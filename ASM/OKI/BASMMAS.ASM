;-----------------------------------------------------------------------------
;   OBASIC CALL  ｱｾﾝﾌﾞﾗ ﾙｰﾁﾝ
;
;   ﾌｧｲﾙ　集計 ﾕｰﾃｨﾘﾃｨｰ
;
;   CALL MMAS(ﾌｧｲﾙNo1,ﾌｧｲﾙNo2,乗務員REC,開始日付,集計日数,
;					潤うとしFLG,ﾀﾞｲﾔ日数配列,ｽﾃｰﾀｽFLG)
;
;	ﾌｧｲﾙNo1		MMAS.UD
;	ﾌｧｲﾙNo2		MMASN.UD
;       乗務員REC       乗務員ﾚｺｰﾄﾞ番号
;	開始日付	集計する最初日付(1/1から開始する日付までの日数をｾｯﾄ)
;	集計日数	何日分かｾｯﾄ
;	潤うとしFLG	当年の潤うとしをｾｯﾄ
;	ﾀﾞｲﾔ日数配列	ﾀﾞｲﾔの日数を配列でｾｯﾄ
;	ｽﾃｰﾀｽFLG	ｴﾗｰｺｰﾄﾞ
;
;
;ｽﾃｰﾀｽFLG
;		99	ERR_REC_CHK	JADDのREC=0
;		98	ERR_REC_CHK1	DAY_REC=0
;		97	ERR_S_POINT	ﾌｧｲﾙﾎﾟｲﾝﾀｰ先頭移動ｴﾗｰ
;		96	ERR_MOV_POINT	ﾌｧｲﾙﾎﾟｲﾝﾀｰJADD分移動
;		95	ERR_MOV1_POINT	ﾌｧｲﾙﾎﾟｲﾝﾀｰMMAS1分移動
;		94	ERR_S_READ	ﾌｧｲﾙﾘｰﾄﾞ
;		93	ERR_S_WRITE	ﾌｧｲﾙﾗｲﾄ
;		92	ERR_MOV2_POINT	ﾌｧｲﾙﾎﾟｲﾝﾀｰNEXT移動
;
; BASIC BLOAD ADD
;              BLOAD &HF200  に固定 
;
;
;-----------------------------------------------------------------------------

INCLUDE	MDOS.H
INCLUDE	MACRO.H
INCLUDE	STD.H

L_ADD		EQU	0F200H		;BLOAD address = DS:F200
OFSET		EQU	L_ADD-7


PARA_OP	STRUC				;スタック受渡テーブル
	BP_SV	DW	?		;BP退避
	R_ADD	DD	?		;RETURN	ADD
	S_FLG	DW	?		;ｽﾃｰﾀｽFLG
	D_DAY	DW	?		;ﾀﾞｲﾔ日数配列(99ｺ)
	U_DAY	DW	?		;潤う年FLG
	C_DAY	DW	?		;ｶｳﾝﾄ数
	D_REC	DW	?		;日付
	J_REC	DW	?		;乗務員REC
	F_NO1	DW	?		;ﾌｧｲﾙNO1(MMASN.UD)
	F_NO	DW	?		;ﾌｧｲﾙNO(MMAS.UD)
PARA_OP	ENDS


CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,SS:CODE,ES:CODE

	DB	0FDH
	DW	0000H
	DW	L_ADD
	DW	endp - startp

	PUBLIC	MAIN

startp	EQU	$

MAIN	PROC	FAR

		PUSH	BP		;BPスタックに退避	
		MOV	BP,SP		;スタックポイントBPにMOVE
		PUSHA			;全レジスタ退避

;--------------------------ﾀﾞｲﾔ日数配列ｱﾄﾞﾚｽ

		MOV	BX,[BP].D_DAY	;ﾀﾞｲﾔ日数配列アドレス取得
		MOV	D_ADD[OFSET],BX	;
		MOV	SI,BX		;
;-----------------------------------------------------------------------
		CLD
		MOV	CX,D_TBL_SIZE
		MOV	DI,OFFSET D_TBL[OFSET]
		REP	MOVSB

;--------------------------潤う年FLG

		MOV	BX,[BP].U_DAY	;潤う年アドレス取得
		MOV	AX,[BX]		;潤う年の中身
		MOV	DAY_U[OFSET],AL
		MOV	DAY_MAX[OFSET],365
		CMP	DAY_U[OFSET],1
		JNE	NEXT_1
		INC	DAY_MAX[OFSET]

