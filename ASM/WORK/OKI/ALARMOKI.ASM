	;
	;	Interval Clock for PC9801 series ver 2.00
	;	Copyright (C) 1989, 1990 by K. Konishi
	;
code	segment	byte public 'code'
	;
	assume	cs:code, ds:code
	;
VSYNC	=	0ah
	;
beep1	macro
	mov	ah, 02h
	int	21h
	endm
	;
beep0	macro
	mov	ah, 02h
	int	21h
	endm
	;	変数
	;
_int2f	dd	?
_vsync	dd	?
sp_	dw	?
ss_	dw	?
	dw	256 dup (?)
stk	label	word
chk_ich	db	41h, 00h, 3ah, 00h, 2ah, 38h, 0aah, 38h, 1bh, 7ah, 9bh, 7ah, 26h, 7eh, 0a6h, 7eh, 2eh, 4fh, 0aeh, 4fh
ct	dw	0
alerm	dw	0						;アラーム状態
buf	db	6 dup (?)					;時刻取り込み領域
flag	record	t_flag:1,d_flag:1,j_flag:1,c_flag:1,i_flag:1,a_flag:1,m_flag:1,day:1,s_flag:1
flags	flag	<1, 0, 1, 1, 0, 1, 0, 0, 1>
t_addr	dw	160*24					;時刻表示位置
t_col	db	0e1h, 0c1h, 61h, 41h	;時刻表示カラー
t_spac1	db	0						;時刻表示時の前のスペース数
t_spac2	db	2						;時刻表示時の後のスペース数
d_addr	dw	160*24+2*75				;日付表示位置
d_col	db	0e1h, 0c1h, 61h, 41h	;日付表示カラー
d_spac1	db	1						;日付表示時の前のスペース数
d_spac2	db	0						;日付表示時の後のスペース数
alerm_l	dw	6000					;アラームの長さ
alerm_t	dw	0aa00h					;アラームタイプ
a_time	dw	0fffeh					;アラーム設定時刻
s_time	db	6 dup (?)				;立ち上げ時刻
base	dw	6						;基準間隔
id	db	low '⑥', high '⑥', 2		;識別子
	;
	;	常駐部
	;
int2f	proc	near
	cmp	ax, 6001
	je	?4
	jmp	cs:_int2f
?4:	mov	bx, cs
	iret
int2f	endp
	;
inter	proc	near
	cli
	mov	cs:sp_, sp
	mov	cs:ss_, ss
	push	cs
	pop	ss
	mov	sp, offset stk-2
	;
	push	es
	push	ds
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	mov	ax, cs
	mov	ds, ax
	;
	sti
	mov	ax, 0a000h
	mov	es, ax
	;
	mov	ah, 1				;キーチェック
	int	21h
	and	al, 19h
	cmp	al, 11h
	jne	?8
	or	flags, mask t_flag
	mov	di, t_addr
	mov	word ptr es:4[di], ':'
	test	flags, mask s_flag
	jz	?12
	mov	word ptr es:10[di], ':'
?12:	test	flags, mask day
	jz	?16
	or	flags, mask d_flag
	mov	di, d_addr
	mov	word ptr es:4[di], '/'
?16:	jmp	?6
?8:	cmp	al, 19h
	jne	?19
	test	flags, mask m_flag
	jnz		?23
	xor	flags, mask j_flag
	or	flags, mask m_flag
?23:	jmp	?6
?19:	cmp	al, 18h
	jne	?26
	or	flags, mask i_flag
	jmp	?6
?26:	cmp	al, 9h
	jne	?29
	test	flags, mask m_flag
	jnz		?33
	xor	flags, mask a_flag
	or	flags, mask m_flag
?33:	jmp	?6
?29:	and	flags, not ( mask i_flag or mask m_flag )
?6:	;
	mov	bx, offset buf		;時刻取得
	push	cs
	pop	es
	mov	ah, 0
	int	1ch
	;
	mov	ax, a_time			;アラーム処理
	cmp	ax, word ptr 3[bx]
	jne	?37
	cmp	byte ptr 5[bx], 0
	jne	?37
	cmp	alerm, 0
	jne	?37
	mov	ax, alerm_l
	mov	alerm, ax
