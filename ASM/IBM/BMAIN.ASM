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
	CALL	PARA			;ºÏÝÄÞ×²ÝÌ¶æ¾
	JC	@1			;ERROR
        MOV	AH,WORK[0]
        MOV	AL,WORK[1]
        CALL	CTOH			;·¬×¸À°ðHEXÉÏ·
        OR	AL,AL
        JZ	@1
        MOV	LEN,AL

@1:
	MOV	CX,20				;20ñÂç·
LOOP1:
	PUSH	CX

	XOR	CX,CX
	MOV	CL,LEN				;¹Ì·³iñPbj
	MOV	AX,740				;üg
	CALL	BEEP

	
	XOR	CX,CX
	MOV	CL,LEN				;¹Ì·³iñPbj
	MOV	AX,620				;üg
	CALL	BEEP


	POP	CX
	LOOP	LOOP1

	EXIT	0


LEN	DB	100
WORK	DB	256 	DUP(0)
	
	
	STACK	256

	SEGEND

	END	@S
