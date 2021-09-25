;****************************************
;*					*
;*	INPUT PROC	Ver 2.01	*
;*					*
;*	AH=座標Ｙ			*
;*	AL=座標Ｘ			*
;*	CH=機能コード			*
;*	CL=文字数			*
;*	BL=FEP変換指定			*
;*	SI=ソース文字列アドレス		*
;*	LIB	UTY.LIB		登録	*
;*					*
;*	RET				*
;*	DI=ソース文字列アドレス		*
;*	AL=抜け出しコード		*
;*					*
;*	漢字コード	80H～ 9FH	*
;*			0E0H～0FFH	*
;*	ｶﾅコード	0A0H～0DFH	*
;*			   ｱ～ﾝ		*
;*	機能ｺｰﾄﾞ			*
;*	0･･なんでも有り			*
;*	1･･全角のみ	FEP起動		*
;*	2･･カナのみ１			*
;*	3･･カナのみ２(ﾊﾞｯｸｽﾍﾟｰｽ有) 	*
;*	4･･半角のみ			*
;*	5･･数字のみ１			*
;*	6･･数字のみ２(ﾊﾞｯｸｽﾍﾟｰｽ有) 	*
;*					*
;****************************************

;****************************************
;	MDOS.H	FUNCTION 21H		*
;	STD .H	ﾃﾞﾌｫﾙﾄ定義		*
;****************************************
INCLUDE	MDOS.H
INCLUDE	STD.H

KANJ_TBL_LEN	EQU	40			;漢字ﾃｰﾌﾞﾙﾚﾝｸﾞｽ
BAK_OP_FLG1	EQU	3			;ﾊﾞｯｸｽﾍﾟｰｽｵﾌﾟｼｮﾝｺｰﾄﾞ1
BAK_OP_FLG2	EQU	6			;ﾊﾞｯｸｽﾍﾟｰｽｵﾌﾟｼｮﾝｺｰﾄﾞ2
RIGHT_OP_FLG1	EQU	3			;RIGHT OFF ｵﾌﾟｼｮﾝｺｰﾄﾞ1
RIGHT_OP_FLG2	EQU	6			;RIGHT OFF ｵﾌﾟｼｮﾝｺｰﾄﾞ2
CU_TOP		EQU	14			;INS ｶｰｿﾙﾄｯﾌﾟ位置
CU_DOT		EQU	15			;INS ｶｰｿﾙﾄﾞｯﾄ数
CU_DEF_TOP	EQU	0			;ｶｰｿﾙﾄｯﾌﾟ位置 ﾃﾞﾌｫﾙﾄ
CU_DEF_DOT	EQU	29			;ｶｰｿﾙﾄﾞｯﾄ数   ﾃﾞﾌｫﾙﾄ
NOT_KEYC	EQU	20H			;入力キー制御コード
						;設定ｺｰﾄﾞ未満は受け付けない

CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE

;****************************************
; 外部参照　	LOCATE			*
; モジュール名	INPUT			*
;****************************************
EXTRN	LOCATE:NEAR
PUBLIC	INPUT

;--------------------------------------------------------------------
;初期設定

INPUT	PROC	NEAR

	MOV	WORD PTR DX_SAVE,DX		;DX退避
	MOV	BYTE PTR INTBL.IN_Y,AH		;ﾛｹｰﾄY
	MOV	BYTE PTR INTBL.IN_X,AL		;ﾛｹｰﾄX
	MOV	BYTE PTR INTBL.IN_L,CL		;文字列ﾚﾝｸﾞｽ
	MOV	BYTE PTR OP_FLG,BH		;機能ｺｰﾄﾞ
	MOV	BYTE PTR FEP_S,BL		;FEPｽｲｯﾁ
	CALL	K_MODE				;ｷｰﾎﾞｰﾄﾞﾓｰﾄﾞSAVE,LOAD
	CALL	FEP				;FEPの起動ﾁｪｯｸ
	XOR	AX,AX				;AX初期化
	XOR	BX,BX				;BX初期化
	XOR	CX,CX				;CX初期化
	MOV	BYTE PTR INS_FLG,0		;ｲﾝｻｰﾄﾌﾗｸﾞ初期化
	CLD					;ﾃﾞｨﾚｸｼｮﾝFLG ﾘｾｯﾄ
	MOV	DI,OFFSET INTBL.IN_K		;漢字FLGﾃｰﾌﾞﾙｸﾘｱｰ
	MOV	CX,KANJ_TBL_LEN			;ﾃｰﾌﾞﾙﾚﾝｸﾞｽ
	REP	STOSW				;[DI]にALｾｯﾄ

	MOV	DI,OFFSET INTBL.IN_D		;文字列格納ｱﾄﾞﾚｽ
	MOV	BP,DI				;DIをBPに退避
