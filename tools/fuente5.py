#!/usr/bin/env python3
"""Fuente de 5x10 de la v2: 64 columnas en Mode 1.

Uso:  tools/fuente5.py > src/v2/glifos5.inc

Los glifos se dibujan aqui abajo con '#' y '.'; corregir una letra es
cambiar su linea y regenerar el include.

Glifos de 4 pixeles de ancho mas uno de separacion. Frente a la de 3 de
ancho (fuente4.py), la cuarta columna permite diagonales de verdad en la
N o el cero tachado. La M, la W, la m y la w usan tambien la quinta, la
de separacion: con cuatro columnas no caben sus tres trazos, y la m se
leia como una n.

Filas: la 0 queda libre como interlineado. Mayusculas y digitos en las
1-7, minusculas con la altura x en las 3-7, descendentes en las 8-9.
Aqui se dibujan en coordenadas de 9 filas (0-8) y se desplazan una al
emitirlas.
"""
import sys

G = {}

def g(c, *filas, desde=0):
    m = ["....."] * 9
    for i, f in enumerate(filas):
        m[desde + i] = f.ljust(5, ".")
    G[c] = m

# --- signos ---
g(' ')
g('!', ".#..", ".#..", ".#..", ".#..", ".#..", "....", ".#..")
g('"', "#.#.", "#.#.")
g('#', ".#.#", ".#.#", "####", ".#.#", "####", ".#.#", ".#.#")
g('$', "..#.", ".###", "#.#.", ".##.", "..##", "###.", "..#.")
g('%', "##..", "##.#", "..#.", ".#..", "#...", "#.##", "..##")
g('&', ".#..", "#.#.", "#.#.", ".#..", "#.##", "#..#", ".##.")
g("'", ".#..", ".#..")
g('(', "..#.", ".#..", "#...", "#...", "#...", ".#..", "..#.")
g(')', "#...", ".#..", "..#.", "..#.", "..#.", ".#..", "#...")
g('*', "#.#.", ".#..", "###.", ".#..", "#.#.", desde=1)
g('+', ".#..", ".#..", "###.", ".#..", ".#..", desde=1)
g(',', ".#..", ".#..", "#...", desde=6)
g('-', "###.", desde=3)
g('.', ".#..", desde=6)
g('/', "...#", "...#", "..#.", ".#..", "#...", "#...", "#...")
g(':', ".#..", "....", "....", ".#..", desde=2)
g(';', ".#..", "....", "....", ".#..", ".#..", "#...", desde=2)
g('<', "..#.", ".#..", "#...", ".#..", "..#.", desde=1)
g('=', "###.", "....", "###.", desde=2)
g('>', "#...", ".#..", "..#.", ".#..", "#...", desde=1)
g('?', ".##.", "#..#", "...#", "..#.", ".#..", "....", ".#..")
g('@', ".##.", "#..#", "#.##", "#.##", "#.#.", "#...", ".##.")

# --- digitos ---
g('0', ".##.", "#..#", "#.##", "##.#", "#..#", "#..#", ".##.")
g('1', ".#..", "##..", ".#..", ".#..", ".#..", ".#..", "###.")
g('2', ".##.", "#..#", "...#", "..#.", ".#..", "#...", "####")
g('3', "###.", "...#", "...#", ".##.", "...#", "...#", "###.")
g('4', "..#.", ".##.", "#.#.", "#.#.", "####", "..#.", "..#.")
g('5', "####", "#...", "###.", "...#", "...#", "#..#", ".##.")
g('6', ".##.", "#...", "#...", "###.", "#..#", "#..#", ".##.")
g('7', "####", "...#", "...#", "..#.", ".#..", ".#..", ".#..")
g('8', ".##.", "#..#", "#..#", ".##.", "#..#", "#..#", ".##.")
g('9', ".##.", "#..#", "#..#", ".###", "...#", "...#", ".##.")

