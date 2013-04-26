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


	// Initialize MMR address
	MOV R26,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R10,	R26, R27 LSL		// R10 <- _INIT << _SHIFT

	//contrive it so r0 is a glitchy pixel in the glider setup (21,16) for example
	mov r0, 5392		//0x1510
	mov r1, 4			// expected accum result

	mov r18, 0	// debug counter

	mov r27, 255
	strb r27, r10, MMR_LED		// init to all LEDs on
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop

Main_loop:	add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop


	// rewrite the pixel (dark or light gray depending on value)
	ldrb r4, r0, 0	// get pixel val
	and r27, r4, 1	// get bottom bit
	cmp r27, 0	
	mov_eq r24, 100	//is black? => dark grey
	cmp r27, 0
	mov_ne r24, 201	//else => light grey

	strb r24, r0, 0


	mov r27, 200	// gray
	strb r27, r0, 0	// make the target pixel gray so we can tell
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop

	ldneighbor r25, r0, 0		// get this neighborhood
	and r25, r25, r15			// and it with summing mask (masks out all but
	and r26, r26, r15			// bit0 of each pixel
	accumbytes r1, r25, r26	// expected accum result
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop
	
Accum_loop:	add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop

	ldneighbor r25, r0, 0		// get this neighborhood
	and r25, r25, r15			// and it with summing mask (masks out all but
	and r26, r26, r15			// bit0 of each pixel
	accumbytes r24, r25, r26	// get the nbrhd sum
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop
	cmp r24, r1
	b_eq <Accum_loop>

	// If it falls through, that means r24 has the wrong accum result, increment counter
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop
	add r18, r18, 1	//increment the debugger
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop

	// Update the debug counter in the LEDs
	strb r18, r10, MMR_LED
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop

	//move to next pixel
	add r0, r0, 1

	mov r25, 65535	// 0x0FFFF
	and r26, r0, r25	// don't let the cursor get out of the FB's
	cmp r26, 0	// if out of FB1, halt
	b_ne <Main_loop>
			add r27, r27, 0	//noop
			add r26, r26, 0	//noop
			add r28, r28, 0	//noop

	halt
