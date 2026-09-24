; ===============================================================
;  EXPLORADOR M4  -  ROM de fondo, slot 12
;
;  |EXPLOR,@a$   navega y deja en a$ el fichero elegido.
;                BASIC lo ejecuta con RUN a$ en la linea siguiente.
;
;  Una ROM es de solo lectura y vive en #C000, la misma zona que se
;  pagina para hablar con el M4. Por eso las variables residen en
;  RAM y la rutina del protocolo se copia alli antes de usarla.
; ===============================================================

M4ROM   equ 6
MAXLEN  equ 75   ; pedir siempre el largo; el recorte lo hago yo
MAXST   equ 90               ; el nombre mas largo de la biblioteca mide 86
MAXENT  equ 130              ; 130 x 41 = 5330 bytes, muy por debajo del firmware
VISIBLE equ 16
FILA0   equ 5                ; primera fila de lista (base 0)
COL0    equ 1                ; primera columna de lista
LISTW   equ 38               ; ancho util
REP1    equ 20
REP2    equ 4
RAM     equ #8000
m4cmd   equ m4ram          ; se llama a la copia en RAM
cursor  equ   RAM+#0091
oldcur  equ   RAM+#0092
top     equ   RAM+#0093
nent    equ   RAM+#0094
linea   equ   RAM+#0095
crow    equ   RAM+#0096
ccol    equ   RAM+#0097
esdir   equ   RAM+#0098
prevfir equ   RAM+#0099
prevdir equ   RAM+#009A
repcnt  equ   RAM+#009B
rsize   equ   RAM+#009C
cmdlen  equ   RAM+#009D
pagina  equ   RAM+#009E
pagvis  equ   RAM+#009F
ptab    equ   RAM+#00A0
scradd  equ   RAM+#00A2
ptxt    equ   RAM+#00A4
destino equ   RAM+#00A6
idx     equ   RAM+#00A8
descr   equ   RAM+#00AA
rowtab  equ   RAM+#00AC
cmdbuf  equ   RAM+#00DE      ; libre desde que 'lanza' escribe en a$
m4slot  equ   cmdbuf         ; slot donde vive la ROM del M4
nomram  equ   cmdbuf+1       ; KL FIND COMMAND exige el nombre en RAM
modovac equ   cmdbuf+4       ; pasada actual de la busqueda
baselen equ   cmdbuf+5       ; longitud de la ruta de partida
si      equ   cmdbuf+6       ; indices de la ordenacion
sj      equ   cmdbuf+7
tmpptr  equ   cmdbuf+8
sk      equ   cmdbuf+10
sgap    equ   cmdbuf+11
bufbus  equ   cmdbuf+16    ; texto tecleado en la busqueda       ; longitud de la ruta de partida       ; pasada actual de la busqueda       ; KL FIND COMMAND exige el nombre en RAM
resp    equ   RAM+#011E
FONTE   equ   RAM+#024A
ENTPTR  equ   RAM+#054A
ENTBUF  equ   RAM+#0662
ENTTOP  equ   ENTBUF+5400-96  ; margen para un nombre largo mas
;  El paquete de C_CD: tamano, orden y el nombre, que puede medir 90
;  caracteres. Pegado al protocolo no cabia y pisaba el cursor.
cdbuf   equ   ENTBUF+5540    ; 3 bytes: tamano, cmd lo, cmd hi
cdname  equ   ENTBUF+5543    ; hasta 96 bytes
titbuf  equ   ENTBUF+5640    ; titulo del disco, solo letras y cifras
candbuf equ   ENTBUF+5688    ; nombre de un fichero, igual
clase   equ   ENTBUF+5701    ; 0 .BAS, 1 sin extension, 2 .BIN
ntot    equ   ENTBUF+5702    ; ficheros de la clase
sintr   equ   ENTBUF+5703    ; de ellos, los que no son de trampas
mejorl  equ   ENTBUF+5704    ; coincidencia con el titulo: longitud
mejori  equ   ENTBUF+5705    ; e indice
manual  equ   ENTBUF+5706    ; 1 = abrir el disco sin lanzar nada
ebpos   equ   ENTBUF+5707    ; busqueda de "cara B", 2 bytes
fbuf    equ   ENTBUF+5710    ; paquetes de fichero: seek, read, close
fdes    equ   ENTBUF+5718    ; descriptor del .cpr abierto
m4ram   equ RAM              ; copia ejecutable del protocolo

        org   #C000

        db    1              ; ROM de fondo
        db    1,1,0          ; version 1.1
        dw    tabla
        jp    init           ; entrada 0: inicializacion
        jp    explor         ; entrada 1: |EXPLOR

tabla   db    "EXPLORADO",'R'+#80
        db    "EXPLO",'R'+#80
        db    0

; --- no reserva memoria: se usa mientras corre y se suelta al
;     volver, para no recortarsela al juego que se cargue despues
init    ret

; --- |EXPLOR,@a$ ---
explor  or    a
        ret   z              ; sin parametros
        ld    l,(ix+0)
        ld    h,(ix+1)
        ld    (descr),hl     ; descriptor de a$

;  Una ROM no inicializa su RAM: al entrar, las variables tienen
;  lo que dejara el programa anterior. Con 'pagvis' o 'top' sucios
;  se dibuja en la pagina equivocada o desde una fila absurda.
        ld    hl,cursor
        ld    de,cursor+1
        ld    bc,24
        ld    (hl),0
        ldir

        ld    hl,m4src       ; el protocolo, a RAM
        ld    de,m4ram
        ld    bc,m4end-m4src
        ldir

;  El slot del M4 varia de una maquina a otra (el manual recomienda
;  el 7 en los 464, el 6 en los 6128). Se localiza preguntando al
;  firmware en que ROM vive el comando |M4.
        ld    hl,nomm4
        ld    de,nomram
        ld    bc,2
        ldir
        ld    a,M4ROM        ; valor por defecto si no aparece
        ld    (m4slot),a
        ld    hl,nomram
        call  #BCD4          ; KL FIND COMMAND
        jr    nc,ex_sl
        ld    a,c            ; C = slot de la ROM que lo implementa
        ld    (m4slot),a
ex_sl

start   ld    a,1
        call  #BC0E          ; Mode 1
        ld    bc,#0000
        call  #BC38          ; borde negro
        ld    a,0
        ld    b,0
        ld    c,0
        call  #BC32          ; tinta 0 negro
        ld    a,1
        ld    b,20
        ld    c,20
        call  #BC32          ; tinta 1 cian brillante
        ld    a,2
        ld    b,26
        ld    c,26
        call  #BC32          ; tinta 2 blanco brillante
        ld    a,3
        ld    b,24
        ld    c,24
        call  #BC32          ; tinta 3 amarillo brillante
        call  #BC14

        call  initfont
        call  initrow
        call  limpia
;  Se sube a la raiz (nunca falla) y desde ahi se intenta entrar en
;  la biblioteca. Si esa carpeta no existe nos quedamos en la raiz,
;  que es un sitio sensato. Luego se mide la ruta resultante: ese
;  sera el tope del que no se puede subir, sin numeros magicos.
        ld    hl,barra0
        call  cd_a
        ld    hl,raiz
        call  cd_a
        call  midepath
        ld    a,c
        ld    (baselen),a
        call  leedir
        call  marco
        call  ruta
        call  pintalista
        call  contador

