;****************************************
;*					*
;*	RSIBM PROC	Ver 1.00	*
;*					*
;*	AH=���W�x			*
;*	AL=���W�w			*
;*	CH=�@�\�R�[�h			*
;*	CL=������			*
;*	SI=�\�[�X������A�h���X		*
;*					*
;*  	CALL (TEXT$,OP%,ST%)		*
;*					*
;*	�@�\����(OP%)			*
;*	1��COM1 OPEN  			*
;*	2�������񑗏o			*
;*	3���������M			*
;*					*
;****************************************

PORT_NO		EQU	0			;COM PORT NO
BPS		EQU	7			;9600 Bps
PA     		EQU	2			;EVEN
JIS        	EQU	3			;8 Bit
STP		EQU	0			;STOP Bit

L_ADD		EQU	0F100H			;BLOAD���ڽ  BASIC &HF100
OFSET		EQU	L_ADD-7			;OFFSET

PARA_OP	STRUC				;�X�^�b�N��n�e�[�u��
	BP_SS	DW	?		;BP�̑ޔ�
	R_ADD	DD	?		;RETURN	ADD
	ST_P	DW	?		;ST%	ADD
	OP_P	DW	?		;OP%	ADD
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

SUB_ST:

	MOV	BP,SP
	PUSHA

	MOV	BX,[BP].ST_P		;�ð�����ڽ
	MOV	ST_ADD[OFSET],BX

	MOV	BX,[BP].OP_P		;��߼�ݎ擾
	MOV	OP_ADD[OFSET],BX	;��߼�ݱ��ڽ
	MOV	AX,[BX]
	MOV	OP_TION[OFSET],AL


	MOV	BX,[BP].TX_P		;�s�d�w�s�� �X�g�����O�f�B�X�N���v�^
	MOV	CL,[BX]			;�s�d�w�s���̒���
	MOV	INTBL.IN_L[OFSET],CL	;�������ݸ޽
	MOV	SI,[BX+1]		;�s�d�w�s���̃A�h���X
	MOV	TEXT_ADD[OFSET],SI	;


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
	MOVSB					;[DI]��[SI]�̓��e��߰
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
	MOV	BX,QZ_ADD[OFSET]		;OBASIC CALL
	MOV	BYTE PTR [BX],AL		;���ͺ���RETURN	

	MOV	DI,TEXT_ADD[OFSET]		;�s�d�w�s���̃A�h���X
	MOV	SI,OFFSET INTBL.IN_D[OFSET]
	MOV	CL,INTBL.IN_L[OFSET]
	REP	MOVSB
	POPA
	POP	BP

	RET	18			;STACK	�ذ RETURN

MAIN	ENDP
ENDP	EQU	$
CODE	ENDS
	END
