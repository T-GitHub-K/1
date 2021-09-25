IF1
%OUT STD.H		READ_START
ENDIF
;----------------------------------------------------------------
;	286 ͯ�ް						
;								
;	CPU 286�̊g�����߃Z�b�g					
;----------------------------------------------------------------

.286c

NUL	EQU	0H
BREAK	EQU	03H
BS	EQU	08H
LF	EQU	0AH
CR	EQU	0DH
CLS	EQU	1AH
ESC	EQU	1BH
HOME	EQU	1EH
SPC	EQU	20H
DEL	EQU	7FH
EOF	EQU	-1
INS	EQU	12H
TAB	EQU	09H
;-----------------------------------------------------------------------------
EXTRN	BEEP:NEAR		;���Ȃ炷
EXTRN	CTOH:NEAR		;��׸����HEX�ɕϊ�
EXTRN	HTOC:NEAR		;HEX��׸���ɕϊ�
EXTRN	PALETTE:NEAR	;�w����گĂ���ʂɕ\��
EXTRN	PARA:NEAR		;DTA�̕�����擾
EXTRN	WAIT1:NEAR		;����
;-----------------------------------------------------------------------------
;
;
;	�l�`�b�q�n
;
;

;--�Z�O�����g-------------------------------------------------------

PSEG	MACRO

	CODE	SEGMENT	PUBLIC
			ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE
ENDM

;--COM�`���̃Z�O�����g-----------------------------------------------

COMSEG	MACRO

	CODE	SEGMENT	PUBLIC
			ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE

			ORG	80H
			DTA	DB	80H 	DUP(0)
			ORG	100H
ENDM

;--�Z�O�����g�̏I���------------------------------------------------
SEGEND	MACRO
			CODE	ENDS
ENDM

;--�v���Z�X�I��------------------------------------------------------
EXIT	MACRO	REG
			
	IFNB	<REG>
			MOV	AL,REG
	ELSE
			XOR AL,AL
	ENDIF
			MOV	AH,4CH
			INT	21H
ENDM
;--�X�^�b�N----------------------------------------------------------
STACK	MACRO	SIZE
			
	IFNB	<SIZE>
			STACK_D		DB	SIZE	DUP(0)
	ELSE
			STACK_D		DB	128		DUP(0)
	ENDIF
ENDM

IF1
%OUT STD.H		READ_END
ENDIF
