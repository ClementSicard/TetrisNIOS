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
	addi t0, zero, 6
	addi t1, zero, 7
	addi t2, zero, L
	addi t3, zero, N
	
	stw t0, T_X(zero)
	stw t1, T_Y(zero)
	stw t2, T_type(zero)
	stw t3, T_orientation(zero)

	call draw_tetromino
	call draw_gsa

	addi a0, zero, So_COL

	call detect_collision
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
	addi sp, sp, -20
	stw s0, 0(sp)
	stw s1, 4(sp)
	stw s2, 8(sp)
	stw s3, 12(sp)
	stw ra, 16(sp)

	addi s0, zero, 0
	addi s1, zero, 0
	addi s2, zero, 0
	addi s3, zero, 1 ; Mask value to get the LED to be turned on

	; a0 = x, a1 = y
	srli s0, a0, 2 		; s0 = x/4 --> LED[0, 1 ou 2]
	slli s0, t0, 2 		; s0 = LED + s0 * 4
	slli s1, a0, 3		; s1 = 8 * a0
	add s1, s1, a1		; s1 = s1 + a1 ;8*x + y 
	andi s1, s1, 0x1F	; s1 = s1 % 32
	sll  s3, s3, s1
	addi s2, s0, LEDS	; s2 = LED + s0
	ldw s4, 0(s2)
	or s3, s3, s4
	stw s3, 0 (s2)

	ldw s0, 0(sp)
	ldw s1, 4(sp)
	ldw s2, 8(sp)
	ldw s3, 12(sp)
	ldw ra, 16(sp)
	addi sp, sp, 20
	ret
; END:set_pixel

; BEGIN:wait
wait:
	addi sp, sp, -4
	stw ra, 0(sp)

	addi t0, zero, 1
	slli t0, t0, 20
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
	addi sp, sp, -12
	stw s0, 0(sp)
	stw s1, 4(sp)
	stw s2, 8(sp)
	stw ra, 12(sp)

	add s0, zero, a0 ; x
	add s1, zero, a1 ; y
	cmpgei s2, s0, 12
	bne s2, zero, retOne
	cmpgei s2, s1, 8
	bne s2, zero, retOne
	cmplti s2, s0, 0
	bne s2, zero, retOne
	cmplti s2, s1, 0
	bne s2, zero, retOne
	addi v0, zero, 0
	ret
	retOne:
		addi v0, zero, 1

		ldw s0, 0(sp)
		ldw s1, 4(sp)
		ldw s2, 8(sp)
		ldw ra, 12(sp)
		addi sp, sp, 12
		ret 
;END:in_gsa

;BEGIN:get_gsa
get_gsa:
	addi sp, sp, -12
	stw s0, 0(sp)
	stw s1, 4(sp)
	stw ra, 8(sp)

	add s0, zero, a0 ; x
	add s1, zero, a1 ; y
	slli s0, s0, 3 ; 8x
	add s0, s0, s1 ; 8x + y
	slli s0, s0, 2 ; (8x + y)* 4
	ldw v0, GSA(s0)

	ldw s0, 0(sp)
	ldw s1, 4(sp)
	ldw ra, 8(sp)
	addi sp, sp, 12
	ret
;END:get_gsa

;BEGIN:set_gsa
set_gsa:
	addi sp, sp, -12
	stw s0, 0(sp)
	stw s1, 4(sp)
	stw ra, 8(sp)
	
	add s0, zero, a0 ; x
	add s1, zero, a1 ; y
	slli s0, s0, 3 ; 8x
	add s0, s0, s1 ; 8x + y
	slli s0, s0, 2 ; (8x + y)* 4
	stw a2, GSA (s0)
	
	ldw s0, 0(sp)
	ldw s1, 4(sp)
	ldw ra, 8(sp)
	addi sp, sp, 12
	ret
;END:set_gsa

;BEGIN:draw_gsa
draw_gsa:
	addi sp, sp, -20
	stw ra, 0(sp)
	stw s0, 4(sp)
	stw s1, 8(sp)
	stw s5, 12(sp)
	stw s6, 16(sp)
	
	add s0, zero, zero ; s0 = x
	add s1, zero, zero ; s1 = y
	addi s5, zero, 12  ; s5 = 12 when x == 12 end
	addi s6, zero, 8   ; s6 = 8 when y == 8 end 
	
	loopX:
	beq s0, s5, end ; s0 == t5 end
	add a0, zero, s0 ; 
	loopY:
	beq s1, s6, incX
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
	ldw s5, 12(sp)
	ldw s6, 16(sp)
	addi sp, sp, 20 
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


