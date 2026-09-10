#!/usr/bin/env python3
"""Escenario orientativo ASO 2026/27: martes y jueves, dos horas cada día.
No representa un horario confirmado por el docente. Salida CSV por stdout.
"""
import csv
import sys
from collections import Counter
from datetime import date, timedelta

INICIO = date(2026, 9, 9)
FIN_CENTRO = date(2027, 3, 23)
HORARIO = {1: 2, 3: 2}  # lunes=0; sustituir por el horario real cuando se conozca
NO_LECTIVOS = {
    date(2026, 10, 9), date(2026, 10, 12),
    date(2026, 12, 7), date(2026, 12, 8),
    date(2027, 2, 12), date(2027, 3, 19),
}
BLOQUES = [
    ('1ª', 'UD1: fundamentos y scripting', 24),
    ('1ª', 'UD2: procesos y servicios', 8),
    ('1ª', 'UD3: directorio', 16),
    ('1ª', 'Prueba y recuperación', 4),
    ('2ª', 'UD4: integración en red', 16),
    ('2ª', 'UD5: automatización', 16),
    ('2ª', 'UD6: administración remota', 8),
    ('2ª', 'UD7: impresión', 4),
    ('2ª', 'Prueba, recuperación y cierre', 6),
]

def lectivo(d):
    return d.weekday() < 5 and d not in NO_LECTIVOS and not (
        date(2026, 12, 23) <= d <= date(2027, 1, 6)
    )

def fechas():
    d = INICIO
    while d <= FIN_CENTRO:
        yield d
        d += timedelta(days=1)

if __name__ == '__main__':
    slots = [d for d in fechas() if lectivo(d)
             for _ in range(HORARIO.get(d.weekday(), 0))]
    required = sum(h for _, _, h in BLOQUES)
    if required > len(slots):
        raise SystemExit(f'No cabe: {required} horas previstas, {len(slots)} disponibles')
    writer = csv.writer(sys.stdout)
    writer.writerow(['evaluacion', 'bloque', 'horas', 'inicio', 'fin'])
    offset = 0
    for ev, block, hours in BLOQUES:
        writer.writerow([ev, block, hours, slots[offset], slots[offset + hours - 1]])
        offset += hours
    counts = Counter(d.weekday() for d in fechas() if lectivo(d))
    print(f'Sesiones lectivas por día (lunes=0): {dict(sorted(counts.items()))}', file=sys.stderr)
    print(f'Horas previstas/disponibles: {required}/{len(slots)}', file=sys.stderr)
