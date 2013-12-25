#include <inc/lib.h>

int sum;
int k;

void mythread(void * arg) {
	int i, t, g;
	for (i = 0; i != 10000; i++) {
		cprintf("%d\n", sum);
		t = sum;
		for (g = 0; g != 10; g++) k++;
		++t;
		for (g = 0; g != 10; g++) k++;
		sum = t;
	}
}

void
umain(int argc, char **argv)
{
	uint32_t id[2];
	sum = 0;
	pthread_create(&id[0], mythread, NULL);
	pthread_create(&id[1], mythread, NULL);
	pthread_join(id[0]);
	pthread_join(id[1]);
	cprintf("HAHA: %d\n", sum);
}

