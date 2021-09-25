;****************************************************************
;*	64�̃J���[���W�X�^����ʂŕ\���m�F�Z�b�g		*
;*								*
;*	�b�q=�ݒ�  �d�r�b=���~  ��=�I���@'�{'=�� '�|'=�O"	*
;*								*
;*	DSPXXGA �͂ł��Ȃ�					*
;*								*
;*	DSPXXGA���Z�b�g����O�ɕύX����DSPXXGA���N�������	*
;*	���Ȃ�						*
;*								*
;****************************************************************


.286c

CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE


	ORG	100H
		
EXTRN	PALETTE:NEAR
EXTRN	HTOC:NEAR

PUBLIC	PALMAIN

PALMAIN	PROC	NEAR

START:
	MOV	AX,CS
	MOV	DS,AX
	MOV	ES,AX

	MOV	AH,02H
	MOV	BH,00
	MOV	DH,02				;�x���W
	MOV	DL,00				;�w���W
	INT	10H

	MOV	AH,09
	MOV	DX,OFFSET SMSG
	INT	21H

	XOR	AX,AX

LOOP1:

	PUSH	AX
	CALL	MSG1
	CALL	PALETTE			;AH=PAL�ԍ�   RETURN AL=�I������
	MOV	KEY,AL
	POP	AX
	
	MOV	AL,KEY
	
	CMP	AL,"*"
	JE	END_P
	
	CMP	AL,"-"
	JE	@1
	
	INC	AH
	INC	AH
	
@1:
	CMP	AH,0
	JNE	@2
	MOV	AH,3FH
	JMP	SHORT @3
@2:
	DEC	AH
@3:
	CMP	AH,3FH
	JBE	@4
	MOV	AH,0
@4:
	JMP	LOOP1

END_P:
	MOV	AX,4C00H
	INT	21H


MSG1	PROC	NEAR

RED_1:
	PUSHA
	
	MOV	AL,AH
	CALL	HTOC
	MOV	M,AH
	MOV	M[1],AL

	MOV	AH,02H
	MOV	BH,00
	MOV	DH,00
	MOV	DL,00
	INT	10H

	MOV	AH,09
	MOV	DX,OFFSET MSG
	INT	21H

	POPA
	
	RET

MSG1	ENDP



KEY	DB	0

MSG	DB	"  ��گĔԍ�= "
M	DB	30H,30H
	DB	"$"

SMSG	DB	"�b�q=�ݒ�  �d�r�b=���~  ��=�I���@'�{'=�� '�|'=�O"
	DB	0DH,0AH,0DH,0AH
	DB	"$"

PALMAIN	ENDP

CODE	ENDS
	END	START

