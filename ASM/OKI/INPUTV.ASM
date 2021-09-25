;****************************************
;*					*
;*	INPUT PROC	Ver 2.11	*
;*					*
;*	AH=座標Ｙ			*
;*	AL=座標Ｘ			*
;*	CH=機能コード			*
;*	CL=文字数			*
;*	SI=ソース文字列アドレス		*
;*					*
;*  	CALL (TEXT$,HX%,HY%,QZ%,OP%,	*
;*	      C1%,C2%,S%)		*
;*					*
;*	漢字コード	80H～ 9FH	*
;*			0E0H～0FFH	*
;*	ｶﾅコード	0A0H～0DFH	*
;*			   ｱ～ﾝ		*
;*	機能ｺｰﾄﾞ			*
;*	1･･数字のみ  			*
;*	2･･半角のみ			*
;*	3･･なんでも有り			*
;*					*
;*	4･･数字のみ  	ﾚﾝｸﾞｽで抜ける	*
;*	5･･半角のみ			*
;*	6･･なんでも有り			*
;*					*
;*	7･･全角のみ  			*
;*	8･･カナのみ			*
;*					*
;****************************************

;****************************************
;	MDOS.H	FUNCTION 21H		*
;	STD .H	ﾃﾞﾌｫﾙﾄ定義		*
;****************************************
INCLUDE	MDOS.H
INCLUDE	STD.H


KANJ_TBL_LEN	EQU	128			;漢字ﾃｰﾌﾞﾙﾚﾝｸﾞｽ WORD PTR
CU_TOP		EQU	6			;ｶｰｿﾙ開始位置
CU_END		EQU	7			;ｶｰｿﾙ終了位置
CU_DEF_TOP	EQU	0			;ｶｰｿﾙ開始位置 ﾃﾞﾌｫﾙﾄ
CU_DEF_END	EQU	7			;ｶｰｿﾙ終了位置 ﾃﾞﾌｫﾙﾄ
NOT_KEYC	EQU	20H			;入力キー制御コード
						;設定ｺｰﾄﾞ未満は受け付けない

FGC1		EQU	7			;表示色  白
BGC1		EQU	0			;背景色  黒
FGP1		EQU	0			;表示色拡張
BGP1		EQU	0			;背景色拡張

OFSET		EQU	0			;OFFSET

PARA_OP	STRUC				;スタック受渡テーブル
	BP_SS	DW	?		;BPの退避
	R_ADD	DW	?		;RETURN	ADD  ASM仕様
	S_FL	DW	?		;ｼｰｸﾚｯﾄFLG
	C2_P	DW	?		;入力背景色BGC
	C1_P	DW	?		;入力表示色FGC
	OP_P	DW	?		;オプション
	QZ_P	DW	?		;キコード
	Y_P	DW	?		;Y	ADD
	X_P	DW	?		;X	ADD
	TX_P	DW	?		;TEXT$	ADD
PARA_OP	ENDS

CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE

	PUBLIC	INPUT1

STARTP	EQU	$
;MAIN PROGRAM------------------------------------------------------------------
INPUT1 	PROC	NEAR

	PUSH	BP
	MOV	ESC_FLG[OFSET],0
	MOV	S_FLG[OFSET],0

SUB_ST:

	MOV	BP,SP
	PUSHA

	MOV	BX,[BP].C2_P		;背景色アドレス
	MOV	AX,[BX]
	SHL	AL,1
	SHL	AL,1
	SHL	AL,1
	SHL	AL,1
	MOV	DL,AL			;一時対比
	
	MOV	BX,[BP].C1_P		;表示色アドレス
	MOV	AX,[BX]
	AND	AX,00001111B		;上位Bitﾏｽｸ
	OR	AL,DL		
	MOV	FBCG[OFSET],AL

	MOV	BX,[BP].S_FL		;ｼｰｸﾚｯﾄFLGアドレス
	MOV	AX,[BX]
	MOV	S_FLG[OFSET],AL

	MOV	BX,[BP].OP_P		;オプションアドレス
	MOV	AX,[BX]
	MOV	OP_FLG[OFSET],AL

	MOV	BX,[BP].QZ_P		;キーコードアドレス
	MOV	QZ_ADD[OFSET],BX

	MOV	BX,[BP].X_P		;Ｘ座標
	MOV	AX,[BX]
	MOV	INTBL.IN_X[OFSET],AL	;ﾛｹｰﾄX

	MOV	BX,[BP].Y_P		;Ｙ座標
	MOV	AX,[BX]
	MOV	INTBL.IN_Y[OFSET],AL	;ﾛｹｰﾄY

	MOV	BX,[BP].TX_P		;ＴＥＸＴ＄ ストリングディスクリプタ
