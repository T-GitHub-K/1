/*=============================================================================
*							ＦＨＣＡＬ for Windows
*
=============================================================================*/

#define  STRICT
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <math.h>
#include <string.h>
#include <mbstring.h>
#include <ctype.h>
#include <windowsx.h>

#include "common.h"
#include "resource.h"


/*===== 関数プロトタイプ ====================================================*/

static int InitApp(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpszCmdLine, int cmdShow);
static LRESULT CALLBACK FhcalwWndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam);
static void QuitProcess(HWND hWnd);
static void SetWinPos(void);
static void SetWinSize(void);
static void SetWindowZorder(int flg);
static void FhcalwPaint(HWND hWnd);
static void DispInputInd(HDC hDC);
static void DispInputInd2(HDC hDC);
static void UpdateText(int pos);
static void MakePanelFont(void);
static void DeletePanelFont(void);
static void DispText2(HDC hDC, int Num, char *Text);
static void PaintRegion(HDC hDC, HRGN hRgn, COLORREF rgb);
static void CommandProc(HWND hWnd, int key);
static int InpNum(int key);
static int CalcOpe(HWND hWnd, int key);
static void MenuOpe(HWND hWnd, int key);
static void InsertKey(char key);
static void Clear(void);
static void Change2Dec(void);
static void Change2Hex(void);
static void ResetTempMode(void);
static void RunProgram(HWND hWnd, int num);
static void ProgramProc(HWND hWnd);
static char *GetPromptStr(char *str, char *prompt);
static void CalcOp1(void);
static void CalcOp2(void);
static void CalcSqrt(void);
static void CalcParcent(void);
static long double GetNum(void);
static void PushNumber(void);
static void PushStack(long double num);
static void PopStack(void);
static void DispNormalBar(void);
static void DispProgramBar(char *prompt);
static void SetDisplay(int type);
static void MakeDecStr(long double num, char *str);
static void ReformDecStr(char *str);
static void MakeHexStr(long double num, char *str);
static void ReformHexStr(char *str);
static void MakeBinStr(long double num, char *str);
static long double DecStr2Num(void);
static long double HexStr2Num(void);

static void UpdateIndicater(void);


static int SetHotkey(void);
static void ReleaseHotkey(void);

//static void MakeTableMetrix(HWND hDC);
//static void CalcPoint(POINT *point, int n);


//static void CalcPointX(COORDSIZE *x);
//static void CalcPointY(COORDSIZE *y);

static void MapWindowButton(void);
static void DestroyAllButton(void);


static void EraseBackGround(HWND hWnd, HDC hDC);

void ConOutDec(char *Prompt, int Num);



#define WM_CLICK_ICON		(WM_USER+1)




/*===== テーブル ============================================================*/

/* ボタンデータテーブル */

BUTTONDATA Buttons[] = {
	{ { 12, 18}, {48,14}, BUT_QUIT,    3, "Quit", NULL },
	{ { 12, 36}, {48,14}, BUT_ICON,    2, "Icon", NULL },
	{ { 12, 54}, {48,14}, BUT_MENU,    2, "Menu", NULL },

	{ { 12, 81}, {24,24}, BUT_7,       0, "７", NULL },
	{ { 40, 81}, {24,24}, BUT_8,       0, "８", NULL },
	{ { 68, 81}, {24,24}, BUT_9,       0, "９", NULL },
	{ { 96, 81}, {24,24}, BUT_E,       0, "Ｅ", NULL },
	{ {124, 81}, {24,24}, BUT_F,       0, "Ｆ", NULL },
	{ {152, 81}, {24,24}, BUT_LPAR,    1, "(", NULL },
	{ {180, 81}, {24,24}, BUT_RPAR,    1, ")", NULL },
	{ {208, 81}, {24,24}, BUT_AC,      1, "AC", NULL },
	{ {236, 81}, {24,24}, BUT_MRET,    1, "MR", NULL },

	{ { 12,108}, {24,24}, BUT_4,       0, "４", NULL },
	{ { 40,108}, {24,24}, BUT_5,       0, "５", NULL },
	{ { 68,108}, {24,24}, BUT_6,       0, "６", NULL },
	{ { 96,108}, {24,24}, BUT_C,       0, "Ｃ", NULL },
	{ {124,108}, {24,24}, BUT_D,       0, "Ｄ", NULL },
	{ {152,108}, {24,24}, BUT_MINUS,   1, "－", NULL },
	{ {180,108}, {24,24}, BUT_DIVIDE,  1, "÷", NULL },
	{ {208,108}, {24,24}, BUT_CE,      1, "CE", NULL },
	{ {236,108}, {24,24}, BUT_MCLR,    1, "MC", NULL },

	{ { 12,135}, {24,24}, BUT_1,       0, "１", NULL },
	{ { 40,135}, {24,24}, BUT_2,       0, "２", NULL },
	{ { 68,135}, {24,24}, BUT_3,       0, "３", NULL },
	{ { 96,135}, {24,24}, BUT_A,       0, "Ａ", NULL },
	{ {124,135}, {24,24}, BUT_B,       0, "Ｂ", NULL },
	{ {152,135}, {24,24}, BUT_PLUS,    1, "＋", NULL },
	{ {180,135}, {24,24}, BUT_TIMES,   1, "×", NULL },
	{ {208,135}, {24,24}, BUT_RUN1,    1, "P1", NULL },
	{ {236,135}, {24,24}, BUT_MMINUS,  1, "M-", NULL },

	{ { 12,162}, {24,24}, BUT_0,       0, "０", NULL },
	{ { 40,162}, {24,24}, BUT_DOT,     0, "．", NULL },
	{ { 68,162}, {24,24}, BUT_COMMA,   1, "±", NULL },
	{ { 96,162}, {24,24}, BUT_PER,     1, "％", NULL },
	{ {124,162}, {24,24}, BUT_SQR,     1, "√", NULL },
	{ {152,162}, {24,24}, BUT_EQUAL,   1, "＝", NULL },
	{ {180,162}, {24,24}, BUT_HEX_DEC, 1, "HD", NULL },
	{ {208,162}, {24,24}, BUT_RUN2,    1, "P2", NULL },
	{ {236,162}, {24,24}, BUT_MPLUS,   1, "M+", NULL }
};


/* 表示板表示データ */
static POINT PanelInner[5] = {{92,71},{92,9},{265,9},{265,71},{92,71}};

/* 表示板内部塗り潰し用データ */
static RECT Frame2 = {91,10,264,70};

/* インジケータ表示データ */
static POINT MarkHex[3] = {{75,34},{85,41},{75,48}};
static POINT MarkDec[3] = {{75,52},{85,59},{75,66}};

/* 数値表示位置データ */
static RECT NumDisp[3] = {{100,50,257,68},{100,32,257,50},{100,14,257,32}};


COORDSIZE NorWinSizeX = { 278 };
COORDSIZE NorWinSizeY = { 198 };
COORDSIZE NoButtonWinSizeY = { 83 };


