;****************************************************************
;                                                               *
;      [ SYSMENU.ASM ] for CONFIG menu program                  *
;                                                               *
;        The BASIC 1987         ７月号 No.50 P113-119           *
;           バグ情報          ８月号 No.51 p167                 *
;           Ｖ３．１０対応版９月号 No.52 P145-146               *
;                                                               *
;                      伊達 秀光                                *
;                                                               *
;        一部バグ修正   By. M.FUKUI                             *
;                                                               *
;        ＭＳ－ＤＯＳ Ｖ３．３０ 対応                           *
;                                                               *
;            JUPITER PDS salon #514 C.Koshida                   *
;                                                               *
;                27-Sep-88      by M.FUKUI                      *
;                                                               *
;        メニュー数２６個（アルファベット）に変更               *
;                                                               *
;                 04-Oct-88     by M. FUKUI                     *
;                                                               *
;            日経ＭＩＸ long/main　83番 atlanさんの知人         *
;                                                               *
;         実行ファイル作成手順                                  *
;                                                               *
;           masm sysmenu;                                       *
;                                                               *
;           link sysmenu;                                       *
;                                                               *
;           exe2bin sysmenu.exe sysmenu.drv                     *
;                                                               *
;                                                               *
;         使用法                                                *
;                                                               *
;           CONFIG.SYS                                          *
;             device=sysmenu.drv                                *
;                                                               *
;           SYSMENU.BAT                                         *
;           *RAM DISK               (Title-1 16ch.)             *
;             CONFIGに書く内容                                  *
;           #AUTOEXEC.BATに書く内容                             *
;                                                               *
;           *CACHE DISK             (Title-2 16ch.)             *
;             CONFIGに書く内容                                  *
;           #AUTOEXEC.BATに書く内容                             *
;                                                               *
;****************************************************************
;
CR		equ	0dh
LF		equ	0ah
;
;
code 		segment
		assume	cs:code
		org	0h
dvf_zn2		equ	word ptr 43h			;Vr2.xx用
dvf_zn3		equ	word ptr 50h			;Vr3.10用
dvf_seg		equ	word ptr 18h			;Vr3.10用
sys_seg		equ	word ptr 1ah			;   〃
os_adr		equ	dword ptr 3			;   〃
dvf_zn33	equ	word ptr 58h			;V3.30 用
dvf_seg33	equ	word ptr 20h			;   〃
sys_seg33	equ	word ptr 22h			;   〃
start:		dw	-1,-1
		dw	8000h
		dw	f_in
		dw	s_in
		db	'sysmenu'
s_bx		dd	?
j_t		dw	insrz,sr,sr,sr,sr,sr,sr,sr,sr,sr,sr,sr,sr
f_in		proc	far
		mov	word ptr s_bx,bx
		mov	word ptr s_bx+2,es
		ret
f_in		endp
s_in		proc	far
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	bp
		push	ds
		push	es
		lds	bx,s_bx
		assume	cs:code,ds:code
		mov	al,2[bx]
		cmp	al,12
		ja	sr
		cbw
		shl	ax,1
		mov	si,offset j_t
		add	si,ax
		push	cs
		pop	ds
		jmp	[si]
sr:		assume	cs:code,ds:nothing
		mov	ah,1
		lds	bx,s_bx
		assume	cs:nothing,ds:code
		mov	3[bx], ax
		pop	es
		pop	ds
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
s_in		endp
		assume	cs:code,ds:nothing
insrz:
		lds	bx,s_bx
		assume	cs:code,ds:code,es:code
		cld
		les	di,[bx+12h]
		mov	cs:dv_namo,di
		mov	cs:dv_nams,es
		push	ax
		push	bx
		mov	ah,30h
		int	21h
		cmp	al,2
		jbe	pas_v1
		cmp	ah,30
		pop	bx
		pop	ax
		jae	pas_v13
		mov	cx,ds:[dvf_zn3]
		mov	cs:byte ptr ck_ver,1
		jmp	insrz1
pas_v13:
		mov	cx,ds:[dvf_zn33]
		mov	cs:byte ptr ck_ver,3
		jmp	insrz1
pas_v1:
		pop	bx
		pop	ax							;
		mov	cx,ds:[dvf_zn2]
insrz1:
		mov	cs:dv_zn,cx
		mov	word ptr [bx+0eh],offset insrz
		mov	10h[bx],cs
		cmp	cs:byte ptr ck_ver,1
		jb	pas_v2
		ja	pas_v23
		mov	cx,ds:[sys_seg]			;
		mov	cs:sv_syss,cx			;
		jmp	pas_v2
pas_v23:
		mov	cx,ds:[sys_seg33]		; Vr3.30
		mov	cs:sv_syss,cx			;
