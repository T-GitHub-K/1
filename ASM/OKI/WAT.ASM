;********************************************************
;*	WAIT 						*
;*	�g�p��						*
;*	A>WAT	���Đ�                          	*
;*	A>WAT	2000					*
;*					By wolf    	*
;********************************************************
INCLUDE	MACRO.H
INCLUDE	STD.H

MAX	EQU	3
MIN	EQU	2


CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE

	ORG	80H
PARA	DB	80H	DUP(0)			;DAT  �ر������
	ORG	100H



START:	MOV	AL,PARA				;DTA ���Ұ����

DEF:	CMP	AL,MAX				;���Ұ���� ���� �ő�
	JBE	DEF1
	JMP	E_MSG				;�g�p��\��

DEF1:	CMP	AL,MIN				;���Ұ���� ���� �ŏ�
 	JAE	DEF2
	JMP	E_MSG				;�g�p��\��
DEF2:
	XOR 	CX,CX
  	MOV	CL,PARA
	DEC	CX

A:	MOV	BX,CX
	MOV	AL,PARA[BX+1]			;���͐���  0<=PARA[n]<=9
	CMP	AL,30H
	JAE	A1
	JMP	E_MSG

A1:	CMP	AL,39H
	JBE	A2
	JMP	E_MSG
A2:
	SUB	AL,30H
	MOV	BX,10
	MUL	BX
	ADD	WATS,AL
	LOOP	A

	MOV	AL,WATS
C:	CALL	WAT
	DEC	AL
	JNE	C


END:	MOV	AH,4CH
	INT	21H



E_MSG:	MOV	AH,09H
	COLOR_M	0,2
	MOV	DX,OFFSET MSG
	INT	21H
	COLOR_M	7,0
	MOV	DX,OFFSET MSG1
	INT	21H
	COLOR_M	7,0

	JMP	END


WAT	PROC	NEAR
	MOV	CL,WATS
B:		MOV	BX,CX
		MOV	CL,WATS
B1:		MOV	AH,AH
		LOOP	B1
		MOV	CX,BX
	LOOP	B
	RET
WAT	ENDP


WATS	DB	1 DUP(0)

MSG     DB	"�p�����[�^�̎w��Ɍ�肪����܂�",'$'
MSG1 	DB	CR,LF,CR,LF
	DB	"	�g�p��	                           ",CR,LF
 	DB	CR,LF
	DB	"	  A>WAT ���Đ�                          ",CR,LF,CR,LF
	DB	"	  A>WAT 1-99",CR,LF,CR,LF
	DB	"         ",'$'

CODE	ENDS
	END	START
