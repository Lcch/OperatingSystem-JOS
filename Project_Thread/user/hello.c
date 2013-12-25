#include <inc/lib.h>

pthread_mutex_t Lock;
int sum;
int k;

void mythread(void * arg) {
	int i, t, g;
	for (i = 0; i != 10000; i++) {
		cprintf("%d\n", sum);
		pthread_mutex_lock(&Lock);
		t = sum;
		for (g = 0; g != 10; g++) k++;
		++t;
		for (g = 0; g != 10; g++) k++;
		sum = t;
		pthread_mutex_unlock(&Lock);
	}
}

void
umain(int argc, char **argv)
{
	pthread_mutex_init(&Lock);
	uint32_t id[2];
	sum = 0;
	pthread_create(&id[0], mythread, NULL);
	pthread_create(&id[1], mythread, NULL);
	pthread_join(id[0]);
	pthread_join(id[1]);
	cprintf("HAHA: %d\n", sum);
}

/*
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
*/



/*
pthread_mutex_t Lock;
int wc = 0;
int k = 0;

void mythread(void * arg) {
	int i;
	//pthread_mutex_lock(&Lock);
	int t = wc;
	ffor (i = 0; i < 2000000; i++) k++;
	t = t + 1;
	if ((uint32_t)arg == 0) {
		for (i = 0; i < 2000000; i++) k++;
	}
	wc = t;
	//pthread_mutex_unlock(&Lock);
}

void mythread2(void * arg) {
	int i;
	for (i = 0; i != 1000; i++)
		wc = wc + 1;
}

void
umain(int argc, char **argv)
{
//	cprintf("hello, world\n");
//	cprintf("i am environment %08x\n", thisenv->env_id);
	uint32_t id[2];
	wc = 0;
	pthread_create(&id[0], mythread2, NULL);
	pthread_create(&id[1], mythread2, NULL);
	pthread_join(id[0]);
	pthread_join(id[1]);
	cprintf("%d\n", wc);

	
	pthread_mutex_init(&Lock);

	int i;
	uint32_t id[3];
	for (i = 0; i != 3; i++) {
		pthread_create(&id[i], mythread, (void *)i);
	}
	pthread_join(id[1]);
	pthread_join(id[0]);
	pthread_join(id[2]);
	cprintf("%d\n", wc);
	*/
