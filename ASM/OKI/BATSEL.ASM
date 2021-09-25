page 55,132
; ***********************************************************************
; *     	実行バッチファイル・選択ユーティリティ 			*
; ***********************************************************************

; ********** 定数設定 **********
val_buff_size	equ	07fffh			; **** 最大ファイル名バッファ長
val_first_pagenum equ	00			; **** 最初に表示するページ
val_max_page	equ	12			; **** 最大の扱えるページ数
val_dir_flength	equ	128			; **** 取り出したｄｉｒ情報の
						;      １ファイルの大きさ
val_fpos_offset	equ	01			; **** data_buff 中のファイル名
						;      の位置
val_page_num	equ	20			; **** 1 Page内の表示ﾌｧｲﾙ数
val_readbuff_length	equ	256

; ==========		マクロ定義		==========
PRINT_STR 	macro string			; string dispaly macro
		mov	dx,offset string
		mov	ah,9
		int	21h
		endm
PRINT_CHR	macro	chrval			;; ***** １文字表示
		push	dx
		push	ax
		mov	dl,chrval
		mov	ah,2
		int	21h
		pop	ax
		pop	dx
		endm
; ********** Massage and dos return for Error *********
MSGOUT_RETURN	macro 	return_code,string
		PRINT_STR	end_msg
		PRINT_STR	string
		mov	ah,4ch			; ***** return dos function
		mov	al,return_code
		int	21h
		endm

; ==========		データセグメントの定義		=========
dataseg		segment	para public 'data'
psp_save	dw	0			; *** psp segment save area
alldir		db	'*.BAT',0		; *** ﾌｧｲﾙ名の指定がなかった時
topmsg	   	db	'File Slector Utility Program by KEI',0dh,0ah,'$'
notdos_vermsg	db	0dh,0ah,7,'ＤＯＳのバージョン３以上が必要です。$'
dir_notfound	db	0dh,0ah,7,'このドライブにはファイルが存在しません。$'
openmes	   	db	27,'[>1h',27,'[2J',27,'[42m'
	   	db   	'Batch File Selector  Version 1.2.0                                             '
		db	27,'[24;4H',27,'[7m'
		db	' HELP ',12		; PF1
		db	'      ',12		; PF2
		db	' 終了 ',12		; PF3 
		db	'      ',12		; PF4
		db	' 実行 ',12,12,12	; PF5
		db	'      ',12
		db	'      ',12
		db	'      ',12
		db	'      ',12
		db	'      ',12
	   	db	27,'[42m',27,'[00;47H$'		     ; *** 表示offset
end_msg		db	27,'[m$'
path_msg   	db   	'  Path [\$'
page_number   	db	0				; *** page count
disp_page 	db 	0				; *** display page
locxy	   	db	27,'[000;000H$' 		; *** locate position
cursor	   	db	0
sel_colorp 	db	27,'[43m$'			; *** select color code
get_count	db	0				; *** file read counter
non_color  	db	27,'[m',0dh,0ah,'$'		; *** reset  color code
cls_msg		db	27,'[2J$'
abend_msg   	db	0dh,0ah,'Program abend for running $'
eoc_pos		db	27,'[23;0H$'
quitmsg	   	db	0dh,0ah,27,'[2J',27,'[m<<< Program quit >>>$'
runmsg		db	27,'[m$'
memerr_msg	db	'Modify Allocates Memory Block Function Error$'
; ********** ファイルｒｅａｄ用データエリア **********
subdirname	db	'.\'
subdirname2	db	40 dup(0h)
startup_buff	db	256 dup(20h),0dh
search_key	db	'REM ',0	; ***** 読込みﾊﾞｯﾌｧ内で識別するｷｰﾜｰﾄﾞ
; ********** DIR SELECT MODE COMMAND TABLE **********
;	                code   label			  key name
table	   	dw	0008h, back_page		; LEFT
	   	dw	003ch, next_page		; RIGHT
	   	dw	0036h, back_page		; ROLL UP
	   	dw	0037h, next_page		; ROLL DOWN
	   	dw	003ah, cursor_left		; UP
	   	dw	003dh, cursor_right		; DOWN
		dw	0064h, quit_com			; QUIT           [PF3]
		dw	0066h, run_com			; RUN 'setup.bat'[PF5]
	   	db	0ffh				; **** END key code
