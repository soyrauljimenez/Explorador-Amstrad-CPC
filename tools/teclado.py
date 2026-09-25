#!/usr/bin/env python3
"""Teclado del CPC 464 para la ventana de busqueda de la v2.

Uso:  tools/teclado.py > src/v2/teclado.inc
      tools/teclado.py --png salida.png     (maqueta para mirar la geometria)

Dibujado como en CPC Doctor: cada tecla es un recuadro, y la elegida se
rellena. Bloque principal del 464; el numerico y los cursores no caben
con teclas de este tamano y para escribir no hacen falta.

Cada tecla: x, y (pixel y linea de pantalla en Mode 1), ancho, alto,
accion, rotulo, fila y donde empieza el rotulo (pixeles desde x, para
que salga centrado).
  accion: el caracter que escribe (32 o mas), o 1 ESC (salir), 2 CLR
  (borrar todo), 3 DEL (borrar una), 4 RETURN (buscar), 5 espacio,
  0 nada (TAB, CAPS, SHIFT, CTRL: se dibujan pero el cursor las salta).
RETURN esta en dos filas, para poder llegar a ella desde las dos, con el
mismo recuadro; cada linea de barrido solo recorre las teclas de su
fila, asi que cada copia pinta la parte que le toca.
"""
import sys

U = 20           # una tecla normal, en pixeles
X0 = 10          # borde izquierdo del teclado
Y0 = 62          # primera fila (linea de pantalla)
PASO = 14        # de una fila a la siguiente
ALTO = 13        # alto de una tecla

ESC, CLR, DEL, RET, ESP = 1, 2, 3, 4, 5

def fila(n, teclas, x=0.0):
    """teclas: (ancho en unidades, accion, rotulo)"""
    out = []
    for ancho, acc, rot in teclas:
        out.append(dict(x=X0 + round(x * U), y=Y0 + n * PASO, w=round(ancho * U),
                        h=ALTO, acc=acc, rot=rot, fila=n))
        x += ancho
    return out

def car(c):
    return (1, ord(c), c)

TECLAS = []
TECLAS += fila(0, [(1, ESC, "ESC")] + [car(c) for c in "1234567890-^"] +
               [(1, CLR, "CLR"), (1, DEL, "DEL")])
TECLAS += fila(1, [(1.5, 0, "TAB")] + [car(c) for c in "QWERTYUIOP@["])
TECLAS += fila(2, [(1.5, 0, "CAPS")] + [car(c) for c in "ASDFGHJKL:;]"])
TECLAS += fila(3, [(2.25, 0, "SHIFT")] + [car(c) for c in "ZXCVBNM,./\\"] +
               [(1.75, 0, "SHIFT")])
TECLAS += fila(4, [(9, ESP, "SPACE"), (1.5, 0, "CTRL")], x=3)

# RETURN: una tecla alta a la derecha de las filas 1 y 2
ret = dict(x=X0 + round(13.5 * U), y=Y0 + PASO, w=round(1.5 * U), h=PASO + ALTO,
           acc=RET, rot="RET", fila=1)
TECLAS.insert([i for i, t in enumerate(TECLAS) if t['fila'] == 1][-1] + 1, ret)
ret2 = dict(ret, fila=2)
TECLAS.insert([i for i, t in enumerate(TECLAS) if t['fila'] == 2][-1] + 1, ret2)

def rotx(t):
    """donde empieza el rotulo, centrado en el recuadro (ancho - 1)"""
    return (t['w'] - 1 - 5 * len(t['rot'])) // 2

YMIN = min(t['y'] for t in TECLAS)
YMAX = max(t['y'] + t['h'] - 1 for t in TECLAS)


def inc():
    etiquetas = {}
    print("; Generado por tools/teclado.py: no editar a mano.")
    print(f"; Por tecla: dw x, db y, ancho, alto, accion, dw rotulo, db fila, x del rotulo")
    print(f"NTECLAS equ {len(TECLAS)}")
    print(f"KBYMIN  equ {YMIN}")
    print(f"KBYMAX  equ {YMAX}")
    print(f"KPASO   equ {PASO}")
    print("TECLAS")
    for t in TECLAS:
        if t['acc'] >= 32:
            rot = "0"
        else:
            rot = etiquetas.setdefault(t['rot'], f"kr_{t['rot'].lower()}")
        print(f"        dw    {t['x']}")
        print(f"        db    {t['y']},{t['w']},{t['h']},{t['acc']}")
        print(f"        dw    {rot}")
        print(f"        db    {t['fila']},{rotx(t)}   ; {t['rot']}")
    print("; primera tecla y cuantas hay en cada fila")
    print("KFILAS")
    for n in range(5):
        idx = [i for i, t in enumerate(TECLAS) if t['fila'] == n]
        print(f"        dw    TECLAS+{idx[0] * 10}")
        print(f"        db    {len(idx)}")
    for rot, et in etiquetas.items():
        print(f"{et:8s} db   \"{rot}\",0")


def png(nombre):
    sys.path.insert(0, 'tools')
    from fuente5 import filas
    from PIL import Image
    W, H = 320, 200
    img = Image.new('RGB', (W, H), (0, 0, 0))
    px = img.load()
    AM = (255, 255, 0)
    sel = next(t for t in TECLAS if t['rot'] == 'Q')
    for t in TECLAS:
        x0, x1, y0, y1 = t['x'], t['x'] + t['w'] - 2, t['y'], t['y'] + t['h'] - 1
        s = t is sel
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                borde = y in (y0, y1) or x in (x0, x1)
                if borde or s:
                    px[x, y] = AM
        rot = t['rot']
        lx = x0 + rotx(t)
        ly = y0 + (t['h'] - 10) // 2
        for i, c in enumerate(rot):
            g = filas(c)
            for gy in range(10):
                for gx in range(5):
                    if g[gy][gx] == '#':
                        px[lx + 5 * i + gx, ly + gy] = (0, 0, 0) if s else AM
    img.resize((W * 3, H * 3), Image.NEAREST).crop((0, (YMIN - 6) * 3, W * 3, (YMAX + 6) * 3)).save(nombre)


if __name__ == "__main__":
    if len(sys.argv) > 2 and sys.argv[1] == "--png":
        png(sys.argv[2])
    else:
        inc()
