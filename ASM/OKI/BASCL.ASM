
INCLUDE	MDOS.H
INCLUDE	MACRO.H
INCLUDE	STD.H

L_ADD		EQU	0FD00H		;BLOAD address = DS:FD00
OFSET		EQU	L_ADD-7


PARA_OP	STRUC				;スタック受渡テーブル
	BP_SV	DW	?		;BP退避
	R_ADD	DD	?		;RETURN	ADD
	S_FLG	DW	?		;ｽﾃｰﾀｽFLG
	J_REC	DW	?		;乗務員REC
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

;--------------------------ファイルハンドル

		MOV	BX,[BP].NO_P	;ファイルハンドルアドレス取得
		MOV	AX,[BX]		;ファイルハンドルの中身
		MOV	F1_NO[OFSET],AX

;--------------------------ファイルポインタの移動  BUF_SIZE
REC_CHK:
		MOV	CX,JADD_REC[OFSET]	;JADDのレコード番号
		OR	CX,CX			;REC=0のﾁｪｯｸ
		JNE	S_POINT			;IF REC=0 THEN GOTO EXIT
						;         ELSE GOTO S_POINT
		MOV	AX,ERR_REC_CHK			;ｴﾗｰｺｰﾄﾞ
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
		OR	CX,CX			;IF CX=0 THEN GOTO WRITE_DATA
		JNE	MOV_POINT		;        ELSE  MOV_POINT
		JMP	WRITE_DATA		;書き込み処理へ

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
		JMP	WRITE_DATA

MOV_ERR:
		MOV	AX,ERR_MOV_POINT		;ｴﾗｰｺｰﾄﾞ
		JMP	EXIT

;--------------------------ファイルに書き込み

WRITE_DATA:
		MOV	CX,DAY_MAX
WRITE_LOOP:
		PUSH	CX
		MOV	AX,4000H
		MOV	DX,OFFSET F1.P1[OFSET]
		MOV	CX,F1_FIELD
		MOV	BX,F1_NO[OFSET]
		INT	21H
		POP	CX

		JC	WRITE_ERR
		CMP	AX,F1_FIELD
		JNE	WRITE_ERR
		LOOP	WRITE_LOOP
		XOR	AX,AX
		JMP	SHORT EXIT

WRITE_ERR:
		MOV	AX,ERR_S_WRITE
		JMP	SHORT EXIT


EXIT:
		MOV	BX,[BP].S_FLG	;ｽﾃｰﾀｽFLGアドレス取得
		MOV	[BX],AX		;ｽﾃｰﾀｽFLGセット   AXにｾｯﾄ

		POPA			;全レジスタ復帰
        	POP	BP		;BP復帰
		RET	6		;スタック調整RETURN

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
F1	F1_STR		<0,0,0,0,0,0,0,0>		;初期化

F1_FIELD	EQU	SIZE F1
F1_BUF		EQU	F1_FIELD*366
F1_NO		DW	0				;ファイルハンドル

JADD_REC	DW	0				;乗務員REC
DAY_REC		DW	0				;日数
F1_POINT	DD	0				;ﾎﾟｲﾝﾀｰ退避ｴﾘｱ

DAY_MAX		EQU	366				;

MAIN	ENDP
endp	EQU	$

CODE		ENDS
		END
