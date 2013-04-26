// NUMBERS	- Number of times to repeat the next command (0 - infinite)
// ARROWS   - Move cursor
// SPACE    - Toggle cursor
// TAB      - Switch FB
// ^A    	- Accumbytes on current nbrhd, store result in LEDs
// ^D    	- Draw border on current FB
// ^N		- GoL rules on current nbrhd, store result in LEDs
// a-q		- Plot GoL obj (after clearing board)
// BACKSPACE	- Clear current FB to all gray
// ENTER	- Run 1 generation of GoL on the current FB, write to other FB
//

// COLOR: BBGGRRR_
.EQU	COLOR			63	// Yellow
.EQU	CURSOR_DEAD		15	// Red
.EQU	CURSOR_ALIVE	49	// Green

.EQU	PLOT_TEXT_CURSOR_ADDR	57605	// (5, 225)

.EQU	SPECIFIC_LINE	223	// Line that goes above the text

.EQU	TOP_LEFT_ADDR		257
.EQU	BOTTOM_RIGHT_ADDR 	57086

.EQU	CURSOR_INIT_ADDR	26222	// (110, 102)
.EQU	MAX_STICKY			500		// Max number of sticky pixels allowed

.EQU 	BOUNDARY_TOP	1
.EQU 	BOUNDARY_BOTTOM	222
.EQU 	BOUNDARY_LEFT	1
.EQU 	BOUNDARY_RIGHT	254
.EQU	BOUNDARY_MARGIN	2		// Amount to increment to get from right to left

//.EQU	MMR_MEM		4293918720	//0x00FFF00000
.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.EQU	MMR_VGA			0
.EQU	MMR_LED			5	// 0x05
.EQU	MMR_IRQ_STATUS	15	// 0x0F
.EQU	MMR_IRQ_ENABLE	16	// 0x10
.EQU	MMR_KBD_DATA	18	// 0x12 (Endian confusion)
.EQU	KBD_BIT			2
.EQU	MMR_DIPSWITCH	22	// 0x16

.EQU	UP_ARROW		17	// 0x11
.EQU	LEFT_ARROW		18	// 0x12
.EQU	DOWN_ARROW		19	// 0x13
.EQU	RIGHT_ARROW		20	// 0x14
.EQU	SPACE_BAR		32	// 0x20
.EQU	TAB_KEY			9	// 0x09
.EQU	UPPER_A			65	// 0x41
.EQU	UPPER_C			67	// 0x43
.EQU	UPPER_I			73	// 0x49
.EQU	UPPER_N			78	// 0x4e
.EQU	UPPER_P			80	// 0x50
.EQU	UPPER_R			82	// 0x52
.EQU	UPPER_S			83	// 0x53
.EQU	BACK_KEY		8	// 0x08
.EQU	EQUAL_KEY		61	// 0x3d
.EQU	ENTER_KEY		13	// 0x0d
.EQU	ESC_KEY			27	// 0x1b
.EQU	LOWER_A			97	// 0x61
.EQU	LOWER_Z			122	// 0x7a
.EQU	LESS_THAN		60	// 0x3c
.EQU	GREATER_THAN	62	// 0x3e
.EQU	SECRET_IMAGE	39	// 0x27  <'>
.EQU	SECRET_MAIN		34	// 0x22  <">

.EQU	NUM_ZERO	48	// 0x30
		// ONE-EIGHT are sequential between these two
.EQU	NUM_NINE	57	// 0x39

.EQU	RET_GOL_BIT			1		//bit0
.EQU	RET_SWITCH_BIT		2		//bit1
.EQU	RET_CLEAR_BIT		4		//bit2
.EQU	RET_DRAW_BIT		8		//bit3
.EQU	RET_COPY_BIT		16		//bit4
.EQU	RET_SET_BIT			32		//bit5
.EQU	RET_SET2_BIT		64		//bit6
.EQU	RET_COPY2_BIT		128		//bit7
.EQU	RET_PLOT_BIT		256		//bit8
.EQU	RET_BORDER_BIT		512		//bit9
.EQU	RET_BCD_BIT 		1024	// bit10
.EQU	RET_IMAGEINIT_BIT	2048	// bit11
.EQU	RET_MENU_BIT		4096	// bit12
.EQU	RET_PLOT2_BIT		8192	// bit13


