;****************************************************************
;	CTOH.ASM     						*
;								*
;	��׸�����P�U�i�ɕϊ�					*
;								*
;	����	AX=��׸������	3346H				*
;	RETURN 	AL=16�i		3FH				*
;								*
;	�j��ڼ޽�	AL					*
;****************************************************************
	
.286c
	
	
_TEXT	SEGMENT	WORD PUBLIC 'CODE'
	ASSUME	CS:_TEXT,DS:_TEXT,ES:_TEXT,SS:_TEXT
	
PUBLIC	CTOH
	
CTOH	PROC	NEAR
	
@1:
	PUSHA
	
	MOV	CHR,AX
	XCHG	AH,AL
	
	CMP	AL,30H				;��׸������ 0��菬����
	JB	@2
	CMP	AL,46H				;��׸������ F���傫��
	JA	@2
	CMP	AL,39H
	JA	@3
	SUB	AL,30H				;0-9
	MOV	WORK,AL
	JMP	SHORT @4
	
@2:
	MOV	AL,0
	JMP	@E				;ERROR
	
@3:
	SUB	AL,37H				;9���傫��  A-F
	MOV	WORK,AL
	
@4:
	MOV	AX,CHR
	
	CMP	AL,30H				;��׸������ 0��菬����
	JB	@2
	CMP	AL,46H				;��׸������ F���傫��
	JA	@2
	CMP	AL,39H
	JA	@5
	SUB	AL,30H
	MOV	WORK[1],AL
	JMP	SHORT @6
	
@5:
	SUB	AL,37H
	MOV	WORK[1],AL
	
@6:
	MOV	AL,WORK
	MOV	CL,4
	SHL	AL,CL
	OR	AL,WORK[1]
	MOV	WORK,AL
	
@E:
	POPA

	MOV	AL,WORK

	RET

CHR	DW	0
WORK	DB	0,0

CTOH	ENDP
_TEXT	ENDS
	END
