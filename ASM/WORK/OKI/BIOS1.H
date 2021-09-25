.XLIST
IF1
%OUT BIOS.H_START
ENDIF
;********************************
;* 	BIOS CALL		*
;*				*
;********************************
;
;	漢字変換 	有効/無効 モード	SWITCH=0 無効  SWITCH=1 有効
;
FEP_SWITCH	MACRO	SWITCH
		MOV	AL,SWITCH
		MOV	BL,25H
		INT	83H
		ENDM
;
;	キーボード入力 	有効/無効 モード	SWITCH=0 無効	SWITCH=1 有効
;
KBD_SWITCH	MACRO	SWITCH
		MOV	DL,SWITCH
		MOV	CL,1AH
		INT	80H
		ENDM
;
;	キーボード	参照 	  モード
;	
KBD_MODE	MACRO
		MOV	AH,0
		MOV	CL,69H
		INT	80H
		ENDM
;
;	キーボード	設定 	  モード
;	
KBD_MODE_S	MACRO	PARMS
		MOV	AH,1
		MOV	DX,PARMS
		MOV	CL,69H
		INT	80H
		ENDM

;
;	ＢＩＯＳ ＣＡＬＬ　ＭＡＣＲＯ　定義
;
;	破壊	AX,BX,ES
;
;
;


;	機能コード1
;
;	割り込み処理ルーチン  LEVEL 1  	登録,解除
;
;	入力	CL=01H
;		ES:DX=ECBｱﾄﾞﾚｽ
;
;	出力	なし
;
BIOS_1		MACRO	ECB
		MOV	CL,01H
		MOV	DX,OFFSET ECB
		INT	80H
		ENDM


;	機能コード2
;
;	割り込み処理ルーチン  LEVEL 2  	登録,解除
;
;	入力	CL=02H
;		ES:DX=ECBｱﾄﾞﾚｽ
;
;	出力	なし
;
BIOS_2		MACRO	ECB
		MOV	CL,02H
		MOV	DX,OFFSET ECB
		INT	80H
		ENDM


;	機能コード1
;
;	割り込み処理ルーチン  LEVEL 3  	登録,解除
;
;	入力	CL=03H
;		ES:DX=ECBｱﾄﾞﾚｽ
;
;	出力	なし
;
BIOS_3		MACRO	ECB
		MOV	CL,03H
		MOV	DX,OFFSET ECB
		INT	80H
		ENDM


;	機能コード5
;
;	割り込み処理ルーチン  LEVEL 5  	登録,解除
;
;	入力	CL=05H
;		ES:DX=ECBｱﾄﾞﾚｽ
;
;	出力	なし
;
BIOS_5		MACRO	ECB
		MOV	CL,05H
		MOV	DX,OFFSET ECB
		INT	80H
		ENDM


;	機能コード6
;
;	割り込み処理ルーチン  LEVEL 6  	登録,解除
;
;	入力	CL=06H
;		ES:DX=ECBｱﾄﾞﾚｽ
;
;	出力	なし
;
BIOS_6		MACRO	ECB
		MOV	CL,06H
		MOV	DX,OFFSET ECB
		INT	80H
		ENDM


;	機能コード8
;
;	タイマ割り込み処理ルーチン  LEVEL 3  	登録,解除
;
;	入力	CL=08H
;		ES:DX=TECBｱﾄﾞﾚｽ
;		AL=登録番号	(3-9)
;
;	出力	なし
;
BIOS_8		MACRO	TECB
		MOV	CL,08H
		MOV	DX,OFFSET TECB
		INT	80H
		ENDM


;	機能コード9
;
;	タイマ割り込み処理ルーチン  LEVEL 4  	登録,解除
;
;	入力	CL=09H
;		ES:DX=TECBｱﾄﾞﾚｽ
;		AL=登録番号	(3-9)
;
;	出力	なし
;
BIOS_9		MACRO	TECB
		MOV	CL,09H
		MOV	DX,OFFSET TECB
		INT	80H
		ENDM


;	機能コード16
;
;	ＩＯＢＹＴＥの設定
;
;	入力	CL=10H
;		DL=IOBYTE
;
;	出力	なし
;
BIOS_16		MACRO	IOBYTE
		MOV	CL,10H
		MOV	DL,IOBYTE
		INT	80H
		ENDM


;	機能コード17
;
;	ＩＯＢＹＴＥの参照
;
;	入力	CL=11H
;
;	出力	AL=IOBYTE
;
BIOS_17		MACRO	IOBYTE
		MOV	CL,11H
		INT	80H
		ENDM


;	機能コード24
;
;	ｷｰﾎﾞｰﾄﾞ･ﾊﾞｯﾌｧからの１文字読み込み
;
;	入力	CL=18H
;
;	出力	AL=ASCIIｺｰﾄﾞ
;
BIOS_18		MACRO
		PUSH	ES
		MOV	CL,18H
		INT	80H
		POP	ES
		ENDM


;	機能コード25
;
;	ｷｰﾎﾞｰﾄﾞ･ﾊﾞｯﾌｧの状態参照
;
;	入力	CL=19H
;
;	出力	AL=ﾊﾞｯﾌｧ状態
;			0:ﾊﾞｯﾌｧ空
;			 :AH=先頭文字	ﾊﾞｯﾌｧの状態は変化しない
;
BIOS_19		MACRO
		MOV	CL,19H
		INT	80H
		ENDM