;	MOV	CL,[BX]			;ＴＥＸＴ＄の長さ
;	MOV	INTBL.IN_L[OFSET],CL	;文字列ﾚﾝｸﾞｽ
;	MOV	SI,[BX+1]		;ＴＥＸＴ＄のアドレス
	MOV	SI,BX			;ＴＥＸＴ＄のアドレス
	MOV	TEXT_ADD[OFSET],SI	;

;------------------------------------------------------------------------
;CODE	SEGMENT	PUBLIC							-
;	ASSUME	CS:CODE,DS:DATA,ES:DATA					-
;									-
;****************************************				-
; 外部参照　	LOCATE			*				-
; モジュール名	INPUT			*				-
;****************************************				-
;EXTRN	LOCATE:NEAR							-
;PUBLIC	INPUT								-
;									-
;------------------------------------------------------------------------
;初期設定								-
;									-
;INPUT	PROC	NEAR							-
;------------------------------------------------------------------------

	XOR	AX,AX				;AX初期化
	XOR	BX,BX				;BX初期化
	XOR	CX,CX				;CX初期化
	XOR	DX,DX				;DX初期化
	MOV	INS_FLG[OFSET],0		;ｲﾝｻｰﾄﾌﾗｸﾞ初期化
	CLD					;ﾃﾞｨﾚｸｼｮﾝFLG ﾘｾｯﾄ
	MOV	DI,OFFSET INTBL.IN_K[OFSET]	;漢字FLGﾃｰﾌﾞﾙｸﾘｱｰ
	MOV	CX,KANJ_TBL_LEN			;ﾃｰﾌﾞﾙﾚﾝｸﾞｽ
	REP	STOSW				;[DI]にALｾｯﾄ

	MOV	DI,OFFSET INTBL.IN_D[OFSET]	;文字列格納ｱﾄﾞﾚｽ
	MOV	BP,DI				;DIをBPに退避
;	MOV	CL,INTBL.IN_L[OFSET]		;文字列ﾚﾝｸﾞｽ
;--------------------------------------------------------------------
;文字列ワークエリアにコピー

CP_CHR:
	MOV	AL,CS:[SI]			;SIの示す文字列ｺﾋﾟｰ
	OR	AL,AL				;IF AL=0 THEN GOTO CP_CHR2
	JZ	CP_CHR2
	CMP	INTBL.IN_K[BX][OFSET],2		;漢字ｺｰﾄﾞ２ﾊﾞｲﾄ目ﾁｪｯｸ
	JZ	CP_CHR1
	CALL	KNJ_CHK				;漢字ｺｰﾄﾞﾁｪｯｸ
	CMP	KNJ_CHK_F[OFSET],1		;漢字ｺｰﾄﾞ１ﾊﾞｲﾄ目ﾁｪｯｸ
	JNE	CP_CHR1
	MOV	INTBL.IN_K[BX][OFSET],1		;漢字ﾃｰﾌﾞﾙｾｯﾄ
	MOV	INTBL.IN_K[BX+1][OFSET],2	;漢字ﾃｰﾌﾞﾙｾｯﾄ
CP_CHR1:
	INC	BX				;文字数ｶｳﾝﾄ
	MOVSB					;[DI]に[SI]の内容ｺﾋﾟｰ
	JMP	SHORT CP_CHR
CP_CHR2:					;文字ﾚﾝｸﾞｽの示す所
;	MOV	CL,INTBL.IN_L[OFSET]		;までSPCをｾｯﾄ
;	SUB	CX,BX
;	LEA	DI,INTBL.IN_D[BX][OFSET]
;	MOV	AL,SPC
;	REP	STOSB
CP_CHR3:					;文字ﾚﾝｸﾞｽの最後にNULｾｯﾄ
MOV	INTBL.IN_L[OFSET],BL			;文字ﾚﾝｸﾞｽｾｯﾄ
	MOV	BYTE PTR [DI],NUL
	MOV	DI,BP				;DI復帰
	CALL	INP_CRT				;画面表示

;---------------------------------------------------------------------
;メインスタート 入力ロケート表示

	CMP	ESC_FLG[OFSET],1
	JNE	INP_START
	MOV	AL,1BH
	JMP	INP_END

INP_START:
	MOV	AH,INTBL.IN_Y[OFSET]		;ﾛｹｰﾄY
	MOV	AL,INTBL.IN_X[OFSET]		;ﾛｹｰﾄX	
	ADD	AL,BL				;ﾛｹｰﾄXに文字ﾎﾟｼﾞｼｮﾝﾌﾟﾗｽ
	CALL	LOCATE				;PROC NEAR


;--------------------------------------------------------------------------
;キー入力

	XOR	DX,DX				;AL=ｺｰﾄﾞ
	MOV	AH,07H				;一文字入力
	INT	21H				;INT 80H
						;AX,BX,ES破壊
						;CL=18H

