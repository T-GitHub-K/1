;****************************************************************
;	F2.COM			ｷｰ  走査ｺｰﾄﾞ			*
;								*
;				F2 - 3CH 00H			*
;	キー変更処理		NULL へ				*
;****************************************************************

INCLUDE	STD.H

INT_NO	EQU	15H				;書き換えるベクター番号

MAS_KEY	EQU	3BH				;入力するｷｰの走査ｺｰﾄﾞ
RES_KEY	EQU	3CH				;変更する走査ｺｰﾄﾞ
						;3CH は F2キー


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
	CMP	AL,RES_KEY			;'F2'の走査コード
	JZ	J1
	MOV	BYTE PTR CS:STK_AL,AL		;前回の走査コード
J1:	
	CMP	AL,RES_KEY
	JNZ	END_1
	CMP	BYTE PTR CS:STK_AL,0E0H		;PRINT SCREEN の回避
	JZ	END_1				;走査ｺｰﾄﾞが E0H 2AH E0H 37H 
						;最後に37Hがあるので前回の
						;走査ｺｰﾄﾞをみて判定するため
	
	MOV	AL,MAS_KEY			;00の走査コード
	POPF
	STC					;ｷｬﾘｰﾌﾗｸﾞをONにして更新
	JMP	DWORD PTR CS:OLD_OFF		;元のアドレスにジャンプ
END_1:	
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
M0	DB	"F9  Ver 1.00 (C) CopyRight by Takeo   All Rights Reserved (C)"
	DB	CR,LF
	DB	"F9.COM  解放しました。$"

M1	DB	"F9  Ver 1.00 (C) CopyRight by Takeo   All Rights Reserved (C)"
	DB	CR,LF
	DB	"F9.COM  常駐しました。$"
	
	SEGEND

	END	@S
