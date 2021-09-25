;****************************************
;*					*
;*	COLOR	 PROC	¶×°‚ÌÝ’è	*
;*					*
;*	AH=Ì«±¶×°	AL=ÊÞ¯¸¶×°	*
;*	BH=Šg’£¶×°¸Þ×ÝÄÞŽw’è		*
;*	BL=Šg’£¶×°Žw’è			*
;*					*
;*	¶×°Žw’è		0`7	 	*
;*	Šg’£¸Þ×ÝÄÞ	0¥¥Ì«±	1¥¥ÊÞ¯¸	*
;*	Šg’£¶×°		0¥¥–¾‚é‚¢1¥¥ˆÃ‚¢*
;*					*
;*	LIB	UTY.LIB	“o˜^		*
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

	MOV	DH,FG			;Šg’£¶×°
	MOV	DL,FGP
	MOV	CL,0D9H
	CALL	BIOS

	MOV	DH,0			;Ì«±¸Þ×ÝÄÞ¶×°
	MOV	DL,FGC
	MOV	CL,34H
	CALL	BIOS

	MOV	DH,1			;ÊÞ¯¸¸Þ×ÝÄÞ¶×°
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