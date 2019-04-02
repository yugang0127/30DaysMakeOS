/*计时器关系*/
#include "bootpack.h"

#define PIC_CTRL	0x0043
#define PIC_CNT0	0x0040

struct TIMERCTL timerctl;

void init_pit(void)
{
	io_out8(PIC_CTRL, 0x34);
	io_out8(PIC_CNT0, 0x9c);
	io_out8(PIC_CNT0, 0x2e);
	timerctl.count = 0;
	return;
}

void inthandler20(int *esp)
{
	io_out8(PIC0_OCW2, 0x60); /* 把IRQ-00信号接收完了的信息通知PIC */
	timerctl.count++;
	return;
}