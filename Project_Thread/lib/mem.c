#include <inc/lib.h>

extern char end[];
static char *cur = end;

#define null ((char *)(0))

char *
malloc(uint32_t size)
{
	cur = ROUNDUP(cur, PGSIZE);

	char * ret = cur;
	int r;
	uint32_t t;
	for (t = 0; t < size; t += PGSIZE) {
		r = sys_page_alloc(0, cur, PTE_W | PTE_U | PTE_P);
		if (r < 0) {
			cur -= t;
			return null;
		}
		cur += PGSIZE;
	}
	return ret;
}