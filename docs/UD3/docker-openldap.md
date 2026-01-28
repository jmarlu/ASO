# 🐳 OpenLDAP en Docker 

> Objetivo: montar un laboratorio de OpenLDAP en una máquina virtual Ubuntu usando Docker y Docker Compose, entendiendo los conceptos básicos para poder adaptarlo en clase.

---

## 1. Fundamentos de Docker

- **Contenedor:** proceso aislado que incluye todo lo necesario para ejecutar una aplicación (bibliotecas, configuración). Comparte el kernel del sistema anfitrión.
- **Imagen:** plantilla inmutable a partir de la cual se crean contenedores (por ejemplo, `osixia/openldap:1.5.0`).
- **Dockerfile:** receta que describe cómo construir una imagen.
- **Volumen:** carpeta persistente para guardar datos aunque el contenedor se destruya.
- **Registro:** repositorio donde se almacenan imágenes (`Docker Hub`, `ghcr.io`, etc.).

Ventajas para el aula:
- Montaje rápido, reproducible y sin «ensuciar» la máquina.
- Posibilidad de que cada alumno tenga un entorno idéntico.

---

## 2. Instalar Docker Engine en Ubuntu

1. **Actualizar la VM:**
   ```bash
   sudo apt update && sudo apt upgrade
   ```
2. **Instalar requisitos previos:**
   ```bash
   sudo apt install ca-certificates curl gnupg lsb-release
   ```
3. **Añadir la clave y el repositorio oficial:**
   ```bash
   sudo install -m 0755 -d /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt update
   ```
4. **Instalar Docker y plugins:**
   ```bash
   sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```
5. **Añadir al grupo `docker` (opcional, para no usar `sudo`):**
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```
6. **Probar con un contenedor de ejemplo:**
   ```bash
   docker run --rm hello-world
   ```

---

## 3. Comandos básicos imprescindibles

| Acción | Comando | Comentario |
|--------|---------|------------|
| Listar contenedores activos | `docker ps` | Con `-a` muestra también los detenidos |
| Descargar imagen | `docker pull imagen:tag` | Ej: `docker pull osixia/openldap:1.5.0` |
| Crear/ejecutar contenedor | `docker run --name nombre imagen` | Añade `-d` para modo daemon |
| Parar/arrancar contenedor | `docker stop nombre` / `docker start nombre` | |
| Ver logs en vivo | `docker logs -f nombre` | Útil para diagnosticar arranques |
| Entrar en un contenedor | `docker exec -it nombre bash` | Depuración o mantenimiento |
| Eliminar contenedor | `docker rm nombre` | Elimina solo el contenedor |
| Eliminar imagen | `docker rmi imagen:tag` | Necesario detener y borrar contenedores primero |

---

## 4. Docker Compose 

**Docker Compose** permite definir múltiples contenedores y sus relaciones en un archivo `docker-compose.yml`.

Elementos clave del YAML:

  - `services`: cada servicio es un contenedor.
  - `image` o `build`: usar imagen existente o construirla.
  - `ports`: mapeo `host:contenedor`.
  - `environment`: variables de entorno.
  - `volumes`: datos persistentes o archivos que se comparten.
  - `depends_on`: orden de arranque entre servicios.

Comandos básicos:
   - `docker compose up -d` → crea/arranca los servicios.
   - `docker compose ps` → estado.
   - `docker compose logs -f servicio` → logs.
   - `docker compose down` → detiene y elimina contenedores, pero respeta volúmenes.

> Desde Docker 20.10 el plugin oficial se invoca como `docker compose` (con espacio). Asegúrate de no usar la sintaxis antigua `docker-compose`.

---

## 5. Laboratorio: OpenLDAP + phpLDAPadmin

### 5.1 Estructura recomendada

```
~/openldap-lab/
├── datos/
│   ├── ldap/
│   └── slapd.d/
├── docker-compose.yml
```

### 5.2 Fichero `docker-compose.yml`

```yaml
version: "3.9"

services:
  openldap:
    image: osixia/openldap:1.5.0
    container_name: openldap
    environment:
      LDAP_ORGANISATION: "ASIR2X"
      LDAP_DOMAIN: "asir.local"
      LDAP_ADMIN_PASSWORD: "admin123"
      LDAP_TLS: "false"  # Desactiva la validación por certificado
    ports:
      - "389:389"
      # Si usas LDAPS (TLS directo), expón también 636
      # - "636:636"
    volumes:
      - ./datos/ldap:/var/lib/ldap
      - ./datos/slapd.d:/etc/ldap/slapd.d
    restart: unless-stopped

  phpldapadmin:
    image: osixia/phpldapadmin:0.9.0
    container_name: phpldapadmin
    environment:
      PHPLDAPADMIN_LDAP_HOSTS: openldap
      PHPLDAPADMIN_HTTPS: "false"
    ports:
      - "8080:80"
    depends_on:
      - openldap
    restart: unless-stopped


```


!!! Warning:

      cuando experimentes con TLS, replicación u otras opciones avanzadas ese estado queda persistido en `./datos/slapd.d` y en la base de datos bajo `./datos/ldap`. Si desactivas la característica, elimina o renombra la carpeta `datos/` antes de levantar de nuevo el stack (`docker compose down && rm -rf datos` o `mv datos datos_backup`) para regenerar una configuración limpia.



## 6. Pasos para arrancar el laboratorio

1. Crear directorio y copiar los archivos anteriores.
2. Crear las carpetas para los volúmenes persistentes:

   ```bash
   mkdir -p datos/ldap datos/slapd.d
   ```
3. Ajustar variables: dominio (`LDAP_DOMAIN`), contraseña admin, entradas en el LDIF.
4. Lanzar los servicios:
   ```bash
   docker compose up -d
   ```
5. Comprobar estado:
   ```bash
   docker compose ps
   docker compose logs -f openldap
   ```
6. Acceder a phpLDAPadmin desde el navegador en `http://IP_VM:8080`.  
   - **Login DN:** `cn=admin,dc=asir,dc=local`  
   - **Password:** la que definiste como `LDAP_ADMIN_PASSWORD`.
