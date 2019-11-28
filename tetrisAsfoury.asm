  ;; game state memory location
  .equ T_X, 0x1000                  ; falling tetrominoe position on x
  .equ T_Y, 0x1004                  ; falling tetrominoe position on y
  .equ T_type, 0x1008               ; falling tetrominoe type
  .equ T_orientation, 0x100C        ; falling tetrominoe orientation
  .equ SCORE,  0x1010               ; score
  .equ GSA, 0x1014                  ; Game State Array starting address
  .equ SEVEN_SEGS, 0x1198           ; 7-segment display addresses
  .equ LEDS, 0x2000                 ; LED address
  .equ RANDOM_NUM, 0x2010           ; Random number generator address
  .equ BUTTONS, 0x2030              ; Buttons addresses

  ;; type enumeration
  .equ C, 0x00
  .equ B, 0x01
  .equ T, 0x02
  .equ S, 0x03
  .equ L, 0x04

  ;; GSA type
  .equ NOTHING, 0x0
  .equ PLACED, 0x1
  .equ FALLING, 0x2

  ;; orientation enumeration
  .equ N, 0
  .equ E, 1
  .equ So, 2
  .equ W, 3
  .equ ORIENTATION_END, 4

  ;; collision boundaries
  .equ COL_X, 4
  .equ COL_Y, 3

  ;; Rotation enumeration
  .equ CLOCKWISE, 0
  .equ COUNTERCLOCKWISE, 1

  ;; Button enumeration
  .equ moveL, 0x01
  .equ rotL, 0x02
  .equ reset, 0x04
  .equ rotR, 0x08
  .equ moveR, 0x10
  .equ moveD, 0x20

  ;; Collision return ENUM
  .equ W_COL, 0
  .equ E_COL, 1
  .equ So_COL, 2
  .equ OVERLAP, 3
  .equ NONE, 4

  ;; start location
  .equ START_X, 6
  .equ START_Y, 1

  ;; game rate of tetrominoe falling down (in terms of game loop iteration)
  .equ RATE, 5

  ;; standard limits
  .equ X_LIMIT, 12
  .equ Y_LIMIT, 8


  ;; TODO Insert your code here

;BEGIN:main
main:
	addi sp, zero, LEDS

;	addi t0, zero, 6 
;	addi t1, zero, 1
;	addi t2, zero, S 
;	addi t3, zero, E

;	stw t0, T_X(zero)
;	stw t1, T_Y(zero)
;	stw t2, T_type(zero)
;	stw t3, T_orientation(zero)

;	addi a0, zero, FALLING
;	call draw_tetromino
;	call draw_gsa
	addi a0,zero,3
	add a1, zero,zero
	addi a2, zero, 2
	call set_gsa
	addi a0,zero,3
	addi a1, zero,1
	addi a2, zero, 2
	call set_gsa


	addi s0, zero, 12 ; s0 = 12
	add s1, zero, zero ; s1 = 0
	
	addi s2, zero, 4
	addi s3, zero, 8

	loop_main_2:
	beq s2, s3, end_setup
	add s1, zero, zero 
	loop_main_1: 
	beq s0, s1, loop_main_2_inc
	add a0, s1, zero
	add a1, zero, s2
	addi a2, zero, PLACED
	call set_gsa
	addi s1, s1, 1
	call loop_main_1
	loop_main_2_inc:
	addi s2, s2, 1
	call loop_main_2
	
	end_setup:
	call draw_gsa
	call wait
	call detect_full_line
	add a0, v0, zero
	call remove_full_line
	ret
;END:main



; BEGIN:clear_leds
clear_leds:
	stw zero, LEDS (zero) ; 0 -> 3
	stw zero, LEDS + 4 (zero) ; 4 -> 7
	stw zero, LEDS + 8 (zero) ; 8 -> 11
	ret
; END:clear_leds


