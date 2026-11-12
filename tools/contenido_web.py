#!/usr/bin/env python3
"""EL CONTENIDO de la web de esta ROM: lo unico que es de este juego.

jekyll.py y make_web.py son la maquinaria y no llevan dentro el nombre de
ningun juego: lo leen de aqui.

Todas las cifras de aqui estan medidas sobre esta ROM, con las herramientas
de tools/: CODIGO y DATOS los imprime tools/presupuesto.py (make sanity),
INSTRUCCIONES, COMENTARIOS y RUTINAS los da tools/densidad.py (make densidad:
"de N" rutinas, "N instrucciones, M comentarios").
"""

NOMBRE = "Exciting Baseball"
EDITOR = "Casio"
ANIO = 1984
REPOSITORIO = "https://github.com/antxiko/ExcitingBaseball-disassembly"
SHA1 = "b7fd07b7825c6beeb19b1f38631d2869f60939fb"

CODIGO = 11827
DATOS = 4557
RUTINAS = 706
INSTRUCCIONES = 5751
COMENTARIOS = 2440


def densidad(idioma):
    """El porcentaje comentado, con la coma o el punto de cada idioma."""
    d = "%.1f" % (100.0 * COMENTARIOS / INSTRUCCIONES)
    return d.replace(".", ",") if idioma == "es" else d


PIE_LEGAL = {
    "es": "<em>Exciting Baseball</em> (Nessen Koushien) es un juego de Casio para MSX, de "
          "1984, en un cartucho de 16 KB. Todos los derechos sobre el juego siguen siendo "
          "de sus titulares. Este trabajo es de preservaci&oacute;n, estudio y "
          "documentaci&oacute;n, y la imagen de la ROM no se distribuye.",
    "en": "<em>Exciting Baseball</em> (Nessen Koushien) is a 1984 Casio game for the MSX, "
          "on a 16 KB cartridge. All rights in the game remain with their holders. This is "
          "preservation, study and documentation work, and the ROM image is not distributed.",
}

PORTADA = {
    "es": dict(
        titulo="Exciting Baseball - desensamblado comentado",
        claim="El torneo de b&eacute;isbol de los institutos japoneses, contra el ordenador "
              "o entre dos: el cuadro de las ocho regiones, el lanzador, el swing a tiempo, "
              "los corredores, la defensa en casillas y el ordenador que juega con su propio "
              "mando; las pantallas desde los bytes de la ROM, cotejadas con openMSX; las "
              "jugadas en GIF y las cuatro m&uacute;sicas de su propio motor, id&eacute;nticas "
              "a openMSX cuadro a cuadro.",
        ficha=["Casio - <b>(c) 1984</b>",
               "Cartucho de <b>16 KB</b> en 0x8000",
               "<b>MSX</b>", "Volcado <b>b7fd07b7...</b>"],
        aviso="<b>Aqu&iacute; no hay capturas del juego.</b> El logotipo y las "
              "pantallas salen de ejecutar la ROM (cotejadas con openMSX), y los "
              "GIF son la ROM <b>funcionando en openMSX</b>: en cada cuadro se "
              "apuntan la VRAM y los registros del VDP, y <b>c&oacute;digo nuestro "
              "los pinta</b>.",
    ),
    "en": dict(
        titulo="Exciting Baseball - commented disassembly",
        claim="The Japanese high-school baseball tournament, against the computer or between "
              "two: the bracket of the eight regions, the pitcher, the timed swing, the "
              "runners, the fielders drawn in tiles and the computer playing with its own "
              "joystick; the screens from the ROM's bytes, checked against openMSX; the plays "
              "in GIF and the four tunes from its own engine, identical to openMSX frame by "
              "frame.",
        ficha=["Casio - <b>(c) 1984</b>",
               "<b>16 KB</b> cartridge at 0x8000",
               "<b>MSX</b>", "Dump <b>b7fd07b7...</b>"],
        aviso="<b>There are no screenshots of the game here.</b> The logo and the "
              "screens come from running the ROM (checked against openMSX), and the "
              "GIFs are the ROM <b>running in openMSX</b>: on every frame the VRAM and "
              "the VDP registers are logged, and <b>our own code paints them</b>.",
    ),
}

PAGINAS = [
    [("THE-GAME.html", "LA-PARTIDA.html", "The game", "La partida",
      "the controls, the pitcher, the batter, the count, the runners, the fielders and the "
      "computer, as the code has them",
      "los mandos, el lanzador, el bateador, la cuenta, los corredores, la defensa y el "
      "ordenador, como los tiene el c&oacute;digo"),
     ("THE-TOURNAMENT.html", "EL-TORNEO.html", "The tournament", "El torneo",
      "the screens from the ROM, the bracket of the eight regions and how it is won",
      "las pantallas desde la ROM, el cuadro de las ocho regiones y c&oacute;mo se gana"),
     ("THE-PLAYS.html", "LAS-JUGADAS.html", "The plays", "Las jugadas",
      "a game against the computer, played in GIF",
      "una partida contra el ordenador, jugada en GIF"),
     ("THE-SPRITES.html", "LOS-SPRITES.html", "The sprites", "Los sprites",
      "every sprite drawing, the batter right- and left-handed and his swing frame by frame, put together from the "
      "ROM tables",
      "todos los dibujos de los sprites, el bateador diestro y zurdo y su swing cuadro a cuadro, montados desde las "
      "tablas de la ROM"),
     ("THE-TEXTS.html", "LOS-TEXTOS.html", "The texts", "Los textos",
      "every text in the ROM, with its translation",
      "todos los textos de la ROM, con su traducci&oacute;n"),
     ("THE-MUSIC.html", "LA-MUSICA.html", "The music", "La m&uacute;sica",
      "the four tunes, from its own sound engine and checked against openMSX",
      "las cuatro m&uacute;sicas, de su propio motor de sonido y cotejadas con openMSX")],
    [("CURIOSITIES.html", "CURIOSIDADES.html", "Curiosities", "Curiosidades",
      "the vibrato that is cleared in the BIOS, the computer's joystick, the code nobody calls "
      "and the borrowed font",
      "el vibrato que se borra en la BIOS, el mando del ordenador, el c&oacute;digo que nadie "
      "llama y la fuente prestada"),
     ("SECRETS-AND-BUGS.html", "SECRETOS-Y-FALLOS.html", "Secrets and bugs", "Secretos y fallos",
      "what was searched for: no hidden keys, a vibrato cleared into the BIOS, and the scoreboard checked",
      "lo que se ha buscado: ninguna tecla escondida, un vibrato que se borra en la BIOS, y el marcador comprobado")],
    [("UNDER-THE-HOOD.html", "POR-DENTRO.html", "Under the hood", "Por dentro",
      "rebuilding the ROM, the BIOS it uses, the interrupt, the RAM, the sound engine and the "
      "tools",
      "rehacer la ROM, la BIOS que usa, la interrupci&oacute;n, la RAM, el motor de sonido y "
      "las herramientas")],
]

# Repositorio nuevo: no hay paginas viejas que redirigir.
VIEJAS = {}

LOGOTIPO = "logotipo.png"
