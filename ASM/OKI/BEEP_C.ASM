;	Lattice C　LINK		
;				
;	ﾓﾃﾞﾙ		Sﾓﾃﾞﾙ	
;				
;	ｸﾞﾙｰﾌﾟﾒｲ 	PGROUP  
;				
;	ｾｸﾞﾒﾝﾄﾒｲ	PROG	


PGROUP	GROUP	PROG			;Lattice C Pgroup

PROG	SEGMENT	BYTE PUBLIC 'PROG'	;Lattice C prog segment
	ASSUME	CS:PGROUP

PUBLIC	BEEP				;Exturn BEEP

BEEP	PROC	NEAR

	MOV	BH,20			;20回ループ

LOOP:	PUSH	BX
	MOV	CL,78H
	MOV	AX,630
	MOV	DX,22
	MOV	CH,0
	INT	80H

	MOV	BL,0FFH			;WAIT ﾙｰﾁﾝ
LOOP1:	DEC	BL
	OR	BL,BL
	JNZ	LOOP1

	MOV	CL,78H
	MOV	AX,630
	MOV	DX,22
	MOV	CH,0
	INT	80H

	MOV	CL,78H
	MOV	AX,740
	MOV	DX,20
	MOV	CH,0
	INT	80H

	MOV	BL,0FFH			;WAIT ﾙｰﾁﾝ
LOOP2:	DEC	BL
	OR	BL,BL
	JNZ	LOOP2

	MOV	CL,78H
	MOV	AX,740
	MOV	DX,20
	MOV	CH,0
	INT	80H

	POP	BX
	DEC	BH
	OR	BH,BH
	JNZ	LOOP

	RET
BEEP	ENDP

PROG	ENDS
	END