;--------------------------------------------------------------------
;文字列ワークエリアにコピー

CP_CHR:
	MOV	AL,[SI]				;SIの示す文字列ｺﾋﾟｰ
	CMP	AL,'$'				;$の前までコピー
	JZ	CP_CHR2
	CMP	INTBL.IN_K[BX],2		;漢字ｺｰﾄﾞ２ﾊﾞｲﾄ目ﾁｪｯｸ
	JZ	CP_CHR1
	CALL	KNJ_CHK				;漢字ｺｰﾄﾞﾁｪｯｸ
	CMP	KNJ_CHK_F,1			;漢字ｺｰﾄﾞ１ﾊﾞｲﾄ目ﾁｪｯｸ
	JNE	CP_CHR1
	MOV	INTBL.IN_K[BX],1		;漢字ﾃｰﾌﾞﾙｾｯﾄ
	MOV	INTBL.IN_K[BX+1],2		;漢字ﾃｰﾌﾞﾙｾｯﾄ
CP_CHR1:
	INC	BL				;文字数ｶｳﾝﾄ
	MOVSB					;[DI]に[SI]の内容ｺﾋﾟｰ
	JMP	CP_CHR
CP_CHR2:					;文字ﾚﾝｸﾞｽの示す所
	MOV	CL,INTBL.IN_L			;までSPCをｾｯﾄ
	SUB	CX,BX
	LEA	DI,INTBL.IN_D[BX]
	MOV	AL,SPC
	REP	STOSB
CP_CHR3:					;文字ﾚﾝｸﾞｽの最後に$ｾｯﾄ
	MOV	BYTE PTR [DI],'$'
	MOV	DI,BP				;DI復帰
	CALL	INP_LOC				;表示LOCATEｾｯﾄ
	CALL	INP_CRT				;画面表示
	XOR	BX,BX
;---------------------------------------------------------------------
;メインスタート 入力ロケート表示

INP_START:
	MOV	AH,INTBL.IN_Y			;ﾛｹｰﾄY
	MOV	AL,INTBL.IN_X			;ﾛｹｰﾄX	
	ADD	AL,BL				;ﾛｹｰﾄXに文字ﾎﾟｼﾞｼｮﾝﾌﾟﾗｽ
	CALL	LOCATE				;PROC NEAR
;--------------------------------------------------------------------------
;キー入力

 	MOV	BX_STK,BX			;BIOS CALL
	MOV	CL,18H				;一文字入力
	PUSH	ES				;AL=ｺｰﾄﾞ
	INT	80H				;INT 80H
	POP	ES				;AX,BX,ES破壊
	MOV	BX,BX_STK			;CL=18H
;--------------------------------------------------------------------------
;制御コードジャンプテーブルルーチン

	MOV	SI,OFFSET KEY_TBL-4		;ｷｰﾃｰﾌﾞﾙ OFFSET
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
	JZ	INP_START
LEFT1:
	DEC	BL				;ｶｰｿﾙ左に移動
	CMP	INTBL.IN_K[BX],2		;漢字ｺｰﾄﾞ2ﾊﾞｲﾄ目かﾁｪｯｸ
	JNE	LEFT2
	DEC	BL
LEFT2:
	CMP	OP_FLG,BAK_OP_FLG1		;ｵﾌﾟｼｮﾝ3,6ﾊﾞｯｸｽﾍﾟｰｽ処理
	JZ	BS2
	CMP	OP_FLG,BAK_OP_FLG2
	JZ	BS2
	JMP	INP_START

BS0:						;ＢＳ処理判定
	CMP	BL,0				;１番左端

	JZ	INP_START
BS1:
	DEC	BL				;ｶｰｿﾙ左に移動
	CMP	INTBL.IN_K[BX],2		;漢字ｺｰﾄﾞ2ﾊﾞｲﾄ目かﾁｪｯｸ
	JNE	BS2
	DEC	BL
BS2:
	CALL	DEL_1
	JMP	INP_START

