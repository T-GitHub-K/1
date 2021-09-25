;****************************************
;*					*
;*	INPUT PROC	Ver 2.01	*
;*					*
;*	AH=���W�x			*
;*	AL=���W�w			*
;*	CH=�@�\�R�[�h			*
;*	CL=������			*
;*	BL=FEP�ϊ��w��			*
;*	SI=�\�[�X������A�h���X		*
;*	LIB	UTY.LIB		�o�^	*
;*					*
;*	RET				*
;*	DI=�\�[�X������A�h���X		*
;*	AL=�����o���R�[�h		*
;*					*
;*	�����R�[�h	80H�` 9FH	*
;*			0E0H�`0FFH	*
;*	�ŃR�[�h	0A0H�`0DFH	*
;*			   ��`�		*
;*	�@�\����			*
;*	0���Ȃ�ł��L��			*
;*	1���S�p�̂�	FEP�N��		*
;*	2���J�i�݂̂P			*
;*	3���J�i�݂̂Q(�ޯ���߰��L) 	*
;*	4�����p�̂�			*
;*	5�������݂̂P			*
;*	6�������݂̂Q(�ޯ���߰��L) 	*
;*					*
;****************************************

;****************************************
;	MDOS.H	FUNCTION 21H		*
;	STD .H	��̫�Ē�`		*
;****************************************
INCLUDE	MDOS.H
INCLUDE	STD.H

KANJ_TBL_LEN	EQU	40			;����ð����ݸ޽
BAK_OP_FLG1	EQU	3			;�ޯ���߰���߼�ݺ���1
BAK_OP_FLG2	EQU	6			;�ޯ���߰���߼�ݺ���2
RIGHT_OP_FLG1	EQU	3			;RIGHT OFF ��߼�ݺ���1
RIGHT_OP_FLG2	EQU	6			;RIGHT OFF ��߼�ݺ���2
CU_TOP		EQU	14			;INS ����į�߈ʒu
CU_DOT		EQU	15			;INS �����ޯĐ�
CU_DEF_TOP	EQU	0			;����į�߈ʒu ��̫��
CU_DEF_DOT	EQU	29			;�����ޯĐ�   ��̫��
NOT_KEYC	EQU	20H			;���̓L�[����R�[�h
						;�ݒ躰�ޖ����͎󂯕t���Ȃ�

CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE

;****************************************
; �O���Q�Ɓ@	LOCATE			*
; ���W���[����	INPUT			*
;****************************************
EXTRN	LOCATE:NEAR
PUBLIC	INPUT

;--------------------------------------------------------------------
;�����ݒ�

INPUT	PROC	NEAR

	MOV	WORD PTR DX_SAVE,DX		;DX�ޔ�
	MOV	BYTE PTR INTBL.IN_Y,AH		;۹��Y
	MOV	BYTE PTR INTBL.IN_X,AL		;۹��X
	MOV	BYTE PTR INTBL.IN_L,CL		;�������ݸ޽
	MOV	BYTE PTR OP_FLG,BH		;�@�\����
	MOV	BYTE PTR FEP_S,BL		;FEP����
	CALL	K_MODE				;���ް��Ӱ��SAVE,LOAD
	CALL	FEP				;FEP�̋N������
	XOR	AX,AX				;AX������
	XOR	BX,BX				;BX������
	XOR	CX,CX				;CX������
	MOV	BYTE PTR INS_FLG,0		;�ݻ���׸ޏ�����
	CLD					;�ިڸ���FLG ؾ��
	MOV	DI,OFFSET INTBL.IN_K		;����FLGð��ٸر�
	MOV	CX,KANJ_TBL_LEN			;ð����ݸ޽
	REP	STOSW				;[DI]��AL���

	MOV	DI,OFFSET INTBL.IN_D		;������i�[���ڽ
	MOV	BP,DI				;DI��BP�ɑޔ�
;--------------------------------------------------------------------
;�����񃏁[�N�G���A�ɃR�s�[

CP_CHR:
	MOV	AL,[SI]				;SI�̎����������߰
	CMP	AL,'$'				;$�̑O�܂ŃR�s�[
	JZ	CP_CHR2
	CMP	INTBL.IN_K[BX],2		;�������ނQ�޲Ė�����
	JZ	CP_CHR1
	CALL	KNJ_CHK				;������������
	CMP	KNJ_CHK_F,1			;�������ނP�޲Ė�����
	JNE	CP_CHR1
	MOV	INTBL.IN_K[BX],1		;����ð��پ��
	MOV	INTBL.IN_K[BX+1],2		;����ð��پ��
CP_CHR1:
	INC	BL				;����������
	MOVSB					;[DI]��[SI]�̓��e��߰
	JMP	CP_CHR
CP_CHR2:					;�����ݸ޽�̎�����
	MOV	CL,INTBL.IN_L			;�܂�SPC���
	SUB	CX,BX
	LEA	DI,INTBL.IN_D[BX]
	MOV	AL,SPC
	REP	STOSB
CP_CHR3:					;�����ݸ޽�̍Ō��$���
	MOV	BYTE PTR [DI],'$'
	MOV	DI,BP				;DI���A
	CALL	INP_LOC				;�\��LOCATE���
	CALL	INP_CRT				;��ʕ\��
	XOR	BX,BX
;---------------------------------------------------------------------
;���C���X�^�[�g ���̓��P�[�g�\��

INP_START:
	MOV	AH,INTBL.IN_Y			;۹��Y
	MOV	AL,INTBL.IN_X			;۹��X	
	ADD	AL,BL				;۹��X�ɕ����߼޼����׽
	CALL	LOCATE				;PROC NEAR
;--------------------------------------------------------------------------
;�L�[����

 	MOV	BX_STK,BX			;BIOS CALL
	MOV	CL,18H				;�ꕶ������
	PUSH	ES				;AL=����
	INT	80H				;INT 80H
	POP	ES				;AX,BX,ES�j��
	MOV	BX,BX_STK			;CL=18H
;--------------------------------------------------------------------------
;����R�[�h�W�����v�e�[�u�����[�`��

	MOV	SI,OFFSET KEY_TBL-4		;��ð��� OFFSET
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
	JZ	INP_START
LEFT1:
	DEC	BL				;���ٍ��Ɉړ�
	CMP	INTBL.IN_K[BX],2		;��������2�޲Ėڂ�����
	JNE	LEFT2
	DEC	BL
LEFT2:
	CMP	OP_FLG,BAK_OP_FLG1		;��߼��3,6�ޯ���߰�����
	JZ	BS2
	CMP	OP_FLG,BAK_OP_FLG2
	JZ	BS2
	JMP	INP_START

BS0:						;�a�r��������
	CMP	BL,0				;�P�ԍ��[

	JZ	INP_START
BS1:
	DEC	BL				;���ٍ��Ɉړ�
	CMP	INTBL.IN_K[BX],2		;��������2�޲Ėڂ�����
	JNE	BS2
	DEC	BL
BS2:
	CALL	DEL_1
	JMP	INP_START

RIGHT0:						;���̏���
	CMP	OP_FLG,RIGHT_OP_FLG1		;��߼��3,6�E�ړ��į��
	JZ	RIGHT3
	CMP	OP_FLG,RIGHT_OP_FLG2
	JZ	RIGHT3
	INC	BL
	CMP	INTBL.IN_K[BX],2		;��������2�޲Ėڂ�����
	JZ	RIGHT1
	CMP	BL,INTBL.IN_L
	JNE	RIGHT3
	DEC	BL
	JMP	INP_START
RIGHT1:
	MOV	DL,INTBL.IN_L
	DEC	DL
	CMP	BL,DL				;������2�޲Ă��Ō�
	JNE	RIGHT2
	SUB	BL,2
RIGHT2:
	INC	BL
RIGHT3:
	JMP	INP_START

UP0:
	JMP	INP_END
DOWN0:
	JMP	INP_END

INS0:						;INS�̏���
	CMP	INS_FLG,0			;FLG=0 �ݻ��Ӱ�ސݒ�
	JZ	INS1				;FLG=1 �ݻ��Ӱ�މ���
	MOV	INS_FLG,0
	MOV	DL,1
	MOV	AL,CU_DEF_DOT			;��̫�Ă��ޯĐ�
	MOV	AH,CU_DEF_TOP			;��̫�Ă�į�߈ʒu
	JMP	INS2
INS1:
	MOV	INS_FLG,1			;�ݻ��Ӱ�ސݒ�
	MOV	DL,1
	MOV	AL,CU_DOT			;�����ޯĐ�
	MOV	AH,CU_TOP			;����į�߈ʒu
INS2:
;----------------------------------------------------------------------
	MOV	CL,2BH				;BIOS CALL
	MOV	BX_STK,BX			;���ٌ`��ݒ�
	PUSH	ES				;INT 80H
	INT	80H				;CL=2BH
	POP	ES				;AL=�����ޯĐ�
	MOV	BX,BX_STK			;AH=���ٕ\��į��
	JMP	INP_START			;ES,AX,BX�j��
;----------------------------------------------------------------------
DEL0:						;DEL�̏���
	CALL	DEL_1
	JMP	INP_START
;----------------------------------------------------------------------
;�������͏���

INP_0:
        CMP	AL,CR				;CR����͂�����I��
	JNE	INP_01
	JMP	INP_END
INP_01:
	CMP	AL,NOT_KEYC			;CHAR ���ނ�20H����
	JAE	INP_02
	JMP	INP_START
INP_02:
	CALL	OP_CHK				;��߼������
	CMP	NG,0				;���͐���FLG NG=1 ���͋���
	JZ	INP_1
	CALL	BEEP1
	JMP	INP_START
INP_1:
	CALL	KNJ_CHK				;������������
	CMP	KNJ_CHK_F,1;
	JNE	INP_4				;�������ނ���Ȃ��ꍇ�́AINP_4
	CMP	INTBL.IN_D[BX+1],'$'		;�ּެ���
	JNE	INP_2				;�������ނ�2�޲Ėڂ�����Ȃ�
						;�ꍇ�́ABEFFER �ر�����
 	MOV	BX_STK,BX			;BIOS CALL
	MOV	CL,18H				;INT 80H
	PUSH	ES				;CL=18H
	INT	80H				;AL=����
	POP	ES				;ES,AX,BX�j��
	MOV	BX,BX_STK			;����BUFFER �ر�
	JMP	INP_START
INP_2:
	CMP	INS_FLG,1			;�ݻ��Ӱ�ނ�����
	JNE	INP_3
	CALL	INS_1				;�ݻ��ٰ�ݺ��
INP_3:
	MOV	INTBL.IN_D[BX],AL		;�������ޓ��͏���
	MOV	INTBL.IN_K[BX],1		;1�޲Ėھ�ď���
 	MOV	BX_STK,BX			;BIOS CALL
	MOV	CL,18H				;INT 80H
	PUSH	ES				;CL=18H
	INT	80H				;AL=����
	POP	ES				;ES,AX,BX�j��
	MOV	BX,BX_STK			;����BEFFER 2�޲Ėڎ擾
	MOV	INTBL.IN_D[BX+1],AL		;2�޲Ėھ�ď���
	MOV	INTBL.IN_K[BX+1],2
	CMP	INTBL.IN_D[BX+2],'$'		;���͌㎟�̶����߼޼������
	JZ	INP_6				;�����߼޼�݂��ݸ޽�̍Ō�
	ADD	BL,2				;��������INP_6 �ּެ���
	JMP	INP_6				;NOT ���������߼޼�ݐݒ�
INP_4:
	CMP	INS_FLG,1			;���p����ٰ��
	JNE	INP_5				;�ݻ��Ӱ������
	CALL	INS_1				;�ݻ��ٰ�ݺ��
INP_5:
	MOV	INTBL.IN_D[BX],AL		;���޾��
	MOV	INTBL.IN_K[BX],0		;����FLG�ر�
	CMP	INTBL.IN_D[BX+1],'$'		;���̶����߼޼������
	JZ	INP_6				;�����߼޼�݂��ݸ޽�̍Ō�
						;�������� INP_6 �ּެ���
	INC	BL				; NOT ���������߼޼�ݐݒ�
INP_6:
	CMP	INS_FLG,1			;�����߼޼�݂̏������菈��
	JZ	INP_7
	CMP	INTBL.IN_K[BX],2		;�����߼޼�݂�������2�޲Ė�
	JNE	INP_7				;�������ꍇ�͊���ð��ق�ر�
	MOV	INTBL.IN_K[BX],0		;������SPC���
	MOV	INTBL.IN_D[BX],SPC
INP_7:
	CALL	INP_LOC				;�\��LOCATE���
	CALL	INP_CRT				;��ʕ\��
	JMP	INP_START			;���̓��C����
;------------------------------------------------------------------------
;���͏I��

INP_END:
	MOV	BYTE PTR QZ,AL			;�����o���R�[�h
	MOV	DL,1				;BIOS CALL
	MOV	AL,CU_DEF_DOT			;INT 80H
	MOV	AH,CU_DEF_TOP			;���ٌ`������ɖ߂�
	MOV	CL,2BH				;CL=2BH
	PUSH	ES				;ES,AX,BX�j��
	INT	80H
;-------------------------------------------------------------------------
	MOV	CL,69H				;BIOS CALL
	MOV	AH,1				;INT 80H
	MOV	DX,KM_6	         		;CL=69H	
	INT	80H				;��Ӱ�ޏ����l�ɖ߂�
;-------------------------------------------------------------------------
	MOV	CL,0BH				;BIOS CALL
	MOV	BL,0				;INT 83H
	INT	83H				;CL=0BH
	POP	ES				;FEP �I��
	MOV	DX,DX_SAVE
	MOV	DI,OFFSET INTBL.IN_D
	MOV	AL,BYTE PTR QZ

	RET					;INPUT ٰ�ݏI��
;-------------------------------------------------------------------------
;************************
;*	���ٰ��		*
;************************

INP_LOC	PROC	NEAR				;����LOCATE 	ٰ��
	MOV	AH,INTBL.IN_Y
	MOV	AL,INTBL.IN_X
	CALL	LOCATE
	RET
INP_LOC	ENDP

INP_CRT	PROC	NEAR				;��ʕ\��	ٰ��
	MOV	BX_STK,BX
	MOV	CL,0D7H				;BIOS CALL
	MOV	DX,OFFSET INTBL.IN_D		;INT 80H
	PUSH	ES				;CL=0D7H
	INT	80H				;'$'�܂ŕ\��
	POP	ES
	MOV	BX,BX_STK
	RET
INP_CRT	ENDP

BEEP1	PROC	NEAR				;�ް�߉�����	ٰ��
	DISPLAY_CHAR	BEEP			;FUNCTION 02H
	RET					;MDOS.H
BEEP1	ENDP

INS_1	PROC	NEAR				;INS����	ٰ��
	MOV	INP_COUNT,BL			;�����߼޼�ݑޔ�
	MOV	CL,INTBL.IN_L			;�������ݸ޽�擾
	SUB	CL,BL				;�ݸ޽�Ɠ��͐��̍�
	MOV	CL_STK,CL			;�į�
	MOV	BL,INTBL.IN_L			;��납��ړ�
	LEA	DI,INTBL.IN_K[BX-1]		;�ړ���̱��ڽ�擾
	MOV	DI_STK,DI			;�į�(����ð���)
	LEA	DI,INTBL.IN_D[BX-1]		;�ړ���̱��ڽ�擾
	CMP	KNJ_CHK_F,1			;�������ނ�����
	JNE	INS_2				;��������Ȃ����̔�ѐ�
	DEC	BL				;
	DEC	CL
	MOV	CL_STK,CL
INS_2:
	LEA	SI,INTBL.IN_K[BX-2]		;�ړ����̱��ڽ�擾
	MOV	SI_STK,SI			;�į�(����ð���)
	LEA	SI,INTBL.IN_D[BX-2]		;�ړ����̱��ڽ�擾
	STD					;�ިڸ��� FLG ���
	REP	MOVSB				;[SI]��[DI]��߰
	MOV	DI,DI_STK			;CX����s
	MOV	SI,SI_STK
	MOV	CL,CL_STK
	REP	MOVSB
	MOV	BL,INTBL.IN_L
	CMP	INTBL.IN_K[BX-1],1
	JNE	INS_3
	MOV	INTBL.IN_D[BX-1],SPC
	MOV	INTBL.IN_K[BX-1],0
INS_3:
	MOV	BL,INP_COUNT
	MOV	DI,BP
	CLD
	RET
INS_1	ENDP

DEL_1	PROC	NEAR				;DEL����	ٰ��
	MOV	DEL_SPC,0
	MOV	INP_COUNT,BL
	MOV	CL,INTBL.IN_L
	SUB	CL,BL
	MOV	CL_STK,CL
	LEA	DI,INTBL.IN_K[BX]
	MOV	DI_STK,DI
	LEA	DI,INTBL.IN_D[BX]
	CMP	INTBL.IN_K[BX],1
	JNE	DEL_2
	DEC	CL
	MOV	CL_STK,CL
	INC	BL
	MOV	DEL_SPC,1
	CMP	INTBL.IN_D[BX-1],'$'
	JZ	DEL_3
DEL_2:
	LEA	SI,INTBL.IN_K[BX+1]
	MOV	SI_STK,SI
	LEA	SI,INTBL.IN_D[BX+1]
	REP	MOVSB
	MOV	SI,SI_STK
	MOV	DI,DI_STK
	MOV	CL,CL_STK
	REP	MOVSB
DEL_3:
	MOV	BL,INTBL.IN_L
	MOV	INTBL.IN_D[BX-1],SPC
	MOV	INTBL.IN_K[BX-1],0
	CMP	DEL_SPC,0
	JZ	DEL_4
	MOV	INTBL.IN_D[BX-2],SPC
	MOV	INTBL.IN_K[BX-2],0
DEL_4:
	CALL	INP_LOC
	CALL	INP_CRT
	MOV	BL,INP_COUNT
	RET
DEL_1	ENDP

OP_CHK	PROC	NEAR				;�I�v�V����	ٰ��
	MOV	NG,0
	CALL	KNJ_CHK
	MOV	AL_STK,AL

	MOV	SI,OFFSET OP_TBL-4		;��߼��ð��� OFFSET
OP_C:	ADD	SI,4				;
	CMP	BYTE PTR [SI],0FFH		;��ð��ٍŌ�
	JZ	OP_EXIT
	MOV	AL,OP_FLG
	CMP	AL,[SI]				;�����ޔ�r
	MOV	AL,AL_STK
	JNZ	OP_C
	JMP	[SI+2]				;ð��ټެ���

OP_6:
OP_5:						;��߼��6 �����̂�
	CMP	KNJ_CHK_F,1			;��߼��5 �����̂�
	JZ	OP_CHK_NG			;���ނ���������
	CMP	AL,30H				;���ނ�"1"��菬����
	JB	OP_CHK_NG
	CMP	AL,39H				;���ނ�"9"���傫��
	JA	OP_CHK_NG
	JMP	OP_EXIT

OP_4:						;��߼��4 ���p�̂�
	CMP	KNJ_CHK_F,1			;���ނ���������
	JZ	OP_CHK_NG
	JMP	OP_EXIT

OP_3:						;��߼��3 �ł̂�
OP_2:						;��߼��2 �ł̂�
	CMP	KNJ_CHK_F,1			;���ނ���������
	JZ	OP_CHK_NG
	CMP	AL,0A0H				;���ނ� "�"��菬����
	JB	OP_CHK_NG
	CMP	AL,0DFH				;���ނ� "�"���傫��
	JA	OP_CHK_NG
	JMP	OP_EXIT

OP_1:						;��߼��1 �S�p�̂�
	CMP	KNJ_CHK_F,1			;���ނ���������
	JZ	OP_EXIT

OP_CHK_NG:
 	CMP	KNJ_CHK_F,1			;��߼�݂̎w�肪�������󂯕t��
						;�Ȃ�Ӱ�ނ������緰�ޯ̧�ر�
	JNE	OP_CHK_NG1
	MOV	BX_STK,BX			;BIOS CALL
	MOV	CL,18H				;INT 80H
	PUSH	ES				;CL=18H
	INT	80H				;���޲ē���
	POP	ES				;BX,ES�j��
	MOV	BX,BX_STK
OP_CHK_NG1:
	MOV	NG,1
OP_EXIT:
	RET
OP_CHK	ENDP

KNJ_CHK	PROC	NEAR				;������������	ٰ��
	MOV	KNJ_CHK_F,0
	CMP	AL,80H
	JB	KNJ_EXIT
	CMP	AL,9FH
	JA	KNJ_CHK2
	MOV	KNJ_CHK_F,1
	JMP	KNJ_EXIT
KNJ_CHK2:
	CMP	AL,0E0H
	JB	KNJ_EXIT
	CMP	AL,0FFH
	JA	KNJ_EXIT
	MOV	KNJ_CHK_F,1
KNJ_EXIT:
	RET
KNJ_CHK	ENDP

K_MODE	PROC	NEAR				;��Ӱ��		ٰ��
	MOV	BX_STK,BX
	MOV	AH,0
	MOV	CL,69H
	PUSH	ES
	INT	80H
	MOV	K_STK,AX
	CMP	OP_FLG,0
	JZ	K_EXIT
	CMP	OP_FLG,4
	JB	_M1
	MOV	DX,KM_4
	JMP	K_SET
_M1:	CMP	OP_FLG,1
	JZ	_M2
	MOV	DX,KM_2
	JMP	K_SET
_M2:	MOV	DX,KM_1
K_SET:	MOV	AH,1
	MOV	CL,69H
	INT	80H
K_EXIT:	POP	ES
	MOV	BX,BX_STK
	RET
K_MODE	ENDP

FEP	PROC	NEAR				;FEP		ٰ��
	MOV	CL,0EH				;FEP�N��,�����ݒ�
	INT	83H
	MOV	FEP_D,AL			;����Ӱ�ޑޔ�
	CMP	FEP_S,1				;FEP����
	JNE	FEP_EXIT
	MOV	CL,0BH
	MOV	BL,1
	INT	83H
FEP_EXIT:
	RET
FEP	ENDP

INP_STR	STRUC
	IN_Y	DB	0			;����۹��Y
	IN_X	DB	0			;����۹��X
	IN_L	DB	0			;���͐�
	IN_D	DB	80	DUP(0)		;�ް��i�[�̈�
	IN_K	DB	80	DUP(0)		;��������FLG
INP_STR	ENDS
INTBL	INP_STR	<,,,,>				;������

DX_SAVE		DW	0			;DX�ޔ�̈�
INP_COUNT	DB	0			;���͕������ޔ�̈�
AL_STK		DB	0			;AL�ޔ�̈�
BX_STK		DW	0			;BX�ޔ�̈�
CL_STK		DB	0			;CL�ޔ�̈�
SI_STK		DW	0			;SI�ޔ�̈�
DI_STK		DW	0			;DI�ޔ�̈�
INS_FLG		DB	0			;�ݻ��Ӱ��FLG
KNJ_CHK_F	DB	0			;������������FLG
DEL_SPC		DB	0			;�ްذ�ٰ�� ܰ�FLG
OP_FLG		DB	0			;�@�\����
NG		DB	0			;���͐�������FLG
K_STK		DW	0			;��Ӱ�ޑޔ�̈�
FEP_D		DB	0			;FEPӰ�ޑޔ�̈�
FEP_S		DB	0			;FEPӰ�޽���
QZ		DB	0			;�����o���R�[�h
KM_1		DW	0A400H			;�S�p
KM_2		DW	1400H			;����
KM_3		DW	1400H			;����
KM_4		DW	8400H			;ۯ�
KM_5		DW	8400H			;ۯ�
KM_6		DW	8400H			;ۯ�
;
;		�ެ���ð���
;			���ށ@JMP��
KEY_TBL		DW	0008H,LEFT0		;BS,��
		DW	000CH,RIGHT0		;��
		DW	0012H,INS0		;�ݻ�� 	INS
		DW	007FH,DEL0		;��ذ�	DEL
		DW	000BH,UP0		;��
		DW	000AH,DOWN0		;��
		DB	0FFH   			;EXIT

;
;		�ެ���ð���
;			���ށ@JMP��
OP_TBL		DW	0001H,OP_1		;��߼��1
		DW	0002H,OP_2		;��߼��2
		DW	0003H,OP_3		;��߼��3
		DW	0004H,OP_4		;��߼��4
		DW	0005H,OP_5		;��߼��5
		DW	0006H,OP_6		;��߼��6
		DB	0FFH   			;EXIT

INPUT	ENDP
CODE	ENDS
	END

