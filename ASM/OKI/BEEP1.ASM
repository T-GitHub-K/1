
WAIT_DT	EQU	0


CODE	SEGMENT
	ASSUME	CS:CODE


ORG	100H
	
START:	MOV	BH,20

A:
	CALL	WAIT_S

	PUSH	BX
	MOV	CL,78H
	MOV	AX,630
	MOV	DX,22
	MOV	CH,0
	INT	80H

	MOV	BL,0FFH
LOOP:	DEC	BL
	OR	BL,BL
	JNZ	LOOP

	MOV	CL,78H
	MOV	AX,630
	MOV	DX,22
	MOV	CH,0
	INT	80H

	MOV	CL,78H
	MOV	AX,740
	MOV	DX,20
	MOV	CH,0
	INT	80H

	MOV	BL,0FFH
LOOP1:	DEC	BL
	OR	BL,BL
	JNZ	LOOP1

	MOV	CL,78H
	MOV	AX,740
	MOV	DX,20
	MOV	CH,0
	INT	80H

	POP	BX
	DEC	BH
	OR	BH,BH
	JNZ	A

	MOV	AH,4CH
	INT	21H

WAIT_S	PROC
	MOV	CX,WAIT_DT
   WAIT_T:
	MOV	AX,0FFFFH
      WAIT_TT:
		DEC	AX
		OR 	AX,AX
		JNE	WAIT_TT
   LOOP	WAIT_T
	RET
WAIT_S	ENDP

CODE	ENDS
	END	START
