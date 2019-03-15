void io_hlt(void);
void write_mem8(int addr, int data);

void HariMain(void)
{
	int i; /*变量声明：i是一个32位整数*/

	for (i = 0xa0000; i <= 0xaffff; i++) {
		write_mem8(i, i & 0x0f); /* 低4位不动，高4位全部变成0 */
	}

	for (;;) {
		io_hlt();
	}
}