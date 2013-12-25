#include <inc/lib.h>

int num = 0;

void mythread(void * arg) {
	cprintf("Hello from %d\n", ++num);
}

void
umain(int argc, char **argv)
{
	uint32_t id[10];
	int i;
	for (i = 0; i != 10; i++) {
		pthread_create(&id[i], mythread, NULL);
	}
	for (i = 0; i != 10; i++) {
		pthread_join(id[i]);
	}
}
