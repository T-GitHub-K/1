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
	CALL	PARA			;ΊΟέΔήΧ²έΜΆζΎ
	JC	@1			;ERROR
        MOV	AH,WORK[0]
        MOV	AL,WORK[1]
        CALL	CTOH			;·¬ΧΈΐ°πHEXΙΟ·
        OR	AL,AL
        JZ	@1
        MOV	LEN,AL

@1:
	MOV	CX,1				;20ρΒη·
LOOP1:
	PUSH	CX

	MOV	AX,440				;όgihj
	CALL	SUB
	MOV	AX,20
	CALL	SUB

	MOV	AX,495				;όgihj
	CALL	SUB
	MOV	AX,20
	CALL	SUB

	MOV	AX,560				;όgihj
	CALL	SUB
	MOV	AX,20
	CALL	SUB

	MOV	AX,585				;όgihj
	CALL	SUB
	MOV	AX,20
	CALL	SUB

	MOV	AX,660				;όgihj
	CALL	SUB
	MOV	AX,20
	CALL	SUB

	MOV	AX,740				;όgihj
	CALL	SUB
	MOV	AX,20
	CALL	SUB

	MOV	AX,820				;όgihj
	CALL	SUB
	MOV	AX,20
	CALL	SUB

	MOV	AX,880				;όgihj
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