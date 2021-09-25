;****************************************************************
;	WAIT1.ASM     						*
;								*
;	ì¸óÕ	CX=∂≥›ƒêî					*
;								*
;	îjâÛ⁄ºﬁΩ¿	Ç»Çµ					*
;****************************************************************

.286c


CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE


PUBLIC	WAIT1

WAIT1	PROC	NEAR

	PUSHA

LOOP1:
	PUSH	CX
	MOV	CX,50000
		
		LOOP2:
			OR	AX,AX
			LOOP LOOP2
	POP CX
	LOOP	LOOP1


	POPA
	
	
	RET
	
WAIT1	ENDP
CODE	ENDS
	END
