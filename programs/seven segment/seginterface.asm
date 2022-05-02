

;SEVEN SEGMENT 8-DIGIT COMMON ANODE DISPLAY 
                   	
	CPU	"8051.TBL"	;Processor declaration
	HOF	"INT8"		;Intel 8-bit hexcode

	ZERO: 	EQU 3fH
	ONE:	EQU 06H
	TWO:	EQU 5bH
	THREE:  EQU 4fH
	FOUR:	EQU 66H
	FIVE:	EQU 6dH
	SIX:	EQU 7dH
	SEVEN:	EQU 07H
	EIGHT:	EQU 7fH
	NINE:	EQU 0e7H
	;DOT:	EQU 7FH
	adata:	equ 77h
	bdata:  equ 7ch
	cdata:	equ 39h
	ddata:  equ 5eh
	edata:	equ 79h
	fdata:	equ 71h
	seg_port: equ 0a0h  ; port p2
	digit_port: equ 90h ; port p1
	
	ORG 0000H
	
		MOV seg_port,#00H
		mov digit_port,#0ffh
		mov a,#0feh
		
LOOP:		mov digit_port,a
		MOV seg_port,#ZERO
		CALL DELAYS
		MOV seg_port,#ONE
		CALL DELAYS

		MOV seg_port,#TWO
		CALL DELAYS

		MOV seg_port,#THREE
		CALL DELAYS

		MOV seg_port,#FOUR
		CALL DELAYS

		MOV seg_port,#FIVE
		CALL DELAYS

		MOV seg_port,#SIX
		CALL DELAYS

		MOV seg_port,#SEVEN
		CALL DELAYS

		MOV seg_port,#EIGHT
		CALL DELAYS

		MOV seg_port,#NINE
   		CALL DELAYS

   		;MOV seg_port,#DOT
   		;CALL DELAYS

		MOV seg_port,#adata
   		CALL DELAYS

		MOV seg_port,#bdata
   		CALL DELAYS

		MOV seg_port,#cdata
   		CALL DELAYS

		MOV seg_port,#ddata
   		CALL DELAYS

		MOV seg_port,#edata
   		CALL DELAYS

		MOV seg_port,#fdata
   		CALL DELAYS

		rl  a	
   		AJMP loop
   	
DELAYS:	       	 
		MOV R5,#2 ;200ms delay
	D1:
		CALL DELAY
		DJNZ R5,D1
		RET
				
	DELAY:          ;100ms DELAY
		MOV R7,#200
	D2:								
		MOV R6,#100
	D3:	
		NOP
		NOP
		NOP
		DJNZ R6,D3
		DJNZ R7,D2	
		RET
END

