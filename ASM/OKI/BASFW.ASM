
INCLUDE	MDOS.H
INCLUDE	MACRO.H
INCLUDE	STD.H

L_ADD		EQU	0F600H		;BLOAD address = DS:F600
OFSET		EQU	L_ADD-7


PARA_OP	STRUC				;�X�^�b�N��n�e�[�u��
	BP_SV	DW	?		;BP�ޔ�
	R_ADD	DD	?		;RETURN	ADD
	S_FLG	DW	?		;�ð��FLG
	D_REC	DW	?		;���t
	J_REC	DW	?		;�斱��REC
	D_DAY	DW	?		;�Ζ�����
	K_KBN	DW	?		;�Ζ��敪
	K_KAI	DW	?		;���i��
	H_TIM	DW	?		;����َ���  13:00>>>1300
	K_TIM	DW	?		;�S������   13:00>>>1300
	Y_KAI	DW	?		;�\���
	M_KAI	DW	?		;������
	E_SYU	DW	?		;�c�Ǝ���   �P���x����
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

;--------------------------�c�Ǝ���

		
		MOV	BX,[BP].E_SYU	;�c�Ǝ����̃A�h���X�擾
		MOV	AX,[BX]		;�c�Ǝ������ʂ̒��g
		MOV	WORD PTR F1.P1[OFSET],AX
		MOV	AX,[BX+2]	;�c�Ǝ�����ʂ̒��g
		MOV	WORD PTR F1.P1[OFSET+2],AX
					;FIELD�ɃZ�b�g

;--------------------------������


		MOV	BX,[BP].M_KAI	;�����񐔃A�h���X�擾
		MOV	AX,[BX]		;�����񐔂̒��g
		MOV	F1.P2[OFSET],AX

;--------------------------�\���


		MOV	BX,[BP].Y_KAI	;�\��񐔃A�h���X�擾
		MOV	AX,[BX]		;�\��񐔂̒��g
		MOV	F1.P3[OFSET],AX


;--------------------------�S������


		MOV	BX,[BP].K_TIM	;�S�����ԃA�h���X�擾
		MOV	AX,[BX]		;�S�����Ԃ̒��g
		MOV	F1.P4[OFSET],AX


;--------------------------�n���h������


		MOV	BX,[BP].H_TIM	;����َ��ԃA�h���X�擾
		MOV	AX,[BX]		;����َ��Ԃ̒��g
		MOV	F1.P5[OFSET],AX


;--------------------------���i��


		MOV	BX,[BP].K_KAI	;���i�񐔃A�h���X�擾
		MOV	AX,[BX]		;���i�񐔂̒��g
		MOV	F1.P6[OFSET],AX


;--------------------------�Ζ��敪


		MOV	BX,[BP].K_KBN	;�Ζ��敪�A�h���X�擾
		MOV	AX,[BX]		;�Ζ��敪�̒��g
		MOV	F1.P7[OFSET],AX

;--------------------------�Ζ�����

		MOV	BX,[BP].D_DAY	;�Ζ������A�h���X�擾
		MOV	AX,[BX]		;�Ζ������̒��g
		MOV	F1.P8[OFSET],AX

;--------------------------�斱���q�d�b


		MOV	BX,[BP].J_REC	;�斱���q�d�b�A�h���X�擾
		MOV	AX,[BX]		;�斱���q�d�b�̒��g
		MOV	JADD_REC[OFSET],AX


;--------------------------�����q�d�b


		MOV	BX,[BP].D_REC	;�����q�d�b�A�h���X�擾
		MOV	AX,[BX]		;�����q�d�b�̒��g
		MOV	DAY_REC[OFSET],AX

;--------------------------�t�@�C���n���h��

		MOV	BX,[BP].NO_P	;�t�@�C���n���h���A�h���X�擾
		MOV	AX,[BX]		;�t�@�C���n���h���̒��g
		MOV	F1_NO[OFSET],AX


;--------------------------�t�@�C���|�C���^�̈ړ�  BUF_SIZE
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
		OR	CX,CX			;IF CX=0 THEN GOTO MOV1_CHK
		JNE	MOV_POINT		;        ELSE  MOV_POINT
		JMP	MOV1_CHK		;S_MMAS�̏�����

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

		MOV	WORD PTR F1_POINT[OFSET],DX	;�t�@�C���̃|�C���^�[
		MOV	WORD PTR F1_POINT[OFSET+2],AX	;DAY_REC=0 ���߲���

		JMP	MOV1_CHK

MOV_ERR:
		MOV	AX,ERR_MOV_POINT		;�װ����
		JMP	EXIT

;-----------------------------------------------�ۂ��񂽁[�ړ���������

MOV1_CHK:
		MOV	CX,DAY_REC[OFSET]	;DAY�̃��R�[�h�ԍ�
		DEC	CX			;REC 1��
		OR	CX,CX			;IF CX=0 THEN GOTO WRITE_DATA
		JNE	MOV1_POINT		;        ELSE  MOV1_POINT
		JMP	WRITE_DATA			;S_READ�̏�����

;-----------------------------------------------�ۂ��񂽁[�ړ� F1_FIELD

MOV1_POINT:

		MOV	AX,F1_FIELD
		MUL	CX

		MOV	BX,F1_NO[OFSET]
		MOV	CX,DX
		MOV	DX,AX
		MOV	AL,1
		MOV	AH,42H
		INT	21H
		
		JC	MOV1_ERR

		JMP	WRITE_DATA

MOV1_ERR:
		MOV	AX,ERR_MOV1_POINT	;�װ����
		JMP	EXIT


;--------------------------�t�@�C���ɏ�������

WRITE_DATA:
		MOV	AX,4000H
		MOV	DX,OFFSET F1.P1[OFSET]
		MOV	CX,F1_FIELD
		MOV	BX,F1_NO[OFSET]
		INT	21H

		JC	WRITE_ERR
		CMP	AX,F1_FIELD
		JZ	EXIT

WRITE_ERR:
		MOV	AX,ERR_S_WRITE
		JMP	SHORT EXIT


EXIT:
		MOV	BX,[BP].S_FLG	;�ð��FLG�A�h���X�擾
		MOV	[BX],AX		;�ð��FLG�Z�b�g   AX�ɾ��

		POPA			;�S���W�X�^���A
        	POP	BP		;BP���A
		RET	24		;�X�^�b�N����RETURN

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
F1	F1_STR		<,,,,,,>			;������

F1_FIELD	EQU	SIZE F1
F1_BUF		EQU	F1_FIELD*366
F1_NO		DW	0				;�t�@�C���n���h��

JADD_REC	DW	0				;�斱��REC
DAY_REC		DW	0				;����
F1_POINT	DD	0				;�߲����ޔ�ر



MAIN	ENDP
endp	EQU	$

CODE		ENDS
		END
