
	addi sp, sp, -40
	stw s0, 0(sp)
	stw s1, 4(sp)
	stw s2, 8(sp)
	stw s3, 12(sp)
	stw s4, 16(sp)
	stw s5, 20(sp)
	stw s6, 24(sp)
	stw a0, 28(sp)
	stw a1, 32(sp)
	stw ra, 36(sp)

	ldw s0, SCORE(zero)		; s0 = score
	
	addi s1, zero, 10
	addi s3, zero, 3
	
	ds_loop:
		cmpgei s4, s0, s1		; s4 = s0 >= 10
		cmpge s6, s3, zero		; counter >= 0
		or s6, s4, s6			; s6 = or les deux du dessus
		beq s6, zero, end_disp_score
		addi a0, s0, 0			; a0 = s0 (set ds_helper argument)
		addi a1, s3, 0			; a1 = counter (segment index)
		call ds_helper
		addi s0, v0, 0			; s0 = mod10(c)
		addi s3, s3, -1			; decrement counter s3
		call ds_loop

	end_disp_score:
		; print(c)
		addi s2, s0, font_data
		ldw s2, 0(s2)				; s2 = value to display in 7seg format
		stw s2, SEVEN_SEGS(zero)	
		
		ldw s0, 0(sp)
		ldw s1, 4(sp)
		ldw s2, 8(sp)
		ldw s3, 12(sp)
		ldw s4, 16(sp)
		ldw s5, 20(sp)
		ldw s6, 24(sp)
		ldw a0, 28(sp)
		ldw a1, 32(sp)
		ldw ra, 36(sp)
		addi sp, sp, 40
		ret

ds_helper:
	; returns a0 mod a1
	addi sp, sp, -28
	stw a0, 0(sp)
	stw a1, 4(sp)
	stw s0, 8(sp)
	stw s1, 12(sp)
	stw s2, 16(sp)
	stw s3, 20(sp)
	stw ra, 24(sp)
	
	addi s1, zero, 10
	mod_loop:
		blt a0, s1, end_mod			; if a0 < 10 goto end_mod
		addi a0, a0, -10			; decrement argument
		addi s0, s0, 1				; increment counter

	end_mod:
		addi v0, s0, 0				; return counter
		
		; print(a0)
		addi s3, a1, SEVEN_SEGS		; SEVEN_SEGS + index
		addi s2, a0, font_data
		ldw s2, 0(s2)				; s2 = value to display in 7seg format
		stw s2, 0(s3)	

		ldw a0, 0(sp)
		ldw a1, 4(sp)
		ldw s0, 8(sp)
		ldw s1, 12(sp)
		ldw s2, 16(sp)
		ldw s3, 20(sp)
		ldw ra, 24(sp)
		addi sp, sp, 28
		ret