RIGHT0:						;→の処理
	CMP	OP_FLG,RIGHT_OP_FLG1		;ｵﾌﾟｼｮﾝ3,6右移動ｽﾄｯﾌﾟ
	JZ	RIGHT3
	CMP	OP_FLG,RIGHT_OP_FLG2
	JZ	RIGHT3
	INC	BL
	CMP	INTBL.IN_K[BX],2		;漢字ｺｰﾄﾞ2ﾊﾞｲﾄ目かﾁｪｯｸ
	JZ	RIGHT1
	CMP	BL,INTBL.IN_L
	JNE	RIGHT3
	DEC	BL
	JMP	INP_START
RIGHT1:
	MOV	DL,INTBL.IN_L
	DEC	DL
	CMP	BL,DL				;漢字の2ﾊﾞｲﾄが最後
	JNE	RIGHT2
	SUB	BL,2
RIGHT2:
	INC	BL
RIGHT3:
	JMP	INP_START

UP0:
	JMP	INP_END
DOWN0:
	JMP	INP_END

INS0:						;INSの処理
	CMP	INS_FLG,0			;FLG=0 ｲﾝｻｰﾄﾓｰﾄﾞ設定
	JZ	INS1				;FLG=1 ｲﾝｻｰﾄﾓｰﾄﾞ解除
	MOV	INS_FLG,0
	MOV	DL,1
	MOV	AL,CU_DEF_DOT			;ﾃﾞﾌｫﾙﾄのﾄﾞｯﾄ数
	MOV	AH,CU_DEF_TOP			;ﾃﾞﾌｫﾙﾄのﾄｯﾌﾟ位置
	JMP	INS2
INS1:
	MOV	INS_FLG,1			;ｲﾝｻｰﾄﾓｰﾄﾞ設定
	MOV	DL,1
	MOV	AL,CU_DOT			;ｶｰｿﾙﾄﾞｯﾄ数
	MOV	AH,CU_TOP			;ｶｰｿﾙﾄｯﾌﾟ位置
INS2:
;----------------------------------------------------------------------
	MOV	CL,2BH				;BIOS CALL
	MOV	BX_STK,BX			;ｶｰｿﾙ形状設定
	PUSH	ES				;INT 80H
	INT	80H				;CL=2BH
	POP	ES				;AL=ｶｰｿﾙﾄﾞｯﾄ数
	MOV	BX,BX_STK			;AH=ｶｰｿﾙ表示ﾄｯﾌﾟ
	JMP	INP_START			;ES,AX,BX破壊
;----------------------------------------------------------------------
DEL0:						;DELの処理
	CALL	DEL_1
	JMP	INP_START
;----------------------------------------------------------------------
;文字入力処理

INP_0:
        CMP	AL,CR				;CRを入力したら終了
	JNE	INP_01
	JMP	INP_END
INP_01:
	CMP	AL,NOT_KEYC			;CHAR ｺｰﾄﾞが20H未満
	JAE	INP_02
	JMP	INP_START
INP_02:
	CALL	OP_CHK				;ｵﾌﾟｼｮﾝﾁｪｯｸ
	CMP	NG,0				;入力制限FLG NG=1 入力拒否
	JZ	INP_1
	CALL	BEEP1
	JMP	INP_START
INP_1:
	CALL	KNJ_CHK				;漢字ｺｰﾄﾞﾁｪｯｸ
	CMP	KNJ_CHK_F,1;
	JNE	INP_4				;漢字ｺｰﾄﾞじゃない場合は、INP_4
	CMP	INTBL.IN_D[BX+1],'$'		;へｼﾞｬﾝﾌﾟ
	JNE	INP_2				;漢字ｺｰﾄﾞで2ﾊﾞｲﾄ目が入らない
						;場合は、BEFFER ｸﾘｱｰする
 	MOV	BX_STK,BX			;BIOS CALL
	MOV	CL,18H				;INT 80H
	PUSH	ES				;CL=18H
	INT	80H				;AL=ｺｰﾄﾞ
	POP	ES				;ES,AX,BX破壊
	MOV	BX,BX_STK			;入力BUFFER ｸﾘｱｰ
	JMP	INP_START
INP_2:
	CMP	INS_FLG,1			;ｲﾝｻｰﾄﾓｰﾄﾞかﾁｪｯｸ
	JNE	INP_3
	CALL	INS_1				;ｲﾝｻｰﾄﾙｰﾁﾝｺｰﾙ
