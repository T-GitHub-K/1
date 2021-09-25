;********************************************************************
;                         RS232C I/O routine                        *
;********************************************************************
;
	TITLE	rs driver
;
;------------------------- ﾘｶﾊﾞﾘ ﾀｲﾑ sleep -------------------------
SLEEP	macro
	jmp	$+2
	jmp	$+2
	endm
;
_TEXT	SEGMENT	BYTE PUBLIC 'CODE'
_TEXT	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
;
DGROUP	GROUP	CONST,_BSS,_DATA
	ASSUME	CS:_TEXT,DS:DGROUP,SS:DGROUP,ES:DGROUP
PUBLIC	_open_rs		;ＲＳポートイニシャル
PUBLIC	_close_rs		;ＲＳポートリバース
PUBLIC	_put_rs			;データ送信
PUBLIC	_get_rs			;データ受信
;
_DATA	SEGMENT
_rcv_cnt	dw	?	;受信データカウンタ
_rcv_rp		dw	?	;受信リードポインタ
_rcv_wp		dw	?	;受信ライトポインタ
_rcv_buff	dw	1024 dup(?)	;受信バッファ
_snd_cnt	dw	?	;送信データカウンタ
_snd_rp		dw	?	;送信リードポインタ
_snd_wp		dw	?	;送信ライトポインタ
_snd_buff	dw	1024 dup(?)	;送信バッファ
_old_14		dd	?	;旧INT 14Hインターラプトベクタ
_rs_add		dw	?	;RS232Cポートアドレス
_port_no	db	?	;RS232Cポート番号
_ir_vector	db	?	;割り込みベクタ
_irm_8259	db	?	;8259マスク
_DATA	ENDS
;
_TEXT	SEGMENT
	PUBLIC	_open_rs
;********************************************************************
;	RS232C デバイスの割当＆転送レートのセット
;
;	input
;		SS:SP+2 ---- RS232C ポート番号( 0 or 1 )
;		SS:SP+4 ---- RS232C モードパラメータ( INT 14Hに同じ)
;********************************************************************
;
_open_rs	PROC	NEAR
	push	bp
	mov	bp,sp
	mov	_rcv_rp,OFFSET DGROUP:_rcv_buff
	mov	_rcv_wp,OFFSET DGROUP:_rcv_buff
	mov	_rcv_cnt,0
	mov	al,byte ptr[bp+4]	;ポート番号
	mov	_port_no,al
	mov	_ir_vector,0ch		;ポート１割り込みベクタ
	mov	_irm_8259,0efh		;ポート１８２５９マスク
	test	al,al
	jz	open_rs1
	mov	_ir_vector,0bh		;ポート２割り込みベクタ
	mov	_irm_8259,0f7h		;ポート２８２５９マスク
open_rs1:
	mov	al,[bp+6]		;RS232Cモード
	sub	ah,ah
	mov	dl,_port_no		;RS232Cポート番号セット
	xor	dh,dh
	int	14h			;RS232Cモードセット
	push	es
	push	ds
	mov	ah,35h			;割り込みアドレス取得ファンクション
	mov	al,_ir_vector
	int	21h			;旧割り込みアドレスの読み込み
	mov	word ptr _old_14,bx
	mov	word ptr _old_14 + 2,es
	mov	al,_ir_vector
	mov	bx,cs
	mov	ds,bx
	mov	ah,25h			;割り込みアドレス設定ファンクション
	mov	dx,offset _TEXT:int_top
	int	21h			;割り込みアドレスセット
	pop	ds
	mov	ax,040h
	mov	es,ax
	mov	bl,_port_no
	xor	bh,bh
	shl	bx,1
	mov	ax,es:[bx]		;ポートＩ／Ｏアドレスの読み込み
	mov	_rs_add,ax
	mov	dx,ax
	inc	dx
	cli				;割込禁止
	SLEEP
	mov	al,1
	out	dx,al			;割り込みマスクレジスタ書き込み
	SLEEP
	add	dx,3			;モデムレジスタアドレス
	mov	al,1011b
	out	dx,al			;モデムレジスタ書き込み
	SLEEP
	in	al,21h			;8259割込マスク値取得
	SLEEP
	and	al,_irm_8259
	out	21h,al			;8259割込マスク書き込み
	SLEEP
	sti				;割り込み許可
	pop	es
	mov	sp,bp
	pop	bp
	ret
