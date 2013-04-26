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


.region code

	// Initialize MMR address
	MOV R26,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R14,	R26, R27 LSL		// R10 <- _INIT << _SHIFT

	// enable kbd irq
	mov r27, KBD_BIT
	strb r27, r14, MMR_IRQ_ENABLE

	mov r23, 3
	strb r23, r14, MMR_LED	// start with all LED's on
	add r23, r23, 1

	mov r0, 0		// FB1
	mov r1, 65535	// FB2
	mov r27, 384	// halfway through 2nd row
	add r1, r1, r27

	mov r2, 63
	mov r3, 255

	mov r5, 0

	strb r23, r14, MMR_LED	// start with all LED's on
	add r23, r23, 1

	strb r2, r0, 5
	strb r2, r0, 6
	strb r2, r0, 8
	strb r2, r0, 9
	strb r2, r0, 10
	strb r2, r0, 11
	strb r2, r0, 14
	strb r2, r0, 15
	strb r2, r0, 17
	
	strb r23, r14, MMR_LED	// start with all LED's on
	add r23, r23, 1

	strb r3, r1, 0
	strb r3, r1, 1
	strb r3, r1, 2
	strb r3, r1, 3
	strb r3, r1, 8
	strb r3, r1, 9
	strb r3, r1, 10
	strb r3, r1, 11

	strb r23, r14, MMR_LED	// start with all LED's on
	add r23, r23, 1

	mov r27, 512
	add r0, r0, r27
	
	add r2, r2, 63

	strb r2, r0, 5
	strb r2, r0, 6
	strb r2, r0, 8
	strb r2, r0, 9
	strb r2, r0, 10
	strb r2, r0, 11
	strb r2, r0, 14
	strb r2, r0, 15
	strb r2, r0, 17
	
	strb r23, r14, MMR_LED	// start with all LED's on
	add r23, r23, 1

	mov r27, 32768
	add r1, r1, r27
	sub r3, r3, 63

	strb r3, r1, 0
	strb r3, r1, 1
	strb r3, r1, 2
	strb r3, r1, 3
	strb r3, r1, 8
	strb r3, r1, 9
	strb r3, r1, 10
	strb r3, r1, 11

	strb r23, r14, MMR_LED	// start with all LED's on
	add r23, r23, 1




Wait_kbd:	ldrb r27, r14, MMR_IRQ_STATUS
	tst r27, KBD_BIT // is KBD_BIT set?
	b_eq <Wait_kbd>
//__Wait_kbd

	// Clear irq status
	mov r27, KBD_BIT
	strb r27, r14, MMR_IRQ_STATUS

	// R5 has current FB
	add r5, r5, 1
	and r5, r5, 1

	str	 r5, r14, 0		// signal FB MMR
	strb r5, r14, MMR_LED	// change LEDs

	b <Wait_kbd>

	halt

