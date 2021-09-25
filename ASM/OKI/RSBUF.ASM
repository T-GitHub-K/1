;****************************************************************
;*	�q�r�|�Q�R�Q�b �o�b�t�@�T�C�Y�ύX�Ղ�			*
;*								*
;*	�l�r�|�c�n�r �����������P�x�������s����			*
;*	��)�o�b�t�@�r�W�[����͖����ɂȂ�        		*
;*	92.11.28	T.K			Ver 1.20	*
;****************************************************************
INCLUDE	STD.H

BUFSIZE	EQU	256			;�ޯ̧���� ��̫��


CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,SS:CODE,ES:CODE


	ORG	80H
DTA	DB	80H	DUP(?)
	ORG	100H
	

START:
	JMP	S1

BUF_SIZE	DW	0		;SET BUFFER
BUFSTK	DW	0			;BUFFER
MSG	DB 	"RSBUF 	Ver 1.20",CR,LF
	DB	"�q�r�|�Q�R�Q�b�̃o�b�t�@�T�C�Y�� "
BUFS	DB	0,0,0,0," ���� "
BUF	DB	0,0,0,0
	DB	" �o�C�g�ɕύX���܂����B",CR,LF
	DB	"��) �o�b�t�@�r�W�[����͖����ɂȂ�܂��B",CR,LF
	DB	"$"
;
;	16�i����10�i�ɕϊ�  10�̈ʂ܂�
;

SUB_S	PROC	NEAR
	MOV	AX,BX
	MOV	BX,10
	XOR	DX,DX
	DIV	BX
	ADD	AL,30H
	ADD	DL,30H
	MOV	BH,AL
	MOV	BL,DL
	RET
SUB_S	ENDP

;
;	16�i����10�i�ɕϊ�  1000�̈ʂ܂�
;

SUB_S1	PROC	NEAR
	MOV	AX,BX
	MOV	BX,1000
	XOR	DX,DX
	DIV	BX
	ADD	AL,30H
	MOV	CH,AL
	MOV	AX,DX
	XOR	DX,DX
	MOV	BX,100
	DIV	BX
	ADD	AL,30H
	MOV	CL,AL
	MOV	BX,DX
	CALL	SUB_S
	RET
SUB_S1	ENDP

;		�������擪�A�h���X'SI'�ɃZ�b�g�������� 'CX'�ɃZ�b�g
PARA_SET	PROC	NEAR
		CLD
		MOV	CX,0
PARA1:
		LODSB
		CMP	AL,CR
		JE	PARA_END
		CMP	AL,SPC
		JE	PARA1
		CMP	AL,","
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

;
;	�A�X�L�[�R�[�h(30H-39H)�@�����ɕϊ�
;
;	DI�ɃL�����N�^�[�A�h���X�Z�b�g
;	������Ō�ɂb�q���Z�b�g���Ă���
;


ASC_TO_HEX	PROC	NEAR
ASC_LOOP:	MOV	AL,[DI]
		CMP	AL,CR
		JE	ASC_NEXT
		INC	DI
		LOOP	ASC_LOOP
ASC_NEXT:
		XOR	BX,BX
		MOV	CX,1
		CALL	ASC_SUB
		MOV	CX,10
		CALL	ASC_SUB
		MOV	CX,100
		CALL	ASC_SUB
		MOV	CX,1000
		CALL	ASC_SUB
		MOV	CX,10000
		CALL	ASC_SUB
		RET
ASC_TO_HEX	ENDP


ASC_SUB		PROC	NEAR
		DEC	DI
		MOV	AL,[DI]
		CMP	AL," "
		JE	ASC_SUB_END
		SUB	AL,"0"-1
ASC_SUB_1:
		DEC	AL
		JE	ALL_END
		ADD	BX,CX
		JMP	SHORT	ASC_SUB_1
ASC_SUB_END:	POP	AX
ALL_END:	RET

ASC_SUB		ENDP





;************************************************************************
;	�R�}���h���C���ɂ���p�����[�^�[���o��			*
;*****************************   �l�`�h�m  ******************************

S1:
		MOV	SI,OFFSET DTA[0]
		CMP	BYTE PTR [SI],0
		JNE	NEXT
		JMP	PARA_ERR
NEXT:		INC	SI
		CALL	PARA_SET
		JNC	S2
		JMP	PARA_ERR
;
;	�p�����[�^�[���`�F�b�N
;	�L�����N�^�[�`�F�b�N 30H-39H
;

S2:
		CMP	CX,4
		JBE	S3
		JMP	PARA_ERR
S3:
		XOR	BX,BX
LOOP1:		MOV	AL,[SI+BX]
		CMP	AL,30H
		JB	L_ERR
		CMP	AL,39H
		JA	L_ERR
		INC	BX
		LOOP	LOOP1
		JMP	S4
L_ERR:		
		JMP	PARA_ERR
;
;	�p�����^�[�Z�b�g BUF_SIZE
;
;	�R�~���j�P�[�V���� COM BUFFRER �i�[�A�h���X���o��
;
;		BIOS CALL CL,6F

S4:
		MOV	DI,SI
		MOV	BYTE PTR [DI-1]," "
		CALL	ASC_TO_HEX
		MOV	BUF_SIZE,BX
S5:

	PUSH	ES
	MOV	CL,6FH
	XOR	AX,AX
	INT	80H

	MOV	BX,AX
	MOV	BX,ES:[BX+2]
	MOV	AX,ES:[BX+4]
	MOV	BUFSTK,AX
	MOV	AX,BUF_SIZE
	MOV	WORD PTR ES:[BX+4],AX

	POP	ES
	MOV	BX,BUFSTK
	CALL	SUB_S1
	MOV	BUFS[0],CH
	MOV	BUFS[1],CL
	MOV	BUFS[2],AL
	MOV	BUFS[3],DL

	MOV	BX,BUF_SIZE
	CALL	SUB_S1
	MOV	BUF[0],CH
	MOV	BUF[1],CL
	MOV	BUF[2],AL
	MOV	BUF[3],DL

MSGOUT:	
	MOV	CL,0D7H
	MOV	DX,OFFSET MSG
	INT	80H

	MOV	AX,4C00H
	INT	21H

PARA_ERR:
		MOV	WORD PTR BUF_SIZE,BUFSIZE
		JMP	SHORT	S5


CODE	ENDS
	END	START
