# Preparación del bloque Fundamentos de GNU/Linux

Borrador revisado para ASO, todavía sin integrar en su menú.

- [Informe de revisión y comprobaciones](REVISION.md).
- [Recorrido de los siete temas](docs/index.md).
- [Actividades adaptadas](docs/Actividades.md).
- [Soluciones docentes](docs/soluciones.md).

La fuente de ISO se conserva sin cambios. Los datos de práctica se encuentran en `docs/datos/`.

Para previsualizar solo este borrador desde la raíz del repositorio, con MkDocs Material instalado:

```bash
mkdocs serve -f preparacion/fundamentos-linux/mkdocs.yml
```

Para compilarlo sin tocar el sitio principal:

```bash
mkdocs build --strict -f preparacion/fundamentos-linux/mkdocs.yml --site-dir /tmp/aso-fundamentos-site
```

Las soluciones también se generan en esta previsualización local aunque no estén en el menú. Este directorio de preparación está fuera de `docs/` de ASO, por lo que no forma parte de su sitio principal.
