#!/usr/bin/env python3
"""Las musicas de Exciting Baseball, EJECUTANDO su propio motor de sonido (ver
motor_musica.py).

El motor va en la interrupcion: `sonido_cuadro` (0xBB99) en cada cuadro. Cada
musica la pone el juego con `pieza` (0xBB37: B el canal de la RAM, DE la pieza)
una vez por canal, despues de callar el sonido (`sonido_calla`, 0xBB5E). El
motor llega al PSG por la BIOS (WRTPSG y RDPSG), que aqui se atrapan.

Uso:  musica.py registros N [cuadros] | mp3 N f.mp3 | todas docs/audio | cotejo
      (N es el numero de la musica en PIEZAS)
"""
import hashlib
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import motor_musica  # noqa: E402

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# (piezas por canal, fichero, quien la pide)
PIEZAS = [
    (((0, 0xBE28), (1, 0xBE65), (2, 0xBE9F)), "musica_presentacion.mp3",
     "el arranque, con CASIO en la ventana (0x8060)"),
    (((0, 0xBF62),), "musica_salida.mp3", "el principio de cada partida (0x80BC) y GAME SET (0x814A)"),
    (((1, 0xBFB5),), "musica_home_run.mp3", "NICE / HOME RUN (0x8C19)"),
    (((0, 0xBFB5), (2, 0xBFEF)), "musica_game_clear.mp3", "GAME CLEAR, el torneo ganado (0x81C3)"),
]

CFG = dict(rom="excitingbaseball.rom", org=0x8000, sp=0xF000, frame=0xBB99,
           ram=(0xE400, 0xE460), hz=60, max_s=300)


def arranca(n):
    rom = open(os.path.join(RAIZ, CFG["rom"]), "rb").read()
    z = motor_musica.Cartucho(CFG, rom)
    z.sp = CFG["sp"]
    z.maq.psg[7] = 0xB8
    z.corre(0xBB5E)
    for canal, pieza in PIEZAS[n][0]:
        z.b, z.de = canal, pieza
        z.corre(0xBB37)
    z.escrituras.clear()
    return z


def ejecuta(n, maximo=None):
    maximo = maximo or CFG["hz"] * CFG["max_s"]
    z = arranca(n)
    a, b = CFG["ram"]
    cuadros, vistos = [], {}
    for k in range(maximo):
        cuadros.append(motor_musica.cuadro(z))
        h = hashlib.sha1(bytes(z.mem[a:b])).digest()
        if h in vistos:
            return cuadros, (None if vistos[h] == k else vistos[h])
        vistos[h] = k + 1
    return cuadros, None


def mp3(n, ruta):
    hz = CFG["hz"]
    cuadros, vuelta = ejecuta(n)
    todo, fundido = motor_musica.desarrolla(cuadros, vuelta, hz)
    motor_musica.a_mp3(motor_musica.sintetiza(todo, hz), ruta, fundido, hz)
    print("%-26s %d cuadros (%.1f s), vuelve al %s" % (os.path.basename(ruta), len(cuadros),
                                                      len(cuadros) / hz, vuelta))


def cotejo():
    """Cuadro a cuadro, los tonos y los volumenes del motor ejecutado contra los del PSG que
    grabo openMSX al entrar en cada interrupcion (work/*.bin, con la RAM 0xE000-0xE7FF). La
    pieza empieza en la interrupcion en la que el canal de su primera pieza pasa a tenerla;
    se mira cada canal mientras sigue con su pieza (el canal de la RAM c suena en el 2 - c
    del PSG) y se saltan los cuadros en que la interrupcion llega con la anterior corriendo."""
    import vdp
    out = []
    for grab in ("atraccion", "partida", "musicas"):
        ruta = os.path.join(RAIZ, "work", grab + ".bin")
        if not os.path.exists(ruta):
            continue
        cs = list(vdp.cuadros(ruta))
        base = lambda k, c: cs[k]["ram"][0x402 + 0x20 * c] | cs[k]["ram"][0x403 + 0x20 * c] << 8
        for n, (piezas, fichero, _) in enumerate(PIEZAS):
            c0, p0 = piezas[0]
            k0 = next((k for k in range(1, len(cs)) if base(k, c0) == p0 and base(k - 1, c0) != p0), None)
            if k0 is None or any(o[0] == n for o in out):
                continue
            cuadros, _ = ejecuta(n, 60 * 120)
            regs = list(cs[k0]["psg"])
            malos, mirados = [], 0
            for k, escr in enumerate(cuadros):
                for r, v in escr:
                    if r < 16:
                        regs[r] = v
                j = k0 + 1 + k
                if j + 1 >= len(cs):
                    break
                if cs[j]["ram"][7] & 1 or cs[j - 1]["ram"][7] & 1:
                    continue
                canales = [c for c, p in piezas if all(base(jj, c) == p for jj in (j - 1, j, j + 1))]
                if not canales:
                    break
                mirados += 1
                if any(cs[j]["psg"][r] != regs[r] for c in canales for r in (2 * (2 - c), 2 * (2 - c) + 1, 10 - c)):
                    malos.append(k)
            out.append((n, grab, k0, mirados, malos))
    return out


def main(argv):
    if argv and argv[0] == "cotejo":
        for n, grab, k0, mirados, malos in cotejo():
            print("%-26s %s, empieza en el cuadro %d: %d cuadros mirados, %d distintos %s"
                  % (PIEZAS[n][1], grab, k0, mirados, len(malos), malos[:8]))
        return 0
    if argv and argv[0] == "todas":
        os.makedirs(argv[1], exist_ok=True)
        for n, (_, fichero, _) in enumerate(PIEZAS):
            mp3(n, os.path.join(argv[1], fichero))
        return 0
    if argv and argv[0] == "mp3":
        mp3(int(argv[1]), argv[2])
        return 0
    if argv and argv[0] == "registros":
        cuadros, vuelta = ejecuta(int(argv[1]), int(argv[2]) if len(argv) > 2 else None)
        for i, escr in enumerate(cuadros):
            print("%5d %s" % (i, " ".join("%X=%02X" % rv for rv in escr)))
        print("cuadros: %d, vuelve al %s" % (len(cuadros), vuelta))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
