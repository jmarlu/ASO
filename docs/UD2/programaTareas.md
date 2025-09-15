# Programación de tareas

En un sistema operativo existen ciertas tareas que se realizan de forma periódica y que será conveniente que se resuelvan de automáticamente para liberar al administrador de esas tareas. Se dispone de herramientas capaces de programar estas tareas y dejar al sistema operativo la ejecución de ellas.

En Microsoft Windows Server se dispone de la herramienta Programador de tareas, cuyo nombre es autodescriptivo. Se accede a ella a través del <span class="menu">Administrador de servidor</span> → <span class="menu">Herramientas</span> → <span class="menu">Programador de tareas</span>. Accediendo al menú <span class="menu">Acción</span> es posible crear una tarea a través de un asistente con la opción <span class="menu">Crear tarea básica… </span> o crear una en modo avanzado con la opción <span class="menu">Crear tarea…</span> , que será el que se analice a continuación. La ventana que se abre posee cinco pestañas:

- <span class="menu">General</span>, que permite asignar un nombre a la tarea, una descripción y bajo qué credenciales se ejecutará la tareas, es decir, con permiso de que usuario se va a ejecutar esa tarea. Habitualmente será el administrador el que programe las tareas. Una cosa que hay que tener en cuenta es marcar la opción Ejecutar tanto si el usuario inició sesión como si no ya que de no haber iniciado sesión, la tarea no se ejecutará.
- <span class="menu">Desencadenadores</span>, configura las acciones que lanzarán la tarea. Las opciones son múltiples; según una programación, al inicio de sesión, al registrarse un evento o incluso al conectarse algún usuario específico. Las opciones que muestra esta pestaña variarán en función de la opción seleccionada.
- <span class="menu">Acciones</span>, establece que acción o acciones se realizarán cuando el desencadenador se dispare. La opción más común será la de ejecutar un programa, habitualmente un script de terminal que realizará una tarea determinada. Pero también es posible ejecutar cualquier aplicación del sistema. Hay que tener en cuenta que este programa lo ejecutará el usuario especificado en la pestaña General, por lo que hay que ser sumamente cuidadosos con las tareas que se le encomienda.
- <span class="menu">Condiciones</span>, una vez especificada la acción o acciones a realizar, es posible indicar que esa tarea se ejecute en unas condiciones específicas. Normalmente suelen referirse al consumo de energía si la tarea se va a realizar de forma prolongada.
- por último, <span class="menu">Configuración</span> en donde se establecen directrices adicionales a las condiciones de la pestaña anterior, pero en esta ocasión referidas a la ejecución de la tarea.

Esta herramienta también sirve para comprobar que tareas se están ejecutando y desde cuando lo hacen, a través del menú <span class="menu">Acción</span> → <span class="menu">Mostrar</span> todas las tareas en ejecución.

En sistemas operativos GNU/Linux la programación de tareas se realiza a través del demonio `cron` que permite ejecutar tareas de forma automática. Cada minuto `cron` comprueba el listado de tareas y si debe o no ejecutar un programa de su listado. A diferencia de Microsoft Windows Server, `cron` solo lanza tareas según una programación. Éstas deben ser descritas con comandos o contenidas en **shell scripts**.

Existen al menos dos formas distintas de usar cron. La primera es a través de los directorios,

- `/etc/cron.hourly`
- `/etc/cron.daily`
- `/etc/cron.weekly`
- `/etc/cron.monthly`

en donde si se coloca un archivo tipo shellscript se ejecutará cada hora, cada día, cada semana o cada mes, dependiendo del directorio en donde se sitúe.

La segunda manera de programar tareas con cron es a través de manipular directamente el archivo `/etc/crontab`. Por defecto, este archivo tendrá este contenido:

```bash title="Fichero de configuración de cron"

SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin

# run-parts

01 \* \* \* _ root run-parts /etc/cron.hourly
02 4 _ \* _ root run-parts /etc/cron.daily
22 4 _ _ 0 root run-parts /etc/cron.weekly
42 4 1 _ \* root run-parts /etc/cron.monthly

```

