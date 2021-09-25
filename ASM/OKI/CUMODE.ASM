;****************************************
;*					*
;*	CUMODE PROC	����Ӱ�ނ̐ݒ�	*
;*					*
;*	AH=����				*
;*					*
;*	0�����ٖ��\��			*
;*	1�����ٕ\��			*
;*	2�����ٓ��͗v�����\��	INT80	*
;*					*
;*	LIB	UTY.LIB	�o�^		*
;****************************************

INCLUDE	MDOS.H
INCLUDE	STD.H

CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE

PUBLIC	CUMODE

CUMODE	PROC	NEAR

	PUSHA

	MOV	DL,AH
	PUSH	ES
	MOV	CL,2AH
	INT 	80H
	POP	ES

	POPA

	RET

CUMODE	ENDP
CODE	ENDS
	END
