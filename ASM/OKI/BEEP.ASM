CODE	SEGMENT PUBLIC
	ASSUME	CS:CODE,DS:CODE,SS:CODE,ES:CODE

START:
		MOV	AH,02H
		MOV	DL,07H
		INT	21H
		
		MOV	AH,4CH
		INT	21H

CODE		ENDS
		END	START

