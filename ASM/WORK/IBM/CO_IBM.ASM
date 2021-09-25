;****************************************************************
;	CO_IBM     						*
;								*
;								*
;****************************************************************

INCLUDE	STD.H


CO_NO	EQU	71H

	COMSEG

@S:

	PUSHA
	PUSH	ES
	PUSH	DS
	
	MOV	AX,CS
	MOV	DS,AX
	
	MOV	AX,0B800H
	MOV	ES,AX
	XOR	DI,DI
	MOV	AH,0FEH
	INT	10H
	
	ADD	DI,144
	
	
	MOV	STK_ES,ES
	MOV	STK_DI,DI


	MOV	ES,STK_ES
	MOV	DI,STK_DI
	
	CLD
	MOV	SI,OFFSET H
	MOV	CX,16
	REP	MOVSB
	
	MOV	DI,STK_DI
	MOV	CX,8
	MOV	AH,0FFH
	INT	10H
	
END_T1:	
	POP	DS
	POP	ES
	POPA
	
	EXIT

H	DB	0,CO_NO,0,CO_NO,":",CO_NO
M	DB	0,CO_NO,0,CO_NO,":",CO_NO
S	DB	0,CO_NO,0,CO_NO

STK_ES	DW	0
STK_DI	DW	0

	SEGEND

	END	@S
	