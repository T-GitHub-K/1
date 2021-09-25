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
				

MSG_INP:	LOCATE_M	24,0
		COLOR_M		6,0,0,0
		DISPLAY		MSG5
		DIR_CONSOLE_INPUT
		CMP	AL,"N"
		JZ	MSG_EXIT
		MOV	END_C,1
		CMP	AL,"*"
		JZ	EXIT
		CMP	AL,"Y"
		MOV	END_C,2
		JZ	EXIT
		DISPLAY_CHAR	BEEP
		JMP	SHORT	MSG_INP
MSG_EXIT:
		COLOR_M		1,7,1,0
		LOCATE_M	24,5
		DISPLAY		MSG5_CLS
		MOV	END_C,0

EXIT:
		COLOR_M		1,7,1,0	;FG=青 BG=白 拡張=BG,明
		DISPLAY_CHAR	CLS

		END_PROCESS END_C


TITLE0	DB	"＊  タクコンデモ初期設定  ＊"
	DB	"$"
     
GAMEN0	DB "",CR,LF
DB	"$" 
GAMEN1	DB "         ※ 今からタクコンデモの設定をします ※         ",CR,LF
DB	"$" 
GAMEN2	DB "                                                        ",CR,LF
DB	"$" 
GAMEN3	DB "           データーを初期化しますか？(Ｙ／Ｎ)           ",CR,LF
DB	"$" 
GAMEN4	DB "                                                        ",CR,LF
DB	"$" 
GAMEN5	DB "",CR,LF
DB	"$" 

MSG5	DB	"処理選択　　　　はい･･･〔Ｙ〕   いいえ･･･〔Ｎ〕   中止の時は･･･〔＊〕  "
	DB	"$"
MSG5_CLS	DB	"                                                           "
	DB	"$"
END_C	DB	0

CODE	ENDS
	END	START
