.EQU	DBG_CNT		50		// Number of generations to loop
.EQU	DBG_INF_LOOP	1	// 1 - infinite loop
							// 0 - loop for <DBG_CNT> generations
//
// File:	game_of_life.s -- Game of Life
// Course:	ECE 554, Spring 2011
// Team:	Binary Evolution
// Names:	Ross Nordstrom
// Descr:	Basic implementation of game of life
// 
 
// CONSTANT DECLARATIONS
//.EQU	MMR_MEM		4293918720	//0x00FFF00000
.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.EQU	MMR_VGA			0
.EQU	MMR_IRQ_ENABLE	16	// 0x10
.EQU	MMR_IRQ_STATUS	15	// 0x0F
.EQU	MMR_KBD_DATA	18	// 0x12 (Endian confusion)
.EQU	KBD_BIT			2

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

.EQU	BOARD_START_X	1		// Upper left of board
.EQU	BOARD_START_Y	1
.EQU	BOARD_END_X		254		// Lower right of board
.EQU	BOARD_END_Y		254
.EQU	BOARD_WIDTH		254


// REGISTER USAGE:
// R0-R1:	Unedited neighborhood
// R2:		Current X coordinate
// R3:		Current Y coordinate
// R4:		0x0000000000	-- Middle pixel of
// R5:		0xFF00000000	-- neighborhood is set
// R6:		Current Frame Buffer
// R7:		Previous/Next Frame Buffer
// R8:		Mem address of pixel within current FB
// R9:		Mem address of pixel in prev/next FB
// R10:		Index of leftmost board column (BOARD_START_X)
// R11:		Index of uppermost board row (BOARD_START_Y)
// R12:		Index of rightmost board column (BOARD_END_X)
// R13:		Index of lowermost board row (BOARD_END_Y)
// R14:		MMR Address
// R15:		Neighborhood summing mask
// R16:		MASK for "Keyboard Data Ready Interrupt"
// R17:		Keyboard value (ASCII)
// R18:	Previous kbd key
// R19:	Current kbd key
// R20:		Amount to increment addr by to get to the beginning of the next line
// R21-R22:	Neighborhood registers
// R23:		Sum of neighborhood
// R24:		<Not used yet>
// R25:		Debug reg - infinite loop?
// R26:		Debug reg - count
// R27:		Temporary register
// R28-R31:	UNAVAILABLE (Branching, SP, LR, PC)


.region code

	// DEBUG
	MOV R25,	DBG_INF_LOOP	
	MOV	R26,	DBG_CNT			// Loop through for DBG_CNT generations

	// Initialize board constants
	MOV	R10, BOARD_START_X
	MOV R11, BOARD_START_Y
	MOV R12, BOARD_END_X
	MOV R13, BOARD_END_Y

	// Initialize R0,R1 to 0x0000000000 (black)
	MOV	R0, 0
	MOV	R1, 0

	// Initialize MMR address
	MOV R14,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R14,	R14, R27 LSL		// R14 <- _INIT << _SHIFT

	// Initialize FB addresses
	ldadr	R6,		<myFB1>
	ldadr	R7,		<myFB2>

	// Initialize WHITE neighborhood constants
	MOV R4, 0					// R4 gets all 0's
	MOV R5,		CNTR_MASK_INIT
	MOV R27,	CNTR_MASK_SHIFT
	MOV R5,	R5, R27 LSL			// R5 <- _INIT << _SHIFT (0xFF00000000)

	// Initialize R20 - Amount to increment addr by to get to the beginning of the next line
	MOV	R27, FB_WIDTH
	SUB R20, R27, BOARD_WIDTH	// Amount to add is the amount in the left+right margins

	// Initialize R15  -- Neighborhood summing mask (0x0101010101)
	MOV	R15, 257			// 0x0101
	MOV R27, 16				// SHift size
	MOV R15, R15, R27 LSL	// Left shift by 2 bytes
	MOV R27, 8
	OR	R15, R15, 257		// R15 now has 0x01010101
	MOV R27, R15, R27 LSL	// Left shift by 2 bytes
	OR	R15, R27, 1			// R15 now has 0x0101010101
	
// Enable MMR_IRQ
	mov r27, KBD_BIT
	strb r27, r14, MMR_IRQ_ENABLE

	// Initialize current (X,Y) coordinates