bucle   call  lee_entrada
        or    a
        jr    z,bucle
        cp    1
        jr    z,arriba
        cp    2
        jr    z,abajo
        cp    3
        jp    z,salir
        cp    4
        jp    z,entrar
        cp    5
        jp    z,atras
        cp    6
        jr    z,pagarr
        cp    7
        jr    z,pagaba
        cp    8
        jp    z,busca
        cp    9
        jp    z,lista
        jr    bucle

arriba  ld    a,(cursor)
        or    a
        jr    z,bucle
        dec   a
        call  mueve
        jr    bucle

abajo   ld    a,(nent)
        ld    b,a
        ld    a,(cursor)
        inc   a
        cp    b
        jr    nc,bucle
        call  mueve
        jr    bucle

;  Paginar mueve la ventana una pantalla completa y deja el cursor
;  en su primera linea.

pagarr  ld    a,(top)
        sub   VISIBLE
        jr    nc,pa1
        xor   a
pa1     ld    b,a
        ld    a,(top)
        cp    b
        jr    nz,pa2
        xor   a              ; ya en la primera pagina: al principio
        ld    (cursor),a
        jp    repag
pa2     ld    a,b
        ld    (top),a
        ld    (cursor),a
        jp    repag

pagaba  ld    a,(top)        ; la ultima pagina se muestra tal cual:
        add   a,VISIBLE      ; si quedan tres entradas, se ven tres
        ld    b,a
        ld    a,(nent)
        ld    c,a
        ld    a,b
        cp    c
        jr    c,pb2          ; queda pagina por delante
        ld    a,(nent)       ; ya en la ultima: al final de la lista
        dec   a
        ld    (cursor),a
        jp    repag
pb2     ld    a,b
        ld    (top),a
        ld    (cursor),a
repag   call  redibuja
        jp    bucle

salir   call  #BB03          ; KM RESET: vaciar el teclado
        call  #BB48          ; KM DISARM BREAK
        ld    hl,barra0
        call  cd_a
        call  restaura
        ld    hl,(descr)     ; a$ = "" -> BASIC no ejecuta nada
        ld    (hl),0
        ret

entrar  ld    a,(cursor)
        call  entrada
        ld    a,(hl)
        cp    62             ; '>' = directorio
        jr    z,en_dir
        call  esdisk
        jr    c,en_dsk       ; .dsk: arrancar el juego directamente
        ld    de,extrom      ; un .ROM es una imagen para un slot de
        call  esext          ; la placa, no un programa: no se lanza
        jp    c,bucle
        jp    lanza          ; fichero suelto: ejecutarlo
en_dir  inc   hl             ; saltar el marcador
        call  cd_a
        call  recarga
        jp    bucle

; --- .dsk: entrar en la imagen y lanzar su cargador ---
;  Con el fuego pulsado un segundo se abre para elegir a mano, que
;  es la salida cuando el cargador elegido no es el bueno.
en_dsk  push  hl
        call  mantiene
        ld    a,0
        rla
        ld    (manual),a
        pop   hl
en_ds2  ld    de,extcpr      ; un .cpr solo si lleva un disco dentro
        call  esext
        jr    nc,en_ds3
        call  esconv         ; A: 0 disco, 1 cartucho, 2 no se abre
        or    a
        jr    z,en_ds3
        cp    1
        jr    nz,en_mal
        ld    hl,txcart
        jr    en_av
en_ds3  push  hl
        call  cd_a
        pop   hl
        ld    a,(resp+3)     ; #FF = no ha podido entrar (el mismo
        cp    #FF            ; criterio que la ROM del M4 en |CD)
        jr    z,en_mal
        call  leedir
        ld    a,(manual)
        or    a
        jr    nz,en_lis
        call  buscar
        jp    c,lanza        ; encontrado: a BASIC y a correr
en_lis  xor   a              ; sin cargador, o a mano: el contenido
        ld    (cursor),a
        ld    (top),a
        call  ruta
        call  redibuja
        jp    bucle
en_mal  ld    hl,txilegi     ; imagen que no se puede abrir
en_av   call  aviso
        jp    bucle

; --- L: una carpeta se abre; un disco, sin lanzar nada ---
lista   ld    a,(cursor)
        call  entrada
        ld    a,(hl)
        cp    62
        jp    z,en_dir
        call  esdisk
        jp    nc,bucle
        ld    a,1
        ld    (manual),a
        jr    en_ds2

; --- carry si el fuego sigue pulsado un segundo ---
;     Con ENTER no hay joystick pulsado y vuelve enseguida.
mantiene
        ld    b,50
mt1     push  bc
        call  #BD19          ; un cuadro
        call  #BB24          ; KM GET JOYSTICK
        pop   bc
        and   #20
        ret   z              ; soltado antes: lanzar
        djnz  mt1
        scf
        ret

; ---------------------------------------------------------------
;  Elige el cargador del disco recien leido. Carry = HL es el nombre;
;  sin carry, mostrar la lista para elegir a mano. En orden:
;
;   1. DISC, con cualquier extension: es lo que haria un RUN"DISC.
;   2. Una cara B (FACE B, SIDE B, CARA B, o 2): esas no se lanzan,
;      las pide el juego cuando hace falta.
;   3. De la primera clase que tenga algo (.BAS, sin extension,
;      .BIN), el fichero que se llama como el juego: COMMANDO en
;      "Commando", MOLECULE en "Molecule Man". Si hay varios, el mas
;      largo; se exigen tres letras para que una "A" no valga.
;   4. El primero que no sea de trampas (CHEAT, POKE, TRAIN). Si son
;      mas de cinco .BIN, se muestra la lista: a ciegas no se acierta.
;
;  Medido sobre 936 discos: no cambia ninguno de los 876 que tienen un
;  solo candidato, y en los ambiguos evita lanzar editores de niveles,
;  menus de trampas y caras B.
; ---------------------------------------------------------------
buscar  call  hazttl
        ld    c,0            ; 1. DISC
bu1     push  bc
        ld    a,c
        call  pasadisc
        pop   bc
        ret   c
        inc   c
        ld    a,c
        cp    3
        jr    nz,bu1
        call  esladob        ; 2. cara B
        jr    c,bu_no
        ld    c,0            ; 3. la primera clase con algo
bu2     push  bc
        ld    a,c
        call  cuenta
        pop   bc
        or    a
        jr    nz,bu3
        inc   c
        ld    a,c
        cp    3
        jr    nz,bu2
bu_no   or    a              ; nada que lanzar: la lista
        ret
bu3     call  portitulo
        ret   c
        ld    a,(clase)      ; 4. sin trampas; muchos .BIN, a mano
        cp    2
        jr    nz,bu4
        ld    a,(sintr)
        or    a
        jr    nz,bu5
        ld    a,(ntot)
bu5     cp    6
        jr    nc,bu_no
bu4     jp    primero

