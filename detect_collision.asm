detect_collision:
	addi sp, sp, -8
	stw a0, 0(sp)
    stw ra, 4(sp)

    addi t0, zero, OVERLAP
	beq a0, t0, case_OL
	addi t0, zero, W_COL
	beq a0, t0, case_W
	addi t0, zero, E_COL
	beq a0, t0, case_E
	addi t0, zero, So_COL
	beq a0, t0, case_So

	case_W:
        ldw t0, T_X(zero)
        ldw t1, T_Y(zero)
        
        addi sp, sp, -8
        stw t1, 0(sp)
        stw t0, 4(sp)
        
        addi t0, t0, -1
        stw t0, T_X(zero)
        call det
    
    case_E:
        ldw t0, T_X(zero)
        ldw t1, T_Y(zero)
        
        addi sp, sp, -8
        stw t1, 0(sp)
        stw t0, 4(sp)
        
        addi t0, t0, 1
        stw t0, T_X(zero)
        call det
	
    case_So:
        ldw t0, T_X(zero)
        ldw t1, T_Y(zero)
        
        addi sp, sp, -8
        stw t1, 0(sp)
        stw t0, 4(sp)
        
        addi t1, t1, 1
        stw t1, T_Y(zero)
        call det
        
    case_OL:
        ldw t0, T_X(zero)
        ldw t1, T_Y(zero)
        
        addi sp, sp, -8
        stw t1, 0(sp)
        stw t0, 4(sp)
        
        call det
	
    det:
        ldw t0, T_orientation(zero)
        slli t0, t0, 2
        ldw t1, T_type(zero)
        slli t1, t1, 4 
        add t0, t0, t1 
        ldw a0, T_X(zero) 
        ldw a1, T_Y(zero)
        
        addi sp, sp, -4
        stw t0, 0(sp)
        
        call in_gsa
        bne v0, zero, col
        call get_gsa
        addi t5, zero, PLACED
        
        beq t5, v0, col
        
        ldw t0, 0(sp)
        addi sp, sp, 4
        
        ldw t3, DRAW_Ax(t0)
        ldw t4, DRAW_Ay(t0)
        ldw a0, 0(t3)
        ldw a1, 0(t4)
        ldw t1, T_X(zero)
        ldw t2, T_Y(zero)
        add a0, a0, t1
        add a1, a1, t2
        
        addi sp, sp, -4
        stw t0, 0(sp)
        
        call in_gsa
        bne v0, zero, col
        call get_gsa
        addi t5, zero, PLACED
        beq v0, t5, col
        
        ldw t0, 0(sp)
        addi sp, sp, 4
        
        ldw t3, DRAW_Ax(t0)
        ldw t4, DRAW_Ay(t0)
        ldw a0, 4(t3)
        ldw a1, 4(t4)
        ldw t1, T_X(zero)
        ldw t2, T_Y(zero)
        add a0, a0, t1
        add a1, a1, t2
        
        addi sp, sp, -4
        stw t0, 0(sp)
        
        call in_gsa
        bne v0, zero, col
        call get_gsa
        addi t5, zero, PLACED
        beq v0, t5, col
        
        ldw t0, 0(sp)
        addi sp, sp, 4
        
        ldw t3, DRAW_Ax(t0)
        ldw t4, DRAW_Ay(t0)
        ldw a0, 8(t3)
        ldw a1, 8(t4)
        ldw t1, T_X(zero)
        ldw t2, T_Y(zero)
        add a0, a0, t1
        add a1, a1, t2
        
        addi sp, sp, -4
        stw t0, 0(sp)
        
        call in_gsa
        bne v0, zero, col
        call get_gsa
        addi t5, zero, PLACED
        beq v0, t5, col
        
        ldw t0, 0(sp)
        addi sp, sp, 4
        
        call detect_col_end
    
    col:    
        ldw t0, 0(sp)
        addi sp, sp, 4
        
        
        ldw t1, 0(sp)
        ldw t2, 4(sp)
        addi sp, sp, 8
        
        stw t0, T_X(zero)
        stw t1, T_Y(zero)
        
        ldw v0, 0(sp)
        ldw ra, 4(sp)
        addi sp, sp, 4
        ret

	detect_col_end:
        ldw t1, 0(sp)
        ldw t0, 4(sp)
        addi sp, sp, 8
        
        stw t0, T_X(zero)
        stw t1, T_Y(zero)
        addi v0, zero, NONE
        
        ldw a0, 0(sp)
        ldw ra, 4(sp)
        addi sp, sp, 8
        ret