static HFONT hFontPanel = NULL;
static LOGFONT LogFontPanel = {
	16, 8,
	FALSE, FALSE, FW_NORMAL, FALSE, FALSE, FALSE,
	SHIFTJIS_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
	DRAFT_QUALITY, FIXED_PITCH, ""
};






static char ClassStr[] = "FHCALW";


/*===== 外部参照 ============================================================*/




/*===== グローバルデータ ====================================================*/

HINSTANCE hInst;			/* アプリケーションのインスタンス */

int inpmode;				/* 入力モード (MODE_HEX / MODE_DEC) */

char DecDispStr[60];		/* 表示文字列（１０進） */
char HexDispStr[30];		/*			 （１６進） */
char BinDispStr[30];		/*			 （２進） */
char StsDispStr[30];		/*			 （ステータス） */

char *progpos;				/* プログラム実行時の取り出し位置 */
int prognum;				/* 実行プログラム番号 (0=なし) */
char clip[256];				/* クリップボードから取得したテキスト */

int WinSizeX;				/* ウインドウのサイズ（Ｘ） */
int WinSizeY;				/*					 （Ｙ） */

/* 次のものは INIファイルに登録する */

int DispComma;				/* 位取り表示フラグ (0/1) */
int ButtonDisp;				/* ボタン表示フラグ (0/1) */
int EscIcon;				/* ESCキーでアイコン化 (0/1) */
int DispBinary;				/* ２進表示フラグ (0/1) */
int AlwaysOnTop;			/* 常に前に表示フラグ (0/1) */
int WinPosX = CW_USEDEFAULT;				/* ウインドウ表示位置（Ｘ） */
int WinPosY = 0;				/* 					 （Ｙ） */
int IconPosX;
int IconPosY;
char prog[2][256];			/* プログラム */
COLORREF PanelColor;		/* パネルの色 */
COLORREF InnerColor;		/* 表示パネルの色 */
COLORREF TextColor;			/* 文字の色 */
ushort KeyHotSts;			/* ホットキーのシフトステータス */
ushort KeyHotKey;			/* ホットキーのキー */



/*===== ローカルなデータ ====================================================*/

static HWND hWndMain;				/* メインウインドウのウインドウハンドル */
static HACCEL hAccel;				/* アクセラレータのハンドル */

static int setonly;					/* 演算子のセットだけフラグ */
static int status;					/* 電卓の状態 */
static int errnum;					/* エラー番号 */

static char numstr[MAXINP_DEC+3];	/* 入力文字列 */
static int negative;				/* 負数フラグ(入力文字列に対してのみ有効) */

static int parlev;					/* 括弧のレベル */

static long double inpnum;			/* トップレベル */
static long double numstk[3][10];	/* 数値スタック */

static char op1[10];				/* 加減算オペレーション */
static char op2[10];				/* 乗除算オペレーション */

static int tmpmode;					/* 一時入力モード変更時の保存用 */

static int MetricY;
static int MetricX;

static long double Memory = 0.0;

//static int ime_open;






/*----- メインルーチン --------------------------------------------------------
*
*	Parameter
*		HINSTANCE hInstance : このアプリケーションのこのインスタンスのハンドル
*		HINSTANCE hPrevInstance : このアプリケーションの直前のインスタンスのハンドル
*			0 = 最初のインスタンス
*		LPSTR lpszCmdLine : アプリケーションが起動したときのコマンドラインをさすロングポインタ
*		int cmdShow : 最初に表示するウインドウの形式。
*			(SW_SHOWNORMAL / SW_HIDE / SW_MINIMIZE)
*
*	Return Value
*		int 最後のメッセージのwParam
*----------------------------------------------------------------------------*/

int PASCAL WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpszCmdLine, int cmdShow)
{
    MSG msg;
	int ret;

	hWndMain = NULL;

	ret = FALSE;
	if(InitApp(hInstance, hPrevInstance, lpszCmdLine, cmdShow) == SUCCESS)
	{
		while(GetMessage(&msg, NULL, 0, 0))
		{
			if(TranslateAccelerator(hWndMain, hAccel, &msg) == 0)
			{
				TranslateMessage(&msg);
				DispatchMessage(&msg);
			}
		}
		ret = msg.wParam;
	}
	return(ret);
}


/*----- アプリケーションの初期化 ----------------------------------------------
*
*	Parameter
*		HINSTANCE hInstance : このアプリケーションのこのインスタンスのハンドル
*		HINSTANCE hPrevInstance : このアプリケーションの直前のインスタンスのハンドル
*			0 = 最初のインスタンス
*		LPSTR lpszCmdLine : アプリケーションが起動したときのコマンドラインをさすロングポインタ
*		int cmdShow : 最初に表示するウインドウの形式。
*			(SW_SHOWNORMAL / SW_HIDE / SW_MINIMIZE)
*
*	Return Value
*		int ステータス
*			SUCCESS/FAIL
*----------------------------------------------------------------------------*/

static int InitApp(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpszCmdLine, int cmdShow)
{
	int Sts;
	WNDCLASS wClass;
	NOTIFYICONDATA ntData;

//	AllocConsole();

	if((GetVersion() & 0x000000FF) >= 4)
	{
		Sts = FAIL;
		hInst = hInstance;
		inpmode = MODE_DEC;
		tmpmode = MODE_NONE;

		LoadINIfile();

		wClass.style         = CS_HREDRAW | CS_VREDRAW;
		wClass.lpfnWndProc   = FhcalwWndProc;
		wClass.cbClsExtra    = 0;
		wClass.cbWndExtra    = 0;
		wClass.hInstance     = hInstance;
		wClass.hIcon         = LoadIcon(hInstance, MAKEINTRESOURCE(fhcalw));
		wClass.hCursor       = LoadCursor(NULL, IDC_ARROW);
		wClass.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
		wClass.lpszMenuName  = NULL;
		wClass.lpszClassName = ClassStr;
		RegisterClass(&wClass);

		hAccel = LoadAccelerators(hInst, MAKEINTRESOURCE(fhcalw));

		SetWinSize();
		hWndMain = CreateWindow(ClassStr, "Fhcalw95",
				WS_POPUP | WS_BORDER | WS_SYSMENU,
				WinPosX, WinPosY, WinSizeX, WinSizeY,
				HWND_DESKTOP, 0, hInstance, NULL);

		if(hWndMain != NULL)
		{
			ntData.cbSize = sizeof(NOTIFYICONDATA);
			ntData.hWnd = hWndMain;
			ntData.uID = 1;
			ntData.uFlags = NIF_ICON | NIF_TIP | NIF_MESSAGE;
			ntData.uCallbackMessage = WM_CLICK_ICON;
			ntData.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(fhcalw));
			lstrcpy(ntData.szTip, "");
			Shell_NotifyIcon(NIM_ADD, &ntData);

			MakePanelFont();
			MakeButtonFont();
			MapWindowButton();
			Clear();

			if(AlwaysOnTop == 1)
				SetWindowPos(hWndMain, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
			else
				SetWindowPos(hWndMain, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);

			if((cmdShow == SW_MINIMIZE) ||
			   (cmdShow == SW_SHOWMINIMIZED) ||
			   (cmdShow == SW_SHOWMINNOACTIVE))
			{
				ShowWindow(hWndMain, SW_HIDE);
			}
			else
				ShowWindow(hWndMain, SW_SHOW);

		    UpdateWindow(hWndMain);
			SetDisplay(0);
			SetHotkey();

			Sts = SUCCESS;
		}
	}
	return(Sts);
}


