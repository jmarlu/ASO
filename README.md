# ASO
Administración de Sistemas Operativos

## Material público y privado

- `docs/`: material publicable del alumnado (apuntes, actividades, laboratorios y recursos). MkDocs publica también los archivos que no figuran en el menú.
- `privado/docs/`: archivo local de exámenes, entregas, notas, informes individuales, solucionarios, bancos de preguntas y guiones docentes. Conserva la estructura anterior de `docs/` y está excluido de Git y de MkDocs.
- `privado/inventario_separacion.json`: inventario local de los archivos trasladados y sus hashes SHA256 para comprobar su conservación.

Los exámenes se preparan en `privado/docs/Examenes/`. Para publicar un enunciado, copia únicamente la versión revisada y sin datos personales a una página de actividades de `docs/`. No copies carpetas de convocatorias completas ni archivos comprimidos con entregas o soluciones.

Antes de publicar:

```bash
python3 scripts/comprobar_publicacion.py
mkdocs build --strict
```

La comprobación rechaza rutas reservadas al material privado, documentos ofimáticos, paquetes comprimidos y enlaces simbólicos dentro de `docs/`. Es una protección contra reintroducciones accidentales; el contenido nuevo debe revisarse antes de publicarlo.

`privado/` no se recupera al clonar el repositorio: conserva una copia de seguridad en un almacenamiento de acceso restringido. Las referencias históricas de los documentos trasladados a `docs/Examenes/` corresponden ahora a `privado/docs/Examenes/`.

Esta separación no elimina versiones anteriores del historial de Git ni retira por sí sola una web ya desplegada. Tras guardar los cambios, hay que desplegar la versión limpia y gestionar por separado las copias históricas que contengan información privada.