pas_v2:
		push	ax
		push	bx
		push	ds
		push	cs
		push	cs
		pop	ds
		pop	es
		call	bat_set
		mov	dx,offset bat_nam
		call	d_read
		jnb	menu1
insrz2:
		jmp	menu6
menu1:
		mov	cx, word ptr b_tatl
		jcxz	insrz2
		call	dvn_pr
		jb	menu6
menu2:
		call	key_in
		jb	menu6
menu3:
		call	moj_trf
		cmp	cx,2
		jbe	menu6
		push	si
		mov	ax,trf_no
		mov	bx,dv_nams
		mov	si,bx
		mov	ds,bx
		mov	cl,4
		shr	ax,cl
		or	ax,ax
		jz	menu4
		sub	bx,ax
		mov	cs:dv_nams,bx
		cmp	cs:byte ptr ck_Ver,1
		jb	menu4
		push	ds
		mov	dx,cs:sv_syss
		sub	si,dx
		mov	cl,4
		sal	si,cl
		mov	cx,si
		mov	ds,dx
		sub	dx,ax
		mov	es,dx
		mov	cs:sv_syss,dx
		xor	si,si
		xor	di,di
		rep	movsb
		pop	ds
menu4:
		mov	es,bx
		mov	cx,cs:dv_zn
		add	cx,cs:dv_namo
		inc	cx
		xor	si,si
		mov	di,si
		rep	movsb
		mov	al,[si-1]
		cmp	al,LF
		je	menu4a
		mov	al,LF
		stosb
		inc	cs:word ptr dv_zn
menu4a:
		push	cs
		pop	ds
		pop	si
		mov	cx,trf_no
		add	dv_zn,cx
menu5:
		rep	movsb
menu6:
		pop	ds
		pop	bx
		mov	ax,cs:dv_nams
		mov	[bx+14h],ax
		cmp	cs:byte ptr ck_ver,1
		je	pas_v3
		ja	pas_v33
		mov	[bx+86h],ax
		mov	ax,cs:dv_zn
		mov	ds:[dvf_zn2],ax
		jmp	menu6a
pas_v3:
		mov	ds:[dvf_seg],ax
		mov	bp,sp
		mov	[bp+22h],ax
		mov	[bp+1eh],ax
		mov	ax,cs:sv_syss
		mov	ds:[sys_seg],ax
		les	di,ds:[os_adr]
		mov	es:[di+18h],ax
		mov	ax,cs:dv_zn
		mov	ds:[dvf_zn3],ax
		jmp	menu6a
pas_v33:
		mov	ds:[dvf_seg33],ax
		mov	bp,sp
		mov	[bp+22h],ax
		mov	[bp+1eh],ax
		mov	ax,cs:sv_syss
		mov	ds:[sys_seg33],ax
		les	di,ds:[os_adr]
		mov	es:[di+18h],ax
		mov	ax,cs:dv_zn
		mov	ds:[dvf_zn33],ax
menu6a:
		push	cs
		push	cs
		pop	ds
		pop	es
		mov	si,copy_p
		or	si,si
		jnz	menu7
		mov	dx,offset aut_nam
		mov	ah,41h
		int	21h
		jmp	menue
menu7:
		call	aut_copy
menue:
		pop	ax
		jmp	sr
d_read:
		mov	word ptr b_tatl,0
		mov	ax,3d00h
		int	21h
		jnb	d_read1
		jmp	d_readen
d_read1:
		mov	bx,ax
		push	bx
		mov	dx,offset fbuf
		mov	cx, fbuf_size		; 800h
		mov	ah,3fh
		int	21h
		jb	d_read2
		mov	b_tatl,ax
d_read2:
		pop	bx
		mov	ah,3eh
		int	21h
d_readen:
		ret
bat_set:
		mov	si,dv_namo
		mov	ds,dv_nams
		mov	di,offset bat_nam
		xor	cx,cx
bat_set1:
		lodsb
		cmp	al,2eh
		je	bat_set2
		stosb
		inc	cx
		cmp	cx,8
		jb	bat_set1
		mov	al,2eh
bat_set2:
		stosb
		mov	si,offset ex_n
		mov	cx,4
		push	cs
		pop	ds
	        rep	movsb
		ret
dvn_pr:
		mov	si,offset fbuf
		call	msg_sch
		jnb	dvn_pr1
		stc
		jmp	dvn_prenn
dvn_pr1:
		mov	dx,offset begin_m
		mov	ah,9
		int	21h
		mov	bx,offset msg_p
		mov	di,offset con_p
		mov	byte ptr dat_no0,40h		;	30h
dvn_pr2:
		mov	si,[bx]
		or	si,si
		jz	dvn_preno
		inc	byte ptr dat_no0
		mov	dx,offset dat_no
		mov	ah,9
		int	21h
		mov	dx,offset menu_color		; メニューに色づけする
		mov	ah,9
		int	21h
		mov	cx,2