7. Probar desde la línea de comandos del host:
   ```bash
   ldapsearch -x -H ldap://localhost:389 -b "dc=asir,dc=local" "(objectClass=*)"
   ```

Para detener el laboratorio sin perder datos:
```bash
docker compose down
```
Los contenedores se recrearán en el próximo `up`, reutilizando los volúmenes.

---

## Gestión del Servidor

Aprender a gestionar un servicio LDAP ejecutándose en Docker, comprendiendo las operaciones básicas (alta, baja, modificación y consulta) y las opciones de cada comando.

 
### 🧩 Comandos básicos de OpenLDAP

> En esta sección aprenderás a usar los comandos `ldapadd`, `ldapsearch`, `ldapmodify` y `ldapdelete` con sus opciones explicadas, ejemplos prácticos y salidas esperadas.

---

#### 🧱 ldapadd — Crear entradas

!!! info "Sintaxis general"
    ```bash
    ldapadd -x -H ldap://127.0.0.1:389 -D "cn=admin,dc=asir,dc=local" -w admin123 -f base.ldif
    ldapadd -x -H ldap://127.0.0.1:389 -D "cn=admin,dc=asir,dc=local" -w admin123 -f userOrgs.ldif
    ```

**Opciones más comunes**

| Opción | Descripción |
|:-------|:-------------|
| `-x` | Usa autenticación simple (simple bind) |
| `-H` | URI del servidor LDAP |
| `-D` | DN del usuario admin |
| `-w` | Contraseña |
| `-f` | Fichero LDIF con las entradas a crear |
| `-c` | Continúa en caso de errores (“Already exists”) |

---

**Ejemplo** (creación base y OU):
```ldif title="base.ldif"
dn: dc=asir,dc=local
objectClass: top
objectClass: dcObject
objectClass: organization
o: ASIR2X
dc: asir
```
```ldif title="userOrgs.ldif"

dn: ou=Usuarios,dc=asir,dc=local
objectClass: organizationalUnit
ou: Usuarios

dn: cn=profesor,ou=Usuarios,dc=asir,dc=local
objectClass: inetOrgPerson
cn: profesor
sn: Demo
uid: profesor
mail: profesor@asir.local
userPassword: 123


```

**Salida esperada:**
```
adding new entry "dc=asir,dc=local"
adding new entry "ou=Usuarios,dc=asir,dc=local"
```
---
#### 🔍 ldapsearch — Buscar entradas
```bash
ldapsearch -x -H ldap://127.0.0.1:389 -D "cn=admin,dc=asir,dc=local" -w admin123 -b "dc=asir,dc=local" -s sub "(objectClass=*)" dn
```

| Opción | Descripción |
|:-------|:------------|
| `-b` | Base DN |
| `-s` | Alcance: `base` (solo DN), `one` (hijos directos), `sub` (subárbol) |
| `"(filtro)"` | Ej.: `(uid=profesor)`, `(&(objectClass=inetOrgPerson)(sn=Demo))` |
| `atributos` | Lista opcional (ej.: `cn mail`) |

**Ejemplo** (buscar usuario):
```bash
ldapsearch -x -H ldap://127.0.0.1:389   -D "cn=admin,dc=asir,dc=local" -w admin123   -b "ou=Usuarios,dc=asir,dc=local" -s sub "(uid=profesor)" cn sn mail
```
**Salida esperada:**
```
dn: cn=profesor,ou=Usuarios,dc=asir,dc=local
cn: profesor
sn: Demo
mail: profesor@asir.local
```
#### 🧰 ldapmodify — Modificar entradas

```bash
ldapmodify -x -H ldap://127.0.0.1:389 -D "cn=admin,dc=asir,dc=local" -w admin123 -f modificar.ldif
```
Ejemplo LDIF con *replace* y *add*:
```ldif title="modificar-profesor.ldif"
dn: cn=profesor,ou=Usuarios,dc=asir,dc=local
changetype: modify
replace: mail
mail: profesor@asir2x.local
-
add: telephoneNumber
telephoneNumber: +34 600 000 111
```
**Salida esperada:**
```
modifying entry "cn=profesor,ou=Usuarios,dc=asir,dc=local"
```

---

#### 🗑️ ldapdelete — Eliminar entradas
```bash
ldapdelete -x -H ldap://127.0.0.1:389 -D "cn=admin,dc=asir,dc=local" -w admin123 "cn=profesor,ou=Usuarios,dc=asir,dc=local"
```
**Salida esperada:**
```
deleting entry "cn=profesor,ou=Usuarios,dc=asir,dc=local"
```

## 7.Recursos recomendados

- [Documentación oficial de Docker](https://docs.docker.com/)
- [Cheatsheet Docker](https://docs.docker.com/get-started/docker_cheatsheet.pdf)
- [Repositorio Docker OpenLDAP (osixia)](https://github.com/osixia/docker-openldap)
- [phpLDAPadmin dockerizado](https://github.com/osixia/docker-phpLDAPadmin)
- [Guía ldapsearch de OpenLDAP](https://www.openldap.org/software/man.cgi?query=ldapsearch)
