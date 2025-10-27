# ⚙️ Docker Compose

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
      LDAP_TLS: "false"
    ports:
      - "389:389"
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