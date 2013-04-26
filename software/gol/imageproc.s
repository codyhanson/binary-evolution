//image processing routines for the game of life suite
// COLOR: BBGGRRR_
.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.EQU	MMR_VGA			0
.EQU	MMR_LED			5	// 0x05
.EQU	MMR_IRQ_STATUS	15	// 0x0F
.EQU	MMR_IRQ_ENABLE	16	// 0x10
.EQU	MMR_KBD_DATA	18	// 0x12 (Endian confusion)
.EQU	KBD_BIT			2

.EQU	LOWER_A		97	// 0x61 avg filter
.EQU	LOWER_M		109	// 0x6D median filter
.EQU	LOWER_T		116	// 0x74 threshold
.EQU	LOWER_N		110	// 0x6E add noise
.EQU	LOWER_G		103	// 0x67 add g noise
.EQU	LOWER_R		114	// 0x72 reset to original image 
.EQU	LEFT_ARROW	18	// 0x12 set fb1
.EQU	RIGHT_ARROW	20	// 0x14 set fb2
.EQU	ENTER_KEY	13	// 0x0d
.EQU	ESC_KEY		27	// 0x1b

.EQU	NUM_ZERO	48	// 0x30
		// ONE-EIGHT are sequential between these two
.EQU	NUM_NINE	57	// 0x39 

.EQU	RET_BCD_BIT 		1024	// bit10

//REGISTER USAGE
// r1:		Keyboard input
// r2:		MMR base address
// r19:		Return register (each bit is a signal to subroutines about where to return to)
// r20:		Pixel addr in other FB -- used by proc_nbrhd.s
// r21:		Holds previous r0 during proc_1_generation.s
// r22-r27:	Temp reg's

.region code 
	b	<Start>		// start with Main_menu 

	// Initialize MMR address
Start_image_proc:	MOV R26,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R17,	R26, R27 LSL		// R17 <- _INIT << _SHIFT

	// Initialize myRepeatKeyCount to -1
	mov r6, -1

	// FB
	mov r5, 1	// FB2, bw mode
	strb r5, r17, MMR_VGA
	// enable kbd irq
	mov r27, KBD_BIT
	strb r27, r17, MMR_IRQ_ENABLE 

	//initialize FB with initial image
	mov r19, 0			// Signal to return here
	b <imageprocinit>

Img_Wait_kbd: ldrb r27, r17, MMR_IRQ_STATUS
	tst r27, KBD_BIT // is KBD_BIT set?
	b_eq <Img_Wait_kbd>
//__Wait_kbd

	// Clear IRQ status
	mov r27, KBD_BIT
	strb r27, r17, MMR_IRQ_STATUS

	ldrb r1, r17, MMR_KBD_DATA	// get the key

///////////////////////////////////////////////////////////////////////////////
// FIGURE OUT WHAT KEY WAS PRESSED. DO SOMETHING BASED ON THAT
///////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////
	// NUMBER CHECK MUST BE AT THE BEGINNING
	////////////////////////////////////////////
 mov r27, NUM_ZERO
	cmp r1, r27
	b_lt	<imgNot_a_number>

 mov r27, NUM_NINE
	cmp r1, r27
	b_gt	<imgNot_a_number>

////////////////////////////////////
// A NUMBER WAS ENTERED. PROCESS IT
////////////////////////////////////
	// Get the number that was input
	mov r27, 15			// 0x0F
	and r21, r1, r27	// bottom hex digit of number (0-9)

	// Check if the number was -1 (unset yet), if so, make it 1
	cmp r6, -1			// Was it set to -1?
	mov_eq r6, 0		// If so, set r6 to 0

	// Shift in the new digit
	mov r25, 4			// Shift amount
	mov r26, r6, r25 LSL	// r26 <- Previous number << 4

	// Add on the new number to the shifted old number
	add r6, r26, r21

	// Wait for next key
	b		<Img_Wait_kbd>

////////////////////////////////////
// DONE HANDLING NUMBER INPUT
////////////////////////////////////

imgNot_a_number: add r26, r26, 0	//noop

	////////////////////////////////////////////
	// REPEAT THE DESIRED COMMAND
	//				<myRepeatKeyCount> TIMES
	////////////////////////////////////////////

	// Check if the number was -1 (unset yet), if so, make it 1
	cmp r6, -1			// Was it set to -1?
	mov_eq r6, 1		// If so, set r6 to 1

	// Convert from BCD to binary
	mov r19, RET_BCD_BIT
	b	<Bcd_to_bin>
Done_bcd_to_bin_1: add r27, r27, 0 //noop

// Loop and repeat the entered command
imgRepeatKey_loop:	add r27, r27, 0	//noop

//ESC	==> Return to main menu
 mov r27, ESC_KEY
	cmp r1, r27
	b_eq	<Start>	// branch to subroutine that returns to main menu, in ross's code
 mov r27, RIGHT_ARROW
	cmp r1, r27
	mov_eq r5, 1	// FB2, bw mode
	cmp r1, r27
	strb_eq r5, r17, MMR_VGA
 mov r27, LEFT_ARROW
	cmp r1, r27
	mov_eq r5, 0	// FB1, bw mode
	cmp r1, r27
	strb_eq r5, r17, MMR_VGA
 mov r27, LOWER_A
	cmp r1, r27
	b_eq <average> //avg filter
 mov r27, LOWER_T
	//store the number pressed for use by the threshold function
	cmp r1, r27
	b_eq <threshold> //threshold function
 mov r27, LOWER_M
	cmp r1, r27
	b_eq <median> //median filter
 mov r27, LOWER_N
	cmp r1, r27
	b_eq <addnoise> //add noise to the image 
 mov r27, LOWER_G
	cmp r1, r27
	b_eq <addgnoise> //add gaussian noise to the image 
 mov r27, LOWER_R
	mov r19, 0
	cmp r1, r27
	b_eq <imageprocinit> //resets the image to the original

	mov r6, -1
	b <Img_Wait_kbd> //didn't press a valid key


//copy imageprocinit fb over to FB2
//REGISTER USAGE:
// r24:	0x0FFFF loop limit
// r25: loop count
// r22:	image proc base image
// r21:	FB2
imageprocinit: ldadr r24, <fbcountfull>
	      ldr r24,r24,0 
	// initialize this and that addr
	ldadr r21, <myFB2>
	ldadr r22, <imageprocbaseimage>	
	mov r25, 0			// initialize this addr to 0

imgCopy_loop:	ldrb r27, r22, 0	// get pixel from base
		strb r27, r21, 0	// Store into fb2

	// Increment the addresses
	add r25, r25, 1 //count++
	add r21, r21, 1
	add r22, r22, 1

	cmp r25, r24		// Done?
	b_ne	<imgCopy_loop>	// If not, continue looping
	//done copying FB over

	// Return based on r19
	mov r6, -1
	b	<Img_Wait_kbd> //return to input loop 
