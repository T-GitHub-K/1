CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE

S:
	MOV	AX,CODE
	MOV	DS,AX

	MOV	AX,OFFSET D1
	PUSH	AX
	MOV	AX,OFFSET D2
	PUSH	AX
	MOV	AX,OFFSET D3
	PUSH	AX
	MOV	AX,OFFSET D4
	PUSH	AX
	MOV	AX,OFFSET D5
	PUSH	AX
	MOV	AX,OFFSET D6
	PUSH	AX
	MOV	AX,OFFSET D7
	PUSH	AX
	MOV	AX,OFFSET D8
	PUSH	AX
	MOV	AX,OFFSET D9
	PUSH	AX
	MOV	AX,OFFSET D10
	PUSH	AX
	
	PUSH	AX
	PUSH	AX
	INT	82H

	MOV	AH,4CH
	INT	21H

D1	DW	5
D2	DW	2
D3	DW	1000
D4	DW	500
D5	DW	50
D6	DW	0
D7	DW	64
D8	DW	2
D9	DW	64
D10	DW	9

CODE	ENDS
	END
