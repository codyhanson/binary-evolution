.region code
label_code: add r1,r2,r3
	B <label_isr>

.region ex
label_ex2:	or r1,r3,r20
label_ex: LDADR r4, <label_code>

.region isr
label_isr: B <label_ex>
label_isr2: bic r20, r4, 0x20
	  //LDADR R28, <0x20> 
	  //TO ADDRESS


