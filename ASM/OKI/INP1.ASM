INCLUDE	MDOS.H
INCLUDE	STD.H
INCLUDE	UTY.H
INCLUDE	MACRO.H
INCLUDE	BIOS.H

	;INPUT_M	MACRO	HY,HX,STRING,COUNT,OP,FEP
	;INPUT1_M       MACRO	STRING,HY,HX,QZ,OP,C1,C2,C3,C4,S
	;LOCATE_M	MACRO	HY,HX
	;COLOR_M	MACRO	FGC,BGC,FG,BG


K_MODE	EQU     8400H		;��Ӱ����̫��
CLS_SP	EQU	20H		;�ر���߰�
K_SPC	EQU	15		;�\���J�n�ʒu��߰�

K_CODE	EQU	 6		;����	����
K_NAME	EQU	40		;��	����
K_FURI	EQU	40		;�ض��	����
K_ADD	EQU	40		;�Z��	����
K_TEL	EQU	12		;TEL	����

MG_HY	EQU	 0		;ү����	۹��Y
MG_HX	EQU	 0		;ү����	۹��X
MG_FGC	EQU	 6		;ү����	̫���װ
MG_BGC	EQU	 0		;ү����	�ޯ��װ
MG_FG	EQU	 0		;ү����	̫���g���װ
MG_BG	EQU	 0		;ү����	�ޯ��g���װ

DG_FGC	EQU	 0		;�ް�	̫���װ
DG_BGC	EQU	 7		;�ް�  	�ޯ��װ
DG_FG	EQU	 0		;�ް�  	̫���g���װ
DG_BG	EQU	 0		;�ް�  	�ޯ��g���װ

SG_FGC	EQU	 1		;�������	̫���װ
SG_BGC	EQU	 7		;�������	�ޯ��װ
SG_FG	EQU	 0		;�������	̫���g���װ
SG_BG	EQU	 0		;�������	�ޯ��g���װ
SG_HY	EQU	 5		;�������	۹��Y
SG_HX	EQU	 0		;�������	۹��X

TI_FGC	EQU	 7		;����	̫���װ
TI_BGC	EQU	 2		;����	�ޯ��װ
TI_FG	EQU	 0		;����	̫���g���װ
TI_BG	EQU	 0 		;����	�ޯ��g���װ
TI_HY	EQU	 1		;����	۹��Y
TI_HX	EQU	26		;����	۹��X

N1_HX	EQU	26		;���ڂP	۹��X
N1_HY	EQU	 5		;���ڂP ۹��Y
N1_QZ	EQU	 0		;���ڂP 
N1_OP	EQU	 1		;���ڂP	��߼��FLG
N1_C1	EQU	 1		;���ڂP ̫���װ
N1_C2	EQU	 7		;���ڂP	�ޯ��װ
N1_C3	EQU	 0		;���ڂP ̫���g���װ 
N1_C4	EQU	 1		;���ڂP	�ޯ��g���װ
N1_S	EQU	 0		;���ڂP	���گ�FLG

N2_HX	EQU	26		;���ڂP	۹��X
N2_HY	EQU	 7		;���ڂP ۹��Y
N2_QZ	EQU	 0		;���ڂP 
N2_OP	EQU	 3		;���ڂP	��߼��FLG
N2_C1	EQU	 1		;���ڂP ̫���װ
N2_C2	EQU	 7		;���ڂP	�ޯ��װ
N2_C3	EQU	 0		;���ڂP ̫���g���װ 
N2_C4	EQU	 1		;���ڂP	�ޯ��g���װ
N2_S	EQU	 0		;���ڂP	���گ�FLG

N3_HX	EQU	26		;���ڂP	۹��X
N3_HY	EQU	 9		;���ڂP ۹��Y
N3_QZ	EQU	 0		;���ڂP 
N3_OP	EQU	 8		;���ڂP	��߼��FLG
N3_C1	EQU	 1		;���ڂP ̫���װ
N3_C2	EQU	 7		;���ڂP	�ޯ��װ
N3_C3	EQU	 0		;���ڂP ̫���g���װ 
N3_C4	EQU	 1		;���ڂP	�ޯ��g���װ
N3_S	EQU	 0		;���ڂP	���گ�FLG

N4_HX	EQU	26		;���ڂP	۹��X
N4_HY	EQU	11		;���ڂP ۹��Y
N4_QZ	EQU	 0		;���ڂP 
N4_OP	EQU	 3		;���ڂP	��߼��FLG
N4_C1	EQU	 1		;���ڂP ̫���װ
N4_C2	EQU	 7		;���ڂP	�ޯ��װ
N4_C3	EQU	 0		;���ڂP ̫���g���װ 
N4_C4	EQU	 1		;���ڂP	�ޯ��g���װ
N4_S	EQU	 0		;���ڂP	���گ�FLG