NEXT_1:
;--------------------------カウント

		MOV	BX,[BP].C_DAY	;カウントアドレス取得
		MOV	AX,[BX]		;カウントの中身
		MOV	DAY_COUNT[OFSET],AX

;--------------------------日数ＲＥＣ

		MOV	BX,[BP].D_REC	;日数ＲＥＣアドレス取得
		MOV	AX,[BX]		;日数ＲＥＣの中身
		MOV	DAY_REC[OFSET],AX
		MOV	DAY_REC_C[OFSET],AX

;--------------------------乗務員ＲＥＣ

		MOV	BX,[BP].J_REC	;乗務員ＲＥＣアドレス取得
		MOV	AX,[BX]		;乗務員ＲＥＣの中身
		MOV	JADD_REC[OFSET],AX

;--------------------------ファイルハンドル１(MMASN.UD)

		MOV	BX,[BP].F_NO1	;ファイルハンドルアドレス取得
		MOV	AX,[BX]		;ファイルハンドルの中身
		MOV	FILE_NO1[OFSET],AX

;--------------------------ファイルハンドル０(MMAS.UD)

		MOV	BX,[BP].F_NO	;ファイルハンドルアドレス取得
		MOV	AX,[BX]		;ファイルハンドルの中身
		MOV	FILE_NO[OFSET],AX

;------------------------------------------------------------------------
REC_CHK:
		MOV	CX,JADD_REC[OFSET]	;JADDのレコード番号
		OR	CX,CX			;REC=0のﾁｪｯｸ
		JNE	REC_CHK1		;IF REC=0 THEN AX=99:GOTO EXIT
						;          ELSE GOTO REC_CHK1
		MOV	AX,ERR_REC_CHK			;ｴﾗｰｺｰﾄﾞ
		JMP	EXIT

REC_CHK1:
		MOV	CX,DAY_REC[OFSET]	;日付レコード番号
		OR	CX,CX			;REC=0のﾁｪｯｸ
		JNE	S_POINT			;IF REC=0 THEN AX=99:GOTO EXIT
						;          ELSE GOTO S_POINT
		MOV	AX,ERR_REC_CHK1		;ｴﾗｰｺｰﾄﾞ
		JMP	EXIT

;------------------------------------------------------------------------
;
;		初期設定	ふぁいるの先頭にぽいんたーをせっと
;
;------------------------------------------------------------------------
		;MOVE_PTR	MACRO	HANDLE,HIGHT,LOW,METHOD

S_POINT:
							;ファイルの先頭にセット
		MOVE_PTR	FILE_NO[OFSET],0,0,0	;MMAS.UD
		JC	S_ERR
							;ファイルの先頭にセット
		MOVE_PTR	FILE_NO1[OFSET],0,0,0	;MMASN.UD
		JC	S_ERR
		JMP	SHORT MOV_CHK

S_ERR:
		MOV	AX,ERR_S_POINT			;ｴﾗｰｺｰﾄﾞ
		JMP	EXIT


;-----------------------------------------------ぽいんたー移動ちぇっく

MOV_CHK:
		MOV	CX,JADD_REC[OFSET]	;JADDのレコード番号
		DEC	CX			;REC 1減
		OR	CX,CX			;IF CX=0 THEN GOTO MOV1_CHK
		JNE	MOV_POINT		;        ELSE  MOV_POINT
		JMP	MOV1_CHK		;S_MMASの処理へ

;-----------------------------------------------ぽいんたー移動 BUF_SIZE

MOV_POINT:
		PUSH	CX
		MOV	AX,BUF_SIZE
		MUL	CX

		MOV	BX,FILE_NO[OFSET]
		MOV	CX,DX
		MOV	DX,AX
		MOV	AL,1
		MOV	AH,42H
		INT	21H
		POP	CX

		JC	MOV_ERR

		MOV	AX,BUF1_SIZE
		MUL	CX

		MOV	BX,FILE_NO1[OFSET]
		MOV	CX,DX
		MOV	DX,AX
		MOV	AL,1
		MOV	AH,42H
		INT	21H
		
		JC	MOV_ERR

		MOV	WORD PTR F_POINT[OFSET],DX	;ファイルのポインター
		MOV	WORD PTR F_POINT[OFSET+2],AX	;

		JMP	MOV1_CHK

MOV_ERR:
		MOV	AX,ERR_MOV_POINT		;ｴﾗｰｺｰﾄﾞ
		JMP	EXIT

;-----------------------------------------------MMASN.UD の移動
;-----------------------------------------------ぽいんたー移動ちぇっく