INP_3:
	MOV	INTBL.IN_D[BX],AL		;漢字ｺｰﾄﾞ入力処理
	MOV	INTBL.IN_K[BX],1		;1ﾊﾞｲﾄ目ｾｯﾄ処理
 	MOV	BX_STK,BX			;BIOS CALL
	MOV	CL,18H				;INT 80H
	PUSH	ES				;CL=18H
	INT	80H				;AL=ｺｰﾄﾞ
	POP	ES				;ES,AX,BX破壊
	MOV	BX,BX_STK			;入力BEFFER 2ﾊﾞｲﾄ目取得
	MOV	INTBL.IN_D[BX+1],AL		;2ﾊﾞｲﾄ目ｾｯﾄ処理
	MOV	INTBL.IN_K[BX+1],2
	CMP	INTBL.IN_D[BX+2],'$'		;入力後次のｶｰｿﾙﾎﾟｼﾞｼｮﾝﾁｪｯｸ
	JZ	INP_6				;入力ﾎﾟｼﾞｼｮﾝがﾚﾝｸﾞｽの最後
	ADD	BL,2				;だったらINP_6 へｼﾞｬﾝﾌﾟ
	JMP	INP_6				;NOT だったらﾎﾟｼﾞｼｮﾝ設定
INP_4:
	CMP	INS_FLG,1			;半角処理ﾙｰﾁﾝ
	JNE	INP_5				;ｲﾝｻｰﾄﾓｰﾄﾞﾁｪｯｸ
	CALL	INS_1				;ｲﾝｻｰﾄﾙｰﾁﾝｺｰﾙ
INP_5:
	MOV	INTBL.IN_D[BX],AL		;ｺｰﾄﾞｾｯﾄ
	MOV	INTBL.IN_K[BX],0		;漢字FLGｸﾘｱｰ
	CMP	INTBL.IN_D[BX+1],'$'		;次のｶｰｿﾙﾎﾟｼﾞｼｮﾝﾁｪｯｸ
	JZ	INP_6				;入力ﾎﾟｼﾞｼｮﾝがﾚﾝｸﾞｽの最後
						;だったら INP_6 へｼﾞｬﾝﾌﾟ
	INC	BL				; NOT だったらﾎﾟｼﾞｼｮﾝ設定
INP_6:
	CMP	INS_FLG,1			;次のﾎﾟｼﾞｼｮﾝの処理判定処理
	JZ	INP_7
	CMP	INTBL.IN_K[BX],2		;次のﾎﾟｼﾞｼｮﾝが漢字の2ﾊﾞｲﾄ目
	JNE	INP_7				;だった場合は漢字ﾃｰﾌﾞﾙをｸﾘｱｰ
	MOV	INTBL.IN_K[BX],0		;文字列SPCｾｯﾄ
	MOV	INTBL.IN_D[BX],SPC
INP_7:
	CALL	INP_LOC				;表示LOCATEｾｯﾄ
	CALL	INP_CRT				;画面表示
	JMP	INP_START			;入力メインへ
;------------------------------------------------------------------------
;入力終了

INP_END:
	MOV	BYTE PTR QZ,AL			;抜け出しコード
	MOV	DL,1				;BIOS CALL
	MOV	AL,CU_DEF_DOT			;INT 80H
	MOV	AH,CU_DEF_TOP			;ｶｰｿﾙ形状を元に戻す
	MOV	CL,2BH				;CL=2BH
	PUSH	ES				;ES,AX,BX破壊
	INT	80H
;-------------------------------------------------------------------------
	MOV	CL,69H				;BIOS CALL
	MOV	AH,1				;INT 80H
	MOV	DX,KM_6	         		;CL=69H	
	INT	80H				;ｷｰﾓｰﾄﾞ初期値に戻す
;-------------------------------------------------------------------------
	MOV	CL,0BH				;BIOS CALL
	MOV	BL,0				;INT 83H
	INT	83H				;CL=0BH
	POP	ES				;FEP 終了
	MOV	DX,DX_SAVE
	MOV	DI,OFFSET INTBL.IN_D
	MOV	AL,BYTE PTR QZ

	RET					;INPUT ﾙｰﾁﾝ終了
;-------------------------------------------------------------------------
;************************
;*	ｻﾌﾞﾙｰﾁﾝ		*
;************************

