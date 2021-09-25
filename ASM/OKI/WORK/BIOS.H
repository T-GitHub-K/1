.XLIST
IF1
%OUT BIOS.H_START
ENDIF
;********************************
;* 	BIOS CALL		*
;*				*
;********************************
;
;	�����ϊ� 	�L��/���� ���[�h	SWITCH=0 ����  SWITCH=1 �L��
;
FEP_SWITCH	MACRO	SWITCH
		MOV	AL,SWITCH
		MOV	BL,25H
		INT	83H
		ENDM
;
;	�L�[�{�[�h���� 	�L��/���� ���[�h	SWITCH=0 ����	SWITCH=1 �L��
;
KBD_SWITCH	MACRO	SWITCH
		MOV	DL,SWITCH
		MOV	CL,1AH
		INT	80H
		ENDM
;
;	�L�[�{�[�h	�Q�� 	  ���[�h
;	
KBD_MODE	MACRO
		MOV	AH,0
		MOV	CL,69H
		INT	80H
		ENDM
;
;	�L�[�{�[�h	�ݒ� 	  ���[�h
;	
KBD_MODE_S	MACRO	PARMS
		MOV	AH,1
		MOV	DX,PARMS
		MOV	CL,69H
		INT	80H
		ENDM

;
;	�a�h�n�r �b�`�k�k�@�l�`�b�q�n�@��`
;
;	�j��	AX,BX,ES
;
;
;


;	�@�\�R�[�h1
;
;	���荞�ݏ������[�`��  LEVEL 1  	�o�^,����
;
;	����	CL=01H
;		ES:DX=ECB���ڽ
;
;	�o��	�Ȃ�
;
BIOS_1		MACRO	ECB
		MOV	CL,01H
		MOV	DX,OFFSET ECB
		INT	80H
		ENDM


;	�@�\�R�[�h2
;
;	���荞�ݏ������[�`��  LEVEL 2  	�o�^,����
;
;	����	CL=02H
;		ES:DX=ECB���ڽ
;
;	�o��	�Ȃ�
;
BIOS_2		MACRO	ECB
		MOV	CL,02H
		MOV	DX,OFFSET ECB
		INT	80H
		ENDM


;	�@�\�R�[�h1
;
;	���荞�ݏ������[�`��  LEVEL 3  	�o�^,����
;
;	����	CL=03H
;		ES:DX=ECB���ڽ
;
;	�o��	�Ȃ�
;
BIOS_3		MACRO	ECB
		MOV	CL,03H
		MOV	DX,OFFSET ECB
		INT	80H
		ENDM


;	�@�\�R�[�h5
;
;	���荞�ݏ������[�`��  LEVEL 5  	�o�^,����
;
;	����	CL=05H
;		ES:DX=ECB���ڽ
;
;	�o��	�Ȃ�
;
BIOS_5		MACRO	ECB
		MOV	CL,05H
		MOV	DX,OFFSET ECB
		INT	80H
		ENDM


;	�@�\�R�[�h6
;
;	���荞�ݏ������[�`��  LEVEL 6  	�o�^,����
;
;	����	CL=06H
;		ES:DX=ECB���ڽ
;
;	�o��	�Ȃ�
;
BIOS_6		MACRO	ECB
		MOV	CL,06H
		MOV	DX,OFFSET ECB
		INT	80H
		ENDM


;	�@�\�R�[�h8
;
;	�^�C�}���荞�ݏ������[�`��  LEVEL 3  	�o�^,����
;
;	����	CL=08H
;		ES:DX=TECB���ڽ
;		AL=�o�^�ԍ�	(3-9)
;
;	�o��	�Ȃ�
;
BIOS_8		MACRO	TECB
		MOV	CL,08H
		MOV	DX,OFFSET TECB
		INT	80H
		ENDM


;	�@�\�R�[�h9
;
;	�^�C�}���荞�ݏ������[�`��  LEVEL 4  	�o�^,����
;
;	����	CL=09H
;		ES:DX=TECB���ڽ
;		AL=�o�^�ԍ�	(3-9)
;
;	�o��	�Ȃ�
;
BIOS_9		MACRO	TECB
		MOV	CL,09H
		MOV	DX,OFFSET TECB
		INT	80H
		ENDM


;	�@�\�R�[�h16
;
;	�h�n�a�x�s�d�̐ݒ�
;
;	����	CL=10H
;		DL=IOBYTE
;
;	�o��	�Ȃ�
;
BIOS_16		MACRO	IOBYTE
		MOV	CL,10H
		MOV	DL,IOBYTE
		INT	80H
		ENDM


;	�@�\�R�[�h17
;
;	�h�n�a�x�s�d�̎Q��
;
;	����	CL=11H
;
;	�o��	AL=IOBYTE
;
BIOS_17		MACRO	IOBYTE
		MOV	CL,11H
		INT	80H
		ENDM


;	�@�\�R�[�h24
;
;	���ް�ޥ�ޯ̧����̂P�����ǂݍ���
;
;	����	CL=18H
;
;	�o��	AL=ASCII����
;
BIOS_18		MACRO
		PUSH	ES
		MOV	CL,18H
		INT	80H
		POP	ES
		ENDM


;	�@�\�R�[�h25
;
;	���ް�ޥ�ޯ̧�̏�ԎQ��
;
;	����	CL=19H
;
;	�o��	AL=�ޯ̧���
;			0:�ޯ̧��
;			 :AH=�擪����	�ޯ̧�̏�Ԃ͕ω����Ȃ�
;
BIOS_19		MACRO
		MOV	CL,19H
		INT	80H
		ENDM


;	�@�\�R�[�h26
;
;	���ް�ޓ��̗͂L��,����
;
;	����	CL=1AH
;		DL=Ӱ��
;			0:�����͖���
;			1:�����͗L��
;	�o��	�Ȃ�
;
BIOS_26		MACRO	PARA
		MOV	CL,1AH
		MOV	DL,PARA
		INT	80H
		ENDM


;	�@�\�R�[�h27
;
;	���ް�ޓ��͕����̍Ċ���
;
;	����	CL=1BH
;		DL=���݂̓��͕����R�[�h
;		DH=�V���͕����R�[�h
;
;	�o��	�Ȃ�
;
BIOS_27		MACRO	NEW,OLD
		MOV	CL,1BH
		MOV	DL,OLD
		MOV	DH,NEW
		INT	80H
		ENDM


;	�@�\�R�[�h28
;
;	̧ݸ��ݷ�/���̼�ķ��̕����񊄓��ƎQ��
;
;	����	CL=1CH
;		ES:DX=����ݸޱ��ڽ
;		AL=�@�\FLG
;			0:����
;			1:�Q��
;			2:�ݒ�
;	�o��	�Ȃ�
;
BIOS_28		MACRO	STRING,PARA
		MOV	CL,1CH
		MOV	DX,OFFSET STRING
		MOV	AL,PARA
		INT	80H
		ENDM


;	�@�\�R�[�h29
;
;	���ް���ޯ̧�̸ر�
;
;	����	CL=1DH
;
;	�o��	�Ȃ�
;
BIOS_29		MACRO
		MOV	CL,1DH
		INT	80H
		ENDM


;	�@�\�R�[�h30
;
;	CTRL+F8,CTRL+F9�̏�ԏ�����
;
;	����	CL=1EH
;		DL=0
;		
;	�o��	�Ȃ�
;
BIOS_30		MACRO
		MOV	CL,1EH
		MOV	DL,0
		INT	80H
		ENDM


;	�@�\�R�[�h31
;
;	CTRL+F8,CTRL+F9�̏�ԎQ��
;
;	����	CL=1FH
;
;	�o��	AL=���
;			0:�Ȃ�
;			1:CTRL+F9
;			2:CTRL+F8
;			3:����
;
BIOS_31		MACRO
		MOV	CL,1FH
		INT	80H
		ENDM


;	�@�\�R�[�h32
;
;	̧ݸ��ݷ��p�g���b�v���̎Q��
;
;	����	CL=20H
;
;	�o��	ES:BX=�g���b�v���G���A�A�h���X
;
BIOS_32		MACRO
		MOV	CL,20H
		INT	80H
		ENDM


;	�@�\�R�[�h33
;
;	���ް�޷���ւ̕����o�^
;
;	����	CL=21H
;		DX=�����R�[�h
;
;	�o��	�Ȃ�
;
BIOS_33		MACRO	CHAR
		MOV	CL,21H
		MOV	DX,CHAR
		INT	80H
		ENDM


;	�@�\�R�[�h35
;
;	�Ђ炪��,�J�^�J�i�L�[�̏��
;
;	����	CL=23H
;
;	�o��	AL=���
;			0:������ĂȂ�
;			 :������Ă���
;
BIOS_35		MACRO
		MOV	CL,23H
		INT	80H
		ENDM


;	�@�\�R�[�h39
;
;	���ް�޸د����̗L��
;
;	����	CL=27H
;		DL=Ӱ��
;			0:�د��Ȃ�
;			1:�د�����
;	�o��	�Ȃ�
;
BIOS_39		MACRO	PARA
		MOV	CL,27H
		MOV	DL,PARA
		INT	80H
		ENDM


;	�@�\�R�[�h40
;
;	��ذ݂̏o�͏�Ԃ̎Q��
;
;	����	CL=28H
;
;	�o��	AL=���
;			0:�o�͕s��
;			 :�o�͉\
;
BIOS_40		MACRO
		MOV	CL,28H
		INT	80H
		ENDM


;	�@�\�R�[�h41
;
;	��ذ݂ւ̂P�����o��
;
;	����	CL=29H
;		DL=ASCII����
;
;	�o��	�Ȃ�
;
BIOS_29		MACRO	PARA
		PUSH	ES
		MOV	CL,29H
		MOV	DL,PARA
		INT	80H
		POP	ES
		ENDM


;	�@�\�R�[�h42
;
;	����Ӱ�ނ̐ݒ�
;
;	����	CL=2AH
;		DL=Ӱ��
;			0:���ٖ��\��
;			1:���ٕ\��
;			2:���ް�ޓ��͑҂��̂ݕ\��
;
BIOS_42		MACRO	PARA
		MOV	CL,2AH
		MOV	DL,PARA
		INT	80H
		ENDM










;	��ʕ\��	BIOS
;
BIOS_D7		MACRO	STRING
		PUSH	ES
		MOV	CL,0D7H				;BIOS CALL
		MOV	DX,OFFSET STRING		;INT 80H
		INT	80H				;'$'�܂ŕ\��
		POP	ES
		ENDM

IF1
%OUT BIOS.H_END
ENDIF
.LIST

