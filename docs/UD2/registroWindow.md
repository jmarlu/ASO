# Registro del sistema en Microsoft Windows

En la familia de Microsoft Windows, cobra especial importancia una base de datos jerárquica gestionada por el propio sistema operativo y que almacena todos los datos de configuración tanto del hardware, software como de los usuarios. Esta base de datos no es otra que el **Registro de Windows** y es una pieza fundamental en los sistemas operativos de Microsoft.

Se introdujo por primera vez con Microsoft Windows 3.1 con el propósito de guardar información basados en COM (Component Object Mode de Microsoft). A partir de Microsoft Windows 95 se ampliaron las características almacenadas en el registro, pauta que se siguió versión tras versión hasta la actualidad. Antes de su existencia, la configuración del software se almacenaba en ficheros de configuración INI (Windows Initialization File) contenidos en la carpeta de usuario. En un ambiente multiusuario toda la información de la configuración del software estaba repartida en demasiados archivos de este tipo. La búsqueda de un dato se realiza de forma más rápida en un ambiente estructurado y no recorriendo el disco en busca de los ficheros INI.

Esta base de datos jerárquica está compuesta por dos elementos básicos:

- **claves**, contenedores de valores que tienen un comportamiento similar a las carpetas, que a su vez pueden contener subclaves. Los nombres de esta claves no pueden contener barras, caracteres especiales y no distinguen entre mayúsculas y minúsculas.
- **valores**, el contenido de cada una de las claves. Este contenido es fuertemente tipado y debe pertenecer a alguno de estos tipos de datos:

      - **REG_BINARY**, contiene datos binarios
      - **REG_DWORD**, número entero positivo de 32 bits
      - **REG_LINK**, enlace simbólico a otra clave de registro
      - **REG_MULTI_SZ**, valor de cadena múltiple (lista ordenada de cadenas)
      - **REG_SZ**, cadena de texto en formato UTF-16
      - **REG_NONE**, datos sin ningún tipado

El registro se divide en varias secciones lógicas o **árboles** cada una destinada a contener la información específica de un área del equipo. De esta forma, si es necesario la obtención de un dato de configuración del software, no buscará en la rama de usuario, ni en la de hardware. Esta distinción en ramas limita el espectro de búsqueda y lo hace más óptimo. Actualmente son seis las claves del registro:

- **HKEY_LOCAL_MACHINE (HKLM)**, almacena configuraciones específicas del equipo local. Este árbol se almacena en memoria principal al arrancar el sistema y es allí donde se modifica la información. Durante el proceso de apagado, esta información se escribe en memoria no volátil.
- **HKEY_CLASSES_ROOT (HKCR)**, contiene la información sobre aplicaciones, asociaciones de archivos e identificadores de clases de objetos OLE (Object Linking and Embedding).
- **HKEY_USERS (HKU)**, alberga la información de todos los perfiles de usuario locales presentes en el sistema.
- **HKEY_CURRENT_USER (HKCU)**, posee la información referida al usuario con la sesión iniciada en estos momentos. En los sistemas NT (New Technology) de Microsoft, esta información se copia en los ficheros NTUSER.DAT y USRCLASS.DAT, y se ubica en la carpeta personal de cada usuario. Si los perfiles se han configurado como móviles, esta información viaja al equipo en el que se inicie sesión.
- **HKEY_PERFONMANCE_DATA**, este árbol no aparece en el registro, aunque puede ser accedida a través de la API (Application Programming Interface) de Windows. Esta clave proporciona información en tiempo de ejecución del rendimiento del sistema. Los datos son proporcionados por el kernel, controladores, programas y servicios en funcionamiento.
- **HKEY_DYN_DATA**, clave que tan sólo está presente en los sistemas de Microsoft Windows 95, Microsoft Windows 98 y Microsoft Windows ME. Contiene información sobre los dispositivos de hardware y de red. Esta rama no se guarda en el registro ya que es creada en tiempo real y destruida cuando se apaga el ordenador. Durante su existencia se almacena en la memoria principal.

Prácticamente cualquier configuración se guarda en este registro y es modificable a través del programa **RegEdit.exe**, una herramienta que permite explorar, importar y modificar los valores del registro. Es necesario prestar especial atención a esta herramienta, ya que los cambios se producen sin solicitar confirmación y de forma persistente, lo que puede conducir a errores irreversibles. Es altamente recomendable realizar una copia del registro antes de proceder a su modificación.

Existen dos formas de edición del registro:

• **manual**, a través de la aplicación **RegEdit.exe**, que mostrará la base de datos jerarquizada a través de la cual se podrá navegar hasta la clave necesaria para modificar allí su valor.
• **automática**, a través de ficheros de configuración con extensión reg. Estos archivos contienen texto con una estructura específica que permite añadir o eliminar datos en el registro:

