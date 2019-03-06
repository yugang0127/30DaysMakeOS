	DB	0xeb, 0x4e, 0x90, 0x48, 0x45, 0x4c, 0x4c, 0x4f
	DB	0x49, 0x50, 0x4c, 0x00, 0x02, 0x01, 0x01, 0x00
	DB	0x02, 0xe0, 0x00, 0x40, 0x0b, 0xf0, 0x09, 0x00
	DB	0x12, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x40, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x29, 0xff
	DB	0xff, 0xff, 0xff, 0x48, 0x45, 0x4c, 0x4c, 0x4f
	DB	0x2d, 0x4f, 0x53, 0x20, 0x20, 0x20, 0x46, 0x41
	DB	0x54, 0x31, 0x32, 0x20, 0x20, 0x20, 0x00, 0x00
	RESB	16
	DB	0xb8, 0x00, 0x00, 0x8e, 0xd0, 0xbc, 0x00, 0x7c
	DB	0x8e, 0xd8, 0x8e, 0xc0, 0xbe, 0x74, 0x7c, 0x8a
	DB	0x04, 0x83, 0xc6, 0x01, 0x3c, 0x00, 0x74, 0x09
	DB	0xb4, 0x0e, 0xbb, 0x0f, 0x00, 0xcd, 0x10, 0xeb
	DB	0xee, 0xf4, 0xeb, 0xfd, 0x0a, 0x0a, 0x68, 0x65
	DB	0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72
	DB	0x6c, 0x64, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00
	RESB	368
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x55, 0xaa
	DB	0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
	RESB	4600
	DB	0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
	RESB	1469432
	
	; hello-os
	; TAB=4

	; 以下这段是标准FAT12格式软盘专用的代码

			DB	0xeb, 0x4e, 0x90
			DB	"HELLOIPL"	     ; 启动器的名称可以任意的字符串（8字节）
			DW	512			     ; 每个扇区（sector）的大小（必须为512字节）
			DB	1                ; 簇（cluster）的大小（必须为一个扇区）
			DW	1                ; FAT的起始位置（一般从第一个扇区开始）
			DB	2                ; FAT的个数（必须为2）
			DW	224              ; 根目录的大小（一般设成224项）
			DW	2880             ; 该磁盘的大小（必须是2880扇区）
			DB	0xf0             ; 磁盘的种类（必须是0xf0)
			DW	9                ; FAT的长度（必须是9扇区）
			DW	18               ; 1个磁道（track）有几个扇区（必须是18）
			DW	2                ; 磁头数（必须是2）
			DD	0                ; 不使用分区，必须是0
			DD	2880             ; 重写一次磁盘大小
			DB	0, 0, 0x29       ;