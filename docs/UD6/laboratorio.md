# Laboratorio: acceso remoto entre Linux y Windows

## 1. Preparar el entorno

Usa VMs de laboratorio con instantánea y consola accesible. Estas direcciones son un ejemplo: sustitúyelas de forma coherente si tu red usa otras.

| Equipo | Sistema | IP de laboratorio | Función |
|---|---|---|---|
| `srv-linux` | Ubuntu Server 24.04 | 10.50.0.10 | Servidor SSH |
| `cli-linux` | Ubuntu Desktop 24.04 | 10.50.0.20 | Cliente SSH y RDP |
| `win-remoto` | Windows 11 Pro/Education/Enterprise | 10.50.0.30 | Cliente SSH y servidor RDP |
| `win-cliente` | Windows 11 | 10.50.0.40 | Cliente RDP, compartible por parejas |

Conecta las interfaces de laboratorio a la misma red privada `10.50.0.0/24`. Una segunda interfaz NAT puede servir para instalar paquetes. Registra IP y versión reales con `ip -br a`, `cat /etc/os-release` y, en Windows, `ipconfig` y `winver`. Comprueba que las IP no estén duplicadas.

## 2. Instalar SSH y crear la cuenta

En la **consola de srv-linux**, con la cuenta administradora de instalación:

```bash
sudo apt update
sudo apt install openssh-server python3
sudo systemctl enable --now ssh
sudo adduser asoadmin
sudo usermod -aG sudo asoadmin
id asoadmin
sudo ss -ltnp 'sport = :22'
sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

La cuenta se crea una sola vez en una VM limpia; elige su contraseña de forma interactiva. Aquí dispone de sudo porque realizará mantenimiento. Anota su grupo y explica qué acciones lo necesitan. Guarda la huella pública de host para contrastarla en los clientes.

Si UFW ya está activo, autoriza `sudo ufw allow from 10.50.0.0/24 to any port 22 proto tcp`. Si vas a activarlo para la práctica, prepara esa regla desde la consola antes de habilitarlo y anota su estado previo. No cambies el puerto SSH: Ubuntu puede utilizar activación por `ssh.socket`, que debe revisarse aparte si se cambia la escucha.

En **cli-linux**:

```bash
sudo apt install openssh-client rsync remmina
ssh asoadmin@10.50.0.10
```

Contrasta la huella antes de aceptar. Dentro de la sesión ejecuta `hostname`, `whoami` e `id`; termina con `exit`. Después prueba la orden puntual:

```bash
ssh asoadmin@10.50.0.10 'hostname; id; uptime'
```

Si la imagen del servidor ya impide contraseñas, incorpora la clave pública desde su consola en el paso siguiente; no debilites la configuración para copiarla.

## 3. Claves de cliente y acceso desde Windows

En **cli-linux**, crea una clave exclusiva de este laboratorio con frase de paso. Si el archivo ya existe, reutilízalo tras identificarlo o elige otro nombre; no lo sobrescribas.

```bash
ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519_aso" -C 'ASO-UD6-cli-linux'
ssh-copy-id -i "$HOME/.ssh/id_ed25519_aso.pub" asoadmin@10.50.0.10
ssh -o IdentitiesOnly=yes -i "$HOME/.ssh/id_ed25519_aso" asoadmin@10.50.0.10 'id'
```

La petición de frase de paso de la clave local es compatible con el acceso por clave. Comprueba que no se esté usando como alternativa la contraseña remota.

En **win-remoto**, abre PowerShell con tu usuario normal:

```powershell
Get-Command ssh, ssh-keygen
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\id_ed25519_aso" -C 'ASO-UD6-windows'
Get-Content "$env:USERPROFILE\.ssh\id_ed25519_aso.pub"
ssh asoadmin@10.50.0.10
```

Si no existe `ssh`, instala el **cliente OpenSSH** desde Características opcionales con la cuenta administradora de la VM y vuelve a abrir PowerShell. Referencia: [OpenSSH en Windows](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse).

Para registrar la clave de Windows, copia **solo la línea del archivo `.pub`**. En la sesión Linux iniciada como `asoadmin`, o entrando a esa cuenta desde la consola con `sudo -iu asoadmin`:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
nano ~/.ssh/authorized_keys
```

