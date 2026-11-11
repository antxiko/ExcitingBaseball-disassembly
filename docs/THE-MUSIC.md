# The music

Four tunes, on the three channels of the PSG. They are not recorded by hand:
`tools/musica.py` **runs the ROM's own sound engine** with `tools/z80run.py` -`pieza`
(0xBB37) with each piece on its channel and, every frame, `sonido_cuadro` (0xBB99)- and
logs what it writes to the PSG through the BIOS (WRTPSG and RDPSG).

**Checked against openMSX**: the tone and volume registers match the recorded ones frame
by frame, **0 different**: 227 frames the opening, 184 the start, 1,061 GAME CLEAR and 73
the HOME RUN one, until the game puts another sound on its channel. The HOME RUN and GAME
CLEAR tunes were recorded by calling the game's own routines that start them
(`tools/guiones/musicas.tcl`), because a short game does not get there. The channels an
effect takes away from the music are not compared, nor the frames where the interrupt
comes while the previous one is still running.

## The engine

Three channels at 0xE402, 0xE422 and 0xE442, 32 bytes each, with pieces in **three-byte**
groups: a note (its number, the duration and how long to wait for the next one) or an
order from 0xF3 to 0xFF (end, repeat, jump, volume, envelope, noise, vibrato; the table
0xBDA5). The notes come from twelve periods of the lowest octave (0xBDD0), halved for
every octave. Channel 0xE402 plays on the PSG's C, 0xE422 on B and 0xE442 on A.

| | Who asks for it | Length |
|---|---|---:|
| the opening | the boot, with CASIO in the window (0x8060) | 3.8 s |
| the start | every game when it begins (0x80BC) and GAME SET (0x814A) | 3.1 s |
| HOME RUN | NICE / HOME RUN (0x8C19) | 17.7 s |
| GAME CLEAR | the tournament won (0x81C3) | 19.3 s, and the last part loops |

## The opening

<audio controls src="audio/musica_presentacion.mp3"></audio>

## The start

<audio controls src="audio/musica_salida.mp3"></audio>

## HOME RUN

<audio controls src="audio/musica_home_run.mp3"></audio>

## GAME CLEAR

<audio controls src="audio/musica_game_clear.mp3"></audio>