;BEGIN:generate_tetromino
generate_tetromino:
	addi sp, sp, -16
	stw s0, 0(sp)			; save callee-saved registers to stack
	stw s1, 4(sp)
	stw s2, 8(sp)
	stw ra, 12(sp)			; x anchor point
	
	addi s1, zero, 5	

	rand:
		ldw s0, RANDOM_NUM(zero)	; read from RANDOM_NUM generator
		andi s0, s0, 0x0007		; mask s0 to take the last 3 bits (0x0007 = 0000 0000 0000 0111)
	
	bge s0, s1, rand			; if s0 (random nb) >= 5, then redraw a random number

	stw s0, T_type(zero)		; store type in memory	

	addi s2, zero, START_X		; x = 6
	stw s2, T_X(zero)			; store in memory anchor position

	addi s2, zero, START_Y		; y = 1
	stw s2, T_Y(zero)			; store in memory anchor position

	addi s2, zero, N			; set default orientation to North
	stw s2, T_orientation(zero)	; store orientation in memory

	ldw s0, 0(sp)				; restore saved registers
	ldw s1, 4(sp)
	ldw s2, 8(sp)
	ldw ra, 12(sp)
	addi sp, sp, 16
;END:generate_tetromino

check_col_helper:
	

;BEGIN:detect_collision
detect_collision:
	addi sp, sp, -4
	stw s0, 0(sp)


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
		addi sp, sp, -8
		stw a0, 0(sp)						; type de la collision, argument de detect_collision
		stw ra, 4(sp)
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
		addi sp, sp, -8
		stw a0, 0(sp)						; type de la collision, argument de detect_collision
		stw ra, 4(sp)
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
		addi sp, sp, -8
		stw a0, 0(sp)						; type de la collision, argument de detect_collision
		stw ra, 4(sp)
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
		addi sp, sp, -8
		stw a0, 0(sp)						; type de la collision, argument de detect_collision
		stw ra, 4(sp)
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
		ldw a0, 0(sp)
		ldw ra, 4(sp)
		ldw s0, 8(sp)
		addi sp, sp, 8
		ret

;END:detect_collision

;BEGIN:rotate_tetromino
rotate_tetromino:
	addi sp, sp, -16
	stw s0, 0(sp)				; backup saved register
	stw s1, 4(sp)
	stw ra, 8(sp)
	stw a0, 12(sp)

	ldw s0, T_orientation(zero)	; s0 = T_orientation
	
	addi s1, zero, rotR 		
	beq a0, s1, right 			; if a0 = rotR goto right 
	addi s1, zero, rotL
	beq a0, s1, left			; if a0 = rotL goto left
	call end_rot

	right:
		addi s0, s0, 1
		andi s0, s0, 0x3		; s0 = s0 mod 4 -> new orientation
		stw s0, T_orientation(zero)
		call end_rot
	left:
		addi s0, s0, -1
		andi s0, s0, 0x3		; s0 = s0 mod 4 -> new orientation
		stw s0, T_orientation(zero)
		call end_rot
	end_rot:
		ldw s0, 0(sp)
		ldw s1, 4(sp)
		ldw ra, 8(sp)
		ldw a0, 12(sp)
		addi sp, sp, 16
		ret
;END:rotate_tetromino

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


;BEGIN:reset_game
reset_game:
	addi sp, sp, -20
	stw s0, 0(sp)
	stw s1, 4(sp)
	stw s2, 8(sp)
	stw s3, 12(sp)
	stw ra, 16(sp)

	; set score to 0
	addi s0, zero, 0
	stw s0, SCORE(zero)		
	call display_score		; all 7-seg displays show zero

	addi s1, zero, 97		; s1 = 97
	addi s2, zero, 0
	reset_gsa:				; reset whole gsa
		beq s1, s2, end_res_gsa
		slli s3, s2, 2
		addi s3, s3, GSA
		ldw zero, 0(s3)
		addi s2, s2, 1
		call reset_gsa

	end_res_gsa:
	
	; new tetromino generated at (6,1)
	call generate_tetromino

	call draw_gsa
	
	ldw s0, 0(sp)
	ldw s1, 4(sp)
	ldw s2, 8(sp)
	ldw s3, 12(sp)
	ldw ra, 16(sp)
	addi sp, sp, 20
	ret
;END:reset_game


;BEGIN:increment_score
increment_score:
	addi sp, sp, -8
	stw s0, 0(sp)
	stw ra, 4(sp)

	ldw s0, SCORE(zero)			; s0 = score
	addi s0, s0, 1				; score = score + 1
	stw s0, SCORE(zero)
	ret
;END:increment_score


;BEGIN:display_score
display_score:
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
		cmpgei s4, s0, 10 		; s4 = s0 >= 10
		cmpgei s6, s3, 1 		; counter > 0
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
		slli s0, s0, 2
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
;END:display_score

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
	
	addi s0, zero, 0
	addi s1, zero, 10
	mod_loop:
		blt a0, s1, end_mod			; if a0 < 10 goto end_mod
		addi a0, a0, -10			; decrement argument
		addi s0, s0, 1				; increment counter
		call mod_loop

	end_mod:
		addi v0, s0, 0				; return counter
		
		; print(a0)
		slli a0, a0, 2
		slli a1, a1, 2
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

font_data:
	.word 0xFC		; 0
	.word 0x60		; 1
	.word 0xDA		; 2
	.word 0xF2		; 3
	.word 0x66		; 4
	.word 0xB6		; 5
	.word 0xBE		; 6
	.word 0xE0		; 7
	.word 0xFE 		; 8
	.word 0xF6		; 9


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
	































