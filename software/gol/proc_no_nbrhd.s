//REGISTER USAGE
// 	-- SEE gol/ui_main.s --
.EQU	MMR_LED			5	// 0x05
.EQU 	RET_BIT			1	// bit0

.region code

Process_this_nbrhd_1: add r27, r27, 0	//noop

//	ldneighbor r25, r0, 0	// get this neighborhood
//	and r25, r25, r15			// and it with summing mask (masks out all but
//	and r26, r26, r15			// 		bit0 of each pixel)
//	accumbytes r24, r25, r26	// get the nbrhd sum
		
		// load each pixel in the neigbhorhood, accumulating as we go
		mov r24, 0			// Accumulation

		// TOP ROW
		ldrb r27, r0, -257	// upper left pixel
		tst r27, 1
		add_ne r24, r24, 1	// If it was alive, inc the accum

		ldrb r27, r0, -256	// upper middle pixel
		tst r27, 1
		add_ne r24, r24, 1	// If it was alive, inc the accum

		ldrb r27, r0, -255	// upper right pixel
		tst r27, 1
		add_ne r24, r24, 1	// If it was alive, inc the accum

		// MIDDLE ROW (other than center pixel)
		ldrb r27, r0, -1	// middle left pixel
		tst r27, 1
		add_ne r24, r24, 1	// If it was alive, inc the accum

		// Save middle pixel for last

		ldrb r27, r0, 1		// middle right pixel
		tst r27, 1
		add_ne r24, r24, 1	// If it was alive, inc the accum

		// BOTTOM ROW
		ldrb r27, r0, 255	// bottom left pixel
		tst r27, 1
		add_ne r24, r24, 1	// If it was alive, inc the accum

		ldrb r27, r0, 256	// bottom middle pixel
		tst r27, 1
		add_ne r24, r24, 1	// If it was alive, inc the accum

		ldrb r27, r0, 257	// bottom right pixel
		tst r27, 1
		add_ne r24, r24, 1	// If it was alive, inc the accum

		// CENTER PIXEL
		ldrb r27, r0, 0		// center pixel
		tst r27, 1
		add_ne r24, r24, 1	// If it was alive, inc the accum




	// Get pixel's addr in other FB
	mov r25, 65535
	add r25, r25, 1
	add r20, r0, r25		// add 0x10000 to pixel address
	mov r26, 65535
	add r25, r26, r25		// r25 has 0x1FFFF
	and r20, r20, r25		// mask pixel address to stay within the two FBs

	ldrb	r25, r20, 0		// Get pixel value in other FB
							// r27 has current pixel value
	tst		r27, 1			// Check bit0
	b_eq	<Was_dead_1>
	//b_ne	<Was_alive_1>		// Implied branch -- "Was_alive" is the next instr

Was_alive_1:	and r26, r25, -2	// Default to dead (-2 = 0x1111110)
	cmp r24, 3
	or_eq r26, r26, 1			// stays alive
	cmp r24, 4
	or_eq r26, r26, 1			// stays alive
	b	<Store_cell_1>

Was_dead_1:	and r26, r25, -2	// Default to dead (-2 = 0x1111110)
	cmp r24, 3
	or_eq r26, r26, 1			// stays alive

Store_cell_1:	strb r26, r20, 0	// store result in other FB

	// Decide where to return to
	and r27, r19, RET_BIT
	cmp r27, 0
	b_eq	<Done_proc_nbrhd_0>	// exit subroutine w/ 1st option
	b		<Done_proc_nbrhd_1>	// exit subroutine w/ 2nd option

// ___END OF SUBROUTINE___
