// gol/switch_fb.s
// Subroutine to switch the FB
.EQU	MMR_VGA			0
.EQU	MMR_LED			5	// 0x05
.EQU	MMR_IRQ_STATUS	15	// 0x0F
.EQU	MMR_IRQ_ENABLE	16	// 0x10
.EQU	MMR_KBD_DATA	18	// 0x12 (Endian confusion)
.EQU	KBD_BIT			2

.EQU	RET_BIT	2			// bit1

.region code

	b <Start>

// Beginning of subroutine
Switch_fb: 	add r5, r5, 1
	and r5, r5, 1
	add r5, r5, 2	// Set to color mode
	strb r5, r10, MMR_VGA
	and r5, r5, 1	// Get rid of the extra bit

	// move cursor to other FB
	mov r26, 65535		// r26 has 0x0FFFF
	add r27, r26, 1		// r27 has 0x10000

	cmp r5, 1				// Switch to FB2 or FB1?
	b_eq <Switch_to_FB2>	// Was in FB1
	//b_ne <Switch_to_FB1>	// Implied branch (switch from FB2)

Switch_to_FB1:		and r0, r0, r26	// if FB1, clear bit 0x1....
	b <Done_switching>

Switch_to_FB2:		or	r0, r0, r27	// if FB2, set bit 0x1....

	// Decide where to return to
Done_switching:		tst r19, RET_BIT
//	b_eq	<Done_switch_fb_0>	// exit subroutine w/ 1st option
//	b		<Done_switch_fb_1>	// exit subroutine w/ 2nd option
	b		<Done_switch_fb_0>	// exit subroutine w/ 1st option

// ___END OF SUBROUTINE___