; ************ COM MODE COMMAND TABLE **********
com_shell	db	'  '
com_env		db	'\command.com'			; **** ｺﾏﾝﾄﾞ shell
		db	52 dup(0)
; ****** 実行環境 　　　親環境　psp80h       psp50h(fcb)   psp60h(fcb) *****
com_blockpar	dw	0000h,com_string2,?,com_string3,?,com_string4,?
com_string2	db	60,'/C '			; Command parameter
com_string22	db	'.\'
com_string23	db	55 dup(20h),0dh,0ah,'$'
com_string3	db	'/C',0				; FCB no1 10byte
com_string4	db	'**** ',0			; FCB no2 10byte
search_point	db	0
dta_newarea   	db	128	 dup(0)			; DTA buffer
cd_buff    	db	80	 dup(0)			; ｶﾚﾝﾄ dir get buffer
read_buff  	db	32*256+1 dup(0ffh)		; read dir data buffer
data_buff   	db	128*256  dup(0ffh)		; *** data buff
dataseg		ends

; =========		 スタックセグメントの定義	=========
stackseg	segment	para stack 'stack'
	db	256	dup('...stack')
stackseg	ends

; ========== 		コードセグメントの定義		==========
codeseg		segment	para public 'code'
		assume	cs:codeseg,ss:stackseg,ds:dataseg

; ==========		PROGRAM START		===========
START:
	mov	ax,dataseg			; ***** データセグメントの定義
	mov	es,ax				; ***** STRING_COPY先のｾｸﾞﾒﾝﾄ
	mov	ax,ds				; **** ｐｓｐのセグメント保存
	mov	word ptr es:psp_save,ax		; ***** psp seg add push
	mov	ax,dataseg			; ***** DS ﾉ dataseg define
	mov	ds,ax
	PRINT_STR	topmsg			; *** 開始メッセージ
	mov	ah,30h				; *** Dos version check 
	int	21h
	cmp	al,3				; *** V3 以下は ERROR
	jnc	mstart
	MSGOUT_RETURN	02,notdos_vermsg	; **** don't dos version
mstart:	mov	ax,1a00h			; *** DAT adress の設定
	mov	dx,offset dta_newarea
	int	21h
	call	read_dirdata			; *** read dir data
	mov	al,val_first_pagenum		; *** 表示するﾍﾟｰｼﾞ番号の初期化
	mov	byte ptr page_number,al

; ========== 		MAIN ROUTINE			=========
main:	call	page_print
	mov	al,0
	mov	byte ptr cursor,al
main_loop:			; ***** ディレクトリー選択モード/コマンド入力
	mov	al,byte ptr cursor
	xor	ah,ah
	call	calc_cu
	dec	ah				; **** x座標を１戻す
	call	move_cu
	mov	ah,1				; ***** N88BASIC ROM キー入力
	int	21h				; ***** Function call
						; ***** Return keycode to AH

	mov	ah,al				; ***** Return keycode to AH
	mov	di,offset table-4 ;--+
keych:	;			     |
	add	di,4  ;<-------------+
	cmp	byte ptr [di],0ffh
	jz	error_cu			; if not found key
	cmp	ah,[di]				
	jnz	keych
	jmp	[di+2]				; JUMP same job
error_cu:
	jmp	short main_loop

; ==========	 	各コマンドの処理		=========
; ***** ページ戻しコマンド *****
back_page:
	PRINT_STR	non_color
	mov	al,byte ptr page_number
	or	al,al
	jz	position_err
	dec	al
	mov	byte ptr page_number,al
	call	page_print
	jmp	short main_loop
; ***** ページ送りコマンド *****
next_page:
	PRINT_STR	non_color
	mov	al,byte ptr page_number
	cmp	al,val_max_page-1
	jnc	position_err
	inc	al
	mov	byte ptr page_number,al
	call	page_print
	jmp	short main_loop
position_err:
	jmp	 main_loop
; ***** カーソルを下に移動 *****
cursor_left:
	mov	al,byte ptr cursor
	sub	al,1
	jc	position_err
	jmp	short cursor_com
