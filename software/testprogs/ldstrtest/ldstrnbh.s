
.region code
	ldadr r0, <FB1>
	ldadr r1, <FB2>
	mov r2,  1
	mov r3,  512
	mov r4, -1 //all FF's	
	mov r5, -1 //all FF's	

Loop:	strneighbor r4, r2 
	add r2,r2, 5	
	cmp r2, r1
	b_ne <Loop>
	halt
