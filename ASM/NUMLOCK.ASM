;****************************************************************
;	文字入力時常に NumLock 監視				*
;								*
;	NUMLOCK.ASM	Ver 1.00	                        *
;				                                *
;				                                *
;				                                *
;****************************************************************

INCLUDE	STD.H

INT_NO	EQU	15H				;書き換えるベクター番号


	COMSEG

@S:	JMP	SET

OLD_OFF	DW	0
OLD_SEG	DW	0
SIN	DB	"NUM"				;常駐したときの確認文字

ENT:
	PUSHF
	CMP	AH,4FH				;機能番号 4FH ｷｰﾎﾞｰﾄﾞｲﾝﾀｰｾﾌﾟﾄ
	JNZ	END_1

	PUSH	ES
	PUSH	SI
	PUSH	AX
		
	XOR	AX,AX
	MOV	ES,AX
	MOV	SI,0417H
	MOV	AX,ES:[SI]
	OR  	AX,00100000B
	MOV	ES:[SI],AX
	
	POP	AX
	POP	SI
	POP	ES

END_1:
	POPF
	JMP	DWORD PTR CS:OLD_OFF		;元のアドレスにジャンプ


STK_AL	DB	0				;前回の走査コードのエリア	

	STACK	64				;ﾜｰｸｴﾘｱ
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
	
CHK	DB	"NUM",0

M1	DB	"Num Lock Key !  Ver 1.00 (C) CopyRight by Takeo   All Rights Reserved (C)"
	DB	CR,LF
	DB	"Num Lock LOCK ! $"

M0	DB	"Num Lock Key !  Ver 1.00 (C) CopyRight by Takeo   All Rights Reserved (C)"
	DB	CR,LF
	DB	"Num Lock UNLOCK ! $"
	
	SEGEND

	END	@S
