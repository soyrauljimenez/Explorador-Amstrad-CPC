; Generado por tools/teclado.py: no editar a mano.
; Por tecla: dw x, db y, ancho, alto, accion, dw rotulo, db fila, x del rotulo
NTECLAS equ 58
KBYMIN  equ 62
KBYMAX  equ 130
KPASO   equ 14
TECLAS
        dw    10
        db    62,20,13,1
        dw    kr_esc
        db    0,2   ; ESC
        dw    30
        db    62,20,13,49
        dw    0
        db    0,7   ; 1
        dw    50
        db    62,20,13,50
        dw    0
        db    0,7   ; 2
        dw    70
        db    62,20,13,51
        dw    0
        db    0,7   ; 3
        dw    90
        db    62,20,13,52
        dw    0
        db    0,7   ; 4
        dw    110
        db    62,20,13,53
        dw    0
        db    0,7   ; 5
        dw    130
        db    62,20,13,54
        dw    0
        db    0,7   ; 6
        dw    150
        db    62,20,13,55
        dw    0
        db    0,7   ; 7
        dw    170
        db    62,20,13,56
        dw    0
        db    0,7   ; 8
        dw    190
        db    62,20,13,57
        dw    0
        db    0,7   ; 9
        dw    210
        db    62,20,13,48
        dw    0
        db    0,7   ; 0
        dw    230
        db    62,20,13,45
        dw    0
        db    0,7   ; -
        dw    250
        db    62,20,13,94
        dw    0
        db    0,7   ; ^
        dw    270
        db    62,20,13,2
        dw    kr_clr
        db    0,2   ; CLR
        dw    290
        db    62,20,13,3
        dw    kr_del
        db    0,2   ; DEL
        dw    10
        db    76,30,13,0
        dw    kr_tab
        db    1,7   ; TAB
        dw    40
        db    76,20,13,81
        dw    0
        db    1,7   ; Q
        dw    60
        db    76,20,13,87
        dw    0
        db    1,7   ; W
        dw    80
        db    76,20,13,69
        dw    0
        db    1,7   ; E
        dw    100
        db    76,20,13,82
        dw    0
        db    1,7   ; R
        dw    120
        db    76,20,13,84
        dw    0
        db    1,7   ; T
        dw    140
        db    76,20,13,89
        dw    0
        db    1,7   ; Y
        dw    160
        db    76,20,13,85
        dw    0
        db    1,7   ; U
        dw    180
        db    76,20,13,73
        dw    0
        db    1,7   ; I
        dw    200
        db    76,20,13,79
        dw    0
        db    1,7   ; O
        dw    220
        db    76,20,13,80
        dw    0
        db    1,7   ; P
        dw    240
        db    76,20,13,64
        dw    0
        db    1,7   ; @
        dw    260
        db    76,20,13,91
        dw    0
        db    1,7   ; [
        dw    280
        db    76,30,27,4
        dw    kr_ret
        db    1,7   ; RET
        dw    10
        db    90,30,13,0
        dw    kr_caps
        db    2,4   ; CAPS
        dw    40
        db    90,20,13,65
        dw    0
        db    2,7   ; A
        dw    60
        db    90,20,13,83
        dw    0
        db    2,7   ; S
        dw    80
        db    90,20,13,68
        dw    0
        db    2,7   ; D
        dw    100
        db    90,20,13,70
        dw    0
        db    2,7   ; F
        dw    120
        db    90,20,13,71
        dw    0
        db    2,7   ; G
        dw    140
        db    90,20,13,72
        dw    0
        db    2,7   ; H
        dw    160
        db    90,20,13,74
        dw    0
        db    2,7   ; J
        dw    180
        db    90,20,13,75
        dw    0
        db    2,7   ; K
        dw    200
        db    90,20,13,76
        dw    0
        db    2,7   ; L
        dw    220
        db    90,20,13,58
        dw    0
        db    2,7   ; :
        dw    240
        db    90,20,13,59
        dw    0
        db    2,7   ; ;
        dw    260
        db    90,20,13,93
        dw    0
        db    2,7   ; ]
        dw    280
        db    76,30,27,4
        dw    kr_ret
        db    2,7   ; RET
        dw    10
        db    104,45,13,0
        dw    kr_shift
        db    3,9   ; SHIFT
        dw    55
        db    104,20,13,90
        dw    0
        db    3,7   ; Z
        dw    75
        db    104,20,13,88
        dw    0
        db    3,7   ; X
        dw    95
        db    104,20,13,67
        dw    0
        db    3,7   ; C
        dw    115
        db    104,20,13,86
        dw    0
        db    3,7   ; V
        dw    135
        db    104,20,13,66
        dw    0
        db    3,7   ; B
        dw    155
        db    104,20,13,78
        dw    0
        db    3,7   ; N
        dw    175
        db    104,20,13,77
        dw    0
        db    3,7   ; M
        dw    195
        db    104,20,13,44
        dw    0
        db    3,7   ; ,
        dw    215
        db    104,20,13,46
        dw    0
        db    3,7   ; .
        dw    235
        db    104,20,13,47
        dw    0
        db    3,7   ; /
        dw    255
        db    104,20,13,92
        dw    0
        db    3,7   ; \
        dw    275
        db    104,35,13,0
        dw    kr_shift
        db    3,4   ; SHIFT
        dw    70
        db    118,180,13,5
        dw    kr_space
        db    4,77   ; SPACE
        dw    250
        db    118,30,13,0
        dw    kr_ctrl
        db    4,4   ; CTRL
; primera tecla y cuantas hay en cada fila
KFILAS
        dw    TECLAS+0
        db    15
        dw    TECLAS+150
        db    14
        dw    TECLAS+290
        db    14
        dw    TECLAS+430
        db    13
        dw    TECLAS+560
        db    2
kr_esc   db   "ESC",0
kr_clr   db   "CLR",0
kr_del   db   "DEL",0
kr_tab   db   "TAB",0
kr_ret   db   "RET",0
kr_caps  db   "CAPS",0
kr_shift db   "SHIFT",0
kr_space db   "SPACE",0
kr_ctrl  db   "CTRL",0