; BEGIN:set_pixel
set_pixel:
	; Initialize registers
	addi t0, zero, 0
	addi t1, zero, 0
	addi t2, zero, 0
	addi t3, zero, 1 ; Mask value to get the LED to be turned on

	; a0 = x, a1 = y
	srli t0, a0, 2 		; t0 = x/4 --> LED[0, 1 ou 2]
	slli t0, t0, 2 		; t0 = LED + t0 * 4
	slli t1, a0, 3		; t1 = 8 * a0
	add t1, t1, a1		; t1 = t1 + a1 ;8*x + y 
	andi t1, t1, 0x1F	; t1 = t1 % 32
	sll  t3, t3, t1
	addi t2, t0, LEDS	; t2 = LED + t0
	ldw t4, 0(t2)
	or t3, t3, t4
	stw t3, 0 (t2)
	ret
; END:set_pixel

; BEGIN:wait
wait:
	addi sp, sp, -4
	stw ra, 0(sp)
	addi t0, zero, 1
	slli t0, t0, 21 ; set to 21 always
	loop: 
		beq t0, zero, done
		addi t0, t0, -1
		call loop
	done:
		ldw ra, 0(sp)
		addi sp, sp, 4
		ret
; END:wait

; BEGIN:in_gsa
in_gsa:
	add t0, zero, a0 ; x
	add t1, zero, a1 ; y
	cmpgei t2, t0, 12
	bne t2, zero, retOne
	cmpgei t2, t1, 8
	bne t2, zero, retOne
	cmplti t2, t0, 0
	bne t2, zero, retOne
	cmplti t2, t1, 0
	bne t2, zero, retOne
	addi v0, zero, 0
	ret
	retOne:
		addi v0, zero, 1
		ret 
;END:in_gsa

;BEGIN:get_gsa
get_gsa:
	add t0, zero, a0 ; x
	add t1, zero, a1 ; y
	slli t0, t0, 3 ; 8x
	add t0, t0, t1 ; 8x + y
	slli t0, t0, 2 ; (8x + y)* 4
	ldw v0, GSA(t0)
	ret
;END:get_gsa

;BEGIN:set_gsa
set_gsa:
	add t0, zero, a0 ; x
	add t1, zero, a1 ; y
	slli t0, t0, 3 ; 8x
	add t0, t0, t1 ; 8x + y
	slli t0, t0, 2 ; (8x + y)* 4
	stw a2, GSA (t0)
	ret
;END:set_gsa
;BEGIN:draw_gsa
draw_gsa:
	addi sp, sp, -12
	stw ra, 0(sp)
	stw s0, 4(sp)
	stw s1, 8(sp)
	
	add s0, zero, zero ; s0 = x
	add s1, zero, zero ; s1 = y
	addi t5, zero, 12  ; t5 = 12 when x == 12 end
	addi t6, zero, 8   ; t6 = 8 when y == 8 end 
	
	loopX:
	beq s0, t5, end ; s0 == t5 end
	add a0, zero, s0 ; 
	loopY:
	beq s1, t6, incX
	add a1, zero, s1
	call get_gsa 
	beq v0, zero, dontSet
	call set_pixel
	dontSet:
	addi s1, s1, 1
	call loopY
	incX:
	add s1, zero, zero
	addi s0, s0, 1
	call loopX

	
	end:
	ldw ra, 0(sp)
	ldw s0, 4(sp)
	ldw s1, 8(sp)
	addi sp, sp, 12 
	ret
;END:draw_gsa

;BEGIN:draw_tetromino
draw_tetromino:
	addi sp, sp, -12
	stw ra, 8(sp)
	stw s0, 4(sp)
	stw s1, 0(sp)
	addi s0, zero, 3
	add s1, zero, a0
	add a2, zero, a0
	loop_draw_tetromino:
		blt s0, zero, end_draw_tetromino
		add a0, s0, zero
		call get_tetromino_pair_n
		add a0, v0, zero
		add a1, v1, zero
		call set_gsa
		addi s0, s0, -1
		call loop_draw_tetromino
	end_draw_tetromino:
		ldw ra, 8(sp)
		ldw s0, 4(sp)
		ldw s1, 0(sp)
		addi sp, sp, 8
		ret
