# Actividades de la UD9

## Introducción

1. Cree un directorio `bin` en el directorio de inicio. En `bin`, cree o recupere el programa corto siguiente (script shell que muestra una frase en la pantalla):

   ```bash title=""
   pwd
   /home/ubuntu/bin
   $ vi  micomando
   echo "Ejecución de micomando"
   $ chmod u+x micomando
   ```

   Modifique la variable PATH de forma que este comando funcione:

   ```bash title=""
   micomando
   Ejecución de micomando
   ```

2. Programa que muestre por pantalla “Bienvenido, introduce tus nombres y apellidos”. Acto seguido podremos introducir nuestro nombre y el script devolverá “Que tengas un buen día
   XXXXXXXX”. Guarda el fichero como `Script1_1.sh`.

   ```bash title=""
   $ ./Script1_1.sh
   Bienvenido, introduce tu nobre y apellidos:
   Julio Martinez
   Que tengas un prospero dia Julio Martinez
   ```

   A continuación crea el script `“Script1_1_2.sh”` en el cual por un lado de pida el nombre y por otro el apellido, para finalmente usar ambas variables en una misma frase.

   ```bash title=""
   Inserta un nombre: Julio
   Inserta un apellido: Martinez
   Bienvenido Julio, tu apellido es Martinez
   ```

3. Crea un script que solicite un nombre de usuario, una ruta del home a crear y un intérprete. Finalmente debe mostrar un mensaje indicando que el usuario se ha creado (`useradd o adduser` :smile: ).

   Es importante usar la opción que efectivamente genere la carpeta home al crear el usuario. Guarda el script como `“Script1_2.sh”`

   ```bash title=""
   Inserta un nombre de usuario: Lorenzo
   Inserta una ruta de directorio home: /home/lamas
   Elige un shell de comandos: /bin/bash
   Usuario creado correctamente.
   ```

4. Cree los f1, f2,f3 en un directorio y metase dentro de el. Ejecute y explique que hace cada uno de los siguientes comandos.

   1. `echo \*`
   2. `echo \*`
   3. `echo "\*"`
   4. `echo ’\*’`
   5. `edad=20`
   6. `echo $edad`
   7. `echo \$edad`
   8. `echo "$edad"`
   9. `echo ’$edad’`
   10. `echo "Tú eres $(logname) y tienes -> $edad años"`
   11. `echo Tú eres $(logname) y tienes -> $edad años`

5. Definir las siguientes variables:

   ```bash title=""
   s1=si
   s2=no
   vacia=""
   arch1=informe.pdf
   ```

   1. pruebe si $s1 es igual a $s2.
   2. Pruebe si $s1 es diferente de $s2.
   3. Pruebe si $vacia está vacía.
   4. Pruebe si $vacia no está vacía.

6. tests numéricos.Definir las variables num1 y num2 con los valores siguientes:

   ```bash title=""

       num1=2
       num2=100

   ```

   Verifique si $num1 es mayor que $num2 empleando los comandos [ ], [[]] y (( )).

7. Operadores lógicos de los comandos [ ], [[]] y operadores lógicos del shell
   Ejecute los comandos siguientes:

   ```bash title=""

   $ > arch
   $ chmod 444 arch
   $ ls -l arch
   -r--r--r-- 1 ubuntu ubuntu  0  2 feb  17:23 arch
   ```

   1. Si el archivo $arch no es ejecutable, muestre ”Permiso x no indicado”.
   2. Si el archivo $arch no es ni ejecutable ni accesible para escritura, muestre ”Permisos wx no indicados”.

## IF

1. Crea un script (`Script_IF_1.sh`) que solicite un número por pantalla al usuario. El script debe indicar si el número pasado es par o impar. PISTA: El símbolo “%” dentro de una ecuación matemática te devuelve el resto de una división.

2. Crea un (`Script_IF_2.sh`) que solicite al usuario que introduzca 2 números y un símbolo matemático (+,-,\* o /). El script debe devolver el resultado.