N5_HX	EQU	26		;���ڂP	۹��X
N5_HY	EQU	13		;���ڂP ۹��Y
N5_QZ	EQU	 0		;���ڂP 
N5_OP	EQU	 2		;���ڂP	��߼��FLG
N5_C1	EQU	 1		;���ڂP ̫���װ
N5_C2	EQU	 7		;���ڂP	�ޯ��װ
N5_C3	EQU	 0		;���ڂP ̫���g���װ 
N5_C4	EQU	 1		;���ڂP	�ޯ��g���װ
N5_S	EQU	 0		;���ڂP	���گ�FLG

CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE

	ORG	100H

START:
	JMP	MAIN

TITLE0	DB	"��  �T���v���v���O����  ��"
	DB	"$"
     
GAMEN	DB 	K_SPC	DUP(20H)
	DB	"�ڋq�R�[�h["
	DB	K_CODE	DUP(20H)
	DB	"]",CR,LF
	DB	CR,LF

	DB 	K_SPC	DUP(20H)
	DB	"�ڋq��    ["
	DB	K_NAME	DUP(20H)
	DB	"]",CR,LF
	DB	CR,LF

	DB 	K_SPC	DUP(20H)
	DB	"�t���K�i  ["
	DB	K_FURI	DUP(20H)
	DB	"]",CR,LF
	DB	CR,LF

	DB 	K_SPC	DUP(20H)
	DB	"�Z��      ["
	DB	K_ADD	DUP(20H)
	DB	"]",CR,LF
	DB	CR,LF

	DB 	K_SPC	DUP(20H)
	DB	"�d�b�ԍ�  ["
	DB	K_TEL	DUP(20H)
	DB	"]",CR,LF
	DB	"$" 

MSG0	DB	"�ڋq�R�[�h����   �U��  "
	DB	"$"
MSG1	DB	'�ڋq������     �Q�O����'
	DB	"$"
MSG2	DB	'�t���K�i����   �S�O����'
	DB	"$"
MSG3	DB	'�Z������       �Q�O����'
	DB	"$"
MSG4	DB	"�d�b�ԍ�����   �P�O��  "
	DB	"$"
MSG5	DB	"�C���͂���܂����H  �C�����襥��k�m��.�l   �C���Ȃ�����k�O�l  �I������k���l"
	DB	"$"
MSG5_CLS	DB	"                                                                             "
	DB	"$"


