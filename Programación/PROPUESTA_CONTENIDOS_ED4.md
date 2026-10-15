# Propuesta de adaptación de ASO al modelo F01.PC02, edición 4

> **Estado a 30/09/2026:** propuesta histórica previa a la adaptación. El DOCX ya incorpora las correcciones descritas en [CAMBIOS_ED4_2026-09-30.md](CAMBIOS_ED4_2026-09-30.md), incluido un plan de empresa provisional desarrollado. Los pendientes indicados más abajo corresponden al estado de 24/09/2026.

Documento de trabajo, 24/09/2026. Estas propuestas no son acuerdos aprobados por el centro ni una adaptación normativa completa. El DOCX de ASO contiene la aclaración horaria, un índice enlazado y los apartados de conexión con el PI existente y previsión provisional de empresa. El resto de la adaptación sigue pendiente.

## Estructura que debe tener la programación

0. Propuestas de mejora del curso anterior.
1. Introducción y justificación teórica contextualizada.
   - 1.1. Normativa de referencia.
   - 1.2. Identificación del título.
   - 1.3. Cuadro horario.
   - 1.4. Relación entre los estándares de competencia y los módulos del ciclo formativo.
   - 1.5. Identificación del módulo / unidad formativa.
   - 1.6. Características del alumnado.
   - 1.7. Del sector productivo.
2. Desarrollo curricular.
   - 2.1. Competencias y objetivos.
   - 2.2. Resultados de aprendizaje y criterios de evaluación.
   - 2.3. Relación entre competencias y resultados de aprendizaje.
   - 2.4. Contenidos básicos de referencia del módulo.
3. Metodología didáctica: estrategias, líneas pedagógicas del centro y recursos.
4. Unidades.
5. Proyecto intermodular: especificaciones y distribución de elementos curriculares.
6. Plan formativo en empresa.
7. Evaluación y calificación: instrumentos, calificación, recuperación e inasistencia.
8. Evaluación de la práctica docente.
9. Medidas de atención a la diversidad.
10. Anexo I: ponderaciones de RA y CE, y distribución de un mismo CE entre unidades cuando proceda.

## Contenidos que podemos incorporar

### 0. Propuestas de mejora

Texto propuesto: «Se propone reforzar los fundamentos de Linux al inicio del módulo, organizar las prácticas en un laboratorio reutilizable y vincular cada entrega a los resultados de aprendizaje y criterios de evaluación correspondientes. Se introducirán comprobaciones individuales de los comandos y configuraciones empleados, documentación de incidencias y actividades de recuperación centradas en los aprendizajes no alcanzados.»

Son propuestas para este curso. Para presentarlas como conclusiones del anterior, deben contrastarse con la memoria y el seguimiento de aula. El repaso se integra en la UD1, sin sumar horas ficticias.

### 1.3. Cuadro horario

