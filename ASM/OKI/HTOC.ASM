;****************************************************************
;	HTOC.ASM     						*
;								*
;	ÇPÇUêiÇ∑¨◊∏¿∞Ç…ïœä∑					*
;								*
;	ì¸óÕ	AL=16êi		3FH				*
;	RETURN 	AX=∑¨◊∏¿∞	3346H				*
;								*
;	îjâÛ⁄ºﬁΩ¿	AX					*
;****************************************************************
	
.286c
	
	
CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE
	
PUBLIC	HTOC
	
HTOC	PROC	NEAR
	
@1:
	PUSHA
	
	MOV	DL,AL
	MOV	CL,4
	SHR	AL,CL
	CMP	AL,9				;
	JA	@2
	ADD	AL,30H
	JMP	SHORT	@3
@2:
	ADD	AL,37H
@3:
	MOV	WORK[0],AL
	
	MOV	AL,DL
	AND	AL,00001111B
	CMP	AL,9				;
	JA	@4
	ADD	AL,30H
	JMP	SHORT	@5
@4:
	ADD	AL,37H
@5:
	MOV	WORK[1],AL
	
	POPA
	
	MOV	AH,WORK[0]
	MOV	AL,WORK[1]
	
	RET
	
WORK	DB	0,0

HTOC	ENDP
CODE	ENDS
	END
