

;0AH 		DS:DX=格納ﾊﾞｯﾌｧｱﾄﾞﾚｽ

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

		
EXTRN	PARA:NEAR		;DTAの文字列取得
EXTRN	CTOH:NEAR		;ｷｬﾗｸﾀｰｺｰﾄﾞを16進に変換


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
		MOV	KEY_MAX,16H		;初期値
		MOV	SI,OFFSET DTA[0]	;ｺﾏﾝﾄﾞﾗｲﾝ
		MOV	DI,OFFSET WORK		;ｺﾏﾝﾄﾞﾗｲﾝ取得ﾊﾞｯﾌｧ
		CALL	PARA			;ｺﾏﾝﾄﾞﾗｲﾝの文字取得
		JC	INP_KEY			;ERROR
        	MOV	AH,WORK[0]		;１文字目読込 1Byte目
        	MOV	AL,WORK[1]		;	      2Byte目
;------------------------------------------------------------------------------
		CMP	AH,'Y'			;Y/N 入力判定
		JZ	INP_KEY_YN
		CMP	AH,'y'
		JZ	INP_KEY_YN
;------------------------------------------------------------------------------
        	CALL	CTOH			;ｷｬﾗｸﾀｰをHEXに変換 AL=ｺｰﾄﾞ
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
		MOV	AH,KEY_BUF[2]		;入力1Byte目
		
		MOV	AL,KEY_BUF[1]
		CMP	AL,0
		JZ	BEEP			;入力文字がない
		CMP	AL,1			;入力が1Byteなのに０以下
		JA	INP_SKIP
		CMP	AH,'0'
		JB	BEEP
INP_SKIP:
		CMP	AH,'9'
		JA	BEEP
;------------------------------------------------------------------------------
		MOV	AL,KEY_BUF[3]		;入力2Byte目
		CMP	AX,'  '
		JE	BEEP
        	CMP	AL,'9'
        	JA	BEEP
		CMP	AH,'0'
		JAE	INP_SKIP1
		MOV	AH,'0'
INP_SKIP1:
        	CALL	CTOH			;ｷｬﾗｸﾀｰをHEXに変換 AL=ｺｰﾄﾞ
;------------------------------------------------------------------------------
;		CMP	AL,1H
;		JB	BEEP
		CMP	AL,KEY_MAX
		JA	BEEP
;------------------------------------------------------------------------------
		CMP	AL,10H			;10H以上だったらALに6H引いてｾｯﾄ
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
KEY_BUF		DB	3			;ﾊﾞｯﾌｧ最大長
		DB	0			;ﾃﾞｰﾀﾊﾞｲﾄ数(CR含まない)
		DB	LEN	DUP(0)		;
WORK		DB	256	DUP(0)
POS_C		DB	1BH,'[22;63H$'		;ｶｰｿﾙ位置
CLS_C		DB	1BH,'[K$'		;ｶｰｿﾙの位置から行末までｸﾘｱ
CHR_DAT		DB	0,1,2,3,4,5,6,7,8,9,0AH,0BH,0CH,0DH,0EH,0FH,10H
;------------------------------------------------------------------------------

CODE		ENDS
		END	START