En donde:

- SHELL es el shell bajo el cual se ejecuta. Si no se especifica, se tomará por defecto el indicado en la línea /etc/passwd correspondiente al usuario que esté ejecutando cron.
- PATH contiene la ruta a los directorios en los cuales buscará el comando a ejecutar. Éste es distinto al PATH global del sistema o del usuario.

Después de estas dos variables, se establecen las tareas que se van a ejecutar, cuando y quien las va a realizar. No hay límites en cuanto al número de tareas programadas, eso sí, **una por línea**. Las siete columnas de los que cada tarea está compuesto son:

| Campo       | Descripción                                                                                                                                                                                                           |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Minuto      | Establece el minuto de la hora en que la tarea será ejecutada, este valor debe oscilar entre 0 y 59.                                                                                                                  |
| Hora        | Controla la hora en la que la tarea será ejecutada, se especifica en un formato de 24 horas, los valores deben estar entre 0 y 23, 0 es medianoche.                                                                   |
| Día del Mes | Día del mes en que se va a ejecutar la tarea. Por ejemplo se indicaría 20, para ejecutar el comando el día 20 del mes.                                                                                                |
| Mes         | Mes en que el comando se ejecutará, puede ser indicado numéricamente (1-12), o por el nombre del mes en inglés, solo las tres primeras letras.                                                                        |
| Día semana  | Día en la semana en que se ejecutará el comando, puede ser numérico (0-7) o por el nombre del día en inglés, solo las tres primeras letras. Los valores 0 y 7 hacen referencia al mismo día de la semana, el domingo. |
| Usuario     | Usuario que ejecuta el comando.                                                                                                                                                                                       |
| Comando     | Comando, script o programa que se ejecuta. Este campo puede contener múltiples palabras y espacios.                                                                                                                   |

El uso de las cinco primeras columnas puede ser un tanto lioso al principio. Para aclarar conceptos se usarán algunos ejemplos.

```bash title="Ejemplos de momentos de ejecución"
1 \* \* \* _ Se ejecuta al minuto 1 de cada hora de todos los días
15 8 _ \* _ A las 8:15 de cada día
0 17 _ \* 0 A las 17:00 todos los domingos
5 \* _ Sun Cada minuto de 5:00 a 5:59 todos los domingos
45 19 1 _ _ A las 19:45 del primer día de cada mes
1 _ 20 7 _ Al minuto 1 de cada hora del 20 de julio
10 1 _ 12 1 A las 1:10 todos los lunes de diciembre
0 12 16 _ Wen Al mediodía de los días 16 de cada mes y que sea Miércoles
30 9 20 7 4 A las 9:30 del día 20 de julio y que sean jueves
30 9 20 7 _ A las 9:30 del día 20 de julio sin importar el día de la semana
20 \* \* _ 6 Al minuto 20 de cada hora de los sábados
20 _ _ 1 6 Al minuto 20 de cada hora de los sábados de enero

```

También es posible especificar listas en los campos. Las listas pueden estar expresadas en una comalista o a través de guiones. cron, de igual manera soporta incrementos en las listas, que se indican de la siguiente manera:

```bash title="Ejemplos de momentos de ejecución"
59 11 _ 1-3 1,2,3,4,5   A las 11:59 de lunes a viernes, de enero a marzo
45 _ 10-25 _ 6-7  Al minuto 45 de todas las horas de los días 10 al 25 de todos los meses del día los sábados o domingos
10,30,50 \* \* _ 1,3,5  En el minuto 10, 30 y 50 de todas las horas de los días lunes, miércoles y viernes
_/15 10-14 \* \* _  Cada quince minutos de las 10:00 a las 14:00
_ 12 1-10/2 2,8 _   Cada minuto de la hora 12 en los días 1,3,5,7 y 9 de febrero y agosto. (el incremento en el tercer campo es de 2 y comienza a partir de 1)
0 \_/5 1-10,15,20-23 \* 3 Cada 5 horas de los días 1 al 10, el día 15 y del día 20 al 23 de cada mes y que el día sea miércoles
3/3 2/4 2 2 2 Cada 3 minutos empezando por el minuto 3 (3,6,9...) de las horas 2, 6, 10, 14, 18 y 22 (cada 4 horas empezando en la hora 2) del día 2 de febrero y que sea martes
```