/*----- メッセージ処理 --------------------------------------------------------
*
*	Parameter
*		HWND hWnd : ウインドウハンドル
*		UINT message  : メッセージ番号
*		WPARAM wParam : メッセージの WPARAM 引数
*		LPARAM lParam : メッセージの LPARAM 引数
*
*	Return Value
*		メッセージに対応する戻り値
*----------------------------------------------------------------------------*/

static LRESULT CALLBACK FhcalwWndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message)
	{
		case WM_HOTKEY :
			SetForegroundWindow(hWnd);
			ShowWindow(hWnd, SW_SHOW);
			if(AlwaysOnTop)
				SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW | SWP_NOSIZE | SWP_NOMOVE);
			break;

		case WM_SETFOCUS :
		case WM_KILLFOCUS :
			InvalidateRgn(GetDlgItem(hWnd, BUT_QUIT), NULL, FALSE);
			return(DefWindowProc(hWnd, message, wParam, lParam));

		case WM_COMMAND:
			CommandProc(hWnd, LOWORD(wParam));
			SetFocus(hWnd);
			break;

		case WM_CHAR :
			if(wParam < 0x100)
				wParam = toupper(wParam);
			CommandProc(hWnd, wParam + BUT_TOP);
			break;


#if 0
		case WM_KEYDOWN :
			switch(wParam)
			{
				case VK_HOME :
					CommandProc(hWnd, BUT_AC);
					break;

				default :
					CommandProc(hWnd, BUT_TOP + wParam);
					break;

//					return(DefWindowProc(hWnd, message, wParam, lParam));
			}
			break;
#endif


		case WM_CLICK_ICON :
			if((lParam & 0x00000007L) == 1)
			{
				SetForegroundWindow(hWnd);
				ShowWindow(hWnd, SW_SHOW);
				if(AlwaysOnTop)
					SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW | SWP_NOSIZE | SWP_NOMOVE);
			}
			return 0;

		case WM_DRAWITEM :
			DrawButton(hWnd, (int)wParam, (DRAWITEMSTRUCT *)lParam);
			return(TRUE);

		/* タイトルバーのない時のウインドウ移動のための処理 */
        case WM_NCHITTEST:
            wParam = DefWindowProc(hWnd, message, wParam, lParam);
            if(wParam == HTCLIENT)
                return HTCAPTION;
            else
              return wParam;

		case WM_ERASEBKGND :
			EraseBackGround(hWnd, (HDC)wParam);
			return(1);

		case WM_PAINT:
			FhcalwPaint(hWnd);
			break;

		case WM_DESTROY:
			PostQuitMessage(0);
			break;

		case WM_QUERYENDSESSION:
			QuitProcess(hWnd);
			return(TRUE);

		case WM_CLOSE:
			QuitProcess(hWnd);
			DestroyWindow(hWnd);
			break;

		default:
			return(DefWindowProc(hWnd, message, wParam, lParam));
	}
    return(0L);
}


/*----- 終了時の処理 ----------------------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void QuitProcess(HWND hWnd)
{
	NOTIFYICONDATA ntData;

	ReleaseHotkey();
	SetWinPos();
	SaveINIfile(hWnd);
	DeleteButtonFont();
	DeletePanelFont();

	ntData.cbSize = sizeof(NOTIFYICONDATA);
	ntData.hWnd = hWnd;
	ntData.uID = 1;
	Shell_NotifyIcon(NIM_DELETE, &ntData);

	return;
}










/*----- 電卓に関係するイベント処理 --------------------------------------------
*
*	Parameter
*		HWND hWnd : ウインドウハンドル
*		int key : イベント
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void CommandProc(HWND hWnd, int key)
{

	if(prognum == 0)
	{
		if((key >= BUT_TOP) && (key <= BUT_BTM))
		{
			key -= BUT_TOP;

			if(InpNum(key) == NO)
				CalcOpe(hWnd, key);
		}
		else
			MenuOpe(hWnd, key);

		if(prognum != 0)
		{
			DispProgramBar("");
			ProgramProc(hWnd);
		}
	}
	else
	{
		if((key == BUT_RET) || (key == BUT_EQUAL))
		{
			DispProgramBar("");
			ProgramProc(hWnd);
		}
		else if((key == BUT_ESC) || (key == BUT_AC))
		{
			prognum = 0;
			DispNormalBar();
			SetDisplay(1);
		}
		else
		{
			key -= BUT_TOP;
			InpNum(key);
		}
	}
	return;
}


/*----- 数値入力 --------------------------------------------------------------
*
*	Parameter
*		int key : イベント
*
*	Return Value
*		int 数値入力だったかどうか
*			YES/NO
*----------------------------------------------------------------------------*/

static int InpNum(int key)
{
	int sts;

	sts = NO;

	if((key >= 'A') && (key <= 'F'))
		Change2Hex();

	if((isdigit(key) != 0) ||
	   ((inpmode == MODE_HEX) && (key >= 'A') && (key <= 'F')))
	{
		if(status == NUM_DISP)
		{
			status = NUM_INP;
			strcpy(numstr, "0");
			negative = NO;
		}

		if (strcmp(numstr, "0") == 0)
			numstr[0] = '\0';

		InsertKey((char)key);
		SetDisplay(1);
		sts = YES;
	}
	else
	{
		switch(key)
		{
			case ' ' :
				if((status == NUM_DISP) || (strcmp(numstr, "0") == 0))
				{
					inpmode ^= 1;
					tmpmode = MODE_NONE;
					UpdateIndicater();
				}
				sts = YES;
				break;

			case 'H' :
			case 'X' :
				Change2Hex();
				sts = YES;
				break;

			case 'T' :
				Change2Dec();
				sts = YES;
				break;

			case '.' :
				Change2Dec();
				if(inpmode == MODE_DEC)
				{
					if((status == NUM_INP) && (strchr(numstr, '.') == NULL))
						InsertKey((char)key);
					else if(status == NUM_DISP)
					{
						strcpy(numstr, "0.");
						status = NUM_INP;
					}
					SetDisplay(1);
				}
				sts = YES;
				break;

			case 0x08 :		/* BS */
				if(status == NUM_INP)
				{
					if (strlen(numstr) == 1)
					{
						strcpy(numstr, "0");
						negative = NO;
					}
					else
						numstr[strlen(numstr) - 1] = '\0';
					SetDisplay(1);
				}
				else
				{
					numstk[0][parlev] = 0.0;
					inpnum = 0.0;
					SetDisplay(0);
				}
				sts = YES;
				break;

			case ',' :				/* ± */
				if(status == NUM_INP)
				{
					if(strcmp(numstr, "0") != 0)
					{
						negative = ~negative;
						SetDisplay(1);
					}
				}
				else
				{
				   if(numstk[0][parlev] != 0.0)
					{
						numstk[0][parlev] = -numstk[0][parlev];
						inpnum = numstk[0][parlev];
						SetDisplay(0);
					}
				}
				sts = YES;
				break;

			case '}' :			/* CE */
				if(status == NUM_INP)
				{
					strcpy(numstr, "0");
					negative = NO;
					SetDisplay(1);
					status = NUM_DISP;
					ResetTempMode();
				}
				break;
		}
	}

	if(sts == YES)
		setonly = NO;

	return(sts);
}


