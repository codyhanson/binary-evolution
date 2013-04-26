// gol/set_fb.s
// Subroutine to switch the FB
.EQU	END_USABLE_FB	61440	// Row 239

.EQU	MMR_RAND		4	// LFSR Pseudo-random number generator

.EQU	BGD_COLOR		48	// Color to set the screen to (GREEN)

.EQU	RET_BIT			32	// bit5
.EQU	RET_BIT2		64	// bit6

// Selected item will be in the opposite color. Deselected will be in current color, but dead

.region code

	b <Start>

// Beginning of subroutine
Set_fb:	add r21, r0, 0	// Store the old "current cursor"
	add r27, r27, 0		// noop
	add r27, r27, 0		// noop
	mov r20, END_USABLE_FB
	
	cmp r24, 0
	b_eq	<Set_fb_rainbow>	// If 0 was input, set the screen to rainbow colors

	ldr r27, r10, MMR_RAND
	// If r24 was 1, give it a random color
	cmp r24, 1	// 1?
	add_eq r24, r27, 0	// Get random if so
	tst r24, 254	// Is it black?
	mov_eq	r24, 255	// If it would've been black, make it white
	
	mov r22, 65535	// 0x0FFFF
	add r26, r22, 1	// 0x10000
	and r27, r0, r26	// get 0x00000 or 0x10000 depending on current cursor

	// Do a normal Set_fb with the color in r24
Set_fb_loop:	ldrb r23, r27, 0
	tst r23, 1				// Was it alive?
	or_ne	r24, r24, 1		// If so, set r24 to alive
	tst r23, 1				// Was it alive?
	and_eq	r24, r24, -2	// If not, set r24 to dead
	strb r24, r27, 0		// Store the new pixel

	add r27, r27, 1
	and r18, r22, r27	// Mask off the FB bit
	cmp r18, r20		// check if we are at the end of the FB
	b_le <Set_fb_loop>

	b	<Set_wrapup>

	// Reset "previous" value to be the new "set" value
Set_wrapup:		mov r4, 0

	// Restore the old "current cursor"
	add r0, r21, 0

	// Decide where to return to
	tst r19, RET_BIT2
	b_ne	<Done_set_fb_3>		// exit subroutine w/ 3rd option

	tst r19, RET_BIT
	b_eq	<Done_set_fb_0>		// exit subroutine w/ 1st option
//	b		<Done_set_fb_1>		// exit subroutine w/ 2nd option
	b		<Done_set_fb_0>		// exit subroutine w/ 1st option

// ___END OF SUBROUTINE___




// EASTER EGG SUBROUTINE
// Beginning of subroutine
Set_fb_rainbow:	add r21, r0, 0	// Store the old "current cursor"
	mov r22, 65535	// 0x0FFFF
	add r26, r22, 1	// 0x10000
	and r27, r0, r26	// get 0x00000 or 0x10000 depending on current cursor

	// Draw a ton of colors on the FB
	mov r24, 2
Set_fb_loop_rainbow:	ldrb r23, r27, 0
	tst r23, 1				// Was it alive?
	or_ne	r24, r24, 1		// If so, set r24 to alive
	tst r23, 1				// Was it alive?
	and_eq	r24, r24, -2	// If not, set r24 to dead
	strb r24, r27, 0		// Store the new pixel

	add r24, r24, 2		// Increment our rainbow color
	tst r24, 254	// Is it black?
	mov_eq	r24, 2	// If it would've been black, make it white
	add r27, r27, 1
	and r18, r22, r27	// Mask off the FB bit
	cmp r18, r20		// check if we are at the end of the FB
	b_ne <Set_fb_loop_rainbow>

	b	<Set_wrapup>


