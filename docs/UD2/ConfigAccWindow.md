# Configuración y endurecimiento inicial en Windows 10/11

## Objetivo rápido

Dejar un equipo cliente listo para producción: políticas básicas, firewall, UAC y arranque de aplicaciones controlado.

## Pasos recomendados

1. **Políticas locales (gpedit.msc)**
   - Equipo → Plantillas administrativas → Sistema → "Solicitar credenciales en elevación" habilitado.
   - Equipo → Plantillas administrativas → Almacenamiento → "Denegar instalación de dispositivos de almacenamiento extraíble" habilitado (relacionado con la Actividad 2.7).
2. **UAC (Control de Cuentas de Usuario)**
   - Panel de control → Cuentas de usuario → Cambiar configuración de UAC.
   - Selecciona el nivel según el entorno:
     - Servidor/empresa: "Notificar siempre".
     - Lab/ejercicio: "No notificar nunca" (solo si se pide expresamente y documentando el riesgo).
3. **Firewall de Windows Defender**
   - Abrir `wf.msc`.
   - Asegurar perfiles **Dominio**, **Privado** y **Público** activados.
   - Crear regla de salida/entrada solo si es necesaria (por ejemplo, habilitar HTTP/HTTPS para nginx en pruebas).
4. **Aplicaciones al inicio**
   - `taskmgr` → pestaña Inicio: habilitar/deshabilitar programas.
   - Alternativa con PowerShell: `Get-CimInstance Win32_StartupCommand`.
   - Para agregar `notepad.exe` al inicio (Actividad 2.7): coloca acceso directo en `%ProgramData%\Microsoft\Windows\Start Menu\Programs\StartUp`.
5. **Ubicación de carpetas especiales**
   - Botón derecho en Documentos/Descargas → Propiedades → Ubicación → Mover a la partición de datos.
6. **Registro (RegEdit)**
   - Exporta una copia antes de modificar: `reg export HKLM\SOFTWARE backup.reg`.
   - Para deshabilitar USB (ejemplo): `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\USBSTOR` valor `Start=4`.
   - Para UAC avanzado: `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System` ajusta `EnableLUA` (1 recomendado, 0 deshabilita UAC).
7. **Actualizaciones**
   - Configuración → Actualización y seguridad → Pausar o programar horas activas.
   - En dominio, usa GPO: Equipo → Plantillas administrativas → Componentes de Windows → Windows Update → "Configurar actualizaciones automáticas".

## Validación mínima

- Captura de policies aplicadas y estado del firewall.
- `systeminfo` para confirmar versión/edición.
- `gpresult /h informe.html` para evidenciar que las directivas se han aplicado.