/*----- コマンド処理 ----------------------------------------------------------
*
*	Parameter
*		HWND hWnd : ウインドウハンドル
*		int key : イベント
*
*	Return Value
*		int コマンドだったかどうか
*			YES/NO
*----------------------------------------------------------------------------*/

static int CalcOpe(HWND hWnd, int key)
{
	int sts;

	sts = YES;

	if((status == NUM_ERR) && (key != '{') && (key != 'Q') && (key != BUT_ESC-BUT_TOP))
		key = NUL;

	if(key == BUT_ESC-BUT_TOP)
	{
	   if(EscIcon == 0)
			key = 'Q';
		else
			key = 'I';
	}
	else if(key == BUT_RET-BUT_TOP)
	{
		key = '=';
	}

	switch(key)
	{
		case '+' :
		case '-' :
			if(setonly == NO)
			{
				PushNumber();
				CalcOp1();
				if(status != NUM_ERR)
					op1[parlev] = key;
			}
			else
			{
				if(status != NUM_ERR)
					op1[parlev] = key;
				op2[parlev] = ' ';
			}
			setonly = YES;
			SetDisplay(0);
			DispNormalBar();
			ResetTempMode();
			break;

		case '*' :
		case '/' :
			if(setonly == NO)
			{
				PushNumber();
				CalcOp2();
				if(status != NUM_ERR)
					op2[parlev] = key;
			}
			else
			{
				if(status != NUM_ERR)
					op2[parlev] = key;
				op1[parlev] = ' ';
			}
			setonly = YES;
			SetDisplay(0);
			DispNormalBar();
			ResetTempMode();
			break;

		case '=' :
			setonly = NO;
			PushNumber();
			CalcOp1();
			SetDisplay(0);
			DispNormalBar();
			ResetTempMode();
			break;

		case '(' :
			if(parlev < 9)
			{
				setonly = NO;
				parlev++;
				numstk[0][parlev] = 0.0;
				inpnum = 0.0;
				op1[parlev] = ' ';
				op2[parlev] = ' ';
				status = NUM_DISP;
				SetDisplay(0);
				DispNormalBar();
				ResetTempMode();
			}
			break;

		case ')' :
			setonly = NO;
			PushNumber();
			CalcOp1();
			if(parlev > 0)
				parlev--;
			SetDisplay(0);
			DispNormalBar();
			ResetTempMode();
			break;

		case 'S' :
			setonly = NO;
			CalcSqrt();
			SetDisplay(0);
			DispNormalBar();
			ResetTempMode();
			break;

		case '%' :
			setonly = NO;
			CalcParcent();
			SetDisplay(0);
			DispNormalBar();
			ResetTempMode();
			break;

		case '{' :			/* AC */
			Clear();
			ResetTempMode();
			SetDisplay(0);
			DispNormalBar();
			break;

		case 'Q' :
			PostMessage(hWnd, WM_CLOSE, 0, 0L);
			break;

		case 'I' :
			SaveINIfile(hWnd);
			ShowWindow(hWndMain, SW_HIDE);
			break;

		case 'Z' :
			DispMenu(hWnd, key);
			break;

		case '[' :
			setonly = NO;
			Clear();
			ResetTempMode();
			RunProgram(hWnd, 1);
			SetDisplay(0);
			DispNormalBar();
			break;

		case ']' :
			setonly = NO;
			Clear();
			ResetTempMode();
			RunProgram(hWnd, 2);
			SetDisplay(0);
			DispNormalBar();
			break;

		case NUL :
		case 0x0A :
			/* 何もしない */
			break;

		case 'R' :		/* MR */
			setonly = NO;
			inpnum = Memory;
			SetDisplay(0);
			DispNormalBar();
			ResetTempMode();
			break;

		case 'L' :		/* MC */
			Memory = 0.0;
			DispNormalBar();
			break;

		case 'P' :		/* M+ */
			Memory += GetNum();
			DispNormalBar();
			break;

		case 'M' :		/* M- */
			Memory -= GetNum();
			DispNormalBar();
			break;

		default :
			sts = NO;
			break;
	}
	return(sts);
}




/*----- メニュー処理 ----------------------------------------------------------
*
*	Parameter
*		HWND hWnd : ウインドウハンドル
*		int key : イベント
*
*	Return Value
*		int コマンドだったかどうか
*			YES/NO
*----------------------------------------------------------------------------*/

static void MenuOpe(HWND hWnd, int key)
{
	switch(key)
	{

		case MENU_SET :
			ReleaseHotkey();
			SetOption(hWnd);

			DestroyAllButton();
			MapWindowButton();

			SetWinSize();
			SetWindowPos(hWnd, HWND_BOTTOM, 0, 0, WinSizeX, WinSizeY, SWP_NOMOVE);
			if(AlwaysOnTop == 1)
				SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE | SWP_SHOWWINDOW);
			else
				SetWindowPos(hWnd, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);

			InvalidateRect(hWnd, NULL, TRUE);
			SetHotkey();
			if(status == NUM_INP)
				SetDisplay(1);
			else
				SetDisplay(0);
			DispNormalBar();
			break;

		case MENU_HELP :
			WinHelp(hWnd, "Fhcalw95.HLP", HELP_CONTEXT, 1);
			break;

		case MENU_ABOUT :
			DispAbout(hWnd);
			break;

		case MENU_PROG1 :
			setonly = NO;
			SetProgram(hWnd, 1);
			break;

		case MENU_PROG2 :
			setonly = NO;
			SetProgram(hWnd, 2);
			break;

		case MENU_COPY :
			setonly = NO;
			ToClipboard(hWnd);
			break;

		case MENU_PASTE :
			setonly = NO;
			Clear();
			ResetTempMode();
			FromClipboard(hWnd);
			SetDisplay(0);
			DispNormalBar();
			break;
	}
	return;
}