;--------------------------------------------------------------------------
;制御コードジャンプテーブルルーチン

	MOV	SI,OFFSET KEY_TBL[OFSET-4]	;ｷｰﾃｰﾌﾞﾙ OFFSET
KEY_C:	ADD	SI,4;
	CMP	BYTE PTR [SI],0FFH		;ｷｰﾃｰﾌﾞﾙ最後
	JZ	KEY_EXIT
	CMP	AL,[SI]				;ｷｰｺｰﾄﾞ比較
	JNZ	KEY_C
	JMP	[SI+2]				;ﾃｰﾌﾞﾙｼﾞｬﾝﾌﾟ
KEY_EXIT:
	JMP	INP_0				;制御文字以外
;--------------------------------------------------------------------------
;制御コード処理ルーチン

LEFT0:						;←の処理判定
	CMP	BL,0				;１番左端
	JNE	LEFT1
	CALL	BEEP1
	JMP	INP_START
LEFT1:
	DEC	BL				;ｶｰｿﾙ左に移動
	CMP	INTBL.IN_K[BX][OFSET],2		;漢字ｺｰﾄﾞ2ﾊﾞｲﾄ目かﾁｪｯｸ
	JNE	LEFT2
	DEC	BL
LEFT2:
;	CMP	OP_FLG[OFSET],BAK_OP_FLG1
						;ｵﾌﾟｼｮﾝ3,6ﾊﾞｯｸｽﾍﾟｰｽ処理
;	JZ	BS2
;	CMP	OP_FLG[OFSET],BAK_OP_FLG2
;	JZ	BS2
	JMP	INP_START
;--------------------------------------------------------------------------

BS0:						;ＢＳ処理判定
	CMP	BL,0				;１番左端
	JNE	BS1
	CALL	BEEP1
	JMP	INP_START
BS1:
	DEC	BL				;ｶｰｿﾙ左に移動
	CMP	INTBL.IN_K[BX][OFSET],2		;漢字ｺｰﾄﾞ2ﾊﾞｲﾄ目かﾁｪｯｸ
	JNE	BS2
	DEC	BL
BS2:
	CALL	DEL_1
	JMP	INP_START
;--------------------------------------------------------------------------

RIGHT0:						;→の処理
;	CMP	OP_FLG[OFSET],RIGHT_OP_FLG1	;ｵﾌﾟｼｮﾝ3,6右移動ｽﾄｯﾌﾟ
;	JZ	RIGHT3
;	CMP	OP_FLG[OFSET],RIGHT_OP_FLG2
;	JZ	RIGHT3
	INC	BL
	CMP	INTBL.IN_K[BX][OFSET],2		;漢字ｺｰﾄﾞ2ﾊﾞｲﾄ目かﾁｪｯｸ
	JZ	RIGHT1
	CMP	BL,INTBL.IN_L[OFSET]
	JNE	RIGHT3
	CALL	BEEP1
	DEC	BL
	JMP	INP_START
RIGHT1:
	MOV	DL,INTBL.IN_L[OFSET]
	DEC	DL
	CMP	BL,DL				;漢字の2ﾊﾞｲﾄが最後
	JNE	RIGHT2
	CALL	BEEP1
	SUB	BL,2
RIGHT2:
	INC	BL
RIGHT3:
	JMP	INP_START
;--------------------------------------------------------------------------

INS0:						;INSの処理
	CMP	INS_FLG[OFSET],0		;FLG=0 ｲﾝｻｰﾄﾓｰﾄﾞ設定
	JZ	INS1				;FLG=1 ｲﾝｻｰﾄﾓｰﾄﾞ解除
	MOV	INS_FLG[OFSET],0
	MOV	CH,CU_DEF_TOP			;ﾃﾞﾌｫﾙﾄのﾄｯﾌﾟ位置
	MOV	CL,CU_DEF_END			;ﾃﾞﾌｫﾙﾄのﾄﾞｯﾄ数
	JMP	SHORT INS2
INS1:
	MOV	INS_FLG[OFSET],1		;ｲﾝｻｰﾄﾓｰﾄﾞ設定
	MOV	CH,CU_TOP			;ｶｰｿﾙ開始位置
	MOV	CL,CU_END			;ｶｰｿﾙ終了位置
INS2:
	MOV	AH,01				;ｶｰｿﾙ形状
	INT	10H				;
	JMP	INP_START			;ES,AX,BX破壊
;----------------------------------------------------------------------
DEL0:						;DELの処理
	CALL	DEL_1
	JMP	INP_START
;----------------------------------------------------------------------

HOME0:
;	CMP	OP_FLG[OFSET],BAK_OP_FLG1
;	JZ	CLS0
;	CMP	OP_FLG[OFSET],BAK_OP_FLG2
;	JZ	CLS0
	MOV	BL,0				;先頭行ヘセット
	JMP	INP_START
;----------------------------------------------------------------------

