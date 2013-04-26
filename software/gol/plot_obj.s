//
// File: plot_obj.s -- Plot Game of Life Object
// Descr: 	Plots a GoL object on the cursor based on a letter key (a,b,c,...,o,p,q)
//			If the cursor is too close to the right or the bottom, the program simply
//			offsets it to the right spot so it will fit
//
.EQU	RET_BIT			256	//bit8
.EQU	RET_BIT2		8192//bit13

.EQU	BOARD_START_X	1		// Upper left of board
.EQU	BOARD_START_Y	1
.EQU	BOARD_END_X		254
.EQU	BOARD_END_Y		222


//REGISTER USAGE
//r0:		Pixel address
//r1:		Object index
//r20:		original r0
//r21:		obj#Width
//r22:		obj#Height
//r23:		obj#Addr
//r24:		pixel value from dmem obj
//r25:		lower-right addr

.region code
	// This is a sub routine. Don't let it execute unless called
	b	<Start>

Plot_obj:	strb r4, r0, 0		// Replace the cursor with its previous value
	add r20, r0, 0				// Store original r0
	add r18, r1, 0				// Store the original key

	// Object index is in r1 (0-26). Multiply it by 15 to get its offset within the LUT
	cmp r1, 0					// If index is 0, don't bother "multiplying"
	b_eq	<Skip_lut_offset>

	// Emulate multiplying by adding the number to itself 15 times
	mov r26, 15		// Counter to do it 15 times
	mov r27, 0		// Accumulation of the "multiplication" result
Mult_by_15_loop:	add r27, r1, r27
	sub r26, r26, 1	// Dec counter
	b_ne	<Mult_by_15_loop>

	add r1, r27, 0	// Mov the offset into r1

	//Object location in LUT is at <obj0Width> + r1 (the offset)
Skip_lut_offset:	ldadr r27, <obj0Width>
	add r27, r27, r1	// Move to this object's offset within LUT
	ldr	r21, r27, 0		// WIDTH
	ldr	r22, r27, 5		// HEIGHT
	ldr	r23, r27, 10	// OBJECT ADDRESS

	mov r27, 8				// Shift value
	mov r26, r22, r27 LSL	// Shift obj#Height over to Y-byte
	add r25, r26, r21		// r25 has distance from upper-left to lower-right
	add r25, r0, r25		// Add the pixel addr to get addr of lower-right
	mov r27, 257
	sub r25, r25, r27		// Move it up a row and left a column to fix off-by-one indexing
		// r25 is at lower left of where we want the new obj

	cmp r18, 26	// If plotting game of life text, don't do boundary case
	b_ge	<Skip_y_adjust>

	// Check if we have enough horizontal space to plot the obj
	and r26, r0, 255		//  get x-coord
	add r26, r21, r26		// add the obj width to the x-coord
	sub r27, r26, BOARD_END_X
	b_lt	<Skip_x_adjust>	// Don't need to adjust if there's enough space

X_adjust_loop: sub r0, r0, 1	// Move left a pixel
	sub r25, r25, 1				// Move "lower left of where we want the new obj" left a pixel
	sub r27, r27, 1				// Decrement the counter (started as how far over the cursor was)
	b_ne	<X_adjust_loop>

	// Check if we have enough vertical space to plot the obj
Skip_x_adjust:	mov r27, 8		// Shift val
	mov r26, r0, r27 LSR		// Shift the cursor down
	and r26, r26, 255			// get y-coord
	add r26, r22, r26			// add the obj height to the y-coord
	sub r27, r26, BOARD_END_Y	// Is it past the bottom of the board?
	b_le	<Skip_y_adjust>		// Don't need to adjust if there's enough space

Y_adjust_loop: sub r0, r0, 256	// Move up a pixel
	sub r25, r25, 256			// Move "lower left of where we want the new obj" up a pixel
	sub r27, r27, 1				// Decrement the counter (started as how far past bottom the cursor was)
	b_ne	<Y_adjust_loop>

// r26 has count within row
Skip_y_adjust:	mov r26, 0
	// Put the figure into the FB
Plot_obj_loop:	ldrb r24, r23, 0	// Get obj value at this location
	ldrb r18, r0, 0					// Get old pixel value
	and r18, r18, -2				// Default to dead
	tst r24, 1						// Should it be alive?
	or_ne r18, r18, 1				// If so, set alive bit to 1
	strb r18, r0, 0					// Place it in the FB

	// Increment addresses and row counter
	add r26, r26, 1		// Count within row
	cmp r26, r21		// Check if we ran off the end of this row
	mov_eq r26, 0		// If so, reset to 0

	// If starting a new row, move FB addr down a row, otherwise move it right a col
	mov r27, 256
	cmp r26, 0
	add_eq r0, r0, r27	// Move down a row
	cmp r26, 0
	sub_eq r0, r0, r21	// Get back to the left side of the obj
	add r0, r0, 1

	add r23, r23, 1				// Increment our location in the obj dmem
	cmp r0, r25					// Are we past the end of the obj? (i.e. done)
	b_le	<Plot_obj_loop>		// If not, continue looping
//___Plot_obj_loop

	add r0, r20, 0		// Restore original r0
	ldrb r4, r0, 0		// Reload cursor loc's value

	tst r19, RET_BIT2
	b_ne	<Done_plot_obj_3>

	tst r19, RET_BIT
	b_eq	<Done_plot_obj_0>
	b		<Done_plot_obj_1>

