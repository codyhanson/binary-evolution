//
// File:	kbd_test.s - Keyboard  Test program
// Course:	ECE 554, Spring 2011
// Team:	Binary EvolutioA		
// Names:	Ross Nordstrom
// Descr:	Program to test vga and keyboard functionality
//			- Move pixel (or pixel neighborhood) based on kbd input
// 

// CONSTANT DECLARATIONS
//.EQU	MMR_MEM		4293918720	//0xFFF0000000
.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.EQU	MMR_VGA			0
.EQU	MMR_IRQ_STATUS	15	// 0x0F
.EQU	MMR_IRQ_ENABLE	16	// 0x10
.EQU	MMR_KBD_DATA	18	// 0x12 (Endian confusion)

.EQU	KBD_IRQ_MASK	1
//.EQU	CNTR_MASK	4278190080	//0xFF00000000
.EQU		CNTR_MASK_INIT	255		//0x00000000FF
.EQU		CNTR_MASK_SHIFT	32		// to shift _INIT over to become CNTR_MASK

.EQU	UP_ARROW	17	// 0x11
.EQU	LEFT_ARROW	18	// 0x12
.EQU	DOWN_ARROW	19	// 0x13
.EQU	RIGHT_ARROW	20	// 0x14

.EQU	FB_WIDTH	256
.EQU	FB_HEIGHT	256
.EQU	LOG_WIDTH	8
.EQU	LOG_HEIGHT	8

.EQU	BOARD_START_X	2		// Upper left of board
.EQU	BOARD_START_Y	2
.EQU	BOARD_END_X		253		// Lower right of board
.EQU	BOARD_END_Y		249

.EQU	INIT_X			128
.EQU	INIT_Y			101

// REGISTER USAGE:
// R0:		0x0000000000
// R1:		0x0000000000
// R2:		Current X coordinate
// R3:		Current Y coordinate
// R4:		0x0000000000	-- Middle pixel of
// R5:		0xFF00000000	-- neighborhood is set
// R6:		Current Frame Buffer
// R7:		Previous/Next Frame Buffer
// R8:		Mem address of pixel within a FB
// R9:		Mem address of pixel in prev/next FB
// R10:		Index of leftmost board column (BOARD_START_X)
// R11:		Index of uppermost board row (BOARD_START_Y)
// R12:		Index of rightmost board column (BOARD_END_X)
// R13:		Index of lowermost board row (BOARD_END_Y)
// R14:		MMR Address
// R15:		MMR Contents
// R16:		MASK for "Keyboard Data Ready Interrupt"
// R17:		Keyboard value (ASCII)
// R18-R19:	<Not used yet>
// R22:		<Not used yet>
// R23:		0xFFFFFFFFFF
// R24:		LED addr
// R25:		Temp reg
// R26:		Time wasting counter
// R27:		Temporary register
// R28-R31:	UNAVAILABLE (Branching, SP, LR, PC)


.region code

//DBG
 mov r23, -1


	// Initialize board constants
	MOV	R10, BOARD_START_X
	MOV R11, BOARD_START_Y
	MOV R12, BOARD_END_X
	MOV R13, BOARD_END_Y

	// Initialize current (X,Y) coordinates
	MOV R2,	INIT_X
	MOV R3,	INIT_Y

	// Initialize R0,R1 to 0x0000000000 (black)
	MOV	R0, 0
	MOV	R1, 0

	// Initialize MMR address
	MOV R14,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R14,	R14, R27 LSL		// R14 <- _INIT << _SHIFT

	// Initialize MASKS
	MOV R16,	KBD_IRQ_MASK

	// Initialize FB addresses
	ldadr	R6,		<myFB1>
	ldadr	R7,		<myFB2>

	// Initialize WHITE neighborhood constants
	MOV R4, 0					// R4 gets all 0's
	MOV R5,		CNTR_MASK_INIT
	MOV R27,	CNTR_MASK_SHIFT
	MOV R5,	R5, R27 LSL			// R5 <- _INIT << _SHIFT (0xFF00000000)

	// Initialize mem address of the pixel in current and current FB
	MOV R27,	LOG_WIDTH
	MOV R27,	R3, R27 LSL		// TEMP <- INIT_Y << LOG_FB_WIDTH
	ADD R8,		R27, R2			// R8 <- (INIT_Y * FB_WIDTH) + INIT_X
	ADD R9, 	R6, R8			// R7 <- pixel addr in current FB

	// Initialize the pixel
	STRNEIGHBOR R4, R9, 0		// Store the new pixel location in the FB
	STRNEIGHBOR R4, R9, 0		// Store the new pixel location in the FB

	// Re-set R9 to be the address of the next FB
	ADD R9, 	R7, R8			// R7 <- pixel addr in current FB

	// Enable Keyboard Interrupts
	STRB	R16, R14, MMR_IRQ_ENABLE	// Store keyboard mask into IRQ

	// Set reg for LED MMR 
	MOV R25, 4095	// 0xFFF
	MOV R27, 28		// Shift amount
	MOV R24, R25, R27 LSL
	ADD	R24, R24, 5	// R24 has LED MMR addr ==> 0xFFF0000005

								// Enable Reg (0x10 within MMR)

	strb r0, r6, 195
	strb r0, r6, 196
	strb r0, r6, 197
	strb r0, r6, 198
	strb r0, r6, 199
	strb r0, r6, 200
	strb r0, r6, 201
	strb r0, r6, 202
	strb r0, r6, 203
	strb r0, r6, 204
	strb r0, r6, 205
	strb r0, r6, 206
	strb r0, r6, 207
	strb r0, r6, 208
	strb r0, r6, 209
	strb r0, r6, 210

	// Main loop -- Waits for keyboard input and reacts to it (moves obj)