CLS0:
	MOV	AL,SPC				;SPCｺｰﾄﾞ
	XOR	CX,CX
	CLD					;ﾃﾞｨﾚｸｼｮﾝFLG ﾘｾｯﾄ
	MOV	DI,OFFSET INTBL.IN_D[OFSET]	;文字ｴﾘｱｸﾘｱｰ
	MOV	CL,INTBL.IN_L[OFSET]		;文字ﾚﾝｸﾞｽ
	REP	STOSB				;[DI]にALｾｯﾄ

	XOR	AX,AX
	XOR	CX,CX
	MOV	DI,OFFSET INTBL.IN_K[OFSET]	;漢字FLGﾃｰﾌﾞﾙｸﾘｱｰ
	MOV	CX,KANJ_TBL_LEN			;ﾃｰﾌﾞﾙﾚﾝｸﾞｽ
	REP	STOSW				;[DI]にAXｾｯﾄ

	CALL	INP_CRT
	MOV	BL,0				;先頭行ヘセット
	JMP	INP_START
;----------------------------------------------------------------------
ESC0:
	POPA
	MOV	ESC_FLG[OFSET],1
	JMP	SUB_ST
;------------------------------------------------------------------------
CR0:
	JMP	INP_END
;------------------------------------------------------------------------
UP0:
	CMP	BL,0
	JNE	UP0_1
	JMP	INP_END
UP0_1:
	CALL	BEEP1
	JMP	INP_START
;------------------------------------------------------------------------
DO0:
	CMP	BL,0
	JNE	DO0_1
	JMP	INP_END
DO0_1:
	CALL	BEEP1
	JMP	INP_START


;------------------------------------------------------------------------
BREAK0:
	JMP	INP_END
;------------------------------------------------------------------------
;文字入力処理

INP_0:
	MOV	INC_FLG[OFSET],0		;ｲﾝｸﾘﾒﾝﾄFLG=0
INP_01:
	CMP	AL,NOT_KEYC			;CHAR ｺｰﾄﾞが20H未満
	JAE	INP_02
	JMP	INP_START
INP_02:
	CALL	OP_CHK				;ｵﾌﾟｼｮﾝﾁｪｯｸ
	CMP	NG[OFSET],0			;入力制限FLG NG=1 入力拒否
	JZ	INP_1
	CALL	BEEP1
	JMP	INP_START
INP_1:
	CALL	KNJ_CHK				;漢字ｺｰﾄﾞﾁｪｯｸ
	CMP	KNJ_CHK_F[OFSET],1;
	JNE	INP_4				;漢字ｺｰﾄﾞじゃない場合は、INP_4
	CMP	INTBL.IN_D[BX+1][OFSET],NUL	;へｼﾞｬﾝﾌﾟ
	JNE	INP_2				;漢字ｺｰﾄﾞで2ﾊﾞｲﾄ目が入らない
						;場合は、BUFFER ｸﾘｱｰする
 	PUSH	BX				;BIOS CALL
	PUSH	ES				;CL=18H
	MOV	CL,18H				;INT 80H
	INT	80H				;AL=ｺｰﾄﾞ
	POP	ES				;ES,AX,BX破壊
	POP	BX				;入力BUFFER ｸﾘｱｰ
	JMP	INP_START
INP_2:
	CMP	INS_FLG[OFSET],1		;ｲﾝｻｰﾄﾓｰﾄﾞかﾁｪｯｸ
	JNE	INP_3
	CALL	INS_1				;ｲﾝｻｰﾄﾙｰﾁﾝｺｰﾙ
INP_3:
	MOV	INTBL.IN_D[BX][OFSET],AL	;漢字ｺｰﾄﾞ入力処理
	MOV	INTBL.IN_K[BX][OFSET],1		;1ﾊﾞｲﾄ目ｾｯﾄ処理
 	PUSH	BX				;BIOS CALL
	PUSH	ES				;CL=18H
	MOV	CL,18H				;INT 80H
	INT	80H
	POP	ES				;AL=ｺｰﾄﾞ
	POP	BX				;ES,AX,BX破壊
	MOV	INTBL.IN_D[BX+1][OFSET],AL	;2ﾊﾞｲﾄ目ｾｯﾄ処理
	MOV	INTBL.IN_K[BX+1][OFSET],2
	CMP	INTBL.IN_D[BX+2][OFSET],NUL	;入力後次のｶｰｿﾙﾎﾟｼﾞｼｮﾝﾁｪｯｸ
	JZ	INP_6				;入力ﾎﾟｼﾞｼｮﾝがﾚﾝｸﾞｽの最後
	ADD	BL,2				;だったらINP_6 へｼﾞｬﾝﾌﾟ
	MOV	INC_FLG[OFSET],1		;
	JMP	SHORT INP_6			;NOT だったらﾎﾟｼﾞｼｮﾝ設定
