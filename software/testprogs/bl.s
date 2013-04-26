//.EQU	MMR_MEM		4293918720	//0x00FFF00000
.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.EQU	MMR_VGA			0
.EQU	MMR_LED			5	// 0x05
.EQU	MMR_IRQ_STATUS	15	// 0x0F
.EQU	MMR_IRQ_ENABLE	16	// 0x10
.EQU	MMR_KBD_DATA	18	// 0x12 (Endian confusion)
.EQU	KBD_BIT			2

//r10 - MMR

.region code

	// Initialize MMR address
	MOV R26,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R10,	R26, R27 LSL		// R10 <- _INIT << _SHIFT


	mov r0, 0
	strb r0, r10, MMR_LED	// start with LEDs off
	mov r30, 0 //init link reg
		
	bl <proper>	//led0,1 on iff good, only led0 iff linkval is wrong
firstlr:	bl <pipe2>	//rightmost led3 only iff fail branch
	b <failed>	//leds remain off iff failed


proper:		mov r0, 1
	mov r1, 0
	//check for linked address
	ldadr r2, <firstlr>	//is comparison address in correct place?
	cmp r30, r2
	mov_eq r1, 2
	or r0, r0, r1
	
pipe2:		mov r1, 8
	or r0, r0, r1
	
	strb r0, r10, MMR_LED

failed:		halt
