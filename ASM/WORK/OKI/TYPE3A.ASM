;************************************************
;*	Type 1/	Type 3 BIOS call subroutine	*
;*						*
;*	Usage	CALL BCALL(PAGE,SX,SY,BX,BY)    *
;*						*
;*		PAGE	･･転送元ページ		*
;*		SX	･･先頭Ｘ		*
;*		SY	･･先頭Ｙ		*
;*		BX	･･転送数Ｘ		*
;*		BY	･･転送数Ｙ		*
;*						*
;************************************************

L_ADD	equ	0f000H		;BLOAD address = DS:F000
OFSET	equ	L_ADD-7

SOR_SCREEN	EQU	1
DST_SCREEN	EQU	2

.286c

CODE	SEGMENT
	DB	0FDH
	DW	0000H
	DW	L_ADD
	DW	endp - startp

	ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE
	PUBLIC	MAIN

startp	equ	$

MAIN	PROC	FAR

	MOV	BP,SP
	PUSHA
	PUSH	ES


	MOV	BX,[BP+12]	; PAGE
	MOV	AX,[BX]		;設定PAGE
	MOV	PAGE0[OFSET],AX

	CMP	AX,1
	JZ	NEXT1
	MOV	AX,SOR_SCREEN	;退避PAGE
	MOV	PAGE1[OFSET],AX
	JMP	JUMP

NEXT1:	MOV	AX,DST_SCREEN
	MOV	PAGE1[OFSET],AX

JUMP:

	MOV	BX,[BP+10]	;先頭Ｘ
	MOV	AX,[BX]
	MOV	S_X[OFSET],AX
	MOV	S_X1[OFSET],AX

	MOV	BX,[BP+8]	;先頭Ｙ
	MOV	AX,[BX]
	MOV	S_Y[OFSET],AX
	MOV	S_Y1[OFSET],AX
	
	MOV	BX,[BP+6]	;先頭ブロック数Ｘ
	MOV	AX,[BX]
	MOV	B_X[OFSET],AX

	MOV	BX,[BP+4]	;先頭ブロック数Ｙ
	MOV	AX,[BX]
	MOV	B_Y[OFSET],AX

	MOV	AX,0		;
	MOV	BX,0		;
	MOV	CX,0D4H		;BIOS CALL D4H
	MOV	DX,OFFSET PAGE0[OFSET]	;ADD

	INT	80H

	POP	ES
	POPA

	MOV	SP,BP
	RET	10

			;パラメーターテーブル
PAGE0	DW	?		;PAGE
S_X	DW	?		;先頭Ｘ
S_Y	DW	?		;先頭Ｙ
B_X	DW	?		;ﾌﾞﾛｯｸＸ
B_Y	DW	?		;ﾌﾞﾛｯｸＹ
PAGE1	DW	?		;ﾃﾞｨｽﾃｨﾈｰｼｮﾝPAGE
S_X1	DW	?		;ﾃﾞｨｽﾃｨﾈｰｼｮﾝ先頭Ｘ
S_Y1	DW	?		;ﾃﾞｨｽﾃｨﾈｰｼｮﾝ先頭Ｙ


MAIN	ENDP

endp	equ	$
CODE	ENDS
	END
