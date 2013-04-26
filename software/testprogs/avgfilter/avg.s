// uses a 3x3 spatial averaging filter to filter half the frame buffer
//does all work in FB0

.EQU width 254
.EQU height 254  //only average half the image
.EQU KB  18

.region code

	mov r0, 257  //current pixel address, start one line down and one pixel in 
	ldadr r1, <fb1>
	//add r1,r1, 257 // first destination pixel for the lower half averaged image
	add r1,r1, 32768 // first destination pixel for the lower half averaged image
	mov r10, width
	mov r11, height 
	mov r12, 0 //use as row count
	mov r13, 3 //use for shift right by 3, which is a divide by 8
    mov r14, 0

vertloop: add r0, r0, 0 

horizloop: ldneighbor r3, r0,0 //put neighborhood into r3 and r4
	   ldrb r5,r0,0 //get the center alone
	   accumbytes r6 , r3,r4
       sub r6,r6,r5 //subtract the center
	   mov r6,r6, r13 LSR //divide by 8
	   strb r6, r1,0 //store averaged byte to bottom half
	  
	   //now increment addresses of r0 and r1 to see if we are at the end of a row
	   add r14,r14,1 //col count ++
	   cmp r14,r10 // at end of row?	
	   b_eq <endhorizloop>
incbyone:  add r0,r0,1
	   add r1,r1,1 
	   b <horizloop> 
endhorizloop: add r12,r12,1 //rowcount++
		add r0,r0,3
		add r1,r1,3 //allow for buffer, move to next row
		mov r14,0

//end vert loop
	cmp r12, r11
	b_ne <vertloop>
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
