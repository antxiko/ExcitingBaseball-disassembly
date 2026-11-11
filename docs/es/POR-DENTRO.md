# Por dentro

## Rehacer la ROM

`make verify` ensambla `src/excitingbaseball.asm` con pasmo y sale la ROM de 16 KB
**byte a byte**. `make sanity` comprueba lo que el reensamblado no cubre: que ningún
byte declarado como datos se lea como código, que ningún punto de entrada caiga en
datos y que los 16.384 bytes estén explicados. `make test` pasa los tests. La ROM no
está en el repositorio: hace falta ponerla en la raíz como `excitingbaseball.rom` (el
volcado de GoodMSX, `[!]`, sha1 `b7fd07b7...`).

| | bytes |
|---|---|
| código trazado | 11.827 |
| datos con nombre | 4.557 |
| sin explicar | 0 |

El listado lleva 2.440 comentarios en 5.751 instrucciones (42,4 %), 706 rutinas y
etiquetas, ninguna por debajo del 10 % comentada, y ninguna rutina llamada sin nombre.

## El cartucho

16 KB en la **página 2** (0x8000-0xBFFF), con INIT en 0x8010 y el resto de la cabecera
a cero. Casi todo es código: los dibujos son pocos (el campo, los jugadores, el
lanzamiento de cerca) y las letras salen de la BIOS.

## La BIOS que usa

INIT32 e INIGRP para las pantallas, WRTVDP para los registros, FILVRM, LDIRVM, LDIRMV y
WRTVRM para la VRAM, GTSTCK, GTTRIG y SNSMAT para los mandos y el teclado, y WRTPSG y
RDPSG para el sonido.

## La interrupción

El juego pone en el gancho H.TIMI (0xFD9F) un `jp` y va cambiando su dirección:

| | dirección | qué hace |
|---|---|---|
| `irq_presentacion` | 0x82DC | la música y la cuenta de cuadros |
| `irq_juego` | 0x82E9 | un cuadro de juego, si el anterior ha acabado |
| `irq_fin` | 0x82C5 | la ventana, el marcador y los sprites del final |

En `irq_juego` hay trabajo que se reparte en **tres cuadros**: en uno el marcador, en
otro los colores del campo, la defensa y la ventana, y en otro la cuenta; el resto
(los mandos, el ordenador, el lanzador, la pelota, los corredores, la defensa) va en
todos.

## Las fases de la jugada

Dos bytes, 0xE001 y 0xE002, llevan la jugada: un bit por fase (el bateador nuevo, el
lanzador, el lanzamiento, la pelota bateada, el robo, los corredores, el final de la
jugada y el cambio de campo) y otro byte para el paso dentro de la fase (`fase`,
0x8639). Cada parte del juego (la pelota, el bateador, la defensa, los corredores)
tiene además su propio byte de estado con un bit por paso.

## Cómo se ha hecho

El trazado sigue el código desde INIT, pero casi todo cuelga de la interrupción y de
tres tablas de saltos (los caminos de los corredores, 0xB490 y 0xB498, y las órdenes de
la música, 0xBDA5). Lo demás se ha **medido en openMSX** (`tools/omsx_cobertura.tcl`:
una condición en cada instrucción apunta cada dirección nueva de la ROM), jugando y
esperando en la selección, en un Philips VG 8020 y en C-BIOS. La interrupción del final
de la partida (0x82C5) no sale jugando un rato: se declara porque `fin_partida` la
pone en el gancho.

## La RAM

| | |
|---|---|
| 0xE000 | la ventana |
| 0xE001 / 0xE002 | la fase de la jugada y su paso |
| 0xE006 | la partida: acabada, quién batea, dos jugadores |
| 0xE013-0xE015 | strikes, bolas y outs |
| 0xE027-0xE03A | las carreras de cada entrada y las sumas |
| 0xE067 | cuatro corredores, 6 bytes cada uno |
| 0xE08C / 0xE08E | los dos mandos (el del ordenador es el segundo) |
| 0xE1A0 | la tabla de sprites que va a la VRAM |
| 0xE1F0 | las ocho regiones del torneo y su fuerza |
| 0xE24D | los nueve jugadores de la defensa, a pintar o a borrar |
| 0xE400-0xE45F | el motor de sonido |
