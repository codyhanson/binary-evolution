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
.EQU	SPACE_BAR	32	// 0x20

//REGISTER USAGE
// r0: 		current fb
// r1:		current pixel addr
// r2:		pixel addr in other fb
//
// R14:		MMR baseaddr
// r15:		summing mask
//
// R20-R27:	Temp regs

.region code

	// Initialize MMR address
	MOV R26,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R14,	R26, R27 LSL		// R10 <- _INIT << _SHIFT

	mov r27, 255
	strb r27, r14, MMR_LED	// start with all LED's on

	// Initialize r15  -- Neighborhood summing mask (0x0101010101)
	mov	r15, 257			// 0x0101
	mov r27, 16				// Shift size
	mov r15, r15, r27 LSL	// Left shift by 2 bytes
	mov r27, 8
	or	r15, r15, 257		// r15 now has 0x01010101
	mov r27, r15, r27 LSL	// Left shift by 2 bytes
	or	r15, r27, 1			// r15 now has 0x0101010101


	mov r20, 65535	// End of FB1	 (0xFFFF)

	mov r0, 0		// Current FB: 0=FB1, 1=FB2
	mov r1, 0		// pixel addr in FB1

	//Enable KBD IRQ
	mov r27, KBD_BIT
	strb r27, r14, MMR_IRQ_ENABLE

Main_loop: mov r27, 16
	mov r1, r0, r27 LSL		// current pixel gets current FB (0/1) << 16
							//  	so either 0x10000 or 0x00000

Wait_kbd:	ldrb r27, r14, MMR_IRQ_STATUS
	tst r27, KBD_BIT // is KBD_BIT set?
	b_eq <Wait_kbd>
//__Wait_kbd

	// Clear IRQ status
	mov r27, KBD_BIT
	strb r27, r14, MMR_IRQ_STATUS





Generation_loop:	add r27, r27, 0	//noop
	
Process_this_nbrhd: add r27, r27, 0	//noop
	add r27, r27, 0	//noop

	ldneighbor r25, r1, 0	// get this neighborhood
	and r25, r25, r15		// and it with summing mask (masks out all but
	and r26, r26, r15		// bit0 of each pixel
	accumbytes r24, r25, r26	// get the nbrhd sum
	add r27, r27, 0		//noop
	add r27, r27, 0		//noop

	// Get pixel's addr in other FB
	mov r27, 65535
	add r27, r27, 1
	add r2, r1, r27		// add 0x10000 to pixel address
	mov r26, 65535
	add r27, r26, r27	// r27 has 0x1FFFF
	and r2, r2, r27		// mask pixel address to stay within the two FBs

	ldrb	r25, r1, 0		// Get current pixel value
	and		r25, r25, 1		// Check bit0
	b_eq	<Was_dead>
	add r27, r27, 0	//noop
	//b_ne	<Was_alive>		// Implied branch -- "Was_alive" is the next instr

Was_alive:	mov r26, 0		// Default to dead
	cmp r24, 3
	mov_eq r26, 255			// stays alive
	cmp r24, 4
	mov_eq r26, 255			// stays alive

	add r27, r27, 0		//noop
	add r27, r27, 0		//noop

	b	<Store_cell>
	add r27, r27, 0	//noop

Was_dead:	mov r26, 0		// Default to dead
	cmp r24, 3
	mov_eq r26, 255			// cell is born

Store_cell:	strb r26, r2, 0	// store result in other FB
	strb r26, r14, MMR_LED	// write it to LEDs too
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
//__DONE WITH THIS PIXEL

	// Process next nbrhd
	add r1, r1, 1		// move to next nbrhd
	and r27, r1, r20	// Mask off the FB bit
	cmp r27, r20		// Compare to 0xFFFF (end of FB)
	b_ne	<Generation_loop>

	// Done with this generation -- Switch to other FB

	// Switch FB
	add r0, r0, 1
	and r0, r0, 1
	strb r0, r14, MMR_VGA

	add r27, r27, 0		//noop
	add r27, r27, 0		//noop
	b <Main_loop>
//__DONE WITH THIS GENERATION
	
	add r27, r27, 0		//noop
	add r27, r27, 0		//noop
	add r27, r27, 0		//noop
	add r27, r27, 0		//noop

	halt


