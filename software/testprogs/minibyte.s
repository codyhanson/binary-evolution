.region code

//write a test pattern

	mov r0, 0	//beginning of vga

Mainloop0:	strb r0,r0,0

	add r0, r0, 1

	cmp r0, 256 //one line
	b_ne <Mainloop0>

//-----------------------------------------------
//copy with x ops


	mov r0, 0;	//beginning of vga
	mov r1, 512;	//2next line


Mainloop1:	ldrb r2,r0,0
	strb r2,r1,0

	add r0, r0, 3
	add r1, r1, 3

	cmp r0, 257
	b_lt <Mainloop1>


	HALT
