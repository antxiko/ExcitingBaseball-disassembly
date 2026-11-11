# La música

Cuatro músicas, en los tres canales del PSG. No están grabadas a mano:
`tools/musica.py` **ejecuta el motor de sonido de la propia ROM** con
`tools/z80run.py` -`pieza` (0xBB37) con cada pieza en su canal y, en cada cuadro,
`sonido_cuadro` (0xBB99)- y apunta lo que escribe en el PSG a través de la BIOS
(WRTPSG y RDPSG).

**Cotejadas con openMSX**: los registros de tono y de volumen coinciden cuadro a
cuadro con los grabados, **0 distintos**: 227 cuadros la presentación, 184 la salida,
1.061 GAME CLEAR y 73 la del HOME RUN, hasta que el juego pone otro sonido en su
canal. La del HOME RUN y la de GAME CLEAR se grabaron llamando a las rutinas del propio
juego que las ponen (`tools/guiones/musicas.tcl`), porque una partida corta no llega.
No se miran los canales que un efecto le quita a la música, ni los cuadros en que la
interrupción llega con la anterior aún corriendo.

## El motor

Tres canales en 0xE402, 0xE422 y 0xE442, de 32 bytes cada uno, con piezas en grupos
de **tres bytes**: una nota (su número, la duración y lo que espera hasta la
siguiente) o una orden de 0xF3 a 0xFF (acabar, repetir, saltar, el volumen, la
envolvente, el ruido, el vibrato; la tabla 0xBDA5). Las notas salen de doce periodos
de la octava más grave (0xBDD0), partidos por dos por cada octava. El canal 0xE402
suena en el C del PSG, el 0xE422 en el B y el 0xE442 en el A.

| | Quién la pide | Duración |
|---|---|---:|
| la presentación | el arranque, con CASIO en la ventana (0x8060) | 3,8 s |
| la salida | cada partida al empezar (0x80BC) y GAME SET (0x814A) | 3,1 s |
| HOME RUN | NICE / HOME RUN (0x8C19) | 17,7 s |
| GAME CLEAR | el torneo ganado (0x81C3) | 19,3 s, y la última parte vuelve a empezar |

## La presentación

<audio controls src="../audio/musica_presentacion.mp3"></audio>

## La salida

<audio controls src="../audio/musica_salida.mp3"></audio>

## HOME RUN

<audio controls src="../audio/musica_home_run.mp3"></audio>

## GAME CLEAR

<audio controls src="../audio/musica_game_clear.mp3"></audio>