?37:	;
	cmp	alerm, 1
	jna	?41
	dec	alerm
	test	flags, mask a_flag
	jz	?45
	mov	ax, alerm
	and	ax, 15
	mov	cl, al
	mov	ax, alerm_t
	shl	ax, cl
	shl	ax, 1
	jnc	?49
	beep1
	jmp	?47
?49:	beep0
?47:	jmp	?43
?45:	beep0
?43:	jmp	?39
?41:	beep0
?39:	;
	test	flags, mask j_flag	;時報処理
	jz	?53
	mov	ax, 100
	xor	dx, dx
	div	base
	shr	ax, 1
	shr	ax, 1
	shr	ax, 1
	cmp	ax, 0
	jne	?57
	mov	ax, 1
?57:	cmp	word ptr 4[bx], 0
	jne	?61
	cmp	ct, ax
	jnb	?65
	beep1
	inc	ct
	jmp	?63
?65:	beep0
?63:	jmp	?59
?61:	mov	ct, 0
?59:
?53:	;
	test	flags, mask m_flag	;マスク時はアラーム時刻表示
	jz	?69
	mov	ax, a_time
	mov	word ptr buf+3, ax
	mov	buf+5, 0
?69:	;
	test	flags, mask i_flag	;経過時間表時処理
	jz	?73
	mov	al, buf+5
	sub	al, s_time+5
	das
	mov	buf+5, al
	mov	al, buf+4
	sbb	al, s_time+4
	das
	mov	buf+4, al
	mov	al, buf+3
	sbb	al, s_time+3
	das
	mov	buf+3, al
	jnc	?77
	add	buf+3, 24h
?77:	cmp	buf+5, 59h
	jna	?81
	sub	buf+5, 40h
?81:	cmp	buf+4, 59h
	jna	?85
	sub	buf+4, 40h
?85:
?73:	;
	mov	ax, 0a000h
	mov	es, ax
	;
	mov	di, t_addr			;時刻表示破壊チェック
	cmp	word ptr es:4[di], ':'
	jne	?86
	test	flags, mask s_flag
	jz	?90
	cmp	word ptr es:10[di], ':'
	je	?90
?86:	test	flags, mask c_flag
	jz	?94
	and	flags, not mask t_flag
?94:
?90:	;
	mov	di, d_addr			;日付表示破壊チェック
	cmp	word ptr es:4[di], '/'
	je	?98
	test	flags, mask c_flag
	jz	?102
	and	flags, not mask d_flag
?102:
?98:	;
	test	flags, mask t_flag	;時刻表示
	jNz	?106
	jmp	?107
?106:	mov	cl, t_spac1
	xor	ch, ch
	jcxz	?111
	mov	ax, ' '*256
	std
	mov	di, t_addr
	dec	di
	dec	di
	rep	stosw
?111:	;
	mov	di, t_addr
	test	flags, mask s_flag
	jz	?115
	mov	al, 5[bx]
	mov	ah, al
	and	al, 15
	mov	cl, 4
	shr	ah, cl
	and	ah, 15
	add	ax, '00'
	mov	es:14[di], al
	mov	byte ptr es:15[di], 0
	mov	es:12[di], ah
	mov	byte ptr es:13[di], 0
	;
	mov	byte ptr es:10[di], ':'
	mov	byte ptr es:11[di], 0
?115:	mov	al, 4[bx]
	mov	ah, al
	and	al, 15
	mov	cl, 4
	shr	ah, cl
	and	ah, 15
	add	ax, '00'
	mov	es:8[di], al
	mov	byte ptr es:9[di], 0
	mov	es:6[di], ah
	mov	byte ptr es:7[di], 0
	;
	mov	byte ptr es:4[di], ':'
	mov	byte ptr es:5[di], 0
	;
	mov	al, 3[bx]
	mov	ah, al
	and	al, 15
	mov	cl, 4
	shr	ah, cl
	and	ah, 15
	add	ax, '00'
	mov	es:2[di], al
	mov	byte ptr es:3[di], 0
	mov	es:[di], ah
	mov	byte ptr es:1[di], 0
	;
	mov	cl, t_spac2
	xor	ch, ch
	jcxz	?119
	mov	ax, ' '*256
	cld
	add	di, 16
	test	flags, mask s_flag
	jnz	?123
	sub	di, 6
