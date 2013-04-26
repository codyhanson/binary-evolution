//implements a median filter, 3x3

.EQU width 254
.EQU height 254  //leave a border around the edge
.EQU KB  18
.EQU medianoffset 5

.region code

	mov r0, 257  //current pixel address, start one line down and one pixel in 
	ldadr r1, <fb2>
	add r1,r1, 257 // first destination pixel for the lower half averaged image 
	mov r2, width
	mov r7, height 
	mov r8, 0 //use as row count
	mov r6, 0 //col count 

	mov r20,0

	ldadr r11, <swapspace> 

horizloop: ldneighbor r3, r0,0 //put neighborhood into r3 and r4 

	///////////////////////////
	//actual image proc operation
	///////////////////////////
	mov r9, 8 //shift right by 1 byte amount
	mov r10, 5 
	add r12,r11,0	//use r12 to hold incremented values of address of swapspace

	//parse the bytes from r3 and r4 out into r10-r18	
bytebreakout:	and r13, r4, 255
		and r14, r3, 255
		mov r4,r4, r9 LSR
		mov r3,r3, r9 LSR
		strb r13,r12,0	
		strb r14,r12,5	
		add r12,r12,1
		sub r15,r12,r11	
		cmp r15,r10 //have we gone 9 times?
		b_ne <bytebreakout>

	//begin the bubble sort
	//swap regs are r13 and r14
		mov r16, 9
sortstart: 	add r12,r11,0	//reset memory pointer
		mov r10, 0 //swapped flag, branch here to try another run

continue:	sub r15	,r12,r11
		cmp r15,r16	 //do a check to see if we should keep going in this run 
		b_eq <endsorttest> //branch if at the end of this pass

		ldrb r13,r12,0	
		ldrb r14,r12,1	
		add r12,r12,1	
		cmp r13,r14 
		b_ls <continue> //r13 =< r14 don't swap

		swp r13,r13,r14 //r13 > r14, swap
		strb r13,r12, -1
		strb r14,r12, 0
		mov r10,1 //set swapped flag
		b <continue>

endsorttest:	cmp r10, 0	
		b_ne <sortstart>

		//sorted!
		ldrb r5,r11, medianoffset //this is the elusive median value 

		//add noops
		mov r20,0
		add r20,r20,0
		add r20,r20,0
		add r20,r20,0
		add r20,r20,0
		add r20,r20,0

	///////////////////////////
	//actual image proc operation
	///////////////////////////
	strb r5, r1,0 //store filtered byte to FB2
	//now increment addresses of r0 and r1 to see if we are at the end of a row
	add r6,r6,1 //col count ++
	cmp r6,r2 // at end of row?	
	b_eq <endhorizloop>
incbyone:  add r0,r0,1
	add r1,r1,1 
	b <horizloop> 
endhorizloop: add r8,r8,1 //rowcount++
	add r0,r0,3
	add r1,r1,3 //allow for buffer, move to next row
	mov r6,0

	cmp r8, r7
	b_ne <horizloop> 

//begin interactive section
	ldadr r0, <mmradd> //no offset is the vga mmr
	ldr r0,r0,0	//r0 now has 0xFFF0000000 if the write datafile was assembled 
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
