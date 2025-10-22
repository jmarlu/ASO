---
search:
  exclude: true
---

# Soluciones Examen de Comandos Linux

## 1. Gestión de Usuarios (2.5 puntos)
**Solución:**
```bash
cut -d":" -f1,3 /etc/passwd | sort -k2n -t":" | tr -s ":" " "
cut -d":" -f1,3 /etc/passwd | tr -s ":" " " | sort -k2n  
```

## 2. Búsqueda de Correos Electrónicos (2.5 puntos)
**Solución:**
```bash
find / -type f -exec egrep -l ".*@.*\..*" {} \; 2>/dev/null
```

## 3. Gestión de Ficheros y Permisos (3 puntos)
**Solución:**
```bash
find / -user $USER -size +200k -writable -type f 2>err3 | wc -l >res3
```

## 4. Monitorización de Procesos (2 puntos)
**Solución:**
<!-- ```bash
while true; do 
    ps -u $USER -o pid,%mem,comm --sort=-%mem | head -n 6
    sleep 3
    clear
done
``` -->
```bash 
    ps -u $USER -o pid,%mem,comm --sort=-%mem | head -n 6
```

## Notas de evaluación
- Las soluciones utilizan solo comandos básicos de Linux
- No se han utilizado awk ni sed como se especificó
- Cada solución cumple con los requisitos de formato de salida
- Se han incluido las redirecciones de error cuando era necesario