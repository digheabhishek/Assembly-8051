/*SORT ARRAY IN DORDER*/
	 //Descending Array

ORG 00H
MOV R7,#06H
L2:MOV R0, #40H
MOV R6,#05H
L1:MOV A,@R0
INC R0
MOV 50H,@R0
CJNE A,50H,NEXT
SJMP DOWN
NEXT: JNC DOWN
MOV @R0,A
DEC R0
MOV @R0,50H
DOWN:DJNZ R6,L1
DJNZ R7,L2
END