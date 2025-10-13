## Soluciones: Windows

### Introducción
1. `Get-Location`
2. `Get-ChildItem`
3. `New-Item -Name prueba.txt -ItemType File`

### Navegación y directorios
1. `Set-Location C:\`
2. `New-Item -Name nuevo_directorio -ItemType Directory`
3. `Remove-Item -Recurse -Force nuevo_directorio`

### Visualización de contenido
1. `Get-Content prueba.txt`
2. `(Get-Content prueba.txt).Count`
3. `Select-String -Path usuarios.txt -Pattern "administrador"`

## Ejercicios avanzados

### Listado de archivos y directorios
1. `Get-ChildItem -Force C:\`
2. `Get-ChildItem -Recurse C:\Usuarios`
3. `Get-ChildItem -Name a*`

### Variables de entorno
1. `$Env:USERPROFILE`
2. `$Env:PATH`
3. `$Env:PATH += ";C:\nuevo\directorio"`

### Gestión de directorios
1. `New-Item -Name D1 -ItemType Directory`
2. `Copy-Item * -Destination D1`
3. `Move-Item archivo.txt -Destination D1`

### Permisos y propietarios
1. `icacls archivo /grant:r "$($Env:USERNAME):W"`
2. `icacls archivo /setowner Administrador`
3. `icacls *.ps1 /grant:r Everyone:X`

### Búsqueda y manipulación de archivos
1. `Get-ChildItem -Path $Env:USERPROFILE -Filter "t*" | ForEach-Object { $_.LastWriteTime = Get-Date }`
2. `Get-ChildItem -Path C:\ -Recurse -Filter "*" | Where-Object { $_.Length -lt 1MB -and $_.Owner -eq "Administrador" } | Set-Content -Path ficheros_pequeños`
3. `Get-ChildItem -Path C:\Users\Guest -Recurse | Where-Object { $_.Length -gt 5000MB -and $_.Attributes -match "Archive" } | Remove-Item`

### Procesamiento de contenido
1. `(Get-Content usuarios.txt) -replace ":", "_" | Set-Content usuarios.txt`
2. `Select-String -Path usuarios.txt -Pattern "Administrador"`
3. `(Get-Content usuarios.txt | Select-String "PowerShell").Count`

### Redirecciones
1. `Get-Content registro.log >> salida.txt 2>> errores.txt`
2. `Get-Content t1 | Select-Object -Last 3 | Set-Content resultado.txt`
3. `Get-ChildItem | Out-File listado.txt 2> errores_listado.txt`