; --- A = indice -> HL = nombre, A = clase (0 BAS, 1 sin ext., 2 BIN, 3 otra) ---
clasede call  entrada
        push  hl
        ld    de,extbas
        call  esext
        pop   hl
        ld    a,0
        ret   c
        push  hl
        call  esvac
        pop   hl
        ld    a,1
        ret   c
        push  hl
        ld    de,extbin
        call  esext
        pop   hl
        ld    a,2
        ret   c
        ld    a,3
        ret

; --- A = clase: carry si hay un DISC en ella, HL = nombre ---
pasadisc
        ld    (clase),a
        ld    b,0
pd1     ld    a,(nent)
        cp    b
        jr    z,pd_no
        push  bc
        ld    a,b
        call  clasede
        ld    c,a
        ld    a,(clase)
        cp    c
        jr    nz,pd2
        push  hl
        call  base
        ld    a,b
        cp    4
        jr    nz,pd3
        ld    hl,candbuf
        ld    de,txdisc
        ld    b,4
        call  igualn
        jr    nc,pd3
        pop   hl
        pop   bc
        scf
        ret
pd3     pop   hl
pd2     pop   bc
        inc   b
        jr    pd1
pd_no   or    a
        ret

; --- A = clase: A = cuantos hay, (sintr) cuantos no son de trampas ---
cuenta  ld    (clase),a
        xor   a
        ld    (ntot),a
        ld    (sintr),a
        ld    b,0
cu1     ld    a,(nent)
        cp    b
        jr    z,cu9
        push  bc
        ld    a,b
        call  clasede
        ld    c,a
        ld    a,(clase)
        cp    c
        jr    nz,cu2
        push  hl
        ld    hl,ntot
        inc   (hl)
        pop   hl
        call  estrampa
        jr    c,cu2
        ld    hl,sintr
        inc   (hl)
cu2     pop   bc
        inc   b
        jr    cu1
cu9     ld    a,(ntot)
        ret

; --- en la clase (clase), el que se llama como el juego: carry, HL ---
portitulo
        xor   a
        ld    (mejorl),a
        ld    b,0
po1     ld    a,(nent)
        cp    b
        jr    z,po9
        push  bc
        ld    a,b
        call  clasede
        ld    c,a
        ld    a,(clase)
        cp    c
        jr    nz,po8
        call  base           ; B = letras del nombre
        ld    a,b
        cp    3
        jr    c,po8
        ld    c,a
        ld    a,(mejorl)
        cp    c
        jr    nc,po8         ; ya hay uno igual de largo o mas
        push  bc
        ld    hl,titbuf
        ld    de,candbuf
        ld    b,c
        call  igualn
        pop   bc
        jr    nc,po8
        ld    a,c
        ld    (mejorl),a
        pop   bc
        push  bc
        ld    a,b
        ld    (mejori),a
po8     pop   bc
        inc   b
        jr    po1
po9     ld    a,(mejorl)
        or    a
        ret   z
        ld    a,(mejori)
        call  entrada
        scf
        ret

; --- en la clase (clase), el primero que no sea de trampas; si todos lo
;     son, el primero. Carry, HL = nombre ---
primero ld    b,0
pm1     ld    a,(nent)
        cp    b
        jr    z,pm4
        push  bc
        ld    a,b
        call  clasede
        ld    c,a
        ld    a,(clase)
        cp    c
        jr    nz,pm2
        call  estrampa
        jr    c,pm2
        pop   bc
        scf
        ret
pm2     pop   bc
        inc   b
        jr    pm1
pm4     ld    b,0
pm5     ld    a,(nent)
        cp    b
        jr    z,pm_no
        push  bc
        ld    a,b
        call  clasede
        ld    c,a
        ld    a,(clase)
        cp    c
        pop   bc
        jr    z,pm_si
        inc   b
        jr    pm5
pm_si   scf
        ret
pm_no   or    a
        ret

; --- HL = nombre: carry si empieza por CHEAT, POKE o TRAIN ---
estrampa
        push  hl
        ld    de,txcheat
        ld    b,5
        call  empieza
        pop   hl
        ret   c
        push  hl
        ld    de,txpoke
        ld    b,4
        call  empieza
        pop   hl
        ret   c
        push  hl
        ld    de,txtrain
        ld    b,5
        call  empieza
        pop   hl
        ret

; --- carry si el nombre del disco dice cara B: FACE, SIDE o CARA,
;     espacios o '_', y B o 2 sueltos ---
esladob ld    hl,cdname
eb1     ld    a,(hl)
        or    a
        ret   z
        ld    (ebpos),hl
        ld    de,txface
        ld    b,4
        call  empieza
        jr    c,eb2
        ld    hl,(ebpos)
        ld    de,txside
        ld    b,4
        call  empieza
        jr    c,eb2
        ld    hl,(ebpos)
        ld    de,txcara
        ld    b,4
        call  empieza
        jr    c,eb2
eb_sig  ld    hl,(ebpos)
        inc   hl
        jr    eb1
eb2     ld    a,(hl)         ; HL ya esta tras la palabra
        cp    32
        jr    z,eb3
        cp    95             ; '_'
        jr    nz,eb4
eb3     inc   hl
        jr    eb2
eb4     call  mayus
        cp    66             ; 'B'
        jr    z,eb5
        cp    50             ; '2'
        jr    nz,eb_sig
eb5     inc   hl
        ld    a,(hl)
        call  alnum
        jr    c,eb_sig       ; "FACE BALL" no es una cara B
        scf
        ret

; --- titbuf = titulo del disco (cdname hasta '(' o '['), solo letras
;     y cifras en mayusculas ---
hazttl  ld    hl,cdname
        ld    de,titbuf
        ld    b,0
ti1     ld    a,(hl)
        or    a
        jr    z,ti9
        cp    40             ; '('
        jr    z,ti9
        cp    91             ; '['
        jr    z,ti9
        call  alnum
        jr    nc,ti2
        ld    (de),a
        inc   de
        inc   b
        ld    a,b
        cp    47
        jr    nc,ti9
ti2     inc   hl
        jr    ti1
ti9     xor   a
        ld    (de),a
        ret

; --- HL = nombre: candbuf = lo de antes del punto, solo letras y
;     cifras en mayusculas. B = cuantas ---
base    ld    de,candbuf
        ld    b,0
ba1     ld    a,(hl)
        or    a
        jr    z,ba9
        cp    46             ; '.'
        jr    z,ba9
        call  alnum
        jr    nc,ba2
        ld    (de),a
        inc   de
        inc   b
        ld    a,b
        cp    12
        jr    nc,ba9
ba2     inc   hl
        jr    ba1
ba9     xor   a
        ld    (de),a
        ret

; --- A a mayuscula; carry si es letra o cifra ---
alnum   call  mayus
        cp    48
        ccf
        ret   nc
        cp    58
        ret   c
        cp    65
        ccf
        ret   nc
        cp    91
        ret

; --- carry si HL empieza por los B caracteres de DE (en mayusculas) ---
;     HL queda tras ellos si coinciden.
empieza ld    a,(hl)
        call  mayus
        ex    de,hl
        cp    (hl)
        ex    de,hl
        jr    nz,em_no
        inc   hl
        inc   de
        djnz  empieza
        scf
        ret
em_no   or    a
        ret

