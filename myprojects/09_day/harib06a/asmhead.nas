; haribote-os
; TAB=4

BOTPAK	EQU		0x00280000		; bootpackのロード先
DSKCAC	EQU		0x00100000		; ディスクキャッシュの場所
DSKCAC0	EQU		0x00008000		; ディスクキャッシュの場所（リアルモード）

; 有关BOOT_INFO
CYLS	EQU		0x0ff0			; 设定启动区
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2			; 关于颜色数目的信息，颜色的位数
SCRNX	EQU		0x0ff4			; 分辨率的X (screen x)
SCRNY	EQU		0x0ff6			; 分辨率的Y（screen y）
VRAM	EQU		0x0ff8			; 图像缓冲区的开始地址

		ORG		0xc200			; 这个程序将要被装载到内容的什么地方呢		

; 设置屏幕模式

		MOV		AL,0x13			; VGA显卡，320x200x8位彩色
		MOV		AH,0x00
		INT		0x10
		MOV		BYTE [VMODE],8	; 记录画面模式
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

; 用BIOS取得键盘上各种LED指示灯的状态

		MOV		AH,0x02
		INT		0x16 			; keyboard BIOS
		MOV		[LEDS],AL

; PIC关闭一切中断
;	根据AT兼容机的规格，如果要初始化PIC
;	必须在CLI之前进行，否则有时会挂起
;	随后进行PIC的初始化

		MOV		AL,0xff
		OUT		0x21,AL
		NOP						; 如果连续执行OUT指令，有些机种会无法正常运行
		OUT		0xa1,AL

		CLI						; 禁止CPU级别的中断

; 设定A20GATE，使CPU能够访问1MB以上的存储器

		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf			; enable A20
		OUT		0x60,AL
		CALL	waitkbdout

; 保护模式转移

[INSTRSET "i486p"]				; 到486的命令为止想使用的记述

		LGDT	[GDTR0]			; 设置临时GDT
		MOV		EAX,CR0
		AND		EAX,0x7fffffff	; 把bit31设为0(为了禁止页面）
		OR		EAX,0x00000001	; 将bit0设为1(用于保护模式转移)
		MOV		CR0,EAX
		JMP		pipelineflush
pipelineflush:
		MOV		AX,1*8			;  可读和写段32bit
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX

; bootpack的传输

		MOV		ESI,bootpack	; 源文件
		MOV		EDI,BOTPAK		; 源文件
		MOV		ECX,512*1024/4
		CALL	memcpy

; 顺便将磁盘数据传送到原始位置

; 首先从启动扇区

		MOV		ESI,0x7c00		; 源文件
		MOV		EDI,DSKCAC		; 源文件
		MOV		ECX,512/4
		CALL	memcpy

; 剩下的全部

		MOV		ESI,DSKCAC0+512	; 源文件
		MOV		EDI,DSKCAC+512	; 源文件
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; 从汽缸数转换为字节数/4
		SUB		ECX,512/4		; 只扣除IPL部分
		CALL	memcpy

; 因为asmhead必须做的事全部做完了
;	之后就交给bootpack了

; 启动bootpack

		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; 无可转发
		MOV		ESI,[EBX+20]	; 源文件
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	; 源文件
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	; 堆栈初始值
		JMP		DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout		; 如果AND的结果不是0的话就是waitkbdout
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			; 如果减去的结果不是0的话就是memcpy
		RET
; 如果memcpy不忘记放入地址尺寸前缀，弦指令也能写

		ALIGNB	16
GDT0:
		RESB	8				; 空选择器
		DW		0xffff,0x0000,0x9200,0x00cf	; 可读和写段32bit
		DW		0xffff,0x0000,0x9a28,0x0047	; 可执行片段32bit(用于bootpack)

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack: