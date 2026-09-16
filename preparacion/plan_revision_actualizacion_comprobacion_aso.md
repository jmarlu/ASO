# Plan de revision, actualizacion y comprobacion de ASO

Fecha de revision: 2026-07-30

Documento base revisado:

- `Programación/PD_0374. Administración de sistemas operativos_Presencial_2425 (1).docx`

Fuentes normativas contrastadas en la Fase 1:

- Real Decreto 1629/2009, de 30 de octubre, por el que se establece el titulo de Tecnico Superior en Administracion de Sistemas Informaticos en Red.
- Orden 36/2012, de 22 de junio, por la que se establece para la Comunitat Valenciana el curriculo LOE de ASIR.
- Decreto 114/2025, de 29 de julio, del Consell, por el que se establecen los curriculos de ciclos formativos de grado medio y superior en aplicacion de la Ley Organica 3/2022.

Material revisado:

- `docs/index.md`
- `docs/UD1/`
- `docs/UD2/`
- `docs/UD3/`
- `docs/UD4/`
- `docs/Examenes/`

## 1. Diagnostico inicial

La programacion didactica del modulo establece:

- Modulo: Administracion de Sistemas Operativos, codigo 0374.
- Curso: 2o de ASIR.
- Duracion: 120 horas.
- Carga semanal: 6 horas.
- Curso academico indicado: 2025/2026.
- Resultados de aprendizaje: RA1 a RA7.

El curriculo vigente publicado por la Generalitat en el Decreto 114/2025 cambia la distribucion horaria general del ciclo. Para ASIR, el modulo 0374 aparece en segundo curso con 133 horas y 4 horas semanales. No obstante, el propio decreto incluye una disposicion transitoria: los ciclos LOE en extincion que sigan impartiendose mantienen su normativa especifica y sus curriculos hasta su finalizacion. Por eso, para 2o ASIR en 2025/2026 pueden convivir dos referencias:

- Grupo LOE en extincion: mantener programacion de centro de 120 horas, basada en Orden 36/2012 y RD 1629/2009.
- Grupo del curriculo adaptado a LO 3/2022: usar 133 horas y 4 horas semanales, segun Decreto 114/2025.

El material actual del sitio esta organizado principalmente en cuatro unidades publicadas:

- UD1: scripting en Linux y PowerShell.
- UD2: instalacion, actualizacion, procesos, servicios, tareas y contenedores.
- UD3: servicios de directorio, LDAP, OpenLDAP, PAM y autenticacion.
- UD4: integracion de sistemas, permisos especiales, ACL, Samba, NFS y recursos compartidos.

La programacion, sin embargo, secuencia siete unidades:

- UD1: aplicacion de lenguajes de scripting.
- UD2: administracion de procesos del sistema.
- UD3: administracion de servicio de directorio.
- UD4: integracion de sistemas operativos en red.
- UD5: informacion del sistema operativo.
- UD6: servicios de acceso y administracion remota.
- UD7: administracion de servidores de impresion.

### Incidencias detectadas

| Prioridad | Incidencia | Evidencia | Accion recomendada |
|---|---|---|---|
| Alta | Desajuste de horas entre programacion, web y curriculo vigente | La programacion indica 120 h y 6 h/semana; `docs/index.md` indicaba 85 h y 4 h/semana; Decreto 114/2025 fija 133 h y 4 h/semana para el nuevo curriculo | Actualizar `docs/index.md` distinguiendo curriculo vigente y transicion LOE 2025/2026 |
| Alta | Faltan unidades publicadas explicitas para UD5, UD6 y UD7 | No existen carpetas `docs/UD5`, `docs/UD6`, `docs/UD7` | Crear estructura minima por unidad con teoria, practica, checklist y evaluacion |
| Alta | RA3 aparece asignado a UD5 en la programacion, pero parte del contenido esta en UD2 | `docs/UD2/programaTareas.md` cubre cron y systemd timers | Decidir si se separa como UD5 o se mantiene en UD2 con trazabilidad clara |
| Media | RA4 esta tratado parcialmente en materiales de PowerShell/WMI, pero no como unidad propia | `docs/UD1/windows/Estandares WMI-CIM.md` contiene sesiones remotas | Crear UD6 y mover o referenciar administracion remota desde ahi |
| Media | RA5 no tiene desarrollo visible como unidad independiente | No hay unidad de impresion publicada | Crear UD7 con CUPS, Windows Print Server, colas, protocolos y evidencias |
| Media | La UD2 actual mezcla contenidos de RA2, RA3 y contenidos de soporte | Procesos, servicios, tareas, instalacion, LXD y actualizacion estan juntos | Reorganizar por RA o anadir tabla de correlacion al inicio de la unidad |
| Baja | Algunos titulos y textos tienen errores menores | Ejemplos: "Examenes", "quetener", "conterner", "Commandos", "Esructura" | Correccion ortografica y normalizacion de titulos |

