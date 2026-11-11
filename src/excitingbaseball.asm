; ==========================================================================
; EXCITING BASEBALL - Casio - MSX1 (1984) - ROM de 16 KB en 0x8000
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x08000


; ----------------------------------------------------------------------
; DATOS cabecera: "AB", INIT (0x8010) y el resto de la cabecera a cero
;   0x8000..0x8010  (16 bytes)
DATA_cabecera:
	defb 041h,042h	; 8000
	defw 08010h,00000h,00000h,00000h,00000h,00000h,00000h	; 8002

; ======================================================================
; CODIGO 0x8010..0x824e  (574 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; INIT: la pantalla, la interrupcion, la seleccion de jugadores y el bucle de la partida.
; ----------------------------------------------------------------------
init:		; El arranque
	ld sp,0f000h		;8010   ; la pila
	xor a			;8013   ; la interrupcion no esta corriendo
	ld (0e007h),a		;8014
	call pantalla_seleccion		;8017   ; la pantalla de la seleccion
	ld hl,082dch		;801a   ; la interrupcion de la presentacion (0x82DC)...
	ld (0fda0h),hl		;801d   ; ...en H.TIMI
	ld a,0c3h		;8020   ; el "jp" del gancho
	ld (0fd9fh),a		;8022
	call sonido_calla		;8025   ; el sonido callado
	call elige_jugadores		;8028   ; uno o dos jugadores
	call 0006fh		;802b
	ld de,0e600h		;802e   ; la fuente de la BIOS que ha dejado INIT32 (2 KB, LDIRMV) a 0xE600
	ld hl,00000h		;8031   ; desde 0x0000...
	ld bc,00800h		;8034   ; ...2 KB
	call 00059h		;8037
	call 00072h		;803a   ; SCREEN 2 (INIGRP)
	ld bc,0a201h		;803d   ; el registro 1 a 0xA2: pantalla apagada
	call 00047h		;8040
	call dibujos		;8043   ; los dibujos del juego
	call campo_colores		;8046   ; los colores del campo (0xAD0B)
	call campo_nombres		;8049   ; la tabla de nombres del campo (0xACFF)
	call torneo		;804c   ; el cuadro del torneo (0xB85C)
	call sprites_carga		;804f   ; los sprites (0xAA1E)
	ld a,085h		;8052   ; la ventana: CASIO en letras grandes
	ld (0e000h),a		;8054   ; en 0xE000
	call cartel		;8057   ; a la ventana
	ld bc,0e201h		;805a   ; el registro 1 a 0xE2: la pantalla encendida
	call 00047h		;805d
	ld b,000h		;8060   ; la musica de la presentacion: tres canales (0xBE28, 0xBE65, 0xBE9F)
	ld de,0be28h		;8062   ; el canal 0...
	call pieza		;8065
	ld b,001h		;8068   ; el 1...
	ld de,0be65h		;806a
	call pieza		;806d
	ld b,002h		;8070   ; y el 2
	ld de,0be9fh		;8072
	call pieza		;8075
	call espera_musica		;8078   ; espera a que acabe
	ld a,082h		;807b   ; el cartel 2: SELECT 1PLAYER TEAM
	ld (0e000h),a		;807d   ; en 0xE000
elige_equipo:		; La eleccion del equipo: el cartel y la flecha del mando
	call cartel		;8080   ; la ventana
	call elige_equipo_bucle		;8083   ; la region con el mando
partida:		; Una partida: las fases, las carreras a 0xFF, y la interrupcion del juego
	ld hl,082dch		;8086   ; la interrupcion de la presentacion
	ld (0fda0h),hl		;8089
	xor a			;808c   ; sin carteles de cuenta
	ld (0e003h),a		;808d
	ld hl,elige_equipo		;8090   ; la primera fase de la jugada...
	ld (0e001h),hl		;8093   ; ...0xE001/0xE002 = 0x80, 0x80
	ld a,085h		;8096   ; la ventana: CASIO en letras grandes
	ld (0e000h),a		;8098
	ld hl,0e027h		;809b   ; las 19 casillas de las carreras...
	ld b,013h		;809e
L_80A0:
	ld (hl),0ffh		;80a0   ; ...a 0xFF: sin jugar
	inc hl			;80a2   ; (hl apunta a 0xE03A)
	djnz L_80A0		;80a3
	xor a			;80a5   ; sin cartel parpadeante...
	ld (0e025h),a		;80a6
	ld (0e015h),a		;80a9   ; ...ni outs...
	ld (0e004h),a		;80ac   ; ...la primera media entrada...
	ld (0e030h),a		;80af   ; ...sin carreras
	ld (hl),a			;80b2   ; la suma, a cero
	ld hl,00808h		;80b3   ; el bateador 8 de los dos: el siguiente sera el 0
	ld (0e021h),a		;80b6   ; los dos bateadores, el primero
	call corredores_borra		;80b9   ; el marcador
	ld b,000h		;80bc   ; la musica de salida (0xBF62)
	ld de,0bf62h		;80be
	call pieza		;80c1
	call espera_musica		;80c4   ; espera a que acabe
	ld hl,082e9h		;80c7   ; la interrupcion del juego (0x82E9)
	ld (0fda0h),hl		;80ca   ; en H.TIMI
	ld a,0c3h		;80cd   ; el "jp"
	ld (0fd9fh),a		;80cf
bucle_partida:		; El bucle de la partida: la fase de la jugada, la media entrada, los carteles y el fin
	call fase		;80d2   ; la fase de la jugada
	call outs		;80d5   ; los outs: la media entrada
	call carreras		;80d8   ; las carreras
	call bases_ocupadas		;80db   ; los jugadores del campo
	call corredores_ordenes		;80de   ; la pelota
	call fin_partida		;80e1   ; la partida acabada?
	ld a,(0e020h)		;80e4   ; el color del equipo que batea...
	ld (0e157h),a		;80e7   ; ...en los cuatro corredores
	ld (0e15bh),a		;80ea
	ld (0e15fh),a		;80ed
	ld (0e163h),a		;80f0
	jr bucle_partida		;80f3   ; otra vuelta
marca_base:		; Marca la base C del corredor que llega (0x8F1B) si la pelota no esta en juego
	call cuantos_en_base		;80f5   ; cuantos corredores hay en la base C
	cp 002h		;80f8   ; dos o mas: todos
	jr nc,marca_base_todos		;80fa
	call corredor_base		;80fc   ; el corredor de esa base
	ret nz			;80ff   ; no hay
	ld a,(hl)			;8100   ; en marcha y sin orden?
	xor 080h		;8101
	and 0e0h		;8103
	ret nz			;8105
marca_base_c:		; La base C
	inc c			;8106   ; la base siguiente
	call corredor_base		;8107   ; el corredor de esa base
	ret nz			;810a
	set 7,(hl)		;810b   ; en marcha
	res 5,(hl)		;810d   ; sin la orden de volver
	ret			;810f
marca_base_todos:		; Con la pelota en juego, todos los corredores de la base C
	ld b,004h		;8110
	ld hl,0e067h		;8112   ; los cuatro corredores, de 6 en 6
	ld de,00006h		;8115
marca_base_uno:		; Un corredor
	ld a,(hl)			;8118   ; su base...
	and 003h		;8119
	cp c			;811b   ; ...es la C?
	jr nz,marca_base_sig		;811c
	res 5,(hl)		;811e   ; sin la orden de volver
marca_base_sig:		; El siguiente
	add hl,de			;8120
	djnz marca_base_uno		;8121
	jr marca_base_c		;8123
fin_partida:		; La partida acabada: la musica, el resultado y vuelta a empezar
	ld hl,0e006h		;8125   ; acabada?
	bit 0,(hl)		;8128
	ret z			;812a
	ld hl,082c5h		;812b   ; la interrupcion del final (0x82C5)
	ld (0fda0h),hl		;812e
	ld a,0c2h		;8131   ; los sprites del campo, fuera de la pantalla
	ld (0e1a0h),a		;8133   ; los cuatro sprites de los corredores...
	ld (0e1ach),a		;8136
	ld (0e1b0h),a		;8139
	ld (0e1b4h),a		;813c
	ld (0e1b8h),a		;813f   ; ...y el del lanzador
	ld hl,0e000h		;8142   ; el cartel: GAME SET
	ld (hl),080h		;8145   ; GAME SET (0x80)
	call sonido_calla		;8147   ; el sonido callado
	ld b,000h		;814a   ; la musica de GAME SET
	ld de,0bf62h		;814c
	call pieza		;814f
	call espera_musica		;8152
	ld a,(0e030h)		;8155   ; las carreras de los dos
	ld de,(0e03ah)		;8158   ; las del ordenador
	ld d,a			;815c   ; D, las del jugador
	push de			;815d
	call torneo_resultado		;815e   ; en el marcador
	pop de			;8161
	ld a,(0e006h)		;8162   ; dos jugadores?
	rlca			;8165   ; bit 7: dos jugadores
	jr c,fin_ronda		;8166
	ld a,e			;8168   ; el ordenador gana?
	cp d			;8169   ; gana el ordenador o empatan: fin
	jr nc,game_over		;816a
	ld a,(0e201h)		;816c   ; ha pasado de la tercera ronda del torneo?
	cp 003h		;816f   ; ...ya la tercera?
	jr nc,torneo_ganado		;8171
fin_ronda:		; Gana el jugador: la ronda siguiente del torneo
	ld a,(0e201h)		;8173
	cp 003h		;8176   ; la ultima ronda: el torneo ganado
	jr nc,game_over		;8178
	ld a,084h		;817a   ; el cartel: NEXT GAME
	ld (0e000h),a		;817c   ; en 0xE000
fin_espera:		; Espera el boton (siguiente partida) o el otro (A RESET)
	call mandos		;817f   ; los mandos
	ld a,(0e08ch)		;8182   ; el boton del primero...
	ld hl,(0e08eh)		;8185   ; ...o del segundo
	or l			;8188
	bit 5,a		;8189   ; el segundo boton: vuelve a empezar
	jp nz,game_over		;818b
	bit 4,a		;818e   ; el primero: la partida siguiente
	jr z,fin_espera		;8190
	call torneo_partidas		;8192   ; el cuadro del torneo
	ld hl,0e006h		;8195   ; la siguiente partida: un jugador, o dos
	ld a,(hl)			;8198
	and 028h		;8199   ; dos jugadores con el segundo batea?
	ld a,080h		;819b
	jr z,fin_siguiente		;819d   ; sigue igual
	ld a,020h		;819f   ; (o con el otro)
fin_siguiente:		; La partida siguiente
	ld (hl),a			;81a1
	jp partida		;81a2
game_over:		; GAME OVER: el cartel y, tras unos cuadros, el arranque
	ld a,083h		;81a5   ; el cartel: GAME OVER
	ld (0e000h),a		;81a7   ; en 0xE000
game_over_espera:		; La espera: 250 cuadros
	xor a			;81aa
	ld (0e0a0h),a		;81ab   ; la cuenta de cuadros a cero
L_81AE:
	ld a,(0e0a0h)		;81ae   ; espera...
	cp 0fah		;81b1   ; ...250 cuadros
	jr c,L_81AE		;81b3
	ld a,0c9h		;81b5   ; el gancho H.TIMI vuelve a "ret"
	ld (0fd9fh),a		;81b7
	pop hl			;81ba   ; fuera la vuelta...
	jp init		;81bb   ; ...y al arranque
torneo_ganado:		; El torneo ganado: GAME CLEAR, su musica y la de la presentacion
	ld a,086h		;81be   ; el cartel: GAME CLEAR
	ld (0e000h),a		;81c0   ; en 0xE000
	ld b,000h		;81c3   ; la musica del torneo ganado (0xBFB5, 0xBFEF)
	ld de,0bfb5h		;81c5
	call pieza		;81c8
	ld b,002h		;81cb   ; y el 2
	ld de,0bfefh		;81cd
	call pieza		;81d0
	call espera_musica		;81d3
	call sonido_calla		;81d6   ; y la de la presentacion
	ld b,000h		;81d9   ; el canal 0...
	ld de,0be28h		;81db
	call pieza		;81de
	ld b,001h		;81e1   ; el 1...
	ld de,0be65h		;81e3
	call pieza		;81e6
	ld b,002h		;81e9   ; y el 2
	ld de,0be9fh		;81eb
	call pieza		;81ee
	call espera_musica		;81f1
	jr game_over_espera		;81f4   ; otra vez, tras 250 cuadros
espera_musica:		; Espera a que la musica acabe (0xE404)
	ld a,(0e404h)		;81f6   ; la musica...
	or a			;81f9   ; ...aun suena?
	ret z			;81fa
	jr espera_musica		;81fb
elige_jugadores:		; 1 PLAYER VS. CPU o 2 PLAYERS: la flecha con el mando, el boton elige
	ld hl,0e006h		;81fd   ; 0xE006 = 0x20: uno contra el ordenador, de momento
	ld (hl),020h		;8200
elige_jugadores_bucle:		; Lee los mandos
	push af			;8202
	call mandos		;8203   ; los mandos
	ld a,(0e08dh)		;8206   ; los dos, juntos
	ld hl,(0e08fh)		;8209
	or l			;820c
	ld b,a			;820d
	pop af			;820e
	bit 4,b		;820f   ; el boton?
	jr nz,elige_jugadores_boton		;8211
	bit 0,b		;8213   ; arriba o abajo: la opcion
	jr z,elige_jugadores_abajo		;8215
	bit 0,a		;8217   ; la opcion 1 (dos jugadores)...
	jr nz,elige_jugadores_cambia		;8219
elige_jugadores_abajo:		; Abajo
	bit 1,b		;821b
	jr z,elige_jugadores_flecha		;821d   ; arriba?
	bit 0,a		;821f
	jr nz,elige_jugadores_flecha		;8221   ; la opcion 0
elige_jugadores_cambia:		; La otra opcion
	inc a			;8223
elige_jugadores_flecha:		; La flecha (0x824E, 0x8251 o un hueco: parpadea con la cuenta 0xE0A0)
	ld hl,0824eh		;8224   ; la flecha arriba (0x824E)...
	bit 0,a		;8227
	jr z,L_822E		;8229   ; ...en la opcion 0...
	ld hl,08251h		;822b   ; ...o abajo (0x8251)
L_822E:
	ld de,(0e0a0h)		;822e   ; la cuenta de cuadros...
	bit 4,e		;8232   ; ...bit 4: parpadea
	jr nz,L_8239		;8234
	ld hl,08254h		;8236   ; sin flecha (0x8254)
L_8239:
	push af			;8239
	ld de,001a1h		;823a   ; fila 13, columna 1
	ld bc,00103h		;823d   ; 1 x 3 casillas
	call bloque		;8240   ; a la tabla de nombres
	pop af			;8243
	jr elige_jugadores_bucle		;8244
elige_jugadores_boton:		; El boton: la opcion 1 (dos jugadores) pone 0x80 en 0xE006; la 0 lo deja en 0x20
	rrca			;8246   ; la opcion: 0 uno contra el ordenador...
	ret nc			;8247
	ld a,080h		;8248   ; ...1: dos jugadores (bit 7)
	ld (0e006h),a		;824a
	ret			;824d

; ----------------------------------------------------------------------
; DATOS flechas: La flecha de la opcion: tres casillas en tres sitios
;   0x824e..0x8257  (9 bytes)
DATA_flechas:
	defb 020h,020h,042h,041h,020h,020h,041h,020h,042h	; 824e    BA  A B

; ======================================================================
; CODIGO 0x8257..0x8393  (316 bytes)
; ======================================================================


elige_equipo_bucle:		; La region del jugador: el mando mueve una marca por las ocho del cuadro
	xor a			;8257
elige_equipo_lee:		; Lee los mandos
	push af			;8258
	call mandos		;8259
	ld a,(0e08dh)		;825c   ; los mandos
	ld hl,(0e08fh)		;825f
	or l			;8262
	ld e,a			;8263
	pop af			;8264
	bit 4,e		;8265   ; el boton?
	jr nz,elige_equipo_boton		;8267
	bit 3,e		;8269   ; a la derecha...
	jr z,elige_equipo_izq		;826b
	inc a			;826d
	cp 008h		;826e   ; ...hasta la 7
	jr c,elige_equipo_pinta		;8270
	ld a,007h		;8272
	jr elige_equipo_pinta		;8274
elige_equipo_izq:		; A la izquierda, hasta la 0
	bit 2,e		;8276   ; a la izquierda?
	jr z,elige_equipo_pinta		;8278
	dec a			;827a
	jp p,elige_equipo_pinta		;827b
	xor a			;827e
elige_equipo_pinta:		; Pinta el cuadro con la region marcada (0xE235: tres filas de 8)
	push af			;827f
	ld hl,0e21dh		;8280   ; la copia del cuadro...
	ld de,0e235h		;8283   ; ...a la copia 0xE235...
	ld bc,00018h		;8286   ; ...tres filas de 8
	ldir		;8289
	ld c,a			;828b   ; BC = la region marcada
	ld b,000h		;828c
	ld a,(0e0a0h)		;828e   ; parpadea con la cuenta
	bit 4,a		;8291   ; ...bit 4: parpadea
	jr nz,elige_equipo_nombres		;8293
	ld hl,0e235h		;8295   ; la region elegida, en otro color
	add hl,bc			;8298
	ld (hl),006h		;8299   ; ...a 6 (vacia)
	ld hl,0e23dh		;829b   ; la fila 2...
	add hl,bc			;829e
	ld (hl),006h		;829f
	ld hl,0e245h		;82a1   ; la fila 3...
	add hl,bc			;82a4
	ld (hl),006h		;82a5
elige_equipo_nombres:		; A la tabla de nombres
	ld de,000a1h		;82a7   ; fila 5, columna 1
	ld hl,0e235h		;82aa
	ld bc,00803h		;82ad   ; 8 x 3 casillas
	call bloque		;82b0
	pop af			;82b3
	jr elige_equipo_lee		;82b4
elige_equipo_boton:		; El boton: el cuadro como estaba
	call torneo_jugador		;82b6   ; la region elegida, la del jugador
	ld de,000a1h		;82b9   ; el cuadro como estaba
	ld hl,0e21dh		;82bc
	ld bc,00803h		;82bf
	jp bloque		;82c2
irq_fin:		; La interrupcion del final de la partida: la ventana, el marcador, las carreras y los sprites, y la musica
	ld hl,0e007h		;82c5   ; la interrupcion anterior aun corre?
	bit 0,(hl)		;82c8
	ret nz			;82ca
	set 0,(hl)		;82cb   ; ahora esta corriendo
	call cartel		;82cd   ; la ventana
	call marcador		;82d0   ; el marcador
	call carreras		;82d3   ; las carreras
	call parpadeo		;82d6   ; los sprites que parpadean
	call sprites_vram		;82d9   ; los sprites a la VRAM
irq_presentacion:		; La interrupcion de la presentacion: la musica y la cuenta de cuadros
	call sonido_cuadro		;82dc   ; la musica
	ld hl,0e0a0h		;82df   ; la cuenta de cuadros
	inc (hl)			;82e2
	ld hl,0e007h		;82e3
	res 0,(hl)		;82e6   ; la interrupcion ha acabado
	ret			;82e8
irq_juego:		; La interrupcion del juego: un cuadro entero, si la anterior ha acabado
	call sonido_cuadro		;82e9   ; la musica
	ld hl,0e007h		;82ec   ; ha pasado un cuadro
	res 1,(hl)		;82ef
	bit 0,(hl)		;82f1   ; la anterior aun corre?
	ret nz			;82f3
	set 0,(hl)		;82f4   ; ahora esta corriendo
	call parpadeo		;82f6   ; los sprites que parpadean
	call sprites_vram		;82f9   ; los sprites a la VRAM
	ld a,(0e0a0h)		;82fc   ; la cuenta de cuadros: tres pasos que se turnan
	rrca			;82ff
	jr c,irq_juego_1		;8300
	rrca			;8302
	jr c,irq_juego_2		;8303
	call marcador		;8305   ; paso 0: los marcadores de las carreras
	jr irq_juego_todos		;8308
irq_juego_1:		; Paso 1: los colores del campo, los jugadores de la defensa, la ventana y los corredores de primera y segunda
	call colores_campo		;830a   ; el campo: los colores
	call defensa_pinta		;830d   ; los jugadores de la defensa
	call cartel		;8310   ; la ventana
	ld c,001h		;8313   ; las marcas de primera...
	call marca_base		;8315
	ld c,002h		;8318   ; ...y de segunda
	call marca_base		;831a
	jr irq_juego_todos		;831d
irq_juego_2:		; Paso 2: la cuenta (S, B, O)
	call cuenta		;831f
irq_juego_todos:		; Todos los cuadros: los mandos, los jugadores, la pelota y las cuentas
	call mandos		;8322   ; los mandos
	call ordenador		;8325   ; el ordenador
	call mandos_equipo		;8328   ; los mandos ordenados
	call lanzador		;832b   ; el lanzador
	call pelota_lanzada		;832e   ; la pelota lanzada
	call bateador		;8331   ; el bateador
	call base_por_bolas		;8334   ; la base por bolas
	call tiro_base		;8337   ; el tiro a una base
	call mandos_equipo		;833a
	call diagonales		;833d   ; las diagonales
	call mandos_equipo		;8340
	call bateada		;8343   ; la pelota bateada
	call corredores		;8346   ; los corredores
	call campo		;8349   ; los jugadores del campo
	call tiro		;834c   ; el tiro
	call cuentas		;834f   ; las cuentas
	ld hl,0e007h		;8352   ; la interrupcion ha acabado
	res 0,(hl)		;8355
	ret			;8357
mandos_equipo:		; Los dos mandos, ordenados: el del que batea y el del que lanza (0xE256 y 0xE258)
	ld hl,(0e08ch)		;8358   ; el mando 1...
	ld de,(0e08eh)		;835b   ; ...y el 2
	ld a,(0e006h)		;835f   ; batea el segundo?
	bit 6,a		;8362
	jr z,mandos_equipo_guarda		;8364
	ld hl,(0e08eh)		;8366   ; al reves
	ld de,(0e08ch)		;8369
mandos_equipo_guarda:		; Guardados
	ld (0e256h),hl		;836d   ; el del que batea...
	ld (0e258h),de		;8370   ; ...y el del que lanza
	ret			;8374
diagonales:		; Las diagonales del mando a una sola direccion (0x8393)
	ld hl,0e08ch		;8375
	call diagonal		;8378
	ld hl,0e08eh		;837b
diagonal:		; Un mando
	ld a,(hl)			;837e   ; el mando
	ld b,004h		;837f   ; cuatro bits de direccion
	ld de,08393h		;8381   ; la tabla
diagonal_bit:		; Busca el primer bit puesto
	rrca			;8384
	jr c,diagonal_pon		;8385   ; este?
	inc de			;8387   ; el siguiente
	djnz diagonal_bit		;8388
	ret			;838a
diagonal_pon:		; La direccion de la tabla, con el boton
	ld a,(hl)			;838b   ; el boton y lo demas...
	and 030h		;838c   ; ...se queda
	ld b,a			;838e
	ld a,(de)			;838f   ; la direccion sola
	or b			;8390
	ld (hl),a			;8391   ; guardada
	ret			;8392

; ----------------------------------------------------------------------
; DATOS una_direccion: Cada bit de direccion, solo
;   0x8393..0x8397  (4 bytes)
DATA_una_direccion:
	defb 001h,002h,004h,008h	; 8393

; ======================================================================
; CODIGO 0x8397..0x8463  (204 bytes)
; ======================================================================


cuentas:		; Las doce cuentas de 0xE0A0 suben
	ld hl,0e0a0h		;8397   ; (las doce cuentas)
	ld b,00ch		;839a   ; ...doce cuentas
cuentas_una:		; Una
	inc (hl)			;839c   ; una sube
	inc hl			;839d
	djnz cuentas_una		;839e
	ret			;83a0
parpadeo:		; Los sprites que parpadean: diez juegos de 4 bytes que se turnan
	ld hl,0e0a8h		;83a1   ; el juego de sprites que toca...
	ld a,(hl)			;83a4
	cp 00ah		;83a5   ; ...de 0 a 9
	jr c,parpadeo_copia		;83a7
	xor a			;83a9
	ld (hl),a			;83aa
parpadeo_copia:		; Copia los sprites de 0xE150 a la vez que los gira
	add a,a			;83ab   ; por cuatro
	add a,a			;83ac
	ld de,0e178h		;83ad   ; los 40 bytes de 0xE150...
	ld hl,0e150h		;83b0
	ld bc,00028h		;83b3
	ldir		;83b6   ; ...a 0xE178
	ld c,a			;83b8
	ld hl,0e150h		;83b9   ; y desde el que toca...
	add hl,bc			;83bc
	ld bc,00028h		;83bd
	ld de,0e1c4h		;83c0   ; ...a 0xE1C4: los que parpadean se turnan
	ldir		;83c3
	ret			;83c5
sprites_vram:		; Los sprites (0xE1A0, 80 bytes) a 0x1B00
	ld hl,0e1a0h		;83c6
	ld de,01b00h		;83c9   ; a la tabla de atributos
	ld bc,00050h		;83cc   ; 80 bytes: 20 sprites
	jp 0005ch		;83cf

; ----------------------------------------------------------------------
; La pantalla de la seleccion: SCREEN 1, los dibujos y los textos fijos.
; ----------------------------------------------------------------------
pantalla_seleccion:		; La pantalla de la seleccion de jugadores, en SCREEN 1
	call 0006fh		;83d2   ; SCREEN 1 (INIT32): la fuente de la BIOS en la VRAM
	ld bc,0a201h		;83d5   ; la pantalla apagada
	call 00047h		;83d8
	ld bc,00007h		;83db   ; el fondo negro (registro 7)
	call 00047h		;83de
	ld de,00300h		;83e1   ; los dibujos de 0x8511 (36 casillas desde la 0x60)
	ld hl,08511h		;83e4   ; desde 0x8511
	ld bc,00120h		;83e7   ; 0x120 bytes
	call 0005ch		;83ea
	ld de,00200h		;83ed   ; los de 0x8631 (una casilla, la 0x40)
	ld hl,08631h		;83f0   ; 0x8631: una casilla
	ld b,008h		;83f3   ; ocho veces
	call fila		;83f5
	ld de,02004h		;83f8   ; los colores de 0x8463 (18 casillas)
	ld hl,08463h		;83fb   ; desde 0x8463
	ld b,012h		;83fe   ; 18 bytes
	call fila		;8400
	ld a,020h		;8403   ; la tabla de nombres a 0x20
	ld bc,00300h		;8405   ; 768 bytes
	ld hl,01800h		;8408   ; la tabla de nombres
	call 00056h		;840b
	ld de,0004ah		;840e   ; el texto de la ventana (0x8475): 12 x 2
	ld hl,08475h		;8411   ; desde 0x8475
	ld bc,00c02h		;8414   ; 12 x 2
	call bloque		;8417
	ld de,000c9h		;841a   ; el de 0x848D: 14 x 2
	ld hl,0848dh		;841d   ; desde 0x848D
	ld bc,00e02h		;8420   ; 14 x 2
	call bloque		;8423
	ld de,0196ah		;8426   ; PLAYER SELECT
	ld hl,084a9h		;8429   ; fila 11, columna 10
	ld b,00dh		;842c
	call fila		;842e
	ld de,019a3h		;8431   ; 1PLAY VS.CPU.  PUSH TRIGGER1
	ld hl,084b6h		;8434   ; fila 13, columna 3
	ld b,01ch		;8437
	call fila		;8439
	ld de,019e3h		;843c   ; 2PLAY VS.2PLAY PUSH TRIGGER1
	ld hl,084d2h		;843f   ; fila 15, columna 3
	ld b,01ch		;8442
	call fila		;8444
	ld de,01a2ah		;8447   ; TO START GAME
	ld hl,084eeh		;844a   ; fila 17, columna 10
	ld b,00dh		;844d
	call fila		;844f
	ld de,01ac5h		;8452   ; COPYRIGHT 1984 @ CASIO
	ld hl,084fbh		;8455   ; fila 22, columna 5
	ld b,016h		;8458
	call fila		;845a
	ld bc,0e201h		;845d   ; la pantalla encendida
	jp 00047h		;8460

; ----------------------------------------------------------------------
; DATOS colores_seleccion: Los colores de las 18 primeras letras de la
;   seleccion (SCREEN 1: uno por cada 8 casillas)
;   0x8463..0x8475  (18 bytes)
DATA_colores_seleccion:
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,030h,030h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h	; 8463  ........00......
	defb 0c0h,0c0h	; 8473

; ----------------------------------------------------------------------
; DATOS ventana_seleccion: Las casillas del dibujo de la ventana de la
;   seleccion: 12 x 2 y 14 x 2
;   0x8475..0x84a9  (52 bytes)
DATA_ventana_seleccion:
	defb 060h,062h,020h,064h,066h,020h,068h,06ah,06ch,020h,060h,06eh	; 8475  `b df hjl `n
	defb 061h,063h,020h,065h,067h,020h,069h,06bh,06dh,020h,061h,06fh	; 8481  ac eg ikm ao
	defb 074h,076h,020h,070h,072h,020h,07ch,07eh,020h,080h,082h,020h,078h,07ah	; 848d  tv pr |~ .. xz
	defb 075h,077h,020h,071h,073h,020h,07dh,07fh,020h,081h,083h,020h,079h,07bh	; 849b  uw qs }. .. y{

; ----------------------------------------------------------------------
; DATOS textos_seleccion: PLAYER SELECT, 1PLAY VS.CPU.  PUSH TRIGGER1, 2PLAY
;   VS.2PLAY PUSH TRIGGER1, TO START GAME, COPYRIGHT 1984 @ CASIO
;   0x84a9..0x8511  (104 bytes)
DATA_textos_seleccion:
	defb 050h,04ch,041h,059h,045h,052h,020h,053h,045h,04ch,045h,043h,054h	; 84a9  PLAYER SELECT
	defb 031h,050h,04ch,041h,059h,020h,056h,053h,02eh,043h,050h,055h,02eh,020h,020h,050h,055h,053h,048h,020h,054h,052h,049h,047h,047h,045h,052h,031h	; 84b6  1PLAY VS.CPU.  PUSH TRIGGER1
	defb 031h,050h,04ch,041h,059h,020h,056h,053h,02eh,032h,050h,04ch,041h,059h,020h,050h,055h,053h,048h,020h,054h,052h,049h,047h,047h,045h,052h,031h	; 84d2  1PLAY VS.2PLAY PUSH TRIGGER1
	defb 054h,04fh,020h,053h,054h,041h,052h,054h,020h,047h,041h,04dh,045h	; 84ee  TO START GAME
	defb 043h,04fh,050h,059h,052h,049h,047h,048h,054h,020h,031h,039h,038h,034h,020h,040h,020h,043h,041h,053h,049h,04fh	; 84fb  COPYRIGHT 1984 @ CASIO

; ----------------------------------------------------------------------
; DATOS seleccion_casillas: Los dibujos de 36 casillas de la seleccion (desde
;   la 0x60)
;   0x8511..0x8631  (288 bytes)
DATA_seleccion_casillas:
	defb 000h,01fh,01fh,060h,060h,060h,060h,060h	; 8511  ...`````
	defb 060h,060h,060h,060h,060h,01fh,01fh,000h	; 8519  `````...
	defb 000h,0feh,0feh,000h,000h,000h,000h,000h	; 8521  ........
	defb 000h,000h,000h,000h,000h,0feh,0feh,000h	; 8529  ........
	defb 007h,007h,018h,018h,060h,060h,060h,060h	; 8531  ....````
	defb 060h,07fh,07fh,060h,060h,060h,060h,000h	; 8539  `..````.
	defb 0e0h,0e0h,018h,018h,006h,006h,006h,006h	; 8541  ........
	defb 006h,0feh,0feh,006h,006h,006h,006h,000h	; 8549  ........
	defb 000h,01fh,01fh,060h,060h,060h,060h,01fh	; 8551  ...````.
	defb 01fh,000h,000h,000h,000h,07fh,07fh,000h	; 8559  ........
	defb 000h,0feh,0feh,000h,000h,000h,000h,0f8h	; 8561  ........
	defb 0f8h,006h,006h,006h,006h,0f8h,0f8h,000h	; 8569  ........
	defb 000h,003h,003h,003h,003h,003h,003h,003h	; 8571  ........
	defb 003h,003h,003h,003h,003h,003h,003h,000h	; 8579  ........
	defb 000h,0f8h,0f8h,006h,006h,006h,006h,006h	; 8581  ........
	defb 006h,006h,006h,006h,006h,0f8h,0f8h,000h	; 8589  ........
	defb 000h,04ch,04dh,02dh,07fh,04ch,07fh,04ch	; 8591  .LM-.L.L
	defb 07fh,00ch,07fh,00ch,00ch,00ch,00ch,00dh	; 8599  ........
	defb 000h,094h,012h,010h,0feh,090h,090h,090h	; 85a1  ........
	defb 092h,014h,0d8h,018h,028h,048h,08ah,00eh	; 85a9  ....(H..
	defb 000h,018h,0ffh,018h,0ffh,024h,042h,099h	; 85b1  .....$B.
	defb 0ffh,018h,0ffh,000h,048h,048h,044h,084h	; 85b9  ....HHD.
	defb 000h,010h,07ch,014h,014h,054h,024h,034h	; 85c1  ..|..T$4
	defb 02ch,044h,047h,000h,084h,084h,042h,042h	; 85c9  ,DG...BB
	defb 000h,07fh,061h,06fh,061h,07fh,060h,06fh	; 85d1  ..aoa.`o
	defb 06ch,06fh,062h,066h,07bh,062h,07fh,060h	; 85d9  lobf{b.`
	defb 000h,0feh,086h,0f6h,086h,0feh,006h,0f6h	; 85e1  ........
	defb 036h,0f6h,096h,066h,046h,026h,0feh,006h	; 85e9  6..fF&..
	defb 000h,07fh,061h,061h,061h,07fh,061h,061h	; 85f1  ..aaa.aa
	defb 061h,07fh,061h,001h,001h,001h,001h,001h	; 85f9  a.a.....
	defb 000h,0feh,086h,086h,086h,0feh,086h,086h	; 8601  ........
	defb 086h,0feh,086h,080h,080h,080h,080h,080h	; 8609  ........
	defb 000h,01fh,000h,000h,003h,000h,000h,000h	; 8611  ........
	defb 07fh,000h,000h,000h,000h,000h,000h,00fh	; 8619  ........
	defb 000h,0f8h,010h,020h,0c0h,0c0h,0c0h,0c0h	; 8621  ... ....
	defb 0ffh,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,080h	; 8629  ........

; ----------------------------------------------------------------------
; DATOS seleccion_casilla40: El dibujo de la casilla 0x40
;   0x8631..0x8639  (8 bytes)
DATA_seleccion_casilla40:
	defb 03ch,042h,099h,0a1h,0a1h,099h,042h,03ch	; 8631  <B....B<

; ======================================================================
; CODIGO 0x8639..0x86e3  (170 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; Las fases de la jugada: el bit mas alto de 0xE001 decide; dentro, 0xE002 es el paso.
; ----------------------------------------------------------------------
fase:		; La fase de la jugada
	ld ix,0e002h		;8639   ; IX = el paso (0xE002)
	ld a,(0e001h)		;863d   ; la fase...
	rlca			;8640   ; ...bit 7: el bateador nuevo
	jr c,fase_bateador		;8641
	rlca			;8643   ; bit 6: el lanzador en su sitio
	jp c,fase_lanzador		;8644
	rlca			;8647   ; bit 5: el lanzamiento
	jp c,fase_lanzamiento		;8648
	rlca			;864b   ; bit 4: la pelota bateada
	jp c,fase_bateada		;864c
	rlca			;864f   ; bit 3: el robo de base
	jp c,fase_robo		;8650
	rlca			;8653   ; bit 2: los corredores
	jp c,fase_corredores		;8654
	rlca			;8657   ; bit 1: la jugada se acaba
	jp c,fase_fin_jugada		;8658
	rlca			;865b   ; bit 0: el cambio de campo
	jp c,fase_cambio		;865c
	ret			;865f
fase_bateador:		; Un bateador nuevo: la cuenta a cero y su sitio en el orden
	ld a,(ix+000h)		;8660
	rlca			;8663   ; paso 7...
	jr c,fase_bateador_nuevo		;8664
	rlca			;8666   ; paso 6: espera
	jp c,fase_bateador_espera2		;8667
	ret			;866a
fase_bateador_nuevo:		; Si no hay cartel en marcha: la ventana, las cuentas y el bateador siguiente
	ld a,(0e003h)		;866b
	and 050h		;866e
	ret nz			;8670
	ld a,0c0h		;8671   ; la ventana: el lanzamiento de cerca
	ld (0e000h),a		;8673
	call jugada_borra		;8676   ; la jugada, a cero
	ld (0e013h),a		;8679   ; strikes...
	ld (0e014h),a		;867c   ; ...y bolas a cero
	ld (0e0a1h),a		;867f   ; la cuenta de cuadros a cero
	call defensa_repinta		;8682   ; los nueve jugadores de la defensa, a repintar
	call sonido_calla		;8685   ; el sonido callado
	call sprites_jugada_fuera		;8688   ; los sprites de la jugada, fuera
	call bateador_siguiente		;868b   ; el bateador siguiente: zurdo o diestro (0x8777)
	ld hl,0e006h		;868e   ; bit 4 de 0xE006: zurdo
	set 4,(hl)		;8691
	or a			;8693   ; diestro: bit 4 a cero
	jr nz,fase_bateador_espera		;8694
	res 4,(hl)		;8696
fase_bateador_espera:		; El paso siguiente: esperar
	ld (ix+000h),040h		;8698
	ret			;869c
colores_campo:		; Los colores del campo segun quien batea: seis tramos (0x86E3 o 0x86EF)
	ld a,(0e001h)		;869d   ; solo al empezar
	cp 080h		;86a0   ; la fase 1?
	jp nz,parpadeo_cartel		;86a2
	ld hl,00709h		;86a5   ; los colores de los dos equipos...
	ld (0e01fh),hl		;86a8
	ld hl,086e3h		;86ab   ; ...en 0xE01F, y la tabla
	ld a,(0e006h)		;86ae   ; batea el segundo?
	bit 6,a		;86b1
	jr z,colores_campo_seis		;86b3
	ld hl,00907h		;86b5   ; los colores al reves
	ld (0e01fh),hl		;86b8
	ld hl,086efh		;86bb
colores_campo_seis:		; Seis tramos de colores, desde 0x28C0
	ld b,006h		;86be
	ld de,028c0h		;86c0   ; el tercio 1, la casilla 0x18 (0x28C0)
colores_campo_uno:		; Un tramo: el color y cuantos bytes, en el tercio 2 y en el 3
	push bc			;86c3
	ld a,(hl)			;86c4   ; el color...
	inc hl			;86c5
	ld c,(hl)			;86c6   ; ...y la longitud
	inc hl			;86c7
	push hl			;86c8
	ld b,000h		;86c9
	push de			;86cb
	pop hl			;86cc
	push bc			;86cd
	push af			;86ce
	call 00056h		;86cf   ; FILVRM...
	pop af			;86d2
	ld bc,00800h		;86d3   ; el otro tercio: 0x800 mas
	add hl,bc			;86d6
	pop bc			;86d7
	ex de,hl			;86d8   ; el tramo siguiente
	add hl,bc			;86d9
	ex de,hl			;86da
	call 00056h		;86db   ; ...y en el otro tercio
	pop hl			;86de
	pop bc			;86df
	djnz colores_campo_uno		;86e0
	ret			;86e2

; ----------------------------------------------------------------------
; DATOS colores_equipos: Los colores del campo para cada equipo que batea:
;   seis tramos (color, longitud), dos tablas
;   0x86e3..0x86fb  (24 bytes)
DATA_colores_equipos:
	defb 0f6h,006h	; 86e3
	defb 096h,002h	; 86e5
	defb 0f6h,006h	; 86e7
	defb 096h,012h	; 86e9
	defb 092h,020h	; 86eb
	defb 096h,020h	; 86ed
	defb 0f6h,006h	; 86ef
	defb 076h,002h	; 86f1
	defb 0f6h,006h	; 86f3
	defb 076h,012h	; 86f5
	defb 072h,020h	; 86f7
	defb 076h,020h	; 86f9

; ======================================================================
; CODIGO 0x86fb..0x8777  (124 bytes)
; ======================================================================


parpadeo_cartel:		; El cartel de la ventana que parpadea (0xE025): su cuenta, su sonido y los colores
	ld hl,0e025h		;86fb
	bit 7,(hl)		;86fe   ; en marcha?
	ret z			;8700
	bit 6,(hl)		;8701   ; bit 6: recien puesto
	res 6,(hl)		;8703   ; ya no
	inc hl			;8705   ; la cuenta
	jr z,parpadeo_cuenta		;8706
	ld (hl),000h		;8708   ; la cuenta a cero...
	push hl			;870a
	ld b,002h		;870b   ; ...y su sonido
	ld de,0bfefh		;870d   ; ...el sonido del cartel (0xBFEF)
	call pieza		;8710
	pop hl			;8713
parpadeo_cuenta:		; Sube la cuenta: 0xF0 cuadros en la fase 1, 0x40 en las demas
	inc (hl)			;8714   ; un cuadro mas
	ld a,(0e001h)		;8715   ; la fase...
	ld b,0f0h		;8718   ; ...1: 0xF0
	cp 001h		;871a
	jr z,parpadeo_compara		;871c
	ld b,040h		;871e   ; las demas: 0x40
parpadeo_compara:		; Llega al tope?
	ld a,(hl)			;8720
	cp b			;8721   ; llega?
	jr c,parpadeo_colores		;8722
	dec hl			;8724   ; el cartel...
	xor a			;8725
	ld (hl),a			;8726   ; se acaba
	ld a,(0e001h)		;8727
	cp 001h		;872a
	jr z,parpadeo_apagado		;872c
	ld b,002h		;872e   ; otro sonido
	ld de,0bfeeh		;8730   ; el sonido (0xBFEE)
	call pieza		;8733
	jr parpadeo_apagado		;8736
parpadeo_colores:		; Encendido o apagado, segun la cuenta de cuadros
	ld bc,01917h		;8738   ; los colores encendidos...
	ld a,(0e0a0h)		;873b   ; la cuenta de cuadros...
	bit 4,a		;873e   ; ...bit 4: parpadea
	jr nz,parpadeo_pon		;8740
parpadeo_apagado:		; Los colores normales
	ld bc,09171h		;8742   ; los colores normales
parpadeo_pon:		; Los dos colores en las casillas de la ventana (0x2E70 y 0x2C70)
	push bc			;8745
	ld a,b			;8746
	ld hl,02e70h		;8747   ; 0x2E70...
	ld bc,00010h		;874a   ; ...16 bytes
	call 00056h		;874d
	pop bc			;8750
	ld a,c			;8751
	ld hl,02c70h		;8752   ; y 0x2C70
	ld bc,00010h		;8755
	jp 00056h		;8758
bateador_siguiente:		; El bateador siguiente del equipo que batea (0-8) y su lado (0x8777)
	ld hl,0e021h		;875b   ; el bateador del primero...
	ld d,000h		;875e
	ld a,(0e006h)		;8760
	bit 6,a		;8763
	jr z,bateador_cuenta		;8765
	inc hl			;8767   ; ...o del segundo
bateador_cuenta:		; El siguiente, de 0 a 8
	ld a,(hl)			;8768   ; el que tocaba...
	ld e,a			;8769
	inc a			;876a   ; ...el siguiente...
	cp 009h		;876b
	jr c,bateador_lado		;876d
	xor a			;876f   ; ...de 0 a 8
bateador_lado:		; Su lado: 0 diestro, 1 zurdo
	ld (hl),a			;8770
	ld hl,08777h		;8771   ; su lado
	add hl,de			;8774
	ld a,(hl)			;8775
	ret			;8776

; ----------------------------------------------------------------------
; DATOS zurdos: Los nueve bateadores de cada equipo: 1 zurdo, 0 diestro
;   0x8777..0x8780  (9 bytes)
DATA_zurdos:
	defb 000h,000h,001h,000h,000h,001h,000h,001h,000h	; 8777  .........

; ======================================================================
; CODIGO 0x8780..0x895c  (476 bytes)
; ======================================================================


jugada_borra:		; La jugada a cero: carreras, bases, cartel, pelota...
	xor a			;8780   ; A = 0
	ld (0e04ch),a		;8781   ; las cuentas de la jugada a cero
	ld (0e054h),a		;8784   ; ...ni tiro...
	ld (0e00eh),a		;8787   ; ...ni ordenes
	ld (0e008h),a		;878a
	ld (0e00dh),a		;878d
	ld (0e009h),a		;8790
	ld (0e00ah),a		;8793
	ld (0e00bh),a		;8796
	ld (0e00ch),a		;8799
	ld (0e01eh),a		;879c
	ld (0e012h),a		;879f
	ld (0e054h),a		;87a2
	ld (0e041h),a		;87a5
	ld (0e010h),a		;87a8
	ld (0e011h),a		;87ab
	ld (0e01ch),a		;87ae
	ld (0e043h),a		;87b1
	ret			;87b4
fase_bateador_espera2:		; Espera 32 cuadros y pasa al lanzador
	ld a,(0e0a1h)		;87b5   ; la cuenta de cuadros...
	cp 020h		;87b8   ; ...32?
	ret c			;87ba
	ld hl,08040h		;87bb   ; la fase del lanzador
	ld (0e001h),hl		;87be
	ret			;87c1
fase_lanzador:		; El lanzador en su sitio: los sprites, la pelota y el lanzamiento
	ld a,(0e003h)		;87c2
	and 050h		;87c5
	ret nz			;87c7
	ld a,(0e00dh)		;87c8   ; ya lanzado?
	and 003h		;87cb
	cp 001h		;87cd   ; ...ya en marcha
	ret z			;87cf
	call sprites_jugada_fuera		;87d0   ; los sprites, fuera
	ld a,0c0h		;87d3   ; la ventana: el lanzamiento de cerca
	ld (0e000h),a		;87d5
	call jugada_borra		;87d8
	ld (0e00fh),a		;87db   ; el estado de las partes de la jugada a cero
	ld (0e055h),a		;87de
	ld (0e01ah),a		;87e1
	ld (0e03eh),a		;87e4
	ld (0e03fh),a		;87e7
	ld (0e05fh),a		;87ea
	ld a,080h		;87ed   ; el lanzador...
	ld (0e008h),a		;87ef   ; el lanzador...
	ld (0e00ah),a		;87f2   ; ...el bateador...
	ld (0e00dh),a		;87f5   ; ...y la jugada en marcha
	call defensa_repinta		;87f8   ; los nueve jugadores de la defensa, a repintar
	ld a,0c0h		;87fb   ; la pelota, fuera
	ld (0e24dh),a		;87fd   ; (0xE24D: el lanzador en casillas, a borrar)
	call sonido_calla		;8800   ; el sonido callado
	ld hl,08020h		;8803   ; la fase del lanzamiento
	ld (0e001h),hl		;8806
	ret			;8809

; ----------------------------------------------------------------------
; El lanzamiento y el bateo: el swing coincide con la pelota en la zona, por la altura (0xE1EC) y el tiempo (0xE016).
; ----------------------------------------------------------------------
fase_lanzamiento:		; El lanzamiento, por pasos
	ld a,(0e002h)		;880a   ; el paso...
	rlca			;880d   ; ...bit 7: la pelota
	jr c,lanza_vuela		;880e
	rlca			;8810   ; bit 6: la salida
	jp c,lanza_salida		;8811
	rlca			;8814
	rlca			;8815   ; bit 4: el toque
	jp c,lanza_paso4		;8816
	rlca			;8819   ; bit 3: espera
	jp c,lanza_paso3		;881a
	rlca			;881d
	rlca			;881e   ; bit 0: out
	rlca			;881f
	jp c,lanza_paso0		;8820
	ret			;8823
lanza_vuela:		; La pelota en el aire: el bateo, el toque y la bola o el strike
	ld a,(0e00ah)		;8824
	bit 0,a		;8827   ; ya ha salido la pelota?
	jp z,lanza_efecto		;8829
	ld hl,00000h		;882c   ; sin direccion
	ld (0e010h),hl		;882f
	call bateo		;8832   ; el bateo
	call robo		;8835   ; el robo de base
	call toque		;8838   ; el toque (bunt)
	ld a,(0e009h)		;883b   ; la pelota sigue?
	and 0c0h		;883e
	jp z,lanza_fin		;8840
	ld a,(0e1ech)		;8843   ; la altura de la pelota...
	cp 026h		;8846   ; ...entre 0x26 y 0x2E...
	ret c			;8848
	cp 02eh		;8849
	ret nc			;884b
	ld a,(0e1a5h)		;884c   ; ...y la X entre 0x6F y 0x80...
	cp 06fh		;884f
	ret c			;8851
	cp 080h		;8852
	ret nc			;8854
	ld hl,0e012h		;8855   ; ...es strike
	set 0,(hl)		;8858   ; strike
	ret			;885a
bateo:		; El bateo: la pelota en la zona y el bate en movimiento (0xE016, de 10 a 21)
	ld a,(0e1ech)		;885b
	cp 026h		;885e   ; la pelota en la zona de bateo...
	ret c			;8860
	cp 02eh		;8861   ; la altura...
	ret nc			;8863
	ld a,(0e016h)		;8864   ; el bate, del cuadro 10...
	cp 00ah		;8867   ; el cuadro del swing...
	ret c			;8869
	cp 016h		;886a   ; ...al 21
	ret nc			;886c
	ld hl,(0e1b8h)		;886d   ; la altura del bate...
	ld a,(0e1a4h)		;8870   ; ...menos la de la pelota
	sub l			;8873
	add a,008h		;8874
	cp 010h		;8876   ; ...a menos de 8: tocada
	ret nc			;8878
	ld (0e019h),a		;8879   ; guardada
	ld a,(0e1a5h)		;887c   ; la X de la pelota y la del bate...
	ld b,003h		;887f   ; ...cuatro anchos: el sitio del bate
	sub h			;8881   ; la X de la pelota menos la del bate
	add a,009h		;8882
	cp 004h		;8884   ; hasta 4: el extremo...
	jr c,bateo_toca		;8886
	dec b			;8888   ; hasta 9...
	cp 009h		;8889
	jr c,bateo_toca		;888b
	dec b			;888d   ; hasta 14...
	cp 00eh		;888e
	jr c,bateo_toca		;8890
	dec b			;8892   ; hasta 18: el mango
	cp 012h		;8893
	ret nc			;8895
bateo_toca:		; La pelota tocada: el momento del swing (temprano, a tiempo, tarde) y el sitio del bate, la direccion
	ld a,(0e016h)		;8896
	ld (0e017h),a		;8899   ; el cuadro del swing
	ld c,000h		;889c
	cp 00dh		;889e   ; antes del 13: temprano
	jr c,bateo_direccion		;88a0
	inc c			;88a2   ; temprano...
	cp 012h		;88a3   ; antes del 18: a tiempo
	jr c,bateo_direccion		;88a5
	inc c			;88a7   ; ...tarde
bateo_direccion:		; La direccion: el momento por 4 mas el sitio (0xE018)
	ld a,c			;88a8
	rlca			;88a9
	rlca			;88aa
	add a,b			;88ab
	ld (0e018h),a		;88ac
	xor a			;88af   ; la pelota bateada
	ld (0e009h),a		;88b0   ; la pelota, fuera de la fase del lanzamiento
	pop hl			;88b3   ; fuera de esta fase
	ld (ix+000h),040h		;88b4   ; el paso 6
	ld hl,0e00ch		;88b8   ; la jugada empieza
	ld (hl),0ffh		;88bb   ; 0xFF
	ld b,001h		;88bd   ; los tres sonidos del golpe
	ld de,0bf0fh		;88bf   ; el canal 1 (0xBF0F)...
	call pieza		;88c2
	ld b,002h		;88c5
	ld de,0bf19h		;88c7   ; ...el 2 (0xBF19)...
	call pieza		;88ca
	ld b,000h		;88cd
	ld de,0bf8eh		;88cf   ; ...el 0 (0xBF8E)
	call pieza		;88d2
	ret			;88d5
robo:		; El robo de base: el corredor sale con el mando del que batea
	ld a,(0e1ech)		;88d6
	cp 026h		;88d9   ; la pelota aun no ha llegado
	ret nc			;88db
	ld a,(0e256h)		;88dc   ; el boton del que batea?
	bit 5,a		;88df
	ret z			;88e1   ; el boton?
	ld b,a			;88e2
	ld a,(0e01bh)		;88e3   ; las bases ocupadas
	bit 3,b		;88e6   ; a la derecha: el de primera...
	jr z,robo_segunda		;88e8
	bit 1,a		;88ea   ; el de primera ya corre?
	ret nz			;88ec
	ld c,001h		;88ed   ; primera...
	call corredor_base		;88ef   ; ...su corredor
	ret nz			;88f2
	ld a,091h		;88f3   ; ...sale hacia segunda
	jr robo_sale		;88f5
robo_segunda:		; Arriba: el de segunda
	bit 0,b		;88f7   ; arriba?
	jr z,robo_tercera		;88f9
	bit 2,a		;88fb
	ret nz			;88fd
	ld c,002h		;88fe   ; segunda
	call corredor_base		;8900
	ret nz			;8903
	ld a,092h		;8904   ; a tercera
	jr robo_sale		;8906
robo_tercera:		; A la izquierda: el de tercera
	bit 2,b		;8908   ; a la izquierda?
	ret z			;890a
	ld c,003h		;890b   ; tercera
	call corredor_base		;890d
	ret nz			;8910
	ld a,093h		;8911   ; a casa
robo_sale:		; El corredor sale: su sprite y su estado
	push af			;8913
	push hl			;8914
	call corredores_marcha		;8915   ; en marcha
	pop hl			;8918
	pop af			;8919
	ld (hl),a			;891a   ; la orden
	ld a,080h		;891b   ; robo
	ld (0e00fh),a		;891d
	ret			;8920
toque:		; El toque (bunt): la pelota llega al bate quieto
	ld a,(0e016h)		;8921
	cp 00ah		;8924   ; el bate quieto (antes del cuadro 10)
	ret nc			;8926
	ld hl,(0e1ech)		;8927   ; la altura de la pelota...
	ld a,l			;892a
	cp 026h		;892b
	ret c			;892d
	cp 02eh		;892e
	ret nc			;8930
	ld a,(0e1b1h)		;8931   ; la X del bate...
	sub h			;8934   ; ...menos la de la pelota...
	add a,002h		;8935
	cp 004h		;8937   ; ...a menos de 2
	ret nc			;8939
	ld a,020h		;893a   ; la pelota, tocada
	ld (0e009h),a		;893c   ; 0xE009
	ld hl,08020h		;893f
	ld (0e01ch),hl		;8942   ; 0xE01C
	ld bc,00000h		;8945   ; la base del bateador
	call jugador_marca		;8948
	ld (ix+000h),010h		;894b   ; el paso 4
	call corredores_ordenes_borra		;894f   ; el bateador corre
	ld b,000h		;8952   ; el sonido del toque (0x895C)
	ld de,0895ch		;8954
	call pieza		;8957
	pop af			;895a   ; fuera de esta fase
	ret			;895b

; ----------------------------------------------------------------------
; DATOS sonido_toque: El sonido del toque: una nota (3 bytes) y el final
;   0x895c..0x8960  (4 bytes)
DATA_sonido_toque:
	defb 013h,00eh,012h,0ffh	; 895c

; ======================================================================
; CODIGO 0x8960..0x8fcb  (1643 bytes)
; ======================================================================


lanza_fin:		; La pelota pasa: bola o strike, y la cuenta
	ld a,(0e016h)		;8960   ; el bate se ha movido...
	ld hl,0e012h		;8963   ; las cuentas
	cp 00ah		;8966   ; ...despues del cuadro 10: strike
	jr c,lanza_cartel		;8968   ; ya ha movido el bate: strike
	set 0,(hl)		;896a
lanza_cartel:		; El cartel de la cuenta (0xE003): BALL o STRIKE
	ld a,(0e00fh)		;896c
	rlca			;896f   ; hay robo?
	jr c,lanza_cuenta		;8970
	ld a,(hl)			;8972   ; strike o bola...
	and 001h		;8973
	inc a			;8975   ; ...el texto 1 o 2...
	rlca			;8976
	rlca			;8977
	or 080h		;8978   ; ...con el cartel en marcha
	ld b,a			;897a
	ld hl,0e003h		;897b
	ld (hl),b			;897e   ; en 0xE003
lanza_cuenta:		; Strike: tres, out; bola: cuatro, base
	ld hl,0e012h		;897f
	bit 0,(hl)		;8982   ; strike?
	jr z,lanza_bola		;8984
	res 0,(hl)		;8986   ; un strike...
	ld hl,0e013h		;8988
	inc (hl)			;898b   ; uno mas
	ld a,(hl)			;898c
	cp 003h		;898d   ; ...tres?
	jr c,lanza_sigue		;898f
	ld (hl),000h		;8991   ; la cuenta a cero
	ld hl,0e014h		;8993   ; las bolas a cero
	ld (hl),000h		;8996
	ld hl,08040h		;8998   ; out
	ld (0e01ch),hl		;899b   ; al bateador nuevo
	ld (ix+000h),008h		;899e   ; el paso 3
	ld hl,0e00fh		;89a2
	ld a,(0e015h)		;89a5   ; los outs...
	cp 002h		;89a8   ; ...dos o mas?
	jr nc,lanza_robo_fin		;89aa
	bit 7,(hl)		;89ac   ; hay robo?
	jr nz,lanza_carrera		;89ae
	ret			;89b0
lanza_robo_fin:		; El robo se acaba
	ld (hl),000h		;89b1
	ret			;89b3
lanza_sigue:		; Sigue el bateador
	ld hl,08040h		;89b4
	ld (0e001h),hl		;89b7   ; la fase del bateador nuevo
	ld a,(0e00fh)		;89ba
	rlca			;89bd
	ret nc			;89be
lanza_carrera:		; Con el corredor saliendo, la fase de los corredores
	ld hl,08008h		;89bf
	ld (0e001h),hl		;89c2   ; la fase de los corredores
	ret			;89c5
lanza_bola:		; Una bola: la cuarta, base por bolas
	ld hl,0e014h		;89c6
	inc (hl)			;89c9   ; una bola mas
	ld a,(hl)			;89ca
	cp 004h		;89cb   ; cuatro?
	jr c,lanza_sigue		;89cd
	ld hl,08080h		;89cf
	ld (0e01ch),hl		;89d2   ; base por bolas
	ld (ix+000h),001h		;89d5   ; el paso 0
	ret			;89d9
lanza_efecto:		; Antes de soltar la pelota: el efecto del lanzador con su mando (0xE010)
	ld a,(0e256h)		;89da   ; el mando del que lanza
	ld hl,0e010h		;89dd
	ld c,000h		;89e0
	bit 5,a		;89e2   ; el boton?
	jr z,lanza_efecto_guarda		;89e4
	and 00fh		;89e6   ; la direccion...
	ld b,a			;89e8
	ld a,(hl)			;89e9
	and 0f0h		;89ea
	or b			;89ec   ; ...a 0xE010
	ld (hl),a			;89ed
	ld c,001h		;89ee   ; hay efecto
lanza_efecto_guarda:		; Lo guarda
	inc hl			;89f0   ; el byte siguiente...
	ld a,(hl)			;89f1
	and 0feh		;89f2   ; ...sin el bit 0...
	or c			;89f4   ; ...con el efecto
	ld (hl),a			;89f5   ; guardado
	ret			;89f6
lanza_salida:		; El lanzamiento empieza: las cuentas a cero y la fase de la pelota
	xor a			;89f7
	ld (0e0a1h),a		;89f8   ; la cuenta de cuadros a cero
	ld (0e009h),a		;89fb
	ld (0e00dh),a		;89fe
	ld hl,08010h		;8a01   ; la fase de la pelota bateada
	ld (0e001h),hl		;8a04
	ret			;8a07
lanza_paso4:		; El toque: espera el fin y pasa a la fase de los corredores
	ld a,(0e01ch)		;8a08   ; la base por bolas...
	bit 5,a		;8a0b   ; ...acabada?
	ret nz			;8a0d
	ld hl,08080h		;8a0e   ; la base por bolas
	ld (0e01ch),hl		;8a11
	ld (ix+000h),001h		;8a14
	ret			;8a18
lanza_paso3:		; Espera y vuelve al bateador nuevo
	ld a,(0e01ch)		;8a19   ; el golpe...
	and 0f0h		;8a1c   ; ...acabado?
	ret nz			;8a1e
	ld hl,08080h		;8a1f   ; el bateador nuevo
	ld (0e001h),hl		;8a22
	ret			;8a25
lanza_paso0:		; El out por strikes: la cuenta a cero y el bateador nuevo
	ld a,(0e01ch)		;8a26   ; 0xE01C...
	bit 7,a		;8a29   ; ...bit 7?
	ret nz			;8a2b
	xor a			;8a2c   ; las cuentas a cero
	ld (0e013h),a		;8a2d
	ld (0e014h),a		;8a30
	ld hl,08080h		;8a33   ; el bateador nuevo
	ld (0e001h),hl		;8a36
	ret			;8a39

; ----------------------------------------------------------------------
; La pelota bateada: hacia donde va (al azar dentro de la direccion), la carrera y el fin de la jugada.
; ----------------------------------------------------------------------
fase_bateada:		; La pelota bateada, por pasos
	ld a,(0e002h)		;8a3a
	rlca			;8a3d   ; bit 7: sale
	jr c,bateada_sale		;8a3e
	rlca			;8a40   ; bit 6
	jp c,bateada_paso6		;8a41
	rlca			;8a44   ; bit 5
	jp c,bateada_paso5		;8a45
	rlca			;8a48   ; bit 4
	jp c,bateada_paso4		;8a49
	rlca			;8a4c   ; bit 3
	jp c,bateada_paso2		;8a4d
	rlca			;8a50   ; bit 2
	jp c,bateada_paso1		;8a51
	ret			;8a54
bateada_sale:		; Espera 32 cuadros: el destino de la pelota
	ld a,(0e0a1h)		;8a55
	cp 020h		;8a58   ; 32 cuadros
	ret c			;8a5a
	ld a,080h		;8a5b
	ld (0e24dh),a		;8a5d   ; (0xE24D: el lanzador en casillas, a pintar)
	xor a			;8a60
	ld (0e00fh),a		;8a61
	ld (0e01ah),a		;8a64
	ld (0e03eh),a		;8a67
	ld (0e05eh),a		;8a6a
	ld a,(0e006h)		;8a6d   ; el ordenador batea?
	bit 3,a		;8a70
	jr z,bateada_toque		;8a72
	ld a,r		;8a74   ; entonces, al azar, a veces otra cosa
	and 055h		;8a76   ; tres de cada cuatro, otra cosa
	jr nz,bateada_lejos		;8a78
bateada_toque:		; El toque: corto y al azar
	ld a,(0e016h)		;8a7a
	ld hl,(0e017h)		;8a7d   ; el cuadro del swing...
	cp l			;8a80   ; ...a tiempo?
	jr nz,bateada_lejos		;8a81
	ld a,r		;8a83   ; un toque: la distancia...
	and 01fh		;8a85
	sub 010h		;8a87
	ld (0e094h),a		;8a89
	ld a,r		;8a8c   ; ...y la altura
	and 00fh		;8a8e
	or 018h		;8a90
	ld (0e093h),a		;8a92
	jr bateada_direccion		;8a95
bateada_lejos:		; Lejos: al azar, a un lado o al otro
	ld a,r		;8a97
	rlca			;8a99   ; al azar...
	jr c,bateada_otro		;8a9a
	ld b,026h		;8a9c   ; a un lado...
	call mitad		;8a9e
	jr bateada_x		;8aa1
bateada_otro:		; Al otro lado
	ld b,01ch		;8aa3   ; ...o al otro
	call mitad		;8aa5
	neg		;8aa8
bateada_x:		; La distancia
	ld b,026h		;8aaa
	add a,b			;8aac
	ld (0e093h),a		;8aad   ; la distancia
	ld hl,0e0a0h		;8ab0   ; mas azar, con la cuenta
	ld a,r		;8ab3
	add a,(hl)			;8ab5
	rlca			;8ab6
	ld r,a		;8ab7
	jr c,bateada_y		;8ab9   ; alta o baja
	push af			;8abb
	ld hl,(0e093h)		;8abc
	ld h,010h		;8abf
	call multiplica		;8ac1
	ld e,019h		;8ac4   ; entre 25
	call divide		;8ac6
	ld a,060h		;8ac9   ; hasta 0x60
	sub h			;8acb
	ld b,a			;8acc
	pop af			;8acd
	call mitad		;8ace
	jr bateada_guarda		;8ad1
bateada_y:		; La altura
	ld b,030h		;8ad3
	call mitad		;8ad5
	neg		;8ad8
bateada_guarda:		; Guarda
	ld b,010h		;8ada
	add a,b			;8adc
	ld (0e094h),a		;8add   ; la altura
bateada_direccion:		; La direccion del golpe, con el bateador zurdo corrida ocho
	ld a,(0e018h)		;8ae0   ; la direccion del golpe
	ld hl,0e006h		;8ae3   ; zurdo?
	bit 4,(hl)		;8ae6
	jr z,bateada_fin		;8ae8
	cp 004h		;8aea   ; del 0 al 3...
	jr nc,bateada_zurdo		;8aec
	add a,008h		;8aee   ; ...8 mas
	jr bateada_fin		;8af0
bateada_zurdo:		; Zurdo
	cp 008h		;8af2   ; del 8 en adelante...
	jr c,bateada_fin		;8af4
	sub 008h		;8af6   ; ...8 menos
bateada_fin:		; El paso siguiente
	ld (0e097h),a		;8af8   ; la direccion
	xor a			;8afb   ; sin pelota lanzada...
	ld (0e00ah),a		;8afc
	ld (0e008h),a		;8aff   ; ...ni lanzador...
	ld a,080h		;8b02   ; ...la pelota bateada
	ld (0e00bh),a		;8b04
	ld a,040h		;8b07   ; el paso 6
	ld (0e002h),a		;8b09
	ret			;8b0c
mitad:		; A partir de A y B, la distancia (0xACAC multiplica)
	ld h,a			;8b0d   ; A al cuadrado...
	ld l,a			;8b0e
	call multiplica		;8b0f
	sra h		;8b12   ; ...la mitad...
	sra a		;8b14   ; ...mas A / 2...
	add a,h			;8b16
	ld h,a			;8b17
	ld l,b			;8b18   ; ...por B
	call multiplica		;8b19
	ld a,h			;8b1c
	ret			;8b1d
bateada_paso6:		; La pelota en el campo: el cartel
	ld hl,0e04ch		;8b1e   ; el campo, en marcha
	ld (hl),080h		;8b21
	ld a,087h		;8b23   ; la ventana sin texto (0x87)
	ld (0e000h),a		;8b25
	ld hl,0e002h		;8b28   ; el paso siguiente
	res 6,(hl)		;8b2b
	set 5,(hl)		;8b2d
	ret			;8b2f
bateada_paso5:		; Atrapada o no: los corredores y el out
	ld a,(0e04ch)		;8b30   ; en marcha?
	cp 080h		;8b33
	ret z			;8b35
	call corredores_salen		;8b36   ; los corredores salen
	xor a			;8b39
	ld (0e03bh),a		;8b3a
	ld a,(0e097h)		;8b3d   ; la direccion...
	dec a			;8b40   ; ...del 1 al 10: en el campo
	cp 00ah		;8b41
	jr nc,bateada_fuera		;8b43
	ld hl,0e00eh		;8b45   ; la jugada en marcha
	set 7,(hl)		;8b48
	ld ix,0e054h		;8b4a
	ld a,(0e04dh)		;8b4e   ; como la cogio
	bit 5,a		;8b51   ; bit 5: de bote
	jr nz,bateada_corre		;8b53
	bit 0,a		;8b55   ; bit 0: en el aire
	jr nz,bateada_corre		;8b57
	and 006h		;8b59   ; bits 1-2: quien
	jr z,bateada_atrapada		;8b5b
	cp 002h		;8b5d
	jr z,bateada_bote		;8b5f
	cp 004h		;8b61
	jr nz,bateada_corre		;8b63
	set 2,(ix+001h)		;8b65   ; el corredor de tercera
bateada_corre:		; Los corredores corren
	ld a,080h		;8b69
	ld (0e054h),a		;8b6b   ; en 0xE054
	ld a,(0e04dh)		;8b6e   ; en el aire?
	ld hl,0e055h		;8b71
	bit 6,a		;8b74
	jr z,bateada_corre_paso		;8b76
	set 4,(hl)		;8b78   ; out
bateada_corre_paso:		; El paso siguiente
	ld hl,0e002h		;8b7a
	res 5,(hl)		;8b7d   ; el paso siguiente
	set 4,(hl)		;8b7f
	ret			;8b81
bateada_atrapada:		; Atrapada en el aire: out
	set 3,(ix+001h)		;8b82   ; en el aire: out...
	set 0,(ix+001h)		;8b86   ; ...y los corredores vuelven
	jr bateada_corre		;8b8a
bateada_bote:		; De bote
	set 0,(ix+001h)		;8b8c   ; de bote
	jr bateada_corre		;8b90
bateada_fuera:		; Fuera del campo: foul o home run
	ld a,(0e096h)		;8b92   ; la altura de la pelota...
	cp 010h		;8b95
	jr c,bateada_fuera_paso		;8b97
	cp 080h		;8b99
	jr nc,bateada_fuera_paso		;8b9b
	ld a,010h		;8b9d   ; ...a 0x10
	ld (0e096h),a		;8b9f
bateada_fuera_paso:		; El paso siguiente
	xor a			;8ba2
	ld (0e0a9h),a		;8ba3   ; la cuenta a cero
	ld hl,0e002h		;8ba6
	res 5,(hl)		;8ba9   ; el paso siguiente
	res 4,(hl)		;8bab
	set 3,(hl)		;8bad
	ret			;8baf
bateada_paso4:		; La pelota al lanzador, o el home run
	ld a,(0e00bh)		;8bb0
	bit 0,a		;8bb3   ; bit 0: home run
	jr nz,home_run		;8bb5
	bit 1,a		;8bb7   ; bit 1: atrapada?
	jr z,bateada_vuelve		;8bb9
	call alguno_corre		;8bbb   ; algun corredor en marcha?
	jr nz,bateada_vuelve		;8bbe
	ld c,001h		;8bc0   ; primera...
	call corredor_base		;8bc2
	jr nz,bateada_vuelve		;8bc5
	ld (hl),081h		;8bc7   ; ...vuelve
	ld c,002h		;8bc9   ; segunda...
	call corredor_base		;8bcb
	jr nz,bateada_vuelve		;8bce
	ld (hl),082h		;8bd0   ; ...vuelve
	ld c,003h		;8bd2   ; tercera...
	call corredor_base		;8bd4
	jr nz,bateada_vuelve		;8bd7
	ld (hl),083h		;8bd9   ; ...vuelve
bateada_vuelve:		; La pelota vuelve: la jugada se acaba
	ld a,(0e04dh)		;8bdb
	bit 7,a		;8bde   ; ya parada?
	ret z			;8be0
	ld a,0c2h		;8be1   ; la pelota, fuera
	ld (0e1ech),a		;8be3
	ld hl,0e054h		;8be6   ; 0xE054
	set 4,(hl)		;8be9
	xor a			;8beb   ; las ordenes a cero
	ld (0e01ah),a		;8bec
	ld (0e03bh),a		;8bef
	ld (0e0a9h),a		;8bf2
	ld a,(0e00bh)		;8bf5
	bit 1,a		;8bf8   ; atrapada?
	jr nz,bateada_robo		;8bfa
	call corredores_ordenes_borra		;8bfc   ; las ordenes borradas
	xor a			;8bff
	ld (0e00eh),a		;8c00
	ld hl,08002h		;8c03   ; la fase de los corredores
	ld (0e001h),hl		;8c06
	ret			;8c09
bateada_robo:		; Con robo
	ld hl,08004h		;8c0a
	ld (0e001h),hl		;8c0d   ; la del robo
	ret			;8c10
home_run:		; HOME RUN: el cartel, su musica y los corredores a casa
	ld a,081h		;8c11   ; la ventana: NICE / HOME RUN
	ld (0e000h),a		;8c13   ; en 0xE000
	call sonido_calla		;8c16   ; el sonido callado
	ld b,001h		;8c19   ; su musica (0xBFB5)
	ld de,0bfb5h		;8c1b
	call pieza		;8c1e
	ld a,0c0h		;8c21   ; el cartel parpadeante
	ld (0e025h),a		;8c23
	xor a			;8c26
	ld (0e009h),a		;8c27   ; la pelota...
	ld (0e00ch),a		;8c2a   ; ...y la jugada a cero
	ld a,003h		;8c2d
	ld (0e00bh),a		;8c2f   ; el paso 3
	ld a,0c2h		;8c32
	ld (0e1ech),a		;8c34   ; la pelota fuera
	ld hl,0e00eh		;8c37
	res 7,(hl)		;8c3a   ; ya no en marcha
	ld a,010h		;8c3c
	ld (0e04ch),a		;8c3e   ; el campo, quieto
	ld hl,0e067h		;8c41   ; los cuatro corredores...
	ld de,00006h		;8c44
	ld b,004h		;8c47
home_run_corre:		; Los cuatro corredores, a correr
	res 5,(hl)		;8c49   ; ...sin ordenes de volver...
	res 4,(hl)		;8c4b
	set 3,(hl)		;8c4d   ; ...y a correr
	add hl,de			;8c4f
	djnz home_run_corre		;8c50
	ld c,001h		;8c52   ; el de primera...
	call corredor_base		;8c54
	jr nz,home_run_2		;8c57
	set 7,(hl)		;8c59   ; ...corre
home_run_2:		; El de segunda
	ld c,002h		;8c5b
	call corredor_base		;8c5d
	jr nz,home_run_3		;8c60
	set 7,(hl)		;8c62   ; corre
home_run_3:		; El de tercera
	ld c,003h		;8c64
	call corredor_base		;8c66
	jr nz,home_run_fin		;8c69
	set 7,(hl)		;8c6b   ; corre
home_run_fin:		; La fase del cambio
	ld hl,08001h		;8c6d
	ld (0e001h),hl		;8c70   ; la fase de los corredores
	ret			;8c73

; ----------------------------------------------------------------------
; Los corredores en el campo: corren, llegan o los eliminan.
; ----------------------------------------------------------------------
fase_corredores:		; Los corredores
	ld a,(0e0a9h)		;8c74   ; la cuenta de cuadros...
	add a,001h		;8c77
	ld a,(0e03bh)		;8c79   ; ...con el acarreo, la parte alta
	adc a,000h		;8c7c
	cp 001h		;8c7e   ; una vuelta o mas?
	ld hl,0e067h		;8c80   ; los cuatro corredores
	ld de,00006h		;8c83
	ld b,004h		;8c86
	jr nc,corredores_fin		;8c88   ; si: se acaba
	xor a			;8c8a
corredores_quietos:		; Alguno parado?
	bit 6,(hl)		;8c8b   ; quieto?
	jr nz,corredores_sig		;8c8d
	or (hl)			;8c8f   ; en marcha
corredores_sig:		; El siguiente
	add hl,de			;8c90
	djnz corredores_quietos		;8c91
	rlca			;8c93   ; alguno en marcha?
	jr nc,corredores_paso		;8c94
	xor a			;8c96   ; la cuenta a cero
	ld (0e0a9h),a		;8c97
corredores_paso:		; Por pasos
	ld a,(0e002h)		;8c9a   ; el paso...
	rlca			;8c9d   ; ...bit 7: el mando
	jr c,corredores_mando		;8c9e
	rlca			;8ca0   ; bit 6: el que va
	jp c,corredores_mueve		;8ca1
	ret			;8ca4
corredores_fin:		; Todos han llegado: fuera la pelota y la jugada siguiente
	ld a,0c2h		;8ca5   ; la pelota fuera
	ld (0e1ech),a		;8ca7
	xor a			;8caa   ; el tiro...
	ld (0e054h),a		;8cab
	ld (0e00eh),a		;8cae   ; ...y la jugada a cero
corredores_fin_uno:		; Un corredor
	bit 6,(hl)		;8cb1   ; quieto?
	jr z,corredores_fin_sig		;8cb3
	ld (hl),a			;8cb5   ; a cero, el estado...
	inc hl			;8cb6
	ld (hl),a			;8cb7   ; ...y la cuenta
	dec hl			;8cb8
corredores_fin_sig:		; El siguiente
	add hl,de			;8cb9
	djnz corredores_fin_uno		;8cba
	ld a,(0e00fh)		;8cbc   ; hubo robo?
	rlca			;8cbf
	jr c,corredores_fin_robo		;8cc0
	ld hl,08080h		;8cc2   ; el bateador nuevo
	ld (0e001h),hl		;8cc5
	ret			;8cc8
corredores_fin_robo:		; Tras un robo
	xor a			;8cc9
	ld (0e00fh),a		;8cca   ; sin robo
	ld (0e054h),a		;8ccd
	ld a,(0e01ch)		;8cd0   ; 0xE01C...
	cp 040h		;8cd3   ; ...0x40: el tercer out
	jr z,corredores_fin_cambio		;8cd5
	ld hl,08040h		;8cd7   ; el bateador nuevo
	ld (0e001h),hl		;8cda
	ret			;8cdd
corredores_fin_cambio:		; Tras el tercer out
	call defensa_repinta		;8cde   ; los jugadores de la defensa, a repintar
	ld hl,00820h		;8ce1   ; la fase del cambio de campo
	ld (0e001h),hl		;8ce4
	ret			;8ce7
corredores_mando:		; El que batea mueve a sus corredores con el mando (0xE01A)
	ld a,(0e01ah)		;8ce8   ; las ordenes del mando...
	and 0f0h		;8ceb   ; ...la direccion
	ld (0e03fh),a		;8ced
	ret z			;8cf0   ; nada
	push af			;8cf1
	and 070h		;8cf2   ; la base de la orden...
	ld hl,(0e03eh)		;8cf4   ; ...la de antes?
	cp l			;8cf7   ; la guarda
	jr z,corredores_mando_base		;8cf8
	ld (0e03eh),a		;8cfa
	rrca			;8cfd   ; a los bits bajos
	rrca			;8cfe
	rrca			;8cff
	rrca			;8d00
	ld b,a			;8d01
	ld a,(0e01bh)		;8d02   ; las bases ocupadas...
	ld c,a			;8d05
	and b			;8d06   ; ...las de la orden
	ld b,a			;8d07
	ld a,c			;8d08   ; y en marcha...
	rrca			;8d09
	rrca			;8d0a
	rrca			;8d0b
	cpl			;8d0c   ; ...no
	and b			;8d0d
	jr z,corredores_mando_base		;8d0e
	ld a,(0e003h)		;8d10   ; ya hay cartel?
	and 030h		;8d13
	jr nz,corredores_mando_base		;8d15
	ld a,022h		;8d17   ; el cartel 0x22 (SAFE)
	ld (0e003h),a		;8d19
corredores_mando_base:		; A que base va
	pop af			;8d1c
	ld c,003h		;8d1d   ; tres bases
corredores_mando_bit:		; El bit de la base
	rlca			;8d1f   ; el bit de la base
	jr c,corredores_mando_uno		;8d20
	dec c			;8d22   ; la anterior
	jr nz,corredores_mando_bit		;8d23
	jr corredores_mando_libre		;8d25
corredores_mando_uno:		; El corredor de esa base
	push bc			;8d27
	call corredor_base		;8d28   ; el corredor de esa base
	pop bc			;8d2b
	jr nz,corredores_mando_vuelve		;8d2c
	dec c			;8d2e   ; la anterior
	jr nz,corredores_mando_uno		;8d2f
corredores_mando_libre:		; La base libre?
	call alguno_corre		;8d31
	jr nz,corredores_mando_vuelve		;8d34
	ld a,(0e01ah)		;8d36   ; la orden
	ld b,003h		;8d39   ; tres bases
corredores_mando_bit2:		; Su bit
	rlca			;8d3b   ; su bit
	jr c,corredores_mando_va		;8d3c
	djnz corredores_mando_bit2		;8d3e
	jr corredores_mando_marca		;8d40
corredores_mando_va:		; El corredor va
	ld c,b			;8d42
	call corredor_base		;8d43   ; su corredor
corredores_mando_marca:		; Lo marca en marcha
	ld a,(hl)			;8d46
	and 003h		;8d47   ; su base...
	or 0e0h		;8d49   ; ...en marcha y con orden
	ld (hl),a			;8d4b
	ld hl,0e01eh		;8d4c   ; la jugada...
	set 7,(hl)		;8d4f   ; ...en marcha
	ret			;8d51
corredores_mando_vuelve:		; El corredor vuelve
	ld a,(0e01ah)		;8d52   ; la orden
	ld b,003h		;8d55   ; tres bases
L_8D57:
	rlca			;8d57   ; su bit
	jr c,corredores_mando_vuelve2		;8d58
	djnz L_8D57		;8d5a
	ret			;8d5c
corredores_mando_vuelve2:		; El de esa base
	push bc			;8d5d
	ld c,b			;8d5e   ; su corredor
	call corredor_base		;8d5f
	pop bc			;8d62
	ret nz			;8d63
	bit 7,(hl)		;8d64   ; en marcha?
	ret z			;8d66
	ld a,b			;8d67   ; el que va
	ld (0e061h),a		;8d68
	ld hl,00000h		;8d6b   ; sin camino aun
	ld (0e062h),hl		;8d6e
	ld hl,(0e1a4h)		;8d71   ; desde la pelota
	ld (0e064h),hl		;8d74
	ld a,0c2h		;8d77   ; el sprite del que va...
	ld (0e174h),a		;8d79
	ld a,(0e01fh)		;8d7c   ; ...con el color del equipo
	ld (0e16fh),a		;8d7f
	ld hl,0e002h		;8d82   ; el paso 6
	res 7,(hl)		;8d85
	set 6,(hl)		;8d87
	ret			;8d89
corredores_mueve:		; Mueve al corredor que va: su camino (0xA7DF)
	xor a			;8d8a
	ld (0e03fh),a		;8d8b
	ld a,(0e054h)		;8d8e   ; el tiro en marcha?
	bit 6,a		;8d91
	jr nz,corredores_mueve_fin		;8d93
	ld a,(0e061h)		;8d95   ; el corredor que va
	ld c,a			;8d98
	call corredor_base		;8d99
	jr nz,corredores_mueve_fin		;8d9c
	bit 7,(hl)		;8d9e   ; en marcha?
	jr z,corredores_mueve_fin		;8da0
	bit 6,(hl)		;8da2   ; ya llega?
	jr nz,corredores_mueve_fin		;8da4
	push hl			;8da6
	ex de,hl			;8da7
	ld e,(hl)			;8da8   ; su destino...
	inc hl			;8da9
	ld d,(hl)			;8daa
	ld (0e083h),de		;8dab   ; ...a 0xE083
	inc hl			;8daf
	ld a,(hl)			;8db0   ; su direccion
	pop hl			;8db1
	push hl			;8db2
	bit 5,(hl)		;8db3   ; vuelve?
	jr nz,corredores_mueve_dir		;8db5
	xor 080h		;8db7   ; la otra
corredores_mueve_dir:		; Su direccion
	ld (0e16eh),a		;8db9
	ld hl,(0e062h)		;8dbc   ; el camino...
	ld (0e089h),hl		;8dbf
	ld hl,(0e064h)		;8dc2   ; ...el principio...
	ld (0e085h),hl		;8dc5
	ld hl,(0e1a4h)		;8dc8   ; ...y donde esta
	ld (0e087h),hl		;8dcb
	ld a,018h		;8dce   ; velocidad 0x18
	ld (0e08bh),a		;8dd0
	call hacia		;8dd3   ; un paso
	ld hl,(0e089h)		;8dd6   ; guardado
	ld (0e062h),hl		;8dd9
	ld hl,(0e087h)		;8ddc   ; donde esta, al sprite
	ld (0e16ch),hl		;8ddf
	ld (0e1a4h),hl		;8de2
	ld a,(0e08bh)		;8de5   ; ha llegado?
	or a			;8de8
	pop hl			;8de9
	ret nz			;8dea
	ld a,(hl)			;8deb   ; su base...
	and 003h		;8dec
	or 0e0h		;8dee   ; ...en marcha
	ld (hl),a			;8df0
	ld hl,0e01eh		;8df1   ; la jugada en marcha
	set 7,(hl)		;8df4
corredores_mueve_fin:		; El paso siguiente
	ld hl,0e002h		;8df6   ; el paso 7
	set 7,(hl)		;8df9
	res 6,(hl)		;8dfb
	ret			;8dfd
fase_fin_jugada:		; La jugada se acaba: espera a que paren y el bateador nuevo
	call todos_parados		;8dfe   ; todos parados?
	jr z,fin_jugada_espera		;8e01
	xor a			;8e03   ; no: la cuenta a cero
	ld (0e0a9h),a		;8e04
fin_jugada_espera:		; 64 cuadros
	ld a,(0e0a9h)		;8e07   ; la cuenta...
	cp 040h		;8e0a   ; ...64?
	jr nc,fin_jugada_nuevo		;8e0c
	ld a,(0e002h)		;8e0e   ; el paso...
	rlca			;8e11
	jr c,fin_jugada_vuelve		;8e12
	rlca			;8e14
	jp c,fin_jugada_mando		;8e15
	ret			;8e18
fin_jugada_nuevo:		; El bateador nuevo
	ld hl,08080h		;8e19   ; el bateador nuevo
	ld (0e001h),hl		;8e1c
	ret			;8e1f
fin_jugada_vuelve:		; Los corredores vuelven
	ld hl,0e01eh		;8e20   ; la jugada en marcha
	set 7,(hl)		;8e23
	call alguno_corre		;8e25   ; algun corredor...
	ld (hl),0e0h		;8e28   ; ...vuelve
	ld (ix+000h),040h		;8e2a   ; el paso 6
	ret			;8e2e
fin_jugada_mando:		; Con el mando
	ld a,(0e01ah)		;8e2f   ; la orden...
	and 070h		;8e32
	ret z			;8e34
	rlca			;8e35   ; la base de la orden
	ld c,003h		;8e36
	rlca			;8e38
	jr c,fin_jugada_mando_uno		;8e39
	dec c			;8e3b
	rlca			;8e3c
	jr c,fin_jugada_mando_uno		;8e3d
	dec c			;8e3f
fin_jugada_mando_uno:		; Uno
	call corredor_base		;8e40   ; su corredor
	ret nz			;8e43
	bit 7,(hl)		;8e44   ; en marcha?
	ret z			;8e46
	bit 6,(hl)		;8e47   ; ya llega?
	ret nz			;8e49
	ld a,(hl)			;8e4a   ; su base, en marcha
	and 003h		;8e4b
	or 0e0h		;8e4d
	ld (hl),a			;8e4f
	ld a,080h		;8e50   ; la jugada
	ld (0e01eh),a		;8e52
	ret			;8e55
fase_cambio:		; El cambio de campo: el sonido, el marcador y el otro equipo
	ld a,(ix+000h)		;8e56
	rlca			;8e59
	jr c,L_8E5D		;8e5a
	ret			;8e5c
L_8E5D:
	call todos_parados		;8e5d   ; todos parados?
	ret nz			;8e60
	ld b,002h		;8e61   ; su sonido
	ld de,0bfeeh		;8e63   ; ...0xBFEE
	call pieza		;8e66
	call corredores_borra		;8e69   ; el marcador
	call sprites_jugada_fuera		;8e6c   ; los sprites, fuera
	ld hl,08080h		;8e6f   ; el bateador nuevo
	ld (0e001h),hl		;8e72
	ld hl,0e006h		;8e75   ; bit 1: la ultima entrada?
	bit 1,(hl)		;8e78
	ret z			;8e7a
	set 0,(hl)		;8e7b   ; la partida se acaba
	res 1,(hl)		;8e7d
	ret			;8e7f
bateada_paso2:		; Atrapada: el cartel OUT y el out
	ld a,(0e0a9h)		;8e80   ; la cuenta...
	cp 020h		;8e83   ; ...32?
	ret c			;8e85
	call corredores_ordenes_borra		;8e86   ; las ordenes borradas
	ld a,08ch		;8e89   ; el cartel OUT
	ld (0e003h),a		;8e8b
	ld a,(0e013h)		;8e8e   ; un out mas...
	inc a			;8e91
	cp 003h		;8e92   ; ...si no son tres
	jr nc,bateada_paso2_fin		;8e94
	ld (0e013h),a		;8e96
bateada_paso2_fin:		; El paso siguiente
	ld hl,0e002h		;8e99   ; el paso siguiente
	res 3,(hl)		;8e9c
	set 2,(hl)		;8e9e
	ret			;8ea0
bateada_paso1:		; El bateador vuelve: la jugada se acaba
	call todos_parados		;8ea1   ; todos parados?
	ret nz			;8ea4
	ld c,000h		;8ea5   ; el bateador...
	call corredor_base		;8ea7
	ld (hl),000h		;8eaa   ; ...a cero...
	ex de,hl			;8eac
	ld (hl),0c2h		;8ead   ; ...y su sprite fuera
	xor a			;8eaf
	ld (0e00bh),a		;8eb0   ; sin pelota
	ld (0e009h),a		;8eb3
	ld hl,08040h		;8eb6   ; el bateador nuevo
	ld (0e001h),hl		;8eb9
	ret			;8ebc
fase_robo:		; El robo de base: el lanzador lanza a la base
	ld hl,078b0h		;8ebd   ; la pelota en el lanzador...
	ld (0e174h),hl		;8ec0
	ld (0e1a4h),hl		;8ec3
	ld a,024h		;8ec6   ; ...dibujo 0x24...
	ld (0e176h),a		;8ec8
	ld a,(0e01fh)		;8ecb   ; ...color del equipo
	ld (0e177h),a		;8ece
	ld a,040h		;8ed1   ; el sprite de la pelota en el campo
	ld (0e1a6h),a		;8ed3
	ld a,00fh		;8ed6
	ld (0e1a7h),a		;8ed8
	ld a,010h		;8edb   ; el lanzador en marcha
	ld (0e008h),a		;8edd
	xor a			;8ee0   ; las cuentas a cero
	ld (0e00dh),a		;8ee1
	ld (0e00ah),a		;8ee4
	ld (0e0a9h),a		;8ee7
	ld (0e03bh),a		;8eea
	ld (0e055h),a		;8eed
	ld a,092h		;8ef0   ; el corredor que va
	ld (0e05eh),a		;8ef2
	ld a,002h		;8ef5   ; la pelota bateada, quieta
	ld (0e00bh),a		;8ef7
	ld a,020h		;8efa   ; la pelota
	ld (0e009h),a		;8efc
	ld a,080h		;8eff   ; la orden
	ld (0e01ah),a		;8f01
	ld a,090h		;8f04   ; el tiro
	ld (0e054h),a		;8f06
	ld a,0c1h		;8f09   ; el receptor en casillas, a borrar
	ld (0e24eh),a		;8f0b
	ld hl,00100h		;8f0e   ; la cuenta
	ld (0e09eh),hl		;8f11
	ld hl,08004h		;8f14   ; la fase de los corredores
	ld (0e001h),hl		;8f17
	ret			;8f1a
corredor_base:		; HL = el corredor que esta en la base C (0xE067, 6 bytes; DE sus sprites); NZ si no hay
	push bc			;8f1b
	ld hl,0e067h		;8f1c   ; los cuatro corredores...
	ld de,0e154h		;8f1f   ; ...y sus sprites
	ld b,004h		;8f22
corredor_base_uno:		; Uno
	ld a,(hl)			;8f24
	bit 6,a		;8f25   ; fuera?
	jr nz,corredor_base_sig		;8f27
	and 003h		;8f29   ; su base...
	cp c			;8f2b   ; ...la C?
	jr z,corredor_base_fin		;8f2c
corredor_base_sig:		; El siguiente
	push de			;8f2e
	ld de,00006h		;8f2f   ; el siguiente: 6 bytes...
	add hl,de			;8f32
	pop de			;8f33
	push hl			;8f34
	ld hl,00004h		;8f35   ; ...y 4 de sprite
	add hl,de			;8f38
	ex de,hl			;8f39
	pop hl			;8f3a
	djnz corredor_base_uno		;8f3b
	inc b			;8f3d   ; NZ: no hay
corredor_base_fin:		; Fin
	pop bc			;8f3e
	ret			;8f3f
sprites_jugada_fuera:		; Los sprites de la jugada, fuera de la pantalla (Y 0xC2)
	ld a,0c2h		;8f40
	ld (0e16ch),a		;8f42   ; los sprites de la jugada (Y 0xC2: fuera)
	ld (0e170h),a		;8f45
	ld (0e164h),a		;8f48
	ld (0e168h),a		;8f4b
	ld (0e174h),a		;8f4e
	ret			;8f51
defensa_repinta:		; Los nueve jugadores de la defensa, a repintar
	ld bc,00008h		;8f52   ; nueve casillas, C de 8 a 0
defensa_repinta_uno:		; Uno
	call jugador_marca		;8f55
	dec c			;8f58
	jp p,defensa_repinta_uno		;8f59
	ret			;8f5c
jugador_marca:		; Marca al jugador C de la defensa (0xE24D) para repintarlo: B bit 0, borrarlo (ya corre en un sprite)
	ld hl,0e24dh		;8f5d   ; la casilla C...
	ld d,000h		;8f60
	ld e,c			;8f62
	add hl,de			;8f63
	ld a,080h		;8f64   ; 0x80: a repintar...
	bit 0,b		;8f66   ; ...vacia...
	jr z,jugador_marca_pon		;8f68
	ld a,0c0h		;8f6a   ; ...o 0xC0: ocupada
jugador_marca_pon:		; La marca
	or c			;8f6c
	ld (hl),a			;8f6d   ; guardada
	ret			;8f6e
defensa_pinta:		; Pinta los jugadores de la defensa marcados, en casillas (0x8FE7 sus sitios, 0x8FCB sus dibujos)
	ld b,009h		;8f6f   ; nueve casillas
	ld hl,0e24dh		;8f71
defensa_pinta_busca:		; El siguiente marcado
	bit 7,(hl)		;8f74   ; a repintar?
	jr nz,defensa_pinta_uno		;8f76
defensa_pinta_sig:		; El siguiente
	inc hl			;8f78
	djnz defensa_pinta_busca		;8f79
	ret			;8f7b
defensa_pinta_uno:		; Uno: su dibujo segun quien es, o vacio si hay que borrarlo
	push bc			;8f7c
	push hl			;8f7d
	ld a,(hl)			;8f7e   ; la marca...
	ld (hl),000h		;8f7f   ; ...ya pintada
	ld b,000h		;8f81   ; vacia...
	bit 6,a		;8f83   ; ...u ocupada
	jr z,defensa_pinta_quien		;8f85
	ld b,0ffh		;8f87
defensa_pinta_quien:		; Quien es
	and 03fh		;8f89   ; su numero
	ld c,a			;8f8b
	ld a,c			;8f8c
	rlca			;8f8d   ; por dos
	ld e,a			;8f8e
	ld d,000h		;8f8f
	ld hl,08fe7h		;8f91   ; su sitio en la tabla de nombres
	add hl,de			;8f94
	ld e,(hl)			;8f95
	inc hl			;8f96
	ld d,(hl)			;8f97
	push de			;8f98   ; guardado
	ld de,00004h		;8f99   ; 4 casillas por dibujo
	ld hl,08fcbh		;8f9c   ; los dibujos
	ld a,c			;8f9f
	cp 001h		;8fa0   ; la casilla 1...
	jr z,defensa_pinta_receptor		;8fa2
	jr c,defensa_pinta_lanzador		;8fa4   ; ...la 0...
	bit 0,b		;8fa6   ; ...ocupada...
	jr nz,defensa_pinta_d2		;8fa8
	cp 006h		;8faa   ; ...las bases 2 a 5...
	jr nc,defensa_pinta_d5		;8fac
	add hl,de			;8fae
defensa_pinta_d5:		; Un dibujo mas
	add hl,de			;8faf
defensa_pinta_d4:		; Un dibujo mas
	add hl,de			;8fb0
defensa_pinta_d3:		; Un dibujo mas
	add hl,de			;8fb1
defensa_pinta_d2:		; Un dibujo mas
	add hl,de			;8fb2
defensa_pinta_d1:		; Un dibujo mas
	add hl,de			;8fb3
defensa_pinta_dibujo:		; Las 2 x 2 casillas a la tabla de nombres
	pop de			;8fb4
	ld bc,00202h		;8fb5   ; 2 x 2 casillas
	call bloque		;8fb8   ; a la tabla de nombres
	pop hl			;8fbb
	pop bc			;8fbc
	jr defensa_pinta_sig		;8fbd   ; la siguiente
defensa_pinta_receptor:		; El receptor (1)
	bit 0,b		;8fbf
	jr z,defensa_pinta_d3		;8fc1
	jr defensa_pinta_d1		;8fc3
defensa_pinta_lanzador:		; El lanzador (0)
	bit 0,b		;8fc5
	jr z,defensa_pinta_d4		;8fc7
	jr defensa_pinta_dibujo		;8fc9

; ----------------------------------------------------------------------
; DATOS defensa_dibujos: Los dibujos de los jugadores de la defensa: siete
;   juegos de 2 x 2 casillas (vacio, el lanzador, el receptor, los del cuadro
;   y los de fuera)
;   0x8fcb..0x8fe7  (28 bytes)
DATA_defensa_dibujos:
	defb 002h,002h,002h,002h	; 8fcb
	defb 0aah,06ah,002h,002h	; 8fcf
	defb 003h,003h,003h,003h	; 8fd3
	defb 018h,019h,01ah,01bh	; 8fd7
	defb 020h,021h,022h,023h	; 8fdb
	defb 01ch,01dh,01eh,01fh	; 8fdf
	defb 01ch,01dh,01eh,01fh	; 8fe3

; ----------------------------------------------------------------------
; DATOS defensa_sitios: Los sitios de los nueve jugadores de la defensa en la
;   tabla de nombres
;   0x8fe7..0x8ff9  (18 bytes)
DATA_defensa_sitios:
	defw 0020fh,002cfh,001f9h,001b3h,001e5h,001abh,00186h,0014fh,00198h	; 8fe7

; ======================================================================
; CODIGO 0x8ff9..0x901c  (35 bytes)
; ======================================================================


bloque:		; Un bloque de B x C casillas desde HL a la tabla de nombres (0x1800 + DE)
	ld a,018h		;8ff9   ; la tabla de nombres...
	or d			;8ffb   ; ...0x1800 + DE
	ld d,a			;8ffc
bloque_fila:		; Una fila
	call fila		;8ffd
	push hl			;9000   ; la fila siguiente...
	ld hl,00020h		;9001   ; ...32 mas
	add hl,de			;9004
	ex de,hl			;9005
	pop hl			;9006
	dec c			;9007   ; C filas
	jr nz,bloque_fila		;9008
	ret			;900a
fila:		; B casillas desde HL a la VRAM DE (LDIRVM); HL avanza B
	push de			;900b
	push hl			;900c
	push bc			;900d
	ld c,b			;900e   ; B casillas
	ld b,000h		;900f
	call 0005ch		;9011   ; LDIRVM
	pop bc			;9014
	ld e,b			;9015   ; HL mas B
	ld d,000h		;9016
	pop hl			;9018
	add hl,de			;9019
	pop de			;901a
	ret			;901b

; ----------------------------------------------------------------------
; DATOS sin_llamada: Un trozo de codigo que nadie llama (ld bc,0x0203; ld
;   de,0x028F; ld hl,0x9028; jp bloque) y sus seis casillas; no se ejecuta
;   jugando ni en la demo
;   0x901c..0x902e  (18 bytes)
DATA_sin_llamada:
	defb 001h,003h,002h,011h,08fh,002h,021h,028h,090h,0c3h,0f9h,08fh,018h,019h,01ah,01bh	; 901c  ......!(........
	defb 01ch,01dh	; 902c

; ======================================================================
; CODIGO 0x902e..0x90a1  (115 bytes)
; ======================================================================


cuenta:		; La cuenta: S, B y O en bolas (0x91 encendida, 0x06 apagada)
	ld hl,0e211h		;902e   ; las bolas de la cuenta, en 0xE211
	ld a,(0e013h)		;9031   ; los strikes...
	call bolas		;9034
	ld a,(0e014h)		;9037   ; ...las bolas...
	call bolas		;903a
	ld a,(0e015h)		;903d   ; ...y los outs
	call bolas		;9040
	ld de,000b9h		;9043   ; fila 5, columna 25
	ld bc,00303h		;9046   ; 3 x 3 casillas
	ld hl,0e211h		;9049
	ld a,006h		;904c   ; la S, B y O delante (0x06)
	ld (0e219h),a		;904e
	call bloque		;9051   ; a la pantalla
	call cartel_cuenta		;9054   ; el cartel de la cuenta
	jp cartel_jugada		;9057   ; y el de la jugada
cartel_cuenta:		; El cartel de la cuenta (BALL, STRIKE, FOUL) con su sonido, y apagarlo
	ld hl,0e003h		;905a
	bit 7,(hl)		;905d   ; bit 7: hay cartel
	ret z			;905f
	bit 6,(hl)		;9060   ; bit 6: ya puesto
	jr nz,cartel_cuenta_apaga		;9062
	set 6,(hl)		;9064   ; ya puesto
	ld a,(hl)			;9066   ; el texto...
	and 00ch		;9067
	ld b,a			;9069   ; ...por 6
	rrca			;906a
	add a,b			;906b
	push af			;906c
	ld b,000h		;906d   ; el canal 0
	ld de,0beefh		;906f   ; STRIKE: 0xBEEF
	cp 006h		;9072   ; el texto 6?
	jr z,cartel_cuenta_sonido		;9074
	ld de,0bedch		;9076   ; BALL: 0xBEDC
	cp 00ch		;9079   ; el 12?
	jr nz,cartel_cuenta_pon		;907b
cartel_cuenta_sonido:		; Su sonido
	call pieza		;907d
cartel_cuenta_pon:		; El cartel
	pop af			;9080
	jr cartel_cuenta_texto		;9081
cartel_cuenta_apaga:		; Lo apaga a su tiempo
	ld a,(0e0a2h)		;9083   ; su cuenta...
	rlca			;9086   ; ...aun no
	ret c			;9087
	res 6,(hl)		;9088   ; se acaba
	res 7,(hl)		;908a
	xor a			;908c   ; el texto vacio
cartel_cuenta_texto:		; Seis letras de 0x90A1 en la fila 3, columna 24
	ld c,a			;908d
	ld b,000h		;908e
	ld hl,090a1h		;9090   ; en 0x90A1
	add hl,bc			;9093
	ld de,01878h		;9094   ; fila 3, columna 24
	ld b,006h		;9097   ; seis letras
	ld a,0c0h		;9099   ; su cuenta
	ld (0e0a2h),a		;909b
	jp fila		;909e

; ----------------------------------------------------------------------
; DATOS textos_cuenta: BALL, STRIKE y FOUL (seis letras cada uno; 0x06 es el
;   espacio)
;   0x90a1..0x90b9  (24 bytes)
DATA_textos_cuenta:
	defb 006h,006h,006h,006h,006h,006h,006h,042h,041h,04ch,04ch,006h,053h,054h,052h,049h	; 90a1  .......BALL.STRI
	defb 04bh,045h,006h,046h,04fh,055h,04ch,006h	; 90b1  KE.FOUL.

; ======================================================================
; CODIGO 0x90b9..0x9119  (96 bytes)
; ======================================================================


bolas:		; A bolas encendidas de tres
	ld b,003h		;90b9
bolas_una:		; Una
	ld c,006h		;90bb   ; vacia (0x06)
	dec a			;90bd   ; una menos...
	jp m,bolas_pon		;90be
	ld c,091h		;90c1   ; ...encendida (0x91)
bolas_pon:		; La pone
	ld (hl),c			;90c3
	inc hl			;90c4
	djnz bolas_una		;90c5
	ret			;90c7
cartel_jugada:		; El cartel de la jugada (OUT, SAFE, CHANGE) con su sonido, y apagarlo
	ld hl,0e003h		;90c8
	bit 5,(hl)		;90cb   ; bit 5: hay cartel
	ret z			;90cd
	bit 4,(hl)		;90ce   ; bit 4: ya puesto
	jr nz,cartel_jugada_apaga		;90d0
	set 4,(hl)		;90d2   ; ya puesto
	ld a,(hl)			;90d4   ; el texto...
	and 003h		;90d5
	add a,a			;90d7   ; ...por 6
	ld b,a			;90d8
	add a,a			;90d9
	add a,b			;90da
	jr z,cartel_jugada_texto		;90db
	push af			;90dd
	cp 006h		;90de   ; el 6?
	jr z,cartel_jugada_out		;90e0
	cp 00ch		;90e2   ; el 12?
	jr z,cartel_jugada_change		;90e4
	pop af			;90e6
	jr cartel_jugada_texto		;90e7
cartel_jugada_out:		; OUT
	ld b,000h		;90e9
	ld de,0bf52h		;90eb   ; OUT: 0xBF52
	jr cartel_jugada_sonido		;90ee
cartel_jugada_change:		; CHANGE
	ld b,000h		;90f0
	ld de,0bf42h		;90f2   ; CHANGE: 0xBF42
cartel_jugada_sonido:		; Su sonido
	call pieza		;90f5
	pop af			;90f8
	jr cartel_jugada_texto		;90f9
cartel_jugada_apaga:		; Lo apaga a su tiempo
	ld a,(0e0a3h)		;90fb   ; su cuenta...
	rlca			;90fe   ; ...aun no
	ret c			;90ff
	res 4,(hl)		;9100   ; se acaba
	res 5,(hl)		;9102
	xor a			;9104   ; el texto vacio
cartel_jugada_texto:		; Seis letras de 0x9119
	ld c,a			;9105
	ld b,000h		;9106
	ld hl,09119h		;9108   ; en 0x9119
	add hl,bc			;910b
	ld de,01878h		;910c   ; fila 3, columna 24
	ld b,006h		;910f   ; seis letras
	ld a,0a0h		;9111   ; su cuenta
	ld (0e0a3h),a		;9113
	jp fila		;9116

; ----------------------------------------------------------------------
; DATOS textos_jugada: OUT, SAFE y CHANGE
;   0x9119..0x9131  (24 bytes)
DATA_textos_jugada:
	defb 006h,006h,006h,006h,006h,006h,006h,04fh,055h,054h,006h,006h,006h,053h,041h,046h	; 9119  .......OUT...SAF
	defb 045h,006h,043h,048h,041h,04eh,047h,045h	; 9129  E.CHANGE

; ======================================================================
; CODIGO 0x9131..0x91dc  (171 bytes)
; ======================================================================


outs:		; El tercer out: CHANGE, la media entrada siguiente y el fin de la partida
	ld a,(0e01eh)		;9131   ; la jugada en marcha?
	rlca			;9134
	ret nc			;9135
	ld hl,0e015h		;9136   ; los outs...
	ld a,(hl)			;9139   ; ...uno mas...
	inc a			;913a
	cp 003h		;913b   ; ...tres?
	jr nc,outs_tres		;913d
	ld (hl),a			;913f   ; no: guardado...
	ld a,021h		;9140   ; ...y el cartel OUT
	ld (0e003h),a		;9142
	xor a			;9145   ; la jugada acabada
	ld (0e01eh),a		;9146
	ret			;9149
outs_tres:		; Tres outs
	ld a,(0e01eh)		;914a
	bit 6,a		;914d   ; el tercer out ya visto?
	jr nz,outs_cambio		;914f
	ld a,(0e00fh)		;9151   ; hubo robo?
	rlca			;9154
	jr nc,L_915B		;9155
	xor a			;9157   ; la base por bolas, acabada
	ld (0e01ch),a		;9158
L_915B:
	ld a,021h		;915b   ; el cartel OUT
	ld (0e003h),a		;915d
	inc (hl)			;9160   ; el tercer out
	xor a			;9161   ; la jugada...
	ld (0e054h),a		;9162
	ld (0e00eh),a		;9165
	ld (0e043h),a		;9168
	ld hl,0e01eh		;916b
	ld (hl),0c0h		;916e   ; el tercer out, visto
	ld hl,00000h		;9170
	ld (0e001h),hl		;9173   ; sin fase
	ret			;9176
outs_cambio:		; El cambio de campo
	bit 5,a		;9177
	jr nz,outs_otro		;9179
	ld a,(0e003h)		;917b   ; hay cartel?
	and 0a0h		;917e
	ret nz			;9180
	ld a,(0e004h)		;9181   ; la media entrada...
	inc a			;9184   ; ...una mas...
	ld (0e004h),a		;9185
	cp 011h		;9188   ; ...la baja de la novena?
	jr z,outs_novena		;918a
	jr nc,outs_fin		;918c   ; mas: se acaba
outs_change:		; CHANGE con su sonido (0x91DC)
	ld a,023h		;918e
	ld (0e003h),a		;9190   ; el cartel CHANGE
	ld b,001h		;9193   ; el canal 1...
	ld de,091dch		;9195   ; ...0x91DC
	call pieza		;9198
	ld hl,0e01eh		;919b   ; el cambio, en marcha
	set 5,(hl)		;919e
	ret			;91a0
outs_otro:		; El otro equipo batea
	ld a,(0e003h)		;91a1
	and 0a0h		;91a4   ; hay cartel?
	ret nz			;91a6
	ld hl,0e006h		;91a7   ; batea el otro equipo
	ld a,(hl)			;91aa
	ld b,040h		;91ab   ; 0x40...
	bit 7,a		;91ad
	jr nz,L_91B3		;91af
	ld b,068h		;91b1   ; ...o 0x68
L_91B3:
	xor b			;91b3
	ld (hl),a			;91b4
	ld hl,08080h		;91b5   ; el bateador nuevo
	ld (0e001h),hl		;91b8
	call corredores_borra		;91bb   ; los corredores a cero
	xor a			;91be   ; el tercer out...
	ld (0e01eh),a		;91bf
	ld (0e015h),a		;91c2   ; ...y los outs a cero
	jp sprites_jugada_fuera		;91c5   ; los sprites, fuera
outs_novena:		; La novena: si el de casa va ganando, no batea
	ld a,(0e03ah)		;91c8   ; las del de casa...
	ld b,a			;91cb
	ld a,(0e030h)		;91cc   ; ...contra las del de fuera
	cp b			;91cf   ; el de casa no gana: sigue
	jr nc,outs_change		;91d0
outs_fin:		; La partida se acaba
	xor a			;91d2   ; la partida...
	ld (0e01eh),a		;91d3
	ld hl,0e006h		;91d6
	set 0,(hl)		;91d9   ; ...acabada
	ret			;91db

; ----------------------------------------------------------------------
; DATOS sonido_change: El sonido de CHANGE: una pieza del motor
;   0x91dc..0x91ec  (16 bytes)
DATA_sonido_change:
	defb 0fah,000h,00ch,0fbh,000h,006h,030h,002h,006h,035h,002h,006h,0fch,000h,006h,0ffh	; 91dc  ......0..5......

; ======================================================================
; CODIGO 0x91ec..0x9319  (301 bytes)
; ======================================================================


carreras:		; Una carrera: al marcador de la entrada y la suma; diez o mas, la partida se acaba
	ld a,(0e004h)		;91ec   ; la media entrada...
	srl a		;91ef   ; ...entre 2: la entrada
	ld b,00ah		;91f1   ; la baja...
	jr c,carreras_casilla		;91f3
	ld b,000h		;91f5   ; ...la alta
carreras_casilla:		; La casilla de la entrada
	add a,b			;91f7
	ld c,a			;91f8   ; la casilla de la entrada
	ld b,000h		;91f9
	ld hl,0e027h		;91fb   ; en 0xE027
	add hl,bc			;91fe
	ld a,b			;91ff   ; la primera?
	or c			;9200
	push hl			;9201
	jr z,carreras_tercer		;9202
	ld de,00009h		;9204   ; la anterior del otro equipo...
	ld a,c			;9207
	cp 00ah		;9208
	jr c,carreras_otro		;920a
	ld de,0fff6h		;920c   ; ...9 adelante o 10 atras
carreras_otro:		; La del otro equipo
	add hl,de			;920f
	ld a,(hl)			;9210   ; sin jugar (0xFF)...
	inc a			;9211
	jr nz,carreras_tercer		;9212
	inc (hl)			;9214   ; ...a 0
carreras_tercer:		; Con dos outs, solo si nadie esta en juego
	ld a,(0e015h)		;9215   ; los outs...
	cp 002h		;9218   ; ...dos?
	jr nz,carreras_corredor		;921a
	call alguno_corre		;921c   ; algun corredor en marcha?
	pop hl			;921f
	ret z			;9220
	push hl			;9221
carreras_corredor:		; El corredor que llega a casa
	ld hl,0e067h		;9222   ; los cuatro corredores
	ld de,00006h		;9225
	ld b,004h		;9228
carreras_busca:		; Uno
	bit 2,(hl)		;922a   ; llega a casa (bit 2)?
	jr nz,carreras_llega		;922c
	add hl,de			;922e
	djnz carreras_busca		;922f
	pop hl			;9231
	ret			;9232
carreras_llega:		; Llega: una carrera
	res 2,(hl)		;9233   ; ya no
	pop hl			;9235
	ld a,(0e015h)		;9236   ; los outs...
	cp 003h		;9239   ; ...tres: no cuenta
	ret nc			;923b
	ld a,0c0h		;923c   ; el cartel parpadeante
	ld (0e025h),a		;923e
	ld a,(hl)			;9241   ; la casilla de la entrada...
	add a,001h		;9242   ; ...sin jugar (0xFF)...
	jr nz,carreras_suma		;9244
	inc (hl)			;9246   ; ...pasa a 0
carreras_suma:		; La suma de cada equipo
	inc (hl)			;9247   ; una carrera
	ld a,(0e001h)		;9248   ; la fase...
	rrca			;924b
	jr c,carreras_suma2		;924c   ; ...la de la jugada?
	ld a,022h		;924e   ; el cartel 0x22
	ld (0e003h),a		;9250
	ld hl,0e041h		;9253   ; la carrera, apuntada
	ld (hl),080h		;9256
carreras_suma2:		; La del otro
	ld hl,0e027h		;9258   ; la suma del primero...
	call suma9		;925b
	cp 064h		;925e   ; ...cien o mas?
	jr nc,carreras_fin		;9260
	ld c,a			;9262
	ld (0e030h),a		;9263   ; guardada
	ld hl,0e031h		;9266   ; la del segundo
	call suma9		;9269
	cp 064h		;926c   ; cien o mas?
	jr nc,carreras_fin		;926e
	ld (0e03ah),a		;9270   ; guardada
	ld a,(0e004h)		;9273   ; la novena baja?
	cp 011h		;9276
	ret c			;9278
	ld a,c			;9279   ; el de casa...
	cp d			;927a   ; ...ya gana?
	ret nc			;927b
	ld hl,0e006h		;927c
	ld a,(0e00bh)		;927f   ; hay robo?
	rrca			;9282
	jr c,carreras_fin_robo		;9283
	set 0,(hl)		;9285   ; la partida se acaba
	ret			;9287
carreras_fin_robo:		; Fin con robo
	set 1,(hl)		;9288   ; se acabara al acabar la jugada
	ret			;928a
carreras_fin:		; Fin
	ld hl,0e006h		;928b
	set 0,(hl)		;928e   ; la partida se acaba
	ret			;9290
suma9:		; La suma de nueve casillas hasta la primera 0xFF
	ld b,009h		;9291
	ld d,000h		;9293   ; la suma
suma9_una:		; Una
	ld a,(hl)			;9295   ; una casilla...
	cp 0ffh		;9296   ; ...sin jugar: fin
	jr z,suma9_fin		;9298
	add a,d			;929a   ; suma
	ld d,a			;929b
	inc hl			;929c
	djnz suma9_una		;929d
suma9_fin:		; Fin
	ld a,d			;929f
	ret			;92a0
marcador:		; El marcador: las 20 casillas de carreras, dibujadas en 0xE0B0 y a la VRAM (0x0F00)
	ld hl,0e027h		;92a1
	ld de,0e0b0h		;92a4   ; en 0xE0B0
	ld b,014h		;92a7   ; 20 casillas
marcador_una:		; Una
	push hl			;92a9
	push de			;92aa
	push bc			;92ab
	call marcador_cifra		;92ac
	pop bc			;92af
	pop de			;92b0
	ld hl,00008h		;92b1   ; 8 bytes cada una
	add hl,de			;92b4
	ex de,hl			;92b5
	pop hl			;92b6
	inc hl			;92b7
	djnz marcador_una		;92b8
	ld hl,0e0b0h		;92ba
	ld de,00f00h		;92bd   ; a 0x0F00: las casillas 0xE0-0xF3
	ld b,0a0h		;92c0   ; 160 bytes
	jp fila		;92c2
marcador_cifra:		; Una cifra: de 0 a 9, la letra de la fuente (LDIRMV); de 10 en adelante, dos cifras pequenas (0x9319)
	ld a,(hl)			;92c5
	cp 0ffh		;92c6   ; sin jugar?
	jp z,marcador_vacia		;92c8
	cp 00ah		;92cb   ; de 10 en adelante?
	jr nc,marcador_dos		;92cd
marcador_fuente:		; La letra de la fuente
	rlca			;92cf
	rlca			;92d0   ; por 8
	rlca			;92d1
	ld c,a			;92d2
	ld b,000h		;92d3
	ld hl,00180h		;92d5   ; la cifra de la fuente (casilla 0x30 + A)...
	add hl,bc			;92d8
	ld bc,00008h		;92d9   ; ...8 bytes...
	jp 00059h		;92dc   ; ...LDIRMV
marcador_dos:		; Dos cifras
	ld bc,00a00h		;92df   ; las decenas: C
marcador_decenas:		; Las decenas
	cp 00ah		;92e2   ; 10 o mas?
	jr c,marcador_pinta		;92e4
	sub 00ah		;92e6   ; diez menos...
	inc c			;92e8   ; ...una decena mas
	djnz marcador_decenas		;92e9
marcador_pinta:		; Juntas: la de las decenas en la mitad izquierda
	sla c		;92eb   ; por 8
	sla c		;92ed
	sla c		;92ef
	ld l,c			;92f1
	ld h,000h		;92f2
	ld bc,09319h		;92f4   ; la cifra pequena de las decenas
	add hl,bc			;92f7
	push hl			;92f8
	add a,a			;92f9   ; la de las unidades, por 8
	add a,a			;92fa
	add a,a			;92fb
	ld c,a			;92fc
	ld b,000h		;92fd
	ld hl,09319h		;92ff   ; en 0x9319
	add hl,bc			;9302
	pop bc			;9303
	ld a,008h		;9304
marcador_fila:		; Una fila
	push af			;9306
	ld a,(bc)			;9307   ; la de las decenas...
	rlca			;9308   ; ...a la mitad izquierda...
	rlca			;9309
	rlca			;930a
	rlca			;930b
	or (hl)			;930c   ; ...con la de las unidades
	inc bc			;930d
	inc hl			;930e
	ld (de),a			;930f   ; guardada
	inc de			;9310
	pop af			;9311
	dec a			;9312
	jr nz,marcador_fila		;9313
	ret			;9315
marcador_cero:		; Un cero
	xor a			;9316   ; la cifra 0
	jr marcador_fuente		;9317

; ----------------------------------------------------------------------
; DATOS cifras_pequenas: Las diez cifras pequenas del marcador: 4 bits de
;   ancho, 8 filas
;   0x9319..0x9369  (80 bytes)
DATA_cifras_pequenas:
	defb 004h,00ah,00ah,00ah,00ah,00ah,004h,000h	; 9319  ........
	defb 004h,00ch,004h,004h,004h,004h,00eh,000h	; 9321  ........
	defb 004h,00ah,002h,004h,008h,008h,00eh,000h	; 9329  ........
	defb 004h,00ah,002h,004h,002h,00ah,004h,000h	; 9331  ........
	defb 008h,008h,00ah,00ah,00fh,002h,002h,000h	; 9339  ........
	defb 00eh,008h,008h,00ch,002h,00ah,004h,000h	; 9341  ........
	defb 004h,00ah,008h,00ch,00ah,00ah,004h,000h	; 9349  ........
	defb 00eh,002h,002h,002h,002h,002h,002h,000h	; 9351  ........
	defb 004h,00ah,00ah,004h,00ah,00ah,004h,000h	; 9359  ........
	defb 004h,00ah,00ah,006h,002h,00ah,004h,000h	; 9361  ........

; ======================================================================
; CODIGO 0x9369..0x9382  (25 bytes)
; ======================================================================


marcador_vacia:		; Una casilla sin jugar: vacia, o la X de la novena no jugada
	ld a,(0e004h)		;9369   ; la media entrada...
	cp 011h		;936c   ; ...la novena baja?
	jr c,$+28		;936e
	jr nz,$-90		;9370
	ld a,(0e006h)		;9372   ; la partida acabada?
	bit 0,a		;9375
	jr z,$+19		;9377
	ld hl,09382h		;9379   ; la X...
	ld bc,00008h		;937c   ; ...8 bytes
	ldir		;937f
	ret			;9381

; ----------------------------------------------------------------------
; DATOS aspa: La X: la novena que no se juega porque el de casa ya gana
;   0x9382..0x938a  (8 bytes)
DATA_aspa:
	defb 082h,044h,028h,010h,028h,044h,082h,000h	; 9382  .D(.(D..

; ======================================================================
; CODIGO 0x938a..0x93e2  (88 bytes)
; ======================================================================


marcador_blanco:		; Ocho bytes a cero
	ld a,000h		;938a   ; ocho bytes a cero
	ld b,008h		;938c
marcador_blanco_uno:		; Uno
	ld (de),a			;938e
	inc de			;938f
	djnz marcador_blanco_uno		;9390
	ret			;9392
cartel:		; La ventana (0xE000): el lanzamiento de cerca o un texto de 0x93E2 (el 7, ninguno)
	ld hl,0e000h		;9393
	ld a,(hl)			;9396   ; la ventana pendiente?
	rlca			;9397
	ret nc			;9398
	res 7,(hl)		;9399   ; ya no
	rlca			;939b   ; bit 6: el lanzamiento de cerca
	jp c,cartel_lanzamiento		;939c
	ld a,006h		;939f   ; 0x06: vacia
	ld hl,0e600h		;93a1   ; en 0xE600
	push hl			;93a4
	ld b,054h		;93a5   ; 84 casillas
cartel_borra:		; La ventana a 0x06 (vacia)
	ld (hl),a			;93a7
	inc hl			;93a8
	djnz cartel_borra		;93a9
	pop hl			;93ab
	ld de,0000ah		;93ac   ; fila 0, columna 10
	ld bc,00c07h		;93af   ; 12 x 7
	call bloque		;93b2
	ld a,0c2h		;93b5   ; la pelota de la ventana, fuera
	ld (0e1a0h),a		;93b7
	ld a,(0e000h)		;93ba   ; el texto...
	cp 007h		;93bd   ; ...el 7: ninguno
	ret z			;93bf
	add a,a			;93c0   ; por 24
	add a,a			;93c1
	add a,a			;93c2
	ld b,a			;93c3
	add a,a			;93c4
	add a,b			;93c5
	ld e,a			;93c6
	ld d,000h		;93c7
	ld hl,093e2h		;93c9   ; en 0x93E2
	add hl,de			;93cc
	ld de,0004ah		;93cd   ; fila 2, columna 10
	ld bc,00c02h		;93d0   ; 12 x 2
	jp bloque		;93d3
cartel_lanzamiento:		; El lanzamiento de cerca (0x948A)
	ld hl,0948ah		;93d6
	ld de,0000ah		;93d9   ; fila 0, columna 10
	ld bc,00c07h		;93dc   ; 12 x 7
	jp bloque		;93df

; ----------------------------------------------------------------------
; DATOS textos_ventana: Los textos de la ventana (12 x 2): 0 GAME SET, 1 NICE
;   / HOME RUN, 2 SELECT 1PLAYER TEAM, 3 GAME OVER, 4 NEXT GAME A / RESET B, 5
;   CASIO en letras grandes, 6 GAME CLEAR
;   0x93e2..0x948a  (168 bytes)
DATA_textos_ventana:
	defb 006h,006h,047h,041h,04dh,045h,006h,053h,045h,054h,006h,006h	; 93e2  ..GAME.SET..
	defb 006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h	; 93ee  ............
	defb 006h,04eh,049h,043h,045h,006h,006h,006h,006h,006h,006h,006h	; 93fa  .NICE.......
	defb 006h,006h,006h,048h,04fh,04dh,045h,006h,052h,055h,04eh,006h	; 9406  ...HOME.RUN.
	defb 006h,006h,053h,045h,04ch,045h,043h,054h,006h,006h,006h,006h	; 9412  ..SELECT....
	defb 031h,050h,04ch,041h,059h,045h,052h,006h,054h,045h,041h,04dh	; 941e  1PLAYER.TEAM
	defb 006h,006h,047h,041h,04dh,045h,006h,04fh,056h,045h,052h,006h	; 942a  ..GAME.OVER.
	defb 006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h	; 9436  ............
	defb 04eh,045h,058h,054h,006h,047h,041h,04dh,045h,006h,006h,041h	; 9442  NEXT.GAME..A
	defb 052h,045h,053h,045h,054h,006h,006h,006h,006h,006h,006h,042h	; 944e  RESET......B
	defb 006h,020h,022h,024h,026h,028h,02ah,02ch,006h,020h,02eh,006h	; 945a  . "$&(*,. ..
	defb 006h,021h,023h,025h,027h,029h,02bh,02dh,006h,021h,02fh,006h	; 9466  .!#%')+-.!/.
	defb 006h,047h,041h,04dh,045h,006h,043h,04ch,045h,041h,052h,006h	; 9472  .GAME.CLEAR.
	defb 006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h,006h	; 947e  ............

; ----------------------------------------------------------------------
; DATOS ventana_lanzamiento: El lanzamiento de cerca en la ventana: el campo
;   desde detras del lanzador, 12 x 7 casillas
;   0x948a..0x94de  (84 bytes)
DATA_ventana_lanzamiento:
	defb 003h,003h,003h,075h,076h,077h,0b7h,0b6h,0b5h,003h,003h,003h	; 948a  ...uvw......
	defb 075h,076h,077h,002h,002h,002h,002h,002h,002h,0b7h,0b6h,0b5h	; 9496  uvw.........
	defb 002h,002h,002h,002h,002h,090h,0d0h,002h,002h,002h,002h,002h	; 94a2  ............
	defb 002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h	; 94ae  ............
	defb 002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h	; 94ba  ............
	defb 002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h	; 94c6  ............
	defb 002h,0b3h,0b2h,0b1h,0b0h,0afh,06fh,070h,071h,072h,073h,002h	; 94d2  ......opqrs.

; ======================================================================
; CODIGO 0x94de..0x97c5  (743 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; El ordenador juega con el segundo mando: en cada fase escribe en 0xE08E la direccion y el boton que pulsaria un jugador.
; ----------------------------------------------------------------------
ordenador:		; Los mandos del ordenador, segun la fase
	ld hl,0e006h		;94de   ; dos jugadores? entonces el ordenador no juega
	bit 7,(hl)		;94e1   ; un jugador?
	ret nz			;94e3
	xor a			;94e4   ; su mando a cero
	ld ix,0e08eh		;94e5   ; el segundo mando...
	ld (ix+000h),a		;94e9   ; ...a cero
	ld (ix+001h),a		;94ec   ; (y lo recien pulsado)
	ld a,(0e001h)		;94ef   ; la fase: bit 5 el lanzamiento...
	rlca			;94f2
	rlca			;94f3
	rlca			;94f4
	jr c,ordenador_lanza		;94f5
	rlca			;94f7   ; ...bit 4 la pelota bateada...
	jp c,ordenador_bateada		;94f8
	rlca			;94fb
	rlca			;94fc
	jp c,ordenador_corre		;94fd
	rlca			;9500   ; ...bit 2 los corredores
	jp c,ordenador_fin_jugada		;9501
	ret			;9504
ordenador_lanza:		; En el lanzamiento: si lanza el ordenador, el efecto al azar; si batea, el swing
	bit 3,(hl)		;9505   ; el ordenador lanza?
	jp z,ordenador_corredores		;9507
	ld a,(0e009h)		;950a   ; la pelota ya sale?
	bit 0,a		;950d   ; la pelota ya ha salido?
	jr nz,ordenador_batea		;950f
	ld hl,0e040h		;9511   ; el efecto, al azar
	ld (hl),000h		;9514   ; el efecto...
	ld a,r		;9516   ; ...al azar...
	and 00fh		;9518
	jr nz,ordenador_azar		;951a
	set 7,(hl)		;951c   ; ...a veces con bit 7
ordenador_azar:		; Otro numero al azar (el registro R)
	ld a,r		;951e
	rlca			;9520   ; el azar se mueve
	ld r,a		;9521
	and 07fh		;9523   ; el efecto
	or (hl)			;9525
	ld (hl),a			;9526
	ld a,r		;9527   ; la altura a la que batea, al azar entre 0x9A y 0xA2
	rlca			;9529
	ld r,a		;952a
	and 00fh		;952c   ; la altura...
	add a,09ah		;952e   ; ...de 0x9A...
	cp 0a3h		;9530   ; ...a 0xA2
	jr nc,ordenador_azar		;9532
	ld (0e03dh),a		;9534   ; guardada
	ld a,(0e0a0h)		;9537   ; la cuenta de cuadros...
	bit 6,a		;953a   ; ...bit 6?
	ret nz			;953c
	ld (ix+000h),022h		;953d   ; abajo y el boton 2, en los cuadros pares de 64
	ret			;9541
ordenador_batea:		; Batea: mueve el bate hacia la pelota y el boton al llegar a su altura
	ld hl,0e040h		;9542
	bit 7,(hl)		;9545   ; bit 7?
	jr z,ordenador_batea_x		;9547
	res 7,(hl)		;9549   ; una vez
	ld (ix+000h),028h		;954b   ; a la derecha y el boton 2
ordenador_batea_x:		; La X del bate hacia la de la pelota
	ld bc,00000h		;954f
	ld a,(0e091h)		;9552   ; la pelota...
	add a,01fh		;9555   ; ...cerca?
	cp 036h		;9557
	ret nc			;9559
	ld a,(0e1a5h)		;955a   ; la X de la pelota...
	ld hl,(0e1b8h)		;955d   ; ...y la del bate
	cp h			;9560
	jr z,ordenador_batea_y		;9561
	ld b,004h		;9563   ; arriba...
	jr c,ordenador_batea_y		;9565
	ld b,008h		;9567   ; ...o abajo
ordenador_batea_y:		; La Y
	ld a,(0e1a4h)		;9569
	cp l			;956c   ; la Y
	jr z,ordenador_batea_boton		;956d
	ld c,002h		;956f   ; a la derecha...
	jr nc,ordenador_batea_boton		;9571
	ld c,001h		;9573   ; ...o a la izquierda
ordenador_batea_boton:		; El boton, con la pelota a su altura
	ld a,(ix+000h)		;9575   ; la direccion
	or b			;9578
	or c			;9579
	ld (ix+000h),a		;957a
	ld a,(0e1a8h)		;957d   ; la altura de la pelota...
	ld hl,(0e03dh)		;9580   ; ...y la elegida
	cp l			;9583
	ret c			;9584
	ld a,(0e1ech)		;9585   ; la pelota en el campo?
	cp 0c0h		;9588
	ret nc			;958a
	set 4,(ix+000h)		;958b   ; el boton
	ret			;958f
ordenador_corredores:		; Los corredores: a la base siguiente, segun por donde va la pelota
	bit 5,(hl)		;9590   ; los corredores?
	ret z			;9592
	ld a,(0e009h)		;9593
	bit 0,a		;9596   ; la pelota bateada?
	jp nz,ordenador_roba_sigue		;9598
	ld c,001h		;959b   ; el de primera
	call corredor_base		;959d
	jr nz,ordenador_corredor2		;95a0
	ld bc,00005h		;95a2   ; su Y...
	add hl,bc			;95a5
	ld a,(hl)			;95a6
	cp 0beh		;95a7   ; ...pasada la mitad?
	jr nc,ordenador_corredor2		;95a9
	ld (ix+000h),028h		;95ab   ; a la derecha y el boton 2
	jr ordenador_roba		;95af
ordenador_corredor2:		; El de segunda
	ld c,002h		;95b1   ; el de segunda
	call corredor_base		;95b3
	jr nz,ordenador_corredor3		;95b6
	ld bc,00005h		;95b8
	add hl,bc			;95bb
	ld a,(hl)			;95bc
	cp 070h		;95bd   ; pasada la mitad?
	jr nc,ordenador_corredor3		;95bf
	ld (ix+000h),021h		;95c1   ; arriba y el boton 2
	jr ordenador_roba		;95c5
ordenador_corredor3:		; El de tercera
	ld c,003h		;95c7   ; el de tercera
	call corredor_base		;95c9
	jr nz,ordenador_roba		;95cc
	ld bc,00005h		;95ce
	add hl,bc			;95d1
	ld a,(hl)			;95d2
	cp 042h		;95d3   ; pasada la mitad?
	jr c,ordenador_roba		;95d5
	ld (ix+000h),024h		;95d7   ; a la izquierda y el boton 2
ordenador_roba:		; El robo: al azar
	ld a,(0e0a9h)		;95db   ; la cuenta...
	cp 010h		;95de   ; ...16?
	ret nc			;95e0
	set 4,(ix+000h)		;95e1   ; el boton
	ld a,r		;95e5   ; al azar...
	res 7,a		;95e7
	ld (0e0a9h),a		;95e9   ; ...la cuenta
	ld hl,0e04ah		;95ec   ; la orden
	xor a			;95ef
	ld (hl),a			;95f0
	ld a,r		;95f1   ; al azar...
	bit 2,a		;95f3
	jr z,ordenador_roba_lado		;95f5
	set 0,(hl)		;95f7   ; ...segunda...
	bit 3,a		;95f9
	jr z,ordenador_roba_lado		;95fb
	res 0,(hl)		;95fd   ; ...o tercera
	set 1,(hl)		;95ff
ordenador_roba_lado:		; Segun el lanzador
	ld a,(0e1a1h)		;9601   ; la X del lanzador...
	cp 077h		;9604   ; ...a la izquierda?
	jr c,ordenador_roba_izq		;9606
	cp 07ah		;9608   ; ...en medio?
	jr c,ordenador_roba_medio		;960a
	ld a,r		;960c
	bit 0,a		;960e
	jr nz,ordenador_roba_2		;9610
	bit 1,a		;9612
	jr nz,ordenador_roba_3		;9614
	ret			;9616
ordenador_roba_medio:		; En el medio
	ld a,r		;9617   ; al azar...
	bit 0,a		;9619   ; ...la mitad de las veces, nada
	ret z			;961b
	bit 1,a		;961c   ; bit 1...
	jr z,ordenador_roba_3		;961e
	jr ordenador_roba_2		;9620
ordenador_roba_izq:		; A la izquierda
	ld a,r		;9622   ; al azar...
	bit 0,a		;9624   ; ...bit 0: tercera
	jr nz,ordenador_roba_3		;9626
	bit 1,a		;9628   ; bit 1: segunda
	jr nz,ordenador_roba_2		;962a
	ret			;962c
ordenador_roba_3:		; Roba tercera
	set 3,(hl)		;962d
	ret			;962f
ordenador_roba_2:		; Roba segunda
	set 2,(hl)		;9630
	ret			;9632
ordenador_roba_sigue:		; Sigue con lo que hacia
	ld a,(0e04ah)		;9633
	ld (ix+000h),a		;9636
	ret			;9639
ordenador_bateada:		; La pelota bateada: el ordenador en el campo lanza a la base que hace falta
	bit 3,(hl)		;963a
	jp z,ordenador_corre		;963c
	ld a,(0e04ch)		;963f   ; el campo...
	rlca			;9642   ; ...en marcha?
	jr nz,ordenador_bateada_base		;9643
	set 4,(ix+000h)		;9645   ; el boton
	ret			;9649
ordenador_bateada_base:		; A que base
	ld a,(0e097h)		;964a   ; la direccion...
	ld hl,(0e01bh)		;964d   ; ...las bases
	bit 2,l		;9650   ; primera ocupada...
	jr z,ordenador_bateada_2		;9652
	bit 5,l		;9654   ; ...sin corredor en marcha?
	jr nz,ordenador_bateada_2		;9656
	set 4,(ix+000h)		;9658   ; el boton...
	set 2,(ix+000h)		;965c   ; ...a la izquierda: tercera
	ret			;9660
ordenador_bateada_2:		; A segunda
	bit 1,l		;9661   ; segunda ocupada?
	jr z,ordenador_bateada_1		;9663
	bit 4,l		;9665
	jr nz,ordenador_bateada_1		;9667
	cp 007h		;9669   ; la direccion...
	jr nc,ordenador_bateada_1		;966b
	set 0,(ix+000h)		;966d   ; el boton y arriba: segunda
	set 4,(ix+000h)		;9671
	ret			;9675
ordenador_bateada_1:		; A primera
	bit 0,l		;9676   ; tercera?
	ret z			;9678
	bit 3,l		;9679
	ret nz			;967b
	cp 003h		;967c   ; la direccion
	jr c,ordenador_bateada_3		;967e
	cp 009h		;9680
	ret c			;9682
ordenador_bateada_3:		; Hacia primera
	set 3,(ix+000h)		;9683   ; el boton y a la derecha: primera
	set 4,(ix+000h)		;9687
	ret			;968b
ordenador_corre:		; Los corredores del ordenador
	bit 5,(hl)		;968c
	ret z			;968e
	push ix		;968f   ; IX...
	pop hl			;9691   ; ...en HL
	set 4,(hl)		;9692   ; el boton
	ld a,(0e055h)		;9694   ; el tiro...
	bit 5,a		;9697
	jr z,ordenador_corre_base		;9699
	bit 4,a		;969b
	jr z,ordenador_corre_vuelve		;969d
	ld a,(0e015h)		;969f
	cp 002h		;96a2
	jr nc,ordenador_derecha		;96a4
ordenador_corre_base:		; Hacia la base libre
	ld a,(0e01bh)		;96a6   ; las bases
	rra			;96a9   ; primera...
	rra			;96aa
	rra			;96ab
	jr c,ordenador_abajo		;96ac
	rla			;96ae   ; segunda...
	jr c,ordenador_izquierda		;96af
	rla			;96b1   ; tercera...
	jr c,ordenador_arriba		;96b2
	push hl			;96b4
	call alguno_corre		;96b5   ; alguno corre?
	pop hl			;96b8
	jr z,ordenador_derecha		;96b9
	res 4,(hl)		;96bb   ; sin boton
	ret			;96bd
ordenador_corre_vuelve:		; O vuelven
	ld a,(0e04dh)		;96be   ; como lo cogio...
	cpl			;96c1
	and 018h		;96c2
	jr z,ordenador_corre_base		;96c4
	ld a,(0e01bh)		;96c6   ; las bases
	and 007h		;96c9
	jr nz,ordenador_corre_base		;96cb
ordenador_arriba:		; Arriba
	set 0,(hl)		;96cd
	ret			;96cf
ordenador_derecha:		; A la derecha
	set 3,(hl)		;96d0
	ret			;96d2
ordenador_abajo:		; Abajo
	set 1,(hl)		;96d3
	ret			;96d5
ordenador_izquierda:		; A la izquierda
	set 2,(hl)		;96d6
	ret			;96d8
ordenador_fin_jugada:		; Al acabar la jugada
	bit 5,(hl)		;96d9
	ret z			;96db
	push ix		;96dc
	pop hl			;96de
	set 4,(hl)		;96df   ; el boton
	ld a,(0e01bh)		;96e1   ; las bases...
	rlca			;96e4   ; ...tercera?
	rlca			;96e5
	rlca			;96e6
	jr c,ordenador_izquierda		;96e7
	rlca			;96e9   ; segunda?
	jr c,ordenador_arriba		;96ea
	rlca			;96ec   ; primera?
	jr c,ordenador_derecha		;96ed
	ret			;96ef
lanzador:		; El lanzador (0xE008): se pone, se mueve de lado y lanza
	ld ix,0e008h		;96f0   ; IX = su estado
	ld a,(ix+000h)		;96f4   ; su estado...
	rlca			;96f7   ; ...bit 7: se pone
	jr c,lanzador_pone		;96f8
	rlca			;96fa   ; bit 6: se mueve
	jr c,lanzador_mueve		;96fb
	rlca			;96fd   ; bit 5: lanza
	jp c,lanzador_brazo		;96fe
	rlca			;9701   ; bit 4: espera
	ret c			;9702
	ld a,0c2h		;9703   ; sin lanzador: sus sprites fuera
	ld (0e1a0h),a		;9705   ; los sprites del lanzador, fuera
	ld (0e150h),a		;9708
	ret			;970b
lanzador_pone:		; En su sitio (X 0x78), con el color del equipo
	ld a,0c0h		;970c
	ld (0e24dh),a		;970e   ; el lanzador en casillas, a borrar: ahora es sprite
	ld hl,07802h		;9711   ; Y 0x02, X 0x78
	ld (0e1a0h),hl		;9714
	ld hl,(0e01eh)		;9717   ; el color del equipo...
	ld l,028h		;971a   ; ...dibujo 0x28
	ld (0e1a2h),hl		;971c
	res 7,(ix+000h)		;971f   ; ya puesto...
	set 6,(ix+000h)		;9723   ; ...se mueve
	jp lanzador_sprite		;9727
lanzador_mueve:		; Se mueve a los lados con el mando del que lanza, entre 0x74 y 0x7C; el boton lanza
	ld a,(0e006h)		;972a
	ld hl,(0e258h)		;972d   ; el mando del que lanza
	bit 4,l		;9730   ; el boton?
	jr nz,lanzador_lanza		;9732
	bit 5,l		;9734   ; el boton 2?
	jr nz,lanzador_robo		;9736
lanzador_lado:		; A un lado
	bit 5,a		;9738   ; lo mueve el ordenador?
	jr nz,lanzador_solo		;973a
	ld a,(0e1a1h)		;973c   ; la X
	bit 3,l		;973f   ; a la derecha?
	jr nz,lanzador_der		;9741
	bit 2,l		;9743   ; a la izquierda?
	jp z,lanzador_sprite		;9745
lanzador_izq:		; Un punto a la izquierda
	dec a			;9748
	cp 074h		;9749   ; hasta 0x74
	jr c,lanzador_vuelve		;974b
	jr lanzador_guarda		;974d
lanzador_der:		; Un punto a la derecha
	inc a			;974f
	cp 07ch		;9750   ; hasta 0x7C
	jr nc,lanzador_vuelve		;9752
lanzador_guarda:		; Guarda la X
	ld (0e1a1h),a		;9754   ; guardada
	jp lanzador_sprite		;9757
lanzador_vuelve:		; Al tope: cambia de lado
	rr (ix+000h)		;975a   ; el bit 0 del estado...
	ccf			;975e   ; ...al reves
	rl (ix+000h)		;975f
	jp lanzador_sprite		;9763
lanzador_solo:		; Solo (el ordenador): se mueve cada dos cuadros
	ld a,(0e0a0h)		;9766   ; la cuenta de cuadros...
	bit 0,a		;9769   ; ...cada dos
	jr z,$+99		;976b
	ld a,(0e1a1h)		;976d
	bit 0,(ix+000h)		;9770   ; hacia que lado
	jr nz,lanzador_izq		;9774
	jr lanzador_der		;9776
lanzador_lanza:		; El boton: el lanzamiento empieza
	xor a			;9778
	ld (0e0a5h),a		;9779   ; la cuenta a cero
	res 6,(ix+000h)		;977c   ; lanza
	set 5,(ix+000h)		;9780
	jr $+74		;9784
lanzador_robo:		; El mando hacia una base: un lanzamiento a esa base
	ld a,l			;9786   ; la direccion...
	and 00dh		;9787
	jr z,lanzador_lado		;9789   ; ...una base?
	or 080h		;978b   ; el tiro a esa base
	ld (0e043h),a		;978d
	ld hl,00000h		;9790   ; sin fase
	ld (0e001h),hl		;9793
	ld a,010h		;9796   ; el lanzador espera
	ld (0e008h),a		;9798
	ret			;979b
lanzador_brazo:		; El brazo: su dibujo (0x97C5) cuadro a cuadro, con su sonido
	ld a,(0e0a5h)		;979c   ; la cuenta...
	cp 020h		;979f   ; ...32?
	jr nz,L_97B0		;97a1
	ld b,001h		;97a3   ; el canal 1...
	ld de,0bf84h		;97a5   ; ...0xBF84
	call pieza		;97a8
	ld hl,0e009h		;97ab   ; la pelota sale
	ld (hl),080h		;97ae
L_97B0:
	ld hl,097c5h		;97b0   ; el brazo...
	call tabla4		;97b3   ; ...segun la cuenta
	cp 0ffh		;97b6   ; 0xFF: se acaba
	jr z,lanzador_suelta		;97b8
	ld (0e1a2h),a		;97ba   ; el dibujo
	jr $+17		;97bd
lanzador_suelta:		; La pelota sale
	ld (ix+000h),010h		;97bf   ; espera
	jr $+11		;97c3

; ----------------------------------------------------------------------
; DATOS lanzador_brazo_dibujos: El dibujo del brazo segun la cuenta: cuatro
;   tramos y sus dibujos
;   0x97c5..0x97ce  (9 bytes)
DATA_lanzador_brazo_dibujos:
	defb 010h,020h,030h,040h,028h,02ch,030h,0ffh,0ffh	; 97c5  . 0@(,0..

; ======================================================================
; CODIGO 0x97ce..0x9901  (307 bytes)
; ======================================================================


lanzador_sprite:		; El sprite del lanzador en el campo (0xE150)
	push hl			;97ce
	ld hl,(0e1a0h)		;97cf   ; Y y X del lanzador...
	ld l,083h		;97d2   ; ...dibujo 0x83...
	ld (0e150h),hl		;97d4   ; ...en 0xE150
	ld hl,(0e1a2h)		;97d7   ; el resto
	ld (0e152h),hl		;97da
	pop hl			;97dd
	ret			;97de
pelota_lanzada:		; La pelota lanzada (0xE009): sale, vuela hacia el bateador con su efecto
	ld a,(0e009h)		;97df
	rlca			;97e2   ; bit 7: sale
	jr c,pelota_sale		;97e3
	rlca			;97e5   ; bit 6: vuela
	jr c,pelota_vuela		;97e6
	ld hl,0e1a8h		;97e8   ; la pelota de la ventana, fuera
	ld (hl),0c2h		;97eb
	rlca			;97ed
	ret c			;97ee
	ld a,0c2h		;97ef   ; y la del campo
	ld (0e1a4h),a		;97f1
	ld (0e1ech),a		;97f4
	ret			;97f7
pelota_sale:		; Sale: su sprite en la mano, su velocidad y su altura
	ld hl,07883h		;97f8   ; la pelota de la ventana: Y 0x83, X 0x78...
	ld (0e1a8h),hl		;97fb
	ld hl,00f3dh		;97fe   ; ...dibujo 0x3D, color 0x0F
	ld (0e1aah),hl		;9801
	ld hl,08300h		;9804   ; la distancia: 0x8300
	ld (0e044h),hl		;9807
	xor a			;980a   ; la cuenta del efecto a cero
	ld (0e090h),a		;980b
	ld a,(0e1a1h)		;980e   ; la X del lanzador...
	sub 078h		;9811   ; ...menos la del centro...
	add a,a			;9813   ; ...por 8: la X de salida
	add a,a			;9814
	add a,a			;9815
	ld (0e091h),a		;9816
	ld hl,0e092h		;9819   ; la altura: 0x6E
	ld (hl),06eh		;981c
	ld hl,00000h		;981e   ; las dos pelotas del campo, a cero
	ld (0e1a4h),hl		;9821
	ld (0e1ech),hl		;9824
	ld hl,00f34h		;9827   ; dibujo 0x34, color 0x0F
	ld (0e1a6h),hl		;982a
	ld h,001h		;982d   ; (y la sombra)
	ld (0e1eeh),hl		;982f
	ld hl,0e00ah		;9832   ; ya ha salido
	set 0,(hl)		;9835
	ld hl,0e009h		;9837   ; vuela
	ld (hl),041h		;983a
	ret			;983c
pelota_vuela:		; Vuela: la distancia (0xE044) y, con ella, la Y, la X y la altura
	ld hl,(0e044h)		;983d   ; la distancia...
	ld de,0005ah		;9840   ; ...0x5A mas...
	add hl,de			;9843
	ld a,h			;9844   ; ...su parte alta, la Y en la ventana
	ld (0e1a8h),a		;9845
	cp 0adh		;9848   ; llega?
	jp nc,pelota_llega		;984a
	ld (0e044h),hl		;984d   ; guardada
	ld bc,(0e090h)		;9850   ; la X y el efecto
	ld a,b			;9854
	ld b,000h		;9855
	bit 7,a		;9857   ; hacia la izquierda?
	jr z,pelota_x		;9859
	ld b,0ffh		;985b
	neg		;985d
pelota_x:		; La X
	ld h,a			;985f
	ld a,c			;9860
	srl a		;9861   ; la mitad de la Y...
	add a,035h		;9863   ; ...mas 0x35
	ld l,a			;9865
	call multiplica		;9866   ; por la X...
	ld e,0d4h		;9869   ; ...entre 0xD4
	call divide		;986b
	ld a,h			;986e
	bit 0,b		;986f   ; hacia la izquierda?
	jr z,pelota_x_pon		;9871
	neg		;9873
pelota_x_pon:		; Guardada
	add a,078h		;9875   ; mas el centro
	ld (0e1a5h),a		;9877   ; la X en el campo...
	ld (0e1edh),a		;987a   ; ...y la de la sombra
	ld a,c			;987d   ; la mitad de la Y...
	srl a		;987e
	add a,00ah		;9880   ; ...mas 10: la de la sombra
	ld hl,0e1ech		;9882
	ld (hl),a			;9885
	ld b,a			;9886
	cp 032h		;9887   ; por debajo de 0x32...
	jr c,pelota_y		;9889
	ld (hl),0c2h		;988b   ; ...si no, fuera
pelota_y:		; La Y en la ventana y en el campo
	ld hl,(0e092h)		;988d   ; la altura...
	ld a,c			;9890
	add a,021h		;9891   ; ...con la Y...
	ld h,a			;9893
	call multiplica		;9894   ; ...multiplicada...
	srl h		;9897   ; ...la mitad
	ld a,b			;9899   ; la Y menos la altura
	sub h			;989a
	cp 032h		;989b   ; por debajo de 0x32...
	jr c,pelota_y_pon		;989d
	ld a,0c2h		;989f   ; ...si no, fuera
pelota_y_pon:		; Guardada
	ld (0e1a4h),a		;98a1   ; la Y de la pelota
	ld a,(0e0a0h)		;98a4   ; cada cuatro cuadros...
	and 003h		;98a7
	jr nz,pelota_tamano		;98a9
	ld hl,09901h		;98ab   ; la velocidad (0x9901)...
	ld a,(0e090h)		;98ae
	call tabla6		;98b1
	ld hl,0e090h		;98b4   ; ...se suma
	ld b,(hl)			;98b7
	add a,b			;98b8
	ld (hl),a			;98b9
pelota_tamano:		; El tamano segun la distancia (0x990E)
	ld a,(0e090h)		;98ba   ; el dibujo segun la distancia (0x990E)
	ld hl,0990eh		;98bd
	call tabla4		;98c0
	ld (0e1a6h),a		;98c3   ; el de la pelota...
	ld (0e1eeh),a		;98c6   ; ...y el de la sombra
	ld a,(0e090h)		;98c9   ; la distancia...
	cp 023h		;98cc   ; ...antes de 0x23 no hay efecto
	ret c			;98ce
	ld a,(0e0a0h)		;98cf   ; cada dos cuadros
	bit 0,a		;98d2
	ret nz			;98d4
	ld a,(0e258h)		;98d5   ; el mando del que lanza
	ld hl,0e092h		;98d8
	bit 0,a		;98db   ; arriba?
	jr nz,pelota_efecto_arriba		;98dd
	bit 1,a		;98df   ; abajo?
	jr z,pelota_efecto_x		;98e1
	dec (hl)			;98e3   ; dos menos
	dec (hl)			;98e4
	jr pelota_efecto_x		;98e5
pelota_efecto_arriba:		; El efecto, con el mando del que lanza: arriba, un punto mas...
	inc (hl)			;98e7
pelota_efecto_x:		; ...y a la izquierda o a la derecha
	ld hl,0e091h		;98e8
	bit 2,a		;98eb   ; a la izquierda?
	jr nz,pelota_efecto_izq		;98ed
	bit 3,a		;98ef   ; a la derecha?
	ret z			;98f1
	inc (hl)			;98f2   ; un punto a la derecha
	ret			;98f3
pelota_efecto_izq:		; Un punto a la izquierda
	dec (hl)			;98f4
	ret			;98f5
pelota_llega:		; Ha llegado: fin del vuelo
	ld hl,0e009h		;98f6   ; la pelota...
	ld (hl),000h		;98f9   ; ...se acaba
	ld hl,0e00dh		;98fb   ; y 0xE00D...
	ld (hl),0ffh		;98fe   ; ...0xFF
	ret			;9900

; ----------------------------------------------------------------------
; DATOS pelota_tablas: La velocidad (0x9901) y el dibujo (0x990E) de la pelota
;   segun la distancia
;   0x9901..0x9917  (22 bytes)
DATA_pelota_tablas:
	defb 014h,030h,03ch,046h,050h,05ah,002h,003h,004h,005h,009h,00ch,00fh,014h,028h,03ch	; 9901  .0<FPZ........(<
	defb 050h,034h,038h,03ch,040h,044h	; 9911

; ======================================================================
; CODIGO 0x9917..0x9aec  (469 bytes)
; ======================================================================


tiro_base:		; El lanzamiento a una base (0xE043): la pelota sale, vuela hasta la base y vuelve al lanzador
	ld a,(0e043h)		;9917   ; el tiro a una base...
	rlca			;991a   ; ...bit 7: en marcha
	ret nc			;991b
	rlca			;991c   ; bit 6: vuela a la base
	jr c,tiro_base_vuela		;991d
	rlca			;991f   ; bit 5: espera
	jp c,tiro_base_espera		;9920
	rlca			;9923   ; bit 4: vuelve
	jp c,tiro_base_lanzador		;9924
	ld b,001h		;9927   ; el canal 1...
	ld de,0bf84h		;9929   ; ...0xBF84
	call pieza		;992c
	xor a			;992f   ; sin efecto
	ld (0e010h),a		;9930
	call corredores_marcha		;9933   ; los corredores en marcha
	ld a,010h		;9936   ; el campo, quieto
	ld (0e04ch),a		;9938
	ld a,(0e043h)		;993b   ; la base...
	ld bc,0a002h		;993e   ; a tercera: dibujo 0xA0...
	ld hl,0cf85h		;9941   ; ...destino Y 0x85, X 0xCF
	bit 3,a		;9944   ; tercera?
	jr nz,tiro_base_pon		;9946
	ld bc,0a003h		;9948   ; a segunda...
	ld hl,0716ah		;994b   ; ...destino Y 0x6A, X 0x71
	bit 0,a		;994e   ; segunda?
	jr nz,tiro_base_pon		;9950
	ld bc,02004h		;9952   ; a primera...
	ld hl,02285h		;9955   ; ...destino Y 0x85, X 0x22
tiro_base_pon:		; La base de destino
	ld (0e164h),hl		;9958   ; el destino
	ld hl,(0e01eh)		;995b   ; el color del equipo...
	ld l,024h		;995e   ; ...dibujo 0x24
	ld (0e166h),hl		;9960
	ld a,b			;9963   ; el dibujo del lanzador
	ld (0e152h),a		;9964
	ld hl,00000h		;9967   ; el camino a cero
	ld (0e044h),hl		;996a
	ld a,c			;996d   ; el jugador de esa base, en casillas
	ld (0e046h),a		;996e
	ld b,001h		;9971   ; ocupada
	call jugador_marca		;9973
	ld hl,07883h		;9976   ; la pelota en el lanzador...
	ld (0e1a4h),hl		;9979
	ld hl,00f3ch		;997c   ; ...dibujo 0x3C, color 0x0F
	ld (0e1a6h),hl		;997f
	ld hl,0e043h		;9982   ; el paso: vuela
	ld a,(hl)			;9985
	and 00fh		;9986
	or 0c0h		;9988
	ld (hl),a			;998a
	ret			;998b
tiro_base_vuela:		; Vuela hasta la base (0xA7DF)
	ld hl,(0e1a4h)		;998c   ; donde esta la pelota
	ld (0e087h),hl		;998f
	ld hl,(0e150h)		;9992   ; el lanzador...
	ld b,006h		;9995   ; ...seis puntos mas a la derecha: de donde sale
L_9997:
	inc l			;9997
	djnz L_9997		;9998
	ld (0e085h),hl		;999a
	ld hl,(0e164h)		;999d   ; el destino
	ld (0e083h),hl		;99a0
	ld hl,(0e044h)		;99a3   ; el camino
	ld (0e089h),hl		;99a6
	ld a,060h		;99a9   ; velocidad 0x60
	ld (0e08bh),a		;99ab
	call hacia		;99ae   ; un paso
	ld hl,(0e087h)		;99b1   ; guardado
	ld (0e1a4h),hl		;99b4
	ld hl,(0e089h)		;99b7
	ld (0e044h),hl		;99ba
	ld a,(0e08bh)		;99bd   ; ha llegado?
	or a			;99c0
	ret nz			;99c1
	ld b,001h		;99c2   ; el canal 1...
	ld de,0bfeeh		;99c4   ; ...0xBFEE
	call pieza		;99c7
	ld b,002h		;99ca   ; el canal 2...
	ld de,0bfa2h		;99cc   ; ...0xBFA2
	call pieza		;99cf
	ld a,(0e043h)		;99d2   ; la base...
	ld bc,00901h		;99d5   ; tercera: el bit de corredor 0x09...
	bit 3,a		;99d8
	jr nz,tiro_base_llega		;99da
	ld bc,01202h		;99dc   ; segunda: 0x12...
	bit 0,a		;99df
	jr nz,tiro_base_llega		;99e1
	ld bc,02403h		;99e3   ; primera: 0x24
tiro_base_llega:		; Llega: si el corredor no estaba en su base, out
	ld a,(0e01bh)		;99e6   ; el corredor estaba en la base?
	cpl			;99e9
	and b			;99ea
	jr nz,tiro_base_vuelve		;99eb
	ld hl,0e01eh		;99ed   ; si no: la jugada...
	ld (hl),080h		;99f0
	call corredor_base		;99f2   ; ...el corredor de esa base...
	ld a,(hl)			;99f5   ; ...sale corriendo
	and 003h		;99f6
	or 0e0h		;99f8
	ld (hl),a			;99fa
tiro_base_vuelve:		; La pelota vuelve
	ld hl,00000h		;99fb
	ld (0e044h),hl		;99fe   ; el camino a cero
	xor a			;9a01
	ld (0e0a9h),a		;9a02   ; la cuenta a cero
	ld hl,0e043h		;9a05
	ld a,(hl)			;9a08
	and 00fh		;9a09
	or 0a0h		;9a0b   ; el paso: espera
	ld (hl),a			;9a0d
	ret			;9a0e
tiro_base_espera:		; Espera 48 cuadros
	ld a,(0e0a9h)		;9a0f   ; la cuenta...
	cp 030h		;9a12   ; ...48?
	ret c			;9a14
	ld b,001h		;9a15   ; el canal 1...
	ld de,0bf84h		;9a17   ; ...0xBF84
	call pieza		;9a1a
	ld hl,0e043h		;9a1d
	ld a,(hl)			;9a20
	and 00fh		;9a21
	or 090h		;9a23   ; el paso: vuelve
	ld (hl),a			;9a25
	ret			;9a26
tiro_base_lanzador:		; Vuelve al lanzador
	ld hl,(0e1a4h)		;9a27   ; donde esta la pelota
	ld (0e087h),hl		;9a2a
	ld hl,(0e164h)		;9a2d   ; desde la base...
	ld (0e085h),hl		;9a30
	ld hl,(0e150h)		;9a33   ; ...al lanzador
	ld (0e083h),hl		;9a36
	ld hl,(0e044h)		;9a39   ; el camino
	ld (0e089h),hl		;9a3c
	ld a,060h		;9a3f   ; velocidad 0x60
	ld (0e08bh),a		;9a41
	call hacia		;9a44   ; un paso
	ld hl,(0e089h)		;9a47   ; guardado
	ld (0e044h),hl		;9a4a
	ld hl,(0e087h)		;9a4d
	ld (0e1a4h),hl		;9a50
	ld a,(0e08bh)		;9a53   ; ha llegado?
	or a			;9a56
	ret nz			;9a57
	ld b,001h		;9a58   ; el canal 1...
	ld de,0bfeeh		;9a5a   ; ...0xBFEE
	call pieza		;9a5d
	ld b,002h		;9a60   ; el canal 2...
	ld de,0bfa2h		;9a62   ; ...0xBFA2
	call pieza		;9a65
	ld a,0c2h		;9a68   ; el sprite del lanzador, fuera
	ld (0e150h),a		;9a6a
	xor a			;9a6d   ; el tiro...
	ld (0e043h),a		;9a6e
	ld (0e04ch),a		;9a71   ; ...y el campo, a cero
	ld bc,(0e046h)		;9a74   ; el jugador de la base...
	ld b,000h		;9a78   ; ...vacia
	call jugador_marca		;9a7a
	ld hl,08040h		;9a7d   ; el lanzador otra vez
	ld (0e001h),hl		;9a80
	ret			;9a83
bateador:		; El bateador (0xE00A): se pone, se mueve y batea
	ld ix,0e1ach		;9a84
	ld a,(0e00ah)		;9a88   ; su estado...
	rlca			;9a8b   ; ...bit 7: se pone
	jr c,bateador_pone		;9a8c
	rlca			;9a8e   ; bit 6: en marcha
	jp c,bateador_swing		;9a8f
	ld a,0c2h		;9a92   ; los seis sprites (24 bytes)...
	ld hl,0e1ach		;9a94
	ld b,018h		;9a97
bateador_fuera:		; Sin bateador: sus sprites fuera
	ld (hl),a			;9a99   ; ...a 0xC2
	inc hl			;9a9a
	djnz bateador_fuera		;9a9b
	ret			;9a9d
bateador_pone:		; Se pone: sus dibujos (diestro o zurdo, girados) y sus sprites (0x9AEC o 0x9B04)
	ld de,03d80h		;9a9e   ; a 0x3D80...
	ld hl,09b1ch		;9aa1   ; ...los dibujos de 0x9B1C...
	ld bc,00280h		;9aa4   ; ...0x280 bytes
	ld a,(0e006h)		;9aa7   ; zurdo?
	bit 4,a		;9aaa
	jr nz,bateador_zurdo		;9aac
	call 0005ch		;9aae   ; LDIRVM
	jr bateador_sprites		;9ab1
bateador_zurdo:		; El zurdo: los dibujos girados
	ld a,014h		;9ab3   ; 20 bloques...
	ld hl,09b2ch		;9ab5   ; ...girados desde 0x9B2C
	call gira_bloque		;9ab8
bateador_sprites:		; Sus sprites, con el color del equipo
	xor a			;9abb
	ld (0e016h),a		;9abc   ; el swing a cero
	ld hl,09aech		;9abf   ; los sprites del diestro...
	ld de,0e1ach		;9ac2
	ld bc,00018h		;9ac5   ; ...24 bytes
	ld a,(0e006h)		;9ac8   ; zurdo?
	bit 4,a		;9acb
	jr z,bateador_copia		;9acd
	ld hl,09b04h		;9acf   ; los del zurdo
bateador_copia:		; Copiados
	ldir		;9ad2
	ld ix,0e1ach		;9ad4
	ld a,(0e020h)		;9ad8   ; el color del equipo...
	ld (ix+007h),a		;9adb   ; ...en tres sprites
	ld (ix+00bh),a		;9ade
	ld (ix+017h),a		;9ae1
	ld hl,0e00ah		;9ae4
	res 7,(hl)		;9ae7   ; ya puesto...
	set 6,(hl)		;9ae9   ; ...en marcha
	ret			;9aeb

; ----------------------------------------------------------------------
; DATOS bateador_sprites_tabla: Los seis sprites del bateador, diestro
;   (0x9AEC) y zurdo (0x9B04)
;   0x9aec..0x9b1c  (48 bytes)
DATA_bateador_sprites_tabla:
	defb 011h,068h,0e8h,00bh	; 9aec
	defb 017h,068h,0c8h,000h	; 9af0
	defb 027h,068h,0cch,000h	; 9af4
	defb 01ah,078h,048h,001h	; 9af8
	defb 0a0h,070h,0b4h,00bh	; 9afc
	defb 0a0h,070h,0b0h,000h	; 9b00
	defb 011h,088h,0e8h,00bh	; 9b04
	defb 017h,088h,0c8h,000h	; 9b08
	defb 027h,088h,0cch,000h	; 9b0c
	defb 01ah,078h,048h,001h	; 9b10
	defb 0a0h,080h,0b4h,00bh	; 9b14
	defb 0a0h,080h,0b0h,000h	; 9b18

; ----------------------------------------------------------------------
; DATOS bateador_dibujos: Los dibujos del bateador (0x280 bytes a 0x3D80;
;   desde 0x9B2C, girados para el zurdo)
;   0x9b1c..0x9d9c  (640 bytes)
DATA_bateador_dibujos:
	defb 000h,000h,000h,000h,001h,003h,003h,001h	; 9b1c  ........
	defb 001h,001h,001h,001h,003h,002h,002h,003h	; 9b24  ........
	defb 000h,000h,0c0h,0e0h,0c0h,0e0h,0e0h,0e0h	; 9b2c  ........
	defb 0c0h,0e0h,0e0h,0e0h,040h,040h,060h,000h	; 9b34  ....@@`.
	defb 002h,002h,002h,002h,002h,000h,000h,000h	; 9b3c  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9b44  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9b4c  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9b54  ........
	defb 000h,001h,001h,00fh,013h,00fh,007h,001h	; 9b5c  ........
	defb 003h,003h,002h,003h,001h,003h,000h,000h	; 9b64  ........
	defb 000h,080h,080h,0e0h,0e0h,0e0h,0c0h,080h	; 9b6c  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,080h,080h,0c0h	; 9b74  ........
	defb 000h,0c0h,060h,030h,00ch,000h,000h,000h	; 9b7c  ..`0....
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9b84  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9b8c  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9b94  ........
	defb 000h,001h,001h,00fh,013h,00fh,007h,001h	; 9b9c  ........
	defb 003h,003h,002h,003h,001h,003h,000h,000h	; 9ba4  ........
	defb 000h,080h,080h,0e0h,0e0h,0e0h,0c0h,080h	; 9bac  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,080h,080h,0c0h	; 9bb4  ........
	defb 000h,0c0h,060h,030h,00ch,000h,000h,000h	; 9bbc  ..`0....
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9bc4  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9bcc  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9bd4  ........
	defb 001h,003h,003h,003h,007h,00fh,03fh,03fh	; 9bdc  ......??
	defb 01fh,01fh,01fh,01fh,00fh,00fh,01fh,01fh	; 9be4  ........
	defb 080h,0c0h,0e0h,0c0h,0c0h,080h,0c0h,0e0h	; 9bec  ........
	defb 0e0h,0e0h,0c0h,0c0h,000h,080h,0c0h,0c0h	; 9bf4  ........
	defb 01fh,01fh,01fh,00eh,00eh,00eh,00eh,00eh	; 9bfc  ........
	defb 01eh,01ch,018h,018h,018h,03ch,03eh,007h	; 9c04  .....<>.
	defb 0e0h,0e0h,0e0h,0e0h,0e0h,0c0h,0c0h,080h	; 9c0c  ........
	defb 0c0h,0e0h,070h,000h,000h,000h,000h,000h	; 9c14  ..p.....
	defb 001h,003h,003h,003h,007h,00fh,01fh,00fh	; 9c1c  ........
	defb 033h,03fh,01fh,01fh,00fh,007h,00fh,00fh	; 9c24  3?......
	defb 080h,0c0h,0e0h,0c0h,0c0h,080h,0e0h,0f0h	; 9c2c  ........
	defb 0f0h,0f0h,0e0h,0e0h,0c0h,080h,0c0h,0c0h	; 9c34  ........
	defb 00fh,00fh,00fh,007h,007h,007h,007h,00fh	; 9c3c  ........
	defb 00eh,01ch,01ch,038h,038h,018h,008h,00ch	; 9c44  ...88...
	defb 0e0h,0e0h,0e0h,060h,060h,060h,060h,040h	; 9c4c  ...````@
	defb 060h,070h,038h,000h,000h,000h,000h,000h	; 9c54  `p8.....
	defb 001h,003h,003h,003h,003h,007h,00fh,00fh	; 9c5c  ........
	defb 00fh,00fh,00fh,007h,003h,001h,003h,003h	; 9c64  ........
	defb 080h,0c0h,0e0h,0c0h,0c0h,080h,0e0h,0f8h	; 9c6c  ........
	defb 0feh,0efh,0ffh,0fch,0c0h,0c0h,0f0h,0f0h	; 9c74  ........
	defb 003h,003h,003h,001h,001h,000h,000h,000h	; 9c7c  ........
	defb 001h,001h,003h,003h,007h,007h,003h,001h	; 9c84  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f8h,0f8h,0f8h,0f8h	; 9c8c  ........
	defb 0dch,0dch,098h,000h,000h,000h,000h,080h	; 9c94  ........
	defb 001h,003h,003h,003h,00fh,07fh,0ffh,0efh	; 9c9c  ........
	defb 07fh,03fh,01fh,00fh,007h,00fh,00fh,00fh	; 9ca4  .?......
	defb 080h,0c0h,0c0h,0c0h,0e0h,0f0h,0f0h,0f0h	; 9cac  ........
	defb 0f0h,0f0h,0f0h,0e0h,0c0h,0e0h,0e0h,0e0h	; 9cb4  ........
	defb 00fh,00fh,00dh,005h,005h,007h,007h,007h	; 9cbc  ........
	defb 007h,00fh,007h,003h,003h,003h,001h,000h	; 9cc4  ........
	defb 0e0h,0e0h,0e0h,0e0h,0c0h,0c0h,0c0h,080h	; 9ccc  ........
	defb 080h,080h,000h,000h,000h,080h,080h,0c0h	; 9cd4  ........
	defb 030h,030h,030h,030h,030h,030h,030h,030h	; 9cdc  00000000
	defb 030h,030h,030h,030h,000h,000h,000h,000h	; 9ce4  0000....
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9cec  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9cf4  ........
	defb 0c0h,0e0h,070h,038h,01ch,00eh,000h,000h	; 9cfc  ..p8....
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9d04  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9d0c  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9d14  ........
	defb 000h,000h,0f0h,0ffh,01fh,001h,000h,000h	; 9d1c  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9d24  ........
	defb 000h,000h,000h,000h,0e0h,0e0h,000h,000h	; 9d2c  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9d34  ........
	defb 000h,000h,0ffh,0ffh,000h,000h,000h,000h	; 9d3c  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9d44  ........
	defb 000h,000h,0f0h,0f0h,000h,000h,000h,000h	; 9d4c  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9d54  ........
	defb 001h,01fh,0ffh,0f0h,000h,000h,000h,000h	; 9d5c  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9d64  ........
	defb 0e0h,0e0h,000h,000h,000h,000h,000h,000h	; 9d6c  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9d74  ........
	defb 0e0h,0f8h,03eh,00fh,003h,000h,000h,000h	; 9d7c  ..>.....
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9d84  ........
	defb 000h,000h,000h,080h,0e0h,0f0h,000h,000h	; 9d8c  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 9d94  ........

; ======================================================================
; CODIGO 0x9d9c..0x9e60  (196 bytes)
; ======================================================================


bateador_swing:		; El swing: el boton empieza; los dibujos cuadro a cuadro (0x9E60, 0x9E69, 0x9E76)
	ld a,(0e256h)		;9d9c
	ld d,a			;9d9f   ; D, el mando
	ld hl,0e00ah		;9da0   ; la pelota ya sale?
	bit 0,(hl)		;9da3
	jr z,bateador_mueve		;9da5
	and 010h		;9da7   ; el boton?
	jr z,bateador_mueve		;9da9
	ld a,(0e016h)		;9dab   ; el cuadro del swing...
	inc a			;9dae   ; ...uno mas, hasta 255
	jr z,bateador_mueve		;9daf
	ld (0e016h),a		;9db1
	ld hl,09e60h		;9db4   ; la Y del bate (0x9E60)...
	call tabla4		;9db7
	ld (ix+006h),a		;9dba   ; ...en dos sprites
	add a,004h		;9dbd
	ld (ix+00ah),a		;9dbf
	ld a,(0e016h)		;9dc2   ; la de las piernas (0x9E76)...
	ld hl,09e76h		;9dc5
	call tabla4		;9dc8
	ld (ix+016h),a		;9dcb   ; ...en otros dos
	add a,004h		;9dce
	ld (ix+012h),a		;9dd0
	ld a,(0e016h)		;9dd3   ; el cuadro 5?
	cp 005h		;9dd6
	jr z,bateador_swing_5		;9dd8
	cp 00ah		;9dda   ; el 10?
	jr z,bateador_swing_10		;9ddc
	cp 016h		;9dde   ; el 22?
	jr nz,bateador_swing_dibujo		;9de0
	ld bc,0e6fch		;9de2   ; el paso de los sprites
bateador_swing_mueve:		; Corre los sprites (al reves para el zurdo)
	ld hl,0e006h		;9de5
	bit 4,(hl)		;9de8   ; zurdo?
	jr z,bateador_swing_pon		;9dea
	ld a,b			;9dec   ; al reves
	neg		;9ded
	ld b,a			;9def
bateador_swing_pon:		; Los suma
	ld a,(ix+000h)		;9df0   ; la Y...
	add a,c			;9df3
	ld (ix+000h),a		;9df4
	ld a,(ix+001h)		;9df7   ; ...y la X
	add a,b			;9dfa
	ld (ix+001h),a		;9dfb
bateador_swing_dibujo:		; El dibujo del bate
	ld a,(0e016h)		;9dfe   ; el dibujo del bate (0x9E69)...
	ld hl,09e69h		;9e01
	call tabla6		;9e04
	ld (ix+002h),a		;9e07   ; ...guardado
bateador_mueve:		; Se mueve hacia delante o hacia atras en la caja
	ld a,d			;9e0a   ; el mando
	push af			;9e0b
	and 00ch		;9e0c   ; adelante o atras?
	jr z,bateador_altura		;9e0e
	ld bc,0586eh		;9e10   ; los topes del diestro...
	ld hl,0e006h		;9e13
	bit 4,(hl)		;9e16
	jr z,bateador_mueve_x		;9e18
	ld bc,08198h		;9e1a   ; ...o del zurdo
bateador_mueve_x:		; La X
	ld a,(ix+005h)		;9e1d   ; la X del bateador
	bit 2,d		;9e20   ; a la izquierda?
	ld hl,0e1adh		;9e22   ; los cuatro sprites
	ld de,00004h		;9e25
	jr z,bateador_delante		;9e28
	cp b			;9e2a   ; al tope?
	jr c,bateador_altura		;9e2b
	ld b,004h		;9e2d   ; cuatro sprites...
bateador_atras:		; Atras
	dec (hl)			;9e2f   ; ...un punto
	add hl,de			;9e30
	djnz bateador_atras		;9e31
	jr bateador_altura		;9e33
bateador_delante:		; Delante
	cp c			;9e35   ; al tope?
	jr nc,bateador_altura		;9e36
	ld b,004h		;9e38   ; cuatro sprites...
bateador_delante_uno:		; Uno
	inc (hl)			;9e3a   ; ...un punto
	add hl,de			;9e3b
	djnz bateador_delante_uno		;9e3c
	jr bateador_altura		;9e3e
bateador_swing_5:		; El cuadro 5 del swing
	ld bc,0fd08h		;9e40   ; el paso del cuadro 5
	jr bateador_swing_mueve		;9e43
bateador_swing_10:		; El cuadro 10
	ld bc,01302h		;9e45   ; el del cuadro 10
	jr bateador_swing_mueve		;9e48
bateador_altura:		; La altura del bate: arriba o abajo
	pop af			;9e4a
	and 003h		;9e4b   ; arriba o abajo?
	ret z			;9e4d
	ld hl,0e1b8h		;9e4e   ; la Y del bate
	cp 001h		;9e51   ; arriba (1)?
	ld a,(hl)			;9e53
	jr z,bateador_baja		;9e54
	cp 027h		;9e56   ; hasta 0x27
	ret nc			;9e58
	inc (hl)			;9e59   ; un punto
	ret			;9e5a
bateador_baja:		; Baja
	cp 010h		;9e5b   ; hasta 0x10
	ret c			;9e5d
	dec (hl)			;9e5e   ; un punto
	ret			;9e5f

; ----------------------------------------------------------------------
; DATOS swing_tablas: Los cuadros del swing (0x9E60), los dibujos del bate
;   (0x9E69) y los de las piernas (0x9E76)
;   0x9e60..0x9e7f  (31 bytes)
DATA_swing_tablas:
	defb 005h,00ah,016h,01bh,0c8h,0d0h,0d8h,0e0h,0e0h,005h,00ah,00eh,012h,016h,01bh,0e8h	; 9e60  ................
	defb 0ech,0f0h,0f4h,0f8h,0fch,0fch,005h,00ah,016h,01bh,0b0h,0b0h,0b8h,0c0h,0c0h	; 9e70  ...............

; ======================================================================
; CODIGO 0x9e7f..0xa011  (402 bytes)
; ======================================================================


gira_bloque:		; A veces: copia sprites girados (0xA8B6) de 16 en 16
	ld bc,00010h		;9e7f
	call vram_girada		;9e82   ; 16 bytes girados
	ld bc,00020h		;9e85   ; la otra mitad del sprite...
	push bc			;9e88
	or a			;9e89   ; ...16 atras
	sbc hl,bc		;9e8a
	ld bc,00010h		;9e8c
	call vram_girada		;9e8f   ; 16 bytes girados
	pop bc			;9e92
	add hl,bc			;9e93   ; 32 adelante
	dec a			;9e94   ; A bloques
	jr nz,gira_bloque		;9e95
	ret			;9e97
bateada:		; La pelota bateada (0xE00B): su vuelo, los botes y donde cae
	ld a,(0e00bh)		;9e98
	rlca			;9e9b   ; bit 7: empieza
	jr c,bateada_empieza		;9e9c
	rlca			;9e9e   ; bit 6: vuela
	jr c,bateada_vuela		;9e9f
	ret			;9ea1
bateada_empieza:		; Empieza: la posicion, la velocidad y el sprite
	ld hl,00000h		;9ea2   ; la distancia...
	ld (0e098h),hl		;9ea5
	ld hl,0000ah		;9ea8   ; ...y la altura a 10
	ld (0e09ah),hl		;9eab
	ld hl,(0e093h)		;9eae   ; la velocidad del golpe
	ld (0e095h),hl		;9eb1
	ld a,020h		;9eb4   ; 0xE009
	ld (0e009h),a		;9eb6
	ld hl,078a4h		;9eb9   ; la pelota y su sombra: Y 0xA4, X 0x78...
	ld (0e1a4h),hl		;9ebc
	ld (0e1ech),hl		;9ebf
	ld hl,00f3ch		;9ec2   ; ...dibujo 0x3C, color 0x0F
	ld (0e1a6h),hl		;9ec5
	ld hl,0013ch		;9ec8   ; la sombra: dibujo 0x3C, color 1
	ld (0e1eeh),hl		;9ecb
	ld hl,0e00bh		;9ece   ; vuela
	ld (hl),040h		;9ed1
	ret			;9ed3
bateada_vuela:		; Cada cuatro cuadros: la distancia y la altura con la gravedad
	ld a,(0e0a0h)		;9ed4   ; cada cuatro cuadros
	and 003h		;9ed7
	ret nz			;9ed9
	ld hl,(0e098h)		;9eda   ; la distancia...
	ld de,(0e095h)		;9edd   ; ...mas la velocidad...
	ld d,000h		;9ee1
	bit 7,e		;9ee3   ; ...con signo...
	jr z,bateada_vuela_d		;9ee5
	ld d,0ffh		;9ee7
bateada_vuela_d:		; La distancia
	ld b,010h		;9ee9   ; ...por 16
bateada_vuela_d1:		; Un paso
	add hl,de			;9eeb
	djnz bateada_vuela_d1		;9eec
	ld (0e098h),hl		;9eee   ; guardada
	ld hl,(0e09ah)		;9ef1   ; la altura...
	ld de,(0e096h)		;9ef4   ; ...mas la velocidad hacia arriba...
	ld d,000h		;9ef8
	bit 7,e		;9efa   ; ...con signo...
	jr z,bateada_vuela_h		;9efc
	ld d,0ffh		;9efe
bateada_vuela_h:		; La altura
	ld b,00fh		;9f00   ; ...por 16
bateada_vuela_h1:		; Un paso
	adc hl,de		;9f02
	djnz bateada_vuela_h1		;9f04
	adc hl,de		;9f06
	jp m,bateada_bota		;9f08   ; por debajo del suelo...
	jr nz,bateada_altura		;9f0b   ; ...o en el
bateada_bota:		; Toca el suelo: un bote, con su sonido, y pierde velocidad
	ld b,001h		;9f0d   ; el canal 1...
	ld de,0bf98h		;9f0f   ; ...0xBF98
	call pieza		;9f12
	ld b,000h		;9f15   ; el canal 0...
	ld de,0bfeeh		;9f17   ; ...0xBFEE
	call pieza		;9f1a
	ld hl,0e00bh		;9f1d   ; ya ha botado
	set 1,(hl)		;9f20
	inc hl			;9f22
	ld (hl),000h		;9f23   ; 0xE00C a cero
	ld a,(0e096h)		;9f25   ; la velocidad hacia arriba...
	neg		;9f28   ; ...al reves...
	ld h,a			;9f2a
	ld l,08ch		;9f2b   ; ...por 0x8C / 256...
	call multiplica		;9f2d
	ld a,h			;9f30
	add a,004h		;9f31   ; ...mas 4
	ld (0e096h),a		;9f33
	ld a,(0e00bh)		;9f36   ; fuera del campo?
	bit 0,a		;9f39
	jp nz,bateada_para		;9f3b
	ld a,(0e095h)		;9f3e   ; la velocidad...
	ld b,000h		;9f41
	or a			;9f43   ; negativa?
	jp p,bateada_bota_x		;9f44
	neg		;9f47
	ld b,0ffh		;9f49
bateada_bota_x:		; La X del bote
	ld h,a			;9f4b
	push bc			;9f4c
	ld l,0dch		;9f4d   ; por 0xDC / 256
	call multiplica		;9f4f
	ld a,h			;9f52
	pop bc			;9f53
	bit 0,b		;9f54   ; con su signo
	jr z,bateada_bota_pon		;9f56
	neg		;9f58
bateada_bota_pon:		; Guardada
	ld (0e095h),a		;9f5a
	ld hl,00000h		;9f5d   ; la altura a cero
bateada_altura:		; La altura
	ld (0e09ah),hl		;9f60
	ld a,(0e00bh)		;9f63   ; fuera del campo?
	bit 0,a		;9f66
	jr nz,bateada_pinta		;9f68
	ld hl,(0e098h)		;9f6a   ; la distancia...
	ld bc,06000h		;9f6d   ; ...pasa de 0x60?
	sbc hl,bc		;9f70
	jr c,bateada_pinta		;9f72
	bit 1,a		;9f74   ; ya ha botado?
	jr nz,bateada_valla		;9f76
	ld hl,(0e09ah)		;9f78   ; la altura...
	ld bc,01000h		;9f7b
	sbc hl,bc		;9f7e   ; ...por encima de 0x10?
	jr nc,bateada_fuera_campo		;9f80
bateada_valla:		; Contra la valla: rebota
	ld hl,(0e095h)		;9f82   ; la velocidad...
	bit 7,l		;9f85   ; ...hacia atras?
	jr nz,bateada_pinta		;9f87
	ld h,020h		;9f89   ; por 0x20 / 256...
	call multiplica		;9f8b
	ld a,h			;9f8e   ; ...al reves: rebota
	neg		;9f8f
	ld (0e095h),a		;9f91
	jr bateada_pinta		;9f94
bateada_fuera_campo:		; Por encima de la valla: fuera
	ld hl,0e00bh		;9f96   ; fuera del campo: home run
	set 0,(hl)		;9f99
bateada_pinta:		; La gravedad y el sprite: la Y, la X segun la direccion (0xA011) y la sombra
	ld hl,0e096h		;9f9b   ; la gravedad: la velocidad hacia arriba...
	ld a,(hl)			;9f9e
	sub 004h		;9f9f   ; ...4 menos
	ld (hl),a			;9fa1
	ld hl,(0e098h)		;9fa2   ; la distancia
	push hl			;9fa5
	ld hl,(0e097h)		;9fa6   ; la direccion...
	ld h,000h		;9fa9
	add hl,hl			;9fab   ; ...por 2...
	ld de,0a011h		;9fac   ; ...en 0xA011
	add hl,de			;9faf
	push hl			;9fb0
	pop ix		;9fb1
	pop hl			;9fb3
	push hl			;9fb4
	ld l,(ix+000h)		;9fb5   ; lo que avanza...
	call multiplica		;9fb8   ; ...por la distancia...
	sla h		;9fbb   ; ...por 2
	ld a,0a6h		;9fbd   ; 0xA6 menos: la Y de la sombra
	sub h			;9fbf
	ld (0e1ech),a		;9fc0
	ld hl,(0e09ah)		;9fc3   ; la altura...
	sub h			;9fc6   ; ...restada: la Y de la pelota
	ld (0e1a4h),a		;9fc7
	pop hl			;9fca
	ld l,(ix+001h)		;9fcb   ; lo que se abre...
	call multiplica		;9fce   ; ...por la distancia
	sla h		;9fd1   ; por 2
	ld a,(0e097h)		;9fd3   ; la direccion...
	cp 006h		;9fd6   ; ...de la 6 en adelante, a la izquierda
	ld a,077h		;9fd8   ; desde 0x77
	jr nc,bateada_izq		;9fda
	add a,h			;9fdc   ; a la derecha
	jr bateada_pinta_x		;9fdd
bateada_izq:		; A la izquierda
	sub h			;9fdf
bateada_pinta_x:		; La X
	ld (0e1edh),a		;9fe0   ; la X de la sombra...
	ld (0e1a5h),a		;9fe3   ; ...y de la pelota
	ld b,03ch		;9fe6   ; el dibujo grande...
	ld a,(0e099h)		;9fe8   ; ...con la altura...
	cp 030h		;9feb   ; ...de 0x30 o mas...
	jr c,bateada_pinta_dibujo		;9fed
	ld b,038h		;9fef   ; ...el pequeno
bateada_pinta_dibujo:		; El dibujo
	ld a,b			;9ff1
	ld (0e1a6h),a		;9ff2   ; la pelota...
	ld (0e1eeh),a		;9ff5   ; ...y su sombra
	ld a,(0e095h)		;9ff8   ; parada: sin velocidad...
	or a			;9ffb
	ret nz			;9ffc
	ld a,(0e09ah)		;9ffd   ; ...ni altura...
	cp 005h		;a000
	ret nc			;a002
	ld a,(0e096h)		;a003   ; ...ni subida
	cp 005h		;a006
	ret nc			;a008
bateada_para:		; Parada
	ld hl,0e00bh		;a009   ; el paso: parada
	res 6,(hl)		;a00c
	set 5,(hl)		;a00e
	ret			;a010

; ----------------------------------------------------------------------
; DATOS direcciones_golpe: Las doce direcciones del golpe: cuanto avanza y
;   cuanto se abre por paso
;   0xa011..0xa029  (24 bytes)
DATA_direcciones_golpe:
	defb 01eh,08ch	; a011
	defb 041h,093h	; a013
	defb 054h,08bh	; a015
	defb 06eh,06fh	; a017
	defb 080h,036h	; a019
	defb 080h,01bh	; a01b
	defb 080h,01bh	; a01d
	defb 080h,036h	; a01f
	defb 06eh,06fh	; a021
	defb 054h,08bh	; a023
	defb 041h,093h	; a025
	defb 01eh,08ch	; a027

; ======================================================================
; CODIGO 0xa029..0xa668  (1599 bytes)
; ======================================================================


corredores_ordenes:		; Las ordenes a los corredores con el mando (0xE00E): avanzar o volver
	ld ix,0e00eh		;a029
	bit 7,(ix+000h)		;a02d   ; en marcha?
	ret z			;a031
	ld a,(0e00bh)		;a032   ; ya ha botado?
	bit 1,a		;a035
	ld a,(0e024h)		;a037   ; a donde se puede correr...
	push af			;a03a
	jr nz,corredores_ordenes_mando		;a03b
	or 038h		;a03d   ; en el aire: solo volver
	ld b,a			;a03f
	ld a,(0e01bh)		;a040   ; las bases ocupadas...
	or 007h		;a043
	and 03fh		;a045
	and b			;a047
	ld (0e024h),a		;a048   ; guardado
corredores_ordenes_mando:		; El mando
	call corredores_boton		;a04b   ; el boton con una direccion
	call corredores_direccion		;a04e   ; la direccion
	pop af			;a051   ; como estaba
	ld (0e024h),a		;a052
	ret			;a055
corredores_boton:		; El boton con una direccion: los corredores que corren
	ld a,(0e256h)		;a056
	and 030h		;a059   ; el boton?
	ret z			;a05b
	ld b,007h		;a05c   ; los de avanzar...
	bit 5,a		;a05e   ; boton 2?
	jr z,corredores_boton_base		;a060
	ld b,038h		;a062   ; ...o los de volver
corredores_boton_base:		; A que base
	ld e,b			;a064
	ld a,(0e024h)		;a065   ; a donde se puede...
	and b			;a068   ; ...de los de esa clase
	ld b,a			;a069
	rra			;a06a   ; juntos en los bits bajos
	rra			;a06b
	rra			;a06c
	or b			;a06d
	ld b,001h		;a06e
	push ix		;a070
	pop hl			;a072
	ld b,001h		;a073   ; primera
	bit 3,(hl)		;a075   ; a la derecha: primera?
	jr nz,corredores_boton_bit		;a077
	ld b,002h		;a079   ; segunda
	bit 0,(hl)		;a07b   ; arriba: segunda?
	jr nz,corredores_boton_bit		;a07d
	ld b,004h		;a07f   ; tercera
	bit 2,(hl)		;a081   ; a la izquierda: tercera?
	ret z			;a083
corredores_boton_bit:		; El bit
	and b			;a084   ; se puede?
	bit 0,a		;a085
	jr nz,corredores_boton_1		;a087
	bit 1,a		;a089
	jr nz,corredores_boton_2		;a08b
	bit 2,a		;a08d
	jp nz,corredores_boton_3		;a08f
	ret			;a092
corredores_boton_1:		; El de primera
	ld c,001h		;a093   ; primera
	push de			;a095
	call corredor_base		;a096   ; su corredor
	pop de			;a099
	ret nz			;a09a
	ld a,(hl)			;a09b   ; su base...
	and 003h		;a09c
	ld b,a			;a09e
	set 7,b		;a09f   ; ...en marcha
	bit 0,e		;a0a1   ; avanzar?
	jr nz,corredores_boton_1g		;a0a3
	set 5,b		;a0a5   ; con orden de volver...
corredores_boton_1g:		; Guardado
	ld (hl),b			;a0a7   ; guardado
	ret			;a0a8
corredores_boton_2:		; El de segunda
	ld c,002h		;a0a9   ; segunda
	push de			;a0ab
	call corredor_base		;a0ac   ; su corredor
	pop de			;a0af
	ret nz			;a0b0
	ld a,(hl)			;a0b1   ; su base...
	and 003h		;a0b2
	ld b,a			;a0b4
	set 7,b		;a0b5   ; ...en marcha
	bit 0,e		;a0b7
	jr nz,corredores_boton_2g		;a0b9
	set 5,b		;a0bb   ; con orden
	ld (hl),b			;a0bd
	ld a,(0e01bh)		;a0be   ; el de primera tambien corre?
	bit 3,a		;a0c1
	jr nz,corredores_boton_1		;a0c3
	ret			;a0c5
corredores_boton_2g:		; Guardado
	ld (hl),b			;a0c6
	ret			;a0c7
corredores_boton_3:		; El de tercera
	ld c,003h		;a0c8   ; tercera
	push de			;a0ca
	call corredor_base		;a0cb   ; su corredor
	pop de			;a0ce
	ret nz			;a0cf
	ld a,(hl)			;a0d0   ; su base...
	and 003h		;a0d1
	ld b,a			;a0d3
	set 7,b		;a0d4   ; ...en marcha
	bit 0,e		;a0d6
	jr nz,corredores_boton_3g		;a0d8
	set 5,b		;a0da   ; con orden
	ld (hl),b			;a0dc
	ld a,(0e01bh)		;a0dd   ; el de segunda tambien corre?
	bit 4,a		;a0e0
	jr nz,corredores_boton_2		;a0e2
	ret			;a0e4
corredores_boton_3g:		; Guardado
	ld (hl),b			;a0e5
	ret			;a0e6
corredores_direccion:		; La direccion del mando, a 0xE00E
	ld a,(0e256h)		;a0e7
	and 00dh		;a0ea   ; la direccion...
	ret z			;a0ec
	ld b,a			;a0ed
	ld a,(0e00eh)		;a0ee   ; ...a los bits bajos de 0xE00E
	and 0f0h		;a0f1
	or b			;a0f3
	ld (0e00eh),a		;a0f4
	ret			;a0f7
bases_ocupadas:		; Las bases ocupadas (0xE01B: bits 0-2) y con corredor en marcha (bits 3-5), y a donde se puede correr (0xE024)
	ld hl,0e01bh		;a0f8
	ld c,001h		;a0fb   ; primera
	call corredor_estado		;a0fd   ; su corredor
	jr nz,bases_1_libre		;a100
	set 0,(hl)		;a102   ; ocupada
	bit 7,a		;a104   ; en marcha?
	jr z,bases_1_quieto		;a106
	set 3,(hl)		;a108   ; en marcha
	jr bases_2		;a10a
bases_1_libre:		; Primera libre
	res 0,(hl)		;a10c
bases_1_quieto:		; Quieto
	res 3,(hl)		;a10e
bases_2:		; Segunda
	ld c,002h		;a110
	call corredor_estado		;a112   ; segunda
	jr nz,bases_2_libre		;a115
	set 1,(hl)		;a117   ; ocupada
	bit 7,a		;a119
	jr z,bases_2_quieto		;a11b
	set 4,(hl)		;a11d   ; en marcha
	jr bases_3		;a11f
bases_2_libre:		; Libre
	res 1,(hl)		;a121
bases_2_quieto:		; Quieto
	res 4,(hl)		;a123
bases_3:		; Tercera
	ld c,003h		;a125
	call corredor_estado		;a127   ; tercera
	jr nz,bases_3_libre		;a12a
	set 2,(hl)		;a12c   ; ocupada
	bit 7,a		;a12e
	jr z,bases_3_quieto		;a130
	set 5,(hl)		;a132   ; en marcha
	jr bases_carreras		;a134
bases_3_libre:		; Libre
	res 2,(hl)		;a136
bases_3_quieto:		; Quieto
	res 5,(hl)		;a138
bases_carreras:		; A donde se puede correr
	call alguno_corre		;a13a   ; algun corredor en marcha?
	ld hl,0e024h		;a13d   ; todas se pueden...
	ld (hl),03fh		;a140
	jr nz,bases_carreras_1		;a142
	res 3,(hl)		;a144   ; ...si no hay jugada, no se avanza de primera
bases_carreras_1:		; Primera
	ld c,001h		;a146
	call cuantos_en_base		;a148   ; cuantos en primera
	cp 002h		;a14b   ; dos o mas: no
	jr c,bases_carreras_1b		;a14d
	res 3,(hl)		;a14f
bases_carreras_1b:		; Con corredor
	ld a,(0e01bh)		;a151   ; primera ocupada?
	bit 0,a		;a154
	jr z,bases_carreras_2		;a156
	bit 3,a		;a158   ; en marcha?
	jr nz,bases_carreras_1c		;a15a
	res 3,(hl)		;a15c   ; quieto: no avanza
	jr bases_carreras_2		;a15e
bases_carreras_1c:		; En marcha
	call corredor_estado		;a160   ; su estado
	bit 5,a		;a163   ; vuelve?
	jr nz,bases_carreras_2		;a165
	res 0,(hl)		;a167   ; no avanza
	bit 3,(hl)		;a169
	jr nz,bases_carreras_2		;a16b
	res 4,(hl)		;a16d   ; tampoco vuelve
bases_carreras_2:		; Segunda
	ld c,002h		;a16f
	call cuantos_en_base		;a171   ; cuantos en segunda
	cp 002h		;a174   ; dos o mas: no
	jr c,bases_carreras_2b		;a176
	res 4,(hl)		;a178
	res 0,(hl)		;a17a
bases_carreras_2b:		; Con corredor
	ld a,(0e01bh)		;a17c   ; segunda ocupada?
	bit 1,a		;a17f
	jr z,bases_carreras_3		;a181   ; en marcha?
	bit 4,a		;a183
	jr nz,bases_carreras_2c		;a185
	res 0,(hl)		;a187   ; quieto: no avanza
	res 4,(hl)		;a189
	jr bases_carreras_3		;a18b
bases_carreras_2c:		; En marcha
	call corredor_estado		;a18d   ; su estado
	bit 5,a		;a190   ; vuelve?
	jr z,bases_carreras_2d		;a192
	res 0,(hl)		;a194
	jr bases_carreras_3		;a196
bases_carreras_2d:		; Quieto
	res 1,(hl)		;a198
	bit 4,(hl)		;a19a
	jr nz,bases_carreras_3		;a19c
	res 5,(hl)		;a19e
bases_carreras_3:		; Tercera
	ld c,003h		;a1a0
	call cuantos_en_base		;a1a2   ; cuantos en tercera
	cp 002h		;a1a5   ; dos o mas: no
	jr c,bases_carreras_3b		;a1a7
	res 5,(hl)		;a1a9
	res 1,(hl)		;a1ab
bases_carreras_3b:		; Con corredor
	ld a,(0e01bh)		;a1ad   ; tercera ocupada?
	bit 2,a		;a1b0
	ret z			;a1b2
	bit 5,a		;a1b3   ; en marcha?
	jr nz,bases_carreras_3c		;a1b5
	res 1,(hl)		;a1b7   ; quieto: no avanza
	res 5,(hl)		;a1b9
	ret			;a1bb
bases_carreras_3c:		; En marcha
	call corredor_estado		;a1bc   ; su estado
	bit 5,a		;a1bf   ; vuelve?
	ret z			;a1c1
	res 1,(hl)		;a1c2
	ret			;a1c4
cuantos_en_base:		; Cuantos corredores hay en la base C
	push bc			;a1c5
	push hl			;a1c6
	ld b,004h		;a1c7   ; cuatro corredores
	ld iy,00000h		;a1c9   ; la cuenta
	ld de,00006h		;a1cd
	ld hl,0e067h		;a1d0   ; desde 0xE067
cuantos_en_base_uno:		; Uno
	ld a,(hl)			;a1d3
	bit 6,a		;a1d4   ; fuera?
	jr nz,cuantos_en_base_sig		;a1d6
	and 003h		;a1d8   ; su base...
	cp c			;a1da   ; ...la C?
	jr nz,cuantos_en_base_sig		;a1db
	inc iy		;a1dd   ; uno mas
cuantos_en_base_sig:		; El siguiente
	add hl,de			;a1df
	djnz cuantos_en_base_uno		;a1e0
	push iy		;a1e2   ; la cuenta...
	pop bc			;a1e4
	ld a,c			;a1e5   ; ...en A
	pop hl			;a1e6
	pop bc			;a1e7
	ret			;a1e8
corredor_estado:		; A = el estado del corredor de la base C
	push hl			;a1e9
	call corredor_base		;a1ea   ; su corredor
	ld a,(hl)			;a1ed   ; su estado
	pop hl			;a1ee
	ret			;a1ef
alguno_corre:		; Z si algun corredor esta en marcha
	ld hl,0e067h		;a1f0
	ld de,00006h		;a1f3   ; cuatro corredores
	ld b,004h		;a1f6
alguno_corre_uno:		; Uno
	ld a,(hl)			;a1f8
	bit 7,a		;a1f9   ; en marcha...
	jr z,alguno_corre_sig		;a1fb
	and 043h		;a1fd   ; ...en una base: Z
	ret z			;a1ff
alguno_corre_sig:		; El siguiente
	add hl,de			;a200
	djnz alguno_corre_uno		;a201
	inc b			;a203   ; NZ: ninguno
	ret			;a204
base_por_bolas:		; La base por bolas y el golpe (0xE01C): los corredores obligados avanzan
	ld a,(0e003h)		;a205
	and 0a0h		;a208   ; hay cartel?
	ret nz			;a20a
	ld ix,0e01ch		;a20b
	ld a,(ix+000h)		;a20f   ; su estado...
	rlca			;a212   ; ...bit 7: la base por bolas
	jr c,base_por_bolas_paso		;a213
	rlca			;a215   ; bit 6: el golpe
	jp c,golpe		;a216
	rlca			;a219   ; bit 5: baja la pelota
	jp c,golpe_baja		;a21a
	ret			;a21d
base_por_bolas_paso:		; Por pasos
	ld a,(ix+001h)		;a21e
	rlca			;a221   ; bit 7: pone
	jr c,base_por_bolas_pone		;a222
	rlca			;a224   ; bit 6: espera
	jr c,base_por_bolas_fin		;a225
	ret			;a227
base_por_bolas_pone:		; El bateador a primera y los demas, uno mas
	xor a			;a228   ; las partes de la jugada a cero
	ld (0e008h),a		;a229
	ld (0e009h),a		;a22c
	ld (0e00ah),a		;a22f
	ld (0e066h),a		;a232
	ld (0e00dh),a		;a235
	ld bc,00000h		;a238   ; la casilla de casa...
	call jugador_marca		;a23b   ; ...vacia
	ld c,000h		;a23e   ; el bateador...
	call corredor_base		;a240
	ld (hl),080h		;a243   ; ...corre
	inc hl			;a245
	inc hl			;a246
	inc hl			;a247
	inc hl			;a248
	ld (hl),0adh		;a249   ; Y 0xAD...
	inc hl			;a24b
	ld (hl),080h		;a24c   ; ...X 0x80: en casa
	inc c			;a24e   ; el de primera...
	call corredor_base		;a24f
	jr nz,base_por_bolas_espera		;a252
	ld (hl),081h		;a254   ; ...a segunda
	inc c			;a256
	call corredor_base		;a257
	jr nz,base_por_bolas_espera		;a25a
	ld (hl),082h		;a25c   ; el de segunda, a tercera
	inc c			;a25e
	call corredor_base		;a25f
	jr nz,base_por_bolas_espera		;a262
	ld (hl),083h		;a264   ; el de tercera, a casa
base_por_bolas_espera:		; El paso siguiente
	ld (ix+001h),040h		;a266   ; espera
	ret			;a26a
base_por_bolas_fin:		; Espera a que paren
	call todos_parados		;a26b   ; todos parados?
	ret nz			;a26e
	res 7,(ix+000h)		;a26f   ; se acaba
	ret			;a273
todos_parados:		; Z si ninguno de los cuatro corredores esta en marcha
	ld hl,(0e067h)		;a274   ; el estado de los cuatro...
	ld a,l			;a277
	ld hl,(0e06dh)		;a278
	or l			;a27b
	ld hl,(0e073h)		;a27c
	or l			;a27f
	ld hl,(0e079h)		;a280
	or l			;a283
	and 080h		;a284   ; ...alguno en marcha?
	ret			;a286
golpe:		; La pelota bateada se queda en el campo: el bateador corre a primera
	ld a,(0e00fh)		;a287   ; hay robo?
	rlca			;a28a
	ret c			;a28b
	ld a,(ix+001h)		;a28c   ; el paso
	rlca			;a28f
	jr c,golpe_corre		;a290
	rlca			;a292
	jr c,golpe_fin		;a293
	ret			;a295
golpe_corre:		; Corre
	ld a,003h		;a296   ; el bateador...
	ld (0e023h),a		;a298   ; ...a la tercera velocidad
	ld bc,00000h		;a29b   ; la casilla de casa vacia
	call jugador_marca		;a29e
	ld hl,0e01eh		;a2a1   ; la jugada en marcha
	set 7,(hl)		;a2a4
	xor a			;a2a6   ; las partes a cero
	ld (0e00ah),a		;a2a7
	ld (0e009h),a		;a2aa
	ld (0e008h),a		;a2ad
	ld (0e00dh),a		;a2b0
	ld c,000h		;a2b3   ; el bateador...
	call corredor_base		;a2b5
	ld (hl),0e0h		;a2b8   ; ...corre a primera
	inc hl			;a2ba
	inc hl			;a2bb
	inc hl			;a2bc
	inc hl			;a2bd
	ld (hl),0adh		;a2be   ; Y 0xAD...
	inc hl			;a2c0
	ld (hl),080h		;a2c1   ; ...X 0x80
	ld (ix+001h),040h		;a2c3   ; espera
	ret			;a2c7
golpe_fin:		; Espera a que paren
	call todos_parados		;a2c8
	ret nz			;a2cb
	ld (ix+000h),000h		;a2cc   ; se acaba
	ret			;a2d0
golpe_baja:		; Baja la pelota
	ld hl,0e1a4h		;a2d1   ; la Y de la pelota...
	ld a,(hl)			;a2d4
	cp 008h		;a2d5   ; ...por encima de 8?
	jr c,golpe_baja_fin		;a2d7
	dec (hl)			;a2d9   ; un punto arriba
	ret			;a2da
golpe_baja_fin:		; Fin
	res 5,(ix+000h)		;a2db   ; se acaba
	ret			;a2df
campo:		; Los jugadores del campo: van a por la pelota, la cogen y la lanzan
	ld a,(0e04ch)		;a2e0
	rlca			;a2e3   ; bit 7: sale
	jr c,campo_sale		;a2e4
	rlca			;a2e6   ; bit 6: va a por ella
	jp c,campo_corre		;a2e7
	rlca			;a2ea   ; bit 5: la tiene
	jp c,campo_fin		;a2eb
	rlca			;a2ee   ; bit 4: espera
	ret c			;a2ef
	ld a,0c2h		;a2f0   ; los dos sprites del campo, fuera
	ld (0e164h),a		;a2f2
	ld (0e168h),a		;a2f5
	ret			;a2f8
campo_sale:		; La pelota bateada: quien va a por ella, segun la direccion (0xE097)
	ld hl,00000h		;a2f9   ; los dos caminos a cero
	ld (0e050h),hl		;a2fc
	ld (0e052h),hl		;a2ff
	xor a			;a302   ; como la coge, a cero
	ld (0e04dh),a		;a303
	ld a,(0e097h)		;a306   ; la direccion...
	dec a			;a309   ; ...del 1 al 10?
	cp 00ah		;a30a
	jp nc,campo_fuera		;a30c
	ld a,(0e096h)		;a30f   ; la altura...
	cp 080h		;a312
	jr c,campo_cerca		;a314
	neg		;a316   ; al reves...
	sub 003h		;a318
campo_cerca:		; Cerca del lanzador: el lanzador
	sra a		;a31a   ; la mitad...
	cp 010h		;a31c   ; ...poca?
	jr nc,campo_interior		;a31e
	sra a		;a320   ; la mitad...
	ld hl,(0e095h)		;a322   ; ...mas la distancia
	add a,l			;a325
	ld c,a			;a326
	ld a,(0e097h)		;a327   ; lo lejos del centro...
	sub 006h		;a32a
	jr nc,campo_lejos		;a32c
	neg		;a32e   ; al reves...
	dec a			;a330
campo_lejos:		; Mas lejos: el jardinero que toca
	ld b,030h		;a331   ; cerca del centro: 0x30
	cp 002h		;a333
	jr c,campo_cubre		;a335
	ld b,028h		;a337   ; 0x28
	jr z,campo_cubre		;a339
	ld b,020h		;a33b   ; 0x20
campo_cubre:		; El que cubre
	ld a,c			;a33d
	cp b			;a33e   ; cerca?
	jr nc,campo_interior		;a33f
	ld hl,0e04dh		;a341   ; la coge el lanzador
	set 0,(hl)		;a344
	ld a,(0e097h)		;a346   ; la direccion...
	cp 006h		;a349   ; ...a la izquierda?
	ld a,080h		;a34b
	jr nc,campo_cubre_pon		;a34d
	ld a,000h		;a34f
campo_cubre_pon:		; Su destino
	ld h,a			;a351
	add a,004h		;a352   ; mas 4
	ld l,a			;a354
	ld (0e04eh),hl		;a355   ; a donde va
	xor a			;a358
	ld (0e05fh),a		;a359   ; sin base
	ld a,0c0h		;a35c   ; el lanzador en casillas, a borrar
	ld (0e24dh),a		;a35e
	ld a,(0e01fh)		;a361   ; el color del equipo
	ld (0e167h),a		;a364
	ld hl,0e04ch		;a367   ; va a por ella
	res 7,(hl)		;a36a
	set 6,(hl)		;a36c
	ret			;a36e
campo_interior:		; Los del cuadro: segunda, primera o tercera
	ld a,(0e097h)		;a36f
	cp 004h		;a372   ; del 0 al 3: primera
	jr c,campo_1		;a374
	cp 006h		;a376   ; 4 y 5: segunda
	jr c,campo_2		;a378
	cp 008h		;a37a   ; 6 y 7: tercera
	jr c,campo_3		;a37c
	ld a,002h		;a37e   ; del 8 en adelante: el de la izquierda
	ld bc,00004h		;a380
	jr campo_va		;a383
campo_1:		; El de primera
	xor a			;a385
	ld bc,08084h		;a386
	jr campo_va		;a389
campo_2:		; El de segunda
	ld a,001h		;a38b
	ld bc,08084h		;a38d
	jr campo_va		;a390
campo_3:		; El de tercera
	ld a,003h		;a392
	ld bc,00004h		;a394
campo_va:		; El que va: su sitio en casillas se borra (ahora corre en un sprite)
	ld hl,0e166h		;a397
	ld (hl),b			;a39a   ; su direccion
	ld (0e04eh),bc		;a39b   ; guardada
	push af			;a39f
	add a,002h		;a3a0   ; su base...
	ld c,a			;a3a2
	ld (0e05fh),a		;a3a3   ; ...guardada...
	ld b,001h		;a3a6   ; ...a borrar en casillas
	call jugador_marca		;a3a8
	pop af			;a3ab
	rlca			;a3ac   ; como la coge...
	ld hl,0e04dh		;a3ad
	or (hl)			;a3b0
	ld (hl),a			;a3b1   ; ...guardado
	ld a,(0e01fh)		;a3b2   ; el color del equipo
	ld (0e167h),a		;a3b5
	ld a,(0e097h)		;a3b8   ; la direccion: el jardinero
	cp 004h		;a3bb
	jr c,campo_jardin_3		;a3bd
	cp 006h		;a3bf
	jr c,campo_jardin_2		;a3c1
	cp 008h		;a3c3
	jr c,campo_jardin_1		;a3c5
	ld a,001h		;a3c7
	ld b,080h		;a3c9
	jr campo_jardin_va		;a3cb
campo_jardin_3:		; El jardinero de la izquierda
	ld a,003h		;a3cd
	ld b,000h		;a3cf
	jr campo_jardin_va		;a3d1
campo_jardin_2:		; El del centro
	ld a,002h		;a3d3
	ld b,080h		;a3d5
	jr campo_jardin_va		;a3d7
campo_jardin_1:		; El de la derecha
	ld a,002h		;a3d9
	ld b,000h		;a3db
campo_jardin_va:		; El que va
	push af			;a3dd
	ld hl,0e16ah		;a3de   ; su sprite
	ld (hl),b			;a3e1
	inc hl			;a3e2
	ld a,(0e01fh)		;a3e3   ; el color
	ld (hl),a			;a3e6
	pop af			;a3e7
	push af			;a3e8
	add a,005h		;a3e9   ; su base...
	ld c,a			;a3eb
	ld (0e060h),a		;a3ec   ; ...guardada...
	ld a,030h		;a3ef   ; ...corriendo
	ld (0e055h),a		;a3f1
	ld b,001h		;a3f4
	call jugador_marca		;a3f6   ; a borrar en casillas
	pop af			;a3f9
	ld hl,0e04dh		;a3fa   ; como la coge
	rlca			;a3fd
	rlca			;a3fe
	rlca			;a3ff
	or (hl)			;a400
	ld (hl),a			;a401
	ld hl,0e04ch		;a402   ; va a por ella
	res 7,(hl)		;a405
	set 6,(hl)		;a407
	ret			;a409
campo_fuera:		; Fuera del campo: nadie va
	ld a,010h		;a40a   ; nadie: espera
	ld (0e04ch),a		;a40c
	ret			;a40f
campo_corre:		; Corren hacia la pelota (0xA7DF) y la cogen si la tocan
	ld a,(0e00bh)		;a410
	bit 0,a		;a413   ; ya parada?
	ret nz			;a415
	ld a,(0e04dh)		;a416   ; el que cubre...
	and 018h		;a419
	jp z,campo_jardin		;a41b
	rrca			;a41e   ; a que base
	rrca			;a41f
	rrca			;a420
	cp 002h		;a421   ; segunda?
	jr c,campo_corre_1		;a423
	jr z,campo_corre_2		;a425
	ld hl,0c05fh		;a427   ; hacia tercera (Y 0x5F, X 0xC0)
	jr campo_corre_va		;a42a
campo_corre_1:		; Hacia primera
	ld hl,0305fh		;a42c   ; hacia primera (Y 0x5F, X 0x30)
	jr campo_corre_va		;a42f
campo_corre_2:		; Hacia segunda
	ld hl,0784fh		;a431   ; hacia segunda (Y 0x4F, X 0x78)
campo_corre_va:		; Va
	ld (0e085h),hl		;a434   ; el destino
	ld hl,(0e1ech)		;a437   ; desde la pelota
	ld (0e083h),hl		;a43a
	ld hl,(0e052h)		;a43d   ; el camino
	ld (0e089h),hl		;a440
	ld hl,(0e168h)		;a443   ; donde esta
	ld (0e087h),hl		;a446
	ld a,024h		;a449   ; velocidad 0x24
	ld (0e08bh),a		;a44b
	call hacia		;a44e   ; un paso
	ld hl,(0e089h)		;a451   ; guardado
	ld (0e052h),hl		;a454
	ld a,(0e08bh)		;a457   ; ha llegado?
	or a			;a45a
	jr z,campo_corre_llega		;a45b
	ld hl,(0e087h)		;a45d   ; donde esta, al sprite
	ld (0e168h),hl		;a460
	jr campo_coge		;a463
campo_corre_llega:		; Llega
	ld hl,(0e052h)		;a465   ; el camino...
	ld bc,000c8h		;a468   ; ...0xC8 menos
	sbc hl,bc		;a46b
	ld (0e052h),hl		;a46d
campo_coge:		; La pelota a su alcance: la coge
	ld a,(0e1a4h)		;a470   ; la Y de la pelota...
	ld hl,(0e1ech)		;a473
	add a,006h		;a476   ; ...mas 6...
	cp l			;a478   ; ...contra la sombra
	jr c,campo_jardin		;a479
	ld hl,(0e168h)		;a47b   ; el jugador...
	ld a,(0e1a4h)		;a47e
	sub l			;a481   ; ...a menos de 4 en Y...
	add a,004h		;a482
	cp 008h		;a484
	jr nc,campo_jardin		;a486
	ld a,(0e1a5h)		;a488
	sub h			;a48b   ; ...y en X
	add a,004h		;a48c
	cp 008h		;a48e
	jr nc,campo_jardin		;a490
	ld hl,0e055h		;a492   ; la tiene
	res 4,(hl)		;a495
	ld hl,0e04dh		;a497   ; en el aire
campo_cogida:		; Cogida: el sonido, y la fase de lanzarla
	set 7,(hl)		;a49a
	dec hl			;a49c   ; el paso...
	res 6,(hl)		;a49d
	set 5,(hl)		;a49f
	call sonido_calla		;a4a1   ; el sonido callado
	ld a,(0e025h)		;a4a4   ; hay cartel?
	rlca			;a4a7
	ret c			;a4a8
	ld b,002h		;a4a9   ; el canal 2...
	ld de,0bfa2h		;a4ab   ; ...0xBFA2
	jp pieza		;a4ae
campo_jardin:		; El jardinero
	ld a,(0e04dh)		;a4b1
	bit 5,a		;a4b4   ; de bote?
	jr z,campo_jardin_destino		;a4b6
	and 018h		;a4b8
	ret nz			;a4ba
campo_jardin_destino:		; Su destino
	ld a,(0e04dh)		;a4bb
	bit 0,a		;a4be   ; el lanzador?
	jr z,campo_jardin_d		;a4c0
	ld hl,07883h		;a4c2   ; hacia casa (Y 0x83, X 0x78)
	jr campo_jardin_corre		;a4c5
campo_jardin_d:		; Segun la base
	and 006h		;a4c7   ; quien
	jr nz,campo_jardin_e		;a4c9
	ld hl,0cf85h		;a4cb   ; hacia el centro (Y 0x85, X 0xCF)
	jr campo_jardin_corre		;a4ce
campo_jardin_e:		; Otra
	cp 004h		;a4d0
	jr z,campo_jardin_f		;a4d2
	jr c,campo_jardin_g		;a4d4
	ld hl,05867h		;a4d6   ; hacia la derecha (Y 0x67, X 0x58)
	jr campo_jardin_corre		;a4d9
campo_jardin_f:		; Otra
	ld hl,02877h		;a4db   ; hacia el medio (Y 0x77, X 0x28)
	jr campo_jardin_corre		;a4de
campo_jardin_g:		; Otra
	ld hl,09867h		;a4e0   ; hacia la izquierda (Y 0x67, X 0x98)
campo_jardin_corre:		; Corre
	ld (0e085h),hl		;a4e3   ; el destino
	ld hl,(0e1ech)		;a4e6
	ld (0e083h),hl		;a4e9   ; desde la pelota
	ld hl,(0e164h)		;a4ec
	ld (0e087h),hl		;a4ef   ; donde esta
	ld hl,(0e050h)		;a4f2
	ld (0e089h),hl		;a4f5   ; el camino
	ld hl,0e08bh		;a4f8
	ld (hl),017h		;a4fb   ; velocidad 0x17
	call hacia		;a4fd   ; un paso
	ld hl,(0e089h)		;a500   ; guardado
	ld (0e050h),hl		;a503
	ld a,(0e08bh)		;a506
	or a			;a509
	jr z,campo_jardin_llega		;a50a   ; ha llegado?
	ld hl,(0e087h)		;a50c
	ld (0e164h),hl		;a50f   ; donde esta, al sprite
	jr campo_jardin_coge		;a512
campo_jardin_llega:		; Llega
	ld hl,(0e050h)		;a514   ; el camino...
	ld bc,00096h		;a517   ; ...0x96 menos
	sbc hl,bc		;a51a
	ld (0e050h),hl		;a51c
campo_jardin_coge:		; La coge si la tiene a su alcance: en el aire o de bote
	ld hl,(0e1a4h)		;a51f   ; la pelota...
	ld bc,(0e087h)		;a522   ; ...y el jugador
	ld a,h			;a526   ; la distancia en X...
	sub b			;a527
	add a,003h		;a528
	cp 006h		;a52a   ; ...menos de 3?
	jr nc,campo_jardin_sigue		;a52c
	ld a,(0e04dh)		;a52e   ; el lanzador?
	rrca			;a531
	ld d,00eh		;a532   ; su alcance: 0x0E
	jr c,campo_jardin_alcance		;a534
	ld a,(0e095h)		;a536   ; la velocidad...
	ld d,005h		;a539   ; ...rapida: 0x05
	cp 02ah		;a53b
	jr nc,campo_jardin_alcance		;a53d
	ld d,00ch		;a53f   ; 0x0C
	ld a,(0e00bh)		;a541   ; ha botado?
	bit 1,a		;a544
	jr z,campo_jardin_alcance		;a546
	ld d,007h		;a548   ; 0x07
campo_jardin_alcance:		; El alcance
	ld a,(0e1ech)		;a54a   ; la sombra...
	ld b,a			;a54d
	sub c			;a54e   ; ...contra el jugador...
	add a,004h		;a54f
	cp 008h		;a551   ; ...a menos de 4?
	jr nc,campo_jardin_sigue		;a553
	ld a,b			;a555   ; la altura...
	sub l			;a556
	add a,006h		;a557
	cp d			;a559   ; ...dentro del alcance?
	jr nc,campo_jardin_sigue		;a55a
	ld hl,0e04dh		;a55c   ; cogida en el aire
	set 6,(hl)		;a55f
	jp campo_cogida		;a561
campo_jardin_sigue:		; Sigue
	ld hl,0e04dh		;a564
	bit 5,(hl)		;a567   ; parado?
	jr nz,campo_jardin_dibujo		;a569
	ld hl,(0e164h)		;a56b   ; el jugador...
	call distancia_casa		;a56e   ; ...lejos de casa...
	cp 068h		;a571   ; ...menos de 0x68?
	jr nc,campo_jardin_para		;a573
	add a,008h		;a575   ; mas 8
	ld b,a			;a577
	ld hl,(0e1ech)		;a578   ; la pelota...
	call distancia_casa		;a57b   ; ...mas lejos?
	cp b			;a57e
	jr c,campo_jardin_dibujo		;a57f
campo_jardin_para:		; Para
	ld hl,0e055h		;a581
	res 4,(hl)		;a584   ; para
	ld hl,0e04dh		;a586   ; parado
	set 5,(hl)		;a589
	ret			;a58b
campo_jardin_dibujo:		; Su dibujo de correr
	ld bc,(0e04eh)		;a58c   ; los dos dibujos
	ld a,(0e0a7h)		;a590   ; la cuenta...
	cp 006h		;a593   ; ...menos de 6: el primero
	jr nc,campo_jardin_dibujo2		;a595
	ld c,b			;a597
campo_jardin_dibujo2:		; La cuenta
	cp 00ch		;a598
	jr c,campo_jardin_dibujo3		;a59a   ; ...hasta 12
	xor a			;a59c
	ld (0e0a7h),a		;a59d
campo_jardin_dibujo3:		; Guardado
	ld hl,0e166h		;a5a0
	ld (hl),c			;a5a3   ; el dibujo
	ret			;a5a4
distancia_casa:		; La distancia de Y, X (H, L) a la casa: la mayor mas la mitad de la menor
	ld a,l			;a5a5
	sub 0a0h		;a5a6   ; la distancia en Y a 0xA0...
	jr nc,distancia_casa_x		;a5a8
	neg		;a5aa   ; ...en valor absoluto
distancia_casa_x:		; La X
	ld l,a			;a5ac
	srl a		;a5ad   ; la mitad...
	add a,l			;a5af   ; ...mas el valor
	ld l,a			;a5b0
	ld a,h			;a5b1
	sub 078h		;a5b2   ; la distancia en X a 0x78...
	jr nc,distancia_casa_suma		;a5b4
	neg		;a5b6   ; ...en valor absoluto
distancia_casa_suma:		; La suma
	srl a		;a5b8   ; la mitad...
	add a,l			;a5ba   ; ...sumada
	ret			;a5bb
campo_fin:		; Fin de la jugada del campo
	ld hl,0e00bh		;a5bc
	ld a,(hl)			;a5bf   ; solo los dos bits bajos
	and 003h		;a5c0
	ld (hl),a			;a5c2
	ret			;a5c3
tiro:		; El tiro del jugador que tiene la pelota (0xE054): a la base del mando
	ld a,(0e054h)		;a5c4
	bit 7,a		;a5c7   ; en marcha?
	ret z			;a5c9
	call tiro_elige		;a5ca   ; el mando elige la base
	jp tiro_vuela		;a5cd   ; el tiro
tiro_elige:		; El mando elige la base
	ld a,(0e258h)		;a5d0   ; el mando del que esta en el campo
	and 00fh		;a5d3   ; una direccion?
	jp z,tiro_color		;a5d5
	ld b,a			;a5d8   ; la base...
	ld a,(0e05eh)		;a5d9   ; ...ya elegida?
	and 00fh		;a5dc
	cp b			;a5de
	jp z,tiro_color		;a5df
	ld hl,0e054h		;a5e2   ; la nueva...
	ld a,(hl)			;a5e5
	and 00fh		;a5e6
	ld c,a			;a5e8
	ld a,(hl)			;a5e9   ; ...guardada
	and 0f0h		;a5ea
	or b			;a5ec
	ld (hl),a			;a5ed
	ld a,(0e05eh)		;a5ee   ; la de antes...
	and 00fh		;a5f1
	cp c			;a5f3
	jr z,tiro_marca		;a5f4
	ld a,(hl)			;a5f6   ; ...y la marcada
	and 00fh		;a5f7
	cp c			;a5f9
	jr z,tiro_marca		;a5fa
	ld a,c			;a5fc   ; el jugador que cubria la de antes
	call cubre_base		;a5fd
	jr nc,tiro_marca		;a600
	ld b,000h		;a602   ; ...se vuelve a pintar
	call jugador_marca		;a604
tiro_marca:		; La base marcada
	ld a,(0e054h)		;a607   ; el que cubre la nueva...
	call cubre_base		;a60a
	ld b,0ffh		;a60d   ; ...a borrar: sale en un sprite
	call jugador_marca		;a60f
	ld hl,0a682h		;a612   ; su sitio
	ld de,00002h		;a615
	ld b,004h		;a618   ; cuatro bases
	ld a,(0e054h)		;a61a   ; el bit de la base...
tiro_busca:		; El sitio de la base (0xA682)
	rrca			;a61d
	jr c,tiro_sitio		;a61e
	add hl,de			;a620   ; la siguiente
	djnz tiro_busca		;a621
tiro_sitio:		; Su sitio
	push ix		;a623
	push hl			;a625
	pop ix		;a626
	ld l,(ix+000h)		;a628   ; la Y...
	ld h,(ix+001h)		;a62b   ; ...y la X de la base
	pop ix		;a62e
	ld bc,(0e174h)		;a630   ; el jugador que tiene la pelota...
	ld a,b			;a634
	cp h			;a635   ; ...ya esta en ella?
	jr nz,tiro_pon		;a636
	ld a,c			;a638
	cp l			;a639
	jr nz,tiro_pon		;a63a
	ld a,0c2h		;a63c   ; sin marca
	ld (0e170h),a		;a63e
	ret			;a641
tiro_pon:		; El sprite de la marca
	ld (0e170h),hl		;a642   ; la marca en la base...
	ld a,024h		;a645   ; ...dibujo 0x24
	ld (0e172h),a		;a647
tiro_color:		; El color de la marca, que parpadea
	ld a,(0e0a0h)		;a64a   ; la cuenta de cuadros...
	and 008h		;a64d   ; ...bit 3: parpadea
	ld a,(0e01fh)		;a64f
	jr z,tiro_color_pon		;a652
	ld a,001h		;a654   ; blanca o del equipo
tiro_color_pon:		; Guardado
	ld (0e173h),a		;a656
	ret			;a659
cubre_base:		; CY si hay quien cubra la base A (0xE055): C, el jugador de la defensa que la cubre (0xA668)
	ld b,004h		;a65a
	ld hl,0e055h		;a65c   ; los cuatro bits de las bases ocupadas
	ld d,(hl)			;a65f
base_ocupada_uno:		; Uno
	rrc d		;a660   ; el siguiente
	rrca			;a662   ; su bit
	jr c,$+13		;a663
	djnz base_ocupada_uno		;a665
	ret			;a667

; ----------------------------------------------------------------------
; DATOS cubren: El jugador de la defensa que cubre cada base: dos por base
;   0xa668..0xa670  (8 bytes)
DATA_cubren:
	defb 002h,003h,004h,005h,001h,001h,003h,005h	; a668  ........

; ======================================================================
; CODIGO 0xa670..0xa682  (18 bytes)
; ======================================================================


base_ocupada_si:		; Si: su casilla de la tabla 0xA668
	dec b			;a670   ; la base...
	sla b		;a671   ; ...por dos
	ld c,b			;a673
	ld b,000h		;a674
	ld hl,0a668h		;a676   ; en 0xA668
	add hl,bc			;a679
	bit 7,d		;a67a   ; ocupada?
	jr z,base_ocupada_fin		;a67c
	inc hl			;a67e
base_ocupada_fin:		; Fin
	ld c,(hl)			;a67f   ; su casilla
	scf			;a680   ; CY
	ret			;a681

; ----------------------------------------------------------------------
; DATOS bases_xy: La Y y la X de las cuatro bases
;   0xa682..0xa68a  (8 bytes)
DATA_bases_xy:
	defb 06ah,071h	; a682
	defb 0a0h,078h	; a684
	defb 085h,022h	; a686
	defb 085h,0cfh	; a688

; ======================================================================
; CODIGO 0xa68a..0xa8ad  (547 bytes)
; ======================================================================


tiro_vuela:		; El tiro: con el boton sale hacia la base; vuela; llega
	ld a,(0e054h)		;a68a
	bit 6,a		;a68d   ; bit 6: vuela
	jp nz,tiro_va		;a68f
	bit 5,a		;a692   ; bit 5: espera
	jp nz,tiro_fin		;a694
	bit 4,a		;a697   ; bit 4: elige
	ret z			;a699
	ld a,(0e258h)		;a69a   ; el boton del que esta en el campo?
	and 010h		;a69d
	ret z			;a69f
	ld a,0c2h		;a6a0   ; la pelota del campo, fuera
	ld (0e1ech),a		;a6a2
	ld a,002h		;a6a5   ; la pelota bateada, quieta
	ld (0e00bh),a		;a6a7
	ld a,020h		;a6aa   ; la pelota
	ld (0e009h),a		;a6ac
	ld a,(0e170h)		;a6af   ; hay base marcada?
	cp 0c2h		;a6b2
	jr nz,tiro_sale		;a6b4
	ld a,(0e054h)		;a6b6   ; no: espera
	and 09fh		;a6b9
	or 020h		;a6bb
	ld (0e054h),a		;a6bd
	ret			;a6c0
tiro_sale:		; Sale
	ld hl,(0e1a4h)		;a6c1   ; desde la pelota
	ld (0e05ah),hl		;a6c4
	ld hl,00000h		;a6c7   ; el camino a cero
	ld (0e05ch),hl		;a6ca
	xor a			;a6cd   ; las ordenes a cero
	ld (0e01ah),a		;a6ce
	ld a,(0e055h)		;a6d1   ; con las bases del jugador?
	bit 5,a		;a6d4
	jr z,tiro_sale_otro		;a6d6
	ld hl,0e055h		;a6d8
	res 5,(hl)		;a6db   ; ya no
	ld a,0c2h		;a6dd   ; los dos sprites del campo, fuera
	ld (0e164h),a		;a6df
	ld (0e168h),a		;a6e2
	ld a,(0e054h)		;a6e5   ; las bases de la jugada...
	and 00ch		;a6e8
	ld b,a			;a6ea
	ld a,(0e055h)		;a6eb   ; ...ocupadas?
	and b			;a6ee
	jr nz,tiro_sale_marca		;a6ef
	ld a,(0e055h)		;a6f1   ; sin bits de corredores
	and 0f1h		;a6f4
	ld (0e055h),a		;a6f6
tiro_sale_marca:		; Las bases
	ld bc,(0e05fh)		;a6f9   ; los dos jugadores...
	push bc			;a6fd
	ld b,000h		;a6fe
	call jugador_marca		;a700   ; ...se vuelven a pintar
	pop bc			;a703
	ld c,b			;a704
	ld b,000h		;a705
	call jugador_marca		;a707
	jr tiro_sale_va		;a70a
tiro_sale_otro:		; Otra
	ld a,(0e05eh)		;a70c   ; la base de antes...
	call cubre_base		;a70f   ; ...ocupada?
	jr nc,tiro_sale_va		;a712
	ld b,000h		;a714   ; se vuelve a pintar
	call jugador_marca		;a716
	ld a,(0e055h)		;a719   ; sin bits de corredores
	and 0f1h		;a71c
	ld (0e055h),a		;a71e
	jr tiro_sale_va		;a721
tiro_sale_va:		; La pelota hacia la base, con su sonido
	ld a,(0e054h)		;a723   ; la base marcada es el destino
	ld (0e05eh),a		;a726
	ld de,0e174h		;a729   ; la marca...
	ld hl,0e170h		;a72c   ; ...pasa a ser el jugador de la base
	ld bc,00004h		;a72f
	ldir		;a732
	ld a,(0e01fh)		;a734   ; con el color del equipo
	ld (0e177h),a		;a737
	ld b,001h		;a73a   ; el canal 1...
	ld de,0bf84h		;a73c   ; ...0xBF84
	call pieza		;a73f
	ld a,0c2h		;a742   ; la marca y el jugador, fuera
	ld (0e170h),a		;a744
	ld (0e16ch),a		;a747
	ld a,(0e054h)		;a74a   ; vuela
	and 09fh		;a74d
	or 040h		;a74f
	ld (0e054h),a		;a751
	ret			;a754
tiro_va:		; Vuela hasta la base (0xA7DF)
	ld a,0c2h		;a755
	ld (0e16ch),a		;a757   ; el jugador, fuera
	ld hl,(0e1a4h)		;a75a   ; desde donde esta
	ld (0e087h),hl		;a75d
	call distancia_casa		;a760   ; lejos de casa...
	cp 080h		;a763   ; ...menos de 0x80: el dibujo grande
	ld a,03ch		;a765
	jr c,tiro_va_pon		;a767
	ld a,038h		;a769   ; el pequeno
tiro_va_pon:		; Guardado
	ld (0e1a6h),a		;a76b
	ld hl,(0e05ah)		;a76e   ; desde la salida
	ld (0e085h),hl		;a771
	ld hl,(0e05ch)		;a774   ; el camino
	ld (0e089h),hl		;a777
	ld hl,(0e174h)		;a77a   ; hasta el jugador de la base
	ld (0e083h),hl		;a77d
	ld a,034h		;a780   ; velocidad 0x34
	ld (0e08bh),a		;a782
	call hacia		;a785   ; un paso
	ld hl,(0e087h)		;a788   ; guardado
	ld (0e1a4h),hl		;a78b
	ld hl,(0e089h)		;a78e
	ld (0e05ch),hl		;a791
	ld a,(0e08bh)		;a794   ; ha llegado?
	or a			;a797
	ret nz			;a798
	ld a,(0e025h)		;a799   ; hay cartel?
	rlca			;a79c
	jr c,tiro_llega		;a79d
	ld b,002h		;a79f   ; el canal 2...
	ld de,0bfa2h		;a7a1   ; ...0xBFA2
	call pieza		;a7a4
tiro_llega:		; Llega: el jugador de la base la tiene
	ld b,001h		;a7a7   ; el canal 1...
	ld de,0bfeeh		;a7a9   ; ...0xBFEE
	call pieza		;a7ac
	ld hl,0e01ah		;a7af   ; la orden...
	ld (hl),000h		;a7b2
	ld a,(0e05eh)		;a7b4   ; ...segun la base: primera...
	rrca			;a7b7
	jr nc,tiro_llega_2		;a7b8
	set 5,(hl)		;a7ba   ; ...a 0x20
tiro_llega_2:		; Segunda
	rrca			;a7bc   ; segunda...
	jr nc,tiro_llega_3		;a7bd
	set 7,(hl)		;a7bf   ; ...a 0x80
tiro_llega_3:		; Tercera
	rrca			;a7c1   ; tercera...
	jr nc,tiro_llega_4		;a7c2
	set 6,(hl)		;a7c4   ; ...a 0x40
tiro_llega_4:		; Casa
	rrca			;a7c6   ; casa...
	jr nc,tiro_llega_fin		;a7c7
	set 4,(hl)		;a7c9   ; ...a 0x10
tiro_llega_fin:		; Fin
	ld a,(0e054h)		;a7cb
	and 09fh		;a7ce   ; espera
	or 020h		;a7d0
	ld (0e054h),a		;a7d2
	ret			;a7d5
tiro_fin:		; Fin
	ld a,(0e054h)		;a7d6
	and 09fh		;a7d9   ; sin paso
	ld (0e054h),a		;a7db
	ret			;a7de
hacia:		; Un paso desde 0xE087 hacia 0xE083 (Y, X), con la velocidad 0xE08B: la distancia con raiz cuadrada; 0xE08B = 0 al llegar
	ld ix,0e083h		;a7df
	ld a,(ix+000h)		;a7e3   ; la Y del destino...
	sub (ix+002h)		;a7e6   ; ...menos la de salida...
	jr nc,hacia_dy		;a7e9
	neg		;a7eb   ; ...en valor absoluto
hacia_dy:		; La distancia en Y
	ld b,a			;a7ed
	ld a,(ix+001h)		;a7ee   ; la X del destino...
	sub (ix+003h)		;a7f1   ; ...menos la de salida...
	jr nc,hacia_dx		;a7f4
	neg		;a7f6   ; ...en valor absoluto
hacia_dx:		; En X
	ld c,a			;a7f8
	ld e,003h		;a7f9   ; entre 3
	ld l,b			;a7fb
	ld h,000h		;a7fc
	call divide		;a7fe   ; DY / 3
	ld l,c			;a801
	call hipotenusa		;a802   ; la longitud
	ld h,(ix+008h)		;a805   ; por la velocidad
	call multiplica		;a808
	push hl			;a80b
	ld h,b			;a80c   ; DY, DX
	ld l,c			;a80d
	call hipotenusa		;a80e   ; la longitud entera
	ld a,l			;a811
	ld e,l			;a812
	pop hl			;a813
	call divide		;a814   ; entre ella
	push af			;a817
	push hl			;a818
	ld hl,(0e087h)		;a819   ; donde esta
	call distancia_casa		;a81c   ; lejos de casa...
	ld hl,0a8adh		;a81f   ; ...su velocidad (0xA8AD)
	push bc			;a822
	call tabla4		;a823
	pop bc			;a826
	pop hl			;a827
	ld l,a			;a828
	call multiplica		;a829   ; por ella
	ld l,h			;a82c
	ld h,000h		;a82d
	add hl,hl			;a82f   ; por 4
	add hl,hl			;a830
	ld de,(0e089h)		;a831   ; mas el camino
	add hl,de			;a835
	ld (0e089h),hl		;a836   ; guardado
	pop af			;a839
	ld l,b			;a83a
	call multiplica		;a83b   ; por DY
	ld e,a			;a83e
	push af			;a83f
	call divide		;a840   ; entre la longitud
	ld a,(ix+002h)		;a843   ; la Y de salida...
	cp (ix+000h)		;a846   ; ...por encima o por debajo?
	jr nc,hacia_y_menos		;a849
	add a,h			;a84b   ; mas
	jr hacia_y_pon		;a84c
hacia_y_menos:		; La Y hacia arriba
	sub h			;a84e   ; menos
hacia_y_pon:		; Guardada
	ld (ix+004h),a		;a84f
	pop af			;a852
	ld hl,(0e089h)		;a853   ; el camino
	ld l,c			;a856
	call multiplica		;a857   ; por DX
	ld e,a			;a85a
	call divide		;a85b   ; entre la longitud
	ld a,(ix+003h)		;a85e   ; la X de salida...
	cp (ix+001h)		;a861   ; ...a un lado o al otro?
	jr nc,hacia_x_menos		;a864
	add a,h			;a866   ; mas
	jr hacia_x_pon		;a867
hacia_x_menos:		; La X hacia la izquierda
	sub h			;a869   ; menos
hacia_x_pon:		; Guardada
	ld (ix+005h),a		;a86a
	ld bc,00000h		;a86d   ; se ha pasado del destino en Y?
	ld a,(ix+000h)		;a870
	cp (ix+002h)		;a873
	rl b		;a876
	cp (ix+004h)		;a878
	rl c		;a87b
	ld a,b			;a87d   ; (los dos lados)
	xor c			;a87e
	jr nz,hacia_llega		;a87f   ; si
	ld bc,00000h		;a881   ; en X?
	ld a,(ix+001h)		;a884
	cp (ix+003h)		;a887
	rl b		;a88a
	cp (ix+005h)		;a88c
	rl c		;a88f
	ld a,b			;a891   ; (los dos lados)
	xor c			;a892
	ret z			;a893   ; no: sigue
hacia_llega:		; Ha llegado
	xor a			;a894
	ld (0e08bh),a		;a895   ; velocidad 0: ha llegado
	ret			;a898
hipotenusa:		; La raiz de H*H + L*L (0xACD6)
	push hl			;a899
	ld h,l			;a89a   ; L * L
	call multiplica		;a89b
	pop de			;a89e
	push hl			;a89f
	push de			;a8a0
	pop hl			;a8a1
	ld l,h			;a8a2   ; H * H
	call multiplica		;a8a3
	pop de			;a8a6
	add hl,de			;a8a7   ; la suma
	call raiz		;a8a8   ; su raiz
	inc hl			;a8ab   ; mas uno
	ret			;a8ac

; ----------------------------------------------------------------------
; DATOS velocidades: La velocidad segun la distancia a casa (0xACEE)
;   0xa8ad..0xa8b6  (9 bytes)
DATA_velocidades:
	defb 060h,06ch,078h,080h,0ffh,087h,04bh,032h,028h	; a8ad  `lx...K2(

; ======================================================================
; CODIGO 0xa8b6..0xa9ac  (246 bytes)
; ======================================================================


vram_girada:		; BC bytes de HL a la VRAM DE, cada uno girado (0xACA1) y con WRTVRM
	push af			;a8b6
vram_girada_uno:		; Uno
	call gira_byte		;a8b7   ; el byte girado
	ex de,hl			;a8ba
	call 0004dh		;a8bb   ; WRTVRM
	ex de,hl			;a8be
	inc de			;a8bf   ; el siguiente
	inc hl			;a8c0
	dec bc			;a8c1   ; BC bytes
	ld a,b			;a8c2
	or c			;a8c3
	jr nz,vram_girada_uno		;a8c4
	pop af			;a8c6
	ret			;a8c7
mandos:		; Los dos mandos: el teclado (filas 3, 5, 6 y 7), GTSTCK y GTTRIG, en 0xE08C (el 1) y 0xE08E (el 2), con lo recien pulsado detras
	ld bc,00000h		;a8c8   ; B el mando 1, C el mando 2
	ld a,003h		;a8cb   ; la fila 3 del teclado
	call snsmat		;a8cd
	bit 1,a		;a8d0   ; la D...
	jr nz,mandos_e		;a8d2
	set 3,c		;a8d4   ; ...derecha del 2
mandos_e:		; La E: arriba del 2
	bit 2,a		;a8d6   ; la E...
	jr nz,mandos_f5		;a8d8
	set 0,c		;a8da   ; ...arriba del 2
mandos_f5:		; La fila 5: la S, izquierda del 2
	ld a,005h		;a8dc   ; la fila 5
	call snsmat		;a8de
	bit 0,a		;a8e1   ; la S...
	jr nz,mandos_f5b		;a8e3
	set 2,c		;a8e5   ; ...izquierda del 2
mandos_f5b:		; La X: abajo del 2
	bit 5,a		;a8e7   ; la X...
	jr nz,mandos_cursores		;a8e9
	set 1,c		;a8eb   ; ...abajo del 2
mandos_cursores:		; Los cursores (GTSTCK 0)
	ld a,000h		;a8ed   ; los cursores
	call stick		;a8ef
	ld b,a			;a8f2   ; al mando 1
	ld a,006h		;a8f3   ; la fila 6
	call snsmat		;a8f5
	bit 1,a		;a8f8   ; CTRL...
	jr nz,mandos_f7		;a8fa
	set 4,c		;a8fc   ; ...boton del 2
mandos_f7:		; La fila 7: TAB, el boton 2 del 2
	ld a,007h		;a8fe   ; la fila 7
	call snsmat		;a900
	bit 3,a		;a903   ; TAB...
	jr nz,mandos_f7b		;a905
	set 5,c		;a907   ; ...boton 2 del 2
mandos_f7b:		; BS: el boton 2 del 1
	bit 5,a		;a909   ; BS...
	jr nz,mandos_f7c		;a90b
	set 5,b		;a90d   ; ...boton 2 del 1
mandos_f7c:		; RETURN: el boton 1 del 1
	bit 7,a		;a90f   ; RETURN...
	jr nz,mandos_joy1		;a911
	set 4,b		;a913   ; ...boton del 1
mandos_joy1:		; El mando 1
	ld a,001h		;a915   ; el mando 1 (GTSTCK 1)
	call stick		;a917
	or a			;a91a
	jr z,mandos_joy2		;a91b   ; nada?
	ld d,a			;a91d
	ld a,b			;a91e   ; con los botones de antes
	and 0f0h		;a91f
	or d			;a921
	ld b,a			;a922
mandos_joy2:		; El mando 2
	ld a,002h		;a923   ; el mando 2 (GTSTCK 2)
	call stick		;a925
	or a			;a928
	jr z,mandos_gatillos		;a929   ; nada?
	ld d,a			;a92b
	ld a,c			;a92c   ; con los botones de antes
	and 0f0h		;a92d
	or d			;a92f
	ld c,a			;a930
mandos_gatillos:		; Los gatillos (GTTRIG 1 a 4)
	ld a,001h		;a931   ; GTTRIG 1: el boton del mando 1
	push bc			;a933
	call 000d8h		;a934
	pop bc			;a937
	or a			;a938
	jr z,mandos_gatillo2		;a939
	set 4,b		;a93b   ; al 1
mandos_gatillo2:		; El 2
	ld a,002h		;a93d   ; GTTRIG 2: el del mando 2
	push bc			;a93f
	call 000d8h		;a940
	pop bc			;a943
	or a			;a944
	jr z,mandos_gatillo3		;a945
	set 4,c		;a947   ; al 2
mandos_gatillo3:		; El 3
	ld a,003h		;a949   ; GTTRIG 3: el segundo boton del mando 1
	push bc			;a94b
	call 000d8h		;a94c
	pop bc			;a94f
	or a			;a950
	jr z,mandos_gatillo4		;a951
	set 5,b		;a953   ; al 1
mandos_gatillo4:		; El 4
	ld a,004h		;a955   ; GTTRIG 4: el del mando 2
	push bc			;a957
	call 000d8h		;a958
	pop bc			;a95b
	or a			;a95c
	jr z,mandos_barra		;a95d
	set 5,c		;a95f   ; al 2
mandos_barra:		; Contra el ordenador, la barra y GRAPH son tambien los botones del primero
	ld a,(0e006h)		;a961   ; dos jugadores?
	bit 7,a		;a964
	jr nz,mandos_guarda		;a966
	xor a			;a968   ; GTTRIG 0: la barra...
	push bc			;a969
	call 000d8h		;a96a
	pop bc			;a96d
	or a			;a96e
	jr z,mandos_graph		;a96f
	set 4,b		;a971   ; ...el boton del 1
mandos_graph:		; La fila 6
	ld a,006h		;a973
	call snsmat		;a975   ; la fila 6...
	bit 2,a		;a978   ; ...GRAPH?
	jr nz,mandos_guarda		;a97a
	set 5,b		;a97c   ; el boton 2 del 1
mandos_guarda:		; Guarda y lo recien pulsado
	ld hl,0e08ch		;a97e
	ld a,(hl)			;a981   ; el de antes...
	ld (hl),b			;a982   ; ...el nuevo...
	cpl			;a983   ; ...lo recien pulsado
	and b			;a984
	inc hl			;a985
	ld (hl),a			;a986   ; guardado
	ld hl,0e08eh		;a987
	ld a,(hl)			;a98a   ; el de antes...
	ld (hl),c			;a98b   ; ...el nuevo...
	cpl			;a98c   ; ...lo recien pulsado
	and c			;a98d
	inc hl			;a98e
	ld (hl),a			;a98f   ; guardado
	ld a,(0e006h)		;a990   ; dos jugadores?
	rlca			;a993
	ret c			;a994
	ld hl,0e08ch		;a995   ; contra el ordenador, el mando 1 lleva tambien...
	ld a,(0e08eh)		;a998
	or (hl)			;a99b   ; ...con lo del 2
	ld (hl),a			;a99c
	ret			;a99d
stick:		; GTSTCK A en los bits del juego (0xA9AC)
	push bc			;a99e
	call 000d5h		;a99f   ; GTSTCK
	ld c,a			;a9a2
	ld b,000h		;a9a3
	ld hl,0a9ach		;a9a5   ; la tabla
	add hl,bc			;a9a8
	ld a,(hl)			;a9a9   ; los bits
	pop bc			;a9aa
	ret			;a9ab

; ----------------------------------------------------------------------
; DATOS direcciones: De GTSTCK (0-8) a los bits del juego
;   0xa9ac..0xa9b5  (9 bytes)
DATA_direcciones:
	defb 000h,001h,009h,008h,00ah,002h,006h,004h,005h	; a9ac  .........

; ======================================================================
; CODIGO 0xa9b5..0xaa35  (128 bytes)
; ======================================================================


snsmat:		; SNSMAT
	push bc			;a9b5
	call 00141h		;a9b6   ; SNSMAT
	pop bc			;a9b9
	ret			;a9ba
dibujos:		; Los dibujos del campo: los de 0xADB5 y 0xAE85 (girado), a los tres tercios
	ld d,000h		;a9bb
	ld bc,00180h		;a9bd   ; 0x180 bytes...
	ld hl,0e600h		;a9c0   ; ...desde 0xE600...
dibujos_borra:		; La RAM a cero
	ld (hl),d			;a9c3   ; ...a cero
	inc hl			;a9c4
	dec bc			;a9c5
	ld a,b			;a9c6
	or c			;a9c7
	jr nz,dibujos_borra		;a9c8
	ld bc,00500h		;a9ca   ; 0x500 bytes desde 0xE900...
	ld hl,0e900h		;a9cd
dibujos_borra2:		; Otra
	ld (hl),d			;a9d0   ; ...a cero
	inc hl			;a9d1
	dec bc			;a9d2
	ld a,b			;a9d3
	or c			;a9d4
	jr nz,dibujos_borra2		;a9d5
	ld de,0e650h		;a9d7   ; a 0xE650...
	ld hl,0adb5h		;a9da   ; ...los dibujos de 0xADB5...
	ld bc,000d0h		;a9dd   ; ...0xD0 bytes
	ldir		;a9e0
	ld de,0e900h		;a9e2   ; a 0xE900...
	ld hl,0ae85h		;a9e5   ; ...los de 0xAE85...
	ld bc,00190h		;a9e8   ; ...0x190 bytes
	ldir		;a9eb
	ld de,0eb00h		;a9ed   ; y a 0xEB00...
	ld hl,0ae85h		;a9f0
	ld bc,00190h		;a9f3   ; ...girados
	call copia_girada		;a9f6
	ld b,003h		;a9f9   ; tres tercios
	ld de,00000h		;a9fb   ; desde 0x0000
dibujos_tercio:		; Un tercio
	push bc			;a9fe
	push de			;a9ff
	ld bc,00800h		;aa00   ; 2 KB...
	ld hl,0e600h		;aa03   ; ...de 0xE600
	call 0005ch		;aa06   ; LDIRVM
	pop de			;aa09
	ld hl,00800h		;aa0a   ; el tercio siguiente
	add hl,de			;aa0d
	ex de,hl			;aa0e
	pop bc			;aa0f
	djnz dibujos_tercio		;aa10
	ld de,00100h		;aa12   ; a 0x0100...
	ld hl,08511h		;aa15   ; ...los de 0x8511...
	ld bc,00080h		;aa18   ; ...0x80 bytes
	jp 0005ch		;aa1b
sprites_carga:		; Los sprites: 0xAA35 a 0x3800 y nueve girados a 0x3C00
	ld hl,0aa35h		;aa1e
	ld de,03800h		;aa21   ; a 0x3800
	ld bc,00260h		;aa24   ; 0x260 bytes
	call 0005ch		;aa27
	ld hl,0aa45h		;aa2a   ; desde 0xAA45...
	ld de,03c00h		;aa2d   ; ...a 0x3C00...
	ld a,009h		;aa30   ; ...nueve bloques girados
	jp gira_bloque		;aa32

; ----------------------------------------------------------------------
; DATOS sprites_dibujos: Los dibujos de los sprites (0x260 bytes a 0x3800;
;   desde 0xAA45, girados a 0x3C00)
;   0xaa35..0xac95  (608 bytes)
DATA_sprites_dibujos:
	defb 000h,000h,000h,000h,003h,007h,00dh,009h	; aa35  ........
	defb 003h,003h,001h,003h,003h,003h,006h,004h	; aa3d  ........
	defb 000h,000h,0c0h,0e0h,0c0h,0e0h,0f0h,0d8h	; aa45  ........
	defb 080h,0c0h,0c0h,080h,000h,000h,000h,000h	; aa4d  ........
	defb 000h,000h,000h,000h,003h,007h,007h,001h	; aa55  ........
	defb 003h,003h,003h,003h,006h,00ch,008h,000h	; aa5d  ........
	defb 000h,000h,0c0h,0e0h,0c0h,0c0h,0c0h,0f0h	; aa65  ........
	defb 0a0h,0c0h,060h,020h,030h,020h,000h,000h	; aa6d  ..` 0 ..
	defb 000h,000h,000h,000h,002h,003h,000h,000h	; aa75  ........
	defb 003h,007h,01dh,008h,000h,000h,000h,000h	; aa7d  ........
	defb 000h,000h,030h,070h,030h,0f8h,0fch,07eh	; aa85  ..0p0..~
	defb 0f2h,0e2h,080h,0c0h,040h,000h,000h,000h	; aa8d  ....@...
	defb 000h,000h,000h,000h,003h,001h,027h,03fh	; aa95  ......'?
	defb 003h,006h,00ch,000h,000h,000h,000h,000h	; aa9d  ........
	defb 000h,000h,030h,070h,030h,0f8h,0fch,0feh	; aaa5  ..0p0...
	defb 0f2h,0e2h,000h,000h,000h,000h,000h,000h	; aaad  ........
	defb 000h,000h,003h,003h,007h,00fh,00fh,00dh	; aab5  ........
	defb 00fh,03ch,020h,000h,000h,000h,000h,000h	; aabd  .< .....
	defb 000h,060h,0f0h,0e0h,0f0h,0d8h,078h,000h	; aac5  .`....x.
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; aacd  ........
	defb 000h,000h,000h,000h,030h,01ch,0c7h,073h	; aad5  ....0..s
	defb 01fh,007h,000h,000h,000h,000h,000h,000h	; aadd  ........
	defb 000h,000h,000h,000h,000h,000h,018h,0f8h	; aae5  ........
	defb 0feh,0f3h,070h,03eh,000h,000h,000h,000h	; aaed  ..p>....
	defb 000h,000h,000h,000h,001h,001h,007h,00fh	; aaf5  ........
	defb 019h,013h,003h,003h,002h,006h,004h,004h	; aafd  ........
	defb 000h,000h,000h,000h,080h,080h,0e0h,0f0h	; ab05  ........
	defb 0d8h,0e8h,0e0h,060h,060h,030h,010h,010h	; ab0d  ...``0..
	defb 000h,000h,001h,003h,001h,001h,003h,007h	; ab15  ........
	defb 00ch,000h,000h,001h,001h,001h,001h,003h	; ab1d  ........
	defb 000h,000h,080h,080h,0e0h,0f0h,0e8h,0f0h	; ab25  ........
	defb 0e0h,070h,0f0h,0d0h,098h,00ch,004h,000h	; ab2d  .p......
	defb 000h,000h,001h,003h,001h,001h,003h,007h	; ab35  ........
	defb 00ch,009h,001h,003h,003h,002h,002h,006h	; ab3d  ........
	defb 000h,000h,080h,080h,0c0h,0e0h,0e0h,0e0h	; ab45  ........
	defb 0c0h,0e0h,0e0h,060h,070h,018h,008h,000h	; ab4d  ...`p...
	defb 000h,000h,000h,000h,001h,001h,007h,00fh	; ab55  ........
	defb 00bh,009h,003h,003h,003h,007h,004h,000h	; ab5d  ........
	defb 000h,000h,018h,018h,090h,090h,0f0h,0e0h	; ab65  ........
	defb 0c0h,080h,0c0h,0e0h,060h,060h,020h,030h	; ab6d  ....`` 0
	defb 000h,000h,001h,003h,001h,001h,00bh,00fh	; ab75  ........
	defb 005h,003h,007h,005h,003h,001h,000h,001h	; ab7d  ........
	defb 000h,000h,080h,080h,080h,0c0h,0c0h,0c0h	; ab85  ........
	defb 080h,0c0h,0c0h,080h,080h,080h,080h,080h	; ab8d  ........
	defb 000h,000h,000h,000h,001h,011h,01fh,00fh	; ab95  ........
	defb 003h,003h,007h,007h,006h,00ch,008h,000h	; ab9d  ........
	defb 000h,000h,000h,000h,080h,080h,0e0h,0f0h	; aba5  ........
	defb 0b0h,0e0h,0e0h,0c0h,0c0h,040h,040h,0c0h	; abad  .....@@.
	defb 000h,000h,000h,000h,000h,001h,001h,003h	; abb5  ........
	defb 007h,007h,00fh,00fh,01dh,011h,001h,001h	; abbd  ........
	defb 000h,000h,000h,000h,000h,080h,0e0h,0f8h	; abc5  ........
	defb 0d8h,080h,080h,0c0h,080h,080h,000h,080h	; abcd  ........
	defb 000h,000h,000h,000h,000h,000h,000h,001h	; abd5  ........
	defb 001h,000h,000h,000h,000h,000h,000h,000h	; abdd  ........
	defb 000h,000h,000h,000h,000h,000h,000h,080h	; abe5  ........
	defb 080h,000h,000h,000h,000h,000h,000h,000h	; abed  ........
	defb 000h,000h,000h,000h,000h,000h,000h,001h	; abf5  ........
	defb 001h,000h,000h,000h,000h,000h,000h,000h	; abfd  ........
	defb 000h,000h,000h,000h,000h,000h,080h,0c0h	; ac05  ........
	defb 0c0h,080h,000h,000h,000h,000h,000h,000h	; ac0d  ........
	defb 000h,000h,000h,000h,000h,000h,001h,003h	; ac15  ........
	defb 003h,001h,000h,000h,000h,000h,000h,000h	; ac1d  ........
	defb 000h,000h,000h,000h,000h,000h,080h,0c0h	; ac25  ........
	defb 0c0h,080h,000h,000h,000h,000h,000h,000h	; ac2d  ........
	defb 000h,000h,000h,000h,000h,001h,003h,003h	; ac35  ........
	defb 003h,001h,000h,000h,000h,000h,000h,000h	; ac3d  ........
	defb 000h,000h,000h,000h,000h,0c0h,0e0h,0e0h	; ac45  ........
	defb 0e0h,0c0h,000h,000h,000h,000h,000h,000h	; ac4d  ........
	defb 000h,000h,000h,003h,00fh,00fh,01fh,01fh	; ac55  ........
	defb 01fh,01fh,00fh,00fh,003h,000h,000h,000h	; ac5d  ........
	defb 000h,000h,000h,0c0h,0f0h,0f0h,0f8h,0f8h	; ac65  ........
	defb 0f8h,0f8h,0f0h,0f0h,0c0h,000h,000h,000h	; ac6d  ........
	defb 000h,000h,000h,00ch,008h,000h,000h,003h	; ac75  ........
	defb 000h,000h,008h,00ch,000h,000h,000h,000h	; ac7d  ........
	defb 000h,000h,000h,018h,008h,080h,080h,0c0h	; ac85  ........
	defb 080h,080h,008h,018h,000h,000h,000h,000h	; ac8d  ........

; ======================================================================
; CODIGO 0xac95..0xad75  (224 bytes)
; ======================================================================


copia_girada:		; BC bytes de HL a DE, cada uno girado
	call gira_byte		;ac95   ; girado
	ld (de),a			;ac98   ; guardado
	inc hl			;ac99
	inc de			;ac9a
	dec bc			;ac9b   ; BC bytes
	ld a,b			;ac9c
	or c			;ac9d
	jr nz,copia_girada		;ac9e
	ret			;aca0
gira_byte:		; A = el byte (HL) dado la vuelta (bit 0 al 7)
	push bc			;aca1
	ld b,008h		;aca2   ; ocho bits
	ld c,(hl)			;aca4   ; el byte
gira_byte_bit:		; Un bit
	rrc c		;aca5   ; el bit de la derecha...
	rla			;aca7   ; ...a la izquierda de A
	djnz gira_byte_bit		;aca8
	pop bc			;acaa
	ret			;acab
multiplica:		; HL = H * L
	ld d,000h		;acac
	ld e,l			;acae   ; E = L
	ld l,d			;acaf   ; HL = H x 256
	push bc			;acb0
	ld b,008h		;acb1   ; ocho bits
multiplica_bit:		; Un bit
	add hl,hl			;acb3   ; el bit de arriba de H...
	jr nc,multiplica_sig		;acb4
	add hl,de			;acb6   ; ...suma L
multiplica_sig:		; El siguiente
	djnz multiplica_bit		;acb7
	pop bc			;acb9
	ret			;acba
divide:		; H = HL / E (y el resto)
	push af			;acbb
	push bc			;acbc
	ld b,008h		;acbd   ; ocho bits
	xor a			;acbf
divide_bit:		; Un bit
	adc hl,hl		;acc0   ; el bit de arriba de HL
	ld a,h			;acc2   ; la parte alta...
	jr c,divide_resta		;acc3
	cp e			;acc5   ; ...cabe E?
	jr c,divide_sig		;acc6
divide_resta:		; Resta
	sub e			;acc8   ; resta
	ld h,a			;acc9
	xor a			;acca
divide_sig:		; El siguiente
	ccf			;accb   ; el bit del cociente
	djnz divide_bit		;accc
	rl l		;acce   ; el ultimo
	ld a,h			;acd0   ; H el cociente, L el resto
	ld h,l			;acd1
	ld l,a			;acd2
	pop bc			;acd3
	pop af			;acd4
	ret			;acd5
raiz:		; HL = la raiz cuadrada de HL
	push bc			;acd6
	ld bc,00000h		;acd7   ; la cuenta
	scf			;acda   ; el primer impar: 1
raiz_resta:		; Restando los impares
	sbc hl,bc		;acdb   ; resta el impar...
	jr c,raiz_fin		;acdd
	sbc hl,bc		;acdf   ; ...y el siguiente
	jr c,raiz_fin		;ace1
	inc bc			;ace3   ; uno mas
	jr raiz_resta		;ace4
raiz_fin:		; Fin
	push bc			;ace6   ; la cuenta, en HL
	pop hl			;ace7
	pop bc			;ace8
	ret			;ace9
tabla6:		; A en una tabla de 6 tramos: el valor del tramo
	ld b,006h		;acea
	jr tabla_busca		;acec
tabla4:		; A en una tabla de 4 tramos
	ld b,004h		;acee
tabla_busca:		; Busca el tramo
	push hl			;acf0
	ld c,b			;acf1   ; C = B (el valor del tramo, B mas alla)
tabla_busca_uno:		; Uno
	cp (hl)			;acf2   ; A antes de este tope?
	jr c,tabla_valor		;acf3
	inc c			;acf5   ; el tramo siguiente
	inc hl			;acf6
	djnz tabla_busca_uno		;acf7
tabla_valor:		; Su valor
	ld b,000h		;acf9
	pop hl			;acfb
	add hl,bc			;acfc   ; el valor
	ld a,(hl)			;acfd
	ret			;acfe
campo_nombres:		; La tabla de nombres del campo (0xB015, 768 bytes)
	ld de,01800h		;acff
	ld hl,0b015h		;ad02   ; desde 0xB015...
	ld bc,00300h		;ad05   ; ...768 bytes
	jp 0005ch		;ad08
campo_colores:		; Los colores del campo: siete colores de 8 filas (0xAD75) y franjas (0xAD7C, 0xAD8F, 0xADA2)
	ld b,007h		;ad0b   ; siete...
	ld de,0ad75h		;ad0d   ; ...colores de 0xAD75...
	ld hl,0e600h		;ad10   ; ...en 0xE600
campo_colores_uno:		; Uno
	push bc			;ad13
	ld a,(de)			;ad14   ; un color...
	inc de			;ad15
	ld b,008h		;ad16   ; ...ocho veces
campo_colores_fila:		; Una fila
	ld (hl),a			;ad18
	inc hl			;ad19
	djnz campo_colores_fila		;ad1a
	pop bc			;ad1c
	djnz campo_colores_uno		;ad1d
	ld d,0f1h		;ad1f   ; el resto: 0xF1...
	ld hl,0e650h		;ad21
	ld bc,007b0h		;ad24   ; ...0x7B0 bytes
campo_colores_relleno:		; El resto, 0xF1
	ld (hl),d			;ad27
	inc hl			;ad28
	dec bc			;ad29
	ld a,b			;ad2a
	or c			;ad2b
	jr nz,campo_colores_relleno		;ad2c
	ld ix,0ad7ch		;ad2e   ; las franjas de 0xAD7C...
	ld hl,0e900h		;ad32   ; ...en 0xE900
	call franjas		;ad35
	ld ix,0ad8fh		;ad38   ; las de 0xAD8F...
	ld hl,0eb00h		;ad3c   ; ...en 0xEB00
	call franjas		;ad3f
	ld b,003h		;ad42   ; tres tercios
	ld de,02000h		;ad44   ; desde 0x2000
campo_colores_tercio:		; A los tres tercios
	push bc			;ad47
	push de			;ad48
	ld bc,00800h		;ad49   ; 2 KB...
	ld hl,0e600h		;ad4c   ; ...de 0xE600
	call 0005ch		;ad4f   ; LDIRVM
	pop de			;ad52
	ld hl,00800h		;ad53   ; el tercio siguiente
	add hl,de			;ad56
	ex de,hl			;ad57
	pop bc			;ad58
	djnz campo_colores_tercio		;ad59
	ret			;ad5b
franjas:		; Las franjas de color: 19 tramos (IY las longitudes, IX los colores)
	ld iy,0ada2h		;ad5c   ; las longitudes
	ld b,013h		;ad60   ; 19 tramos
franjas_uno:		; Uno
	push bc			;ad62
	ld b,(iy+000h)		;ad63   ; la longitud...
	ld a,(ix+000h)		;ad66   ; ...y el color
franjas_byte:		; Un byte
	ld (hl),a			;ad69   ; un byte
	inc hl			;ad6a
	djnz franjas_byte		;ad6b
	inc ix		;ad6d   ; el siguiente
	inc iy		;ad6f
	pop bc			;ad71
	djnz franjas_uno		;ad72
	ret			;ad74

; ----------------------------------------------------------------------
; DATOS campo_colores_tablas: Los siete colores de las primeras casillas, las
;   dos franjas de colores (19 cada una) y sus longitudes (19)
;   0xad75..0xadb5  (64 bytes)
DATA_campo_colores_tablas:
	defb 000h,0cch,066h,022h,044h,077h,011h,0c6h,06fh,041h,071h,026h,041h,071h,041h,0f1h	; ad75  ..f"Dw..oAq&AqA.
	defb 042h,041h,071h,041h,071h,041h,071h,041h,071h,0f6h,0c6h,06fh,041h,091h,026h,041h	; ad85  BAqAqAqAq..oA.&A
	defb 091h,041h,0f1h,042h,041h,091h,041h,091h,041h,091h,041h,091h,0f6h,028h,078h,003h	; ad95  .A.BA.A.A.A..(x.
	defb 005h,018h,006h,002h,008h,020h,050h,008h,004h,00ch,004h,00ch,002h,006h,010h,008h	; ada5  ..... P.........

; ----------------------------------------------------------------------
; DATOS campo_casillas: Los dibujos de 26 casillas del campo (a 0xE650)
;   0xadb5..0xae85  (208 bytes)
DATA_campo_casillas:
	defb 000h,020h,0fch,024h,024h,044h,044h,0c6h	; adb5  . .$$DD.
	defb 000h,02ah,02ah,0feh,02ah,02ah,02ah,06ah	; adbd  .**.***j
	defb 000h,010h,0feh,0aah,0bah,092h,0aah,0a6h	; adc5  ........
	defb 000h,010h,0feh,07ch,054h,07ch,054h,092h	; adcd  ...|T|T.
	defb 000h,044h,008h,0deh,054h,054h,044h,0feh	; add5  .D..TTD.
	defb 000h,02ah,04ch,02ah,048h,0feh,06ch,066h	; addd  .*L*H.lf
	defb 000h,028h,028h,0eah,02ch,028h,048h,08eh	; ade5  .((.,(H.
	defb 000h,010h,0feh,092h,092h,0feh,010h,010h	; aded  ........
	defb 000h,0feh,0bah,092h,0bah,096h,0bah,0feh	; adf5  ........
	defb 000h,0d0h,03eh,0c0h,03eh,06ah,03eh,0c2h	; adfd  ..>.>j>.
	defb 000h,0feh,0aah,0aah,0aah,0c6h,082h,0feh	; ae05  ........
	defb 000h,020h,0feh,05ah,0fch,07ah,05eh,078h	; ae0d  . .Z.z^x
	defb 000h,0e8h,0beh,0d4h,0beh,0a8h,0d4h,0beh	; ae15  ........
	defb 000h,054h,03eh,0c8h,054h,05ch,054h,0feh	; ae1d  .T>.T\T.
	defb 020h,020h,0e0h,000h,000h,000h,001h,001h	; ae25    ......
	defb 004h,004h,007h,000h,000h,000h,080h,080h	; ae2d  ........
	defb 007h,00fh,00bh,003h,007h,007h,004h,00ch	; ae35  ........
	defb 0e0h,0f0h,0f0h,0c0h,0e0h,0e0h,040h,030h	; ae3d  ......@0
	defb 000h,000h,000h,000h,001h,001h,003h,007h	; ae45  ........
	defb 000h,000h,000h,000h,080h,080h,0e0h,0e0h	; ae4d  ........
	defb 00fh,009h,00bh,007h,006h,006h,004h,00ch	; ae55  ........
	defb 0f0h,098h,0d8h,0e0h,060h,060h,020h,030h	; ae5d  ....`` 0
	defb 000h,000h,000h,000h,001h,001h,003h,007h	; ae65  ........
	defb 000h,000h,000h,000h,080h,080h,0e0h,0e0h	; ae6d  ........
	defb 00fh,009h,00bh,007h,006h,006h,004h,00ch	; ae75  ........
	defb 0f0h,098h,0d8h,0e0h,060h,060h,020h,030h	; ae7d  ....`` 0

; ----------------------------------------------------------------------
; DATOS campo_casillas2: Los de 50 casillas mas (a 0xE900, y dados la vuelta a
;   0xEB00)
;   0xae85..0xb015  (400 bytes)
DATA_campo_casillas2:
	defb 000h,000h,000h,000h,000h,003h,01fh,0ffh	; ae85  ........
	defb 000h,000h,001h,00fh,07fh,0ffh,0ffh,0ffh	; ae8d  ........
	defb 007h,03fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ae95  .?......
	defb 001h,001h,001h,003h,003h,003h,007h,007h	; ae9d  ........
	defb 007h,00fh,00fh,00fh,01fh,01fh,01fh,03fh	; aea5  .......?
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0fch,0e3h,01fh	; aead  ........
	defb 0ffh,0ffh,0feh,0f1h,08fh,07fh,0ffh,0ffh	; aeb5  ........
	defb 0f8h,0c7h,03fh,0ffh,0ffh,0ffh,0ffh,0ffh	; aebd  ..?.....
	defb 0f8h,0fbh,0fbh,00bh,00bh,00bh,003h,03bh	; aec5  .......;
	defb 00fh,0efh,0eeh,0e1h,0efh,0efh,0f7h,0f7h	; aecd  ........
	defb 0fbh,0fbh,0f8h,0ffh,0ffh,0ffh,0ffh,0ffh	; aed5  ........
	defb 0f7h,0f7h,007h,0ffh,0ffh,0ffh,0ffh,0ffh	; aedd  ........
	defb 00fh,0f0h,0c0h,000h,000h,0c0h,0f0h,00fh	; aee5  ........
	defb 0ffh,0ffh,03eh,001h,00fh,03fh,0ffh,0ffh	; aeed  ..>..?..
	defb 01fh,003h,000h,01fh,0ffh,0ffh,0ffh,0ffh	; aef5  ........
	defb 000h,000h,000h,000h,000h,003h,00fh,03fh	; aefd  .......?
	defb 0c0h,0dfh,0dfh,0dfh,0dfh,0dfh,0dfh,0dfh	; af05  ........
	defb 000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; af0d  ........
	defb 03fh,0cfh,0f3h,0fch,0ffh,0ffh,0ffh,0ffh	; af15  ?.......
	defb 0ffh,0ffh,0ffh,0ffh,03fh,0cfh,0f3h,0fch	; af1d  ....?...
	defb 0ffh,01fh,003h,0cch,0fch,033h,0cfh,0cch	; af25  .....3..
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fch,0e0h	; af2d  ........
	defb 0ffh,0ffh,0ffh,0feh,0f0h,080h,000h,000h	; af35  ........
	defb 0ffh,0f8h,0c0h,000h,000h,000h,000h,000h	; af3d  ........
	defb 0ffh,0ffh,0ffh,07fh,00fh,001h,066h,066h	; af45  ......ff
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,03fh,007h	; af4d  ......?.
	defb 0f0h,010h,010h,010h,010h,010h,010h,010h	; af55  ........
	defb 0ffh,001h,001h,001h,001h,001h,001h,001h	; af5d  ........
	defb 0ffh,000h,000h,000h,000h,000h,000h,000h	; af65  ........
	defb 080h,080h,080h,080h,080h,080h,080h,080h	; af6d  ........
	defb 03fh,00fh,003h,000h,000h,000h,000h,000h	; af75  ?.......
	defb 0ffh,0ffh,0ffh,0ffh,03fh,00fh,003h,000h	; af7d  ....?...
	defb 03fh,01fh,007h,003h,000h,000h,000h,000h	; af85  ?.......
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,07fh,01fh,00fh	; af8d  ........
	defb 003h,001h,000h,000h,000h,000h,000h,000h	; af95  ........
	defb 0ffh,0ffh,07fh,03fh,00fh,007h,001h,000h	; af9d  ...?....
	defb 0ffh,07fh,07fh,03fh,01fh,01fh,00fh,007h	; afa5  ...?....
	defb 007h,003h,003h,001h,000h,000h,000h,000h	; afad  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,03fh	; afb5  .......?
	defb 03fh,01fh,00fh,00fh,007h,003h,003h,001h	; afbd  ?.......
	defb 0c0h,0f0h,0fch,0ffh,0ffh,0ffh,0ffh,0ffh	; afc5  ........
	defb 0c6h,0c6h,01bh,01bh,0c0h,0f0h,0fch,0ffh	; afcd  ........
	defb 0c0h,0e0h,0f8h,0fch,0ffh,0ffh,0ffh,0ffh	; afd5  ........
	defb 0dbh,0dbh,060h,07bh,01bh,080h,0e0h,0f0h	; afdd  ..`{....
	defb 0fch,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; afe5  ........
	defb 033h,033h,080h,0c0h,0f0h,0fch,0feh,0ffh	; afed  33......
	defb 01bh,0dbh,0c0h,033h,03fh,0cch,0f3h,033h	; aff5  ...3?..3
	defb 0c6h,0f6h,033h,03fh,0fch,030h,0dbh,0dbh	; affd  ..3?.0..
	defb 000h,000h,000h,00fh,000h,000h,000h,000h	; b005  ........
	defb 000h,038h,07ch,07ch,07ch,038h,000h,000h	; b00d  .8|||8..

; ----------------------------------------------------------------------
; DATOS campo_mapa: La tabla de nombres del campo: 24 filas de 32
;   0xb015..0xb315  (768 bytes)
DATA_campo_mapa:
	defb 005h,005h,005h,005h,005h,005h,005h,005h,005h,005h,003h,003h,003h,075h,076h,077h,0b7h,0b6h,0b5h,003h,003h,003h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h	; b015  .............uvw................
	defb 005h,006h,006h,006h,006h,006h,006h,006h,006h,005h,075h,076h,077h,002h,002h,002h,002h,002h,002h,0b7h,0b6h,0b5h,005h,005h,005h,005h,005h,005h,005h,005h,005h,005h	; b035  ..........uvw...................
	defb 005h,006h,006h,006h,006h,006h,006h,006h,006h,005h,002h,002h,002h,002h,002h,090h,0d0h,002h,002h,002h,002h,002h,005h,006h,006h,006h,006h,006h,006h,006h,006h,005h	; b055  ................................
	defb 005h,006h,006h,006h,006h,006h,006h,006h,006h,005h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,005h,006h,006h,006h,006h,006h,006h,006h,006h,005h	; b075  ................................
	defb 005h,006h,006h,006h,006h,006h,006h,006h,006h,005h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,005h,006h,006h,006h,006h,006h,006h,006h,006h,005h	; b095  ................................
	defb 005h,006h,006h,006h,006h,006h,006h,006h,006h,004h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,004h,006h,053h,006h,006h,006h,006h,006h,006h,005h	; b0b5  ........................S.......
	defb 004h,006h,006h,006h,006h,006h,006h,006h,006h,004h,002h,0b3h,0b2h,0b1h,0b0h,0afh,06fh,070h,071h,072h,073h,002h,004h,006h,042h,006h,006h,006h,006h,006h,006h,004h	; b0d5  ................opqrs...B.......
	defb 004h,006h,006h,006h,006h,006h,006h,006h,006h,0cfh,006h,006h,031h,032h,033h,034h,035h,036h,037h,038h,039h,006h,08eh,006h,04fh,006h,006h,006h,006h,006h,006h,004h	; b0f5  ............123456789...O.......
	defb 0b9h,0b8h,0b4h,0cfh,0cfh,0ceh,0cfh,0ceh,0cfh,0ceh,006h,006h,0e0h,0e1h,0e2h,0e3h,0e4h,0e5h,0e6h,0e7h,0e8h,0e9h,08eh,08fh,08eh,08fh,08eh,08eh,08fh,074h,078h,079h	; b115  .............................txy
	defb 0ceh,0cfh,0cfh,0ceh,0cfh,0ceh,0cfh,0cfh,0c9h,0c8h,006h,006h,0eah,0ebh,0ech,0edh,0eeh,0efh,0f0h,0f1h,0f2h,0f3h,088h,089h,08eh,08fh,08eh,08fh,08eh,08fh,08eh,08fh	; b135  ................................
	defb 0ceh,0cfh,0ceh,0ceh,0ceh,0cfh,0c9h,0c8h,0bfh,0beh,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,07eh,07fh,088h,089h,08eh,08eh,08fh,08fh,08eh,08eh	; b155  ......................~.........
	defb 0ceh,0cfh,0cfh,0ceh,0c9h,0c8h,0bfh,0beh,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,07eh,07fh,088h,089h,08eh,08eh,08fh,08eh	; b175  ........................~.......
	defb 0cfh,0cfh,0cbh,0cah,0c1h,0c0h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,080h,081h,08ah,08bh,08eh,08eh	; b195  ................................
	defb 0ceh,0cdh,0cch,0c3h,0c2h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,082h,083h,08ch,08dh,08fh	; b1b5  ................................
	defb 004h,004h,0c4h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,075h,076h,077h,0b7h,0b6h,0b5h,003h,003h,003h,003h,003h,003h,003h,003h,003h,003h,084h,004h,004h	; b1d5  .............uvw................
	defb 004h,0c6h,0c5h,003h,003h,003h,003h,003h,003h,003h,075h,076h,077h,065h,066h,0aeh,06eh,0a6h,0a5h,0b7h,0b6h,0b5h,003h,003h,003h,003h,003h,003h,003h,085h,086h,004h	; b1f5  ..........uvwef.n...............
	defb 004h,0c7h,003h,003h,003h,003h,003h,075h,076h,077h,065h,066h,067h,002h,002h,002h,002h,002h,002h,0a7h,0a6h,0a5h,0b7h,0b6h,0b5h,003h,003h,003h,003h,003h,087h,004h	; b215  .......uvwefg...................
	defb 002h,0b7h,0b6h,0b5h,075h,076h,077h,065h,066h,067h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,0a7h,0a6h,0a5h,0b7h,0b6h,0b5h,075h,076h,077h,002h	; b235  ....uvwefg..................uvw.
	defb 0a0h,002h,002h,002h,0a7h,0adh,0ach,002h,002h,002h,002h,002h,002h,002h,002h,090h,0d0h,002h,002h,002h,002h,002h,002h,002h,002h,06ch,06dh,067h,002h,002h,002h,060h	; b255  .........................lmg...`
	defb 001h,0a2h,0a1h,0a0h,002h,002h,002h,0a7h,0a6h,0a5h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,065h,066h,067h,002h,002h,002h,060h,061h,062h,001h	; b275  ......................efg...`ab.
	defb 001h,001h,001h,001h,0a2h,0a1h,0a0h,002h,002h,002h,0a7h,0a6h,0a5h,002h,002h,002h,002h,002h,002h,065h,066h,067h,002h,002h,002h,060h,061h,062h,001h,001h,001h,001h	; b295  ...................efg...`ab....
	defb 001h,001h,001h,001h,001h,001h,001h,0a2h,0a1h,0a0h,002h,002h,002h,0a7h,0a9h,0a8h,068h,069h,067h,002h,002h,002h,060h,061h,062h,001h,001h,001h,001h,001h,001h,001h	; b2b5  ................hig...`ab.......
	defb 001h,001h,001h,001h,001h,001h,001h,001h,001h,001h,0a3h,002h,002h,002h,0abh,0aah,06ah,06bh,002h,002h,002h,063h,001h,001h,001h,001h,001h,001h,001h,001h,001h,001h	; b2d5  ................jk...c..........
	defb 001h,001h,001h,001h,001h,001h,001h,001h,001h,001h,0a4h,002h,002h,002h,002h,002h,002h,002h,002h,002h,002h,064h,001h,001h,001h,001h,001h,001h,001h,001h,001h,001h	; b2f5  .....................d..........

; ======================================================================
; CODIGO 0xb315..0xb490  (379 bytes)
; ======================================================================


corredores:		; Los cuatro corredores: su velocidad, la marcha y sus sprites
	call velocidad_corredores		;b315   ; la velocidad
	call corredores_quita		;b318   ; sin ordenes de volver
	ld ix,0e156h		;b31b   ; el primero: sus sprites...
	ld iy,0e067h		;b31f   ; ...y su estado
	call corredor		;b323
	ld ix,0e15ah		;b326   ; el segundo
	ld iy,0e06dh		;b32a
	call corredor		;b32e
	ld ix,0e15eh		;b331   ; el tercero
	ld iy,0e073h		;b335
	call corredor		;b339
	ld ix,0e162h		;b33c   ; el cuarto
	ld iy,0e079h		;b340
	call corredor		;b344
	jp corredores_sprites		;b347   ; sus sprites
corredores_borra:		; Los cuatro, a cero
	ld a,003h		;b34a   ; la velocidad: 3
	ld (0e042h),a		;b34c
	ld hl,0e067h		;b34f   ; el primero...
	call corredor_borra		;b352
	ld hl,0e06dh		;b355   ; ...el segundo...
	call corredor_borra		;b358
	ld hl,0e073h		;b35b   ; ...el tercero...
	call corredor_borra		;b35e
	ld hl,0e079h		;b361   ; ...y el cuarto
corredor_borra:		; Uno
	ld b,004h		;b364   ; cuatro bytes...
corredor_borra_byte:		; Un byte
	ld (hl),000h		;b366   ; ...a cero
	inc hl			;b368
	djnz corredor_borra_byte		;b369
	ld (hl),0d2h		;b36b   ; la Y fuera (0xD2)...
	inc hl			;b36d
	ld (hl),000h		;b36e   ; ...y la X a cero
	ret			;b370
corredores_salen:		; Al batear: los que estan en base salen, y el bateador a primera
	ld hl,0e067h		;b371
	ld b,004h		;b374   ; cuatro corredores
corredores_salen_uno:		; Uno
	ld a,(hl)			;b376   ; en una base?
	and 003h		;b377
	jr z,corredores_salen_sig		;b379
	set 7,(hl)		;b37b   ; en marcha...
	res 5,(hl)		;b37d   ; ...sin orden de volver
corredores_salen_sig:		; El siguiente
	inc hl			;b37f
	inc hl			;b380
	ld (hl),a			;b381   ; su base, guardada
	inc hl			;b382
	inc hl			;b383
	inc hl			;b384
	inc hl			;b385
	djnz corredores_salen_uno		;b386   ; el siguiente
	ld hl,0e067h		;b388   ; un sitio libre...
	ld b,004h		;b38b
corredores_bateador:		; Un sitio libre para el bateador
	ld a,(hl)			;b38d   ; ...sin base
	and 003h		;b38e
	jr z,corredores_bateador_pon		;b390
	inc hl			;b392
	inc hl			;b393
	inc hl			;b394
	inc hl			;b395
	inc hl			;b396
	inc hl			;b397
	djnz corredores_bateador		;b398   ; el siguiente
	ret			;b39a
corredores_bateador_pon:		; Se pone en casa
	set 7,(hl)		;b39b   ; el bateador, en marcha
	res 5,(hl)		;b39d
	inc hl			;b39f
	inc hl			;b3a0
	inc hl			;b3a1
	inc hl			;b3a2
	ld (hl),0adh		;b3a3   ; Y 0xAD...
	inc hl			;b3a5
	ld (hl),080h		;b3a6   ; ...X 0x80: en casa
	ld a,(0e020h)		;b3a8   ; el color del equipo...
	ld b,004h		;b3ab   ; ...en los cuatro
	ld hl,0e157h		;b3ad
corredores_color:		; El color del equipo
	ld (hl),a			;b3b0   ; el color
	inc hl			;b3b1   ; el sprite siguiente
	inc hl			;b3b2
	inc hl			;b3b3
	inc hl			;b3b4
	djnz corredores_color		;b3b5
	ret			;b3b7
corredor:		; Un corredor (IY): corre de base en base por las tablas de pasos (0xB490, 0xB498)
	ld c,(iy+000h)		;b3b8   ; el estado
	ld hl,0b498h		;b3bb   ; los tramos de vuelta
	ld a,c			;b3be
	rlca			;b3bf   ; bit 7: en marcha?
	jr nc,corredor_quieto		;b3c0
	ld (iy+002h),000h		;b3c2   ; la orden a cero
	rlca			;b3c6   ; bit 6: fuera
	jp c,corredor_fuera		;b3c7
	rlca			;b3ca   ; bit 5: vuelve
	jr c,corredor_paso		;b3cb
	ld hl,0b490h		;b3cd   ; los tramos de ida
corredor_paso:		; Un paso cada tanto (0xE042)
	ld a,(iy+001h)		;b3d0   ; la cuenta...
	and a			;b3d3
	jr z,corredor_paso_hace		;b3d4
	dec (iy+001h)		;b3d6   ; ...uno menos
	ret			;b3d9
corredor_paso_hace:		; El paso de su tramo: jp (hl)
	ld a,(0e042h)		;b3da   ; la velocidad...
	ld (iy+001h),a		;b3dd   ; ...a la cuenta
	ld a,c			;b3e0   ; el tramo (la base)...
	and 007h		;b3e1
	cp 004h		;b3e3   ; ...de 0 a 3
	ret nc			;b3e5
	add a,a			;b3e6   ; por dos
	ld e,a			;b3e7
	ld d,000h		;b3e8
	add hl,de			;b3ea
	ld e,(hl)			;b3eb   ; su rutina
	inc hl			;b3ec
	ld h,(hl)			;b3ed
	ld l,e			;b3ee
	jp (hl)			;b3ef
corredor_quieto:		; Quieto o en su base
	and 00eh		;b3f0   ; quieto: con orden?
	ld a,(iy+002h)		;b3f2
	jr nz,corredor_espera		;b3f5
	ld (iy+004h),0d2h		;b3f7   ; fuera
	ret			;b3fb
corredor_espera:		; Espera la orden
	rlca			;b3fc   ; bit 7 de la orden: avanzar?
	jr c,corredor_avanza		;b3fd
	ld hl,0e011h		;b3ff   ; hay jugada?
	bit 0,(hl)		;b402
	ret z			;b404
	dec hl			;b405   ; bit 1 de 0xE010: robo?
	bit 1,(hl)		;b406
	jr nz,corredor_sale		;b408
	call corredor_puede		;b40a   ; puede salir?
	ret z			;b40d
corredor_sale:		; Sale
	ld a,c			;b40e   ; sale: la orden
	and 003h		;b40f
	or 0c0h		;b411
	ld (iy+002h),a		;b413
	ret			;b416
corredor_avanza:		; Avanza
	ld hl,0e010h		;b417   ; robo?
	bit 1,(hl)		;b41a
	jr nz,corredor_avanza2		;b41c
	call corredor_puede		;b41e   ; puede salir?
	ret z			;b421
corredor_avanza2:		; Sigue
	inc hl			;b422   ; bit 0 de 0xE011
	bit 0,(hl)		;b423
	jr z,corredor_avanza4		;b425
	ld a,(iy+002h)		;b427   ; la orden
	ld b,a			;b42a
	and 060h		;b42b   ; hacia donde?
	jr nz,corredor_avanza_limite		;b42d
	bit 4,b		;b42f   ; hacia delante...
	jr nz,corredor_avanza3		;b431
	ld a,b			;b433   ; ...0x30
	or 030h		;b434
	jr corredor_avanza_pon		;b436
corredor_avanza3:		; Otro
	ld a,b			;b438   ; hacia atras...
	and 08fh		;b439   ; ...0x40
	or 040h		;b43b
corredor_avanza_pon:		; Guardado
	ld (iy+002h),a		;b43d
	jr corredor_avanza_limite		;b440
corredor_avanza4:		; Otro
	ld a,(iy+002h)		;b442   ; sin direccion
	and 09fh		;b445
	ld (iy+002h),a		;b447
corredor_avanza_limite:		; Hasta el limite de su base (0xB4A4)
	ld a,c			;b44a   ; el tramo...
	and 003h		;b44b
	add a,a			;b44d
	ld e,a			;b44e   ; por dos
	ld d,000h		;b44f
	ld hl,0b4a4h		;b451   ; sus limites (0xB4A4)
	add hl,de			;b454
	ld e,(hl)			;b455
	inc hl			;b456
	ld d,(hl)			;b457
	ld a,(iy+005h)		;b458   ; su Y...
	cp d			;b45b   ; ...dentro de los limites?
	jr nc,corredor_avanza_lento		;b45c
	cp e			;b45e
	jr nc,corredor_avanza_dir		;b45f
corredor_avanza_lento:		; Lento
	ld a,(0e0a0h)		;b461   ; cada cuatro cuadros
	and 003h		;b464
	ret nz			;b466
corredor_avanza_dir:		; La direccion
	ld a,(iy+002h)		;b467   ; la orden...
	rlca			;b46a   ; ...avanzar?
	rlca			;b46b
	jr nc,corredor_vuelve		;b46c
	call corredor_limite		;b46e   ; ha pasado el limite?
	ret c			;b471
	ld hl,0b490h		;b472   ; los tramos de ida
	jr corredor_dibujo		;b475
corredor_vuelve:		; Vuelve
	rlca			;b477   ; volver?
	ret nc			;b478
	ld hl,0b498h		;b479   ; los tramos de vuelta
corredor_dibujo:		; Su dibujo
	ld a,(0e0a0h)		;b47c   ; la cuenta de cuadros...
	and 010h		;b47f   ; ...bit 4
	jr z,corredor_dibujo2		;b481
	ld (ix+000h),018h		;b483   ; el dibujo 0x18
	jr corredor_dibujo_fin		;b487
corredor_dibujo2:		; Otro
	ld (ix+000h),018h		;b489
corredor_dibujo_fin:		; El paso
	jp corredor_paso		;b48d

; ----------------------------------------------------------------------
; DATOS corredor_tablas: Las rutinas de los cuatro tramos, de ida (0xB490) y
;   de vuelta (0xB498); los bits de cada base (0xB4A0) y los limites (0xB4A4)
;   0xb490..0xb4ac  (28 bytes)
DATA_corredor_tablas:
	defw 0b4bdh,0b4fdh,0b53dh,0b57dh	; b490  -> ida_casa_1 ida_1_2 ida_2_3 ida_3_casa
	defw 0b5b7h,0b5e0h,0b625h,0b66ah	; b498  -> vuelta_1 vuelta_2 vuelta_3 vuelta_casa
	defb 000h,008h,001h,004h	; b4a0
	defb 0f0h,0f1h,0c5h,0cfh,077h,081h,031h,03bh	; b4a4  ....w.1;

; ======================================================================
; CODIGO 0xb4ac..0xb903  (1111 bytes)
; ======================================================================


corredor_puede:		; Z si el corredor de esta base no tiene orden
	push hl			;b4ac
	ld hl,0b4a0h		;b4ad   ; los bits de cada base
	ld a,c			;b4b0   ; la base...
	and 003h		;b4b1
	ld e,a			;b4b3
	ld d,000h		;b4b4
	add hl,de			;b4b6
	ld a,(0e010h)		;b4b7   ; la orden...
	and (hl)			;b4ba   ; ...con el bit de la base
	pop hl			;b4bb
	ret			;b4bc
ida_casa_1:		; De casa a primera
	ld a,(iy+005h)		;b4bd   ; la Y...
	cp 0ceh		;b4c0   ; ...ya en primera (0xCE)?
	jr c,ida_paso_1		;b4c2
	ld a,(iy+000h)		;b4c4   ; la base siguiente
	inc a			;b4c7
	ld (iy+002h),000h		;b4c8   ; sin orden
	bit 3,a		;b4cc   ; ya en casa?
	jr nz,ida_llega		;b4ce
	ld (ix+000h),018h		;b4d0   ; quieto
	and 06fh		;b4d4   ; sin el bit de marcha
ida_llega:		; Llega
	ld (iy+000h),a		;b4d6
	ret			;b4d9
ida_paso_1:		; Un paso
	ld hl,0e00ch		;b4da   ; bit 0 de 0xE00C...
	bit 0,(hl)		;b4dd
	jr z,ida_paso_1b		;b4df
	cp 0c8h		;b4e1   ; ...hasta 0xC8
	ret nc			;b4e3
ida_paso_1b:		; Otro
	inc (iy+003h)		;b4e4   ; el paso...
	ld a,(iy+003h)		;b4e7
	cp 003h		;b4ea   ; ...cada tres...
	jr c,ida_paso_1c		;b4ec
	ld (iy+003h),000h		;b4ee   ; ...un punto arriba
	dec (iy+004h)		;b4f2   ; (la Y)
ida_paso_1c:		; Otro
	inc (iy+005h)		;b4f5   ; la X, uno mas
	ld c,0ceh		;b4f8   ; el tope
	jp corredor_dibujo_der		;b4fa
ida_1_2:		; De primera a segunda
	ld a,(iy+005h)		;b4fd   ; ya en segunda (0x81)?
	cp 081h		;b500
	jr nc,ida_paso_2		;b502
	ld a,(iy+000h)		;b504
	inc a			;b507
	ld (iy+002h),000h		;b508
	bit 3,a		;b50c
	jr nz,ida_llega_2		;b50e
	ld (ix+000h),018h		;b510
	and 06fh		;b514
ida_llega_2:		; Llega
	ld (iy+000h),a		;b516
	ret			;b519
ida_paso_2:		; Un paso
	ld hl,0e00ch		;b51a   ; bit 0 de 0xE00C...
	bit 0,(hl)		;b51d
	jr z,ida_paso_2b		;b51f
	cp 088h		;b521   ; ...desde 0x88
	ret c			;b523
ida_paso_2b:		; Otro
	inc (iy+003h)		;b524   ; el paso...
	ld a,(iy+003h)		;b527
	cp 003h		;b52a
	jr c,ida_paso_2c		;b52c
	ld (iy+003h),000h		;b52e   ; ...un punto arriba
	dec (iy+004h)		;b532
ida_paso_2c:		; Otro
	dec (iy+005h)		;b535   ; la X, uno menos
	ld c,080h		;b538
	jp corredor_llega_base		;b53a
ida_2_3:		; De segunda a tercera
	ld a,(iy+005h)		;b53d   ; ya en tercera (0x33)?
	cp 033h		;b540
	jr nc,ida_paso_3		;b542
	ld a,(iy+000h)		;b544
	inc a			;b547
	ld (iy+002h),000h		;b548
	bit 3,a		;b54c
	jr nz,ida_llega_3		;b54e
	ld (ix+000h),018h		;b550
	and 06fh		;b554
ida_llega_3:		; Llega
	ld (iy+000h),a		;b556
	ret			;b559
ida_paso_3:		; Un paso
	ld hl,0e00ch		;b55a   ; bit 0 de 0xE00C...
	bit 0,(hl)		;b55d
	jr z,ida_paso_3b		;b55f
	cp 03ah		;b561   ; ...desde 0x3A
	ret c			;b563
ida_paso_3b:		; Otro
	inc (iy+003h)		;b564   ; el paso
	ld a,(iy+003h)		;b567
	cp 003h		;b56a
	jr c,ida_paso_3c		;b56c
	ld (iy+003h),000h		;b56e   ; un punto abajo
	inc (iy+004h)		;b572
ida_paso_3c:		; Otro
	dec (iy+005h)		;b575   ; la X, uno menos
	ld c,033h		;b578
	jp corredor_llega_base		;b57a
ida_3_casa:		; De tercera a casa
	ld a,(iy+005h)		;b57d   ; ya en casa (0x80)?
	cp 080h		;b580
	jr c,ida_paso_4		;b582
	ld a,(iy+000h)		;b584   ; la base siguiente...
	inc a			;b587
	ld (iy+002h),000h		;b588
	and 06fh		;b58c   ; ...en casa: una carrera
	or 0e0h		;b58e
	ld (iy+000h),a		;b590
	ret			;b593
ida_paso_4:		; Un paso
	ld hl,0e00ch		;b594   ; bit 0 de 0xE00C
	bit 0,(hl)		;b597
	jr z,ida_paso_4b		;b599
	cp 080h		;b59b
	ret nc			;b59d
ida_paso_4b:		; Otro
	inc (iy+003h)		;b59e   ; el paso
	ld a,(iy+003h)		;b5a1
	cp 003h		;b5a4
	jr c,ida_paso_4c		;b5a6
	ld (iy+003h),000h		;b5a8   ; un punto abajo
	inc (iy+004h)		;b5ac
ida_paso_4c:		; Otro
	inc (iy+005h)		;b5af   ; la X, uno mas
	ld c,080h		;b5b2
	jp corredor_llega_casa		;b5b4
vuelta_1:		; De vuelta a primera
	ld a,(iy+005h)		;b5b7   ; ya en casa?
	cp 081h		;b5ba
	jr nc,vuelta_paso_1		;b5bc
	ld (iy+000h),000h		;b5be   ; se acaba
	ld (iy+002h),000h		;b5c2
	ret			;b5c6
vuelta_paso_1:		; Un paso
	dec (iy+003h)		;b5c7   ; el paso, al reves
	ld a,(iy+003h)		;b5ca
	cp 003h		;b5cd
	jr c,vuelta_paso_1b		;b5cf
	ld (iy+003h),002h		;b5d1   ; un punto abajo
	inc (iy+004h)		;b5d5
vuelta_paso_1b:		; Otro
	dec (iy+005h)		;b5d8   ; la X, uno menos
	ld c,080h		;b5db
	jp corredor_dibujo_izq		;b5dd
vuelta_2:		; De vuelta a segunda
	ld a,(iy+005h)		;b5e0   ; ya en primera?
	cp 0ceh		;b5e3
	jr c,vuelta_paso_2		;b5e5
	ld c,0f7h		;b5e7   ; llega a primera
	call corredor_base_llega		;b5e9
	ld a,(iy+000h)		;b5ec   ; la orden...
	ld (iy+002h),000h		;b5ef
	and 04fh		;b5f3   ; ...a cero
	ld (iy+000h),a		;b5f5
	ld (ix+000h),018h		;b5f8   ; quieto
	ld a,(0e03fh)		;b5fc   ; la jugada...
	bit 4,a		;b5ff   ; ...con el bit de primera?
	ret z			;b601
	ld a,080h		;b602   ; en marcha
	ld (0e01eh),a		;b604
	ld (iy+000h),0e1h		;b607   ; sale otra vez
	ret			;b60b
vuelta_paso_2:		; Un paso
	dec (iy+003h)		;b60c   ; el paso, al reves
	ld a,(iy+003h)		;b60f
	cp 003h		;b612
	jr c,vuelta_paso_2b		;b614
	ld (iy+003h),002h		;b616   ; un punto abajo
	inc (iy+004h)		;b61a
vuelta_paso_2b:		; Otro
	inc (iy+005h)		;b61d   ; la X, uno mas
	ld c,0ceh		;b620
	jp corredor_llega_casa		;b622
vuelta_3:		; De vuelta a tercera
	ld a,(iy+005h)		;b625   ; ya en segunda?
	cp 080h		;b628
	jr c,vuelta_paso_3		;b62a
	ld c,0feh		;b62c   ; llega a segunda
	call corredor_base_llega		;b62e
	ld a,(iy+000h)		;b631   ; la orden...
	ld (iy+002h),000h		;b634
	and 04fh		;b638   ; ...a cero
	ld (iy+000h),a		;b63a
	ld (ix+000h),018h		;b63d
	ld a,(0e03fh)		;b641   ; la jugada...
	bit 5,a		;b644   ; ...con el bit de segunda?
	ret z			;b646
	ld a,080h		;b647
	ld (0e01eh),a		;b649
	ld (iy+000h),0e2h		;b64c   ; sale otra vez
	ret			;b650
vuelta_paso_3:		; Un paso
	dec (iy+003h)		;b651   ; el paso, al reves
	ld a,(iy+003h)		;b654
	cp 003h		;b657
	jr c,vuelta_paso_3b		;b659
	ld (iy+003h),002h		;b65b   ; un punto arriba
	dec (iy+004h)		;b65f
vuelta_paso_3b:		; Otro
	inc (iy+005h)		;b662   ; la X, uno mas
	ld c,080h		;b665
	jp corredor_llega_casa		;b667
vuelta_casa:		; De vuelta a casa
	ld a,(iy+005h)		;b66a   ; ya en tercera?
	cp 033h		;b66d
	jr nc,vuelta_paso_4		;b66f
	ld c,0fbh		;b671   ; llega a tercera
	call corredor_base_llega		;b673
	ld a,(iy+000h)		;b676   ; la orden...
	ld (iy+002h),000h		;b679
	and 04fh		;b67d   ; ...a cero
	ld (iy+000h),a		;b67f
	ld (ix+000h),018h		;b682
	ld a,(0e03fh)		;b686   ; la jugada...
	bit 6,a		;b689   ; ...con el bit de tercera?
	ret z			;b68b
	ld a,080h		;b68c
	ld (0e01eh),a		;b68e
	ld (iy+000h),0e3h		;b691   ; sale otra vez
	ret			;b695
vuelta_paso_4:		; Un paso
	dec (iy+003h)		;b696   ; el paso, al reves
	ld a,(iy+003h)		;b699
	cp 003h		;b69c
	jr c,vuelta_paso_4b		;b69e
	ld (iy+003h),002h		;b6a0   ; un punto arriba
	dec (iy+004h)		;b6a4
vuelta_paso_4b:		; Otro
	dec (iy+005h)		;b6a7   ; la X, uno menos
	ld c,033h		;b6aa
	jp corredor_llega_base		;b6ac
corredores_sprites:		; Los sprites de los cuatro
	ld hl,0e06bh		;b6af   ; la Y y la X de los cuatro...
	ld de,0e154h		;b6b2   ; ...a sus sprites
	ld b,004h		;b6b5
corredores_sprites_uno:		; Uno
	ld a,(hl)			;b6b7   ; la Y...
	sub 010h		;b6b8   ; ...16 mas arriba
	ld (de),a			;b6ba
	inc hl			;b6bb
	inc de			;b6bc
	ld a,(hl)			;b6bd   ; la X...
	sub 008h		;b6be   ; ...8 a la izquierda
	ld (de),a			;b6c0
	inc hl			;b6c1   ; el siguiente corredor
	inc hl			;b6c2
	inc hl			;b6c3
	inc hl			;b6c4
	inc hl			;b6c5
	inc de			;b6c6   ; el siguiente sprite
	inc de			;b6c7
	inc de			;b6c8
	djnz corredores_sprites_uno		;b6c9
	ret			;b6cb
corredores_marcha:		; Los que tienen orden, en marcha
	ld iy,0e067h		;b6cc
	ld b,004h		;b6d0
corredores_marcha_uno:		; Uno
	ld a,(iy+002h)		;b6d2   ; con orden?
	rlca			;b6d5
	jr nc,corredores_marcha_sig		;b6d6
	set 4,(iy+000h)		;b6d8   ; en marcha
corredores_marcha_sig:		; El siguiente
	ld de,00006h		;b6dc   ; el siguiente
	add iy,de		;b6df
	djnz corredores_marcha_uno		;b6e1
corredores_ordenes_borra:		; Las ordenes a cero y en marcha
	ld iy,0e067h		;b6e3
	ld b,004h		;b6e7
corredores_ordenes_uno:		; Uno
	ld a,(iy+002h)		;b6e9   ; la orden...
	bit 7,a		;b6ec   ; ...en marcha?
	jr z,corredores_ordenes_marca		;b6ee
	and 003h		;b6f0   ; solo la base
	ld (iy+002h),a		;b6f2
	set 7,(iy+000h)		;b6f5   ; en marcha
corredores_ordenes_marca:		; Marcado
	ld a,(iy+000h)		;b6f9   ; en marcha?
	rlca			;b6fc
	jr nc,corredores_ordenes_sig		;b6fd
	set 5,(iy+000h)		;b6ff   ; sin orden de volver
corredores_ordenes_sig:		; El siguiente
	ld de,00006h		;b703   ; el siguiente
	add iy,de		;b706
	djnz corredores_ordenes_uno		;b708
	ret			;b70a
corredores_quita:		; Quita las ordenes de vuelta
	ld a,(0e009h)		;b70b   ; el tiro...
	rrca			;b70e   ; ...en marcha?
	ret nc			;b70f
	ld b,004h		;b710
	ld iy,0e067h		;b712
corredores_quita_uno:		; Uno
	ld a,(iy+002h)		;b716   ; las ordenes...
	and 09fh		;b719   ; ...sin direccion
	ld (iy+002h),a		;b71b
	ld de,00006h		;b71e
	add iy,de		;b721
	djnz corredores_quita_uno		;b723
	ret			;b725
corredor_llega_casa:		; Llega a casa: el sonido y el dibujo
	bit 7,(iy+002h)		;b726   ; ya llegando?
	ret nz			;b72a
	ld a,(iy+000h)		;b72b   ; bit 4: en marcha
	bit 4,a		;b72e
	jr z,corredor_dibujo_der		;b730
	ld a,c			;b732   ; cerca del tope?
	sub (iy+005h)		;b733
	cp 010h		;b736
	jr nc,corredor_dibujo_der		;b738
	ld a,(ix+000h)		;b73a   ; el dibujo de llegar...
	cp 088h		;b73d   ; ...ya puesto?
	jr z,corredor_llega_casa2		;b73f
	ld b,002h		;b741   ; el canal 2...
	ld de,0bf26h		;b743   ; ...0xBF26
	call pieza		;b746
corredor_llega_casa2:		; Su dibujo
	ld (ix+000h),088h		;b749   ; el dibujo 0x88
	ret			;b74d
corredor_dibujo_der:		; El dibujo de correr a la derecha
	ld a,000h		;b74e   ; el dibujo...
	ld hl,0e0a0h		;b750   ; ...segun la cuenta de cuadros...
	bit 3,(hl)		;b753
	jr nz,corredor_dibujo_pon		;b755
	ld a,004h		;b757   ; ...0 o 4
corredor_dibujo_pon:		; Guardado
	ld (ix+000h),a		;b759
	jr corredor_pasos		;b75c
corredor_llega_base:		; Llega a una base
	bit 7,(iy+002h)		;b75e
	ret nz			;b762
	ld a,(iy+000h)		;b763   ; bit 4: en marcha
	bit 4,a		;b766
	jr z,corredor_dibujo_izq		;b768
	ld a,(iy+005h)		;b76a   ; cerca del tope?
	sub c			;b76d
	cp 010h		;b76e
	jr nc,corredor_dibujo_izq		;b770
	ld a,(ix+000h)		;b772   ; el dibujo...
	cp 008h		;b775   ; ...ya puesto?
	jr z,corredor_llega_base2		;b777
	ld b,002h		;b779   ; el canal 2...
	ld de,0bf26h		;b77b   ; ...0xBF26
	call pieza		;b77e
corredor_llega_base2:		; Su dibujo
	ld (ix+000h),008h		;b781   ; el dibujo 0x08
	ret			;b785
corredor_dibujo_izq:		; El dibujo de correr a la izquierda
	ld a,080h		;b786   ; el dibujo...
	ld hl,0e0a0h		;b788   ; ...segun la cuenta...
	bit 3,(hl)		;b78b
	jr nz,corredor_dibujo_pon2		;b78d
	ld a,084h		;b78f   ; ...0x80 o 0x84
corredor_dibujo_pon2:		; Guardado
	ld (ix+000h),a		;b791
corredor_pasos:		; El sonido de los pasos, si el canal esta libre
	ld a,(0e00bh)		;b794   ; ha botado?
	rrca			;b797
	ret c			;b798
	ld a,(0e444h)		;b799   ; el canal A libre?
	and a			;b79c
	ret nz			;b79d
	ld b,002h		;b79e   ; el canal 2...
	ld de,0befch		;b7a0   ; ...0xBEFC
	jp pieza		;b7a3
corredor_fuera:		; Fuera: sale del campo
	ld a,(iy+004h)		;b7a6   ; la Y...
	cp 0c5h		;b7a9   ; ...fuera del campo?
	jr c,corredor_fuera_paso		;b7ab
corredor_fuera_fin:		; Se acaba
	ld a,(iy+000h)		;b7ad   ; se acaba...
	and 004h		;b7b0
	ld (iy+000h),a		;b7b2
	ld (iy+002h),000h		;b7b5   ; ...sin orden
	ret			;b7b9
corredor_fuera_paso:		; Un paso
	ld a,(iy+005h)		;b7ba   ; la X...
	cp 018h		;b7bd   ; ...en los bordes?
	jr c,corredor_fuera_fin		;b7bf
	cp 0e8h		;b7c1
	jr nc,corredor_fuera_fin		;b7c3
	call corredor_pasos		;b7c5   ; los pasos
	ld a,(iy+000h)		;b7c8   ; su base...
	and 003h		;b7cb
	jr z,corredor_fuera_dir		;b7cd
	ld d,a			;b7cf
	scf			;b7d0   ; los bits...
	ld a,0f6h		;b7d1
corredor_fuera_bit:		; Su bit
	dec d			;b7d3
	jr z,corredor_fuera_dir		;b7d4
	rla			;b7d6
	jr corredor_fuera_bit		;b7d7
corredor_fuera_dir:		; Hacia que lado
	ld a,(ix+001h)		;b7d9   ; su dibujo...
	cp 007h		;b7dc   ; ...el 7?
	jr z,corredor_fuera_der		;b7de
	ld a,(0e0a0h)		;b7e0   ; cada dos cuadros
	and 001h		;b7e3
	ret z			;b7e5
	inc (iy+004h)		;b7e6   ; abajo...
	dec (iy+005h)		;b7e9   ; ...y a la izquierda
	jp corredor_dibujo_izq		;b7ec
corredor_fuera_der:		; A la derecha
	ld a,(0e0a0h)		;b7ef
	and 001h		;b7f2
	ret z			;b7f4
	inc (iy+004h)		;b7f5   ; abajo...
	inc (iy+005h)		;b7f8   ; ...y a la derecha
	jp corredor_dibujo_der		;b7fb
corredor_limite:		; CY si ha pasado el limite de su base
	ld e,(iy+005h)		;b7fe   ; la X
	ld a,c			;b801   ; la base...
	and 003h		;b802
	cp 001h		;b804   ; ...primera?
	jr z,corredor_limite_1		;b806
	cp 002h		;b808
	jr z,corredor_limite_2		;b80a
	cp 003h		;b80c
	jr z,corredor_limite_3		;b80e
	ret			;b810
corredor_limite_1:		; Primera
	ld a,e			;b811   ; pasada 0xAE?
	cp 0aeh		;b812
	ret			;b814
corredor_limite_2:		; Segunda
	ld a,e			;b815   ; pasada 0x60?
	cp 060h		;b816
	ret			;b818
corredor_limite_3:		; Tercera
	ld a,e			;b819   ; pasada 0x52?
	cp 052h		;b81a
	ccf			;b81c
	ret			;b81d
corredor_base_llega:		; Llega a la base: quita su orden
	bit 7,(iy+002h)		;b81e   ; con orden?
	ret z			;b822
	ld (iy+002h),000h		;b823   ; sin orden
	ld hl,0e010h		;b827   ; robo?
	bit 1,(hl)		;b82a
	jr z,corredor_base_llega2		;b82c
	ld (hl),000h		;b82e   ; se acaba
	push iy		;b830   ; los demas sin ordenes
	call corredores_ordenes_borra		;b832
	pop iy		;b835
	ret			;b837
corredor_base_llega2:		; Otra
	ld a,(hl)			;b838   ; quita su bit
	and c			;b839
	ld (hl),a			;b83a
	ret			;b83b
velocidad_corredores:		; La velocidad de los corredores (0xE042): con robo, al azar 2 o 5; si no, 3
	ld a,(0e00fh)		;b83c   ; hay robo?
	rlca			;b83f
	jr nc,velocidad_normal		;b840
	ld a,(0e042h)		;b842   ; la velocidad...
	cp 003h		;b845   ; ...ya elegida?
	ret nz			;b847
	ld a,r		;b848   ; al azar...
	and 004h		;b84a
	ld a,002h		;b84c   ; ...2...
	jr z,velocidad_pon		;b84e
	ld a,005h		;b850   ; ...o 5
velocidad_pon:		; Guardada
	ld (0e042h),a		;b852
	ret			;b855
velocidad_normal:		; 3
	ld a,003h		;b856
	ld (0e042h),a		;b858
	ret			;b85b
torneo:		; El cuadro del torneo: la fuerza de cada region al azar, el orden y el dibujo
	ld a,r		;b85c   ; la semilla del azar, del registro R
	ld (0e200h),a		;b85e   ; la semilla
	call torneo_fuerza		;b861   ; la fuerza de las regiones
	ld hl,0ba61h		;b864   ; las lineas del cuadro...
	ld de,01821h		;b867   ; ...en la fila 1, columna 1
	ld b,004h		;b86a   ; cuatro filas
torneo_lineas:		; Las lineas del cuadro (0xBA61): cuatro filas de 8
	push bc			;b86c
	push hl			;b86d
	push de			;b86e
	ld bc,00008h		;b86f   ; 8 casillas
	call 0005ch		;b872   ; LDIRVM
	pop de			;b875
	pop hl			;b876
	ld bc,00008h		;b877   ; la siguiente
	add hl,bc			;b87a
	ld c,020h		;b87b   ; la fila siguiente
	ex de,hl			;b87d
	add hl,bc			;b87e
	ex de,hl			;b87f
	pop bc			;b880
	djnz torneo_lineas		;b881
	ld b,008h		;b883   ; ocho regiones
	ld iy,0e21dh		;b885   ; la copia, en 0xE21D
	ld hl,0e1f0h		;b889   ; desde 0xE1F0
	ld de,018a1h		;b88c   ; fila 5, columna 1
torneo_region:		; Una region: sus tres letras (0xBA41)
	push bc			;b88f
	push hl			;b890
	push de			;b891
	push iy		;b892
	ld a,(hl)			;b894   ; su numero...
	and 007h		;b895
	add a,a			;b897   ; ...por 4...
	add a,a			;b898
	ld hl,0ba41h		;b899   ; ...en 0xBA41
	ld c,a			;b89c
	ld b,000h		;b89d
	add hl,bc			;b89f
	ld b,003h		;b8a0   ; tres letras
	ex de,hl			;b8a2
torneo_region_letra:		; Una letra, a la pantalla y a la copia 0xE21D
	push bc			;b8a3
	ld a,(de)			;b8a4   ; una...
	ld (iy+000h),a		;b8a5   ; ...a la copia...
	call 0004dh		;b8a8   ; ...y a la pantalla
	ld bc,00020h		;b8ab   ; la fila siguiente
	add hl,bc			;b8ae
	inc de			;b8af   ; la copia, 8 mas
	ld c,008h		;b8b0
	add iy,bc		;b8b2
	pop bc			;b8b4
	djnz torneo_region_letra		;b8b5
	pop iy		;b8b7
	pop de			;b8b9
	pop hl			;b8ba
	inc hl			;b8bb   ; la region siguiente
	inc hl			;b8bc
	inc de			;b8bd   ; la columna siguiente
	inc iy		;b8be
	pop bc			;b8c0
	djnz torneo_region		;b8c1
	ret			;b8c3
torneo_fuerza:		; La fuerza de cada region al azar, y el orden: cada region, cuantas tiene por debajo
	xor a			;b8c4   ; la ronda del torneo a 0
	ld (0e201h),a		;b8c5
	ld d,011h		;b8c8   ; los numeros, de 0 a 0x10
	call torneo_azar8		;b8ca
	ld b,008h		;b8cd   ; ocho regiones
	ld hl,0e1f1h		;b8cf   ; desde la primera
torneo_fuerza_uno:		; Una
	ld a,(hl)			;b8d2
	push hl			;b8d3
	push bc			;b8d4
	ld bc,00800h		;b8d5   ; cuantas por debajo
	ld hl,0e1f1h		;b8d8
torneo_fuerza_cuenta:		; Cuenta las de menos
	cp (hl)			;b8db   ; esta...
	jr z,torneo_fuerza_sig		;b8dc   ; ...igual...
	jr c,torneo_fuerza_sig		;b8de   ; ...o menor
	inc c			;b8e0   ; una mas
torneo_fuerza_sig:		; La siguiente
	inc hl			;b8e1
	inc hl			;b8e2
	djnz torneo_fuerza_cuenta		;b8e3
	ld a,c			;b8e5   ; su sitio...
	pop bc			;b8e6
	pop hl			;b8e7
	dec hl			;b8e8
	and 007h		;b8e9   ; ...de 0 a 7...
	or 080h		;b8eb   ; ...en juego (bit 7)
	ld (hl),a			;b8ed
	inc hl			;b8ee
	inc hl			;b8ef
	inc hl			;b8f0
	djnz torneo_fuerza_uno		;b8f1
	ld d,00eh		;b8f3   ; la fuerza, de 0 a 0x0D
torneo_azar8:		; Ocho numeros al azar (0xB905) en 0xE1F1
	ld hl,0e1f1h		;b8f5
	ld b,008h		;b8f8   ; ocho
torneo_azar8_uno:		; Uno
	call azar		;b8fa
	ld (hl),a			;b8fd   ; guardado
	inc hl			;b8fe
	inc hl			;b8ff
	djnz torneo_azar8_uno		;b900
	ret			;b902

; ----------------------------------------------------------------------
; DATOS sin_uso_b903: Dos bytes entre dos rutinas que nadie lee (no se
;   ejecutan jugando)
;   0xb903..0xb905  (2 bytes)
DATA_sin_uso_b903:
	defb 016h,00eh	; b903

; ======================================================================
; CODIGO 0xb905..0xba41  (316 bytes)
; ======================================================================


azar:		; Al azar: 0xE200 = 0xE200 x 5 + D
	ld a,(0e200h)		;b905   ; el azar...
	ld c,a			;b908
	add a,a			;b909   ; ...por 5...
	add a,a			;b90a
	add a,c			;b90b
	add a,d			;b90c   ; ...mas D
	ld (0e200h),a		;b90d   ; guardado
	ret			;b910
torneo_jugador:		; Marca la region del jugador y su rival
	and 007h		;b911   ; la region del jugador...
	ld c,a			;b913
	add a,a			;b914   ; ...por dos...
	ld e,a			;b915
	ld d,000h		;b916
	ld hl,0e1f0h		;b918   ; ...en 0xE1F0
	add hl,de			;b91b
	set 6,(hl)		;b91c   ; es la del jugador...
	set 4,(hl)		;b91e   ; ...en esta ronda
	dec hl			;b920   ; su rival: la de al lado
	dec hl			;b921
	bit 0,c		;b922
	jr nz,torneo_jugador_marca		;b924
	inc hl			;b926
	inc hl			;b927
	inc hl			;b928
	inc hl			;b929
torneo_jugador_marca:		; Marcada
	set 5,(hl)		;b92a   ; el rival...
	set 3,(hl)		;b92c   ; ...marcado
torneo_partidas:		; Las partidas de la ronda del torneo: quien juega contra quien
	ld hl,0e1f0h		;b92e   ; las ocho regiones...
	ld bc,00800h		;b931   ; ...tres bits de cada una
	ld de,00000h		;b934
torneo_partidas_bit:		; Una
	ld a,(hl)			;b937   ; en juego...
	rlca			;b938
	rl d		;b939
	rlca			;b93b   ; ...del jugador...
	rl e		;b93c
	rlca			;b93e   ; ...rival
	rl c		;b93f
	inc hl			;b941
	inc hl			;b942
	djnz torneo_partidas_bit		;b943   ; la siguiente
	ld a,d			;b945   ; las dos...
	and e			;b946
	jr nz,torneo_partidas_rival		;b947   ; ...a la vez?
	ld a,d			;b949   ; la del jugador...
	and c			;b94a   ; ...y en juego?
	jp nz,torneo_final		;b94b
	ld e,d			;b94e
torneo_partidas_rival:		; El rival
	ld a,e			;b94f   ; el jugador
	ld b,000h		;b950   ; su numero
torneo_partidas_busca:		; Busca
	rlca			;b952   ; el primer bit
	jr c,torneo_partidas_pon		;b953
	inc b			;b955
	jr torneo_partidas_busca		;b956
torneo_partidas_pon:		; Guardado
	ld a,b			;b958
	and 007h		;b959   ; de 0 a 7
	add a,a			;b95b
	ld e,a			;b95c
	ld d,000h		;b95d
	ld hl,0e1f0h		;b95f   ; su sitio
	add hl,de			;b962
	push bc			;b963
	push hl			;b964
	ld a,(hl)			;b965   ; su estado
	call torneo_jugador_letras		;b966   ; sus letras
	pop hl			;b969
	pop bc			;b96a
	bit 0,b		;b96b   ; a que lado?
	jr nz,torneo_partidas_otro		;b96d
	inc hl			;b96f   ; la de al lado...
	inc hl			;b970
	ld a,(hl)			;b971
	bit 7,a		;b972   ; ...en juego?
	jr nz,torneo_rival		;b974
	dec hl			;b976
	dec hl			;b977
	jr torneo_partidas_lado		;b978
torneo_partidas_otro:		; El otro
	dec hl			;b97a
	dec hl			;b97b
	ld a,(hl)			;b97c   ; la de antes...
	bit 7,a		;b97d   ; ...en juego?
	jr nz,torneo_rival		;b97f
	dec b			;b981
torneo_partidas_lado:		; El lado
	bit 1,b		;b982   ; hacia arriba o hacia abajo?
	jr nz,torneo_partidas_baja		;b984
	inc hl			;b986   ; la de dos mas alla
	inc hl			;b987
	inc hl			;b988
	inc hl			;b989
torneo_partidas_sube:		; Sube
	ld a,(hl)			;b98a   ; en juego?
	bit 7,a		;b98b
	jr nz,torneo_rival		;b98d
	inc hl			;b98f   ; la siguiente
	inc hl			;b990
	ld a,(hl)			;b991
	bit 7,a		;b992
	jr nz,torneo_rival		;b994
	jr torneo_partidas_mitad		;b996
torneo_partidas_baja:		; Baja
	dec hl			;b998
	dec hl			;b999
	dec hl			;b99a
	dec hl			;b99b
	jr torneo_partidas_sube		;b99c
torneo_partidas_mitad:		; La mitad
	ld hl,0e1f0h		;b99e
	bit 2,b		;b9a1   ; la mitad...
	jr nz,torneo_partidas_mitad2		;b9a3
	ld hl,0e1f8h		;b9a5   ; ...la otra
torneo_partidas_mitad2:		; Otra
	ld b,004h		;b9a8   ; cuatro
	ld a,(hl)			;b9aa
	bit 7,a		;b9ab   ; en juego?
	jr nz,torneo_rival		;b9ad
	inc hl			;b9af
	inc hl			;b9b0
	djnz torneo_partidas_mitad2		;b9b1
	ret			;b9b3
torneo_rival:		; Las letras del rival en la ventana (0x192A)
	ld de,0192ah		;b9b4   ; fila 9, columna 10
	set 3,(hl)		;b9b7   ; marcada
torneo_letras:		; Las letras de una region (0xBA41), sin los espacios
	and 007h		;b9b9   ; la region...
	add a,a			;b9bb   ; ...por 4...
	add a,a			;b9bc
	ld c,a			;b9bd
	ld b,000h		;b9be
	ld hl,0ba41h		;b9c0   ; ...en 0xBA41
	add hl,bc			;b9c3
	ex de,hl			;b9c4
	ld c,002h		;b9c5   ; dos letras
torneo_letras_una:		; Una
	ld a,(de)			;b9c7   ; una...
	cp 006h		;b9c8   ; ...espacio?
	jr z,torneo_letras_sig		;b9ca
	call 0004dh		;b9cc   ; WRTVRM
	inc hl			;b9cf
	dec c			;b9d0
	ret z			;b9d1
torneo_letras_sig:		; La siguiente
	inc de			;b9d2   ; la siguiente
	jr torneo_letras_una		;b9d3
torneo_jugador_letras:		; Las del jugador (0x190A)
	ld de,0190ah		;b9d5   ; fila 8, columna 10
	set 4,(hl)		;b9d8   ; marcada
	jr torneo_letras		;b9da
torneo_final:		; La final
	ld a,c			;b9dc
	ld b,000h		;b9dd
torneo_final_busca:		; Busca
	rlca			;b9df
	jr c,torneo_final_pon		;b9e0
	inc b			;b9e2
	jr torneo_final_busca		;b9e3
torneo_final_pon:		; Guardado
	ld a,b			;b9e5   ; el numero de la region...
	and 007h		;b9e6   ; ...de 0 a 7...
	add a,a			;b9e8   ; ...por dos
	ld e,a			;b9e9
	ld d,000h		;b9ea
	ld hl,0e1f0h		;b9ec   ; en 0xE1F0
	add hl,de			;b9ef
	push bc			;b9f0
	push hl			;b9f1
	ld a,(hl)			;b9f2   ; su estado...
	call torneo_rival		;b9f3   ; ...y sus letras
	pop hl			;b9f6
	pop bc			;b9f7
	bit 0,b		;b9f8   ; a que lado?
	jr nz,torneo_final_otro		;b9fa
	inc hl			;b9fc   ; la de al lado...
	inc hl			;b9fd
	ld a,(hl)			;b9fe   ; ...en juego?
	bit 7,a		;b9ff
	jr nz,torneo_jugador_letras		;ba01
	dec hl			;ba03
	dec hl			;ba04
	jr torneo_final_lado		;ba05
torneo_final_otro:		; Otro
	dec hl			;ba07   ; la de antes...
	dec hl			;ba08
	ld a,(hl)			;ba09   ; ...en juego?
	bit 7,a		;ba0a
	jr nz,torneo_jugador_letras		;ba0c
	dec b			;ba0e   ; el bit
torneo_final_lado:		; El lado
	bit 1,b		;ba0f   ; hacia arriba o abajo?
	jr nz,torneo_final_baja		;ba11
	inc hl			;ba13   ; la de dos mas alla
	inc hl			;ba14
	inc hl			;ba15
	inc hl			;ba16
torneo_final_sube:		; Sube
	ld a,(hl)			;ba17   ; en juego?
	bit 7,a		;ba18
	jr nz,torneo_jugador_letras		;ba1a
	inc hl			;ba1c   ; la siguiente
	inc hl			;ba1d
	ld a,(hl)			;ba1e
	bit 7,a		;ba1f
	jr nz,torneo_jugador_letras		;ba21
	jr torneo_final_mitad		;ba23
torneo_final_baja:		; Baja
	dec hl			;ba25
	dec hl			;ba26
	dec hl			;ba27
	dec hl			;ba28
	jr torneo_final_sube		;ba29
torneo_final_mitad:		; La mitad
	ld hl,0e1f0h		;ba2b
	bit 2,b		;ba2e
	jr nz,torneo_final_mitad2		;ba30
	ld hl,0e1f8h		;ba32
torneo_final_mitad2:		; Otra
	ld b,004h		;ba35   ; cuatro
	ld a,(hl)			;ba37
	bit 7,a		;ba38   ; en juego?
	jr nz,torneo_jugador_letras		;ba3a
	inc hl			;ba3c
	inc hl			;ba3d
	djnz torneo_final_mitad2		;ba3e
	ret			;ba40

; ----------------------------------------------------------------------
; DATOS torneo_dibujos: Las ocho regiones en tres letras (4 bytes cada una) y
;   las lineas del cuadro (4 filas de 8 casillas)
;   0xba41..0xba81  (64 bytes)
DATA_torneo_dibujos:
	defb 00ah,006h,00bh,006h	; ba41
	defb 00ch,006h,00dh,006h	; ba45
	defb 00eh,006h,00fh,006h	; ba49
	defb 00dh,010h,016h,006h	; ba4d
	defb 011h,006h,012h,006h	; ba51
	defb 010h,013h,017h,006h	; ba55
	defb 014h,006h,012h,006h	; ba59
	defb 011h,006h,015h,006h	; ba5d
	defb 006h,006h,006h,006h,07dh,006h,006h,006h	; ba61  ....}...
	defb 006h,006h,0bbh,07ch,07ch,07bh,006h,006h	; ba69  ...||{..
	defb 006h,0bbh,07bh,006h,006h,0bbh,07bh,006h	; ba71  ..{...{.
	defb 0bah,07ah,0bah,07ah,0bah,07ah,0bah,07ah	; ba79  .z.z.z.z

; ======================================================================
; CODIGO 0xba81..0xbda5  (804 bytes)
; ======================================================================


torneo_resultado:		; Despues de una partida: los resultados de la ronda, la ronda siguiente y las lineas del cuadro
	ld a,(0e201h)		;ba81   ; la ronda del torneo...
	cp 003h		;ba84   ; ...ya la tercera?
	ret nc			;ba86
	ld hl,0e1f0h		;ba87   ; las ocho regiones
	ld b,008h		;ba8a
torneo_resultado_uno:		; Una region
	bit 4,(hl)		;ba8c   ; la del jugador?
	jr z,torneo_resultado_jug		;ba8e
	res 4,(hl)		;ba90   ; ya no
	inc hl			;ba92
	ld (hl),d			;ba93   ; su fuerza: la de D
	dec hl			;ba94
torneo_resultado_jug:		; La del jugador
	bit 3,(hl)		;ba95   ; su rival?
	jr z,torneo_resultado_sig		;ba97
	res 3,(hl)		;ba99   ; ya no
	inc hl			;ba9b
	ld (hl),e			;ba9c   ; su fuerza: la de E
	dec hl			;ba9d
torneo_resultado_sig:		; La siguiente
	inc hl			;ba9e
	inc hl			;ba9f
	djnz torneo_resultado_uno		;baa0
	ld hl,0e201h		;baa2   ; la ronda...
	ld a,(hl)			;baa5
	inc (hl)			;baa6   ; ...una mas
	ld hl,0e1f0h		;baa7
	cp 002h		;baaa   ; la segunda?
	jr z,torneo_resultado_r3		;baac
	cp 001h		;baae   ; la primera?
	jr z,torneo_resultado_r2		;bab0
	call torneo_ganador		;bab2   ; las cuatro partidas de la primera ronda
	ld de,01881h		;bab5   ; fila 4, columna 1
	call torneo_linea		;bab8
	call torneo_ganador		;babb
	ld de,01883h		;babe   ; columna 3
	call torneo_linea		;bac1
	call torneo_ganador		;bac4
	ld de,01885h		;bac7   ; columna 5
	call torneo_linea		;baca
	call torneo_ganador		;bacd
	ld de,01887h		;bad0   ; columna 7
	jr torneo_linea		;bad3
torneo_resultado_r2:		; La ronda 2
	call torneo_ganador		;bad5   ; las dos de la segunda
	ld de,01862h		;bad8   ; fila 3, columna 2
	call torneo_linea		;badb
	call torneo_ganador		;bade
	ld de,01866h		;bae1   ; columna 6
torneo_linea:		; Borra la linea del que pierde
	push hl			;bae4
	ex de,hl			;bae5   ; la linea del que pierde...
	ld bc,00000h		;bae6
	adc hl,bc		;bae9   ; ...una mas a la derecha si gana el segundo
	ld a,006h		;baeb   ; 0x06: vacia
	call 0004dh		;baed   ; WRTVRM
	pop hl			;baf0
	ret			;baf1
torneo_resultado_r3:		; La final
	call torneo_ganador		;baf2   ; la final
	ld a,000h		;baf5
	adc a,a			;baf7   ; el ganador...
	add a,a			;baf8   ; ...por dos
	ld c,a			;baf9
	ld b,000h		;bafa
	ld hl,01843h		;bafc   ; fila 2, columna 3
	add hl,bc			;baff
	ld a,006h		;bb00   ; 0x06: vacia
	call 0004dh		;bb02   ; WRTVRM...
	inc hl			;bb05
	jp 0004dh		;bb06   ; ...y la de al lado
torneo_ganador:		; Entre dos regiones seguidas que siguen, gana la mas fuerte (CY el primero)
	ld b,008h		;bb09   ; ocho
torneo_ganador_busca:		; La primera
	bit 7,(hl)		;bb0b   ; en juego?
	jr nz,torneo_ganador_otra		;bb0d
	inc hl			;bb0f
	inc hl			;bb10
	djnz torneo_ganador_busca		;bb11
	ret			;bb13
torneo_ganador_otra:		; La segunda
	ld e,l			;bb14   ; la primera
	ld d,h			;bb15
	inc hl			;bb16
	inc hl			;bb17
torneo_ganador_busca2:		; Busca
	bit 7,(hl)		;bb18   ; en juego?
	jr nz,torneo_ganador_compara		;bb1a
	inc hl			;bb1c
	inc hl			;bb1d
	djnz torneo_ganador_busca2		;bb1e
	ret			;bb20
torneo_ganador_compara:		; Compara las fuerzas
	inc de			;bb21
	ld a,(de)			;bb22   ; la fuerza de la primera...
	dec de			;bb23
	inc hl			;bb24
	ld c,(hl)			;bb25   ; ...y de la segunda
	dec hl			;bb26
	cp c			;bb27   ; la primera es mas fuerte?
	jr nc,torneo_ganador_segunda		;bb28
	ex de,hl			;bb2a
	res 7,(hl)		;bb2b   ; la segunda, fuera
	ex de,hl			;bb2d
	and a			;bb2e   ; NC
	jr torneo_ganador_fin		;bb2f
torneo_ganador_segunda:		; Gana la segunda
	res 7,(hl)		;bb31   ; la primera, fuera
	scf			;bb33   ; CY
torneo_ganador_fin:		; Fin
	inc hl			;bb34
	inc hl			;bb35
	ret			;bb36
pieza:		; Pone la pieza DE en el canal B y la hace sonar
	call canal		;bb37   ; el canal en su estado inicial
	ld (hl),e			;bb3a   ; el principio de la pieza...
	inc hl			;bb3b
	ld (hl),d			;bb3c
	inc hl			;bb3d
	ld (hl),001h		;bb3e   ; ...y suena
	ret			;bb40
canal:		; HL = el canal B (0xE402 + B x 0x20), y lo deja en su estado inicial (0xBDBF)
	push bc			;bb41
	push de			;bb42
	ld hl,0e402h		;bb43   ; los canales desde 0xE402...
	ld a,b			;bb46   ; ...B por 32
	rrca			;bb47
	rrca			;bb48
	rrca			;bb49
	ld e,a			;bb4a
	ld d,000h		;bb4b
	add hl,de			;bb4d
	push hl			;bb4e
	inc hl			;bb4f   ; desde +2...
	inc hl			;bb50
	ex de,hl			;bb51
	ld hl,0bdbfh		;bb52   ; ...30 bytes de 0xBDBF
	ld bc,0001eh		;bb55
	ldir		;bb58
	pop hl			;bb5a
	pop de			;bb5b
	pop bc			;bb5c
	ret			;bb5d
sonido_calla:		; Calla el sonido: los tres canales a cero, el PSG sin ruido y los volumenes a 0
	xor a			;bb5e
	ld (0e400h),a		;bb5f   ; sin transporte
	ld b,a			;bb62
	call canal		;bb63   ; el canal 0...
	inc b			;bb66
	call canal		;bb67   ; ...el 1...
	inc b			;bb6a
	call canal		;bb6b   ; ...y el 2
	ld a,007h		;bb6e   ; el registro 7 del PSG (RDPSG)...
	call 00096h		;bb70
	and 0c0h		;bb73   ; ...los dos bits de los puertos se quedan...
	or 038h		;bb75   ; ...los tonos apagados (0x38)...
	ld e,a			;bb77
	ld a,007h		;bb78
	call 00093h		;bb7a   ; ...WRTPSG
	xor a			;bb7d   ; ninguno suena
	ld (0e404h),a		;bb7e
	ld (0e424h),a		;bb81
	ld (0e444h),a		;bb84
	ld b,002h		;bb87   ; los tres volumenes a 0
sonido_calla_uno:		; Cada canal
	call canal_para		;bb89
	djnz sonido_calla_uno		;bb8c
canal_para:		; El canal deja de sonar: el vibrato a cero... en la direccion 0x0012 de la BIOS, no en el canal
	xor a			;bb8e
	ld (00012h),a		;bb8f   ; un "ld (ix+0x12),a" que se quedo en "ld (0x0012),a": escribe en la ROM de la BIOS y no hace nada
volumen:		; El volumen E en el registro 8 + B del PSG
	ld e,a			;bb92
	ld a,008h		;bb93
	add a,b			;bb95
	jp 00093h		;bb96
sonido_cuadro:		; Un cuadro del motor: los tres canales, del 2 al 0
	ld b,002h		;bb99   ; empieza por el 2
	ld ix,0e402h		;bb9b   ; el canal de la RAM 0
sonido_cuadro_uno:		; Un canal
	call canal_cuadro		;bb9f
	ld de,00020h		;bba2   ; el siguiente...
	add ix,de		;bba5
	ld a,(0e401h)		;bba7   ; ...con el numero de canal...
	ld b,a			;bbaa   ; ...uno menos
	djnz sonido_cuadro_uno		;bbab
canal_cuadro:		; Un cuadro de un canal: el tempo, la nota, el vibrato y la envolvente
	ld a,b			;bbad
	ld (0e401h),a		;bbae   ; el canal en curso
	ld a,(ix+002h)		;bbb1   ; suena?
	and a			;bbb4
	ret z			;bbb5
	dec (ix+00eh)		;bbb6   ; el tempo...
	ret nz			;bbb9   ; ...aun no
	ld a,(ix+00dh)		;bbba   ; vuelve a su cuenta
	ld (ix+00eh),a		;bbbd
	dec (ix+007h)		;bbc0   ; la nota acaba?...
	jp z,nota		;bbc3   ; ...la siguiente
	dec (ix+006h)		;bbc6   ; le queda de sonar?...
	jr z,canal_para		;bbc9   ; ...si no, calla
	ld a,(ix+012h)		;bbcb   ; hay vibrato?
	and a			;bbce
	call nz,vibrato		;bbcf
	inc (ix+006h)		;bbd2   ; lo que le queda...
	dec (ix+006h)		;bbd5
	jp p,envolvente		;bbd8   ; ...si no ha acabado, la envolvente
	ld (ix+006h),000h		;bbdb
	ret			;bbdf
vibrato:		; El vibrato: el periodo del canal (RDPSG) mas el paso
	ld a,(0e401h)		;bbe0
	add a,a			;bbe3
	ld h,a			;bbe4
	call 00096h		;bbe5   ; RDPSG: la parte baja...
	ld l,a			;bbe8
	inc h			;bbe9
	ld a,h			;bbea
	call 00096h		;bbeb   ; ...y la alta
	ld h,a			;bbee
	ld d,000h		;bbef
	ld a,(ix+012h)		;bbf1   ; el paso...
	ld e,a			;bbf4
	inc e			;bbf5
	dec e			;bbf6
	jp p,vibrato_suma		;bbf7   ; ...con signo
	dec d			;bbfa
vibrato_suma:		; Le suma el paso
	add hl,de			;bbfb
	ex de,hl			;bbfc
	ld a,(0e401h)		;bbfd
	add a,a			;bc00
	call 00093h		;bc01   ; WRTPSG: la parte baja...
	inc a			;bc04
	ld e,d			;bc05
	jp 00093h		;bc06   ; ...y la alta
envolvente:		; La envolvente: el paso que toca segun lo que le queda a la nota
	ld a,(ix+00bh)		;bc09
	cp 010h		;bc0c   ; acabada?
	ret z			;bc0e
	ld e,000h		;bc0f
	ld h,e			;bc11
	ld l,(ix+006h)		;bc12   ; lo que le queda, por 16...
	add hl,hl			;bc15
	add hl,hl			;bc16
	add hl,hl			;bc17
	add hl,hl			;bc18
	ld d,(ix+005h)		;bc19   ; ...entre la duracion
	xor a			;bc1c
	ld b,008h		;bc1d
envolvente_div:		; La division, bit a bit
	push hl			;bc1f   ; el resto
	srl d		;bc20   ; el divisor, a la mitad
	rr e		;bc22
	and a			;bc24
	sbc hl,de		;bc25   ; cabe?
	ccf			;bc27
	jr nc,envolvente_bit		;bc28
	ex (sp),hl			;bc2a
envolvente_bit:		; Un bit del cociente
	rla			;bc2b   ; el bit del cociente
	pop hl			;bc2c   ; el resto
	djnz envolvente_div		;bc2d   ; ocho bits
	ld c,a			;bc2f   ; el cociente
	ld a,010h		;bc30
	sub c			;bc32
envolvente_paso:		; El paso: el volumen esta en la mitad alta o baja del byte de la tabla
	ld (ix+00bh),a		;bc33
	cp 010h		;bc36
	ret z			;bc38
	srl a		;bc39   ; el paso entre 2: el byte...
	push af			;bc3b
	ld e,a			;bc3c
	ld d,000h		;bc3d
	ld l,(ix+009h)		;bc3f   ; ...de la envolvente
	ld h,(ix+00ah)		;bc42
	add hl,de			;bc45
	ld a,(0e401h)		;bc46
	ld b,a			;bc49
	pop af			;bc4a
	ld a,(hl)			;bc4b   ; el byte...
	jr c,envolvente_volumen		;bc4c
	rrca			;bc4e   ; ...su mitad alta
	rrca			;bc4f
	rrca			;bc50
	rrca			;bc51
envolvente_volumen:		; El volumen del paso por el del canal, entre 16
	and 00fh		;bc52   ; el volumen de la envolvente...
	inc a			;bc54   ; ...mas uno...
	ld e,a			;bc55
	ld d,(ix+008h)		;bc56   ; ...por el del canal
	xor a			;bc59
	ld c,008h		;bc5a
envolvente_mult:		; La multiplicacion, bit a bit
	add a,a			;bc5c
	rl e		;bc5d
	jr nc,envolvente_mult_sig		;bc5f
	add a,d			;bc61
envolvente_mult_sig:		; El bit siguiente
	dec c			;bc62   ; el bit siguiente
	jr nz,envolvente_mult		;bc63
	rrca			;bc65   ; entre 16
	rrca			;bc66
	rrca			;bc67
	rrca			;bc68
	and 00fh		;bc69
	jp volumen		;bc6b
nota:		; La nota siguiente: una nota o una orden (0xF3-0xFF, tabla 0xBDA5)
	call pieza_lee		;bc6e
	and a			;bc71
	jp p,nota_pon		;bc72   ; una nota?
	cpl			;bc75   ; la orden: 0xFF es la 0, 0xFE la 1...
	add a,a			;bc76
	push de			;bc77
	ld e,a			;bc78
	ld d,000h		;bc79
	ld hl,0bda5h		;bc7b   ; su rutina en la tabla 0xBDA5
	add hl,de			;bc7e
	pop de			;bc7f
	push hl			;bc80
	ld hl,nota		;bc81   ; al acabar, otra nota
	ex (sp),hl			;bc84
	ld a,(hl)			;bc85
	inc hl			;bc86
	ld h,(hl)			;bc87
	ld l,a			;bc88
	jp (hl)			;bc89   ; a la orden
nota_pon:		; Una nota: A el numero, E la duracion, D hasta la siguiente; duracion 0 es un silencio
	ld (ix+005h),e		;bc8a
	ld (ix+006h),e		;bc8d
	ld (ix+007h),d		;bc90
	inc e			;bc93   ; duracion 0: silencio
	dec e			;bc94
	jp z,canal_para		;bc95
nota_tono:		; El periodo de la nota en el canal B
	ld d,a			;bc98
	ld a,(0e400h)		;bc99   ; mas el transporte
	add a,d			;bc9c
	ld c,000h		;bc9d
nota_octava:		; La octava: de 12 en 12
	cp 00ch		;bc9f
	jr c,nota_periodo		;bca1
	sub 00ch		;bca3
	inc c			;bca5
	jr nota_octava		;bca6
nota_periodo:		; El periodo de la nota (0xBDD0), partido por 2 por cada octava
	add a,a			;bca8   ; por dos
	ld e,a			;bca9
	ld d,000h		;bcaa
	ld hl,0bdd0h		;bcac   ; en la tabla de periodos
	add hl,de			;bcaf
	ld e,(hl)			;bcb0   ; el periodo
	inc hl			;bcb1
	ld d,(hl)			;bcb2
	ld a,c			;bcb3   ; la octava
	and a			;bcb4
	jr z,nota_escribe		;bcb5
nota_octava_baja:		; Una octava mas arriba
	srl d		;bcb7
	rr e		;bcb9
	dec a			;bcbb
	jr nz,nota_octava_baja		;bcbc
nota_escribe:		; En los registros 2B y 2B+1 del PSG; en el canal 3 (el ruido, registro 6), solo uno
	ld a,b			;bcbe   ; el registro 2B...
	add a,b			;bcbf
	call 00093h		;bcc0   ; ...la parte baja
	cp 006h		;bcc3   ; el registro 6 (el ruido)?
	jr z,nota_envolvente		;bcc5
	ld e,d			;bcc7
	inc a			;bcc8
	call 00093h		;bcc9   ; la parte alta
nota_envolvente:		; Si la envolvente es de las de tabla, desde el paso 0
	ld a,(ix+00ch)		;bccc
	cp 010h		;bccf
	ret c			;bcd1
	xor a			;bcd2
	jp envolvente_paso		;bcd3
orden_fin:		; Orden 0xFF: la pieza se acaba y el canal calla
	xor a			;bcd6
	ld (ix+002h),a		;bcd7
	pop hl			;bcda
	jp canal_para		;bcdb
orden_repite:		; Orden 0xFC: vuelve a la marca si faltan repeticiones
	dec (ix+011h)		;bcde
	ret z			;bce1
orden_vuelve:		; Orden 0xFD: vuelve a la marca
	ld e,(ix+00fh)		;bce2
	ld d,(ix+010h)		;bce5
orden_salta:		; Orden 0xF4: salta a DE
	ld (ix+003h),e		;bce8
	ld (ix+004h),d		;bceb
orden_nada:		; Orden 0xFE: nada
	ret			;bcee
orden_marca:		; Orden 0xFB: la marca de la repeticion y cuantas veces
	ld (ix+011h),d		;bcef   ; cuantas veces
	ld e,(ix+003h)		;bcf2   ; la marca es por donde va
	ld d,(ix+004h)		;bcf5
	ld (ix+00fh),e		;bcf8   ; guardada
	ld (ix+010h),d		;bcfb
	ret			;bcfe
orden_volumen:		; Orden 0xFA: el volumen del canal
	ld a,d			;bcff
	and 00fh		;bd00
	ld (ix+008h),a		;bd02
	ret			;bd05
envolvente_psg:		; La envolvente del PSG: volumen 16 y los registros 11-13
	ld a,010h		;bd06   ; el volumen 16: la del PSG
	ld (ix+00bh),a		;bd08
	call volumen		;bd0b   ; en el registro de volumen
	ld e,d			;bd0e
	ld a,00dh		;bd0f   ; la forma en el registro 13
	call 00093h		;bd11
	call pieza_lee		;bd14   ; los tres bytes siguientes...
	ld a,00bh		;bd17   ; ...el periodo en los registros 11...
	call 00093h		;bd19
	inc a			;bd1c   ; ...y 12
	ld e,d			;bd1d
	jp 00093h		;bd1e
orden_envolvente:		; Orden 0xF9: el tipo de envolvente: del PSG o de la tabla 0xBDE8
	ld (ix+00ch),d		;bd21   ; el tipo de envolvente...
	bit 4,d		;bd24   ; ...bit 4: de tabla
	jr z,envolvente_psg		;bd26
	ld a,d			;bd28   ; la tabla: 8 bytes por envolvente...
	and 00fh		;bd29
	add a,a			;bd2b
	add a,a			;bd2c
	add a,a			;bd2d
	ld e,a			;bd2e
	ld d,000h		;bd2f
	ld hl,0bde8h		;bd31   ; ...desde 0xBDE8
	add hl,de			;bd34
	ld (ix+009h),l		;bd35
	ld (ix+00ah),h		;bd38
	ret			;bd3b
orden_f8:		; Orden 0xF8: no hace nada
	ret			;bd3c
orden_f7:		; Orden 0xF7: no hace nada
	ret			;bd3d
orden_mezcla:		; Orden 0xF6: tono y ruido del canal en el registro 7
	ld a,d			;bd3e   ; los bits de tono y ruido...
	and 009h		;bd3f   ; ...la mascara
	ld l,a			;bd41
	ld h,009h		;bd42   ; los del canal
	ld a,b			;bd44
	and a			;bd45
	jr z,orden_mezcla_pon		;bd46   ; 0: el canal A
orden_mezcla_bit:		; Los bits del canal
	add hl,hl			;bd48   ; corridos al canal
	dec a			;bd49
	jr nz,orden_mezcla_bit		;bd4a
orden_mezcla_pon:		; Los escribe
	ld a,007h		;bd4c   ; RDPSG 7
	call 00096h		;bd4e
	ld c,a			;bd51
	ld a,h			;bd52   ; fuera los del canal...
	cpl			;bd53
	and c			;bd54
	or l			;bd55   ; ...y los nuevos
	and 03fh		;bd56   ; los puertos como estaban
	or 080h		;bd58
	ld e,a			;bd5a
	ld a,007h		;bd5b   ; WRTPSG 7
	jp 00093h		;bd5d
orden_ruido:		; Orden 0xF5: una nota de ruido (el periodo del ruido en el registro 6)
	pop af			;bd60   ; fuera la vuelta...
	push de			;bd61
	call pieza_lee		;bd62   ; ...y los tres bytes siguientes
	pop af			;bd65
	ld (ix+005h),e		;bd66   ; la duracion...
	ld (ix+006h),e		;bd69
	ld (ix+007h),d		;bd6c   ; ...y hasta la siguiente
	inc e			;bd6f
	dec e			;bd70
	jp z,canal_para		;bd71   ; 0: silencio
	ld b,003h		;bd74   ; el canal del ruido
	jp nota_tono		;bd76
pieza_lee:		; Los tres bytes siguientes de la pieza: A, E, D
	ld l,(ix+000h)		;bd79   ; el principio de la pieza...
	ld h,(ix+001h)		;bd7c
	ld e,(ix+003h)		;bd7f   ; ...mas por donde va
	ld d,(ix+004h)		;bd82
	add hl,de			;bd85
	inc de			;bd86   ; tres mas
	inc de			;bd87
	inc de			;bd88
	ld (ix+003h),e		;bd89
	ld (ix+004h),d		;bd8c
	ld a,(0e401h)		;bd8f   ; el canal
	ld b,a			;bd92
	ld a,(hl)			;bd93   ; A, E y D
	inc hl			;bd94
	ld e,(hl)			;bd95
	inc hl			;bd96
	ld d,(hl)			;bd97
	ret			;bd98
orden_vibrato:		; Orden 0xF3: el paso del vibrato y una nota
	pop af			;bd99   ; fuera la vuelta...
	push de			;bd9a
	call pieza_lee		;bd9b   ; ...los tres bytes siguientes
	ld (ix+012h),a		;bd9e   ; el paso del vibrato
	pop af			;bda1
	jp nota_pon		;bda2   ; y una nota

; ----------------------------------------------------------------------
; DATOS ordenes: Las trece ordenes del motor (0xFF, 0xFE... 0xF3); la
;   siguiente entrada, la 0xF2, cae en los primeros bytes de 0xBDBF (0x0000)
;   0xbda5..0xbdbf  (26 bytes)
DATA_ordenes:
	defw 0bcd6h,0bceeh	; bda5  -> orden_fin orden_nada
	defw 0bce2h,0bcdeh	; bda9  -> orden_vuelve orden_repite
	defw 0bcefh,0bcffh	; bdad  -> orden_marca orden_volumen
	defw 0bd21h,0bd3ch	; bdb1  -> orden_envolvente orden_f8
	defw 0bd3dh,0bd3eh	; bdb5  -> orden_f7 orden_mezcla
	defw 0bd60h,0bce8h	; bdb9  -> orden_ruido orden_salta
	defw 0bd99h	; bdbd  -> orden_vibrato

; ----------------------------------------------------------------------
; DATOS canal_inicio: El estado inicial de un canal (desde +2); la copia lleva
;   30 bytes y sigue por los periodos
;   0xbdbf..0xbdd0  (17 bytes)
DATA_canal_inicio:
	defb 000h,000h,000h,001h,001h,001h,00fh,0e8h,0bdh,010h,010h,001h,001h,000h,000h,001h	; bdbf  ................
	defb 000h	; bdcf

; ----------------------------------------------------------------------
; DATOS periodos: Los periodos de las doce notas de la octava mas baja
;   0xbdd0..0xbde8  (24 bytes)
DATA_periodos:
	defw 00d5ch,00c9dh,00be7h,00b3ch,00a9bh,00a02h,00973h,008ebh,0086bh,007f2h,00780h,00714h	; bdd0

; ----------------------------------------------------------------------
; DATOS envolventes: Las ocho envolventes de tabla: 16 pasos de 4 bits (8
;   bytes cada una)
;   0xbde8..0xbe28  (64 bytes)
DATA_envolventes:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; bde8  ........
	defb 0feh,0dch,0bah,098h,076h,054h,032h,010h	; bdf0  ....vT2.
	defb 001h,023h,045h,067h,089h,0abh,0cdh,0efh	; bdf8  .#Eg....
	defb 0feh,0dch,0bah,098h,089h,0abh,0cdh,0efh	; be00  ........
	defb 089h,0abh,0cdh,0efh,0feh,0dch,0bah,098h	; be08  ........
	defb 0fdh,0b9h,075h,031h,0ech,0a8h,064h,020h	; be10  ..u1..d 
	defb 004h,08ch,0feh,0dch,0bah,098h,076h,054h	; be18  ......vT
	defb 004h,08ch,0feh,0dch,0bah,0abh,0cdh,0efh	; be20  ........

; ----------------------------------------------------------------------
; DATOS piezas: Las piezas de las musicas y los efectos: grupos de 3 bytes
;   (nota u orden, y sus dos argumentos)
;   0xbe28..0xc000  (472 bytes)
DATA_piezas:
	defb 0fah,0ffh,00ch	; be28
	defb 0f9h,0ffh,011h	; be2b
	defb 028h,01eh,01eh	; be2e
	defb 024h,00ah,00ah	; be31
	defb 026h,005h,005h	; be34
	defb 028h,00ah,00ah	; be37
	defb 029h,005h,005h	; be3a
	defb 02bh,01eh,01eh	; be3d
	defb 028h,01eh,01eh	; be40
	defb 034h,00ah,00ah	; be43
	defb 034h,005h,005h	; be46
	defb 034h,00ah,00ah	; be49
	defb 034h,005h,005h	; be4c
	defb 032h,00fh,00fh	; be4f
	defb 032h,00fh,00fh	; be52
	defb 030h,00fh,00fh	; be55
	defb 030h,005h,005h	; be58
	defb 030h,005h,005h	; be5b
	defb 030h,005h,005h	; be5e
	defb 030h,00fh,00fh	; be61
	defb 0ffh,0fah,0ffh	; be64
	defb 00bh,0f9h,0ffh	; be67
	defb 011h,018h,00fh	; be6a
	defb 00fh,018h,00fh	; be6d
	defb 00fh,018h,00fh	; be70
	defb 00fh,018h,00fh	; be73
	defb 00fh,013h,00fh	; be76
	defb 00fh,013h,00fh	; be79
	defb 00fh,018h,00fh	; be7c
	defb 00fh,018h,00fh	; be7f
	defb 00fh,018h,00fh	; be82
	defb 00fh,018h,00fh	; be85
	defb 00fh,017h,00fh	; be88
	defb 00fh,017h,00fh	; be8b
	defb 00fh,018h,00fh	; be8e
	defb 00fh,018h,005h	; be91
	defb 005h,018h,005h	; be94
	defb 005h,018h,005h	; be97
	defb 005h,018h,00fh	; be9a
	defb 00fh,0ffh,0fah	; be9d
	defb 0ffh,00ch,0f9h	; bea0
	defb 0ffh,011h,024h	; bea3
	defb 01eh,01eh,01fh	; bea6
	defb 00ah,00ah,021h	; bea9
	defb 005h,005h,024h	; beac
	defb 00ah,00ah,026h	; beaf
	defb 005h,005h,028h	; beb2
	defb 01eh,01eh,024h	; beb5
	defb 01eh,01eh,02bh	; beb8
	defb 00ah,00ah,02bh	; bebb
	defb 005h,005h,02bh	; bebe
	defb 00ah,00ah,02bh	; bec1
	defb 005h,005h,029h	; bec4
	defb 00fh,00fh,029h	; bec7
	defb 00fh,00fh,028h	; beca
	defb 00fh,00fh,028h	; becd
	defb 005h,005h,028h	; bed0
	defb 005h,005h,028h	; bed3
	defb 005h,005h,028h	; bed6
	defb 00fh,00fh,0ffh	; bed9
	defb 0fah,000h,00ch	; bedc
	defb 035h,002h,003h	; bedf
	defb 037h,002h,003h	; bee2
	defb 039h,002h,003h	; bee5
	defb 03bh,002h,003h	; bee8
	defb 03ch,004h,006h	; beeb
	defb 0ffh,0fah,000h	; beee
	defb 00ch,028h,003h	; bef1
	defb 004h,026h,003h	; bef4
	defb 004h,024h,003h	; bef7
	defb 004h,0ffh,0fah	; befa
	defb 000h,00ch,0f6h	; befd
	defb 000h,001h,0f9h	; bf00
	defb 000h,011h,0f5h	; bf03
	defb 000h,010h,000h	; bf06
	defb 002h,002h,024h	; bf09
	defb 000h,004h,0ffh	; bf0c
	defb 0fah,000h,00fh	; bf0f
	defb 0f9h,000h,011h	; bf12
	defb 054h,010h,020h	; bf15
	defb 0ffh,0fah,000h	; bf18
	defb 00fh,0f9h,000h	; bf1b
	defb 011h,0f6h,000h	; bf1e
	defb 000h,043h,010h	; bf21
	defb 020h,0ffh,0fah	; bf24
	defb 000h,00ch,0f9h	; bf27
	defb 000h,014h,0f6h	; bf2a
	defb 000h,001h,0f5h	; bf2d
	defb 000h,01fh,000h	; bf30
	defb 002h,002h,030h	; bf33
	defb 000h,002h,0f5h	; bf36
	defb 000h,010h,000h	; bf39
	defb 010h,010h,0f6h	; bf3c
	defb 000h,008h,0ffh	; bf3f
	defb 0fah,000h,00ch	; bf42
	defb 0fbh,000h,003h	; bf45
	defb 043h,002h,006h	; bf48
	defb 048h,002h,006h	; bf4b
	defb 0fch,000h,000h	; bf4e
	defb 0ffh,0fah,000h	; bf51
	defb 00ch,02eh,003h	; bf54
	defb 004h,02ch,003h	; bf57
	defb 004h,02ah,003h	; bf5a
	defb 004h,024h,007h	; bf5d
	defb 009h,0ffh,0fah	; bf60
	defb 000h,00fh,02bh	; bf63
	defb 001h,001h,02ch	; bf66
	defb 001h,001h,02dh	; bf69
	defb 001h,001h,02eh	; bf6c
	defb 001h,001h,02fh	; bf6f
	defb 001h,001h,030h	; bf72
	defb 001h,001h,031h	; bf75
	defb 020h,020h,0f9h	; bf78
	defb 000h,011h,0f3h	; bf7b
	defb 000h,031h,003h	; bf7e
	defb 080h,090h,0ffh	; bf81
	defb 0fah,000h,00ch	; bf84
	defb 0f3h,000h,030h	; bf87
	defb 0ffh,040h,040h	; bf8a
	defb 0ffh,0fah,000h	; bf8d
	defb 00ch,0f3h,000h	; bf90
	defb 02bh,0ffh,08fh	; bf93
	defb 09fh,0ffh,0fah	; bf96
	defb 000h,00ch,0f9h	; bf99
	defb 000h,014h,018h	; bf9c
	defb 003h,004h,0ffh	; bf9f
	defb 0fah,000h,00ch	; bfa2
	defb 0f9h,000h,011h	; bfa5
	defb 0f6h,000h,001h	; bfa8
	defb 0f5h,000h,018h	; bfab
	defb 000h,004h,006h	; bfae
	defb 0f6h,000h,008h	; bfb1
	defb 0ffh,0fah,000h	; bfb4
	defb 00ch,030h,000h	; bfb7
	defb 090h,0fbh,000h	; bfba
	defb 003h,034h,00eh	; bfbd
	defb 012h,032h,00eh	; bfc0
	defb 012h,02fh,01bh	; bfc3
	defb 024h,034h,00eh	; bfc6
	defb 012h,032h,00eh	; bfc9
	defb 012h,02fh,01bh	; bfcc
	defb 024h,034h,005h	; bfcf
	defb 00ch,032h,005h	; bfd2
	defb 006h,034h,00eh	; bfd5
	defb 012h,034h,005h	; bfd8
	defb 00ch,032h,005h	; bfdb
	defb 006h,034h,00eh	; bfde
	defb 012h,034h,005h	; bfe1
	defb 00ch,032h,005h	; bfe4
	defb 006h,034h,036h	; bfe7
	defb 048h,0fch,000h	; bfea
	defb 000h,0ffh,0fah	; bfed
	defb 000h,00bh,0f6h	; bff0
	defb 000h,001h,0f5h	; bff3
	defb 000h,01fh,000h	; bff6
	defb 060h,060h,0f6h	; bff9
	defb 000h,008h,0fdh	; bffc
	defb 006h	; bfff