INP_4:
	CMP	INS_FLG[OFSET],1		;半角処理ﾙｰﾁﾝ
	JNE	INP_5				;ｲﾝｻｰﾄﾓｰﾄﾞﾁｪｯｸ
	CALL	INS_1				;ｲﾝｻｰﾄﾙｰﾁﾝｺｰﾙ
INP_5:
	MOV	INTBL.IN_D[BX][OFSET],AL	;ｺｰﾄﾞｾｯﾄ
	MOV	INTBL.IN_K[BX][OFSET],0		;漢字FLGｸﾘｱｰ
	CMP	INTBL.IN_D[BX+1][OFSET],NUL	;次のｶｰｿﾙﾎﾟｼﾞｼｮﾝﾁｪｯｸ
	JZ	INP_6				;入力ﾎﾟｼﾞｼｮﾝがﾚﾝｸﾞｽの最後
	MOV	INC_FLG[OFSET],1		;だったら INP_6 へｼﾞｬﾝﾌﾟ
	INC	BL				; NOT だったらﾎﾟｼﾞｼｮﾝ設定

INP_6:
	CMP	INS_FLG[OFSET],1		;次のﾎﾟｼﾞｼｮﾝの処理判定処理
	JZ	INP_7
	CMP	INTBL.IN_K[BX][OFSET],2		;次のﾎﾟｼﾞｼｮﾝが漢字の2ﾊﾞｲﾄ目
	JNE	INP_7				;だった場合は漢字ﾃｰﾌﾞﾙをｸﾘｱｰ
	MOV	INTBL.IN_K[BX][OFSET],0		;文字列SPCｾｯﾄ
	MOV	INTBL.IN_D[BX][OFSET],SPC
INP_7:
	CALL	INP_CRT				;画面表示

	CMP	INC_FLG[OFSET],0		;ｶｰｿﾙの位置が移動可能の状態
	JNE	INP_8				;IF INC_FLG=1 THEN GOTO INP_8
						;移動できる状態だったらINP_8へ

	CMP	OP_FLG[OFSET],4			;IF OP_FLG<4 THEN GOTO INP_8
	JB	INP_8
	CMP	OP_FLG[OFSET],6			;IF OP_FLG>6 THEN GOTO INP_8
	JA	INP_8

	CMP	KNJ_CHK_F[OFSET],1		;漢字判定
	JZ	INP_7S				;非漢字の処理
	CMP	INTBL.IN_D[BX+1][OFSET],NUL	;次のｶｰｿﾙﾎﾟｼﾞｼｮﾝﾁｪｯｸ
	JNE	INP_8				;ｶｰｿﾙが移動できなかった
	JMP	INP_END				;次の文字がＮＵＬ
INP_7S:
						;漢字の処理
	CMP	INTBL.IN_D[BX+2][OFSET],NUL	;次のｶｰｿﾙﾎﾟｼﾞｼｮﾝﾁｪｯｸ
	JNE	INP_8				;ｶｰｿﾙが移動できなかった
	JMP	INP_END				;次の文字がＮＵＬ

INP_8:
	JMP	INP_START			;入力メインへ
;------------------------------------------------------------------------
;入力終了

INP_END:
	PUSH	AX
	PUSH	ES				;ES,AX,BX破壊
	MOV	DL,1				;BIOS CALL
	MOV	CH,CU_DEF_TOP			;ｶｰｿﾙ形状を元に戻す
	MOV	CL,CU_DEF_END			;INT 80H
	MOV	CL,2BH				;CL=2BH
	INT	80H
	POP	ES				;終了

	POP	AX
	MOV	BX,QZ_ADD[OFSET]		;OBASIC CALL
	MOV	BYTE PTR [BX],AL		;入力ｺｰﾄﾞRETURN	

	MOV	DI,TEXT_ADD[OFSET]		;ＴＥＸＴ＄のアドレス
	MOV	SI,OFFSET INTBL.IN_D[OFSET]
	MOV	CL,INTBL.IN_L[OFSET]
	REP	MOVSB


	POPA
	POP	BP

	RET	16			;STACK	ﾌﾘｰ RETURN

;-------------------------------------------------------------------------
;************************
;*	ｻﾌﾞﾙｰﾁﾝ		*
;************************

INP_CRT	PROC	NEAR				;画面表示	ﾙｰﾁﾝ
	PUSHA
	PUSH	BP
	
	MOV	AH,13H				;BIOS CALL
	MOV	AL,01H				;BIOS CALL
	XOR	BH,BH				;PAGE
	MOV	BL,FBCG[OFSET]			;色 上位4Bit B  下位 4Bit F	
	MOV	CX,INTBL.IN_L[OFSET]		;文字数
	MOV	DH,INTBL.IN_Y[OFSET]
	MOV	DL,INTBL.IN_X[OFSET]

	CMP	S_FLG[OFSET],0			;ｼｰｸﾚｯﾄ文字があるか
	JZ	INP_CRT_JNE
	LEA	BP,S_MOJI[OFSET]		;ｼｰｸﾚｯﾄ文字ｾｯﾄ
	JMP	INP_CRT_BIOS
