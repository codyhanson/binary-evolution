//.EQU	MMR_MEM		4293918720	//0x00FFF00000
.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.EQU	MMR_VGA			0
.EQU	MMR_LED			5	// 0x05
.EQU	MMR_IRQ_STATUS	15	// 0x0F
.EQU	MMR_IRQ_ENABLE	16	// 0x10
.EQU	MMR_KBD_DATA	18	// 0x12 (Endian confusion)
.EQU	KBD_BIT			2

.region code

	// Initialize r15  -- Neighborhood summing mask (0x0101010101)
	mov	r15, 257			// 0x0101
	mov r27, 16				// Shift size
	mov r15, r15, r27 LSL	// Left shift by 2 bytes
	mov r27, 8
	or	r15, r15, 257		// r15 now has 0x01010101
	mov r27, r15, r27 LSL	// Left shift by 2 bytes
	or	r15, r27, 1			// r15 now has 0x0101010101

	mov r27, 255
	strb r27, r10, MMR_LED		// start with all LEDs on
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop

	// Initialize MMR address
	MOV R26,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R10,	R26, R27 LSL		// R10 <- _INIT << _SHIFT

	//contrive it so r0 is a glitchy pixel in the glider setup (21,16) for example
	mov r0, 5392		//0x1510

	ldrb r24, r0, 0	//get value
	and r25, r24, 1	// get bit0
	mov r26, 160	// gray, keep bit0 set
	add r27, r26, r25 // 160 + 1 or 0 depending on if bit0 is set
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop
	strb r27, r0, 0	// make the target pixel gray so we can tell
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop

	// Set expected result
	ldneighbor r25, r0, 0		// get this neighborhood
	and r25, r25, r15			// and it with summing mask (masks out all but
	and r26, r26, r15			// bit0 of each pixel
	accumbytes r1, r25, r26	// get the nbrhd sum
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop
	//r1 has expected sum
	
	strb r1, r10, MMR_LED		// write the expected sum to the LEDs
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop


Main_loop:	add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop

	ldneighbor r25, r0, 0		// get this neighborhood
	and r25, r25, r15			// and it with summing mask (masks out all but
	and r26, r26, r15			// bit0 of each pixel
	accumbytes r24, r25, r26	// get the nbrhd sum
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop
	cmp r24, r1	// compare new sum with the expected
	b_eq <Main_loop>

	// If it falls through, that means r24 has the wrong accum result
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop

	// Store the wrong sum value to the LED's
	strb r24, r10, MMR_LED
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop

	// Make bottom row of VGA white so we can the program is done
	mov r26, 255
	mov r27, 65535
Bleh_loop: strb r26, r27, 0
	sub r27, r27, 1

	and r24, r27, r26	//get bottom byte
	cmp r24, 0
	b_ne	<Bleh_loop>

			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop

	halt
