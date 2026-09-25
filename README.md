# Explorador Amstrad CPC

por Raul Jimenez · licencia MIT

Explorador de ficheros en ROM para el **M4 Board**. Navega la microSD con
joystick, muestra los nombres de fichero completos y **arranca los juegos
directamente** al pulsar fuego sobre una imagen `.dsk`.

Se abre tecleando **`|E`** en BASIC (o `|EXPLOR`, su nombre largo). No
necesita ningún fichero en la tarjeta, y el arranque automático al
encender es opcional.

![El explorador listando una carpeta](docs/v2-explorador.png)

*Captura generada con la misma fuente y la misma maquetación que usa la
ROM.*

## Por qué existe

M4FE, el front-end habitual del M4, muestra los nombres mutilados
—`ALIENS~2.DSK`— porque en Mode 1 solo le caben unos 13 caracteres por
línea: gasta un panel lateral fijo en la ayuda y le queda poco sitio.

Este explorador mueve la ayuda al pie de pantalla y aprovecha el ancho
entero para el nombre. Con el mismo hardware.

## Cómo es

| | M4FE | Explorador |
|---|---|---|
| Modo | Mode 1, 40 col | Mode 1, **64 col** |
| Nombre visible | ~13 caracteres | **58 caracteres** |
| Juegos por página | — | 14 |
| Ayuda | Panel lateral | Pie de pantalla |
| Arranque de juegos | Entrar y elegir | **Directo sobre el `.dsk`** |

### 64 columnas en Mode 1

La idea de partida era pasar a Mode 2, que tiene 80 columnas, sin
perder el color: Mode 2 solo tiene dos tintas, y conseguir más obliga a
reescribir la paleta mientras el haz baja por la pantalla. Funciona,
pero solo mientras el programa está parado; cada vez que redibuja o lee
la tarjeta, los colores saltan.

Así que se queda en **Mode 1** y gana columnas por la letra: una fuente
propia de 4 píxeles de ancho más uno de separación, con interlineado y
descendentes de verdad. Cuatro colores sin trucos de temporización, así
que no hay nada que pueda parpadear.

Por dentro:

- **Letras que no encajan en bytes.** En Mode 1 un byte son 4 píxeles y
  una letra ocupa 5, así que casi siempre comparte byte con la
  vecina. Los glifos se guardan ya desplazados en sus cuatro posiciones
  posibles dentro del byte, listos para combinarse con una máscara de
  color, y solo con las líneas que llevan tinta: una coma o un guion no
  ocupan diez.
- **Filas compuestas en RAM.** Cada fila se monta entera en un búfer y se
  copia a pantalla de una vez: no hay que leer la pantalla, que desde la
  ROM ni siquiera se puede en la página `#C000`, y solo se pintan las
  líneas de cada letra que llevan tinta. Cambiar de página tarda menos de
  tres décimas.
- **Filas de 10 líneas.** Ya no coinciden con las de 8 del CRTC, así que
  cada fila guarda la dirección de su primera línea de barrido.

La fuente se dibuja con `#` y `.` en [`tools/fuente5.py`](tools/fuente5.py):
corregir una letra es cambiar su línea y regenerar el include.

## Qué hace

- **Nombres completos.** `Abu Simbel Profanation (S) (1986) (Trainer).dsk`
  se lee entero, sin códigos ni abreviaturas.
- **Arranque directo.** Fuego sobre un `.dsk` entra en la imagen, elige
  el cargador y lo ejecuta. Sin pasos intermedios.
- **Elegir a mano cuando haga falta.** La tecla `L`, o mantener fuego un
  segundo, abre el disco y enseña sus ficheros sin lanzar nada.
- **Juegos en `.cpr`.** Los juegos de disco empaquetados como cartucho
  se abren y se lanzan como un `.dsk`, también en un CPC clásico.
- **Joystick o teclado.** Cursores para elegir, izquierda y derecha para
  paginar, dos botones para entrar y volver.
- **Ordenación alfabética**, con las carpetas agrupadas arriba.
- **Buscar en la carpeta o en toda la biblioteca.** `F` busca en la
  carpeta y `G` en todas; el texto vale en cualquier parte del nombre,
  sin distinguir mayúsculas. Se escribe con el teclado o, con el
  joystick, en un teclado del 464 dibujado en pantalla.
