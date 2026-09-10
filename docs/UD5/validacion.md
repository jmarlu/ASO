# Validación técnica de UD5

Fecha: 10 de septiembre de 2026.

## Comprobaciones realizadas

| Comprobación | Resultado |
|---|---|
| Sintaxis Bash de los tres scripts y de la solución de cuentas | Correcta |
| Argumentos ausentes | Los tres scripts devuelven 2 |
| Copia de ruta con espacios y lectura del contenido restaurable | Correcta; contenido del archivo de prueba idéntico |
| Seis copias consecutivas | Se conservan cinco; un archivo ajeno permanece intacto |
| Destino igual al origen o contenido en él | Rechazado con código 2 |
| Bloqueo de copia ocupado | Rechazado con código 75 |
| Destino sin escritura con cuenta no privilegiada | Rechazado con código 2 |
| Informe con permisos privados | Generado con modo 600 y secciones esperadas |
| Servicio inexistente | Código 1 y archivo de incidencia |
| Servicio activo y una incidencia de prueba previa | Código 0 y retirada de la incidencia |
| Seis unidades systemd | `systemd-analyze verify` sin errores |
| Calendarios diario 08:00, diario 02:30 y cada minuto | `systemd-analyze calendar` los acepta |
| Sitio MkDocs completo | Compilación estricta correcta |

Las pruebas de scripts se ejecutaron en directorios temporales. La comprobación de servicio fue de solo lectura: no se detuvieron servicios del equipo anfitrión. Para verificar las unidades sin instalar el laboratorio, únicamente se adaptó su ejecutable a `bash` y a la ruta local del script; no se arrancaron esas unidades.

## Comprobaciones pendientes en el entorno del aula

El material contiene las instrucciones y resultados esperados, pero no se ha validado aquí el recorrido completo sobre las VMs Ubuntu Server/Kubuntu:

- Disparos reales de cron y at con la cuenta `asoauto`.
- Arranque de los servicios con sus restricciones y recuperación persistente del timer.
- Instalación e interacción gráfica con KCron.
- Aplicación de política a las cuentas `ud5_prueba1` y `ud5_prueba2`.
- Simulación de apagado real y de parada/recuperación de nginx en la VM.

Estas pruebas deben registrarse al preparar el aula. No se presentan como ejecutadas a partir de una comprobación de sintaxis.

## Reproducir la compilación

Desde la raíz del repositorio, en un entorno Python separado:

```bash
python3 -m venv /tmp/aso-docs-venv
/tmp/aso-docs-venv/bin/pip install 'mkdocs==1.6.1' 'mkdocs-material==9.7.7'
/tmp/aso-docs-venv/bin/mkdocs build --strict --site-dir /tmp/aso-docs-site
```

Se utilizó MkDocs 1.6.1 y Material 9.7.7. Las páginas fuera del menú producen avisos informativos, pero también pueden generarse y localizarse: la guía docente no debe considerarse privada por estar fuera de la navegación.