# --- mayusculas ---
g('A', ".##.", "#..#", "#..#", "####", "#..#", "#..#", "#..#")
g('B', "###.", "#..#", "#..#", "###.", "#..#", "#..#", "###.")
g('C', ".###", "#...", "#...", "#...", "#...", "#...", ".###")
g('D', "###.", "#..#", "#..#", "#..#", "#..#", "#..#", "###.")
g('E', "####", "#...", "#...", "###.", "#...", "#...", "####")
g('F', "####", "#...", "#...", "###.", "#...", "#...", "#...")
g('G', ".###", "#...", "#...", "#.##", "#..#", "#..#", ".###")
g('H', "#..#", "#..#", "#..#", "####", "#..#", "#..#", "#..#")
g('I', "###.", ".#..", ".#..", ".#..", ".#..", ".#..", "###.")
g('J', "...#", "...#", "...#", "...#", "...#", "#..#", ".##.")
g('K', "#..#", "#..#", "#.#.", "##..", "#.#.", "#..#", "#..#")
g('L', "#...", "#...", "#...", "#...", "#...", "#...", "####")
g('M', "#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#")
g('N', "#..#", "##.#", "##.#", "#.##", "#.##", "#..#", "#..#")
g('O', ".##.", "#..#", "#..#", "#..#", "#..#", "#..#", ".##.")
g('P', "###.", "#..#", "#..#", "###.", "#...", "#...", "#...")
g('Q', ".##.", "#..#", "#..#", "#..#", "#..#", "#.#.", ".#.#")
g('R', "###.", "#..#", "#..#", "###.", "#.#.", "#..#", "#..#")
g('S', ".###", "#...", "#...", ".##.", "...#", "...#", "###.")
g('T', "###.", ".#..", ".#..", ".#..", ".#..", ".#..", ".#..")
g('U', "#..#", "#..#", "#..#", "#..#", "#..#", "#..#", ".##.")
g('V', "#.#.", "#.#.", "#.#.", "#.#.", "#.#.", ".#..", ".#..")
g('W', "#...#", "#...#", "#...#", "#.#.#", "#.#.#", "##.##", "#...#")
g('X', "#..#", "#..#", ".##.", ".##.", ".##.", "#..#", "#..#")
g('Y', "#.#.", "#.#.", "#.#.", ".#..", ".#..", ".#..", ".#..")
g('Z', "####", "...#", "..#.", ".#..", "#...", "#...", "####")
g('[', "##..", "#...", "#...", "#...", "#...", "#...", "##..")
g('\\', "#...", "#...", ".#..", ".#..", "..#.", "...#", "...#")
g(']', ".##.", "..#.", "..#.", "..#.", "..#.", "..#.", ".##.")
g('^', ".#..", "#.#.")
g('_', "####", desde=8)
g('`', "#...", ".#..")

# --- minusculas ---
g('a', ".##.", "...#", ".###", "#..#", ".###", desde=2)
g('b', "#...", "#...", "###.", "#..#", "#..#", "#..#", "###.")
g('c', ".###", "#...", "#...", "#...", ".###", desde=2)
g('d', "...#", "...#", ".###", "#..#", "#..#", "#..#", ".###")
g('e', ".##.", "#..#", "####", "#...", ".###", desde=2)
g('f', "..##", ".#..", "###.", ".#..", ".#..", ".#..", ".#..")
g('g', ".###", "#..#", "#..#", "#..#", ".###", "...#", ".##.", desde=2)
g('h', "#...", "#...", "###.", "#..#", "#..#", "#..#", "#..#")
g('i', ".#..", "....", "##..", ".#..", ".#..", ".#..", "###.")
g('j', "..#.", "....", ".##.", "..#.", "..#.", "..#.", "..#.", "..#.", "##..")
g('k', "#...", "#...", "#..#", "#.#.", "##..", "#.#.", "#..#")
g('l', "##..", ".#..", ".#..", ".#..", ".#..", ".#..", "###.")
g('m', "####.", "#.#.#", "#.#.#", "#.#.#", "#.#.#", desde=2)
g('n', "###.", "#..#", "#..#", "#..#", "#..#", desde=2)
g('o', ".##.", "#..#", "#..#", "#..#", ".##.", desde=2)
g('p', "###.", "#..#", "#..#", "#..#", "###.", "#...", "#...", desde=2)
g('q', ".###", "#..#", "#..#", "#..#", ".###", "...#", "...#", desde=2)
g('r', "#.##", "##..", "#...", "#...", "#...", desde=2)
g('s', ".###", "#...", ".##.", "...#", "###.", desde=2)
g('t', ".#..", ".#..", "###.", ".#..", ".#..", ".#..", "..##")
g('u', "#..#", "#..#", "#..#", "#..#", ".###", desde=2)
g('v', "#.#.", "#.#.", "#.#.", ".#..", ".#..", desde=2)
g('w', "#...#", "#...#", "#.#.#", "#.#.#", ".#.#.", desde=2)
g('x', "#..#", ".##.", ".##.", ".##.", "#..#", desde=2)
g('y', "#..#", "#..#", "#..#", "#..#", ".###", "...#", ".##.", desde=2)
g('z', "####", "..#.", ".#..", "#...", "####", desde=2)
g('{', "..#.", ".#..", ".#..", "#...", ".#..", ".#..", "..#.")
g('|', ".#..", ".#..", ".#..", ".#..", ".#..", ".#..", ".#..")
g('}', "#...", ".#..", ".#..", "..#.", ".#..", ".#..", "#...")
g('~', ".#.#", "#.#.", desde=2)
g(chr(127), "####", "####", "####", "####", "####", "####", "####")

