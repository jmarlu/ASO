# Los procesos

Un proceso representa un programa **en curso de ejecución** y, al mismo tiempo, todo su entorno de
ejecución (memoria, estado, identificación, propietario, padre...).

El entorno viene marcado por:

- **Un número de proceso único PID (Process ID)**
- **Un número de proceso padre PID (Parent Process ID)**. Todos los procesos tienen un PPID salvo el proceso 0, que es un seudoproceso que representa el inicio del sistema (crea el 1 init).
- **Un número de usuario y uno de grupo**: corresponde al UID y al GID de la cuenta de usuario que inicia el proceso.
- **Duración y prioridad del proceso**. No todos los procesos tienen la misma prioridad para ser ejecutados por el procesador.
- **Directorio de Trabajo.** . desde que directorio se ha lanzado el proceso.
- **Archivos abiertos por el proceso**.

Un proceso pasa por distintos estados durante la ejecución del mismo:

- en espera E/S (**waiting**)
- dormido (**sleeping**)
- listo para la ejecución (**runnable**)
- dormido en el swap (**memoria virtual**)
- nuevo proceso
- fin de proceso
- (**zombie**). Cuando un padre termina sus hijos terminan. Pero, cuando algunos de sus hijos queda ejecutándose y su padre termina se le denomina de esa manera.

Además se pueden ejecutar de dos formas:

- ejecución en modo usuario (user mode)
- ejecución en modo núcleo (kernel mode)

## Ejecución en segundo plano\.

En entornos multitarea hay muchos procesos en ejecución o un estado que hemos comentado anteriormente. El shell es un programa que provoca un proceso y cuando **se ejecuta algún comando se produce un proceso hijo**. Hasta que no termine el este proceso no se puede ejecutar otro. Pero, este comportamiento lo podemos cambiar mediante el `&`. En este caso, el shell y el comando iniciado funcionarán en paralelo.

```bash title="Ejemplo de ejecución en segundo plano"
ls -R / > ls.txt 2>/dev/null &
[2] 55351
# No da los siguiente trabajos  mediante el comando jobs
 jobs
[1]-  Ejecutando              ls --color=auto -R / 2/dev/null > ls.txt &
[2]+  Ejecutando              ls --color=auto -R / > ls.txt 2> /dev/null &

```

Podemos parar un proceso de forma temporal con ++ctrl++ \+ ++z++. Lo lleva a segundo plano y se para, como podemos ver en el siguiente ejemplo:

```bash title="Parada y puesta en segundo plano"
sleep 100
^Z

[1]+  Detenido                sleep 100

```

Para reanudar el proceso lo tenemos que poner en primer plano con el comando `fg`

```bash title="A primer plano "
fg
sleep100
```

Con el comando `bg` un job parado para iniciarlo de nuevo en segundo plano.

```bash title="Ejemplo de bg"
jobs
# listo los trabajos
[1]+  Detenido                sleep 100
# Ejecuto en segundo plano el trabajo con el número 1
 bg 1
[1]+ sleep 100 &

```

## Lista de los procesos

El comando `ps (process status)` permite obtener información sobre los procesos en curso.

```bash title="Ejemplo de ps con las opciones ef"
ps -ef
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 19:12 ?        00:00:06 /sbin/init splash
root           2       0  0 19:12 ?        00:00:00 [kthreadd]


```

Nos muestra una salida de todos los procesos `(-e)` y con más información sobre ellos `(-f)`. Si queremos toda la información deberemos utilizar la opción `-l`.

```bash title="Ejemplo de ps con la opción u"
ps -u root
    PID TTY          TIME CMD
      1 ?        00:00:06 systemd

```

Nos muestra información de los procesos pertenecientes a root. Como podemos ver, no nos muestra tantas columnas.

## Parada de un proceso/señales

El comando kill no es obligatoriamente destruir o terminar un proceso, sino mandar señales a los procesos.

```bash title="Sintaxis de kill"
kill [-l] -Num_señal PID [PID2...]

```

Cuando se manda una señal a un proceso, éste debe interceptarla y reaccionar en consecuencia.

```bash title="Ejemplo de kill"

kill -l     (lista todas las posibles señales que pueden enviarse a un proceso)
 1) SIGHUP       2) SIGINT       3) SIGQUIT      4) SIGILL
 5) SIGTRAP      6) SIGABRT      7) SIGBUS       8) SIGFPE
 9) SIGKILL     10) SIGUSR1     11) SIGSEGV     12) SIGUSR2
13) SIGPIPE     14) SIGALRM     15) SIGTERM     16) SIGSTKFLT
17) SIGCHLD     18) SIGCONT     19) SIGSTOP     20) SIGTSTP
21) SIGTTIN     22) SIGTTOU     23) SIGURG      24) SIGXCPU
25) SIGXFSZ     26) SIGVTALRM   27) SIGPROF     28) SIGWINCH
29) SIGIO       30) SIGPWR      31) SIGSYS      34) SIGRTMIN
35) SIGRTMIN+1  36) SIGRTMIN+2  37) SIGRTMIN+3  38) SIGRTMIN+4
39) SIGRTMIN+5  40) SIGRTMIN+6  41) SIGRTMIN+7  42) SIGRTMIN+8
43) SIGRTMIN+9  44) SIGRTMIN+10 45) SIGRTMIN+11 46) SIGRTMIN+12
47) SIGRTMIN+13 48) SIGRTMIN+14 49) SIGRTMIN+15 50) SIGRTMAX-14
51) SIGRTMAX-13 52) SIGRTMAX-12 53) SIGRTMAX-11 54) SIGRTMAX-10
55) SIGRTMAX-9  56) SIGRTMAX-8  57) SIGRTMAX-7  58) SIGRTMAX-6
59) SIGRTMAX-5  60) SIGRTMAX-4  61) SIGRTMAX-3  62) SIGRTMAX-2
63) SIGRTMAX-1  64) SIGRTMAX
```

En el anterior ejemplo nos muestra todas las señales que podemos mandar, por defecto manda la 15 (SIGTERM). Pide al
proceso terminar con **normalidad**.

```bash title="Ejemplo de señales"
sleep 100&
[1] 62497
 kill 62497
 jobs
[1]+  Terminado               sleep 100
 sleep 100&
[1] 62642
 kill -9 62642
 jobs
[1]+  Terminado (killed)      sleep 100

```
