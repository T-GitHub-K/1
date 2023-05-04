/*=============================================================================
*								INIファイル関係
*
=============================================================================*/

#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include <windowsx.h>

#include "common.h"


/*===== 外部参照 ============================================================*/

extern int DispComma;			/* 位取り表示フラグ (0/1) */
extern int ButtonDisp;			/* ボタン表示フラグ (0/1) */
extern int EscIcon;				/* ESCキーでアイコン化 (0/1) */
extern int DispBinary;			/* ２進表示フラグ (0/1) */
extern int AlwaysOnTop;			/* 常に前に表示フラグ (0/1) */
extern int WinPosX;				/* ウインドウ表示位置（Ｘ） */
extern int WinPosY;				/* 					 （Ｙ） */
extern char prog[2][256];		/* プログラム */
extern COLORREF PanelColor;		/* パネルの色 */
extern COLORREF InnerColor;		/* 表示パネルの色 */
extern COLORREF TextColor;		/* 文字の色 */
extern ushort KeyHotSts;		/* ホットキーのシフトステータス */
extern ushort KeyHotKey;		/* ホットキーのキー */


/*----- レジストリに設定値を保存 ----------------------------------------------
*
*	Parameter
*		HWND hWnd : ウインドウハンドル
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

void SaveINIfile(HWND hWnd)
{
	HKEY hKey1;
	HKEY hKey2;
	HKEY hKey3;
	HKEY hKey4;
	DWORD Dispos;

	if(RegCreateKeyEx(HKEY_CURRENT_USER, "Software", 0, "", REG_OPTION_NON_VOLATILE, KEY_CREATE_SUB_KEY, NULL, &hKey1, &Dispos) == ERROR_SUCCESS)
	{
		if(RegCreateKeyEx(hKey1, "Fhcal for win32", 0, "", REG_OPTION_NON_VOLATILE, KEY_CREATE_SUB_KEY, NULL, &hKey2, &Dispos) == ERROR_SUCCESS)
		{
			if(RegCreateKeyEx(hKey2, "Fhcalw32", 0, "", REG_OPTION_NON_VOLATILE, KEY_CREATE_SUB_KEY, NULL, &hKey3, &Dispos) == ERROR_SUCCESS)
			{
				if(RegCreateKeyEx(hKey3, "Options", 0, "", REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, NULL, &hKey4, &Dispos) == ERROR_SUCCESS)
				{
					RegSetValueEx(hKey4, "DispComma", 0, REG_DWORD, (CONST BYTE *)&DispComma, sizeof(int));
					RegSetValueEx(hKey4, "ButtonDisp", 0, REG_DWORD, (CONST BYTE *)&ButtonDisp, sizeof(int));
					RegSetValueEx(hKey4, "EscIcon", 0, REG_DWORD, (CONST BYTE *)&EscIcon, sizeof(int));
					RegSetValueEx(hKey4, "DispBinary", 0, REG_DWORD, (CONST BYTE *)&DispBinary, sizeof(int));
					RegSetValueEx(hKey4, "AlwaysOnTop", 0, REG_DWORD, (CONST BYTE *)&AlwaysOnTop, sizeof(int));
					RegCloseKey(hKey4);
				}
				if(RegCreateKeyEx(hKey3, "Position", 0, "", REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, NULL, &hKey4, &Dispos) == ERROR_SUCCESS)
				{
					RegSetValueEx(hKey4, "PosX", 0, REG_DWORD, (CONST BYTE *)&WinPosX, sizeof(int));
					RegSetValueEx(hKey4, "PosY", 0, REG_DWORD, (CONST BYTE *)&WinPosY, sizeof(int));
					RegCloseKey(hKey4);
				}
				if(RegCreateKeyEx(hKey3, "Color", 0, "", REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, NULL, &hKey4, &Dispos) == ERROR_SUCCESS)
				{
					RegSetValueEx(hKey4, "BodyColor", 0, REG_DWORD, (CONST BYTE *)&PanelColor, sizeof(COLORREF));
					RegSetValueEx(hKey4, "PanelColor", 0, REG_DWORD, (CONST BYTE *)&InnerColor, sizeof(COLORREF));
					RegSetValueEx(hKey4, "TextColor", 0, REG_DWORD, (CONST BYTE *)&TextColor, sizeof(COLORREF));
					RegCloseKey(hKey4);
				}
				if(RegCreateKeyEx(hKey3, "Hotkey", 0, "", REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, NULL, &hKey4, &Dispos) == ERROR_SUCCESS)
				{
					RegSetValueEx(hKey4, "HotShift", 0, REG_BINARY, (CONST BYTE *)&KeyHotSts, sizeof(ushort));
					RegSetValueEx(hKey4, "HotKey", 0, REG_BINARY, (CONST BYTE *)&KeyHotKey, sizeof(ushort));
					RegCloseKey(hKey4);
				}
				if(RegCreateKeyEx(hKey3, "Program", 0, "", REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, NULL, &hKey4, &Dispos) == ERROR_SUCCESS)
				{
					RegSetValueEx(hKey4, "Prog1", 0, REG_SZ, (CONST BYTE *)prog[0], strlen(prog[0])+1);
					RegSetValueEx(hKey4, "Prog2", 0, REG_SZ, (CONST BYTE *)prog[1], strlen(prog[1])+1);
					RegCloseKey(hKey4);
				}
				RegCloseKey(hKey3);
			}
			RegCloseKey(hKey2);
		}
		RegCloseKey(hKey1);
	}
	return;
}


/*----- レジストリから設定値を呼び出す ----------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

void LoadINIfile(void)
{
	RECT rc;
	HKEY hKey1;
	HKEY hKey2;
	HKEY hKey3;
	HKEY hKey4;
	DWORD Size;
	DWORD Type;

	GetWindowRect(GetDesktopWindow(), &rc);
	WinPosX = (rc.right - rc.left - 316) / 2;
	WinPosY = (rc.bottom - rc.top - 198) / 2;

	DispComma = 0;
	ButtonDisp = 0;
	EscIcon = 0;
	DispBinary = 0;
	AlwaysOnTop = 0;
	PanelColor = RGB(128, 128, 0);
	InnerColor = RGB(0, 0, 0);
	TextColor = RGB(0, 255, 0);
	prog[0][0] = NUL;
	prog[1][0] = NUL;
	KeyHotSts = 0;
	KeyHotKey = 0;

	if(RegOpenKeyEx(HKEY_CURRENT_USER, "Software", 0, KEY_READ, &hKey1) == ERROR_SUCCESS)
	{
		if(RegOpenKeyEx(hKey1, "Fhcal for win32", 0, KEY_READ, &hKey2) == ERROR_SUCCESS)
		{
			if(RegOpenKeyEx(hKey2, "Fhcalw32", 0, KEY_READ, &hKey3) == ERROR_SUCCESS)
			{
				if(RegOpenKeyEx(hKey3, "Options", 0, KEY_READ, &hKey4) == ERROR_SUCCESS)
				{
					Size = sizeof(int);
					RegQueryValueEx(hKey4, "DispComma", NULL, &Type, (BYTE *)&DispComma, &Size);
					Size = sizeof(int);
					RegQueryValueEx(hKey4, "ButtonDisp", NULL, &Type, (BYTE *)&ButtonDisp, &Size);
					Size = sizeof(int);
					RegQueryValueEx(hKey4, "EscIcon", NULL, &Type, (BYTE *)&EscIcon, &Size);
					Size = sizeof(int);
					RegQueryValueEx(hKey4, "DispBinary", NULL, &Type, (BYTE *)&DispBinary, &Size);
					Size = sizeof(int);
					RegQueryValueEx(hKey4, "AlwaysOnTop", NULL, &Type, (BYTE *)&AlwaysOnTop, &Size);
					RegCloseKey(hKey4);
				}
				if(RegOpenKeyEx(hKey3, "Position", 0, KEY_READ, &hKey4) == ERROR_SUCCESS)
				{
					Size = sizeof(int);
					RegQueryValueEx(hKey4, "PosX", NULL, &Type, (BYTE *)&WinPosX, &Size);
					Size = sizeof(int);
					RegQueryValueEx(hKey4, "PosY", NULL, &Type, (BYTE *)&WinPosY, &Size);
					RegCloseKey(hKey4);
				}
				if(RegOpenKeyEx(hKey3, "Color", 0, KEY_READ, &hKey4) == ERROR_SUCCESS)
				{
					Size = sizeof(COLORREF);
					RegQueryValueEx(hKey4, "BodyColor", NULL, &Type, (BYTE *)&PanelColor, &Size);
					Size = sizeof(COLORREF);
					RegQueryValueEx(hKey4, "PanelColor", NULL, &Type, (BYTE *)&InnerColor, &Size);
					Size = sizeof(COLORREF);
					RegQueryValueEx(hKey4, "TextColor", NULL, &Type, (BYTE *)&TextColor, &Size);
					RegCloseKey(hKey4);
				}
				if(RegOpenKeyEx(hKey3, "Hotkey", 0, KEY_READ, &hKey4) == ERROR_SUCCESS)
				{
					Size = sizeof(ushort);
					RegQueryValueEx(hKey4, "HotShift", NULL, &Type, (BYTE *)&KeyHotSts, &Size);
					Size = sizeof(ushort);
					RegQueryValueEx(hKey4, "HotKey", NULL, &Type, (BYTE *)&KeyHotKey, &Size);
					RegCloseKey(hKey4);
				}
				if(RegOpenKeyEx(hKey3, "Program", 0, KEY_READ, &hKey4) == ERROR_SUCCESS)
				{
					Size = 256;
					RegQueryValueEx(hKey4, "Prog1", NULL, &Type, (BYTE *)prog[0], &Size);
					Size = 256;
					RegQueryValueEx(hKey4, "Prog2", NULL, &Type, (BYTE *)prog[1], &Size);
					RegCloseKey(hKey4);
				}
				RegCloseKey(hKey3);
			}
			RegCloseKey(hKey2);
		}
		RegCloseKey(hKey1);
	}
	return;
}



