INCLUDE	MDOS.H
INCLUDE	STD.H
INCLUDE	UTY.H
INCLUDE	MACRO.H
INCLUDE	BIOS.H

	;INPUT_M	MACRO	HY,HX,STRING,COUNT,OP,FEP
	;INPUT1_M       MACRO	STRING,HY,HX,QZ,OP,C1,C2,C3,C4,S
	;LOCATE_M	MACRO	HY,HX
	;COLOR_M	MACRO	FGC,BGC,FG,BG


K_MODE	EQU     8400H		;ｷｰﾓｰﾄﾞﾃﾞﾌｫﾙﾄ
CLS_SP	EQU	20H		;ｸﾘｱｰｽﾍﾟｰｽ
K_SPC	EQU	15		;表示開始位置ｽﾍﾟｰｽ

K_CODE	EQU	 6		;ｺｰﾄﾞ	桁数
K_NAME	EQU	40		;名	桁数
K_FURI	EQU	40		;ﾌﾘｶﾞﾅ	桁数
K_ADD	EQU	40		;住所	桁数
K_TEL	EQU	12		;TEL	桁数

MG_HY	EQU	 0		;ﾒｯｾｰｼﾞ	ﾛｹｰﾄY
MG_HX	EQU	 0		;ﾒｯｾｰｼﾞ	ﾛｹｰﾄX
MG_FGC	EQU	 6		;ﾒｯｾｰｼﾞ	ﾌｫｱｰｶﾗｰ
MG_BGC	EQU	 0		;ﾒｯｾｰｼﾞ	ﾊﾞｯｸｶﾗｰ
MG_FG	EQU	 0		;ﾒｯｾｰｼﾞ	ﾌｫｱｰ拡張ｶﾗｰ
MG_BG	EQU	 0		;ﾒｯｾｰｼﾞ	ﾊﾞｯｸ拡張ｶﾗｰ

DG_FGC	EQU	 0		;ﾃﾞｰﾀ	ﾌｫｱｰｶﾗｰ
DG_BGC	EQU	 7		;ﾃﾞｰﾀ  	ﾊﾞｯｸｶﾗｰ
DG_FG	EQU	 0		;ﾃﾞｰﾀ  	ﾌｫｱｰ拡張ｶﾗｰ
DG_BG	EQU	 0		;ﾃﾞｰﾀ  	ﾊﾞｯｸ拡張ｶﾗｰ

SG_FGC	EQU	 1		;初期画面	ﾌｫｱｰｶﾗｰ
SG_BGC	EQU	 7		;初期画面	ﾊﾞｯｸｶﾗｰ
SG_FG	EQU	 0		;初期画面	ﾌｫｱｰ拡張ｶﾗｰ
SG_BG	EQU	 0		;初期画面	ﾊﾞｯｸ拡張ｶﾗｰ
SG_HY	EQU	 5		;初期画面	ﾛｹｰﾄY
SG_HX	EQU	 0		;初期画面	ﾛｹｰﾄX

TI_FGC	EQU	 7		;ﾀｲﾄﾙ	ﾌｫｱｰｶﾗｰ
TI_BGC	EQU	 2		;ﾀｲﾄﾙ	ﾊﾞｯｸｶﾗｰ
TI_FG	EQU	 0		;ﾀｲﾄﾙ	ﾌｫｱｰ拡張ｶﾗｰ
TI_BG	EQU	 0 		;ﾀｲﾄﾙ	ﾊﾞｯｸ拡張ｶﾗｰ
TI_HY	EQU	 1		;ﾀｲﾄﾙ	ﾛｹｰﾄY
TI_HX	EQU	26		;ﾀｲﾄﾙ	ﾛｹｰﾄX

N1_HX	EQU	26		;項目１	ﾛｹｰﾄX
N1_HY	EQU	 5		;項目１ ﾛｹｰﾄY
N1_QZ	EQU	 0		;項目１ 
N1_OP	EQU	 1		;項目１	ｵﾌﾟｼｮﾝFLG
N1_C1	EQU	 1		;項目１ ﾌｫｱｰｶﾗｰ
N1_C2	EQU	 7		;項目１	ﾊﾞｯｸｶﾗｰ
N1_C3	EQU	 0		;項目１ ﾌｫｱｰ拡張ｶﾗｰ 
N1_C4	EQU	 1		;項目１	ﾊﾞｯｸ拡張ｶﾗｰ
N1_S	EQU	 0		;項目１	ｼｰｸﾚｯﾄFLG

