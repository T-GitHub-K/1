IF1
%OUT STD.H		READ_START
ENDIF
;----------------------------------------------------------------
;	286 ﾍｯﾀﾞｰ						
;								
;	CPU 286の拡張命令セット					
;----------------------------------------------------------------

.286c

NUL	EQU	0H
BREAK	EQU	03H
BS	EQU	08H
LF	EQU	0AH
CR	EQU	0DH
CLS	EQU	1AH
ESC	EQU	1BH
HOME	EQU	1EH
SPC	EQU	20H
DEL	EQU	7FH
EOF	EQU	-1
INS	EQU	12H
TAB	EQU	09H
;-----------------------------------------------------------------------------
EXTRN	BEEP:NEAR		;音ならす
EXTRN	CTOH:NEAR		;ｷｬﾗｸﾀｰをHEXに変換
EXTRN	HTOC:NEAR		;HEXをｷｬﾗｸﾀｰに変換
EXTRN	PALETTE:NEAR	;指定ﾊﾟﾚｯﾄを画面に表示
EXTRN	PARA:NEAR		;DTAの文字列取得
EXTRN	WAIT1:NEAR		;ｳｴｲﾄ
;-----------------------------------------------------------------------------
;
;
;	ＭＡＣＲＯ
;
;

;--セグメント-------------------------------------------------------

PSEG	MACRO

	CODE	SEGMENT	PUBLIC
			ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE
ENDM

;--COM形式のセグメント-----------------------------------------------

COMSEG	MACRO

	CODE	SEGMENT	PUBLIC
			ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE

			ORG	80H
			DTA	DB	80H 	DUP(0)
			ORG	100H
ENDM

;--セグメントの終わり------------------------------------------------
SEGEND	MACRO
			CODE	ENDS
ENDM

;--プロセス終了------------------------------------------------------
EXIT	MACRO	REG
			
	IFNB	<REG>
			MOV	AL,REG
	ELSE
			XOR AL,AL
	ENDIF
			MOV	AH,4CH
			INT	21H
ENDM
;--スタック----------------------------------------------------------
STACK	MACRO	SIZE
			
	IFNB	<SIZE>
			STACK_D		DB	SIZE	DUP(0)
	ELSE
			STACK_D		DB	128		DUP(0)
	ENDIF
ENDM

IF1
%OUT STD.H		READ_END
ENDIF