/*----- ウインドウをクリアする ------------------------------------------------
*
*	Parameter
*		HWND hWnd : ウインドウハンドル
*		HDC hDC : デバイスコンテキスト
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void EraseBackGround(HWND hWnd, HDC hDC)
{
	HBRUSH hBrush;
	RECT Rect;

	GetClientRect(hWnd, &Rect);
	hBrush = CreateSolidBrush(PanelColor);
	FillRect(hDC, &Rect, hBrush);
	DeleteObject(hBrush);
	return;
}



/*----- ウインドウの描画 ------------------------------------------------------
*
*	Parameter
*		HWND hWnd : ウインドウハンドル
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void FhcalwPaint(HWND hWnd)
{
	PAINTSTRUCT ps;
	HDC hDC;
	RECT Rect;
	HPEN hPen;
	HPEN hPenOld;
	HBRUSH hBrush;
	HBRUSH hBrushOld;

    BeginPaint(hWnd, (LPPAINTSTRUCT) &ps);
    hDC = ps.hdc;

	GetClientRect(hWnd, &Rect);

	/* 電卓の明るいところ */
	hPen = CreatePen(PS_SOLID, 0, RGB(255,255,255));
	hPenOld = SelectObject(hDC, hPen);
	MoveToEx(hDC, Rect.left, Rect.bottom, NULL);
	LineTo(hDC, Rect.left, Rect.top);
	LineTo(hDC, Rect.right-1, Rect.top);
	SelectObject(hDC, hPenOld);
	DeleteObject(hPen);

	/* 電卓の暗いところ */
	hPen = CreatePen(PS_SOLID, 0, RGB(0,0,0));
	hPenOld = SelectObject(hDC, hPen);
	LineTo(hDC, Rect.right-1, Rect.bottom-1);
	LineTo(hDC, Rect.left-1, Rect.bottom-1);
	SelectObject(hDC, hPenOld);
	DeleteObject(hPen);

	/* 文字盤の内部 */
	hBrush = CreateSolidBrush(InnerColor);
	hBrushOld = SelectObject(hDC, hBrush);
	Rectangle(hDC, Frame2.left, Frame2.top, Frame2.right, Frame2.bottom);
	SelectObject(hDC, hBrushOld);
	DeleteObject(hBrush);

	DispInputInd2(hDC);

	DispText2(hDC, 2, StsDispStr);
	DispText2(hDC, 0, DecDispStr);
	DispText2(hDC, 1, HexDispStr);
//	if(DispBinary == 1)
//		DispText2(hDC, 3, BinDispStr);

    EndPaint(hWnd, (LPPAINTSTRUCT) &ps);
	return;
}




static void MakePanelFont(void)
{
	hFontPanel = CreateFontIndirect(&LogFontPanel);
	return;
}



static void DeletePanelFont(void)
{
	if(hFontPanel != NULL)
		DeleteObject(hFontPanel);
	hFontPanel = NULL;
	return;
}


/*----- 文字列を表示 ----------------------------------------------------------
*
*	Parameter
*		HDC hDC : 
*		RECT *Rect : 
*		int Num : 
*		char *Text : 
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void DispText2(HDC hDC, int Num, char *Text)
{
	HFONT hFontOld;

	hFontOld = SelectObject(hDC, hFontPanel);
	SetTextAlign(hDC, TA_RIGHT);
	SetTextColor(hDC, TextColor);
	SetBkColor(hDC, InnerColor);
	ExtTextOut(hDC, NumDisp[Num].right, NumDisp[Num].top, ETO_OPAQUE, &NumDisp[Num], Text, strlen(Text), NULL);
	SelectObject(hDC, hFontOld);
	return;
}


/*----- 入力インジケータを表示 ------------------------------------------------
*
*	Parameter
*		HDC hDC : デバイスコンテキスト
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void DispInputInd2(HDC hDC)
{
	COLORREF hex;
	COLORREF dec;

	hex = RGB(0, 0, 0);
	dec = RGB(0, 255, 0);
	if(inpmode == MODE_HEX)
	{
		hex = RGB(0, 255, 0);
		dec = RGB(0, 0, 0);
	}

	PaintRegion(hDC, CreatePolygonRgn(MarkHex, 3, WINDING), hex);
	PaintRegion(hDC, CreatePolygonRgn(MarkDec, 3, WINDING), dec);
	return;
}



/*----- 領域をペイントする ----------------------------------------------------
*
*	Parameter
*		HDC hDC : デバイスコンテキストのハンドル
*		HRGN hRGN : 領域のハンドル
*		COLORREF rgb : ブラシの色
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void PaintRegion(HDC hDC, HRGN hRgn, COLORREF rgb)
{
	HBRUSH hBrush;

	hBrush = CreateSolidBrush(rgb);
	FillRgn(hDC, hRgn, hBrush);
	DeleteObject(hRgn);
	DeleteObject(hBrush);
	return;
}


















/*----- 入力インジケータを表示 ------------------------------------------------
*
*	Parameter
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void UpdateIndicater(void)
{
	HDC hDC;

	hDC = GetDC(hWndMain);
	DispInputInd2(hDC);
	ReleaseDC(hWndMain, hDC);

	return;
}


/*----- 文字列を表示 ----------------------------------------------------------
*
*	Parameter
*		int pos : 表示位置 (0～3)
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void UpdateText(int pos)
{
	RECT Rect;
	char *Str;
	HDC hDC;

	GetClientRect(hWndMain, &Rect);
	switch(pos)
	{
		case 0 :
			Str = DecDispStr;
			break;

		case 1 :
			Str = HexDispStr;
			break;

		case 2 :
			Str = StsDispStr;
			break;

		case 3 :
			Str = BinDispStr;
			break;
	}

	hDC = GetDC(hWndMain);
	DispText2(hDC, pos, Str);
	ReleaseDC(hWndMain, hDC);

	return;
}



















/*----- ウインドウの位置を保存 ------------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void SetWinPos(void)
{
	WINDOWPLACEMENT WinPlace;

	WinPlace.length = sizeof(WINDOWPLACEMENT);
	GetWindowPlacement(hWndMain, &WinPlace);
	WinPosX = WinPlace.rcNormalPosition.left;
	WinPosY = WinPlace.rcNormalPosition.top;
	return;
}



/*----- ウインドウのサイズをセットする ----------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void SetWinSize(void)
{
	WinSizeX = NorWinSizeX;
	WinSizeY = NorWinSizeY;
	if(ButtonDisp)
		WinSizeY = NoButtonWinSizeY;

	return;
}

















/*----- 標準ステータスを表示 --------------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void DispNormalBar(void)
{
	int i;

	if(prognum == 0)
	{
		memset(StsDispStr, ' ', 20);
		StsDispStr[20] = NUL;
		StsDispStr[18] = op1[parlev];
		if(op2[parlev] != ' ')
			StsDispStr[18] = op2[parlev];

		for(i = 0; i < parlev; i++)
			StsDispStr[14-i] = '(';

		if(Memory != 0)
			StsDispStr[4] = 'M';

		UpdateText(2);
	}
	return;
}


/*----- プログラム実行中ステータスを表示 --------------------------------------
*
*	Parameter
*		char *prompt : 入力プロンプト
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void DispProgramBar(char *prompt)
{
	if(prognum == 5)
		sprintf(StsDispStr, "CL  %-14s  ", prompt);
	else
		sprintf(StsDispStr, "P%1d  %-14s  ", prognum, prompt);
	UpdateText(2);

	return;
}


/*----- 数値を表示 ------------------------------------------------------------
*
*	Parameter
*		int type : 表示モード
*			0 = スタックトップを表示
*			1 = 入力中の文字列を表示
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void SetDisplay(int type)
{
	static const char errmes[8][13] = {
		"Data is long",
		"Clipbd unuse",
		"Overflow",
		"Square root",
		"Zero divide",
		"Prompt mess",
		"Unknown char",
		"Parenthesis"
	};

	long double num;

	if(status != NUM_ERR)
	{
		if(type == 0)
		{
			status = NUM_DISP;
			MakeDecStr(inpnum, DecDispStr);
			ReformDecStr(DecDispStr);
			MakeHexStr(inpnum, HexDispStr);
			ReformHexStr(HexDispStr);
			MakeBinStr(inpnum, BinDispStr);
		}
		else
		{
			status = NUM_INP;
			DecDispStr[0] = NUL;
			HexDispStr[0] = NUL;
			if(inpmode == MODE_DEC)
			{
				/*===== 10進入力 =====*/

				num = atof(numstr);
				if(negative)
				{
					num = -num;
					strcpy(DecDispStr, "-");
				}
				strcat(DecDispStr, numstr);
				ReformDecStr(DecDispStr);
				MakeHexStr(num, HexDispStr);
				ReformHexStr(HexDispStr);
				MakeBinStr(num, BinDispStr);
			}
			else
			{
				/*===== 16進入力 =====*/

				num = HexStr2Num();
				MakeDecStr(num, DecDispStr);
				ReformDecStr(DecDispStr);
				MakeHexStr(num, HexDispStr);
				ReformHexStr(HexDispStr);
				MakeBinStr(num, BinDispStr);
			}
		}
	}

	if(status == NUM_ERR)
	{
		HexDispStr[0] = NUL;
		BinDispStr[0] = NUL;
		strcpy(DecDispStr, "ERR : ");
		strcat(DecDispStr, errmes[errnum]);
	}

	UpdateText(0);
	UpdateText(1);
	if(DispBinary == 1)
		UpdateText(3);

	return;
}


