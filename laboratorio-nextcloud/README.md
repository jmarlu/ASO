# Laboratorio Nextcloud + LDAP (Integración con el dominio `dc=laboratorio,dc=local`)

Entorno Nextcloud listo para conectar con el LDAP del laboratorio anterior (OpenLDAP en Docker, puerto 1389) y usarlo como backend de identidades.

## Estructura
- `docker-compose.yml`: Nextcloud + Postgres + Redis (opcional pero recomendado) en una red interna.
- Volúmenes locales: `./data/nextcloud` y `./data/db` para persistencia.

## Arranque rápido
```bash
cd laboratorio-nextcloud
docker compose up -d
```

Servicios:
- Nextcloud: http://localhost:8080
- Postgres: solo red interna del compose
- Redis: solo red interna del compose

Primera vez en el asistente web:
- Usuario admin inicial: `admin`
- Clave admin inicial: `admin123`  (cámbiala tras el primer login)
- DB:
  - Tipo: PostgreSQL
  - Usuario: `ncuser`
  - Contraseña: `ncpass`
  - Base de datos: `nextcloud`
  - Host: `db`

## Conexión a LDAP
En el asistente de Nextcloud (o luego en **Ajustes → LDAP/AD Integration**):

- Servidor: `ldap://host.docker.internal:1389` (si usas Docker Desktop) o la IP del host donde corre LDAP, p.ej. `ldap://192.168.56.1:1389`.
- DN base: `dc=laboratorio,dc=local`
- Usuario de conexión: `cn=admin,dc=laboratorio,dc=local`
- Contraseña: `admin`
- Filtro de usuarios: `(objectClass=person)` o restringe por `(&(objectClass=person)(|(uid=profesor)(uid=alumno1)))` si solo quieres los iniciales.
- Filtro de grupos: `(objectClass=posixGroup)`
- Atributo de login: `uid`

Tras guardar, comprueba en la pestaña de prueba de conexión que se resuelven `profesor` y `alumno1`.

## Validaciones rápidas
1. Login web con `profesor/Profesor123` y `alumno1/Alumno123`.
2. Crear archivo con `alumno1`, luego verificar que `profesor` puede verlo si lo compartes (según política de Nextcloud; independiente de ACL de Samba).
3. Revisa **Usuarios** en Nextcloud: deben aparecer los dos usuarios del LDAP y sus grupos (`profesores`, `alumnos`).

## Limpieza
```bash
docker compose down -v
```

## Notas
- Ajusta las contraseñas iniciales en el compose si lo necesitas.
- Si usas Linux sin `host.docker.internal`, cambia la URL LDAP en el asistente por la IP del host (la misma que usa la VM/Vagrant, 192.168.56.1 por defecto).
