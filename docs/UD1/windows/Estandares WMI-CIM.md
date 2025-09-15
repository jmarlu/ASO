# Estándares.

## ¿Qué son CIM y WMI?

CIM (Common Information Model) es un estándar abierto creado por la organización DMTF orientado a proveer una definición común para el intercambio de información entre sistemas, redes, aplicaciones y servicios.

WMI (Windows Management Instrumentation) es la implementación de Microsoft de CIM, con la que se proveen métodos para consultar y modificar la configuración de una máquina Window.

Aunque esta definido anteriormente como un estándar abierto, actualmente es el nombre de la implementación . Por lo tanto:

Los cmdlets Wmi fueron los que aparecieron primero pero a partir de Windows PowerShell 3 fueron sustituidos por los CimCmdlets.

## Descubrir las clases que soporta.

`Get-CimClass` es **EL** comando elegido para descubrir todo lo que se esconde en una infraestructura
CIM/WMI ya que el descubrimiento era hasta ahora el gran punto débil de esta tecnología.

Veamos un ejemplo:

```PowerShell title="Filtrar clases"
 Get-CimClass -ClassName *network*
>>


   NameSpace: ROOT/cimv2

CimClassName                        CimClassMethods      CimClassProperties
------------                        ---------------      ------------------
Win32_NetworkLoginProfile           {}                   {Caption, Description, SettingID, AccountExpires...}
Win32_NetworkAdapterConfiguration   {EnableDHCP, Rene... {Caption, Description, SettingID, ArpAlwaysSourceRoute...}
Win32_NetworkAdapterSetting         {}                   {Element, Setting}
```

Pero podemos, también las propiedades y métodos.

```PowerShell title=""
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT>  (Get-CimClass -ClassName Win32_NetworkAdapterConfiguration).
>> CimClassProperties | Select-Object Name
>>

Name
----
Caption
Description
SettingID

```

También podemos buscar clases que tengan una propiedad o método en concreto.

```PowerShell title=""
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT>  Get-CimClass -PropertyName speed


   NameSpace: ROOT/cimv2

CimClassName                        CimClassMethods      CimClassProperties
------------                        ---------------      ------------------
CIM_NetworkAdapter                  {SetPowerState, R... {Caption, Description, InstallDate, Name...}
Win32_NetworkAdapter                {SetPowerState, R... {Caption, Description, InstallDate, Name...}
```

## Recuperar las instancias de esas clases.

Ya hemos visto que tipos hay. Ahora debemos recuperar el objeto o instancia perteneciente a una clase en concreto.

Veamoslo en el siguiente ejemplo.

```PowerShell title=""
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT> Get-CimInstance -ClassName Win32_BIOS


SMBIOSBIOSVersion : VirtualBox
Manufacturer      : innotek GmbH
Name              : Default System BIOS
SerialNumber      : 0
Version           : VBOX   - 1
```

## Recuperar con un filtro QL/CQL

Cuando una consulta CIM/WMI devuelve un gran número de objetos, es preferible utilizar (con `Where-Object`).

## Comandos de la familia WMI

Como hemos dicho anteriormente el conjunto de comandos WMI ha sido sustituido por los comandos de la familia CIM.
Aunque hay muchos scripts que poseen dichos comandos. Por ejemplo, el comando `Get-CimInstance` tienes como equivalente a `get-wmiObject`

## Establecer sesiones con equipos remotos

Mientras que los comando WMI se comunicaban con máquinas remotas mediante los protocolos DCOM y RPC. Éstas, no eran óptimas dado que la sesión se elimina después de haber devuelto los resultados.

Sin embargo, los comandos de la familia CIM mejoran enormemente esta comunicación aportando:

- Una comunicación que permite eligir entre los protocolos HTTPS/WS-Man o DCOM/RPC.
- La posibilidad de mantener una sesión entre el cliente y los servidores.
- La posibilidad de enviar consultas de manera paralela y no secuencial.
- Un mecanismo de «remoting» similar a las sesiones PowerShell remotas.

Para el siguiente ejemplo tenemos un Windows server con un dominio y un windows 10 añadido al dominio de tal manera que consultamos desde un ordenador a otro. el nombre de la computadora y el dia que instaló el sistema operativo y su versión.

```PowerShell title=""
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT> $s = New-CimSession -ComputerName localhost, cliente2
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT> Get-CimInstance -ClassName Win32_operatingSystem -CimSession $s |
>> Select-Object PSComputerName, Installdate, Version, Caption

PSComputerName Installdate         Version    Caption
-------------- -----------         -------    -------
localhost      06/10/2023 8:55:15  10.0.20348 Microsoft Windows Server 2022 Standard
cliente2       15/03/2022 18:27:37 10.0.19044 Microsoft Windows 10 Education

```

