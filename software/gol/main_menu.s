// ARROWS   - Change selection (highlighted)
// NUM_ONE	- Start GoL code
// NUM_TWO	- Start Image Processing code
// any other key - Start highlighted code
//

// COLOR: BBGGRRR_
.EQU	END_USABLE_FB	61439	// Row 239

.EQU	COLOR_1			240	// Cyan
.EQU	COLOR_2			206	// Magenta
.EQU	BORDER_COLOR	63	// Yellow

//.EQU	MMR_MEM		4293918720	//0x00FFF00000
.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.EQU	MMR_VGA			0
.EQU	MMR_LED			5	// 0x05
.EQU	MMR_IRQ_STATUS	15	// 0x0F
.EQU	MMR_IRQ_ENABLE	16	// 0x10
.EQU	MMR_KBD_DATA	18	// 0x12 (Endian confusion)
.EQU	KBD_BIT			2

.EQU	UP_ARROW	17	// 0x11
.EQU	LEFT_ARROW	18	// 0x12
.EQU	DOWN_ARROW	19	// 0x13
.EQU	RIGHT_ARROW	20	// 0x14
.EQU	NUM_ONE		49	// 0x31
.EQU	NUM_TWO		50	// 0x32

.EQU	RET_GOL_BIT		1	//bit0
.EQU	RET_SWITCH_BIT	2	//bit1
.EQU	RET_CLEAR_BIT	4	//bit2
.EQU	RET_DRAW_BIT	8	//bit3
.EQU	RET_COPY_BIT	16	//bit4
.EQU	RET_SET_BIT		32	//bit5
.EQU	RET_SET2_BIT	64	//bit6


//REGISTER USAGE
// r0:		Current cursor (address of pixel)
// r1:		Keyboard input
// r2:		Current selection
// r3-r9:	--
// r10:		MMR base address
// r11-r15:	--
// r16-r18: Temp
// r19:		Return register (each bit is a signal to subroutines about where to return to)
// r20:		Pixel addr in other FB -- used by proc_nbrhd.s
// r21:		Holds previous r0 during proc_1_generation.s
// r22-r23:	Temp reg's
// r24: 	Border color input for <draw_border.s>
// r25-r27:	Temp reg's


.region code

Start:		add r27, r27, 0	//noop

//DBG
// mov r17, 0

	// Initialize MMR address
	mov r26,	MMR_MEM_INIT
	mov r27,	MMR_MEM_SHIFT
	mov r10,	r26, r27 LSL		// r10 <- _INIT << _SHIFT

	// FB
	mov r5, 2	// FB1, color mode
	strb r5, r10, MMR_VGA
	mov r5, 0	// get rid of extra color bit

	// enable kbd irq
	mov r27, KBD_BIT
	strb r27, r10, MMR_IRQ_ENABLE

	// Initialize the main menu screen
	mov r19, 0			// Signal to return here
	b	<Menu_setup>
Done_menu_setup_0:	mov r2, 0		// Initialize selection

Main_menu_loop: add r27, r27, 0	//noop

//DBG
 //mov r27, KBD_BIT
Main_wait_kbd:	ldrb r27, r10, MMR_IRQ_STATUS
	tst r27, KBD_BIT // is KBD_BIT set?
	b_eq <Main_wait_kbd>
//__Wait_kbd

	// Clear IRQ status
	mov r27, KBD_BIT
	strb r27, r10, MMR_IRQ_STATUS

//DBG
// mov r1, NUM_ONE

	ldrb r1, r10, MMR_KBD_DATA	// get the key
	strb r1, r10, MMR_LED	// store the key in the LEDs

///////////////////////////////////////////////////////////////////////////////
// FIGURE OUT WHAT KEY WAS PRESSED. DO SOMETHING BASED ON THAT
///////////////////////////////////////////////////////////////////////////////

//ARROW ==> Change slection highlight
 mov r27, UP_ARROW
	cmp r1, r27
	b_lt	<Main_not_an_arrow>

 mov r27, RIGHT_ARROW
	cmp r1, r27
	b_gt	<Main_not_an_arrow>

	// Switch the selection
	add r2, r2, 1
	and r2, r2, 1

	// Switch the FB
	add r5, r5, 1
	or r5, r5, 2	// Set the color bit
	strb r5, r10, MMR_VGA	// Switch to the new FB
	b	<Main_menu_loop>

Main_not_an_arrow:	add r27, r27, 0	//noop

 mov r27, NUM_ONE
	cmp r1, r27
	mov_eq	r2, 0				// if 1, set selection to 0

 mov r27, NUM_TWO
	cmp r1, r27
	mov_eq	r2, 1				// if 2, set selection to 1

//////////////////////////////////////////
// Branch to the appropriate application
//////////////////////////////////////////

	// Clear out both FB's
Soft_reset:	mov r0, END_USABLE_FB		// End of the visible FB
	mov r27, 65535
	add r27, r27, 1
	add r1, r0, r27				// Addr in FB2
	mov r3, 0					// Value to clear the FB's to
Menu_clear_fb_loop: strb r3, r0, 0	// FB1
	strb r3, r1, 0					// FB2
	sub r1, r1, 1		// Dec by 1
	sub r0, r0, 1		// Dec by 1
	b_ne	<Menu_clear_fb_loop>
	// BOTH FB's ARE CLEARED


	// Decide where to branch to
	tst r2, 1
	b_eq	<Start_gol>			// If r3=0, start Game of Life
	b		<Start_image_proc>	// Else, Image Processing

