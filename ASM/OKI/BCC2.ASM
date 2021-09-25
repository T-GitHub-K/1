;********************************************
;ＢＣＣ　チェック
;ＴＸＴ＄すべての　ＸＯＲ　をとり　ＢＣ＄と比較
;ＣＡＬＬ（ＴＸＴ＄，ＢＣ＄，ＦＬＧ）
;ＦＬＧ　０：正常　１：エラー
;********************************************
DBG	EQU	0			;直接実行
;
CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE
START:
;
IF	DBG
;********************************************
;ｂａｓｉｃ９８から渡される引き数テーブル作成
;********************************************
	PUSH	CS
	POP	DS
	MOV	AX,DS
	MOV	SI,OFFSET ADDTBL
	MOV	WORD PTR [SI+00H],OFFSET FFF
	MOV	WORD PTR [SI+02H],AX
	MOV	WORD PTR [SI+04H],OFFSET BADD
	MOV	WORD PTR [SI+06H],AX
	MOV	WORD PTR [SI+08H],OFFSET TADD
	MOV	WORD PTR [SI+0AH],AX
	MOV	SI,OFFSET BADD
	MOV	WORD PTR [SI+02H],OFFSET BBB
	MOV	SI,OFFSET TADD
	MOV	WORD PTR [SI+02H],OFFSET TTT
	MOV	BX,OFFSET ADDTBL
	MOV	DX,DS
JMP	NXT
	;********************************************
	;テスト用データ
	;********************************************
ADDTBL	DB	 12 DUP(?)
TTT	DB	02H,05H,02H
TADD	DB	03H,00H,00H,00H
BBB	DB	05H
BADD	DB	01H,00H,00H,00H
FFF	DW	00H
NXT:
ENDIF
;
	;*******************************************
	;各レジスタ退避
	;*******************************************
	IRP	DUM,<AX,BX,CX,DX,SI,DI,DS,ES>
		PUSH	DUM
	ENDM
	;*******************************************
	;引き数テーブル用セグメントオフセット
	;*******************************************
	PUSH	SS
	PUSH	DX
	PUSH	DS
	PUSH	BX
	PUSH	CS			;DS=CS
	POP	DS
	POP	AX			;引き数テーブルBXセット
	MOV	SAV_BX,AX
	POP	AX			;引き数テーブルDSセット
	MOV	SAV_DS,AX
	POP	AX			;DX退避(文字のセグメント用)
	MOV	SAV_DX,AX
	POP	AX			;リロケーションコード０以外
	MOV	SAV_SS,AX
	;********************************************
	;テーブルセグメントオフセット
	;********************************************
	MOV	BX,SAV_BX
	MOV	AX,SAV_DS
	MOV	ES,AX
	MOV	AX,WORD PTR ES:[BX+0AH]	;セグメント
	MOV	SI,WORD PTR ES:[BX+08H]	;オフセット
	MOV	ES,AX
	;********************************************
	;ストリングディスクリプタのデータ解析
	;********************************************
	MOV	AH,BYTE PTR ES:[SI]	;桁数
	INC	SI
	MOV	AL,BYTE PTR ES:[SI]	;文字のリロケーションコード
	INC	SI
	MOV	BX,WORD PTR ES:[SI]	;文字のオフセットアドレス
	MOV	SI,BX			;文字転送用アドレス
	;********************************************
	;リロケーションコードによって文字のセグメントセット
	;********************************************
	MOV	DX,SAV_DX		;テーブルセグメント
	MOV	BX,SAV_SS		;文字のセグメント(テキストセグメント内)
	MOV	ES,DX			;
	CMP	AL,00H
	JE	BCC_CHK
	MOV	ES,BX			;
BCC_CHK:
	;********************************************
	;ＸＯＲ初期化
	;********************************************
	XOR	DX,DX
	;********************************************
	;桁数カウンターセット
	;********************************************
	XOR	CX,CX
	MOV	CL,AH
	CLD
REP:
	MOV	DL,BYTE PTR ES:[SI]
	XOR	DH,DL
	INC	SI
	LOOP	REP
;
	PUSH	DX			;ＸＯＲの結果退避(DH)
;
	;********************************************
	;テーブルセグメントオフセット
	;********************************************
	MOV	BX,SAV_BX
	MOV	AX,SAV_DS
	MOV	ES,AX
	MOV	AX,WORD PTR ES:[BX+06H]	;セグメント
	MOV	SI,WORD PTR ES:[BX+04H]	;オフセット
	MOV	ES,AX
	;********************************************
	;ストリングディスクリプタのデータ解析
	;********************************************
	MOV	AH,BYTE PTR ES:[SI]	;桁数
	INC	SI
	MOV	AL,BYTE PTR ES:[SI]	;文字のリロケーションコード
	INC	SI
	MOV	BX,WORD PTR ES:[SI]	;文字のオフセットアドレス
	MOV	SI,BX			;文字転送用アドレス
	;********************************************
	;リロケーションコードによって文字のセグメントセット
	;********************************************
	MOV	DX,SAV_DX		;テーブルセグメント
	MOV	BX,SAV_SS		;文字のセグメント(テキストセグメント内)
	MOV	ES,DX			;
	CMP	AL,00H
	JE	BCC_CHK2
	MOV	ES,BX			;
BCC_CHK2:
	;********************************************
	;ＴＸＴとＢＣＣ比較
	;********************************************
;
	POP	DX
;
	MOV	DL,BYTE PTR ES:[SI]	;ＢＣＣの中身
	MOV	BYTE PTR ES:[SI],DH	;ＴＸＴのＸＯＲ結果をＢＣＣにセット
	CMP	DH,DL
	JE	PRO_END
	;********************************************
	;テーブルのさすアドレスにセット
	;********************************************
	MOV	BX,SAV_BX
	MOV	AX,SAV_DS
	MOV	ES,AX
	MOV	AX,WORD PTR ES:[BX+02H]	;セグメント
	MOV	SI,WORD PTR ES:[BX+00H]	;オフセット
	MOV	ES,AX
	MOV	WORD PTR ES:[SI],01H	;数値
PRO_END:
	;********************************************
	;退避データ元に戻す
	;********************************************
	IRP	DUM,<ES,DS,DI,SI,DX,CX,BX,AX>	;各レジスタ
	POP	DUM
	ENDM
	;********************************************
	;プログラムエンド
	;********************************************
IF	DBG
	MOV	AH,4CH
	INT	21H
ENDIF
	IRET
;
;********************************************
;レジスタ退避用データ
;********************************************
SAV_BX	DW	  1 DUP(?)
SAV_DS	DW	  1 DUP(?)
SAV_DX	DW	  1 DUP(?)
SAV_SS	DW	  1 DUP(?)
;********************************************
;
;********************************************
CODE	ENDS
	END	START
