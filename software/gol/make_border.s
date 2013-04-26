// gol/make_border.s
// Subroutine to set the border in both FB's
// 		r24 has the line y-coord above the text
.EQU	END_USABLE_FB	61439	// Row 239

.EQU	RET_BIT			512	//bit9

// Selected item will be in the opposite color. Deselected will be in current color, but dead

.region code

	b <Start>

// Beginning of subroutine
Make_border:	add r20, r0, 0	// Store the cursor
	mov r0, 0	// Move the cursor to the upper left corner
	mov r25, 65535
	add r25, r25, 1	// 0x10000
	or r21, r0, r25	// r21 has the cursor addr in FB2
	
	mov r22, END_USABLE_FB	// Bottom of visible FB
	mov r27, 255	// Subtract amount
	sub r23, r22, r27	// Bottom left corner

Set_left_border_loop:	ldrb r25, r0, 0	// Get the current value
	or r25, r25, 1		// Turn the pixel on
	strb r25, r0, 0		// Store in FB1
	strb r25, r21, 0	// Store in FB2

	add r21, r21, 256	// Move FB2 addr down a row
	add r0, r0, 256		// Move FB1 addr down a row
	cmp r0, r23			// Are we at bottom left corner?
	b_ne	<Set_left_border_loop>

	add r23, r23, 256	// r23 has Bottom right corner

Set_bottom_border_loop:	ldrb r25, r0, 0	// Get the current value
	or r25, r25, 1		// Turn the pixel on
	strb r25, r0, 0		// Store in FB1
	strb r25, r21, 0	// Store in FB2

	add r21, r21, 1		// Move FB2 addr right a column
	add r0, r0, 1		// Move Fb1 addr right a column
	cmp r0, r23			// Are we at the bottom right corner?
	b_ne	<Set_bottom_border_loop>

	mov r23, 255		// r23 has top right corner
	sub r0, r0, 1		// Move back to the lower right corner

Set_right_border_loop:	ldrb r25, r0, 0	// Get the current value
	or r25, r25, 1		// Turn the pixel on
	strb r25, r0, 0		// Store in FB1
	strb r25, r21, 0	// Store in FB2

	sub r21, r21, 256	// Move FB2 addr up a row
	sub r0, r0, 256		// Move Fb1 addr up a row
	cmp r0, r23			// Are we at the upper right corner?
	b_ne	<Set_right_border_loop>

	mov r23, 0			// r23 has top left corner

Set_top_border_loop:	ldrb r25, r0, 0	// Get the current value
	or r25, r25, 1		// Turn the pixel on
	strb r25, r0, 0		// Store in FB1
	strb r25, r21, 0	// Store in FB2

	sub r21, r21, 1		// Move FB2 addr left a column
	sub r0, r0, 1		// Move Fb1 addr left a column
	cmp r0, r23			// Are we at the upper right corner?
	b_ne	<Set_top_border_loop>

	mov r27, 8			// Shift val
	mov r0, r24, r27 LSL	// Shift the specific row number over to y-coord

Set_specific_line_loop:	ldrb r25, r0, 0	// Get the current value
	or r25, r25, 1		// Turn the pixel on
	strb r25, r0, 0		// Store in FB1
	strb r25, r21, 0	// Store in FB2

	add r21, r21, 1		// Move FB2 addr right a column
	add r0, r0, 1		// Move Fb1 addr right a column
	tst r0, 255			// Tst agains 0xFF ... if x-coord is 0, we're done
	b_ne	<Set_specific_line_loop>

	cmp r19, RET_BIT
	b		<Done_make_border_0>	// Retun to gol code

//	b_ne	<Done_make_border_0>	// Retun to gol code
//	b		<Done_make_border_1>	// Retun to image proc code

 halt
