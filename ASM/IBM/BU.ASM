;
;title	BU (BATUTY)
;subttl	Copyright(C)1989-91 by Yohei Shimizu(Paci).All rights reserved.
;
;
;	BU.HLP		;help file name for TAG jump
;
;	bu(Batch file Utility)
;	optasm 1.60
;
;まだ
;o dspbat..で同じパスに.COMと.EXEがあって.EXEで起動すると変な表示??
;o ERRORLEVELを得るのがDOS 6.3でできないらしい(batcpも?)(ハングする??)
;o getfatrがボリュームラベルで255が返る??
;
;o dspdrvがIBMのRAMドライブに対応してない

VERSION	equ	'1.10d'
VERNUM	equ	110

DEBUGFLAG	equ	0

CR	equ	0dh		;[cr]
LF	equ	0ah		;linefeed
HT	equ	09h		;[tab]

BUFF_SIZE	equ	8000h

UCHAR_MAX	equ	255	;unsigned char max(CRC table size)
CHAR_BIT	equ	8	;char bit size
CRCPOLY		equ	1021h	;CRC 多項式

ENV_NAME_MAX	equ	512	;env_nameの最大長さ

PARASET_COUNT	equ	128	;paraset$の最大長さ

ID2_UNKNOWN	equ	0
ID2_FMR		equ	10h
  ID2_OASYS	equ	4
  ID2_FM16B	equ	2
  ID2_FMR24	equ	1
ID2_NEC		equ	20h
  ID2_NECHIRESO	equ	1
ID2_IBM		equ	40h
  ID2_NOTAT	equ	1
  ID2_AX	equ	00000000b
  ID2_J31	equ	00000010b

ID_UNKNOWN	equ	255
ID_FM16B	equ	199
ID_OASYS	equ	198
ID_FM16		equ	195
ID_FM24		equ	190
ID_PC98N	equ	185
ID_PC98H	equ	180
ID_J31		equ	170
ID_IBM		equ	160
ID_AX		equ	150

UMB_CHK_SEG	equ	0c000h	;これより下にint 2e(のアドレス)があればUMBに
				;COMMAND.COMとみなす


DTASTRUCT	STRUC	;; find first

DTA__DRIVENO	db ?
DTA__INNAME	db 11 dup(?)
DTA__INATTR	db ?
DTA__COUNT	dw ?
DTA__CLUSTER	dw ?
DTA__RESERVE	db 4 dup(?)
DTA_ATTRIB	db ?
DTA_TIME	dw ?
DTA_DATE	dw ?
DTA_SIZEL	dw ?
DTA_SIZEH	dw ?
DTA_NAME	db 13 dup(?)

DTASTRUCT	ENDS

DTA_DATA_SIZE	equ	48


dwdb	macro	string
	dw string
	db '&string',0
	endm

dbdw	macro	a,b
	db a
	dw b
	endm

dw2db	macro	a,b,c
	dw a,b
	db c
	endm

_BIT7	EQU	10000000b
_BIT6	EQU	01000000b
_BIT5	EQU	00100000b
_BIT4	EQU	00010000b
_BIT3	EQU	00001000b
_BIT2	EQU	00000100b
_BIT1	EQU	00000010b
_BIT0	EQU	00000001b


include	struc240.inc
;
;
;
code	segment
assume	cs:code,ds:code

	org	100h

begin:
	jmp	main000

;
;

	org	103h

verbin		dw 10000	;+3  Version BINARY(N.NN.NN)　※未使用
batcpver	db 0		;+5  batcpで取り込み時,batcp自身のフラグ
				;    (0のまま batcp 0.30A～1.25.1x)
				;    BIT 0:UMB対応版 (batcp 1.25.2a～)
		db 0		;    (Reserved)
chkbatcp	dw 0fcfdh	;+7  BU識別文字
codesize	dw codeend-256	;+9  BU.COM Size
endjmp:		int 21h		;+11 End process jmp	(db 0cdh,21h)
		db 3 dup(?)	;ここがcd以外ならbatcp取り込み↑

;
;

main000:
;
;
	cld
if debugflag
	jmp	short main050
main020:
	jmp	dx			;debug用
endif
;
;
;
main050:
	cli
	mov	sp,offset spoff	;最初に必ずこれをすること
	sti
	call	setdta

	mov	ah,30h		;get dos ver
	int	21h
	mov	[dosver_ax],ax

	mov	ax,3700h		;GET SWITCH CHAR(DL=CHAR)
	int	21h
	mov	[switchchar],dl
	cmp	dl,'-'
	jnz	main080
	mov	byte ptr [path_chr],'/'
main080:

	mov	si,offset 80h	;パラメータ開始位置
	lodsb
	mov	bl,al
	mov	bh,0
	mov	byte ptr [si+bx],CR		;念の為
;main100:
;	call	init
	cmp	byte ptr [endjmp],0cdh
	_if nz
		mov	byte ptr [swchm],0
	_endif

	call	paraget
main150:		;ここにjmpすればパラメータの重複処理となる(EX->KEYWAIT)
	mov	sp,offset spoff
	call	paraskip
	cmp	al,'!'
	jnz	main160
	mov	byte ptr [linefeedflg],1
	inc	si
	call	paraskip
main160:
	inc	byte ptr [cmd_search_flg]	;1
	call	paraset		;[SP][TAB]までを PARASET$に入れる
	dec	byte ptr [cmd_search_flg]	;0
	call	cmd_search
	jnz	main300

    ;CMD があった
main250:
	call	cmd_call
   ;終わり
endn:	push	cs
	pop	ds		;DSを変えられてた時用に戻す
	push	cs
	pop	es		;上に同じ
	push	ax		;ERRORLEVEL
	mov	dx,[swche]
	or	dx,dx
	jz	endn200
    ;/E(ERRORLEVEL表示)の処理
	push	ax
	call	envprintsp
	pop	ax
	call	envdecipr8
endn200:
	cmp	byte ptr [linefeedflg],0
	jz	endn300
	call	linefeed
endn300:
	cmp	byte ptr [swchd],0
	jz	endn400
    ;/D(ENV SET)の処理
	call	envset
;	mov	ax,cs
;	mov	ds,ax		envsetで DS,ES 変わるので)
;	mov	es,ax
endn400:
	pop	ax		;ERRORLEVEL
	or	ah,ah
	jz	endn500
	mov	al,254
endn500:
;	cmp	byte ptr [multi_f],0
;	jz	endn800
;	mov	si,[save_si]
;	jmp	main100
;endn800:
	mov	ah,4ch
;	int	21h
	jmp	endjmp

main300:
	mov	dx,offset nocommand$

