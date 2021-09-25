;-----------------------------------------------------------------------------
;   OBASIC CALL  ������ ٰ��
;
;   ̧�ف@CLOSE հè�è�
;
;   CALL CLOSE(̧��No,�ð��FLG)
;
;  �װ�ð��
;
;		99	ERR_PARA	���Ұ���װ
;		98	ERR_CLOSE	�۰�޴װ
;
; BASIC BLOAD ADD
;              BLOAD &HF100  �ɌŒ� 
;
;
;-----------------------------------------------------------------------------


INCLUDE	MDOS.H
INCLUDE	MACRO.H
INCLUDE	STD.H

L_ADD		EQU	0F100H		;BLOAD address = DS:F100
OFSET		EQU	L_ADD-7


PARA_OP	STRUC				;�X�^�b�N��n�e�[�u��
	BP_SV	DW	?		;BP�ޔ�
	R_ADD	DD	?		;RETURN	ADD
	ST_P	DW	?		;�ð��FLG
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
;-----------------------------------------------------------------------
		
		MOV	BX,[BP].NO_P	;̧��NO�̃A�h���X�擾
		MOV	AX,[BX]		;̧��NO�̒��g
		MOV	FILE_NO[OFSET],AX
		CMP	AX,0
		JNE	CLOSE_FILE

		MOV	AX,ERR_PARA	;�װ����
		JMP	EXIT

;-----------------------------------------------------------------------

CLOSE_FILE:
		MOV	BX,FILE_NO[OFSET]
		MOV	AH,3EH
		INT	21H

		JC	CLOSE_ERR
		MOV	AX,0
		JMP	EXIT

CLOSE_ERR:
		MOV	AX,ERR_CLOSE	;�װ����

EXIT:
		MOV	BX,[BP].ST_P	;�ð�����
		MOV	[BX],AX
		POPA
        	POP	BP

		RET	4

;---------------------------------------------------------------------------
FILE_NO		DW	0
;--------------------------------------------------------------------------
ERR_PARA	EQU	99			;��װҰ���װ
ERR_CLOSE	EQU	98			;�۰�޴װ


MAIN	ENDP
endp	EQU	$

CODE		ENDS
		END
