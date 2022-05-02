ORG 0000H
		LJMP MAIN
		ORG 0030H
MAIN:		NOP
 		EN      EQU   P2.0
 		RS      EQU   P2.2
// 		RW      EQU   P1.1                                         
		DAT    	EQU   P2
		LCALL LCD_INT
		LCALL CLEAR
		LCALL LINE1
		MOV DPTR,#MYDATA
		LCALL LOOP
		LCALL LINE2
		MOV DPTR,#MYDAT2
		LCALL LOOP
		 LCALL LINE5
		lcall dispH
again:	lcall adconvert
		LCALL LINE3
		lcall adisph
		LCALL LINE4
		lcall adispl
		
		SJMP again

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
// 		CLR   RW
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
LDELAY:       	MOV R6,#1    			
HER2:          	MOV R7,#255  			
HER:          	DJNZ R7,HER
                DJNZ R6,HER2
                RET
;=========================================================================
COM:	CLR RS
//		CLR RW
		LCALL W_NIB
		LCALL SDELAY
		RET
;=========================================================================
LINE1:		MOV A,#80H
		LCALL COM
		RET
LINE2:	MOV A,#0C0H
		LCALL COM
		RET
LINE3:	MOV A,#0c9H
		LCALL COM
		RET
LINE4: 	MOV A,#0cah
		LCALL com	
		RET
LINE5: 	MOV A,#0cbh
		LCALL com	
		RET
;=========================================================================
LOOP:	CLR A
		MOVC A,@A+DPTR
		JZ GO_B2
		LCALL DATAW
		LCALL SDELAY
		INC DPTR
		SJMP LOOP
GO_B2:		RET

ADisph:	
		MOV a,r3
		LCALL DATAW
		LCALL SDELAY
		ret
ADispl:	
		MOV a,r4
		LCALL DATAW
		LCALL SDELAY
		ret

;=========================================================================
MYDATA:		DB " PIO-ADC-01  ",0
MYDAT2:		DB " ADC i/p= ",0
dispH:	
		MOV a,#48H  ;ascii for H
		LCALL DATAW
		LCALL SDELAY
		ret

;======================================================================
adconvert:
;----------------------------------------------------------
START	EQU	P1.0		; Pin 6 Start
EOC		EQU	P1.3		; Pin 7 EOC
OE		EQU	P1.1		; Pin 9 Output Enable
ALE		EQU	P1.2 		; Pin 22 ALE
adata	EQU	P0			; Data Lines

;----------------------------------------------------------
   	; Read one byte of data from adc.
	; Performs a analog conversion cycle.
	; address of channel in register "ADDRESS",
	; Returns data in BUFFER
	; Destroys A.
		MOV 	adata,#0FFH		; Data lines for input
		SETB 	OE		; Disable output
	 	SETB ALE		; Latch the address
		NOP
		nop
		nop
		NOP
		SETB START		; Start the conversion
		NOP
		NOP
		NOP
		CLR START
		NOP
		NOP
	EOCLOOP:	
		JNB EOC, EOCLOOP	; Do until EOC high
		CLR OE		; Output Enable
		MOV a,adata	; Get data in buffer
		SETB OE
		CLR ALE
									  
;---------------------------------------------------------
; binary to ascii conversion		
;        
;*******************************************************************************
		    mov	  R1,a	
            anl   a,#0f0h      ; a=xxxx0000    ; A && #f0h (get the high nibble)
            swap  a            ; a=0000xxxx    ; swap nibbles
            orl   a,#30h       ; a=0011xxxx    ; add #30h, if nibble is
           	mov r2,a
		    mov b, #3ah        ; stores #3ah in B
		    div ab             ; divide A/#3ah
            jz recupera1      ; if zero, nibble < #0Ah
nibble1_ok:
            mov a,r2
            add a, #07h        ; adds #07h to get ASCII of A-F
           	mov  r3,a
            jmp nibble2
		   
  recupera1:
            mov a,r2
			mov r3,a
	nibble2:
			mov	  a,r1	
            anl   a,#0fh        ; a=0000xxxx    ; A && #0fh (get low nibble)
            orl   a,#30h        ; a=0011xxxx    ; add #30h, if nibble is
           	mov   r2,a			; store acc. at Reg.R2
		    mov b, #3ah         ; stores #3ah in B
            div ab            ; divide A/#3ah
            jz  recupera2        ; if zero, nibble < #0Ah
            mov a,r2
            add a, #07h        ; adds #07h to get ASCII of A-F
            mov  r4,a
            ret                ; return to main routine
     recupera2:
            mov	a,r2
			mov r4,a	
            ret                ; return to main routine
			end