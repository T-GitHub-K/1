/*=============================================================================
*								�e��_�C�A���O
*
=============================================================================*/

#define  STRICT
#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include <windowsx.h>
#include <commdlg.h>

#include "common.h"
#include "resource.h"



typedef struct {
	int num;
	char *text;
} KEYTOPTBL;



#define ID_SET_COMMA	150
#define ID_SET_BUTTON	152
#define ID_SET_ICON		153
#define ID_SET_BINARY	154
#define ID_SET_ONTOP	155
#define ID_SET_HELP		159
#define ID_SET_COLOR	160
#define ID_SET_COLOR1	161
#define ID_SET_COLOR2	162
#define ID_SET_HOTSET	163

#define ID_PROG_EDIT	500
#define ID_PROG_HELP	501

#define ID_HOT_DISP		170
#define ID_HOT_HELP		171





/*===== �v���g�^�C�v ========================================================*/

static BOOL CALLBACK About(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam);
static BOOL CALLBACK SetOptionProc(HWND hDlg, UINT iMessage, WPARAM wParam, LPARAM lParam);
static COLORREF ColorCommonDialog(HWND hWnd, COLORREF org);
static void HotkeyDialog(HWND hDlg);
static BOOL CALLBACK SetHotkeyProc(HWND hDlg, UINT iMessage, WPARAM wParam, LPARAM lParam);
static void MakeKeyText(char *buf, int mode);
static BOOL CALLBACK SetProgProc(HWND hDlg, UINT iMessage, WPARAM wParam, LPARAM lParam);



KEYTOPTBL keytoptext[] = {
	{ 0x08, "BACK" },
	{ 0x09, "TAB" },
	{ 0x0C, "CLEAR" },
	{ 0x15, "KANA" },
	{ 0x19, "KANJI" },
	{ 0x1B, "ESCAPE" },
	{ 0x1C, "CONVERT" },
	{ 0x1D, "NONCONVERT" },
	{ 0x21, "PRIOR" },
	{ 0x22, "NEXT" },
	{ 0x23, "END" },
	{ 0x24, "HOME" },
	{ 0x25, "LEFT" },
	{ 0x26, "UP" },
	{ 0x27, "RIGHT" },
	{ 0x28, "DOWN" },
	{ 0x2D, "INS" },
	{ 0x2E, "DEL" },
	{ 0x2F, "HELP" },
	{ '0', "0" },
	{ '1', "1" },
	{ '2', "2" },
	{ '3', "3" },
	{ '4', "4" },
	{ '5', "5" },
	{ '6', "6" },
	{ '7', "7" },
	{ '8', "8" },
	{ '9', "9" },
	{ 'A', "A" },
	{ 'B', "B" },
	{ 'C', "C" },
	{ 'D', "D" },
	{ 'E', "E" },
	{ 'F', "F" },
	{ 'G', "G" },
	{ 'H', "H" },
	{ 'I', "I" },
	{ 'J', "J" },
	{ 'K', "K" },
	{ 'L', "L" },
	{ 'M', "M" },
	{ 'N', "N" },
	{ 'O', "O" },
	{ 'P', "P" },
	{ 'Q', "Q" },
	{ 'R', "R" },
	{ 'S', "S" },
	{ 'T', "T" },
	{ 'U', "U" },
	{ 'V', "V" },
	{ 'W', "W" },
	{ 'X', "X" },
	{ 'Y', "Y" },
	{ 'Z', "Z" },
	{ 0x60, "0" },
	{ 0x61, "1" },
	{ 0x62, "2" },
	{ 0x63, "3" },
	{ 0x64, "4" },
	{ 0x65, "5" },
	{ 0x66, "6" },
	{ 0x67, "7" },
	{ 0x68, "8" },
	{ 0x69, "9" },
	{ 0x6A, "*" },
	{ 0x6B, "+" },
	{ 0x6C, "," },
	{ 0x6D, "-" },
	{ 0x6E, "." },
	{ 0x6F, "/" },
	{ 0x70, "F1" },
	{ 0x71, "F2" },
	{ 0x72, "F3" },
	{ 0x73, "F4" },
	{ 0x74, "F5" },
	{ 0x75, "F6" },
	{ 0x76, "F7" },
	{ 0x77, "F8" },
	{ 0x78, "F9" },
	{ 0x79, "F10" },
	{ 0x7A, "F11" },
	{ 0x7B, "F12" },
	{ 0x7C, "F13" },
	{ 0x7D, "F14" },
	{ 0x7E, "F15" },
	{ 0x7F, "F16" },
	{ 0x80, "F17" },
	{ 0x81, "F18" },
	{ 0x82, "F19" },
	{ 0x83, "F20" },
	{ 0x84, "F21" },
	{ 0x85, "F22" },
	{ 0x86, "F23" },
	{ 0x87, "F24" },
};



