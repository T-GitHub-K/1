INCLUDE	MDOS.H
INCLUDE	MACRO.H
INCLUDE	STD.H

L_ADD		EQU	0FA00H		;BLOAD address = DS:FA00
OFSET		EQU	L_ADD-7


PARA_OP	STRUC				;スタック受渡テーブル
	BP_SV	DW	?		;BP退避
	R_ADD	DD	?		;RETURN	ADD
	S_FLG	DW	?		;ｽﾃｰﾀｽFLG
	K_HAI	DW	?		;配列
	U_DAY	DW	?		;潤う年FLG
	C_DAY	DW	?		;ｶｳﾝﾄ数
	D_REC	DW	?		;日付REC
	J_REC	DW	?		;乗務員REC
	F_NO	DW	?		;ﾌｧｲﾙNO
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

;--------------------------格納配列ｱﾄﾞﾚｽ

		MOV	BX,[BP].K_HAI	;格納配列アドレス取得
		MOV	K_ADD[OFSET],BX	;

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

;--------------------------ファイルハンドル０(MMAS.UD)

		MOV	BX,[BP].F_NO	;ファイルハンドルアドレス取得
		MOV	AX,[BX]		;ファイルハンドルの中身
		MOV	F1_NO[OFSET],AX

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
		MOVE_PTR	F1_NO[OFSET],0,0,0	;
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
		MOV	AX,F1_BUF
		MUL	CX

		MOV	BX,F1_NO[OFSET]
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

		MOV	AX,F1_SIZE
		MUL	CX

		MOV	BX,F1_NO[OFSET]
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
		READ_HANDLE	F1_NO[OFSET],F1.P1[OFSET],F1_SIZE
		JC	READ_ERR

		CMP	AX,F1_SIZE
		JZ	S_ADD

READ_ERR:
		MOV	AX,ERR_S_READ		;ｴﾗｰｺｰﾄﾞ
		JMP	EXIT

;-----------------------------------------------------集計

S_ADD:
				;単精度実数をＨＥＸに変換
		MOV	AX,WORD PTR F1.P1[OFSET]	;営業収入下位
		MOV	BX,WORD PTR F1.P1[OFSET+2]	;営業収入上位

		XOR	CX,CX
		XOR	DX,DX
		AND	BH,01111111B
		MOV	DL,BH
		MOV	CL,24
		SUB	CL,BH
		XOR	BH,BH

		OR	CL,CL
		JZ	NLOOP
		
LOOP1:
		SHR	BX,1
		RCR	AX,1
		LOOP	LOOP1
NLOOP:
		CMP	DL,16
		JA	S_NEXT
		MOV	CL,DL
		MOV	DX,1
		DEC	CL
		JZ	SET1
LOOP2:
		SHL	DX,1
		LOOP	LOOP2
SET1:
		OR 	AX,DX
		JMP	S_EXIT

S_NEXT:
		SUB	DL,16
		MOV	CL,DL
		MOV	DX,1
		DEC	CL
		JZ	SET
LOOP3:
		SHL	DX,1
		LOOP	LOOP3
SET:
		OR	BX,DX

S_EXIT:
		MOV	WORD PTR P1_EIS[OFSET],AX
		MOV	WORD PTR P1_EIS[OFSET+2],BX
;----------------------------------------営業収入
S_KINTAI:
	CLC						;ｷｬﾘｰFLGﾘｾｯﾄ
	MOV	AX,KH.K2[OFSET]				;営業収入下位
	MOV	BX,WORD PTR P1_EIS[OFSET]		;変換後営業収入下位

	ADC	AX,BX					;
	MOV	KH.K2[OFSET],AX				;集計ｴﾘｱにｾｯﾄ

	MOV	AX,KH.K1[OFSET]				;営業収入上位
	MOV	BX,WORD PTR P1_EIS[OFSET+2]		;変換後営業収入上位

	ADC	AX,BX					;
	MOV	KH.K1[OFSET],AX				;集計ｴﾘｱにｾｯﾄ