; --- carry si los B bytes de HL y DE son iguales ---
igualn  ld    a,(de)
        cp    (hl)
        jr    nz,ig_no
        inc   hl
        inc   de
        djnz  igualn
        scf
        ret
ig_no   or    a
        ret

; ---------------------------------------------------------------
;  Un .cpr puede ser un cartucho de verdad, que en un CPC clasico no
;  arranca, o un juego de disco empaquetado como cartucho, en el que
;  el M4 entra con |CD como en un .dsk. No sirve preguntarle al M4:
;  con un cartucho de verdad no falla, devuelve el contenido del
;  ultimo disco que leyo. Asi que se mira dentro: en los convertidos
;  el banco 3 empieza con el directorio del disco, y en un cartucho
;  ahi hay codigo.
;
;  Fichero: "RIFF", tamano, "AMS!" y bancos de 8 + 16384 bytes, asi
;  que el banco 3 empieza en 12 + 3 x 16392 = #C024. Antes se mira el
;  tamano: si el fichero no llega, una lectura corta dejaria en el
;  bufer del M4 datos de un comando anterior.
;
;  HL = nombre, en la carpeta actual. A: 0 disco, 1 cartucho, 2 no se
;  puede abrir. HL se conserva.
; ---------------------------------------------------------------
esconv  push  hl
        ld    de,cdbuf+4     ; C_OPEN: tamano, #4301, modo, nombre
        ld    b,0
ec1     ld    a,(hl)
        ld    (de),a
        inc   hl
        inc   de
        inc   b
        or    a
        jr    nz,ec1
        ld    a,b
        add   a,3
        ld    (cdbuf),a
        ld    a,#01
        ld    (cdbuf+1),a
        ld    a,#43
        ld    (cdbuf+2),a
        ld    a,#81          ; FA_READ + #80: nombre largo, no 8.3 (lo
        ld    (cdbuf+3),a    ; mismo que hace la ROM del M4 con los .sna)
        ld    hl,cdbuf
        call  m4cmd
        ld    a,(resp+4)     ; 0 = abierto
        or    a
        jr    z,ec2
        pop   hl
        ld    a,2
        ret
ec2     ld    a,(resp+3)
        ld    (fdes),a
        ld    a,#11          ; C_FSIZE
        ld    b,3
        call  fpaq
        ld    hl,(resp+5)    ; palabra alta del tamano
        ld    a,h
        or    l
        jr    nz,ec3         ; 64 KB o mas: llega de sobra
        ld    hl,(resp+3)
        ld    de,#C024+40
        or    a
        sbc   hl,de
        jr    c,ec_car       ; demasiado corto para un banco 3
ec3     ld    hl,fbuf+4      ; C_SEEK al banco 3
        ld    (hl),#24
        inc   hl
        ld    (hl),#C0
        inc   hl
        ld    (hl),0
        inc   hl
        ld    (hl),0
        ld    a,#05
        ld    b,7
        call  fpaq
        ld    hl,fbuf+4      ; C_READ de 40 bytes
        ld    (hl),40
        inc   hl
        ld    (hl),0
        ld    a,#02
        ld    b,5
        call  fpaq
        ld    a,(resp+3)     ; 0 = leido
        or    a
        jr    nz,ec_car
        call  ecmira         ; se decide antes de cerrar: el cierre
        jr    nc,ec_car      ; pisa la respuesta
        xor   a
        jr    ec_fin
ec_car  ld    a,1
ec_fin  push  af
        ld    a,#04          ; C_CLOSE
        ld    b,3
        call  fpaq
        pop   af
        pop   hl
        ret

