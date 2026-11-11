# Exciting Baseball - commented disassembly

*(También [en castellano](README.es.md).)*

The commented disassembly of **Exciting Baseball** (*Nessen Koushien*, Casio, 1984) for the MSX: a 16 KB cartridge at 0x8000.

- **100%** of the binary explained: 11,827 bytes of code and 4,557 of named data, not one byte unassigned.
- **42.4%** of the listing commented, 706 routines and labels, none below 10% of comments.
- The listing reassembles into the original ROM **byte for byte**.
- The selection, the field, the tournament bracket and the region choice come from running the ROM, checked against openMSX; the pitch, the hit, the plays, CHANGE and a run, played in GIF; the four tunes, from its own sound engine and identical to openMSX frame by frame.

The site: <https://antxiko.github.io/ExcitingBaseball-disassembly/>
(in Spanish: <https://antxiko.github.io/ExcitingBaseball-disassembly/es/>).

## Rebuilding it

The ROM image is not distributed. Put yours in the root as `excitingbaseball.rom` (sha256 `cedff2f5...`) and run `make`. The details, in [UNDER THE HOOD](docs/UNDER-THE-HOOD.md).

## Legal

The game belongs to Casio and its rights holders. The `LICENSE` covers only the tools, comments, analysis and documentation here. See [LEGAL-NOTICE.md](LEGAL-NOTICE.md).
