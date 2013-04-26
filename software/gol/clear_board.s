// gol/clear_board.s
// Subroutine to clear the GoL board
.EQU RET_BIT	4	// bit2

.EQU 	BOUNDARY_TOP	1
.EQU 	BOUNDARY_BOTTOM	222
.EQU 	BOUNDARY_LEFT	1
.EQU 	BOUNDARY_RIGHT	254
.EQU	BOUNDARY_MARGIN	3		// Amount to increment to get from right to left

//REGISTER USAGE
// 	-- SEE gol/ui_main.s --
// r21:		Old "current cursor"
// r22:		BOUNDARY_RIGHT
// r23:		bottom-right addr (if cursor > that, this generation is done)

.region code

	// SUBROUTINES SHOULDN'T BE EXECUTED FIRST
	b <Start>


// Beginning of subroutine
Clear_board:	ldadr r27, <numStickyPixels>	// Clear the sticky pixels
	mov r26, 0
	str r26, r27, 0		// Set numStickyPixels to 0

Delete_board:	add r21, r0, 0	// Store the old "current cursor"

	// Initialize r22 and r23
	mov r27, 8
	mov r22, BOUNDARY_RIGHT
	mov r26, BOUNDARY_BOTTOM
	mov r23, r5, r27 LSL	// Shift FB-bit to 0x100 or 0x000
	add r23, r23, r26		// Add Bottom y-coord to it
	mov r23, r23, r27 LSL	// Shift them over a byte
	add r23, r23, r22		// r23 has bottom right corner
	
	// Initialize current pixel to the beginning of the board
	mov r27, 8			// Shift value
	mov r25, r5, r27 LSL	// Shift the FB bit to 0x100
	add r25, r25, BOUNDARY_TOP
	mov r26, BOUNDARY_LEFT
	mov r0, r25, r27 LSL	// Shift FB-bit & Y-coord over a byte
	add r0, r0, r26			// Add in the X-coord to bottom byte
	

Clear_board_loop:		ldrb r27, r0, 0	// Grab the current pixel
	and r24, r27, -2	// Turn off bit0
	strb r24, r0, 0		// Store the new dead pixel

	// Check where the cursor is, and move accordingly
	mov r27, 255		// 0x00FF
	and r26, r0, r27	// Grab X-coord
	cmp r26, r22		// Check if we're at the right border
	add_eq r0, r0, BOUNDARY_MARGIN	// If so, add MARGIN amount to get to beginning of next row
	cmp r26, r22		
	add_ne r0, r0, 1	// If not, increment by 1
	
	cmp r0, r23			// Are we out of the board?
	b_le	<Clear_board_loop>

//__Clear_board loop

	// Restore the old "current cursor"
	add r0, r21, 0

	// Decide where to return to
	tst r19, RET_BIT
	b_eq	<Done_clear_board_0>	// exit subroutine w/ 1st option
	b		<Done_clear_board_1>	// exit subroutine w/ 2nd option

// ___END OF SUBROUTINE___
