// program to cause a breakpoint trap

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $3");

    // my test for continue:
    // cprintf("hello from A\n");
    // cprintf("hello from B\n");
 	// cprintf("hello from C\n");   

 	// my test for singal stepping
 	asm volatile("movl $0x1, %eax");
 	asm volatile("movl $0x2, %eax");
}