Añade la línea completa sin borrar la clave de cli-linux. Cierra la sesión y prueba desde Windows:

```powershell
ssh -o IdentitiesOnly=yes -i "$env:USERPROFILE\.ssh\id_ed25519_aso" asoadmin@10.50.0.10 'hostname; id'
```

**Punto de control:** ambos clientes acceden por su propia clave a la misma cuenta remota. La clave privada nunca sale de su cliente.

## 4. Restringir el acceso sin perder la consola

Mantén abierta la sesión actual y la consola del hipervisor. Guarda una copia de la configuración y revisa los fragmentos existentes:

```bash
sudo cp -a /etc/ssh/sshd_config /etc/ssh/sshd_config.ud6.bak
sudo ls -l /etc/ssh/sshd_config.d/
sudoedit /etc/ssh/sshd_config.d/00-aso-ud6.conf
```

Contenido del nuevo fragmento, para esta VM dedicada:

```text
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
AllowUsers asoadmin
AllowAgentForwarding no
AllowTcpForwarding local
X11Forwarding no
```

`AllowUsers` restringe a todas las cuentas SSH del servidor: úsalo en la VM dedicada y conserva la administración local por consola. El reenvío TCP local se mantiene para el túnel del paso 7.

```bash
sudo /usr/sbin/sshd -t
sudo /usr/sbin/sshd -T -C user=asoadmin,addr=10.50.0.20,host=cli-linux | grep -E '^(permitrootlogin|passwordauthentication|kbdinteractiveauthentication|pubkeyauthentication|allowusers|allowtcpforwarding) '
```

Si la validación falla o los valores no coinciden, revisa los fragmentos y bloques `Match` antes de continuar. Cuando coincidan:

```bash
sudo systemctl reload ssh
```

Abre una **segunda conexión** por clave desde cada cliente. Desde cli-linux comprueba también el rechazo de contraseña:

```bash
ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password,keyboard-interactive asoadmin@10.50.0.10
```

Se espera rechazo. Registra la consulta y el registro del servidor con `sudo journalctl -u ssh --since '-10 minutes' --no-pager`. Si tu distribución utiliza `auth.log`, consúltalo también.

**Recuperación:** desde la consola renombra únicamente `00-aso-ud6.conf` como `00-aso-ud6.conf.disabled`, ejecuta `sshd -t` y recarga `ssh`. Corrige la causa antes de volver a aplicar el fragmento; no cierres la única conexión útil para probar.

## 5. Transferir y verificar

En **cli-linux**, crea un documento de prueba y transfiérelo:

```bash
mkdir -p ~/ud6-cliente
echo 'Evidencia de transferencia ASO UD6' > ~/ud6-cliente/prueba.txt
ssh -i ~/.ssh/id_ed25519_aso asoadmin@10.50.0.10 'mkdir -p ~/ud6-remoto'
scp -i ~/.ssh/id_ed25519_aso ~/ud6-cliente/prueba.txt asoadmin@10.50.0.10:ud6-remoto/
sha256sum ~/ud6-cliente/prueba.txt
ssh -i ~/.ssh/id_ed25519_aso asoadmin@10.50.0.10 'sha256sum ~/ud6-remoto/prueba.txt'
rsync -avn -e 'ssh -i ~/.ssh/id_ed25519_aso' ~/ud6-cliente/ asoadmin@10.50.0.10:ud6-remoto/
```

Los hashes deben coincidir. `-n` simula rsync; revisa su salida antes de retirar esa opción si quieres repetir la sincronización. No necesitas `--delete`.

## 6. Administrar un servicio