INP_LOC	PROC	NEAR				;初期LOCATE 	ﾙｰﾁﾝ
	MOV	AH,INTBL.IN_Y
	MOV	AL,INTBL.IN_X
	CALL	LOCATE
	RET
INP_LOC	ENDP

INP_CRT	PROC	NEAR				;画面表示	ﾙｰﾁﾝ
	MOV	BX_STK,BX
	MOV	CL,0D7H				;BIOS CALL
	MOV	DX,OFFSET INTBL.IN_D		;INT 80H
	PUSH	ES				;CL=0D7H
	INT	80H				;'$'まで表示
	POP	ES
	MOV	BX,BX_STK
	RET
INP_CRT	ENDP

BEEP1	PROC	NEAR				;ﾋﾞｰﾌﾟ音発生	ﾙｰﾁﾝ
	DISPLAY_CHAR	BEEP			;FUNCTION 02H
	RET					;MDOS.H
BEEP1	ENDP

INS_1	PROC	NEAR				;INS処理	ﾙｰﾁﾝ
	MOV	INP_COUNT,BL			;入力ﾎﾟｼﾞｼｮﾝ退避
	MOV	CL,INTBL.IN_L			;文字列ﾚﾝｸﾞｽ取得
	SUB	CL,BL				;ﾚﾝｸﾞｽと入力数の差
	MOV	CL_STK,CL			;ｽﾄｯｸ
	MOV	BL,INTBL.IN_L			;後ろから移動
	LEA	DI,INTBL.IN_K[BX-1]		;移動先のｱﾄﾞﾚｽ取得
	MOV	DI_STK,DI			;ｽﾄｯｸ(漢字ﾃｰﾌﾞﾙ)
	LEA	DI,INTBL.IN_D[BX-1]		;移動先のｱﾄﾞﾚｽ取得
	CMP	KNJ_CHK_F,1			;漢字ｺｰﾄﾞかﾁｪｯｸ
	JNE	INS_2				;漢字じゃない時の飛び先
	DEC	BL				;
	DEC	CL
	MOV	CL_STK,CL
INS_2:
	LEA	SI,INTBL.IN_K[BX-2]		;移動元のｱﾄﾞﾚｽ取得
	MOV	SI_STK,SI			;ｽﾄｯｸ(漢字ﾃｰﾌﾞﾙ)
	LEA	SI,INTBL.IN_D[BX-2]		;移動元のｱﾄﾞﾚｽ取得
	STD					;ﾃﾞｨﾚｸｼｮﾝ FLG ｾｯﾄ
	REP	MOVSB				;[SI]ｶﾗ[DI]ｺﾋﾟｰ
	MOV	DI,DI_STK			;CX回実行
	MOV	SI,SI_STK
	MOV	CL,CL_STK
	REP	MOVSB
	MOV	BL,INTBL.IN_L
	CMP	INTBL.IN_K[BX-1],1
	JNE	INS_3
	MOV	INTBL.IN_D[BX-1],SPC
	MOV	INTBL.IN_K[BX-1],0
INS_3:
	MOV	BL,INP_COUNT
	MOV	DI,BP
	CLD
	RET
INS_1	ENDP

DEL_1	PROC	NEAR				;DEL処理	ﾙｰﾁﾝ
	MOV	DEL_SPC,0
	MOV	INP_COUNT,BL
	MOV	CL,INTBL.IN_L
	SUB	CL,BL
	MOV	CL_STK,CL
	LEA	DI,INTBL.IN_K[BX]
	MOV	DI_STK,DI
	LEA	DI,INTBL.IN_D[BX]
	CMP	INTBL.IN_K[BX],1
	JNE	DEL_2
	DEC	CL
	MOV	CL_STK,CL
	INC	BL
	MOV	DEL_SPC,1
	CMP	INTBL.IN_D[BX-1],'$'
	JZ	DEL_3
DEL_2:
	LEA	SI,INTBL.IN_K[BX+1]
	MOV	SI_STK,SI
	LEA	SI,INTBL.IN_D[BX+1]
	REP	MOVSB
	MOV	SI,SI_STK
	MOV	DI,DI_STK
	MOV	CL,CL_STK
	REP	MOVSB
DEL_3:
	MOV	BL,INTBL.IN_L
	MOV	INTBL.IN_D[BX-1],SPC
	MOV	INTBL.IN_K[BX-1],0
	CMP	DEL_SPC,0
	JZ	DEL_4
	MOV	INTBL.IN_D[BX-2],SPC
	MOV	INTBL.IN_K[BX-2],0
