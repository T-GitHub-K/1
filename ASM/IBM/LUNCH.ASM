;****************************************************************
;	LUNCH TIME    						*
;								*
;	TIMER 割り込みテストプロ				*
;****************************************************************

INCLUDE	STD.H
INT_NO	EQU	1CH
CO_NO	EQU	0EH

	COMSEG

@S:	JMP	SET

OLD_OFF	DW	0
OLD_SEG	DW	0
SIN	DB	"LUNCH"

ENT:
	PUSHA
	PUSH	ES
	PUSH	DS

	MOV	AX,CS
	MOV	DS,AX
TIM:	
;-----------------------------------------TIMER
	MOV	AH,02
	INT	1AH
	
	CMP	CH,12H
	JNE	J1
	CMP	CL,00
	JNE	J1
	JMP	SHORT DISP1

J1:
	JMP	END_T1
;-------------------------------------------------	
DISP:
	CMP	FLG,1
	JE	DISP1
	JMP	END_T1
DISP1:
	CALL	SUB3
	MOV	AX,0B800H
	MOV	ES,AX
	XOR	DI,DI
	MOV	AH,0FEH
	INT	10H
	
	CLD
	MOV	DI,STK_DI
	JMP	L1
	
	MOV	SI,OFFSET MSGCLS
	MOV	CX,20
	REP	MOVSB
	
	MOV	DI,STK_DI
	MOV	CX,10
	MOV	AH,0FFH
	INT	10H
L1:
	ADD	DI,20
	CMP	DI,4000
	JB	J2
	MOV	DI,0
J2:	
	MOV	STK_DI,DI
	
	MOV	SI,OFFSET MSG
	MOV	CX,20
	REP	MOVSB
	
	MOV	DI,STK_DI
	MOV	CX,10
	MOV	AH,0FFH
	INT	10H
	
END_T1:	
	POP	DS
	POP	ES
	POPA
	JMP	DWORD PTR CS:OLD_OFF


MSG	DB	"L",CO_NO,"U",CO_NO,"N",CO_NO,"C",CO_NO,"H",CO_NO
	DB	"T",CO_NO,"I",CO_NO,"M",CO_NO,"E",CO_NO," ",CO_NO
MSGCLS	DB	" ",0," ",0," ",0," ",0," ",0
      	DB	" ",0," ",0," ",0," ",0," ",0
STK_DI	DW	0
STK_CH	DB	0
STK_CL	DB	0
STK_DH	DB	0
STK_P	DW	0
COUNT	DB	0
FLG	DB	0

SUB	PROC	NEAR
	
@1:
	PUSHA
	
	MOV	DL,AL
	MOV	CL,4
	SHR	AL,CL
	CMP	AL,9				;
	JA	@2
	ADD	AL,30H
	JMP	SHORT	@3
@2:
	ADD	AL,37H
@3:
	MOV	WORK[0],AL
	
	MOV	AL,DL
	AND	AL,00001111B
	CMP	AL,9				;
	JA	@4
	ADD	AL,30H
	JMP	SHORT	@5
@4:
	ADD	AL,37H
@5:
	MOV	WORK[1],AL
	
	POPA
	
	MOV	AH,WORK[0]
	MOV	AL,WORK[1]
	
	RET
	
WORK	DB	0,0

SUB	ENDP

SUB1	PROC	NEAR

	PUSHA
	
	MOV	HZ,AX
	MOV	LEN,CX
	
	MOV	DX,18
	MOV	AX,13550		;DX:AX=1193180
	MOV	BX,HZ
	
	DIV	BX			;COUNT=1193180/HZ(周波数)
					;商 >> AX  余り >> DX
	
	MOV	C,AX
	
	MOV	AL,0B6H			;TIMER ﾁｯﾌﾟのREADY
	OUT	43H,AL
	
	MOV	AX,C
	
	OUT	42H,AL			;COUNT の下位ﾊﾞｲﾄ送出
	XCHG	AH,AL
	OUT	42H,AL			;COUNT の上位ﾊﾞｲﾄの送出
	
	IN	AL,61H
	OR	AL,3
	OUT	61H,AL			;ｽﾋﾟｰｶｰ ON
	
	MOV	CX,LEN			;音長
	CALL	SUB2
	
	IN	AL,61H
	AND	AL,11111100B
	OUT	61H,AL			;ｽﾋﾟｰｶｰ OFF

	POPA

	RET


C	DW	0
HZ	DW	0
LEN	DW	0


SUB1	ENDP

SUB2	PROC	NEAR

	PUSHA

LOOP1:
	PUSH	CX
	MOV	CX,5000
		
		LOOP2:
			OR	AX,AX
			LOOP LOOP2
	POP CX
	LOOP	LOOP1


	POPA
	
	
	RET
	
SUB2	ENDP

SUB3	PROC	NEAR

	PUSHA
	MOV	CX,100
	MOV	AX,440				;周波数（ド）
	CALL	SUB1
	MOV	AX,20
	CALL	SUB1

	MOV	AX,495				;周波数（ド）
	CALL	SUB1
	MOV	AX,20
	CALL	SUB1

	MOV	AX,560				;周波数（ド）
	CALL	SUB1
	MOV	AX,20
	CALL	SUB1

	MOV	AX,585				;周波数（ド）
	CALL	SUB1
	MOV	AX,20
	CALL	SUB1

	MOV	AX,660				;周波数（ド）
	CALL	SUB1
	MOV	AX,20
	CALL	SUB1

	MOV	AX,740				;周波数（ド）
	CALL	SUB1
	MOV	AX,20
	CALL	SUB1

	MOV	AX,820				;周波数（ド）
	CALL	SUB1
	MOV	AX,20
	CALL	SUB1

	MOV	AX,880				;周波数（ド）
	CALL	SUB1
	MOV	AX,20
	CALL	SUB1

	POPA
	RET
	
SUB3	ENDP


	STACK	128
	EVEN
SIZE1	EQU	$




SET:
	MOV	AH,35H
	MOV	AL,INT_NO
	INT	21H
	MOV	OLD_OFF,BX
	MOV	OLD_SEG,ES

	SUB	BX,5
	MOV	DI,BX
	MOV	SI,OFFSET CHK
	MOV	CX,5
	REPZ	CMPSB
	JNE	INT_SET
	
	MOV	AH,09
	MOV	DX,OFFSET M0
	INT	21H
	
	MOV	BX,OLD_OFF
	MOV	ES,OLD_SEG
	MOV	DX,ES:[BX-9]
	MOV	DS,ES:[BX-7]
	MOV	AH,25H
	MOV	AL,INT_NO
	INT	21H
	
	MOV	ES,CS:OLD_SEG
	MOV	ES,WORD PTR ES:[002CH]
	MOV	AH,49H
	INT	21H
	MOV	ES,CS:OLD_SEG
	MOV	AH,49H
	INT	21H
	
	EXIT

INT_SET:
	MOV	AH,09H
	MOV	DX,OFFSET M1
	INT	21H
	
	MOV	DX,OFFSET ENT
	MOV	AH,25H
	MOV	AL,INT_NO
	INT	21H
	
	MOV	DX,OFFSET SIZE1
	MOV	CL,4
	SHR	DX,CL
	MOV	AX,3100H
	INT	21H
	
	EXIT
	
CHK	DB	"LUNCH",0
M0	DB	"LUNCHTIME 解放しました。$"
M1	DB	"LUNCHTIME 常駐しました。$"
	
	SEGEND

	END	@S
