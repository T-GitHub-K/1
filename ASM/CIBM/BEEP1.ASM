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
	CALL	PARA			;�����ײ݂̕����擾
	JC	@1			;ERROR
        MOV	AH,WORK[0]
        MOV	AL,WORK[1]
        CALL	CTOH			;��׸����HEX�ɕϊ�
        OR	AL,AL
        JZ	@1
        MOV	LEN,AL

@1:
	MOV	CX,3				;1��炷
LOOP1:
	PUSH	CX

	MOV	AX,440				;���g���i�h�j
	CALL	SUB
	
	MOV	AX,20
	CALL	SUB

	MOV	DL,LEN
	PUSH	DX
	MOV	DL,50
	ADD	DL,LEN
	MOV	LEN,DL
	
	MOV	AX,440				;���g���i���j
	CALL	SUB
	
	POP	DX
	MOV	LEN,DL
	
	MOV	AX,20
	CALL	SUB
	
	MOV	DL,LEN
	PUSH	DX
	MOV	DL,100
	ADD	DL,LEN
	MOV	LEN,DL
	
	MOV	AX,660				;���g���i���j
	CALL	SUB
	
	POP	DX
	MOV	LEN,DL

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