## 2. Matriz de correlacion programacion-material

| Unidad programada | RA principal | Ponderacion RA | Material actual relacionado | Estado | Revision necesaria |
|---|---:|---:|---|---|---|
| UD1. Scripting en sistemas libres y propietarios | RA7 | 20% | `docs/UD1/linux/`, `docs/UD1/windows/` | Desarrollada | Revisar coherencia Linux-PowerShell, depuracion, funciones, librerias y scripts de administracion real |
| UD2. Administracion de procesos del sistema | RA2 | 8% | `docs/UD2/procesosLinux.md`, `docs/UD2/GestiServicios.md` | Parcialmente desarrollada | Separar procesos de servicios, anadir arranque, hilos, trabajos, seguridad ante procesos sospechosos y evidencias |
| UD3. Servicio de directorio | RA1 | 18% | `docs/UD3/teoria.md`, `docker-openldap.md`, `pam.md`, `ServiciosAutenticacion.md`, `actividades.md` | Desarrollada | Comprobar cobertura de esquema, filtros, cliente LDAP, integracion con PAM/SSSD y documentacion final |
| UD4. Integracion de sistemas operativos en red | RA6 | 22% | `docs/UD4/teoria.md`, `actividades.md`, `guion_clase.md`, `laboratorio-general/` | Desarrollada | Asegurar escenario heterogeneo completo Linux-Windows, Samba/NFS, permisos y prueba de conectividad |
| UD5. Informacion del sistema operativo y automatizacion | RA3 | 18% | `docs/UD2/programaTareas.md`, `docs/UD2/documeConfigSistema.md`, `docs/UD2/actuSisOp.md` | Mezclada en UD2 | Crear UD5 o reubicar contenido; incluir inventario, logs, rendimiento, cron, timers y programador Windows |
| UD6. Acceso y administracion remota | RA4 | 9% | `docs/UD1/windows/Estandares WMI-CIM.md`, partes de UD3/UD4 | Insuficiente como unidad | Crear UD6 con SSH, RDP/xRDP, PowerShell Remoting, tunneling, cuentas, cifrado y pruebas |
| UD7. Servidores de impresion | RA5 | 5% | Sin unidad especifica visible | Pendiente | Crear UD7 con CUPS, Windows, IPP/LPD/SMB, colas, grupos, permisos y comparticion |

## 3. Criterios comunes para revisar cada unidad

Cada unidad debe quedar con la misma estructura minima para facilitar el estudio y la evaluacion:

1. Portada de unidad con RA, criterios de evaluacion y conceptos previos relacionados.
2. Teoria esencial con definiciones, mapa mental de conceptos y comandos principales.
3. Laboratorio guiado reproducible en Linux, Windows o escenario mixto segun corresponda.
4. Actividades graduadas:
   - Nivel 1: comprobacion de conceptos.
   - Nivel 2: ejecucion guiada.
   - Nivel 3: administracion con pequenas decisiones tecnicas.
   - Nivel 4: caso profesional integrado.
5. Checklist de comprobacion para el alumnado.
6. Evidencias obligatorias de entrega.
7. Rubrica o criterios de correccion conectados con RA y criterios.
8. Solucion guia separada del material visible si hay riesgo de copia.

## 4. Plan de revision por fases

### Fase 1. Alinear programacion, indice y temporalizacion

Objetivo: que el sitio y la programacion digan lo mismo.

Tareas:

- Actualizar `docs/index.md` con el marco vigente: 133 horas y 4 horas semanales segun Decreto 114/2025.
- Mantener una nota de transicion para 2025/2026: si el grupo pertenece al segundo curso LOE en extincion, usar la programacion de centro de 120 horas.
- Sustituir la temporalizacion de 85 horas por una planificacion realista de 133 horas.
- Corregir el diagrama de Gantt para siete unidades.
- Incorporar una tabla de RA con ponderaciones:
  - RA1: 18%.
  - RA2: 8%.
  - RA3: 18%.
  - RA4: 9%.
  - RA5: 5%.
  - RA6: 22%.
  - RA7: 20%.
