.region code

//write a test pattern

	mov r0, 0	//beginning of vga

Mainloop0:	strb r0,r0,0

	add r0, r0, 1

	cmp r0, 32768 //middle of vga
	b_ne <Mainloop0>

//-----------------------------------------------
//copy with x ops


	mov r0, 0;	//beginning of vga
	mov r1, 32768;	//middle of vga
	mov r5, 255;	//mask for lower byte

Mainloop1:	ldneighbor r2,r0,0
	strneighbor r2,r1,0

	add r0, r0, 5
	add r1, r1, 5

	and r4, r1, r5
	cmp r4, 250
	add_gt r1, r1, 1024
	cmp r4, 250
	add_gt r0, r0, 1024

	cmp r0, 32768
	b_lt <Mainloop1>


end:	mov r24, 0	//nop?
	HALT