;END:draw_tetromino

;BEGIN:detect_collision
detect_collision:
	
	addi s0, zero, W_COL		
	beq a0, s0, case_W
	addi s0, zero, E_COL		
	beq a0, s0, case_E
	addi s0, zero, So_COL		
	beq a0, s0, case_So
	addi s0, zero, OVERLAP
	beq a0, s0, case_ol
	call end_det_col

	case_W:
		addi sp, sp, -4
		stw a0, 0(sp)
		addi s0, zero, 4
		loop_W:
			beq a0, s0, end_det_col
			call get_tetromino_pair_n  		;(v0,v1) la paire
			addi v0, v0, -1
			addi sp, sp, -8
			stw a0, 0(sp)
			stw a1, 4(sp)
					
			add a0, v0, zero				; a0 = x
			add a1, v1, zero				; a1 = y
			
			addi sp, sp, -8
			stw a0, 0(sp)
			stw a1, 4(sp)
			call in_gsa
			
			ldw a0, 0(sp)
			ldw a1, 4(sp) 
			addi sp, sp, 8

			bne v0, zero, col_w
			
			call get_gsa
			addi t0, zero, 1
			beq v0, t0, col_w
			addi v0, zero, NONE
			
			ldw a0, 0(sp)
			ldw a1, 4(sp)
			addi sp, sp, 8
			call loop_W
			
			col_w:
				addi v0, zero, W_COL
				ret
			addi a0, a0, 1
			call loop_W
	

	case_E:
		addi sp, sp, -4
		stw a0, 0(sp)
		addi s0, zero, 4
		loop_E:
			beq a0, s0, end_det_col
			call get_tetromino_pair_n  		;(v0,v1) la paire
			addi v0, v0, 1
			addi sp, sp, -8
			stw a0, 0(sp)
			stw a1, 4(sp)
					
			add a0, v0, zero				; a0 = x
			add a1, v1, zero				; a1 = y
			
			addi sp, sp, -8
			stw a0, 0(sp)
			stw a1, 4(sp)
			call in_gsa
			
			ldw a0, 0(sp)
			ldw a1, 4(sp) 
			addi sp, sp, 8

			bne v0, zero, col_e
			
			call get_gsa
			addi t0, zero, 1
			beq v0, t0, col_w
			addi v0, zero, NONE
			
			ldw a0, 0(sp)
			ldw a1, 4(sp)
			addi sp, sp, 8
			call loop_E
			
			col_e:
				addi v0, zero, E_COL
				ret
			addi a0, a0, 1
			call loop_E
	


	case_So:
		addi sp, sp, -4
		stw a0, 0(sp)
		addi s0, zero, 4
		add a0, zero,zero
		loop_So:
			beq a0, s0, end_det_col
			call get_tetromino_pair_n  		;(v0,v1) la paire
			addi v1, v1, 1
			addi sp, sp, -8
			stw a0, 0(sp)
			stw a1, 4(sp)
					
			add a0, v0, zero				; a0 = x
			add a1, v1, zero				; a1 = y
			
			addi sp, sp, -8
			stw a0, 0(sp)
			stw a1, 4(sp)
			call in_gsa
			
			ldw a0, 0(sp)
			ldw a1, 4(sp) 
			addi sp, sp, 8

			bne v0, zero, col_so
			
			call get_gsa
			addi t0, zero, 1
			beq v0, t0, col_so
			addi v0, zero, NONE
			
			ldw a0, 0(sp)
			ldw a1, 4(sp)
			addi sp, sp, 8
			addi a0, a0, 1
			call loop_So
			
			col_so:
				addi v0, zero, So_COL
				ret
			addi a0, a0, 1
			call loop_So



	case_ol:
		addi sp, sp, -4
		stw a0, 0(sp)
		addi s0, zero, 4
		loop_ol:
			beq a0, s0, end_det_col
			call get_tetromino_pair_n  		;(v0,v1) la paire
			addi sp, sp, -8
			stw a0, 0(sp)
			stw a1, 4(sp)
					
			add a0, v0, zero				; a0 = x
			add a1, v1, zero				; a1 = y
			
			addi sp, sp, -8
			stw a0, 0(sp)
			stw a1, 4(sp)
			call in_gsa
			
			ldw a0, 0(sp)
			ldw a1, 4(sp) 
			addi sp, sp, 8

			bne v0, zero, col_ol
			
			call get_gsa
			addi t0, zero, 1
			beq v0, t0, col_ol
			addi v0, zero, NONE
			
			ldw a0, 0(sp)
			ldw a1, 4(sp)
			addi sp, sp, 8
			call loop_ol
			
			col_ol:
				addi v0, zero, OVERLAP
				ret
			addi a0, a0, 1
			call loop_ol
	
	




	end_det_col:
			ldw a0, 0(sp)
			addi sp, sp, 4
			ret

