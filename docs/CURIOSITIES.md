# Curiosities

## The vibrato that is cleared in the BIOS

When a music channel stops, `canal_para` (0xBB8E) means to clear its vibrato by zeroing
its byte +0x12. But the instruction is `ld (0x0012),a`, not `ld (ix+0x12),a`: it writes
to address 0x0012, which is the BIOS ROM, and does nothing. A channel's vibrato stays as
it was until another piece changes it.

## The computer plays with a joystick

The computer does not move its players from the inside: in each phase of the play it
writes into the **second joystick's** RAM (0xE08E) the direction and buttons a player
would press, and the rest of the game cannot tell (`ordenador`, 0x94DE). It pitches with
random spin, bats by moving the bat towards the ball and pressing when it is at the
height it chose, and steals at random.

## A borrowed font

The game brings no font of its own: it starts in SCREEN 1 with INIT32, which leaves the
**BIOS** font in the VRAM, and copies those 2 KB to RAM before switching to SCREEN 2
(0x802E). The letters of the selection and the digits of the scoreboard are, therefore,
those of the BIOS of whatever MSX it runs on.

## Code nobody calls

At 0x901C there is an eleven-byte routine that paints six tiles in the name table:
nobody calls it, with `call` or `jp`, and it does not run in the openMSX measurements
(playing and waiting on the selection).

## No demo and no extra innings

Without touching anything, the game stays on the selection screen: there is no demo. And
the game ends after the ninth inning even if they are tied: against the computer, a tie
is a defeat.

## The tournament is drawn at random

The strength of the eight regions comes from a seed taken from the Z80's R register,
which changes with every instruction: no two games have the same bracket. And the games
the player is not in are not played: the stronger region wins.