Consulta desde cli-linux `systemctl --failed --no-pager` mediante una orden SSH. Si conservas UD5, consulta `systemctl list-timers --all aso-informe.timer` y el resultado del informe; si no, consulta el servicio `ssh`.

Para una acción que requiera privilegios, abre una sesión interactiva y usa sudo con contraseña dentro de ella. No guardes contraseñas en scripts ni habilites sudo sin contraseña para toda la cuenta. Aporta una consulta antes y después de la acción autorizada.

## 7. Abrir un túnel a un servicio local

En una terminal de **srv-linux** como `asoadmin`:

```bash
mkdir -p ~/ud6-web
echo 'Servicio local de ASO UD6' > ~/ud6-web/index.html
python3 -m http.server 8000 --bind 127.0.0.1 --directory ~/ud6-web
```

Déjala abierta. En otra terminal de srv-linux, comprueba que `ss -ltn 'sport = :8000'` muestra `127.0.0.1:8000`. En **cli-linux**:

```bash
ssh -i ~/.ssh/id_ed25519_aso -o ExitOnForwardFailure=yes -N -L 127.0.0.1:8080:127.0.0.1:8000 asoadmin@10.50.0.10
```

Desde el navegador de cli-linux abre `http://127.0.0.1:8080`. Debe verse el texto. El acceso directo a `http://10.50.0.10:8000` desde el cliente debe fallar porque el servidor HTTP solo escucha en su loopback. Finaliza el túnel con `Ctrl+C` y demuestra que la URL local deja de responder; después detén el servidor HTTP.

## 8. Escritorio remoto Windows → Windows y Linux → Windows

En la consola de **win-remoto**, con administrador local:

1. Crea una cuenta local estándar `asoremoto`, con contraseña, desde la administración de usuarios. Registra que no pertenece a Administradores.
2. Activa **Configuración → Sistema → Escritorio remoto**. Mantén la autenticación a nivel de red, NLA.
3. Añade `asoremoto` a los usuarios autorizados para Escritorio remoto.
4. En el firewall avanzado identifica las reglas entrantes de RDP. Limita su ámbito remoto a `10.50.0.0/24` y los perfiles a la red privada de laboratorio. Revisa que no haya otra regla RDP más amplia habilitada.
5. Anota el nombre real con `hostname` y el usuario de conexión como `NOMBREDELPC\asoremoto`.

En **win-cliente**, ejecuta `Test-NetConnection 10.50.0.30 -Port 3389` en PowerShell y abre `mstsc /v:10.50.0.30`. Contrasta nombre/certificado con el equipo de la consola y entra con la cuenta autorizada. Dentro abre PowerShell y muestra `hostname`, `whoami` y `Get-Service Spooler`.

Cierra **la sesión** desde Windows antes de la segunda prueba. En **cli-linux**, abre Remmina, crea un perfil RDP hacia `10.50.0.30` y usa las mismas credenciales. Verifica otra vez el equipo y ejecuta la consulta de servicio. Guarda la evidencia de la conexión heterogénea. Si Remmina no negocia NLA, revisa cliente y perfil; no desactives NLA para dar por superada la actividad.

Prueba una cuenta estándar de laboratorio que no esté autorizada para RDP y verifica el rechazo. No utilices una cuenta administradora para esa prueba, pues puede disponer del derecho por otro grupo.

## 9. Cerrar y documentar

- Cierra sesiones y túneles. Recupera los archivos de evidencia antes de retirar cuentas o VMs.
- Si vas a reutilizar SSH en UD7, conserva el acceso por clave y documenta su configuración. Si no, restaura la instantánea inicial después de entregar las evidencias.
- Desactiva Escritorio remoto si no se necesita, retira solo las autorizaciones creadas para la práctica y devuelve las reglas modificadas a su estado previo.
- Registra la configuración final, los puertos que quedan disponibles y cualquier validación pendiente.

No se exige instalar [las ampliaciones](ampliacion.md) para completar este recorrido.
