// gol/bcd_to_bin.s
// Subroutine to convert r6 from a packed BCD into a 40-bit binary number
// ***NOTE -- The BCD number is limited to 4 digits

// The algorithm in C:
// unsigned int BCDtoI(unsigned int BCD) {
//    unsigned int result;
//    result=((BCD>>12)&0x0f)*1000;
//    result+=((BCD>>8)&0x0f)*100;
//    result+=((BCD>>4)&0x0f)*10;
//    result+=((BCD)&0x0f);
//    return result;
//}

.EQU	RET_BIT 	1024	// bit10

.region code

	b	<Start>	//DON'T START PROGRAM WITH SUBROUTINE

Bcd_to_bin:	mov r27, 65535	// 0xFFFF
	and r6, r6, r27			// Mask it down to 4-digits

//Digit3
	mov r27, 15				// Digit mask
	mov r26, 1000			// Multiplicand (aka number of times to loop)
	mov r25, 12				// Shift amount

	mov r24, r6, r25 LSR	// BCD >> 12
	and r24, r24, r27		// (" ") & 0x0f

	mov r23, 0					// Accum
Bcd_digit3:	add r23, r24, r23	// add r24 to itself 1000 times to immitate "*1000"
	sub r26, r26, 1
	b_ne <Bcd_digit3>			// If not 0, continue looping


//Digit2
	mov r26, 100			// Multiplicand (aka number of times to loop)
	mov r25, 8				// Shift amount

	mov r24, r6, r25 LSR	// BCD >> 8
	and r24, r24, r27		// (" ") & 0x0f

Bcd_digit2:	add r23, r24, r23	// add r24 to itself 100 times to immitate "*100"
	sub r26, r26, 1
	b_ne <Bcd_digit2>		// If not 0, continue looping


//Digit1
	mov r26, 10				// Multiplicand (aka number of times to loop)
	mov r25, 4				// Shift amount

	mov r24, r6, r25 LSR	// BCD >> 4
	and r24, r24, r27		// (" ") & 0x0f

Bcd_digit1:	add r23, r24, r23	// add r24 to itself 10 times to immitate "*10"
	sub r26, r26, 1
	b_ne <Bcd_digit1>		// If not 0, continue looping


//Digit0
	and r24, r6, r27		// (" ") & 0x0f
Bcd_digit0:	add r6, r24, r23	// += (BCD)&0x0f

// r6 has the converted value
	tst r19, RET_BIT
	b_eq	<Done_bcd_to_bin_0>	// Exit subroutine to GoL
	b		<Done_bcd_to_bin_1>	// Exit subroutine to image proc
