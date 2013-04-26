
.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.region code	

	MOV R14,	MMR_MEM_INIT

	MOV R27,	MMR_MEM_SHIFT
	MOV R14,	R14, R27 LSL		// R14 <- _INIT << _SHIFT
	or	 R15,	R14,0
	or	 r16,	r14,0
	or  	r17,	r14,0


	mov r3, 18          
	or r14, r14, r3    //0xFFF00012 is location of keyboard	in r14
	mov r3, 5
	or r15, r15, r3    //0xFFF00005 is location of leds in r15
	mov r3, 15
	or r16, r16, r3    //0xFFF0000F is location of irq status in r16
	mov r3, 16 
	or r17, r17, r3    //0xFFF00010 is location of irq en in r17	
	mov r3, 0



ToP:	mov r20, 65535	// 2^16 -1

Waste_time: sub r20, r20, 1
	cmp r20, r3
	b_ne <Waste_time>


	ldr r21, r14, 0		// get kbd data
	str r21, r15, 0    //write data to leds



	b <ToP> 

	
	halt






	 

	

