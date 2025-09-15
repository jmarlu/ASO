# Actividades

## Introducción

1. Genera un Script que muestre los **procesos del sistema** ordenados por el **id**.
2. Muestra los servicios cuyo nombre empiece por la letra `n`, utilizando la creación de un script.
3. Crea un script que se le introduzca dos números como argumentos y los muestre por pantalla.
4. Diseña un script en Shell que pida al usuario dos números, los guarde en dos variables y los muestre por pantalla.
5. Crea un shell script que muestre por pantalla el resultado de de las siguientes operaciones. Debes tener en cuenta que a, b y c son variables enteras que son preguntadas al usuario al iniciar el script.

   - a%b
   - a/c
   - 2 _ b + 3 _ (a-c)
   - a \* (b/c)
   - (a\*c)%b

## Control de flujo

1. Crea un script que si no se la pasa ningún argumento nos lo diga.

2. Crea un script PowerShell que al ejecutarlo muestre por pantalla uno de estos mensajes **“Buenos días”**, **“Buenas tardes”** o **“Buenas noches”**, en función de la hora que sea en el sistema (de 8:00 de la mañana a 15:00 será mañana, de 15:00 a 20:00 será tarde y el resto será noche). Usa el `cmdlet Get-Date`.

3. Construye tres script PowerShell utilizando estructuras iterativas:
4. el primero **ej208A.ps1**, que imprima la **tabla de multiplicar** de un número preguntado al usuario. Este
   número debe ser entero positivo.
5. el segundo **ej208B.ps1**, que pida un número e indique si se trata de un número par y si es número primo.
6. el tercero **ej208C.ps1**, que muestre las diez primeras tablas de multiplicar por pantalla. Hay un tiempo de espera de un segundo entre ellas. Utiliza las estructuras **while, do while, for y foreach y el cmdlet Start-Sleep.**

## Vectores y Funciones

1. Diseña un script PowerShell que lea un vector con 365 temperaturas y calcule la media y cuantos días han estado por encima y cuantos por debajo de ella. Rellena el vector con valores aleatorios entre -5 y 35, para ello usa Get-Random.

2. Crea un script PowerShell para que haga una **copias de seguridad** de todos los archivos del directorio de trabajo del usuario actual. Deberá realizar las siguientes acciones:

   - **comprobará** si el archivo ya existe en la copia de seguridad, si es así comprobará cual de los dos es más reciente y que tamaño tienen. Si es más reciente o posee un tamaño mayor, lo copiará. En cualquier otro caso, no lo copia.
   - llevará un **registro** de todos los archivos copiados cada vez que se ejecute mediante un archivo de bitácora. Guarda este fichero el directorio que contiene el script.

Crea una **función** para cada tarea realizada en este script.

!!! warning

    Utiliza en la generación de los scripts los **cmdlets** de depuración si así lo consideras al haber encontrado problemas en la ejecución.

!!! note "NOTA"

    Escribe el código de los scripts en **PowerShell** que se detallan en cada ejercicio. Deberás crear un fichero de texto para cada ejercicio con el siguiente nombre: ejXXX.sh, donde las X representan el número de ejercicio. Una vez terminada la práctica, comprime todos estos ficheros en uno y súbelos al Moodle.

## Administración

1.  Diseña un script `(scriptAd1.ps1`) que liste todos los equipos de un **Dominio** y que que muestre si están conectado o no.

    ```PowerShell title="Salida del script"
    Equipo   Version
    ---
    SERVIDOR alcanzado
    CLIENTE2 alcanzado
    ASIR no alcanzado
    UBUNTU1 no alcanzado
    ASIRL... no alcanzado
    LINUX... no alcanzado
    UBUNT... no alcanzado
    ```

    !!!note

        Comando para conseguir todos los equipos `Get-ADComputer`
        Envio de un solo ping `Test-Connection $Equipo -quiet -count 1)`.

2.  Modifica el anterior script y guárdalo como `(scriptProcesVirtual.ps1`). Tenemos que comprobar el tamaño en memoria del procesos que se llame PowerShell (propiedad `VirtualMemorySize`) de todos los equipos.

```PowerShell title="Salida del Script"
Equipo   MemoriaVirtual
------   --------------
SERVIDOR      268861440
CLIENTE2      725434368
ASIR       no alcanzado
UBUNTU1    no alcanzado
ASIRL...   no alcanzado
LINUX...   no alcanzado
```

    !!!note

        Tenemos dos opciones utilizar la propiedad `ComputerName` o crear una sesión por cada uno de los ordenadores.