dvn_pr3:
		mov	dl,[si]
		cmp	dl,CR
		je	dvn_pr4
		cmp	dl,1ah
		je	dvn_pr4a
		mov	ah,2
		int	21h
		inc	si
		inc	cx
		cmp	cx,18
		jne	dvn_pr3
dvn_pr4:
		inc	si
		mov	dl,[si]
		cmp	dl,LF
		jne	dvn_pr4
dvn_pr4a:
		inc	si
		mov	[di],si
		mov	dl,20h
		mov	ax,18		; 20
		sub	ax,cx
		jz	dvn_pr6
		xchg	ax,cx
dvn_pr5:
		mov	ah,2
		int	21h
		loop	dvn_pr5
dvn_pr6:
		mov	dx,offset menu_none	; メニューの色を戻す
		mov	ah,9
		int	21h
		mov	dl,20h
		mov	cx,2
drv_pr6a:
		mov	ah,2
		int	21h
		loop	drv_pr6a
		inc	bx
		inc	bx
		inc	di
		inc	di
		jmp	dvn_pr2
dvn_preno:
		mov	word ptr [di],0
		call	put_LF
		call	put_LF
		clc
dvn_prenn:
		ret
msg_sch:
		push	si
		push	si
		pop	di
		mov	bx,offset msg_p
		mov	byte ptr d_tatl, 0
		mov	al,'*'
		mov	cx,b_tatl
msg_sch1:
		repne	scasb
		jcxz	msg_sche
msg_sch1a:
		pop	dx
		push	dx
		mov	si,di
		dec	si
		cmp	dx,si
		je	msg_sch1b
		dec	si
		cmp	byte ptr [si],LF
		je	msg_sch1b
		cmp	byte ptr [si],CR
		jne	msg_sch1
msg_sch1b:
		cmp	byte ptr [di],20h
		jne	msg_sch2
		inc	di
		dec	cx
msg_sch2:
		cmp	byte ptr d_tatl,26		; 8 メニュー数
		jae	msg_sch3
		inc	byte ptr d_tatl
		mov	[bx],di
		inc	bx
		inc	bx
		jmp	msg_sch1
msg_sch3:
		sub	di,offset fbuf+1
		mov	b_tatl,di
msg_sche:
		mov	word ptr [bx],0
		cmp	byte ptr d_tatl,0
		clc
		jnz	msg_scher			; 結果をキャリーに
		stc
msg_scher:
		pop	si
		ret
omj_cnv:
		push	cx
		push	si
omj_cnvst:
		lodsb
		cmp	al,81h
		jb	omj_cnv2
		cmp	al,9fh
		jbe	omj_cnv1
		cmp	al,0e0h
		jb	omj_cnv2
		cmp	al,0fch
		ja	omj_cnv2
omj_cnv1:
		inc	si
		dec	cx
		jcxz	omj_cnve
		jmp	omj_cnv3
omj_cnv2:
		cmp	al,61h
		jb	omj_cnv3
		cmp	al,7ah
		ja	omj_cnv3
		sub	al,20h
		mov	[si-1],al
omj_cnv3:
		loop	omj_cnvst
omj_cnve:
		pop	si
		pop	cx
		ret
moj_trf:
		call	omj_cnv
		push	si
moj_trf1:
		pop	si
		push	si
		mov	di,si
moj_trf2:
		call	moj_lp
		jb	moj_trf2
		push	cx
		push	si
		push	di
		mov	bp,si
		dec	bp
		mov	si,offset trf_d
		xor	cx,cx
moj_trf3:
		mov	di,bp
		mov	cl,[si]
		inc	si
		jcxz	moj_trf4
	        rep	cmpsb
		lahf
		add	si,cx
		sahf
		lodsb
		jnz	moj_trf3
		pop	di
		pop	si
		pop	cx
		jmp	moj_trf5
moj_trf4:
		pop	di
		pop	si
		pop	cx
		mov	al,5ah
moj_trf5:
		stosb
moj_trf6:
		call	moj_l
		call	moj_p
		jne	moj_trf6
		call	moj_lp
		stosb
moj_trf7:
		call	moj_l
		stosb
		cmp	al,20h
		ja	moj_trf7
		cmp	al,LF
		je	moj_trf2
		mov	byte ptr [di-1],0
moj_trf8:
		call	moj_l
		stosb
		cmp	al,LF
		jne	moj_trf8
		jmp	moj_trf2
moj_l:
		jcxz	moj_trfen
		lodsb
		dec	cx
		ret
moj_trfen:
		pop	cx
		pop	si
		sub	di,si
		mov	cx,di
		mov	trf_no,cx
		ret
