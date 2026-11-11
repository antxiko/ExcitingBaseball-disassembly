#!/usr/bin/env python3
"""Los sprites de Exciting Baseball MONTADOS DESDE LA ROM (ninguna imagen es una captura).

Los dibujos se cargan como los carga el juego: `sprites_carga` (0xAA1E) pone 0x260 bytes de 0xAA35 en 0x3800 y
nueve de ellos girados de lado en 0x3C00 (`gira_bloque`, 0x9E7F: cada mitad de 16 bytes con los bits al reves,
`gira_byte` 0xACA1, y las dos mitades cambiadas); `bateador_pone` (0x9A9E) pone los 0x280 bytes del bateador
(0x9B1C) en 0x3D80, tal cual para el diestro o veinte girados para el zurdo.

  dibujos.png       todos los dibujos de la tabla de sprites (VRAM 0x3800-0x3FFF) con su numero: con el diestro
                    arriba y con el zurdo abajo (solo cambia desde 0x3D80)
  bateador.png      el bateador diestro y el zurdo: seis sprites cada uno (0x9AEC / 0x9B04: Y, X, dibujo y color;
                    tres llevan el color del equipo, 0xE020) en los cuadros del swing en que cambia de dibujo
  swing.gif         el swing cuadro a cuadro como `bateador_swing` (0x9DA0): los dibujos del cuerpo (0x9E60), del
                    bate (0x9E69) y de las piernas (0x9E76) por tramos (`tabla_busca`, 0xACF0), y el bate que se
                    mueve en los cuadros 5, 10 y 22 (0x9E40, 0x9E45, 0x9DE2)

Uso: hojas.py docs/imagenes | hojas.py cotejo
"""
import os
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))
import vdp          # noqa: E402

ORG = 0x8000
ROM = open(os.path.join(RAIZ, "excitingbaseball.rom"), "rb").read()
FONDO = (40, 40, 48)
COLOR_EQUIPO = 8        # en las hojas: un rojo; el juego pone el del equipo que batea (0xE020)


def b(a):
    return ROM[a - ORG]


def bloque(a, n):
    return ROM[a - ORG:a - ORG + n]


def rev(x):
    return int("{:08b}".format(x)[::-1], 2)


def girados(a, n):
    """gira_bloque con HL = a (la mitad derecha del primero): n sprites de lado."""
    out = bytearray()
    for k in range(n):
        der = bloque(a + 32 * k, 16)
        izq = bloque(a - 16 + 32 * k, 16)
        out += bytes(rev(x) for x in der) + bytes(rev(x) for x in izq)
    return bytes(out)


def patrones(zurdo=False):
    t = bytearray(0x800)
    t[0x000:0x260] = bloque(0xAA35, 0x260)
    t[0x400:0x400 + 9 * 32] = girados(0xAA45, 9)
    t[0x580:0x800] = girados(0x9B2C, 20) if zurdo else bloque(0x9B1C, 0x280)
    return bytes(t)


def pinta(im, pat, n, x, y, color, escala=1):
    if color == 0:
        return
    d = pat[n * 8:n * 8 + 32]
    c = vdp.PALETA[color]
    for fila in range(16):
        for col in range(16):
            if (d[fila + (16 if col >= 8 else 0)] >> (7 - (col & 7))) & 1:
                for ey in range(escala):
                    for ex in range(escala):
                        px, py = (x + col) * escala + ex, (y + fila) * escala + ey
                        if 0 <= px < im.width and 0 <= py < im.height:
                            im.putpixel((px, py), c)


def tabla(a, n, v):
    """tabla_busca (0xACF0): el valor del tramo de v en una tabla de n topes y n + 1 valores."""
    i = 0
    while i < n and v >= b(a + i):
        i += 1
    return b(a + n + i)


def bateador(zurdo, cuadro=0, color=COLOR_EQUIPO):
    """Los seis sprites (Y, X, dibujo, color) del bateador en el cuadro del swing (0 = quieto)."""
    base = 0x9B04 if zurdo else 0x9AEC
    s = [[b(base + 4 * k + j) for j in range(4)] for k in range(6)]
    for k in (1, 2, 5):
        s[k][3] = color
    for c in range(1, cuadro + 1):
        s[1][2] = tabla(0x9E60, 4, c)
        s[2][2] = s[1][2] + 4
        s[5][2] = tabla(0x9E76, 4, c)
        s[4][2] = s[5][2] + 4
        paso = {5: (0x08, 0xFD), 10: (0x02, 0x13), 22: (0xFC, 0xE6)}.get(c)
        if paso:
            dy, dx = paso
            if zurdo:
                dx = (-dx) & 0xFF
            s[0][0] = (s[0][0] + dy) & 0xFF
            s[0][1] = (s[0][1] + dx) & 0xFF
        s[0][2] = tabla(0x9E69, 6, c)
    return [tuple(x) for x in s]