Este ejemplo lo he realizado desde el Windows Server dado que tenemos un usuario administrador del dominio. Se puede realizar al contrario, pero tenemos que cambiar la credencial.

Podemos también, quitar todas las conexiones que hemos establecido anteriormente mediante.

```PowerShell title=""
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT> Get-CimSession


Id           : 1
Name         : CimSession1
InstanceId   : d92a043e-ff09-4abb-9fe1-dc53a7678539
ComputerName : cliente2
Protocol     : WSMAN

Id           : 2
Name         : CimSession2
InstanceId   : ec1f236f-d97a-4efb-a18f-ad788b8e7f45
ComputerName : localhost
Protocol     : WSMAN



PS C:\Users\Administrador.WIN-OT4FJF7Q1AT> Get-CimSession | Remove-CimSession
>>
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT> Get-CimSession
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT>
```

## Gestionar o monitorizar eventos\.

Es una herramienta muy útil de CIM/WMI que permite vigilar eventos (click, ejecución de procesos, etc.. ).

Para suscribirnos a un evento, por ejemplo a la creación de proceso.El comando PowerShell clave para llevar a cabo esta
operación es `Register-CimIndicationEvent`.

Vamos a ver un ejemplo en el que se monitoriza la ejecución cualquier proceso y nos muestra un mensaje.

```PowerShell title="Script cuando se genera proceso"
$action = {
  $name = $event.SourceEventArgs.NewEvent.ProcessName
  $id = $event.SourceEventArgs.NewEvent.ProcessId
  Write-Host -Object "New Process Started : Name = $name
 ID = $id"
}
Register-CimIndicationEvent -ClassName 'Win32_ProcessStartTrace' -SourceIdentifier "ProcessSta" -Action $action

```

En este ejemplo se suscribe a los eventos generados por la clase denominada Win32_ProcessStartTrace. Esta clase genera un evento cada vez que se inicia un proceso. La variable $action contiene el bloque de script para Action, que usa la $event variable para acceder al evento recibido de CIM.

## Comunicaciones remotas de Windows PowerShell

El mecanismo de comunicación remota de Windows PowerShell, presente desde la versión 2.0, llamado también _Gestión remota de Windows (WinRM)_ y nos permite la administración de equipos Windows.

Para autorizar a un sistema a recibir comandos remotos, es necesario activar el remoting con el comando `Enable-PSRemoting`.
El comando debe ejecutarse en una consola PowerShell abierta con la opción Ejecutar como administrador.

El servicio WinRM se configura básicamente con **HTTP** en el puerto 5985 y escucha en todas las direcciones IP. Para forzar el uso de **HTTPS** y así cifrar sus conexiones, debe primero obtener un certificado que almacenará en el
almacén Equipo local/Personal.

!!!note

      La activación y configuración del servicio WinRM en un gran número de servidores o puestos de trabajo puede realizarse con GPO.

### Sesiones Remotas.

Antes de poder **enviar órdenes** a un equipo remoto para administrarlo, es necesario establecer una sesión remota.
Una sesión remota puede ser:

- **Temporal:** una sesión temporal se establece justo durante el tiempo del envío de un comando con `Invoke-Command o Enter-PSSession`.
- **Permanente:** Una sesión permanente es útil en los casos donde debemos ejecutar varios comandos que comparten datos mediante variables o funciones. La creación de una conexión permanente a un equipo local o remoto se realiza con el comando
  `New-PSSession`

```PowerShell title="Establecientod una sesion con Cliente2"
$session = New-PSSession -ComputerName cliente2
# Si necesitamos cambiar de credenciales podemos utilizar el siguiente comandos

$cred = Get-Credential
$session = New-PSSession -ComputerName cliente2  -Credential $cred

```

Ahora podemos ejecutar de comandos remotos con `Invoke-Command`

```PowerShell title="consulta de servicios en ejecución de Cliente2"
$cmde = { Get-Service | Where {$_.Status -eq ’running’} }
Invoke-Command -ComputerName cliente2 -ScriptBlock $cmde
Status   Name               DisplayName                            PSComputerName
------   ----               -----------                            --------------
Running  AdobeARMservice    Adobe Acrobat Update Service           cliente2
Running  Appinfo            Información de la aplicación           cliente2
Running  AppXSvc            Servicio de implementación de AppX ... cliente2
```