3. Copia el script anterior y a esta nueva copia llámala (`Script_IF_3.sh`). Modifícala para que una vez introducido los dos números y el símbolo el programa te pregunte si deseas que el resultado salga con decimales: “Deseas el resultado con decimales (s/n)”. En caso de que el usuario responda “s” debe mostrarlo con decimales, en caso de que diga “n” sin decimales y en cualquier otro caso debe mostrar el siguiente error “No has seleccionado ninguna opción” y termine el programa.

   ```bash title=""
   Introduce un número: 3
   Introduce un número: 4
   Introduce un signo(+,-,/,*):*
   Quieres decimales (s/n)?s
   12

    Introduce un número: 3
   Introduce un número: 4
   Introduce un signo(+,-,/,*):-
   Quieres decimales (s/n)?v
   no has seleccionado ninguna opción

    Introduce un número: 120
   Introduce un número: 7
   Introduce un signo(+,-,/,*):*
   Quieres decimales (s/n)? s
   17.142857

   ```

4. Haz un script (`Script_IF_4.sh`) que solicite al usuario una IP por pantalla. Acto seguido se mostrará un menú, dependiendo de lo que seleccione el usuario, el script hará una cosa u otra. En caso de no seleccionar ninguna de las opciones el script devolverá el siguiente error “No has seleccionado ninguna opción válida” y terminará.

A continuación se indican las opciones:

1. Realizar un ping.
   1. Ejemplo de uso: ping 8.8.8.8
2. Realizar traceroute.
   1. Ejemplo de uso: traceroute 8.8.8.8
3. Realizar comando whois.
   1. Ejemplo de uso: whois 8.8.8.8

Ejemplo:

```bash title=""
Introduzca un IP: 8.8.8.8
seleccione una opción:
1.ping
2.traceroute
3. whois
```

5. Crea el script `Script_IF_5.sh`, el cual pregunte al usuario que introduzca la ruta absoluta de un directorio o de un fichero. El script debe:

   1. Indicarte si la ruta absoluta se trata de un directorio, fichero o si no existe.
   2. En caso de tratarse de un fichero debe indicarte si tienes permisos de escritura/lectura/ejecución. En caso de no tener permisos no mostrará nada por pantalla.

   **PISTA:** Se pueden anidar (meter uno dentro de otro) varias estructuras IF.

```bash title=""
IF [ CONDICIÓN ]

Then

    IF [ CONDICIÓN ]

    THEN

        ACCIONES

    FI

FI

```

Ejemplo:

```bash title=""
Introduzca una ruta absoluta:/home/ubuntu/prueba.txt
información sobre /home/ubuntu/prueba.txt
1.Es un fichero
2.Tiene permisos de escritura
3. Tiene permisos de lectura


Introduzca una ruta absoluta:/home/ubuntu/p
información sobre /home/ubuntu/p
1. no existe
```

## Argumentos

1. Crea un script que espere un fichero como argumento. El script debe devolver quien es su usuario propietario y que permisos tienen el resto de usuarios (únicamente el resto de usuarios).

   En caso de no recibir exactamente un argumento se debe devolver “ERROR NÚMERO DE
   ARGUMENTOS INCORRECTO”.

   En caso de que el argumento proporcionado no sea un fichero o directorio se debe devolver
   un error de “EL ARGUMENTO DEBE SER UN FICHERO”.

   ```bash title=""
   ./scriptArgs_2.sh scriptArgs_2.sh
   El propietario de scriptArgs_2 es ubuntu y los permisos para el resto de los usuarios son ---

    ./scriptArgs_2.sh
    ERROR NÚMERO DE
   ARGUMENTOS INCORRECTO

   ./scriptArgs_2.sh /home
   EL ARGUMENTO DEBE SER UN FICHERO
   ```

2. Genera un script que pasado un nombre de usuario como argumento te devuelve su UID y el intérprete shell que tiene configurado.

   En caso de no recibir exactamente un argumento, el programa debe devolver “ERROR, NÚMERO DE ARGUMENTOS INCORRECTOS” y terminar.

   ```bash title=""
   ./scriptArgs_3.sh ubuntu
   el uid de ubuntu es :1000 y tiene el shell /bin/bash

   ./scriptArgs_3.sh
   ERROR, NÚMERO DE ARGUMENTOS INCORRECTOS


   ```

