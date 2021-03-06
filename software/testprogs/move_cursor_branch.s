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
.EQU	ENTER_KEY	13	// 0x0d
.EQU	TAB_KEY		9	// 0x09
.EQU	ESC_KEY		27	// 0x1b

.region code

	// Initialize MMR address
	MOV R26,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R10,	R26, R27 LSL		// R10 <- _INIT << _SHIFT

	// initialize cursor's head
	mov r0, 32768
	add r0, r0, 127		// move it to the middle of the row

	// Store the cursor's head
	mov r24, 255	//white
	strb r24, r0, 0

	// enable kbd irq
	mov r27, KBD_BIT
	strb r27, r10, MMR_IRQ_ENABLE

	// initialize last pixel
	add r3, r0, 0	//address
	ldrb r4, r3, 0	//data

	mov r27, 255
	strb r27, r10, MMR_LED	// start with all LED's on

Main_loop: mov r27, 65535
	and r0, r0, r27	// don't let the cursor get out of the FB

Wait_kbd:	ldrb r27, r10, MMR_IRQ_STATUS
	tst r27, KBD_BIT // is KBD_BIT set?
	b_eq <Wait_kbd>
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
//__Wait_kbd

	// Clear IRQ status
	mov r27, KBD_BIT
	strb r27, r10, MMR_IRQ_STATUS

	ldrb r1, r10, MMR_KBD_DATA	// get the key
	strb r1, r10, MMR_LED	// store the key in the LEDs


 mov r27, UP_ARROW
	cmp r1, r27
	sub_eq r0, r0, 256	// if so, move up a row
	cmp r1, r27
	b_eq	<Move_cursor>
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop

 mov r27, LEFT_ARROW
	cmp r1, r27
	sub_eq r0, r0, 1	// if so, move left a column
	cmp r1, r27
	b_eq	<Move_cursor>
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop

 mov r27, DOWN_ARROW
	cmp r1, r27
	add_eq r0, r0, 256	// if so, move down a row
	cmp r1, r27
	b_eq	<Move_cursor>
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop

 mov r27, RIGHT_ARROW
	cmp r1, r27
	add_eq r0, r0, 1	// if so, move right a row
	cmp r1, r27
	b_eq	<Move_cursor>
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop

 mov r27, SPACE_BAR
	cmp r1, r27
	not_eq r4, r4		// if so, toggle bit 
	//r0 (current address) stays the same
	cmp r1, r27
	strb r4, r10, MMR_LED	// store the underlying pixel value in the LED
	cmp r1, r27
	b_eq	<Move_cursor>
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop


Move_cursor:	add r27, r27, 0
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	add r27, r27, 0	//noop
	//restore last pixel
	strb r4, r3, 0
	//set next last pixel
	add r3, r0, 0
	ldrb r4, r0, 0 	//always black or white

	// generate and store the new cursor
	cmp r4, 0	
	mov_eq r24, 100	//is black? => dark grey
	cmp r4, 0 	//necessary?
	mov_ne r24, 200	//else => light grey

	strb r24, r0, 0

	

	b <Main_loop>

	halt
