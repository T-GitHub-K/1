;************************************************
;*	Type 1/	Type 3 BIOS call subroutine	*
;*						*
;*	Usage	CALL BCALL(INTNO,REG(1))   	*
;*						*
;*	Parameters:	INTNO : interrupt number*
;*						*
;*	Parameters:		INPUT	OUTPUT	*
;*		REG(1) :	AX	AX	*
;*		REG(2) :	BX	BX	*
;*		REG(3) :	CX	CX	*
;*		REG(4) :	DX	DX	*
;*		REG(5) :	SI	SI	*
;*		REG(6) :	DI	DI	*
;*		REG(7) :	dummy	DS	*
;*		REG(8) :	dummy	ES	*
;************************************************
L_ADD	equ	0f000H		;BLOAD address = DS:F000
OFSET	equ	L_ADD-7

code	segment
	db	0FDH
	dw	0000H
	dw	L_ADD
	dw	endp - startp

	assume	cs:code,ds:code,es:code,ss:code
	public	main

startp	equ	$
main	proc	far
	mov	bp,sp		;save SP
	push	es		;save ES

	push	bx
	mov	bx,[bp+6]	; INTNO -> BX
	mov	bl,[bx]
	mov	byte ptr [INUM][OFSET],bl	;set INT number
	pop	bx

	mov	si,[bp+4]
	mov	ax,[si]		;REG(1) -> AX
	add	si,2
	mov	bx,[si]		;REG(2) -> BX
	add	si,2
	mov	cx,[si]		;REG(3) -> CX
	add	si,2
	mov	dx,[si]		;REG(4) -> DX
	push	bx
	mov	bx,si
	add	bx,2
	mov	si,[bx]		;REG(5) -> SI
	add	bx,2
	mov	di,[bx]		;REG(6) -> DI
	pop	bx

;	int	80H
	db	0CDH		;code of INT
INUM	db	00H		;INT number set here

	push	bx
	push	si
	mov	si,[bp+4]
	mov	[si],ax		;AX -> REG(1)
	add	si,2
	mov	[si],bx		;BX -> REG(2)
	add	si,2
	mov	[si],cx		;CX -> REG(3)
	add	si,2
	mov	[si],dx		;DX -> REG(4)
	mov	bx,si
	pop	si
	add	bx,2
	mov	[bx],si		;SI -> REG(5)
	add	bx,2
	mov	[bx],di		;DI -> REG(6)
	add	bx,2
	mov	[bx],ds		;DS -> REG(7)
	add	bx,2
	mov	[bx],es		;ES -> REG(8)
	pop	bx
	pop	es		;recover ES

	mov	sp,bp
	ret	4

main	endp
endp	equ	$
code	ends
	end
