// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
		panic("pgfault, the fault is not a write\n");

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
		panic("pgfault, not a copy-on-write page\n");
	}

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
	
	memcpy(PFTEMP, addr, PGSIZE);
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);

	return;
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
	}

	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
	int childpid = sys_exofork();
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
		// cprintf("fork child ok\n");
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);

		/* LAB 4 Challenge , set childenv's priority
		num--;
		if (num == 0) num = 0x100;
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);

		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
