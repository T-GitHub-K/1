;****************************************
;*					*
;*	RSIBM PROC	Ver 1.00	*
;*					*
;*	AH=座標Ｙ			*
;*	AL=座標Ｘ			*
;*	CH=機能コード			*
;*	CL=文字数			*
;*	SI=ソース文字列アドレス		*
;*					*
;*  	CALL (TEXT$,OP%,ST%)		*
;*					*
;*	機能ｺｰﾄﾞ(OP%)			*
;*	1･･COM1 OPEN  			*
;*	2･･文字列送出			*
;*	3･･文字列受信			*
;*					*
;****************************************

PORT_NO		EQU	0			;COM PORT NO
BPS		EQU	7			;9600 Bps
PA     		EQU	2			;EVEN
JIS        	EQU	3			;8 Bit
STP		EQU	0			;STOP Bit

L_ADD		EQU	0F100H			;BLOADｱﾄﾞﾚｽ  BASIC &HF100
OFSET		EQU	L_ADD-7			;OFFSET

PARA_OP	STRUC				;スタック受渡テーブル
	BP_SS	DW	?		;BPの退避
	R_ADD	DD	?		;RETURN	ADD
	ST_P	DW	?		;ST%	ADD
	OP_P	DW	?		;OP%	ADD
	TX_P	DW	?		;TEXT$	ADD
PARA_OP	ENDS

CODE	SEGMENT	
	ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE

	DB	0FDH		;BSAVEの印
	DW	0000H		;セグメントアドレス　ダミー
	DW	L_ADD		;オフセットアドレス
	DW	ENDP-STARTP	;プログラムの長さ

	PUBLIC	MAIN

STARTP	EQU	$
;MAIN PROGRAM
MAIN 	PROC	FAR

	PUSH	BP

SUB_ST:

	MOV	BP,SP
	PUSHA

	MOV	BX,[BP].ST_P		;ｽﾃｰﾀｽｱﾄﾞﾚｽ
	MOV	ST_ADD[OFSET],BX

	MOV	BX,[BP].OP_P		;ｵﾌﾟｼｮﾝ取得
	MOV	OP_ADD[OFSET],BX	;ｵﾌﾟｼｮﾝｱﾄﾞﾚｽ
	MOV	AX,[BX]
	MOV	OP_TION[OFSET],AL


	MOV	BX,[BP].TX_P		;ＴＥＸＴ＄ ストリングディスクリプタ
	MOV	CL,[BX]			;ＴＥＸＴ＄の長さ
	MOV	INTBL.IN_L[OFSET],CL	;文字列ﾚﾝｸﾞｽ
	MOV	SI,[BX+1]		;ＴＥＸＴ＄のアドレス
	MOV	TEXT_ADD[OFSET],SI	;


	CALL	INP_COL				;画面色設定
;	CALL	K_MODE				;ｷｰﾎﾞｰﾄﾞﾓｰﾄﾞ設定
	XOR	AX,AX				;AX初期化
	XOR	BX,BX				;BX初期化
	XOR	CX,CX				;CX初期化
	XOR	DX,DX				;DX初期化
;	CALL	FEP				;FEP起動設定  FEP_Sによる
	MOV	INS_FLG[OFSET],0		;ｲﾝｻｰﾄﾌﾗｸﾞ初期化
	CLD					;ﾃﾞｨﾚｸｼｮﾝFLG ﾘｾｯﾄ
	MOV	DI,OFFSET INTBL.IN_K[OFSET]	;漢字FLGﾃｰﾌﾞﾙｸﾘｱｰ
	MOV	CX,KANJ_TBL_LEN			;ﾃｰﾌﾞﾙﾚﾝｸﾞｽ
	REP	STOSW				;[DI]にALｾｯﾄ

	MOV	DI,OFFSET INTBL.IN_D[OFSET]	;文字列格納ｱﾄﾞﾚｽ
	MOV	BP,DI				;DIをBPに退避
	MOV	CL,INTBL.IN_L[OFSET]		;文字列ﾚﾝｸﾞｽ
;--------------------------------------------------------------------
;文字列ワークエリアにコピー

CP_CHR:
	MOV	AL,CS:[SI]			;SIの示す文字列ｺﾋﾟｰ
	OR	CL,CL				;IF CL=0 THEN GOTO CP_CHR2
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
	DEC	CX				;OBASIC CALL
	MOVSB					;[DI]に[SI]の内容ｺﾋﾟｰ
	JMP	SHORT CP_CHR
CP_CHR2:					;文字ﾚﾝｸﾞｽの示す所
	MOV	CL,INTBL.IN_L[OFSET]		;までSPCをｾｯﾄ
	SUB	CX,BX
	LEA	DI,INTBL.IN_D[BX][OFSET]
	MOV	AL,SPC
	REP	STOSB
CP_CHR3:					;文字ﾚﾝｸﾞｽの最後にNULｾｯﾄ
	MOV	BYTE PTR [DI],NUL
	MOV	DI,BP				;DI復帰
	CALL	INP_LOC				;表示LOCATEｾｯﾄ
	CALL	INP_CRT				;画面表示
	XOR	BX,BX
	PUSH	BX
	PUSH	ES				;INT 80H
	MOV	DL,1				;ｶｰｿﾙﾓｰﾄﾞ　表示に設定
	MOV	CL,2AH				;BIOS CALL
	INT	80H				;CL=2AH
	POP	ES				;BX,ES破壊
	POP	BX
;---------------------------------------------------------------------
;メインスタート 入力ロケート表示
	MOV	BX,QZ_ADD[OFSET]		;OBASIC CALL
	MOV	BYTE PTR [BX],AL		;入力ｺｰﾄﾞRETURN	

	MOV	DI,TEXT_ADD[OFSET]		;ＴＥＸＴ＄のアドレス
	MOV	SI,OFFSET INTBL.IN_D[OFSET]
	MOV	CL,INTBL.IN_L[OFSET]
	REP	MOVSB
	POPA
	POP	BP

	RET	18			;STACK	ﾌﾘｰ RETURN

MAIN	ENDP
ENDP	EQU	$
CODE	ENDS
	END
