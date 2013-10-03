// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line

extern int user_setcolor;

struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Backtrace", mon_backtrace },
    { "setcolor", "Change the console color", mon_setcolor },
    { "showmappings", "Show virtual addresses mappings", mon_showmappings },
    { "setpermission", "set permission", mon_setpermission },
    { "dump", "dump contents in memory", mon_dump }
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}

int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
    if (argc != 2) {
        cprintf("Command should be: setcolor [binary number]\n");
        cprintf("num show the color attribute. \n");
        cprintf("                 Text Attribute Byte (B & W)    \n");
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
        cprintf(" This is color that you want ! \n");
    }
    return 0;
}

int
mon_setpermission(int argc, char **argv, struct Trapframe *tf)
{
    if (argc != 5) { 
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
        cprintf("Example: setpermissions 0x0 1 0 1\n");
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
        uint32_t perm = 0;
        if (argv[2][0] == '1') perm |= PTE_W;
        if (argv[3][0] == '1') perm |= PTE_U;
        if (argv[4][0] == '1') perm |= PTE_P;
        addr = ROUNDUP(addr, PGSIZE);
        pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
        if (pte != NULL) {
            cprintf("0x%08x -> pa: 0x%08x\n old_perm: ", addr, PTE_ADDR(*pte));
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
            cprintf("  --> new_perm: ");
            *pte = PTE_ADDR(*pte) | perm;     
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
            cprintf("\n");
        } else {
            cprintf(" no mapped \n");
        }
    }
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
        return true;
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
        return true;
    }
    if (addr < -KERNBASE) {
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
        return true;
    }
    // Not in virtual memory mapped.
    return false;
}

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
    if (argc != 4) {
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
        uint32_t haddr = strtol(argv[3], NULL, 0);
        if (laddr > haddr) {
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
        }
        laddr = ROUNDDOWN(laddr, 4);
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n"); 
                    cprintf("0x%08x:  ", now);
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
        }
    }
    return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
    if (argc != 3) {
        cprintf("Command should be: showmappings [addr1] [addr2]\n");
        cprintf("Example: showmappings 0x3000 0x5000\n");
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
        uint32_t haddr = strtol(argv[2], NULL, 0);
        if (laddr > haddr) {
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
        }
        laddr = ROUNDDOWN(laddr, PGSIZE);
        haddr = ROUNDUP(haddr, PGSIZE);
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
            cprintf("[ 0x%08x, 0x%08x ) -> ", now, now + PGSIZE); 
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
            if (pte == 0 || (*pte & PTE_P) == 0) {
                cprintf(" no mapped \n");
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
                if (*pte & PTE_U) cprintf(" user       ");
                else cprintf(" supervisor ");
                if (*pte & PTE_W) cprintf(" RW ");
                else cprintf(" R ");
                cprintf("\n");
            }
        }
    }
    return 0;
}

/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
