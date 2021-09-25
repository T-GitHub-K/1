;********************************************************
;*	PALETTE.ASM					*
;* 							*
;* 	���� AH=�װڼ޽��ԍ�				*
;* 	RETURN AL=�I������				*
;* 							*
;* 	�j��ڼ޽�	AL				*
;* 							*
;*		R	G	B                   	*
;*	��گ�	00      00	00	           	*
;*		3F	3F	3F                     	*
;*                                                     	*
;********************************************************


.286c

ESC	EQU	1BH
CR	EQU	0DH


CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE


EXTRN	HTOC:NEAR				;�P�U�i���P�O�i�ɕϊ�

PUBLIC	PALETTE

PALETTE	PROC	NEAR

	PUSHA
	
	MOV	REG_NO,AH
	
	MOV	AH,10H				;�װڼ޽��ԍ�����گĂ��擾
	MOV	AL,15H
	MOV	BL,REG_NO
	INT	10H

	MOV	SGREEN,CH			;��گĂ̓��e�ۑ�
	MOV	SBULE,CL
	MOV	SRED,DH

	MOV	GREEN,CH
	MOV	BULE,CL
	MOV	RED,DH
	
	
	MOV	AX,1000H			;�װڼ޽��ԍ�����گľ��
	MOV	BL,0				;�װڼ޽��ԍ�    ��
	MOV	BH,REG_NO			;��گ�ڼ޽��ԍ�
	INT	10H
	
	CALL	MSG1

	JMP	KEY_LOOP

END_P_A:
	MOV	KEY,AL				;���ͷ��Ҕ�
	JMP	END_P
	
END_P1_A:
	MOV	KEY,AL				;���ͷ��Ҕ�
	JMP	END_P1

KEY_LOOP:

	MOV	AH,02H					;���ق̈ʒu�w��
	MOV	BH,00
	MOV	DH,01					;���W�P
	MOV	DL,01					;���W�P
	INT	10H

	CALL	MSG1					;ү���ޕ\��

	MOV	AH,08					;������
	INT	21H					;AL=��������

	CMP	AL,CR					;�ݒ�I��
	JE	END_P_A
	
	CMP	AL,"*"					;�j���I��
	JE	END_P1_A
	
	CMP	AL,ESC
	JE	END_P1_A

	CMP	AL,"+"
	JE	END_P1_A
	
	CMP	AL,"-"
	JE	END_P1_A


	CMP	AL,"1"
	JB	KEY_LOOP
	CMP	AL,"6"
	JA	KEY_LOOP

	CMP	AL,"3"
	JA	KEY_ADD

KEY_DEC:
	CMP	AL,"1"
	JE	RED_D
	CMP	AL,"2"
	JE	GREEN_D
	JMP	SHORT	BULE_D
	JMP	KEY_NEXT

RED_D:
	CMP	RED,0
	JNE	RED_D1
	JMP	KEY_E
RED_D1:
	DEC	RED
	MOV	DH,RED
	JMP	KEY_NEXT
GREEN_D:
	CMP	GREEN,0
	JE	KEY_E
	DEC	GREEN
	MOV	CH,GREEN
	JMP	KEY_NEXT
BULE_D:
	CMP	BULE,0
	JE	KEY_E
	DEC	BULE
	MOV	CL,BULE
	JMP	KEY_NEXT

KEY_ADD:
	CMP	AL,"4"
	JE	RED_A
	CMP	AL,"5"
	JE	GREEN_A
	JMP	SHORT	BULE_A
	JMP	KEY_NEXT

RED_A:
	CMP	RED,3FH
	JE	KEY_E
	INC	RED
	MOV	DH,RED
	JMP	KEY_NEXT
GREEN_A:
	CMP	GREEN,3FH
	JE	KEY_E
	INC	GREEN
	MOV	CH,GREEN
	JMP	KEY_NEXT
BULE_A:
	CMP	BULE,3FH
	JE	KEY_E
	INC	BULE
	MOV	CL,BULE

KEY_NEXT:
	MOV	AH,10H				;��گĐݒ�
	MOV	AL,10H
	MOV	BL,REG_NO
	MOV	CH,GREEN
	MOV	CL,BULE
	MOV	DH,RED
	INT	10H

KEY_E:

	CALL	MSG1
	JMP	KEY_LOOP

END_P1:						;�j���I��

	MOV	AH,10H
	MOV	AL,10H
	MOV	BL,REG_NO
	MOV	CH,SGREEN
	MOV	CL,SBULE
	MOV	DH,SRED
	INT	10H
END_P:						;�ݒ�I��

	MOV	AX,1000H			;�װڼ޽��ԍ�����گľ��
	MOV	BL,0				;�װڼ޽��ԍ�    ��
	MOV	BH,0				;��گ�ڼ޽��ԍ�  ��
	INT	10H

	POPA
	
	MOV	AL,KEY
	
	RET


MSG1	PROC	NEAR

RED_1:
	MOV	AL,RED
	CALL	HTOC
	MOV	MRED,AH
	MOV	MRED[1],AL

GREEN_1:
	MOV	AL,GREEN
	CALL	HTOC
	MOV	MGREEN,AH
	MOV	MGREEN[1],AL

BULE_1:
	MOV	AL,BULE
	CALL	HTOC
	MOV	MBULE,AH
	MOV	MBULE[1],AL

	MOV	AH,02H
	MOV	BH,00
	MOV	DH,01
	MOV	DL,01
	INT	10H

	MOV	AH,09
	MOV	DX,OFFSET MSG
	INT	21H

	RET

MSG1	ENDP
RED	DB	0
GREEN	DB	0
BULE	DB	0

SGREEN	DB	0
SBULE	DB	0
SRED	DB	0

REG_NO	DB	0
KEY	DB	0

MSG	DB	"  RED= "
MRED	DB	30H,30H
	DB	"  GREEN= "
MGREEN	DB	30H,30H
	DB	"  BULE= "
MBULE	DB	30H,30H
	DB	"$"

PALETTE ENDP

CODE	ENDS
	END
