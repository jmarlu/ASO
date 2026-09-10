.TL
Guia WSL2 + Ubuntu + LXD + Docker para laboratorio (Windows 10/11)
.AU
Laboratorio ASO
.PP
Objetivo: que el alumnado en Windows 10/11 tenga el mismo flujo de trabajo que en Linux, usando Ubuntu en WSL2 con Docker (LDAP) y LXD (Samba).
.PP
Nota: esta guia asume un ordenador por alumno. No se trata la solucion de WiFi/bridge. Todo sucede en el mismo equipo.
.NH 1
Requisitos
.IP "-" 2
Windows 10 (2004 o superior) o Windows 11.
.IP "-" 2
Virtualizacion activada en BIOS/UEFI.
.IP "-" 2
Permisos de administrador local.
.IP "-" 2
Espacio libre: 10-20 GB.
.IP "-" 2
No usar Docker Desktop a la vez que Docker dentro de WSL2.
.NH 1
Instalacion de WSL2 y Ubuntu
.NH 2
Paso 1: Instalar WSL2 + Ubuntu
.PP
Abrir PowerShell como administrador y ejecutar:
.nf
wsl --install -d Ubuntu-22.04
.fi
.PP
Reiniciar si lo solicita. Al abrir Ubuntu por primera vez, se creara usuario y contrasena.
.PP
Abrir Ubuntu desde el menu Inicio o con:
.nf
wsl -d Ubuntu-22.04
.fi
.NH 2
Paso 2: Activar systemd (necesario para LXD)
.PP
En Ubuntu:
.nf
sudo tee /etc/wsl.conf >/dev/null <<'EOS'
[boot]
systemd=true
EOS
.fi
.PP
Cerrar Ubuntu y reiniciar WSL:
.nf
wsl --shutdown
.fi
.PP
Volver a abrir Ubuntu.
.NH 1
Instalacion de Docker y LXD en Ubuntu (WSL2)
.NH 2
Paso 3: Actualizar e instalar paquetes
.PP
En Ubuntu:
.nf
sudo apt-get update
sudo apt-get install -y docker.io lxd ldap-utils
.fi
.NH 2
Paso 4: Permisos y servicios
.PP
En Ubuntu:
.nf
sudo usermod -aG docker "$USER"
sudo usermod -aG lxd "$USER"
newgrp docker
newgrp lxd
sudo systemctl enable --now docker
.fi
.NH 2
Paso 5: Inicializar LXD (modo NAT)
.PP
En Ubuntu:
.nf
sudo lxd init --auto
.fi
.NH 1
LDAP en Docker (mismo equipo)
.PP
El LDAP corre en Docker dentro de Ubuntu WSL2 y publica el puerto 1389.
.PP
Ejemplo (usar la imagen LDAP del laboratorio):
.nf
docker run -d --name ldap \
  -p 1389:1389 \
  -e LDAP_ORGANISATION="Laboratorio" \
  -e LDAP_DOMAIN="laboratorio.local" \
  -e LDAP_ADMIN_PASSWORD="admin" \
  osixia/openldap:1.5.0
.fi
.PP
Valores del laboratorio (segun provision.sh):
.nf
LDAP_PORT=1389
LDAP_BASE=dc=laboratorio,dc=local
LDAP_BINDDN=cn=admin,dc=laboratorio,dc=local
LDAP_BINDPW=admin
.fi
.NH 1
Acceso desde contenedor LXD (Samba) al LDAP
.PP
Docker y LXD usan redes NAT diferentes. El contenedor LXD debe acceder al LDAP a traves del host.
.PP
Obtener IP del host en la red de LXD (lxdbr0):
.nf
ip -4 addr show lxdbr0 | awk '/inet /{print $2}'
.fi
.PP
Ejemplo tipico: 10.0.0.1/24. Usar 10.0.0.1 como LDAP_HOST en el contenedor LXD:
.nf
ldap://10.0.0.1:1389
.fi
.PP
Prueba desde el LXD:
.nf
lxc exec samba -- ldapsearch -x -H ldap://10.0.0.1:1389 -b "dc=laboratorio,dc=local"
.fi
.NH 1
Acceso a VM VirtualBox (Host-Only)
.PP
WSL2 no ve la red Host-Only de VirtualBox. Para acceder desde WSL2, se recomienda anadir un segundo adaptador NAT y hacer reenvio de puertos.
.PP
En VirtualBox (VM Ubuntu):
.IP "1." 2
Adaptador 1 = Host-Only (como ya lo teneis).
.IP "2." 2
Adaptador 2 = NAT.
.IP "3." 2
Reenvio de puertos: Host 2222 -> Guest 22 (SSH).
.PP
Desde Ubuntu (WSL2):
.nf
ssh usuario@127.0.0.1 -p 2222
.fi
.PP
Para otros servicios, abrir mas puertos en NAT y conectar a 127.0.0.1:PUERTO.
.NH 1
Checklist final
.IP "-" 2
Ubuntu WSL2 abre y tiene usuario creado.
.IP "-" 2
systemd activo (WSL reiniciado).
.IP "-" 2
Docker y LXD instalados y funcionales.
.IP "-" 2
LDAP en Docker con puerto 1389 publicado.
.IP "-" 2
LXD accede al LDAP via IP de lxdbr0 (10.0.0.1 tipico).
.IP "-" 2
VM VirtualBox accesible desde WSL2 por NAT + port forwarding.
