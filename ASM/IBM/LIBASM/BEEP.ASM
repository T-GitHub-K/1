;****************************************************************
;	BEEP.ASM     						*
;								*
;	入力	AX=周波数					*
;	入力	CX=周波数					*
;								*
;	破壊ﾚｼﾞｽﾀ	なし					*
;****************************************************************

.286c


CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE


EXTRN	WAIT1:NEAR


PUBLIC	BEEP

BEEP	PROC	NEAR

@1:
	PUSHA
	
	MOV	HZ,AX
	MOV	LEN,CX
	
	MOV	DX,18
	MOV	AX,13550		;DX:AX=1193180
	MOV	BX,HZ
	
	DIV	BX			;COUNT=1193180/HZ(周波数)
					;商 >> AX  余り >> DX
	
	MOV	COUNT,AX
	
	MOV	AL,0B6H			;TIMER ﾁｯﾌﾟのREADY
	OUT	43H,AL
	
	MOV	AX,COUNT
	
	OUT	42H,AL			;COUNT の下位ﾊﾞｲﾄ送出
	XCHG	AH,AL
	OUT	42H,AL			;COUNT の上位ﾊﾞｲﾄの送出
	
	IN	AL,61H
	OR	AL,3
	OUT	61H,AL			;ｽﾋﾟｰｶｰ ON
	
	MOV	CX,LEN			;音長
	CALL	WAIT1
	
	IN	AL,61H
	AND	AL,11111100B
	OUT	61H,AL			;ｽﾋﾟｰｶｰ OFF

	POPA

	RET


COUNT	DW	0
HZ	DW	0
LEN	DW	0


BEEP	ENDP
CODE	ENDS
	END