;END:detect_collision

;BEGIN:rotate_tetromino
rotate_tetromino:
	addi sp, sp, -8
	stw s0, 0(sp)				; backup saved register
	stw s1, 4(sp)

	ldw s0, T_orientation(zero)
	
	addi s1, zero, rotR
	beq a0, s1, right
	addi s1, zero, rotL
	beq a0, s1, left
	call end_rot

	right:
		addi s0, s0, 1
		andi s0, s0, 0x3		; s0 = s0 mod 4
		stw s0, T_orientation(zero)
		call end_rot
	left:
		addi s0, s0, -1
		andi s0, s0, 0x3		; s0 = s0 mod 4
		stw s0, T_orientation(zero)
		call end_rot
	end_rot:
		ldw s0, 0(sp)
		ldw s1, 4(sp)
		addi sp, sp, 8
		ret
;END:rotate_tetromino

;BEGIN:act
act:
	addi sp, sp, -20
	stw s0, 0(sp)
	stw s1, 4(sp)
	stw s2, 8(sp)
	stw s3, 12(sp)
	stw a0, 16(sp)

	add s2, zero, zero				; nb_col register
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
		ldw s0, T_X(zero)
		addi s0, s0, -1
		stw s0, T_X(zero)
		call end_act
	mR:
		addi a0, zero, E_COL		; check for East collision
		call detect_collision
		beq a0, v0, end_act			; if collision goto end_act
		ldw s0, T_X(zero)
		addi s0, s0, 1
		stw s0, T_X(zero)
		call end_act
	mD:
		addi a0, zero, So_COL		; check for South collision
		call detect_collision
		beq a0, v0, end_act			; if collision goto end_act
		ldw s0, T_Y(zero)
		addi s0, s0, 1
		stw s0, T_Y(zero)
		call end_act
	rot:
		call rotate_tetromino
		addi a0, zero, OVERLAP
		addi s0, zero, 2
		check_overlap:
			call detect_collision	; Check for OVERLAP collision
			bne a0, v0, end_act
			addi s2, s2, 1			; nb_col = nb_col + 1
			beq s2, s0, end_act
			; check if anchor on left or right
			ldw s3, T_X(zero)
			addi s1, zero, START_X
			bge s3, s1, r_right 	; if x >= 6 goto right
									
			addi s3, s3, 1		; center from left if x < 6
			stw s3, T_X(zero)
			call loop_rot_overlap
			r_right:					; center from the right
				addi s3, s3, -1
				stw s3, T_X(zero)
			loop_rot_overlap:
				call check_overlap
		call end_act
	res:
		;call reset_game
	
	end_act:
		ldw s0, 0(sp)
		ldw s1, 4(sp)
		ldw s2, 8(sp)
		ldw s3, 12(sp)
		ldw a0, 16(sp)
		addi sp, sp, 20
		ret
;END:act

;BEGIN:get_input
get_input:
	ldw v0, BUTTONS+4(zero)
	stw zero, BUTTONS+4(zero)
	ret
