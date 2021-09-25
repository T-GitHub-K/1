INCLUDE	MDOS.H
INCLUDE	MACRO.H
INCLUDE	STD.H

L_ADD		EQU	0FA00H		;BLOAD address = DS:FA00
OFSET		EQU	L_ADD-7


PARA_OP	STRUC				;�X�^�b�N��n�e�[�u��
	BP_SV	DW	?		;BP�ޔ�
	R_ADD	DD	?		;RETURN	ADD
	S_FLG	DW	?		;�ð��FLG
	K_HAI	DW	?		;�z��
	U_DAY	DW	?		;�����NFLG
	C_DAY	DW	?		;���Đ�
	D_REC	DW	?		;���tREC
	J_REC	DW	?		;�斱��REC
	F_NO	DW	?		;̧��NO
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

;--------------------------�i�[�z����ڽ

		MOV	BX,[BP].K_HAI	;�i�[�z��A�h���X�擾
		MOV	K_ADD[OFSET],BX	;

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

;--------------------------�t�@�C���n���h���O(MMAS.UD)

		MOV	BX,[BP].F_NO	;�t�@�C���n���h���A�h���X�擾
		MOV	AX,[BX]		;�t�@�C���n���h���̒��g
		MOV	F1_NO[OFSET],AX

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
		MOVE_PTR	F1_NO[OFSET],0,0,0	;
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
		MOV	AX,F1_BUF
		MUL	CX

		MOV	BX,F1_NO[OFSET]
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

		MOV	AX,F1_SIZE
		MUL	CX

		MOV	BX,F1_NO[OFSET]
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
		READ_HANDLE	F1_NO[OFSET],F1.P1[OFSET],F1_SIZE
		JC	READ_ERR

		CMP	AX,F1_SIZE
		JZ	S_ADD

READ_ERR:
		MOV	AX,ERR_S_READ		;�װ����
		JMP	EXIT

;-----------------------------------------------------�W�v

S_ADD:
				;�P���x�������g�d�w�ɕϊ�
		MOV	AX,WORD PTR F1.P1[OFSET]	;�c�Ǝ�������
		MOV	BX,WORD PTR F1.P1[OFSET+2]	;�c�Ǝ������

		XOR	CX,CX
		XOR	DX,DX
		AND	BH,01111111B
		MOV	DL,BH
		MOV	CL,24
		SUB	CL,BH
		XOR	BH,BH

		OR	CL,CL
		JZ	NLOOP
		
LOOP1:
		SHR	BX,1
		RCR	AX,1
		LOOP	LOOP1
NLOOP:
		CMP	DL,16
		JA	S_NEXT
		MOV	CL,DL
		MOV	DX,1
		DEC	CL
		JZ	SET1
LOOP2:
		SHL	DX,1
		LOOP	LOOP2
SET1:
		OR 	AX,DX
		JMP	S_EXIT

S_NEXT:
		SUB	DL,16
		MOV	CL,DL
		MOV	DX,1
		DEC	CL
		JZ	SET
LOOP3:
		SHL	DX,1
		LOOP	LOOP3
SET:
		OR	BX,DX

S_EXIT:
		MOV	WORD PTR P1_EIS[OFSET],AX
		MOV	WORD PTR P1_EIS[OFSET+2],BX
;----------------------------------------�c�Ǝ���
S_KINTAI:
	CLC						;��ذFLGؾ��
	MOV	AX,KH.K2[OFSET]				;�c�Ǝ�������
	MOV	BX,WORD PTR P1_EIS[OFSET]		;�ϊ���c�Ǝ�������

	ADC	AX,BX					;
	MOV	KH.K2[OFSET],AX				;�W�v�ر�ɾ��

	MOV	AX,KH.K1[OFSET]				;�c�Ǝ������
	MOV	BX,WORD PTR P1_EIS[OFSET+2]		;�ϊ���c�Ǝ������

	ADC	AX,BX					;
	MOV	KH.K1[OFSET],AX				;�W�v�ر�ɾ��

;----------------------------------------------������
	MOV	AX,KH.K3[OFSET]				;�W�v������
	MOV	BX,F1.P2[OFSET]				;�ǂݍ��ݖ�����

	ADD	AX,BX					;
	MOV	KH.K3[OFSET],AX				;�W�v�ر�ɾ��

;----------------------------------------------�\���
	MOV	AX,KH.K4[OFSET]				;�W�v�\���
	MOV	BX,F1.P3[OFSET]				;�ǂݍ��ݗ\���

	ADD	AX,BX					;
	MOV	KH.K4[OFSET],AX				;�W�v�ر�ɾ��
;----------------------------------------------�S������
	MOV	AX,F1.P4[OFSET]				;�S������
	OR	AX,AX
	JZ	S_KINTAI1
	XOR	DX,DX
	MOV	BX,100					;���� to ���ɕϊ�
	DIV	BX
	MOV	CX,DX
	MOV	BX,60
	MUL	BX
	ADD	AX,CX
	MOV	BX,AX

	CLC						;��ذFLGؾ��
	MOV	AX,KH.K6[OFSET]				;�S�����ԉ���
	ADC	AX,BX					;
	MOV	KH.K6[OFSET],AX				;�W�v�ر�ɾ��

	MOV	AX,KH.K5[OFSET]				;�S�����ԏ��
	ADC	AX,0
	MOV	KH.K5[OFSET],AX				;�W�v�ر�ɾ��

;----------------------------------------------����َ���
S_KINTAI1:	
	MOV	AX,F1.P5[OFSET]				;����َ���
	OR	AX,AX
	JZ	S_KINTAI2
	XOR	DX,DX
	MOV	BX,100					;���� to ���ɕϊ�
	DIV	BX
	MOV	CX,DX
	MOV	BX,60
	MUL	BX
	ADD	AX,CX
	MOV	BX,AX

	CLC						;��ذFLGؾ��
	MOV	AX,KH.K8[OFSET]				;����َ��ԉ���
	ADC	AX,BX					;
	MOV	KH.K8[OFSET],AX				;�W�v�ر�ɾ��

	MOV	AX,KH.K7[OFSET]				;����َ��ԏ��
	ADC	AX,0
	MOV	KH.K7[OFSET],AX				;�W�v�ر�ɾ��

;----------------------------------------------���i��
S_KINTAI2:
	MOV	AX,KH.K9[OFSET]				;�W�v���i��
	MOV	BX,F1.P6[OFSET]				;�ǂݍ��݌��i��

	ADD	AX,BX					;
	MOV	KH.K9[OFSET],AX				;�W�v�ر�ɾ��
;----------------------------------------------�Ζ��敪�ʏW�v
	XOR	BX,BX
	MOV	CX,F1.P8[OFSET]				;�Ζ�����
	MOV	DX,F1.P7[OFSET]				;�Ζ��敪
	OR	DX,DX					;�Ζ��敪���Ȃ�!
	JZ	S_KINTAI3
	CMP	DX,KB_MAX				;�Ζ��敪�ő�l
	JA	S_KINTAI3
	ADD	BX,DX
	ADD	BX,DX

	MOV	AX,KH.K9[OFSET][BX]			;�W�v��
	ADD	AX,CX					;
	MOV	KH.K9[OFSET][BX],AX			;�W�v�ر�ɾ��

S_KINTAI3:


;---------------------------------------------------------------------------

REP_DATA:
		XOR	AX,AX
		DEC	DAY_COUNT[OFSET]
		JNE	MOV2_POINT
		JMP	EXIT

;-----------------------------------------------------------------------
MOV2_POINT:
		INC	DAY_REC_C[OFSET]
		MOV	AX,DAY_REC_C[OFSET]
		CMP	DAY_MAX[OFSET],AX
		JAE	MOV2_POINT1
							;MMASN.UD
		MOV	BX,F1_NO[OFSET]
		MOV	CX,WORD PTR F_POINT[OFSET]
		MOV	DX,WORD PTR F_POINT[OFSET+2]
		MOV	AL,0
		MOV	AH,42H
		INT	21H

		JC	MOV2_ERR
		MOV	DAY_REC_C[OFSET],1
		JMP	MOV2_POINT_EXIT

MOV2_POINT1:


MOV2_POINT_EXIT:

		JMP	S_READ

MOV2_ERR:
		MOV	AX,ERR_MOV2_POINT
		JMP	EXIT
;--------------------------------------------------------------------------

EXIT:
		MOV	BX,[BP].S_FLG	;�ð��FLG�A�h���X�擾
		MOV	[BX],AX		;�ð��FLG�Z�b�g   AX�ɾ��

		MOV	SI,OFFSET KH.K1[OFSET]
		MOV	DI,K_ADD[OFSET]
		CLD
		MOV	CX,KH_SIZE
		REP	MOVSW

		MOV	DI,OFFSET KH.K1[OFSET]
		XOR	AX,AX
		CLD
		MOV	CX,KH_SIZE
		REP	STOSW

		POPA			;�S���W�X�^���A
        	POP	BP		;BP���A
		RET	14		;�X�^�b�N����RETURN


;--------------------------------------------------------------------------
;		����FIELD �ݒ�
;		���R�[�h�����O�X�ݒ�  MMASN.UD
;--------------------------------------------------------------------------

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

F1_SIZE	EQU	SIZE F1
F1_BUF	EQU	F1_SIZE*366
F1_NO	DW	0				;�t�@�C���n���h��


;--------------------------------------------------------------------------
;		�i�[�z�� �ݒ�
;		���R�[�h�����O�X�ݒ� 
;--------------------------------------------------------------------------

K_STR	STRUC
	K1	DW	0				;�c�Ǝ��� ���	  
	K2	DW	0				;�c�Ǝ��� ����    
	K3	DW	0				;������         
	K4	DW	0				;�\���         
	K5	DW	0				;�S������ ���    
	K6	DW	0				;�S������ ����    
	K7	DW	0				;����َ��ԏ��    
	K8	DW	0				;����َ��ԉ���    
	K9	DW	0				;���i��         
	K10	DW	0				;�ʏ�Ζ�����     
	K11	DW	0				;���o�P����       
	K12	DW	0				;���o�Q����       
	K13	DW	0				;�J�Г���         
	K14	DW	0				;�L������         
	K15	DW	0				;���Γ���         
	K16	DW	0				;���x����         
	K17	DW	0				;��������         
	K18	DW	0				;�L������         
	K19	DW	0				;���L����         
	K20	DW	0				;�L�ʓ���         
	K21	DW	0				;���ʓ���         
K_STR	ENDS
KH	K_STR	<,,,,,,,,,,,,,,,,,,,,>			;������

KH_SIZE	EQU	SIZE KH/2
KB_MAX	EQU	21
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
F_POINT		DD	0				;�t�@�C���|�C���^�[�ޔ�
K_ADD		DW	0				;�i�[�z����ڽ
D_DAYC		DW	0				;�Ζ�����
P1_EIS		DD	0				;�c�Ǝ��� �ϊ���

MAIN	ENDP
endp	EQU	$

CODE		ENDS
		END
