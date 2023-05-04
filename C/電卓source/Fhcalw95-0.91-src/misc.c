/*=============================================================================
*								�T�u���[�`����
*
=============================================================================*/

#define  STRICT
#include <windows.h>
#include <stdlib.h>
#include <windowsx.h>

#include "common.h"



/*----- ���s�܂���NUL�܂ł��R�s�[ ---------------------------------------------
*
*	Parameter
*		char *dst : �R�s�[��
*		char *src : �R�s�[��
*		int max : ����

*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

void StrCpyLine(char *dst, char *src, int max)
{
	char ch;

	for(; max > 0; max--)
	{
		if(((ch = *src++) == NUL) || (ch == 0x0A))
			break;
		*dst++ = ch;
	}
	*dst = NUL;

	return;
}


/*----- �������w�肵��������̃R�s�[ ------------------------------------------
*
*	Parameter
*		char *dst : �R�s�[��
*		char *src : �R�s�[��
*		int len : �ő�o�C�g��
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

void StrbCpy(char *dst, char *src, int len)
{
	char ch;

	while(len > 0)
	{
		if((ch = *src++) == NUL)
			break;
		if(isSjis(ch) == YES)
		{
			if(len >= 2)
			{
				*dst = ch;
				if((ch = *src++) == NUL)
					break;
				dst++;
				*dst++ = ch;
				len--;
			}
			else
				break;
		}
		else
			*dst++ = ch;

		len--;
	}
	*dst = NUL;

	return;
}


/*----- SHIFT-JIS�̑�P�o�C�g���`�F�b�N ---------------------------------------
*
*	Parameter
*		char c : �����R�[�h
*
*	Return Value
*		int �X�e�[�^�X
*			YES/NO
*----------------------------------------------------------------------------*/

int isSjis(char c)
{
	int ret;

	ret = NO;
	if((((uchar)c >= (uchar)0x81) && ((uchar)c <= (uchar)0x9F)) ||
	   ((uchar)c >= (uchar)0xE0))
		ret = YES;

	return(ret);
}