/*===== �O���Q�� ============================================================*/

extern HINSTANCE hInst;			/* �A�v���P�[�V�����̃C���X�^���X */
extern int DispComma;			/* �ʎ��\���t���O (0/1) */
extern int ButtonDisp;			/* �{�^���\���t���O (0/1) */
extern int EscIcon;				/* ESC�L�[�ŃA�C�R���� (0/1) */
extern int DispBinary;			/* �Q�i�\���t���O (0/1) */
extern int AlwaysOnTop;			/* ��ɑO�ɕ\���t���O (0/1) */
extern int WinPosX;				/* �E�C���h�E�\���ʒu�i�w�j */
extern int WinPosY;				/* 					 �i�x�j */
extern char prog[2][256];		/* �v���O���� */
extern COLORREF PanelColor;		/* �p�l���̐F */
extern COLORREF InnerColor;		/* �\���p�l���̐F */
extern COLORREF TextColor;		/* �����̐F */
extern ushort KeyHotSts;		/* �z�b�g�L�[�̃V�t�g�X�e�[�^�X */
extern ushort KeyHotKey;		/* �z�b�g�L�[�̃L�[ */


/*===== ���[�J���ȃf�[�^ ====================================================*/

static int progsetnum;			/* �o�^�v���O�����ԍ� */

static ushort tmpsts;
static ushort tmpkey;



/*----- ABOUT�_�C�A���O��\�� -------------------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/
void DispAbout(HWND hWnd)
{
	DialogBox(hInst, MAKEINTRESOURCE(FHCALW_ABOUT), hWnd, About);
	return;
}


/*----- ABOUT�_�C�A���O�̃��b�Z�[�W���� ---------------------------------------
*
*	Parameter
*		HWND hDlg : �E�C���h�E�n���h��
*		UINT message : ���b�Z�[�W�ԍ�
*		WPARAM wParam : ���b�Z�[�W�� WPARAM ����
*		LPARAM lParam : ���b�Z�[�W�� LPARAM ����
*
*	Return Value
*		BOOL TRUE/FALSE
*----------------------------------------------------------------------------*/

BOOL CALLBACK About(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message)
	{
		case WM_INITDIALOG :
			return(TRUE);

		case WM_COMMAND :
			switch(GET_WM_COMMAND_ID(wParam, lParam))
			{
				case IDOK :
					EndDialog(hDlg, TRUE);
					return(TRUE);

				default:
					return(TRUE);
			}
	}
    return(FALSE);
}


/*----- �I�v�V�����ݒ�_�C�A���O��\�� ----------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

void SetOption(HWND hWnd)
{
	DialogBox(hInst, MAKEINTRESOURCE(FHCALW_SET), hWnd, SetOptionProc);
	return;
}


/*----- �I�v�V�����ݒ�_�C�A���O�̃��b�Z�[�W���� ------------------------------
*
*	Parameter
*		HWND hDlg : �E�C���h�E�n���h��
*		UINT message : ���b�Z�[�W�ԍ�
*		WPARAM wParam : ���b�Z�[�W�� WPARAM ����
*		LPARAM lParam : ���b�Z�[�W�� LPARAM ����
*
*	Return Value
*		BOOL TRUE/FALSE
*----------------------------------------------------------------------------*/

