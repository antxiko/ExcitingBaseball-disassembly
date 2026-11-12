# Secrets and bugs

What was searched for in the code, and what was found. A bug only goes here if it has been checked: by running the
game's own routine (`tools/bios.py`) or against the openMSX recordings.

## Secrets: none hidden

- **No hidden keys.** The controls are read in one place (`mandos`, 0xA8C8): the keys of the two players (the cursors,
  RETURN and BS for player 1; E, S, D, X, CTRL and TAB for player 2, as in [The game](THE-GAME.html)), the two
  joysticks (GTSTCK and GTTRIG 1 to 4) and, against the computer, the space bar and GRAPH as player 1's buttons too.
  There is no other keyboard read in the ROM: no key held at start-up and nothing typed on the selection screen.
- **No demo and no extra innings**, as told in [Curiosities](CURIOSITIES.html): there is nothing more to unlock.

## Bug: the vibrato that is cleared in the BIOS

When a music channel stops, `canal_para` (0xBB8E) means to clear its vibrato, but it writes to address 0x0012 (the
BIOS ROM) instead of to the channel's byte +0x12, so it does nothing; it is told in [Curiosities](CURIOSITIES.html).

## Checked and correct

- **The scoreboard.** Each inning has one tile (`marcador_cifra`, 0x92C5): 0 to 9 with the font's figure and from
  10 on, two small figures packed into the same tile. Running it here with 9, 10, 37 and 99 runs gives the right
  figures every time.
- **The end of the game.** The ninth inning's bottom half is not played if the home team is already winning, and
  the game ends as soon as it goes ahead in it (`carreras`, 0x91EC, comparing the two totals that `suma9` adds up);
  and either team reaching **100 runs** ends it too, so the total never needs three figures.
