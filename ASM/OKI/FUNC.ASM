;********************************************************
;*	FUNCTION �o�^�Ղ�				*
;*	F1--F9   �܂őΉ�				*
;*	�g�p��						*
;*	A>FUNC ̧ݸ��ݔԍ� �o�^����			*
;*	A>FUNC 1 OBASIC					*
;*					By wolf    	*
;********************************************************


CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE,ES:CODE

	ORG	80H

PARA	DB	80H	DUP(0)			;DAT  �ر������

	ORG	100H

CR	=	0DH
LF	=	0AH


START:	MOV	AL,PARA				;DTA ���Ұ����
	CMP	AL,3				;���Ұ���� ����
 	JBE	E_MSG				;�g�p��\��

	MOV	AL,PARA[2]			;DTA�������Ұ�����
	CMP	AL,30H				;IF AL<1 THEN E_MSG
	JB	E_MSG
	CMP	AL,39H				;IF AL>9 THEN E_MSG
	JA	E_MSG
	CMP	AL,30H
	JNE	A
	ADD	AL,0AH

A:	DEC	AL				;F1=30H �̈� 31H-01H
	MOV	FUNC.FKEY,AL			;FUNC ��FUNCTION �ԍ����

	XOR	BX,BX				;BX������
CP:  	
	MOV	AL,PARA[BX+4]			;DTA ������ذ��
	CMP	AL,'/'				;�����̎w��L��??
	JE 	SWITCH
	MOV	FUNC.FPARA[BX],AL		;FUNC �ɕ������
	INC	BX				;BX����
	CMP	AL,0DH				;CR��������
	JE	F
	CMP	BX,0FH				;���͕���������
	JE	E_MSG
	JMP	CP

SWITCH:	
	MOV	AL,PARA[BX+5]
	CMP	AL,'C'
	JE	SW_NOT_0D
	CMP	AL,'c'
	JE	SW_NOT_0D
	MOV	AL,0DH
	JMP	SW_END

SW_NOT_0D:
	MOV	AL,20H

SW_END:	MOV	FUNC.FPARA[BX],AL		;FUNC �ɕ������
	INC	BX

F:	
	MOV	FUNC.FLEN,BL			;FUNC �ɕ������ݸ޽���

;  �h�m�s�@�W�O�g�@�t�@���N�V�����ݒ�  BIOS CALL

	MOV	CL,1CH
	MOV	AL,2
	MOV	DX,OFFSET FUNC
	INT	80H

END:	MOV	AH,4CH
	INT	21H

E_MSG:	MOV	AH,09H
	MOV	DX,OFFSET MSG
	INT	21H
	JMP	END

;-------------	FUNC 	�L�[�ԍ� 	1 BYTE
;			������ 		1 BYTE
;			����	       15 BYTE
;
	FUNCST	STRUC
		FKEY	DB	1 DUP(0)
		FLEN	DB	1 DUP(0)
		FPARA	DB     15 DUP(0)
	FUNCST	ENDS

FUNC	FUNCST	<,,>

MSG     DB	"���Ұ��̎w��Ɍ�肪�����",CR,LF
 	DB	CR,LF
	DB	"	�g�p��	F1�Ɂ@OBASIC ���Z�b�g����ꍇ",CR,LF
 	DB	CR,LF
	DB	"	A>FUNC 1 OBASIC",CR,LF
 	DB	CR,LF
 	DB	CR,LF
	DB	"�A��  �ݒ�ł���t�@���N�V�����́A�e�P�`�e�X �܂�",CR,LF
	DB	"      �������͂P�S�����܂�",CR,LF,"$"

CODE	ENDS
	END	START