3. Crea un script (`blacklist.sh`) que espera como argumento el nombre de un usuario. Si no
   se pasa ningún argumento o si se pasa más de uno, el script devolverá el siguiente error “Debes pasar un nombre de usuario como argumento” y terminará.

   Una vez comprobado que efectivamente se ha pasado un único argumento el script mostrará un menú tal que así:

   ```bash title=""
         seleccione una opción
         1.Agregar usuario a blacklist
         2.Eliminar usuario de blacklist.
   ```

   Si seleccionamos la opción “1” el usuario se agregará al fichero “blacklist.txt”, es importante que dicho fichero no se debe eliminar/sobrescribir tras cada ejecución, es decir, debe almacenar todos los usuarios que vamos agregando cada vez que ejecutemos el script. Una vez añadido al fichero el usuario debe ser bloqueado (no eliminado) y mostrar el mensaje “Usuario XXXX bloqueado” siendo XXXX el nombre del usuario.

   Si se intenta bloquear un usuario que ya se encontraba en la lista se debe devolver el error “Usuario ya bloqueado con anterioridad” y finalizar la ejecución.

   Si seleccionamos la opción “2” se debe desbloquear el usuario, eliminar de la lista “blacklist.txt” y mostrar el mensaje “Usuario XXXXX desbloqueado”.

## Case & While

1.  Genera un script que recoja una dirección IP como argumento, se debe comprobar que se ha
    introducido un único argumento y si no se debe mostrar un mensaje de error. Acto seguido se mostrará al usuario 5 opciones (p`ing, tracepath, nslookup, whois y salir`). Si el usuario escoge un comando, dicho comando ha de ejecutarse y se debe mostrar el menú de nuevo. El programa no debe terminar a menos que el usuario pulse el número 5. En caso de tocar una opción inexistente el programa debe devolver un
    error “OPCIÓN DESCONOCIDA”. Para terminar un programa puedes hacer uso del comando “exit”.

2.  Dado un fichero `usuarios.log` que tenga separados por **tabuladores** los usuarios y las contraseñas, el script debe solicitar un usuario y una contraseña: 1. En caso de que el usuario o contraseña sean incorrectos se debe volver a permitir al usuario introducir las credenciales, hasta un total de 3 veces. 2. Si el usuario ha fallado 3 veces con su usuario/contraseña el programa debe finalizar indicando **“Usuario Incorrecto”**. 3. En caso de que el usuario y contraseña sean correctos indicará “Bienvenido XXX” y finalizará.

    !!!info

          Recuerda el uso del comando “tr” para sustituir los tabuladores por otro separador.

3.  Realiza un script “`CrearUsuarios.sh`” que muestre el siguiente menú y permita seleccionar una opción:

    ```bash title=""
          a. Log in.
          b. Registrarse.
          c. Salir.
    ```

    En caso de elegir “b” se solicitará un nombre de usuario y posteriormente una contraseña, la cual deberá repetir y el script comprobará que efectivamente se ha introducido la misma contraseña 2 veces.

    En caso de que las contraseñas no coincidan se mostrará el mensaje **“Contraseñas no coinciden”** y volverá a mostrar el menú. En caso de que las contraseñas coincidan se añadirá al fichero `“cuentas.log”`
    el usuario y su contraseña, separado por un espacio en blanco y finalmente mostrará el menú de nuevo:

        salva miContraseña
        pepe 1234Password
        jose 81237594

    En caso de seleccionar la opción “a” el usuario debe introducir su nombre de usuario y posteriormente su contraseña. El script debe indicar si el usuario y contraseña son válidos. En caso de serlo mostrará el mensaje de **“Bienvenido XXXX”** y el programa finalizará. En caso de no ser correcto se mostrará el mensaje “Login Incorrecto” y se volverá a mostrar el menú inicial. Además **permita hasta 3 intentos** en caso de insertar un **usuario/contraseña** incorrectos (usando bucle while o until).

    En caso de que no se seleccione “a”, “b” o “c” se debe mostrar un mensaje **“OPCIÓN INCORRECTA**” y volver a mostrar el menú.

## For

1. Dado el siguiente código, realiza una traza, completando la siguiente tabla (añade filas si necesario), como si el usuario hubiera ejecutado en el terminal: `bash ./ejemploContinue.sh`

   | Iteración | $i  | $resto | Acción |
   | --------- | --- | ------ | ------ |
   |           |     |        |        |
   |           |     |        |        |
   |           |     |        |        |
   |           |     |        |        |

   ```bash title=""
   #!/bin/bash
   echo " A continuación solo mostraremos los números divisibles (del 1 al 10)de " $1
   for (( i=1; i<= 10;i++ ))
   do
      let "resto="$i% $1"
      if [ $resto -ne 0]
      then
         #los números no divisibles no deben salir por pantalla
         #Al hacer continue no ejecutamos el echo $i
         continue
      fi
      echo $i
      done
   ```

