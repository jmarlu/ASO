# Cómo funciona un servidor de impresión

## 1. Del documento al dispositivo

La aplicación produce un documento. El cliente envía un trabajo a una impresora lógica. El servidor conserva el trabajo en su spool, aplica opciones y filtros y lo entrega a un dispositivo físico o virtual mediante un backend. El estado final y los registros permiten investigar el resultado.

| Elemento | Función | Ejemplo del laboratorio |
|---|---|---|
| Impresora lógica o cola | Nombre, opciones y trabajos pendientes | `aula_pdf` |
| Dispositivo | Destino del trabajo procesado | Backend `cups-pdf:/` |
| Filtro/controlador | Conversión a un formato aceptado | Conversión a PostScript/PDF en CUPS-PDF |
| Spooler | Recepción, orden y gestión de trabajos | CUPS / Windows Print Spooler |
| Clase o agrupación | Destino que distribuye a impresoras miembros disponibles | `clase_aula` |

Dos colas pueden apuntar al mismo dispositivo. Eso permite configuraciones diferentes, pero no crea dos impresoras físicas ni garantiza tolerancia a fallos. Una clase de dos colas hacia el mismo backend solo simula la agrupación.

## 2. Protocolos y puertos

| Protocolo | Puerto habitual | Uso y límites |
|---|---|---|
| IPP / IPPS | TCP 631 habitualmente | Trabajos, atributos y estados; IPPS utiliza TLS |
| HTTP/HTTPS de CUPS | TCP 631 | Interfaz web del servidor; no implica abrir su administración a toda la red |
| LPD/LPR | TCP 515 | Integración heredada; protección limitada por sí sola |
| AppSocket / JetDirect | TCP 9100 | Entrega directa al dispositivo; normalmente sin autenticación/cifrado propios |
| SMB y servicios Windows | TCP 445 y, según gestión, RPC | Compartición Windows; las reglas necesarias dependen del método y versión |
| DNS-SD/mDNS | UDP 5353 | Descubrimiento; no transporta el documento de impresión |

Una URL `ipp://servidor/printers/cola` identifica un recurso de impresión; `http://servidor:631` abre una interfaz web. Consultar una página no demuestra que el cliente pueda enviar un formato imprimible. Para esta práctica IPP se limita a la red privada y se usan documentos ficticios. Antes de transportar documentos reales deben definirse autenticación y cifrado de extremo a extremo.

## 3. CUPS y Windows

CUPS ofrece administración web, utilidades de terminal y colas accesibles por IPP. La impresión sin controlador específico consulta las capacidades del destino mediante IPP Everywhere; evita instalar un PPD propio de cada modelo. CUPS-PDF es un backend virtual del laboratorio y conserva un flujo con PPD. Las [opciones de administración de CUPS](https://www.cups.org/doc/man-lpadmin.html) distinguen estos modelos y advierten de la retirada futura de los controladores tradicionales.

Windows dispone del servicio Spooler, el panel de impresoras y comandos del módulo PrintManagement. Un cliente puede conectarse a un servidor CUPS por IPP, siempre que las capacidades y formatos sean compatibles. Microsoft Print to PDF guarda un PDF local; seleccionarlo no prueba impresión hacia CUPS. La [ampliación Windows](windows.md) trata un servidor de colas propio.

## 4. Estados que debes distinguir

| Operación | Efecto |
|---|---|
| Pausar/deshabilitar la impresora | Detiene el procesamiento; puede seguir admitiendo trabajos |
| Rechazar trabajos | Impide nuevas entregas; no borra automáticamente las pendientes |
| Retener un trabajo | Conserva un trabajo concreto sin procesarlo todavía |
| Cancelar | Retira el trabajo seleccionado |
| Reanudar/habilitar | Permite volver a procesar los pendientes |

En CUPS se usan `cupsdisable`, `cupsenable`, `cupsreject`, `cupsaccept`, `lp -i` y `cancel`. El manual de [impresión por terminal](https://www.cups.org/doc/options.html) explica las opciones de los trabajos. Anota el identificador exacto devuelto por `lp`; evita cancelar todos los trabajos para resolver uno.

## 5. Permisos y grupos

El grupo administrativo `lpadmin` de Ubuntu permite administrar CUPS. No debes añadir a todo el alumnado a ese grupo para que pueda imprimir. Una **clase CUPS** agrupa destinos; un **grupo UNIX** agrupa personas y puede intervenir en una política de acceso. Son conceptos diferentes.

Una lista de nombres permitidos no autentica por sí sola al solicitante. Para imponer autorizaciones por usuario se necesita una política que autentique, un transporte protegido y cuentas verificables. `lp -U nombre` indica el usuario solicitado: no demuestra su identidad si el servidor no exige autenticación. La [guía de compartición de CUPS](https://www.cups.org/doc/sharing.html) incluye políticas autenticadas.

La práctica básica prueba la compartición en una subred aislada y la separación entre administración e impresión. La protección por grupo se plantea como ampliación docente, con prueba positiva y negativa autenticadas.

## 6. Diagnóstico por etapas

1. ¿El cliente alcanza el servidor y TCP 631?
2. ¿Existe el destino y admite trabajos?
3. ¿Está habilitado o hay trabajos retenidos?
4. ¿El filtro admite el formato recibido?
5. ¿El backend genera una salida y puede escribir en su directorio?
6. ¿El resultado contiene el documento esperado?

Consulta `lpstat`, el estado de CUPS y sus registros. Un PDF ausente puede deberse a un trabajo todavía retenido, un fallo de filtro o a buscarlo en el home equivocado. El historial y el spool pueden contener datos de los documentos: recoge solo las evidencias de prueba necesarias.
