;****************************************************************
;	BMAIN.ASM     						*
;								*
;								*
;****************************************************************

INCLUDE	STD.H

	COMSEG

@S:
	MOV	SI,OFFSET SI1
	MOV	DI,OFFSET DI1
	
	INT	65h
	
	EXIT	0
	
SI1	DB	"ABCDEFGHIJK"
DI1	DB	"12345678901"

	STACK	256

	SEGEND

	END	@S
