INCLUDE	MDOS.H
INCLUDE	STD.H
INCLUDE	UTY.H
INCLUDE	MACRO.H

WAIT_DT		EQU	1

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
		MOV	DX,OFFSET TITLE0
		CALL	INP_CRT



NEXT:
		COLOR_M		7,2,1,0	;FG=�� BG=�� �g��=BG,��
		COLOR_M		7,2,0,0	;FG=�� BG=�� �g��=FG,��
		LOCATE_M	8,10
		MOV	DX,OFFSET GAMEN0
		CALL	INP_CRT
		LOCATE_M	9,10
		MOV	DX,OFFSET GAMEN1
		CALL	INP_CRT
		LOCATE_M	10,10
		MOV	DX,OFFSET GAMEN2
		CALL	INP_CRT
		LOCATE_M	11,10
		MOV	DX,OFFSET GAMEN3
		CALL	INP_CRT
		LOCATE_M	12,10
		MOV	DX,OFFSET GAMEN4
		CALL	INP_CRT
		LOCATE_M	13,10
		MOV	DX,OFFSET GAMEN5
		CALL	INP_CRT
		

MSG_INP:	
		DISPLAY		INPCLS
		DIR_CONSOLE_INPUT
		CMP	AL,"*"
		JNE	MSG_INP1
		JMP	EXIT
MSG_INP1:
		CMP	AL,"+"
		JZ	OFF_S
		DISPLAY_CHAR	BEEP
		JMP	SHORT	MSG_INP

OFF_S:
		COLOR_M		0,7,1,1	;FG=�� BG=�� �g��=BG,��
		LOCATE_M	COUNT,0
		MOV	DX,OFFSET ENDGMN0
		CALL	INP_CRT
;		DISPLAY_CHAR	BEEP
		CALL	WAIT_S

		INC	COUNT
		CMP	COUNT,10
		JZ	OFF_S1EXIT
		JMP	OFF_S
OFF_S1EXIT:
		LOCATE_M	COUNT,0
		MOV	DX,OFFSET ENDGMN1
		CALL	INP_CRT
;		DISPLAY_CHAR	BEEP
		CALL	WAIT_S

		INC	COUNT

		LOCATE_M	COUNT,0
		MOV	DX,OFFSET ENDGMN2
		CALL	INP_CRT
;		DISPLAY_CHAR	BEEP
		CALL	WAIT_S

		INC	COUNT

		LOCATE_M	COUNT,0
		MOV	DX,OFFSET ENDGMN3
		CALL	INP_CRT
;		DISPLAY_CHAR	BEEP
		CALL	WAIT_S

		INC	COUNT

OFF_S_L:
		LOCATE_M	COUNT,0
		MOV	DX,OFFSET ENDGMN0
		CALL	INP_CRT
;		DISPLAY_CHAR	BEEP
		CALL	WAIT_S

		INC	COUNT
		CMP	COUNT,25
		JZ	EXIT
		JMP	OFF_S_L

EXIT:
		CMP	AL,"*"
		JNE	EXIT1
		DISPLAY		INPPRN
		END_PROCESS 99H
EXIT1:
		END_PROCESS 0


WAIT_S	PROC
	MOV	CX,WAIT_DT
   WAIT_T:
	MOV	AX,0FFFFH
      WAIT_TT:
		DEC	AX
		OR 	AX,AX
		JNE	WAIT_TT
   LOOP	WAIT_T
	RET
WAIT_S	ENDP

INP_CRT	PROC	NEAR				;��ʕ\��	ٰ��
	MOV	CL,0D7H				;BIOS CALL
;	MOV	DX,OFFSET INTBL.IN_D		;INT 80H
	PUSH	ES				;CL=0D7H
	INT	80H				;'$'�܂ŕ\��
	POP	ES
	RET
INP_CRT	ENDP


TITLE0	DB	"��  �V�X�e���I���W���É�  ��"
	DB	"$"
     
GAMEN0	DB "�X�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�Z",CR,LF
DB	"$" 
GAMEN1	DB "�a         �� �É��x�X�̖{���̋Ɩ����I�����܂��B ��       �a",CR,LF
DB	"$" 
GAMEN2	DB "�a   �������������J�l�ł����B�������K���o�����悤��   �a",CR,LF
DB	"$" 
GAMEN3	DB "�a          ���ƂɋA���Ă�����肨�₷�݂������� �B       �a",CR,LF
DB	"$" 
GAMEN4	DB "�a     �@�@   �� �{����͂���Ɠd����؂�܂��B��         �a",CR,LF
DB	"$" 
GAMEN5	DB "�^�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�b�`",CR,LF
DB	"$" 

ENDGMN0 DB "�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K�K","$"
ENDGMN1 DB "�K�K�K�K�K�K�K�K�K�K�K�K�K                            �K�K�K�K�K�K�K�K�K�K�K�K�K","$"
ENDGMN2 DB "�K�K�K�K�K�K�K�K�K�K�K�K�K �{���̉c�Ƃ͏I�����܂����B �K�K�K�K�K�K�K�K�K�K�K�K�K","$"
ENDGMN3 DB "�K�K�K�K�K�K�K�K�K�K�K�K�K                            �K�K�K�K�K�K�K�K�K�K�K�K�K","$"


INPCLS	DB	ESC,"0$"
INPPRN	DB	ESC,"1$"

COUNT	DB	0

CODE	ENDS
	END	START