/*----- １０進表示文字列を作成 ------------------------------------------------
*
*	Parameter
*		long double num : 数値
*		char *str : 文字列のセット位置
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void MakeDecStr(long double num, char *str)
{
	char *first;
	char *last;
	char *point;

//	sprintf(str, "%0.14Lf", num);
	sprintf(str, "%0.13Lf", num);
	first = str;
	last = strchr(first, NUL);
	point = strchr(first, '.');

	if(str[0] == '-')
		first++;

	if((point - first) > 14)
	{
		Error(ERR_OVER);
		*str = NUL;
	}
	else
	{
		if((last - first) > 14 + 1)
			last = first + 14 + 1;
		while (last[-1] == '0')
			--last;
	    if(last[-1] == '.')
			--last;

		*last = NUL;
	}
	return;
}


/*----- １０進表示文字列に位取りのカンマをセット ------------------------------
*
*	Parameter
*		char *str : 文字列
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void ReformDecStr(char *str)
{
	char *pos;
	int i;
	int count;

	if(DispComma == 1)
	{
		strrev(str);

		if((pos = strchr(str, '.')) != NULL)
			pos++;
		else
			pos = str;

		count = 0;
		for(i = strlen(pos); i > 0; i--)
		{
			pos++;
			if((++count > 2) && isdigit(*pos))
			{
				memmove(pos + 1, pos, i + 1);
				*pos++ = ',';
				count = 0;
			}
		}

		strrev(str);
	}
	return;
}


/*----- １６進表示文字列を作成 ------------------------------------------------
*
*	Parameter
*		long double num : 数値
*		char *str : 文字列のセット位置
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void MakeHexStr(long double num, char *str)
{
	ulong low;
	ulong hi;
	int i;
	char *pos;

	i = NO;
	if(num < 0.0)
	{
		num = -num;
		i = YES;
	}

	low = (ulong)num;
	hi = ((ulong)(num / 0x10000l) / 0x10000l);

	if(i)
	{
		low = ~low;
		hi = ~hi;
		low++;
		if(low == 0)
			hi++;
	}

	sprintf(str, "%08lX%08lX", hi, low);

	/*===== サプレス処理 =====*/

	pos = str + 6;
	for(i = 9; i > 0; i--)
	{
		if(*pos != '0')
			break;
		pos++;
	}
	memmove(str, pos, 17 - (pos - str));

	return;
}


/*----- １６進表示文字列に位取りのスペースをセット ----------------------------
*
*	Parameter
*		char *str : 文字列
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void ReformHexStr(char *str)
{
	int len;
	int len2;

	if(DispComma == 1)
	{
		strrev(str);
		len2 = len = strlen(str);
		if(len2 > 8)
		{
			memmove(str + 9, str + 8, len - 8 + 1);
			*(str + 8) = ' ';
			len++;
		}
		if(len2 > 4)
		{
			memmove(str + 5, str + 4, len - 4 + 1);
			*(str + 4) = ' ';
		}
		strrev(str);
	}
	return;
}


/*----- ２進表示文字列を作成 --------------------------------------------------
*
*	Parameter
*		long double num : 数値
*		char *str : 文字列のセット位置
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void MakeBinStr(long double num, char *str)
{
	ulong low;
	int i;
	char *pos;
	char *top;

	low = (ulong)num;
	if(num < 0.0)
	{
		low = (ulong)(-num);
		low = ~low;
		low++;
	}

	top = str;
	pos = str + 1;
	for(i = 0; i < 16; i++)
	{
		if((low % 2) == 1)
		{
			*str++ = '1';
			pos = str;
		}
		else
			*str++ = '0';

		low /= 2;

		if((DispComma == 1) && ((i % 4) == 3))
			*str++ = ' ';
	}
	*pos = NUL;
	strrev(top);

	return;
}


/*----- １０進文字列を数値に変換 ----------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		long double 数値
*----------------------------------------------------------------------------*/

static long double DecStr2Num(void)
{
	long double num;

	num = atof(numstr);
	if(negative)
		num = -num;
	return(num);
}


/*----- １６進文字列を数値に変換 ----------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		long double 数値
*----------------------------------------------------------------------------*/

static long double HexStr2Num(void)
{
	long double num;
	char *str;
	int x;

	str = numstr;
	num = 0.0;
	while(*str != NUL)
	{
		num *= 16.0;
		x = *str++;
		x -= '0';
		if(x > 9)
			x -= 7;
		num += x;
	}
	if(negative)
		num = -num;
	return(num);
}