//REGISTER USAGE
// r0:		Current cursor (address of pixel)
// r1:		Keyboard input
// r2:		Generation number
// r3:		Previous pixel address
// r4:		Value of previous pixel
// r5:		Current FB
// r6:		"myRepeatKeyCount" - Number of times to repeat a command
// r7-r9:	--
// r10:		MMR base address
// r11-r14:	--
// r15:		Summing mask
// r16-r18:	Temp
// r19:		Return register (each bit is a signal to subroutines about where to return to)
// r20:		Pixel addr in other FB -- used by proc_nbrhd.s
// r21:		Holds previous r0 during proc_1_generation.s
// r22-r27:	Temp reg's

.region code

	b	<Start>		// start with Main_menu


	// Initialize MMR address
Start_gol:	MOV R26,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R10,	R26, R27 LSL		// R10 <- _INIT << _SHIFT

	mov r5, 2		// FB1, COLOR
	strb r5, r10, 0	// Set FB to 1 and color mode

	b	<Setup_lut>
Done_setup_lut:	mov r24, COLOR		// Set the color to paint this FB
	mov r19, 0	// Signal to set_fb to return here

	b	<Set_fb>
Done_set_fb_0:		mov r24, SPECIFIC_LINE	// Location to place the specific line at
	mov r19, 0	// Signal to make_border to return here

	b	<Make_border>
Done_make_border_0:	mov r0, PLOT_TEXT_CURSOR_ADDR
	mov r1, 26	// GoL text "object"
	mov r19, RET_PLOT2_BIT

	b	<Plot_obj>
Done_plot_obj_3:	mov r0, CURSOR_INIT_ADDR	// Put cursor where we want to intialize the default GoL object
	mov r1, 0	// Default object
	mov r19, 0	// Signal to plot_obj to return here
	b	<Plot_obj>
Done_plot_obj_0: mov r19, RET_COPY_BIT

	b	<Copy_fb>
	// Initialize r15  -- Neighborhood summing mask (0x0101010101)
Done_copy_fb_1:		mov	r15, 257			// 0x0101
	mov r27, 16				// Shift size
	mov r15, r15, r27 LSL	// Left shift by 2 bytes
	mov r27, 8
	or	r15, r15, 257		// r15 now has 0x01010101
	mov r27, r15, r27 LSL	// Left shift by 2 bytes
	or	r15, r27, 1			// r15 now has 0x0101010101

	// Reset sticky pixels to 0
	ldadr r27, <numStickyPixels>
	mov r26, 0
	str r26, r27, 0		// Set numStickyPixels to 0

	// Initialize myRepeatKeyCount to -1
	mov r6, -1

	// FB
	mov r5, 2	// FB1, color mode
	strb r5, r10, MMR_VGA
	mov r5, 0	// get rid of extra color bit

	mov r27, 255
	strb r27, r10, MMR_LED	// start with all LED's on

	// enable kbd irq
	mov r27, KBD_BIT
	strb r27, r10, MMR_IRQ_ENABLE

	// initialize cursor's head
	mov r0, CURSOR_INIT_ADDR

	// initialize last pixel
	add r3, r0, 0	//address
	ldrb r4, r3, 0	//data

	// Store the cursor's head
	tst r4, 1	// get bottom bit
	mov_eq r25, CURSOR_DEAD		//is dead? => dark grey
	tst r4, 1	// get bottom bit
	mov_ne r25, CURSOR_ALIVE	//else => light grey
	strb r25, r0, 0

	// Initialize generation counter
	mov r2, 0

//DBG
 mov r17, 0

Main_loop: mov r25, 65535	// 0x0FFFF
	add r26, r25, 1			// 0x10000
	add r27, r25, r26		// 0x1FFFF
	and r0, r0, r27			// don't let the cursor get out of the FB's

//DBG
 mov r27, KBD_BIT

Wait_kbd:	ldrb r27, r10, MMR_IRQ_STATUS
	tst r27, KBD_BIT // is KBD_BIT set?
	b_eq <Wait_kbd>
//__Wait_kbd

	RETURN 2

	// Clear IRQ status
	mov r27, KBD_BIT
	strb r27, r10, MMR_IRQ_STATUS


