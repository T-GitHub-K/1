;********************************************
;�a�b�b�@�`�F�b�N
;�s�w�s�����ׂẮ@�w�n�q�@���Ƃ�@�a�b���Ɣ�r
;�b�`�k�k�i�s�w�s���C�a�b���C�e�k�f�j
;�e�k�f�@�O�F����@�P�F�G���[
;********************************************
DBG	EQU	0			;���ڎ��s
;
CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE
START:
;
IF	DBG
;********************************************
;�����������X�W����n�����������e�[�u���쐬
;********************************************
	PUSH	CS
	POP	DS
	MOV	AX,DS
	MOV	SI,OFFSET ADDTBL
	MOV	WORD PTR [SI+00H],OFFSET FFF
	MOV	WORD PTR [SI+02H],AX
	MOV	WORD PTR [SI+04H],OFFSET BADD
	MOV	WORD PTR [SI+06H],AX
	MOV	WORD PTR [SI+08H],OFFSET TADD
	MOV	WORD PTR [SI+0AH],AX
	MOV	SI,OFFSET BADD
	MOV	WORD PTR [SI+02H],OFFSET BBB
	MOV	SI,OFFSET TADD
	MOV	WORD PTR [SI+02H],OFFSET TTT
	MOV	BX,OFFSET ADDTBL
	MOV	DX,DS
JMP	NXT
	;********************************************
	;�e�X�g�p�f�[�^
	;********************************************
ADDTBL	DB	 12 DUP(?)
TTT	DB	02H,05H,02H
TADD	DB	03H,00H,00H,00H
BBB	DB	05H
BADD	DB	01H,00H,00H,00H
FFF	DW	00H
NXT:
ENDIF
;
	;*******************************************
	;�e���W�X�^�ޔ�
	;*******************************************
	IRP	DUM,<AX,BX,CX,DX,SI,DI,DS,ES>
		PUSH	DUM
	ENDM
	;*******************************************
	;�������e�[�u���p�Z�O�����g�I�t�Z�b�g
	;*******************************************
	PUSH	SS
	PUSH	DX
	PUSH	DS
	PUSH	BX
	PUSH	CS			;DS=CS
	POP	DS
	POP	AX			;�������e�[�u��BX�Z�b�g
	MOV	SAV_BX,AX
	POP	AX			;�������e�[�u��DS�Z�b�g
	MOV	SAV_DS,AX
	POP	AX			;DX�ޔ�(�����̃Z�O�����g�p)
	MOV	SAV_DX,AX
	POP	AX			;�����P�[�V�����R�[�h�O�ȊO
	MOV	SAV_SS,AX
	;********************************************
	;�e�[�u���Z�O�����g�I�t�Z�b�g
	;********************************************
	MOV	BX,SAV_BX
	MOV	AX,SAV_DS
	MOV	ES,AX
	MOV	AX,WORD PTR ES:[BX+0AH]	;�Z�O�����g
	MOV	SI,WORD PTR ES:[BX+08H]	;�I�t�Z�b�g
	MOV	ES,AX
	;********************************************
	;�X�g�����O�f�B�X�N���v�^�̃f�[�^���
	;********************************************
	MOV	AH,BYTE PTR ES:[SI]	;����
	INC	SI
	MOV	AL,BYTE PTR ES:[SI]	;�����̃����P�[�V�����R�[�h
	INC	SI
	MOV	BX,WORD PTR ES:[SI]	;�����̃I�t�Z�b�g�A�h���X
	MOV	SI,BX			;�����]���p�A�h���X
	;********************************************
	;�����P�[�V�����R�[�h�ɂ���ĕ����̃Z�O�����g�Z�b�g
	;********************************************
	MOV	DX,SAV_DX		;�e�[�u���Z�O�����g
	MOV	BX,SAV_SS		;�����̃Z�O�����g(�e�L�X�g�Z�O�����g��)
	MOV	ES,DX			;
	CMP	AL,00H
	JE	BCC_CHK
	MOV	ES,BX			;
BCC_CHK:
	;********************************************
	;�w�n�q������
	;********************************************
	XOR	DX,DX
	;********************************************
	;�����J�E���^�[�Z�b�g
	;********************************************
	XOR	CX,CX
	MOV	CL,AH
	CLD
REP:
	MOV	DL,BYTE PTR ES:[SI]
	XOR	DH,DL
	INC	SI
	LOOP	REP
;
	PUSH	DX			;�w�n�q�̌��ʑޔ�(DH)
;
	;********************************************
	;�e�[�u���Z�O�����g�I�t�Z�b�g
	;********************************************
	MOV	BX,SAV_BX
	MOV	AX,SAV_DS
	MOV	ES,AX
	MOV	AX,WORD PTR ES:[BX+06H]	;�Z�O�����g
	MOV	SI,WORD PTR ES:[BX+04H]	;�I�t�Z�b�g
	MOV	ES,AX
	;********************************************
	;�X�g�����O�f�B�X�N���v�^�̃f�[�^���
	;********************************************
	MOV	AH,BYTE PTR ES:[SI]	;����
	INC	SI
	MOV	AL,BYTE PTR ES:[SI]	;�����̃����P�[�V�����R�[�h
	INC	SI
	MOV	BX,WORD PTR ES:[SI]	;�����̃I�t�Z�b�g�A�h���X
	MOV	SI,BX			;�����]���p�A�h���X
	;********************************************
	;�����P�[�V�����R�[�h�ɂ���ĕ����̃Z�O�����g�Z�b�g
	;********************************************
	MOV	DX,SAV_DX		;�e�[�u���Z�O�����g
	MOV	BX,SAV_SS		;�����̃Z�O�����g(�e�L�X�g�Z�O�����g��)
	MOV	ES,DX			;
	CMP	AL,00H
	JE	BCC_CHK2
	MOV	ES,BX			;
BCC_CHK2:
	;********************************************
	;�s�w�s�Ƃa�b�b��r
	;********************************************
;
	POP	DX
;
	MOV	DL,BYTE PTR ES:[SI]	;�a�b�b�̒��g
	MOV	BYTE PTR ES:[SI],DH	;�s�w�s�̂w�n�q���ʂ��a�b�b�ɃZ�b�g
	CMP	DH,DL
	JE	PRO_END
	;********************************************
	;�e�[�u���̂����A�h���X�ɃZ�b�g
	;********************************************
	MOV	BX,SAV_BX
	MOV	AX,SAV_DS
	MOV	ES,AX
	MOV	AX,WORD PTR ES:[BX+02H]	;�Z�O�����g
	MOV	SI,WORD PTR ES:[BX+00H]	;�I�t�Z�b�g
	MOV	ES,AX
	MOV	WORD PTR ES:[SI],01H	;���l
PRO_END:
	;********************************************
	;�ޔ��f�[�^���ɖ߂�
	;********************************************
	IRP	DUM,<ES,DS,DI,SI,DX,CX,BX,AX>	;�e���W�X�^
	POP	DUM
	ENDM
	;********************************************
	;�v���O�����G���h
	;********************************************
IF	DBG
	MOV	AH,4CH
	INT	21H
ENDIF
	IRET
;
;********************************************
;���W�X�^�ޔ�p�f�[�^
;********************************************
SAV_BX	DW	  1 DUP(?)
SAV_DS	DW	  1 DUP(?)
SAV_DX	DW	  1 DUP(?)
SAV_SS	DW	  1 DUP(?)
;********************************************
;
;********************************************
CODE	ENDS
	END	START
