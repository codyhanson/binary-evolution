
.EQU		MMR_MEM_INIT	4095	//0x00000FFF
.EQU		MMR_MEM_SHIFT	28		// to shift _INIT over to become MMR_MEM

.region code	

	MOV R14,	MMR_MEM_INIT
	MOV R27,	MMR_MEM_SHIFT
	MOV R14,	R14, R27 LSL		// R14 <- _INIT << _SHIFT

	mov r3, 5
	or r14, r14, r3    //0xFFF00005 is location of leds	
	
	
loop:	mov r4, 15          //active low, so initialize all to 1111
	str r4, r14, 0 

	mov r1, 65534
	mov r2, 0
mylabel: sub r1, r1, 1
	cmp r1, r2
	b_ne <mylabel>
	mov r4, 7
	str r4, r14, 0         //active low, so initialize all to 0111   

	mov r1, 65534
	mov r2, 0
mylabel2: sub r1, r1, 1
	cmp r1, r2
	b_ne <mylabel2>
	mov r4, 3
	str r4, r14 , 0       //active low, so initialize all to 0011  

	mov r1, 65534
	mov r2, 0
mylabel3: sub r1, r1, 1
	cmp r1, r2
	b_ne <mylabel3>
	mov r4, 1           //active low, so initialize all to 0001  
	str r4, r14, 0 

	mov r1, 65534
	mov r2, 0
mylabel4: sub r1, r1, 1
	cmp r1, r2
	b_ne <mylabel4>
	mov r4, 0           //active low, so initialize all to 0000  
	str r4, r14, 0 

	b <loop>

	
	

	
	



	


	
	halt
