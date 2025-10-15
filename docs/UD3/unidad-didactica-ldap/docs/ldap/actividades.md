# 🔧 Actividades – Bloque 1: Conceptos Fundamentales de LDAP

> Todas las actividades se pueden resolver con los conceptos y ejemplos de la **Teoría**.

---

## Nivel 1 – Fundamentos

### 1. Comparativa LDAP vs SQL
Completa una tabla técnica con 6 criterios: estructura, rendimiento (lectura/escritura), seguridad, transacciones, esquema, casos de uso.

### 2. Vocabulario DIT
Dado un árbol, identifica **DN**, **RDN**, **OU**, **CN** y **DC** de 5 entradas diferentes.

```mermaid
graph TD
    A[dc=instituto,dc=edu]
    A-->B[ou=alumnos]
    A-->C[ou=profesores]
    B-->D[cn=Maria Lopez]
    C-->E[cn=Juan Perez]
```

---

## Nivel 2 – Aplicación

### 3. Diseña tu DIT (empresa)
Crea un DIT para `dc=empresa,dc=com` con:
- `ou=Usuarios`, `ou=Departamentos` (Ventas/Soporte), `ou=Grupos`.
- 4 usuarios `inetOrgPerson` y 2 grupos (`groupOfNames` con `member:` DN).
- Diagrama Mermaid del DIT.

### 4. LDIF de altas y cambios
Crea `altas.ldif` con OU+2 usuarios.  
Crea `cambios.ldif` con **add** de un atributo y **replace** de otro.  
Ejecuta:
```bash
ldapadd   -x -H ldap://127.0.0.1 -D "cn=admin,dc=empresa,dc=com" -W -f altas.ldif
ldapmodify -x -H ldap://127.0.0.1 -D "cn=admin,dc=empresa,dc=com" -W -f cambios.ldif
```

### 5. Búsquedas con base, alcance y filtros
1) Devuelve **solo** la entrada base (alcance `base`).  
2) Lista **hijos directos** de `ou=Usuarios` (alcance `one`).  
3) Encuentra en **todo el subárbol** a usuarios con `sn=Lopez` (alcance `sub`).  
4) Filtro combinado: `inetOrgPerson` de Ventas **o** Soporte cuyo `cn` empiece por `M`.

---

## Nivel 3 – Análisis/Creación

### 6. Esquema personalizado
Define en LDIF el atributo `cicloFormativo` (Directory String) y la clase `alumnoFP` (SUP `inetOrgPerson`, MUST `cn/sn/uid`, MAY `mail/cicloFormativo/tutor`).

### 7. Secuencia funcional LDAP
Crea un **sequenceDiagram (Mermaid)** con: `bind → search → result → modify → result → unbind`.

### 8. DSML y exportación
Explica **cuándo** usarías **DSML** en lugar de LDIF en un entorno real y dibuja un flujo simple (Mermaid) que lo muestre.

---

## Nivel 4 – Escenario profesional

### 9. Arquitectura con réplica
Diseña (Mermaid) una arquitectura con **slapd maestro** y **réplica**, 3 aplicaciones cliente (una de solo lectura), y señala **qué peticiones** van al maestro y cuáles a la réplica. Añade una nota sobre **TLS** y **ACL**.