DEL_4:
	CALL	INP_LOC
	CALL	INP_CRT
	MOV	BL,INP_COUNT
	RET
DEL_1	ENDP

OP_CHK	PROC	NEAR				;オプション	ﾙｰﾁﾝ
	MOV	NG,0
	CALL	KNJ_CHK
	MOV	AL_STK,AL

	MOV	SI,OFFSET OP_TBL-4		;ｵﾌﾟｼｮﾝﾃｰﾌﾞﾙ OFFSET
OP_C:	ADD	SI,4				;
	CMP	BYTE PTR [SI],0FFH		;ｷｰﾃｰﾌﾞﾙ最後
	JZ	OP_EXIT
	MOV	AL,OP_FLG
	CMP	AL,[SI]				;ｷｰｺｰﾄﾞ比較
	MOV	AL,AL_STK
	JNZ	OP_C
	JMP	[SI+2]				;ﾃｰﾌﾞﾙｼﾞｬﾝﾌﾟ

OP_6:
OP_5:						;ｵﾌﾟｼｮﾝ6 数字のみ
	CMP	KNJ_CHK_F,1			;ｵﾌﾟｼｮﾝ5 数字のみ
	JZ	OP_CHK_NG			;ｺｰﾄﾞが漢字ｺｰﾄﾞ
	CMP	AL,30H				;ｺｰﾄﾞが"1"より小さい
	JB	OP_CHK_NG
	CMP	AL,39H				;ｺｰﾄﾞが"9"より大きい
	JA	OP_CHK_NG
	JMP	OP_EXIT

OP_4:						;ｵﾌﾟｼｮﾝ4 半角のみ
	CMP	KNJ_CHK_F,1			;ｺｰﾄﾞが漢字ｺｰﾄﾞ
	JZ	OP_CHK_NG
	JMP	OP_EXIT

OP_3:						;ｵﾌﾟｼｮﾝ3 ｶﾅのみ
OP_2:						;ｵﾌﾟｼｮﾝ2 ｶﾅのみ
	CMP	KNJ_CHK_F,1			;ｺｰﾄﾞが漢字ｺｰﾄﾞ
	JZ	OP_CHK_NG
	CMP	AL,0A0H				;ｺｰﾄﾞが "ｱ"より小さい
	JB	OP_CHK_NG
	CMP	AL,0DFH				;ｺｰﾄﾞが "ﾝ"より大きい
	JA	OP_CHK_NG
	JMP	OP_EXIT

OP_1:						;ｵﾌﾟｼｮﾝ1 全角のみ
	CMP	KNJ_CHK_F,1			;ｺｰﾄﾞが漢字ｺｰﾄﾞ
	JZ	OP_EXIT

OP_CHK_NG:
 	CMP	KNJ_CHK_F,1			;ｵﾌﾟｼｮﾝの指定が漢字を受け付け
						;ないﾓｰﾄﾞだったらｷｰﾊﾞｯﾌｧｸﾘｱｰ
	JNE	OP_CHK_NG1
	MOV	BX_STK,BX			;BIOS CALL
	MOV	CL,18H				;INT 80H
	PUSH	ES				;CL=18H
	INT	80H				;一ﾊﾞｲﾄ入力
	POP	ES				;BX,ES破壊
	MOV	BX,BX_STK
OP_CHK_NG1:
	MOV	NG,1
OP_EXIT:
	RET
OP_CHK	ENDP

KNJ_CHK	PROC	NEAR				;漢字ｺｰﾄﾞﾁｪｯｸ	ﾙｰﾁﾝ
	MOV	KNJ_CHK_F,0
	CMP	AL,80H
	JB	KNJ_EXIT
	CMP	AL,9FH
	JA	KNJ_CHK2
	MOV	KNJ_CHK_F,1
	JMP	KNJ_EXIT
KNJ_CHK2:
	CMP	AL,0E0H
	JB	KNJ_EXIT
	CMP	AL,0FFH
	JA	KNJ_EXIT
	MOV	KNJ_CHK_F,1
KNJ_EXIT:
	RET
KNJ_CHK	ENDP

