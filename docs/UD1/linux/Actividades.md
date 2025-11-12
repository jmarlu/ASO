# Actividades de Script de Linux


## Introducción

1. **CLI personal `micomando`**
      - Crea el directorio `~/misScripts` (si no existe) y guarda allí un script llamado `micomando` con el contenido `echo "Ejecución de micomando"`.
      - Concede permisos de ejecución (`chmod u+x ~/misScripts/micomando`).
      - Añade `export PATH="$HOME/misScripts:$PATH"` al final de tu `~/.bashrc` y vuelve a cargar la sesión (`source ~/.bashrc`).
      - Comprueba que el comando funciona escribiendo `micomando` desde cualquier directorio; debe mostrar el texto del script.

2. **Saludo personalizado**
      - Crea `Script1_1.sh`, que pida por teclado el nombre completo y muestre `Que tengas un próspero día <nombre introducido>`.
      - Duplica el archivo como `Script1_1_2.sh` y modifica la lógica para solicitar nombre y apellido por separado. Muestra ambos valores en la misma frase siguiendo el ejemplo del enunciado.

3. **Creación de usuarios con variables (`Script1_2.sh`)**
      - El script debe solicitar nombre de usuario, ruta del directorio home a crear y shell predeterminado.
      - Usa `useradd -m -d <ruta> -s <shell> <usuario>` (se requiere ejecutar con privilegios de administración).
      - Muestra un mensaje de éxito o un error significativo si el usuario ya existe o si el comando falla.

