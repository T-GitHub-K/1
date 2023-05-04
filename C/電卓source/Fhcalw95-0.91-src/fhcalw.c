/*=============================================================================
*							�e�g�b�`�k for Windows
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


/*===== �֐��v���g�^�C�v ====================================================*/

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




/*===== �e�[�u�� ============================================================*/

/* �{�^���f�[�^�e�[�u�� */

BUTTONDATA Buttons[] = {
	{ { 12, 18}, {48,14}, BUT_QUIT,    3, "Quit", NULL },
	{ { 12, 36}, {48,14}, BUT_ICON,    2, "Icon", NULL },
	{ { 12, 54}, {48,14}, BUT_MENU,    2, "Menu", NULL },

	{ { 12, 81}, {24,24}, BUT_7,       0, "�V", NULL },
	{ { 40, 81}, {24,24}, BUT_8,       0, "�W", NULL },
	{ { 68, 81}, {24,24}, BUT_9,       0, "�X", NULL },
	{ { 96, 81}, {24,24}, BUT_E,       0, "�d", NULL },
	{ {124, 81}, {24,24}, BUT_F,       0, "�e", NULL },
	{ {152, 81}, {24,24}, BUT_LPAR,    1, "(", NULL },
	{ {180, 81}, {24,24}, BUT_RPAR,    1, ")", NULL },
	{ {208, 81}, {24,24}, BUT_AC,      1, "AC", NULL },
	{ {236, 81}, {24,24}, BUT_MRET,    1, "MR", NULL },

	{ { 12,108}, {24,24}, BUT_4,       0, "�S", NULL },
	{ { 40,108}, {24,24}, BUT_5,       0, "�T", NULL },
	{ { 68,108}, {24,24}, BUT_6,       0, "�U", NULL },
	{ { 96,108}, {24,24}, BUT_C,       0, "�b", NULL },
	{ {124,108}, {24,24}, BUT_D,       0, "�c", NULL },
	{ {152,108}, {24,24}, BUT_MINUS,   1, "�|", NULL },
	{ {180,108}, {24,24}, BUT_DIVIDE,  1, "��", NULL },
	{ {208,108}, {24,24}, BUT_CE,      1, "CE", NULL },
	{ {236,108}, {24,24}, BUT_MCLR,    1, "MC", NULL },

	{ { 12,135}, {24,24}, BUT_1,       0, "�P", NULL },
	{ { 40,135}, {24,24}, BUT_2,       0, "�Q", NULL },
	{ { 68,135}, {24,24}, BUT_3,       0, "�R", NULL },
	{ { 96,135}, {24,24}, BUT_A,       0, "�`", NULL },
	{ {124,135}, {24,24}, BUT_B,       0, "�a", NULL },
	{ {152,135}, {24,24}, BUT_PLUS,    1, "�{", NULL },
	{ {180,135}, {24,24}, BUT_TIMES,   1, "�~", NULL },
	{ {208,135}, {24,24}, BUT_RUN1,    1, "P1", NULL },
	{ {236,135}, {24,24}, BUT_MMINUS,  1, "M-", NULL },

	{ { 12,162}, {24,24}, BUT_0,       0, "�O", NULL },
	{ { 40,162}, {24,24}, BUT_DOT,     0, "�D", NULL },
	{ { 68,162}, {24,24}, BUT_COMMA,   1, "�}", NULL },
	{ { 96,162}, {24,24}, BUT_PER,     1, "��", NULL },
	{ {124,162}, {24,24}, BUT_SQR,     1, "��", NULL },
	{ {152,162}, {24,24}, BUT_EQUAL,   1, "��", NULL },
	{ {180,162}, {24,24}, BUT_HEX_DEC, 1, "HD", NULL },
	{ {208,162}, {24,24}, BUT_RUN2,    1, "P2", NULL },
	{ {236,162}, {24,24}, BUT_MPLUS,   1, "M+", NULL }
};


/* �\���\���f�[�^ */
static POINT PanelInner[5] = {{92,71},{92,9},{265,9},{265,71},{92,71}};

/* �\�������h��ׂ��p�f�[�^ */
static RECT Frame2 = {91,10,264,70};

/* �C���W�P�[�^�\���f�[�^ */
static POINT MarkHex[3] = {{75,34},{85,41},{75,48}};
static POINT MarkDec[3] = {{75,52},{85,59},{75,66}};

/* ���l�\���ʒu�f�[�^ */
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


/*===== �O���Q�� ============================================================*/




/*===== �O���[�o���f�[�^ ====================================================*/

