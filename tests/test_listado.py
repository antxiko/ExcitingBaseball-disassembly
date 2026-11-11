"""Lo que se afirma de la ROM, comprobado contra sus bytes.

Corre con la ROM delante y sin ella: cuando no esta, la imagen se rehace desde
las filas defb/defw del listado, que si viaja con el repositorio. Sin la ROM
solo se comprueba lo que cae en datos.
"""

import os
import re
import subprocess
import sys
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))

ROM = os.path.join(RAIZ, "excitingbaseball.rom")
ASM = os.path.join(RAIZ, "src", "excitingbaseball.asm")
NOTAS = os.path.join(RAIZ, "src", "excitingbaseball.notes")
ORG = 0x8000
TAM = 16384

FILA = re.compile(r"^\s+def(b|w)\s+([0-9a-fA-F,h ]+)\s*;\s*([0-9a-f]{4})")


def imagen_desde_el_listado():
    img = bytearray(TAM)
    with open(ASM, encoding="utf-8") as f:
        for ln in f:
            m = FILA.match(ln)
            if not m:
                continue
            ancho, cuerpo, dirr = m.group(1), m.group(2), int(m.group(3), 16)
            p = dirr - ORG
            for tok in cuerpo.split(","):
                tok = tok.strip().rstrip("h")
                if not tok:
                    continue
                v = int(tok, 16)
                if ancho == "b":
                    img[p] = v
                    p += 1
                else:
                    img[p] = v & 0xFF
                    img[p + 1] = v >> 8
                    p += 2
    return bytes(img)


def lee():
    if os.path.exists(ROM):
        with open(ROM, "rb") as f:
            return f.read()
    return imagen_desde_el_listado()


def b(a):
    return lee()[a - ORG]


def w(a):
    rom = lee()
    return rom[a - ORG] | (rom[a - ORG + 1] << 8)


def instruccion(dirr):
    """La instruccion del listado en esa direccion (sin el comentario)."""
    with open(ASM, encoding="utf-8") as f:
        for ln in f:
            m = re.match(r"^\t(\S.*?)\s*;([0-9a-f]{4})", ln)
            if m and int(m.group(2), 16) == dirr:
                return m.group(1).replace("\t", " ").strip()
    return None


class Cabecera(unittest.TestCase):
    def test_ab_e_init_en_0x8010(self):
        rom = lee()
        self.assertEqual(rom[:2], b"AB")
        self.assertEqual(w(0x8002), 0x8010)
        self.assertEqual(rom[4:16], bytes(12))

    def test_son_16_kb(self):
        self.assertEqual(len(lee()), TAM)


class LaInterrupcion(unittest.TestCase):
    def test_cuatro_interrupciones_por_h_timi(self):
        self.assertEqual([instruccion(0x801A), instruccion(0x801D)], ["ld hl,082dch", "ld (0fda0h),hl"])
        self.assertEqual([instruccion(0x80C7), instruccion(0x80CA)], ["ld hl,082e9h", "ld (0fda0h),hl"])
        self.assertEqual([instruccion(0x812B), instruccion(0x812E)], ["ld hl,082c5h", "ld (0fda0h),hl"])

    def test_el_juego_se_turna_en_tres_cuadros(self):
        self.assertEqual([instruccion(a) for a in (0x82FC, 0x82FF, 0x8302)],
                         ["ld a,(0e0a0h)", "rrca", "rrca"])


class LaPartida(unittest.TestCase):
    def test_los_zurdos_de_los_nueve_bateadores(self):
        self.assertEqual(list(lee()[0x8777 - ORG:0x8780 - ORG]), [0, 0, 1, 0, 0, 1, 0, 1, 0])

    def test_los_carteles_de_la_cuenta(self):
        self.assertEqual(lee()[0x90A1 - ORG:0x90B9 - ORG], b"" * 7 + b"BALLSTRIKEFOUL")
        self.assertEqual(lee()[0x9119 - ORG:0x9131 - ORG], b"" * 7 + b"OUTSAFECHANGE")

    def test_la_novena_baja_es_la_media_entrada_17(self):
        self.assertEqual([instruccion(0x9181), instruccion(0x9188)], ["ld a,(0e004h)", "cp 011h"])

    def test_siete_textos_de_la_ventana(self):
        t = lee()[0x93E2 - ORG:0x93E2 - ORG + 7 * 24]
        self.assertIn(b"GAMESET", t[0:24])
        self.assertIn(b"HOMERUN", t[24:48])
        self.assertIn(b"GAMECLEAR", t[144:168])


class Sonido(unittest.TestCase):
    def test_trece_ordenes_y_la_ultima_cae_en_el_canal(self):
        t = [w(0xBDA5 + 2 * k) for k in range(14)]
        self.assertEqual(t[13], 0)
        self.assertEqual(t[7:9], [0xBD3C, 0xBD3D])
        self.assertEqual([b(0xBD3C), b(0xBD3D)], [0xC9, 0xC9])

    def test_doce_periodos_de_mas_grave_a_mas_agudo(self):
        t = [w(0xBDD0 + 2 * k) for k in range(12)]
        self.assertEqual(t[0], 0x0D5C)
        self.assertTrue(all(x > y for x, y in zip(t, t[1:])))

    def test_el_vibrato_que_se_borra_en_la_bios(self):
        """canal_para escribe en la direccion 0x0012 (la ROM de la BIOS), no en IX+0x12."""
        self.assertEqual(instruccion(0xBB8F), "ld (00012h),a")


class ElListado(unittest.TestCase):
    def test_densidad_y_flojas(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "densidad.py"), ASM],
            capture_output=True, text=True, check=True).stdout
        m = re.search(r"(\d+) instrucciones, (\d+) comentarios", salida)
        self.assertGreaterEqual(int(m.group(2)) * 100, 40 * int(m.group(1)))
        self.assertIn("---- 0 rutinas por debajo del 10 %", salida)

    def test_ningun_call_sin_nombre(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "sin_bautizar.py"), ASM],
            capture_output=True, text=True, check=True).stdout
        self.assertTrue(salida.startswith("0 rutinas sin bautizar"), salida[:200])

    def test_cada_comentario_en_su_instruccion(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "valida_c.py"), ASM, NOTAS],
            capture_output=True, text=True, check=True).stdout
        self.assertIn("0 fuera de sitio, 0 repetidos", salida)


if __name__ == "__main__":
    unittest.main()
