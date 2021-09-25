;****************************************************************
;	F2.COM			��  ��������			*
;								*
;				F2 - 3CH 00H			*
;	�L�[�ύX����		NULL ��				*
;****************************************************************

INCLUDE	STD.H

INT_NO	EQU	15H				;����������x�N�^�[�ԍ�

MAS_KEY	EQU	3BH				;���͂��鷰�̑�������
RES_KEY	EQU	3CH				;�ύX���鑖������
						;3CH �� F2�L�[


	COMSEG

@S:	JMP	SET

OLD_OFF	DW	0
OLD_SEG	DW	0
SIN	DB	"KEY"				;�풓�����Ƃ��̊m�F����

ENT:
	PUSHF
	CMP	AH,4FH				;�@�\�ԍ� 4FH ���ް�޲�������
	JNZ	END_1
KEY1:
	CMP	AL,RES_KEY			;'F2'�̑����R�[�h
	JZ	J1
	MOV	BYTE PTR CS:STK_AL,AL		;�O��̑����R�[�h
J1:	
	CMP	AL,RES_KEY
	JNZ	END_1
	CMP	BYTE PTR CS:STK_AL,0E0H		;PRINT SCREEN �̉��
	JZ	END_1				;�������ނ� E0H 2AH E0H 37H 
						;�Ō��37H������̂őO���
						;�������ނ��݂Ĕ��肷�邽��
	
	MOV	AL,MAS_KEY			;00�̑����R�[�h
	POPF
	STC					;��ذ�׸ނ�ON�ɂ��čX�V
	JMP	DWORD PTR CS:OLD_OFF		;���̃A�h���X�ɃW�����v
END_1:	
	POPF
	JMP	DWORD PTR CS:OLD_OFF		;���̃A�h���X�ɃW�����v


STK_AL	DB	0				;�O��̑����R�[�h�̃G���A	

	STACK	128				;ܰ��ر
	EVEN

SIZE1	EQU	$


SET:
	MOV	AH,35H
	MOV	AL,INT_NO
	INT	21H
	MOV	OLD_OFF,BX
	MOV	OLD_SEG,ES

	SUB	BX,3
	MOV	DI,BX
	MOV	SI,OFFSET CHK
	MOV	CX,3
	REPZ	CMPSB
	JNE	INT_SET
	
	MOV	AH,09
	MOV	DX,OFFSET M0
	INT	21H
	
	MOV	BX,OLD_OFF
	MOV	ES,OLD_SEG
	MOV	DX,ES:[BX-7]
	MOV	DS,ES:[BX-5]
	MOV	AH,25H
	MOV	AL,INT_NO
	INT	21H
	
	MOV	ES,CS:OLD_SEG
	MOV	ES,WORD PTR ES:[002CH]
	MOV	AH,49H
	INT	21H
	MOV	ES,CS:OLD_SEG
	MOV	AH,49H
	INT	21H
	
	EXIT

INT_SET:
	MOV	AH,09H
	MOV	DX,OFFSET M1
	INT	21H
	
	MOV	DX,OFFSET ENT
	MOV	AH,25H
	MOV	AL,INT_NO
	INT	21H
	
	MOV	DX,OFFSET SIZE1
	MOV	CL,4
	SHR	DX,CL
	MOV	AX,3100H
	INT	21H
	
	EXIT
	
CHK	DB	"KEY",0
M0	DB	"F9  Ver 1.00 (C) CopyRight by Takeo   All Rights Reserved (C)"
	DB	CR,LF
	DB	"F9.COM  ������܂����B$"

M1	DB	"F9  Ver 1.00 (C) CopyRight by Takeo   All Rights Reserved (C)"
	DB	CR,LF
	DB	"F9.COM  �풓���܂����B$"
	
	SEGEND

	END	@S
