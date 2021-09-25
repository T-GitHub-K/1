page 55,132
; ***********************************************************************
; *     	���s�o�b�`�t�@�C���E�I�����[�e�B���e�B 			*
; ***********************************************************************

; ********** �萔�ݒ� **********
val_buff_size	equ	07fffh			; **** �ő�t�@�C�����o�b�t�@��
val_first_pagenum equ	00			; **** �ŏ��ɕ\������y�[�W
val_max_page	equ	12			; **** �ő�̈�����y�[�W��
val_dir_flength	equ	128			; **** ���o��������������
						;      �P�t�@�C���̑傫��
val_fpos_offset	equ	01			; **** data_buff ���̃t�@�C����
						;      �̈ʒu
val_page_num	equ	20			; **** 1 Page���̕\��̧�ِ�
val_readbuff_length	equ	256

; ==========		�}�N����`		==========
PRINT_STR 	macro string			; string dispaly macro
		mov	dx,offset string
		mov	ah,9
		int	21h
		endm
PRINT_CHR	macro	chrval			;; ***** �P�����\��
		push	dx
		push	ax
		mov	dl,chrval
		mov	ah,2
		int	21h
		pop	ax
		pop	dx
		endm
; ********** Massage and dos return for Error *********
MSGOUT_RETURN	macro 	return_code,string
		PRINT_STR	end_msg
		PRINT_STR	string
		mov	ah,4ch			; ***** return dos function
		mov	al,return_code
		int	21h
		endm

