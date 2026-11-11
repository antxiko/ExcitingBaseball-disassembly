# The texts

Every text in the ROM, in English, except the title and the regions, which are kanji
tiles. In the window and the signs, the space is tile 0x06.

| Where | Text | Meaning |
|---|---|---|
| the selection (0x84A9) | PLAYER SELECT | |
| | 1PLAY VS.CPU.  PUSH TRIGGER1 | one against the computer |
| | 1PLAY VS.2PLAY PUSH TRIGGER1 | one against another |
| | TO START GAME | |
| | COPYRIGHT 1984 @ CASIO | the @ is drawn as © |
| the window (0x93E2) | GAME SET | end of the match |
| | NICE / HOME RUN | |
| | SELECT 1PLAYER TEAM | player 1, pick a team |
| | GAME OVER | |
| | NEXT GAME A / RESET B | A: next match / B: start again |
| | GAME CLEAR | tournament won |
| the count (0x90A1) | BALL, STRIKE, FOUL | |
| the play (0x9119) | OUT, SAFE, CHANGE | |
| the scoreboard | S, B, O | strikes, balls, outs |
| | 123456789 | the nine innings |

In the selection, the Japanese title (熱戦甲子園, *Nessen Koushien*) and CASIO in big
letters are tiles of their own (0x8475); in the window, CASIO in big letters is text 5 of
the table.
