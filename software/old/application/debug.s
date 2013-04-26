//
// File:	Game of Life
// Course:	ECE 554, Spring 2011
// Team:	Binary EvolutioA		
// Names:	Ross Nordstrom
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
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.EQU	FB_WIDTH	10
.EQU	FB_HEIGHT	10
.EQU	LOG_WIDTH	3
.EQU	LOG_HEIGHT	3

//.EQU	CNTR_MASK	4278190080	//0x00FF00000000
.EQU		CNTR_MASK_INIT	255		//0x00000000FF
.EQU		CNTR_MASK_SHIFT	32		// to shift _INIT over to become CNTR_MASK

.EQU	DBG_CNT		1

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
// R15-R19:	<Not used yet>
// R20:		Sum of the neighborhood
// R21:		Next frame (gets swapped with R3)
// R22-R25:	<Not used yet>
// R26:		Debug reg - mem
// R27:		Debug reg - count
// R28-R31:	UNAVAILABLE (Branching, SP, LR, PC)

.region code

	// Initialize Registers
	ldadr	R3,		<myFB1>
	ldadr	R21,	<myFB2>
	ldadr	R14,	<myFBLUT>

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


// Comment this in or out to change which FB to be current
	SWP R3, R3, R21		// Switch between the two frame buffers

	// Initialize row to 5, column to 6 (nbrhd of 0x56)
	MOV R4, 6
	MOV R5, 5

	ADD R0, R14, R5		// Calculate offset into FB_LUT
	LDRB	R0,	R0,	0				// Grab Address of current row from LUT
	ADD 	R0, R0, R4				// R0 <- address within FB space

	ADD R13,	R0,	R21				// R13 <- Mem addr of pixel in next FB
	ADD R0,		R0,	R3				// R0  <- Mem addr of pixel in current FB
	// R0 now has pixel address is = Y*WIDTH + X

	// Accumulate this pixel's neighborhood
	LDNEIGHBOR	R10,	R0,	0		// Load nbrhd into R10 and R11
		// Should get:		R10 = 00 45 46 47 57
		//					R11 = 56 55 65 66 67
	ACCUMBYTES	R20,	R10, R11	// R20 the sum of the nbrhd. Flags set


	// Store the new value in the next frame buffer
	STRB	R20,	R13,	0		// Store into pixel address
									// in the OTHER fb

	halt

