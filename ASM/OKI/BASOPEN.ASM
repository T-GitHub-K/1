;-----------------------------------------------------------------------------
;   OBASIC CALL  ������ ٰ��
;
;   ̧�ف@OPEN հè�è�
;
;   CALL OPEN(̧��Ȱ�,̧��No,����Ӱ��,�ð��FLG)
;
;   ����Ӱ��     0����READ
;                1����WRITE
;                2����READ/WRITE
;
;  �װ�ð��
;
;		99	ERR_PARA	���Ұ���װ
;		98	ERR_OPN		����ݴװ
;		97	ERR_MAKE	;Ҳ��װ
;
; BASIC BLOAD ADD
;              BLOAD &HF000  �ɌŒ� 
;
;
;-----------------------------------------------------------------------------

INCLUDE	MDOS.H
INCLUDE	MACRO.H
INCLUDE	STD.H

L_ADD		EQU	0F000H		;BLOAD address = DS:F000
OFSET		EQU	L_ADD-7


PARA_OP	STRUC				;�X�^�b�N��n�e�[�u��
	BP_SV	DW	?		;BP�ޔ�
	R_ADD	DD	?		;RETURN	ADD
	ST_P	DW	?		;�ð��FLG
	AC_P	DW	?		;����Ӱ��
	NO_P	DW	?		;FILE No
	FN_P	DW	?		;FILE NAME
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

;----------------------------------------------------------------------

		MOV	BX,[BP].AC_P	;����Ӱ�ރA�h���X�擾
		MOV	AX,[BX]		;����Ӱ�ނ̒��g
		MOV	AC_M[OFSET],AL	;AL=0���READӰ��
		CMP	AL,3		;AL=1���WRITEӰ��
		JB	NEXT_PARA	;AL=2���READ/WRITE

         	MOV	AL,ERR_PARA	;�װ����
		JMP	EXIT
;-----------------------------------------------------------------------

NEXT_PARA:
		MOV	BX,[BP].NO_P	;̧��NO�̃A�h���X�擾
		MOV	AX,[BX]		;̧��NO�̒��g
		MOV	FILE_NO[OFSET],AX
;-----------------------------------------------------------------------
		XOR	CX,CX
		MOV	BX,[BP].FN_P		;̧�ٖ� 
		MOV	CL,[BX]			;̧�ٖ��̒���
		MOV	SI,[BX+1]		;̧�ٖ��̃A�h���X
;-----------------------------------------------------------------------
PARA_COPY:
		CLD
		MOV	DI,OFFSET FILE_NAM[OFSET]
		REP	MOVSB
		MOV	BYTE PTR [DI],NUL
;------------------------------------------------------------------------
OPEN_FILE:
		MOV	DX,OFFSET FILE_NAM[OFSET]
		MOV	AL,AC_M[OFSET]			;����Ӱ��
		MOV	AH,3DH
		INT	21H

		JC	OPEN_CHK
		MOV	FILE_NO[OFSET],AX
		JMP	EXIT

OPEN_CHK:
		CMP	AX,02H				;̧�ٖ������݂��Ȃ�
		JZ	MAKE_FILE

		MOV	AL,ERR_OPN			;�װ����
		JMP	SHORT EXIT

MAKE_FILE:
		MOV	DX,OFFSET FILE_NAM[OFSET]
		MOV	CX,0				;̧�ّ���
		MOV	AH,3CH
		INT	21H

		JC	MAKE_ERR
		MOV	FILE_NO[OFSET],AX
		JMP	SHORT EXIT

MAKE_ERR:
		MOV	AX,ERR_MAKE			;�װ����

EXIT:
		MOV	BX,[BP].ST_P	;�ð��FLG���
		MOV	[BX],AX

		MOV	AX,FILE_NO[OFSET]
		MOV	BX,[BP].NO_P	;̧��NO���
		MOV	[BX],AX
		POPA
        	POP	BP

		RET	8
;--------------------------------------------------------------------------

FILE_NAM	DB	60	DUP(0)			;̧�ٖ��ر
AC_M		DB	0				;����Ӱ��
FILE_NO		DW	0				;̧��NO
;-------------------------------------------------------------------------

ERR_PARA	EQU	99				;���Ұ���װ
ERR_OPN		EQU	98				;����ݴװ
ERR_MAKE	EQU	97				;Ҳ��װ


MAIN	ENDP
endp	EQU	$

CODE		ENDS
		END
