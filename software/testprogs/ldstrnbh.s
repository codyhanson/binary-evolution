.region isr 
ISR: 	add r1,r1,r1
	return 1


.region ex
EX:	add r1,r1,r1
	return 1

.region code

MAIN:	ldadr r0,<w1>
	ldr r0, r0, 0
	add r1, r0, 0

	ldadr r2,<w2>
	ldr r2, r2, 0
	add r3, r2, 0

	ldadr r4,<w3> 
	ldr r4, r4, 0
	add r5, r4, 0

	mxadd r6, r0, r2
	mxsub r20, r0, r2
	accumbytes r8, r2, r3
	bwcmpl r10,r2
	mxmul r12,r4,r4

	ldadr r22, <VGAFB1>
	
	not r1,r1
	strneighbor r0,r22,25
	ldneighbor r25,r22,25



	HALT
//.region data
