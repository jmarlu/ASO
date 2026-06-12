---
search:
  exclude: true
---
# Mock exam extraordinaria UD1 + UD2 (2 horas)

## Contexto de la prueba

Este simulacro prepara la prueba extraordinaria de `UD1` y `UD2`.

- `UD1`: scripts en `bash`, argumentos, validaciones, condicionales,
  bucles, `case`, lectura de ficheros y generacion de evidencias.
- `UD2`: contenedores LXD/LXC, instalacion y consulta de paquetes,
  gestion de servicios con `systemd`, procesos, senales, prioridades,
  `cron` y `systemd timers`.

La prueba se realiza sobre un unico contenedor Ubuntu. La Parte 1 se hace en
el host. Las Partes 2 a 5 se hacen solo dentro del contenedor.

Material permitido para practicar: `man`, `--help`, apuntes de clase y el
material de `docs/UD1` y `docs/UD2`.

## Organizacion y entrega

Dentro del contenedor crea la carpeta `~/mock_extra_ud1_ud2/` con esta
estructura:

- `~/mock_extra_ud1_ud2/scripts/`
- `~/mock_extra_ud1_ud2/resultados/`
- `~/mock_extra_ud1_ud2/datos/`
- `~/mock_extra_ud1_ud2/cron/`

Guarda en esa carpeta todos los scripts, evidencias y ficheros pedidos.


## Parte 1 - Preparacion del laboratorio LXD/LXC (1 punto)

1. Crea un contenedor Ubuntu 24.04 llamado `mock-extra-ud1ud2`.
2. Configura antes del primer arranque:
   - un limite de memoria de `640MB`;
   - un limite de CPU de `1`;
   - arranque automatico del contenedor.
3. Arranca el contenedor y comprueba su estado e IP.
4. Entra en el contenedor y crea la estructura de carpetas pedida.
5. Guarda en `~/mock_extra_ud1_ud2/resultados/lxc.txt` evidencias de:
   - creacion y arranque del contenedor;
   - informacion general del contenedor;
   - configuracion de memoria;
   - configuracion de CPU;
   - configuracion de arranque automatico;
   - direccion IP asignada;
   - perfiles aplicados al contenedor.
6. Crea un snapshot llamado `inicio-mock`.
7. Realiza dentro del contenedor las Partes 2 a 5.

## Parte 2 - Datos y scripting en bash (5 puntos)

1. Crea `~/mock_extra_ud1_ud2/datos/nodos.txt` con este contenido:

   ```text
   # ip nombre rol disco ram estado puerto
   10.20.0.11 web-a web 14 4 activo 80
   10.20.0.12 web-b web 28 2 mantenimiento 8080
   10.20.0.13 db-a datos 45 8 activo 3306
   10.20.0.14 backup-a copias 18 1 caido 873
   10.20.0.15 cache-a cache xx 16 activo 6379
   10.20.0.16 monitor-a monitor 30 yy activo 9090
   10.20.0.17 proxy-a red 22 4 activo ochenta
   10.20.0.18 dns-a red 9 2 activo 53
   10.20.0.19 app-a app 35 6 degradado 9000
   ```

2. Crea el script
   `~/mock_extra_ud1_ud2/scripts/revision_nodos.sh`.