;	機能コード26
;
;	ｷｰﾎﾞｰﾄﾞ入力の有効,無効
;
;	入力	CL=1AH
;		DL=ﾓｰﾄﾞ
;			0:ｷｰ入力無効
;			1:ｷｰ入力有効
;	出力	なし
;
BIOS_26		MACRO	PARA
		MOV	CL,1AH
		MOV	DL,PARA
		INT	80H
		ENDM


;	機能コード27
;
;	ｷｰﾎﾞｰﾄﾞ入力文字の再割当
;
;	入力	CL=1BH
;		DL=現在の入力文字コード
;		DH=新入力文字コード
;
;	出力	なし
;
BIOS_27		MACRO	NEW,OLD
		MOV	CL,1BH
		MOV	DL,OLD
		MOV	DH,NEW
		INT	80H
		ENDM


;	機能コード28
;
;	ﾌｧﾝｸｼｮﾝｷｰ/ｸﾞﾗﾌｼﾌﾄｷｰの文字列割当と参照
;
;	入力	CL=1CH
;		ES:DX=ｽﾄﾘﾝﾝｸﾞｱﾄﾞﾚｽ
;		AL=機能FLG
;			0:交換
;			1:参照
;			2:設定
;	出力	なし
;
BIOS_28		MACRO	STRING,PARA
		MOV	CL,1CH
		MOV	DX,OFFSET STRING
		MOV	AL,PARA
		INT	80H
		ENDM


;	機能コード29
;
;	ｷｰﾎﾞｰﾄﾞﾊﾞｯﾌｧのｸﾘｱｰ
;
;	入力	CL=1DH
;
;	出力	なし
;
BIOS_29		MACRO
		MOV	CL,1DH
		INT	80H
		ENDM


;	機能コード30
;
;	CTRL+F8,CTRL+F9の状態初期化
;
;	入力	CL=1EH
;		DL=0
;		
;	出力	なし
;
BIOS_30		MACRO
		MOV	CL,1EH
		MOV	DL,0
		INT	80H
		ENDM


;	機能コード31
;
;	CTRL+F8,CTRL+F9の状態参照
;
;	入力	CL=1FH
;
;	出力	AL=状態
;			0:なし
;			1:CTRL+F9
;			2:CTRL+F8
;			3:両方
;
BIOS_31		MACRO
		MOV	CL,1FH
		INT	80H
		ENDM


;	機能コード32
;
;	ﾌｧﾝｸｼｮﾝｷｰ用トラップ情報の参照
;
;	入力	CL=20H
;
;	出力	ES:BX=トラップ情報エリアアドレス
;
BIOS_32		MACRO
		MOV	CL,20H
		INT	80H
		ENDM


;	機能コード33
;
;	ｷｰﾎﾞｰﾄﾞｷｭｳへの文字登録
;
;	入力	CL=21H
;		DX=文字コード
;
;	出力	なし
;
BIOS_33		MACRO	CHAR
		MOV	CL,21H
		MOV	DX,CHAR
		INT	80H
		ENDM


;	機能コード35
;
;	ひらがな,カタカナキーの状態
;
;	入力	CL=23H
;
;	出力	AL=状態
;			0:押されてない
;			 :押されている
;
BIOS_35		MACRO
		MOV	CL,23H
		INT	80H
		ENDM


;	機能コード39
;
;	ｷｰﾎﾞｰﾄﾞｸﾘｯｸ音の有無
;
;	入力	CL=27H
;		DL=ﾓｰﾄﾞ
;			0:ｸﾘｯｸなし
;			1:ｸﾘｯｸあり
;	出力	なし
;
BIOS_39		MACRO	PARA
		MOV	CL,27H
		MOV	DL,PARA
		INT	80H
		ENDM


;	機能コード40
;
;	ｽｸﾘｰﾝの出力状態の参照
;
;	入力	CL=28H
;
;	出力	AL=状態
;			0:出力不可
;			 :出力可能
;
BIOS_40		MACRO
		MOV	CL,28H
		INT	80H
		ENDM


;	機能コード41
;
;	ｽｸﾘｰﾝへの１文字出力
;
;	入力	CL=29H
;		DL=ASCIIｺｰﾄﾞ
;
;	出力	なし
;
BIOS_29		MACRO	PARA
		PUSH	ES
		MOV	CL,29H
		MOV	DL,PARA
		INT	80H
		POP	ES
		ENDM


;	機能コード42
;
;	ｶｰｿﾙﾓｰﾄﾞの設定
;
;	入力	CL=2AH
;		DL=ﾓｰﾄﾞ
;			0:ｶｰｿﾙ無表示
;			1:ｶｰｿﾙ表示
;			2:ｷｰﾎﾞｰﾄﾞ入力待ちのみ表示
;
BIOS_42		MACRO	PARA
		MOV	CL,2AH
		MOV	DL,PARA
		INT	80H
		ENDM










;	画面表示	BIOS
;
BIOS_D7		MACRO	STRING
		PUSH	ES
		MOV	CL,0D7H				;BIOS CALL
		MOV	DX,OFFSET STRING		;INT 80H
		INT	80H				;'$'まで表示
		POP	ES
		ENDM

IF1
%OUT BIOS.H_END
ENDIF
.LIST