?123:	rep	stosw
?119:	;
	mov	di, t_addr
	lea	di, 2000h[di]
	mov	al, t_spac1
	xor	ah, ah
	sub	di, ax
	sub	di, ax
	cld
	mov	cx, 8
	add	cx, ax
	mov	al, t_spac2
	add	cx, ax
	xor	si, si
	test	flags, mask j_flag
	jnz	?127
	inc	si
?127:	test	flags, mask a_flag
	jnz	?131
	inc	si
	inc	si
?131:	mov	al, t_col[si]
	mov	ah, 0ffh
	test	flags, mask s_flag
	jnz	?135
	sub	cx, 3
?135:	rep	stosw
?107:	;
	test	flags, mask d_flag	;日付表示
	jNz	?139
	jmp	?140
?139:	mov	cl, d_spac1
	xor	ch, ch
	jcxz	?144
	mov	ax, ' '*256
	std
	mov	di, d_addr
	dec	di
	dec	di
	rep	stosw
?144:	;
	mov	di, d_addr
	mov	al, 2[bx]
	mov	ah, al
	and	al, 15
	mov	cl, 4
	shr	ah, cl
	and	ah, 15
	add	ax, '00'
	mov	es:8[di], al
	mov	byte ptr es:9[di], 0
	mov	es:6[di], ah
	mov	byte ptr es:7[di], 0
	;
	mov	byte ptr es:4[di], '/'
	mov	byte ptr es:5[di], 0
	;
	mov	al, 1[bx]
	mov	cl, 4
	shr	al, cl
	xor	ah, ah
	mov	dl, 10
	div	dl
	add	ax, '00'
	mov	es:2[di], ah
	mov	byte ptr es:3[di], 0
	cmp	al, '0'
	je	?148
	mov	es:[di], al
	mov	byte ptr es:1[di], 0
	jmp	?146
?148:	mov	word ptr es:[di], ' '
?146:	;
	mov	cl, d_spac2
	xor	ch, ch
	jcxz	?152
	mov	ax, ' '*256
	cld
	add	di, 10
	rep	stosw
?152:	;
	mov	di, d_addr
	lea	di, 2000h[di]
	mov	al, d_spac1
	xor	ah, ah
	sub	di, ax
	sub	di, ax
	cld
	mov	cx, 5
	add	cx, ax
	mov	al, d_spac2
	add	cx, ax
	xor	si, si
	test	flags, mask j_flag
	jnz	?156
	inc	si
?156:	test	flags, mask a_flag
	jnz	?160
	inc	si
	inc	si
?160:	mov	al, d_col[si]
	mov	ah, 0ffh
	rep	stosw
?140:	;
	cli
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	ds
	pop	es
	mov	ss, cs:ss_
	mov	sp, cs:sp_
	jmp	cs:_vsync
inter	endp
	;
	;	初期設定　＆　設定変更
	;
start	proc	near
	assume	cs:code, ds:data
	mov	ax, data
	mov	es, ax
	mov	cx, 127
	mov	si, 128+1
	mov	di, offset op_buf
	cld
	rep	movsb
	;
	mov	ax, data
	mov	ds, ax
	mov	dx, offset m0
	mov	ah, 9
	int	21h
	;
	mov	ax, 6001			;常駐チェック
	int	2fh
	mov	es, bx
	cmp	word ptr es:id, '⑥'
	jne	?161
	cmp	byte ptr es:id+2, 2
	jNe	?166
	jmp	?165
?161:
?166:	call	check
	call	a_set
	;
	mov	bx, offset s_time	;スタート時刻の取得
	push	cs
	pop	es
	mov	ah, 0
	int	1ch
	;
	mov	al, VSYNC			;ＶＳＹＮＣアドレスの取得
	mov	ah, 35h
	int	21h
	mov	word ptr _vsync, bx
	mov	word ptr _vsync+2, es
	;
	mov	al, 2fh				;ＩＮＴ２Ｆの取得
	mov	ah, 35h
	int	21h
	mov	word ptr _int2f, bx
	mov	word ptr _int2f+2, es
	;
	push	ds				;ＶＳＹＮＣの設定
	mov	dx, offset inter
	push	cs
	pop	ds
	mov	ah, 25h
	mov	al, VSYNC
	int	21h
	;
	mov	dx, offset int2f	;ＩＮＴ２Ｆの設定
	mov	ah, 25h
	mov	al, 2fh
	int	21h
	pop	ds
	;
	mov	ax, 0a000h			;表示準備
	mov	es, ax
	test	cs:flags, mask t_flag
	jz	?170
	mov	di, cs:t_addr
	mov	word ptr es:4[di], ':'
	test	cs:flags, mask s_flag
	jz	?175
	mov	word ptr es:10[di], ':'
