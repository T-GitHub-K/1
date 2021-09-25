;****************************************
;*					*
;*	CUMODE PROC	ｶｰｿﾙﾓｰﾄﾞの設定	*
;*					*
;*	AH=ｽｲｯﾁ				*
;*					*
;*	0･･ｶｰｿﾙ無表示			*
;*	1･･ｶｰｿﾙ表示			*
;*	2･･ｶｰｿﾙ入力要求時表示	INT80	*
;*					*
;*	LIB	UTY.LIB	登録		*
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