;�i�[�G���A

I_DATA1	DB 	K_CODE	DUP(20H)
	DB	0
I_DATA2	DB	K_NAME	DUP(20H)
	DB	0
I_DATA3	DB	K_FURI	DUP(20H)
	DB	0
I_DATA4	DB	K_ADD	DUP(20H)
	DB	0
I_DATA5	DB	K_TEL	DUP(20H)
	DB	0
QZ	DB	0


;��ʃN���A�[
CLEAR_SUB	PROC
		COLOR_M		SG_FGC,SG_BGC,SG_FG,SG_BG
		DISPLAY_CHAR	CLS
		RET
CLEAR_SUB	ENDP

;�^�C�g���\��
TITLE_SUB	PROC
		COLOR_M		TI_FGC,TI_BGC,TI_FG,TI_BG
		LOCATE_M	TI_HY,TI_HX
		DISPLAY		TITLE0
		RET
TITLE_SUB	ENDP

;������ʕ\��
GAMEN_SUB	PROC
		COLOR_M		SG_FGC,SG_BGC,SG_FG,SG_BG
		LOCATE_M	SG_HY,SG_HX
		DISPLAY		GAMEN
		RET
GAMEN_SUB	ENDP

;�i�[�G���A������
CLEAR_SUB1	PROC
		MOV	AL,CLS_SP
		MOV	DI,OFFSET I_DATA1
		MOV	CX,K_CODE
	REP	STOSB
		MOV	DI,OFFSET I_DATA2
		MOV	CX,K_NAME
	REP	STOSB
		MOV	DI,OFFSET I_DATA3
		MOV	CX,K_FURI
	REP	STOSB
		MOV	DI,OFFSET I_DATA4
		MOV	CX,K_ADD
	REP	STOSB
		MOV	DI,OFFSET I_DATA5
		MOV	CX,K_TEL
	REP	STOSB
		RET
CLEAR_SUB1	ENDP

;���b�Z�[�W�\��
MGDISP_M	MACRO	STRING
		COLOR_M		MG_FGC,MG_BGC,MG_FG,MG_BG
		LOCATE_M	MG_HY,MG_HX
		DISPLAY		STRING
		ENDM

;�f�[�^�\��
DDISP_M		MACRO	DY,DX,STRING
		COLOR_M		DG_FGC,DG_BGC,DG_FG,DG_BG
		LOCATE_M	DY,DX
		BIOS_D7		STRING
		ENDM

;�ڋq�R�[�h
NY1_SUB	PROC
		MGDISP_M	MSG0
		INPUT1_M 	I_DATA1,N1_HX,N1_HY,N1_QZ,N1_OP,N1_C1,N1_C2,N1_C3,N1_C4,N1_S
		MOV	QZ,AL
		DDISP_M		N1_HY,N1_HX,I_DATA1
		RET
NY1_SUB	ENDP

;�ڋq������
NY2_SUB	PROC
		MGDISP_M        MSG1
		INPUT1_M 	I_DATA2,N2_HX,N2_HY,N2_QZ,N2_OP,N2_C1,N2_C2,N2_C3,N2_C4,N2_S
		MOV	QZ,AL
		DDISP_M		N2_HY,N2_HX,I_DATA2
		RET
NY2_SUB	ENDP

;�t���K�i����
NY3_SUB	PROC
		MGDISP_M        MSG2
		INPUT1_M 	I_DATA3,N3_HX,N3_HY,N3_QZ,N3_OP,N3_C1,N3_C2,N3_C3,N3_C4,N3_S
		MOV	QZ,AL
		DDISP_M		N3_HY,N3_HX,I_DATA3
		RET
NY3_SUB	ENDP

;�Z������
NY4_SUB	PROC
		MGDISP_M        MSG3
		INPUT1_M 	I_DATA4,N4_HX,N4_HY,N4_QZ,N4_OP,N4_C1,N4_C2,N4_C3,N4_C4,N4_S
		MOV	QZ,AL
		DDISP_M		N4_HY,N4_HX,I_DATA4
		RET
NY4_SUB	ENDP

;�d�b�ԍ�����
NY5_SUB	PROC
		MGDISP_M        MSG4
		INPUT1_M 	I_DATA5,N5_HX,N5_HY,N5_QZ,N5_OP,N5_C1,N5_C2,N5_C3,N5_C4,N5_S
		MOV	QZ,AL
		DDISP_M		N5_HY,N5_HX,I_DATA5
		RET
NY5_SUB	ENDP


;�W�����v�e�[�u��

JMP_TBL		DW	0,NY1_SUB,NY2_SUB,NY3_SUB,NY4_SUB,NY5_SUB

MAIN:

		CALL	CLEAR_SUB	;��ʏ�����
		CALL	TITLE_SUB	;�^�C�g���\��

NY_START:
		CALL	GAMEN_SUB	;������ʕ\��
		CALL	CLEAR_SUB1	;�f�[�^�N���A�[

;����
NY1:
NY1_1:		CALL	NY1_SUB		;�ڋq�R�[�h����
		CMP	QZ,0BH
		JNE	NEXT_1
		JMP	NY1_1
NEXT_1:

;��
NY2:
NY2_1:		CALL	NY2_SUB		;�ڋq������
		CMP	QZ,0BH
		JNE	NEXT_2
		JMP	NY1_1
NEXT_2:

;�J�i
NY3:
NY3_1:		CALL	NY3_SUB		;�ڋq�J�i����
		CMP	QZ,0BH
		JNE	NEXT_3
		JMP	NY2_1
NEXT_3:

;�Z��
NY4:
NY4_1:		CALL	NY4_SUB		;�Z������
		CMP	QZ,0BH
		JNE	NEXT_4
		JMP	NY3_1
NEXT_4:

;TEL
NY5:
NY5_1:		CALL	NY5_SUB		;�d�b�ԍ�����
		CMP	QZ,0BH
		JNE	NEXT_5
		JMP	NY4_1
NEXT_5:

;Ұ�����

MSG_INP:	LOCATE_M	24,1
		COLOR_M		6,0,1,1
		DISPLAY		MSG5
		KBD_MODE_S	K_MODE
		DIR_CONSOLE_INPUT

		CMP	AL,"0"
		JNE	MSG_INP1
		JMP	MSG_EXIT
MSG_INP1:
		CMP	AL,"*"
		JNE	MSG_INP2
		JMP	EXIT
MSG_INP2:
		CMP	AL,"0"
		JB	MSG_INP3
		CMP	AL,"5"
		JBE	JMP_T
MSG_INP3:
		DISPLAY_CHAR	BEEP
		DISPLAY_CHAR	BEEP
		DISPLAY_CHAR	BEEP
		JMP	MSG_INP

JMP_T:
		SUB	AL,30H
		XOR	BX,BX
		ADD	BL,AL
		ADD	BL,AL
		MOV	SI,OFFSET JMP_TBL
		COLOR_M		1,7,1,0
		LOCATE_M	24,1
		DISPLAY		MSG5_CLS
		CALL	WORD PTR [SI+BX]
		JMP	MSG_INP

MSG_EXIT:
		COLOR_M		1,7,1,0
		LOCATE_M	24,1
		DISPLAY		MSG5_CLS
		JMP	NY_START

EXIT:
		COLOR_M		7,0,0,0
		DISPLAY_CHAR	CLS
		END_PROCESS 0

CODE	ENDS
	END	START
