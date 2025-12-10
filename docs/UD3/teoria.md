# 🧱 Bloque 1 – Conceptos Fundamentales de LDAP

> "Comprender un servicio de directorio es entender el corazón de la gestión de identidades."

---

## 1. Introducción a LDAP y a los servicios de directorio

Un **servicio de directorio** es una base de datos **jerárquica y optimizada para lectura** que almacena información sobre recursos de red (usuarios, equipos, grupos) y facilita su **búsqueda** y **autenticación**. LDAP es el **protocolo estándar** cliente-servidor para acceder y modificar esa información (sobre TCP/IP).

**Puntos clave del documento base:**
- LDAP ofrece **búsqueda y recuperación** de información, y define operaciones para **añadir/actualizar/borrar** entradas.
- **Origen X.500**: LDAP simplifica X.500 para hacerlo práctico en TCP/IP. Muchos servidores X.500 incorporaron **pasarelas LDAP**.
- LDAP **no** es una BBDD relacional, ni un sistema de ficheros para objetos grandes, ni óptimo para datos muy dinámicos.

### **LDAP HOY**

```mermaid
flowchart TB
    subgraph LDAP_HOY[LDAP HOY]
        direction TB
        A["✅ Acceso estándar a directorios (TCP/IP)"]
        B["✅ Base de OpenLDAP/AD"]
        C["✅ Lecturas rápidas, estructura jerárquica"]
        D["✅ Seguridad: SASL, TLS/LDAPS"]
        E["⚠️ No es SQL ni sistema de ficheros"]
    end
```

---

## 2. Modelos de LDAP

LDAP se entiende mejor con **cuatro modelos**: **información**, **nombrado**, **funcional** y **seguridad**.

### 2.1 Modelo de información
Este modelo provee de las estructuras y tipos de datos necesarios para construir un árbol de directorios LDAP. La unidad básica en un directorio LDAP es la entrada. Una entrada se puede ver como un nodo en el árbol de
información de directorio (DIT). Una entrada contiene información sobre una
instancia de uno o más objectClass. Estos objectClass son unos objetos que
tienen ciertos atributos, algunos opcionales y otros obligatorios. Los
atributos pueden ser de distintos tipos y cada tipo lleva asociado reglas de
codificación y de coincidencia que tienen en cuenta cosas como qué tipo de
dato puede tomar este atributo o como compararlo en una búsqueda.
Veamos como sería una entrada simple.


**Ejemplo de entrada (LDIF):**

```ldif
dn: cn=Jose Martin,ou=People,dc=universidad,dc=edu
objectClass: inetOrgPerson
cn: Jose Martin
sn: Martin
uid: jmartin
mail: jmartin@universidad.edu
```

### 2.2 Modelo de nombrado
Las entradas se **organizan en árbol**. El **DN** se construye concatenando **RDNs** desde la raíz (sufijos `dc=...`). **Case-insensitive** en nombres de atributos; espacios en torno a `,` y `=` se ignoran.

- **DN (Distinguished Name)**: la “dirección completa” de una entrada. Es la suma de todos los RDN desde el nodo hasta la raíz, por ejemplo `cn=Ana Lopez,ou=Usuarios,dc=empresa,dc=com`.
- **RDN (Relative Distinguished Name)**: el fragmento que identifica a la entrada dentro de su rama. En el ejemplo anterior, `cn=Ana Lopez` es el RDN dentro de `ou=Usuarios`.
- **OU (Organizational Unit)**: contenedor lógico para agrupar entradas relacionadas (departamentos, equipos, aulas). Aparece como `ou=...`.
- **CN (Common Name)**: nombre común de una entrada, usado para personas o grupos (`cn=Ana Lopez`, `cn=admins`).
- **DC (Domain Component)**: fragmento del dominio DNS usado en la raíz del directorio (`dc=empresa`, `dc=com`), ayuda a que la jerarquía refleje el dominio de la organización.

```mermaid
graph TD
    DC[dc=empresa,dc=com]
    DC --> OU1[ou=Usuarios]
    DC --> OU2[ou=Departamentos]
    DC --> OU3[ou=Grupos]
    OU2 --> OU21[ou=Ventas]
    OU2 --> OU22[ou=Soporte]
    OU1 --> CN1[cn=Ana Lopez]
    OU3 --> G1[cn=admins]
```

### 2.3 Modelo funcional
Operaciones del **protocolo**: `bind` (autenticación), `search` (búsqueda), **actualizaciones** (`add/modify/delete`), `unbind`.

```mermaid
sequenceDiagram
    participant C as Cliente LDAP
    participant S as Servidor OpenLDAP (slapd)
    participant DB as Backend (mdb/hdb)
    C->>S: Bind (autenticación)
    C->>S: Search (base, scope, filter, attrs)
    S->>DB: Evalúa y aplica filtros
    DB-->>S: Entradas coincidentes
    S-->>C: Resultado (atributos solicitados)
    C->>S: Add/Modify/Delete (opcional)
    S-->>C: Éxito/Error
    C-->>S: Unbind (cierre)
```

### 2.4 Modelo de seguridad
- **Autenticación** (simple o **SASL**), **cifrado** (**TLS/LDAPS**), y **ACL** para autorización. LDAPv3 integra métodos, TLS es **operación extendida** estándar; LDAPS usa puerto **636**.

``` mermaid
graph TD
    U[Cliente] -->|bind| A[Autenticación]
    A -->|SASL/Password| T[TLS/LDAPS]
    A --> S[Servidor OpenLDAP]
    S --> ACL[ACL: autorización por DN/atributos]
    ACL --> S
```

