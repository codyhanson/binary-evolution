//
// File:	setup_lut.s -- Sets up the game of life initial cells LUT
// Course:	ECE 554, Spring 2011
// Team:	Binary Evolution
// Names:	Ross Nordstrom
// Descr:	Sets up the game of life object LUT with object addresses
// TODO:	Slim down register usage within this file
// 

// CONSTANT DECLARATIONS
.EQU	NUM_LUT_OBJS	17

// REGISTER USAGE
// R26: Object LUT address
// R27: Temp

.region code

	// Branch to <Start> to make sure the main program gets run first
	b	<Start>


//
//Everything should be initialized in the main .s file
//

	// Initialize current (X,Y) coordinates
Setup_lut:	ldadr r26, <obj0Addr>		// Get the LUT address
	
	ldadr	r27, <cell_000>		//Obj 0
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_001>		//Obj 1
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_002>		//Obj 2
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_003>		//Obj 3
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_004>		//Obj 4
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_005>		//Obj 5
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_006>		//Obj 6
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_007>		//Obj 7
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_008>		//Obj 8
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_009>		//Obj 9
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_010>		//Obj 10
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_011>		//Obj 11
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_012>		//Obj 12
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_013>		//Obj 13
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_014>		//Obj 14
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_015>		//Obj 15
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_016>		//Obj 16
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_017>		//Obj 17
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_018>		//Obj 18
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_019>		//Obj 19
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_020>		//Obj 20
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_021>		//Obj 21
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_022>		//Obj 22
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_023>		//Obj 23
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_024>		//Obj 24
	str		r27, r26, 0
	add		r26, r26, 15

	ldadr	r27, <cell_025>		//Obj 25
	str		r27, r26, 0
	add		r26, r26, 15

	// Game of life screen's text
	ldadr	r27, <cell_026>		//Obj 26
	str		r27, r26, 0
	add		r26, r26, 15

	b	<Done_setup_lut>		// Return from subroutine

//__Setup_lut
