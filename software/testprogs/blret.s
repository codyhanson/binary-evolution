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
		
	bl <proper>	//led0,1 on iff good, only led1 iff linkval is wrong
	mov r1, 2
	or r0, r0, r1
	strb r0, r10, MMR_LED
	halt



proper:		mov r0, 1
	return 1 
	//add r31, r30, 0		//LR->PC: manual ret.
	//fails - can we write to pc?

	
	//should never execute.
	//led3 only, iff superbad
	mov r0, 8
	strb r0, r10, MMR_LED
	halt
	