; --- paquete de fichero: A = orden (#43xx), B = tamano; en fbuf+4 los
;     datos que siguen al descriptor ---
fpaq    ld    hl,fbuf
        ld    (hl),b
        inc   hl
        ld    (hl),a
        inc   hl
        ld    (hl),#43
        inc   hl
        ld    a,(fdes)
        ld    (hl),a
        ld    hl,fbuf
        jp    m4cmd

; --- carry si lo leido es "cb03" y detras una entrada de directorio:
;     usuario 0-15 y un nombre de 11 caracteres legibles ---
ecmira  ld    hl,resp+4
        ld    de,txcb03
        ld    b,4
        call  igualn
        jr    nc,ek_no
        ld    a,(resp+12)
        cp    16
        jr    nc,ek_no
        ld    a,(resp+13)    ; el nombre no empieza por espacio
        and   #7F
        cp    33
        jr    c,ek_no
        ld    hl,resp+13
        ld    b,11
ek1     ld    a,(hl)
        and   #7F
        cp    32
        jr    c,ek_no
        cp    127
        jr    nc,ek_no
        inc   hl
        djnz  ek1
        scf
        ret
ek_no   or    a
        ret

txcb03  db    "cb03"
txdisc  db    "DISC"
txcheat db    "CHEAT"
txpoke  db    "POKE"
txtrain db    "TRAIN"
txface  db    "FACE"
txside  db    "SIDE"
txcara  db    "CARA"
txcart  db    "Cartucho: solo CPC Plus",0
txilegi db    "No se puede abrir",0

; --- aviso en la linea de la ruta: HL = mensaje ---
aviso   call  avisa          ; lo pinta cada version a su manera
        ld    b,100          ; dos segundos y se repone la ruta
av2     push  bc
        call  #BD19
        pop   bc
        djnz  av2
        jp    ruta

; --- el aviso, en amarillo sobre la linea de la ruta ---
avisa   push  hl
        ld    b,2
        ld    c,3
        call  setpos
        ld    hl,tabama
        ld    (ptab),hl
        pop   hl
        call  putstr
ai1     ld    a,(ccol)       ; borrar el resto de la ruta
        cp    29
        ret   nc
        ld    a,32
        call  putc
        jr    ai1

; --- HL = nombre. Carry si no tiene extension ---
;     El nombre puede llegar como "JUEGO." o como "JUEGO.   ",
;     asi que se retrocede sobre los espacios finales y se mira
;     si el ultimo caracter util es el punto.
esvac   push  hl
        ld    c,0
ev1     ld    a,(hl)
        or    a
        jr    z,ev2
        inc   hl
        inc   c
        jr    ev1
ev2     ld    a,c
        or    a
        jr    z,ev_no
ev3     dec   hl
        ld    a,(hl)
        cp    32
        jr    nz,ev4
        dec   c
        jr    nz,ev3
        jr    ev_no
ev4     cp    46             ; '.'
        jr    z,ev_si
ev_no   pop   hl
        or    a
        ret
ev_si   pop   hl
        scf
        ret

; --- HL = nombre, DE = extension de 3 letras. Carry si coincide ---
esext   push  hl
        push  de
        ld    c,0
ee1     ld    a,(hl)
        or    a
        jr    z,ee2
        inc   hl
        inc   c
        jr    ee1
ee2     ld    a,c
        cp    4
        jr    c,ee_no
        dec   hl
        dec   hl
        dec   hl
        dec   hl
        ld    a,(hl)
        cp    46             ; '.'
        jr    nz,ee_no
        ld    b,3
ee3     inc   hl
        ld    a,(hl)
        call  mayus
        ld    c,a
        ld    a,(de)
        cp    c
        jr    nz,ee_no
        inc   de
        djnz  ee3
        pop   de
        pop   hl
        scf
        ret
ee_no   pop   de
        pop   hl
        or    a
        ret

extbas  db    "BAS"
extdsk  db    "DSK"
extrom  db    "ROM"
extcpr  db    "CPR"
extbin  db    "BIN"

;  No se sube por encima de la carpeta de partida: se compara la
;  longitud de la ruta actual con la que se midio al arrancar.
atras   call  midepath
        ld    a,(baselen)
        cp    c
        jp    nc,bucle       ; ya estamos en el tope
        ld    hl,dotdot
        call  cd_a
        call  recarga
        jp    bucle

recarga call  leedir
        xor   a
        ld    (cursor),a
        ld    (top),a
        jp    redibuja

cd_a    ld    a,#08          ; C_CD, escrito a mano: cdbuf esta en RAM
        ld    (cdbuf+1),a
        ld    a,#43
        ld    (cdbuf+2),a
        ld    de,cdname
        ld    b,0
cda1    ld    a,(hl)
        ld    (de),a
        inc   hl
        inc   de
        inc   b
        or    a
        jr    nz,cda1
        ld    a,b
        add   a,2
        ld    (cdbuf),a
        ld    hl,cdbuf
        jp    m4cmd

; --- HL = nombre. Carry si termina en .DSK o .CPR ---
; ---------------------------------------------------------------
;  Buscador. Se escribe sobre la linea de la ruta y al terminar se
;  repinta. Salta a la primera entrada que empiece por lo tecleado.
; ---------------------------------------------------------------
busca   ld    b,2
        ld    c,3
        call  setpos
        ld    hl,tabama
        ld    (ptab),hl
        ld    b,36
bs0     push  bc
        ld    a,32
        call  putc
        pop   bc
        djnz  bs0
        ld    b,2
        ld    c,3
        call  setpos
        ld    hl,txtbus
        call  putstr

        ld    hl,bufbus
        ld    c,0
bs1     call  #BB06          ; KM WAIT CHAR
        cp    13
        jr    z,bs_fin
        cp    27
        jr    z,bs_sal
        cp    252
        jr    z,bs_sal
        cp    127
        jr    z,bs_del
        cp    32
        jr    c,bs1
        cp    128
        jr    nc,bs1
        ld    b,a
        ld    a,c
        cp    20             ; tope del campo
        jr    nc,bs1
        ld    a,b
        ld    (hl),a
        inc   hl
        inc   c
        call  putc
        jr    bs1

bs_del  ld    a,c
        or    a
        jr    z,bs1
        dec   hl
        dec   c
        call  retro
        ld    a,32
        call  putc
        call  retro
        jr    bs1

bs_fin  ld    (hl),0
        ld    a,c
        or    a
        jr    z,bs_sal
        ld    b,0
bs_f1   ld    a,(nent)
        cp    b
        jr    z,bs_sal       ; sin coincidencias: no mover nada
        ld    a,b
        push  bc
        call  entrada
        ld    a,(hl)
        cp    62
        jr    nz,bs_f2
        inc   hl             ; saltar el marcador de carpeta
bs_f2   ld    de,bufbus
        call  prefijo
        pop   bc
        jr    c,bs_hit
        inc   b
        jr    bs_f1
bs_hit  ld    a,b
        ld    (cursor),a
        ld    (top),a
bs_sal  call  ruta
        jp    repag

; --- retrocede una columna ---
retro   ld    a,(ccol)
        dec   a
        ld    (ccol),a
        jp    calcdir

; --- carry si (HL) empieza por (DE), sin distinguir mayusculas ---
prefijo ld    a,(de)
        or    a
        scf
        ret   z
        cp    97
        jr    c,pf1
        cp    123
        jr    nc,pf1
        sub   32
pf1     ld    c,a
        ld    a,(hl)
        cp    97
        jr    c,pf2
        cp    123
        jr    nc,pf2
        sub   32
pf2     cp    c
        jr    z,pf3
        or    a
        ret
pf3     inc   hl
        inc   de
        jr    prefijo

; --- HL = nombre. Carry si es imagen de disco (.DSK o .CPR) ---
esdisk  ld    de,extdsk
        call  esext
        ret   c
        ld    de,extcpr
        jp    esext

mayus   cp    97
        ret   c
        cp    123
        ret   nc
        sub   32
        ret

; ---------------------------------------------------------------
;  Lanzar un fichero. Construye RUN"NOMBRE" y la deja en el buffer
;  de expansion del teclado; al volver a BASIC, este la lee como
;  si se hubiera tecleado. Vale igual para .BAS y .BIN.
;  Los nombres AMSDOS traen relleno de espacios: se quitan.
; ---------------------------------------------------------------
; --- HL = nombre elegido -> a$, sin pasarse de lo reservado ---
;     Los nombres AMSDOS traen relleno de espacios: se quitan.
lanza   push  hl
        call  restaura
        ld    hl,(descr)
        ld    a,(hl)         ; longitud que reservo BASIC
        ld    (cmdlen),a
        inc   hl
        ld    e,(hl)
        inc   hl
        ld    d,(hl)         ; DE = texto de a$
        pop   hl             ; HL = nombre elegido
        ld    b,0
lz1     ld    a,(hl)
        or    a
        jr    z,lz2
        inc   hl
        cp    32             ; saltar el relleno
        jr    z,lz1
        ld    c,a
        ld    a,(cmdlen)
        cp    b
        jr    z,lz2          ; no cabe mas
        ld    a,c
        ld    (de),a
        inc   de
        inc   b
        jr    lz1
lz2     ld    a,b            ; ¿acaba en punto? (extension vacia)
        or    a
        jr    z,lz3
        dec   de
        ld    a,(de)
        cp    46
        jr    nz,lz3
        dec   b              ; quitarlo: RUN"ARKANOI2", no "ARKANOI2."
lz3     ld    hl,(descr)
        ld    (hl),b         ; longitud real escrita
        ret

; --- deja la pantalla como la espera BASIC ---; --- deja la pantalla como la espera BASIC ---
restaura
        ld    b,#BC          ; CRTC R12 -> mostrar #C000
        ld    c,12
        out   (c),c
        ld    b,#BD
        ld    c,#30
        out   (c),c
        ld    a,1
        call  #BC0E
        ld    a,0
        ld    b,1
        ld    c,1
        call  #BC32
        ld    a,1
        ld    b,24
        ld    c,24
        call  #BC32
        ld    a,2
        ld    b,20
        ld    c,20
        call  #BC32
        ld    a,3
        ld    b,6
        ld    c,6
        call  #BC32
        ld    bc,#0101
        call  #BC38
        jp    #BC14

mueve   ld    b,a
        ld    a,(cursor)
        ld    (oldcur),a
        ld    a,b
        ld    (cursor),a
        ld    a,(top)
        cp    b
        jr    z,mv_sin
        jr    c,mv_baja
        ld    a,b
        ld    (top),a
        jp    redibuja
mv_baja ld    a,b
        sub   VISIBLE-1
        jr    c,mv_sin
        ld    c,a
        ld    a,(top)
        cp    c
        jr    nc,mv_sin
        ld    a,c
        ld    (top),a
        jp    redibuja
mv_sin  ld    a,(pagvis)     ; parcial: sobre la pagina visible
        ld    (pagina),a
        ld    a,(oldcur)
        call  fila
        ld    a,(cursor)
        call  fila
        jp    contador

pintalista
        ld    a,(top)
        ld    (linea),a
        ld    b,VISIBLE
pt1     push  bc
        ld    a,(linea)
        call  fila
        ld    a,(linea)
        inc   a
        ld    (linea),a
        pop   bc
        djnz  pt1
        ret

; --- pinta la entrada A en la fila que le toca ---
fila    ld    b,a
        ld    a,(top)
        neg
        add   a,b
        cp    VISIBLE
        ret   nc
        add   a,FILA0
        ld    (crow),a
        ld    a,COL0
        ld    (ccol),a
        call  calcdir

        ld    hl,tabfic      ; tinta por defecto: fichero
        ld    (ptab),hl
        xor   a
        ld    (esdir),a

        ld    a,(nent)       ; pasada la ultima -> linea vacia
        cp    b
        jr    z,fi_vac
        jr    c,fi_vac
        ld    a,b
        call  entrada
        ld    a,(hl)
        cp    62
        jr    nz,fi_go
        inc   hl
        ld    a,1
        ld    (esdir),a
        push  hl
        ld    hl,tabdir      ; carpeta -> cian
        ld    (ptab),hl
        pop   hl
fi_go   ld    (ptxt),hl
        jr    fi_sel
fi_vac  ld    hl,vacio
        ld    (ptxt),hl

fi_sel  ld    a,(cursor)     ; seleccionada -> barra amarilla
        cp    b
        jr    nz,fi_txt
        ld    hl,tabsel
        ld    (ptab),hl
        ld    a,62           ; '>'
        call  putc
        ld    a,32
        call  putc
        jr    fi_cue
fi_txt  ld    a,32
        call  putc
        ld    a,32
        call  putc
fi_cue  ld    a,(esdir)
        or    a
        jr    z,fi_t1
        ld    a,91
        call  putc
fi_t1   ld    hl,(ptxt)
fi_t2   ld    a,(hl)
        or    a
        jr    z,fi_t3
        ld    a,(ccol)
        cp    COL0+LISTW-2
        jr    nc,fi_t3
        ld    a,(hl)
        push  hl
        call  putc
        pop   hl
        inc   hl
        jr    fi_t2
fi_t3   ld    a,(esdir)
        or    a
        jr    z,fi_t4
        ld    a,93
        call  putc
fi_t4   ld    a,(ccol)       ; rellenar: la barra ocupa todo el ancho
        cp    COL0+LISTW
        ret   nc
        ld    a,32
        call  putc
        jr    fi_t4

; --- escribe el caracter A en (ccol,crow) con la tabla (ptab) ---
;     Fuente del sistema, 8 px: cada fila se parte en dos nibbles
;     y cada nibble da un byte de pantalla en Mode 1.
putc    push  hl
        push  de
        push  bc
        ld    c,a
        ld    de,(scradd)    ; ya calculada: no se rehace por caracter
        ld    a,c            ; la fuente solo cubre del 32 al 127:
        cp    32             ; fuera de rango se leeria mas alla
        jr    c,pc_sus
        cp    128
        jr    c,pc_ok
pc_sus  ld    a,63           ; '?'
pc_ok   sub   32
        ld    l,a
        ld    h,0
        add   hl,hl
        add   hl,hl
        add   hl,hl
        ld    bc,FONTE
        add   hl,bc
        ld    b,8
pc1     push  bc
        ld    a,(hl)
        push  hl
        rrca
        rrca
        rrca
        rrca
        and   #0F
        ld    hl,(ptab)
        add   a,l
        ld    l,a
        jr    nc,pc2
        inc   h
pc2     ld    a,(hl)
        ld    (de),a
        pop   hl
        push  hl
        ld    a,(hl)
        and   #0F
        ld    hl,(ptab)
        add   a,l
        ld    l,a
        jr    nc,pc3
        inc   h
pc3     ld    a,(hl)
        inc   de
        ld    (de),a
        dec   de
        pop   hl
        inc   hl
        ld    a,d
        add   a,8
        ld    d,a
        pop   bc
        djnz  pc1
        ld    hl,(scradd)    ; avanzar dos bytes
        inc   hl
        inc   hl
        ld    (scradd),hl
        ld    a,(ccol)
        inc   a
        ld    (ccol),a
        pop   bc
        pop   de
        pop   hl
        ret

; --- cadena en (ccol,crow) con la tabla activa ---
putstr  ld    a,(hl)
        or    a
        ret   z
        push  hl
        call  putc
        pop   hl
        inc   hl
        jr    putstr

; --- B = columna, C = fila ---
setpos  ld    a,b
        ld    (ccol),a
        ld    a,c
        ld    (crow),a
calcdir push  hl
        push  de
        ld    a,(crow)
        ld    l,a
        ld    h,0
        add   hl,hl
        ld    de,rowtab
        add   hl,de
        ld    e,(hl)
        inc   hl
        ld    d,(hl)
        ld    a,(ccol)
        add   a,a
        ld    l,a
        ld    h,0
        add   hl,de
        ld    a,(pagina)
        xor   h
        ld    h,a
        ld    (scradd),hl
        pop   de
        pop   hl
        ret

; --- direccion de la fila de texto C ---
dirfila ld    l,c
        ld    h,0
        add   hl,hl
        ld    de,rowtab
        add   hl,de
        ld    e,(hl)
        inc   hl
        ld    d,(hl)
        ld    a,(pagina)
        xor   d
        ld    d,a
        ret

; --- linea horizontal continua en la fila de texto C ---
;     #F0 = los 4 pixeles del byte en tinta 1
rayah   call  dirfila
        ld    b,80
rh1     ld    a,#F0
        ld    (de),a
        inc   de
        djnz  rh1
        ret

; --- lineas verticales de los bordes, filas 0..23 ---
;     #80 = pixel izquierdo del byte, #10 = pixel derecho
rayav   ld    c,0
rv1     push  bc
        call  dirfila
        ld    b,8
rv2     push  de
        ld    a,#80
        ld    (de),a
        ld    hl,79
        add   hl,de
        ld    (hl),#10
        pop   de
        ld    a,d
        add   a,8
        ld    d,a
        djnz  rv2
        pop   bc
        inc   c
        ld    a,c
        cp    24
        jr    nz,rv1
        ret

; --- marco estatico: se pinta una sola vez ---
marco   call  rayav
        ld    c,0
        call  rayah
        ld    c,2
        call  rayah
        ld    c,4
        call  rayah
        ld    c,FILA0+VISIBLE
        call  rayah
        ld    c,FILA0+VISIBLE+3
        call  rayah

        ld    b,2            ; titulo
        ld    c,1
        call  setpos
        ld    hl,tabfic
        ld    (ptab),hl
        ld    hl,titulo
        call  putstr
        ld    b,33
        ld    c,1
        call  setpos
        ld    hl,tabfic
        ld    (ptab),hl
        ld    hl,maquina
        call  putstr
        ld    hl,tabdir      ; una barra por cada tinta disponible
        call  barra
        ld    hl,tabfic
        call  barra
        ld    hl,tabama
        call  barra

        ld    b,2            ; ayuda, dos lineas y dos columnas
        ld    c,FILA0+VISIBLE+1
        call  setpos
        ld    hl,tabfic
        ld    (ptab),hl
        ld    hl,ayuda1
        call  putstr
        ld    b,21
        ld    c,FILA0+VISIBLE+1
        call  setpos
        ld    hl,ayuda2
        call  putstr
        ld    b,2
        ld    c,FILA0+VISIBLE+2
        call  setpos
        ld    hl,ayuda3
        call  putstr
        ld    b,21
        ld    c,FILA0+VISIBLE+2
        call  setpos
        ld    hl,ayuda4
        jp    putstr

; --- ruta actual ---
; --- C = longitud de la ruta actual ---
midepath
        ld    hl,cmdpath
        call  m4cmd
        ld    hl,resp+3
        ld    c,0
mp1     ld    a,(hl)
        or    a
        ret   z
        inc   hl
        inc   c
        jr    mp1

barra   ld    (ptab),hl
        ld    a,92           ; '\\'
        jp    putc

ruta    ld    b,2
        ld    c,3
        call  setpos
        ld    hl,tabdir
        ld    (ptab),hl
        ld    b,27
rt0     push  bc
        ld    a,32
        call  putc
        pop   bc
        djnz  rt0
        ld    b,2
        ld    c,3
        call  setpos
        ld    hl,cmdpath
        call  m4cmd
        ld    hl,resp+3
;  Acotado al ancho de la fila.
rt1     ld    a,(hl)
        or    a
        ret   z
        ld    a,(ccol)
        cp    28             ; el contador empieza en la 30
        ret   nc
        ld    a,(hl)
        push  hl
        call  putc
        pop   hl
        inc   hl
        jr    rt1

; --- contador de posicion ---
contador
        ld    b,30
        ld    c,3
        call  setpos
        ld    hl,tabfic
        ld    (ptab),hl
        ld    b,9
ct0     push  bc
        ld    a,32
        call  putc
        pop   bc
        djnz  ct0
        ld    b,30
        ld    c,3
        call  setpos
        ld    a,(cursor)
        inc   a
        call  prtnum
        ld    a,47
        call  putc
        ld    a,(nent)
        call  prtnum
        ret

prtnum  ld    h,0
        ld    l,a
        ld    de,100
        call  pn1
        ld    de,10
        call  pn1
        ld    de,1
pn1     ld    a,#2F
pn2     inc   a
        or    a
        sbc   hl,de
        jr    nc,pn2
        add   hl,de
        push  hl
        call  putc
        pop   hl
        ret

initfont
        ld    de,FONTE
        ld    a,32
if1     push  af
        push  de
        call  #BBA5          ; TXT GET MATRIX
        pop   de
        di
        call  #B906          ; ROM baja ON
        ld    bc,8
        ldir
        call  #B909          ; ROM baja OFF
        ei
        pop   af
        inc   a
        cp    128
        jr    nz,if1
        ret

initrow ld    hl,#C000
        ld    de,rowtab
        ld    b,25
ir1     ld    a,l
        ld    (de),a
        inc   de
        ld    a,h
        ld    (de),a
        inc   de
        ld    a,l
        add   a,80
        ld    l,a
        jr    nc,ir2
        inc   h
ir2     djnz  ir1
        ret

; ---------------------------------------------------------------
;  Doble bufer. Se pinta entero en la pagina oculta y se conmuta
;  el CRTC, asi que el cambio ocurre entre frames y nunca se ve
;  el orden de dibujado.  R12 = #30 -> #C000,  #10 -> #4000
; ---------------------------------------------------------------
redibuja
        ld    a,(pagvis)
        xor   #80            ; pintar en la que no se ve
        ld    (pagina),a
        call  marco
        call  ruta
        call  pintalista
        call  contador

flip    ld    a,(pagina)
        ld    (pagvis),a
        or    a
        jr    z,fl_c
        ld    a,#10          ; mostrar #4000
        jr    fl_s
fl_c    ld    a,#30          ; mostrar #C000
fl_s    ld    b,#BC
        ld    c,12           ; seleccionar R12
        out   (c),c
        ld    b,#BD
        ld    c,a
        out   (c),c
        ret

; --- limpia la pagina oculta, una vez al arrancar ---
limpia  ld    hl,#4000
        ld    (hl),0
        ld    de,#4001
        ld    bc,#3FFF
        ldir
        ret

leedir  call  leerdir
        jp    ordena

leerdir ld    hl,cmdargs
        call  m4cmd
        ld    hl,ENTBUF
        ld    (destino),hl
        ld    hl,ENTPTR
        ld    (idx),hl
        xor   a
        ld    (nent),a
ld1     ld    a,(nent)
        cp    MAXENT
        ret   nc
        ld    hl,(destino)   ; ¿queda sitio para otro nombre?
        ld    de,ENTTOP
        or    a
        sbc   hl,de
        ret   nc
        ld    hl,cmdrd
        call  m4cmd
        cp    3
        ret   c
        ld    hl,(destino)
        ld    de,(idx)
        ld    a,l
        ld    (de),a
        inc   de
        ld    a,h
        ld    (de),a
        inc   de
        ld    (idx),de
        ld    hl,resp+3
        ld    de,(destino)
        ld    c,0
;  AMSDOS guarda los atributos del fichero en el bit 7 de cada
;  caracter del nombre y la extension (herencia de CP/M). Sin
;  enmascararlo, un espacio protegido llega como #A0 y ni se
;  reconoce la extension vacia ni se pinta bien el nombre.
ld2     ld    a,(hl)
        and   #7F            ; los atributos AMSDOS viajan en el bit 7
        ld    (de),a
        or    a
        jr    z,ld3
        inc   hl
        inc   de
        inc   c
        ld    a,c
        cp    MAXST
        jr    c,ld2
        xor   a              ; truncar y terminar
        ld    (de),a
ld3     inc   de
        ld    (destino),de
        ld    a,(nent)
        inc   a
        ld    (nent),a
        jr    ld1

; ---------------------------------------------------------------
;  Ordenacion alfabetica por insercion sobre la tabla de punteros.
;  No se mueven los nombres, solo sus direcciones. El marcador '>'
;  de las carpetas vale 62 y las letras empiezan en 65, asi que
;  quedan agrupadas arriba sin tratarlas como caso especial.
; ---------------------------------------------------------------
ordena  ld    a,(nent)
        cp    2
        ret   c
        ld    hl,saltos
or_g    ld    a,(hl)
        or    a
        ret   z              ; se acabaron los saltos
        ld    (sgap),a
        inc   hl
        push  hl
        call  pasada
        pop   hl
        jr    or_g

pasada  ld    a,(sgap)
        ld    (si),a
or_i    ld    a,(nent)
        ld    b,a
        ld    a,(si)
        cp    b
        ret   nc
        call  punt
        ld    e,(hl)
        inc   hl
        ld    d,(hl)
        ld    (tmpptr),de
        ld    a,(si)
        ld    (sj),a
or_j    ld    a,(sgap)
        ld    c,a
        ld    a,(sj)
        sub   c
        jr    c,or_ins       ; j < salto: ya esta en su sitio
        ld    (sk),a
        call  punt
        ld    e,(hl)
        inc   hl
        ld    d,(hl)
        ex    de,hl
        ld    de,(tmpptr)
        call  cmpstr
        jr    c,or_ins
        jr    z,or_ins
        ld    a,(sk)         ; desplazar un salto
        call  punt
        ld    e,(hl)
        inc   hl
        ld    d,(hl)
        ld    a,(sj)
        call  punt
        ld    (hl),e
        inc   hl
        ld    (hl),d
        ld    a,(sk)
        ld    (sj),a
        jr    or_j
or_ins  ld    a,(sj)
        call  punt
        ld    de,(tmpptr)
        ld    (hl),e
        inc   hl
        ld    (hl),d
        ld    a,(si)
        inc   a
        ld    (si),a
        jp    or_i

saltos  db    40,13,4,1,0

; --- A = indice -> HL = direccion de su puntero ---
;     DE se preserva: la ordenacion lo usa para el puntero activo.
punt    ld    l,a
        ld    h,0
        add   hl,hl
        push  de
        ld    de,ENTPTR
        add   hl,de
        pop   de
        ret

; --- compara (HL) con (DE) sin distinguir mayusculas ---
;     carry si (HL) < (DE), Z si iguales
cmpstr  ld    a,(de)
        cp    97
        jr    c,cs1
        cp    123
        jr    nc,cs1
        sub   32
cs1     ld    c,a
        ld    a,(hl)
        cp    97
        jr    c,cs2
        cp    123
        jr    nc,cs2
        sub   32
cs2     cp    c
        ret   nz
        or    a
        ret   z
        inc   hl
        inc   de
        jr    cmpstr

entrada ld    l,a
        ld    h,0
        add   hl,hl
        ld    de,ENTPTR
        add   hl,de
        ld    e,(hl)
        inc   hl
        ld    d,(hl)
        ex    de,hl
        ret

lee_entrada
        call  #BD19
        call  #BB09
        jr    nc,li_joy
        cp    240
        jr    z,li_up
        cp    241
        jr    z,li_dn
        cp    242
        jr    z,li_pu
        cp    243
        jr    z,li_pd
        cp    13
        jr    z,li_ok
        cp    127
        jr    z,li_bk
        cp    27
        jr    z,li_esc
        cp    252            ; ESC del CPC
        jr    z,li_esc
        cp    70             ; F
        jr    z,li_bus
        cp    102            ; f
        jr    z,li_bus
        cp    76             ; L: abrir el disco sin lanzar nada
        jp    z,li_lst
        cp    108            ; l
        jp    z,li_lst
        jr    li_joy
li_up   ld    a,1
        ret
li_dn   ld    a,2
        ret
li_esc  ld    a,3
        ret
li_ok   ld    a,4
        ret
li_bk   ld    a,5
        ret
li_pu   ld    a,6
        ret
li_pd   ld    a,7
        ret
li_lst  ld    a,9
        ret
li_bus  ld    a,8
        ret

li_joy  call  #BB24
        ld    b,a
        and   #30
        ld    d,a
        ld    a,(prevfir)
        ld    c,a
        ld    a,d
        ld    (prevfir),a
        ld    a,d
        or    a
        jr    z,lj_dir
        ld    a,c
        or    a
        jr    nz,lj_dir
        ld    a,d
        and   #20
        jr    z,lj_f2
        ld    a,4
        ret
lj_f2   ld    a,5
        ret
lj_dir  ld    a,b
        and   #0F
        jr    nz,lj_hay
        ld    (prevdir),a
        ret
lj_hay  ld    d,a
        ld    a,(prevdir)
        cp    d
        jr    z,lj_man
        ld    a,d
        ld    (prevdir),a
        ld    a,REP1
        ld    (repcnt),a
        jr    lj_act
lj_man  ld    a,(repcnt)
        dec   a
        ld    (repcnt),a
        jr    nz,lj_no
        ld    a,REP2
        ld    (repcnt),a
lj_act  ld    a,d
        and   1
        jr    z,lj_a2
        ld    a,1
        ret
lj_a2   ld    a,d
        and   2
        jr    z,lj_a3
        ld    a,2
        ret
lj_a3   ld    a,d
        and   4
        jr    z,lj_a4
        ld    a,6
        ret
lj_a4   ld    a,7
        ret
lj_no   xor   a
        ret

m4src   ld    a,(hl)
        inc   a
        ld    e,a
        ld    bc,#FE00
mc2     ld    a,(hl)
        out   (c),a
        inc   hl
        dec   e
        jr    nz,mc2
        ld    bc,#FC00
        out   (c),a
        di
        ld    a,(m4slot)
        ld    c,a
        call  #B90F
        push  bc
        ld    hl,(#FF02)
        ld    a,(hl)
        ld    (rsize),a
        ld    a,(rsize)      ; el bloque copiado cubre el nombre entero
        add   a,20           ; margen para el relleno que el tamano no cuenta
        ld    c,a
        ld    b,0
        ld    de,resp
        ldir
        xor   a
        ld    (de),a
        pop   bc
        call  #B918          ; KL ROM DESELECT
        ei
        ld    a,(rsize)
        ret
m4end

cmdargs db    argend-cmdargs-1
        db    #25,#43
        db    0
argend
cmdrd   db    3
        db    #06,#43
        db    MAXLEN
cmdpath db    2
        db    #13,#43
dotdot  db    "..",0
raiz    db    "/ROMS",0
txtbus  db    "Buscar: ",0
barra0  db    "/",0
nomm4   db    "M",'4'+#80   ; nombre RSX en formato del firmware

titulo  db    "EXPLORADOR",0
maquina db    "AUA",0
ayuda1  db    "ARR/ABA: ELEGIR",0
ayuda2  db    "FUEGO: ABRIR",0
ayuda3  db    "IZQ/DER: PAGINADO",0
ayuda4  db    "SALTAR: ATRAS",0
vacio   db    0

tabdir  db    #00,#10,#20,#30,#40,#50,#60,#70,#80,#90,#A0,#B0,#C0,#D0,#E0,#F0
tabfic  db    #00,#01,#02,#03,#04,#05,#06,#07,#08,#09,#0A,#0B,#0C,#0D,#0E,#0F
tabama  db    #00,#11,#22,#33,#44,#55,#66,#77,#88,#99,#AA,#BB,#CC,#DD,#EE,#FF   ; amarillo sobre negro
tabsel  db    #FF,#EE,#DD,#CC,#BB,#AA,#99,#88,#77,#66,#55,#44,#33,#22,#11,#00



; ---------------------------------------------------------------
;  Los buffers se colocan detras del codigo, calculados por el
;  ensamblador. Antes estaban en direcciones fijas y al crecer el
;  programa se solapo con el juego de caracteres: las variables
;  machacaban glifos y los digitos salian corruptos.
; ---------------------------------------------------------------

        defs  #4000-($-#C000),#FF