BOOL CALLBACK SetOptionProc(HWND hDlg, UINT iMessage, WPARAM wParam, LPARAM lParam)
{
	static COLORREF panel;
	static COLORREF inner;
	static COLORREF text;
	COLORREF tmp;
	HDC hDC;
	char keys[50];

	switch (iMessage)
	{
		case WM_INITDIALOG :
			panel = PanelColor;
			inner = InnerColor;
			text = TextColor;
			tmpsts = KeyHotSts;
			tmpkey = KeyHotKey;
			SendDlgItemMessage(hDlg, ID_SET_COMMA, BM_SETCHECK, DispComma, 0L);
			SendDlgItemMessage(hDlg, ID_SET_BUTTON, BM_SETCHECK, ButtonDisp, 0L);
			SendDlgItemMessage(hDlg, ID_SET_ICON, BM_SETCHECK, EscIcon, 0L);
			SendDlgItemMessage(hDlg, ID_SET_BINARY, BM_SETCHECK, DispBinary, 0L);
			SendDlgItemMessage(hDlg, ID_SET_ONTOP, BM_SETCHECK, AlwaysOnTop, 0L);
			MakeKeyText(keys, YES);
			SendDlgItemMessage(hDlg, ID_HOT_DISP, WM_SETTEXT, 0, (LPARAM)(LPCSTR)keys);
			return(TRUE);

		case WM_COMMAND :
			switch(GET_WM_COMMAND_ID(wParam, lParam))
			{
				case IDOK :
					DispComma = (int)SendDlgItemMessage(hDlg, ID_SET_COMMA, BM_GETCHECK, 0, 0L);
					ButtonDisp = (int)SendDlgItemMessage(hDlg, ID_SET_BUTTON, BM_GETCHECK, 0, 0L);
					EscIcon = (int)SendDlgItemMessage(hDlg, ID_SET_ICON, BM_GETCHECK, 0, 0L);
					DispBinary = (int)SendDlgItemMessage(hDlg, ID_SET_BINARY, BM_GETCHECK, 0, 0L);
					AlwaysOnTop = (int)SendDlgItemMessage(hDlg, ID_SET_ONTOP, BM_GETCHECK, 0, 0L);
					PanelColor = panel;
					InnerColor = inner;
					TextColor = text;
					KeyHotSts = tmpsts;
					KeyHotKey = tmpkey;
					EndDialog(hDlg, TRUE);
					break;

				case IDCANCEL :
					EndDialog(hDlg, FALSE);
					break;

				case ID_SET_HELP :
					WinHelp(hDlg, "Fhcalw95.HLP", HELP_CONTEXT, 3);
					break;

				case ID_SET_COLOR :
					panel = ColorCommonDialog(hDlg, panel);
					break;

				case ID_SET_COLOR1 :
					tmp = ColorCommonDialog(hDlg, inner);
					hDC = GetDC(hDlg);
					inner = GetNearestColor(hDC, tmp);
					if(tmp != inner)
						MessageBox(hDlg, "�ł��߂����F��I�т܂���", "�\���̐F", MB_OK);
					ReleaseDC(hDlg, hDC);
					break;

				case ID_SET_COLOR2 :
					tmp = ColorCommonDialog(hDlg, text);
					hDC = GetDC(hDlg);
					text = GetNearestColor(hDC, tmp);
					if(tmp != text)
						MessageBox(hDlg, "�ł��߂����F��I�т܂���", "�����̐F", MB_OK);
					ReleaseDC(hDlg, hDC);
					break;

				case ID_SET_HOTSET :
					HotkeyDialog(hDlg);
					MakeKeyText(keys, YES);
					SendDlgItemMessage(hDlg, ID_HOT_DISP, WM_SETTEXT, 0, (LPARAM)(LPCSTR)keys);
					break;

				default:
					return(FALSE);
			}
            break;

		default:
			return(FALSE);
	}
	return(TRUE);
}


/*----- �F�ݒ�R�����_�C�A���O��\�� ------------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*		COLORREF org : �f�t�H���g�̐F
*
*	Return Value
*		COLORREF �F
*----------------------------------------------------------------------------*/

static COLORREF ColorCommonDialog(HWND hWnd, COLORREF org)
{
	CHOOSECOLOR ccTemp;
	COLORREF crTemp[16];
	int i;

	for(i = 0; i < 16; i++)
		crTemp[i] = RGB(0, 0, 0);

	ccTemp.lStructSize = sizeof(CHOOSECOLOR);
	ccTemp.hwndOwner = hWnd;
	ccTemp.hInstance = 0;
	ccTemp.rgbResult = org;
	ccTemp.lpCustColors = crTemp;
	ccTemp.Flags = CC_RGBINIT;
	ccTemp.lCustData = 0L;
	ccTemp.lpfnHook = NULL;
	ccTemp.lpTemplateName = NULL;
	if(ChooseColor(&ccTemp) == TRUE)
		org = ccTemp.rgbResult;

	return(org);
}


/*----- �z�b�g�L�[�ݒ�_�C�A���O��\�� ----------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

static void HotkeyDialog(HWND hWnd)
{
	DialogBox(hInst, MAKEINTRESOURCE(FHCALW_HOTKEY), hWnd, SetHotkeyProc);
	return;
}


/*----- �z�b�g�L�[�ݒ�_�C�A���O�̃��b�Z�[�W���� ------------------------------
*
*	Parameter
*		HWND hDlg : �E�C���h�E�n���h��
*		UINT message : ���b�Z�[�W�ԍ�
*		WPARAM wParam : ���b�Z�[�W�� WPARAM ����
*		LPARAM lParam : ���b�Z�[�W�� LPARAM ����
*
*	Return Value
*		BOOL TRUE/FALSE
*----------------------------------------------------------------------------*/

