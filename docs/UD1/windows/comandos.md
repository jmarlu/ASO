#comandos

## Estructura de comandos\.

Los comandos incluidas en PowerShell reciben el nombre de **cmdlets (command-let)** y posee conjuntos específicos para trabajar con _Active Directory, Exchange_, cada uno de ellos se denominarán **módulos**.

Los nombres de todos los **cmdlets** están formados por un verbo, un guion y un nombre en singular. Habitualmente, se escribe con mayúsculas la primera letra de cada palabra, pero no se trata más que de una norma de estilo, porque \*_PowerShell no distingue entre mayúsculas y minúsculas._

Una característica de PowerShell es que se dispone de la mayoría de comandos que del CLI tradicional de Microsoft. De ese modo, es posible ejecutar el comando `dir` en lugar del `Get-ChildItem`, cmdlet que realiza la misma tarea. En realidad lo que está usando es un alias del segundo para lanzar el primero.

Dispone de **auto-completado** de comandos y parámetros que facilitará las tareas de creación de scripts. Basta con comenzar a escribir un cmdlet y pulsarla tecla Tab. Como hemos visto en Linux

Si utilizamos **PowerShell ISE** al escribir aparecerá una ventana con todos los cmdlets que coincidan con el texto escrito, incluso puede aparecer un recuadro con ayuda sobre su sintaxis. Para aceptar la sugerencia se pulsa la tecla Intro.

## Ayuda sobre los comandos

Para solicitar ayuda acerca de un comando, puede hacerlo de distintas maneras:

- Get-Help miComando
- HelpmiComando
- miComando-?

## Get-Command

Si no sabemos que comandos disponemos. `Get-command` permite descubrir todos los comandos PowerShell.

```PowerShell title=""
PS /home/julio> Get-Command -CommandType cmdlet 

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Cmdlet          Add-Content                                        7.0.0.0    Microsoft.PowerShell.Management
Cmdlet          Add-History                                        7.0.3.0    Microsoft.PowerShell.Core
Cmdlet          Add-Member                                         7.0.0.0    Microsoft.PowerShell.Utility
Cmdlet          Add-Type                                           7.0.0.0    Microsoft.PowerShell.Utility
Cmdlet          Clear-Content                                      7.0.0.0    Microsoft.PowerShell.Management
Cmdlet          Clear-History                                      7.0.3.0    Microsoft.PowerShell.Core

```

El parámetro `-CommandType` seguido del tipo de comando elegido, cmdlet. Pero podemos elegir otros tipos como alias , funciones etc..

Otra opción importante es `-verb` permite conocer todos los comandos que empiezan por un verbo concreto.

## Objetos

No voy desarrollar la programación orientada a objetos. Pero hay que entender que es un objeto. Porque en todos lo elementos en PowerShell son objetos.

Por ejemplo mi coche es un objeto que dispone de propiedades y métodos. Las propiedades pueden ser:

- Marca,
- Modelo,
- Cilindrada,
- Potencia,
- Color,
- Peso,

Pero ¿qué **acciones (métodos)** podemos realizar con nuestra moto?
Pues entre otras cosas, podemos:

- Arrancar/parar el motor,
- Acelerar/frenar,

Pero como podemos utilizar o recuperar esa informaticón. Por ejmplo, en un objeto llamado «miCoche», para recuperar el color usaremos la sintaxis siguiente:

```PowerShell title=""

PS > $miMoto.color
```

Y para arrancar «miCoche», la sintaxis que sigue:

```PowerShell title=""

PS > $miMoto.arrancar()
```

## Get-Member

Devuelve todas las propiedades y métodos de un **objeto** así como su tipo.

```PowerShell title="Obtención de tipo "
PS /home/julio> $result = Get-ChildItem /
PS /home/julio> $result | Get-Member


   TypeName: System.IO.DirectoryInfo

Name                      MemberType     Definition
----                      ----------     ----------
LinkType                  CodeProperty   System.String LinkType{get=GetLinkType;}
Mode                      CodeProperty   System.String Mode{get=Mode;}
ModeWithoutHardLink       CodeProperty   System.String ModeWithoutHardLink{get=ModeWithoutHardLink;}
Target                    CodeProperty   System.String Target{get=GetTarget;}

....

TypeName: System.IO.FileInfo

Name                      MemberType     Definition
----                      ----------     ----------
LinkType                  CodeProperty   System.String LinkType{get=GetLinkType;}
...
## Podemos ver que es miembro de dos tipos.
## Además, podemos utilizarlo de la siguiente manera en la que podemos sacar los nombres.

PS /home/julio> $result.Name
bin
boot

```

Pero si lo ejecutamos de la siguiente forma:

```PowerShell title=""
 PS /home/julio> Get-Member -InputObject $result

   TypeName: System.Object[]

Name           MemberType            Definition
----           ----------            ----------
Add            Method                int IList.Add(System.Object value)
Address        Method                System.Object&, System.Private.CoreLib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e Address(int )
```

Nos está indicando que esta compuesto de un array de objetos.

