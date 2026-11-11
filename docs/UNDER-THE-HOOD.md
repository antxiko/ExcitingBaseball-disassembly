# Under the hood

## Rebuilding the ROM

`make verify` assembles `src/excitingbaseball.asm` with pasmo and the 16 KB ROM comes
out **byte for byte**. `make sanity` checks what reassembling does not cover: that no
byte declared as data is read as code, that no entry point falls in data and that all
16,384 bytes are explained. `make test` runs the tests. The ROM is not in the repository:
it has to be placed in the root as `excitingbaseball.rom` (the GoodMSX dump, `[!]`, sha1
`b7fd07b7...`).

| | bytes |
|---|---|
| traced code | 11,827 |
| named data | 4,557 |
| unexplained | 0 |

The listing has 2,440 comments on 5,751 instructions (42.4%), 706 routines and labels,
none below 10% commented, and no called routine without a name.

## The cartridge

16 KB in **page 2** (0x8000-0xBFFF), with INIT at 0x8010 and the rest of the header at
zero. It is almost all code: there are few drawings (the field, the players, the
close-up of the pitch) and the letters come from the BIOS.

## The BIOS it uses

INIT32 and INIGRP for the screens, WRTVDP for the registers, FILVRM, LDIRVM, LDIRMV and
WRTVRM for the VRAM, GTSTCK, GTTRIG and SNSMAT for the joysticks and the keyboard, and
WRTPSG and RDPSG for the sound.

## The interrupt

The game puts a `jp` in the H.TIMI hook (0xFD9F) and keeps changing its address:

| | address | what it does |
|---|---|---|
| `irq_presentacion` | 0x82DC | the music and the frame counter |
| `irq_juego` | 0x82E9 | a frame of the game, if the previous one is over |
| `irq_fin` | 0x82C5 | the window, the scoreboard and the sprites at the end |

In `irq_juego` some work is spread over **three frames**: the scoreboard in one, the
field colours, the fielders and the window in another, and the count in the third; the
rest (the joysticks, the computer, the pitcher, the ball, the runners, the fielders) runs
in all of them.

## The phases of the play

Two bytes, 0xE001 and 0xE002, drive the play: one bit per phase (the new batter, the
pitcher, the pitch, the hit ball, the steal, the runners, the end of the play and the
change of sides) and another byte for the step inside the phase (`fase`, 0x8639). Each
part of the game (the ball, the batter, the fielders, the runners) also has its own state
byte with one bit per step.

## How it was done

The trace follows the code from INIT, but almost everything hangs off the interrupt and
three jump tables (the runners' paths, 0xB490 and 0xB498, and the music orders, 0xBDA5).
The rest has been **measured in openMSX** (`tools/omsx_cobertura.tcl`: a condition on
every instruction logs every new ROM address), playing and waiting on the selection, on a
Philips VG 8020 and on C-BIOS. The end-of-game interrupt (0x82C5) does not come up in a
short game: it is declared because `fin_partida` puts it in the hook.

## The RAM

| | |
|---|---|
| 0xE000 | the window |
| 0xE001 / 0xE002 | the phase of the play and its step |
| 0xE006 | the game: over, who bats, two players |
| 0xE013-0xE015 | strikes, balls and outs |
| 0xE027-0xE03A | the runs of each inning and the totals |
| 0xE067 | four runners, 6 bytes each |
| 0xE08C / 0xE08E | the two joysticks (the computer's is the second) |
| 0xE1A0 | the sprite table sent to the VRAM |
| 0xE1F0 | the eight regions of the tournament and their strength |
| 0xE24D | the nine fielders, to paint or to erase |
| 0xE400-0xE45F | the sound engine |
