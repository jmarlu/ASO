# Correccion examen de recuperacion UD1 + UD2 (2026-03-09)

Uso rapido (una entrega):

```bash
./check_entrega.sh /ruta/a/recuperacion_ud1_ud2_entrega.tar.gz
```

Correccion masiva (carpeta de alumnos):

```bash
./corrige_entregas.sh /ruta/al/alumnado --csv resultados.csv
```

Estructura esperada:

```text
alumnado/
  ana/
    recuperacion_ud1_ud2_entrega.tar.gz
  pedro/
    recuperacion_ud1_ud2_entrega.tar.gz
```

El script valida la estructura y comprueba evidencias basicas de cada parte.
Devuelve puntuacion sobre 10.

La correccion es automatica y heuristica. Si necesitas reglas mas estrictas,
edita las expresiones de `rg` dentro de `check_entrega.sh`.
