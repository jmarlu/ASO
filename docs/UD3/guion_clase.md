---
search:
  exclude: true
---

# Guion de clase UD3 - LDAP y servicios de directorio

## Objetivo de la sesion
- Entender que es un directorio LDAP y como se organiza (DIT, DN, RDN).
- Practicar operaciones basicas: add/search/modify/delete con LDIF.
- Introducir filtros, alcance y una vista rapida de ACL en OpenLDAP.
- Conectar LDAP con PAM/SSSD y servicios de autenticacion en una VM.
- Ver una integracion tipo (NSS/PAM/SSSD) y el flujo de login.

## Requisitos previos (5 min)
- Docker y Docker Compose instalados en la maquina de laboratorio.
- Navegador para phpLDAPadmin (opcional).
- Terminal con herramientas LDAP (`ldapsearch`, `ldapadd`, `ldapmodify`, `ldapdelete`).

## Material preparado en este repo
- Guia de laboratorio Docker: `docs/UD3/docker-openldap.md`.
- Teoria base: `docs/UD3/teoria.md`.
- Actividades y ejemplos: `docs/UD3/actividades.md`, `docs/UD3/soluciones.md`.
- PAM: `docs/UD3/pam.md`.
- Servicios de autenticacion: `docs/UD3/ServiciosAutenticacion.md`.

## Estructura y tiempos sugeridos (2 sesiones de 60 min)
### Sesion 1 (60 min)
1. Introduccion y objetivos (5 min)
2. DIT, DN/RDN y objetos (10 min)
3. Laboratorio: levantar OpenLDAP (10 min)
4. Operaciones LDAP con LDIF (15 min)
5. Busquedas: base/scope/filtros + ACL rapida (15 min)
6. Mini resumen y preguntas (5 min)

### Sesion 2 (60 min)
1. Repaso rapido del DIT y comandos (5 min)
2. PAM y flujo de autenticacion (10 min)
3. Integracion SSSD + NSS/PAM en VM (30 min)
4. Integracion de servicios con LDAP (10 min)
5. Cierre y preguntas (5 min)

## Demo en directo (paso a paso)

### 0) Preparar laboratorio Docker (Sesion 1)
En una carpeta de trabajo (por ejemplo `~/openldap-lab/`):
```bash
mkdir -p ~/openldap-lab/datos/ldap ~/openldap-lab/datos/slapd.d
```
Crear `docker-compose.yml` siguiendo `docs/UD3/docker-openldap.md` y arrancar:
```bash
docker compose up -d
docker compose ps
```
Salida esperada (resumen):
```text
openldap      ... Up ...
phpldapadmin  ... Up ...
```
Verifica el servicio:
```bash
ldapsearch -x -H ldap://localhost:389 -b "dc=asir,dc=local" "(objectClass=*)"
```

### 1) DIT, DN y RDN (introduccion breve) (Sesion 1)
**Idea clave**: el directorio es un arbol; el DN identifica una entrada unica.
Ejemplo:
```text
cn=profesor,ou=Usuarios,dc=asir,dc=local
```
Relaciona con los conceptos del `docs/UD3/teoria.md`.

### 2) Carga inicial con LDIF (ldapadd) (Sesion 1)
Usa un LDIF minimo (base + OU + usuario). Ejemplo tomado de `docs/UD3/docker-openldap.md`.
```bash
ldapadd -x -H ldap://127.0.0.1:389 -D "cn=admin,dc=asir,dc=local" -w admin123 -f base.ldif
ldapadd -x -H ldap://127.0.0.1:389 -D "cn=admin,dc=asir,dc=local" -w admin123 -f userOrgs.ldif
```
Salida esperada (resumen):
```text
adding new entry "dc=asir,dc=local"
adding new entry "ou=Usuarios,dc=asir,dc=local"
```
Recuerda: `-x` es bind simple, `-D` es el DN del admin, `-f` apunta al LDIF.

### 3) Busquedas (ldapsearch): base, scope y filtros (Sesion 1)
1) Buscar todo el arbol:
```bash
ldapsearch -x -H ldap://127.0.0.1:389 -D "cn=admin,dc=asir,dc=local" -w admin123 -b "dc=asir,dc=local" -s sub "(objectClass=*)" dn
```
2) Buscar un usuario por uid:
```bash
ldapsearch -x -H ldap://127.0.0.1:389 -D "cn=admin,dc=asir,dc=local" -w admin123 -b "ou=Usuarios,dc=asir,dc=local" -s sub "(uid=profesor)" cn sn mail
```
Salida esperada (resumen):
```text
dn: cn=profesor,ou=Usuarios,dc=asir,dc=local
cn: profesor
sn: Demo
mail: profesor@asir.local
```
Pausa para explicar `-b`, `-s` y los filtros `(atributo=valor)`.

### 4) Modificar entradas (ldapmodify) (Sesion 1)
```bash
ldapmodify -x -H ldap://127.0.0.1:389 -D "cn=admin,dc=asir,dc=local" -w admin123 -f modificar-profesor.ldif
```
Salida esperada (resumen):
```text
modifying entry "cn=profesor,ou=Usuarios,dc=asir,dc=local"
```
Explica `changetype: modify`, `replace` y `add`.