BOOL CALLBACK SetHotkeyProc(HWND hDlg, UINT iMessage, WPARAM wParam, LPARAM lParam)
{
	char keys[256];
	int i;

	switch (iMessage)
	{
		case WM_INITDIALOG :
			SetTimer(hDlg, 1, 50, NULL);
			return(TRUE);

		case WM_TIMER :
			GetKeyboardState((BYTE FAR *)keys);
			tmpsts = 0;
			tmpkey = 0;
			if(keys[VK_SHIFT] & 0x80)
				tmpsts |= KEY_STS_SHIFT;
			if(keys[VK_CONTROL] & 0x80)
				tmpsts |= KEY_STS_CTRL;
			if(keys[VK_MENU] & 0x80)
				tmpsts |= KEY_STS_ALT;
			for(i = 0; i < sizeof(keytoptext) / sizeof(KEYTOPTBL); i++)
			{
				if(keys[keytoptext[i].num] & 0x80)
				{
					tmpkey = keytoptext[i].num;
					break;
				}
			}

			MakeKeyText(keys, NO);
			SendDlgItemMessage(hDlg, ID_HOT_DISP, WM_SETTEXT, 0, (LPARAM)(LPCSTR)keys);
			if(tmpkey != 0)
				KillTimer(hDlg, 1);
            break;

		case WM_COMMAND :
			switch(GET_WM_COMMAND_ID(wParam, lParam))
			{
				case IDOK :
					KillTimer(hDlg, 1);
					EndDialog(hDlg, FALSE);
					break;

				case IDCANCEL :		/* �N���A */
					SetTimer(hDlg, 1, 50, NULL);
					break;

				case ID_HOT_HELP :
					KillTimer(hDlg, 1);
					WinHelp(hDlg, "Fhcalw95.HLP", HELP_CONTEXT, 4);
					SetTimer(hDlg, 1, 50, NULL);
					break;

				default:
					return(FALSE);
			}
            break;

		default:
			return(FALSE);
	}
	return(TRUE);
}


/*----- �z�b�g�L�[�̕\���p��������쐬 ----------------------------------------
*
*	Parameter
*		char *buf : ������̊i�[�ʒu
*		int mode : �z�b�g�L�[���g�p���Ȃ����Ɂu�g�p���Ȃ��v���Z�b�g���邩�ǂ���
*			YES/NO
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

static void MakeKeyText(char *buf, int mode)
{
	int i;

	if((mode == YES) && (tmpkey == 0))
		strcpy(buf, "�g�p���Ȃ�");
	else
	{
		*buf = NUL;
		if(tmpsts & KEY_STS_ALT)
			strcat(buf, "Alt+");
		if(tmpsts & KEY_STS_CTRL)
			strcat(buf, "Ctrl+");
		if(tmpsts & KEY_STS_SHIFT)
			strcat(buf, "Shift+");

		if(tmpkey != 0)
		{
			for(i = 0; i < sizeof(keytoptext) / sizeof(KEYTOPTBL); i++)
			{
				if(keytoptext[i].num == tmpkey)
				{
					strcat(buf, keytoptext[i].text);
					break;
				}
			}
		}
	}
	return;
}


/*----- �v���O�������̓_�C�A���O��\�� ----------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*		int num : �v���O�����ԍ�
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

void SetProgram(HWND hWnd, int num)
{
	progsetnum = num - 1;
	DialogBox(hInst, MAKEINTRESOURCE(FHCALW_PROG), hWnd, SetProgProc);
	return;
}


/*----- �v���O�������̓_�C�A���O�̃��b�Z�[�W���� ------------------------------
*
*	Parameter
*		HWND hDlg : �E�C���h�E�n���h��
*		UINT message : ���b�Z�[�W�ԍ�
*		WPARAM wParam : ���b�Z�[�W�� WPARAM ����
*		LPARAM lParam : ���b�Z�[�W�� LPARAM ����
*
*	Return Value
*		BOOL TRUE/FALSE
*----------------------------------------------------------------------------*/

BOOL CALLBACK SetProgProc(HWND hDlg, UINT iMessage, WPARAM wParam, LPARAM lParam)
{
	char buf[20];

	switch (iMessage)
	{
		case WM_INITDIALOG :
			SendDlgItemMessage(hDlg, ID_PROG_EDIT, EM_LIMITTEXT, 255, 0L);
			SendDlgItemMessage(hDlg, ID_PROG_EDIT, WM_SETTEXT, 0, (LPARAM)(LPCSTR)prog[progsetnum]);
			wsprintf(buf, "�v���O����%d", progsetnum + 1);
			SetWindowText(hDlg, buf);
			return(TRUE);

		case WM_COMMAND :
			switch(GET_WM_COMMAND_ID(wParam, lParam))
			{
				case IDOK :
					SendDlgItemMessage(hDlg, ID_PROG_EDIT, WM_GETTEXT, 256, (LPARAM)(LPCSTR)prog[progsetnum]);
					EndDialog(hDlg, TRUE);
					break;

				case IDCANCEL :
					EndDialog(hDlg, FALSE);
					break;

				case ID_PROG_HELP :
					WinHelp(hDlg, "Fhcalw95.HLP", HELP_CONTEXT, 5);
					break;

				default:
					return(FALSE);
			}
            break;

		default:
			return(FALSE);
	}
	return(TRUE);
}


