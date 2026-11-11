#!/usr/bin/env python3
"""Las pantallas de Exciting Baseball, EJECUTANDO la ROM (tools/bios.py: el Z80 con la BIOS que usa):

  - la seleccion de jugadores: INIT (0x8010) hasta que se espera el mando (0x8028), en SCREEN 1;
  - la presentacion: el campo, el cuadro del torneo y CASIO en la ventana, de 0x802B a la espera de la
    musica (0x8078), con uno contra el ordenador (0xE006 = 0x20);
  - la eleccion de la region: SELECT 1PLAYER TEAM en la ventana (0x807B-0x8083);
  - el campo al empezar la partida: de 0x8086 a la musica de salida (0x80BC), y la ventana del lanzamiento
    (`cartel` con 0xE000 = 0xC0), el marcador (0x92A1), la cuenta (0x902E), los nueve jugadores de la
    defensa (0x8F52 y 0x8F6F) y sus colores (0x869D), que en el juego pinta la interrupcion.

La seleccion usa la fuente de la BIOS (INIT32 la pone en la VRAM y el juego la copia a la RAM para sus
cifras): aqui sale de la VRAM grabada en openMSX, que es la de C-BIOS.

logotipo.png, la cabecera de la web: CASIO y el titulo japones (Nessen Koushien) de la seleccion.

Cada pantalla se coteja con la VRAM que grabo openMSX en el cuadro que se diga: la imagen sin sprites punto
a punto, la tabla de nombres, los dibujos y los colores.

Uso: pantallas.py <dir> [cotejo]
"""
import os
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import vdp                  # noqa: E402
from bios import Msx        # noqa: E402

RAIZ = os.path.dirname(AQUI)
# (grabacion, cuadro)
COTEJO = {"seleccion": ("atraccion", 200), "presentacion": ("partida", 300),
          "region": ("partida", 410), "campo": ("partida", 605)}


def fuente():
    for i, c in enumerate(vdp.cuadros(os.path.join(RAIZ, "work", "atraccion.bin"))):
        if i == 200:
            return bytes(c["vram"][0:0x800])


def ejecuta():
    rom = open(os.path.join(RAIZ, "excitingbaseball.rom"), "rb").read()
    m = Msx(rom, 0x8000)
    m.fuente = fuente()
    m.sp = 0xF000
    out = {}
    m.hasta(0x8010, 0x8028)
    out["seleccion"] = (bytes(m.vdp.vram), bytes(m.vdp.regs))
    m.mem[0xE006] = 0x20                     # uno contra el ordenador (lo que deja elige_jugadores)
    m.hasta(0x802B, 0x8078)
    out["presentacion"] = (bytes(m.vdp.vram), bytes(m.vdp.regs))
    m.hasta(0x807B, 0x8083)
    out["region"] = (bytes(m.vdp.vram), bytes(m.vdp.regs))
    m.hasta(0x8086, 0x80BC)
    m.mem[0xE000] = 0xC0                     # la ventana del lanzamiento, como al empezar la jugada
    m.mem[0xE001] = 0x80                     # la fase del bateador nuevo: los colores del campo
    for r in (0x9393, 0x92A1, 0x902E, 0x8F52, 0x8F6F, 0x869D):
        m.llama(r, sp=0xEFF0)
    out["campo"] = (bytes(m.vdp.vram), bytes(m.vdp.regs))
    return out


def cotejo(pant):
    grabs = {}
    for nom, (grab, n) in COTEJO.items():
        if grab not in grabs:
            grabs[grab] = {i: c for i, c in enumerate(vdp.cuadros(os.path.join(RAIZ, "work", grab + ".bin")))
                           if i in [x[1] for x in COTEJO.values() if x[0] == grab]}
        suya = grabs[grab][n]
        v, regs = pant[nom]
        nombres = [a - 0x1800 for a in range(0x1800, 0x1B00) if v[a] != suya["vram"][a]]
        t1, t2 = vdp.tela(v, regs, False), vdp.tela(suya["vram"], suya["regs"], False)
        puntos = [(x // 8, y // 8) for y in range(192) for x in range(256) if t1[y][x] != t2[y][x]]
        print("%-12s contra %s/%d: puntos distintos %d de 49152 (en %d celdas: %s); nombres %d (%s); registros %s"
              % (nom, grab, n, len(puntos), len(set(puntos)), sorted(set((y, x) for x, y in puntos) - set((f, c) for f in (5, 6, 7) for c in range(1, 9)))[:40],
                 len(nombres), [(a // 32, a % 32) for a in nombres[:12]],
                 "iguales" if regs == bytes(suya["regs"]) else "%s / %s" % (regs.hex(), bytes(suya["regs"]).hex())))


def main(argv):
    pant = ejecuta()
    for nom, (v, regs) in pant.items():
        vdp.imagen(v, regs, 2, con_sprites=False).save(os.path.join(argv[0], "%s.png" % nom))
    v, regs = pant["seleccion"]
    vdp.imagen(v, regs, 4, con_sprites=False).crop((224, 32, 800, 192)).save(os.path.join(argv[0], "logotipo.png"))
    if len(argv) > 1:
        cotejo(pant)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