def filas(c):
    """las 10 filas del glifo como cadenas de 5 pixeles"""
    return ["....."] + G[c]


def tabla():
    """Glifos ya desplazados, listos para Mode 1.

    Con celdas de 5 pixeles la letra empieza en cualquiera de los 4
    pixeles de un byte y ocupa siempre dos bytes. Para cada glifo, cada
    desplazamiento s (0-3) y cada una de las 10 filas se guardan esos
    dos bytes ya en formato Mode 1 con tinta 3 (los dos planos a 1):
    el color se saca luego con un AND (#F0 tinta 1, #0F tinta 2).
    Orden: glifo, desplazamiento, fila, byte izquierdo y derecho.
    """
    def m1(n):
        return (n << 4) | n          # nibble de pixeles -> tinta 3
    print("; Generado por tools/fuente5.py: no editar a mano.")
    print("; 96 glifos x 4 desplazamientos x 10 filas x 2 bytes.")
    for i in range(32, 128):
        c = chr(i)
        vis = c if 32 < i < 127 else ("espacio" if i == 32 else "bloque")
        for d in range(4):
            v = []
            for f in filas(c):
                p = 0
                for k, px in enumerate(f):
                    if px == '#':
                        p |= 16 >> k
                p <<= 3 - d
                v += [m1(p >> 4), m1(p & 15)]
            print(f"        db    {','.join('#%02X' % x for x in v)}   ; {vis} +{d}")


def celdas():
    """la celda de 5 pixeles en cada desplazamiento, en tinta 3"""
    out = []
    for d in range(4):
        p = 0x1F << (3 - d)
        out += [((p >> 4) << 4) | (p >> 4), ((p & 15) << 4) | (p & 15)]
    return out


def descriptores():
    """Por glifo, 8 bytes: donde empieza su primera linea con tinta,
    cuantas lineas tiene y donde empieza el glifo entero.

    La linea 0 es el interlineado y siempre esta vacia; una minuscula
    sin rasgos ocupa solo las lineas 3-7. Pintar solo las lineas con
    tinta ahorra casi la mitad del trabajo en un nombre tipico.
    """
    print("; por glifo: dw GLIFOS+80g+2f, dw 80f, db lineas, db 0, dw GLIFOS+80g")
    print("GDESC")
    for i in range(32, 128):
        c = chr(i)
        g = i - 32
        llenas = [k for k, fila in enumerate(filas(c)) if '#' in fila]
        f, n = (llenas[0], llenas[-1] - llenas[0] + 1) if llenas else (0, 0)
        vis = c if 32 < i < 127 else ("espacio" if i == 32 else "bloque")
        print(f"        dw    GLIFOS+{80*g+2*f},{80*f}")
        print(f"        db    {n},0")
        print(f"        dw    GLIFOS+{80*g}   ; {vis}: lineas {f}-{f+n-1}")


def main():
    faltan = [chr(i) for i in range(32, 128) if chr(i) not in G]
    if faltan:
        sys.exit("faltan glifos: " + repr(faltan))
    for c in G:
        assert all(len(f) == 5 for f in G[c]), c
    tabla()
    print("; la celda entera, para borrar y para el video inverso")
    print("CELDAS  db    " + ",".join("#%02X" % x for x in celdas()))
    descriptores()


if __name__ == "__main__":
    main()
