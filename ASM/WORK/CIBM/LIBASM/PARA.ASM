;****************************************************************
;	PARA.ASM     						*
;								*
;	SI>>文字列アドレス					*
;	DI>>格納アドレス					*
;								*
;	破壊レジスタ	SI,DI   				*
;								*
;****************************************************************

.286c

INCLUDE STD.H

_TEXT	SEGMENT	WORD PUBLIC 'CODE'
	ASSUME	CS:_TEXT,DS:_TEXT,ES:_TEXT,SS:_TEXT


PUBLIC	PARA

PARA	PROC	NEAR

	PUSH	AX
	PUSH	CX

@S:
		CMP	BYTE PTR [SI],0
		JNE	@0
		STC
		JMP	SHORT @2
@0:		INC	SI
		CALL	PARA_SET
		JNC	@1
		JMP	SHORT @2
@1:
		REP	MOVSB

@2:
	POP	CX
	POP	AX
	
		RET



PARA_SET	PROC	NEAR
		MOV	CX,0
PARA1:
		LODSB
		CMP	AL,CR
		JE	PARA_END
		CMP	AL,SPC
		JE	PARA1
		CMP	AL,","
		JE	PARA1
		CMP	AL,"/"
		JE	PARA1
		CMP	AL,TAB
		JE	PARA1
		
		PUSH	SI
PARA_CHR:
		INC	CX
		LODSB
		CMP	AL,CR
		JE	CHR_END
		CMP	AL,SPC
		JE	CHR_END
		CMP	AL,","
		JE	CHR_END
		CMP	AL,"/"
		JE	CHR_END
		CMP	AL,TAB
		JE	CHR_END
		JMP	SHORT	PARA_CHR

PARA_END:
		STC
		JMP	SHORT	PARA_EXIT
CHR_END:
		POP	SI
		DEC	SI
		CLC
PARA_EXIT:
		RET
PARA_SET	ENDP


PARA	ENDP
_TEXT	ENDS
	END	@S
