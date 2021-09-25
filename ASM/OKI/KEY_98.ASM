INCLUDE	MDOS.H

CODE	SEGMENT	
	ASSUME	CS:CODE,DS:CODE

	ORG	100H

START:		mov	ah,05h
		int	18h
		CMP	AL,'*'
		JZ	END
		or	bh,bh
		jz	START
		
		XOR	CX,CX
		XOR	BX,BX
		
		push	ax
		
		xor	ah,ah
		
		MOV	CL,4
		SHL	AX,CL
		SHR	AL,CL
		CALL	SUB
		MOV	BL,AL
		MOV	AL,AH
		CALL	SUB
		MOV	BH,AL
		CALL	DISP
		
		pop	ax
		
		xor	al,al
		mov	al,ah
		
		MOV	CL,4
		SHL	AX,CL
		SHR	AL,CL
		CALL	SUB
		MOV	BL,AL
		MOV	AL,AH
		CALL	SUB
		MOV	BH,AL
		CALL	DISP
		
		
		JMP	START

END:		END_PROCESS	0

SUB:		CMP	AL,09H
		JBE	NEXT
		ADD	AL,07H
NEXT:		ADD	AL,30H
		RET


		
DISP:		DISPLAY_CHAR	BH
		DISPLAY_CHAR	BL
		DISPLAY_CHAR	'H'
		DISPLAY_CHAR	20H
		RET

CODE	ENDS
	END	START

