INCLUDE	MDOS.H
INCLUDE	STD.H
INCLUDE	UTY.H
INCLUDE	MACRO.H


MSGY	EQU	0
MSGX	EQU	0

CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE

	ORG	100H

START:		
                                     
		;INPUT_M	MACRO	LY,LX,STRING,COUNT,OP,FEP
		;LOCATE_M	MACRO	LY,LX
		;COLOR_M	MACRO	FGC,BGC,FG,P

		COLOR_M		1,7,1,0	;FG=�� BG=�� �g��=BG,��
		DISPLAY_CHAR	CLS

		COLOR_M		7,2,0,1	;FG=�� BG=�� �g��=FG,��
		LOCATE_M	1,26
		DISPLAY		TITLE0

NEXT:
		

		COLOR_M		7,4,1,1	;FG=�� BG=�� �g��=BG,��
		COLOR_M		7,4,0,0	;FG=�� BG=�� �g��=FG,��
		LOCATE_M	8,10
		DISPLAY		GAMEN0
		LOCATE_M	9,10
		DISPLAY		GAMEN1
		LOCATE_M	10,10
		DISPLAY		GAMEN2
		LOCATE_M	11,10
		DISPLAY		GAMEN3
		LOCATE_M	12,10
		DISPLAY		GAMEN4
		LOCATE_M	13,10
		DISPLAY		GAMEN5
				

MSG_INP:	LOCATE_M	24,0
		COLOR_M		6,0,0,0
		DISPLAY		MSG5
		DIR_CONSOLE_INPUT
		CMP	AL,CR
		JZ	MSG_EXIT
		MOV	END_C,1
		CMP	AL,"*"
		JZ	EXIT
		DISPLAY_CHAR	BEEP
		JMP	SHORT	MSG_INP
MSG_EXIT:
		COLOR_M		1,7,1,0
		LOCATE_M	24,5
		DISPLAY		MSG5_CLS
		MOV	END_C,0

EXIT:
		COLOR_M		1,7,1,0	;FG=�� BG=�� �g��=BG,��
		DISPLAY_CHAR	CLS

		END_PROCESS END_C


TITLE0	DB	"��  �^�s�Ǘ��Ɩ��ύX����  ��"
	DB	"$"
     
GAMEN0	DB "�X�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�Z",CR,LF
DB	"$" 
GAMEN1	DB "�a �� ������^�s�Ǘ��Ɩ��̃v���O�����̏C�������s���܂� �� �a",CR,LF
DB	"$" 
GAMEN2	DB "�a                                                        �a",CR,LF
DB	"$" 
GAMEN3	DB "�a  �Q�Ԃɉ^�s�Ǘ��Ɩ��v���O�������{���Z�b�g���Ă�������  �a",CR,LF
DB	"$" 
GAMEN4	DB "�a                                                        �a",CR,LF
DB	"$" 
GAMEN5	DB "�^�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�`",CR,LF
DB	"$" 

MSG5	DB	"�t���b�s�[�̃Z�b�g���ł�����k�b�q�l�L�[�������ĉ������B  ���~�̎��ͥ���k���l  "
	DB	"$"
MSG5_CLS	DB	"                                                           "
	DB	"$"
END_C	DB	0

CODE	ENDS
	END	START
