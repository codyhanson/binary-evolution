.region code
	add r0, r0, 1 //annoying comment
	add_eq r1, r0, r0
	add r2, r1, r0
label1:	add r10,r2, -1
	add r10,r10, -1
	add_ne r10,r10,r0

	b <jumpfwd>

	mov r1, 255
	mov r9, -15 
	mxadd r4,r1,r9 

loopPrep:	mov r4, 7
	mov r4,r4,r0 lsl //shift 7 left by 1 bit
loop:   sub r4, r4, 1 
	b_ne <loop> 

	bl <mysub> 

	ldadr r0, <myB>
	ldr r1, r0,0

	ldadr r2, <myMiOneb2>
	ldrb r3, r2, 0
	ldrb r4, r2, 1
	ldrsb r5, r2, 0
	ldrsb r6, r2, 1

	ldadr r7, <abc1>
	ldr r8, r7,0
	not r9,r8
	ldadr r10, <myspace20>
	str r9,r10,0		
	strh r9,r10,6		
	strb r9,r10,10		
	halt 

jumpfwd: sub r1, r2, -1
	 b <loopPrep>

mysub: mov r8, 63	//subroutine, bic and AND tests.
	mov r1, -1
	bic r2, r1, r8
	bic r3, r1, 15
	and r4,r8,r1
	and r4,r8,-7
	return 0 
