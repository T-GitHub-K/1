ECHO OFF
CO 2,7
CLS
LO 8,21
                  ECHO   電源を切ってもよろしいですか？
LO 11,21
                  ECHO 電源を切る･･･Ｙ      中止する･･･Ｎ
LO 11,60
SELECT Y
IF ERRORLEVEL 99 GOTO EXIT
CD \
SHIP
I:PWOFF
:EXIT
CO 7,0
CLS