N2_HX	EQU	26		;項目１	ﾛｹｰﾄX
N2_HY	EQU	 7		;項目１ ﾛｹｰﾄY
N2_QZ	EQU	 0		;項目１ 
N2_OP	EQU	 3		;項目１	ｵﾌﾟｼｮﾝFLG
N2_C1	EQU	 1		;項目１ ﾌｫｱｰｶﾗｰ
N2_C2	EQU	 7		;項目１	ﾊﾞｯｸｶﾗｰ
N2_C3	EQU	 0		;項目１ ﾌｫｱｰ拡張ｶﾗｰ 
N2_C4	EQU	 1		;項目１	ﾊﾞｯｸ拡張ｶﾗｰ
N2_S	EQU	 0		;項目１	ｼｰｸﾚｯﾄFLG

N3_HX	EQU	26		;項目１	ﾛｹｰﾄX
N3_HY	EQU	 9		;項目１ ﾛｹｰﾄY
N3_QZ	EQU	 0		;項目１ 
N3_OP	EQU	 8		;項目１	ｵﾌﾟｼｮﾝFLG
N3_C1	EQU	 1		;項目１ ﾌｫｱｰｶﾗｰ
N3_C2	EQU	 7		;項目１	ﾊﾞｯｸｶﾗｰ
N3_C3	EQU	 0		;項目１ ﾌｫｱｰ拡張ｶﾗｰ 
N3_C4	EQU	 1		;項目１	ﾊﾞｯｸ拡張ｶﾗｰ
N3_S	EQU	 0		;項目１	ｼｰｸﾚｯﾄFLG

N4_HX	EQU	26		;項目１	ﾛｹｰﾄX
N4_HY	EQU	11		;項目１ ﾛｹｰﾄY
N4_QZ	EQU	 0		;項目１ 
N4_OP	EQU	 3		;項目１	ｵﾌﾟｼｮﾝFLG
N4_C1	EQU	 1		;項目１ ﾌｫｱｰｶﾗｰ
N4_C2	EQU	 7		;項目１	ﾊﾞｯｸｶﾗｰ
N4_C3	EQU	 0		;項目１ ﾌｫｱｰ拡張ｶﾗｰ 
N4_C4	EQU	 1		;項目１	ﾊﾞｯｸ拡張ｶﾗｰ
N4_S	EQU	 0		;項目１	ｼｰｸﾚｯﾄFLG

N5_HX	EQU	26		;項目１	ﾛｹｰﾄX
N5_HY	EQU	13		;項目１ ﾛｹｰﾄY
N5_QZ	EQU	 0		;項目１ 
N5_OP	EQU	 2		;項目１	ｵﾌﾟｼｮﾝFLG
N5_C1	EQU	 1		;項目１ ﾌｫｱｰｶﾗｰ
N5_C2	EQU	 7		;項目１	ﾊﾞｯｸｶﾗｰ
N5_C3	EQU	 0		;項目１ ﾌｫｱｰ拡張ｶﾗｰ 
N5_C4	EQU	 1		;項目１	ﾊﾞｯｸ拡張ｶﾗｰ
N5_S	EQU	 0		;項目１	ｼｰｸﾚｯﾄFLG

CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE

	ORG	100H

START:
	JMP	MAIN

TITLE0	DB	"＊  サンプルプログラム  ＊"
	DB	"$"
     
GAMEN	DB 	K_SPC	DUP(20H)
	DB	"顧客コード["
	DB	K_CODE	DUP(20H)
	DB	"]",CR,LF
	DB	CR,LF

	DB 	K_SPC	DUP(20H)
	DB	"顧客名    ["
	DB	K_NAME	DUP(20H)
	DB	"]",CR,LF
	DB	CR,LF

	DB 	K_SPC	DUP(20H)
	DB	"フリガナ  ["
	DB	K_FURI	DUP(20H)
	DB	"]",CR,LF
	DB	CR,LF

	DB 	K_SPC	DUP(20H)
	DB	"住所      ["
	DB	K_ADD	DUP(20H)
	DB	"]",CR,LF
	DB	CR,LF

	DB 	K_SPC	DUP(20H)
	DB	"電話番号  ["
	DB	K_TEL	DUP(20H)
	DB	"]",CR,LF
	DB	"$" 