- **El nombre largo, entero.** Si un nombre no cabe en la línea, al
  elegirlo se lee completo en el pie.
- **En castellano o en inglés.** Con `C` se elige, y se recuerda.
- **Sin parpadeo.** Doble búfer de pantalla: se dibuja en la página
  oculta y se conmuta el CRTC de un frame al siguiente.
- **Sin ficheros auxiliares.** `|E` desde BASIC, y el explorador
  carga y arranca el juego él mismo.
- **Arranque automático opcional.** Una línea en `AUTOEXEC.BAS` y sale al
  encender; ESC te deja en BASIC.

## Controles

| Tecla / mando | Acción |
|---|---|
| Arriba / abajo | Elegir |
| Izquierda / derecha | Página |
| FUEGO 1 / ENTER | Abrir carpeta o **ejecutar juego** |
| `L` / FUEGO 1 un segundo | Sobre un juego: abrirlo **sin lanzarlo**, para elegir a mano |
| FUEGO 2 / DEL | Volver atrás |
| `F` | Buscar en esta carpeta (otra vez `F` y ENTER: la siguiente) |
| `G` | Buscar en toda la biblioteca |
| `C` | Configuración: idioma |
| ESC | Volver a BASIC |

### Buscar

`F` y `G` abren una ventana con un teclado como el del 464. Con el
joystick se elige tecla y FUEGO la pulsa; `RET` busca, `DEL` borra una
letra, `CLR` todo, `ESC` cierra, y FUEGO 2 también borra. El teclado de
verdad sirve igual: se escribe, ENTER busca y ESC cierra.

- **`F`** salta a la siguiente entrada de la carpeta que contenga el
  texto, dando la vuelta al final. El texto se queda escrito: `F` y
  ENTER otra vez, la siguiente.
- **`G`** recorre todas las carpetas desde `/ROMS` y enseña lo
  encontrado como una carpeta más, con la ruta delante:
  `R/Rally II (UK) (1985).dsk`. Fuego sobre un resultado lo abre o lo
  lanza como siempre, y FUEGO 2 vuelve a donde estabas. Si no encuentra
  nada, dice cuántas carpetas y ficheros ha mirado.

### Configuración

`C` abre la configuración. Por ahora, el idioma: castellano o inglés.
Se guarda en `/EXPLOR.CFG`, en la raíz de la tarjeta, y se recuerda al
volver a encender.

## Cómo arranca los juegos

El explorador carga el fichero elegido y lo arranca él mismo, del mismo
modo que la ROM del M4 ejecuta el `AUTOEXEC.BAS` al encender:

- **Un BASIC** se carga en `#0170`, donde lo espera BASIC, se ajustan sus
  punteros de fin de programa y se llama a la rutina de `RUN` de la ROM
  de BASIC, con las direcciones de cada modelo (464, 664 y 6128).
- **Un binario** se carga en su dirección y se salta a su arranque.
- **Un BASIC guardado en ASCII**, sin cabecera, no se puede arrancar así:
  el explorador vuelve a BASIC con el `RUN"…"` escrito para teclearlo.

Las versiones anteriores dejaban el nombre en una variable y era BASIC el
que hacía el `RUN`. Esa forma sigue funcionando, para no romper las
instalaciones que la usan:

```basic
10 a$=SPACE$(40)
20 |EXPLOR,@a$
30 IF a$<>"" THEN RUN a$
```

### Qué cargador elige

Candidatos son los `.BAS`, los ficheros con **extensión en blanco** (muy
comunes en los discos de CPC) y los `.BIN`, por ese orden. Cuando hay
más de uno decide así:

1. Un fichero **`DISC`**, que es lo que haría un `RUN"DISC`.
2. Si el disco es una **cara B** (*Face B*, *Side B*, *Cara B* o `2`),
   no lanza nada y enseña la lista: esas caras las pide el juego.
3. El que **se llama como el juego**: `COMMANDO` en *Commando*,
   `MOLECULE` en *Molecule Man*. Con tres letras como mínimo.
