/*=============================================================================
*								サブルーチン類
*
=============================================================================*/

#define  STRICT
#include <windows.h>
#include <stdlib.h>
#include <windowsx.h>

#include "common.h"



/*----- 改行またはNULまでをコピー ---------------------------------------------
*
*	Parameter
*		char *dst : コピー先
*		char *src : コピー元
*		int max : 長さ

*	Return Value
*		なし
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


/*----- 長さを指定した文字列のコピー ------------------------------------------
*
*	Parameter
*		char *dst : コピー先
*		char *src : コピー元
*		int len : 最大バイト数
*
*	Return Value
*		なし
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


/*----- SHIFT-JISの第１バイトかチェック ---------------------------------------
*
*	Parameter
*		char c : 文字コード
*
*	Return Value
*		int ステータス
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


