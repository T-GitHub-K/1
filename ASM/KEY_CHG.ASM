;****************************************************************
;	F9F5.COM		ｷｰ  走査ｺｰﾄﾞ	ｷｰ  走査ｺｰﾄﾞ	*
;								*
;				F9 - 43H 00H	F5 - 3FH 00H	*
;				*  - 37H 2AH	/  - 35H 2FH	*
;	キー変更処理						*
;****************************************************************

INCLUDE	STD.H

INT_NO	EQU	15H				;書き換えるベクター番号

	COMSEG

@S:	JMP	SET

OLD_OFF	DW	0
OLD_SEG	DW	0
SIN	DB	"KEY"				;常駐したときの確認文字

ENT:
	PUSHF
	CMP	AH,4FH				;機能番号 4FH ｷｰﾎﾞｰﾄﾞｲﾝﾀｰｾﾌﾟﾄ
	JNZ	END_1
KEY1:
	CMP	AL,42H				;F8の走査コード
	JNZ	KEY2
	MOV	AL,48H				;↑の走査コード
	POPF
	STC					;ｷｬﾘｰﾌﾗｸﾞをONにして更新
	JMP	DWORD PTR CS:OLD_OFF		;元のアドレスにジャンプ
KEY2:
	CMP	AL,44H				;F10の走査コード
	JNZ	END_1
	MOV	AL,50H				;↓の走査コード
	POPF
	STC					;ｷｬﾘｰﾌﾗｸﾞをONにして更新
	JMP	DWORD PTR CS:OLD_OFF		;元のアドレスにジャンプ
END_1:	
	MOV	BYTE PTR CS:STK_AL,AL		;前回の走査コード
	POPF
	JMP	DWORD PTR CS:OLD_OFF		;元のアドレスにジャンプ


STK_AL	DB	0				;前回の走査コードのエリア	

	STACK	128				;ﾜｰｸｴﾘｱ
	EVEN

SIZE1	EQU	$


SET:
	MOV	AH,35H
	MOV	AL,INT_NO
	INT	21H
	MOV	OLD_OFF,BX
	MOV	OLD_SEG,ES

	SUB	BX,3
	MOV	DI,BX
	MOV	SI,OFFSET CHK
	MOV	CX,3
	REPZ	CMPSB
	JNE	INT_SET
	
	MOV	AH,09
	MOV	DX,OFFSET M0
	INT	21H
	
	MOV	BX,OLD_OFF
	MOV	ES,OLD_SEG
	MOV	DX,ES:[BX-7]
	MOV	DS,ES:[BX-5]
	MOV	AH,25H
	MOV	AL,INT_NO
	INT	21H
	
	MOV	ES,CS:OLD_SEG
	MOV	ES,WORD PTR ES:[002CH]
	MOV	AH,49H
	INT	21H
	MOV	ES,CS:OLD_SEG
	MOV	AH,49H
	INT	21H
	
	EXIT

INT_SET:
	MOV	AH,09H
	MOV	DX,OFFSET M1
	INT	21H
	
	MOV	DX,OFFSET ENT
	MOV	AH,25H
	MOV	AL,INT_NO
	INT	21H
	
	MOV	DX,OFFSET SIZE1
	MOV	CL,4
	SHR	DX,CL
	MOV	AX,3100H
	INT	21H
	
	EXIT
	
CHK	DB	"KEY",0
M0	DB	"F9F5  Ver 1.00 (C) CopyRight by Takeo   All Rights Reserved (C)"
	DB	CR,LF
	DB	"F9F5.COM  解放しました。$"

M1	DB	"F9F5  Ver 1.00 (C) CopyRight by Takeo   All Rights Reserved (C)"
	DB	CR,LF
	DB	"F9F5.COM  常駐しました。$"
	
	SEGEND

	END	@S