- Revisar la navegacion en `mkdocs.yml` para que las unidades publicadas coincidan con las unidades programadas.

Recomendacion de reparto horario si se aplica el curriculo vigente de 133 horas:

| UD | RA | Peso programacion | Horas recomendadas |
|---|---:|---:|---:|
| UD1. Scripting Linux y PowerShell | RA7 | 20% | 26 |
| UD2. Procesos y servicios del sistema | RA2 | 8% | 11 |
| UD3. Servicios de directorio | RA1 | 18% | 24 |
| UD4. Integracion de sistemas operativos en red | RA6 | 22% | 29 |
| UD5. Informacion del sistema y automatizacion | RA3 | 18% | 24 |
| UD6. Acceso y administracion remota | RA4 | 9% | 12 |
| UD7. Servidores de impresion | RA5 | 5% | 7 |

Esta distribucion suma 133 horas y conserva la proporcion de pesos de RA de la programacion. Los pesos no vienen fijados por la norma estatal ni por el decreto autonomico; son una decision de programacion didactica del centro, siempre que todos los RA y criterios queden evaluados.

Comprobacion:

- El indice no debe contener horas antiguas.
- Cada unidad debe aparecer una sola vez en la navegacion.
- Cada RA debe tener una unidad principal y, si procede, unidades de apoyo.

### Fase 2. Revisar UD1: scripting Linux y PowerShell

Objetivo: consolidar RA7 y conectar scripting con administracion real del sistema.

Material actual:

- `docs/UD1/linux/`
- `docs/UD1/windows/`
- `docs/Examenes/Examen_shell_scripting.md`
- `docs/Examenes/UD1_UD2_*`

Actualizaciones:

- Unificar progresion Linux y PowerShell: variables, parametros, operadores, control de flujo, funciones, depuracion y documentacion.
- Anadir un bloque claro de depuracion:
  - `bash -n`, `shellcheck` si se usa, trazas con `set -x`.
  - PowerShell: errores, `$ErrorActionPreference`, `try/catch`.
- Reforzar scripts de administracion:
  - gestion de usuarios;
  - comprobacion de servicios;
  - automatizacion de tareas;
  - recogida de informacion del sistema.
- Mantener correlacion con UD2 y UD5: los scripts deben automatizar procesos, servicios, inventario o tareas programadas.

Comprobacion:

- Todo script de actividad debe tener entrada, salida, validaciones y evidencia.
- Debe existir al menos una practica integradora Linux y otra Windows.
- Los examenes UD1+UD2 deben seguir estando alineados con las actividades reales.

### Fase 3. Revisar UD2: procesos, servicios y arranque

Objetivo: dejar UD2 centrada en RA2.

Material actual:

- `docs/UD2/procesosLinux.md`
- `docs/UD2/GestiServicios.md`
- `docs/UD2/Actividades.md`

Actualizaciones:

- Separar conceptos:
  - proceso, hilo, trabajo, demonio y servicio;
  - estados de proceso;
  - senales;
  - prioridades;
  - arbol de procesos;
  - secuencia de arranque con systemd.
- Anadir equivalente Windows:
  - Administrador de tareas;
  - servicios;
  - visor de eventos;
  - PowerShell para procesos y servicios.
- Crear actividad de seguridad:
  - detectar proceso desconocido;
  - identificar binario, usuario, puertos, consumo y persistencia;
  - documentar accion correctiva.

Comprobacion:

- El alumnado debe demostrar `ps`, `top/htop`, `pstree`, `jobs`, `kill`, `nice/renice`, `systemctl` y logs.
- Debe existir una evidencia sobre arranque y dependencias de servicios.
- Cada actividad debe indicar criterios RA2.a a RA2.i.

### Fase 4. Revisar UD3: servicio de directorio

Objetivo: comprobar cobertura completa de RA1.

Material actual:

- `docs/UD3/teoria.md`
- `docs/UD3/docker-openldap.md`
- `docs/UD3/pam.md`
- `docs/UD3/ServiciosAutenticacion.md`
- `docs/UD3/actividades.md`
- `laboratorio-general/ldap/`

Actualizaciones:

- Confirmar que se explican DIT, DN, RDN, atributos, objectClass y esquema.
- Asegurar que hay practica de:
  - instalacion de OpenLDAP;
  - carga de LDIF;
  - busquedas con base, scope y filtros;
  - modificacion y borrado;
  - ACL;
  - integracion cliente con PAM/SSSD;
  - documentacion final.
