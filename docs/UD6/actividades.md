# Actividades y evaluación de UD6

Realiza las actividades en las VMs del [laboratorio](laboratorio.md). Los resultados esperados sirven para comprobar tus pruebas; documenta también lo que falle y cómo lo recuperas.

## 1. Elegir el método de administración

Para cada caso, elige herramienta, cuenta, puerto y evidencia del resultado:

1. Consultar servicios fallidos en un servidor Linux sin escritorio.
2. Resolver una incidencia que solo puedes reproducir en una interfaz gráfica Windows.
3. Transferir una memoria de práctica y comprobar su integridad.
4. Acceder desde tu cliente a una aplicación que solo escucha en el loopback del servidor.

Compara una terminal SSH mantenida durante diez minutos con la ejecución puntual `ssh ... 'uptime'`. Explica qué estado conserva cada forma de trabajo y por qué ambas autentican al cliente y protegen el transporte.

**Evidencia:** tabla de decisiones y explicación de sesión interactiva/petición puntual. Criterios RA4.a–b.

## 2. Implantar SSH y limitar usuarios

1. Instala el servicio, crea `asoadmin` y demuestra paquete, escucha y grupos.
2. Contrasta la huella del servidor desde la consola y ambos clientes.
3. Genera una clave diferente por cliente y registra sus claves públicas.
4. Aplica el fragmento de configuración, valida sintaxis y configuración efectiva.
5. Demuestra conexión Linux → Linux y Windows → Linux por clave, y rechazo de contraseña.
6. Explica cómo recuperarías el acceso desde la consola sin borrar toda la configuración.

**Evidencia:** configuración sin secretos, consultas de validación, identidad remota y registro del intento rechazado. No entregues claves privadas. Criterios RA4.c–d–e–f–g–h.

## 3. Transferir y administrar

Transfiere `prueba.txt` por SCP y demuestra la igualdad de hashes. Modifica su contenido, simula una sincronización con rsync y explica la diferencia entre copiar el directorio y su contenido. Consulta un servicio remoto y realiza una intervención pequeña autorizada por el docente, por ejemplo recargar una configuración ya validada. Registra estado previo y posterior.

**Evidencia:** archivo, hashes, simulación y transcripción de la intervención. Criterios RA4.c–e–h–i.

## 4. Gestionar una sesión RDP

1. Crea la cuenta estándar `asoremoto`, autorízala y comprueba NLA y ámbito del firewall.
2. Accede desde Windows y desde Linux, de forma secuencial.
3. Identifica el equipo remoto y consulta el servicio Spooler con interfaz y PowerShell.
4. Verifica el rechazo de una cuenta estándar sin autorización RDP.
5. Explica la diferencia entre desconectar la ventana y cerrar la sesión del usuario.

**Evidencia:** configuración, conexiones desde ambos sistemas y prueba negativa. Criterios RA4.c–e–f–g–h–i.

## 5. Publicar un acceso temporal por túnel

Monta el servidor HTTP de prueba en el loopback de srv-linux y accede por un túnel ligado al loopback del cliente. Demuestra que funciona con el túnel, que el puerto del servidor no es accesible directamente por la red y que el acceso local deja de funcionar al cerrarlo. Explica los dos significados de `127.0.0.1` en la orden SSH.

**Evidencia:** puertos de escucha, página obtenida y resultado tras el cierre. Criterios RA4.a–e–h–i.

## 6. Caso final: intervención remota reproducible

Entrega una memoria con este recorrido: identificar el servidor, entrar por clave, consultar un servicio, transferir una evidencia, acceder a Windows con cuenta restringida y cerrar las conexiones. Incluye una incidencia reproducida por ti, su diagnóstico y la recuperación. Puede ser una clave pública ausente en una cuenta de prueba o una conexión a un puerto incorrecto; conserva la consola y una vía de acceso válida.

Organización propuesta:

```text
ud6_entrega/
  memoria.md (o PDF)
  configuracion/
  evidencias/ssh/
  evidencias/transferencia/
  evidencias/rdp/
  evidencias/tunel/
  incidencias.md
```

## Rúbrica

| Apartado | Peso | Evidencia para puntuación completa |
|---|---:|---|
| Elección y explicación | 10 % | Métodos, puertos y distinción de modos de sesión |
| SSH y cuentas | 25 % | Instalación, claves, configuración efectiva y rechazo esperado |
| Administración y transferencia | 20 % | Intervención verificable y hashes iguales |
| RDP e interoperabilidad | 20 % | Dos orígenes, usuario estándar, NLA y prueba negativa |
| Túnel y recuperación | 15 % | Escuchas correctas, acceso temporal y recuperación explicada |
| Documentación | 10 % | Entorno, órdenes, resultados y retirada reproducibles |

Por apartado: 0 % del peso si falta o es incorrecto; 50 % si está incompleto o sin validar; 100 % si cumple y se explica. La suma puntúa la entrega. El docente registra por separado las evidencias de RA4.a–i; una media no sustituye criterios ausentes. Se mantiene el 9 % de RA4 en la evaluación del módulo.

## Comprobación antes de entregar

- [ ] He distinguido equipo cliente y equipo remoto en las capturas.
- [ ] He probado las conexiones desde los sistemas requeridos.
- [ ] He verificado la clave de host y protegido las claves privadas.
- [ ] La prueba negativa falla por el motivo previsto y queda registrada.
- [ ] Los hashes coinciden y sé explicar el túnel.
- [ ] He cerrado sesiones y retirado accesos temporales.

**Ampliación opcional:** [PowerShell Remoting y xRDP](ampliacion.md), con evidencias adicionales. No sustituye las pruebas básicas.