Dato oficial comprobado: módulo 0374, segundo curso, 133 horas y 4 horas semanales, según el [Decreto 114/2025, página 72](https://dogv.gva.es/datos/2025/08/04/pdf/2025_29742_es.pdf#page=72).

El calendario de 102 horas es un ejemplo de aula, no el reparto oficial. La diferencia de 31 horas no se asignará a empresa por simple resta. El horario real y el plan formativo deben sustentar la temporalización definitiva. La plantilla pide el cuadro del ciclo y su lengua vehicular; la programación actual solo incluye el de ASO, por lo que habrá que completar el cuadro del ciclo y confirmar las lenguas con el centro.

### 1.4 y 2.3. Correspondencias curriculares

Preparar dos tablas diferentes: estándares de competencia ↔ módulos, y competencias del título ↔ resultados de aprendizaje de ASO. La programación anterior menciona UC0490_3 y UC0485_3; deben contrastarse los códigos, denominaciones y correspondencias oficiales antes de trasladarlos a la nueva tabla. No basta con cambiar la etiqueta «unidad» por «estándar».

La relación pedagógica entre competencias y RA puede apoyarse en evidencias de administración de servicios, gestión de usuarios, diagnóstico de incidencias, mantenimiento y documentación. Se debe conservar la distinción entre esa relación didáctica y una correspondencia normativa.

### 4. Unidades: actividades y evidencias

| Unidad | RA principal de la programación actual | Propuesta de evidencia |
|---|---|---|
| UD1. Fundamentos y scripting | RA7 | Guiones Bash y PowerShell, pruebas y explicación individual; fundamentos Linux como preparación. |
| UD2. Procesos y servicios | RA2 | Diagnóstico de procesos, prioridades, arranque y recuperación de un servicio. |
| UD3. Directorio | RA1 | Directorio, usuarios y grupos; consultas e integración de un cliente; documentación. |
| UD4. Integración de sistemas | RA6 | Recurso compartido entre Linux y Windows, permisos y pruebas de acceso autorizado y denegado. |
| UD5. Automatización | RA3 | Tareas puntuales y periódicas, automatización de cuentas, herramientas gráficas y registros de ejecución. |
| UD6. Administración remota | RA4 | Acceso remoto seguro, cuentas, pruebas entre sistemas y registro de la configuración. |
| UD7. Impresión | RA5 | Servidor, colas y clientes; pruebas y resolución de incidencias. |

En cada ficha clasificar las actividades como pide la plantilla: introducción; formativas no evaluables; formativas evaluables; proyecto intermodular; refuerzo; profundización; recuperación; complementarias; CLIL. Por ejemplo: demostración guiada como no evaluable, práctica individual con pruebas como evaluable y reparación de una configuración fallida como recuperación.

Para CLIL se propone lectura guiada de documentación técnica en inglés y elaboración de un glosario. Su inclusión y alcance deben coordinarse con el proyecto lingüístico. Si no hay actividad complementaria prevista, indicarlo expresamente.

### 5. Proyecto intermodular

#### 5.1. Especificaciones

La conexión se establece con el proyecto ya desarrollado en el repositorio hermano `PI`: **construcción, instalación y administración de un nodo Proxmox individual con VMs/LXC y servicios Linux automatizados**. Cada estudiante trabaja con hardware reutilizado autorizado o con Proxmox virtualizado en VirtualBox. El Proxmox del centro queda fuera del montaje previsto.

El producto incluye un nodo administrable, una plantilla Linux, dos invitados (servidor `srv-aso` y cliente de pruebas), un servicio de ASO aprobado, dos scripts Bash de inventario y copia del servicio, un playbook Ansible útil ejecutado sobre el servidor, copias y restauración comprobada, pruebas y memoria Markdown en un repositorio individual de GitHub.

PI desarrolla Proxmox y profundiza en Ansible. ASO aporta los conocimientos de Linux, procesos y servicios, scripting, permisos, integración y administración remota que el alumnado aplica en el proyecto. El servicio se acuerda según los conocimientos disponibles; Samba es una opción, no se exige desplegar todos los servicios. LDAP y CUPS solo se incorporarán si forman parte del servicio elegido o de una ampliación aprobada. Un proyecto realizado únicamente con Linux o Bash no acredita por sí solo los CE que requieren sistemas heterogéneos o guiones en sistemas propietarios.

#### 5.2. Distribución de elementos curriculares

Las referencias RA/CE de esta tabla corresponden a **ASO**, no a los RA propios de PI. Son conexiones propuestas para seleccionar evidencias concretas; no suponen cobertura automática de un RA completo.

| Aportación de ASO | Unidad / RA | CE candidatos para la coordinación | Evidencia |
|---|---|---|---|
| Procesos y operación del servicio | UD2 / RA2 | RA2.d, f, g, i | Estado, arranque, registros, diagnóstico y documentación del servicio. |
| Scripts de inventario y copia | UD1 / RA7 | RA7.a, b, e, f, i | Dos scripts propios adaptados; caso correcto y caso de error; copia y recuperación verificadas. |
| Integración y permisos, según servicio | UD4 / RA6 | RA6.b, e, f, h | Configuración y pruebas cliente-servidor; completar la heterogeneidad exigida por el CE cuando corresponda. |
| Tareas programadas, si se incorporan | UD5 / RA3 | RA3.b, d, h | Programación con cron o timers y registros. Ejecutar Ansible manualmente no acredita por sí solo planificación temporal. |
| Administración remota | UD6 / RA4 | RA4.d, e, h, i | SSH, acceso administrativo, cifrado y documentación. |
| Directorio, condicionado a la elección | UD3 / RA1 | RA1.c, d, h, j | Instalación de LDAP e integración de cliente si el servicio lo requiere. |
| Impresión, condicionado a la elección | UD7 / RA5 | RA5.d, g, i | CUPS, gestión de colas y documentación si se elige este servicio. |

La coordinación se realizará antes de S13 (base Linux y SSH), S21 (servicio, permisos y pruebas) y S26 (Bash y equipo controlador de Ansible). Se comprobarán los aprendizajes disponibles y se acordarán apoyos o un servicio equivalente si falta algún requisito. Estas referencias son hitos del PI, no fechas confirmadas del calendario de ASO.

Las evidencias compartidas se localizarán en la memoria del proyecto, sin exigir otra memoria paralela. Cada módulo valorará sus propios RA y CE; no se trasladará automáticamente la nota de PI a ASO ni se sumarán horas por duplicado. Los aprendizajes de ASO que no cubra el servicio seleccionado seguirán trabajándose y evaluándose en ASO.

Fuentes locales revisadas:

- [Coordinación PI–ASO](../../PI/programaciones/09_coordinacion/Coordinacion_ASO.md).
- [Programación específica del proyecto](../../PI/programaciones/02_programacion_proyecto_proxmox/Programacion_PI_ASIR_Proxmox_Individual_2026-2027.md).
- [Entrega de automatización del alumnado](../../PI/web_alumnado/docs/proyecto/automatizacion.md).

Los enlaces requieren conservar ambos repositorios como carpetas hermanas. El documento de coordinación de PI describe una revisión anterior de materiales UD1–UD4; no se toma como calendario aprobado ni como inventario completo actual de ASO.

### 6. Plan formativo en empresa

**Redacción para la programación:** «La previsión de actividades y resultados de aprendizaje de ASO en empresa tiene carácter provisional, puesto que en el momento de elaborar esta programación no se conocen las empresas de destino, sus entornos tecnológicos ni las tareas que podrán ofrecer al alumnado. No se puede asegurar de antemano que en todas las empresas se desarrollen contenidos específicos de este módulo. Una vez conocida la empresa, la tutoría del centro y la tutoría de empresa concretarán las actividades viables, los resultados de aprendizaje y criterios de evaluación relacionados, las evidencias y el seguimiento, y actualizarán el plan formativo correspondiente. Solo se incorporarán a la evaluación de ASO los aprendizajes efectivamente trabajados y acreditados. Si la empresa no permite desarrollar una actividad prevista, se revisará la planificación para asegurar el aprendizaje y su evaluación en el centro.»

Como posibilidades orientativas, no tareas garantizadas: gestionar cuentas con supervisión; consultar registros y diagnosticar incidencias; comprobar tareas programadas; documentar intervenciones; administrar servicios remotamente cuando exista autorización.

Usar la tabla del modelo: RA, desarrollo en centro/empresa, modo de evaluación compartida, porcentajes de centro/empresa/ampliación y actividades formativas. Añadir como apoyo la evidencia esperada y la persona responsable del seguimiento.

Dejar como **pendiente del plan formativo** qué RA se comparten, sus actividades concretas y los porcentajes. La disponibilidad de tareas depende de cada empresa. No asignar automáticamente 31 horas, ni convertir los pesos de calificación de los RA en horas de estancia. Las evidencias deben evitar datos reales de clientes, credenciales o información confidencial.

### 7 y 10. Evaluación y anexo

La plantilla ed4 propone escala de 0 a 10 y mantiene el umbral de al menos 5 en cada RA. Su texto de recuperación dice «superior a 5», lo que debe corregirse para que no contradiga ese umbral. Antes de sustituir las reglas de inasistencia y convocatoria, revisar la normativa aplicable y los procedimientos del centro; esta corrección horaria no los modifica.

Conservar como punto de partida las ponderaciones actuales: RA1 18 %, RA2 8 %, RA3 18 %, RA4 9 %, RA5 5 %, RA6 22 % y RA7 20 %; suman 100 %. La nueva plantilla no obliga por sí sola a cambiarlas.

Proponer una rúbrica con funcionamiento, verificación, diagnóstico y documentación, siempre vinculada a CE concretos. Para la tabla de CE distribuidos entre unidades, identificar primero cuáles se evalúan realmente en más de una unidad y repartir su ponderación hasta el 100 %. Reutilizar un script no implica necesariamente volver a calificar el mismo CE.

### 8 y 9. Seguimiento e inclusión

Registrar por evaluación: progreso por RA, dificultades frecuentes, desviación de la temporalización, eficacia del refuerzo y propuestas de mejora. En inclusión: guías graduadas, materiales accesibles, alternativas de presentación de evidencias y apoyos acordados con orientación, manteniendo los aprendizajes que se deben acreditar.

## Datos necesarios para cerrar la adaptación

- Horario real y organización de la formación en empresa.
- Memoria del curso anterior y líneas del PEC aplicables.
- Acuerdos del proyecto intermodular y lenguas vehiculares.
- Correspondencias curriculares y normativa de evaluación actualizadas.
- RA, actividades, seguimiento y evaluación del plan formativo del grupo.

El documento F01.PC02 ed4 se conserva como plantilla de referencia. Las propuestas anteriores permiten redactar los apartados sin presentar datos pendientes como decisiones ya adoptadas.