3.  Modifica el anterior script y guárdalo como `(scriptMediaPlayerVersion.ps1`). De tal manera, que en esta versión consigamos la versión del programa Media player. Para ello, es necesario que realizes una función que se llame `Get-Key` y mandes esta a todos los equipos.

    ```PowerShell title="Salida del script"
    Equipo   Version
    ---      ----
    SERVIDOR 12,0,10011,16384
    CLIENTE2 12,0,10011,16384
    ASIR Equipo inalca...
    UBUNTU1 Equipo inalca...
    ASIRL... Equipo inalca...
    ```

    !!!note

         La versión la tenemos que coger del registro de windows. mediante el comando `Get-ItemProperty HKLM:\SOFTWARE\Microsoft\MediaPlayer\PlayerUpgrade -Name "PlayerVersion" -ea silentlycontinue`. Recordar que sólo nos interesa la version. También, si no está instalada que nos diga que no instalada.

4.  Crea el siguiente script `(scriptDNSConfig.ps1`) De tal manera, que este script consiga la configuracion DNS de todos las interfaces activas en los equipos. Esta vez vamos a crear una función que se le pasen por parámetros todos los equipos.

Esta función debe empezar de la siguiente manera:

    ``` PowerShell title=""
    function Get-DNSConfiguration
        {
            [CmdletBinding()]
            Param ( [Parameter(Mandatory=$true,ValueFromPipeline=$true)} [String[]]$ComputerName
        Process
        {
        #Aquí tenéis que poner el código.
        }
        }
    ```

Aclaraciones sobre la creación de la función:

- El `CmdletBinding` atributo es un atributo de funciones que hace que funcionen como cmdlets compilados escritos en C#. Proporciona acceso a las características de los cmdlets. Como por ejemplo que acepte valores desde un Pipeline (`ValueFromPipeline=$true`).
- Después tendremos que buscar de todos los computadoras las interfaces que están activas. Buscando la instancia de la clase `Win32_NetworkAdapter`
- A continuación, deberemos pasarle esas interfaces para recuperar la configuración con la clase Win32_NetworkAdapterConfiguration

El resultado debe ser el siguiente:

```PowerShell title="Salida"

Get-DNSConfiguration -ComputerName cliente2

HostName Ping DNS
-------- ---- ---
cliente2 OK   {172.16.0.3, 8.8.8.8}

#O, como aceptamos pipeline.


Get-ADComputer -Filter * | Select-Object Name -ExpandProperty Name |
Get-DNSConfiguration
#Podemos llamar a esa función de esa manera  porque hemos establecido el bloque process, sino tendríamos que utilizar la variable $_ para cada uno de los objetos que se les pasa.


HostName Ping DNS
-------- ---- ---
SERVIDOR OK   {127.0.0.1, 8.8.8.8}
CLIENTE2 OK   {172.16.0.3, 8.8.8.8}
ASIR     NOK
UBUNTU1  NOK
ASIRL... NOK



```

5. Modifica el anterior script con el nombre scriptSetDNSConfig.ps1. Con el objetivo de asignar DNS a las interfaces con la opción `SetDNSServerSearchOrder($DNSList)`.Donde `$DNSList` es un parámetro que por defecto no es obligatorio por defecto y que tenga unos valores por defecto como `[String[]]$DNSList = @('192.168.0.30', '192.168.0.40')`. Tendrás que determinar si se ha actualizado las DNS o no.

El resultado debe ser el siguiente:

```PowerShell title="Salida"

 Get-DNSConfiguration -ComputerName cliente2
HostName  Ping DNS
-------- ---- ---
CLIENTE2 OK {192.168.1.30, 192.168.1.40}

```

6. Crea el siguiente script `scriptNewUser.ps1`. Con el objetivo que en un controlador de dominio con el Rol de Active Directory creemos todos los usuarios desde un listado en un fichero CSV. Para realizar esto deberemos tener un fichero de la siguiente manera:

```PowerShell title="Formato de fichero con ; de separador"

Name;SAMAccountName;givenName;surname;Description;profilePath;scriptPath;
Perez;Perez;Eduardo;Pérez;Cuenta de usuario;;login.vbs;L:;\\srvfic1\users
Larea;Larea;Pedro;Larea;Cuenta de usuario;;login.vbs;L:;\\srvfic1\users
Gonzalo;Gonzalo;Juan;Gonzalo;Cuenta de usuario;;login.vbs;L:;\\srvfic1\users
Arellano;Arellano;Marcelo;Arellano;Cuenta de usuario;;login.vbs;L:;\\srvfic1\
users
Navarro;Navarro;Jorge;Navarro;Cuenta de usuario;;login.vbs;L:;\\srvfic1\users

```

    Este fichero tendrás que importarlo con el comando `Import-Csv` y posteriormente pasar los datos al comando `New-ADUser`. **Cada columna del fichero será una opción del comando anterior.**
    Utiliza los datos que te he dado pero tendrás que incluir un password para cada uno de ellos, además establecer que no expira nunca la contraseña.También, éstos tendrán que estar en una OU del dominio que hayáis hecho.