//DBG - switch_fb, run 1 gen, clear this fb, move right, move down, toggle this bit, move left, __repeat
 and r27, r17, 3
 cmp r27, 0
 mov_eq r1, LOWER_A			// Gen 2
 cmp r27, 1
 mov_eq r1, NUM_ZERO		// Gen 3
 cmp r27, 2
 mov_eq r1, UPPER_S			// Gen 3
 add r17, r17, 1

	ldrb r1, r10, MMR_KBD_DATA	// get the key

	ldr r27, r10, MMR_DIPSWITCH
	not r27, r27
	and r27, r27, 255
	strb r27, r10, MMR_LED	// store the dipswitch status to the LEDs

///////////////////////////////////////////////////////////////////////////////
// FIGURE OUT WHAT KEY WAS PRESSED. DO SOMETHING BASED ON THAT
///////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////
	// NUMBER CHECK MUST BE AT THE BEGINNING
	////////////////////////////////////////////
 mov r27, NUM_ZERO
	cmp r1, r27
	b_lt	<Not_a_number>

 mov r27, NUM_NINE
	cmp r1, r27
	b_gt	<Not_a_number>

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
	b		<Wait_kbd>

////////////////////////////////////
// DONE HANDLING NUMBER INPUT
////////////////////////////////////

Not_a_number: add r26, r26, 0	//noop

	////////////////////////////////////////////
	// REPEAT THE DESIRED COMMAND
	//				<myRepeatKeyCount> TIMES
	////////////////////////////////////////////

	// Check if the number was -1 (unset yet), if so, make it 1
	cmp r6, -1			// Was it set to -1?
	mov_eq r6, 1		// If so, set r6 to 1

	// Convert from BCD to binary
	mov r19, 0
	b	<Bcd_to_bin>
Done_bcd_to_bin_0: add r27, r27, 0 //noop

// Loop and repeat the entered command
RepeatKey_loop:	add r27, r27, 0	//noop

 mov r27, UP_ARROW
	cmp r1, r27
	sub_eq r0, r0, 256	// if so, move up a row
	cmp r1, r27
	b_eq	<Move_cursor>

 mov r27, LEFT_ARROW
	cmp r1, r27
	sub_eq r0, r0, 1	// if so, move left a column
	cmp r1, r27
	b_eq	<Move_cursor>

 mov r27, DOWN_ARROW
	cmp r1, r27
	add_eq r0, r0, 256	// if so, move down a row
	cmp r1, r27
	b_eq	<Move_cursor>

 mov r27, RIGHT_ARROW
	cmp r1, r27
	add_eq r0, r0, 1	// if so, move right a row
	cmp r1, r27
	b_eq	<Move_cursor>

//SPACE	==> Toggle current pixel on/off
 mov r27, SPACE_BAR
	cmp r1, r27
	b_ne	<Not_space>	//skip ahead if not space
	and r25, r4, 1		//get bottom bit of previous value
	cmp r25, 1			// check bit0
	or_ne r4, r4, 1		// toggle off to on
	cmp r25, 1			// check bit0
	and_eq r4, r4, -2	// toggle on to off	(and with 2_11110)
	//r0 (current address) stays the same

	b	<Move_cursor>
Not_space:	add r27, r27, 0	//noop

//TAB	==> Switch FB
 mov r27, TAB_KEY
	mov r19, 0	// Signal to switch_fb.s to return to ui_main.s
	cmp r1, r27
	b_ne	<Not_tab>	// if not TAB_KEY, skip to next step in code
	b		<Switch_fb>	// branch to subroutine

	b <Move_cursor>
Not_tab:	add r27, r27, 0	//noop


//ESC	==> Return to main menu
 mov r27, ESC_KEY
	cmp r1, r27
	b_eq	<Start>	// branch to subroutine that returns to main menu


//'A'	==> Accumbytes on this nbrhd
 mov r27, UPPER_A
	cmp r1, r27
	b_ne <Not_a>		// If not the 'a' key, skip to the next step in code

	ldneighbor r25, r0, 0		// get this neighborhood
	and r25, r25, r15			// and it with summing mask (masks out all but
	and r26, r26, r15			// bit0 of each pixel
	accumbytes r24, r25, r26	// get the nbrhd sum
	strb r24, r10, MMR_LED		// write the value to the LEDs
	b <Move_cursor>
Not_a:		add r27, r27, 0	//noop


//'C'	==> Copy this FB to the other one
Upper_c:  mov r27, UPPER_C
	cmp r1, r27
	b_ne <Not_c>		// If not the 'c' key, skip to the next step in code

	strb r4, r0, 0		// Store the cursor with its previous value

	// Copy this FB to the other
	mov r19, 0			// Signal to return to ui_main.s
	b	<Copy_fb>
