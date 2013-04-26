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

	mov r27, 255
	strb r27, r10, MMR_LED	// start with LED's on

Main_loop: add r27, r27, 0
	mov r0, 1

	mov r5, 1

	cmp r5, 1
	b_eq <blah>

	add r27, r27, 0
	add r27, r27, 0
	add r27, r27, 0
	add r27, r27, 0
	add r27, r27, 0
	
	add r0, r0, 1		// 2
	add r0, r0, 1		// 2 or 3
blah:	add r0, r0, 1	// 
	add r0, r0, 1
	add r0, r0, 1



	strb r0, r10, MMR_LED	// start with LED's on

	b <Main_loop>

	halt
