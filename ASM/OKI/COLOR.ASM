;****************************************
;*					*
;*	COLOR	 PROC	�װ�̐ݒ�	*
;*					*
;*	AH=̫��װ	AL=�ޯ��װ	*
;*	BH=�g���װ�����ގw��		*
;*	BL=�g���װ�w��			*
;*					*
;*	�װ�w��		0�`7	 	*
;*	�g��������	0��̫�	1���ޯ�	*
;*	�g���װ		0�����邢1���Â�*
;*					*
;*	LIB	UTY.LIB	�o�^		*
;****************************************

INCLUDE	MDOS.H
INCLUDE	STD.H

CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE

PUBLIC	COLOR

COLOR	PROC	NEAR

	PUSHA

	MOV	FGC,AH
	MOV	BGC,AL
	MOV	FG,BH
	MOV	FGP,BL

	MOV	DH,FG			;�g���װ
	MOV	DL,FGP
	MOV	CL,0D9H
	CALL	BIOS

	MOV	DH,0			;̫������޶װ
	MOV	DL,FGC
	MOV	CL,34H
	CALL	BIOS

	MOV	DH,1			;�ޯ������޶װ
	MOV	DL,BGC
	MOV	CL,34H
	CALL	BIOS

	POPA
	RET

BIOS	PROC	NEAR
	PUSH	ES
	INT	80H
	POP	ES
	RET
BIOS	ENDP

FG	DB	0
FGP	DB	0
FGC	DB	0
BGC	DB	0


COLOR	ENDP
CODE	ENDS
	END
