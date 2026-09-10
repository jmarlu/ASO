# Revisión de temporalización de ASO

Fecha: 10 de septiembre de 2026. Estado: diagnóstico inicial conservado como antecedente.

**Actualización:** el docente ha confirmado 2026/2027, Elche y cuatro horas semanales. Se han contrastado calendario local e instrucciones FP 2026/2027 y preparado la [propuesta publicada](../../docs/temporalizacion_2026_2027.md). Los pendientes y referencias generales que siguen describen el estado previo a esa comprobación.

El escenario por sesiones se reproduce con `python3 preparacion/temporalizacion/calcular.py`; usa martes/jueves 2+2 como hipótesis, no como horario confirmado. El resultado está en `escenario_2026_2027.csv`.

## Condiciones indicadas por el docente

- Centro de la Comunitat Valenciana.
- Dos evaluaciones de trabajo en el centro antes de la formación en empresa.
- Incluir el repaso de fundamentos Linux dentro de UD1.

## Incoherencias del índice actual

1. Conserva fechas del curso 2025/2026; no consta todavía si se quiere corregir ese curso o preparar 2026/2027.
2. Asigna 26 horas de UD1 entre el 8 y el 24 de septiembre con una carga declarada de 4 horas semanales: no caben.
3. El reparto suma 133 horas; a 4 horas semanales requiere 33,25 semanas completas de clase, antes de descontar festivos y reservar pruebas. No se puede trasladar sin más ese total a una fase presencial de septiembre a comienzos/mediados de marzo.
4. La programación DOCX indica 120 horas y 6 horas semanales, mientras el índice habla de 133 y 4. Hay que confirmar el horario real y el plan aplicable antes de fechar las unidades.
5. La primera evaluación termina implícitamente en noviembre, pero no se indican las sesiones de evaluación ni se justifica ese corte.
6. UD5 comienza el 15 de enero y no se explica el hueco tras Navidad.
7. UD6 comienza el domingo 8 de febrero de 2026 y UD7 el domingo 1 de marzo de 2026.
8. Se excluye el 16 de febrero de una unidad que acaba el 3 de febrero y el 20 de marzo de otra que acaba el 16 de marzo.
9. El Gantt marca unidades como realizadas o activas sin relación con el curso que se vaya a planificar.
10. No figura el comienzo de empresa, ni un margen explícito de pruebas, recuperación y preparación de la transición.
11. El repaso Linux de 4–6 horas debe incluirse dentro del presupuesto de UD1, no añadirse sin ajustar el total.

## Referencias consultadas

Para 2026/2027, la ficha oficial autonómica indica comienzo de FP el 9 de septiembre de 2026 y final el 18 de junio de 2027; Navidad del 22 de diciembre al 6 de enero y Pascua del 25 de marzo al 5 de abril, ambos intervalos incluidos. Son fechas generales del curso, no fechas de salida a empresa de este grupo. [Calendario escolar de la Generalitat](https://sede.gva.es/es/detall-tramit?id_proc=G25685).

El calendario municipal y los acuerdos del centro deben incorporarse antes del cómputo final. La fecha de inicio de empresa no se deduce del calendario escolar general. No se ha supuesto que el fin de la segunda evaluación sea automáticamente la evaluación final del módulo.

## Método para cerrar las fechas

1. Confirmar curso académico, municipio, horario semanal por días, fechas de las dos evaluaciones y salida prevista a empresa.
2. Enumerar las sesiones reales desde el inicio del curso hasta la última clase previa a empresa, descontando vacaciones y días no lectivos aplicables.
3. Reservar dentro de esas sesiones las pruebas, recuperación y cierre de evidencias.
4. Distribuir el tiempo restante entre UD1–UD7, incluyendo fundamentos en UD1 y priorizando GNU/Linux.
5. Si el total disponible es inferior al reparto actual, revisar actividades y la distribución formativa autorizada entre centro y empresa. No dar por transferidas horas o resultados de aprendizaje a empresa sin su plan formativo.
6. Publicar una tabla con las dos evaluaciones, unidades, horas de aula y cierre; añadir después un tramo diferenciado de formación en empresa, con seguimiento según la organización del centro.
7. Generar el Gantt desde esas mismas fechas y retirar estados done/active de una planificación futura.

## Datos pendientes

- Curso: 2025/2026 o 2026/2027.
- Municipio y calendario propio del centro.
- Número real de horas/semanales y días en los que se imparte ASO.
- Fecha de cierre de cada evaluación y comienzo previsto de empresa.

No se han reemplazado las fechas de la web por fechas supuestas. Esta revisión permite identificar qué debe corregirse en cuanto se confirme el calendario del grupo.