moj_lp:
		jcxz	moj_trfen
		lodsb
		dec	cx
		call	moj_p
		je	moj_lp
		ret
moj_p:
		cmp	al,9h
		jz	moj_pe
		cmp	al,3bh
		je	moj_pe
		cmp	al,3dh
		je	moj_pe
		cmp	al,2ch
		je	moj_pe
		cmp	al,20h
moj_pe:
		ret
key_in:
		mov	byte ptr kbuf,2
key_in1:
		mov	dx,offset inputm
		mov	ah,9
		int	21h
		mov	dx,offset kbuf
		mov	ah,0ah
		int	21h
		mov	al,byte ptr kbuf+2
		cmp	byte ptr kbuf+1,0	; if only CR,
		jnz	key_in1_ch_found	; then
		mov	al,'a'			; set default character 'a' 
key_in1_ch_found:
		cmp	al,61h
		jb	up_c
		sub	al,20h
up_c:
		cmp	al,'@'		;30h
		jle	key_inn		;je key_inn
		jbe	key_in1
		sub	al,40h		; 30h
		cmp	al,byte ptr d_tatl
		ja	key_in1
		mov	ah,0
		dec	ax
		mov	si,offset con_p
		mov	di,offset msg_p
		sal	ax,1
		add	si,ax
		add	di,ax
		mov	si,[si]
		mov	cx,[di+2]
		jcxz	key_in3
key_in2:
		sub	cx,si
		jcxz	key_inn
		dec	cx
		mov	bx,cx
		call	copyd_sch
		jcxz	key_inn
		clc
		jmp	key_ine
key_in3:
		mov	cx,offset fbuf
		add	cx,word ptr b_tatl
		inc	cx
		jmp	key_in2
key_inn:
		stc
key_ine:
		pushf
		call	put_LF
		popf
		ret
copyd_sch:
		push	ax
		mov	word ptr copy_p,0
		mov	di,si
		mov	al,'#'
copyd_sch1:
		repne	scasb
		jcxz	copyd_sche
		mov	word ptr copy_p,di
		mov	word ptr copy_su,cx
		sub	bx,cx
		dec	bx
copyd_sche:
		mov	cx,bx
		pop	ax
		ret
aut_copy:
		mov	dx,offset aut_nam
		mov	ah,3ch
		xor	cx,cx
		int	21h
		jb	aut_erp1
		mov	bx,ax
		mov	cx,copy_su
		mov	dx,copy_p
		mov	ah,40h
		int	21h
		jb	aut_erp
		cmp	ax,copy_su
		jne	aut_erp
		mov	ah,3eh
		int	21h
		jb	aut_erp
		ret
aut_erp:
		mov	ah,3eh
		int	21h
aut_erp1:
		call	put_LF
		mov	dx, offset aut_erm
		mov	ah,9
		int	21h
		ret
put_LF:					; Line Feed の出力
		mov	dx,offset lfd
		mov	ah,9
		int	21h
		ret
;
dv_namo		dw	0
dv_nams		dw	0
sv_syss		dw	0
ck_ver		db	0
dv_zn		dw	0
trf_no		dw	0
d_tatl		db	0
b_tatl		dw	0
copy_p		dw	0
copy_su		dw	0
begin_m		db	CR,LF,1bh,'[43;34m'
		db	28 dup('-')
		db	'  CONFIG Menu Program '
		db	28	dup('-')
		db	1bh,'[m',CR,LF
		db	CR,LF,'$'
inputm		db	1bh,'[37m'
		db	'組み込むシステムを選んでください。［Default = A］:'
		db	1bh,'[m$'
aut_erm		db	1bh,'[31mAUTOEXECへコピー出来ません。',1bh,'[m',CR,LF,'$'
dat_no		db	1bh,'[33m'
dat_no0		db	'0:$'
lfd		db	CR,LF,'$'
menu_color	db	1bh,'[m$'
menu_none	db	1bh,'[m$'
trf_d		db	8,'AVAILDEVA',7,'BUFFERSB',5,'BREAKC',6,'DEVICED'
		db	5,'FILESF',7,'COUNTEYQ',5,'SHELLS',8,'SWITCHARW'
		db      4,'FCBSX',9,'LASTDRIVEL',0
msg_p		db	30*2	dup(0)		; 10*2	dup(0)
con_p		db	30*2	dup(0)		; 10*2	dup(0)
aut_nam		db	'autoexec.bat',0
ex_n		db	'bat',0
bat_nam		db	13	dup(0)
kbuf		db	5	dup(0)
fbuf_size	equ	1024*20			; SYSMENU.BATの内容に応じて
fbuf		equ	$			; 容量を変更すること
fbuf_end	equ 	fbuf+fbuf_size
;
code		ends
		end	start
