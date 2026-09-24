# Ampliación: PowerShell Remoting y xRDP

Estas prácticas requieren tiempo y VMs preparados por el docente. Complementan las ocho horas del recorrido básico.

## PowerShell Remoting en un dominio de laboratorio

Usa dos VMs Windows unidas al mismo dominio de pruebas, DNS del dominio y reloj sincronizado. El nombre `win-remoto.aula.test` representa el nombre DNS real del servidor; sustitúyelo. Este recorrido usa Windows PowerShell 5.1 y WinRM. Una instalación de PowerShell 7 puede tener endpoints diferentes.

En el servidor, con PowerShell elevado:

```powershell
Enable-PSRemoting -Force
Get-Service WinRM
Get-PSSessionConfiguration
```

Comprueba las reglas WinRM de firewall y limita el ámbito a la red de gestión del laboratorio. En el cliente, con una cuenta de dominio autorizada en el endpoint remoto:

```powershell
Test-WSMan win-remoto.aula.test
Invoke-Command -ComputerName win-remoto.aula.test -Authentication Kerberos -ScriptBlock {
    hostname
    Get-Service Spooler
}
$sesion = New-PSSession -ComputerName win-remoto.aula.test -Authentication Kerberos
Invoke-Command -Session $sesion -ScriptBlock { $script:etiqueta = 'prueba UD6' }
Invoke-Command -Session $sesion -ScriptBlock { $script:etiqueta }
Remove-PSSession $sesion
```

Consulta, autenticación y permiso sobre el endpoint son comprobaciones distintas. La práctica reutiliza una cuenta administrativa de dominio **solo del laboratorio**; una delegación con JEA y mínimos privilegios necesita un diseño adicional. No deduzcas del puerto 5985 que los comandos viajan necesariamente en claro: Kerberos puede proteger los mensajes de WinRM. HTTPS en 5986 añade TLS y requiere un certificado de servidor válido.

**En grupo de trabajo:** no apliques este bloque como si hubiese Kerberos. El docente debe preparar un listener HTTPS con certificado confiable y una cuenta autorizada. No uses `TrustedHosts=*`, Basic sin TLS ni `AllowUnencrypted`. Registra como pendiente la prueba si el entorno no dispone de esas condiciones. Referencia: [diagnóstico y requisitos de PowerShell Remoting](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_remote_troubleshooting?view=powershell-7.5).

**Entrega:** respuesta puntual, estado compartido en PSSession, sesión cerrada y explicación de autenticación/cifrado. Al retirar el laboratorio restaura la instantánea; `Disable-PSRemoting` por sí solo no revierte todos los cambios de WinRM y firewall.

## xRDP en una VM Linux separada

Utiliza una VM Ubuntu 24.04 nueva, con consola accesible, IP `10.50.0.50` y espacio para un escritorio Xfce. No instales este escritorio en el servidor SSH del recorrido básico.

```bash
sudo apt update
sudo apt install xrdp xorgxrdp xfce4
sudo adduser asoescritorio
sudo adduser xrdp ssl-cert
sudo -iu asoescritorio sh -c 'echo startxfce4 > "$HOME/.xsession"; chmod 600 "$HOME/.xsession"'
sudo systemctl enable --now xrdp
sudo systemctl restart xrdp
sudo ss -ltnp 'sport = :3389'
```

Si UFW está activo, permite TCP 3389 únicamente desde `10.50.0.0/24`. Revisa el certificado configurado en `/etc/xrdp/xrdp.ini`, contrástalo desde la consola y mantén el transporte TLS. Cierra cualquier sesión gráfica local de `asoescritorio` antes de probar la sesión remota.

Desde Windows abre `mstsc /v:10.50.0.50`, selecciona la sesión Xorg si el diálogo de xRDP la ofrece y autentica `asoescritorio`. Consulta identidad, crea un archivo en su home y cierra la sesión desde el escritorio. No presupongas que es el mismo escritorio que se ve en la consola.

Si falla, consulta `sudo journalctl -u xrdp -u xrdp-sesman --since '-10 minutes' --no-pager`, `/var/log/xrdp.log` y `/var/log/xrdp-sesman.log`. Revisa usuario, contraseña, sesión Xorg, escritorio y certificado antes de cambiar controles de acceso. Referencia: [proyecto xRDP](https://github.com/neutrinolabs/xrdp).

**Entrega:** cliente, servidor, identidad, transporte y registro de sesión. Restaura la instantánea al terminar o documenta qué servicio permanece accesible.