En el siguiente ejemplo lanzamos un comando en la máquina cliente2 utilizando la sesión anteriormente creada $sesion.

```PowerShell title=""
 Invoke-Command -Session $session -ScriptBlock {$s=Get-Service wuauserv}



PS C:\Users\Administrador.WIN-OT4FJF7Q1AT>  Invoke-Command -Session $session -ScriptBlock {$s}



Status   Name               DisplayName                            PSComputerName
------   ----               -----------                            --------------
Running  wuauserv           Windows Update                         cliente2

Invoke-Command -Session $session -ScriptBlock {$s | Stop-Service}



PS C:\Users\Administrador.WIN-OT4FJF7Q1AT>  Invoke-Command -Session $session -ScriptBlock {$s}



Status   Name               DisplayName                            PSComputerName
------   ----               -----------                            --------------
Stopped  wuauserv           Windows Update                         cliente2


```

En el siguiente ejemplo vamos a la ver cuanto disco duro queda libre en el equipo remoto , pero esta vez ejecutamos un script en el equipo remoto.
Empecemos por el script.

```PowerShell title="Script freeSpace.ps1"
Function Get-DiskFreeSpace {
$Disks = Get- Win32_LogicalDisk |
Where {$_.DriveType -eq 3}
Foreach($disk in $Disks)
{
$prop = [Ordered]@{
’ID’ = $disk.DeviceID
’FreeSpace(GB)’ = [Math]::Round(($disk.FreeSpace)/1GB,3)
’FreeSpace(%)’ =
[Math]::Round(($disk.FreeSpace)*100/($disk.Size),3)
}
New-Object -TypeName PSObject -Property $prop
}
}

```

Vamos a explicar el anterior script un poco más:

- Hemos creado una función que podemos reutilizar.
- Se crea una variable `$disk` para contener la consulta sobre los discos que sean de tipo 3. Estos son discos locales.
- Se crea un objeto personalizado `New-Object` por cada uno de los discos en las que las propiedades de estos viene determinada por una matriz diccionario ordenada `[Ordered]@`.

A continuación se ejecuta ese script en los ordenadores remotos, en este caso cliente2.

```PowerShell title="Invocamos"
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT> Invoke-Command -ComputerName cliente2 -FilePath .\Documents\free.ps1


DeviceID DriveType ProviderName VolumeName Size        FreeSpace PSComputerName
-------- --------- ------------ ---------- ----        --------- --------------
C:       3                                 53083406336 765591552 cliente2

ID             : C:
FreeSpace(GB)  : 0,713
FreeSpace(%)   : 1,442
PSComputerName : cliente2
RunspaceId     : 1f37c8a5-986b-4766-ba65-c85143e3d03f

```

En el anterior ejemplo no hemos abierto una sesión , hemos utilizado la opción `-ComputerName`

#### Apertura de una sesión remota interactiva PowerShell

Se puede ejecutar comandos en modo interactivo en un equipo remoto. Se trata de un funcionamiento similar al de SSH.

El comando `Enter-PSSession` arranca una única sesión interactiva en un equipo remoto. Se puede abrir una sola sesión interactiva a la vez.
Ejemplo:

```PowerShell title="Sesion remota interactiva"

PS C:\Users\Administrador.WIN-OT4FJF7Q1AT> Enter-PSSession -ComputerName cliente2
[cliente2]: PS C:\Users\Administrador\Documents>
```

#### Importación de comandos

Supongamos que en un equipo tenemos modulos que nos gustaría usar en nuestro equipo local.

Veamos un ejemplo, en nuestro disponemos de un servidor con el
rol «Active Directory Domain Services» instalado. Este módulo aporta numerosos comandos para la gestión de objetos de usuario, equipos, grupos, OUs, etc. Por lo tanto queremos importar este módulo en la sesión actual de nuestro cliente.

Creamos una sesión e importamos el módulo desde el servidor al `cliente2`. **La sesión que tenemos que abrir en el cliente es de administrador, sino no nos deja**.

```PowerShell title="Importación de módulo"
PS > $s = New-PSSession -ComputerName servidor
PS > Invoke-Command -Session $s -ScriptBlock { Import-Module ActiveDirectory }
# ya hemos importado (esto se toma un poco de tiempo) desde server y ahora podemos importar los comandos que lo componen.
PS > Import-PSSession -Session $s -Module ActiveDirectory

```

Con lo cuál, ahora ya podemos utilizar esos comandos.

```PowerShell title="Demostración"
PS > Get-Command *-AD*

```