4. El primero que **no sea de trampas** (`CHEAT`, `POKE`, `TRAIN`). Si
   son más de cinco `.BIN`, enseña la lista: ahí no se acierta a ciegas.

Lo habitual es que un disco tenga un solo candidato, y entonces no hay
nada que decidir. Estas reglas solo entran en juego con los ambiguos,
donde evitan lanzar un editor de niveles, un menú de trampas o una cara B. Si aun así elige
mal, `L` o el fuego largo abren el disco para elegir a mano.

Si no hay ningún candidato, muestra el contenido. Los `.ROM` no se
ejecutan: son imágenes para un slot de la placa.

### Juegos en `.cpr`

Un `.cpr` puede ser dos cosas:

- **Un juego de disco empaquetado como cartucho**, para jugarlo en una
  GX4000. El M4 entra en él como en un `.dsk` y el explorador lo lanza
  igual, también en un 464 o un 6128 clásicos.
- **Un cartucho de verdad**, que necesita el hardware de un CPC Plus. El
  explorador avisa con *Cartucho: solo CPC Plus* y no lo abre.

No basta con preguntar al M4: con un cartucho de verdad no falla, sino
que devuelve el contenido del último disco que leyó. Así que el
explorador mira dentro del fichero: en los convertidos, el banco 3 empieza
con el directorio del disco; en un cartucho, ahí hay código.

## Instalación

1. Sube [`build/EXPLOR2.ROM`](build/EXPLOR2.ROM) a un slot libre del M4
   (del 8 al 15 en un 6128; en un 464 hace falta ROM baja modificada).
   Página **Roms** de la interfaz web, botón **Upload** del slot.
2. Reinicia el M4 y comprueba con `|M4HELP` que aparece en su slot.
3. En BASIC, teclea `|E`.

El slot donde viva la ROM del M4 se detecta solo, preguntando al firmware
dónde está el comando `|M4`. Funciona con el 6, el 7 o donde lo tengas.

![La búsqueda en toda la biblioteca](docs/v2-buscador.png)

## Arranque automático (opcional)

Para que salga al encender, graba en el CPC un `AUTOEXEC.BAS` de una
línea:

    NEW
    10 |E
    SAVE"AUTOEXEC.BAS"

El `SAVE` **debe hacerse en el CPC**: el arranque automático necesita el
fichero tokenizado y con cabecera AMSDOS, que es justo lo que produce el
`SAVE` del propio intérprete.

Con ESC sales a BASIC sin reiniciar, y `RUN` vuelve a abrirlo. Para
quitar el arranque automático, borra `AUTOEXEC.BAS` de la tarjeta.

Si tenías el arranque de las versiones anteriores (`A.BAS`, `E.BAS` y el
fichero `EXPON`), sigue funcionando con esta ROM, pero solo lanza el
explorador al encender si `EXPON` vale 1, y salir con ESC lo pone a 0.
`|E` no lo toca. Para pasarte al nuevo, graba el `AUTOEXEC.BAS` de
arriba encima del antiguo; `A.BAS`, `E.BAS` y `EXPON` ya no hacen falta.

## Configuración

Arranca en `/ROMS` y no deja subir por encima. Para otra carpeta, cambia
la cadena `raiz` en `src/v2/explorador.asm`; el tope se ajusta solo, porque mide la ruta de partida en vez de usar un
número fijo. Si esa carpeta no existe, se queda en la raíz.

## Compilar

Necesitas **rasm**, de Roudoudou — ver [`tools/rasm.md`](tools/rasm.md).

```bash
./tools/rom.sh v2                    # ensambla build/EXPLOR2.ROM
M4=192.168.1.42 ./tools/rom.sh v2 12 # y ademas la sube al slot 12
```

Si cambias la fuente o el teclado de la búsqueda, regenera antes sus
tablas:

```bash
python3 tools/fuente5.py > src/v2/glifos5.inc
python3 tools/teclado.py > src/v2/teclado.inc
```

Con `RESET=s` el script reinicia además el M4 al terminar la subida, sin
preguntar.

## Limitaciones conocidas

