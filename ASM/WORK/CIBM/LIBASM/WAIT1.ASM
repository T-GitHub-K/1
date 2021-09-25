;****************************************************************
;	WAIT1.ASM     						*
;								*
;	ì¸óÕ	CX=∂≥›ƒêî					*
;								*
;	îjâÛ⁄ºﬁΩ¿	Ç»Çµ					*
;****************************************************************

.286c


_TEXT	SEGMENT	WORD PUBLIC 'CODE'
	ASSUME	CS:_TEXT,DS:_TEXT,ES:_TEXT,SS:_TEXT


PUBLIC	WAIT1

WAIT1	PROC	NEAR

	PUSHA

LOOP1:
	PUSH	CX
	MOV	CX,10000
		
		LOOP2:
			OR	AX,AX
			LOOP LOOP2
	POP CX
	LOOP	LOOP1


	POPA
	
	
	RET
	
WAIT1	ENDP
_TEXT	ENDS
	END