---

## 3. ACL en LDAP (slapd)

Las **ACL** de OpenLDAP controlan **quién** puede hacer **qué** sobre **qué** datos. Se evalúan en orden, de arriba abajo, y la primera que encaja decide.

### 3.1 Piezas clave
- **Ámbito**: `to *`, a una base DN (`to dn.base="dc=empresa,dc=com"`), a un subárbol (`dn.subtree=...`) o a atributos concretos (`attrs=userPassword,loginShell`).
- **Quién**: `by` con identidades (`dn.exact=`, `group.exact=`, `anonymous`, `users`, `self`, `*`).
- **Permisos**: `none`, `auth`, `compare`, `search`, `read`, `write`, `manage`. Se pueden combinar (`read,write`).
- **Orden**: la primera regla coincidente aplica; deja una regla final de “cierre” para evitar fugas.

### 3.2 Ejemplos típicos (config dinámica `cn=config`)
```ldif
# 1) Solo admins gestionan todo
olcAccess: {0}to * by dn.exact="cn=admin,dc=empresa,dc=com" manage by * break

# 2) Los usuarios pueden leer todo el árbol salvo contraseñas
olcAccess: {1}to * by users read by anonymous auth
olcAccess: {2}to attrs=userPassword by self write by anonymous auth by * none

# 3) Grupo de Helpdesk puede modificar teléfono/mail
olcAccess: {3}to attrs=telephoneNumber,mail by group.exact="cn=helpdesk,ou=Grupos,dc=empresa,dc=com" write by * break
```

Notas rápidas:
- En `cn=config`, los índices `{0}`, `{1}`… marcan el orden. Edita con `ldapmodify` contra `cn=config`.
- Usa `ldapsearch -LLL -b cn=config olcAccess` para revisar la ACL efectiva.
- Prueba con `ldapwhoami -x -D "uid=alumno,ou=Usuarios,dc=empresa,dc=com" -W` y luego operaciones `ldapsearch/ldapmodify` para validar permisos.

### 3.3 Flujo de cambio seguro
1) **Exporta** configuración actual: `slapcat -b cn=config | grep olcAccess`.  
2) **Planifica** reglas de más específico a más genérico.  
3) **Aplica** con LDIF y `ldapmodify` sobre `cn=config`.  
4) **Valida** con usuarios reales (self, anónimo, grupo).  
5) **Documenta** en un comentario/README del laboratorio qué reglas hay y por qué.

---

## 4. Búsquedas LDAP: base, alcance y filtros

Cuando ejecutamos un `search` estamos diciendo al servidor qué parte del árbol queremos examinar y qué condiciones deben cumplir las entradas que devuelva. Piensa en tres preguntas:

1. **¿Dónde empiezo?** → *Base DN*  
   Es el punto del árbol a partir del cual se busca (`dc=empresa,dc=com`, `ou=Usuarios,dc=empresa,dc=com`, etc.).

2. **¿Hasta dónde bajo?** → *Scope* (alcance)  
   - `base`: solo consulta la entrada indicada como base.  
   - `oneLevel`: revisa sus hijos directos (un único nivel).  
   - `subtree`: baja por todo el subárbol.

3. **¿Qué estoy buscando?** → *Filtro*  
   Es el conjunto de condiciones sobre atributos, parecido a un `WHERE`.

```mermaid
graph TD
    Cliente[Cliente LDAP] -->|search| Servidor
    Servidor --> Base[Base DN]
    Servidor --> Alcance[Scope: base / oneLevel / subtree]
    Servidor --> Filtro[condiciones]
    Filtro --> Resultado[Entradas devueltas]
    Resultado --> Cliente
```

### 4.1 Scope y filtros en acción
| Scope | ¿Qué abarca? | Ejemplo de uso |
|-------|--------------|----------------|
| `base` | Solo la entrada del *base DN* | Leer atributos de `cn=admin,dc=empresa,dc=com` |
| `oneLevel` | Los hijos directos (1 nivel) | Listar usuarios dentro de `ou=Usuarios,dc=empresa,dc=com` |
| `subtree` | Toda la rama descendiente | Inventariar todas las entradas bajo `dc=empresa,dc=com` |

| Tipo de filtro | Sintaxis | ¿Qué hace? |
|----------------|----------|------------|
| Presencia | `(atributo=*)` | Devuelve entradas que tengan ese atributo |
| Igualdad | `(atributo=valor)` | Coincidencia exacta |
| Subcadenas | `(atributo=valor*)` | Compara prefijos o sufijos (`*valor*`) |
| OR | `(|(cond1)(cond2))` | Entradas que cumplan al menos una condición |
| AND | `(&(cond1)(cond2))` | Entradas que cumplan todas las condiciones |
| NOT | `(!(cond))` | Entradas que NO cumplan la condición |

Los filtros se pueden anidar: `(&(objectClass=person)(|(sn=Lopez)(sn=Perez)))` devuelve personas con apellido López **o** Pérez.



---

## 4. LDIF y DSML

**LDIF**: formato de texto para **representar/alterar** entradas y esquemas; soporta cambios (`changetype: modify`) y **Base64** para binarios. **DSML**: representación **XML** útil para integración con aplicaciones/servicios web.

```mermaid
  graph LR
      L[Servidor LDAP] <-->|import/export| F[LDIF .ldif]
      L --> X[DSML/XML]
      X --> Apps[Integración con apps/servicios]
```


---
