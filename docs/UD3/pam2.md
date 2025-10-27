---
title: "Bloque 2 · PAM y SSSD (Teoría y Laboratorio LDAP)"
---

🔐 PAM (Pluggable Authentication Modules)
🧩 ¿Qué es PAM?

PAM (Pluggable Authentication Modules) es el sistema modular que usa GNU/Linux para gestionar la autenticación, autorización y sesión de usuarios.

Funciona como una interfaz intermedia entre las aplicaciones (como login, ssh, sudo, su, lightdm, sddm, etc.) y los diferentes mecanismos de autenticación (como /etc/passwd, LDAP, Kerberos o tokens).

💡 En pocas palabras:

        PAM decide quién puede acceder, cómo se valida y qué se hace al iniciar/cerrar sesión.