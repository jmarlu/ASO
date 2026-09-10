# Administración de Sistemas Operativos

Aquí puedes encontrar los apuntes del módulo de ***Administración de Sistemas Operativos***, que se imparte en el segundo curso del ciclo formativo de grado superior de Administración de Sistemas Informáticos en Red.

* **Curso 2026/2027 · Elche (Alicante) · 4 horas semanales.**
* El currículo de ASIR asigna **133 horas** al módulo 0374. La programación debe distinguir formación en el centro y la parte que corresponda desarrollar en empresa; no se consideran 133 horas de aula antes de la salida. [Decreto 114/2025, página 72](https://dogv.gva.es/datos/2025/08/04/pdf/2025_29742_es.pdf).
* Se organizan dos evaluaciones en el centro y una fase posterior de formación en empresa, con seguimiento y evaluación final. La [temporalización revisada](temporalizacion_2026_2027.md) diferencia calendario confirmado y propuesta pendiente del horario y plan del centro.

## ¿Qué voy a aprender?

* Administrar sistemas operativos de servidor, instalando y configurando el software, en condiciones de calidad para asegurar el funcionamiento del sistema.
* Administrar servicios de recursos compartidos (acceso a directorios, impresión, accesos remotos, entre otros) instalando y configurando el software, en condiciones de calidad.
* Administrar usuarios de acuerdo a las especificaciones de explotación para garantizar los accesos y la disponibilidad de los recursos del sistema.
* Gestionar los recursos de diferentes sistemas operativos (programando y verificando su cumplimiento).

## Resultados de aprendizaje

Un *Resultado de Aprendizaje* **"es una declaración de lo que el estudiante se espera que conozca, comprenda y sea capaz de hacer al finalizar un periodo de aprendizaje".** Los resultados de aprendizaje de ASO vienen definidos en el [RD 1629/2009.](https://www.boe.es/eli/es/rd/2009/10/30/1629)

Los Resultados de Aprendizaje de ASO son:

1. Administra el servicio de directorio interpretando especificaciones e integrándolo en una red.
2. Administra procesos del sistema describiéndolos y aplicando criterios de seguridad y eficiencia.
3. Gestiona la automatización de tareas del sistema, aplicando criterios de eficiencia y utilizando comandos y herramientas gráficas.
4. Administra de forma remota el sistema operativo en red valorando su importancia y aplicando criterios de seguridad.
5. Administra servidores de impresión describiendo sus funciones e integrándolos en una red.
6. Integra sistemas operativos libres y propietarios, justificando y garantizando su interoperabilidad.
7. Utiliza lenguajes de guiones en sistemas operativos, describiendo su aplicación y administrando servicios del sistema operativo.

## Relación entre RA, unidades y peso de programación

La normativa fija los resultados de aprendizaje y sus criterios de evaluación. Los pesos siguientes proceden de la programación del módulo revisada en el centro y sirven para organizar la evaluación y la carga de trabajo.

| RA | Resultado de aprendizaje | Unidad principal | Peso programación |
|---:|---|---|---:|
| RA1 | Administra el servicio de directorio interpretando especificaciones e integrándolo en una red. | UD3. Servicios de directorio | 18% |
| RA2 | Administra procesos del sistema describiéndolos y aplicando criterios de seguridad y eficiencia. | UD2. Procesos y servicios | 8% |
| RA3 | Gestiona la automatización de tareas del sistema, aplicando criterios de eficiencia y utilizando comandos y herramientas gráficas. | UD5. Automatización y mantenimiento GNU/Linux | 18% |
| RA4 | Administra de forma remota el sistema operativo en red valorando su importancia y aplicando criterios de seguridad. | UD6. Acceso y administración remota | 9% |
| RA5 | Administra servidores de impresión describiendo sus funciones e integrándolos en una red. | UD7. Servidores de impresión | 5% |
| RA6 | Integra sistemas operativos libres y propietarios, justificando y garantizando su interoperabilidad. | UD4. Integración de sistemas operativos en red | 22% |
| RA7 | Utiliza lenguajes de guiones en sistemas operativos, describiendo su aplicación y administrando servicios del sistema operativo. | UD1. Scripting Linux y PowerShell | 20% |

La correlación recomendada es mantener una unidad principal por RA, pero diseñar prácticas integradas:

- UD1 se debe reutilizar en UD2, UD5 y UD7 mediante scripts de administración.
- UD3 debe preparar la base de usuarios y autenticación que se aprovechará en UD4 y UD6.
- UD4 debe actuar como unidad integradora fuerte porque es el RA con mayor peso.
- [UD5](UD5/index.md) desarrolla informes, tareas programadas y mantenimiento GNU/Linux a partir de los procesos y servicios estudiados en UD2.

## Unidades didácticas / Temporalización

La propuesta se adapta al **calendario de Elche 2026/2027** y a las **cuatro horas semanales**. Sustituye la temporalización antigua de 2025/2026.

| Fase | Periodo propuesto | Trabajo principal |
|---|---|---|
| Primera evaluación | Septiembre – 10 de diciembre | UD1 (incluido fundamentos Linux), UD2 y UD3; prueba y recuperación |
| Segunda evaluación | 15 de diciembre – 23 de marzo | UD4, UD5, UD6 y UD7; prueba, recuperación y preparación de empresa |
| Formación en empresa y cierre | 6 de abril – 18 de junio | Actividades del plan formativo, seguimiento y evaluación final |

**Fechas orientativas:** el cálculo detallado usa martes y jueves, dos horas cada día, como ejemplo de horario. Da 102 horas en el centro, incluidas 10 para evaluación y recuperación. Los días reales de ASO y el plan de empresa deben confirmar o ajustar ese escenario; no se asignan automáticamente las 31 horas restantes del currículo a empresa.

Consulta la **[temporalización completa, calendario local y Gantt](temporalizacion_2026_2027.md)**, que también explica en qué condiciones encajarían 400 horas de empresa en segundo curso.

## Evaluación

Para superar el módulo hay que tener todos los **RA aprobados**.

### Instrumentos de calificación

1. **Instrumento de calificación 1 (IC1):**: *escala de valores* comprendidas entre 0 y 3 puntos calificados de la siguiente forma:
    * **0**: No realizada.
    * **1**: Realizada pero solución errónea o incompleta.
    * **2**: Realizada y solución aceptable, aunque tiene algún apartado incompleto.
    * **3**: Realizada y solución correcta.

2. **Instrumento de calificación 2 (IC2):** *escala de valores* comprendidas entre 0 y 7 puntos calificados de la siguiente forma:
    * **0**: No realizada.
    * **1-3**: Realizada pero solución errónea o incompleta.
    * **3-6**: Realizada y solución aceptable, aunque tiene algún apartado incompleto.
    * **7**: Realizada y solución correcta.

### Instrumentos de Evaluación
La nota de cada **Resultado de Aprendizaje** se calcula mediante la media ponderada de los puntos obtenidos, de los siguientes instrumentos de evaluación.

1. **Instrumento de Evaluación 1 (IE1). Trabajo en Clase/Actividades.**
    1. Se evalúan todas las actividades realizadas en clase.
    2. Las actividades se evalúan mediante observación directa del docente y aplicando el **IC1**.
    
2. **Instrumentos de Evaluación 2 (IE2). Pruebas de auditoría y objetivas.**
    Pueden contener:
    1. Cuestionario multi-opción (test) de 20 preguntas sobre la teoría de la unidad.
    2. Ejercicios prácticos sobre las actividades realizadas de la unidad.

!!! not "**Nota**:"    
    Esta prueba se califica entre 0 y 30 puntos siguiendo las siguientes premisas:
- **0-10** puntos. Donde Cada dos contestaciones incorrectas contestadas resta una bien.
- **0-6** puntos: dos ejercicios de *nivel medio-bajo*, 3 puntos cada uno de ellos aplicando **IC1**.
- **0-14** puntos: dos ejercicios de *nivel medio-alto* aplicando **IC2**.
