.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.region code

	// Initialize MMR address
	MOV R14,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R14,	R14, R27 LSL		// R14 <- _INIT << _SHIFT
	
//write a test pattern

	mov r0, 0	//beginning of vga

Mainloop0:	strb r0,r0,0

	add r0, r0, 1

	cmp r0, 32768 //middle of vga
	b_ne <Mainloop0>

//-----------------------------------------------
//copy with x ops


	mov r0, 0;	//beginning of vga
	mov r1, 32768;	//middle of vga
	mov r5, 255;	//mask for lower byte

Mainloop1:	ldrb r2,r0,0
	strb r2,r1,0

	add r0, r0, 3
	add r1, r1, 3

	and r4, r1, r5
	cmp r4, 252
	add_gt r1, r1, 256
	cmp r4, 252
	add_gt r0, r0, 256


	cmp r0, 32768
	strb_lt r0, r14, 5  // r14 = MMR base addr. + MMR_LED
	
	cmp r0, 32768
	b_lt <Mainloop1>

end:	mov r24, 0	//nop?
	HALT
