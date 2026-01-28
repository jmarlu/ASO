## Correccion examen UD1+UD2 (2026-01-21)

Uso rapido (una entrega):

```bash
./check_entrega.sh /ruta/al/examen_ud1_ud2_entrega.tar.gz
```

Correccion masiva (carpeta de alumnos):

```bash
./corrige_entregas.sh /ruta/al/alumnos --csv resultados.csv
```

Estructura esperada:

```
alumnos/
  ana/
    examen_ud1_ud2_entrega.tar.gz
  pedro/
    examen_ud1_ud2_entrega.tar.gz
```

El script valida la estructura y comprueba evidencias basicas de cada parte.
Devuelve puntuacion sobre 10.