HINSTANCE hInst;			/* �A�v���P�[�V�����̃C���X�^���X */

int inpmode;				/* ���̓��[�h (MODE_HEX / MODE_DEC) */

char DecDispStr[60];		/* �\��������i�P�O�i�j */
char HexDispStr[30];		/*			 �i�P�U�i�j */
char BinDispStr[30];		/*			 �i�Q�i�j */
char StsDispStr[30];		/*			 �i�X�e�[�^�X�j */

char *progpos;				/* �v���O�������s���̎��o���ʒu */
int prognum;				/* ���s�v���O�����ԍ� (0=�Ȃ�) */
char clip[256];				/* �N���b�v�{�[�h����擾�����e�L�X�g */

int WinSizeX;				/* �E�C���h�E�̃T�C�Y�i�w�j */
int WinSizeY;				/*					 �i�x�j */

/* ���̂��̂� INI�t�@�C���ɓo�^���� */

int DispComma;				/* �ʎ��\���t���O (0/1) */
int ButtonDisp;				/* �{�^���\���t���O (0/1) */
int EscIcon;				/* ESC�L�[�ŃA�C�R���� (0/1) */
int DispBinary;				/* �Q�i�\���t���O (0/1) */
int AlwaysOnTop;			/* ��ɑO�ɕ\���t���O (0/1) */
int WinPosX = CW_USEDEFAULT;				/* �E�C���h�E�\���ʒu�i�w�j */
int WinPosY = 0;				/* 					 �i�x�j */
int IconPosX;
int IconPosY;
char prog[2][256];			/* �v���O���� */
COLORREF PanelColor;		/* �p�l���̐F */
COLORREF InnerColor;		/* �\���p�l���̐F */
COLORREF TextColor;			/* �����̐F */
ushort KeyHotSts;			/* �z�b�g�L�[�̃V�t�g�X�e�[�^�X */
ushort KeyHotKey;			/* �z�b�g�L�[�̃L�[ */



/*===== ���[�J���ȃf�[�^ ====================================================*/

static HWND hWndMain;				/* ���C���E�C���h�E�̃E�C���h�E�n���h�� */
static HACCEL hAccel;				/* �A�N�Z�����[�^�̃n���h�� */

static int setonly;					/* ���Z�q�̃Z�b�g�����t���O */
static int status;					/* �d��̏�� */
static int errnum;					/* �G���[�ԍ� */

static char numstr[MAXINP_DEC+3];	/* ���͕����� */
static int negative;				/* �����t���O(���͕�����ɑ΂��Ă̂ݗL��) */

static int parlev;					/* ���ʂ̃��x�� */

static long double inpnum;			/* �g�b�v���x�� */
static long double numstk[3][10];	/* ���l�X�^�b�N */

static char op1[10];				/* �����Z�I�y���[�V���� */
static char op2[10];				/* �揜�Z�I�y���[�V���� */

static int tmpmode;					/* �ꎞ���̓��[�h�ύX���̕ۑ��p */

static int MetricY;
static int MetricX;

static long double Memory = 0.0;

//static int ime_open;






/*----- ���C�����[�`�� --------------------------------------------------------
*
*	Parameter
*		HINSTANCE hInstance : ���̃A�v���P�[�V�����̂��̃C���X�^���X�̃n���h��
*		HINSTANCE hPrevInstance : ���̃A�v���P�[�V�����̒��O�̃C���X�^���X�̃n���h��
*			0 = �ŏ��̃C���X�^���X
*		LPSTR lpszCmdLine : �A�v���P�[�V�������N�������Ƃ��̃R�}���h���C�������������O�|�C���^
*		int cmdShow : �ŏ��ɕ\������E�C���h�E�̌`���B
*			(SW_SHOWNORMAL / SW_HIDE / SW_MINIMIZE)
*
*	Return Value
*		int �Ō�̃��b�Z�[�W��wParam
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


/*----- �A�v���P�[�V�����̏����� ----------------------------------------------
*
*	Parameter
*		HINSTANCE hInstance : ���̃A�v���P�[�V�����̂��̃C���X�^���X�̃n���h��
*		HINSTANCE hPrevInstance : ���̃A�v���P�[�V�����̒��O�̃C���X�^���X�̃n���h��
*			0 = �ŏ��̃C���X�^���X
*		LPSTR lpszCmdLine : �A�v���P�[�V�������N�������Ƃ��̃R�}���h���C�������������O�|�C���^
*		int cmdShow : �ŏ��ɕ\������E�C���h�E�̌`���B
*			(SW_SHOWNORMAL / SW_HIDE / SW_MINIMIZE)
*
*	Return Value
*		int �X�e�[�^�X
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


/*----- ���b�Z�[�W���� --------------------------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*		UINT message  : ���b�Z�[�W�ԍ�
*		WPARAM wParam : ���b�Z�[�W�� WPARAM ����
*		LPARAM lParam : ���b�Z�[�W�� LPARAM ����
*
*	Return Value
*		���b�Z�[�W�ɑΉ�����߂�l
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

		/* �^�C�g���o�[�̂Ȃ����̃E�C���h�E�ړ��̂��߂̏��� */
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