Main_loop:	MOV R2,	BOARD_START_X
	MOV R3,	BOARD_START_Y

Wait_kbd:	ldrb r27, r14, MMR_IRQ_STATUS
	tst r27, KBD_BIT // is KBD_BIT set?
	b_eq <Wait_kbd>

	// Clear IRQ status
	mov r27, KBD_BIT
	strb r27, r14, MMR_IRQ_STATUS


	// Initialize mem address of the pixel in current and next FB
	MOV R27,	LOG_WIDTH
	MOV R27,	R3, R27 LSL		// TEMP <- INIT_Y << LOG_FB_WIDTH
	ADD R8,		R27, R2			// R8 <- (INIT_Y * FB_WIDTH) + INIT_X
	ADD R9, 	R7, R8			// R7 <- pixel addr in next/prev FB
	ADD R8,		R6, R8			// R8 <- pixel addr in current FB

Traverse_down:	CMP R3, BOARD_END_Y	// Check if we are past the end of the board (aka generation done)
	B_GT	<Switch_FB>		// If so, switch the FB and start a new generation

Traverse_right:	LDNEIGHBOR	R0, R8, 0		// Grab the neighborhood from the FB
	// Process the nbrhd -- R8 has nbrhd addr to be processed. R9 has destination addr
	// Load the existing nbrhd
	AND			R21, R0, R15	// Mask all the pixels in nbrhd to 1 or 0
	AND			R22, R1, R15

	ACCUMBYTES	R23, R21, R22	// R23 gets the sum of the neighborhood

	AND	R27, R1, R5				// Check the original center pixel val (alive or dead)
	B_EQ	<Was_dead>			// If it was 0, it was dead
	//B_NE	<Was_alive>			// else it was 1, so alive

Was_alive:	CMP	R23, 3			// 2 neighbors?
	B_LT	<Pixel_dead>		// If less than 2 neighbors, it dies by starvation
	CMP	R23, 4					// 3 neighbors?
	B_GT	<Pixel_dead>		// If more than 3 neighbors, dies by overpopulation
	B		<Pixel_alive>		// Otherwise it is alive
//Was_alive

Was_dead:	CMP R23, 3		// 3 live neighbors?
	B_EQ	<Pixel_alive>	// This pixel gets born
	//B_NE	<Pixel_dead>	// Otherwise, it is dead 
//Was_dead

Pixel_dead:	MOV	R27, 0		// TEMP gets 0x00
	STRB	R27, R9, 0		// Store the byte in the next FB
	B		<Inc_X>
//Pixel_dead

Pixel_alive:	MOV	R27, 255	// TEMP gets 0xFF
	STRB	R27, R9, 0			// Store the byte in the next FB
	//B		<Inc_X>			// Implied branch (<Inc_X> is next)
//Pixel_alive

	// Increment X-coordinate
Inc_X:	ADD R2, R2, 1		// Move right one spot
	ADD R8, R8, 1		// Increment mem addresses too
	ADD R9, R9, 1
	CMP R2, BOARD_END_X	// At the right edge of the board?
	B_NE	<Traverse_right>	// If not, continue traversing across the board
//Traverse_right

	// Done with this row. Increment Y-coord and memory addresses to the beginning of the next row
	ADD R3, R3, 1		// Move down one spot
	ADD R8, R8, R20		// Increment mem addresses to the start of the next row
	ADD R9, R9, R20
	MOV R2,	BOARD_START_X		// Reset the X-coord
	B		<Traverse_down>		// Start the next row (beginning of loop checks for generation end)
//Traverse_down

	// Switch VGA to new FB
Switch_FB:	ADD R0, R0, 0	// NOOP
	// TODO: Need to comment out the following line for the simulation to work!!!
//	STR	R7, R14, MMR_VGA	// Set VGA MMR to the new FB
	SWP R6, R6, R7					// Switch between the two frame buffers


//	//DEBUG
//	CMP R25, 0				// Finite loop?
//	SUB_EQ R26, R26, 1		// If yes, decrement the generations counter
//	B_EQ <dbg_halt>			// If yes, halt when counter is 0


	// Done with this frame -- Start new round of nbrhd processing
	RETURN 2	//dump frame buffers with this special return instruction

	B <Main_loop>
//<Main_loop>

dbg_halt:	halt
