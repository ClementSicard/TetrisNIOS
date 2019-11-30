detect_collision:
	addi sp, sp, -12
    stw s0, 0(sp)
    stw a0, 4(sp)
    stw ra, 8(sp)


	addi s0, zero, W_COL		
	beq a0, s0, case_W
	addi s0, zero, E_COL		
	beq a0, s0, case_E
	addi s0, zero, So_COL		
	beq a0, s0, case_So
	addi s0, zero, OVERLAP
	beq a0, s0, case_ol
	addi v0, zero, NONE
	call end_det_col

	case_W:
		addi s0, zero, 4
		addi a0, zero, 0					; loop index
		loop_W:
			beq a0, s0, end_det_col			; if loop index = 4 goto end_det_col
			
			call get_tetromino_pair_n  		;(v0,v1) la paire  a0 --> index of loop
			addi v0, v0, -1
	
			addi sp, sp, -8
			stw a0, 0(sp)					; save loop index to stack
			stw a1, 4(sp)					; save a1 in case (???)
					
			add a0, v0, zero				; a0 = x - 1
			add a1, v1, zero				; a1 = y
			
			addi sp, sp, -8
			stw a0, 0(sp)					; push a0 = x - 1 to the stack
			stw a1, 4(sp)					; push a1 = y to stack 
			
			call in_gsa
			
			ldw a0, 0(sp)					; reuse arguments for in_gsa to apply to get_gsa (in case modified)
			ldw a1, 4(sp) 
			addi sp, sp, 8

			bne v0, zero, col_w				; if not in gsa --> collision
			
			call get_gsa					
			addi t0, zero, 1
			beq v0, t0, col_w				; if get_gsa = 1 --> collision

			addi v0, zero, NONE				; default value for v0
			
			ldw a0, 0(sp)					; takes back loop index
			ldw a1, 4(sp)					; takes back a1 initial value (not necessarily known)
			addi sp, sp, 8
			addi a0, a0, 1					; increment loop index
			call loop_W
			
			col_w:
				addi v0, zero, W_COL
				call end_det_col
	
	case_E:
		addi s0, zero, 4
		addi a0, zero, 0					; loop index
		loop_E:
			beq a0, s0, end_det_col			; if loop index = 4 goto end_det_col
			
			call get_tetromino_pair_n  		;(v0,v1) la paire  a0 --> index of loop
			addi v0, v0, 1
	
			addi sp, sp, -8
			stw a0, 0(sp)					; save loop index to stack
			stw a1, 4(sp)					; save a1 in case (???)
					
			add a0, v0, zero				; a0 = x + 1
			add a1, v1, zero				; a1 = y
			
			addi sp, sp, -8
			stw a0, 0(sp)					; push a0 = x + 1 to the stack
			stw a1, 4(sp)					; push a1 = y to stack 
			
			call in_gsa
			
			ldw a0, 0(sp)					; reuse arguments for in_gsa to apply to get_gsa (in case modified)
			ldw a1, 4(sp) 
			addi sp, sp, 8

			bne v0, zero, col_e				; if not in gsa --> collision
			
			call get_gsa					
			addi t0, zero, 1
			beq v0, t0, col_e				; if get_gsa = 1 --> collision

			addi v0, zero, NONE				; default value for v0
			
			ldw a0, 0(sp)					; takes back loop index
			ldw a1, 4(sp)					; takes back a1 initial value (not necessarily known)
			addi sp, sp, 8
			addi a0, a0, 1					; increment loop index
			call loop_E
			
			col_e:
				addi v0, zero, E_COL
				call end_det_col

	case_So:
		addi s0, zero, 4
		addi a0, zero, 0					; loop index
		loop_So:
			beq a0, s0, end_det_col			; if loop index = 4 goto end_det_col
			
			call get_tetromino_pair_n  		;(v0,v1) la paire  a0 --> index of loop
			addi v1, v1, 1
	
			addi sp, sp, -8
			stw a0, 0(sp)					; save loop index to stack
			stw a1, 4(sp)					; save a1 in case (???)
					
			add a0, v0, zero				; a0 = x
			add a1, v1, zero				; a1 = y + 1
			
			addi sp, sp, -8
			stw a0, 0(sp)					; push a0 = x to the stack
			stw a1, 4(sp)					; push a1 = y + 1 to stack 
			
			call in_gsa
			
			ldw a0, 0(sp)					; reuse arguments for in_gsa to apply to get_gsa (in case modified)
			ldw a1, 4(sp) 
			addi sp, sp, 8

			bne v0, zero, col_So			; if not in gsa --> collision
			
			call get_gsa					
			addi t0, zero, 1
			beq v0, t0, col_So				; if get_gsa = 1 --> collision

			addi v0, zero, NONE				; default value for v0
			
			ldw a0, 0(sp)					; takes back loop index
			ldw a1, 4(sp)					; takes back a1 initial value (not necessarily known)
			addi sp, sp, 8
			addi a0, a0, 1					; increment loop index
			call loop_So
			
			col_So:
				addi v0, zero, So_COL
				call end_det_col


	case_ol:
		addi s0, zero, 4
		addi a0, zero, 0					; loop index
		loop_ol:
			beq a0, s0, end_det_col			; if loop index = 4 goto end_det_col
			
			call get_tetromino_pair_n  		;(v0,v1) la paire  a0 --> index of loop
	
			addi sp, sp, -8
			stw a0, 0(sp)					; save loop index to stack
			stw a1, 4(sp)					; save a1 in case (???)
					
			add a0, v0, zero				; a0 = x - 1
			add a1, v1, zero				; a1 = y
			
			addi sp, sp, -8
			stw a0, 0(sp)					; push a0 = x - 1 to the stack
			stw a1, 4(sp)					; push a1 = y to stack 
			
			call in_gsa
			
			ldw a0, 0(sp)					; reuse arguments for in_gsa to apply to get_gsa (in case modified)
			ldw a1, 4(sp) 
			addi sp, sp, 8

			bne v0, zero, col_ol			; if not in gsa --> collision
			
			call get_gsa					
			addi t0, zero, 1
			beq v0, t0, col_ol				; if get_gsa = 1 --> collision

			addi v0, zero, NONE				; default value for v0
			
			ldw a0, 0(sp)					; takes back loop index
			ldw a1, 4(sp)					; takes back a1 initial value (not necessarily known)
			addi sp, sp, 8
			addi a0, a0, 1					; increment loop index
			call loop_ol
			
			col_ol:
				addi v0, zero, OVERLAP
				call end_det_col

	end_det_col:
		ldw s0, 0(sp)
        ldw a0, 4(sp)
        ldw ra, 8(sp)
		addi sp, sp, 12
		ret