2. Dado un fichero llamado `expira.log` que contenga en cada fila un **nombre de usuario**, se debe realizar un script que espere como argumento un número, dicho número será el número de días tras los cuales expirará la contraseña (comando `chage`).

3. **Usando OBLIGATORIAMENTE el for (( … ))**. Genera un script que pasados dos argumentos numéricos, que será el número de filas y el número de columnas respectivamente, rellene con un “\*” cada elemento de la tabla creada.

   El script debe recorrer todos los usuarios del fichero mediante un bucle for (( … )) y debe configurarlos para que su contraseña expire después de los días pasados como argumento.

### ForIn

1.  Crea un programa que añada únicamente a los ficheros (no a los directorios) permisos de ejecución a los grupos del usuario (nada más al grupo del usuario, no al usuario propietario ni al resto). El script debe hacer un ls –l al final sobre el directorio trabajado para ver los cambios.
2.  Realiza un script que reciba 3 argumentos, una extensión de fichero y dos nombres de directorios. El script deberá:

    1. Comprobar que ha recibido 3 argumentos, en caso contrario mostrará un error.
    2. Comprobar que el segundo y tercer argumento son directorios, en caso contrario mostrará un error.
    3. Posteriormente dará al usuario la opción de “mover” o “copiar”:
    4. En caso de seleccionar “mover”, se moverán todos los ficheros con dicha extensión (argumento número 1) del primer directorio (argumento número 2) al segundo directorio (argumento número 3).
    5. En caso de seleccionar “copiar” realizará lo mismo pero copiando en vez de moviendo.

3.  A partir de un fichero de texto llamado `equipos.txt` con los siguientes campos separados por espacios en blanco:

    1. IP.
    2. Nombre del Equipo.
    3. Memoria en disco libre en GBytes.
    4. Memoria RAM total en GBytes.

    El script esperará recibir un argumento que representará la capacidad de memoria en disco mínima que deba tener un equipo. Acto seguido el script mostrará una alerta de todos aquellos equipos que tienen menos de dicha capacidad disponible. Se debe de comprobar que efectivamente se ha introducido uno y solo un argumento al script.

4.  **Antes de nada instala el paquete: openssh-server.A continuación, sigue las siguientes indicaciones:**

    1.  Instala los paquetes `“ssh”, “sshpass” y “openssh-server”`. En una máquina
    2.  Arranca el servicio ssh:

        1.  `service ssh start`

    3.  Accede a la configuración del servicio`/etc/ssh/sshd_config`:
        1. Descomenta y cambia la línea“`PermitRootLogin yes`”.
        2. Esta medida está desaconsejada de cara a la seguridad informática, la hacemos únicamente para facilitar la resolución de este ejercicio.
    4.  Reinicia el servicio ssh para que surjan efectos los cambios.
        1. `service ssh restart`
    5.  Crea una contraseña para root:
        1. `sudo su`
        2. `passwd` (con esta contraseña se la tenemos que pasar a todos `sshpass`)
    6.  Crea tres clones enlazados a partir de la anterior con distinta ip y mac.
    7.  Abre las tres máquinas en terminales por separado, revisa su IP (`ip –a`) y comprueba que tienen conectividad. Posteriormente prueba a entrar al contenedor con ssh (`ssh IP`)

    Crea un script llamado **creaUsuarios.sh** que se encontrará en la máquina original. Dicho script leerá de dos ficheros. El primero es una lista de hosts (**hosts.txt**) y el segundo es una lista de usuarios (**usuarios.txt**).
    El script debe acceder a cada equipo, borrar dicho usuario junto con su contenido si existía y crearlos de nuevo.

!!! warning

      **TODAS LAS ACTIVIDADES SON OBLIGATORIAS.** Además, cuando os pidan en el ejercicio que generéis un fichero script , es el que me tenéis que subir, y cuando no lo pida tenéis que subir un fichero pdf con las capturas como siempre. Aunque haya un solo fichero es conveniente que lo subáis comprimido.
