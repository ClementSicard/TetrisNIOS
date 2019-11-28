addi sp, zero, LEDS
addi sp, sp, -20
stw s0, 0(sp)		; i = 0
stw s1, 4(sp)
stw s2, 8(sp)
stw s3, 12(sp)
stw s4, 16(sp)

loop_3:
    loop_2:
        addi s0, zero, 0
        addi s1, zero, RATE
            ; while (i < rate) :
            loop_1:
                bge s0, s1, out_1
                call draw_gsa
                call display_score
                call wait
                call get_input
                ; if button pressed, do required action
                addi a0, v0, 0
                call act
                call draw_tetromino

                addi s0, s0, 1
                call loop_1

            out_1:
                ; Remove falling tetro from GSA, not tetro structure
                ; try to move the falling tetro down (?)            
                addi a0, zero, moveD
                call act
                call draw_tetromino
                addi s2, ; falling tetro can be drawn ?
                bne s2, zero, loop_2
    
    addi s4, zero, PLACED
    stw s4, T_type(zero)