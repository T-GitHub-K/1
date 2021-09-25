;-----------------------------------------------------------------------------
;   OBASIC CALL  ｱｾﾝﾌﾞﾗ ﾙｰﾁﾝ
;
;   ﾌｧｲﾙ　CLOSE ﾕｰﾃｨﾘﾃｨｰ
;
;   CALL CLOSE(ﾌｧｲﾙNo,ｽﾃｰﾀｽFLG)
;
;  ｴﾗｰｽﾃｰﾀｽ
;
;		99	ERR_PARA	ﾊﾟﾗﾒｰﾀｰｴﾗｰ
;		98	ERR_CLOSE	ｸﾛｰｽﾞｴﾗｰ
;
; BASIC BLOAD ADD
;              BLOAD &HF100  に固定 
;
;
;-----------------------------------------------------------------------------


INCLUDE	MDOS.H
INCLUDE	MACRO.H
INCLUDE	STD.H

L_ADD		EQU	0F100H		;BLOAD address = DS:F100
OFSET		EQU	L_ADD-7


PARA_OP	STRUC				;スタック受渡テーブル
	BP_SV	DW	?		;BP退避
	R_ADD	DD	?		;RETURN	ADD
	ST_P	DW	?		;ｽﾃｰﾀｽFLG
	NO_P	DW	?		;FILE No
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
;-----------------------------------------------------------------------
		
		MOV	BX,[BP].NO_P	;ﾌｧｲﾙNOのアドレス取得
		MOV	AX,[BX]		;ﾌｧｲﾙNOの中身
		MOV	FILE_NO[OFSET],AX
		CMP	AX,0
		JNE	CLOSE_FILE

		MOV	AX,ERR_PARA	;ｴﾗｰｺｰﾄﾞ
		JMP	EXIT

;-----------------------------------------------------------------------

CLOSE_FILE:
		MOV	BX,FILE_NO[OFSET]
		MOV	AH,3EH
		INT	21H

		JC	CLOSE_ERR
		MOV	AX,0
		JMP	EXIT

CLOSE_ERR:
		MOV	AX,ERR_CLOSE	;ｴﾗｰｺｰﾄﾞ

EXIT:
		MOV	BX,[BP].ST_P	;ｽﾃｰﾀｽｾｯﾄ
		MOV	[BX],AX
		POPA
        	POP	BP

		RET	4

;---------------------------------------------------------------------------
FILE_NO		DW	0
;--------------------------------------------------------------------------
ERR_PARA	EQU	99			;ﾊﾟﾗｰﾒｰﾀｰｴﾗｰ
ERR_CLOSE	EQU	98			;ｸﾛｰｽﾞｴﾗｰ


MAIN	ENDP
endp	EQU	$

CODE		ENDS
		END
