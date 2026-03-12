---
search:
  exclude: true
---
# Examenes de ASO

## Contexto de la UD1

La UD1 se centra en el uso de la terminal Linux y en la automatizacion con
scripts de `bash`. El alumnado trabaja con:

- creacion y ejecucion de scripts;
- permisos, variables y argumentos;
- estructuras condicionales e iterativas;
- `case`, tratamiento de ficheros y validacion de datos;
- redirecciones, salidas y documentacion basica del trabajo realizado.

En evaluacion, la UD1 debe comprobar que el alumnado es capaz de resolver una
tarea real mediante guiones sencillos, legibles y con validaciones minimas.

## Contexto de la UD2

La UD2 se orienta a la administracion basica del sistema operativo. Los bloques
principales del material de esta unidad son:

- instalacion, desinstalacion y actualizacion de software;
- uso de contenedores LXD mediante la CLI `lxc`;
- documentacion de la configuracion del sistema;
- gestion de servicios con `systemd`;
- procesos, prioridades y senales;
- programacion de tareas con `cron` y `systemd timers`.

En evaluacion, la UD2 debe comprobar que el alumnado sabe preparar un entorno
de trabajo, mantener servicios y dejar evidencias tecnicas de lo realizado.

## Sentido de los examenes integrados UD1 + UD2

Cuando se combinan ambas unidades en una misma prueba, el escenario natural es
un contenedor LXD/LXC. Asi se evalua en una sola practica:

- la preparacion del laboratorio;
- la administracion del sistema dentro del contenedor;
- la automatizacion mediante scripts;
- la organizacion de evidencias y la entrega final.

Este formato reproduce una situacion de administracion realista y permite
acotar bien la correccion en pruebas de dos horas.

## Organizacion de esta carpeta

La carpeta `docs/Examenes/` centraliza los enunciados, soluciones y materiales
de correccion de las distintas convocatorias.

Convenciones recomendadas:

- un examen nuevo debe ir en su propia carpeta con fecha ISO `YYYY-MM-DD`;
- si el examen es de recuperacion, conviene indicarlo en el nombre de la
  carpeta o del fichero;
- el enunciado principal se guarda en Markdown y, si hace falta, tambien en
  PDF;
- las soluciones y utilidades de correccion deben quedar dentro de la misma
  carpeta del examen.

Ejemplos de nombres coherentes:

- `UD2_2026-01-12/`
- `UD1_UD2_2026-01-21/`
- `UD1_UD2_recuperacion_2026-03-09/`

## Criterio practico para nuevas pruebas

Antes de crear un examen en esta carpeta, conviene revisar tres cosas:

1. Que el enunciado este alineado con los contenidos reales de `docs/UD1` y
   `docs/UD2`.
2. Que el volumen de trabajo sea realista para la duracion prevista.
3. Que la estructura de entrega pida evidencias claras y faciles de corregir.