def hoja_dibujos(Image):
    E = 2
    im = Image.new("RGB", (16 * 20 * E, 2 * 4 * 22 * E + 8), FONDO)
    for z, pat in enumerate((patrones(False), patrones(True))):
        for n in range(64):
            pinta(im, pat, n * 4, (n % 16) * 20 + 2, z * 92 + (n // 16) * 22 + 2, 15, E)
    return im


def hoja_bateador(Image):
    E = 3
    cuadros = [0, 5, 10, 14, 18, 22, 27]
    im = Image.new("RGB", (len(cuadros) * 64 * E, 2 * 64 * E), FONDO)
    for z in (0, 1):
        for i, c in enumerate(cuadros):
            pat = patrones(bool(z))
            for y, x, n, col in reversed(bateador(bool(z), c)):
                if y < 0x40:                    # el bateador grande (los de 0xA0 son los de abajo, en el campo)
                    pinta(im, pat, n, i * 64 + (x - (0x68 if z else 0x58)), z * 64 + y + 4, col, E)
    return im


def anima_swing(Image):
    E, cuadros = 3, []
    for c in list(range(0, 30)) + [29] * 30:
        im = Image.new("RGB", (2 * 64 * E, 64 * E), FONDO)
        for z in (0, 1):
            pat = patrones(bool(z))
            for y, x, n, col in reversed(bateador(bool(z), c)):
                if y < 0x40:
                    pinta(im, pat, n, z * 64 + (x - (0x68 if z else 0x58)), y + 4, col, E)
        cuadros.append(im)
    return cuadros


def guarda_gif(cuadros, ruta, ms=1000 / 60):
    imgs, durs = [], []
    for im in cuadros:
        if imgs and list(im.getdata()) == list(imgs[-1].getdata()):
            durs[-1] += ms
        else:
            imgs.append(im)
            durs.append(ms)
    imgs[0].save(ruta, save_all=True, append_images=imgs[1:], duration=[max(20, int(round(d))) for d in durs],
                 loop=0, disposal=1)


def cotejo():
    """Contra las grabaciones de openMSX (work/*.bin, la RAM 0xE000-0xE7FF):
    1) la tabla de dibujos de los sprites (VRAM 0x3800-0x3FFF) contra `patrones()` del diestro o del zurdo;
    2) los dibujos y colores de los seis sprites del bateador (0xE1AC) contra `bateador()` en el cuadro del swing
       de la RAM (0xE016), con el color del equipo de 0xE020 (la Y y la X cambian al moverse en la caja: no se
       comparan, salvo la diferencia entre el bate y el cuerpo, que solo cambia con el swing)."""
    pd, pz = patrones(False), patrones(True)
    tot = dict(patrones=0, pat_diestro=0, pat_zurdo=0, pat_otros=0, bateador=0, bat_mal=0)
    for grab in ("atraccion", "partida", "musicas"):
        ruta = os.path.join(RAIZ, "work", grab + ".bin")
        if not os.path.exists(ruta):
            continue
        for c in vdp.cuadros(ruta):
            v, ram = c["vram"], c["ram"]
            t = v[0x3800:0x4000]
            if t == pd:
                tot["pat_diestro"] += 1
            elif t == pz:
                tot["pat_zurdo"] += 1
            elif t[:0x260] == pd[:0x260]:
                tot["pat_otros"] += 1
            tot["patrones"] += t[:0x580] == pd[:0x580]
            bat = ram[0x1AC:0x1C4]
            zurdo = bool(ram[0x006] & 0x10)
            if not (ram[0x00A] & 0x40) or bat[0] >= 0xC0 or ram[0x016] == 0xFF:
                continue
            quiero = bateador(zurdo, ram[0x016], ram[0x020])
            hay = [tuple(bat[4 * k:4 * k + 4]) for k in range(6)]
            tot["bateador"] += 1
            ok = all(h[2] == q[2] and (h[3] & 15) == (q[3] & 15) for h, q in zip(hay, quiero))
            ok = ok and ((hay[0][1] - hay[1][1]) & 0xFF) == ((quiero[0][1] - quiero[1][1]) & 0xFF)
            tot["bat_mal"] += not ok
    return tot


def main(argv):
    if argv and argv[0] == "cotejo":
        print(cotejo())
        return 0
    from PIL import Image
    salida = argv[0]
    os.makedirs(salida, exist_ok=True)
    hoja_dibujos(Image).save(os.path.join(salida, "dibujos.png"))
    hoja_bateador(Image).save(os.path.join(salida, "bateador.png"))
    guarda_gif(anima_swing(Image), os.path.join(salida, "swing.gif"))
    for f in ("dibujos.png", "bateador.png", "swing.gif"):
        print(f, os.path.getsize(os.path.join(salida, f)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
