   ORG 0000H
		LJMP MAIN
		ORG 0030H
MAIN:		NOP
 		EN      EQU   P2.0
 		RS      EQU   P2.2
 		RW      EQU   P2.1                                         
		DAT    	EQU   P2
		SDA		EQU   P0.1
		SCL		EQU   P0.0
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
		lcall ascii_convert
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
MYDATA:		DB " PIO-I2CADDA  ",0
MYDAT2:		DB " ADC i/p= ",0
dispH:	
		MOV a,#48H  ;ascii for H
		LCALL DATAW
		LCALL SDELAY
		ret

;======================================================================

;I2C-ADDA conversion
;I2C I/O...
;=======================================================================
Bit_Delay:      
		nop
		nop
		RET
;
;Set SCL
Set_SCL:
		setb	SCL
		jnb	SCL,$
		ACALL	Bit_Delay
		RET
;
;Clear SCL
Clr_SCL:
		clr   	SCL
		ACALL	Bit_Delay
		RET
;
;Pulse SCL
Emit_Clock:     
		ACALL Set_SCL
		ACALL Clr_SCL
		RET
;
;Start Sequence
Start:          
		setb    SDA
		ACALL	Bit_Delay
		ACALL	Set_SCL    
		clr     SDA
		ACALL	Bit_Delay
		ACALL	Clr_SCL
		RET
;
;Stop Sequence
Stop:           
		clr     SDA
		ACALL	Bit_Delay
		ACALL	Set_SCL
		setb    SDA
		ACALL	Bit_Delay
		RET

;Transmit a byte over the I2C bus
;input: acc contains byte to transmit
;output: cy = 0 if sequence completes
;        cy = 1 if unable to transmit
;
Xmit_Byte:
		mov     r1,#8           ;8 bits to send
xb1:
		rlc     a
		mov     SDA,c           ;put bit on pin
		ACALL	Emit_Clock      ;emit clock pulse
		djnz    r1,xb1          ;loop until done

;setup to accept ACK from slave device          
		setb    SDA             ;release data pin
		ACALL	Bit_Delay
		acall	Set_SCL         ;SCL high
		ACALL	Bit_Delay
		jnb     SDA,xb2         ;jump if ACK seen
		acall	Clr_SCL         ;drop SCL
		setb    c               ;set error code
		ret
xb2:
		ACALL	Clr_SCL         ;drop SCL
		clr     c               ;set completion code
		ret

;Receive a byte over the I2C bus
;output: acc contains received byte
;        cy is dummied up with a 0
;
Rec_Byte:
		mov     r1,#8           ;8 bits to receive
rb1:
		acall	Set_SCL         ;SCL high
		mov     c,SDA           ;pick bit off of pin
		rlc     a               
		acall	Clr_SCL         ;SCL low
		djnz    r1,rb1          ;more bits to receive?
		clr     c               ;must complete ok
		ret                     
                   
;		***end of sub routines**********

;Transmit address and data register byte over I2C bus
;
;       
;output: cy = 0 if sequence completes
;        cy = 1 if unable to transmit
;
xd_fault:                               ;bus fault
		setb    c               ;set error code
		ret
Put_ADI2C_Reg:
		jnb     SCL,xd_fault
		jnb     SDA,xd_fault    ;jump if bus fault
		mov     a,#90H        ;setup slave address WR mode
		acall	Start           ;set start condition
		acall   Xmit_Byte       ;send slave address
		jc      xd2             ;jump on error
		mov     a,#00H          ;setup AD control Byte
		acall   Xmit_Byte       ;send register address
		

;set stop condition, return code is already in cy
xd2:
		acall	Stop           ;set stop condition
		ret

;       
;Transmit address and receive registered data byte over I2C bus
;
;output: cy = 0 if sequence completes
;        cy = 1 if unable to receive
;        r7 contains received byte if cy = 0
rd_fault:                               ;bus fault
		setb    c               ;set error code
		ret
Get_ADI2C_Byte:
		jnb     SCL,rd_fault
		jnb     SDA,rd_fault    ;jump if bus fault
		mov     a,#91H         ;setup slave address RD mode
		acall	Start           ;set start condition
		acall   Xmit_Byte       ;send slave address
		jc      rd3             ;jump on error
rd1:
		acall   Rec_Byte        ;go receive
		mov     b,a            ;store AD data byte

;sequence complete, return code is already in cy
rd2:
		setb    SDA             ;set SDA idle
		acall	Emit_Clock      ;emit clock pulse
rd3:
		acall	Stop            ;set stop condition
		ret
 	
 adconvert:
i2c:
	clr	c
	acall	Put_ADI2C_Reg
	jc	i2c
	acall	Get_ADI2C_Byte
	jc	i2c
	ret
;---------------------------------------------------------
; binary to ascii conversion		
;        
;*******************************************************************************
ascii_convert:	   	
		    mov	  r1,b	
            anl   a,#0f0h      ; a=xxxx0000    ; A && #f0h (get the high nibble)
            swap  a            ; a=0000xxxx    ; swap nibbles
            orl   a,#30h       ; a=0011xxxx    ; add #30h, if nibble is
           	mov   r2,a
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