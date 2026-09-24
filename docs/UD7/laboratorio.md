# Laboratorio: impresión compartida sin impresora física

## 1. Entorno

Usa `srv-linux` (Ubuntu Server 24.04, `10.50.0.10`), `cli-linux` (`10.50.0.20`) y `win-remoto` (`10.50.0.30`) del [laboratorio UD6](../UD6/laboratorio.md). Necesitas el acceso SSH por clave y la cuenta `asoadmin` en el servidor. Si partes de VMs nuevas, completa antes esos pasos o pide al docente las imágenes preparadas.

Guarda una instantánea. Descarga [prueba.ps](lab/prueba.ps) en cli-linux y [prueba-windows.txt](lab/prueba-windows.txt) en Windows; colócalos en una carpeta `ud7` de cada cliente. No uses documentos reales para la prueba.

## 2. Instalar CUPS y el destino virtual

En **srv-linux**:

```bash
sudo apt update
sudo apt install cups cups-client cups-filters printer-driver-cups-pdf ghostscript
sudo systemctl enable --now cups
sudo usermod -aG lpadmin asoadmin
dpkg-query -W cups printer-driver-cups-pdf
sudo lpinfo -v
lpinfo -m | grep -i 'cups-pdf'
```

Abre una sesión nueva como `asoadmin` y verifica `id`. El paquete puede crear una cola llamada `PDF`; no la confundas con las colas que vas a crear. Identifica el modelo disponible para CUPS-PDF y guárdalo en la variable `modelo_pdf`:

```bash
modelo_pdf=$(lpinfo -m | awk 'tolower($0) ~ /cups-pdf/ {print $1; exit}')
echo "$modelo_pdf"
```

**No continúes si está vacío.** Comprueba que el paquete se instaló y que existe un backend `cups-pdf:/` en la salida de `lpinfo -v`. El identificador del modelo se obtiene del equipo, no se inventa una ruta PPD.

```bash
sudo lpadmin -p aula_pdf -E -v cups-pdf:/ -m "$modelo_pdf" -D 'PDF principal ASO' -L 'Servidor del aula'
sudo lpadmin -p reserva_pdf -E -v cups-pdf:/ -m "$modelo_pdf" -D 'PDF reserva ASO' -L 'Servidor del aula'
lpstat -p -v
lpoptions -p aula_pdf -l
```

En estas órdenes `-E` aparece después de `-p` y habilita la cola y su aceptación de trabajos. En otras posiciones puede solicitar cifrado de la conexión administrativa: importa dónde lo escribes.

El backend produce PDF. Consulta las rutas de salida en `/etc/cups/cups-pdf.conf`: `Out` para cuentas que resuelve el servidor y `AnonDirName` para usuarios no resueltos. Las líneas comentadas documentan valores por defecto. En Ubuntu suelen ser `${HOME}/PDF` y `/var/spool/cups-pdf/ANONYMOUS`; verifica lo que usa tu paquete. No cambies permisos del backend ni desactives AppArmor para resolver un fallo.

## 3. Compartir las dos colas

En srv-linux, guarda una copia de configuración antes de cambiar la compartición:

```bash
sudo cp -a /etc/cups/cupsd.conf /etc/cups/cupsd.conf.ud7.bak
sudo cupsctl --share-printers
sudo lpadmin -p aula_pdf -o printer-is-shared=true
sudo lpadmin -p reserva_pdf -o printer-is-shared=true
sudo cupsctl
sudo ss -ltnp 'sport = :631'
```

`--share-printers` permite por defecto compartir con la misma subred. No uses `--remote-any` ni habilites administración remota global. En una VM con varias interfaces revisa `/etc/cups/cupsd.conf`: sustituye una eventual escucha global `Port 631` por estas escuchas TCP, conservando la escucha del socket UNIX si existe:

```text
Listen 127.0.0.1:631
Listen 10.50.0.10:631
```

No dejes a la vez una escucha global y las específicas. Valida antes de reiniciar:

```bash
sudo /usr/sbin/cupsd -t
sudo systemctl restart cups
sudo ss -ltnp 'sport = :631'
```

