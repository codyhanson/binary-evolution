// gol/menu_setup.s
// Subroutine to copy the main menu screen back to
//		FB1, switch to that, and start menu code
// The menu is encoded in memory as follows:
//		[2-byte addr][1-byte encoding]
.EQU	END_USABLE_FB	61440	// Right end of row 239

.EQU	MMR_VGA			0
.EQU	MMR_LED			5	// 0x05
.EQU	MMR_IRQ_STATUS	15	// 0x0F
.EQU	MMR_IRQ_ENABLE	16	// 0x10
.EQU	MMR_KBD_DATA	18	// 0x12 (Endian confusion)
.EQU	KBD_BIT			2

// Color codex: 1: 00    2: 01    3: 10
.EQU	FB1_BASE_COLOR		63	// Yellow
.EQU	FB1_COLOR_1			15	// 00 Red
.EQU	FB1_COLOR_2			49	// 01 Green
.EQU	FB1_COLOR_3			9	// 10 Orange

.EQU	FB2_BASE_COLOR		193	// Blue
.EQU	FB2_COLOR_1			15	// 00 Red
.EQU	FB2_COLOR_2			201	// 01 Purple
.EQU	FB2_COLOR_3			49	// 10 Green

.EQU	RET_BIT			4096	// bit12

//REGISTER USAGE:
// r15:	val to write to FB1
// r16:	val to write to FB2
// r17: addr to write to
// r18: shift amount to get the addr
// r14:	FB1_COLOR_1
// r20: FB1_COLOR_2
// r21: FB1_COLOR_3
// r22: FB2_COLOR_1
// r23: FB2_COLOR_2
// r24: FB2_COLOR_3
// r25:	value to write
// r26:	number of items
// r27:	addr of item
.region code

	b <Start>

// Beginning of subroutine

// Paint the main menu into FB1 with a base color
Menu_setup: 	mov r24, FB1_BASE_COLOR	// Base color to make the menu
	mov r25, END_USABLE_FB	// End of FB1 (stop at row 240)
	mov r27, 65535
	add r26, r25, r27

Paint_menu_fb1_loop: sub r25, r25, 1
	strb r24, r25, 0
	cmp r25, 0
	b_ne	<Paint_menu_fb1_loop>

	mov r24, FB2_BASE_COLOR
Paint_menu_fb2_loop: strb r24, r26, 0
	sub r26, r26, 1
	cmp r26, r27		// Is it at 0x0FFFF yet?
	b_ne	<Paint_menu_fb2_loop>

// Read info from dmem to set certain pixels in the menu to a different color
	ldadr r26, <numMenuItems>			// Get the number of menu items
	ldr r26, r26, 0
	ldadr r27, <menuItems>				// Get the addr of the items

	mov r14, FB1_COLOR_1
	mov r20, FB1_COLOR_2
	mov r21, FB1_COLOR_3
	mov r22, FB2_COLOR_1
	mov r23, FB2_COLOR_2
	mov r24, FB2_COLOR_3

Set_menu_pixels_loop:	add r27, r27, 0
	ldrb r25, r27, 2	// Get the pixel location and color
	mov r15, FB1_COLOR_1
	tst r25, 1		// bit0 set?
	mov_ne r15, FB1_COLOR_2

	mov r16, FB2_COLOR_1
	tst r25, 2		// bit1 set?
	mov_ne r16, FB2_COLOR_3

	// Now get the addr to place them at
	ldrh	r17, r27, 0	// ldrh gets 2 bytes
	add r27, r27, 0	//noop
	strb	r15, r17, 0	// Store the appropriate color into FB1

	mov r25, 65535
	add r25, r25, 1		// 0x1000 - offset for FB2
	add r17, r17, r25	// Move the dest addr to FB2
	strb r16, r17, 0	// Store the appropriate color into FB2
	add r27, r27, 0	//noop

	add r27, r27, 3		// Move the addr to the next menu item in dmem
	sub r26, r26, 1		// Decrement the counter for how many items we've written
	b_ne	<Set_menu_pixels_loop>	// Loop until it's 0

	tst r19, RET_BIT
	b_eq 	<Done_menu_setup_0>
	b		<Done_menu_setup_1>
// ___END OF SUBROUTINE___
