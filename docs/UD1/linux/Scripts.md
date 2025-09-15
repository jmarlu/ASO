# Scripts en Linux

## Creación de Scripts

- ¿Dónde creo mis scripts?

  Lo primero que debemos preguntarnos es dónde vamos a crear el script.
  Si empezamos a crear el script en un directorio donde no tenemos permisos de escritura no nos dejará guardar los cambios y nuestro trabajo será en vano.

- ¿Con qué creo mis scripts?

Para la creación de scripts usaremos el editor de texto **vim o con editor nano**.

El editor Vim es mas completo y cuando lo controlas es mucho mas rápido pero el editor nano también es muy valido para empezar . Aquí tienes comandos básicos:


|        Controles         |  Funcionamiento                           |
| :----------------------: | :---------------------------------------- |
| `nano “NombreFichero”.sh` | Genera o Abre el fichero para su edición. |
|      `Control + o`       | Guardar Cambios.                          |
|      `Control + x`       | Salir.                                    |
|      `Control + _`       | Ir a una línea.                           |
|        `Alt + U`         | Deshacer.                                 |
|        `Alt + E`         | Rehacer.                                  |



En la leyenda “^” equivale a “Control” y “M-“ equivale a “Alt”.

<figure>
  <img src="../imagenes/nano.png" width="800"/>
</figure> 

- ¿Cómo empiezo mis scripts?

Lo primero será crear el “shebang” 🔀 #!/bin/bash.

<figure>
  <img src="../imagenes/shebang.png" width="200"/>
</figure>

La función del shebang es decirle al sistema operativo que cuando le digamos de ejecutar este fichero use el SHELL bash, cuya ubicación dentro del sistema es /bin/bash.
Si vamos a la ruta /bin, veremos que existe un ejecutable llamado “bash”.

<figure>
  <img src="../imagenes/bash.png" width="500"/>
</figure>

- ¿Cómo ejecuto mis scripts?

Una vez guardados los cambios debemos darle permisos de ejecución al fichero, en caso de que estemos trabajando con un script. Es importante solo dar permiso de ejecución al usuario propietario, si no se puede producir una brecha de seguridad, pues los scripts suelen almacenar/manipular datos/servicios importantes de nuestro servidor.

```bash
chmod 750 “NombreFichero”.sh
```

Una vez hecho, ya podemos ejecutar nuestro script de una de las siguientes formas:

```bash
./”NombreFichero”.sh
bash “NombreFIchero”.sh
```

!!! warning

      No uséis el comando “sh script.sh” donde script.sh es el nombre de vuestro script. Esto fuerza al terminal a usar el shell SHELL, y nosotros vamos a usar BASH. Por lo que en ciertos comandos nos dará error al usar SHELL.

## Comentarios

Importante el uso de comentarios para poder describir que hace cada parte del código, tanto de cara a vosotros como de cara a compañeros de trabajo que vayan a modificar tu código.

Para ello se usa 🔀 **“#”**:

<figure>
  <img src="../imagenes/ejemplo1.png" width="600"/>
</figure>