MOV1_CHK:
		MOV	CX,DAY_REC[OFSET]	;DAYのレコード番号
		DEC	CX			;REC 1減
		OR	CX,CX			;IF CX=0 THEN GOTO S_READ
		JNE	MOV1_POINT		;        ELSE  MOV1_POINT
		JMP	S_READ			;S_READの処理へ

;-----------------------------------------------ぽいんたー移動 MMAS1_SIZE

MOV1_POINT:

		MOV	AX,MMAS1_SIZE
		MUL	CX

		MOV	BX,FILE_NO1[OFSET]
		MOV	CX,DX
		MOV	DX,AX
		MOV	AL,1
		MOV	AH,42H
		INT	21H
		
		JC	MOV1_ERR

		JMP	S_READ

MOV1_ERR:
		MOV	AX,ERR_MOV1_POINT	;ｴﾗｰｺｰﾄﾞ
		JMP	EXIT

;--------------------------------------------------ファイルから読み込み
S_READ:
		READ_HANDLE	FILE_NO[OFSET],MMAS.M_EIS[OFSET],MMAS_SIZE
		JC	READ_ERR

		CMP	AX,MMAS_SIZE
		JZ	S_KINTAI

READ_ERR:
		MOV	AX,ERR_S_READ		;ｴﾗｰｺｰﾄﾞ
		JMP	EXIT

;-----------------------------------------------------勤怠計算

S_KINTAI:
	MOV	K_KTJ[OFSET],0				;拘束時間初期化
	MOV	AX,MMAS.M_SJ[OFSET]			;開始時間
	OR	AX,AX
	JZ	S_KINTAI1

	XOR	DX,DX
	MOV	BX,100					;時間 to 分に変換
	DIV	BX
	MOV	CX,DX
	MOV	BX,60
	MUL	BX
	ADD	AX,CX

S_KINTAI1:
;-----------------------------------------------------勤怠計算　拘束時間
	MOV	K_SM[OFSET],AX

	MOV	AX,MMAS.M_EJ[OFSET]			;終了時間
	OR	AX,AX
	JZ	S_KINTAI2
	XOR	DX,DX
	MOV	BX,100					;時間 to 分に変換
	DIV	BX
	MOV	CX,DX
	MOV	BX,60
	MUL	BX
	ADD	AX,CX

	CMP	AX,K_SM[OFSET]				;開始時間が終了時間より
	JB	S_KINTAI2				;大きい場合のチェック

	SUB	AX,K_SM[OFSET]				;終了－開始
	OR	AX,AX
	JZ	S_KINTAI2
	XOR	DX,DX
	MOV	BX,60					;分を時分に変換
	DIV	BX
	MOV	CX,DX
	MOV	BX,100
	MUL	BX
	ADD	AX,CX
	MOV	K_KTJ[OFSET],AX

;-----------------------------------------------------勤怠計算　欠格回数

S_KINTAI2:
	MOV	K_KKK[OFSET],0			;欠格回数初期化
	MOV	AX,MMAS.M_KKK[OFSET]		;明細ﾃﾞｰﾀｰよりﾃﾞｰﾀｰ取得文字列
	XCHG	AH,AL
	CMP	AH,30H				;文字の'0'かどうか
	JAE	S_KINTAI3			;IF AH=>'0' THEN S_KINTAI3
	MOV	AH,30H				;	    ELSE AH='0'
	
S_KINTAI3:
	CMP	AL,30H				;IF AL=>'0' THEN S_KINTAI4
	JAE	S_KINTAI4			;	    ELSE AL='0'
	MOV	AL,30H

S_KINTAI4:
	CMP	AH,39H				;IF AH<='9' THEN S_KINTAI5
	JBE	S_KINTAI5			;	    ELSE AH='0'
	MOV	AH,30H

S_KINTAI5:
	CMP	AL,39H				;IF AL<='9' THEN S_KINTAI6
	JBE	S_KINTAI6			;	    ELSE AL='0'
	MOV	AL,30H

S_KINTAI6:
	SUB	AH,30H				;AHを文字から数値に変換
	SUB	AL,30H				;ALを文字から数値に変換
	AAD
	MOV	K_KKK[OFSET],AX

;--------------------------------------------------勤務日数テーブルGET

