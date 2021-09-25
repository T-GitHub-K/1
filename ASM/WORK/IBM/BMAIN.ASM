;****************************************************************
;	BMAIN.ASM     						*
;								*
;								*
;****************************************************************

INCLUDE	STD.H

	COMSEG

@S:
	MOV	SI,OFFSET DTA[0]
	MOV	DI,OFFSET WORK
	CALL	PARA			;ｺﾏﾝﾄﾞﾗｲﾝの文字取得
	JC	@1			;ERROR
        MOV	AH,WORK[0]
        MOV	AL,WORK[1]
        CALL	CTOH			;ｷｬﾗｸﾀｰをHEXに変換
        OR	AL,AL
        JZ	@1
        MOV	LEN,AL

@1:
	MOV	CX,20				;20回鳴らす
LOOP1:
	PUSH	CX

	XOR	CX,CX
	MOV	CL,LEN				;音の長さ（約１秒）
	MOV	AX,740				;周波数
	CALL	BEEP

	
	XOR	CX,CX
	MOV	CL,LEN				;音の長さ（約１秒）
	MOV	AX,620				;周波数
	CALL	BEEP


	POP	CX
	LOOP	LOOP1

	EXIT	0


LEN	DB	100
WORK	DB	256 	DUP(0)
	
	
	STACK	256

	SEGEND

	END	@S