_open_rs	ENDP
;
	PUBLIC	_close_rs
;********************************************************************
;	RS232Cデバイスを元に戻す
;
;
;	Input	-- なし
;********************************************************************
;
_close_rs	PROC	NEAR
	push	bp
	mov	bp,sp
	cli				;割込禁止
	SLEEP
	mov	ah,_irm_8259		;8259割込許可マスク
	xor	ah,0ffh			;On / Off 反転
	in	al,21h			;8259現マスク取得
	SLEEP
	or	al,ah			;現マスク割込禁止
	out	21h,al			;8259割込禁止設定
	push	ds
	mov	ah,25h			;割込アドレス設定ファンクション
	mov	al,_ir_vector
	mov	dx,word ptr _old_14	;旧割り込みアドレスに戻す
	mov	ds,word ptr _old_14 + 2
	int	21h
	pop	ds
	sti				;割込許可
	mov	sp,bp
	pop	bp
	ret
_close_rs	ENDP
;
	PUBLIC	_put_rs
;********************************************************************
;	１文字送出ルーチン
;
;
;	Input	-- SS:SP + 2 送出文字コード
;********************************************************************
_put_rs	PROC	NEAR
	push	bp
	mov	bp,sp
	mov	dx,_rs_add
	add	dx,5
_put_rs1:
	in	al,dx
	SLEEP
	test	al,00100000b		;Transmitter holding register empty ?
	jz	_put_rs1
	mov	al,[bp+4]
	sub	dx,5
	out	dx,al
	sub	ah,ah
	mov	sp,bp
	pop	bp
	ret
_put_rs	ENDP
;
	PUBLIC	_get_rs
;********************************************************************
;	１文字受信ルーチン
;
;
;	Input	-- なし
;	Output	-- AL = 受信文字コード（ＡＨ　＝　００の時）
;		-- AX = -1.. 受信データが存在しない
;********************************************************************
_get_rs	PROC	NEAR
	push	bp
	mov	bp,sp
	sub	sp,2
	cmp	_rcv_cnt,0
	jne	get_rs1
	mov	ax,-1
	jmp	SHORT get_rs3
get_rs1:
	mov	bx,_rcv_rp
	add	_rcv_rp,2
	mov	ax,[bx]
	mov	[bp-2],ax
	cmp	_rcv_rp,OFFSET DGROUP:_rcv_buff+2048
	jb	get_rs2
	mov	_rcv_rp,OFFSET DGROUP:_rcv_buff
get_rs2:
	mov	ax,[bp-2]
	xor	ah,ah
	dec	_rcv_cnt
get_rs3:
	mov	sp,bp
	pop	bp
	ret
_get_rs	ENDP
;
;********************************************************************
;	受信割り込み処理ルーチン
;********************************************************************
;					受信割込アドレス
int_top:
	sti
	push	ax
	push	bx
	push	cx
	push	dx
	push	ds
	mov	ax,seg DGROUP
	mov	ds,ax			;Cのデータセグメントセット
	mov	dx,_rs_add
	add	dx,2			;Interupt identification ｱﾄﾞﾚｽ
	in	al,dx
	SLEEP
	test	al,100b
	jz	int_top_snd
	add	dx,3			;Line starus ﾚｼﾞｽﾀｱﾄﾞﾚｽ
	in	al,dx
	SLEEP
	mov	ch,al
	sub	dx,5
	in	al,dx
	SLEEP
	mov	cl,al
	mov	ax,_rcv_cnt
	cmp	ax,1024
	jz	int_topx
	mov	bx,_rcv_wp
	mov	[bx],cx
	inc	bx
	inc	bx
	cmp	bx,offset DGROUP:_rcv_buff + 2048
	jnz	int_top_1
	mov	bx,offset DGROUP:_rcv_buff
int_top_1:
	mov	_rcv_wp,bx
	inc	_rcv_cnt
	jmp	short int_topx
int_top_snd:
int_topx:
	cli
	mov	al,20h
	out	20h,al
	SLEEP
	sti
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	iret
;
_TEXT	ENDS
END