Si UFW está activo, añade `sudo ufw allow from 10.50.0.0/24 to 10.50.0.10 port 631 proto tcp`. Comprueba que no haya una regla previa más amplia que permita el mismo puerto. Conserva la autorización SSH de UD6.

## 4. Administrar por navegador a través de SSH

En **cli-linux**, mantén este túnel en una terminal:

```bash
ssh -i ~/.ssh/id_ed25519_aso -o ExitOnForwardFailure=yes -N -L 127.0.0.1:8631:127.0.0.1:631 asoadmin@10.50.0.10
```

Abre `http://127.0.0.1:8631` en el navegador del cliente. Accede a **Administration** con la cuenta `asoadmin` cuando se solicite. Si CUPS exige HTTPS, utiliza `https://127.0.0.1:8631` y contrasta el certificado del servidor; el túnel termina en ese mismo CUPS. La conexión HTTP interior viaja por loopback y por el túnel cifrado, no como administración HTTP abierta a toda la red.

Localiza ambas impresoras, consulta opciones y trabajos. Captura la administración web y explica por qué entrar al sitio no concede por sí solo privilegios de administrador. Mantén el túnel abierto para las pruebas gráficas posteriores.

## 5. Enviar desde Linux y comprobar el PDF

En **cli-linux**, instala `cups-client` y sitúate en la carpeta donde guardaste `prueba.ps`:

```bash
sudo apt install cups-client
lpstat -h 10.50.0.10:631 -p
lp -h 10.50.0.10:631 -d aula_pdf -t 'ud7-linux-inicial' prueba.ps
lpstat -h 10.50.0.10:631 -W not-completed -o aula_pdf
```

Anota el identificador devuelto, por ejemplo `aula_pdf-7`. El número variará. En el servidor consulta `lpstat -W completed -o aula_pdf`, identifica el usuario del trabajo y busca el PDF en la ruta que le corresponda según CUPS-PDF. Si el usuario del cliente no existe en el servidor, revisa la salida anónima indicada por `AnonDirName`.

Recupera el PDF desde su ruta concreta mediante SCP con una cuenta autorizada, o ábrelo en el escritorio del servidor si dispone de él. Si solo el administrador puede leerlo, prepara una copia de **ese archivo de prueba** para `asoadmin`, con propietario `asoadmin` y modo 600; no abras permisos sobre todos los PDFs. Verifica el título y las tres líneas de texto. Trabajo completado y contenido correcto son dos evidencias diferentes.

## 6. Pausa, reanudación, retención y cancelación

En srv-linux:

```bash
sudo cupsdisable aula_pdf
lpstat -p aula_pdf
```

Desde cli-linux envía otra vez `prueba.ps` con título `ud7-pausa`. Consulta la cola: el trabajo queda pendiente porque la impresora está pausada. En srv-linux ejecuta `sudo cupsenable aula_pdf` y comprueba que se procesa y genera un PDF.

Para poder cancelar un trabajo sin competir con una impresión rápida, retenlo al enviarlo desde cli-linux:

```bash
lp -h 10.50.0.10:631 -d aula_pdf -H hold -t 'ud7-cancelar' prueba.ps
lpstat -h 10.50.0.10:631 -W not-completed -o aula_pdf
```

Anota su identificador y, como propietario o administrador, ejecuta `cancel -h 10.50.0.10:631 ID_REAL`. Sustituye `ID_REAL` por ese trabajo, sin usar `-a`. Demuestra su desaparición de los pendientes y que no se produjo su PDF.

Desde el navegador, repite una pausa y reanudación sobre `reserva_pdf` y retén/libera un trabajo de prueba. Si la interfaz pide autenticación, utiliza `asoadmin`. Conserva el identificador del trabajo en la captura.

Finalmente, en srv-linux prueba:

```bash
sudo cupsreject aula_pdf
lpstat -a aula_pdf
```

Un nuevo envío desde cli-linux debe ser rechazado. Restablece la aceptación con `sudo cupsaccept aula_pdf` y repite con éxito. Explica por qué «pausada» y «rechaza trabajos» no significan lo mismo.

