//connection detail:
//		Connect Port0 of Dyna-EB to PIO Keypad
//		Connect Port2(i.e Port3 in Dyna-EB) to J1 of PIO LCD
//					

lcd_port	equ	P2

	ORG 	0000H 
	LJMP 	MAIN 

	 
 LCD_RESET: ;RESET & initialize LCD in 4-bit mode 
	ANL 	lcd_port,#0FH	;HIGHER NIBLE =0, CONTROL PINS UNCHANGED
	ACALL 	DELAYL		;20mS DELAY
	ACALL 	DELAYL
	ACALL 	DELAYL
	ACALL 	DELAYL
	MOV 	lcd_port,#31h ;FIRST BYTEDATA=30h ,ENABLE=1
	MOV 	lcd_port,#30h ;DATA=30h ,ENABLE=0
	ACALL 	DELAYL		; 15mS DELAY
    ACALL 	DELAYL
	ACALL	DELAYL
	MOV 	lcd_port,#31h ;SECOND BYTE DATA=30h ,ENABLE=1
	MOV 	lcd_port,#30h ;DATA=30h ,ENABLE=0
	ACALL 	DELAYL		; 5mS DELAY
	MOV 	lcd_port,#31h ;THIRD BYTE DATA=30h ,ENABLE=1
	MOV 	lcd_port,#30h ;DATA=30h ,ENABLE=0
	ACALL 	DELAYL		; 5mS DELAY
	MOV 	lcd_port,#21h ;4-BIT MODE DATA=20h ,ENABLE=1
	MOV 	lcd_port,#20h ;DATA=20h ,ENABLE=0
	ACALL 	DELAYL		; 5mS DELAY
	RET
LCD_INIT:

	ACALL	LCD_RESET
	MOV	A,#28H	;4-BIT MODE, 2LINE, 5X7 DOTS
	ACALL	LCD_CMD
	MOV     A,#0cH	; DISPLAY=ON,,CUSOR BLINKING
	ACALL	LCD_CMD
	MOV	A,#06H	;AUTO INCREMENT
	ACALL	LCD_CMD
	MOV	A,#80H	; CURSOR TO LINE 1
	ACALL	LCD_CMD
	RET

LCD_CMD:
	;SEND HIGHER NIBBLE
	MOV	R0,A
	CALL	OUTCMD
	; SEND LOWER NIBBLE
	MOV	A,R0
	SWAP	A ; SWAP LOWER NIBBLE TO HIGHER NIBBLE
	CALL	OUTCMD
	ACALL	DELAYL
	RET
OUTCMD:
	ANL	A,#0F0H  ; MASK LOWER NIBBLE
	ORL	A,#01H	; ENABLE=1,RS=0 CMD REG
	MOV lcd_port,A
	ANL	A,#0F0H	; ENABLE=0,RS=0 CMD REG 
	MOV	LCD_PORT,A
	RET

 LCD_STRING:
	MOV 	lcd_port,#00H 
	MOV 	A,#00H
	MOV 	R1,#00H
 NC: ;checks the end of message string
	MOVC	A,@A+DPTR
	CJNE 	A,#2FH,NC1
	RET
 NC1:
	LCALL 	LCD_WRITE
	INC 	R1
	MOV 	A,R1 
	AJMP 	NC 

 LCD_WRITE:

	;SEND HIGHER NIBBLE
	MOV	R0,A
	CALL	OUTDAT
	; SEND LOWER NIBBLE
	MOV	A,R0
	SWAP	A ; SWAP LOWER NIBBLE TO HIGHER NIBBLE
	CALL	OUTDAT
	ACALL	DELAYL
	RET
OUTDAT:
	ANL	A,#0F0H  ; MASK LOWER NIBBLE
	ORL	A,#05H	; ENABLE=1,RS=1 DATA REG
	MOV LCD_PORT,A
	ANL	A,#0F4H	; ENABLE=0,RS=1 DATA REG
	MOV	LCD_PORT,A
	RET
		
 NEXT_LINE:
	MOV 	LCD_PORT,#00H
	MOV 	A,#0C0H
	ACALL 	LCD_CMD
	RET 

 LCD_CLEAR: 
	;This Subroutine is used to clear LCD
	MOV 	LCD_PORT,#00H
	MOV 	A,#01H		;CLEAR DISPLAY
	ACALL 	LCD_CMD
	RET 

 
 DELAYL: ; 5ms DELAY
	SETB 	PSW.4 ; SELECT BANK 2
	MOV 	R7,#25
 HDH:
	MOV 	R6,#60
	DJNZ 	R6,$
	DJNZ 	R7,HDH 
	CLR 	PSW.4 ;DEFAULT BANK 
	RET

 LOOP: ;1 SEC DELAY
	MOV 	R7,#100
 LOOP1:
	CALL 	DELAYL
	CALL 	DELAYL
	DJNZ 	R7,LOOP1
	RET

