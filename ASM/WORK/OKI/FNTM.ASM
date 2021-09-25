INCLUDE	MDOS.H
INCLUDE	STD.H

CODE	SEGMENT
	ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE

	ORG	100H
	
START:
	MOV	CL,0A7H
	MOV	AL,1
	MOV	DX,OFFSET PAT0+2
	PUSH	ES
	INT	80H
	POP	ES

	MOV	CL,0A7H
	MOV	AL,1
	MOV	DX,OFFSET PAT1+2
	PUSH	ES
	INT	80H
	POP	ES

	MOV	CL,0A7H
	MOV	AL,1
	MOV	DX,OFFSET PAT2+2
	PUSH	ES
	INT	80H
	POP	ES

	MOV	CL,0A7H
	MOV	AL,1
	MOV	DX,OFFSET PAT3+2
	PUSH	ES
	INT	80H
	POP	ES

	MOV	CL,0A7H
	MOV	AL,1
	MOV	DX,OFFSET PAT4+2
	PUSH	ES
	INT	80H
	POP	ES

	MOV	CL,0A7H
	MOV	AL,1
	MOV	DX,OFFSET PAT5+2
	PUSH	ES
	INT	80H
	POP	ES

	MOV	CL,0A7H
	MOV	AL,1
	MOV	DX,OFFSET PAT6+2
	PUSH	ES
	INT	80H
	POP	ES

	MOV	CL,0A7H
	MOV	AL,1
	MOV	DX,OFFSET PAT7+2
	PUSH	ES
	INT	80H
	POP	ES

	MOV	CL,0A7H
	MOV	AL,1
	MOV	DX,OFFSET PAT8+2
	PUSH	ES
	INT	80H
	POP	ES

	MOV	CL,0A7H
	MOV	AL,1
	MOV	DX,OFFSET PAT9+2
	PUSH	ES
	INT	80H
	POP	ES

MAIN:

		CREATE_HANDLE	PNAME,0

		JC	MEKEERR
		MOV	HANDLE_D,AX

;
		WRITE_HANDLE	HANDLE_D,PAT0,620
		
		JC	WRTERR
		CMP	AX,620
		JE	CPYEND
		JMP	DISK_FULL

MEKEERR:
		MOV	DX,OFFSET MSGMER
		JMP	SHORT	MSGOUT

WRTERR:		MOV	DX,OFFSET MSGWER
		JMP	SHORT	MSGOUT

DELERR:		MOV	DX,OFFSET MSGDER
		JMP	SHORT	MSGOUT

CPYEND:
		CLOSE_HANDLE	HANDLE_D

		JC	CLSERR
		MOV	DX,OFFSET MSGEND
		JMP	SHORT	MSGOUT
;
CLSERR:		MOV	DX,OFFSET MSGCER
;
MSGOUT:
		MOV	AH,09H
		INT	21H
;
		END_PROCESS


DISK_FULL:
		CLOSE_HANDLE	HANDLE_D
		JC	CLSERR
		DELETE_ENTRY	PNAME
		JC	DELERR
		MOV	DX,OFFSET MSGFER
		JMP	SHORT	MSGOUT


MSGDER		DB	CR,LF,LF,"¥¥¥¥Delete Err",CR,LF,"$"

MSGFER		DB	CR,LF,LF,"¥¥¥¥Disk Full",CR,LF,"$"

MSGMER		DB	CR,LF,LF,'¥¥¥¥Directory Full',CR,LF,'$'

MSGWER		DB	CR,LF,LF,'¥¥¥¥Disk Full',CR,LF,'$'

MSGCER		DB	CR,LF,LF,'¥¥¥¥Cannot Close',CR,LF,'$'

MSGEND		DB	CR,LF,LF,'¥¥¥¥FNT.DAT Make Complete',CR,LF,'$'

HANDLE_D	DW	?



PNAME	DB	"FNT.DAT",0

;				62*10=620Byte
PAT0	DB	30H,0

	DB	30H,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

PAT1	DB	31H,0

	DB	31H,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

PAT2	DB	32H,0

	DB	32H,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

PAT3	DB	33H,0

	DB	33H,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

PAT4	DB	34H,0

	DB	34H,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

PAT5	DB	35H,0

	DB	35H,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

PAT6	DB	36H,0

	DB	36H,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

PAT7	DB	37H,0

	DB	37H,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

PAT8	DB	38H,0

	DB	38H,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

PAT9	DB	39H,0

	DB	39H,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0

	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0


CODE	ENDS
	END	START