Done_copy_fb_0:	ldrb r4, r0, 0	// Restore the cursor

Not_c:		add r27, r27, 0	//noop


//'I'	==> Invert both FB's alive/dead value
 mov r27, UPPER_I
	cmp r1, r27
	b_eq	<Invert_board>
Done_invert_board:	add r27, r27, 0	//noop


//'R'	==> Soft reset of GoL
 mov r27, UPPER_R
	cmp r1, r27
	mov_eq r2, 0	// Tell main_menu.s to clear then go to Start_gol
	cmp r1, r27
	b_eq	<Soft_reset>
	

// '<'	==> Change to a "lower" color
 mov r27, LESS_THAN
	cmp r1, r27
	b_ne	<Not_less_than>

	// Sample the current color and decrement it
	mov r27, 0
	ldrb r24, r27, 0	// Sample
	sub r24, r24, 2		// Decrement
	tst r24, 254		// Check the top 7 bits. If 0, set to white
	mov_eq r24, 255
	mov r19, RET_SET_BIT2
	b	<Sneaky_set>	// Back door entrance to the "S" set_fb

Not_less_than:	add r27, r27, 0 //noop


// '>'	==> Change to a "higher" color
 mov r27, GREATER_THAN
	cmp r1, r27
	b_ne	<Not_greater_than>

	// Sample the current color and decrement it
	mov r27, 0
	ldrb r24, r27, 0	// Sample
	add r24, r24, 2		// Increment
	tst r24, 254		// Check the top 7 bits. If 0, set to next color
	mov_eq r24, 3
	mov r19, RET_SET_BIT2
	b	<Sneaky_set>	// Back door entrance to the "S" set_fb

Not_greater_than:	add r27, r27, 0 //noop


// <'>	==> Run the Game of Life on the image processing image
 mov r27, SECRET_IMAGE
	cmp r1, r27
	b_ne	<Not_secret_image>

	add r20, r0, 0	// Store cursor
	ldadr r22, <imageprocbaseimage>	
	add r22, r22, 1
	mov r0, TOP_LEFT_ADDR

	mov r27, 65535
	add r27, r27, 1
	add r24, r0, r27	// addr in FB2

Secret_set_img_loop: ldrb r23, r22, 0	// Get the image's pixel
	strb r23, r0, 0		// Store it in FB1
	strb r23, r24, 0	// Store it in FB2

	add r22, r22, 1
	add r0, r0, 1
	add r24, r24, 1

	and r27, r0, 255	// Get x-coord
	cmp r27, 255
	add_eq r0, r0, BOUNDARY_MARGIN
	cmp r27, 255
	add_eq r24, r24, BOUNDARY_MARGIN
	cmp r27, 255
	add_eq r22, r22, BOUNDARY_MARGIN

	cmp r0, BOTTOM_RIGHT_ADDR
	b_le	<Secret_set_img_loop>

	add r0, r20, 0	// Restore the cursor

Not_secret_image: add r27, r27, 0 //noop



// <">	==> Run the Game of Life on the main menu screens
 mov r27, SECRET_MAIN
	cmp r1, r27
	b_ne	<Not_secret_main>

	mov r19, RET_MENU_BIT		// Signal to return to here
	b	<Menu_setup>

Done_menu_setup_1:	b <Done_copy_fb_1>

Not_secret_main: add r27, r27, 0 //noop


//'S'	==> Set FB to a color
 mov r27, UPPER_S
	cmp r1, r27
	b_ne <Not_s>		// If not the 's' key, skip to the next step in code

	// Set the fb color to the user input. If less than 2, set to default
	mov r19, RET_SET_BIT2	// Signal to return to ui_main.s
	add r24, r6, 0			// Make the input the number that was entered


	// Set the FB to the given color
Sneaky_set:	mov r19, RET_SET_BIT2	// Signal to return to ui_main.s
	b	<Set_fb>
Done_set_fb_3:		add r27, r27, 0	//noop
	mov r19, RET_COPY_BIT2	// Signal to return to ui_main.s
	b	<Copy_fb>
Done_copy_fb_3:		add r27, r27, 0	//noop
	// Reset repeat counter and exit the repeat loop
	mov r6, -1
	b	<Main_loop>

Not_s:		add r27, r27, 0	//noop