INP_CRT_JNE:
	LEA	BP,INTBL.IN_D[OFSET]		;文字ｱﾄﾞﾚｽｾｯﾄ
INP_CRT_BIOS:
	INT	10H

INP_CRT_EXIT:

	POP	BP
	POPA
	RET
INP_CRT	ENDP

BEEP1	PROC	NEAR				;ﾋﾞｰﾌﾟ音発生	ﾙｰﾁﾝ
	DISPLAY_CHAR	BEEP			;FUNCTION 02H
	RET					;MDOS.H
BEEP1	ENDP

INS_1	PROC	NEAR				;INS処理	ﾙｰﾁﾝ
	MOV	INP_COUNT[OFSET],BL		;入力ﾎﾟｼﾞｼｮﾝ退避
	MOV	CL,INTBL.IN_L[OFSET]		;文字列ﾚﾝｸﾞｽ取得
	SUB	CL,BL				;ﾚﾝｸﾞｽと入力数の差
	MOV	CL_STK[OFSET],CL		;ｽﾄｯｸ
	MOV	BL,INTBL.IN_L[OFSET]		;後ろから移動
	LEA	DI,INTBL.IN_K[BX-1][OFSET]	;移動先のｱﾄﾞﾚｽ取得
	MOV	DI_STK[OFSET],DI		;ｽﾄｯｸ(漢字ﾃｰﾌﾞﾙ)
	LEA	DI,INTBL.IN_D[BX-1][OFSET]	;移動先のｱﾄﾞﾚｽ取得
	CMP	KNJ_CHK_F[OFSET],1		;漢字ｺｰﾄﾞかﾁｪｯｸ
	JNE	INS_2				;漢字じゃない時の飛び先
	DEC	BL				;
	DEC	CL
	MOV	CL_STK[OFSET],CL
INS_2:
	LEA	SI,INTBL.IN_K[BX-2][OFSET]	;移動元のｱﾄﾞﾚｽ取得
	MOV	SI_STK[OFSET],SI		;ｽﾄｯｸ(漢字ﾃｰﾌﾞﾙ)
	LEA	SI,INTBL.IN_D[BX-2][OFSET]	;移動元のｱﾄﾞﾚｽ取得
	STD					;ﾃﾞｨﾚｸｼｮﾝ FLG ｾｯﾄ
	REP	MOVSB				;[SI]ｶﾗ[DI]ｺﾋﾟｰ
	MOV	DI,DI_STK[OFSET]		;CX回実行
	MOV	SI,SI_STK[OFSET]
	MOV	CL,CL_STK[OFSET]
	REP	MOVSB
	MOV	BL,INTBL.IN_L[OFSET]
	CMP	INTBL.IN_K[BX-1][OFSET],1
	JNE	INS_3
	MOV	INTBL.IN_D[BX-1][OFSET],SPC
	MOV	INTBL.IN_K[BX-1][OFSET],0
INS_3:
	MOV	BL,INP_COUNT[OFSET]
	MOV	DI,BP
	CLD
	RET
INS_1	ENDP

DEL_1	PROC	NEAR				;DEL処理	ﾙｰﾁﾝ
	MOV	DEL_SPC[OFSET],0
	MOV	INP_COUNT[OFSET],BL
	MOV	CL,INTBL.IN_L[OFSET]
	SUB	CL,BL
	MOV	CL_STK[OFSET],CL
	LEA	DI,INTBL.IN_K[BX][OFSET]
	MOV	DI_STK[OFSET],DI
	LEA	DI,INTBL.IN_D[BX][OFSET]
	CMP	INTBL.IN_K[BX][OFSET],1
	JNE	DEL_2
	DEC	CL
	MOV	CL_STK[OFSET],CL
	INC	BL
	MOV	DEL_SPC[OFSET],1
DEL_2:
	LEA	SI,INTBL.IN_K[BX+1][OFSET]
	MOV	SI_STK[OFSET],SI
	LEA	SI,INTBL.IN_D[BX+1][OFSET]
	REP	MOVSB
	MOV	SI,SI_STK[OFSET]
	MOV	DI,DI_STK[OFSET]
	MOV	CL,CL_STK[OFSET]
	REP	MOVSB
DEL_3:
	MOV	BL,INTBL.IN_L[OFSET]
	MOV	INTBL.IN_D[BX-1][OFSET],SPC
	MOV	INTBL.IN_K[BX-1][OFSET],0
	CMP	DEL_SPC[OFSET],0
	JZ	DEL_4
	MOV	INTBL.IN_D[BX-2][OFSET],SPC
	MOV	INTBL.IN_K[BX-2][OFSET],0
