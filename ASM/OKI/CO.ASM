;********************************************************
;*	COLOR 						*
;*	使用例						*
;*	A>CO	ﾌｫｱｶﾗｰ,ﾊﾞｯｸｶﾗｰ,拡張ｶﾗｰ			*
;*	A>CO	7,0,0					*
;*					By wolf    	*
;********************************************************
INCLUDE	MACRO.H
INCLUDE	STD.H


CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE,ES:CODE

	ORG	80H
PARA	DB	80H	DUP(0)			;DAT  ｴﾘｱ初期化
	ORG	100H

START:	MOV	AL,PARA				;DTA ﾊﾟﾗﾒｰﾀｰ数

DEF:	CMP	AL,8				;ﾊﾟﾗﾒｰﾀｰ数 ﾁｪｯｸ
	JBE	DEF1
	JMP	E_MSG				;使用例表示

DEF1:	CMP	AL,2				;ﾊﾟﾗﾒｰﾀｰ数 ﾁｪｯｸ
 	JAE	A
	JMP	E_MSG				;使用例表示

A:	MOV	AL,PARA[2]			;入力制限  0<=PARA[2]<=7
	CMP	AL,30H
	JAE	A1
	JMP	END

A1:	CMP	AL,37H
	JBE	A2
	JMP	END
	
A2:	SUB	AL,30H				;AL-30H
	MOV	CPARA.FGC,AL			;CPARA にﾌｫｱｶﾗｰｾｯﾄ

	MOV	AL,PARA[4]
	CMP	AL,30H
	JAE	B
	MOV	CPARA.BGC,0
	JMP	D

B:	CMP	AL,37H
	JBE	C
	MOV	CPARA.BGC,0
	JMP	D

C:	SUB	AL,30H				;AL-30H
	MOV	CPARA.BGC,AL			;CPARA にﾊﾞｯｸｶﾗｰｾｯﾄ

	MOV	AL,PARA[6]
	CMP	AL,30H
	JAE	FG1
	MOV	CPARA.FG,0
	JMP	P0

FG1:	CMP	AL,31H
	JBE	FG2
	MOV	CPARA.FG,0
	JMP	P0

FG2:	SUB	AL,30H				;AL-30H
	MOV	CPARA.FG,AL			;CPARA に拡張ｸﾞﾗﾝﾄﾞｾｯﾄ

P0:	MOV	AL,PARA[8]
	CMP	AL,30H
	JAE	P1
	MOV	CPARA.P,0

P1:	CMP	AL,31H
	JBE	P2
	MOV	CPARA.P,0
	JMP	D

P2:	SUB	AL,30H				;AL-30H
	MOV	CPARA.P,AL			;CPARA に拡張ｶﾗｰｾｯﾄ

D:	COLOR_M	CPARA.FGC,CPARA.BGC,CPARA.FG,CPARA.P
	
END:	MOV	AH,4CH
	INT	21H

E_MSG:	MOV	AH,09H
	COLOR_M	0,2
	MOV	DX,OFFSET MSG
	INT	21H
	COLOR_M	7,0
	MOV	DX,OFFSET MSG1
	INT	21H
	COLOR_M	0,7,1,1
	MOV	DX,OFFSET KURO
	INT	21H
	COLOR_M	1,7
	MOV	DX,OFFSET AO
	INT	21H
	COLOR_M	2,7
	MOV	DX,OFFSET AKA
	INT	21H
	COLOR_M	3,7
	MOV	DX,OFFSET FUJI
	INT	21H
	COLOR_M	4,7
	MOV	DX,OFFSET MIDO
	INT	21H
	COLOR_M	5,7
	MOV	DX,OFFSET MIZU
	INT	21H
	COLOR_M	6,7
	MOV	DX,OFFSET KII
	INT	21H
	COLOR_M	7,7
	MOV	DX,OFFSET SIRO
	INT	21H
	COLOR_M	7,0,1,0
	MOV	DX,OFFSET ENDCR
	INT	21H

	JMP	END

;		CO	FGｶﾗｰ	1 BYTE
;			BGｶﾗｰ	1 BYTE
;			拡張ｸﾞﾗﾝﾄﾞ指定	1 BYTE
;			拡張ｶﾗｰ指定	1 BYTE
;
	COST	STRUC
		FGC	DB	1 DUP(0)
		BGC	DB     	1 DUP(0)
		FG	DB     	1 DUP(0)
		P	DB     	1 DUP(0)
	COST	ENDS

CPARA	COST	<,,,>

MSG     DB	"パラメータの指定に誤りがあります",'$'
MSG1 	DB	CR,LF,CR,LF
	DB	"	使用例	ﾌｫｱｶﾗｰを白ﾊﾞｯｸｶﾗｰを黒の場合",CR,LF
 	DB	CR,LF
	DB	"	  A>CO ﾌｫｱｶﾗｰ,ﾊﾞｯｸｶﾗｰ,拡張ｸﾞﾗﾝﾄﾞ,拡張ｶﾗｰ",CR,LF,CR,LF
	DB	"	  A>CO 7,0,0,0",CR,LF,CR,LF
	DB	"         ",'$'
KURO	DB	" 0･･黒","$"
AO 	DB	" 1･･青","$"
AKA	DB	" 2･･赤","$"
FUJI 	DB	" 3･･紫","$"
MIDO 	DB	" 4･･緑","$"
MIZU 	DB	" 5･･水","$"
KII 	DB	" 6･･黄","$"
SIRO 	DB	" 7･･白","$"
ENDCR 	DB	CR,LF
	DB	"$"

CODE	ENDS
	END	START
