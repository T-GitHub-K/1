;********************************************************
;*	WAIT 						*
;*	使用例						*
;*	A>WAT	ｳｴｲﾄ数                          	*
;*	A>WAT	2000					*
;*					By wolf    	*
;********************************************************
INCLUDE	MACRO.H
INCLUDE	STD.H
INCLUDE UTY.H

MAX	EQU	3
MIN	EQU	2


CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE


	INPUT1_M	MSG




START:	MOV	AL,PARA				;DTA ﾊﾟﾗﾒｰﾀｰ数

DEF:	CMP	AL,MAX				;ﾊﾟﾗﾒｰﾀｰ数 ﾁｪｯｸ 最大
	JBE	DEF1
	JMP	E_MSG				;使用例表示

DEF1:	CMP	AL,MIN				;ﾊﾟﾗﾒｰﾀｰ数 ﾁｪｯｸ 最小
 	JAE	DEF2
	JMP	E_MSG				;使用例表示
DEF2:
	XOR 	CX,CX
  	MOV	CL,PARA
	DEC	CX

A:	MOV	BX,CX
	MOV	AL,PARA[BX+1]			;入力制限  0<=PARA[n]<=9
	CMP	AL,30H
	JAE	A1
	JMP	E_MSG

A1:	CMP	AL,39H
	JBE	A2
	JMP	E_MSG
A2:
	SUB	AL,30H
	MOV	BX,10
	MUL	BX
	ADD	WATS,AL
	LOOP	A

	MOV	AL,WATS
C:	CALL	WAT
	DEC	AL
	JNE	C


END:	MOV	AH,4CH
	INT	21H



E_MSG:	MOV	AH,09H
	COLOR_M	0,2
	MOV	DX,OFFSET MSG
	INT	21H
	COLOR_M	7,0
	MOV	DX,OFFSET MSG1
	INT	21H
	COLOR_M	7,0

	JMP	END


WAT	PROC	NEAR
	MOV	CL,WATS
B:		MOV	BX,CX
		MOV	CL,WATS
B1:		MOV	AH,AH
		LOOP	B1
		MOV	CX,BX
	LOOP	B
	RET
WAT	ENDP


WATS	DB	1 DUP(0)

MSG     DB	"パラメータの指定に誤りがあります",'$'
MSG1 	DB	CR,LF,CR,LF
	DB	"	使用例	                           ",CR,LF
 	DB	CR,LF
	DB	"	  A>WAT ｳｴｲﾄ数                          ",CR,LF,CR,LF
	DB	"	  A>WAT 1-99",CR,LF,CR,LF
	DB	"         ",'$'

CODE	ENDS
	END
