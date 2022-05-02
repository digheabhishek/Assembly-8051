;This programme demonstre to interface DYNA-PIO-LED-SW AND DYNA-PIO-RELAY-BUZZER BOARD.
; Connect the LED_SWitch board on Port1 and RLY-BZR board on Port2
; The Higher nibble of port1 is in output mode and Lower nibble is in input mode.
; The Push button (Select The jumper JP5,6,7,8) on LED-SWITCH borad is used to enable Relay,led & Buzzer located on DYNA-PIO-buzzer board.
; The LEDs on Lower nibble (Select the jumpers JP1,2,3,4) on LED switch board shows the status of opto and digital inputs from PIO-opto-buzzer board.
   
	; BIT ASSIGNMENT FOR DYNA-PIO-LED-SW
	BUZR_SW		BIT		P1.4
	LED_SW		BIT		P1.5
	RLY_NO_SW	BIT		P1.6
	RLY_NC_SW	BIT	 	P1.7
	OPTO0_STS	BIT		P1.0
	OPTO1_STS	BIT		P1.1
	DIN0_STS	BIT		P1.2
	DIN1_STS	BIT		P1.3
	;BIT ASSIGNMENT FOR DYNA-PIO-OPTO-RLY-BZR
	BUZR_ON		BIT		P2.2
	LED_ON		BIT		P2.3
	RLY_NO_ON	BIT		P2.0
	RLY_NC_ON	BIT		P2.1
	OPTO0_IN	BIT		P2.6
	OPTO1_IN	BIT		P2.7
	DIN0		BIT		P2.4
	DIN1		BIT		P2.5
	
		ORG 0100H
	  	
		MOV		P2,#0FFH
		MOV		P1,#0FFH
	START:
		MOV		C,BUZR_SW
		MOV		BUZR_ON,C
		MOV		C,LED_SW
		MOV		LED_ON,C
		MOV		C,RLY_NO_SW
		MOV		RLY_NO_ON,C
		MOV		C,RLY_NC_SW
		MOV		RLY_NC_ON,C
		MOV		C,DIN0
		CPL		C
		MOV		DIN0_STS,C
		MOV		C,DIN1
		CPL		C
		MOV		DIN1_STS,C
		MOV		C,OPTO0_IN
		CPL		C
		MOV		OPTO0_STS,C
		MOV		C,OPTO1_IN
		CPL		C
		MOV		OPTO1_STS,C
		JMP		START
		END
			
			