MSG0	DB	"顧客コード入力   ６桁  "
	DB	"$"
MSG1	DB	'顧客名入力     ２０文字'
	DB	"$"
MSG2	DB	'フリガナ入力   ４０文字'
	DB	"$"
MSG3	DB	'住所入力       ２０文字'
	DB	"$"
MSG4	DB	"電話番号入力   １０桁  "
	DB	"$"
MSG5	DB	"修正はありますか？  修正あり･･･〔Ｎｏ.〕   修正なし･･･〔０〕  終了･･･〔＊〕"
	DB	"$"
MSG5_CLS	DB	"                                                                             "
	DB	"$"


;格納エリア

I_DATA1	DB 	K_CODE	DUP(20H)
	DB	0
I_DATA2	DB	K_NAME	DUP(20H)
	DB	0
I_DATA3	DB	K_FURI	DUP(20H)
	DB	0
I_DATA4	DB	K_ADD	DUP(20H)
	DB	0
I_DATA5	DB	K_TEL	DUP(20H)
	DB	0
QZ	DB	0


;画面クリアー
CLEAR_SUB	PROC
		COLOR_M		SG_FGC,SG_BGC,SG_FG,SG_BG
		DISPLAY_CHAR	CLS
		RET
CLEAR_SUB	ENDP

;タイトル表示
TITLE_SUB	PROC
		COLOR_M		TI_FGC,TI_BGC,TI_FG,TI_BG
		LOCATE_M	TI_HY,TI_HX
		DISPLAY		TITLE0
		RET
TITLE_SUB	ENDP

;初期画面表示
GAMEN_SUB	PROC
		COLOR_M		SG_FGC,SG_BGC,SG_FG,SG_BG
		LOCATE_M	SG_HY,SG_HX
		DISPLAY		GAMEN
		RET
GAMEN_SUB	ENDP

;格納エリア初期化
CLEAR_SUB1	PROC
		MOV	AL,CLS_SP
		MOV	DI,OFFSET I_DATA1
		MOV	CX,K_CODE
	REP	STOSB
		MOV	DI,OFFSET I_DATA2
		MOV	CX,K_NAME
	REP	STOSB
		MOV	DI,OFFSET I_DATA3
		MOV	CX,K_FURI
	REP	STOSB
		MOV	DI,OFFSET I_DATA4
		MOV	CX,K_ADD
	REP	STOSB
		MOV	DI,OFFSET I_DATA5
		MOV	CX,K_TEL
	REP	STOSB
		RET
CLEAR_SUB1	ENDP

;メッセージ表示
MGDISP_M	MACRO	STRING
		COLOR_M		MG_FGC,MG_BGC,MG_FG,MG_BG
		LOCATE_M	MG_HY,MG_HX
		DISPLAY		STRING
		ENDM

;データ表示
DDISP_M		MACRO	DY,DX,STRING
		COLOR_M		DG_FGC,DG_BGC,DG_FG,DG_BG
		LOCATE_M	DY,DX
		BIOS_D7		STRING
		ENDM

;顧客コード
NY1_SUB	PROC
		MGDISP_M	MSG0
		INPUT1_M 	I_DATA1,N1_HX,N1_HY,N1_QZ,N1_OP,N1_C1,N1_C2,N1_C3,N1_C4,N1_S
		MOV	QZ,AL
		DDISP_M		N1_HY,N1_HX,I_DATA1
		RET
NY1_SUB	ENDP

;顧客名入力
NY2_SUB	PROC
		MGDISP_M        MSG1
		INPUT1_M 	I_DATA2,N2_HX,N2_HY,N2_QZ,N2_OP,N2_C1,N2_C2,N2_C3,N2_C4,N2_S
		MOV	QZ,AL
		DDISP_M		N2_HY,N2_HX,I_DATA2
		RET
