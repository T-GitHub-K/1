;********************************************************
;*	COMMAND LINE ���͌^   	                	*
;*		                                    	*
;*		                                    	*
;*		                                    	*
;*	COLOR 						*
;*	�g�p��						*
;*	A>IBMCO   �װ,��گ�				*
;*	A>IBMCO   7,07					*
;*					            	*
;*	16�F�̶װ�ԍ���64�F����گĔԍ���Ă���    	*
;*	�װ       0-F		                   	*
;*	��گ�	  00-3F			           	*
;*		                                    	*
;*					By wolf    	*
;********************************************************
;INCLUDE	STD.H

CR	EQU	0DH
LF	EQU	0AH


CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE,ES:CODE

	ORG	80H
PARA	DB	80H	DUP(0)			;DAT  �ر������
	ORG	100H

START:	MOV	AL,PARA				;DTA ���Ұ����

DEF:	CMP	AL,8				;���Ұ���� ����  �ő�l
	JBE	DEF1
	JMP	E_MSG				;�g�p��\��

DEF1:	CMP	AL,4				;���Ұ���� ����  �ŏ��l
 	JAE	PALA_1
	JMP	E_MSG				;�g�p��\��

PALA_1:	MOV	AL,PARA[2]			;���p�����[�^�擾
						;(�װ�ԍ�)
	CMP	AL," "				;SPACE
	JE	PALA_E
	CMP	AL,","				;���
	JE	PALA_E
	CMP	AL,"/"				;�ׯ��
	JE	PALA_E
	JMP	SHORT PALA_1A

PALA_E:
	JMP	E_MSG				;�g�p��\��

PALA_1A:
	MOV	BX,1
	MOV	CX,0
PALA_1B:
	INC	BX
	MOV	AL,PARA[BX]
	CMP	AL," "				;SPACE
	JE	PALA_2
	CMP	AL,","				;���
	JE	PALA_2
	CMP	AL,"/"				;�ׯ��
	JE	PALA_2
	CMP	AL,0DH
	JE	PALA_E
	CMP	CX,1				;�擾���� ���Ұ���P��
	JA	PALA_1B
	PUSH	BX
	MOV	BX,CX
	MOV	PALA1[BX],AL
	INC	CX
	POP	BX
	JMP	SHORT	PALA_1B

PALA_2:
	MOV	CX,0
PALA_2A:
	INC	BX
	MOV	AL,PARA[BX]			;���p�����[�^�擾
						;(��گĔԍ�)
	CMP	AL," "				;SPACE
	JE	PALA_END
	CMP	AL,","				;���
	JE	PALA_END
	CMP	AL,"/"				;�ׯ��
	JE	PALA_END
	CMP	AL,0DH
	JE	PALA_END
	CMP	CX,2				;�擾���� ���Ұ���Q��
	JA	PALA_2A
	PUSH	BX
	MOV	BX,CX
	MOV	PALA2[BX],AL
	INC	CX
	POP	BX
	JMP	SHORT	PALA_2A

PALA_END:
PALA_SET1:					;������Ұ��
	MOV	BX,0
	MOV	AL,PALA1[BX]
	CMP	AL,30H				;��׸������ 0��菬����
	JB	PALA_E1
	CMP	AL,46H				;��׸������ F���傫��
	JA	PALA_E1
	CMP	AL,39H
	JA	PALA_ABC
	SUB	AL,30H
	MOV	P1,AL
	JMP	PALA_SET2

PALA_E1:
	JMP	E_MSG				;�g�p��\��

PALA_ABC:
	SUB	AL,37H
	MOV	P1,AL


PALA_SET2:					;������Ұ��
	MOV	BX,0
	MOV	AL,PALA2[BX]
	CMP	AL,30H				;��׸������ 0��菬����
	JB	PALA_E1
	CMP	AL,46H				;��׸������ F���傫��
	JA	PALA_E1
	CMP	AL,39H
	JA	PALA_ABC2
	SUB	AL,30H
	MOV	P2,AL
	JMP	SHORT PALA_SETA

PALA_ABC2:
	SUB	AL,37H
	MOV	P2,AL
PALA_SETA:
	MOV	CL,4
	SHL	AL,CL
	MOV	DL,AL

PALA_SET3:
						;������Ұ��
	MOV	BX,1
	MOV	AL,PALA2[BX]
	CMP	AL,30H				;��׸������ 0��菬����
	JB	PALA_E3
	CMP	AL,46H				;��׸������ F���傫��
	JA	PALA_E3
	CMP	AL,39H
	JA	PALA_ABC3
	SUB	AL,30H
	MOV	P2,AL
	JMP	SHORT PALA_SETB

PALA_E3:
	MOV	AL,P2
	JMP	RUN

PALA_ABC3:
	SUB	AL,37H
	MOV	P2,AL
PALA_SETB:
	OR	AL,DL
	MOV	P2,AL
RUN:
	MOV	AX,1000H
	MOV	BL,P1
	MOV	BH,P2
	INT	10H

END:	MOV	AH,4CH
	INT	21H

E_MSG:	MOV	AH,09H
	MOV	DX,OFFSET MSG
	INT	21H

	JMP	END

MSG     DB	"�p�����[�^�̎w��Ɍ�肪����܂�"
 	DB	CR,LF,CR,LF
	DB	"	�g�p��	�װ�ԍ��V����گĔԍ��R�V�̏ꍇ",CR,LF
 	DB	CR,LF
	DB	"       A>IBMCO �װ,��گ�",CR,LF,CR,LF
	DB	"       A>IBMCO 7 37     ",CR,LF,CR,LF
	DB	"         ",'$'


PALA1	DB	2	DUP(0)
PALA2	DB	2	DUP(0)

P1	DB	0		;�װڼ޽�
P2	DB	0		;��گ�ڼ޽�

STK	DB	100H	DUP(0)

CODE	ENDS
	END	START
