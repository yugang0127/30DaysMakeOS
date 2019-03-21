/*中断关系*/

#include "bootpack.h"
#include <stdio.h>

void init_pic(void)
/* PIC的初始化 */
{
	io_out8(PIC0_IMR,  0xff   ); /* 禁止所有中断 */
	io_out8(PIC1_IMR,  0xff   ); /* 禁止所有中断 */

	io_out8(PIC0_ICW1, 0x11  ); /* 边沿触发模式(edge trigger mode) */
	io_out8(PIC0_ICW2, 0x20  ); /* IRQ-07由INT20-27接收 */
	io_out8(PIC0_ICW3, 1 << 2); /* PIC1由IRQ2连接 */
	io_out8(PIC0_ICW4, 0x01  ); /* 无缓冲区模式 */ 

	io_out8(PIC1_ICW1, 0x11  ); /* 边沿触发模式(edge trigger mode) */
	io_out8(PIC1_ICW2, 0x28  ); /* IRQ-07由INT28-2f接收 */
	io_out8(PIC1_ICW3, 2     ); /* PIC1由IRQ2连接 */
	io_out8(PIC1_ICW4, 0x01  ); /* 无缓冲区模式 */

	io_out8(PIC0_IMR,  0xfb  ); /* 11111011 PIC1以外全部禁止 */ 
	io_out8(PIC1_IMR,  0xff  ); /* 11111111 禁止所有中断 */

	return;
}

#define PORT_KEYDAT		0x0060

struct FIFO8 keyfifo;

void inthandler21(int *esp)
/*来自PS/2键盘的中断 */
{
	unsigned char data;
	io_out8(PIC0_OCW2, 0x61); /* 通知PIC"IRQ-01已结处理完毕"*/
	data = io_in8(PORT_KEYDAT);
	fifo8_put(&keyfifo, data);
	return;
}

void inthandler2c(int *esp)
/*来自PS/2鼠标的中断 */
{
	struct BOOTINFO *binfo = (struct BOOTINFO *) ADR_BOOTINFO;
	boxfill8(binfo->vram, binfo->scrnx, COL8_000000, 0, 0, 32 * 8 - 1, 15);
	putfonts8_asc(binfo->vram, binfo->scrnx, 0, 0, COL8_FFFFFF, "INT 2c (IRQ-12) : PS/2 mouse");
	for (;;) {
		io_hlt();
	}
}

void inthandler27(int *esp)
/*来自PIC0的不完全中断对策*/
/* Athlon64X2机因为芯片组的原因，在PIC初始化时会发生一次中断*/
/*这个中断处理函数对于那个中断什么都不做做做做过头*/
/*为什么什么都不做呢？
	→这个中断是由PIC初始化时的电气噪声产生的。
	没有必要认真地去处理什么。*/
{
	io_out8(PIC0_OCW2, 0x67); /*通知PIC接受完毕(参见7-1) */
	return;
}