Como se puede apreciar en el último ejemplo la tarea cron que estuviera asignada a esta línea, sólo se ejecutaría si cumple con los cinco criterios, es decir, siempre es un AND que sólo resulta verdadero si todas las condiciones son ciertas.

## Ejecutando cron con múltiples usuarios, comando crontab

GNU/Linux es un sistema multiusuario y cron es de las aplicaciones que soporta el trabajo con varios usuarios a la vez. Cada usuario puede tener su propio archivo crontab, de hecho el /etc/crontab se asume que es el archivo del usuario root. Cualquier usuario puede disponer de su propio archivo de programación de tareas a través del comando crontab. En el directorio `/var/spool/cron/crontabs`, que puede variar según la distribución, se genera un archivo de tareas para cada usuario.

El uso de crontab es `crontab -e` este comando abrirá el editor de texto ( Editor Vi) por defecto con un archivo vacío y donde el usuario especificará las tareas que desea programar, y que se guardará automáticamente como `/var/spool/cron/crontabs/usuario.` Hay que tener en cuenta que si existe esta nueva lista de tareas programadas serán dos las que serán comprobadas en cada minuto por el demonio cron: la del usuario recién creada y la del sistema vista con anterioridad.

## Systemd timers

Los temporizadores son una forma opcional de programar tareas en el sistema operativo.
Las unidades systemd hacen posible la creación de tareas complicadas.
A continuación se muestran dos ejemplos, uno con crontab anterior y otro con systemd.
crear una tarea programada que guarde información de fecha en el archivo /tmp/date cada 10 minutos.

```bash title="Ejemplo con crontab"
*/10 **** /usr/bin/date >> /tmp/date

```

Ahora con systemd

- Creemos un archivo /etc/systemd/system/date.service con el siguiente contenido:

  ```bash title="Contenido del servicio"
  [Unit]
  Description=Guardamos la fecha en  /tmp/date
  [Service]
  Type=oneshot
  ExecStart=/usr/bin/sh -c '/usr/bin/date >> /tmp/date'
  ```

- Luego creemos un archivo de temporizador /etc/systemd/system/date.timer con el siguiente contenido

```bash title="Contenido del temporizador"
 [Unit]
Description=date.service es ejecutado cada 10 minutos

[Timer]
OnCalendar=*:0/10
```

- Inicia el temporizador con el siguiente comando:

  ```bash title="Comando para iniciar el temporizador"
  systemctl start date.timer

  #listado de los temporizadores
  systemctl list-timers
  NEXT                         LEFT          LAST                         PASSED       UNIT                         ACTIVATES
  Wed 2023-10-04 12:36:26 CEST 8min left     Tue 2023-10-03 11:48:10 CEST 24h ago      logrotate.timer              logrotate.service
  Wed 2023-10-04 12:36:26 CEST 8min left     Tue 2023-10-03 11:48:10 CEST 24h ago      man-db.timer                 man-db.service
  Wed 2023-10-04 12:36:26 CEST 8min left     Tue 2023-10-03 22:39:05 CEST 13h ago      phpsessionclean.timer        phpsessionclean.service
  Wed 2023-10-04 12:36:28 CEST 8min left     Tue 2023-10-03 22:30:05 CEST 13h ago      anacron.timer                anacron.service
  Wed 2023-10-04 13:32:32 CEST 1h 4min left  Tue 2023-10-03 12:16:38 CEST 24h ago      apt-daily-upgrade.timer      apt-daily-upgrade.service
  Wed 2023-10-04 16:44:22 CEST 4h 16min left Tue 2023-10-03 12:31:34 CEST 23h ago      motd-news.timer              motd-news.service
  ```
