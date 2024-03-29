;************************************************
;*	Type 1/	Type 3 BIOS call subroutine	*
;*						*
;*	Usage	CALL BCALL(PAGE,SX,SY,BX,BY)    *
;*						*
;*		PAGE	¥¥]³y[W		*
;*		SX	¥¥æªw		*
;*		SY	¥¥æªx		*
;*		BX	¥¥]w		*
;*		BY	¥¥]x		*
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
	MOV	AX,[BX]		;ÝèPAGE
	MOV	PAGE0[OFSET],AX

	CMP	AX,1
	JZ	NEXT1
	MOV	AX,SOR_SCREEN	;ÞðPAGE
	MOV	PAGE1[OFSET],AX
	JMP	JUMP

NEXT1:	MOV	AX,DST_SCREEN
	MOV	PAGE1[OFSET],AX

JUMP:

	MOV	BX,[BP+10]	;æªw
	MOV	AX,[BX]
	MOV	S_X[OFSET],AX
	MOV	S_X1[OFSET],AX

	MOV	BX,[BP+8]	;æªx
	MOV	AX,[BX]
	MOV	S_Y[OFSET],AX
	MOV	S_Y1[OFSET],AX
	
	MOV	BX,[BP+6]	;æªubNw
	MOV	AX,[BX]
	MOV	B_X[OFSET],AX

	MOV	BX,[BP+4]	;æªubNx
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

			;p[^[e[u
PAGE0	DW	?		;PAGE
S_X	DW	?		;æªw
S_Y	DW	?		;æªx
B_X	DW	?		;ÌÞÛ¯¸w
B_Y	DW	?		;ÌÞÛ¯¸x
PAGE1	DW	?		;ÃÞ¨½Ã¨È°¼®ÝPAGE
S_X1	DW	?		;ÃÞ¨½Ã¨È°¼®Ýæªw
S_Y1	DW	?		;ÃÞ¨½Ã¨È°¼®Ýæªx


MAIN	ENDP

endp	equ	$
CODE	ENDS
	END