4. **Comportamiento de comodines y expansión de variables**
      - Crea un directorio de pruebas con ficheros `f1`, `f2` y `f3` y sitúate en él.
      - Evalúa y explica qué muestran los siguientes comandos:

     | Comando | Pista |
     | --- | --- |
     | `echo *` | Se expande el comodín al contenido del directorio. |
     | `echo \*` | El carácter `\` evita la expansión del comodín. |
     | `echo "*"` | Las comillas dobles bloquean la expansión de comodines. |
     | `echo '\*'` | Las comillas simples imprimen el texto literal, incluido el `\`. |
     | `edad=20` | Asigna un valor a la variable `edad`. |
     | `echo $edad` | Expande la variable. |
     | `echo \$edad` | Escapa el símbolo `$` para mostrarlo literal. |
     | `echo "$edad"` | Se evalúa la variable dentro de comillas dobles. |
     | `echo '$edad'` | Con comillas simples no se expande la variable. |
     | `echo "Tú eres $(logname) y tienes -> $edad años"` | Combina sustitución de comandos y expansión de variables. |
     | `echo Tú eres $(logname) y tienes -> $edad años` | Resultado equivalente mientras no existan espacios problemáticos. |

5. **Comparaciones de cadenas**
      - Define `s1=si`, `s2=no`, `vacia=""` y `arch1=informe.pdf`.
      - Comprueba con `[[ ... ]]`:  
            a) Si `s1` es igual a `s2`.  
            b) Si `s1` es diferente de `s2`.  
            c) Si `vacia` está vacía (`-z`).  
            d) Si `vacia` no está vacía (`-n`).  
      - Anota cada resultado con un mensaje claro por pantalla.

6. **Comparaciones numéricas**
      - Declara `num1=2` y `num2=100`.
      - Verifica si `num1` es mayor que `num2` usando las tres sintaxis: `[ ]`, `[[ ]]` y `(( ))`.
      - Indica el resultado en cada caso con un mensaje descriptivo.

7. **Permisos sobre ficheros (`arch`)**
      - Crea un fichero vacío `arch` (`> arch`) y ajusta permisos a solo lectura (`chmod 444 arch`).
      - Programa un script que:  
      a) Muestre `Permiso x no indicado` si el fichero no es ejecutable.  
      b) Muestre `Permisos wx no indicados` cuando además tampoco sea escribible.

## Estructura IF

1. **Paridad de un número (`Script_IF_1.sh`)**  
   Solicita un número entero por teclado y muestra si es par o impar. Aprovecha el operador `%` para obtener el resto de la división entre 2 y valida que el dato sea realmente numérico antes de operar.

2. **Calculadora básica (`Script_IF_2.sh`)**  
   Pide dos números y el símbolo de la operación (`+`, `-`, `*`, `/`). Calcula y muestra el resultado. Controla posibles errores (operador desconocido, división por cero) antes de usar `bc -l` o aritmética integrada.

3. **Calculadora con formato (`Script_IF_3.sh`)**  
   Parte del script anterior y añade una pregunta adicional: `¿Quieres decimales (s/n)?`.  
      - Respuesta `s`: muestra el resultado con decimales.  
      - Respuesta `n`: muestra el número redondeado (usa `printf`).  
      - Cualquier otra opción debe generar el mensaje `No has seleccionado ninguna opción` y finalizar con error.

4. **Menú de utilidades de red (`Script_IF_4.sh`)**  
      - Solicita una IP o dominio.  
      - Muestra un menú con tres opciones: `ping`, `traceroute` y `whois`.  
      - Ejecuta la opción elegida validando previamente que el comando esté instalado (`command -v`).  
      - Ante una opción no válida, indica `No has seleccionado ninguna opción válida` y termina.  
      - Nota: en Debian/Ubuntu puedes instalar herramientas extra con `sudo apt install inetutils-ping traceroute whois`.

5. **Información de rutas (`Script_IF_5.sh`)**  
      - Pide una ruta absoluta.  
      - Si es un directorio, informa de ello.  
      - Si es un fichero, comprueba permisos de lectura, escritura y ejecución imprimiendo los que correspondan.  
      - Si no existe, muestra `no existe`.  
      - Recuerda que puedes anidar condicionales `if` para estructurar la lógica.

## Argumentos

1. **Propietario y permisos (`scriptArgs_2.sh`)**  
      - Debe recibir exactamente un argumento.  
      - Si no recibe ninguno o recibe más de uno, mostrar `ERROR NÚMERO DE ARGUMENTOS INCORRECTO`.  
      - Si el argumento no es un fichero regular, mostrar `EL ARGUMENTO DEBE SER UN FICHERO`.  
      - En caso correcto, obtener el propietario y los permisos de “otros” usando `stat`.

2. **Datos de usuario (`scriptArgs_3.sh`)**  
    - Recibe un único argumento: nombre de usuario.  
    - Si falta el argumento muestra `ERROR, NÚMERO DE ARGUMENTOS INCORRECTOS`.  
    - Con `getent passwd <usuario>` recupera UID y shell, y muéstralos en pantalla.

3. **Lista negra (`blacklist.sh`)**  
      - Recibe exactamente un nombre de usuario.  
      - Muestra un menú con dos opciones:  
      1. Agregar usuario a la lista y bloquearlo (`usermod -L`). Evita duplicados.  
      2. Eliminar usuario de la lista y desbloquearlo (`usermod -U`).  
      - La lista se guarda en `blacklist.txt` y debe conservarse entre ejecuciones.

## Case y While

1. **Menú interactivo de red**  
      - El script recibe una IP/dominio como argumento.  
      - Dentro de un bucle `while` ofrece las opciones: `ping`, `tracepath`, `nslookup`, `whois` y `salir`.  
      - Usa `case` para despachar cada opción y vuelve al menú salvo que el usuario elija salir.  
      - Ante opciones no contempladas muestra `OPCIÓN DESCONOCIDA`.

2. **Control de accesos con `usuarios.log`**  
      - El fichero `usuarios.log` contiene pares `usuario<TAB>contraseña`.  
      - Permite introducir usuario y contraseña con un máximo de tres intentos.  
      - Si alguno de los campos está vacío o no coincide, incrementa el contador y vuelve a pedir credenciales.  
      - Mensaje final: `Bienvenido <usuario>` si acierta; `Usuario Incorrecto` si agota los intentos. 

3. **Registro y autenticación (`CrearUsuarios.sh`)**  
      - Menú principal con opciones: `a) Log in`, `b) Registrarse`, `c) Salir`.  
      - Registro: solicita usuario, contraseña y confirmación. Si coinciden, guarda `usuario contraseña` en `cuentas.log`.  
      - Inicio de sesión: permite hasta tres intentos comprobando contra `cuentas.log`.  
      - Maneja errores (usuario existente, contraseñas distintas, opción inválida).

## For

1. **Traza de `ejemploContinue.sh`**  
      - Ejecuta `bash ./ejemploContinue.sh 3`.  
      - Completa la tabla con las columnas `Iteración`, `i`, `resto` (`i % 3`) y la acción tomada (`continue` o impresión por pantalla).  
      - Observa que solo se muestran los valores de `i` divisible por el parámetro recibido.

2. **Expiración de contraseñas (`expira.log`)**  
      - El script recibe un número de días y un fichero `expira.log` con usuarios (uno por línea).  
      - Valida el argumento, comprueba que el fichero existe y usa `chage -M <días> <usuario>` para cada entrada.  
      - Informa de usuarios inexistentes o de posibles errores de ejecución.

3. **Tablero de asteriscos**  
      - Usa obligatoriamente la sintaxis `for (( ... ))`.  
      - Recibe dos enteros positivos: número de filas y columnas.  
      - Imprime una tabla rectangular rellenando cada celda con `*` separado por espacios.

## For-in

1. **Permisos de ejecución para el grupo**  
      - Recibe un directorio como argumento.  
      - Recorre sus elementos con un bucle `for` (solo ficheros) y añade permiso de ejecución al grupo (`chmod g+x`).  
      - Al finalizar, muestra `ls -l` del directorio para comprobar los cambios.

2. **Mover o copiar por extensión**  
      - Argumentos: extensión (sin punto), directorio origen y directorio destino.  
      - Verifica que existan los directorios.  
      - Pregunta si se desea `mover` o `copiar` y realiza la operación solo con los ficheros que coincidan con la extensión.

3. **Alerta de capacidad con `equipos.txt`**  
      - El fichero contiene: IP, nombre, espacio libre y RAM (en GB) separados por espacios.  
      - El script recibe un único argumento (`capacidad mínima`).  
      - Recorre el fichero y muestra una alerta por cada equipo cuya capacidad libre sea inferior a la indicada.

4. **Creación masiva de usuarios remotos (`creaUsuarios.sh`)**  
      - Requiere que estén instalados `openssh-server`, `ssh` y `sshpass` en la máquina que ejecuta el script.  
      - Archivos de entrada: `hosts.txt` (un host por línea) y `usuarios.txt` (un usuario por línea).  
      - Para cada host:  
            - Conecta como root usando `sshpass` (solo para entornos de laboratorio).  
            - Elimina el usuario si existe (`userdel -rf`).  
            - Crea de nuevo el usuario con `useradd -m`.  
            - Recuerda que en entornos reales se recomienda autenticación por claves, contraseñas robustas y control detallado de errores.


