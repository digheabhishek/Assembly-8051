ORG 0000H
		LJMP MAIN
		ORG 0030H
MAIN:		NOP
 		EN      EQU   P1.0
 		RS      EQU   P1.2
 		RW      EQU   P1.1                                         
		DAT    	EQU   P1
		clr		rw
		LCALL LCD_INT
		LCALL CLEAR
		LCALL LINE1
		MOV DPTR,#MYDATA
		LCALL LOOP
		LCALL LINE2
		MOV DPTR,#MYDAT2
		LCALL LOOP
				
again:		SJMP again

;=========================================================================
W_NIB:		PUSH  ACC           	;Save A for low nibble
		ORL   DAT,#0F0h    	;Bits 4..7 <- 1
		ORL   A,#0Fh        	;Don't affect bits 0-3
		ANL   DAT,A        	;High nibble to display
		SETB  EN 
		CLR   EN 
		POP   ACC           	;Prepare to send
		SWAP  A             	;...second nibble
		ORL   DAT,#0F0h    	; Bits 4...7 <- 1
		ORL   A,#0Fh       	; Don't affect bits 0...3
		ANL   DAT,A        	;Low nibble to display
		SETB  EN 
		CLR   EN 
		RET
;=========================================================================
LCD_INT:	CLR   RS
 		//CLR   RW
 		CLR   EN
 		SETB  EN
 		MOV   DAT,#028h
 		CLR   EN
 		LCALL SDELAY
 		MOV   A,#28h
		LCALL COM
 		MOV   A,#0Ch
		LCALL COM
 		MOV   A,#06h
 		LCALL COM
		LCALL CLEAR
		MOV A,#080H
		LCALL COM
 		RET
;=========================================================================
CLEAR:		CLR   RS
		MOV   A,#01h
 		LCALL COM
		RET

;=========================================================================
DATAW:		SETB  RS
//		CLR RW
		LCALL W_NIB
		LCALL LDELAY
		RET
;=========================================================================
SDELAY:       	MOV R6,#1    			
HERE2:          MOV R7,#255  			
HERE:           DJNZ R7,HERE
                DJNZ R6,HERE2
                RET
;=========================================================================
LDELAY:       	MOV R6,#100    			
HER2:          	MOV R7,#255  			
HER:          	DJNZ R7,HER
                DJNZ R6,HER2
                RET
;=========================================================================
COM:	CLR RS
 		CLR RW
		LCALL W_NIB
		LCALL SDELAY
		RET
;=========================================================================
LINE1:	MOV A,#80H
		LCALL COM
		RET
LINE2:	MOV A,#0C0H
		LCALL COM
		RET
LINE3:	MOV A,#0c9H
		LCALL COM
		RET

;=========================================================================
LOOP:	CLR A
		MOVC A,@A+DPTR
		JZ GO_B2
		LCALL DATAW
		LCALL SDELAY
		INC DPTR
		SJMP LOOP
GO_B2:	RET
;=========================================================================
MYDATA:		DB " DYNA-PIO-LCD ",0
MYDAT2:		DB " 4BIT MODE ",0

		END