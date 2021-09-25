INCLUDE	MDOS.H
INCLUDE	MACRO.H
INCLUDE	STD.H

L_ADD		EQU	0F800H		;BLOAD address = DS:F800
OFSET		EQU	L_ADD-7

PARA_OP	STRUC				;スタック受渡テーブル
	BP_SV	DW	?		;BP退避
	R_ADD	DD	?		;RETURN	ADD
	S_FLG	DW	?		;ｽﾃｰﾀｽFLG
	D_REC	DW	?		;日付REC
	J_REC	DW	?		;乗務員REC
	D_DAY	DW	?		;勤務日数
	K_KBN	DW	?		;勤務区分
	K_KAI	DW	?		;欠格回数
	H_TIM	DW	?		;ﾊﾝﾄﾞﾙ時間  13:00>>>1300
	K_TIM	DW	?		;拘束時間   13:00>>>1300
	Y_KAI	DW	?		;予約回数
	M_KAI	DW	?		;無線回
	E_SYU	DW	?		;営業収入   単精度実数
	NO_P	DW	?		;FILE No
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

;--------------------------乗務員ＲＥＣ


		MOV	BX,[BP].J_REC	;乗務員ＲＥＣアドレス取得
		MOV	AX,[BX]		;乗務員ＲＥＣの中身
		MOV	JADD_REC[OFSET],AX


;--------------------------日数ＲＥＣ


		MOV	BX,[BP].D_REC	;日数ＲＥＣアドレス取得
		MOV	AX,[BX]		;日数ＲＥＣの中身
		MOV	DAY_REC[OFSET],AX

;--------------------------ファイルハンドル

		MOV	BX,[BP].NO_P	;ファイルハンドルアドレス取得
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
		MOVE_PTR	F1_NO[OFSET],0,0,0	;MMAS.UD
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

;-----------------------------------------------ぽいんたー移動 F1_BUF

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

		MOV	WORD PTR F1_POINT[OFSET],DX	;ファイルのポインター
		MOV	WORD PTR F1_POINT[OFSET+2],AX	;DAY_REC=0 のﾎﾟｲﾝﾀｰ

		JMP	MOV1_CHK

MOV_ERR:
		MOV	AX,ERR_MOV_POINT		;ｴﾗｰｺｰﾄﾞ
		JMP	EXIT

;-----------------------------------------------ぽいんたー移動ちぇっく

MOV1_CHK:
		MOV	CX,DAY_REC[OFSET]	;DAYのレコード番号
		DEC	CX			;REC 1減
		OR	CX,CX			;IF CX=0 THEN GOTO S_READ
		JNE	MOV1_POINT		;        ELSE  MOV1_POINT
		JMP	S_READ			;S_READの処理へ

;-----------------------------------------------ぽいんたー移動 F1_FIELD

MOV1_POINT:

		MOV	AX,F1_FIELD
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
		READ_HANDLE	F1_NO[OFSET],F1.P1[OFSET],F1_FIELD
		JC	READ_ERR

		CMP	AX,F1_FIELD
		JZ	SET_D

READ_ERR:
		MOV	AX,ERR_S_READ		;ｴﾗｰｺｰﾄﾞ
		JMP	EXIT

SET_D:
;--------------------------営業収入

		MOV	BX,[BP].E_SYU		;営業収入のアドレス取得
						;営業収入下位の中身
		MOV	AX,WORD PTR F1.P1[OFSET]
		MOV	[BX],AX
						;営業収入上位の中身
		MOV	AX,WORD PTR F1.P1[OFSET+2]
		MOV	[BX+2],AX

;--------------------------無線回数

		MOV	BX,[BP].M_KAI		;無線回数アドレス取得
		MOV	AX,F1.P2[OFSET]		;無線回数の中身
		MOV	[BX],AX

;--------------------------予約回数

		MOV	BX,[BP].Y_KAI		;予約回数アドレス取得
		MOV	AX,F1.P3[OFSET]		;予約回数の中身
		MOV	[BX],AX

;--------------------------拘束時間

		MOV	BX,[BP].K_TIM		;拘束時間アドレス取得
		MOV	AX,F1.P4[OFSET]		;拘束時間の中身
		MOV	[BX],AX

;--------------------------ハンドル時間

		MOV	BX,[BP].H_TIM		;ﾊﾝﾄﾞﾙ時間アドレス取得
		MOV	AX,F1.P5[OFSET]		;ﾊﾝﾄﾞﾙ時間の中身
		MOV	[BX],AX

;--------------------------欠格回数


		MOV	BX,[BP].K_KAI		;欠格回数アドレス取得
		MOV	AX,F1.P6[OFSET]		;欠格回数の中身
		MOV	[BX],AX

;--------------------------勤務区分

		MOV	BX,[BP].K_KBN		;勤務区分アドレス取得
		MOV	AX,F1.P7[OFSET]		;勤務区分の中身
		MOV	[BX],AX

;--------------------------勤務日数

		MOV	BX,[BP].D_DAY		;勤務日数アドレス取得
		MOV	AX,F1.P8[OFSET]		;勤務日数の中身
		MOV	[BX],AX
		XOR	AX,AX
;----------------------------------------------------------

EXIT:
		MOV	BX,[BP].S_FLG	;ｽﾃｰﾀｽFLGアドレス取得
		MOV	[BX],AX		;ｽﾃｰﾀｽFLGセット   AXにｾｯﾄ

		POPA			;全レジスタ復帰
        	POP	BP		;BP復帰
		RET	24		;スタック調整RETURN

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


;-----------------------------------------------------------------------------
;		明細FIELD 設定
;		レコードレングス設定
;-----------------------------------------------------------------------------

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

F1_FIELD	EQU	SIZE F1
F1_BUF		EQU	F1_FIELD*366
F1_NO		DW	0				;ファイルハンドル

JADD_REC	DW	0				;乗務員REC
DAY_REC		DW	0				;日数
F1_POINT	DD	0				;ﾎﾟｲﾝﾀｰ退避ｴﾘｱ


MAIN	ENDP
endp	EQU	$

CODE		ENDS
		END
