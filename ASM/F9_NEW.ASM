;****************************************************************
;	F9_11_12.COM		��  ��������			*
;								*
;				F9 - 43H 00H			*
;				*  - 37H 00H			*
;	�L�[�ύX����						*
;****************************************************************

INCLUDE	STD.H

INT_NO	EQU	15H				;����������x�N�^�[�ԍ�

MAS_KEY		EQU	43H	;[F9]		���͂��鷰�̑�������
MAS_KEY1	EQU	85H	;[F11]	���͂��鷰�̑�������
MAS_KEY2	EQU	86H	;[F12]	���͂��鷰�̑�������

RES_KEY		EQU	37H	;�ύX���鑖������[*]
RES_KEY1	EQU	89H	;�ύX���鑖������[Ctrl]+[F11]
RES_KEY2	EQU	8AH	;�ύX���鑖������[Ctrl]+[F12]
				
				;43H �� F9�L�[
				;89H �� [Ctrl]+[F11]�L�[
				;8AH �� [Ctrl]+[F12]�L�[
				;37H �� '*'�L�[


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
	CMP	AL,RES_KEY			;'*'�̑����R�[�h
	JZ	J1
	MOV	BYTE PTR CS:STK_AL,AL		;�O��̑����R�[�h
J1:	
	CMP	BYTE PTR CS:STK_AL,0E0H		;PRINT SCREEN �̉��
	JZ	END_1				;�������ނ� E0H 2AH E0H 37H 
						;�Ō��37H������̂őO���
						;�������ނ��݂Ĕ��肷�邽��
	
	CMP	AL,RES_KEY
	JNZ	J2
	MOV	AL,MAS_KEY			;F9�̑����R�[�h
	JMP	 J4
J2:
	CMP	AL,RES_KEY1
	JNZ	J3
	MOV	AL,MAS_KEY1			;F11�̑����R�[�h
	JMP 	J4
J3:
	CMP	AL,RES_KEY2
	JNZ	END_1
	MOV	AL,MAS_KEY2			;F12�̑����R�[�h

J4:
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