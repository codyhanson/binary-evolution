// gol/invert_board.s
// Subroutine to 

.EQU 	BOUNDARY_TOP	1
.EQU 	BOUNDARY_BOTTOM	222
.EQU 	BOUNDARY_LEFT	1
.EQU 	BOUNDARY_RIGHT	254
.EQU	BOUNDARY_MARGIN	2		// Amount to increment to get from right to left

.EQU	TOP_LEFT_ADDR		257
.EQU	BOTTOM_RIGHT_ADDR 	57086

//REGISTER USAGE
// 	-- SEE gol/ui_main.s --

.region code

	// SUBROUTINES SHOULDN'T BE EXECUTED FIRST
	b <Start>


// Beginning of subroutine
Invert_board:	add r21, r0, 0	// Store the old "current cursor"
	//restore last pixel
	strb r4, r3, 0

	mov r0, BOTTOM_RIGHT_ADDR
	mov r27, 65535			// 0x0FFFF
	add r27, r27, 1			// 0x10000
	add r26, r0, r27		// r26 gets FB2 addr

Invert_loop:	ldrb r25, r26, 0	// Get value in FB2
	or r27, r25, 1
	tst r25, 1				// Is it alive?
	and_ne r27, r25, -2		// If so, kill it
	strb r27, r26, 0		// Store inverted value to FB2 loc

	ldrb r25, r0, 0			// Get value in FB1
	or r27, r25, 1
	tst r25, 1				// Is it alive?
	and_ne r27, r25, -2		// If so, kill it
	strb r27, r0, 0			// Store inverted value to FB1 loc

	sub r26, r26, 1			// Dec FB2 loc
	sub r0, r0, 1			// Dec FB1 loc

	and r27, r0, 255		// Get x-coord
	cmp r27, 0
	sub_eq	r26, r26, BOUNDARY_MARGIN
	cmp r27, 0
	sub_eq	r0, r0, BOUNDARY_MARGIN

	cmp r0, TOP_LEFT_ADDR
	b_ge	<Invert_loop>

	// Restore the old "current cursor"
	add r0, r21, 0

	//set next last pixel
	add r3, r0, 0
	ldrb r4, r0, 0 	//pixel's current value

	b		<Done_invert_board>	// exit subroutine
// ___END OF SUBROUTINE___