?175:
?170:	test	cs:flags, mask d_flag
	jz	?178
	mov	di, cs:d_addr
	mov	word ptr es:4[di], '/'
?178:	;
	mov	ah, 31h				;常駐終了
	mov	al, 0
	mov	dx, offset start+100h+15
	mov	cl, 4
	shr	dx, cl
	int	21h
	;
	;	既に常駐していた場合
	;
?165:	push	es
	push	es
	push	cs
	pop	es
	pop	ds
	mov	si, offset flags
	mov	di, offset flags
	mov	cx, offset id-offset flags
	cld
	rep	movsb
	mov	ax, data
	mov	ds, ax
	call	check
	call	a_set
	;
	pop	es
	mov	si, offset flags
	mov	di, offset flags
	mov	cx, offset id-offset flags
	cld
	rep	movs	byte ptr es:[di], byte ptr cs:[si]
	cmp	cs:alerm, 0
	jne	?182
	mov	es:alerm, 0
?182:	;
	mov	cx, es:base
	mov	bx, offset inter
	mov	ah, 2
	int	1ch
	;
	mov	ax, 0a000h
	mov	es, ax
	test	cs:flags, mask t_flag
	jz	?186
	mov	di, cs:t_addr
	mov	word ptr es:4[di], ':'
	test	cs:flags, mask s_flag
	jz	?190
	mov	word ptr es:10[di], ':'
?190:
?186:	test	cs:flags, mask d_flag
	jz	?194
	mov	di, cs:d_addr
	mov	word ptr es:4[di], '/'
?194:	;
	mov	ax, 4c00h
	int	21h

start	endp
	;
	;	パラメータチェック
	;
check	proc	near
	mov	cs:alerm, 1
	mov	si, offset op_buf
	cld
?196:	call	sskip
	cmp	al, 13
	jNe	?200
	jmp	?201
?200:	cmp	al, 'd'
	je	?202
	cmp	al, 'D'
	jne	?206
?202:	call	val
	cmp	ax, -1
	jne	?210
	and	cs:flags, not ( mask d_flag or mask day )
	jmp	?208
?210:	cmp	ax, 24
	jna	?213
	mov	ah, 9
	mov	dx, offset me2
	int	21h
	jmp	_brk
?213:
?208:	mov	tmp, ax
	mov	al, [si]
	call	sskip
	cmp	al, ','
	je	?217
	mov	ah, 9
	mov	dx, offset me1
	int	21h
	jmp	_brk
?217:	call	val
	cmp	ax, -1
	jne	?221
	mov	ah, 9
	mov	dx, offset me1
	int	21h
	jmp	_brk
?221:	cmp	ax, 79-5
	jna	?225
	mov	ah, 9
	mov	dx, offset me2
	int	21h
	jmp	_brk
?225:	add	ax, ax
	mov	bx, ax
	mov	ax, 160
	mul	tmp
	add	ax, bx
	mov	cs:d_addr, ax
	or	cs:flags, mask d_flag or mask day
	jmp	?203
?206:	cmp	al, 't'
	je	?226
	cmp	al, 'T'
	jne	?229
?226:	call	val
	cmp	ax, -1
	jne	?233
	and	cs:flags, not mask t_flag
	jmp	?231
?233:	cmp	ax, 24
	jna	?236
	mov	ah, 9
	mov	dx, offset me2
	int	21h
	jmp	_brk
?236:
?231:	mov	tmp, ax
	mov	al, [si]
	call	sskip
	cmp	al, ','
	je	?240
	mov	ah, 9
	mov	dx, offset me1
	int	21h
	jmp	_brk
?240:	call	val
	cmp	ax, -1
	jne	?244
	mov	ah, 9
	mov	dx, offset me1
	int	21h
	jmp	_brk
