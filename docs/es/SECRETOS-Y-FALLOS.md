# Secretos y fallos

Lo que se ha buscado en el código y lo que se ha encontrado. Un fallo solo entra aquí si está comprobado:
ejecutando la propia rutina del juego (`tools/bios.py`) o contra las grabaciones de openMSX.

## Secretos: ninguno escondido

- **Ninguna tecla escondida.** Los mandos se leen en un solo sitio (`mandos`, 0xA8C8): las teclas de los dos jugadores
  (los cursores, RETURN y BS el 1; E, S, D, X, CTRL y TAB el 2, como en [La partida](LA-PARTIDA.html)), los dos
  joysticks (GTSTCK y GTTRIG 1 a 4) y, contra el ordenador, la barra espaciadora y GRAPH también como botones del 1. No
  hay ninguna otra lectura del teclado en la ROM: ninguna tecla pulsada al encender y nada que escribir en la pantalla
  de elección.
- **Ni demostración ni entradas extra**, como se cuenta en [Curiosidades](CURIOSIDADES.html): no hay nada más que
  desbloquear.

## Fallo: el vibrato que se borra en la BIOS

Cuando un canal de música se para, `canal_para` (0xBB8E) quiere borrar su vibrato, pero escribe en la dirección
0x0012 (la ROM de la BIOS) en vez de en el byte +0x12 del canal, así que no hace nada; se cuenta en
[Curiosidades](CURIOSIDADES.html).

## Comprobado y correcto

- **El marcador.** Cada entrada tiene una casilla (`marcador_cifra`, 0x92C5): de 0 a 9 con la cifra de la fuente y
  desde 10, dos cifras pequeñas juntas en la misma casilla. Ejecutándola aquí con 9, 10, 37 y 99 carreras da las
  cifras buenas siempre.
- **El final de la partida.** La baja de la novena no se juega si el de casa ya va ganando, y la partida se acaba en
  cuanto se pone por delante en ella (`carreras`, 0x91EC, comparando las dos sumas que hace `suma9`); y si un equipo
  llega a **100 carreras** también se acaba, así que la suma nunca necesita tres cifras.
