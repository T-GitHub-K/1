;****************************************************************
;	LPRN.ASM     						*
;								*
;								*
;****************************************************************

INCLUDE	STD.H

	COMSEG

@S:

	MOV	CX,42
L1:	
	MOV	AH,0
	MOV	AL,0DH
	MOV	DX,0
	INT	17H
	LOOP	L1

	MOV	AH,4CH
	INT	21H


	STACK	256

	SEGEND
	
	END	@S
