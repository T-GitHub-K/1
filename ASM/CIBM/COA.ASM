;********************************************************
;*	COLOR 						*
;*	使用例						*
;*	A>COA   ﾌｫｱｸﾞﾗﾝﾄﾞｶﾗｰ,ﾊﾞｯｸｸﾞﾗﾝﾄﾞｶﾗｰ		*
;*	A>COA   FGC,BGC					*
;*	A>COA   7,7					*
;*					By wolf    	*
;********************************************************
INCLUDE	MACRO.H
INCLUDE	STD.H


CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE,ES:CODE

	ORG	80H
PARA	DB	80H	DUP(0)			;DAT  ｴﾘｱ初期化
	ORG	100H

START:	MOV	AX,CS
	MOV	ES,AX

	MOV	AL,PARA				;DTA ﾊﾟﾗﾒｰﾀｰ数

DEF:	CMP	AL,8				;ﾊﾟﾗﾒｰﾀｰ数 ﾁｪｯｸ  最大値
	JBE	DEF1
	JMP	E_MSG				;使用例表示

DEF1:	CMP	AL,4				;ﾊﾟﾗﾒｰﾀｰ数 ﾁｪｯｸ  最小値
 	JAE	PALA_1
	JMP	E_MSG				;使用例表示

PALA_1:	MOV	AL,PARA[2]			;第一パラメータ取得
						;(ﾌｫｱｸﾞﾗﾝﾄﾞ番号)
	CMP	AL," "				;SPACE
	JE	PALA_E
	CMP	AL,","				;ｶﾝﾏ
	JE	PALA_E
	CMP	AL,"/"				;ｽﾗｯｼｭ
	JE	PALA_E
	JMP	SHORT PALA_1A

PALA_E:
	JMP	E_MSG				;使用例表示

PALA_1A:
	MOV	BX,1
	MOV	CX,0
PALA_1B:
	INC	BX
	MOV	AL,PARA[BX]
	CMP	AL," "				;SPACE
	JE	PALA_2
	CMP	AL,","				;ｶﾝﾏ
	JE	PALA_2
	CMP	AL,"/"				;ｽﾗｯｼｭ
	JE	PALA_2
	CMP	AL,0DH
	JE	PALA_E
	CMP	CX,1				;取得制限 ﾊﾟﾗﾒｰﾀｰ１個
	JA	PALA_1B
	PUSH	BX
	MOV	BX,CX
	MOV	PALA1[BX],AL
	INC	CX
	POP	BX
	JMP	SHORT	PALA_1B

PALA_2:
	MOV	CX,0
PALA_2A:
	INC	BX
	MOV	AL,PARA[BX]			;第二パラメータ取得
						;(ﾊﾟﾚｯﾄ番号)
	CMP	AL," "				;SPACE
	JE	PALA_END
	CMP	AL,","				;ｶﾝﾏ
	JE	PALA_END
	CMP	AL,"/"				;ｽﾗｯｼｭ
	JE	PALA_END
	CMP	AL,0DH
	JE	PALA_END
	CMP	CX,1				;取得制限 ﾊﾟﾗﾒｰﾀｰ１個
	JA	PALA_2A
	PUSH	BX
	MOV	BX,CX
	MOV	PALA2[BX],AL
	INC	CX
	POP	BX
	JMP	SHORT	PALA_2A

PALA_END:
PALA_SET1:					;第一ﾊﾟﾗﾒｰﾀｰ
	MOV	BX,0
	MOV	AL,PALA1[BX]
	CMP	AL,30H				;ｷｬﾗｸﾀｰｺｰﾄﾞ 0より小さい
	JB	PALA_E1
	CMP	AL,37H				;ｷｬﾗｸﾀｰｺｰﾄﾞ 7より大きい
	JA	PALA_E1
	SUB	AL,30H
	MOV	P1,AL
	JMP	PALA_SET2

PALA_E1:
	JMP	E_MSG				;使用例表示



PALA_SET2:					;第二ﾊﾟﾗﾒｰﾀｰ
	MOV	BX,0
	MOV	AL,PALA2[BX]
	CMP	AL,30H				;ｷｬﾗｸﾀｰｺｰﾄﾞ 0より小さい
	JB	PALA_E1
	CMP	AL,37H				;ｷｬﾗｸﾀｰｺｰﾄﾞ 7より大きい
	JA	PALA_E1
	SUB	AL,30H
	MOV	P2,AL

RUN:	
	XOR	AX,AX
	MOV	AH,03H				;ｶ-ｿﾙ取得
	MOV	BH,0				;DH=行 DL=桁
	INT	10H
	
	MOV	CX,80
	SUB	CX,DL
	
	
	
	


END:	MOV	AH,4CH
	INT	21H

E_MSG:	MOV	AH,09H
	MOV	DX,OFFSET MSG
	INT	21H

	JMP	END

MSG     DB	"パラメータの指定に誤りがあります"
 	DB	CR,LF,CR,LF
	DB	"	使用例 ﾌｫｱｸﾞﾗﾝﾄﾞｶﾗｰ番号７ﾊﾞｯｸｸﾞﾗﾝﾄﾞｶﾗｰを０の場合",CR,LF
 	DB	CR,LF
	DB	"       A>COA ﾌｫｱｶﾗｰ,ﾊﾞｯｸｶﾗｰ",CR,LF,CR,LF
	DB	"       A>COA 7 0           ",CR,LF,CR,LF
	DB	"         ",'$'


PALA1	DB	2	DUP(0)
PALA2	DB	2	DUP(0)

P1	DB	0	;前景色
P2	DB	0	;後景色

SET	DB	0,P


STK	DB	100H	DUP(0)

CODE	ENDS
	END	START
