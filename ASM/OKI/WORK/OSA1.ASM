INCLUDE	MDOS.H
INCLUDE	STD.H
INCLUDE	UTY.H
INCLUDE	MACRO.H


MSGY	EQU	0
MSGX	EQU	0

CODE	SEGMENT	PUBLIC
	ASSUME	CS:CODE,DS:CODE,ES:CODE

	ORG	100H

START:		
                                     
		;INPUT_M	MACRO	LY,LX,STRING,COUNT,OP,FEP
		;LOCATE_M	MACRO	LY,LX
		;COLOR_M	MACRO	FGC,BGC,FG,P

		COLOR_M		1,7,1,0	;FG=青 BG=白 拡張=BG,明
		DISPLAY_CHAR	CLS

		COLOR_M		7,2,0,1	;FG=白 BG=赤 拡張=FG,暗
		LOCATE_M	1,26
		DISPLAY		TITLE0

NEXT:
		COLOR_M		7,4,1,1	;FG=白 BG=緑 拡張=BG,暗
		COLOR_M		7,4,0,0	;FG=白 BG=緑 拡張=FG,明
		LOCATE_M	8,10
		DISPLAY		GAMEN0
		LOCATE_M	9,10
		DISPLAY		GAMEN1
		LOCATE_M	10,10
		DISPLAY		GAMEN2
		LOCATE_M	11,10
		DISPLAY		GAMEN3
		LOCATE_M	12,10
		DISPLAY		GAMEN4
		LOCATE_M	13,10
		DISPLAY		GAMEN5
				

MSG_INP:	
		DISPLAY		INPCLS
		DIR_CONSOLE_INPUT
		CMP	AL,"*"
		JZ	EXIT
		DISPLAY_CHAR	BEEP
		JMP	SHORT	MSG_INP

EXIT:
		COLOR_M		7,0,0,0	
		COLOR_M		7,0,1,0	
		DISPLAY_CHAR	CLS
		DISPLAY		INPPRN

		END_PROCESS 0


TITLE0	DB	"＊  運行管理業務変更処理  ＊"
	DB	"$"
     
GAMEN0	DB "",CR,LF
DB	"$" 
GAMEN1	DB "   ※ 運行管理業務のプログラムの修正が終了しました ※   ",CR,LF
DB	"$" 
GAMEN2	DB "                                                        ",CR,LF
DB	"$" 
GAMEN3	DB "         フロッピーを抜いて電源を切って下さい。         ",CR,LF
DB	"$" 
GAMEN4	DB "            〔＊〕キーでＤＯＳに戻ります                ",CR,LF
DB	"$" 
GAMEN5	DB "",CR,LF
DB	"$" 
INPCLS	DB	ESC,"0$"
INPPRN	DB	ESC,"1$"

CODE	ENDS
	END	START