Main_loop:	ADD R27, R27, 0		// NOOP

//DBG MMR IRQ not working yet
//	LDR		R15, R14,  MMR_IRQ_STATUS
//	AND		R15, R15,  R16			// Mask out the Keyboard IRQ Status bit
//	B_EQ	<Main_loop>				// If not set, do nothing (empty loop)

//DBG
 ldr r27, r14, MMR_KBD_DATA		// get kbd data
 ldr r15, r14, MMR_IRQ_STATUS
 or  r27, r27, 8	// default LED3 to on
 cmp r15, 0
 str r17, r24, 0	// Store kbd_data to LED

//DBG - print top 5 bits of kbd_data
 tst r17, 128
 strb_ne r23, r6, 200	//bit7
 strb_eq r0, r6, 200

 tst r17, 64
 strb_ne r23, r6, 201	//bit6
 strb_eq r0, r6, 201

 tst r17, 32
 strb_ne r23, r6, 202	//bit5
 strb_eq r0, r6, 202

 tst r17, 16
 strb_ne r23, r6, 203	//bit4
 strb_eq r0, r6, 203

 tst r17, 8
 strb_ne r23, r6, 204	//bit3
 strb_eq r0, r6, 204
//__DBG


//	// GOT KEYBOARD IRQ! Read in the byte
//	LDRB	R17, R14, MMR_KBD_DATA	// Keyboard data offset within MMR 

	// Looking for an Arrow (Up-0x11, Left-0x12, Down-0x13, Right-0x14)
	CMP		R17, UP_ARROW
	B_EQ	<Move_up>	// If up arrow, execute that code

	CMP		R17, LEFT_ARROW
	B_EQ	<Move_left>	// If left arrow, execute that code

	CMP		R17, DOWN_ARROW
	B_EQ	<Move_down>	// If down arrow, execute that code

	CMP		R17, RIGHT_ARROW
	B_EQ	<Move_rt>	// If right arrow, execute that code

	// Didn't get an arrow
	B		<Main_loop>

Move_down:  CMP	R3, BOARD_END_Y		// Check if we are at bottom of board
	B_EQ	<Main_loop>				// If so, don't do anything

	ADD		R3, R3, 1			// Increment Y-coord (move down)
	ADD		R8, R8, FB_WIDTH	// Increment mem addr to move down a row
 strb r23, r8, 0
	B		<Moved>

Move_up:  CMP	R3, BOARD_START_Y	// Check if we are at top of board
	B_EQ	<Main_loop>				// If so, don't do anything

	SUB		R3, R3, 1			// Decrement Y-coord (move up)
	SUB		R8, R8, FB_WIDTH	// Decrement mem addr to move up a row
 strb r23, r8, 0
	B		<Moved>

Move_rt:  CMP	R2, BOARD_END_X		// Check if we are at right edge of board
	B_EQ	<Main_loop>				// If so, don't do anything

	ADD		R2, R2, 1			// Increment X-coord (move right)
	ADD		R8, R8, 1			// Increment mem addr to move right a row
 strb r23, r8, 0
	B		<Moved>

Move_left:  CMP	R2, BOARD_START_X	// Check if we are at left edge of board
	B_EQ	<Main_loop>				// If so, don't do anything

	SUB		R2, R2, 1			// Decrement X-coord (move left)
	SUB		R8, R8, 1			// Decrement mem addr to move left a row
 strb r23, r8, 0
	//B		<Moved>		// Don't need to branch since next code is <Moved>

// Switch VGA to new FB
Moved:	add r27, r27, 0	//noop
	//DBG STR	R7, R14, MMR_VGA	// Set VGA MMR to the new FB
	//SWP R6, R6, R7				// Switch between the two frame buffers

	B	<Main_loop>

//Main_loop

	halt