//EQUAL SIGN ==> Clear current FB, but don't delete the pinned keys
 mov r27, EQUAL_KEY
	cmp r1, r27
	b_ne <Not_equal>	// If not EQUAL_KEY, skip to the next step in code

	mov r19, 0	// Signal to clear_board.s to return to ui_main.s
	b	<Delete_board>		//branch to subroutine

Not_equal:		add r27, r27, 0	//noop


//BACKSPACE	==> Clear current FB
 mov r27, BACK_KEY
	cmp r1, r27
	b_ne <Not_backspace>	// If not BACKSPACE, skip to the next step in code

	mov r19, 0	// Signal to clear_board.s to return to ui_main.s
	b	<Clear_board>		//branch to subroutine
Done_clear_board_0: 	add r27, r27, 0	//noop
//DBG -- keep this here for now
Done_clear_board_1: 	add r27, r27, 0	//noop

Not_backspace:		add r27, r27, 0	//noop


// 'a' - 'z'
 mov r27, LOWER_Z
	cmp	r1, r27
	b_gt	<Not_a_letter>	// Bad input. Skip to next code
 mov r27, LOWER_A
	cmp r1, r27
	b_lt	<Not_a_letter>	// Bad input. Skip to next code
	sub r1, r1, r27			// Get letter's index (0-16)
	mov r19, RET_PLOT_BIT	// Signal to plot_obj to return here
	b		<Plot_obj>

Done_plot_obj_1:	add r27, r27, 0	//noop
Not_a_letter:		add r27, r27, 0	//noop


//'N'	==> GoL rules on this nbrhd (write result to LED and other FB)
 mov r27, UPPER_N
	mov r19, 0	// Signal to proc_nbrhd.s to return to ui_main.s
	cmp r1, r27
	b_eq	<Process_this_nbrhd_0>	// If so, process this nbrhd with GoL  (just use nbrhd ops... it's one operation so who cares)


//'P'	==> Make this pixel "sticky"
 mov r27, UPPER_P
	cmp r1, r27
	b_ne	<Not_p>		// if not "P", skip this code

	mov r27, 65535
	and r24, r0, r27	// Get the cursor's index within a FB

	ldadr r27, <numStickyPixels>
	ldadr r26, <stickyPixels>
	ldr r25, r27, 0		// Get the number of sticky pixels
	cmp r25, MAX_STICKY	// Check if we're maxed out
	b_eq	<Not_p>

	// "Multiply" the number of sticky pixels by 2 since they each take up 2 bytes
	add r23, r25, r25	// *= 2

	add r26, r23, r26	// Get to the next open "sticky pixel" addr
	strh r24, r26, 0	// Store the current pixel addr there
	add r25, r25, 1		// Inc number of sticky pixels by one
	str r25, r27, 0		// Store the inc'ed value back

	// Set previous value to WHITE
	mov r4, 255
Not_p: add r27, r27, 0	//noop

//ENTER	==> Process 1 Generation of gol
 mov r27, ENTER_KEY
	cmp r1, r27
	b_ne	<Not_enter>	// If not, skip this code

	strb r4, r0, 0		// Replace the cursor with its previous value
	mov	r19, RET_GOL_BIT	// Signal to proc_nbrhd.s to return to proc_1_generation.s
	b	<Process_1_Gen>	// If so, process 1 GoL generation
Done_Process_1_Gen:		ldrb r4, r0, 0

	mov	r19, 0			// Signal to proc_nbrhd.s to return to proc_1_generation.s
	b		<Switch_fb>	// branch to subroutine

Not_enter: 	add r27, r27, 0	//noop



	////////////////////////////////////////////
	// END OF KEY-PRESS LOGIC. STORE CURSOR
	// AND SUBROUTINE RETURNS:
	////////////////////////////////////////////

Done_switch_fb_0:	add r27, r27, 0	//noop
Done_proc_nbrhd_0: 	add r27, r27, 0	//noop


Move_cursor:	add r27, r27, 0	// noop

////////////////////////////////
// DEAL WITH THE STICKY PIXELS
// r23 has "WHITE" to write each pinned pixel
// r24 has address of the current stuck pixel to write
// r25 has number of sticky pixels
// r26 has addr of sticky pixel addresses
// r27 has 0x10000 or 0x00000 and will get or'ed with each pixel addr
Set_sticky_pixels:	ldadr r27, <numStickyPixels>
	ldadr r26, <stickyPixels>
	ldr r25, r27, 0			// Get the number of sticky pixels
	cmp r25, 0
	b_eq	<Done_sticky_pixels>	// If there aren't any, skip this code

	mov r23, 255			// Make the pinned pixels WHITE
	mov r27, 65535			// 0x0FFFF
	add r27, r27, 1			// 0x10000
	tst r5, 1				// Which FB are we in?
	mov_eq r27, 0			// If we are in FB1, make r27 0x00000