DEL_4:
	CALL	INP_CRT
	MOV	BL,INP_COUNT[OFSET]
	RET
DEL_1	ENDP

OP_CHK	PROC	NEAR					;オプション	ﾙｰﾁﾝ
	MOV	NG[OFSET],0
	CALL	KNJ_CHK
	MOV	SI,OFFSET OP_TBL[OFSET-4]		;ｵﾌﾟｼｮﾝﾃｰﾌﾞﾙ OFFSET

OP_C:	ADD	SI,4					;
	CMP	BYTE PTR [SI],0FFH			;ｷｰﾃｰﾌﾞﾙ最後
	JZ	OP_EXIT
	MOV	DH,OP_FLG[OFSET]
	CMP	DH,[SI]					;ｷｰｺｰﾄﾞ比較
	JNZ	OP_C
	JMP	[SI+2]					;ﾃｰﾌﾞﾙｼﾞｬﾝﾌﾟ

OP_4:
OP_1:						;数字のみ
	CMP	KNJ_CHK_F[OFSET],1		;ｺｰﾄﾞが漢字ｺｰﾄﾞ
	JZ	OP_CHK_NG			;ﾁｪｯｸNGｾｯﾄ
	CMP	AL,"*"				;ｱｽﾀﾘｽｸはOK
	JZ	OP_1EXIT
	CMP	AL,"-"				;ﾏｲﾅｽはOK
	JZ	OP_1EXIT
	CMP	AL,"."				;ﾋﾟﾘｵﾄﾞはOK
	JZ	OP_1EXIT

	CMP	AL,30H				;ｺｰﾄﾞが"1"より小さい
	JB	OP_CHK_NG
	CMP	AL,39H				;ｺｰﾄﾞが"9"より大きい
	JA	OP_CHK_NG
OP_1EXIT:
	JMP	OP_EXIT

OP_2:
OP_5:						;半角のみ
	CMP	KNJ_CHK_F[OFSET],1		;ｺｰﾄﾞが漢字ｺｰﾄﾞ
	JZ	OP_CHK_NG
	JMP	OP_EXIT

OP_3:
OP_6:						;何でもあり
	JMP	OP_EXIT

OP_7:						;全角のみ
	CMP	KNJ_CHK_F[OFSET],1		;ｺｰﾄﾞが漢字ｺｰﾄﾞ
	JZ	OP_EXIT
	JMP	OP_CHK_NG

OP_8:						;カナのみ
	CMP	KNJ_CHK_F[OFSET],1		;ｺｰﾄﾞが漢字ｺｰﾄﾞ
	JZ	OP_CHK_NG
	CMP	AL,20H				;ｺｰﾄﾞがSPCはOK
	JZ	OP_EXIT
	CMP	AL,0A0H				;ｺｰﾄﾞが "ｱ"より小さい
	JB	OP_CHK_NG
	CMP	AL,0DFH				;ｺｰﾄﾞが "ﾝ"より大きい
	JA	OP_CHK_NG
	JMP	SHORT OP_EXIT


OP_CHK_NG:
 	CMP	KNJ_CHK_F[OFSET],1		;ｵﾌﾟｼｮﾝの指定が漢字を受け付け
						;ないﾓｰﾄﾞだったらｷｰﾊﾞｯﾌｧｸﾘｱｰ
	JNE	OP_CHK_NG1
	PUSH	BX				;BIOS CALL
	PUSH	ES				;CL=18H
	MOV	CL,18H				;INT 80H
	INT	80H				;一ﾊﾞｲﾄ入力
	POP	ES				;BX,ES破壊
	POP	BX
OP_CHK_NG1:
	MOV	NG[OFSET],1
OP_EXIT:
	RET
OP_CHK	ENDP

KNJ_CHK	PROC	NEAR				;漢字ｺｰﾄﾞﾁｪｯｸ	ﾙｰﾁﾝ
	MOV	KNJ_CHK_F[OFSET],0
	CMP	AL,80H
	JB	KNJ_EXIT
	CMP	AL,9FH
	JA	KNJ_CHK2
	MOV	KNJ_CHK_F[OFSET],1
	JMP	SHORT KNJ_EXIT
KNJ_CHK2:
	CMP	AL,0E0H
	JB	KNJ_EXIT
	CMP	AL,0FFH
	JA	KNJ_EXIT
	MOV	KNJ_CHK_F[OFSET],1
KNJ_EXIT:
	RET
KNJ_CHK	ENDP

;****************************************
;*					*
;*	LOCATE PROC	数値ｾｯﾄ用	*
;*					*
;*	AH=座標Ｙ	AL=座標Ｘ	*
;*					*
;*	LIB	UTY.LIB	登録		*
;****************************************


