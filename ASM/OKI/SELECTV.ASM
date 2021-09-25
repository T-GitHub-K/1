

;0AH 		DS:DX=�i�[�ޯ̧���ڽ

KEY_INPUT	MACRO
		PUSH	DX
		MOV	AH,09H
		MOV	DX,OFFSET CLS_C
		INT	21H
		POP	DX


		MOV	AH,0AH
		INT	21H
		ENDM

POS		MACRO
		MOV	AH,09H
		MOV	DX,OFFSET POS_C
		INT	21H
		ENDM

		
EXTRN	PARA:NEAR		;DTA�̕�����擾
EXTRN	CTOH:NEAR		;��׸�����ނ�16�i�ɕϊ�


LEN	EQU	10

CODE	SEGMENT PUBLIC
	ASSUME	CS:CODE,DS:CODE,SS:CODE,ES:CODE

	ORG	80H

DTA	DB	80H	DUP(0)

	ORG	100H


START:
		POS
;		MOV	CX,LEN
;		MOV	AL,0
;		MOV	DI,OFFSET KEY_BUF[2]
;		REP	STOSB
;------------------------------------------------------------------------------
		MOV	KEY_MAX,16H		;�����l
		MOV	SI,OFFSET DTA[0]	;�����ײ�
		MOV	DI,OFFSET WORK		;�����ײݎ擾�ޯ̧
		CALL	PARA			;�����ײ݂̕����擾
		JC	INP_KEY			;ERROR
        	MOV	AH,WORK[0]		;�P�����ړǍ� 1Byte��
        	MOV	AL,WORK[1]		;	      2Byte��
;------------------------------------------------------------------------------
		CMP	AH,'Y'			;Y/N ���͔���
		JZ	INP_KEY_YN
		CMP	AH,'y'
		JZ	INP_KEY_YN
;------------------------------------------------------------------------------
        	CALL	CTOH			;��׸����HEX�ɕϊ� AL=����
        	OR	AL,AL
        	JZ	INP_KEY			;ERROR
        	CMP	AL,16H
        	JA	INP_KEY			;ERROR
;        	CMP	AL,1H
;        	JB	INP_KEY			;ERROR
        	MOV	KEY_MAX,AL
;------------------------------------------------------------------------------
INP_KEY:
		MOV	DX,OFFSET KEY_BUF
		KEY_INPUT
;------------------------------------------------------------------------------
		MOV	AH,KEY_BUF[2]		;����1Byte��
		
		MOV	AL,KEY_BUF[1]
		CMP	AL,0
		JZ	BEEP			;���͕������Ȃ�
		CMP	AL,1			;���͂�1Byte�Ȃ̂ɂO�ȉ�
		JA	INP_SKIP
		CMP	AH,'0'
		JB	BEEP
INP_SKIP:
		CMP	AH,'9'
		JA	BEEP
;------------------------------------------------------------------------------
		MOV	AL,KEY_BUF[3]		;����2Byte��
		CMP	AX,'  '
		JE	BEEP
        	CMP	AL,'9'
        	JA	BEEP
		CMP	AH,'0'
		JAE	INP_SKIP1
		MOV	AH,'0'
INP_SKIP1:
        	CALL	CTOH			;��׸����HEX�ɕϊ� AL=����
;------------------------------------------------------------------------------
;		CMP	AL,1H
;		JB	BEEP
		CMP	AL,KEY_MAX
		JA	BEEP
;------------------------------------------------------------------------------
		CMP	AL,10H			;10H�ȏゾ������AL��6H�����ľ��
		JB	SKIP
		SUB	AL,6
SKIP:
		XOR	AH,AH
		MOV	BX,AX
		MOV	AL,CHR_DAT[BX]
		JMP	END
;------------------------------------------------------------------------------
INP_KEY_YN:
		MOV	DX,OFFSET KEY_BUF
		KEY_INPUT
		MOV	AL,KEY_BUF[2]
		CMP	AL,'Y'
		JZ	SET_Y
		CMP	AL,'y'
		JZ	SET_Y
		CMP	AL,'N'
		JZ	SET_N
		CMP	AL,'n'
		JZ	SET_N
		JMP	BEEP
SET_Y:
		MOV	AL,0H
		JMP	END
SET_N:
		MOV	AL,99
;------------------------------------------------------------------------------
END:
		MOV	AH,4CH
		INT	21H
;------------------------------------------------------------------------------
BEEP:
		MOV	AH,02H
		MOV	DL,07H
		INT	21H
		JMP	START
;------------------------------------------------------------------------------
KEY_MAX		DB	'0'
KEY_BUF		DB	3			;�ޯ̧�ő咷
		DB	0			;�ް��޲Đ�(CR�܂܂Ȃ�)
		DB	LEN	DUP(0)		;
WORK		DB	256	DUP(0)
POS_C		DB	1BH,'[22;63H$'		;���وʒu
CLS_C		DB	1BH,'[K$'		;���ق̈ʒu����s���܂Ÿر
CHR_DAT		DB	0,1,2,3,4,5,6,7,8,9,0AH,0BH,0CH,0DH,0EH,0FH,10H
;------------------------------------------------------------------------------

CODE		ENDS
		END	START