Sticky_loop:	ldrh r24, r26, 0	// Get this sticky pixel's addr
	or r24, r24, r27		// Make sure it's in the next FB
	strb r23, r24, 0		// Set that pixel to WHITE

	add r26, r26, 2			// Go to next sticky pixel (add 2 b/c they each take up 2 bytes)
	sub r25, r25, 1			// Decrement "number of sticky pixels" to show we've processed a new one
	b_ne	<Sticky_loop>	// If not, loop
Done_sticky_pixels:	add r27, r27, 0	//noop
////////////////////////////////

	// Make sure the new cursor is in bounds
	mov r27, 8				// Shift amount
	mov r25, r0, r27 LSR	// Get the Y-coord
	mov r27, 255			// Lower byte mask
	and r25, r25, r27		// Mask off the FB bit if it was there
	and r26, r0, r27		// Get the X-coord

	// Check Y-coord
	mov r24, BOUNDARY_TOP
	mov r27, BOUNDARY_BOTTOM
	cmp r25, r24		// Compare Y-coord to TOP of board
	add_lt	r25, r27, 0	// If Y-coord is above boundary, wrap to bottom
	cmp r25, r27		// Compare Y-coord to BOTTOM of board
	add_gt	r25, r24, 0	// If below bottom, wrap to top

	// Check X-coord
	mov r24, BOUNDARY_RIGHT
	mov r27, BOUNDARY_LEFT
	cmp r26, r24
	add_gt	r26, r27, 0	// If X-coord is right of boundary, wrap to left
	cmp r26, r27
	add_lt	r26, r24, 0	// If left of boundary, wrap to right

	// Reassemble the cursor address
	mov r27, 8			// Shift amount
	mov r24, r25, r27 LSL
	add r0, r24, r26	// r0 has [Y][X]

	// Get the FB bit in the cursor addr
	mov r26, 65535		// r26 has 0x0FFFF
	add r27, r26, 1		// r27 has 0x10000
	cmp r5, 1			// In FB2?
	add_eq r0, r0, r27	// If so, add 0x10000


	//restore last pixel
	strb r4, r3, 0
	//set next last pixel
	add r3, r0, 0
	ldrb r4, r0, 0 	//pixel's current value

	// generate and store the new cursor
	and r27, r4, 1	// get bottom bit
	cmp r27, 0	
	mov_eq r24, CURSOR_DEAD
	cmp r27, 0
	mov_ne r24, CURSOR_ALIVE

	strb r24, r0, 0

	////////////////////////////////////////////
	// PROCESSED THE KEY.
	// DECIDE WHETHER TO BRANCH.
	////////////////////////////////////////////

	// If it was set to zero, loop forever:
	cmp r6, 0	
	b_ne	<Not_infinite_loop>

	// Check if a key was pressed. If not, continue looping
	ldrb r27, r10, MMR_IRQ_STATUS
	tst r27, KBD_BIT 				// is KBD_BIT set?
	b_eq	<RepeatKey_loop>		// if not, continue looping

	// Clear IRQ status
	mov r27, KBD_BIT
	strb r27, r10, MMR_IRQ_STATUS

	// Reset to -1
	mov r6, -1

	// Exit the infinite loop
	b <Main_loop>

	// Check if a key was pressed. If not, continue looping
Not_infinite_loop:	ldrb r27, r10, MMR_IRQ_STATUS
	tst r27, KBD_BIT 				// is KBD_BIT set?
	mov_ne r6, -1					// if so, reset repeat counter
	tst r27, KBD_BIT 				// is KBD_BIT set?
	b_ne	<Main_loop>				// if so, break out of loop

	// Otherwise it was a constant, so decrement it and check if we hit zero
	sub r6, r6, 1			// Decrement repeat counter
	b_ne	<RepeatKey_loop>

	////////////////////////////////////////////
	// FELL THROUGH. RESET COUNTER TO -1
	// 		AND WAIT FOR A NEW KEY
	////////////////////////////////////////////

	// Reset to -1
	mov r6, -1

	b <Main_loop>
