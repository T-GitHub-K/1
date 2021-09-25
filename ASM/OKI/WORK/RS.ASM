;********************************************************************
;                         RS232C I/O routine                        *
;********************************************************************
;
	TITLE	rs driver
;
;------------------------- ض��� ��� sleep -------------------------
SLEEP	macro
	jmp	$+2
	jmp	$+2
	endm
;
_TEXT	SEGMENT	BYTE PUBLIC 'CODE'
_TEXT	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
;
DGROUP	GROUP	CONST,_BSS,_DATA
	ASSUME	CS:_TEXT,DS:DGROUP,SS:DGROUP,ES:DGROUP
PUBLIC	_open_rs		;�q�r�|�[�g�C�j�V����
PUBLIC	_close_rs		;�q�r�|�[�g���o�[�X
PUBLIC	_put_rs			;�f�[�^���M
PUBLIC	_get_rs			;�f�[�^��M
;
_DATA	SEGMENT
_rcv_cnt	dw	?	;��M�f�[�^�J�E���^
_rcv_rp		dw	?	;��M���[�h�|�C���^
_rcv_wp		dw	?	;��M���C�g�|�C���^
_rcv_buff	dw	1024 dup(?)	;��M�o�b�t�@
_snd_cnt	dw	?	;���M�f�[�^�J�E���^
_snd_rp		dw	?	;���M���[�h�|�C���^
_snd_wp		dw	?	;���M���C�g�|�C���^
_snd_buff	dw	1024 dup(?)	;���M�o�b�t�@
_old_14		dd	?	;��INT 14H�C���^�[���v�g�x�N�^
_rs_add		dw	?	;RS232C�|�[�g�A�h���X
_port_no	db	?	;RS232C�|�[�g�ԍ�
_ir_vector	db	?	;���荞�݃x�N�^
_irm_8259	db	?	;8259�}�X�N
_DATA	ENDS
;
_TEXT	SEGMENT
	PUBLIC	_open_rs
;********************************************************************
;	RS232C �f�o�C�X�̊������]�����[�g�̃Z�b�g
;
;	input
;		SS:SP+2 ---- RS232C �|�[�g�ԍ�( 0 or 1 )
;		SS:SP+4 ---- RS232C ���[�h�p�����[�^( INT 14H�ɓ���)
;********************************************************************
;
_open_rs	PROC	NEAR
	push	bp
	mov	bp,sp
	mov	_rcv_rp,OFFSET DGROUP:_rcv_buff
	mov	_rcv_wp,OFFSET DGROUP:_rcv_buff
	mov	_rcv_cnt,0
	mov	al,byte ptr[bp+4]	;�|�[�g�ԍ�
	mov	_port_no,al
	mov	_ir_vector,0ch		;�|�[�g�P���荞�݃x�N�^
	mov	_irm_8259,0efh		;�|�[�g�P�W�Q�T�X�}�X�N
	test	al,al
	jz	open_rs1
	mov	_ir_vector,0bh		;�|�[�g�Q���荞�݃x�N�^
	mov	_irm_8259,0f7h		;�|�[�g�Q�W�Q�T�X�}�X�N
open_rs1:
	mov	al,[bp+6]		;RS232C���[�h
	sub	ah,ah
	mov	dl,_port_no		;RS232C�|�[�g�ԍ��Z�b�g
	xor	dh,dh
	int	14h			;RS232C���[�h�Z�b�g
	push	es
	push	ds
	mov	ah,35h			;���荞�݃A�h���X�擾�t�@���N�V����
	mov	al,_ir_vector
	int	21h			;�����荞�݃A�h���X�̓ǂݍ���
	mov	word ptr _old_14,bx
	mov	word ptr _old_14 + 2,es
	mov	al,_ir_vector
	mov	bx,cs
	mov	ds,bx
	mov	ah,25h			;���荞�݃A�h���X�ݒ�t�@���N�V����
	mov	dx,offset _TEXT:int_top
	int	21h			;���荞�݃A�h���X�Z�b�g
	pop	ds
	mov	ax,040h
	mov	es,ax
	mov	bl,_port_no
	xor	bh,bh
	shl	bx,1
	mov	ax,es:[bx]		;�|�[�g�h�^�n�A�h���X�̓ǂݍ���
	mov	_rs_add,ax
	mov	dx,ax
	inc	dx
	cli				;�����֎~
	SLEEP
	mov	al,1
	out	dx,al			;���荞�݃}�X�N���W�X�^��������
	SLEEP
	add	dx,3			;���f�����W�X�^�A�h���X
	mov	al,1011b
	out	dx,al			;���f�����W�X�^��������
	SLEEP
	in	al,21h			;8259�����}�X�N�l�擾
	SLEEP
	and	al,_irm_8259
	out	21h,al			;8259�����}�X�N��������
	SLEEP
	sti				;���荞�݋���
	pop	es
	mov	sp,bp
	pop	bp
	ret
_open_rs	ENDP
;
	PUBLIC	_close_rs
;********************************************************************
;	RS232C�f�o�C�X�����ɖ߂�
;
;
;	Input	-- �Ȃ�
;********************************************************************
;
_close_rs	PROC	NEAR
	push	bp
	mov	bp,sp
	cli				;�����֎~
	SLEEP
	mov	ah,_irm_8259		;8259�������}�X�N
	xor	ah,0ffh			;On / Off ���]
	in	al,21h			;8259���}�X�N�擾
	SLEEP
	or	al,ah			;���}�X�N�����֎~
	out	21h,al			;8259�����֎~�ݒ�
	push	ds
	mov	ah,25h			;�����A�h���X�ݒ�t�@���N�V����
	mov	al,_ir_vector
	mov	dx,word ptr _old_14	;�����荞�݃A�h���X�ɖ߂�
	mov	ds,word ptr _old_14 + 2
	int	21h
	pop	ds
	sti				;��������
	mov	sp,bp
	pop	bp
	ret
_close_rs	ENDP
;
	PUBLIC	_put_rs
;********************************************************************
;	�P�������o���[�`��
;
;
;	Input	-- SS:SP + 2 ���o�����R�[�h
;********************************************************************
_put_rs	PROC	NEAR
	push	bp
	mov	bp,sp
	mov	dx,_rs_add
	add	dx,5
_put_rs1:
	in	al,dx
	SLEEP
	test	al,00100000b		;Transmitter holding register empty ?
	jz	_put_rs1
	mov	al,[bp+4]
	sub	dx,5
	out	dx,al
	sub	ah,ah
	mov	sp,bp
	pop	bp
	ret
_put_rs	ENDP
;
	PUBLIC	_get_rs
;********************************************************************
;	�P������M���[�`��
;
;
;	Input	-- �Ȃ�
;	Output	-- AL = ��M�����R�[�h�i�`�g�@���@�O�O�̎��j
;		-- AX = -1.. ��M�f�[�^�����݂��Ȃ�
;********************************************************************
_get_rs	PROC	NEAR
	push	bp
	mov	bp,sp
	sub	sp,2
	cmp	_rcv_cnt,0
	jne	get_rs1
	mov	ax,-1
	jmp	SHORT get_rs3
get_rs1:
	mov	bx,_rcv_rp
	add	_rcv_rp,2
	mov	ax,[bx]
	mov	[bp-2],ax
	cmp	_rcv_rp,OFFSET DGROUP:_rcv_buff+2048
	jb	get_rs2
	mov	_rcv_rp,OFFSET DGROUP:_rcv_buff
get_rs2:
	mov	ax,[bp-2]
	xor	ah,ah
	dec	_rcv_cnt
get_rs3:
	mov	sp,bp
	pop	bp
	ret
_get_rs	ENDP
;
;********************************************************************
;	��M���荞�ݏ������[�`��
;********************************************************************
;					��M�����A�h���X
int_top:
	sti
	push	ax
	push	bx
	push	cx
	push	dx
	push	ds
	mov	ax,seg DGROUP
	mov	ds,ax			;C�̃f�[�^�Z�O�����g�Z�b�g
	mov	dx,_rs_add
	add	dx,2			;Interupt identification ���ڽ
	in	al,dx
	SLEEP
	test	al,100b
	jz	int_top_snd
	add	dx,3			;Line starus ڼ޽����ڽ
	in	al,dx
	SLEEP
	mov	ch,al
	sub	dx,5
	in	al,dx
	SLEEP
	mov	cl,al
	mov	ax,_rcv_cnt
	cmp	ax,1024
	jz	int_topx
	mov	bx,_rcv_wp
	mov	[bx],cx
	inc	bx
	inc	bx
	cmp	bx,offset DGROUP:_rcv_buff + 2048
	jnz	int_top_1
	mov	bx,offset DGROUP:_rcv_buff
int_top_1:
	mov	_rcv_wp,bx
	inc	_rcv_cnt
	jmp	short int_topx
int_top_snd:
int_topx:
	cli
	mov	al,20h
	out	20h,al
	SLEEP
	sti
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	iret
;
_TEXT	ENDS
END
