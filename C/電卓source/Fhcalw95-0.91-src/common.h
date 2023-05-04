


#define ulong unsigned long
#define ushort unsigned short
#define uint unsigned int
#define uchar unsigned char


#define COORDSIZE		long


#define NUL				'\0'

#define YES				-1
#define NO				0

#define SUCCESS			-1
#define FAIL			0

#define NUM_INP			0
#define NUM_DISP		1
#define NUM_ERR			2

#define MODE_NONE		-1
#define MODE_DEC		0
#define MODE_HEX		1

#define MAXINP_DEC		14
#define MAXINP_HEX		8

#define ID_DISPLAY_DEC	400
#define ID_DISPLAY_HEX	401
#define ID_DISPLAY_STS	402
#define ID_DISPLAY_BIN	403

#define ERR_LONG	0
#define ERR_CLIP	1
#define ERR_OVER	2
#define ERR_SQRT	3
#define ERR_DIV0	4
#define ERR_PROMPT	5
#define ERR_CHAR	6
#define ERR_PAR		7



#define KEY_STS_ALT		0x0001
#define KEY_STS_SHIFT	0x0002
#define KEY_STS_CTRL	0x0004


#define ID_PLUSMINUS_B	0xFE









#define BUT_TOP		1000
#define BUT_BTM		1255
#define BUT_QUIT	(BUT_TOP + 'Q')
#define BUT_QUIT_NF	(BUT_TOP + 'Z')
#define BUT_ICON	(BUT_TOP + 'I')
#define BUT_MENU	(BUT_TOP + 'Z')
#define BUT_MENU_K	(BUT_TOP + 'N')
#define BUT_LPAR	(BUT_TOP + '(')
#define BUT_RPAR	(BUT_TOP + ')')
#define BUT_AC		(BUT_TOP + '{')
#define BUT_CE		(BUT_TOP + '}')
#define BUT_0		(BUT_TOP + '0')
#define BUT_1		(BUT_TOP + '1')
#define BUT_2		(BUT_TOP + '2')
#define BUT_3		(BUT_TOP + '3')
#define BUT_4		(BUT_TOP + '4')
#define BUT_5		(BUT_TOP + '5')
#define BUT_6		(BUT_TOP + '6')
#define BUT_7		(BUT_TOP + '7')
#define BUT_8		(BUT_TOP + '8')
#define BUT_9		(BUT_TOP + '9')
#define BUT_A		(BUT_TOP + 'A')
#define BUT_B		(BUT_TOP + 'B')
#define BUT_C		(BUT_TOP + 'C')
#define BUT_D		(BUT_TOP + 'D')
#define BUT_E		(BUT_TOP + 'E')
#define BUT_F		(BUT_TOP + 'F')
#define BUT_PLUS	(BUT_TOP + '+')
#define BUT_MINUS	(BUT_TOP + '-')
#define BUT_TIMES	(BUT_TOP + '*')
#define BUT_DIVIDE	(BUT_TOP + '/')
#define BUT_EQUAL	(BUT_TOP + '=')
#define BUT_DOT		(BUT_TOP + '.')
#define BUT_COMMA	(BUT_TOP + ',')
#define BUT_PER		(BUT_TOP + '%')
#define BUT_SQR		(BUT_TOP + 'S')
#define BUT_HEX_DEC	(BUT_TOP + ' ')
#define BUT_RUN1	(BUT_TOP + '[')
#define BUT_RUN2	(BUT_TOP + ']')
#define BUT_ESC		(BUT_TOP + 0x1B)	/* ESC */
#define BUT_BS		(BUT_TOP + 0x08)	/* BS */
#define BUT_RET		(BUT_TOP + 0x0D)	/* RET */
#define BUT_MRET	(BUT_TOP + 'R')
#define BUT_MCLR	(BUT_TOP + 'L')
#define BUT_MPLUS	(BUT_TOP + 'P')
#define BUT_MMINUS	(BUT_TOP + 'M')

#define MENU_COPY	2000
#define MENU_PASTE	2001
#define MENU_PROG1	2002
#define MENU_PROG2	2003
#define MENU_SET	2004
#define MENU_HELP	2005
#define MENU_ABOUT	2006





/*===== ストラクチャ ========================================================*/

/* ボタンデータテーブル */


typedef struct {
	POINT pos;				/* 位置 */
	SIZE size;				/* サイズ */
	int mesg;				/* ボタンに対応するメッセージ */
	int Type;
	char Text[5];
	HWND hWnd;				/* ボタンのウインドウハンドル */
} BUTTONDATA;





/*----- main.c -----*/

int PASCAL WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpszCmdLine, int cmdShow);
void Error(int errno);
int PreProcess(char *istr, char *ostr);
BUTTONDATA *AskButtonData(int Msg);

/*----- button.c -----*/

void DrawButton(HWND hWnd, int Id, DRAWITEMSTRUCT *DrawItem);
void DrawButtonText(HDC hDC, int mode, RECT *Region, int ButtonId);
void MakeButtonFont(void);
void DeleteButtonFont(void);

/*----- registry.c -----*/

void SaveINIfile(HWND hWnd);
void LoadINIfile(void);

/*----- menu.c -----*/

void DispMenu(HWND hWnd, int key);

/*----- dialog.c -----*/

void DispAbout(HWND hWnd);
void SetOption(HWND hWnd);
void SetProgram(HWND hWnd, int num);

/*----- clipbd.c -----*/

void ToClipboard(HWND hWnd);
void FromClipboard(HWND hWnd);

/*----- mouse.c -----*/

void MouseOpe(HWND hWnd, WPARAM wParam, LPARAM lParam);
void ReleaseDownedButton(void);
void DragOpe(HWND hWnd, WPARAM wParam, LPARAM lParam);

/*----- misc.c -----*/

void StrCpyLine(char *dst, char *src, int max);
void StrbCpy(char *dst, char *src, int len);
int isSjis(char c);

/*----- imectrl.c -----*/

void ImeCreate(void);
void ImeDestroy(void);
void ImeSetOpen(HWND hWnd, int mode);
WORD ImeGetOpen(HWND hWnd);
