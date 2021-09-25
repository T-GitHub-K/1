;-----------------------------------------------------------------------------
;   OBASIC CALL  ｱｾﾝﾌﾞﾗ ﾙｰﾁﾝ
;
;   ﾌｧｲﾙ　OPEN ﾕｰﾃｨﾘﾃｨｰ
;
;   CALL OPEN(ﾌｧｲﾙﾈｰﾑ,ﾌｧｲﾙNo,ｱｸｾｽﾓｰﾄﾞ,ｽﾃｰﾀｽFLG)
;
;   ｱｸｾｽﾓｰﾄﾞ     0････READ
;                1････WRITE
;                2････READ/WRITE
;
;  ｴﾗｰｽﾃｰﾀｽ
;
;		99	ERR_PARA	ﾊﾟﾗﾒｰﾀｰｴﾗｰ
;		98	ERR_OPN		ｵｰﾌﾟﾝｴﾗｰ
;		97	ERR_MAKE	;ﾒｲｸｴﾗｰ
;
; BASIC BLOAD ADD
;              BLOAD &HF000  に固定 
;
;
;-----------------------------------------------------------------------------

INCLUDE	MDOS.H
INCLUDE	MACRO.H
INCLUDE	STD.H

L_ADD		EQU	0F000H		;BLOAD address = DS:F000
OFSET		EQU	L_ADD-7


PARA_OP	STRUC				;スタック受渡テーブル
	BP_SV	DW	?		;BP退避
	R_ADD	DD	?		;RETURN	ADD
	ST_P	DW	?		;ｽﾃｰﾀｽFLG
	AC_P	DW	?		;ｱｸｾｽﾓｰﾄﾞ
	NO_P	DW	?		;FILE No
	FN_P	DW	?		;FILE NAME
PARA_OP	ENDS


CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,SS:CODE,ES:CODE

	DB	0FDH
	DW	0000H
	DW	L_ADD
	DW	endp - startp

	PUBLIC	MAIN

startp	EQU	$

MAIN	PROC	FAR

		PUSH	BP		;BPスタックに退避	
		MOV	BP,SP		;スタックポイントBPにMOVE
		PUSHA			;全レジスタ退避

;----------------------------------------------------------------------

		MOV	BX,[BP].AC_P	;ｱｸｾｽﾓｰﾄﾞアドレス取得
		MOV	AX,[BX]		;ｱｸｾｽﾓｰﾄﾞの中身
		MOV	AC_M[OFSET],AL	;AL=0･･･READﾓｰﾄﾞ
		CMP	AL,3		;AL=1･･･WRITEﾓｰﾄﾞ
		JB	NEXT_PARA	;AL=2･･･READ/WRITE

         	MOV	AL,ERR_PARA	;ｴﾗｰｺｰﾄﾞ
		JMP	EXIT
;-----------------------------------------------------------------------

NEXT_PARA:
		MOV	BX,[BP].NO_P	;ﾌｧｲﾙNOのアドレス取得
		MOV	AX,[BX]		;ﾌｧｲﾙNOの中身
		MOV	FILE_NO[OFSET],AX
;-----------------------------------------------------------------------
		XOR	CX,CX
		MOV	BX,[BP].FN_P		;ﾌｧｲﾙ名 
		MOV	CL,[BX]			;ﾌｧｲﾙ名の長さ
		MOV	SI,[BX+1]		;ﾌｧｲﾙ名のアドレス
;-----------------------------------------------------------------------
PARA_COPY:
		CLD
		MOV	DI,OFFSET FILE_NAM[OFSET]
		REP	MOVSB
		MOV	BYTE PTR [DI],NUL
;------------------------------------------------------------------------
OPEN_FILE:
		MOV	DX,OFFSET FILE_NAM[OFSET]
		MOV	AL,AC_M[OFSET]			;ｱｸｾｽﾓｰﾄﾞ
		MOV	AH,3DH
		INT	21H

		JC	OPEN_CHK
		MOV	FILE_NO[OFSET],AX
		JMP	EXIT

OPEN_CHK:
		CMP	AX,02H				;ﾌｧｲﾙ名が存在しない
		JZ	MAKE_FILE

		MOV	AL,ERR_OPN			;ｴﾗｰｺｰﾄﾞ
		JMP	SHORT EXIT

MAKE_FILE:
		MOV	DX,OFFSET FILE_NAM[OFSET]
		MOV	CX,0				;ﾌｧｲﾙ属性
		MOV	AH,3CH
		INT	21H

		JC	MAKE_ERR
		MOV	FILE_NO[OFSET],AX
		JMP	SHORT EXIT

MAKE_ERR:
		MOV	AX,ERR_MAKE			;ｴﾗｰｺｰﾄﾞ

EXIT:
		MOV	BX,[BP].ST_P	;ｽﾃｰﾀｽFLGｾｯﾄ
		MOV	[BX],AX

		MOV	AX,FILE_NO[OFSET]
		MOV	BX,[BP].NO_P	;ﾌｧｲﾙNOｾｯﾄ
		MOV	[BX],AX
		POPA
        	POP	BP

		RET	8
;--------------------------------------------------------------------------

FILE_NAM	DB	60	DUP(0)			;ﾌｧｲﾙ名ｴﾘｱ
AC_M		DB	0				;ｱｸｾｽﾓｰﾄﾞ
FILE_NO		DW	0				;ﾌｧｲﾙNO
;-------------------------------------------------------------------------

ERR_PARA	EQU	99				;ﾊﾟﾗﾒｰﾀｰｴﾗｰ
ERR_OPN		EQU	98				;ｵｰﾌﾟﾝｴﾗｰ
ERR_MAKE	EQU	97				;ﾒｲｸｴﾗｰ


MAIN	ENDP
endp	EQU	$

CODE		ENDS
		END
