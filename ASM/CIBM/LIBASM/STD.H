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

IF1
%OUT STD.H		READ_END
ENDIF
