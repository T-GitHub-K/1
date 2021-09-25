
INCLUDE	MDOS.H
INCLUDE	MACRO.H
INCLUDE	STD.H

L_ADD		EQU	0FD00H		;BLOAD address = DS:FD00
OFSET		EQU	L_ADD-7


PARA_OP	STRUC				;�X�^�b�N��n�e�[�u��
	BP_SV	DW	?		;BP�ޔ�
	R_ADD	DD	?		;RETURN	ADD
	S_FLG	DW	?		;�ð��FLG
	J_REC	DW	?		;�斱��REC
	NO_P	DW	?		;FILE No
PARA_OP	ENDS


CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,SS:CODE,ES:CODE

	DB	0FDH
	DW	0000H
	DW	L_ADD
	DW	endp - startp

	PUBLIC	MAIN

startp	EQU	$

MAIN	PROC	FAR

		PUSH	BP		;BP�X�^�b�N�ɑޔ�	
		MOV	BP,SP		;�X�^�b�N�|�C���gBP��MOVE
		PUSHA			;�S���W�X�^�ޔ�

;--------------------------�斱���q�d�b

		MOV	BX,[BP].J_REC	;�斱���q�d�b�A�h���X�擾
		MOV	AX,[BX]		;�斱���q�d�b�̒��g
		MOV	JADD_REC[OFSET],AX

;--------------------------�t�@�C���n���h��

		MOV	BX,[BP].NO_P	;�t�@�C���n���h���A�h���X�擾
		MOV	AX,[BX]		;�t�@�C���n���h���̒��g
		MOV	F1_NO[OFSET],AX

;--------------------------�t�@�C���|�C���^�̈ړ�  BUF_SIZE
REC_CHK:
		MOV	CX,JADD_REC[OFSET]	;JADD�̃��R�[�h�ԍ�
		OR	CX,CX			;REC=0������
		JNE	S_POINT			;IF REC=0 THEN GOTO EXIT
						;         ELSE GOTO S_POINT
		MOV	AX,ERR_REC_CHK			;�װ����
		JMP	EXIT

;------------------------------------------------------------------------
;
;		�����ݒ�	�ӂ�����̐擪�ɂۂ��񂽁[��������
;
;------------------------------------------------------------------------
		;MOVE_PTR	MACRO	HANDLE,HIGHT,LOW,METHOD

S_POINT:
							;�t�@�C���̐擪�ɃZ�b�g
		MOVE_PTR	F1_NO[OFSET],0,0,0	;MMAS.UD
		JC	S_ERR
		JMP	SHORT MOV_CHK

S_ERR:
		MOV	AX,ERR_S_POINT			;�װ����
		JMP	EXIT

;-----------------------------------------------�ۂ��񂽁[�ړ���������
MOV_CHK:
		MOV	CX,JADD_REC[OFSET]	;JADD�̃��R�[�h�ԍ�
		DEC	CX			;REC 1��
		OR	CX,CX			;IF CX=0 THEN GOTO WRITE_DATA
		JNE	MOV_POINT		;        ELSE  MOV_POINT
		JMP	WRITE_DATA		;�������ݏ�����

;-----------------------------------------------�ۂ��񂽁[�ړ� F1_BUF

MOV_POINT:
		MOV	AX,F1_BUF
		MUL	CX

		MOV	BX,F1_NO[OFSET]
		MOV	CX,DX
		MOV	DX,AX
		MOV	AL,1
		MOV	AH,42H
		INT	21H

		JC	MOV_ERR
		JMP	WRITE_DATA

MOV_ERR:
		MOV	AX,ERR_MOV_POINT		;�װ����
		JMP	EXIT

;--------------------------�t�@�C���ɏ�������

WRITE_DATA:
		MOV	CX,DAY_MAX
WRITE_LOOP:
		PUSH	CX
		MOV	AX,4000H
		MOV	DX,OFFSET F1.P1[OFSET]
		MOV	CX,F1_FIELD
		MOV	BX,F1_NO[OFSET]
		INT	21H
		POP	CX

		JC	WRITE_ERR
		CMP	AX,F1_FIELD
		JNE	WRITE_ERR
		LOOP	WRITE_LOOP
		XOR	AX,AX
		JMP	SHORT EXIT

WRITE_ERR:
		MOV	AX,ERR_S_WRITE
		JMP	SHORT EXIT


EXIT:
		MOV	BX,[BP].S_FLG	;�ð��FLG�A�h���X�擾
		MOV	[BX],AX		;�ð��FLG�Z�b�g   AX�ɾ��

		POPA			;�S���W�X�^���A
        	POP	BP		;BP���A
		RET	6		;�X�^�b�N����RETURN

;
;----------------------------------------------------------------------------
;		�G���[�R�[�h
;
;----------------------------------------------------------------------------

ERR_REC_CHK	EQU	99				;JADD��REC=0
ERR_REC_CHK1	EQU	98				;DAY_REC=0
ERR_S_POINT	EQU	97				;̧���߲����擪�ړ��װ
ERR_MOV_POINT	EQU	96				;̧���߲���JADD���ړ�
ERR_MOV1_POINT	EQU	95				;̧���߲���MMAS1���ړ�
ERR_S_READ	EQU	94				;̧��ذ��
ERR_S_WRITE	EQU	93				;̧��ײ�
ERR_MOV2_POINT	EQU	92				;̧���߲���NEXT�ړ�


;-----------------------------------------------------------------------------
;		����FIELD �ݒ�
;		���R�[�h�����O�X�ݒ�
;-----------------------------------------------------------------------------

F1_STR	STRUC
	P1	DD	0				;�c�Ǝ���
	P2	DW	0				;������
	P3	DW	0				;�\���
	P4	DW	0				;�S������
	P5	DW	0				;����َ���
	P6	DW	0				;���i��
	P7	DW	0				;�Ζ��敪
	P8	DW	0				;�Ζ�����
F1_STR	ENDS
F1	F1_STR		<0,0,0,0,0,0,0,0>		;������

F1_FIELD	EQU	SIZE F1
F1_BUF		EQU	F1_FIELD*366
F1_NO		DW	0				;�t�@�C���n���h��

JADD_REC	DW	0				;�斱��REC
DAY_REC		DW	0				;����
F1_POINT	DD	0				;�߲����ޔ�ر

DAY_MAX		EQU	366				;

MAIN	ENDP
endp	EQU	$

CODE		ENDS
		END