; ***** カーソルを上に移動 *****
cursor_right:
	mov	al,byte ptr cursor
	add	al,1
	cmp	al,20
	jz	position_err
cursor_com:
	mov	byte ptr cursor,al
	jmp	main_loop
; *****	   	指定ファイルを実行	*****
RUN_COM:call	sdir_set		; *** サブディレクトリ名の設定
	call	main_run		; *** Command.com でのコマンド実行
	call	sdir_set
	mov	dx,offset com_string23
	mov	ah,3bh
	int	21h
	MSGOUT_RETURN	00,runmsg
; ********	Program Quit 	**********
quit_com:				; *** [PF･3]
	PRINT_STR	eoc_pos
	MSGOUT_RETURN	01,quitmsg

; =========		サブルーチン			========
; ***** ディレクトリ名のコピー		*****
sdir_set proc 	near
	mov	al,val_page_num
	mov	ah,byte ptr page_number
	mul	ah
	mov	bl,byte ptr cursor
	xor	bh,bh
	add	ax,bx				; ax=dir number
	call	calc_fa
	mov	di,offset com_string23		; **** com_string23 (ﾊﾟﾗﾒｰﾀ ﾚﾂ)
sdir_lp:mov	al,[bx]				; **** に指定されたファイル名を
	mov	[di],al				; **** 転送コピーする
	inc	bx				
	inc	di
	or	al,al				; **** 0 で終り、
	jne	sdir_lp
	ret
sdir_set endp

; **** 	Ｃｏｍｍａｎｄ．ｃｏｍでのコマンドの実行  *****
main_run proc 	near
	PRINT_STR cls_msg			; **** 画面消去
	mov	ax,word ptr ds:psp_save		; **** プログラム占有メモリを
	mov	es,ax				; **** 縮小する
	mov	bx,2000h			; **** このプログラム本体で
	mov	ah,4ah				; **** 割り当てるメモリ　128KB
	int	21h				; **** ﾒﾓﾘﾌﾞﾛｯｸｻｲｽﾞの変更
	jc	no_mem_error
no_mem_error:
	mov	ax,ds
	mov	com_blockpar[4],ax		; **** コマンドブロックを作成
	mov	com_blockpar[8],ax
	mov	com_blockpar[12],ax
	mov	dx,offset com_shell[2]		; **** command shell の設定
	mov	bx,offset com_blockpar		; **** コマンドブロックの設定
	push	ds				; **** ES=DS <=CS
	pop	es
	mov	ah,4bh				; **** ﾌﾟﾛｸﾞﾗﾑのﾛｰﾄﾞと実行
	mov	al,0				; **** Load & Run 
	int	21h
	jc	command_run_error		; **** コマンド異常終了
	mov	ax,dataseg
	mov	ds,ax
	mov	es,ax
	ret					; **** コマンド正常終了
command_run_error:
	MSGOUT_RETURN	10,abend_msg		; **** Error end
main_run endp

; *****	ｄｉｒのデータを読込む	[Input]  : dir   [Output] : data_buff
read_dirdata 	proc	near
	mov	byte ptr get_count,0		; **** read counter
	xor	bh,bh
	mov	ah,4eh				; search dir top
	mov	dx,offset alldir
	mov	cx,01h				; **** 読込むファイル属性
	int	21h
	jnc	find_dir
	MSGOUT_RETURN	03,dir_notfound		; **** file not found
find_dir:
	mov	di,offset read_buff
nxtfile:inc	get_count			; **** counter add
	mov	bx,offset dta_newarea[15h]
	mov	al,0				; al=0
	mov	[di],al				; 選択flag 
	mov	cx,22				; store length
stloop:	mov	ah,[bx]
	mov	[di+1],ah
	inc	bx
	inc	di
	loop	stloop
	mov	cx,9				; space length
	mov	al,0				; space code
stloop2:mov	[di+1],al
	inc	di
	loop	stloop2
	inc	di
skip_dirread:
	mov	ah,4fh				; search dir next
	mov	cx,10h				; **** 読込むファイル属性
	int	21h
	jc	chang_dirdata
	cmp	byte ptr get_count,250		; **** read data check
	je	chang_dirdata
	jmp	nxtfile

