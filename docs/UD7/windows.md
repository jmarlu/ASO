# Ampliación: servidor de impresión Windows

Este recorrido permite comparar CUPS con un spooler Windows. Requiere una VM adicional Windows Server 2022/2025 con interfaz gráfica, un cliente Windows y una red privada preparada. No se cuenta dentro de las cuatro horas del laboratorio principal.

## 1. Instalar y consultar el rol

En PowerShell elevado del **servidor Windows**:

```powershell
Install-WindowsFeature Print-Server -IncludeManagementTools
Get-WindowsFeature Print-Server
Get-Service Spooler
Get-Printer
Get-PrinterDriver
```

Si se solicita reinicio, complétalo antes de continuar. Abre **Administración de impresión** (`printmanagement.msc`) y localiza el servidor, controladores, puertos e impresoras. El objetivo es gestionar una cola compartida, no desplegar servicios de Escritorio remoto.

## 2. Destino de prueba sin impresora física

Prepara `C:\ASO-UD7` desde la consola del servidor. Conserva acceso de SYSTEM y Administradores a esa carpeta. Mediante el asistente de impresoras de Administración de impresión:

1. Agrega una impresora local y crea un puerto de tipo **Local Port** cuyo nombre sea la ruta completa `C:\ASO-UD7\salida.prn`.
2. Selecciona el controlador firmado **Generic / Text Only** (su nombre puede aparecer traducido). Si no está disponible, el docente debe instalar previamente ese controlador desde el catálogo de Windows; no sustituyas por un controlador de procedencia desconocida.
3. Nombra la cola `ASO_Texto` y añade ubicación y comentario.
4. Imprime desde Bloc de notas un documento de texto corto y comprueba `salida.prn` en el servidor.

La salida es texto de impresión, no PDF. El puerto es un archivo fijo: recoge cada evidencia antes de imprimir otra, pues puede sustituirse. No uses `FILE:` o `PORTPROMPT:` para esta demostración desatendida, ya que pueden pedir un nombre de archivo en una sesión interactiva.

## 3. Compartir y asignar permisos

Comparte la cola como `ASO_Texto` desde sus propiedades. Crea un grupo local `ASO_Impresion` y una cuenta de prueba con contraseña; incluye esa cuenta en el grupo. En **Seguridad** de la impresora, concede al grupo permiso de imprimir, conservando la administración para Administradores y SYSTEM. Revisa concesiones amplias que permitan imprimir por otro grupo antes de probar un rechazo.

Habilita las reglas del servicio de archivos e impresoras que necesite el recorrido en el perfil privado o de dominio y limita su ámbito a la subred del laboratorio. No deduzcas que todos los métodos de administración funcionan abriendo únicamente TCP 445: algunas operaciones utilizan RPC. Documenta las reglas efectivamente utilizadas.

Consulta la configuración con:

```powershell
Get-Printer -Name 'ASO_Texto' | Format-List Name,DriverName,PortName,Shared,ShareName
Get-PrintJob -PrinterName 'ASO_Texto'
```

En el cliente, accede a `\\NOMBRE-SERVIDOR\ASO_Texto` con la cuenta autorizada. En un dominio utiliza su identidad de dominio; en grupo de trabajo autentica la cuenta local del servidor. Si Windows pide elevación para instalar el controlador firmado, la preparación la realiza el docente con la cuenta administradora. No desactives las protecciones de Point and Print.

Referencia: [Add-Printer para conexiones compartidas](https://learn.microsoft.com/en-us/powershell/module/printmanagement/add-printer?view=windowsserver2025-ps).

## 4. Gestionar y auditar

Pausa la impresora desde Administración de impresión, envía un trabajo desde el cliente, consulta su identificador y reanuda. Prueba también cancelar un trabajo seleccionado desde la interfaz. Verifica el archivo de salida en el servidor y registra qué usuario lo envió.

Consulta los trabajos con [Get-PrintJob](https://learn.microsoft.com/en-us/powershell/module/printmanagement/get-printjob?view=windowsserver2025-ps). En el Visor de eventos localiza **Microsoft → Windows → PrintService**; habilita Operational si necesitas recoger la prueba y anota su estado previo. Un historial vacío sin registro habilitado no acredita ausencia de trabajos.

Comprueba rechazo con una cuenta de prueba sin permiso efectivo de impresión. La denegación debe deberse al permiso, no a que el servidor esté apagado. Documenta el resultado y devuelve la cola al estado disponible.

## 5. Entrega y retirada

Compara con CUPS: nombre de cola, dispositivo/puerto, controlador, clase o agrupación, cuenta, método de compartición y registros. La impresión de Windows a Windows complementa, pero no sustituye, la prueba Windows → CUPS del laboratorio básico.

Tras recoger las evidencias, elimina la conexión creada en el cliente y la cola `ASO_Texto` desde el servidor. Retira su puerto solo si ninguna otra impresora lo utiliza. Conserva o retira cuentas y reglas según lo registrado; si la VM era exclusiva, restaura su instantánea inicial.
