;********************************************************
;*	COLOR 						*
;*	使用例						*
;*	A>IBMCO   ｶﾗｰ,ﾊﾟﾚｯﾄ				*
;*	A>IBMCO   7,7					*
;*					            	*
;*	16色のｶﾗｰ番号に64色のﾊﾟﾚｯﾄ番号をｾｯﾄする    	*
;*	ｶﾗｰ       0-F		                   	*
;*	ﾊﾟﾚｯﾄ	  0-3F			           	*
;*		                                    	*
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

DEF:	CMP	AL,8				;ﾊﾟﾗﾒｰﾀｰ数 ﾁｪｯｸ  最大値
	JBE	DEF1
	JMP	E_MSG				;使用例表示

DEF1:	CMP	AL,4				;ﾊﾟﾗﾒｰﾀｰ数 ﾁｪｯｸ  最小値
 	JAE	PALA_1
	JMP	E_MSG				;使用例表示

PALA_1:	MOV	AL,PARA[2]			;第一パラメータ取得
						;(ｶﾗｰ番号)
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
	CMP	CX,2				;取得制限 ﾊﾟﾗﾒｰﾀｰ２個
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
	CMP	AL,46H				;ｷｬﾗｸﾀｰｺｰﾄﾞ Fより大きい
	JA	PALA_E1
	CMP	AL,39H
	JA	PALA_ABC
	SUB	AL,30H
	MOV	P1,AL
	JMP	PALA_SET2

PALA_E1:
	JMP	E_MSG				;使用例表示

PALA_ABC:
	SUB	AL,37H
	MOV	P1,AL


PALA_SET2:					;第二ﾊﾟﾗﾒｰﾀｰ
	MOV	BX,0
	MOV	AL,PALA2[BX]
	CMP	AL,30H				;ｷｬﾗｸﾀｰｺｰﾄﾞ 0より小さい
	JB	PALA_E1
	CMP	AL,46H				;ｷｬﾗｸﾀｰｺｰﾄﾞ Fより大きい
	JA	PALA_E1
	CMP	AL,39H
	JA	PALA_ABC2
	SUB	AL,30H
	MOV	P2,AL
	JMP	SHORT PALA_SETA

PALA_ABC2:
	SUB	AL,37H
	MOV	P2,AL
PALA_SETA:
	MOV	CL,4
	SHL	AL,CL
	MOV	DL,AL

PALA_SET3:
						;第二ﾊﾟﾗﾒｰﾀｰ
	MOV	BX,1
	MOV	AL,PALA2[BX]
	CMP	AL,30H				;ｷｬﾗｸﾀｰｺｰﾄﾞ 0より小さい
	JB	PALA_E3
	CMP	AL,46H				;ｷｬﾗｸﾀｰｺｰﾄﾞ Fより大きい
	JA	PALA_E3
	CMP	AL,39H
	JA	PALA_ABC3
	SUB	AL,30H
	MOV	P2,AL
	JMP	SHORT PALA_SETB

PALA_E3:
	MOV	AL,P2
	JMP	RUN

PALA_ABC3:
	SUB	AL,37H
	MOV	P2,AL
PALA_SETB:
	OR	AL,DL
	MOV	P2,AL
RUN:
	MOV	AX,1000H
	MOV	BL,P1
	MOV	BH,P2
	INT	10H

END:	MOV	AH,4CH
	INT	21H

E_MSG:	MOV	AH,09H
	MOV	DX,OFFSET MSG
	INT	21H

	JMP	END

MSG     DB	"パラメータの指定に誤りがあります"
 	DB	CR,LF,CR,LF
	DB	"	使用例	ｶﾗｰ番号７をﾊﾟﾚｯﾄ番号３７の場合",CR,LF
 	DB	CR,LF
	DB	"       A>IBMCO ｶﾗｰ,ﾊﾟﾚｯﾄ",CR,LF,CR,LF
	DB	"       A>IBMCO 7 37     ",CR,LF,CR,LF
	DB	"         ",'$'


PALA1	DB	2	DUP(0)
PALA2	DB	2	DUP(0)

P1	DB	0
P2	DB	0

STK	DB	100H	DUP(0)

CODE	ENDS
	END	START
