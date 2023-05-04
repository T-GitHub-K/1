/*=============================================================================
*							�N���b�v�{�[�h�֌W
*
=============================================================================*/

#define  STRICT
#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include <windowsx.h>

#include "common.h"


/*===== �O���Q�� ============================================================*/

extern int inpmode;			/* ���̓��[�h (MODE_HEX / MODE_DEC) */
extern char DecDispStr[60];		/* �\��������i�P�O�i�j */
extern char HexDispStr[30];		/*			 �i�P�U�i�j */
extern char BinDispStr[30];		/*			 �i�Q�i�j */
extern char *progpos;			/* �v���O�������s���̎��o���ʒu */
extern char prognum;			/* ���s�v���O�����ԍ� (0=�Ȃ�) */
extern char clip[256];			/* �N���b�v�{�[�h����擾�����e�L�X�g */
extern int DownedButton;		/* �����\�����̃{�^���ԍ� (-1=�Ȃ�) */



/*----- �N���b�v�{�[�h�փR�s�[ ------------------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*
*	Return Value
*		�Ȃ�
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


/*----- �N���b�v�{�[�h����y�[�X�g --------------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*
*	Return Value
*		�Ȃ�
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


