   ORG	0000H

	jmp	main

;I2C I/O...
	
	SDA	 EQU     P0.1
	SCL	 EQU     P0.0
; 
;Macros...
;
;Bit Delay
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

                   
;		***end of sub routines**********



;DAC output
;Transmit address ,control and data byte over I2C bus  
;
;output: cy = 0 if sequence completes
;        cy = 1 if unable to transmit
;
xdb_fault:                              ;bus fault
		setb    c               ;set error code
		ret
Put_DAI2C_Byte:
		jnb     SCL,xdb_fault
		jnb     SDA,xdb_fault   ;jump if bus fault
		mov     a,#90H          ;setup slave address
		acall	Start           ;set start condition
		acall   Xmit_Byte       ;send slave address
		jc      xdb1            ;jump on error
		mov     a,#40H          ;setup DA mode data byte
		acall   Xmit_Byte       ;send data byte
		jc      xdb1            ;jump on error
		mov     a,r7			;dac data
		cpl a	   				;compliment acc
		mov p1,a				;output the complimented data on Port1
		mov a,r7
		acall	Xmit_Byte
		jc	xdb1
;set stop condition, return code is already in cy
xdb1:
		acall	Stop            ;set stop condition
		ret
	
Main:
	clr	c
	mov	r7,#00h
	acall	Put_DAI2C_Byte
	jc	main
next:	inc	r7
	acall	Put_DAI2C_Byte
	jc	main
	cjne	r7,#0ffH,next
	acall	Put_DAI2C_Byte
	jc	main
	mov	r7,#0ffH
	acall	Put_DAI2C_Byte
next1:	dec	r7
	acall	Put_DAI2C_Byte
	jc	main
	cjne	r7,#00H,next1
	jc	main
	jmp	main
    end