; ***** ファイル・バッファの整形導入 	*****
chang_dirdata:
	mov	si,offset read_buff
	mov	di,offset data_buff
chang_dirdata_loop:
	cmp	byte ptr [si],0ffh
	jne	change_dirdata_skip
	ret					; **** Ｍａｉｎルーチンへ戻る
change_dirdata_skip:
	mov	byte ptr [di],0			; **** set flag reaset
	inc	di
; **** ファイル名エリアのブランクでのリセット ****
	mov	cx,13				; **** file length
	mov	bx,0
reset_loop:
	inc	bx
	mov	byte ptr [di+bx],20h		; **** Reset space
	loop	reset_loop
	; **** ファイル名のコピー ****
	mov	bx,0
read_set_loop:
	mov	al,byte ptr [si+bx+10]
	mov	byte ptr [di+bx],al
	cmp	al,0
	je	skip_read_set
	inc	bx
	jmp	short	read_set_loop
skip_read_set:
	push	di			; ***** ｓｔａｒｔｕｐファイル名セット
	mov	bx,offset subdirname2
subdirname_loop:
	mov	al,byte ptr [di]
	cmp	al,0
	mov	byte ptr [bx],al
	je	startup_set
	inc	bx
	inc	di
	jmp	short subdirname_loop
startup_set:
	mov	cx,val_readbuff_length		; **** "startup_buff" を
	mov	di,offset startup_buff		; **** 0H で埋めつくす
	mov	al,0
	cld
	rep	stosb
	mov	ah,3dh				; **** file open
	mov	dx,offset subdirname		; **** file name
	mov	al,0				; **** read mode
	int	21h
	jc	fileread_skip
	mov	bx,ax				; **** ファイルハンドル
	push	bx				; **** file handel push
	mov	ah,3fh				; **** read command
	mov	dx,offset startup_buff
	mov	cx,256				; **** read bytes
	int	21h
	pop	bx
	push	ax

	mov	ah,3eh				; **** close
	int	21h
	pop	ax
	cmp	ax,5				; **** 頭に'REM 'が在るから
	jc	fileread_skip			; **** 5byte以下はerror

	pop	di
	push	di
	add	di,12	; <*****		; **** ﾃﾞｰﾀｴﾘｱのoffsetを加算
	mov	bx,offset startup_buff
	push	di				; **** DI ﾚｼﾞｽﾀｰは保存先
	push	si
	mov	bx,offset startup_buff		; **** 検索される文字列
	mov	si,offset search_key		; **** 検索するキーワード
	call	search_string			; **** return BX,CLflag
	pop	si
	pop	di
	jc	fileread_skip0
data_move_loop:
	mov	al,byte ptr [bx]
	mov	byte ptr [di],al
	cmp	al,0dh
	je	fileread_skip0
	cmp	al,0			; <****
	je	fileread_skip0		; <****
	inc	bx
	inc	di
	jmp	short data_move_loop
fileread_skip0:
	mov	byte ptr [di],0
fileread_skip:
	pop	di
	add	di,62+65	; <****
	add	si,32
	jmp	chang_dirdata_loop



read_dirdata	endp

; *****	　　１ページの表示サブルーチン 		*****
page_print	proc	near
	push	cx
	PRINT_STR 	openmes 	; **** openning message
	PRINT_STR	path_msg	; **** PATH= の表示
	mov	ah,47h			; **** Path get
	mov	si,offset cd_buff
	mov	dl,0			; **** ｶﾚﾝﾄ drive
	int	21h
	mov	ah,2			; ***** 現在のカレントパスを表示
ch_loop:mov	dl,[si]
	cmp	dl,0
	je	ch_skip
	int	21h
	inc	si
	jmp	short ch_loop
ch_skip:
	PRINT_CHR	']'
	PRINT_STR	non_color
	mov	al,byte ptr page_number		; ***** page number
	mov	ah,20 
	mul	ah
	xchg	ax,di
	mov	cx,20 				; ***** loop counter
ppri_loop:
	call	disp_one
	inc	di
	loop	ppri_loop
	mov	cl,0
	mov	byte ptr [cursor],cl
	pop	cx
	ret
page_print	endp

