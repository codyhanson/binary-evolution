//
// File:	Image Processing
// Course:	ECE 554, Spring 2011
// Team:	Binary Evolution
// Names:	Ross Nordstrom
//

// Regions:
// .region isr
// .region ex
// .region code

//
// Data/EQU declarations...
//
.EQU	FB_SIZE		100
.EQU	FRAME_BUF1	0
.EQU	FRAME_BUF2	100
.EQU	DATA_MEM	200

//.EQU	MMR_MEM		4293918720	//0x00FFF00000
.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.EQU	FB_WIDTH	8
.EQU	FB_HEIGHT	8
.EQU	LOG_WIDTH	3
.EQU	LOG_HEIGHT	3

//.EQU	CNTR_MASK	4278190080	//0x00FF00000000
.EQU		CNTR_MASK_INIT	255		//0x00000000FF
.EQU		CNTR_MASK_SHIFT	24		// to shift _INIT over to become CNTR_MASK

.EQU	CNTR_POS	16
.EQU	NEIGH_SIZE	72 //9*8

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
// R14-R19:	<Not used yet>
// R20:		Sum of the neighborhood
// R21:		Next frame (gets swapped with R3)
// R22-R23:	Image kernel
// R24-R27:	<Not used yet>
// R28-R31:	UNAVAILABLE (PC, LR, SP, Branching)

.region code

	// Initialize Registers
	ldadr	R3,		<myFB1>
	ldadr	R21,	<myFB2>

	// Initialize the Laplacian kernel
	ldadr	R22,	<myImKern1>
	ldaddr	R23,	<myImKern2>

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

// Loops through game of life generations
Main_loop:	SWP R3, R3, R21		// Switch between the two frame buffers
	// R3 has the current frame buffer. R4 has the next frame buffer

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
Horiz_loop:		MOV	R0, R5, R8 LSL	// R0 <- Y-coord << log_2(WIDTH)
	ADD R0, R0, R4					// R0 <- (Y*WIDTH) + X

	ADD R13,	R0,	R21				// R13 <- Mem addr of pixel in next FB
	ADD R0,		R0,	R3				// R0  <- Mem addr of pixel in current FB
	// R0 now has pixel address is = Y*WIDTH + X

	// Accumulate this pixel's neighborhood
	LDNEIGHBOR	R10,	R0,	0		// Load nbrhd into R10 and R11
	MXMUL		R10,	R10,	R20	// Multiply the neigborhood by the kernel
	ACCUMBYTES	R20,	R10, R11	// R20 the sum of the nbrhd. Flags set

	// Mask out the old value
	AND		R1, R11,	R12			// R1 gets the original center value

	// Store the new value in the next frame buffer
	STRB	R1,	R13,	0	// Store into pixel address in the OTHER fb

	// Move to the next neighborhood position
	SUB		R4, R4,	1		// Decrement X-coord (move left)
	B_NE	<Horiz_loop>	// Not done with row yet
//<Horiz_loop>

	// Done with this row.
	SUB		R5, R5, 1		// Decrement Y-coord (move up)
	B_NE	<Vert_loop>		// If NOT 0, we have more rows to process
//<Vert_loop>

	// Done with this frame -- Start new round of nbrhd processing
// TODO: Don't loop while debugging
//	B <Main_loop>
//<Main_loop>

	halt

