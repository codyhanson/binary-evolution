// gol/copy_fb.s
// Subroutine to copy this fb over to the other
.EQU	END_USABLE_FB	61439	// Row 239

.EQU	MMR_VGA			0
.EQU	MMR_LED			5	// 0x05
.EQU	MMR_IRQ_STATUS	15	// 0x0F
.EQU	MMR_IRQ_ENABLE	16	// 0x10
.EQU	MMR_KBD_DATA	18	// 0x12 (Endian confusion)
.EQU	KBD_BIT			2

.EQU	RET_BIT			16	//bit4
.EQU	RET_BIT2		128	//bit7

//REGISTER USAGE:
// r24:	0x0FFFF, and END_USABLE_FB
// r25:	value here
// r26:	this addr
// r27:	that addr
.region code

	b <Start>

// Beginning of subroutine
Copy_fb: 	add r27, r27, 0	//noop

	// move cursor to other FB
	mov r24, 65535		// r26 has 0x0FFFF
	add r27, r24, 1		// r27 has 0x10000

	mov r24, END_USABLE_FB

	// initialize this and that addr
	mov r25, 0			// initialize this addr to 0
	mov r26, 0			// initialize that addr to 0
	tst r5, 1			// Are we in FB2?
	add_ne r25, r27, 0	// If so, this addr gets 0x10000
	tst r5, 1			// Are we in FB2?
	add_eq r26, r27, 0	// If not, that addr gets 0x10000
	
Copy_loop:	ldrb r27, r25, 0	// Get this pixel
	strb r27, r26, 0			// Store into that pixel

	// Increment the addresses
	add r25, r25, 1
	add r26, r26, 1

	mov r27, 65535
	and r23, r25, r27	// Mask off the FB bit
	cmp r23, r24		// Done?
	b_ne	<Copy_loop>	// If not, continue looping

	// Decide where to return to
	tst r19, RET_BIT2
	b_ne	<Done_copy_fb_3>	// exit subroutine w/ 3rd option
	tst r19, RET_BIT
	b_eq	<Done_copy_fb_0>	// exit subroutine w/ 1st option
	b		<Done_copy_fb_1>	// exit subroutine w/ 2nd option


// ___END OF SUBROUTINE___