/*----- �I�����̏��� ----------------------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
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










/*----- �d��Ɋ֌W����C�x���g���� --------------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*		int key : �C�x���g
*
*	Return Value
*		�Ȃ�
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


/*----- ���l���� --------------------------------------------------------------
*
*	Parameter
*		int key : �C�x���g
*
*	Return Value
*		int ���l���͂��������ǂ���
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

			case ',' :				/* �} */
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


/*----- �R�}���h���� ----------------------------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*		int key : �C�x���g
*
*	Return Value
*		int �R�}���h���������ǂ���
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
			/* �������Ȃ� */
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




/*----- ���j���[���� ----------------------------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*		int key : �C�x���g
*
*	Return Value
*		int �R�}���h���������ǂ���
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














/*----- �E�C���h�E���N���A���� ------------------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*		HDC hDC : �f�o�C�X�R���e�L�X�g
*
*	Return Value
*		�Ȃ�
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



/*----- �E�C���h�E�̕`�� ------------------------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*
*	Return Value
*		�Ȃ�
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

	/* �d��̖��邢�Ƃ��� */
	hPen = CreatePen(PS_SOLID, 0, RGB(255,255,255));
	hPenOld = SelectObject(hDC, hPen);
	MoveToEx(hDC, Rect.left, Rect.bottom, NULL);
	LineTo(hDC, Rect.left, Rect.top);
	LineTo(hDC, Rect.right-1, Rect.top);
	SelectObject(hDC, hPenOld);
	DeleteObject(hPen);

	/* �d��̈Â��Ƃ��� */
	hPen = CreatePen(PS_SOLID, 0, RGB(0,0,0));
	hPenOld = SelectObject(hDC, hPen);
	LineTo(hDC, Rect.right-1, Rect.bottom-1);
	LineTo(hDC, Rect.left-1, Rect.bottom-1);
	SelectObject(hDC, hPenOld);
	DeleteObject(hPen);

	/* �����Ղ̓��� */
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


/*----- �������\�� ----------------------------------------------------------
*
*	Parameter
*		HDC hDC : 
*		RECT *Rect : 
*		int Num : 
*		char *Text : 
*
*	Return Value
*		�Ȃ�
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


/*----- ���̓C���W�P�[�^��\�� ------------------------------------------------
*
*	Parameter
*		HDC hDC : �f�o�C�X�R���e�L�X�g
*
*	Return Value
*		�Ȃ�
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



/*----- �̈���y�C���g���� ----------------------------------------------------
*
*	Parameter
*		HDC hDC : �f�o�C�X�R���e�L�X�g�̃n���h��
*		HRGN hRGN : �̈�̃n���h��
*		COLORREF rgb : �u���V�̐F
*
*	Return Value
*		�Ȃ�
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


















/*----- ���̓C���W�P�[�^��\�� ------------------------------------------------
*
*	Parameter
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

static void UpdateIndicater(void)
{
	HDC hDC;

	hDC = GetDC(hWndMain);
	DispInputInd2(hDC);
	ReleaseDC(hWndMain, hDC);

	return;
}


/*----- �������\�� ----------------------------------------------------------
*
*	Parameter
*		int pos : �\���ʒu (0�`3)
*
*	Return Value
*		�Ȃ�
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



















/*----- �E�C���h�E�̈ʒu��ۑ� ------------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
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



/*----- �E�C���h�E�̃T�C�Y���Z�b�g���� ----------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

static void SetWinSize(void)
{
	WinSizeX = NorWinSizeX;
	WinSizeY = NorWinSizeY;
	if(ButtonDisp)
		WinSizeY = NoButtonWinSizeY;

	return;
}

















/*----- �W���X�e�[�^�X��\�� --------------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
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


/*----- �v���O�������s���X�e�[�^�X��\�� --------------------------------------
*
*	Parameter
*		char *prompt : ���̓v�����v�g
*
*	Return Value
*		�Ȃ�
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


/*----- ���l��\�� ------------------------------------------------------------
*
*	Parameter
*		int type : �\�����[�h
*			0 = �X�^�b�N�g�b�v��\��
*			1 = ���͒��̕������\��
*
*	Return Value
*		�Ȃ�
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
				/*===== 10�i���� =====*/

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
				/*===== 16�i���� =====*/

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


