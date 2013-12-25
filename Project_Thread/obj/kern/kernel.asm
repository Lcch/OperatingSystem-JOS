
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
f0100015:	b8 00 70 12 00       	mov    $0x127000,%eax
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
f0100034:	bc 00 70 12 f0       	mov    $0xf0127000,%esp

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
f010005d:	b8 28 94 12 f0       	mov    $0xf0129428,%eax
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
f0100070:	83 3d 80 0e 22 f0 00 	cmpl   $0x0,0xf0220e80
f0100077:	75 3a                	jne    f01000b3 <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100079:	89 35 80 0e 22 f0    	mov    %esi,0xf0220e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010007f:	fa                   	cli    
f0100080:	fc                   	cld    

	va_start(ap, fmt);
f0100081:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f0100084:	e8 ef 65 00 00       	call   f0106678 <cpunum>
f0100089:	ff 75 0c             	pushl  0xc(%ebp)
f010008c:	ff 75 08             	pushl  0x8(%ebp)
f010008f:	50                   	push   %eax
f0100090:	68 40 6d 10 f0       	push   $0xf0106d40
f0100095:	e8 c7 3d 00 00       	call   f0103e61 <cprintf>
	vcprintf(fmt, ap);
f010009a:	83 c4 08             	add    $0x8,%esp
f010009d:	53                   	push   %ebx
f010009e:	56                   	push   %esi
f010009f:	e8 97 3d 00 00       	call   f0103e3b <vcprintf>
	cprintf("\n");
f01000a4:	c7 04 24 af 70 10 f0 	movl   $0xf01070af,(%esp)
f01000ab:	e8 b1 3d 00 00       	call   f0103e61 <cprintf>
	va_end(ap);
f01000b0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000b3:	83 ec 0c             	sub    $0xc,%esp
f01000b6:	6a 00                	push   $0x0
f01000b8:	e8 a8 0f 00 00       	call   f0101065 <monitor>
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
f01000c8:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000d2:	77 12                	ja     f01000e6 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000d4:	50                   	push   %eax
f01000d5:	68 64 6d 10 f0       	push   $0xf0106d64
f01000da:	6a 7f                	push   $0x7f
f01000dc:	68 ab 6d 10 f0       	push   $0xf0106dab
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
f01000ee:	e8 85 65 00 00       	call   f0106678 <cpunum>
f01000f3:	83 ec 08             	sub    $0x8,%esp
f01000f6:	50                   	push   %eax
f01000f7:	68 b7 6d 10 f0       	push   $0xf0106db7
f01000fc:	e8 60 3d 00 00       	call   f0103e61 <cprintf>

	lapic_init();
f0100101:	e8 8d 65 00 00       	call   f0106693 <lapic_init>
	env_init_percpu();
f0100106:	e8 f9 33 00 00       	call   f0103504 <env_init_percpu>
	trap_init_percpu();
f010010b:	e8 68 3d 00 00       	call   f0103e78 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100110:	e8 63 65 00 00       	call   f0106678 <cpunum>
f0100115:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010011c:	29 c2                	sub    %eax,%edx
f010011e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100121:	8d 14 85 20 10 22 f0 	lea    -0xfddefe0(,%eax,4),%edx
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
f0100131:	c7 04 24 60 94 12 f0 	movl   $0xf0129460,(%esp)
f0100138:	e8 f2 67 00 00       	call   f010692f <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f010013d:	e8 e8 47 00 00       	call   f010492a <sched_yield>

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
f0100149:	b8 08 20 26 f0       	mov    $0xf0262008,%eax
f010014e:	2d af fe 21 f0       	sub    $0xf021feaf,%eax
f0100153:	50                   	push   %eax
f0100154:	6a 00                	push   $0x0
f0100156:	68 af fe 21 f0       	push   $0xf021feaf
f010015b:	e8 e9 5e 00 00       	call   f0106049 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100160:	e8 52 05 00 00       	call   f01006b7 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100165:	83 c4 08             	add    $0x8,%esp
f0100168:	68 ac 1a 00 00       	push   $0x1aac
f010016d:	68 cd 6d 10 f0       	push   $0xf0106dcd
f0100172:	e8 ea 3c 00 00       	call   f0103e61 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100177:	e8 e1 17 00 00       	call   f010195d <mem_init>

	// MSRs init:
	msrs_init();
f010017c:	e8 bf fe ff ff       	call   f0100040 <msrs_init>

    // Lab 3 user environment initialization functions
	env_init();
f0100181:	e8 a8 33 00 00       	call   f010352e <env_init>
    trap_init();
f0100186:	e8 f2 3d 00 00       	call   f0103f7d <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010018b:	e8 fe 61 00 00       	call   f010638e <mp_init>
	lapic_init();
f0100190:	e8 fe 64 00 00       	call   f0106693 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100195:	e8 28 3c 00 00       	call   f0103dc2 <pic_init>
f010019a:	c7 04 24 60 94 12 f0 	movl   $0xf0129460,(%esp)
f01001a1:	e8 89 67 00 00       	call   f010692f <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001a6:	83 c4 10             	add    $0x10,%esp
f01001a9:	83 3d 88 0e 22 f0 07 	cmpl   $0x7,0xf0220e88
f01001b0:	77 16                	ja     f01001c8 <i386_init+0x86>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001b2:	68 00 70 00 00       	push   $0x7000
f01001b7:	68 88 6d 10 f0       	push   $0xf0106d88
f01001bc:	6a 68                	push   $0x68
f01001be:	68 ab 6d 10 f0       	push   $0xf0106dab
f01001c3:	e8 a0 fe ff ff       	call   f0100068 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c8:	83 ec 04             	sub    $0x4,%esp
f01001cb:	b8 ca 62 10 f0       	mov    $0xf01062ca,%eax
f01001d0:	2d 50 62 10 f0       	sub    $0xf0106250,%eax
f01001d5:	50                   	push   %eax
f01001d6:	68 50 62 10 f0       	push   $0xf0106250
f01001db:	68 00 70 00 f0       	push   $0xf0007000
f01001e0:	e8 ae 5e 00 00       	call   f0106093 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001e5:	a1 c4 13 22 f0       	mov    0xf02213c4,%eax
f01001ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001f1:	29 c2                	sub    %eax,%edx
f01001f3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001f6:	8d 04 85 20 10 22 f0 	lea    -0xfddefe0(,%eax,4),%eax
f01001fd:	83 c4 10             	add    $0x10,%esp
f0100200:	3d 20 10 22 f0       	cmp    $0xf0221020,%eax
f0100205:	0f 86 95 00 00 00    	jbe    f01002a0 <i386_init+0x15e>
f010020b:	bb 20 10 22 f0       	mov    $0xf0221020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100210:	e8 63 64 00 00       	call   f0106678 <cpunum>
f0100215:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010021c:	29 c2                	sub    %eax,%edx
f010021e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100221:	8d 04 85 20 10 22 f0 	lea    -0xfddefe0(,%eax,4),%eax
f0100228:	39 c3                	cmp    %eax,%ebx
f010022a:	74 51                	je     f010027d <i386_init+0x13b>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010022c:	89 d8                	mov    %ebx,%eax
f010022e:	2d 20 10 22 f0       	sub    $0xf0221020,%eax
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
f0100257:	05 00 20 22 f0       	add    $0xf0222000,%eax
f010025c:	a3 84 0e 22 f0       	mov    %eax,0xf0220e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100261:	83 ec 08             	sub    $0x8,%esp
f0100264:	68 00 70 00 00       	push   $0x7000
f0100269:	0f b6 03             	movzbl (%ebx),%eax
f010026c:	50                   	push   %eax
f010026d:	e8 7d 65 00 00       	call   f01067ef <lapic_startap>
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
f0100280:	a1 c4 13 22 f0       	mov    0xf02213c4,%eax
f0100285:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010028c:	29 c2                	sub    %eax,%edx
f010028e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100291:	8d 04 85 20 10 22 f0 	lea    -0xfddefe0(,%eax,4),%eax
f0100298:	39 c3                	cmp    %eax,%ebx
f010029a:	0f 82 70 ff ff ff    	jb     f0100210 <i386_init+0xce>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01002a0:	83 ec 04             	sub    $0x4,%esp
f01002a3:	6a 01                	push   $0x1
f01002a5:	68 5b a3 01 00       	push   $0x1a35b
f01002aa:	68 6b ca 1c f0       	push   $0xf01cca6b
f01002af:	e8 7c 35 00 00       	call   f0103830 <env_create>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// ENV_CREATE(user_spawnhello, ENV_TYPE_USER);
	ENV_CREATE(user_thread_t2, ENV_TYPE_USER);
f01002b4:	83 c4 0c             	add    $0xc,%esp
f01002b7:	6a 00                	push   $0x0
f01002b9:	68 43 50 00 00       	push   $0x5043
f01002be:	68 29 5e 21 f0       	push   $0xf0215e29
f01002c3:	e8 68 35 00 00       	call   f0103830 <env_create>
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01002c8:	e8 91 03 00 00       	call   f010065e <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01002cd:	e8 58 46 00 00       	call   f010492a <sched_yield>

f01002d2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002d2:	55                   	push   %ebp
f01002d3:	89 e5                	mov    %esp,%ebp
f01002d5:	53                   	push   %ebx
f01002d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01002d9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002dc:	ff 75 0c             	pushl  0xc(%ebp)
f01002df:	ff 75 08             	pushl  0x8(%ebp)
f01002e2:	68 e8 6d 10 f0       	push   $0xf0106de8
f01002e7:	e8 75 3b 00 00       	call   f0103e61 <cprintf>
	vcprintf(fmt, ap);
f01002ec:	83 c4 08             	add    $0x8,%esp
f01002ef:	53                   	push   %ebx
f01002f0:	ff 75 10             	pushl  0x10(%ebp)
f01002f3:	e8 43 3b 00 00       	call   f0103e3b <vcprintf>
	cprintf("\n");
f01002f8:	c7 04 24 af 70 10 f0 	movl   $0xf01070af,(%esp)
f01002ff:	e8 5d 3b 00 00       	call   f0103e61 <cprintf>
	va_end(ap);
f0100304:	83 c4 10             	add    $0x10,%esp
}
f0100307:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010030a:	c9                   	leave  
f010030b:	c3                   	ret    

f010030c <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f010030c:	55                   	push   %ebp
f010030d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010030f:	ba 84 00 00 00       	mov    $0x84,%edx
f0100314:	ec                   	in     (%dx),%al
f0100315:	ec                   	in     (%dx),%al
f0100316:	ec                   	in     (%dx),%al
f0100317:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100318:	c9                   	leave  
f0100319:	c3                   	ret    

f010031a <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010031a:	55                   	push   %ebp
f010031b:	89 e5                	mov    %esp,%ebp
f010031d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100322:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100323:	a8 01                	test   $0x1,%al
f0100325:	74 08                	je     f010032f <serial_proc_data+0x15>
f0100327:	b2 f8                	mov    $0xf8,%dl
f0100329:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010032a:	0f b6 c0             	movzbl %al,%eax
f010032d:	eb 05                	jmp    f0100334 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010032f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100334:	c9                   	leave  
f0100335:	c3                   	ret    

f0100336 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100336:	55                   	push   %ebp
f0100337:	89 e5                	mov    %esp,%ebp
f0100339:	53                   	push   %ebx
f010033a:	83 ec 04             	sub    $0x4,%esp
f010033d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010033f:	eb 29                	jmp    f010036a <cons_intr+0x34>
		if (c == 0)
f0100341:	85 c0                	test   %eax,%eax
f0100343:	74 25                	je     f010036a <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100345:	8b 15 24 02 22 f0    	mov    0xf0220224,%edx
f010034b:	88 82 20 00 22 f0    	mov    %al,-0xfddffe0(%edx)
f0100351:	8d 42 01             	lea    0x1(%edx),%eax
f0100354:	a3 24 02 22 f0       	mov    %eax,0xf0220224
		if (cons.wpos == CONSBUFSIZE)
f0100359:	3d 00 02 00 00       	cmp    $0x200,%eax
f010035e:	75 0a                	jne    f010036a <cons_intr+0x34>
			cons.wpos = 0;
f0100360:	c7 05 24 02 22 f0 00 	movl   $0x0,0xf0220224
f0100367:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010036a:	ff d3                	call   *%ebx
f010036c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010036f:	75 d0                	jne    f0100341 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100371:	83 c4 04             	add    $0x4,%esp
f0100374:	5b                   	pop    %ebx
f0100375:	c9                   	leave  
f0100376:	c3                   	ret    

f0100377 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100377:	55                   	push   %ebp
f0100378:	89 e5                	mov    %esp,%ebp
f010037a:	57                   	push   %edi
f010037b:	56                   	push   %esi
f010037c:	53                   	push   %ebx
f010037d:	83 ec 0c             	sub    $0xc,%esp
f0100380:	89 c6                	mov    %eax,%esi
f0100382:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100387:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100388:	a8 20                	test   $0x20,%al
f010038a:	75 19                	jne    f01003a5 <cons_putc+0x2e>
f010038c:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100391:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100396:	e8 71 ff ff ff       	call   f010030c <delay>
f010039b:	89 fa                	mov    %edi,%edx
f010039d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010039e:	a8 20                	test   $0x20,%al
f01003a0:	75 03                	jne    f01003a5 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003a2:	4b                   	dec    %ebx
f01003a3:	75 f1                	jne    f0100396 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01003a5:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003ac:	89 f0                	mov    %esi,%eax
f01003ae:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003af:	b2 79                	mov    $0x79,%dl
f01003b1:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003b2:	84 c0                	test   %al,%al
f01003b4:	78 1d                	js     f01003d3 <cons_putc+0x5c>
f01003b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f01003bb:	e8 4c ff ff ff       	call   f010030c <delay>
f01003c0:	ba 79 03 00 00       	mov    $0x379,%edx
f01003c5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003c6:	84 c0                	test   %al,%al
f01003c8:	78 09                	js     f01003d3 <cons_putc+0x5c>
f01003ca:	43                   	inc    %ebx
f01003cb:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01003d1:	75 e8                	jne    f01003bb <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d3:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d8:	89 f8                	mov    %edi,%eax
f01003da:	ee                   	out    %al,(%dx)
f01003db:	b2 7a                	mov    $0x7a,%dl
f01003dd:	b0 0d                	mov    $0xd,%al
f01003df:	ee                   	out    %al,(%dx)
f01003e0:	b0 08                	mov    $0x8,%al
f01003e2:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
    // set user_setcolor
    c |= (user_setcolor << 8);
f01003e3:	a1 00 00 22 f0       	mov    0xf0220000,%eax
f01003e8:	c1 e0 08             	shl    $0x8,%eax
f01003eb:	09 c6                	or     %eax,%esi

	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003ed:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f01003f3:	75 06                	jne    f01003fb <cons_putc+0x84>
		c |= 0x0700;
f01003f5:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f01003fb:	89 f0                	mov    %esi,%eax
f01003fd:	25 ff 00 00 00       	and    $0xff,%eax
f0100402:	83 f8 09             	cmp    $0x9,%eax
f0100405:	74 78                	je     f010047f <cons_putc+0x108>
f0100407:	83 f8 09             	cmp    $0x9,%eax
f010040a:	7f 0b                	jg     f0100417 <cons_putc+0xa0>
f010040c:	83 f8 08             	cmp    $0x8,%eax
f010040f:	0f 85 9e 00 00 00    	jne    f01004b3 <cons_putc+0x13c>
f0100415:	eb 10                	jmp    f0100427 <cons_putc+0xb0>
f0100417:	83 f8 0a             	cmp    $0xa,%eax
f010041a:	74 39                	je     f0100455 <cons_putc+0xde>
f010041c:	83 f8 0d             	cmp    $0xd,%eax
f010041f:	0f 85 8e 00 00 00    	jne    f01004b3 <cons_putc+0x13c>
f0100425:	eb 36                	jmp    f010045d <cons_putc+0xe6>
	case '\b':
		if (crt_pos > 0) {
f0100427:	66 a1 04 00 22 f0    	mov    0xf0220004,%ax
f010042d:	66 85 c0             	test   %ax,%ax
f0100430:	0f 84 e0 00 00 00    	je     f0100516 <cons_putc+0x19f>
			crt_pos--;
f0100436:	48                   	dec    %eax
f0100437:	66 a3 04 00 22 f0    	mov    %ax,0xf0220004
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010043d:	0f b7 c0             	movzwl %ax,%eax
f0100440:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100446:	83 ce 20             	or     $0x20,%esi
f0100449:	8b 15 08 00 22 f0    	mov    0xf0220008,%edx
f010044f:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100453:	eb 78                	jmp    f01004cd <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100455:	66 83 05 04 00 22 f0 	addw   $0x50,0xf0220004
f010045c:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010045d:	66 8b 0d 04 00 22 f0 	mov    0xf0220004,%cx
f0100464:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100469:	89 c8                	mov    %ecx,%eax
f010046b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100470:	66 f7 f3             	div    %bx
f0100473:	66 29 d1             	sub    %dx,%cx
f0100476:	66 89 0d 04 00 22 f0 	mov    %cx,0xf0220004
f010047d:	eb 4e                	jmp    f01004cd <cons_putc+0x156>
		break;
	case '\t':
		cons_putc(' ');
f010047f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100484:	e8 ee fe ff ff       	call   f0100377 <cons_putc>
		cons_putc(' ');
f0100489:	b8 20 00 00 00       	mov    $0x20,%eax
f010048e:	e8 e4 fe ff ff       	call   f0100377 <cons_putc>
		cons_putc(' ');
f0100493:	b8 20 00 00 00       	mov    $0x20,%eax
f0100498:	e8 da fe ff ff       	call   f0100377 <cons_putc>
		cons_putc(' ');
f010049d:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a2:	e8 d0 fe ff ff       	call   f0100377 <cons_putc>
		cons_putc(' ');
f01004a7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ac:	e8 c6 fe ff ff       	call   f0100377 <cons_putc>
f01004b1:	eb 1a                	jmp    f01004cd <cons_putc+0x156>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01004b3:	66 a1 04 00 22 f0    	mov    0xf0220004,%ax
f01004b9:	0f b7 c8             	movzwl %ax,%ecx
f01004bc:	8b 15 08 00 22 f0    	mov    0xf0220008,%edx
f01004c2:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01004c6:	40                   	inc    %eax
f01004c7:	66 a3 04 00 22 f0    	mov    %ax,0xf0220004
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f01004cd:	66 81 3d 04 00 22 f0 	cmpw   $0x7cf,0xf0220004
f01004d4:	cf 07 
f01004d6:	76 3e                	jbe    f0100516 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004d8:	a1 08 00 22 f0       	mov    0xf0220008,%eax
f01004dd:	83 ec 04             	sub    $0x4,%esp
f01004e0:	68 00 0f 00 00       	push   $0xf00
f01004e5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004eb:	52                   	push   %edx
f01004ec:	50                   	push   %eax
f01004ed:	e8 a1 5b 00 00       	call   f0106093 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004f2:	8b 15 08 00 22 f0    	mov    0xf0220008,%edx
f01004f8:	83 c4 10             	add    $0x10,%esp
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004fb:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100500:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100506:	40                   	inc    %eax
f0100507:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010050c:	75 f2                	jne    f0100500 <cons_putc+0x189>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010050e:	66 83 2d 04 00 22 f0 	subw   $0x50,0xf0220004
f0100515:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100516:	8b 0d 0c 00 22 f0    	mov    0xf022000c,%ecx
f010051c:	b0 0e                	mov    $0xe,%al
f010051e:	89 ca                	mov    %ecx,%edx
f0100520:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100521:	66 8b 35 04 00 22 f0 	mov    0xf0220004,%si
f0100528:	8d 59 01             	lea    0x1(%ecx),%ebx
f010052b:	89 f0                	mov    %esi,%eax
f010052d:	66 c1 e8 08          	shr    $0x8,%ax
f0100531:	89 da                	mov    %ebx,%edx
f0100533:	ee                   	out    %al,(%dx)
f0100534:	b0 0f                	mov    $0xf,%al
f0100536:	89 ca                	mov    %ecx,%edx
f0100538:	ee                   	out    %al,(%dx)
f0100539:	89 f0                	mov    %esi,%eax
f010053b:	89 da                	mov    %ebx,%edx
f010053d:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010053e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100541:	5b                   	pop    %ebx
f0100542:	5e                   	pop    %esi
f0100543:	5f                   	pop    %edi
f0100544:	c9                   	leave  
f0100545:	c3                   	ret    

f0100546 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100546:	55                   	push   %ebp
f0100547:	89 e5                	mov    %esp,%ebp
f0100549:	53                   	push   %ebx
f010054a:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010054d:	ba 64 00 00 00       	mov    $0x64,%edx
f0100552:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100553:	a8 01                	test   $0x1,%al
f0100555:	0f 84 dc 00 00 00    	je     f0100637 <kbd_proc_data+0xf1>
f010055b:	b2 60                	mov    $0x60,%dl
f010055d:	ec                   	in     (%dx),%al
f010055e:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100560:	3c e0                	cmp    $0xe0,%al
f0100562:	75 11                	jne    f0100575 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100564:	83 0d 28 02 22 f0 40 	orl    $0x40,0xf0220228
		return 0;
f010056b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100570:	e9 c7 00 00 00       	jmp    f010063c <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f0100575:	84 c0                	test   %al,%al
f0100577:	79 33                	jns    f01005ac <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100579:	8b 0d 28 02 22 f0    	mov    0xf0220228,%ecx
f010057f:	f6 c1 40             	test   $0x40,%cl
f0100582:	75 05                	jne    f0100589 <kbd_proc_data+0x43>
f0100584:	88 c2                	mov    %al,%dl
f0100586:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100589:	0f b6 d2             	movzbl %dl,%edx
f010058c:	8a 82 40 6e 10 f0    	mov    -0xfef91c0(%edx),%al
f0100592:	83 c8 40             	or     $0x40,%eax
f0100595:	0f b6 c0             	movzbl %al,%eax
f0100598:	f7 d0                	not    %eax
f010059a:	21 c1                	and    %eax,%ecx
f010059c:	89 0d 28 02 22 f0    	mov    %ecx,0xf0220228
		return 0;
f01005a2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005a7:	e9 90 00 00 00       	jmp    f010063c <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f01005ac:	8b 0d 28 02 22 f0    	mov    0xf0220228,%ecx
f01005b2:	f6 c1 40             	test   $0x40,%cl
f01005b5:	74 0e                	je     f01005c5 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01005b7:	88 c2                	mov    %al,%dl
f01005b9:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01005bc:	83 e1 bf             	and    $0xffffffbf,%ecx
f01005bf:	89 0d 28 02 22 f0    	mov    %ecx,0xf0220228
	}

	shift |= shiftcode[data];
f01005c5:	0f b6 d2             	movzbl %dl,%edx
f01005c8:	0f b6 82 40 6e 10 f0 	movzbl -0xfef91c0(%edx),%eax
f01005cf:	0b 05 28 02 22 f0    	or     0xf0220228,%eax
	shift ^= togglecode[data];
f01005d5:	0f b6 8a 40 6f 10 f0 	movzbl -0xfef90c0(%edx),%ecx
f01005dc:	31 c8                	xor    %ecx,%eax
f01005de:	a3 28 02 22 f0       	mov    %eax,0xf0220228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005e3:	89 c1                	mov    %eax,%ecx
f01005e5:	83 e1 03             	and    $0x3,%ecx
f01005e8:	8b 0c 8d 40 70 10 f0 	mov    -0xfef8fc0(,%ecx,4),%ecx
f01005ef:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005f3:	a8 08                	test   $0x8,%al
f01005f5:	74 18                	je     f010060f <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f01005f7:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005fa:	83 fa 19             	cmp    $0x19,%edx
f01005fd:	77 05                	ja     f0100604 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f01005ff:	83 eb 20             	sub    $0x20,%ebx
f0100602:	eb 0b                	jmp    f010060f <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100604:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100607:	83 fa 19             	cmp    $0x19,%edx
f010060a:	77 03                	ja     f010060f <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f010060c:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010060f:	f7 d0                	not    %eax
f0100611:	a8 06                	test   $0x6,%al
f0100613:	75 27                	jne    f010063c <kbd_proc_data+0xf6>
f0100615:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010061b:	75 1f                	jne    f010063c <kbd_proc_data+0xf6>
		cprintf("Rebooting!\n");
f010061d:	83 ec 0c             	sub    $0xc,%esp
f0100620:	68 02 6e 10 f0       	push   $0xf0106e02
f0100625:	e8 37 38 00 00       	call   f0103e61 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010062a:	ba 92 00 00 00       	mov    $0x92,%edx
f010062f:	b0 03                	mov    $0x3,%al
f0100631:	ee                   	out    %al,(%dx)
f0100632:	83 c4 10             	add    $0x10,%esp
f0100635:	eb 05                	jmp    f010063c <kbd_proc_data+0xf6>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100637:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010063c:	89 d8                	mov    %ebx,%eax
f010063e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100641:	c9                   	leave  
f0100642:	c3                   	ret    

f0100643 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100643:	55                   	push   %ebp
f0100644:	89 e5                	mov    %esp,%ebp
f0100646:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100649:	80 3d 10 00 22 f0 00 	cmpb   $0x0,0xf0220010
f0100650:	74 0a                	je     f010065c <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100652:	b8 1a 03 10 f0       	mov    $0xf010031a,%eax
f0100657:	e8 da fc ff ff       	call   f0100336 <cons_intr>
}
f010065c:	c9                   	leave  
f010065d:	c3                   	ret    

f010065e <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010065e:	55                   	push   %ebp
f010065f:	89 e5                	mov    %esp,%ebp
f0100661:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100664:	b8 46 05 10 f0       	mov    $0xf0100546,%eax
f0100669:	e8 c8 fc ff ff       	call   f0100336 <cons_intr>
}
f010066e:	c9                   	leave  
f010066f:	c3                   	ret    

f0100670 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100670:	55                   	push   %ebp
f0100671:	89 e5                	mov    %esp,%ebp
f0100673:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100676:	e8 c8 ff ff ff       	call   f0100643 <serial_intr>
	kbd_intr();
f010067b:	e8 de ff ff ff       	call   f010065e <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100680:	8b 15 20 02 22 f0    	mov    0xf0220220,%edx
f0100686:	3b 15 24 02 22 f0    	cmp    0xf0220224,%edx
f010068c:	74 22                	je     f01006b0 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010068e:	0f b6 82 20 00 22 f0 	movzbl -0xfddffe0(%edx),%eax
f0100695:	42                   	inc    %edx
f0100696:	89 15 20 02 22 f0    	mov    %edx,0xf0220220
		if (cons.rpos == CONSBUFSIZE)
f010069c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006a2:	75 11                	jne    f01006b5 <cons_getc+0x45>
			cons.rpos = 0;
f01006a4:	c7 05 20 02 22 f0 00 	movl   $0x0,0xf0220220
f01006ab:	00 00 00 
f01006ae:	eb 05                	jmp    f01006b5 <cons_getc+0x45>
		return c;
	}
	return 0;
f01006b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01006b5:	c9                   	leave  
f01006b6:	c3                   	ret    

f01006b7 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006b7:	55                   	push   %ebp
f01006b8:	89 e5                	mov    %esp,%ebp
f01006ba:	57                   	push   %edi
f01006bb:	56                   	push   %esi
f01006bc:	53                   	push   %ebx
f01006bd:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006c0:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01006c7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006ce:	5a a5 
	if (*cp != 0xA55A) {
f01006d0:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01006d6:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006da:	74 11                	je     f01006ed <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006dc:	c7 05 0c 00 22 f0 b4 	movl   $0x3b4,0xf022000c
f01006e3:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006e6:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006eb:	eb 16                	jmp    f0100703 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006ed:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006f4:	c7 05 0c 00 22 f0 d4 	movl   $0x3d4,0xf022000c
f01006fb:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006fe:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100703:	8b 0d 0c 00 22 f0    	mov    0xf022000c,%ecx
f0100709:	b0 0e                	mov    $0xe,%al
f010070b:	89 ca                	mov    %ecx,%edx
f010070d:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010070e:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100711:	89 da                	mov    %ebx,%edx
f0100713:	ec                   	in     (%dx),%al
f0100714:	0f b6 f8             	movzbl %al,%edi
f0100717:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010071a:	b0 0f                	mov    $0xf,%al
f010071c:	89 ca                	mov    %ecx,%edx
f010071e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010071f:	89 da                	mov    %ebx,%edx
f0100721:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100722:	89 35 08 00 22 f0    	mov    %esi,0xf0220008

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100728:	0f b6 d8             	movzbl %al,%ebx
f010072b:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010072d:	66 89 3d 04 00 22 f0 	mov    %di,0xf0220004

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100734:	e8 25 ff ff ff       	call   f010065e <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100739:	83 ec 0c             	sub    $0xc,%esp
f010073c:	0f b7 05 90 93 12 f0 	movzwl 0xf0129390,%eax
f0100743:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100748:	50                   	push   %eax
f0100749:	e8 fa 35 00 00       	call   f0103d48 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010074e:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100753:	b0 00                	mov    $0x0,%al
f0100755:	89 da                	mov    %ebx,%edx
f0100757:	ee                   	out    %al,(%dx)
f0100758:	b2 fb                	mov    $0xfb,%dl
f010075a:	b0 80                	mov    $0x80,%al
f010075c:	ee                   	out    %al,(%dx)
f010075d:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100762:	b0 0c                	mov    $0xc,%al
f0100764:	89 ca                	mov    %ecx,%edx
f0100766:	ee                   	out    %al,(%dx)
f0100767:	b2 f9                	mov    $0xf9,%dl
f0100769:	b0 00                	mov    $0x0,%al
f010076b:	ee                   	out    %al,(%dx)
f010076c:	b2 fb                	mov    $0xfb,%dl
f010076e:	b0 03                	mov    $0x3,%al
f0100770:	ee                   	out    %al,(%dx)
f0100771:	b2 fc                	mov    $0xfc,%dl
f0100773:	b0 00                	mov    $0x0,%al
f0100775:	ee                   	out    %al,(%dx)
f0100776:	b2 f9                	mov    $0xf9,%dl
f0100778:	b0 01                	mov    $0x1,%al
f010077a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010077b:	b2 fd                	mov    $0xfd,%dl
f010077d:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010077e:	83 c4 10             	add    $0x10,%esp
f0100781:	3c ff                	cmp    $0xff,%al
f0100783:	0f 95 45 e7          	setne  -0x19(%ebp)
f0100787:	8a 45 e7             	mov    -0x19(%ebp),%al
f010078a:	a2 10 00 22 f0       	mov    %al,0xf0220010
f010078f:	89 da                	mov    %ebx,%edx
f0100791:	ec                   	in     (%dx),%al
f0100792:	89 ca                	mov    %ecx,%edx
f0100794:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100795:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100799:	74 21                	je     f01007bc <cons_init+0x105>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f010079b:	83 ec 0c             	sub    $0xc,%esp
f010079e:	0f b7 05 90 93 12 f0 	movzwl 0xf0129390,%eax
f01007a5:	25 ef ff 00 00       	and    $0xffef,%eax
f01007aa:	50                   	push   %eax
f01007ab:	e8 98 35 00 00       	call   f0103d48 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007b0:	83 c4 10             	add    $0x10,%esp
f01007b3:	80 3d 10 00 22 f0 00 	cmpb   $0x0,0xf0220010
f01007ba:	75 10                	jne    f01007cc <cons_init+0x115>
		cprintf("Serial port does not exist!\n");
f01007bc:	83 ec 0c             	sub    $0xc,%esp
f01007bf:	68 0e 6e 10 f0       	push   $0xf0106e0e
f01007c4:	e8 98 36 00 00       	call   f0103e61 <cprintf>
f01007c9:	83 c4 10             	add    $0x10,%esp
}
f01007cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007cf:	5b                   	pop    %ebx
f01007d0:	5e                   	pop    %esi
f01007d1:	5f                   	pop    %edi
f01007d2:	c9                   	leave  
f01007d3:	c3                   	ret    

f01007d4 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007d4:	55                   	push   %ebp
f01007d5:	89 e5                	mov    %esp,%ebp
f01007d7:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007da:	8b 45 08             	mov    0x8(%ebp),%eax
f01007dd:	e8 95 fb ff ff       	call   f0100377 <cons_putc>
}
f01007e2:	c9                   	leave  
f01007e3:	c3                   	ret    

f01007e4 <getchar>:

int
getchar(void)
{
f01007e4:	55                   	push   %ebp
f01007e5:	89 e5                	mov    %esp,%ebp
f01007e7:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007ea:	e8 81 fe ff ff       	call   f0100670 <cons_getc>
f01007ef:	85 c0                	test   %eax,%eax
f01007f1:	74 f7                	je     f01007ea <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007f3:	c9                   	leave  
f01007f4:	c3                   	ret    

f01007f5 <iscons>:

int
iscons(int fdnum)
{
f01007f5:	55                   	push   %ebp
f01007f6:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007f8:	b8 01 00 00 00       	mov    $0x1,%eax
f01007fd:	c9                   	leave  
f01007fe:	c3                   	ret    
	...

f0100800 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100800:	55                   	push   %ebp
f0100801:	89 e5                	mov    %esp,%ebp
f0100803:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100806:	68 50 70 10 f0       	push   $0xf0107050
f010080b:	e8 51 36 00 00       	call   f0103e61 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100810:	83 c4 08             	add    $0x8,%esp
f0100813:	68 0c 00 10 00       	push   $0x10000c
f0100818:	68 7c 72 10 f0       	push   $0xf010727c
f010081d:	e8 3f 36 00 00       	call   f0103e61 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100822:	83 c4 0c             	add    $0xc,%esp
f0100825:	68 0c 00 10 00       	push   $0x10000c
f010082a:	68 0c 00 10 f0       	push   $0xf010000c
f010082f:	68 a4 72 10 f0       	push   $0xf01072a4
f0100834:	e8 28 36 00 00       	call   f0103e61 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100839:	83 c4 0c             	add    $0xc,%esp
f010083c:	68 2c 6d 10 00       	push   $0x106d2c
f0100841:	68 2c 6d 10 f0       	push   $0xf0106d2c
f0100846:	68 c8 72 10 f0       	push   $0xf01072c8
f010084b:	e8 11 36 00 00       	call   f0103e61 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100850:	83 c4 0c             	add    $0xc,%esp
f0100853:	68 af fe 21 00       	push   $0x21feaf
f0100858:	68 af fe 21 f0       	push   $0xf021feaf
f010085d:	68 ec 72 10 f0       	push   $0xf01072ec
f0100862:	e8 fa 35 00 00       	call   f0103e61 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100867:	83 c4 0c             	add    $0xc,%esp
f010086a:	68 08 20 26 00       	push   $0x262008
f010086f:	68 08 20 26 f0       	push   $0xf0262008
f0100874:	68 10 73 10 f0       	push   $0xf0107310
f0100879:	e8 e3 35 00 00       	call   f0103e61 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010087e:	b8 07 24 26 f0       	mov    $0xf0262407,%eax
f0100883:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100888:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010088b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100890:	89 c2                	mov    %eax,%edx
f0100892:	85 c0                	test   %eax,%eax
f0100894:	79 06                	jns    f010089c <mon_kerninfo+0x9c>
f0100896:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010089c:	c1 fa 0a             	sar    $0xa,%edx
f010089f:	52                   	push   %edx
f01008a0:	68 34 73 10 f0       	push   $0xf0107334
f01008a5:	e8 b7 35 00 00       	call   f0103e61 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01008af:	c9                   	leave  
f01008b0:	c3                   	ret    

f01008b1 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01008b1:	55                   	push   %ebp
f01008b2:	89 e5                	mov    %esp,%ebp
f01008b4:	53                   	push   %ebx
f01008b5:	83 ec 04             	sub    $0x4,%esp
f01008b8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008bd:	83 ec 04             	sub    $0x4,%esp
f01008c0:	ff b3 c4 77 10 f0    	pushl  -0xfef883c(%ebx)
f01008c6:	ff b3 c0 77 10 f0    	pushl  -0xfef8840(%ebx)
f01008cc:	68 69 70 10 f0       	push   $0xf0107069
f01008d1:	e8 8b 35 00 00       	call   f0103e61 <cprintf>
f01008d6:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008d9:	83 c4 10             	add    $0x10,%esp
f01008dc:	83 fb 6c             	cmp    $0x6c,%ebx
f01008df:	75 dc                	jne    f01008bd <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01008e9:	c9                   	leave  
f01008ea:	c3                   	ret    

f01008eb <mon_si>:
    return 0;
}

int 
mon_si(int argc, char **argv, struct Trapframe *tf)
{
f01008eb:	55                   	push   %ebp
f01008ec:	89 e5                	mov    %esp,%ebp
f01008ee:	83 ec 08             	sub    $0x8,%esp
f01008f1:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f01008f4:	85 c0                	test   %eax,%eax
f01008f6:	75 14                	jne    f010090c <mon_si+0x21>
        cprintf("Error: you only can use si in breakpoint.\n");
f01008f8:	83 ec 0c             	sub    $0xc,%esp
f01008fb:	68 60 73 10 f0       	push   $0xf0107360
f0100900:	e8 5c 35 00 00       	call   f0103e61 <cprintf>

    cprintf("tfno: %u\n", tf->tf_trapno);
    env_run(curenv);
    panic("mon_si : env_run return");
    return 0;
}
f0100905:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010090a:	c9                   	leave  
f010090b:	c3                   	ret    
        cprintf("Error: you only can use si in breakpoint.\n");
        return -1;
    }

    // next step also cause debug interrupt
    tf->tf_eflags |= FL_TF;
f010090c:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)

    cprintf("tfno: %u\n", tf->tf_trapno);
f0100913:	83 ec 08             	sub    $0x8,%esp
f0100916:	ff 70 28             	pushl  0x28(%eax)
f0100919:	68 72 70 10 f0       	push   $0xf0107072
f010091e:	e8 3e 35 00 00       	call   f0103e61 <cprintf>
    env_run(curenv);
f0100923:	e8 50 5d 00 00       	call   f0106678 <cpunum>
f0100928:	83 c4 04             	add    $0x4,%esp
f010092b:	6b c0 74             	imul   $0x74,%eax,%eax
f010092e:	ff b0 28 10 22 f0    	pushl  -0xfddefd8(%eax)
f0100934:	e8 c4 32 00 00       	call   f0103bfd <env_run>

f0100939 <mon_continue>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

int 
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
f0100939:	55                   	push   %ebp
f010093a:	89 e5                	mov    %esp,%ebp
f010093c:	83 ec 08             	sub    $0x8,%esp
f010093f:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f0100942:	85 c0                	test   %eax,%eax
f0100944:	75 14                	jne    f010095a <mon_continue+0x21>
        cprintf("Error: you only can use continue in breakpoint.\n");
f0100946:	83 ec 0c             	sub    $0xc,%esp
f0100949:	68 8c 73 10 f0       	push   $0xf010738c
f010094e:	e8 0e 35 00 00       	call   f0103e61 <cprintf>
    }
    tf->tf_eflags &= (~FL_TF);
    env_run(curenv);    // usually it won't return;
    panic("mon_continue : env_run return");
    return 0;
}
f0100953:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100958:	c9                   	leave  
f0100959:	c3                   	ret    
{
    if (tf == NULL) {
        cprintf("Error: you only can use continue in breakpoint.\n");
        return -1;
    }
    tf->tf_eflags &= (~FL_TF);
f010095a:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
    env_run(curenv);    // usually it won't return;
f0100961:	e8 12 5d 00 00       	call   f0106678 <cpunum>
f0100966:	83 ec 0c             	sub    $0xc,%esp
f0100969:	6b c0 74             	imul   $0x74,%eax,%eax
f010096c:	ff b0 28 10 22 f0    	pushl  -0xfddefd8(%eax)
f0100972:	e8 86 32 00 00       	call   f0103bfd <env_run>

f0100977 <mon_showmappings>:
    return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100977:	55                   	push   %ebp
f0100978:	89 e5                	mov    %esp,%ebp
f010097a:	57                   	push   %edi
f010097b:	56                   	push   %esi
f010097c:	53                   	push   %ebx
f010097d:	83 ec 0c             	sub    $0xc,%esp
f0100980:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 3) {
f0100983:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100987:	74 21                	je     f01009aa <mon_showmappings+0x33>
        cprintf("Command should be: showmappings [addr1] [addr2]\n");
f0100989:	83 ec 0c             	sub    $0xc,%esp
f010098c:	68 c0 73 10 f0       	push   $0xf01073c0
f0100991:	e8 cb 34 00 00       	call   f0103e61 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f0100996:	c7 04 24 f4 73 10 f0 	movl   $0xf01073f4,(%esp)
f010099d:	e8 bf 34 00 00       	call   f0103e61 <cprintf>
f01009a2:	83 c4 10             	add    $0x10,%esp
f01009a5:	e9 1a 01 00 00       	jmp    f0100ac4 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f01009aa:	83 ec 04             	sub    $0x4,%esp
f01009ad:	6a 00                	push   $0x0
f01009af:	6a 00                	push   $0x0
f01009b1:	ff 76 04             	pushl  0x4(%esi)
f01009b4:	e8 c9 57 00 00       	call   f0106182 <strtol>
f01009b9:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f01009bb:	83 c4 0c             	add    $0xc,%esp
f01009be:	6a 00                	push   $0x0
f01009c0:	6a 00                	push   $0x0
f01009c2:	ff 76 08             	pushl  0x8(%esi)
f01009c5:	e8 b8 57 00 00       	call   f0106182 <strtol>
        if (laddr > haddr) {
f01009ca:	83 c4 10             	add    $0x10,%esp
f01009cd:	39 c3                	cmp    %eax,%ebx
f01009cf:	76 01                	jbe    f01009d2 <mon_showmappings+0x5b>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f01009d1:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, PGSIZE);
f01009d2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        haddr = ROUNDUP(haddr, PGSIZE);
f01009d8:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01009de:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
f01009e4:	83 ec 04             	sub    $0x4,%esp
f01009e7:	57                   	push   %edi
f01009e8:	53                   	push   %ebx
f01009e9:	68 7c 70 10 f0       	push   $0xf010707c
f01009ee:	e8 6e 34 00 00       	call   f0103e61 <cprintf>
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f01009f3:	83 c4 10             	add    $0x10,%esp
f01009f6:	39 fb                	cmp    %edi,%ebx
f01009f8:	75 07                	jne    f0100a01 <mon_showmappings+0x8a>
f01009fa:	e9 c5 00 00 00       	jmp    f0100ac4 <mon_showmappings+0x14d>
f01009ff:	89 f3                	mov    %esi,%ebx
            cprintf("[ 0x%08x, 0x%08x ) -> ", now, now + PGSIZE); 
f0100a01:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
f0100a07:	83 ec 04             	sub    $0x4,%esp
f0100a0a:	56                   	push   %esi
f0100a0b:	53                   	push   %ebx
f0100a0c:	68 8d 70 10 f0       	push   $0xf010708d
f0100a11:	e8 4b 34 00 00       	call   f0103e61 <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f0100a16:	83 c4 0c             	add    $0xc,%esp
f0100a19:	6a 00                	push   $0x0
f0100a1b:	53                   	push   %ebx
f0100a1c:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0100a22:	e8 a2 0c 00 00       	call   f01016c9 <pgdir_walk>
f0100a27:	89 c3                	mov    %eax,%ebx
            if (pte == 0 || (*pte & PTE_P) == 0) {
f0100a29:	83 c4 10             	add    $0x10,%esp
f0100a2c:	85 c0                	test   %eax,%eax
f0100a2e:	74 06                	je     f0100a36 <mon_showmappings+0xbf>
f0100a30:	8b 00                	mov    (%eax),%eax
f0100a32:	a8 01                	test   $0x1,%al
f0100a34:	75 12                	jne    f0100a48 <mon_showmappings+0xd1>
                cprintf(" no mapped \n");
f0100a36:	83 ec 0c             	sub    $0xc,%esp
f0100a39:	68 a4 70 10 f0       	push   $0xf01070a4
f0100a3e:	e8 1e 34 00 00       	call   f0103e61 <cprintf>
f0100a43:	83 c4 10             	add    $0x10,%esp
f0100a46:	eb 74                	jmp    f0100abc <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f0100a48:	83 ec 08             	sub    $0x8,%esp
f0100a4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a50:	50                   	push   %eax
f0100a51:	68 b1 70 10 f0       	push   $0xf01070b1
f0100a56:	e8 06 34 00 00       	call   f0103e61 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f0100a5b:	83 c4 10             	add    $0x10,%esp
f0100a5e:	f6 03 04             	testb  $0x4,(%ebx)
f0100a61:	74 12                	je     f0100a75 <mon_showmappings+0xfe>
f0100a63:	83 ec 0c             	sub    $0xc,%esp
f0100a66:	68 b9 70 10 f0       	push   $0xf01070b9
f0100a6b:	e8 f1 33 00 00       	call   f0103e61 <cprintf>
f0100a70:	83 c4 10             	add    $0x10,%esp
f0100a73:	eb 10                	jmp    f0100a85 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f0100a75:	83 ec 0c             	sub    $0xc,%esp
f0100a78:	68 c6 70 10 f0       	push   $0xf01070c6
f0100a7d:	e8 df 33 00 00       	call   f0103e61 <cprintf>
f0100a82:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f0100a85:	f6 03 02             	testb  $0x2,(%ebx)
f0100a88:	74 12                	je     f0100a9c <mon_showmappings+0x125>
f0100a8a:	83 ec 0c             	sub    $0xc,%esp
f0100a8d:	68 d3 70 10 f0       	push   $0xf01070d3
f0100a92:	e8 ca 33 00 00       	call   f0103e61 <cprintf>
f0100a97:	83 c4 10             	add    $0x10,%esp
f0100a9a:	eb 10                	jmp    f0100aac <mon_showmappings+0x135>
                else cprintf(" R ");
f0100a9c:	83 ec 0c             	sub    $0xc,%esp
f0100a9f:	68 d8 70 10 f0       	push   $0xf01070d8
f0100aa4:	e8 b8 33 00 00       	call   f0103e61 <cprintf>
f0100aa9:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f0100aac:	83 ec 0c             	sub    $0xc,%esp
f0100aaf:	68 af 70 10 f0       	push   $0xf01070af
f0100ab4:	e8 a8 33 00 00       	call   f0103e61 <cprintf>
f0100ab9:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDUP(haddr, PGSIZE);
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f0100abc:	39 f7                	cmp    %esi,%edi
f0100abe:	0f 85 3b ff ff ff    	jne    f01009ff <mon_showmappings+0x88>
                cprintf("\n");
            }
        }
    }
    return 0;
}
f0100ac4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ac9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100acc:	5b                   	pop    %ebx
f0100acd:	5e                   	pop    %esi
f0100ace:	5f                   	pop    %edi
f0100acf:	c9                   	leave  
f0100ad0:	c3                   	ret    

f0100ad1 <mon_setpermission>:
    return 0;
}

int
mon_setpermission(int argc, char **argv, struct Trapframe *tf)
{
f0100ad1:	55                   	push   %ebp
f0100ad2:	89 e5                	mov    %esp,%ebp
f0100ad4:	57                   	push   %edi
f0100ad5:	56                   	push   %esi
f0100ad6:	53                   	push   %ebx
f0100ad7:	83 ec 0c             	sub    $0xc,%esp
f0100ada:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 5) { 
f0100add:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f0100ae1:	74 21                	je     f0100b04 <mon_setpermission+0x33>
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
f0100ae3:	83 ec 0c             	sub    $0xc,%esp
f0100ae6:	68 1c 74 10 f0       	push   $0xf010741c
f0100aeb:	e8 71 33 00 00       	call   f0103e61 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f0100af0:	c7 04 24 6c 74 10 f0 	movl   $0xf010746c,(%esp)
f0100af7:	e8 65 33 00 00       	call   f0103e61 <cprintf>
f0100afc:	83 c4 10             	add    $0x10,%esp
f0100aff:	e9 a5 01 00 00       	jmp    f0100ca9 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f0100b04:	83 ec 04             	sub    $0x4,%esp
f0100b07:	6a 00                	push   $0x0
f0100b09:	6a 00                	push   $0x0
f0100b0b:	ff 73 04             	pushl  0x4(%ebx)
f0100b0e:	e8 6f 56 00 00       	call   f0106182 <strtol>
        uint32_t perm = 0;
        if (argv[2][0] == '1') perm |= PTE_W;
f0100b13:	8b 53 08             	mov    0x8(%ebx),%edx
f0100b16:	83 c4 10             	add    $0x10,%esp
    if (argc != 5) { 
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
        cprintf("Example: setpermissions 0x0 1 0 1\n");
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
        uint32_t perm = 0;
f0100b19:	80 3a 31             	cmpb   $0x31,(%edx)
f0100b1c:	0f 94 c2             	sete   %dl
f0100b1f:	0f b6 d2             	movzbl %dl,%edx
f0100b22:	89 d6                	mov    %edx,%esi
f0100b24:	d1 e6                	shl    %esi
        if (argv[2][0] == '1') perm |= PTE_W;
        if (argv[3][0] == '1') perm |= PTE_U;
f0100b26:	8b 53 0c             	mov    0xc(%ebx),%edx
f0100b29:	80 3a 31             	cmpb   $0x31,(%edx)
f0100b2c:	75 03                	jne    f0100b31 <mon_setpermission+0x60>
f0100b2e:	83 ce 04             	or     $0x4,%esi
        if (argv[4][0] == '1') perm |= PTE_P;
f0100b31:	8b 53 10             	mov    0x10(%ebx),%edx
f0100b34:	80 3a 31             	cmpb   $0x31,(%edx)
f0100b37:	75 03                	jne    f0100b3c <mon_setpermission+0x6b>
f0100b39:	83 ce 01             	or     $0x1,%esi
        addr = ROUNDUP(addr, PGSIZE);
f0100b3c:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f0100b42:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
f0100b48:	83 ec 04             	sub    $0x4,%esp
f0100b4b:	6a 00                	push   $0x0
f0100b4d:	57                   	push   %edi
f0100b4e:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0100b54:	e8 70 0b 00 00       	call   f01016c9 <pgdir_walk>
f0100b59:	89 c3                	mov    %eax,%ebx
        if (pte != NULL) {
f0100b5b:	83 c4 10             	add    $0x10,%esp
f0100b5e:	85 c0                	test   %eax,%eax
f0100b60:	0f 84 33 01 00 00    	je     f0100c99 <mon_setpermission+0x1c8>
            cprintf("0x%08x -> pa: 0x%08x\n old_perm: ", addr, PTE_ADDR(*pte));
f0100b66:	83 ec 04             	sub    $0x4,%esp
f0100b69:	8b 00                	mov    (%eax),%eax
f0100b6b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b70:	50                   	push   %eax
f0100b71:	57                   	push   %edi
f0100b72:	68 90 74 10 f0       	push   $0xf0107490
f0100b77:	e8 e5 32 00 00       	call   f0103e61 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100b7c:	83 c4 10             	add    $0x10,%esp
f0100b7f:	f6 03 02             	testb  $0x2,(%ebx)
f0100b82:	74 12                	je     f0100b96 <mon_setpermission+0xc5>
f0100b84:	83 ec 0c             	sub    $0xc,%esp
f0100b87:	68 dc 70 10 f0       	push   $0xf01070dc
f0100b8c:	e8 d0 32 00 00       	call   f0103e61 <cprintf>
f0100b91:	83 c4 10             	add    $0x10,%esp
f0100b94:	eb 10                	jmp    f0100ba6 <mon_setpermission+0xd5>
f0100b96:	83 ec 0c             	sub    $0xc,%esp
f0100b99:	68 df 70 10 f0       	push   $0xf01070df
f0100b9e:	e8 be 32 00 00       	call   f0103e61 <cprintf>
f0100ba3:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100ba6:	f6 03 04             	testb  $0x4,(%ebx)
f0100ba9:	74 12                	je     f0100bbd <mon_setpermission+0xec>
f0100bab:	83 ec 0c             	sub    $0xc,%esp
f0100bae:	68 23 83 10 f0       	push   $0xf0108323
f0100bb3:	e8 a9 32 00 00       	call   f0103e61 <cprintf>
f0100bb8:	83 c4 10             	add    $0x10,%esp
f0100bbb:	eb 10                	jmp    f0100bcd <mon_setpermission+0xfc>
f0100bbd:	83 ec 0c             	sub    $0xc,%esp
f0100bc0:	68 28 87 10 f0       	push   $0xf0108728
f0100bc5:	e8 97 32 00 00       	call   f0103e61 <cprintf>
f0100bca:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100bcd:	f6 03 01             	testb  $0x1,(%ebx)
f0100bd0:	74 12                	je     f0100be4 <mon_setpermission+0x113>
f0100bd2:	83 ec 0c             	sub    $0xc,%esp
f0100bd5:	68 b5 8d 10 f0       	push   $0xf0108db5
f0100bda:	e8 82 32 00 00       	call   f0103e61 <cprintf>
f0100bdf:	83 c4 10             	add    $0x10,%esp
f0100be2:	eb 10                	jmp    f0100bf4 <mon_setpermission+0x123>
f0100be4:	83 ec 0c             	sub    $0xc,%esp
f0100be7:	68 e0 70 10 f0       	push   $0xf01070e0
f0100bec:	e8 70 32 00 00       	call   f0103e61 <cprintf>
f0100bf1:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f0100bf4:	83 ec 0c             	sub    $0xc,%esp
f0100bf7:	68 e2 70 10 f0       	push   $0xf01070e2
f0100bfc:	e8 60 32 00 00       	call   f0103e61 <cprintf>
            *pte = PTE_ADDR(*pte) | perm;     
f0100c01:	8b 03                	mov    (%ebx),%eax
f0100c03:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c08:	09 c6                	or     %eax,%esi
f0100c0a:	89 33                	mov    %esi,(%ebx)
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100c0c:	83 c4 10             	add    $0x10,%esp
f0100c0f:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0100c15:	74 12                	je     f0100c29 <mon_setpermission+0x158>
f0100c17:	83 ec 0c             	sub    $0xc,%esp
f0100c1a:	68 dc 70 10 f0       	push   $0xf01070dc
f0100c1f:	e8 3d 32 00 00       	call   f0103e61 <cprintf>
f0100c24:	83 c4 10             	add    $0x10,%esp
f0100c27:	eb 10                	jmp    f0100c39 <mon_setpermission+0x168>
f0100c29:	83 ec 0c             	sub    $0xc,%esp
f0100c2c:	68 df 70 10 f0       	push   $0xf01070df
f0100c31:	e8 2b 32 00 00       	call   f0103e61 <cprintf>
f0100c36:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100c39:	f6 03 04             	testb  $0x4,(%ebx)
f0100c3c:	74 12                	je     f0100c50 <mon_setpermission+0x17f>
f0100c3e:	83 ec 0c             	sub    $0xc,%esp
f0100c41:	68 23 83 10 f0       	push   $0xf0108323
f0100c46:	e8 16 32 00 00       	call   f0103e61 <cprintf>
f0100c4b:	83 c4 10             	add    $0x10,%esp
f0100c4e:	eb 10                	jmp    f0100c60 <mon_setpermission+0x18f>
f0100c50:	83 ec 0c             	sub    $0xc,%esp
f0100c53:	68 28 87 10 f0       	push   $0xf0108728
f0100c58:	e8 04 32 00 00       	call   f0103e61 <cprintf>
f0100c5d:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100c60:	f6 03 01             	testb  $0x1,(%ebx)
f0100c63:	74 12                	je     f0100c77 <mon_setpermission+0x1a6>
f0100c65:	83 ec 0c             	sub    $0xc,%esp
f0100c68:	68 b5 8d 10 f0       	push   $0xf0108db5
f0100c6d:	e8 ef 31 00 00       	call   f0103e61 <cprintf>
f0100c72:	83 c4 10             	add    $0x10,%esp
f0100c75:	eb 10                	jmp    f0100c87 <mon_setpermission+0x1b6>
f0100c77:	83 ec 0c             	sub    $0xc,%esp
f0100c7a:	68 e0 70 10 f0       	push   $0xf01070e0
f0100c7f:	e8 dd 31 00 00       	call   f0103e61 <cprintf>
f0100c84:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100c87:	83 ec 0c             	sub    $0xc,%esp
f0100c8a:	68 af 70 10 f0       	push   $0xf01070af
f0100c8f:	e8 cd 31 00 00       	call   f0103e61 <cprintf>
f0100c94:	83 c4 10             	add    $0x10,%esp
f0100c97:	eb 10                	jmp    f0100ca9 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100c99:	83 ec 0c             	sub    $0xc,%esp
f0100c9c:	68 a4 70 10 f0       	push   $0xf01070a4
f0100ca1:	e8 bb 31 00 00       	call   f0103e61 <cprintf>
f0100ca6:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100ca9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cb1:	5b                   	pop    %ebx
f0100cb2:	5e                   	pop    %esi
f0100cb3:	5f                   	pop    %edi
f0100cb4:	c9                   	leave  
f0100cb5:	c3                   	ret    

f0100cb6 <mon_setcolor>:
    return 0;
}

int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f0100cb6:	55                   	push   %ebp
f0100cb7:	89 e5                	mov    %esp,%ebp
f0100cb9:	56                   	push   %esi
f0100cba:	53                   	push   %ebx
f0100cbb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f0100cbe:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100cc2:	74 66                	je     f0100d2a <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f0100cc4:	83 ec 0c             	sub    $0xc,%esp
f0100cc7:	68 b4 74 10 f0       	push   $0xf01074b4
f0100ccc:	e8 90 31 00 00       	call   f0103e61 <cprintf>
        cprintf("num show the color attribute. \n");
f0100cd1:	c7 04 24 e4 74 10 f0 	movl   $0xf01074e4,(%esp)
f0100cd8:	e8 84 31 00 00       	call   f0103e61 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100cdd:	c7 04 24 04 75 10 f0 	movl   $0xf0107504,(%esp)
f0100ce4:	e8 78 31 00 00       	call   f0103e61 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100ce9:	c7 04 24 38 75 10 f0 	movl   $0xf0107538,(%esp)
f0100cf0:	e8 6c 31 00 00       	call   f0103e61 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100cf5:	c7 04 24 7c 75 10 f0 	movl   $0xf010757c,(%esp)
f0100cfc:	e8 60 31 00 00       	call   f0103e61 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100d01:	c7 04 24 f3 70 10 f0 	movl   $0xf01070f3,(%esp)
f0100d08:	e8 54 31 00 00       	call   f0103e61 <cprintf>
        cprintf("         set the background color to black\n");
f0100d0d:	c7 04 24 c0 75 10 f0 	movl   $0xf01075c0,(%esp)
f0100d14:	e8 48 31 00 00       	call   f0103e61 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100d19:	c7 04 24 ec 75 10 f0 	movl   $0xf01075ec,(%esp)
f0100d20:	e8 3c 31 00 00       	call   f0103e61 <cprintf>
f0100d25:	83 c4 10             	add    $0x10,%esp
f0100d28:	eb 52                	jmp    f0100d7c <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100d2a:	83 ec 0c             	sub    $0xc,%esp
f0100d2d:	ff 73 04             	pushl  0x4(%ebx)
f0100d30:	e8 4b 51 00 00       	call   f0105e80 <strlen>
f0100d35:	83 c4 10             	add    $0x10,%esp
f0100d38:	48                   	dec    %eax
f0100d39:	78 26                	js     f0100d61 <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f0100d3b:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100d3e:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100d43:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f0100d48:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f0100d4c:	0f 94 c3             	sete   %bl
f0100d4f:	0f b6 db             	movzbl %bl,%ebx
f0100d52:	d3 e3                	shl    %cl,%ebx
f0100d54:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100d56:	48                   	dec    %eax
f0100d57:	78 0d                	js     f0100d66 <mon_setcolor+0xb0>
f0100d59:	41                   	inc    %ecx
f0100d5a:	83 f9 08             	cmp    $0x8,%ecx
f0100d5d:	75 e9                	jne    f0100d48 <mon_setcolor+0x92>
f0100d5f:	eb 05                	jmp    f0100d66 <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100d61:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f0100d66:	89 15 00 00 22 f0    	mov    %edx,0xf0220000
        cprintf(" This is color that you want ! \n");
f0100d6c:	83 ec 0c             	sub    $0xc,%esp
f0100d6f:	68 20 76 10 f0       	push   $0xf0107620
f0100d74:	e8 e8 30 00 00       	call   f0103e61 <cprintf>
f0100d79:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f0100d7c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d81:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100d84:	5b                   	pop    %ebx
f0100d85:	5e                   	pop    %esi
f0100d86:	c9                   	leave  
f0100d87:	c3                   	ret    

f0100d88 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f0100d88:	55                   	push   %ebp
f0100d89:	89 e5                	mov    %esp,%ebp
f0100d8b:	57                   	push   %edi
f0100d8c:	56                   	push   %esi
f0100d8d:	53                   	push   %ebx
f0100d8e:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100d91:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100d93:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100d95:	85 c0                	test   %eax,%eax
f0100d97:	74 6d                	je     f0100e06 <mon_backtrace+0x7e>
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100d99:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
f0100d9c:	8b 5e 04             	mov    0x4(%esi),%ebx
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100d9f:	ff 76 18             	pushl  0x18(%esi)
f0100da2:	ff 76 14             	pushl  0x14(%esi)
f0100da5:	ff 76 10             	pushl  0x10(%esi)
f0100da8:	ff 76 0c             	pushl  0xc(%esi)
f0100dab:	ff 76 08             	pushl  0x8(%esi)
f0100dae:	53                   	push   %ebx
f0100daf:	56                   	push   %esi
f0100db0:	68 44 76 10 f0       	push   $0xf0107644
f0100db5:	e8 a7 30 00 00       	call   f0103e61 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100dba:	83 c4 18             	add    $0x18,%esp
f0100dbd:	57                   	push   %edi
f0100dbe:	ff 76 04             	pushl  0x4(%esi)
f0100dc1:	e8 cb 47 00 00       	call   f0105591 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100dc6:	83 c4 0c             	add    $0xc,%esp
f0100dc9:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100dcc:	ff 75 d0             	pushl  -0x30(%ebp)
f0100dcf:	68 0f 71 10 f0       	push   $0xf010710f
f0100dd4:	e8 88 30 00 00       	call   f0103e61 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100dd9:	83 c4 0c             	add    $0xc,%esp
f0100ddc:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ddf:	ff 75 dc             	pushl  -0x24(%ebp)
f0100de2:	68 1f 71 10 f0       	push   $0xf010711f
f0100de7:	e8 75 30 00 00       	call   f0103e61 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100dec:	83 c4 08             	add    $0x8,%esp
f0100def:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100df2:	53                   	push   %ebx
f0100df3:	68 24 71 10 f0       	push   $0xf0107124
f0100df8:	e8 64 30 00 00       	call   f0103e61 <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100dfd:	8b 36                	mov    (%esi),%esi
f0100dff:	83 c4 10             	add    $0x10,%esp
f0100e02:	85 f6                	test   %esi,%esi
f0100e04:	75 96                	jne    f0100d9c <mon_backtrace+0x14>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100e06:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e0e:	5b                   	pop    %ebx
f0100e0f:	5e                   	pop    %esi
f0100e10:	5f                   	pop    %edi
f0100e11:	c9                   	leave  
f0100e12:	c3                   	ret    

f0100e13 <pa_con>:
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
f0100e13:	55                   	push   %ebp
f0100e14:	89 e5                	mov    %esp,%ebp
f0100e16:	53                   	push   %ebx
f0100e17:	83 ec 04             	sub    $0x4,%esp
f0100e1a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
f0100e20:	8b 15 90 0e 22 f0    	mov    0xf0220e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e26:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100e2c:	77 15                	ja     f0100e43 <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e2e:	52                   	push   %edx
f0100e2f:	68 64 6d 10 f0       	push   $0xf0106d64
f0100e34:	68 96 00 00 00       	push   $0x96
f0100e39:	68 29 71 10 f0       	push   $0xf0107129
f0100e3e:	e8 25 f2 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100e43:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100e49:	39 d0                	cmp    %edx,%eax
f0100e4b:	72 18                	jb     f0100e65 <pa_con+0x52>
f0100e4d:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
f0100e53:	39 d8                	cmp    %ebx,%eax
f0100e55:	73 0e                	jae    f0100e65 <pa_con+0x52>
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
f0100e57:	29 d0                	sub    %edx,%eax
f0100e59:	8b 80 00 00 00 ef    	mov    -0x11000000(%eax),%eax
f0100e5f:	89 01                	mov    %eax,(%ecx)
        return true;
f0100e61:	b0 01                	mov    $0x1,%al
f0100e63:	eb 56                	jmp    f0100ebb <pa_con+0xa8>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e65:	ba 00 f0 11 f0       	mov    $0xf011f000,%edx
f0100e6a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100e70:	77 15                	ja     f0100e87 <pa_con+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e72:	52                   	push   %edx
f0100e73:	68 64 6d 10 f0       	push   $0xf0106d64
f0100e78:	68 9b 00 00 00       	push   $0x9b
f0100e7d:	68 29 71 10 f0       	push   $0xf0107129
f0100e82:	e8 e1 f1 ff ff       	call   f0100068 <_panic>
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
f0100e87:	3d 00 f0 11 00       	cmp    $0x11f000,%eax
f0100e8c:	72 18                	jb     f0100ea6 <pa_con+0x93>
f0100e8e:	3d 00 70 12 00       	cmp    $0x127000,%eax
f0100e93:	73 11                	jae    f0100ea6 <pa_con+0x93>
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
f0100e95:	2d 00 f0 11 00       	sub    $0x11f000,%eax
f0100e9a:	8b 80 00 80 ff ef    	mov    -0x10008000(%eax),%eax
f0100ea0:	89 01                	mov    %eax,(%ecx)
        return true;
f0100ea2:	b0 01                	mov    $0x1,%al
f0100ea4:	eb 15                	jmp    f0100ebb <pa_con+0xa8>
    }
    if (addr < -KERNBASE) {
f0100ea6:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100eab:	77 0c                	ja     f0100eb9 <pa_con+0xa6>
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
f0100ead:	8b 80 00 00 00 f0    	mov    -0x10000000(%eax),%eax
f0100eb3:	89 01                	mov    %eax,(%ecx)
        return true;
f0100eb5:	b0 01                	mov    $0x1,%al
f0100eb7:	eb 02                	jmp    f0100ebb <pa_con+0xa8>
    }
    // Not in virtual memory mapped.
    return false;
f0100eb9:	b0 00                	mov    $0x0,%al
}
f0100ebb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ebe:	c9                   	leave  
f0100ebf:	c3                   	ret    

f0100ec0 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
f0100ec0:	55                   	push   %ebp
f0100ec1:	89 e5                	mov    %esp,%ebp
f0100ec3:	57                   	push   %edi
f0100ec4:	56                   	push   %esi
f0100ec5:	53                   	push   %ebx
f0100ec6:	83 ec 2c             	sub    $0x2c,%esp
f0100ec9:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 4) {
f0100ecc:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100ed0:	74 2d                	je     f0100eff <mon_dump+0x3f>
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
f0100ed2:	83 ec 0c             	sub    $0xc,%esp
f0100ed5:	68 7c 76 10 f0       	push   $0xf010767c
f0100eda:	e8 82 2f 00 00       	call   f0103e61 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100edf:	c7 04 24 ac 76 10 f0 	movl   $0xf01076ac,(%esp)
f0100ee6:	e8 76 2f 00 00       	call   f0103e61 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100eeb:	c7 04 24 d4 76 10 f0 	movl   $0xf01076d4,(%esp)
f0100ef2:	e8 6a 2f 00 00       	call   f0103e61 <cprintf>
f0100ef7:	83 c4 10             	add    $0x10,%esp
f0100efa:	e9 59 01 00 00       	jmp    f0101058 <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100eff:	83 ec 04             	sub    $0x4,%esp
f0100f02:	6a 00                	push   $0x0
f0100f04:	6a 00                	push   $0x0
f0100f06:	ff 76 08             	pushl  0x8(%esi)
f0100f09:	e8 74 52 00 00       	call   f0106182 <strtol>
f0100f0e:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100f10:	83 c4 0c             	add    $0xc,%esp
f0100f13:	6a 00                	push   $0x0
f0100f15:	6a 00                	push   $0x0
f0100f17:	ff 76 0c             	pushl  0xc(%esi)
f0100f1a:	e8 63 52 00 00       	call   f0106182 <strtol>
        if (laddr > haddr) {
f0100f1f:	83 c4 10             	add    $0x10,%esp
f0100f22:	39 c3                	cmp    %eax,%ebx
f0100f24:	76 01                	jbe    f0100f27 <mon_dump+0x67>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100f26:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, 4);
f0100f27:	89 df                	mov    %ebx,%edi
f0100f29:	83 e7 fc             	and    $0xfffffffc,%edi
        haddr = ROUNDDOWN(haddr, 4);
f0100f2c:	83 e0 fc             	and    $0xfffffffc,%eax
f0100f2f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if (argv[1][0] == 'v') {
f0100f32:	8b 46 04             	mov    0x4(%esi),%eax
f0100f35:	80 38 76             	cmpb   $0x76,(%eax)
f0100f38:	74 0e                	je     f0100f48 <mon_dump+0x88>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100f3a:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100f3d:	0f 85 98 00 00 00    	jne    f0100fdb <mon_dump+0x11b>
f0100f43:	e9 00 01 00 00       	jmp    f0101048 <mon_dump+0x188>
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100f48:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100f4b:	74 7c                	je     f0100fc9 <mon_dump+0x109>
f0100f4d:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100f4f:	39 fb                	cmp    %edi,%ebx
f0100f51:	74 15                	je     f0100f68 <mon_dump+0xa8>
f0100f53:	f6 c3 0f             	test   $0xf,%bl
f0100f56:	75 21                	jne    f0100f79 <mon_dump+0xb9>
                    if (now != laddr) cprintf("\n"); 
f0100f58:	83 ec 0c             	sub    $0xc,%esp
f0100f5b:	68 af 70 10 f0       	push   $0xf01070af
f0100f60:	e8 fc 2e 00 00       	call   f0103e61 <cprintf>
f0100f65:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100f68:	83 ec 08             	sub    $0x8,%esp
f0100f6b:	53                   	push   %ebx
f0100f6c:	68 38 71 10 f0       	push   $0xf0107138
f0100f71:	e8 eb 2e 00 00       	call   f0103e61 <cprintf>
f0100f76:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100f79:	83 ec 04             	sub    $0x4,%esp
f0100f7c:	6a 00                	push   $0x0
f0100f7e:	89 d8                	mov    %ebx,%eax
f0100f80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f85:	50                   	push   %eax
f0100f86:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0100f8c:	e8 38 07 00 00       	call   f01016c9 <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100f91:	83 c4 10             	add    $0x10,%esp
f0100f94:	85 c0                	test   %eax,%eax
f0100f96:	74 19                	je     f0100fb1 <mon_dump+0xf1>
f0100f98:	f6 00 01             	testb  $0x1,(%eax)
f0100f9b:	74 14                	je     f0100fb1 <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100f9d:	83 ec 08             	sub    $0x8,%esp
f0100fa0:	ff 33                	pushl  (%ebx)
f0100fa2:	68 42 71 10 f0       	push   $0xf0107142
f0100fa7:	e8 b5 2e 00 00       	call   f0103e61 <cprintf>
f0100fac:	83 c4 10             	add    $0x10,%esp
f0100faf:	eb 10                	jmp    f0100fc1 <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100fb1:	83 ec 0c             	sub    $0xc,%esp
f0100fb4:	68 4d 71 10 f0       	push   $0xf010714d
f0100fb9:	e8 a3 2e 00 00       	call   f0103e61 <cprintf>
f0100fbe:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100fc1:	83 c3 04             	add    $0x4,%ebx
f0100fc4:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100fc7:	75 86                	jne    f0100f4f <mon_dump+0x8f>
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
f0100fc9:	83 ec 0c             	sub    $0xc,%esp
f0100fcc:	68 af 70 10 f0       	push   $0xf01070af
f0100fd1:	e8 8b 2e 00 00       	call   f0103e61 <cprintf>
f0100fd6:	83 c4 10             	add    $0x10,%esp
f0100fd9:	eb 7d                	jmp    f0101058 <mon_dump+0x198>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100fdb:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100fdd:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100fe0:	39 fb                	cmp    %edi,%ebx
f0100fe2:	74 15                	je     f0100ff9 <mon_dump+0x139>
f0100fe4:	f6 c3 0f             	test   $0xf,%bl
f0100fe7:	75 21                	jne    f010100a <mon_dump+0x14a>
                    if (now != laddr) cprintf("\n");
f0100fe9:	83 ec 0c             	sub    $0xc,%esp
f0100fec:	68 af 70 10 f0       	push   $0xf01070af
f0100ff1:	e8 6b 2e 00 00       	call   f0103e61 <cprintf>
f0100ff6:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100ff9:	83 ec 08             	sub    $0x8,%esp
f0100ffc:	53                   	push   %ebx
f0100ffd:	68 38 71 10 f0       	push   $0xf0107138
f0101002:	e8 5a 2e 00 00       	call   f0103e61 <cprintf>
f0101007:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f010100a:	83 ec 08             	sub    $0x8,%esp
f010100d:	56                   	push   %esi
f010100e:	53                   	push   %ebx
f010100f:	e8 ff fd ff ff       	call   f0100e13 <pa_con>
f0101014:	83 c4 10             	add    $0x10,%esp
f0101017:	84 c0                	test   %al,%al
f0101019:	74 15                	je     f0101030 <mon_dump+0x170>
                    cprintf("0x%08x  ", value);
f010101b:	83 ec 08             	sub    $0x8,%esp
f010101e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101021:	68 42 71 10 f0       	push   $0xf0107142
f0101026:	e8 36 2e 00 00       	call   f0103e61 <cprintf>
f010102b:	83 c4 10             	add    $0x10,%esp
f010102e:	eb 10                	jmp    f0101040 <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0101030:	83 ec 0c             	sub    $0xc,%esp
f0101033:	68 4b 71 10 f0       	push   $0xf010714b
f0101038:	e8 24 2e 00 00       	call   f0103e61 <cprintf>
f010103d:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0101040:	83 c3 04             	add    $0x4,%ebx
f0101043:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101046:	75 98                	jne    f0100fe0 <mon_dump+0x120>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f0101048:	83 ec 0c             	sub    $0xc,%esp
f010104b:	68 af 70 10 f0       	push   $0xf01070af
f0101050:	e8 0c 2e 00 00       	call   f0103e61 <cprintf>
f0101055:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0101058:	b8 00 00 00 00       	mov    $0x0,%eax
f010105d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101060:	5b                   	pop    %ebx
f0101061:	5e                   	pop    %esi
f0101062:	5f                   	pop    %edi
f0101063:	c9                   	leave  
f0101064:	c3                   	ret    

f0101065 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0101065:	55                   	push   %ebp
f0101066:	89 e5                	mov    %esp,%ebp
f0101068:	57                   	push   %edi
f0101069:	56                   	push   %esi
f010106a:	53                   	push   %ebx
f010106b:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010106e:	68 18 77 10 f0       	push   $0xf0107718
f0101073:	e8 e9 2d 00 00       	call   f0103e61 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101078:	c7 04 24 3c 77 10 f0 	movl   $0xf010773c,(%esp)
f010107f:	e8 dd 2d 00 00       	call   f0103e61 <cprintf>

	if (tf != NULL)
f0101084:	83 c4 10             	add    $0x10,%esp
f0101087:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010108b:	74 0e                	je     f010109b <monitor+0x36>
		print_trapframe(tf);
f010108d:	83 ec 0c             	sub    $0xc,%esp
f0101090:	ff 75 08             	pushl  0x8(%ebp)
f0101093:	e8 29 31 00 00       	call   f01041c1 <print_trapframe>
f0101098:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010109b:	83 ec 0c             	sub    $0xc,%esp
f010109e:	68 58 71 10 f0       	push   $0xf0107158
f01010a3:	e8 f8 4c 00 00       	call   f0105da0 <readline>
f01010a8:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01010aa:	83 c4 10             	add    $0x10,%esp
f01010ad:	85 c0                	test   %eax,%eax
f01010af:	74 ea                	je     f010109b <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01010b1:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01010b8:	be 00 00 00 00       	mov    $0x0,%esi
f01010bd:	eb 04                	jmp    f01010c3 <monitor+0x5e>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01010bf:	c6 03 00             	movb   $0x0,(%ebx)
f01010c2:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01010c3:	8a 03                	mov    (%ebx),%al
f01010c5:	84 c0                	test   %al,%al
f01010c7:	74 64                	je     f010112d <monitor+0xc8>
f01010c9:	83 ec 08             	sub    $0x8,%esp
f01010cc:	0f be c0             	movsbl %al,%eax
f01010cf:	50                   	push   %eax
f01010d0:	68 5c 71 10 f0       	push   $0xf010715c
f01010d5:	e8 1f 4f 00 00       	call   f0105ff9 <strchr>
f01010da:	83 c4 10             	add    $0x10,%esp
f01010dd:	85 c0                	test   %eax,%eax
f01010df:	75 de                	jne    f01010bf <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01010e1:	80 3b 00             	cmpb   $0x0,(%ebx)
f01010e4:	74 47                	je     f010112d <monitor+0xc8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01010e6:	83 fe 0f             	cmp    $0xf,%esi
f01010e9:	75 14                	jne    f01010ff <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01010eb:	83 ec 08             	sub    $0x8,%esp
f01010ee:	6a 10                	push   $0x10
f01010f0:	68 61 71 10 f0       	push   $0xf0107161
f01010f5:	e8 67 2d 00 00       	call   f0103e61 <cprintf>
f01010fa:	83 c4 10             	add    $0x10,%esp
f01010fd:	eb 9c                	jmp    f010109b <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01010ff:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0101103:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0101104:	8a 03                	mov    (%ebx),%al
f0101106:	84 c0                	test   %al,%al
f0101108:	75 09                	jne    f0101113 <monitor+0xae>
f010110a:	eb b7                	jmp    f01010c3 <monitor+0x5e>
			buf++;
f010110c:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010110d:	8a 03                	mov    (%ebx),%al
f010110f:	84 c0                	test   %al,%al
f0101111:	74 b0                	je     f01010c3 <monitor+0x5e>
f0101113:	83 ec 08             	sub    $0x8,%esp
f0101116:	0f be c0             	movsbl %al,%eax
f0101119:	50                   	push   %eax
f010111a:	68 5c 71 10 f0       	push   $0xf010715c
f010111f:	e8 d5 4e 00 00       	call   f0105ff9 <strchr>
f0101124:	83 c4 10             	add    $0x10,%esp
f0101127:	85 c0                	test   %eax,%eax
f0101129:	74 e1                	je     f010110c <monitor+0xa7>
f010112b:	eb 96                	jmp    f01010c3 <monitor+0x5e>
			buf++;
	}
	argv[argc] = 0;
f010112d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0101134:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0101135:	85 f6                	test   %esi,%esi
f0101137:	0f 84 5e ff ff ff    	je     f010109b <monitor+0x36>
f010113d:	bb c0 77 10 f0       	mov    $0xf01077c0,%ebx
f0101142:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101147:	83 ec 08             	sub    $0x8,%esp
f010114a:	ff 33                	pushl  (%ebx)
f010114c:	ff 75 a8             	pushl  -0x58(%ebp)
f010114f:	e8 37 4e 00 00       	call   f0105f8b <strcmp>
f0101154:	83 c4 10             	add    $0x10,%esp
f0101157:	85 c0                	test   %eax,%eax
f0101159:	75 20                	jne    f010117b <monitor+0x116>
			return commands[i].func(argc, argv, tf);
f010115b:	83 ec 04             	sub    $0x4,%esp
f010115e:	6b ff 0c             	imul   $0xc,%edi,%edi
f0101161:	ff 75 08             	pushl  0x8(%ebp)
f0101164:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0101167:	50                   	push   %eax
f0101168:	56                   	push   %esi
f0101169:	ff 97 c8 77 10 f0    	call   *-0xfef8838(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010116f:	83 c4 10             	add    $0x10,%esp
f0101172:	85 c0                	test   %eax,%eax
f0101174:	78 26                	js     f010119c <monitor+0x137>
f0101176:	e9 20 ff ff ff       	jmp    f010109b <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010117b:	47                   	inc    %edi
f010117c:	83 c3 0c             	add    $0xc,%ebx
f010117f:	83 ff 09             	cmp    $0x9,%edi
f0101182:	75 c3                	jne    f0101147 <monitor+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0101184:	83 ec 08             	sub    $0x8,%esp
f0101187:	ff 75 a8             	pushl  -0x58(%ebp)
f010118a:	68 7e 71 10 f0       	push   $0xf010717e
f010118f:	e8 cd 2c 00 00       	call   f0103e61 <cprintf>
f0101194:	83 c4 10             	add    $0x10,%esp
f0101197:	e9 ff fe ff ff       	jmp    f010109b <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010119c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010119f:	5b                   	pop    %ebx
f01011a0:	5e                   	pop    %esi
f01011a1:	5f                   	pop    %edi
f01011a2:	c9                   	leave  
f01011a3:	c3                   	ret    

f01011a4 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01011a4:	55                   	push   %ebp
f01011a5:	89 e5                	mov    %esp,%ebp
f01011a7:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01011a9:	83 3d 34 02 22 f0 00 	cmpl   $0x0,0xf0220234
f01011b0:	75 0f                	jne    f01011c1 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01011b2:	b8 07 30 26 f0       	mov    $0xf0263007,%eax
f01011b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011bc:	a3 34 02 22 f0       	mov    %eax,0xf0220234
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f01011c1:	a1 34 02 22 f0       	mov    0xf0220234,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f01011c6:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f01011cd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01011d3:	89 15 34 02 22 f0    	mov    %edx,0xf0220234

	return result;
}
f01011d9:	c9                   	leave  
f01011da:	c3                   	ret    

f01011db <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01011db:	55                   	push   %ebp
f01011dc:	89 e5                	mov    %esp,%ebp
f01011de:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01011e1:	89 d1                	mov    %edx,%ecx
f01011e3:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01011e6:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01011e9:	a8 01                	test   $0x1,%al
f01011eb:	74 42                	je     f010122f <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01011ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011f2:	89 c1                	mov    %eax,%ecx
f01011f4:	c1 e9 0c             	shr    $0xc,%ecx
f01011f7:	3b 0d 88 0e 22 f0    	cmp    0xf0220e88,%ecx
f01011fd:	72 15                	jb     f0101214 <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011ff:	50                   	push   %eax
f0101200:	68 88 6d 10 f0       	push   $0xf0106d88
f0101205:	68 79 03 00 00       	push   $0x379
f010120a:	68 f1 80 10 f0       	push   $0xf01080f1
f010120f:	e8 54 ee ff ff       	call   f0100068 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101214:	c1 ea 0c             	shr    $0xc,%edx
f0101217:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010121d:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101224:	a8 01                	test   $0x1,%al
f0101226:	74 0e                	je     f0101236 <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101228:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010122d:	eb 0c                	jmp    f010123b <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f010122f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101234:	eb 05                	jmp    f010123b <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0101236:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f010123b:	c9                   	leave  
f010123c:	c3                   	ret    

f010123d <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f010123d:	55                   	push   %ebp
f010123e:	89 e5                	mov    %esp,%ebp
f0101240:	56                   	push   %esi
f0101241:	53                   	push   %ebx
f0101242:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101244:	83 ec 0c             	sub    $0xc,%esp
f0101247:	50                   	push   %eax
f0101248:	e8 d3 2a 00 00       	call   f0103d20 <mc146818_read>
f010124d:	89 c6                	mov    %eax,%esi
f010124f:	43                   	inc    %ebx
f0101250:	89 1c 24             	mov    %ebx,(%esp)
f0101253:	e8 c8 2a 00 00       	call   f0103d20 <mc146818_read>
f0101258:	c1 e0 08             	shl    $0x8,%eax
f010125b:	09 f0                	or     %esi,%eax
}
f010125d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101260:	5b                   	pop    %ebx
f0101261:	5e                   	pop    %esi
f0101262:	c9                   	leave  
f0101263:	c3                   	ret    

f0101264 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101264:	55                   	push   %ebp
f0101265:	89 e5                	mov    %esp,%ebp
f0101267:	57                   	push   %edi
f0101268:	56                   	push   %esi
f0101269:	53                   	push   %ebx
f010126a:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010126d:	3c 01                	cmp    $0x1,%al
f010126f:	19 f6                	sbb    %esi,%esi
f0101271:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101277:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101278:	8b 1d 30 02 22 f0    	mov    0xf0220230,%ebx
f010127e:	85 db                	test   %ebx,%ebx
f0101280:	75 17                	jne    f0101299 <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f0101282:	83 ec 04             	sub    $0x4,%esp
f0101285:	68 2c 78 10 f0       	push   $0xf010782c
f010128a:	68 ae 02 00 00       	push   $0x2ae
f010128f:	68 f1 80 10 f0       	push   $0xf01080f1
f0101294:	e8 cf ed ff ff       	call   f0100068 <_panic>

	if (only_low_memory) {
f0101299:	84 c0                	test   %al,%al
f010129b:	74 50                	je     f01012ed <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010129d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01012a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012a3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01012a6:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012a9:	89 d8                	mov    %ebx,%eax
f01012ab:	2b 05 90 0e 22 f0    	sub    0xf0220e90,%eax
f01012b1:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01012b4:	c1 e8 16             	shr    $0x16,%eax
f01012b7:	39 c6                	cmp    %eax,%esi
f01012b9:	0f 96 c0             	setbe  %al
f01012bc:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f01012bf:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f01012c3:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f01012c5:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012c9:	8b 1b                	mov    (%ebx),%ebx
f01012cb:	85 db                	test   %ebx,%ebx
f01012cd:	75 da                	jne    f01012a9 <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01012cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01012d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01012d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01012db:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01012de:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01012e0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01012e3:	89 1d 30 02 22 f0    	mov    %ebx,0xf0220230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01012e9:	85 db                	test   %ebx,%ebx
f01012eb:	74 57                	je     f0101344 <check_page_free_list+0xe0>
f01012ed:	89 d8                	mov    %ebx,%eax
f01012ef:	2b 05 90 0e 22 f0    	sub    0xf0220e90,%eax
f01012f5:	c1 f8 03             	sar    $0x3,%eax
f01012f8:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01012fb:	89 c2                	mov    %eax,%edx
f01012fd:	c1 ea 16             	shr    $0x16,%edx
f0101300:	39 d6                	cmp    %edx,%esi
f0101302:	76 3a                	jbe    f010133e <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101304:	89 c2                	mov    %eax,%edx
f0101306:	c1 ea 0c             	shr    $0xc,%edx
f0101309:	3b 15 88 0e 22 f0    	cmp    0xf0220e88,%edx
f010130f:	72 12                	jb     f0101323 <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101311:	50                   	push   %eax
f0101312:	68 88 6d 10 f0       	push   $0xf0106d88
f0101317:	6a 58                	push   $0x58
f0101319:	68 fd 80 10 f0       	push   $0xf01080fd
f010131e:	e8 45 ed ff ff       	call   f0100068 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101323:	83 ec 04             	sub    $0x4,%esp
f0101326:	68 80 00 00 00       	push   $0x80
f010132b:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101330:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101335:	50                   	push   %eax
f0101336:	e8 0e 4d 00 00       	call   f0106049 <memset>
f010133b:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010133e:	8b 1b                	mov    (%ebx),%ebx
f0101340:	85 db                	test   %ebx,%ebx
f0101342:	75 a9                	jne    f01012ed <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101344:	b8 00 00 00 00       	mov    $0x0,%eax
f0101349:	e8 56 fe ff ff       	call   f01011a4 <boot_alloc>
f010134e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101351:	8b 15 30 02 22 f0    	mov    0xf0220230,%edx
f0101357:	85 d2                	test   %edx,%edx
f0101359:	0f 84 b2 01 00 00    	je     f0101511 <check_page_free_list+0x2ad>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010135f:	8b 1d 90 0e 22 f0    	mov    0xf0220e90,%ebx
f0101365:	39 da                	cmp    %ebx,%edx
f0101367:	72 4b                	jb     f01013b4 <check_page_free_list+0x150>
		assert(pp < pages + npages);
f0101369:	a1 88 0e 22 f0       	mov    0xf0220e88,%eax
f010136e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101371:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101374:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101377:	39 c2                	cmp    %eax,%edx
f0101379:	73 57                	jae    f01013d2 <check_page_free_list+0x16e>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010137b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f010137e:	89 d0                	mov    %edx,%eax
f0101380:	29 d8                	sub    %ebx,%eax
f0101382:	a8 07                	test   $0x7,%al
f0101384:	75 6e                	jne    f01013f4 <check_page_free_list+0x190>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101386:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101389:	c1 e0 0c             	shl    $0xc,%eax
f010138c:	0f 84 83 00 00 00    	je     f0101415 <check_page_free_list+0x1b1>
		assert(page2pa(pp) != IOPHYSMEM);
f0101392:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101397:	0f 84 98 00 00 00    	je     f0101435 <check_page_free_list+0x1d1>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f010139d:	be 00 00 00 00       	mov    $0x0,%esi
f01013a2:	bf 00 00 00 00       	mov    $0x0,%edi
f01013a7:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f01013aa:	e9 9f 00 00 00       	jmp    f010144e <check_page_free_list+0x1ea>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01013af:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f01013b2:	73 19                	jae    f01013cd <check_page_free_list+0x169>
f01013b4:	68 0b 81 10 f0       	push   $0xf010810b
f01013b9:	68 17 81 10 f0       	push   $0xf0108117
f01013be:	68 c8 02 00 00       	push   $0x2c8
f01013c3:	68 f1 80 10 f0       	push   $0xf01080f1
f01013c8:	e8 9b ec ff ff       	call   f0100068 <_panic>
		assert(pp < pages + npages);
f01013cd:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01013d0:	72 19                	jb     f01013eb <check_page_free_list+0x187>
f01013d2:	68 2c 81 10 f0       	push   $0xf010812c
f01013d7:	68 17 81 10 f0       	push   $0xf0108117
f01013dc:	68 c9 02 00 00       	push   $0x2c9
f01013e1:	68 f1 80 10 f0       	push   $0xf01080f1
f01013e6:	e8 7d ec ff ff       	call   f0100068 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01013eb:	89 d0                	mov    %edx,%eax
f01013ed:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01013f0:	a8 07                	test   $0x7,%al
f01013f2:	74 19                	je     f010140d <check_page_free_list+0x1a9>
f01013f4:	68 50 78 10 f0       	push   $0xf0107850
f01013f9:	68 17 81 10 f0       	push   $0xf0108117
f01013fe:	68 ca 02 00 00       	push   $0x2ca
f0101403:	68 f1 80 10 f0       	push   $0xf01080f1
f0101408:	e8 5b ec ff ff       	call   f0100068 <_panic>
f010140d:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101410:	c1 e0 0c             	shl    $0xc,%eax
f0101413:	75 19                	jne    f010142e <check_page_free_list+0x1ca>
f0101415:	68 40 81 10 f0       	push   $0xf0108140
f010141a:	68 17 81 10 f0       	push   $0xf0108117
f010141f:	68 cd 02 00 00       	push   $0x2cd
f0101424:	68 f1 80 10 f0       	push   $0xf01080f1
f0101429:	e8 3a ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010142e:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101433:	75 19                	jne    f010144e <check_page_free_list+0x1ea>
f0101435:	68 51 81 10 f0       	push   $0xf0108151
f010143a:	68 17 81 10 f0       	push   $0xf0108117
f010143f:	68 ce 02 00 00       	push   $0x2ce
f0101444:	68 f1 80 10 f0       	push   $0xf01080f1
f0101449:	e8 1a ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010144e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101453:	75 19                	jne    f010146e <check_page_free_list+0x20a>
f0101455:	68 84 78 10 f0       	push   $0xf0107884
f010145a:	68 17 81 10 f0       	push   $0xf0108117
f010145f:	68 cf 02 00 00       	push   $0x2cf
f0101464:	68 f1 80 10 f0       	push   $0xf01080f1
f0101469:	e8 fa eb ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010146e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101473:	75 19                	jne    f010148e <check_page_free_list+0x22a>
f0101475:	68 6a 81 10 f0       	push   $0xf010816a
f010147a:	68 17 81 10 f0       	push   $0xf0108117
f010147f:	68 d0 02 00 00       	push   $0x2d0
f0101484:	68 f1 80 10 f0       	push   $0xf01080f1
f0101489:	e8 da eb ff ff       	call   f0100068 <_panic>
f010148e:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101490:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101495:	76 40                	jbe    f01014d7 <check_page_free_list+0x273>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101497:	89 c3                	mov    %eax,%ebx
f0101499:	c1 eb 0c             	shr    $0xc,%ebx
f010149c:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f010149f:	77 12                	ja     f01014b3 <check_page_free_list+0x24f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014a1:	50                   	push   %eax
f01014a2:	68 88 6d 10 f0       	push   $0xf0106d88
f01014a7:	6a 58                	push   $0x58
f01014a9:	68 fd 80 10 f0       	push   $0xf01080fd
f01014ae:	e8 b5 eb ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f01014b3:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01014b9:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01014bc:	76 19                	jbe    f01014d7 <check_page_free_list+0x273>
f01014be:	68 a8 78 10 f0       	push   $0xf01078a8
f01014c3:	68 17 81 10 f0       	push   $0xf0108117
f01014c8:	68 d1 02 00 00       	push   $0x2d1
f01014cd:	68 f1 80 10 f0       	push   $0xf01080f1
f01014d2:	e8 91 eb ff ff       	call   f0100068 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01014d7:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01014dc:	75 19                	jne    f01014f7 <check_page_free_list+0x293>
f01014de:	68 84 81 10 f0       	push   $0xf0108184
f01014e3:	68 17 81 10 f0       	push   $0xf0108117
f01014e8:	68 d3 02 00 00       	push   $0x2d3
f01014ed:	68 f1 80 10 f0       	push   $0xf01080f1
f01014f2:	e8 71 eb ff ff       	call   f0100068 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f01014f7:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f01014fd:	77 03                	ja     f0101502 <check_page_free_list+0x29e>
			++nfree_basemem;
f01014ff:	47                   	inc    %edi
f0101500:	eb 01                	jmp    f0101503 <check_page_free_list+0x29f>
		else
			++nfree_extmem;
f0101502:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101503:	8b 12                	mov    (%edx),%edx
f0101505:	85 d2                	test   %edx,%edx
f0101507:	0f 85 a2 fe ff ff    	jne    f01013af <check_page_free_list+0x14b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010150d:	85 ff                	test   %edi,%edi
f010150f:	7f 19                	jg     f010152a <check_page_free_list+0x2c6>
f0101511:	68 a1 81 10 f0       	push   $0xf01081a1
f0101516:	68 17 81 10 f0       	push   $0xf0108117
f010151b:	68 db 02 00 00       	push   $0x2db
f0101520:	68 f1 80 10 f0       	push   $0xf01080f1
f0101525:	e8 3e eb ff ff       	call   f0100068 <_panic>
	assert(nfree_extmem > 0);
f010152a:	85 f6                	test   %esi,%esi
f010152c:	7f 19                	jg     f0101547 <check_page_free_list+0x2e3>
f010152e:	68 b3 81 10 f0       	push   $0xf01081b3
f0101533:	68 17 81 10 f0       	push   $0xf0108117
f0101538:	68 dc 02 00 00       	push   $0x2dc
f010153d:	68 f1 80 10 f0       	push   $0xf01080f1
f0101542:	e8 21 eb ff ff       	call   f0100068 <_panic>
}
f0101547:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010154a:	5b                   	pop    %ebx
f010154b:	5e                   	pop    %esi
f010154c:	5f                   	pop    %edi
f010154d:	c9                   	leave  
f010154e:	c3                   	ret    

f010154f <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010154f:	55                   	push   %ebp
f0101550:	89 e5                	mov    %esp,%ebp
f0101552:	56                   	push   %esi
f0101553:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f0101554:	c7 05 30 02 22 f0 00 	movl   $0x0,0xf0220230
f010155b:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f010155e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101563:	e8 3c fc ff ff       	call   f01011a4 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101568:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010156d:	77 15                	ja     f0101584 <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010156f:	50                   	push   %eax
f0101570:	68 64 6d 10 f0       	push   $0xf0106d64
f0101575:	68 50 01 00 00       	push   $0x150
f010157a:	68 f1 80 10 f0       	push   $0xf01080f1
f010157f:	e8 e4 ea ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101584:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f010158a:	c1 ee 0c             	shr    $0xc,%esi
    size_t mpentry_page = MPENTRY_PADDR / PGSIZE;
    for (i = 0; i < npages; i++) {
f010158d:	83 3d 88 0e 22 f0 00 	cmpl   $0x0,0xf0220e88
f0101594:	74 64                	je     f01015fa <page_init+0xab>
f0101596:	8b 1d 30 02 22 f0    	mov    0xf0220230,%ebx
f010159c:	ba 00 00 00 00       	mov    $0x0,%edx
f01015a1:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub) && i != mpentry_page) {
f01015a6:	85 c0                	test   %eax,%eax
f01015a8:	74 2a                	je     f01015d4 <page_init+0x85>
f01015aa:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f01015af:	76 04                	jbe    f01015b5 <page_init+0x66>
f01015b1:	39 c6                	cmp    %eax,%esi
f01015b3:	77 1f                	ja     f01015d4 <page_init+0x85>
f01015b5:	83 f8 07             	cmp    $0x7,%eax
f01015b8:	74 1a                	je     f01015d4 <page_init+0x85>
		    pages[i].pp_ref = 0;
f01015ba:	89 d1                	mov    %edx,%ecx
f01015bc:	03 0d 90 0e 22 f0    	add    0xf0220e90,%ecx
f01015c2:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f01015c8:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f01015ca:	89 d3                	mov    %edx,%ebx
f01015cc:	03 1d 90 0e 22 f0    	add    0xf0220e90,%ebx
f01015d2:	eb 14                	jmp    f01015e8 <page_init+0x99>
        } else {
            pages[i].pp_ref = 1;
f01015d4:	89 d1                	mov    %edx,%ecx
f01015d6:	03 0d 90 0e 22 f0    	add    0xf0220e90,%ecx
f01015dc:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f01015e2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    size_t mpentry_page = MPENTRY_PADDR / PGSIZE;
    for (i = 0; i < npages; i++) {
f01015e8:	40                   	inc    %eax
f01015e9:	83 c2 08             	add    $0x8,%edx
f01015ec:	39 05 88 0e 22 f0    	cmp    %eax,0xf0220e88
f01015f2:	77 b2                	ja     f01015a6 <page_init+0x57>
f01015f4:	89 1d 30 02 22 f0    	mov    %ebx,0xf0220230
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f01015fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01015fd:	5b                   	pop    %ebx
f01015fe:	5e                   	pop    %esi
f01015ff:	c9                   	leave  
f0101600:	c3                   	ret    

f0101601 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101601:	55                   	push   %ebp
f0101602:	89 e5                	mov    %esp,%ebp
f0101604:	53                   	push   %ebx
f0101605:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
    while (page_free_list && page_free_list->pp_ref != 0) 
f0101608:	8b 1d 30 02 22 f0    	mov    0xf0220230,%ebx
f010160e:	85 db                	test   %ebx,%ebx
f0101610:	74 63                	je     f0101675 <page_alloc+0x74>
f0101612:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101617:	74 63                	je     f010167c <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f0101619:	8b 1b                	mov    (%ebx),%ebx
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
    while (page_free_list && page_free_list->pp_ref != 0) 
f010161b:	85 db                	test   %ebx,%ebx
f010161d:	75 08                	jne    f0101627 <page_alloc+0x26>
f010161f:	89 1d 30 02 22 f0    	mov    %ebx,0xf0220230
f0101625:	eb 4e                	jmp    f0101675 <page_alloc+0x74>
f0101627:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010162c:	75 eb                	jne    f0101619 <page_alloc+0x18>
f010162e:	eb 4c                	jmp    f010167c <page_alloc+0x7b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101630:	89 d8                	mov    %ebx,%eax
f0101632:	2b 05 90 0e 22 f0    	sub    0xf0220e90,%eax
f0101638:	c1 f8 03             	sar    $0x3,%eax
f010163b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010163e:	89 c2                	mov    %eax,%edx
f0101640:	c1 ea 0c             	shr    $0xc,%edx
f0101643:	3b 15 88 0e 22 f0    	cmp    0xf0220e88,%edx
f0101649:	72 12                	jb     f010165d <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010164b:	50                   	push   %eax
f010164c:	68 88 6d 10 f0       	push   $0xf0106d88
f0101651:	6a 58                	push   $0x58
f0101653:	68 fd 80 10 f0       	push   $0xf01080fd
f0101658:	e8 0b ea ff ff       	call   f0100068 <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f010165d:	83 ec 04             	sub    $0x4,%esp
f0101660:	68 00 10 00 00       	push   $0x1000
f0101665:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101667:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010166c:	50                   	push   %eax
f010166d:	e8 d7 49 00 00       	call   f0106049 <memset>
f0101672:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f0101675:	89 d8                	mov    %ebx,%eax
f0101677:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010167a:	c9                   	leave  
f010167b:	c3                   	ret    

    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f010167c:	8b 03                	mov    (%ebx),%eax
f010167e:	a3 30 02 22 f0       	mov    %eax,0xf0220230
        if (alloc_flags & ALLOC_ZERO) {
f0101683:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101687:	74 ec                	je     f0101675 <page_alloc+0x74>
f0101689:	eb a5                	jmp    f0101630 <page_alloc+0x2f>

f010168b <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010168b:	55                   	push   %ebp
f010168c:	89 e5                	mov    %esp,%ebp
f010168e:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f0101691:	85 c0                	test   %eax,%eax
f0101693:	74 14                	je     f01016a9 <page_free+0x1e>
f0101695:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010169a:	75 0d                	jne    f01016a9 <page_free+0x1e>
    pp->pp_link = page_free_list;
f010169c:	8b 15 30 02 22 f0    	mov    0xf0220230,%edx
f01016a2:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f01016a4:	a3 30 02 22 f0       	mov    %eax,0xf0220230
}
f01016a9:	c9                   	leave  
f01016aa:	c3                   	ret    

f01016ab <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01016ab:	55                   	push   %ebp
f01016ac:	89 e5                	mov    %esp,%ebp
f01016ae:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01016b1:	8b 50 04             	mov    0x4(%eax),%edx
f01016b4:	4a                   	dec    %edx
f01016b5:	66 89 50 04          	mov    %dx,0x4(%eax)
f01016b9:	66 85 d2             	test   %dx,%dx
f01016bc:	75 09                	jne    f01016c7 <page_decref+0x1c>
		page_free(pp);
f01016be:	50                   	push   %eax
f01016bf:	e8 c7 ff ff ff       	call   f010168b <page_free>
f01016c4:	83 c4 04             	add    $0x4,%esp
}
f01016c7:	c9                   	leave  
f01016c8:	c3                   	ret    

f01016c9 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01016c9:	55                   	push   %ebp
f01016ca:	89 e5                	mov    %esp,%ebp
f01016cc:	56                   	push   %esi
f01016cd:	53                   	push   %ebx
f01016ce:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f01016d1:	89 f3                	mov    %esi,%ebx
f01016d3:	c1 eb 16             	shr    $0x16,%ebx
f01016d6:	c1 e3 02             	shl    $0x2,%ebx
f01016d9:	03 5d 08             	add    0x8(%ebp),%ebx
f01016dc:	8b 03                	mov    (%ebx),%eax
f01016de:	85 c0                	test   %eax,%eax
f01016e0:	74 04                	je     f01016e6 <pgdir_walk+0x1d>
f01016e2:	a8 01                	test   $0x1,%al
f01016e4:	75 2c                	jne    f0101712 <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f01016e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01016ea:	74 61                	je     f010174d <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(1);
f01016ec:	83 ec 0c             	sub    $0xc,%esp
f01016ef:	6a 01                	push   $0x1
f01016f1:	e8 0b ff ff ff       	call   f0101601 <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f01016f6:	83 c4 10             	add    $0x10,%esp
f01016f9:	85 c0                	test   %eax,%eax
f01016fb:	74 57                	je     f0101754 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f01016fd:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101701:	2b 05 90 0e 22 f0    	sub    0xf0220e90,%eax
f0101707:	c1 f8 03             	sar    $0x3,%eax
f010170a:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f010170d:	83 c8 07             	or     $0x7,%eax
f0101710:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f0101712:	8b 03                	mov    (%ebx),%eax
f0101714:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101719:	89 c2                	mov    %eax,%edx
f010171b:	c1 ea 0c             	shr    $0xc,%edx
f010171e:	3b 15 88 0e 22 f0    	cmp    0xf0220e88,%edx
f0101724:	72 15                	jb     f010173b <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101726:	50                   	push   %eax
f0101727:	68 88 6d 10 f0       	push   $0xf0106d88
f010172c:	68 b4 01 00 00       	push   $0x1b4
f0101731:	68 f1 80 10 f0       	push   $0xf01080f1
f0101736:	e8 2d e9 ff ff       	call   f0100068 <_panic>
f010173b:	c1 ee 0a             	shr    $0xa,%esi
f010173e:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101744:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f010174b:	eb 0c                	jmp    f0101759 <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f010174d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101752:	eb 05                	jmp    f0101759 <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f0101754:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f0101759:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010175c:	5b                   	pop    %ebx
f010175d:	5e                   	pop    %esi
f010175e:	c9                   	leave  
f010175f:	c3                   	ret    

f0101760 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101760:	55                   	push   %ebp
f0101761:	89 e5                	mov    %esp,%ebp
f0101763:	57                   	push   %edi
f0101764:	56                   	push   %esi
f0101765:	53                   	push   %ebx
f0101766:	83 ec 1c             	sub    $0x1c,%esp
f0101769:	89 c7                	mov    %eax,%edi
f010176b:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f010176e:	01 d1                	add    %edx,%ecx
f0101770:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101773:	39 ca                	cmp    %ecx,%edx
f0101775:	74 32                	je     f01017a9 <boot_map_region+0x49>
f0101777:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f0101779:	8b 45 0c             	mov    0xc(%ebp),%eax
f010177c:	83 c8 01             	or     $0x1,%eax
f010177f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f0101782:	83 ec 04             	sub    $0x4,%esp
f0101785:	6a 01                	push   $0x1
f0101787:	53                   	push   %ebx
f0101788:	57                   	push   %edi
f0101789:	e8 3b ff ff ff       	call   f01016c9 <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f010178e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101791:	09 f2                	or     %esi,%edx
f0101793:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101795:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010179b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01017a1:	83 c4 10             	add    $0x10,%esp
f01017a4:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01017a7:	75 d9                	jne    f0101782 <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f01017a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01017ac:	5b                   	pop    %ebx
f01017ad:	5e                   	pop    %esi
f01017ae:	5f                   	pop    %edi
f01017af:	c9                   	leave  
f01017b0:	c3                   	ret    

f01017b1 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01017b1:	55                   	push   %ebp
f01017b2:	89 e5                	mov    %esp,%ebp
f01017b4:	53                   	push   %ebx
f01017b5:	83 ec 08             	sub    $0x8,%esp
f01017b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f01017bb:	6a 00                	push   $0x0
f01017bd:	ff 75 0c             	pushl  0xc(%ebp)
f01017c0:	ff 75 08             	pushl  0x8(%ebp)
f01017c3:	e8 01 ff ff ff       	call   f01016c9 <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01017c8:	83 c4 10             	add    $0x10,%esp
f01017cb:	85 c0                	test   %eax,%eax
f01017cd:	74 37                	je     f0101806 <page_lookup+0x55>
f01017cf:	f6 00 01             	testb  $0x1,(%eax)
f01017d2:	74 39                	je     f010180d <page_lookup+0x5c>
    if (pte_store != NULL) {
f01017d4:	85 db                	test   %ebx,%ebx
f01017d6:	74 02                	je     f01017da <page_lookup+0x29>
        *pte_store = pte;
f01017d8:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f01017da:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017dc:	c1 e8 0c             	shr    $0xc,%eax
f01017df:	3b 05 88 0e 22 f0    	cmp    0xf0220e88,%eax
f01017e5:	72 14                	jb     f01017fb <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01017e7:	83 ec 04             	sub    $0x4,%esp
f01017ea:	68 f0 78 10 f0       	push   $0xf01078f0
f01017ef:	6a 51                	push   $0x51
f01017f1:	68 fd 80 10 f0       	push   $0xf01080fd
f01017f6:	e8 6d e8 ff ff       	call   f0100068 <_panic>
	return &pages[PGNUM(pa)];
f01017fb:	c1 e0 03             	shl    $0x3,%eax
f01017fe:	03 05 90 0e 22 f0    	add    0xf0220e90,%eax
f0101804:	eb 0c                	jmp    f0101812 <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0101806:	b8 00 00 00 00       	mov    $0x0,%eax
f010180b:	eb 05                	jmp    f0101812 <page_lookup+0x61>
f010180d:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != NULL) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f0101812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101815:	c9                   	leave  
f0101816:	c3                   	ret    

f0101817 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101817:	55                   	push   %ebp
f0101818:	89 e5                	mov    %esp,%ebp
f010181a:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010181d:	e8 56 4e 00 00       	call   f0106678 <cpunum>
f0101822:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101829:	29 c2                	sub    %eax,%edx
f010182b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010182e:	83 3c 85 28 10 22 f0 	cmpl   $0x0,-0xfddefd8(,%eax,4)
f0101835:	00 
f0101836:	74 20                	je     f0101858 <tlb_invalidate+0x41>
f0101838:	e8 3b 4e 00 00       	call   f0106678 <cpunum>
f010183d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101844:	29 c2                	sub    %eax,%edx
f0101846:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0101849:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0101850:	8b 55 08             	mov    0x8(%ebp),%edx
f0101853:	39 50 60             	cmp    %edx,0x60(%eax)
f0101856:	75 06                	jne    f010185e <tlb_invalidate+0x47>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101858:	8b 45 0c             	mov    0xc(%ebp),%eax
f010185b:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010185e:	c9                   	leave  
f010185f:	c3                   	ret    

f0101860 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101860:	55                   	push   %ebp
f0101861:	89 e5                	mov    %esp,%ebp
f0101863:	56                   	push   %esi
f0101864:	53                   	push   %ebx
f0101865:	83 ec 14             	sub    $0x14,%esp
f0101868:	8b 75 08             	mov    0x8(%ebp),%esi
f010186b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f010186e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101871:	50                   	push   %eax
f0101872:	53                   	push   %ebx
f0101873:	56                   	push   %esi
f0101874:	e8 38 ff ff ff       	call   f01017b1 <page_lookup>
    if (pg == NULL) return;
f0101879:	83 c4 10             	add    $0x10,%esp
f010187c:	85 c0                	test   %eax,%eax
f010187e:	74 26                	je     f01018a6 <page_remove+0x46>
    page_decref(pg);
f0101880:	83 ec 0c             	sub    $0xc,%esp
f0101883:	50                   	push   %eax
f0101884:	e8 22 fe ff ff       	call   f01016ab <page_decref>
    if (pte != NULL) *pte = 0;
f0101889:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010188c:	83 c4 10             	add    $0x10,%esp
f010188f:	85 c0                	test   %eax,%eax
f0101891:	74 06                	je     f0101899 <page_remove+0x39>
f0101893:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f0101899:	83 ec 08             	sub    $0x8,%esp
f010189c:	53                   	push   %ebx
f010189d:	56                   	push   %esi
f010189e:	e8 74 ff ff ff       	call   f0101817 <tlb_invalidate>
f01018a3:	83 c4 10             	add    $0x10,%esp
}
f01018a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01018a9:	5b                   	pop    %ebx
f01018aa:	5e                   	pop    %esi
f01018ab:	c9                   	leave  
f01018ac:	c3                   	ret    

f01018ad <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01018ad:	55                   	push   %ebp
f01018ae:	89 e5                	mov    %esp,%ebp
f01018b0:	57                   	push   %edi
f01018b1:	56                   	push   %esi
f01018b2:	53                   	push   %ebx
f01018b3:	83 ec 10             	sub    $0x10,%esp
f01018b6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01018b9:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f01018bc:	6a 01                	push   $0x1
f01018be:	57                   	push   %edi
f01018bf:	ff 75 08             	pushl  0x8(%ebp)
f01018c2:	e8 02 fe ff ff       	call   f01016c9 <pgdir_walk>
f01018c7:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f01018c9:	83 c4 10             	add    $0x10,%esp
f01018cc:	85 c0                	test   %eax,%eax
f01018ce:	74 39                	je     f0101909 <page_insert+0x5c>
    ++pp->pp_ref;
f01018d0:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f01018d4:	f6 00 01             	testb  $0x1,(%eax)
f01018d7:	74 0f                	je     f01018e8 <page_insert+0x3b>
        page_remove(pgdir, va);
f01018d9:	83 ec 08             	sub    $0x8,%esp
f01018dc:	57                   	push   %edi
f01018dd:	ff 75 08             	pushl  0x8(%ebp)
f01018e0:	e8 7b ff ff ff       	call   f0101860 <page_remove>
f01018e5:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f01018e8:	8b 55 14             	mov    0x14(%ebp),%edx
f01018eb:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018ee:	2b 35 90 0e 22 f0    	sub    0xf0220e90,%esi
f01018f4:	c1 fe 03             	sar    $0x3,%esi
f01018f7:	89 f0                	mov    %esi,%eax
f01018f9:	c1 e0 0c             	shl    $0xc,%eax
f01018fc:	89 d6                	mov    %edx,%esi
f01018fe:	09 c6                	or     %eax,%esi
f0101900:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101902:	b8 00 00 00 00       	mov    $0x0,%eax
f0101907:	eb 05                	jmp    f010190e <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f0101909:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f010190e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101911:	5b                   	pop    %ebx
f0101912:	5e                   	pop    %esi
f0101913:	5f                   	pop    %edi
f0101914:	c9                   	leave  
f0101915:	c3                   	ret    

f0101916 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101916:	55                   	push   %ebp
f0101917:	89 e5                	mov    %esp,%ebp
f0101919:	53                   	push   %ebx
f010191a:	83 ec 0c             	sub    $0xc,%esp
f010191d:	8b 45 08             	mov    0x8(%ebp),%eax
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	uint32_t ed = ROUNDUP(pa + size, PGSIZE);
f0101920:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101926:	03 5d 0c             	add    0xc(%ebp),%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
f0101929:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	uint32_t ed = ROUNDUP(pa + size, PGSIZE);
f010192e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
	boot_map_region(kern_pgdir, base, ed - pa, pa, PTE_PCD | PTE_PWT | PTE_W);
f0101934:	29 c3                	sub    %eax,%ebx
f0101936:	6a 1a                	push   $0x1a
f0101938:	50                   	push   %eax
f0101939:	89 d9                	mov    %ebx,%ecx
f010193b:	8b 15 00 93 12 f0    	mov    0xf0129300,%edx
f0101941:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0101946:	e8 15 fe ff ff       	call   f0101760 <boot_map_region>
	uintptr_t tmp_base = base;
f010194b:	a1 00 93 12 f0       	mov    0xf0129300,%eax
	base += ed - pa;
f0101950:	01 c3                	add    %eax,%ebx
f0101952:	89 1d 00 93 12 f0    	mov    %ebx,0xf0129300
	return (void *) tmp_base;
	panic("mmio_map_region not implemented");
}
f0101958:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010195b:	c9                   	leave  
f010195c:	c3                   	ret    

f010195d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010195d:	55                   	push   %ebp
f010195e:	89 e5                	mov    %esp,%ebp
f0101960:	57                   	push   %edi
f0101961:	56                   	push   %esi
f0101962:	53                   	push   %ebx
f0101963:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101966:	b8 15 00 00 00       	mov    $0x15,%eax
f010196b:	e8 cd f8 ff ff       	call   f010123d <nvram_read>
f0101970:	c1 e0 0a             	shl    $0xa,%eax
f0101973:	89 c2                	mov    %eax,%edx
f0101975:	85 c0                	test   %eax,%eax
f0101977:	79 06                	jns    f010197f <mem_init+0x22>
f0101979:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010197f:	c1 fa 0c             	sar    $0xc,%edx
f0101982:	89 15 38 02 22 f0    	mov    %edx,0xf0220238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101988:	b8 17 00 00 00       	mov    $0x17,%eax
f010198d:	e8 ab f8 ff ff       	call   f010123d <nvram_read>
f0101992:	89 c2                	mov    %eax,%edx
f0101994:	c1 e2 0a             	shl    $0xa,%edx
f0101997:	89 d0                	mov    %edx,%eax
f0101999:	85 d2                	test   %edx,%edx
f010199b:	79 06                	jns    f01019a3 <mem_init+0x46>
f010199d:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01019a3:	c1 f8 0c             	sar    $0xc,%eax
f01019a6:	74 0e                	je     f01019b6 <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01019a8:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01019ae:	89 15 88 0e 22 f0    	mov    %edx,0xf0220e88
f01019b4:	eb 0c                	jmp    f01019c2 <mem_init+0x65>
	else
		npages = npages_basemem;
f01019b6:	8b 15 38 02 22 f0    	mov    0xf0220238,%edx
f01019bc:	89 15 88 0e 22 f0    	mov    %edx,0xf0220e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01019c2:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01019c5:	c1 e8 0a             	shr    $0xa,%eax
f01019c8:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01019c9:	a1 38 02 22 f0       	mov    0xf0220238,%eax
f01019ce:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01019d1:	c1 e8 0a             	shr    $0xa,%eax
f01019d4:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01019d5:	a1 88 0e 22 f0       	mov    0xf0220e88,%eax
f01019da:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01019dd:	c1 e8 0a             	shr    $0xa,%eax
f01019e0:	50                   	push   %eax
f01019e1:	68 10 79 10 f0       	push   $0xf0107910
f01019e6:	e8 76 24 00 00       	call   f0103e61 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01019eb:	b8 00 10 00 00       	mov    $0x1000,%eax
f01019f0:	e8 af f7 ff ff       	call   f01011a4 <boot_alloc>
f01019f5:	a3 8c 0e 22 f0       	mov    %eax,0xf0220e8c
	memset(kern_pgdir, 0, PGSIZE);
f01019fa:	83 c4 0c             	add    $0xc,%esp
f01019fd:	68 00 10 00 00       	push   $0x1000
f0101a02:	6a 00                	push   $0x0
f0101a04:	50                   	push   %eax
f0101a05:	e8 3f 46 00 00       	call   f0106049 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101a0a:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101a0f:	83 c4 10             	add    $0x10,%esp
f0101a12:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101a17:	77 15                	ja     f0101a2e <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101a19:	50                   	push   %eax
f0101a1a:	68 64 6d 10 f0       	push   $0xf0106d64
f0101a1f:	68 90 00 00 00       	push   $0x90
f0101a24:	68 f1 80 10 f0       	push   $0xf01080f1
f0101a29:	e8 3a e6 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101a2e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101a34:	83 ca 05             	or     $0x5,%edx
f0101a37:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101a3d:	a1 88 0e 22 f0       	mov    0xf0220e88,%eax
f0101a42:	c1 e0 03             	shl    $0x3,%eax
f0101a45:	e8 5a f7 ff ff       	call   f01011a4 <boot_alloc>
f0101a4a:	a3 90 0e 22 f0       	mov    %eax,0xf0220e90
    

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101a4f:	b8 00 10 02 00       	mov    $0x21000,%eax
f0101a54:	e8 4b f7 ff ff       	call   f01011a4 <boot_alloc>
f0101a59:	a3 3c 02 22 f0       	mov    %eax,0xf022023c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101a5e:	e8 ec fa ff ff       	call   f010154f <page_init>

	check_page_free_list(1);
f0101a63:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a68:	e8 f7 f7 ff ff       	call   f0101264 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101a6d:	83 3d 90 0e 22 f0 00 	cmpl   $0x0,0xf0220e90
f0101a74:	75 17                	jne    f0101a8d <mem_init+0x130>
		panic("'pages' is a null pointer!");
f0101a76:	83 ec 04             	sub    $0x4,%esp
f0101a79:	68 c4 81 10 f0       	push   $0xf01081c4
f0101a7e:	68 ed 02 00 00       	push   $0x2ed
f0101a83:	68 f1 80 10 f0       	push   $0xf01080f1
f0101a88:	e8 db e5 ff ff       	call   f0100068 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a8d:	a1 30 02 22 f0       	mov    0xf0220230,%eax
f0101a92:	85 c0                	test   %eax,%eax
f0101a94:	74 0e                	je     f0101aa4 <mem_init+0x147>
f0101a96:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101a9b:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a9c:	8b 00                	mov    (%eax),%eax
f0101a9e:	85 c0                	test   %eax,%eax
f0101aa0:	75 f9                	jne    f0101a9b <mem_init+0x13e>
f0101aa2:	eb 05                	jmp    f0101aa9 <mem_init+0x14c>
f0101aa4:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101aa9:	83 ec 0c             	sub    $0xc,%esp
f0101aac:	6a 00                	push   $0x0
f0101aae:	e8 4e fb ff ff       	call   f0101601 <page_alloc>
f0101ab3:	89 c6                	mov    %eax,%esi
f0101ab5:	83 c4 10             	add    $0x10,%esp
f0101ab8:	85 c0                	test   %eax,%eax
f0101aba:	75 19                	jne    f0101ad5 <mem_init+0x178>
f0101abc:	68 df 81 10 f0       	push   $0xf01081df
f0101ac1:	68 17 81 10 f0       	push   $0xf0108117
f0101ac6:	68 f5 02 00 00       	push   $0x2f5
f0101acb:	68 f1 80 10 f0       	push   $0xf01080f1
f0101ad0:	e8 93 e5 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ad5:	83 ec 0c             	sub    $0xc,%esp
f0101ad8:	6a 00                	push   $0x0
f0101ada:	e8 22 fb ff ff       	call   f0101601 <page_alloc>
f0101adf:	89 c7                	mov    %eax,%edi
f0101ae1:	83 c4 10             	add    $0x10,%esp
f0101ae4:	85 c0                	test   %eax,%eax
f0101ae6:	75 19                	jne    f0101b01 <mem_init+0x1a4>
f0101ae8:	68 f5 81 10 f0       	push   $0xf01081f5
f0101aed:	68 17 81 10 f0       	push   $0xf0108117
f0101af2:	68 f6 02 00 00       	push   $0x2f6
f0101af7:	68 f1 80 10 f0       	push   $0xf01080f1
f0101afc:	e8 67 e5 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b01:	83 ec 0c             	sub    $0xc,%esp
f0101b04:	6a 00                	push   $0x0
f0101b06:	e8 f6 fa ff ff       	call   f0101601 <page_alloc>
f0101b0b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b0e:	83 c4 10             	add    $0x10,%esp
f0101b11:	85 c0                	test   %eax,%eax
f0101b13:	75 19                	jne    f0101b2e <mem_init+0x1d1>
f0101b15:	68 0b 82 10 f0       	push   $0xf010820b
f0101b1a:	68 17 81 10 f0       	push   $0xf0108117
f0101b1f:	68 f7 02 00 00       	push   $0x2f7
f0101b24:	68 f1 80 10 f0       	push   $0xf01080f1
f0101b29:	e8 3a e5 ff ff       	call   f0100068 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b2e:	39 fe                	cmp    %edi,%esi
f0101b30:	75 19                	jne    f0101b4b <mem_init+0x1ee>
f0101b32:	68 21 82 10 f0       	push   $0xf0108221
f0101b37:	68 17 81 10 f0       	push   $0xf0108117
f0101b3c:	68 fa 02 00 00       	push   $0x2fa
f0101b41:	68 f1 80 10 f0       	push   $0xf01080f1
f0101b46:	e8 1d e5 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b4b:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101b4e:	74 05                	je     f0101b55 <mem_init+0x1f8>
f0101b50:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101b53:	75 19                	jne    f0101b6e <mem_init+0x211>
f0101b55:	68 4c 79 10 f0       	push   $0xf010794c
f0101b5a:	68 17 81 10 f0       	push   $0xf0108117
f0101b5f:	68 fb 02 00 00       	push   $0x2fb
f0101b64:	68 f1 80 10 f0       	push   $0xf01080f1
f0101b69:	e8 fa e4 ff ff       	call   f0100068 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b6e:	8b 15 90 0e 22 f0    	mov    0xf0220e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101b74:	a1 88 0e 22 f0       	mov    0xf0220e88,%eax
f0101b79:	c1 e0 0c             	shl    $0xc,%eax
f0101b7c:	89 f1                	mov    %esi,%ecx
f0101b7e:	29 d1                	sub    %edx,%ecx
f0101b80:	c1 f9 03             	sar    $0x3,%ecx
f0101b83:	c1 e1 0c             	shl    $0xc,%ecx
f0101b86:	39 c1                	cmp    %eax,%ecx
f0101b88:	72 19                	jb     f0101ba3 <mem_init+0x246>
f0101b8a:	68 33 82 10 f0       	push   $0xf0108233
f0101b8f:	68 17 81 10 f0       	push   $0xf0108117
f0101b94:	68 fc 02 00 00       	push   $0x2fc
f0101b99:	68 f1 80 10 f0       	push   $0xf01080f1
f0101b9e:	e8 c5 e4 ff ff       	call   f0100068 <_panic>
f0101ba3:	89 f9                	mov    %edi,%ecx
f0101ba5:	29 d1                	sub    %edx,%ecx
f0101ba7:	c1 f9 03             	sar    $0x3,%ecx
f0101baa:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101bad:	39 c8                	cmp    %ecx,%eax
f0101baf:	77 19                	ja     f0101bca <mem_init+0x26d>
f0101bb1:	68 50 82 10 f0       	push   $0xf0108250
f0101bb6:	68 17 81 10 f0       	push   $0xf0108117
f0101bbb:	68 fd 02 00 00       	push   $0x2fd
f0101bc0:	68 f1 80 10 f0       	push   $0xf01080f1
f0101bc5:	e8 9e e4 ff ff       	call   f0100068 <_panic>
f0101bca:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101bcd:	29 d1                	sub    %edx,%ecx
f0101bcf:	89 ca                	mov    %ecx,%edx
f0101bd1:	c1 fa 03             	sar    $0x3,%edx
f0101bd4:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101bd7:	39 d0                	cmp    %edx,%eax
f0101bd9:	77 19                	ja     f0101bf4 <mem_init+0x297>
f0101bdb:	68 6d 82 10 f0       	push   $0xf010826d
f0101be0:	68 17 81 10 f0       	push   $0xf0108117
f0101be5:	68 fe 02 00 00       	push   $0x2fe
f0101bea:	68 f1 80 10 f0       	push   $0xf01080f1
f0101bef:	e8 74 e4 ff ff       	call   f0100068 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101bf4:	a1 30 02 22 f0       	mov    0xf0220230,%eax
f0101bf9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101bfc:	c7 05 30 02 22 f0 00 	movl   $0x0,0xf0220230
f0101c03:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c06:	83 ec 0c             	sub    $0xc,%esp
f0101c09:	6a 00                	push   $0x0
f0101c0b:	e8 f1 f9 ff ff       	call   f0101601 <page_alloc>
f0101c10:	83 c4 10             	add    $0x10,%esp
f0101c13:	85 c0                	test   %eax,%eax
f0101c15:	74 19                	je     f0101c30 <mem_init+0x2d3>
f0101c17:	68 8a 82 10 f0       	push   $0xf010828a
f0101c1c:	68 17 81 10 f0       	push   $0xf0108117
f0101c21:	68 05 03 00 00       	push   $0x305
f0101c26:	68 f1 80 10 f0       	push   $0xf01080f1
f0101c2b:	e8 38 e4 ff ff       	call   f0100068 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101c30:	83 ec 0c             	sub    $0xc,%esp
f0101c33:	56                   	push   %esi
f0101c34:	e8 52 fa ff ff       	call   f010168b <page_free>
	page_free(pp1);
f0101c39:	89 3c 24             	mov    %edi,(%esp)
f0101c3c:	e8 4a fa ff ff       	call   f010168b <page_free>
	page_free(pp2);
f0101c41:	83 c4 04             	add    $0x4,%esp
f0101c44:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c47:	e8 3f fa ff ff       	call   f010168b <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c53:	e8 a9 f9 ff ff       	call   f0101601 <page_alloc>
f0101c58:	89 c6                	mov    %eax,%esi
f0101c5a:	83 c4 10             	add    $0x10,%esp
f0101c5d:	85 c0                	test   %eax,%eax
f0101c5f:	75 19                	jne    f0101c7a <mem_init+0x31d>
f0101c61:	68 df 81 10 f0       	push   $0xf01081df
f0101c66:	68 17 81 10 f0       	push   $0xf0108117
f0101c6b:	68 0c 03 00 00       	push   $0x30c
f0101c70:	68 f1 80 10 f0       	push   $0xf01080f1
f0101c75:	e8 ee e3 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c7a:	83 ec 0c             	sub    $0xc,%esp
f0101c7d:	6a 00                	push   $0x0
f0101c7f:	e8 7d f9 ff ff       	call   f0101601 <page_alloc>
f0101c84:	89 c7                	mov    %eax,%edi
f0101c86:	83 c4 10             	add    $0x10,%esp
f0101c89:	85 c0                	test   %eax,%eax
f0101c8b:	75 19                	jne    f0101ca6 <mem_init+0x349>
f0101c8d:	68 f5 81 10 f0       	push   $0xf01081f5
f0101c92:	68 17 81 10 f0       	push   $0xf0108117
f0101c97:	68 0d 03 00 00       	push   $0x30d
f0101c9c:	68 f1 80 10 f0       	push   $0xf01080f1
f0101ca1:	e8 c2 e3 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ca6:	83 ec 0c             	sub    $0xc,%esp
f0101ca9:	6a 00                	push   $0x0
f0101cab:	e8 51 f9 ff ff       	call   f0101601 <page_alloc>
f0101cb0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101cb3:	83 c4 10             	add    $0x10,%esp
f0101cb6:	85 c0                	test   %eax,%eax
f0101cb8:	75 19                	jne    f0101cd3 <mem_init+0x376>
f0101cba:	68 0b 82 10 f0       	push   $0xf010820b
f0101cbf:	68 17 81 10 f0       	push   $0xf0108117
f0101cc4:	68 0e 03 00 00       	push   $0x30e
f0101cc9:	68 f1 80 10 f0       	push   $0xf01080f1
f0101cce:	e8 95 e3 ff ff       	call   f0100068 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101cd3:	39 fe                	cmp    %edi,%esi
f0101cd5:	75 19                	jne    f0101cf0 <mem_init+0x393>
f0101cd7:	68 21 82 10 f0       	push   $0xf0108221
f0101cdc:	68 17 81 10 f0       	push   $0xf0108117
f0101ce1:	68 10 03 00 00       	push   $0x310
f0101ce6:	68 f1 80 10 f0       	push   $0xf01080f1
f0101ceb:	e8 78 e3 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cf0:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101cf3:	74 05                	je     f0101cfa <mem_init+0x39d>
f0101cf5:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101cf8:	75 19                	jne    f0101d13 <mem_init+0x3b6>
f0101cfa:	68 4c 79 10 f0       	push   $0xf010794c
f0101cff:	68 17 81 10 f0       	push   $0xf0108117
f0101d04:	68 11 03 00 00       	push   $0x311
f0101d09:	68 f1 80 10 f0       	push   $0xf01080f1
f0101d0e:	e8 55 e3 ff ff       	call   f0100068 <_panic>
	assert(!page_alloc(0));
f0101d13:	83 ec 0c             	sub    $0xc,%esp
f0101d16:	6a 00                	push   $0x0
f0101d18:	e8 e4 f8 ff ff       	call   f0101601 <page_alloc>
f0101d1d:	83 c4 10             	add    $0x10,%esp
f0101d20:	85 c0                	test   %eax,%eax
f0101d22:	74 19                	je     f0101d3d <mem_init+0x3e0>
f0101d24:	68 8a 82 10 f0       	push   $0xf010828a
f0101d29:	68 17 81 10 f0       	push   $0xf0108117
f0101d2e:	68 12 03 00 00       	push   $0x312
f0101d33:	68 f1 80 10 f0       	push   $0xf01080f1
f0101d38:	e8 2b e3 ff ff       	call   f0100068 <_panic>
f0101d3d:	89 f0                	mov    %esi,%eax
f0101d3f:	2b 05 90 0e 22 f0    	sub    0xf0220e90,%eax
f0101d45:	c1 f8 03             	sar    $0x3,%eax
f0101d48:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d4b:	89 c2                	mov    %eax,%edx
f0101d4d:	c1 ea 0c             	shr    $0xc,%edx
f0101d50:	3b 15 88 0e 22 f0    	cmp    0xf0220e88,%edx
f0101d56:	72 12                	jb     f0101d6a <mem_init+0x40d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d58:	50                   	push   %eax
f0101d59:	68 88 6d 10 f0       	push   $0xf0106d88
f0101d5e:	6a 58                	push   $0x58
f0101d60:	68 fd 80 10 f0       	push   $0xf01080fd
f0101d65:	e8 fe e2 ff ff       	call   f0100068 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101d6a:	83 ec 04             	sub    $0x4,%esp
f0101d6d:	68 00 10 00 00       	push   $0x1000
f0101d72:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101d74:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d79:	50                   	push   %eax
f0101d7a:	e8 ca 42 00 00       	call   f0106049 <memset>
	page_free(pp0);
f0101d7f:	89 34 24             	mov    %esi,(%esp)
f0101d82:	e8 04 f9 ff ff       	call   f010168b <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d87:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101d8e:	e8 6e f8 ff ff       	call   f0101601 <page_alloc>
f0101d93:	83 c4 10             	add    $0x10,%esp
f0101d96:	85 c0                	test   %eax,%eax
f0101d98:	75 19                	jne    f0101db3 <mem_init+0x456>
f0101d9a:	68 99 82 10 f0       	push   $0xf0108299
f0101d9f:	68 17 81 10 f0       	push   $0xf0108117
f0101da4:	68 17 03 00 00       	push   $0x317
f0101da9:	68 f1 80 10 f0       	push   $0xf01080f1
f0101dae:	e8 b5 e2 ff ff       	call   f0100068 <_panic>
	assert(pp && pp0 == pp);
f0101db3:	39 c6                	cmp    %eax,%esi
f0101db5:	74 19                	je     f0101dd0 <mem_init+0x473>
f0101db7:	68 b7 82 10 f0       	push   $0xf01082b7
f0101dbc:	68 17 81 10 f0       	push   $0xf0108117
f0101dc1:	68 18 03 00 00       	push   $0x318
f0101dc6:	68 f1 80 10 f0       	push   $0xf01080f1
f0101dcb:	e8 98 e2 ff ff       	call   f0100068 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101dd0:	89 f2                	mov    %esi,%edx
f0101dd2:	2b 15 90 0e 22 f0    	sub    0xf0220e90,%edx
f0101dd8:	c1 fa 03             	sar    $0x3,%edx
f0101ddb:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101dde:	89 d0                	mov    %edx,%eax
f0101de0:	c1 e8 0c             	shr    $0xc,%eax
f0101de3:	3b 05 88 0e 22 f0    	cmp    0xf0220e88,%eax
f0101de9:	72 12                	jb     f0101dfd <mem_init+0x4a0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101deb:	52                   	push   %edx
f0101dec:	68 88 6d 10 f0       	push   $0xf0106d88
f0101df1:	6a 58                	push   $0x58
f0101df3:	68 fd 80 10 f0       	push   $0xf01080fd
f0101df8:	e8 6b e2 ff ff       	call   f0100068 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101dfd:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101e04:	75 11                	jne    f0101e17 <mem_init+0x4ba>
f0101e06:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101e0c:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101e12:	80 38 00             	cmpb   $0x0,(%eax)
f0101e15:	74 19                	je     f0101e30 <mem_init+0x4d3>
f0101e17:	68 c7 82 10 f0       	push   $0xf01082c7
f0101e1c:	68 17 81 10 f0       	push   $0xf0108117
f0101e21:	68 1b 03 00 00       	push   $0x31b
f0101e26:	68 f1 80 10 f0       	push   $0xf01080f1
f0101e2b:	e8 38 e2 ff ff       	call   f0100068 <_panic>
f0101e30:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101e31:	39 d0                	cmp    %edx,%eax
f0101e33:	75 dd                	jne    f0101e12 <mem_init+0x4b5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101e35:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101e38:	89 15 30 02 22 f0    	mov    %edx,0xf0220230

	// free the pages we took
	page_free(pp0);
f0101e3e:	83 ec 0c             	sub    $0xc,%esp
f0101e41:	56                   	push   %esi
f0101e42:	e8 44 f8 ff ff       	call   f010168b <page_free>
	page_free(pp1);
f0101e47:	89 3c 24             	mov    %edi,(%esp)
f0101e4a:	e8 3c f8 ff ff       	call   f010168b <page_free>
	page_free(pp2);
f0101e4f:	83 c4 04             	add    $0x4,%esp
f0101e52:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e55:	e8 31 f8 ff ff       	call   f010168b <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e5a:	a1 30 02 22 f0       	mov    0xf0220230,%eax
f0101e5f:	83 c4 10             	add    $0x10,%esp
f0101e62:	85 c0                	test   %eax,%eax
f0101e64:	74 07                	je     f0101e6d <mem_init+0x510>
		--nfree;
f0101e66:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e67:	8b 00                	mov    (%eax),%eax
f0101e69:	85 c0                	test   %eax,%eax
f0101e6b:	75 f9                	jne    f0101e66 <mem_init+0x509>
		--nfree;
	assert(nfree == 0);
f0101e6d:	85 db                	test   %ebx,%ebx
f0101e6f:	74 19                	je     f0101e8a <mem_init+0x52d>
f0101e71:	68 d1 82 10 f0       	push   $0xf01082d1
f0101e76:	68 17 81 10 f0       	push   $0xf0108117
f0101e7b:	68 28 03 00 00       	push   $0x328
f0101e80:	68 f1 80 10 f0       	push   $0xf01080f1
f0101e85:	e8 de e1 ff ff       	call   f0100068 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101e8a:	83 ec 0c             	sub    $0xc,%esp
f0101e8d:	68 6c 79 10 f0       	push   $0xf010796c
f0101e92:	e8 ca 1f 00 00       	call   f0103e61 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101e97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e9e:	e8 5e f7 ff ff       	call   f0101601 <page_alloc>
f0101ea3:	89 c7                	mov    %eax,%edi
f0101ea5:	83 c4 10             	add    $0x10,%esp
f0101ea8:	85 c0                	test   %eax,%eax
f0101eaa:	75 19                	jne    f0101ec5 <mem_init+0x568>
f0101eac:	68 df 81 10 f0       	push   $0xf01081df
f0101eb1:	68 17 81 10 f0       	push   $0xf0108117
f0101eb6:	68 8e 03 00 00       	push   $0x38e
f0101ebb:	68 f1 80 10 f0       	push   $0xf01080f1
f0101ec0:	e8 a3 e1 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ec5:	83 ec 0c             	sub    $0xc,%esp
f0101ec8:	6a 00                	push   $0x0
f0101eca:	e8 32 f7 ff ff       	call   f0101601 <page_alloc>
f0101ecf:	89 c6                	mov    %eax,%esi
f0101ed1:	83 c4 10             	add    $0x10,%esp
f0101ed4:	85 c0                	test   %eax,%eax
f0101ed6:	75 19                	jne    f0101ef1 <mem_init+0x594>
f0101ed8:	68 f5 81 10 f0       	push   $0xf01081f5
f0101edd:	68 17 81 10 f0       	push   $0xf0108117
f0101ee2:	68 8f 03 00 00       	push   $0x38f
f0101ee7:	68 f1 80 10 f0       	push   $0xf01080f1
f0101eec:	e8 77 e1 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ef1:	83 ec 0c             	sub    $0xc,%esp
f0101ef4:	6a 00                	push   $0x0
f0101ef6:	e8 06 f7 ff ff       	call   f0101601 <page_alloc>
f0101efb:	89 c3                	mov    %eax,%ebx
f0101efd:	83 c4 10             	add    $0x10,%esp
f0101f00:	85 c0                	test   %eax,%eax
f0101f02:	75 19                	jne    f0101f1d <mem_init+0x5c0>
f0101f04:	68 0b 82 10 f0       	push   $0xf010820b
f0101f09:	68 17 81 10 f0       	push   $0xf0108117
f0101f0e:	68 90 03 00 00       	push   $0x390
f0101f13:	68 f1 80 10 f0       	push   $0xf01080f1
f0101f18:	e8 4b e1 ff ff       	call   f0100068 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f1d:	39 f7                	cmp    %esi,%edi
f0101f1f:	75 19                	jne    f0101f3a <mem_init+0x5dd>
f0101f21:	68 21 82 10 f0       	push   $0xf0108221
f0101f26:	68 17 81 10 f0       	push   $0xf0108117
f0101f2b:	68 93 03 00 00       	push   $0x393
f0101f30:	68 f1 80 10 f0       	push   $0xf01080f1
f0101f35:	e8 2e e1 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f3a:	39 c6                	cmp    %eax,%esi
f0101f3c:	74 04                	je     f0101f42 <mem_init+0x5e5>
f0101f3e:	39 c7                	cmp    %eax,%edi
f0101f40:	75 19                	jne    f0101f5b <mem_init+0x5fe>
f0101f42:	68 4c 79 10 f0       	push   $0xf010794c
f0101f47:	68 17 81 10 f0       	push   $0xf0108117
f0101f4c:	68 94 03 00 00       	push   $0x394
f0101f51:	68 f1 80 10 f0       	push   $0xf01080f1
f0101f56:	e8 0d e1 ff ff       	call   f0100068 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101f5b:	8b 0d 30 02 22 f0    	mov    0xf0220230,%ecx
f0101f61:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101f64:	c7 05 30 02 22 f0 00 	movl   $0x0,0xf0220230
f0101f6b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101f6e:	83 ec 0c             	sub    $0xc,%esp
f0101f71:	6a 00                	push   $0x0
f0101f73:	e8 89 f6 ff ff       	call   f0101601 <page_alloc>
f0101f78:	83 c4 10             	add    $0x10,%esp
f0101f7b:	85 c0                	test   %eax,%eax
f0101f7d:	74 19                	je     f0101f98 <mem_init+0x63b>
f0101f7f:	68 8a 82 10 f0       	push   $0xf010828a
f0101f84:	68 17 81 10 f0       	push   $0xf0108117
f0101f89:	68 9b 03 00 00       	push   $0x39b
f0101f8e:	68 f1 80 10 f0       	push   $0xf01080f1
f0101f93:	e8 d0 e0 ff ff       	call   f0100068 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101f98:	83 ec 04             	sub    $0x4,%esp
f0101f9b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101f9e:	50                   	push   %eax
f0101f9f:	6a 00                	push   $0x0
f0101fa1:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0101fa7:	e8 05 f8 ff ff       	call   f01017b1 <page_lookup>
f0101fac:	83 c4 10             	add    $0x10,%esp
f0101faf:	85 c0                	test   %eax,%eax
f0101fb1:	74 19                	je     f0101fcc <mem_init+0x66f>
f0101fb3:	68 8c 79 10 f0       	push   $0xf010798c
f0101fb8:	68 17 81 10 f0       	push   $0xf0108117
f0101fbd:	68 9e 03 00 00       	push   $0x39e
f0101fc2:	68 f1 80 10 f0       	push   $0xf01080f1
f0101fc7:	e8 9c e0 ff ff       	call   f0100068 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101fcc:	6a 02                	push   $0x2
f0101fce:	6a 00                	push   $0x0
f0101fd0:	56                   	push   %esi
f0101fd1:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0101fd7:	e8 d1 f8 ff ff       	call   f01018ad <page_insert>
f0101fdc:	83 c4 10             	add    $0x10,%esp
f0101fdf:	85 c0                	test   %eax,%eax
f0101fe1:	78 19                	js     f0101ffc <mem_init+0x69f>
f0101fe3:	68 c4 79 10 f0       	push   $0xf01079c4
f0101fe8:	68 17 81 10 f0       	push   $0xf0108117
f0101fed:	68 a1 03 00 00       	push   $0x3a1
f0101ff2:	68 f1 80 10 f0       	push   $0xf01080f1
f0101ff7:	e8 6c e0 ff ff       	call   f0100068 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101ffc:	83 ec 0c             	sub    $0xc,%esp
f0101fff:	57                   	push   %edi
f0102000:	e8 86 f6 ff ff       	call   f010168b <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102005:	6a 02                	push   $0x2
f0102007:	6a 00                	push   $0x0
f0102009:	56                   	push   %esi
f010200a:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0102010:	e8 98 f8 ff ff       	call   f01018ad <page_insert>
f0102015:	83 c4 20             	add    $0x20,%esp
f0102018:	85 c0                	test   %eax,%eax
f010201a:	74 19                	je     f0102035 <mem_init+0x6d8>
f010201c:	68 f4 79 10 f0       	push   $0xf01079f4
f0102021:	68 17 81 10 f0       	push   $0xf0108117
f0102026:	68 a5 03 00 00       	push   $0x3a5
f010202b:	68 f1 80 10 f0       	push   $0xf01080f1
f0102030:	e8 33 e0 ff ff       	call   f0100068 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102035:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f010203a:	8b 08                	mov    (%eax),%ecx
f010203c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102042:	89 fa                	mov    %edi,%edx
f0102044:	2b 15 90 0e 22 f0    	sub    0xf0220e90,%edx
f010204a:	c1 fa 03             	sar    $0x3,%edx
f010204d:	c1 e2 0c             	shl    $0xc,%edx
f0102050:	39 d1                	cmp    %edx,%ecx
f0102052:	74 19                	je     f010206d <mem_init+0x710>
f0102054:	68 24 7a 10 f0       	push   $0xf0107a24
f0102059:	68 17 81 10 f0       	push   $0xf0108117
f010205e:	68 a6 03 00 00       	push   $0x3a6
f0102063:	68 f1 80 10 f0       	push   $0xf01080f1
f0102068:	e8 fb df ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010206d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102072:	e8 64 f1 ff ff       	call   f01011db <check_va2pa>
f0102077:	89 f2                	mov    %esi,%edx
f0102079:	2b 15 90 0e 22 f0    	sub    0xf0220e90,%edx
f010207f:	c1 fa 03             	sar    $0x3,%edx
f0102082:	c1 e2 0c             	shl    $0xc,%edx
f0102085:	39 d0                	cmp    %edx,%eax
f0102087:	74 19                	je     f01020a2 <mem_init+0x745>
f0102089:	68 4c 7a 10 f0       	push   $0xf0107a4c
f010208e:	68 17 81 10 f0       	push   $0xf0108117
f0102093:	68 a7 03 00 00       	push   $0x3a7
f0102098:	68 f1 80 10 f0       	push   $0xf01080f1
f010209d:	e8 c6 df ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 1);
f01020a2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01020a7:	74 19                	je     f01020c2 <mem_init+0x765>
f01020a9:	68 dc 82 10 f0       	push   $0xf01082dc
f01020ae:	68 17 81 10 f0       	push   $0xf0108117
f01020b3:	68 a8 03 00 00       	push   $0x3a8
f01020b8:	68 f1 80 10 f0       	push   $0xf01080f1
f01020bd:	e8 a6 df ff ff       	call   f0100068 <_panic>
	assert(pp0->pp_ref == 1);
f01020c2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01020c7:	74 19                	je     f01020e2 <mem_init+0x785>
f01020c9:	68 ed 82 10 f0       	push   $0xf01082ed
f01020ce:	68 17 81 10 f0       	push   $0xf0108117
f01020d3:	68 a9 03 00 00       	push   $0x3a9
f01020d8:	68 f1 80 10 f0       	push   $0xf01080f1
f01020dd:	e8 86 df ff ff       	call   f0100068 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020e2:	6a 02                	push   $0x2
f01020e4:	68 00 10 00 00       	push   $0x1000
f01020e9:	53                   	push   %ebx
f01020ea:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f01020f0:	e8 b8 f7 ff ff       	call   f01018ad <page_insert>
f01020f5:	83 c4 10             	add    $0x10,%esp
f01020f8:	85 c0                	test   %eax,%eax
f01020fa:	74 19                	je     f0102115 <mem_init+0x7b8>
f01020fc:	68 7c 7a 10 f0       	push   $0xf0107a7c
f0102101:	68 17 81 10 f0       	push   $0xf0108117
f0102106:	68 ac 03 00 00       	push   $0x3ac
f010210b:	68 f1 80 10 f0       	push   $0xf01080f1
f0102110:	e8 53 df ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102115:	ba 00 10 00 00       	mov    $0x1000,%edx
f010211a:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f010211f:	e8 b7 f0 ff ff       	call   f01011db <check_va2pa>
f0102124:	89 da                	mov    %ebx,%edx
f0102126:	2b 15 90 0e 22 f0    	sub    0xf0220e90,%edx
f010212c:	c1 fa 03             	sar    $0x3,%edx
f010212f:	c1 e2 0c             	shl    $0xc,%edx
f0102132:	39 d0                	cmp    %edx,%eax
f0102134:	74 19                	je     f010214f <mem_init+0x7f2>
f0102136:	68 b8 7a 10 f0       	push   $0xf0107ab8
f010213b:	68 17 81 10 f0       	push   $0xf0108117
f0102140:	68 ad 03 00 00       	push   $0x3ad
f0102145:	68 f1 80 10 f0       	push   $0xf01080f1
f010214a:	e8 19 df ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f010214f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102154:	74 19                	je     f010216f <mem_init+0x812>
f0102156:	68 fe 82 10 f0       	push   $0xf01082fe
f010215b:	68 17 81 10 f0       	push   $0xf0108117
f0102160:	68 ae 03 00 00       	push   $0x3ae
f0102165:	68 f1 80 10 f0       	push   $0xf01080f1
f010216a:	e8 f9 de ff ff       	call   f0100068 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010216f:	83 ec 0c             	sub    $0xc,%esp
f0102172:	6a 00                	push   $0x0
f0102174:	e8 88 f4 ff ff       	call   f0101601 <page_alloc>
f0102179:	83 c4 10             	add    $0x10,%esp
f010217c:	85 c0                	test   %eax,%eax
f010217e:	74 19                	je     f0102199 <mem_init+0x83c>
f0102180:	68 8a 82 10 f0       	push   $0xf010828a
f0102185:	68 17 81 10 f0       	push   $0xf0108117
f010218a:	68 b1 03 00 00       	push   $0x3b1
f010218f:	68 f1 80 10 f0       	push   $0xf01080f1
f0102194:	e8 cf de ff ff       	call   f0100068 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102199:	6a 02                	push   $0x2
f010219b:	68 00 10 00 00       	push   $0x1000
f01021a0:	53                   	push   %ebx
f01021a1:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f01021a7:	e8 01 f7 ff ff       	call   f01018ad <page_insert>
f01021ac:	83 c4 10             	add    $0x10,%esp
f01021af:	85 c0                	test   %eax,%eax
f01021b1:	74 19                	je     f01021cc <mem_init+0x86f>
f01021b3:	68 7c 7a 10 f0       	push   $0xf0107a7c
f01021b8:	68 17 81 10 f0       	push   $0xf0108117
f01021bd:	68 b4 03 00 00       	push   $0x3b4
f01021c2:	68 f1 80 10 f0       	push   $0xf01080f1
f01021c7:	e8 9c de ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021cc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021d1:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f01021d6:	e8 00 f0 ff ff       	call   f01011db <check_va2pa>
f01021db:	89 da                	mov    %ebx,%edx
f01021dd:	2b 15 90 0e 22 f0    	sub    0xf0220e90,%edx
f01021e3:	c1 fa 03             	sar    $0x3,%edx
f01021e6:	c1 e2 0c             	shl    $0xc,%edx
f01021e9:	39 d0                	cmp    %edx,%eax
f01021eb:	74 19                	je     f0102206 <mem_init+0x8a9>
f01021ed:	68 b8 7a 10 f0       	push   $0xf0107ab8
f01021f2:	68 17 81 10 f0       	push   $0xf0108117
f01021f7:	68 b5 03 00 00       	push   $0x3b5
f01021fc:	68 f1 80 10 f0       	push   $0xf01080f1
f0102201:	e8 62 de ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f0102206:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010220b:	74 19                	je     f0102226 <mem_init+0x8c9>
f010220d:	68 fe 82 10 f0       	push   $0xf01082fe
f0102212:	68 17 81 10 f0       	push   $0xf0108117
f0102217:	68 b6 03 00 00       	push   $0x3b6
f010221c:	68 f1 80 10 f0       	push   $0xf01080f1
f0102221:	e8 42 de ff ff       	call   f0100068 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102226:	83 ec 0c             	sub    $0xc,%esp
f0102229:	6a 00                	push   $0x0
f010222b:	e8 d1 f3 ff ff       	call   f0101601 <page_alloc>
f0102230:	83 c4 10             	add    $0x10,%esp
f0102233:	85 c0                	test   %eax,%eax
f0102235:	74 19                	je     f0102250 <mem_init+0x8f3>
f0102237:	68 8a 82 10 f0       	push   $0xf010828a
f010223c:	68 17 81 10 f0       	push   $0xf0108117
f0102241:	68 ba 03 00 00       	push   $0x3ba
f0102246:	68 f1 80 10 f0       	push   $0xf01080f1
f010224b:	e8 18 de ff ff       	call   f0100068 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102250:	8b 15 8c 0e 22 f0    	mov    0xf0220e8c,%edx
f0102256:	8b 02                	mov    (%edx),%eax
f0102258:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010225d:	89 c1                	mov    %eax,%ecx
f010225f:	c1 e9 0c             	shr    $0xc,%ecx
f0102262:	3b 0d 88 0e 22 f0    	cmp    0xf0220e88,%ecx
f0102268:	72 15                	jb     f010227f <mem_init+0x922>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010226a:	50                   	push   %eax
f010226b:	68 88 6d 10 f0       	push   $0xf0106d88
f0102270:	68 bd 03 00 00       	push   $0x3bd
f0102275:	68 f1 80 10 f0       	push   $0xf01080f1
f010227a:	e8 e9 dd ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f010227f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102284:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102287:	83 ec 04             	sub    $0x4,%esp
f010228a:	6a 00                	push   $0x0
f010228c:	68 00 10 00 00       	push   $0x1000
f0102291:	52                   	push   %edx
f0102292:	e8 32 f4 ff ff       	call   f01016c9 <pgdir_walk>
f0102297:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010229a:	83 c2 04             	add    $0x4,%edx
f010229d:	83 c4 10             	add    $0x10,%esp
f01022a0:	39 d0                	cmp    %edx,%eax
f01022a2:	74 19                	je     f01022bd <mem_init+0x960>
f01022a4:	68 e8 7a 10 f0       	push   $0xf0107ae8
f01022a9:	68 17 81 10 f0       	push   $0xf0108117
f01022ae:	68 be 03 00 00       	push   $0x3be
f01022b3:	68 f1 80 10 f0       	push   $0xf01080f1
f01022b8:	e8 ab dd ff ff       	call   f0100068 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01022bd:	6a 06                	push   $0x6
f01022bf:	68 00 10 00 00       	push   $0x1000
f01022c4:	53                   	push   %ebx
f01022c5:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f01022cb:	e8 dd f5 ff ff       	call   f01018ad <page_insert>
f01022d0:	83 c4 10             	add    $0x10,%esp
f01022d3:	85 c0                	test   %eax,%eax
f01022d5:	74 19                	je     f01022f0 <mem_init+0x993>
f01022d7:	68 28 7b 10 f0       	push   $0xf0107b28
f01022dc:	68 17 81 10 f0       	push   $0xf0108117
f01022e1:	68 c1 03 00 00       	push   $0x3c1
f01022e6:	68 f1 80 10 f0       	push   $0xf01080f1
f01022eb:	e8 78 dd ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022f0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022f5:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f01022fa:	e8 dc ee ff ff       	call   f01011db <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022ff:	89 da                	mov    %ebx,%edx
f0102301:	2b 15 90 0e 22 f0    	sub    0xf0220e90,%edx
f0102307:	c1 fa 03             	sar    $0x3,%edx
f010230a:	c1 e2 0c             	shl    $0xc,%edx
f010230d:	39 d0                	cmp    %edx,%eax
f010230f:	74 19                	je     f010232a <mem_init+0x9cd>
f0102311:	68 b8 7a 10 f0       	push   $0xf0107ab8
f0102316:	68 17 81 10 f0       	push   $0xf0108117
f010231b:	68 c2 03 00 00       	push   $0x3c2
f0102320:	68 f1 80 10 f0       	push   $0xf01080f1
f0102325:	e8 3e dd ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f010232a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010232f:	74 19                	je     f010234a <mem_init+0x9ed>
f0102331:	68 fe 82 10 f0       	push   $0xf01082fe
f0102336:	68 17 81 10 f0       	push   $0xf0108117
f010233b:	68 c3 03 00 00       	push   $0x3c3
f0102340:	68 f1 80 10 f0       	push   $0xf01080f1
f0102345:	e8 1e dd ff ff       	call   f0100068 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010234a:	83 ec 04             	sub    $0x4,%esp
f010234d:	6a 00                	push   $0x0
f010234f:	68 00 10 00 00       	push   $0x1000
f0102354:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f010235a:	e8 6a f3 ff ff       	call   f01016c9 <pgdir_walk>
f010235f:	83 c4 10             	add    $0x10,%esp
f0102362:	f6 00 04             	testb  $0x4,(%eax)
f0102365:	75 19                	jne    f0102380 <mem_init+0xa23>
f0102367:	68 68 7b 10 f0       	push   $0xf0107b68
f010236c:	68 17 81 10 f0       	push   $0xf0108117
f0102371:	68 c4 03 00 00       	push   $0x3c4
f0102376:	68 f1 80 10 f0       	push   $0xf01080f1
f010237b:	e8 e8 dc ff ff       	call   f0100068 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102380:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0102385:	f6 00 04             	testb  $0x4,(%eax)
f0102388:	75 19                	jne    f01023a3 <mem_init+0xa46>
f010238a:	68 0f 83 10 f0       	push   $0xf010830f
f010238f:	68 17 81 10 f0       	push   $0xf0108117
f0102394:	68 c5 03 00 00       	push   $0x3c5
f0102399:	68 f1 80 10 f0       	push   $0xf01080f1
f010239e:	e8 c5 dc ff ff       	call   f0100068 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023a3:	6a 02                	push   $0x2
f01023a5:	68 00 10 00 00       	push   $0x1000
f01023aa:	53                   	push   %ebx
f01023ab:	50                   	push   %eax
f01023ac:	e8 fc f4 ff ff       	call   f01018ad <page_insert>
f01023b1:	83 c4 10             	add    $0x10,%esp
f01023b4:	85 c0                	test   %eax,%eax
f01023b6:	74 19                	je     f01023d1 <mem_init+0xa74>
f01023b8:	68 7c 7a 10 f0       	push   $0xf0107a7c
f01023bd:	68 17 81 10 f0       	push   $0xf0108117
f01023c2:	68 c8 03 00 00       	push   $0x3c8
f01023c7:	68 f1 80 10 f0       	push   $0xf01080f1
f01023cc:	e8 97 dc ff ff       	call   f0100068 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01023d1:	83 ec 04             	sub    $0x4,%esp
f01023d4:	6a 00                	push   $0x0
f01023d6:	68 00 10 00 00       	push   $0x1000
f01023db:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f01023e1:	e8 e3 f2 ff ff       	call   f01016c9 <pgdir_walk>
f01023e6:	83 c4 10             	add    $0x10,%esp
f01023e9:	f6 00 02             	testb  $0x2,(%eax)
f01023ec:	75 19                	jne    f0102407 <mem_init+0xaaa>
f01023ee:	68 9c 7b 10 f0       	push   $0xf0107b9c
f01023f3:	68 17 81 10 f0       	push   $0xf0108117
f01023f8:	68 c9 03 00 00       	push   $0x3c9
f01023fd:	68 f1 80 10 f0       	push   $0xf01080f1
f0102402:	e8 61 dc ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102407:	83 ec 04             	sub    $0x4,%esp
f010240a:	6a 00                	push   $0x0
f010240c:	68 00 10 00 00       	push   $0x1000
f0102411:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0102417:	e8 ad f2 ff ff       	call   f01016c9 <pgdir_walk>
f010241c:	83 c4 10             	add    $0x10,%esp
f010241f:	f6 00 04             	testb  $0x4,(%eax)
f0102422:	74 19                	je     f010243d <mem_init+0xae0>
f0102424:	68 d0 7b 10 f0       	push   $0xf0107bd0
f0102429:	68 17 81 10 f0       	push   $0xf0108117
f010242e:	68 ca 03 00 00       	push   $0x3ca
f0102433:	68 f1 80 10 f0       	push   $0xf01080f1
f0102438:	e8 2b dc ff ff       	call   f0100068 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010243d:	6a 02                	push   $0x2
f010243f:	68 00 00 40 00       	push   $0x400000
f0102444:	57                   	push   %edi
f0102445:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f010244b:	e8 5d f4 ff ff       	call   f01018ad <page_insert>
f0102450:	83 c4 10             	add    $0x10,%esp
f0102453:	85 c0                	test   %eax,%eax
f0102455:	78 19                	js     f0102470 <mem_init+0xb13>
f0102457:	68 08 7c 10 f0       	push   $0xf0107c08
f010245c:	68 17 81 10 f0       	push   $0xf0108117
f0102461:	68 cd 03 00 00       	push   $0x3cd
f0102466:	68 f1 80 10 f0       	push   $0xf01080f1
f010246b:	e8 f8 db ff ff       	call   f0100068 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102470:	6a 02                	push   $0x2
f0102472:	68 00 10 00 00       	push   $0x1000
f0102477:	56                   	push   %esi
f0102478:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f010247e:	e8 2a f4 ff ff       	call   f01018ad <page_insert>
f0102483:	83 c4 10             	add    $0x10,%esp
f0102486:	85 c0                	test   %eax,%eax
f0102488:	74 19                	je     f01024a3 <mem_init+0xb46>
f010248a:	68 40 7c 10 f0       	push   $0xf0107c40
f010248f:	68 17 81 10 f0       	push   $0xf0108117
f0102494:	68 d0 03 00 00       	push   $0x3d0
f0102499:	68 f1 80 10 f0       	push   $0xf01080f1
f010249e:	e8 c5 db ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024a3:	83 ec 04             	sub    $0x4,%esp
f01024a6:	6a 00                	push   $0x0
f01024a8:	68 00 10 00 00       	push   $0x1000
f01024ad:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f01024b3:	e8 11 f2 ff ff       	call   f01016c9 <pgdir_walk>
f01024b8:	83 c4 10             	add    $0x10,%esp
f01024bb:	f6 00 04             	testb  $0x4,(%eax)
f01024be:	74 19                	je     f01024d9 <mem_init+0xb7c>
f01024c0:	68 d0 7b 10 f0       	push   $0xf0107bd0
f01024c5:	68 17 81 10 f0       	push   $0xf0108117
f01024ca:	68 d1 03 00 00       	push   $0x3d1
f01024cf:	68 f1 80 10 f0       	push   $0xf01080f1
f01024d4:	e8 8f db ff ff       	call   f0100068 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01024d9:	ba 00 00 00 00       	mov    $0x0,%edx
f01024de:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f01024e3:	e8 f3 ec ff ff       	call   f01011db <check_va2pa>
f01024e8:	89 f2                	mov    %esi,%edx
f01024ea:	2b 15 90 0e 22 f0    	sub    0xf0220e90,%edx
f01024f0:	c1 fa 03             	sar    $0x3,%edx
f01024f3:	c1 e2 0c             	shl    $0xc,%edx
f01024f6:	39 d0                	cmp    %edx,%eax
f01024f8:	74 19                	je     f0102513 <mem_init+0xbb6>
f01024fa:	68 7c 7c 10 f0       	push   $0xf0107c7c
f01024ff:	68 17 81 10 f0       	push   $0xf0108117
f0102504:	68 d4 03 00 00       	push   $0x3d4
f0102509:	68 f1 80 10 f0       	push   $0xf01080f1
f010250e:	e8 55 db ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102513:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102518:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f010251d:	e8 b9 ec ff ff       	call   f01011db <check_va2pa>
f0102522:	89 f2                	mov    %esi,%edx
f0102524:	2b 15 90 0e 22 f0    	sub    0xf0220e90,%edx
f010252a:	c1 fa 03             	sar    $0x3,%edx
f010252d:	c1 e2 0c             	shl    $0xc,%edx
f0102530:	39 d0                	cmp    %edx,%eax
f0102532:	74 19                	je     f010254d <mem_init+0xbf0>
f0102534:	68 a8 7c 10 f0       	push   $0xf0107ca8
f0102539:	68 17 81 10 f0       	push   $0xf0108117
f010253e:	68 d5 03 00 00       	push   $0x3d5
f0102543:	68 f1 80 10 f0       	push   $0xf01080f1
f0102548:	e8 1b db ff ff       	call   f0100068 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010254d:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102552:	74 19                	je     f010256d <mem_init+0xc10>
f0102554:	68 25 83 10 f0       	push   $0xf0108325
f0102559:	68 17 81 10 f0       	push   $0xf0108117
f010255e:	68 d7 03 00 00       	push   $0x3d7
f0102563:	68 f1 80 10 f0       	push   $0xf01080f1
f0102568:	e8 fb da ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f010256d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102572:	74 19                	je     f010258d <mem_init+0xc30>
f0102574:	68 36 83 10 f0       	push   $0xf0108336
f0102579:	68 17 81 10 f0       	push   $0xf0108117
f010257e:	68 d8 03 00 00       	push   $0x3d8
f0102583:	68 f1 80 10 f0       	push   $0xf01080f1
f0102588:	e8 db da ff ff       	call   f0100068 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010258d:	83 ec 0c             	sub    $0xc,%esp
f0102590:	6a 00                	push   $0x0
f0102592:	e8 6a f0 ff ff       	call   f0101601 <page_alloc>
f0102597:	83 c4 10             	add    $0x10,%esp
f010259a:	85 c0                	test   %eax,%eax
f010259c:	74 04                	je     f01025a2 <mem_init+0xc45>
f010259e:	39 c3                	cmp    %eax,%ebx
f01025a0:	74 19                	je     f01025bb <mem_init+0xc5e>
f01025a2:	68 d8 7c 10 f0       	push   $0xf0107cd8
f01025a7:	68 17 81 10 f0       	push   $0xf0108117
f01025ac:	68 db 03 00 00       	push   $0x3db
f01025b1:	68 f1 80 10 f0       	push   $0xf01080f1
f01025b6:	e8 ad da ff ff       	call   f0100068 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01025bb:	83 ec 08             	sub    $0x8,%esp
f01025be:	6a 00                	push   $0x0
f01025c0:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f01025c6:	e8 95 f2 ff ff       	call   f0101860 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025cb:	ba 00 00 00 00       	mov    $0x0,%edx
f01025d0:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f01025d5:	e8 01 ec ff ff       	call   f01011db <check_va2pa>
f01025da:	83 c4 10             	add    $0x10,%esp
f01025dd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025e0:	74 19                	je     f01025fb <mem_init+0xc9e>
f01025e2:	68 fc 7c 10 f0       	push   $0xf0107cfc
f01025e7:	68 17 81 10 f0       	push   $0xf0108117
f01025ec:	68 df 03 00 00       	push   $0x3df
f01025f1:	68 f1 80 10 f0       	push   $0xf01080f1
f01025f6:	e8 6d da ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025fb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102600:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0102605:	e8 d1 eb ff ff       	call   f01011db <check_va2pa>
f010260a:	89 f2                	mov    %esi,%edx
f010260c:	2b 15 90 0e 22 f0    	sub    0xf0220e90,%edx
f0102612:	c1 fa 03             	sar    $0x3,%edx
f0102615:	c1 e2 0c             	shl    $0xc,%edx
f0102618:	39 d0                	cmp    %edx,%eax
f010261a:	74 19                	je     f0102635 <mem_init+0xcd8>
f010261c:	68 a8 7c 10 f0       	push   $0xf0107ca8
f0102621:	68 17 81 10 f0       	push   $0xf0108117
f0102626:	68 e0 03 00 00       	push   $0x3e0
f010262b:	68 f1 80 10 f0       	push   $0xf01080f1
f0102630:	e8 33 da ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 1);
f0102635:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010263a:	74 19                	je     f0102655 <mem_init+0xcf8>
f010263c:	68 dc 82 10 f0       	push   $0xf01082dc
f0102641:	68 17 81 10 f0       	push   $0xf0108117
f0102646:	68 e1 03 00 00       	push   $0x3e1
f010264b:	68 f1 80 10 f0       	push   $0xf01080f1
f0102650:	e8 13 da ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f0102655:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010265a:	74 19                	je     f0102675 <mem_init+0xd18>
f010265c:	68 36 83 10 f0       	push   $0xf0108336
f0102661:	68 17 81 10 f0       	push   $0xf0108117
f0102666:	68 e2 03 00 00       	push   $0x3e2
f010266b:	68 f1 80 10 f0       	push   $0xf01080f1
f0102670:	e8 f3 d9 ff ff       	call   f0100068 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102675:	83 ec 08             	sub    $0x8,%esp
f0102678:	68 00 10 00 00       	push   $0x1000
f010267d:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0102683:	e8 d8 f1 ff ff       	call   f0101860 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102688:	ba 00 00 00 00       	mov    $0x0,%edx
f010268d:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0102692:	e8 44 eb ff ff       	call   f01011db <check_va2pa>
f0102697:	83 c4 10             	add    $0x10,%esp
f010269a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010269d:	74 19                	je     f01026b8 <mem_init+0xd5b>
f010269f:	68 fc 7c 10 f0       	push   $0xf0107cfc
f01026a4:	68 17 81 10 f0       	push   $0xf0108117
f01026a9:	68 e6 03 00 00       	push   $0x3e6
f01026ae:	68 f1 80 10 f0       	push   $0xf01080f1
f01026b3:	e8 b0 d9 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01026b8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01026bd:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f01026c2:	e8 14 eb ff ff       	call   f01011db <check_va2pa>
f01026c7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026ca:	74 19                	je     f01026e5 <mem_init+0xd88>
f01026cc:	68 20 7d 10 f0       	push   $0xf0107d20
f01026d1:	68 17 81 10 f0       	push   $0xf0108117
f01026d6:	68 e7 03 00 00       	push   $0x3e7
f01026db:	68 f1 80 10 f0       	push   $0xf01080f1
f01026e0:	e8 83 d9 ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 0);
f01026e5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026ea:	74 19                	je     f0102705 <mem_init+0xda8>
f01026ec:	68 47 83 10 f0       	push   $0xf0108347
f01026f1:	68 17 81 10 f0       	push   $0xf0108117
f01026f6:	68 e8 03 00 00       	push   $0x3e8
f01026fb:	68 f1 80 10 f0       	push   $0xf01080f1
f0102700:	e8 63 d9 ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f0102705:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010270a:	74 19                	je     f0102725 <mem_init+0xdc8>
f010270c:	68 36 83 10 f0       	push   $0xf0108336
f0102711:	68 17 81 10 f0       	push   $0xf0108117
f0102716:	68 e9 03 00 00       	push   $0x3e9
f010271b:	68 f1 80 10 f0       	push   $0xf01080f1
f0102720:	e8 43 d9 ff ff       	call   f0100068 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102725:	83 ec 0c             	sub    $0xc,%esp
f0102728:	6a 00                	push   $0x0
f010272a:	e8 d2 ee ff ff       	call   f0101601 <page_alloc>
f010272f:	83 c4 10             	add    $0x10,%esp
f0102732:	85 c0                	test   %eax,%eax
f0102734:	74 04                	je     f010273a <mem_init+0xddd>
f0102736:	39 c6                	cmp    %eax,%esi
f0102738:	74 19                	je     f0102753 <mem_init+0xdf6>
f010273a:	68 48 7d 10 f0       	push   $0xf0107d48
f010273f:	68 17 81 10 f0       	push   $0xf0108117
f0102744:	68 ec 03 00 00       	push   $0x3ec
f0102749:	68 f1 80 10 f0       	push   $0xf01080f1
f010274e:	e8 15 d9 ff ff       	call   f0100068 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102753:	83 ec 0c             	sub    $0xc,%esp
f0102756:	6a 00                	push   $0x0
f0102758:	e8 a4 ee ff ff       	call   f0101601 <page_alloc>
f010275d:	83 c4 10             	add    $0x10,%esp
f0102760:	85 c0                	test   %eax,%eax
f0102762:	74 19                	je     f010277d <mem_init+0xe20>
f0102764:	68 8a 82 10 f0       	push   $0xf010828a
f0102769:	68 17 81 10 f0       	push   $0xf0108117
f010276e:	68 ef 03 00 00       	push   $0x3ef
f0102773:	68 f1 80 10 f0       	push   $0xf01080f1
f0102778:	e8 eb d8 ff ff       	call   f0100068 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010277d:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0102782:	8b 08                	mov    (%eax),%ecx
f0102784:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010278a:	89 fa                	mov    %edi,%edx
f010278c:	2b 15 90 0e 22 f0    	sub    0xf0220e90,%edx
f0102792:	c1 fa 03             	sar    $0x3,%edx
f0102795:	c1 e2 0c             	shl    $0xc,%edx
f0102798:	39 d1                	cmp    %edx,%ecx
f010279a:	74 19                	je     f01027b5 <mem_init+0xe58>
f010279c:	68 24 7a 10 f0       	push   $0xf0107a24
f01027a1:	68 17 81 10 f0       	push   $0xf0108117
f01027a6:	68 f2 03 00 00       	push   $0x3f2
f01027ab:	68 f1 80 10 f0       	push   $0xf01080f1
f01027b0:	e8 b3 d8 ff ff       	call   f0100068 <_panic>
	kern_pgdir[0] = 0;
f01027b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01027bb:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01027c0:	74 19                	je     f01027db <mem_init+0xe7e>
f01027c2:	68 ed 82 10 f0       	push   $0xf01082ed
f01027c7:	68 17 81 10 f0       	push   $0xf0108117
f01027cc:	68 f4 03 00 00       	push   $0x3f4
f01027d1:	68 f1 80 10 f0       	push   $0xf01080f1
f01027d6:	e8 8d d8 ff ff       	call   f0100068 <_panic>
	pp0->pp_ref = 0;

	kern_pgdir[PDX(va)] = 0;
f01027db:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f01027e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01027e6:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
f01027ec:	89 f8                	mov    %edi,%eax
f01027ee:	2b 05 90 0e 22 f0    	sub    0xf0220e90,%eax
f01027f4:	c1 f8 03             	sar    $0x3,%eax
f01027f7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027fa:	89 c2                	mov    %eax,%edx
f01027fc:	c1 ea 0c             	shr    $0xc,%edx
f01027ff:	3b 15 88 0e 22 f0    	cmp    0xf0220e88,%edx
f0102805:	72 12                	jb     f0102819 <mem_init+0xebc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102807:	50                   	push   %eax
f0102808:	68 88 6d 10 f0       	push   $0xf0106d88
f010280d:	6a 58                	push   $0x58
f010280f:	68 fd 80 10 f0       	push   $0xf01080fd
f0102814:	e8 4f d8 ff ff       	call   f0100068 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102819:	83 ec 04             	sub    $0x4,%esp
f010281c:	68 00 10 00 00       	push   $0x1000
f0102821:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102826:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010282b:	50                   	push   %eax
f010282c:	e8 18 38 00 00       	call   f0106049 <memset>
	page_free(pp0);
f0102831:	89 3c 24             	mov    %edi,(%esp)
f0102834:	e8 52 ee ff ff       	call   f010168b <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102839:	83 c4 0c             	add    $0xc,%esp
f010283c:	6a 01                	push   $0x1
f010283e:	6a 00                	push   $0x0
f0102840:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0102846:	e8 7e ee ff ff       	call   f01016c9 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010284b:	89 fa                	mov    %edi,%edx
f010284d:	2b 15 90 0e 22 f0    	sub    0xf0220e90,%edx
f0102853:	c1 fa 03             	sar    $0x3,%edx
f0102856:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102859:	89 d0                	mov    %edx,%eax
f010285b:	c1 e8 0c             	shr    $0xc,%eax
f010285e:	83 c4 10             	add    $0x10,%esp
f0102861:	3b 05 88 0e 22 f0    	cmp    0xf0220e88,%eax
f0102867:	72 12                	jb     f010287b <mem_init+0xf1e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102869:	52                   	push   %edx
f010286a:	68 88 6d 10 f0       	push   $0xf0106d88
f010286f:	6a 58                	push   $0x58
f0102871:	68 fd 80 10 f0       	push   $0xf01080fd
f0102876:	e8 ed d7 ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f010287b:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102881:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102884:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f010288b:	75 11                	jne    f010289e <mem_init+0xf41>
f010288d:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102893:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102899:	f6 00 01             	testb  $0x1,(%eax)
f010289c:	74 19                	je     f01028b7 <mem_init+0xf5a>
f010289e:	68 58 83 10 f0       	push   $0xf0108358
f01028a3:	68 17 81 10 f0       	push   $0xf0108117
f01028a8:	68 00 04 00 00       	push   $0x400
f01028ad:	68 f1 80 10 f0       	push   $0xf01080f1
f01028b2:	e8 b1 d7 ff ff       	call   f0100068 <_panic>
f01028b7:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01028ba:	39 d0                	cmp    %edx,%eax
f01028bc:	75 db                	jne    f0102899 <mem_init+0xf3c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01028be:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f01028c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01028c9:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01028cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028d2:	a3 30 02 22 f0       	mov    %eax,0xf0220230

	// free the pages we took
	page_free(pp0);
f01028d7:	83 ec 0c             	sub    $0xc,%esp
f01028da:	57                   	push   %edi
f01028db:	e8 ab ed ff ff       	call   f010168b <page_free>
	page_free(pp1);
f01028e0:	89 34 24             	mov    %esi,(%esp)
f01028e3:	e8 a3 ed ff ff       	call   f010168b <page_free>
	page_free(pp2);
f01028e8:	89 1c 24             	mov    %ebx,(%esp)
f01028eb:	e8 9b ed ff ff       	call   f010168b <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01028f0:	83 c4 08             	add    $0x8,%esp
f01028f3:	68 01 10 00 00       	push   $0x1001
f01028f8:	6a 00                	push   $0x0
f01028fa:	e8 17 f0 ff ff       	call   f0101916 <mmio_map_region>
f01028ff:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102901:	83 c4 08             	add    $0x8,%esp
f0102904:	68 00 10 00 00       	push   $0x1000
f0102909:	6a 00                	push   $0x0
f010290b:	e8 06 f0 ff ff       	call   f0101916 <mmio_map_region>
f0102910:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102912:	83 c4 10             	add    $0x10,%esp
f0102915:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010291b:	76 0d                	jbe    f010292a <mem_init+0xfcd>
f010291d:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102923:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102928:	76 19                	jbe    f0102943 <mem_init+0xfe6>
f010292a:	68 6c 7d 10 f0       	push   $0xf0107d6c
f010292f:	68 17 81 10 f0       	push   $0xf0108117
f0102934:	68 10 04 00 00       	push   $0x410
f0102939:	68 f1 80 10 f0       	push   $0xf01080f1
f010293e:	e8 25 d7 ff ff       	call   f0100068 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102943:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102949:	76 0e                	jbe    f0102959 <mem_init+0xffc>
f010294b:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102951:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102957:	76 19                	jbe    f0102972 <mem_init+0x1015>
f0102959:	68 94 7d 10 f0       	push   $0xf0107d94
f010295e:	68 17 81 10 f0       	push   $0xf0108117
f0102963:	68 11 04 00 00       	push   $0x411
f0102968:	68 f1 80 10 f0       	push   $0xf01080f1
f010296d:	e8 f6 d6 ff ff       	call   f0100068 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102972:	89 da                	mov    %ebx,%edx
f0102974:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102976:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010297c:	74 19                	je     f0102997 <mem_init+0x103a>
f010297e:	68 bc 7d 10 f0       	push   $0xf0107dbc
f0102983:	68 17 81 10 f0       	push   $0xf0108117
f0102988:	68 13 04 00 00       	push   $0x413
f010298d:	68 f1 80 10 f0       	push   $0xf01080f1
f0102992:	e8 d1 d6 ff ff       	call   f0100068 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102997:	39 c6                	cmp    %eax,%esi
f0102999:	73 19                	jae    f01029b4 <mem_init+0x1057>
f010299b:	68 6f 83 10 f0       	push   $0xf010836f
f01029a0:	68 17 81 10 f0       	push   $0xf0108117
f01029a5:	68 15 04 00 00       	push   $0x415
f01029aa:	68 f1 80 10 f0       	push   $0xf01080f1
f01029af:	e8 b4 d6 ff ff       	call   f0100068 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01029b4:	89 da                	mov    %ebx,%edx
f01029b6:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f01029bb:	e8 1b e8 ff ff       	call   f01011db <check_va2pa>
f01029c0:	85 c0                	test   %eax,%eax
f01029c2:	74 19                	je     f01029dd <mem_init+0x1080>
f01029c4:	68 e4 7d 10 f0       	push   $0xf0107de4
f01029c9:	68 17 81 10 f0       	push   $0xf0108117
f01029ce:	68 17 04 00 00       	push   $0x417
f01029d3:	68 f1 80 10 f0       	push   $0xf01080f1
f01029d8:	e8 8b d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01029dd:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
f01029e3:	89 fa                	mov    %edi,%edx
f01029e5:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f01029ea:	e8 ec e7 ff ff       	call   f01011db <check_va2pa>
f01029ef:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01029f4:	74 19                	je     f0102a0f <mem_init+0x10b2>
f01029f6:	68 08 7e 10 f0       	push   $0xf0107e08
f01029fb:	68 17 81 10 f0       	push   $0xf0108117
f0102a00:	68 18 04 00 00       	push   $0x418
f0102a05:	68 f1 80 10 f0       	push   $0xf01080f1
f0102a0a:	e8 59 d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102a0f:	89 f2                	mov    %esi,%edx
f0102a11:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0102a16:	e8 c0 e7 ff ff       	call   f01011db <check_va2pa>
f0102a1b:	85 c0                	test   %eax,%eax
f0102a1d:	74 19                	je     f0102a38 <mem_init+0x10db>
f0102a1f:	68 38 7e 10 f0       	push   $0xf0107e38
f0102a24:	68 17 81 10 f0       	push   $0xf0108117
f0102a29:	68 19 04 00 00       	push   $0x419
f0102a2e:	68 f1 80 10 f0       	push   $0xf01080f1
f0102a33:	e8 30 d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a38:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102a3e:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0102a43:	e8 93 e7 ff ff       	call   f01011db <check_va2pa>
f0102a48:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a4b:	74 19                	je     f0102a66 <mem_init+0x1109>
f0102a4d:	68 5c 7e 10 f0       	push   $0xf0107e5c
f0102a52:	68 17 81 10 f0       	push   $0xf0108117
f0102a57:	68 1a 04 00 00       	push   $0x41a
f0102a5c:	68 f1 80 10 f0       	push   $0xf01080f1
f0102a61:	e8 02 d6 ff ff       	call   f0100068 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102a66:	83 ec 04             	sub    $0x4,%esp
f0102a69:	6a 00                	push   $0x0
f0102a6b:	53                   	push   %ebx
f0102a6c:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0102a72:	e8 52 ec ff ff       	call   f01016c9 <pgdir_walk>
f0102a77:	83 c4 10             	add    $0x10,%esp
f0102a7a:	f6 00 1a             	testb  $0x1a,(%eax)
f0102a7d:	75 19                	jne    f0102a98 <mem_init+0x113b>
f0102a7f:	68 88 7e 10 f0       	push   $0xf0107e88
f0102a84:	68 17 81 10 f0       	push   $0xf0108117
f0102a89:	68 1c 04 00 00       	push   $0x41c
f0102a8e:	68 f1 80 10 f0       	push   $0xf01080f1
f0102a93:	e8 d0 d5 ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a98:	83 ec 04             	sub    $0x4,%esp
f0102a9b:	6a 00                	push   $0x0
f0102a9d:	53                   	push   %ebx
f0102a9e:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0102aa4:	e8 20 ec ff ff       	call   f01016c9 <pgdir_walk>
f0102aa9:	83 c4 10             	add    $0x10,%esp
f0102aac:	f6 00 04             	testb  $0x4,(%eax)
f0102aaf:	74 19                	je     f0102aca <mem_init+0x116d>
f0102ab1:	68 cc 7e 10 f0       	push   $0xf0107ecc
f0102ab6:	68 17 81 10 f0       	push   $0xf0108117
f0102abb:	68 1d 04 00 00       	push   $0x41d
f0102ac0:	68 f1 80 10 f0       	push   $0xf01080f1
f0102ac5:	e8 9e d5 ff ff       	call   f0100068 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102aca:	83 ec 04             	sub    $0x4,%esp
f0102acd:	6a 00                	push   $0x0
f0102acf:	53                   	push   %ebx
f0102ad0:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0102ad6:	e8 ee eb ff ff       	call   f01016c9 <pgdir_walk>
f0102adb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102ae1:	83 c4 0c             	add    $0xc,%esp
f0102ae4:	6a 00                	push   $0x0
f0102ae6:	57                   	push   %edi
f0102ae7:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0102aed:	e8 d7 eb ff ff       	call   f01016c9 <pgdir_walk>
f0102af2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102af8:	83 c4 0c             	add    $0xc,%esp
f0102afb:	6a 00                	push   $0x0
f0102afd:	56                   	push   %esi
f0102afe:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0102b04:	e8 c0 eb ff ff       	call   f01016c9 <pgdir_walk>
f0102b09:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102b0f:	c7 04 24 81 83 10 f0 	movl   $0xf0108381,(%esp)
f0102b16:	e8 46 13 00 00       	call   f0103e61 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102b1b:	a1 90 0e 22 f0       	mov    0xf0220e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b20:	83 c4 10             	add    $0x10,%esp
f0102b23:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b28:	77 15                	ja     f0102b3f <mem_init+0x11e2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b2a:	50                   	push   %eax
f0102b2b:	68 64 6d 10 f0       	push   $0xf0106d64
f0102b30:	68 b9 00 00 00       	push   $0xb9
f0102b35:	68 f1 80 10 f0       	push   $0xf01080f1
f0102b3a:	e8 29 d5 ff ff       	call   f0100068 <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102b3f:	8b 15 88 0e 22 f0    	mov    0xf0220e88,%edx
f0102b45:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102b4c:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102b4f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102b55:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102b57:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b5c:	50                   	push   %eax
f0102b5d:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102b62:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0102b67:	e8 f4 eb ff ff       	call   f0101760 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    boot_map_region(kern_pgdir,
f0102b6c:	a1 3c 02 22 f0       	mov    0xf022023c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b71:	83 c4 10             	add    $0x10,%esp
f0102b74:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b79:	77 15                	ja     f0102b90 <mem_init+0x1233>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b7b:	50                   	push   %eax
f0102b7c:	68 64 6d 10 f0       	push   $0xf0106d64
f0102b81:	68 c6 00 00 00       	push   $0xc6
f0102b86:	68 f1 80 10 f0       	push   $0xf01080f1
f0102b8b:	e8 d8 d4 ff ff       	call   f0100068 <_panic>
f0102b90:	83 ec 08             	sub    $0x8,%esp
f0102b93:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102b95:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b9a:	50                   	push   %eax
f0102b9b:	b9 00 10 02 00       	mov    $0x21000,%ecx
f0102ba0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102ba5:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0102baa:	e8 b1 eb ff ff       	call   f0101760 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102baf:	83 c4 10             	add    $0x10,%esp
f0102bb2:	b8 00 f0 11 f0       	mov    $0xf011f000,%eax
f0102bb7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bbc:	77 15                	ja     f0102bd3 <mem_init+0x1276>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bbe:	50                   	push   %eax
f0102bbf:	68 64 6d 10 f0       	push   $0xf0106d64
f0102bc4:	68 d7 00 00 00       	push   $0xd7
f0102bc9:	68 f1 80 10 f0       	push   $0xf01080f1
f0102bce:	e8 95 d4 ff ff       	call   f0100068 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102bd3:	83 ec 08             	sub    $0x8,%esp
f0102bd6:	6a 02                	push   $0x2
f0102bd8:	68 00 f0 11 00       	push   $0x11f000
f0102bdd:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102be2:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102be7:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0102bec:	e8 6f eb ff ff       	call   f0101760 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102bf1:	83 c4 08             	add    $0x8,%esp
f0102bf4:	6a 02                	push   $0x2
f0102bf6:	6a 00                	push   $0x0
f0102bf8:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102bfd:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102c02:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0102c07:	e8 54 eb ff ff       	call   f0101760 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c0c:	83 c4 10             	add    $0x10,%esp
f0102c0f:	b8 00 20 22 f0       	mov    $0xf0222000,%eax
f0102c14:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c19:	0f 87 60 06 00 00    	ja     f010327f <mem_init+0x1922>
f0102c1f:	eb 0c                	jmp    f0102c2d <mem_init+0x12d0>
f0102c21:	89 d8                	mov    %ebx,%eax
f0102c23:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102c29:	77 1c                	ja     f0102c47 <mem_init+0x12ea>
f0102c2b:	eb 05                	jmp    f0102c32 <mem_init+0x12d5>
	//
	// LAB 4: Your code here:
    
    int cpu_id;
    for (cpu_id = 0; cpu_id < NCPU; cpu_id++) {
        boot_map_region(kern_pgdir,
f0102c2d:	b8 00 20 22 f0       	mov    $0xf0222000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c32:	50                   	push   %eax
f0102c33:	68 64 6d 10 f0       	push   $0xf0106d64
f0102c38:	68 24 01 00 00       	push   $0x124
f0102c3d:	68 f1 80 10 f0       	push   $0xf01080f1
f0102c42:	e8 21 d4 ff ff       	call   f0100068 <_panic>
f0102c47:	83 ec 08             	sub    $0x8,%esp
f0102c4a:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f0102c4c:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102c52:	50                   	push   %eax
f0102c53:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102c58:	89 f2                	mov    %esi,%edx
f0102c5a:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0102c5f:	e8 fc ea ff ff       	call   f0101760 <boot_map_region>
f0102c64:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102c6a:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
    
    int cpu_id;
    for (cpu_id = 0; cpu_id < NCPU; cpu_id++) {
f0102c70:	83 c4 10             	add    $0x10,%esp
f0102c73:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102c79:	75 a6                	jne    f0102c21 <mem_init+0x12c4>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102c7b:	8b 35 8c 0e 22 f0    	mov    0xf0220e8c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102c81:	a1 88 0e 22 f0       	mov    0xf0220e88,%eax
f0102c86:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102c8d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102c93:	74 63                	je     f0102cf8 <mem_init+0x139b>
f0102c95:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102c9a:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102ca0:	89 f0                	mov    %esi,%eax
f0102ca2:	e8 34 e5 ff ff       	call   f01011db <check_va2pa>
f0102ca7:	8b 15 90 0e 22 f0    	mov    0xf0220e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cad:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102cb3:	77 15                	ja     f0102cca <mem_init+0x136d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cb5:	52                   	push   %edx
f0102cb6:	68 64 6d 10 f0       	push   $0xf0106d64
f0102cbb:	68 40 03 00 00       	push   $0x340
f0102cc0:	68 f1 80 10 f0       	push   $0xf01080f1
f0102cc5:	e8 9e d3 ff ff       	call   f0100068 <_panic>
f0102cca:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0102cd1:	39 d0                	cmp    %edx,%eax
f0102cd3:	74 19                	je     f0102cee <mem_init+0x1391>
f0102cd5:	68 00 7f 10 f0       	push   $0xf0107f00
f0102cda:	68 17 81 10 f0       	push   $0xf0108117
f0102cdf:	68 40 03 00 00       	push   $0x340
f0102ce4:	68 f1 80 10 f0       	push   $0xf01080f1
f0102ce9:	e8 7a d3 ff ff       	call   f0100068 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102cee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102cf4:	39 df                	cmp    %ebx,%edi
f0102cf6:	77 a2                	ja     f0102c9a <mem_init+0x133d>
f0102cf8:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102cfd:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
f0102d03:	89 f0                	mov    %esi,%eax
f0102d05:	e8 d1 e4 ff ff       	call   f01011db <check_va2pa>
f0102d0a:	8b 15 3c 02 22 f0    	mov    0xf022023c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d10:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d16:	77 15                	ja     f0102d2d <mem_init+0x13d0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d18:	52                   	push   %edx
f0102d19:	68 64 6d 10 f0       	push   $0xf0106d64
f0102d1e:	68 45 03 00 00       	push   $0x345
f0102d23:	68 f1 80 10 f0       	push   $0xf01080f1
f0102d28:	e8 3b d3 ff ff       	call   f0100068 <_panic>
f0102d2d:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0102d34:	39 d0                	cmp    %edx,%eax
f0102d36:	74 19                	je     f0102d51 <mem_init+0x13f4>
f0102d38:	68 34 7f 10 f0       	push   $0xf0107f34
f0102d3d:	68 17 81 10 f0       	push   $0xf0108117
f0102d42:	68 45 03 00 00       	push   $0x345
f0102d47:	68 f1 80 10 f0       	push   $0xf01080f1
f0102d4c:	e8 17 d3 ff ff       	call   f0100068 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102d51:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d57:	81 fb 00 10 02 00    	cmp    $0x21000,%ebx
f0102d5d:	75 9e                	jne    f0102cfd <mem_init+0x13a0>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d5f:	a1 88 0e 22 f0       	mov    0xf0220e88,%eax
f0102d64:	c1 e0 0c             	shl    $0xc,%eax
f0102d67:	74 41                	je     f0102daa <mem_init+0x144d>
f0102d69:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102d6e:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102d74:	89 f0                	mov    %esi,%eax
f0102d76:	e8 60 e4 ff ff       	call   f01011db <check_va2pa>
f0102d7b:	39 c3                	cmp    %eax,%ebx
f0102d7d:	74 19                	je     f0102d98 <mem_init+0x143b>
f0102d7f:	68 68 7f 10 f0       	push   $0xf0107f68
f0102d84:	68 17 81 10 f0       	push   $0xf0108117
f0102d89:	68 49 03 00 00       	push   $0x349
f0102d8e:	68 f1 80 10 f0       	push   $0xf01080f1
f0102d93:	e8 d0 d2 ff ff       	call   f0100068 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d98:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d9e:	a1 88 0e 22 f0       	mov    0xf0220e88,%eax
f0102da3:	c1 e0 0c             	shl    $0xc,%eax
f0102da6:	39 c3                	cmp    %eax,%ebx
f0102da8:	72 c4                	jb     f0102d6e <mem_init+0x1411>
f0102daa:	c7 45 d0 00 20 22 f0 	movl   $0xf0222000,-0x30(%ebp)
f0102db1:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0102db6:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102db9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	return (physaddr_t)kva - KERNBASE;
f0102dbc:	89 de                	mov    %ebx,%esi
f0102dbe:	81 c6 00 00 00 10    	add    $0x10000000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102dc4:	8d 97 00 80 00 00    	lea    0x8000(%edi),%edx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102dca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102dcd:	e8 09 e4 ff ff       	call   f01011db <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dd2:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102dd9:	77 15                	ja     f0102df0 <mem_init+0x1493>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ddb:	53                   	push   %ebx
f0102ddc:	68 64 6d 10 f0       	push   $0xf0106d64
f0102de1:	68 51 03 00 00       	push   $0x351
f0102de6:	68 f1 80 10 f0       	push   $0xf01080f1
f0102deb:	e8 78 d2 ff ff       	call   f0100068 <_panic>

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102df0:	bb 00 00 00 00       	mov    $0x0,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102df5:	8d 97 00 80 00 00    	lea    0x8000(%edi),%edx
f0102dfb:	89 7d c8             	mov    %edi,-0x38(%ebp)
f0102dfe:	89 d7                	mov    %edx,%edi
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e00:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102e03:	39 d0                	cmp    %edx,%eax
f0102e05:	74 19                	je     f0102e20 <mem_init+0x14c3>
f0102e07:	68 90 7f 10 f0       	push   $0xf0107f90
f0102e0c:	68 17 81 10 f0       	push   $0xf0108117
f0102e11:	68 51 03 00 00       	push   $0x351
f0102e16:	68 f1 80 10 f0       	push   $0xf01080f1
f0102e1b:	e8 48 d2 ff ff       	call   f0100068 <_panic>

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102e20:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e26:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102e2c:	0f 85 7d 04 00 00    	jne    f01032af <mem_init+0x1952>
f0102e32:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102e35:	66 bb 00 00          	mov    $0x0,%bx
f0102e39:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102e3c:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102e3f:	89 f0                	mov    %esi,%eax
f0102e41:	e8 95 e3 ff ff       	call   f01011db <check_va2pa>
f0102e46:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102e49:	74 19                	je     f0102e64 <mem_init+0x1507>
f0102e4b:	68 d8 7f 10 f0       	push   $0xf0107fd8
f0102e50:	68 17 81 10 f0       	push   $0xf0108117
f0102e55:	68 53 03 00 00       	push   $0x353
f0102e5a:	68 f1 80 10 f0       	push   $0xf01080f1
f0102e5f:	e8 04 d2 ff ff       	call   f0100068 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102e64:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e6a:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102e70:	75 ca                	jne    f0102e3c <mem_init+0x14df>
f0102e72:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102e79:	81 ef 00 00 01 00    	sub    $0x10000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102e7f:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f0102e85:	0f 85 2e ff ff ff    	jne    f0102db9 <mem_init+0x145c>
f0102e8b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102e8e:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102e93:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102e99:	83 fa 04             	cmp    $0x4,%edx
f0102e9c:	77 1f                	ja     f0102ebd <mem_init+0x1560>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102e9e:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102ea2:	75 7e                	jne    f0102f22 <mem_init+0x15c5>
f0102ea4:	68 9a 83 10 f0       	push   $0xf010839a
f0102ea9:	68 17 81 10 f0       	push   $0xf0108117
f0102eae:	68 5e 03 00 00       	push   $0x35e
f0102eb3:	68 f1 80 10 f0       	push   $0xf01080f1
f0102eb8:	e8 ab d1 ff ff       	call   f0100068 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102ebd:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ec2:	76 3f                	jbe    f0102f03 <mem_init+0x15a6>
				assert(pgdir[i] & PTE_P);
f0102ec4:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102ec7:	f6 c2 01             	test   $0x1,%dl
f0102eca:	75 19                	jne    f0102ee5 <mem_init+0x1588>
f0102ecc:	68 9a 83 10 f0       	push   $0xf010839a
f0102ed1:	68 17 81 10 f0       	push   $0xf0108117
f0102ed6:	68 62 03 00 00       	push   $0x362
f0102edb:	68 f1 80 10 f0       	push   $0xf01080f1
f0102ee0:	e8 83 d1 ff ff       	call   f0100068 <_panic>
				assert(pgdir[i] & PTE_W);
f0102ee5:	f6 c2 02             	test   $0x2,%dl
f0102ee8:	75 38                	jne    f0102f22 <mem_init+0x15c5>
f0102eea:	68 ab 83 10 f0       	push   $0xf01083ab
f0102eef:	68 17 81 10 f0       	push   $0xf0108117
f0102ef4:	68 63 03 00 00       	push   $0x363
f0102ef9:	68 f1 80 10 f0       	push   $0xf01080f1
f0102efe:	e8 65 d1 ff ff       	call   f0100068 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102f03:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102f07:	74 19                	je     f0102f22 <mem_init+0x15c5>
f0102f09:	68 bc 83 10 f0       	push   $0xf01083bc
f0102f0e:	68 17 81 10 f0       	push   $0xf0108117
f0102f13:	68 65 03 00 00       	push   $0x365
f0102f18:	68 f1 80 10 f0       	push   $0xf01080f1
f0102f1d:	e8 46 d1 ff ff       	call   f0100068 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102f22:	40                   	inc    %eax
f0102f23:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102f28:	0f 85 65 ff ff ff    	jne    f0102e93 <mem_init+0x1536>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102f2e:	83 ec 0c             	sub    $0xc,%esp
f0102f31:	68 fc 7f 10 f0       	push   $0xf0107ffc
f0102f36:	e8 26 0f 00 00       	call   f0103e61 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102f3b:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f40:	83 c4 10             	add    $0x10,%esp
f0102f43:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f48:	77 15                	ja     f0102f5f <mem_init+0x1602>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f4a:	50                   	push   %eax
f0102f4b:	68 64 6d 10 f0       	push   $0xf0106d64
f0102f50:	68 f9 00 00 00       	push   $0xf9
f0102f55:	68 f1 80 10 f0       	push   $0xf01080f1
f0102f5a:	e8 09 d1 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102f5f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102f64:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102f67:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f6c:	e8 f3 e2 ff ff       	call   f0101264 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102f71:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102f74:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102f79:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102f7c:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102f7f:	83 ec 0c             	sub    $0xc,%esp
f0102f82:	6a 00                	push   $0x0
f0102f84:	e8 78 e6 ff ff       	call   f0101601 <page_alloc>
f0102f89:	89 c6                	mov    %eax,%esi
f0102f8b:	83 c4 10             	add    $0x10,%esp
f0102f8e:	85 c0                	test   %eax,%eax
f0102f90:	75 19                	jne    f0102fab <mem_init+0x164e>
f0102f92:	68 df 81 10 f0       	push   $0xf01081df
f0102f97:	68 17 81 10 f0       	push   $0xf0108117
f0102f9c:	68 32 04 00 00       	push   $0x432
f0102fa1:	68 f1 80 10 f0       	push   $0xf01080f1
f0102fa6:	e8 bd d0 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0102fab:	83 ec 0c             	sub    $0xc,%esp
f0102fae:	6a 00                	push   $0x0
f0102fb0:	e8 4c e6 ff ff       	call   f0101601 <page_alloc>
f0102fb5:	89 c7                	mov    %eax,%edi
f0102fb7:	83 c4 10             	add    $0x10,%esp
f0102fba:	85 c0                	test   %eax,%eax
f0102fbc:	75 19                	jne    f0102fd7 <mem_init+0x167a>
f0102fbe:	68 f5 81 10 f0       	push   $0xf01081f5
f0102fc3:	68 17 81 10 f0       	push   $0xf0108117
f0102fc8:	68 33 04 00 00       	push   $0x433
f0102fcd:	68 f1 80 10 f0       	push   $0xf01080f1
f0102fd2:	e8 91 d0 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0102fd7:	83 ec 0c             	sub    $0xc,%esp
f0102fda:	6a 00                	push   $0x0
f0102fdc:	e8 20 e6 ff ff       	call   f0101601 <page_alloc>
f0102fe1:	89 c3                	mov    %eax,%ebx
f0102fe3:	83 c4 10             	add    $0x10,%esp
f0102fe6:	85 c0                	test   %eax,%eax
f0102fe8:	75 19                	jne    f0103003 <mem_init+0x16a6>
f0102fea:	68 0b 82 10 f0       	push   $0xf010820b
f0102fef:	68 17 81 10 f0       	push   $0xf0108117
f0102ff4:	68 34 04 00 00       	push   $0x434
f0102ff9:	68 f1 80 10 f0       	push   $0xf01080f1
f0102ffe:	e8 65 d0 ff ff       	call   f0100068 <_panic>
	page_free(pp0);
f0103003:	83 ec 0c             	sub    $0xc,%esp
f0103006:	56                   	push   %esi
f0103007:	e8 7f e6 ff ff       	call   f010168b <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010300c:	89 f8                	mov    %edi,%eax
f010300e:	2b 05 90 0e 22 f0    	sub    0xf0220e90,%eax
f0103014:	c1 f8 03             	sar    $0x3,%eax
f0103017:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010301a:	89 c2                	mov    %eax,%edx
f010301c:	c1 ea 0c             	shr    $0xc,%edx
f010301f:	83 c4 10             	add    $0x10,%esp
f0103022:	3b 15 88 0e 22 f0    	cmp    0xf0220e88,%edx
f0103028:	72 12                	jb     f010303c <mem_init+0x16df>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010302a:	50                   	push   %eax
f010302b:	68 88 6d 10 f0       	push   $0xf0106d88
f0103030:	6a 58                	push   $0x58
f0103032:	68 fd 80 10 f0       	push   $0xf01080fd
f0103037:	e8 2c d0 ff ff       	call   f0100068 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010303c:	83 ec 04             	sub    $0x4,%esp
f010303f:	68 00 10 00 00       	push   $0x1000
f0103044:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103046:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010304b:	50                   	push   %eax
f010304c:	e8 f8 2f 00 00       	call   f0106049 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103051:	89 d8                	mov    %ebx,%eax
f0103053:	2b 05 90 0e 22 f0    	sub    0xf0220e90,%eax
f0103059:	c1 f8 03             	sar    $0x3,%eax
f010305c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010305f:	89 c2                	mov    %eax,%edx
f0103061:	c1 ea 0c             	shr    $0xc,%edx
f0103064:	83 c4 10             	add    $0x10,%esp
f0103067:	3b 15 88 0e 22 f0    	cmp    0xf0220e88,%edx
f010306d:	72 12                	jb     f0103081 <mem_init+0x1724>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010306f:	50                   	push   %eax
f0103070:	68 88 6d 10 f0       	push   $0xf0106d88
f0103075:	6a 58                	push   $0x58
f0103077:	68 fd 80 10 f0       	push   $0xf01080fd
f010307c:	e8 e7 cf ff ff       	call   f0100068 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103081:	83 ec 04             	sub    $0x4,%esp
f0103084:	68 00 10 00 00       	push   $0x1000
f0103089:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f010308b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103090:	50                   	push   %eax
f0103091:	e8 b3 2f 00 00       	call   f0106049 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103096:	6a 02                	push   $0x2
f0103098:	68 00 10 00 00       	push   $0x1000
f010309d:	57                   	push   %edi
f010309e:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f01030a4:	e8 04 e8 ff ff       	call   f01018ad <page_insert>
	assert(pp1->pp_ref == 1);
f01030a9:	83 c4 20             	add    $0x20,%esp
f01030ac:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01030b1:	74 19                	je     f01030cc <mem_init+0x176f>
f01030b3:	68 dc 82 10 f0       	push   $0xf01082dc
f01030b8:	68 17 81 10 f0       	push   $0xf0108117
f01030bd:	68 39 04 00 00       	push   $0x439
f01030c2:	68 f1 80 10 f0       	push   $0xf01080f1
f01030c7:	e8 9c cf ff ff       	call   f0100068 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01030cc:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01030d3:	01 01 01 
f01030d6:	74 19                	je     f01030f1 <mem_init+0x1794>
f01030d8:	68 1c 80 10 f0       	push   $0xf010801c
f01030dd:	68 17 81 10 f0       	push   $0xf0108117
f01030e2:	68 3a 04 00 00       	push   $0x43a
f01030e7:	68 f1 80 10 f0       	push   $0xf01080f1
f01030ec:	e8 77 cf ff ff       	call   f0100068 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01030f1:	6a 02                	push   $0x2
f01030f3:	68 00 10 00 00       	push   $0x1000
f01030f8:	53                   	push   %ebx
f01030f9:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f01030ff:	e8 a9 e7 ff ff       	call   f01018ad <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103104:	83 c4 10             	add    $0x10,%esp
f0103107:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010310e:	02 02 02 
f0103111:	74 19                	je     f010312c <mem_init+0x17cf>
f0103113:	68 40 80 10 f0       	push   $0xf0108040
f0103118:	68 17 81 10 f0       	push   $0xf0108117
f010311d:	68 3c 04 00 00       	push   $0x43c
f0103122:	68 f1 80 10 f0       	push   $0xf01080f1
f0103127:	e8 3c cf ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f010312c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103131:	74 19                	je     f010314c <mem_init+0x17ef>
f0103133:	68 fe 82 10 f0       	push   $0xf01082fe
f0103138:	68 17 81 10 f0       	push   $0xf0108117
f010313d:	68 3d 04 00 00       	push   $0x43d
f0103142:	68 f1 80 10 f0       	push   $0xf01080f1
f0103147:	e8 1c cf ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 0);
f010314c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103151:	74 19                	je     f010316c <mem_init+0x180f>
f0103153:	68 47 83 10 f0       	push   $0xf0108347
f0103158:	68 17 81 10 f0       	push   $0xf0108117
f010315d:	68 3e 04 00 00       	push   $0x43e
f0103162:	68 f1 80 10 f0       	push   $0xf01080f1
f0103167:	e8 fc ce ff ff       	call   f0100068 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010316c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103173:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103176:	89 d8                	mov    %ebx,%eax
f0103178:	2b 05 90 0e 22 f0    	sub    0xf0220e90,%eax
f010317e:	c1 f8 03             	sar    $0x3,%eax
f0103181:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103184:	89 c2                	mov    %eax,%edx
f0103186:	c1 ea 0c             	shr    $0xc,%edx
f0103189:	3b 15 88 0e 22 f0    	cmp    0xf0220e88,%edx
f010318f:	72 12                	jb     f01031a3 <mem_init+0x1846>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103191:	50                   	push   %eax
f0103192:	68 88 6d 10 f0       	push   $0xf0106d88
f0103197:	6a 58                	push   $0x58
f0103199:	68 fd 80 10 f0       	push   $0xf01080fd
f010319e:	e8 c5 ce ff ff       	call   f0100068 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01031a3:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01031aa:	03 03 03 
f01031ad:	74 19                	je     f01031c8 <mem_init+0x186b>
f01031af:	68 64 80 10 f0       	push   $0xf0108064
f01031b4:	68 17 81 10 f0       	push   $0xf0108117
f01031b9:	68 40 04 00 00       	push   $0x440
f01031be:	68 f1 80 10 f0       	push   $0xf01080f1
f01031c3:	e8 a0 ce ff ff       	call   f0100068 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01031c8:	83 ec 08             	sub    $0x8,%esp
f01031cb:	68 00 10 00 00       	push   $0x1000
f01031d0:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f01031d6:	e8 85 e6 ff ff       	call   f0101860 <page_remove>
	assert(pp2->pp_ref == 0);
f01031db:	83 c4 10             	add    $0x10,%esp
f01031de:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01031e3:	74 19                	je     f01031fe <mem_init+0x18a1>
f01031e5:	68 36 83 10 f0       	push   $0xf0108336
f01031ea:	68 17 81 10 f0       	push   $0xf0108117
f01031ef:	68 42 04 00 00       	push   $0x442
f01031f4:	68 f1 80 10 f0       	push   $0xf01080f1
f01031f9:	e8 6a ce ff ff       	call   f0100068 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01031fe:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0103203:	8b 08                	mov    (%eax),%ecx
f0103205:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010320b:	89 f2                	mov    %esi,%edx
f010320d:	2b 15 90 0e 22 f0    	sub    0xf0220e90,%edx
f0103213:	c1 fa 03             	sar    $0x3,%edx
f0103216:	c1 e2 0c             	shl    $0xc,%edx
f0103219:	39 d1                	cmp    %edx,%ecx
f010321b:	74 19                	je     f0103236 <mem_init+0x18d9>
f010321d:	68 24 7a 10 f0       	push   $0xf0107a24
f0103222:	68 17 81 10 f0       	push   $0xf0108117
f0103227:	68 45 04 00 00       	push   $0x445
f010322c:	68 f1 80 10 f0       	push   $0xf01080f1
f0103231:	e8 32 ce ff ff       	call   f0100068 <_panic>
	kern_pgdir[0] = 0;
f0103236:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010323c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103241:	74 19                	je     f010325c <mem_init+0x18ff>
f0103243:	68 ed 82 10 f0       	push   $0xf01082ed
f0103248:	68 17 81 10 f0       	push   $0xf0108117
f010324d:	68 47 04 00 00       	push   $0x447
f0103252:	68 f1 80 10 f0       	push   $0xf01080f1
f0103257:	e8 0c ce ff ff       	call   f0100068 <_panic>
	pp0->pp_ref = 0;
f010325c:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103262:	83 ec 0c             	sub    $0xc,%esp
f0103265:	56                   	push   %esi
f0103266:	e8 20 e4 ff ff       	call   f010168b <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010326b:	c7 04 24 90 80 10 f0 	movl   $0xf0108090,(%esp)
f0103272:	e8 ea 0b 00 00       	call   f0103e61 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103277:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010327a:	5b                   	pop    %ebx
f010327b:	5e                   	pop    %esi
f010327c:	5f                   	pop    %edi
f010327d:	c9                   	leave  
f010327e:	c3                   	ret    
	//
	// LAB 4: Your code here:
    
    int cpu_id;
    for (cpu_id = 0; cpu_id < NCPU; cpu_id++) {
        boot_map_region(kern_pgdir,
f010327f:	83 ec 08             	sub    $0x8,%esp
f0103282:	6a 02                	push   $0x2
f0103284:	68 00 20 22 00       	push   $0x222000
f0103289:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010328e:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103293:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
f0103298:	e8 c3 e4 ff ff       	call   f0101760 <boot_map_region>
f010329d:	bb 00 a0 22 f0       	mov    $0xf022a000,%ebx
f01032a2:	83 c4 10             	add    $0x10,%esp
f01032a5:	be 00 80 fe ef       	mov    $0xeffe8000,%esi
f01032aa:	e9 72 f9 ff ff       	jmp    f0102c21 <mem_init+0x12c4>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01032af:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f01032b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032b5:	e8 21 df ff ff       	call   f01011db <check_va2pa>
f01032ba:	e9 41 fb ff ff       	jmp    f0102e00 <mem_init+0x14a3>

f01032bf <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01032bf:	55                   	push   %ebp
f01032c0:	89 e5                	mov    %esp,%ebp
f01032c2:	57                   	push   %edi
f01032c3:	56                   	push   %esi
f01032c4:	53                   	push   %ebx
f01032c5:	83 ec 1c             	sub    $0x1c,%esp
f01032c8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01032cb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032ce:	8b 55 10             	mov    0x10(%ebp),%edx
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f01032d1:	85 d2                	test   %edx,%edx
f01032d3:	0f 84 85 00 00 00    	je     f010335e <user_mem_check+0x9f>

	perm |= PTE_P;
f01032d9:	8b 75 14             	mov    0x14(%ebp),%esi
f01032dc:	83 ce 01             	or     $0x1,%esi
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
f01032df:	89 c3                	mov    %eax,%ebx
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
f01032e1:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f01032e8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01032ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f01032f1:	89 c2                	mov    %eax,%edx
f01032f3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01032f9:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f01032fc:	74 67                	je     f0103365 <user_mem_check+0xa6>
		if (va_now >= ULIM) {
f01032fe:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103303:	76 17                	jbe    f010331c <user_mem_check+0x5d>
f0103305:	eb 08                	jmp    f010330f <user_mem_check+0x50>
f0103307:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010330d:	76 0d                	jbe    f010331c <user_mem_check+0x5d>
			user_mem_check_addr = va_now;
f010330f:	89 1d 2c 02 22 f0    	mov    %ebx,0xf022022c
			return -E_FAULT;
f0103315:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010331a:	eb 4e                	jmp    f010336a <user_mem_check+0xab>
		}
		pte = pgdir_walk(env->env_pgdir, (void *)va_now, false);
f010331c:	83 ec 04             	sub    $0x4,%esp
f010331f:	6a 00                	push   $0x0
f0103321:	53                   	push   %ebx
f0103322:	ff 77 60             	pushl  0x60(%edi)
f0103325:	e8 9f e3 ff ff       	call   f01016c9 <pgdir_walk>
		if (pte == NULL || ((*pte & perm ) != perm)) {
f010332a:	83 c4 10             	add    $0x10,%esp
f010332d:	85 c0                	test   %eax,%eax
f010332f:	74 08                	je     f0103339 <user_mem_check+0x7a>
f0103331:	8b 00                	mov    (%eax),%eax
f0103333:	21 f0                	and    %esi,%eax
f0103335:	39 c6                	cmp    %eax,%esi
f0103337:	74 0d                	je     f0103346 <user_mem_check+0x87>
			user_mem_check_addr = va_now;
f0103339:	89 1d 2c 02 22 f0    	mov    %ebx,0xf022022c
			return -E_FAULT;
f010333f:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103344:	eb 24                	jmp    f010336a <user_mem_check+0xab>

	perm |= PTE_P;
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f0103346:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010334c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103352:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0103355:	75 b0                	jne    f0103307 <user_mem_check+0x48>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0103357:	b8 00 00 00 00       	mov    $0x0,%eax
f010335c:	eb 0c                	jmp    f010336a <user_mem_check+0xab>
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f010335e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103363:	eb 05                	jmp    f010336a <user_mem_check+0xab>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0103365:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010336a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010336d:	5b                   	pop    %ebx
f010336e:	5e                   	pop    %esi
f010336f:	5f                   	pop    %edi
f0103370:	c9                   	leave  
f0103371:	c3                   	ret    

f0103372 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103372:	55                   	push   %ebp
f0103373:	89 e5                	mov    %esp,%ebp
f0103375:	53                   	push   %ebx
f0103376:	83 ec 04             	sub    $0x4,%esp
f0103379:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010337c:	8b 45 14             	mov    0x14(%ebp),%eax
f010337f:	83 c8 04             	or     $0x4,%eax
f0103382:	50                   	push   %eax
f0103383:	ff 75 10             	pushl  0x10(%ebp)
f0103386:	ff 75 0c             	pushl  0xc(%ebp)
f0103389:	53                   	push   %ebx
f010338a:	e8 30 ff ff ff       	call   f01032bf <user_mem_check>
f010338f:	83 c4 10             	add    $0x10,%esp
f0103392:	85 c0                	test   %eax,%eax
f0103394:	79 21                	jns    f01033b7 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103396:	83 ec 04             	sub    $0x4,%esp
f0103399:	ff 35 2c 02 22 f0    	pushl  0xf022022c
f010339f:	ff 73 48             	pushl  0x48(%ebx)
f01033a2:	68 bc 80 10 f0       	push   $0xf01080bc
f01033a7:	e8 b5 0a 00 00       	call   f0103e61 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01033ac:	89 1c 24             	mov    %ebx,(%esp)
f01033af:	e8 8c 07 00 00       	call   f0103b40 <env_destroy>
f01033b4:	83 c4 10             	add    $0x10,%esp
	}
}
f01033b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033ba:	c9                   	leave  
f01033bb:	c3                   	ret    

f01033bc <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01033bc:	55                   	push   %ebp
f01033bd:	89 e5                	mov    %esp,%ebp
f01033bf:	57                   	push   %edi
f01033c0:	56                   	push   %esi
f01033c1:	53                   	push   %ebx
f01033c2:	83 ec 0c             	sub    $0xc,%esp
f01033c5:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
f01033c7:	89 d3                	mov    %edx,%ebx
f01033c9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
f01033cf:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f01033d6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f01033dc:	39 fb                	cmp    %edi,%ebx
f01033de:	74 5a                	je     f010343a <region_alloc+0x7e>
        pg = page_alloc(1);
f01033e0:	83 ec 0c             	sub    $0xc,%esp
f01033e3:	6a 01                	push   $0x1
f01033e5:	e8 17 e2 ff ff       	call   f0101601 <page_alloc>
        if (pg == NULL) {
f01033ea:	83 c4 10             	add    $0x10,%esp
f01033ed:	85 c0                	test   %eax,%eax
f01033ef:	75 17                	jne    f0103408 <region_alloc+0x4c>
            panic("region_alloc : can't alloc page\n");
f01033f1:	83 ec 04             	sub    $0x4,%esp
f01033f4:	68 cc 83 10 f0       	push   $0xf01083cc
f01033f9:	68 69 01 00 00       	push   $0x169
f01033fe:	68 0f 84 10 f0       	push   $0xf010840f
f0103403:	e8 60 cc ff ff       	call   f0100068 <_panic>
        } else {
            r = page_insert(e->env_pgdir, pg, (void *)addr, PTE_U | PTE_W);
f0103408:	6a 06                	push   $0x6
f010340a:	53                   	push   %ebx
f010340b:	50                   	push   %eax
f010340c:	ff 76 60             	pushl  0x60(%esi)
f010340f:	e8 99 e4 ff ff       	call   f01018ad <page_insert>
            if (r != 0) {
f0103414:	83 c4 10             	add    $0x10,%esp
f0103417:	85 c0                	test   %eax,%eax
f0103419:	74 15                	je     f0103430 <region_alloc+0x74>
                panic("/kern/env.c/region_alloc : %e\n", r);
f010341b:	50                   	push   %eax
f010341c:	68 f0 83 10 f0       	push   $0xf01083f0
f0103421:	68 6d 01 00 00       	push   $0x16d
f0103426:	68 0f 84 10 f0       	push   $0xf010840f
f010342b:	e8 38 cc ff ff       	call   f0100068 <_panic>
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0103430:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103436:	39 df                	cmp    %ebx,%edi
f0103438:	75 a6                	jne    f01033e0 <region_alloc+0x24>
                panic("/kern/env.c/region_alloc : %e\n", r);
            }
        }
    }
    return;
}
f010343a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010343d:	5b                   	pop    %ebx
f010343e:	5e                   	pop    %esi
f010343f:	5f                   	pop    %edi
f0103440:	c9                   	leave  
f0103441:	c3                   	ret    

f0103442 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103442:	55                   	push   %ebp
f0103443:	89 e5                	mov    %esp,%ebp
f0103445:	57                   	push   %edi
f0103446:	56                   	push   %esi
f0103447:	53                   	push   %ebx
f0103448:	83 ec 0c             	sub    $0xc,%esp
f010344b:	8b 45 08             	mov    0x8(%ebp),%eax
f010344e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103451:	8a 4d 10             	mov    0x10(%ebp),%cl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103454:	85 c0                	test   %eax,%eax
f0103456:	75 24                	jne    f010347c <envid2env+0x3a>
		*env_store = curenv;
f0103458:	e8 1b 32 00 00       	call   f0106678 <cpunum>
f010345d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103464:	29 c2                	sub    %eax,%edx
f0103466:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103469:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0103470:	89 06                	mov    %eax,(%esi)
		return 0;
f0103472:	b8 00 00 00 00       	mov    $0x0,%eax
f0103477:	e9 80 00 00 00       	jmp    f01034fc <envid2env+0xba>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010347c:	89 c2                	mov    %eax,%edx
f010347e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103484:	89 d3                	mov    %edx,%ebx
f0103486:	c1 e3 07             	shl    $0x7,%ebx
f0103489:	8d 1c 93             	lea    (%ebx,%edx,4),%ebx
f010348c:	03 1d 3c 02 22 f0    	add    0xf022023c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103492:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103496:	74 05                	je     f010349d <envid2env+0x5b>
f0103498:	39 43 48             	cmp    %eax,0x48(%ebx)
f010349b:	74 0d                	je     f01034aa <envid2env+0x68>
		*env_store = 0;
f010349d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01034a3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01034a8:	eb 52                	jmp    f01034fc <envid2env+0xba>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01034aa:	84 c9                	test   %cl,%cl
f01034ac:	74 47                	je     f01034f5 <envid2env+0xb3>
f01034ae:	e8 c5 31 00 00       	call   f0106678 <cpunum>
f01034b3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01034ba:	29 c2                	sub    %eax,%edx
f01034bc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01034bf:	39 1c 85 28 10 22 f0 	cmp    %ebx,-0xfddefd8(,%eax,4)
f01034c6:	74 2d                	je     f01034f5 <envid2env+0xb3>
f01034c8:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01034cb:	e8 a8 31 00 00       	call   f0106678 <cpunum>
f01034d0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01034d7:	29 c2                	sub    %eax,%edx
f01034d9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01034dc:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f01034e3:	3b 78 48             	cmp    0x48(%eax),%edi
f01034e6:	74 0d                	je     f01034f5 <envid2env+0xb3>
		*env_store = 0;
f01034e8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01034ee:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01034f3:	eb 07                	jmp    f01034fc <envid2env+0xba>
	}

	*env_store = e;
f01034f5:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01034f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034fc:	83 c4 0c             	add    $0xc,%esp
f01034ff:	5b                   	pop    %ebx
f0103500:	5e                   	pop    %esi
f0103501:	5f                   	pop    %edi
f0103502:	c9                   	leave  
f0103503:	c3                   	ret    

f0103504 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103504:	55                   	push   %ebp
f0103505:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103507:	b8 88 93 12 f0       	mov    $0xf0129388,%eax
f010350c:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010350f:	b8 23 00 00 00       	mov    $0x23,%eax
f0103514:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103516:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103518:	b0 10                	mov    $0x10,%al
f010351a:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010351c:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010351e:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103520:	ea 27 35 10 f0 08 00 	ljmp   $0x8,$0xf0103527
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103527:	b0 00                	mov    $0x0,%al
f0103529:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010352c:	c9                   	leave  
f010352d:	c3                   	ret    

f010352e <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010352e:	55                   	push   %ebp
f010352f:	89 e5                	mov    %esp,%ebp
f0103531:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
f0103532:	8b 1d 3c 02 22 f0    	mov    0xf022023c,%ebx
f0103538:	89 1d 40 02 22 f0    	mov    %ebx,0xf0220240
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
f010353e:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        envs[i].env_status = ENV_FREE;
f0103545:	c7 43 54 00 00 00 00 	movl   $0x0,0x54(%ebx)
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f010354c:	8d 83 84 00 00 00    	lea    0x84(%ebx),%eax
f0103552:	8d 8b 00 10 02 00    	lea    0x21000(%ebx),%ecx
f0103558:	89 c2                	mov    %eax,%edx
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f010355a:	89 43 44             	mov    %eax,0x44(%ebx)
{
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
f010355d:	39 c8                	cmp    %ecx,%eax
f010355f:	74 1e                	je     f010357f <env_init+0x51>
        envs[i].env_id = 0;
f0103561:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE;
f0103568:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f010356f:	05 84 00 00 00       	add    $0x84,%eax
        if (i + 1 != NENV)
f0103574:	39 c8                	cmp    %ecx,%eax
f0103576:	75 0f                	jne    f0103587 <env_init+0x59>
            envs[i].env_link = envs + (i + 1);
        else 
            envs[i].env_link = NULL;
f0103578:	c7 42 44 00 00 00 00 	movl   $0x0,0x44(%edx)
    }

	// Per-CPU part of the initialization
	env_init_percpu();
f010357f:	e8 80 ff ff ff       	call   f0103504 <env_init_percpu>
}
f0103584:	5b                   	pop    %ebx
f0103585:	c9                   	leave  
f0103586:	c3                   	ret    
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0103587:	89 42 44             	mov    %eax,0x44(%edx)
f010358a:	89 c2                	mov    %eax,%edx
f010358c:	eb d3                	jmp    f0103561 <env_init+0x33>

f010358e <env_clone>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_clone(struct Env **newenv_store, envid_t parent_id)
{
f010358e:	55                   	push   %ebp
f010358f:	89 e5                	mov    %esp,%ebp
f0103591:	56                   	push   %esi
f0103592:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103593:	8b 1d 40 02 22 f0    	mov    0xf0220240,%ebx
f0103599:	85 db                	test   %ebx,%ebx
f010359b:	0f 84 06 01 00 00    	je     f01036a7 <env_clone+0x119>
		return -E_NO_FREE_ENV;

	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01035a1:	8b 43 48             	mov    0x48(%ebx),%eax
f01035a4:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)
f01035a9:	89 c1                	mov    %eax,%ecx
f01035ab:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f01035b1:	7f 05                	jg     f01035b8 <env_clone+0x2a>
		generation = 1 << ENVGENSHIFT;
f01035b3:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f01035b8:	89 d8                	mov    %ebx,%eax
f01035ba:	2b 05 3c 02 22 f0    	sub    0xf022023c,%eax
f01035c0:	c1 f8 02             	sar    $0x2,%eax
f01035c3:	89 c6                	mov    %eax,%esi
f01035c5:	c1 e6 05             	shl    $0x5,%esi
f01035c8:	89 c2                	mov    %eax,%edx
f01035ca:	c1 e2 0a             	shl    $0xa,%edx
f01035cd:	29 f2                	sub    %esi,%edx
f01035cf:	01 c2                	add    %eax,%edx
f01035d1:	89 d6                	mov    %edx,%esi
f01035d3:	c1 e6 0f             	shl    $0xf,%esi
f01035d6:	29 d6                	sub    %edx,%esi
f01035d8:	89 f2                	mov    %esi,%edx
f01035da:	c1 e2 05             	shl    $0x5,%edx
f01035dd:	8d 04 02             	lea    (%edx,%eax,1),%eax
f01035e0:	09 c1                	or     %eax,%ecx
f01035e2:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01035e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035e8:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01035eb:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01035f2:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01035f9:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103600:	83 ec 04             	sub    $0x4,%esp
f0103603:	6a 44                	push   $0x44
f0103605:	6a 00                	push   $0x0
f0103607:	53                   	push   %ebx
f0103608:	e8 3c 2a 00 00       	call   f0106049 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010360d:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103613:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103619:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010361f:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103626:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	e->env_tf.tf_eflags |= FL_IF;
f010362c:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103633:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010363a:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010363e:	8b 43 44             	mov    0x44(%ebx),%eax
f0103641:	a3 40 02 22 f0       	mov    %eax,0xf0220240
	*newenv_store = e;
f0103646:	8b 45 08             	mov    0x8(%ebp),%eax
f0103649:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new thread %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010364b:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010364e:	e8 25 30 00 00       	call   f0106678 <cpunum>
f0103653:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010365a:	29 c2                	sub    %eax,%edx
f010365c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010365f:	83 c4 10             	add    $0x10,%esp
f0103662:	83 3c 85 28 10 22 f0 	cmpl   $0x0,-0xfddefd8(,%eax,4)
f0103669:	00 
f010366a:	74 1d                	je     f0103689 <env_clone+0xfb>
f010366c:	e8 07 30 00 00       	call   f0106678 <cpunum>
f0103671:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103678:	29 c2                	sub    %eax,%edx
f010367a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010367d:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0103684:	8b 40 48             	mov    0x48(%eax),%eax
f0103687:	eb 05                	jmp    f010368e <env_clone+0x100>
f0103689:	b8 00 00 00 00       	mov    $0x0,%eax
f010368e:	83 ec 04             	sub    $0x4,%esp
f0103691:	53                   	push   %ebx
f0103692:	50                   	push   %eax
f0103693:	68 1a 84 10 f0       	push   $0xf010841a
f0103698:	e8 c4 07 00 00       	call   f0103e61 <cprintf>
	return 0;
f010369d:	83 c4 10             	add    $0x10,%esp
f01036a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01036a5:	eb 05                	jmp    f01036ac <env_clone+0x11e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01036a7:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new thread %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01036ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01036af:	5b                   	pop    %ebx
f01036b0:	5e                   	pop    %esi
f01036b1:	c9                   	leave  
f01036b2:	c3                   	ret    

f01036b3 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01036b3:	55                   	push   %ebp
f01036b4:	89 e5                	mov    %esp,%ebp
f01036b6:	56                   	push   %esi
f01036b7:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01036b8:	8b 1d 40 02 22 f0    	mov    0xf0220240,%ebx
f01036be:	85 db                	test   %ebx,%ebx
f01036c0:	0f 84 57 01 00 00    	je     f010381d <env_alloc+0x16a>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01036c6:	83 ec 0c             	sub    $0xc,%esp
f01036c9:	6a 01                	push   $0x1
f01036cb:	e8 31 df ff ff       	call   f0101601 <page_alloc>
f01036d0:	83 c4 10             	add    $0x10,%esp
f01036d3:	85 c0                	test   %eax,%eax
f01036d5:	0f 84 49 01 00 00    	je     f0103824 <env_alloc+0x171>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    p->pp_ref++;
f01036db:	66 ff 40 04          	incw   0x4(%eax)
f01036df:	2b 05 90 0e 22 f0    	sub    0xf0220e90,%eax
f01036e5:	c1 f8 03             	sar    $0x3,%eax
f01036e8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01036eb:	89 c2                	mov    %eax,%edx
f01036ed:	c1 ea 0c             	shr    $0xc,%edx
f01036f0:	3b 15 88 0e 22 f0    	cmp    0xf0220e88,%edx
f01036f6:	72 12                	jb     f010370a <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01036f8:	50                   	push   %eax
f01036f9:	68 88 6d 10 f0       	push   $0xf0106d88
f01036fe:	6a 58                	push   $0x58
f0103700:	68 fd 80 10 f0       	push   $0xf01080fd
f0103705:	e8 5e c9 ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f010370a:	2d 00 00 00 10       	sub    $0x10000000,%eax
    e->env_pgdir = (pde_t *)page2kva(p);
f010370f:	89 43 60             	mov    %eax,0x60(%ebx)
    
    memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103712:	83 ec 04             	sub    $0x4,%esp
f0103715:	68 00 10 00 00       	push   $0x1000
f010371a:	ff 35 8c 0e 22 f0    	pushl  0xf0220e8c
f0103720:	50                   	push   %eax
f0103721:	e8 d7 29 00 00       	call   f01060fd <memcpy>
    memset(e->env_pgdir, 0, PDX(UTOP) * sizeof(pde_t));
f0103726:	83 c4 0c             	add    $0xc,%esp
f0103729:	68 ec 0e 00 00       	push   $0xeec
f010372e:	6a 00                	push   $0x0
f0103730:	ff 73 60             	pushl  0x60(%ebx)
f0103733:	e8 11 29 00 00       	call   f0106049 <memset>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103738:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010373b:	83 c4 10             	add    $0x10,%esp
f010373e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103743:	77 15                	ja     f010375a <env_alloc+0xa7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103745:	50                   	push   %eax
f0103746:	68 64 6d 10 f0       	push   $0xf0106d64
f010374b:	68 cb 00 00 00       	push   $0xcb
f0103750:	68 0f 84 10 f0       	push   $0xf010840f
f0103755:	e8 0e c9 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010375a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103760:	83 ca 05             	or     $0x5,%edx
f0103763:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
    
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103769:	8b 43 48             	mov    0x48(%ebx),%eax
f010376c:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103771:	89 c1                	mov    %eax,%ecx
f0103773:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0103779:	7f 05                	jg     f0103780 <env_alloc+0xcd>
		generation = 1 << ENVGENSHIFT;
f010377b:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0103780:	89 d8                	mov    %ebx,%eax
f0103782:	2b 05 3c 02 22 f0    	sub    0xf022023c,%eax
f0103788:	c1 f8 02             	sar    $0x2,%eax
f010378b:	89 c6                	mov    %eax,%esi
f010378d:	c1 e6 05             	shl    $0x5,%esi
f0103790:	89 c2                	mov    %eax,%edx
f0103792:	c1 e2 0a             	shl    $0xa,%edx
f0103795:	29 f2                	sub    %esi,%edx
f0103797:	01 c2                	add    %eax,%edx
f0103799:	89 d6                	mov    %edx,%esi
f010379b:	c1 e6 0f             	shl    $0xf,%esi
f010379e:	29 d6                	sub    %edx,%esi
f01037a0:	89 f2                	mov    %esi,%edx
f01037a2:	c1 e2 05             	shl    $0x5,%edx
f01037a5:	8d 04 02             	lea    (%edx,%eax,1),%eax
f01037a8:	09 c1                	or     %eax,%ecx
f01037aa:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01037ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037b0:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01037b3:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01037ba:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01037c1:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01037c8:	83 ec 04             	sub    $0x4,%esp
f01037cb:	6a 44                	push   $0x44
f01037cd:	6a 00                	push   $0x0
f01037cf:	53                   	push   %ebx
f01037d0:	e8 74 28 00 00       	call   f0106049 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01037d5:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01037db:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01037e1:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01037e7:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01037ee:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f01037f4:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01037fb:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103802:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// set priority
	// e->env_priority = 0x0;

	// commit the allocation
	env_free_list = e->env_link;
f0103806:	8b 43 44             	mov    0x44(%ebx),%eax
f0103809:	a3 40 02 22 f0       	mov    %eax,0xf0220240
	*newenv_store = e;
f010380e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103811:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103813:	83 c4 10             	add    $0x10,%esp
f0103816:	b8 00 00 00 00       	mov    $0x0,%eax
f010381b:	eb 0c                	jmp    f0103829 <env_alloc+0x176>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010381d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103822:	eb 05                	jmp    f0103829 <env_alloc+0x176>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103824:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103829:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010382c:	5b                   	pop    %ebx
f010382d:	5e                   	pop    %esi
f010382e:	c9                   	leave  
f010382f:	c3                   	ret    

f0103830 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103830:	55                   	push   %ebp
f0103831:	89 e5                	mov    %esp,%ebp
f0103833:	57                   	push   %edi
f0103834:	56                   	push   %esi
f0103835:	53                   	push   %ebx
f0103836:	83 ec 34             	sub    $0x34,%esp
f0103839:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("env_create %u %u %u\n", binary, size, type);
	// LAB 3: Your code here.

    struct Env * e;
    int r = env_alloc(&e, 0);
f010383c:	6a 00                	push   $0x0
f010383e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103841:	50                   	push   %eax
f0103842:	e8 6c fe ff ff       	call   f01036b3 <env_alloc>
    if (r < 0) {
f0103847:	83 c4 10             	add    $0x10,%esp
f010384a:	85 c0                	test   %eax,%eax
f010384c:	79 15                	jns    f0103863 <env_create+0x33>
        panic("env_create: %e\n", r);
f010384e:	50                   	push   %eax
f010384f:	68 32 84 10 f0       	push   $0xf0108432
f0103854:	68 d8 01 00 00       	push   $0x1d8
f0103859:	68 0f 84 10 f0       	push   $0xf010840f
f010385e:	e8 05 c8 ff ff       	call   f0100068 <_panic>
    }
    load_icode(e, binary, size);
f0103863:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103866:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
f0103869:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f010386f:	74 17                	je     f0103888 <env_create+0x58>
        panic("error elf magic number\n");
f0103871:	83 ec 04             	sub    $0x4,%esp
f0103874:	68 42 84 10 f0       	push   $0xf0108442
f0103879:	68 ac 01 00 00       	push   $0x1ac
f010387e:	68 0f 84 10 f0       	push   $0xf010840f
f0103883:	e8 e0 c7 ff ff       	call   f0100068 <_panic>
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0103888:	8b 5e 1c             	mov    0x1c(%esi),%ebx
    eph = ph + elf->e_phnum;
f010388b:	8b 7e 2c             	mov    0x2c(%esi),%edi

    lcr3(PADDR(e->env_pgdir));
f010388e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103891:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103894:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103899:	77 15                	ja     f01038b0 <env_create+0x80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010389b:	50                   	push   %eax
f010389c:	68 64 6d 10 f0       	push   $0xf0106d64
f01038a1:	68 b2 01 00 00       	push   $0x1b2
f01038a6:	68 0f 84 10 f0       	push   $0xf010840f
f01038ab:	e8 b8 c7 ff ff       	call   f0100068 <_panic>
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
        panic("error elf magic number\n");
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01038b0:	8d 1c 1e             	lea    (%esi,%ebx,1),%ebx
    eph = ph + elf->e_phnum;
f01038b3:	0f b7 ff             	movzwl %di,%edi
f01038b6:	c1 e7 05             	shl    $0x5,%edi
f01038b9:	8d 3c 3b             	lea    (%ebx,%edi,1),%edi
	return (physaddr_t)kva - KERNBASE;
f01038bc:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01038c1:	0f 22 d8             	mov    %eax,%cr3

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01038c4:	39 fb                	cmp    %edi,%ebx
f01038c6:	73 48                	jae    f0103910 <env_create+0xe0>
        if (ph->p_type == ELF_PROG_LOAD) {
f01038c8:	83 3b 01             	cmpl   $0x1,(%ebx)
f01038cb:	75 3c                	jne    f0103909 <env_create+0xd9>
            // cprintf("%u %u\n", ph->p_memsz, ph->p_filesz);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01038cd:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01038d0:	8b 53 08             	mov    0x8(%ebx),%edx
f01038d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01038d6:	e8 e1 fa ff ff       	call   f01033bc <region_alloc>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01038db:	83 ec 04             	sub    $0x4,%esp
f01038de:	ff 73 10             	pushl  0x10(%ebx)
f01038e1:	89 f0                	mov    %esi,%eax
f01038e3:	03 43 04             	add    0x4(%ebx),%eax
f01038e6:	50                   	push   %eax
f01038e7:	ff 73 08             	pushl  0x8(%ebx)
f01038ea:	e8 0e 28 00 00       	call   f01060fd <memcpy>
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f01038ef:	8b 43 10             	mov    0x10(%ebx),%eax
f01038f2:	83 c4 0c             	add    $0xc,%esp
f01038f5:	8b 53 14             	mov    0x14(%ebx),%edx
f01038f8:	29 c2                	sub    %eax,%edx
f01038fa:	52                   	push   %edx
f01038fb:	6a 00                	push   $0x0
f01038fd:	03 43 08             	add    0x8(%ebx),%eax
f0103900:	50                   	push   %eax
f0103901:	e8 43 27 00 00       	call   f0106049 <memset>
f0103906:	83 c4 10             	add    $0x10,%esp
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
    eph = ph + elf->e_phnum;

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f0103909:	83 c3 20             	add    $0x20,%ebx
f010390c:	39 df                	cmp    %ebx,%edi
f010390e:	77 b8                	ja     f01038c8 <env_create+0x98>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
        }
    }
    e->env_tf.tf_eip = elf->e_entry;
f0103910:	8b 46 18             	mov    0x18(%esi),%eax
f0103913:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103916:	89 42 30             	mov    %eax,0x30(%edx)

    lcr3(PADDR(kern_pgdir));
f0103919:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010391e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103923:	77 15                	ja     f010393a <env_create+0x10a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103925:	50                   	push   %eax
f0103926:	68 64 6d 10 f0       	push   $0xf0106d64
f010392b:	68 be 01 00 00       	push   $0x1be
f0103930:	68 0f 84 10 f0       	push   $0xf010840f
f0103935:	e8 2e c7 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010393a:	05 00 00 00 10       	add    $0x10000000,%eax
f010393f:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103942:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103947:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010394c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010394f:	e8 68 fa ff ff       	call   f01033bc <region_alloc>
    int r = env_alloc(&e, 0);
    if (r < 0) {
        panic("env_create: %e\n", r);
    }
    load_icode(e, binary, size);
    e->env_type = type;
f0103954:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103957:	8b 55 10             	mov    0x10(%ebp),%edx
f010395a:	89 50 50             	mov    %edx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
    if (type == ENV_TYPE_FS)
f010395d:	83 fa 01             	cmp    $0x1,%edx
f0103960:	75 07                	jne    f0103969 <env_create+0x139>
        e->env_tf.tf_eflags |= FL_IOPL_3;
f0103962:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
    return;
}
f0103969:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010396c:	5b                   	pop    %ebx
f010396d:	5e                   	pop    %esi
f010396e:	5f                   	pop    %edi
f010396f:	c9                   	leave  
f0103970:	c3                   	ret    

f0103971 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103971:	55                   	push   %ebp
f0103972:	89 e5                	mov    %esp,%ebp
f0103974:	57                   	push   %edi
f0103975:	56                   	push   %esi
f0103976:	53                   	push   %ebx
f0103977:	83 ec 1c             	sub    $0x1c,%esp
f010397a:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010397d:	e8 f6 2c 00 00       	call   f0106678 <cpunum>
f0103982:	6b c0 74             	imul   $0x74,%eax,%eax
f0103985:	39 b8 28 10 22 f0    	cmp    %edi,-0xfddefd8(%eax)
f010398b:	75 29                	jne    f01039b6 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f010398d:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103992:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103997:	77 15                	ja     f01039ae <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103999:	50                   	push   %eax
f010399a:	68 64 6d 10 f0       	push   $0xf0106d64
f010399f:	68 f2 01 00 00       	push   $0x1f2
f01039a4:	68 0f 84 10 f0       	push   $0xf010840f
f01039a9:	e8 ba c6 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039ae:	05 00 00 00 10       	add    $0x10000000,%eax
f01039b3:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// if curenv is a thread, we don't need to flush mapped pages
	if (curenv->isthread) {
f01039b6:	e8 bd 2c 00 00       	call   f0106678 <cpunum>
f01039bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01039be:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f01039c4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01039cb:	80 78 7c 00          	cmpb   $0x0,0x7c(%eax)
f01039cf:	74 1a                	je     f01039eb <env_free+0x7a>
		e->env_status = ENV_FREE;
f01039d1:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
		e->env_link = env_free_list;
f01039d8:	a1 40 02 22 f0       	mov    0xf0220240,%eax
f01039dd:	89 47 44             	mov    %eax,0x44(%edi)
		env_free_list = e;
f01039e0:	89 3d 40 02 22 f0    	mov    %edi,0xf0220240
		return;
f01039e6:	e9 4d 01 00 00       	jmp    f0103b38 <env_free+0x1c7>
f01039eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01039ee:	c1 e0 02             	shl    $0x2,%eax
f01039f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01039f4:	8b 47 60             	mov    0x60(%edi),%eax
f01039f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01039fa:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01039fd:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103a03:	0f 84 ab 00 00 00    	je     f0103ab4 <env_free+0x143>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103a09:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a0f:	89 f0                	mov    %esi,%eax
f0103a11:	c1 e8 0c             	shr    $0xc,%eax
f0103a14:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103a17:	3b 05 88 0e 22 f0    	cmp    0xf0220e88,%eax
f0103a1d:	72 15                	jb     f0103a34 <env_free+0xc3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a1f:	56                   	push   %esi
f0103a20:	68 88 6d 10 f0       	push   $0xf0106d88
f0103a25:	68 09 02 00 00       	push   $0x209
f0103a2a:	68 0f 84 10 f0       	push   $0xf010840f
f0103a2f:	e8 34 c6 ff ff       	call   f0100068 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103a34:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103a37:	c1 e2 16             	shl    $0x16,%edx
f0103a3a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103a3d:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103a42:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103a49:	01 
f0103a4a:	74 17                	je     f0103a63 <env_free+0xf2>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103a4c:	83 ec 08             	sub    $0x8,%esp
f0103a4f:	89 d8                	mov    %ebx,%eax
f0103a51:	c1 e0 0c             	shl    $0xc,%eax
f0103a54:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103a57:	50                   	push   %eax
f0103a58:	ff 77 60             	pushl  0x60(%edi)
f0103a5b:	e8 00 de ff ff       	call   f0101860 <page_remove>
f0103a60:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103a63:	43                   	inc    %ebx
f0103a64:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103a6a:	75 d6                	jne    f0103a42 <env_free+0xd1>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103a6c:	8b 47 60             	mov    0x60(%edi),%eax
f0103a6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a72:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a79:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103a7c:	3b 05 88 0e 22 f0    	cmp    0xf0220e88,%eax
f0103a82:	72 14                	jb     f0103a98 <env_free+0x127>
		panic("pa2page called with invalid pa");
f0103a84:	83 ec 04             	sub    $0x4,%esp
f0103a87:	68 f0 78 10 f0       	push   $0xf01078f0
f0103a8c:	6a 51                	push   $0x51
f0103a8e:	68 fd 80 10 f0       	push   $0xf01080fd
f0103a93:	e8 d0 c5 ff ff       	call   f0100068 <_panic>
		page_decref(pa2page(pa));
f0103a98:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103a9b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103a9e:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0103aa5:	03 05 90 0e 22 f0    	add    0xf0220e90,%eax
f0103aab:	50                   	push   %eax
f0103aac:	e8 fa db ff ff       	call   f01016ab <page_decref>
f0103ab1:	83 c4 10             	add    $0x10,%esp
		return;
	}

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103ab4:	ff 45 e0             	incl   -0x20(%ebp)
f0103ab7:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103abe:	0f 85 27 ff ff ff    	jne    f01039eb <env_free+0x7a>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103ac4:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ac7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103acc:	77 15                	ja     f0103ae3 <env_free+0x172>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ace:	50                   	push   %eax
f0103acf:	68 64 6d 10 f0       	push   $0xf0106d64
f0103ad4:	68 17 02 00 00       	push   $0x217
f0103ad9:	68 0f 84 10 f0       	push   $0xf010840f
f0103ade:	e8 85 c5 ff ff       	call   f0100068 <_panic>
	e->env_pgdir = 0;
f0103ae3:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103aea:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103aef:	c1 e8 0c             	shr    $0xc,%eax
f0103af2:	3b 05 88 0e 22 f0    	cmp    0xf0220e88,%eax
f0103af8:	72 14                	jb     f0103b0e <env_free+0x19d>
		panic("pa2page called with invalid pa");
f0103afa:	83 ec 04             	sub    $0x4,%esp
f0103afd:	68 f0 78 10 f0       	push   $0xf01078f0
f0103b02:	6a 51                	push   $0x51
f0103b04:	68 fd 80 10 f0       	push   $0xf01080fd
f0103b09:	e8 5a c5 ff ff       	call   f0100068 <_panic>
	page_decref(pa2page(pa));
f0103b0e:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103b11:	c1 e0 03             	shl    $0x3,%eax
f0103b14:	03 05 90 0e 22 f0    	add    0xf0220e90,%eax
f0103b1a:	50                   	push   %eax
f0103b1b:	e8 8b db ff ff       	call   f01016ab <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103b20:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103b27:	a1 40 02 22 f0       	mov    0xf0220240,%eax
f0103b2c:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103b2f:	89 3d 40 02 22 f0    	mov    %edi,0xf0220240
f0103b35:	83 c4 10             	add    $0x10,%esp
}
f0103b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b3b:	5b                   	pop    %ebx
f0103b3c:	5e                   	pop    %esi
f0103b3d:	5f                   	pop    %edi
f0103b3e:	c9                   	leave  
f0103b3f:	c3                   	ret    

f0103b40 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103b40:	55                   	push   %ebp
f0103b41:	89 e5                	mov    %esp,%ebp
f0103b43:	53                   	push   %ebx
f0103b44:	83 ec 04             	sub    $0x4,%esp
f0103b47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103b4a:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103b4e:	75 23                	jne    f0103b73 <env_destroy+0x33>
f0103b50:	e8 23 2b 00 00       	call   f0106678 <cpunum>
f0103b55:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b5c:	29 c2                	sub    %eax,%edx
f0103b5e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b61:	39 1c 85 28 10 22 f0 	cmp    %ebx,-0xfddefd8(,%eax,4)
f0103b68:	74 09                	je     f0103b73 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103b6a:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103b71:	eb 3d                	jmp    f0103bb0 <env_destroy+0x70>
	}

	env_free(e);
f0103b73:	83 ec 0c             	sub    $0xc,%esp
f0103b76:	53                   	push   %ebx
f0103b77:	e8 f5 fd ff ff       	call   f0103971 <env_free>

	if (curenv == e) {
f0103b7c:	e8 f7 2a 00 00       	call   f0106678 <cpunum>
f0103b81:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b88:	29 c2                	sub    %eax,%edx
f0103b8a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b8d:	83 c4 10             	add    $0x10,%esp
f0103b90:	39 1c 85 28 10 22 f0 	cmp    %ebx,-0xfddefd8(,%eax,4)
f0103b97:	75 17                	jne    f0103bb0 <env_destroy+0x70>
		curenv = NULL;
f0103b99:	e8 da 2a 00 00       	call   f0106678 <cpunum>
f0103b9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ba1:	c7 80 28 10 22 f0 00 	movl   $0x0,-0xfddefd8(%eax)
f0103ba8:	00 00 00 
		sched_yield();
f0103bab:	e8 7a 0d 00 00       	call   f010492a <sched_yield>
	}
}
f0103bb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103bb3:	c9                   	leave  
f0103bb4:	c3                   	ret    

f0103bb5 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103bb5:	55                   	push   %ebp
f0103bb6:	89 e5                	mov    %esp,%ebp
f0103bb8:	53                   	push   %ebx
f0103bb9:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103bbc:	e8 b7 2a 00 00       	call   f0106678 <cpunum>
f0103bc1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103bc8:	29 c2                	sub    %eax,%edx
f0103bca:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103bcd:	8b 1c 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%ebx
f0103bd4:	e8 9f 2a 00 00       	call   f0106678 <cpunum>
f0103bd9:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103bdc:	8b 65 08             	mov    0x8(%ebp),%esp
f0103bdf:	61                   	popa   
f0103be0:	07                   	pop    %es
f0103be1:	1f                   	pop    %ds
f0103be2:	83 c4 08             	add    $0x8,%esp
f0103be5:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103be6:	83 ec 04             	sub    $0x4,%esp
f0103be9:	68 5a 84 10 f0       	push   $0xf010845a
f0103bee:	68 4d 02 00 00       	push   $0x24d
f0103bf3:	68 0f 84 10 f0       	push   $0xf010840f
f0103bf8:	e8 6b c4 ff ff       	call   f0100068 <_panic>

f0103bfd <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103bfd:	55                   	push   %ebp
f0103bfe:	89 e5                	mov    %esp,%ebp
f0103c00:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// cprintf("I am in env_run\n");
	
    if (curenv != NULL) {
f0103c03:	e8 70 2a 00 00       	call   f0106678 <cpunum>
f0103c08:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c0f:	29 c2                	sub    %eax,%edx
f0103c11:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c14:	83 3c 85 28 10 22 f0 	cmpl   $0x0,-0xfddefd8(,%eax,4)
f0103c1b:	00 
f0103c1c:	74 3d                	je     f0103c5b <env_run+0x5e>
        // context switch
        if (curenv->env_status == ENV_RUNNING) {
f0103c1e:	e8 55 2a 00 00       	call   f0106678 <cpunum>
f0103c23:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c2a:	29 c2                	sub    %eax,%edx
f0103c2c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c2f:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0103c36:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103c3a:	75 1f                	jne    f0103c5b <env_run+0x5e>
            curenv->env_status = ENV_RUNNABLE;
f0103c3c:	e8 37 2a 00 00       	call   f0106678 <cpunum>
f0103c41:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c48:	29 c2                	sub    %eax,%edx
f0103c4a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c4d:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0103c54:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
        }
        // how about other env_status ? e.g. like ENV_DYING ?
    }
    curenv = e;
f0103c5b:	e8 18 2a 00 00       	call   f0106678 <cpunum>
f0103c60:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c67:	29 c2                	sub    %eax,%edx
f0103c69:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c6c:	8b 55 08             	mov    0x8(%ebp),%edx
f0103c6f:	89 14 85 28 10 22 f0 	mov    %edx,-0xfddefd8(,%eax,4)
    curenv->env_status = ENV_RUNNING;
f0103c76:	e8 fd 29 00 00       	call   f0106678 <cpunum>
f0103c7b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c82:	29 c2                	sub    %eax,%edx
f0103c84:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c87:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0103c8e:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f0103c95:	e8 de 29 00 00       	call   f0106678 <cpunum>
f0103c9a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ca1:	29 c2                	sub    %eax,%edx
f0103ca3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ca6:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0103cad:	ff 40 58             	incl   0x58(%eax)

    lcr3(PADDR(curenv->env_pgdir));
f0103cb0:	e8 c3 29 00 00       	call   f0106678 <cpunum>
f0103cb5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cbc:	29 c2                	sub    %eax,%edx
f0103cbe:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cc1:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0103cc8:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ccb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103cd0:	77 15                	ja     f0103ce7 <env_run+0xea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cd2:	50                   	push   %eax
f0103cd3:	68 64 6d 10 f0       	push   $0xf0106d64
f0103cd8:	68 78 02 00 00       	push   $0x278
f0103cdd:	68 0f 84 10 f0       	push   $0xf010840f
f0103ce2:	e8 81 c3 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ce7:	05 00 00 00 10       	add    $0x10000000,%eax
f0103cec:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103cef:	83 ec 0c             	sub    $0xc,%esp
f0103cf2:	68 60 94 12 f0       	push   $0xf0129460
f0103cf7:	e8 ee 2c 00 00       	call   f01069ea <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103cfc:	f3 90                	pause  
    unlock_kernel();
    env_pop_tf(&curenv->env_tf);    
f0103cfe:	e8 75 29 00 00       	call   f0106678 <cpunum>
f0103d03:	83 c4 04             	add    $0x4,%esp
f0103d06:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d0d:	29 c2                	sub    %eax,%edx
f0103d0f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d12:	ff 34 85 28 10 22 f0 	pushl  -0xfddefd8(,%eax,4)
f0103d19:	e8 97 fe ff ff       	call   f0103bb5 <env_pop_tf>
	...

f0103d20 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103d20:	55                   	push   %ebp
f0103d21:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d23:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d28:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d2b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103d2c:	b2 71                	mov    $0x71,%dl
f0103d2e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103d2f:	0f b6 c0             	movzbl %al,%eax
}
f0103d32:	c9                   	leave  
f0103d33:	c3                   	ret    

f0103d34 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103d34:	55                   	push   %ebp
f0103d35:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d37:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d3f:	ee                   	out    %al,(%dx)
f0103d40:	b2 71                	mov    $0x71,%dl
f0103d42:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d45:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103d46:	c9                   	leave  
f0103d47:	c3                   	ret    

f0103d48 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103d48:	55                   	push   %ebp
f0103d49:	89 e5                	mov    %esp,%ebp
f0103d4b:	56                   	push   %esi
f0103d4c:	53                   	push   %ebx
f0103d4d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d50:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103d52:	66 a3 90 93 12 f0    	mov    %ax,0xf0129390
	if (!didinit)
f0103d58:	80 3d 44 02 22 f0 00 	cmpb   $0x0,0xf0220244
f0103d5f:	74 5a                	je     f0103dbb <irq_setmask_8259A+0x73>
f0103d61:	ba 21 00 00 00       	mov    $0x21,%edx
f0103d66:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103d67:	89 f0                	mov    %esi,%eax
f0103d69:	66 c1 e8 08          	shr    $0x8,%ax
f0103d6d:	b2 a1                	mov    $0xa1,%dl
f0103d6f:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103d70:	83 ec 0c             	sub    $0xc,%esp
f0103d73:	68 66 84 10 f0       	push   $0xf0108466
f0103d78:	e8 e4 00 00 00       	call   f0103e61 <cprintf>
f0103d7d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103d80:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103d85:	0f b7 f6             	movzwl %si,%esi
f0103d88:	f7 d6                	not    %esi
f0103d8a:	89 f0                	mov    %esi,%eax
f0103d8c:	88 d9                	mov    %bl,%cl
f0103d8e:	d3 f8                	sar    %cl,%eax
f0103d90:	a8 01                	test   $0x1,%al
f0103d92:	74 11                	je     f0103da5 <irq_setmask_8259A+0x5d>
			cprintf(" %d", i);
f0103d94:	83 ec 08             	sub    $0x8,%esp
f0103d97:	53                   	push   %ebx
f0103d98:	68 1b 89 10 f0       	push   $0xf010891b
f0103d9d:	e8 bf 00 00 00       	call   f0103e61 <cprintf>
f0103da2:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103da5:	43                   	inc    %ebx
f0103da6:	83 fb 10             	cmp    $0x10,%ebx
f0103da9:	75 df                	jne    f0103d8a <irq_setmask_8259A+0x42>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103dab:	83 ec 0c             	sub    $0xc,%esp
f0103dae:	68 af 70 10 f0       	push   $0xf01070af
f0103db3:	e8 a9 00 00 00       	call   f0103e61 <cprintf>
f0103db8:	83 c4 10             	add    $0x10,%esp
}
f0103dbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103dbe:	5b                   	pop    %ebx
f0103dbf:	5e                   	pop    %esi
f0103dc0:	c9                   	leave  
f0103dc1:	c3                   	ret    

f0103dc2 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103dc2:	55                   	push   %ebp
f0103dc3:	89 e5                	mov    %esp,%ebp
f0103dc5:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f0103dc8:	c6 05 44 02 22 f0 01 	movb   $0x1,0xf0220244
f0103dcf:	ba 21 00 00 00       	mov    $0x21,%edx
f0103dd4:	b0 ff                	mov    $0xff,%al
f0103dd6:	ee                   	out    %al,(%dx)
f0103dd7:	b2 a1                	mov    $0xa1,%dl
f0103dd9:	ee                   	out    %al,(%dx)
f0103dda:	b2 20                	mov    $0x20,%dl
f0103ddc:	b0 11                	mov    $0x11,%al
f0103dde:	ee                   	out    %al,(%dx)
f0103ddf:	b2 21                	mov    $0x21,%dl
f0103de1:	b0 20                	mov    $0x20,%al
f0103de3:	ee                   	out    %al,(%dx)
f0103de4:	b0 04                	mov    $0x4,%al
f0103de6:	ee                   	out    %al,(%dx)
f0103de7:	b0 03                	mov    $0x3,%al
f0103de9:	ee                   	out    %al,(%dx)
f0103dea:	b2 a0                	mov    $0xa0,%dl
f0103dec:	b0 11                	mov    $0x11,%al
f0103dee:	ee                   	out    %al,(%dx)
f0103def:	b2 a1                	mov    $0xa1,%dl
f0103df1:	b0 28                	mov    $0x28,%al
f0103df3:	ee                   	out    %al,(%dx)
f0103df4:	b0 02                	mov    $0x2,%al
f0103df6:	ee                   	out    %al,(%dx)
f0103df7:	b0 01                	mov    $0x1,%al
f0103df9:	ee                   	out    %al,(%dx)
f0103dfa:	b2 20                	mov    $0x20,%dl
f0103dfc:	b0 68                	mov    $0x68,%al
f0103dfe:	ee                   	out    %al,(%dx)
f0103dff:	b0 0a                	mov    $0xa,%al
f0103e01:	ee                   	out    %al,(%dx)
f0103e02:	b2 a0                	mov    $0xa0,%dl
f0103e04:	b0 68                	mov    $0x68,%al
f0103e06:	ee                   	out    %al,(%dx)
f0103e07:	b0 0a                	mov    $0xa,%al
f0103e09:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103e0a:	66 a1 90 93 12 f0    	mov    0xf0129390,%ax
f0103e10:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103e14:	74 0f                	je     f0103e25 <pic_init+0x63>
		irq_setmask_8259A(irq_mask_8259A);
f0103e16:	83 ec 0c             	sub    $0xc,%esp
f0103e19:	0f b7 c0             	movzwl %ax,%eax
f0103e1c:	50                   	push   %eax
f0103e1d:	e8 26 ff ff ff       	call   f0103d48 <irq_setmask_8259A>
f0103e22:	83 c4 10             	add    $0x10,%esp
}
f0103e25:	c9                   	leave  
f0103e26:	c3                   	ret    
	...

f0103e28 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103e28:	55                   	push   %ebp
f0103e29:	89 e5                	mov    %esp,%ebp
f0103e2b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103e2e:	ff 75 08             	pushl  0x8(%ebp)
f0103e31:	e8 9e c9 ff ff       	call   f01007d4 <cputchar>
f0103e36:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0103e39:	c9                   	leave  
f0103e3a:	c3                   	ret    

f0103e3b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103e3b:	55                   	push   %ebp
f0103e3c:	89 e5                	mov    %esp,%ebp
f0103e3e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103e41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103e48:	ff 75 0c             	pushl  0xc(%ebp)
f0103e4b:	ff 75 08             	pushl  0x8(%ebp)
f0103e4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103e51:	50                   	push   %eax
f0103e52:	68 28 3e 10 f0       	push   $0xf0103e28
f0103e57:	e8 45 1b 00 00       	call   f01059a1 <vprintfmt>
	return cnt;
}
f0103e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e5f:	c9                   	leave  
f0103e60:	c3                   	ret    

f0103e61 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103e61:	55                   	push   %ebp
f0103e62:	89 e5                	mov    %esp,%ebp
f0103e64:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103e67:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103e6a:	50                   	push   %eax
f0103e6b:	ff 75 08             	pushl  0x8(%ebp)
f0103e6e:	e8 c8 ff ff ff       	call   f0103e3b <vcprintf>
	va_end(ap);

	return cnt;
}
f0103e73:	c9                   	leave  
f0103e74:	c3                   	ret    
f0103e75:	00 00                	add    %al,(%eax)
	...

f0103e78 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103e78:	55                   	push   %ebp
f0103e79:	89 e5                	mov    %esp,%ebp
f0103e7b:	57                   	push   %edi
f0103e7c:	56                   	push   %esi
f0103e7d:	53                   	push   %ebx
f0103e7e:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
    
    int cpu_id = thiscpu->cpu_id;
f0103e81:	e8 f2 27 00 00       	call   f0106678 <cpunum>
f0103e86:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103e8d:	29 c2                	sub    %eax,%edx
f0103e8f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103e92:	0f b6 34 85 20 10 22 	movzbl -0xfddefe0(,%eax,4),%esi
f0103e99:	f0 
    
    // Setup a TSS so that we get the right stack
	// when we trap to the kernel.
    thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id * (KSTKSIZE + KSTKGAP);
f0103e9a:	e8 d9 27 00 00       	call   f0106678 <cpunum>
f0103e9f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ea6:	29 c2                	sub    %eax,%edx
f0103ea8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103eab:	89 f2                	mov    %esi,%edx
f0103ead:	f7 da                	neg    %edx
f0103eaf:	c1 e2 10             	shl    $0x10,%edx
f0103eb2:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103eb8:	89 14 85 30 10 22 f0 	mov    %edx,-0xfddefd0(,%eax,4)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103ebf:	e8 b4 27 00 00       	call   f0106678 <cpunum>
f0103ec4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ecb:	29 c2                	sub    %eax,%edx
f0103ecd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ed0:	66 c7 04 85 34 10 22 	movw   $0x10,-0xfddefcc(,%eax,4)
f0103ed7:	f0 10 00 

    gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103eda:	8d 5e 05             	lea    0x5(%esi),%ebx
f0103edd:	e8 96 27 00 00       	call   f0106678 <cpunum>
f0103ee2:	89 c7                	mov    %eax,%edi
f0103ee4:	e8 8f 27 00 00       	call   f0106678 <cpunum>
f0103ee9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103eec:	e8 87 27 00 00       	call   f0106678 <cpunum>
f0103ef1:	66 c7 04 dd 20 93 12 	movw   $0x68,-0xfed6ce0(,%ebx,8)
f0103ef8:	f0 68 00 
f0103efb:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0103f02:	29 fa                	sub    %edi,%edx
f0103f04:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103f07:	8d 14 95 2c 10 22 f0 	lea    -0xfddefd4(,%edx,4),%edx
f0103f0e:	66 89 14 dd 22 93 12 	mov    %dx,-0xfed6cde(,%ebx,8)
f0103f15:	f0 
f0103f16:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103f19:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0103f20:	29 ca                	sub    %ecx,%edx
f0103f22:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0103f25:	8d 14 95 2c 10 22 f0 	lea    -0xfddefd4(,%edx,4),%edx
f0103f2c:	c1 ea 10             	shr    $0x10,%edx
f0103f2f:	88 14 dd 24 93 12 f0 	mov    %dl,-0xfed6cdc(,%ebx,8)
f0103f36:	c6 04 dd 26 93 12 f0 	movb   $0x40,-0xfed6cda(,%ebx,8)
f0103f3d:	40 
f0103f3e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f45:	29 c2                	sub    %eax,%edx
f0103f47:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f4a:	8d 04 85 2c 10 22 f0 	lea    -0xfddefd4(,%eax,4),%eax
f0103f51:	c1 e8 18             	shr    $0x18,%eax
f0103f54:	88 04 dd 27 93 12 f0 	mov    %al,-0xfed6cd9(,%ebx,8)
    							sizeof(struct Taskstate), 0);

    // Initialize the TSS slot of the gdt.
    gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0103f5b:	c6 04 dd 25 93 12 f0 	movb   $0x89,-0xfed6cdb(,%ebx,8)
f0103f62:	89 

    // Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
    ltr(GD_TSS0 + (cpu_id << 3));
f0103f63:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103f6a:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103f6d:	b8 94 93 12 f0       	mov    $0xf0129394,%eax
f0103f72:	0f 01 18             	lidtl  (%eax)

    // Load the IDT
    lidt(&idt_pd);
}
f0103f75:	83 c4 1c             	add    $0x1c,%esp
f0103f78:	5b                   	pop    %ebx
f0103f79:	5e                   	pop    %esi
f0103f7a:	5f                   	pop    %edi
f0103f7b:	c9                   	leave  
f0103f7c:	c3                   	ret    

f0103f7d <trap_init>:
}


void
trap_init(void)
{
f0103f7d:	55                   	push   %ebp
f0103f7e:	89 e5                	mov    %esp,%ebp
f0103f80:	83 ec 08             	sub    $0x8,%esp
f0103f83:	ba 01 00 00 00       	mov    $0x1,%edx
f0103f88:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f8d:	eb 02                	jmp    f0103f91 <trap_init+0x14>
f0103f8f:	40                   	inc    %eax
f0103f90:	42                   	inc    %edx
    extern void vec51();
    

    int i;
    for (i = 0; i != 20; i++) {
    	if (i == T_BRKPT) {
f0103f91:	83 f8 03             	cmp    $0x3,%eax
f0103f94:	75 30                	jne    f0103fc6 <trap_init+0x49>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
f0103f96:	8b 0d a8 93 12 f0    	mov    0xf01293a8,%ecx
f0103f9c:	66 89 0d 78 02 22 f0 	mov    %cx,0xf0220278
f0103fa3:	66 c7 05 7a 02 22 f0 	movw   $0x8,0xf022027a
f0103faa:	08 00 
f0103fac:	c6 05 7c 02 22 f0 00 	movb   $0x0,0xf022027c
f0103fb3:	c6 05 7d 02 22 f0 ee 	movb   $0xee,0xf022027d
f0103fba:	c1 e9 10             	shr    $0x10,%ecx
f0103fbd:	66 89 0d 7e 02 22 f0 	mov    %cx,0xf022027e
f0103fc4:	eb c9                	jmp    f0103f8f <trap_init+0x12>
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f0103fc6:	8b 0c 85 9c 93 12 f0 	mov    -0xfed6c64(,%eax,4),%ecx
f0103fcd:	66 89 0c c5 60 02 22 	mov    %cx,-0xfddfda0(,%eax,8)
f0103fd4:	f0 
f0103fd5:	66 c7 04 c5 62 02 22 	movw   $0x8,-0xfddfd9e(,%eax,8)
f0103fdc:	f0 08 00 
f0103fdf:	c6 04 c5 64 02 22 f0 	movb   $0x0,-0xfddfd9c(,%eax,8)
f0103fe6:	00 
f0103fe7:	c6 04 c5 65 02 22 f0 	movb   $0x8e,-0xfddfd9b(,%eax,8)
f0103fee:	8e 
f0103fef:	c1 e9 10             	shr    $0x10,%ecx
f0103ff2:	66 89 0c c5 66 02 22 	mov    %cx,-0xfddfd9a(,%eax,8)
f0103ff9:	f0 
    extern void vec46();
    extern void vec51();
    

    int i;
    for (i = 0; i != 20; i++) {
f0103ffa:	83 fa 14             	cmp    $0x14,%edx
f0103ffd:	75 90                	jne    f0103f8f <trap_init+0x12>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
    	}
    }
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, vec32, 0);
f0103fff:	b8 f2 93 12 f0       	mov    $0xf01293f2,%eax
f0104004:	66 a3 60 03 22 f0    	mov    %ax,0xf0220360
f010400a:	66 c7 05 62 03 22 f0 	movw   $0x8,0xf0220362
f0104011:	08 00 
f0104013:	c6 05 64 03 22 f0 00 	movb   $0x0,0xf0220364
f010401a:	c6 05 65 03 22 f0 8e 	movb   $0x8e,0xf0220365
f0104021:	c1 e8 10             	shr    $0x10,%eax
f0104024:	66 a3 66 03 22 f0    	mov    %ax,0xf0220366
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, vec33, 0);
f010402a:	b8 f8 93 12 f0       	mov    $0xf01293f8,%eax
f010402f:	66 a3 68 03 22 f0    	mov    %ax,0xf0220368
f0104035:	66 c7 05 6a 03 22 f0 	movw   $0x8,0xf022036a
f010403c:	08 00 
f010403e:	c6 05 6c 03 22 f0 00 	movb   $0x0,0xf022036c
f0104045:	c6 05 6d 03 22 f0 8e 	movb   $0x8e,0xf022036d
f010404c:	c1 e8 10             	shr    $0x10,%eax
f010404f:	66 a3 6e 03 22 f0    	mov    %ax,0xf022036e
    SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, vec36, 0);
f0104055:	b8 fe 93 12 f0       	mov    $0xf01293fe,%eax
f010405a:	66 a3 80 03 22 f0    	mov    %ax,0xf0220380
f0104060:	66 c7 05 82 03 22 f0 	movw   $0x8,0xf0220382
f0104067:	08 00 
f0104069:	c6 05 84 03 22 f0 00 	movb   $0x0,0xf0220384
f0104070:	c6 05 85 03 22 f0 8e 	movb   $0x8e,0xf0220385
f0104077:	c1 e8 10             	shr    $0x10,%eax
f010407a:	66 a3 86 03 22 f0    	mov    %ax,0xf0220386
    SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, vec39, 0);
f0104080:	b8 04 94 12 f0       	mov    $0xf0129404,%eax
f0104085:	66 a3 98 03 22 f0    	mov    %ax,0xf0220398
f010408b:	66 c7 05 9a 03 22 f0 	movw   $0x8,0xf022039a
f0104092:	08 00 
f0104094:	c6 05 9c 03 22 f0 00 	movb   $0x0,0xf022039c
f010409b:	c6 05 9d 03 22 f0 8e 	movb   $0x8e,0xf022039d
f01040a2:	c1 e8 10             	shr    $0x10,%eax
f01040a5:	66 a3 9e 03 22 f0    	mov    %ax,0xf022039e
    SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, vec46, 0);
f01040ab:	b8 0a 94 12 f0       	mov    $0xf012940a,%eax
f01040b0:	66 a3 d0 03 22 f0    	mov    %ax,0xf02203d0
f01040b6:	66 c7 05 d2 03 22 f0 	movw   $0x8,0xf02203d2
f01040bd:	08 00 
f01040bf:	c6 05 d4 03 22 f0 00 	movb   $0x0,0xf02203d4
f01040c6:	c6 05 d5 03 22 f0 8e 	movb   $0x8e,0xf02203d5
f01040cd:	c1 e8 10             	shr    $0x10,%eax
f01040d0:	66 a3 d6 03 22 f0    	mov    %ax,0xf02203d6

    SETGATE(idt[T_SYSCALL], 0, GD_KT, vec48, 3);
f01040d6:	b8 ec 93 12 f0       	mov    $0xf01293ec,%eax
f01040db:	66 a3 e0 03 22 f0    	mov    %ax,0xf02203e0
f01040e1:	66 c7 05 e2 03 22 f0 	movw   $0x8,0xf02203e2
f01040e8:	08 00 
f01040ea:	c6 05 e4 03 22 f0 00 	movb   $0x0,0xf02203e4
f01040f1:	c6 05 e5 03 22 f0 ee 	movb   $0xee,0xf02203e5
f01040f8:	c1 e8 10             	shr    $0x10,%eax
f01040fb:	66 a3 e6 03 22 f0    	mov    %ax,0xf02203e6
	
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, vec51, 0);
f0104101:	b8 10 94 12 f0       	mov    $0xf0129410,%eax
f0104106:	66 a3 f8 03 22 f0    	mov    %ax,0xf02203f8
f010410c:	66 c7 05 fa 03 22 f0 	movw   $0x8,0xf02203fa
f0104113:	08 00 
f0104115:	c6 05 fc 03 22 f0 00 	movb   $0x0,0xf02203fc
f010411c:	c6 05 fd 03 22 f0 8e 	movb   $0x8e,0xf02203fd
f0104123:	c1 e8 10             	shr    $0x10,%eax
f0104126:	66 a3 fe 03 22 f0    	mov    %ax,0xf02203fe
    
 	
	// Per-CPU setup 
	trap_init_percpu();
f010412c:	e8 47 fd ff ff       	call   f0103e78 <trap_init_percpu>
}
f0104131:	c9                   	leave  
f0104132:	c3                   	ret    

f0104133 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104133:	55                   	push   %ebp
f0104134:	89 e5                	mov    %esp,%ebp
f0104136:	53                   	push   %ebx
f0104137:	83 ec 0c             	sub    $0xc,%esp
f010413a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010413d:	ff 33                	pushl  (%ebx)
f010413f:	68 7a 84 10 f0       	push   $0xf010847a
f0104144:	e8 18 fd ff ff       	call   f0103e61 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104149:	83 c4 08             	add    $0x8,%esp
f010414c:	ff 73 04             	pushl  0x4(%ebx)
f010414f:	68 89 84 10 f0       	push   $0xf0108489
f0104154:	e8 08 fd ff ff       	call   f0103e61 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104159:	83 c4 08             	add    $0x8,%esp
f010415c:	ff 73 08             	pushl  0x8(%ebx)
f010415f:	68 98 84 10 f0       	push   $0xf0108498
f0104164:	e8 f8 fc ff ff       	call   f0103e61 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104169:	83 c4 08             	add    $0x8,%esp
f010416c:	ff 73 0c             	pushl  0xc(%ebx)
f010416f:	68 a7 84 10 f0       	push   $0xf01084a7
f0104174:	e8 e8 fc ff ff       	call   f0103e61 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104179:	83 c4 08             	add    $0x8,%esp
f010417c:	ff 73 10             	pushl  0x10(%ebx)
f010417f:	68 b6 84 10 f0       	push   $0xf01084b6
f0104184:	e8 d8 fc ff ff       	call   f0103e61 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104189:	83 c4 08             	add    $0x8,%esp
f010418c:	ff 73 14             	pushl  0x14(%ebx)
f010418f:	68 c5 84 10 f0       	push   $0xf01084c5
f0104194:	e8 c8 fc ff ff       	call   f0103e61 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104199:	83 c4 08             	add    $0x8,%esp
f010419c:	ff 73 18             	pushl  0x18(%ebx)
f010419f:	68 d4 84 10 f0       	push   $0xf01084d4
f01041a4:	e8 b8 fc ff ff       	call   f0103e61 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01041a9:	83 c4 08             	add    $0x8,%esp
f01041ac:	ff 73 1c             	pushl  0x1c(%ebx)
f01041af:	68 e3 84 10 f0       	push   $0xf01084e3
f01041b4:	e8 a8 fc ff ff       	call   f0103e61 <cprintf>
f01041b9:	83 c4 10             	add    $0x10,%esp
}
f01041bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01041bf:	c9                   	leave  
f01041c0:	c3                   	ret    

f01041c1 <print_trapframe>:
    lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01041c1:	55                   	push   %ebp
f01041c2:	89 e5                	mov    %esp,%ebp
f01041c4:	53                   	push   %ebx
f01041c5:	83 ec 04             	sub    $0x4,%esp
f01041c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01041cb:	e8 a8 24 00 00       	call   f0106678 <cpunum>
f01041d0:	83 ec 04             	sub    $0x4,%esp
f01041d3:	50                   	push   %eax
f01041d4:	53                   	push   %ebx
f01041d5:	68 47 85 10 f0       	push   $0xf0108547
f01041da:	e8 82 fc ff ff       	call   f0103e61 <cprintf>
	print_regs(&tf->tf_regs);
f01041df:	89 1c 24             	mov    %ebx,(%esp)
f01041e2:	e8 4c ff ff ff       	call   f0104133 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01041e7:	83 c4 08             	add    $0x8,%esp
f01041ea:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01041ee:	50                   	push   %eax
f01041ef:	68 65 85 10 f0       	push   $0xf0108565
f01041f4:	e8 68 fc ff ff       	call   f0103e61 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01041f9:	83 c4 08             	add    $0x8,%esp
f01041fc:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104200:	50                   	push   %eax
f0104201:	68 78 85 10 f0       	push   $0xf0108578
f0104206:	e8 56 fc ff ff       	call   f0103e61 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010420b:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010420e:	83 c4 10             	add    $0x10,%esp
f0104211:	83 f8 13             	cmp    $0x13,%eax
f0104214:	77 09                	ja     f010421f <print_trapframe+0x5e>
		return excnames[trapno];
f0104216:	8b 14 85 20 88 10 f0 	mov    -0xfef77e0(,%eax,4),%edx
f010421d:	eb 20                	jmp    f010423f <print_trapframe+0x7e>
	if (trapno == T_SYSCALL)
f010421f:	83 f8 30             	cmp    $0x30,%eax
f0104222:	74 0f                	je     f0104233 <print_trapframe+0x72>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104224:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104227:	83 fa 0f             	cmp    $0xf,%edx
f010422a:	77 0e                	ja     f010423a <print_trapframe+0x79>
		return "Hardware Interrupt";
f010422c:	ba fe 84 10 f0       	mov    $0xf01084fe,%edx
f0104231:	eb 0c                	jmp    f010423f <print_trapframe+0x7e>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0104233:	ba f2 84 10 f0       	mov    $0xf01084f2,%edx
f0104238:	eb 05                	jmp    f010423f <print_trapframe+0x7e>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f010423a:	ba 11 85 10 f0       	mov    $0xf0108511,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010423f:	83 ec 04             	sub    $0x4,%esp
f0104242:	52                   	push   %edx
f0104243:	50                   	push   %eax
f0104244:	68 8b 85 10 f0       	push   $0xf010858b
f0104249:	e8 13 fc ff ff       	call   f0103e61 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010424e:	83 c4 10             	add    $0x10,%esp
f0104251:	3b 1d 60 0a 22 f0    	cmp    0xf0220a60,%ebx
f0104257:	75 1a                	jne    f0104273 <print_trapframe+0xb2>
f0104259:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010425d:	75 14                	jne    f0104273 <print_trapframe+0xb2>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010425f:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104262:	83 ec 08             	sub    $0x8,%esp
f0104265:	50                   	push   %eax
f0104266:	68 9d 85 10 f0       	push   $0xf010859d
f010426b:	e8 f1 fb ff ff       	call   f0103e61 <cprintf>
f0104270:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0104273:	83 ec 08             	sub    $0x8,%esp
f0104276:	ff 73 2c             	pushl  0x2c(%ebx)
f0104279:	68 ac 85 10 f0       	push   $0xf01085ac
f010427e:	e8 de fb ff ff       	call   f0103e61 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104283:	83 c4 10             	add    $0x10,%esp
f0104286:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010428a:	75 45                	jne    f01042d1 <print_trapframe+0x110>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010428c:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010428f:	a8 01                	test   $0x1,%al
f0104291:	74 07                	je     f010429a <print_trapframe+0xd9>
f0104293:	b9 20 85 10 f0       	mov    $0xf0108520,%ecx
f0104298:	eb 05                	jmp    f010429f <print_trapframe+0xde>
f010429a:	b9 2b 85 10 f0       	mov    $0xf010852b,%ecx
f010429f:	a8 02                	test   $0x2,%al
f01042a1:	74 07                	je     f01042aa <print_trapframe+0xe9>
f01042a3:	ba 37 85 10 f0       	mov    $0xf0108537,%edx
f01042a8:	eb 05                	jmp    f01042af <print_trapframe+0xee>
f01042aa:	ba 3d 85 10 f0       	mov    $0xf010853d,%edx
f01042af:	a8 04                	test   $0x4,%al
f01042b1:	74 07                	je     f01042ba <print_trapframe+0xf9>
f01042b3:	b8 42 85 10 f0       	mov    $0xf0108542,%eax
f01042b8:	eb 05                	jmp    f01042bf <print_trapframe+0xfe>
f01042ba:	b8 77 86 10 f0       	mov    $0xf0108677,%eax
f01042bf:	51                   	push   %ecx
f01042c0:	52                   	push   %edx
f01042c1:	50                   	push   %eax
f01042c2:	68 ba 85 10 f0       	push   $0xf01085ba
f01042c7:	e8 95 fb ff ff       	call   f0103e61 <cprintf>
f01042cc:	83 c4 10             	add    $0x10,%esp
f01042cf:	eb 10                	jmp    f01042e1 <print_trapframe+0x120>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01042d1:	83 ec 0c             	sub    $0xc,%esp
f01042d4:	68 af 70 10 f0       	push   $0xf01070af
f01042d9:	e8 83 fb ff ff       	call   f0103e61 <cprintf>
f01042de:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01042e1:	83 ec 08             	sub    $0x8,%esp
f01042e4:	ff 73 30             	pushl  0x30(%ebx)
f01042e7:	68 c9 85 10 f0       	push   $0xf01085c9
f01042ec:	e8 70 fb ff ff       	call   f0103e61 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01042f1:	83 c4 08             	add    $0x8,%esp
f01042f4:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01042f8:	50                   	push   %eax
f01042f9:	68 d8 85 10 f0       	push   $0xf01085d8
f01042fe:	e8 5e fb ff ff       	call   f0103e61 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104303:	83 c4 08             	add    $0x8,%esp
f0104306:	ff 73 38             	pushl  0x38(%ebx)
f0104309:	68 eb 85 10 f0       	push   $0xf01085eb
f010430e:	e8 4e fb ff ff       	call   f0103e61 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104313:	83 c4 10             	add    $0x10,%esp
f0104316:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010431a:	74 25                	je     f0104341 <print_trapframe+0x180>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010431c:	83 ec 08             	sub    $0x8,%esp
f010431f:	ff 73 3c             	pushl  0x3c(%ebx)
f0104322:	68 fa 85 10 f0       	push   $0xf01085fa
f0104327:	e8 35 fb ff ff       	call   f0103e61 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010432c:	83 c4 08             	add    $0x8,%esp
f010432f:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104333:	50                   	push   %eax
f0104334:	68 09 86 10 f0       	push   $0xf0108609
f0104339:	e8 23 fb ff ff       	call   f0103e61 <cprintf>
f010433e:	83 c4 10             	add    $0x10,%esp
	}
}
f0104341:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104344:	c9                   	leave  
f0104345:	c3                   	ret    

f0104346 <page_fault_handler>:
	}
}

void
page_fault_handler(struct Trapframe *tf)
{
f0104346:	55                   	push   %ebp
f0104347:	89 e5                	mov    %esp,%ebp
f0104349:	57                   	push   %edi
f010434a:	56                   	push   %esi
f010434b:	53                   	push   %ebx
f010434c:	83 ec 1c             	sub    $0x1c,%esp
f010434f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104352:	0f 20 d0             	mov    %cr2,%eax
f0104355:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// cprintf("Page Fault: 0x%08x\n", fault_va);

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT)
f0104358:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010435d:	75 17                	jne    f0104376 <page_fault_handler+0x30>
    	panic("page_fault_handler : page fault in kernel\n");
f010435f:	83 ec 04             	sub    $0x4,%esp
f0104362:	68 c4 87 10 f0       	push   $0xf01087c4
f0104367:	68 63 01 00 00       	push   $0x163
f010436c:	68 1c 86 10 f0       	push   $0xf010861c
f0104371:	e8 f2 bc ff ff       	call   f0100068 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

    if (curenv->env_pgfault_upcall != NULL) {
f0104376:	e8 fd 22 00 00       	call   f0106678 <cpunum>
f010437b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104382:	29 c2                	sub    %eax,%edx
f0104384:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104387:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f010438e:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104392:	0f 84 01 01 00 00    	je     f0104499 <page_fault_handler+0x153>
    	// cprintf("user page fault, exist env's page fault upcall \n");
    	// exist env's page fault upcall
		// void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

    	struct UTrapframe * ut;
    	if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp <= UXSTACKTOP - 1) {
f0104398:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010439b:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f01043a1:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01043a7:	77 25                	ja     f01043ce <page_fault_handler+0x88>
    		// already in user exception stack, should first push an empty 32-bit word
    		ut = (struct UTrapframe *)((void *)tf->tf_esp - sizeof(struct UTrapframe) - 4);
f01043a9:	83 e8 38             	sub    $0x38,%eax
f01043ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe) + 4, PTE_U | PTE_W);
f01043af:	e8 c4 22 00 00       	call   f0106678 <cpunum>
f01043b4:	6a 06                	push   $0x6
f01043b6:	6a 38                	push   $0x38
f01043b8:	ff 75 e0             	pushl  -0x20(%ebp)
f01043bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01043be:	ff b0 28 10 22 f0    	pushl  -0xfddefd8(%eax)
f01043c4:	e8 a9 ef ff ff       	call   f0103372 <user_mem_assert>
f01043c9:	83 c4 10             	add    $0x10,%esp
f01043cc:	eb 26                	jmp    f01043f4 <page_fault_handler+0xae>
    	} else {
    		// it's the first time in user exception stack
    		ut = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe), PTE_U | PTE_W);
f01043ce:	e8 a5 22 00 00       	call   f0106678 <cpunum>
f01043d3:	6a 06                	push   $0x6
f01043d5:	6a 34                	push   $0x34
f01043d7:	68 cc ff bf ee       	push   $0xeebfffcc
f01043dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01043df:	ff b0 28 10 22 f0    	pushl  -0xfddefd8(%eax)
f01043e5:	e8 88 ef ff ff       	call   f0103372 <user_mem_assert>
f01043ea:	83 c4 10             	add    $0x10,%esp
    		// already in user exception stack, should first push an empty 32-bit word
    		ut = (struct UTrapframe *)((void *)tf->tf_esp - sizeof(struct UTrapframe) - 4);
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe) + 4, PTE_U | PTE_W);
    	} else {
    		// it's the first time in user exception stack
    		ut = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f01043ed:	c7 45 e0 cc ff bf ee 	movl   $0xeebfffcc,-0x20(%ebp)
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe), PTE_U | PTE_W);
    	}
    	
    	ut->utf_esp = tf->tf_esp;
f01043f4:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01043f7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01043fa:	89 42 30             	mov    %eax,0x30(%edx)
    	ut->utf_eflags = tf->tf_eflags;
f01043fd:	8b 43 38             	mov    0x38(%ebx),%eax
f0104400:	89 42 2c             	mov    %eax,0x2c(%edx)
    	ut->utf_eip = tf->tf_eip;
f0104403:	8b 43 30             	mov    0x30(%ebx),%eax
f0104406:	89 42 28             	mov    %eax,0x28(%edx)
		ut->utf_regs = tf->tf_regs;
f0104409:	89 d7                	mov    %edx,%edi
f010440b:	83 c7 08             	add    $0x8,%edi
f010440e:	89 de                	mov    %ebx,%esi
f0104410:	b8 20 00 00 00       	mov    $0x20,%eax
f0104415:	f7 c7 01 00 00 00    	test   $0x1,%edi
f010441b:	74 03                	je     f0104420 <page_fault_handler+0xda>
f010441d:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f010441e:	b0 1f                	mov    $0x1f,%al
f0104420:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104426:	74 05                	je     f010442d <page_fault_handler+0xe7>
f0104428:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010442a:	83 e8 02             	sub    $0x2,%eax
f010442d:	89 c1                	mov    %eax,%ecx
f010442f:	c1 e9 02             	shr    $0x2,%ecx
f0104432:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104434:	a8 02                	test   $0x2,%al
f0104436:	74 02                	je     f010443a <page_fault_handler+0xf4>
f0104438:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010443a:	a8 01                	test   $0x1,%al
f010443c:	74 01                	je     f010443f <page_fault_handler+0xf9>
f010443e:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		ut->utf_err = tf->tf_err;
f010443f:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104442:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104445:	89 42 04             	mov    %eax,0x4(%edx)
		ut->utf_fault_va = fault_va;
f0104448:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010444b:	89 02                	mov    %eax,(%edx)

		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f010444d:	e8 26 22 00 00       	call   f0106678 <cpunum>
f0104452:	6b c0 74             	imul   $0x74,%eax,%eax
f0104455:	8b 98 28 10 22 f0    	mov    -0xfddefd8(%eax),%ebx
f010445b:	e8 18 22 00 00       	call   f0106678 <cpunum>
f0104460:	6b c0 74             	imul   $0x74,%eax,%eax
f0104463:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0104469:	8b 40 64             	mov    0x64(%eax),%eax
f010446c:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (uint32_t)ut;
f010446f:	e8 04 22 00 00       	call   f0106678 <cpunum>
f0104474:	6b c0 74             	imul   $0x74,%eax,%eax
f0104477:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f010447d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104480:	89 50 3c             	mov    %edx,0x3c(%eax)
    	env_run(curenv);
f0104483:	e8 f0 21 00 00       	call   f0106678 <cpunum>
f0104488:	83 ec 0c             	sub    $0xc,%esp
f010448b:	6b c0 74             	imul   $0x74,%eax,%eax
f010448e:	ff b0 28 10 22 f0    	pushl  -0xfddefd8(%eax)
f0104494:	e8 64 f7 ff ff       	call   f0103bfd <env_run>
    } else {
    	// cprintf("user page fault, env_pgfault_upcall == NULL\n");
   	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104499:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f010449c:	e8 d7 21 00 00       	call   f0106678 <cpunum>
    } else {
    	// cprintf("user page fault, env_pgfault_upcall == NULL\n");
   	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01044a1:	56                   	push   %esi
f01044a2:	ff 75 e4             	pushl  -0x1c(%ebp)
		curenv->env_id, fault_va, tf->tf_eip);
f01044a5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044ac:	29 c2                	sub    %eax,%edx
f01044ae:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01044b1:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
    } else {
    	// cprintf("user page fault, env_pgfault_upcall == NULL\n");
   	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01044b8:	ff 70 48             	pushl  0x48(%eax)
f01044bb:	68 f0 87 10 f0       	push   $0xf01087f0
f01044c0:	e8 9c f9 ff ff       	call   f0103e61 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01044c5:	89 1c 24             	mov    %ebx,(%esp)
f01044c8:	e8 f4 fc ff ff       	call   f01041c1 <print_trapframe>
	env_destroy(curenv);
f01044cd:	e8 a6 21 00 00       	call   f0106678 <cpunum>
f01044d2:	83 c4 04             	add    $0x4,%esp
f01044d5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044dc:	29 c2                	sub    %eax,%edx
f01044de:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01044e1:	ff 34 85 28 10 22 f0 	pushl  -0xfddefd8(,%eax,4)
f01044e8:	e8 53 f6 ff ff       	call   f0103b40 <env_destroy>
f01044ed:	83 c4 10             	add    $0x10,%esp
}
f01044f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01044f3:	5b                   	pop    %ebx
f01044f4:	5e                   	pop    %esi
f01044f5:	5f                   	pop    %edi
f01044f6:	c9                   	leave  
f01044f7:	c3                   	ret    

f01044f8 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01044f8:	55                   	push   %ebp
f01044f9:	89 e5                	mov    %esp,%ebp
f01044fb:	57                   	push   %edi
f01044fc:	56                   	push   %esi
f01044fd:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104500:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104501:	83 3d 80 0e 22 f0 00 	cmpl   $0x0,0xf0220e80
f0104508:	74 01                	je     f010450b <trap+0x13>
		asm volatile("hlt");
f010450a:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010450b:	e8 68 21 00 00       	call   f0106678 <cpunum>
f0104510:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104517:	29 c2                	sub    %eax,%edx
f0104519:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010451c:	8d 14 85 20 10 22 f0 	lea    -0xfddefe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104523:	b8 01 00 00 00       	mov    $0x1,%eax
f0104528:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010452c:	83 f8 02             	cmp    $0x2,%eax
f010452f:	75 10                	jne    f0104541 <trap+0x49>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104531:	83 ec 0c             	sub    $0xc,%esp
f0104534:	68 60 94 12 f0       	push   $0xf0129460
f0104539:	e8 f1 23 00 00       	call   f010692f <spin_lock>
f010453e:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104541:	9c                   	pushf  
f0104542:	58                   	pop    %eax
		lock_kernel();

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104543:	f6 c4 02             	test   $0x2,%ah
f0104546:	74 19                	je     f0104561 <trap+0x69>
f0104548:	68 28 86 10 f0       	push   $0xf0108628
f010454d:	68 17 81 10 f0       	push   $0xf0108117
f0104552:	68 29 01 00 00       	push   $0x129
f0104557:	68 1c 86 10 f0       	push   $0xf010861c
f010455c:	e8 07 bb ff ff       	call   f0100068 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104561:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104565:	83 e0 03             	and    $0x3,%eax
f0104568:	83 f8 03             	cmp    $0x3,%eax
f010456b:	0f 85 dc 00 00 00    	jne    f010464d <trap+0x155>
f0104571:	83 ec 0c             	sub    $0xc,%esp
f0104574:	68 60 94 12 f0       	push   $0xf0129460
f0104579:	e8 b1 23 00 00       	call   f010692f <spin_lock>
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();

		assert(curenv);
f010457e:	e8 f5 20 00 00       	call   f0106678 <cpunum>
f0104583:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010458a:	29 c2                	sub    %eax,%edx
f010458c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010458f:	83 c4 10             	add    $0x10,%esp
f0104592:	83 3c 85 28 10 22 f0 	cmpl   $0x0,-0xfddefd8(,%eax,4)
f0104599:	00 
f010459a:	75 19                	jne    f01045b5 <trap+0xbd>
f010459c:	68 41 86 10 f0       	push   $0xf0108641
f01045a1:	68 17 81 10 f0       	push   $0xf0108117
f01045a6:	68 32 01 00 00       	push   $0x132
f01045ab:	68 1c 86 10 f0       	push   $0xf010861c
f01045b0:	e8 b3 ba ff ff       	call   f0100068 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01045b5:	e8 be 20 00 00       	call   f0106678 <cpunum>
f01045ba:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01045c1:	29 c2                	sub    %eax,%edx
f01045c3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01045c6:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f01045cd:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01045d1:	75 41                	jne    f0104614 <trap+0x11c>
			env_free(curenv);
f01045d3:	e8 a0 20 00 00       	call   f0106678 <cpunum>
f01045d8:	83 ec 0c             	sub    $0xc,%esp
f01045db:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01045e2:	29 c2                	sub    %eax,%edx
f01045e4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01045e7:	ff 34 85 28 10 22 f0 	pushl  -0xfddefd8(,%eax,4)
f01045ee:	e8 7e f3 ff ff       	call   f0103971 <env_free>
			curenv = NULL;
f01045f3:	e8 80 20 00 00       	call   f0106678 <cpunum>
f01045f8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01045ff:	29 c2                	sub    %eax,%edx
f0104601:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104604:	c7 04 85 28 10 22 f0 	movl   $0x0,-0xfddefd8(,%eax,4)
f010460b:	00 00 00 00 
			sched_yield();
f010460f:	e8 16 03 00 00       	call   f010492a <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104614:	e8 5f 20 00 00       	call   f0106678 <cpunum>
f0104619:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104620:	29 c2                	sub    %eax,%edx
f0104622:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104625:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f010462c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104631:	89 c7                	mov    %eax,%edi
f0104633:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104635:	e8 3e 20 00 00       	call   f0106678 <cpunum>
f010463a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104641:	29 c2                	sub    %eax,%edx
f0104643:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104646:	8b 34 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010464d:	89 35 60 0a 22 f0    	mov    %esi,0xf0220a60
	// LAB 3: Your code here.
    // cprintf("CPU %d, TRAP NUM : %u\n", cpunum(), tf->tf_trapno);
    
    int r;

	if (tf->tf_trapno == T_DEBUG) {
f0104653:	8b 46 28             	mov    0x28(%esi),%eax
f0104656:	83 f8 01             	cmp    $0x1,%eax
f0104659:	75 11                	jne    f010466c <trap+0x174>
		monitor(tf);
f010465b:	83 ec 0c             	sub    $0xc,%esp
f010465e:	56                   	push   %esi
f010465f:	e8 01 ca ff ff       	call   f0101065 <monitor>
f0104664:	83 c4 10             	add    $0x10,%esp
f0104667:	e9 e8 00 00 00       	jmp    f0104754 <trap+0x25c>
		return;
	}
	if (tf->tf_trapno == T_PGFLT) {
f010466c:	83 f8 0e             	cmp    $0xe,%eax
f010466f:	75 11                	jne    f0104682 <trap+0x18a>
		page_fault_handler(tf);
f0104671:	83 ec 0c             	sub    $0xc,%esp
f0104674:	56                   	push   %esi
f0104675:	e8 cc fc ff ff       	call   f0104346 <page_fault_handler>
f010467a:	83 c4 10             	add    $0x10,%esp
f010467d:	e9 d2 00 00 00       	jmp    f0104754 <trap+0x25c>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f0104682:	83 f8 03             	cmp    $0x3,%eax
f0104685:	75 11                	jne    f0104698 <trap+0x1a0>
		monitor(tf);
f0104687:	83 ec 0c             	sub    $0xc,%esp
f010468a:	56                   	push   %esi
f010468b:	e8 d5 c9 ff ff       	call   f0101065 <monitor>
f0104690:	83 c4 10             	add    $0x10,%esp
f0104693:	e9 bc 00 00 00       	jmp    f0104754 <trap+0x25c>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f0104698:	83 f8 30             	cmp    $0x30,%eax
f010469b:	75 24                	jne    f01046c1 <trap+0x1c9>
		r = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f010469d:	83 ec 08             	sub    $0x8,%esp
f01046a0:	ff 76 04             	pushl  0x4(%esi)
f01046a3:	ff 36                	pushl  (%esi)
f01046a5:	ff 76 10             	pushl  0x10(%esi)
f01046a8:	ff 76 18             	pushl  0x18(%esi)
f01046ab:	ff 76 14             	pushl  0x14(%esi)
f01046ae:	ff 76 1c             	pushl  0x1c(%esi)
f01046b1:	e8 86 03 00 00       	call   f0104a3c <syscall>
                       tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = r;
f01046b6:	89 46 1c             	mov    %eax,0x1c(%esi)
f01046b9:	83 c4 20             	add    $0x20,%esp
f01046bc:	e9 93 00 00 00       	jmp    f0104754 <trap+0x25c>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01046c1:	83 f8 27             	cmp    $0x27,%eax
f01046c4:	75 1a                	jne    f01046e0 <trap+0x1e8>
		cprintf("Spurious interrupt on irq 7\n");
f01046c6:	83 ec 0c             	sub    $0xc,%esp
f01046c9:	68 48 86 10 f0       	push   $0xf0108648
f01046ce:	e8 8e f7 ff ff       	call   f0103e61 <cprintf>
		print_trapframe(tf);
f01046d3:	89 34 24             	mov    %esi,(%esp)
f01046d6:	e8 e6 fa ff ff       	call   f01041c1 <print_trapframe>
f01046db:	83 c4 10             	add    $0x10,%esp
f01046de:	eb 74                	jmp    f0104754 <trap+0x25c>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01046e0:	83 f8 20             	cmp    $0x20,%eax
f01046e3:	75 0a                	jne    f01046ef <trap+0x1f7>
		lapic_eoi();
f01046e5:	e8 e8 20 00 00       	call   f01067d2 <lapic_eoi>
		sched_yield();
f01046ea:	e8 3b 02 00 00       	call   f010492a <sched_yield>
		return;
	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
    if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f01046ef:	83 f8 21             	cmp    $0x21,%eax
f01046f2:	75 07                	jne    f01046fb <trap+0x203>
        kbd_intr();
f01046f4:	e8 65 bf ff ff       	call   f010065e <kbd_intr>
f01046f9:	eb 59                	jmp    f0104754 <trap+0x25c>
        return;
    }

    if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f01046fb:	83 f8 24             	cmp    $0x24,%eax
f01046fe:	75 07                	jne    f0104707 <trap+0x20f>
        serial_intr();
f0104700:	e8 3e bf ff ff       	call   f0100643 <serial_intr>
f0104705:	eb 4d                	jmp    f0104754 <trap+0x25c>
        return;
    }

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104707:	83 ec 0c             	sub    $0xc,%esp
f010470a:	56                   	push   %esi
f010470b:	e8 b1 fa ff ff       	call   f01041c1 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104710:	83 c4 10             	add    $0x10,%esp
f0104713:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104718:	75 17                	jne    f0104731 <trap+0x239>
		panic("unhandled trap in kernel");
f010471a:	83 ec 04             	sub    $0x4,%esp
f010471d:	68 65 86 10 f0       	push   $0xf0108665
f0104722:	68 0e 01 00 00       	push   $0x10e
f0104727:	68 1c 86 10 f0       	push   $0xf010861c
f010472c:	e8 37 b9 ff ff       	call   f0100068 <_panic>
	else {
		env_destroy(curenv);
f0104731:	e8 42 1f 00 00       	call   f0106678 <cpunum>
f0104736:	83 ec 0c             	sub    $0xc,%esp
f0104739:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104740:	29 c2                	sub    %eax,%edx
f0104742:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104745:	ff 34 85 28 10 22 f0 	pushl  -0xfddefd8(,%eax,4)
f010474c:	e8 ef f3 ff ff       	call   f0103b40 <env_destroy>
f0104751:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0104754:	e8 1f 1f 00 00       	call   f0106678 <cpunum>
f0104759:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104760:	29 c2                	sub    %eax,%edx
f0104762:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104765:	83 3c 85 28 10 22 f0 	cmpl   $0x0,-0xfddefd8(,%eax,4)
f010476c:	00 
f010476d:	74 3e                	je     f01047ad <trap+0x2b5>
f010476f:	e8 04 1f 00 00       	call   f0106678 <cpunum>
f0104774:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010477b:	29 c2                	sub    %eax,%edx
f010477d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104780:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0104787:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010478b:	75 20                	jne    f01047ad <trap+0x2b5>
		// cprintf("Env\n");
		env_run(curenv);
f010478d:	e8 e6 1e 00 00       	call   f0106678 <cpunum>
f0104792:	83 ec 0c             	sub    $0xc,%esp
f0104795:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010479c:	29 c2                	sub    %eax,%edx
f010479e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01047a1:	ff 34 85 28 10 22 f0 	pushl  -0xfddefd8(,%eax,4)
f01047a8:	e8 50 f4 ff ff       	call   f0103bfd <env_run>
	} else {
		// cprintf("trap sched_yield\n");
		sched_yield();
f01047ad:	e8 78 01 00 00       	call   f010492a <sched_yield>
	...

f01047b4 <vec0>:
.data
.align 2
.globl vectors
vectors:
.text
	MYTH_NOEC(vec0, T_DIVIDE)
f01047b4:	6a 00                	push   $0x0
f01047b6:	6a 00                	push   $0x0
f01047b8:	e9 59 4c 02 00       	jmp    f0129416 <_alltraps>
f01047bd:	90                   	nop

f01047be <vec1>:
 	MYTH_NOEC(vec1, T_DEBUG)
f01047be:	6a 00                	push   $0x0
f01047c0:	6a 01                	push   $0x1
f01047c2:	e9 4f 4c 02 00       	jmp    f0129416 <_alltraps>
f01047c7:	90                   	nop

f01047c8 <vec2>:
 	MYTH_NOEC(vec2, T_NMI)
f01047c8:	6a 00                	push   $0x0
f01047ca:	6a 02                	push   $0x2
f01047cc:	e9 45 4c 02 00       	jmp    f0129416 <_alltraps>
f01047d1:	90                   	nop

f01047d2 <vec3>:
 	MYTH_NOEC(vec3, T_BRKPT)
f01047d2:	6a 00                	push   $0x0
f01047d4:	6a 03                	push   $0x3
f01047d6:	e9 3b 4c 02 00       	jmp    f0129416 <_alltraps>
f01047db:	90                   	nop

f01047dc <vec4>:
 	MYTH_NOEC(vec4, T_OFLOW)
f01047dc:	6a 00                	push   $0x0
f01047de:	6a 04                	push   $0x4
f01047e0:	e9 31 4c 02 00       	jmp    f0129416 <_alltraps>
f01047e5:	90                   	nop

f01047e6 <vec6>:
 	MYTH_NULL()
 	MYTH_NOEC(vec6, T_BOUND)
f01047e6:	6a 00                	push   $0x0
f01047e8:	6a 05                	push   $0x5
f01047ea:	e9 27 4c 02 00       	jmp    f0129416 <_alltraps>
f01047ef:	90                   	nop

f01047f0 <vec7>:
	MYTH_NOEC(vec7, T_DEVICE)
f01047f0:	6a 00                	push   $0x0
f01047f2:	6a 07                	push   $0x7
f01047f4:	e9 1d 4c 02 00       	jmp    f0129416 <_alltraps>
f01047f9:	90                   	nop

f01047fa <vec8>:
 	MYTH(vec8, T_DBLFLT)
f01047fa:	6a 08                	push   $0x8
f01047fc:	e9 15 4c 02 00       	jmp    f0129416 <_alltraps>
f0104801:	90                   	nop

f0104802 <vec10>:
 	MYTH_NULL()
 	MYTH(vec10, T_TSS)
f0104802:	6a 0a                	push   $0xa
f0104804:	e9 0d 4c 02 00       	jmp    f0129416 <_alltraps>
f0104809:	90                   	nop

f010480a <vec11>:
 	MYTH(vec11, T_SEGNP)
f010480a:	6a 0b                	push   $0xb
f010480c:	e9 05 4c 02 00       	jmp    f0129416 <_alltraps>
f0104811:	90                   	nop

f0104812 <vec12>:
 	MYTH(vec12, T_STACK)
f0104812:	6a 0c                	push   $0xc
f0104814:	e9 fd 4b 02 00       	jmp    f0129416 <_alltraps>
f0104819:	90                   	nop

f010481a <vec13>:
 	MYTH(vec13, T_GPFLT)
f010481a:	6a 0d                	push   $0xd
f010481c:	e9 f5 4b 02 00       	jmp    f0129416 <_alltraps>
f0104821:	90                   	nop

f0104822 <vec14>:
 	MYTH(vec14, T_PGFLT) 
f0104822:	6a 0e                	push   $0xe
f0104824:	e9 ed 4b 02 00       	jmp    f0129416 <_alltraps>
f0104829:	90                   	nop

f010482a <vec16>:
 	MYTH_NULL()
 	MYTH_NOEC(vec16, T_FPERR)
f010482a:	6a 00                	push   $0x0
f010482c:	6a 10                	push   $0x10
f010482e:	e9 e3 4b 02 00       	jmp    f0129416 <_alltraps>
f0104833:	90                   	nop

f0104834 <vec17>:
 	MYTH(vec17, T_ALIGN)
f0104834:	6a 11                	push   $0x11
f0104836:	e9 db 4b 02 00       	jmp    f0129416 <_alltraps>
f010483b:	90                   	nop

f010483c <vec18>:
 	MYTH_NOEC(vec18, T_MCHK)
f010483c:	6a 00                	push   $0x0
f010483e:	6a 12                	push   $0x12
f0104840:	e9 d1 4b 02 00       	jmp    f0129416 <_alltraps>
f0104845:	90                   	nop

f0104846 <vec19>:
 	MYTH_NOEC(vec19, T_SIMDERR)
f0104846:	6a 00                	push   $0x0
f0104848:	6a 13                	push   $0x13
f010484a:	e9 c7 4b 02 00       	jmp    f0129416 <_alltraps>
	...

f0104850 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104850:	55                   	push   %ebp
f0104851:	89 e5                	mov    %esp,%ebp
f0104853:	83 ec 08             	sub    $0x8,%esp
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104856:	8b 15 3c 02 22 f0    	mov    0xf022023c,%edx
		     envs[i].env_status == ENV_RUNNING ||
f010485c:	8b 42 54             	mov    0x54(%edx),%eax
f010485f:	48                   	dec    %eax
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104860:	83 f8 02             	cmp    $0x2,%eax
f0104863:	76 47                	jbe    f01048ac <sched_halt+0x5c>
			else cprintf("ENV_RUNNING\n");
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
f0104865:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f010486a:	8b 8a d8 00 00 00    	mov    0xd8(%edx),%ecx
f0104870:	49                   	dec    %ecx
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104871:	83 f9 02             	cmp    $0x2,%ecx
f0104874:	76 10                	jbe    f0104886 <sched_halt+0x36>
			else cprintf("ENV_RUNNING\n");
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
f0104876:	40                   	inc    %eax
f0104877:	81 c2 84 00 00 00    	add    $0x84,%edx
f010487d:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104882:	75 e6                	jne    f010486a <sched_halt+0x1a>
f0104884:	eb 07                	jmp    f010488d <sched_halt+0x3d>
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	
	if (i == NENV) {
f0104886:	3d 00 04 00 00       	cmp    $0x400,%eax
f010488b:	75 1f                	jne    f01048ac <sched_halt+0x5c>
		cprintf("No runnable environments in the system!\n");
f010488d:	83 ec 0c             	sub    $0xc,%esp
f0104890:	68 70 88 10 f0       	push   $0xf0108870
f0104895:	e8 c7 f5 ff ff       	call   f0103e61 <cprintf>
f010489a:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010489d:	83 ec 0c             	sub    $0xc,%esp
f01048a0:	6a 00                	push   $0x0
f01048a2:	e8 be c7 ff ff       	call   f0101065 <monitor>
f01048a7:	83 c4 10             	add    $0x10,%esp
f01048aa:	eb f1                	jmp    f010489d <sched_halt+0x4d>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01048ac:	e8 c7 1d 00 00       	call   f0106678 <cpunum>
f01048b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01048b4:	c7 80 28 10 22 f0 00 	movl   $0x0,-0xfddefd8(%eax)
f01048bb:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01048be:	a1 8c 0e 22 f0       	mov    0xf0220e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01048c3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01048c8:	77 12                	ja     f01048dc <sched_halt+0x8c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01048ca:	50                   	push   %eax
f01048cb:	68 64 6d 10 f0       	push   $0xf0106d64
f01048d0:	6a 58                	push   $0x58
f01048d2:	68 99 88 10 f0       	push   $0xf0108899
f01048d7:	e8 8c b7 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01048dc:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01048e1:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01048e4:	e8 8f 1d 00 00       	call   f0106678 <cpunum>
f01048e9:	6b d0 74             	imul   $0x74,%eax,%edx
f01048ec:	81 c2 20 10 22 f0    	add    $0xf0221020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01048f2:	b8 02 00 00 00       	mov    $0x2,%eax
f01048f7:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01048fb:	83 ec 0c             	sub    $0xc,%esp
f01048fe:	68 60 94 12 f0       	push   $0xf0129460
f0104903:	e8 e2 20 00 00       	call   f01069ea <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104908:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010490a:	e8 69 1d 00 00       	call   f0106678 <cpunum>
f010490f:	6b c0 74             	imul   $0x74,%eax,%eax
	// Release the big kernel lock as if we were "leaving" the kernel
	
	unlock_kernel();
	
	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104912:	8b 80 30 10 22 f0    	mov    -0xfddefd0(%eax),%eax
f0104918:	bd 00 00 00 00       	mov    $0x0,%ebp
f010491d:	89 c4                	mov    %eax,%esp
f010491f:	6a 00                	push   $0x0
f0104921:	6a 00                	push   $0x0
f0104923:	fb                   	sti    
f0104924:	f4                   	hlt    
f0104925:	83 c4 10             	add    $0x10,%esp
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104928:	c9                   	leave  
f0104929:	c3                   	ret    

f010492a <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010492a:	55                   	push   %ebp
f010492b:	89 e5                	mov    %esp,%ebp
f010492d:	53                   	push   %ebx
f010492e:	83 ec 04             	sub    $0x4,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int now_env, i;
	if (curenv) {			// thiscpu->cpu_env
f0104931:	e8 42 1d 00 00       	call   f0106678 <cpunum>
f0104936:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010493d:	29 c2                	sub    %eax,%edx
f010493f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104942:	83 3c 85 28 10 22 f0 	cmpl   $0x0,-0xfddefd8(,%eax,4)
f0104949:	00 
f010494a:	74 2e                	je     f010497a <sched_yield+0x50>
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
f010494c:	e8 27 1d 00 00       	call   f0106678 <cpunum>
f0104951:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104958:	29 c2                	sub    %eax,%edx
f010495a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010495d:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0104964:	8b 40 48             	mov    0x48(%eax),%eax
f0104967:	8d 40 01             	lea    0x1(%eax),%eax
f010496a:	25 ff 03 00 00       	and    $0x3ff,%eax
f010496f:	79 0e                	jns    f010497f <sched_yield+0x55>
f0104971:	48                   	dec    %eax
f0104972:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0104977:	40                   	inc    %eax
f0104978:	eb 05                	jmp    f010497f <sched_yield+0x55>
	} else {
		now_env = 0;
f010497a:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
		if (envs[now_env].env_status == ENV_RUNNABLE) {
f010497f:	8b 1d 3c 02 22 f0    	mov    0xf022023c,%ebx
f0104985:	89 c2                	mov    %eax,%edx
f0104987:	c1 e2 07             	shl    $0x7,%edx
f010498a:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f010498d:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f0104990:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f0104994:	0f 85 87 00 00 00    	jne    f0104a21 <sched_yield+0xf7>
f010499a:	eb 20                	jmp    f01049bc <sched_yield+0x92>
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f010499c:	40                   	inc    %eax
f010499d:	25 ff 03 00 80       	and    $0x800003ff,%eax
f01049a2:	79 07                	jns    f01049ab <sched_yield+0x81>
f01049a4:	48                   	dec    %eax
f01049a5:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f01049aa:	40                   	inc    %eax
		if (envs[now_env].env_status == ENV_RUNNABLE) {
f01049ab:	89 c1                	mov    %eax,%ecx
f01049ad:	c1 e1 07             	shl    $0x7,%ecx
f01049b0:	8d 0c 81             	lea    (%ecx,%eax,4),%ecx
f01049b3:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f01049b6:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f01049ba:	75 09                	jne    f01049c5 <sched_yield+0x9b>
			env_run(&envs[now_env]);	
f01049bc:	83 ec 0c             	sub    $0xc,%esp
f01049bf:	51                   	push   %ecx
f01049c0:	e8 38 f2 ff ff       	call   f0103bfd <env_run>
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f01049c5:	4a                   	dec    %edx
f01049c6:	75 d4                	jne    f010499c <sched_yield+0x72>
		if (envs[now_env].env_status == ENV_RUNNABLE) {
			env_run(&envs[now_env]);	
		}
	}

	if (curenv && curenv->env_status == ENV_RUNNING) {
f01049c8:	e8 ab 1c 00 00       	call   f0106678 <cpunum>
f01049cd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01049d4:	29 c2                	sub    %eax,%edx
f01049d6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01049d9:	83 3c 85 28 10 22 f0 	cmpl   $0x0,-0xfddefd8(,%eax,4)
f01049e0:	00 
f01049e1:	74 34                	je     f0104a17 <sched_yield+0xed>
f01049e3:	e8 90 1c 00 00       	call   f0106678 <cpunum>
f01049e8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01049ef:	29 c2                	sub    %eax,%edx
f01049f1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01049f4:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f01049fb:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01049ff:	75 16                	jne    f0104a17 <sched_yield+0xed>
		env_run(curenv);
f0104a01:	e8 72 1c 00 00       	call   f0106678 <cpunum>
f0104a06:	83 ec 0c             	sub    $0xc,%esp
f0104a09:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a0c:	ff b0 28 10 22 f0    	pushl  -0xfddefd8(%eax)
f0104a12:	e8 e6 f1 ff ff       	call   f0103bfd <env_run>
	}

	// sched_halt never returns
	sched_halt();
f0104a17:	e8 34 fe ff ff       	call   f0104850 <sched_halt>
}
f0104a1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104a1f:	c9                   	leave  
f0104a20:	c3                   	ret    
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f0104a21:	40                   	inc    %eax
f0104a22:	25 ff 03 00 80       	and    $0x800003ff,%eax
f0104a27:	79 07                	jns    f0104a30 <sched_yield+0x106>
f0104a29:	48                   	dec    %eax
f0104a2a:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0104a2f:	40                   	inc    %eax
f0104a30:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0104a35:	e9 71 ff ff ff       	jmp    f01049ab <sched_yield+0x81>
	...

f0104a3c <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104a3c:	55                   	push   %ebp
f0104a3d:	89 e5                	mov    %esp,%ebp
f0104a3f:	57                   	push   %edi
f0104a40:	56                   	push   %esi
f0104a41:	53                   	push   %ebx
f0104a42:	83 ec 3c             	sub    $0x3c,%esp
f0104a45:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104a4b:	8b 75 10             	mov    0x10(%ebp),%esi
f0104a4e:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Return any appropriate return value.
	// LAB 3: Your code here.
    
    // cprintf("SYSCALLNO %d\n", syscallno);
	int r = 0;
    switch (syscallno) {
f0104a51:	83 f8 12             	cmp    $0x12,%eax
f0104a54:	0f 87 e0 09 00 00    	ja     f010543a <syscall+0x9fe>
f0104a5a:	ff 24 85 a8 88 10 f0 	jmp    *-0xfef7758(,%eax,4)
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env * new_env;
	int r = env_alloc(&new_env, curenv->env_id);
f0104a61:	e8 12 1c 00 00       	call   f0106678 <cpunum>
f0104a66:	83 ec 08             	sub    $0x8,%esp
f0104a69:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104a70:	29 c2                	sub    %eax,%edx
f0104a72:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a75:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0104a7c:	ff 70 48             	pushl  0x48(%eax)
f0104a7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a82:	50                   	push   %eax
f0104a83:	e8 2b ec ff ff       	call   f01036b3 <env_alloc>
	if (r < 0) return r;
f0104a88:	83 c4 10             	add    $0x10,%esp
f0104a8b:	85 c0                	test   %eax,%eax
f0104a8d:	0f 88 cf 09 00 00    	js     f0105462 <syscall+0xa26>
	
	new_env->env_status = ENV_NOT_RUNNABLE;
f0104a93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a96:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memcpy((void *)(&new_env->env_tf), (void*)(&curenv->env_tf), sizeof(struct Trapframe));
f0104a9d:	e8 d6 1b 00 00       	call   f0106678 <cpunum>
f0104aa2:	83 ec 04             	sub    $0x4,%esp
f0104aa5:	6a 44                	push   $0x44
f0104aa7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104aae:	29 c2                	sub    %eax,%edx
f0104ab0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ab3:	ff 34 85 28 10 22 f0 	pushl  -0xfddefd8(,%eax,4)
f0104aba:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104abd:	e8 3b 16 00 00       	call   f01060fd <memcpy>
	
	// for children environment, return 0
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104ac2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ac5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return new_env->env_id;
f0104acc:	8b 40 48             	mov    0x48(%eax),%eax
f0104acf:	83 c4 10             	add    $0x10,%esp
    // cprintf("SYSCALLNO %d\n", syscallno);
	int r = 0;
    switch (syscallno) {
    	case SYS_exofork:
    		r = sys_exofork();
    		break;
f0104ad2:	e9 8b 09 00 00       	jmp    f0105462 <syscall+0xa26>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	// LAB 4: Your code here.

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
f0104ad7:	83 fe 02             	cmp    $0x2,%esi
f0104ada:	74 05                	je     f0104ae1 <syscall+0xa5>
f0104adc:	83 fe 04             	cmp    $0x4,%esi
f0104adf:	75 2a                	jne    f0104b0b <syscall+0xcf>
		return -E_INVAL;

	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104ae1:	83 ec 04             	sub    $0x4,%esp
f0104ae4:	6a 01                	push   $0x1
f0104ae6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ae9:	50                   	push   %eax
f0104aea:	53                   	push   %ebx
f0104aeb:	e8 52 e9 ff ff       	call   f0103442 <envid2env>
	if (r < 0) return r;
f0104af0:	83 c4 10             	add    $0x10,%esp
f0104af3:	85 c0                	test   %eax,%eax
f0104af5:	0f 88 67 09 00 00    	js     f0105462 <syscall+0xa26>
	env->env_status = status;
f0104afb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104afe:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f0104b01:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b06:	e9 57 09 00 00       	jmp    f0105462 <syscall+0xa26>
	// check whether the current environment has permission to set
	// envid's status.
	// LAB 4: Your code here.

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
		return -E_INVAL;
f0104b0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
    	case SYS_exofork:
    		r = sys_exofork();
    		break;
    	case SYS_env_set_status:
    		r = sys_env_set_status((envid_t)a1, (int)a2);
    		break;
f0104b10:	e9 4d 09 00 00       	jmp    f0105462 <syscall+0xa26>
	//   allocated!
	// LAB 4: Your code here.
	// cprintf("In kernel sys_page_alloc function\n");

	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104b15:	83 ec 04             	sub    $0x4,%esp
f0104b18:	6a 01                	push   $0x1
f0104b1a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b1d:	50                   	push   %eax
f0104b1e:	53                   	push   %ebx
f0104b1f:	e8 1e e9 ff ff       	call   f0103442 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104b24:	83 c4 10             	add    $0x10,%esp
f0104b27:	85 c0                	test   %eax,%eax
f0104b29:	0f 88 88 00 00 00    	js     f0104bb7 <syscall+0x17b>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104b2f:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104b35:	0f 87 86 00 00 00    	ja     f0104bc1 <syscall+0x185>
f0104b3b:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0104b41:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104b47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b4c:	39 d6                	cmp    %edx,%esi
f0104b4e:	0f 85 0e 09 00 00    	jne    f0105462 <syscall+0xa26>
	
	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;
f0104b54:	89 fa                	mov    %edi,%edx
f0104b56:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f0104b5c:	83 fa 05             	cmp    $0x5,%edx
f0104b5f:	0f 85 fd 08 00 00    	jne    f0105462 <syscall+0xa26>

	struct PageInfo * pg = page_alloc(ALLOC_ZERO);
f0104b65:	83 ec 0c             	sub    $0xc,%esp
f0104b68:	6a 01                	push   $0x1
f0104b6a:	e8 92 ca ff ff       	call   f0101601 <page_alloc>
f0104b6f:	89 c3                	mov    %eax,%ebx
	if (pg == NULL) return -E_NO_MEM;
f0104b71:	83 c4 10             	add    $0x10,%esp
f0104b74:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104b79:	85 db                	test   %ebx,%ebx
f0104b7b:	0f 84 e1 08 00 00    	je     f0105462 <syscall+0xa26>
	if (page_insert(env->env_pgdir, pg, va, perm) < 0) {
f0104b81:	57                   	push   %edi
f0104b82:	56                   	push   %esi
f0104b83:	53                   	push   %ebx
f0104b84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b87:	ff 70 60             	pushl  0x60(%eax)
f0104b8a:	e8 1e cd ff ff       	call   f01018ad <page_insert>
f0104b8f:	89 c2                	mov    %eax,%edx
f0104b91:	83 c4 10             	add    $0x10,%esp
		// page_insert fails, should free the page you allocated!  
		page_free(pg);
		return -E_NO_MEM;
	}
	return 0;
f0104b94:	b8 00 00 00 00       	mov    $0x0,%eax
	
	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;

	struct PageInfo * pg = page_alloc(ALLOC_ZERO);
	if (pg == NULL) return -E_NO_MEM;
	if (page_insert(env->env_pgdir, pg, va, perm) < 0) {
f0104b99:	85 d2                	test   %edx,%edx
f0104b9b:	0f 89 c1 08 00 00    	jns    f0105462 <syscall+0xa26>
		// page_insert fails, should free the page you allocated!  
		page_free(pg);
f0104ba1:	83 ec 0c             	sub    $0xc,%esp
f0104ba4:	53                   	push   %ebx
f0104ba5:	e8 e1 ca ff ff       	call   f010168b <page_free>
f0104baa:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104bad:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104bb2:	e9 ab 08 00 00       	jmp    f0105462 <syscall+0xa26>
	// LAB 4: Your code here.
	// cprintf("In kernel sys_page_alloc function\n");

	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;
f0104bb7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104bbc:	e9 a1 08 00 00       	jmp    f0105462 <syscall+0xa26>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104bc1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104bc6:	e9 97 08 00 00       	jmp    f0105462 <syscall+0xa26>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	// LAB 4: Your code here.

	struct Env * dstenv, * srcenv;
	int r = envid2env(dstenvid, &dstenv, 1);
f0104bcb:	83 ec 04             	sub    $0x4,%esp
f0104bce:	6a 01                	push   $0x1
f0104bd0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104bd3:	50                   	push   %eax
f0104bd4:	57                   	push   %edi
f0104bd5:	e8 68 e8 ff ff       	call   f0103442 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104bda:	83 c4 10             	add    $0x10,%esp
f0104bdd:	85 c0                	test   %eax,%eax
f0104bdf:	0f 88 d1 00 00 00    	js     f0104cb6 <syscall+0x27a>
	r = envid2env(srcenvid, &srcenv, 1);
f0104be5:	83 ec 04             	sub    $0x4,%esp
f0104be8:	6a 01                	push   $0x1
f0104bea:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104bed:	50                   	push   %eax
f0104bee:	53                   	push   %ebx
f0104bef:	e8 4e e8 ff ff       	call   f0103442 <envid2env>
f0104bf4:	89 c2                	mov    %eax,%edx
	if (r < 0) return -E_BAD_ENV;
f0104bf6:	83 c4 10             	add    $0x10,%esp
f0104bf9:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104bfe:	85 d2                	test   %edx,%edx
f0104c00:	0f 88 5c 08 00 00    	js     f0105462 <syscall+0xa26>

	if ((uint32_t)srcva >= UTOP || ROUNDUP(srcva, PGSIZE) != srcva) return -E_INVAL;
f0104c06:	b0 fd                	mov    $0xfd,%al
f0104c08:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104c0e:	0f 87 4e 08 00 00    	ja     f0105462 <syscall+0xa26>
f0104c14:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0104c1a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104c20:	39 d6                	cmp    %edx,%esi
f0104c22:	0f 85 3a 08 00 00    	jne    f0105462 <syscall+0xa26>
	if ((uint32_t)dstva >= UTOP || ROUNDUP(dstva, PGSIZE) != dstva) return -E_INVAL;
f0104c28:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104c2f:	0f 87 2d 08 00 00    	ja     f0105462 <syscall+0xa26>
f0104c35:	8b 55 18             	mov    0x18(%ebp),%edx
f0104c38:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0104c3e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104c44:	39 55 18             	cmp    %edx,0x18(%ebp)
f0104c47:	0f 85 15 08 00 00    	jne    f0105462 <syscall+0xa26>


	// struct PageInfo * page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
	struct PageInfo * pg;
	pte_t * pte;
	pg = page_lookup(srcenv->env_pgdir, srcva, &pte);
f0104c4d:	83 ec 04             	sub    $0x4,%esp
f0104c50:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104c53:	50                   	push   %eax
f0104c54:	56                   	push   %esi
f0104c55:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104c58:	ff 70 60             	pushl  0x60(%eax)
f0104c5b:	e8 51 cb ff ff       	call   f01017b1 <page_lookup>
f0104c60:	89 c2                	mov    %eax,%edx
	if (pg == NULL) return -E_INVAL;		
f0104c62:	83 c4 10             	add    $0x10,%esp
f0104c65:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c6a:	85 d2                	test   %edx,%edx
f0104c6c:	0f 84 f0 07 00 00    	je     f0105462 <syscall+0xa26>

	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;
f0104c72:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104c75:	81 e1 fd f1 ff ff    	and    $0xfffff1fd,%ecx
f0104c7b:	83 f9 05             	cmp    $0x5,%ecx
f0104c7e:	0f 85 de 07 00 00    	jne    f0105462 <syscall+0xa26>
	
	if ((perm & PTE_W) && ((*pte) & PTE_W) == 0) return -E_INVAL;
f0104c84:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104c88:	74 0c                	je     f0104c96 <syscall+0x25a>
f0104c8a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104c8d:	f6 01 02             	testb  $0x2,(%ecx)
f0104c90:	0f 84 cc 07 00 00    	je     f0105462 <syscall+0xa26>

	// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	if (page_insert(dstenv->env_pgdir, pg, dstva, perm) < 0) return -E_NO_MEM;
f0104c96:	ff 75 1c             	pushl  0x1c(%ebp)
f0104c99:	ff 75 18             	pushl  0x18(%ebp)
f0104c9c:	52                   	push   %edx
f0104c9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ca0:	ff 70 60             	pushl  0x60(%eax)
f0104ca3:	e8 05 cc ff ff       	call   f01018ad <page_insert>
f0104ca8:	83 c4 10             	add    $0x10,%esp
f0104cab:	c1 f8 1f             	sar    $0x1f,%eax
f0104cae:	83 e0 fc             	and    $0xfffffffc,%eax
f0104cb1:	e9 ac 07 00 00       	jmp    f0105462 <syscall+0xa26>
	//   check the current permissions on the page.
	// LAB 4: Your code here.

	struct Env * dstenv, * srcenv;
	int r = envid2env(dstenvid, &dstenv, 1);
	if (r < 0) return -E_BAD_ENV;
f0104cb6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104cbb:	e9 a2 07 00 00       	jmp    f0105462 <syscall+0xa26>
{
	// Hint: This function is a wrapper around page_remove().
	// LAB 4: Your code here.

	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104cc0:	83 ec 04             	sub    $0x4,%esp
f0104cc3:	6a 01                	push   $0x1
f0104cc5:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104cc8:	50                   	push   %eax
f0104cc9:	53                   	push   %ebx
f0104cca:	e8 73 e7 ff ff       	call   f0103442 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104ccf:	83 c4 10             	add    $0x10,%esp
f0104cd2:	85 c0                	test   %eax,%eax
f0104cd4:	78 3d                	js     f0104d13 <syscall+0x2d7>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104cd6:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104cdc:	77 3f                	ja     f0104d1d <syscall+0x2e1>
f0104cde:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0104ce4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104cea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104cef:	39 d6                	cmp    %edx,%esi
f0104cf1:	0f 85 6b 07 00 00    	jne    f0105462 <syscall+0xa26>
	
	// void page_remove(pde_t *pgdir, void *va)
	page_remove(env->env_pgdir, va);
f0104cf7:	83 ec 08             	sub    $0x8,%esp
f0104cfa:	56                   	push   %esi
f0104cfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cfe:	ff 70 60             	pushl  0x60(%eax)
f0104d01:	e8 5a cb ff ff       	call   f0101860 <page_remove>
f0104d06:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104d09:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d0e:	e9 4f 07 00 00       	jmp    f0105462 <syscall+0xa26>
	// Hint: This function is a wrapper around page_remove().
	// LAB 4: Your code here.

	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;
f0104d13:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104d18:	e9 45 07 00 00       	jmp    f0105462 <syscall+0xa26>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104d1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d22:	e9 3b 07 00 00       	jmp    f0105462 <syscall+0xa26>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// cprintf("In kernel sys_env_set_pgfault_upcall function\n");
	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104d27:	83 ec 04             	sub    $0x4,%esp
f0104d2a:	6a 01                	push   $0x1
f0104d2c:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104d2f:	50                   	push   %eax
f0104d30:	53                   	push   %ebx
f0104d31:	e8 0c e7 ff ff       	call   f0103442 <envid2env>
	if (r < 0) return r;
f0104d36:	83 c4 10             	add    $0x10,%esp
f0104d39:	85 c0                	test   %eax,%eax
f0104d3b:	0f 88 21 07 00 00    	js     f0105462 <syscall+0xa26>

	env->env_pgfault_upcall = func;
f0104d41:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d44:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f0104d47:	b8 00 00 00 00       	mov    $0x0,%eax
    	case SYS_page_unmap:
    		r = sys_page_unmap((envid_t)a1, (void *)a2);
    		break;
    	case SYS_env_set_pgfault_upcall:
    		r = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
    		break;
f0104d4c:	e9 11 07 00 00       	jmp    f0105462 <syscall+0xa26>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104d51:	e8 d4 fb ff ff       	call   f010492a <sched_yield>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, (void *)s, len, PTE_U);
f0104d56:	e8 1d 19 00 00       	call   f0106678 <cpunum>
f0104d5b:	6a 04                	push   $0x4
f0104d5d:	56                   	push   %esi
f0104d5e:	53                   	push   %ebx
f0104d5f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d66:	29 c2                	sub    %eax,%edx
f0104d68:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d6b:	ff 34 85 28 10 22 f0 	pushl  -0xfddefd8(,%eax,4)
f0104d72:	e8 fb e5 ff ff       	call   f0103372 <user_mem_assert>
    
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104d77:	83 c4 0c             	add    $0xc,%esp
f0104d7a:	53                   	push   %ebx
f0104d7b:	56                   	push   %esi
f0104d7c:	68 1f 71 10 f0       	push   $0xf010711f
f0104d81:	e8 db f0 ff ff       	call   f0103e61 <cprintf>
f0104d86:	83 c4 10             	add    $0x10,%esp
    		sys_yield();
    		r = 0;
    		break;
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            r = 0;
f0104d89:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d8e:	e9 cf 06 00 00       	jmp    f0105462 <syscall+0xa26>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104d93:	e8 d8 b8 ff ff       	call   f0100670 <cons_getc>
            sys_cputs((char *)a1, (size_t)a2);
            r = 0;
            break;
        case SYS_cgetc:
            r = sys_cgetc();
            break;
f0104d98:	e9 c5 06 00 00       	jmp    f0105462 <syscall+0xa26>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104d9d:	e8 d6 18 00 00       	call   f0106678 <cpunum>
f0104da2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104da9:	29 c2                	sub    %eax,%edx
f0104dab:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104dae:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0104db5:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_cgetc:
            r = sys_cgetc();
            break;
        case SYS_getenvid:
            r = sys_getenvid();
            break;
f0104db8:	e9 a5 06 00 00       	jmp    f0105462 <syscall+0xa26>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104dbd:	83 ec 04             	sub    $0x4,%esp
f0104dc0:	6a 01                	push   $0x1
f0104dc2:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104dc5:	50                   	push   %eax
f0104dc6:	53                   	push   %ebx
f0104dc7:	e8 76 e6 ff ff       	call   f0103442 <envid2env>
f0104dcc:	83 c4 10             	add    $0x10,%esp
f0104dcf:	85 c0                	test   %eax,%eax
f0104dd1:	0f 88 8b 06 00 00    	js     f0105462 <syscall+0xa26>
		return r;
	
	// if it is not a thread, then have to kill all the thread
	if (!e->isthread) {
f0104dd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104dda:	80 78 7c 00          	cmpb   $0x0,0x7c(%eax)
f0104dde:	0f 85 db 00 00 00    	jne    f0104ebf <syscall+0x483>
f0104de4:	be 00 00 00 00       	mov    $0x0,%esi
		int i;
		for (i = 0; i < NENV; i++) 
		if ((envs[i].env_tgid == curenv->env_id) && (envs[i].isthread) && (envs[i].env_status == ENV_RUNNABLE || envs[i].env_status == ENV_RUNNING)) {
f0104de9:	a1 3c 02 22 f0       	mov    0xf022023c,%eax
f0104dee:	8b 9c 30 80 00 00 00 	mov    0x80(%eax,%esi,1),%ebx
f0104df5:	e8 7e 18 00 00       	call   f0106678 <cpunum>
f0104dfa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e01:	29 c2                	sub    %eax,%edx
f0104e03:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e06:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0104e0d:	3b 58 48             	cmp    0x48(%eax),%ebx
f0104e10:	75 25                	jne    f0104e37 <syscall+0x3fb>
f0104e12:	89 f0                	mov    %esi,%eax
f0104e14:	03 05 3c 02 22 f0    	add    0xf022023c,%eax
f0104e1a:	80 78 7c 00          	cmpb   $0x0,0x7c(%eax)
f0104e1e:	74 17                	je     f0104e37 <syscall+0x3fb>
f0104e20:	8b 50 54             	mov    0x54(%eax),%edx
f0104e23:	83 ea 02             	sub    $0x2,%edx
f0104e26:	83 fa 01             	cmp    $0x1,%edx
f0104e29:	77 0c                	ja     f0104e37 <syscall+0x3fb>
			env_destroy(&envs[i]);
f0104e2b:	83 ec 0c             	sub    $0xc,%esp
f0104e2e:	50                   	push   %eax
f0104e2f:	e8 0c ed ff ff       	call   f0103b40 <env_destroy>
f0104e34:	83 c4 10             	add    $0x10,%esp
f0104e37:	81 c6 84 00 00 00    	add    $0x84,%esi
		return r;
	
	// if it is not a thread, then have to kill all the thread
	if (!e->isthread) {
		int i;
		for (i = 0; i < NENV; i++) 
f0104e3d:	81 fe 00 10 02 00    	cmp    $0x21000,%esi
f0104e43:	75 a4                	jne    f0104de9 <syscall+0x3ad>
f0104e45:	be 00 00 00 00       	mov    $0x0,%esi
		if ((envs[i].env_tgid == curenv->env_id) && (envs[i].isthread) && (envs[i].env_status == ENV_RUNNABLE || envs[i].env_status == ENV_RUNNING)) {
			env_destroy(&envs[i]);
		}
		for (i = 0; i < NENV; i++)
		if ((envs[i].env_tgid == curenv->env_id) && (envs[i].isthread)) {
f0104e4a:	a1 3c 02 22 f0       	mov    0xf022023c,%eax
f0104e4f:	8b 9c 30 80 00 00 00 	mov    0x80(%eax,%esi,1),%ebx
f0104e56:	e8 1d 18 00 00       	call   f0106678 <cpunum>
f0104e5b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e62:	29 c2                	sub    %eax,%edx
f0104e64:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e67:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0104e6e:	3b 58 48             	cmp    0x48(%eax),%ebx
f0104e71:	75 3e                	jne    f0104eb1 <syscall+0x475>
f0104e73:	89 f0                	mov    %esi,%eax
f0104e75:	03 05 3c 02 22 f0    	add    0xf022023c,%eax
f0104e7b:	80 78 7c 00          	cmpb   $0x0,0x7c(%eax)
f0104e7f:	74 30                	je     f0104eb1 <syscall+0x475>
			while (envs[i].env_status == ENV_DYING) {
f0104e81:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104e85:	75 2a                	jne    f0104eb1 <syscall+0x475>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104e87:	83 ec 0c             	sub    $0xc,%esp
f0104e8a:	68 60 94 12 f0       	push   $0xf0129460
f0104e8f:	e8 56 1b 00 00       	call   f01069ea <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104e94:	f3 90                	pause  
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104e96:	c7 04 24 60 94 12 f0 	movl   $0xf0129460,(%esp)
f0104e9d:	e8 8d 1a 00 00       	call   f010692f <spin_lock>
f0104ea2:	83 c4 10             	add    $0x10,%esp
f0104ea5:	a1 3c 02 22 f0       	mov    0xf022023c,%eax
f0104eaa:	83 7c 30 54 01       	cmpl   $0x1,0x54(%eax,%esi,1)
f0104eaf:	74 d6                	je     f0104e87 <syscall+0x44b>
f0104eb1:	81 c6 84 00 00 00    	add    $0x84,%esi
		int i;
		for (i = 0; i < NENV; i++) 
		if ((envs[i].env_tgid == curenv->env_id) && (envs[i].isthread) && (envs[i].env_status == ENV_RUNNABLE || envs[i].env_status == ENV_RUNNING)) {
			env_destroy(&envs[i]);
		}
		for (i = 0; i < NENV; i++)
f0104eb7:	81 fe 00 10 02 00    	cmp    $0x21000,%esi
f0104ebd:	75 8b                	jne    f0104e4a <syscall+0x40e>
				lock_kernel();
			}
		}
	} 

	env_destroy(e);
f0104ebf:	83 ec 0c             	sub    $0xc,%esp
f0104ec2:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ec5:	e8 76 ec ff ff       	call   f0103b40 <env_destroy>
f0104eca:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104ecd:	b8 00 00 00 00       	mov    $0x0,%eax
        case SYS_getenvid:
            r = sys_getenvid();
            break;
        case SYS_env_destroy:
            r = sys_env_destroy(a1);
            break;
f0104ed2:	e9 8b 05 00 00       	jmp    f0105462 <syscall+0xa26>
	
	// Any environment is allowed to send IPC messages to any other environment, 
	// and the kernel does no special permission checking other than verifying that the target envid is valid.
	// So set the checkperm falg to 0
	struct Env * env;
	int r = envid2env(envid, &env, 0);	
f0104ed7:	83 ec 04             	sub    $0x4,%esp
f0104eda:	6a 00                	push   $0x0
f0104edc:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104edf:	50                   	push   %eax
f0104ee0:	53                   	push   %ebx
f0104ee1:	e8 5c e5 ff ff       	call   f0103442 <envid2env>
	//	-E_BAD_ENV if environment envid doesn't currently exist.
	if (r < 0) return -E_BAD_ENV;
f0104ee6:	83 c4 10             	add    $0x10,%esp
f0104ee9:	85 c0                	test   %eax,%eax
f0104eeb:	0f 88 06 01 00 00    	js     f0104ff7 <syscall+0x5bb>

	//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
	//		or another environment managed to send first.
	if (env->env_ipc_recving == false || env->env_ipc_from != 0) {
f0104ef1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ef4:	80 7a 68 00          	cmpb   $0x0,0x68(%edx)
f0104ef8:	0f 84 03 01 00 00    	je     f0105001 <syscall+0x5c5>
		return -E_IPC_NOT_RECV;
f0104efe:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	//	-E_BAD_ENV if environment envid doesn't currently exist.
	if (r < 0) return -E_BAD_ENV;

	//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
	//		or another environment managed to send first.
	if (env->env_ipc_recving == false || env->env_ipc_from != 0) {
f0104f03:	83 7a 74 00          	cmpl   $0x0,0x74(%edx)
f0104f07:	0f 85 55 05 00 00    	jne    f0105462 <syscall+0xa26>
		return -E_IPC_NOT_RECV;
	}

	//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
	if ((uint32_t)srcva < UTOP && ROUNDUP(srcva, PGSIZE) != srcva)
f0104f0d:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104f13:	0f 87 a5 00 00 00    	ja     f0104fbe <syscall+0x582>
f0104f19:	8d 97 ff 0f 00 00    	lea    0xfff(%edi),%edx
f0104f1f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		return -E_INVAL;
f0104f25:	b0 fd                	mov    $0xfd,%al
	if (env->env_ipc_recving == false || env->env_ipc_from != 0) {
		return -E_IPC_NOT_RECV;
	}

	//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
	if ((uint32_t)srcva < UTOP && ROUNDUP(srcva, PGSIZE) != srcva)
f0104f27:	39 d7                	cmp    %edx,%edi
f0104f29:	0f 85 33 05 00 00    	jne    f0105462 <syscall+0xa26>
		return -E_INVAL;

	//	-E_INVAL if srcva < UTOP and perm is inappropriate
	if ((uint32_t)srcva < UTOP && (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0))) 
f0104f2f:	8b 55 18             	mov    0x18(%ebp),%edx
f0104f32:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f0104f38:	83 fa 05             	cmp    $0x5,%edx
f0104f3b:	0f 85 21 05 00 00    	jne    f0105462 <syscall+0xa26>
		return -E_INVAL;

	//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's address space 
	if ((uint32_t)srcva < UTOP) {
		pte_t * pte;
		struct PageInfo * pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104f41:	e8 32 17 00 00       	call   f0106678 <cpunum>
f0104f46:	83 ec 04             	sub    $0x4,%esp
f0104f49:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104f4c:	52                   	push   %edx
f0104f4d:	57                   	push   %edi
f0104f4e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f51:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0104f57:	ff 70 60             	pushl  0x60(%eax)
f0104f5a:	e8 52 c8 ff ff       	call   f01017b1 <page_lookup>
f0104f5f:	89 c1                	mov    %eax,%ecx
		if (pg == NULL) return -E_INVAL;
f0104f61:	83 c4 10             	add    $0x10,%esp
f0104f64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f69:	85 c9                	test   %ecx,%ecx
f0104f6b:	0f 84 f1 04 00 00    	je     f0105462 <syscall+0xa26>

		//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
		//		current environment's address space.
		if ((perm & PTE_W) && (*pte & PTE_W) == 0) 
f0104f71:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104f75:	74 0c                	je     f0104f83 <syscall+0x547>
f0104f77:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f7a:	f6 02 02             	testb  $0x2,(%edx)
f0104f7d:	0f 84 df 04 00 00    	je     f0105462 <syscall+0xa26>
			return -E_INVAL;

		//	-E_NO_MEM if there's not enough memory to map srcva in envid's
		//		address space.
		if (env->env_ipc_dstva != NULL) {
f0104f83:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104f86:	8b 42 6c             	mov    0x6c(%edx),%eax
f0104f89:	85 c0                	test   %eax,%eax
f0104f8b:	74 2a                	je     f0104fb7 <syscall+0x57b>
			r = page_insert(env->env_pgdir, pg, env->env_ipc_dstva, perm);
f0104f8d:	ff 75 18             	pushl  0x18(%ebp)
f0104f90:	50                   	push   %eax
f0104f91:	51                   	push   %ecx
f0104f92:	ff 72 60             	pushl  0x60(%edx)
f0104f95:	e8 13 c9 ff ff       	call   f01018ad <page_insert>
f0104f9a:	89 c2                	mov    %eax,%edx
			if (r < 0) return -E_NO_MEM;
f0104f9c:	83 c4 10             	add    $0x10,%esp
f0104f9f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104fa4:	85 d2                	test   %edx,%edx
f0104fa6:	0f 88 b6 04 00 00    	js     f0105462 <syscall+0xa26>
			env->env_ipc_perm = perm;
f0104fac:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104faf:	8b 55 18             	mov    0x18(%ebp),%edx
f0104fb2:	89 50 78             	mov    %edx,0x78(%eax)
f0104fb5:	eb 07                	jmp    f0104fbe <syscall+0x582>
		} else env->env_ipc_perm = 0;	
f0104fb7:	c7 42 78 00 00 00 00 	movl   $0x0,0x78(%edx)
	}

	env->env_ipc_recving = false;
f0104fbe:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104fc1:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// ... I mistake write env->env_ipc_from = envid in the first
	// ... Debug a lot of time...
	env->env_ipc_from = curenv->env_id;
f0104fc5:	e8 ae 16 00 00       	call   f0106678 <cpunum>
f0104fca:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fcd:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0104fd3:	8b 40 48             	mov    0x48(%eax),%eax
f0104fd6:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_value = value;
f0104fd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fdc:	89 70 70             	mov    %esi,0x70(%eax)
	env->env_tf.tf_regs.reg_eax = 0;
f0104fdf:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	env->env_status = ENV_RUNNABLE;
f0104fe6:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	return 0;
f0104fed:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ff2:	e9 6b 04 00 00       	jmp    f0105462 <syscall+0xa26>
	// and the kernel does no special permission checking other than verifying that the target envid is valid.
	// So set the checkperm falg to 0
	struct Env * env;
	int r = envid2env(envid, &env, 0);	
	//	-E_BAD_ENV if environment envid doesn't currently exist.
	if (r < 0) return -E_BAD_ENV;
f0104ff7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104ffc:	e9 61 04 00 00       	jmp    f0105462 <syscall+0xa26>

	//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
	//		or another environment managed to send first.
	if (env->env_ipc_recving == false || env->env_ipc_from != 0) {
		return -E_IPC_NOT_RECV;
f0105001:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0105006:	e9 57 04 00 00       	jmp    f0105462 <syscall+0xa26>
static int
sys_ipc_recv(void *dstva)
{
	// cprintf("I am receiving???\n");
	// LAB 4: Your code here.
	if (((uint32_t)dstva < UTOP) && ROUNDUP(dstva, PGSIZE) != dstva) return -E_INVAL;
f010500b:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105011:	77 13                	ja     f0105026 <syscall+0x5ea>
f0105013:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f0105019:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010501e:	39 c3                	cmp    %eax,%ebx
f0105020:	0f 85 1b 04 00 00    	jne    f0105441 <syscall+0xa05>
	curenv->env_ipc_recving = true;			// Env is blocked receiving
f0105026:	e8 4d 16 00 00       	call   f0106678 <cpunum>
f010502b:	6b c0 74             	imul   $0x74,%eax,%eax
f010502e:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0105034:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;			// VA at which to map received page
f0105038:	e8 3b 16 00 00       	call   f0106678 <cpunum>
f010503d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105040:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0105046:	89 58 6c             	mov    %ebx,0x6c(%eax)
	curenv->env_ipc_from = 0;				// set from to 0
f0105049:	e8 2a 16 00 00       	call   f0106678 <cpunum>
f010504e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105051:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f0105057:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;	// mark it not runnable
f010505e:	e8 15 16 00 00       	call   f0106678 <cpunum>
f0105063:	6b c0 74             	imul   $0x74,%eax,%eax
f0105066:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f010506c:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();							// give up the CPU
f0105073:	e8 b2 f8 ff ff       	call   f010492a <sched_yield>

static int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
	struct Env * env;
	int r = envid2env(envid, &env, 1);	
f0105078:	83 ec 04             	sub    $0x4,%esp
f010507b:	6a 01                	push   $0x1
f010507d:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105080:	50                   	push   %eax
f0105081:	53                   	push   %ebx
f0105082:	e8 bb e3 ff ff       	call   f0103442 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0105087:	83 c4 10             	add    $0x10,%esp
f010508a:	c1 f8 1f             	sar    $0x1f,%eax
f010508d:	83 e0 fe             	and    $0xfffffffe,%eax
f0105090:	e9 cd 03 00 00       	jmp    f0105462 <syscall+0xa26>
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0105095:	83 ec 04             	sub    $0x4,%esp
f0105098:	6a 01                	push   $0x1
f010509a:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010509d:	50                   	push   %eax
f010509e:	53                   	push   %ebx
f010509f:	e8 9e e3 ff ff       	call   f0103442 <envid2env>
	if (r < 0) return -E_BAD_ENV;	
f01050a4:	83 c4 10             	add    $0x10,%esp
f01050a7:	85 c0                	test   %eax,%eax
f01050a9:	78 35                	js     f01050e0 <syscall+0x6a4>

	user_mem_assert (env, tf, sizeof(struct Trapframe), PTE_U);
f01050ab:	6a 04                	push   $0x4
f01050ad:	6a 44                	push   $0x44
f01050af:	56                   	push   %esi
f01050b0:	ff 75 dc             	pushl  -0x24(%ebp)
f01050b3:	e8 ba e2 ff ff       	call   f0103372 <user_mem_assert>

	env->env_tf = *tf;
f01050b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01050bb:	b9 11 00 00 00       	mov    $0x11,%ecx
f01050c0:	89 c7                	mov    %eax,%edi
f01050c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	env->env_tf.tf_cs |= 3;
f01050c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01050c7:	66 83 48 34 03       	orw    $0x3,0x34(%eax)
	env->env_tf.tf_eflags |= FL_IF;
f01050cc:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
f01050d3:	83 c4 10             	add    $0x10,%esp

	return 0;
f01050d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01050db:	e9 82 03 00 00       	jmp    f0105462 <syscall+0xa26>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;	
f01050e0:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
        case SYS_set_priority:
        	r = sys_set_priority((envid_t)a1, (uint32_t)a2);
        	break;
        case SYS_env_set_trapframe:
        	r = sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
        	break;
f01050e5:	e9 78 03 00 00       	jmp    f0105462 <syscall+0xa26>

static int
sys_exec(uint32_t eip, uint32_t esp, void * v_ph, uint32_t phnum)
{
	// set new eip and esp
	memset((void *)(&curenv->env_tf.tf_regs), 0, sizeof(struct PushRegs));
f01050ea:	e8 89 15 00 00       	call   f0106678 <cpunum>
f01050ef:	83 ec 04             	sub    $0x4,%esp
f01050f2:	6a 20                	push   $0x20
f01050f4:	6a 00                	push   $0x0
f01050f6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01050fd:	29 c2                	sub    %eax,%edx
f01050ff:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105102:	ff 34 85 28 10 22 f0 	pushl  -0xfddefd8(,%eax,4)
f0105109:	e8 3b 0f 00 00       	call   f0106049 <memset>
	curenv->env_tf.tf_eip = eip;
f010510e:	e8 65 15 00 00       	call   f0106678 <cpunum>
f0105113:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010511a:	29 c2                	sub    %eax,%edx
f010511c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010511f:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0105126:	89 58 30             	mov    %ebx,0x30(%eax)
	curenv->env_tf.tf_esp = esp;
f0105129:	e8 4a 15 00 00       	call   f0106678 <cpunum>
f010512e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105135:	29 c2                	sub    %eax,%edx
f0105137:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010513a:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0105141:	89 70 3c             	mov    %esi,0x3c(%eax)
	uint32_t va, end_addr;
	struct PageInfo * pg;

	// Elf 
	struct Proghdr * ph = (struct Proghdr *) v_ph; 
	for (i = 0; i < phnum; i++, ph++) {
f0105144:	83 c4 10             	add    $0x10,%esp
f0105147:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
f010514b:	0f 84 0c 01 00 00    	je     f010525d <syscall+0x821>
	uint32_t now_addr = MYTEMPLATE;
	uint32_t va, end_addr;
	struct PageInfo * pg;

	// Elf 
	struct Proghdr * ph = (struct Proghdr *) v_ph; 
f0105151:	89 7d cc             	mov    %edi,-0x34(%ebp)
	memset((void *)(&curenv->env_tf.tf_regs), 0, sizeof(struct PushRegs));
	curenv->env_tf.tf_eip = eip;
	curenv->env_tf.tf_esp = esp;

	int perm, i;
	uint32_t now_addr = MYTEMPLATE;
f0105154:	bf 00 00 00 80       	mov    $0x80000000,%edi
	uint32_t va, end_addr;
	struct PageInfo * pg;

	// Elf 
	struct Proghdr * ph = (struct Proghdr *) v_ph; 
	for (i = 0; i < phnum; i++, ph++) {
f0105159:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		if (ph->p_type != ELF_PROG_LOAD)
f0105160:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105163:	83 38 01             	cmpl   $0x1,(%eax)
f0105166:	0f 85 dd 00 00 00    	jne    f0105249 <syscall+0x80d>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
f010516c:	89 c2                	mov    %eax,%edx
f010516e:	8b 40 18             	mov    0x18(%eax),%eax
f0105171:	83 e0 02             	and    $0x2,%eax
	// Elf 
	struct Proghdr * ph = (struct Proghdr *) v_ph; 
	for (i = 0; i < phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
f0105174:	83 f8 01             	cmp    $0x1,%eax
f0105177:	19 c0                	sbb    %eax,%eax
f0105179:	83 e0 fe             	and    $0xfffffffe,%eax
f010517c:	83 c0 07             	add    $0x7,%eax
f010517f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;

		// Move to real virtual address
		end_addr = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
f0105182:	8b 72 08             	mov    0x8(%edx),%esi
f0105185:	89 f0                	mov    %esi,%eax
f0105187:	03 42 14             	add    0x14(%edx),%eax
f010518a:	05 ff 0f 00 00       	add    $0xfff,%eax
f010518f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105194:	89 45 c8             	mov    %eax,-0x38(%ebp)
		for (va = ROUNDDOWN(ph->p_va, PGSIZE); va != end_addr; now_addr += PGSIZE, va += PGSIZE) {
f0105197:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f010519d:	39 f0                	cmp    %esi,%eax
f010519f:	0f 84 a4 00 00 00    	je     f0105249 <syscall+0x80d>
f01051a5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
			if ((pg = page_lookup(curenv->env_pgdir, (void *)now_addr, NULL)) == NULL) 
f01051a8:	e8 cb 14 00 00       	call   f0106678 <cpunum>
f01051ad:	83 ec 04             	sub    $0x4,%esp
f01051b0:	6a 00                	push   $0x0
f01051b2:	57                   	push   %edi
f01051b3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01051ba:	29 c2                	sub    %eax,%edx
f01051bc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01051bf:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f01051c6:	ff 70 60             	pushl  0x60(%eax)
f01051c9:	e8 e3 c5 ff ff       	call   f01017b1 <page_lookup>
f01051ce:	89 c3                	mov    %eax,%ebx
f01051d0:	83 c4 10             	add    $0x10,%esp
f01051d3:	85 c0                	test   %eax,%eax
f01051d5:	0f 84 6d 02 00 00    	je     f0105448 <syscall+0xa0c>
				return -E_NO_MEM;		// no page
			if (page_insert(curenv->env_pgdir, pg, (void *)va, perm) < 0)
f01051db:	e8 98 14 00 00       	call   f0106678 <cpunum>
f01051e0:	ff 75 d0             	pushl  -0x30(%ebp)
f01051e3:	56                   	push   %esi
f01051e4:	53                   	push   %ebx
f01051e5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01051ec:	29 c2                	sub    %eax,%edx
f01051ee:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01051f1:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f01051f8:	ff 70 60             	pushl  0x60(%eax)
f01051fb:	e8 ad c6 ff ff       	call   f01018ad <page_insert>
f0105200:	83 c4 10             	add    $0x10,%esp
f0105203:	85 c0                	test   %eax,%eax
f0105205:	0f 88 44 02 00 00    	js     f010544f <syscall+0xa13>
				return -E_NO_MEM;		
			page_remove(curenv->env_pgdir, (void *)now_addr);
f010520b:	e8 68 14 00 00       	call   f0106678 <cpunum>
f0105210:	83 ec 08             	sub    $0x8,%esp
f0105213:	ff 75 d4             	pushl  -0x2c(%ebp)
f0105216:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010521d:	29 c2                	sub    %eax,%edx
f010521f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105222:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0105229:	ff 70 60             	pushl  0x60(%eax)
f010522c:	e8 2f c6 ff ff       	call   f0101860 <page_remove>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;

		// Move to real virtual address
		end_addr = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
		for (va = ROUNDDOWN(ph->p_va, PGSIZE); va != end_addr; now_addr += PGSIZE, va += PGSIZE) {
f0105231:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0105237:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010523d:	83 c4 10             	add    $0x10,%esp
f0105240:	39 75 c8             	cmp    %esi,-0x38(%ebp)
f0105243:	0f 85 5c ff ff ff    	jne    f01051a5 <syscall+0x769>
	uint32_t va, end_addr;
	struct PageInfo * pg;

	// Elf 
	struct Proghdr * ph = (struct Proghdr *) v_ph; 
	for (i = 0; i < phnum; i++, ph++) {
f0105249:	ff 45 c4             	incl   -0x3c(%ebp)
f010524c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010524f:	39 55 18             	cmp    %edx,0x18(%ebp)
f0105252:	76 0e                	jbe    f0105262 <syscall+0x826>
f0105254:	83 45 cc 20          	addl   $0x20,-0x34(%ebp)
f0105258:	e9 03 ff ff ff       	jmp    f0105160 <syscall+0x724>
	memset((void *)(&curenv->env_tf.tf_regs), 0, sizeof(struct PushRegs));
	curenv->env_tf.tf_eip = eip;
	curenv->env_tf.tf_esp = esp;

	int perm, i;
	uint32_t now_addr = MYTEMPLATE;
f010525d:	bf 00 00 00 80       	mov    $0x80000000,%edi
			page_remove(curenv->env_pgdir, (void *)now_addr);
		}
	}

	// New Stack
	if ((pg = page_lookup(curenv->env_pgdir, (void *)now_addr, NULL)) == NULL) 
f0105262:	e8 11 14 00 00       	call   f0106678 <cpunum>
f0105267:	83 ec 04             	sub    $0x4,%esp
f010526a:	6a 00                	push   $0x0
f010526c:	57                   	push   %edi
f010526d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105274:	29 c2                	sub    %eax,%edx
f0105276:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105279:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0105280:	ff 70 60             	pushl  0x60(%eax)
f0105283:	e8 29 c5 ff ff       	call   f01017b1 <page_lookup>
f0105288:	89 c3                	mov    %eax,%ebx
f010528a:	83 c4 10             	add    $0x10,%esp
f010528d:	85 c0                	test   %eax,%eax
f010528f:	0f 84 c1 01 00 00    	je     f0105456 <syscall+0xa1a>
		return -E_NO_MEM;
	if (page_insert(curenv->env_pgdir, pg, (void *)(USTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0) 
f0105295:	e8 de 13 00 00       	call   f0106678 <cpunum>
f010529a:	6a 07                	push   $0x7
f010529c:	68 00 d0 bf ee       	push   $0xeebfd000
f01052a1:	53                   	push   %ebx
f01052a2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01052a9:	29 c2                	sub    %eax,%edx
f01052ab:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01052ae:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f01052b5:	ff 70 60             	pushl  0x60(%eax)
f01052b8:	e8 f0 c5 ff ff       	call   f01018ad <page_insert>
f01052bd:	83 c4 10             	add    $0x10,%esp
f01052c0:	85 c0                	test   %eax,%eax
f01052c2:	0f 88 95 01 00 00    	js     f010545d <syscall+0xa21>
		return -E_NO_MEM;
	page_remove(curenv->env_pgdir, (void *)now_addr);
f01052c8:	e8 ab 13 00 00       	call   f0106678 <cpunum>
f01052cd:	83 ec 08             	sub    $0x8,%esp
f01052d0:	57                   	push   %edi
f01052d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01052d4:	8b 80 28 10 22 f0    	mov    -0xfddefd8(%eax),%eax
f01052da:	ff 70 60             	pushl  0x60(%eax)
f01052dd:	e8 7e c5 ff ff       	call   f0101860 <page_remove>
	
	env_run(curenv);		// never return
f01052e2:	e8 91 13 00 00       	call   f0106678 <cpunum>
f01052e7:	83 c4 04             	add    $0x4,%esp
f01052ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01052ed:	ff b0 28 10 22 f0    	pushl  -0xfddefd8(%eax)
f01052f3:	e8 05 e9 ff ff       	call   f0103bfd <env_run>

static int
sys_getpid()
{
	// in process(main thread), env_id = env_tgid
	return curenv->env_tgid;
f01052f8:	e8 7b 13 00 00       	call   f0106678 <cpunum>
f01052fd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105304:	29 c2                	sub    %eax,%edx
f0105306:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105309:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0105310:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
        case SYS_exec:
        	r = sys_exec((uint32_t)a1, (uint32_t)a2, (void *)a3, (uint32_t)a4);
        	break;
       	case SYS_getpid:
        	r = sys_getpid();
        	break;
f0105316:	e9 47 01 00 00       	jmp    f0105462 <syscall+0xa26>
// thread:
static envid_t
sys_exothread(void)
{
	struct Env * new_env;
	int r = env_alloc(&new_env, curenv->env_id);
f010531b:	e8 58 13 00 00       	call   f0106678 <cpunum>
f0105320:	83 ec 08             	sub    $0x8,%esp
f0105323:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010532a:	29 c2                	sub    %eax,%edx
f010532c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010532f:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f0105336:	ff 70 48             	pushl  0x48(%eax)
f0105339:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010533c:	50                   	push   %eax
f010533d:	e8 71 e3 ff ff       	call   f01036b3 <env_alloc>
	if (r < 0) return r;
f0105342:	83 c4 10             	add    $0x10,%esp
f0105345:	85 c0                	test   %eax,%eax
f0105347:	0f 88 15 01 00 00    	js     f0105462 <syscall+0xa26>

	new_env->env_status = ENV_NOT_RUNNABLE;
f010534d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105350:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	new_env->env_pgdir = curenv->env_pgdir;
f0105357:	e8 1c 13 00 00       	call   f0106678 <cpunum>
f010535c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105363:	29 c2                	sub    %eax,%edx
f0105365:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105368:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f010536f:	8b 40 60             	mov    0x60(%eax),%eax
f0105372:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy((void *)(&new_env->env_tf), (void*)(&curenv->env_tf), sizeof(struct Trapframe));
f0105375:	e8 fe 12 00 00       	call   f0106678 <cpunum>
f010537a:	83 ec 04             	sub    $0x4,%esp
f010537d:	6a 44                	push   $0x44
f010537f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105386:	29 c2                	sub    %eax,%edx
f0105388:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010538b:	ff 34 85 28 10 22 f0 	pushl  -0xfddefd8(,%eax,4)
f0105392:	ff 75 dc             	pushl  -0x24(%ebp)
f0105395:	e8 63 0d 00 00       	call   f01060fd <memcpy>

	new_env->env_tgid = curenv->env_id;
f010539a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010539d:	e8 d6 12 00 00       	call   f0106678 <cpunum>
f01053a2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01053a9:	29 c2                	sub    %eax,%edx
f01053ab:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01053ae:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f01053b5:	8b 40 48             	mov    0x48(%eax),%eax
f01053b8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	new_env->isthread = true;
f01053be:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01053c1:	c6 43 7c 01          	movb   $0x1,0x7c(%ebx)
	new_env->env_pgfault_upcall = curenv->env_pgfault_upcall;
f01053c5:	e8 ae 12 00 00       	call   f0106678 <cpunum>
f01053ca:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01053d1:	29 c2                	sub    %eax,%edx
f01053d3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01053d6:	8b 04 85 28 10 22 f0 	mov    -0xfddefd8(,%eax,4),%eax
f01053dd:	8b 40 64             	mov    0x64(%eax),%eax
f01053e0:	89 43 64             	mov    %eax,0x64(%ebx)

	return new_env->env_id;
f01053e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01053e6:	8b 40 48             	mov    0x48(%eax),%eax
f01053e9:	83 c4 10             	add    $0x10,%esp
       	case SYS_getpid:
        	r = sys_getpid();
        	break;
        case SYS_exothread:
        	r = sys_exothread();
        	break;
f01053ec:	eb 74                	jmp    f0105462 <syscall+0xa26>
sys_join(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1) < 0))
f01053ee:	83 ec 04             	sub    $0x4,%esp
f01053f1:	6a 01                	push   $0x1
f01053f3:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01053f6:	50                   	push   %eax
f01053f7:	53                   	push   %ebx
f01053f8:	e8 45 e0 ff ff       	call   f0103442 <envid2env>
f01053fd:	83 c4 10             	add    $0x10,%esp
f0105400:	c1 e8 1f             	shr    $0x1f,%eax
f0105403:	75 5d                	jne    f0105462 <syscall+0xa26>
		return r;
	if (e->env_tgid != curenv->env_id) {
f0105405:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105408:	8b 98 80 00 00 00    	mov    0x80(%eax),%ebx
f010540e:	e8 65 12 00 00       	call   f0106678 <cpunum>
f0105413:	6b c0 74             	imul   $0x74,%eax,%eax
f0105416:	8b 90 28 10 22 f0    	mov    -0xfddefd8(%eax),%edx
		// curenv do not have such thread
		return -1;
f010541c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1) < 0))
		return r;
	if (e->env_tgid != curenv->env_id) {
f0105421:	3b 5a 48             	cmp    0x48(%edx),%ebx
f0105424:	75 3c                	jne    f0105462 <syscall+0xa26>
		// curenv do not have such thread
		return -1;
	}
	if (e->env_status == ENV_RUNNABLE || e->env_status == ENV_RUNNING) {
f0105426:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105429:	8b 40 54             	mov    0x54(%eax),%eax
f010542c:	83 e8 02             	sub    $0x2,%eax
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1) < 0))
		return r;
f010542f:	83 f8 01             	cmp    $0x1,%eax
f0105432:	0f 97 c0             	seta   %al
f0105435:	0f b6 c0             	movzbl %al,%eax
f0105438:	eb 28                	jmp    f0105462 <syscall+0xa26>
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
    
    // cprintf("SYSCALLNO %d\n", syscallno);
	int r = 0;
f010543a:	b8 00 00 00 00       	mov    $0x0,%eax
f010543f:	eb 21                	jmp    f0105462 <syscall+0xa26>
            break;
        case SYS_ipc_try_send:
        	r = sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
        	break;
        case SYS_ipc_recv:
        	r = sys_ipc_recv((void *)a1);
f0105441:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105446:	eb 1a                	jmp    f0105462 <syscall+0xa26>
        	break;
        case SYS_env_set_trapframe:
        	r = sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
        	break;
        case SYS_exec:
        	r = sys_exec((uint32_t)a1, (uint32_t)a2, (void *)a3, (uint32_t)a4);
f0105448:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010544d:	eb 13                	jmp    f0105462 <syscall+0xa26>
f010544f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0105454:	eb 0c                	jmp    f0105462 <syscall+0xa26>
f0105456:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010545b:	eb 05                	jmp    f0105462 <syscall+0xa26>
f010545d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        	break;
        dafult:
            r = -E_INVAL;
	}
	return r;
}
f0105462:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105465:	5b                   	pop    %ebx
f0105466:	5e                   	pop    %esi
f0105467:	5f                   	pop    %edi
f0105468:	c9                   	leave  
f0105469:	c3                   	ret    
	...

f010546c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010546c:	55                   	push   %ebp
f010546d:	89 e5                	mov    %esp,%ebp
f010546f:	57                   	push   %edi
f0105470:	56                   	push   %esi
f0105471:	53                   	push   %ebx
f0105472:	83 ec 14             	sub    $0x14,%esp
f0105475:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105478:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010547b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010547e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105481:	8b 1a                	mov    (%edx),%ebx
f0105483:	8b 01                	mov    (%ecx),%eax
f0105485:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0105488:	39 c3                	cmp    %eax,%ebx
f010548a:	0f 8f 97 00 00 00    	jg     f0105527 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0105490:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105497:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010549a:	01 d8                	add    %ebx,%eax
f010549c:	89 c7                	mov    %eax,%edi
f010549e:	c1 ef 1f             	shr    $0x1f,%edi
f01054a1:	01 c7                	add    %eax,%edi
f01054a3:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01054a5:	39 df                	cmp    %ebx,%edi
f01054a7:	7c 31                	jl     f01054da <stab_binsearch+0x6e>
f01054a9:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01054ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01054af:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01054b4:	39 f0                	cmp    %esi,%eax
f01054b6:	0f 84 b3 00 00 00    	je     f010556f <stab_binsearch+0x103>
f01054bc:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01054c0:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01054c4:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01054c6:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01054c7:	39 d8                	cmp    %ebx,%eax
f01054c9:	7c 0f                	jl     f01054da <stab_binsearch+0x6e>
f01054cb:	0f b6 0a             	movzbl (%edx),%ecx
f01054ce:	83 ea 0c             	sub    $0xc,%edx
f01054d1:	39 f1                	cmp    %esi,%ecx
f01054d3:	75 f1                	jne    f01054c6 <stab_binsearch+0x5a>
f01054d5:	e9 97 00 00 00       	jmp    f0105571 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01054da:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01054dd:	eb 39                	jmp    f0105518 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01054df:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01054e2:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f01054e4:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01054e7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01054ee:	eb 28                	jmp    f0105518 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01054f0:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01054f3:	76 12                	jbe    f0105507 <stab_binsearch+0x9b>
			*region_right = m - 1;
f01054f5:	48                   	dec    %eax
f01054f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01054f9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01054fc:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01054fe:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105505:	eb 11                	jmp    f0105518 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105507:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010550a:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f010550c:	ff 45 0c             	incl   0xc(%ebp)
f010550f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105511:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105518:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f010551b:	0f 8d 76 ff ff ff    	jge    f0105497 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105521:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105525:	75 0d                	jne    f0105534 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0105527:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010552a:	8b 03                	mov    (%ebx),%eax
f010552c:	48                   	dec    %eax
f010552d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105530:	89 02                	mov    %eax,(%edx)
f0105532:	eb 55                	jmp    f0105589 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105534:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105537:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105539:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010553c:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010553e:	39 c1                	cmp    %eax,%ecx
f0105540:	7d 26                	jge    f0105568 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0105542:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105545:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0105548:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f010554d:	39 f2                	cmp    %esi,%edx
f010554f:	74 17                	je     f0105568 <stab_binsearch+0xfc>
f0105551:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105555:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105559:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010555a:	39 c1                	cmp    %eax,%ecx
f010555c:	7d 0a                	jge    f0105568 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f010555e:	0f b6 1a             	movzbl (%edx),%ebx
f0105561:	83 ea 0c             	sub    $0xc,%edx
f0105564:	39 f3                	cmp    %esi,%ebx
f0105566:	75 f1                	jne    f0105559 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105568:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010556b:	89 02                	mov    %eax,(%edx)
f010556d:	eb 1a                	jmp    f0105589 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010556f:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105571:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105574:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0105577:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010557b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010557e:	0f 82 5b ff ff ff    	jb     f01054df <stab_binsearch+0x73>
f0105584:	e9 67 ff ff ff       	jmp    f01054f0 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0105589:	83 c4 14             	add    $0x14,%esp
f010558c:	5b                   	pop    %ebx
f010558d:	5e                   	pop    %esi
f010558e:	5f                   	pop    %edi
f010558f:	c9                   	leave  
f0105590:	c3                   	ret    

f0105591 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105591:	55                   	push   %ebp
f0105592:	89 e5                	mov    %esp,%ebp
f0105594:	57                   	push   %edi
f0105595:	56                   	push   %esi
f0105596:	53                   	push   %ebx
f0105597:	83 ec 2c             	sub    $0x2c,%esp
f010559a:	8b 75 08             	mov    0x8(%ebp),%esi
f010559d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01055a0:	c7 03 f4 88 10 f0    	movl   $0xf01088f4,(%ebx)
	info->eip_line = 0;
f01055a6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01055ad:	c7 43 08 f4 88 10 f0 	movl   $0xf01088f4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01055b4:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01055bb:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01055be:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01055c5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01055cb:	0f 87 ba 00 00 00    	ja     f010568b <debuginfo_eip+0xfa>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
f01055d1:	e8 a2 10 00 00       	call   f0106678 <cpunum>
f01055d6:	6a 04                	push   $0x4
f01055d8:	6a 10                	push   $0x10
f01055da:	68 00 00 20 00       	push   $0x200000
f01055df:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01055e6:	29 c2                	sub    %eax,%edx
f01055e8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01055eb:	ff 34 85 28 10 22 f0 	pushl  -0xfddefd8(,%eax,4)
f01055f2:	e8 c8 dc ff ff       	call   f01032bf <user_mem_check>
f01055f7:	83 c4 10             	add    $0x10,%esp
f01055fa:	85 c0                	test   %eax,%eax
f01055fc:	0f 88 11 02 00 00    	js     f0105813 <debuginfo_eip+0x282>
			return -1;
		}

		stabs = usd->stabs;
f0105602:	a1 00 00 20 00       	mov    0x200000,%eax
f0105607:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f010560a:	8b 0d 04 00 20 00    	mov    0x200004,%ecx
f0105610:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr = usd->stabstr;
f0105613:	a1 08 00 20 00       	mov    0x200008,%eax
f0105618:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f010561b:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
f0105621:	e8 52 10 00 00       	call   f0106678 <cpunum>
f0105626:	89 c2                	mov    %eax,%edx
f0105628:	6a 04                	push   $0x4
f010562a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010562d:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0105630:	50                   	push   %eax
f0105631:	ff 75 d0             	pushl  -0x30(%ebp)
f0105634:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f010563b:	29 d0                	sub    %edx,%eax
f010563d:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0105640:	ff 34 85 28 10 22 f0 	pushl  -0xfddefd8(,%eax,4)
f0105647:	e8 73 dc ff ff       	call   f01032bf <user_mem_check>
f010564c:	83 c4 10             	add    $0x10,%esp
f010564f:	85 c0                	test   %eax,%eax
f0105651:	0f 88 c3 01 00 00    	js     f010581a <debuginfo_eip+0x289>
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0105657:	e8 1c 10 00 00       	call   f0106678 <cpunum>
f010565c:	89 c2                	mov    %eax,%edx
f010565e:	6a 04                	push   $0x4
f0105660:	89 f8                	mov    %edi,%eax
f0105662:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0105665:	50                   	push   %eax
f0105666:	ff 75 d4             	pushl  -0x2c(%ebp)
f0105669:	6b c2 74             	imul   $0x74,%edx,%eax
f010566c:	ff b0 28 10 22 f0    	pushl  -0xfddefd8(%eax)
f0105672:	e8 48 dc ff ff       	call   f01032bf <user_mem_check>
f0105677:	89 c2                	mov    %eax,%edx
f0105679:	83 c4 10             	add    $0x10,%esp
			return -1;
f010567c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0105681:	85 d2                	test   %edx,%edx
f0105683:	0f 88 ab 01 00 00    	js     f0105834 <debuginfo_eip+0x2a3>
f0105689:	eb 1a                	jmp    f01056a5 <debuginfo_eip+0x114>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010568b:	bf e6 e8 11 f0       	mov    $0xf011e8e6,%edi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105690:	c7 45 d4 91 54 11 f0 	movl   $0xf0115491,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105697:	c7 45 cc 90 54 11 f0 	movl   $0xf0115490,-0x34(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010569e:	c7 45 d0 90 8e 10 f0 	movl   $0xf0108e90,-0x30(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01056a5:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f01056a8:	0f 83 73 01 00 00    	jae    f0105821 <debuginfo_eip+0x290>
f01056ae:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f01056b2:	0f 85 70 01 00 00    	jne    f0105828 <debuginfo_eip+0x297>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01056b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01056bf:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01056c2:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01056c5:	c1 f8 02             	sar    $0x2,%eax
f01056c8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01056ce:	48                   	dec    %eax
f01056cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01056d2:	83 ec 08             	sub    $0x8,%esp
f01056d5:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01056d8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01056db:	56                   	push   %esi
f01056dc:	6a 64                	push   $0x64
f01056de:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01056e1:	e8 86 fd ff ff       	call   f010546c <stab_binsearch>
	if (lfile == 0)
f01056e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01056e9:	83 c4 10             	add    $0x10,%esp
		return -1;
f01056ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01056f1:	85 d2                	test   %edx,%edx
f01056f3:	0f 84 3b 01 00 00    	je     f0105834 <debuginfo_eip+0x2a3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01056f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01056fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105702:	83 ec 08             	sub    $0x8,%esp
f0105705:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105708:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010570b:	56                   	push   %esi
f010570c:	6a 24                	push   $0x24
f010570e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105711:	e8 56 fd ff ff       	call   f010546c <stab_binsearch>

	if (lfun <= rfun) {
f0105716:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105719:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010571c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010571f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0105722:	83 c4 10             	add    $0x10,%esp
f0105725:	39 c1                	cmp    %eax,%ecx
f0105727:	7f 21                	jg     f010574a <debuginfo_eip+0x1b9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105729:	6b c1 0c             	imul   $0xc,%ecx,%eax
f010572c:	03 45 d0             	add    -0x30(%ebp),%eax
f010572f:	8b 10                	mov    (%eax),%edx
f0105731:	89 f9                	mov    %edi,%ecx
f0105733:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f0105736:	39 ca                	cmp    %ecx,%edx
f0105738:	73 06                	jae    f0105740 <debuginfo_eip+0x1af>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010573a:	03 55 d4             	add    -0x2c(%ebp),%edx
f010573d:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105740:	8b 40 08             	mov    0x8(%eax),%eax
f0105743:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105746:	29 c6                	sub    %eax,%esi
f0105748:	eb 0f                	jmp    f0105759 <debuginfo_eip+0x1c8>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010574a:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010574d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105750:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		rline = rfile;
f0105753:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105756:	89 45 c8             	mov    %eax,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105759:	83 ec 08             	sub    $0x8,%esp
f010575c:	6a 3a                	push   $0x3a
f010575e:	ff 73 08             	pushl  0x8(%ebx)
f0105761:	e8 c1 08 00 00       	call   f0106027 <strfind>
f0105766:	2b 43 08             	sub    0x8(%ebx),%eax
f0105769:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f010576c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010576f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    rfun = rline;
f0105772:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105775:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0105778:	83 c4 08             	add    $0x8,%esp
f010577b:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010577e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105781:	56                   	push   %esi
f0105782:	6a 44                	push   $0x44
f0105784:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105787:	e8 e0 fc ff ff       	call   f010546c <stab_binsearch>
    if (lfun <= rfun) {
f010578c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010578f:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0105792:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0105797:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f010579a:	0f 8f 94 00 00 00    	jg     f0105834 <debuginfo_eip+0x2a3>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f01057a0:	6b ca 0c             	imul   $0xc,%edx,%ecx
f01057a3:	03 4d d0             	add    -0x30(%ebp),%ecx
f01057a6:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f01057aa:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01057ad:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01057b0:	89 75 cc             	mov    %esi,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01057b3:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01057b6:	eb 04                	jmp    f01057bc <debuginfo_eip+0x22b>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01057b8:	4a                   	dec    %edx
f01057b9:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01057bc:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f01057bf:	7c 19                	jl     f01057da <debuginfo_eip+0x249>
	       && stabs[lline].n_type != N_SOL
f01057c1:	8a 48 fc             	mov    -0x4(%eax),%cl
f01057c4:	80 f9 84             	cmp    $0x84,%cl
f01057c7:	74 73                	je     f010583c <debuginfo_eip+0x2ab>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01057c9:	80 f9 64             	cmp    $0x64,%cl
f01057cc:	75 ea                	jne    f01057b8 <debuginfo_eip+0x227>
f01057ce:	83 38 00             	cmpl   $0x0,(%eax)
f01057d1:	74 e5                	je     f01057b8 <debuginfo_eip+0x227>
f01057d3:	eb 67                	jmp    f010583c <debuginfo_eip+0x2ab>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01057d5:	03 45 d4             	add    -0x2c(%ebp),%eax
f01057d8:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01057da:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01057dd:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01057e0:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01057e5:	39 ca                	cmp    %ecx,%edx
f01057e7:	7d 4b                	jge    f0105834 <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
f01057e9:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01057ec:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01057ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01057f2:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f01057f6:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01057f8:	eb 04                	jmp    f01057fe <debuginfo_eip+0x26d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01057fa:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01057fd:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01057fe:	39 f0                	cmp    %esi,%eax
f0105800:	7d 2d                	jge    f010582f <debuginfo_eip+0x29e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105802:	8a 0a                	mov    (%edx),%cl
f0105804:	83 c2 0c             	add    $0xc,%edx
f0105807:	80 f9 a0             	cmp    $0xa0,%cl
f010580a:	74 ee                	je     f01057fa <debuginfo_eip+0x269>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010580c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105811:	eb 21                	jmp    f0105834 <debuginfo_eip+0x2a3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
f0105813:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105818:	eb 1a                	jmp    f0105834 <debuginfo_eip+0x2a3>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
f010581a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010581f:	eb 13                	jmp    f0105834 <debuginfo_eip+0x2a3>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105821:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105826:	eb 0c                	jmp    f0105834 <debuginfo_eip+0x2a3>
f0105828:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010582d:	eb 05                	jmp    f0105834 <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010582f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105834:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105837:	5b                   	pop    %ebx
f0105838:	5e                   	pop    %esi
f0105839:	5f                   	pop    %edi
f010583a:	c9                   	leave  
f010583b:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010583c:	6b d2 0c             	imul   $0xc,%edx,%edx
f010583f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105842:	8b 04 16             	mov    (%esi,%edx,1),%eax
f0105845:	2b 7d d4             	sub    -0x2c(%ebp),%edi
f0105848:	39 f8                	cmp    %edi,%eax
f010584a:	72 89                	jb     f01057d5 <debuginfo_eip+0x244>
f010584c:	eb 8c                	jmp    f01057da <debuginfo_eip+0x249>
	...

f0105850 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105850:	55                   	push   %ebp
f0105851:	89 e5                	mov    %esp,%ebp
f0105853:	57                   	push   %edi
f0105854:	56                   	push   %esi
f0105855:	53                   	push   %ebx
f0105856:	83 ec 2c             	sub    $0x2c,%esp
f0105859:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010585c:	89 d6                	mov    %edx,%esi
f010585e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105861:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105864:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105867:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010586a:	8b 45 10             	mov    0x10(%ebp),%eax
f010586d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105870:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105873:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105876:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010587d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0105880:	72 0c                	jb     f010588e <printnum+0x3e>
f0105882:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105885:	76 07                	jbe    f010588e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105887:	4b                   	dec    %ebx
f0105888:	85 db                	test   %ebx,%ebx
f010588a:	7f 31                	jg     f01058bd <printnum+0x6d>
f010588c:	eb 3f                	jmp    f01058cd <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010588e:	83 ec 0c             	sub    $0xc,%esp
f0105891:	57                   	push   %edi
f0105892:	4b                   	dec    %ebx
f0105893:	53                   	push   %ebx
f0105894:	50                   	push   %eax
f0105895:	83 ec 08             	sub    $0x8,%esp
f0105898:	ff 75 d4             	pushl  -0x2c(%ebp)
f010589b:	ff 75 d0             	pushl  -0x30(%ebp)
f010589e:	ff 75 dc             	pushl  -0x24(%ebp)
f01058a1:	ff 75 d8             	pushl  -0x28(%ebp)
f01058a4:	e8 3b 12 00 00       	call   f0106ae4 <__udivdi3>
f01058a9:	83 c4 18             	add    $0x18,%esp
f01058ac:	52                   	push   %edx
f01058ad:	50                   	push   %eax
f01058ae:	89 f2                	mov    %esi,%edx
f01058b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058b3:	e8 98 ff ff ff       	call   f0105850 <printnum>
f01058b8:	83 c4 20             	add    $0x20,%esp
f01058bb:	eb 10                	jmp    f01058cd <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01058bd:	83 ec 08             	sub    $0x8,%esp
f01058c0:	56                   	push   %esi
f01058c1:	57                   	push   %edi
f01058c2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01058c5:	4b                   	dec    %ebx
f01058c6:	83 c4 10             	add    $0x10,%esp
f01058c9:	85 db                	test   %ebx,%ebx
f01058cb:	7f f0                	jg     f01058bd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01058cd:	83 ec 08             	sub    $0x8,%esp
f01058d0:	56                   	push   %esi
f01058d1:	83 ec 04             	sub    $0x4,%esp
f01058d4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01058d7:	ff 75 d0             	pushl  -0x30(%ebp)
f01058da:	ff 75 dc             	pushl  -0x24(%ebp)
f01058dd:	ff 75 d8             	pushl  -0x28(%ebp)
f01058e0:	e8 1b 13 00 00       	call   f0106c00 <__umoddi3>
f01058e5:	83 c4 14             	add    $0x14,%esp
f01058e8:	0f be 80 fe 88 10 f0 	movsbl -0xfef7702(%eax),%eax
f01058ef:	50                   	push   %eax
f01058f0:	ff 55 e4             	call   *-0x1c(%ebp)
f01058f3:	83 c4 10             	add    $0x10,%esp
}
f01058f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058f9:	5b                   	pop    %ebx
f01058fa:	5e                   	pop    %esi
f01058fb:	5f                   	pop    %edi
f01058fc:	c9                   	leave  
f01058fd:	c3                   	ret    

f01058fe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01058fe:	55                   	push   %ebp
f01058ff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105901:	83 fa 01             	cmp    $0x1,%edx
f0105904:	7e 0e                	jle    f0105914 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105906:	8b 10                	mov    (%eax),%edx
f0105908:	8d 4a 08             	lea    0x8(%edx),%ecx
f010590b:	89 08                	mov    %ecx,(%eax)
f010590d:	8b 02                	mov    (%edx),%eax
f010590f:	8b 52 04             	mov    0x4(%edx),%edx
f0105912:	eb 22                	jmp    f0105936 <getuint+0x38>
	else if (lflag)
f0105914:	85 d2                	test   %edx,%edx
f0105916:	74 10                	je     f0105928 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105918:	8b 10                	mov    (%eax),%edx
f010591a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010591d:	89 08                	mov    %ecx,(%eax)
f010591f:	8b 02                	mov    (%edx),%eax
f0105921:	ba 00 00 00 00       	mov    $0x0,%edx
f0105926:	eb 0e                	jmp    f0105936 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105928:	8b 10                	mov    (%eax),%edx
f010592a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010592d:	89 08                	mov    %ecx,(%eax)
f010592f:	8b 02                	mov    (%edx),%eax
f0105931:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105936:	c9                   	leave  
f0105937:	c3                   	ret    

f0105938 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0105938:	55                   	push   %ebp
f0105939:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010593b:	83 fa 01             	cmp    $0x1,%edx
f010593e:	7e 0e                	jle    f010594e <getint+0x16>
		return va_arg(*ap, long long);
f0105940:	8b 10                	mov    (%eax),%edx
f0105942:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105945:	89 08                	mov    %ecx,(%eax)
f0105947:	8b 02                	mov    (%edx),%eax
f0105949:	8b 52 04             	mov    0x4(%edx),%edx
f010594c:	eb 1a                	jmp    f0105968 <getint+0x30>
	else if (lflag)
f010594e:	85 d2                	test   %edx,%edx
f0105950:	74 0c                	je     f010595e <getint+0x26>
		return va_arg(*ap, long);
f0105952:	8b 10                	mov    (%eax),%edx
f0105954:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105957:	89 08                	mov    %ecx,(%eax)
f0105959:	8b 02                	mov    (%edx),%eax
f010595b:	99                   	cltd   
f010595c:	eb 0a                	jmp    f0105968 <getint+0x30>
	else
		return va_arg(*ap, int);
f010595e:	8b 10                	mov    (%eax),%edx
f0105960:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105963:	89 08                	mov    %ecx,(%eax)
f0105965:	8b 02                	mov    (%edx),%eax
f0105967:	99                   	cltd   
}
f0105968:	c9                   	leave  
f0105969:	c3                   	ret    

f010596a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010596a:	55                   	push   %ebp
f010596b:	89 e5                	mov    %esp,%ebp
f010596d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105970:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105973:	8b 10                	mov    (%eax),%edx
f0105975:	3b 50 04             	cmp    0x4(%eax),%edx
f0105978:	73 08                	jae    f0105982 <sprintputch+0x18>
		*b->buf++ = ch;
f010597a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010597d:	88 0a                	mov    %cl,(%edx)
f010597f:	42                   	inc    %edx
f0105980:	89 10                	mov    %edx,(%eax)
}
f0105982:	c9                   	leave  
f0105983:	c3                   	ret    

f0105984 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105984:	55                   	push   %ebp
f0105985:	89 e5                	mov    %esp,%ebp
f0105987:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010598a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010598d:	50                   	push   %eax
f010598e:	ff 75 10             	pushl  0x10(%ebp)
f0105991:	ff 75 0c             	pushl  0xc(%ebp)
f0105994:	ff 75 08             	pushl  0x8(%ebp)
f0105997:	e8 05 00 00 00       	call   f01059a1 <vprintfmt>
	va_end(ap);
f010599c:	83 c4 10             	add    $0x10,%esp
}
f010599f:	c9                   	leave  
f01059a0:	c3                   	ret    

f01059a1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01059a1:	55                   	push   %ebp
f01059a2:	89 e5                	mov    %esp,%ebp
f01059a4:	57                   	push   %edi
f01059a5:	56                   	push   %esi
f01059a6:	53                   	push   %ebx
f01059a7:	83 ec 2c             	sub    $0x2c,%esp
f01059aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01059ad:	8b 75 10             	mov    0x10(%ebp),%esi
f01059b0:	eb 13                	jmp    f01059c5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01059b2:	85 c0                	test   %eax,%eax
f01059b4:	0f 84 6d 03 00 00    	je     f0105d27 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f01059ba:	83 ec 08             	sub    $0x8,%esp
f01059bd:	57                   	push   %edi
f01059be:	50                   	push   %eax
f01059bf:	ff 55 08             	call   *0x8(%ebp)
f01059c2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01059c5:	0f b6 06             	movzbl (%esi),%eax
f01059c8:	46                   	inc    %esi
f01059c9:	83 f8 25             	cmp    $0x25,%eax
f01059cc:	75 e4                	jne    f01059b2 <vprintfmt+0x11>
f01059ce:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f01059d2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01059d9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f01059e0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01059e7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01059ec:	eb 28                	jmp    f0105a16 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059ee:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01059f0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f01059f4:	eb 20                	jmp    f0105a16 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059f6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01059f8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f01059fc:	eb 18                	jmp    f0105a16 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059fe:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105a00:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105a07:	eb 0d                	jmp    f0105a16 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105a09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105a0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a0f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a16:	8a 06                	mov    (%esi),%al
f0105a18:	0f b6 d0             	movzbl %al,%edx
f0105a1b:	8d 5e 01             	lea    0x1(%esi),%ebx
f0105a1e:	83 e8 23             	sub    $0x23,%eax
f0105a21:	3c 55                	cmp    $0x55,%al
f0105a23:	0f 87 e0 02 00 00    	ja     f0105d09 <vprintfmt+0x368>
f0105a29:	0f b6 c0             	movzbl %al,%eax
f0105a2c:	ff 24 85 40 8a 10 f0 	jmp    *-0xfef75c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105a33:	83 ea 30             	sub    $0x30,%edx
f0105a36:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0105a39:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0105a3c:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105a3f:	83 fa 09             	cmp    $0x9,%edx
f0105a42:	77 44                	ja     f0105a88 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a44:	89 de                	mov    %ebx,%esi
f0105a46:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105a49:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0105a4a:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105a4d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0105a51:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105a54:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0105a57:	83 fb 09             	cmp    $0x9,%ebx
f0105a5a:	76 ed                	jbe    f0105a49 <vprintfmt+0xa8>
f0105a5c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105a5f:	eb 29                	jmp    f0105a8a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105a61:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a64:	8d 50 04             	lea    0x4(%eax),%edx
f0105a67:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a6a:	8b 00                	mov    (%eax),%eax
f0105a6c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a6f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105a71:	eb 17                	jmp    f0105a8a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0105a73:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105a77:	78 85                	js     f01059fe <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a79:	89 de                	mov    %ebx,%esi
f0105a7b:	eb 99                	jmp    f0105a16 <vprintfmt+0x75>
f0105a7d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105a7f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0105a86:	eb 8e                	jmp    f0105a16 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a88:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0105a8a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105a8e:	79 86                	jns    f0105a16 <vprintfmt+0x75>
f0105a90:	e9 74 ff ff ff       	jmp    f0105a09 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105a95:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a96:	89 de                	mov    %ebx,%esi
f0105a98:	e9 79 ff ff ff       	jmp    f0105a16 <vprintfmt+0x75>
f0105a9d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105aa0:	8b 45 14             	mov    0x14(%ebp),%eax
f0105aa3:	8d 50 04             	lea    0x4(%eax),%edx
f0105aa6:	89 55 14             	mov    %edx,0x14(%ebp)
f0105aa9:	83 ec 08             	sub    $0x8,%esp
f0105aac:	57                   	push   %edi
f0105aad:	ff 30                	pushl  (%eax)
f0105aaf:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105ab2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ab5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105ab8:	e9 08 ff ff ff       	jmp    f01059c5 <vprintfmt+0x24>
f0105abd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105ac0:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ac3:	8d 50 04             	lea    0x4(%eax),%edx
f0105ac6:	89 55 14             	mov    %edx,0x14(%ebp)
f0105ac9:	8b 00                	mov    (%eax),%eax
f0105acb:	85 c0                	test   %eax,%eax
f0105acd:	79 02                	jns    f0105ad1 <vprintfmt+0x130>
f0105acf:	f7 d8                	neg    %eax
f0105ad1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105ad3:	83 f8 0f             	cmp    $0xf,%eax
f0105ad6:	7f 0b                	jg     f0105ae3 <vprintfmt+0x142>
f0105ad8:	8b 04 85 a0 8b 10 f0 	mov    -0xfef7460(,%eax,4),%eax
f0105adf:	85 c0                	test   %eax,%eax
f0105ae1:	75 1a                	jne    f0105afd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0105ae3:	52                   	push   %edx
f0105ae4:	68 16 89 10 f0       	push   $0xf0108916
f0105ae9:	57                   	push   %edi
f0105aea:	ff 75 08             	pushl  0x8(%ebp)
f0105aed:	e8 92 fe ff ff       	call   f0105984 <printfmt>
f0105af2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105af5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105af8:	e9 c8 fe ff ff       	jmp    f01059c5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0105afd:	50                   	push   %eax
f0105afe:	68 29 81 10 f0       	push   $0xf0108129
f0105b03:	57                   	push   %edi
f0105b04:	ff 75 08             	pushl  0x8(%ebp)
f0105b07:	e8 78 fe ff ff       	call   f0105984 <printfmt>
f0105b0c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b0f:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105b12:	e9 ae fe ff ff       	jmp    f01059c5 <vprintfmt+0x24>
f0105b17:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0105b1a:	89 de                	mov    %ebx,%esi
f0105b1c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0105b1f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105b22:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b25:	8d 50 04             	lea    0x4(%eax),%edx
f0105b28:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b2b:	8b 00                	mov    (%eax),%eax
f0105b2d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105b30:	85 c0                	test   %eax,%eax
f0105b32:	75 07                	jne    f0105b3b <vprintfmt+0x19a>
				p = "(null)";
f0105b34:	c7 45 d0 0f 89 10 f0 	movl   $0xf010890f,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0105b3b:	85 db                	test   %ebx,%ebx
f0105b3d:	7e 42                	jle    f0105b81 <vprintfmt+0x1e0>
f0105b3f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0105b43:	74 3c                	je     f0105b81 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105b45:	83 ec 08             	sub    $0x8,%esp
f0105b48:	51                   	push   %ecx
f0105b49:	ff 75 d0             	pushl  -0x30(%ebp)
f0105b4c:	e8 4f 03 00 00       	call   f0105ea0 <strnlen>
f0105b51:	29 c3                	sub    %eax,%ebx
f0105b53:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105b56:	83 c4 10             	add    $0x10,%esp
f0105b59:	85 db                	test   %ebx,%ebx
f0105b5b:	7e 24                	jle    f0105b81 <vprintfmt+0x1e0>
					putch(padc, putdat);
f0105b5d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0105b61:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0105b64:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105b67:	83 ec 08             	sub    $0x8,%esp
f0105b6a:	57                   	push   %edi
f0105b6b:	53                   	push   %ebx
f0105b6c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105b6f:	4e                   	dec    %esi
f0105b70:	83 c4 10             	add    $0x10,%esp
f0105b73:	85 f6                	test   %esi,%esi
f0105b75:	7f f0                	jg     f0105b67 <vprintfmt+0x1c6>
f0105b77:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0105b7a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105b81:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105b84:	0f be 02             	movsbl (%edx),%eax
f0105b87:	85 c0                	test   %eax,%eax
f0105b89:	75 47                	jne    f0105bd2 <vprintfmt+0x231>
f0105b8b:	eb 37                	jmp    f0105bc4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f0105b8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105b91:	74 16                	je     f0105ba9 <vprintfmt+0x208>
f0105b93:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105b96:	83 fa 5e             	cmp    $0x5e,%edx
f0105b99:	76 0e                	jbe    f0105ba9 <vprintfmt+0x208>
					putch('?', putdat);
f0105b9b:	83 ec 08             	sub    $0x8,%esp
f0105b9e:	57                   	push   %edi
f0105b9f:	6a 3f                	push   $0x3f
f0105ba1:	ff 55 08             	call   *0x8(%ebp)
f0105ba4:	83 c4 10             	add    $0x10,%esp
f0105ba7:	eb 0b                	jmp    f0105bb4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f0105ba9:	83 ec 08             	sub    $0x8,%esp
f0105bac:	57                   	push   %edi
f0105bad:	50                   	push   %eax
f0105bae:	ff 55 08             	call   *0x8(%ebp)
f0105bb1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105bb4:	ff 4d e4             	decl   -0x1c(%ebp)
f0105bb7:	0f be 03             	movsbl (%ebx),%eax
f0105bba:	85 c0                	test   %eax,%eax
f0105bbc:	74 03                	je     f0105bc1 <vprintfmt+0x220>
f0105bbe:	43                   	inc    %ebx
f0105bbf:	eb 1b                	jmp    f0105bdc <vprintfmt+0x23b>
f0105bc1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105bc4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105bc8:	7f 1e                	jg     f0105be8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105bca:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105bcd:	e9 f3 fd ff ff       	jmp    f01059c5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105bd2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105bd5:	43                   	inc    %ebx
f0105bd6:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0105bd9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0105bdc:	85 f6                	test   %esi,%esi
f0105bde:	78 ad                	js     f0105b8d <vprintfmt+0x1ec>
f0105be0:	4e                   	dec    %esi
f0105be1:	79 aa                	jns    f0105b8d <vprintfmt+0x1ec>
f0105be3:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0105be6:	eb dc                	jmp    f0105bc4 <vprintfmt+0x223>
f0105be8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105beb:	83 ec 08             	sub    $0x8,%esp
f0105bee:	57                   	push   %edi
f0105bef:	6a 20                	push   $0x20
f0105bf1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105bf4:	4b                   	dec    %ebx
f0105bf5:	83 c4 10             	add    $0x10,%esp
f0105bf8:	85 db                	test   %ebx,%ebx
f0105bfa:	7f ef                	jg     f0105beb <vprintfmt+0x24a>
f0105bfc:	e9 c4 fd ff ff       	jmp    f01059c5 <vprintfmt+0x24>
f0105c01:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105c04:	89 ca                	mov    %ecx,%edx
f0105c06:	8d 45 14             	lea    0x14(%ebp),%eax
f0105c09:	e8 2a fd ff ff       	call   f0105938 <getint>
f0105c0e:	89 c3                	mov    %eax,%ebx
f0105c10:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0105c12:	85 d2                	test   %edx,%edx
f0105c14:	78 0a                	js     f0105c20 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105c16:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105c1b:	e9 b0 00 00 00       	jmp    f0105cd0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105c20:	83 ec 08             	sub    $0x8,%esp
f0105c23:	57                   	push   %edi
f0105c24:	6a 2d                	push   $0x2d
f0105c26:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105c29:	f7 db                	neg    %ebx
f0105c2b:	83 d6 00             	adc    $0x0,%esi
f0105c2e:	f7 de                	neg    %esi
f0105c30:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105c33:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105c38:	e9 93 00 00 00       	jmp    f0105cd0 <vprintfmt+0x32f>
f0105c3d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105c40:	89 ca                	mov    %ecx,%edx
f0105c42:	8d 45 14             	lea    0x14(%ebp),%eax
f0105c45:	e8 b4 fc ff ff       	call   f01058fe <getuint>
f0105c4a:	89 c3                	mov    %eax,%ebx
f0105c4c:	89 d6                	mov    %edx,%esi
			base = 10;
f0105c4e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105c53:	eb 7b                	jmp    f0105cd0 <vprintfmt+0x32f>
f0105c55:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0105c58:	89 ca                	mov    %ecx,%edx
f0105c5a:	8d 45 14             	lea    0x14(%ebp),%eax
f0105c5d:	e8 d6 fc ff ff       	call   f0105938 <getint>
f0105c62:	89 c3                	mov    %eax,%ebx
f0105c64:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f0105c66:	85 d2                	test   %edx,%edx
f0105c68:	78 07                	js     f0105c71 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f0105c6a:	b8 08 00 00 00       	mov    $0x8,%eax
f0105c6f:	eb 5f                	jmp    f0105cd0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0105c71:	83 ec 08             	sub    $0x8,%esp
f0105c74:	57                   	push   %edi
f0105c75:	6a 2d                	push   $0x2d
f0105c77:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f0105c7a:	f7 db                	neg    %ebx
f0105c7c:	83 d6 00             	adc    $0x0,%esi
f0105c7f:	f7 de                	neg    %esi
f0105c81:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f0105c84:	b8 08 00 00 00       	mov    $0x8,%eax
f0105c89:	eb 45                	jmp    f0105cd0 <vprintfmt+0x32f>
f0105c8b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f0105c8e:	83 ec 08             	sub    $0x8,%esp
f0105c91:	57                   	push   %edi
f0105c92:	6a 30                	push   $0x30
f0105c94:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105c97:	83 c4 08             	add    $0x8,%esp
f0105c9a:	57                   	push   %edi
f0105c9b:	6a 78                	push   $0x78
f0105c9d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105ca0:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ca3:	8d 50 04             	lea    0x4(%eax),%edx
f0105ca6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105ca9:	8b 18                	mov    (%eax),%ebx
f0105cab:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105cb0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105cb3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105cb8:	eb 16                	jmp    f0105cd0 <vprintfmt+0x32f>
f0105cba:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105cbd:	89 ca                	mov    %ecx,%edx
f0105cbf:	8d 45 14             	lea    0x14(%ebp),%eax
f0105cc2:	e8 37 fc ff ff       	call   f01058fe <getuint>
f0105cc7:	89 c3                	mov    %eax,%ebx
f0105cc9:	89 d6                	mov    %edx,%esi
			base = 16;
f0105ccb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105cd0:	83 ec 0c             	sub    $0xc,%esp
f0105cd3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0105cd7:	52                   	push   %edx
f0105cd8:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105cdb:	50                   	push   %eax
f0105cdc:	56                   	push   %esi
f0105cdd:	53                   	push   %ebx
f0105cde:	89 fa                	mov    %edi,%edx
f0105ce0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ce3:	e8 68 fb ff ff       	call   f0105850 <printnum>
			break;
f0105ce8:	83 c4 20             	add    $0x20,%esp
f0105ceb:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105cee:	e9 d2 fc ff ff       	jmp    f01059c5 <vprintfmt+0x24>
f0105cf3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105cf6:	83 ec 08             	sub    $0x8,%esp
f0105cf9:	57                   	push   %edi
f0105cfa:	52                   	push   %edx
f0105cfb:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105cfe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d01:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105d04:	e9 bc fc ff ff       	jmp    f01059c5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105d09:	83 ec 08             	sub    $0x8,%esp
f0105d0c:	57                   	push   %edi
f0105d0d:	6a 25                	push   $0x25
f0105d0f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105d12:	83 c4 10             	add    $0x10,%esp
f0105d15:	eb 02                	jmp    f0105d19 <vprintfmt+0x378>
f0105d17:	89 c6                	mov    %eax,%esi
f0105d19:	8d 46 ff             	lea    -0x1(%esi),%eax
f0105d1c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105d20:	75 f5                	jne    f0105d17 <vprintfmt+0x376>
f0105d22:	e9 9e fc ff ff       	jmp    f01059c5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0105d27:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d2a:	5b                   	pop    %ebx
f0105d2b:	5e                   	pop    %esi
f0105d2c:	5f                   	pop    %edi
f0105d2d:	c9                   	leave  
f0105d2e:	c3                   	ret    

f0105d2f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105d2f:	55                   	push   %ebp
f0105d30:	89 e5                	mov    %esp,%ebp
f0105d32:	83 ec 18             	sub    $0x18,%esp
f0105d35:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d38:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105d3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105d3e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105d42:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105d45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105d4c:	85 c0                	test   %eax,%eax
f0105d4e:	74 26                	je     f0105d76 <vsnprintf+0x47>
f0105d50:	85 d2                	test   %edx,%edx
f0105d52:	7e 29                	jle    f0105d7d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105d54:	ff 75 14             	pushl  0x14(%ebp)
f0105d57:	ff 75 10             	pushl  0x10(%ebp)
f0105d5a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105d5d:	50                   	push   %eax
f0105d5e:	68 6a 59 10 f0       	push   $0xf010596a
f0105d63:	e8 39 fc ff ff       	call   f01059a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105d68:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105d6b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105d71:	83 c4 10             	add    $0x10,%esp
f0105d74:	eb 0c                	jmp    f0105d82 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105d76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105d7b:	eb 05                	jmp    f0105d82 <vsnprintf+0x53>
f0105d7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105d82:	c9                   	leave  
f0105d83:	c3                   	ret    

f0105d84 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105d84:	55                   	push   %ebp
f0105d85:	89 e5                	mov    %esp,%ebp
f0105d87:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105d8a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105d8d:	50                   	push   %eax
f0105d8e:	ff 75 10             	pushl  0x10(%ebp)
f0105d91:	ff 75 0c             	pushl  0xc(%ebp)
f0105d94:	ff 75 08             	pushl  0x8(%ebp)
f0105d97:	e8 93 ff ff ff       	call   f0105d2f <vsnprintf>
	va_end(ap);

	return rc;
}
f0105d9c:	c9                   	leave  
f0105d9d:	c3                   	ret    
	...

f0105da0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105da0:	55                   	push   %ebp
f0105da1:	89 e5                	mov    %esp,%ebp
f0105da3:	57                   	push   %edi
f0105da4:	56                   	push   %esi
f0105da5:	53                   	push   %ebx
f0105da6:	83 ec 0c             	sub    $0xc,%esp
f0105da9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105dac:	85 c0                	test   %eax,%eax
f0105dae:	74 11                	je     f0105dc1 <readline+0x21>
		cprintf("%s", prompt);
f0105db0:	83 ec 08             	sub    $0x8,%esp
f0105db3:	50                   	push   %eax
f0105db4:	68 29 81 10 f0       	push   $0xf0108129
f0105db9:	e8 a3 e0 ff ff       	call   f0103e61 <cprintf>
f0105dbe:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105dc1:	83 ec 0c             	sub    $0xc,%esp
f0105dc4:	6a 00                	push   $0x0
f0105dc6:	e8 2a aa ff ff       	call   f01007f5 <iscons>
f0105dcb:	89 c7                	mov    %eax,%edi
f0105dcd:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105dd0:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105dd5:	e8 0a aa ff ff       	call   f01007e4 <getchar>
f0105dda:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105ddc:	85 c0                	test   %eax,%eax
f0105dde:	79 21                	jns    f0105e01 <readline+0x61>
			if (c != -E_EOF)
f0105de0:	83 f8 f8             	cmp    $0xfffffff8,%eax
f0105de3:	0f 84 89 00 00 00    	je     f0105e72 <readline+0xd2>
				cprintf("read error: %e\n", c);
f0105de9:	83 ec 08             	sub    $0x8,%esp
f0105dec:	50                   	push   %eax
f0105ded:	68 ff 8b 10 f0       	push   $0xf0108bff
f0105df2:	e8 6a e0 ff ff       	call   f0103e61 <cprintf>
f0105df7:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105dfa:	b8 00 00 00 00       	mov    $0x0,%eax
f0105dff:	eb 76                	jmp    f0105e77 <readline+0xd7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105e01:	83 f8 08             	cmp    $0x8,%eax
f0105e04:	74 05                	je     f0105e0b <readline+0x6b>
f0105e06:	83 f8 7f             	cmp    $0x7f,%eax
f0105e09:	75 18                	jne    f0105e23 <readline+0x83>
f0105e0b:	85 f6                	test   %esi,%esi
f0105e0d:	7e 14                	jle    f0105e23 <readline+0x83>
			if (echoing)
f0105e0f:	85 ff                	test   %edi,%edi
f0105e11:	74 0d                	je     f0105e20 <readline+0x80>
				cputchar('\b');
f0105e13:	83 ec 0c             	sub    $0xc,%esp
f0105e16:	6a 08                	push   $0x8
f0105e18:	e8 b7 a9 ff ff       	call   f01007d4 <cputchar>
f0105e1d:	83 c4 10             	add    $0x10,%esp
			i--;
f0105e20:	4e                   	dec    %esi
f0105e21:	eb b2                	jmp    f0105dd5 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105e23:	83 fb 1f             	cmp    $0x1f,%ebx
f0105e26:	7e 21                	jle    f0105e49 <readline+0xa9>
f0105e28:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105e2e:	7f 19                	jg     f0105e49 <readline+0xa9>
			if (echoing)
f0105e30:	85 ff                	test   %edi,%edi
f0105e32:	74 0c                	je     f0105e40 <readline+0xa0>
				cputchar(c);
f0105e34:	83 ec 0c             	sub    $0xc,%esp
f0105e37:	53                   	push   %ebx
f0105e38:	e8 97 a9 ff ff       	call   f01007d4 <cputchar>
f0105e3d:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105e40:	88 9e 80 0a 22 f0    	mov    %bl,-0xfddf580(%esi)
f0105e46:	46                   	inc    %esi
f0105e47:	eb 8c                	jmp    f0105dd5 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105e49:	83 fb 0a             	cmp    $0xa,%ebx
f0105e4c:	74 05                	je     f0105e53 <readline+0xb3>
f0105e4e:	83 fb 0d             	cmp    $0xd,%ebx
f0105e51:	75 82                	jne    f0105dd5 <readline+0x35>
			if (echoing)
f0105e53:	85 ff                	test   %edi,%edi
f0105e55:	74 0d                	je     f0105e64 <readline+0xc4>
				cputchar('\n');
f0105e57:	83 ec 0c             	sub    $0xc,%esp
f0105e5a:	6a 0a                	push   $0xa
f0105e5c:	e8 73 a9 ff ff       	call   f01007d4 <cputchar>
f0105e61:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105e64:	c6 86 80 0a 22 f0 00 	movb   $0x0,-0xfddf580(%esi)
			return buf;
f0105e6b:	b8 80 0a 22 f0       	mov    $0xf0220a80,%eax
f0105e70:	eb 05                	jmp    f0105e77 <readline+0xd7>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105e72:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105e77:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105e7a:	5b                   	pop    %ebx
f0105e7b:	5e                   	pop    %esi
f0105e7c:	5f                   	pop    %edi
f0105e7d:	c9                   	leave  
f0105e7e:	c3                   	ret    
	...

f0105e80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105e80:	55                   	push   %ebp
f0105e81:	89 e5                	mov    %esp,%ebp
f0105e83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105e86:	80 3a 00             	cmpb   $0x0,(%edx)
f0105e89:	74 0e                	je     f0105e99 <strlen+0x19>
f0105e8b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105e90:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105e91:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105e95:	75 f9                	jne    f0105e90 <strlen+0x10>
f0105e97:	eb 05                	jmp    f0105e9e <strlen+0x1e>
f0105e99:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105e9e:	c9                   	leave  
f0105e9f:	c3                   	ret    

f0105ea0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105ea0:	55                   	push   %ebp
f0105ea1:	89 e5                	mov    %esp,%ebp
f0105ea3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105ea6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105ea9:	85 d2                	test   %edx,%edx
f0105eab:	74 17                	je     f0105ec4 <strnlen+0x24>
f0105ead:	80 39 00             	cmpb   $0x0,(%ecx)
f0105eb0:	74 19                	je     f0105ecb <strnlen+0x2b>
f0105eb2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105eb7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105eb8:	39 d0                	cmp    %edx,%eax
f0105eba:	74 14                	je     f0105ed0 <strnlen+0x30>
f0105ebc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105ec0:	75 f5                	jne    f0105eb7 <strnlen+0x17>
f0105ec2:	eb 0c                	jmp    f0105ed0 <strnlen+0x30>
f0105ec4:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ec9:	eb 05                	jmp    f0105ed0 <strnlen+0x30>
f0105ecb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105ed0:	c9                   	leave  
f0105ed1:	c3                   	ret    

f0105ed2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105ed2:	55                   	push   %ebp
f0105ed3:	89 e5                	mov    %esp,%ebp
f0105ed5:	53                   	push   %ebx
f0105ed6:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ed9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105edc:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ee1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0105ee4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105ee7:	42                   	inc    %edx
f0105ee8:	84 c9                	test   %cl,%cl
f0105eea:	75 f5                	jne    f0105ee1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105eec:	5b                   	pop    %ebx
f0105eed:	c9                   	leave  
f0105eee:	c3                   	ret    

f0105eef <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105eef:	55                   	push   %ebp
f0105ef0:	89 e5                	mov    %esp,%ebp
f0105ef2:	53                   	push   %ebx
f0105ef3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105ef6:	53                   	push   %ebx
f0105ef7:	e8 84 ff ff ff       	call   f0105e80 <strlen>
f0105efc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105eff:	ff 75 0c             	pushl  0xc(%ebp)
f0105f02:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0105f05:	50                   	push   %eax
f0105f06:	e8 c7 ff ff ff       	call   f0105ed2 <strcpy>
	return dst;
}
f0105f0b:	89 d8                	mov    %ebx,%eax
f0105f0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105f10:	c9                   	leave  
f0105f11:	c3                   	ret    

f0105f12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105f12:	55                   	push   %ebp
f0105f13:	89 e5                	mov    %esp,%ebp
f0105f15:	56                   	push   %esi
f0105f16:	53                   	push   %ebx
f0105f17:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f1a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f1d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105f20:	85 f6                	test   %esi,%esi
f0105f22:	74 15                	je     f0105f39 <strncpy+0x27>
f0105f24:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0105f29:	8a 1a                	mov    (%edx),%bl
f0105f2b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105f2e:	80 3a 01             	cmpb   $0x1,(%edx)
f0105f31:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105f34:	41                   	inc    %ecx
f0105f35:	39 ce                	cmp    %ecx,%esi
f0105f37:	77 f0                	ja     f0105f29 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105f39:	5b                   	pop    %ebx
f0105f3a:	5e                   	pop    %esi
f0105f3b:	c9                   	leave  
f0105f3c:	c3                   	ret    

f0105f3d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105f3d:	55                   	push   %ebp
f0105f3e:	89 e5                	mov    %esp,%ebp
f0105f40:	57                   	push   %edi
f0105f41:	56                   	push   %esi
f0105f42:	53                   	push   %ebx
f0105f43:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105f49:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105f4c:	85 f6                	test   %esi,%esi
f0105f4e:	74 32                	je     f0105f82 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0105f50:	83 fe 01             	cmp    $0x1,%esi
f0105f53:	74 22                	je     f0105f77 <strlcpy+0x3a>
f0105f55:	8a 0b                	mov    (%ebx),%cl
f0105f57:	84 c9                	test   %cl,%cl
f0105f59:	74 20                	je     f0105f7b <strlcpy+0x3e>
f0105f5b:	89 f8                	mov    %edi,%eax
f0105f5d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0105f62:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105f65:	88 08                	mov    %cl,(%eax)
f0105f67:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105f68:	39 f2                	cmp    %esi,%edx
f0105f6a:	74 11                	je     f0105f7d <strlcpy+0x40>
f0105f6c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0105f70:	42                   	inc    %edx
f0105f71:	84 c9                	test   %cl,%cl
f0105f73:	75 f0                	jne    f0105f65 <strlcpy+0x28>
f0105f75:	eb 06                	jmp    f0105f7d <strlcpy+0x40>
f0105f77:	89 f8                	mov    %edi,%eax
f0105f79:	eb 02                	jmp    f0105f7d <strlcpy+0x40>
f0105f7b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105f7d:	c6 00 00             	movb   $0x0,(%eax)
f0105f80:	eb 02                	jmp    f0105f84 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105f82:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0105f84:	29 f8                	sub    %edi,%eax
}
f0105f86:	5b                   	pop    %ebx
f0105f87:	5e                   	pop    %esi
f0105f88:	5f                   	pop    %edi
f0105f89:	c9                   	leave  
f0105f8a:	c3                   	ret    

f0105f8b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105f8b:	55                   	push   %ebp
f0105f8c:	89 e5                	mov    %esp,%ebp
f0105f8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105f91:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105f94:	8a 01                	mov    (%ecx),%al
f0105f96:	84 c0                	test   %al,%al
f0105f98:	74 10                	je     f0105faa <strcmp+0x1f>
f0105f9a:	3a 02                	cmp    (%edx),%al
f0105f9c:	75 0c                	jne    f0105faa <strcmp+0x1f>
		p++, q++;
f0105f9e:	41                   	inc    %ecx
f0105f9f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105fa0:	8a 01                	mov    (%ecx),%al
f0105fa2:	84 c0                	test   %al,%al
f0105fa4:	74 04                	je     f0105faa <strcmp+0x1f>
f0105fa6:	3a 02                	cmp    (%edx),%al
f0105fa8:	74 f4                	je     f0105f9e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105faa:	0f b6 c0             	movzbl %al,%eax
f0105fad:	0f b6 12             	movzbl (%edx),%edx
f0105fb0:	29 d0                	sub    %edx,%eax
}
f0105fb2:	c9                   	leave  
f0105fb3:	c3                   	ret    

f0105fb4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105fb4:	55                   	push   %ebp
f0105fb5:	89 e5                	mov    %esp,%ebp
f0105fb7:	53                   	push   %ebx
f0105fb8:	8b 55 08             	mov    0x8(%ebp),%edx
f0105fbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105fbe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0105fc1:	85 c0                	test   %eax,%eax
f0105fc3:	74 1b                	je     f0105fe0 <strncmp+0x2c>
f0105fc5:	8a 1a                	mov    (%edx),%bl
f0105fc7:	84 db                	test   %bl,%bl
f0105fc9:	74 24                	je     f0105fef <strncmp+0x3b>
f0105fcb:	3a 19                	cmp    (%ecx),%bl
f0105fcd:	75 20                	jne    f0105fef <strncmp+0x3b>
f0105fcf:	48                   	dec    %eax
f0105fd0:	74 15                	je     f0105fe7 <strncmp+0x33>
		n--, p++, q++;
f0105fd2:	42                   	inc    %edx
f0105fd3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105fd4:	8a 1a                	mov    (%edx),%bl
f0105fd6:	84 db                	test   %bl,%bl
f0105fd8:	74 15                	je     f0105fef <strncmp+0x3b>
f0105fda:	3a 19                	cmp    (%ecx),%bl
f0105fdc:	74 f1                	je     f0105fcf <strncmp+0x1b>
f0105fde:	eb 0f                	jmp    f0105fef <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105fe0:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fe5:	eb 05                	jmp    f0105fec <strncmp+0x38>
f0105fe7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105fec:	5b                   	pop    %ebx
f0105fed:	c9                   	leave  
f0105fee:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105fef:	0f b6 02             	movzbl (%edx),%eax
f0105ff2:	0f b6 11             	movzbl (%ecx),%edx
f0105ff5:	29 d0                	sub    %edx,%eax
f0105ff7:	eb f3                	jmp    f0105fec <strncmp+0x38>

f0105ff9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105ff9:	55                   	push   %ebp
f0105ffa:	89 e5                	mov    %esp,%ebp
f0105ffc:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fff:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0106002:	8a 10                	mov    (%eax),%dl
f0106004:	84 d2                	test   %dl,%dl
f0106006:	74 18                	je     f0106020 <strchr+0x27>
		if (*s == c)
f0106008:	38 ca                	cmp    %cl,%dl
f010600a:	75 06                	jne    f0106012 <strchr+0x19>
f010600c:	eb 17                	jmp    f0106025 <strchr+0x2c>
f010600e:	38 ca                	cmp    %cl,%dl
f0106010:	74 13                	je     f0106025 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0106012:	40                   	inc    %eax
f0106013:	8a 10                	mov    (%eax),%dl
f0106015:	84 d2                	test   %dl,%dl
f0106017:	75 f5                	jne    f010600e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0106019:	b8 00 00 00 00       	mov    $0x0,%eax
f010601e:	eb 05                	jmp    f0106025 <strchr+0x2c>
f0106020:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106025:	c9                   	leave  
f0106026:	c3                   	ret    

f0106027 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0106027:	55                   	push   %ebp
f0106028:	89 e5                	mov    %esp,%ebp
f010602a:	8b 45 08             	mov    0x8(%ebp),%eax
f010602d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0106030:	8a 10                	mov    (%eax),%dl
f0106032:	84 d2                	test   %dl,%dl
f0106034:	74 11                	je     f0106047 <strfind+0x20>
		if (*s == c)
f0106036:	38 ca                	cmp    %cl,%dl
f0106038:	75 06                	jne    f0106040 <strfind+0x19>
f010603a:	eb 0b                	jmp    f0106047 <strfind+0x20>
f010603c:	38 ca                	cmp    %cl,%dl
f010603e:	74 07                	je     f0106047 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0106040:	40                   	inc    %eax
f0106041:	8a 10                	mov    (%eax),%dl
f0106043:	84 d2                	test   %dl,%dl
f0106045:	75 f5                	jne    f010603c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f0106047:	c9                   	leave  
f0106048:	c3                   	ret    

f0106049 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106049:	55                   	push   %ebp
f010604a:	89 e5                	mov    %esp,%ebp
f010604c:	57                   	push   %edi
f010604d:	56                   	push   %esi
f010604e:	53                   	push   %ebx
f010604f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106052:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106055:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106058:	85 c9                	test   %ecx,%ecx
f010605a:	74 30                	je     f010608c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010605c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106062:	75 25                	jne    f0106089 <memset+0x40>
f0106064:	f6 c1 03             	test   $0x3,%cl
f0106067:	75 20                	jne    f0106089 <memset+0x40>
		c &= 0xFF;
f0106069:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010606c:	89 d3                	mov    %edx,%ebx
f010606e:	c1 e3 08             	shl    $0x8,%ebx
f0106071:	89 d6                	mov    %edx,%esi
f0106073:	c1 e6 18             	shl    $0x18,%esi
f0106076:	89 d0                	mov    %edx,%eax
f0106078:	c1 e0 10             	shl    $0x10,%eax
f010607b:	09 f0                	or     %esi,%eax
f010607d:	09 d0                	or     %edx,%eax
f010607f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0106081:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0106084:	fc                   	cld    
f0106085:	f3 ab                	rep stos %eax,%es:(%edi)
f0106087:	eb 03                	jmp    f010608c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0106089:	fc                   	cld    
f010608a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010608c:	89 f8                	mov    %edi,%eax
f010608e:	5b                   	pop    %ebx
f010608f:	5e                   	pop    %esi
f0106090:	5f                   	pop    %edi
f0106091:	c9                   	leave  
f0106092:	c3                   	ret    

f0106093 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106093:	55                   	push   %ebp
f0106094:	89 e5                	mov    %esp,%ebp
f0106096:	57                   	push   %edi
f0106097:	56                   	push   %esi
f0106098:	8b 45 08             	mov    0x8(%ebp),%eax
f010609b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010609e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01060a1:	39 c6                	cmp    %eax,%esi
f01060a3:	73 34                	jae    f01060d9 <memmove+0x46>
f01060a5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01060a8:	39 d0                	cmp    %edx,%eax
f01060aa:	73 2d                	jae    f01060d9 <memmove+0x46>
		s += n;
		d += n;
f01060ac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01060af:	f6 c2 03             	test   $0x3,%dl
f01060b2:	75 1b                	jne    f01060cf <memmove+0x3c>
f01060b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01060ba:	75 13                	jne    f01060cf <memmove+0x3c>
f01060bc:	f6 c1 03             	test   $0x3,%cl
f01060bf:	75 0e                	jne    f01060cf <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01060c1:	83 ef 04             	sub    $0x4,%edi
f01060c4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01060c7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01060ca:	fd                   	std    
f01060cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01060cd:	eb 07                	jmp    f01060d6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01060cf:	4f                   	dec    %edi
f01060d0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01060d3:	fd                   	std    
f01060d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01060d6:	fc                   	cld    
f01060d7:	eb 20                	jmp    f01060f9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01060d9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01060df:	75 13                	jne    f01060f4 <memmove+0x61>
f01060e1:	a8 03                	test   $0x3,%al
f01060e3:	75 0f                	jne    f01060f4 <memmove+0x61>
f01060e5:	f6 c1 03             	test   $0x3,%cl
f01060e8:	75 0a                	jne    f01060f4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01060ea:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01060ed:	89 c7                	mov    %eax,%edi
f01060ef:	fc                   	cld    
f01060f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01060f2:	eb 05                	jmp    f01060f9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01060f4:	89 c7                	mov    %eax,%edi
f01060f6:	fc                   	cld    
f01060f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01060f9:	5e                   	pop    %esi
f01060fa:	5f                   	pop    %edi
f01060fb:	c9                   	leave  
f01060fc:	c3                   	ret    

f01060fd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01060fd:	55                   	push   %ebp
f01060fe:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0106100:	ff 75 10             	pushl  0x10(%ebp)
f0106103:	ff 75 0c             	pushl  0xc(%ebp)
f0106106:	ff 75 08             	pushl  0x8(%ebp)
f0106109:	e8 85 ff ff ff       	call   f0106093 <memmove>
}
f010610e:	c9                   	leave  
f010610f:	c3                   	ret    

f0106110 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0106110:	55                   	push   %ebp
f0106111:	89 e5                	mov    %esp,%ebp
f0106113:	57                   	push   %edi
f0106114:	56                   	push   %esi
f0106115:	53                   	push   %ebx
f0106116:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106119:	8b 75 0c             	mov    0xc(%ebp),%esi
f010611c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010611f:	85 ff                	test   %edi,%edi
f0106121:	74 32                	je     f0106155 <memcmp+0x45>
		if (*s1 != *s2)
f0106123:	8a 03                	mov    (%ebx),%al
f0106125:	8a 0e                	mov    (%esi),%cl
f0106127:	38 c8                	cmp    %cl,%al
f0106129:	74 19                	je     f0106144 <memcmp+0x34>
f010612b:	eb 0d                	jmp    f010613a <memcmp+0x2a>
f010612d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0106131:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0106135:	42                   	inc    %edx
f0106136:	38 c8                	cmp    %cl,%al
f0106138:	74 10                	je     f010614a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f010613a:	0f b6 c0             	movzbl %al,%eax
f010613d:	0f b6 c9             	movzbl %cl,%ecx
f0106140:	29 c8                	sub    %ecx,%eax
f0106142:	eb 16                	jmp    f010615a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106144:	4f                   	dec    %edi
f0106145:	ba 00 00 00 00       	mov    $0x0,%edx
f010614a:	39 fa                	cmp    %edi,%edx
f010614c:	75 df                	jne    f010612d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010614e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106153:	eb 05                	jmp    f010615a <memcmp+0x4a>
f0106155:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010615a:	5b                   	pop    %ebx
f010615b:	5e                   	pop    %esi
f010615c:	5f                   	pop    %edi
f010615d:	c9                   	leave  
f010615e:	c3                   	ret    

f010615f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010615f:	55                   	push   %ebp
f0106160:	89 e5                	mov    %esp,%ebp
f0106162:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0106165:	89 c2                	mov    %eax,%edx
f0106167:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010616a:	39 d0                	cmp    %edx,%eax
f010616c:	73 12                	jae    f0106180 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f010616e:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0106171:	38 08                	cmp    %cl,(%eax)
f0106173:	75 06                	jne    f010617b <memfind+0x1c>
f0106175:	eb 09                	jmp    f0106180 <memfind+0x21>
f0106177:	38 08                	cmp    %cl,(%eax)
f0106179:	74 05                	je     f0106180 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010617b:	40                   	inc    %eax
f010617c:	39 c2                	cmp    %eax,%edx
f010617e:	77 f7                	ja     f0106177 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106180:	c9                   	leave  
f0106181:	c3                   	ret    

f0106182 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106182:	55                   	push   %ebp
f0106183:	89 e5                	mov    %esp,%ebp
f0106185:	57                   	push   %edi
f0106186:	56                   	push   %esi
f0106187:	53                   	push   %ebx
f0106188:	8b 55 08             	mov    0x8(%ebp),%edx
f010618b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010618e:	eb 01                	jmp    f0106191 <strtol+0xf>
		s++;
f0106190:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106191:	8a 02                	mov    (%edx),%al
f0106193:	3c 20                	cmp    $0x20,%al
f0106195:	74 f9                	je     f0106190 <strtol+0xe>
f0106197:	3c 09                	cmp    $0x9,%al
f0106199:	74 f5                	je     f0106190 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010619b:	3c 2b                	cmp    $0x2b,%al
f010619d:	75 08                	jne    f01061a7 <strtol+0x25>
		s++;
f010619f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01061a0:	bf 00 00 00 00       	mov    $0x0,%edi
f01061a5:	eb 13                	jmp    f01061ba <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01061a7:	3c 2d                	cmp    $0x2d,%al
f01061a9:	75 0a                	jne    f01061b5 <strtol+0x33>
		s++, neg = 1;
f01061ab:	8d 52 01             	lea    0x1(%edx),%edx
f01061ae:	bf 01 00 00 00       	mov    $0x1,%edi
f01061b3:	eb 05                	jmp    f01061ba <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01061b5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01061ba:	85 db                	test   %ebx,%ebx
f01061bc:	74 05                	je     f01061c3 <strtol+0x41>
f01061be:	83 fb 10             	cmp    $0x10,%ebx
f01061c1:	75 28                	jne    f01061eb <strtol+0x69>
f01061c3:	8a 02                	mov    (%edx),%al
f01061c5:	3c 30                	cmp    $0x30,%al
f01061c7:	75 10                	jne    f01061d9 <strtol+0x57>
f01061c9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01061cd:	75 0a                	jne    f01061d9 <strtol+0x57>
		s += 2, base = 16;
f01061cf:	83 c2 02             	add    $0x2,%edx
f01061d2:	bb 10 00 00 00       	mov    $0x10,%ebx
f01061d7:	eb 12                	jmp    f01061eb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01061d9:	85 db                	test   %ebx,%ebx
f01061db:	75 0e                	jne    f01061eb <strtol+0x69>
f01061dd:	3c 30                	cmp    $0x30,%al
f01061df:	75 05                	jne    f01061e6 <strtol+0x64>
		s++, base = 8;
f01061e1:	42                   	inc    %edx
f01061e2:	b3 08                	mov    $0x8,%bl
f01061e4:	eb 05                	jmp    f01061eb <strtol+0x69>
	else if (base == 0)
		base = 10;
f01061e6:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01061eb:	b8 00 00 00 00       	mov    $0x0,%eax
f01061f0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01061f2:	8a 0a                	mov    (%edx),%cl
f01061f4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01061f7:	80 fb 09             	cmp    $0x9,%bl
f01061fa:	77 08                	ja     f0106204 <strtol+0x82>
			dig = *s - '0';
f01061fc:	0f be c9             	movsbl %cl,%ecx
f01061ff:	83 e9 30             	sub    $0x30,%ecx
f0106202:	eb 1e                	jmp    f0106222 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0106204:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0106207:	80 fb 19             	cmp    $0x19,%bl
f010620a:	77 08                	ja     f0106214 <strtol+0x92>
			dig = *s - 'a' + 10;
f010620c:	0f be c9             	movsbl %cl,%ecx
f010620f:	83 e9 57             	sub    $0x57,%ecx
f0106212:	eb 0e                	jmp    f0106222 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0106214:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0106217:	80 fb 19             	cmp    $0x19,%bl
f010621a:	77 13                	ja     f010622f <strtol+0xad>
			dig = *s - 'A' + 10;
f010621c:	0f be c9             	movsbl %cl,%ecx
f010621f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106222:	39 f1                	cmp    %esi,%ecx
f0106224:	7d 0d                	jge    f0106233 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f0106226:	42                   	inc    %edx
f0106227:	0f af c6             	imul   %esi,%eax
f010622a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f010622d:	eb c3                	jmp    f01061f2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010622f:	89 c1                	mov    %eax,%ecx
f0106231:	eb 02                	jmp    f0106235 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0106233:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0106235:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106239:	74 05                	je     f0106240 <strtol+0xbe>
		*endptr = (char *) s;
f010623b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010623e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0106240:	85 ff                	test   %edi,%edi
f0106242:	74 04                	je     f0106248 <strtol+0xc6>
f0106244:	89 c8                	mov    %ecx,%eax
f0106246:	f7 d8                	neg    %eax
}
f0106248:	5b                   	pop    %ebx
f0106249:	5e                   	pop    %esi
f010624a:	5f                   	pop    %edi
f010624b:	c9                   	leave  
f010624c:	c3                   	ret    
f010624d:	00 00                	add    %al,(%eax)
	...

f0106250 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106250:	fa                   	cli    

	xorw    %ax, %ax
f0106251:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106253:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106255:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106257:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106259:	0f 01 16             	lgdtl  (%esi)
f010625c:	74 70                	je     f01062ce <sum+0x2>
	movl    %cr0, %eax
f010625e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106261:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106265:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106268:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010626e:	08 00                	or     %al,(%eax)

f0106270 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106270:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106274:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106276:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106278:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010627a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010627e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106280:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106282:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl    %eax, %cr3
f0106287:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010628a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f010628d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106292:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106295:	8b 25 84 0e 22 f0    	mov    0xf0220e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010629b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01062a0:	b8 c2 00 10 f0       	mov    $0xf01000c2,%eax
	call    *%eax
f01062a5:	ff d0                	call   *%eax

f01062a7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01062a7:	eb fe                	jmp    f01062a7 <spin>
f01062a9:	8d 76 00             	lea    0x0(%esi),%esi

f01062ac <gdt>:
	...
f01062b4:	ff                   	(bad)  
f01062b5:	ff 00                	incl   (%eax)
f01062b7:	00 00                	add    %al,(%eax)
f01062b9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01062c0:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01062c4 <gdtdesc>:
f01062c4:	17                   	pop    %ss
f01062c5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01062ca <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01062ca:	90                   	nop
	...

f01062cc <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f01062cc:	55                   	push   %ebp
f01062cd:	89 e5                	mov    %esp,%ebp
f01062cf:	56                   	push   %esi
f01062d0:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01062d1:	85 d2                	test   %edx,%edx
f01062d3:	7e 17                	jle    f01062ec <sum+0x20>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01062d5:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f01062da:	b9 00 00 00 00       	mov    $0x0,%ecx
		sum += ((uint8_t *)addr)[i];
f01062df:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f01062e3:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01062e5:	41                   	inc    %ecx
f01062e6:	39 d1                	cmp    %edx,%ecx
f01062e8:	75 f5                	jne    f01062df <sum+0x13>
f01062ea:	eb 05                	jmp    f01062f1 <sum+0x25>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01062ec:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f01062f1:	88 d8                	mov    %bl,%al
f01062f3:	5b                   	pop    %ebx
f01062f4:	5e                   	pop    %esi
f01062f5:	c9                   	leave  
f01062f6:	c3                   	ret    

f01062f7 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01062f7:	55                   	push   %ebp
f01062f8:	89 e5                	mov    %esp,%ebp
f01062fa:	56                   	push   %esi
f01062fb:	53                   	push   %ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01062fc:	8b 0d 88 0e 22 f0    	mov    0xf0220e88,%ecx
f0106302:	89 c3                	mov    %eax,%ebx
f0106304:	c1 eb 0c             	shr    $0xc,%ebx
f0106307:	39 cb                	cmp    %ecx,%ebx
f0106309:	72 12                	jb     f010631d <mpsearch1+0x26>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010630b:	50                   	push   %eax
f010630c:	68 88 6d 10 f0       	push   $0xf0106d88
f0106311:	6a 57                	push   $0x57
f0106313:	68 9d 8d 10 f0       	push   $0xf0108d9d
f0106318:	e8 4b 9d ff ff       	call   f0100068 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010631d:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106320:	89 f2                	mov    %esi,%edx
f0106322:	c1 ea 0c             	shr    $0xc,%edx
f0106325:	39 d1                	cmp    %edx,%ecx
f0106327:	77 12                	ja     f010633b <mpsearch1+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106329:	56                   	push   %esi
f010632a:	68 88 6d 10 f0       	push   $0xf0106d88
f010632f:	6a 57                	push   $0x57
f0106331:	68 9d 8d 10 f0       	push   $0xf0108d9d
f0106336:	e8 2d 9d ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f010633b:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0106341:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106347:	39 f3                	cmp    %esi,%ebx
f0106349:	73 35                	jae    f0106380 <mpsearch1+0x89>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010634b:	83 ec 04             	sub    $0x4,%esp
f010634e:	6a 04                	push   $0x4
f0106350:	68 ad 8d 10 f0       	push   $0xf0108dad
f0106355:	53                   	push   %ebx
f0106356:	e8 b5 fd ff ff       	call   f0106110 <memcmp>
f010635b:	83 c4 10             	add    $0x10,%esp
f010635e:	85 c0                	test   %eax,%eax
f0106360:	75 10                	jne    f0106372 <mpsearch1+0x7b>
		    sum(mp, sizeof(*mp)) == 0)
f0106362:	ba 10 00 00 00       	mov    $0x10,%edx
f0106367:	89 d8                	mov    %ebx,%eax
f0106369:	e8 5e ff ff ff       	call   f01062cc <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010636e:	84 c0                	test   %al,%al
f0106370:	74 13                	je     f0106385 <mpsearch1+0x8e>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106372:	83 c3 10             	add    $0x10,%ebx
f0106375:	39 de                	cmp    %ebx,%esi
f0106377:	77 d2                	ja     f010634b <mpsearch1+0x54>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106379:	bb 00 00 00 00       	mov    $0x0,%ebx
f010637e:	eb 05                	jmp    f0106385 <mpsearch1+0x8e>
f0106380:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106385:	89 d8                	mov    %ebx,%eax
f0106387:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010638a:	5b                   	pop    %ebx
f010638b:	5e                   	pop    %esi
f010638c:	c9                   	leave  
f010638d:	c3                   	ret    

f010638e <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010638e:	55                   	push   %ebp
f010638f:	89 e5                	mov    %esp,%ebp
f0106391:	57                   	push   %edi
f0106392:	56                   	push   %esi
f0106393:	53                   	push   %ebx
f0106394:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106397:	c7 05 c0 13 22 f0 20 	movl   $0xf0221020,0xf02213c0
f010639e:	10 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01063a1:	83 3d 88 0e 22 f0 00 	cmpl   $0x0,0xf0220e88
f01063a8:	75 16                	jne    f01063c0 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063aa:	68 00 04 00 00       	push   $0x400
f01063af:	68 88 6d 10 f0       	push   $0xf0106d88
f01063b4:	6a 6f                	push   $0x6f
f01063b6:	68 9d 8d 10 f0       	push   $0xf0108d9d
f01063bb:	e8 a8 9c ff ff       	call   f0100068 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01063c0:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01063c7:	85 c0                	test   %eax,%eax
f01063c9:	74 16                	je     f01063e1 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
f01063cb:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01063ce:	ba 00 04 00 00       	mov    $0x400,%edx
f01063d3:	e8 1f ff ff ff       	call   f01062f7 <mpsearch1>
f01063d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01063db:	85 c0                	test   %eax,%eax
f01063dd:	75 3c                	jne    f010641b <mp_init+0x8d>
f01063df:	eb 20                	jmp    f0106401 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01063e1:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01063e8:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01063eb:	2d 00 04 00 00       	sub    $0x400,%eax
f01063f0:	ba 00 04 00 00       	mov    $0x400,%edx
f01063f5:	e8 fd fe ff ff       	call   f01062f7 <mpsearch1>
f01063fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01063fd:	85 c0                	test   %eax,%eax
f01063ff:	75 1a                	jne    f010641b <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106401:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106406:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010640b:	e8 e7 fe ff ff       	call   f01062f7 <mpsearch1>
f0106410:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106413:	85 c0                	test   %eax,%eax
f0106415:	0f 84 3b 02 00 00    	je     f0106656 <mp_init+0x2c8>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010641b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010641e:	8b 70 04             	mov    0x4(%eax),%esi
f0106421:	85 f6                	test   %esi,%esi
f0106423:	74 06                	je     f010642b <mp_init+0x9d>
f0106425:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106429:	74 15                	je     f0106440 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f010642b:	83 ec 0c             	sub    $0xc,%esp
f010642e:	68 10 8c 10 f0       	push   $0xf0108c10
f0106433:	e8 29 da ff ff       	call   f0103e61 <cprintf>
f0106438:	83 c4 10             	add    $0x10,%esp
f010643b:	e9 16 02 00 00       	jmp    f0106656 <mp_init+0x2c8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106440:	89 f0                	mov    %esi,%eax
f0106442:	c1 e8 0c             	shr    $0xc,%eax
f0106445:	3b 05 88 0e 22 f0    	cmp    0xf0220e88,%eax
f010644b:	72 15                	jb     f0106462 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010644d:	56                   	push   %esi
f010644e:	68 88 6d 10 f0       	push   $0xf0106d88
f0106453:	68 90 00 00 00       	push   $0x90
f0106458:	68 9d 8d 10 f0       	push   $0xf0108d9d
f010645d:	e8 06 9c ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f0106462:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106468:	83 ec 04             	sub    $0x4,%esp
f010646b:	6a 04                	push   $0x4
f010646d:	68 b2 8d 10 f0       	push   $0xf0108db2
f0106472:	56                   	push   %esi
f0106473:	e8 98 fc ff ff       	call   f0106110 <memcmp>
f0106478:	83 c4 10             	add    $0x10,%esp
f010647b:	85 c0                	test   %eax,%eax
f010647d:	74 15                	je     f0106494 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010647f:	83 ec 0c             	sub    $0xc,%esp
f0106482:	68 40 8c 10 f0       	push   $0xf0108c40
f0106487:	e8 d5 d9 ff ff       	call   f0103e61 <cprintf>
f010648c:	83 c4 10             	add    $0x10,%esp
f010648f:	e9 c2 01 00 00       	jmp    f0106656 <mp_init+0x2c8>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106494:	66 8b 5e 04          	mov    0x4(%esi),%bx
f0106498:	0f b7 d3             	movzwl %bx,%edx
f010649b:	89 f0                	mov    %esi,%eax
f010649d:	e8 2a fe ff ff       	call   f01062cc <sum>
f01064a2:	84 c0                	test   %al,%al
f01064a4:	74 15                	je     f01064bb <mp_init+0x12d>
		cprintf("SMP: Bad MP configuration checksum\n");
f01064a6:	83 ec 0c             	sub    $0xc,%esp
f01064a9:	68 74 8c 10 f0       	push   $0xf0108c74
f01064ae:	e8 ae d9 ff ff       	call   f0103e61 <cprintf>
f01064b3:	83 c4 10             	add    $0x10,%esp
f01064b6:	e9 9b 01 00 00       	jmp    f0106656 <mp_init+0x2c8>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01064bb:	8a 46 06             	mov    0x6(%esi),%al
f01064be:	3c 01                	cmp    $0x1,%al
f01064c0:	74 1d                	je     f01064df <mp_init+0x151>
f01064c2:	3c 04                	cmp    $0x4,%al
f01064c4:	74 19                	je     f01064df <mp_init+0x151>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01064c6:	83 ec 08             	sub    $0x8,%esp
f01064c9:	0f b6 c0             	movzbl %al,%eax
f01064cc:	50                   	push   %eax
f01064cd:	68 98 8c 10 f0       	push   $0xf0108c98
f01064d2:	e8 8a d9 ff ff       	call   f0103e61 <cprintf>
f01064d7:	83 c4 10             	add    $0x10,%esp
f01064da:	e9 77 01 00 00       	jmp    f0106656 <mp_init+0x2c8>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f01064df:	0f b7 56 28          	movzwl 0x28(%esi),%edx
f01064e3:	0f b7 c3             	movzwl %bx,%eax
f01064e6:	8d 04 06             	lea    (%esi,%eax,1),%eax
f01064e9:	e8 de fd ff ff       	call   f01062cc <sum>
f01064ee:	3a 46 2a             	cmp    0x2a(%esi),%al
f01064f1:	74 15                	je     f0106508 <mp_init+0x17a>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01064f3:	83 ec 0c             	sub    $0xc,%esp
f01064f6:	68 b8 8c 10 f0       	push   $0xf0108cb8
f01064fb:	e8 61 d9 ff ff       	call   f0103e61 <cprintf>
f0106500:	83 c4 10             	add    $0x10,%esp
f0106503:	e9 4e 01 00 00       	jmp    f0106656 <mp_init+0x2c8>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106508:	85 f6                	test   %esi,%esi
f010650a:	0f 84 46 01 00 00    	je     f0106656 <mp_init+0x2c8>
		return;
	ismp = 1;
f0106510:	c7 05 00 10 22 f0 01 	movl   $0x1,0xf0221000
f0106517:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010651a:	8b 46 24             	mov    0x24(%esi),%eax
f010651d:	a3 00 20 26 f0       	mov    %eax,0xf0262000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106522:	66 83 7e 22 00       	cmpw   $0x0,0x22(%esi)
f0106527:	0f 84 ac 00 00 00    	je     f01065d9 <mp_init+0x24b>
f010652d:	8d 5e 2c             	lea    0x2c(%esi),%ebx
f0106530:	bf 00 00 00 00       	mov    $0x0,%edi
		switch (*p) {
f0106535:	8a 03                	mov    (%ebx),%al
f0106537:	84 c0                	test   %al,%al
f0106539:	74 06                	je     f0106541 <mp_init+0x1b3>
f010653b:	3c 04                	cmp    $0x4,%al
f010653d:	77 6b                	ja     f01065aa <mp_init+0x21c>
f010653f:	eb 64                	jmp    f01065a5 <mp_init+0x217>
		case MPPROC:
			proc = (struct mpproc *)p;
f0106541:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f0106543:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f0106547:	74 1d                	je     f0106566 <mp_init+0x1d8>
				bootcpu = &cpus[ncpu];
f0106549:	a1 c4 13 22 f0       	mov    0xf02213c4,%eax
f010654e:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0106555:	29 c1                	sub    %eax,%ecx
f0106557:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f010655a:	8d 04 85 20 10 22 f0 	lea    -0xfddefe0(,%eax,4),%eax
f0106561:	a3 c0 13 22 f0       	mov    %eax,0xf02213c0
			if (ncpu < NCPU) {
f0106566:	a1 c4 13 22 f0       	mov    0xf02213c4,%eax
f010656b:	83 f8 07             	cmp    $0x7,%eax
f010656e:	7f 1b                	jg     f010658b <mp_init+0x1fd>
				cpus[ncpu].cpu_id = ncpu;
f0106570:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106577:	29 c2                	sub    %eax,%edx
f0106579:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010657c:	88 04 95 20 10 22 f0 	mov    %al,-0xfddefe0(,%edx,4)
				ncpu++;
f0106583:	40                   	inc    %eax
f0106584:	a3 c4 13 22 f0       	mov    %eax,0xf02213c4
f0106589:	eb 15                	jmp    f01065a0 <mp_init+0x212>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010658b:	83 ec 08             	sub    $0x8,%esp
f010658e:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0106592:	50                   	push   %eax
f0106593:	68 e8 8c 10 f0       	push   $0xf0108ce8
f0106598:	e8 c4 d8 ff ff       	call   f0103e61 <cprintf>
f010659d:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01065a0:	83 c3 14             	add    $0x14,%ebx
			continue;
f01065a3:	eb 27                	jmp    f01065cc <mp_init+0x23e>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01065a5:	83 c3 08             	add    $0x8,%ebx
			continue;
f01065a8:	eb 22                	jmp    f01065cc <mp_init+0x23e>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01065aa:	83 ec 08             	sub    $0x8,%esp
f01065ad:	0f b6 c0             	movzbl %al,%eax
f01065b0:	50                   	push   %eax
f01065b1:	68 10 8d 10 f0       	push   $0xf0108d10
f01065b6:	e8 a6 d8 ff ff       	call   f0103e61 <cprintf>
			ismp = 0;
f01065bb:	c7 05 00 10 22 f0 00 	movl   $0x0,0xf0221000
f01065c2:	00 00 00 
			i = conf->entry;
f01065c5:	0f b7 7e 22          	movzwl 0x22(%esi),%edi
f01065c9:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01065cc:	47                   	inc    %edi
f01065cd:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f01065d1:	39 f8                	cmp    %edi,%eax
f01065d3:	0f 87 5c ff ff ff    	ja     f0106535 <mp_init+0x1a7>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01065d9:	a1 c0 13 22 f0       	mov    0xf02213c0,%eax
f01065de:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01065e5:	83 3d 00 10 22 f0 00 	cmpl   $0x0,0xf0221000
f01065ec:	75 26                	jne    f0106614 <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01065ee:	c7 05 c4 13 22 f0 01 	movl   $0x1,0xf02213c4
f01065f5:	00 00 00 
		lapicaddr = 0;
f01065f8:	c7 05 00 20 26 f0 00 	movl   $0x0,0xf0262000
f01065ff:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106602:	83 ec 0c             	sub    $0xc,%esp
f0106605:	68 30 8d 10 f0       	push   $0xf0108d30
f010660a:	e8 52 d8 ff ff       	call   f0103e61 <cprintf>
		return;
f010660f:	83 c4 10             	add    $0x10,%esp
f0106612:	eb 42                	jmp    f0106656 <mp_init+0x2c8>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106614:	83 ec 04             	sub    $0x4,%esp
f0106617:	ff 35 c4 13 22 f0    	pushl  0xf02213c4
f010661d:	0f b6 00             	movzbl (%eax),%eax
f0106620:	50                   	push   %eax
f0106621:	68 b7 8d 10 f0       	push   $0xf0108db7
f0106626:	e8 36 d8 ff ff       	call   f0103e61 <cprintf>

	if (mp->imcrp) {
f010662b:	83 c4 10             	add    $0x10,%esp
f010662e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106631:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106635:	74 1f                	je     f0106656 <mp_init+0x2c8>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106637:	83 ec 0c             	sub    $0xc,%esp
f010663a:	68 5c 8d 10 f0       	push   $0xf0108d5c
f010663f:	e8 1d d8 ff ff       	call   f0103e61 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106644:	ba 22 00 00 00       	mov    $0x22,%edx
f0106649:	b0 70                	mov    $0x70,%al
f010664b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010664c:	b2 23                	mov    $0x23,%dl
f010664e:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010664f:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106652:	ee                   	out    %al,(%dx)
f0106653:	83 c4 10             	add    $0x10,%esp
	}
}
f0106656:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106659:	5b                   	pop    %ebx
f010665a:	5e                   	pop    %esi
f010665b:	5f                   	pop    %edi
f010665c:	c9                   	leave  
f010665d:	c3                   	ret    
	...

f0106660 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106660:	55                   	push   %ebp
f0106661:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106663:	c1 e0 02             	shl    $0x2,%eax
f0106666:	03 05 04 20 26 f0    	add    0xf0262004,%eax
f010666c:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010666e:	a1 04 20 26 f0       	mov    0xf0262004,%eax
f0106673:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106676:	c9                   	leave  
f0106677:	c3                   	ret    

f0106678 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106678:	55                   	push   %ebp
f0106679:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010667b:	a1 04 20 26 f0       	mov    0xf0262004,%eax
f0106680:	85 c0                	test   %eax,%eax
f0106682:	74 08                	je     f010668c <cpunum+0x14>
		return lapic[ID] >> 24;
f0106684:	8b 40 20             	mov    0x20(%eax),%eax
f0106687:	c1 e8 18             	shr    $0x18,%eax
f010668a:	eb 05                	jmp    f0106691 <cpunum+0x19>
	return 0;
f010668c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106691:	c9                   	leave  
f0106692:	c3                   	ret    

f0106693 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106693:	55                   	push   %ebp
f0106694:	89 e5                	mov    %esp,%ebp
f0106696:	83 ec 08             	sub    $0x8,%esp
	if (!lapicaddr)
f0106699:	a1 00 20 26 f0       	mov    0xf0262000,%eax
f010669e:	85 c0                	test   %eax,%eax
f01066a0:	0f 84 2a 01 00 00    	je     f01067d0 <lapic_init+0x13d>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01066a6:	83 ec 08             	sub    $0x8,%esp
f01066a9:	68 00 10 00 00       	push   $0x1000
f01066ae:	50                   	push   %eax
f01066af:	e8 62 b2 ff ff       	call   f0101916 <mmio_map_region>
f01066b4:	a3 04 20 26 f0       	mov    %eax,0xf0262004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01066b9:	ba 27 01 00 00       	mov    $0x127,%edx
f01066be:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01066c3:	e8 98 ff ff ff       	call   f0106660 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01066c8:	ba 0b 00 00 00       	mov    $0xb,%edx
f01066cd:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01066d2:	e8 89 ff ff ff       	call   f0106660 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01066d7:	ba 20 00 02 00       	mov    $0x20020,%edx
f01066dc:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01066e1:	e8 7a ff ff ff       	call   f0106660 <lapicw>
	lapicw(TICR, 10000000); 
f01066e6:	ba 80 96 98 00       	mov    $0x989680,%edx
f01066eb:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01066f0:	e8 6b ff ff ff       	call   f0106660 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01066f5:	e8 7e ff ff ff       	call   f0106678 <cpunum>
f01066fa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106701:	29 c2                	sub    %eax,%edx
f0106703:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106706:	8d 04 85 20 10 22 f0 	lea    -0xfddefe0(,%eax,4),%eax
f010670d:	83 c4 10             	add    $0x10,%esp
f0106710:	39 05 c0 13 22 f0    	cmp    %eax,0xf02213c0
f0106716:	74 0f                	je     f0106727 <lapic_init+0x94>
		lapicw(LINT0, MASKED);
f0106718:	ba 00 00 01 00       	mov    $0x10000,%edx
f010671d:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106722:	e8 39 ff ff ff       	call   f0106660 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106727:	ba 00 00 01 00       	mov    $0x10000,%edx
f010672c:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106731:	e8 2a ff ff ff       	call   f0106660 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106736:	a1 04 20 26 f0       	mov    0xf0262004,%eax
f010673b:	8b 40 30             	mov    0x30(%eax),%eax
f010673e:	c1 e8 10             	shr    $0x10,%eax
f0106741:	3c 03                	cmp    $0x3,%al
f0106743:	76 0f                	jbe    f0106754 <lapic_init+0xc1>
		lapicw(PCINT, MASKED);
f0106745:	ba 00 00 01 00       	mov    $0x10000,%edx
f010674a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010674f:	e8 0c ff ff ff       	call   f0106660 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106754:	ba 33 00 00 00       	mov    $0x33,%edx
f0106759:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010675e:	e8 fd fe ff ff       	call   f0106660 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106763:	ba 00 00 00 00       	mov    $0x0,%edx
f0106768:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010676d:	e8 ee fe ff ff       	call   f0106660 <lapicw>
	lapicw(ESR, 0);
f0106772:	ba 00 00 00 00       	mov    $0x0,%edx
f0106777:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010677c:	e8 df fe ff ff       	call   f0106660 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106781:	ba 00 00 00 00       	mov    $0x0,%edx
f0106786:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010678b:	e8 d0 fe ff ff       	call   f0106660 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106790:	ba 00 00 00 00       	mov    $0x0,%edx
f0106795:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010679a:	e8 c1 fe ff ff       	call   f0106660 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010679f:	ba 00 85 08 00       	mov    $0x88500,%edx
f01067a4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067a9:	e8 b2 fe ff ff       	call   f0106660 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01067ae:	8b 15 04 20 26 f0    	mov    0xf0262004,%edx
f01067b4:	81 c2 00 03 00 00    	add    $0x300,%edx
f01067ba:	8b 02                	mov    (%edx),%eax
f01067bc:	f6 c4 10             	test   $0x10,%ah
f01067bf:	75 f9                	jne    f01067ba <lapic_init+0x127>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01067c1:	ba 00 00 00 00       	mov    $0x0,%edx
f01067c6:	b8 20 00 00 00       	mov    $0x20,%eax
f01067cb:	e8 90 fe ff ff       	call   f0106660 <lapicw>
}
f01067d0:	c9                   	leave  
f01067d1:	c3                   	ret    

f01067d2 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01067d2:	55                   	push   %ebp
f01067d3:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01067d5:	83 3d 04 20 26 f0 00 	cmpl   $0x0,0xf0262004
f01067dc:	74 0f                	je     f01067ed <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f01067de:	ba 00 00 00 00       	mov    $0x0,%edx
f01067e3:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01067e8:	e8 73 fe ff ff       	call   f0106660 <lapicw>
}
f01067ed:	c9                   	leave  
f01067ee:	c3                   	ret    

f01067ef <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01067ef:	55                   	push   %ebp
f01067f0:	89 e5                	mov    %esp,%ebp
f01067f2:	56                   	push   %esi
f01067f3:	53                   	push   %ebx
f01067f4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01067f7:	8a 5d 08             	mov    0x8(%ebp),%bl
f01067fa:	ba 70 00 00 00       	mov    $0x70,%edx
f01067ff:	b0 0f                	mov    $0xf,%al
f0106801:	ee                   	out    %al,(%dx)
f0106802:	b2 71                	mov    $0x71,%dl
f0106804:	b0 0a                	mov    $0xa,%al
f0106806:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106807:	83 3d 88 0e 22 f0 00 	cmpl   $0x0,0xf0220e88
f010680e:	75 19                	jne    f0106829 <lapic_startap+0x3a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106810:	68 67 04 00 00       	push   $0x467
f0106815:	68 88 6d 10 f0       	push   $0xf0106d88
f010681a:	68 98 00 00 00       	push   $0x98
f010681f:	68 d4 8d 10 f0       	push   $0xf0108dd4
f0106824:	e8 3f 98 ff ff       	call   f0100068 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106829:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106830:	00 00 
	wrv[1] = addr >> 4;
f0106832:	89 f0                	mov    %esi,%eax
f0106834:	c1 e8 04             	shr    $0x4,%eax
f0106837:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010683d:	c1 e3 18             	shl    $0x18,%ebx
f0106840:	89 da                	mov    %ebx,%edx
f0106842:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106847:	e8 14 fe ff ff       	call   f0106660 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010684c:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106851:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106856:	e8 05 fe ff ff       	call   f0106660 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010685b:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106860:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106865:	e8 f6 fd ff ff       	call   f0106660 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010686a:	c1 ee 0c             	shr    $0xc,%esi
f010686d:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106873:	89 da                	mov    %ebx,%edx
f0106875:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010687a:	e8 e1 fd ff ff       	call   f0106660 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010687f:	89 f2                	mov    %esi,%edx
f0106881:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106886:	e8 d5 fd ff ff       	call   f0106660 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010688b:	89 da                	mov    %ebx,%edx
f010688d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106892:	e8 c9 fd ff ff       	call   f0106660 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106897:	89 f2                	mov    %esi,%edx
f0106899:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010689e:	e8 bd fd ff ff       	call   f0106660 <lapicw>
		microdelay(200);
	}
}
f01068a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01068a6:	5b                   	pop    %ebx
f01068a7:	5e                   	pop    %esi
f01068a8:	c9                   	leave  
f01068a9:	c3                   	ret    

f01068aa <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01068aa:	55                   	push   %ebp
f01068ab:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01068ad:	8b 55 08             	mov    0x8(%ebp),%edx
f01068b0:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01068b6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01068bb:	e8 a0 fd ff ff       	call   f0106660 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01068c0:	8b 15 04 20 26 f0    	mov    0xf0262004,%edx
f01068c6:	81 c2 00 03 00 00    	add    $0x300,%edx
f01068cc:	8b 02                	mov    (%edx),%eax
f01068ce:	f6 c4 10             	test   $0x10,%ah
f01068d1:	75 f9                	jne    f01068cc <lapic_ipi+0x22>
		;
}
f01068d3:	c9                   	leave  
f01068d4:	c3                   	ret    
f01068d5:	00 00                	add    %al,(%eax)
	...

f01068d8 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01068d8:	55                   	push   %ebp
f01068d9:	89 e5                	mov    %esp,%ebp
f01068db:	53                   	push   %ebx
f01068dc:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01068df:	83 38 00             	cmpl   $0x0,(%eax)
f01068e2:	74 25                	je     f0106909 <holding+0x31>
f01068e4:	8b 58 08             	mov    0x8(%eax),%ebx
f01068e7:	e8 8c fd ff ff       	call   f0106678 <cpunum>
f01068ec:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01068f3:	29 c2                	sub    %eax,%edx
f01068f5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01068f8:	8d 04 85 20 10 22 f0 	lea    -0xfddefe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f01068ff:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106901:	0f 94 c0             	sete   %al
f0106904:	0f b6 c0             	movzbl %al,%eax
f0106907:	eb 05                	jmp    f010690e <holding+0x36>
f0106909:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010690e:	83 c4 04             	add    $0x4,%esp
f0106911:	5b                   	pop    %ebx
f0106912:	c9                   	leave  
f0106913:	c3                   	ret    

f0106914 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106914:	55                   	push   %ebp
f0106915:	89 e5                	mov    %esp,%ebp
f0106917:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010691a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106920:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106923:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106926:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010692d:	c9                   	leave  
f010692e:	c3                   	ret    

f010692f <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010692f:	55                   	push   %ebp
f0106930:	89 e5                	mov    %esp,%ebp
f0106932:	53                   	push   %ebx
f0106933:	83 ec 04             	sub    $0x4,%esp
f0106936:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106939:	89 d8                	mov    %ebx,%eax
f010693b:	e8 98 ff ff ff       	call   f01068d8 <holding>
f0106940:	85 c0                	test   %eax,%eax
f0106942:	75 0d                	jne    f0106951 <spin_lock+0x22>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106944:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106946:	b0 01                	mov    $0x1,%al
f0106948:	f0 87 03             	lock xchg %eax,(%ebx)
f010694b:	85 c0                	test   %eax,%eax
f010694d:	75 20                	jne    f010696f <spin_lock+0x40>
f010694f:	eb 2e                	jmp    f010697f <spin_lock+0x50>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106951:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106954:	e8 1f fd ff ff       	call   f0106678 <cpunum>
f0106959:	83 ec 0c             	sub    $0xc,%esp
f010695c:	53                   	push   %ebx
f010695d:	50                   	push   %eax
f010695e:	68 e4 8d 10 f0       	push   $0xf0108de4
f0106963:	6a 41                	push   $0x41
f0106965:	68 48 8e 10 f0       	push   $0xf0108e48
f010696a:	e8 f9 96 ff ff       	call   f0100068 <_panic>
f010696f:	b9 01 00 00 00       	mov    $0x1,%ecx

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106974:	f3 90                	pause  
f0106976:	89 c8                	mov    %ecx,%eax
f0106978:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010697b:	85 c0                	test   %eax,%eax
f010697d:	75 f5                	jne    f0106974 <spin_lock+0x45>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010697f:	e8 f4 fc ff ff       	call   f0106678 <cpunum>
f0106984:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010698b:	29 c2                	sub    %eax,%edx
f010698d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106990:	8d 04 85 20 10 22 f0 	lea    -0xfddefe0(,%eax,4),%eax
f0106997:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f010699a:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010699d:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010699f:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01069a4:	77 30                	ja     f01069d6 <spin_lock+0xa7>
f01069a6:	eb 27                	jmp    f01069cf <spin_lock+0xa0>
f01069a8:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01069ae:	76 10                	jbe    f01069c0 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01069b0:	8b 5a 04             	mov    0x4(%edx),%ebx
f01069b3:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01069b6:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01069b8:	40                   	inc    %eax
f01069b9:	83 f8 0a             	cmp    $0xa,%eax
f01069bc:	75 ea                	jne    f01069a8 <spin_lock+0x79>
f01069be:	eb 25                	jmp    f01069e5 <spin_lock+0xb6>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01069c0:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01069c7:	40                   	inc    %eax
f01069c8:	83 f8 09             	cmp    $0x9,%eax
f01069cb:	7e f3                	jle    f01069c0 <spin_lock+0x91>
f01069cd:	eb 16                	jmp    f01069e5 <spin_lock+0xb6>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01069cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01069d4:	eb ea                	jmp    f01069c0 <spin_lock+0x91>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01069d6:	8b 50 04             	mov    0x4(%eax),%edx
f01069d9:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01069dc:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01069de:	b8 01 00 00 00       	mov    $0x1,%eax
f01069e3:	eb c3                	jmp    f01069a8 <spin_lock+0x79>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01069e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01069e8:	c9                   	leave  
f01069e9:	c3                   	ret    

f01069ea <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01069ea:	55                   	push   %ebp
f01069eb:	89 e5                	mov    %esp,%ebp
f01069ed:	57                   	push   %edi
f01069ee:	56                   	push   %esi
f01069ef:	53                   	push   %ebx
f01069f0:	83 ec 4c             	sub    $0x4c,%esp
f01069f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01069f6:	89 d8                	mov    %ebx,%eax
f01069f8:	e8 db fe ff ff       	call   f01068d8 <holding>
f01069fd:	85 c0                	test   %eax,%eax
f01069ff:	0f 85 c0 00 00 00    	jne    f0106ac5 <spin_unlock+0xdb>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106a05:	83 ec 04             	sub    $0x4,%esp
f0106a08:	6a 28                	push   $0x28
f0106a0a:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106a0d:	50                   	push   %eax
f0106a0e:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0106a11:	50                   	push   %eax
f0106a12:	e8 7c f6 ff ff       	call   f0106093 <memmove>
			
		cprintf("%u\n", lk->cpu->cpu_id);
f0106a17:	83 c4 08             	add    $0x8,%esp
f0106a1a:	8b 43 08             	mov    0x8(%ebx),%eax
f0106a1d:	0f b6 00             	movzbl (%eax),%eax
f0106a20:	50                   	push   %eax
f0106a21:	68 78 70 10 f0       	push   $0xf0107078
f0106a26:	e8 36 d4 ff ff       	call   f0103e61 <cprintf>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106a2b:	8b 43 08             	mov    0x8(%ebx),%eax
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
			
		cprintf("%u\n", lk->cpu->cpu_id);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106a2e:	0f b6 30             	movzbl (%eax),%esi
f0106a31:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106a34:	e8 3f fc ff ff       	call   f0106678 <cpunum>
f0106a39:	56                   	push   %esi
f0106a3a:	53                   	push   %ebx
f0106a3b:	50                   	push   %eax
f0106a3c:	68 10 8e 10 f0       	push   $0xf0108e10
f0106a41:	e8 1b d4 ff ff       	call   f0103e61 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
f0106a46:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0106a49:	83 c4 20             	add    $0x20,%esp
f0106a4c:	85 c0                	test   %eax,%eax
f0106a4e:	74 61                	je     f0106ab1 <spin_unlock+0xc7>
f0106a50:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106a53:	8d 7d cc             	lea    -0x34(%ebp),%edi
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106a56:	8d 75 d0             	lea    -0x30(%ebp),%esi
f0106a59:	83 ec 08             	sub    $0x8,%esp
f0106a5c:	56                   	push   %esi
f0106a5d:	50                   	push   %eax
f0106a5e:	e8 2e eb ff ff       	call   f0105591 <debuginfo_eip>
f0106a63:	83 c4 10             	add    $0x10,%esp
f0106a66:	85 c0                	test   %eax,%eax
f0106a68:	78 27                	js     f0106a91 <spin_unlock+0xa7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106a6a:	8b 03                	mov    (%ebx),%eax
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106a6c:	83 ec 04             	sub    $0x4,%esp
f0106a6f:	89 c2                	mov    %eax,%edx
f0106a71:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106a74:	52                   	push   %edx
f0106a75:	ff 75 d8             	pushl  -0x28(%ebp)
f0106a78:	ff 75 dc             	pushl  -0x24(%ebp)
f0106a7b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0106a7e:	ff 75 d0             	pushl  -0x30(%ebp)
f0106a81:	50                   	push   %eax
f0106a82:	68 58 8e 10 f0       	push   $0xf0108e58
f0106a87:	e8 d5 d3 ff ff       	call   f0103e61 <cprintf>
f0106a8c:	83 c4 20             	add    $0x20,%esp
f0106a8f:	eb 12                	jmp    f0106aa3 <spin_unlock+0xb9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106a91:	83 ec 08             	sub    $0x8,%esp
f0106a94:	ff 33                	pushl  (%ebx)
f0106a96:	68 6f 8e 10 f0       	push   $0xf0108e6f
f0106a9b:	e8 c1 d3 ff ff       	call   f0103e61 <cprintf>
f0106aa0:	83 c4 10             	add    $0x10,%esp
			
		cprintf("%u\n", lk->cpu->cpu_id);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
f0106aa3:	39 fb                	cmp    %edi,%ebx
f0106aa5:	74 0a                	je     f0106ab1 <spin_unlock+0xc7>
f0106aa7:	8b 43 04             	mov    0x4(%ebx),%eax
f0106aaa:	83 c3 04             	add    $0x4,%ebx
f0106aad:	85 c0                	test   %eax,%eax
f0106aaf:	75 a8                	jne    f0106a59 <spin_unlock+0x6f>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106ab1:	83 ec 04             	sub    $0x4,%esp
f0106ab4:	68 77 8e 10 f0       	push   $0xf0108e77
f0106ab9:	6a 6a                	push   $0x6a
f0106abb:	68 48 8e 10 f0       	push   $0xf0108e48
f0106ac0:	e8 a3 95 ff ff       	call   f0100068 <_panic>
	}
	lk->pcs[0] = 0;
f0106ac5:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106acc:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106ad3:	b8 00 00 00 00       	mov    $0x0,%eax
f0106ad8:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106adb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106ade:	5b                   	pop    %ebx
f0106adf:	5e                   	pop    %esi
f0106ae0:	5f                   	pop    %edi
f0106ae1:	c9                   	leave  
f0106ae2:	c3                   	ret    
	...

f0106ae4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0106ae4:	55                   	push   %ebp
f0106ae5:	89 e5                	mov    %esp,%ebp
f0106ae7:	57                   	push   %edi
f0106ae8:	56                   	push   %esi
f0106ae9:	83 ec 10             	sub    $0x10,%esp
f0106aec:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106aef:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0106af2:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0106af5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0106af8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0106afb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106afe:	85 c0                	test   %eax,%eax
f0106b00:	75 2e                	jne    f0106b30 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0106b02:	39 f1                	cmp    %esi,%ecx
f0106b04:	77 5a                	ja     f0106b60 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0106b06:	85 c9                	test   %ecx,%ecx
f0106b08:	75 0b                	jne    f0106b15 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106b0a:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b0f:	31 d2                	xor    %edx,%edx
f0106b11:	f7 f1                	div    %ecx
f0106b13:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0106b15:	31 d2                	xor    %edx,%edx
f0106b17:	89 f0                	mov    %esi,%eax
f0106b19:	f7 f1                	div    %ecx
f0106b1b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106b1d:	89 f8                	mov    %edi,%eax
f0106b1f:	f7 f1                	div    %ecx
f0106b21:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106b23:	89 f8                	mov    %edi,%eax
f0106b25:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106b27:	83 c4 10             	add    $0x10,%esp
f0106b2a:	5e                   	pop    %esi
f0106b2b:	5f                   	pop    %edi
f0106b2c:	c9                   	leave  
f0106b2d:	c3                   	ret    
f0106b2e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106b30:	39 f0                	cmp    %esi,%eax
f0106b32:	77 1c                	ja     f0106b50 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106b34:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f0106b37:	83 f7 1f             	xor    $0x1f,%edi
f0106b3a:	75 3c                	jne    f0106b78 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106b3c:	39 f0                	cmp    %esi,%eax
f0106b3e:	0f 82 90 00 00 00    	jb     f0106bd4 <__udivdi3+0xf0>
f0106b44:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106b47:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0106b4a:	0f 86 84 00 00 00    	jbe    f0106bd4 <__udivdi3+0xf0>
f0106b50:	31 f6                	xor    %esi,%esi
f0106b52:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106b54:	89 f8                	mov    %edi,%eax
f0106b56:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106b58:	83 c4 10             	add    $0x10,%esp
f0106b5b:	5e                   	pop    %esi
f0106b5c:	5f                   	pop    %edi
f0106b5d:	c9                   	leave  
f0106b5e:	c3                   	ret    
f0106b5f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106b60:	89 f2                	mov    %esi,%edx
f0106b62:	89 f8                	mov    %edi,%eax
f0106b64:	f7 f1                	div    %ecx
f0106b66:	89 c7                	mov    %eax,%edi
f0106b68:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106b6a:	89 f8                	mov    %edi,%eax
f0106b6c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106b6e:	83 c4 10             	add    $0x10,%esp
f0106b71:	5e                   	pop    %esi
f0106b72:	5f                   	pop    %edi
f0106b73:	c9                   	leave  
f0106b74:	c3                   	ret    
f0106b75:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106b78:	89 f9                	mov    %edi,%ecx
f0106b7a:	d3 e0                	shl    %cl,%eax
f0106b7c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0106b7f:	b8 20 00 00 00       	mov    $0x20,%eax
f0106b84:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0106b86:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106b89:	88 c1                	mov    %al,%cl
f0106b8b:	d3 ea                	shr    %cl,%edx
f0106b8d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0106b90:	09 ca                	or     %ecx,%edx
f0106b92:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0106b95:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106b98:	89 f9                	mov    %edi,%ecx
f0106b9a:	d3 e2                	shl    %cl,%edx
f0106b9c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0106b9f:	89 f2                	mov    %esi,%edx
f0106ba1:	88 c1                	mov    %al,%cl
f0106ba3:	d3 ea                	shr    %cl,%edx
f0106ba5:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0106ba8:	89 f2                	mov    %esi,%edx
f0106baa:	89 f9                	mov    %edi,%ecx
f0106bac:	d3 e2                	shl    %cl,%edx
f0106bae:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0106bb1:	88 c1                	mov    %al,%cl
f0106bb3:	d3 ee                	shr    %cl,%esi
f0106bb5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106bb7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0106bba:	89 f0                	mov    %esi,%eax
f0106bbc:	89 ca                	mov    %ecx,%edx
f0106bbe:	f7 75 ec             	divl   -0x14(%ebp)
f0106bc1:	89 d1                	mov    %edx,%ecx
f0106bc3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0106bc5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106bc8:	39 d1                	cmp    %edx,%ecx
f0106bca:	72 28                	jb     f0106bf4 <__udivdi3+0x110>
f0106bcc:	74 1a                	je     f0106be8 <__udivdi3+0x104>
f0106bce:	89 f7                	mov    %esi,%edi
f0106bd0:	31 f6                	xor    %esi,%esi
f0106bd2:	eb 80                	jmp    f0106b54 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106bd4:	31 f6                	xor    %esi,%esi
f0106bd6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106bdb:	89 f8                	mov    %edi,%eax
f0106bdd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106bdf:	83 c4 10             	add    $0x10,%esp
f0106be2:	5e                   	pop    %esi
f0106be3:	5f                   	pop    %edi
f0106be4:	c9                   	leave  
f0106be5:	c3                   	ret    
f0106be6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0106be8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106beb:	89 f9                	mov    %edi,%ecx
f0106bed:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106bef:	39 c2                	cmp    %eax,%edx
f0106bf1:	73 db                	jae    f0106bce <__udivdi3+0xea>
f0106bf3:	90                   	nop
		{
		  q0--;
f0106bf4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106bf7:	31 f6                	xor    %esi,%esi
f0106bf9:	e9 56 ff ff ff       	jmp    f0106b54 <__udivdi3+0x70>
	...

f0106c00 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0106c00:	55                   	push   %ebp
f0106c01:	89 e5                	mov    %esp,%ebp
f0106c03:	57                   	push   %edi
f0106c04:	56                   	push   %esi
f0106c05:	83 ec 20             	sub    $0x20,%esp
f0106c08:	8b 45 08             	mov    0x8(%ebp),%eax
f0106c0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0106c0e:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106c11:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0106c14:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0106c17:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0106c1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0106c1d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106c1f:	85 ff                	test   %edi,%edi
f0106c21:	75 15                	jne    f0106c38 <__umoddi3+0x38>
    {
      if (d0 > n1)
f0106c23:	39 f1                	cmp    %esi,%ecx
f0106c25:	0f 86 99 00 00 00    	jbe    f0106cc4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106c2b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0106c2d:	89 d0                	mov    %edx,%eax
f0106c2f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106c31:	83 c4 20             	add    $0x20,%esp
f0106c34:	5e                   	pop    %esi
f0106c35:	5f                   	pop    %edi
f0106c36:	c9                   	leave  
f0106c37:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106c38:	39 f7                	cmp    %esi,%edi
f0106c3a:	0f 87 a4 00 00 00    	ja     f0106ce4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106c40:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0106c43:	83 f0 1f             	xor    $0x1f,%eax
f0106c46:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106c49:	0f 84 a1 00 00 00    	je     f0106cf0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106c4f:	89 f8                	mov    %edi,%eax
f0106c51:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0106c54:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0106c56:	bf 20 00 00 00       	mov    $0x20,%edi
f0106c5b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0106c5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106c61:	89 f9                	mov    %edi,%ecx
f0106c63:	d3 ea                	shr    %cl,%edx
f0106c65:	09 c2                	or     %eax,%edx
f0106c67:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0106c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106c6d:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0106c70:	d3 e0                	shl    %cl,%eax
f0106c72:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106c75:	89 f2                	mov    %esi,%edx
f0106c77:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0106c79:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106c7c:	d3 e0                	shl    %cl,%eax
f0106c7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106c81:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106c84:	89 f9                	mov    %edi,%ecx
f0106c86:	d3 e8                	shr    %cl,%eax
f0106c88:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0106c8a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106c8c:	89 f2                	mov    %esi,%edx
f0106c8e:	f7 75 f0             	divl   -0x10(%ebp)
f0106c91:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0106c93:	f7 65 f4             	mull   -0xc(%ebp)
f0106c96:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0106c99:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106c9b:	39 d6                	cmp    %edx,%esi
f0106c9d:	72 71                	jb     f0106d10 <__umoddi3+0x110>
f0106c9f:	74 7f                	je     f0106d20 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0106ca1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106ca4:	29 c8                	sub    %ecx,%eax
f0106ca6:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0106ca8:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0106cab:	d3 e8                	shr    %cl,%eax
f0106cad:	89 f2                	mov    %esi,%edx
f0106caf:	89 f9                	mov    %edi,%ecx
f0106cb1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0106cb3:	09 d0                	or     %edx,%eax
f0106cb5:	89 f2                	mov    %esi,%edx
f0106cb7:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0106cba:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106cbc:	83 c4 20             	add    $0x20,%esp
f0106cbf:	5e                   	pop    %esi
f0106cc0:	5f                   	pop    %edi
f0106cc1:	c9                   	leave  
f0106cc2:	c3                   	ret    
f0106cc3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0106cc4:	85 c9                	test   %ecx,%ecx
f0106cc6:	75 0b                	jne    f0106cd3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106cc8:	b8 01 00 00 00       	mov    $0x1,%eax
f0106ccd:	31 d2                	xor    %edx,%edx
f0106ccf:	f7 f1                	div    %ecx
f0106cd1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0106cd3:	89 f0                	mov    %esi,%eax
f0106cd5:	31 d2                	xor    %edx,%edx
f0106cd7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106cdc:	f7 f1                	div    %ecx
f0106cde:	e9 4a ff ff ff       	jmp    f0106c2d <__umoddi3+0x2d>
f0106ce3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0106ce4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106ce6:	83 c4 20             	add    $0x20,%esp
f0106ce9:	5e                   	pop    %esi
f0106cea:	5f                   	pop    %edi
f0106ceb:	c9                   	leave  
f0106cec:	c3                   	ret    
f0106ced:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106cf0:	39 f7                	cmp    %esi,%edi
f0106cf2:	72 05                	jb     f0106cf9 <__umoddi3+0xf9>
f0106cf4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0106cf7:	77 0c                	ja     f0106d05 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106cf9:	89 f2                	mov    %esi,%edx
f0106cfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106cfe:	29 c8                	sub    %ecx,%eax
f0106d00:	19 fa                	sbb    %edi,%edx
f0106d02:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0106d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106d08:	83 c4 20             	add    $0x20,%esp
f0106d0b:	5e                   	pop    %esi
f0106d0c:	5f                   	pop    %edi
f0106d0d:	c9                   	leave  
f0106d0e:	c3                   	ret    
f0106d0f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106d10:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106d13:	89 c1                	mov    %eax,%ecx
f0106d15:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0106d18:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0106d1b:	eb 84                	jmp    f0106ca1 <__umoddi3+0xa1>
f0106d1d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106d20:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0106d23:	72 eb                	jb     f0106d10 <__umoddi3+0x110>
f0106d25:	89 f2                	mov    %esi,%edx
f0106d27:	e9 75 ff ff ff       	jmp    f0106ca1 <__umoddi3+0xa1>
