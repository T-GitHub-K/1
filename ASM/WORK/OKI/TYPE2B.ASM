;********************************************************************
;*	Type 2 BIOS call subroutine	if800
;*	GRAPH ASM			1987-3-12
;*	
;*	BLOAD address = DS:F000
;*
;*	Usage : CALL GRAPH(P1,P2,¥¥¥¥¥¥,PN)
;*	
;*	Input   P1,P2,¥¥¥¥¥¥ : Graphic BIOS call parameters
;*		PN	     : Number of parameters (not count pn)
;*
;*	Output Nothing
;*********************************************************************
COM	equ	0


ife	COM
	L_ADD	equ	0F000H			;BLOAD address = DS:F000
	OFSET	equ	L_ADD - 7
else
	OFSET	equ	0
endif

code		segment 'code'
ife	COM
	db	0FDH				;BLOAD header
	dw	0000H
	dw	L_ADD
	dw	endp - startp
endif

	assume	cs:code,ds:code
	public	graph

startp		equ	$
graph		proc	far
		mov	bp,sp			;save SP
		push	si
		mov	si,[bp+4]
		mov	ax,[si]			;number of parameters
		inc	ax
		mov	cl,1
		shl	ax,cl
		mov	si,offset return + OFSET
ife	COM
		mov	byte ptr ds:[si+0],0CAH	;set code of RET
		mov	word ptr ds:[si+1],ax	;set return number
else
		mov	byte ptr cs:[si+0],0CAH	;set code of RET
		mov	word ptr cs:[si+1],ax	;set return number
endif
		pop	si

		int	82H
		mov	sp,bp
return:		nop				;RET
		nop				;return number
		nop				;return	number

graph		endp

endp		equ	$
code		ends
		end





















		