```Powershell title=""
versiónEditorRegistro
línea en blanco
[rutaRegistro1]
"nombreDato1"="tipoDatos1:valorDatos1"
"nombreDato2"="tipoDatos2:valorDatos2"
línea en blanco
[rutaRegistro2]
"nombreDato3"="tipoDatos3:valorDatos3"
```

En donde:

- **versiónEditorRegistro**, indica la versión del editor a utilizar. A partir de Microsoft Windows Server 2003 y Microsoft Windows XP se utiliza la versión 5.0, por lo que será conveniente especificar siempre esta versión.
- **rutaRegistro**, es la ruta de la clave que se va a importar al registro. Se escribe entre corchetes y utilizando la barra inversa para separar los niveles de jerarquía.
- **nombreDato**, nombre del dato que se necesita modificar. Si esta entrada existe en el registro se modifica su valor, en caso contrario se crea una nueva entrada con los datos proporcionados.
- **tipoDatos**, el tipo de dato del valor que se introducirá en la entrada. Es necesario recordar que el registro es una base de datos fuertemente tipada, por lo que es necesario indicar siempre el tipo de dato.
- **valorDato**, el valor que se introduce en el registro. Huelga decir que sebe ser un valor compatible con el tipo de dato especificado en tipoDato.

Para ilustrar el funcionamiento de estos ficheros, se creará un registro que añada los datos de una aplicación en todos los ordenadores del sistema informático. Para realizar esta tarea la opción más práctica es crear un fichero REG que se ejecutará en cada uno de los ordenadores. Con posterioridad descubriremos que un SOR permite realizar esta tarea de una forma infinitamente más práctica.

El fichero REG será el siguiente:

```Powershell title="El fichero REG"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\software\MiAplicacion]
"Titulo"="Mi Aplicación v 1.0"
"VersionInicial"=dword:00001024

```

Si se ejecuta este fichero, se añadirá una nueva clave denominada **MiAplicacion** que contendrá dos registros (Titulo y VersionInicial) con los valores de cada uno de ellos. Nótese que los valores del tipo REG-SZ se introducen sin tipo de datos, pero siempre entre comillas dobles. Además, el fichero de registro debe terminar siempre con una línea en blanco.

A través de los archivos REG también existe la posibilidad de eliminar claves o valores. Si se elimina una clave del registro, ésta desaparecerá del árbol al que pertenece. Sin embargo, si se elimina un valor, la clave a la que pertenece ese valor continuará existiendo. Para eliminar elementos del registro es necesario colocar un guion en lugar del valor que se requiere suprimir y si se trata de una clave, anteponer este guion a la ruta de la clave.

```Powershell title="El fichero REG"
"Titulo"=-
"VersionInicial"=-
```

Si se ejecuta este fichero REG, eliminará los valores de **Titulo y VersionInicial**, pero mantendrá las claves en el registro.

```Powershell title="El fichero REG"
[-HKEY_CURRENT_USER\software\MiAplicación]
```

En esta ocasión se quita la clave entera MiAplicacion, por lo que desaparecerán tanto las claves que la contienen como sus valores.

Esta alteración del registro también se puede realizar desde el terminal de comandos facilitando la automatización de estas modificaciones. Para ello se utiliza el comando REG, que permite la adición, eliminación, consulta, copia, restauración y exportación de contenido del registro. Se puede obtener toda la información de este comando a través de su ayuda en el terminal:

```Powershell title="Ejemplo del comando reg"
reg /?
```

Si lo que se pretende es añadir información al registro se usará la opción reg add del comando de la siguiente manera:

```Powershell title="Ejemplo del comando reg"
reg add Clave /v NombreValor /t TipoDato /d Dato

```

Así, se podría introducir la información del ejemplo anterior del siguiente modo:

```Powershell title="Ejemplo del comando reg"
reg add hkcu\software\MiAplicacion /v Titulo /t REG_SZ /d “Mi aplicación v 1.0”
```

Y la segunda clave:

```Powershell title="Ejemplo del comando reg"
reg add hkcu\software\MiAplicacion /v VersionInicial /t REG_DWORD /d 1024
```

Para acortar la ruta de acceso a la clase, es posible utilizar las abreviaturas de los árboles para simplificar los comandos. Así `hkcu` correspondería con el árbol HKEY_CURRENT_USER.

Si se requiere borrar una entrada, se utilizará la opción reg delete de la siguiente manera:
reg delete hkcu\software\MiAplicacion /v

Para conocer lo que es capaz de realizar este comando, así como todas sus opciones, es buena idea consultar su ayuda en el terminal. Aunque parezca una forma un tanto incómoda de editar el registro, en los sucesivo se trabajará con scripts Powershell que se pueden programar para realizar este tipo de configuraciones de forma aromatizada, la cual ahorrará mucho tiempo y trabajo.
