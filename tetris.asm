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
	addi t1, zero, 1
	stw t0, T_X(zero)
	stw t1, T_Y(zero)
	stw zero, T_type(zero)
	stw zero, T_orientation(zero)
	call draw_tetromino
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
	addi t0, zero, 1
	slli t0, t0, 20
	loop: 
		beq t0, zero, done
		addi t0, t0, -1
		call loop
	done:
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


; BEGIN:draw_tetromino
draw_tetromino: ; need to take into account a0 now sets activates only tetremino
	addi sp, sp, -4
	stw s0, 0(sp)
	
	addi sp, sp, -4
	stw s1, 0(sp)

	addi sp, sp, -4
	stw s2, 0(sp)

	ldw s0, T_X(zero)
	ldw s1, T_Y(zero)
	ldw t2, T_orientation(zero)
	ldw t3, T_type(zero)
	slli t3, t3, 4 ; Type*16
	slli t2, t2, 2; orientation * 4
	add t2, t2, t3; Type*16+ orientation * 4
	
	ldw t3, DRAW_Ax(t2) ; gets address of shape from DRAW_Ax/DRAW_Ay
	ldw t4, 0(t3) ; loads x offsets A1
	ldw t5, 4(t3) ; A2
	ldw t6, 8(t3) ; A3

	ldw t7, DRAW_Ay(t2) ; loads y offsets
	ldw t0, 0(t3) ; B1
	ldw t1, 4(t3) ; B2
	ldw s2, 8(t3) ; B3
	
	add a0, zero, s0
	add a1, zero, s1
	call set_pixel
	
	add t4, t4, s0
	add t0, t0, s1
	add a0, zero, t4
	add a1, zero, t0
	call set_pixel
	
	add t5, t5, s0
	add t1, t1, s1
	add a0, t5, zero
	add a1, t1, zero
	call set_pixel
	
	add t6, t6, s0
	add s2, s2, s1
	add a0, zero, t6
	add a1, zero, s2
	call set_pixel

	ldw s2, 0(sp)
	addi sp, sp, 4
	
	ldw s1, 0(sp)
	addi sp, sp, 4
	
	ldw s0, 0(sp)
	addi sp, sp, 4
	ret
;END:draw_tetromino


;BEGIN:generate_tetromino
generate_tetromino:
	addi sp, sp, -12
	stw s0, 0(sp)			; save callee-saved registers to stack
	stw s1, 4(sp)
	stw s2, 8(sp)			; x anchor point
	
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
	addi sp, sp, 12
;END:generate_tetromino

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
	jmpi end_rot

	right:
		addi s0, s0, 1
		andi s0, s0, 0x3		; s0 = s0 mod 4
		stw s0, T_orientation(zero)
		jmpi end_rot
	left:
		addi s0, s0, -1
		andi s0, s0, 0x3		; s0 = s0 mod 4
		stw s0, T_orientation(zero)
		jmpi end_rot
	end_rot:
		ldw s0, 0(sp)
		ldw s1, 4(sp)
		addi sp, sp, 8
		ret
;END:rotate_tetromino

;BEGIN:act
act:
	addi sp, sp, -12
	stw s0, 0(sp)
	stw s1, 4(sp)
	stw a0, 8(sp)

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
		; if no collision (TODO)
		ldw s0, T_X(zero)
		addi s0, s0, -1
		stw s0, T_X(zero)
		jmpi end_act
	mR:
		; if no collision (TODO)
		ldw s0, T_X(zero)
		addi s0, s0, 1
		stw s0, T_X(zero)
		jmpi end_act
	mD:
		; if no collision (TODO)
		ldw s0, T_Y(zero)
		addi s0, s0, 1
		stw s0, T_Y(zero)
		jmpi end_act
	rot:
		call rotate_tetromino
		addi a0, zero, OVERLAP
		check_overlap:
			; Check for OVERLAP collision
			call detect_collision
			
		jmpi end_act

	res:
		call reset_game
	
	end_act:
		ldw s0, 0(sp)
		ldw s1, 4(sp)
		ldw a0, 8(sp)
		addi sp, sp, 12
;END:act




;BEGIN:reset_game
reset_game:



;END:reset_game

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




