/*----- �P�O�i�\����������쐬 ------------------------------------------------
*
*	Parameter
*		long double num : ���l
*		char *str : ������̃Z�b�g�ʒu
*
*	Return Value
*		�Ȃ�
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


/*----- �P�O�i�\��������Ɉʎ��̃J���}���Z�b�g ------------------------------
*
*	Parameter
*		char *str : ������
*
*	Return Value
*		�Ȃ�
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


/*----- �P�U�i�\����������쐬 ------------------------------------------------
*
*	Parameter
*		long double num : ���l
*		char *str : ������̃Z�b�g�ʒu
*
*	Return Value
*		�Ȃ�
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

	/*===== �T�v���X���� =====*/

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


/*----- �P�U�i�\��������Ɉʎ��̃X�y�[�X���Z�b�g ----------------------------
*
*	Parameter
*		char *str : ������
*
*	Return Value
*		�Ȃ�
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


/*----- �Q�i�\����������쐬 --------------------------------------------------
*
*	Parameter
*		long double num : ���l
*		char *str : ������̃Z�b�g�ʒu
*
*	Return Value
*		�Ȃ�
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


/*----- �P�O�i������𐔒l�ɕϊ� ----------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		long double ���l
*----------------------------------------------------------------------------*/

static long double DecStr2Num(void)
{
	long double num;

	num = atof(numstr);
	if(negative)
		num = -num;
	return(num);
}


/*----- �P�U�i������𐔒l�ɕϊ� ----------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		long double ���l
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


/*----- �z�b�g�L�[��ݒ肷�� --------------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		int �X�e�[�^�X
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


/*----- �z�b�g�L�[�̐ݒ���������� --------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

static void ReleaseHotkey(void)
{
	if(KeyHotKey != 0)
		UnregisterHotKey(hWndMain, 0);
	return;
}




















/*----- ���͕������o�b�t�@�ɃZ�b�g --------------------------------------------
*
*	Parameter
*		char key : ���͕���
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

static void InsertKey(char key)
{
	int len;
	int max;

	max = MAXINP_DEC;							/* ���͉\������ݒ� */
	if(inpmode == MODE_HEX)
		max = MAXINP_HEX;
	if(strchr(numstr, '.') != 0)				/* �����_���͍ς݂Ȃ�{�P */
		max++;

	len = strlen(numstr);
	if(len < max)								/* ���͉\�Ȃ� */
	{
	    numstr[len++] = key;
	    numstr[len] = NUL;
	}
	return;
}


/*----- ���l���N���A ----------------------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
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


/*----- �ꎞ�I�ɂP�O�i���͂ɐݒ� ----------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

static void Change2Dec(void)
{
	if((inpmode == MODE_HEX) &&							/* ���݂��P�U�i���͂� */
	   ((status == NUM_DISP) ||							/* ���͏�ԂłȂ��� */
		(strcspn(numstr, "ABCDEF") == strlen(numstr))))	/* �����݂̂Ȃ� */
	{
		inpmode = MODE_DEC;						/* �ꎞ�I�ɂP�O�i���͂� */
		tmpmode = MODE_HEX;
		UpdateIndicater();
		if(status == NUM_INP)					/* ���͒��Ȃ�ĕ\�� */
			SetDisplay(1);
	}
	return;
}


/*----- �ꎞ�I�ɂP�U�i���͂ɐݒ� ----------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

static void Change2Hex(void)
{
	if((inpmode == MODE_DEC) &&					/* ���݂��P�O�i���͂� */
	   ((status == NUM_DISP) ||					/* ���͏�ԂłȂ��� */
		((strlen(numstr) <= 7) &&				/* �������V�����ȉ��� */
		 (strchr(numstr, '.') == NULL))))		/* �����_���Ȃ���� */
	{
		inpmode = MODE_HEX;						/* �ꎞ�I�ɂP�U�i���͂� */
		tmpmode = MODE_DEC;
		UpdateIndicater();
		if(status == NUM_INP)					/* ���͒��Ȃ�ĕ\�� */
			SetDisplay(1);
	}
	return;
}


