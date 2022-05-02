  ;This programme demonstrates to interface DYNA-PIO-LED-SW with Dyna-51EB
; Connect the LED_SWitch board on Port1 
; The Higher nibble of port1 is in input mode and Lower nibble is in output mode.
; The Push button (Select The jumper JP5,6,7,8) on LED-SWITCH borad is used as input source
; The LEDs on Lower nibble (Select the jumpers JP1,2,3,4) on LED switch board shows the status of above switches
   
	; BIT ASSIGNMENT FOR DYNA-PIO-LED-SW
	push_SW1		BIT		P1.4
	push_sw2		BIT		P1.5
	push_SW3		BIT		P1.6
	push_SW4		BIT	 	P1.7
	pushsw1_STS		BIT		P1.0
	pushsw2_STS		BIT		P1.1
	pushsw3_STS		BIT		P1.2
	pushsw4_STS		BIT		P1.3
	
		ORG 0100H
	  	
		MOV		P2,#0FFH
		MOV		P1,#0FFH
	START:
		MOV		C,push_sw1
		MOV		pushsw1_sts,C
		MOV		C,push_SW2
		MOV		pushsw2_sts,C
		MOV		C,push_SW3
		MOV		pushsw3_sts,C
		MOV		C,push_SW4
		MOV		pushSW4_sts,C
		jmp		start
		END