### 5) Borrado controlado (ldapdelete) (Sesion 1)
```bash
ldapdelete -x -H ldap://127.0.0.1:389 -D "cn=admin,dc=asir,dc=local" -w admin123 "cn=profesor,ou=Usuarios,dc=asir,dc=local"
```
Salida esperada (resumen):
```text
deleting entry "cn=profesor,ou=Usuarios,dc=asir,dc=local"
```

### 6) ACL rapida (solo lectura) (Sesion 1)
**Idea clave**: las ACL se aplican en orden y la primera que encaja manda.
```bash
ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b cn=config olcAccess
```
Si no se puede acceder desde el host, explica el concepto y deja esta parte para la practica.

### 7) PAM en 10 minutos (conceptos y pila) (Sesion 2)
**Idea clave**: PAM es la "centralita" que conecta servicios con backends (LDAP/SSSD).
Puntos clave a cubrir (ver `docs/UD3/pam.md`):
- Tipos: `auth`, `account`, `password`, `session`.
- Controles: `required`, `requisite`, `sufficient`, `optional`, `include`.
- Archivos en `/etc/pam.d/` y pilas `common-*` (Debian/Ubuntu).
Ejemplo minimo (explicarlo, no editarlo en directo):
```text
auth    required        pam_env.so
auth    include         common-auth
account include         common-account
session include         common-session
```
Mensaje clave: si tocas PAM sin backup, te puedes bloquear el acceso.

Ejemplo didactico que rompe el acceso (no ejecutarlo en sistemas reales):
```text
auth    requisite       pam_deny.so
```
Explicacion breve: `pam_deny.so` con control `requisite` corta la pila de inmediato y devuelve fallo, asi que cualquier login queda bloqueado. Sirve para ilustrar la logica de controles y el orden de evaluacion.

Rollback rapido (para demo controlada en VM):
```bash
sudo cp /etc/pam.d/common-auth /etc/pam.d/common-auth.bak
# ...cambios...
sudo mv /etc/pam.d/common-auth.bak /etc/pam.d/common-auth
```

### 8) Servicios de autenticacion con LDAP (SSSD + VM) (Sesion 2)
**Idea clave**: LDAP valida, SSSD cachea, PAM decide, NSS resuelve.
Usa el guion de `docs/UD3/ServiciosAutenticacion.md` como base.

1) Paquetes en VM:
```bash
sudo apt update && sudo apt install sssd libnss-sss libpam-sss ldap-utils pamtester sssd-tools
```
2) Configuracion minima de `/etc/sssd/sssd.conf` (resumen):
```ini
[sssd]
services = nss, pam
domains = asir

[domain/asir]
id_provider = ldap
auth_provider = ldap
ldap_uri = ldap://192.168.56.1:389
ldap_search_base = dc=asir,dc=local
ldap_default_bind_dn = cn=admin,dc=asir,dc=local
ldap_default_authtok = admin123
ldap_user_search_base = ou=Usuarios,dc=asir,dc=local
ldap_group_search_base = ou=Groups,dc=asir,dc=local
access_provider = permit
```
3) Permisos y arranque:
```bash
sudo chmod 600 /etc/sssd/sssd.conf
sudo systemctl enable --now sssd
```
4) NSS:
```bash
getent passwd profesor
```
5) PAM (via `pam-auth-update`):
```bash
sudo pam-auth-update
```
6) Prueba rapida:
```bash
sudo pamtester login profesor authenticate
su - profesor
```
Salida esperada (resumen):
```text
pam_sm_authenticate = PAM_SUCCESS
```
Recordatorio: mantener una consola root abierta por seguridad.

### 9) Integracion de servicios con LDAP (vision rapida) (Sesion 2)
**Idea clave**: el servicio consume identidades centralizadas, pero el acceso final depende de PAM/NSS.
Ejemplos para comentar (sin ejecutar):
- `sshd` + PAM para logins remotos.
- `sudo` con PAM y grupos LDAP.
- `samba`/`nfs` usando usuarios LDAP (concepto, no demo).
Relaciona con el flujo completo: LDAP -> SSSD -> NSS/PAM -> servicio.

### 10) Limpieza (opcional) (Sesion 2)
```bash
docker compose down
```

## Checklist de mensajes clave para el alumnado
- LDAP es un arbol (DIT) y el DN identifica una entrada unica.
- Las operaciones basicas son add/search/modify/delete y se expresan en LDIF.
- En las busquedas importan base, scope y filtro.
- En OpenLDAP, el orden de las ACL define el permiso efectivo.
- PAM decide el acceso; SSSD integra LDAP y cachea credenciales.
- La integracion de servicios depende de NSS/PAM y del backend LDAP.

## Preguntas rapidas para cerrar
- Que diferencia hay entre DN y RDN?
- Por que `-b` y `-s` cambian el resultado de una busqueda?
- Que ocurre si una ACL anterior ya coincide?
- Donde se decide el acceso final: en LDAP o en PAM?
