
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 60 12 00       	mov    $0x126000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 60 12 f0       	mov    $0xf0126000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 04 01 00 00       	call   f0100142 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <msrs_init>:
#include <kern/spinlock.h>

static void boot_aps(void);

void msrs_init()
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
	// set up model specific registers
	extern void sysenter_handler();

	// GD_KT is kernel code segment, is also CS register
	wrmsr(IA32_SYSENTER_CS, GD_KT, 0);
f0100043:	ba 00 00 00 00       	mov    $0x0,%edx
f0100048:	b8 08 00 00 00       	mov    $0x8,%eax
f010004d:	b9 74 01 00 00       	mov    $0x174,%ecx
f0100052:	0f 30                	wrmsr  
	wrmsr(IA32_SYSENTER_ESP, KSTACKTOP, 0);
f0100054:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0100059:	b1 75                	mov    $0x75,%cl
f010005b:	0f 30                	wrmsr  
	wrmsr(IA32_SYSENTER_EIP, (uint32_t)(sysenter_handler), 0);		// entry of sysenter
f010005d:	b8 04 84 12 f0       	mov    $0xf0128404,%eax
f0100062:	b1 76                	mov    $0x76,%cl
f0100064:	0f 30                	wrmsr  
}
f0100066:	c9                   	leave  
f0100067:	c3                   	ret    

f0100068 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100068:	55                   	push   %ebp
f0100069:	89 e5                	mov    %esp,%ebp
f010006b:	56                   	push   %esi
f010006c:	53                   	push   %ebx
f010006d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100070:	83 3d 80 fe 2d f0 00 	cmpl   $0x0,0xf02dfe80
f0100077:	75 3a                	jne    f01000b3 <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100079:	89 35 80 fe 2d f0    	mov    %esi,0xf02dfe80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010007f:	fa                   	cli    
f0100080:	fc                   	cld    

	va_start(ap, fmt);
f0100081:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f0100084:	e8 27 5d 00 00       	call   f0105db0 <cpunum>
f0100089:	ff 75 0c             	pushl  0xc(%ebp)
f010008c:	ff 75 08             	pushl  0x8(%ebp)
f010008f:	50                   	push   %eax
f0100090:	68 80 64 10 f0       	push   $0xf0106480
f0100095:	e8 f3 3c 00 00       	call   f0103d8d <cprintf>
	vcprintf(fmt, ap);
f010009a:	83 c4 08             	add    $0x8,%esp
f010009d:	53                   	push   %ebx
f010009e:	56                   	push   %esi
f010009f:	e8 c3 3c 00 00       	call   f0103d67 <vcprintf>
	cprintf("\n");
f01000a4:	c7 04 24 ef 67 10 f0 	movl   $0xf01067ef,(%esp)
f01000ab:	e8 dd 3c 00 00       	call   f0103d8d <cprintf>
	va_end(ap);
f01000b0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000b3:	83 ec 0c             	sub    $0xc,%esp
f01000b6:	6a 00                	push   $0x0
f01000b8:	e8 ac 0f 00 00       	call   f0101069 <monitor>
f01000bd:	83 c4 10             	add    $0x10,%esp
f01000c0:	eb f1                	jmp    f01000b3 <_panic+0x4b>

f01000c2 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000c2:	55                   	push   %ebp
f01000c3:	89 e5                	mov    %esp,%ebp
f01000c5:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000c8:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000d2:	77 12                	ja     f01000e6 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000d4:	50                   	push   %eax
f01000d5:	68 a4 64 10 f0       	push   $0xf01064a4
f01000da:	6a 7c                	push   $0x7c
f01000dc:	68 eb 64 10 f0       	push   $0xf01064eb
f01000e1:	e8 82 ff ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000e6:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01000eb:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000ee:	e8 bd 5c 00 00       	call   f0105db0 <cpunum>
f01000f3:	83 ec 08             	sub    $0x8,%esp
f01000f6:	50                   	push   %eax
f01000f7:	68 f7 64 10 f0       	push   $0xf01064f7
f01000fc:	e8 8c 3c 00 00       	call   f0103d8d <cprintf>

	lapic_init();
f0100101:	e8 c5 5c 00 00       	call   f0105dcb <lapic_init>
	env_init_percpu();
f0100106:	e8 01 34 00 00       	call   f010350c <env_init_percpu>
	trap_init_percpu();
f010010b:	e8 94 3c 00 00       	call   f0103da4 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100110:	e8 9b 5c 00 00       	call   f0105db0 <cpunum>
f0100115:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010011c:	29 c2                	sub    %eax,%edx
f010011e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100121:	8d 14 85 20 00 2e f0 	lea    -0xfd1ffe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100128:	b8 01 00 00 00       	mov    $0x1,%eax
f010012d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100131:	c7 04 24 40 84 12 f0 	movl   $0xf0128440,(%esp)
f0100138:	e8 2a 5f 00 00       	call   f0106067 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f010013d:	e8 30 45 00 00       	call   f0104672 <sched_yield>

f0100142 <i386_init>:
	wrmsr(IA32_SYSENTER_EIP, (uint32_t)(sysenter_handler), 0);		// entry of sysenter
}

void
i386_init(void)
{
f0100142:	55                   	push   %ebp
f0100143:	89 e5                	mov    %esp,%ebp
f0100145:	53                   	push   %ebx
f0100146:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100149:	b8 08 10 32 f0       	mov    $0xf0321008,%eax
f010014e:	2d 6e e7 2d f0       	sub    $0xf02de76e,%eax
f0100153:	50                   	push   %eax
f0100154:	6a 00                	push   $0x0
f0100156:	68 6e e7 2d f0       	push   $0xf02de76e
f010015b:	e8 21 56 00 00       	call   f0105781 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100160:	e8 76 05 00 00       	call   f01006db <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100165:	83 c4 08             	add    $0x8,%esp
f0100168:	68 ac 1a 00 00       	push   $0x1aac
f010016d:	68 0d 65 10 f0       	push   $0xf010650d
f0100172:	e8 16 3c 00 00       	call   f0103d8d <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100177:	e8 e5 17 00 00       	call   f0101961 <mem_init>

	// MSRs init:
	msrs_init();
f010017c:	e8 bf fe ff ff       	call   f0100040 <msrs_init>

    // Lab 3 user environment initialization functions
	env_init();
f0100181:	e8 b0 33 00 00       	call   f0103536 <env_init>
    trap_init();
f0100186:	e8 1e 3d 00 00       	call   f0103ea9 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010018b:	e8 36 59 00 00       	call   f0105ac6 <mp_init>
	lapic_init();
f0100190:	e8 36 5c 00 00       	call   f0105dcb <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100195:	e8 54 3b 00 00       	call   f0103cee <pic_init>
f010019a:	c7 04 24 40 84 12 f0 	movl   $0xf0128440,(%esp)
f01001a1:	e8 c1 5e 00 00       	call   f0106067 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001a6:	83 c4 10             	add    $0x10,%esp
f01001a9:	83 3d 88 fe 2d f0 07 	cmpl   $0x7,0xf02dfe88
f01001b0:	77 16                	ja     f01001c8 <i386_init+0x86>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001b2:	68 00 70 00 00       	push   $0x7000
f01001b7:	68 c8 64 10 f0       	push   $0xf01064c8
f01001bc:	6a 65                	push   $0x65
f01001be:	68 eb 64 10 f0       	push   $0xf01064eb
f01001c3:	e8 a0 fe ff ff       	call   f0100068 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c8:	83 ec 04             	sub    $0x4,%esp
f01001cb:	b8 02 5a 10 f0       	mov    $0xf0105a02,%eax
f01001d0:	2d 88 59 10 f0       	sub    $0xf0105988,%eax
f01001d5:	50                   	push   %eax
f01001d6:	68 88 59 10 f0       	push   $0xf0105988
f01001db:	68 00 70 00 f0       	push   $0xf0007000
f01001e0:	e8 e6 55 00 00       	call   f01057cb <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001e5:	a1 c4 03 2e f0       	mov    0xf02e03c4,%eax
f01001ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001f1:	29 c2                	sub    %eax,%edx
f01001f3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001f6:	8d 04 85 20 00 2e f0 	lea    -0xfd1ffe0(,%eax,4),%eax
f01001fd:	83 c4 10             	add    $0x10,%esp
f0100200:	3d 20 00 2e f0       	cmp    $0xf02e0020,%eax
f0100205:	0f 86 95 00 00 00    	jbe    f01002a0 <i386_init+0x15e>
f010020b:	bb 20 00 2e f0       	mov    $0xf02e0020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100210:	e8 9b 5b 00 00       	call   f0105db0 <cpunum>
f0100215:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010021c:	29 c2                	sub    %eax,%edx
f010021e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100221:	8d 04 85 20 00 2e f0 	lea    -0xfd1ffe0(,%eax,4),%eax
f0100228:	39 c3                	cmp    %eax,%ebx
f010022a:	74 51                	je     f010027d <i386_init+0x13b>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010022c:	89 d8                	mov    %ebx,%eax
f010022e:	2d 20 00 2e f0       	sub    $0xf02e0020,%eax
f0100233:	c1 f8 02             	sar    $0x2,%eax
f0100236:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0100239:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f010023c:	89 d1                	mov    %edx,%ecx
f010023e:	c1 e1 05             	shl    $0x5,%ecx
f0100241:	29 d1                	sub    %edx,%ecx
f0100243:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100246:	89 d1                	mov    %edx,%ecx
f0100248:	c1 e1 0e             	shl    $0xe,%ecx
f010024b:	29 d1                	sub    %edx,%ecx
f010024d:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100250:	8d 44 90 01          	lea    0x1(%eax,%edx,4),%eax
f0100254:	c1 e0 0f             	shl    $0xf,%eax
f0100257:	05 00 10 2e f0       	add    $0xf02e1000,%eax
f010025c:	a3 84 fe 2d f0       	mov    %eax,0xf02dfe84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100261:	83 ec 08             	sub    $0x8,%esp
f0100264:	68 00 70 00 00       	push   $0x7000
f0100269:	0f b6 03             	movzbl (%ebx),%eax
f010026c:	50                   	push   %eax
f010026d:	e8 b5 5c 00 00       	call   f0105f27 <lapic_startap>
f0100272:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100275:	8b 43 04             	mov    0x4(%ebx),%eax
f0100278:	83 f8 01             	cmp    $0x1,%eax
f010027b:	75 f8                	jne    f0100275 <i386_init+0x133>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010027d:	83 c3 74             	add    $0x74,%ebx
f0100280:	a1 c4 03 2e f0       	mov    0xf02e03c4,%eax
f0100285:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010028c:	29 c2                	sub    %eax,%edx
f010028e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100291:	8d 04 85 20 00 2e f0 	lea    -0xfd1ffe0(,%eax,4),%eax
f0100298:	39 c3                	cmp    %eax,%ebx
f010029a:	0f 82 70 ff ff ff    	jb     f0100210 <i386_init+0xce>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f01002a0:	83 ec 04             	sub    $0x4,%esp
f01002a3:	6a 00                	push   $0x0
f01002a5:	68 74 e9 00 00       	push   $0xe974
f01002aa:	68 74 84 12 f0       	push   $0xf0128474
f01002af:	e8 a6 34 00 00       	call   f010375a <env_create>
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f01002b4:	83 c4 0c             	add    $0xc,%esp
f01002b7:	6a 00                	push   $0x0
f01002b9:	68 74 e9 00 00       	push   $0xe974
f01002be:	68 74 84 12 f0       	push   $0xf0128474
f01002c3:	e8 92 34 00 00       	call   f010375a <env_create>
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f01002c8:	83 c4 0c             	add    $0xc,%esp
f01002cb:	6a 00                	push   $0x0
f01002cd:	68 74 e9 00 00       	push   $0xe974
f01002d2:	68 74 84 12 f0       	push   $0xf0128474
f01002d7:	e8 7e 34 00 00       	call   f010375a <env_create>
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f01002dc:	83 c4 0c             	add    $0xc,%esp
f01002df:	6a 00                	push   $0x0
f01002e1:	68 74 e9 00 00       	push   $0xe974
f01002e6:	68 74 84 12 f0       	push   $0xf0128474
f01002eb:	e8 6a 34 00 00       	call   f010375a <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01002f0:	e8 7d 43 00 00       	call   f0104672 <sched_yield>

f01002f5 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002f5:	55                   	push   %ebp
f01002f6:	89 e5                	mov    %esp,%ebp
f01002f8:	53                   	push   %ebx
f01002f9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01002fc:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002ff:	ff 75 0c             	pushl  0xc(%ebp)
f0100302:	ff 75 08             	pushl  0x8(%ebp)
f0100305:	68 28 65 10 f0       	push   $0xf0106528
f010030a:	e8 7e 3a 00 00       	call   f0103d8d <cprintf>
	vcprintf(fmt, ap);
f010030f:	83 c4 08             	add    $0x8,%esp
f0100312:	53                   	push   %ebx
f0100313:	ff 75 10             	pushl  0x10(%ebp)
f0100316:	e8 4c 3a 00 00       	call   f0103d67 <vcprintf>
	cprintf("\n");
f010031b:	c7 04 24 ef 67 10 f0 	movl   $0xf01067ef,(%esp)
f0100322:	e8 66 3a 00 00       	call   f0103d8d <cprintf>
	va_end(ap);
f0100327:	83 c4 10             	add    $0x10,%esp
}
f010032a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010032d:	c9                   	leave  
f010032e:	c3                   	ret    
	...

f0100330 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100330:	55                   	push   %ebp
f0100331:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100333:	ba 84 00 00 00       	mov    $0x84,%edx
f0100338:	ec                   	in     (%dx),%al
f0100339:	ec                   	in     (%dx),%al
f010033a:	ec                   	in     (%dx),%al
f010033b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010033c:	c9                   	leave  
f010033d:	c3                   	ret    

f010033e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010033e:	55                   	push   %ebp
f010033f:	89 e5                	mov    %esp,%ebp
f0100341:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100346:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100347:	a8 01                	test   $0x1,%al
f0100349:	74 08                	je     f0100353 <serial_proc_data+0x15>
f010034b:	b2 f8                	mov    $0xf8,%dl
f010034d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010034e:	0f b6 c0             	movzbl %al,%eax
f0100351:	eb 05                	jmp    f0100358 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100353:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100358:	c9                   	leave  
f0100359:	c3                   	ret    

f010035a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010035a:	55                   	push   %ebp
f010035b:	89 e5                	mov    %esp,%ebp
f010035d:	53                   	push   %ebx
f010035e:	83 ec 04             	sub    $0x4,%esp
f0100361:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100363:	eb 29                	jmp    f010038e <cons_intr+0x34>
		if (c == 0)
f0100365:	85 c0                	test   %eax,%eax
f0100367:	74 25                	je     f010038e <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100369:	8b 15 24 f2 2d f0    	mov    0xf02df224,%edx
f010036f:	88 82 20 f0 2d f0    	mov    %al,-0xfd20fe0(%edx)
f0100375:	8d 42 01             	lea    0x1(%edx),%eax
f0100378:	a3 24 f2 2d f0       	mov    %eax,0xf02df224
		if (cons.wpos == CONSBUFSIZE)
f010037d:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100382:	75 0a                	jne    f010038e <cons_intr+0x34>
			cons.wpos = 0;
f0100384:	c7 05 24 f2 2d f0 00 	movl   $0x0,0xf02df224
f010038b:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010038e:	ff d3                	call   *%ebx
f0100390:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100393:	75 d0                	jne    f0100365 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100395:	83 c4 04             	add    $0x4,%esp
f0100398:	5b                   	pop    %ebx
f0100399:	c9                   	leave  
f010039a:	c3                   	ret    

f010039b <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010039b:	55                   	push   %ebp
f010039c:	89 e5                	mov    %esp,%ebp
f010039e:	57                   	push   %edi
f010039f:	56                   	push   %esi
f01003a0:	53                   	push   %ebx
f01003a1:	83 ec 0c             	sub    $0xc,%esp
f01003a4:	89 c6                	mov    %eax,%esi
f01003a6:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003ab:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003ac:	a8 20                	test   $0x20,%al
f01003ae:	75 19                	jne    f01003c9 <cons_putc+0x2e>
f01003b0:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01003b5:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01003ba:	e8 71 ff ff ff       	call   f0100330 <delay>
f01003bf:	89 fa                	mov    %edi,%edx
f01003c1:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003c2:	a8 20                	test   $0x20,%al
f01003c4:	75 03                	jne    f01003c9 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003c6:	4b                   	dec    %ebx
f01003c7:	75 f1                	jne    f01003ba <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01003c9:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003cb:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003d0:	89 f0                	mov    %esi,%eax
f01003d2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003d3:	b2 79                	mov    $0x79,%dl
f01003d5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003d6:	84 c0                	test   %al,%al
f01003d8:	78 1d                	js     f01003f7 <cons_putc+0x5c>
f01003da:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f01003df:	e8 4c ff ff ff       	call   f0100330 <delay>
f01003e4:	ba 79 03 00 00       	mov    $0x379,%edx
f01003e9:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003ea:	84 c0                	test   %al,%al
f01003ec:	78 09                	js     f01003f7 <cons_putc+0x5c>
f01003ee:	43                   	inc    %ebx
f01003ef:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01003f5:	75 e8                	jne    f01003df <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003f7:	ba 78 03 00 00       	mov    $0x378,%edx
f01003fc:	89 f8                	mov    %edi,%eax
f01003fe:	ee                   	out    %al,(%dx)
f01003ff:	b2 7a                	mov    $0x7a,%dl
f0100401:	b0 0d                	mov    $0xd,%al
f0100403:	ee                   	out    %al,(%dx)
f0100404:	b0 08                	mov    $0x8,%al
f0100406:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
    // set user_setcolor
    c |= (user_setcolor << 8);
f0100407:	a1 00 f0 2d f0       	mov    0xf02df000,%eax
f010040c:	c1 e0 08             	shl    $0x8,%eax
f010040f:	09 c6                	or     %eax,%esi

	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100411:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100417:	75 06                	jne    f010041f <cons_putc+0x84>
		c |= 0x0700;
f0100419:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f010041f:	89 f0                	mov    %esi,%eax
f0100421:	25 ff 00 00 00       	and    $0xff,%eax
f0100426:	83 f8 09             	cmp    $0x9,%eax
f0100429:	74 78                	je     f01004a3 <cons_putc+0x108>
f010042b:	83 f8 09             	cmp    $0x9,%eax
f010042e:	7f 0b                	jg     f010043b <cons_putc+0xa0>
f0100430:	83 f8 08             	cmp    $0x8,%eax
f0100433:	0f 85 9e 00 00 00    	jne    f01004d7 <cons_putc+0x13c>
f0100439:	eb 10                	jmp    f010044b <cons_putc+0xb0>
f010043b:	83 f8 0a             	cmp    $0xa,%eax
f010043e:	74 39                	je     f0100479 <cons_putc+0xde>
f0100440:	83 f8 0d             	cmp    $0xd,%eax
f0100443:	0f 85 8e 00 00 00    	jne    f01004d7 <cons_putc+0x13c>
f0100449:	eb 36                	jmp    f0100481 <cons_putc+0xe6>
	case '\b':
		if (crt_pos > 0) {
f010044b:	66 a1 04 f0 2d f0    	mov    0xf02df004,%ax
f0100451:	66 85 c0             	test   %ax,%ax
f0100454:	0f 84 e0 00 00 00    	je     f010053a <cons_putc+0x19f>
			crt_pos--;
f010045a:	48                   	dec    %eax
f010045b:	66 a3 04 f0 2d f0    	mov    %ax,0xf02df004
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100461:	0f b7 c0             	movzwl %ax,%eax
f0100464:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f010046a:	83 ce 20             	or     $0x20,%esi
f010046d:	8b 15 08 f0 2d f0    	mov    0xf02df008,%edx
f0100473:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100477:	eb 78                	jmp    f01004f1 <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100479:	66 83 05 04 f0 2d f0 	addw   $0x50,0xf02df004
f0100480:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100481:	66 8b 0d 04 f0 2d f0 	mov    0xf02df004,%cx
f0100488:	bb 50 00 00 00       	mov    $0x50,%ebx
f010048d:	89 c8                	mov    %ecx,%eax
f010048f:	ba 00 00 00 00       	mov    $0x0,%edx
f0100494:	66 f7 f3             	div    %bx
f0100497:	66 29 d1             	sub    %dx,%cx
f010049a:	66 89 0d 04 f0 2d f0 	mov    %cx,0xf02df004
f01004a1:	eb 4e                	jmp    f01004f1 <cons_putc+0x156>
		break;
	case '\t':
		cons_putc(' ');
f01004a3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a8:	e8 ee fe ff ff       	call   f010039b <cons_putc>
		cons_putc(' ');
f01004ad:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b2:	e8 e4 fe ff ff       	call   f010039b <cons_putc>
		cons_putc(' ');
f01004b7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004bc:	e8 da fe ff ff       	call   f010039b <cons_putc>
		cons_putc(' ');
f01004c1:	b8 20 00 00 00       	mov    $0x20,%eax
f01004c6:	e8 d0 fe ff ff       	call   f010039b <cons_putc>
		cons_putc(' ');
f01004cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d0:	e8 c6 fe ff ff       	call   f010039b <cons_putc>
f01004d5:	eb 1a                	jmp    f01004f1 <cons_putc+0x156>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01004d7:	66 a1 04 f0 2d f0    	mov    0xf02df004,%ax
f01004dd:	0f b7 c8             	movzwl %ax,%ecx
f01004e0:	8b 15 08 f0 2d f0    	mov    0xf02df008,%edx
f01004e6:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01004ea:	40                   	inc    %eax
f01004eb:	66 a3 04 f0 2d f0    	mov    %ax,0xf02df004
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f01004f1:	66 81 3d 04 f0 2d f0 	cmpw   $0x7cf,0xf02df004
f01004f8:	cf 07 
f01004fa:	76 3e                	jbe    f010053a <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004fc:	a1 08 f0 2d f0       	mov    0xf02df008,%eax
f0100501:	83 ec 04             	sub    $0x4,%esp
f0100504:	68 00 0f 00 00       	push   $0xf00
f0100509:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010050f:	52                   	push   %edx
f0100510:	50                   	push   %eax
f0100511:	e8 b5 52 00 00       	call   f01057cb <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100516:	8b 15 08 f0 2d f0    	mov    0xf02df008,%edx
f010051c:	83 c4 10             	add    $0x10,%esp
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010051f:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100524:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010052a:	40                   	inc    %eax
f010052b:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100530:	75 f2                	jne    f0100524 <cons_putc+0x189>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100532:	66 83 2d 04 f0 2d f0 	subw   $0x50,0xf02df004
f0100539:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010053a:	8b 0d 0c f0 2d f0    	mov    0xf02df00c,%ecx
f0100540:	b0 0e                	mov    $0xe,%al
f0100542:	89 ca                	mov    %ecx,%edx
f0100544:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100545:	66 8b 35 04 f0 2d f0 	mov    0xf02df004,%si
f010054c:	8d 59 01             	lea    0x1(%ecx),%ebx
f010054f:	89 f0                	mov    %esi,%eax
f0100551:	66 c1 e8 08          	shr    $0x8,%ax
f0100555:	89 da                	mov    %ebx,%edx
f0100557:	ee                   	out    %al,(%dx)
f0100558:	b0 0f                	mov    $0xf,%al
f010055a:	89 ca                	mov    %ecx,%edx
f010055c:	ee                   	out    %al,(%dx)
f010055d:	89 f0                	mov    %esi,%eax
f010055f:	89 da                	mov    %ebx,%edx
f0100561:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100562:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100565:	5b                   	pop    %ebx
f0100566:	5e                   	pop    %esi
f0100567:	5f                   	pop    %edi
f0100568:	c9                   	leave  
f0100569:	c3                   	ret    

f010056a <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010056a:	55                   	push   %ebp
f010056b:	89 e5                	mov    %esp,%ebp
f010056d:	53                   	push   %ebx
f010056e:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100571:	ba 64 00 00 00       	mov    $0x64,%edx
f0100576:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100577:	a8 01                	test   $0x1,%al
f0100579:	0f 84 dc 00 00 00    	je     f010065b <kbd_proc_data+0xf1>
f010057f:	b2 60                	mov    $0x60,%dl
f0100581:	ec                   	in     (%dx),%al
f0100582:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100584:	3c e0                	cmp    $0xe0,%al
f0100586:	75 11                	jne    f0100599 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100588:	83 0d 28 f2 2d f0 40 	orl    $0x40,0xf02df228
		return 0;
f010058f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100594:	e9 c7 00 00 00       	jmp    f0100660 <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f0100599:	84 c0                	test   %al,%al
f010059b:	79 33                	jns    f01005d0 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010059d:	8b 0d 28 f2 2d f0    	mov    0xf02df228,%ecx
f01005a3:	f6 c1 40             	test   $0x40,%cl
f01005a6:	75 05                	jne    f01005ad <kbd_proc_data+0x43>
f01005a8:	88 c2                	mov    %al,%dl
f01005aa:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01005ad:	0f b6 d2             	movzbl %dl,%edx
f01005b0:	8a 82 80 65 10 f0    	mov    -0xfef9a80(%edx),%al
f01005b6:	83 c8 40             	or     $0x40,%eax
f01005b9:	0f b6 c0             	movzbl %al,%eax
f01005bc:	f7 d0                	not    %eax
f01005be:	21 c1                	and    %eax,%ecx
f01005c0:	89 0d 28 f2 2d f0    	mov    %ecx,0xf02df228
		return 0;
f01005c6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005cb:	e9 90 00 00 00       	jmp    f0100660 <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f01005d0:	8b 0d 28 f2 2d f0    	mov    0xf02df228,%ecx
f01005d6:	f6 c1 40             	test   $0x40,%cl
f01005d9:	74 0e                	je     f01005e9 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01005db:	88 c2                	mov    %al,%dl
f01005dd:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01005e0:	83 e1 bf             	and    $0xffffffbf,%ecx
f01005e3:	89 0d 28 f2 2d f0    	mov    %ecx,0xf02df228
	}

	shift |= shiftcode[data];
f01005e9:	0f b6 d2             	movzbl %dl,%edx
f01005ec:	0f b6 82 80 65 10 f0 	movzbl -0xfef9a80(%edx),%eax
f01005f3:	0b 05 28 f2 2d f0    	or     0xf02df228,%eax
	shift ^= togglecode[data];
f01005f9:	0f b6 8a 80 66 10 f0 	movzbl -0xfef9980(%edx),%ecx
f0100600:	31 c8                	xor    %ecx,%eax
f0100602:	a3 28 f2 2d f0       	mov    %eax,0xf02df228

	c = charcode[shift & (CTL | SHIFT)][data];
f0100607:	89 c1                	mov    %eax,%ecx
f0100609:	83 e1 03             	and    $0x3,%ecx
f010060c:	8b 0c 8d 80 67 10 f0 	mov    -0xfef9880(,%ecx,4),%ecx
f0100613:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100617:	a8 08                	test   $0x8,%al
f0100619:	74 18                	je     f0100633 <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f010061b:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010061e:	83 fa 19             	cmp    $0x19,%edx
f0100621:	77 05                	ja     f0100628 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f0100623:	83 eb 20             	sub    $0x20,%ebx
f0100626:	eb 0b                	jmp    f0100633 <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100628:	8d 53 bf             	lea    -0x41(%ebx),%edx
f010062b:	83 fa 19             	cmp    $0x19,%edx
f010062e:	77 03                	ja     f0100633 <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f0100630:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100633:	f7 d0                	not    %eax
f0100635:	a8 06                	test   $0x6,%al
f0100637:	75 27                	jne    f0100660 <kbd_proc_data+0xf6>
f0100639:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010063f:	75 1f                	jne    f0100660 <kbd_proc_data+0xf6>
		cprintf("Rebooting!\n");
f0100641:	83 ec 0c             	sub    $0xc,%esp
f0100644:	68 42 65 10 f0       	push   $0xf0106542
f0100649:	e8 3f 37 00 00       	call   f0103d8d <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010064e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100653:	b0 03                	mov    $0x3,%al
f0100655:	ee                   	out    %al,(%dx)
f0100656:	83 c4 10             	add    $0x10,%esp
f0100659:	eb 05                	jmp    f0100660 <kbd_proc_data+0xf6>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010065b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100660:	89 d8                	mov    %ebx,%eax
f0100662:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100665:	c9                   	leave  
f0100666:	c3                   	ret    

f0100667 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100667:	55                   	push   %ebp
f0100668:	89 e5                	mov    %esp,%ebp
f010066a:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010066d:	80 3d 10 f0 2d f0 00 	cmpb   $0x0,0xf02df010
f0100674:	74 0a                	je     f0100680 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100676:	b8 3e 03 10 f0       	mov    $0xf010033e,%eax
f010067b:	e8 da fc ff ff       	call   f010035a <cons_intr>
}
f0100680:	c9                   	leave  
f0100681:	c3                   	ret    

f0100682 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100682:	55                   	push   %ebp
f0100683:	89 e5                	mov    %esp,%ebp
f0100685:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100688:	b8 6a 05 10 f0       	mov    $0xf010056a,%eax
f010068d:	e8 c8 fc ff ff       	call   f010035a <cons_intr>
}
f0100692:	c9                   	leave  
f0100693:	c3                   	ret    

f0100694 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100694:	55                   	push   %ebp
f0100695:	89 e5                	mov    %esp,%ebp
f0100697:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010069a:	e8 c8 ff ff ff       	call   f0100667 <serial_intr>
	kbd_intr();
f010069f:	e8 de ff ff ff       	call   f0100682 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01006a4:	8b 15 20 f2 2d f0    	mov    0xf02df220,%edx
f01006aa:	3b 15 24 f2 2d f0    	cmp    0xf02df224,%edx
f01006b0:	74 22                	je     f01006d4 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01006b2:	0f b6 82 20 f0 2d f0 	movzbl -0xfd20fe0(%edx),%eax
f01006b9:	42                   	inc    %edx
f01006ba:	89 15 20 f2 2d f0    	mov    %edx,0xf02df220
		if (cons.rpos == CONSBUFSIZE)
f01006c0:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006c6:	75 11                	jne    f01006d9 <cons_getc+0x45>
			cons.rpos = 0;
f01006c8:	c7 05 20 f2 2d f0 00 	movl   $0x0,0xf02df220
f01006cf:	00 00 00 
f01006d2:	eb 05                	jmp    f01006d9 <cons_getc+0x45>
		return c;
	}
	return 0;
f01006d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01006d9:	c9                   	leave  
f01006da:	c3                   	ret    

f01006db <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006db:	55                   	push   %ebp
f01006dc:	89 e5                	mov    %esp,%ebp
f01006de:	57                   	push   %edi
f01006df:	56                   	push   %esi
f01006e0:	53                   	push   %ebx
f01006e1:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006e4:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01006eb:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006f2:	5a a5 
	if (*cp != 0xA55A) {
f01006f4:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01006fa:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006fe:	74 11                	je     f0100711 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100700:	c7 05 0c f0 2d f0 b4 	movl   $0x3b4,0xf02df00c
f0100707:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010070a:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010070f:	eb 16                	jmp    f0100727 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100711:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100718:	c7 05 0c f0 2d f0 d4 	movl   $0x3d4,0xf02df00c
f010071f:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100722:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100727:	8b 0d 0c f0 2d f0    	mov    0xf02df00c,%ecx
f010072d:	b0 0e                	mov    $0xe,%al
f010072f:	89 ca                	mov    %ecx,%edx
f0100731:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100732:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100735:	89 da                	mov    %ebx,%edx
f0100737:	ec                   	in     (%dx),%al
f0100738:	0f b6 f8             	movzbl %al,%edi
f010073b:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010073e:	b0 0f                	mov    $0xf,%al
f0100740:	89 ca                	mov    %ecx,%edx
f0100742:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100743:	89 da                	mov    %ebx,%edx
f0100745:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100746:	89 35 08 f0 2d f0    	mov    %esi,0xf02df008

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010074c:	0f b6 d8             	movzbl %al,%ebx
f010074f:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100751:	66 89 3d 04 f0 2d f0 	mov    %di,0xf02df004

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100758:	e8 25 ff ff ff       	call   f0100682 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f010075d:	83 ec 0c             	sub    $0xc,%esp
f0100760:	0f b7 05 90 83 12 f0 	movzwl 0xf0128390,%eax
f0100767:	25 fd ff 00 00       	and    $0xfffd,%eax
f010076c:	50                   	push   %eax
f010076d:	e8 02 35 00 00       	call   f0103c74 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100772:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100777:	b0 00                	mov    $0x0,%al
f0100779:	89 da                	mov    %ebx,%edx
f010077b:	ee                   	out    %al,(%dx)
f010077c:	b2 fb                	mov    $0xfb,%dl
f010077e:	b0 80                	mov    $0x80,%al
f0100780:	ee                   	out    %al,(%dx)
f0100781:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100786:	b0 0c                	mov    $0xc,%al
f0100788:	89 ca                	mov    %ecx,%edx
f010078a:	ee                   	out    %al,(%dx)
f010078b:	b2 f9                	mov    $0xf9,%dl
f010078d:	b0 00                	mov    $0x0,%al
f010078f:	ee                   	out    %al,(%dx)
f0100790:	b2 fb                	mov    $0xfb,%dl
f0100792:	b0 03                	mov    $0x3,%al
f0100794:	ee                   	out    %al,(%dx)
f0100795:	b2 fc                	mov    $0xfc,%dl
f0100797:	b0 00                	mov    $0x0,%al
f0100799:	ee                   	out    %al,(%dx)
f010079a:	b2 f9                	mov    $0xf9,%dl
f010079c:	b0 01                	mov    $0x1,%al
f010079e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010079f:	b2 fd                	mov    $0xfd,%dl
f01007a1:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01007a2:	83 c4 10             	add    $0x10,%esp
f01007a5:	3c ff                	cmp    $0xff,%al
f01007a7:	0f 95 45 e7          	setne  -0x19(%ebp)
f01007ab:	8a 45 e7             	mov    -0x19(%ebp),%al
f01007ae:	a2 10 f0 2d f0       	mov    %al,0xf02df010
f01007b3:	89 da                	mov    %ebx,%edx
f01007b5:	ec                   	in     (%dx),%al
f01007b6:	89 ca                	mov    %ecx,%edx
f01007b8:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007b9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01007bd:	75 10                	jne    f01007cf <cons_init+0xf4>
		cprintf("Serial port does not exist!\n");
f01007bf:	83 ec 0c             	sub    $0xc,%esp
f01007c2:	68 4e 65 10 f0       	push   $0xf010654e
f01007c7:	e8 c1 35 00 00       	call   f0103d8d <cprintf>
f01007cc:	83 c4 10             	add    $0x10,%esp
}
f01007cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007d2:	5b                   	pop    %ebx
f01007d3:	5e                   	pop    %esi
f01007d4:	5f                   	pop    %edi
f01007d5:	c9                   	leave  
f01007d6:	c3                   	ret    

f01007d7 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007d7:	55                   	push   %ebp
f01007d8:	89 e5                	mov    %esp,%ebp
f01007da:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007dd:	8b 45 08             	mov    0x8(%ebp),%eax
f01007e0:	e8 b6 fb ff ff       	call   f010039b <cons_putc>
}
f01007e5:	c9                   	leave  
f01007e6:	c3                   	ret    

f01007e7 <getchar>:

int
getchar(void)
{
f01007e7:	55                   	push   %ebp
f01007e8:	89 e5                	mov    %esp,%ebp
f01007ea:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007ed:	e8 a2 fe ff ff       	call   f0100694 <cons_getc>
f01007f2:	85 c0                	test   %eax,%eax
f01007f4:	74 f7                	je     f01007ed <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007f6:	c9                   	leave  
f01007f7:	c3                   	ret    

f01007f8 <iscons>:

int
iscons(int fdnum)
{
f01007f8:	55                   	push   %ebp
f01007f9:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007fb:	b8 01 00 00 00       	mov    $0x1,%eax
f0100800:	c9                   	leave  
f0100801:	c3                   	ret    
	...

f0100804 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100804:	55                   	push   %ebp
f0100805:	89 e5                	mov    %esp,%ebp
f0100807:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010080a:	68 90 67 10 f0       	push   $0xf0106790
f010080f:	e8 79 35 00 00       	call   f0103d8d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100814:	83 c4 08             	add    $0x8,%esp
f0100817:	68 0c 00 10 00       	push   $0x10000c
f010081c:	68 bc 69 10 f0       	push   $0xf01069bc
f0100821:	e8 67 35 00 00       	call   f0103d8d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100826:	83 c4 0c             	add    $0xc,%esp
f0100829:	68 0c 00 10 00       	push   $0x10000c
f010082e:	68 0c 00 10 f0       	push   $0xf010000c
f0100833:	68 e4 69 10 f0       	push   $0xf01069e4
f0100838:	e8 50 35 00 00       	call   f0103d8d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010083d:	83 c4 0c             	add    $0xc,%esp
f0100840:	68 64 64 10 00       	push   $0x106464
f0100845:	68 64 64 10 f0       	push   $0xf0106464
f010084a:	68 08 6a 10 f0       	push   $0xf0106a08
f010084f:	e8 39 35 00 00       	call   f0103d8d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100854:	83 c4 0c             	add    $0xc,%esp
f0100857:	68 6e e7 2d 00       	push   $0x2de76e
f010085c:	68 6e e7 2d f0       	push   $0xf02de76e
f0100861:	68 2c 6a 10 f0       	push   $0xf0106a2c
f0100866:	e8 22 35 00 00       	call   f0103d8d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086b:	83 c4 0c             	add    $0xc,%esp
f010086e:	68 08 10 32 00       	push   $0x321008
f0100873:	68 08 10 32 f0       	push   $0xf0321008
f0100878:	68 50 6a 10 f0       	push   $0xf0106a50
f010087d:	e8 0b 35 00 00       	call   f0103d8d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100882:	b8 07 14 32 f0       	mov    $0xf0321407,%eax
f0100887:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010088c:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010088f:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100894:	89 c2                	mov    %eax,%edx
f0100896:	85 c0                	test   %eax,%eax
f0100898:	79 06                	jns    f01008a0 <mon_kerninfo+0x9c>
f010089a:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008a0:	c1 fa 0a             	sar    $0xa,%edx
f01008a3:	52                   	push   %edx
f01008a4:	68 74 6a 10 f0       	push   $0xf0106a74
f01008a9:	e8 df 34 00 00       	call   f0103d8d <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b3:	c9                   	leave  
f01008b4:	c3                   	ret    

f01008b5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01008b5:	55                   	push   %ebp
f01008b6:	89 e5                	mov    %esp,%ebp
f01008b8:	53                   	push   %ebx
f01008b9:	83 ec 04             	sub    $0x4,%esp
f01008bc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008c1:	83 ec 04             	sub    $0x4,%esp
f01008c4:	ff b3 04 6f 10 f0    	pushl  -0xfef90fc(%ebx)
f01008ca:	ff b3 00 6f 10 f0    	pushl  -0xfef9100(%ebx)
f01008d0:	68 a9 67 10 f0       	push   $0xf01067a9
f01008d5:	e8 b3 34 00 00       	call   f0103d8d <cprintf>
f01008da:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008dd:	83 c4 10             	add    $0x10,%esp
f01008e0:	83 fb 6c             	cmp    $0x6c,%ebx
f01008e3:	75 dc                	jne    f01008c1 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01008ed:	c9                   	leave  
f01008ee:	c3                   	ret    

f01008ef <mon_si>:
    return 0;
}

int 
mon_si(int argc, char **argv, struct Trapframe *tf)
{
f01008ef:	55                   	push   %ebp
f01008f0:	89 e5                	mov    %esp,%ebp
f01008f2:	83 ec 08             	sub    $0x8,%esp
f01008f5:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f01008f8:	85 c0                	test   %eax,%eax
f01008fa:	75 14                	jne    f0100910 <mon_si+0x21>
        cprintf("Error: you only can use si in breakpoint.\n");
f01008fc:	83 ec 0c             	sub    $0xc,%esp
f01008ff:	68 a0 6a 10 f0       	push   $0xf0106aa0
f0100904:	e8 84 34 00 00       	call   f0103d8d <cprintf>

    cprintf("tfno: %u\n", tf->tf_trapno);
    env_run(curenv);
    panic("mon_si : env_run return");
    return 0;
}
f0100909:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010090e:	c9                   	leave  
f010090f:	c3                   	ret    
        cprintf("Error: you only can use si in breakpoint.\n");
        return -1;
    }

    // next step also cause debug interrupt
    tf->tf_eflags |= FL_TF;
f0100910:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)

    cprintf("tfno: %u\n", tf->tf_trapno);
f0100917:	83 ec 08             	sub    $0x8,%esp
f010091a:	ff 70 28             	pushl  0x28(%eax)
f010091d:	68 b2 67 10 f0       	push   $0xf01067b2
f0100922:	e8 66 34 00 00       	call   f0103d8d <cprintf>
    env_run(curenv);
f0100927:	e8 84 54 00 00       	call   f0105db0 <cpunum>
f010092c:	83 c4 04             	add    $0x4,%esp
f010092f:	6b c0 74             	imul   $0x74,%eax,%eax
f0100932:	ff b0 28 00 2e f0    	pushl  -0xfd1ffd8(%eax)
f0100938:	e8 ec 31 00 00       	call   f0103b29 <env_run>

f010093d <mon_continue>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

int 
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
f010093d:	55                   	push   %ebp
f010093e:	89 e5                	mov    %esp,%ebp
f0100940:	83 ec 08             	sub    $0x8,%esp
f0100943:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f0100946:	85 c0                	test   %eax,%eax
f0100948:	75 14                	jne    f010095e <mon_continue+0x21>
        cprintf("Error: you only can use continue in breakpoint.\n");
f010094a:	83 ec 0c             	sub    $0xc,%esp
f010094d:	68 cc 6a 10 f0       	push   $0xf0106acc
f0100952:	e8 36 34 00 00       	call   f0103d8d <cprintf>
    }
    tf->tf_eflags &= (~FL_TF);
    env_run(curenv);    // usually it won't return;
    panic("mon_continue : env_run return");
    return 0;
}
f0100957:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010095c:	c9                   	leave  
f010095d:	c3                   	ret    
{
    if (tf == NULL) {
        cprintf("Error: you only can use continue in breakpoint.\n");
        return -1;
    }
    tf->tf_eflags &= (~FL_TF);
f010095e:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
    env_run(curenv);    // usually it won't return;
f0100965:	e8 46 54 00 00       	call   f0105db0 <cpunum>
f010096a:	83 ec 0c             	sub    $0xc,%esp
f010096d:	6b c0 74             	imul   $0x74,%eax,%eax
f0100970:	ff b0 28 00 2e f0    	pushl  -0xfd1ffd8(%eax)
f0100976:	e8 ae 31 00 00       	call   f0103b29 <env_run>

f010097b <mon_showmappings>:
    return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f010097b:	55                   	push   %ebp
f010097c:	89 e5                	mov    %esp,%ebp
f010097e:	57                   	push   %edi
f010097f:	56                   	push   %esi
f0100980:	53                   	push   %ebx
f0100981:	83 ec 0c             	sub    $0xc,%esp
f0100984:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 3) {
f0100987:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f010098b:	74 21                	je     f01009ae <mon_showmappings+0x33>
        cprintf("Command should be: showmappings [addr1] [addr2]\n");
f010098d:	83 ec 0c             	sub    $0xc,%esp
f0100990:	68 00 6b 10 f0       	push   $0xf0106b00
f0100995:	e8 f3 33 00 00       	call   f0103d8d <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f010099a:	c7 04 24 34 6b 10 f0 	movl   $0xf0106b34,(%esp)
f01009a1:	e8 e7 33 00 00       	call   f0103d8d <cprintf>
f01009a6:	83 c4 10             	add    $0x10,%esp
f01009a9:	e9 1a 01 00 00       	jmp    f0100ac8 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f01009ae:	83 ec 04             	sub    $0x4,%esp
f01009b1:	6a 00                	push   $0x0
f01009b3:	6a 00                	push   $0x0
f01009b5:	ff 76 04             	pushl  0x4(%esi)
f01009b8:	e8 fd 4e 00 00       	call   f01058ba <strtol>
f01009bd:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f01009bf:	83 c4 0c             	add    $0xc,%esp
f01009c2:	6a 00                	push   $0x0
f01009c4:	6a 00                	push   $0x0
f01009c6:	ff 76 08             	pushl  0x8(%esi)
f01009c9:	e8 ec 4e 00 00       	call   f01058ba <strtol>
        if (laddr > haddr) {
f01009ce:	83 c4 10             	add    $0x10,%esp
f01009d1:	39 c3                	cmp    %eax,%ebx
f01009d3:	76 01                	jbe    f01009d6 <mon_showmappings+0x5b>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f01009d5:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, PGSIZE);
f01009d6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        haddr = ROUNDUP(haddr, PGSIZE);
f01009dc:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01009e2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
f01009e8:	83 ec 04             	sub    $0x4,%esp
f01009eb:	57                   	push   %edi
f01009ec:	53                   	push   %ebx
f01009ed:	68 bc 67 10 f0       	push   $0xf01067bc
f01009f2:	e8 96 33 00 00       	call   f0103d8d <cprintf>
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f01009f7:	83 c4 10             	add    $0x10,%esp
f01009fa:	39 fb                	cmp    %edi,%ebx
f01009fc:	75 07                	jne    f0100a05 <mon_showmappings+0x8a>
f01009fe:	e9 c5 00 00 00       	jmp    f0100ac8 <mon_showmappings+0x14d>
f0100a03:	89 f3                	mov    %esi,%ebx
            cprintf("[ 0x%08x, 0x%08x ) -> ", now, now + PGSIZE); 
f0100a05:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
f0100a0b:	83 ec 04             	sub    $0x4,%esp
f0100a0e:	56                   	push   %esi
f0100a0f:	53                   	push   %ebx
f0100a10:	68 cd 67 10 f0       	push   $0xf01067cd
f0100a15:	e8 73 33 00 00       	call   f0103d8d <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f0100a1a:	83 c4 0c             	add    $0xc,%esp
f0100a1d:	6a 00                	push   $0x0
f0100a1f:	53                   	push   %ebx
f0100a20:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0100a26:	e8 a2 0c 00 00       	call   f01016cd <pgdir_walk>
f0100a2b:	89 c3                	mov    %eax,%ebx
            if (pte == 0 || (*pte & PTE_P) == 0) {
f0100a2d:	83 c4 10             	add    $0x10,%esp
f0100a30:	85 c0                	test   %eax,%eax
f0100a32:	74 06                	je     f0100a3a <mon_showmappings+0xbf>
f0100a34:	8b 00                	mov    (%eax),%eax
f0100a36:	a8 01                	test   $0x1,%al
f0100a38:	75 12                	jne    f0100a4c <mon_showmappings+0xd1>
                cprintf(" no mapped \n");
f0100a3a:	83 ec 0c             	sub    $0xc,%esp
f0100a3d:	68 e4 67 10 f0       	push   $0xf01067e4
f0100a42:	e8 46 33 00 00       	call   f0103d8d <cprintf>
f0100a47:	83 c4 10             	add    $0x10,%esp
f0100a4a:	eb 74                	jmp    f0100ac0 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f0100a4c:	83 ec 08             	sub    $0x8,%esp
f0100a4f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a54:	50                   	push   %eax
f0100a55:	68 f1 67 10 f0       	push   $0xf01067f1
f0100a5a:	e8 2e 33 00 00       	call   f0103d8d <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f0100a5f:	83 c4 10             	add    $0x10,%esp
f0100a62:	f6 03 04             	testb  $0x4,(%ebx)
f0100a65:	74 12                	je     f0100a79 <mon_showmappings+0xfe>
f0100a67:	83 ec 0c             	sub    $0xc,%esp
f0100a6a:	68 f9 67 10 f0       	push   $0xf01067f9
f0100a6f:	e8 19 33 00 00       	call   f0103d8d <cprintf>
f0100a74:	83 c4 10             	add    $0x10,%esp
f0100a77:	eb 10                	jmp    f0100a89 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f0100a79:	83 ec 0c             	sub    $0xc,%esp
f0100a7c:	68 06 68 10 f0       	push   $0xf0106806
f0100a81:	e8 07 33 00 00       	call   f0103d8d <cprintf>
f0100a86:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f0100a89:	f6 03 02             	testb  $0x2,(%ebx)
f0100a8c:	74 12                	je     f0100aa0 <mon_showmappings+0x125>
f0100a8e:	83 ec 0c             	sub    $0xc,%esp
f0100a91:	68 13 68 10 f0       	push   $0xf0106813
f0100a96:	e8 f2 32 00 00       	call   f0103d8d <cprintf>
f0100a9b:	83 c4 10             	add    $0x10,%esp
f0100a9e:	eb 10                	jmp    f0100ab0 <mon_showmappings+0x135>
                else cprintf(" R ");
f0100aa0:	83 ec 0c             	sub    $0xc,%esp
f0100aa3:	68 18 68 10 f0       	push   $0xf0106818
f0100aa8:	e8 e0 32 00 00       	call   f0103d8d <cprintf>
f0100aad:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f0100ab0:	83 ec 0c             	sub    $0xc,%esp
f0100ab3:	68 ef 67 10 f0       	push   $0xf01067ef
f0100ab8:	e8 d0 32 00 00       	call   f0103d8d <cprintf>
f0100abd:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDUP(haddr, PGSIZE);
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f0100ac0:	39 f7                	cmp    %esi,%edi
f0100ac2:	0f 85 3b ff ff ff    	jne    f0100a03 <mon_showmappings+0x88>
                cprintf("\n");
            }
        }
    }
    return 0;
}
f0100ac8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100acd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ad0:	5b                   	pop    %ebx
f0100ad1:	5e                   	pop    %esi
f0100ad2:	5f                   	pop    %edi
f0100ad3:	c9                   	leave  
f0100ad4:	c3                   	ret    

f0100ad5 <mon_setpermission>:
    return 0;
}

int
mon_setpermission(int argc, char **argv, struct Trapframe *tf)
{
f0100ad5:	55                   	push   %ebp
f0100ad6:	89 e5                	mov    %esp,%ebp
f0100ad8:	57                   	push   %edi
f0100ad9:	56                   	push   %esi
f0100ada:	53                   	push   %ebx
f0100adb:	83 ec 0c             	sub    $0xc,%esp
f0100ade:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 5) { 
f0100ae1:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f0100ae5:	74 21                	je     f0100b08 <mon_setpermission+0x33>
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
f0100ae7:	83 ec 0c             	sub    $0xc,%esp
f0100aea:	68 5c 6b 10 f0       	push   $0xf0106b5c
f0100aef:	e8 99 32 00 00       	call   f0103d8d <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f0100af4:	c7 04 24 ac 6b 10 f0 	movl   $0xf0106bac,(%esp)
f0100afb:	e8 8d 32 00 00       	call   f0103d8d <cprintf>
f0100b00:	83 c4 10             	add    $0x10,%esp
f0100b03:	e9 a5 01 00 00       	jmp    f0100cad <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f0100b08:	83 ec 04             	sub    $0x4,%esp
f0100b0b:	6a 00                	push   $0x0
f0100b0d:	6a 00                	push   $0x0
f0100b0f:	ff 73 04             	pushl  0x4(%ebx)
f0100b12:	e8 a3 4d 00 00       	call   f01058ba <strtol>
        uint32_t perm = 0;
        if (argv[2][0] == '1') perm |= PTE_W;
f0100b17:	8b 53 08             	mov    0x8(%ebx),%edx
f0100b1a:	83 c4 10             	add    $0x10,%esp
    if (argc != 5) { 
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
        cprintf("Example: setpermissions 0x0 1 0 1\n");
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
        uint32_t perm = 0;
f0100b1d:	80 3a 31             	cmpb   $0x31,(%edx)
f0100b20:	0f 94 c2             	sete   %dl
f0100b23:	0f b6 d2             	movzbl %dl,%edx
f0100b26:	89 d6                	mov    %edx,%esi
f0100b28:	d1 e6                	shl    %esi
        if (argv[2][0] == '1') perm |= PTE_W;
        if (argv[3][0] == '1') perm |= PTE_U;
f0100b2a:	8b 53 0c             	mov    0xc(%ebx),%edx
f0100b2d:	80 3a 31             	cmpb   $0x31,(%edx)
f0100b30:	75 03                	jne    f0100b35 <mon_setpermission+0x60>
f0100b32:	83 ce 04             	or     $0x4,%esi
        if (argv[4][0] == '1') perm |= PTE_P;
f0100b35:	8b 53 10             	mov    0x10(%ebx),%edx
f0100b38:	80 3a 31             	cmpb   $0x31,(%edx)
f0100b3b:	75 03                	jne    f0100b40 <mon_setpermission+0x6b>
f0100b3d:	83 ce 01             	or     $0x1,%esi
        addr = ROUNDUP(addr, PGSIZE);
f0100b40:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f0100b46:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
f0100b4c:	83 ec 04             	sub    $0x4,%esp
f0100b4f:	6a 00                	push   $0x0
f0100b51:	57                   	push   %edi
f0100b52:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0100b58:	e8 70 0b 00 00       	call   f01016cd <pgdir_walk>
f0100b5d:	89 c3                	mov    %eax,%ebx
        if (pte != NULL) {
f0100b5f:	83 c4 10             	add    $0x10,%esp
f0100b62:	85 c0                	test   %eax,%eax
f0100b64:	0f 84 33 01 00 00    	je     f0100c9d <mon_setpermission+0x1c8>
            cprintf("0x%08x -> pa: 0x%08x\n old_perm: ", addr, PTE_ADDR(*pte));
f0100b6a:	83 ec 04             	sub    $0x4,%esp
f0100b6d:	8b 00                	mov    (%eax),%eax
f0100b6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b74:	50                   	push   %eax
f0100b75:	57                   	push   %edi
f0100b76:	68 d0 6b 10 f0       	push   $0xf0106bd0
f0100b7b:	e8 0d 32 00 00       	call   f0103d8d <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100b80:	83 c4 10             	add    $0x10,%esp
f0100b83:	f6 03 02             	testb  $0x2,(%ebx)
f0100b86:	74 12                	je     f0100b9a <mon_setpermission+0xc5>
f0100b88:	83 ec 0c             	sub    $0xc,%esp
f0100b8b:	68 1c 68 10 f0       	push   $0xf010681c
f0100b90:	e8 f8 31 00 00       	call   f0103d8d <cprintf>
f0100b95:	83 c4 10             	add    $0x10,%esp
f0100b98:	eb 10                	jmp    f0100baa <mon_setpermission+0xd5>
f0100b9a:	83 ec 0c             	sub    $0xc,%esp
f0100b9d:	68 1f 68 10 f0       	push   $0xf010681f
f0100ba2:	e8 e6 31 00 00       	call   f0103d8d <cprintf>
f0100ba7:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100baa:	f6 03 04             	testb  $0x4,(%ebx)
f0100bad:	74 12                	je     f0100bc1 <mon_setpermission+0xec>
f0100baf:	83 ec 0c             	sub    $0xc,%esp
f0100bb2:	68 63 7a 10 f0       	push   $0xf0107a63
f0100bb7:	e8 d1 31 00 00       	call   f0103d8d <cprintf>
f0100bbc:	83 c4 10             	add    $0x10,%esp
f0100bbf:	eb 10                	jmp    f0100bd1 <mon_setpermission+0xfc>
f0100bc1:	83 ec 0c             	sub    $0xc,%esp
f0100bc4:	68 a7 7e 10 f0       	push   $0xf0107ea7
f0100bc9:	e8 bf 31 00 00       	call   f0103d8d <cprintf>
f0100bce:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100bd1:	f6 03 01             	testb  $0x1,(%ebx)
f0100bd4:	74 12                	je     f0100be8 <mon_setpermission+0x113>
f0100bd6:	83 ec 0c             	sub    $0xc,%esp
f0100bd9:	68 b9 84 10 f0       	push   $0xf01084b9
f0100bde:	e8 aa 31 00 00       	call   f0103d8d <cprintf>
f0100be3:	83 c4 10             	add    $0x10,%esp
f0100be6:	eb 10                	jmp    f0100bf8 <mon_setpermission+0x123>
f0100be8:	83 ec 0c             	sub    $0xc,%esp
f0100beb:	68 20 68 10 f0       	push   $0xf0106820
f0100bf0:	e8 98 31 00 00       	call   f0103d8d <cprintf>
f0100bf5:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f0100bf8:	83 ec 0c             	sub    $0xc,%esp
f0100bfb:	68 22 68 10 f0       	push   $0xf0106822
f0100c00:	e8 88 31 00 00       	call   f0103d8d <cprintf>
            *pte = PTE_ADDR(*pte) | perm;     
f0100c05:	8b 03                	mov    (%ebx),%eax
f0100c07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c0c:	09 c6                	or     %eax,%esi
f0100c0e:	89 33                	mov    %esi,(%ebx)
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100c10:	83 c4 10             	add    $0x10,%esp
f0100c13:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0100c19:	74 12                	je     f0100c2d <mon_setpermission+0x158>
f0100c1b:	83 ec 0c             	sub    $0xc,%esp
f0100c1e:	68 1c 68 10 f0       	push   $0xf010681c
f0100c23:	e8 65 31 00 00       	call   f0103d8d <cprintf>
f0100c28:	83 c4 10             	add    $0x10,%esp
f0100c2b:	eb 10                	jmp    f0100c3d <mon_setpermission+0x168>
f0100c2d:	83 ec 0c             	sub    $0xc,%esp
f0100c30:	68 1f 68 10 f0       	push   $0xf010681f
f0100c35:	e8 53 31 00 00       	call   f0103d8d <cprintf>
f0100c3a:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100c3d:	f6 03 04             	testb  $0x4,(%ebx)
f0100c40:	74 12                	je     f0100c54 <mon_setpermission+0x17f>
f0100c42:	83 ec 0c             	sub    $0xc,%esp
f0100c45:	68 63 7a 10 f0       	push   $0xf0107a63
f0100c4a:	e8 3e 31 00 00       	call   f0103d8d <cprintf>
f0100c4f:	83 c4 10             	add    $0x10,%esp
f0100c52:	eb 10                	jmp    f0100c64 <mon_setpermission+0x18f>
f0100c54:	83 ec 0c             	sub    $0xc,%esp
f0100c57:	68 a7 7e 10 f0       	push   $0xf0107ea7
f0100c5c:	e8 2c 31 00 00       	call   f0103d8d <cprintf>
f0100c61:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100c64:	f6 03 01             	testb  $0x1,(%ebx)
f0100c67:	74 12                	je     f0100c7b <mon_setpermission+0x1a6>
f0100c69:	83 ec 0c             	sub    $0xc,%esp
f0100c6c:	68 b9 84 10 f0       	push   $0xf01084b9
f0100c71:	e8 17 31 00 00       	call   f0103d8d <cprintf>
f0100c76:	83 c4 10             	add    $0x10,%esp
f0100c79:	eb 10                	jmp    f0100c8b <mon_setpermission+0x1b6>
f0100c7b:	83 ec 0c             	sub    $0xc,%esp
f0100c7e:	68 20 68 10 f0       	push   $0xf0106820
f0100c83:	e8 05 31 00 00       	call   f0103d8d <cprintf>
f0100c88:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100c8b:	83 ec 0c             	sub    $0xc,%esp
f0100c8e:	68 ef 67 10 f0       	push   $0xf01067ef
f0100c93:	e8 f5 30 00 00       	call   f0103d8d <cprintf>
f0100c98:	83 c4 10             	add    $0x10,%esp
f0100c9b:	eb 10                	jmp    f0100cad <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100c9d:	83 ec 0c             	sub    $0xc,%esp
f0100ca0:	68 e4 67 10 f0       	push   $0xf01067e4
f0100ca5:	e8 e3 30 00 00       	call   f0103d8d <cprintf>
f0100caa:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100cad:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cb5:	5b                   	pop    %ebx
f0100cb6:	5e                   	pop    %esi
f0100cb7:	5f                   	pop    %edi
f0100cb8:	c9                   	leave  
f0100cb9:	c3                   	ret    

f0100cba <mon_setcolor>:
    return 0;
}

int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f0100cba:	55                   	push   %ebp
f0100cbb:	89 e5                	mov    %esp,%ebp
f0100cbd:	56                   	push   %esi
f0100cbe:	53                   	push   %ebx
f0100cbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f0100cc2:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100cc6:	74 66                	je     f0100d2e <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f0100cc8:	83 ec 0c             	sub    $0xc,%esp
f0100ccb:	68 f4 6b 10 f0       	push   $0xf0106bf4
f0100cd0:	e8 b8 30 00 00       	call   f0103d8d <cprintf>
        cprintf("num show the color attribute. \n");
f0100cd5:	c7 04 24 24 6c 10 f0 	movl   $0xf0106c24,(%esp)
f0100cdc:	e8 ac 30 00 00       	call   f0103d8d <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100ce1:	c7 04 24 44 6c 10 f0 	movl   $0xf0106c44,(%esp)
f0100ce8:	e8 a0 30 00 00       	call   f0103d8d <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100ced:	c7 04 24 78 6c 10 f0 	movl   $0xf0106c78,(%esp)
f0100cf4:	e8 94 30 00 00       	call   f0103d8d <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100cf9:	c7 04 24 bc 6c 10 f0 	movl   $0xf0106cbc,(%esp)
f0100d00:	e8 88 30 00 00       	call   f0103d8d <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100d05:	c7 04 24 33 68 10 f0 	movl   $0xf0106833,(%esp)
f0100d0c:	e8 7c 30 00 00       	call   f0103d8d <cprintf>
        cprintf("         set the background color to black\n");
f0100d11:	c7 04 24 00 6d 10 f0 	movl   $0xf0106d00,(%esp)
f0100d18:	e8 70 30 00 00       	call   f0103d8d <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100d1d:	c7 04 24 2c 6d 10 f0 	movl   $0xf0106d2c,(%esp)
f0100d24:	e8 64 30 00 00       	call   f0103d8d <cprintf>
f0100d29:	83 c4 10             	add    $0x10,%esp
f0100d2c:	eb 52                	jmp    f0100d80 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100d2e:	83 ec 0c             	sub    $0xc,%esp
f0100d31:	ff 73 04             	pushl  0x4(%ebx)
f0100d34:	e8 7f 48 00 00       	call   f01055b8 <strlen>
f0100d39:	83 c4 10             	add    $0x10,%esp
f0100d3c:	48                   	dec    %eax
f0100d3d:	78 26                	js     f0100d65 <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f0100d3f:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100d42:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100d47:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f0100d4c:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f0100d50:	0f 94 c3             	sete   %bl
f0100d53:	0f b6 db             	movzbl %bl,%ebx
f0100d56:	d3 e3                	shl    %cl,%ebx
f0100d58:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100d5a:	48                   	dec    %eax
f0100d5b:	78 0d                	js     f0100d6a <mon_setcolor+0xb0>
f0100d5d:	41                   	inc    %ecx
f0100d5e:	83 f9 08             	cmp    $0x8,%ecx
f0100d61:	75 e9                	jne    f0100d4c <mon_setcolor+0x92>
f0100d63:	eb 05                	jmp    f0100d6a <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100d65:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f0100d6a:	89 15 00 f0 2d f0    	mov    %edx,0xf02df000
        cprintf(" This is color that you want ! \n");
f0100d70:	83 ec 0c             	sub    $0xc,%esp
f0100d73:	68 60 6d 10 f0       	push   $0xf0106d60
f0100d78:	e8 10 30 00 00       	call   f0103d8d <cprintf>
f0100d7d:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f0100d80:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d85:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100d88:	5b                   	pop    %ebx
f0100d89:	5e                   	pop    %esi
f0100d8a:	c9                   	leave  
f0100d8b:	c3                   	ret    

f0100d8c <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f0100d8c:	55                   	push   %ebp
f0100d8d:	89 e5                	mov    %esp,%ebp
f0100d8f:	57                   	push   %edi
f0100d90:	56                   	push   %esi
f0100d91:	53                   	push   %ebx
f0100d92:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100d95:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100d97:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100d99:	85 c0                	test   %eax,%eax
f0100d9b:	74 6d                	je     f0100e0a <mon_backtrace+0x7e>
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100d9d:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
f0100da0:	8b 5e 04             	mov    0x4(%esi),%ebx
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100da3:	ff 76 18             	pushl  0x18(%esi)
f0100da6:	ff 76 14             	pushl  0x14(%esi)
f0100da9:	ff 76 10             	pushl  0x10(%esi)
f0100dac:	ff 76 0c             	pushl  0xc(%esi)
f0100daf:	ff 76 08             	pushl  0x8(%esi)
f0100db2:	53                   	push   %ebx
f0100db3:	56                   	push   %esi
f0100db4:	68 84 6d 10 f0       	push   $0xf0106d84
f0100db9:	e8 cf 2f 00 00       	call   f0103d8d <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100dbe:	83 c4 18             	add    $0x18,%esp
f0100dc1:	57                   	push   %edi
f0100dc2:	ff 76 04             	pushl  0x4(%esi)
f0100dc5:	e8 0f 3f 00 00       	call   f0104cd9 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100dca:	83 c4 0c             	add    $0xc,%esp
f0100dcd:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100dd0:	ff 75 d0             	pushl  -0x30(%ebp)
f0100dd3:	68 4f 68 10 f0       	push   $0xf010684f
f0100dd8:	e8 b0 2f 00 00       	call   f0103d8d <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100ddd:	83 c4 0c             	add    $0xc,%esp
f0100de0:	ff 75 d8             	pushl  -0x28(%ebp)
f0100de3:	ff 75 dc             	pushl  -0x24(%ebp)
f0100de6:	68 5f 68 10 f0       	push   $0xf010685f
f0100deb:	e8 9d 2f 00 00       	call   f0103d8d <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100df0:	83 c4 08             	add    $0x8,%esp
f0100df3:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100df6:	53                   	push   %ebx
f0100df7:	68 64 68 10 f0       	push   $0xf0106864
f0100dfc:	e8 8c 2f 00 00       	call   f0103d8d <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100e01:	8b 36                	mov    (%esi),%esi
f0100e03:	83 c4 10             	add    $0x10,%esp
f0100e06:	85 f6                	test   %esi,%esi
f0100e08:	75 96                	jne    f0100da0 <mon_backtrace+0x14>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100e0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e12:	5b                   	pop    %ebx
f0100e13:	5e                   	pop    %esi
f0100e14:	5f                   	pop    %edi
f0100e15:	c9                   	leave  
f0100e16:	c3                   	ret    

f0100e17 <pa_con>:
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
f0100e17:	55                   	push   %ebp
f0100e18:	89 e5                	mov    %esp,%ebp
f0100e1a:	53                   	push   %ebx
f0100e1b:	83 ec 04             	sub    $0x4,%esp
f0100e1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
f0100e24:	8b 15 90 fe 2d f0    	mov    0xf02dfe90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e2a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100e30:	77 15                	ja     f0100e47 <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e32:	52                   	push   %edx
f0100e33:	68 a4 64 10 f0       	push   $0xf01064a4
f0100e38:	68 96 00 00 00       	push   $0x96
f0100e3d:	68 69 68 10 f0       	push   $0xf0106869
f0100e42:	e8 21 f2 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100e47:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100e4d:	39 d0                	cmp    %edx,%eax
f0100e4f:	72 18                	jb     f0100e69 <pa_con+0x52>
f0100e51:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
f0100e57:	39 d8                	cmp    %ebx,%eax
f0100e59:	73 0e                	jae    f0100e69 <pa_con+0x52>
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
f0100e5b:	29 d0                	sub    %edx,%eax
f0100e5d:	8b 80 00 00 00 ef    	mov    -0x11000000(%eax),%eax
f0100e63:	89 01                	mov    %eax,(%ecx)
        return true;
f0100e65:	b0 01                	mov    $0x1,%al
f0100e67:	eb 56                	jmp    f0100ebf <pa_con+0xa8>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e69:	ba 00 e0 11 f0       	mov    $0xf011e000,%edx
f0100e6e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100e74:	77 15                	ja     f0100e8b <pa_con+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e76:	52                   	push   %edx
f0100e77:	68 a4 64 10 f0       	push   $0xf01064a4
f0100e7c:	68 9b 00 00 00       	push   $0x9b
f0100e81:	68 69 68 10 f0       	push   $0xf0106869
f0100e86:	e8 dd f1 ff ff       	call   f0100068 <_panic>
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
f0100e8b:	3d 00 e0 11 00       	cmp    $0x11e000,%eax
f0100e90:	72 18                	jb     f0100eaa <pa_con+0x93>
f0100e92:	3d 00 60 12 00       	cmp    $0x126000,%eax
f0100e97:	73 11                	jae    f0100eaa <pa_con+0x93>
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
f0100e99:	2d 00 e0 11 00       	sub    $0x11e000,%eax
f0100e9e:	8b 80 00 80 ff ef    	mov    -0x10008000(%eax),%eax
f0100ea4:	89 01                	mov    %eax,(%ecx)
        return true;
f0100ea6:	b0 01                	mov    $0x1,%al
f0100ea8:	eb 15                	jmp    f0100ebf <pa_con+0xa8>
    }
    if (addr < -KERNBASE) {
f0100eaa:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100eaf:	77 0c                	ja     f0100ebd <pa_con+0xa6>
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
f0100eb1:	8b 80 00 00 00 f0    	mov    -0x10000000(%eax),%eax
f0100eb7:	89 01                	mov    %eax,(%ecx)
        return true;
f0100eb9:	b0 01                	mov    $0x1,%al
f0100ebb:	eb 02                	jmp    f0100ebf <pa_con+0xa8>
    }
    // Not in virtual memory mapped.
    return false;
f0100ebd:	b0 00                	mov    $0x0,%al
}
f0100ebf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ec2:	c9                   	leave  
f0100ec3:	c3                   	ret    

f0100ec4 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
f0100ec4:	55                   	push   %ebp
f0100ec5:	89 e5                	mov    %esp,%ebp
f0100ec7:	57                   	push   %edi
f0100ec8:	56                   	push   %esi
f0100ec9:	53                   	push   %ebx
f0100eca:	83 ec 2c             	sub    $0x2c,%esp
f0100ecd:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 4) {
f0100ed0:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100ed4:	74 2d                	je     f0100f03 <mon_dump+0x3f>
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
f0100ed6:	83 ec 0c             	sub    $0xc,%esp
f0100ed9:	68 bc 6d 10 f0       	push   $0xf0106dbc
f0100ede:	e8 aa 2e 00 00       	call   f0103d8d <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100ee3:	c7 04 24 ec 6d 10 f0 	movl   $0xf0106dec,(%esp)
f0100eea:	e8 9e 2e 00 00       	call   f0103d8d <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100eef:	c7 04 24 14 6e 10 f0 	movl   $0xf0106e14,(%esp)
f0100ef6:	e8 92 2e 00 00       	call   f0103d8d <cprintf>
f0100efb:	83 c4 10             	add    $0x10,%esp
f0100efe:	e9 59 01 00 00       	jmp    f010105c <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100f03:	83 ec 04             	sub    $0x4,%esp
f0100f06:	6a 00                	push   $0x0
f0100f08:	6a 00                	push   $0x0
f0100f0a:	ff 76 08             	pushl  0x8(%esi)
f0100f0d:	e8 a8 49 00 00       	call   f01058ba <strtol>
f0100f12:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100f14:	83 c4 0c             	add    $0xc,%esp
f0100f17:	6a 00                	push   $0x0
f0100f19:	6a 00                	push   $0x0
f0100f1b:	ff 76 0c             	pushl  0xc(%esi)
f0100f1e:	e8 97 49 00 00       	call   f01058ba <strtol>
        if (laddr > haddr) {
f0100f23:	83 c4 10             	add    $0x10,%esp
f0100f26:	39 c3                	cmp    %eax,%ebx
f0100f28:	76 01                	jbe    f0100f2b <mon_dump+0x67>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100f2a:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, 4);
f0100f2b:	89 df                	mov    %ebx,%edi
f0100f2d:	83 e7 fc             	and    $0xfffffffc,%edi
        haddr = ROUNDDOWN(haddr, 4);
f0100f30:	83 e0 fc             	and    $0xfffffffc,%eax
f0100f33:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if (argv[1][0] == 'v') {
f0100f36:	8b 46 04             	mov    0x4(%esi),%eax
f0100f39:	80 38 76             	cmpb   $0x76,(%eax)
f0100f3c:	74 0e                	je     f0100f4c <mon_dump+0x88>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100f3e:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100f41:	0f 85 98 00 00 00    	jne    f0100fdf <mon_dump+0x11b>
f0100f47:	e9 00 01 00 00       	jmp    f010104c <mon_dump+0x188>
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100f4c:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100f4f:	74 7c                	je     f0100fcd <mon_dump+0x109>
f0100f51:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100f53:	39 fb                	cmp    %edi,%ebx
f0100f55:	74 15                	je     f0100f6c <mon_dump+0xa8>
f0100f57:	f6 c3 0f             	test   $0xf,%bl
f0100f5a:	75 21                	jne    f0100f7d <mon_dump+0xb9>
                    if (now != laddr) cprintf("\n"); 
f0100f5c:	83 ec 0c             	sub    $0xc,%esp
f0100f5f:	68 ef 67 10 f0       	push   $0xf01067ef
f0100f64:	e8 24 2e 00 00       	call   f0103d8d <cprintf>
f0100f69:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100f6c:	83 ec 08             	sub    $0x8,%esp
f0100f6f:	53                   	push   %ebx
f0100f70:	68 78 68 10 f0       	push   $0xf0106878
f0100f75:	e8 13 2e 00 00       	call   f0103d8d <cprintf>
f0100f7a:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100f7d:	83 ec 04             	sub    $0x4,%esp
f0100f80:	6a 00                	push   $0x0
f0100f82:	89 d8                	mov    %ebx,%eax
f0100f84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f89:	50                   	push   %eax
f0100f8a:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0100f90:	e8 38 07 00 00       	call   f01016cd <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100f95:	83 c4 10             	add    $0x10,%esp
f0100f98:	85 c0                	test   %eax,%eax
f0100f9a:	74 19                	je     f0100fb5 <mon_dump+0xf1>
f0100f9c:	f6 00 01             	testb  $0x1,(%eax)
f0100f9f:	74 14                	je     f0100fb5 <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100fa1:	83 ec 08             	sub    $0x8,%esp
f0100fa4:	ff 33                	pushl  (%ebx)
f0100fa6:	68 82 68 10 f0       	push   $0xf0106882
f0100fab:	e8 dd 2d 00 00       	call   f0103d8d <cprintf>
f0100fb0:	83 c4 10             	add    $0x10,%esp
f0100fb3:	eb 10                	jmp    f0100fc5 <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100fb5:	83 ec 0c             	sub    $0xc,%esp
f0100fb8:	68 8d 68 10 f0       	push   $0xf010688d
f0100fbd:	e8 cb 2d 00 00       	call   f0103d8d <cprintf>
f0100fc2:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100fc5:	83 c3 04             	add    $0x4,%ebx
f0100fc8:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100fcb:	75 86                	jne    f0100f53 <mon_dump+0x8f>
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
f0100fcd:	83 ec 0c             	sub    $0xc,%esp
f0100fd0:	68 ef 67 10 f0       	push   $0xf01067ef
f0100fd5:	e8 b3 2d 00 00       	call   f0103d8d <cprintf>
f0100fda:	83 c4 10             	add    $0x10,%esp
f0100fdd:	eb 7d                	jmp    f010105c <mon_dump+0x198>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100fdf:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100fe1:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100fe4:	39 fb                	cmp    %edi,%ebx
f0100fe6:	74 15                	je     f0100ffd <mon_dump+0x139>
f0100fe8:	f6 c3 0f             	test   $0xf,%bl
f0100feb:	75 21                	jne    f010100e <mon_dump+0x14a>
                    if (now != laddr) cprintf("\n");
f0100fed:	83 ec 0c             	sub    $0xc,%esp
f0100ff0:	68 ef 67 10 f0       	push   $0xf01067ef
f0100ff5:	e8 93 2d 00 00       	call   f0103d8d <cprintf>
f0100ffa:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100ffd:	83 ec 08             	sub    $0x8,%esp
f0101000:	53                   	push   %ebx
f0101001:	68 78 68 10 f0       	push   $0xf0106878
f0101006:	e8 82 2d 00 00       	call   f0103d8d <cprintf>
f010100b:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f010100e:	83 ec 08             	sub    $0x8,%esp
f0101011:	56                   	push   %esi
f0101012:	53                   	push   %ebx
f0101013:	e8 ff fd ff ff       	call   f0100e17 <pa_con>
f0101018:	83 c4 10             	add    $0x10,%esp
f010101b:	84 c0                	test   %al,%al
f010101d:	74 15                	je     f0101034 <mon_dump+0x170>
                    cprintf("0x%08x  ", value);
f010101f:	83 ec 08             	sub    $0x8,%esp
f0101022:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101025:	68 82 68 10 f0       	push   $0xf0106882
f010102a:	e8 5e 2d 00 00       	call   f0103d8d <cprintf>
f010102f:	83 c4 10             	add    $0x10,%esp
f0101032:	eb 10                	jmp    f0101044 <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0101034:	83 ec 0c             	sub    $0xc,%esp
f0101037:	68 8b 68 10 f0       	push   $0xf010688b
f010103c:	e8 4c 2d 00 00       	call   f0103d8d <cprintf>
f0101041:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0101044:	83 c3 04             	add    $0x4,%ebx
f0101047:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010104a:	75 98                	jne    f0100fe4 <mon_dump+0x120>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f010104c:	83 ec 0c             	sub    $0xc,%esp
f010104f:	68 ef 67 10 f0       	push   $0xf01067ef
f0101054:	e8 34 2d 00 00       	call   f0103d8d <cprintf>
f0101059:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f010105c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101061:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101064:	5b                   	pop    %ebx
f0101065:	5e                   	pop    %esi
f0101066:	5f                   	pop    %edi
f0101067:	c9                   	leave  
f0101068:	c3                   	ret    

f0101069 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0101069:	55                   	push   %ebp
f010106a:	89 e5                	mov    %esp,%ebp
f010106c:	57                   	push   %edi
f010106d:	56                   	push   %esi
f010106e:	53                   	push   %ebx
f010106f:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0101072:	68 58 6e 10 f0       	push   $0xf0106e58
f0101077:	e8 11 2d 00 00       	call   f0103d8d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010107c:	c7 04 24 7c 6e 10 f0 	movl   $0xf0106e7c,(%esp)
f0101083:	e8 05 2d 00 00       	call   f0103d8d <cprintf>

	if (tf != NULL)
f0101088:	83 c4 10             	add    $0x10,%esp
f010108b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010108f:	74 0e                	je     f010109f <monitor+0x36>
		print_trapframe(tf);
f0101091:	83 ec 0c             	sub    $0xc,%esp
f0101094:	ff 75 08             	pushl  0x8(%ebp)
f0101097:	e8 4f 2f 00 00       	call   f0103feb <print_trapframe>
f010109c:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010109f:	83 ec 0c             	sub    $0xc,%esp
f01010a2:	68 98 68 10 f0       	push   $0xf0106898
f01010a7:	e8 3c 44 00 00       	call   f01054e8 <readline>
f01010ac:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01010ae:	83 c4 10             	add    $0x10,%esp
f01010b1:	85 c0                	test   %eax,%eax
f01010b3:	74 ea                	je     f010109f <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01010b5:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01010bc:	be 00 00 00 00       	mov    $0x0,%esi
f01010c1:	eb 04                	jmp    f01010c7 <monitor+0x5e>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01010c3:	c6 03 00             	movb   $0x0,(%ebx)
f01010c6:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01010c7:	8a 03                	mov    (%ebx),%al
f01010c9:	84 c0                	test   %al,%al
f01010cb:	74 64                	je     f0101131 <monitor+0xc8>
f01010cd:	83 ec 08             	sub    $0x8,%esp
f01010d0:	0f be c0             	movsbl %al,%eax
f01010d3:	50                   	push   %eax
f01010d4:	68 9c 68 10 f0       	push   $0xf010689c
f01010d9:	e8 53 46 00 00       	call   f0105731 <strchr>
f01010de:	83 c4 10             	add    $0x10,%esp
f01010e1:	85 c0                	test   %eax,%eax
f01010e3:	75 de                	jne    f01010c3 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01010e5:	80 3b 00             	cmpb   $0x0,(%ebx)
f01010e8:	74 47                	je     f0101131 <monitor+0xc8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01010ea:	83 fe 0f             	cmp    $0xf,%esi
f01010ed:	75 14                	jne    f0101103 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01010ef:	83 ec 08             	sub    $0x8,%esp
f01010f2:	6a 10                	push   $0x10
f01010f4:	68 a1 68 10 f0       	push   $0xf01068a1
f01010f9:	e8 8f 2c 00 00       	call   f0103d8d <cprintf>
f01010fe:	83 c4 10             	add    $0x10,%esp
f0101101:	eb 9c                	jmp    f010109f <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0101103:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0101107:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0101108:	8a 03                	mov    (%ebx),%al
f010110a:	84 c0                	test   %al,%al
f010110c:	75 09                	jne    f0101117 <monitor+0xae>
f010110e:	eb b7                	jmp    f01010c7 <monitor+0x5e>
			buf++;
f0101110:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0101111:	8a 03                	mov    (%ebx),%al
f0101113:	84 c0                	test   %al,%al
f0101115:	74 b0                	je     f01010c7 <monitor+0x5e>
f0101117:	83 ec 08             	sub    $0x8,%esp
f010111a:	0f be c0             	movsbl %al,%eax
f010111d:	50                   	push   %eax
f010111e:	68 9c 68 10 f0       	push   $0xf010689c
f0101123:	e8 09 46 00 00       	call   f0105731 <strchr>
f0101128:	83 c4 10             	add    $0x10,%esp
f010112b:	85 c0                	test   %eax,%eax
f010112d:	74 e1                	je     f0101110 <monitor+0xa7>
f010112f:	eb 96                	jmp    f01010c7 <monitor+0x5e>
			buf++;
	}
	argv[argc] = 0;
f0101131:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0101138:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0101139:	85 f6                	test   %esi,%esi
f010113b:	0f 84 5e ff ff ff    	je     f010109f <monitor+0x36>
f0101141:	bb 00 6f 10 f0       	mov    $0xf0106f00,%ebx
f0101146:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010114b:	83 ec 08             	sub    $0x8,%esp
f010114e:	ff 33                	pushl  (%ebx)
f0101150:	ff 75 a8             	pushl  -0x58(%ebp)
f0101153:	e8 6b 45 00 00       	call   f01056c3 <strcmp>
f0101158:	83 c4 10             	add    $0x10,%esp
f010115b:	85 c0                	test   %eax,%eax
f010115d:	75 20                	jne    f010117f <monitor+0x116>
			return commands[i].func(argc, argv, tf);
f010115f:	83 ec 04             	sub    $0x4,%esp
f0101162:	6b ff 0c             	imul   $0xc,%edi,%edi
f0101165:	ff 75 08             	pushl  0x8(%ebp)
f0101168:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010116b:	50                   	push   %eax
f010116c:	56                   	push   %esi
f010116d:	ff 97 08 6f 10 f0    	call   *-0xfef90f8(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0101173:	83 c4 10             	add    $0x10,%esp
f0101176:	85 c0                	test   %eax,%eax
f0101178:	78 26                	js     f01011a0 <monitor+0x137>
f010117a:	e9 20 ff ff ff       	jmp    f010109f <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010117f:	47                   	inc    %edi
f0101180:	83 c3 0c             	add    $0xc,%ebx
f0101183:	83 ff 09             	cmp    $0x9,%edi
f0101186:	75 c3                	jne    f010114b <monitor+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0101188:	83 ec 08             	sub    $0x8,%esp
f010118b:	ff 75 a8             	pushl  -0x58(%ebp)
f010118e:	68 be 68 10 f0       	push   $0xf01068be
f0101193:	e8 f5 2b 00 00       	call   f0103d8d <cprintf>
f0101198:	83 c4 10             	add    $0x10,%esp
f010119b:	e9 ff fe ff ff       	jmp    f010109f <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01011a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011a3:	5b                   	pop    %ebx
f01011a4:	5e                   	pop    %esi
f01011a5:	5f                   	pop    %edi
f01011a6:	c9                   	leave  
f01011a7:	c3                   	ret    

f01011a8 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01011a8:	55                   	push   %ebp
f01011a9:	89 e5                	mov    %esp,%ebp
f01011ab:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01011ad:	83 3d 34 f2 2d f0 00 	cmpl   $0x0,0xf02df234
f01011b4:	75 0f                	jne    f01011c5 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01011b6:	b8 07 20 32 f0       	mov    $0xf0322007,%eax
f01011bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011c0:	a3 34 f2 2d f0       	mov    %eax,0xf02df234
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f01011c5:	a1 34 f2 2d f0       	mov    0xf02df234,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f01011ca:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f01011d1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01011d7:	89 15 34 f2 2d f0    	mov    %edx,0xf02df234

	return result;
}
f01011dd:	c9                   	leave  
f01011de:	c3                   	ret    

f01011df <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01011df:	55                   	push   %ebp
f01011e0:	89 e5                	mov    %esp,%ebp
f01011e2:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01011e5:	89 d1                	mov    %edx,%ecx
f01011e7:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01011ea:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01011ed:	a8 01                	test   $0x1,%al
f01011ef:	74 42                	je     f0101233 <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01011f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011f6:	89 c1                	mov    %eax,%ecx
f01011f8:	c1 e9 0c             	shr    $0xc,%ecx
f01011fb:	3b 0d 88 fe 2d f0    	cmp    0xf02dfe88,%ecx
f0101201:	72 15                	jb     f0101218 <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101203:	50                   	push   %eax
f0101204:	68 c8 64 10 f0       	push   $0xf01064c8
f0101209:	68 79 03 00 00       	push   $0x379
f010120e:	68 31 78 10 f0       	push   $0xf0107831
f0101213:	e8 50 ee ff ff       	call   f0100068 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101218:	c1 ea 0c             	shr    $0xc,%edx
f010121b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101221:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101228:	a8 01                	test   $0x1,%al
f010122a:	74 0e                	je     f010123a <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f010122c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101231:	eb 0c                	jmp    f010123f <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0101233:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101238:	eb 05                	jmp    f010123f <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f010123a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f010123f:	c9                   	leave  
f0101240:	c3                   	ret    

f0101241 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0101241:	55                   	push   %ebp
f0101242:	89 e5                	mov    %esp,%ebp
f0101244:	56                   	push   %esi
f0101245:	53                   	push   %ebx
f0101246:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101248:	83 ec 0c             	sub    $0xc,%esp
f010124b:	50                   	push   %eax
f010124c:	e8 fb 29 00 00       	call   f0103c4c <mc146818_read>
f0101251:	89 c6                	mov    %eax,%esi
f0101253:	43                   	inc    %ebx
f0101254:	89 1c 24             	mov    %ebx,(%esp)
f0101257:	e8 f0 29 00 00       	call   f0103c4c <mc146818_read>
f010125c:	c1 e0 08             	shl    $0x8,%eax
f010125f:	09 f0                	or     %esi,%eax
}
f0101261:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101264:	5b                   	pop    %ebx
f0101265:	5e                   	pop    %esi
f0101266:	c9                   	leave  
f0101267:	c3                   	ret    

f0101268 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101268:	55                   	push   %ebp
f0101269:	89 e5                	mov    %esp,%ebp
f010126b:	57                   	push   %edi
f010126c:	56                   	push   %esi
f010126d:	53                   	push   %ebx
f010126e:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101271:	3c 01                	cmp    $0x1,%al
f0101273:	19 f6                	sbb    %esi,%esi
f0101275:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f010127b:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f010127c:	8b 1d 30 f2 2d f0    	mov    0xf02df230,%ebx
f0101282:	85 db                	test   %ebx,%ebx
f0101284:	75 17                	jne    f010129d <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f0101286:	83 ec 04             	sub    $0x4,%esp
f0101289:	68 6c 6f 10 f0       	push   $0xf0106f6c
f010128e:	68 ae 02 00 00       	push   $0x2ae
f0101293:	68 31 78 10 f0       	push   $0xf0107831
f0101298:	e8 cb ed ff ff       	call   f0100068 <_panic>

	if (only_low_memory) {
f010129d:	84 c0                	test   %al,%al
f010129f:	74 50                	je     f01012f1 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01012a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01012a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012a7:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01012aa:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012ad:	89 d8                	mov    %ebx,%eax
f01012af:	2b 05 90 fe 2d f0    	sub    0xf02dfe90,%eax
f01012b5:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01012b8:	c1 e8 16             	shr    $0x16,%eax
f01012bb:	39 c6                	cmp    %eax,%esi
f01012bd:	0f 96 c0             	setbe  %al
f01012c0:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f01012c3:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f01012c7:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f01012c9:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012cd:	8b 1b                	mov    (%ebx),%ebx
f01012cf:	85 db                	test   %ebx,%ebx
f01012d1:	75 da                	jne    f01012ad <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01012d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01012d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01012dc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01012df:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01012e2:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01012e4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01012e7:	89 1d 30 f2 2d f0    	mov    %ebx,0xf02df230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01012ed:	85 db                	test   %ebx,%ebx
f01012ef:	74 57                	je     f0101348 <check_page_free_list+0xe0>
f01012f1:	89 d8                	mov    %ebx,%eax
f01012f3:	2b 05 90 fe 2d f0    	sub    0xf02dfe90,%eax
f01012f9:	c1 f8 03             	sar    $0x3,%eax
f01012fc:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01012ff:	89 c2                	mov    %eax,%edx
f0101301:	c1 ea 16             	shr    $0x16,%edx
f0101304:	39 d6                	cmp    %edx,%esi
f0101306:	76 3a                	jbe    f0101342 <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101308:	89 c2                	mov    %eax,%edx
f010130a:	c1 ea 0c             	shr    $0xc,%edx
f010130d:	3b 15 88 fe 2d f0    	cmp    0xf02dfe88,%edx
f0101313:	72 12                	jb     f0101327 <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101315:	50                   	push   %eax
f0101316:	68 c8 64 10 f0       	push   $0xf01064c8
f010131b:	6a 58                	push   $0x58
f010131d:	68 3d 78 10 f0       	push   $0xf010783d
f0101322:	e8 41 ed ff ff       	call   f0100068 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101327:	83 ec 04             	sub    $0x4,%esp
f010132a:	68 80 00 00 00       	push   $0x80
f010132f:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101334:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101339:	50                   	push   %eax
f010133a:	e8 42 44 00 00       	call   f0105781 <memset>
f010133f:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101342:	8b 1b                	mov    (%ebx),%ebx
f0101344:	85 db                	test   %ebx,%ebx
f0101346:	75 a9                	jne    f01012f1 <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101348:	b8 00 00 00 00       	mov    $0x0,%eax
f010134d:	e8 56 fe ff ff       	call   f01011a8 <boot_alloc>
f0101352:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101355:	8b 15 30 f2 2d f0    	mov    0xf02df230,%edx
f010135b:	85 d2                	test   %edx,%edx
f010135d:	0f 84 b2 01 00 00    	je     f0101515 <check_page_free_list+0x2ad>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101363:	8b 1d 90 fe 2d f0    	mov    0xf02dfe90,%ebx
f0101369:	39 da                	cmp    %ebx,%edx
f010136b:	72 4b                	jb     f01013b8 <check_page_free_list+0x150>
		assert(pp < pages + npages);
f010136d:	a1 88 fe 2d f0       	mov    0xf02dfe88,%eax
f0101372:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101375:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101378:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010137b:	39 c2                	cmp    %eax,%edx
f010137d:	73 57                	jae    f01013d6 <check_page_free_list+0x16e>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010137f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101382:	89 d0                	mov    %edx,%eax
f0101384:	29 d8                	sub    %ebx,%eax
f0101386:	a8 07                	test   $0x7,%al
f0101388:	75 6e                	jne    f01013f8 <check_page_free_list+0x190>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010138a:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010138d:	c1 e0 0c             	shl    $0xc,%eax
f0101390:	0f 84 83 00 00 00    	je     f0101419 <check_page_free_list+0x1b1>
		assert(page2pa(pp) != IOPHYSMEM);
f0101396:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010139b:	0f 84 98 00 00 00    	je     f0101439 <check_page_free_list+0x1d1>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01013a1:	be 00 00 00 00       	mov    $0x0,%esi
f01013a6:	bf 00 00 00 00       	mov    $0x0,%edi
f01013ab:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f01013ae:	e9 9f 00 00 00       	jmp    f0101452 <check_page_free_list+0x1ea>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01013b3:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f01013b6:	73 19                	jae    f01013d1 <check_page_free_list+0x169>
f01013b8:	68 4b 78 10 f0       	push   $0xf010784b
f01013bd:	68 57 78 10 f0       	push   $0xf0107857
f01013c2:	68 c8 02 00 00       	push   $0x2c8
f01013c7:	68 31 78 10 f0       	push   $0xf0107831
f01013cc:	e8 97 ec ff ff       	call   f0100068 <_panic>
		assert(pp < pages + npages);
f01013d1:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01013d4:	72 19                	jb     f01013ef <check_page_free_list+0x187>
f01013d6:	68 6c 78 10 f0       	push   $0xf010786c
f01013db:	68 57 78 10 f0       	push   $0xf0107857
f01013e0:	68 c9 02 00 00       	push   $0x2c9
f01013e5:	68 31 78 10 f0       	push   $0xf0107831
f01013ea:	e8 79 ec ff ff       	call   f0100068 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01013ef:	89 d0                	mov    %edx,%eax
f01013f1:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01013f4:	a8 07                	test   $0x7,%al
f01013f6:	74 19                	je     f0101411 <check_page_free_list+0x1a9>
f01013f8:	68 90 6f 10 f0       	push   $0xf0106f90
f01013fd:	68 57 78 10 f0       	push   $0xf0107857
f0101402:	68 ca 02 00 00       	push   $0x2ca
f0101407:	68 31 78 10 f0       	push   $0xf0107831
f010140c:	e8 57 ec ff ff       	call   f0100068 <_panic>
f0101411:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101414:	c1 e0 0c             	shl    $0xc,%eax
f0101417:	75 19                	jne    f0101432 <check_page_free_list+0x1ca>
f0101419:	68 80 78 10 f0       	push   $0xf0107880
f010141e:	68 57 78 10 f0       	push   $0xf0107857
f0101423:	68 cd 02 00 00       	push   $0x2cd
f0101428:	68 31 78 10 f0       	push   $0xf0107831
f010142d:	e8 36 ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101432:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101437:	75 19                	jne    f0101452 <check_page_free_list+0x1ea>
f0101439:	68 91 78 10 f0       	push   $0xf0107891
f010143e:	68 57 78 10 f0       	push   $0xf0107857
f0101443:	68 ce 02 00 00       	push   $0x2ce
f0101448:	68 31 78 10 f0       	push   $0xf0107831
f010144d:	e8 16 ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101452:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101457:	75 19                	jne    f0101472 <check_page_free_list+0x20a>
f0101459:	68 c4 6f 10 f0       	push   $0xf0106fc4
f010145e:	68 57 78 10 f0       	push   $0xf0107857
f0101463:	68 cf 02 00 00       	push   $0x2cf
f0101468:	68 31 78 10 f0       	push   $0xf0107831
f010146d:	e8 f6 eb ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101472:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101477:	75 19                	jne    f0101492 <check_page_free_list+0x22a>
f0101479:	68 aa 78 10 f0       	push   $0xf01078aa
f010147e:	68 57 78 10 f0       	push   $0xf0107857
f0101483:	68 d0 02 00 00       	push   $0x2d0
f0101488:	68 31 78 10 f0       	push   $0xf0107831
f010148d:	e8 d6 eb ff ff       	call   f0100068 <_panic>
f0101492:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101494:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101499:	76 40                	jbe    f01014db <check_page_free_list+0x273>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010149b:	89 c3                	mov    %eax,%ebx
f010149d:	c1 eb 0c             	shr    $0xc,%ebx
f01014a0:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f01014a3:	77 12                	ja     f01014b7 <check_page_free_list+0x24f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014a5:	50                   	push   %eax
f01014a6:	68 c8 64 10 f0       	push   $0xf01064c8
f01014ab:	6a 58                	push   $0x58
f01014ad:	68 3d 78 10 f0       	push   $0xf010783d
f01014b2:	e8 b1 eb ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f01014b7:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01014bd:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01014c0:	76 19                	jbe    f01014db <check_page_free_list+0x273>
f01014c2:	68 e8 6f 10 f0       	push   $0xf0106fe8
f01014c7:	68 57 78 10 f0       	push   $0xf0107857
f01014cc:	68 d1 02 00 00       	push   $0x2d1
f01014d1:	68 31 78 10 f0       	push   $0xf0107831
f01014d6:	e8 8d eb ff ff       	call   f0100068 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01014db:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01014e0:	75 19                	jne    f01014fb <check_page_free_list+0x293>
f01014e2:	68 c4 78 10 f0       	push   $0xf01078c4
f01014e7:	68 57 78 10 f0       	push   $0xf0107857
f01014ec:	68 d3 02 00 00       	push   $0x2d3
f01014f1:	68 31 78 10 f0       	push   $0xf0107831
f01014f6:	e8 6d eb ff ff       	call   f0100068 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f01014fb:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f0101501:	77 03                	ja     f0101506 <check_page_free_list+0x29e>
			++nfree_basemem;
f0101503:	47                   	inc    %edi
f0101504:	eb 01                	jmp    f0101507 <check_page_free_list+0x29f>
		else
			++nfree_extmem;
f0101506:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101507:	8b 12                	mov    (%edx),%edx
f0101509:	85 d2                	test   %edx,%edx
f010150b:	0f 85 a2 fe ff ff    	jne    f01013b3 <check_page_free_list+0x14b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101511:	85 ff                	test   %edi,%edi
f0101513:	7f 19                	jg     f010152e <check_page_free_list+0x2c6>
f0101515:	68 e1 78 10 f0       	push   $0xf01078e1
f010151a:	68 57 78 10 f0       	push   $0xf0107857
f010151f:	68 db 02 00 00       	push   $0x2db
f0101524:	68 31 78 10 f0       	push   $0xf0107831
f0101529:	e8 3a eb ff ff       	call   f0100068 <_panic>
	assert(nfree_extmem > 0);
f010152e:	85 f6                	test   %esi,%esi
f0101530:	7f 19                	jg     f010154b <check_page_free_list+0x2e3>
f0101532:	68 f3 78 10 f0       	push   $0xf01078f3
f0101537:	68 57 78 10 f0       	push   $0xf0107857
f010153c:	68 dc 02 00 00       	push   $0x2dc
f0101541:	68 31 78 10 f0       	push   $0xf0107831
f0101546:	e8 1d eb ff ff       	call   f0100068 <_panic>
}
f010154b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010154e:	5b                   	pop    %ebx
f010154f:	5e                   	pop    %esi
f0101550:	5f                   	pop    %edi
f0101551:	c9                   	leave  
f0101552:	c3                   	ret    

f0101553 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101553:	55                   	push   %ebp
f0101554:	89 e5                	mov    %esp,%ebp
f0101556:	56                   	push   %esi
f0101557:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f0101558:	c7 05 30 f2 2d f0 00 	movl   $0x0,0xf02df230
f010155f:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f0101562:	b8 00 00 00 00       	mov    $0x0,%eax
f0101567:	e8 3c fc ff ff       	call   f01011a8 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010156c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101571:	77 15                	ja     f0101588 <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101573:	50                   	push   %eax
f0101574:	68 a4 64 10 f0       	push   $0xf01064a4
f0101579:	68 50 01 00 00       	push   $0x150
f010157e:	68 31 78 10 f0       	push   $0xf0107831
f0101583:	e8 e0 ea ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101588:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f010158e:	c1 ee 0c             	shr    $0xc,%esi
    size_t mpentry_page = MPENTRY_PADDR / PGSIZE;
    for (i = 0; i < npages; i++) {
f0101591:	83 3d 88 fe 2d f0 00 	cmpl   $0x0,0xf02dfe88
f0101598:	74 64                	je     f01015fe <page_init+0xab>
f010159a:	8b 1d 30 f2 2d f0    	mov    0xf02df230,%ebx
f01015a0:	ba 00 00 00 00       	mov    $0x0,%edx
f01015a5:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub) && i != mpentry_page) {
f01015aa:	85 c0                	test   %eax,%eax
f01015ac:	74 2a                	je     f01015d8 <page_init+0x85>
f01015ae:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f01015b3:	76 04                	jbe    f01015b9 <page_init+0x66>
f01015b5:	39 c6                	cmp    %eax,%esi
f01015b7:	77 1f                	ja     f01015d8 <page_init+0x85>
f01015b9:	83 f8 07             	cmp    $0x7,%eax
f01015bc:	74 1a                	je     f01015d8 <page_init+0x85>
		    pages[i].pp_ref = 0;
f01015be:	89 d1                	mov    %edx,%ecx
f01015c0:	03 0d 90 fe 2d f0    	add    0xf02dfe90,%ecx
f01015c6:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f01015cc:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f01015ce:	89 d3                	mov    %edx,%ebx
f01015d0:	03 1d 90 fe 2d f0    	add    0xf02dfe90,%ebx
f01015d6:	eb 14                	jmp    f01015ec <page_init+0x99>
        } else {
            pages[i].pp_ref = 1;
f01015d8:	89 d1                	mov    %edx,%ecx
f01015da:	03 0d 90 fe 2d f0    	add    0xf02dfe90,%ecx
f01015e0:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f01015e6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    size_t mpentry_page = MPENTRY_PADDR / PGSIZE;
    for (i = 0; i < npages; i++) {
f01015ec:	40                   	inc    %eax
f01015ed:	83 c2 08             	add    $0x8,%edx
f01015f0:	39 05 88 fe 2d f0    	cmp    %eax,0xf02dfe88
f01015f6:	77 b2                	ja     f01015aa <page_init+0x57>
f01015f8:	89 1d 30 f2 2d f0    	mov    %ebx,0xf02df230
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f01015fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101601:	5b                   	pop    %ebx
f0101602:	5e                   	pop    %esi
f0101603:	c9                   	leave  
f0101604:	c3                   	ret    

f0101605 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101605:	55                   	push   %ebp
f0101606:	89 e5                	mov    %esp,%ebp
f0101608:	53                   	push   %ebx
f0101609:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
    while (page_free_list && page_free_list->pp_ref != 0) 
f010160c:	8b 1d 30 f2 2d f0    	mov    0xf02df230,%ebx
f0101612:	85 db                	test   %ebx,%ebx
f0101614:	74 63                	je     f0101679 <page_alloc+0x74>
f0101616:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010161b:	74 63                	je     f0101680 <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f010161d:	8b 1b                	mov    (%ebx),%ebx
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
    while (page_free_list && page_free_list->pp_ref != 0) 
f010161f:	85 db                	test   %ebx,%ebx
f0101621:	75 08                	jne    f010162b <page_alloc+0x26>
f0101623:	89 1d 30 f2 2d f0    	mov    %ebx,0xf02df230
f0101629:	eb 4e                	jmp    f0101679 <page_alloc+0x74>
f010162b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101630:	75 eb                	jne    f010161d <page_alloc+0x18>
f0101632:	eb 4c                	jmp    f0101680 <page_alloc+0x7b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101634:	89 d8                	mov    %ebx,%eax
f0101636:	2b 05 90 fe 2d f0    	sub    0xf02dfe90,%eax
f010163c:	c1 f8 03             	sar    $0x3,%eax
f010163f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101642:	89 c2                	mov    %eax,%edx
f0101644:	c1 ea 0c             	shr    $0xc,%edx
f0101647:	3b 15 88 fe 2d f0    	cmp    0xf02dfe88,%edx
f010164d:	72 12                	jb     f0101661 <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010164f:	50                   	push   %eax
f0101650:	68 c8 64 10 f0       	push   $0xf01064c8
f0101655:	6a 58                	push   $0x58
f0101657:	68 3d 78 10 f0       	push   $0xf010783d
f010165c:	e8 07 ea ff ff       	call   f0100068 <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f0101661:	83 ec 04             	sub    $0x4,%esp
f0101664:	68 00 10 00 00       	push   $0x1000
f0101669:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010166b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101670:	50                   	push   %eax
f0101671:	e8 0b 41 00 00       	call   f0105781 <memset>
f0101676:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f0101679:	89 d8                	mov    %ebx,%eax
f010167b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010167e:	c9                   	leave  
f010167f:	c3                   	ret    

    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f0101680:	8b 03                	mov    (%ebx),%eax
f0101682:	a3 30 f2 2d f0       	mov    %eax,0xf02df230
        if (alloc_flags & ALLOC_ZERO) {
f0101687:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010168b:	74 ec                	je     f0101679 <page_alloc+0x74>
f010168d:	eb a5                	jmp    f0101634 <page_alloc+0x2f>

f010168f <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010168f:	55                   	push   %ebp
f0101690:	89 e5                	mov    %esp,%ebp
f0101692:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f0101695:	85 c0                	test   %eax,%eax
f0101697:	74 14                	je     f01016ad <page_free+0x1e>
f0101699:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010169e:	75 0d                	jne    f01016ad <page_free+0x1e>
    pp->pp_link = page_free_list;
f01016a0:	8b 15 30 f2 2d f0    	mov    0xf02df230,%edx
f01016a6:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f01016a8:	a3 30 f2 2d f0       	mov    %eax,0xf02df230
}
f01016ad:	c9                   	leave  
f01016ae:	c3                   	ret    

f01016af <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01016af:	55                   	push   %ebp
f01016b0:	89 e5                	mov    %esp,%ebp
f01016b2:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01016b5:	8b 50 04             	mov    0x4(%eax),%edx
f01016b8:	4a                   	dec    %edx
f01016b9:	66 89 50 04          	mov    %dx,0x4(%eax)
f01016bd:	66 85 d2             	test   %dx,%dx
f01016c0:	75 09                	jne    f01016cb <page_decref+0x1c>
		page_free(pp);
f01016c2:	50                   	push   %eax
f01016c3:	e8 c7 ff ff ff       	call   f010168f <page_free>
f01016c8:	83 c4 04             	add    $0x4,%esp
}
f01016cb:	c9                   	leave  
f01016cc:	c3                   	ret    

f01016cd <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01016cd:	55                   	push   %ebp
f01016ce:	89 e5                	mov    %esp,%ebp
f01016d0:	56                   	push   %esi
f01016d1:	53                   	push   %ebx
f01016d2:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f01016d5:	89 f3                	mov    %esi,%ebx
f01016d7:	c1 eb 16             	shr    $0x16,%ebx
f01016da:	c1 e3 02             	shl    $0x2,%ebx
f01016dd:	03 5d 08             	add    0x8(%ebp),%ebx
f01016e0:	8b 03                	mov    (%ebx),%eax
f01016e2:	85 c0                	test   %eax,%eax
f01016e4:	74 04                	je     f01016ea <pgdir_walk+0x1d>
f01016e6:	a8 01                	test   $0x1,%al
f01016e8:	75 2c                	jne    f0101716 <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f01016ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01016ee:	74 61                	je     f0101751 <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(1);
f01016f0:	83 ec 0c             	sub    $0xc,%esp
f01016f3:	6a 01                	push   $0x1
f01016f5:	e8 0b ff ff ff       	call   f0101605 <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f01016fa:	83 c4 10             	add    $0x10,%esp
f01016fd:	85 c0                	test   %eax,%eax
f01016ff:	74 57                	je     f0101758 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f0101701:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101705:	2b 05 90 fe 2d f0    	sub    0xf02dfe90,%eax
f010170b:	c1 f8 03             	sar    $0x3,%eax
f010170e:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f0101711:	83 c8 07             	or     $0x7,%eax
f0101714:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f0101716:	8b 03                	mov    (%ebx),%eax
f0101718:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010171d:	89 c2                	mov    %eax,%edx
f010171f:	c1 ea 0c             	shr    $0xc,%edx
f0101722:	3b 15 88 fe 2d f0    	cmp    0xf02dfe88,%edx
f0101728:	72 15                	jb     f010173f <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010172a:	50                   	push   %eax
f010172b:	68 c8 64 10 f0       	push   $0xf01064c8
f0101730:	68 b4 01 00 00       	push   $0x1b4
f0101735:	68 31 78 10 f0       	push   $0xf0107831
f010173a:	e8 29 e9 ff ff       	call   f0100068 <_panic>
f010173f:	c1 ee 0a             	shr    $0xa,%esi
f0101742:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101748:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f010174f:	eb 0c                	jmp    f010175d <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f0101751:	b8 00 00 00 00       	mov    $0x0,%eax
f0101756:	eb 05                	jmp    f010175d <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f0101758:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f010175d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101760:	5b                   	pop    %ebx
f0101761:	5e                   	pop    %esi
f0101762:	c9                   	leave  
f0101763:	c3                   	ret    

f0101764 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101764:	55                   	push   %ebp
f0101765:	89 e5                	mov    %esp,%ebp
f0101767:	57                   	push   %edi
f0101768:	56                   	push   %esi
f0101769:	53                   	push   %ebx
f010176a:	83 ec 1c             	sub    $0x1c,%esp
f010176d:	89 c7                	mov    %eax,%edi
f010176f:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101772:	01 d1                	add    %edx,%ecx
f0101774:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101777:	39 ca                	cmp    %ecx,%edx
f0101779:	74 32                	je     f01017ad <boot_map_region+0x49>
f010177b:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f010177d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101780:	83 c8 01             	or     $0x1,%eax
f0101783:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f0101786:	83 ec 04             	sub    $0x4,%esp
f0101789:	6a 01                	push   $0x1
f010178b:	53                   	push   %ebx
f010178c:	57                   	push   %edi
f010178d:	e8 3b ff ff ff       	call   f01016cd <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f0101792:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101795:	09 f2                	or     %esi,%edx
f0101797:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101799:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010179f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01017a5:	83 c4 10             	add    $0x10,%esp
f01017a8:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01017ab:	75 d9                	jne    f0101786 <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f01017ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01017b0:	5b                   	pop    %ebx
f01017b1:	5e                   	pop    %esi
f01017b2:	5f                   	pop    %edi
f01017b3:	c9                   	leave  
f01017b4:	c3                   	ret    

f01017b5 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01017b5:	55                   	push   %ebp
f01017b6:	89 e5                	mov    %esp,%ebp
f01017b8:	53                   	push   %ebx
f01017b9:	83 ec 08             	sub    $0x8,%esp
f01017bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f01017bf:	6a 00                	push   $0x0
f01017c1:	ff 75 0c             	pushl  0xc(%ebp)
f01017c4:	ff 75 08             	pushl  0x8(%ebp)
f01017c7:	e8 01 ff ff ff       	call   f01016cd <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01017cc:	83 c4 10             	add    $0x10,%esp
f01017cf:	85 c0                	test   %eax,%eax
f01017d1:	74 37                	je     f010180a <page_lookup+0x55>
f01017d3:	f6 00 01             	testb  $0x1,(%eax)
f01017d6:	74 39                	je     f0101811 <page_lookup+0x5c>
    if (pte_store != 0) {
f01017d8:	85 db                	test   %ebx,%ebx
f01017da:	74 02                	je     f01017de <page_lookup+0x29>
        *pte_store = pte;
f01017dc:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f01017de:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017e0:	c1 e8 0c             	shr    $0xc,%eax
f01017e3:	3b 05 88 fe 2d f0    	cmp    0xf02dfe88,%eax
f01017e9:	72 14                	jb     f01017ff <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01017eb:	83 ec 04             	sub    $0x4,%esp
f01017ee:	68 30 70 10 f0       	push   $0xf0107030
f01017f3:	6a 51                	push   $0x51
f01017f5:	68 3d 78 10 f0       	push   $0xf010783d
f01017fa:	e8 69 e8 ff ff       	call   f0100068 <_panic>
	return &pages[PGNUM(pa)];
f01017ff:	c1 e0 03             	shl    $0x3,%eax
f0101802:	03 05 90 fe 2d f0    	add    0xf02dfe90,%eax
f0101808:	eb 0c                	jmp    f0101816 <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f010180a:	b8 00 00 00 00       	mov    $0x0,%eax
f010180f:	eb 05                	jmp    f0101816 <page_lookup+0x61>
f0101811:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f0101816:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101819:	c9                   	leave  
f010181a:	c3                   	ret    

f010181b <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010181b:	55                   	push   %ebp
f010181c:	89 e5                	mov    %esp,%ebp
f010181e:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101821:	e8 8a 45 00 00       	call   f0105db0 <cpunum>
f0101826:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010182d:	29 c2                	sub    %eax,%edx
f010182f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0101832:	83 3c 85 28 00 2e f0 	cmpl   $0x0,-0xfd1ffd8(,%eax,4)
f0101839:	00 
f010183a:	74 20                	je     f010185c <tlb_invalidate+0x41>
f010183c:	e8 6f 45 00 00       	call   f0105db0 <cpunum>
f0101841:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101848:	29 c2                	sub    %eax,%edx
f010184a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010184d:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f0101854:	8b 55 08             	mov    0x8(%ebp),%edx
f0101857:	39 50 60             	cmp    %edx,0x60(%eax)
f010185a:	75 06                	jne    f0101862 <tlb_invalidate+0x47>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010185c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010185f:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101862:	c9                   	leave  
f0101863:	c3                   	ret    

f0101864 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101864:	55                   	push   %ebp
f0101865:	89 e5                	mov    %esp,%ebp
f0101867:	56                   	push   %esi
f0101868:	53                   	push   %ebx
f0101869:	83 ec 14             	sub    $0x14,%esp
f010186c:	8b 75 08             	mov    0x8(%ebp),%esi
f010186f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f0101872:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101875:	50                   	push   %eax
f0101876:	53                   	push   %ebx
f0101877:	56                   	push   %esi
f0101878:	e8 38 ff ff ff       	call   f01017b5 <page_lookup>
    if (pg == NULL) return;
f010187d:	83 c4 10             	add    $0x10,%esp
f0101880:	85 c0                	test   %eax,%eax
f0101882:	74 26                	je     f01018aa <page_remove+0x46>
    page_decref(pg);
f0101884:	83 ec 0c             	sub    $0xc,%esp
f0101887:	50                   	push   %eax
f0101888:	e8 22 fe ff ff       	call   f01016af <page_decref>
    if (pte != NULL) *pte = 0;
f010188d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101890:	83 c4 10             	add    $0x10,%esp
f0101893:	85 c0                	test   %eax,%eax
f0101895:	74 06                	je     f010189d <page_remove+0x39>
f0101897:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f010189d:	83 ec 08             	sub    $0x8,%esp
f01018a0:	53                   	push   %ebx
f01018a1:	56                   	push   %esi
f01018a2:	e8 74 ff ff ff       	call   f010181b <tlb_invalidate>
f01018a7:	83 c4 10             	add    $0x10,%esp
}
f01018aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01018ad:	5b                   	pop    %ebx
f01018ae:	5e                   	pop    %esi
f01018af:	c9                   	leave  
f01018b0:	c3                   	ret    

f01018b1 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01018b1:	55                   	push   %ebp
f01018b2:	89 e5                	mov    %esp,%ebp
f01018b4:	57                   	push   %edi
f01018b5:	56                   	push   %esi
f01018b6:	53                   	push   %ebx
f01018b7:	83 ec 10             	sub    $0x10,%esp
f01018ba:	8b 75 0c             	mov    0xc(%ebp),%esi
f01018bd:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f01018c0:	6a 01                	push   $0x1
f01018c2:	57                   	push   %edi
f01018c3:	ff 75 08             	pushl  0x8(%ebp)
f01018c6:	e8 02 fe ff ff       	call   f01016cd <pgdir_walk>
f01018cb:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f01018cd:	83 c4 10             	add    $0x10,%esp
f01018d0:	85 c0                	test   %eax,%eax
f01018d2:	74 39                	je     f010190d <page_insert+0x5c>
    ++pp->pp_ref;
f01018d4:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f01018d8:	f6 00 01             	testb  $0x1,(%eax)
f01018db:	74 0f                	je     f01018ec <page_insert+0x3b>
        page_remove(pgdir, va);
f01018dd:	83 ec 08             	sub    $0x8,%esp
f01018e0:	57                   	push   %edi
f01018e1:	ff 75 08             	pushl  0x8(%ebp)
f01018e4:	e8 7b ff ff ff       	call   f0101864 <page_remove>
f01018e9:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f01018ec:	8b 55 14             	mov    0x14(%ebp),%edx
f01018ef:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018f2:	2b 35 90 fe 2d f0    	sub    0xf02dfe90,%esi
f01018f8:	c1 fe 03             	sar    $0x3,%esi
f01018fb:	89 f0                	mov    %esi,%eax
f01018fd:	c1 e0 0c             	shl    $0xc,%eax
f0101900:	89 d6                	mov    %edx,%esi
f0101902:	09 c6                	or     %eax,%esi
f0101904:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101906:	b8 00 00 00 00       	mov    $0x0,%eax
f010190b:	eb 05                	jmp    f0101912 <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f010190d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f0101912:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101915:	5b                   	pop    %ebx
f0101916:	5e                   	pop    %esi
f0101917:	5f                   	pop    %edi
f0101918:	c9                   	leave  
f0101919:	c3                   	ret    

f010191a <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f010191a:	55                   	push   %ebp
f010191b:	89 e5                	mov    %esp,%ebp
f010191d:	53                   	push   %ebx
f010191e:	83 ec 0c             	sub    $0xc,%esp
f0101921:	8b 45 08             	mov    0x8(%ebp),%eax
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	uint32_t ed = ROUNDUP(pa + size, PGSIZE);
f0101924:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010192a:	03 5d 0c             	add    0xc(%ebp),%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
f010192d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	uint32_t ed = ROUNDUP(pa + size, PGSIZE);
f0101932:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
	boot_map_region(kern_pgdir, base, ed - pa, pa, PTE_PCD | PTE_PWT | PTE_W);
f0101938:	29 c3                	sub    %eax,%ebx
f010193a:	6a 1a                	push   $0x1a
f010193c:	50                   	push   %eax
f010193d:	89 d9                	mov    %ebx,%ecx
f010193f:	8b 15 00 83 12 f0    	mov    0xf0128300,%edx
f0101945:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f010194a:	e8 15 fe ff ff       	call   f0101764 <boot_map_region>
	uintptr_t tmp_base = base;
f010194f:	a1 00 83 12 f0       	mov    0xf0128300,%eax
	base += ed - pa;
f0101954:	01 c3                	add    %eax,%ebx
f0101956:	89 1d 00 83 12 f0    	mov    %ebx,0xf0128300
	return (void *) tmp_base;
	panic("mmio_map_region not implemented");
}
f010195c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010195f:	c9                   	leave  
f0101960:	c3                   	ret    

f0101961 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101961:	55                   	push   %ebp
f0101962:	89 e5                	mov    %esp,%ebp
f0101964:	57                   	push   %edi
f0101965:	56                   	push   %esi
f0101966:	53                   	push   %ebx
f0101967:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010196a:	b8 15 00 00 00       	mov    $0x15,%eax
f010196f:	e8 cd f8 ff ff       	call   f0101241 <nvram_read>
f0101974:	c1 e0 0a             	shl    $0xa,%eax
f0101977:	89 c2                	mov    %eax,%edx
f0101979:	85 c0                	test   %eax,%eax
f010197b:	79 06                	jns    f0101983 <mem_init+0x22>
f010197d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101983:	c1 fa 0c             	sar    $0xc,%edx
f0101986:	89 15 38 f2 2d f0    	mov    %edx,0xf02df238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010198c:	b8 17 00 00 00       	mov    $0x17,%eax
f0101991:	e8 ab f8 ff ff       	call   f0101241 <nvram_read>
f0101996:	89 c2                	mov    %eax,%edx
f0101998:	c1 e2 0a             	shl    $0xa,%edx
f010199b:	89 d0                	mov    %edx,%eax
f010199d:	85 d2                	test   %edx,%edx
f010199f:	79 06                	jns    f01019a7 <mem_init+0x46>
f01019a1:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01019a7:	c1 f8 0c             	sar    $0xc,%eax
f01019aa:	74 0e                	je     f01019ba <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01019ac:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01019b2:	89 15 88 fe 2d f0    	mov    %edx,0xf02dfe88
f01019b8:	eb 0c                	jmp    f01019c6 <mem_init+0x65>
	else
		npages = npages_basemem;
f01019ba:	8b 15 38 f2 2d f0    	mov    0xf02df238,%edx
f01019c0:	89 15 88 fe 2d f0    	mov    %edx,0xf02dfe88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01019c6:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01019c9:	c1 e8 0a             	shr    $0xa,%eax
f01019cc:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01019cd:	a1 38 f2 2d f0       	mov    0xf02df238,%eax
f01019d2:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01019d5:	c1 e8 0a             	shr    $0xa,%eax
f01019d8:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01019d9:	a1 88 fe 2d f0       	mov    0xf02dfe88,%eax
f01019de:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01019e1:	c1 e8 0a             	shr    $0xa,%eax
f01019e4:	50                   	push   %eax
f01019e5:	68 50 70 10 f0       	push   $0xf0107050
f01019ea:	e8 9e 23 00 00       	call   f0103d8d <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01019ef:	b8 00 10 00 00       	mov    $0x1000,%eax
f01019f4:	e8 af f7 ff ff       	call   f01011a8 <boot_alloc>
f01019f9:	a3 8c fe 2d f0       	mov    %eax,0xf02dfe8c
	memset(kern_pgdir, 0, PGSIZE);
f01019fe:	83 c4 0c             	add    $0xc,%esp
f0101a01:	68 00 10 00 00       	push   $0x1000
f0101a06:	6a 00                	push   $0x0
f0101a08:	50                   	push   %eax
f0101a09:	e8 73 3d 00 00       	call   f0105781 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101a0e:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101a13:	83 c4 10             	add    $0x10,%esp
f0101a16:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101a1b:	77 15                	ja     f0101a32 <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101a1d:	50                   	push   %eax
f0101a1e:	68 a4 64 10 f0       	push   $0xf01064a4
f0101a23:	68 90 00 00 00       	push   $0x90
f0101a28:	68 31 78 10 f0       	push   $0xf0107831
f0101a2d:	e8 36 e6 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101a32:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101a38:	83 ca 05             	or     $0x5,%edx
f0101a3b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101a41:	a1 88 fe 2d f0       	mov    0xf02dfe88,%eax
f0101a46:	c1 e0 03             	shl    $0x3,%eax
f0101a49:	e8 5a f7 ff ff       	call   f01011a8 <boot_alloc>
f0101a4e:	a3 90 fe 2d f0       	mov    %eax,0xf02dfe90
    

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101a53:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101a58:	e8 4b f7 ff ff       	call   f01011a8 <boot_alloc>
f0101a5d:	a3 3c f2 2d f0       	mov    %eax,0xf02df23c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101a62:	e8 ec fa ff ff       	call   f0101553 <page_init>

	check_page_free_list(1);
f0101a67:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a6c:	e8 f7 f7 ff ff       	call   f0101268 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101a71:	83 3d 90 fe 2d f0 00 	cmpl   $0x0,0xf02dfe90
f0101a78:	75 17                	jne    f0101a91 <mem_init+0x130>
		panic("'pages' is a null pointer!");
f0101a7a:	83 ec 04             	sub    $0x4,%esp
f0101a7d:	68 04 79 10 f0       	push   $0xf0107904
f0101a82:	68 ed 02 00 00       	push   $0x2ed
f0101a87:	68 31 78 10 f0       	push   $0xf0107831
f0101a8c:	e8 d7 e5 ff ff       	call   f0100068 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a91:	a1 30 f2 2d f0       	mov    0xf02df230,%eax
f0101a96:	85 c0                	test   %eax,%eax
f0101a98:	74 0e                	je     f0101aa8 <mem_init+0x147>
f0101a9a:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101a9f:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101aa0:	8b 00                	mov    (%eax),%eax
f0101aa2:	85 c0                	test   %eax,%eax
f0101aa4:	75 f9                	jne    f0101a9f <mem_init+0x13e>
f0101aa6:	eb 05                	jmp    f0101aad <mem_init+0x14c>
f0101aa8:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101aad:	83 ec 0c             	sub    $0xc,%esp
f0101ab0:	6a 00                	push   $0x0
f0101ab2:	e8 4e fb ff ff       	call   f0101605 <page_alloc>
f0101ab7:	89 c6                	mov    %eax,%esi
f0101ab9:	83 c4 10             	add    $0x10,%esp
f0101abc:	85 c0                	test   %eax,%eax
f0101abe:	75 19                	jne    f0101ad9 <mem_init+0x178>
f0101ac0:	68 1f 79 10 f0       	push   $0xf010791f
f0101ac5:	68 57 78 10 f0       	push   $0xf0107857
f0101aca:	68 f5 02 00 00       	push   $0x2f5
f0101acf:	68 31 78 10 f0       	push   $0xf0107831
f0101ad4:	e8 8f e5 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ad9:	83 ec 0c             	sub    $0xc,%esp
f0101adc:	6a 00                	push   $0x0
f0101ade:	e8 22 fb ff ff       	call   f0101605 <page_alloc>
f0101ae3:	89 c7                	mov    %eax,%edi
f0101ae5:	83 c4 10             	add    $0x10,%esp
f0101ae8:	85 c0                	test   %eax,%eax
f0101aea:	75 19                	jne    f0101b05 <mem_init+0x1a4>
f0101aec:	68 35 79 10 f0       	push   $0xf0107935
f0101af1:	68 57 78 10 f0       	push   $0xf0107857
f0101af6:	68 f6 02 00 00       	push   $0x2f6
f0101afb:	68 31 78 10 f0       	push   $0xf0107831
f0101b00:	e8 63 e5 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b05:	83 ec 0c             	sub    $0xc,%esp
f0101b08:	6a 00                	push   $0x0
f0101b0a:	e8 f6 fa ff ff       	call   f0101605 <page_alloc>
f0101b0f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b12:	83 c4 10             	add    $0x10,%esp
f0101b15:	85 c0                	test   %eax,%eax
f0101b17:	75 19                	jne    f0101b32 <mem_init+0x1d1>
f0101b19:	68 4b 79 10 f0       	push   $0xf010794b
f0101b1e:	68 57 78 10 f0       	push   $0xf0107857
f0101b23:	68 f7 02 00 00       	push   $0x2f7
f0101b28:	68 31 78 10 f0       	push   $0xf0107831
f0101b2d:	e8 36 e5 ff ff       	call   f0100068 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b32:	39 fe                	cmp    %edi,%esi
f0101b34:	75 19                	jne    f0101b4f <mem_init+0x1ee>
f0101b36:	68 61 79 10 f0       	push   $0xf0107961
f0101b3b:	68 57 78 10 f0       	push   $0xf0107857
f0101b40:	68 fa 02 00 00       	push   $0x2fa
f0101b45:	68 31 78 10 f0       	push   $0xf0107831
f0101b4a:	e8 19 e5 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b4f:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101b52:	74 05                	je     f0101b59 <mem_init+0x1f8>
f0101b54:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101b57:	75 19                	jne    f0101b72 <mem_init+0x211>
f0101b59:	68 8c 70 10 f0       	push   $0xf010708c
f0101b5e:	68 57 78 10 f0       	push   $0xf0107857
f0101b63:	68 fb 02 00 00       	push   $0x2fb
f0101b68:	68 31 78 10 f0       	push   $0xf0107831
f0101b6d:	e8 f6 e4 ff ff       	call   f0100068 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b72:	8b 15 90 fe 2d f0    	mov    0xf02dfe90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101b78:	a1 88 fe 2d f0       	mov    0xf02dfe88,%eax
f0101b7d:	c1 e0 0c             	shl    $0xc,%eax
f0101b80:	89 f1                	mov    %esi,%ecx
f0101b82:	29 d1                	sub    %edx,%ecx
f0101b84:	c1 f9 03             	sar    $0x3,%ecx
f0101b87:	c1 e1 0c             	shl    $0xc,%ecx
f0101b8a:	39 c1                	cmp    %eax,%ecx
f0101b8c:	72 19                	jb     f0101ba7 <mem_init+0x246>
f0101b8e:	68 73 79 10 f0       	push   $0xf0107973
f0101b93:	68 57 78 10 f0       	push   $0xf0107857
f0101b98:	68 fc 02 00 00       	push   $0x2fc
f0101b9d:	68 31 78 10 f0       	push   $0xf0107831
f0101ba2:	e8 c1 e4 ff ff       	call   f0100068 <_panic>
f0101ba7:	89 f9                	mov    %edi,%ecx
f0101ba9:	29 d1                	sub    %edx,%ecx
f0101bab:	c1 f9 03             	sar    $0x3,%ecx
f0101bae:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101bb1:	39 c8                	cmp    %ecx,%eax
f0101bb3:	77 19                	ja     f0101bce <mem_init+0x26d>
f0101bb5:	68 90 79 10 f0       	push   $0xf0107990
f0101bba:	68 57 78 10 f0       	push   $0xf0107857
f0101bbf:	68 fd 02 00 00       	push   $0x2fd
f0101bc4:	68 31 78 10 f0       	push   $0xf0107831
f0101bc9:	e8 9a e4 ff ff       	call   f0100068 <_panic>
f0101bce:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101bd1:	29 d1                	sub    %edx,%ecx
f0101bd3:	89 ca                	mov    %ecx,%edx
f0101bd5:	c1 fa 03             	sar    $0x3,%edx
f0101bd8:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101bdb:	39 d0                	cmp    %edx,%eax
f0101bdd:	77 19                	ja     f0101bf8 <mem_init+0x297>
f0101bdf:	68 ad 79 10 f0       	push   $0xf01079ad
f0101be4:	68 57 78 10 f0       	push   $0xf0107857
f0101be9:	68 fe 02 00 00       	push   $0x2fe
f0101bee:	68 31 78 10 f0       	push   $0xf0107831
f0101bf3:	e8 70 e4 ff ff       	call   f0100068 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101bf8:	a1 30 f2 2d f0       	mov    0xf02df230,%eax
f0101bfd:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101c00:	c7 05 30 f2 2d f0 00 	movl   $0x0,0xf02df230
f0101c07:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c0a:	83 ec 0c             	sub    $0xc,%esp
f0101c0d:	6a 00                	push   $0x0
f0101c0f:	e8 f1 f9 ff ff       	call   f0101605 <page_alloc>
f0101c14:	83 c4 10             	add    $0x10,%esp
f0101c17:	85 c0                	test   %eax,%eax
f0101c19:	74 19                	je     f0101c34 <mem_init+0x2d3>
f0101c1b:	68 ca 79 10 f0       	push   $0xf01079ca
f0101c20:	68 57 78 10 f0       	push   $0xf0107857
f0101c25:	68 05 03 00 00       	push   $0x305
f0101c2a:	68 31 78 10 f0       	push   $0xf0107831
f0101c2f:	e8 34 e4 ff ff       	call   f0100068 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101c34:	83 ec 0c             	sub    $0xc,%esp
f0101c37:	56                   	push   %esi
f0101c38:	e8 52 fa ff ff       	call   f010168f <page_free>
	page_free(pp1);
f0101c3d:	89 3c 24             	mov    %edi,(%esp)
f0101c40:	e8 4a fa ff ff       	call   f010168f <page_free>
	page_free(pp2);
f0101c45:	83 c4 04             	add    $0x4,%esp
f0101c48:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c4b:	e8 3f fa ff ff       	call   f010168f <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c57:	e8 a9 f9 ff ff       	call   f0101605 <page_alloc>
f0101c5c:	89 c6                	mov    %eax,%esi
f0101c5e:	83 c4 10             	add    $0x10,%esp
f0101c61:	85 c0                	test   %eax,%eax
f0101c63:	75 19                	jne    f0101c7e <mem_init+0x31d>
f0101c65:	68 1f 79 10 f0       	push   $0xf010791f
f0101c6a:	68 57 78 10 f0       	push   $0xf0107857
f0101c6f:	68 0c 03 00 00       	push   $0x30c
f0101c74:	68 31 78 10 f0       	push   $0xf0107831
f0101c79:	e8 ea e3 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c7e:	83 ec 0c             	sub    $0xc,%esp
f0101c81:	6a 00                	push   $0x0
f0101c83:	e8 7d f9 ff ff       	call   f0101605 <page_alloc>
f0101c88:	89 c7                	mov    %eax,%edi
f0101c8a:	83 c4 10             	add    $0x10,%esp
f0101c8d:	85 c0                	test   %eax,%eax
f0101c8f:	75 19                	jne    f0101caa <mem_init+0x349>
f0101c91:	68 35 79 10 f0       	push   $0xf0107935
f0101c96:	68 57 78 10 f0       	push   $0xf0107857
f0101c9b:	68 0d 03 00 00       	push   $0x30d
f0101ca0:	68 31 78 10 f0       	push   $0xf0107831
f0101ca5:	e8 be e3 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101caa:	83 ec 0c             	sub    $0xc,%esp
f0101cad:	6a 00                	push   $0x0
f0101caf:	e8 51 f9 ff ff       	call   f0101605 <page_alloc>
f0101cb4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101cb7:	83 c4 10             	add    $0x10,%esp
f0101cba:	85 c0                	test   %eax,%eax
f0101cbc:	75 19                	jne    f0101cd7 <mem_init+0x376>
f0101cbe:	68 4b 79 10 f0       	push   $0xf010794b
f0101cc3:	68 57 78 10 f0       	push   $0xf0107857
f0101cc8:	68 0e 03 00 00       	push   $0x30e
f0101ccd:	68 31 78 10 f0       	push   $0xf0107831
f0101cd2:	e8 91 e3 ff ff       	call   f0100068 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101cd7:	39 fe                	cmp    %edi,%esi
f0101cd9:	75 19                	jne    f0101cf4 <mem_init+0x393>
f0101cdb:	68 61 79 10 f0       	push   $0xf0107961
f0101ce0:	68 57 78 10 f0       	push   $0xf0107857
f0101ce5:	68 10 03 00 00       	push   $0x310
f0101cea:	68 31 78 10 f0       	push   $0xf0107831
f0101cef:	e8 74 e3 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cf4:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101cf7:	74 05                	je     f0101cfe <mem_init+0x39d>
f0101cf9:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101cfc:	75 19                	jne    f0101d17 <mem_init+0x3b6>
f0101cfe:	68 8c 70 10 f0       	push   $0xf010708c
f0101d03:	68 57 78 10 f0       	push   $0xf0107857
f0101d08:	68 11 03 00 00       	push   $0x311
f0101d0d:	68 31 78 10 f0       	push   $0xf0107831
f0101d12:	e8 51 e3 ff ff       	call   f0100068 <_panic>
	assert(!page_alloc(0));
f0101d17:	83 ec 0c             	sub    $0xc,%esp
f0101d1a:	6a 00                	push   $0x0
f0101d1c:	e8 e4 f8 ff ff       	call   f0101605 <page_alloc>
f0101d21:	83 c4 10             	add    $0x10,%esp
f0101d24:	85 c0                	test   %eax,%eax
f0101d26:	74 19                	je     f0101d41 <mem_init+0x3e0>
f0101d28:	68 ca 79 10 f0       	push   $0xf01079ca
f0101d2d:	68 57 78 10 f0       	push   $0xf0107857
f0101d32:	68 12 03 00 00       	push   $0x312
f0101d37:	68 31 78 10 f0       	push   $0xf0107831
f0101d3c:	e8 27 e3 ff ff       	call   f0100068 <_panic>
f0101d41:	89 f0                	mov    %esi,%eax
f0101d43:	2b 05 90 fe 2d f0    	sub    0xf02dfe90,%eax
f0101d49:	c1 f8 03             	sar    $0x3,%eax
f0101d4c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d4f:	89 c2                	mov    %eax,%edx
f0101d51:	c1 ea 0c             	shr    $0xc,%edx
f0101d54:	3b 15 88 fe 2d f0    	cmp    0xf02dfe88,%edx
f0101d5a:	72 12                	jb     f0101d6e <mem_init+0x40d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d5c:	50                   	push   %eax
f0101d5d:	68 c8 64 10 f0       	push   $0xf01064c8
f0101d62:	6a 58                	push   $0x58
f0101d64:	68 3d 78 10 f0       	push   $0xf010783d
f0101d69:	e8 fa e2 ff ff       	call   f0100068 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101d6e:	83 ec 04             	sub    $0x4,%esp
f0101d71:	68 00 10 00 00       	push   $0x1000
f0101d76:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101d78:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d7d:	50                   	push   %eax
f0101d7e:	e8 fe 39 00 00       	call   f0105781 <memset>
	page_free(pp0);
f0101d83:	89 34 24             	mov    %esi,(%esp)
f0101d86:	e8 04 f9 ff ff       	call   f010168f <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d8b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101d92:	e8 6e f8 ff ff       	call   f0101605 <page_alloc>
f0101d97:	83 c4 10             	add    $0x10,%esp
f0101d9a:	85 c0                	test   %eax,%eax
f0101d9c:	75 19                	jne    f0101db7 <mem_init+0x456>
f0101d9e:	68 d9 79 10 f0       	push   $0xf01079d9
f0101da3:	68 57 78 10 f0       	push   $0xf0107857
f0101da8:	68 17 03 00 00       	push   $0x317
f0101dad:	68 31 78 10 f0       	push   $0xf0107831
f0101db2:	e8 b1 e2 ff ff       	call   f0100068 <_panic>
	assert(pp && pp0 == pp);
f0101db7:	39 c6                	cmp    %eax,%esi
f0101db9:	74 19                	je     f0101dd4 <mem_init+0x473>
f0101dbb:	68 f7 79 10 f0       	push   $0xf01079f7
f0101dc0:	68 57 78 10 f0       	push   $0xf0107857
f0101dc5:	68 18 03 00 00       	push   $0x318
f0101dca:	68 31 78 10 f0       	push   $0xf0107831
f0101dcf:	e8 94 e2 ff ff       	call   f0100068 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101dd4:	89 f2                	mov    %esi,%edx
f0101dd6:	2b 15 90 fe 2d f0    	sub    0xf02dfe90,%edx
f0101ddc:	c1 fa 03             	sar    $0x3,%edx
f0101ddf:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101de2:	89 d0                	mov    %edx,%eax
f0101de4:	c1 e8 0c             	shr    $0xc,%eax
f0101de7:	3b 05 88 fe 2d f0    	cmp    0xf02dfe88,%eax
f0101ded:	72 12                	jb     f0101e01 <mem_init+0x4a0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101def:	52                   	push   %edx
f0101df0:	68 c8 64 10 f0       	push   $0xf01064c8
f0101df5:	6a 58                	push   $0x58
f0101df7:	68 3d 78 10 f0       	push   $0xf010783d
f0101dfc:	e8 67 e2 ff ff       	call   f0100068 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101e01:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101e08:	75 11                	jne    f0101e1b <mem_init+0x4ba>
f0101e0a:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101e10:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101e16:	80 38 00             	cmpb   $0x0,(%eax)
f0101e19:	74 19                	je     f0101e34 <mem_init+0x4d3>
f0101e1b:	68 07 7a 10 f0       	push   $0xf0107a07
f0101e20:	68 57 78 10 f0       	push   $0xf0107857
f0101e25:	68 1b 03 00 00       	push   $0x31b
f0101e2a:	68 31 78 10 f0       	push   $0xf0107831
f0101e2f:	e8 34 e2 ff ff       	call   f0100068 <_panic>
f0101e34:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101e35:	39 d0                	cmp    %edx,%eax
f0101e37:	75 dd                	jne    f0101e16 <mem_init+0x4b5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101e39:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101e3c:	89 15 30 f2 2d f0    	mov    %edx,0xf02df230

	// free the pages we took
	page_free(pp0);
f0101e42:	83 ec 0c             	sub    $0xc,%esp
f0101e45:	56                   	push   %esi
f0101e46:	e8 44 f8 ff ff       	call   f010168f <page_free>
	page_free(pp1);
f0101e4b:	89 3c 24             	mov    %edi,(%esp)
f0101e4e:	e8 3c f8 ff ff       	call   f010168f <page_free>
	page_free(pp2);
f0101e53:	83 c4 04             	add    $0x4,%esp
f0101e56:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e59:	e8 31 f8 ff ff       	call   f010168f <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e5e:	a1 30 f2 2d f0       	mov    0xf02df230,%eax
f0101e63:	83 c4 10             	add    $0x10,%esp
f0101e66:	85 c0                	test   %eax,%eax
f0101e68:	74 07                	je     f0101e71 <mem_init+0x510>
		--nfree;
f0101e6a:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e6b:	8b 00                	mov    (%eax),%eax
f0101e6d:	85 c0                	test   %eax,%eax
f0101e6f:	75 f9                	jne    f0101e6a <mem_init+0x509>
		--nfree;
	assert(nfree == 0);
f0101e71:	85 db                	test   %ebx,%ebx
f0101e73:	74 19                	je     f0101e8e <mem_init+0x52d>
f0101e75:	68 11 7a 10 f0       	push   $0xf0107a11
f0101e7a:	68 57 78 10 f0       	push   $0xf0107857
f0101e7f:	68 28 03 00 00       	push   $0x328
f0101e84:	68 31 78 10 f0       	push   $0xf0107831
f0101e89:	e8 da e1 ff ff       	call   f0100068 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101e8e:	83 ec 0c             	sub    $0xc,%esp
f0101e91:	68 ac 70 10 f0       	push   $0xf01070ac
f0101e96:	e8 f2 1e 00 00       	call   f0103d8d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101e9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ea2:	e8 5e f7 ff ff       	call   f0101605 <page_alloc>
f0101ea7:	89 c7                	mov    %eax,%edi
f0101ea9:	83 c4 10             	add    $0x10,%esp
f0101eac:	85 c0                	test   %eax,%eax
f0101eae:	75 19                	jne    f0101ec9 <mem_init+0x568>
f0101eb0:	68 1f 79 10 f0       	push   $0xf010791f
f0101eb5:	68 57 78 10 f0       	push   $0xf0107857
f0101eba:	68 8e 03 00 00       	push   $0x38e
f0101ebf:	68 31 78 10 f0       	push   $0xf0107831
f0101ec4:	e8 9f e1 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ec9:	83 ec 0c             	sub    $0xc,%esp
f0101ecc:	6a 00                	push   $0x0
f0101ece:	e8 32 f7 ff ff       	call   f0101605 <page_alloc>
f0101ed3:	89 c6                	mov    %eax,%esi
f0101ed5:	83 c4 10             	add    $0x10,%esp
f0101ed8:	85 c0                	test   %eax,%eax
f0101eda:	75 19                	jne    f0101ef5 <mem_init+0x594>
f0101edc:	68 35 79 10 f0       	push   $0xf0107935
f0101ee1:	68 57 78 10 f0       	push   $0xf0107857
f0101ee6:	68 8f 03 00 00       	push   $0x38f
f0101eeb:	68 31 78 10 f0       	push   $0xf0107831
f0101ef0:	e8 73 e1 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ef5:	83 ec 0c             	sub    $0xc,%esp
f0101ef8:	6a 00                	push   $0x0
f0101efa:	e8 06 f7 ff ff       	call   f0101605 <page_alloc>
f0101eff:	89 c3                	mov    %eax,%ebx
f0101f01:	83 c4 10             	add    $0x10,%esp
f0101f04:	85 c0                	test   %eax,%eax
f0101f06:	75 19                	jne    f0101f21 <mem_init+0x5c0>
f0101f08:	68 4b 79 10 f0       	push   $0xf010794b
f0101f0d:	68 57 78 10 f0       	push   $0xf0107857
f0101f12:	68 90 03 00 00       	push   $0x390
f0101f17:	68 31 78 10 f0       	push   $0xf0107831
f0101f1c:	e8 47 e1 ff ff       	call   f0100068 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f21:	39 f7                	cmp    %esi,%edi
f0101f23:	75 19                	jne    f0101f3e <mem_init+0x5dd>
f0101f25:	68 61 79 10 f0       	push   $0xf0107961
f0101f2a:	68 57 78 10 f0       	push   $0xf0107857
f0101f2f:	68 93 03 00 00       	push   $0x393
f0101f34:	68 31 78 10 f0       	push   $0xf0107831
f0101f39:	e8 2a e1 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f3e:	39 c6                	cmp    %eax,%esi
f0101f40:	74 04                	je     f0101f46 <mem_init+0x5e5>
f0101f42:	39 c7                	cmp    %eax,%edi
f0101f44:	75 19                	jne    f0101f5f <mem_init+0x5fe>
f0101f46:	68 8c 70 10 f0       	push   $0xf010708c
f0101f4b:	68 57 78 10 f0       	push   $0xf0107857
f0101f50:	68 94 03 00 00       	push   $0x394
f0101f55:	68 31 78 10 f0       	push   $0xf0107831
f0101f5a:	e8 09 e1 ff ff       	call   f0100068 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101f5f:	8b 0d 30 f2 2d f0    	mov    0xf02df230,%ecx
f0101f65:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101f68:	c7 05 30 f2 2d f0 00 	movl   $0x0,0xf02df230
f0101f6f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101f72:	83 ec 0c             	sub    $0xc,%esp
f0101f75:	6a 00                	push   $0x0
f0101f77:	e8 89 f6 ff ff       	call   f0101605 <page_alloc>
f0101f7c:	83 c4 10             	add    $0x10,%esp
f0101f7f:	85 c0                	test   %eax,%eax
f0101f81:	74 19                	je     f0101f9c <mem_init+0x63b>
f0101f83:	68 ca 79 10 f0       	push   $0xf01079ca
f0101f88:	68 57 78 10 f0       	push   $0xf0107857
f0101f8d:	68 9b 03 00 00       	push   $0x39b
f0101f92:	68 31 78 10 f0       	push   $0xf0107831
f0101f97:	e8 cc e0 ff ff       	call   f0100068 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101f9c:	83 ec 04             	sub    $0x4,%esp
f0101f9f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101fa2:	50                   	push   %eax
f0101fa3:	6a 00                	push   $0x0
f0101fa5:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0101fab:	e8 05 f8 ff ff       	call   f01017b5 <page_lookup>
f0101fb0:	83 c4 10             	add    $0x10,%esp
f0101fb3:	85 c0                	test   %eax,%eax
f0101fb5:	74 19                	je     f0101fd0 <mem_init+0x66f>
f0101fb7:	68 cc 70 10 f0       	push   $0xf01070cc
f0101fbc:	68 57 78 10 f0       	push   $0xf0107857
f0101fc1:	68 9e 03 00 00       	push   $0x39e
f0101fc6:	68 31 78 10 f0       	push   $0xf0107831
f0101fcb:	e8 98 e0 ff ff       	call   f0100068 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101fd0:	6a 02                	push   $0x2
f0101fd2:	6a 00                	push   $0x0
f0101fd4:	56                   	push   %esi
f0101fd5:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0101fdb:	e8 d1 f8 ff ff       	call   f01018b1 <page_insert>
f0101fe0:	83 c4 10             	add    $0x10,%esp
f0101fe3:	85 c0                	test   %eax,%eax
f0101fe5:	78 19                	js     f0102000 <mem_init+0x69f>
f0101fe7:	68 04 71 10 f0       	push   $0xf0107104
f0101fec:	68 57 78 10 f0       	push   $0xf0107857
f0101ff1:	68 a1 03 00 00       	push   $0x3a1
f0101ff6:	68 31 78 10 f0       	push   $0xf0107831
f0101ffb:	e8 68 e0 ff ff       	call   f0100068 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102000:	83 ec 0c             	sub    $0xc,%esp
f0102003:	57                   	push   %edi
f0102004:	e8 86 f6 ff ff       	call   f010168f <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102009:	6a 02                	push   $0x2
f010200b:	6a 00                	push   $0x0
f010200d:	56                   	push   %esi
f010200e:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0102014:	e8 98 f8 ff ff       	call   f01018b1 <page_insert>
f0102019:	83 c4 20             	add    $0x20,%esp
f010201c:	85 c0                	test   %eax,%eax
f010201e:	74 19                	je     f0102039 <mem_init+0x6d8>
f0102020:	68 34 71 10 f0       	push   $0xf0107134
f0102025:	68 57 78 10 f0       	push   $0xf0107857
f010202a:	68 a5 03 00 00       	push   $0x3a5
f010202f:	68 31 78 10 f0       	push   $0xf0107831
f0102034:	e8 2f e0 ff ff       	call   f0100068 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102039:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f010203e:	8b 08                	mov    (%eax),%ecx
f0102040:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102046:	89 fa                	mov    %edi,%edx
f0102048:	2b 15 90 fe 2d f0    	sub    0xf02dfe90,%edx
f010204e:	c1 fa 03             	sar    $0x3,%edx
f0102051:	c1 e2 0c             	shl    $0xc,%edx
f0102054:	39 d1                	cmp    %edx,%ecx
f0102056:	74 19                	je     f0102071 <mem_init+0x710>
f0102058:	68 64 71 10 f0       	push   $0xf0107164
f010205d:	68 57 78 10 f0       	push   $0xf0107857
f0102062:	68 a6 03 00 00       	push   $0x3a6
f0102067:	68 31 78 10 f0       	push   $0xf0107831
f010206c:	e8 f7 df ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102071:	ba 00 00 00 00       	mov    $0x0,%edx
f0102076:	e8 64 f1 ff ff       	call   f01011df <check_va2pa>
f010207b:	89 f2                	mov    %esi,%edx
f010207d:	2b 15 90 fe 2d f0    	sub    0xf02dfe90,%edx
f0102083:	c1 fa 03             	sar    $0x3,%edx
f0102086:	c1 e2 0c             	shl    $0xc,%edx
f0102089:	39 d0                	cmp    %edx,%eax
f010208b:	74 19                	je     f01020a6 <mem_init+0x745>
f010208d:	68 8c 71 10 f0       	push   $0xf010718c
f0102092:	68 57 78 10 f0       	push   $0xf0107857
f0102097:	68 a7 03 00 00       	push   $0x3a7
f010209c:	68 31 78 10 f0       	push   $0xf0107831
f01020a1:	e8 c2 df ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 1);
f01020a6:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01020ab:	74 19                	je     f01020c6 <mem_init+0x765>
f01020ad:	68 1c 7a 10 f0       	push   $0xf0107a1c
f01020b2:	68 57 78 10 f0       	push   $0xf0107857
f01020b7:	68 a8 03 00 00       	push   $0x3a8
f01020bc:	68 31 78 10 f0       	push   $0xf0107831
f01020c1:	e8 a2 df ff ff       	call   f0100068 <_panic>
	assert(pp0->pp_ref == 1);
f01020c6:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01020cb:	74 19                	je     f01020e6 <mem_init+0x785>
f01020cd:	68 2d 7a 10 f0       	push   $0xf0107a2d
f01020d2:	68 57 78 10 f0       	push   $0xf0107857
f01020d7:	68 a9 03 00 00       	push   $0x3a9
f01020dc:	68 31 78 10 f0       	push   $0xf0107831
f01020e1:	e8 82 df ff ff       	call   f0100068 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020e6:	6a 02                	push   $0x2
f01020e8:	68 00 10 00 00       	push   $0x1000
f01020ed:	53                   	push   %ebx
f01020ee:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f01020f4:	e8 b8 f7 ff ff       	call   f01018b1 <page_insert>
f01020f9:	83 c4 10             	add    $0x10,%esp
f01020fc:	85 c0                	test   %eax,%eax
f01020fe:	74 19                	je     f0102119 <mem_init+0x7b8>
f0102100:	68 bc 71 10 f0       	push   $0xf01071bc
f0102105:	68 57 78 10 f0       	push   $0xf0107857
f010210a:	68 ac 03 00 00       	push   $0x3ac
f010210f:	68 31 78 10 f0       	push   $0xf0107831
f0102114:	e8 4f df ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102119:	ba 00 10 00 00       	mov    $0x1000,%edx
f010211e:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0102123:	e8 b7 f0 ff ff       	call   f01011df <check_va2pa>
f0102128:	89 da                	mov    %ebx,%edx
f010212a:	2b 15 90 fe 2d f0    	sub    0xf02dfe90,%edx
f0102130:	c1 fa 03             	sar    $0x3,%edx
f0102133:	c1 e2 0c             	shl    $0xc,%edx
f0102136:	39 d0                	cmp    %edx,%eax
f0102138:	74 19                	je     f0102153 <mem_init+0x7f2>
f010213a:	68 f8 71 10 f0       	push   $0xf01071f8
f010213f:	68 57 78 10 f0       	push   $0xf0107857
f0102144:	68 ad 03 00 00       	push   $0x3ad
f0102149:	68 31 78 10 f0       	push   $0xf0107831
f010214e:	e8 15 df ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f0102153:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102158:	74 19                	je     f0102173 <mem_init+0x812>
f010215a:	68 3e 7a 10 f0       	push   $0xf0107a3e
f010215f:	68 57 78 10 f0       	push   $0xf0107857
f0102164:	68 ae 03 00 00       	push   $0x3ae
f0102169:	68 31 78 10 f0       	push   $0xf0107831
f010216e:	e8 f5 de ff ff       	call   f0100068 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102173:	83 ec 0c             	sub    $0xc,%esp
f0102176:	6a 00                	push   $0x0
f0102178:	e8 88 f4 ff ff       	call   f0101605 <page_alloc>
f010217d:	83 c4 10             	add    $0x10,%esp
f0102180:	85 c0                	test   %eax,%eax
f0102182:	74 19                	je     f010219d <mem_init+0x83c>
f0102184:	68 ca 79 10 f0       	push   $0xf01079ca
f0102189:	68 57 78 10 f0       	push   $0xf0107857
f010218e:	68 b1 03 00 00       	push   $0x3b1
f0102193:	68 31 78 10 f0       	push   $0xf0107831
f0102198:	e8 cb de ff ff       	call   f0100068 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010219d:	6a 02                	push   $0x2
f010219f:	68 00 10 00 00       	push   $0x1000
f01021a4:	53                   	push   %ebx
f01021a5:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f01021ab:	e8 01 f7 ff ff       	call   f01018b1 <page_insert>
f01021b0:	83 c4 10             	add    $0x10,%esp
f01021b3:	85 c0                	test   %eax,%eax
f01021b5:	74 19                	je     f01021d0 <mem_init+0x86f>
f01021b7:	68 bc 71 10 f0       	push   $0xf01071bc
f01021bc:	68 57 78 10 f0       	push   $0xf0107857
f01021c1:	68 b4 03 00 00       	push   $0x3b4
f01021c6:	68 31 78 10 f0       	push   $0xf0107831
f01021cb:	e8 98 de ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021d0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021d5:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f01021da:	e8 00 f0 ff ff       	call   f01011df <check_va2pa>
f01021df:	89 da                	mov    %ebx,%edx
f01021e1:	2b 15 90 fe 2d f0    	sub    0xf02dfe90,%edx
f01021e7:	c1 fa 03             	sar    $0x3,%edx
f01021ea:	c1 e2 0c             	shl    $0xc,%edx
f01021ed:	39 d0                	cmp    %edx,%eax
f01021ef:	74 19                	je     f010220a <mem_init+0x8a9>
f01021f1:	68 f8 71 10 f0       	push   $0xf01071f8
f01021f6:	68 57 78 10 f0       	push   $0xf0107857
f01021fb:	68 b5 03 00 00       	push   $0x3b5
f0102200:	68 31 78 10 f0       	push   $0xf0107831
f0102205:	e8 5e de ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f010220a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010220f:	74 19                	je     f010222a <mem_init+0x8c9>
f0102211:	68 3e 7a 10 f0       	push   $0xf0107a3e
f0102216:	68 57 78 10 f0       	push   $0xf0107857
f010221b:	68 b6 03 00 00       	push   $0x3b6
f0102220:	68 31 78 10 f0       	push   $0xf0107831
f0102225:	e8 3e de ff ff       	call   f0100068 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010222a:	83 ec 0c             	sub    $0xc,%esp
f010222d:	6a 00                	push   $0x0
f010222f:	e8 d1 f3 ff ff       	call   f0101605 <page_alloc>
f0102234:	83 c4 10             	add    $0x10,%esp
f0102237:	85 c0                	test   %eax,%eax
f0102239:	74 19                	je     f0102254 <mem_init+0x8f3>
f010223b:	68 ca 79 10 f0       	push   $0xf01079ca
f0102240:	68 57 78 10 f0       	push   $0xf0107857
f0102245:	68 ba 03 00 00       	push   $0x3ba
f010224a:	68 31 78 10 f0       	push   $0xf0107831
f010224f:	e8 14 de ff ff       	call   f0100068 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102254:	8b 15 8c fe 2d f0    	mov    0xf02dfe8c,%edx
f010225a:	8b 02                	mov    (%edx),%eax
f010225c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102261:	89 c1                	mov    %eax,%ecx
f0102263:	c1 e9 0c             	shr    $0xc,%ecx
f0102266:	3b 0d 88 fe 2d f0    	cmp    0xf02dfe88,%ecx
f010226c:	72 15                	jb     f0102283 <mem_init+0x922>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010226e:	50                   	push   %eax
f010226f:	68 c8 64 10 f0       	push   $0xf01064c8
f0102274:	68 bd 03 00 00       	push   $0x3bd
f0102279:	68 31 78 10 f0       	push   $0xf0107831
f010227e:	e8 e5 dd ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f0102283:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102288:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010228b:	83 ec 04             	sub    $0x4,%esp
f010228e:	6a 00                	push   $0x0
f0102290:	68 00 10 00 00       	push   $0x1000
f0102295:	52                   	push   %edx
f0102296:	e8 32 f4 ff ff       	call   f01016cd <pgdir_walk>
f010229b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010229e:	83 c2 04             	add    $0x4,%edx
f01022a1:	83 c4 10             	add    $0x10,%esp
f01022a4:	39 d0                	cmp    %edx,%eax
f01022a6:	74 19                	je     f01022c1 <mem_init+0x960>
f01022a8:	68 28 72 10 f0       	push   $0xf0107228
f01022ad:	68 57 78 10 f0       	push   $0xf0107857
f01022b2:	68 be 03 00 00       	push   $0x3be
f01022b7:	68 31 78 10 f0       	push   $0xf0107831
f01022bc:	e8 a7 dd ff ff       	call   f0100068 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01022c1:	6a 06                	push   $0x6
f01022c3:	68 00 10 00 00       	push   $0x1000
f01022c8:	53                   	push   %ebx
f01022c9:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f01022cf:	e8 dd f5 ff ff       	call   f01018b1 <page_insert>
f01022d4:	83 c4 10             	add    $0x10,%esp
f01022d7:	85 c0                	test   %eax,%eax
f01022d9:	74 19                	je     f01022f4 <mem_init+0x993>
f01022db:	68 68 72 10 f0       	push   $0xf0107268
f01022e0:	68 57 78 10 f0       	push   $0xf0107857
f01022e5:	68 c1 03 00 00       	push   $0x3c1
f01022ea:	68 31 78 10 f0       	push   $0xf0107831
f01022ef:	e8 74 dd ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022f4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022f9:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f01022fe:	e8 dc ee ff ff       	call   f01011df <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102303:	89 da                	mov    %ebx,%edx
f0102305:	2b 15 90 fe 2d f0    	sub    0xf02dfe90,%edx
f010230b:	c1 fa 03             	sar    $0x3,%edx
f010230e:	c1 e2 0c             	shl    $0xc,%edx
f0102311:	39 d0                	cmp    %edx,%eax
f0102313:	74 19                	je     f010232e <mem_init+0x9cd>
f0102315:	68 f8 71 10 f0       	push   $0xf01071f8
f010231a:	68 57 78 10 f0       	push   $0xf0107857
f010231f:	68 c2 03 00 00       	push   $0x3c2
f0102324:	68 31 78 10 f0       	push   $0xf0107831
f0102329:	e8 3a dd ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f010232e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102333:	74 19                	je     f010234e <mem_init+0x9ed>
f0102335:	68 3e 7a 10 f0       	push   $0xf0107a3e
f010233a:	68 57 78 10 f0       	push   $0xf0107857
f010233f:	68 c3 03 00 00       	push   $0x3c3
f0102344:	68 31 78 10 f0       	push   $0xf0107831
f0102349:	e8 1a dd ff ff       	call   f0100068 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010234e:	83 ec 04             	sub    $0x4,%esp
f0102351:	6a 00                	push   $0x0
f0102353:	68 00 10 00 00       	push   $0x1000
f0102358:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f010235e:	e8 6a f3 ff ff       	call   f01016cd <pgdir_walk>
f0102363:	83 c4 10             	add    $0x10,%esp
f0102366:	f6 00 04             	testb  $0x4,(%eax)
f0102369:	75 19                	jne    f0102384 <mem_init+0xa23>
f010236b:	68 a8 72 10 f0       	push   $0xf01072a8
f0102370:	68 57 78 10 f0       	push   $0xf0107857
f0102375:	68 c4 03 00 00       	push   $0x3c4
f010237a:	68 31 78 10 f0       	push   $0xf0107831
f010237f:	e8 e4 dc ff ff       	call   f0100068 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102384:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0102389:	f6 00 04             	testb  $0x4,(%eax)
f010238c:	75 19                	jne    f01023a7 <mem_init+0xa46>
f010238e:	68 4f 7a 10 f0       	push   $0xf0107a4f
f0102393:	68 57 78 10 f0       	push   $0xf0107857
f0102398:	68 c5 03 00 00       	push   $0x3c5
f010239d:	68 31 78 10 f0       	push   $0xf0107831
f01023a2:	e8 c1 dc ff ff       	call   f0100068 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023a7:	6a 02                	push   $0x2
f01023a9:	68 00 10 00 00       	push   $0x1000
f01023ae:	53                   	push   %ebx
f01023af:	50                   	push   %eax
f01023b0:	e8 fc f4 ff ff       	call   f01018b1 <page_insert>
f01023b5:	83 c4 10             	add    $0x10,%esp
f01023b8:	85 c0                	test   %eax,%eax
f01023ba:	74 19                	je     f01023d5 <mem_init+0xa74>
f01023bc:	68 bc 71 10 f0       	push   $0xf01071bc
f01023c1:	68 57 78 10 f0       	push   $0xf0107857
f01023c6:	68 c8 03 00 00       	push   $0x3c8
f01023cb:	68 31 78 10 f0       	push   $0xf0107831
f01023d0:	e8 93 dc ff ff       	call   f0100068 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01023d5:	83 ec 04             	sub    $0x4,%esp
f01023d8:	6a 00                	push   $0x0
f01023da:	68 00 10 00 00       	push   $0x1000
f01023df:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f01023e5:	e8 e3 f2 ff ff       	call   f01016cd <pgdir_walk>
f01023ea:	83 c4 10             	add    $0x10,%esp
f01023ed:	f6 00 02             	testb  $0x2,(%eax)
f01023f0:	75 19                	jne    f010240b <mem_init+0xaaa>
f01023f2:	68 dc 72 10 f0       	push   $0xf01072dc
f01023f7:	68 57 78 10 f0       	push   $0xf0107857
f01023fc:	68 c9 03 00 00       	push   $0x3c9
f0102401:	68 31 78 10 f0       	push   $0xf0107831
f0102406:	e8 5d dc ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010240b:	83 ec 04             	sub    $0x4,%esp
f010240e:	6a 00                	push   $0x0
f0102410:	68 00 10 00 00       	push   $0x1000
f0102415:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f010241b:	e8 ad f2 ff ff       	call   f01016cd <pgdir_walk>
f0102420:	83 c4 10             	add    $0x10,%esp
f0102423:	f6 00 04             	testb  $0x4,(%eax)
f0102426:	74 19                	je     f0102441 <mem_init+0xae0>
f0102428:	68 10 73 10 f0       	push   $0xf0107310
f010242d:	68 57 78 10 f0       	push   $0xf0107857
f0102432:	68 ca 03 00 00       	push   $0x3ca
f0102437:	68 31 78 10 f0       	push   $0xf0107831
f010243c:	e8 27 dc ff ff       	call   f0100068 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102441:	6a 02                	push   $0x2
f0102443:	68 00 00 40 00       	push   $0x400000
f0102448:	57                   	push   %edi
f0102449:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f010244f:	e8 5d f4 ff ff       	call   f01018b1 <page_insert>
f0102454:	83 c4 10             	add    $0x10,%esp
f0102457:	85 c0                	test   %eax,%eax
f0102459:	78 19                	js     f0102474 <mem_init+0xb13>
f010245b:	68 48 73 10 f0       	push   $0xf0107348
f0102460:	68 57 78 10 f0       	push   $0xf0107857
f0102465:	68 cd 03 00 00       	push   $0x3cd
f010246a:	68 31 78 10 f0       	push   $0xf0107831
f010246f:	e8 f4 db ff ff       	call   f0100068 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102474:	6a 02                	push   $0x2
f0102476:	68 00 10 00 00       	push   $0x1000
f010247b:	56                   	push   %esi
f010247c:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0102482:	e8 2a f4 ff ff       	call   f01018b1 <page_insert>
f0102487:	83 c4 10             	add    $0x10,%esp
f010248a:	85 c0                	test   %eax,%eax
f010248c:	74 19                	je     f01024a7 <mem_init+0xb46>
f010248e:	68 80 73 10 f0       	push   $0xf0107380
f0102493:	68 57 78 10 f0       	push   $0xf0107857
f0102498:	68 d0 03 00 00       	push   $0x3d0
f010249d:	68 31 78 10 f0       	push   $0xf0107831
f01024a2:	e8 c1 db ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024a7:	83 ec 04             	sub    $0x4,%esp
f01024aa:	6a 00                	push   $0x0
f01024ac:	68 00 10 00 00       	push   $0x1000
f01024b1:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f01024b7:	e8 11 f2 ff ff       	call   f01016cd <pgdir_walk>
f01024bc:	83 c4 10             	add    $0x10,%esp
f01024bf:	f6 00 04             	testb  $0x4,(%eax)
f01024c2:	74 19                	je     f01024dd <mem_init+0xb7c>
f01024c4:	68 10 73 10 f0       	push   $0xf0107310
f01024c9:	68 57 78 10 f0       	push   $0xf0107857
f01024ce:	68 d1 03 00 00       	push   $0x3d1
f01024d3:	68 31 78 10 f0       	push   $0xf0107831
f01024d8:	e8 8b db ff ff       	call   f0100068 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01024dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01024e2:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f01024e7:	e8 f3 ec ff ff       	call   f01011df <check_va2pa>
f01024ec:	89 f2                	mov    %esi,%edx
f01024ee:	2b 15 90 fe 2d f0    	sub    0xf02dfe90,%edx
f01024f4:	c1 fa 03             	sar    $0x3,%edx
f01024f7:	c1 e2 0c             	shl    $0xc,%edx
f01024fa:	39 d0                	cmp    %edx,%eax
f01024fc:	74 19                	je     f0102517 <mem_init+0xbb6>
f01024fe:	68 bc 73 10 f0       	push   $0xf01073bc
f0102503:	68 57 78 10 f0       	push   $0xf0107857
f0102508:	68 d4 03 00 00       	push   $0x3d4
f010250d:	68 31 78 10 f0       	push   $0xf0107831
f0102512:	e8 51 db ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102517:	ba 00 10 00 00       	mov    $0x1000,%edx
f010251c:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0102521:	e8 b9 ec ff ff       	call   f01011df <check_va2pa>
f0102526:	89 f2                	mov    %esi,%edx
f0102528:	2b 15 90 fe 2d f0    	sub    0xf02dfe90,%edx
f010252e:	c1 fa 03             	sar    $0x3,%edx
f0102531:	c1 e2 0c             	shl    $0xc,%edx
f0102534:	39 d0                	cmp    %edx,%eax
f0102536:	74 19                	je     f0102551 <mem_init+0xbf0>
f0102538:	68 e8 73 10 f0       	push   $0xf01073e8
f010253d:	68 57 78 10 f0       	push   $0xf0107857
f0102542:	68 d5 03 00 00       	push   $0x3d5
f0102547:	68 31 78 10 f0       	push   $0xf0107831
f010254c:	e8 17 db ff ff       	call   f0100068 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102551:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102556:	74 19                	je     f0102571 <mem_init+0xc10>
f0102558:	68 65 7a 10 f0       	push   $0xf0107a65
f010255d:	68 57 78 10 f0       	push   $0xf0107857
f0102562:	68 d7 03 00 00       	push   $0x3d7
f0102567:	68 31 78 10 f0       	push   $0xf0107831
f010256c:	e8 f7 da ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f0102571:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102576:	74 19                	je     f0102591 <mem_init+0xc30>
f0102578:	68 76 7a 10 f0       	push   $0xf0107a76
f010257d:	68 57 78 10 f0       	push   $0xf0107857
f0102582:	68 d8 03 00 00       	push   $0x3d8
f0102587:	68 31 78 10 f0       	push   $0xf0107831
f010258c:	e8 d7 da ff ff       	call   f0100068 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102591:	83 ec 0c             	sub    $0xc,%esp
f0102594:	6a 00                	push   $0x0
f0102596:	e8 6a f0 ff ff       	call   f0101605 <page_alloc>
f010259b:	83 c4 10             	add    $0x10,%esp
f010259e:	85 c0                	test   %eax,%eax
f01025a0:	74 04                	je     f01025a6 <mem_init+0xc45>
f01025a2:	39 c3                	cmp    %eax,%ebx
f01025a4:	74 19                	je     f01025bf <mem_init+0xc5e>
f01025a6:	68 18 74 10 f0       	push   $0xf0107418
f01025ab:	68 57 78 10 f0       	push   $0xf0107857
f01025b0:	68 db 03 00 00       	push   $0x3db
f01025b5:	68 31 78 10 f0       	push   $0xf0107831
f01025ba:	e8 a9 da ff ff       	call   f0100068 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01025bf:	83 ec 08             	sub    $0x8,%esp
f01025c2:	6a 00                	push   $0x0
f01025c4:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f01025ca:	e8 95 f2 ff ff       	call   f0101864 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025cf:	ba 00 00 00 00       	mov    $0x0,%edx
f01025d4:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f01025d9:	e8 01 ec ff ff       	call   f01011df <check_va2pa>
f01025de:	83 c4 10             	add    $0x10,%esp
f01025e1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025e4:	74 19                	je     f01025ff <mem_init+0xc9e>
f01025e6:	68 3c 74 10 f0       	push   $0xf010743c
f01025eb:	68 57 78 10 f0       	push   $0xf0107857
f01025f0:	68 df 03 00 00       	push   $0x3df
f01025f5:	68 31 78 10 f0       	push   $0xf0107831
f01025fa:	e8 69 da ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025ff:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102604:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0102609:	e8 d1 eb ff ff       	call   f01011df <check_va2pa>
f010260e:	89 f2                	mov    %esi,%edx
f0102610:	2b 15 90 fe 2d f0    	sub    0xf02dfe90,%edx
f0102616:	c1 fa 03             	sar    $0x3,%edx
f0102619:	c1 e2 0c             	shl    $0xc,%edx
f010261c:	39 d0                	cmp    %edx,%eax
f010261e:	74 19                	je     f0102639 <mem_init+0xcd8>
f0102620:	68 e8 73 10 f0       	push   $0xf01073e8
f0102625:	68 57 78 10 f0       	push   $0xf0107857
f010262a:	68 e0 03 00 00       	push   $0x3e0
f010262f:	68 31 78 10 f0       	push   $0xf0107831
f0102634:	e8 2f da ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 1);
f0102639:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010263e:	74 19                	je     f0102659 <mem_init+0xcf8>
f0102640:	68 1c 7a 10 f0       	push   $0xf0107a1c
f0102645:	68 57 78 10 f0       	push   $0xf0107857
f010264a:	68 e1 03 00 00       	push   $0x3e1
f010264f:	68 31 78 10 f0       	push   $0xf0107831
f0102654:	e8 0f da ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f0102659:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010265e:	74 19                	je     f0102679 <mem_init+0xd18>
f0102660:	68 76 7a 10 f0       	push   $0xf0107a76
f0102665:	68 57 78 10 f0       	push   $0xf0107857
f010266a:	68 e2 03 00 00       	push   $0x3e2
f010266f:	68 31 78 10 f0       	push   $0xf0107831
f0102674:	e8 ef d9 ff ff       	call   f0100068 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102679:	83 ec 08             	sub    $0x8,%esp
f010267c:	68 00 10 00 00       	push   $0x1000
f0102681:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0102687:	e8 d8 f1 ff ff       	call   f0101864 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010268c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102691:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0102696:	e8 44 eb ff ff       	call   f01011df <check_va2pa>
f010269b:	83 c4 10             	add    $0x10,%esp
f010269e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026a1:	74 19                	je     f01026bc <mem_init+0xd5b>
f01026a3:	68 3c 74 10 f0       	push   $0xf010743c
f01026a8:	68 57 78 10 f0       	push   $0xf0107857
f01026ad:	68 e6 03 00 00       	push   $0x3e6
f01026b2:	68 31 78 10 f0       	push   $0xf0107831
f01026b7:	e8 ac d9 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01026bc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01026c1:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f01026c6:	e8 14 eb ff ff       	call   f01011df <check_va2pa>
f01026cb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026ce:	74 19                	je     f01026e9 <mem_init+0xd88>
f01026d0:	68 60 74 10 f0       	push   $0xf0107460
f01026d5:	68 57 78 10 f0       	push   $0xf0107857
f01026da:	68 e7 03 00 00       	push   $0x3e7
f01026df:	68 31 78 10 f0       	push   $0xf0107831
f01026e4:	e8 7f d9 ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 0);
f01026e9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026ee:	74 19                	je     f0102709 <mem_init+0xda8>
f01026f0:	68 87 7a 10 f0       	push   $0xf0107a87
f01026f5:	68 57 78 10 f0       	push   $0xf0107857
f01026fa:	68 e8 03 00 00       	push   $0x3e8
f01026ff:	68 31 78 10 f0       	push   $0xf0107831
f0102704:	e8 5f d9 ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f0102709:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010270e:	74 19                	je     f0102729 <mem_init+0xdc8>
f0102710:	68 76 7a 10 f0       	push   $0xf0107a76
f0102715:	68 57 78 10 f0       	push   $0xf0107857
f010271a:	68 e9 03 00 00       	push   $0x3e9
f010271f:	68 31 78 10 f0       	push   $0xf0107831
f0102724:	e8 3f d9 ff ff       	call   f0100068 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102729:	83 ec 0c             	sub    $0xc,%esp
f010272c:	6a 00                	push   $0x0
f010272e:	e8 d2 ee ff ff       	call   f0101605 <page_alloc>
f0102733:	83 c4 10             	add    $0x10,%esp
f0102736:	85 c0                	test   %eax,%eax
f0102738:	74 04                	je     f010273e <mem_init+0xddd>
f010273a:	39 c6                	cmp    %eax,%esi
f010273c:	74 19                	je     f0102757 <mem_init+0xdf6>
f010273e:	68 88 74 10 f0       	push   $0xf0107488
f0102743:	68 57 78 10 f0       	push   $0xf0107857
f0102748:	68 ec 03 00 00       	push   $0x3ec
f010274d:	68 31 78 10 f0       	push   $0xf0107831
f0102752:	e8 11 d9 ff ff       	call   f0100068 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102757:	83 ec 0c             	sub    $0xc,%esp
f010275a:	6a 00                	push   $0x0
f010275c:	e8 a4 ee ff ff       	call   f0101605 <page_alloc>
f0102761:	83 c4 10             	add    $0x10,%esp
f0102764:	85 c0                	test   %eax,%eax
f0102766:	74 19                	je     f0102781 <mem_init+0xe20>
f0102768:	68 ca 79 10 f0       	push   $0xf01079ca
f010276d:	68 57 78 10 f0       	push   $0xf0107857
f0102772:	68 ef 03 00 00       	push   $0x3ef
f0102777:	68 31 78 10 f0       	push   $0xf0107831
f010277c:	e8 e7 d8 ff ff       	call   f0100068 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102781:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0102786:	8b 08                	mov    (%eax),%ecx
f0102788:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010278e:	89 fa                	mov    %edi,%edx
f0102790:	2b 15 90 fe 2d f0    	sub    0xf02dfe90,%edx
f0102796:	c1 fa 03             	sar    $0x3,%edx
f0102799:	c1 e2 0c             	shl    $0xc,%edx
f010279c:	39 d1                	cmp    %edx,%ecx
f010279e:	74 19                	je     f01027b9 <mem_init+0xe58>
f01027a0:	68 64 71 10 f0       	push   $0xf0107164
f01027a5:	68 57 78 10 f0       	push   $0xf0107857
f01027aa:	68 f2 03 00 00       	push   $0x3f2
f01027af:	68 31 78 10 f0       	push   $0xf0107831
f01027b4:	e8 af d8 ff ff       	call   f0100068 <_panic>
	kern_pgdir[0] = 0;
f01027b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01027bf:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01027c4:	74 19                	je     f01027df <mem_init+0xe7e>
f01027c6:	68 2d 7a 10 f0       	push   $0xf0107a2d
f01027cb:	68 57 78 10 f0       	push   $0xf0107857
f01027d0:	68 f4 03 00 00       	push   $0x3f4
f01027d5:	68 31 78 10 f0       	push   $0xf0107831
f01027da:	e8 89 d8 ff ff       	call   f0100068 <_panic>
	pp0->pp_ref = 0;

	kern_pgdir[PDX(va)] = 0;
f01027df:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f01027e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01027ea:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
f01027f0:	89 f8                	mov    %edi,%eax
f01027f2:	2b 05 90 fe 2d f0    	sub    0xf02dfe90,%eax
f01027f8:	c1 f8 03             	sar    $0x3,%eax
f01027fb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027fe:	89 c2                	mov    %eax,%edx
f0102800:	c1 ea 0c             	shr    $0xc,%edx
f0102803:	3b 15 88 fe 2d f0    	cmp    0xf02dfe88,%edx
f0102809:	72 12                	jb     f010281d <mem_init+0xebc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010280b:	50                   	push   %eax
f010280c:	68 c8 64 10 f0       	push   $0xf01064c8
f0102811:	6a 58                	push   $0x58
f0102813:	68 3d 78 10 f0       	push   $0xf010783d
f0102818:	e8 4b d8 ff ff       	call   f0100068 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010281d:	83 ec 04             	sub    $0x4,%esp
f0102820:	68 00 10 00 00       	push   $0x1000
f0102825:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f010282a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010282f:	50                   	push   %eax
f0102830:	e8 4c 2f 00 00       	call   f0105781 <memset>
	page_free(pp0);
f0102835:	89 3c 24             	mov    %edi,(%esp)
f0102838:	e8 52 ee ff ff       	call   f010168f <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010283d:	83 c4 0c             	add    $0xc,%esp
f0102840:	6a 01                	push   $0x1
f0102842:	6a 00                	push   $0x0
f0102844:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f010284a:	e8 7e ee ff ff       	call   f01016cd <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010284f:	89 fa                	mov    %edi,%edx
f0102851:	2b 15 90 fe 2d f0    	sub    0xf02dfe90,%edx
f0102857:	c1 fa 03             	sar    $0x3,%edx
f010285a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010285d:	89 d0                	mov    %edx,%eax
f010285f:	c1 e8 0c             	shr    $0xc,%eax
f0102862:	83 c4 10             	add    $0x10,%esp
f0102865:	3b 05 88 fe 2d f0    	cmp    0xf02dfe88,%eax
f010286b:	72 12                	jb     f010287f <mem_init+0xf1e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010286d:	52                   	push   %edx
f010286e:	68 c8 64 10 f0       	push   $0xf01064c8
f0102873:	6a 58                	push   $0x58
f0102875:	68 3d 78 10 f0       	push   $0xf010783d
f010287a:	e8 e9 d7 ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f010287f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102885:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102888:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f010288f:	75 11                	jne    f01028a2 <mem_init+0xf41>
f0102891:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102897:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010289d:	f6 00 01             	testb  $0x1,(%eax)
f01028a0:	74 19                	je     f01028bb <mem_init+0xf5a>
f01028a2:	68 98 7a 10 f0       	push   $0xf0107a98
f01028a7:	68 57 78 10 f0       	push   $0xf0107857
f01028ac:	68 00 04 00 00       	push   $0x400
f01028b1:	68 31 78 10 f0       	push   $0xf0107831
f01028b6:	e8 ad d7 ff ff       	call   f0100068 <_panic>
f01028bb:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01028be:	39 d0                	cmp    %edx,%eax
f01028c0:	75 db                	jne    f010289d <mem_init+0xf3c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01028c2:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f01028c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01028cd:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01028d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028d6:	a3 30 f2 2d f0       	mov    %eax,0xf02df230

	// free the pages we took
	page_free(pp0);
f01028db:	83 ec 0c             	sub    $0xc,%esp
f01028de:	57                   	push   %edi
f01028df:	e8 ab ed ff ff       	call   f010168f <page_free>
	page_free(pp1);
f01028e4:	89 34 24             	mov    %esi,(%esp)
f01028e7:	e8 a3 ed ff ff       	call   f010168f <page_free>
	page_free(pp2);
f01028ec:	89 1c 24             	mov    %ebx,(%esp)
f01028ef:	e8 9b ed ff ff       	call   f010168f <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01028f4:	83 c4 08             	add    $0x8,%esp
f01028f7:	68 01 10 00 00       	push   $0x1001
f01028fc:	6a 00                	push   $0x0
f01028fe:	e8 17 f0 ff ff       	call   f010191a <mmio_map_region>
f0102903:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102905:	83 c4 08             	add    $0x8,%esp
f0102908:	68 00 10 00 00       	push   $0x1000
f010290d:	6a 00                	push   $0x0
f010290f:	e8 06 f0 ff ff       	call   f010191a <mmio_map_region>
f0102914:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102916:	83 c4 10             	add    $0x10,%esp
f0102919:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010291f:	76 0d                	jbe    f010292e <mem_init+0xfcd>
f0102921:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102927:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010292c:	76 19                	jbe    f0102947 <mem_init+0xfe6>
f010292e:	68 ac 74 10 f0       	push   $0xf01074ac
f0102933:	68 57 78 10 f0       	push   $0xf0107857
f0102938:	68 10 04 00 00       	push   $0x410
f010293d:	68 31 78 10 f0       	push   $0xf0107831
f0102942:	e8 21 d7 ff ff       	call   f0100068 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102947:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010294d:	76 0e                	jbe    f010295d <mem_init+0xffc>
f010294f:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102955:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010295b:	76 19                	jbe    f0102976 <mem_init+0x1015>
f010295d:	68 d4 74 10 f0       	push   $0xf01074d4
f0102962:	68 57 78 10 f0       	push   $0xf0107857
f0102967:	68 11 04 00 00       	push   $0x411
f010296c:	68 31 78 10 f0       	push   $0xf0107831
f0102971:	e8 f2 d6 ff ff       	call   f0100068 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102976:	89 da                	mov    %ebx,%edx
f0102978:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010297a:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102980:	74 19                	je     f010299b <mem_init+0x103a>
f0102982:	68 fc 74 10 f0       	push   $0xf01074fc
f0102987:	68 57 78 10 f0       	push   $0xf0107857
f010298c:	68 13 04 00 00       	push   $0x413
f0102991:	68 31 78 10 f0       	push   $0xf0107831
f0102996:	e8 cd d6 ff ff       	call   f0100068 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010299b:	39 c6                	cmp    %eax,%esi
f010299d:	73 19                	jae    f01029b8 <mem_init+0x1057>
f010299f:	68 af 7a 10 f0       	push   $0xf0107aaf
f01029a4:	68 57 78 10 f0       	push   $0xf0107857
f01029a9:	68 15 04 00 00       	push   $0x415
f01029ae:	68 31 78 10 f0       	push   $0xf0107831
f01029b3:	e8 b0 d6 ff ff       	call   f0100068 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01029b8:	89 da                	mov    %ebx,%edx
f01029ba:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f01029bf:	e8 1b e8 ff ff       	call   f01011df <check_va2pa>
f01029c4:	85 c0                	test   %eax,%eax
f01029c6:	74 19                	je     f01029e1 <mem_init+0x1080>
f01029c8:	68 24 75 10 f0       	push   $0xf0107524
f01029cd:	68 57 78 10 f0       	push   $0xf0107857
f01029d2:	68 17 04 00 00       	push   $0x417
f01029d7:	68 31 78 10 f0       	push   $0xf0107831
f01029dc:	e8 87 d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01029e1:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
f01029e7:	89 fa                	mov    %edi,%edx
f01029e9:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f01029ee:	e8 ec e7 ff ff       	call   f01011df <check_va2pa>
f01029f3:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01029f8:	74 19                	je     f0102a13 <mem_init+0x10b2>
f01029fa:	68 48 75 10 f0       	push   $0xf0107548
f01029ff:	68 57 78 10 f0       	push   $0xf0107857
f0102a04:	68 18 04 00 00       	push   $0x418
f0102a09:	68 31 78 10 f0       	push   $0xf0107831
f0102a0e:	e8 55 d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102a13:	89 f2                	mov    %esi,%edx
f0102a15:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0102a1a:	e8 c0 e7 ff ff       	call   f01011df <check_va2pa>
f0102a1f:	85 c0                	test   %eax,%eax
f0102a21:	74 19                	je     f0102a3c <mem_init+0x10db>
f0102a23:	68 78 75 10 f0       	push   $0xf0107578
f0102a28:	68 57 78 10 f0       	push   $0xf0107857
f0102a2d:	68 19 04 00 00       	push   $0x419
f0102a32:	68 31 78 10 f0       	push   $0xf0107831
f0102a37:	e8 2c d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a3c:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102a42:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0102a47:	e8 93 e7 ff ff       	call   f01011df <check_va2pa>
f0102a4c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a4f:	74 19                	je     f0102a6a <mem_init+0x1109>
f0102a51:	68 9c 75 10 f0       	push   $0xf010759c
f0102a56:	68 57 78 10 f0       	push   $0xf0107857
f0102a5b:	68 1a 04 00 00       	push   $0x41a
f0102a60:	68 31 78 10 f0       	push   $0xf0107831
f0102a65:	e8 fe d5 ff ff       	call   f0100068 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102a6a:	83 ec 04             	sub    $0x4,%esp
f0102a6d:	6a 00                	push   $0x0
f0102a6f:	53                   	push   %ebx
f0102a70:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0102a76:	e8 52 ec ff ff       	call   f01016cd <pgdir_walk>
f0102a7b:	83 c4 10             	add    $0x10,%esp
f0102a7e:	f6 00 1a             	testb  $0x1a,(%eax)
f0102a81:	75 19                	jne    f0102a9c <mem_init+0x113b>
f0102a83:	68 c8 75 10 f0       	push   $0xf01075c8
f0102a88:	68 57 78 10 f0       	push   $0xf0107857
f0102a8d:	68 1c 04 00 00       	push   $0x41c
f0102a92:	68 31 78 10 f0       	push   $0xf0107831
f0102a97:	e8 cc d5 ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a9c:	83 ec 04             	sub    $0x4,%esp
f0102a9f:	6a 00                	push   $0x0
f0102aa1:	53                   	push   %ebx
f0102aa2:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0102aa8:	e8 20 ec ff ff       	call   f01016cd <pgdir_walk>
f0102aad:	83 c4 10             	add    $0x10,%esp
f0102ab0:	f6 00 04             	testb  $0x4,(%eax)
f0102ab3:	74 19                	je     f0102ace <mem_init+0x116d>
f0102ab5:	68 0c 76 10 f0       	push   $0xf010760c
f0102aba:	68 57 78 10 f0       	push   $0xf0107857
f0102abf:	68 1d 04 00 00       	push   $0x41d
f0102ac4:	68 31 78 10 f0       	push   $0xf0107831
f0102ac9:	e8 9a d5 ff ff       	call   f0100068 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102ace:	83 ec 04             	sub    $0x4,%esp
f0102ad1:	6a 00                	push   $0x0
f0102ad3:	53                   	push   %ebx
f0102ad4:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0102ada:	e8 ee eb ff ff       	call   f01016cd <pgdir_walk>
f0102adf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102ae5:	83 c4 0c             	add    $0xc,%esp
f0102ae8:	6a 00                	push   $0x0
f0102aea:	57                   	push   %edi
f0102aeb:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0102af1:	e8 d7 eb ff ff       	call   f01016cd <pgdir_walk>
f0102af6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102afc:	83 c4 0c             	add    $0xc,%esp
f0102aff:	6a 00                	push   $0x0
f0102b01:	56                   	push   %esi
f0102b02:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0102b08:	e8 c0 eb ff ff       	call   f01016cd <pgdir_walk>
f0102b0d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102b13:	c7 04 24 c1 7a 10 f0 	movl   $0xf0107ac1,(%esp)
f0102b1a:	e8 6e 12 00 00       	call   f0103d8d <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102b1f:	a1 90 fe 2d f0       	mov    0xf02dfe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b24:	83 c4 10             	add    $0x10,%esp
f0102b27:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b2c:	77 15                	ja     f0102b43 <mem_init+0x11e2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b2e:	50                   	push   %eax
f0102b2f:	68 a4 64 10 f0       	push   $0xf01064a4
f0102b34:	68 b9 00 00 00       	push   $0xb9
f0102b39:	68 31 78 10 f0       	push   $0xf0107831
f0102b3e:	e8 25 d5 ff ff       	call   f0100068 <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102b43:	8b 15 88 fe 2d f0    	mov    0xf02dfe88,%edx
f0102b49:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102b50:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102b53:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102b59:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102b5b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b60:	50                   	push   %eax
f0102b61:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102b66:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0102b6b:	e8 f4 eb ff ff       	call   f0101764 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    boot_map_region(kern_pgdir,
f0102b70:	a1 3c f2 2d f0       	mov    0xf02df23c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b75:	83 c4 10             	add    $0x10,%esp
f0102b78:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b7d:	77 15                	ja     f0102b94 <mem_init+0x1233>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b7f:	50                   	push   %eax
f0102b80:	68 a4 64 10 f0       	push   $0xf01064a4
f0102b85:	68 c6 00 00 00       	push   $0xc6
f0102b8a:	68 31 78 10 f0       	push   $0xf0107831
f0102b8f:	e8 d4 d4 ff ff       	call   f0100068 <_panic>
f0102b94:	83 ec 08             	sub    $0x8,%esp
f0102b97:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102b99:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b9e:	50                   	push   %eax
f0102b9f:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102ba4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102ba9:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0102bae:	e8 b1 eb ff ff       	call   f0101764 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bb3:	83 c4 10             	add    $0x10,%esp
f0102bb6:	b8 00 e0 11 f0       	mov    $0xf011e000,%eax
f0102bbb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bc0:	77 15                	ja     f0102bd7 <mem_init+0x1276>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bc2:	50                   	push   %eax
f0102bc3:	68 a4 64 10 f0       	push   $0xf01064a4
f0102bc8:	68 d7 00 00 00       	push   $0xd7
f0102bcd:	68 31 78 10 f0       	push   $0xf0107831
f0102bd2:	e8 91 d4 ff ff       	call   f0100068 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102bd7:	83 ec 08             	sub    $0x8,%esp
f0102bda:	6a 02                	push   $0x2
f0102bdc:	68 00 e0 11 00       	push   $0x11e000
f0102be1:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102be6:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102beb:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0102bf0:	e8 6f eb ff ff       	call   f0101764 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102bf5:	83 c4 08             	add    $0x8,%esp
f0102bf8:	6a 02                	push   $0x2
f0102bfa:	6a 00                	push   $0x0
f0102bfc:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102c01:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102c06:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0102c0b:	e8 54 eb ff ff       	call   f0101764 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c10:	83 c4 10             	add    $0x10,%esp
f0102c13:	b8 00 10 2e f0       	mov    $0xf02e1000,%eax
f0102c18:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c1d:	0f 87 60 06 00 00    	ja     f0103283 <mem_init+0x1922>
f0102c23:	eb 0c                	jmp    f0102c31 <mem_init+0x12d0>
f0102c25:	89 d8                	mov    %ebx,%eax
f0102c27:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102c2d:	77 1c                	ja     f0102c4b <mem_init+0x12ea>
f0102c2f:	eb 05                	jmp    f0102c36 <mem_init+0x12d5>
	//
	// LAB 4: Your code here:
    
    int cpu_id;
    for (cpu_id = 0; cpu_id < NCPU; cpu_id++) {
        boot_map_region(kern_pgdir,
f0102c31:	b8 00 10 2e f0       	mov    $0xf02e1000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c36:	50                   	push   %eax
f0102c37:	68 a4 64 10 f0       	push   $0xf01064a4
f0102c3c:	68 24 01 00 00       	push   $0x124
f0102c41:	68 31 78 10 f0       	push   $0xf0107831
f0102c46:	e8 1d d4 ff ff       	call   f0100068 <_panic>
f0102c4b:	83 ec 08             	sub    $0x8,%esp
f0102c4e:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f0102c50:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102c56:	50                   	push   %eax
f0102c57:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102c5c:	89 f2                	mov    %esi,%edx
f0102c5e:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0102c63:	e8 fc ea ff ff       	call   f0101764 <boot_map_region>
f0102c68:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102c6e:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
    
    int cpu_id;
    for (cpu_id = 0; cpu_id < NCPU; cpu_id++) {
f0102c74:	83 c4 10             	add    $0x10,%esp
f0102c77:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102c7d:	75 a6                	jne    f0102c25 <mem_init+0x12c4>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102c7f:	8b 35 8c fe 2d f0    	mov    0xf02dfe8c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102c85:	a1 88 fe 2d f0       	mov    0xf02dfe88,%eax
f0102c8a:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102c91:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102c97:	74 63                	je     f0102cfc <mem_init+0x139b>
f0102c99:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102c9e:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102ca4:	89 f0                	mov    %esi,%eax
f0102ca6:	e8 34 e5 ff ff       	call   f01011df <check_va2pa>
f0102cab:	8b 15 90 fe 2d f0    	mov    0xf02dfe90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cb1:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102cb7:	77 15                	ja     f0102cce <mem_init+0x136d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cb9:	52                   	push   %edx
f0102cba:	68 a4 64 10 f0       	push   $0xf01064a4
f0102cbf:	68 40 03 00 00       	push   $0x340
f0102cc4:	68 31 78 10 f0       	push   $0xf0107831
f0102cc9:	e8 9a d3 ff ff       	call   f0100068 <_panic>
f0102cce:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0102cd5:	39 d0                	cmp    %edx,%eax
f0102cd7:	74 19                	je     f0102cf2 <mem_init+0x1391>
f0102cd9:	68 40 76 10 f0       	push   $0xf0107640
f0102cde:	68 57 78 10 f0       	push   $0xf0107857
f0102ce3:	68 40 03 00 00       	push   $0x340
f0102ce8:	68 31 78 10 f0       	push   $0xf0107831
f0102ced:	e8 76 d3 ff ff       	call   f0100068 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102cf2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102cf8:	39 df                	cmp    %ebx,%edi
f0102cfa:	77 a2                	ja     f0102c9e <mem_init+0x133d>
f0102cfc:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102d01:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
f0102d07:	89 f0                	mov    %esi,%eax
f0102d09:	e8 d1 e4 ff ff       	call   f01011df <check_va2pa>
f0102d0e:	8b 15 3c f2 2d f0    	mov    0xf02df23c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d14:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d1a:	77 15                	ja     f0102d31 <mem_init+0x13d0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d1c:	52                   	push   %edx
f0102d1d:	68 a4 64 10 f0       	push   $0xf01064a4
f0102d22:	68 45 03 00 00       	push   $0x345
f0102d27:	68 31 78 10 f0       	push   $0xf0107831
f0102d2c:	e8 37 d3 ff ff       	call   f0100068 <_panic>
f0102d31:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0102d38:	39 d0                	cmp    %edx,%eax
f0102d3a:	74 19                	je     f0102d55 <mem_init+0x13f4>
f0102d3c:	68 74 76 10 f0       	push   $0xf0107674
f0102d41:	68 57 78 10 f0       	push   $0xf0107857
f0102d46:	68 45 03 00 00       	push   $0x345
f0102d4b:	68 31 78 10 f0       	push   $0xf0107831
f0102d50:	e8 13 d3 ff ff       	call   f0100068 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102d55:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d5b:	81 fb 00 f0 01 00    	cmp    $0x1f000,%ebx
f0102d61:	75 9e                	jne    f0102d01 <mem_init+0x13a0>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d63:	a1 88 fe 2d f0       	mov    0xf02dfe88,%eax
f0102d68:	c1 e0 0c             	shl    $0xc,%eax
f0102d6b:	74 41                	je     f0102dae <mem_init+0x144d>
f0102d6d:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102d72:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102d78:	89 f0                	mov    %esi,%eax
f0102d7a:	e8 60 e4 ff ff       	call   f01011df <check_va2pa>
f0102d7f:	39 c3                	cmp    %eax,%ebx
f0102d81:	74 19                	je     f0102d9c <mem_init+0x143b>
f0102d83:	68 a8 76 10 f0       	push   $0xf01076a8
f0102d88:	68 57 78 10 f0       	push   $0xf0107857
f0102d8d:	68 49 03 00 00       	push   $0x349
f0102d92:	68 31 78 10 f0       	push   $0xf0107831
f0102d97:	e8 cc d2 ff ff       	call   f0100068 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d9c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102da2:	a1 88 fe 2d f0       	mov    0xf02dfe88,%eax
f0102da7:	c1 e0 0c             	shl    $0xc,%eax
f0102daa:	39 c3                	cmp    %eax,%ebx
f0102dac:	72 c4                	jb     f0102d72 <mem_init+0x1411>
f0102dae:	c7 45 d0 00 10 2e f0 	movl   $0xf02e1000,-0x30(%ebp)
f0102db5:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0102dba:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102dbd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	return (physaddr_t)kva - KERNBASE;
f0102dc0:	89 de                	mov    %ebx,%esi
f0102dc2:	81 c6 00 00 00 10    	add    $0x10000000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102dc8:	8d 97 00 80 00 00    	lea    0x8000(%edi),%edx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102dce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102dd1:	e8 09 e4 ff ff       	call   f01011df <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dd6:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102ddd:	77 15                	ja     f0102df4 <mem_init+0x1493>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ddf:	53                   	push   %ebx
f0102de0:	68 a4 64 10 f0       	push   $0xf01064a4
f0102de5:	68 51 03 00 00       	push   $0x351
f0102dea:	68 31 78 10 f0       	push   $0xf0107831
f0102def:	e8 74 d2 ff ff       	call   f0100068 <_panic>

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102df4:	bb 00 00 00 00       	mov    $0x0,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102df9:	8d 97 00 80 00 00    	lea    0x8000(%edi),%edx
f0102dff:	89 7d c8             	mov    %edi,-0x38(%ebp)
f0102e02:	89 d7                	mov    %edx,%edi
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e04:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102e07:	39 d0                	cmp    %edx,%eax
f0102e09:	74 19                	je     f0102e24 <mem_init+0x14c3>
f0102e0b:	68 d0 76 10 f0       	push   $0xf01076d0
f0102e10:	68 57 78 10 f0       	push   $0xf0107857
f0102e15:	68 51 03 00 00       	push   $0x351
f0102e1a:	68 31 78 10 f0       	push   $0xf0107831
f0102e1f:	e8 44 d2 ff ff       	call   f0100068 <_panic>

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102e24:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e2a:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102e30:	0f 85 7d 04 00 00    	jne    f01032b3 <mem_init+0x1952>
f0102e36:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102e39:	66 bb 00 00          	mov    $0x0,%bx
f0102e3d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102e40:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102e43:	89 f0                	mov    %esi,%eax
f0102e45:	e8 95 e3 ff ff       	call   f01011df <check_va2pa>
f0102e4a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102e4d:	74 19                	je     f0102e68 <mem_init+0x1507>
f0102e4f:	68 18 77 10 f0       	push   $0xf0107718
f0102e54:	68 57 78 10 f0       	push   $0xf0107857
f0102e59:	68 53 03 00 00       	push   $0x353
f0102e5e:	68 31 78 10 f0       	push   $0xf0107831
f0102e63:	e8 00 d2 ff ff       	call   f0100068 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102e68:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e6e:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102e74:	75 ca                	jne    f0102e40 <mem_init+0x14df>
f0102e76:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102e7d:	81 ef 00 00 01 00    	sub    $0x10000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102e83:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f0102e89:	0f 85 2e ff ff ff    	jne    f0102dbd <mem_init+0x145c>
f0102e8f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102e92:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102e97:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102e9d:	83 fa 04             	cmp    $0x4,%edx
f0102ea0:	77 1f                	ja     f0102ec1 <mem_init+0x1560>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102ea2:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102ea6:	75 7e                	jne    f0102f26 <mem_init+0x15c5>
f0102ea8:	68 da 7a 10 f0       	push   $0xf0107ada
f0102ead:	68 57 78 10 f0       	push   $0xf0107857
f0102eb2:	68 5e 03 00 00       	push   $0x35e
f0102eb7:	68 31 78 10 f0       	push   $0xf0107831
f0102ebc:	e8 a7 d1 ff ff       	call   f0100068 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102ec1:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ec6:	76 3f                	jbe    f0102f07 <mem_init+0x15a6>
				assert(pgdir[i] & PTE_P);
f0102ec8:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102ecb:	f6 c2 01             	test   $0x1,%dl
f0102ece:	75 19                	jne    f0102ee9 <mem_init+0x1588>
f0102ed0:	68 da 7a 10 f0       	push   $0xf0107ada
f0102ed5:	68 57 78 10 f0       	push   $0xf0107857
f0102eda:	68 62 03 00 00       	push   $0x362
f0102edf:	68 31 78 10 f0       	push   $0xf0107831
f0102ee4:	e8 7f d1 ff ff       	call   f0100068 <_panic>
				assert(pgdir[i] & PTE_W);
f0102ee9:	f6 c2 02             	test   $0x2,%dl
f0102eec:	75 38                	jne    f0102f26 <mem_init+0x15c5>
f0102eee:	68 eb 7a 10 f0       	push   $0xf0107aeb
f0102ef3:	68 57 78 10 f0       	push   $0xf0107857
f0102ef8:	68 63 03 00 00       	push   $0x363
f0102efd:	68 31 78 10 f0       	push   $0xf0107831
f0102f02:	e8 61 d1 ff ff       	call   f0100068 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102f07:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102f0b:	74 19                	je     f0102f26 <mem_init+0x15c5>
f0102f0d:	68 fc 7a 10 f0       	push   $0xf0107afc
f0102f12:	68 57 78 10 f0       	push   $0xf0107857
f0102f17:	68 65 03 00 00       	push   $0x365
f0102f1c:	68 31 78 10 f0       	push   $0xf0107831
f0102f21:	e8 42 d1 ff ff       	call   f0100068 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102f26:	40                   	inc    %eax
f0102f27:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102f2c:	0f 85 65 ff ff ff    	jne    f0102e97 <mem_init+0x1536>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102f32:	83 ec 0c             	sub    $0xc,%esp
f0102f35:	68 3c 77 10 f0       	push   $0xf010773c
f0102f3a:	e8 4e 0e 00 00       	call   f0103d8d <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102f3f:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f44:	83 c4 10             	add    $0x10,%esp
f0102f47:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f4c:	77 15                	ja     f0102f63 <mem_init+0x1602>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f4e:	50                   	push   %eax
f0102f4f:	68 a4 64 10 f0       	push   $0xf01064a4
f0102f54:	68 f9 00 00 00       	push   $0xf9
f0102f59:	68 31 78 10 f0       	push   $0xf0107831
f0102f5e:	e8 05 d1 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102f63:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102f68:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102f6b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f70:	e8 f3 e2 ff ff       	call   f0101268 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102f75:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102f78:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102f7d:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102f80:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102f83:	83 ec 0c             	sub    $0xc,%esp
f0102f86:	6a 00                	push   $0x0
f0102f88:	e8 78 e6 ff ff       	call   f0101605 <page_alloc>
f0102f8d:	89 c6                	mov    %eax,%esi
f0102f8f:	83 c4 10             	add    $0x10,%esp
f0102f92:	85 c0                	test   %eax,%eax
f0102f94:	75 19                	jne    f0102faf <mem_init+0x164e>
f0102f96:	68 1f 79 10 f0       	push   $0xf010791f
f0102f9b:	68 57 78 10 f0       	push   $0xf0107857
f0102fa0:	68 32 04 00 00       	push   $0x432
f0102fa5:	68 31 78 10 f0       	push   $0xf0107831
f0102faa:	e8 b9 d0 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0102faf:	83 ec 0c             	sub    $0xc,%esp
f0102fb2:	6a 00                	push   $0x0
f0102fb4:	e8 4c e6 ff ff       	call   f0101605 <page_alloc>
f0102fb9:	89 c7                	mov    %eax,%edi
f0102fbb:	83 c4 10             	add    $0x10,%esp
f0102fbe:	85 c0                	test   %eax,%eax
f0102fc0:	75 19                	jne    f0102fdb <mem_init+0x167a>
f0102fc2:	68 35 79 10 f0       	push   $0xf0107935
f0102fc7:	68 57 78 10 f0       	push   $0xf0107857
f0102fcc:	68 33 04 00 00       	push   $0x433
f0102fd1:	68 31 78 10 f0       	push   $0xf0107831
f0102fd6:	e8 8d d0 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0102fdb:	83 ec 0c             	sub    $0xc,%esp
f0102fde:	6a 00                	push   $0x0
f0102fe0:	e8 20 e6 ff ff       	call   f0101605 <page_alloc>
f0102fe5:	89 c3                	mov    %eax,%ebx
f0102fe7:	83 c4 10             	add    $0x10,%esp
f0102fea:	85 c0                	test   %eax,%eax
f0102fec:	75 19                	jne    f0103007 <mem_init+0x16a6>
f0102fee:	68 4b 79 10 f0       	push   $0xf010794b
f0102ff3:	68 57 78 10 f0       	push   $0xf0107857
f0102ff8:	68 34 04 00 00       	push   $0x434
f0102ffd:	68 31 78 10 f0       	push   $0xf0107831
f0103002:	e8 61 d0 ff ff       	call   f0100068 <_panic>
	page_free(pp0);
f0103007:	83 ec 0c             	sub    $0xc,%esp
f010300a:	56                   	push   %esi
f010300b:	e8 7f e6 ff ff       	call   f010168f <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103010:	89 f8                	mov    %edi,%eax
f0103012:	2b 05 90 fe 2d f0    	sub    0xf02dfe90,%eax
f0103018:	c1 f8 03             	sar    $0x3,%eax
f010301b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010301e:	89 c2                	mov    %eax,%edx
f0103020:	c1 ea 0c             	shr    $0xc,%edx
f0103023:	83 c4 10             	add    $0x10,%esp
f0103026:	3b 15 88 fe 2d f0    	cmp    0xf02dfe88,%edx
f010302c:	72 12                	jb     f0103040 <mem_init+0x16df>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010302e:	50                   	push   %eax
f010302f:	68 c8 64 10 f0       	push   $0xf01064c8
f0103034:	6a 58                	push   $0x58
f0103036:	68 3d 78 10 f0       	push   $0xf010783d
f010303b:	e8 28 d0 ff ff       	call   f0100068 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103040:	83 ec 04             	sub    $0x4,%esp
f0103043:	68 00 10 00 00       	push   $0x1000
f0103048:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010304a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010304f:	50                   	push   %eax
f0103050:	e8 2c 27 00 00       	call   f0105781 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103055:	89 d8                	mov    %ebx,%eax
f0103057:	2b 05 90 fe 2d f0    	sub    0xf02dfe90,%eax
f010305d:	c1 f8 03             	sar    $0x3,%eax
f0103060:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103063:	89 c2                	mov    %eax,%edx
f0103065:	c1 ea 0c             	shr    $0xc,%edx
f0103068:	83 c4 10             	add    $0x10,%esp
f010306b:	3b 15 88 fe 2d f0    	cmp    0xf02dfe88,%edx
f0103071:	72 12                	jb     f0103085 <mem_init+0x1724>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103073:	50                   	push   %eax
f0103074:	68 c8 64 10 f0       	push   $0xf01064c8
f0103079:	6a 58                	push   $0x58
f010307b:	68 3d 78 10 f0       	push   $0xf010783d
f0103080:	e8 e3 cf ff ff       	call   f0100068 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103085:	83 ec 04             	sub    $0x4,%esp
f0103088:	68 00 10 00 00       	push   $0x1000
f010308d:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f010308f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103094:	50                   	push   %eax
f0103095:	e8 e7 26 00 00       	call   f0105781 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010309a:	6a 02                	push   $0x2
f010309c:	68 00 10 00 00       	push   $0x1000
f01030a1:	57                   	push   %edi
f01030a2:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f01030a8:	e8 04 e8 ff ff       	call   f01018b1 <page_insert>
	assert(pp1->pp_ref == 1);
f01030ad:	83 c4 20             	add    $0x20,%esp
f01030b0:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01030b5:	74 19                	je     f01030d0 <mem_init+0x176f>
f01030b7:	68 1c 7a 10 f0       	push   $0xf0107a1c
f01030bc:	68 57 78 10 f0       	push   $0xf0107857
f01030c1:	68 39 04 00 00       	push   $0x439
f01030c6:	68 31 78 10 f0       	push   $0xf0107831
f01030cb:	e8 98 cf ff ff       	call   f0100068 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01030d0:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01030d7:	01 01 01 
f01030da:	74 19                	je     f01030f5 <mem_init+0x1794>
f01030dc:	68 5c 77 10 f0       	push   $0xf010775c
f01030e1:	68 57 78 10 f0       	push   $0xf0107857
f01030e6:	68 3a 04 00 00       	push   $0x43a
f01030eb:	68 31 78 10 f0       	push   $0xf0107831
f01030f0:	e8 73 cf ff ff       	call   f0100068 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01030f5:	6a 02                	push   $0x2
f01030f7:	68 00 10 00 00       	push   $0x1000
f01030fc:	53                   	push   %ebx
f01030fd:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f0103103:	e8 a9 e7 ff ff       	call   f01018b1 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103108:	83 c4 10             	add    $0x10,%esp
f010310b:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103112:	02 02 02 
f0103115:	74 19                	je     f0103130 <mem_init+0x17cf>
f0103117:	68 80 77 10 f0       	push   $0xf0107780
f010311c:	68 57 78 10 f0       	push   $0xf0107857
f0103121:	68 3c 04 00 00       	push   $0x43c
f0103126:	68 31 78 10 f0       	push   $0xf0107831
f010312b:	e8 38 cf ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f0103130:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103135:	74 19                	je     f0103150 <mem_init+0x17ef>
f0103137:	68 3e 7a 10 f0       	push   $0xf0107a3e
f010313c:	68 57 78 10 f0       	push   $0xf0107857
f0103141:	68 3d 04 00 00       	push   $0x43d
f0103146:	68 31 78 10 f0       	push   $0xf0107831
f010314b:	e8 18 cf ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 0);
f0103150:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103155:	74 19                	je     f0103170 <mem_init+0x180f>
f0103157:	68 87 7a 10 f0       	push   $0xf0107a87
f010315c:	68 57 78 10 f0       	push   $0xf0107857
f0103161:	68 3e 04 00 00       	push   $0x43e
f0103166:	68 31 78 10 f0       	push   $0xf0107831
f010316b:	e8 f8 ce ff ff       	call   f0100068 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103170:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103177:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010317a:	89 d8                	mov    %ebx,%eax
f010317c:	2b 05 90 fe 2d f0    	sub    0xf02dfe90,%eax
f0103182:	c1 f8 03             	sar    $0x3,%eax
f0103185:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103188:	89 c2                	mov    %eax,%edx
f010318a:	c1 ea 0c             	shr    $0xc,%edx
f010318d:	3b 15 88 fe 2d f0    	cmp    0xf02dfe88,%edx
f0103193:	72 12                	jb     f01031a7 <mem_init+0x1846>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103195:	50                   	push   %eax
f0103196:	68 c8 64 10 f0       	push   $0xf01064c8
f010319b:	6a 58                	push   $0x58
f010319d:	68 3d 78 10 f0       	push   $0xf010783d
f01031a2:	e8 c1 ce ff ff       	call   f0100068 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01031a7:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01031ae:	03 03 03 
f01031b1:	74 19                	je     f01031cc <mem_init+0x186b>
f01031b3:	68 a4 77 10 f0       	push   $0xf01077a4
f01031b8:	68 57 78 10 f0       	push   $0xf0107857
f01031bd:	68 40 04 00 00       	push   $0x440
f01031c2:	68 31 78 10 f0       	push   $0xf0107831
f01031c7:	e8 9c ce ff ff       	call   f0100068 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01031cc:	83 ec 08             	sub    $0x8,%esp
f01031cf:	68 00 10 00 00       	push   $0x1000
f01031d4:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f01031da:	e8 85 e6 ff ff       	call   f0101864 <page_remove>
	assert(pp2->pp_ref == 0);
f01031df:	83 c4 10             	add    $0x10,%esp
f01031e2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01031e7:	74 19                	je     f0103202 <mem_init+0x18a1>
f01031e9:	68 76 7a 10 f0       	push   $0xf0107a76
f01031ee:	68 57 78 10 f0       	push   $0xf0107857
f01031f3:	68 42 04 00 00       	push   $0x442
f01031f8:	68 31 78 10 f0       	push   $0xf0107831
f01031fd:	e8 66 ce ff ff       	call   f0100068 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103202:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f0103207:	8b 08                	mov    (%eax),%ecx
f0103209:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010320f:	89 f2                	mov    %esi,%edx
f0103211:	2b 15 90 fe 2d f0    	sub    0xf02dfe90,%edx
f0103217:	c1 fa 03             	sar    $0x3,%edx
f010321a:	c1 e2 0c             	shl    $0xc,%edx
f010321d:	39 d1                	cmp    %edx,%ecx
f010321f:	74 19                	je     f010323a <mem_init+0x18d9>
f0103221:	68 64 71 10 f0       	push   $0xf0107164
f0103226:	68 57 78 10 f0       	push   $0xf0107857
f010322b:	68 45 04 00 00       	push   $0x445
f0103230:	68 31 78 10 f0       	push   $0xf0107831
f0103235:	e8 2e ce ff ff       	call   f0100068 <_panic>
	kern_pgdir[0] = 0;
f010323a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103240:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103245:	74 19                	je     f0103260 <mem_init+0x18ff>
f0103247:	68 2d 7a 10 f0       	push   $0xf0107a2d
f010324c:	68 57 78 10 f0       	push   $0xf0107857
f0103251:	68 47 04 00 00       	push   $0x447
f0103256:	68 31 78 10 f0       	push   $0xf0107831
f010325b:	e8 08 ce ff ff       	call   f0100068 <_panic>
	pp0->pp_ref = 0;
f0103260:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103266:	83 ec 0c             	sub    $0xc,%esp
f0103269:	56                   	push   %esi
f010326a:	e8 20 e4 ff ff       	call   f010168f <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010326f:	c7 04 24 d0 77 10 f0 	movl   $0xf01077d0,(%esp)
f0103276:	e8 12 0b 00 00       	call   f0103d8d <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010327b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010327e:	5b                   	pop    %ebx
f010327f:	5e                   	pop    %esi
f0103280:	5f                   	pop    %edi
f0103281:	c9                   	leave  
f0103282:	c3                   	ret    
	//
	// LAB 4: Your code here:
    
    int cpu_id;
    for (cpu_id = 0; cpu_id < NCPU; cpu_id++) {
        boot_map_region(kern_pgdir,
f0103283:	83 ec 08             	sub    $0x8,%esp
f0103286:	6a 02                	push   $0x2
f0103288:	68 00 10 2e 00       	push   $0x2e1000
f010328d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103292:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103297:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
f010329c:	e8 c3 e4 ff ff       	call   f0101764 <boot_map_region>
f01032a1:	bb 00 90 2e f0       	mov    $0xf02e9000,%ebx
f01032a6:	83 c4 10             	add    $0x10,%esp
f01032a9:	be 00 80 fe ef       	mov    $0xeffe8000,%esi
f01032ae:	e9 72 f9 ff ff       	jmp    f0102c25 <mem_init+0x12c4>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01032b3:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f01032b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032b9:	e8 21 df ff ff       	call   f01011df <check_va2pa>
f01032be:	e9 41 fb ff ff       	jmp    f0102e04 <mem_init+0x14a3>

f01032c3 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01032c3:	55                   	push   %ebp
f01032c4:	89 e5                	mov    %esp,%ebp
f01032c6:	57                   	push   %edi
f01032c7:	56                   	push   %esi
f01032c8:	53                   	push   %ebx
f01032c9:	83 ec 1c             	sub    $0x1c,%esp
f01032cc:	8b 7d 08             	mov    0x8(%ebp),%edi
f01032cf:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032d2:	8b 55 10             	mov    0x10(%ebp),%edx
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f01032d5:	85 d2                	test   %edx,%edx
f01032d7:	0f 84 85 00 00 00    	je     f0103362 <user_mem_check+0x9f>

	perm |= PTE_P;
f01032dd:	8b 75 14             	mov    0x14(%ebp),%esi
f01032e0:	83 ce 01             	or     $0x1,%esi
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
f01032e3:	89 c3                	mov    %eax,%ebx
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
f01032e5:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f01032ec:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01032f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f01032f5:	89 c2                	mov    %eax,%edx
f01032f7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01032fd:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f0103300:	74 67                	je     f0103369 <user_mem_check+0xa6>
		if (va_now >= ULIM) {
f0103302:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103307:	76 17                	jbe    f0103320 <user_mem_check+0x5d>
f0103309:	eb 08                	jmp    f0103313 <user_mem_check+0x50>
f010330b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103311:	76 0d                	jbe    f0103320 <user_mem_check+0x5d>
			user_mem_check_addr = va_now;
f0103313:	89 1d 2c f2 2d f0    	mov    %ebx,0xf02df22c
			return -E_FAULT;
f0103319:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010331e:	eb 4e                	jmp    f010336e <user_mem_check+0xab>
		}
		pte = pgdir_walk(env->env_pgdir, (void *)va_now, false);
f0103320:	83 ec 04             	sub    $0x4,%esp
f0103323:	6a 00                	push   $0x0
f0103325:	53                   	push   %ebx
f0103326:	ff 77 60             	pushl  0x60(%edi)
f0103329:	e8 9f e3 ff ff       	call   f01016cd <pgdir_walk>
		if (pte == NULL || ((*pte & perm ) != perm)) {
f010332e:	83 c4 10             	add    $0x10,%esp
f0103331:	85 c0                	test   %eax,%eax
f0103333:	74 08                	je     f010333d <user_mem_check+0x7a>
f0103335:	8b 00                	mov    (%eax),%eax
f0103337:	21 f0                	and    %esi,%eax
f0103339:	39 c6                	cmp    %eax,%esi
f010333b:	74 0d                	je     f010334a <user_mem_check+0x87>
			user_mem_check_addr = va_now;
f010333d:	89 1d 2c f2 2d f0    	mov    %ebx,0xf02df22c
			return -E_FAULT;
f0103343:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103348:	eb 24                	jmp    f010336e <user_mem_check+0xab>

	perm |= PTE_P;
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f010334a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103350:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103356:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0103359:	75 b0                	jne    f010330b <user_mem_check+0x48>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f010335b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103360:	eb 0c                	jmp    f010336e <user_mem_check+0xab>
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f0103362:	b8 00 00 00 00       	mov    $0x0,%eax
f0103367:	eb 05                	jmp    f010336e <user_mem_check+0xab>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0103369:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010336e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103371:	5b                   	pop    %ebx
f0103372:	5e                   	pop    %esi
f0103373:	5f                   	pop    %edi
f0103374:	c9                   	leave  
f0103375:	c3                   	ret    

f0103376 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103376:	55                   	push   %ebp
f0103377:	89 e5                	mov    %esp,%ebp
f0103379:	53                   	push   %ebx
f010337a:	83 ec 04             	sub    $0x4,%esp
f010337d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103380:	8b 45 14             	mov    0x14(%ebp),%eax
f0103383:	83 c8 04             	or     $0x4,%eax
f0103386:	50                   	push   %eax
f0103387:	ff 75 10             	pushl  0x10(%ebp)
f010338a:	ff 75 0c             	pushl  0xc(%ebp)
f010338d:	53                   	push   %ebx
f010338e:	e8 30 ff ff ff       	call   f01032c3 <user_mem_check>
f0103393:	83 c4 10             	add    $0x10,%esp
f0103396:	85 c0                	test   %eax,%eax
f0103398:	79 21                	jns    f01033bb <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f010339a:	83 ec 04             	sub    $0x4,%esp
f010339d:	ff 35 2c f2 2d f0    	pushl  0xf02df22c
f01033a3:	ff 73 48             	pushl  0x48(%ebx)
f01033a6:	68 fc 77 10 f0       	push   $0xf01077fc
f01033ab:	e8 dd 09 00 00       	call   f0103d8d <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01033b0:	89 1c 24             	mov    %ebx,(%esp)
f01033b3:	e8 b4 06 00 00       	call   f0103a6c <env_destroy>
f01033b8:	83 c4 10             	add    $0x10,%esp
	}
}
f01033bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033be:	c9                   	leave  
f01033bf:	c3                   	ret    

f01033c0 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01033c0:	55                   	push   %ebp
f01033c1:	89 e5                	mov    %esp,%ebp
f01033c3:	57                   	push   %edi
f01033c4:	56                   	push   %esi
f01033c5:	53                   	push   %ebx
f01033c6:	83 ec 0c             	sub    $0xc,%esp
f01033c9:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
f01033cb:	89 d3                	mov    %edx,%ebx
f01033cd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
f01033d3:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f01033da:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f01033e0:	39 fb                	cmp    %edi,%ebx
f01033e2:	74 5a                	je     f010343e <region_alloc+0x7e>
        pg = page_alloc(1);
f01033e4:	83 ec 0c             	sub    $0xc,%esp
f01033e7:	6a 01                	push   $0x1
f01033e9:	e8 17 e2 ff ff       	call   f0101605 <page_alloc>
        if (pg == NULL) {
f01033ee:	83 c4 10             	add    $0x10,%esp
f01033f1:	85 c0                	test   %eax,%eax
f01033f3:	75 17                	jne    f010340c <region_alloc+0x4c>
            panic("region_alloc : can't alloc page\n");
f01033f5:	83 ec 04             	sub    $0x4,%esp
f01033f8:	68 0c 7b 10 f0       	push   $0xf0107b0c
f01033fd:	68 31 01 00 00       	push   $0x131
f0103402:	68 4f 7b 10 f0       	push   $0xf0107b4f
f0103407:	e8 5c cc ff ff       	call   f0100068 <_panic>
        } else {
            r = page_insert(e->env_pgdir, pg, (void *)addr, PTE_U | PTE_W);
f010340c:	6a 06                	push   $0x6
f010340e:	53                   	push   %ebx
f010340f:	50                   	push   %eax
f0103410:	ff 76 60             	pushl  0x60(%esi)
f0103413:	e8 99 e4 ff ff       	call   f01018b1 <page_insert>
            if (r != 0) {
f0103418:	83 c4 10             	add    $0x10,%esp
f010341b:	85 c0                	test   %eax,%eax
f010341d:	74 15                	je     f0103434 <region_alloc+0x74>
                panic("/kern/env.c/region_alloc : %e\n", r);
f010341f:	50                   	push   %eax
f0103420:	68 30 7b 10 f0       	push   $0xf0107b30
f0103425:	68 35 01 00 00       	push   $0x135
f010342a:	68 4f 7b 10 f0       	push   $0xf0107b4f
f010342f:	e8 34 cc ff ff       	call   f0100068 <_panic>
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0103434:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010343a:	39 df                	cmp    %ebx,%edi
f010343c:	75 a6                	jne    f01033e4 <region_alloc+0x24>
                panic("/kern/env.c/region_alloc : %e\n", r);
            }
        }
    }
    return;
}
f010343e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103441:	5b                   	pop    %ebx
f0103442:	5e                   	pop    %esi
f0103443:	5f                   	pop    %edi
f0103444:	c9                   	leave  
f0103445:	c3                   	ret    

f0103446 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103446:	55                   	push   %ebp
f0103447:	89 e5                	mov    %esp,%ebp
f0103449:	57                   	push   %edi
f010344a:	56                   	push   %esi
f010344b:	53                   	push   %ebx
f010344c:	83 ec 0c             	sub    $0xc,%esp
f010344f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103452:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103455:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103458:	85 c0                	test   %eax,%eax
f010345a:	75 24                	jne    f0103480 <envid2env+0x3a>
		*env_store = curenv;
f010345c:	e8 4f 29 00 00       	call   f0105db0 <cpunum>
f0103461:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103468:	29 c2                	sub    %eax,%edx
f010346a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010346d:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f0103474:	89 06                	mov    %eax,(%esi)
		return 0;
f0103476:	b8 00 00 00 00       	mov    $0x0,%eax
f010347b:	e9 84 00 00 00       	jmp    f0103504 <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103480:	89 c3                	mov    %eax,%ebx
f0103482:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103488:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f010348f:	c1 e3 07             	shl    $0x7,%ebx
f0103492:	29 cb                	sub    %ecx,%ebx
f0103494:	03 1d 3c f2 2d f0    	add    0xf02df23c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010349a:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010349e:	74 05                	je     f01034a5 <envid2env+0x5f>
f01034a0:	39 43 48             	cmp    %eax,0x48(%ebx)
f01034a3:	74 0d                	je     f01034b2 <envid2env+0x6c>
		*env_store = 0;
f01034a5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01034ab:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01034b0:	eb 52                	jmp    f0103504 <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01034b2:	84 d2                	test   %dl,%dl
f01034b4:	74 47                	je     f01034fd <envid2env+0xb7>
f01034b6:	e8 f5 28 00 00       	call   f0105db0 <cpunum>
f01034bb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01034c2:	29 c2                	sub    %eax,%edx
f01034c4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01034c7:	39 1c 85 28 00 2e f0 	cmp    %ebx,-0xfd1ffd8(,%eax,4)
f01034ce:	74 2d                	je     f01034fd <envid2env+0xb7>
f01034d0:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01034d3:	e8 d8 28 00 00       	call   f0105db0 <cpunum>
f01034d8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01034df:	29 c2                	sub    %eax,%edx
f01034e1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01034e4:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f01034eb:	3b 78 48             	cmp    0x48(%eax),%edi
f01034ee:	74 0d                	je     f01034fd <envid2env+0xb7>
		*env_store = 0;
f01034f0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01034f6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01034fb:	eb 07                	jmp    f0103504 <envid2env+0xbe>
	}

	*env_store = e;
f01034fd:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01034ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103504:	83 c4 0c             	add    $0xc,%esp
f0103507:	5b                   	pop    %ebx
f0103508:	5e                   	pop    %esi
f0103509:	5f                   	pop    %edi
f010350a:	c9                   	leave  
f010350b:	c3                   	ret    

f010350c <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010350c:	55                   	push   %ebp
f010350d:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010350f:	b8 88 83 12 f0       	mov    $0xf0128388,%eax
f0103514:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103517:	b8 23 00 00 00       	mov    $0x23,%eax
f010351c:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010351e:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103520:	b0 10                	mov    $0x10,%al
f0103522:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103524:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103526:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103528:	ea 2f 35 10 f0 08 00 	ljmp   $0x8,$0xf010352f
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f010352f:	b0 00                	mov    $0x0,%al
f0103531:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103534:	c9                   	leave  
f0103535:	c3                   	ret    

f0103536 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103536:	55                   	push   %ebp
f0103537:	89 e5                	mov    %esp,%ebp
f0103539:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
f010353a:	8b 1d 3c f2 2d f0    	mov    0xf02df23c,%ebx
f0103540:	89 1d 40 f2 2d f0    	mov    %ebx,0xf02df240
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
f0103546:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        envs[i].env_status = ENV_FREE;
f010354d:	c7 43 54 00 00 00 00 	movl   $0x0,0x54(%ebx)
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103554:	8d 43 7c             	lea    0x7c(%ebx),%eax
f0103557:	8d 8b 00 f0 01 00    	lea    0x1f000(%ebx),%ecx
f010355d:	89 c2                	mov    %eax,%edx
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f010355f:	89 43 44             	mov    %eax,0x44(%ebx)
{
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
f0103562:	39 c8                	cmp    %ecx,%eax
f0103564:	74 1c                	je     f0103582 <env_init+0x4c>
        envs[i].env_id = 0;
f0103566:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE;
f010356d:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f0103574:	83 c0 7c             	add    $0x7c,%eax
        if (i + 1 != NENV)
f0103577:	39 c8                	cmp    %ecx,%eax
f0103579:	75 0f                	jne    f010358a <env_init+0x54>
            envs[i].env_link = envs + (i + 1);
        else 
            envs[i].env_link = NULL;
f010357b:	c7 42 44 00 00 00 00 	movl   $0x0,0x44(%edx)
    }

	// Per-CPU part of the initialization
	env_init_percpu();
f0103582:	e8 85 ff ff ff       	call   f010350c <env_init_percpu>
}
f0103587:	5b                   	pop    %ebx
f0103588:	c9                   	leave  
f0103589:	c3                   	ret    
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f010358a:	89 42 44             	mov    %eax,0x44(%edx)
f010358d:	89 c2                	mov    %eax,%edx
f010358f:	eb d5                	jmp    f0103566 <env_init+0x30>

f0103591 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103591:	55                   	push   %ebp
f0103592:	89 e5                	mov    %esp,%ebp
f0103594:	56                   	push   %esi
f0103595:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103596:	8b 1d 40 f2 2d f0    	mov    0xf02df240,%ebx
f010359c:	85 db                	test   %ebx,%ebx
f010359e:	0f 84 a3 01 00 00    	je     f0103747 <env_alloc+0x1b6>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01035a4:	83 ec 0c             	sub    $0xc,%esp
f01035a7:	6a 01                	push   $0x1
f01035a9:	e8 57 e0 ff ff       	call   f0101605 <page_alloc>
f01035ae:	83 c4 10             	add    $0x10,%esp
f01035b1:	85 c0                	test   %eax,%eax
f01035b3:	0f 84 95 01 00 00    	je     f010374e <env_alloc+0x1bd>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    p->pp_ref++;
f01035b9:	66 ff 40 04          	incw   0x4(%eax)
f01035bd:	2b 05 90 fe 2d f0    	sub    0xf02dfe90,%eax
f01035c3:	c1 f8 03             	sar    $0x3,%eax
f01035c6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035c9:	89 c2                	mov    %eax,%edx
f01035cb:	c1 ea 0c             	shr    $0xc,%edx
f01035ce:	3b 15 88 fe 2d f0    	cmp    0xf02dfe88,%edx
f01035d4:	72 12                	jb     f01035e8 <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01035d6:	50                   	push   %eax
f01035d7:	68 c8 64 10 f0       	push   $0xf01064c8
f01035dc:	6a 58                	push   $0x58
f01035de:	68 3d 78 10 f0       	push   $0xf010783d
f01035e3:	e8 80 ca ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f01035e8:	2d 00 00 00 10       	sub    $0x10000000,%eax
    e->env_pgdir = (pde_t *)page2kva(p);
f01035ed:	89 43 60             	mov    %eax,0x60(%ebx)
    
    memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01035f0:	83 ec 04             	sub    $0x4,%esp
f01035f3:	68 00 10 00 00       	push   $0x1000
f01035f8:	ff 35 8c fe 2d f0    	pushl  0xf02dfe8c
f01035fe:	50                   	push   %eax
f01035ff:	e8 31 22 00 00       	call   f0105835 <memcpy>
    memset(e->env_pgdir, 0, PDX(UTOP) * sizeof(pde_t));
f0103604:	83 c4 0c             	add    $0xc,%esp
f0103607:	68 ec 0e 00 00       	push   $0xeec
f010360c:	6a 00                	push   $0x0
f010360e:	ff 73 60             	pushl  0x60(%ebx)
f0103611:	e8 6b 21 00 00       	call   f0105781 <memset>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103616:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103619:	83 c4 10             	add    $0x10,%esp
f010361c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103621:	77 15                	ja     f0103638 <env_alloc+0xa7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103623:	50                   	push   %eax
f0103624:	68 a4 64 10 f0       	push   $0xf01064a4
f0103629:	68 cb 00 00 00       	push   $0xcb
f010362e:	68 4f 7b 10 f0       	push   $0xf0107b4f
f0103633:	e8 30 ca ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103638:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010363e:	83 ca 05             	or     $0x5,%edx
f0103641:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
    
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103647:	8b 43 48             	mov    0x48(%ebx),%eax
f010364a:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010364f:	89 c1                	mov    %eax,%ecx
f0103651:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0103657:	7f 05                	jg     f010365e <env_alloc+0xcd>
		generation = 1 << ENVGENSHIFT;
f0103659:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f010365e:	89 d8                	mov    %ebx,%eax
f0103660:	2b 05 3c f2 2d f0    	sub    0xf02df23c,%eax
f0103666:	c1 f8 02             	sar    $0x2,%eax
f0103669:	89 c6                	mov    %eax,%esi
f010366b:	c1 e6 05             	shl    $0x5,%esi
f010366e:	89 c2                	mov    %eax,%edx
f0103670:	c1 e2 0a             	shl    $0xa,%edx
f0103673:	8d 14 16             	lea    (%esi,%edx,1),%edx
f0103676:	01 c2                	add    %eax,%edx
f0103678:	89 d6                	mov    %edx,%esi
f010367a:	c1 e6 0f             	shl    $0xf,%esi
f010367d:	01 f2                	add    %esi,%edx
f010367f:	c1 e2 05             	shl    $0x5,%edx
f0103682:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0103685:	f7 d8                	neg    %eax
f0103687:	09 c1                	or     %eax,%ecx
f0103689:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010368c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010368f:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103692:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103699:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01036a0:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01036a7:	83 ec 04             	sub    $0x4,%esp
f01036aa:	6a 44                	push   $0x44
f01036ac:	6a 00                	push   $0x0
f01036ae:	53                   	push   %ebx
f01036af:	e8 cd 20 00 00       	call   f0105781 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01036b4:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01036ba:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01036c0:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01036c6:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01036cd:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01036d3:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01036da:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01036de:	8b 43 44             	mov    0x44(%ebx),%eax
f01036e1:	a3 40 f2 2d f0       	mov    %eax,0xf02df240
	*newenv_store = e;
f01036e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01036e9:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01036eb:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01036ee:	e8 bd 26 00 00       	call   f0105db0 <cpunum>
f01036f3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01036fa:	29 c2                	sub    %eax,%edx
f01036fc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036ff:	83 c4 10             	add    $0x10,%esp
f0103702:	83 3c 85 28 00 2e f0 	cmpl   $0x0,-0xfd1ffd8(,%eax,4)
f0103709:	00 
f010370a:	74 1d                	je     f0103729 <env_alloc+0x198>
f010370c:	e8 9f 26 00 00       	call   f0105db0 <cpunum>
f0103711:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103718:	29 c2                	sub    %eax,%edx
f010371a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010371d:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f0103724:	8b 40 48             	mov    0x48(%eax),%eax
f0103727:	eb 05                	jmp    f010372e <env_alloc+0x19d>
f0103729:	b8 00 00 00 00       	mov    $0x0,%eax
f010372e:	83 ec 04             	sub    $0x4,%esp
f0103731:	53                   	push   %ebx
f0103732:	50                   	push   %eax
f0103733:	68 5a 7b 10 f0       	push   $0xf0107b5a
f0103738:	e8 50 06 00 00       	call   f0103d8d <cprintf>
	return 0;
f010373d:	83 c4 10             	add    $0x10,%esp
f0103740:	b8 00 00 00 00       	mov    $0x0,%eax
f0103745:	eb 0c                	jmp    f0103753 <env_alloc+0x1c2>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103747:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010374c:	eb 05                	jmp    f0103753 <env_alloc+0x1c2>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010374e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103753:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103756:	5b                   	pop    %ebx
f0103757:	5e                   	pop    %esi
f0103758:	c9                   	leave  
f0103759:	c3                   	ret    

f010375a <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f010375a:	55                   	push   %ebp
f010375b:	89 e5                	mov    %esp,%ebp
f010375d:	57                   	push   %edi
f010375e:	56                   	push   %esi
f010375f:	53                   	push   %ebx
f0103760:	83 ec 34             	sub    $0x34,%esp
f0103763:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("env_create %u %u %u\n", binary, size, type);
	// LAB 3: Your code here.
    struct Env * e;
    int r = env_alloc(&e, 0);
f0103766:	6a 00                	push   $0x0
f0103768:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010376b:	50                   	push   %eax
f010376c:	e8 20 fe ff ff       	call   f0103591 <env_alloc>
    if (r < 0) {
f0103771:	83 c4 10             	add    $0x10,%esp
f0103774:	85 c0                	test   %eax,%eax
f0103776:	79 15                	jns    f010378d <env_create+0x33>
        panic("env_create: %e\n", r);
f0103778:	50                   	push   %eax
f0103779:	68 6f 7b 10 f0       	push   $0xf0107b6f
f010377e:	68 9f 01 00 00       	push   $0x19f
f0103783:	68 4f 7b 10 f0       	push   $0xf0107b4f
f0103788:	e8 db c8 ff ff       	call   f0100068 <_panic>
    }
    load_icode(e, binary, size);
f010378d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103790:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
f0103793:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103799:	74 17                	je     f01037b2 <env_create+0x58>
        panic("error elf magic number\n");
f010379b:	83 ec 04             	sub    $0x4,%esp
f010379e:	68 7f 7b 10 f0       	push   $0xf0107b7f
f01037a3:	68 74 01 00 00       	push   $0x174
f01037a8:	68 4f 7b 10 f0       	push   $0xf0107b4f
f01037ad:	e8 b6 c8 ff ff       	call   f0100068 <_panic>
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01037b2:	8b 5e 1c             	mov    0x1c(%esi),%ebx
    eph = ph + elf->e_phnum;
f01037b5:	8b 7e 2c             	mov    0x2c(%esi),%edi

    lcr3(PADDR(e->env_pgdir));
f01037b8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01037bb:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037c3:	77 15                	ja     f01037da <env_create+0x80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037c5:	50                   	push   %eax
f01037c6:	68 a4 64 10 f0       	push   $0xf01064a4
f01037cb:	68 7a 01 00 00       	push   $0x17a
f01037d0:	68 4f 7b 10 f0       	push   $0xf0107b4f
f01037d5:	e8 8e c8 ff ff       	call   f0100068 <_panic>
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
        panic("error elf magic number\n");
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01037da:	8d 1c 1e             	lea    (%esi,%ebx,1),%ebx
    eph = ph + elf->e_phnum;
f01037dd:	0f b7 ff             	movzwl %di,%edi
f01037e0:	c1 e7 05             	shl    $0x5,%edi
f01037e3:	8d 3c 3b             	lea    (%ebx,%edi,1),%edi
	return (physaddr_t)kva - KERNBASE;
f01037e6:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01037eb:	0f 22 d8             	mov    %eax,%cr3

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01037ee:	39 fb                	cmp    %edi,%ebx
f01037f0:	73 48                	jae    f010383a <env_create+0xe0>
        if (ph->p_type == ELF_PROG_LOAD) {
f01037f2:	83 3b 01             	cmpl   $0x1,(%ebx)
f01037f5:	75 3c                	jne    f0103833 <env_create+0xd9>
            // cprintf("%u %u\n", ph->p_memsz, ph->p_filesz);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01037f7:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01037fa:	8b 53 08             	mov    0x8(%ebx),%edx
f01037fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103800:	e8 bb fb ff ff       	call   f01033c0 <region_alloc>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103805:	83 ec 04             	sub    $0x4,%esp
f0103808:	ff 73 10             	pushl  0x10(%ebx)
f010380b:	89 f0                	mov    %esi,%eax
f010380d:	03 43 04             	add    0x4(%ebx),%eax
f0103810:	50                   	push   %eax
f0103811:	ff 73 08             	pushl  0x8(%ebx)
f0103814:	e8 1c 20 00 00       	call   f0105835 <memcpy>
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0103819:	8b 43 10             	mov    0x10(%ebx),%eax
f010381c:	83 c4 0c             	add    $0xc,%esp
f010381f:	8b 53 14             	mov    0x14(%ebx),%edx
f0103822:	29 c2                	sub    %eax,%edx
f0103824:	52                   	push   %edx
f0103825:	6a 00                	push   $0x0
f0103827:	03 43 08             	add    0x8(%ebx),%eax
f010382a:	50                   	push   %eax
f010382b:	e8 51 1f 00 00       	call   f0105781 <memset>
f0103830:	83 c4 10             	add    $0x10,%esp
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
    eph = ph + elf->e_phnum;

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f0103833:	83 c3 20             	add    $0x20,%ebx
f0103836:	39 df                	cmp    %ebx,%edi
f0103838:	77 b8                	ja     f01037f2 <env_create+0x98>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
        }
    }
    e->env_tf.tf_eip = elf->e_entry;
f010383a:	8b 46 18             	mov    0x18(%esi),%eax
f010383d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103840:	89 42 30             	mov    %eax,0x30(%edx)

    lcr3(PADDR(kern_pgdir));
f0103843:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103848:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010384d:	77 15                	ja     f0103864 <env_create+0x10a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010384f:	50                   	push   %eax
f0103850:	68 a4 64 10 f0       	push   $0xf01064a4
f0103855:	68 86 01 00 00       	push   $0x186
f010385a:	68 4f 7b 10 f0       	push   $0xf0107b4f
f010385f:	e8 04 c8 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103864:	05 00 00 00 10       	add    $0x10000000,%eax
f0103869:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010386c:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103871:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103876:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103879:	e8 42 fb ff ff       	call   f01033c0 <region_alloc>
    int r = env_alloc(&e, 0);
    if (r < 0) {
        panic("env_create: %e\n", r);
    }
    load_icode(e, binary, size);
    e->env_type = type;
f010387e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103881:	8b 55 10             	mov    0x10(%ebp),%edx
f0103884:	89 50 50             	mov    %edx,0x50(%eax)
    // cprintf("env_create out\n");
    return;
}
f0103887:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010388a:	5b                   	pop    %ebx
f010388b:	5e                   	pop    %esi
f010388c:	5f                   	pop    %edi
f010388d:	c9                   	leave  
f010388e:	c3                   	ret    

f010388f <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010388f:	55                   	push   %ebp
f0103890:	89 e5                	mov    %esp,%ebp
f0103892:	57                   	push   %edi
f0103893:	56                   	push   %esi
f0103894:	53                   	push   %ebx
f0103895:	83 ec 1c             	sub    $0x1c,%esp
f0103898:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010389b:	e8 10 25 00 00       	call   f0105db0 <cpunum>
f01038a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01038a3:	39 b8 28 00 2e f0    	cmp    %edi,-0xfd1ffd8(%eax)
f01038a9:	75 29                	jne    f01038d4 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01038ab:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038b0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038b5:	77 15                	ja     f01038cc <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038b7:	50                   	push   %eax
f01038b8:	68 a4 64 10 f0       	push   $0xf01064a4
f01038bd:	68 b5 01 00 00       	push   $0x1b5
f01038c2:	68 4f 7b 10 f0       	push   $0xf0107b4f
f01038c7:	e8 9c c7 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01038cc:	05 00 00 00 10       	add    $0x10000000,%eax
f01038d1:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038d4:	8b 5f 48             	mov    0x48(%edi),%ebx
f01038d7:	e8 d4 24 00 00       	call   f0105db0 <cpunum>
f01038dc:	6b d0 74             	imul   $0x74,%eax,%edx
f01038df:	b8 00 00 00 00       	mov    $0x0,%eax
f01038e4:	83 ba 28 00 2e f0 00 	cmpl   $0x0,-0xfd1ffd8(%edx)
f01038eb:	74 11                	je     f01038fe <env_free+0x6f>
f01038ed:	e8 be 24 00 00       	call   f0105db0 <cpunum>
f01038f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01038f5:	8b 80 28 00 2e f0    	mov    -0xfd1ffd8(%eax),%eax
f01038fb:	8b 40 48             	mov    0x48(%eax),%eax
f01038fe:	83 ec 04             	sub    $0x4,%esp
f0103901:	53                   	push   %ebx
f0103902:	50                   	push   %eax
f0103903:	68 97 7b 10 f0       	push   $0xf0107b97
f0103908:	e8 80 04 00 00       	call   f0103d8d <cprintf>
f010390d:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103910:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103917:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010391a:	c1 e0 02             	shl    $0x2,%eax
f010391d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103920:	8b 47 60             	mov    0x60(%edi),%eax
f0103923:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103926:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103929:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010392f:	0f 84 ab 00 00 00    	je     f01039e0 <env_free+0x151>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103935:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010393b:	89 f0                	mov    %esi,%eax
f010393d:	c1 e8 0c             	shr    $0xc,%eax
f0103940:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103943:	3b 05 88 fe 2d f0    	cmp    0xf02dfe88,%eax
f0103949:	72 15                	jb     f0103960 <env_free+0xd1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010394b:	56                   	push   %esi
f010394c:	68 c8 64 10 f0       	push   $0xf01064c8
f0103951:	68 c4 01 00 00       	push   $0x1c4
f0103956:	68 4f 7b 10 f0       	push   $0xf0107b4f
f010395b:	e8 08 c7 ff ff       	call   f0100068 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103960:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103963:	c1 e2 16             	shl    $0x16,%edx
f0103966:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103969:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010396e:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103975:	01 
f0103976:	74 17                	je     f010398f <env_free+0x100>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103978:	83 ec 08             	sub    $0x8,%esp
f010397b:	89 d8                	mov    %ebx,%eax
f010397d:	c1 e0 0c             	shl    $0xc,%eax
f0103980:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103983:	50                   	push   %eax
f0103984:	ff 77 60             	pushl  0x60(%edi)
f0103987:	e8 d8 de ff ff       	call   f0101864 <page_remove>
f010398c:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010398f:	43                   	inc    %ebx
f0103990:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103996:	75 d6                	jne    f010396e <env_free+0xdf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103998:	8b 47 60             	mov    0x60(%edi),%eax
f010399b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010399e:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01039a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01039a8:	3b 05 88 fe 2d f0    	cmp    0xf02dfe88,%eax
f01039ae:	72 14                	jb     f01039c4 <env_free+0x135>
		panic("pa2page called with invalid pa");
f01039b0:	83 ec 04             	sub    $0x4,%esp
f01039b3:	68 30 70 10 f0       	push   $0xf0107030
f01039b8:	6a 51                	push   $0x51
f01039ba:	68 3d 78 10 f0       	push   $0xf010783d
f01039bf:	e8 a4 c6 ff ff       	call   f0100068 <_panic>
		page_decref(pa2page(pa));
f01039c4:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01039c7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01039ca:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01039d1:	03 05 90 fe 2d f0    	add    0xf02dfe90,%eax
f01039d7:	50                   	push   %eax
f01039d8:	e8 d2 dc ff ff       	call   f01016af <page_decref>
f01039dd:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01039e0:	ff 45 e0             	incl   -0x20(%ebp)
f01039e3:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01039ea:	0f 85 27 ff ff ff    	jne    f0103917 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01039f0:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039f3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039f8:	77 15                	ja     f0103a0f <env_free+0x180>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039fa:	50                   	push   %eax
f01039fb:	68 a4 64 10 f0       	push   $0xf01064a4
f0103a00:	68 d2 01 00 00       	push   $0x1d2
f0103a05:	68 4f 7b 10 f0       	push   $0xf0107b4f
f0103a0a:	e8 59 c6 ff ff       	call   f0100068 <_panic>
	e->env_pgdir = 0;
f0103a0f:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103a16:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a1b:	c1 e8 0c             	shr    $0xc,%eax
f0103a1e:	3b 05 88 fe 2d f0    	cmp    0xf02dfe88,%eax
f0103a24:	72 14                	jb     f0103a3a <env_free+0x1ab>
		panic("pa2page called with invalid pa");
f0103a26:	83 ec 04             	sub    $0x4,%esp
f0103a29:	68 30 70 10 f0       	push   $0xf0107030
f0103a2e:	6a 51                	push   $0x51
f0103a30:	68 3d 78 10 f0       	push   $0xf010783d
f0103a35:	e8 2e c6 ff ff       	call   f0100068 <_panic>
	page_decref(pa2page(pa));
f0103a3a:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103a3d:	c1 e0 03             	shl    $0x3,%eax
f0103a40:	03 05 90 fe 2d f0    	add    0xf02dfe90,%eax
f0103a46:	50                   	push   %eax
f0103a47:	e8 63 dc ff ff       	call   f01016af <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103a4c:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103a53:	a1 40 f2 2d f0       	mov    0xf02df240,%eax
f0103a58:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103a5b:	89 3d 40 f2 2d f0    	mov    %edi,0xf02df240
f0103a61:	83 c4 10             	add    $0x10,%esp
}
f0103a64:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a67:	5b                   	pop    %ebx
f0103a68:	5e                   	pop    %esi
f0103a69:	5f                   	pop    %edi
f0103a6a:	c9                   	leave  
f0103a6b:	c3                   	ret    

f0103a6c <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103a6c:	55                   	push   %ebp
f0103a6d:	89 e5                	mov    %esp,%ebp
f0103a6f:	53                   	push   %ebx
f0103a70:	83 ec 04             	sub    $0x4,%esp
f0103a73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103a76:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103a7a:	75 23                	jne    f0103a9f <env_destroy+0x33>
f0103a7c:	e8 2f 23 00 00       	call   f0105db0 <cpunum>
f0103a81:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a88:	29 c2                	sub    %eax,%edx
f0103a8a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a8d:	39 1c 85 28 00 2e f0 	cmp    %ebx,-0xfd1ffd8(,%eax,4)
f0103a94:	74 09                	je     f0103a9f <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103a96:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103a9d:	eb 3d                	jmp    f0103adc <env_destroy+0x70>
	}

	env_free(e);
f0103a9f:	83 ec 0c             	sub    $0xc,%esp
f0103aa2:	53                   	push   %ebx
f0103aa3:	e8 e7 fd ff ff       	call   f010388f <env_free>

	if (curenv == e) {
f0103aa8:	e8 03 23 00 00       	call   f0105db0 <cpunum>
f0103aad:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ab4:	29 c2                	sub    %eax,%edx
f0103ab6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ab9:	83 c4 10             	add    $0x10,%esp
f0103abc:	39 1c 85 28 00 2e f0 	cmp    %ebx,-0xfd1ffd8(,%eax,4)
f0103ac3:	75 17                	jne    f0103adc <env_destroy+0x70>
		curenv = NULL;
f0103ac5:	e8 e6 22 00 00       	call   f0105db0 <cpunum>
f0103aca:	6b c0 74             	imul   $0x74,%eax,%eax
f0103acd:	c7 80 28 00 2e f0 00 	movl   $0x0,-0xfd1ffd8(%eax)
f0103ad4:	00 00 00 
		sched_yield();
f0103ad7:	e8 96 0b 00 00       	call   f0104672 <sched_yield>
	}
}
f0103adc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103adf:	c9                   	leave  
f0103ae0:	c3                   	ret    

f0103ae1 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103ae1:	55                   	push   %ebp
f0103ae2:	89 e5                	mov    %esp,%ebp
f0103ae4:	53                   	push   %ebx
f0103ae5:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103ae8:	e8 c3 22 00 00       	call   f0105db0 <cpunum>
f0103aed:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103af4:	29 c2                	sub    %eax,%edx
f0103af6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103af9:	8b 1c 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%ebx
f0103b00:	e8 ab 22 00 00       	call   f0105db0 <cpunum>
f0103b05:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103b08:	8b 65 08             	mov    0x8(%ebp),%esp
f0103b0b:	61                   	popa   
f0103b0c:	07                   	pop    %es
f0103b0d:	1f                   	pop    %ds
f0103b0e:	83 c4 08             	add    $0x8,%esp
f0103b11:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103b12:	83 ec 04             	sub    $0x4,%esp
f0103b15:	68 ad 7b 10 f0       	push   $0xf0107bad
f0103b1a:	68 08 02 00 00       	push   $0x208
f0103b1f:	68 4f 7b 10 f0       	push   $0xf0107b4f
f0103b24:	e8 3f c5 ff ff       	call   f0100068 <_panic>

f0103b29 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103b29:	55                   	push   %ebp
f0103b2a:	89 e5                	mov    %esp,%ebp
f0103b2c:	83 ec 08             	sub    $0x8,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// cprintf("I am in env_run\n");
    if (curenv != NULL) {
f0103b2f:	e8 7c 22 00 00       	call   f0105db0 <cpunum>
f0103b34:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b3b:	29 c2                	sub    %eax,%edx
f0103b3d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b40:	83 3c 85 28 00 2e f0 	cmpl   $0x0,-0xfd1ffd8(,%eax,4)
f0103b47:	00 
f0103b48:	74 3d                	je     f0103b87 <env_run+0x5e>
        // context switch
        if (curenv->env_status == ENV_RUNNING) {
f0103b4a:	e8 61 22 00 00       	call   f0105db0 <cpunum>
f0103b4f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b56:	29 c2                	sub    %eax,%edx
f0103b58:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b5b:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f0103b62:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103b66:	75 1f                	jne    f0103b87 <env_run+0x5e>
            curenv->env_status = ENV_RUNNABLE;
f0103b68:	e8 43 22 00 00       	call   f0105db0 <cpunum>
f0103b6d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b74:	29 c2                	sub    %eax,%edx
f0103b76:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b79:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f0103b80:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
        }
        // how about other env_status ? e.g. like ENV_DYING ?
    }
    curenv = e;
f0103b87:	e8 24 22 00 00       	call   f0105db0 <cpunum>
f0103b8c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b93:	29 c2                	sub    %eax,%edx
f0103b95:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b98:	8b 55 08             	mov    0x8(%ebp),%edx
f0103b9b:	89 14 85 28 00 2e f0 	mov    %edx,-0xfd1ffd8(,%eax,4)
    curenv->env_status = ENV_RUNNING;
f0103ba2:	e8 09 22 00 00       	call   f0105db0 <cpunum>
f0103ba7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103bae:	29 c2                	sub    %eax,%edx
f0103bb0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103bb3:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f0103bba:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f0103bc1:	e8 ea 21 00 00       	call   f0105db0 <cpunum>
f0103bc6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103bcd:	29 c2                	sub    %eax,%edx
f0103bcf:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103bd2:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f0103bd9:	ff 40 58             	incl   0x58(%eax)
    
    lcr3(PADDR(curenv->env_pgdir));
f0103bdc:	e8 cf 21 00 00       	call   f0105db0 <cpunum>
f0103be1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103be8:	29 c2                	sub    %eax,%edx
f0103bea:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103bed:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f0103bf4:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bf7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bfc:	77 15                	ja     f0103c13 <env_run+0xea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bfe:	50                   	push   %eax
f0103bff:	68 a4 64 10 f0       	push   $0xf01064a4
f0103c04:	68 32 02 00 00       	push   $0x232
f0103c09:	68 4f 7b 10 f0       	push   $0xf0107b4f
f0103c0e:	e8 55 c4 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103c13:	05 00 00 00 10       	add    $0x10000000,%eax
f0103c18:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103c1b:	83 ec 0c             	sub    $0xc,%esp
f0103c1e:	68 40 84 12 f0       	push   $0xf0128440
f0103c23:	e8 fa 24 00 00       	call   f0106122 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103c28:	f3 90                	pause  
    unlock_kernel();
    env_pop_tf(&curenv->env_tf);    
f0103c2a:	e8 81 21 00 00       	call   f0105db0 <cpunum>
f0103c2f:	83 c4 04             	add    $0x4,%esp
f0103c32:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c39:	29 c2                	sub    %eax,%edx
f0103c3b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c3e:	ff 34 85 28 00 2e f0 	pushl  -0xfd1ffd8(,%eax,4)
f0103c45:	e8 97 fe ff ff       	call   f0103ae1 <env_pop_tf>
	...

f0103c4c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103c4c:	55                   	push   %ebp
f0103c4d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c4f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c54:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c57:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103c58:	b2 71                	mov    $0x71,%dl
f0103c5a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103c5b:	0f b6 c0             	movzbl %al,%eax
}
f0103c5e:	c9                   	leave  
f0103c5f:	c3                   	ret    

f0103c60 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103c60:	55                   	push   %ebp
f0103c61:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c63:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c68:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c6b:	ee                   	out    %al,(%dx)
f0103c6c:	b2 71                	mov    $0x71,%dl
f0103c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c71:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103c72:	c9                   	leave  
f0103c73:	c3                   	ret    

f0103c74 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103c74:	55                   	push   %ebp
f0103c75:	89 e5                	mov    %esp,%ebp
f0103c77:	56                   	push   %esi
f0103c78:	53                   	push   %ebx
f0103c79:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c7c:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103c7e:	66 a3 90 83 12 f0    	mov    %ax,0xf0128390
	if (!didinit)
f0103c84:	80 3d 44 f2 2d f0 00 	cmpb   $0x0,0xf02df244
f0103c8b:	74 5a                	je     f0103ce7 <irq_setmask_8259A+0x73>
f0103c8d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103c92:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103c93:	89 f0                	mov    %esi,%eax
f0103c95:	66 c1 e8 08          	shr    $0x8,%ax
f0103c99:	b2 a1                	mov    $0xa1,%dl
f0103c9b:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103c9c:	83 ec 0c             	sub    $0xc,%esp
f0103c9f:	68 b9 7b 10 f0       	push   $0xf0107bb9
f0103ca4:	e8 e4 00 00 00       	call   f0103d8d <cprintf>
f0103ca9:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103cac:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103cb1:	0f b7 f6             	movzwl %si,%esi
f0103cb4:	f7 d6                	not    %esi
f0103cb6:	89 f0                	mov    %esi,%eax
f0103cb8:	88 d9                	mov    %bl,%cl
f0103cba:	d3 f8                	sar    %cl,%eax
f0103cbc:	a8 01                	test   $0x1,%al
f0103cbe:	74 11                	je     f0103cd1 <irq_setmask_8259A+0x5d>
			cprintf(" %d", i);
f0103cc0:	83 ec 08             	sub    $0x8,%esp
f0103cc3:	53                   	push   %ebx
f0103cc4:	68 e3 80 10 f0       	push   $0xf01080e3
f0103cc9:	e8 bf 00 00 00       	call   f0103d8d <cprintf>
f0103cce:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103cd1:	43                   	inc    %ebx
f0103cd2:	83 fb 10             	cmp    $0x10,%ebx
f0103cd5:	75 df                	jne    f0103cb6 <irq_setmask_8259A+0x42>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103cd7:	83 ec 0c             	sub    $0xc,%esp
f0103cda:	68 ef 67 10 f0       	push   $0xf01067ef
f0103cdf:	e8 a9 00 00 00       	call   f0103d8d <cprintf>
f0103ce4:	83 c4 10             	add    $0x10,%esp
}
f0103ce7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103cea:	5b                   	pop    %ebx
f0103ceb:	5e                   	pop    %esi
f0103cec:	c9                   	leave  
f0103ced:	c3                   	ret    

f0103cee <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103cee:	55                   	push   %ebp
f0103cef:	89 e5                	mov    %esp,%ebp
f0103cf1:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f0103cf4:	c6 05 44 f2 2d f0 01 	movb   $0x1,0xf02df244
f0103cfb:	ba 21 00 00 00       	mov    $0x21,%edx
f0103d00:	b0 ff                	mov    $0xff,%al
f0103d02:	ee                   	out    %al,(%dx)
f0103d03:	b2 a1                	mov    $0xa1,%dl
f0103d05:	ee                   	out    %al,(%dx)
f0103d06:	b2 20                	mov    $0x20,%dl
f0103d08:	b0 11                	mov    $0x11,%al
f0103d0a:	ee                   	out    %al,(%dx)
f0103d0b:	b2 21                	mov    $0x21,%dl
f0103d0d:	b0 20                	mov    $0x20,%al
f0103d0f:	ee                   	out    %al,(%dx)
f0103d10:	b0 04                	mov    $0x4,%al
f0103d12:	ee                   	out    %al,(%dx)
f0103d13:	b0 03                	mov    $0x3,%al
f0103d15:	ee                   	out    %al,(%dx)
f0103d16:	b2 a0                	mov    $0xa0,%dl
f0103d18:	b0 11                	mov    $0x11,%al
f0103d1a:	ee                   	out    %al,(%dx)
f0103d1b:	b2 a1                	mov    $0xa1,%dl
f0103d1d:	b0 28                	mov    $0x28,%al
f0103d1f:	ee                   	out    %al,(%dx)
f0103d20:	b0 02                	mov    $0x2,%al
f0103d22:	ee                   	out    %al,(%dx)
f0103d23:	b0 01                	mov    $0x1,%al
f0103d25:	ee                   	out    %al,(%dx)
f0103d26:	b2 20                	mov    $0x20,%dl
f0103d28:	b0 68                	mov    $0x68,%al
f0103d2a:	ee                   	out    %al,(%dx)
f0103d2b:	b0 0a                	mov    $0xa,%al
f0103d2d:	ee                   	out    %al,(%dx)
f0103d2e:	b2 a0                	mov    $0xa0,%dl
f0103d30:	b0 68                	mov    $0x68,%al
f0103d32:	ee                   	out    %al,(%dx)
f0103d33:	b0 0a                	mov    $0xa,%al
f0103d35:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103d36:	66 a1 90 83 12 f0    	mov    0xf0128390,%ax
f0103d3c:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103d40:	74 0f                	je     f0103d51 <pic_init+0x63>
		irq_setmask_8259A(irq_mask_8259A);
f0103d42:	83 ec 0c             	sub    $0xc,%esp
f0103d45:	0f b7 c0             	movzwl %ax,%eax
f0103d48:	50                   	push   %eax
f0103d49:	e8 26 ff ff ff       	call   f0103c74 <irq_setmask_8259A>
f0103d4e:	83 c4 10             	add    $0x10,%esp
}
f0103d51:	c9                   	leave  
f0103d52:	c3                   	ret    
	...

f0103d54 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103d54:	55                   	push   %ebp
f0103d55:	89 e5                	mov    %esp,%ebp
f0103d57:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103d5a:	ff 75 08             	pushl  0x8(%ebp)
f0103d5d:	e8 75 ca ff ff       	call   f01007d7 <cputchar>
f0103d62:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0103d65:	c9                   	leave  
f0103d66:	c3                   	ret    

f0103d67 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103d67:	55                   	push   %ebp
f0103d68:	89 e5                	mov    %esp,%ebp
f0103d6a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103d6d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103d74:	ff 75 0c             	pushl  0xc(%ebp)
f0103d77:	ff 75 08             	pushl  0x8(%ebp)
f0103d7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103d7d:	50                   	push   %eax
f0103d7e:	68 54 3d 10 f0       	push   $0xf0103d54
f0103d83:	e8 61 13 00 00       	call   f01050e9 <vprintfmt>
	return cnt;
}
f0103d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d8b:	c9                   	leave  
f0103d8c:	c3                   	ret    

f0103d8d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103d8d:	55                   	push   %ebp
f0103d8e:	89 e5                	mov    %esp,%ebp
f0103d90:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103d93:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103d96:	50                   	push   %eax
f0103d97:	ff 75 08             	pushl  0x8(%ebp)
f0103d9a:	e8 c8 ff ff ff       	call   f0103d67 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103d9f:	c9                   	leave  
f0103da0:	c3                   	ret    
f0103da1:	00 00                	add    %al,(%eax)
	...

f0103da4 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103da4:	55                   	push   %ebp
f0103da5:	89 e5                	mov    %esp,%ebp
f0103da7:	57                   	push   %edi
f0103da8:	56                   	push   %esi
f0103da9:	53                   	push   %ebx
f0103daa:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
    
    int cpu_id = thiscpu->cpu_id;
f0103dad:	e8 fe 1f 00 00       	call   f0105db0 <cpunum>
f0103db2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103db9:	29 c2                	sub    %eax,%edx
f0103dbb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103dbe:	0f b6 34 85 20 00 2e 	movzbl -0xfd1ffe0(,%eax,4),%esi
f0103dc5:	f0 
    
    // Setup a TSS so that we get the right stack
	// when we trap to the kernel.
    thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id * (KSTKSIZE + KSTKGAP);
f0103dc6:	e8 e5 1f 00 00       	call   f0105db0 <cpunum>
f0103dcb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103dd2:	29 c2                	sub    %eax,%edx
f0103dd4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103dd7:	89 f2                	mov    %esi,%edx
f0103dd9:	f7 da                	neg    %edx
f0103ddb:	c1 e2 10             	shl    $0x10,%edx
f0103dde:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103de4:	89 14 85 30 00 2e f0 	mov    %edx,-0xfd1ffd0(,%eax,4)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103deb:	e8 c0 1f 00 00       	call   f0105db0 <cpunum>
f0103df0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103df7:	29 c2                	sub    %eax,%edx
f0103df9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103dfc:	66 c7 04 85 34 00 2e 	movw   $0x10,-0xfd1ffcc(,%eax,4)
f0103e03:	f0 10 00 

    gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103e06:	8d 5e 05             	lea    0x5(%esi),%ebx
f0103e09:	e8 a2 1f 00 00       	call   f0105db0 <cpunum>
f0103e0e:	89 c7                	mov    %eax,%edi
f0103e10:	e8 9b 1f 00 00       	call   f0105db0 <cpunum>
f0103e15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103e18:	e8 93 1f 00 00       	call   f0105db0 <cpunum>
f0103e1d:	66 c7 04 dd 20 83 12 	movw   $0x68,-0xfed7ce0(,%ebx,8)
f0103e24:	f0 68 00 
f0103e27:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0103e2e:	29 fa                	sub    %edi,%edx
f0103e30:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103e33:	8d 14 95 2c 00 2e f0 	lea    -0xfd1ffd4(,%edx,4),%edx
f0103e3a:	66 89 14 dd 22 83 12 	mov    %dx,-0xfed7cde(,%ebx,8)
f0103e41:	f0 
f0103e42:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103e45:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0103e4c:	29 ca                	sub    %ecx,%edx
f0103e4e:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0103e51:	8d 14 95 2c 00 2e f0 	lea    -0xfd1ffd4(,%edx,4),%edx
f0103e58:	c1 ea 10             	shr    $0x10,%edx
f0103e5b:	88 14 dd 24 83 12 f0 	mov    %dl,-0xfed7cdc(,%ebx,8)
f0103e62:	c6 04 dd 26 83 12 f0 	movb   $0x40,-0xfed7cda(,%ebx,8)
f0103e69:	40 
f0103e6a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103e71:	29 c2                	sub    %eax,%edx
f0103e73:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103e76:	8d 04 85 2c 00 2e f0 	lea    -0xfd1ffd4(,%eax,4),%eax
f0103e7d:	c1 e8 18             	shr    $0x18,%eax
f0103e80:	88 04 dd 27 83 12 f0 	mov    %al,-0xfed7cd9(,%ebx,8)
    							sizeof(struct Taskstate), 0);

    // Initialize the TSS slot of the gdt.
    gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0103e87:	c6 04 dd 25 83 12 f0 	movb   $0x89,-0xfed7cdb(,%ebx,8)
f0103e8e:	89 

    // Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
    ltr(GD_TSS0 + (cpu_id << 3));
f0103e8f:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103e96:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103e99:	b8 94 83 12 f0       	mov    $0xf0128394,%eax
f0103e9e:	0f 01 18             	lidtl  (%eax)

    // Load the IDT
    lidt(&idt_pd);
}
f0103ea1:	83 c4 1c             	add    $0x1c,%esp
f0103ea4:	5b                   	pop    %ebx
f0103ea5:	5e                   	pop    %esi
f0103ea6:	5f                   	pop    %edi
f0103ea7:	c9                   	leave  
f0103ea8:	c3                   	ret    

f0103ea9 <trap_init>:
}


void
trap_init(void)
{
f0103ea9:	55                   	push   %ebp
f0103eaa:	89 e5                	mov    %esp,%ebp
f0103eac:	83 ec 08             	sub    $0x8,%esp
f0103eaf:	ba 01 00 00 00       	mov    $0x1,%edx
f0103eb4:	b8 00 00 00 00       	mov    $0x0,%eax
f0103eb9:	eb 02                	jmp    f0103ebd <trap_init+0x14>
f0103ebb:	40                   	inc    %eax
f0103ebc:	42                   	inc    %edx
	// LAB 3: Your code here.  
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
    	if (i == T_BRKPT) {
f0103ebd:	83 f8 03             	cmp    $0x3,%eax
f0103ec0:	75 30                	jne    f0103ef2 <trap_init+0x49>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
f0103ec2:	8b 0d a8 83 12 f0    	mov    0xf01283a8,%ecx
f0103ec8:	66 89 0d 78 f2 2d f0 	mov    %cx,0xf02df278
f0103ecf:	66 c7 05 7a f2 2d f0 	movw   $0x8,0xf02df27a
f0103ed6:	08 00 
f0103ed8:	c6 05 7c f2 2d f0 00 	movb   $0x0,0xf02df27c
f0103edf:	c6 05 7d f2 2d f0 ee 	movb   $0xee,0xf02df27d
f0103ee6:	c1 e9 10             	shr    $0x10,%ecx
f0103ee9:	66 89 0d 7e f2 2d f0 	mov    %cx,0xf02df27e
f0103ef0:	eb c9                	jmp    f0103ebb <trap_init+0x12>
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f0103ef2:	8b 0c 85 9c 83 12 f0 	mov    -0xfed7c64(,%eax,4),%ecx
f0103ef9:	66 89 0c c5 60 f2 2d 	mov    %cx,-0xfd20da0(,%eax,8)
f0103f00:	f0 
f0103f01:	66 c7 04 c5 62 f2 2d 	movw   $0x8,-0xfd20d9e(,%eax,8)
f0103f08:	f0 08 00 
f0103f0b:	c6 04 c5 64 f2 2d f0 	movb   $0x0,-0xfd20d9c(,%eax,8)
f0103f12:	00 
f0103f13:	c6 04 c5 65 f2 2d f0 	movb   $0x8e,-0xfd20d9b(,%eax,8)
f0103f1a:	8e 
f0103f1b:	c1 e9 10             	shr    $0x10,%ecx
f0103f1e:	66 89 0c c5 66 f2 2d 	mov    %cx,-0xfd20d9a(,%eax,8)
f0103f25:	f0 

	// LAB 3: Your code here.  
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
f0103f26:	83 fa 14             	cmp    $0x14,%edx
f0103f29:	75 90                	jne    f0103ebb <trap_init+0x12>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
    	}
    }
    SETGATE(idt[48], 0, GD_KT, vec48, 3);
f0103f2b:	b8 ec 83 12 f0       	mov    $0xf01283ec,%eax
f0103f30:	66 a3 e0 f3 2d f0    	mov    %ax,0xf02df3e0
f0103f36:	66 c7 05 e2 f3 2d f0 	movw   $0x8,0xf02df3e2
f0103f3d:	08 00 
f0103f3f:	c6 05 e4 f3 2d f0 00 	movb   $0x0,0xf02df3e4
f0103f46:	c6 05 e5 f3 2d f0 ee 	movb   $0xee,0xf02df3e5
f0103f4d:	c1 e8 10             	shr    $0x10,%eax
f0103f50:	66 a3 e6 f3 2d f0    	mov    %ax,0xf02df3e6

	// Per-CPU setup 
	trap_init_percpu();
f0103f56:	e8 49 fe ff ff       	call   f0103da4 <trap_init_percpu>
}
f0103f5b:	c9                   	leave  
f0103f5c:	c3                   	ret    

f0103f5d <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103f5d:	55                   	push   %ebp
f0103f5e:	89 e5                	mov    %esp,%ebp
f0103f60:	53                   	push   %ebx
f0103f61:	83 ec 0c             	sub    $0xc,%esp
f0103f64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103f67:	ff 33                	pushl  (%ebx)
f0103f69:	68 cd 7b 10 f0       	push   $0xf0107bcd
f0103f6e:	e8 1a fe ff ff       	call   f0103d8d <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103f73:	83 c4 08             	add    $0x8,%esp
f0103f76:	ff 73 04             	pushl  0x4(%ebx)
f0103f79:	68 dc 7b 10 f0       	push   $0xf0107bdc
f0103f7e:	e8 0a fe ff ff       	call   f0103d8d <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103f83:	83 c4 08             	add    $0x8,%esp
f0103f86:	ff 73 08             	pushl  0x8(%ebx)
f0103f89:	68 eb 7b 10 f0       	push   $0xf0107beb
f0103f8e:	e8 fa fd ff ff       	call   f0103d8d <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103f93:	83 c4 08             	add    $0x8,%esp
f0103f96:	ff 73 0c             	pushl  0xc(%ebx)
f0103f99:	68 fa 7b 10 f0       	push   $0xf0107bfa
f0103f9e:	e8 ea fd ff ff       	call   f0103d8d <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103fa3:	83 c4 08             	add    $0x8,%esp
f0103fa6:	ff 73 10             	pushl  0x10(%ebx)
f0103fa9:	68 09 7c 10 f0       	push   $0xf0107c09
f0103fae:	e8 da fd ff ff       	call   f0103d8d <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103fb3:	83 c4 08             	add    $0x8,%esp
f0103fb6:	ff 73 14             	pushl  0x14(%ebx)
f0103fb9:	68 18 7c 10 f0       	push   $0xf0107c18
f0103fbe:	e8 ca fd ff ff       	call   f0103d8d <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103fc3:	83 c4 08             	add    $0x8,%esp
f0103fc6:	ff 73 18             	pushl  0x18(%ebx)
f0103fc9:	68 27 7c 10 f0       	push   $0xf0107c27
f0103fce:	e8 ba fd ff ff       	call   f0103d8d <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103fd3:	83 c4 08             	add    $0x8,%esp
f0103fd6:	ff 73 1c             	pushl  0x1c(%ebx)
f0103fd9:	68 36 7c 10 f0       	push   $0xf0107c36
f0103fde:	e8 aa fd ff ff       	call   f0103d8d <cprintf>
f0103fe3:	83 c4 10             	add    $0x10,%esp
}
f0103fe6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103fe9:	c9                   	leave  
f0103fea:	c3                   	ret    

f0103feb <print_trapframe>:
    lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103feb:	55                   	push   %ebp
f0103fec:	89 e5                	mov    %esp,%ebp
f0103fee:	53                   	push   %ebx
f0103fef:	83 ec 04             	sub    $0x4,%esp
f0103ff2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103ff5:	e8 b6 1d 00 00       	call   f0105db0 <cpunum>
f0103ffa:	83 ec 04             	sub    $0x4,%esp
f0103ffd:	50                   	push   %eax
f0103ffe:	53                   	push   %ebx
f0103fff:	68 9a 7c 10 f0       	push   $0xf0107c9a
f0104004:	e8 84 fd ff ff       	call   f0103d8d <cprintf>
	print_regs(&tf->tf_regs);
f0104009:	89 1c 24             	mov    %ebx,(%esp)
f010400c:	e8 4c ff ff ff       	call   f0103f5d <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104011:	83 c4 08             	add    $0x8,%esp
f0104014:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104018:	50                   	push   %eax
f0104019:	68 b8 7c 10 f0       	push   $0xf0107cb8
f010401e:	e8 6a fd ff ff       	call   f0103d8d <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104023:	83 c4 08             	add    $0x8,%esp
f0104026:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010402a:	50                   	push   %eax
f010402b:	68 cb 7c 10 f0       	push   $0xf0107ccb
f0104030:	e8 58 fd ff ff       	call   f0103d8d <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104035:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104038:	83 c4 10             	add    $0x10,%esp
f010403b:	83 f8 13             	cmp    $0x13,%eax
f010403e:	77 09                	ja     f0104049 <print_trapframe+0x5e>
		return excnames[trapno];
f0104040:	8b 14 85 a0 7f 10 f0 	mov    -0xfef8060(,%eax,4),%edx
f0104047:	eb 20                	jmp    f0104069 <print_trapframe+0x7e>
	if (trapno == T_SYSCALL)
f0104049:	83 f8 30             	cmp    $0x30,%eax
f010404c:	74 0f                	je     f010405d <print_trapframe+0x72>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010404e:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104051:	83 fa 0f             	cmp    $0xf,%edx
f0104054:	77 0e                	ja     f0104064 <print_trapframe+0x79>
		return "Hardware Interrupt";
f0104056:	ba 51 7c 10 f0       	mov    $0xf0107c51,%edx
f010405b:	eb 0c                	jmp    f0104069 <print_trapframe+0x7e>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f010405d:	ba 45 7c 10 f0       	mov    $0xf0107c45,%edx
f0104062:	eb 05                	jmp    f0104069 <print_trapframe+0x7e>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f0104064:	ba 64 7c 10 f0       	mov    $0xf0107c64,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104069:	83 ec 04             	sub    $0x4,%esp
f010406c:	52                   	push   %edx
f010406d:	50                   	push   %eax
f010406e:	68 de 7c 10 f0       	push   $0xf0107cde
f0104073:	e8 15 fd ff ff       	call   f0103d8d <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104078:	83 c4 10             	add    $0x10,%esp
f010407b:	3b 1d 60 fa 2d f0    	cmp    0xf02dfa60,%ebx
f0104081:	75 1a                	jne    f010409d <print_trapframe+0xb2>
f0104083:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104087:	75 14                	jne    f010409d <print_trapframe+0xb2>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104089:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010408c:	83 ec 08             	sub    $0x8,%esp
f010408f:	50                   	push   %eax
f0104090:	68 f0 7c 10 f0       	push   $0xf0107cf0
f0104095:	e8 f3 fc ff ff       	call   f0103d8d <cprintf>
f010409a:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f010409d:	83 ec 08             	sub    $0x8,%esp
f01040a0:	ff 73 2c             	pushl  0x2c(%ebx)
f01040a3:	68 ff 7c 10 f0       	push   $0xf0107cff
f01040a8:	e8 e0 fc ff ff       	call   f0103d8d <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01040ad:	83 c4 10             	add    $0x10,%esp
f01040b0:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01040b4:	75 45                	jne    f01040fb <print_trapframe+0x110>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01040b6:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01040b9:	a8 01                	test   $0x1,%al
f01040bb:	74 07                	je     f01040c4 <print_trapframe+0xd9>
f01040bd:	b9 73 7c 10 f0       	mov    $0xf0107c73,%ecx
f01040c2:	eb 05                	jmp    f01040c9 <print_trapframe+0xde>
f01040c4:	b9 7e 7c 10 f0       	mov    $0xf0107c7e,%ecx
f01040c9:	a8 02                	test   $0x2,%al
f01040cb:	74 07                	je     f01040d4 <print_trapframe+0xe9>
f01040cd:	ba 8a 7c 10 f0       	mov    $0xf0107c8a,%edx
f01040d2:	eb 05                	jmp    f01040d9 <print_trapframe+0xee>
f01040d4:	ba 90 7c 10 f0       	mov    $0xf0107c90,%edx
f01040d9:	a8 04                	test   $0x4,%al
f01040db:	74 07                	je     f01040e4 <print_trapframe+0xf9>
f01040dd:	b8 95 7c 10 f0       	mov    $0xf0107c95,%eax
f01040e2:	eb 05                	jmp    f01040e9 <print_trapframe+0xfe>
f01040e4:	b8 f6 7d 10 f0       	mov    $0xf0107df6,%eax
f01040e9:	51                   	push   %ecx
f01040ea:	52                   	push   %edx
f01040eb:	50                   	push   %eax
f01040ec:	68 0d 7d 10 f0       	push   $0xf0107d0d
f01040f1:	e8 97 fc ff ff       	call   f0103d8d <cprintf>
f01040f6:	83 c4 10             	add    $0x10,%esp
f01040f9:	eb 10                	jmp    f010410b <print_trapframe+0x120>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01040fb:	83 ec 0c             	sub    $0xc,%esp
f01040fe:	68 ef 67 10 f0       	push   $0xf01067ef
f0104103:	e8 85 fc ff ff       	call   f0103d8d <cprintf>
f0104108:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010410b:	83 ec 08             	sub    $0x8,%esp
f010410e:	ff 73 30             	pushl  0x30(%ebx)
f0104111:	68 1c 7d 10 f0       	push   $0xf0107d1c
f0104116:	e8 72 fc ff ff       	call   f0103d8d <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010411b:	83 c4 08             	add    $0x8,%esp
f010411e:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104122:	50                   	push   %eax
f0104123:	68 2b 7d 10 f0       	push   $0xf0107d2b
f0104128:	e8 60 fc ff ff       	call   f0103d8d <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010412d:	83 c4 08             	add    $0x8,%esp
f0104130:	ff 73 38             	pushl  0x38(%ebx)
f0104133:	68 3e 7d 10 f0       	push   $0xf0107d3e
f0104138:	e8 50 fc ff ff       	call   f0103d8d <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010413d:	83 c4 10             	add    $0x10,%esp
f0104140:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104144:	74 25                	je     f010416b <print_trapframe+0x180>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104146:	83 ec 08             	sub    $0x8,%esp
f0104149:	ff 73 3c             	pushl  0x3c(%ebx)
f010414c:	68 4d 7d 10 f0       	push   $0xf0107d4d
f0104151:	e8 37 fc ff ff       	call   f0103d8d <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104156:	83 c4 08             	add    $0x8,%esp
f0104159:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010415d:	50                   	push   %eax
f010415e:	68 5c 7d 10 f0       	push   $0xf0107d5c
f0104163:	e8 25 fc ff ff       	call   f0103d8d <cprintf>
f0104168:	83 c4 10             	add    $0x10,%esp
	}
}
f010416b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010416e:	c9                   	leave  
f010416f:	c3                   	ret    

f0104170 <page_fault_handler>:
		sched_yield();
}

void
page_fault_handler(struct Trapframe *tf)
{
f0104170:	55                   	push   %ebp
f0104171:	89 e5                	mov    %esp,%ebp
f0104173:	57                   	push   %edi
f0104174:	56                   	push   %esi
f0104175:	53                   	push   %ebx
f0104176:	83 ec 0c             	sub    $0xc,%esp
f0104179:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010417c:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT)
f010417f:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0104184:	75 17                	jne    f010419d <page_fault_handler+0x2d>
    	panic("page_fault_handler : page fault in kernel\n");
f0104186:	83 ec 04             	sub    $0x4,%esp
f0104189:	68 40 7f 10 f0       	push   $0xf0107f40
f010418e:	68 37 01 00 00       	push   $0x137
f0104193:	68 6f 7d 10 f0       	push   $0xf0107d6f
f0104198:	e8 cb be ff ff       	call   f0100068 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010419d:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01041a0:	e8 0b 1c 00 00       	call   f0105db0 <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041a5:	57                   	push   %edi
f01041a6:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01041a7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01041ae:	29 c2                	sub    %eax,%edx
f01041b0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01041b3:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041ba:	ff 70 48             	pushl  0x48(%eax)
f01041bd:	68 6c 7f 10 f0       	push   $0xf0107f6c
f01041c2:	e8 c6 fb ff ff       	call   f0103d8d <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01041c7:	89 1c 24             	mov    %ebx,(%esp)
f01041ca:	e8 1c fe ff ff       	call   f0103feb <print_trapframe>
	env_destroy(curenv);
f01041cf:	e8 dc 1b 00 00       	call   f0105db0 <cpunum>
f01041d4:	83 c4 04             	add    $0x4,%esp
f01041d7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01041de:	29 c2                	sub    %eax,%edx
f01041e0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01041e3:	ff 34 85 28 00 2e f0 	pushl  -0xfd1ffd8(,%eax,4)
f01041ea:	e8 7d f8 ff ff       	call   f0103a6c <env_destroy>
f01041ef:	83 c4 10             	add    $0x10,%esp
}
f01041f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01041f5:	5b                   	pop    %ebx
f01041f6:	5e                   	pop    %esi
f01041f7:	5f                   	pop    %edi
f01041f8:	c9                   	leave  
f01041f9:	c3                   	ret    

f01041fa <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01041fa:	55                   	push   %ebp
f01041fb:	89 e5                	mov    %esp,%ebp
f01041fd:	57                   	push   %edi
f01041fe:	56                   	push   %esi
f01041ff:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104202:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104203:	83 3d 80 fe 2d f0 00 	cmpl   $0x0,0xf02dfe80
f010420a:	74 01                	je     f010420d <trap+0x13>
		asm volatile("hlt");
f010420c:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010420d:	e8 9e 1b 00 00       	call   f0105db0 <cpunum>
f0104212:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104219:	29 c2                	sub    %eax,%edx
f010421b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010421e:	8d 14 85 20 00 2e f0 	lea    -0xfd1ffe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104225:	b8 01 00 00 00       	mov    $0x1,%eax
f010422a:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010422e:	83 f8 02             	cmp    $0x2,%eax
f0104231:	75 10                	jne    f0104243 <trap+0x49>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104233:	83 ec 0c             	sub    $0xc,%esp
f0104236:	68 40 84 12 f0       	push   $0xf0128440
f010423b:	e8 27 1e 00 00       	call   f0106067 <spin_lock>
f0104240:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104243:	9c                   	pushf  
f0104244:	58                   	pop    %eax
		lock_kernel();

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104245:	f6 c4 02             	test   $0x2,%ah
f0104248:	74 19                	je     f0104263 <trap+0x69>
f010424a:	68 7b 7d 10 f0       	push   $0xf0107d7b
f010424f:	68 57 78 10 f0       	push   $0xf0107857
f0104254:	68 01 01 00 00       	push   $0x101
f0104259:	68 6f 7d 10 f0       	push   $0xf0107d6f
f010425e:	e8 05 be ff ff       	call   f0100068 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104263:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104267:	83 e0 03             	and    $0x3,%eax
f010426a:	83 f8 03             	cmp    $0x3,%eax
f010426d:	0f 85 dc 00 00 00    	jne    f010434f <trap+0x155>
f0104273:	83 ec 0c             	sub    $0xc,%esp
f0104276:	68 40 84 12 f0       	push   $0xf0128440
f010427b:	e8 e7 1d 00 00       	call   f0106067 <spin_lock>
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();

		assert(curenv);
f0104280:	e8 2b 1b 00 00       	call   f0105db0 <cpunum>
f0104285:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010428c:	29 c2                	sub    %eax,%edx
f010428e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104291:	83 c4 10             	add    $0x10,%esp
f0104294:	83 3c 85 28 00 2e f0 	cmpl   $0x0,-0xfd1ffd8(,%eax,4)
f010429b:	00 
f010429c:	75 19                	jne    f01042b7 <trap+0xbd>
f010429e:	68 94 7d 10 f0       	push   $0xf0107d94
f01042a3:	68 57 78 10 f0       	push   $0xf0107857
f01042a8:	68 0a 01 00 00       	push   $0x10a
f01042ad:	68 6f 7d 10 f0       	push   $0xf0107d6f
f01042b2:	e8 b1 bd ff ff       	call   f0100068 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01042b7:	e8 f4 1a 00 00       	call   f0105db0 <cpunum>
f01042bc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01042c3:	29 c2                	sub    %eax,%edx
f01042c5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01042c8:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f01042cf:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01042d3:	75 41                	jne    f0104316 <trap+0x11c>
			env_free(curenv);
f01042d5:	e8 d6 1a 00 00       	call   f0105db0 <cpunum>
f01042da:	83 ec 0c             	sub    $0xc,%esp
f01042dd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01042e4:	29 c2                	sub    %eax,%edx
f01042e6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01042e9:	ff 34 85 28 00 2e f0 	pushl  -0xfd1ffd8(,%eax,4)
f01042f0:	e8 9a f5 ff ff       	call   f010388f <env_free>
			curenv = NULL;
f01042f5:	e8 b6 1a 00 00       	call   f0105db0 <cpunum>
f01042fa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104301:	29 c2                	sub    %eax,%edx
f0104303:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104306:	c7 04 85 28 00 2e f0 	movl   $0x0,-0xfd1ffd8(,%eax,4)
f010430d:	00 00 00 00 
			sched_yield();
f0104311:	e8 5c 03 00 00       	call   f0104672 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104316:	e8 95 1a 00 00       	call   f0105db0 <cpunum>
f010431b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104322:	29 c2                	sub    %eax,%edx
f0104324:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104327:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f010432e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104333:	89 c7                	mov    %eax,%edi
f0104335:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104337:	e8 74 1a 00 00       	call   f0105db0 <cpunum>
f010433c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104343:	29 c2                	sub    %eax,%edx
f0104345:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104348:	8b 34 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010434f:	89 35 60 fa 2d f0    	mov    %esi,0xf02dfa60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
    cprintf("CPU %d, TRAP NUM : %u\n", cpunum(), tf->tf_trapno);
f0104355:	8b 7e 28             	mov    0x28(%esi),%edi
f0104358:	e8 53 1a 00 00       	call   f0105db0 <cpunum>
f010435d:	83 ec 04             	sub    $0x4,%esp
f0104360:	57                   	push   %edi
f0104361:	50                   	push   %eax
f0104362:	68 9b 7d 10 f0       	push   $0xf0107d9b
f0104367:	e8 21 fa ff ff       	call   f0103d8d <cprintf>
    int r;

	if (tf->tf_trapno == T_DEBUG) {
f010436c:	8b 46 28             	mov    0x28(%esi),%eax
f010436f:	83 c4 10             	add    $0x10,%esp
f0104372:	83 f8 01             	cmp    $0x1,%eax
f0104375:	75 11                	jne    f0104388 <trap+0x18e>
		monitor(tf);
f0104377:	83 ec 0c             	sub    $0xc,%esp
f010437a:	56                   	push   %esi
f010437b:	e8 e9 cc ff ff       	call   f0101069 <monitor>
f0104380:	83 c4 10             	add    $0x10,%esp
f0104383:	e9 d7 00 00 00       	jmp    f010445f <trap+0x265>
		return;
	}
	if (tf->tf_trapno == T_PGFLT) {
f0104388:	83 f8 0e             	cmp    $0xe,%eax
f010438b:	75 11                	jne    f010439e <trap+0x1a4>
		page_fault_handler(tf);
f010438d:	83 ec 0c             	sub    $0xc,%esp
f0104390:	56                   	push   %esi
f0104391:	e8 da fd ff ff       	call   f0104170 <page_fault_handler>
f0104396:	83 c4 10             	add    $0x10,%esp
f0104399:	e9 c1 00 00 00       	jmp    f010445f <trap+0x265>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f010439e:	83 f8 03             	cmp    $0x3,%eax
f01043a1:	75 11                	jne    f01043b4 <trap+0x1ba>
		monitor(tf);
f01043a3:	83 ec 0c             	sub    $0xc,%esp
f01043a6:	56                   	push   %esi
f01043a7:	e8 bd cc ff ff       	call   f0101069 <monitor>
f01043ac:	83 c4 10             	add    $0x10,%esp
f01043af:	e9 ab 00 00 00       	jmp    f010445f <trap+0x265>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f01043b4:	83 f8 30             	cmp    $0x30,%eax
f01043b7:	75 3a                	jne    f01043f3 <trap+0x1f9>
		r = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f01043b9:	83 ec 08             	sub    $0x8,%esp
f01043bc:	ff 76 04             	pushl  0x4(%esi)
f01043bf:	ff 36                	pushl  (%esi)
f01043c1:	ff 76 10             	pushl  0x10(%esi)
f01043c4:	ff 76 18             	pushl  0x18(%esi)
f01043c7:	ff 76 14             	pushl  0x14(%esi)
f01043ca:	ff 76 1c             	pushl  0x1c(%esi)
f01043cd:	e8 be 03 00 00       	call   f0104790 <syscall>
                       tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
        if (r < 0)
f01043d2:	83 c4 20             	add    $0x20,%esp
f01043d5:	85 c0                	test   %eax,%eax
f01043d7:	79 15                	jns    f01043ee <trap+0x1f4>
            panic("trap.c/syscall : %e\n", r);
f01043d9:	50                   	push   %eax
f01043da:	68 b2 7d 10 f0       	push   $0xf0107db2
f01043df:	68 d1 00 00 00       	push   $0xd1
f01043e4:	68 6f 7d 10 f0       	push   $0xf0107d6f
f01043e9:	e8 7a bc ff ff       	call   f0100068 <_panic>
        else
            tf->tf_regs.reg_eax = r;
f01043ee:	89 46 1c             	mov    %eax,0x1c(%esi)
f01043f1:	eb 6c                	jmp    f010445f <trap+0x265>
		return;
	}
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01043f3:	83 f8 27             	cmp    $0x27,%eax
f01043f6:	75 1a                	jne    f0104412 <trap+0x218>
		cprintf("Spurious interrupt on irq 7\n");
f01043f8:	83 ec 0c             	sub    $0xc,%esp
f01043fb:	68 c7 7d 10 f0       	push   $0xf0107dc7
f0104400:	e8 88 f9 ff ff       	call   f0103d8d <cprintf>
		print_trapframe(tf);
f0104405:	89 34 24             	mov    %esi,(%esp)
f0104408:	e8 de fb ff ff       	call   f0103feb <print_trapframe>
f010440d:	83 c4 10             	add    $0x10,%esp
f0104410:	eb 4d                	jmp    f010445f <trap+0x265>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104412:	83 ec 0c             	sub    $0xc,%esp
f0104415:	56                   	push   %esi
f0104416:	e8 d0 fb ff ff       	call   f0103feb <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010441b:	83 c4 10             	add    $0x10,%esp
f010441e:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104423:	75 17                	jne    f010443c <trap+0x242>
		panic("unhandled trap in kernel");
f0104425:	83 ec 04             	sub    $0x4,%esp
f0104428:	68 e4 7d 10 f0       	push   $0xf0107de4
f010442d:	68 e6 00 00 00       	push   $0xe6
f0104432:	68 6f 7d 10 f0       	push   $0xf0107d6f
f0104437:	e8 2c bc ff ff       	call   f0100068 <_panic>
	else {
		env_destroy(curenv);
f010443c:	e8 6f 19 00 00       	call   f0105db0 <cpunum>
f0104441:	83 ec 0c             	sub    $0xc,%esp
f0104444:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010444b:	29 c2                	sub    %eax,%edx
f010444d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104450:	ff 34 85 28 00 2e f0 	pushl  -0xfd1ffd8(,%eax,4)
f0104457:	e8 10 f6 ff ff       	call   f0103a6c <env_destroy>
f010445c:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010445f:	e8 4c 19 00 00       	call   f0105db0 <cpunum>
f0104464:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010446b:	29 c2                	sub    %eax,%edx
f010446d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104470:	83 3c 85 28 00 2e f0 	cmpl   $0x0,-0xfd1ffd8(,%eax,4)
f0104477:	00 
f0104478:	74 3e                	je     f01044b8 <trap+0x2be>
f010447a:	e8 31 19 00 00       	call   f0105db0 <cpunum>
f010447f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104486:	29 c2                	sub    %eax,%edx
f0104488:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010448b:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f0104492:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104496:	75 20                	jne    f01044b8 <trap+0x2be>
		env_run(curenv);
f0104498:	e8 13 19 00 00       	call   f0105db0 <cpunum>
f010449d:	83 ec 0c             	sub    $0xc,%esp
f01044a0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044a7:	29 c2                	sub    %eax,%edx
f01044a9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01044ac:	ff 34 85 28 00 2e f0 	pushl  -0xfd1ffd8(,%eax,4)
f01044b3:	e8 71 f6 ff ff       	call   f0103b29 <env_run>
	else
		sched_yield();
f01044b8:	e8 b5 01 00 00       	call   f0104672 <sched_yield>
f01044bd:	00 00                	add    %al,(%eax)
	...

f01044c0 <vec0>:
.data
.align 2
.globl vectors
vectors:
.text
	MYTH_NOEC(vec0, T_DIVIDE)
f01044c0:	6a 00                	push   $0x0
f01044c2:	6a 00                	push   $0x0
f01044c4:	e9 29 3f 02 00       	jmp    f01283f2 <_alltraps>
f01044c9:	90                   	nop

f01044ca <vec1>:
 	MYTH_NOEC(vec1, T_DEBUG)
f01044ca:	6a 00                	push   $0x0
f01044cc:	6a 01                	push   $0x1
f01044ce:	e9 1f 3f 02 00       	jmp    f01283f2 <_alltraps>
f01044d3:	90                   	nop

f01044d4 <vec2>:
 	MYTH_NOEC(vec2, T_NMI)
f01044d4:	6a 00                	push   $0x0
f01044d6:	6a 02                	push   $0x2
f01044d8:	e9 15 3f 02 00       	jmp    f01283f2 <_alltraps>
f01044dd:	90                   	nop

f01044de <vec3>:
 	MYTH_NOEC(vec3, T_BRKPT)
f01044de:	6a 00                	push   $0x0
f01044e0:	6a 03                	push   $0x3
f01044e2:	e9 0b 3f 02 00       	jmp    f01283f2 <_alltraps>
f01044e7:	90                   	nop

f01044e8 <vec4>:
 	MYTH_NOEC(vec4, T_OFLOW)
f01044e8:	6a 00                	push   $0x0
f01044ea:	6a 04                	push   $0x4
f01044ec:	e9 01 3f 02 00       	jmp    f01283f2 <_alltraps>
f01044f1:	90                   	nop

f01044f2 <vec6>:
 	MYTH_NULL()
 	MYTH_NOEC(vec6, T_BOUND)
f01044f2:	6a 00                	push   $0x0
f01044f4:	6a 05                	push   $0x5
f01044f6:	e9 f7 3e 02 00       	jmp    f01283f2 <_alltraps>
f01044fb:	90                   	nop

f01044fc <vec7>:
	MYTH_NOEC(vec7, T_DEVICE)
f01044fc:	6a 00                	push   $0x0
f01044fe:	6a 07                	push   $0x7
f0104500:	e9 ed 3e 02 00       	jmp    f01283f2 <_alltraps>
f0104505:	90                   	nop

f0104506 <vec8>:
 	MYTH_NOEC(vec8, T_DBLFLT)
f0104506:	6a 00                	push   $0x0
f0104508:	6a 08                	push   $0x8
f010450a:	e9 e3 3e 02 00       	jmp    f01283f2 <_alltraps>
f010450f:	90                   	nop

f0104510 <vec10>:
 	MYTH_NULL()
 	MYTH(vec10, T_TSS)
f0104510:	6a 0a                	push   $0xa
f0104512:	e9 db 3e 02 00       	jmp    f01283f2 <_alltraps>
f0104517:	90                   	nop

f0104518 <vec11>:
 	MYTH(vec11, T_SEGNP)
f0104518:	6a 0b                	push   $0xb
f010451a:	e9 d3 3e 02 00       	jmp    f01283f2 <_alltraps>
f010451f:	90                   	nop

f0104520 <vec12>:
 	MYTH(vec12, T_STACK)
f0104520:	6a 0c                	push   $0xc
f0104522:	e9 cb 3e 02 00       	jmp    f01283f2 <_alltraps>
f0104527:	90                   	nop

f0104528 <vec13>:
 	MYTH(vec13, T_GPFLT)
f0104528:	6a 0d                	push   $0xd
f010452a:	e9 c3 3e 02 00       	jmp    f01283f2 <_alltraps>
f010452f:	90                   	nop

f0104530 <vec14>:
 	MYTH(vec14, T_PGFLT) 
f0104530:	6a 0e                	push   $0xe
f0104532:	e9 bb 3e 02 00       	jmp    f01283f2 <_alltraps>
f0104537:	90                   	nop

f0104538 <vec16>:
 	MYTH_NULL()
 	MYTH_NOEC(vec16, T_FPERR)
f0104538:	6a 00                	push   $0x0
f010453a:	6a 10                	push   $0x10
f010453c:	e9 b1 3e 02 00       	jmp    f01283f2 <_alltraps>
f0104541:	90                   	nop

f0104542 <vec17>:
 	MYTH(vec17, T_ALIGN)
f0104542:	6a 11                	push   $0x11
f0104544:	e9 a9 3e 02 00       	jmp    f01283f2 <_alltraps>
f0104549:	90                   	nop

f010454a <vec18>:
 	MYTH_NOEC(vec18, T_MCHK)
f010454a:	6a 00                	push   $0x0
f010454c:	6a 12                	push   $0x12
f010454e:	e9 9f 3e 02 00       	jmp    f01283f2 <_alltraps>
f0104553:	90                   	nop

f0104554 <vec19>:
 	MYTH_NOEC(vec19, T_SIMDERR)
f0104554:	6a 00                	push   $0x0
f0104556:	6a 13                	push   $0x13
f0104558:	e9 95 3e 02 00       	jmp    f01283f2 <_alltraps>
f010455d:	00 00                	add    %al,(%eax)
	...

f0104560 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104560:	55                   	push   %ebp
f0104561:	89 e5                	mov    %esp,%ebp
f0104563:	83 ec 08             	sub    $0x8,%esp
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104566:	8b 15 3c f2 2d f0    	mov    0xf02df23c,%edx
f010456c:	8b 42 54             	mov    0x54(%edx),%eax
f010456f:	83 e8 02             	sub    $0x2,%eax
f0104572:	83 f8 01             	cmp    $0x1,%eax
f0104575:	76 46                	jbe    f01045bd <sched_halt+0x5d>
			else cprintf("ENV_RUNNING\n");
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
f0104577:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010457c:	8b 8a d0 00 00 00    	mov    0xd0(%edx),%ecx
f0104582:	83 e9 02             	sub    $0x2,%ecx
f0104585:	83 f9 01             	cmp    $0x1,%ecx
f0104588:	76 0d                	jbe    f0104597 <sched_halt+0x37>
			else cprintf("ENV_RUNNING\n");
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
f010458a:	40                   	inc    %eax
f010458b:	83 c2 7c             	add    $0x7c,%edx
f010458e:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104593:	75 e7                	jne    f010457c <sched_halt+0x1c>
f0104595:	eb 07                	jmp    f010459e <sched_halt+0x3e>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	
	if (i == NENV) {
f0104597:	3d 00 04 00 00       	cmp    $0x400,%eax
f010459c:	75 1f                	jne    f01045bd <sched_halt+0x5d>
		cprintf("No runnable environments in the system!\n");
f010459e:	83 ec 0c             	sub    $0xc,%esp
f01045a1:	68 f0 7f 10 f0       	push   $0xf0107ff0
f01045a6:	e8 e2 f7 ff ff       	call   f0103d8d <cprintf>
f01045ab:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01045ae:	83 ec 0c             	sub    $0xc,%esp
f01045b1:	6a 00                	push   $0x0
f01045b3:	e8 b1 ca ff ff       	call   f0101069 <monitor>
f01045b8:	83 c4 10             	add    $0x10,%esp
f01045bb:	eb f1                	jmp    f01045ae <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01045bd:	e8 ee 17 00 00       	call   f0105db0 <cpunum>
f01045c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c5:	c7 80 28 00 2e f0 00 	movl   $0x0,-0xfd1ffd8(%eax)
f01045cc:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01045cf:	a1 8c fe 2d f0       	mov    0xf02dfe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01045d4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01045d9:	77 12                	ja     f01045ed <sched_halt+0x8d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01045db:	50                   	push   %eax
f01045dc:	68 a4 64 10 f0       	push   $0xf01064a4
f01045e1:	6a 57                	push   $0x57
f01045e3:	68 19 80 10 f0       	push   $0xf0108019
f01045e8:	e8 7b ba ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01045ed:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01045f2:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01045f5:	e8 b6 17 00 00       	call   f0105db0 <cpunum>
f01045fa:	6b d0 74             	imul   $0x74,%eax,%edx
f01045fd:	81 c2 20 00 2e f0    	add    $0xf02e0020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104603:	b8 02 00 00 00       	mov    $0x2,%eax
f0104608:	f0 87 42 04          	lock xchg %eax,0x4(%edx)

	// Release the big kernel lock as if we were "leaving" the kernel
	
	cprintf("OVER %d\n", thiscpu->cpu_id);
f010460c:	e8 9f 17 00 00       	call   f0105db0 <cpunum>
f0104611:	83 ec 08             	sub    $0x8,%esp
f0104614:	6b c0 74             	imul   $0x74,%eax,%eax
f0104617:	0f b6 80 20 00 2e f0 	movzbl -0xfd1ffe0(%eax),%eax
f010461e:	50                   	push   %eax
f010461f:	68 26 80 10 f0       	push   $0xf0108026
f0104624:	e8 64 f7 ff ff       	call   f0103d8d <cprintf>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104629:	c7 04 24 40 84 12 f0 	movl   $0xf0128440,(%esp)
f0104630:	e8 ed 1a 00 00       	call   f0106122 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104635:	f3 90                	pause  

	unlock_kernel();
	
	cprintf("YY %x\n", thiscpu->cpu_ts.ts_esp0);
f0104637:	e8 74 17 00 00       	call   f0105db0 <cpunum>
f010463c:	83 c4 08             	add    $0x8,%esp
f010463f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104642:	ff b0 30 00 2e f0    	pushl  -0xfd1ffd0(%eax)
f0104648:	68 2f 80 10 f0       	push   $0xf010802f
f010464d:	e8 3b f7 ff ff       	call   f0103d8d <cprintf>
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104652:	e8 59 17 00 00       	call   f0105db0 <cpunum>
f0104657:	6b c0 74             	imul   $0x74,%eax,%eax
	unlock_kernel();
	
	cprintf("YY %x\n", thiscpu->cpu_ts.ts_esp0);

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010465a:	8b 80 30 00 2e f0    	mov    -0xfd1ffd0(%eax),%eax
f0104660:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104665:	89 c4                	mov    %eax,%esp
f0104667:	6a 00                	push   $0x0
f0104669:	6a 00                	push   $0x0
f010466b:	fb                   	sti    
f010466c:	f4                   	hlt    
f010466d:	83 c4 10             	add    $0x10,%esp
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104670:	c9                   	leave  
f0104671:	c3                   	ret    

f0104672 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104672:	55                   	push   %ebp
f0104673:	89 e5                	mov    %esp,%ebp
f0104675:	56                   	push   %esi
f0104676:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int now_env, i;
	if (curenv) {			// thiscpu->cpu_env
f0104677:	e8 34 17 00 00       	call   f0105db0 <cpunum>
f010467c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104683:	29 c2                	sub    %eax,%edx
f0104685:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104688:	83 3c 85 28 00 2e f0 	cmpl   $0x0,-0xfd1ffd8(,%eax,4)
f010468f:	00 
f0104690:	74 2e                	je     f01046c0 <sched_yield+0x4e>
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
f0104692:	e8 19 17 00 00       	call   f0105db0 <cpunum>
f0104697:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010469e:	29 c2                	sub    %eax,%edx
f01046a0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01046a3:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f01046aa:	8b 40 48             	mov    0x48(%eax),%eax
f01046ad:	8d 40 01             	lea    0x1(%eax),%eax
f01046b0:	25 ff 03 00 00       	and    $0x3ff,%eax
f01046b5:	79 0e                	jns    f01046c5 <sched_yield+0x53>
f01046b7:	48                   	dec    %eax
f01046b8:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f01046bd:	40                   	inc    %eax
f01046be:	eb 05                	jmp    f01046c5 <sched_yield+0x53>
	} else {
		now_env = 0;
f01046c0:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
		if (envs[now_env].env_status == ENV_RUNNABLE) {
f01046c5:	8b 1d 3c f2 2d f0    	mov    0xf02df23c,%ebx
f01046cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01046d2:	89 c1                	mov    %eax,%ecx
f01046d4:	c1 e1 07             	shl    $0x7,%ecx
f01046d7:	29 d1                	sub    %edx,%ecx
f01046d9:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f01046dc:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f01046e0:	0f 85 8f 00 00 00    	jne    f0104775 <sched_yield+0x103>
f01046e6:	eb 26                	jmp    f010470e <sched_yield+0x9c>
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f01046e8:	40                   	inc    %eax
f01046e9:	25 ff 03 00 80       	and    $0x800003ff,%eax
f01046ee:	79 07                	jns    f01046f7 <sched_yield+0x85>
f01046f0:	48                   	dec    %eax
f01046f1:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f01046f6:	40                   	inc    %eax
		if (envs[now_env].env_status == ENV_RUNNABLE) {
f01046f7:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
f01046fe:	89 c1                	mov    %eax,%ecx
f0104700:	c1 e1 07             	shl    $0x7,%ecx
f0104703:	29 f1                	sub    %esi,%ecx
f0104705:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f0104708:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f010470c:	75 09                	jne    f0104717 <sched_yield+0xa5>
			//cprintf("I am CPU %d , I am in sched yield, I find ENV %d\n", thiscpu->cpu_id, now_env);
			env_run(&envs[now_env]);
f010470e:	83 ec 0c             	sub    $0xc,%esp
f0104711:	51                   	push   %ecx
f0104712:	e8 12 f4 ff ff       	call   f0103b29 <env_run>
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f0104717:	4a                   	dec    %edx
f0104718:	75 ce                	jne    f01046e8 <sched_yield+0x76>
		if (envs[now_env].env_status == ENV_RUNNABLE) {
			//cprintf("I am CPU %d , I am in sched yield, I find ENV %d\n", thiscpu->cpu_id, now_env);
			env_run(&envs[now_env]);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING) {
f010471a:	e8 91 16 00 00       	call   f0105db0 <cpunum>
f010471f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104726:	29 c2                	sub    %eax,%edx
f0104728:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010472b:	83 3c 85 28 00 2e f0 	cmpl   $0x0,-0xfd1ffd8(,%eax,4)
f0104732:	00 
f0104733:	74 34                	je     f0104769 <sched_yield+0xf7>
f0104735:	e8 76 16 00 00       	call   f0105db0 <cpunum>
f010473a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104741:	29 c2                	sub    %eax,%edx
f0104743:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104746:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f010474d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104751:	75 16                	jne    f0104769 <sched_yield+0xf7>
		env_run(curenv);
f0104753:	e8 58 16 00 00       	call   f0105db0 <cpunum>
f0104758:	83 ec 0c             	sub    $0xc,%esp
f010475b:	6b c0 74             	imul   $0x74,%eax,%eax
f010475e:	ff b0 28 00 2e f0    	pushl  -0xfd1ffd8(%eax)
f0104764:	e8 c0 f3 ff ff       	call   f0103b29 <env_run>
	}

	// sched_halt never returns
	sched_halt();
f0104769:	e8 f2 fd ff ff       	call   f0104560 <sched_halt>
}
f010476e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104771:	5b                   	pop    %ebx
f0104772:	5e                   	pop    %esi
f0104773:	c9                   	leave  
f0104774:	c3                   	ret    
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f0104775:	40                   	inc    %eax
f0104776:	25 ff 03 00 80       	and    $0x800003ff,%eax
f010477b:	79 07                	jns    f0104784 <sched_yield+0x112>
f010477d:	48                   	dec    %eax
f010477e:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0104783:	40                   	inc    %eax
f0104784:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0104789:	e9 69 ff ff ff       	jmp    f01046f7 <sched_yield+0x85>
	...

f0104790 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104790:	55                   	push   %ebp
f0104791:	89 e5                	mov    %esp,%ebp
f0104793:	57                   	push   %edi
f0104794:	56                   	push   %esi
f0104795:	53                   	push   %ebx
f0104796:	83 ec 1c             	sub    $0x1c,%esp
f0104799:	8b 45 08             	mov    0x8(%ebp),%eax
f010479c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010479f:	8b 75 10             	mov    0x10(%ebp),%esi
f01047a2:	8b 7d 14             	mov    0x14(%ebp),%edi
    // sys_page_unmap(envid_t envid, void *va)
    // sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// sys_exofork(void)
	// sys_env_set_status(envid_t envid, int status)

    switch (syscallno) {
f01047a5:	83 f8 0a             	cmp    $0xa,%eax
f01047a8:	0f 87 e7 03 00 00    	ja     f0104b95 <syscall+0x405>
f01047ae:	ff 24 85 90 80 10 f0 	jmp    *-0xfef7f70(,%eax,4)
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env * new_env;
	int r = env_alloc(&new_env, curenv->env_id);
f01047b5:	e8 f6 15 00 00       	call   f0105db0 <cpunum>
f01047ba:	83 ec 08             	sub    $0x8,%esp
f01047bd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01047c4:	29 c2                	sub    %eax,%edx
f01047c6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01047c9:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f01047d0:	ff 70 48             	pushl  0x48(%eax)
f01047d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047d6:	50                   	push   %eax
f01047d7:	e8 b5 ed ff ff       	call   f0103591 <env_alloc>
	if (r < 0) return r;
f01047dc:	83 c4 10             	add    $0x10,%esp
f01047df:	85 c0                	test   %eax,%eax
f01047e1:	0f 88 c5 03 00 00    	js     f0104bac <syscall+0x41c>
	
	new_env->env_status = ENV_NOT_RUNNABLE;
f01047e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047ea:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memcpy((void *)(&new_env->env_tf), (void*)(&curenv->env_tf), sizeof(struct Trapframe));
f01047f1:	e8 ba 15 00 00       	call   f0105db0 <cpunum>
f01047f6:	83 ec 04             	sub    $0x4,%esp
f01047f9:	6a 44                	push   $0x44
f01047fb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104802:	29 c2                	sub    %eax,%edx
f0104804:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104807:	ff 34 85 28 00 2e f0 	pushl  -0xfd1ffd8(,%eax,4)
f010480e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104811:	e8 1f 10 00 00       	call   f0105835 <memcpy>
	
	// for children environment, return 0
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104816:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104819:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return new_env->env_id;
f0104820:	8b 40 48             	mov    0x48(%eax),%eax
f0104823:	83 c4 10             	add    $0x10,%esp
	// sys_exofork(void)
	// sys_env_set_status(envid_t envid, int status)

    switch (syscallno) {
    	case SYS_exofork:
    		return sys_exofork();
f0104826:	e9 81 03 00 00       	jmp    f0104bac <syscall+0x41c>
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
f010482b:	83 fe 02             	cmp    $0x2,%esi
f010482e:	74 05                	je     f0104835 <syscall+0xa5>
f0104830:	83 fe 04             	cmp    $0x4,%esi
f0104833:	75 2a                	jne    f010485f <syscall+0xcf>
		return -E_INVAL;

	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104835:	83 ec 04             	sub    $0x4,%esp
f0104838:	6a 01                	push   $0x1
f010483a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010483d:	50                   	push   %eax
f010483e:	53                   	push   %ebx
f010483f:	e8 02 ec ff ff       	call   f0103446 <envid2env>
	if (r < 0) return r;
f0104844:	83 c4 10             	add    $0x10,%esp
f0104847:	85 c0                	test   %eax,%eax
f0104849:	0f 88 5d 03 00 00    	js     f0104bac <syscall+0x41c>
	env->env_status = status;
f010484f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104852:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f0104855:	b8 00 00 00 00       	mov    $0x0,%eax
f010485a:	e9 4d 03 00 00       	jmp    f0104bac <syscall+0x41c>
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
		return -E_INVAL;
f010485f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

    switch (syscallno) {
    	case SYS_exofork:
    		return sys_exofork();
    	case SYS_env_set_status:
    		return sys_env_set_status((envid_t)a1, (int)a2);
f0104864:	e9 43 03 00 00       	jmp    f0104bac <syscall+0x41c>
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104869:	83 ec 04             	sub    $0x4,%esp
f010486c:	6a 01                	push   $0x1
f010486e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104871:	50                   	push   %eax
f0104872:	53                   	push   %ebx
f0104873:	e8 ce eb ff ff       	call   f0103446 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104878:	83 c4 10             	add    $0x10,%esp
f010487b:	85 c0                	test   %eax,%eax
f010487d:	0f 88 88 00 00 00    	js     f010490b <syscall+0x17b>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104883:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104889:	0f 87 86 00 00 00    	ja     f0104915 <syscall+0x185>
f010488f:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0104895:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010489b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01048a0:	39 d6                	cmp    %edx,%esi
f01048a2:	0f 85 04 03 00 00    	jne    f0104bac <syscall+0x41c>
	
	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;
f01048a8:	89 fa                	mov    %edi,%edx
f01048aa:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f01048b0:	83 fa 05             	cmp    $0x5,%edx
f01048b3:	0f 85 f3 02 00 00    	jne    f0104bac <syscall+0x41c>

	struct PageInfo * pg = page_alloc(ALLOC_ZERO);
f01048b9:	83 ec 0c             	sub    $0xc,%esp
f01048bc:	6a 01                	push   $0x1
f01048be:	e8 42 cd ff ff       	call   f0101605 <page_alloc>
f01048c3:	89 c3                	mov    %eax,%ebx
	if (pg == NULL) return -E_NO_MEM;
f01048c5:	83 c4 10             	add    $0x10,%esp
f01048c8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01048cd:	85 db                	test   %ebx,%ebx
f01048cf:	0f 84 d7 02 00 00    	je     f0104bac <syscall+0x41c>
	if (page_insert(env->env_pgdir, pg, va, perm) < 0) {
f01048d5:	57                   	push   %edi
f01048d6:	56                   	push   %esi
f01048d7:	53                   	push   %ebx
f01048d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048db:	ff 70 60             	pushl  0x60(%eax)
f01048de:	e8 ce cf ff ff       	call   f01018b1 <page_insert>
f01048e3:	89 c2                	mov    %eax,%edx
f01048e5:	83 c4 10             	add    $0x10,%esp
		// page_insert fails, should free the page you allocated!  
		page_free(pg);
		return -E_NO_MEM;
	}
	return 0;
f01048e8:	b8 00 00 00 00       	mov    $0x0,%eax
	
	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;

	struct PageInfo * pg = page_alloc(ALLOC_ZERO);
	if (pg == NULL) return -E_NO_MEM;
	if (page_insert(env->env_pgdir, pg, va, perm) < 0) {
f01048ed:	85 d2                	test   %edx,%edx
f01048ef:	0f 89 b7 02 00 00    	jns    f0104bac <syscall+0x41c>
		// page_insert fails, should free the page you allocated!  
		page_free(pg);
f01048f5:	83 ec 0c             	sub    $0xc,%esp
f01048f8:	53                   	push   %ebx
f01048f9:	e8 91 cd ff ff       	call   f010168f <page_free>
f01048fe:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104901:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104906:	e9 a1 02 00 00       	jmp    f0104bac <syscall+0x41c>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;
f010490b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104910:	e9 97 02 00 00       	jmp    f0104bac <syscall+0x41c>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104915:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010491a:	e9 8d 02 00 00       	jmp    f0104bac <syscall+0x41c>
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	struct Env * dstenv, * srcenv;
	int r = envid2env(dstenvid, &dstenv, 1);
f010491f:	83 ec 04             	sub    $0x4,%esp
f0104922:	6a 01                	push   $0x1
f0104924:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104927:	50                   	push   %eax
f0104928:	57                   	push   %edi
f0104929:	e8 18 eb ff ff       	call   f0103446 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f010492e:	83 c4 10             	add    $0x10,%esp
f0104931:	85 c0                	test   %eax,%eax
f0104933:	0f 88 cd 00 00 00    	js     f0104a06 <syscall+0x276>
	r = envid2env(srcenvid, &srcenv, 1);
f0104939:	83 ec 04             	sub    $0x4,%esp
f010493c:	6a 01                	push   $0x1
f010493e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104941:	50                   	push   %eax
f0104942:	53                   	push   %ebx
f0104943:	e8 fe ea ff ff       	call   f0103446 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104948:	83 c4 10             	add    $0x10,%esp
f010494b:	85 c0                	test   %eax,%eax
f010494d:	0f 88 bd 00 00 00    	js     f0104a10 <syscall+0x280>

	if ((uint32_t)srcva >= UTOP || ROUNDUP(srcva, PGSIZE) != srcva) return -E_INVAL;
f0104953:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104958:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f010495e:	0f 87 48 02 00 00    	ja     f0104bac <syscall+0x41c>
f0104964:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f010496a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104970:	39 d6                	cmp    %edx,%esi
f0104972:	0f 85 34 02 00 00    	jne    f0104bac <syscall+0x41c>
	if ((uint32_t)dstva >= UTOP || ROUNDUP(dstva, PGSIZE) != dstva) return -E_INVAL;
f0104978:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010497f:	0f 87 27 02 00 00    	ja     f0104bac <syscall+0x41c>
f0104985:	8b 55 18             	mov    0x18(%ebp),%edx
f0104988:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f010498e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104994:	39 55 18             	cmp    %edx,0x18(%ebp)
f0104997:	0f 85 0f 02 00 00    	jne    f0104bac <syscall+0x41c>


	// struct PageInfo * page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
	struct PageInfo * pg;
	pte_t * pte;
	pg = page_lookup(srcenv->env_pgdir, srcva, &pte);
f010499d:	83 ec 04             	sub    $0x4,%esp
f01049a0:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01049a3:	50                   	push   %eax
f01049a4:	56                   	push   %esi
f01049a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049a8:	ff 70 60             	pushl  0x60(%eax)
f01049ab:	e8 05 ce ff ff       	call   f01017b5 <page_lookup>
f01049b0:	89 c2                	mov    %eax,%edx
	if (pg == NULL) return -E_INVAL;		
f01049b2:	83 c4 10             	add    $0x10,%esp
f01049b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01049ba:	85 d2                	test   %edx,%edx
f01049bc:	0f 84 ea 01 00 00    	je     f0104bac <syscall+0x41c>

	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;
f01049c2:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f01049c5:	81 e1 fd f1 ff ff    	and    $0xfffff1fd,%ecx
f01049cb:	83 f9 05             	cmp    $0x5,%ecx
f01049ce:	0f 85 d8 01 00 00    	jne    f0104bac <syscall+0x41c>
	
	if ((perm & PTE_W) && ((*pte) & PTE_W) == 0) return -E_INVAL;
f01049d4:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01049d8:	74 0c                	je     f01049e6 <syscall+0x256>
f01049da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01049dd:	f6 01 02             	testb  $0x2,(%ecx)
f01049e0:	0f 84 c6 01 00 00    	je     f0104bac <syscall+0x41c>

	// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	if (page_insert(dstenv->env_pgdir, pg, dstva, perm) < 0) return -E_NO_MEM;
f01049e6:	ff 75 1c             	pushl  0x1c(%ebp)
f01049e9:	ff 75 18             	pushl  0x18(%ebp)
f01049ec:	52                   	push   %edx
f01049ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049f0:	ff 70 60             	pushl  0x60(%eax)
f01049f3:	e8 b9 ce ff ff       	call   f01018b1 <page_insert>
f01049f8:	83 c4 10             	add    $0x10,%esp
f01049fb:	c1 f8 1f             	sar    $0x1f,%eax
f01049fe:	83 e0 fc             	and    $0xfffffffc,%eax
f0104a01:	e9 a6 01 00 00       	jmp    f0104bac <syscall+0x41c>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	struct Env * dstenv, * srcenv;
	int r = envid2env(dstenvid, &dstenv, 1);
	if (r < 0) return -E_BAD_ENV;
f0104a06:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104a0b:	e9 9c 01 00 00       	jmp    f0104bac <syscall+0x41c>
	r = envid2env(srcenvid, &srcenv, 1);
	if (r < 0) return -E_BAD_ENV;
f0104a10:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104a15:	e9 92 01 00 00       	jmp    f0104bac <syscall+0x41c>
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104a1a:	83 ec 04             	sub    $0x4,%esp
f0104a1d:	6a 01                	push   $0x1
f0104a1f:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104a22:	50                   	push   %eax
f0104a23:	53                   	push   %ebx
f0104a24:	e8 1d ea ff ff       	call   f0103446 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104a29:	83 c4 10             	add    $0x10,%esp
f0104a2c:	85 c0                	test   %eax,%eax
f0104a2e:	78 3d                	js     f0104a6d <syscall+0x2dd>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104a30:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104a36:	77 3f                	ja     f0104a77 <syscall+0x2e7>
f0104a38:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0104a3e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104a44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a49:	39 d6                	cmp    %edx,%esi
f0104a4b:	0f 85 5b 01 00 00    	jne    f0104bac <syscall+0x41c>
	
	// void page_remove(pde_t *pgdir, void *va)
	page_remove(env->env_pgdir, va);
f0104a51:	83 ec 08             	sub    $0x8,%esp
f0104a54:	56                   	push   %esi
f0104a55:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104a58:	ff 70 60             	pushl  0x60(%eax)
f0104a5b:	e8 04 ce ff ff       	call   f0101864 <page_remove>
f0104a60:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104a63:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a68:	e9 3f 01 00 00       	jmp    f0104bac <syscall+0x41c>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;
f0104a6d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104a72:	e9 35 01 00 00       	jmp    f0104bac <syscall+0x41c>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104a77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a7c:	e9 2b 01 00 00       	jmp    f0104bac <syscall+0x41c>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104a81:	e8 ec fb ff ff       	call   f0104672 <sched_yield>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, (void *)s, len, PTE_U);
f0104a86:	e8 25 13 00 00       	call   f0105db0 <cpunum>
f0104a8b:	6a 04                	push   $0x4
f0104a8d:	56                   	push   %esi
f0104a8e:	53                   	push   %ebx
f0104a8f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104a96:	29 c2                	sub    %eax,%edx
f0104a98:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a9b:	ff 34 85 28 00 2e f0 	pushl  -0xfd1ffd8(,%eax,4)
f0104aa2:	e8 cf e8 ff ff       	call   f0103376 <user_mem_assert>
    
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104aa7:	83 c4 0c             	add    $0xc,%esp
f0104aaa:	53                   	push   %ebx
f0104aab:	56                   	push   %esi
f0104aac:	68 5f 68 10 f0       	push   $0xf010685f
f0104ab1:	e8 d7 f2 ff ff       	call   f0103d8d <cprintf>
f0104ab6:	83 c4 10             	add    $0x10,%esp
    		sys_yield();
    		return 0;
    		break;
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
f0104ab9:	b8 00 00 00 00       	mov    $0x0,%eax
f0104abe:	e9 e9 00 00 00       	jmp    f0104bac <syscall+0x41c>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104ac3:	e8 cc bb ff ff       	call   f0100694 <cons_getc>
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
            break;
        case SYS_cgetc:
            return sys_cgetc();
f0104ac8:	e9 df 00 00 00       	jmp    f0104bac <syscall+0x41c>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104acd:	e8 de 12 00 00       	call   f0105db0 <cpunum>
f0104ad2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ad9:	29 c2                	sub    %eax,%edx
f0104adb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ade:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f0104ae5:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_cgetc:
            return sys_cgetc();
            return 0;
            break;
        case SYS_getenvid:
            return sys_getenvid();
f0104ae8:	e9 bf 00 00 00       	jmp    f0104bac <syscall+0x41c>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104aed:	83 ec 04             	sub    $0x4,%esp
f0104af0:	6a 01                	push   $0x1
f0104af2:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104af5:	50                   	push   %eax
f0104af6:	53                   	push   %ebx
f0104af7:	e8 4a e9 ff ff       	call   f0103446 <envid2env>
f0104afc:	83 c4 10             	add    $0x10,%esp
f0104aff:	85 c0                	test   %eax,%eax
f0104b01:	0f 88 a5 00 00 00    	js     f0104bac <syscall+0x41c>
		return r;
	if (e == curenv)
f0104b07:	e8 a4 12 00 00       	call   f0105db0 <cpunum>
f0104b0c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104b0f:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0104b16:	29 c1                	sub    %eax,%ecx
f0104b18:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0104b1b:	39 14 85 28 00 2e f0 	cmp    %edx,-0xfd1ffd8(,%eax,4)
f0104b22:	75 2d                	jne    f0104b51 <syscall+0x3c1>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104b24:	e8 87 12 00 00       	call   f0105db0 <cpunum>
f0104b29:	83 ec 08             	sub    $0x8,%esp
f0104b2c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b33:	29 c2                	sub    %eax,%edx
f0104b35:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b38:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f0104b3f:	ff 70 48             	pushl  0x48(%eax)
f0104b42:	68 36 80 10 f0       	push   $0xf0108036
f0104b47:	e8 41 f2 ff ff       	call   f0103d8d <cprintf>
f0104b4c:	83 c4 10             	add    $0x10,%esp
f0104b4f:	eb 2f                	jmp    f0104b80 <syscall+0x3f0>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104b51:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104b54:	e8 57 12 00 00       	call   f0105db0 <cpunum>
f0104b59:	83 ec 04             	sub    $0x4,%esp
f0104b5c:	53                   	push   %ebx
f0104b5d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b64:	29 c2                	sub    %eax,%edx
f0104b66:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b69:	8b 04 85 28 00 2e f0 	mov    -0xfd1ffd8(,%eax,4),%eax
f0104b70:	ff 70 48             	pushl  0x48(%eax)
f0104b73:	68 51 80 10 f0       	push   $0xf0108051
f0104b78:	e8 10 f2 ff ff       	call   f0103d8d <cprintf>
f0104b7d:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104b80:	83 ec 0c             	sub    $0xc,%esp
f0104b83:	ff 75 dc             	pushl  -0x24(%ebp)
f0104b86:	e8 e1 ee ff ff       	call   f0103a6c <env_destroy>
f0104b8b:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104b8e:	b8 00 00 00 00       	mov    $0x0,%eax
            break;
        case SYS_getenvid:
            return sys_getenvid();
            break;
        case SYS_env_destroy:
            return sys_env_destroy(a1);
f0104b93:	eb 17                	jmp    f0104bac <syscall+0x41c>
            break;
        dafult:
            return -E_INVAL;
	}
    panic("syscall not implemented");
f0104b95:	83 ec 04             	sub    $0x4,%esp
f0104b98:	68 69 80 10 f0       	push   $0xf0108069
f0104b9d:	68 7f 01 00 00       	push   $0x17f
f0104ba2:	68 81 80 10 f0       	push   $0xf0108081
f0104ba7:	e8 bc b4 ff ff       	call   f0100068 <_panic>
}
f0104bac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104baf:	5b                   	pop    %ebx
f0104bb0:	5e                   	pop    %esi
f0104bb1:	5f                   	pop    %edi
f0104bb2:	c9                   	leave  
f0104bb3:	c3                   	ret    

f0104bb4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104bb4:	55                   	push   %ebp
f0104bb5:	89 e5                	mov    %esp,%ebp
f0104bb7:	57                   	push   %edi
f0104bb8:	56                   	push   %esi
f0104bb9:	53                   	push   %ebx
f0104bba:	83 ec 14             	sub    $0x14,%esp
f0104bbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104bc0:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0104bc3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104bc6:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104bc9:	8b 1a                	mov    (%edx),%ebx
f0104bcb:	8b 01                	mov    (%ecx),%eax
f0104bcd:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0104bd0:	39 c3                	cmp    %eax,%ebx
f0104bd2:	0f 8f 97 00 00 00    	jg     f0104c6f <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0104bd8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104bdf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104be2:	01 d8                	add    %ebx,%eax
f0104be4:	89 c7                	mov    %eax,%edi
f0104be6:	c1 ef 1f             	shr    $0x1f,%edi
f0104be9:	01 c7                	add    %eax,%edi
f0104beb:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104bed:	39 df                	cmp    %ebx,%edi
f0104bef:	7c 31                	jl     f0104c22 <stab_binsearch+0x6e>
f0104bf1:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104bf4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104bf7:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0104bfc:	39 f0                	cmp    %esi,%eax
f0104bfe:	0f 84 b3 00 00 00    	je     f0104cb7 <stab_binsearch+0x103>
f0104c04:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0104c08:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104c0c:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104c0e:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c0f:	39 d8                	cmp    %ebx,%eax
f0104c11:	7c 0f                	jl     f0104c22 <stab_binsearch+0x6e>
f0104c13:	0f b6 0a             	movzbl (%edx),%ecx
f0104c16:	83 ea 0c             	sub    $0xc,%edx
f0104c19:	39 f1                	cmp    %esi,%ecx
f0104c1b:	75 f1                	jne    f0104c0e <stab_binsearch+0x5a>
f0104c1d:	e9 97 00 00 00       	jmp    f0104cb9 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104c22:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104c25:	eb 39                	jmp    f0104c60 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104c27:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104c2a:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0104c2c:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c2f:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104c36:	eb 28                	jmp    f0104c60 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104c38:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104c3b:	76 12                	jbe    f0104c4f <stab_binsearch+0x9b>
			*region_right = m - 1;
f0104c3d:	48                   	dec    %eax
f0104c3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c41:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104c44:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c46:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104c4d:	eb 11                	jmp    f0104c60 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104c4f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104c52:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0104c54:	ff 45 0c             	incl   0xc(%ebp)
f0104c57:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c59:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104c60:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0104c63:	0f 8d 76 ff ff ff    	jge    f0104bdf <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104c69:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104c6d:	75 0d                	jne    f0104c7c <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0104c6f:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104c72:	8b 03                	mov    (%ebx),%eax
f0104c74:	48                   	dec    %eax
f0104c75:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104c78:	89 02                	mov    %eax,(%edx)
f0104c7a:	eb 55                	jmp    f0104cd1 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c7c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104c7f:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104c81:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104c84:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c86:	39 c1                	cmp    %eax,%ecx
f0104c88:	7d 26                	jge    f0104cb0 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0104c8a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c8d:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0104c90:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0104c95:	39 f2                	cmp    %esi,%edx
f0104c97:	74 17                	je     f0104cb0 <stab_binsearch+0xfc>
f0104c99:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0104c9d:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104ca1:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104ca2:	39 c1                	cmp    %eax,%ecx
f0104ca4:	7d 0a                	jge    f0104cb0 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0104ca6:	0f b6 1a             	movzbl (%edx),%ebx
f0104ca9:	83 ea 0c             	sub    $0xc,%edx
f0104cac:	39 f3                	cmp    %esi,%ebx
f0104cae:	75 f1                	jne    f0104ca1 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104cb0:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104cb3:	89 02                	mov    %eax,(%edx)
f0104cb5:	eb 1a                	jmp    f0104cd1 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104cb7:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104cb9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cbc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0104cbf:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104cc3:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104cc6:	0f 82 5b ff ff ff    	jb     f0104c27 <stab_binsearch+0x73>
f0104ccc:	e9 67 ff ff ff       	jmp    f0104c38 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104cd1:	83 c4 14             	add    $0x14,%esp
f0104cd4:	5b                   	pop    %ebx
f0104cd5:	5e                   	pop    %esi
f0104cd6:	5f                   	pop    %edi
f0104cd7:	c9                   	leave  
f0104cd8:	c3                   	ret    

f0104cd9 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104cd9:	55                   	push   %ebp
f0104cda:	89 e5                	mov    %esp,%ebp
f0104cdc:	57                   	push   %edi
f0104cdd:	56                   	push   %esi
f0104cde:	53                   	push   %ebx
f0104cdf:	83 ec 2c             	sub    $0x2c,%esp
f0104ce2:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ce5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104ce8:	c7 03 bc 80 10 f0    	movl   $0xf01080bc,(%ebx)
	info->eip_line = 0;
f0104cee:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104cf5:	c7 43 08 bc 80 10 f0 	movl   $0xf01080bc,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104cfc:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104d03:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104d06:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d0d:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104d13:	0f 87 ba 00 00 00    	ja     f0104dd3 <debuginfo_eip+0xfa>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
f0104d19:	e8 92 10 00 00       	call   f0105db0 <cpunum>
f0104d1e:	6a 04                	push   $0x4
f0104d20:	6a 10                	push   $0x10
f0104d22:	68 00 00 20 00       	push   $0x200000
f0104d27:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d2e:	29 c2                	sub    %eax,%edx
f0104d30:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d33:	ff 34 85 28 00 2e f0 	pushl  -0xfd1ffd8(,%eax,4)
f0104d3a:	e8 84 e5 ff ff       	call   f01032c3 <user_mem_check>
f0104d3f:	83 c4 10             	add    $0x10,%esp
f0104d42:	85 c0                	test   %eax,%eax
f0104d44:	0f 88 11 02 00 00    	js     f0104f5b <debuginfo_eip+0x282>
			return -1;
		}

		stabs = usd->stabs;
f0104d4a:	a1 00 00 20 00       	mov    0x200000,%eax
f0104d4f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f0104d52:	8b 0d 04 00 20 00    	mov    0x200004,%ecx
f0104d58:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr = usd->stabstr;
f0104d5b:	a1 08 00 20 00       	mov    0x200008,%eax
f0104d60:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104d63:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
f0104d69:	e8 42 10 00 00       	call   f0105db0 <cpunum>
f0104d6e:	89 c2                	mov    %eax,%edx
f0104d70:	6a 04                	push   $0x4
f0104d72:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104d75:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0104d78:	50                   	push   %eax
f0104d79:	ff 75 d0             	pushl  -0x30(%ebp)
f0104d7c:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0104d83:	29 d0                	sub    %edx,%eax
f0104d85:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0104d88:	ff 34 85 28 00 2e f0 	pushl  -0xfd1ffd8(,%eax,4)
f0104d8f:	e8 2f e5 ff ff       	call   f01032c3 <user_mem_check>
f0104d94:	83 c4 10             	add    $0x10,%esp
f0104d97:	85 c0                	test   %eax,%eax
f0104d99:	0f 88 c3 01 00 00    	js     f0104f62 <debuginfo_eip+0x289>
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0104d9f:	e8 0c 10 00 00       	call   f0105db0 <cpunum>
f0104da4:	89 c2                	mov    %eax,%edx
f0104da6:	6a 04                	push   $0x4
f0104da8:	89 f8                	mov    %edi,%eax
f0104daa:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0104dad:	50                   	push   %eax
f0104dae:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104db1:	6b c2 74             	imul   $0x74,%edx,%eax
f0104db4:	ff b0 28 00 2e f0    	pushl  -0xfd1ffd8(%eax)
f0104dba:	e8 04 e5 ff ff       	call   f01032c3 <user_mem_check>
f0104dbf:	89 c2                	mov    %eax,%edx
f0104dc1:	83 c4 10             	add    $0x10,%esp
			return -1;
f0104dc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0104dc9:	85 d2                	test   %edx,%edx
f0104dcb:	0f 88 ab 01 00 00    	js     f0104f7c <debuginfo_eip+0x2a3>
f0104dd1:	eb 1a                	jmp    f0104ded <debuginfo_eip+0x114>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104dd3:	bf fb d3 11 f0       	mov    $0xf011d3fb,%edi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104dd8:	c7 45 d4 21 41 11 f0 	movl   $0xf0114121,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104ddf:	c7 45 cc 20 41 11 f0 	movl   $0xf0114120,-0x34(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104de6:	c7 45 d0 94 85 10 f0 	movl   $0xf0108594,-0x30(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104ded:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0104df0:	0f 83 73 01 00 00    	jae    f0104f69 <debuginfo_eip+0x290>
f0104df6:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0104dfa:	0f 85 70 01 00 00    	jne    f0104f70 <debuginfo_eip+0x297>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104e00:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104e07:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104e0a:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0104e0d:	c1 f8 02             	sar    $0x2,%eax
f0104e10:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104e16:	48                   	dec    %eax
f0104e17:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e1a:	83 ec 08             	sub    $0x8,%esp
f0104e1d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104e20:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e23:	56                   	push   %esi
f0104e24:	6a 64                	push   $0x64
f0104e26:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104e29:	e8 86 fd ff ff       	call   f0104bb4 <stab_binsearch>
	if (lfile == 0)
f0104e2e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e31:	83 c4 10             	add    $0x10,%esp
		return -1;
f0104e34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0104e39:	85 d2                	test   %edx,%edx
f0104e3b:	0f 84 3b 01 00 00    	je     f0104f7c <debuginfo_eip+0x2a3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e41:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0104e44:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e47:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e4a:	83 ec 08             	sub    $0x8,%esp
f0104e4d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104e50:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e53:	56                   	push   %esi
f0104e54:	6a 24                	push   $0x24
f0104e56:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104e59:	e8 56 fd ff ff       	call   f0104bb4 <stab_binsearch>

	if (lfun <= rfun) {
f0104e5e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104e61:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104e64:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104e67:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104e6a:	83 c4 10             	add    $0x10,%esp
f0104e6d:	39 c1                	cmp    %eax,%ecx
f0104e6f:	7f 21                	jg     f0104e92 <debuginfo_eip+0x1b9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e71:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0104e74:	03 45 d0             	add    -0x30(%ebp),%eax
f0104e77:	8b 10                	mov    (%eax),%edx
f0104e79:	89 f9                	mov    %edi,%ecx
f0104e7b:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f0104e7e:	39 ca                	cmp    %ecx,%edx
f0104e80:	73 06                	jae    f0104e88 <debuginfo_eip+0x1af>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e82:	03 55 d4             	add    -0x2c(%ebp),%edx
f0104e85:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e88:	8b 40 08             	mov    0x8(%eax),%eax
f0104e8b:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104e8e:	29 c6                	sub    %eax,%esi
f0104e90:	eb 0f                	jmp    f0104ea1 <debuginfo_eip+0x1c8>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104e92:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104e95:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104e98:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		rline = rfile;
f0104e9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e9e:	89 45 c8             	mov    %eax,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104ea1:	83 ec 08             	sub    $0x8,%esp
f0104ea4:	6a 3a                	push   $0x3a
f0104ea6:	ff 73 08             	pushl  0x8(%ebx)
f0104ea9:	e8 b1 08 00 00       	call   f010575f <strfind>
f0104eae:	2b 43 08             	sub    0x8(%ebx),%eax
f0104eb1:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0104eb4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104eb7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    rfun = rline;
f0104eba:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104ebd:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0104ec0:	83 c4 08             	add    $0x8,%esp
f0104ec3:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104ec6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104ec9:	56                   	push   %esi
f0104eca:	6a 44                	push   $0x44
f0104ecc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104ecf:	e8 e0 fc ff ff       	call   f0104bb4 <stab_binsearch>
    if (lfun <= rfun) {
f0104ed4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104ed7:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0104eda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0104edf:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0104ee2:	0f 8f 94 00 00 00    	jg     f0104f7c <debuginfo_eip+0x2a3>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0104ee8:	6b ca 0c             	imul   $0xc,%edx,%ecx
f0104eeb:	03 4d d0             	add    -0x30(%ebp),%ecx
f0104eee:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f0104ef2:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104ef5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104ef8:	89 75 cc             	mov    %esi,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0104efb:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104efe:	eb 04                	jmp    f0104f04 <debuginfo_eip+0x22b>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104f00:	4a                   	dec    %edx
f0104f01:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104f04:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f0104f07:	7c 19                	jl     f0104f22 <debuginfo_eip+0x249>
	       && stabs[lline].n_type != N_SOL
f0104f09:	8a 48 fc             	mov    -0x4(%eax),%cl
f0104f0c:	80 f9 84             	cmp    $0x84,%cl
f0104f0f:	74 73                	je     f0104f84 <debuginfo_eip+0x2ab>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104f11:	80 f9 64             	cmp    $0x64,%cl
f0104f14:	75 ea                	jne    f0104f00 <debuginfo_eip+0x227>
f0104f16:	83 38 00             	cmpl   $0x0,(%eax)
f0104f19:	74 e5                	je     f0104f00 <debuginfo_eip+0x227>
f0104f1b:	eb 67                	jmp    f0104f84 <debuginfo_eip+0x2ab>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104f1d:	03 45 d4             	add    -0x2c(%ebp),%eax
f0104f20:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f22:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f25:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f28:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104f2d:	39 ca                	cmp    %ecx,%edx
f0104f2f:	7d 4b                	jge    f0104f7c <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
f0104f31:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f34:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0104f37:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104f3a:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0104f3e:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104f40:	eb 04                	jmp    f0104f46 <debuginfo_eip+0x26d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104f42:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104f45:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104f46:	39 f0                	cmp    %esi,%eax
f0104f48:	7d 2d                	jge    f0104f77 <debuginfo_eip+0x29e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f4a:	8a 0a                	mov    (%edx),%cl
f0104f4c:	83 c2 0c             	add    $0xc,%edx
f0104f4f:	80 f9 a0             	cmp    $0xa0,%cl
f0104f52:	74 ee                	je     f0104f42 <debuginfo_eip+0x269>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f54:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f59:	eb 21                	jmp    f0104f7c <debuginfo_eip+0x2a3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
f0104f5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f60:	eb 1a                	jmp    f0104f7c <debuginfo_eip+0x2a3>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
f0104f62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f67:	eb 13                	jmp    f0104f7c <debuginfo_eip+0x2a3>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104f69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f6e:	eb 0c                	jmp    f0104f7c <debuginfo_eip+0x2a3>
f0104f70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f75:	eb 05                	jmp    f0104f7c <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f77:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f7f:	5b                   	pop    %ebx
f0104f80:	5e                   	pop    %esi
f0104f81:	5f                   	pop    %edi
f0104f82:	c9                   	leave  
f0104f83:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104f84:	6b d2 0c             	imul   $0xc,%edx,%edx
f0104f87:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104f8a:	8b 04 16             	mov    (%esi,%edx,1),%eax
f0104f8d:	2b 7d d4             	sub    -0x2c(%ebp),%edi
f0104f90:	39 f8                	cmp    %edi,%eax
f0104f92:	72 89                	jb     f0104f1d <debuginfo_eip+0x244>
f0104f94:	eb 8c                	jmp    f0104f22 <debuginfo_eip+0x249>
	...

f0104f98 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104f98:	55                   	push   %ebp
f0104f99:	89 e5                	mov    %esp,%ebp
f0104f9b:	57                   	push   %edi
f0104f9c:	56                   	push   %esi
f0104f9d:	53                   	push   %ebx
f0104f9e:	83 ec 2c             	sub    $0x2c,%esp
f0104fa1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104fa4:	89 d6                	mov    %edx,%esi
f0104fa6:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fa9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104fac:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104faf:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104fb2:	8b 45 10             	mov    0x10(%ebp),%eax
f0104fb5:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104fb8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104fbb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104fbe:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0104fc5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0104fc8:	72 0c                	jb     f0104fd6 <printnum+0x3e>
f0104fca:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0104fcd:	76 07                	jbe    f0104fd6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104fcf:	4b                   	dec    %ebx
f0104fd0:	85 db                	test   %ebx,%ebx
f0104fd2:	7f 31                	jg     f0105005 <printnum+0x6d>
f0104fd4:	eb 3f                	jmp    f0105015 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104fd6:	83 ec 0c             	sub    $0xc,%esp
f0104fd9:	57                   	push   %edi
f0104fda:	4b                   	dec    %ebx
f0104fdb:	53                   	push   %ebx
f0104fdc:	50                   	push   %eax
f0104fdd:	83 ec 08             	sub    $0x8,%esp
f0104fe0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104fe3:	ff 75 d0             	pushl  -0x30(%ebp)
f0104fe6:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fe9:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fec:	e8 2b 12 00 00       	call   f010621c <__udivdi3>
f0104ff1:	83 c4 18             	add    $0x18,%esp
f0104ff4:	52                   	push   %edx
f0104ff5:	50                   	push   %eax
f0104ff6:	89 f2                	mov    %esi,%edx
f0104ff8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ffb:	e8 98 ff ff ff       	call   f0104f98 <printnum>
f0105000:	83 c4 20             	add    $0x20,%esp
f0105003:	eb 10                	jmp    f0105015 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105005:	83 ec 08             	sub    $0x8,%esp
f0105008:	56                   	push   %esi
f0105009:	57                   	push   %edi
f010500a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010500d:	4b                   	dec    %ebx
f010500e:	83 c4 10             	add    $0x10,%esp
f0105011:	85 db                	test   %ebx,%ebx
f0105013:	7f f0                	jg     f0105005 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105015:	83 ec 08             	sub    $0x8,%esp
f0105018:	56                   	push   %esi
f0105019:	83 ec 04             	sub    $0x4,%esp
f010501c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010501f:	ff 75 d0             	pushl  -0x30(%ebp)
f0105022:	ff 75 dc             	pushl  -0x24(%ebp)
f0105025:	ff 75 d8             	pushl  -0x28(%ebp)
f0105028:	e8 0b 13 00 00       	call   f0106338 <__umoddi3>
f010502d:	83 c4 14             	add    $0x14,%esp
f0105030:	0f be 80 c6 80 10 f0 	movsbl -0xfef7f3a(%eax),%eax
f0105037:	50                   	push   %eax
f0105038:	ff 55 e4             	call   *-0x1c(%ebp)
f010503b:	83 c4 10             	add    $0x10,%esp
}
f010503e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105041:	5b                   	pop    %ebx
f0105042:	5e                   	pop    %esi
f0105043:	5f                   	pop    %edi
f0105044:	c9                   	leave  
f0105045:	c3                   	ret    

f0105046 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105046:	55                   	push   %ebp
f0105047:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105049:	83 fa 01             	cmp    $0x1,%edx
f010504c:	7e 0e                	jle    f010505c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010504e:	8b 10                	mov    (%eax),%edx
f0105050:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105053:	89 08                	mov    %ecx,(%eax)
f0105055:	8b 02                	mov    (%edx),%eax
f0105057:	8b 52 04             	mov    0x4(%edx),%edx
f010505a:	eb 22                	jmp    f010507e <getuint+0x38>
	else if (lflag)
f010505c:	85 d2                	test   %edx,%edx
f010505e:	74 10                	je     f0105070 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105060:	8b 10                	mov    (%eax),%edx
f0105062:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105065:	89 08                	mov    %ecx,(%eax)
f0105067:	8b 02                	mov    (%edx),%eax
f0105069:	ba 00 00 00 00       	mov    $0x0,%edx
f010506e:	eb 0e                	jmp    f010507e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105070:	8b 10                	mov    (%eax),%edx
f0105072:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105075:	89 08                	mov    %ecx,(%eax)
f0105077:	8b 02                	mov    (%edx),%eax
f0105079:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010507e:	c9                   	leave  
f010507f:	c3                   	ret    

f0105080 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0105080:	55                   	push   %ebp
f0105081:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105083:	83 fa 01             	cmp    $0x1,%edx
f0105086:	7e 0e                	jle    f0105096 <getint+0x16>
		return va_arg(*ap, long long);
f0105088:	8b 10                	mov    (%eax),%edx
f010508a:	8d 4a 08             	lea    0x8(%edx),%ecx
f010508d:	89 08                	mov    %ecx,(%eax)
f010508f:	8b 02                	mov    (%edx),%eax
f0105091:	8b 52 04             	mov    0x4(%edx),%edx
f0105094:	eb 1a                	jmp    f01050b0 <getint+0x30>
	else if (lflag)
f0105096:	85 d2                	test   %edx,%edx
f0105098:	74 0c                	je     f01050a6 <getint+0x26>
		return va_arg(*ap, long);
f010509a:	8b 10                	mov    (%eax),%edx
f010509c:	8d 4a 04             	lea    0x4(%edx),%ecx
f010509f:	89 08                	mov    %ecx,(%eax)
f01050a1:	8b 02                	mov    (%edx),%eax
f01050a3:	99                   	cltd   
f01050a4:	eb 0a                	jmp    f01050b0 <getint+0x30>
	else
		return va_arg(*ap, int);
f01050a6:	8b 10                	mov    (%eax),%edx
f01050a8:	8d 4a 04             	lea    0x4(%edx),%ecx
f01050ab:	89 08                	mov    %ecx,(%eax)
f01050ad:	8b 02                	mov    (%edx),%eax
f01050af:	99                   	cltd   
}
f01050b0:	c9                   	leave  
f01050b1:	c3                   	ret    

f01050b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01050b2:	55                   	push   %ebp
f01050b3:	89 e5                	mov    %esp,%ebp
f01050b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01050b8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01050bb:	8b 10                	mov    (%eax),%edx
f01050bd:	3b 50 04             	cmp    0x4(%eax),%edx
f01050c0:	73 08                	jae    f01050ca <sprintputch+0x18>
		*b->buf++ = ch;
f01050c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01050c5:	88 0a                	mov    %cl,(%edx)
f01050c7:	42                   	inc    %edx
f01050c8:	89 10                	mov    %edx,(%eax)
}
f01050ca:	c9                   	leave  
f01050cb:	c3                   	ret    

f01050cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01050cc:	55                   	push   %ebp
f01050cd:	89 e5                	mov    %esp,%ebp
f01050cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01050d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01050d5:	50                   	push   %eax
f01050d6:	ff 75 10             	pushl  0x10(%ebp)
f01050d9:	ff 75 0c             	pushl  0xc(%ebp)
f01050dc:	ff 75 08             	pushl  0x8(%ebp)
f01050df:	e8 05 00 00 00       	call   f01050e9 <vprintfmt>
	va_end(ap);
f01050e4:	83 c4 10             	add    $0x10,%esp
}
f01050e7:	c9                   	leave  
f01050e8:	c3                   	ret    

f01050e9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01050e9:	55                   	push   %ebp
f01050ea:	89 e5                	mov    %esp,%ebp
f01050ec:	57                   	push   %edi
f01050ed:	56                   	push   %esi
f01050ee:	53                   	push   %ebx
f01050ef:	83 ec 2c             	sub    $0x2c,%esp
f01050f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01050f5:	8b 75 10             	mov    0x10(%ebp),%esi
f01050f8:	eb 13                	jmp    f010510d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01050fa:	85 c0                	test   %eax,%eax
f01050fc:	0f 84 6d 03 00 00    	je     f010546f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f0105102:	83 ec 08             	sub    $0x8,%esp
f0105105:	57                   	push   %edi
f0105106:	50                   	push   %eax
f0105107:	ff 55 08             	call   *0x8(%ebp)
f010510a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010510d:	0f b6 06             	movzbl (%esi),%eax
f0105110:	46                   	inc    %esi
f0105111:	83 f8 25             	cmp    $0x25,%eax
f0105114:	75 e4                	jne    f01050fa <vprintfmt+0x11>
f0105116:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f010511a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105121:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0105128:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f010512f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105134:	eb 28                	jmp    f010515e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105136:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105138:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f010513c:	eb 20                	jmp    f010515e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010513e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105140:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0105144:	eb 18                	jmp    f010515e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105146:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105148:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010514f:	eb 0d                	jmp    f010515e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105151:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105154:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105157:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010515e:	8a 06                	mov    (%esi),%al
f0105160:	0f b6 d0             	movzbl %al,%edx
f0105163:	8d 5e 01             	lea    0x1(%esi),%ebx
f0105166:	83 e8 23             	sub    $0x23,%eax
f0105169:	3c 55                	cmp    $0x55,%al
f010516b:	0f 87 e0 02 00 00    	ja     f0105451 <vprintfmt+0x368>
f0105171:	0f b6 c0             	movzbl %al,%eax
f0105174:	ff 24 85 80 81 10 f0 	jmp    *-0xfef7e80(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010517b:	83 ea 30             	sub    $0x30,%edx
f010517e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0105181:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0105184:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105187:	83 fa 09             	cmp    $0x9,%edx
f010518a:	77 44                	ja     f01051d0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010518c:	89 de                	mov    %ebx,%esi
f010518e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105191:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0105192:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105195:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0105199:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010519c:	8d 58 d0             	lea    -0x30(%eax),%ebx
f010519f:	83 fb 09             	cmp    $0x9,%ebx
f01051a2:	76 ed                	jbe    f0105191 <vprintfmt+0xa8>
f01051a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01051a7:	eb 29                	jmp    f01051d2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01051a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01051ac:	8d 50 04             	lea    0x4(%eax),%edx
f01051af:	89 55 14             	mov    %edx,0x14(%ebp)
f01051b2:	8b 00                	mov    (%eax),%eax
f01051b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051b7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01051b9:	eb 17                	jmp    f01051d2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f01051bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01051bf:	78 85                	js     f0105146 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051c1:	89 de                	mov    %ebx,%esi
f01051c3:	eb 99                	jmp    f010515e <vprintfmt+0x75>
f01051c5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01051c7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f01051ce:	eb 8e                	jmp    f010515e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051d0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01051d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01051d6:	79 86                	jns    f010515e <vprintfmt+0x75>
f01051d8:	e9 74 ff ff ff       	jmp    f0105151 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01051dd:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051de:	89 de                	mov    %ebx,%esi
f01051e0:	e9 79 ff ff ff       	jmp    f010515e <vprintfmt+0x75>
f01051e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01051e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01051eb:	8d 50 04             	lea    0x4(%eax),%edx
f01051ee:	89 55 14             	mov    %edx,0x14(%ebp)
f01051f1:	83 ec 08             	sub    $0x8,%esp
f01051f4:	57                   	push   %edi
f01051f5:	ff 30                	pushl  (%eax)
f01051f7:	ff 55 08             	call   *0x8(%ebp)
			break;
f01051fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051fd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105200:	e9 08 ff ff ff       	jmp    f010510d <vprintfmt+0x24>
f0105205:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105208:	8b 45 14             	mov    0x14(%ebp),%eax
f010520b:	8d 50 04             	lea    0x4(%eax),%edx
f010520e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105211:	8b 00                	mov    (%eax),%eax
f0105213:	85 c0                	test   %eax,%eax
f0105215:	79 02                	jns    f0105219 <vprintfmt+0x130>
f0105217:	f7 d8                	neg    %eax
f0105219:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010521b:	83 f8 08             	cmp    $0x8,%eax
f010521e:	7f 0b                	jg     f010522b <vprintfmt+0x142>
f0105220:	8b 04 85 e0 82 10 f0 	mov    -0xfef7d20(,%eax,4),%eax
f0105227:	85 c0                	test   %eax,%eax
f0105229:	75 1a                	jne    f0105245 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f010522b:	52                   	push   %edx
f010522c:	68 de 80 10 f0       	push   $0xf01080de
f0105231:	57                   	push   %edi
f0105232:	ff 75 08             	pushl  0x8(%ebp)
f0105235:	e8 92 fe ff ff       	call   f01050cc <printfmt>
f010523a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010523d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105240:	e9 c8 fe ff ff       	jmp    f010510d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0105245:	50                   	push   %eax
f0105246:	68 69 78 10 f0       	push   $0xf0107869
f010524b:	57                   	push   %edi
f010524c:	ff 75 08             	pushl  0x8(%ebp)
f010524f:	e8 78 fe ff ff       	call   f01050cc <printfmt>
f0105254:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105257:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010525a:	e9 ae fe ff ff       	jmp    f010510d <vprintfmt+0x24>
f010525f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0105262:	89 de                	mov    %ebx,%esi
f0105264:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0105267:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010526a:	8b 45 14             	mov    0x14(%ebp),%eax
f010526d:	8d 50 04             	lea    0x4(%eax),%edx
f0105270:	89 55 14             	mov    %edx,0x14(%ebp)
f0105273:	8b 00                	mov    (%eax),%eax
f0105275:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105278:	85 c0                	test   %eax,%eax
f010527a:	75 07                	jne    f0105283 <vprintfmt+0x19a>
				p = "(null)";
f010527c:	c7 45 d0 d7 80 10 f0 	movl   $0xf01080d7,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0105283:	85 db                	test   %ebx,%ebx
f0105285:	7e 42                	jle    f01052c9 <vprintfmt+0x1e0>
f0105287:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f010528b:	74 3c                	je     f01052c9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f010528d:	83 ec 08             	sub    $0x8,%esp
f0105290:	51                   	push   %ecx
f0105291:	ff 75 d0             	pushl  -0x30(%ebp)
f0105294:	e8 3f 03 00 00       	call   f01055d8 <strnlen>
f0105299:	29 c3                	sub    %eax,%ebx
f010529b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010529e:	83 c4 10             	add    $0x10,%esp
f01052a1:	85 db                	test   %ebx,%ebx
f01052a3:	7e 24                	jle    f01052c9 <vprintfmt+0x1e0>
					putch(padc, putdat);
f01052a5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f01052a9:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01052ac:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01052af:	83 ec 08             	sub    $0x8,%esp
f01052b2:	57                   	push   %edi
f01052b3:	53                   	push   %ebx
f01052b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01052b7:	4e                   	dec    %esi
f01052b8:	83 c4 10             	add    $0x10,%esp
f01052bb:	85 f6                	test   %esi,%esi
f01052bd:	7f f0                	jg     f01052af <vprintfmt+0x1c6>
f01052bf:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01052c2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01052c9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01052cc:	0f be 02             	movsbl (%edx),%eax
f01052cf:	85 c0                	test   %eax,%eax
f01052d1:	75 47                	jne    f010531a <vprintfmt+0x231>
f01052d3:	eb 37                	jmp    f010530c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f01052d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01052d9:	74 16                	je     f01052f1 <vprintfmt+0x208>
f01052db:	8d 50 e0             	lea    -0x20(%eax),%edx
f01052de:	83 fa 5e             	cmp    $0x5e,%edx
f01052e1:	76 0e                	jbe    f01052f1 <vprintfmt+0x208>
					putch('?', putdat);
f01052e3:	83 ec 08             	sub    $0x8,%esp
f01052e6:	57                   	push   %edi
f01052e7:	6a 3f                	push   $0x3f
f01052e9:	ff 55 08             	call   *0x8(%ebp)
f01052ec:	83 c4 10             	add    $0x10,%esp
f01052ef:	eb 0b                	jmp    f01052fc <vprintfmt+0x213>
				else
					putch(ch, putdat);
f01052f1:	83 ec 08             	sub    $0x8,%esp
f01052f4:	57                   	push   %edi
f01052f5:	50                   	push   %eax
f01052f6:	ff 55 08             	call   *0x8(%ebp)
f01052f9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01052fc:	ff 4d e4             	decl   -0x1c(%ebp)
f01052ff:	0f be 03             	movsbl (%ebx),%eax
f0105302:	85 c0                	test   %eax,%eax
f0105304:	74 03                	je     f0105309 <vprintfmt+0x220>
f0105306:	43                   	inc    %ebx
f0105307:	eb 1b                	jmp    f0105324 <vprintfmt+0x23b>
f0105309:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010530c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105310:	7f 1e                	jg     f0105330 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105312:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105315:	e9 f3 fd ff ff       	jmp    f010510d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010531a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010531d:	43                   	inc    %ebx
f010531e:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0105321:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0105324:	85 f6                	test   %esi,%esi
f0105326:	78 ad                	js     f01052d5 <vprintfmt+0x1ec>
f0105328:	4e                   	dec    %esi
f0105329:	79 aa                	jns    f01052d5 <vprintfmt+0x1ec>
f010532b:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010532e:	eb dc                	jmp    f010530c <vprintfmt+0x223>
f0105330:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105333:	83 ec 08             	sub    $0x8,%esp
f0105336:	57                   	push   %edi
f0105337:	6a 20                	push   $0x20
f0105339:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010533c:	4b                   	dec    %ebx
f010533d:	83 c4 10             	add    $0x10,%esp
f0105340:	85 db                	test   %ebx,%ebx
f0105342:	7f ef                	jg     f0105333 <vprintfmt+0x24a>
f0105344:	e9 c4 fd ff ff       	jmp    f010510d <vprintfmt+0x24>
f0105349:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010534c:	89 ca                	mov    %ecx,%edx
f010534e:	8d 45 14             	lea    0x14(%ebp),%eax
f0105351:	e8 2a fd ff ff       	call   f0105080 <getint>
f0105356:	89 c3                	mov    %eax,%ebx
f0105358:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f010535a:	85 d2                	test   %edx,%edx
f010535c:	78 0a                	js     f0105368 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010535e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105363:	e9 b0 00 00 00       	jmp    f0105418 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105368:	83 ec 08             	sub    $0x8,%esp
f010536b:	57                   	push   %edi
f010536c:	6a 2d                	push   $0x2d
f010536e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105371:	f7 db                	neg    %ebx
f0105373:	83 d6 00             	adc    $0x0,%esi
f0105376:	f7 de                	neg    %esi
f0105378:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010537b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105380:	e9 93 00 00 00       	jmp    f0105418 <vprintfmt+0x32f>
f0105385:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105388:	89 ca                	mov    %ecx,%edx
f010538a:	8d 45 14             	lea    0x14(%ebp),%eax
f010538d:	e8 b4 fc ff ff       	call   f0105046 <getuint>
f0105392:	89 c3                	mov    %eax,%ebx
f0105394:	89 d6                	mov    %edx,%esi
			base = 10;
f0105396:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010539b:	eb 7b                	jmp    f0105418 <vprintfmt+0x32f>
f010539d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f01053a0:	89 ca                	mov    %ecx,%edx
f01053a2:	8d 45 14             	lea    0x14(%ebp),%eax
f01053a5:	e8 d6 fc ff ff       	call   f0105080 <getint>
f01053aa:	89 c3                	mov    %eax,%ebx
f01053ac:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f01053ae:	85 d2                	test   %edx,%edx
f01053b0:	78 07                	js     f01053b9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f01053b2:	b8 08 00 00 00       	mov    $0x8,%eax
f01053b7:	eb 5f                	jmp    f0105418 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f01053b9:	83 ec 08             	sub    $0x8,%esp
f01053bc:	57                   	push   %edi
f01053bd:	6a 2d                	push   $0x2d
f01053bf:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f01053c2:	f7 db                	neg    %ebx
f01053c4:	83 d6 00             	adc    $0x0,%esi
f01053c7:	f7 de                	neg    %esi
f01053c9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f01053cc:	b8 08 00 00 00       	mov    $0x8,%eax
f01053d1:	eb 45                	jmp    f0105418 <vprintfmt+0x32f>
f01053d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f01053d6:	83 ec 08             	sub    $0x8,%esp
f01053d9:	57                   	push   %edi
f01053da:	6a 30                	push   $0x30
f01053dc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01053df:	83 c4 08             	add    $0x8,%esp
f01053e2:	57                   	push   %edi
f01053e3:	6a 78                	push   $0x78
f01053e5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01053e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01053eb:	8d 50 04             	lea    0x4(%eax),%edx
f01053ee:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01053f1:	8b 18                	mov    (%eax),%ebx
f01053f3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01053f8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01053fb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105400:	eb 16                	jmp    f0105418 <vprintfmt+0x32f>
f0105402:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105405:	89 ca                	mov    %ecx,%edx
f0105407:	8d 45 14             	lea    0x14(%ebp),%eax
f010540a:	e8 37 fc ff ff       	call   f0105046 <getuint>
f010540f:	89 c3                	mov    %eax,%ebx
f0105411:	89 d6                	mov    %edx,%esi
			base = 16;
f0105413:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105418:	83 ec 0c             	sub    $0xc,%esp
f010541b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f010541f:	52                   	push   %edx
f0105420:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105423:	50                   	push   %eax
f0105424:	56                   	push   %esi
f0105425:	53                   	push   %ebx
f0105426:	89 fa                	mov    %edi,%edx
f0105428:	8b 45 08             	mov    0x8(%ebp),%eax
f010542b:	e8 68 fb ff ff       	call   f0104f98 <printnum>
			break;
f0105430:	83 c4 20             	add    $0x20,%esp
f0105433:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105436:	e9 d2 fc ff ff       	jmp    f010510d <vprintfmt+0x24>
f010543b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010543e:	83 ec 08             	sub    $0x8,%esp
f0105441:	57                   	push   %edi
f0105442:	52                   	push   %edx
f0105443:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105446:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105449:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010544c:	e9 bc fc ff ff       	jmp    f010510d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105451:	83 ec 08             	sub    $0x8,%esp
f0105454:	57                   	push   %edi
f0105455:	6a 25                	push   $0x25
f0105457:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010545a:	83 c4 10             	add    $0x10,%esp
f010545d:	eb 02                	jmp    f0105461 <vprintfmt+0x378>
f010545f:	89 c6                	mov    %eax,%esi
f0105461:	8d 46 ff             	lea    -0x1(%esi),%eax
f0105464:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105468:	75 f5                	jne    f010545f <vprintfmt+0x376>
f010546a:	e9 9e fc ff ff       	jmp    f010510d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f010546f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105472:	5b                   	pop    %ebx
f0105473:	5e                   	pop    %esi
f0105474:	5f                   	pop    %edi
f0105475:	c9                   	leave  
f0105476:	c3                   	ret    

f0105477 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105477:	55                   	push   %ebp
f0105478:	89 e5                	mov    %esp,%ebp
f010547a:	83 ec 18             	sub    $0x18,%esp
f010547d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105480:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105483:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105486:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010548a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010548d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105494:	85 c0                	test   %eax,%eax
f0105496:	74 26                	je     f01054be <vsnprintf+0x47>
f0105498:	85 d2                	test   %edx,%edx
f010549a:	7e 29                	jle    f01054c5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010549c:	ff 75 14             	pushl  0x14(%ebp)
f010549f:	ff 75 10             	pushl  0x10(%ebp)
f01054a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01054a5:	50                   	push   %eax
f01054a6:	68 b2 50 10 f0       	push   $0xf01050b2
f01054ab:	e8 39 fc ff ff       	call   f01050e9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01054b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01054b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01054b9:	83 c4 10             	add    $0x10,%esp
f01054bc:	eb 0c                	jmp    f01054ca <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01054be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01054c3:	eb 05                	jmp    f01054ca <vsnprintf+0x53>
f01054c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01054ca:	c9                   	leave  
f01054cb:	c3                   	ret    

f01054cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01054cc:	55                   	push   %ebp
f01054cd:	89 e5                	mov    %esp,%ebp
f01054cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01054d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01054d5:	50                   	push   %eax
f01054d6:	ff 75 10             	pushl  0x10(%ebp)
f01054d9:	ff 75 0c             	pushl  0xc(%ebp)
f01054dc:	ff 75 08             	pushl  0x8(%ebp)
f01054df:	e8 93 ff ff ff       	call   f0105477 <vsnprintf>
	va_end(ap);

	return rc;
}
f01054e4:	c9                   	leave  
f01054e5:	c3                   	ret    
	...

f01054e8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01054e8:	55                   	push   %ebp
f01054e9:	89 e5                	mov    %esp,%ebp
f01054eb:	57                   	push   %edi
f01054ec:	56                   	push   %esi
f01054ed:	53                   	push   %ebx
f01054ee:	83 ec 0c             	sub    $0xc,%esp
f01054f1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01054f4:	85 c0                	test   %eax,%eax
f01054f6:	74 11                	je     f0105509 <readline+0x21>
		cprintf("%s", prompt);
f01054f8:	83 ec 08             	sub    $0x8,%esp
f01054fb:	50                   	push   %eax
f01054fc:	68 69 78 10 f0       	push   $0xf0107869
f0105501:	e8 87 e8 ff ff       	call   f0103d8d <cprintf>
f0105506:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105509:	83 ec 0c             	sub    $0xc,%esp
f010550c:	6a 00                	push   $0x0
f010550e:	e8 e5 b2 ff ff       	call   f01007f8 <iscons>
f0105513:	89 c7                	mov    %eax,%edi
f0105515:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105518:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010551d:	e8 c5 b2 ff ff       	call   f01007e7 <getchar>
f0105522:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105524:	85 c0                	test   %eax,%eax
f0105526:	79 18                	jns    f0105540 <readline+0x58>
			cprintf("read error: %e\n", c);
f0105528:	83 ec 08             	sub    $0x8,%esp
f010552b:	50                   	push   %eax
f010552c:	68 04 83 10 f0       	push   $0xf0108304
f0105531:	e8 57 e8 ff ff       	call   f0103d8d <cprintf>
			return NULL;
f0105536:	83 c4 10             	add    $0x10,%esp
f0105539:	b8 00 00 00 00       	mov    $0x0,%eax
f010553e:	eb 6f                	jmp    f01055af <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105540:	83 f8 08             	cmp    $0x8,%eax
f0105543:	74 05                	je     f010554a <readline+0x62>
f0105545:	83 f8 7f             	cmp    $0x7f,%eax
f0105548:	75 18                	jne    f0105562 <readline+0x7a>
f010554a:	85 f6                	test   %esi,%esi
f010554c:	7e 14                	jle    f0105562 <readline+0x7a>
			if (echoing)
f010554e:	85 ff                	test   %edi,%edi
f0105550:	74 0d                	je     f010555f <readline+0x77>
				cputchar('\b');
f0105552:	83 ec 0c             	sub    $0xc,%esp
f0105555:	6a 08                	push   $0x8
f0105557:	e8 7b b2 ff ff       	call   f01007d7 <cputchar>
f010555c:	83 c4 10             	add    $0x10,%esp
			i--;
f010555f:	4e                   	dec    %esi
f0105560:	eb bb                	jmp    f010551d <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105562:	83 fb 1f             	cmp    $0x1f,%ebx
f0105565:	7e 21                	jle    f0105588 <readline+0xa0>
f0105567:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010556d:	7f 19                	jg     f0105588 <readline+0xa0>
			if (echoing)
f010556f:	85 ff                	test   %edi,%edi
f0105571:	74 0c                	je     f010557f <readline+0x97>
				cputchar(c);
f0105573:	83 ec 0c             	sub    $0xc,%esp
f0105576:	53                   	push   %ebx
f0105577:	e8 5b b2 ff ff       	call   f01007d7 <cputchar>
f010557c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010557f:	88 9e 80 fa 2d f0    	mov    %bl,-0xfd20580(%esi)
f0105585:	46                   	inc    %esi
f0105586:	eb 95                	jmp    f010551d <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105588:	83 fb 0a             	cmp    $0xa,%ebx
f010558b:	74 05                	je     f0105592 <readline+0xaa>
f010558d:	83 fb 0d             	cmp    $0xd,%ebx
f0105590:	75 8b                	jne    f010551d <readline+0x35>
			if (echoing)
f0105592:	85 ff                	test   %edi,%edi
f0105594:	74 0d                	je     f01055a3 <readline+0xbb>
				cputchar('\n');
f0105596:	83 ec 0c             	sub    $0xc,%esp
f0105599:	6a 0a                	push   $0xa
f010559b:	e8 37 b2 ff ff       	call   f01007d7 <cputchar>
f01055a0:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01055a3:	c6 86 80 fa 2d f0 00 	movb   $0x0,-0xfd20580(%esi)
			return buf;
f01055aa:	b8 80 fa 2d f0       	mov    $0xf02dfa80,%eax
		}
	}
}
f01055af:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055b2:	5b                   	pop    %ebx
f01055b3:	5e                   	pop    %esi
f01055b4:	5f                   	pop    %edi
f01055b5:	c9                   	leave  
f01055b6:	c3                   	ret    
	...

f01055b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01055b8:	55                   	push   %ebp
f01055b9:	89 e5                	mov    %esp,%ebp
f01055bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01055be:	80 3a 00             	cmpb   $0x0,(%edx)
f01055c1:	74 0e                	je     f01055d1 <strlen+0x19>
f01055c3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01055c8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01055c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01055cd:	75 f9                	jne    f01055c8 <strlen+0x10>
f01055cf:	eb 05                	jmp    f01055d6 <strlen+0x1e>
f01055d1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01055d6:	c9                   	leave  
f01055d7:	c3                   	ret    

f01055d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01055d8:	55                   	push   %ebp
f01055d9:	89 e5                	mov    %esp,%ebp
f01055db:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01055de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01055e1:	85 d2                	test   %edx,%edx
f01055e3:	74 17                	je     f01055fc <strnlen+0x24>
f01055e5:	80 39 00             	cmpb   $0x0,(%ecx)
f01055e8:	74 19                	je     f0105603 <strnlen+0x2b>
f01055ea:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01055ef:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01055f0:	39 d0                	cmp    %edx,%eax
f01055f2:	74 14                	je     f0105608 <strnlen+0x30>
f01055f4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01055f8:	75 f5                	jne    f01055ef <strnlen+0x17>
f01055fa:	eb 0c                	jmp    f0105608 <strnlen+0x30>
f01055fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0105601:	eb 05                	jmp    f0105608 <strnlen+0x30>
f0105603:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105608:	c9                   	leave  
f0105609:	c3                   	ret    

f010560a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010560a:	55                   	push   %ebp
f010560b:	89 e5                	mov    %esp,%ebp
f010560d:	53                   	push   %ebx
f010560e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105611:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105614:	ba 00 00 00 00       	mov    $0x0,%edx
f0105619:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f010561c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f010561f:	42                   	inc    %edx
f0105620:	84 c9                	test   %cl,%cl
f0105622:	75 f5                	jne    f0105619 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105624:	5b                   	pop    %ebx
f0105625:	c9                   	leave  
f0105626:	c3                   	ret    

f0105627 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105627:	55                   	push   %ebp
f0105628:	89 e5                	mov    %esp,%ebp
f010562a:	53                   	push   %ebx
f010562b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010562e:	53                   	push   %ebx
f010562f:	e8 84 ff ff ff       	call   f01055b8 <strlen>
f0105634:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105637:	ff 75 0c             	pushl  0xc(%ebp)
f010563a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f010563d:	50                   	push   %eax
f010563e:	e8 c7 ff ff ff       	call   f010560a <strcpy>
	return dst;
}
f0105643:	89 d8                	mov    %ebx,%eax
f0105645:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105648:	c9                   	leave  
f0105649:	c3                   	ret    

f010564a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010564a:	55                   	push   %ebp
f010564b:	89 e5                	mov    %esp,%ebp
f010564d:	56                   	push   %esi
f010564e:	53                   	push   %ebx
f010564f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105652:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105655:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105658:	85 f6                	test   %esi,%esi
f010565a:	74 15                	je     f0105671 <strncpy+0x27>
f010565c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0105661:	8a 1a                	mov    (%edx),%bl
f0105663:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105666:	80 3a 01             	cmpb   $0x1,(%edx)
f0105669:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010566c:	41                   	inc    %ecx
f010566d:	39 ce                	cmp    %ecx,%esi
f010566f:	77 f0                	ja     f0105661 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105671:	5b                   	pop    %ebx
f0105672:	5e                   	pop    %esi
f0105673:	c9                   	leave  
f0105674:	c3                   	ret    

f0105675 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105675:	55                   	push   %ebp
f0105676:	89 e5                	mov    %esp,%ebp
f0105678:	57                   	push   %edi
f0105679:	56                   	push   %esi
f010567a:	53                   	push   %ebx
f010567b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010567e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105681:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105684:	85 f6                	test   %esi,%esi
f0105686:	74 32                	je     f01056ba <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0105688:	83 fe 01             	cmp    $0x1,%esi
f010568b:	74 22                	je     f01056af <strlcpy+0x3a>
f010568d:	8a 0b                	mov    (%ebx),%cl
f010568f:	84 c9                	test   %cl,%cl
f0105691:	74 20                	je     f01056b3 <strlcpy+0x3e>
f0105693:	89 f8                	mov    %edi,%eax
f0105695:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010569a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010569d:	88 08                	mov    %cl,(%eax)
f010569f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01056a0:	39 f2                	cmp    %esi,%edx
f01056a2:	74 11                	je     f01056b5 <strlcpy+0x40>
f01056a4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f01056a8:	42                   	inc    %edx
f01056a9:	84 c9                	test   %cl,%cl
f01056ab:	75 f0                	jne    f010569d <strlcpy+0x28>
f01056ad:	eb 06                	jmp    f01056b5 <strlcpy+0x40>
f01056af:	89 f8                	mov    %edi,%eax
f01056b1:	eb 02                	jmp    f01056b5 <strlcpy+0x40>
f01056b3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01056b5:	c6 00 00             	movb   $0x0,(%eax)
f01056b8:	eb 02                	jmp    f01056bc <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01056ba:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f01056bc:	29 f8                	sub    %edi,%eax
}
f01056be:	5b                   	pop    %ebx
f01056bf:	5e                   	pop    %esi
f01056c0:	5f                   	pop    %edi
f01056c1:	c9                   	leave  
f01056c2:	c3                   	ret    

f01056c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01056c3:	55                   	push   %ebp
f01056c4:	89 e5                	mov    %esp,%ebp
f01056c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01056cc:	8a 01                	mov    (%ecx),%al
f01056ce:	84 c0                	test   %al,%al
f01056d0:	74 10                	je     f01056e2 <strcmp+0x1f>
f01056d2:	3a 02                	cmp    (%edx),%al
f01056d4:	75 0c                	jne    f01056e2 <strcmp+0x1f>
		p++, q++;
f01056d6:	41                   	inc    %ecx
f01056d7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01056d8:	8a 01                	mov    (%ecx),%al
f01056da:	84 c0                	test   %al,%al
f01056dc:	74 04                	je     f01056e2 <strcmp+0x1f>
f01056de:	3a 02                	cmp    (%edx),%al
f01056e0:	74 f4                	je     f01056d6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01056e2:	0f b6 c0             	movzbl %al,%eax
f01056e5:	0f b6 12             	movzbl (%edx),%edx
f01056e8:	29 d0                	sub    %edx,%eax
}
f01056ea:	c9                   	leave  
f01056eb:	c3                   	ret    

f01056ec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01056ec:	55                   	push   %ebp
f01056ed:	89 e5                	mov    %esp,%ebp
f01056ef:	53                   	push   %ebx
f01056f0:	8b 55 08             	mov    0x8(%ebp),%edx
f01056f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056f6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01056f9:	85 c0                	test   %eax,%eax
f01056fb:	74 1b                	je     f0105718 <strncmp+0x2c>
f01056fd:	8a 1a                	mov    (%edx),%bl
f01056ff:	84 db                	test   %bl,%bl
f0105701:	74 24                	je     f0105727 <strncmp+0x3b>
f0105703:	3a 19                	cmp    (%ecx),%bl
f0105705:	75 20                	jne    f0105727 <strncmp+0x3b>
f0105707:	48                   	dec    %eax
f0105708:	74 15                	je     f010571f <strncmp+0x33>
		n--, p++, q++;
f010570a:	42                   	inc    %edx
f010570b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010570c:	8a 1a                	mov    (%edx),%bl
f010570e:	84 db                	test   %bl,%bl
f0105710:	74 15                	je     f0105727 <strncmp+0x3b>
f0105712:	3a 19                	cmp    (%ecx),%bl
f0105714:	74 f1                	je     f0105707 <strncmp+0x1b>
f0105716:	eb 0f                	jmp    f0105727 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105718:	b8 00 00 00 00       	mov    $0x0,%eax
f010571d:	eb 05                	jmp    f0105724 <strncmp+0x38>
f010571f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105724:	5b                   	pop    %ebx
f0105725:	c9                   	leave  
f0105726:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105727:	0f b6 02             	movzbl (%edx),%eax
f010572a:	0f b6 11             	movzbl (%ecx),%edx
f010572d:	29 d0                	sub    %edx,%eax
f010572f:	eb f3                	jmp    f0105724 <strncmp+0x38>

f0105731 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105731:	55                   	push   %ebp
f0105732:	89 e5                	mov    %esp,%ebp
f0105734:	8b 45 08             	mov    0x8(%ebp),%eax
f0105737:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010573a:	8a 10                	mov    (%eax),%dl
f010573c:	84 d2                	test   %dl,%dl
f010573e:	74 18                	je     f0105758 <strchr+0x27>
		if (*s == c)
f0105740:	38 ca                	cmp    %cl,%dl
f0105742:	75 06                	jne    f010574a <strchr+0x19>
f0105744:	eb 17                	jmp    f010575d <strchr+0x2c>
f0105746:	38 ca                	cmp    %cl,%dl
f0105748:	74 13                	je     f010575d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010574a:	40                   	inc    %eax
f010574b:	8a 10                	mov    (%eax),%dl
f010574d:	84 d2                	test   %dl,%dl
f010574f:	75 f5                	jne    f0105746 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0105751:	b8 00 00 00 00       	mov    $0x0,%eax
f0105756:	eb 05                	jmp    f010575d <strchr+0x2c>
f0105758:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010575d:	c9                   	leave  
f010575e:	c3                   	ret    

f010575f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010575f:	55                   	push   %ebp
f0105760:	89 e5                	mov    %esp,%ebp
f0105762:	8b 45 08             	mov    0x8(%ebp),%eax
f0105765:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105768:	8a 10                	mov    (%eax),%dl
f010576a:	84 d2                	test   %dl,%dl
f010576c:	74 11                	je     f010577f <strfind+0x20>
		if (*s == c)
f010576e:	38 ca                	cmp    %cl,%dl
f0105770:	75 06                	jne    f0105778 <strfind+0x19>
f0105772:	eb 0b                	jmp    f010577f <strfind+0x20>
f0105774:	38 ca                	cmp    %cl,%dl
f0105776:	74 07                	je     f010577f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105778:	40                   	inc    %eax
f0105779:	8a 10                	mov    (%eax),%dl
f010577b:	84 d2                	test   %dl,%dl
f010577d:	75 f5                	jne    f0105774 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f010577f:	c9                   	leave  
f0105780:	c3                   	ret    

f0105781 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105781:	55                   	push   %ebp
f0105782:	89 e5                	mov    %esp,%ebp
f0105784:	57                   	push   %edi
f0105785:	56                   	push   %esi
f0105786:	53                   	push   %ebx
f0105787:	8b 7d 08             	mov    0x8(%ebp),%edi
f010578a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010578d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105790:	85 c9                	test   %ecx,%ecx
f0105792:	74 30                	je     f01057c4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105794:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010579a:	75 25                	jne    f01057c1 <memset+0x40>
f010579c:	f6 c1 03             	test   $0x3,%cl
f010579f:	75 20                	jne    f01057c1 <memset+0x40>
		c &= 0xFF;
f01057a1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01057a4:	89 d3                	mov    %edx,%ebx
f01057a6:	c1 e3 08             	shl    $0x8,%ebx
f01057a9:	89 d6                	mov    %edx,%esi
f01057ab:	c1 e6 18             	shl    $0x18,%esi
f01057ae:	89 d0                	mov    %edx,%eax
f01057b0:	c1 e0 10             	shl    $0x10,%eax
f01057b3:	09 f0                	or     %esi,%eax
f01057b5:	09 d0                	or     %edx,%eax
f01057b7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01057b9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01057bc:	fc                   	cld    
f01057bd:	f3 ab                	rep stos %eax,%es:(%edi)
f01057bf:	eb 03                	jmp    f01057c4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01057c1:	fc                   	cld    
f01057c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01057c4:	89 f8                	mov    %edi,%eax
f01057c6:	5b                   	pop    %ebx
f01057c7:	5e                   	pop    %esi
f01057c8:	5f                   	pop    %edi
f01057c9:	c9                   	leave  
f01057ca:	c3                   	ret    

f01057cb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01057cb:	55                   	push   %ebp
f01057cc:	89 e5                	mov    %esp,%ebp
f01057ce:	57                   	push   %edi
f01057cf:	56                   	push   %esi
f01057d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01057d3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01057d9:	39 c6                	cmp    %eax,%esi
f01057db:	73 34                	jae    f0105811 <memmove+0x46>
f01057dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01057e0:	39 d0                	cmp    %edx,%eax
f01057e2:	73 2d                	jae    f0105811 <memmove+0x46>
		s += n;
		d += n;
f01057e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057e7:	f6 c2 03             	test   $0x3,%dl
f01057ea:	75 1b                	jne    f0105807 <memmove+0x3c>
f01057ec:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01057f2:	75 13                	jne    f0105807 <memmove+0x3c>
f01057f4:	f6 c1 03             	test   $0x3,%cl
f01057f7:	75 0e                	jne    f0105807 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01057f9:	83 ef 04             	sub    $0x4,%edi
f01057fc:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057ff:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105802:	fd                   	std    
f0105803:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105805:	eb 07                	jmp    f010580e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105807:	4f                   	dec    %edi
f0105808:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010580b:	fd                   	std    
f010580c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010580e:	fc                   	cld    
f010580f:	eb 20                	jmp    f0105831 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105811:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105817:	75 13                	jne    f010582c <memmove+0x61>
f0105819:	a8 03                	test   $0x3,%al
f010581b:	75 0f                	jne    f010582c <memmove+0x61>
f010581d:	f6 c1 03             	test   $0x3,%cl
f0105820:	75 0a                	jne    f010582c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105822:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105825:	89 c7                	mov    %eax,%edi
f0105827:	fc                   	cld    
f0105828:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010582a:	eb 05                	jmp    f0105831 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010582c:	89 c7                	mov    %eax,%edi
f010582e:	fc                   	cld    
f010582f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105831:	5e                   	pop    %esi
f0105832:	5f                   	pop    %edi
f0105833:	c9                   	leave  
f0105834:	c3                   	ret    

f0105835 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105835:	55                   	push   %ebp
f0105836:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105838:	ff 75 10             	pushl  0x10(%ebp)
f010583b:	ff 75 0c             	pushl  0xc(%ebp)
f010583e:	ff 75 08             	pushl  0x8(%ebp)
f0105841:	e8 85 ff ff ff       	call   f01057cb <memmove>
}
f0105846:	c9                   	leave  
f0105847:	c3                   	ret    

f0105848 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105848:	55                   	push   %ebp
f0105849:	89 e5                	mov    %esp,%ebp
f010584b:	57                   	push   %edi
f010584c:	56                   	push   %esi
f010584d:	53                   	push   %ebx
f010584e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105851:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105854:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105857:	85 ff                	test   %edi,%edi
f0105859:	74 32                	je     f010588d <memcmp+0x45>
		if (*s1 != *s2)
f010585b:	8a 03                	mov    (%ebx),%al
f010585d:	8a 0e                	mov    (%esi),%cl
f010585f:	38 c8                	cmp    %cl,%al
f0105861:	74 19                	je     f010587c <memcmp+0x34>
f0105863:	eb 0d                	jmp    f0105872 <memcmp+0x2a>
f0105865:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0105869:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f010586d:	42                   	inc    %edx
f010586e:	38 c8                	cmp    %cl,%al
f0105870:	74 10                	je     f0105882 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f0105872:	0f b6 c0             	movzbl %al,%eax
f0105875:	0f b6 c9             	movzbl %cl,%ecx
f0105878:	29 c8                	sub    %ecx,%eax
f010587a:	eb 16                	jmp    f0105892 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010587c:	4f                   	dec    %edi
f010587d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105882:	39 fa                	cmp    %edi,%edx
f0105884:	75 df                	jne    f0105865 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105886:	b8 00 00 00 00       	mov    $0x0,%eax
f010588b:	eb 05                	jmp    f0105892 <memcmp+0x4a>
f010588d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105892:	5b                   	pop    %ebx
f0105893:	5e                   	pop    %esi
f0105894:	5f                   	pop    %edi
f0105895:	c9                   	leave  
f0105896:	c3                   	ret    

f0105897 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105897:	55                   	push   %ebp
f0105898:	89 e5                	mov    %esp,%ebp
f010589a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010589d:	89 c2                	mov    %eax,%edx
f010589f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01058a2:	39 d0                	cmp    %edx,%eax
f01058a4:	73 12                	jae    f01058b8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f01058a6:	8a 4d 0c             	mov    0xc(%ebp),%cl
f01058a9:	38 08                	cmp    %cl,(%eax)
f01058ab:	75 06                	jne    f01058b3 <memfind+0x1c>
f01058ad:	eb 09                	jmp    f01058b8 <memfind+0x21>
f01058af:	38 08                	cmp    %cl,(%eax)
f01058b1:	74 05                	je     f01058b8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01058b3:	40                   	inc    %eax
f01058b4:	39 c2                	cmp    %eax,%edx
f01058b6:	77 f7                	ja     f01058af <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01058b8:	c9                   	leave  
f01058b9:	c3                   	ret    

f01058ba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01058ba:	55                   	push   %ebp
f01058bb:	89 e5                	mov    %esp,%ebp
f01058bd:	57                   	push   %edi
f01058be:	56                   	push   %esi
f01058bf:	53                   	push   %ebx
f01058c0:	8b 55 08             	mov    0x8(%ebp),%edx
f01058c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01058c6:	eb 01                	jmp    f01058c9 <strtol+0xf>
		s++;
f01058c8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01058c9:	8a 02                	mov    (%edx),%al
f01058cb:	3c 20                	cmp    $0x20,%al
f01058cd:	74 f9                	je     f01058c8 <strtol+0xe>
f01058cf:	3c 09                	cmp    $0x9,%al
f01058d1:	74 f5                	je     f01058c8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01058d3:	3c 2b                	cmp    $0x2b,%al
f01058d5:	75 08                	jne    f01058df <strtol+0x25>
		s++;
f01058d7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01058d8:	bf 00 00 00 00       	mov    $0x0,%edi
f01058dd:	eb 13                	jmp    f01058f2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01058df:	3c 2d                	cmp    $0x2d,%al
f01058e1:	75 0a                	jne    f01058ed <strtol+0x33>
		s++, neg = 1;
f01058e3:	8d 52 01             	lea    0x1(%edx),%edx
f01058e6:	bf 01 00 00 00       	mov    $0x1,%edi
f01058eb:	eb 05                	jmp    f01058f2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01058ed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01058f2:	85 db                	test   %ebx,%ebx
f01058f4:	74 05                	je     f01058fb <strtol+0x41>
f01058f6:	83 fb 10             	cmp    $0x10,%ebx
f01058f9:	75 28                	jne    f0105923 <strtol+0x69>
f01058fb:	8a 02                	mov    (%edx),%al
f01058fd:	3c 30                	cmp    $0x30,%al
f01058ff:	75 10                	jne    f0105911 <strtol+0x57>
f0105901:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105905:	75 0a                	jne    f0105911 <strtol+0x57>
		s += 2, base = 16;
f0105907:	83 c2 02             	add    $0x2,%edx
f010590a:	bb 10 00 00 00       	mov    $0x10,%ebx
f010590f:	eb 12                	jmp    f0105923 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0105911:	85 db                	test   %ebx,%ebx
f0105913:	75 0e                	jne    f0105923 <strtol+0x69>
f0105915:	3c 30                	cmp    $0x30,%al
f0105917:	75 05                	jne    f010591e <strtol+0x64>
		s++, base = 8;
f0105919:	42                   	inc    %edx
f010591a:	b3 08                	mov    $0x8,%bl
f010591c:	eb 05                	jmp    f0105923 <strtol+0x69>
	else if (base == 0)
		base = 10;
f010591e:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0105923:	b8 00 00 00 00       	mov    $0x0,%eax
f0105928:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010592a:	8a 0a                	mov    (%edx),%cl
f010592c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f010592f:	80 fb 09             	cmp    $0x9,%bl
f0105932:	77 08                	ja     f010593c <strtol+0x82>
			dig = *s - '0';
f0105934:	0f be c9             	movsbl %cl,%ecx
f0105937:	83 e9 30             	sub    $0x30,%ecx
f010593a:	eb 1e                	jmp    f010595a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f010593c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010593f:	80 fb 19             	cmp    $0x19,%bl
f0105942:	77 08                	ja     f010594c <strtol+0x92>
			dig = *s - 'a' + 10;
f0105944:	0f be c9             	movsbl %cl,%ecx
f0105947:	83 e9 57             	sub    $0x57,%ecx
f010594a:	eb 0e                	jmp    f010595a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f010594c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f010594f:	80 fb 19             	cmp    $0x19,%bl
f0105952:	77 13                	ja     f0105967 <strtol+0xad>
			dig = *s - 'A' + 10;
f0105954:	0f be c9             	movsbl %cl,%ecx
f0105957:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010595a:	39 f1                	cmp    %esi,%ecx
f010595c:	7d 0d                	jge    f010596b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f010595e:	42                   	inc    %edx
f010595f:	0f af c6             	imul   %esi,%eax
f0105962:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0105965:	eb c3                	jmp    f010592a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0105967:	89 c1                	mov    %eax,%ecx
f0105969:	eb 02                	jmp    f010596d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010596b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f010596d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105971:	74 05                	je     f0105978 <strtol+0xbe>
		*endptr = (char *) s;
f0105973:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105976:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105978:	85 ff                	test   %edi,%edi
f010597a:	74 04                	je     f0105980 <strtol+0xc6>
f010597c:	89 c8                	mov    %ecx,%eax
f010597e:	f7 d8                	neg    %eax
}
f0105980:	5b                   	pop    %ebx
f0105981:	5e                   	pop    %esi
f0105982:	5f                   	pop    %edi
f0105983:	c9                   	leave  
f0105984:	c3                   	ret    
f0105985:	00 00                	add    %al,(%eax)
	...

f0105988 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105988:	fa                   	cli    

	xorw    %ax, %ax
f0105989:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010598b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010598d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010598f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105991:	0f 01 16             	lgdtl  (%esi)
f0105994:	74 70                	je     f0105a06 <sum+0x2>
	movl    %cr0, %eax
f0105996:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105999:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010599d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01059a0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01059a6:	08 00                	or     %al,(%eax)

f01059a8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01059a8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01059ac:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059ae:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01059b0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01059b2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01059b6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01059b8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01059ba:	b8 00 60 12 00       	mov    $0x126000,%eax
	movl    %eax, %cr3
f01059bf:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01059c2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01059c5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01059ca:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01059cd:	8b 25 84 fe 2d f0    	mov    0xf02dfe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01059d3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01059d8:	b8 c2 00 10 f0       	mov    $0xf01000c2,%eax
	call    *%eax
f01059dd:	ff d0                	call   *%eax

f01059df <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01059df:	eb fe                	jmp    f01059df <spin>
f01059e1:	8d 76 00             	lea    0x0(%esi),%esi

f01059e4 <gdt>:
	...
f01059ec:	ff                   	(bad)  
f01059ed:	ff 00                	incl   (%eax)
f01059ef:	00 00                	add    %al,(%eax)
f01059f1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01059f8:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01059fc <gdtdesc>:
f01059fc:	17                   	pop    %ss
f01059fd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105a02 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105a02:	90                   	nop
	...

f0105a04 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105a04:	55                   	push   %ebp
f0105a05:	89 e5                	mov    %esp,%ebp
f0105a07:	56                   	push   %esi
f0105a08:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a09:	85 d2                	test   %edx,%edx
f0105a0b:	7e 17                	jle    f0105a24 <sum+0x20>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a0d:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0105a12:	b9 00 00 00 00       	mov    $0x0,%ecx
		sum += ((uint8_t *)addr)[i];
f0105a17:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0105a1b:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a1d:	41                   	inc    %ecx
f0105a1e:	39 d1                	cmp    %edx,%ecx
f0105a20:	75 f5                	jne    f0105a17 <sum+0x13>
f0105a22:	eb 05                	jmp    f0105a29 <sum+0x25>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a24:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0105a29:	88 d8                	mov    %bl,%al
f0105a2b:	5b                   	pop    %ebx
f0105a2c:	5e                   	pop    %esi
f0105a2d:	c9                   	leave  
f0105a2e:	c3                   	ret    

f0105a2f <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105a2f:	55                   	push   %ebp
f0105a30:	89 e5                	mov    %esp,%ebp
f0105a32:	56                   	push   %esi
f0105a33:	53                   	push   %ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a34:	8b 0d 88 fe 2d f0    	mov    0xf02dfe88,%ecx
f0105a3a:	89 c3                	mov    %eax,%ebx
f0105a3c:	c1 eb 0c             	shr    $0xc,%ebx
f0105a3f:	39 cb                	cmp    %ecx,%ebx
f0105a41:	72 12                	jb     f0105a55 <mpsearch1+0x26>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a43:	50                   	push   %eax
f0105a44:	68 c8 64 10 f0       	push   $0xf01064c8
f0105a49:	6a 57                	push   $0x57
f0105a4b:	68 a1 84 10 f0       	push   $0xf01084a1
f0105a50:	e8 13 a6 ff ff       	call   f0100068 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105a55:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a58:	89 f2                	mov    %esi,%edx
f0105a5a:	c1 ea 0c             	shr    $0xc,%edx
f0105a5d:	39 d1                	cmp    %edx,%ecx
f0105a5f:	77 12                	ja     f0105a73 <mpsearch1+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a61:	56                   	push   %esi
f0105a62:	68 c8 64 10 f0       	push   $0xf01064c8
f0105a67:	6a 57                	push   $0x57
f0105a69:	68 a1 84 10 f0       	push   $0xf01084a1
f0105a6e:	e8 f5 a5 ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f0105a73:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0105a79:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105a7f:	39 f3                	cmp    %esi,%ebx
f0105a81:	73 35                	jae    f0105ab8 <mpsearch1+0x89>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a83:	83 ec 04             	sub    $0x4,%esp
f0105a86:	6a 04                	push   $0x4
f0105a88:	68 b1 84 10 f0       	push   $0xf01084b1
f0105a8d:	53                   	push   %ebx
f0105a8e:	e8 b5 fd ff ff       	call   f0105848 <memcmp>
f0105a93:	83 c4 10             	add    $0x10,%esp
f0105a96:	85 c0                	test   %eax,%eax
f0105a98:	75 10                	jne    f0105aaa <mpsearch1+0x7b>
		    sum(mp, sizeof(*mp)) == 0)
f0105a9a:	ba 10 00 00 00       	mov    $0x10,%edx
f0105a9f:	89 d8                	mov    %ebx,%eax
f0105aa1:	e8 5e ff ff ff       	call   f0105a04 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105aa6:	84 c0                	test   %al,%al
f0105aa8:	74 13                	je     f0105abd <mpsearch1+0x8e>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105aaa:	83 c3 10             	add    $0x10,%ebx
f0105aad:	39 de                	cmp    %ebx,%esi
f0105aaf:	77 d2                	ja     f0105a83 <mpsearch1+0x54>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105ab1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105ab6:	eb 05                	jmp    f0105abd <mpsearch1+0x8e>
f0105ab8:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105abd:	89 d8                	mov    %ebx,%eax
f0105abf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105ac2:	5b                   	pop    %ebx
f0105ac3:	5e                   	pop    %esi
f0105ac4:	c9                   	leave  
f0105ac5:	c3                   	ret    

f0105ac6 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105ac6:	55                   	push   %ebp
f0105ac7:	89 e5                	mov    %esp,%ebp
f0105ac9:	57                   	push   %edi
f0105aca:	56                   	push   %esi
f0105acb:	53                   	push   %ebx
f0105acc:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105acf:	c7 05 c0 03 2e f0 20 	movl   $0xf02e0020,0xf02e03c0
f0105ad6:	00 2e f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ad9:	83 3d 88 fe 2d f0 00 	cmpl   $0x0,0xf02dfe88
f0105ae0:	75 16                	jne    f0105af8 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ae2:	68 00 04 00 00       	push   $0x400
f0105ae7:	68 c8 64 10 f0       	push   $0xf01064c8
f0105aec:	6a 6f                	push   $0x6f
f0105aee:	68 a1 84 10 f0       	push   $0xf01084a1
f0105af3:	e8 70 a5 ff ff       	call   f0100068 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105af8:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105aff:	85 c0                	test   %eax,%eax
f0105b01:	74 16                	je     f0105b19 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
f0105b03:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105b06:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b0b:	e8 1f ff ff ff       	call   f0105a2f <mpsearch1>
f0105b10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b13:	85 c0                	test   %eax,%eax
f0105b15:	75 3c                	jne    f0105b53 <mp_init+0x8d>
f0105b17:	eb 20                	jmp    f0105b39 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105b19:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105b20:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105b23:	2d 00 04 00 00       	sub    $0x400,%eax
f0105b28:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b2d:	e8 fd fe ff ff       	call   f0105a2f <mpsearch1>
f0105b32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b35:	85 c0                	test   %eax,%eax
f0105b37:	75 1a                	jne    f0105b53 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105b39:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105b3e:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105b43:	e8 e7 fe ff ff       	call   f0105a2f <mpsearch1>
f0105b48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105b4b:	85 c0                	test   %eax,%eax
f0105b4d:	0f 84 3b 02 00 00    	je     f0105d8e <mp_init+0x2c8>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b56:	8b 70 04             	mov    0x4(%eax),%esi
f0105b59:	85 f6                	test   %esi,%esi
f0105b5b:	74 06                	je     f0105b63 <mp_init+0x9d>
f0105b5d:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105b61:	74 15                	je     f0105b78 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105b63:	83 ec 0c             	sub    $0xc,%esp
f0105b66:	68 14 83 10 f0       	push   $0xf0108314
f0105b6b:	e8 1d e2 ff ff       	call   f0103d8d <cprintf>
f0105b70:	83 c4 10             	add    $0x10,%esp
f0105b73:	e9 16 02 00 00       	jmp    f0105d8e <mp_init+0x2c8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b78:	89 f0                	mov    %esi,%eax
f0105b7a:	c1 e8 0c             	shr    $0xc,%eax
f0105b7d:	3b 05 88 fe 2d f0    	cmp    0xf02dfe88,%eax
f0105b83:	72 15                	jb     f0105b9a <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b85:	56                   	push   %esi
f0105b86:	68 c8 64 10 f0       	push   $0xf01064c8
f0105b8b:	68 90 00 00 00       	push   $0x90
f0105b90:	68 a1 84 10 f0       	push   $0xf01084a1
f0105b95:	e8 ce a4 ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f0105b9a:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105ba0:	83 ec 04             	sub    $0x4,%esp
f0105ba3:	6a 04                	push   $0x4
f0105ba5:	68 b6 84 10 f0       	push   $0xf01084b6
f0105baa:	56                   	push   %esi
f0105bab:	e8 98 fc ff ff       	call   f0105848 <memcmp>
f0105bb0:	83 c4 10             	add    $0x10,%esp
f0105bb3:	85 c0                	test   %eax,%eax
f0105bb5:	74 15                	je     f0105bcc <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105bb7:	83 ec 0c             	sub    $0xc,%esp
f0105bba:	68 44 83 10 f0       	push   $0xf0108344
f0105bbf:	e8 c9 e1 ff ff       	call   f0103d8d <cprintf>
f0105bc4:	83 c4 10             	add    $0x10,%esp
f0105bc7:	e9 c2 01 00 00       	jmp    f0105d8e <mp_init+0x2c8>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105bcc:	66 8b 5e 04          	mov    0x4(%esi),%bx
f0105bd0:	0f b7 d3             	movzwl %bx,%edx
f0105bd3:	89 f0                	mov    %esi,%eax
f0105bd5:	e8 2a fe ff ff       	call   f0105a04 <sum>
f0105bda:	84 c0                	test   %al,%al
f0105bdc:	74 15                	je     f0105bf3 <mp_init+0x12d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105bde:	83 ec 0c             	sub    $0xc,%esp
f0105be1:	68 78 83 10 f0       	push   $0xf0108378
f0105be6:	e8 a2 e1 ff ff       	call   f0103d8d <cprintf>
f0105beb:	83 c4 10             	add    $0x10,%esp
f0105bee:	e9 9b 01 00 00       	jmp    f0105d8e <mp_init+0x2c8>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105bf3:	8a 46 06             	mov    0x6(%esi),%al
f0105bf6:	3c 01                	cmp    $0x1,%al
f0105bf8:	74 1d                	je     f0105c17 <mp_init+0x151>
f0105bfa:	3c 04                	cmp    $0x4,%al
f0105bfc:	74 19                	je     f0105c17 <mp_init+0x151>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105bfe:	83 ec 08             	sub    $0x8,%esp
f0105c01:	0f b6 c0             	movzbl %al,%eax
f0105c04:	50                   	push   %eax
f0105c05:	68 9c 83 10 f0       	push   $0xf010839c
f0105c0a:	e8 7e e1 ff ff       	call   f0103d8d <cprintf>
f0105c0f:	83 c4 10             	add    $0x10,%esp
f0105c12:	e9 77 01 00 00       	jmp    f0105d8e <mp_init+0x2c8>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0105c17:	0f b7 56 28          	movzwl 0x28(%esi),%edx
f0105c1b:	0f b7 c3             	movzwl %bx,%eax
f0105c1e:	8d 04 06             	lea    (%esi,%eax,1),%eax
f0105c21:	e8 de fd ff ff       	call   f0105a04 <sum>
f0105c26:	3a 46 2a             	cmp    0x2a(%esi),%al
f0105c29:	74 15                	je     f0105c40 <mp_init+0x17a>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105c2b:	83 ec 0c             	sub    $0xc,%esp
f0105c2e:	68 bc 83 10 f0       	push   $0xf01083bc
f0105c33:	e8 55 e1 ff ff       	call   f0103d8d <cprintf>
f0105c38:	83 c4 10             	add    $0x10,%esp
f0105c3b:	e9 4e 01 00 00       	jmp    f0105d8e <mp_init+0x2c8>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105c40:	85 f6                	test   %esi,%esi
f0105c42:	0f 84 46 01 00 00    	je     f0105d8e <mp_init+0x2c8>
		return;
	ismp = 1;
f0105c48:	c7 05 00 00 2e f0 01 	movl   $0x1,0xf02e0000
f0105c4f:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105c52:	8b 46 24             	mov    0x24(%esi),%eax
f0105c55:	a3 00 10 32 f0       	mov    %eax,0xf0321000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c5a:	66 83 7e 22 00       	cmpw   $0x0,0x22(%esi)
f0105c5f:	0f 84 ac 00 00 00    	je     f0105d11 <mp_init+0x24b>
f0105c65:	8d 5e 2c             	lea    0x2c(%esi),%ebx
f0105c68:	bf 00 00 00 00       	mov    $0x0,%edi
		switch (*p) {
f0105c6d:	8a 03                	mov    (%ebx),%al
f0105c6f:	84 c0                	test   %al,%al
f0105c71:	74 06                	je     f0105c79 <mp_init+0x1b3>
f0105c73:	3c 04                	cmp    $0x4,%al
f0105c75:	77 6b                	ja     f0105ce2 <mp_init+0x21c>
f0105c77:	eb 64                	jmp    f0105cdd <mp_init+0x217>
		case MPPROC:
			proc = (struct mpproc *)p;
f0105c79:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f0105c7b:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f0105c7f:	74 1d                	je     f0105c9e <mp_init+0x1d8>
				bootcpu = &cpus[ncpu];
f0105c81:	a1 c4 03 2e f0       	mov    0xf02e03c4,%eax
f0105c86:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0105c8d:	29 c1                	sub    %eax,%ecx
f0105c8f:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0105c92:	8d 04 85 20 00 2e f0 	lea    -0xfd1ffe0(,%eax,4),%eax
f0105c99:	a3 c0 03 2e f0       	mov    %eax,0xf02e03c0
			if (ncpu < NCPU) {
f0105c9e:	a1 c4 03 2e f0       	mov    0xf02e03c4,%eax
f0105ca3:	83 f8 07             	cmp    $0x7,%eax
f0105ca6:	7f 1b                	jg     f0105cc3 <mp_init+0x1fd>
				cpus[ncpu].cpu_id = ncpu;
f0105ca8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105caf:	29 c2                	sub    %eax,%edx
f0105cb1:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105cb4:	88 04 95 20 00 2e f0 	mov    %al,-0xfd1ffe0(,%edx,4)
				ncpu++;
f0105cbb:	40                   	inc    %eax
f0105cbc:	a3 c4 03 2e f0       	mov    %eax,0xf02e03c4
f0105cc1:	eb 15                	jmp    f0105cd8 <mp_init+0x212>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105cc3:	83 ec 08             	sub    $0x8,%esp
f0105cc6:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0105cca:	50                   	push   %eax
f0105ccb:	68 ec 83 10 f0       	push   $0xf01083ec
f0105cd0:	e8 b8 e0 ff ff       	call   f0103d8d <cprintf>
f0105cd5:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105cd8:	83 c3 14             	add    $0x14,%ebx
			continue;
f0105cdb:	eb 27                	jmp    f0105d04 <mp_init+0x23e>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105cdd:	83 c3 08             	add    $0x8,%ebx
			continue;
f0105ce0:	eb 22                	jmp    f0105d04 <mp_init+0x23e>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105ce2:	83 ec 08             	sub    $0x8,%esp
f0105ce5:	0f b6 c0             	movzbl %al,%eax
f0105ce8:	50                   	push   %eax
f0105ce9:	68 14 84 10 f0       	push   $0xf0108414
f0105cee:	e8 9a e0 ff ff       	call   f0103d8d <cprintf>
			ismp = 0;
f0105cf3:	c7 05 00 00 2e f0 00 	movl   $0x0,0xf02e0000
f0105cfa:	00 00 00 
			i = conf->entry;
f0105cfd:	0f b7 7e 22          	movzwl 0x22(%esi),%edi
f0105d01:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d04:	47                   	inc    %edi
f0105d05:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105d09:	39 f8                	cmp    %edi,%eax
f0105d0b:	0f 87 5c ff ff ff    	ja     f0105c6d <mp_init+0x1a7>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105d11:	a1 c0 03 2e f0       	mov    0xf02e03c0,%eax
f0105d16:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105d1d:	83 3d 00 00 2e f0 00 	cmpl   $0x0,0xf02e0000
f0105d24:	75 26                	jne    f0105d4c <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105d26:	c7 05 c4 03 2e f0 01 	movl   $0x1,0xf02e03c4
f0105d2d:	00 00 00 
		lapicaddr = 0;
f0105d30:	c7 05 00 10 32 f0 00 	movl   $0x0,0xf0321000
f0105d37:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105d3a:	83 ec 0c             	sub    $0xc,%esp
f0105d3d:	68 34 84 10 f0       	push   $0xf0108434
f0105d42:	e8 46 e0 ff ff       	call   f0103d8d <cprintf>
		return;
f0105d47:	83 c4 10             	add    $0x10,%esp
f0105d4a:	eb 42                	jmp    f0105d8e <mp_init+0x2c8>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105d4c:	83 ec 04             	sub    $0x4,%esp
f0105d4f:	ff 35 c4 03 2e f0    	pushl  0xf02e03c4
f0105d55:	0f b6 00             	movzbl (%eax),%eax
f0105d58:	50                   	push   %eax
f0105d59:	68 bb 84 10 f0       	push   $0xf01084bb
f0105d5e:	e8 2a e0 ff ff       	call   f0103d8d <cprintf>

	if (mp->imcrp) {
f0105d63:	83 c4 10             	add    $0x10,%esp
f0105d66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d69:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105d6d:	74 1f                	je     f0105d8e <mp_init+0x2c8>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105d6f:	83 ec 0c             	sub    $0xc,%esp
f0105d72:	68 60 84 10 f0       	push   $0xf0108460
f0105d77:	e8 11 e0 ff ff       	call   f0103d8d <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d7c:	ba 22 00 00 00       	mov    $0x22,%edx
f0105d81:	b0 70                	mov    $0x70,%al
f0105d83:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105d84:	b2 23                	mov    $0x23,%dl
f0105d86:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105d87:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d8a:	ee                   	out    %al,(%dx)
f0105d8b:	83 c4 10             	add    $0x10,%esp
	}
}
f0105d8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d91:	5b                   	pop    %ebx
f0105d92:	5e                   	pop    %esi
f0105d93:	5f                   	pop    %edi
f0105d94:	c9                   	leave  
f0105d95:	c3                   	ret    
	...

f0105d98 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105d98:	55                   	push   %ebp
f0105d99:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105d9b:	c1 e0 02             	shl    $0x2,%eax
f0105d9e:	03 05 04 10 32 f0    	add    0xf0321004,%eax
f0105da4:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105da6:	a1 04 10 32 f0       	mov    0xf0321004,%eax
f0105dab:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105dae:	c9                   	leave  
f0105daf:	c3                   	ret    

f0105db0 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105db0:	55                   	push   %ebp
f0105db1:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105db3:	a1 04 10 32 f0       	mov    0xf0321004,%eax
f0105db8:	85 c0                	test   %eax,%eax
f0105dba:	74 08                	je     f0105dc4 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105dbc:	8b 40 20             	mov    0x20(%eax),%eax
f0105dbf:	c1 e8 18             	shr    $0x18,%eax
f0105dc2:	eb 05                	jmp    f0105dc9 <cpunum+0x19>
	return 0;
f0105dc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105dc9:	c9                   	leave  
f0105dca:	c3                   	ret    

f0105dcb <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105dcb:	55                   	push   %ebp
f0105dcc:	89 e5                	mov    %esp,%ebp
f0105dce:	83 ec 08             	sub    $0x8,%esp
	if (!lapicaddr)
f0105dd1:	a1 00 10 32 f0       	mov    0xf0321000,%eax
f0105dd6:	85 c0                	test   %eax,%eax
f0105dd8:	0f 84 2a 01 00 00    	je     f0105f08 <lapic_init+0x13d>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105dde:	83 ec 08             	sub    $0x8,%esp
f0105de1:	68 00 10 00 00       	push   $0x1000
f0105de6:	50                   	push   %eax
f0105de7:	e8 2e bb ff ff       	call   f010191a <mmio_map_region>
f0105dec:	a3 04 10 32 f0       	mov    %eax,0xf0321004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105df1:	ba 27 01 00 00       	mov    $0x127,%edx
f0105df6:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105dfb:	e8 98 ff ff ff       	call   f0105d98 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105e00:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105e05:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105e0a:	e8 89 ff ff ff       	call   f0105d98 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105e0f:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105e14:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105e19:	e8 7a ff ff ff       	call   f0105d98 <lapicw>
	lapicw(TICR, 10000000); 
f0105e1e:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105e23:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105e28:	e8 6b ff ff ff       	call   f0105d98 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105e2d:	e8 7e ff ff ff       	call   f0105db0 <cpunum>
f0105e32:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105e39:	29 c2                	sub    %eax,%edx
f0105e3b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105e3e:	8d 04 85 20 00 2e f0 	lea    -0xfd1ffe0(,%eax,4),%eax
f0105e45:	83 c4 10             	add    $0x10,%esp
f0105e48:	39 05 c0 03 2e f0    	cmp    %eax,0xf02e03c0
f0105e4e:	74 0f                	je     f0105e5f <lapic_init+0x94>
		lapicw(LINT0, MASKED);
f0105e50:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e55:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105e5a:	e8 39 ff ff ff       	call   f0105d98 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105e5f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e64:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105e69:	e8 2a ff ff ff       	call   f0105d98 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105e6e:	a1 04 10 32 f0       	mov    0xf0321004,%eax
f0105e73:	8b 40 30             	mov    0x30(%eax),%eax
f0105e76:	c1 e8 10             	shr    $0x10,%eax
f0105e79:	3c 03                	cmp    $0x3,%al
f0105e7b:	76 0f                	jbe    f0105e8c <lapic_init+0xc1>
		lapicw(PCINT, MASKED);
f0105e7d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e82:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105e87:	e8 0c ff ff ff       	call   f0105d98 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105e8c:	ba 33 00 00 00       	mov    $0x33,%edx
f0105e91:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105e96:	e8 fd fe ff ff       	call   f0105d98 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105e9b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ea0:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ea5:	e8 ee fe ff ff       	call   f0105d98 <lapicw>
	lapicw(ESR, 0);
f0105eaa:	ba 00 00 00 00       	mov    $0x0,%edx
f0105eaf:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105eb4:	e8 df fe ff ff       	call   f0105d98 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105eb9:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ebe:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105ec3:	e8 d0 fe ff ff       	call   f0105d98 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105ec8:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ecd:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ed2:	e8 c1 fe ff ff       	call   f0105d98 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105ed7:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105edc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ee1:	e8 b2 fe ff ff       	call   f0105d98 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105ee6:	8b 15 04 10 32 f0    	mov    0xf0321004,%edx
f0105eec:	81 c2 00 03 00 00    	add    $0x300,%edx
f0105ef2:	8b 02                	mov    (%edx),%eax
f0105ef4:	f6 c4 10             	test   $0x10,%ah
f0105ef7:	75 f9                	jne    f0105ef2 <lapic_init+0x127>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105ef9:	ba 00 00 00 00       	mov    $0x0,%edx
f0105efe:	b8 20 00 00 00       	mov    $0x20,%eax
f0105f03:	e8 90 fe ff ff       	call   f0105d98 <lapicw>
}
f0105f08:	c9                   	leave  
f0105f09:	c3                   	ret    

f0105f0a <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105f0a:	55                   	push   %ebp
f0105f0b:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105f0d:	83 3d 04 10 32 f0 00 	cmpl   $0x0,0xf0321004
f0105f14:	74 0f                	je     f0105f25 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0105f16:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f1b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f20:	e8 73 fe ff ff       	call   f0105d98 <lapicw>
}
f0105f25:	c9                   	leave  
f0105f26:	c3                   	ret    

f0105f27 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105f27:	55                   	push   %ebp
f0105f28:	89 e5                	mov    %esp,%ebp
f0105f2a:	56                   	push   %esi
f0105f2b:	53                   	push   %ebx
f0105f2c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105f2f:	8a 5d 08             	mov    0x8(%ebp),%bl
f0105f32:	ba 70 00 00 00       	mov    $0x70,%edx
f0105f37:	b0 0f                	mov    $0xf,%al
f0105f39:	ee                   	out    %al,(%dx)
f0105f3a:	b2 71                	mov    $0x71,%dl
f0105f3c:	b0 0a                	mov    $0xa,%al
f0105f3e:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f3f:	83 3d 88 fe 2d f0 00 	cmpl   $0x0,0xf02dfe88
f0105f46:	75 19                	jne    f0105f61 <lapic_startap+0x3a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f48:	68 67 04 00 00       	push   $0x467
f0105f4d:	68 c8 64 10 f0       	push   $0xf01064c8
f0105f52:	68 98 00 00 00       	push   $0x98
f0105f57:	68 d8 84 10 f0       	push   $0xf01084d8
f0105f5c:	e8 07 a1 ff ff       	call   f0100068 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105f61:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105f68:	00 00 
	wrv[1] = addr >> 4;
f0105f6a:	89 f0                	mov    %esi,%eax
f0105f6c:	c1 e8 04             	shr    $0x4,%eax
f0105f6f:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105f75:	c1 e3 18             	shl    $0x18,%ebx
f0105f78:	89 da                	mov    %ebx,%edx
f0105f7a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f7f:	e8 14 fe ff ff       	call   f0105d98 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105f84:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105f89:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f8e:	e8 05 fe ff ff       	call   f0105d98 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105f93:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105f98:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f9d:	e8 f6 fd ff ff       	call   f0105d98 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fa2:	c1 ee 0c             	shr    $0xc,%esi
f0105fa5:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105fab:	89 da                	mov    %ebx,%edx
f0105fad:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fb2:	e8 e1 fd ff ff       	call   f0105d98 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fb7:	89 f2                	mov    %esi,%edx
f0105fb9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fbe:	e8 d5 fd ff ff       	call   f0105d98 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105fc3:	89 da                	mov    %ebx,%edx
f0105fc5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fca:	e8 c9 fd ff ff       	call   f0105d98 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105fcf:	89 f2                	mov    %esi,%edx
f0105fd1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fd6:	e8 bd fd ff ff       	call   f0105d98 <lapicw>
		microdelay(200);
	}
}
f0105fdb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105fde:	5b                   	pop    %ebx
f0105fdf:	5e                   	pop    %esi
f0105fe0:	c9                   	leave  
f0105fe1:	c3                   	ret    

f0105fe2 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105fe2:	55                   	push   %ebp
f0105fe3:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105fe5:	8b 55 08             	mov    0x8(%ebp),%edx
f0105fe8:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105fee:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ff3:	e8 a0 fd ff ff       	call   f0105d98 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105ff8:	8b 15 04 10 32 f0    	mov    0xf0321004,%edx
f0105ffe:	81 c2 00 03 00 00    	add    $0x300,%edx
f0106004:	8b 02                	mov    (%edx),%eax
f0106006:	f6 c4 10             	test   $0x10,%ah
f0106009:	75 f9                	jne    f0106004 <lapic_ipi+0x22>
		;
}
f010600b:	c9                   	leave  
f010600c:	c3                   	ret    
f010600d:	00 00                	add    %al,(%eax)
	...

f0106010 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106010:	55                   	push   %ebp
f0106011:	89 e5                	mov    %esp,%ebp
f0106013:	53                   	push   %ebx
f0106014:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0106017:	83 38 00             	cmpl   $0x0,(%eax)
f010601a:	74 25                	je     f0106041 <holding+0x31>
f010601c:	8b 58 08             	mov    0x8(%eax),%ebx
f010601f:	e8 8c fd ff ff       	call   f0105db0 <cpunum>
f0106024:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010602b:	29 c2                	sub    %eax,%edx
f010602d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106030:	8d 04 85 20 00 2e f0 	lea    -0xfd1ffe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106037:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106039:	0f 94 c0             	sete   %al
f010603c:	0f b6 c0             	movzbl %al,%eax
f010603f:	eb 05                	jmp    f0106046 <holding+0x36>
f0106041:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106046:	83 c4 04             	add    $0x4,%esp
f0106049:	5b                   	pop    %ebx
f010604a:	c9                   	leave  
f010604b:	c3                   	ret    

f010604c <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010604c:	55                   	push   %ebp
f010604d:	89 e5                	mov    %esp,%ebp
f010604f:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106052:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106058:	8b 55 0c             	mov    0xc(%ebp),%edx
f010605b:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010605e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106065:	c9                   	leave  
f0106066:	c3                   	ret    

f0106067 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106067:	55                   	push   %ebp
f0106068:	89 e5                	mov    %esp,%ebp
f010606a:	53                   	push   %ebx
f010606b:	83 ec 04             	sub    $0x4,%esp
f010606e:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106071:	89 d8                	mov    %ebx,%eax
f0106073:	e8 98 ff ff ff       	call   f0106010 <holding>
f0106078:	85 c0                	test   %eax,%eax
f010607a:	75 0d                	jne    f0106089 <spin_lock+0x22>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010607c:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010607e:	b0 01                	mov    $0x1,%al
f0106080:	f0 87 03             	lock xchg %eax,(%ebx)
f0106083:	85 c0                	test   %eax,%eax
f0106085:	75 20                	jne    f01060a7 <spin_lock+0x40>
f0106087:	eb 2e                	jmp    f01060b7 <spin_lock+0x50>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106089:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010608c:	e8 1f fd ff ff       	call   f0105db0 <cpunum>
f0106091:	83 ec 0c             	sub    $0xc,%esp
f0106094:	53                   	push   %ebx
f0106095:	50                   	push   %eax
f0106096:	68 e8 84 10 f0       	push   $0xf01084e8
f010609b:	6a 41                	push   $0x41
f010609d:	68 4c 85 10 f0       	push   $0xf010854c
f01060a2:	e8 c1 9f ff ff       	call   f0100068 <_panic>
f01060a7:	b9 01 00 00 00       	mov    $0x1,%ecx

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01060ac:	f3 90                	pause  
f01060ae:	89 c8                	mov    %ecx,%eax
f01060b0:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01060b3:	85 c0                	test   %eax,%eax
f01060b5:	75 f5                	jne    f01060ac <spin_lock+0x45>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01060b7:	e8 f4 fc ff ff       	call   f0105db0 <cpunum>
f01060bc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01060c3:	29 c2                	sub    %eax,%edx
f01060c5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01060c8:	8d 04 85 20 00 2e f0 	lea    -0xfd1ffe0(,%eax,4),%eax
f01060cf:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01060d2:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01060d5:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01060d7:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01060dc:	77 30                	ja     f010610e <spin_lock+0xa7>
f01060de:	eb 27                	jmp    f0106107 <spin_lock+0xa0>
f01060e0:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01060e6:	76 10                	jbe    f01060f8 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01060e8:	8b 5a 04             	mov    0x4(%edx),%ebx
f01060eb:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01060ee:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01060f0:	40                   	inc    %eax
f01060f1:	83 f8 0a             	cmp    $0xa,%eax
f01060f4:	75 ea                	jne    f01060e0 <spin_lock+0x79>
f01060f6:	eb 25                	jmp    f010611d <spin_lock+0xb6>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01060f8:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01060ff:	40                   	inc    %eax
f0106100:	83 f8 09             	cmp    $0x9,%eax
f0106103:	7e f3                	jle    f01060f8 <spin_lock+0x91>
f0106105:	eb 16                	jmp    f010611d <spin_lock+0xb6>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106107:	b8 00 00 00 00       	mov    $0x0,%eax
f010610c:	eb ea                	jmp    f01060f8 <spin_lock+0x91>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f010610e:	8b 50 04             	mov    0x4(%eax),%edx
f0106111:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106114:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106116:	b8 01 00 00 00       	mov    $0x1,%eax
f010611b:	eb c3                	jmp    f01060e0 <spin_lock+0x79>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010611d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106120:	c9                   	leave  
f0106121:	c3                   	ret    

f0106122 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106122:	55                   	push   %ebp
f0106123:	89 e5                	mov    %esp,%ebp
f0106125:	57                   	push   %edi
f0106126:	56                   	push   %esi
f0106127:	53                   	push   %ebx
f0106128:	83 ec 4c             	sub    $0x4c,%esp
f010612b:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010612e:	89 d8                	mov    %ebx,%eax
f0106130:	e8 db fe ff ff       	call   f0106010 <holding>
f0106135:	85 c0                	test   %eax,%eax
f0106137:	0f 85 c0 00 00 00    	jne    f01061fd <spin_unlock+0xdb>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010613d:	83 ec 04             	sub    $0x4,%esp
f0106140:	6a 28                	push   $0x28
f0106142:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106145:	50                   	push   %eax
f0106146:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0106149:	50                   	push   %eax
f010614a:	e8 7c f6 ff ff       	call   f01057cb <memmove>
			
		cprintf("%u\n", lk->cpu->cpu_id);
f010614f:	83 c4 08             	add    $0x8,%esp
f0106152:	8b 43 08             	mov    0x8(%ebx),%eax
f0106155:	0f b6 00             	movzbl (%eax),%eax
f0106158:	50                   	push   %eax
f0106159:	68 ae 7d 10 f0       	push   $0xf0107dae
f010615e:	e8 2a dc ff ff       	call   f0103d8d <cprintf>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106163:	8b 43 08             	mov    0x8(%ebx),%eax
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
			
		cprintf("%u\n", lk->cpu->cpu_id);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106166:	0f b6 30             	movzbl (%eax),%esi
f0106169:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010616c:	e8 3f fc ff ff       	call   f0105db0 <cpunum>
f0106171:	56                   	push   %esi
f0106172:	53                   	push   %ebx
f0106173:	50                   	push   %eax
f0106174:	68 14 85 10 f0       	push   $0xf0108514
f0106179:	e8 0f dc ff ff       	call   f0103d8d <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
f010617e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0106181:	83 c4 20             	add    $0x20,%esp
f0106184:	85 c0                	test   %eax,%eax
f0106186:	74 61                	je     f01061e9 <spin_unlock+0xc7>
f0106188:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f010618b:	8d 7d cc             	lea    -0x34(%ebp),%edi
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010618e:	8d 75 d0             	lea    -0x30(%ebp),%esi
f0106191:	83 ec 08             	sub    $0x8,%esp
f0106194:	56                   	push   %esi
f0106195:	50                   	push   %eax
f0106196:	e8 3e eb ff ff       	call   f0104cd9 <debuginfo_eip>
f010619b:	83 c4 10             	add    $0x10,%esp
f010619e:	85 c0                	test   %eax,%eax
f01061a0:	78 27                	js     f01061c9 <spin_unlock+0xa7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01061a2:	8b 03                	mov    (%ebx),%eax
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01061a4:	83 ec 04             	sub    $0x4,%esp
f01061a7:	89 c2                	mov    %eax,%edx
f01061a9:	2b 55 e0             	sub    -0x20(%ebp),%edx
f01061ac:	52                   	push   %edx
f01061ad:	ff 75 d8             	pushl  -0x28(%ebp)
f01061b0:	ff 75 dc             	pushl  -0x24(%ebp)
f01061b3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01061b6:	ff 75 d0             	pushl  -0x30(%ebp)
f01061b9:	50                   	push   %eax
f01061ba:	68 5c 85 10 f0       	push   $0xf010855c
f01061bf:	e8 c9 db ff ff       	call   f0103d8d <cprintf>
f01061c4:	83 c4 20             	add    $0x20,%esp
f01061c7:	eb 12                	jmp    f01061db <spin_unlock+0xb9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01061c9:	83 ec 08             	sub    $0x8,%esp
f01061cc:	ff 33                	pushl  (%ebx)
f01061ce:	68 73 85 10 f0       	push   $0xf0108573
f01061d3:	e8 b5 db ff ff       	call   f0103d8d <cprintf>
f01061d8:	83 c4 10             	add    $0x10,%esp
			
		cprintf("%u\n", lk->cpu->cpu_id);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
f01061db:	39 fb                	cmp    %edi,%ebx
f01061dd:	74 0a                	je     f01061e9 <spin_unlock+0xc7>
f01061df:	8b 43 04             	mov    0x4(%ebx),%eax
f01061e2:	83 c3 04             	add    $0x4,%ebx
f01061e5:	85 c0                	test   %eax,%eax
f01061e7:	75 a8                	jne    f0106191 <spin_unlock+0x6f>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01061e9:	83 ec 04             	sub    $0x4,%esp
f01061ec:	68 7b 85 10 f0       	push   $0xf010857b
f01061f1:	6a 6a                	push   $0x6a
f01061f3:	68 4c 85 10 f0       	push   $0xf010854c
f01061f8:	e8 6b 9e ff ff       	call   f0100068 <_panic>
	}
	lk->pcs[0] = 0;
f01061fd:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106204:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010620b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106210:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106213:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106216:	5b                   	pop    %ebx
f0106217:	5e                   	pop    %esi
f0106218:	5f                   	pop    %edi
f0106219:	c9                   	leave  
f010621a:	c3                   	ret    
	...

f010621c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f010621c:	55                   	push   %ebp
f010621d:	89 e5                	mov    %esp,%ebp
f010621f:	57                   	push   %edi
f0106220:	56                   	push   %esi
f0106221:	83 ec 10             	sub    $0x10,%esp
f0106224:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106227:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010622a:	89 7d f0             	mov    %edi,-0x10(%ebp)
f010622d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0106230:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0106233:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106236:	85 c0                	test   %eax,%eax
f0106238:	75 2e                	jne    f0106268 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f010623a:	39 f1                	cmp    %esi,%ecx
f010623c:	77 5a                	ja     f0106298 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f010623e:	85 c9                	test   %ecx,%ecx
f0106240:	75 0b                	jne    f010624d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106242:	b8 01 00 00 00       	mov    $0x1,%eax
f0106247:	31 d2                	xor    %edx,%edx
f0106249:	f7 f1                	div    %ecx
f010624b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010624d:	31 d2                	xor    %edx,%edx
f010624f:	89 f0                	mov    %esi,%eax
f0106251:	f7 f1                	div    %ecx
f0106253:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106255:	89 f8                	mov    %edi,%eax
f0106257:	f7 f1                	div    %ecx
f0106259:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010625b:	89 f8                	mov    %edi,%eax
f010625d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010625f:	83 c4 10             	add    $0x10,%esp
f0106262:	5e                   	pop    %esi
f0106263:	5f                   	pop    %edi
f0106264:	c9                   	leave  
f0106265:	c3                   	ret    
f0106266:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106268:	39 f0                	cmp    %esi,%eax
f010626a:	77 1c                	ja     f0106288 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f010626c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f010626f:	83 f7 1f             	xor    $0x1f,%edi
f0106272:	75 3c                	jne    f01062b0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106274:	39 f0                	cmp    %esi,%eax
f0106276:	0f 82 90 00 00 00    	jb     f010630c <__udivdi3+0xf0>
f010627c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010627f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0106282:	0f 86 84 00 00 00    	jbe    f010630c <__udivdi3+0xf0>
f0106288:	31 f6                	xor    %esi,%esi
f010628a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010628c:	89 f8                	mov    %edi,%eax
f010628e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106290:	83 c4 10             	add    $0x10,%esp
f0106293:	5e                   	pop    %esi
f0106294:	5f                   	pop    %edi
f0106295:	c9                   	leave  
f0106296:	c3                   	ret    
f0106297:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106298:	89 f2                	mov    %esi,%edx
f010629a:	89 f8                	mov    %edi,%eax
f010629c:	f7 f1                	div    %ecx
f010629e:	89 c7                	mov    %eax,%edi
f01062a0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01062a2:	89 f8                	mov    %edi,%eax
f01062a4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01062a6:	83 c4 10             	add    $0x10,%esp
f01062a9:	5e                   	pop    %esi
f01062aa:	5f                   	pop    %edi
f01062ab:	c9                   	leave  
f01062ac:	c3                   	ret    
f01062ad:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01062b0:	89 f9                	mov    %edi,%ecx
f01062b2:	d3 e0                	shl    %cl,%eax
f01062b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01062b7:	b8 20 00 00 00       	mov    $0x20,%eax
f01062bc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f01062be:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01062c1:	88 c1                	mov    %al,%cl
f01062c3:	d3 ea                	shr    %cl,%edx
f01062c5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01062c8:	09 ca                	or     %ecx,%edx
f01062ca:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f01062cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01062d0:	89 f9                	mov    %edi,%ecx
f01062d2:	d3 e2                	shl    %cl,%edx
f01062d4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f01062d7:	89 f2                	mov    %esi,%edx
f01062d9:	88 c1                	mov    %al,%cl
f01062db:	d3 ea                	shr    %cl,%edx
f01062dd:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f01062e0:	89 f2                	mov    %esi,%edx
f01062e2:	89 f9                	mov    %edi,%ecx
f01062e4:	d3 e2                	shl    %cl,%edx
f01062e6:	8b 75 f0             	mov    -0x10(%ebp),%esi
f01062e9:	88 c1                	mov    %al,%cl
f01062eb:	d3 ee                	shr    %cl,%esi
f01062ed:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01062ef:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01062f2:	89 f0                	mov    %esi,%eax
f01062f4:	89 ca                	mov    %ecx,%edx
f01062f6:	f7 75 ec             	divl   -0x14(%ebp)
f01062f9:	89 d1                	mov    %edx,%ecx
f01062fb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01062fd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106300:	39 d1                	cmp    %edx,%ecx
f0106302:	72 28                	jb     f010632c <__udivdi3+0x110>
f0106304:	74 1a                	je     f0106320 <__udivdi3+0x104>
f0106306:	89 f7                	mov    %esi,%edi
f0106308:	31 f6                	xor    %esi,%esi
f010630a:	eb 80                	jmp    f010628c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010630c:	31 f6                	xor    %esi,%esi
f010630e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106313:	89 f8                	mov    %edi,%eax
f0106315:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106317:	83 c4 10             	add    $0x10,%esp
f010631a:	5e                   	pop    %esi
f010631b:	5f                   	pop    %edi
f010631c:	c9                   	leave  
f010631d:	c3                   	ret    
f010631e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0106320:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106323:	89 f9                	mov    %edi,%ecx
f0106325:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106327:	39 c2                	cmp    %eax,%edx
f0106329:	73 db                	jae    f0106306 <__udivdi3+0xea>
f010632b:	90                   	nop
		{
		  q0--;
f010632c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f010632f:	31 f6                	xor    %esi,%esi
f0106331:	e9 56 ff ff ff       	jmp    f010628c <__udivdi3+0x70>
	...

f0106338 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0106338:	55                   	push   %ebp
f0106339:	89 e5                	mov    %esp,%ebp
f010633b:	57                   	push   %edi
f010633c:	56                   	push   %esi
f010633d:	83 ec 20             	sub    $0x20,%esp
f0106340:	8b 45 08             	mov    0x8(%ebp),%eax
f0106343:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0106346:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106349:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f010634c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010634f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0106352:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0106355:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106357:	85 ff                	test   %edi,%edi
f0106359:	75 15                	jne    f0106370 <__umoddi3+0x38>
    {
      if (d0 > n1)
f010635b:	39 f1                	cmp    %esi,%ecx
f010635d:	0f 86 99 00 00 00    	jbe    f01063fc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106363:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0106365:	89 d0                	mov    %edx,%eax
f0106367:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106369:	83 c4 20             	add    $0x20,%esp
f010636c:	5e                   	pop    %esi
f010636d:	5f                   	pop    %edi
f010636e:	c9                   	leave  
f010636f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106370:	39 f7                	cmp    %esi,%edi
f0106372:	0f 87 a4 00 00 00    	ja     f010641c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106378:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f010637b:	83 f0 1f             	xor    $0x1f,%eax
f010637e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106381:	0f 84 a1 00 00 00    	je     f0106428 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106387:	89 f8                	mov    %edi,%eax
f0106389:	8a 4d ec             	mov    -0x14(%ebp),%cl
f010638c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010638e:	bf 20 00 00 00       	mov    $0x20,%edi
f0106393:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0106396:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106399:	89 f9                	mov    %edi,%ecx
f010639b:	d3 ea                	shr    %cl,%edx
f010639d:	09 c2                	or     %eax,%edx
f010639f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f01063a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01063a5:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01063a8:	d3 e0                	shl    %cl,%eax
f01063aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f01063ad:	89 f2                	mov    %esi,%edx
f01063af:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f01063b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01063b4:	d3 e0                	shl    %cl,%eax
f01063b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f01063b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01063bc:	89 f9                	mov    %edi,%ecx
f01063be:	d3 e8                	shr    %cl,%eax
f01063c0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f01063c2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01063c4:	89 f2                	mov    %esi,%edx
f01063c6:	f7 75 f0             	divl   -0x10(%ebp)
f01063c9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01063cb:	f7 65 f4             	mull   -0xc(%ebp)
f01063ce:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01063d1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01063d3:	39 d6                	cmp    %edx,%esi
f01063d5:	72 71                	jb     f0106448 <__umoddi3+0x110>
f01063d7:	74 7f                	je     f0106458 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01063d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01063dc:	29 c8                	sub    %ecx,%eax
f01063de:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01063e0:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01063e3:	d3 e8                	shr    %cl,%eax
f01063e5:	89 f2                	mov    %esi,%edx
f01063e7:	89 f9                	mov    %edi,%ecx
f01063e9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01063eb:	09 d0                	or     %edx,%eax
f01063ed:	89 f2                	mov    %esi,%edx
f01063ef:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01063f2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01063f4:	83 c4 20             	add    $0x20,%esp
f01063f7:	5e                   	pop    %esi
f01063f8:	5f                   	pop    %edi
f01063f9:	c9                   	leave  
f01063fa:	c3                   	ret    
f01063fb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01063fc:	85 c9                	test   %ecx,%ecx
f01063fe:	75 0b                	jne    f010640b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106400:	b8 01 00 00 00       	mov    $0x1,%eax
f0106405:	31 d2                	xor    %edx,%edx
f0106407:	f7 f1                	div    %ecx
f0106409:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010640b:	89 f0                	mov    %esi,%eax
f010640d:	31 d2                	xor    %edx,%edx
f010640f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106411:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106414:	f7 f1                	div    %ecx
f0106416:	e9 4a ff ff ff       	jmp    f0106365 <__umoddi3+0x2d>
f010641b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f010641c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f010641e:	83 c4 20             	add    $0x20,%esp
f0106421:	5e                   	pop    %esi
f0106422:	5f                   	pop    %edi
f0106423:	c9                   	leave  
f0106424:	c3                   	ret    
f0106425:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106428:	39 f7                	cmp    %esi,%edi
f010642a:	72 05                	jb     f0106431 <__umoddi3+0xf9>
f010642c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f010642f:	77 0c                	ja     f010643d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106431:	89 f2                	mov    %esi,%edx
f0106433:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106436:	29 c8                	sub    %ecx,%eax
f0106438:	19 fa                	sbb    %edi,%edx
f010643a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f010643d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106440:	83 c4 20             	add    $0x20,%esp
f0106443:	5e                   	pop    %esi
f0106444:	5f                   	pop    %edi
f0106445:	c9                   	leave  
f0106446:	c3                   	ret    
f0106447:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106448:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010644b:	89 c1                	mov    %eax,%ecx
f010644d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0106450:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0106453:	eb 84                	jmp    f01063d9 <__umoddi3+0xa1>
f0106455:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106458:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f010645b:	72 eb                	jb     f0106448 <__umoddi3+0x110>
f010645d:	89 f2                	mov    %esi,%edx
f010645f:	e9 75 ff ff ff       	jmp    f01063d9 <__umoddi3+0xa1>