!!! note title=¿Qué es un array(vector)?

    Pues, a una zona de almacenamiento contiguo que contiene una serie de elementos del mismo tipo, en este caso otros objetos de tipo ficheros o directorios.
    Esto no lo indica los [].

Ahora si vemos el siguiente ejemplo.

```PowerShell title=""
PS /home/julio/tmp/temp> $result.Length
27

```

Lo que nos está indicando es que tenemos 27 ficheros y carpetas

## Gestión de carpetas y archivos

Cuando en Linux utilizamos el comando `ls` (funciona en PowerShell) lista todos los elementos que tiene en una carpeta. También en el comando DOS/CMD `dir` podemos realizar la misma tarea.

Pero, cuando tecleamos `dir` en PowerShell, en realidad llama a un alias. El alias ejecuta el comando `Get-ChildItem`.

```PowerShell title=""
PS /home/julio> Get-Alias dir 

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Alias           dir -> Get-ChildItem

```

Vamos a poner algunos ejemplos, date cuenta que tenemos diferentes alias.

Ejemplos:

- Para mostrar los archivos ocultos, agregue al comando `Get-Childitem` el parámetro -Force.

  ```PowerShell title=""
  PS /home/julio> gci / -Force


  Directory: /
  Mode LastWriteTime Length Name

    ---

        d-r-- 16/2/2024 16:02 bin
        d-r-- 7/3/2024 10:17 boot
        d-r-- 30/11/2018 23:26 cdrom
        d-r-- 14/3/2024 10:04 dev
        d-r-- 13/3/2024 8:47 etc
        d-r-- 8/1/2024 12:02 home
  ```

- Mostrar todos los archivos con extensión texto

  ```PowerShell title=""
  PS /home/julio/Documentos/CursoBigdate/tmp/hive>  Get-ChildItem / -Include *.txt -Recurse

  ```

- Obtener el nombre de todos los archivos cuyo tamaño es superior a 32 KB.
  ```PowerShell title=""
  Get-ChildItem  / -Recurse | Where-Object {$_.Length -gt 32KB}
  ```
  - Obtener los archivos cuya fecha de última modificación sea posterior al 01(mes)/03(dia)/2023(año)

```PowerShell title=""

Get-ChildItem | Where-Object {$_.LastWriteTime -gt ’01/03/2023’}

```

Pero como nos podemos desplazar entre los directorios. Lo seguimos haciendo con el comando `cd` pero el comando verdadero se llama `Set-Location`

Ejemplo:

```PowerShell title=""
PS /home/julio> Set-Location /
PS />

```

Para la creación de una carpeta se realiza con el comando `New-item`.

Ejemplo:

```PowerShell title=""

PS /home/julio> Set-Location /
PS /> Set-Location ~
PS /home/julio> New-Item -ItemType directory -Name TempPS


    Directory: /home/julio

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           10/4/2024    12:02                TempPS

PS /home/julio>

```

En el anterior ejemplo cambiamos de localización y creamos un directorio.

En el siguiente ejemplo vamos a eliminar todos los archivos .log contenidos en la carpeta C:\Temp. Lo podemos hacer de distinta manera con o sin Pipe.

```PowerShell title=""
PS /home/julio>  Remove-Item ~/temp/*.log
PS /home/julio>

# o con tuberías.

 PS /home/julio> Get-ChildItem ~/temp/* -Include *.txt -Recurse | Remove-Item

```

En el siguiente ejemplo vamos a mover los ficheros log de una carpeta a otra.

```PowerShell title=""
PS /home/julio/temp> ls
archivo.log
PS /home/julio/temp> Move-Item *.log ../
PS /home/julio/temp>

```

Hemos movidos desde la carpeta actual todos los archivos log ha la carpeta padre.

El mismos procedimiento sería con los directorios.

Ahora vamos a renombrar el fichero log que tenemos de dos formas.

```PowerShell title=""
PS /home/julio/temp>  Rename-Item -Path archivo.log -Newname archivo.txt
PS /home/julio/temp> ls
archivo.txt
PS /home/julio/temp>
#O
Rename-Item archivo.log  archivo.txt
```

Observa las dos formas. La primera tenemos dos modificadores o opciones y en la segunda no.

Vamos a copiar archivos o carpetas.

```PowerShell title=""
PS /home/julio/temp> Copy-Item ./archivo.txt /home/julio/tmp/
# Copiamos un archivo
#Ahora vamos a copiar una estructura completa
PS /home/julio> Copy-Item -Path ./temp -Destination ./tmp -Recurse
PS /home/julio> Get-ChildItem tmp


    Directory: /home/julio/tmp

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           11/4/2024    11:18                temp
-----           11/4/2024    11:10              0 archivo.txt
-----            6/3/2024    17:39            237 equipos.txt

PS /home/julio> sl ./tmp/temp/
PS /home/julio/tmp/temp> dir


    Directory: /home/julio/tmp/temp

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           11/4/2024    11:18                casa
-----           11/4/2024    11:10              0 archivo.txt



```


