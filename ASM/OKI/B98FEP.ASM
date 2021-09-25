;************************************************
;*	Type 1 BIOS call subroutine		*
;*						*
;*	OKI BASIC �����Type 1 BIOS call	*
;*		�g�p�@	CALL TYPE1B(REG(1))	*
;*						*
;*	Parameters:		INPUT	OUTPUT	*
;*		REG(1) :	AX	AX	*
;*		REG(2) :	BX	BX	*
;*		REG(3) :	CX	CX	*
;*		REG(4) :	DX	DX	*
;*		REG(5) :	SI	SI	*
;*		REG(6) :	DI	DI	*
;*		REG(7) :	dummy	DS	*
;*		REG(8) :	dummy	ES	*
;************************************************
;
DBG	EQU	0			;���ڎ��s
;
CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE
START:
IF	DBG
;********************************************
;�����������X�W����n�����������e�[�u���쐬
;********************************************
	PUSH	CS
	POP	DS
	MOV	AX,DS
	MOV	BX,OFFSET ADDTBL
	MOV	WORD PTR [BX+00H],OFFSET TTT
	MOV	WORD PTR [BX+02H],AX
JMP	NXT
	;********************************************
	;�e�X�g�p�f�[�^
	;********************************************
ADDTBL	DB	4 DUP(?)
TTT	DW	00H,00H,42H,00H,00H,00H,00H,00H
NXT:
ENDIF
;
	;*******************************************
	;�e���W�X�^�ޔ�
	;*******************************************
	IRP	DUM,<AX,BX,CX,DX,SI,DI,DS,ES>
		PUSH	DUM
	ENDM
	;*******************************************
	;�������e�[�u���Z�O�����g�I�t�Z�b�g
	;*******************************************
	MOV	ES,DS:[BX+2]
	MOV	AX,ES
	MOV	TBL_SEGMNT,AX
	MOV	SI,DS:[BX]
	MOV	TBL_OFFSET,SI
	;********************************************
	;�����̓��e���e���W�X�^�ɃZ�b�g
	;********************************************
	MOV	AX,WORD PTR ES:[SI]
	MOV	BX,WORD PTR ES:[SI+2]
	MOV	CX,WORD PTR ES:[SI+4]
	MOV	DX,WORD PTR ES:[SI+6]
	PUSH	BX
	MOV	BX,SI
	MOV	SI,WORD PTR ES:[BX+8]
	MOV	DI,WORD PTR ES:[BX+10]
	POP	BX
	;********************************************
	;�h�m�s�W�O
	;********************************************
	INT	83H
	;********************************************
	;�e���W�X�^�̓��e�������ɃZ�b�g
	;********************************************
	PUSH	ES
	PUSH	SI
	MOV	SI,TBL_SEGMNT
	MOV	ES,SI
	MOV	SI,TBL_OFFSET
	MOV	WORD PTR ES:[SI],AX
	MOV	WORD PTR ES:[SI+2],BX
	MOV	WORD PTR ES:[SI+4],CX
	MOV	WORD PTR ES:[SI+6],DX
	MOV	BX,SI
	POP	SI
	MOV	WORD PTR ES:[BX+8],SI
	MOV	WORD PTR ES:[BX+10],DI
	MOV	WORD PTR ES:[BX+12],DS
	MOV	AX,ES
	MOV	DS,AX
	POP	ES
	MOV	WORD PTR ES:[BX+14],ES
	;********************************************
	;�ޔ��f�[�^���ɖ߂�
	;********************************************
	IRP	DUM,<ES,DS,DI,SI,DX,CX,BX,AX>	;�e���W�X�^
	POP	DUM
	ENDM
	;********************************************
	;�v���O�����G���h
	;********************************************
	IRET
;
;********************************************
;���W�X�^�ޔ�p�f�[�^
;********************************************
TBL_SEGMNT	DW	1 DUP(?)
TBL_OFFSET	DW	1 DUP(?)
;********************************************
;
;********************************************
CODE	ENDS
	END	START


