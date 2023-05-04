/*=============================================================================
*							クリップボード関係
*
=============================================================================*/

#define  STRICT
#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include <windowsx.h>

#include "common.h"


/*===== 外部参照 ============================================================*/

extern int inpmode;			/* 入力モード (MODE_HEX / MODE_DEC) */
extern char DecDispStr[60];		/* 表示文字列（１０進） */
extern char HexDispStr[30];		/*			 （１６進） */
extern char BinDispStr[30];		/*			 （２進） */
extern char *progpos;			/* プログラム実行時の取り出し位置 */
extern char prognum;			/* 実行プログラム番号 (0=なし) */
extern char clip[256];			/* クリップボードから取得したテキスト */
extern int DownedButton;		/* 押下表示中のボタン番号 (-1=なし) */



/*----- クリップボードへコピー ------------------------------------------------
*
*	Parameter
*		HWND hWnd : ウインドウハンドル
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

void ToClipboard(HWND hWnd)
{
	void far* gbuf;
	HGLOBAL cbhdl;
	char *str;
	int len;

	if(OpenClipboard(hWnd))
	{
		if(EmptyClipboard())
		{
			str = DecDispStr;
			if(inpmode == MODE_HEX)
				str = HexDispStr;

			len = strlen(str);

			cbhdl = GlobalAlloc(GHND, len+1);
			gbuf = GlobalLock(cbhdl);
			_fstrcpy(gbuf, str);
			GlobalUnlock(cbhdl);
			SetClipboardData(CF_TEXT, cbhdl);
		}
		CloseClipboard();
	}
	return;
}


/*----- クリップボードからペースト --------------------------------------------
*
*	Parameter
*		HWND hWnd : ウインドウハンドル
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

void FromClipboard(HWND hWnd)
{
	HGLOBAL cbhdl;
	void far *cl;
	char tmp[256];

	if(OpenClipboard(hWnd))
	{
		if((cbhdl = GetClipboardData(CF_TEXT)) != NULL)
		{
			cl = GlobalLock(cbhdl);
			if(_fstrlen(cl) > 255)
				Error(ERR_LONG);
			else
			{
				_fstrcpy(tmp, cl);
				if(PreProcess(tmp, clip) == 0)
				{
					progpos = clip;
					prognum = 5;
				}
				else
					Error(ERR_PAR);
			}
			GlobalUnlock(cbhdl);
		}
		CloseClipboard();
	}
	else
		Error(ERR_CLIP);

	return;
}


