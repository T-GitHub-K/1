;****************************************
;*					*
;*	LOCATE PROC	���l��ėp	*
;*					*
;*	AH=���W�x	AL=���W�w	*
;*					*
;*	LIB	UTY.LIB	�o�^		*
;****************************************

INCLUDE	MDOS.H
INCLUDE	STD.H

CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE

PUBLIC	LOCATE

LOCATE	PROC	NEAR

	PUSHA

	MOV	DL,AH
	XOR	AH,AH
	XOR	DH,DH
	MOV	CL,2DH
	PUSH	ES
	INT	80H
	POP	ES

	POPA

	RET

LOCATE	ENDP
CODE	ENDS
	END
