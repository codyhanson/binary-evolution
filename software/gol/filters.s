
.EQU width 255  //256 across
.EQU height 234 //240 tall fb plus 6 tall text bar 
.EQU KB  18

.region code

//main ui branches here on 'a' 
average: ldadr r0, <myFB2>
	ldadr r1, <myFB1>
	ldadr r2, <fbcount>
	ldr r2, r2,0
	mov r13, 3 //use for shift right by 3, which is a divide by 8
	mov r11, 0 
avgloop: ldneighbor r3, r0,0 //put neighborhood into r3 and r4
	ldrb r5,r0,0 //get the center alone
	accumbytes r6 , r3,r4
   	sub r6,r6,r5 //subtract the center
	mov r6,r6, r13 LSR //divide by 8
	strb r6, r1,0 //store averaged byte to bottom half 
	add r0,r0,1
	add r1,r1,1 
	add r11,r11,1
	cmp r2, r11
	b_ne <avgloop> //have we gone over all the pixels yet?
	mov r6, -1
	b <Img_Wait_kbd>
//end average filter


median: ldadr r0, <myFB2>
	ldadr r1, <myFB1>
	ldadr r2, <fbcount>
	ldr r2, r2,0
	mov r20,0 //use as count
	mov r9, 8 //shift right by 1 byte amount
	mov r16, 9
	ldadr r11, <swapspace> 

medianloop: ldneighbor r3, r0,0 //put neighborhood into r3 and r4 

	///////////////////////////
	//actual image proc operation
	///////////////////////////
	add r12,r11,0	//use r12 to hold incremented values of address of swapspace
	mov r10, 5 

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
	ldrb r5,r11, 5 //this is the elusive median value 
	strb r5, r1,0 //store filtered byte to destination fb
	//now increment addresses of r0 and r1 to see if we are at the end of a row
	add r0,r0,1
	add r1,r1,1 
	add r20,r20,1

	cmp r2, r20
	b_ne <medianloop> 
	//median is done
	mov r6, -1
	b <Img_Wait_kbd>


addnoise: ldadr r24, <fbcount>
	//load random number MMR	
	//	0xFF_F000_0004 - Random Number Byte		
	//		Bit(s):		Usage
	//		  7:0		 Random Number 
        ldr r24,r24,0 
	// initialize this and that addr
	ldadr r21, <myFB2>
	mov r25, 0			// initialize this addr to 0
	mov r26, 15 //if below this number, add noise
	mov r23, -1 //const
	mov r22, 0 //const

noiseloop:	ldrb r27, r17, 4 //random byte
		cmp r27,r26
		b_gt <endstorenoise> 
		add r28, r22,0 //set to black by default
		tst r27, 1 //test lsb
		add_ne r28, r23,0 //set to white  
		strb r28, r21, 0	// Store into fb2 
endstorenoise:	add r25, r25, 1 //count++
		add r21,r21,1
		// Increment the addresses

		cmp r25, r24		// Done?
		b_ne	<noiseloop>	// If not, continue looping
		//done adding noise 
		mov r6, -1
		b <Img_Wait_kbd> //return to input loop 

addgnoise: ldadr r24, <fbcount>
	//load random number MMR	
	//	0xFF_F000_0004 - Random Number Byte		
	//		Bit(s):		Usage
	//		  7:0		 Random Number 
        ldr r24,r24,0 
	// initialize this and that addr
	ldadr r21, <myFB2>
	mov r25, 0			// initialize this addr to 0
	mov r26, 15 //if below this number, add noise

gnoiseloop:	ldrb r27, r17, 4 //random byte
		cmp r27,r26
		b_gt <gendstorenoise> 

		ldrb r27, r17, 4 //spin for a random while
		add r27, r27, 1
gnoisespin:	add r0,r0,0
		add r0,r0,0
		add r0,r0,0
		sub r27,r27,1	
		b_ne <gnoisespin>	

		add r1,r1,0
		add r2,r2,0
		ldrb r27, r17, 4
		add r1,r1,0
		add r2,r2,0
		add r3,r3,0
		add r4,r4,0
		strb r27, r21, 0	// Store into fb2 
gendstorenoise:	add r25, r25, 1 //count++
		add r21,r21,1
		// Increment the addresses

		cmp r25, r24		// Done?
		b_ne	<gnoiseloop>	// If not, continue looping
		//done adding noise 
		mov r6, -1
		b <Img_Wait_kbd> //return to input loop 



//r6 holds the threshold amount
threshold: ldadr r24, <fbcount> //covers a 256x234 fb
		ldr r24,r24,0 
		ldadr r20, <myFB1>
		ldadr r21, <myFB2>
		mov r25, 0			// initialize this addr to 0

thresh_loop:	ldrb r27, r21, 0	
		mov r28, 255 //all white if passes (the binarization)
		cmp r27,r6
		mov_lt r28, 0 //store a 0 if the byte is not above threshold 
		strb r28, r20, 0	// Store into fb2

	// Increment the addresses
	add r25, r25, 1 //count++
	add r21, r21, 1
	add r20, r20, 1

	cmp r25, r24		// Done?
	b_ne	<thresh_loop>	// If not, continue looping
	//done copying FB over
	mov r6, -1
	b <Img_Wait_kbd> //return to input loop 

