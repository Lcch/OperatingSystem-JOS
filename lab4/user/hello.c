// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	cprintf("hello, world\n");
	cprintf("i am environment %08x\n", thisenv->env_id);

	/*
	int i, child, j;
	for (i = 0; i != 3; i++) {
		child = fork();
		if (child == 0) {
			for (j = 0; j != 10; j++) {
				cprintf("hello world from : %d\n", i);
				sys_yield();
			}
			break;
		}
	}
	*/
}
