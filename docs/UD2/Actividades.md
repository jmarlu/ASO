# Actividades de la UD2

## Actividad 1

1. Accede a Aules y realiza _RELACIÓN 3-I de ejercicios sobre tareas y procesos_.
2. Accede a Aules y realiza _RELACIÓN 3-II de ejercicios sobre instalación_.
3. Accede a Aules y realiza _RELACIÓN 3-III de ejercicios sobre servicios_

## Actividad 2

1.  Ahora a instalar el programa **Wine** (Wine Is Not a Emulator). Se trata de un
    emulador que permitirá la ejecución de software diseñado para Microsoft
    Windows en GNU/Linux. Para ello deberemos incluir una nueva fuente de datos
    (repositorio). El nombre del repositorio lo encontraremos en su página web
    oficial, y es el siguiente: **ppa:wine/wine-builds**
    ¿Cómo puedo consultar los repositorios de los que dispongo?. ¿Cómo puedo eliminar el repositorio de Wine de mi lista?.

2.  Deshabilita los siguientes servicios en Microsoft Windows10 Professional:

    - servicio Informe de errores de Microsoft Windows
    - servicio de seguimiento de diagnósticos
    - servicio Asistente para la compatibilidad de programas
    - registro remoto
    - servicios de Geolocalización
    - administrador de mapas descargados

    Comprueba que los servicios no se arrancan una vez reiniciado el sistema haciendo capturas de los servicios modificados.

3.  Crea un contenedor de ubuntu LXC e instala ngix desde los repositorios ¿Cuál el nombre del servicio?. El servidor web se inicia durante el inicio del sistema de forma predeterminada y escucha en el puerto 80. Cambie la configuración de `systemd` para este servicio para que no se inicie automáticamente durante el inicio del sistema. Reinicie el sistema y verifique que el servidor web no se haya iniciado

4.  En los sistemas operativos cliente, tanto con sistema operativo **GNU/Linux como Microsoft Windows**, programa la ejecución de un comando (con crontab) que realice una copia de los ficheros situados en la carpetas Datos, situada en la primera partición del disco, a Respaldo, situada en la segunda (deberás usar el comando `copy` y `cp`). Por ejemplo, la carpetas **C:\Datos** se copiará a la carpeta **D:\Respaldo**. Recuerda que en GNU/Linux se deberá montar estos volúmenes antes de hacer la copia (edita el fichero /etc/fstab para que se haga de forma automática si no lo hiciste). La tarea será programada para realizarse **cada hora** y con el usuario de mayores privilegios en el sistema. _Recuerda que estos sistemas no tenían ninguna partición_
5.  En el sistema operativo cliente de linux, crea un directorio en el directorio personal que se llama `copia de seguridad`. Ahora tienes que crear con `systemd` una copia de seguridad de los archivos contenidos en `/var/log` que se agreguen a al archivo backup.tar.gz todos los días (puede elegir la hora a la que esto ocurre diariamente). El archivo backup.tar.gz esta creado con el comando `tar`. Este comando empaqueta (tar) y comprime (gz) , busca ayuda en el manual.
6.  Accede a las máquinas virtuales que contienen los sistemas operativos de red y configura las actualizaciones para que se realicen de forma desatendida (tan sólo las actualizaciones de seguridad). Recuerda que en **Ubuntu Server** será necesario la instalación de paquetes adicionales.

7.  Configura las entradas de registro de Microsoft Windows 10 Professional de este modo (recuerda realizar
    capturas de pantalla antes y después del cambio):

    - deshabilita las notificaciones del Control de Cuentas de Usuario.
    - agrega el programa notepad.exe al inicio de **Microsoft Windows**.
    - cambiar la ubicación predeterminada de las carpetas especiales en **Microsoft Windows** a la partición del disco duro donde no esté instalado el sistema operativo (recuerda que durante el proceso de instalación se crearon varias particiones en el disco).
    - deshabilitar los dispositivos USB. Es una buena práctica de seguridad.

    comprueba que los cambios han surtido efecto.

## ACTIVIDADES 3. De refuerzo

1.  Accede a Moodle y descarga en el escritorio de una máquina cliente con Ubuntu Desktop la versión rpm de Mozilla Firefox. Ahora deberás convertirla a un paquete deb con la aplicación Alien. pare ello, sigue estos pasos:

    - abre un terminal y accede al escritorio. Escribe el siguiente comando:
      `sudo alien -d nombre_del_paquete.rpm`
      ¿Por qué es necesario realizar esta conversión entre el formato de paquetes?
    - una vez convertido, utiliza Alien para instalar el paquete con el comando:
      `sudo alien -i nombre_del_paquete.deb`
      ¿Es posible instalar este paquete de alguna otra forma?. ¿Cuáles?.

2.  Utiliza el script que encontrarás en Moodle para realizar esta tarea. Descárgalo en un cliente con Ubuntu Desktop y muévelo a la carpeta /home del usuario actual. Añade el permiso de ejecución al usuario con el comando `chmod 777 script.sh`. Una vez modificado, programa una tarea a través de los siguientes pasos:
    - Abre el fichero de configuración de programación de tareas con el comando:
      `sudo crontab -e`
    - añade al final del archivo el siguiente texto y guarda los cambios: `\* \* \* \* \* ~/Escritorio/script.sh`
    - ¿Qué significa cada uno de los asteriscos de esta configuración?. Comprueba que el script funciona.
    - modifica las líneas del fichero crontab para que esta tarea se ejecute todos los minutos de las horas comprendidas entre las 8 y las 20 de todos los días del mes en curso, sea cual sea el día de la semana

!!! note annotate "Manera de entrega de las actividades"

      Redacta una guía de los pasos a seguir para realizar esta actividad y súbela al **Moodle** del módulo.
      De tal forma que en cada uno de los pasos incluya una imagen que **verifique** que se ha realizado aquello que se pide en cada uno de los ejercicios. Como en las anteriores actividades

!!! warning

      **SOLO LAS ACTIVIDADES 1,2 SON OBLIGATORIAS.**