;END:get_input

;BEGIN:detect_full_line
detect_full_line:
	addi sp, sp, -28
	stw s0, 0(sp)
	stw s1, 4(sp)
	stw s2, 8(sp)
	stw s3, 12(sp)
	stw s4, 16(sp)
	stw s5, 20(sp)
	stw ra, 24(sp)
	
	add s0, zero, zero
	add s1, zero, zero
	addi s2, zero, 8
	addi s3, zero, 12
	addi s4, zero, 1
	addi s5, zero, 12
	loop1_detect_line: 
	beq s0, s2, end_detect_line ; if s0 = 8 => done and line 8 detected
		loop2_detect_line: 
		beq s1, s3, incLoop1 ; if s1 = 12 => go to next line inc y and set x = 0
		add a0, s1, zero ; a0 = x = s1
		add a1, s0, zero ; a1 = y = s0
		call get_gsa     ; get (x,y)
		bne v0, s4, incLoop1 ; get_gsa(x,y) != 1 => no continous line => check next line inc y and set x = 0
		addi s1, s1, 1        ; inc x and loop on next x because get_gsa = 1
		beq s1, s5, line_found ; if x = 12 => placed in each (x,y) in line lineFound
		call loop2_detect_line 
	incLoop1:
		addi s0, s0, 1
		add  s1, zero, zero
		call loop1_detect_line
	end_detect_line:
		addi v0, zero, 8
		ldw s0, 0(sp)
		ldw s1, 4(sp)
		ldw s2, 8(sp)
		ldw s3, 12(sp)
		ldw s4, 16(sp)
		ldw s5, 20(sp)
		ldw ra, 24(sp)
		addi sp, sp, 28
		ret
	line_found:
		add v0, zero, s0 ; y
		ldw s0, 0(sp)
		ldw s1, 4(sp)
		ldw s2, 8(sp)
		ldw s3, 12(sp)
		ldw s4, 16(sp)
		ldw s5, 20(sp)
		ldw ra, 24(sp)
		addi sp, sp, 28
		ret
;END:detect_full_line

;BEGIN:remove_full_line
remove_full_line:
	addi sp, sp, -4
	stw ra, 0(sp)

	
	addi sp, sp, -4
	stw a0, 0(sp) ; add a0 in stack => corresponds to line number
	
	addi a1, zero, NOTHING
	call helper_remove_line
	call clear_leds
	call draw_gsa
	call wait
	
	ldw a0, 0(sp) ; a0 = line nb
	

	addi a1, zero, PLACED
	call helper_remove_line
	call clear_leds
	call draw_gsa
	call wait
	
	ldw a0, 0(sp) ; a0 = line nb

	addi a1, zero, NOTHING
	call helper_remove_line
	call clear_leds
	call draw_gsa
	call wait	
	
	ldw a0, 0(sp) ; a0 = line nb

	addi a1, zero, PLACED
	call helper_remove_line
	call clear_leds
	call draw_gsa
	call wait	
	
	ldw a0, 0(sp) ; a0 = line nb
	
	addi a1, zero, NOTHING
	call helper_remove_line
	call clear_leds
	call draw_gsa
	call wait

	ldw a0, 0(sp) ; a0 = line nb
	addi sp, sp, 4

	call helper_move_all_down
	call clear_leds
	call draw_gsa
		
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
;END:remove_full_line


