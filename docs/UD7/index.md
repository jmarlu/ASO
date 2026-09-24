# UD7. Administración de servidores de impresión

**Previsión: 4 horas. Resultado principal: RA5. Peso en el módulo: 5 %.**

Una impresora compartida es un servicio: recibe trabajos, los coloca en una cola, convierte los documentos y entrega un resultado. Aprenderás a instalarlo, compartirlo entre Linux y Windows y resolver trabajos retenidos o rechazados.

## Recorrido

1. [Teoría: colas, protocolos y permisos](teoria.md).
2. [Laboratorio: CUPS e impresión virtual](laboratorio.md).
3. [Actividades y evaluación](actividades.md).
4. [Ampliación: servidor de impresión Windows](windows.md).

## Requisitos

Servidor Ubuntu Server 24.04, cliente Ubuntu Desktop y cliente Windows 11 de [UD6](../UD6/laboratorio.md), en la misma red privada. No necesitas impresora física: CUPS-PDF genera documentos PDF en el servidor. Utiliza archivos de prueba, ya que el spool y la salida PDF pueden conservar copias.

El laboratorio se refiere a **CUPS 2.4 y al paquete `printer-driver-cups-pdf` de Ubuntu 24.04**. Ese backend utiliza un controlador PPD; se usa como dispositivo virtual de aula. Para impresoras modernas se estudia IPP Everywhere y la impresión sin controlador específico. No asumas que una futura versión de CUPS conserva el mismo flujo PPD.

## Sesiones previstas

| Sesión | Horas | Resultado |
|---|---:|---|
| 1. Servidor y colas | 2 | CUPS, PDF de prueba, dos impresoras lógicas y una clase |
| 2. Clientes e incidencias | 2 | Impresión desde Linux/Windows, pausa/cancelación, diagnóstico y memoria breve |

Se parte de VMs instaladas, repositorios disponibles y del acceso SSH de UD6. El docente debe probar previamente la conexión IPP del cliente Windows concreto. La instalación de un servidor Windows adicional es una ampliación, fuera de las cuatro horas.

## Evidencias de RA5

La correspondencia resume los criterios a–i del módulo 0374 del [RD 1629/2009](https://www.boe.es/eli/es/rd/2009/10/30/1629).

| Criterio | Actividad | Evidencia |
|---|---|---|
| a · Función del servicio | 1 | Recorrido documento → cola → resultado |
| b · Puertos y protocolos | 1 | IPP, LPD, SMB y AppSocket comparados |
| c · Herramientas del sistema | 2 y 4 | `lp`, `lpstat` y panel de impresoras Windows |
| d · Administración web | 2 | CUPS instalado y administración por navegador |
| e · Impresoras lógicas | 2 | Dos colas identificadas y sus dispositivos |
| f · Grupos de impresión | 3 | Clase CUPS y miembros; diferencia frente a grupo de usuarios |
| g · Gestión de trabajos | 3 | Pausa, reanudación, rechazo y cancelación mediante CLI/GUI |
| h · Compartición heterogénea | 4 | Trabajo Windows recibido por CUPS y resultado PDF |
| i · Documentación | 5 | Configuración, clientes y recuperación |

Que desaparezca un trabajo de la cola no basta para demostrar impresión: comprueba el PDF y su contenido. El peso de RA5 sigue siendo el 5 % del módulo.