K_MODE	PROC	NEAR				;ｷｰﾓｰﾄﾞ		ﾙｰﾁﾝ
	MOV	BX_STK,BX
	MOV	AH,0
	MOV	CL,69H
	PUSH	ES
	INT	80H
	MOV	K_STK,AX
	CMP	OP_FLG,0
	JZ	K_EXIT
	CMP	OP_FLG,4
	JB	_M1
	MOV	DX,KM_4
	JMP	K_SET
_M1:	CMP	OP_FLG,1
	JZ	_M2
	MOV	DX,KM_2
	JMP	K_SET
_M2:	MOV	DX,KM_1
K_SET:	MOV	AH,1
	MOV	CL,69H
	INT	80H
K_EXIT:	POP	ES
	MOV	BX,BX_STK
	RET
K_MODE	ENDP

FEP	PROC	NEAR				;FEP		ﾙｰﾁﾝ
	MOV	CL,0EH				;FEP起動,解除設定
	INT	83H
	MOV	FEP_D,AL			;初期ﾓｰﾄﾞ退避
	CMP	FEP_S,1				;FEPｽｲｯﾁ
	JNE	FEP_EXIT
	MOV	CL,0BH
	MOV	BL,1
	INT	83H
FEP_EXIT:
	RET
FEP	ENDP

INP_STR	STRUC
	IN_Y	DB	0			;入力ﾛｹｰﾄY
	IN_X	DB	0			;入力ﾛｹｰﾄX
	IN_L	DB	0			;入力数
	IN_D	DB	80	DUP(0)		;ﾃﾞｰﾀ格納領域
	IN_K	DB	80	DUP(0)		;漢字ｺｰﾄﾞFLG
INP_STR	ENDS
INTBL	INP_STR	<,,,,>				;初期化

DX_SAVE		DW	0			;DX退避領域
INP_COUNT	DB	0			;入力文字数退避領域
AL_STK		DB	0			;AL退避領域
BX_STK		DW	0			;BX退避領域
CL_STK		DB	0			;CL退避領域
SI_STK		DW	0			;SI退避領域
DI_STK		DW	0			;DI退避領域
INS_FLG		DB	0			;ｲﾝｻｰﾄﾓｰﾄﾞFLG
KNJ_CHK_F	DB	0			;漢字入力ﾁｪｯｸFLG
DEL_SPC		DB	0			;ﾃﾞｰﾘｰﾄﾙｰﾁﾝ ﾜｰｸFLG
OP_FLG		DB	0			;機能ｺｰﾄﾞ
NG		DB	0			;入力制限ﾁｪｯｸFLG
K_STK		DW	0			;ｷｰﾓｰﾄﾞ退避領域
FEP_D		DB	0			;FEPﾓｰﾄﾞ退避領域
FEP_S		DB	0			;FEPﾓｰﾄﾞｽｲｯﾁ
QZ		DB	0			;抜け出しコード
KM_1		DW	0A400H			;全角
KM_2		DW	1400H			;ｶﾀｶﾅ
KM_3		DW	1400H			;ｶﾀｶﾅ
KM_4		DW	8400H			;ﾛｯｸ
KM_5		DW	8400H			;ﾛｯｸ
KM_6		DW	8400H			;ﾛｯｸ
;
;		ｼﾞｬﾝﾌﾟﾃｰﾌﾞﾙ
;			ｺｰﾄﾞ　JMP先
KEY_TBL		DW	0008H,LEFT0		;BS,←
		DW	000CH,RIGHT0		;→
		DW	0012H,INS0		;ｲﾝｻｰﾄ 	INS
		DW	007FH,DEL0		;ﾃﾞﾘｰﾄ	DEL
		DW	000BH,UP0		;上
		DW	000AH,DOWN0		;下
		DB	0FFH   			;EXIT

;
;		ｼﾞｬﾝﾌﾟﾃｰﾌﾞﾙ
;			ｺｰﾄﾞ　JMP先
OP_TBL		DW	0001H,OP_1		;ｵﾌﾟｼｮﾝ1
		DW	0002H,OP_2		;ｵﾌﾟｼｮﾝ2
		DW	0003H,OP_3		;ｵﾌﾟｼｮﾝ3
		DW	0004H,OP_4		;ｵﾌﾟｼｮﾝ4
		DW	0005H,OP_5		;ｵﾌﾟｼｮﾝ5
		DW	0006H,OP_6		;ｵﾌﾟｼｮﾝ6
		DB	0FFH   			;EXIT

INPUT	ENDP
CODE	ENDS
	END

