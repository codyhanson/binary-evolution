// Waits for kbd input
.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.EQU	MMR_IRQ_ENABLE	16	// 0x10
.EQU	MMR_IRQ_STATUS	15	// 0x0F
.EQU	MMR_KBD_DATA	18	// 0x12 (Endian confusion)
.EQU	BYTE_MASK		255	// 0xFF

.EQU	KBD_BIT		2	// 2_0010

.region code

	// Initialize MMR address
	MOV R26,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R0,		R26, R27 LSL		// R <- _INIT << _SHIFT

	mov r20, KBD_BIT
	strb r20, r0, MMR_IRQ_ENABLE	//enable kbd irq

	MOV r1, -1	// previous kbd key

Main:	ldr r5, r0, MMR_IRQ_STATUS
	tst r5, KBD_BIT // is KBD_BIT set?
	b_eq <Main>

	strb r5, r0, MMR_IRQ_STATUS	//clear irq
	ldrb	r2, r0, MMR_KBD_DATA	//ld kbd data

	// Store the key val << 24 to Mem[key val]
	strb r2, r2, 528	// store the byte partway into the 3rd row

	b <Main>

	halt
