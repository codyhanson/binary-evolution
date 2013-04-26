//.EQU  MMR_MEM_INIT    4095    //0x00000FFF
//.EQU  MMR_MEM_SHIFT   28              // to shift _INIT over to become MMR_MEM

.EQU KB 18
.region code


	ldadr r0, <mmr_add> //no offset is the vga mmr
	ldr r0,r0,0	//r0 now has 0xFFF0000000 if the write datafile was assembled

	//mov r0, MMR_MEM_INIT
	//mov r20, MMR_MEM_SHIFT
	//mov r0,r0,r20 LSL
	//R0 has the mmr address

	mov r1, 0 //fb1, bw
	mov r2, 1 //fb2, bw
	mov r3, 2 //fb1, color
	mov r4, 3 //fb2, color 

	//ascii keycodes for 1, 2 ,3, 4
	mov r11, 49
	mov r12, 50
	mov r13, 51
	mov r14, 52

	add r10, r3, 0

main:	str r10, r0, 0  //store the mode
	ldr r6, r0, KB // read kb mmr
	//read the kb to determine which mode to go into
	cmp r6, r11	
	add_eq r10, r1, 0
	cmp r6, r11	
	b_eq <main>

	cmp r6, r12	
	add_eq r10, r2, 0 
	cmp r6, r12	
	b_eq <main>

	cmp r6, r13	
	add_eq r10, r3, 0 
	cmp r6, r13	
	b_eq <main>

	cmp r6, r14	
	add_eq r10, r4, 0 
	cmp r6, r14	
	b_eq <main>

	b <main>

	halt
