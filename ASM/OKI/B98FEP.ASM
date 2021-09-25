;************************************************
;*	Type 1 BIOS call subroutine		*
;*						*
;*	OKI BASIC からのType 1 BIOS call	*
;*		使用法	CALL TYPE1B(REG(1))	*
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
DBG	EQU	0			;直接実行
;
CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE
START:
IF	DBG
;********************************************
;ｂａｓｉｃ９８から渡される引き数テーブル作成
;********************************************
	PUSH	CS
	POP	DS
	MOV	AX,DS
	MOV	BX,OFFSET ADDTBL
	MOV	WORD PTR [BX+00H],OFFSET TTT
	MOV	WORD PTR [BX+02H],AX
JMP	NXT
	;********************************************
	;テスト用データ
	;********************************************
ADDTBL	DB	4 DUP(?)
TTT	DW	00H,00H,42H,00H,00H,00H,00H,00H
NXT:
ENDIF
;
	;*******************************************
	;各レジスタ退避
	;*******************************************
	IRP	DUM,<AX,BX,CX,DX,SI,DI,DS,ES>
		PUSH	DUM
	ENDM
	;*******************************************
	;引き数テーブルセグメントオフセット
	;*******************************************
	MOV	ES,DS:[BX+2]
	MOV	AX,ES
	MOV	TBL_SEGMNT,AX
	MOV	SI,DS:[BX]
	MOV	TBL_OFFSET,SI
	;********************************************
	;引数の内容を各レジスタにセット
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
	;ＩＮＴ８０
	;********************************************
	INT	83H
	;********************************************
	;各レジスタの内容を引数にセット
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
	;退避データ元に戻す
	;********************************************
	IRP	DUM,<ES,DS,DI,SI,DX,CX,BX,AX>	;各レジスタ
	POP	DUM
	ENDM
	;********************************************
	;プログラムエンド
	;********************************************
	IRET
;
;********************************************
;レジスタ退避用データ
;********************************************
TBL_SEGMNT	DW	1 DUP(?)
TBL_OFFSET	DW	1 DUP(?)
;********************************************
;
;********************************************
CODE	ENDS
	END	START


