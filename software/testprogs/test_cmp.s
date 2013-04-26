.EQU VAL	123

.region code

Main:	mov r0, VAL
	mov r1, 128

	cmp r0, VAL
	or_eq r1, r1, 255

	cmp r0, VAL
	and_ne r1, r1, 32

// r1 should have 255 -- pure white. If cmp immediates aren't working,
//	it will have gray (128), if they are incorrectly working it will
//	have dark gray (32)

	mov r10, 65535
Write_FB:	strb r1, r10, 0
	sub r10, r10, 1
	cmp r10, 256
	b_ne <Write_FB>


// Put reference colors in the first row: [Darkgray, Lightgray, 2x white]
	mov r27, 255
	mov r20, 255
Write_white: strb r20, r27, 0
	sub r27, r27, 1
	b_ne <Write_white>

	mov r27, 127
	mov r20, 128
Write_lightgray: strb r20, r27, 0
	sub r27, r27, 1
	b_ne <Write_lightgray>
	
	mov r27, 63
	mov r20, 32
Write_darkgray: strb r20, r27, 0
	sub r27, r27, 1
	b_ne <Write_darkgray>
	
	b <Main>


	halt
