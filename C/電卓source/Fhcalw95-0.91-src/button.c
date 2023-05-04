/*=============================================================================
*									ボタン表示
*
=============================================================================*/

#define  STRICT
#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include <windowsx.h>

#include "common.h"
#include "resource.h"



extern HINSTANCE hInst;			/* アプリケーションのインスタンス */



static HFONT hFontButton = NULL;
static LOGFONT LogFontButton = {
	18, 9,
	FALSE, FALSE, FW_NORMAL, FALSE, FALSE, FALSE,
	SHIFTJIS_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
	DRAFT_QUALITY, FIXED_PITCH, ""
};


static HFONT hFontButtonSm = NULL;
static LOGFONT LogFontButtonSm = {
	12, 6,
	FALSE, FALSE, FW_NORMAL, FALSE, FALSE, FALSE,
	SHIFTJIS_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
	DRAFT_QUALITY, FIXED_PITCH, ""
};



/*----- ボタンを表示 ----------------------------------------------------------
*
*	Parameter
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

void DrawButton(HWND hWnd, int Id, DRAWITEMSTRUCT *DrawItem)
{
	HPEN hPenOld;
	HFONT hFontOld;
	int Face;
	int Light;
	int Dark;
	BUTTONDATA *But;
	HDC hDC;
	RECT Rect;
	int Mode;
	COLORREF Text;

	if((But = AskButtonData(Id)) != NULL)
	{
		Mode = 0;
		if(DrawItem->itemState & ODS_SELECTED)
		Mode = 1;

		hDC = DrawItem->hDC;
		Rect = DrawItem->rcItem;

		if((But->Type == 0) || ((But->Type == 3) && (GetFocus() == hWnd)))
		{
			Face = LTGRAY_BRUSH;
			Text = RGB(0,0,0);
		}
		else
		{
			Face = GRAY_BRUSH;
			Text = RGB(255,255,255);
		}

		if(Mode == 0)
		{
			Light = WHITE_PEN;
			Dark = BLACK_PEN;
		}
		else
		{
			Light = BLACK_PEN;
			Dark = WHITE_PEN;
		}

		FillRect(hDC, &Rect, GetStockObject(Face));

		Rect.right -= 1;
		Rect.bottom -= 1;

		hPenOld = SelectObject(hDC, GetStockObject(Light));
		MoveToEx(hDC, Rect.left, Rect.bottom, NULL);
		LineTo(hDC, Rect.left, Rect.top);
		LineTo(hDC, Rect.right, Rect.top);
		SelectObject(hDC, GetStockObject(Dark));
		LineTo(hDC, Rect.right, Rect.bottom);
		LineTo(hDC, Rect.left, Rect.bottom);
		SelectObject(hDC, hPenOld);

		if((But->Type == 0) || (But->Type == 1))
			hFontOld = SelectObject(hDC, hFontButton);
		else
			hFontOld = SelectObject(hDC, hFontButtonSm);
		SetBkMode(hDC, TRANSPARENT);
		SetTextColor(hDC, Text);
		DrawText(hDC, But->Text, strlen(But->Text), &Rect, DT_CENTER | DT_VCENTER | DT_SINGLELINE);
		SelectObject(hDC, hFontOld);
	}
	return;
}



void MakeButtonFont(void)
{
	hFontButton = CreateFontIndirect(&LogFontButton);
	hFontButtonSm = CreateFontIndirect(&LogFontButtonSm);
	return;
}



void DeleteButtonFont(void)
{
	if(hFontButton != NULL)
		DeleteObject(hFontButton);
	hFontButton = NULL;

	if(hFontButtonSm != NULL)
		DeleteObject(hFontButtonSm);
	hFontButtonSm = NULL;
	return;
}