3. El script debe cumplir todo lo siguiente:
   - estar hecho en `bash` y tener permisos de ejecucion;
   - incluir comentarios breves en las partes principales;
   - recibir exactamente tres argumentos:
     `umbral_disco`, `umbral_ram` y `estado_correcto`;
   - validar el numero de argumentos;
   - validar que `umbral_disco` y `umbral_ram` son enteros;
   - validar que `estado_correcto` no esta vacio;
   - validar que existe `~/mock_extra_ud1_ud2/datos/nodos.txt`;
   - ignorar lineas vacias o que empiecen por `#`;
   - validar que cada linea util tiene exactamente 7 campos;
   - si una linea no tiene el formato correcto, mostrar:
     `ERROR FORMATO: linea <n>`;
   - si `disco`, `ram` o `puerto` no son enteros, mostrar:
     `ERROR DATOS: <nombre> (<ip>)`;
   - si `disco` es menor que `umbral_disco`, mostrar:
     `DISCO CRITICO: <nombre> (<ip>) -> <disco>GB`;
   - si `ram` es menor que `umbral_ram`, mostrar:
     `RAM CRITICA: <nombre> (<ip>) -> <ram>GB`;
   - si `estado` no coincide con `estado_correcto`, mostrar:
     `ESTADO REVISAR: <nombre> -> <estado>`;
   - clasificar cada nodo valido en uno de estos grupos usando `case`:
     `frontend`, `backend`, `infraestructura`, `monitorizacion` u `otros`;
   - generar `~/mock_extra_ud1_ud2/resultados/resumen_nodos.csv`
     con cabecera y este formato:
     `ip,nombre,rol,disco,ram,puerto,tipo,estado`;
   - identificar el nodo valido con menor disco;
   - identificar el nodo valido con menor RAM;
   - al final mostrar:
     `Resumen: <n_validos> validos, <n_formato> formato, <n_datos> datos, <n_disco> disco, <n_ram> ram, <n_estado> estado`
   - despues del resumen mostrar:
     `Minimo disco: <nombre> (<ip>) -> <disco>GB`
   - despues mostrar:
     `Minima RAM: <nombre> (<ip>) -> <ram>GB`
4. Ejecuta el script con argumentos `20 4 activo` y guarda la salida en
   `~/mock_extra_ud1_ud2/resultados/revision_20_4.txt`.
5. Ejecuta el script con argumentos `30 8 activo` y guarda la salida en
   `~/mock_extra_ud1_ud2/resultados/revision_30_8.txt`.
6. Ejecuta el script con argumentos incorrectos para demostrar la validacion
   y guarda la salida en
   `~/mock_extra_ud1_ud2/resultados/revision_error_argumentos.txt`.
7. Guarda una copia del contenido del script en
   `~/mock_extra_ud1_ud2/resultados/revision_script.txt`.

## Parte 3 - Paqueteria y servicios (2 puntos)

1. Actualiza el indice de paquetes.
2. Instala `nginx`, `curl`, `htop` y `tree`.
3. Personaliza `/var/www/html/index.html` para que aparezca:
   - el texto `Mock extraordinaria UD1 UD2`;
   - el hostname del contenedor;
   - la fecha actual generada por un comando;
   - el nombre del usuario que ejecuta la practica.
4. Guarda en `~/mock_extra_ud1_ud2/resultados/servicios.txt`:
   - evidencias de actualizacion e instalacion;
   - paquetes actualizables antes o despues de actualizar el indice;
   - un listado de paquetes instalados relacionados con `nginx`, `curl`,
     `htop` y `tree`;
   - informacion de busqueda de `nginx`;
   - dependencias de `nginx`;
   - informacion basica del paquete `curl`;
   - a que paquete pertenece `/bin/bash`;
   - un listado de ficheros relevantes del paquete `nginx`;
   - el estado del servicio `nginx`;
   - los ultimos 20 registros del servicio `nginx`;
   - la comprobacion de que `nginx` esta escuchando en red;
   - el objetivo por defecto del sistema;
   - el estado de las unidades `nginx` y `cron`;
   - la comprobacion de acceso local a la web del contenedor con `curl`.
5. Deshabilita el arranque automatico de `nginx`.
6. Deten y arranca manualmente `nginx`.
7. Guarda tambien en el mismo fichero:
   - la evidencia del nuevo estado de habilitacion de `nginx`;
   - una nueva comprobacion del estado del servicio;
   - una nueva comprobacion de escucha en red;
   - una nueva comprobacion de acceso local a la web.

## Parte 4 - Procesos y tareas programadas (1 punto)

1. Lanza `sleep 450`, `sleep 750` y `sleep 1050` en segundo plano.
2. Guarda en `~/mock_extra_ud1_ud2/resultados/procesos.txt`:
   - los PID de los tres procesos;
   - la relacion de trabajos en segundo plano;
   - una lista de procesos donde aparezcan los tres `sleep`;
   - la relacion de senales disponibles;
   - la evidencia del cambio de niceness del `sleep 450` a `+7`;
   - la comprobacion de la nueva prioridad del `sleep 450`;
   - la comprobacion de que `sleep 750` ha terminado tras enviar `SIGTERM`;
   - la comprobacion de que `sleep 1050` ha terminado tras enviar `SIGKILL`;
   - la comprobacion final de que no quedan procesos `sleep` lanzados para la
     prueba.
