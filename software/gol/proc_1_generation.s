.EQU 	BOUNDARY_TOP	2
.EQU 	BOUNDARY_BOTTOM	221
.EQU 	BOUNDARY_LEFT	2
.EQU 	BOUNDARY_RIGHT	253
.EQU	BOUNDARY_MARGIN	5		// Amount to increment to get from right to left

//.EQU	MMR_MEM		4293918720	//0x00FFF00000
.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.EQU	MMR_VGA			0
.EQU	MMR_LED			5	// 0x05
.EQU	MMR_IRQ_STATUS	15	// 0x0F
.EQU	MMR_IRQ_ENABLE	16	// 0x10
.EQU	MMR_KBD_DATA	18	// 0x12 (Endian confusion)
.EQU	KBD_BIT			2
.EQU	MMR_DIPSWITCH	22	// 0x16

.EQU	NBRHD_BIT		2	// bit1

.EQU	UP_ARROW	17	// 0x11
.EQU	LEFT_ARROW	18	// 0x12
.EQU	DOWN_ARROW	19	// 0x13
.EQU	RIGHT_ARROW	20	// 0x14
.EQU	SPACE_BAR	32	// 0x20

//REGISTER USAGE
// 	-- SEE gol/ui_main.s --
// r21:		Old "current cursor"
// r17:		BOUNDARY_RIGHT
// r18:		bottom-right addr (if cursor > that, this generation is done)
// r24:		Current nbrhd op status (use nbrhd instr's or no?)

.region code

Process_1_Gen:	add r27, r27, 0	//noop
	// Store the old "current cursor"
	add r21, r0, 0

	// Initialize current pixel to the beginning of the board
	mov r27, 8			// Shift value
	mov r25, r5, r27 LSL	// Shift the FB bit to 0x100
	add r25, r25, BOUNDARY_TOP
	mov r26, BOUNDARY_LEFT
	mov r0, r25, r27 LSL	// Shift FB-bit & Y-coord over a byte
	add r0, r0, r26			// Add in the X-coord to bottom byte
	
	// Initialize r17 and r18
	mov r17, BOUNDARY_RIGHT
	mov r26, BOUNDARY_BOTTOM
	mov r18, r5, r27 LSL	// Shift FB-bit to 0x100 or 0x000
	add r18, r18, r26		// Add Bottom y-coord to it
	mov r18, r18, r27 LSL	// Shift them over a byte
	add r18, r18, r17		// r18 has bottom right corner
	
	// Check the "nbrhd op status" from dipswitch[2]
Generation_loop:	ldr r26, r10, MMR_DIPSWITCH
	// Process this nbrhd (read dipswitch to choose where to go)
	tst r26, NBRHD_BIT
	b_eq	<Process_this_nbrhd_0>	// USE nbrhd ops
	b		<Process_this_nbrhd_1>	// do NOT use them
Done_proc_nbrhd_1:	add r27, r27, 0	//noop
	
	// Check where the cursor is, and move accordingly
	mov r27, 255		// 0x00FF
	and r26, r0, r27	// Grab X-coord
	cmp r26, r17		// Check if we're at the right border
	add_eq r0, r0, BOUNDARY_MARGIN	// If so, add MARGIN amount to get to beginning of next row
	cmp r26, r17		
	add_ne r0, r0, 1	// If not, increment by 1
	
	cmp r0, r18			// Are we out of the board?
	b_le	<Generation_loop>


//__DONE WITH THIS GENERATION
	// Restore the old "current cursor"
	add r0, r21, 0

	b <Done_Process_1_Gen>


