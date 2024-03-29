
CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE,SS:CODE
	ORG	100H
START:
;GET INTERRRUPT VECTOR
;ユーザ開放の割り込みテーブル開始番地
;ES:BXに割り込みルーチンの位置を返す

	PUSH	ES
	PUSH	DS

	MOV	AH,35H
	MOV	AL,0EFH
	INT	21H
	MOV	STK_OFF,BX
	MOV	STK_SEG,ES

	MOV	AH,35H
	MOV	AL,0F0H
	INT	21H
	MOV	OLD_OFF,BX
	MOV	OLD_SEG,ES

	CMP	BX,STK_OFF
	JZ	NOT_ENT
	MOV	AX,ES
	CMP	AX,STK_SEG
	JZ	NOT_ENT
;
	MOV	ES,OLD_SEG
	MOV	ES,WORD PTR ES:[002CH]
 	MOV	AH,49H
	INT	21H
	JC	ERR_END
	MOV	ES,OLD_SEG
	MOV	AH,49H
	INT	21H
	JC	ERR_END
	PUSH	DS
	MOV	DX,STK_OFF
	MOV	AX,STK_SEG
	MOV	DS,AX
	MOV	AH,25H
	MOV	AL,0F0H
	INT	21H
	POP	DS
	MOV	AH,9
	MOV	DX,OFFSET MSG
	INT	21H
	JMP	END_PRO
ERR_END:
	MOV	AH,9
	MOV	DX,OFFSET ERR_MSG
	INT	21H
	JMP	END_PRO
NOT_ENT:
	MOV	AH,9
	MOV	DX,OFFSET MSG1
	INT	21H
END_PRO:
	POP	DS
	POP	ES
	MOV	AH,4CH
	INT	21H
;
;
STK_OFF	DW	?
STK_SEG	DW	?
OLD_OFF	DW	?
OLD_SEG	DW	?
MSG	DB	'ORIGIN.COM を開放しました','$',0	
MSG1	DB	'ORIGIN.COM は常駐していません','$',0	
ERR_MSG	DB	'ORIGIN.COM 以外のプログラムが常駐した可能性があります。','$',0	
;
CODE	ENDS
	END	START

