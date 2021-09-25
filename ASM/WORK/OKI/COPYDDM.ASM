;*****************************************************************
;*    COPYDDM PROGRAM
;*           '86,4,3                                             *
;*****************************************************************
;
PAGE ,120

cseg	segment
	assume	cs:cseg,ds:cseg,ss:cseg,es:cseg
;
	org	100h
;
main		proc	far
;
copyddm:	mov	dx,ds
		mov	cs:word ptr [retsav+2],dx
		mov	dx,cs
		mov	ds,dx
;
		mov	dl,1
		mov	dh,1
		mov	cl,88h
		int	80h
;
		mov	ah,9			;print
		mov	dx,offset sname
		int	21h
;
		mov	ah,0ah			;input souce-file name
		mov	dx,offset source
		int	21h
;
		mov	si,offset source[2]	;convert asciz
		mov	bl,source[1]
		xor	bh,bh
		mov	byte ptr [bx] [si],0
;
		mov	ah,9			;print
		mov	dx,offset dname
		int	21h
;
		mov	ah,0ah			;input dest-file name
		mov	dx,offset dest
		int	21h
;
		mov	di,offset dest[2]	;convert asciz
		mov	bl,dest[1]
		xor	bh,bh
		mov	byte ptr [bx] [di],0
;
		mov	ah,3dh			;source-file open
		mov	dx,si
		mov	al,0
		int	21h
		jc	openerr
		mov	handle_s,ax
		mov	ah,3ch			;dest-file make
		mov	dx,di
		mov	cx,0
		int	21h
		jc	makeerr
		mov	handle_d,ax
		mov	ddmflg,0
;
nxtrec:		mov	ah,3fh			;copy source-->dest
		mov	dx,offset buffer
		mov	cx,1024
		mov	bx,handle_s
		int	21h
		jc	readerr
		cmp	ax,0
		je	cpyend
;
		mov	cx,ax
		mov	ah,40h
		mov	dx,offset buffer
		mov	bx,handle_d
		int	21h
		jc	wrterr
;
		cmp	ddmflg,0
		jne	ddmskip
		mov	ah,3eh
		mov	bx,handle_d
		int	21h
		jc	clserr
;
		mov	dl,1
		mov	dh,2
		mov	cl,88h
		int	80h
		mov	ddmflg,1
;
		mov	ah,3dh
		mov	dx,di
		mov	al,1
		int 	21h
		jc	openerr
		mov	handle_d,ax
;
		mov	ah,42h
		mov	cx,0
		mov	dx,0
		mov	al,2
		mov	bx,handle_d
		int	21h
;
ddmskip:	jmp	nxtrec
;
openerr:	mov	dx,offset msgser
		jmp	msgout
;
makeerr:	mov	dx,offset msgmer
		jmp	msgout
;
readerr:	mov	dx,offset msgrer
		jmp	msgout
;
wrterr:		mov	dx,offset msgwer
		jmp	msgout
;
cpyend:		mov	ah,3eh
		mov	bx,handle_d
		int	21h
		jc	clserr
		mov	dx,offset msgend
		jmp	msgout
;
clserr:		mov	dx,offset msgcer
;
msgout:		mov	ah,9
		int	21h
;
		jmp	dword ptr [retsav]
;
msgser		db	0dh,0ah,0ah,'Source File Not Found',0dh,0ah,'$'
;
msgmer		db	0dh,0ah,0ah,'Directory Full',0dh,0ah,'$'
;
msgrer		db	0dh,0ah,0ah,'Read error',0dh,0ah,'$'
;
msgwer		db	0dh,0ah,0ah,'Disk Full',0dh,0ah,'$'
;
msgcer		db	0dh,0ah,0ah,'Cannot Close',0dh,0ah,'$'
;
msgend		db	0dh,0ah,0ah,'Copy Complete',0dh,0ah,'$'
;
sname		db	0dh,0ah,'Source name ? $'
;
dname		db	0dh,0ah,'  Dest name ? $'
;
source		db	62,63 dup (?)
;
dest		db	62,63 dup (?)
;
handle_s	dw	?
;
handle_d	dw	?
;
buffer		db	1024 dup (?)
;
ddmflg		dw	?
;
retsav		dw	2 dup (?)
;
main		endp
;
cseg	ends
;
	end	copyddm