- Anadir comparacion con Active Directory como servicio propietario, aunque el laboratorio principal sea OpenLDAP.

Comprobacion:

- El laboratorio debe poder levantarse desde cero.
- Las busquedas `ldapsearch` deben tener resultados esperados.
- El login o autenticacion centralizada debe estar comprobado con evidencias.
- Debe existir una plantilla de memoria de implantacion LDAP.

### Fase 5. Revisar UD4: integracion de sistemas en red

Objetivo: consolidar RA6, el RA de mayor peso.

Material actual:

- `docs/UD4/teoria.md`
- `docs/UD4/actividades.md`
- `docs/UD4/guion_clase.md`
- `docs/UD4/lab/ud4_lab.sh`
- `laboratorio-general/lxc-samba/`
- `laboratorio-nextcloud/`

Actualizaciones:

- Mantener una linea clara UD3 -> UD4:
  - usuarios centralizados;
  - permisos POSIX/ACL;
  - recursos compartidos;
  - acceso desde clientes heterogeneos.
- Verificar contenidos de Samba, NFS y Nextcloud.
- Anadir pruebas de conectividad y permisos:
  - ping/resolucion;
  - acceso SMB;
  - montaje NFS;
  - usuario autorizado/no autorizado;
  - escritura, lectura y denegacion.
- Incluir diagrama de escenario y tabla de servicios, puertos y usuarios.

Comprobacion:

- El laboratorio debe generar evidencias reproducibles.
- Cada recurso compartido debe tener prueba positiva y prueba negativa.
- La documentacion final debe explicar configuracion, permisos y resultado de pruebas.

### Fase 6. Crear o separar UD5: informacion del sistema y automatizacion

Objetivo: cubrir RA3 sin que quede diluido dentro de UD2.

Material actual relacionado:

- `docs/UD2/programaTareas.md`
- `docs/UD2/documeConfigSistema.md`
- `docs/UD2/actuSisOp.md`

Propuesta:

- Crear `docs/UD5/`.
- Mover o referenciar los contenidos de tareas programadas desde UD2.
- Organizar la unidad en:
  - inventario del sistema;
  - estructura de directorios;
  - sistema de archivos virtual `/proc` y `/sys`;
  - logs;
  - rendimiento;
  - planificacion con `cron`;
  - planificacion con `systemd timers`;
  - Programador de tareas de Windows;
  - automatizacion de cuentas;
  - documentacion de tareas programadas.

Comprobacion:

- El alumnado debe crear una tarea repetitiva y una puntual.
- Debe aplicar restricciones de seguridad.
- Debe documentar temporizador, usuario, comando, logs y resultado.
- Debe haber una actividad conectada con UD1: script ejecutado por cron o timer.

### Fase 7. Crear UD6: acceso y administracion remota

Objetivo: cubrir RA4 como unidad propia.

Material actual relacionado:

- `docs/UD1/windows/Estandares WMI-CIM.md`
- referencias indirectas en UD3 y UD4.

Propuesta:

- Crear `docs/UD6/`.
- Incluir:
  - SSH;
  - claves publicas y privadas;
  - hardening basico de `sshd`;
  - copia remota con `scp`/`rsync`;
  - tuneles SSH;
  - RDP y xRDP;
  - PowerShell Remoting;
  - administracion remota en entornos heterogeneos;
  - cifrado y puertos implicados.

Comprobacion:

- Debe haber pruebas de acceso remoto Linux-Linux, Windows-Windows y al menos una prueba heterogenea.
- Debe documentarse usuario, servicio, puerto, mecanismo de cifrado y prueba de conexion.
- Debe incluir una actividad de seguridad: desactivar password login o restringir usuarios en SSH.

### Fase 8. Crear UD7: servidores de impresion

Objetivo: cubrir RA5, aunque tenga menor ponderacion.

Material actual:

- No se ha localizado una unidad especifica de impresion.

Propuesta:

- Crear `docs/UD7/`.
- Incluir:
  - conceptos de impresion;
  - spooler y colas;
  - puertos y protocolos: IPP, LPD/LPR, SMB, JetDirect 9100;
  - CUPS en GNU/Linux;
  - administracion web de CUPS;
  - gestion de impresoras con comandos;
  - servidor de impresion Windows;
  - comparticion entre sistemas;
  - permisos, grupos y auditoria basica.

Comprobacion:

- Debe existir una practica con impresora virtual o PDF.
- Debe comprobarse cola, cancelacion, pausa, reanudacion y comparticion.
- Debe documentarse configuracion del servidor y pruebas desde cliente.

