# Revisión de las unidades de ASO

Fecha: 9 de septiembre de 2026.

Revisión estática de estructura, navegación, teoría y ejemplos seleccionados de las unidades disponibles. Inventario: 52 documentos Markdown en UD1–UD4; UD5–UD7 tienen directorios vacíos. No equivale a una validación completa de todos los ejercicios: no se han desplegado máquinas virtuales, Docker, LXD ni clientes Windows. Los PDF, imágenes y paquetes ZIP no se han auditado internamente. Se conservan los cambios previos del repositorio.

## Resultado por unidad

| Unidad | Estado | Prioridad |
|---|---|---|
| UD1 — Scripting | Material amplio; errores en ejemplos Bash y PowerShell | Alta |
| UD2 — Procesos y servicios | Errores conceptuales y ejemplos de automatización que deben corregirse | Alta |
| UD3 — Directorio | Contenido desarrollado; secuencia de prácticas y nombres inconsistentes | Alta |
| UD4 — Integración | Buen desarrollo de permisos; faltan pasos esenciales en la práctica integrada | Alta |
| UD5 — Información y automatización | Vacía; parte del contenido está en UD2 | Alta |
| UD6 — Administración remota | Vacía; existe material parcial WMI/CIM en UD1 | Alta |
| UD7 — Impresión | Vacía; sin desarrollo propio | Alta |

## UD1

1. **Alta — Bucle de argumentos sin salida ante valores ausentes.** En `docs/UD1/linux/Argumentos.md:60–67`, ejecutar el ejemplo con `--usuario` sin valor hace fallar `shift 2` sin consumir argumentos. El bucle sigue repitiéndose. Validar que quedan dos argumentos antes de acceder a `$2` y salir con error si falta el valor. Revisar también `Actividades_Rapidas_Soluciones.md`.
2. **Alta — Ejemplos incorrectos de vectores PowerShell.** `docs/UD1/windows/024_PowerShell_VectoresFunciones.md:11` usa `@{}` para un vector vacío: es una tabla hash; corresponde `@()`. En la línea 28, el `for` usa `<` en lugar de `-lt` y no inicializa `$i`. Ejemplo corregido: `$EnterosFor = @(for ($i=0; $i -lt 5; $i++) { $i })`. Ambos errores están duplicados en `012_PowerShellTotal.md`. Véanse [arrays](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arrays?view=powershell-7.6) y [tablas hash](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7.6) de Microsoft.
3. **Media — Definición contradictoria de `until`.** `docs/UD1/linux/While_Until.md:5` dice que repite hasta que deje de cumplirse la condición; debe decir hasta que se cumpla. El desarrollo posterior sí lo explica correctamente.
4. **Media — Aritmética y argumentos.** En `Aritmetica.md`, `expr` no admite aritmética decimal; `length` no es soporte parcial de decimales. En `Argumentos.md`, los efectos de `$*` y `$@` deben explicarse junto con las comillas: la conservación de argumentos corresponde a `"$@"`.
5. **Media — Actividades Windows fuera del menú.** `mkdocs.yml` comenta el acceso a `windows/Actividades.md`. El alumnado dispone de teoría publicada, pero no de una entrada equivalente de prácticas Windows. Decidir qué actividades deben estar disponibles y enlazarlas.

## UD2

