CODE	SEGMENT
	ASSUME	CS:CODE,DS:DATA
;
	MOV	AX,DATA
	MOV	DS,AX
;
	MOV	CX,0
	MOV	SI,OFFSET FINAME
	MOV	DX,SI
	MOV	AH,5BH
	INT	21H
;
	MOV	AH,4CH
	INT	21H
CODE	ENDS
;
DATA	SEGMENT
;
FINAME	DB	"ERRFLG",0
;
DATA	ENDS
	END
