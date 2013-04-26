.EQU	DBG_CNT		100
//
// File:	Game of Life
// Course:	ECE 554, Spring 2011
// Team:	Binary EvolutioA		
// Names:	Ross Nordstrom
//
// History:	2-16-2011 - Created
//			3-08-2011 - Added memory constants, and padded out code a bit
//

// Regions:
// .region isr
// .region ex
// .region code

//
// Data/EQU declarations...
//

//.EQU	MMR_MEM		4293918720	//0x00FFF00000
.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	20		// to shift _INIT over to become MMR_MEM

.EQU	FB_WIDTH	10
.EQU	FB_HEIGHT	10
.EQU	LOG_WIDTH	3
.EQU	LOG_HEIGHT	3

//.EQU	CNTR_MASK	4278190080	//0x00FF00000000
.EQU		CNTR_MASK_INIT	255		//0x00000000FF
.EQU		CNTR_MASK_SHIFT	32		// to shift _INIT over to become CNTR_MASK


// REGISTER USAGE:
// R0:		Memory address of the pixel
// R1:		Pixel value
// R2:		FB MMR Address
// R3:		Current frame (gets swapped with R21)
// R4:		Current X-coordinate (column)
// R5:		Current Y-coordinate (row) - starts in upper left
// R6:		WIDTH of Visible grid (not including padding)
// R7:		HEIGHT of visible grid (not including padding)
// R8:		log_2(WIDTH)
// R9:		log_2(HEIGHT)
// R10+R11:	Neighborhood values
// R12:		Mask for the center of the neighborhood
// R13:		Memory address of pixel's loc in next FB
// R14:		Framebuffer Y-coord LUT
// R15:		Neighborhood Summing mask (change each instance to 0x01)
// R16-R19:	<Not used yet>
// R20:		Sum of the neighborhood
// R21:		Next frame (gets swapped with R3)
// R22-R25:	<Not used yet>
// R25:		0xFFFFF
// R26:		Debug reg - mem
// R27:		Debug reg - count
// R28-R31:	UNAVAILABLE (Branching, SP, LR, PC)

.region code

	// Initialize Registers
	ldadr	R3,		<myFB2>
	ldadr	R21,	<myFB1>
	ldadr	R14,	<myFBLUT>

	// Set R15 
	MOV	R15, 257			// 0x0101
	MOV R28, 16				// SHift size
	MOV R15, R15, R28 LSL	// Left shift by 2 bytes
	OR	R15, R15, 257		// R15 now has 0x01010101
	MOV R28, 8
	MOV R15, R15, R28 LSL	// Left shift by 2 bytes
	OR	R15, R15, 1			// R15 now has 0x0101010101
	

	MOV R25, 0
	SUB R25, R25, 1

	// Initialize the MMR address for the frame buffer
	// FB MMR Addr: <MMR> + 0
	MOV R2,		MMR_MEM_INIT
	MOV R13,	MMR_MEM_SHIFT
	MOV R2,		R2, R13 LSL		// R2 <- _INIT << _SHIFT

	MOV R6,		FB_WIDTH		// Initialize frame buffer width
	MOV	R7,		FB_HEIGHT		// Initialize frame buffer height
	MOV R8,		LOG_WIDTH		// Initialize log_2(WIDTH)
	MOV R9,		LOG_HEIGHT		// Initialize log_2(HEIGHT)

	// Initialize R12 to the CNTR_MASK
	MOV R12,	CNTR_MASK_INIT
	MOV R13,	CNTR_MASK_SHIFT
	MOV R12,	R12, R13 LSL	// R12 <- _INIT << _SHIFT


// DEBUG
	MOV	R27,	DBG_CNT	// Loop through for DBG_CNT generations


// Loops through game of life generations
Main_loop:	SWP R3, R3, R21		// Switch between the two frame buffers

	// R3 has the current frame buffer. R21 has the next frame buffer

	// Set the frame buffer MMR to use R3's frame
//	STR		R3,	R2, 0			// Store the current FB in the MMR

	// Initialize Y-coord to the last row (goes from bottom to top of frame)
	SUB	R5,	R7,	2				// Y <- (HEIGHT-1-1)
	// 1 for pad, 1 for indexing (i.e. 0-9 for height of 10)
	// Initialized the Y-coord to the bottom-most row


// Loops through each row in the grid (from bottom to top)
Vert_loop:		SUB R4,	R6, 2			// X <- (WIDTH-1-1)
	// 1 for pad, 1 for indexing (i.e. 0-9 for width of 10)
	// Initialized the X-coord to the right-most column


// Loops through each pixel in the row (from right to left)
Horiz_loop:		ADD R0, R14, R5		// Calculate offset into FB_LUT
	LDRB	R0,	R0,	0				// Grab Address of current row from LUT
	ADD 	R0, R0, R4				// R0 <- address within FB space

	ADD R13,	R0,	R21				// R13 <- Mem addr of pixel in next FB
	ADD R0,		R0,	R3				// R0  <- Mem addr of pixel in current FB
	// R0 now has pixel address is = Y*WIDTH + X

	// Process the neighborhood
	LDNEIGHBOR	R10,	R0,	0		// Load nbrhd into R10 and R11

	// Mask out the old value
	AND		R1, R11,	R12			// R1 gets the original center value

	// Convert any values in the neighborhood to 0 or 1
	AND			R10, R10, R15
	AND			R11, R11, R15

	ACCUMBYTES	R20,	R10, R11	// R20 the sum of the nbrhd. Flags set
	B_NE	<Was_alive>				// If it wasn't zero, it was alive
	//B_EQ	<Was_dead>	// Implied "branch"

	// Apply the game of life rules to decide the new pixel value,
	// based on the old value
Was_dead:	MOV	R1,	0				// Make sure it has a 0
	CMP R20,	3					// Sum == 3?
	ADD_EQ	R1,	R25, 0				// Cell is born (gets 0xFFFFFF)
	B		<Store_new_val>
//<Was_dead>

Was_alive:	MOV		R1,	0			// Default to dead
	CMP 	R20,	3				// Sum == 3?
	ADD_EQ	R1,		R25, 0			// If 2 nbrs, cell lives
	CMP		R20,	4				// Sum == 4?
	ADD_EQ	R1,		R25, 0			// If 3 nbrs, cell lives
	//B		<Store_new_val>		// Implied "branch"
//<Was_alive>
		
	// R1 contains the new value for this pixel

	// Store the new value in the next frame buffer
Store_new_val:	ADD		R28, R28, 0		// NOOP
	STRB	R1,	R13,	0	// Store into pixel address
										// in the OTHER fb

	// Move to the next neighborhood position
	SUB		R4, R4,	1		// Decrement X-coord (move left)
	B_NE	<Horiz_loop>	// Not done with row yet
//<Horiz_loop>

	// Done with this row.
	SUB		R5, R5, 1		// Decrement Y-coord (move up)
	B_NE	<Vert_loop>		// If NOT 0, we have more rows to process
//<Vert_loop>


//DEBUG
	SUB R27, R27, 1
	B_EQ <rdhalt>

	// Done with this frame -- Start new round of nbrhd processing
	B <Main_loop>
//<Main_loop>

rdhalt:	MOV R28, 0	// noop
	halt