/*----- ホットキーを設定する --------------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		int ステータス
*			SUCCESS/FAIL
*----------------------------------------------------------------------------*/

static int SetHotkey(void)
{
	UINT sft;
	int sts;

	sft = 0;
	if(KeyHotSts & KEY_STS_ALT)
		sft |= MOD_ALT;
	if(KeyHotSts & KEY_STS_CTRL)
		sft |= MOD_CONTROL;
	if(KeyHotSts & KEY_STS_SHIFT)
		sft |= MOD_SHIFT;

	if(KeyHotKey != 0)
		RegisterHotKey(hWndMain, 0, sft, KeyHotKey);
	sts = SUCCESS;

	return(sts);
}


/*----- ホットキーの設定を解除する --------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void ReleaseHotkey(void)
{
	if(KeyHotKey != 0)
		UnregisterHotKey(hWndMain, 0);
	return;
}




















/*----- 入力文字をバッファにセット --------------------------------------------
*
*	Parameter
*		char key : 入力文字
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void InsertKey(char key)
{
	int len;
	int max;

	max = MAXINP_DEC;							/* 入力可能桁数を設定 */
	if(inpmode == MODE_HEX)
		max = MAXINP_HEX;
	if(strchr(numstr, '.') != 0)				/* 小数点入力済みなら＋１ */
		max++;

	len = strlen(numstr);
	if(len < max)								/* 入力可能なら */
	{
	    numstr[len++] = key;
	    numstr[len] = NUL;
	}
	return;
}


/*----- 数値をクリア ----------------------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void Clear(void)
{
	setonly = NO;
	status = NUM_DISP;
	negative = NO;
	parlev = 0;
	op1[0] = ' ';
	op2[0] = ' ';
	numstk[0][0] = 0.0;
	inpnum = 0.0;
	prognum = 0;
}


/*----- 一時的に１０進入力に設定 ----------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void Change2Dec(void)
{
	if((inpmode == MODE_HEX) &&							/* 現在が１６進入力で */
	   ((status == NUM_DISP) ||							/* 入力状態でないか */
		(strcspn(numstr, "ABCDEF") == strlen(numstr))))	/* 数字のみなら */
	{
		inpmode = MODE_DEC;						/* 一時的に１０進入力に */
		tmpmode = MODE_HEX;
		UpdateIndicater();
		if(status == NUM_INP)					/* 入力中なら再表示 */
			SetDisplay(1);
	}
	return;
}


/*----- 一時的に１６進入力に設定 ----------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void Change2Hex(void)
{
	if((inpmode == MODE_DEC) &&					/* 現在が１０進入力で */
	   ((status == NUM_DISP) ||					/* 入力状態でないか */
		((strlen(numstr) <= 7) &&				/* 文字が７文字以下で */
		 (strchr(numstr, '.') == NULL))))		/* 小数点がなければ */
	{
		inpmode = MODE_HEX;						/* 一時的に１６進入力に */
		tmpmode = MODE_DEC;
		UpdateIndicater();
		if(status == NUM_INP)					/* 入力中なら再表示 */
			SetDisplay(1);
	}
	return;
}


/*----- 一時的に変更したモードを戻す ------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void ResetTempMode(void)
{
	if(tmpmode != MODE_NONE)					/* 一時的なモード変更なら */
	{
		inpmode = tmpmode;						/* もとに戻す */
		tmpmode = MODE_NONE;
		UpdateIndicater();
	}
	return;
}


/*----- プログラムの実行開始処理 ----------------------------------------------
*
*	Parameter
*		HWND hWnd : ウインドウハンドル
*		int num : プログラム番号 (1 or 2)
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void RunProgram(HWND hWnd, int num)
{
	if(strlen(prog[num-1]) > 0)
	{
		if(PreProcess(prog[num-1], clip) == 0)
		{
			progpos = clip;
			prognum = num;
		}
		else
			Error(ERR_PAR);
	}
	return;
}


/*----- プログラム実行処理 ----------------------------------------------------
*
*	Parameter
*		HWND hWnd : ウインドウハンドル
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void ProgramProc(HWND hWnd)
{
	char ch;
	char prompt[15];

	while((ch = *progpos++) != NUL)
	{
		if((ch == ' ') || (ch == ','));
			/* nothing */
		else if(ch == '#')
		{
			progpos = GetPromptStr(progpos, prompt);
			DispProgramBar(prompt);
			strcpy(numstr, "0");
			negative = NO;
			SetDisplay(1);
			DispNormalBar();
			break;
		}
		else if((InpNum((int)(uchar)ch) == NO) &&
				(CalcOpe(hWnd, (int)(uchar)ch) == NO))
		{
			Error(ERR_CHAR);
			prognum = 0;
			SetDisplay(1);
			DispNormalBar();
			break;
		}
	}

	if(ch == NUL)
	{
		CalcOpe(hWnd, '=');				/* 最後に = を送っておく */
		prognum = 0;
		DispNormalBar();
		SetDisplay(0);
	}
	return;
}


/*----- 計算式を整形する ------------------------------------------------------
*
*	Parameter
*		char *istr : 元の式
*		char *ostr : 変換後の式
*
*	Return Value
*		int ステータス
*			0 = 正常終了
*			1 = 括弧が多すぎる
*			2 = 括弧の対応がおかしい
*----------------------------------------------------------------------------*/

int PreProcess(char *istr, char *ostr)
{
	int sts;
	int par_lev;
	int next;
	char func_stack[10];
	char ch;

	for(par_lev = 0; par_lev < 10; par_lev++)
		func_stack[par_lev] = NUL;

	par_lev = 0;
	next = 1;
	sts = 0;
	while((sts == 0) && ((ch = *istr) != NUL))
	{
		if((next == 1) && (ch == '-'))
			next = 2;
		else if((isxdigit(ch) != 0) || (ch == '.'))
		{
			*ostr++ = ch;
			if(next == 2)
				*ostr++ = (char)ID_PLUSMINUS_B;
			next = 0;
		}
		else if(strnicmp(istr, "SQR(", 4) == 0)		/* "SQR(" */
		{
			func_stack[par_lev] = 'S';
			istr += 2;
			next = 1;
		}
		else if(strchr("+-*/", ch) != NULL)
		{
			*ostr++ = ch;
			next = 1;
		}
		else if(ch == '(')						/* '(' */
		{
			par_lev++;
			if(par_lev == 10)
				sts = 1;
			else
				*ostr++ = '(';
		}
		else if(ch == ')')						/* ')' */
		{
			par_lev--;
			if(par_lev < 0)
				sts = 2;
			else
			{
				*ostr++ = ')';
				if((ch = func_stack[par_lev]) != NUL)
					*ostr++ = ch;
				func_stack[par_lev] = NUL;
			}
			next = 0;
		}
		else if(ch != ' ')
			*ostr++ = ch;

		istr++;
	}
	*ostr = NUL;

	if((sts == 0) && (par_lev != 0))	/* 最後に括弧の対応がおかしいなら */
		sts = 2;

	return(sts);
}