;BEGIN:helper
get_tetromino_pair_n:
	addi sp, sp, -36
	stw ra , 32(sp)
	stw s0, 28(sp)
	stw s1, 24(sp)
	stw s2, 20(sp)
	stw s3, 16(sp)
	stw s4, 12(sp)
	stw s5, 8(sp)
	stw s6, 4(sp)
	stw s7, 0(sp)
	
	
	ldw s0, T_X(zero)
	ldw s1, T_Y(zero)
	ldw s2, T_orientation(zero)
	ldw s3, T_type(zero)

	addi s6, zero, 1
	addi s7, zero, 2
	addi t0, zero, 3

	slli s3, s3, 4 ; Type*16
	slli s2, s2, 2; orientation * 4
	add s2, s2, s3 ; t2 = Type*16+ orientation * 4

	ldw s4, DRAW_Ax(s2) ; gets address of shape from DRAW_Ax/DRAW_Ay
	ldw s5, DRAW_Ay(s2) ; loads y offsets
	

	beq a0, zero, pair1 
	beq a0, s6, pair2
	beq a0, s7, pair3
	beq a0, t0, pair4
	pair1:
		add v0, zero, s0
		add v1, zero, s1
		call end_get_tet_n
	pair2:
		ldw s3, 0(s4) ; x offset A1
		ldw s2, 0(s5) ; y offset B1
		add v0, s0, s3
		add v1, s1, s2
		call end_get_tet_n
	pair3:
		ldw s3, 4(s4) ; x offset A2
		ldw s2, 4(s5) ; y offset B2
		add v0, s0, s3
		add v1, s1, s2
		call end_get_tet_n
	pair4:
		ldw s3, 8(s4) ; x offset A3
		ldw s2, 8(s5) ; y offset B3
		add v0, s0, s3
		add v1, s1, s2
		call end_get_tet_n
	
	end_get_tet_n:
		ldw ra, 32(sp)
		ldw s0, 28(sp)
		ldw s1, 24(sp)
		ldw s2, 20(sp)
		ldw s3, 16(sp)
		ldw s4, 12(sp)
		ldw s5, 8(sp)
		ldw s6, 4(sp)
		ldw s7, 0(sp)
		addi sp, sp, 36
		ret
helper_remove_line:
	;a0 line number
	; a1 value to add to line NOTHING/PLACED
	addi sp, sp, -20
	stw s0, 0(sp)
	stw s1, 4(sp)
	stw s2, 4(sp)
	stw ra, 8(sp)
	stw s3, 12(sp)

	addi s0, zero, 12 ; s0 = 12 = xfinal
	add s1, zero, zero ; s1 = 0 = x
	
	add s2, a0, zero ; Line that has been detected
	add s3, a1, zero ; s3 = NOTHING/PLACED

	loop_detected_1: ; loop to remove full line
	beq s0, s1, end_loop_detected_1
	add a0, s1, zero
	add a1, zero, s2
	add a2, zero, s3 ; set each elem of line to s3
	call set_gsa
	addi s1, s1, 1
	call loop_detected_1
	end_loop_detected_1:
	ldw s0, 0(sp)
	ldw s1, 4(sp)
	ldw s2, 4(sp)
	ldw ra, 8(sp)
	ldw s3, 12(sp)
	addi sp, sp, 20
	ret
helper_move_all_down:
	addi sp, sp, -20
	stw s0, 0(sp)
	stw s1, 4(sp)
	stw s2, 4(sp)
	stw ra, 8(sp)
	stw s3, 12(sp)


	add s0, zero, zero ; s0 = x
	addi s1, zero, 12  ; s1 = xfinal
	add s2, zero, a0   ; s2 = y (start from above the line that has been detected)
	addi s3, zero, 0   ; s3 = yfinal

	loop_move_down_y:
	beq s2, s3, end_loop_move_down
	addi s0, zero, 0
	loop_move_down_x:
	beq s0, s1, inc_loop_move_down_y
	add a0, s0, zero
	add a1, s2, zero
	addi a1, a1, -1
	call get_gsa
	add a0, s0, zero
	add a1, s2, zero
	add a2, v0, zero
	call set_gsa
	addi s0, s0, 1
	call loop_move_down_x
	inc_loop_move_down_y:
	addi s2, s2, -1
	call loop_move_down_y
	end_loop_move_down:
	addi s0, zero, 0
	loop_line_zero:
	beq s0, s1, end_helper_move_down
	add a0, s0, zero
	addi a1, zero, 0
	addi a2, zero, NOTHING
	call set_gsa 
	addi s0, s0, 1
	call loop_line_zero
	end_helper_move_down:
	ldw s0, 0(sp)
	ldw s1, 4(sp)
	ldw s2, 4(sp)
	ldw ra, 8(sp)
	ldw s3, 12(sp)
	addi sp, sp, 20
	ret