; *****		 display one dir data.  move cursole  display dir no. to DI
disp_one	proc	near
	push	bx
	push	cx
	mov	ax,di
	call	calc_fa
	jc	do_break
	call	calc_cu
	call	move_cu
	call	display
do_break:pop	cx
	pop	bx
	ret
disp_one	endp

; *****	 ファイルアドレスの計算 	
; *****	 [Iinput] : AL = file number(0~255) [Output] : BX = file address
calc_fa	proc near
	push	ax
	xor	ah,ah
	mov	bx,val_dir_flength		 ; **** one file length
	mul	bx				 ; **** dist DX
	mov	bx,offset data_buff+val_fpos_offset ; **** file name buffer
						 ; **** top address
	add	bx,ax
	mov	si,bx
	push	bx
	cmp	byte ptr [si],0ffh
	stc					; **** end of file set CF
	jz	fa_abnormal
	cmp	byte ptr [si-1],01h		; **** file select flag
	clc					; **** reset CF
	jnz	non_color_set
	PRINT_STR	sel_colorp
	jmp	fa_abnormal
non_color_set:
	PRINT_STR	non_color
fa_abnormal:
	pop	bx
	pop	ax
	ret
calc_fa endp

; *****		calculate cursole position 	*****
calc_cu	proc	near
	push	dx
	mov	dl,20 
	div	dl
	mov	byte ptr disp_page,al		; **** 表示するページ
	mov	al,ah
	mov	dl,2				; *** y pos offset
	add	al,dl
	mov	ah,2				; *** X offset
	pop	dx
	ret
calc_cu endp

; *****		move cursole  ah=x al=y		*****
move_cu proc	near
	push	ax
	xor	ah,ah
	mov	cl,10
	div	cl
	add	al,'0'
	mov	byte ptr(locxy+3),al
	add	ah,'0'
	mov	byte ptr(locxy+4),ah
	pop	ax
	mov	al,ah
	xor	ah,ah
	mov	cl,10
	div	cl
	add	al,'0'
	mov	byte ptr(locxy+7),al
	add	ah,'0'
	mov	byte ptr(locxy+8),ah
	PRINT_STR locxy
	ret
move_cu endp

; *****		ファイル名を整形して表示	*****
display proc	near
	push	bx
	PRINT_CHR	'['
	mov	cx,12				; **** dir name length
display_loop:
	mov	dl,[bx]
	mov	ah,2
	int	21h
	inc	bx
	loop	display_loop
	PRINT_CHR	']'
	PRINT_CHR	'['
	mov	cx,63				; **** dir name length
display_loop2:
	mov	dl,[bx]
	mov	ah,2
	int	21h
	inc	bx
	loop	display_loop2
	PRINT_CHR	']'
	pop	bx
	ret					; **** return main
display endp

search_string	proc	near			; *** 文字列検索ﾌﾟﾛｼｰｼﾞｬ
; [IN]	BX:検索する対象の文字列(最後は00) DI:検索するｷｰﾜｰﾄﾞの文字列(最後は00)
; [out]	CLflag OFF  ==> Keyword found   ON ==> Keyword not found
;       BX:検索対象文字列の中で、見つかったｷｰﾜｰﾄﾞ文字列の次の位置ｱﾄﾞﾚｽ

ss_next:mov	di,si				; **** 検索するｷｰﾜｰﾄﾞ address
ss_loop:mov	al,byte ptr [di]
	cmp	al,0				; **** ｷｰﾜｰﾄﾞの最後に到達
	je	end_ss				; **** 文字列発見
	mov	ah,byte ptr [bx]		; **** ｷｰﾜｰﾄﾞが見つからず
	cmp	ah,0				; **** 文字列の最後に到達
	je	fail_ss
	cmp	ah,60h				; **** 英小文字の変換
	jc	sk_cov
	sub	ah,20h
sk_cov:	cmp	al,ah
	je	next_st
	inc	bx
	jmp	short	ss_next
next_st:inc	di
	inc	bx
	jmp	short	ss_loop
end_ss: clc					; **** 発見のためにｷｬﾘｰのｸﾘｱ
	ret					; **** 発見位置は [BX]
fail_ss:stc					; **** 発見出来なかったﾌﾗｸﾞ
	ret
search_string	endp

codeseg	ends
	end 	START