## 7. Crear una clase de impresión

En srv-linux:

```bash
sudo lpadmin -p aula_pdf -c clase_aula
sudo lpadmin -p reserva_pdf -c clase_aula
sudo cupsenable clase_aula
sudo cupsaccept clase_aula
sudo lpadmin -p clase_aula -o printer-is-shared=true
lpstat -c clase_aula
```

Envía desde cli-linux con `lp -h 10.50.0.10:631 -d clase_aula -t 'ud7-clase' prueba.ps`. Comprueba los miembros, el trabajo y la salida. Pausa `aula_pdf`, vuelve a enviar a la clase y observa el procesamiento mediante el miembro disponible; después reanuda `aula_pdf`.

Las dos colas apuntan al mismo backend PDF: esta prueba demuestra agrupación y selección de destinos, no redundancia física. Documenta también la diferencia entre `clase_aula` y el grupo administrativo `lpadmin`.

## 8. Cliente Windows por IPP

En **win-remoto**, registra versión de Windows y consulta desde PowerShell:

```powershell
Test-NetConnection 10.50.0.10 -Port 631
Get-Command Add-Printer -Syntax
```

Si el comando dispone del parámetro `IppURL`, en PowerShell elevado añade la conexión:

```powershell
Add-Printer -Name 'ASO-CUPS' -IppURL 'http://10.50.0.10:631/printers/aula_pdf'
Get-Printer -Name 'ASO-CUPS' | Format-List Name,DriverName,PortName,PrinterStatus
```

También puedes usar **Configuración → Bluetooth y dispositivos → Impresoras y escáneres → Agregar manualmente** y la URL anterior como impresora compartida. Los diálogos dependen de la versión. La referencia de [Add-Printer](https://learn.microsoft.com/en-us/powershell/module/printmanagement/add-printer?view=windowsserver2025-ps) distingue conexión IPP, puerto y conexión a recurso Windows.

El driver IPP y CUPS deben acordar un formato. Si la VM no admite ese destino automáticamente, el docente debe preparar en ella un controlador PostScript firmado compatible con la cola CUPS-PDF y seleccionar la URL con el asistente. No elijas al azar un modelo PCL ni una cola «raw»: que se añada una impresora no garantiza que produzca PDF. Registra como pendiente la prueba hasta que se valide esa combinación de versiones y controlador.

Abre `prueba-windows.txt`, completa el nombre de tu VM e imprime en **ASO-CUPS**. Anota hora e identificador, observa el trabajo en CUPS y verifica que el PDF del servidor contiene el texto editado. Antes del envío puedes pausar `aula_pdf` desde CUPS para observar la cola con calma; reanúdala al terminar. Una impresión local en Microsoft Print to PDF no satisface esta comprobación.

## 9. Diagnóstico y retirada

En srv-linux:

```bash
systemctl status cups --no-pager
lpstat -t
sudo journalctl -u cups --since '-15 minutes' --no-pager
sudo tail -n 30 /var/log/cups/error_log
```

Si necesitas detalle temporal, activa `sudo cupsctl --debug-logging`, reproduce **un** trabajo de prueba, recoge el error y desactívalo con `sudo cupsctl --no-debug-logging`. Si faltan PDFs revisa también la configuración y el registro propio de CUPS-PDF; no reinstales toda la VM sin localizar la etapa que falla.

Tras guardar las evidencias, cancela solo tus trabajos pendientes, cierra el túnel y retira ASO-CUPS en Windows si no va a reutilizarse. En una VM compartida elimina únicamente las colas creadas aquí:

```bash
sudo lpadmin -x clase_aula
sudo lpadmin -x aula_pdf
sudo lpadmin -x reserva_pdf
```

No retires la cola `PDF` creada por el paquete ni otras colas ajenas. Restaura la configuración de compartición y las reglas de firewall a partir de lo registrado, o vuelve a la instantánea inicial si la VM es exclusiva de esta práctica. Conserva únicamente los PDFs de prueba necesarios para la entrega.
