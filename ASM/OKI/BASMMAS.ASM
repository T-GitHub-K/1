;-----------------------------------------------------------------------------
;   OBASIC CALL  ������ ٰ��
;
;   ̧�ف@�W�v հè�è�
;
;   CALL MMAS(̧��No1,̧��No2,�斱��REC,�J�n���t,�W�v����,
;					�����Ƃ�FLG,�޲ԓ����z��,�ð��FLG)
;
;	̧��No1		MMAS.UD
;	̧��No2		MMASN.UD
;       �斱��REC       �斱��ں��ޔԍ�
;	�J�n���t	�W�v����ŏ����t(1/1����J�n������t�܂ł̓������)
;	�W�v����	�����������
;	�����Ƃ�FLG	���N�̏����Ƃ����
;	�޲ԓ����z��	�޲Ԃ̓�����z��ž��
;	�ð��FLG	�װ����
;
;
;�ð��FLG
;		99	ERR_REC_CHK	JADD��REC=0
;		98	ERR_REC_CHK1	DAY_REC=0
;		97	ERR_S_POINT	̧���߲����擪�ړ��װ
;		96	ERR_MOV_POINT	̧���߲���JADD���ړ�
;		95	ERR_MOV1_POINT	̧���߲���MMAS1���ړ�
;		94	ERR_S_READ	̧��ذ��
;		93	ERR_S_WRITE	̧��ײ�
;		92	ERR_MOV2_POINT	̧���߲���NEXT�ړ�
;
; BASIC BLOAD ADD
;              BLOAD &HF200  �ɌŒ� 
;
;
;-----------------------------------------------------------------------------

INCLUDE	MDOS.H
INCLUDE	MACRO.H
INCLUDE	STD.H

L_ADD		EQU	0F200H		;BLOAD address = DS:F200
OFSET		EQU	L_ADD-7


