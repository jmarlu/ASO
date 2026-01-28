---
search:
  exclude: true
---
# Examen practico UD2 (2 horas)

Contexto: Se permite usar `man` y `--help` y mis apuntes. 

Entrega: Parte 1 se realiza en el host para crear el contenedor. Partes 2 a 5
se realizan SOLO DENTRO del contenedor. En el contenedor crea la carpeta
`~/examen_ud2/` con esta estructura:
- `~/examen_ud2/scripts/`
- `~/examen_ud2/resultados/`
- `~/examen_ud2/cron/`

Guarda todos los comandos, salidas y ficheros solicitados dentro de esa carpeta.

Entrega en Aules:
1. En el contenedor, genera `~/examen_ud2_entrega.tar.gz` con la carpeta
   `~/examen_ud2/` usando:
   - `tar -czf ~/examen_ud2_entrega.tar.gz -C ~ examen_ud2`
2. Desde el host, descarga ese fichero con `lxc file pull`.
3. Sube a Aules el fichero `examen_ud2_entrega.tar.gz`.

## Parte 1 - Laboratorio en LXC (2.0 pts)

Crea un contenedor LXC y realiza dentro TODO el examen (Partes 2 a 5).
Debes demostrar que conoces el ciclo de vida basico del contenedor.

1. Lanza un contenedor Ubuntu 24.04 llamado `ud2-lab`.
2. Comprueba su estado e IP con `lxc list`.
3. Entra al contenedor y crea la carpeta `~/examen_ud2/` con la misma
   estructura solicitada en este examen.
4. Crea en `~/examen_ud2/resultados/lxc.txt` un registro con los comandos
   usados en esta parte y la salida de `lxc info ud2-lab` (copiada desde el host).
5. Realiza dentro del contenedor las Partes 2, 3, 4 y 5 completas.
6. Crea un snapshot llamado `inicio`.
7. En el host, exporta el contenedor a `~/ud2-lab.tar.gz`.

## Parte 2 - Paqueteria y actualizaciones (2.0 pts)

1. Actualiza el indice de paquetes.
2. Instala `htop` y `nginx`.
3. Guarda en `~/examen_ud2/resultados/paqueteria.txt`:
   - Comandos del ejercicio 1 y 2 
   - Comando para ver los paquetes instalados que contengan "ssh".
   - Comando para saber a que paquete pertenece `/bin/bash`.
   - Comando para listar los ficheros del paquete `nginx`.
   - Comando para limpiar paquetes huerfanos.

## Parte 3 - Servicios systemd (2.0 pts)

1. Comprueba el estado de `nginx` y guardalo en `~/examen_ud2/resultados/servicios.txt`.
2. Deshabilita el arranque automatico de `nginx` y verifica el estado.
3. Muestra los ultimos 20 registros del journal de `nginx` y guardalos en el mismo fichero.
4. Indica en el fichero anterior el objetivo (target) por defecto del sistema.

## Parte 4 - Procesos y señales (2.0 pts)

1. Lanza `sleep 900` en segundo plano y guarda su PID en `~/examen_ud2/resultados/procesos.txt`.
2. Cambia su prioridad a niceness `+5` y confirma el cambio.
3. Finaliza el proceso con SIGTERM y comprueba que ya no existe.

## Parte 5 - Programacion de tareas (2.0 pts)

1. Crea un cron del usuario actual que cada 10 minutos anada la fecha a
   `~/examen_ud2/cron/fechas.log`.
2. Guarda el contenido final de tu crontab en
   `~/examen_ud2/cron/crontab.txt`.
3. Crea un `systemd` timer que ejecute cada hora un servicio que añada
   `uptime` a `~/examen_ud2/cron/uptime.log`.
   - Guardar los ficheros `mi-uptime.service` y `mi-uptime.timer` en
     `~/examen_ud2/cron/`.
   - Habilita y arranca el timer.
   - Guarda `systemctl list-timers` **filtrado** a tu timer en
     `~/examen_ud2/resultados/timers.txt`.

## Criterios de evaluacion (sobre 10)

- Correcta ejecucion de comandos y evidencias guardadas.
- Ficheros en las rutas solicitadas.
- Entrega correcta en Aules del fichero `examen_ud2_entrega.tar.gz`.
- Uso adecuado de permisos y `sudo` cuando proceda.
