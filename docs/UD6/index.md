# UD6. Acceso y administración remota

**Previsión: 8 horas. Resultado principal: RA4. Peso en el módulo: 9 %.**

Administrar a distancia significa identificar el equipo al que te conectas, autenticarte, realizar una intervención con los permisos adecuados y demostrar su resultado. En esta unidad trabajarás desde Linux y Windows, con terminal y escritorio remoto.

## Recorrido

1. [Teoría: protocolos, identidades y sesiones](teoria.md).
2. [Laboratorio: SSH, transferencia y escritorio remoto](laboratorio.md).
3. [Actividades y evaluación](actividades.md).
4. [Ampliación: PowerShell Remoting y xRDP](ampliacion.md).

## Entorno y conocimientos previos

Usaremos un servidor Ubuntu Server 24.04, un cliente Ubuntu Desktop 24.04 y una VM Windows 11 Pro, Education o Enterprise. Para la prueba Windows → Windows se necesita otro cliente Windows, que puede compartirse por parejas. Windows Home sirve como cliente RDP, pero no como servidor RDP.

Las VMs deben tener una red privada de laboratorio y acceso a repositorios para instalar paquetes. Conserva acceso a la consola del hipervisor. Reutiliza los conocimientos de [servicios de UD2](../UD2/GestiServicios.md) y las tareas de [UD5](../UD5/laboratorio.md); el recorrido básico no depende de LDAP.

## Sesiones previstas

| Sesión | Horas | Producto |
|---|---:|---|
| 1. Acceso SSH e identidad | 2 | Cuenta de laboratorio, huella verificada y conexiones Linux/Windows |
| 2. Claves y administración | 2 | Acceso por clave, restricción por usuario, copia comprobada y diagnóstico |
| 3. Escritorio remoto | 2 | RDP Windows → Windows y Linux → Windows, cuenta permitida y evidencia de sesión |
| 4. Túnel y caso final | 2 | Acceso a un servicio local por SSH, prueba negativa, recuperación y memoria |

Este reparto presupone VMs instaladas y red preparada. La ampliación queda fuera de esas ocho horas; si se asigna, debe ajustarse la planificación con el profesorado.

## Evidencias de RA4

La tabla relaciona las actividades con los criterios a–i del módulo 0374 del [RD 1629/2009](https://www.boe.es/eli/es/rd/2009/10/30/1629). Las etiquetas son resúmenes para organizar el trabajo.

| Criterio | Dónde se trabaja | Evidencia |
|---|---|---|
| a · Métodos remotos | Actividad 1 | Elección justificada de SSH, RDP y ejecución de órdenes |
| b · Sesiones y peticiones | Actividad 1 | Comparación entre terminal interactiva y orden remota puntual |
| c · Herramientas del sistema | Actividades 2 y 4 | OpenSSH y cliente RDP de Windows |
| d · Instalación del servicio | Actividad 2 | Paquete, servicio y puerto de SSH |
| e · Gestión por CLI y GUI | Actividades 2 y 4 | Configuración SSH y panel de Escritorio remoto |
| f · Cuentas de acceso | Actividades 2 y 4 | Cuenta Linux y usuario RDP con permisos delimitados |
| g · Sistemas heterogéneos | Actividades 2 y 4 | Windows → Linux por SSH y Linux → Windows por RDP |
| h · Transferencia cifrada | Actividades 3 y 5 | SCP y túnel con verificación de identidad |
| i · Registro de la intervención | Caso final | Configuración, resultado, incidencia y recuperación |

Una captura del escritorio o un puerto abierto no acreditan toda la unidad. Debes identificar usuario, equipo, servicio, mecanismo de autenticación y resultado de la administración.