PARA_OP	STRUC				;�X�^�b�N��n�e�[�u��
	BP_SV	DW	?		;BP�ޔ�
	R_ADD	DD	?		;RETURN	ADD
	S_FLG	DW	?		;�ð��FLG
	D_DAY	DW	?		;�޲ԓ����z��(99�)
	U_DAY	DW	?		;�����NFLG
	C_DAY	DW	?		;���Đ�
	D_REC	DW	?		;���t
	J_REC	DW	?		;�斱��REC
	F_NO1	DW	?		;̧��NO1(MMASN.UD)
	F_NO	DW	?		;̧��NO(MMAS.UD)
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

;--------------------------�޲ԓ����z����ڽ

		MOV	BX,[BP].D_DAY	;�޲ԓ����z��A�h���X�擾
		MOV	D_ADD[OFSET],BX	;
		MOV	SI,BX		;
;-----------------------------------------------------------------------
		CLD
		MOV	CX,D_TBL_SIZE
		MOV	DI,OFFSET D_TBL[OFSET]
		REP	MOVSB

;--------------------------�����NFLG

		MOV	BX,[BP].U_DAY	;�����N�A�h���X�擾
		MOV	AX,[BX]		;�����N�̒��g
		MOV	DAY_U[OFSET],AL
		MOV	DAY_MAX[OFSET],365
		CMP	DAY_U[OFSET],1
		JNE	NEXT_1
		INC	DAY_MAX[OFSET]

NEXT_1:
;--------------------------�J�E���g

		MOV	BX,[BP].C_DAY	;�J�E���g�A�h���X�擾
		MOV	AX,[BX]		;�J�E���g�̒��g
		MOV	DAY_COUNT[OFSET],AX

;--------------------------�����q�d�b

		MOV	BX,[BP].D_REC	;�����q�d�b�A�h���X�擾
		MOV	AX,[BX]		;�����q�d�b�̒��g
		MOV	DAY_REC[OFSET],AX
		MOV	DAY_REC_C[OFSET],AX

;--------------------------�斱���q�d�b

		MOV	BX,[BP].J_REC	;�斱���q�d�b�A�h���X�擾
		MOV	AX,[BX]		;�斱���q�d�b�̒��g
		MOV	JADD_REC[OFSET],AX

;--------------------------�t�@�C���n���h���P(MMASN.UD)

		MOV	BX,[BP].F_NO1	;�t�@�C���n���h���A�h���X�擾
		MOV	AX,[BX]		;�t�@�C���n���h���̒��g
		MOV	FILE_NO1[OFSET],AX

;--------------------------�t�@�C���n���h���O(MMAS.UD)

		MOV	BX,[BP].F_NO	;�t�@�C���n���h���A�h���X�擾
		MOV	AX,[BX]		;�t�@�C���n���h���̒��g
		MOV	FILE_NO[OFSET],AX

;------------------------------------------------------------------------
REC_CHK:
		MOV	CX,JADD_REC[OFSET]	;JADD�̃��R�[�h�ԍ�
		OR	CX,CX			;REC=0������
		JNE	REC_CHK1		;IF REC=0 THEN AX=99:GOTO EXIT
						;          ELSE GOTO REC_CHK1
		MOV	AX,ERR_REC_CHK			;�װ����
		JMP	EXIT

REC_CHK1:
		MOV	CX,DAY_REC[OFSET]	;���t���R�[�h�ԍ�
		OR	CX,CX			;REC=0������
		JNE	S_POINT			;IF REC=0 THEN AX=99:GOTO EXIT
						;          ELSE GOTO S_POINT
		MOV	AX,ERR_REC_CHK1		;�װ����
		JMP	EXIT

;------------------------------------------------------------------------
;
;		�����ݒ�	�ӂ�����̐擪�ɂۂ��񂽁[��������
;
;------------------------------------------------------------------------
		;MOVE_PTR	MACRO	HANDLE,HIGHT,LOW,METHOD

S_POINT:
							;�t�@�C���̐擪�ɃZ�b�g
		MOVE_PTR	FILE_NO[OFSET],0,0,0	;MMAS.UD
		JC	S_ERR
							;�t�@�C���̐擪�ɃZ�b�g
		MOVE_PTR	FILE_NO1[OFSET],0,0,0	;MMASN.UD
		JC	S_ERR
		JMP	SHORT MOV_CHK

S_ERR:
		MOV	AX,ERR_S_POINT			;�װ����
		JMP	EXIT


;-----------------------------------------------�ۂ��񂽁[�ړ���������

MOV_CHK:
		MOV	CX,JADD_REC[OFSET]	;JADD�̃��R�[�h�ԍ�
		DEC	CX			;REC 1��
		OR	CX,CX			;IF CX=0 THEN GOTO MOV1_CHK
		JNE	MOV_POINT		;        ELSE  MOV_POINT
		JMP	MOV1_CHK		;S_MMAS�̏�����

;-----------------------------------------------�ۂ��񂽁[�ړ� BUF_SIZE

MOV_POINT:
		PUSH	CX
		MOV	AX,BUF_SIZE
		MUL	CX

		MOV	BX,FILE_NO[OFSET]
		MOV	CX,DX
		MOV	DX,AX
		MOV	AL,1
		MOV	AH,42H
		INT	21H
		POP	CX

		JC	MOV_ERR

		MOV	AX,BUF1_SIZE
		MUL	CX

		MOV	BX,FILE_NO1[OFSET]
		MOV	CX,DX
		MOV	DX,AX
		MOV	AL,1
		MOV	AH,42H
		INT	21H
		
		JC	MOV_ERR

		MOV	WORD PTR F_POINT[OFSET],DX	;�t�@�C���̃|�C���^�[
		MOV	WORD PTR F_POINT[OFSET+2],AX	;

		JMP	MOV1_CHK

MOV_ERR:
		MOV	AX,ERR_MOV_POINT		;�װ����
		JMP	EXIT

;-----------------------------------------------MMASN.UD �̈ړ�
;-----------------------------------------------�ۂ��񂽁[�ړ���������

MOV1_CHK:
		MOV	CX,DAY_REC[OFSET]	;DAY�̃��R�[�h�ԍ�
		DEC	CX			;REC 1��
		OR	CX,CX			;IF CX=0 THEN GOTO S_READ
		JNE	MOV1_POINT		;        ELSE  MOV1_POINT
		JMP	S_READ			;S_READ�̏�����

;-----------------------------------------------�ۂ��񂽁[�ړ� MMAS1_SIZE

MOV1_POINT:

		MOV	AX,MMAS1_SIZE
		MUL	CX

		MOV	BX,FILE_NO1[OFSET]
		MOV	CX,DX
		MOV	DX,AX
		MOV	AL,1
		MOV	AH,42H
		INT	21H
		
		JC	MOV1_ERR

		JMP	S_READ

MOV1_ERR:
		MOV	AX,ERR_MOV1_POINT	;�װ����
		JMP	EXIT

;--------------------------------------------------�t�@�C������ǂݍ���
S_READ:
		READ_HANDLE	FILE_NO[OFSET],MMAS.M_EIS[OFSET],MMAS_SIZE
		JC	READ_ERR

		CMP	AX,MMAS_SIZE
		JZ	S_KINTAI

READ_ERR:
		MOV	AX,ERR_S_READ		;�װ����
		JMP	EXIT

;-----------------------------------------------------�Αӌv�Z

S_KINTAI:
	MOV	K_KTJ[OFSET],0				;�S�����ԏ�����
	MOV	AX,MMAS.M_SJ[OFSET]			;�J�n����
	OR	AX,AX
	JZ	S_KINTAI1

	XOR	DX,DX
	MOV	BX,100					;���� to ���ɕϊ�
	DIV	BX
	MOV	CX,DX
	MOV	BX,60
	MUL	BX
	ADD	AX,CX

S_KINTAI1:
;-----------------------------------------------------�Αӌv�Z�@�S������
	MOV	K_SM[OFSET],AX

	MOV	AX,MMAS.M_EJ[OFSET]			;�I������
	OR	AX,AX
	JZ	S_KINTAI2
	XOR	DX,DX
	MOV	BX,100					;���� to ���ɕϊ�
	DIV	BX
	MOV	CX,DX
	MOV	BX,60
	MUL	BX
	ADD	AX,CX

	CMP	AX,K_SM[OFSET]				;�J�n���Ԃ��I�����Ԃ��
	JB	S_KINTAI2				;�傫���ꍇ�̃`�F�b�N

	SUB	AX,K_SM[OFSET]				;�I���|�J�n
	OR	AX,AX
	JZ	S_KINTAI2
	XOR	DX,DX
	MOV	BX,60					;���������ɕϊ�
	DIV	BX
	MOV	CX,DX
	MOV	BX,100
	MUL	BX
	ADD	AX,CX
	MOV	K_KTJ[OFSET],AX

;-----------------------------------------------------�Αӌv�Z�@���i��

S_KINTAI2:
	MOV	K_KKK[OFSET],0			;���i�񐔏�����
	MOV	AX,MMAS.M_KKK[OFSET]		;�����ް������ް���擾������
	XCHG	AH,AL
	CMP	AH,30H				;������'0'���ǂ���
	JAE	S_KINTAI3			;IF AH=>'0' THEN S_KINTAI3
	MOV	AH,30H				;	    ELSE AH='0'
	
S_KINTAI3:
	CMP	AL,30H				;IF AL=>'0' THEN S_KINTAI4
	JAE	S_KINTAI4			;	    ELSE AL='0'
	MOV	AL,30H

S_KINTAI4:
	CMP	AH,39H				;IF AH<='9' THEN S_KINTAI5
	JBE	S_KINTAI5			;	    ELSE AH='0'
	MOV	AH,30H

S_KINTAI5:
	CMP	AL,39H				;IF AL<='9' THEN S_KINTAI6
	JBE	S_KINTAI6			;	    ELSE AL='0'
	MOV	AL,30H

S_KINTAI6:
	SUB	AH,30H				;AH�𕶎����琔�l�ɕϊ�
	SUB	AL,30H				;AL�𕶎����琔�l�ɕϊ�
	AAD
	MOV	K_KKK[OFSET],AX

;--------------------------------------------------�Ζ������e�[�u��GET

S_KINTAI7:
	XOR	AX,AX
	XOR	BX,BX
	MOV	AL,MMAS.M_DO1[OFSET]		;�����ް������޲Ԕԍ��擾
	ADD	BX,AX				;ð��ٔz��Y������
	ADD	BX,AX				;WORD TYPE
	MOV	AX,D_TBL_DMY[OFSET][BX]		;
	MOV	D_DAYC[OFSET],AX

;--------------------------------------------------�r�d�s�@�c�`�s�`
SET_D:

;--------------------------�c�Ǝ���

		MOV	AX,WORD	PTR MMAS.M_EIS[OFSET]		;�c�Ǝ�������
		MOV	WORD PTR MMAS1.M1_EIS[OFSET],AX
		MOV	AX,WORD PTR MMAS.M_EIS[OFSET+2]		;�c�Ǝ������
		MOV	WORD PTR MMAS1.M1_EIS[OFSET+2],AX

;--------------------------������

		MOV	AX,MMAS.M_MSN[OFSET]			;������
		MOV	MMAS1.M1_MSN[OFSET],AX

;--------------------------�\���

		XOR	AX,AX
		MOV	AL,MMAS.M_YYK[OFSET]			;�\���
		MOV	MMAS1.M1_YYK[OFSET],AX

;--------------------------�S������

		MOV	AX,K_KTJ[OFSET]				;�S������
		MOV	MMAS1.M1_KTM[OFSET],AX

;--------------------------�n���h������

		MOV	AX,MMAS.M_HTM[OFSET]			;����َ���
		MOV	MMAS1.M1_HTM[OFSET],AX

;--------------------------���i��

		MOV	AX,K_KKK[OFSET]				;���i��
		MOV	MMAS1.M1_KKK[OFSET],AX

;--------------------------�Ζ��敪

		XOR	AX,AX
		MOV	AL,MMAS.M_KBN[OFSET]			;�Ζ��敪
		MOV	MMAS1.M1_KBN[OFSET],AX

;--------------------------�Ζ�����

		MOV	AX,D_DAYC[OFSET]			;�Ζ�����
		MOV	MMAS1.M1_DAY[OFSET],AX

;----------------------------------------------�t�@�C���ɏ�������

S_WRITE:
		WRITE_HANDLE	FILE_NO1[OFSET],MMAS1.M1_EIS[OFSET],MMAS1_SIZE

		JC	WRITE_ERR
		CMP	AX,MMAS1_SIZE
		JZ	REP_DATA

WRITE_ERR:
		MOV	AX,ERR_S_WRITE			;�װ����
		JMP	SHORT EXIT

;---------------------------------------------------------------------------

REP_DATA:
		MOV	AX,0
		DEC	DAY_COUNT[OFSET]
		JNE	MOV2_POINT
		JMP	EXIT

MOV2_POINT:

;		MOVE_PTR	FILE_NO[OFSET],0,MMAS_SIZE,1	;MMAS.UD
;		JC	MOV2_ERR
;-----------------------------------------------------------------------
		INC	DAY_REC_C[OFSET]
		MOV	AX,DAY_REC_C[OFSET]
		CMP	DAY_MAX[OFSET],AX
		JAE	MOV2_POINT1
							;MMASN.UD
		MOV	BX,FILE_NO1[OFSET]
		MOV	CX,WORD PTR F_POINT[OFSET]
		MOV	DX,WORD PTR F_POINT[OFSET+2]
		MOV	AL,0
		MOV	AH,42H
		INT	21H

		JC	MOV2_ERR
		MOV	DAY_REC_C[OFSET],1
		JMP	MOV2_POINT_EXIT

MOV2_POINT1:

;		MOVE_PTR	FILE_NO1[OFSET],0,MMAS1_SIZE,1	;MMASN.UD
;		JC	MOV2_ERR

MOV2_POINT_EXIT:

		JMP	S_READ

MOV2_ERR:
		MOV	AX,ERR_MOV2_POINT
		JMP	EXIT
;--------------------------------------------------------------------------

EXIT:
		MOV	BX,[BP].S_FLG	;�ð��FLG�A�h���X�擾
		MOV	[BX],AX		;�ð��FLG�Z�b�g   AX�ɾ��

		POPA			;�S���W�X�^���A
        	POP	BP		;BP���A
		RET	16		;�X�^�b�N����RETURN


;--------------------------------------------------------------------------
;		����FIELD �ݒ�
;		���R�[�h�����O�X�ݒ�  MMASN.UD
;--------------------------------------------------------------------------

MMAS1_FIELD	STRUC
	M1_EIS	DD	0				;�c�Ǝ���
	M1_MSN	DW	0				;������
	M1_YYK	DW	0				;�\���
	M1_KTM	DW	0				;�S������
	M1_HTM	DW	0				;����َ���
	M1_KKK	DW	0				;���i��
	M1_KBN	DW	0				;�Ζ��敪
	M1_DAY	DW	0				;�Ζ�����
MMAS1_FIELD	ENDS
MMAS1	MMAS1_FIELD	<,,,,,,>			;������

MMAS1_SIZE	EQU	SIZE MMAS1
BUF1_SIZE	EQU	MMAS1_SIZE*366
FILE_NO1	DW	0				;�t�@�C���n���h��

;--------------------------------------------------------------------------
;		����FIELD �ݒ�
;		���R�[�h�����O�X�ݒ�  MMAS.UD OR MMAS2.UD
;--------------------------------------------------------------------------

MMAS_FIELD	STRUC
	M_EIS	DD	0				;�c�Ǝ���	   4
	M_DC0	DB	0				;�޲Ժ��ދΖ��\    1
	M_K1	DB	0				;�Ζ��敪          1
	M_DO1	DB	0				;�޲Ժ��ގ��_�C��  1
	M_KBN	DB	0				;���Ζ��敪        1
	M_SJ	DW	0				;���J�n����        2
	M_EJ	DW	0				;���I������        2
	M_CS	DW	0				;�������莞��      2
	M_CZ	DW	0				;�����c�Ǝ���      2
	M_CC	DW	0				;�����[�鎞��      2
	M_KB	DB	0				;�ΑӋ敪          1
	M_HTM	DW	0				;����َ���         2
	M_MSN	DW	0				;������          2
	M_KKK1	DW	0				;���i�� DMY    2  
	M_KKK2	DW	0				;���i�� DMY    2
	M_KKK	DW	0				;���i��        2 6
	M_YYK	DB	0				;�\���          1
MMAS_FIELD	ENDS
MMAS	MMAS_FIELD	<,,,,,,,,,,,,,,,,>		;������

MMAS_SIZE	EQU	SIZE MMAS
BUF_SIZE	EQU	MMAS_SIZE*31
FILE_NO		DW	0				;�t�@�C���n���h��

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




JADD_REC	DW	0				;�斱��REC
DAY_REC		DW	0				;����
DAY_REC_C	DW	0				;����
DAY_COUNT	DW	0				;���t�J�E���g
DAY_U		DB	0				;�����NFLG
DAY_MAX		DW	365				;�P�N�̓���
K_KTJ		DW	0				;�S������(����)
K_KKK		DW	0				;���i��
K_SM		DW	0				;�J�n����(��)�ޔ��G���A
F_POINT		DD	0				;�t�@�C���|�C���^�[�ޔ�
D_ADD		DW	0				;�޲ԓ������ڽ
D_DAYC		DW	0				;�Ζ�����
D_TBL_DMY	DW	0				;�޲�ð�����а
D_TBL		DW	99 DUP(0)			;�޲ԓ���ð���

D_TBL_SIZE	EQU	SIZE D_TBL			;ð��ق̻��ގ擾

MAIN	ENDP
endp	EQU	$

CODE		ENDS
		END
