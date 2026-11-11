# Curiosidades

## El vibrato que se borra en la BIOS

Cuando un canal de la música deja de sonar, `canal_para` (0xBB8E) quiere quitarle el
vibrato poniendo a cero su byte +0x12. Pero la instrucción es `ld (0x0012),a`, no
`ld (ix+0x12),a`: escribe en la dirección 0x0012, que es la ROM de la BIOS, y no hace
nada. El vibrato de un canal se queda como estaba hasta que otra pieza lo cambia.

## El ordenador juega con un mando

El ordenador no mueve a sus jugadores por dentro: en cada fase de la jugada escribe
en la RAM del **segundo mando** (0xE08E) la dirección y los botones que pulsaría un
jugador, y el resto del juego no distingue (`ordenador`, 0x94DE). Lanza con efecto al
azar, batea moviendo el bate hacia la pelota y pulsando cuando la tiene a la altura
que ha elegido, y roba base al azar.

## Una fuente prestada

El juego no trae su fuente: arranca en SCREEN 1 con INIT32, que deja la fuente de la
**BIOS** en la VRAM, y se copia esos 2 KB a la RAM antes de pasar a SCREEN 2 (0x802E).
Las letras de la selección y las cifras del marcador son, por eso, las de la BIOS del
MSX donde se juegue.

## Código que nadie llama

En 0x901C hay una rutina de once bytes que pinta seis casillas en la tabla de nombres:
nadie la llama, ni con `call` ni con `jp`, y no se ejecuta en las medidas de openMSX
(jugando y esperando en la selección).

## Sin demo y sin entradas extra

Sin tocar nada, el juego se queda en la pantalla de selección: no hay demo. Y la
partida se acaba al final de la novena entrada aunque vayan empatados: contra el
ordenador, el empate es una derrota.

## El torneo se sortea

La fuerza de las ocho regiones sale de una semilla tomada del registro R del Z80, que
cambia con cada instrucción: dos partidas no tienen el mismo cuadro. Y las partidas en
las que no juega el jugador no se juegan: gana la región más fuerte.