LOCATE	PROC	NEAR

	PUSHA

	MOV	DH,AH
	MOV	DL,AL
	MOV	AH,02H
	XOR	BH,BH
	INT	10H

	POPA
	RET

LOCATE	ENDP

;INPUT	ENDP----------------------------------------------------------------
;CODE	ENDS----------------------------------------------------------------


;DATA	SEGMENT	PUBLIC------------------------------------------------------

INP_STR	STRUC
	IN_Y	DB	0			;入力ﾛｹｰﾄY
	IN_X	DB	0			;入力ﾛｹｰﾄX
	IN_L	DB	0			;入力数
	IN_D	DB	256	DUP(0)		;ﾃﾞｰﾀ格納領域
	IN_K	DB	256	DUP(0)		;漢字ｺｰﾄﾞFLG
INP_STR	ENDS
INTBL	INP_STR	<,,,,>				;初期化


INP_COUNT	DB	0			;入力文字数退避領域
CL_STK		DB	0			;CL退避領域
SI_STK		DW	0			;SI退避領域
DI_STK		DW	0			;DI退避領域
INS_FLG		DB	0			;ｲﾝｻｰﾄﾓｰﾄﾞFLG
KNJ_CHK_F	DB	0			;漢字入力ﾁｪｯｸFLG
DEL_SPC		DB	0			;ﾃﾞｰﾘｰﾄﾙｰﾁﾝ ﾜｰｸFLG
OP_FLG		DB	0			;機能ｺｰﾄﾞ
QZ_ADD		DW	0			;入力ｺｰﾄﾞ ｱﾄﾞﾚｽ格納領域
NG		DB	0			;入力制限ﾁｪｯｸFLG
K_STK		DW	0			;ｷｰﾓｰﾄﾞ退避領域
KM_1		DW	0A400H			;全角
KM_2		DW	1400H			;ｶﾀｶﾅ
KM_3		DW	1400H			;ｶﾀｶﾅ
KM_4		DW	8400H			;ﾛｯｸ
KM_5		DW	8400H			;ﾛｯｸ
KM_6		DW	8400H			;ﾛｯｸ
FBCG		DB	0			;上位　4Bit B 下位 4Bit　F
INC_FLG		DB	0			;ｲﾝｸﾘﾒﾝﾄFLG
ESC_FLG		DB	0			;ｴｽｹｰﾌﾟFLG
TEXT_ADD	DW	0			;TEXTのアドレス
S_FLG		DB	0			;ｼｰｸﾚｯﾄFLG
S_MOJI		DB	256	DUP('*')	;ｼｰｸﾚｯﾄ文字

;		ｼﾞｬﾝﾌﾟﾃｰﾌﾞﾙ
;			ｺｰﾄﾞ　JMP先
KEY_TBL		DW	0008H,LEFT0[OFSET]		;←
		DW	000CH,RIGHT0[OFSET]		;→
		DW	0012H,INS0[OFSET]		;ｲﾝｻｰﾄ 	INS
		DW	007FH,DEL0[OFSET]		;ﾃﾞﾘｰﾄ	DEL
		DW	001CH,BS0[OFSET]		;ﾊﾞｯｸ   BS
		DW	001EH,HOME0[OFSET]		;ﾎｰﾑｷｰ  HOME
		DW	001AH,CLS0[OFSET]		;CLSｷｰ  CLS
		DW	001BH,ESC0[OFSET]		;ESCｷｰ  ESC
		DW	000DH,CR0[OFSET]		;CRｷｰ   CR
		DW	000BH,UP0[OFSET]		;↑
		DW	000AH,DO0[OFSET]		;↓
		DW	0003H,BREAK0[OFSET]		;BREAK  BREAK
		DB	0FFH   			;EXIT

;
;		ｼﾞｬﾝﾌﾟﾃｰﾌﾞﾙ
;			ｺｰﾄﾞ　JMP先
OP_TBL		DW	0001H,OP_1[OFSET]		;ｵﾌﾟｼｮﾝ1
		DW	0002H,OP_2[OFSET]		;ｵﾌﾟｼｮﾝ2
		DW	0003H,OP_3[OFSET]		;ｵﾌﾟｼｮﾝ3
		DW	0004H,OP_4[OFSET]		;ｵﾌﾟｼｮﾝ4
		DW	0005H,OP_5[OFSET]		;ｵﾌﾟｼｮﾝ5
		DW	0006H,OP_6[OFSET]		;ｵﾌﾟｼｮﾝ6
		DW	0007H,OP_7[OFSET]		;ｵﾌﾟｼｮﾝ7
		DW	0008H,OP_8[OFSET]		;ｵﾌﾟｼｮﾝ8
		DB	0FFH   			;EXIT

INPUT1	ENDP
ENDP	EQU	$
CODE	ENDS
	END