S_KINTAI7:
	XOR	AX,AX
	XOR	BX,BX
	MOV	AL,MMAS.M_DO1[OFSET]		;明細ﾃﾞｰﾀｰよりﾀﾞｲﾔ番号取得
	ADD	BX,AX				;ﾃｰﾌﾞﾙ配列添字調整
	ADD	BX,AX				;WORD TYPE
	MOV	AX,D_TBL_DMY[OFSET][BX]		;
	MOV	D_DAYC[OFSET],AX

;--------------------------------------------------ＳＥＴ　ＤＡＴＡ
SET_D:

;--------------------------営業収入

		MOV	AX,WORD	PTR MMAS.M_EIS[OFSET]		;営業収入下位
		MOV	WORD PTR MMAS1.M1_EIS[OFSET],AX
		MOV	AX,WORD PTR MMAS.M_EIS[OFSET+2]		;営業収入上位
		MOV	WORD PTR MMAS1.M1_EIS[OFSET+2],AX

;--------------------------無線回数

		MOV	AX,MMAS.M_MSN[OFSET]			;無線回数
		MOV	MMAS1.M1_MSN[OFSET],AX

;--------------------------予約回数

		XOR	AX,AX
		MOV	AL,MMAS.M_YYK[OFSET]			;予約回数
		MOV	MMAS1.M1_YYK[OFSET],AX

;--------------------------拘束時間

		MOV	AX,K_KTJ[OFSET]				;拘束時間
		MOV	MMAS1.M1_KTM[OFSET],AX

;--------------------------ハンドル時間

		MOV	AX,MMAS.M_HTM[OFSET]			;ﾊﾝﾄﾞﾙ時間
		MOV	MMAS1.M1_HTM[OFSET],AX

;--------------------------欠格回数

		MOV	AX,K_KKK[OFSET]				;欠格回数
		MOV	MMAS1.M1_KKK[OFSET],AX

;--------------------------勤務区分

		XOR	AX,AX
		MOV	AL,MMAS.M_KBN[OFSET]			;勤務区分
		MOV	MMAS1.M1_KBN[OFSET],AX

;--------------------------勤務日数

		MOV	AX,D_DAYC[OFSET]			;勤務日数
		MOV	MMAS1.M1_DAY[OFSET],AX

;----------------------------------------------ファイルに書き込み

S_WRITE:
		WRITE_HANDLE	FILE_NO1[OFSET],MMAS1.M1_EIS[OFSET],MMAS1_SIZE

		JC	WRITE_ERR
		CMP	AX,MMAS1_SIZE
		JZ	REP_DATA

WRITE_ERR:
		MOV	AX,ERR_S_WRITE			;ｴﾗｰｺｰﾄﾞ
		JMP	SHORT EXIT

;---------------------------------------------------------------------------

REP_DATA:
		MOV	AX,0
		DEC	DAY_COUNT[OFSET]
		JNE	MOV2_POINT
		JMP	EXIT

MOV2_POINT:

;		MOVE_PTR	FILE_NO[OFSET],0,MMAS_SIZE,1	;MMAS.UD
;		JC	MOV2_ERR
;-----------------------------------------------------------------------
		INC	DAY_REC_C[OFSET]
		MOV	AX,DAY_REC_C[OFSET]
		CMP	DAY_MAX[OFSET],AX
		JAE	MOV2_POINT1
							;MMASN.UD
		MOV	BX,FILE_NO1[OFSET]
		MOV	CX,WORD PTR F_POINT[OFSET]
		MOV	DX,WORD PTR F_POINT[OFSET+2]
		MOV	AL,0
		MOV	AH,42H
		INT	21H

		JC	MOV2_ERR
		MOV	DAY_REC_C[OFSET],1
		JMP	MOV2_POINT_EXIT

MOV2_POINT1:

;		MOVE_PTR	FILE_NO1[OFSET],0,MMAS1_SIZE,1	;MMASN.UD
;		JC	MOV2_ERR

MOV2_POINT_EXIT:

		JMP	S_READ

MOV2_ERR:
		MOV	AX,ERR_MOV2_POINT
		JMP	EXIT
;--------------------------------------------------------------------------

EXIT:
		MOV	BX,[BP].S_FLG	;ｽﾃｰﾀｽFLGアドレス取得
		MOV	[BX],AX		;ｽﾃｰﾀｽFLGセット   AXにｾｯﾄ

		POPA			;全レジスタ復帰
        	POP	BP		;BP復帰
		RET	16		;スタック調整RETURN


;--------------------------------------------------------------------------
;		明細FIELD 設定
;		レコードレングス設定  MMASN.UD
;--------------------------------------------------------------------------

