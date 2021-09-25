;****************************************************************
;*								*
;*	∑-Œﬁ-ƒﬁ ﬁØÃßÇ…Çe9Çíºê⁄ì¸óÕ				*
;*								*
;****************************************************************


INCLUDE STD.H
INCLUDE MDOS.H

	COMSEG


INPF9	PROC	NEAR

START:
	MOV	AX,CS
	MOV	DS,AX
	MOV	ES,AX

	MOV	AX,0500H
	MOV	CX,4300H
	INT	16H
	
	

	END_PROCESS		;MACRO	RETURN_CODE

INPF9	ENDP

	SEGEND

	END	START
