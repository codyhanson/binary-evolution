.region code	
	//R10 will be written with FFFFFF to separate each test on output


	mov r10, 0

	//Test 1: Checks Branching looping 3 times by incrementing
	mov r1, 0
	mov r2, 3
mylabel: add r1, r1, 1
	cmp r1, r2
	b_ne <mylabel>

	sub r10, r10, 1

	//Test 2: Checks Branching looping 3 times by decrementing
	mov r2, 0
mylabel2: sub r1, r1, 1
	cmp r1, r2
	b_ne <mylabel2>

	sub r10, r10, 0


//If r7 ever equals 1 then there was an error
	
	//Test 3: Checks conditional execution by performing an and
	mov r1, 1
	and r2, r1, 1
	cmp r2, r1
	mov_ne r7, 1

	sub r10, r10, 0

	//Test 4: Checks conditional execution by performing an or and shift
	mov r3, r1, r2 lsl 
	mov r4, 3
	or r3, r3, 1
	cmp r3, r4
	mov_ne r7, 1  

	sub r10, r10, 0

	//Test 5: Checks conditional execution
	mov r1, 0
	mov r2, 0
	mov r3, 0
	sub r3, r3, 1
	mov_pl r7, 1

	sub r10, r10, 0

	//Test 6: Checks accumbytes, by accumilating Rm = x0102030405 Rn = x0102030405  => Rd = 0x1e
	mov r1, 258
	mov r2, 24
	mov r1, r1, r2 lsl
	mov r2, 8
	mov r3, 772
	mov r3, r3, r2 lsl
	mov r4, 5
	or r1, r1, r3
	or r1, r1, r4
	mov r5, 0
	mov r2, r1, r5 lsl
	mov r4, 30
	accumbytes r3, r1, r2
	cmp r3, r4
	mov_ne r7, 1

	sub r10, r10, 0

	//Test 7: Checks that accumbytes works properly when following a branch instruction (ie not writing back when in middle)	
	mov r4, 0
	mov r5, 1
	cmp r5, r4
	b_ne <mylabel3>
	accumbytes r3, r1, r2
mylabel3: add r6, r4, r5
	cmp r5, r6
	mov_ne r7, 1

	sub r10, r10, 0

	//Test 8: Checks that accumbytes works properly when following a branch instruction (ie not writing back when in middle)	
	mov r4, 0
	mov r5, 1
	cmp r5, r4
	b_ne <mylabel4>
	mov r4, 0
	accumbytes r3, r1, r2
mylabel4: add r6, r4, r5
	cmp r5, r6
	mov_ne r7, 1

	sub r10, r10, 0

	//Test 9: Checks branching after a accumbytes
	mov r1, 258
	mov r2, 24
	mov r1, r1, r2 lsl
	mov r2, 8
	mov r3, 772
	mov r3, r3, r2 lsl
	mov r4, 5
	or r1, r1, r3
	or r1, r1, r4
	mov r5, 0
	mov r2, r1, r5 lsl
	mov r4, 30
	accumbytes r3, r1, r2
	b <mylabel5>
	add r1, r2, r3
mylabel5: cmp r3, r4
	mov_ne r7, 1


	sub r10, r10, 0


	//Test 10: Checks conditional operation
	mov r1, 0
	mov r2, 1
	cmp r2, r1
	mov_lt r7, 1
	cmp r1, r2
	mov_gt r7, 1

	sub r10, r10, 0

	//Test 11: Basic Memory Test
	mov r1, 1
	mov r2, 2
	str r1, r2, 0
	ldr r3, r2, 0
	cmp r1, r3
	mov_ne r7, 1

	sub r10, r10, 0

	//Test 12: Memory Test conditonal loading
	mov r1, 1
	mov r2, 2
	mov r3, 7
	str r1, r2, 0
	sub r2, r2, 1
	cmp r1, r2
	ldr_eq r3, r2, 1
	cmp r1, r3
	mov_ne r7, 1

	sub r10, r10, 0
	



	


	
	halt