MMAS1_FIELD	STRUC
	M1_EIS	DD	0				;営業収入
	M1_MSN	DW	0				;無線回数
	M1_YYK	DW	0				;予約回数
	M1_KTM	DW	0				;拘束時間
	M1_HTM	DW	0				;ﾊﾝﾄﾞﾙ時間
	M1_KKK	DW	0				;欠格回数
	M1_KBN	DW	0				;勤務区分
	M1_DAY	DW	0				;勤務日数
MMAS1_FIELD	ENDS
MMAS1	MMAS1_FIELD	<,,,,,,>			;初期化

MMAS1_SIZE	EQU	SIZE MMAS1
BUF1_SIZE	EQU	MMAS1_SIZE*366
FILE_NO1	DW	0				;ファイルハンドル

;--------------------------------------------------------------------------
;		明細FIELD 設定
;		レコードレングス設定  MMAS.UD OR MMAS2.UD
;--------------------------------------------------------------------------

MMAS_FIELD	STRUC
	M_EIS	DD	0				;営業収入	   4
	M_DC0	DB	0				;ﾀﾞｲﾔｺｰﾄﾞ勤務表    1
	M_K1	DB	0				;勤務区分          1
	M_DO1	DB	0				;ﾀﾞｲﾔｺｰﾄﾞ実ダイヤ  1
	M_KBN	DB	0				;実勤務区分        1
	M_SJ	DW	0				;実開始時間        2
	M_EJ	DW	0				;実終了時間        2
	M_CS	DW	0				;調整所定時間      2
	M_CZ	DW	0				;調整残業時間      2
	M_CC	DW	0				;調整深夜時間      2
	M_KB	DB	0				;勤怠区分          1
	M_HTM	DW	0				;ﾊﾝﾄﾞﾙ時間         2
	M_MSN	DW	0				;無線回数          2
	M_KKK1	DW	0				;欠格回数 DMY    2  
	M_KKK2	DW	0				;欠格回数 DMY    2
	M_KKK	DW	0				;欠格回数        2 6
	M_YYK	DB	0				;予約回数          1
MMAS_FIELD	ENDS
MMAS	MMAS_FIELD	<,,,,,,,,,,,,,,,,>		;初期化

MMAS_SIZE	EQU	SIZE MMAS
BUF_SIZE	EQU	MMAS_SIZE*31
FILE_NO		DW	0				;ファイルハンドル

;
;----------------------------------------------------------------------------
;		エラーコード
;
;----------------------------------------------------------------------------

ERR_REC_CHK	EQU	99				;JADDのREC=0
ERR_REC_CHK1	EQU	98				;DAY_REC=0
ERR_S_POINT	EQU	97				;ﾌｧｲﾙﾎﾟｲﾝﾀｰ先頭移動ｴﾗｰ
ERR_MOV_POINT	EQU	96				;ﾌｧｲﾙﾎﾟｲﾝﾀｰJADD分移動
ERR_MOV1_POINT	EQU	95				;ﾌｧｲﾙﾎﾟｲﾝﾀｰMMAS1分移動
ERR_S_READ	EQU	94				;ﾌｧｲﾙﾘｰﾄﾞ
ERR_S_WRITE	EQU	93				;ﾌｧｲﾙﾗｲﾄ
ERR_MOV2_POINT	EQU	92				;ﾌｧｲﾙﾎﾟｲﾝﾀｰNEXT移動




JADD_REC	DW	0				;乗務員REC
DAY_REC		DW	0				;日数
DAY_REC_C	DW	0				;日数
DAY_COUNT	DW	0				;日付カウント
DAY_U		DB	0				;潤う年FLG
DAY_MAX		DW	365				;１年の日数
K_KTJ		DW	0				;拘束時間(時分)
K_KKK		DW	0				;欠格回数
K_SM		DW	0				;開始時間(分)退避エリア
F_POINT		DD	0				;ファイルポインター退避
D_ADD		DW	0				;ﾀﾞｲﾔ日数ｱﾄﾞﾚｽ
D_DAYC		DW	0				;勤務日数
D_TBL_DMY	DW	0				;ﾀﾞｲﾔﾃｰﾌﾞﾙﾀﾞﾐｰ
D_TBL		DW	99 DUP(0)			;ﾀﾞｲﾔ日数ﾃｰﾌﾞﾙ

D_TBL_SIZE	EQU	SIZE D_TBL			;ﾃｰﾌﾞﾙのｻｲｽﾞ取得

MAIN	ENDP
endp	EQU	$

CODE		ENDS
		END