1. **Alta — Confusión entre zombi y huérfano.** `docs/UD2/procesosLinux.md:23` describe como zombi un hijo que sigue ejecutándose tras morir su padre. Eso describe un huérfano; el zombi ya terminó y conserva información de salida pendiente de recogida. Tampoco es correcto afirmar que todos los hijos terminan cuando termina el padre.
2. **Alta — Calendarios cron incorrectos.** En `programaTareas.md:65`, `5 * * * Sun` significa minuto 5 de cada hora del domingo. En las líneas 69–89 se interpreta como AND la combinación de día del mes y día de semana: cuando ambos están restringidos, cron tradicional los combina mediante OR. Esto puede disparar copias en días no previstos. El shell predeterminado tampoco se obtiene del shell de login del usuario. Corregir explicación y todos los ejemplos afectados según el [manual de cron de Debian](https://manpages.debian.org/trixie/cron/crontab.5.en.html).
3. **Alta — Destino de copia systemd incompleto.** En `programaTareas.md:174`, el servicio del sistema sin `User=` apunta a `/home/%u/copia_de_seguridad/backup.tar.gz`; no se prepara el directorio y no representa necesariamente el home del alumno. Definir cuenta, ruta absoluta y creación del destino, y probar el servicio manualmente antes del temporizador. Aclarar también que `tar -czf` sobrescribe el archivo, mientras la actividad pide «añadir».
4. **Alta — Cron de root sobre un script modificable por cualquiera.** `Actividades.md`, actividad 3.2, propone `chmod 777` y después `sudo crontab -e` con `~/Escritorio/script.sh`. Aunque pide explicar el riesgo, las instrucciones hacen ejecutar la configuración insegura; además `~` corresponde a root. Usar desde el inicio propietario, permisos y ruta absoluta coherentes con la cuenta que programa la tarea.
5. **Media — Documentación de credenciales.** `documeConfigSistema.md:10` pide guardar la contraseña del administrador en la documentación. Sustituirla por una referencia a la custodia de credenciales; las memorias entregadas no deben contener contraseñas. En la línea 18, corregir `dxdialog` a `dxdiag`.
6. **Media — Mezcla de objetivos.** Procesos, instalación, registro, contenedores y automatización comparten unidad. La navegación no incorpora `UD2/index.md` ni `documeConfigSistema.md`. Separar el itinerario principal de procesos/servicios y enlazar explícitamente el contenido de apoyo a UD5.

## UD3

1. **Alta — Herramienta equivocada en actividades.** `docs/UD3/actividades.md:69` pide PHPmyAdmin/phpmyadmin para administrar LDAP. El laboratorio usa phpLDAPadmin. Corregir nombre e instrucciones.
2. **Alta — Ruta de modificación inconsistente.** `docker-openldap.md:275` ejecuta `-f modificar.ldif`, pero el bloque proporcionado se titula `modificar-profesor.ldif`. Unificar para que pueda seguirse literalmente.
3. **Media — Identidades incompatibles entre materiales.** El ejemplo Docker crea `cn=profesor,ou=Usuarios,dc=asir,dc=local`; `ldif/20-posix-propiedades.ldif` modifica `uid=profesor,ou=People,dc=asir,dc=local`. El laboratorio general usa `dc=laboratorio,dc=local` y las actividades alternan empresa/asir. Son escenarios posibles, pero necesitan una tabla de correspondencias y una secuencia explícita; el LDIF no puede aplicarse directamente sobre la entrada del ejemplo Docker.
4. **Media — Login exigido antes de construir el entorno.** Las actividades exigen login LDAP antes de cualquier comando, pero más adelante piden crear VMs, servidor y TLS. Diferenciar preparación con administrador local y evidencias posteriores con usuario LDAP. El bloque 2 está duplicado.
5. **Media — Restauración de ACL insuficiente.** La actividad 14 propone `slapcat -b cn=config | grep olcAccess` como backup. Ese filtrado pierde los DN y puede perder continuaciones LDIF; no constituye una copia restaurable. Guardar un LDIF completo y documentar cómo recuperar la configuración.

## UD4

1. **Alta — Faltan credenciales Samba en la práctica integrada.** `docs/UD4/actividades.md:73–83` pasa de resolución de usuarios mediante SSSD a esperar acceso por `smbclient -U`. No configura cuentas/contraseñas Samba ni otro mecanismo de autenticación SMB. La propia teoría, en `teoria.md:366`, sí requiere `pdbedit -a` o `smbpasswd -a`. Incorporar este paso y distinguir resolución de identidad de autenticación.
2. **Alta — Home creado sin propietario.** En `actividades.md:68–71` se crea `/home/usuarios/alumno1` antes del login, pero no se asigna propietario a alumno1. Si lo crea root, `pam_mkhomedir` no resuelve por sí solo el directorio ya existente y la prueba de escritura puede fallar. Fijar propietario y modo antes de aplicar ACL y comprobar el acceso.
3. **Alta — Requisitos NFS ausentes en la práctica integrada.** En `actividades.md:85–93` se reinicia `nfs-kernel-server` sin indicar su instalación ni las condiciones de ejecución en LXD. El script alternativo sí instala paquetes y modifica opciones del contenedor; documentar qué escenario se usa y comprobar exportación y montaje en él.
4. **Media — Salida de permisos esperada incoherente.** `actividades.md:98` espera `drwxrws---+` tanto para la carpeta de grupo como para el home, pero al home no se le aplica setgid y el texto anterior pide modo 700. Dar resultados separados y explicar la máscara ACL.
5. **Media — Dos escenarios sin recorrido único.** El script crea `ud4-lab` y `ud4-client` con usuarios locales; las actividades usan un fileserver integrado con LDAP. Identificar el primero como laboratorio local de permisos y el segundo como integración, con requisitos y comprobaciones propios.

## UD5, UD6 y UD7

- **UD5:** directorio vacío. Reutilizar y revisar `UD2/programaTareas.md` y `UD2/documeConfigSistema.md`; añadir inventario, logs, automatización, pruebas y evidencias.
- **UD6:** directorio vacío. `UD1/windows/Estandares WMI-CIM.md` aporta material parcial, pero está comentado en el menú. Falta un recorrido de SSH, RDP y administración remota con pruebas de acceso.
- **UD7:** directorio vacío. Falta teoría, laboratorio de impresión, gestión de colas y pruebas desde clientes.
- El índice promete siete unidades, mientras `mkdocs.yml` publica cuatro. No basta con crear carpetas: faltan documentos, actividades y entradas de navegación.

## Incidencias transversales

- **Compilación no reproducible en este entorno.** `mkdocs build --strict --site-dir /tmp/aso-review-site` falla al resolver `materialx.emoji` en `mkdocs.yml:112`. No están instalados `material` ni `materialx`; no se puede atribuir el fallo únicamente al nombre del import. Documentar/fijar dependencias y repetir la compilación antes de cambiar la configuración.
- **Temporalización incoherente internamente.** El índice asigna 26 horas a UD1 entre el 8 y el 24 de septiembre mientras declara 4 horas semanales. También menciona festivos fuera del intervalo de UD5 y UD7. Recalcular las fechas con el horario real. Esta revisión no valida la normativa ni el calendario oficial.
- **Rúbrica ambigua.** `docs/index.md:130–131` incluye el 3 en dos bandas de IC2 (`1–3` y `3–6`). Definir intervalos sin solapamientos.
- **Plan anterior desactualizado.** El plan de julio dice que las carpetas UD5–UD7 no existen y que el índice aún requiere la actualización horaria; ahora existen vacías y el índice ya tiene cambios. Separar tareas realizadas, pendientes y verificadas.

## Comprobaciones realizadas

- Inventario de los 52 documentos Markdown de las unidades.
- Comprobación estática de destinos de enlaces Markdown relativos: no se localizaron rutas inexistentes con el comprobador empleado. No valida anclas, enlaces externos ni todas las variantes de sintaxis Markdown.
- `bash -n` sobre los nueve archivos `.sh` de las unidades: todos pasan. Esto solo verifica sintaxis, no funcionamiento ni permisos.
- Intento de compilación estricta MkDocs: bloqueado por dependencia ausente, antes de validar las páginas.
- Contraste documental de semántica cron y estructuras PowerShell mediante las fuentes enlazadas.

## Orden de resolución

1. Corregir los errores ejecutables de UD1–UD4 y las explicaciones de procesos/cron.
2. Completar y probar un recorrido LDAP → Samba con identidades, credenciales y permisos coherentes.
3. Desarrollar UD5–UD7 con actividades y evidencias, y publicarlas en navegación.
4. Ajustar temporalización y rúbrica; fijar dependencias de MkDocs y compilar.
5. Validar los laboratorios en los sistemas de referencia y registrar resultados reales antes de considerar las unidades listas para aula.