; ==========		�f�[�^�Z�O�����g�̒�`		=========
dataseg		segment	para public 'data'
psp_save	dw	0			; *** psp segment save area
alldir		db	'*.BAT',0		; *** ̧�ٖ��̎w�肪�Ȃ�������
topmsg	   	db	'File Slector Utility Program by KEI',0dh,0ah,'$'
notdos_vermsg	db	0dh,0ah,7,'�c�n�r�̃o�[�W�����R�ȏオ�K�v�ł��B$'
dir_notfound	db	0dh,0ah,7,'���̃h���C�u�ɂ̓t�@�C�������݂��܂���B$'
openmes	   	db	27,'[>1h',27,'[2J',27,'[42m'
	   	db   	'Batch File Selector  Version 1.2.0                                             '
		db	27,'[24;4H',27,'[7m'
		db	' HELP ',12		; PF1
		db	'      ',12		; PF2
		db	' �I�� ',12		; PF3 
		db	'      ',12		; PF4
		db	' ���s ',12,12,12	; PF5
		db	'      ',12
		db	'      ',12
		db	'      ',12
		db	'      ',12
		db	'      ',12
	   	db	27,'[42m',27,'[00;47H$'		     ; *** �\��offset
end_msg		db	27,'[m$'
path_msg   	db   	'  Path [\$'
page_number   	db	0				; *** page count
disp_page 	db 	0				; *** display page
locxy	   	db	27,'[000;000H$' 		; *** locate position
cursor	   	db	0
sel_colorp 	db	27,'[43m$'			; *** select color code
get_count	db	0				; *** file read counter
non_color  	db	27,'[m',0dh,0ah,'$'		; *** reset  color code
cls_msg		db	27,'[2J$'
abend_msg   	db	0dh,0ah,'Program abend for running $'
eoc_pos		db	27,'[23;0H$'
quitmsg	   	db	0dh,0ah,27,'[2J',27,'[m<<< Program quit >>>$'
runmsg		db	27,'[m$'
memerr_msg	db	'Modify Allocates Memory Block Function Error$'
; ********** �t�@�C�����������p�f�[�^�G���A **********
subdirname	db	'.\'
subdirname2	db	40 dup(0h)
startup_buff	db	256 dup(20h),0dh
search_key	db	'REM ',0	; ***** �Ǎ����ޯ̧���Ŏ��ʂ��鷰ܰ��
; ********** DIR SELECT MODE COMMAND TABLE **********
;	                code   label			  key name
table	   	dw	0008h, back_page		; LEFT
	   	dw	003ch, next_page		; RIGHT
	   	dw	0036h, back_page		; ROLL UP
	   	dw	0037h, next_page		; ROLL DOWN
	   	dw	003ah, cursor_left		; UP
	   	dw	003dh, cursor_right		; DOWN
		dw	0064h, quit_com			; QUIT           [PF3]
		dw	0066h, run_com			; RUN 'setup.bat'[PF5]
	   	db	0ffh				; **** END key code
; ************ COM MODE COMMAND TABLE **********
com_shell	db	'  '
com_env		db	'\command.com'			; **** ����� shell
		db	52 dup(0)
; ****** ���s�� �@�@�@�e���@psp80h       psp50h(fcb)   psp60h(fcb) *****
com_blockpar	dw	0000h,com_string2,?,com_string3,?,com_string4,?
com_string2	db	60,'/C '			; Command parameter
com_string22	db	'.\'
com_string23	db	55 dup(20h),0dh,0ah,'$'
com_string3	db	'/C',0				; FCB no1 10byte
com_string4	db	'**** ',0			; FCB no2 10byte
search_point	db	0
dta_newarea   	db	128	 dup(0)			; DTA buffer
cd_buff    	db	80	 dup(0)			; ���� dir get buffer
read_buff  	db	32*256+1 dup(0ffh)		; read dir data buffer
data_buff   	db	128*256  dup(0ffh)		; *** data buff
dataseg		ends

; =========		 �X�^�b�N�Z�O�����g�̒�`	=========
stackseg	segment	para stack 'stack'
	db	256	dup('...stack')
stackseg	ends

; ========== 		�R�[�h�Z�O�����g�̒�`		==========
codeseg		segment	para public 'code'
		assume	cs:codeseg,ss:stackseg,ds:dataseg

; ==========		PROGRAM START		===========
START:
	mov	ax,dataseg			; ***** �f�[�^�Z�O�����g�̒�`
	mov	es,ax				; ***** STRING_COPY��̾�����
	mov	ax,ds				; **** �������̃Z�O�����g�ۑ�
	mov	word ptr es:psp_save,ax		; ***** psp seg add push
	mov	ax,dataseg			; ***** DS � dataseg define
	mov	ds,ax
	PRINT_STR	topmsg			; *** �J�n���b�Z�[�W
	mov	ah,30h				; *** Dos version check 
	int	21h
	cmp	al,3				; *** V3 �ȉ��� ERROR
	jnc	mstart
	MSGOUT_RETURN	02,notdos_vermsg	; **** don't dos version
mstart:	mov	ax,1a00h			; *** DAT adress �̐ݒ�
	mov	dx,offset dta_newarea
	int	21h
	call	read_dirdata			; *** read dir data
	mov	al,val_first_pagenum		; *** �\�������߰�ޔԍ��̏�����
	mov	byte ptr page_number,al

; ========== 		MAIN ROUTINE			=========
main:	call	page_print
	mov	al,0
	mov	byte ptr cursor,al
main_loop:			; ***** �f�B���N�g���[�I�����[�h/�R�}���h����
	mov	al,byte ptr cursor
	xor	ah,ah
	call	calc_cu
	dec	ah				; **** x���W���P�߂�
	call	move_cu
	mov	ah,1				; ***** N88BASIC ROM �L�[����
	int	21h				; ***** Function call
						; ***** Return keycode to AH

	mov	ah,al				; ***** Return keycode to AH
	mov	di,offset table-4 ;--+
keych:	;			     |
	add	di,4  ;<-------------+
	cmp	byte ptr [di],0ffh
	jz	error_cu			; if not found key
	cmp	ah,[di]				
	jnz	keych
	jmp	[di+2]				; JUMP same job
error_cu:
	jmp	short main_loop

; ==========	 	�e�R�}���h�̏���		=========
; ***** �y�[�W�߂��R�}���h *****
back_page:
	PRINT_STR	non_color
	mov	al,byte ptr page_number
	or	al,al
	jz	position_err
	dec	al
	mov	byte ptr page_number,al
	call	page_print
	jmp	short main_loop
; ***** �y�[�W����R�}���h *****
next_page:
	PRINT_STR	non_color
	mov	al,byte ptr page_number
	cmp	al,val_max_page-1
	jnc	position_err
	inc	al
	mov	byte ptr page_number,al
	call	page_print
	jmp	short main_loop
position_err:
	jmp	 main_loop
; ***** �J�[�\�������Ɉړ� *****
cursor_left:
	mov	al,byte ptr cursor
	sub	al,1
	jc	position_err
	jmp	short cursor_com
; ***** �J�[�\������Ɉړ� *****
cursor_right:
	mov	al,byte ptr cursor
	add	al,1
	cmp	al,20
	jz	position_err
cursor_com:
	mov	byte ptr cursor,al
	jmp	main_loop
; *****	   	�w��t�@�C�������s	*****
RUN_COM:call	sdir_set		; *** �T�u�f�B���N�g�����̐ݒ�
	call	main_run		; *** Command.com �ł̃R�}���h���s
	call	sdir_set
	mov	dx,offset com_string23
	mov	ah,3bh
	int	21h
	MSGOUT_RETURN	00,runmsg
; ********	Program Quit 	**********
quit_com:				; *** [PF�3]
	PRINT_STR	eoc_pos
	MSGOUT_RETURN	01,quitmsg

; =========		�T�u���[�`��			========
; ***** �f�B���N�g�����̃R�s�[		*****
sdir_set proc 	near
	mov	al,val_page_num
	mov	ah,byte ptr page_number
	mul	ah
	mov	bl,byte ptr cursor
	xor	bh,bh
	add	ax,bx				; ax=dir number
	call	calc_fa
	mov	di,offset com_string23		; **** com_string23 (���Ұ� ��)
sdir_lp:mov	al,[bx]				; **** �Ɏw�肳�ꂽ�t�@�C������
	mov	[di],al				; **** �]���R�s�[����
	inc	bx				
	inc	di
	or	al,al				; **** 0 �ŏI��A
	jne	sdir_lp
	ret
sdir_set endp

; **** 	�b�������������D�������ł̃R�}���h�̎��s  *****
main_run proc 	near
	PRINT_STR cls_msg			; **** ��ʏ���
	mov	ax,word ptr ds:psp_save		; **** �v���O������L��������
	mov	es,ax				; **** �k������
	mov	bx,2000h			; **** ���̃v���O�����{�̂�
	mov	ah,4ah				; **** ���蓖�Ă郁�����@128KB
	int	21h				; **** �����ۯ����ނ̕ύX
	jc	no_mem_error
no_mem_error:
	mov	ax,ds
	mov	com_blockpar[4],ax		; **** �R�}���h�u���b�N���쐬
	mov	com_blockpar[8],ax
	mov	com_blockpar[12],ax
	mov	dx,offset com_shell[2]		; **** command shell �̐ݒ�
	mov	bx,offset com_blockpar		; **** �R�}���h�u���b�N�̐ݒ�
	push	ds				; **** ES=DS <=CS
	pop	es
	mov	ah,4bh				; **** ��۸��т�۰�ނƎ��s
	mov	al,0				; **** Load & Run 
	int	21h
	jc	command_run_error		; **** �R�}���h�ُ�I��
	mov	ax,dataseg
	mov	ds,ax
	mov	es,ax
	ret					; **** �R�}���h����I��
command_run_error:
	MSGOUT_RETURN	10,abend_msg		; **** Error end
main_run endp

; *****	�������̃f�[�^��Ǎ���	[Input]  : dir   [Output] : data_buff
read_dirdata 	proc	near
	mov	byte ptr get_count,0		; **** read counter
	xor	bh,bh
	mov	ah,4eh				; search dir top
	mov	dx,offset alldir
	mov	cx,01h				; **** �Ǎ��ރt�@�C������
	int	21h
	jnc	find_dir
	MSGOUT_RETURN	03,dir_notfound		; **** file not found
find_dir:
	mov	di,offset read_buff
nxtfile:inc	get_count			; **** counter add
	mov	bx,offset dta_newarea[15h]
	mov	al,0				; al=0
	mov	[di],al				; �I��flag 
	mov	cx,22				; store length
stloop:	mov	ah,[bx]
	mov	[di+1],ah
	inc	bx
	inc	di
	loop	stloop
	mov	cx,9				; space length
	mov	al,0				; space code
stloop2:mov	[di+1],al
	inc	di
	loop	stloop2
	inc	di
skip_dirread:
	mov	ah,4fh				; search dir next
	mov	cx,10h				; **** �Ǎ��ރt�@�C������
	int	21h
	jc	chang_dirdata
	cmp	byte ptr get_count,250		; **** read data check
	je	chang_dirdata
	jmp	nxtfile

; ***** �t�@�C���E�o�b�t�@�̐��`���� 	*****
chang_dirdata:
	mov	si,offset read_buff
	mov	di,offset data_buff
chang_dirdata_loop:
	cmp	byte ptr [si],0ffh
	jne	change_dirdata_skip
	ret					; **** �l���������[�`���֖߂�
change_dirdata_skip:
	mov	byte ptr [di],0			; **** set flag reaset
	inc	di
; **** �t�@�C�����G���A�̃u�����N�ł̃��Z�b�g ****
	mov	cx,13				; **** file length
	mov	bx,0
reset_loop:
	inc	bx
	mov	byte ptr [di+bx],20h		; **** Reset space
	loop	reset_loop
	; **** �t�@�C�����̃R�s�[ ****
	mov	bx,0
read_set_loop:
	mov	al,byte ptr [si+bx+10]
	mov	byte ptr [di+bx],al
	cmp	al,0
	je	skip_read_set
	inc	bx
	jmp	short	read_set_loop
skip_read_set:
	push	di			; ***** ���������������t�@�C�����Z�b�g
	mov	bx,offset subdirname2
subdirname_loop:
	mov	al,byte ptr [di]
	cmp	al,0
	mov	byte ptr [bx],al
	je	startup_set
	inc	bx
	inc	di
	jmp	short subdirname_loop
startup_set:
	mov	cx,val_readbuff_length		; **** "startup_buff" ��
	mov	di,offset startup_buff		; **** 0H �Ŗ��߂���
	mov	al,0
	cld
	rep	stosb
	mov	ah,3dh				; **** file open
	mov	dx,offset subdirname		; **** file name
	mov	al,0				; **** read mode
	int	21h
	jc	fileread_skip
	mov	bx,ax				; **** �t�@�C���n���h��
	push	bx				; **** file handel push
	mov	ah,3fh				; **** read command
	mov	dx,offset startup_buff
	mov	cx,256				; **** read bytes
	int	21h
	pop	bx
	push	ax

	mov	ah,3eh				; **** close
	int	21h
	pop	ax
	cmp	ax,5				; **** ����'REM '���݂邩��
	jc	fileread_skip			; **** 5byte�ȉ���error

	pop	di
	push	di
	add	di,12	; <*****		; **** �ް��ر��offset�����Z
	mov	bx,offset startup_buff
	push	di				; **** DI ڼ޽���͕ۑ���
	push	si
	mov	bx,offset startup_buff		; **** ��������镶����
	mov	si,offset search_key		; **** ��������L�[���[�h
	call	search_string			; **** return BX,CLflag
	pop	si
	pop	di
	jc	fileread_skip0
data_move_loop:
	mov	al,byte ptr [bx]
	mov	byte ptr [di],al
	cmp	al,0dh
	je	fileread_skip0
	cmp	al,0			; <****
	je	fileread_skip0		; <****
	inc	bx
	inc	di
	jmp	short data_move_loop
fileread_skip0:
	mov	byte ptr [di],0
fileread_skip:
	pop	di
	add	di,62+65	; <****
	add	si,32
	jmp	chang_dirdata_loop



read_dirdata	endp

; *****	�@�@�P�y�[�W�̕\���T�u���[�`�� 		*****
page_print	proc	near
	push	cx
	PRINT_STR 	openmes 	; **** openning message
	PRINT_STR	path_msg	; **** PATH= �̕\��
	mov	ah,47h			; **** Path get
	mov	si,offset cd_buff
	mov	dl,0			; **** ���� drive
	int	21h
	mov	ah,2			; ***** ���݂̃J�����g�p�X��\��
ch_loop:mov	dl,[si]
	cmp	dl,0
	je	ch_skip
	int	21h
	inc	si
	jmp	short ch_loop
ch_skip:
	PRINT_CHR	']'
	PRINT_STR	non_color
	mov	al,byte ptr page_number		; ***** page number
	mov	ah,20 
	mul	ah
	xchg	ax,di
	mov	cx,20 				; ***** loop counter
ppri_loop:
	call	disp_one
	inc	di
	loop	ppri_loop
	mov	cl,0
	mov	byte ptr [cursor],cl
	pop	cx
	ret
page_print	endp

; *****		 display one dir data.  move cursole  display dir no. to DI
disp_one	proc	near
	push	bx
	push	cx
	mov	ax,di
	call	calc_fa
	jc	do_break
	call	calc_cu
	call	move_cu
	call	display
do_break:pop	cx
	pop	bx
	ret
disp_one	endp

; *****	 �t�@�C���A�h���X�̌v�Z 	
; *****	 [Iinput] : AL = file number(0~255) [Output] : BX = file address
calc_fa	proc near
	push	ax
	xor	ah,ah
	mov	bx,val_dir_flength		 ; **** one file length
	mul	bx				 ; **** dist DX
	mov	bx,offset data_buff+val_fpos_offset ; **** file name buffer
						 ; **** top address
	add	bx,ax
	mov	si,bx
	push	bx
	cmp	byte ptr [si],0ffh
	stc					; **** end of file set CF
	jz	fa_abnormal
	cmp	byte ptr [si-1],01h		; **** file select flag
	clc					; **** reset CF
	jnz	non_color_set
	PRINT_STR	sel_colorp
	jmp	fa_abnormal
non_color_set:
	PRINT_STR	non_color
fa_abnormal:
	pop	bx
	pop	ax
	ret
calc_fa endp

; *****		calculate cursole position 	*****
calc_cu	proc	near
	push	dx
	mov	dl,20 
	div	dl
	mov	byte ptr disp_page,al		; **** �\������y�[�W
	mov	al,ah
	mov	dl,2				; *** y pos offset
	add	al,dl
	mov	ah,2				; *** X offset
	pop	dx
	ret
calc_cu endp

; *****		move cursole  ah=x al=y		*****
move_cu proc	near
	push	ax
	xor	ah,ah
	mov	cl,10
	div	cl
	add	al,'0'
	mov	byte ptr(locxy+3),al
	add	ah,'0'
	mov	byte ptr(locxy+4),ah
	pop	ax
	mov	al,ah
	xor	ah,ah
	mov	cl,10
	div	cl
	add	al,'0'
	mov	byte ptr(locxy+7),al
	add	ah,'0'
	mov	byte ptr(locxy+8),ah
	PRINT_STR locxy
	ret
move_cu endp

; *****		�t�@�C�����𐮌`���ĕ\��	*****
display proc	near
	push	bx
	PRINT_CHR	'['
	mov	cx,12				; **** dir name length
display_loop:
	mov	dl,[bx]
	mov	ah,2
	int	21h
	inc	bx
	loop	display_loop
	PRINT_CHR	']'
	PRINT_CHR	'['
	mov	cx,63				; **** dir name length
display_loop2:
	mov	dl,[bx]
	mov	ah,2
	int	21h
	inc	bx
	loop	display_loop2
	PRINT_CHR	']'
	pop	bx
	ret					; **** return main
display endp

search_string	proc	near			; *** �����񌟍���ۼ��ެ
; [IN]	BX:��������Ώۂ̕�����(�Ō��00) DI:�������鷰ܰ�ނ̕�����(�Ō��00)
; [out]	CLflag OFF  ==> Keyword found   ON ==> Keyword not found
;       BX:�����Ώە�����̒��ŁA����������ܰ�ޕ�����̎��̈ʒu���ڽ

ss_next:mov	di,si				; **** �������鷰ܰ�� address
ss_loop:mov	al,byte ptr [di]
	cmp	al,0				; **** ��ܰ�ނ̍Ō�ɓ��B
	je	end_ss				; **** �����񔭌�
	mov	ah,byte ptr [bx]		; **** ��ܰ�ނ������炸
	cmp	ah,0				; **** ������̍Ō�ɓ��B
	je	fail_ss
	cmp	ah,60h				; **** �p�������̕ϊ�
	jc	sk_cov
	sub	ah,20h
sk_cov:	cmp	al,ah
	je	next_st
	inc	bx
	jmp	short	ss_next
next_st:inc	di
	inc	bx
	jmp	short	ss_loop
end_ss: clc					; **** �����̂��߂ɷ�ذ�̸ر
	ret					; **** �����ʒu�� [BX]
fail_ss:stc					; **** �����o���Ȃ������׸�
	ret
search_string	endp

codeseg	ends
	end 	START
