
.EQU            MMR_MEM_INIT    4095    //0x00000FFF
.EQU            MMR_MEM_SHIFT   28              // to shift _INIT over to become MMR_MEM
.EQU    MMR_KBD_DATA    18      // 0x12 (Endian confusion)

.region code


	mov r0, 0
	mov r1, 10//65535
	mov r2, MMR_MEM_INIT
	mov r3, MMR_MEM_SHIFT
	mov r2, r2, r3 LSL //r2 holds mmr base
	mov r3, MMR_KBD_DATA

	mov r5, -20 //have r5 hold the byte to write out to all the pixels	
WRITELOOP:	strb r5,r0,0 //put byte into fb
		add r0,r0,1
		cmp r0,r1
		b_ne <WRITELOOP>	
		mov r0, 0 //reset to start of FB
		//got down here, wrote a whole frame, get a new byte from the kb
		ldrb r5, r2, MMR_KBD_DATA
		//check if the lsb is 0, then its ok to write out	
		//add_ne r5,r10,0 //r5 <- r10 if the lsb of the new byte was a 1

		//write some test neighborhoods
		mov r10, -1
		mov r11, -1 
		mov r12, 32768
		mov r13, 32748
		mov r14, 32788
		strneighbor r10, r12,0
		strneighbor r10, r13,0
		strneighbor r10, r14,0
		strneighbor r10, r14,0
		
		strneighbor r10, r12,5 
		add r0,r0,0
		strneighbor r10, r13,5
		add r0,r0,0 
		strneighbor r10, r14,5
		add r0,r0,0 

	b <WRITELOOP>