- **La búsqueda en toda la biblioteca** guarda como mucho 130
  resultados; si hay más, se para y lo indica con un `+` tras el texto.
- **Volver desde un juego es reiniciar**, con el botón CPC Reset del M4.
  Con el arranque automático sale el explorador; sin él, BASIC. Volver
  sin perder la partida exigiría una NMI.
- **Los cargadores BASIC guardados en ASCII** no se arrancan solos:
  el explorador deja escrito el `RUN"…"` para teclearlo.
- **La heurística del cargador fallará en algún disco.** Cuando pase, el
  listado interno es la red de seguridad.
- **130 entradas por directorio** como máximo.
- **Los cartuchos de verdad no se lanzan**, ni siquiera en un Plus: el M4
  tiene `|CTRUP` y `|CTR` para eso, pero sin un Plus no se ha podido
  probar.
- **Los nombres de más de 58 caracteres se cortan** con `..` al final.
  En la M, la W, la m y la w los trazos llegan a la columna de separación
  y rozan la letra siguiente: con 4 píxeles no caben sus tres patas.
- **Probado en un CPC 464** con ROM baja de 6128 y el M4 en el slot 6.
  Si lo usas en otra configuración, cuenta qué tal.

## Historial

**v2.2**

- `|E` (o `|EXPLOR`) sin nada más: el explorador carga y arranca el
  juego él mismo, sin `A.BAS` ni `E.BAS`. El arranque automático pasa
  a ser una línea opcional en `AUTOEXEC.BAS`, y ESC vuelve a BASIC sin
  reiniciar.
- La forma anterior, `|EXPLOR,@a$`, sigue funcionando.
- Búsqueda en toda la biblioteca con `G`, además de la de la carpeta con
  `F`. Las dos buscan el texto en cualquier parte del nombre.
- Ventana de búsqueda con un teclado del 464 en pantalla, para escribir
  con el joystick, dibujado como el de CPC Doctor.
- Castellano o inglés, a elegir con `C` y guardado en `/EXPLOR.CFG`.
- El nombre que no cabe en la línea se lee entero en el pie.
- `L` solo actúa sobre juegos.
- El M4 rechaza rutas absolutas como `/ROMS/R` si no se está en la raíz:
  ahora se cambia de carpeta por partes.
- La versión de 40 columnas queda **descontinuada**. Su última versión
  es la [v1.1](../../releases/tag/v1.1).

**v1.1 y v2.1** — lo mismo en las dos:

- Elección del cargador más fina: `DISC`, nombre del juego, fuera las
  trampas y las caras B. No cambia ningún disco con un solo candidato.
- `L` o fuego largo para abrir un disco sin lanzarlo y elegir a mano.
- Juegos en `.cpr` convertidos desde disco; aviso con los cartuchos de
  verdad.
- Corregido: los discos con nombres de más de 77 caracteres pisaban las
  variables del cursor al entrar en ellos.

**v2.0** — Mode 1 a 64 columnas con fuente propia de 5×10 y los colores
de la v1.

**v1.0** — primera versión: Mode 1 a 40 columnas.

## Agradecimientos

A la **Asociación de Usuarios de Amstrad (AUA)**, para quien se ha hecho
este explorador. Por mantener viva una máquina de 1984 cuarenta años
después, por conservar el software y la documentación que de otro modo
se habrían perdido, y por seguir siendo el sitio donde preguntar cuando
algo no funciona.

A **Antero Martínez**, por las pistas para sacar cuatro colores en
Mode 2. Tirando de ese hilo se exploraron los rasters, las franjas por
interrupción y el entrelazado, y de ahí salió la v2.

A **Jose Antonio**, por la sugerencia de cargar juegos en `.cpr`, que
llevó a las versiones 1.1 y 2.1.

Nada de esto tendría sentido sin una comunidad que siga encendiendo
estos ordenadores.

## Créditos

Explorador y documentación: **Raul Jimenez**, para la Asociación de
Usuarios de Amstrad (AUA).

El **M4 Board** es obra de **Duke** (spinpoint.org). **M4FE**, el
front-end que inspiró este proyecto, de **Abalore**. El ensamblador
**rasm** es de **Roudoudou**.
