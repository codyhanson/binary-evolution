.EQU 1 2//comment
//comment2
 	//comment 3
.EQU hex bin

.EQU one two //comment

 add_ff r1,r2,r3
__START:  add r1   , 	r2,      r3
LABEL:  add r1   , 	r2,      r3
LABEL1:  bic r1   , 	r2,      r3
LABEL20:  add r1   , 	r224,      r31
LABEL5:  or r1   , 	r2a,      r31

	add  	r23,r22, 0x43FT
	add_eq 	r23,r22, 0x43F

	ldr r1, r22, 1
	ldr r1, r22, 0xFFF 
	ldr r1, r22, 0xFF 
	ldr r1, r22, r4

	return 0
	return 1
	return 3
	return r1
	return_ne 0
	return_WW 1

	cmp r1, r2
	cmp_gt r1,r2
	cmp r1, 0
	cmp 0 , r1
	cmp r10, 0xF

imalabel:   b r1
	b 20
	b -20
	b 0x20
	b LABEL1
	ldadr r4, LABEL5
