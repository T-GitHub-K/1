;�o�C�i���[���l���A�X�L�[�����ɕϊ�

CODE	SEGMENT	'CODE'
	ASSUME	CS:CODE,DS:CODE,SS:CODE,ES:CODE

	DB	0FDH		;BSAVE�̈�
	DW	03000H		;�Z�O�����g�A�h���X�@�_�~�[
	DW	0FFFH		;�I�t�Z�b�g�A�h���X
	DW	ENDP-STARTP	;�v���O�����̒���

STARTP	EQU	$		;F000�Ԓn���J�n


;MAIN PROGRAM
MAIN	PROC	FAR


;�a�b�b�@�`�F�b�N
;�s�w�s�����ׂẮ@�w�n�q�@���Ƃ�@�a�b���Ɣ�r
;�b�`�k�k�i�s�w�s���C�a�b���C�e�k�f�j
;�e�k�f�@�O�F����@�P�F�G���[

	MOV	BP,SP
	MOV	BX,[BP+8]	;�s�w�s�� �X�g�����O�f�B�X�N���v�^
	MOV	CL,[BX]		;�s�w�s���̒���
	MOV	SI,[BX+1]	;�s�w�s���̃A�h���X
	XOR	DL,DL		;�c�k������

;�s�w�s���̂w�n�q�J��Ԃ�
LOOP2:
	MOV	AL,[SI]		;�s�w�s���P�o�C�g�擾
	XOR	DL,AL
	INC	SI		;���̂s�w�s���ɃZ�b�g
	DEC	CL		;�J�E���^�[����P�}�C�i�X
	JNE	LOOP2		;�O�łȂ���΃��[�v

;�w�n�q�̌��ʂƂa�b����r
	MOV	BX,[BP+6]	;�a�b�� �X�g�����O�f�B�X�N���v�^
	MOV	SI,[BX+1]	;�a�b���̃A�h���X
	MOV	AL,[SI]		;�a�b���̒��g
	XOR	DH,DH		;�e�k�f�������@(�O�Z�b�g)
	CMP	AL,DL		;�a�b���Ƃw�n�q�̌��ʂ��r
	JE	OK		;�������ꍇ���̂܂�
	MOV	DH,1H		;�������Ȃ��ꍇ�@(�P�Z�b�g)
OK:
	MOV	BX,[BP+4]	;�e�k�f�̂e�`�b
	MOV	[BX],DH
	XOR	DH,DH
	MOV	[BX+1],DH	;�e�k�f�Z�b�g

	RET	6



MAIN	ENDP
;MAIN END
ENDP	EQU	$
CODE	ENDS
	END
