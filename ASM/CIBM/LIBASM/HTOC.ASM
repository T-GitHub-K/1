;****************************************************************
;	HTOC.ASM     						*
;								*
;	�P�U�i��׸���ɕϊ�					*
;								*
;	����	AL=16�i		3FH				*
;	RETURN 	AX=��׸��	3346H				*
;								*
;	�j��ڼ޽�	AX					*
;****************************************************************
	
.286c
	
	
_TEXT	SEGMENT	WORD PUBLIC 'CODE'
	ASSUME	CS:_TEXT,DS:_TEXT,ES:_TEXT,SS:_TEXT
	
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
_TEXT	ENDS
	END