;----------------------------------------------無線回数
	MOV	AX,KH.K3[OFSET]				;集計無線回数
	MOV	BX,F1.P2[OFSET]				;読み込み無線回数

	ADD	AX,BX					;
	MOV	KH.K3[OFSET],AX				;集計ｴﾘｱにｾｯﾄ

;----------------------------------------------予約回数
	MOV	AX,KH.K4[OFSET]				;集計予約回数
	MOV	BX,F1.P3[OFSET]				;読み込み予約回数

	ADD	AX,BX					;
	MOV	KH.K4[OFSET],AX				;集計ｴﾘｱにｾｯﾄ
;----------------------------------------------拘束時間
	MOV	AX,F1.P4[OFSET]				;拘束時間
	OR	AX,AX
	JZ	S_KINTAI1
	XOR	DX,DX
	MOV	BX,100					;時間 to 分に変換
	DIV	BX
	MOV	CX,DX
	MOV	BX,60
	MUL	BX
	ADD	AX,CX
	MOV	BX,AX

	CLC						;ｷｬﾘｰFLGﾘｾｯﾄ
	MOV	AX,KH.K6[OFSET]				;拘束時間下位
	ADC	AX,BX					;
	MOV	KH.K6[OFSET],AX				;集計ｴﾘｱにｾｯﾄ

	MOV	AX,KH.K5[OFSET]				;拘束時間上位
	ADC	AX,0
	MOV	KH.K5[OFSET],AX				;集計ｴﾘｱにｾｯﾄ

;----------------------------------------------ﾊﾝﾄﾞﾙ時間
S_KINTAI1:	
	MOV	AX,F1.P5[OFSET]				;ﾊﾝﾄﾞﾙ時間
	OR	AX,AX
	JZ	S_KINTAI2
	XOR	DX,DX
	MOV	BX,100					;時間 to 分に変換
	DIV	BX
	MOV	CX,DX
	MOV	BX,60
	MUL	BX
	ADD	AX,CX
	MOV	BX,AX

	CLC						;ｷｬﾘｰFLGﾘｾｯﾄ
	MOV	AX,KH.K8[OFSET]				;ﾊﾝﾄﾞﾙ時間下位
	ADC	AX,BX					;
	MOV	KH.K8[OFSET],AX				;集計ｴﾘｱにｾｯﾄ

	MOV	AX,KH.K7[OFSET]				;ﾊﾝﾄﾞﾙ時間上位
	ADC	AX,0
	MOV	KH.K7[OFSET],AX				;集計ｴﾘｱにｾｯﾄ

;----------------------------------------------欠格回数
S_KINTAI2:
	MOV	AX,KH.K9[OFSET]				;集計欠格回数
	MOV	BX,F1.P6[OFSET]				;読み込み欠格回数

	ADD	AX,BX					;
	MOV	KH.K9[OFSET],AX				;集計ｴﾘｱにｾｯﾄ
;----------------------------------------------勤務区分別集計
	XOR	BX,BX
	MOV	CX,F1.P8[OFSET]				;勤務日数
	MOV	DX,F1.P7[OFSET]				;勤務区分
	OR	DX,DX					;勤務区分がない!
	JZ	S_KINTAI3
	CMP	DX,KB_MAX				;勤務区分最大値
	JA	S_KINTAI3
	ADD	BX,DX
	ADD	BX,DX

	MOV	AX,KH.K9[OFSET][BX]			;集計回数
	ADD	AX,CX					;
	MOV	KH.K9[OFSET][BX],AX			;集計ｴﾘｱにｾｯﾄ

S_KINTAI3:


;---------------------------------------------------------------------------

REP_DATA:
		XOR	AX,AX
		DEC	DAY_COUNT[OFSET]
		JNE	MOV2_POINT
		JMP	EXIT

