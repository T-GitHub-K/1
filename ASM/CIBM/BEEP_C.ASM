;****************************************************************
;	BMAIN3.ASM     						*
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
	MOV	CX,3				;1回鳴らす
LOOP1:
	PUSH	CX

	MOV	AX,987				;周波数（ド）
	CALL	SUB
	MOV	AX,20
	CALL	SUB

	MOV	AX,329				;周波数（レ）
	CALL	SUB
	MOV	AX,20
	CALL	SUB


	POP	CX
	LOOP	LOOP1

	MOV	AH,4CH
	INT	21H

SUB	PROC	NEAR

	XOR	CX,CX
	MOV	CL,LEN
	CALL	BEEP
	RET
SUB	ENDP


LEN	DB	100
WORK	DB	256 	DUP(0)

	STACK	256

	SEGEND
	
	END	@S