/*----- プロンプト文字列の取得 ------------------------------------------------
*
*	Parameter
*		char *str : プログラム文字列
*		char *prompt : プロンプト文字列の格納位置
*
*	Return Value
*		char *プログラム文字列の次の取り出し位置
*----------------------------------------------------------------------------*/

static char *GetPromptStr(char *str, char *prompt)
{
	char *pos;
	int len;

	while(*str == ' ')
		str++;

	if(*str =='[')
	{
		str++;
		if((pos = (char *)_mbschr((uchar *)str, ']')) == NULL)
			Error(ERR_PROMPT);
		else
		{
			len = pos - str;
			if(len > 14)
				len = 14;
			StrbCpy(prompt, str, len);
			str = pos + 1;
		}
	}
	else
		strcpy(prompt, "数値？");
	return(str);
}


/*----- 加算／減算の処理 ------------------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void CalcOp1(void)
{
	CalcOp2();				/* 乗除算が残っているなら計算する */

	if((op1[parlev] != ' ') && (status != NUM_ERR))
	{
		if(op1[parlev] == '+')
			numstk[1][parlev] = numstk[1][parlev] + numstk[0][parlev];
		else if(op1[parlev] == '-')
			numstk[1][parlev] = numstk[1][parlev] - numstk[0][parlev];
		PopStack();
		op1[parlev] = ' ';
	}
	return;
}


/*----- 乗算／除算の処理 ------------------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void CalcOp2(void)
{
	if((op2[parlev] != ' ') && (status != NUM_ERR))
	{
		if(op2[parlev] == '*')
			numstk[1][parlev] = numstk[1][parlev] * numstk[0][parlev];
		else if(op2[parlev] == '/')
		{
			if(numstk[0][parlev] == 0.0)
				Error(ERR_DIV0);
			else
				numstk[1][parlev] = numstk[1][parlev] / numstk[0][parlev];
		}

		if(status != NUM_ERR)
		{
			PopStack();
			op2[parlev] = ' ';
		}
	}
	return;
}


/*----- 平方根の計算 ----------------------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void CalcSqrt(void)
{
	long double num;

	if(status != NUM_ERR)
	{
		num = GetNum();
		if(num >= 0.0)
			inpnum = sqrt(num);
		else
			Error(ERR_SQRT);
	}
	return;
}


/*----- パーセントの計算 ------------------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void CalcParcent(void)
{
	if(status != NUM_ERR)
	{
		if(op2[parlev] != ' ')
			inpnum = GetNum() / 100.0;
		else
			inpnum = inpnum * GetNum() / 100.0;
	}
	return;
}


/*----- 入力中の数値の取り出し ------------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		long double 数値
*----------------------------------------------------------------------------*/

static long double GetNum(void)
{
	long double num;

	if(status == NUM_INP)						/* 数値入力中なら */
	{
		if(inpmode == MODE_DEC)
			num = DecStr2Num();
		else
			num = HexStr2Num();
		status = NUM_DISP;
		negative = NO;
	}
	else										/* 数値表示中なら */
		num = inpnum;							/* スタックトップの値をセット */

	return(num);
}


/*----- 数値をスタックにセット ------------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void PushNumber(void)
{
	PushStack(GetNum());
	return;
}


/*----- スタックにプッシュ ----------------------------------------------------
*
*	Parameter
*		long double num : 数値
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void PushStack(long double num)
{
	numstk[2][parlev] = numstk[1][parlev];
	numstk[1][parlev] = numstk[0][parlev];
	numstk[0][parlev] = num;
	inpnum = num;
	return;
}


/*----- スタックからポップ ----------------------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void PopStack(void)
{
	numstk[0][parlev] = numstk[1][parlev];
	numstk[1][parlev] = numstk[2][parlev];
	inpnum = numstk[0][parlev];
	return;
}


/*----- エラーをセットする ----------------------------------------------------
*
*	Parameter
*		int errno : エラー番号
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

void Error(int errno)
{
	Clear();
	errnum = errno;
	status = NUM_ERR;
}















/*----- ウインドウにボタンを張り付ける ----------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void MapWindowButton(void)
{
	int i;
	int Max;

	Max = sizeof(Buttons)/sizeof(BUTTONDATA);
	if(ButtonDisp)
		Max = 3;

	for(i = 0; i < Max; i++)
	{
		Buttons[i].hWnd = CreateWindow("BUTTON", "",
			WS_VISIBLE | WS_CHILD | BS_OWNERDRAW,
			Buttons[i].pos.x, Buttons[i].pos.y,
			Buttons[i].size.cx, Buttons[i].size.cy,
			hWndMain, (HMENU)Buttons[i].mesg, hInst, NULL);
	}
	return;
}


/*----- ウインドウのボタンをすべて削除 ----------------------------------------
*
*	Parameter
*		なし
*
*	Return Value
*		なし
*----------------------------------------------------------------------------*/

static void DestroyAllButton(void)
{
	int i;

	for(i = 0; i < sizeof(Buttons)/sizeof(BUTTONDATA); i++)
	{
		if(Buttons[i].hWnd != NULL)
		{
			DestroyWindow(Buttons[i].hWnd);
			Buttons[i].hWnd = NULL;
		}
	}
	return;
}


/*----- 指定IDを持つボタンデータを返す ----------------------------------------
*
*	Parameter
*		int Msg : メッセージ(ID)
*
*	Return Value
*		BUTTONDATA *ボタンデータ
*			NULL = 見つからない
*----------------------------------------------------------------------------*/

BUTTONDATA *AskButtonData(int Msg)
{
	BUTTONDATA *Pos;
	BUTTONDATA *Ret;
	int i;

	Ret = NULL;
	Pos = Buttons;
	for(i = 0; i < sizeof(Buttons)/sizeof(BUTTONDATA); i++)
	{
		if(Msg == Pos->mesg)
		{
			Ret = Pos;
			break;
		}
		Pos++;
	}
	return(Ret);
}












/* デバッグ用 */

int ConOut(char *Str)
{
	DWORD Tmp;
	WriteConsole(GetStdHandle(STD_OUTPUT_HANDLE), Str, strlen(Str), &Tmp, NULL);
	return(0);
}

int ConOutCr(char *Str)
{
	DWORD Tmp;
	WriteConsole(GetStdHandle(STD_OUTPUT_HANDLE), Str, strlen(Str), &Tmp, NULL);
	WriteConsole(GetStdHandle(STD_OUTPUT_HANDLE), "\n", strlen("\n"), &Tmp, NULL);
	return(0);
}

void ConOutDec(char *Prompt, int Num)
{
	char Str[80];
	DWORD Tmp;
	sprintf(Str, "%s %d\n", Prompt, Num);
	WriteConsole(GetStdHandle(STD_OUTPUT_HANDLE), Str, strlen(Str), &Tmp, NULL);
	return;
}








