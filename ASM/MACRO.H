.XLIST
IF1
%OUT MACRO.H_START
ENDIF
;****************************************
;*   	ﾏｸﾛ定義 		 	*
;*      MACRO.H  >>>>> ﾍｯﾀﾞｰﾌｧｲﾙ	* 
;*	1992.05.08			*
;****************************************


;----------------------------------------------------------------
;	INPUTﾙｰﾁﾝ						-
;								-
;	 ﾛｹｰﾄY,ﾛｹｰﾄX,文字ｱﾄﾞﾚｽ,入力文字数,ｵﾌﾟｼｮﾝ,FEP		-
;								-
;----------------------------------------------------------------
INPUT_M		MACRO	LY,LX,STRING,COUNT,OP,FEP
		MOV	AH,LY				;ﾛｹｰﾄY
		MOV	AL,LX				;ﾛｹｰﾄX
		MOV	SI,OFFSET STRING		;文字格納ｱﾄﾞﾚｽ
		MOV	CL,COUNT			;入力桁数
		MOV	BH,OP				;機能番号
		MOV	BL,FEP				;FEP起動ｵﾌﾟｼｮﾝ
		CALL	INPUT				;INPUTﾙｰﾁﾝ
		ENDM

INPUT1_M	MACRO	TEXT,HX,HY,QZ,OP,C1,C2,C3,C4,S
		LOCAL	INP_S,PR0,PR1,PR2,PR3,PR4,PR5,PR6,PR7,PR8
		JMP	SHORT INP_S
		PR0	DW	0
		PR1	DW	0
		PR2	DW	0
		PR3	DW	0
		PR4	DW	0
		PR5	DW	0
		PR6	DW	0
		PR7	DW	0
		PR8	DW	0
			DB	0
INP_S:
		PUSHA

		MOV	PR0,0
		MOV	PR1,0
		MOV	PR2,0
		MOV	PR3,0
		MOV	PR4,0
		MOV	PR5,0
		MOV	PR6,0
		MOV	PR7,0
		MOV	PR8,0


IFNB		<TEXT>
		MOV	AX,OFFSET TEXT
ELSE
		MOV	AX,OFFSET PR0
ENDIF
		PUSH	AX
		XOR	AX,AX

IFNB		<HX>
		MOV	AL,HX
		MOV	PR0,AX
ELSE
		MOV	PR0,1
ENDIF
		MOV	AX,OFFSET PR0
		PUSH	AX
		XOR	AX,AX

IFNB		<HY>
		MOV	AL,HY
		MOV	PR1,AX
ELSE
		MOV	PR1,1
ENDIF
		MOV	AX,OFFSET PR1
		PUSH	AX
		XOR	AX,AX

IFNB		<QZ>
		MOV	AL,QZ
		MOV	PR2,AX
ELSE
		MOV	PR2,0
ENDIF
		MOV	AX,OFFSET PR2
		PUSH	AX
		XOR	AX,AX

IFNB		<OP>
		MOV	AL,OP
		MOV	PR3,AX
ELSE
		MOV	PR3,1
ENDIF
		MOV	AX,OFFSET PR3
		PUSH	AX
		XOR	AX,AX

IFNB		<C1>
		MOV	AL,C1
		MOV	PR4,AX
ELSE
		MOV	PR4,7
ENDIF
		MOV	AX,OFFSET PR4
		PUSH	AX
		XOR	AX,AX

IFNB		<C2>
		MOV	AL,C2
		MOV	PR5,AX
ELSE
		MOV	PR5,0
ENDIF
		MOV	AX,OFFSET PR5
		PUSH	AX
		XOR	AX,AX

IFNB		<C3>
		MOV	AL,C3
		MOV	PR6,AX
ELSE
		MOV	PR6,0
ENDIF
		MOV	AX,OFFSET PR6
		PUSH	AX
		XOR	AX,AX

IFNB		<C4>
		MOV	AL,C4
		MOV	PR7,AX
ELSE
		MOV	PR7,0
ENDIF
		MOV	AX,OFFSET PR7
		PUSH	AX
		XOR	AX,AX

IFNB		<S>
		MOV	AL,S
		MOV	PR8,AX
ELSE
		MOV	PR8,0
ENDIF
		MOV	AX,OFFSET PR8
		PUSH	AX
		XOR	AX,AX

		CALL	INPUT1
		POPA
		MOV	AX,PR2
		ENDM


;----------------------------------------------------------------
;	LOCATEﾙｰﾁﾝ						-
;								-
;	ﾛｹｰﾄY,ﾛｹｰﾄX						-
;								-
;----------------------------------------------------------------
LOCATE_M	MACRO	LY,LX

		PUSHA
		XOR	AX,AX
		XOR	DX,DX

IFNB		<LY>
		MOV	DL,LY
ELSE
		MOV	DL,0
ENDIF
IFNB		<LX>
		MOV	AL,LX
ELSE
		MOV	AL,0
ENDIF
		MOV	CL,2DH
		PUSH	ES
		INT	80H
		POP	ES

		POPA
		ENDM

;----------------------------------------------------------------
;	CUMODEﾙｰﾁﾝ	ｶｰｿﾙﾓｰﾄﾞ				-
;								-
;	0･･無表示 1･･表示 2･･入力待ちのみ表示			-
;		※ 入力待ちの場合 INT80 の入力待ちのみ		-
;----------------------------------------------------------------
CUMODE_M	MACRO	SWITCH
		PUSHA
		PUSH	ES
		MOV	CL,2AH
		MOV	DL,SWITCH
		INT 	80H
		POP	ES
		POPA
		ENDM

;----------------------------------------------------------------
;	COLORﾙｰﾁﾝ						-
;								-
;	ﾌｫｱｰｶﾗｰ,ﾊﾞｯｸｶﾗｰ,拡張ｶﾗｰﾌｫｱｰ,拡張ｶﾗｰﾊﾞｯｸ			-
;  範囲	0-7    ,0-7    ,0-1           ,0-1			-
;			FG=0,BG=1      ｱｻﾞﾔｶ=0,ｸﾗｲ=1		-
;----------------------------------------------------------------
COLOR_M		MACRO	FGC,BGC,FG,BG

		PUSHA

		MOV	DH,0			;ﾌｫｱｸﾞﾗﾝﾄﾞｶﾗｰ

IFNB		<FGC>
		MOV	DL,FGC
ELSE
		MOV	DL,7			;ﾃﾞﾌｫﾙﾄ白
ENDIF
		MOV	CL,34H
		PUSH	ES
		INT	80H
		POP	ES

IFNB		<BGC>
		MOV	DH,1			;ﾊﾞｯｸｸﾞﾗﾝﾄﾞｶﾗｰ
		MOV	DL,BGC
		MOV	CL,34H
		PUSH	ES
		INT	80H
		POP	ES
ENDIF

IFNB		<FG>
		MOV	DH,0			;拡張ｶﾗｰ  ﾌｫｱｶﾗｰ
		MOV	DL,FG
		MOV	CL,0D9H
		PUSH	ES
		INT	80H
		POP	ES
ENDIF

IFNB		<BG>
		MOV	DH,1			;拡張ｶﾗｰ  ﾊﾞｯｸｶﾗｰ
		MOV	DL,BG
		MOV	CL,0D9H
		PUSH	ES
		INT	80H
		POP	ES
ENDIF

		POPA
		ENDM

IF1
%OUT MACRO.H_END
ENDIF
.LIST
