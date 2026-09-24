# Administrar un equipo a distancia

## 1. Las capas de una conexión

Comprueba en este orden: red y dirección de destino; puerto y servicio; identidad del servidor; autenticación del usuario; autorización para la acción. Un fallo en una capa no se arregla quitando controles de otra. Por ejemplo, una clave pública ausente no se resuelve abriendo más puertos.

El cliente inicia la conexión; el servidor acepta solicitudes. La cuenta local desde la que ejecutas el cliente puede ser distinta de la cuenta remota. Una orden `hostname` ejecutada en tu terminal y otra ejecutada mediante SSH pueden mostrar equipos diferentes.

## 2. Herramientas y usos

| Tecnología | Uso | Puerto habitual | Protección y observaciones |
|---|---|---|---|
| SSH | Terminal, órdenes y túneles | TCP 22 | Cifra el transporte; verifica la clave del servidor |
| SFTP / SCP | Transferencia sobre SSH | TCP 22 | Mantienen la autenticación y el cifrado de SSH |
| RDP | Escritorio remoto Windows y servidores compatibles | TCP/UDP 3389 | Certificado, cifrado y NLA en el recorrido Windows |
| WinRM / PowerShell Remoting | Administración por objetos | TCP 5985 / 5986 | HTTP/HTTPS; el método de autenticación y la configuración determinan la protección |
| VNC | Acceso gráfico | TCP 5900 y siguientes | La protección depende de la implementación; requiere estudiar autenticación y cifrado |

Los puertos son valores habituales, no una garantía de configuración. El laboratorio limita el acceso a la red privada de VMs. No se necesitan redirecciones de puertos del router hacia Internet.

### Sesión interactiva y orden puntual

`ssh usuario@equipo` mantiene un entorno interactivo mientras trabajas. `ssh usuario@equipo 'hostname'` ejecuta una orden y termina. Ambos utilizan una conexión SSH autenticada; «no orientado a sesión» describe aquí el modo de trabajo de una petición puntual, no la inexistencia de una sesión de protocolo o de estado interno.

En PowerShell, una `PSSession` permite reutilizar estado entre llamadas. `Invoke-Command` también puede lanzar una consulta puntual. RDP mantiene un escritorio; desconectar su ventana no siempre cierra la sesión del usuario.

## 3. Identidad y claves SSH

Hay dos parejas de claves distintas:

- **Claves de host:** identifican al servidor. El cliente guarda la identidad aceptada en `known_hosts`. Contrasta la huella por la consola antes de aceptar una primera conexión.
- **Claves de usuario:** identifican a una cuenta cliente. La clave privada permanece en el cliente, protegida con frase de paso; la pública se incorpora a `authorized_keys` de la cuenta remota.

La frase de paso desbloquea la clave privada local. No es la contraseña de la cuenta del servidor. `ssh-agent` puede mantener la clave desbloqueada durante la sesión; esto no justifica copiar la clave privada a la VM remota.

Una advertencia de cambio de clave de host puede indicar una reinstalación o un equipo distinto. Contrasta primero la nueva huella. Solo después retira la entrada concreta antigua con `ssh-keygen -R DIRECCION`; no vacíes todo `known_hosts`.

## 4. Autenticación y autorización

Acceder por SSH no implica poder ejecutar `sudo`. Entrar por RDP tampoco convierte al usuario en administrador. Se pueden asignar cuentas normales para consulta y reservar la elevación para acciones de mantenimiento justificadas.

La configuración SSH del laboratorio permite exclusivamente `asoadmin`, prohíbe el acceso directo de root y exige clave pública después de probarla. Las claves instaladas y los permisos del directorio personal forman parte de la comprobación.

Antes de recargar `sshd`, valida la sintaxis y consulta la configuración efectiva. En Ubuntu los fragmentos de `sshd_config.d` se incluyen al principio y, para muchas directivas, prevalece el primer valor encontrado. Un archivo llamado `99-...` no garantiza imponerse a los anteriores. Consulta la [guía de OpenSSH de Ubuntu](https://ubuntu.com/server/docs/how-to/security/openssh-server/) y el [manual de configuración](https://man.openbsd.org/sshd_config).

## 5. Escritorio remoto

En Windows, RDP permite usar la interfaz del equipo remoto. Se habilita en el sistema que recibirá la conexión y se autoriza una cuenta concreta. NLA autentica antes de crear la sesión completa. Mantén NLA y verifica la identidad del equipo y su certificado; una red privada facilita la práctica, pero no sustituye estas comprobaciones.

xRDP ofrece un servidor compatible con clientes RDP en Linux. Necesita un entorno gráfico y puede crear una sesión diferente de la sesión de consola. Los fallos de escritorio, gestor de sesión y permisos requieren un diagnóstico distinto de los fallos de red.

La documentación de [Microsoft sobre Escritorio remoto](https://learn.microsoft.com/es-es/windows-server/remote/remote-desktop-services/remotepc/remote-desktop-allow-access) detalla ediciones compatibles y permisos. Para acceso desde fuera de la red se planifica una VPN o pasarela administrada; esa infraestructura no forma parte del laboratorio básico.

## 6. Transferencia y túneles

`scp` copia archivos entre cliente y servidor; comprueba el resultado con un hash. `rsync` permite sincronizar de forma selectiva y puede utilizar SSH. La barra final del origen cambia si se copia el directorio o su contenido; ensaya con `--dry-run` antes de aplicar una sincronización.

Un túnel local recibe conexiones en un puerto del cliente y transporta sus datos hasta un destino accesible desde el servidor SSH. En `-L 127.0.0.1:8080:127.0.0.1:8000`, el primer `127.0.0.1` pertenece al cliente y el segundo al servidor. El puerto local queda accesible solo desde el cliente. El cifrado cubre el tramo SSH; no convierte automáticamente en cifrado un tramo posterior hacia otro equipo.

## 7. Evidencias y diagnóstico

| Síntoma | Qué comprobar primero |
|---|---|
| Tiempo de espera | IP, ruta, VM encendida y filtrado de red |
| Conexión rechazada | Servicio y puerto de escucha |
| Clave de host distinta | Identidad desde la consola y cambios de VM |
| `Permission denied (publickey)` | Usuario, clave ofrecida, `authorized_keys`, propietarios y modos |
| Entra pero no puede administrar | Permisos de la cuenta y política sudo |
| RDP autentica pero falla el escritorio | Edición, permisos de inicio de sesión y registros del servidor |
| Túnel abierto sin respuesta web | Destino visto desde el servidor, servicio local y puerto de origen |

Relaciona cada intervención con una consulta antes y otra después. Conserva hora, comando y resultado; no incluyas contraseñas, claves privadas ni el contenido de archivos personales.
