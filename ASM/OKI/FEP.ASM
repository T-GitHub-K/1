CODE	SEGMENT	
	ASSUME	CS:CODE,DS:CODE

	CALL	FEP
	MOV	AX,4C00H
	INT	21H

FEP	PROC	NEAR				;FEP		ٰ��
	MOV	CL,0BH
	MOV	BL,1
	INT	83H
FEP_EXIT:
	RET
FEP	ENDP

CODE	ENDS
	END



