# UD5. Guía docente y soluciones orientativas

Esta guía acompaña a las actividades; los scripts del laboratorio son material inicial para el alumnado. Este archivo no aparece en el menú, pero MkDocs puede generar su página y hacerlo localizable. Si se necesita confidencialidad, debe distribuirse fuera del sitio público.

## Distribución sugerida

Dedicar 4 horas al informe, 5 a cron/at/KCron, 6 a timers, 4 a fiabilidad y cuentas y 5 al caso final. Preparar previamente una VM Server y otra Kubuntu con acceso a repositorios. Comprobar KCron antes de la sesión gráfica.

## Actividades 1 y 2

El diseño debe especificar tanto qué hacer como cómo detectar que no se ha hecho. La carga de `uptime` no equivale al porcentaje de CPU; la memoria disponible es más útil que la memoria libre aislada.

Calendarios solicitados:

```text
*/15 * * * *
30 8 * * 1-5
0 3 1 * *
```

`0 12 16 * Wed` se dispara los días 16 y los miércoles. Para exigir ambas condiciones, programar `0 12 16 * *` y colocar en el script una comprobación `[[ $(date +%u) -eq 3 ]] || exit 0` antes del trabajo. Al estar en el script, `%` no requiere escape de crontab.

La tabla del sistema incorpora la cuenta después de los cinco campos; la tabla de usuario no. El entorno mínimo debe seguir funcionando porque el script fija PATH y utiliza argumentos absolutos. El trabajo de at desaparece de la cola al despacharse, pero su desaparición no acredita éxito: se exige el registro y el resultado.

## Actividad 3

Aceptar variaciones de la interfaz según la versión de Plasma. Deben verse la tarea habilitada, las dos ejecuciones, el calendario modificado y la desactivación. La línea equivalente al calendario final es `0 9 * * 1-5 ...`. KCron edita la programación; cron ejecuta la tarea. No sustituir esta evidencia por un temporizador creado solo en terminal.

## Actividad 4

Los archivos y directivas necesarios están en el laboratorio. Verificar que cada copia del servicio contiene una única orden ExecStart y que los nombres del servicio y timer coinciden. Para ejecutar cada minuto durante la prueba, usar `OnCalendar=*-*-* *:*:00` y después restaurar el horario de producción.

Resultados esperados: timer activo/en espera, `Result=success`, `ExecMainStatus=0` y un resultado nuevo. El oneshot normalmente queda inactivo tras terminar. Si sigue activo, el timer no crea otra instancia de ese servicio; `flock` protege además frente a otros lanzadores que usen el mismo archivo de bloqueo.

Persistent recupera una activación de calendario omitida. La prueba de parada/reanudación debe empezar tras una ejecución automática ya registrada. No afirmar que se han simulado todos los efectos de un apagado real.

## Actividad 5

| Prueba | Resultado esperado | Corrección |
|---|---|---|
| Destino con modo 500 | Código 2 del script de copia; servicio fallido | Restaurar modo 700 y ejecutar de nuevo |
| nginx detenido | Código 1 y archivo de incidencia | Arrancar nginx; repetir; desaparece la incidencia |
| Bloqueo ocupado | Código 75; no se crea copia nueva | Esperar liberación y repetir |
| Sexta copia correcta | Cinco copias; conservar.txt intacto | No requiere corrección |
| Restauración | cmp devuelve 0 | Si difiere, revisar copia elegida y cambios del origen |

No aceptar como solución general «ejecutarlo todo como root». El grupo systemd-journal se justifica por lectura de registros; no permite escribir en el sistema.

## Actividad 6: solución de cuentas

```bash
#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
[[ $# -eq 1 && ( $1 == --simular || $1 == --aplicar ) ]] || {
    echo 'Uso: cuentas-prueba.sh --simular|--aplicar' >&2; exit 2;
}
modo=$1
cuentas=(ud5_prueba1 ud5_prueba2)
for cuenta in "${cuentas[@]}"; do
    id "$cuenta" >/dev/null 2>&1 || {
        echo "No existe la cuenta de prueba: $cuenta" >&2; exit 1;
    }
done
if [[ $modo == --aplicar && $EUID -ne 0 ]]; then
    echo 'La aplicación requiere root' >&2
    exit 1
fi
for cuenta in "${cuentas[@]}"; do
    if [[ $modo == --aplicar ]]; then
        chage -M 90 -W 7 "$cuenta"
        echo "$(date --iso-8601=seconds) Política aplicada: $cuenta"
    else
        echo "SIMULACIÓN: chage -M 90 -W 7 $cuenta"
    fi
done
```

Después de crear únicamente las dos cuentas del ejercicio:

```bash
sudo install -o root -g root -m 750 cuentas-prueba.sh /usr/local/lib/aso-ud5/cuentas-prueba.sh
sudo /usr/local/lib/aso-ud5/cuentas-prueba.sh --simular
sudo /usr/local/lib/aso-ud5/cuentas-prueba.sh --aplicar
sudo chage -l ud5_prueba1
sudo chage -l ud5_prueba2
printf '%s\n' '/usr/local/lib/aso-ud5/cuentas-prueba.sh --aplicar >> /root/ud5-cuentas.log 2>&1' | sudo at now + 2 minutes
sudo atq
```

La política debe mostrar máximo 90 y aviso 7; las cuentas nuevas siguen con la contraseña bloqueada. Repetir el script mantiene la política. Es una automatización limitada y verificable, no una herramienta para modificar todas las cuentas de una máquina.

## Corrección del caso final

Aplicar la rúbrica publicada y registrar RA3.a–h por separado. Solicitar al alumno que explique una línea de calendario, un permiso y un fallo. Comprobar que las fechas de ejecución pertenecen a su entrega y que `cmp` compara un archivo realmente extraído.

No confundir estas parejas: timer habilitado/tarea ejecutada; archivo tar creado/copia restaurada; tarea despachada/orden terminada con éxito; código 75/error de permisos.

## Validación técnica del material

Consultar el [registro de validación](validacion.md) para conocer qué comprobaciones se ejecutaron durante la preparación. La validación completa del aula requiere cron/at/systemd activos, Ubuntu Server y la sesión gráfica Kubuntu; la comprobación estática no sustituye esas pruebas.
