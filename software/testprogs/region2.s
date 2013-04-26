.region code
label_code: add r1,r2,r3
.region ex
label_9ode: add r2,r9,r3
	    add_gt R3, R30, R20
	    add_gt R4, R27, R1
	    bic R4, R27, R2
	    add_gt R4, R27, R3
	    add_gt R4, R27, R4
	    add_gt R4, R27, R5
	    add_gt R4, R27, R30
	    add_gt R4, R27, R31
	    add_gt R3, R30, 0x0
	    add_gt R3, R30, 0x1
	    add_gt R3, R30, 0x2
	    add_gt R3, R30, 0
	    add_gt R3, R30, -1
	    add_gt R3, R30, -4
	    add_mi R3, R30, -3
	    add_gt R3, R30, -2
	    add_gt R3, R30, 8 
	    add_gt R3, R30, 3 
	    add_gt R3, R30, 10
	    add_gt R3, R30, 20 
	    add_gt R3, R30, 16
		cmp r5, r10
		cmp r5, 0
		cmp r5, -1
		cmp r5, -2
		cmp r5, 3

.region isr
label_2ode: add_ne r2,r31,r8
	mov r9,r4,r3 lsl
	mov r9,r4,r3 lsr
	mov r9,r4,r3 asr
	mov r9, -10
	ldrb r8, r12, 1
	ldrsb r8, r12, -1
	ldadr r20, <label_code>
	return 1
	return 0
	
