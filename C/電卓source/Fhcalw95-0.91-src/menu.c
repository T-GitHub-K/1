/*=============================================================================
*									���j���[
*
=============================================================================*/

#define  STRICT
#include <windows.h>
#include <stdlib.h>
#include <windowsx.h>

#include "common.h"



/*----- �|�b�v�A�b�v���j���[��\�� --------------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*		int key
*
*	Return Value
*		�Ȃ�
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
	AppendMenu(hMenu, MF_STRING, MENU_COPY, "�R�s�[(&C)	Ctrl+C");
	AppendMenu(hMenu, MF_STRING, MENU_PASTE, "�\��t���i�v�Z�j(&P)	Ctrl+V");
	AppendMenu(hMenu, MF_SEPARATOR, 0, "");
	AppendMenu(hMenu, MF_STRING, MENU_PROG1, "�v���O�����P�̐ݒ�...(&1)	Shift+F1");
	AppendMenu(hMenu, MF_STRING, MENU_PROG2, "�v���O�����Q�̐ݒ�...(&2)	Shift+F2");
	AppendMenu(hMenu, MF_SEPARATOR, 0, "");
	AppendMenu(hMenu, MF_STRING, MENU_SET, "�ݒ�...(&S)");
	AppendMenu(hMenu, MF_SEPARATOR, 0, "");
	AppendMenu(hMenu, MF_STRING, MENU_HELP, "�w���v(&H)");
	AppendMenu(hMenu, MF_STRING, MENU_ABOUT, "Fhcalw95�ɂ���(&A)");
	TrackPopupMenu(hMenu, TPM_LEFTBUTTON | TPM_RIGHTBUTTON, point.x, point.y, 0, hWnd, NULL);

	DestroyMenu(hMenu);
	return;
}


