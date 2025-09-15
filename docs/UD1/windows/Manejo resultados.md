# Manejo y selección de resultados.

Podemos utilizar dos básicamente `Select-objet` o realizar un filtro más especifico mediante `Where-Object` y todos ellos se les trasfiere los objetos mediante el pipe «|».

## Recuperación de Objetos.

La recuperación de objetos mediante `Select-Object` es muy sencilla y tiene opciones muy interesantes.

Veamos un ejemplo:

```PowerShell title="Selección de cinco procesos"

S /home/julio> $processes | Select-Object -first 5

 NPM(K)    PM(M)      WS(M)     CPU(s)      Id  SI ProcessName
 ------    -----      -----     ------      --  -- -----------
      0     0,00       4,08       0,00  155061 …30 (sd-pam)
      0     0,00       8,53       0,20     992 992 accounts-daemon
      0     0,00       3,92       0,09    8039 …39 accounts-daemon
      0     0,00       0,69       0,17     996 996 acpid
      0     0,00       0,00       0,00     162   0 acpi_thermal_pm


```

Podemos sacar los procesos únicos con la opción `-Unique`.

```PowerShell title=" Selección de cinco procesos únicos"


PS /home/julio>  Get-Process | Select-Object -Unique | Select-Object -First 5

 NPM(K)    PM(M)      WS(M)     CPU(s)      Id  SI ProcessName
 ------    -----      -----     ------      --  -- -----------
      0     0,00       4,07       0,00  155061 …30 (sd-pam)
      0     0,00       8,41       0,35     992 992 accounts-daemon
      0     0,00       0,69       0,33     996 996 acpid
      0     0,00       0,00       0,00     162   0 acpi_thermal_pm
      0     0,00       4,65       0,00  156132 …31 agent

```

Para recuperar el nombre de los procesos
así como el id asociado podemos escribirlo.

```PowerShell title=""
PS /home/julio>  Get-Process | Select-Object ProcessName,ID |  Select-Object -First 5

ProcessName         Id
-----------         --
(sd-pam)        155061
accounts-daemon    992
accounts-daemon   8039
acpid              996
acpi_thermal_pm    162

```

Otra forma de recuperar los objetos es mediante el filtro de busqueda, gracias a `Where-Object`.

Vemos el siguiente ejemplo:

```PowerShell title="Recupera servicios en ejecución"
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT> $services = Get-Service
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT> $services

Status   Name               DisplayName
------   ----               -----------
Running  ADWS               Servicios web de Active Directory
Stopped  AJRouter           Servicio de enrutador de AllJoyn
Stopped  ALG                Servicio de puerta de enlace de niv...


PS C:\Users\Administrador.WIN-OT4FJF7Q1AT> $services | Where-Object {$_.Status -eq ’running’}
Status   Name               DisplayName
------   ----               -----------
Running  ADWS               Servicios web de Active Directory
Running  AppXSvc            Servicio de implementación de AppX ...
Running  BFE                Motor de filtrado de base
```

Aplicamos ahora un filtro para recuperar únicamente los servicios de Windows en ejecución de.

El «$\_» indica que tratamos el objeto actual, en cada momento.

Ahora podemos encadenar otra comparación
separadas por un «pipe».

```PowerShell title="Los tres últimos servicios"
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT>
>> $services | Where-Object {$_.Status -eq ’running’}| Select-Object -Last 3

Status   Name               DisplayName
------   ----               -----------
Running  WpnService         Servicio del sistema de notificacio...
Running  WpnUserService_... Servicio de usuario de notificacion...
Running  wuauserv           Windows Update
```

## Formateo para su visualización

### Listado

Para mostrarlo en formato lista. Es decir
que cada propiedad de cada objeto se muestra en una nueva línea. Mediante al propiedad `Format-first`

```PowerShell title=""
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT>  Get-ChildItem C:\ | Format-List
   Directorio: C:\
Name           : PerfLogs
CreationTime   : 08/05/2021 10:20:24
LastWriteTime  : 08/05/2021 10:20:24
LastAccessTime : 08/05/2021 10:20:24
```

Otro ejemplo, para mostrar selectivamente algunas propiedades de los servicios de Windows:

```PowerShell title=""

PS C:\Users\Administrador.WIN-OT4FJF7Q1AT> Get-Service | Format-List Name, Displayname,Status

Name        : ADWS
DisplayName : Servicios web de Active Directory
Status      : Running
```

!!!note

      La ventaja principal de usar el comando Format-List respecto a la visualización de un tipo tabla (Format-Table), es que los valores de las propiedades disponen de más sitio en pantalla para mostrarse, y por lo tanto no se truncan.

### Tabla

Casi la mayoría de los cmlets lo muestran así, si no es el caso, tenemos `Format-table`.

Para que no se trunque información podemos poner la opción `Autosize`. Veamos un ejemplo:

```PowerShell title=""
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT>  Get-ChildItem C:\| Format-Table -Property mode,name,length,
>> isreadonly,creationTime -Autosize

Mode   Name                length isreadonly CreationTime
----   ----                ------ ---------- ------------
d----- PerfLogs                              08/05/2021 10:20:24
d-r--- Program Files                         08/05/2021 10:20:24
d----- Program Files (x86)                   08/05/2021 10:20:24
d-r--- Users                                 08/05/2021 10:06:51
d----- Windows                               08/05/2021 10:06:51
```

## Redirección

Para redirigir el flujo de salida hacia un archivo podemos utilizar `> y >>`, de la misma manera que en linux Veamos varios ejemplos.

```PowerShell title="Mandar a un archivo"
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT> Get-Process > .\temp\process.txt

PS C:\Users\Administrador.WIN-OT4FJF7Q1AT\temp> Get-Content .\process.txt

Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
-------  ------    -----      -----     ------     --  -- -----------
     92       6      868       4688       0,00   2204   0 AggregatorHost
    258      14     8600      26888       0,36   4836   1 conhost
```

Por ejemplo si queremos redirigir el canal de error, que es el mismo que en linux, a un archivo, lo podemos realizar de la siguiente manera.

```PowerShell title=""
 C:\Users\Administrador.WIN-OT4FJF7Q1AT\temp>  Get-ChildItem C:\Temp\DirInexistente 2> .\err.txt
>>
PS C:\Users\Administrador.WIN-OT4FJF7Q1AT\temp> Get-Content .\err.txt
Get-ChildItem : No se encuentra la ruta de acceso 'C:\Temp\DirInexistente' porque no existe.
En línea: 1 Carácter: 2
+  Get-ChildItem C:\Temp\DirInexistente 2> .\err.txt
+  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (C:\Temp\DirInexistente:String) [Get-ChildItem], ItemNotFoundException
    + FullyQualifiedErrorId : PathNotFound,Microsoft.PowerShell.Commands.GetChildItemCommand
```
