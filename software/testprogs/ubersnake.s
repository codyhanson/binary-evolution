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

.region code

	// Initialize MMR address
	MOV R26,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R10,	R26, R27 LSL		// R10 <- _INIT << _SHIFT

	// enable kbd irq
	mov r27, KBD_BIT
	strb r27, r10, MMR_IRQ_ENABLE

	// initialize snake's head
	mov r0, 32768
	add r0, r0, 127		// move it to the middle of the row

	mov r27, 255
	strb r27, r10, MMR_LED	// start with all LED's on

	// Store the snake's head
	mov r24, 255	//white
	strb r24, r0, 0

Main_loop: mov r27, 65535
	and r0, r0, r27	// don't let the snake get out of the FB

Wait_kbd:	ldrb r27, r10, MMR_IRQ_STATUS
	tst r27, KBD_BIT // is KBD_BIT set?
	b_eq <Wait_kbd>
//__Wait_kbd

	// Clear IRQ status
	mov r27, KBD_BIT
	strb r27, r10, MMR_IRQ_STATUS

	ldrb r1, r10, MMR_KBD_DATA	// get the key
	strb r1, r10, MMR_LED	// store the key in the LEDs


 mov r27, UP_ARROW
	cmp r1, r27
	sub_eq r0, r0, 256	// if so, move up a row

 mov r27, LEFT_ARROW
	cmp r1, r27
	sub_eq r0, r0, 1	// if so, move left a column

 mov r27, DOWN_ARROW
	cmp r1, r27
	add_eq r0, r0, 256	// if so, move down a row

 mov r27, RIGHT_ARROW
	cmp r1, r27
	add_eq r0, r0, 1	// if so, move right a row


	// Store the snake's head
	mov r24, 255	//white
	strb r24, r0, 0

	b <Main_loop>

	halt
