;************************************************
;*	Type 1/	Type 3 BIOS call subroutine	*
;*						*
;*	Usage	CALL BCALL(PAGE,SX,SY,BX,BY)    *
;*						*
;*		PAGE	���]�����y�[�W		*
;*		SX	���擪�w		*
;*		SY	���擪�x		*
;*		BX	���]�����w		*
;*		BY	���]�����x		*
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
	MOV	AX,[BX]		;�ݒ�PAGE
	MOV	PAGE0[OFSET],AX

	CMP	AX,1
	JZ	NEXT1
	MOV	AX,SOR_SCREEN	;�ޔ�PAGE
	MOV	PAGE1[OFSET],AX
	JMP	JUMP

NEXT1:	MOV	AX,DST_SCREEN
	MOV	PAGE1[OFSET],AX

JUMP:

	MOV	BX,[BP+10]	;�擪�w
	MOV	AX,[BX]
	MOV	S_X[OFSET],AX
	MOV	S_X1[OFSET],AX

	MOV	BX,[BP+8]	;�擪�x
	MOV	AX,[BX]
	MOV	S_Y[OFSET],AX
	MOV	S_Y1[OFSET],AX
	
	MOV	BX,[BP+6]	;�擪�u���b�N���w
	MOV	AX,[BX]
	MOV	B_X[OFSET],AX

	MOV	BX,[BP+4]	;�擪�u���b�N���x
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

			;�p�����[�^�[�e�[�u��
PAGE0	DW	?		;PAGE
S_X	DW	?		;�擪�w
S_Y	DW	?		;�擪�x
B_X	DW	?		;��ۯ��w
B_Y	DW	?		;��ۯ��x
PAGE1	DW	?		;�ި�èȰ���PAGE
S_X1	DW	?		;�ި�èȰ��ݐ擪�w
S_Y1	DW	?		;�ި�èȰ��ݐ擪�x


MAIN	ENDP

endp	equ	$
CODE	ENDS
	END