errend:			;ERR表示(DX=STRING,DS=CSになる)
	push	cs	;([BU ERROR --- ...]の表示とともに終了)
	pop	ds	;(DXは ...の文字列オフセットを入れる
	mov	byte ptr [psubflag],1		;強制画面出力
	push	dx
	mov	dx,offset error$
	call	print
	pop	dx
	call	print
	call	linefeed
	mov	ax,255	;ERRORLEVEL
	jmp	endn
;
;
;init:
;	xor	ax,ax
;	mov	[swche],ax
;	mov	[swchd],al
;	mov	[keywaitf],al
;	ret
;
;
;paraget:		;パラメータを得る
;			;RET
;			; SI=パラメータ開始位置
;
;	mov	byte ptr [multi_f],0
;
;	mov	di,offset param$
;paraget200:
;	lodsb
;;	cmp	al,'@'
;;	jnz	paraget300
;;	push	si
;;	push	di
;;	mov	di,offset con$
;;	mov	cx,3
;;	call	strnicmpsd
;;	pop	di
;;	jnz	paraget280
;;	pop	bx		;si
;;	xor	bx,bx		;stdin
;;	mov	ah,3fh		;read handle
;;	mov	dx,di
;;	mov	cx,128
;;	int	21h
;;	jmp	paraget200
;;paraget280:
;;	pop	si
;;paraget300:
;	cmp	al,'\'
;	jnz	paraget400
;	lodsb
;	cmp	al,'+'
;	jz	paraget500
;	mov	al,'\'
;	dec	si
;	jmp	short paraget500
;paraget400:
;	cmp	al,'+'
;	jnz	paraget500
;	lodsb
;	cmp	al,'+'
;	jz	paraget500
;	mov	[multi_f],al
;	dec	si
;	mov	al,CR
;paraget500:
;	stosb
;	cmp	al,CR
;	jnz	paraget200
;
;	mov	[save_si],si
;	mov	si,offset param$
;
paraget:		;パラメータを得る
;			;RET
;			; SI=パラメータ開始位置
;
	call	switch		;スイッチのチェック
	jz	infoeasy	;パラメータがない／スイッチのみ ならば
	ret
;
;
;
infoeasy:		;全コマンド名表示後終了
	call	linefeed
	mov	dx,offset title$
	call	printn
	;call	linefeed
	mov	dx,offset infoeasy$
	call	printlf

	mov	si,offset cmd
	mov	ch,0		;CMD COUNT
infoeasy200:
	add	si,2
	mov	cl,0		;CMD STRINGS COUNT
	lodsb
	cmp	al,'@'
	jnz	infoeasy350
	mov	al,'['
	call	psub
	mov	al,'@'
	call	psub
	mov	al,']'
	call	psub
	mov	cl,3
infoeasy300:
	lodsb
infoeasy350:
	or	al,al
	jz	infoeasy500
	call	psub
	inc	cl
	jmp	infoeasy300
infoeasy500:
	cmp	[swch1],0
	jnz	infoeasy530
	inc	ch
	cmp	ch,5		;CMDを５カウント表示したら改行
	jc	infoeasy550
	mov	ch,0
infoeasy530:
	call	linefeed
	jmp	short infoeasy600
infoeasy550:
	mov	al,HT
	call	psub
	cmp	cl,8
	jnc	infoeasy600	;CMDが８文字より長ければ[TAB]は１回出力
	mov	al,HT
	call	psub
infoeasy600:
;	cmp	word ptr [si],0
;	jnz	infoeasy200
	cmp	si,offset cmd200$
	jc	infoeasy200
	call	linefeed
	xor	ax,ax		;ERRORLEVEL
	jmp	endn
;
;
;
psub:		;AL=CHAR １文字表示
	cmp	byte ptr cs:[psubflag],0
	jz	psub200
	int	29h	;画面強制出力
	ret
psub200:
	push	ax
	push	dx
	mov	dl,al
	mov	ah,2		;DSP OUT
	int	21h
	pop	dx
	pop	ax
	ret
;
;
linefeed:		;改行
	mov	dx,offset crlf$
	jmp	short print
;
printlf:		;改行+DX--$ PRINT
	push	dx
	call	linefeed
	pop	dx
;
print:			;DX--$ 表示
	mov	ah,'$'
print100:		;DX--(AH) 表示
	push	si
	mov	si,dx
print200:
	lodsb
	cmp	al,ah
	jz	print800
	call	psub
	jmp	print200
print800:
	pop	si
	ret
;
printn:			;DX--NULL 表示
	mov	ah,0
	jmp	print100
;
;
printcrt:		;DX--$ 画面に強制出力
	push	word ptr cs:[psubflag]
	mov	byte ptr cs:[psubflag],1
	call	print
	pop	word ptr cs:[psubflag]
	ret
;
;
;
nprintsp:		;SI-- [SP],[TAB],[/],[-] までSKIP
	push	dx
	xor	dx,dx
	jmp	short subsp
;
;
envprintsp:		;ENV DX-- [SP],[TAB],[/] まで表示
	push	dx
	mov	si,dx
	mov	dx,offset envpsub
;	jmp	short subsp
;
subsp:			;SI-- PRINTSP用SUB(DXは呼出命令:0なら呼ばない)
			; SI=STRING
			; DX=呼出命令(0:呼ばない)
			;RET
			; SI=[SP][TAB]の位置
	call	para2quote
printsp200:
	lodsb
	or	ah,ah
	_if z
		cmp	al,' '
		jz	printsp800
		cmp	al,HT
		jz	printsp800
	_else		;ah=["]
		cmp	al,ah
		jz	printsp820
	_endif
	cmp	al,CR
	jz	printsp800
	cmp	al,'/'
	jz	printsp800
;	cmp	al,'-'
;	jz	printsp800
	or	dx,dx
	jz	printsp200
	call	dx
	jmp	printsp200
printsp800:
	dec	si
printsp820:
	pop	dx
	ret
;
;
;
;envprint:		;ENV DX--$ 表示
;	mov	ah,'$'
;	jmp	short envprint100
;
envprintcr:		;ENV DX--CR 表示
	mov	ah,CR
	jmp	short envprint100
;
envprintn:		;ENV DX--NULL 表示
	mov	ah,0
;	jmp	short envprint100
;
envprint100:
			;RET
			; SI=[ah]の次の位置
	mov	si,dx
envprint200:
	lodsb
	cmp	al,ah
	jz	envprint800
	call	envpsub
	jmp	envprint200
envprint800:
	ret
;
;
;
envpset:	;/Dなら ENVNAME$に 以外または-e時は無処理
	cmp	word ptr cs:[swche],0
	jnz	envpset800
	cmp	byte ptr cs:[swchd],0
	jnz	envmset
envpset800:
	ret
;
envpsub_l:
	call	lcase
;
envpsub:	;/Dなら ALをENVNAME$に 以外は画面に
	push	di
	mov	di,cs:[psub_mem]
	or	di,di
	jz	envpsub200
	mov	cs:[di],al
	inc	di
	mov	cs:[psub_mem],di
	pop	di
	ret
envpsub200:
	pop	di
	cmp	byte ptr cs:[swchd],0
	jnz	envmset
	jmp	psub
envmset:	;ENVNAME$に１文字セット
	push	bx
	mov	bx,cs:[envcnt]
	cmp	bx,ENV_NAME_MAX
	_if c
		mov	byte ptr cs:[bx + envname$],al
		inc	word ptr cs:[envcnt]
	_endif
	pop	bx
	ret
;
;
;
paraskip:		;[SP][TAB]をSKIP
			; SI=アドレス
			;RET
			; Z=0:AL=CHR CODE
			; Z=1 END
			; SI=([SP][TAB]以外の文字の先頭)アドレス
	lodsb
	cmp	al,CR
	jz	paraskip300
	call	spn_chk
	jz	paraskip
	cmp	word ptr [si-1],4081h		;8140H:全角スペース
	jnz	paraskip300
	inc	si
	jmp	paraskip
paraskip300:
	pushf
	dec	si	;[SP][TAB]の位置にする
	popf
	ret
;
;
paraskip_0:		;
			;RET
			; Z=1:END(NULLでもEND)
	call	paraskip
	_if nz
		or	al,al
	_endif
	ret
;
;
;
para2quote:		;siの文字列が""で括られているかチェック
			; RET
			; ""で括られていればah=["],si++
			; 括られていなければah=0
	mov	ah,0
	cmp	byte ptr [si],'"'
	jnz	para2quote800
	push	si
	inc	si
para2quote100:
	lodsb
	cmp	al,'"'
	jz	para2quote200
	cmp	al,CR
	jnz	para2quote100
	stc
para2quote200:
	pop	si
	jc	para2quote800
	inc	si
	mov	ah,'"'
para2quote800:
	ret
;
;
;
parafeed:
	mov	di,offset hlpwork$
	jmp	short paraset0
;
paraset:		;[SP][TAB]以外を PARASET$ にセット
			; SI=アドレス
			;RET
			; Z=0:
			; Z=1 END(CR,NULLで終わっている)
			; SI=([SP][TAB][CR]の)アドレス
			; DI=OFFSET PARASET$ ('str'+NUL)
	mov	di,offset paraset$
paraset0:		; DI=input address
	push	di
	call	para2quote
paraset100:
	lodsb
	cmp	al,CR
	jz	paraset300
	or	al,al
	jz	paraset300
	or	ah,ah
	jz	paraset200
	cmp	al,'\'
	jnz	paraset150
	cmp	byte ptr [si],ah	;ah=["]
	jnz	paraset150
	lodsb
	jmp	paraset250
paraset150:
	cmp	al,ah		;ah=["]
	jnz	paraset250

	push	ax		; #1.10α.2b
	mov	al,[si]		; 挟まれた `"' なら終端としない
	call	spn_chk		;
	pop	ax		;
	jnz	paraset250	;

	inc	si		;dec siされるので
	jmp	paraset280
paraset200:
	call	spn_chk
	jz	paraset280
	cmp	word ptr [si-2],4081h	;全角スペース
	jz	paraset280
	cmp	byte ptr [cmd_search_flg],0
	_if nz
		cmp	al,'('
		jz	paraset280
		cmp	al,')'
		jz	paraset280
	_endif
paraset250:
	stosb
	jmp	paraset100
paraset280:
	cmp	al,0		;Z=0
paraset300:
	mov	byte ptr [di],0
	pushf
	dec	si		;[SP][TAB]の位置にする
	popf
	pop	di
paraset900:		;JMP from SWITCH
	ret
;
paraset_al:		;PARASETに代入してALに1文字目
			;RET
			; ZF=1:文字列なし
			; ZF=0:文字列あり
			;  AL=文字
	call	paraset
	mov	al,[di]
	or	al,al
	ret
;
paraset_si:
	call	paraset
	mov	si,di
	ret
;
paraset_si2:
	call	paraset
	push	di		;di=offset paraset$
	_if nz
		call	strend
		call	paraskip
		call	paraset0
	_endif
	pop	si		;si=offset paraset$
	ret
;
;
;
switch:			;スイッチのチェック
			; SI=開始位置
			; AL=[SI]
			;RET
			; Z=1:文字列終わり
			; SI=スイッチの次の文字開始位置
	call	paraskip
	jz	paraset900
	cmp	al,[switchchar]
	jz	switch150
	cmp	al,'-'
	jnz	switch900
switch150:
	inc	si
switch200:
	lodsb
	call	sp_chk
	jz	switch800
	or	al,20h
	mov	bx,offset switchjmp
switch300:
	mov	ah,[bx]
	or	ah,ah
	jnz	switch400
	mov	dx,offset switcherr$
	jmp	errend

switch400:
	add	bx,3
	cmp	al,ah
	jnz	switch300
	call	word ptr [bx-2]
	call	paraskip
	jmp	switch

switch800:
	dec	si
switch900:
	jmp	paraskip	;JP & RET
;
;
switchjmp:		;SWITCH JUMP TABLE
	;      ASCII,	JMP_ADDRESS
	dbdw	'e',	switche
	dbdw	'd',	switchd
	dbdw	'n',	switchd
	dbdw	'm',	switchm
	dbdw	'c',	switchm
	dbdw	'1',	switch1
	dbdw	'?',	switchtitle
	dbdw	'h',	switchtitle
	dbdw	'v',	switchtitle
	dbdw	'l',	switchl		; help file name
	dbdw	's',	switchs		; only output strings
	dbdw	'r',	switchr		; root env
	dbdw	'u',	switchu		; helpでマッチしなければ表示
	db 0
;
;
switche:	;/Exxxx
	mov	[swche],si
	jmp	nprintsp		;JP & RET
;
switchl:	;/Lxxxx (help file name)
	mov	[swchl],si
	jmp	nprintsp		;JP & RET
;
switchs:	;/Sxxxx
	mov	dx,si
	jmp	envprintsp		;JP & RET
;
switchd:	;/Dxxxx
	mov	byte ptr [swchd],1
	mov	di,si
	call	nprintsp
	cmp	si,di
	jnz	switchd150	;変数名指定時
   ;/Dのみ("ENVTMP"をENVNAME$にセット)
	mov	di,offset envtmp$
envsetname:		;DI=ENV NAME(ASCZ)    CALL From XCDD
	push	si
	mov	si,di
	mov	di,offset envname$
switchd130:
	lodsb
	stosb
	or	al,al
	jnz	switchd130
	dec	di		;NULLの位置に戻す
	pop	si
	jmp	short switchd300
    ;/Dxxxx変数を指定
switchd150:
	mov	bx,si
	mov	si,di
	mov	di,offset envname$
switchd200:
	lodsb
	call	iskanji
	_if c
		stosb
		lodsb
	_else
		call	case
	_endif
	stosb
	cmp	si,bx
	jc	switchd200
	cmp	al,'='
	jz	switchd300
switchd280:
	mov	al,'='
	stosb
switchd300:
	mov	ax,di
	sub	ax,offset envname$	;(環境の文字数計算)
	mov	[envcnt],ax
switchd800:
	ret
;
;
switchm:
	mov	byte ptr [swchm],1
	ret
;
;
switchr:
	mov	byte ptr [swchm],0
	ret
;
switchu:
	mov	byte ptr [swchu],1
	ret
;
;
switch1:
	mov	byte ptr [swch1],1		;for 1 column
	ret
;
;
switchtitle:
	call	linefeed
	mov	dx,offset title$
	call	printn
	mov	dx,offset switchtitle$
	call	printlf
	xor	ax,ax		;ERRORLEVEL
	jmp	endn

;
;
strcmpsd:		;SIとDI nullまで比較
			;RET
			; Z=1:同じ
			; Z=0:No
			; (DIは大/小文字 OK)(SI,DIとも壊れる)
	mov	al,[di]
	call	case
	cmp	[si],al
	jnz	strcmpsd300
	inc	di
	inc	si
	or	al,al
	jnz	strcmpsd
strcmpsd300:
	ret
;
;
;
sp_chk:		;[SP],[TAB],[CR]かチェック
	cmp	al,' '
	_if nz
		cmp	al,HT
		_if nz
			cmp	al,CR
		_endif
	_endif
	ret
;
;
;
spn_chk:	;alが[space]文字かチェック
			; ret
			; Z=1 : space
	call	sp_chk
	_if nz
		cmp	al,','
	_endif
	ret
;
;
;
crz_chk:	;alがCR,NULLかチェック
			; ret
			; Z=1 : CRかNULL
	cmp	al,CR
	_if nz
		or	al,al
	_endif
	ret
;
;
;
case:			;AL 小文字なら大文字に
	cmp	al,'a'
	jc	caseret
	cmp	al,'z'
	ja	caseret
	and	al,5fh
caseret:
	ret
;
casew:
	call	case
	xchg	ah,al
	call	case
	xchg	ah,al
	ret
;
;
;
lcase:			;AL 大文字なら小文字に
	cmp	al,'A'
	jc	lcaseret
	cmp	al,'Z'
	ja	lcaseret
	or	al,20h
lcaseret:
	ret
;
;
;
hyojie:
	mov	[hyoji_call],offset envpsub
	call	hyoji
	mov	[hyoji_call],offset psub
	ret
;
hyoji:			;パラメータの[表示メッセージ]があれば画面表示
	cmp	al,CR
	jz	hyoji800
hyoji300:
	lodsb
	cmp	al,CR
	jz	hyoji800
	cmp	al,'$'
	jnz	hyoji500
    ;'$'
	lodsb
	cmp	al,CR
	jnz	hyoji350
	mov	al,'$'
	call	word ptr [hyoji_call]
;	int	29h
	jmp	short hyoji800	;RET
hyoji350:
	cmp	al,'$'
	jz	hyoji500
	call	case
	call	deci_chk
	jc	hyoji400
	mov	[color10$],al
	mov	dx,offset color$
	call	printcrt
	jmp	hyoji300
hyoji400:
	cmp	al,'*'
	_if z
		mov	al,'M'
		jmp	short hyoji490
	_endif
	cmp	al,'{'
	_if z
		mov	al,'<'
		jmp	short hyoji500
	_endif
	cmp	al,'}'
	_if z
		mov	al,'>'
		jmp	short hyoji500
	_endif
	cmp	al,'='
	_if z
		mov	al,'|'
		jmp	short hyoji500
	_endif
	cmp	al,40h
	jc	hyoji500
	cmp	al,7fh
	jna	hyoji480
	push	ax
	mov	al,'$'
	call	[hyoji_call]
;	int	29h	;強制画面出力
	pop	ax
	jmp	short hyoji500
hyoji480:
	cmp	al,'M'
	jnz	hyoji490
	mov	al,CR
	call	[hyoji_call]
;	int	29h	;強制画面出力
	mov	al,'J'
hyoji490:
	sub	al,40h
hyoji500:
	call	[hyoji_call]
;	int	29h	;強制画面出力
	jmp	hyoji300
hyoji800:
	ret
;
;
;
keyecho_w:		;AH!=0 なら漢字出力
	or	ah,ah
	_if nz
		xchg	al,ah
		call	keyecho
		xchg	al,ah
	_endif
;
keyecho:		;BP!=1 なら ALを表示(KEY入力のECHO用)
	dec	bp
	jz	keyecho800
	int	29h	;強制画面出力
keyecho800:
	inc	bp
	jmp	envpset		;JP & RET
;
;
;
execcoms:		;COMMAND.COM 起動して EXEC
	mov	bx,offset enddata
	mov	cl,4
	shr	bx,cl
	inc	bx
	mov	ah,4ah			;Change Memory size
	int	21h

	mov	dx,offset execcoms100$
	jc	execcoms190

	mov	[para_block+ 4],ds	;PSP
;	mov	[para_block+ 8],ds	;FCB 1
;	mov	[para_block+12],ds	;FCB 2

	push	ds

	mov	di,offset comspec$
	call	strget			;"COMSPEC="を得る
	jnc	execcoms200
    ;"COMSPEC="がない
	mov	dx,offset execcoms120$
execcoms190:
	jmp	errend

execcoms200:
	mov	di,offset searchbuff
execcoms220:		;SERCHBUFFにCOMSPEC=に続く文字を入れる
	lodsb
	stosb
	or	al,al
	jnz	execcoms220

	pop	ds

	mov	dx,offset searchbuff
	mov	bx,offset para_block

	mov	ax,4b00h		;PROGRAM LOAD and RUN
	int	21h

	mov	dx,offset execcoms130$
	jc	execcoms190		;COMMANDが見つからない

	mov	bx,0ffffh		;最大量
execcoms400:
	mov	ah,4ah			;Change Memory size
	int	21h
	jnc	execcoms450

	cmp	ax,8			;それだけのメモリーがない？(BX=MAX)
	jz	execcoms400

	mov	dx,offset execcoms140$	;MEMALOC ERR
	jmp	execcoms190
execcoms450:
	ret
;
;
;
strget:			;環境変数から 文字列の位置求める
			; DI=検索文字列(NULLで終わる)
			;RET
			; CY=1:なし
			;    0:あり
			; DS:SI=STRING位置(DIの次の)
	xor	cx,cx
	mov	si,di
strget180:
	inc	cx
	lodsb
	or	al,al
	jnz	strget180
	dec	cx

	mov	ds,ds:[2ch]	;環境変数の位置
	xor	si,si
strget200:
	cmp	byte ptr [si],0
	jz	strget400
	mov	ax,si
	push	cx 
	push	di
  repz cmpsb
	pop	di
	pop	cx
	jz	strget500
	mov	si,ax
strget250:
	lodsb
	or	al,al
	jnz	strget250
	jmp	strget200

strget400:
	stc

strget500:
	ret
;
;
;
hexprax:		;16進4桁AXプリント
	push	ax
	mov	dl,ah
	call	hexprdl
	pop	dx
;
hexprdl:		;16進2桁DLプリント
	push	dx
	push	cx
	mov	al,dl
	mov	cl,4
	shr	al,cl
	pop	cx
	call	hexprsub
	pop	ax
hexprsub:
	and	al,0fh
	;add	al,90h
	;daa
	;adc	al,40h
	;daa
	cmp	al,10
	sbb	al,69h
	das
	jmp	envpsub		;JUMP & RET
;
;
;
hexprax_sup:		;0サプセス 16進AXプリント
			; BX=使用する表示ルーチン名
	push	ax
	push	cx
	push	dx
	push	si

	mov	si,16
	mov	ch,0		;CH=0(文字数)
hexprax_sup100:
	xor	dx,dx
	div	si
	push	dx		;余り=表示文字
	inc	ch
	or	ax,ax
	jnz	hexprax_sup100
hexprax_sup200:
	pop	ax
	cmp	al,10
	sbb	al,69h
	das
	call	bx
	dec	ch
	jnz	hexprax_sup200

	pop	si
	pop	dx
	pop	cx
	pop	ax
	ret
;
;
;
octprax_sup:		;0サプセス 8進AXプリント
	xor	dx,dx
;octprax_sup:		;0サプセス 8進DX:AXプリント
	push	ax
	push	bx
	push	si
	push	di
	mov	bx,8
	jmp	short decipr2
;
;
;
envdeci2:		;0サプセスなしで2桁
	cmp	al,10
	jnc	envdecipr8
	push	ax
	mov	al,'0'
	call	envpsub
	pop	ax
;
envdecipr8:		;10進で表示 AX=数値
	xor	dx,dx
envdecipr16:		;10進で表示 DX:AX=数値
	push	ax
	push	bx
	push	si
	push	di

	mov	bx,10
decipr2:		;jmp from octpr
	mov	cx,dx
	push	bx		;flag
decipr100:
	xor	dx,dx
	;jcxz	decipr200
	xchg	ax,cx
	div	bx
	xchg	ax,cx
;decipr200:
	div	bx
	push	dx
	mov	dx,ax
	or	dx,cx
	jnz	decipr100
decipr400:
	pop	ax
	cmp	al,bl
	jz	decipr800
	add	al,'0'
	call	envpsub
	jmp	decipr400
decipr800:
	pop	di
	pop	si
	pop	bx
	pop	ax
	ret

;	push	ax
;	mov	ch,0		;CH=0(文字数)
;decipr100:
;	call	decidiv
;	push	si		;余り=表示文字
;	inc	ch
;	mov	si,ax
;	or	si,dx
;	jnz	decipr100	;DX:AX != 0
;decipr200:
;	pop	ax
;	add	al,'0'
;	call	envpsub
;	dec	ch
;	jnz	decipr200
;
;	pop	ax
;	ret
;;
;;
;;
;decidiv:		;DX:AX/10 余り SI
;	push	cx
;
;	mov	cx,20h
;	xor	si,si
;decidiv100:
;	shl	ax,1
;	rcl	dx,1
;	rcl	si,1
;	cmp	si,10
;	jc	decidiv110
;	sub	si,10
;	inc	ax
;decidiv110:
;	loop	decidiv100
;
;	pop	cx
;	ret
;
;
;
octin:			;8進数文字列を数値に(3桁以下)
			; DS:SI=文字列
			;RET
			; AL=変換できなかった文字
			; CX=数値
			; SI=変換できなかった文字のアドレス
	mov	cx,3
	xor	dx,dx
octin200:
	lodsb
	sub	al,'0'
	_if nc
		cmp	al,7
		_if na
			shl	dx,1
			shl	dx,1
			shl	dx,1
			cbw
			add	dx,ax
			loop	octin200
			mov	cx,dx
			ret
		_endif
	_endif
	dec	si
	mov	cx,dx
	ret
;
;
deciin:			;10進数文字列を数値に(65535以下)
			; DS:SI=文字列
			; CX=最大数値(CX以下ならリターン)
			;RET
			; AL=PARASKIPした文字(AL=cr:Z=1)
			; CX=数値
			; SI=paraskipしたaddress
			; BX=変換できなかった文字のアドレス
	mov	al,[si]		;いちばん最初の文字
	cmp	al,CR
	jz	deciin800
	call	deci_chk
	jnc	deciin200
paraerr:
	mov	dx,offset paraerr$
	jmp	errend

deciin200:
	push	cx
	push	dx
	xor	cx,cx		;数値

deciin220:
	mov	al,[si]
	call	deci_chk
	jc	deciin500
	sub	al,'0'
	mov	ah,0
	xchg	cx,ax		;今までの数値を AXに
	mov	bx,10
	mul	bx		;それを１０倍
	or	dx,dx		;65536を越えた?
	jnz	decimaxovr	;YES
	add	cx,ax
	jc	decimaxovr	;65536を越えた?
	inc	si
	jmp	deciin220
deciin500:
	pop	dx
	pop	bx		;入力最大値(最初の CX)
	cmp	bx,cx		;越えてない?
	jnc	deciin800	;YES
decimaxovr:
	mov	dx,offset decimaxovr$
	jmp	errend
deciin800:
	mov	bx,si
	jmp	paraskip
;
;
;
hexincl:		;16進入力 MAX 0FFH
	mov	cx,0ffh
	jmp	short hexin
;
hexincx:		;16進入力 MAX 0FFFFH
	mov	cx,0ffffh
;
hexin:			;１６進入力(0FFFFH以下)
			; SI=文字列
			; CX=最大数値(CX以下ならリターン)
			;RET
			; AL=変換できなかった文字
			; CX=数値
			; SI=変換できなかった文字のアドレス
	mov	al,0		;flag(max over)
hexin0:			;al=flag(0=max over error, 0!=max then return)
	mov	ah,0		;最大桁数OFF
hexin1:			;ah=最大桁数
	push	bx
	push	dx
	mov	bx,cx
	mov	ch,al		;flag
	xor	dx,dx
	call	paraskip
	lodsb
	call	hexinsub
	jc	short paraerr
	mov	dl,al
	dec	ah
hexin300:
	lodsb
	call	hexinsub
	jc	hexin600
	cmp	dh,0fh
	ja	hexin900
	mov	cl,4
	shl	dx,cl
	or	dl,al
	dec	ah
	jnz	hexin300
hexin600:
	cmp	dx,bx
	ja	hexin900
hexin800:
	;;pushf
	dec	si
	;;popf
	mov	cx,dx
	pop	dx
	pop	bx
	ret
;
hexin900:
	or	ch,ch
	jnz	hexin800
	jmp	decimaxovr
;
;
;
hexinsub:		;ALの１６進文字を数値に
			;RET
			; CY=1:ERR
			; CY=0:AL=NOM
	push	bx
	mov	bl,al
	sub	al,'0'
	jc	hexinsub500
	cmp	al,0ah
	cmc			;CY=XOR CY
	jnc	hexinsub500
	or	al,20h
	sub	al,27h
	cmp	al,0ah
	jc	hexinsub500
	cmp	al,10h
	cmc
hexinsub500:
	_if c
		mov	al,bl
	_endif
	pop	bx
hexinsub_ret:
	ret
;
;
;
envset:			;SIを親の環境変数にＳＥＴ
			; envname=(name=nnnn)
	mov	ax,[envcnt]
	or	ax,ax
	jz	hexinsub_ret

	mov	dx,offset envname$
				;ES=親の環境アドレス , CX=環境の大きさ
	call	envstrget1	;すでにSETする文字がある？
	push	es
	pop	ds		;DSを親の環境セグメントに
	jnz	envset300	;(SETする文字がある?)NO
    ;del env(すでにある文字列の削除)
	push	cx
	mov	si,dx
	mov	di,bx
	sub	cx,si
    rep movsb
	pop	cx

envset300:
    ;セットする文字があるかチェック
	push	cx
	mov	si,offset envname$
	xor	cx,cx
envset320:
	lods	byte ptr cs:[si]	;cs:lodsb
	inc	cx
	or	al,al		;'='がなくて終わり
	jnz	envset340
	pop	cx
	ret
envset340:
	cmp	al,'='
	jnz	envset320

	cmp	cs:[envcnt],cx	;文字列の終わりが"="の１つめ?
	pop	cx
	jz	envset900	;Yes


	call	envskipend
	pushf
	lea	di,[si+1]	;DI=環境変数の最後の位置(00,00 の次)
	jnz	envset500
    ;自分自信の名前のSKIP
	add	si,4
envset360:
	lodsb
	or	al,al
	jnz	envset360

envset500:
	mov	dx,si		;SI=いちばん終わりのアドレス
	mov	ax,cs:[envcnt]
	add	dx,ax
	add	dx,2		;前後のNULL分
	cmp	cx,dx
;	jnc	envset600	;環境の容量を越えてなければ
	ja	envset600	; #1.09

	mov	byte ptr cs:[swchd],0	;/Dを無効にする
	mov	dx,offset envovr$
	jmp	errend
envset600:
	popf			;ENVSKIPEND のフラグ
	jnz	envset700	;自分の名前なし
    ;自分自信の名前を後ろにずらす
	push	di
	mov	ax,di		;AX=変数の終端
	mov	di,cx
	dec	di		;DI=環境の終端
	sub	cx,ax		;CX=環境の終端 - 変数の終端
	mov	ax,cs:[envcnt]	;AX=今から入れる文字数
	sub	cx,ax		;今から入れる文字数分は余計なので引く
	inc	ax		;AX=今から入れる文字数 + 1(nullの分)
	mov	si,di		;SI=環境の終端
	sub	si,ax		;SI=環境の終端 -(今から入れる文字数 + 1)
	std			;後ろから前に代入する
    rep movsb
	cld
	pop	di

envset700:
    ;環境変数を入れる
	push	cs
	pop	ds	;DSをセットする変数のセグメントに

	mov	si,offset envname$
	mov	cx,[envcnt]
    rep movsb
	mov	ax,0	;終わりのNULL*2
	stosw

envset900:
	ret
;
;
;
envskipend:		;環境の最後のアドレス得る
			; DS=環境のセグメント
			;RET
			; SI=最後のアドレス(00が二つ続く２つめの位置)
			; Z=0:自分自信の名前無し
			;   1:		    あり
	mov	si,-1
envskipend300:
	inc	si
	cmp	word ptr [si],0		;00,00 ?
	jnz	envskipend300
	cmp	word ptr [si+2],1	;01,00 ?(自分の名前あり?)
	ret
;
;
;
envstrget1:
	call	getenvseg	

envstrget:		;環境から DX(NAME=ASCnull)の位置得る
			; ES=環境のセグメント
			; DS:DX=NAMEのアドレス(NAME=)
			;RET
			; Z=0:なし
			; Z=1
			;  ES:BX= 開始アドレス
			;  ES:SI= [=]の次のアドレス
			;  ES:DX= 終了アドレス(NULLの次の文字)

	xor	si,si		;SI=環境の頭
envstrget200:
	mov	di,dx		;DI="NAME="
	mov	bx,si		;SIを待避
	call	envstrcmp
	jz	envstrget500
envstrget300:
	or	al,al
	jz	envstrget400	;NULLまでSKIP
	lods	byte ptr es:[si]	;ES:LODSB
	jmp	envstrget300
envstrget400:
	cmp	byte ptr es:[si],0	;環境終わり?
	jnz	envstrget200		;NO
	cmp	al,1		;Z=0
	ret

envstrget500:	;find!
	mov	dx,si		;待避
envstrget540:
	lods	byte ptr es:[si]	;ES:LODSB
	or	al,al		;SIをNULLまでSKIP
	jnz	envstrget540
	xchg	dx,si
	ret
;
;
;
envstrcmp:		;ES:SIとDS:DIを [=]まで比較
			; Z=1:同じ(SI:[=]の次のアドレス)
			; Z=0:No
			; (DIは大/小文字 OK)
	mov	al,[di]
	call	iskanji
	_if c
		cmp	es:[si],al
		jnz	envstrcmp300
		inc	di
		inc	si
		mov	al,[di]
	_else
		call	case
	_endif
	cmp	es:[si],al
	jnz	envstrcmp300
	inc	di
	inc	si
	cmp	al,'='
	jnz	envstrcmp
envstrcmp300:
	ret
;
;
;
getcmdcomseg:		;(ルートの)command.comのセグメントを得る
			; ES=seg(MCBのところまたはint 2eのセグメント自身)
			;NC:MCBより見つけた
			;CY:無かったのでint 2eのアドレスを返した
			;   (若しくはUMBにCOMMAND.COMがあった)
	cmp	byte ptr [endjmp],0cdh	;batcp取り込み中?
	_if nz		;Yes
		test	byte ptr [batcpver],1	;batcp UMB対応版?
		jz	getcmdcomseg120		;No
	_endif

	mov	ax,352eh		;get vect (2eh)
	int	21h
	mov	ax,es
	cmp	ax,UMB_CHK_SEG
	jnc	getcmdcomseg_cy		;NCならUMB以上にint 2eがあった

getcmdcomseg120:
	mov	ah,52h
	int	21h
	mov	es,es:[bx-2]
getcmdcomseg130:
	mov	ax,es:[1]
	mov	bx,es
	inc	bx
	cmp	ax,es:[16h+10h]	;ppidとpidが同じ?
	jnz	getcmdcomseg135
	cmp	ax,bx		;pspとpidが同じ(command.com)?
	_if z
		clc
		ret
	_endif
getcmdcomseg135:
	cmp	byte ptr es:[0],'Z'	;MCB link End?
	_if z		;Yes
		mov	ax,352eh		;get vect (2eh)
		int	21h
getcmdcomseg_cy:
		stc
		ret
	_endif
	add	bx,es:[3]
	mov	es,bx
	jmp	getcmdcomseg130

;
;
;
getenvseg:		;親の環境のセグメント得る
			;RET
			; ES=セグメント
			; CX=環境の大きさ
	push	bx
	push	dx

	cmp	byte ptr [swchm],1	;-m,c?
	jnz	getenvseg120		;No

	mov	es,ds:[16h]	;親セグメントのpsp
	mov	dx,es:[2ch]	;親セグメントのenv

;	mov	ah,30h		;get dos ver
;	int	21h
;
;	cmp	ax,1003h	;3.10
;	jna	getenvseg110	;<=

;	or	dx,dx
;	jnz	getenvseg110

	mov	ax,es
	dec	ax
	mov	es,ax
	mov	bx,es:[3]		;size
	add	bx,ax
	inc	bx
	mov	es,bx
	inc	ax
	cmp	ax,es:[1]	;(command.comの)pspとprocが同じ?
	;jz	getenvseg155
	jnz	getenvseg110
	;mov	es,bx
	cmp	byte ptr es:[10h],0	;バッチワークエリア??
	jnz	getenvseg155		;違うみたいだ
getenvseg110:
	mov	bx,dx
	jmp	short getenvseg200

getenvseg120:
	call	getcmdcomseg
	jnc	getenvseg160

	mov	bx,es:[2ch]		;env seg
	jmp	getenvseg200

getenvseg140:
	mov	bx,es
	inc	bx
getenvseg150:
	add	bx,es:[3]
	mov	es,bx
	cmp	ax,es:[1]	;pspがcommand.comと同じ?
	jnz	getenvseg140
getenvseg155:
	inc	bx
	jmp	short getenvseg200
getenvseg160:
;	push	ax
;	push	bx
;	mov	ah,30h		;get dos ver
;	int	21h
;	cmp	al,5
;	pop	bx
;	pop	ax
;	jc	getenvseg150	;ver 4 later
;	mov	bx,es:[2ch + 10h]
	mov	cx,es:[2ch + 10h]
	jcxz	getenvseg150

getenvseg180:
	add	bx,es:[3]	;#1.10a.3
	mov	es,bx		;([2ch]に数値があっても次のMCBを調べる)
	cmp	ax,es:[1]	;
	_if z			;
		cmp	byte ptr es:[10h],0	;バッチワークエリア??
		jz	getenvseg180		;みたいなのでもう一個先のMCBへ
		inc	bx	;
		mov	cx,bx	;
	_endif			;

	mov	bx,cx
getenvseg200:
	dec	bx
	mov	es,bx
	mov	ax,es:[3]	;環境の大きさのパラグラフ
	mov	cl,4
	shl	ax,cl
	mov	cx,ax		;CX=環境の大きさ(BYTE)
	inc	bx
	mov	es,bx		;ES=環境の開始アドレス

	pop	dx
	pop	bx

	ret
;
;
;
getbatseg:		;バッチワークエリアのセグメント得る
			;RET
			; NC:OK
			;	ES=セグメント
			; CY:ERROR
	push	bx
	push	dx

	;mov	dx,ds:[16h]	;親セグメントのpsp
	xor	ax,ax
	mov	es,ax
	mov	dx,word ptr es:[24h*4 + 2]

	mov	ah,52h
	int	21h
	mov	es,es:[bx-2]
	mov	bx,es
getbatseg100:
	mov	es,bx
	cmp	dx,es:[1]	;(command.comの)pspとprocが同じ?
	jnz	getbatseg150

	inc	bx
	mov	es,bx
	cmp	[dosver_al],2
	_if a		; DOS 3.x later
		cmp	byte ptr es:[0h],0	;バッチワークエリア??
		jz	getbatseg200		;No
	_else
		mov	al,0
		xor	di,di
		mov	cx,128
	  repnz	scasb
		_if z
			sub	di,5
			mov	si,offset BAT$
			mov	cx,3
		  repz	scasb
			jz	getbatseg200
		_endif
	_endif
	dec	bx
getbatseg150:
	mov	es,bx
	inc	bx
	add	bx,es:[3]
	cmp	byte ptr es:[0],'Z'	;MCB link End?
	jnz	getbatseg100
	stc
	jmp	short getbatseg800

getbatseg200:
	clc
	mov	es,bx		;ES=バッチワークエリアの開始アドレス
getbatseg800:
	pop	dx
	pop	bx

	ret
;
;
;
envsave:		;ENVNAME$ 待避
	push	ax
	push	cx
	push	si
	push	di
	push	ds
	push	es

	mov	ax,cs
	mov	ds,ax
	mov	es,ax

	mov	di,offset envsave$
	xor	ax,ax
	xchg	ax,[envcnt]
	stosw
	mov	al,[swchd]
	stosb
	mov	si,offset envname$
envsave250:		;JMP ENVLOAD
	mov	cx,ENV_NAME_MAX
    rep movsb

	pop	es
	pop	ds
	pop	di
	pop	si
	pop	cx
	pop	ax
	ret
;
;
envinit:		;envname$ 初期化
	push	ax
	push	cx
	push	di
	push	es
	push	cs
	pop	es
	xor	ax,ax
	mov	cs:[envcnt],ax
	mov	cx,ENV_NAME_MAX
	mov	di,offset envname$
  rep	stosb
	pop	es
	pop	di
	pop	cx
	pop	ax
	ret
;
;
envload:		;ENVNAME$ 復活
	push	ax
	push	cx
	push	si
	push	di
	push	ds
	push	es

	mov	ax,cs
	mov	ds,ax
	mov	es,ax

	mov	si,offset envsave$
	lodsw
	mov	[envcnt],ax
	lodsb
	mov	[swchd],al
	mov	di,offset envname$
	jmp	envsave250
;
;
;
errsubset:		;エラールーチン SET(DOS ERRに落ちなくする)
	pushf
	push	ax
	push	bx
	push	dx
	push	es

	mov	ax,3524h	;GET INT ADD(ERR HANDLER No)
	int	21h

	mov	[org24off],bx
	mov	[org24seg],es

	mov	dx,offset errjump

	mov	ax,2524h	;SET INT ADD(ERR HANDLER No)
	int	21h

	pop	es
	pop	dx
	pop	bx
	pop	ax
	popf

	ret
;
;
;
errsubreset:		;エラールーチン RESET
	push	ax
	push	bx
	push	dx
	push	ds

	mov	dx,[org24off]
	mov	ds,[org24seg]

	mov	ax,2524h	;SET INT ADD(ERR HANDLER No)
	int	21h

	pop	ds
	pop	dx
	pop	bx
	pop	ax

	ret
;
;
;
errjump:		;エラー処理ルーチン
	mov	cs:[errcodedi],di
	mov	al,0		;ERR 'I'
	iret
;
;
;
convbtomb:		;数値 DX:AX を DX:AXメガバイトに変換
	call	convbtokb
	;jmp	convbtokb
;
convbtokb:		;数値 DX:AX を DX:AXキロバイトに変換
	push	cx
	mov	cx,10
convbtokb300:
	shr	dx,1
	rcr	ax,1
	loop	convbtokb300
	pop	cx
	ret
;
;
;
spskip:		;[SP],[TAB],[CR] SKIP(終端はNULL)
		; SI=STRINGS
		;RET
		; SI=[TAB],[SP]以外の文字のアドレス
		; AL=[SI]
		; Z=1:AL=NULL
	lodsb
	or	al,al
	jz	spskip800
	call	sp_chk
	jz	spskip
	dec	si
	or	al,al		;Z=0
spskip800:
	ret
;
;
;
strcpysd:		;文字列 SIを DI(PARASET$)にコピー
			;RET
			; DI=NULLの位置/CRの次の位置
	mov	di,offset paraset$
;
strcatsd:		;文字列 SIを DIに追加(NULL,crまで)
	lodsb
	stosb
	cmp	al,CR
	jz	strcatsd800
	or	al,al
	jnz	strcatsd
	dec	di
strcatsd800:
	ret
;
;
;
getch:			;キー入力(NON WAIT)
	mov	dl,0ffh
	mov	ah,6
	int	21h
	or	al,al
	ret
;
;
keyin_w:		;キー入力待ち(漢字もOK)
			;RET
			; AH=0:ASCII
	call	keyin
	call	iskanji
	mov	ah,0
	_if c
		mov	bh,al
		call	getch		
		mov	ah,bh
	_endif
	ret
;
keyin:			;キー入力待ち
	mov	ah,2ch		;GET TIME
	int	21h
keyin150:
	mov	bl,dh		;BL(DH)=SEC
keyin200:
	mov	ah,0bh		;GET K/B STATUS
	int	21h
	or	al,al
	jnz	keyin700

	cmp	byte ptr [keywaitf],0
	jz	keyin200

	cmp	[keywaitc],0
	jz	keyin600

	mov	ah,2ch		;GET TIME
	int	21h
	cmp	bl,dh		;SEC
	jz	keyin200

	dec	[keywaitc]
	jmp	keyin150

keyin600:		;TIME OUT
	mov	ax,254
	jmp	endn

keyin700:		;KEY IN
	mov	ah,08h		;K/B IN WAIT
	int	21h
	ret
;
;
;
calcget:		;CALC sub
			; SI=START
			;RET
			; SI='+','-'の位置
			; AL=変換できなかった文字
			; CX=数値

	mov	di,offset envname$
	mov	byte ptr [di],0
	call	paraskip
	cmp	al,'9'
	ja	calcget100
	cmp	al,'0'
	jc	calcget100
	jnz	calcget050
	mov	al,[si+1]
	call	case
	cmp	al,'X'
	jnz	calcget050
		;0x????
	lodsw			;add si,2
	mov	cx,0ffffh
	jmp	hexin

calcget050:
	push	si
	mov	cx,0ffffh
	call	deciin
	mov	al,[bx]
	call	spn_chk
	jz	calcget070
	call	deci_tok
	jnz	calcget080
calcget070:
	add	sp,2
	ret
calcget080:
	pop	si
calcget100:
calcget200:
	call	paraskip
	jz	calcget300
	call	deci_tok
	jz	calcget300
	call	case
	stosb
	inc	si
	mov	al,[si]
	call	spn_chk
	jnz	calcget200
	call	paraskip
calcget300:
	push	es
	push	ax
	push	si

	mov	al,'='
	stosb

	mov	ax,di
	sub	ax,offset envname$
	mov	[envcnt],ax

	mov	al,0
	stosb

	mov	dx,offset envname$
	call	envstrget1
	jz	calcget400

	push	cs
	pop	es
	push	di
	mov	di,offset envname$
	mov	si,offset errorlevel_eq$
	call	envstrcmp
	pop	di
	_if z
		call	geterrorlevel
		xchg	ax,cx		;mov cx,ax
		jmp	short calcget500
	_endif
	mov	ax,255
	jmp	endn

calcget400:
	mov	cx,0ffffh
	push	ds
	push	es
	pop	ds
	call	deciin

	pop	ds
calcget500:
	pop	si
	pop	ax
	pop	es

	ret
;
;
;
setdta:			;DTA ADD SET
	mov	dx,offset dtaadd
	mov	ah,1ah		;Set DTA Add
	int	21h
	ret
;
;
;
wildcardsub:		;[d:][name]のsub
			;ret
			; dx=wildcard$/wildcard0$

	call	paraskip

	mov	dx,offset wildcard$
	jz	wildcardsub800

	cmp	byte ptr [si+1],':'
	jnz	wildcardsub800
	mov	al,[si]
	mov	[wildcard0$],al
	mov	dx,offset wildcard0$
	inc	si
	inc	si
wildcardsub800:
	ret
;
;
;
fopen:			;file open
			;DX=name
	mov	ax,3d00h	;OPEN HANDLE
	int	21h
	mov	bx,ax
	ret
;
;
fclose:			;file close
			;BX=handle
	mov	ah,3eh		;CLOSE HANDLE
	int	21h
	ret
;
;
;
dosgetday:
	mov	ah,2ah		;GET DAY
	int	21h
	ret
;
dosgettime:
	mov	ah,2ch		;GET TIME
	int	21h
	ret
;
;
;
chkpathchr:
	cmp	al,'\'
	jz	chkpathchr800
	cmp	al,'/'
chkpathchr800:
	ret
;
;
;
iskanji:		;漢字なら CY
	test	al,0e0h
	jns	iskanji800
	jp	iskanji800
	stc
iskanji800:
	ret
;
;
;
j_strlwr:		;si-(NULL/CR)まで小文字に(漢字OK)
	mov	dx,offset lcase
	jmp	short jstr_sub
;
j_strupr:		;si-(NULL/CR)まで大文字に(漢字OK)
	mov	dx,offset case
;
jstr_sub:
	push	si
	push	di
	mov	di,si
j_strupr200:
	lodsb
	call	iskanji
	jnc	j_strupr400
	stosb
	movsb
	jmp	j_strupr200
j_strupr400:
	call	dx
	stosb
	or	al,al
	jz	j_strupr800
	cmp	al,CR
	jnz	j_strupr200
j_strupr800:
	pop	di
	pop	si
	ret
;
;
;
j_strchr:		;siの文字列からalを探す(漢字OK)
			;RET
			; Z=0:文字なし
			; Z=1:
			; SI=alの次の位置
	mov	ah,al
j_strchr200:
	lodsb
	call	iskanji
	jc	j_strchr500
	cmp	al,ah
	jnz	j_strchr600
	ret
j_strchr500:
	lodsb
j_strchr600:
	cmp	al,1
	jnc	j_strchr200
	ret		;Z=0
;
;
j_strright1:		;siの右端の文字を得る(漢字OK)
			; SI='STR'+NULL
			;RET
			; AX=char(ASCIIならAH=0になる)
			; SI=NULLの位置
	push	cx
	xor	cx,cx		;いきなりNULLのとき用
j_strright1200:
	lodsb
	or	al,al
	_if nz
		mov	cl,al
		mov	ch,0
		call	iskanji
		_if c
			lodsb
			mov	ch,al
		_endif
		jmp	j_strright1200
	_endif
	dec	si
	xchg	ax,cx		;mov ax,cx
	pop	cx
	ret
;
;
;
inputcl:
	lodsb
	cmp	al,27h		;[']
	jnz	inputcl300
	lodsb
	mov	cl,al
	lodsb
	cmp	al,27h
	jz	inputcl800
	jmp	paraerr
inputcl300:
	dec	si
	call	hexincl
inputcl800:
	ret
;
;
;
inputcx:
	lodsb
	cmp	al,27h		;[']
	jnz	inputcx300
	lodsw
	mov	cx,ax
	lodsb
	cmp	al,27h
	jz	inputcx800
	jmp	paraerr
inputcx300:
	dec	si
	call	hexincx
inputcx800:
	ret
;
;
;
fgetc:			;read 1 charctor
			; BX=handle
			;ret
			; ZR=EOF
			; AL=char
	dec	word ptr [filecnt]
	jnz	fgetc500
	push	cx
	push	dx
	mov	dx,offset hlpwork$
	mov	cx,BUFF_SIZE
	mov	ah,3fh		;read handle
	int	21h
	mov	[filecnt],ax
	mov	[fileptr],dx
	pop	dx
	pop	cx
	or	ax,ax
	jnz	fgetc500
	ret
fgetc500:
	push	si
	mov	si,[fileptr]
	lodsb
	mov	[fileptr],si
	pop	si
	ret
;
;
;
;strnicmpsd:
;	lodsb
;	call	case
;	mov	ah,al
;	mov	al,es:[di]
;	inc	di
;	call	case
;	cmp	al,ah
;	loopz	strnicmpsd
;	ret
;
;
;
deci_tok:		;alが +,-,/,.. か調べる
			;RET
			; ZR:いずれかの演算子
			; BX=offset(見つけた演算子のdeci_tok$の位置)
			; CY=1:2文字の演算子
			; CY=0:1文字の演算子
	push	cx
	push	di
	mov	di,offset deci_tok1$		;下から見る(2文字の演算子用)
	mov	cx,((offset deci_tok1$ - offset deci_tok$) / 5) -1
;deci_tok0:
	mov	ax,[si]
deci_tok200:
	sub	di,5
	cmp	byte ptr [di+1],0
	_if z
		cmp	[di],al
		clc
	_else
		cmp	[di],ax
		stc
	_endif
	_if nz
		loop	deci_tok200
		jmp	short deci_tok800
	_endif
	;pushf
	mov	bx,di
	;popf
deci_tok800:
	pop	di
	pop	cx
	ret
;
deci_tok$	label byte
		;	演算子	, calcのjmpアドレス , 演算子の優先順位
deci_tok0$:	dw2db	?	,calcend	,0
		dw2db	')'	,calckake	,1
		dw2db	'('	,calckaks	,1
		dw2db	'&'	,calcand	,2
		dw2db	'$'	,calcor		,2
		dw2db	'^'	,calcxor	,2
		dw2db	'+'	,calcadd	,3
		dw2db	'-'	,calcsub	,3
		dw2db	'*'	,calcmul	,4
		dw2db	'/'	,calcdiv	,4
		dw2db	'%'	,calcmod	,4
		dw2db	'++'	,calcinc	,5
		dw2db	'--'	,calcdec	,5
deci_tok1$	label byte
;
;
;
get_d_ram_98_0:
	inc	cx		;add	cl,1
get_d_ram_98:		;RAMドライブのユニット番号
	dec	bx
	cmp	bx,6ch
	jc	get_d_u800
	cmp	byte ptr [bx],8ah
	jz	get_d_ram_98_0
	cmp	byte ptr [bx],0
	jz	get_d_ram_98_0
	jmp	get_d_ram_98
;
get_drive_unit:		;ドライブ番号からunitを求める
			; AL=drive(A:0,B:1,...)
			;RET
			; AH=MEDIA(0:MFD,1:SFD,2:HD,3:RAM , ff:err)
			; CL=unit
			; CH=partition
	push	bx
	push	dx
	push	ds
	push	ax
	test	bl,ID2_IBM
	_if nz		;(IBM)
		cmp	al,2
		_if nc		;C:以上ならRAMかHDDとみなしてしまう
			add	al,80h - 2	;(80h=RAM|HDD UNIT 0)
		_endif
		mov	ah,15h		;read drive type
		mov	dl,al		;drive No. (80<FDD 80>=RAM|HDD)
		push	dx
		int	13h
		pop	dx
		mov	al,ah
		mov	ah,0ffh
		jc	short get_d_u800a	;エラーなら
		xor	cx,cx		;partition=0 unit=0
		or	al,al		;接続なし
		jz	short get_d_u800a
		mov	ah,0
		cmp	al,2		;MFD
		jz	short get_d_u200
		mov	ah,1
		cmp	al,1		;SFD
		jz	short get_d_u200
		mov	ah,3
		cmp	al,70h		;J31 HARD-RAM
		jz	short get_d_u200
		mov	ah,0ffh
		cmp	al,3		;HDD
		jnz	short get_d_u800a
		mov	ah,2
		mov	cx,0100h	;partition=1 unit=0
get_d_u200:
		mov	dh,al	;drive type
get_d_u220:
		mov	al,dl
		and	al,7fh
		or	al,al
		jz	short get_d_u800a
		dec	dl
		push	ax
		push	cx
		push	dx
		mov	ah,15h		;read drive type
		int	13h
		pop	dx
		_if c			;エラーなら
			mov	ah,0	;接続なしにしておく
		_endif
		cmp	ah,dh
		pop	cx
		pop	ax
		_if z
			;add	cx,0101h
			inc	cx	;inc cl(UNIT++)
		_endif
		jmp	get_d_u220
	_endif
	test	bl,ID2_NEC
	_if nz		;(PC98)
		mov	bx,60h
		mov	ds,bx
		mov	bx,6ch
		mov	ah,0
		add	bx,ax
		mov	al,[bx]
		xor	cx,cx		;partition=0,unit=0
		mov	ah,3
		cmp	al,08ah		;RAM(MX1STAR)
		jz	get_d_ram_98
		or	al,al		;RAM(最終接続ドライブ)
		jz	get_d_ram_98
		cmp	al,0e6h		;MELDISK.SYS
		jc	get_d_u350
		cmp	al,0efh
		ja	get_d_u350
		mov	cl,al
		sub	cl,0e6h
get_d_u800a:
		jmp	short get_d_u800
get_d_u350:
		mov	cl,al
		and	cl,0fh		;unit
		and	al,0f0h
		mov	ah,0
		cmp	al,90h		;MFD
		jz	short get_d_u800
		inc	ah
		cmp	al,70h		;SFD
		jz	short get_d_u800
		inc	ah
		cmp	al,80h		;HD(SASI)
		jz	get_d_u400
		cmp	al,0a0h		;HD(SCSI)
		jz	get_d_u400
		inc	ah
		cmp	al,0e0h		;RAM(NEC)
		jz	short get_d_u800
		mov	ah,0ffh
		jmp	short get_d_u800
get_d_u400:		;hd subroutine
		mov	al,[bx]
get_d_u450:
		cmp	bx,6ch
		jz	get_d_u700
		dec	bx
		cmp	al,[bx]	;同じ数値なら同じユニットでパーテーション有り
		jnz	get_d_u700
		inc	ch		;partition
		jmp	get_d_u450
	_endif
	test	bl,ID2_FMR
	_if nz		;(FM)
		mov	bx,40h
		mov	ds,bx
		lds	bx,ds:[0]
		mov	ah,0
		shl	al,1
		add	bx,ax
		mov	cl,[bx+1]
		mov	ch,0
		mov	ah,[bx]
		cmp	ah,2		;HD?
		jnz	short get_d_u800
		mov	ch,cl
		and	ch,0fh		;partition
		shr	cl,1		;unit
		shr	cl,1
		shr	cl,1
		shr	cl,1
get_d_u700:
		inc	ch		;inc partition
get_d_u800:
		pop	bx		;ax
		mov	al,bl
		pop	ds
		pop	dx
		pop	bx
		ret
	_endif
	ret		;念の為
;
;
;
makecrctable:		;始めにCRC tableを初期化
	xor	bx,bx
makecrctable200:
	mov	cl,16 - CHAR_BIT
	mov	ax,bx
	shl	ax,cl
	xor	dx,dx
makecrctable300:
	shl	ax,1
	jnc	makecrctable380
	xor	ax,CRCPOLY
makecrctable380:
	inc	dx
	cmp	dx,CHAR_BIT
	jc	makecrctable300
	mov	di,bx
	mov	word ptr [bx+di+crctable],ax
	inc	bx
	cmp	bx,UCHAR_MAX
	jna	makecrctable200
	ret
;
;
;
cmd_call:
	mov	bx,si		;文字列の開始位置
	cmp	byte ptr [si],'('
	_if z
		push	si
		inc	si
		mov	ah,1		;括弧の数
cmd_call200:
		lodsb
		cmp	al,CR
		_if z
			pop	si
			jmp	short cmd_call300
		_endif
		cmp	al,'('
		_if z
			inc	ah
			jmp	cmd_call200
		_endif
		cmp	al,')'
		jnz	cmd_call200
		dec	ah
		jnz	cmd_call200
		mov	byte ptr [si-1],CR	
		inc	bx
		pop	ax		;dummy (push si)
	_endif
cmd_call300:
	push	si	;文字列の終了位置
	mov	si,bx	;文字列の開始位置
	push	ds
	push	es
	xor	bp,bp		;BP=0(同じ所で処理するコマンドのフラグで使用)
	call	paraskip	;[SP][TAB]SKIP
	call	case
	cmp	al,CR		;これ以上パラメータがなければ Z=1
if debugflag
	call	main020		;debug用(call dx)
else
	call	dx 
endif
	pop	es
	pop	ds
	pop	si
	ret
;
;
;
cmd_search:		;コマンド名のサーチ
			; di=比較するべき文字列(str+NULL)
			;RET
			; Z=1:コマンド有り
			;	dx=jmpするアドレス
			; Z=0:コマンドなし
	push	si
	push	bp
	mov	bp,di

	mov	si,offset cmd
cmd_search200:
	mov	dx,word ptr [si]
	add	si,2
	mov	di,bp
	call	strcmpsd
	jz	cmd_search800
	or	al,al
	jz	cmd_search800
    ;次の CMDと比較するための処理
cmd_search300:
	lodsb
	or	al,al
	jnz	cmd_search300
	cmp	word ptr [si],1
	jnc	cmd_search200		;CMD がなくなってなければ
		;Z=0
cmd_search800:
	pop	bp
	pop	si
	ret
;
;
;
geterrorlevel:		;axに(command.comの)errorlevelを得る
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	push	ds
	mov	ah,30h		;get dos ver
	int	21h

	xor	bp,bp		;bpはsegを0にするのと後でoffsetでも使用

	mov	ds,bp
	mov	ds,word ptr ds:[22h*4 +2]	;Terminate Address
	mov	dx,ds
	cmp	ds:[16h],dx		;ここのセグメントが自分自身なら
	jz	geterr120		;多分command.com

	;23hはbatcpでフックするのでだめ
	;mov	ds,bp
	;mov	ds,word ptr ds:[23h*4 +2]	;CTRL-C break
	;mov	dx,ds
	;cmp	ds:[16h],dx		;ここのセグメントが自分自身なら
	;jz	geterr120		;多分command.com

	mov	ds,bp
	mov	ds,word ptr ds:[24h*4 +2]	;critical error handler
	mov	dx,ds
	cmp	ds:[16h],dx		;ここのセグメントが自分自身なら
	jz	geterr120		;多分command.com

	mov	ds,cs:[16h]	;ベクタから探せないし親セグメントのpspで我慢
	mov	dx,ds

geterr120:
	;mov	dx,ds
	mov	bx,100h

	cmp	ax,1603h	;dos 3.22
	jnz	geterr150
	add	bp,15-6
	xor	bx,bx
	jmp	short geterr200
geterr150:
	cmp	al,5
	jc	geterr200	;dos 4 later
	lds	bx,dword ptr ds:[114h]
	dec	bp
geterr200:
	mov	si,bx
	mov	cx,200h
geterr300:
	push	cx
	push	si
	mov	di,offset geterr100$
	mov	cx,4		;; 6
   repz	cmpsb
	pop	si
	pop	cx
	jz	geterr400
	inc	si
	loop	geterr300
	mov	ax,255
	jmp	endn
geterr400:
	cmp	bp,15-6		;dos 3.22
	jnz	geterr500
	push	es
	mov	di,[si+8]
	mov	es,[di]
	mov	di,[si+12]
	mov	dx,es:[di]
	pop	es
geterr500:
	add	si,6
	add	si,bp
	mov	si,[si]
	mov	ds,dx
	mov	al,[si]
	mov	ah,0
	pop	ds
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	ret
;
;
;
deci_chk:		;alが数字ならNC
	cmp	al,'0'
	_if nc
		cmp	al,'9'+1
		cmc
	_endif
	ret
;
;
;
chk2quote:		; ダブルクォーテーションで括られている時の前処理
	lodsb
	cmp	al,'"'
	_if nz
		dec	si
		ret
	_endif
	push	si
chk2quote400:
	lodsb
	cmp	al,CR
	_if z
		pop	si
		dec	si
		ret
	_endif
	cmp	al,'"'
	jnz	chk2quote400
	mov	byte ptr [si-1],CR
	pop	si
	ret
;
;
;
chdir_sub:		;chdir si
			; SI='PATH'+NULL
		;a:\bin\のようなとき最後の\を取る処理
	mov	dx,si
	call	j_strright1
	cmp	ax,'\'
	_if z
		mov	ax,si
		dec	ax
		cmp	ax,dx		;"\"だけなら取らない
		_if nz
			mov	byte ptr [si-1],0
		_endif
	_endif
	mov	ah,3bh		;CHG DIR
	int	21h
	mov	ax,0
	adc	ax,0		;if error then ax=1
	ret
;
;
;
chdrv_sub:	;logdisk
	cmp	byte ptr [si+1],':'
	_if z
		lodsw		;al=drv ah=':'
		or	al,20h
		sub	al,'a'
		mov	dl,al
		mov	ah,0eh		;SELECT DISK
		int	21h
	_endif
	ret
;
get_lastdelim:		;\path\name の name の位置を調べる
			; ds:si=フルパス名+NULL
			;RET
			; dx=nameの位置

	push	si
	mov	dx,si
	_do			; search the last delim
		lodsb		;
		call	chkpathchr
		_if e
			mov	dx,si
		_else
			call	iskanji
			adc	si,0
		_endif
		cmp	byte ptr [si],0
	_until z
	pop	si
	ret
;
;
drive_nom_set_bx:
	xor	bx,bx		;drive (0=current)
	cmp	byte ptr [si+1],':'
	_if z
		lodsw
		call	case
		sub	al,'A'-1
		mov	bl,al
	_endif
	ret
;
;
;
backslash_sub:			;backslash関連のsub
				;RET
				; dx=パラメーター先頭
				; Z=0:最後が\ではない	(DI=name+1)
				;  =1:最後が\		(DI=NULL+1)
				; ax=0
	call	paraset
backslash_sub1:			;di=文字列先頭(NULLで終わる)
	cmp	byte ptr [di],0
	_if z		;何も文字列がない場合
		mov	dx,di		;dx=nameまたはnullの位置
		inc	di
		xor	ax,ax
		cmp	al,1		;nz
		ret
	_endif
	mov	si,di
	call	get_lastdelim
	xchg	di,dx		;dx=nameまたはnullの位置
	xor	ax,ax
	scasb			;al=0
	ret
;
;
;
findfirst0:
	mov	dx,offset searchbuff
findfirst:
	mov	cx,7
findfirst1:
	mov	ah,4eh		;find first
	int	21h
	ret
;
;
;
getcmdpath:		;pathからコマンドを得る
			; ds:si=ファイル名(スペースまたはCR,NULLで終わる文字列)
			;RET
			; SI=文字列の次の位置
			; CY=0:見つかった
			;  DX=offset DTAADD+1e(ファイル名)
			;  BX=offset searchbuff(見つかったパス+検索ファイル名)
			;  DI=DX～PATHから代入した最後の位置+1
			; CY=1:見つからなかった
			;  AL=1:PATH内に無し
			;  AL=2:PATHの指定が不正

	push	es
	push	bp	;(BPは内部でDIの代わりで使う)
	call	paraset
	push	si

	mov	dx,offset ENV_PATH$
	call	envstrget1
			;es=env_seg
	mov	al,2
	jnz	getcmdpath_cy_ret
			;es:si=pathの内容の先頭
getcmdpath400:
	lods	byte ptr es:[si]
	or	al,al		;いきなりNULL?
	jz	getcmdpath_1_ret
	cmp	al,';'		;いきなり`;'?
	jz	getcmdpath400
	mov	di,offset searchbuff
getcmdpath500:
	mov	[di],al
	inc	di
	lods	byte ptr es:[si]
	cmp	al,';'
	jz	getcmdpath600
	or	al,al
	jnz	getcmdpath500
	dec	si		;次のループ用に戻しておく
getcmdpath600:
	mov	byte ptr [di],0
	push	si
	push	di
	push	es

	push	cs
	pop	es
	mov	di,offset searchbuff
	call	backslash_sub1

	pop	es
	pop	di
	pop	si
	_if nz
		cmp	byte ptr [di-1],':'
		_if nz
			mov	al,[path_chr]
			mov	[di],al
			inc	di
		_endif
	_endif

	mov	bp,di		;bp=PATHから代入した最後の位置+1
	call	getcmdpathsub
	jc	getcmdpath400
	mov	al,0
	clc

getcmdpath800:
	pop	si
	mov	di,bp
	pop	bp
	pop	es
	mov	bx,dx		;searchbuff
	mov	dx,offset dtaadd.DTA_NAME
	ret

getcmdpath_1_ret:
	mov	al,1
getcmdpath_cy_ret:
	stc
	jmp	getcmdpath800
;
;
;
getcmdpathsub0:		;ファイルの検索(PATH形式(COM,EXE.BAT))
			;RET
			; CY=0:ファイルあり(DTAにファイル名)
			; CY=1:ファイルなし
	mov	di,offset searchbuff
	mov	dx,di
getcmdpathsub:
	mov	bx,offset paraset$
	mov	ah,0
getcmdpathsub1:
	mov	al,[bx]
	inc	bx
	mov	[di],al
	inc	di
	cmp	al,'.'		;拡張子あり?
	_if z
		mov	ah,al
	_endif
	or	al,al
	jnz	getcmdpathsub1

	or	ah,ah
	_if nz
		call	findfirst0
	_else
		push	si
		push	es

		push	cs
		pop	es
		lea	bx,[di-1]
		mov	cx,3
		mov	si,offset comexebat$
getcmdpathsub2:
		mov	di,bx
		push	cx
		movsw
		movsw
		mov	al,0
		stosb
		call	findfirst
		pop	cx
		_if c
			loop	getcmdpathsub2
			stc
		_endif
		pop	es
		pop	si
	_endif
	ret
;
;
;
strend:			;ES:DIをnullまでscas
			;RET
			; DI=NULLの位置
			; cx=NUllまでの文字数
			; AL=0
	mov	al,0
	mov	cx,128
  repnz	scasb
	dec	di
	sub	cx,128
	not	cx
	ret
;
;
;
get1char:		;SIから1文字を得る
			; SI=文字(または\xで始る文字列)
			;RET
			; AL=文字
	lodsb
	cmp	al,'\'
	_if z
		lodsb
		call	case
		cmp	al,'X'
		_if z
			mov	cx,0ffffh
			mov	ax,0401h		;4桁
			call	hexin1
			mov	al,cl
		_else
			dec	si
			mov	al,'\'
		_endif
	_endif
	ret
;
;
;
stdout2nul:		;標準出力をnulにする
	mov	bx,1
	mov	ah,45h
	int	21h
	mov	[stdout2_stdout],ax

	mov	dx,offset nul$
	call	fopen
	mov	[stdout2_nul],bx

		;bx=handle "NUL"
	mov	cx,1
	mov	ah,46h
	int	21h

	ret
;
;
stdout2con:		;標準出力をconにする
	mov	bx,[stdout2_stdout]
	mov	cx,1
	mov	ah,46h
	int	21h

		;bx=stdout(DUP)
	call	fclose

	mov	bx,[stdout2_nul]
	jmp	fclose		;jp & ret
;
;
;
chkstdin:		;標準入力のチェック
			;RET
			; NZ(Z=0):リダイレクトではない
			; ZR(Z=1):リダイレクトされている
			; (BX=標準入力ハンドル)
	xor	bx,bx
	mov	ax,4400h
	int	21h
	test	dl,80h
	ret
;
;
vecthook_int_nec:
	pushf
	inc	byte ptr cs:[machinework + 0]
	popf
	jmp	dword ptr cs:[machinework+ 4]
;
vecthook_int_fmr:
	pushf
	inc	byte ptr cs:[machinework + 1]
	popf
	jmp	dword ptr cs:[machinework + 8]
;
vecthook_int_ibm:
	pushf
	inc	byte ptr cs:[machinework + 2]
	popf
	jmp	dword ptr cs:[machinework + 12]
;
;
vecthook_key_tbl	label byte
	dbdw	18h,	vecthook_int_nec	;; NEC
	dbdw	90h,	vecthook_int_fmr	;; FMR
	dbdw	16h,	vecthook_int_ibm	;; IBM
;
vecthook_clock_tbl	label byte
	dbdw	1ch,	vecthook_int_nec	;; NEC
	dbdw	96h,	vecthook_int_fmr	;; FMR
	dbdw	1ah,	vecthook_int_ibm	;; IBM
;
;
vect_chk:		;機種名を返す
			;RET
			; AL=0:NEC 1:FMR 2:IBM 0FF:UNKNOWN
	push	si
	mov	si,offset vecthook_key_tbl
	mov	al,0bh		;check keybuff
	call	vecthook_chk
	cmp	al,-1
	_if z			;KEYBIOSで取得できなかったらCLOCKBIOSでも
				;試してみる
		mov	si,offset vecthook_clock_tbl
		mov	al,2ch		;get time
		call	vecthook_chk
	_endif
	pop	si
	ret
;
;
;
vecthook_chk:		;割り込みからチェックして機種名を返す
			;(ばらばらにチェックするとたま～に変に割り込みが入る
			; のでちょっと面倒な処理にしてる)
			; SI=ベクタのテーブル
			; AL=int21hでのファンクションNo.
			;RET
			; AL=0:NEC 1:FMR 2:IBM 0FF:UNKNOWN
	mov	byte ptr [machinework+3],al

	push	si
	push	es
	mov	di,offset machinework + 4
	mov	cx,3
vecthook_chk200:
	lodsb
	mov	ah,35h		;get vect
	int	21h
	mov	[di],bx
	mov	[di+2],es
	add	di,4
	mov	ah,25h		;set vect
	mov	dx,[si]
	int	21h
	lodsw			;add si,2
	loop	vecthook_chk200
	pop	es

	mov	cx,5		;これだけ繰り返してもダメなら諦め
vecthook_chk400:
	push	cx

	mov	word ptr [machinework],0
	mov	byte ptr [machinework+2],0

	mov	ah,byte ptr [machinework+3]
	int	21h

	mov	ax,00ffh	;ah=やり直しflg, al=ret(機種名)番号
	xor	bx,bx
vecthook_chk600:
	cmp	byte ptr [machinework + bx],1
	_if nc
		inc	ah
		mov	al,bl
	_endif
	inc	bx
	cmp	bl,3
	jc	vecthook_chk600
	pop	cx
	cmp	ah,2
	_if nc		;2つ以上の割り込みが起きてたらやり直し
		loop	vecthook_chk400
		mov	al,255
	_endif

	pop	si
	push	ax

	mov	di,offset machinework + 4
	mov	cx,3
vecthook_chk700:
	push	ds
	lodsb
	lds	dx,[di]
	mov	ah,25h		;set vect
	int	21h
	pop	ds
	add	di,4
	lodsw			;add si,2
	loop	vecthook_chk700

	pop	ax
	ret
;
;
;$w
;
;==== COMMAND AREA ====
; CALL
;	DS:SI=PARAMETER OFFSET (NOW START ADD)
;	AL=DS:[SI](AL=CR:Z=1)
;
; RET
;	AL=RETURN CODE
;
;	セグメントを含むすべてのレジスタを破壊しても構わない
;	戻るには 'RET'か 'JMP ENDN'を(PRINTFで使うものはすべてRETを)使う
;
;
;$C
;
;----
;
;machine:
;		Ret=
;			150 : AX
;			160 : IBM
;			170 : J3100
;			180 : PC9801(24dot)
;			185 : PC9801(16dot)
;			 (180～189 : NEC PC)
;			190 : FM 24dot
;			195 : FM 16dot
;			198 : OASYS
;			199 : FM16B
;			 (190～199 : Fujitsu FM)
;			255 : 機械を未サポート
;	push	es
;	xor	ax,ax
;	mov	es,ax
;	mov	ax,es:[0076h]
;	cmp	ax,0f000h
;	jz	machine120
;	cmp	ax,0f400h
;	jz	machine120
;	cmp	ax,0f800h
;	jz	machine120
;	cmp	ax,0fd80h
;	jnz	machine150
;		;(PC98)
;machine120:
;	mov	ax,es:[0DCh*4]
;	cmp	ax,es:[0DCh*4+4]
;	jz	machine500		;NOT NEC
;	mov	al,ID_PC98N
;	test	byte ptr es:[0501h],08h		;HIRESO?
;	jz	machineret			;No
;	mov	al,ID_PC98H
;machineret:
;	mov	ah,0
;	pop	es
;	ret
;
;machine150:
;	mov	ax,es:[0afh*4]
;	xor	ax,es:[0aeh*4]
;	mov	bx,es:[0afh*4+2]
;	xor	bx,es:[0aeh*4+2]
;	or	ax,bx
;	jz	machine500	;INT AE,INT AFが同じ所を指していれば
;	mov	dx,2121h
;	mov	ah,0h		;JIS TO S-JIS
;	int	0afh
;	cmp	dx,8140h
;	jnz	machine500
;		;(FM)
;	mov	ah,0f0h		;get OASYS ID
;	int	0afh
;	jc	machine250	;not support
;	or	ah,ah
;	jnz	machine250
;	mov	al,ID_OASYS
;	jmp	machineret		;Yes
;machine250:
;	;mov	al,ID_OASYS
;	;cmp	byte ptr [di+5],30h	;OASYS ?(BIOS VER = 30H?)
;	;jz	machineret		;Yes
;
;	mov	di,offset machinework
;	mov	ah,5
;	int	0afh		;GET MACHINE
;	mov	al,ID_FM16B
;	jc	machineret	;16B L20以前の場合
;	cmp	byte ptr [di],0		;MACHINE ID
;	jz	machineret
;
;	mov	al,ID_FM16
;	test	byte ptr [di+3],2	;HIRESO?
;	jz	machineret
;	mov	al,ID_FM24
;	jmp	short machineret
;machine500:	;J31,IBM,AX
;	mov	al,0		;未サポート用
;	mov	ah,0Fh
;	int	10h
;	mov	dl,al
;	mov	al,ID_J31
;	cmp	dl,74h
;	je	machineret
;	cmp	dl,64h
;	je	machineret
;	cmp	dl,02
;	je	machine550
;	cmp	dl,03
;	je	machine550
;	mov	al,ID_UNKNOWN
;	cmp	dl,07
;	jne	machineret
;machine550:
;	mov	ax,5001h
;	int	10h
;	mov	al,ID_IBM
;	cmp	bx,51h
;	jne	machineret0a
;	mov	al,ID_AX
;machineret0a:
;	jmp	machineret

machine2:
;	Ret=BITで返す(オール00なら機種未サポート)
;		BIT7:	Reserve
;		BIT6:	1:IBM系			(40h)
;		BIT5:	1:PC98系		(20h)
;		BIT4:	1:FMR/FM16B/OASYS系	(10h)
;		BIT3:	Reserve
;		BIT2:	---+
;		BIT1:	   +-- (機種別に使用)
;		BIT0:	---+
;
;	FMR系(BIT4が1の時)
;		BIT2:			1:OASYS
;		BIT1:			1:FM16B
;		BIT0:	0:16DOT		1:24DOT
;
;	PC98系(BIT5が1の時)
;		BIT2:
;		BIT1:
;		BIT0:	0:Normal	1:Hireso
;
;	IBM系(BIT6が1の時)
;		BIT2:   -+ BIT0が1の時
;		BIT1:	-+		00:AX  01:J3100
;		BIT0:	0:PC/AT		1:not PC/AT
;
;
	call	vect_chk
	or	al,al
	jz	machine2_nec
	dec	al
	jz	machine2_fmr
	dec	al
	jz	machine2_ibm

	mov	al,ID2_UNKNOWN
machine2ret:
	mov	ah,0
	ret
;
machine2_nec:
	push	ds
	xor	ax,ax
	mov	ds,ax
	test	byte ptr ds:[0501h],08h		;HIRESO?
	pop	ds
	mov	al,ID2_NEC
	jz	machine2ret
	mov	al,ID2_NEC + ID2_NECHIRESO
	jmp	short machine2ret

machine2_fmr:
	mov	ah,0f0h		;get OASYS ID
	int	0afh
	_if nc
		or	ah,ah
		_if z
			mov	al,ID2_FMR + ID2_OASYS
			jmp	machine2ret		;Yes
		_endif
	_endif
	;mov	al,ID2_FMR + ID2_OASYS
	;cmp	byte ptr [di+5],30h	;OASYS ?(BIOS VER = 30H?)
	;jz	machine2ret		;Yes

	mov	di,offset machinework
	mov	ah,5
	int	0afh		;GET MACHINE
	mov	al,ID2_FMR + ID2_FM16B
	jc	machine2ret	;16B L20以前の場合
	cmp	byte ptr [di],0		;MACHINE ID
	jz	machineret

	mov	al,ID2_FMR
	test	byte ptr [di+3],2	;HIRESO?
	jz	machine2ret
	mov	al,ID2_FMR + ID2_FMR24
	jmp	short machine2ret

machine2_ibm:
	mov	al,0		;未サポート用
	mov	ah,0Fh
	int	10h
	mov	dl,al
	mov	al,ID2_IBM + ID2_J31 + ID2_NOTAT
	cmp	dl,74h
	je	machine2ret
	cmp	dl,64h
	je	machine2ret
	cmp	dl,02
	_if ne
		cmp	dl,03
		_if ne
			mov	al,ID2_UNKNOWN
			cmp	dl,07
			jne	short machine2ret
		_endif
	_endif
	mov	ax,5001h
	int	10h
	mov	al,ID2_IBM
	cmp	bx,51h
	jne	short machine2ret
	mov	al,ID2_IBM + ID2_AX + ID2_NOTAT
	jmp	short machine2ret
;
;
machine:
	call	machine2

	test	al,ID2_FMR
	_if nz
		mov	ah,ID_OASYS
		test	al,ID2_OASYS
		_if z
			mov	ah,ID_FM16B
			test	al,ID2_FM16B
			_if z
				mov	ah,ID_FM24
				test	al,ID2_FMR24
				_if z
					mov	ah,ID_FM16
				_endif
			_endif
		_endif
		jmp	short machineret
	_endif

	test	al,ID2_NEC
	_if nz
		mov	ah,ID_PC98H
		test	al,ID2_NECHIRESO
		_if z
			mov	ah,ID_PC98N
		_endif
		jmp	short machineret
	_endif

	test	al,ID2_IBM
	_if nz
		mov	ah,ID_IBM
		test	al,ID2_NOTAT
		_if nz
			and	al,00000110b
			mov	ah,ID_J31
			cmp	al,ID2_J31
			_if nz
				cmp	al,ID2_AX
				_if z
					mov	ah,ID_AX
				_else		;念の為
					mov	ah,ID_IBM	
				_endif
			_endif
		_endif
		jmp	short machineret
	_endif

	mov	ah,ID_UNKNOWN
machineret:
	mov	al,ah
	mov	ah,0
	ret
;
;
;
;---
;
help:
	pushf
	push	si
	mov	si,[swchl]
	or	si,si
	_if nz
		mov	dx,si
help200:
		lodsb
		call	spn_chk
		jnz	help200
		mov	byte ptr [si-1],0
		jmp	help300
	_endif
	push	ds
	mov	ds,ds:[2ch]	;環境のセグメント

	call	envskipend
	jz	help220

	push	cs
	pop	ds
	mov	si,offset batutyhlp$ -4
help220:
	add	si,4
	mov	di,offset hlpname$
help250:
	lodsb
	stosb
	or	al,al
	jnz	help250

	sub	di,4
	mov	ax,'LH'
	stosw		;"HL"
	mov	al,'P'
	stosb		;"P"

	pop	ds
	mov	dx,offset hlpname$
help300:
	call	fopen
	jnc	help400

	mov	dx,offset notfindhlp$
	jmp	errend
help400:
	mov	dx,offset hlpwork$
	mov	cx,8000h
	mov	ah,3fh		;READ HANDLE
	int	21h
	cmp	ax,8000h	;read bytes
	jc	help450

	mov	dx,offset hlptoobig$
	jmp	errend
help450:
	mov	di,ax
	add	di,offset hlpwork$
	cmp	byte ptr [di-1],1ah
	jnz	help460
	dec	di
help460:
	mov	byte ptr [di],0

	call	fclose

	pop	si
	popf

	jnz	help600

    ;ALL
	mov	si,offset hlpwork$
help500:
	lodsb
	or	al,al
	jz	help900
	call	psub
	jmp	help500

    ;KEY WORD
help600:
	mov	dx,si		;DX=KEYWORD
	call	nprintsp
	mov	byte ptr [si],0

	mov	si,dx
help620:
	mov	al,[si]
	call	case
	mov	[si],al
	inc	si
	or	al,al
	jnz	help620

	mov	si,offset hlpwork$
help630:
	lodsb
	or	al,al
	jz	help900
	cmp	al,LF
	jnz	help630

	call	spskip
	jz	help900
	cmp	al,'*'
	jz	help635
	cmp	al,':'
	jz	help635
	cmp	al,'!'
	jnz	help630
help635:
	inc	si
	call	spskip
	jz	help900

	push	si
	mov	di,dx
help640:
	mov	al,[di]
	or	al,al
	jz	help650
	cmp	[si],al
	jnz	help650
	inc	di
	inc	si
	jmp	help640
help650:
	pop	si
	_if z
		cmp	byte ptr [swchu],0
		jz	help700
	_else
		cmp	byte ptr [swchu],0
		jnz	help700
	_endif
	jmp	help630

help700:
	dec	si
	cmp	byte ptr [si],LF	;キーワードの先頭に戻す
	jnz	help700
help750:
	lodsb
	or	al,al
	jz	help900
	call	psub
	cmp	al,LF
	jnz	help750
	push	si
	call	spskip
	pop	si
	cmp	al,LF
	jnz	help750
	jmp	help630
help900:
	xor	ax,ax
	ret
;
;---
;
echo:
	call	hyojie
	xor	ax,ax
	ret
;
;---
;
keywait:
	jz	keywait800
	mov	cx,0ffffh
	call	calc0
	jz	keywait800
keywait200:
	mov	[keywaitc],cx
	mov	byte ptr [keywaitf],1
	jmp	main150

keywait800:
paraforget:
	mov	dx,offset paraforget$
	jmp	errend
;
;---
;
@keynum:
	inc	bp
keynum:
	call	hyoji
keynum200:
	call	keyin
	call	deci_chk
	jc	keynum200
	call	keyecho
	sub	al,'0'
	mov	ah,0
	ret
;
;---
;
@keyyesno:
	inc	bp
keyyesno:
	call	hyoji
keyyesno200:
	call	keyin_w
	or	ah,ah
	_if z
		cmp	al,'Y'
		jz	keyyesno500
		cmp	al,'y'
		jz	keyyesno500
		cmp	al,'ﾝ'
		jz	keyyesno500
		cmp	al,'N'
		jz	keyyesno600
		cmp	al,'n'
		jz	keyyesno600
		cmp	al,'ﾐ'
		jz	keyyesno600
	_else
		cmp	ax,'Ｙ'
		jz	keyyesno500
		cmp	ax,'ｙ'
		jz	keyyesno500
		cmp	ax,'Ｎ'
		jz	keyyesno600
		cmp	ax,'ｎ'
		jz	keyyesno600
	_endif
	jmp	keyyesno200
keyyesno500:		;'Y'
	call	keyecho_w
	xor	ax,ax
	ret

keyyesno600:		;'N'
	call	keyecho_w
	mov	ax,1
	ret
;
;---
;
keyretspc:
	call	hyoji
keyretspc200:
	call	keyin_w
	or	ah,ah
	_if z
		cmp	al,CR
		jz	keyretspc500
		cmp	al,20h
		jz	keyretspc600
	_else
		cmp	ax,8140h
		jz	keyretspc600
	_endif
	jmp	keyretspc200

keyretspc500:		;[RET]
	xor	ax,ax
	ret

keyretspc600:		;[SPACE]
	mov	ax,1
	ret
;
;---
;
keyescany:
	call	hyoji
	call	keyin
	cmp	al,1bh
	mov	ax,0
	jz	keyescany800
	inc	ax
keyescany800:
	ret
;
;---
;
@keycode:
	inc	bp
keycode:
	call	hyoji
	call	keyin
	call	keyecho
	mov	ah,0
	ret
;
;---
;
@keylist:
	inc	bp
keylist:
	mov	dx,si
	call	paraset
				;di=key_list先頭
	mov	al,255
	cmp	dx,si		;1文字もキーの指定なし?
	jz	keylist800	;Yes
	call	paraskip
	call	hyoji
keylist200:
	call	keyin
	mov	si,di
	mov	cl,0		;cl=loop count
	mov	ch,al		;ch=original key ode save
	call	case
	mov	dl,al		;dl=compare key code
keylist400:
	inc	cl
	lodsb
	or	al,al
	jz	keylist200
	call	case
	cmp	dl,al
	jnz	keylist400
	mov	al,ch
	call	keyecho
	mov	al,cl
keylist800:
	mov	ah,0
	ret
;
;---
;			kana	cap	graph	ctrl	shift	alt
shift98$	db	4,	2,	8,	10h,	1,	8
shiftfm$	db	0bh,04h,0ah,20h,0ah,40h,0ah,04h,0ah,18h,0bh,10h
shiftibm$	db	0,	0,	0,	4,	3,	8
;
;
;
altkey:
	inc	bp
shiftkey:
	inc	bp
ctrlkey:
	inc	bp
graphkey:
	inc	bp
capkey:
	inc	bp
kanakey:
	call	machine2
	test	al,ID2_NEC
	_if nz
		;(PC98)
		mov	ah,2
		int	18h
		mov	ah,ds:[bp+shift98$]
		jmp	short shiftkey_go
	_endif
	test	al,ID2_FMR
	_if nz
		mov	ah,0ah
		mov	di,offset searchbuff
		int	90h
		add	bp,bp
		mov	ax,word ptr ds:[bp+shiftfm$]	;ah=KEY_BIT al=add
		push	ax
		mov	ah,0
		add	di,ax
		pop	ax
		mov	al,[di]
		jmp	short shiftkey_go
	_endif
	test	al,ID2_IBM
	_if nz
		mov	ah,2
		int	16h
		mov	ah,ds:[bp+shiftibm$]
		jmp	short shiftkey_go
	_endif
	mov	ax,255
	ret
;
shiftkey_go:
	test	al,ah
	mov	ax,0
	_if nz
		inc	ax
	_endif
	ret
;
;---
;
keybuff:
	mov	ah,0bh
	int	21h
	mov	ah,0
	ret
;
;---
;
keyclear:
	mov	ax,0c00h
	int	21h
	xor	ax,ax
	ret
;
;---
;
dskready:
	call	errsubset
	call	paraset_al
	jnz	dskready300

	mov	ah,19h		;get curent disk
	int	21h
			;al=drive(A=0,B=1..)
	add	al,'A'
dskready300:
	mov	[dskreadytmp$],al
	mov	dx,offset dskreadytmp$
	xor	cx,cx		;Attrib
;	mov	ah,5ah		;Create Temp File
	mov	ah,5bh
	int	21h

	jc	dskready400

	mov	bx,ax
	call	fclose

	mov	dx,offset dskreadytmp$
	mov	ah,41h		;Delete Entry
	int	21h

	mov	al,0
	jmp	short dskready700

dskready400:

	mov	bx,[errcodedi]
	mov	al,11
	cmp	bl,1
	jz	dskready700
	dec	al		;AL=10
	cmp	bl,2
	jz	dskready700
	dec	al		;AL=9
	or	bl,bl
	jz	dskready700
	mov	al,1

dskready700:
	mov	ah,0
	jmp	errsubreset	;JP & RET
;
;---
;
chkdsksize:
;	inc	bp
	mov	bp,1
chkdskfree:
	call	errsubset
	mov	dl,0
	mov	cx,100
;	cmp	al,CR
	jz	chkdskfree200
	mov	cx,0ffffh
	call	calc0
	call	paraset_al
	mov	dl,0
	jz	chkdskfree200
	or	al,20h
	sub	al,('a'-1)
	mov	dl,al
chkdskfree200:
	push	cx
	mov	ah,36h		;GET DSK FREE SPACE
	int	21h
	cmp	ax,0ffffh
	_if z
		pop	cx
		jmp	chkdskfree800
	_endif
	dec	bp
	_if z
		xchg	bx,dx		;mov bx,dx
	_endif
	mul	cx
	mul	bx

	call	convbtokb
	pop	cx
	mov	bx,ax
	mov	ax,0
	or	dx,dx
	jnz	chkdskfree800
	cmp	cx,bx
	jna	chkdskfree800
	inc	ax
chkdskfree800:
	jmp	errsubreset	;JP & RET
;
;---
;
chkmemsize:
;	inc	bp
	mov	bp,1
chkmemfree:
	mov	cx,100
;	cmp	al,CR
	jz	chkmemfree200
	mov	cx,0ffffh
	call	calc0
	cmp	cx,0ffffh
	jz	getbuver
chkmemfree200:
	mov	ax,ds:[2]
	dec	bp
	jz	chkmemfree250
	mov	bx,cs
	sub	ax,bx
chkmemfree250:
	push	cx
	mov	cl,6
	shr	ax,cl

	pop	cx
	mov	bx,ax
	mov	ax,0
	cmp	cx,bx
	jna	chkmemfree800
	inc	ax
chkmemfree800:
	ret
;
;
getbuver:
	mov	ax,VERNUM
	ret
;
;---
;
dspdsksize:
;	inc	bp
	mov	bp,1
dspdskfree:
	call	errsubset
	call	paraset_al
	mov	dl,0
	jz	dspdskfree200
	or	al,20h
	sub	al,('a'-1)
	mov	dl,al
dspdskfree200:
	mov	ah,36h		;GET DSK FREE SPACE
	int	21h
	cmp	ax,0ffffh
	jz	dspdskfree800
	dec	bp
	_if z
		xchg	bx,dx		;mov bx,dx
	_endif
	mul	cx		;1.10.1d
	mul	bx

	call	convbtokb
	call	envdecipr16
	xor	ax,ax
dspdskfree800:
	jmp	errsubreset	;JP & RET
;
;---
;
dspmemsize:
	inc	bp
dspmemfree:
	mov	ax,ds:[2]
	dec	bp
	jz	dspmemfree250
	mov	bx,cs
	sub	ax,bx
dspmemfree250:
	mov	cl,6
	shr	ax,cl
	call	envdecipr8
	xor	ax,ax
	ret
;
;---
;
seterrorlevel:
	mov	ax,0
	jz	seterr800
	mov	cx,255
	call	calc0
	mov	ax,cx
seterr800:
	ret
;
;---
;
dsperrorlevel:
	call	geterrorlevel
	jmp	envdecipr8		;JP & RET
;
;---
;
run:
	call	paraskip
run200:
	mov	di,offset para_str + 1
	jz	run500

	mov	al,[switchchar]
	mov	ah,'C'
	stosw
	mov	al,' '
	stosb
run300:
	lodsb
	cmp	al,CR
	jz	run400
	cmp	al,'\'
	jnz	run320
	lodsb
	cmp	al,'&'
	jz	run350
	mov	al,'\'
	dec	si
	jmp	short run350
run320:
	cmp	al,'&'
	jnz	run350
	lodsb
	cmp	al,'&'
	jnz	run400
run350:
	stosb
	jmp	run300
run400:
	dec	si
run500:
	mov	byte ptr [di],CR
	push	si
	sub	di,offset para_str + 1
	mov	ax,di
	mov	byte ptr [para_str],al
	call	execcoms
	pop	si
	call	paraskip
	jnz	run200
	xor	ax,ax
	ret
;
;---
;
clockdate:
dspdate:
	call	clockyear
	call	envdeci2
	mov	al,'/'
	call	envpsub
	call	clockmonth
	call	envdeci2
	mov	al,'/'
	call	envpsub
	call	clockday
	call	envdeci2
	xor	ax,ax
	ret
;
;
clocktime:
dsptime:
	call	clockhour
	call	envdeci2
	mov	al,':'
	call	envpsub
	call	clockminute
	call	envdeci2
	mov	al,':'
	call	envpsub
	call	clocksecond
	call	envdeci2
	xor	ax,ax
	ret
;
;
dspclock:
	call	dspdate
	mov	al,' '
	call	envpsub
	call	dsptime
	xor	ax,ax
	ret
;
;
clockymd:
	call	clockyear
	push	dx
	push	dx
	mov	cl,10
	div	cl
	mov	al,ah
	call	hexprsub
	pop	dx
	mov	al,dh
	call	hexprsub
	pop	ax
	xor	ah,ah
	cmp	al,10
	jnc	clockymd400
	push	ax
	mov	al,'0'
	call	envpsub
	pop	ax
clockymd400:
	call	envdecipr8
	xor	ax,ax
	ret

clockyearmonth:
	call	clockyear
	push	dx
	call	envdecipr8
	pop	ax
	xchg	al,ah
	call	hexprsub
	xor	ax,ax
	ret

clockyear:
	call	dosgetday
	mov	ax,cx
	sub	ax,2000
	jnc	clockyear700
	add	ax,100
clockyear700:
	ret

clockmonth:
	call	dosgetday
	mov	al,dh
clock900:
	mov	ah,0
	ret

clockday:
	call	dosgetday
	mov	al,dl
	jmp	clock900

clockweek:
	call	dosgetday
	jmp	clock900
;
;---
;
clockhour:
	call	dosgettime
	mov	al,ch
	jmp	clock900

clockminute:
	call	dosgettime
	mov	al,cl
	jmp	clock900

clocksecond:
	call	dosgettime
	mov	al,dh
	jmp	clock900
;
;---
;
timewait:
	mov	cx,3
	jz	timewait200
	mov	cx,0ffffh
	call	calc0
	jcxz	timewait800
timewait200:
	push	cx
	mov	ah,2ch		;GET TIME
	int	21h
	mov	bl,dh		;DH=SEC
	pop	cx
timewait300:
	push	cx
timewait310:
	mov	ah,0bh		;K/B STATUS CHECK(for ^C BREAK)
	int	21h

	mov	ah,2ch
	int	21h
	cmp	bl,dh
	jz	timewait310
	mov	bl,dh
	pop	cx
	loop	timewait300
timewait800:
	xor	ax,ax
	ret
;
;---
;
curdrv:
	call	paraset_al
	jnz	curdrv300
curdrv2:
	mov	ah,19h		;GET CUR DISK
	int	21h
	add	al,'A'
curdrv300:
	call	case
	call	envpsub
	mov	al,':'
	call	envpsub
	xor	ax,ax
	ret
;
;---
;
curdrvpath:
	push	si
	call	curdrv
	pop	si
 ;	JMP	CURPATH
;---
curpath:
	call	paraset_al
	mov	dl,0
	jz	curpath300
	call	case
	sub	al,('A'-1)
	mov	dl,al
curpath300:		;CALL FROM XCDD
	call	errsubset
	mov	si,offset searchbuff
	mov	byte ptr [si],0
	push	si
	mov	ah,47h		;GET CUR PATH
	int	21h

curpath400:
	lodsb
	or	al,al
	jz	curpath500
	call	iskanji
	adc	si,0
	call	chkpathchr
	jnz	curpath400
	mov	al,[path_chr]
	mov	[si-1],al
	jmp	curpath400
curpath500:
	mov	al,[path_chr]
	call	envpsub

	pop	dx
	call	envprintn
curpath800:
	xor	ax,ax
	jmp	errsubreset	;JP & RET
;
;
;
curpath1:
	call	curpath
curpath1_0:
	cmp	byte ptr [searchbuff],0		;ルートなら
	jz	curpath800
	mov	al,[path_chr]
	call	envpsub
	jmp	curpath800
;
curdrvpath1:
	call	curdrvpath
	jmp	curpath1_0
;
;
;
dspbatfullname:		;2
	inc	bp
dspbatdrvpath:		;1
	inc	bp
dspbatdrv:
	cmp	byte ptr [endjmp],0cdh
	_if z		;; 普通のバッチ
		call	getbatseg
		jc	dspbat800
		mov	cx,128
		xor	di,di
dspbat200:
		mov	al,'.'
	  repnz	scasb
		jnz	dspbat800
		push	cx
		push	di
		mov	si,offset bat$ + 1
		mov	cx,3
	  repz	cmpsb
		pop	di
		pop	cx
		jnz	dspbat200

		std
		mov	al,':'
		mov	cx,128
	  repnz	scasb
		cld
		jnz	dspbat800
	_else		;; batcp取り込み中
		mov	es,ds:[10eh]	;親(batcp)のセグメントアドレス
		mov	es,es:[2ch]	;環境エリア
		;mov	es,ds:[2ch]	;自分自身の環境エリア
		xor	ax,ax
		mov	di,ax
		cmp	byte ptr es:[di+5],21h	;ICB?
		_if z
			add	di,32
		_endif
		mov	cx,8000h
dspbat310:
	  repnz	scasb
		jnz	dspbat800
		scasb
		jnz	dspbat310
		cmp	word ptr es:[di],1
		jnz	dspbat310
		scasw		;add di,2
	_endif

	push	ds
	push	es
	pop	ds
	pop	es
	mov	si,di
	mov	di,offset searchbuff
	push	di
	mov	cx,256 / 2
   rep	movsw
	push	cs
	pop	ds
	pop	si		;si=searchbuff
	call	j_strupr
	lodsb
	call	envpsub
	lodsb
	call	envpsub
	or	bp,bp
	_if nz
		call	get_lastdelim
		mov	di,dx
		cmp	byte ptr [di-2],':'
		_if nz
			dec	dx
		_endif
dspbat500:
		cmp	si,dx
		_if c
			lodsb
			call	envpsub
			jmp	dspbat500
		_endif
	_endif
	cmp	bp,2
	_if nc
		mov	dx,si
		call	envprintn
	_endif
	xor	ax,ax
	ret
dspbat800:
	mov	ax,255
	ret
;
;---
;
getdrv:
	mov	ah,19h		;GET CUR DISK
	int	21h
	mov	ah,0
	ret
;
;---
;
cdd:
	mov	al,255
	jz	cdd800

	call	paraset_si
	call	chdrv_sub
	call	chdir_sub
cdd800:
	mov	ah,0
	ret
;
;---
;
xcdd:
	call	envsave
	mov	byte ptr [swchd],1

	push	si
	mov	di,offset xcddtmp$
	call	envsetname
	pop	si

	call	curdrv2

	call	paraset_si
	call	chdrv_sub

	push	si
	mov	dl,0
	call	curpath300
	call	envset
	pop	si
xcdd700:		;; jmp from pushd
	call	chdir_sub
	jmp	envload		;jp & ret
;
;---
;
xpop:
	mov	dx,offset xcddtmp$
	call	envstrget1
	mov	al,1
	jnz	xpop800

	push	es
	pop	ds
	mov	dx,si
	add	dx,2
	mov	ah,3bh		;CHG DIR
	int	21h
	mov	al,1
	jc	xpop800

	lodsb
	or	al,20h
	sub	al,'a'
	mov	dl,al
	mov	ah,0eh		;SELECT DISK
	int	21h

	mov	al,0
xpop800:
	mov	ah,0
	ret
;
;---
;
@lineinput:
	inc	bp
lineinput:
	call	hyoji

	or	bp,bp
	_if nz
		call	stdout2nul
	_endif

	call	chkstdin
	mov	si,offset searchbuff
	_if nz
		mov	byte ptr [si],129
		mov	dx,si
		mov	ah,0ah		;STRINGS INPUT
		int	21h
	_else
		lea	dx,[si+2]
		mov	cx,128
		mov	ah,3fh		;read handle
		int	21h
		mov	bx,ax
		mov	byte ptr [si+bx+2],CR
	_endif

	or	bp,bp
	_if nz
		call	stdout2con
	_endif

	add	si,2
	mov	cl,0
lineinput300:
	lodsb
	cmp	al,CR
	jz	lineinput800
	call	envpsub
	inc	cl
	jmp	lineinput300
lineinput800:
	mov	al,cl
	mov	ah,0
lineinput900:		;jmp from calc
	ret
;
;---
;
calc_tok	dw 0		;演算子
calc_kak	dw 0		;括弧の数
;
;
calc0:		;
	push	dx
	push	cx
	call	calc020
	pop	dx
	cmp	cx,dx
	pop	dx
	ja	decimaxovr
	jmp	paraskip
;
calc:		;RET CX=NUM
	mov	ax,255
	jz	short lineinput900
calc020:
	call	envsave
	mov	[calc_kak],0		;括弧の数
	call	calc040
	cmp	[calc_kak],0
	jnz	kakkoerr
	call	envload
	mov	ax,cx
calc_ret:
	ret
;
calc040:
calc042:		;括弧の時ここにjmp
	mov	bx,offset deci_tok0$	;演算子
	xor	cx,cx		;値

	mov	[calc_tok],bx		;演算子

	call	paraskip
	call	deci_tok
	jnz	calc050
		;いきなり演算子なら
calc045:		;ここから再起呼び出しされる-1
	call	envinit
	jmp	short calc400

calc050:		;ここから再起呼び出しされる-2
	call	paraskip

	call	envinit
	call	calcget
calc300:
	call	deci_tok
	jnz	calc_ret
calc400:
	cmp	al,'('
	_if z
		inc	[calc_kak]
		inc	si
		push	[calc_tok]
		call	calc042
		pop	[calc_tok]
		inc	si
		call	paraskip
		jmp	calc300
	_endif
	cmp	al,')'
	_if z
		dec	[calc_kak]
		_if c
calckaks:
calckake:		;)
kakkoerr:		;(
			mov	dx,offset kakkoerr$
			jmp	errend
		_endif
		ret
	_endif

	push	ax
	mov	di,[calc_tok]
	mov	al,[di+4]
	mov	ah,[bx+4]
	cmp	ah,al
	pop	ax
	jna	calc_ret

	call	deci_tok
	mov	dx,0
	adc	dx,1		;2文字の演算子ならCYが立っている
	add	si,dx
	push	cx
	push	bx
;	push	[calc_tok]
;	mov	[calc_tok],bx		;演算子
	xchg	bx,[calc_tok]
	push	bx
	call	paraskip
	_if nz		; 終わりじゃなければ
		call	deci_tok
		_if z	; その後また演算子なら
			cmp	dx,1
			_if z		;1文字演算子なら
				xor	cx,cx
			_endif
			call	calc045
		_else
			;xor	cx,cx
			call	calc050
		_endif
	_endif
	pop	[calc_tok]
	pop	bx
	pop	dx		;cx

	call	word ptr [bx+2]
	call	paraskip
	cmp	al,')'
	jz	short calcend_ret
	jmp	calc300
;
;
;
calcend:
	pop	ax		;call stack
calcend_ret:
	ret
calcand:		;&
	and	cx,dx
	ret
calcor:			;$
	or	cx,dx
	ret
calcxor:		;^
	xor	cx,dx
	ret
calcadd:		;+
	add	cx,dx
	ret
calcsub:		;-
	xchg	cx,dx
	sub	cx,dx
	ret
calcmul:		;*
	mov	ax,cx
	mul	dx
	mov	cx,ax
	ret
calcdiv0:		;/ , %
	jcxz	calcdiv800
	mov	ax,dx
	xor	dx,dx
	div	cx
	mov	cx,ax
calcdiv800:
	ret
calcdiv:		;/
	call	calcdiv0
	ret
calcmod:		;%
	call	calcdiv0
	mov	cx,dx
	ret
;
calcinc:
	inc	cx	;++
	jmp	calcset
	ret
calcdec:
	dec	cx	;--
calcset:
	cmp	word ptr [envcnt],0
	_if nz
		push	cx
		mov	byte ptr [swchd],1
		mov	ax,cx
		call	envdecipr8
		call	envset
		pop	cx
	_endif
	ret
;
;---
;
random:
	mov	cx,10
	jz	random200
	mov	cx,0ffh
	call	calc0
	_if nz
		push	cx
		mov	cx,0ffh
		call	calc0
		mov	[random_i],cl
		pop	cx
	_endif
random200:
	push	cx
	call	clockminute
	push	ax
	call	clocksecond
	pop	dx
	add	al,[random_i]
	mov	dh,al
	add	dx,3
	mov	ax,0e5dh
	mul	dx
	pop	cx
	mul	cx
	mov	al,dl
	mov	ah,0
	ret
;
;---
;
timestamp:
	call	errsubset
	jz	timestamp800
	call	paraset
	jz	timestamp800
	call	paraskip
	jz	timestamp800
	mov	dx,di
	call	fopen
	jnc	timestamp300
	mov	al,10
timestamp250:
	cmp	bx,2		;FILE not find ?
	jz	timestamp700
	add	al,40
	jmp	short timestamp700
timestamp300:
	mov	ax,5700h	;GET FILE CLOCK(DX=DATE,CX=TIME)
	int	21h
	mov	word ptr [machinework],dx
	mov	word ptr [machinework+2],cx
	call	fclose

	call	paraset
	mov	dx,di
	call	fopen
	mov	al,20
	jc	timestamp250
	mov	ax,5700h	;GET FILE CLOCK(DX=DATE,CX=TIME)
	int	21h
	mov	word ptr [machinework+4],dx
	mov	word ptr [machinework+6],cx
	call	fclose

	mov	si,offset machinework
	mov	di,[si]		;FILE1 DATE
	mov	cx,[si+2]	;FILE1 TIME
	mov	dx,[si+4]	;FILE2 DATE
	mov	bx,[si+6]	;FILE2 TIME

	cmp	di,dx
	mov	al,1
	ja	timestamp700
	mov	al,2
	jc	timestamp700
	cmp	cx,bx
	mov	al,1
	ja	timestamp700
	mov	al,2
	jc	timestamp700
	mov	al,0
timestamp700:
	mov	ah,0
	jmp	errsubreset		;JP & RET
timestamp800:
	call	errsubreset
	jmp	paraerr
;
;---
;
update:
	push	si
	call	timestamp
	pop	si
	cmp	al,1
	jz	updatecopy300
	cmp	al,20
	jnz	updatecopy800
updatecopy300:
	push	ax
	push	si
	mov	si,offset copy$
	call	strcpysd
	pop	si
	call	strcatsd
	mov	si,offset paraset$
	call	run
	cmp	al,255
	pop	ax
	jnz	updatecopy800
	mov	al,255
updatecopy800:
	mov	ah,0
	ret
;
;---
;
flabel:
	call	errsubset
	call	paraset_si2
	call	wildcardsub

	mov	ah,4eh
	mov	cx,8
	int	21h
	mov	al,255
	jc	flabel800

	push	si

	mov	si,offset dtaadd.DTA_NAME
	mov	di,si
	mov	cx,13
flabel200:
	lodsb
	inc	di
	dec	cx
	or	al,al
	jz	flabel240
	cmp	al,'.'
	jnz	flabel200
	dec	di
	inc	cx
flabel220:
	lodsb
	stosb
	dec	cx
	or	al,al
	jnz	flabel220
flabel240:
  rep	stosb		;終端までNULLを入れる
	pop	si

	call	paraskip_0
	jz	flabel500

;	call	paraset		;di=paraset$
	mov	di,si

	mov	si,offset dtaadd.DTA_NAME
	call	j_strupr
	xchg	si,di
	call	j_strupr
flabel250:
	lodsb
	scasb
	jnz	flabel280
	or	al,al
	jnz	flabel250
	jmp	short flabel800
flabel280:
	cmp	al,'*'
	jz	flabel300
	cmp	al,'?'
	jz	flabel250
flabel290:
	mov	ax,1
	ret
flabel300:
	lodsb
	mov	cx,13
  repnz	scasb
	jnz	flabel290
	or	al,al
	jnz	flabel250
	jmp	short flabel800
flabel500:		;volume label 表示
	mov	dx,offset dtaadd.DTA_NAME
	call	envprintn
	xor	ax,ax
flabel800:
	mov	ah,0
	jmp	errsubreset
;
;
;
volumeserial:
	call	errsubset
	call	paraset_si2
	call	drive_nom_set_bx
	mov	ax,440dh
	mov	cx,0866h		;get media id
	mov	dx,offset searchbuff
	int	21h
	mov	al,255
	jc	volumeserial800
	mov	di,dx

	cmp	byte ptr [si],0
	_if z
		mov	ax,[di+4]
		call	hexprax
		mov	al,'-'
		call	envpsub
		mov	ax,[di+2]
		call	hexprax
volumeserial_0:
		mov	al,0
	_else
		call	hexincx
		cmp	al,'-'
		jnz	volumeserial_1
		inc	si
		mov	bx,cx
		call	hexincx
		cmp	[di+4],bx
		jnz	volumeserial_1
		cmp	[di+2],cx
		jz	volumeserial_0
volumeserial_1:
		mov	al,1
	_endif
volumeserial800:
	mov	ah,0
	jmp	errsubreset
;
;---
;
setvolumeserial:	;ボリュームシリアル番号の設定
			;setvolumeserial [d:]1234-fd98
			;ret
			;  0:正常終了
			;255:エラー
	mov	al,255
	jz	setvolser900
	call	errsubset
	call	paraset_si2
	call	drive_nom_set_bx

	mov	ax,440dh
	mov	cx,0866h		;get media id
	mov	dx,offset searchbuff
	int	21h
	mov	al,255
	jc	setvolser800
	mov	di,dx

	call	hexincx
	cmp	al,'-'
	jnz	setvolser_255
	inc	si
	mov	[di+4],cx
	call	hexincx
	mov	[di+2],cx

	mov	ax,440dh
	mov	cx,0846h		;set media id
	;mov	dx,offset searchbuff
	int	21h
	mov	al,0
	_if c
setvolser_255:
		mov	al,255
	_endif
setvolser800:
	mov	ah,0
	jmp	errsubreset
;
setvolser900:
	mov	ah,0
	ret
;
;---
;
filesize:
	jz	paraforget
	call	errsubset
	call	paraset
	mov	dx,di
	call	fopen
	mov	al,255
	jc	filesize800
	xor	cx,cx
	mov	dx,cx
	mov	ax,4202h		;move pointer to end
	int	21h			;ret dx:ax=pointer

	push	ax
	call	fclose
	call	paraskip
	inc	si
	call	case
	cmp	al,'M'
	jnz	filesize260
	pop	ax
	call	convbtomb
	jmp	short filesize280
filesize260:
	cmp	al,'B'
	jz	filesize300
	dec	si
	pop	ax
	call	convbtokb
filesize280:
	push	ax
filesize300:
	call	paraskip
	pop	ax
	jnz	filesize500

	or	dx,dx
	jz	filesize400
	mov	ax,65535		;65536以上のサイズ
filesize400:
	jmp	errsubreset

filesize500:	;サイズの比較
	push	ax
	push	dx
	mov	cx,0ffffh
	call	calc0
	pop	dx
	pop	ax
	or	dx,dx
	;;jnz	filesize400
	jnz	filesize700		;#1.09α.2f
	cmp	ax,cx
	mov	al,0
	jc	filesize800
	mov	al,1
	jz	filesize800
filesize700:
	mov	al,2
filesize800:
	mov	ah,0
	jmp	errsubreset
;
;---
;
fileline:
	jz	paraforget
	call	errsubset
	call	paraset
	mov	dx,di
	call	fopen
	mov	al,255
	jc	fileline800

	push	si

	xor	cx,cx
	;call	fgetc
	;jz	fileline400
	;inc	cx
	;jmp	short fileline240
fileline200:
	call	fgetc
	jz	fileline400
;fileline240:
	cmp	al,LF
	jnz	fileline200
	cmp	cx,-1
	jz	fileline200
	inc	cx
	jmp	fileline200

fileline400:
	pop	si

	push	cx
	call	fclose
	call	paraskip
	pop	ax
	jnz	fileline500
	jmp	errsubreset

fileline500:
	push	ax
	mov	cx,0ffffh
	call	calc0
	pop	ax
	cmp	ax,cx
	mov	al,0
	jc	fileline800
	mov	al,1
	jz	fileline800
	inc	al
fileline800:
	mov	ah,0
	jmp	errsubreset
;
;---
;
filecount:
	call	errsubset
	call	paraset_si2
	call	wildcardsub
	call	paraskip_0
	jz	filecount200
	mov	dx,offset paraset$
filecount200:
	xor	bx,bx		;count
	call	findfirst
	mov	al,255
	jc	filecount800
filecount300:
	inc	bx
	mov	ah,4fh
	int	21h
	jnc	filecount300

filecount700:
	mov	ax,bx
	cmp	ax,254
	jna	filecount800
	mov	al,254
filecount800:
	mov	ah,0
	jmp	errsubreset
;
;---
;
getenvsize:
	call	getenvseg
getenvsize200:		;JP FROM GETENVFREE
	mov	ax,cx
	mov	cl,4
	shr	ax,cl
	cmp	ax,254
	jc	getenvsize800
	mov	ax,254
getenvsize800:
	ret
;
;---
;
getenvfree:
	call	getenvseg
	push	es
	pop	ds
	call	envskipend
	jnz	getenvfree400

	add	si,4
getenvfree300:
	lodsb
	or	al,al
	jnz	getenvfree300

getenvfree400:
	sub	cx,si
	jmp	getenvsize200
;
;---
;
dspenvsegment:
	call	getenvseg
dspenvsegment200:
	mov	ax,es
	call	hexprax
	xor	ax,ax
	ret
;
;---
;
dspbatsegment:
	call	getbatseg
	jnc	dspenvsegment200
	mov	ax,255
	ret
;
;---
;	"A:\PATH\FILE.EXT"
;	 ||--+--|-+--|-+-
;	 ||  |  | |  + +---------- BIT 0
;	 ||  |  | |  +------------ BIT 1
;	 ||  |  | +--------------- BIT 2
;	 ||  |  +----------------- BIT 3
;	 ||  +-------------------- BIT 4
;	 |+----------------------- BIT 5
;	 +------------------------ BIT 6
;
strtok_tbl	db _BIT0			; 0	EXT
		db _BIT1 + _BIT0		; 1	.EXT
		db _BIT3 + _BIT2		; 2	\FILE
		db _BIT2			; 3	FILE
		db _BIT2 + _BIT1 + _BIT0	; 4	FILE.EXT
		db _BIT4			; 5	\PATH
		db _BIT4 + _BIT3		; 6	\PATH\
		db _BIT6 + _BIT5		; 7	A:
		db _BIT6			; 8	A
		db _BIT4 + _BIT3 + _BIT2 + _BIT1 + _BIT0 ; 9 A:\PATH\FILE.EXT

;			;   "A:\PATH\FILE.EXT"	"A:\"
strtokpathname:		; 9	\PATH\FILE.EXT	\
	inc	bp
strtokdrv1:		; 8	A		A
	inc	bp
strtokdrv:		; 7	A:		A:
	inc	bp
strtokpath2:		; 6	\PATH\		\
	inc	bp
strtokpath:		; 5	\PATH
	inc	bp
strtokname:		; 4	FILE.EXT
	inc	bp
strtokfile1:		; 3	FILE
strtoknode1:		; 3	FILE
	inc	bp
strtokfile:		; 2	\FILE		\
strtoknode:		; 2	\FILE		\
	inc	bp
strtokext2:		; 1	.EXT
	inc	bp
strtokext:		; 0	EXT
	call	paraset
	mov	si,di
	cmp	byte ptr [si],0
	jz	short strtok_ret
	mov	ch,ds:[bp+strtok_tbl]

		;drive
	cmp	byte ptr [si+1],':'
	_if z
		lodsb
		test	ch,_BIT6
		_if nz
			call	strtok_psub
		_endif
		lodsb
		test	ch,_BIT5
		_if nz
			call	strtok_psub
		_endif
		mov	di,si
	_endif

		;path
	call	get_lastdelim
	mov	si,dx		;c:\path\file.ext の fileの位置
	cmp	di,si		;startとendが同じ?(pathの指定なし)
	_if nz			; No
		dec	si
		mov	cl,_BIT4
		call	strtok_ssub
		mov	di,si
		inc	si
		mov	cl,_BIT3
		call	strtok_ssub
	_endif

		;file(node)
	mov	di,si
strtok500:
	lodsb
	or	al,al
	_if z
		mov	cl,_BIT2
		call	strtok_ssub
		jmp	short strtok_ret
	_endif
	cmp	al,'.'
	jnz	strtok500
	dec	si
	mov	cl,_BIT2
	call	strtok_ssub

		;ext
	mov	di,si
	test	ch,_BIT1
	_if z
		inc	di
	_endif

strtok600:
	lodsb
	or	al,al
	jnz	strtok600
	mov	cl,_BIT0
	call	strtok_ssub

strtok_ret:
	mov	al,[strtok_flg]
	mov	ah,0
	ret
;
strtok_psub:
	mov	byte ptr [strtok_flg],0
	jmp	envpsub
;
strtok_ssub:		;di=start si=end+1(a:\bin+NULLならNULLの位置)
			;cl=チェックするBIT
			; ret
	push	si
	push	di
	test	ch,cl
	_if nz
		xchg	si,di
strtok_ssub100:
		cmp	si,di
		_if c
			lodsb
			or	al,al
			_if nz
				call	strtok_psub
			_endif
			jmp	strtok_ssub100
		_endif
	_endif
	pop	di
	pop	si
	ret

;
;---
;
strupr:
	call	chk2quote
	call	j_strupr
strupr700:		;JP too STRLWR
	mov	dx,si
	call	envprintcr
	xor	ax,ax
	ret
;
;---
;
strlwr:
	call	chk2quote
	call	j_strlwr
	jmp	strupr700
;
;---
;
strlen:
	call	chk2quote
	mov	ah,0
strlen200:
	lodsb
	cmp	al,CR
	jz	strlen800
	inc	ah
	cmp	ah,254
	jc	strlen200
strlen800:
	mov	al,ah
	mov	ah,0
	ret
;
;---
;
beep:
	mov	cx,1
	jz	beep200
	mov	cx,0ffffh
	call	calc0
beep200:
	mov	ah,6
	mov	dl,7
	int	21h
	jcxz	beep300
	loop	beep200
	xor	ax,ax
	ret
beep300:
	call	getch
	jz	beep200
	mov	ah,0
	ret
;
;---
;
peek:
	cmp	al,'W'
	jnz	peek200
	inc	si
	inc	bp
peek200:
	call	hexincx
	mov	es,cx
	call	hexincx
	mov	di,cx
	or	bp,bp
	jnz	peek500
	mov	al,es:[di]
	mov	ah,0
	ret
peek500:
	mov	ax,es:[di]
	ret
;
;---
;
poke:
	cmp	al,'W'
	jnz	poke200
	inc	si
	inc	bp
poke200:
	call	hexincx
	mov	es,cx
	call	hexincx
	mov	di,cx
	or	bp,bp
	jnz	poke500
	call	hexincl
	mov	al,cl
	stosb
	mov	ah,0
	ret
poke500:
	call	hexincx
	mov	ax,cx
	stosw
	ret
;
;---
;
inport:
	cmp	al,'W'
	jnz	inport200
	inc	si
	inc	bp
inport200:
	call	hexincx
	mov	dx,cx
	or	bp,bp
	jnz	inport500
	in	al,dx
	mov	ah,0
	ret
inport500:
	in	ax,dx
	ret
;
;---
;
outport:
	cmp	al,'W'
	jnz	outport200
	inc	si
	inc	bp
outport200:
	call	hexincx
	mov	dx,cx
	or	bp,bp
	jnz	outport500
	call	hexincl
	mov	al,cl
	out	dx,al
	mov	ah,0
	ret
outport500:
	call	hexincx
	mov	dx,cx
	call	hexincx
	mov	ax,cx
	out	dx,ax
	ret
;
;---
;
int86:
	mov	di,offset hlpwork$ + 4
	push	di
	xor	ax,ax
	mov	cx,9
  rep	stosw
	pop	di
	mov	byte ptr [di],21h		;dummy
	mov	[di+19 - 4],cs		;ds
	mov	[di+21 - 4],cs		;es
	dec	ax			;ax=-1
	mov	word ptr [di+25 - 4],ax		;r=(return)=-1
int200:
	push	si
	push	di
	mov	di,offset register$
	lodsw
	call	casew
	mov	cx,9 + 9
	cmp	ax,'=R'
	_if z
			;'R=XX'
		lodsw
		call	casew
	  repnz	scasw
		jnz	paraerr
		mov	word ptr [hlpwork$+25],cx
		;mov	word ptr [hlpwork$+27],ax
		jmp	short int240
	_endif
  repnz	scasw
	jnz	int260
			;'REG=xx'
	sub	cx,9 + 9 - 1
	neg	cx
	mov	bx,cx
	lodsb
	cmp	al,'='
	jz	int220
	dec	si
int220:
	cmp	cx,9
	jnc	int230
			;'AH=xx'
	call	inputcl
	mov	[bx+ offset hlpwork$ + 4],cl
	jmp	short int240
int230:
			;'AX=xxxx'
	call	inputcx
	shl	bx,1
	;cmp	bx,13 * 2
	;jnc	int235
	;xchg	ch,cl
;int235:
	mov	[bx+ offset hlpwork$ + 4 + 1 - 9*2],cx
int240:
	pop	di
	pop	ax		;si
	jmp	short int290
;
int260:
			;'00'(レジスタ無し)
	pop	di
	pop	si
	call	inputcl
	push	di
	mov	ax,di
	sub	ax,offset hlpwork$ + 4
	or 	ax,ax
	_if nz
		and	ax,1
		cmp	ax,1
		sbb	ax,0
		add	di,ax
	_endif
	mov	[di],cl
	pop	di
	inc	di
int290:
	call	paraskip
	jnz	int200

	mov	di,offset hlpwork$
	xor	bx,bx
	push	bx
	mov	bl,[di+4]
	shl	bx,1
	shl	bx,1
	mov	si,bx
	pop	ds		;ds=0
	movsw
	movsw
	;push	cs
	;pop	ds
	cli
	mov	word ptr cs:[hlpwork$ + 23],sp
	mov	sp,offset hlpwork$ + 5
	pop	ax	;5
	pop	bx	;7
	pop	cx	;9
	pop	dx	;11
	pop	si	;13
	pop	di	;15
	pop	bp	;17
	pop	ds	;19
	pop	es	;21
	mov	sp,word ptr cs:[hlpwork$ + 23]
	sti
	pushf
	call	dword ptr cs:[hlpwork$]
	cli						; alを変えない事 ↓
	mov	word ptr cs:[hlpwork$ + 23],sp
	mov	sp,offset hlpwork$ + 23
	push	es
	push	ds
	push	bp
	push	di
	push	si
	push	dx
	push	cx
	push	bx
	push	ax
	mov	sp,word ptr cs:[hlpwork$ + 23]
	sti
	push	cs
	pop	ds
	mov	cx,word ptr [hlpwork$+25]
	mov	ah,0
	cmp	cx,-1
	jz	int800					; ここまでalを変えない
	sub	cx,9 + 9 - 1
	neg	cx
	mov	bx,cx
	cmp	cx,9
	_if c
		mov	al,[bx+ offset hlpwork$ + 4]
	_else
		shl	bx,1
		mov	ax,[bx+ offset hlpwork$ + 4 + 1 - 9*2]
	_endif
int800:
	ret
;
;---
;
strright:	;; 2
	inc	bp
strleft:	;; 1
	inc	bp
strmid:		;; 0
	;push	si
	call	paraset
	;pop	ax
	;mov	cx,si
	;sub	cx,ax
	call	strend
	push	cx		;str文字数
	call	paraskip
	mov	cx,0
	jz	strmid300
	or	bp,bp
	jnz	strmid300	;strleft,right
	mov	cx,255
	call	calc0
	cmp	cx,1
	adc	cx,0		;cx=0 なら cx=1
	dec	cx
strmid300:
	push	cx		;開始位置
	mov	cx,255
	call	paraskip
	jz	strmid340
	call	calc0
strmid340:
				;cx=抜き出す数(mid),文字数(left,right)
	pop	si	;開始位置
	pop	dx	;str文字数

	add	si,offset paraset$
	cmp	bp,2	;right?
	_if z
		cmp	cx,dx
		_if a
			mov	cx,dx
		_endif
		add	si,dx		
		sub	si,cx
	_endif

	add	dx,offset paraset$

	push	cx	;抜き出す数
	jcxz	strmid800
strmid400:
	cmp	si,dx
	jnc	strmid800
	lodsb
	or	al,al		;文字列が終わりなら
	jz	strmid800
	call	envpsub
	loop	strmid400
strmid800:
	pop	ax
	cmp	ax,255
	jc	strmid900
	mov	ax,254
strmid900:
	ret
;
;---
;
pushd:
	call	envsave

	push	si
	mov	dx,offset pushdtmp$
	call	envstrget1
	pushf
	jnz	pushd150
	mov	ax,dx
	sub	ax,bx
	cmp	ax,230
	mov	dx,offset envmaxlen$
	jnc	errend
pushd150:
	push	ds
	pop	es

	mov	byte ptr [swchd],1

	push	si
	mov	di,offset pushdtmp$
	call	envsetname
	pop	dx
	popf
	jnz	pushd200
	call	getenvseg
	push	es
	pop	ds
	call	envprintn
	push	cs
	push	cs
	pop	ds
	pop	es
	mov	al,';'
	call	envpsub
pushd200:
	pop	si

	call	curdrv2		;カレントドライブをprint

	push	si
	mov	dl,0
	call	curpath300
	call	envset
	pop	si

	push	cs
	pop	es
	call	paraset
	mov	si,di
	call	chdrv_sub
	jmp	xcdd700
;
;
;
popd:
	call	envsave
	mov	dx,offset pushdtmp$
	call	envstrget1
	mov	al,1
	jnz	popd800
	push	es
	pop	ds
	push	cs
	pop	es
	mov	di,offset searchbuff
	mov	cx,256
   rep	movsb
	push	cs
	pop	ds
	mov	si,offset searchbuff
	mov	al,';'
popd200:
	mov	bx,si
	call	j_strchr
	jz	popd200
	mov	si,bx
	lodsb
	sub	al,'A'
	mov	dl,al
	mov	ah,0eh		;SELECT DISK
	int	21h
	mov	al,1
	jc	popd800
	lea	dx,[si+1]
	mov	ah,3bh		;CHG DIR
	int	21h
	mov	al,1
	jc	popd800
	dec	bx
	cmp	byte ptr [bx],';'
	jz	popd700
	inc	bx
popd700:
	mov	byte ptr [bx],0
	mov	byte ptr [swchd],1
	mov	di,offset pushdtmp$
	call	envsetname
	mov	dx,offset searchbuff
	call	envprintn
	call	envset
	mov	al,0
popd800:
	mov	ah,0
	call	envload
	ret
;
;
;
strcmp:			;3
	inc	bp
strcmpi:		;2
stricmp:
	inc	bp
strnicmp:		;1
strncmpi:		;1
	inc	bp
strncmp:		;0
	call	paraset
	call	paraskip
	mov	di,offset searchbuff
	call	paraset0
	mov	cx,255
	cmp	bp,1
	ja	strcmp200
	call	paraskip
	push	di
	call	calc0
	pop	di
strcmp200:
	mov	si,offset paraset$
		;di= searchbuff
	or	bp,bp
	jz	strcmp400
	cmp	bp,3
	jnz	stricmp400
strcmp400:
	lodsb
	scasb
	jnz	strcmpnz
	or	al,al
	loopnz	strcmp400
strcmpz:
	xor	ax,ax
	ret
;
strcmpnz:
	mov	ax,1
	ret
;
;
stricmp400:
	lodsb
	call	iskanji
	jnc	stricmp600
	dec	si
	cmpsw
	jnz	strcmpnz
	sub	cx,2
	ja	stricmp400
	jmp	strcmpz
;
stricmp600:
	call	case
	mov	ah,al
	mov	al,[di]
	inc	di
	call	case
	cmp	al,ah
	jnz	strcmpnz
	or	al,al
	loopnz	stricmp400
	jmp	strcmpz
;
;
;
strchr2:
	mov	al,255
	jz	strchr900
	call	paraset
	call	paraskip
	mov	al,255
	jz	strchr900
	call	get1char
	push	ax		;区切り文字
	call	paraskip
	mov	cx,0
	jz	strchr300
	mov	cx,255
	call	calc0
strchr300:
	push	cx
	mov	cx,1
	jz	strchr340
	mov	cx,255
	call	calc0
strchr340:
	pop	dx
	mov	al,0
	jcxz	strchr980
	xchg	cx,dx
		;dh=0
	mov	si,offset paraset$
	pop	ax
	mov	ah,al
	jcxz	strchr500
strchr400:
	call	j_strchr
	jnz	strchr800
	loop	strchr400
strchr500:
	lodsb
	or	al,al
	jz	strchr800
	cmp	al,ah
	jnz	strchr550
	dec	dl
	jz	strchr800
strchr550:
	call	envpsub
	inc	dh
	call	iskanji
	jnc	strchr500
	lodsb
	call	envpsub
	inc	dh
	jmp	strchr500
strchr800:
	mov	al,dh
	cmp	al,254
	jna	strchr900
	mov	al,254
strchr900:
	mov	ah,0
	ret
strchr980:
	pop	dx		;dummy
	jmp	strchr900
;
;
;
movedata:
	call	hexincx		;ds
	push	cx
	call	hexincx		;si
	push	cx
	call	hexincx		;es
	push	cx
	call	hexincx		;di
	push	cx
	call	hexincx		;cx
	call	paraskip
	jnz	paraerr
	pop	di
	pop	es
	pop	si
	pop	ds
	mov	ax,si
	mov	dx,di
	sub	ax,dx
	mov	ax,ds
	mov	dx,es
	sbb	ax,dx
;	jnc	movedata400		;なんでこうしてるの?
	jc	movedata400		; #1.10α.2e
   rep	movsb
movedata800:
	xor	ax,ax
	ret
movedata400:
	dec	cx
	add	si,cx
	add	di,cx
	inc	cx
	std
   rep	movsb
	cld
	jmp	movedata800
;
;
;
linputfile:
	call	paraset
	mov	cx,1
	call	paraskip
	jz	linputfile300
	mov	cx,65535
	call	calc0
linputfile300:
	call	errsubset
	mov	dx,offset paraset$
	call	fopen
	mov	al,255
	jc	linputfile800
	jcxz	linputfile900
	jmp	short linputfile500
linputfile400:
	call	fgetc
	jz	linputfile900
	cmp	al,LF
	jnz	linputfile400
linputfile500:
	loop	linputfile400

	call	fgetc
	jz	linputfile900
	cmp	al,1ah		;[eof]
	jz	linputfile900
	jmp	short linputfile620
linputfile600:
	call	fgetc
	jz	linputfile700
	cmp	al,1ah		;[eof]
	jz	linputfile700
linputfile620:
	cmp	al,LF
	jz	linputfile700
	cmp	al,CR
	jz	linputfile700
	call	envpsub
	jmp	linputfile600
linputfile700:
	call	fclose
	mov	al,0
linputfile800:
	mov	ah,0
	jmp	errsubreset

linputfile900:
	call	fclose
	mov	al,254
	jmp	linputfile800
;
;
;
getfatr:
	call	errsubset
	mov	al,255
	jz	getfatr700
	call	paraset
	mov	dx,di
	mov	ax,4300h		;get file attribute
	int	21h
	mov	al,255
	jc	getfatr700
	mov	al,cl
	and	al,1fh
getfatr700:
	mov	ah,0
	jmp	errsubreset		;JP & RET
;
;
;
;dspdrv x u p
;	x:F[d]-MFD S[d]-320FD H[d]-HD R[am]-RAM
;	u:Unit No.
;	p:Partition No.
;RET
;	0～15:drive no
;	253:not fond
;	254:parameter error
;	255:machine error
;print
;	dspdrv	"A:"
;	dspdrv0	"A"

dspdrv0:
	inc	bp
dspdrv:
	call	machine2
	cmp	al,ID2_UNKNOWN
	jz	dspdrv900

	push	ax		;al=machine2 id2
	call	paraskip
	or	al,20h
	mov	ah,0
	cmp	al,'f'
	jz	dspdrv200
	inc	ah
	cmp	al,'s'
	jz	dspdrv200
	inc	ah
	cmp	al,'h'
	jz	dspdrv200
	inc	ah
	cmp	al,'r'
	jnz	dspdrv950
dspdrv200:
	push	ax		;ah=media
	call	parafeed
	call	paraskip
	mov	cx,0
	jz	dspdrv220
	mov	cx,9
	call	calc0
dspdrv220:
	pop	ax	;media
	push	ax
	push	cx		;unit
	jnz	dspdrv230
	mov	cx,0
	cmp	ah,2
	jnz	dspdrv240
	inc	cx		;HDなら1上げる
	jmp	short dspdrv240
dspdrv230:
	mov	cx,9
	call	calc0
dspdrv240:
				;(cl=partition)
	pop	dx		;dl=unit
	mov	dh,cl		;dh=partition
	pop	bx		;bh=media
	pop	ax		;(al=machine)
	mov	bl,al		;bl=machine
	mov	al,0		;'A:'
dspdrv300:
	call	get_drive_unit
	cmp	cx,dx
	jz	dspdrv400
dspdrv350:
	inc	al
	cmp	al,'P'-'A'
	jna	dspdrv300
	mov	al,253
	jmp	short dspdrv800
dspdrv400:
	cmp	ah,bh
	jnz	dspdrv350

	push	ax
	add	al,'A'
	call	envpsub
	or	bp,bp
	jnz	dspdrv500
	mov	al,':'
	call	envpsub
dspdrv500:
	pop	ax
dspdrv800:
	mov	ah,0
	jmp	endn		;pushがあるため
dspdrv900:
	mov	al,255
	jmp	dspdrv800
;
dspdrv930:
	pop	ax
dspdrv940:
	pop	ax
dspdrv950:
	pop	ax
	mov	al,254
	jmp	dspdrv800
;
;
;
;addbackslash:
;	call	paraset
;	mov	dx,di
;	call	envprintn
;	mov	al,[si-2]
;	call	chkpathchr
;	mov	al,0
;	jz	addbackslash800
;	mov	al,[path_chr]
;	call	envpsub
;	mov	al,1
;addbackslash800:
;	mov	ah,0
;	ret

addbackslash:
	call	backslash_sub
	pushf
	call	envprintn
	popf
	_if nz
		mov	al,[path_chr]
		call	envpsub
		mov	al,1
	_endif
	mov	ah,0		;これは無くてもよいはず
	ret
;
;
delbackslash:
	call	backslash_sub
	_if z
		mov	[di-2],al	;al=0
		inc	ax		;ax=1
	_endif
	push	ax
	call	envprintn
	pop	ax
	ret
;
;
;
getdosver:
	mov	ah,30h
	int	21h
	mov	cx,ax
	mov	al,10
	mul	cl
	xchg	al,ch
	mov	cl,10
	div	cl
	add	al,ch
	mov	ah,0
	ret
;
;
;
filecrc:
	call	makecrctable

	call	paraset
	call	paraskip
	jz	filecrc300
	call	hexincx
	inc	bp
filecrc300:
	call	errsubset
	mov	dx,offset paraset$
	call	fopen
			;bx=handle
	mov	al,255
	jc	filecrc800

	push	cx

	mov	si,0ffffh		;CRC
filecrc500:
	call	fgetc
	jz	filecrc700

	mov	di,si
	mov	cl,16 - CHAR_BIT
	shr	di,cl
	mov	ah,0
	xor	di,ax
	shl	di,1
	mov	dx,word ptr [di+crctable]

	mov	cl,CHAR_BIT
	shl	si,cl

	xor	si,dx
	jmp	filecrc500
filecrc700:
	not	si

	call	fclose
	call	errsubreset

	pop	cx
	or	bp,bp
	jz	filecrc750	;display
	xor	ax,ax
	cmp	si,cx
	jz	filecrc720
	inc	ax		;ax=1
filecrc720:
	ret
filecrc750:
	mov	ax,si
	call	hexprax
	xor	ax,ax
	ret
filecrc800:
	mov	ah,0
	jmp	errsubreset
;
;
;
printfret0:
	mov	ax,0
	ret
;
printferr:
	mov	ax,255
	ret
;
printf:
	jz	printferr
	;cmp	al,'('
	;jnz	printf160
	;inc	si
;printf160:
	call	paraskip
	jz	printferr
	call	paraset
	mov	[printf_si],si
	xchg	si,di
	mov	di,offset printfstr$
	push	di
	mov	cx,PARASET_COUNT / 2
  rep	movsw
	pop	si		;si=printfstr$
printf200:
	lodsb
	or	al,al
	jz	printfret0
	call	iskanji
	_if c
		call	envpsub
		lodsb
		jmp	short printf280
	_endif
	cmp	al,'%'
	jz	printf500
	cmp	al,'\'
	jz	printf300
printf280:
	call	envpsub
printf200a:
	jmp	short printf200

printf300:		; "\?"
	lodsb
	mov	bl,al
	call	case
	mov	di,offset meta_esc$
	mov	cx,(offset meta_esc_e$ - offset meta_esc$)/2
printf320:
	scasb
	jz	printf350
	inc	di
	loop	printf320
	cmp	al,'X'
	jnz	printf330
	;\xNNN
	mov	cx,0ffffh
	mov	ax,0401h		;4桁
	call	hexin1
	or	ch,ch
	jz	printf325
	mov	al,ch
	call	envpsub
printf325:
	mov	al,cl
	jmp	printf280
printf330:
;	;\DDD
	cmp	al,'0'
	_if nc
		cmp	al,'7'
		_if na
			dec	si
			call	octin
			jmp	printf325
		_endif
	_endif
	cmp	al,'%'
	_if z		;\%NAME%
		push	es
		push	si
		mov	di,offset searchbuff
printf333:
		lodsb
		stosb
		call	crz_chk
		_if z
printf335:
			pop	si
			pop	es
			mov	bl,'%'
			jmp	short printf338
		_endif
		call	sp_chk
		jz	printf335
		cmp	al,'%'
		jnz	printf333

		push	si
		mov	byte ptr [di-1],'='
		mov	dx,offset searchbuff
		call	envstrget1
		mov	dx,si	;dx=環境変数の実体
		pop	si
		jnz	printf335	;環境変数なし
		push	si
		push	ds

		push	es
		pop	ds
			;dx=環境変数の実体
		call	envprintn

		pop	ds
		pop	si
		pop	ax		;dummy(push si)
		pop	es
		jmp	short printf200a
	_endif
printf338:
	mov	al,'\'
printf340:
	call	envpsub
	mov	al,bl
	call	crz_chk
	jnz	printf280
	jmp	printfret0

printf350:		;META
	mov	al,[di]
	cmp	al,LF
	_if z
		mov	al,CR
		call	envpsub
		mov	al,LF
	_endif
	jmp	printf280

printf500:		; "%?"
	mov	dx,si
	lodsb
	mov	ah,0		;flags
				;bit 0	:flag -
				;bit 1	:flag +		; not support
				;bit 2	:flag SPACE	; not support
				;bit 3  :
				;bit 4  :flag width
				;bit 5  :flag width 0
				;bit 6  :flag precision
				;bit 7  :
	_switch al
	_case '-'
		or	ah,00000001b
		_break
	_case '+'
		or	ah,00000010b
		_break
	_case ' '
		or	ah,00000100b
		_break
	_default
		dec	si
	_endsw

	mov	al,[si]
	call	deci_chk
	_if nc
		cmp	byte ptr [si],'0'
		_if z
			or	ah,00100000b
		_endif
		push	ax
		mov	cx,255
		call	deciin
		pop	ax
		or	ah,00010000b
	_endif
	push	cx		;width
	mov	al,[si]
	cmp	al,'.'
	_if z
		inc	si
		push	ax
		mov	cx,255
		call	deciin
		pop	ax
		or	ah,01000000b
	_endif
	push	cx		;precision
	push	ax		;flag

	lodsb
	mov	bl,al
	mov	di,offset format_type$
	mov	cx,(offset format_type_e$ - offset format_type$)/3
printf520:
	scasb
	jz	printf550
	scasw		;add di,2
	loop	printf520
	pop	ax		;flagsのpush分
	pop	ax
	pop	ax
	mov	si,dx
	mov	al,'%'
	jmp	printf340
printf550:
	push	si
	push	di
	mov	si,[printf_si]
	call	paraskip
	jnz	printf560
	pop	si
	pop	si
	pop	ax		;flagsのpush分
	pop	ax
	pop	ax
	jmp	printf200
printf560:
	mov	[psub_mem],offset printf_str
	cmp	byte ptr [si],'"'
	_if z		;"str"をargに指定
		mov	di,offset searchbuff
		call	paraset0
		mov	dx,di
		call	envprintn
		jmp	short printf680
	_endif
	inc	byte ptr [cmd_search_flg]	;1
	mov	di,offset searchbuff
	push	di
	call	paraset0
	pop	di
	dec	byte ptr [cmd_search_flg]	;0
	call	cmd_search
	jnz	printf600
	call	cmd_call
	jmp	short printf680
printf600:
	mov	si,[printf_si]
	mov	cx,0ffffh
	call	calc0
	mov	ax,cx
printf680:
	mov	[printf_si],si
	pop	di
	call	word ptr [di]
	xor	si,si
	xchg	[psub_mem],si
	mov	byte ptr [si],0		;offset si=文字列終端

	mov	dx,offset printf_str
	pop	di		;(old si)
	pop	ax		;flag
	pop	cx		;precision
	pop	bx		;width
	push	di		;(old si)
	test	ah,01000000b		;precison
	_if nz
		mov	di,si
		sub	di,dx		;di=strlen  (dx=offset printf_str)
		sub	di,cx
		_if nc
			add	dx,di
			cmp	dx,si
			ja	printf780
		_endif
	_endif

	test	ah,00010000b		;width
	_if nz
		mov	di,si
		sub	di,dx		;di=strlen  (dx=offset printf_str)
		sub	bx,di
		jc	printf777
		mov	al,' '
		test	ah,00100000b	;width 0
		_if nz
			mov	al,'0'
		_endif
		test	ah,00000001b		;'-'
		_if z
			lea	di,[si+bx]
			std
			mov	cx,si
			sub	cx,dx
			inc	cx
		  rep	movsb

			mov	cx,di
			sub	cx,dx
			inc	cx
		  rep	stosb

			cld
		_else
			or	bx,bx
			_if nz
printf770:
				mov	[si],al
				inc	si
				dec	bx
				jnz	printf770
			_endif
			mov	byte ptr [si],0
		_endif
	_endif
printf777:
	call	envprintn
printf780:
	pop	si
	jmp	printf200
;
printfd:
printfi:
printfu:
	jmp	envdecipr8
;
printfx_:
	mov	bx,offset envpsub
	jmp	short printfx200
printfx:
	mov	bx,offset envpsub_l
printfx200:
	jmp	hexprax_sup
;
printfc:
	or	ah,ah
	_if nz
		xchg	ah,al
		call	envpsub
		xchg	ah,al
	_endif
	jmp	envpsub

printfs:
	ret
;
printfo:
	jmp	octprax_sup
;
;---
;
tempname:
	call	errsubset
	call	paraset
	mov	dx,di
	mov	ah,5ah			;make temp file
	int	21h
	mov	ax,255
	_if nc
		mov	ah,41h		;delete file
		int	21h
		call	envprintn
		xor	ax,ax
	_endif
	jmp	errsubreset
;
;
;
strdel2quote:
	xor	cx,cx
strdel2quote200:
	lodsb
	cmp	al,CR
	jz	strdel2quote800
	call	iskanji
	_if c
strdel2quote400:
		call	envpsub
		lodsb
	_else
		cmp	al,'\'
		jz	strdel2quote400
		cmp	al,'"'
		_if z
			inc	cx
			jmp	strdel2quote200
		_endif
	_endif
	call	envpsub
	jmp	strdel2quote200
strdel2quote800:
	xchg	ax,cx		;mov ax,cx
	ret
;
;
;
@which2:
	inc	bp		;3
which2:
	inc	bp		;2
@which:
	inc	bp		;1
which:
	cmp	al,CR
	jz	paraforget
	call	errsubset
	test	bp,2
	_if nz
		push	si
		call	paraset
		call	getcmdpathsub0
		pop	si
		mov	dx,offset dtaadd.DTA_NAME
		_if nc
			test	bp,1
			jz	which760
			jmp	short which780
		_endif
	_endif
	call	getcmdpath
	jc	which800
		;bx=searchbuff(フルパス)
	test	bp,1
	_if z
		mov	si,bx
which720:
		lodsb
		call	envpsub
		cmp	si,di
		jc	which720
which760:
		;dx=dtaのファイル名
		call	envprintn
	_endif
which780:
	mov	al,0
which800:
	mov	ah,0
	jmp	errsubreset
;
;---
;
parsefile:		;call too getfatr
	;;call	errsubset
	mov	al,255
	_if nz
		call	paraset_si
		mov	di,offset searchbuff
		mov	ax,2900h	;parse file name
		int	21h
		or	al,al		;0=no wildcard  1=in wildcard
		_if nz		;ワイルドカードあり
			mov	al,1
		_else
			lodsb
			or	al,al
			_if nz
				mov	al,2
			_endif
		_endif
	_endif
	mov	ah,0
	;;jmp	errsubreset
	ret
;
;
;==== DATA ====
;$S
crlf$		db CR,LF,'$'
nocommand$	db '該当するコマンドがありません$'
switcherr$	db 'スイッチが違います$'
execcoms100$	db 'メモリーを開放できません$'
execcoms120$	db '環境変数<COMSPEC>がありません$'
execcoms130$	db '<COMSPEC>のコマンドが見つかりません$'
execcoms140$	db 'メモリブロックが異常です$'
paraerr$	db 'パラメータが違います$'
paraforget$	db 'パラメータが不足です$'
decimaxovr$	db '数値が大きすぎます$'
kakkoerr$	db '括弧の数が違います$'
envovr$		db '環境変数の領域が足りません$'
envmaxlen$	db '環境変数の長さが長すぎます$'
hlptoobig$	db 'ヘルプファイルが大きすぎます$'
notfindhlp$	db 'ヘルプファイルが見つかりません$'
nokeyword$	db 'ヘルプキーワードが見つかりません$'

error$	db 7,'BU  Error --- $'

comexebat$	db '.COM','.EXE'
bat$		db '.BAT'

cmd:		;コマンドテーブル(大文字で入れること)
		; "AAA"と"AAA1"では後者を後にする
;$t
	dw	HELP
	db	'?',0
	dwdb	ADDBACKSLASH
	dwdb	BEEP
	dwdb	CALC
	dwdb	CAPKEY
	dwdb	CDD
	dwdb	CHKDSKFREE
	dwdb	CHKDSKSIZE
	dwdb	CHKMEMFREE
	dwdb	CHKMEMSIZE
	dwdb	CLOCKDAY
	dwdb	CTRLKEY
	dwdb	CURDRV
	dwdb	CURPATH
	dwdb	DELBACKSLASH
	dwdb	DSKREADY
	dwdb	DSPBATDRV
	dwdb	DSPBATFULLNAME
	dwdb	DSPCLOCK
	dwdb	DSPDATE
	dwdb	DSPDRV
	dwdb	DSPDSKFREE
	dwdb	DSPDSKSIZE
	dwdb	DSPERRORLEVEL
	dwdb	DSPMEMFREE
	dwdb	DSPMEMSIZE
	dwdb	DSPTIME
	dwdb	ECHO
	dwdb	FILECOUNT
	dwdb	FILECRC
	dwdb	FILELINE
	dwdb	FILESIZE
	dwdb	GETDOSVER
	dwdb	GETDRV
	dwdb	GETENVFREE
	dwdb	GETENVSIZE
	dwdb	GETFATR
	dwdb	GRAPHKEY
	dwdb	HELP
	dwdb	INPORT
	dw	INT86
	db	'INT',0
	dwdb	KANAKEY
	dwdb	KEYBUFF
	dwdb	KEYCLEAR
	dwdb	@KEYCODE
	dwdb	KEYESCANY
	dwdb	@KEYLIST
	dwdb	@KEYNUM
	dwdb	KEYRETSPC
	dwdb	KEYWAIT
	dwdb	@KEYYESNO
	dw	FLABEL
	db	'LABEL',0
	dwdb	@LINEINPUT
	dwdb	LINPUTFILE
	dwdb	MACHINE
	dwdb	OUTPORT
	dwdb	PARSEFILE
	dwdb	PEEK
	dwdb	POKE
	dwdb	POPD
	dwdb	PRINTF
	dwdb	PUSHD
	dwdb	RANDOM
	dwdb	RUN
	dwdb	SETERRORLEVEL
	dwdb	SHIFTKEY
	dwdb	STRCHR2
	dwdb	STRCMP
	dwdb	STRDEL2QUOTE
	dwdb	STRICMP
	dwdb	STRLEN
	dwdb	STRLWR
	dwdb	STRLEFT
	dwdb	STRMID
	dwdb	STRNCMP
	dwdb	STRRIGHT
	dwdb	STRTOKDRV
	dwdb	STRTOKNODE
	dwdb	STRTOKPATH
	dwdb	STRUPR
	dwdb	TEMPNAME
	dwdb	TIMESTAMP
	dwdb	TIMEWAIT
	dwdb	UPDATE
	dwdb	VOLUMESERIAL
	dwdb	@WHICH
	dwdb	XCDD
	dwdb	XPOP

cmd200$:				;以下は infoでの表示なし
	dwdb	KEYNUM
	dwdb	KEYYESNO
	dwdb	KEYCODE
	dwdb	KEYLIST
	dwdb	LINEINPUT

	dwdb	CURPATH1
	dwdb	CURDRVPATH
	dwdb	CURDRVPATH1		;CURDRVPATHより後にする事

	dwdb	@WHICH2			;@WHICHより後にすること
	dwdb	WHICH
	dwdb	WHICH2			;WHICHより後にすること

	dwdb	CLOCKHOUR
	dwdb	CLOCKMINUTE
	dwdb	CLOCKMONTH
	dwdb	CLOCKSECOND
	dwdb	CLOCKWEEK
	dwdb	CLOCKYEAR

	dwdb	STRCMPI
	dwdb	STRNCMPI		;STRNCMPより後にする事
	dwdb	STRNICMP

	dwdb	DSPDRV0			;DSPDRVより後にする事

	dwdb	MOVEDATA

	dwdb	DSPENVSEGMENT

	dwdb	CLOCKYEARMONTH
	dwdb	CLOCKYMD

	dwdb	CLOCKDATE
	dwdb	CLOCKTIME

	dwdb	ALTKEY

	dwdb	DSPBATDRVPATH		;DSPBATDRVより後にする事
	dwdb	DSPBATSEGMENT

	dwdb	STRTOKNAME
	dwdb	STRTOKDRV1		;STRTOKDRVより後にする事
	dwdb	STRTOKPATH2		;STRTOKPATHより後にする事
	dwdb	STRTOKPATHNAME		;STRTOKPATHより後にする事
	dwdb	STRTOKNODE1		;STRTOKNODEより後にする事
	dwdb	STRTOKFILE
	dwdb	STRTOKFILE1		;STRTOKFILEより後にする事
	dwdb	STRTOKEXT
	dwdb	STRTOKEXT2		;STRTOKEXTより後にする事

	dwdb	SETVOLUMESERIAL

	dwdb	MACHINE2		;MACHINEより後にすること

	dw 0

comspec$	db 'COMSPEC=',0
env_path$	db 'PATH=',0

para_block	dw 0,para_str,?,0,0,0,0

copy$		db 'COPY ',0

color$		db 1bh,'[3'
color10$	db '0m$'
		;   0 1 2 3 4 5 6 7 8
register$	db 'FNALAHBLBHCLCHDLDH'
		db 'AXBXCXDXSIDIBPDSES'
;
;
errorlevel_eq$	db 'ERRORLEVEL='
;
;
;$D
psub_mem	dw 0		;0以外ならこの値に表示文字を代入

cmd_search_flg	db 0		;`(',`)'もparasetでのコマンドの区切りと
				; するなら1(cmd_search用)

paraoff		dw ?		;PARAMETER NOW Add

errcodedi	dw 1		;INT24H DI(default=NOT Supported DISK)
org24off	dw ?		;INT24H ORG ADD
org24seg	dw ?		;

	;ここからは init: で初期化する事
swche		dw 0		;-E[STR] があれば 続く文字のアドレス
swchd		db 0		;-D[NAME] なら 1
		db ?		; work for PUSH [SWCHD]
keywaitf	db 0		;KEYWAIT なら 1
	;ここまで

swchl		dw 0		;-L[STR] があれば 続く文字のアドレス(help file)

swchm		db 1		;1:-M(-C)
swch1		db 0		;1 column for commands list
swchu		db 0		;HELP keyword `unmatch' display

psubflag	db 0		;PSUBに INT29Hを使うなら 1

keywaitc	dw ?		;KEYWAIT なら 0～65535

dskreadytmp$	db 'X:\'	;DSKREADYコマンドでのテンポラリファイル名
		db 'BUTMP$$$.)0(',0

wildcard0$	db 'X:\'
wildcard$	db '*.*',0

envcnt		dw ?		;ENVNAME$の最後のNULLの位置

batutyhlp$	db 'BU.HLP',0

envtmp$		db 'ENVTMP=',0
xcddtmp$	db 'XCDDTMP=',0
pushdtmp$	db 'PUSHDTMP=',0

geterr100$	db 0b4h,4dh,0cdh,21h	;; 2eh,0a3h
					;COMMAND.COMがERRORLEVELを得てる所

switchchar	db 0
path_chr	db '\'

filecnt		dw 1		;fgetc
fileptr		dw offset hlpwork$

;con$		db 'CON',0
nul$		db 'NUL',0
;
;multi_f		db 0		;0!=マルチコマンド
;save_si		dw ?		;si退避

random_i	db 0		;random 系列(?)値

linefeedflg	db 0		;コマンドの前の"!"のflag(終了後改行)

strtok_flg	db 1		;strtokで何かを表示したら0

hyoji_call	dw offset psub	;hyojiで呼ぶoffset

meta_esc$	db 'A',07h
		db 'B',08h
		db 'E',1bh
		db 'F',0ch
		db 'N',0ah
		db 'R',0dh
		db 'T',09h
		db 'V',06h
		db '\','\'
meta_esc_e$	label byte

format_type$	label byte
		dbdw 'd',printfd
		dbdw 'i',printfi
		dbdw 'u',printfu
		dbdw 'o',printfo
		dbdw 'x',printfx
		dbdw 'X',printfx_
		;dbdw 'f',printff
		;dbdw 'e',printfe
		;dbdw 'E',printfe_
		;dbdw 'g',printfg
		;dbdw 'G',printfg_
		dbdw 'c',printfc
		dbdw 's',printfs
		;dbdw 'n',printfn
		;dbdw 'p',printfp
format_type_e$	label byte

printf_si	dw ?

dosver_ax	label word
dosver_al	db ?
dosver_ah	db ?

stdout2_stdout	dw ?		;stdout2.. でのstdoutのDUPしたハンドル
stdout2_nul	dw ?		;stdout2.. でのNULのハンドル


 off=$		;以下ワークエリア

paraset$=off		;現在のコマンド名が入る
 off=off+PARASET_COUNT
printfstr$=off		;printfの"format-str"が入る
 off=off+PARASET_COUNT
machinework=off		;MACHINE(FM)ワーク/TIMESTAMPワーク/vecthookワーク
 off=off+16
para_str=off		;EXECCOMSの/C以下のパラメータ
 off=off+128
searchbuff=off		;FILE NAME SEARCH/CURPATH WORK/LINEINPUT/KEYIN/strcmp
 off=off+256		;	PRINTFでのコマンド名
envname$=off		;/Dの変数名
 off=off+ENV_NAME_MAX
envsave$=off		;/Dのカウント(2)+swchd+変数名待避(256)
 off=off+3+ENV_NAME_MAX
dtaadd=off		;DISK/FILE 転送アドレス
 off=off+48
param$=off		;bu.com パラメータ
 off=off+256
crctable=off		;CRC table
 off=off+(UCHAR_MAX+1)*2
printf_str=off		;printfの文字列代入用
 off=off+512
spoff=off+126
 off=off+128

enddata=off


; ↓ この先はCMD:内(例 RUN,HELP)で消される可能性あり


hlpname$=off			;BATUTY.HLPのフルネーム
 off=off+128
hlpwork$=off			;BATUTY.HLP読み込みバッファ
 off=off+8000h


whatver	db '@(#)'
title$	db 'BU (BATUTY)'
	db '  (C)1989-94 by Y.Shimizu  Version '
	db VERSION
if	DEBUGFLAG
	db 'D'
endif
	db 0,CR,LF,22h,3eh

switchtitle$	label byte
	db CR,LF
	db '"BU" for commands list',CR,LF
	db '"BU ? command_name" for command',"'s help",CR,LF
	db '$'

infoeasy$	label byte
	db 'USAGE:BU [-e[PrintString]] [-n[EnvName]] [-r] COMMAND ...',CR,LF
;	db CR,LF
	db ' COMMANDS Are:',CR,LF
	db '$'


codeend:


code 	ends
	end	begin


;batuty.hlpは以下の通り定義する
;
;
;	～～～～
;
;-- 1行以上の空行 --
;
; *	コマンド名
;	説明
;
;-- 1行以上の空行 --
;
; !	コマンド名
;	説明
;
;	～～～～
;
;
;
;　空行（何も入ってない行）の後　* または ! に続けてコマンド名を入れる。(v0.50aまでは * または ! の前に１文字の半角[space]を空けその後[tab]に続けてコマンド名)
;　コマンド名以下空行までを説明文として表示する。
;　それ以外で始まる行は無視される。
;
;
;bu.hlpボツ
;	パラメータは + で区切って複数のコマンドを一度に指定する事ができます.
;	この場合ERRORLEVELには最後のコマンドのものが返ります．またスイッチは
;	各々のコマンド毎に指定してください. '+'自身の指定には"++"または"\+"
;	を使用してください.
;	例)BU -e -nYY CLOCKYEAR + -e -nMM CLOCKMONTH + -e -nDD CLOCKDAY
;
