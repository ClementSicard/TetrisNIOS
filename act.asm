;BEGIN:act
act:
	addi sp, sp, -12
	stw ra, 0(sp)	
	stw s0, 4(sp)
	stw s1, 8(sp)
	
	addi s0, zero, moveL
	beq a0, s0, mL
	addi s0, zero, moveR
	beq a0, s0, mR
	addi s0, zero, moveD
	beq a0, s0, mD
	addi s0, zero, rotL
	beq a0, s0, rot
	addi s0, zero, rotR
	beq a0, s0, rot
	addi s0, zero, reset
	beq a0, s0, res
	

	mL:
		addi a0, zero, W_COL		; check for West collision
		call detect_collision
		beq a0, v0, end_act			; if collision goto end_act
		addi s6, zero, 0
		ldw s0, T_X(zero)
		addi s0, s0, -1
		stw s0, T_X(zero)
		call end_act
	mR:
		addi a0, zero, E_COL		; check for East collision
		call detect_collision
		beq a0, v0, end_act			; if collision goto end_act
		addi s6, zero, 0
		ldw s0, T_X(zero)
		addi s0, s0, 1
		stw s0, T_X(zero)
		call end_act
	mD:
		addi a0, zero, So_COL		; check for South collision
		call detect_collision		
		beq a0, v0, end_act			; if collision goto end_act
		addi s6, zero, 0
		ldw s0, T_Y(zero)
		addi s0, s0, 1
		stw s0, T_Y(zero)
		call end_act
	rot:
		ldw s0, T_orientation(zero)
		addi sp, sp, -4			; push x
		stw s0, 0(sp)
		call rotate_tetromino
		addi a0, zero, OVERLAP
		call detect_collision

		ldw s0, 0(sp)			; pop x
		addi sp, sp, 4
		
		addi a0, zero, NONE
		beq a0, v0, end_act

		h1:
			ldw s1, T_X(zero)
			addi sp, sp, -8
			stw s0, 0(sp)
			stw s1, 4(sp)
			addi sp, sp, 8

			ldw s1, T_X(zero)
			addi s3, zero, 6
			blt t2, t3, left_x

		right_x:
			; update x position
			addi s1, s1, -1
			stw s1, T_X(zero)
			addi a0, zero, OVERLAP
			call detect_collision

			ldw s0, 0(sp)
			ldw s1, 4(sp)
			addi sp, sp, 8

			addi a0, zero, NONE
			beq a0, v0, end_act		; if a0 == v0 --> goto end_act

			addi sp, sp, -8
			stw s0, 0(sp)
			stw s1, 4(sp)

			addi s1, s1, -1
			stw s1, T_X(zero)
			addi a0, zero, OVERLAP
			call detect_collision

			ldw s0, 0(sp)
			ldw s1, 4(sp)
			addi sp, sp, 8

			addi a0, zero, NONE
			beq a0, v0, end_act
			stw s0, T_orientation(zero)
			stw s1, T_X(zero)
			call end_act

		left_x:
			addi s1, s1, 1
			stw t1, T_X(zero)
			addi a0, zero, OVERLAP
			call detect_collision

			ldw s0, 0(sp)
			ldw s1, 4(sp)
			addi sp, sp, 8

			addi a0, zero, NONE
			beq a0, v0, end_act

			addi sp, sp, -8
			stw s0, 0(sp)
			stw s1, 4(sp)

			addi s1, s1, 1
			addi a0, zero, OVERLAP
			call detect_collision

			ldw s0, 0(sp)
			ldw s1, 4(sp)
			addi sp, sp, 8

			addi a0, zero, NONE
			beq a0, v0, end_act
			stw s1, T_X(zero)
			stw s0, T_orientation(zero)
			call end_act
	res:
		call reset_game
		call end_act
	
	end_act:
		ldw ra, 0(sp)	
		ldw s0, 4(sp)
		ldw s1, 8(sp)
		addi sp, sp, 12
		ret
;END:act