//REGISTER USAGE
// 	-- SEE gol/ui_main.s --
.EQU	MMR_LED			5	// 0x05
.EQU 	RET_BIT			1	// bit0

.region code

Process_this_nbrhd_0: add r27, r27, 0	//noop

	ldneighbor r25, r0, 0	// get this neighborhood
	and r25, r25, r15			// and it with summing mask (masks out all but
	and r26, r26, r15			// 		bit0 of each pixel)
	accumbytes r24, r25, r26	// get the nbrhd sum

	// Get pixel's addr in other FB
	mov r27, 65535
	add r27, r27, 1
	add r20, r0, r27		// add 0x10000 to pixel address
	mov r26, 65535
	add r27, r26, r27		// r27 has 0x1FFFF
	and r20, r20, r27		// mask pixel address to stay within the two FBs

	ldrb	r25, r20, 0		// Get pixel value in other FB
	ldrb	r27, r0, 0		// Get current pixel value
	tst		r27, 1			// Check bit0
	b_eq	<Was_dead_0>
	//b_ne	<Was_alive_0>		// Implied branch -- "Was_alive" is the next instr

Was_alive_0:	and r26, r25, -2	// Default to dead (-2 = 0x1111110)
	cmp r24, 3
	or_eq r26, r26, 1			// stays alive
	cmp r24, 4
	or_eq r26, r26, 1			// stays alive
	b	<Store_cell_0>

Was_dead_0:	and r26, r25, -2	// Default to dead (-2 = 0x1111110)
	cmp r24, 3
	or_eq r26, r26, 1			// stays alive

Store_cell_0:	strb r26, r20, 0	// store result in other FB

	// Decide where to return to
	and r27, r19, RET_BIT
	cmp r27, 0
	b_eq	<Done_proc_nbrhd_0>	// exit subroutine w/ 1st option
	b		<Done_proc_nbrhd_1>	// exit subroutine w/ 2nd option

// ___END OF SUBROUTINE___
