;バイナリー数値をアスキー文字に変換

CODE	SEGMENT	'CODE'
	ASSUME	CS:CODE,DS:CODE,SS:CODE,ES:CODE

	DB	0FDH		;BSAVEの印
	DW	03000H		;セグメントアドレス　ダミー
	DW	0FFFH		;オフセットアドレス
	DW	ENDP-STARTP	;プログラムの長さ

STARTP	EQU	$		;F000番地より開始


;MAIN PROGRAM
MAIN	PROC	FAR


;ＢＣＣ　チェック
;ＴＸＴ＄すべての　ＸＯＲ　をとり　ＢＣ＄と比較
;ＣＡＬＬ（ＴＸＴ＄，ＢＣ＄，ＦＬＧ）
;ＦＬＧ　０：正常　１：エラー

	MOV	BP,SP
	MOV	BX,[BP+8]	;ＴＸＴ＄ ストリングディスクリプタ
	MOV	CL,[BX]		;ＴＸＴ＄の長さ
	MOV	SI,[BX+1]	;ＴＸＴ＄のアドレス
	XOR	DL,DL		;ＤＬ初期化

;ＴＸＴ＄のＸＯＲ繰り返し
LOOP2:
	MOV	AL,[SI]		;ＴＸＴ＄１バイト取得
	XOR	DL,AL
	INC	SI		;次のＴＸＴ＄にセット
	DEC	CL		;カウンターから１マイナス
	JNE	LOOP2		;０でなければループ

;ＸＯＲの結果とＢＣ＄比較
	MOV	BX,[BP+6]	;ＢＣ＄ ストリングディスクリプタ
	MOV	SI,[BX+1]	;ＢＣ＄のアドレス
	MOV	AL,[SI]		;ＢＣ＄の中身
	XOR	DH,DH		;ＦＬＧ初期化　(０セット)
	CMP	AL,DL		;ＢＣ＄とＸＯＲの結果を比較
	JE	OK		;正しい場合そのまま
	MOV	DH,1H		;正しくない場合　(１セット)
OK:
	MOV	BX,[BP+4]	;ＦＬＧのＦＡＣ
	MOV	[BX],DH
	XOR	DH,DH
	MOV	[BX+1],DH	;ＦＬＧセット

	RET	6



MAIN	ENDP
;MAIN END
ENDP	EQU	$
CODE	ENDS
	END
