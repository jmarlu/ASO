# Directorios y rutas en GNU/Linux

El árbol de archivos parte de `/`, la raíz. Los dispositivos y sistemas de archivos se incorporan mediante puntos de montaje. Un directorio no implica una partición independiente; `findmnt` permite consultar los montajes.

| Ruta | Función habitual |
|---|---|
| `/etc` | Configuración del sistema |
| `/home` | Directorios personales de usuarios |
| `/root` | Directorio personal de root; distinto de `/` |
| `/usr` | Programas, bibliotecas y datos compartidos |
| `/usr/local` | Software instalado localmente por el administrador |
| `/var` | Datos variables; por ejemplo registros en `/var/log` |
| `/srv` | Datos ofrecidos por servicios |
| `/tmp` | Archivos temporales; no es almacenamiento permanente |
| `/run` | Estado de ejecución desde el arranque |
| `/dev` | Nodos de dispositivos; no son los propios controladores |
| `/proc`, `/sys` | Interfaces virtuales del núcleo y dispositivos |
| `/boot` | Componentes de arranque |
| `/media` | Puntos habituales de montaje de medios extraíbles |
| `/mnt` | Punto convencional para montajes temporales |
| `/opt` | Paquetes adicionales de aplicaciones |

En sistemas con jerarquía `/usr` unificada, `/bin`, `/sbin` y `/lib` pueden ser enlaces a rutas de `/usr`. Comprueba tu máquina con `ls -ld /bin /sbin /lib`; no deduzcas que cada nombre corresponde a un directorio independiente. La organización sigue convenciones del FHS, con variaciones entre sistemas.

## Rutas absolutas y relativas

Una ruta absoluta empieza por `/`; una relativa se interpreta desde el directorio de trabajo. En `/home/alumno`, `datos/informe.txt` equivale a `/home/alumno/datos/informe.txt`.

- `.` representa el directorio actual.
- `..` representa su padre; el padre de `/` sigue siendo `/`.
- `~` es una expansión de Bash al directorio personal, no una raíz adicional.

El directorio que contiene `/home/alumno/datos/informe.txt` es `/home/alumno/datos`, no `/home/alumno`.

```bash
pwd
cd datos
pwd
cd ..
pwd
findmnt -T .
```

El directorio inicial de una terminal depende de cómo se abra. Verifica `pwd` antes de operar. En los ejercicios solo consultaremos las rutas del sistema; los cambios se harán dentro de la zona de práctica.