;-----------------------------------------------------------------------
MOV2_POINT:
		INC	DAY_REC_C[OFSET]
		MOV	AX,DAY_REC_C[OFSET]
		CMP	DAY_MAX[OFSET],AX
		JAE	MOV2_POINT1
							;MMASN.UD
		MOV	BX,F1_NO[OFSET]
		MOV	CX,WORD PTR F_POINT[OFSET]
		MOV	DX,WORD PTR F_POINT[OFSET+2]
		MOV	AL,0
		MOV	AH,42H
		INT	21H

		JC	MOV2_ERR
		MOV	DAY_REC_C[OFSET],1
		JMP	MOV2_POINT_EXIT

MOV2_POINT1:


MOV2_POINT_EXIT:

		JMP	S_READ

MOV2_ERR:
		MOV	AX,ERR_MOV2_POINT
		JMP	EXIT
;--------------------------------------------------------------------------

EXIT:
		MOV	BX,[BP].S_FLG	;ｽﾃｰﾀｽFLGアドレス取得
		MOV	[BX],AX		;ｽﾃｰﾀｽFLGセット   AXにｾｯﾄ

		MOV	SI,OFFSET KH.K1[OFSET]
		MOV	DI,K_ADD[OFSET]
		CLD
		MOV	CX,KH_SIZE
		REP	MOVSW

		MOV	DI,OFFSET KH.K1[OFSET]
		XOR	AX,AX
		CLD
		MOV	CX,KH_SIZE
		REP	STOSW

		POPA			;全レジスタ復帰
        	POP	BP		;BP復帰
		RET	14		;スタック調整RETURN


;--------------------------------------------------------------------------
;		明細FIELD 設定
;		レコードレングス設定  MMASN.UD
;--------------------------------------------------------------------------

F1_STR	STRUC
	P1	DD	0				;営業収入
	P2	DW	0				;無線回数
	P3	DW	0				;予約回数
	P4	DW	0				;拘束時間
	P5	DW	0				;ﾊﾝﾄﾞﾙ時間
	P6	DW	0				;欠格回数
	P7	DW	0				;勤務区分
	P8	DW	0				;勤務日数
F1_STR	ENDS
F1	F1_STR		<,,,,,,>			;初期化

F1_SIZE	EQU	SIZE F1
F1_BUF	EQU	F1_SIZE*366
F1_NO	DW	0				;ファイルハンドル


;--------------------------------------------------------------------------
;		格納配列 設定
;		レコードレングス設定 
;--------------------------------------------------------------------------

K_STR	STRUC
	K1	DW	0				;営業収入 上位	  
	K2	DW	0				;営業収入 下位    
	K3	DW	0				;無線回数         
	K4	DW	0				;予約回数         
	K5	DW	0				;拘束時間 上位    
	K6	DW	0				;拘束時間 下位    
	K7	DW	0				;ﾊﾝﾄﾞﾙ時間上位    
	K8	DW	0				;ﾊﾝﾄﾞﾙ時間下位    
	K9	DW	0				;欠格回数         
	K10	DW	0				;通常勤務日数     
	K11	DW	0				;公出１日数       
	K12	DW	0				;公出２日数       
	K13	DW	0				;労災日数         
	K14	DW	0				;有給日数         
	K15	DW	0				;欠勤日数         
	K16	DW	0				;公休日数         
	K17	DW	0				;穴埋日数         
	K18	DW	0				;有欠日数         
	K19	DW	0				;欠有日数         
	K20	DW	0				;有通日数         
	K21	DW	0				;欠通日数         
K_STR	ENDS
KH	K_STR	<,,,,,,,,,,,,,,,,,,,,>			;初期化

KH_SIZE	EQU	SIZE KH/2
KB_MAX	EQU	21
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
F_POINT		DD	0				;ファイルポインター退避
K_ADD		DW	0				;格納配列ｱﾄﾞﾚｽ
D_DAYC		DW	0				;勤務日数
P1_EIS		DD	0				;営業収入 変換後

MAIN	ENDP
endp	EQU	$

CODE		ENDS
		END
