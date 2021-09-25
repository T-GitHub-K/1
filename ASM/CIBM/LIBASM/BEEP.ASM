;****************************************************************
;	BEEP.ASM     						*
;								*
;	ì¸óÕ	AX=é¸îgêî					*
;	ì¸óÕ	CX=é¸îgêî					*
;								*
;	îjâÛ⁄ºﬁΩ¿	Ç»Çµ					*
;****************************************************************

.286c


_TEXT	SEGMENT	WORD PUBLIC 'CODE'
	ASSUME	CS:_TEXT,DS:_TEXT,ES:_TEXT,SS:_TEXT


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
	
	DIV	BX			;COUNT=1193180/HZ(é¸îgêî)
					;è§ >> AX  ó]ÇË >> DX
	
	MOV	COUNT,AX
	
	MOV	AL,0B6H			;TIMER ¡ØÃﬂÇÃREADY
	OUT	43H,AL
	
	MOV	AX,COUNT
	
	OUT	42H,AL			;COUNT ÇÃâ∫à  ﬁ≤ƒëóèo
	XCHG	AH,AL
	OUT	42H,AL			;COUNT ÇÃè„à  ﬁ≤ƒÇÃëóèo
	
	IN	AL,61H
	OR	AL,3
	OUT	61H,AL			;ΩÀﬂ∞∂∞ ON
	
	MOV	CX,LEN			;âπí∑
	CALL	WAIT1
	
	IN	AL,61H
	AND	AL,11111100B
	OUT	61H,AL			;ΩÀﬂ∞∂∞ OFF

	POPA

	RET


COUNT	DW	0
HZ	DW	0
LEN	DW	0


BEEP	ENDP
_TEXT	ENDS
	END