NY2_SUB	ENDP

;フリガナ入力
NY3_SUB	PROC
		MGDISP_M        MSG2
		INPUT1_M 	I_DATA3,N3_HX,N3_HY,N3_QZ,N3_OP,N3_C1,N3_C2,N3_C3,N3_C4,N3_S
		MOV	QZ,AL
		DDISP_M		N3_HY,N3_HX,I_DATA3
		RET
NY3_SUB	ENDP

;住所入力
NY4_SUB	PROC
		MGDISP_M        MSG3
		INPUT1_M 	I_DATA4,N4_HX,N4_HY,N4_QZ,N4_OP,N4_C1,N4_C2,N4_C3,N4_C4,N4_S
		MOV	QZ,AL
		DDISP_M		N4_HY,N4_HX,I_DATA4
		RET
NY4_SUB	ENDP

;電話番号入力
NY5_SUB	PROC
		MGDISP_M        MSG4
		INPUT1_M 	I_DATA5,N5_HX,N5_HY,N5_QZ,N5_OP,N5_C1,N5_C2,N5_C3,N5_C4,N5_S
		MOV	QZ,AL
		DDISP_M		N5_HY,N5_HX,I_DATA5
		RET
NY5_SUB	ENDP


;ジャンプテーブル

JMP_TBL		DW	0,NY1_SUB,NY2_SUB,NY3_SUB,NY4_SUB,NY5_SUB

MAIN:

		CALL	CLEAR_SUB	;画面初期化
		CALL	TITLE_SUB	;タイトル表示

NY_START:
		CALL	GAMEN_SUB	;初期画面表示
		CALL	CLEAR_SUB1	;データクリアー

;ｺｰﾄﾞ
NY1:
NY1_1:		CALL	NY1_SUB		;顧客コード入力
		CMP	QZ,0BH
		JNE	NEXT_1
		JMP	NY1_1
NEXT_1:

;名
NY2:
NY2_1:		CALL	NY2_SUB		;顧客名入力
		CMP	QZ,0BH
		JNE	NEXT_2
		JMP	NY1_1
NEXT_2:

;カナ
NY3:
NY3_1:		CALL	NY3_SUB		;顧客カナ入力
		CMP	QZ,0BH
		JNE	NEXT_3
		JMP	NY2_1
NEXT_3:

;住所
NY4:
NY4_1:		CALL	NY4_SUB		;住所入力
		CMP	QZ,0BH
		JNE	NEXT_4
		JMP	NY3_1
NEXT_4:

;TEL
NY5:
NY5_1:		CALL	NY5_SUB		;電話番号入力
		CMP	QZ,0BH
		JNE	NEXT_5
		JMP	NY4_1
NEXT_5:

;ﾒｰｯｾｰｼﾞ

MSG_INP:	LOCATE_M	24,1
		COLOR_M		6,0,1,1
		DISPLAY		MSG5
		KBD_MODE_S	K_MODE
		DIR_CONSOLE_INPUT

		CMP	AL,"0"
		JNE	MSG_INP1
		JMP	MSG_EXIT
MSG_INP1:
		CMP	AL,"*"
		JNE	MSG_INP2
		JMP	EXIT
MSG_INP2:
		CMP	AL,"0"
		JB	MSG_INP3
		CMP	AL,"5"
		JBE	JMP_T
MSG_INP3:
		DISPLAY_CHAR	BEEP
		DISPLAY_CHAR	BEEP
		DISPLAY_CHAR	BEEP
		JMP	MSG_INP

JMP_T:
		SUB	AL,30H
		XOR	BX,BX
		ADD	BL,AL
		ADD	BL,AL
		MOV	SI,OFFSET JMP_TBL
		COLOR_M		1,7,1,0
		LOCATE_M	24,1
		DISPLAY		MSG5_CLS
		CALL	WORD PTR [SI+BX]
		JMP	MSG_INP

MSG_EXIT:
		COLOR_M		1,7,1,0
		LOCATE_M	24,1
		DISPLAY		MSG5_CLS
		JMP	NY_START

EXIT:
		COLOR_M		7,0,0,0
		DISPLAY_CHAR	CLS
		END_PROCESS 0

CODE	ENDS
	END	START
