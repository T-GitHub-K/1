;****************************************************************
;*	64個のカラーレジスタを画面で表示確認セット		*
;*								*
;*	ＣＲ=設定  ＥＳＣ=中止  ＊=終了　'＋'=次 '－'=前"	*
;*								*
;*	DSPXXGA はできない					*
;*								*
;*	DSPXXGAをセットする前に変更してDSPXXGAを起動すれば	*
;*	問題ない						*
;*								*
;****************************************************************


INCLUDE STD.H

	COMSEG

EXTRN	PALETTE:NEAR
EXTRN	HTOC:NEAR

PUBLIC	PALMAIN

PALMAIN	PROC	NEAR

START:
	MOV	AX,CS
	MOV	DS,AX
	MOV	ES,AX

	MOV	AH,02H
	MOV	BH,00
	MOV	DH,10				;Ｙ座標
	MOV	DL,00				;Ｘ座標
	INT	10H

	MOV	AH,09
	MOV	DX,OFFSET SMSG
	INT	21H

	XOR	AX,AX

LOOP1:

	PUSH	AX
	CALL	MSG1
	CALL	PALETTE			;AH=PAL番号   RETURN AL=終了ｺｰﾄﾞ
	MOV	KEY,AL
	POP	AX
	
	MOV	AL,KEY
	
	CMP	AL,"*"
	JE	END_P
	
	CMP	AL,"-"
	JE	@1
	
	INC	AH
	INC	AH
	
@1:
	CMP	AH,0
	JNE	@2
	MOV	AH,3FH
	JMP	SHORT @3
@2:
	DEC	AH
@3:
	CMP	AH,3FH
	JBE	@4
	MOV	AH,0
@4:
	JMP	LOOP1

END_P:
	EXIT


MSG1	PROC	NEAR

RED_1:
	PUSHA
	
	MOV	AL,AH
	CALL	HTOC
	MOV	M,AH
	MOV	M[1],AL

	MOV	AH,02H
	MOV	BH,00
	MOV	DH,00
	MOV	DL,00
	INT	10H

	MOV	AH,09
	MOV	DX,OFFSET MSG
	INT	21H

	POPA
	
	RET

MSG1	ENDP



KEY	DB	0

MSG	DB	"  ﾊﾟﾚｯﾄ番号= "
M	DB	30H,30H
	DB	"$"

SMSG	DB	"ＣＲ=設定  ＥＳＣ=中止  ＊=終了　'＋'=次 '－'=前"
	DB	0DH,0AH,0DH,0AH
	DB	"DISPPAL  Ver 0.99     All Rights Reserved.   By TAKEO"
	DB	"$"

PALMAIN	ENDP

	SEGEND

	END	START