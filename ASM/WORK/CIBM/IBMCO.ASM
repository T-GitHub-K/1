;********************************************************
;*	IBMCO Ver 2.0 					*
;*	使用例						*
;*	A>IBMCO    filename(ｶﾗｰfile)    		*
;*	A>IBMCO    IBMDEF.PAL				*
;*					            	*
;*	64個のｶﾗｰﾚｼﾞｽﾀのから１６個のｶﾗｰを選択セットする *
;*		 		                   	*
;*                                                     	*
;*					By TAKEO   	*
;********************************************************

INCLUDE	MDOS.H
INCLUDE	STD.H

F_LEN	EQU	2000				;DATA LEN  最大ﾌｧｲﾙﾚﾝｸﾞｽ
SET_LEN	EQU	17				;SET LEN   1*16=16

_TEXT	SEGMENT WORD PUBLIC 'CODE'
	ASSUME	CS:_TEXT,DS:_TEXT,ES:_TEXT,SS:_TEXT


	ORG	80H
DTA	DB	80H	DUP(?)
	ORG	100H
	
START:
		MOV	SI,OFFSET DTA[0]
		CMP	BYTE PTR [SI],0
		JNE	NEXT
		JMP	PARA_ERR
NEXT:		INC	SI
		CALL	PARA_SET
		JNC	C_LINE0
		JMP	PARA_ERR
C_LINE0:
		MOV	DI,OFFSET PNAME
	REP	MOVSB
		MOV	AL,NUL
		STOSB

		OPEN_HANDLE	PNAME,0

		JC	OPENERR
		MOV	HANDLE_D,AX

		READ_HANDLE	HANDLE_D,PAL1,F_LEN
		
		JC	READERR
		CMP	AX,0
		JE	SETEND
		JMP	SET_PAL
;
PARA_ERR:
		MOV	DX,OFFSET MSGPARA
		JMP	SHORT	MSGOUT

OPENERR:
		MOV	DX,OFFSET MSGSER
		JMP	SHORT	MSGOUT

READERR:
		MOV	DX,OFFSET MSGRER
		JMP	SHORT	MSGOUT

SETEND:
		CLOSE_HANDLE	HANDLE_D

		JC	CLSERR
		MOV	DX,OFFSET MSGEND
		JMP	SHORT	MSGOUT
;
CLSERR:		MOV	DX,OFFSET MSGCER
;

MSGOUT:
		PUSH	DX
		
		MOV	DX,OFFSET TMSG
		MOV	AH,09H
		INT	21H
		
		POP	DX
		
		MOV	AH,09H
		INT	21H
		
EXIT:

		END_PROCESS
ADDBX:
	INC	BX
	MOV	AL,PAL1[BX]
	CMP	AL,0AH
	JNE	ADDBX
	INC	BX
	JMP	SHORT	PALA_SET1
ADDBX1:
	INC	BX
	INC	BX
	JMP	SHORT	PALA_SET1

END_SET1:
	JMP	PALA_SET4

SET_PAL:
		CLD
		MOV	DI,OFFSET PAL
		MOV	BX,0
PALA_SET1:
		MOV	AL,PAL1[BX]
		CMP	AL,3BH				;ｺﾒﾝﾄ行
		JE	ADDBX
		CMP	AL,0DH				;改行復帰
		JE	ADDBX1
		CMP	AL,1AH				;EOF
		JE	END_SET1
		CMP	AL,30H				;ｷｬﾗｸﾀｰｺｰﾄﾞ 0より小さい
		JB	PALA_E
		CMP	AL,46H				;ｷｬﾗｸﾀｰｺｰﾄﾞ Fより大きい
		JA	PALA_E
		CMP	AL,39H
		JA	PALA_ABC
		SUB	AL,30H
		MOV	P1,AL
		JMP	SHORT PALA_SET2

PALA_E:
		JMP	PARA_ERR

PALA_ABC:
		SUB	AL,37H
		MOV	P1,AL

PALA_SET2:
		MOV	AL,PAL1[BX+1]
		CMP	AL,30H				;ｷｬﾗｸﾀｰｺｰﾄﾞ 0より小さい
		JB	PALA_E
		CMP	AL,46H				;ｷｬﾗｸﾀｰｺｰﾄﾞ Fより大きい
		JA	PALA_E
		CMP	AL,39H
		JA	PALA_ABC1
		SUB	AL,30H
		MOV	P2,AL
		JMP	SHORT PALA_SET3
PALA_ABC1:
		SUB	AL,37H
		MOV	P2,AL

PALA_SET3:
		XOR	CX,CX
		MOV	AL,P2
		MOV	CL,4
		SHL	AL,CL
		MOV	AH,P1
		XOR	CX,CX
		MOV	CL,4
		SHR	AX,CL
		STOSB				;DI<<AL
		INC	BX
		INC	BX
		INC	COUNT
		MOV	CL,COUNT
		CMP	CL,SET_LEN
		JAE	END_SET1
		JMP	SHORT PALA_SET1

PALA_SET4:
		MOV	DX,OFFSET PAL
		MOV	AX,1002H
		INT	10H

		JMP	SETEND


PARA_SET	PROC	NEAR
		MOV	CX,0
PARA1:
		LODSB
		CMP	AL,CR
		JE	PARA_END
		CMP	AL,SPC
		JE	PARA1
		CMP	AL,","
		JE	PARA1
		CMP	AL,"/"
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
		CMP	AL,"/"
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


HANDLE_D	DW	?

MSGSER		DB	CR,LF,LF,'････File Not Found',CR,LF,'$'

MSGRER		DB	CR,LF,LF,'････Read error',CR,LF,'$'

MSGCER		DB	CR,LF,LF,'････Cannot Close',CR,LF,'$'

MSGEND		DB	CR,LF,LF,'････Set COLOR DATA',CR,LF,'$'

MSGPARA		DB	CR,LF,LF,"････Parameter Err",CR,LF,"$"

TMSG		DB	CR,LF
		DB	"IBMCO		Ver 2.0	All Rights Reserved.",CR,LF
		DB	CR,LF
		DB	"				   By TAKEO"
		DB	CR,LF,"$"

PNAME	DB	63 DUP(0),0
COUNT	DB	0

;		1*16=16Byte

PAL	DB	SET_LEN	DUP(0)

PAL1	DB	F_LEN	DUP(0)

P1	DB	0
P2	DB	0

STACK	DB	100H	DUP(0)

_TEXT	ENDS
	END	START
