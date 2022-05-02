;DYNA-PIO-LCD-8 bit MODE LCD routines with check busy flag before sending data, command to LCD        
;*************************************************************
LCD     DATA     P2          ;define LCD data port on port 2
BUSY    BIT      LCD.7       ;define LCD busy flag
E       BIT      P1.0        ;define LCD enable pin on port 1.0
RS      BIT      P1.2        ;define LCD register select pin on port 1.2
RW      BIT      P1.1        ;define LCD read/write pin on port 1.1
;*************************************************************
        ORG      00H

LCD_INIT:
        MOV      A,#38H                ;2 line 5x7
        ACALL    COMMAND    
        MOV      A,#0CH                ;LCD on cursor on
        ACALL    COMMAND
        MOV      A,#01H                ;clear LCD
        ACALL    COMMAND
        MOV      A,#06H                ;shift cursor right
        ACALL    COMMAND
DISPLAY:MOV      A,#81H
        ACALL    COMMAND
        MOV      DPTR,#TEST
        ACALL    DISP_STRING
        MOV      A,#0C1H
        ACALL    COMMAND
        MOV      DPTR,#TEST+0EH
        ACALL    DISP_STRING
HERE:   SJMP     HERE        
;=============================================================
COMMAND:
        ACALL    READY                 ;is LCD ready?
        MOV      LCD,A                 ;issue command code
        CLR      RS                    ;RS=0 for command
        CLR      RW                    ;R/W=0 to write to LCD|
        SETB     E                     ;E=1 for H-to-L pulse
        CLR      E                     ;E=0 ,latch in
        RET
;=============================================================
DATA_DISPLAY:
        ACALL    READY                 ;is LCD ready?
        MOV      LCD,A                 ;issue data
        SETB     RS                    ;RS=1 for data
        CLR      RW                    ;R/W=0 to write to LCD
        SETB     E                     ;E=1 for H-to-L pulse
        CLR      E                     ;E=0 ,latch in
        RET
;=============================================================
READY:
        SETB     BUSY                  ;make P1.7 input port
        CLR      RS                    ;RS=0 access command reg
        SETB     RW                    ;R/W=1 read command reg
;read command reg and check busy flag
BACK:
        CLR      E                     ;E=1 for H-to-L pulse
        SETB     E                     ;E=0 H-to-l pulse
        JB       BUSY,BACK             ;stay until busy flag=0
        RET
;=============================================================
DISP_STRING:
    CLR      A                     ;A=0
	MOV      R7,#00H               ;R7=0
NEXT_CHAR:
	INC      R7		       ;R7+1
	MOVC     A,@A+DPTR
	ACALL    DATA_DISPLAY
	MOV      A,R7
	CJNE     R7,#0EH,NEXT_CHAR
	RET        
;=============================================================
TEST:   DB       "DYNA-PIO-LCD ","   8BIT-MODE   "     
        END