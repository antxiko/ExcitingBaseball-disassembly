#!/usr/bin/env python3
"""Los GIF de la web: tramos de las grabaciones de openMSX (tools/guiones/*.tcl, grabados con
tools/lanza_graba.ps1 en C-BIOS_MSX1_JP, -ram "0xE000 0x800"), pintados con tools/vdp.py.

Los cuadros salen de la RAM grabada: 0xE001 la fase de la jugada, 0xE000 la ventana, 0xE003 los carteles
de la cuenta, 0xE013-0xE015 strikes, bolas y outs, 0xE004 la media entrada y 0xE030/0xE03A las carreras.
En `partida` se juega contra el ordenador con la barra cada 30 cuadros y una direccion cada 50.

Uso: gifs.py docs/imagenes
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vdp          # noqa: E402

# (fichero, grabacion, desde, hasta, cada)
TRAMOS = [
    ("lanzamiento.gif", "partida", 600, 1090, 2),     # el bateador nuevo (603), dos lanzamientos y STRIKE (1013)
    ("bateo.gif", "partida", 1260, 2060, 2),          # el tercer lanzamiento, la pelota bateada (1559) y los corredores (2035)
    ("jugada.gif", "partida", 2030, 2860, 2),         # SAFE (2417) y OUT (2735)
    ("change.gif", "partida", 5300, 5600, 2),         # el tercer out (5390) y CHANGE (5490)
    ("carrera.gif", "partida", 8580, 8999, 2),        # una carrera del ordenador (8944)
]


def main(salida):
    raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for fichero, grab, desde, hasta, cada in TRAMOS:
        n, s = vdp.gif(os.path.join(raiz, "work", grab + ".bin"),
                       os.path.join(salida, fichero), desde, hasta, cada=cada, tope_ms=4000)
        print("%-20s %4d imagenes, %5.1f s, %8d bytes" % (
            fichero, n, s, os.path.getsize(os.path.join(salida, fichero))))


if __name__ == "__main__":
    main(sys.argv[1])