/*----- �ꎞ�I�ɕύX�������[�h��߂� ------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

static void ResetTempMode(void)
{
	if(tmpmode != MODE_NONE)					/* �ꎞ�I�ȃ��[�h�ύX�Ȃ� */
	{
		inpmode = tmpmode;						/* ���Ƃɖ߂� */
		tmpmode = MODE_NONE;
		UpdateIndicater();
	}
	return;
}


/*----- �v���O�����̎��s�J�n���� ----------------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*		int num : �v���O�����ԍ� (1 or 2)
*
*	Return Value
*		�Ȃ�
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


/*----- �v���O�������s���� ----------------------------------------------------
*
*	Parameter
*		HWND hWnd : �E�C���h�E�n���h��
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
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
		CalcOpe(hWnd, '=');				/* �Ō�� = �𑗂��Ă��� */
		prognum = 0;
		DispNormalBar();
		SetDisplay(0);
	}
	return;
}


/*----- �v�Z���𐮌`���� ------------------------------------------------------
*
*	Parameter
*		char *istr : ���̎�
*		char *ostr : �ϊ���̎�
*
*	Return Value
*		int �X�e�[�^�X
*			0 = ����I��
*			1 = ���ʂ���������
*			2 = ���ʂ̑Ή�����������
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

	if((sts == 0) && (par_lev != 0))	/* �Ō�Ɋ��ʂ̑Ή������������Ȃ� */
		sts = 2;

	return(sts);
}


/*----- �v�����v�g������̎擾 ------------------------------------------------
*
*	Parameter
*		char *str : �v���O����������
*		char *prompt : �v�����v�g������̊i�[�ʒu
*
*	Return Value
*		char *�v���O����������̎��̎��o���ʒu
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
		strcpy(prompt, "���l�H");
	return(str);
}


/*----- ���Z�^���Z�̏��� ------------------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

static void CalcOp1(void)
{
	CalcOp2();				/* �揜�Z���c���Ă���Ȃ�v�Z���� */

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


/*----- ��Z�^���Z�̏��� ------------------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
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


/*----- �������̌v�Z ----------------------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
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


/*----- �p�[�Z���g�̌v�Z ------------------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
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


/*----- ���͒��̐��l�̎��o�� ------------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		long double ���l
*----------------------------------------------------------------------------*/

static long double GetNum(void)
{
	long double num;

	if(status == NUM_INP)						/* ���l���͒��Ȃ� */
	{
		if(inpmode == MODE_DEC)
			num = DecStr2Num();
		else
			num = HexStr2Num();
		status = NUM_DISP;
		negative = NO;
	}
	else										/* ���l�\�����Ȃ� */
		num = inpnum;							/* �X�^�b�N�g�b�v�̒l���Z�b�g */

	return(num);
}


/*----- ���l���X�^�b�N�ɃZ�b�g ------------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

static void PushNumber(void)
{
	PushStack(GetNum());
	return;
}


/*----- �X�^�b�N�Ƀv�b�V�� ----------------------------------------------------
*
*	Parameter
*		long double num : ���l
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

static void PushStack(long double num)
{
	numstk[2][parlev] = numstk[1][parlev];
	numstk[1][parlev] = numstk[0][parlev];
	numstk[0][parlev] = num;
	inpnum = num;
	return;
}


/*----- �X�^�b�N����|�b�v ----------------------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

static void PopStack(void)
{
	numstk[0][parlev] = numstk[1][parlev];
	numstk[1][parlev] = numstk[2][parlev];
	inpnum = numstk[0][parlev];
	return;
}


/*----- �G���[���Z�b�g���� ----------------------------------------------------
*
*	Parameter
*		int errno : �G���[�ԍ�
*
*	Return Value
*		�Ȃ�
*----------------------------------------------------------------------------*/

void Error(int errno)
{
	Clear();
	errnum = errno;
	status = NUM_ERR;
}















/*----- �E�C���h�E�Ƀ{�^���𒣂�t���� ----------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
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


/*----- �E�C���h�E�̃{�^�������ׂč폜 ----------------------------------------
*
*	Parameter
*		�Ȃ�
*
*	Return Value
*		�Ȃ�
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


/*----- �w��ID�����{�^���f�[�^��Ԃ� ----------------------------------------
*
*	Parameter
*		int Msg : ���b�Z�[�W(ID)
*
*	Return Value
*		BUTTONDATA *�{�^���f�[�^
*			NULL = ������Ȃ�
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












/* �f�o�b�O�p */

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