## 5. Plan de comprobacion transversal

Cada unidad se revisara con la siguiente lista:

| Comprobacion | Pregunta de control | Evidencia |
|---|---|---|
| Coherencia curricular | La unidad indica RA y criterios concretos? | Tabla RA/CE al inicio |
| Coherencia teorica | Estan definidos los conceptos esenciales? | Glosario o bloque de conceptos |
| Coherencia practica | La practica usa los conceptos teoricos? | Laboratorio guiado |
| Correlacion entre unidades | Se conecta con unidades anteriores o posteriores? | Apartado "Relacion con otras UD" |
| Evaluacion | La actividad genera evidencias corregibles? | Lista de ficheros, capturas o comandos |
| Actualidad tecnica | Los comandos siguen siendo validos en Ubuntu/Debian y Windows actuales? | Prueba de laboratorio |
| Reproducibilidad | Puede repetirse desde cero? | Script, checklist o README |
| Seguridad | Hay consideraciones de permisos, usuarios, cifrado o exposicion? | Apartado de buenas practicas |
| Documentacion | El alumnado deja memoria tecnica? | Plantilla o pauta de entrega |

## 6. Correlaciones recomendadas entre unidades

| Relacion | Sentido didactico | Ejemplo practico |
|---|---|---|
| UD1 -> UD2 | Los scripts administran procesos y servicios | Script que comprueba si `nginx` esta activo y lo reinicia con log |
| UD1 -> UD5 | Los scripts automatizan inventario y tareas | Script de informe del sistema ejecutado por `systemd timer` |
| UD2 -> UD5 | Los servicios y procesos generan logs y tareas de mantenimiento | Timer que comprueba un servicio y guarda evidencias |
| UD3 -> UD4 | Los usuarios centralizados se usan para acceder a recursos compartidos | Usuario LDAP accede a recurso Samba/NFS con permisos ACL |
| UD3 -> UD6 | La autenticacion centralizada se usa en acceso remoto | Login SSH contra usuario gestionado por LDAP/SSSD |
| UD4 -> UD7 | Los recursos compartidos incluyen impresion en red | Impresora CUPS compartida y accesible desde cliente |
| UD6 -> UD4 | La administracion remota permite mantener servidores de recursos | Gestionar Samba/NFS por SSH o PowerShell Remoting |
| UD1 -> UD7 | Scripts de administracion de colas | Script que lista trabajos pendientes y avisa de errores |

## 7. Orden recomendado de trabajo

1. Corregir `docs/index.md` para que coincida con la programacion 2025/2026.
2. Crear carpetas base `docs/UD5`, `docs/UD6` y `docs/UD7`.
3. Reordenar o enlazar contenidos de UD2 que realmente pertenecen a RA3.
4. Anadir tabla RA/CE al inicio de cada unidad.
5. Revisar actividades para que todas tengan evidencias corregibles.
6. Crear una prueba corta por unidad y una prueba integrada:
   - UD1 + UD2 + UD5: scripting, procesos, servicios y tareas.
   - UD3 + UD4 + UD6: LDAP, recursos compartidos y acceso remoto.
   - UD7: impresion en red con caso practico breve.
7. Ejecutar comprobacion tecnica de laboratorios.
8. Generar informe final de cambios y pendientes.

## 8. Entregables finales del proceso

Al terminar la revision completa deberian quedar estos entregables:

- `docs/index.md` actualizado.
- `mkdocs.yml` con navegacion coherente.
- `docs/UD1/` revisada y conectada con UD2/UD5.
- `docs/UD2/` centrada en procesos, servicios y arranque.
- `docs/UD3/` validada con laboratorio LDAP reproducible.
- `docs/UD4/` validada con laboratorio de recursos compartidos.
- `docs/UD5/` creada para informacion del sistema y automatizacion.
- `docs/UD6/` creada para administracion remota.
- `docs/UD7/` creada para impresion.
- Una matriz RA-CE-actividad-evidencia.
- Un checklist de comprobacion tecnica por unidad.
- Al menos una prueba de evaluacion por bloque o unidad.

## 9. Proxima accion recomendada

La primera accion tecnica debe ser actualizar `docs/index.md`, porque ahora mismo es la puerta de entrada del alumnado y contiene datos horarios que no coinciden con la programacion revisada. Despues conviene crear las unidades UD5, UD6 y UD7 aunque inicialmente sean esqueletos, para que la estructura del sitio refleje todos los resultados de aprendizaje.
