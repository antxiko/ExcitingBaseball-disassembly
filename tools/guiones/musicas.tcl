# Para cotejar las dos musicas que una partida corta no alcanza: se juega como en partida.tcl y, en el bucle de
# la partida (0x80D2), el cuadro 1500 llama a `home_run` (0x8C11) y el 2600 salta a `torneo_ganado` (0x81BE),
# las rutinas del propio juego que ponen esas musicas. 4200 cuadros. Solo vale para el sonido: lo que se ve no
# es una jugada de verdad.
set ::hr 0
set ::gc 0
proc llama {dir} {
    set sp [expr {[reg sp] - 2}]
    debug write memory $sp 0xD2
    debug write memory [expr {$sp + 1}] 0x80
    reg sp $sp
    reg pc $dir
}
debug set_bp 0x80D2 {} {
    if {$::hr == 1} { set ::hr 2; llama 0x8C11 }
    if {$::gc == 1} { set ::gc 2; reg pc 0x81BE }
}
proc guion {n} {
    if {$n == 150} { keymatrixdown 8 0x01 }
    if {$n == 156} { keymatrixup 8 0x01 }
    if {$n > 300 && $n < 1400} {
        if {$n % 30 == 0} { keymatrixdown 8 0x01 }
        if {$n % 30 == 6} { keymatrixup 8 0x01 }
    }
    if {$n == 1500} { set ::hr 1 }
    if {$n == 2600} { set ::gc 1 }
    return [expr {$n >= 4200}]
}
