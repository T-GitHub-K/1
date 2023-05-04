/*=============================================================================
*									メニュー
*
=============================================================================*/

#define  STRICT
#include <windows.h>
#include <stdlib.h>
#include <windowsx.h>

#include "common.h"



/*----- ポップアップメニューを表示 --------------------------------------------
*
*	Parameter
*		HWND hWnd : ウインドウハンドル
*		int key
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

void DispMenu(HWND hWnd, int key)
{
	POINT point;
	RECT rc;
	HMENU hMenu;

	if(key == BUT_MENU_K)
		GetCursorPos(&point);
	else
	{
		GetWindowRect(hWnd, &rc);
		point.x = rc.left + 20;
		point.y = rc.top + 61;
	}

	hMenu = CreatePopupMenu();
	AppendMenu(hMenu, MF_STRING, MENU_COPY, "コピー(&C)	Ctrl+C");
	AppendMenu(hMenu, MF_STRING, MENU_PASTE, "貼り付け（計算）(&P)	Ctrl+V");
	AppendMenu(hMenu, MF_SEPARATOR, 0, "");
	AppendMenu(hMenu, MF_STRING, MENU_PROG1, "プログラム１の設定...(&1)	Shift+F1");
	AppendMenu(hMenu, MF_STRING, MENU_PROG2, "プログラム２の設定...(&2)	Shift+F2");
	AppendMenu(hMenu, MF_SEPARATOR, 0, "");
	AppendMenu(hMenu, MF_STRING, MENU_SET, "設定...(&S)");
	AppendMenu(hMenu, MF_SEPARATOR, 0, "");
	AppendMenu(hMenu, MF_STRING, MENU_HELP, "ヘルプ(&H)");
	AppendMenu(hMenu, MF_STRING, MENU_ABOUT, "Fhcalw95について(&A)");
	TrackPopupMenu(hMenu, TPM_LEFTBUTTON | TPM_RIGHTBUTTON, point.x, point.y, 0, hWnd, NULL);

	DestroyMenu(hMenu);
	return;
}