?244:	cmp	ax, 79-8
	jna	?248
	mov	ah, 9
	mov	dx, offset me2
	int	21h
?248:	add	ax, ax
	mov	bx, ax
	mov	ax, 160
	mul	tmp
	add	ax, bx
	mov	cs:t_addr, ax
	or	cs:flags, mask t_flag
	jmp	?203
?229:	cmp	al, 'a'
	je	?249
	cmp	al, 'A'
	jne	?252
?249:	lodsb
	cmp	al, '0'
	jne	?256
	and	cs:flags, not mask a_flag
	mov	cs:a_time, 0ffffh
	jmp	?254
?256:	or	cs:flags, mask a_flag
	cmp	al, '1'
	je	?260
	dec	si
	mov	cs:alerm, 0
	mov	cs:a_time, 0fffeh
?260:
?254:	jmp	?203
?252:	cmp	al, 'c'
	je	?261
	cmp	al, 'C'
	jne	?264
?261:	lodsb
	cmp	al, '0'
	jne	?268
	and	cs:flags, not mask c_flag
	jmp	?266
?268:	or	cs:flags, mask c_flag
	cmp	al, '1'
	je	?272
	dec	si
?272:
?266:	jmp	?203
?264:	cmp	al, '@'
	jne	?275
	mov	bx, offset s_time
	push	cs
	pop	es
	mov	ah, 0
	int	1ch
	jmp	?203
?275:	mov	ah, 9
	mov	dx, offset me1
	int	21h
	jmp	_brk
?203:	jmp	?196
?201:
_brk	:	ret
check	endp
	;
sskip	proc	near
	lodsb
?277:	cmp	al, ' '
	je	?280
	cmp	al, '	'
	jne	?282
?280:	lodsb
	jmp	?277
?282:	ret
sskip	endp
	;
val	proc	near
	cld
	call	sskip
	cmp	al, '0'
	jb	?283
	cmp	al, '9'
	jna	?287
?283:	mov	ax, -1
	ret
?287:	and	al, 0fh
	xor	ah, ah
?289:	cmp	byte ptr [si], '0'
	jnae	?293
	cmp	byte ptr [si], '9'
	jnbe	?293
	mov	dx, 10
	mul	dx
	mov	dl, [si]
	and	dl, 0fh
	add	ax, dx
	inc	si
	jmp	?289
?293:	ret
val	endp
	;
a_set	proc	near
	cmp	cs:a_time, 0fffeh
	jne	?297
?307:	mov	dx, offset m1
	mov	ah, 9
	int	21h
	mov	ah, 0ah
	mov	dx, offset inp_buf
	int	21h
	mov	si, offset inp_buf+2
	cmp	inp_buf+2, 0dh
	jne	?305
	jmp	?298
?305:	call	val
	cmp	ax, 24
	jnb	?307
	cmp	byte ptr [si], ':'
	jne	?307
	xor	dx, dx
	mov	cx, 10
	div	cx
	mov	cl, 4
	shl	al, cl
	or	al, dl
	mov	byte ptr cs:a_time, al
	inc	si
	;
	call	val
	cmp	al, 59
	jnbe	?307
?298:	cmp	inp_buf+2, 0dh
	jne	?311
	mov	cs:a_time, 0ffffh
	jmp	?309
?311:	xor	dx, dx
	mov	cx, 10
	div	cx
	mov	cl, 4
	shl	al, cl
	or	al, dl
	mov	byte ptr cs:a_time+1, al
?309:
?297:	ret
a_set	endp
	;
	;
code	ends
	;
	;
data	segment	word public 'data'
	;
inp_buf	db	6, 0, 6 dup (?)
op_buf	db	128 dup (?)
tmp	dw	?
tmp1	db	?
tmp2	db	?
tmp3	db	?
tmp4	db	?
	;
m0	db	"Ｉnterval Ｃlock  version 2.00", 13, 10
	db	"Ｃopyright (C) 1990 by Ｋ. Ｋonishi", 13, 10
	db	'$'
	;
m1	db	"アラーム設定時刻を入力してください ( ex. 16:30 ) : $"
	;
me1	db	"Syntacx Error !!", 13, 10, 7, '$'
	;
me2	db	"Parameter Error !!", 13, 10, 7, '$'
	;
data	ends
	;
	;
	end	start
