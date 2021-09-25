code	segment
	assume	cs:code
start:	mov	cl,34h
	mov	dh,6
	int	80h

	mov	ah,4ch
	int	21h
code	ends
	end
