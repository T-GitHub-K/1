CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE,SS:CODE,ES:CODE

	DB	0FDH
	DW	0000H
	DW	0000H
	DW	ENDP-STARTP


;	OBASIC�����CLAA    CALL TEST(A$,B$,FLG)
;
;	SP �[�b�b�b�b�b�]
;          �a�߂�l    �a
;          �[----------�]
;          �aSEGMENT   �a
;          �[�b�b�b�b�b�]
;          �a�߂�l    �a
;          �[----------�]
;          �aOFFSET    �a
;          �[�b�b�b�b�b�]
;    [SP+4]�a FLG      �a
;          �[----------�]
;          �a FAC      �a
;          �[�b�b�b�b�b�]
;    [SP+6]�a B$       �a
;          �[----------�]
;          �a FAC      �a
;          �[�b�b�b�b�b�]
;    [SP+8]�a A$       �a
;          �[----------�]
;          �a FAC      �a
;          �^�b�b�b�b�b�`
;                        
;                                   
STARTP	EQU	$
MAIN	PROC	FAR

	MOV	BP,SP
	MOV	BX,[BP+8]	;A$
	MOV	CL,[BX]		;A$ LEN
	MOV	SI,[BX+1]	;A$ OFFSET

	MOV	BX,[BP+6]	;B$
	MOV	CH,[BX]		;B$ LEN
	MOV	DI,[BX+1]	;B$ OFFSET

	MOV	DH,1
	CMP	CH,CL
	JNE	EXIT

	XOR	DX,DX

	XOR	CH,CH
	CLD
	REP	MOVSB

EXIT:

	MOV	BX,[BP+4]	;FLG
	MOV	[BX],DH
	XOR	DH,DH
	MOV	[BX+1],DH

	RET	6

MAIN	ENDP

ENDP	EQU	$

CODE	ENDS
	END