3. Crea una tarea programada del usuario actual que cada 12 minutos anada la
   fecha a `~/mock_extra_ud1_ud2/cron/fechas.log`.
4. Anade una segunda tarea programada que al minuto `7` de cada hora anada
   `uptime` a `~/mock_extra_ud1_ud2/cron/carga.log`.
5. Anade una tercera tarea programada que de lunes a viernes a las `18:45`
   anada el hostname a `~/mock_extra_ud1_ud2/cron/host.log`.
6. Guarda el contenido final de la programacion en
   `~/mock_extra_ud1_ud2/cron/crontab.txt`.

## Parte 5 - Systemd timer y empaquetado final (1 punto)

1. Crea `/etc/systemd/system/informe-mock.service` para que anada `date`,
   `hostname`, `whoami` y `uptime` a
   `~/mock_extra_ud1_ud2/cron/informe.log`.
2. Crea `/etc/systemd/system/informe-mock.timer` para ejecutar ese servicio
   cada 45 minutos usando `OnCalendar` y `Persistent=true`.
3. Recarga la configuracion de `systemd`.
4. Habilita y arranca el timer.
5. Ejecuta manualmente una vez `informe-mock.service`.
6. Copia `informe-mock.service` y `informe-mock.timer` a
   `~/mock_extra_ud1_ud2/cron/`.
7. Guarda en `~/mock_extra_ud1_ud2/resultados/timer.txt`:
   - el estado actual del timer;
   - la evidencia de su siguiente ejecucion programada;
   - los registros recientes del servicio asociado;
   - el contenido efectivo del servicio con `systemctl cat`;
   - el contenido actual de `~/mock_extra_ud1_ud2/cron/informe.log`.
8. Genera `~/mock_extra_ud1_ud2_entrega.tar.gz` y preparalo para su descarga
   desde el host.

## Puntuacion detallada (sobre 10)

### Parte 1 - 1 punto

- `0,20`: creacion correcta del contenedor y arranque posterior.
- `0,25`: configuracion correcta de memoria, CPU y autostart.
- `0,25`: estructura de carpetas y evidencias guardadas en `lxc.txt`.
- `0,15`: IP, estado y perfiles del contenedor comprobados.
- `0,15`: snapshot `inicio-mock` creado correctamente.

### Parte 2 - 5 puntos

- `0,50`: fichero `nodos.txt` creado correctamente.
- `0,75`: validacion de argumentos y existencia del fichero.
- `0,50`: lectura correcta del fichero ignorando comentarios y vacios.
- `0,75`: deteccion de errores de formato y de datos.
- `0,75`: alertas correctas de disco, RAM y estado.
- `0,50`: clasificacion correcta con `case`.
- `0,50`: generacion correcta de `resumen_nodos.csv`.
- `0,50`: calculo de minimo disco, minima RAM y resumen final.
- `0,25`: permisos de ejecucion, comentarios y organizacion del script.

### Parte 3 - 2 puntos

- `0,40`: actualizacion e instalacion de paquetes.
- `0,40`: personalizacion funcional de `index.html`.
- `0,50`: evidencias completas de paqueteria y consulta de informacion.
- `0,40`: comprobacion, logs, red y gestion manual de `nginx`.
- `0,30`: estado de unidades, objetivo por defecto y verificacion con `curl`.

### Parte 4 - 1 punto

- `0,50`: gestion correcta de procesos, prioridades y senales.
- `0,50`: tareas programadas correctas y `crontab.txt` guardado.

### Parte 5 - 1 punto

- `0,50`: `service` y `timer` correctos, habilitados y arrancados.
- `0,30`: evidencias del timer, logs y contenido efectivo del servicio.
- `0,20`: empaquetado final correcto.

## Criterios generales de correccion

- La estructura de entrega debe coincidir con la pedida.
- Los ficheros deben estar en las rutas indicadas. Si no, no se corregiran.
- Se valorara la claridad del script, el uso correcto de permisos y la
  organizacion de las evidencias.
- Los comandos deben ser funcionales dentro del contenedor y coherentes con el
  trabajo realizado.
- En los scripts se penalizaran rutas incorrectas, ausencia de validaciones y
  mensajes de salida distintos a los solicitados.
- Las evidencias deben mostrar comandos y salidas, no solo texto descriptivo.

