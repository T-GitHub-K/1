;********************************************************
;*	LOCATE 						*
;*	使用例						*
;*	A>LO	ﾛｹｰﾄY,ﾛｹｰﾄX				*
;*	A>LO	10,10					*
;*					By wolf    	*
;********************************************************
INCLUDE	MACRO.H
INCLUDE	STD.H

CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE,ES:CODE

	ORG	80H
PARA	DB	80H	DUP(0)			;DAT  ｴﾘｱ初期化
	ORG	100H

START:	MOV	LPARA.Y,0
	MOV	LPARA.X,0
	
	MOV	AL,PARA				;DTA ﾊﾟﾗﾒｰﾀｰ数
	CMP	AL,4				;ﾊﾟﾗﾒｰﾀが4より小さい
	JNB	DEF
	JMP	E_MSG

DEF:	CMP	AL,8				;ﾊﾟﾗﾒｰﾀｰ数 ﾁｪｯｸ
	JBE	COPY_PARA
	JMP	E_MSG				;使用例表示

;Ｙ座標

COPY_PARA:
	XOR	BX,BX
	XOR	CX,CX
	MOV	BL,2
	MOV	CL,2
						;ﾊﾟﾗﾒｰﾀｺﾋﾟｰ
PARA0:	MOV	AL,PARA[BX]
	CMP	AL,','				;座標区切り
	JE	PARA_NEXT

	CMP	AL,30H				;入力制限  0<=PARA[2]<=9
	JAE	PARA1
	JMP	END
	
PARA1:	CMP	AL,39H
	JBE	PARA2
	JMP	END

PARA2:	SUB	AL,30H
	CMP	CL,1
	JNE	PARA3
	MOV	DH,AL
	MOV	AL,LPARA.Y
	MOV	DL,10
	MUL	DL
	ADD	AL,DH
	
PARA3:	MOV	LPARA.Y,AL
	INC	BX
	LOOP	PARA0

PARA_NEXT:
	INC	BX

;Ｘ座標

COPY_PARA1:
	XOR	CX,CX
	MOV	CL,2
						;ﾊﾟﾗﾒｰﾀｺﾋﾟｰ
PARA1_0:
	MOV	AL,PARA[BX]
	CMP	AL,0DH				;終了
	JE	PARA_END

	CMP	AL,','				;座標区切り
	JE	PARA2_NEXT

	CMP	AL,30H				;入力制限  0<=PARA[2]<=9
	JAE	PARA1_1
	JMP	END
	
PARA1_1:
	CMP	AL,39H
	JBE	PARA1_2
	JMP	END

PARA1_2:
	SUB	AL,30H
	CMP	CL,1
	JNE	PARA1_3
	MOV	DH,AL
	MOV	AL,LPARA.X
	MOV	DL,10
	MUL	DL
	ADD	AL,DH

PARA1_3:
	MOV	LPARA.X,AL
	INC	BX
	LOOP	PARA1_0

PARA2_NEXT:
	INC	BX

	MOV	AL,PARA[BX]
	CMP	AL,0DH				;終了
	JE	PARA_END

	CMP	AL,30H				;入力制限  0<=PARA[n]<=2
	JAE	PARA2_1
	JMP	PARA_END
	
PARA2_1:
	CMP	AL,32H
	JBE	PARA2_2
	JMP	PARA_END

PARA2_2:
	MOV	LPARA_S,AL
	MOV	AH,09H
	MOV	DX,OFFSET LPARA_C
	INT	21H

PARA_END:
	MOV	DL,LPARA.Y
	MOV	AL,LPARA.X
	XOR	AH,AH
	XOR	DH,DH
	MOV	CL,2DH
	PUSH	ES
	INT	80H
	POP	ES

END:	MOV	AH,4CH
	INT	21H

E_MSG:	MOV	AH,09H
	COLOR_M	0,2
	MOV	DX,OFFSET MSG
	INT	21H
	COLOR_M	7,0
	MOV	DX,OFFSET MSG1
	INT	21H
	JMP	END

;		LO	Y	1 BYTE	Y座標
;			X	1 BYTE	X座標

	LOST	STRUC
		Y	DB	1 DUP(0)
		X	DB     	1 DUP(0)
	LOST	ENDS

LPARA	LOST	<,>

MSG     DB	"パラメータの指定に誤りがあります",'$'
MSG1 	DB	CR,LF,CR,LF
	DB	"	使用例	Y座標を10X座標を10の場合",CR,LF
 	DB	CR,LF
	DB	"	  A>LO ﾛｹｰﾄY,ﾛｹｰﾄX,ｶｰｿﾙｽｲｯﾁ",CR,LF,CR,LF
	DB	"	  A>LO 10,10,1",CR,LF,CR,LF
	DB	"         ",'$'
ENDCR 	DB	CR,LF
	DB	"$"
LPARA_C	DB	1BH
LPARA_S	DB	0,"$"

CODE	ENDS
	END	START
