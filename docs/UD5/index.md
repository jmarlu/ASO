# UD5. Automatización y mantenimiento de sistemas GNU/Linux

**Itinerario completo: 24 horas. RA principal: RA3.**

La [temporalización provisional 2026/2027](../temporalizacion_2026_2027.md) plantea una selección de 16 horas con scripts de partida y evidencias compartidas. El reparto siguiente describe el itinerario completo; la página del calendario especifica la adaptación y sus condiciones.

Al terminar podrás instalar una tarea automática, ejecutarla con los permisos adecuados, comprobar su resultado y diagnosticar un fallo. Trabajaremos con Ubuntu y Bash. Windows queda como ampliación opcional y no forma parte del laboratorio ni de la entrega principal.

## Recorrido

1. [Teoría: de un comando a una tarea fiable](teoria.md).
2. [Laboratorio guiado: mantenimiento de un servidor](laboratorio.md).
3. [Actividades, caso final y evaluación](actividades.md).

## Punto de partida

Necesitas los argumentos, condiciones y redirecciones de [UD1](../UD1/linux/Argumentos.md), y el manejo de [servicios de UD2](../UD2/GestiServicios.md). Usaremos una VM Ubuntu Server 24.04 con systemd, una cuenta con sudo y datos de prueba. Para la práctica gráfica utilizaremos una VM Kubuntu 24.04 con KCron.

El laboratorio funciona de forma independiente de LDAP y Samba. Después puedes aplicar sus tareas a los servidores de UD3 y UD4 y administrarlas remotamente en UD6.

## Distribución de las sesiones

| Bloque | Horas | Resultado |
|---|---:|---|
| Preparar una tarea | 4 | Informe del sistema con parámetros, errores y registro |
| cron, at y planificación gráfica | 5 | Una tarea periódica, una puntual y una creada con KCron |
| systemd timers | 6 | Servicio y temporizador verificados; recuperación de una ejecución pendiente |
| Fiabilidad y cuentas | 4 | Permisos, exclusión mutua, retención y mantenimiento de cuentas de prueba |
| Caso integrado | 5 | Informe, copia restaurable y comprobación de servicio documentados |

## Relación con los criterios de evaluación

La siguiente tabla resume los criterios de RA3 del [RD 1629/2009, módulo 0374](https://www.boe.es/eli/es/rd/2009/10/30/1629); no sustituye su redacción oficial. La planificación gráfica se realiza en Linux.

| Criterio | Aplicación en la unidad | Evidencia |
|---|---|---|
| a — Ventajas de automatizar | Actividad 1 | Justificación de tareas y frecuencia |
| b — Comandos de planificación | Actividades 2 y 4 | crontab, at y unidades systemd |
| c — Restricciones de seguridad | Actividades 5 y 6 | Usuarios, permisos, bloqueo y prueba negativa |
| d — Tareas repetitivas y puntuales | Actividades 2 y 4 | Ejecuciones con fecha y resultado |
| e — Administración automática de cuentas | Actividad 6 | Script y cambio verificado en cuenta de prueba |
| f — Instalación/configuración de herramienta gráfica | Actividad 3 | KCron instalado y configurado |
| g — Uso de herramienta gráfica | Actividad 3 | Tarea guardada, ejecutada y desactivada |
| h — Documentación | Caso final | Memoria reproducible y diagnóstico |

## Criterio de trabajo

Una entrada de cron o un timer activo no demuestran por sí solos que una tarea funciona. Para cada tarea se comprobarán **configuración, ejecución y resultado**. Una copia requiere además una restauración.

El peso de RA3 en la programación existente es del 18 %. La rúbrica de actividades sirve para obtener evidencias de ese RA; no cambia los pesos generales del módulo.
