;****************************************
;*					*
;*	INPUT PROC	Ver 2.11	*
;*					*
;*	AH=���W�x			*
;*	AL=���W�w			*
;*	CH=�@�\�R�[�h			*
;*	CL=������			*
;*	SI=�\�[�X������A�h���X		*
;*					*
;*  	CALL (TEXT$,HX%,HY%,QZ%,OP%,	*
;*	      C1%,C2%,C3%,C4%)		*
;*					*
;*	�����R�[�h	80H�` 9FH	*
;*			0E0H�`0FFH	*
;*	�ŃR�[�h	0A0H�`0DFH	*
;*			   ��`�		*
;*	�@�\����			*
;*	1�������̂�  			*
;*	2�����p�̂�			*
;*	3���Ȃ�ł��L��			*
;*					*
;*	4�������̂�  	�ݸ޽�Ŕ�����	*
;*	5�����p�̂�			*
;*	6���Ȃ�ł��L��			*
;*					*
;*	7���S�p�̂�  			*
;*	8���J�i�̂�			*
;*					*
;*	NUL CHK �ǉ�			*
;*					*
;*					*
;****************************************

;****************************************
;	MDOS.H	FUNCTION 21H		*
;	STD .H	��̫�Ē�`		*
;****************************************
INCLUDE	MDOS.H
INCLUDE	STD.H


KANJ_TBL_LEN	EQU	128			;����ð����ݸ޽ WORD PTR
CU_TOP		EQU	21			;����į�߈ʒu
CU_DOT		EQU	8			;�����ޯĐ�
CU_DEF_TOP	EQU	0			;����į�߈ʒu ��̫��
CU_DEF_DOT	EQU	29			;�����ޯĐ�   ��̫��
NOT_KEYC	EQU	20H			;���̓L�[����R�[�h

FGC1		EQU	7			;�\���F  ��
BGC1		EQU	0			;�w�i�F  ��
FGP1		EQU	0			;�\���F�g��
BGP1		EQU	0			;�w�i�F�g��

						;�ݒ躰�ޖ����͎󂯕t���Ȃ�
L_ADD		EQU	0F100H			;BLOAD���ڽ  BASIC &HF100
OFSET		EQU	L_ADD-7			;OFFSET

PARA_OP	STRUC				;�X�^�b�N��n�e�[�u��
	BP_SS	DW	?		;BP�̑ޔ�
	R_ADD	DD	?		;RETURN	ADD
	C4_P	DW	?		;�g���FFGP
	C3_P	DW	?		;�g���O�����h�w��FG
	C2_P	DW	?		;���͔w�i�FBGC
	C1_P	DW	?		;���͕\���FFGC
	OP_P	DW	?		;�I�v�V����
	QZ_P	DW	?		;�L�R�[�h
	Y_P	DW	?		;Y	ADD
	X_P	DW	?		;X	ADD
	TX_P	DW	?		;TEXT$	ADD
PARA_OP	ENDS

CODE	SEGMENT	
	ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE

	DB	0FDH		;BSAVE�̈�
	DW	0000H		;�Z�O�����g�A�h���X�@�_�~�[
	DW	L_ADD		;�I�t�Z�b�g�A�h���X
	DW	ENDP-STARTP	;�v���O�����̒���

	PUBLIC	MAIN

STARTP	EQU	$
;MAIN PROGRAM
MAIN 	PROC	FAR

	PUSH	BP
	MOV	ESC_FLG[OFSET],0

SUB_ST:

	MOV	BP,SP
	PUSHA

	MOV	BX,[BP].C1_P		;�\���F�A�h���X
	MOV	AX,[BX]
	MOV	FGC[OFSET],AL

	MOV	BX,[BP].C2_P		;�w�i�F�A�h���X
	MOV	AX,[BX]
	MOV	BGC[OFSET],AL

	MOV	BX,[BP].C3_P		;�\���g���A�h���X
	MOV	AX,[BX]
	MOV	FGP[OFSET],AL

	MOV	BX,[BP].C4_P		;�w�i�g���A�h���X
	MOV	AX,[BX]
	MOV	BGP[OFSET],AL

	MOV	BX,[BP].OP_P		;�I�v�V�����A�h���X
	MOV	AX,[BX]
	MOV	OP_FLG[OFSET],AL

	MOV	BX,[BP].QZ_P		;�L�[�R�[�h�A�h���X
	MOV	QZ_ADD[OFSET],BX

	MOV	BX,[BP].X_P		;�w���W
	MOV	AX,[BX]
	CMP	AL,0
	JNE	_XNEXT
	MOV	AL,1
_XNEXT:
	DEC	AL
	MOV	INTBL.IN_X[OFSET],AL	;۹��X

	MOV	BX,[BP].Y_P		;�x���W
	MOV	AX,[BX]
	CMP	AL,0
	JNE	_YNEXT
	MOV	AL,1
_YNEXT:
	DEC	AL
	MOV	INTBL.IN_Y[OFSET],AL	;۹��Y

	MOV	BX,[BP].TX_P		;�s�d�w�s�� �X�g�����O�f�B�X�N���v�^
	MOV	CL,[BX]			;�s�d�w�s���̒���
	MOV	INTBL.IN_L[OFSET],CL	;�������ݸ޽
	MOV	SI,[BX+1]		;�s�d�w�s���̃A�h���X
	MOV	TEXT_ADD[OFSET],SI	;

;------------------------------------------------------------------------
;CODE	SEGMENT	PUBLIC							-
;	ASSUME	CS:CODE,DS:DATA,ES:DATA					-
;									-
;****************************************				-
; �O���Q�Ɓ@	LOCATE			*				-
; ���W���[����	INPUT			*				-
;****************************************				-
;EXTRN	LOCATE:NEAR							-
;PUBLIC	INPUT								-
;									-
;------------------------------------------------------------------------
;�����ݒ�								-
;									-
;INPUT	PROC	NEAR							-
;------------------------------------------------------------------------

	CALL	INP_COL				;��ʐF�ݒ�
;	CALL	K_MODE				;���ް��Ӱ�ސݒ�
	XOR	AX,AX				;AX������
	XOR	BX,BX				;BX������
	XOR	CX,CX				;CX������
	XOR	DX,DX				;DX������
;	CALL	FEP				;FEP�N���ݒ�  FEP_S�ɂ��
	MOV	INS_FLG[OFSET],0		;�ݻ���׸ޏ�����
	CLD					;�ިڸ���FLG ؾ��
	MOV	DI,OFFSET INTBL.IN_K[OFSET]	;����FLGð��ٸر�
	MOV	CX,KANJ_TBL_LEN			;ð����ݸ޽
	REP	STOSW				;[DI]��AL���

	MOV	DI,OFFSET INTBL.IN_D[OFSET]	;������i�[���ڽ
	MOV	BP,DI				;DI��BP�ɑޔ�
	MOV	CL,INTBL.IN_L[OFSET]		;�������ݸ޽
;--------------------------------------------------------------------
;�����񃏁[�N�G���A�ɃR�s�[

CP_CHR:
	MOV	AL,CS:[SI]			;SI�̎����������߰
	OR	CL,CL				;IF CL=0 THEN GOTO CP_CHR2
	JZ	CP_CHR2
	CMP	INTBL.IN_K[BX][OFSET],2		;�������ނQ�޲Ė�����
	JZ	CP_CHR1
	CALL	KNJ_CHK				;������������
	CMP	KNJ_CHK_F[OFSET],1		;�������ނP�޲Ė�����
	JNE	CP_CHR1
	MOV	INTBL.IN_K[BX][OFSET],1		;����ð��پ��
	MOV	INTBL.IN_K[BX+1][OFSET],2	;����ð��پ��
CP_CHR1:
	INC	BX				;����������
	DEC	CX				;OBASIC CALL
	LODSB
	CMP	AL,0
	JNE	CP_NUL
	MOV	AL,20H
CP_NUL:
	STOSB
	JMP	SHORT CP_CHR
CP_CHR2:					;�����ݸ޽�̎�����
	MOV	CL,INTBL.IN_L[OFSET]		;�܂�SPC���
	SUB	CX,BX
	LEA	DI,INTBL.IN_D[BX][OFSET]
	MOV	AL,SPC
	REP	STOSB
CP_CHR3:					;�����ݸ޽�̍Ō��NUL���
	MOV	BYTE PTR [DI],NUL
	MOV	DI,BP				;DI���A
	CALL	INP_LOC				;�\��LOCATE���
	CALL	INP_CRT				;��ʕ\��
	XOR	BX,BX
	PUSH	BX
	PUSH	ES				;INT 80H
	MOV	DL,1				;����Ӱ�ށ@�\���ɐݒ�
	MOV	CL,2AH				;BIOS CALL
	INT	80H				;CL=2AH
	POP	ES				;BX,ES�j��
	POP	BX
;---------------------------------------------------------------------
;���C���X�^�[�g ���̓��P�[�g�\��

	CMP	ESC_FLG[OFSET],1
	JNE	INP_START
	MOV	AL,1BH
	JMP	INP_END

INP_START:
	MOV	AH,INTBL.IN_Y[OFSET]		;۹��Y
	MOV	AL,INTBL.IN_X[OFSET]		;۹��X	
	ADD	AL,BL				;۹��X�ɕ����߼޼����׽
	CALL	LOCATE				;PROC NEAR


;--------------------------------------------------------------------------
;�L�[����

	PUSH	BX
	PUSH	ES				;AL=����
	MOV	CL,18H				;�ꕶ������
	INT	80H				;INT 80H
	POP	ES				;AX,BX,ES�j��
	POP	BX				;CL=18H

;--------------------------------------------------------------------------
;����R�[�h�W�����v�e�[�u�����[�`��

	MOV	SI,OFFSET KEY_TBL[OFSET-4]	;��ð��� OFFSET
KEY_C:	ADD	SI,4;
	CMP	BYTE PTR [SI],0FFH		;��ð��ٍŌ�
	JZ	KEY_EXIT
	CMP	AL,[SI]				;�����ޔ�r
	JNZ	KEY_C
	JMP	[SI+2]				;ð��ټެ���
KEY_EXIT:
	JMP	INP_0				;���䕶���ȊO
;--------------------------------------------------------------------------
;����R�[�h�������[�`��

LEFT0:						;���̏�������
	CMP	BL,0				;�P�ԍ��[
	JNE	LEFT1
	CALL	BEEP1
	JMP	INP_START
LEFT1:
	DEC	BL				;���ٍ��Ɉړ�
	CMP	INTBL.IN_K[BX][OFSET],2		;��������2�޲Ėڂ�����
	JNE	LEFT2
	DEC	BL
LEFT2:
;	CMP	OP_FLG[OFSET],BAK_OP_FLG1
						;��߼��3,6�ޯ���߰�����
;	JZ	BS2
;	CMP	OP_FLG[OFSET],BAK_OP_FLG2
;	JZ	BS2
	JMP	INP_START
;--------------------------------------------------------------------------

BS0:						;�a�r��������
	CMP	BL,0				;�P�ԍ��[
	JNE	BS1
	CALL	BEEP1
	JMP	INP_START
BS1:
	DEC	BL				;���ٍ��Ɉړ�
	CMP	INTBL.IN_K[BX][OFSET],2		;��������2�޲Ėڂ�����
	JNE	BS2
	DEC	BL
BS2:
	CALL	DEL_1
	JMP	INP_START
;--------------------------------------------------------------------------

RIGHT0:						;���̏���
;	CMP	OP_FLG[OFSET],RIGHT_OP_FLG1	;��߼��3,6�E�ړ��į��
;	JZ	RIGHT3
;	CMP	OP_FLG[OFSET],RIGHT_OP_FLG2
;	JZ	RIGHT3
	INC	BL
	CMP	INTBL.IN_K[BX][OFSET],2		;��������2�޲Ėڂ�����
	JZ	RIGHT1
	CMP	BL,INTBL.IN_L[OFSET]
	JNE	RIGHT3
	CALL	BEEP1
	DEC	BL
	JMP	INP_START
RIGHT1:
	MOV	DL,INTBL.IN_L[OFSET]
	DEC	DL
	CMP	BL,DL				;������2�޲Ă��Ō�
	JNE	RIGHT2
	CALL	BEEP1
	SUB	BL,2
RIGHT2:
	INC	BL
RIGHT3:
	JMP	INP_START
;--------------------------------------------------------------------------

INS0:						;INS�̏���
	CMP	INS_FLG[OFSET],0		;FLG=0 �ݻ��Ӱ�ސݒ�
	JZ	INS1				;FLG=1 �ݻ��Ӱ�މ���
	MOV	INS_FLG[OFSET],0
	MOV	DL,1
	MOV	AL,CU_DEF_DOT			;��̫�Ă��ޯĐ�
	MOV	AH,CU_DEF_TOP			;��̫�Ă�į�߈ʒu
	JMP	SHORT INS2
INS1:
	MOV	INS_FLG[OFSET],1		;�ݻ��Ӱ�ސݒ�
	MOV	DL,1
	MOV	AL,CU_DOT			;�����ޯĐ�
	MOV	AH,CU_TOP			;����į�߈ʒu
INS2:
	MOV	CL,2BH				;BIOS CALL
	PUSH	BX				;���ٌ`��ݒ�
	PUSH	ES				;INT 80H
	INT	80H				;CL=2BH
	POP	ES				;AL=�����ޯĐ�
	POP	BX				;AH=���ٕ\��į��
	JMP	INP_START			;ES,AX,BX�j��
;----------------------------------------------------------------------
DEL0:						;DEL�̏���
	CALL	DEL_1
	JMP	INP_START
;----------------------------------------------------------------------

HOME0:
;	CMP	OP_FLG[OFSET],BAK_OP_FLG1
;	JZ	CLS0
;	CMP	OP_FLG[OFSET],BAK_OP_FLG2
;	JZ	CLS0
	MOV	BL,0				;�擪�s�w�Z�b�g
	JMP	INP_START
;----------------------------------------------------------------------

CLS0:
	MOV	AL,SPC				;SPC����
	XOR	CX,CX
	CLD					;�ިڸ���FLG ؾ��
	MOV	DI,OFFSET INTBL.IN_D[OFSET]	;�����ر�ر�
	MOV	CL,INTBL.IN_L[OFSET]		;�����ݸ޽
	REP	STOSB				;[DI]��AL���

	XOR	AX,AX
	XOR	CX,CX
	MOV	DI,OFFSET INTBL.IN_K[OFSET]	;����FLGð��ٸر�
	MOV	CX,KANJ_TBL_LEN			;ð����ݸ޽
	REP	STOSW				;[DI]��AX���

	CALL	INP_LOC
	CALL	INP_CRT
	MOV	BL,0				;�擪�s�w�Z�b�g
	JMP	INP_START
;----------------------------------------------------------------------
ESC0:
	POPA
	MOV	ESC_FLG[OFSET],1
	JMP	SUB_ST
;------------------------------------------------------------------------
CR0:
	JMP	INP_END
;------------------------------------------------------------------------
UP0:
	CMP	BL,0
	JNE	UP0_1
	JMP	INP_END
UP0_1:
	CALL	BEEP1
	JMP	INP_START
;------------------------------------------------------------------------
DO0:
	CMP	BL,0
	JNE	DO0_1
	JMP	INP_END
DO0_1:
	CALL	BEEP1
	JMP	INP_START


;------------------------------------------------------------------------
BREAK0:
	JMP	INP_END
;------------------------------------------------------------------------
;�������͏���

INP_0:
	MOV	INC_FLG[OFSET],0		;�ݸ����FLG=0
INP_01:
	CMP	AL,NOT_KEYC			;CHAR ���ނ�20H����
	JAE	INP_02
	JMP	INP_START
INP_02:
	CALL	OP_CHK				;��߼������
	CMP	NG[OFSET],0			;���͐���FLG NG=1 ���͋���
	JZ	INP_1
	CALL	BEEP1
	JMP	INP_START
INP_1:
	CALL	KNJ_CHK				;������������
	CMP	KNJ_CHK_F[OFSET],1;
	JNE	INP_4				;�������ނ���Ȃ��ꍇ�́AINP_4
	CMP	INTBL.IN_D[BX+1][OFSET],NUL	;�ּެ���
	JNE	INP_2				;�������ނ�2�޲Ėڂ�����Ȃ�
						;�ꍇ�́ABEFFER �ر�����
 	PUSH	BX				;BIOS CALL
	PUSH	ES				;CL=18H
	MOV	CL,18H				;INT 80H
	INT	80H				;AL=����
	POP	ES				;ES,AX,BX�j��
	POP	BX				;����BUFFER �ر�
	JMP	INP_START
INP_2:
	CMP	INS_FLG[OFSET],1		;�ݻ��Ӱ�ނ�����
	JNE	INP_3
	CALL	INS_1				;�ݻ��ٰ�ݺ��
INP_3:
	MOV	INTBL.IN_D[BX][OFSET],AL	;�������ޓ��͏���
	MOV	INTBL.IN_K[BX][OFSET],1		;1�޲Ėھ�ď���
 	PUSH	BX				;BIOS CALL
	PUSH	ES				;CL=18H
	MOV	CL,18H				;INT 80H
	INT	80H
	POP	ES				;AL=����
	POP	BX				;ES,AX,BX�j��
	MOV	INTBL.IN_D[BX+1][OFSET],AL	;2�޲Ėھ�ď���
	MOV	INTBL.IN_K[BX+1][OFSET],2
	CMP	INTBL.IN_D[BX+2][OFSET],NUL	;���͌㎟�̶����߼޼������
	JZ	INP_6				;�����߼޼�݂��ݸ޽�̍Ō�
	ADD	BL,2				;��������INP_6 �ּެ���
	MOV	INC_FLG[OFSET],1		;
	JMP	SHORT INP_6			;NOT ���������߼޼�ݐݒ�
INP_4:
	CMP	INS_FLG[OFSET],1		;���p����ٰ��
	JNE	INP_5				;�ݻ��Ӱ������
	CALL	INS_1				;�ݻ��ٰ�ݺ��
INP_5:
	MOV	INTBL.IN_D[BX][OFSET],AL	;���޾��
	MOV	INTBL.IN_K[BX][OFSET],0		;����FLG�ر�
	CMP	INTBL.IN_D[BX+1][OFSET],NUL	;���̶����߼޼������
	JZ	INP_6				;�����߼޼�݂��ݸ޽�̍Ō�
	MOV	INC_FLG[OFSET],1		;�������� INP_6 �ּެ���
	INC	BL				; NOT ���������߼޼�ݐݒ�

INP_6:
	CMP	INS_FLG[OFSET],1		;�����߼޼�݂̏������菈��
	JZ	INP_7
	CMP	INTBL.IN_K[BX][OFSET],2		;�����߼޼�݂�������2�޲Ė�
	JNE	INP_7				;�������ꍇ�͊���ð��ق�ر�
	MOV	INTBL.IN_K[BX][OFSET],0		;������SPC���
	MOV	INTBL.IN_D[BX][OFSET],SPC
INP_7:
	CALL	INP_LOC				;�\��LOCATE���
	CALL	INP_CRT				;��ʕ\��

	CMP	INC_FLG[OFSET],0		;���ق̈ʒu���ړ��\�̏��
	JNE	INP_8				;IF INC_FLG=1 THEN GOTO INP_8
						;�ړ��ł����Ԃ�������INP_8��

	CMP	OP_FLG[OFSET],4			;IF OP_FLG<4 THEN GOTO INP_8
	JB	INP_8
	CMP	OP_FLG[OFSET],6			;IF OP_FLG>6 THEN GOTO INP_8
	JA	INP_8

	CMP	KNJ_CHK_F[OFSET],1		;��������
	JZ	INP_7S				;�񊿎��̏���
	CMP	INTBL.IN_D[BX+1][OFSET],NUL	;���̶����߼޼������
	JNE	INP_8				;���ق��ړ��ł��Ȃ�����
	JMP	INP_END				;���̕������m�t�k
INP_7S:
						;�����̏���
	CMP	INTBL.IN_D[BX+2][OFSET],NUL	;���̶����߼޼������
	JNE	INP_8				;���ق��ړ��ł��Ȃ�����
	JMP	INP_END				;���̕������m�t�k

INP_8:
	JMP	INP_START			;���̓��C����
;------------------------------------------------------------------------
;���͏I��

INP_END:
	PUSH	AX
	PUSH	ES				;ES,AX,BX�j��
	MOV	DL,1				;BIOS CALL
	MOV	AL,CU_DEF_DOT			;INT 80H
	MOV	AH,CU_DEF_TOP			;���ٌ`������ɖ߂�
	MOV	CL,2BH				;CL=2BH
	INT	80H
;-------------------------------------------------------------------------
;	MOV	CL,69H				;BIOS CALL
;	MOV	AH,1				;INT 80H
;	MOV	DX,K_STK[OFSET]			;CL=69H	
;	INT	80H				;��Ӱ�ޏ����l�ɖ߂�
;-------------------------------------------------------------------------
;	MOV	CL,0BH				;BIOS CALL
;	MOV	BL,0				;INT 83H
; 	INT	83H				;CL=0BH
;-------------------------------------------------------------------------
	POP	ES				;FEP �I��

;	CALL	INP_COL1			;��ʐF COLOR 6,0
;	CALL	INP_LOC				;�\��LOCATE���
;	CALL	INP_CRT				;��ʕ\��

	POP	AX
	MOV	BX,QZ_ADD[OFSET]		;OBASIC CALL
	MOV	BYTE PTR [BX],AL		;���ͺ���RETURN	

	MOV	DI,TEXT_ADD[OFSET]		;�s�d�w�s���̃A�h���X
	MOV	SI,OFFSET INTBL.IN_D[OFSET]
	MOV	CL,INTBL.IN_L[OFSET]
	REP	MOVSB
	POPA
	POP	BP

	RET	18			;STACK	�ذ RETURN

;-------------------------------------------------------------------------
;************************
;*	���ٰ��		*
;************************

INP_LOC	PROC	NEAR				;����LOCATE 	ٰ��
	MOV	AH,INTBL.IN_Y[OFSET]
	MOV	AL,INTBL.IN_X[OFSET]
	CALL	LOCATE
	RET
INP_LOC	ENDP

INP_CRT	PROC	NEAR				;��ʕ\��	ٰ��
	PUSHA
	XOR	SI,SI
	MOV	DH,INTBL.IN_L[OFSET]		;������DH�
INP_CRT_LOOP:	

	MOV	CL,29H				;BIOS CALL
	MOV	DL,INTBL.IN_D[SI][OFSET]	;INT 80H
	INT	80H				;DH��\��
	INC	SI
	DEC	DH
	JZ	INP_CRT_EXIT
	JMP	INP_CRT_LOOP

INP_CRT_EXIT:

	POPA
	RET
INP_CRT	ENDP

BEEP1	PROC	NEAR				;�ް�߉�����	ٰ��
	DISPLAY_CHAR	BEEP			;FUNCTION 02H
	RET					;MDOS.H
BEEP1	ENDP

INS_1	PROC	NEAR				;INS����	ٰ��
	MOV	INP_COUNT[OFSET],BL		;�����߼޼�ݑޔ�
	MOV	CL,INTBL.IN_L[OFSET]		;�������ݸ޽�擾
	SUB	CL,BL				;�ݸ޽�Ɠ��͐��̍�
	MOV	CL_STK[OFSET],CL		;�į�
	MOV	BL,INTBL.IN_L[OFSET]		;��납��ړ�
	LEA	DI,INTBL.IN_K[BX-1][OFSET]	;�ړ���̱��ڽ�擾
	MOV	DI_STK[OFSET],DI		;�į�(����ð���)
	LEA	DI,INTBL.IN_D[BX-1][OFSET]	;�ړ���̱��ڽ�擾
	CMP	KNJ_CHK_F[OFSET],1		;�������ނ�����
	JNE	INS_2				;��������Ȃ����̔�ѐ�
	DEC	BL				;
	DEC	CL
	MOV	CL_STK[OFSET],CL
INS_2:
	LEA	SI,INTBL.IN_K[BX-2][OFSET]	;�ړ����̱��ڽ�擾
	MOV	SI_STK[OFSET],SI		;�į�(����ð���)
	LEA	SI,INTBL.IN_D[BX-2][OFSET]	;�ړ����̱��ڽ�擾
	STD					;�ިڸ��� FLG ���
	REP	MOVSB				;[SI]��[DI]��߰
	MOV	DI,DI_STK[OFSET]		;CX����s
	MOV	SI,SI_STK[OFSET]
	MOV	CL,CL_STK[OFSET]
	REP	MOVSB
	MOV	BL,INTBL.IN_L[OFSET]
	CMP	INTBL.IN_K[BX-1][OFSET],1
	JNE	INS_3
	MOV	INTBL.IN_D[BX-1][OFSET],SPC
	MOV	INTBL.IN_K[BX-1][OFSET],0
INS_3:
	MOV	BL,INP_COUNT[OFSET]
	MOV	DI,BP
	CLD
	RET
INS_1	ENDP

DEL_1	PROC	NEAR				;DEL����	ٰ��
	MOV	DEL_SPC[OFSET],0
	MOV	INP_COUNT[OFSET],BL
	MOV	CL,INTBL.IN_L[OFSET]
	SUB	CL,BL
	MOV	CL_STK[OFSET],CL
	LEA	DI,INTBL.IN_K[BX][OFSET]
	MOV	DI_STK[OFSET],DI
	LEA	DI,INTBL.IN_D[BX][OFSET]
	CMP	INTBL.IN_K[BX][OFSET],1
	JNE	DEL_2
	DEC	CL
	MOV	CL_STK[OFSET],CL
	INC	BL
	MOV	DEL_SPC[OFSET],1
DEL_2:
	LEA	SI,INTBL.IN_K[BX+1][OFSET]
	MOV	SI_STK[OFSET],SI
	LEA	SI,INTBL.IN_D[BX+1][OFSET]
	REP	MOVSB
	MOV	SI,SI_STK[OFSET]
	MOV	DI,DI_STK[OFSET]
	MOV	CL,CL_STK[OFSET]
	REP	MOVSB
DEL_3:
	MOV	BL,INTBL.IN_L[OFSET]
	MOV	INTBL.IN_D[BX-1][OFSET],SPC
	MOV	INTBL.IN_K[BX-1][OFSET],0
	CMP	DEL_SPC[OFSET],0
	JZ	DEL_4
	MOV	INTBL.IN_D[BX-2][OFSET],SPC
	MOV	INTBL.IN_K[BX-2][OFSET],0
DEL_4:
	CALL	INP_LOC
	CALL	INP_CRT
	MOV	BL,INP_COUNT[OFSET]
	RET
DEL_1	ENDP

OP_CHK	PROC	NEAR					;�I�v�V����	ٰ��
	MOV	NG[OFSET],0
	CALL	KNJ_CHK
	MOV	SI,OFFSET OP_TBL[OFSET-4]		;��߼��ð��� OFFSET

OP_C:	ADD	SI,4					;
	CMP	BYTE PTR [SI],0FFH			;��ð��ٍŌ�
	JZ	OP_EXIT
	MOV	DH,OP_FLG[OFSET]
	CMP	DH,[SI]					;�����ޔ�r
	JNZ	OP_C
	JMP	[SI+2]					;ð��ټެ���

OP_4:
OP_1:						;�����̂�
	CMP	KNJ_CHK_F[OFSET],1		;���ނ���������
	JZ	OP_CHK_NG			;����NG���
	CMP	AL,"*"				;���ؽ���OK
	JZ	OP_1EXIT
	CMP	AL,"+"				;��׽��OK
	JZ	OP_1EXIT
	CMP	AL,"-"				;ϲŽ��OK
	JZ	OP_1EXIT
	CMP	AL,"."				;��ص�ނ�OK
	JZ	OP_1EXIT

	CMP	AL,30H				;���ނ�"1"��菬����
	JB	OP_CHK_NG
	CMP	AL,39H				;���ނ�"9"���傫��
	JA	OP_CHK_NG
OP_1EXIT:
	JMP	OP_EXIT

OP_2:
OP_5:						;���p�̂�
	CMP	KNJ_CHK_F[OFSET],1		;���ނ���������
	JZ	OP_CHK_NG
	JMP	OP_EXIT

OP_3:
OP_6:						;���ł�����
	JMP	OP_EXIT

OP_7:						;�S�p�̂�
	CMP	KNJ_CHK_F[OFSET],1		;���ނ���������
	JZ	OP_EXIT
	JMP	OP_CHK_NG

OP_8:						;�J�i�̂�
	CMP	KNJ_CHK_F[OFSET],1		;���ނ���������
	JZ	OP_CHK_NG
	CMP	AL,20H				;���ނ�SPC��OK
	JZ	OP_EXIT
	CMP	AL,0A0H				;���ނ� "�"��菬����
	JB	OP_CHK_NG
	CMP	AL,0DFH				;���ނ� "�"���傫��
	JA	OP_CHK_NG
	JMP	SHORT OP_EXIT


OP_CHK_NG:
 	CMP	KNJ_CHK_F[OFSET],1		;��߼�݂̎w�肪�������󂯕t��
						;�Ȃ�Ӱ�ނ������緰�ޯ̧�ر�
	JNE	OP_CHK_NG1
	PUSH	BX				;BIOS CALL
	PUSH	ES				;CL=18H
	MOV	CL,18H				;INT 80H
	INT	80H				;���޲ē���
	POP	ES				;BX,ES�j��
	POP	BX
OP_CHK_NG1:
	MOV	NG[OFSET],1
OP_EXIT:
	RET
OP_CHK	ENDP

KNJ_CHK	PROC	NEAR				;������������	ٰ��
	MOV	KNJ_CHK_F[OFSET],0
	CMP	AL,80H
	JB	KNJ_EXIT
	CMP	AL,9FH
	JA	KNJ_CHK2
	MOV	KNJ_CHK_F[OFSET],1
	JMP	SHORT KNJ_EXIT
KNJ_CHK2:
	CMP	AL,0E0H
	JB	KNJ_EXIT
	CMP	AL,0FFH
	JA	KNJ_EXIT
	MOV	KNJ_CHK_F[OFSET],1
KNJ_EXIT:
	RET
KNJ_CHK	ENDP

K_MODE	PROC	NEAR				;��Ӱ��		ٰ��
	PUSH	BX
	PUSH	ES
	MOV	AH,0
	MOV	CL,69H
	INT	80H
	MOV	K_STK[OFSET],AX
	CMP	OP_FLG[OFSET],0
	JZ	K_EXIT
	CMP	OP_FLG[OFSET],4
	JB	_M1
	MOV	DX,KM_4[OFSET]
	JMP	SHORT K_SET
_M1:	CMP	OP_FLG[OFSET],1
	JZ	_M2
	MOV	DX,KM_2[OFSET]
	JMP	SHORT K_SET
_M2:
	MOV	DX,KM_1[OFSET]

K_SET:	MOV	AH,1
	MOV	CL,69H
	INT	80H

K_EXIT:	POP	ES
	POP	BX
	RET
K_MODE	ENDP

FEP	PROC	NEAR				;FEP		ٰ��
	PUSH	BX
	PUSH	ES
	MOV	CL,0EH				;FEP�N��,�����ݒ�
 	INT	83H
	MOV	FEP_D[OFSET],AL			;����Ӱ�ޑޔ�
	CMP	FEP_S[OFSET],1			;FEP����
	JNE	FEP_EXIT
	MOV	CL,0BH
	MOV	BL,1
	INT	83H
FEP_EXIT:
	POP	ES
	POP	BX
	RET
FEP	ENDP

;****************************************
;*					*
;*	LOCATE PROC	���l��ėp	*
;*					*
;*	AH=���W�x	AL=���W�w	*
;*					*
;*	LIB	UTY.LIB	�o�^		*
;****************************************


LOCATE	PROC	NEAR

	PUSHA

	MOV	DL,AH
	XOR	AH,AH
	XOR	DH,DH
	MOV	CL,2DH
	PUSH	ES
	INT	80H
	POP	ES

	POPA
	RET

LOCATE	ENDP

;****************************************
;*					*
;*	COLOR	 PROC	�װ�̐ݒ�	*
;*					*
;*	FGC=̫��װ	BGC=�ޯ��װ	*
;*	FG=�g���װ�����ގw��		*
;*	FGP=�g���װ�w��			*
;*					*
;*	�װ�w��		0�`7	 	*
;*	�g��������	0��̫�	1���ޯ�	*
;*	�g���װ		0�����邢1���Â�*
;*					*
;*	LIB	UTY.LIB	�o�^		*
;****************************************


INP_COL	PROC	NEAR

	PUSHA

	MOV	DH,0			;�\���g���װ
	MOV	DL,FGP[OFSET]
	MOV	CL,0D9H
	CALL	BIOS

	MOV	DH,1			;�w�i�g���װ
	MOV	DL,BGP[OFSET]
	MOV	CL,0D9H
	CALL	BIOS

	MOV	DH,0			;̫������޶װ
	MOV	DL,FGC[OFSET]
	MOV	CL,34H
	CALL	BIOS

	MOV	DH,1			;�ޯ������޶װ
	MOV	DL,BGC[OFSET]
	MOV	CL,34H
	CALL	BIOS
	
	POPA
	RET

INP_COL	ENDP

INP_COL1	PROC	NEAR

	PUSHA

	MOV	DH,0			;�\���g���װ
	MOV	DL,FGP1
	MOV	CL,0D9H
	CALL	BIOS

	MOV	DH,1			;�w�i�g���װ
	MOV	DL,BGP1
	MOV	CL,0D9H
	CALL	BIOS

	MOV	DH,0			;̫������޶װ
	MOV	DL,FGC1
	MOV	CL,34H
	CALL	BIOS

	MOV	DH,1			;�ޯ������޶װ
	MOV	DL,BGC1
	MOV	CL,34H
	CALL	BIOS
	
	POPA
	RET

INP_COL1	ENDP

BIOS	PROC	NEAR
	PUSH	ES
	INT	80H
	POP	ES
	RET
BIOS	ENDP

;INPUT	ENDP----------------------------------------------------------------
;CODE	ENDS----------------------------------------------------------------


;DATA	SEGMENT	PUBLIC------------------------------------------------------

INP_STR	STRUC
	IN_Y	DB	0			;����۹��Y
	IN_X	DB	0			;����۹��X
	IN_L	DB	0			;���͐�
	IN_D	DB	256	DUP(0)		;�ް��i�[�̈�
	IN_K	DB	256	DUP(0)		;��������FLG
INP_STR	ENDS
INTBL	INP_STR	<,,,,>				;������


INP_COUNT	DB	0			;���͕������ޔ�̈�
CL_STK		DB	0			;CL�ޔ�̈�
SI_STK		DW	0			;SI�ޔ�̈�
DI_STK		DW	0			;DI�ޔ�̈�
INS_FLG		DB	0			;�ݻ��Ӱ��FLG
KNJ_CHK_F	DB	0			;������������FLG
DEL_SPC		DB	0			;�ްذ�ٰ�� ܰ�FLG
OP_FLG		DB	0			;�@�\����
QZ_ADD		DW	0			;���ͺ��� ���ڽ�i�[�̈�
NG		DB	0			;���͐�������FLG
K_STK		DW	0			;��Ӱ�ޑޔ�̈�
FEP_D		DB	0			;FEPӰ�ޑޔ�̈�
FEP_S		DB	0			;FEPӰ�޽���
KM_1		DW	0A400H			;�S�p
KM_2		DW	1400H			;����
KM_3		DW	1400H			;����
KM_4		DW	8400H			;ۯ�
KM_5		DW	8400H			;ۯ�
KM_6		DW	8400H			;ۯ�
FGC		DB	0			;�\���F
BGC		DB	0			;�w�i�F
FGP		DB	0			;�\���F�g��
BGP		DB	0			;�w�i�F�g��
INC_FLG		DB	0			;�ݸ����FLG
ESC_FLG		DB	0			;������FLG
TEXT_ADD	DW	0			;TEXT�̃A�h���X

;		�ެ���ð���
;			���ށ@JMP��
KEY_TBL		DW	001DH,LEFT0[OFSET]		;��
		DW	001CH,RIGHT0[OFSET]		;��
		DW	0012H,INS0[OFSET]		;�ݻ�� 	INS
		DW	007FH,DEL0[OFSET]		;��ذ�	DEL
		DW	0008H,BS0[OFSET]		;�ޯ�   BS
		DW	000BH,HOME0[OFSET]		;ΰѷ�  HOME
		DW	000CH,CLS0[OFSET]		;CLS��  CLS
		DW	001BH,ESC0[OFSET]		;ESC��  ESC
		DW	000DH,CR0[OFSET]		;CR��   CR
		DW	001EH,UP0[OFSET]		;��
		DW	001FH,DO0[OFSET]		;��
		DW	0003H,BREAK0[OFSET]		;BREAK  BREAK
		DB	0FFH   			;EXIT

;
;		�ެ���ð���
;			���ށ@JMP��
OP_TBL		DW	0001H,OP_1[OFSET]		;��߼��1
		DW	0002H,OP_2[OFSET]		;��߼��2
		DW	0003H,OP_3[OFSET]		;��߼��3
		DW	0004H,OP_4[OFSET]		;��߼��4
		DW	0005H,OP_5[OFSET]		;��߼��5
		DW	0006H,OP_6[OFSET]		;��߼��6
		DW	0007H,OP_7[OFSET]		;��߼��7
		DW	0008H,OP_8[OFSET]		;��߼��8
		DB	0FFH   			;EXIT

MAIN	ENDP
ENDP	EQU	$
CODE	ENDS
	END
