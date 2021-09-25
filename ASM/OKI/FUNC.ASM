;********************************************************
;*	FUNCTION 登録ぷろ				*
;*	F1--F9   まで対応				*
;*	使用例						*
;*	A>FUNC ﾌｧﾝｸｼｮﾝ番号 登録文字			*
;*	A>FUNC 1 OBASIC					*
;*					By wolf    	*
;********************************************************


CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE,ES:CODE

	ORG	80H

PARA	DB	80H	DUP(0)			;DAT  ｴﾘｱ初期化

	ORG	100H

CR	=	0DH
LF	=	0AH


START:	MOV	AL,PARA				;DTA ﾊﾟﾗﾒｰﾀｰ数
	CMP	AL,3				;ﾊﾟﾗﾒｰﾀｰ数 ﾁｪｯｸ
 	JBE	E_MSG				;使用例表示

	MOV	AL,PARA[2]			;DTA入力ﾊﾟﾗﾒｰﾀﾁｪｯｸ
	CMP	AL,30H				;IF AL<1 THEN E_MSG
	JB	E_MSG
	CMP	AL,39H				;IF AL>9 THEN E_MSG
	JA	E_MSG
	CMP	AL,30H
	JNE	A
	ADD	AL,0AH

A:	DEC	AL				;F1=30H の為 31H-01H
	MOV	FUNC.FKEY,AL			;FUNC にFUNCTION 番号ｾｯﾄ

	XOR	BX,BX				;BX初期化
CP:  	
	MOV	AL,PARA[BX+4]			;DTA 文字列ﾘｰﾄﾞ
	CMP	AL,'/'				;ｽｲｯﾁの指定有り??
	JE 	SWITCH
	MOV	FUNC.FPARA[BX],AL		;FUNC に文字ｾｯﾄ
	INC	BX				;BXｶｳﾝﾄ
	CMP	AL,0DH				;CRｷｰかﾁｪｯｸ
	JE	F
	CMP	BX,0FH				;入力文字数ﾁｪｯｸ
	JE	E_MSG
	JMP	CP

SWITCH:	
	MOV	AL,PARA[BX+5]
	CMP	AL,'C'
	JE	SW_NOT_0D
	CMP	AL,'c'
	JE	SW_NOT_0D
	MOV	AL,0DH
	JMP	SW_END

SW_NOT_0D:
	MOV	AL,20H

SW_END:	MOV	FUNC.FPARA[BX],AL		;FUNC に文字ｾｯﾄ
	INC	BX

F:	
	MOV	FUNC.FLEN,BL			;FUNC に文字のﾚﾝｸﾞｽｾｯﾄ

;  ＩＮＴ　８０Ｈ　ファンクション設定  BIOS CALL

	MOV	CL,1CH
	MOV	AL,2
	MOV	DX,OFFSET FUNC
	INT	80H

END:	MOV	AH,4CH
	INT	21H

E_MSG:	MOV	AH,09H
	MOV	DX,OFFSET MSG
	INT	21H
	JMP	END

;-------------	FUNC 	キー番号 	1 BYTE
;			文字数 		1 BYTE
;			文字	       15 BYTE
;
	FUNCST	STRUC
		FKEY	DB	1 DUP(0)
		FLEN	DB	1 DUP(0)
		FPARA	DB     15 DUP(0)
	FUNCST	ENDS

FUNC	FUNCST	<,,>

MSG     DB	"ﾊﾟﾗﾒｰﾀの指定に誤りがありんす",CR,LF
 	DB	CR,LF
	DB	"	使用例	F1に　OBASIC をセットする場合",CR,LF
 	DB	CR,LF
	DB	"	A>FUNC 1 OBASIC",CR,LF
 	DB	CR,LF
 	DB	CR,LF
	DB	"但し  設定できるファンクションは、Ｆ１～Ｆ９ まで",CR,LF
	DB	"      文字数は１４文字まで",CR,LF,"$"

CODE	ENDS
	END	START
