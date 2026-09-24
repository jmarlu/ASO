# Actividades y evaluación de UD7

Completa el [laboratorio de CUPS](laboratorio.md) con documentos de prueba. Registra el nombre del cliente, el servidor, la cola y el identificador de cada trabajo utilizado como evidencia.

## 1. Explicar el recorrido de impresión

Dibuja o describe la secuencia aplicación → cliente → cola → filtro → backend → resultado. Sitúa en ella un fallo de red, una cola pausada y un formato incompatible. Compara IPP, LPD, SMB y AppSocket indicando puerto habitual y protección. Explica por qué compartir una carpeta con un PDF no equivale a compartir una impresora.

**Evidencia:** esquema y tabla de protocolos. Criterios RA5.a–b.

## 2. Instalar y clasificar destinos

1. Instala CUPS y CUPS-PDF, registra las versiones y el modelo utilizado.
2. Crea `aula_pdf` y `reserva_pdf`, con descripción y ubicación.
3. Explica por qué son dos impresoras lógicas hacia un backend virtual.
4. Administra CUPS por navegador a través del túnel SSH y consulta opciones por terminal.
5. Envía una prueba desde Linux y verifica el contenido del PDF generado.

**Evidencia:** paquete, modelo, URI, colas, interfaz web, trabajo y PDF. Criterios RA5.c–d–e–g.

## 3. Gestionar grupo y trabajos

1. Crea `clase_aula` con las dos impresoras y muestra sus miembros.
2. Pausa una impresora y demuestra que admite un trabajo pendiente; reanúdala y verifica la salida.
3. Retén un trabajo concreto y cancélalo por su identificador.
4. Repite una pausa/reanudación y una retención/liberación desde la interfaz web.
5. Rechaza nuevos trabajos, demuestra el fallo de envío y restaura la aceptación.
6. Envía a la clase con un miembro pausado y comprueba qué destino procesó el trabajo.

Explica la diferencia entre clase de impresoras, grupo UNIX de usuarios y grupo `lpadmin`. No presentes dos colas que usan el mismo backend como alta disponibilidad física.

**Evidencia:** tabla antes/acción/después con identificadores y PDF cuando corresponda. Criterios RA5.e–f–g.

## 4. Compartir entre Linux y Windows

Añade la cola IPP en Windows, registra URL, controlador y versión. Imprime el archivo de prueba con el nombre del cliente añadido. Localiza el mismo trabajo en el servidor y abre su PDF. Explica dónde queda el archivo si CUPS-PDF no puede resolver el usuario recibido.

**Evidencia:** configuración Windows, trabajo recibido en CUPS y contenido final. Un puerto abierto o una impresora añadida sin impresión real no acreditan RA5.h. Si la combinación de controlador/versiones no funciona, registra el fallo y completa la prueba cuando el docente prepare el cliente; no lo marques como superado.

## 5. Caso final: recuperar una cola de aula

El docente deja `aula_pdf` pausada o rechazando trabajos, sin avisarte de cuál es el estado. Diagnostica desde un cliente y desde el servidor, explica la diferencia y recupera el servicio. Envía una nueva prueba con título que permita identificarla. Recoge solo los registros relevantes y devuelve el entorno al estado acordado.

Entrega:

```text
ud7_entrega/
  memoria.md (o PDF)
  configuracion/
  evidencias/linux/
  evidencias/windows/
  evidencias/colas/
  resultados/pdf-de-prueba/
  incidencia.md
```

Incluye mapa de red, versiones, colas y miembros, pasos de administración, las pruebas de ambos clientes, la incidencia y la retirada. No entregues el spool completo del servidor.

## Rúbrica

| Apartado | Peso | Evidencia para puntuación completa |
|---|---:|---|
| Arquitectura y protocolos | 15 % | Recorrido, puertos y elección razonada |
| Servidor y administración web | 25 % | Servicio operativo, dos colas y PDF local verificable |
| Clase y gestión de trabajos | 25 % | Miembros, pausa/reanudación, rechazo y cancelación por CLI/GUI |
| Cliente Windows y compartición | 20 % | Trabajo heterogéneo y PDF correcto |
| Diagnóstico y documentación | 15 % | Fallo identificado, recuperación y memoria reproducible |

Por apartado: 0 % del peso si falta o es incorrecto; 50 % si funciona parcialmente o falta comprobación; 100 % si cumple y se explica. El docente registra evidencias de RA5.a–i por separado. La rúbrica no modifica el 5 % que representa RA5 en el módulo.

## Comprobación antes de entregar

- [ ] Distingo cola, dispositivo, clase y grupo de usuarios.
- [ ] Puedo mostrar trabajos concretos y sus resultados.
- [ ] He probado tanto terminal como interfaz gráfica.
- [ ] El documento de Windows llegó al servidor Linux.
- [ ] La cola vuelve a estar habilitada y aceptando trabajos.
- [ ] He cerrado el túnel y documentado qué recursos se conservan.

**Ampliación opcional:** [servidor de impresión Windows](windows.md). Requiere otra sesión y no sustituye la prueba de interoperabilidad de esta unidad.
