#!/usr/bin/env python3
"""Impide reintroducir material reservado en el directorio publicable."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
RESERVADOS = {
    "examenes", "privado", "evaluacion", "correccion", "cuestionarios",
    "unidad-didactica-ldap", "guion_clase.md", "programacionaula.md",
}
EXTENSIONES = {".ods", ".xlsx", ".xls", ".odt", ".docx", ".doc", ".gift",
               ".zip", ".rar", ".gz", ".7z", ".tar"}


def es_privado(path):
    partes = [parte.casefold() for parte in path.parts]
    return (
        any(parte in RESERVADOS or "soluciones" in parte for parte in partes)
        or path.suffix.casefold() in EXTENSIONES
        or path.name.casefold().startswith(("notas_", "calificaciones", "correccion_", "resumen_correccion_"))
    )


def main():
    docs = ROOT / "docs"
    errores = [p.relative_to(ROOT) for p in docs.rglob("*")
               if p.is_symlink() or es_privado(p.relative_to(docs))]
    if errores:
        print("Publicación bloqueada: mueve estos materiales a privado/:", file=sys.stderr)
        for path in sorted(errores):
            print(f"  {path}", file=sys.stderr)
        return 1
    print("Publicación comprobada: sin rutas reservadas ni paquetes privados en docs/.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