;END:helper
C_N_X:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

C_N_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0xFFFFFFFF

C_E_X:
  .word 0x01
  .word 0x00
  .word 0x01

C_E_Y:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

C_So_X:
  .word 0x01
  .word 0x00
  .word 0x01

C_So_Y:
  .word 0x00
  .word 0x01
  .word 0x01

C_W_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0xFFFFFFFF

C_W_Y:
  .word 0x00
  .word 0x01
  .word 0x01

B_N_X:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x02

B_N_Y:
  .word 0x00
  .word 0x00
  .word 0x00

B_E_X:
  .word 0x00
  .word 0x00
  .word 0x00

B_E_Y:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x02

B_So_X:
  .word 0xFFFFFFFE
  .word 0xFFFFFFFF
  .word 0x01

B_So_Y:
  .word 0x00
  .word 0x00
  .word 0x00

B_W_X:
  .word 0x00
  .word 0x00
  .word 0x00

B_W_Y:
  .word 0xFFFFFFFE
  .word 0xFFFFFFFF
  .word 0x01

T_N_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

T_N_Y:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0x00

T_E_X:
  .word 0x00
  .word 0x01
  .word 0x00

T_E_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

T_So_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

T_So_Y:
  .word 0x00
  .word 0x01
  .word 0x00

T_W_X:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0x00

T_W_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

S_N_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

S_N_Y:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

S_E_X:
  .word 0x00
  .word 0x01
  .word 0x01

S_E_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

S_So_X:
  .word 0x01
  .word 0x00
  .word 0xFFFFFFFF

S_So_Y:
  .word 0x00
  .word 0x01
  .word 0x01

S_W_X:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

S_W_Y:
  .word 0x01
  .word 0x00
  .word 0xFFFFFFFF

L_N_X:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x01

L_N_Y:
  .word 0x00
  .word 0x00
  .word 0xFFFFFFFF

L_E_X:
  .word 0x00 ; 0
  .word 0x00 ; 0
  .word 0x01 ; 1

L_E_Y:
  .word 0xFFFFFFFF ; -1
  .word 0x01 ; 1
  .word 0x01 ; 1

L_So_X:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0xFFFFFFFF

L_So_Y:
  .word 0x00
  .word 0x00
  .word 0x01

L_W_X:
  .word 0x00
  .word 0x00
  .word 0xFFFFFFFF

L_W_Y:
  .word 0x01
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

DRAW_Ax:                        ; address of shape arrays, x axis
    .word C_N_X ; 0 C start 
    .word C_E_X ; 4
    .word C_So_X ; 8
    .word C_W_X ; 12
    .word B_N_X ; 16 B start
    .word B_E_X ; 20
    .word B_So_X ; 24
    .word B_W_X  ; 28
    .word T_N_X ; 32 T start
    .word T_E_X ; 36
    .word T_So_X ; 40
    .word T_W_X ; 44
    .word S_N_X ; 48 S start
    .word S_E_X ; 52
    .word S_So_X ; 56
    .word S_W_X ; 60
    .word L_N_X ; 64 L start
    .word L_E_X ; 68
    .word L_So_X ; 72
    .word L_W_X ; 76

DRAW_Ay:                        ; address of shape arrays, y_axis
    .word C_N_Y
    .word C_E_Y
    .word C_So_Y
    .word C_W_Y
    .word B_N_Y
    .word B_E_Y
    .word B_So_Y
    .word B_W_Y
    .word T_N_Y
    .word T_E_Y
    .word T_So_Y
    .word T_W_Y
    .word S_N_Y
    .word S_E_Y
    .word S_So_Y
    .word S_W_Y
    .word L_N_Y
    .word L_E_Y
    .word L_So_Y
    .word L_W_Y




