;----keyboard scan--------

;keyboard format: 0 4 8 C
;                 1 5 9 D
;                 2 6 A E
;                 3 7 B F
;*************************************************
;Declarations
CL0 equ  P0.0;
CL1 equ  P0.1;
CL2 equ  P0.2;
CL3 equ  P0.3;
RW0 equ  P0.4;
RW1 equ  P0.5;
RW2 equ  P0.6;
RW3 equ  P0.7;
;*************************************************

;Subroutine to scan keys
 scan_key:
		mov     P0,#0ffh 	;Configure input
      	clr cl0
      	mov  a,p0
      	anl a,#11110000b
      	cjne a,#11110000b,Row0
     	setb cl0
		CALL dly
		CALL dly
		call dly
     	clr cl1
     	mov  a,p0
      	anl a,#11110000b
      	cjne a,#11110000b,Row1
     	setb cl1
		CALL dly
		CALL dly
		call dly
		clr cl2
      	mov  a,p0
      	anl a,#11110000b
      	cjne a,#11110000b,Row2
      	setb cl2
		CALL dly
		CALL dly
		call dly
      	clr cl3
      	mov  a,p0
      	anl a,#11110000b
      	cjne a,#11110000b,Row3
     	setb cl3
		CALL dly
		CALL dly
		call dly
		ret

row0: 
		mov 	dptr,#key_data
     	mov 	r6,#04h
      	clr 	c
		swap	a
rww0: 	rrc 	a
      	jc 		next0
      	jmp 	over
next0:
		inc 	dptr
      	djnz 	r6,rww0
      	jmp 	scan_key

row1: 	mov 	dptr,#key_data+4h
      	mov 	r6,#04h
      	clr 	c
		swap	a
rww1: 	rrc 	a
      	jc 	next1
      	jmp 	over
next1:
		inc 	dptr
      	djnz 	r6,rww1
      	sjmp 	scan_key

row2: 	mov 	dptr,#key_data+8h
      	mov 	r6,#04h
      	clr 	c
		swap	a
rww2: 	rrc 	a
      	jc 	next2
      	sjmp 	over
next2:	
		inc 	dptr
      	djnz 	r6,rww2
      	jmp 	scan_key

row3: 	mov 	dptr,#key_data+0ch
      	mov 	r6,#04h
      	clr 	c
		swap	a
rww3: 	rrc 	a
      	jc 	next3
      	sjmp 	over
next3:	inc 	dptr
      	djnz 	r6,rww3
      	jmp 	scan_key

dly:
		mov	r3,#0ffH
dly1:   djnz	r3, dly1
		RET

over:  
		mov r5,#01h	 ;flag for key pressed
		ret

;*************************************************
;Display subroutine
display:
		cjne r5,#00h,data_disp ; if key pressed then display data
		mov a,#' '	 ;else display blank
		ret
data_disp:
	 	clr a
     	movc a,@a+dptr
     	ret
  
;*************************************************
;lookup table
	key_data:
	 db "0","1","2","3"; For row1:0 1 2 3
     db "4","5","6","7"; For row2:4 5 6 7
     db "8","9","A","B"; For row3:8 9 A B
     db "C","D","E","F"; For row4:C D E F

;DATA TO BE DISPLAYED

;Maximum message length = 16 characters.

;DISPLAY DATA TABLE IN ASCII FORMAT

	
	MSG1:		
	DB	"PIO-4X4 KEYPAD/"; /= END OF STRING
  	
	MSG2:	
	DB	"KEY PRESSED = /";/= END OF STRING

;*************************************************

;**************main program starts here ***********
MAIN:
	CALL 	LCD_INIT ;Initialize lcd
	CALL	LCD_CLEAR
	MOV 	DPTR,#MSG1
	CALL 	LCD_STRING ;Display message on LCD
	CALL 	NEXT_LINE ;Place cursor to;second Line
	MOV 	DPTR,#MSG2 
	CALL 	LCD_STRING ;Display message on LCD
	mov     P0,#0ffh 	;Configure input
	mov		r5,#00h	  	; clr flag for no key pressed
KEY_SCAN:		      
    call    scan_key     ;Scan for keypress
    call    display      ;display the key pressed
	CALL 	LCD_WRITE
	mov 	A,#10H		; move cursor position 
	call	lcd_cmd
	sjmp    key_scan    ;Loop
	end
  