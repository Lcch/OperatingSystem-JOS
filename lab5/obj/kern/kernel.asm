
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
f0100070:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f0100077:	75 3a                	jne    f01000b3 <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100079:	89 35 80 1e 21 f0    	mov    %esi,0xf0211e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010007f:	fa                   	cli    
f0100080:	fc                   	cld    

	va_start(ap, fmt);
f0100081:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f0100084:	e8 7f 62 00 00       	call   f0106308 <cpunum>
f0100089:	ff 75 0c             	pushl  0xc(%ebp)
f010008c:	ff 75 08             	pushl  0x8(%ebp)
f010008f:	50                   	push   %eax
f0100090:	68 c0 69 10 f0       	push   $0xf01069c0
f0100095:	e8 7b 3c 00 00       	call   f0103d15 <cprintf>
	vcprintf(fmt, ap);
f010009a:	83 c4 08             	add    $0x8,%esp
f010009d:	53                   	push   %ebx
f010009e:	56                   	push   %esi
f010009f:	e8 4b 3c 00 00       	call   f0103cef <vcprintf>
	cprintf("\n");
f01000a4:	c7 04 24 2f 6d 10 f0 	movl   $0xf0106d2f,(%esp)
f01000ab:	e8 65 3c 00 00       	call   f0103d15 <cprintf>
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
f01000c8:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000d2:	77 12                	ja     f01000e6 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000d4:	50                   	push   %eax
f01000d5:	68 e4 69 10 f0       	push   $0xf01069e4
f01000da:	6a 7f                	push   $0x7f
f01000dc:	68 2b 6a 10 f0       	push   $0xf0106a2b
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
f01000ee:	e8 15 62 00 00       	call   f0106308 <cpunum>
f01000f3:	83 ec 08             	sub    $0x8,%esp
f01000f6:	50                   	push   %eax
f01000f7:	68 37 6a 10 f0       	push   $0xf0106a37
f01000fc:	e8 14 3c 00 00       	call   f0103d15 <cprintf>

	lapic_init();
f0100101:	e8 1d 62 00 00       	call   f0106323 <lapic_init>
	env_init_percpu();
f0100106:	e8 fd 33 00 00       	call   f0103508 <env_init_percpu>
	trap_init_percpu();
f010010b:	e8 1c 3c 00 00       	call   f0103d2c <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100110:	e8 f3 61 00 00       	call   f0106308 <cpunum>
f0100115:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010011c:	29 c2                	sub    %eax,%edx
f010011e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100121:	8d 14 85 20 20 21 f0 	lea    -0xfdedfe0(,%eax,4),%edx
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
f0100138:	e8 82 64 00 00       	call   f01065bf <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f010013d:	e8 99 46 00 00       	call   f01047db <sched_yield>

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
f0100149:	b8 08 30 25 f0       	mov    $0xf0253008,%eax
f010014e:	2d 18 04 21 f0       	sub    $0xf0210418,%eax
f0100153:	50                   	push   %eax
f0100154:	6a 00                	push   $0x0
f0100156:	68 18 04 21 f0       	push   $0xf0210418
f010015b:	e8 79 5b 00 00       	call   f0105cd9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100160:	e8 52 05 00 00       	call   f01006b7 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100165:	83 c4 08             	add    $0x8,%esp
f0100168:	68 ac 1a 00 00       	push   $0x1aac
f010016d:	68 4d 6a 10 f0       	push   $0xf0106a4d
f0100172:	e8 9e 3b 00 00       	call   f0103d15 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100177:	e8 e1 17 00 00       	call   f010195d <mem_init>

	// MSRs init:
	msrs_init();
f010017c:	e8 bf fe ff ff       	call   f0100040 <msrs_init>

    // Lab 3 user environment initialization functions
	env_init();
f0100181:	e8 ac 33 00 00       	call   f0103532 <env_init>
    trap_init();
f0100186:	e8 a6 3c 00 00       	call   f0103e31 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010018b:	e8 8e 5e 00 00       	call   f010601e <mp_init>
	lapic_init();
f0100190:	e8 8e 61 00 00       	call   f0106323 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100195:	e8 dc 3a 00 00       	call   f0103c76 <pic_init>
f010019a:	c7 04 24 60 94 12 f0 	movl   $0xf0129460,(%esp)
f01001a1:	e8 19 64 00 00       	call   f01065bf <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001a6:	83 c4 10             	add    $0x10,%esp
f01001a9:	83 3d 88 1e 21 f0 07 	cmpl   $0x7,0xf0211e88
f01001b0:	77 16                	ja     f01001c8 <i386_init+0x86>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001b2:	68 00 70 00 00       	push   $0x7000
f01001b7:	68 08 6a 10 f0       	push   $0xf0106a08
f01001bc:	6a 68                	push   $0x68
f01001be:	68 2b 6a 10 f0       	push   $0xf0106a2b
f01001c3:	e8 a0 fe ff ff       	call   f0100068 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c8:	83 ec 04             	sub    $0x4,%esp
f01001cb:	b8 5a 5f 10 f0       	mov    $0xf0105f5a,%eax
f01001d0:	2d e0 5e 10 f0       	sub    $0xf0105ee0,%eax
f01001d5:	50                   	push   %eax
f01001d6:	68 e0 5e 10 f0       	push   $0xf0105ee0
f01001db:	68 00 70 00 f0       	push   $0xf0007000
f01001e0:	e8 3e 5b 00 00       	call   f0105d23 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001e5:	a1 c4 23 21 f0       	mov    0xf02123c4,%eax
f01001ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001f1:	29 c2                	sub    %eax,%edx
f01001f3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001f6:	8d 04 85 20 20 21 f0 	lea    -0xfdedfe0(,%eax,4),%eax
f01001fd:	83 c4 10             	add    $0x10,%esp
f0100200:	3d 20 20 21 f0       	cmp    $0xf0212020,%eax
f0100205:	0f 86 95 00 00 00    	jbe    f01002a0 <i386_init+0x15e>
f010020b:	bb 20 20 21 f0       	mov    $0xf0212020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100210:	e8 f3 60 00 00       	call   f0106308 <cpunum>
f0100215:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010021c:	29 c2                	sub    %eax,%edx
f010021e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100221:	8d 04 85 20 20 21 f0 	lea    -0xfdedfe0(,%eax,4),%eax
f0100228:	39 c3                	cmp    %eax,%ebx
f010022a:	74 51                	je     f010027d <i386_init+0x13b>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010022c:	89 d8                	mov    %ebx,%eax
f010022e:	2d 20 20 21 f0       	sub    $0xf0212020,%eax
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
f0100257:	05 00 30 21 f0       	add    $0xf0213000,%eax
f010025c:	a3 84 1e 21 f0       	mov    %eax,0xf0211e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100261:	83 ec 08             	sub    $0x8,%esp
f0100264:	68 00 70 00 00       	push   $0x7000
f0100269:	0f b6 03             	movzbl (%ebx),%eax
f010026c:	50                   	push   %eax
f010026d:	e8 0d 62 00 00       	call   f010647f <lapic_startap>
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
f0100280:	a1 c4 23 21 f0       	mov    0xf02123c4,%eax
f0100285:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010028c:	29 c2                	sub    %eax,%edx
f010028e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100291:	8d 04 85 20 20 21 f0 	lea    -0xfdedfe0(,%eax,4),%eax
f0100298:	39 c3                	cmp    %eax,%ebx
f010029a:	0f 82 70 ff ff ff    	jb     f0100210 <i386_init+0xce>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01002a0:	83 ec 04             	sub    $0x4,%esp
f01002a3:	6a 01                	push   $0x1
f01002a5:	68 27 a3 01 00       	push   $0x1a327
f01002aa:	68 4a c2 1c f0       	push   $0xf01cc24a
f01002af:	e8 57 34 00 00       	call   f010370b <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01002b4:	83 c4 0c             	add    $0xc,%esp
f01002b7:	6a 00                	push   $0x0
f01002b9:	68 96 4f 00 00       	push   $0x4f96
f01002be:	68 af 04 20 f0       	push   $0xf02004af
f01002c3:	e8 43 34 00 00       	call   f010370b <env_create>
	ENV_CREATE(user_spawnhello, ENV_TYPE_USER);
	// ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01002c8:	e8 91 03 00 00       	call   f010065e <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01002cd:	e8 09 45 00 00       	call   f01047db <sched_yield>

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
f01002e2:	68 68 6a 10 f0       	push   $0xf0106a68
f01002e7:	e8 29 3a 00 00       	call   f0103d15 <cprintf>
	vcprintf(fmt, ap);
f01002ec:	83 c4 08             	add    $0x8,%esp
f01002ef:	53                   	push   %ebx
f01002f0:	ff 75 10             	pushl  0x10(%ebp)
f01002f3:	e8 f7 39 00 00       	call   f0103cef <vcprintf>
	cprintf("\n");
f01002f8:	c7 04 24 2f 6d 10 f0 	movl   $0xf0106d2f,(%esp)
f01002ff:	e8 11 3a 00 00       	call   f0103d15 <cprintf>
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
f0100345:	8b 15 24 12 21 f0    	mov    0xf0211224,%edx
f010034b:	88 82 20 10 21 f0    	mov    %al,-0xfdeefe0(%edx)
f0100351:	8d 42 01             	lea    0x1(%edx),%eax
f0100354:	a3 24 12 21 f0       	mov    %eax,0xf0211224
		if (cons.wpos == CONSBUFSIZE)
f0100359:	3d 00 02 00 00       	cmp    $0x200,%eax
f010035e:	75 0a                	jne    f010036a <cons_intr+0x34>
			cons.wpos = 0;
f0100360:	c7 05 24 12 21 f0 00 	movl   $0x0,0xf0211224
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
f01003e3:	a1 00 10 21 f0       	mov    0xf0211000,%eax
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
f0100427:	66 a1 04 10 21 f0    	mov    0xf0211004,%ax
f010042d:	66 85 c0             	test   %ax,%ax
f0100430:	0f 84 e0 00 00 00    	je     f0100516 <cons_putc+0x19f>
			crt_pos--;
f0100436:	48                   	dec    %eax
f0100437:	66 a3 04 10 21 f0    	mov    %ax,0xf0211004
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010043d:	0f b7 c0             	movzwl %ax,%eax
f0100440:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100446:	83 ce 20             	or     $0x20,%esi
f0100449:	8b 15 08 10 21 f0    	mov    0xf0211008,%edx
f010044f:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100453:	eb 78                	jmp    f01004cd <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100455:	66 83 05 04 10 21 f0 	addw   $0x50,0xf0211004
f010045c:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010045d:	66 8b 0d 04 10 21 f0 	mov    0xf0211004,%cx
f0100464:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100469:	89 c8                	mov    %ecx,%eax
f010046b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100470:	66 f7 f3             	div    %bx
f0100473:	66 29 d1             	sub    %dx,%cx
f0100476:	66 89 0d 04 10 21 f0 	mov    %cx,0xf0211004
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
f01004b3:	66 a1 04 10 21 f0    	mov    0xf0211004,%ax
f01004b9:	0f b7 c8             	movzwl %ax,%ecx
f01004bc:	8b 15 08 10 21 f0    	mov    0xf0211008,%edx
f01004c2:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01004c6:	40                   	inc    %eax
f01004c7:	66 a3 04 10 21 f0    	mov    %ax,0xf0211004
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f01004cd:	66 81 3d 04 10 21 f0 	cmpw   $0x7cf,0xf0211004
f01004d4:	cf 07 
f01004d6:	76 3e                	jbe    f0100516 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004d8:	a1 08 10 21 f0       	mov    0xf0211008,%eax
f01004dd:	83 ec 04             	sub    $0x4,%esp
f01004e0:	68 00 0f 00 00       	push   $0xf00
f01004e5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004eb:	52                   	push   %edx
f01004ec:	50                   	push   %eax
f01004ed:	e8 31 58 00 00       	call   f0105d23 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004f2:	8b 15 08 10 21 f0    	mov    0xf0211008,%edx
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
f010050e:	66 83 2d 04 10 21 f0 	subw   $0x50,0xf0211004
f0100515:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100516:	8b 0d 0c 10 21 f0    	mov    0xf021100c,%ecx
f010051c:	b0 0e                	mov    $0xe,%al
f010051e:	89 ca                	mov    %ecx,%edx
f0100520:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100521:	66 8b 35 04 10 21 f0 	mov    0xf0211004,%si
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
f0100564:	83 0d 28 12 21 f0 40 	orl    $0x40,0xf0211228
		return 0;
f010056b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100570:	e9 c7 00 00 00       	jmp    f010063c <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f0100575:	84 c0                	test   %al,%al
f0100577:	79 33                	jns    f01005ac <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100579:	8b 0d 28 12 21 f0    	mov    0xf0211228,%ecx
f010057f:	f6 c1 40             	test   $0x40,%cl
f0100582:	75 05                	jne    f0100589 <kbd_proc_data+0x43>
f0100584:	88 c2                	mov    %al,%dl
f0100586:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100589:	0f b6 d2             	movzbl %dl,%edx
f010058c:	8a 82 c0 6a 10 f0    	mov    -0xfef9540(%edx),%al
f0100592:	83 c8 40             	or     $0x40,%eax
f0100595:	0f b6 c0             	movzbl %al,%eax
f0100598:	f7 d0                	not    %eax
f010059a:	21 c1                	and    %eax,%ecx
f010059c:	89 0d 28 12 21 f0    	mov    %ecx,0xf0211228
		return 0;
f01005a2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005a7:	e9 90 00 00 00       	jmp    f010063c <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f01005ac:	8b 0d 28 12 21 f0    	mov    0xf0211228,%ecx
f01005b2:	f6 c1 40             	test   $0x40,%cl
f01005b5:	74 0e                	je     f01005c5 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01005b7:	88 c2                	mov    %al,%dl
f01005b9:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01005bc:	83 e1 bf             	and    $0xffffffbf,%ecx
f01005bf:	89 0d 28 12 21 f0    	mov    %ecx,0xf0211228
	}

	shift |= shiftcode[data];
f01005c5:	0f b6 d2             	movzbl %dl,%edx
f01005c8:	0f b6 82 c0 6a 10 f0 	movzbl -0xfef9540(%edx),%eax
f01005cf:	0b 05 28 12 21 f0    	or     0xf0211228,%eax
	shift ^= togglecode[data];
f01005d5:	0f b6 8a c0 6b 10 f0 	movzbl -0xfef9440(%edx),%ecx
f01005dc:	31 c8                	xor    %ecx,%eax
f01005de:	a3 28 12 21 f0       	mov    %eax,0xf0211228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005e3:	89 c1                	mov    %eax,%ecx
f01005e5:	83 e1 03             	and    $0x3,%ecx
f01005e8:	8b 0c 8d c0 6c 10 f0 	mov    -0xfef9340(,%ecx,4),%ecx
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
f0100620:	68 82 6a 10 f0       	push   $0xf0106a82
f0100625:	e8 eb 36 00 00       	call   f0103d15 <cprintf>
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
f0100649:	80 3d 10 10 21 f0 00 	cmpb   $0x0,0xf0211010
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
f0100680:	8b 15 20 12 21 f0    	mov    0xf0211220,%edx
f0100686:	3b 15 24 12 21 f0    	cmp    0xf0211224,%edx
f010068c:	74 22                	je     f01006b0 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010068e:	0f b6 82 20 10 21 f0 	movzbl -0xfdeefe0(%edx),%eax
f0100695:	42                   	inc    %edx
f0100696:	89 15 20 12 21 f0    	mov    %edx,0xf0211220
		if (cons.rpos == CONSBUFSIZE)
f010069c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006a2:	75 11                	jne    f01006b5 <cons_getc+0x45>
			cons.rpos = 0;
f01006a4:	c7 05 20 12 21 f0 00 	movl   $0x0,0xf0211220
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
f01006dc:	c7 05 0c 10 21 f0 b4 	movl   $0x3b4,0xf021100c
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
f01006f4:	c7 05 0c 10 21 f0 d4 	movl   $0x3d4,0xf021100c
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
f0100703:	8b 0d 0c 10 21 f0    	mov    0xf021100c,%ecx
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
f0100722:	89 35 08 10 21 f0    	mov    %esi,0xf0211008

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100728:	0f b6 d8             	movzbl %al,%ebx
f010072b:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010072d:	66 89 3d 04 10 21 f0 	mov    %di,0xf0211004

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
f0100749:	e8 ae 34 00 00       	call   f0103bfc <irq_setmask_8259A>
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
f010078a:	a2 10 10 21 f0       	mov    %al,0xf0211010
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
f01007ab:	e8 4c 34 00 00       	call   f0103bfc <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007b0:	83 c4 10             	add    $0x10,%esp
f01007b3:	80 3d 10 10 21 f0 00 	cmpb   $0x0,0xf0211010
f01007ba:	75 10                	jne    f01007cc <cons_init+0x115>
		cprintf("Serial port does not exist!\n");
f01007bc:	83 ec 0c             	sub    $0xc,%esp
f01007bf:	68 8e 6a 10 f0       	push   $0xf0106a8e
f01007c4:	e8 4c 35 00 00       	call   f0103d15 <cprintf>
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
f0100806:	68 d0 6c 10 f0       	push   $0xf0106cd0
f010080b:	e8 05 35 00 00       	call   f0103d15 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100810:	83 c4 08             	add    $0x8,%esp
f0100813:	68 0c 00 10 00       	push   $0x10000c
f0100818:	68 fc 6e 10 f0       	push   $0xf0106efc
f010081d:	e8 f3 34 00 00       	call   f0103d15 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100822:	83 c4 0c             	add    $0xc,%esp
f0100825:	68 0c 00 10 00       	push   $0x10000c
f010082a:	68 0c 00 10 f0       	push   $0xf010000c
f010082f:	68 24 6f 10 f0       	push   $0xf0106f24
f0100834:	e8 dc 34 00 00       	call   f0103d15 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100839:	83 c4 0c             	add    $0xc,%esp
f010083c:	68 bc 69 10 00       	push   $0x1069bc
f0100841:	68 bc 69 10 f0       	push   $0xf01069bc
f0100846:	68 48 6f 10 f0       	push   $0xf0106f48
f010084b:	e8 c5 34 00 00       	call   f0103d15 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100850:	83 c4 0c             	add    $0xc,%esp
f0100853:	68 18 04 21 00       	push   $0x210418
f0100858:	68 18 04 21 f0       	push   $0xf0210418
f010085d:	68 6c 6f 10 f0       	push   $0xf0106f6c
f0100862:	e8 ae 34 00 00       	call   f0103d15 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100867:	83 c4 0c             	add    $0xc,%esp
f010086a:	68 08 30 25 00       	push   $0x253008
f010086f:	68 08 30 25 f0       	push   $0xf0253008
f0100874:	68 90 6f 10 f0       	push   $0xf0106f90
f0100879:	e8 97 34 00 00       	call   f0103d15 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010087e:	b8 07 34 25 f0       	mov    $0xf0253407,%eax
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
f01008a0:	68 b4 6f 10 f0       	push   $0xf0106fb4
f01008a5:	e8 6b 34 00 00       	call   f0103d15 <cprintf>
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
f01008c0:	ff b3 44 74 10 f0    	pushl  -0xfef8bbc(%ebx)
f01008c6:	ff b3 40 74 10 f0    	pushl  -0xfef8bc0(%ebx)
f01008cc:	68 e9 6c 10 f0       	push   $0xf0106ce9
f01008d1:	e8 3f 34 00 00       	call   f0103d15 <cprintf>
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
f01008fb:	68 e0 6f 10 f0       	push   $0xf0106fe0
f0100900:	e8 10 34 00 00       	call   f0103d15 <cprintf>

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
f0100919:	68 f2 6c 10 f0       	push   $0xf0106cf2
f010091e:	e8 f2 33 00 00       	call   f0103d15 <cprintf>
    env_run(curenv);
f0100923:	e8 e0 59 00 00       	call   f0106308 <cpunum>
f0100928:	83 c4 04             	add    $0x4,%esp
f010092b:	6b c0 74             	imul   $0x74,%eax,%eax
f010092e:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0100934:	e8 78 31 00 00       	call   f0103ab1 <env_run>

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
f0100949:	68 0c 70 10 f0       	push   $0xf010700c
f010094e:	e8 c2 33 00 00       	call   f0103d15 <cprintf>
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
f0100961:	e8 a2 59 00 00       	call   f0106308 <cpunum>
f0100966:	83 ec 0c             	sub    $0xc,%esp
f0100969:	6b c0 74             	imul   $0x74,%eax,%eax
f010096c:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0100972:	e8 3a 31 00 00       	call   f0103ab1 <env_run>

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
f010098c:	68 40 70 10 f0       	push   $0xf0107040
f0100991:	e8 7f 33 00 00       	call   f0103d15 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f0100996:	c7 04 24 74 70 10 f0 	movl   $0xf0107074,(%esp)
f010099d:	e8 73 33 00 00       	call   f0103d15 <cprintf>
f01009a2:	83 c4 10             	add    $0x10,%esp
f01009a5:	e9 1a 01 00 00       	jmp    f0100ac4 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f01009aa:	83 ec 04             	sub    $0x4,%esp
f01009ad:	6a 00                	push   $0x0
f01009af:	6a 00                	push   $0x0
f01009b1:	ff 76 04             	pushl  0x4(%esi)
f01009b4:	e8 59 54 00 00       	call   f0105e12 <strtol>
f01009b9:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f01009bb:	83 c4 0c             	add    $0xc,%esp
f01009be:	6a 00                	push   $0x0
f01009c0:	6a 00                	push   $0x0
f01009c2:	ff 76 08             	pushl  0x8(%esi)
f01009c5:	e8 48 54 00 00       	call   f0105e12 <strtol>
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
f01009e9:	68 fc 6c 10 f0       	push   $0xf0106cfc
f01009ee:	e8 22 33 00 00       	call   f0103d15 <cprintf>
        
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
f0100a0c:	68 0d 6d 10 f0       	push   $0xf0106d0d
f0100a11:	e8 ff 32 00 00       	call   f0103d15 <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f0100a16:	83 c4 0c             	add    $0xc,%esp
f0100a19:	6a 00                	push   $0x0
f0100a1b:	53                   	push   %ebx
f0100a1c:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
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
f0100a39:	68 24 6d 10 f0       	push   $0xf0106d24
f0100a3e:	e8 d2 32 00 00       	call   f0103d15 <cprintf>
f0100a43:	83 c4 10             	add    $0x10,%esp
f0100a46:	eb 74                	jmp    f0100abc <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f0100a48:	83 ec 08             	sub    $0x8,%esp
f0100a4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a50:	50                   	push   %eax
f0100a51:	68 31 6d 10 f0       	push   $0xf0106d31
f0100a56:	e8 ba 32 00 00       	call   f0103d15 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f0100a5b:	83 c4 10             	add    $0x10,%esp
f0100a5e:	f6 03 04             	testb  $0x4,(%ebx)
f0100a61:	74 12                	je     f0100a75 <mon_showmappings+0xfe>
f0100a63:	83 ec 0c             	sub    $0xc,%esp
f0100a66:	68 39 6d 10 f0       	push   $0xf0106d39
f0100a6b:	e8 a5 32 00 00       	call   f0103d15 <cprintf>
f0100a70:	83 c4 10             	add    $0x10,%esp
f0100a73:	eb 10                	jmp    f0100a85 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f0100a75:	83 ec 0c             	sub    $0xc,%esp
f0100a78:	68 46 6d 10 f0       	push   $0xf0106d46
f0100a7d:	e8 93 32 00 00       	call   f0103d15 <cprintf>
f0100a82:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f0100a85:	f6 03 02             	testb  $0x2,(%ebx)
f0100a88:	74 12                	je     f0100a9c <mon_showmappings+0x125>
f0100a8a:	83 ec 0c             	sub    $0xc,%esp
f0100a8d:	68 53 6d 10 f0       	push   $0xf0106d53
f0100a92:	e8 7e 32 00 00       	call   f0103d15 <cprintf>
f0100a97:	83 c4 10             	add    $0x10,%esp
f0100a9a:	eb 10                	jmp    f0100aac <mon_showmappings+0x135>
                else cprintf(" R ");
f0100a9c:	83 ec 0c             	sub    $0xc,%esp
f0100a9f:	68 58 6d 10 f0       	push   $0xf0106d58
f0100aa4:	e8 6c 32 00 00       	call   f0103d15 <cprintf>
f0100aa9:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f0100aac:	83 ec 0c             	sub    $0xc,%esp
f0100aaf:	68 2f 6d 10 f0       	push   $0xf0106d2f
f0100ab4:	e8 5c 32 00 00       	call   f0103d15 <cprintf>
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
f0100ae6:	68 9c 70 10 f0       	push   $0xf010709c
f0100aeb:	e8 25 32 00 00       	call   f0103d15 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f0100af0:	c7 04 24 ec 70 10 f0 	movl   $0xf01070ec,(%esp)
f0100af7:	e8 19 32 00 00       	call   f0103d15 <cprintf>
f0100afc:	83 c4 10             	add    $0x10,%esp
f0100aff:	e9 a5 01 00 00       	jmp    f0100ca9 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f0100b04:	83 ec 04             	sub    $0x4,%esp
f0100b07:	6a 00                	push   $0x0
f0100b09:	6a 00                	push   $0x0
f0100b0b:	ff 73 04             	pushl  0x4(%ebx)
f0100b0e:	e8 ff 52 00 00       	call   f0105e12 <strtol>
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
f0100b4e:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
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
f0100b72:	68 10 71 10 f0       	push   $0xf0107110
f0100b77:	e8 99 31 00 00       	call   f0103d15 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100b7c:	83 c4 10             	add    $0x10,%esp
f0100b7f:	f6 03 02             	testb  $0x2,(%ebx)
f0100b82:	74 12                	je     f0100b96 <mon_setpermission+0xc5>
f0100b84:	83 ec 0c             	sub    $0xc,%esp
f0100b87:	68 5c 6d 10 f0       	push   $0xf0106d5c
f0100b8c:	e8 84 31 00 00       	call   f0103d15 <cprintf>
f0100b91:	83 c4 10             	add    $0x10,%esp
f0100b94:	eb 10                	jmp    f0100ba6 <mon_setpermission+0xd5>
f0100b96:	83 ec 0c             	sub    $0xc,%esp
f0100b99:	68 5f 6d 10 f0       	push   $0xf0106d5f
f0100b9e:	e8 72 31 00 00       	call   f0103d15 <cprintf>
f0100ba3:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100ba6:	f6 03 04             	testb  $0x4,(%ebx)
f0100ba9:	74 12                	je     f0100bbd <mon_setpermission+0xec>
f0100bab:	83 ec 0c             	sub    $0xc,%esp
f0100bae:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0100bb3:	e8 5d 31 00 00       	call   f0103d15 <cprintf>
f0100bb8:	83 c4 10             	add    $0x10,%esp
f0100bbb:	eb 10                	jmp    f0100bcd <mon_setpermission+0xfc>
f0100bbd:	83 ec 0c             	sub    $0xc,%esp
f0100bc0:	68 90 83 10 f0       	push   $0xf0108390
f0100bc5:	e8 4b 31 00 00       	call   f0103d15 <cprintf>
f0100bca:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100bcd:	f6 03 01             	testb  $0x1,(%ebx)
f0100bd0:	74 12                	je     f0100be4 <mon_setpermission+0x113>
f0100bd2:	83 ec 0c             	sub    $0xc,%esp
f0100bd5:	68 15 8a 10 f0       	push   $0xf0108a15
f0100bda:	e8 36 31 00 00       	call   f0103d15 <cprintf>
f0100bdf:	83 c4 10             	add    $0x10,%esp
f0100be2:	eb 10                	jmp    f0100bf4 <mon_setpermission+0x123>
f0100be4:	83 ec 0c             	sub    $0xc,%esp
f0100be7:	68 60 6d 10 f0       	push   $0xf0106d60
f0100bec:	e8 24 31 00 00       	call   f0103d15 <cprintf>
f0100bf1:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f0100bf4:	83 ec 0c             	sub    $0xc,%esp
f0100bf7:	68 62 6d 10 f0       	push   $0xf0106d62
f0100bfc:	e8 14 31 00 00       	call   f0103d15 <cprintf>
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
f0100c1a:	68 5c 6d 10 f0       	push   $0xf0106d5c
f0100c1f:	e8 f1 30 00 00       	call   f0103d15 <cprintf>
f0100c24:	83 c4 10             	add    $0x10,%esp
f0100c27:	eb 10                	jmp    f0100c39 <mon_setpermission+0x168>
f0100c29:	83 ec 0c             	sub    $0xc,%esp
f0100c2c:	68 5f 6d 10 f0       	push   $0xf0106d5f
f0100c31:	e8 df 30 00 00       	call   f0103d15 <cprintf>
f0100c36:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100c39:	f6 03 04             	testb  $0x4,(%ebx)
f0100c3c:	74 12                	je     f0100c50 <mon_setpermission+0x17f>
f0100c3e:	83 ec 0c             	sub    $0xc,%esp
f0100c41:	68 a3 7f 10 f0       	push   $0xf0107fa3
f0100c46:	e8 ca 30 00 00       	call   f0103d15 <cprintf>
f0100c4b:	83 c4 10             	add    $0x10,%esp
f0100c4e:	eb 10                	jmp    f0100c60 <mon_setpermission+0x18f>
f0100c50:	83 ec 0c             	sub    $0xc,%esp
f0100c53:	68 90 83 10 f0       	push   $0xf0108390
f0100c58:	e8 b8 30 00 00       	call   f0103d15 <cprintf>
f0100c5d:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100c60:	f6 03 01             	testb  $0x1,(%ebx)
f0100c63:	74 12                	je     f0100c77 <mon_setpermission+0x1a6>
f0100c65:	83 ec 0c             	sub    $0xc,%esp
f0100c68:	68 15 8a 10 f0       	push   $0xf0108a15
f0100c6d:	e8 a3 30 00 00       	call   f0103d15 <cprintf>
f0100c72:	83 c4 10             	add    $0x10,%esp
f0100c75:	eb 10                	jmp    f0100c87 <mon_setpermission+0x1b6>
f0100c77:	83 ec 0c             	sub    $0xc,%esp
f0100c7a:	68 60 6d 10 f0       	push   $0xf0106d60
f0100c7f:	e8 91 30 00 00       	call   f0103d15 <cprintf>
f0100c84:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100c87:	83 ec 0c             	sub    $0xc,%esp
f0100c8a:	68 2f 6d 10 f0       	push   $0xf0106d2f
f0100c8f:	e8 81 30 00 00       	call   f0103d15 <cprintf>
f0100c94:	83 c4 10             	add    $0x10,%esp
f0100c97:	eb 10                	jmp    f0100ca9 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100c99:	83 ec 0c             	sub    $0xc,%esp
f0100c9c:	68 24 6d 10 f0       	push   $0xf0106d24
f0100ca1:	e8 6f 30 00 00       	call   f0103d15 <cprintf>
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
f0100cc7:	68 34 71 10 f0       	push   $0xf0107134
f0100ccc:	e8 44 30 00 00       	call   f0103d15 <cprintf>
        cprintf("num show the color attribute. \n");
f0100cd1:	c7 04 24 64 71 10 f0 	movl   $0xf0107164,(%esp)
f0100cd8:	e8 38 30 00 00       	call   f0103d15 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100cdd:	c7 04 24 84 71 10 f0 	movl   $0xf0107184,(%esp)
f0100ce4:	e8 2c 30 00 00       	call   f0103d15 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100ce9:	c7 04 24 b8 71 10 f0 	movl   $0xf01071b8,(%esp)
f0100cf0:	e8 20 30 00 00       	call   f0103d15 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100cf5:	c7 04 24 fc 71 10 f0 	movl   $0xf01071fc,(%esp)
f0100cfc:	e8 14 30 00 00       	call   f0103d15 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100d01:	c7 04 24 73 6d 10 f0 	movl   $0xf0106d73,(%esp)
f0100d08:	e8 08 30 00 00       	call   f0103d15 <cprintf>
        cprintf("         set the background color to black\n");
f0100d0d:	c7 04 24 40 72 10 f0 	movl   $0xf0107240,(%esp)
f0100d14:	e8 fc 2f 00 00       	call   f0103d15 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100d19:	c7 04 24 6c 72 10 f0 	movl   $0xf010726c,(%esp)
f0100d20:	e8 f0 2f 00 00       	call   f0103d15 <cprintf>
f0100d25:	83 c4 10             	add    $0x10,%esp
f0100d28:	eb 52                	jmp    f0100d7c <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100d2a:	83 ec 0c             	sub    $0xc,%esp
f0100d2d:	ff 73 04             	pushl  0x4(%ebx)
f0100d30:	e8 db 4d 00 00       	call   f0105b10 <strlen>
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
f0100d66:	89 15 00 10 21 f0    	mov    %edx,0xf0211000
        cprintf(" This is color that you want ! \n");
f0100d6c:	83 ec 0c             	sub    $0xc,%esp
f0100d6f:	68 a0 72 10 f0       	push   $0xf01072a0
f0100d74:	e8 9c 2f 00 00       	call   f0103d15 <cprintf>
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
f0100db0:	68 c4 72 10 f0       	push   $0xf01072c4
f0100db5:	e8 5b 2f 00 00       	call   f0103d15 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100dba:	83 c4 18             	add    $0x18,%esp
f0100dbd:	57                   	push   %edi
f0100dbe:	ff 76 04             	pushl  0x4(%esi)
f0100dc1:	e8 5b 44 00 00       	call   f0105221 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100dc6:	83 c4 0c             	add    $0xc,%esp
f0100dc9:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100dcc:	ff 75 d0             	pushl  -0x30(%ebp)
f0100dcf:	68 8f 6d 10 f0       	push   $0xf0106d8f
f0100dd4:	e8 3c 2f 00 00       	call   f0103d15 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100dd9:	83 c4 0c             	add    $0xc,%esp
f0100ddc:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ddf:	ff 75 dc             	pushl  -0x24(%ebp)
f0100de2:	68 9f 6d 10 f0       	push   $0xf0106d9f
f0100de7:	e8 29 2f 00 00       	call   f0103d15 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100dec:	83 c4 08             	add    $0x8,%esp
f0100def:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100df2:	53                   	push   %ebx
f0100df3:	68 a4 6d 10 f0       	push   $0xf0106da4
f0100df8:	e8 18 2f 00 00       	call   f0103d15 <cprintf>
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
f0100e20:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e26:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100e2c:	77 15                	ja     f0100e43 <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e2e:	52                   	push   %edx
f0100e2f:	68 e4 69 10 f0       	push   $0xf01069e4
f0100e34:	68 96 00 00 00       	push   $0x96
f0100e39:	68 a9 6d 10 f0       	push   $0xf0106da9
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
f0100e73:	68 e4 69 10 f0       	push   $0xf01069e4
f0100e78:	68 9b 00 00 00       	push   $0x9b
f0100e7d:	68 a9 6d 10 f0       	push   $0xf0106da9
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
f0100ed5:	68 fc 72 10 f0       	push   $0xf01072fc
f0100eda:	e8 36 2e 00 00       	call   f0103d15 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100edf:	c7 04 24 2c 73 10 f0 	movl   $0xf010732c,(%esp)
f0100ee6:	e8 2a 2e 00 00       	call   f0103d15 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100eeb:	c7 04 24 54 73 10 f0 	movl   $0xf0107354,(%esp)
f0100ef2:	e8 1e 2e 00 00       	call   f0103d15 <cprintf>
f0100ef7:	83 c4 10             	add    $0x10,%esp
f0100efa:	e9 59 01 00 00       	jmp    f0101058 <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100eff:	83 ec 04             	sub    $0x4,%esp
f0100f02:	6a 00                	push   $0x0
f0100f04:	6a 00                	push   $0x0
f0100f06:	ff 76 08             	pushl  0x8(%esi)
f0100f09:	e8 04 4f 00 00       	call   f0105e12 <strtol>
f0100f0e:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100f10:	83 c4 0c             	add    $0xc,%esp
f0100f13:	6a 00                	push   $0x0
f0100f15:	6a 00                	push   $0x0
f0100f17:	ff 76 0c             	pushl  0xc(%esi)
f0100f1a:	e8 f3 4e 00 00       	call   f0105e12 <strtol>
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
f0100f5b:	68 2f 6d 10 f0       	push   $0xf0106d2f
f0100f60:	e8 b0 2d 00 00       	call   f0103d15 <cprintf>
f0100f65:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100f68:	83 ec 08             	sub    $0x8,%esp
f0100f6b:	53                   	push   %ebx
f0100f6c:	68 b8 6d 10 f0       	push   $0xf0106db8
f0100f71:	e8 9f 2d 00 00       	call   f0103d15 <cprintf>
f0100f76:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100f79:	83 ec 04             	sub    $0x4,%esp
f0100f7c:	6a 00                	push   $0x0
f0100f7e:	89 d8                	mov    %ebx,%eax
f0100f80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f85:	50                   	push   %eax
f0100f86:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
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
f0100fa2:	68 c2 6d 10 f0       	push   $0xf0106dc2
f0100fa7:	e8 69 2d 00 00       	call   f0103d15 <cprintf>
f0100fac:	83 c4 10             	add    $0x10,%esp
f0100faf:	eb 10                	jmp    f0100fc1 <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100fb1:	83 ec 0c             	sub    $0xc,%esp
f0100fb4:	68 cd 6d 10 f0       	push   $0xf0106dcd
f0100fb9:	e8 57 2d 00 00       	call   f0103d15 <cprintf>
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
f0100fcc:	68 2f 6d 10 f0       	push   $0xf0106d2f
f0100fd1:	e8 3f 2d 00 00       	call   f0103d15 <cprintf>
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
f0100fec:	68 2f 6d 10 f0       	push   $0xf0106d2f
f0100ff1:	e8 1f 2d 00 00       	call   f0103d15 <cprintf>
f0100ff6:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100ff9:	83 ec 08             	sub    $0x8,%esp
f0100ffc:	53                   	push   %ebx
f0100ffd:	68 b8 6d 10 f0       	push   $0xf0106db8
f0101002:	e8 0e 2d 00 00       	call   f0103d15 <cprintf>
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
f0101021:	68 c2 6d 10 f0       	push   $0xf0106dc2
f0101026:	e8 ea 2c 00 00       	call   f0103d15 <cprintf>
f010102b:	83 c4 10             	add    $0x10,%esp
f010102e:	eb 10                	jmp    f0101040 <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0101030:	83 ec 0c             	sub    $0xc,%esp
f0101033:	68 cb 6d 10 f0       	push   $0xf0106dcb
f0101038:	e8 d8 2c 00 00       	call   f0103d15 <cprintf>
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
f010104b:	68 2f 6d 10 f0       	push   $0xf0106d2f
f0101050:	e8 c0 2c 00 00       	call   f0103d15 <cprintf>
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
f010106e:	68 98 73 10 f0       	push   $0xf0107398
f0101073:	e8 9d 2c 00 00       	call   f0103d15 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101078:	c7 04 24 bc 73 10 f0 	movl   $0xf01073bc,(%esp)
f010107f:	e8 91 2c 00 00       	call   f0103d15 <cprintf>

	if (tf != NULL)
f0101084:	83 c4 10             	add    $0x10,%esp
f0101087:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010108b:	74 0e                	je     f010109b <monitor+0x36>
		print_trapframe(tf);
f010108d:	83 ec 0c             	sub    $0xc,%esp
f0101090:	ff 75 08             	pushl  0x8(%ebp)
f0101093:	e8 dd 2f 00 00       	call   f0104075 <print_trapframe>
f0101098:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010109b:	83 ec 0c             	sub    $0xc,%esp
f010109e:	68 d8 6d 10 f0       	push   $0xf0106dd8
f01010a3:	e8 88 49 00 00       	call   f0105a30 <readline>
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
f01010d0:	68 dc 6d 10 f0       	push   $0xf0106ddc
f01010d5:	e8 af 4b 00 00       	call   f0105c89 <strchr>
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
f01010f0:	68 e1 6d 10 f0       	push   $0xf0106de1
f01010f5:	e8 1b 2c 00 00       	call   f0103d15 <cprintf>
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
f010111a:	68 dc 6d 10 f0       	push   $0xf0106ddc
f010111f:	e8 65 4b 00 00       	call   f0105c89 <strchr>
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
f010113d:	bb 40 74 10 f0       	mov    $0xf0107440,%ebx
f0101142:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101147:	83 ec 08             	sub    $0x8,%esp
f010114a:	ff 33                	pushl  (%ebx)
f010114c:	ff 75 a8             	pushl  -0x58(%ebp)
f010114f:	e8 c7 4a 00 00       	call   f0105c1b <strcmp>
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
f0101169:	ff 97 48 74 10 f0    	call   *-0xfef8bb8(%edi)
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
f010118a:	68 fe 6d 10 f0       	push   $0xf0106dfe
f010118f:	e8 81 2b 00 00       	call   f0103d15 <cprintf>
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
f01011a9:	83 3d 34 12 21 f0 00 	cmpl   $0x0,0xf0211234
f01011b0:	75 0f                	jne    f01011c1 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01011b2:	b8 07 40 25 f0       	mov    $0xf0254007,%eax
f01011b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011bc:	a3 34 12 21 f0       	mov    %eax,0xf0211234
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f01011c1:	a1 34 12 21 f0       	mov    0xf0211234,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f01011c6:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f01011cd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01011d3:	89 15 34 12 21 f0    	mov    %edx,0xf0211234

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
f01011f7:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f01011fd:	72 15                	jb     f0101214 <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011ff:	50                   	push   %eax
f0101200:	68 08 6a 10 f0       	push   $0xf0106a08
f0101205:	68 79 03 00 00       	push   $0x379
f010120a:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0101248:	e8 87 29 00 00       	call   f0103bd4 <mc146818_read>
f010124d:	89 c6                	mov    %eax,%esi
f010124f:	43                   	inc    %ebx
f0101250:	89 1c 24             	mov    %ebx,(%esp)
f0101253:	e8 7c 29 00 00       	call   f0103bd4 <mc146818_read>
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
f0101278:	8b 1d 30 12 21 f0    	mov    0xf0211230,%ebx
f010127e:	85 db                	test   %ebx,%ebx
f0101280:	75 17                	jne    f0101299 <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f0101282:	83 ec 04             	sub    $0x4,%esp
f0101285:	68 ac 74 10 f0       	push   $0xf01074ac
f010128a:	68 ae 02 00 00       	push   $0x2ae
f010128f:	68 71 7d 10 f0       	push   $0xf0107d71
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
f01012ab:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
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
f01012e3:	89 1d 30 12 21 f0    	mov    %ebx,0xf0211230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01012e9:	85 db                	test   %ebx,%ebx
f01012eb:	74 57                	je     f0101344 <check_page_free_list+0xe0>
f01012ed:	89 d8                	mov    %ebx,%eax
f01012ef:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
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
f0101309:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f010130f:	72 12                	jb     f0101323 <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101311:	50                   	push   %eax
f0101312:	68 08 6a 10 f0       	push   $0xf0106a08
f0101317:	6a 58                	push   $0x58
f0101319:	68 7d 7d 10 f0       	push   $0xf0107d7d
f010131e:	e8 45 ed ff ff       	call   f0100068 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101323:	83 ec 04             	sub    $0x4,%esp
f0101326:	68 80 00 00 00       	push   $0x80
f010132b:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101330:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101335:	50                   	push   %eax
f0101336:	e8 9e 49 00 00       	call   f0105cd9 <memset>
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
f0101351:	8b 15 30 12 21 f0    	mov    0xf0211230,%edx
f0101357:	85 d2                	test   %edx,%edx
f0101359:	0f 84 b2 01 00 00    	je     f0101511 <check_page_free_list+0x2ad>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010135f:	8b 1d 90 1e 21 f0    	mov    0xf0211e90,%ebx
f0101365:	39 da                	cmp    %ebx,%edx
f0101367:	72 4b                	jb     f01013b4 <check_page_free_list+0x150>
		assert(pp < pages + npages);
f0101369:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
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
f01013b4:	68 8b 7d 10 f0       	push   $0xf0107d8b
f01013b9:	68 97 7d 10 f0       	push   $0xf0107d97
f01013be:	68 c8 02 00 00       	push   $0x2c8
f01013c3:	68 71 7d 10 f0       	push   $0xf0107d71
f01013c8:	e8 9b ec ff ff       	call   f0100068 <_panic>
		assert(pp < pages + npages);
f01013cd:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01013d0:	72 19                	jb     f01013eb <check_page_free_list+0x187>
f01013d2:	68 ac 7d 10 f0       	push   $0xf0107dac
f01013d7:	68 97 7d 10 f0       	push   $0xf0107d97
f01013dc:	68 c9 02 00 00       	push   $0x2c9
f01013e1:	68 71 7d 10 f0       	push   $0xf0107d71
f01013e6:	e8 7d ec ff ff       	call   f0100068 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01013eb:	89 d0                	mov    %edx,%eax
f01013ed:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01013f0:	a8 07                	test   $0x7,%al
f01013f2:	74 19                	je     f010140d <check_page_free_list+0x1a9>
f01013f4:	68 d0 74 10 f0       	push   $0xf01074d0
f01013f9:	68 97 7d 10 f0       	push   $0xf0107d97
f01013fe:	68 ca 02 00 00       	push   $0x2ca
f0101403:	68 71 7d 10 f0       	push   $0xf0107d71
f0101408:	e8 5b ec ff ff       	call   f0100068 <_panic>
f010140d:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101410:	c1 e0 0c             	shl    $0xc,%eax
f0101413:	75 19                	jne    f010142e <check_page_free_list+0x1ca>
f0101415:	68 c0 7d 10 f0       	push   $0xf0107dc0
f010141a:	68 97 7d 10 f0       	push   $0xf0107d97
f010141f:	68 cd 02 00 00       	push   $0x2cd
f0101424:	68 71 7d 10 f0       	push   $0xf0107d71
f0101429:	e8 3a ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010142e:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101433:	75 19                	jne    f010144e <check_page_free_list+0x1ea>
f0101435:	68 d1 7d 10 f0       	push   $0xf0107dd1
f010143a:	68 97 7d 10 f0       	push   $0xf0107d97
f010143f:	68 ce 02 00 00       	push   $0x2ce
f0101444:	68 71 7d 10 f0       	push   $0xf0107d71
f0101449:	e8 1a ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010144e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101453:	75 19                	jne    f010146e <check_page_free_list+0x20a>
f0101455:	68 04 75 10 f0       	push   $0xf0107504
f010145a:	68 97 7d 10 f0       	push   $0xf0107d97
f010145f:	68 cf 02 00 00       	push   $0x2cf
f0101464:	68 71 7d 10 f0       	push   $0xf0107d71
f0101469:	e8 fa eb ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010146e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101473:	75 19                	jne    f010148e <check_page_free_list+0x22a>
f0101475:	68 ea 7d 10 f0       	push   $0xf0107dea
f010147a:	68 97 7d 10 f0       	push   $0xf0107d97
f010147f:	68 d0 02 00 00       	push   $0x2d0
f0101484:	68 71 7d 10 f0       	push   $0xf0107d71
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
f01014a2:	68 08 6a 10 f0       	push   $0xf0106a08
f01014a7:	6a 58                	push   $0x58
f01014a9:	68 7d 7d 10 f0       	push   $0xf0107d7d
f01014ae:	e8 b5 eb ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f01014b3:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01014b9:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01014bc:	76 19                	jbe    f01014d7 <check_page_free_list+0x273>
f01014be:	68 28 75 10 f0       	push   $0xf0107528
f01014c3:	68 97 7d 10 f0       	push   $0xf0107d97
f01014c8:	68 d1 02 00 00       	push   $0x2d1
f01014cd:	68 71 7d 10 f0       	push   $0xf0107d71
f01014d2:	e8 91 eb ff ff       	call   f0100068 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01014d7:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01014dc:	75 19                	jne    f01014f7 <check_page_free_list+0x293>
f01014de:	68 04 7e 10 f0       	push   $0xf0107e04
f01014e3:	68 97 7d 10 f0       	push   $0xf0107d97
f01014e8:	68 d3 02 00 00       	push   $0x2d3
f01014ed:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0101511:	68 21 7e 10 f0       	push   $0xf0107e21
f0101516:	68 97 7d 10 f0       	push   $0xf0107d97
f010151b:	68 db 02 00 00       	push   $0x2db
f0101520:	68 71 7d 10 f0       	push   $0xf0107d71
f0101525:	e8 3e eb ff ff       	call   f0100068 <_panic>
	assert(nfree_extmem > 0);
f010152a:	85 f6                	test   %esi,%esi
f010152c:	7f 19                	jg     f0101547 <check_page_free_list+0x2e3>
f010152e:	68 33 7e 10 f0       	push   $0xf0107e33
f0101533:	68 97 7d 10 f0       	push   $0xf0107d97
f0101538:	68 dc 02 00 00       	push   $0x2dc
f010153d:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0101554:	c7 05 30 12 21 f0 00 	movl   $0x0,0xf0211230
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
f0101570:	68 e4 69 10 f0       	push   $0xf01069e4
f0101575:	68 50 01 00 00       	push   $0x150
f010157a:	68 71 7d 10 f0       	push   $0xf0107d71
f010157f:	e8 e4 ea ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101584:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f010158a:	c1 ee 0c             	shr    $0xc,%esi
    size_t mpentry_page = MPENTRY_PADDR / PGSIZE;
    for (i = 0; i < npages; i++) {
f010158d:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f0101594:	74 64                	je     f01015fa <page_init+0xab>
f0101596:	8b 1d 30 12 21 f0    	mov    0xf0211230,%ebx
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
f01015bc:	03 0d 90 1e 21 f0    	add    0xf0211e90,%ecx
f01015c2:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f01015c8:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f01015ca:	89 d3                	mov    %edx,%ebx
f01015cc:	03 1d 90 1e 21 f0    	add    0xf0211e90,%ebx
f01015d2:	eb 14                	jmp    f01015e8 <page_init+0x99>
        } else {
            pages[i].pp_ref = 1;
f01015d4:	89 d1                	mov    %edx,%ecx
f01015d6:	03 0d 90 1e 21 f0    	add    0xf0211e90,%ecx
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
f01015ec:	39 05 88 1e 21 f0    	cmp    %eax,0xf0211e88
f01015f2:	77 b2                	ja     f01015a6 <page_init+0x57>
f01015f4:	89 1d 30 12 21 f0    	mov    %ebx,0xf0211230
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
f0101608:	8b 1d 30 12 21 f0    	mov    0xf0211230,%ebx
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
f010161f:	89 1d 30 12 21 f0    	mov    %ebx,0xf0211230
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
f0101632:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0101638:	c1 f8 03             	sar    $0x3,%eax
f010163b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010163e:	89 c2                	mov    %eax,%edx
f0101640:	c1 ea 0c             	shr    $0xc,%edx
f0101643:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0101649:	72 12                	jb     f010165d <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010164b:	50                   	push   %eax
f010164c:	68 08 6a 10 f0       	push   $0xf0106a08
f0101651:	6a 58                	push   $0x58
f0101653:	68 7d 7d 10 f0       	push   $0xf0107d7d
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
f010166d:	e8 67 46 00 00       	call   f0105cd9 <memset>
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
f010167e:	a3 30 12 21 f0       	mov    %eax,0xf0211230
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
f010169c:	8b 15 30 12 21 f0    	mov    0xf0211230,%edx
f01016a2:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f01016a4:	a3 30 12 21 f0       	mov    %eax,0xf0211230
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
f0101701:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
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
f010171e:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0101724:	72 15                	jb     f010173b <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101726:	50                   	push   %eax
f0101727:	68 08 6a 10 f0       	push   $0xf0106a08
f010172c:	68 b4 01 00 00       	push   $0x1b4
f0101731:	68 71 7d 10 f0       	push   $0xf0107d71
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
f01017df:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f01017e5:	72 14                	jb     f01017fb <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01017e7:	83 ec 04             	sub    $0x4,%esp
f01017ea:	68 70 75 10 f0       	push   $0xf0107570
f01017ef:	6a 51                	push   $0x51
f01017f1:	68 7d 7d 10 f0       	push   $0xf0107d7d
f01017f6:	e8 6d e8 ff ff       	call   f0100068 <_panic>
	return &pages[PGNUM(pa)];
f01017fb:	c1 e0 03             	shl    $0x3,%eax
f01017fe:	03 05 90 1e 21 f0    	add    0xf0211e90,%eax
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
f010181d:	e8 e6 4a 00 00       	call   f0106308 <cpunum>
f0101822:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101829:	29 c2                	sub    %eax,%edx
f010182b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010182e:	83 3c 85 28 20 21 f0 	cmpl   $0x0,-0xfdedfd8(,%eax,4)
f0101835:	00 
f0101836:	74 20                	je     f0101858 <tlb_invalidate+0x41>
f0101838:	e8 cb 4a 00 00       	call   f0106308 <cpunum>
f010183d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101844:	29 c2                	sub    %eax,%edx
f0101846:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0101849:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
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
f01018ee:	2b 35 90 1e 21 f0    	sub    0xf0211e90,%esi
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
f0101941:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
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
f0101982:	89 15 38 12 21 f0    	mov    %edx,0xf0211238
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
f01019ae:	89 15 88 1e 21 f0    	mov    %edx,0xf0211e88
f01019b4:	eb 0c                	jmp    f01019c2 <mem_init+0x65>
	else
		npages = npages_basemem;
f01019b6:	8b 15 38 12 21 f0    	mov    0xf0211238,%edx
f01019bc:	89 15 88 1e 21 f0    	mov    %edx,0xf0211e88

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
f01019c9:	a1 38 12 21 f0       	mov    0xf0211238,%eax
f01019ce:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01019d1:	c1 e8 0a             	shr    $0xa,%eax
f01019d4:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01019d5:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f01019da:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01019dd:	c1 e8 0a             	shr    $0xa,%eax
f01019e0:	50                   	push   %eax
f01019e1:	68 90 75 10 f0       	push   $0xf0107590
f01019e6:	e8 2a 23 00 00       	call   f0103d15 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01019eb:	b8 00 10 00 00       	mov    $0x1000,%eax
f01019f0:	e8 af f7 ff ff       	call   f01011a4 <boot_alloc>
f01019f5:	a3 8c 1e 21 f0       	mov    %eax,0xf0211e8c
	memset(kern_pgdir, 0, PGSIZE);
f01019fa:	83 c4 0c             	add    $0xc,%esp
f01019fd:	68 00 10 00 00       	push   $0x1000
f0101a02:	6a 00                	push   $0x0
f0101a04:	50                   	push   %eax
f0101a05:	e8 cf 42 00 00       	call   f0105cd9 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101a0a:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
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
f0101a1a:	68 e4 69 10 f0       	push   $0xf01069e4
f0101a1f:	68 90 00 00 00       	push   $0x90
f0101a24:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0101a3d:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0101a42:	c1 e0 03             	shl    $0x3,%eax
f0101a45:	e8 5a f7 ff ff       	call   f01011a4 <boot_alloc>
f0101a4a:	a3 90 1e 21 f0       	mov    %eax,0xf0211e90
    

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101a4f:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101a54:	e8 4b f7 ff ff       	call   f01011a4 <boot_alloc>
f0101a59:	a3 3c 12 21 f0       	mov    %eax,0xf021123c
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
f0101a6d:	83 3d 90 1e 21 f0 00 	cmpl   $0x0,0xf0211e90
f0101a74:	75 17                	jne    f0101a8d <mem_init+0x130>
		panic("'pages' is a null pointer!");
f0101a76:	83 ec 04             	sub    $0x4,%esp
f0101a79:	68 44 7e 10 f0       	push   $0xf0107e44
f0101a7e:	68 ed 02 00 00       	push   $0x2ed
f0101a83:	68 71 7d 10 f0       	push   $0xf0107d71
f0101a88:	e8 db e5 ff ff       	call   f0100068 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a8d:	a1 30 12 21 f0       	mov    0xf0211230,%eax
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
f0101abc:	68 5f 7e 10 f0       	push   $0xf0107e5f
f0101ac1:	68 97 7d 10 f0       	push   $0xf0107d97
f0101ac6:	68 f5 02 00 00       	push   $0x2f5
f0101acb:	68 71 7d 10 f0       	push   $0xf0107d71
f0101ad0:	e8 93 e5 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ad5:	83 ec 0c             	sub    $0xc,%esp
f0101ad8:	6a 00                	push   $0x0
f0101ada:	e8 22 fb ff ff       	call   f0101601 <page_alloc>
f0101adf:	89 c7                	mov    %eax,%edi
f0101ae1:	83 c4 10             	add    $0x10,%esp
f0101ae4:	85 c0                	test   %eax,%eax
f0101ae6:	75 19                	jne    f0101b01 <mem_init+0x1a4>
f0101ae8:	68 75 7e 10 f0       	push   $0xf0107e75
f0101aed:	68 97 7d 10 f0       	push   $0xf0107d97
f0101af2:	68 f6 02 00 00       	push   $0x2f6
f0101af7:	68 71 7d 10 f0       	push   $0xf0107d71
f0101afc:	e8 67 e5 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b01:	83 ec 0c             	sub    $0xc,%esp
f0101b04:	6a 00                	push   $0x0
f0101b06:	e8 f6 fa ff ff       	call   f0101601 <page_alloc>
f0101b0b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b0e:	83 c4 10             	add    $0x10,%esp
f0101b11:	85 c0                	test   %eax,%eax
f0101b13:	75 19                	jne    f0101b2e <mem_init+0x1d1>
f0101b15:	68 8b 7e 10 f0       	push   $0xf0107e8b
f0101b1a:	68 97 7d 10 f0       	push   $0xf0107d97
f0101b1f:	68 f7 02 00 00       	push   $0x2f7
f0101b24:	68 71 7d 10 f0       	push   $0xf0107d71
f0101b29:	e8 3a e5 ff ff       	call   f0100068 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b2e:	39 fe                	cmp    %edi,%esi
f0101b30:	75 19                	jne    f0101b4b <mem_init+0x1ee>
f0101b32:	68 a1 7e 10 f0       	push   $0xf0107ea1
f0101b37:	68 97 7d 10 f0       	push   $0xf0107d97
f0101b3c:	68 fa 02 00 00       	push   $0x2fa
f0101b41:	68 71 7d 10 f0       	push   $0xf0107d71
f0101b46:	e8 1d e5 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b4b:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101b4e:	74 05                	je     f0101b55 <mem_init+0x1f8>
f0101b50:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101b53:	75 19                	jne    f0101b6e <mem_init+0x211>
f0101b55:	68 cc 75 10 f0       	push   $0xf01075cc
f0101b5a:	68 97 7d 10 f0       	push   $0xf0107d97
f0101b5f:	68 fb 02 00 00       	push   $0x2fb
f0101b64:	68 71 7d 10 f0       	push   $0xf0107d71
f0101b69:	e8 fa e4 ff ff       	call   f0100068 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b6e:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101b74:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0101b79:	c1 e0 0c             	shl    $0xc,%eax
f0101b7c:	89 f1                	mov    %esi,%ecx
f0101b7e:	29 d1                	sub    %edx,%ecx
f0101b80:	c1 f9 03             	sar    $0x3,%ecx
f0101b83:	c1 e1 0c             	shl    $0xc,%ecx
f0101b86:	39 c1                	cmp    %eax,%ecx
f0101b88:	72 19                	jb     f0101ba3 <mem_init+0x246>
f0101b8a:	68 b3 7e 10 f0       	push   $0xf0107eb3
f0101b8f:	68 97 7d 10 f0       	push   $0xf0107d97
f0101b94:	68 fc 02 00 00       	push   $0x2fc
f0101b99:	68 71 7d 10 f0       	push   $0xf0107d71
f0101b9e:	e8 c5 e4 ff ff       	call   f0100068 <_panic>
f0101ba3:	89 f9                	mov    %edi,%ecx
f0101ba5:	29 d1                	sub    %edx,%ecx
f0101ba7:	c1 f9 03             	sar    $0x3,%ecx
f0101baa:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101bad:	39 c8                	cmp    %ecx,%eax
f0101baf:	77 19                	ja     f0101bca <mem_init+0x26d>
f0101bb1:	68 d0 7e 10 f0       	push   $0xf0107ed0
f0101bb6:	68 97 7d 10 f0       	push   $0xf0107d97
f0101bbb:	68 fd 02 00 00       	push   $0x2fd
f0101bc0:	68 71 7d 10 f0       	push   $0xf0107d71
f0101bc5:	e8 9e e4 ff ff       	call   f0100068 <_panic>
f0101bca:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101bcd:	29 d1                	sub    %edx,%ecx
f0101bcf:	89 ca                	mov    %ecx,%edx
f0101bd1:	c1 fa 03             	sar    $0x3,%edx
f0101bd4:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101bd7:	39 d0                	cmp    %edx,%eax
f0101bd9:	77 19                	ja     f0101bf4 <mem_init+0x297>
f0101bdb:	68 ed 7e 10 f0       	push   $0xf0107eed
f0101be0:	68 97 7d 10 f0       	push   $0xf0107d97
f0101be5:	68 fe 02 00 00       	push   $0x2fe
f0101bea:	68 71 7d 10 f0       	push   $0xf0107d71
f0101bef:	e8 74 e4 ff ff       	call   f0100068 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101bf4:	a1 30 12 21 f0       	mov    0xf0211230,%eax
f0101bf9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101bfc:	c7 05 30 12 21 f0 00 	movl   $0x0,0xf0211230
f0101c03:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c06:	83 ec 0c             	sub    $0xc,%esp
f0101c09:	6a 00                	push   $0x0
f0101c0b:	e8 f1 f9 ff ff       	call   f0101601 <page_alloc>
f0101c10:	83 c4 10             	add    $0x10,%esp
f0101c13:	85 c0                	test   %eax,%eax
f0101c15:	74 19                	je     f0101c30 <mem_init+0x2d3>
f0101c17:	68 0a 7f 10 f0       	push   $0xf0107f0a
f0101c1c:	68 97 7d 10 f0       	push   $0xf0107d97
f0101c21:	68 05 03 00 00       	push   $0x305
f0101c26:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0101c61:	68 5f 7e 10 f0       	push   $0xf0107e5f
f0101c66:	68 97 7d 10 f0       	push   $0xf0107d97
f0101c6b:	68 0c 03 00 00       	push   $0x30c
f0101c70:	68 71 7d 10 f0       	push   $0xf0107d71
f0101c75:	e8 ee e3 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c7a:	83 ec 0c             	sub    $0xc,%esp
f0101c7d:	6a 00                	push   $0x0
f0101c7f:	e8 7d f9 ff ff       	call   f0101601 <page_alloc>
f0101c84:	89 c7                	mov    %eax,%edi
f0101c86:	83 c4 10             	add    $0x10,%esp
f0101c89:	85 c0                	test   %eax,%eax
f0101c8b:	75 19                	jne    f0101ca6 <mem_init+0x349>
f0101c8d:	68 75 7e 10 f0       	push   $0xf0107e75
f0101c92:	68 97 7d 10 f0       	push   $0xf0107d97
f0101c97:	68 0d 03 00 00       	push   $0x30d
f0101c9c:	68 71 7d 10 f0       	push   $0xf0107d71
f0101ca1:	e8 c2 e3 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ca6:	83 ec 0c             	sub    $0xc,%esp
f0101ca9:	6a 00                	push   $0x0
f0101cab:	e8 51 f9 ff ff       	call   f0101601 <page_alloc>
f0101cb0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101cb3:	83 c4 10             	add    $0x10,%esp
f0101cb6:	85 c0                	test   %eax,%eax
f0101cb8:	75 19                	jne    f0101cd3 <mem_init+0x376>
f0101cba:	68 8b 7e 10 f0       	push   $0xf0107e8b
f0101cbf:	68 97 7d 10 f0       	push   $0xf0107d97
f0101cc4:	68 0e 03 00 00       	push   $0x30e
f0101cc9:	68 71 7d 10 f0       	push   $0xf0107d71
f0101cce:	e8 95 e3 ff ff       	call   f0100068 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101cd3:	39 fe                	cmp    %edi,%esi
f0101cd5:	75 19                	jne    f0101cf0 <mem_init+0x393>
f0101cd7:	68 a1 7e 10 f0       	push   $0xf0107ea1
f0101cdc:	68 97 7d 10 f0       	push   $0xf0107d97
f0101ce1:	68 10 03 00 00       	push   $0x310
f0101ce6:	68 71 7d 10 f0       	push   $0xf0107d71
f0101ceb:	e8 78 e3 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cf0:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101cf3:	74 05                	je     f0101cfa <mem_init+0x39d>
f0101cf5:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101cf8:	75 19                	jne    f0101d13 <mem_init+0x3b6>
f0101cfa:	68 cc 75 10 f0       	push   $0xf01075cc
f0101cff:	68 97 7d 10 f0       	push   $0xf0107d97
f0101d04:	68 11 03 00 00       	push   $0x311
f0101d09:	68 71 7d 10 f0       	push   $0xf0107d71
f0101d0e:	e8 55 e3 ff ff       	call   f0100068 <_panic>
	assert(!page_alloc(0));
f0101d13:	83 ec 0c             	sub    $0xc,%esp
f0101d16:	6a 00                	push   $0x0
f0101d18:	e8 e4 f8 ff ff       	call   f0101601 <page_alloc>
f0101d1d:	83 c4 10             	add    $0x10,%esp
f0101d20:	85 c0                	test   %eax,%eax
f0101d22:	74 19                	je     f0101d3d <mem_init+0x3e0>
f0101d24:	68 0a 7f 10 f0       	push   $0xf0107f0a
f0101d29:	68 97 7d 10 f0       	push   $0xf0107d97
f0101d2e:	68 12 03 00 00       	push   $0x312
f0101d33:	68 71 7d 10 f0       	push   $0xf0107d71
f0101d38:	e8 2b e3 ff ff       	call   f0100068 <_panic>
f0101d3d:	89 f0                	mov    %esi,%eax
f0101d3f:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0101d45:	c1 f8 03             	sar    $0x3,%eax
f0101d48:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d4b:	89 c2                	mov    %eax,%edx
f0101d4d:	c1 ea 0c             	shr    $0xc,%edx
f0101d50:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0101d56:	72 12                	jb     f0101d6a <mem_init+0x40d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d58:	50                   	push   %eax
f0101d59:	68 08 6a 10 f0       	push   $0xf0106a08
f0101d5e:	6a 58                	push   $0x58
f0101d60:	68 7d 7d 10 f0       	push   $0xf0107d7d
f0101d65:	e8 fe e2 ff ff       	call   f0100068 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101d6a:	83 ec 04             	sub    $0x4,%esp
f0101d6d:	68 00 10 00 00       	push   $0x1000
f0101d72:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101d74:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d79:	50                   	push   %eax
f0101d7a:	e8 5a 3f 00 00       	call   f0105cd9 <memset>
	page_free(pp0);
f0101d7f:	89 34 24             	mov    %esi,(%esp)
f0101d82:	e8 04 f9 ff ff       	call   f010168b <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d87:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101d8e:	e8 6e f8 ff ff       	call   f0101601 <page_alloc>
f0101d93:	83 c4 10             	add    $0x10,%esp
f0101d96:	85 c0                	test   %eax,%eax
f0101d98:	75 19                	jne    f0101db3 <mem_init+0x456>
f0101d9a:	68 19 7f 10 f0       	push   $0xf0107f19
f0101d9f:	68 97 7d 10 f0       	push   $0xf0107d97
f0101da4:	68 17 03 00 00       	push   $0x317
f0101da9:	68 71 7d 10 f0       	push   $0xf0107d71
f0101dae:	e8 b5 e2 ff ff       	call   f0100068 <_panic>
	assert(pp && pp0 == pp);
f0101db3:	39 c6                	cmp    %eax,%esi
f0101db5:	74 19                	je     f0101dd0 <mem_init+0x473>
f0101db7:	68 37 7f 10 f0       	push   $0xf0107f37
f0101dbc:	68 97 7d 10 f0       	push   $0xf0107d97
f0101dc1:	68 18 03 00 00       	push   $0x318
f0101dc6:	68 71 7d 10 f0       	push   $0xf0107d71
f0101dcb:	e8 98 e2 ff ff       	call   f0100068 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101dd0:	89 f2                	mov    %esi,%edx
f0101dd2:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101dd8:	c1 fa 03             	sar    $0x3,%edx
f0101ddb:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101dde:	89 d0                	mov    %edx,%eax
f0101de0:	c1 e8 0c             	shr    $0xc,%eax
f0101de3:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0101de9:	72 12                	jb     f0101dfd <mem_init+0x4a0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101deb:	52                   	push   %edx
f0101dec:	68 08 6a 10 f0       	push   $0xf0106a08
f0101df1:	6a 58                	push   $0x58
f0101df3:	68 7d 7d 10 f0       	push   $0xf0107d7d
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
f0101e17:	68 47 7f 10 f0       	push   $0xf0107f47
f0101e1c:	68 97 7d 10 f0       	push   $0xf0107d97
f0101e21:	68 1b 03 00 00       	push   $0x31b
f0101e26:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0101e38:	89 15 30 12 21 f0    	mov    %edx,0xf0211230

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
f0101e5a:	a1 30 12 21 f0       	mov    0xf0211230,%eax
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
f0101e71:	68 51 7f 10 f0       	push   $0xf0107f51
f0101e76:	68 97 7d 10 f0       	push   $0xf0107d97
f0101e7b:	68 28 03 00 00       	push   $0x328
f0101e80:	68 71 7d 10 f0       	push   $0xf0107d71
f0101e85:	e8 de e1 ff ff       	call   f0100068 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101e8a:	83 ec 0c             	sub    $0xc,%esp
f0101e8d:	68 ec 75 10 f0       	push   $0xf01075ec
f0101e92:	e8 7e 1e 00 00       	call   f0103d15 <cprintf>
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
f0101eac:	68 5f 7e 10 f0       	push   $0xf0107e5f
f0101eb1:	68 97 7d 10 f0       	push   $0xf0107d97
f0101eb6:	68 8e 03 00 00       	push   $0x38e
f0101ebb:	68 71 7d 10 f0       	push   $0xf0107d71
f0101ec0:	e8 a3 e1 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ec5:	83 ec 0c             	sub    $0xc,%esp
f0101ec8:	6a 00                	push   $0x0
f0101eca:	e8 32 f7 ff ff       	call   f0101601 <page_alloc>
f0101ecf:	89 c6                	mov    %eax,%esi
f0101ed1:	83 c4 10             	add    $0x10,%esp
f0101ed4:	85 c0                	test   %eax,%eax
f0101ed6:	75 19                	jne    f0101ef1 <mem_init+0x594>
f0101ed8:	68 75 7e 10 f0       	push   $0xf0107e75
f0101edd:	68 97 7d 10 f0       	push   $0xf0107d97
f0101ee2:	68 8f 03 00 00       	push   $0x38f
f0101ee7:	68 71 7d 10 f0       	push   $0xf0107d71
f0101eec:	e8 77 e1 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ef1:	83 ec 0c             	sub    $0xc,%esp
f0101ef4:	6a 00                	push   $0x0
f0101ef6:	e8 06 f7 ff ff       	call   f0101601 <page_alloc>
f0101efb:	89 c3                	mov    %eax,%ebx
f0101efd:	83 c4 10             	add    $0x10,%esp
f0101f00:	85 c0                	test   %eax,%eax
f0101f02:	75 19                	jne    f0101f1d <mem_init+0x5c0>
f0101f04:	68 8b 7e 10 f0       	push   $0xf0107e8b
f0101f09:	68 97 7d 10 f0       	push   $0xf0107d97
f0101f0e:	68 90 03 00 00       	push   $0x390
f0101f13:	68 71 7d 10 f0       	push   $0xf0107d71
f0101f18:	e8 4b e1 ff ff       	call   f0100068 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f1d:	39 f7                	cmp    %esi,%edi
f0101f1f:	75 19                	jne    f0101f3a <mem_init+0x5dd>
f0101f21:	68 a1 7e 10 f0       	push   $0xf0107ea1
f0101f26:	68 97 7d 10 f0       	push   $0xf0107d97
f0101f2b:	68 93 03 00 00       	push   $0x393
f0101f30:	68 71 7d 10 f0       	push   $0xf0107d71
f0101f35:	e8 2e e1 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f3a:	39 c6                	cmp    %eax,%esi
f0101f3c:	74 04                	je     f0101f42 <mem_init+0x5e5>
f0101f3e:	39 c7                	cmp    %eax,%edi
f0101f40:	75 19                	jne    f0101f5b <mem_init+0x5fe>
f0101f42:	68 cc 75 10 f0       	push   $0xf01075cc
f0101f47:	68 97 7d 10 f0       	push   $0xf0107d97
f0101f4c:	68 94 03 00 00       	push   $0x394
f0101f51:	68 71 7d 10 f0       	push   $0xf0107d71
f0101f56:	e8 0d e1 ff ff       	call   f0100068 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101f5b:	8b 0d 30 12 21 f0    	mov    0xf0211230,%ecx
f0101f61:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101f64:	c7 05 30 12 21 f0 00 	movl   $0x0,0xf0211230
f0101f6b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101f6e:	83 ec 0c             	sub    $0xc,%esp
f0101f71:	6a 00                	push   $0x0
f0101f73:	e8 89 f6 ff ff       	call   f0101601 <page_alloc>
f0101f78:	83 c4 10             	add    $0x10,%esp
f0101f7b:	85 c0                	test   %eax,%eax
f0101f7d:	74 19                	je     f0101f98 <mem_init+0x63b>
f0101f7f:	68 0a 7f 10 f0       	push   $0xf0107f0a
f0101f84:	68 97 7d 10 f0       	push   $0xf0107d97
f0101f89:	68 9b 03 00 00       	push   $0x39b
f0101f8e:	68 71 7d 10 f0       	push   $0xf0107d71
f0101f93:	e8 d0 e0 ff ff       	call   f0100068 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101f98:	83 ec 04             	sub    $0x4,%esp
f0101f9b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101f9e:	50                   	push   %eax
f0101f9f:	6a 00                	push   $0x0
f0101fa1:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101fa7:	e8 05 f8 ff ff       	call   f01017b1 <page_lookup>
f0101fac:	83 c4 10             	add    $0x10,%esp
f0101faf:	85 c0                	test   %eax,%eax
f0101fb1:	74 19                	je     f0101fcc <mem_init+0x66f>
f0101fb3:	68 0c 76 10 f0       	push   $0xf010760c
f0101fb8:	68 97 7d 10 f0       	push   $0xf0107d97
f0101fbd:	68 9e 03 00 00       	push   $0x39e
f0101fc2:	68 71 7d 10 f0       	push   $0xf0107d71
f0101fc7:	e8 9c e0 ff ff       	call   f0100068 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101fcc:	6a 02                	push   $0x2
f0101fce:	6a 00                	push   $0x0
f0101fd0:	56                   	push   %esi
f0101fd1:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101fd7:	e8 d1 f8 ff ff       	call   f01018ad <page_insert>
f0101fdc:	83 c4 10             	add    $0x10,%esp
f0101fdf:	85 c0                	test   %eax,%eax
f0101fe1:	78 19                	js     f0101ffc <mem_init+0x69f>
f0101fe3:	68 44 76 10 f0       	push   $0xf0107644
f0101fe8:	68 97 7d 10 f0       	push   $0xf0107d97
f0101fed:	68 a1 03 00 00       	push   $0x3a1
f0101ff2:	68 71 7d 10 f0       	push   $0xf0107d71
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
f010200a:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102010:	e8 98 f8 ff ff       	call   f01018ad <page_insert>
f0102015:	83 c4 20             	add    $0x20,%esp
f0102018:	85 c0                	test   %eax,%eax
f010201a:	74 19                	je     f0102035 <mem_init+0x6d8>
f010201c:	68 74 76 10 f0       	push   $0xf0107674
f0102021:	68 97 7d 10 f0       	push   $0xf0107d97
f0102026:	68 a5 03 00 00       	push   $0x3a5
f010202b:	68 71 7d 10 f0       	push   $0xf0107d71
f0102030:	e8 33 e0 ff ff       	call   f0100068 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102035:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010203a:	8b 08                	mov    (%eax),%ecx
f010203c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102042:	89 fa                	mov    %edi,%edx
f0102044:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f010204a:	c1 fa 03             	sar    $0x3,%edx
f010204d:	c1 e2 0c             	shl    $0xc,%edx
f0102050:	39 d1                	cmp    %edx,%ecx
f0102052:	74 19                	je     f010206d <mem_init+0x710>
f0102054:	68 a4 76 10 f0       	push   $0xf01076a4
f0102059:	68 97 7d 10 f0       	push   $0xf0107d97
f010205e:	68 a6 03 00 00       	push   $0x3a6
f0102063:	68 71 7d 10 f0       	push   $0xf0107d71
f0102068:	e8 fb df ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010206d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102072:	e8 64 f1 ff ff       	call   f01011db <check_va2pa>
f0102077:	89 f2                	mov    %esi,%edx
f0102079:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f010207f:	c1 fa 03             	sar    $0x3,%edx
f0102082:	c1 e2 0c             	shl    $0xc,%edx
f0102085:	39 d0                	cmp    %edx,%eax
f0102087:	74 19                	je     f01020a2 <mem_init+0x745>
f0102089:	68 cc 76 10 f0       	push   $0xf01076cc
f010208e:	68 97 7d 10 f0       	push   $0xf0107d97
f0102093:	68 a7 03 00 00       	push   $0x3a7
f0102098:	68 71 7d 10 f0       	push   $0xf0107d71
f010209d:	e8 c6 df ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 1);
f01020a2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01020a7:	74 19                	je     f01020c2 <mem_init+0x765>
f01020a9:	68 5c 7f 10 f0       	push   $0xf0107f5c
f01020ae:	68 97 7d 10 f0       	push   $0xf0107d97
f01020b3:	68 a8 03 00 00       	push   $0x3a8
f01020b8:	68 71 7d 10 f0       	push   $0xf0107d71
f01020bd:	e8 a6 df ff ff       	call   f0100068 <_panic>
	assert(pp0->pp_ref == 1);
f01020c2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01020c7:	74 19                	je     f01020e2 <mem_init+0x785>
f01020c9:	68 6d 7f 10 f0       	push   $0xf0107f6d
f01020ce:	68 97 7d 10 f0       	push   $0xf0107d97
f01020d3:	68 a9 03 00 00       	push   $0x3a9
f01020d8:	68 71 7d 10 f0       	push   $0xf0107d71
f01020dd:	e8 86 df ff ff       	call   f0100068 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020e2:	6a 02                	push   $0x2
f01020e4:	68 00 10 00 00       	push   $0x1000
f01020e9:	53                   	push   %ebx
f01020ea:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01020f0:	e8 b8 f7 ff ff       	call   f01018ad <page_insert>
f01020f5:	83 c4 10             	add    $0x10,%esp
f01020f8:	85 c0                	test   %eax,%eax
f01020fa:	74 19                	je     f0102115 <mem_init+0x7b8>
f01020fc:	68 fc 76 10 f0       	push   $0xf01076fc
f0102101:	68 97 7d 10 f0       	push   $0xf0107d97
f0102106:	68 ac 03 00 00       	push   $0x3ac
f010210b:	68 71 7d 10 f0       	push   $0xf0107d71
f0102110:	e8 53 df ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102115:	ba 00 10 00 00       	mov    $0x1000,%edx
f010211a:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010211f:	e8 b7 f0 ff ff       	call   f01011db <check_va2pa>
f0102124:	89 da                	mov    %ebx,%edx
f0102126:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f010212c:	c1 fa 03             	sar    $0x3,%edx
f010212f:	c1 e2 0c             	shl    $0xc,%edx
f0102132:	39 d0                	cmp    %edx,%eax
f0102134:	74 19                	je     f010214f <mem_init+0x7f2>
f0102136:	68 38 77 10 f0       	push   $0xf0107738
f010213b:	68 97 7d 10 f0       	push   $0xf0107d97
f0102140:	68 ad 03 00 00       	push   $0x3ad
f0102145:	68 71 7d 10 f0       	push   $0xf0107d71
f010214a:	e8 19 df ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f010214f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102154:	74 19                	je     f010216f <mem_init+0x812>
f0102156:	68 7e 7f 10 f0       	push   $0xf0107f7e
f010215b:	68 97 7d 10 f0       	push   $0xf0107d97
f0102160:	68 ae 03 00 00       	push   $0x3ae
f0102165:	68 71 7d 10 f0       	push   $0xf0107d71
f010216a:	e8 f9 de ff ff       	call   f0100068 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010216f:	83 ec 0c             	sub    $0xc,%esp
f0102172:	6a 00                	push   $0x0
f0102174:	e8 88 f4 ff ff       	call   f0101601 <page_alloc>
f0102179:	83 c4 10             	add    $0x10,%esp
f010217c:	85 c0                	test   %eax,%eax
f010217e:	74 19                	je     f0102199 <mem_init+0x83c>
f0102180:	68 0a 7f 10 f0       	push   $0xf0107f0a
f0102185:	68 97 7d 10 f0       	push   $0xf0107d97
f010218a:	68 b1 03 00 00       	push   $0x3b1
f010218f:	68 71 7d 10 f0       	push   $0xf0107d71
f0102194:	e8 cf de ff ff       	call   f0100068 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102199:	6a 02                	push   $0x2
f010219b:	68 00 10 00 00       	push   $0x1000
f01021a0:	53                   	push   %ebx
f01021a1:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01021a7:	e8 01 f7 ff ff       	call   f01018ad <page_insert>
f01021ac:	83 c4 10             	add    $0x10,%esp
f01021af:	85 c0                	test   %eax,%eax
f01021b1:	74 19                	je     f01021cc <mem_init+0x86f>
f01021b3:	68 fc 76 10 f0       	push   $0xf01076fc
f01021b8:	68 97 7d 10 f0       	push   $0xf0107d97
f01021bd:	68 b4 03 00 00       	push   $0x3b4
f01021c2:	68 71 7d 10 f0       	push   $0xf0107d71
f01021c7:	e8 9c de ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021cc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021d1:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01021d6:	e8 00 f0 ff ff       	call   f01011db <check_va2pa>
f01021db:	89 da                	mov    %ebx,%edx
f01021dd:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f01021e3:	c1 fa 03             	sar    $0x3,%edx
f01021e6:	c1 e2 0c             	shl    $0xc,%edx
f01021e9:	39 d0                	cmp    %edx,%eax
f01021eb:	74 19                	je     f0102206 <mem_init+0x8a9>
f01021ed:	68 38 77 10 f0       	push   $0xf0107738
f01021f2:	68 97 7d 10 f0       	push   $0xf0107d97
f01021f7:	68 b5 03 00 00       	push   $0x3b5
f01021fc:	68 71 7d 10 f0       	push   $0xf0107d71
f0102201:	e8 62 de ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f0102206:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010220b:	74 19                	je     f0102226 <mem_init+0x8c9>
f010220d:	68 7e 7f 10 f0       	push   $0xf0107f7e
f0102212:	68 97 7d 10 f0       	push   $0xf0107d97
f0102217:	68 b6 03 00 00       	push   $0x3b6
f010221c:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0102237:	68 0a 7f 10 f0       	push   $0xf0107f0a
f010223c:	68 97 7d 10 f0       	push   $0xf0107d97
f0102241:	68 ba 03 00 00       	push   $0x3ba
f0102246:	68 71 7d 10 f0       	push   $0xf0107d71
f010224b:	e8 18 de ff ff       	call   f0100068 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102250:	8b 15 8c 1e 21 f0    	mov    0xf0211e8c,%edx
f0102256:	8b 02                	mov    (%edx),%eax
f0102258:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010225d:	89 c1                	mov    %eax,%ecx
f010225f:	c1 e9 0c             	shr    $0xc,%ecx
f0102262:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0102268:	72 15                	jb     f010227f <mem_init+0x922>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010226a:	50                   	push   %eax
f010226b:	68 08 6a 10 f0       	push   $0xf0106a08
f0102270:	68 bd 03 00 00       	push   $0x3bd
f0102275:	68 71 7d 10 f0       	push   $0xf0107d71
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
f01022a4:	68 68 77 10 f0       	push   $0xf0107768
f01022a9:	68 97 7d 10 f0       	push   $0xf0107d97
f01022ae:	68 be 03 00 00       	push   $0x3be
f01022b3:	68 71 7d 10 f0       	push   $0xf0107d71
f01022b8:	e8 ab dd ff ff       	call   f0100068 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01022bd:	6a 06                	push   $0x6
f01022bf:	68 00 10 00 00       	push   $0x1000
f01022c4:	53                   	push   %ebx
f01022c5:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01022cb:	e8 dd f5 ff ff       	call   f01018ad <page_insert>
f01022d0:	83 c4 10             	add    $0x10,%esp
f01022d3:	85 c0                	test   %eax,%eax
f01022d5:	74 19                	je     f01022f0 <mem_init+0x993>
f01022d7:	68 a8 77 10 f0       	push   $0xf01077a8
f01022dc:	68 97 7d 10 f0       	push   $0xf0107d97
f01022e1:	68 c1 03 00 00       	push   $0x3c1
f01022e6:	68 71 7d 10 f0       	push   $0xf0107d71
f01022eb:	e8 78 dd ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022f0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022f5:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01022fa:	e8 dc ee ff ff       	call   f01011db <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022ff:	89 da                	mov    %ebx,%edx
f0102301:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0102307:	c1 fa 03             	sar    $0x3,%edx
f010230a:	c1 e2 0c             	shl    $0xc,%edx
f010230d:	39 d0                	cmp    %edx,%eax
f010230f:	74 19                	je     f010232a <mem_init+0x9cd>
f0102311:	68 38 77 10 f0       	push   $0xf0107738
f0102316:	68 97 7d 10 f0       	push   $0xf0107d97
f010231b:	68 c2 03 00 00       	push   $0x3c2
f0102320:	68 71 7d 10 f0       	push   $0xf0107d71
f0102325:	e8 3e dd ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f010232a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010232f:	74 19                	je     f010234a <mem_init+0x9ed>
f0102331:	68 7e 7f 10 f0       	push   $0xf0107f7e
f0102336:	68 97 7d 10 f0       	push   $0xf0107d97
f010233b:	68 c3 03 00 00       	push   $0x3c3
f0102340:	68 71 7d 10 f0       	push   $0xf0107d71
f0102345:	e8 1e dd ff ff       	call   f0100068 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010234a:	83 ec 04             	sub    $0x4,%esp
f010234d:	6a 00                	push   $0x0
f010234f:	68 00 10 00 00       	push   $0x1000
f0102354:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010235a:	e8 6a f3 ff ff       	call   f01016c9 <pgdir_walk>
f010235f:	83 c4 10             	add    $0x10,%esp
f0102362:	f6 00 04             	testb  $0x4,(%eax)
f0102365:	75 19                	jne    f0102380 <mem_init+0xa23>
f0102367:	68 e8 77 10 f0       	push   $0xf01077e8
f010236c:	68 97 7d 10 f0       	push   $0xf0107d97
f0102371:	68 c4 03 00 00       	push   $0x3c4
f0102376:	68 71 7d 10 f0       	push   $0xf0107d71
f010237b:	e8 e8 dc ff ff       	call   f0100068 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102380:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102385:	f6 00 04             	testb  $0x4,(%eax)
f0102388:	75 19                	jne    f01023a3 <mem_init+0xa46>
f010238a:	68 8f 7f 10 f0       	push   $0xf0107f8f
f010238f:	68 97 7d 10 f0       	push   $0xf0107d97
f0102394:	68 c5 03 00 00       	push   $0x3c5
f0102399:	68 71 7d 10 f0       	push   $0xf0107d71
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
f01023b8:	68 fc 76 10 f0       	push   $0xf01076fc
f01023bd:	68 97 7d 10 f0       	push   $0xf0107d97
f01023c2:	68 c8 03 00 00       	push   $0x3c8
f01023c7:	68 71 7d 10 f0       	push   $0xf0107d71
f01023cc:	e8 97 dc ff ff       	call   f0100068 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01023d1:	83 ec 04             	sub    $0x4,%esp
f01023d4:	6a 00                	push   $0x0
f01023d6:	68 00 10 00 00       	push   $0x1000
f01023db:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01023e1:	e8 e3 f2 ff ff       	call   f01016c9 <pgdir_walk>
f01023e6:	83 c4 10             	add    $0x10,%esp
f01023e9:	f6 00 02             	testb  $0x2,(%eax)
f01023ec:	75 19                	jne    f0102407 <mem_init+0xaaa>
f01023ee:	68 1c 78 10 f0       	push   $0xf010781c
f01023f3:	68 97 7d 10 f0       	push   $0xf0107d97
f01023f8:	68 c9 03 00 00       	push   $0x3c9
f01023fd:	68 71 7d 10 f0       	push   $0xf0107d71
f0102402:	e8 61 dc ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102407:	83 ec 04             	sub    $0x4,%esp
f010240a:	6a 00                	push   $0x0
f010240c:	68 00 10 00 00       	push   $0x1000
f0102411:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102417:	e8 ad f2 ff ff       	call   f01016c9 <pgdir_walk>
f010241c:	83 c4 10             	add    $0x10,%esp
f010241f:	f6 00 04             	testb  $0x4,(%eax)
f0102422:	74 19                	je     f010243d <mem_init+0xae0>
f0102424:	68 50 78 10 f0       	push   $0xf0107850
f0102429:	68 97 7d 10 f0       	push   $0xf0107d97
f010242e:	68 ca 03 00 00       	push   $0x3ca
f0102433:	68 71 7d 10 f0       	push   $0xf0107d71
f0102438:	e8 2b dc ff ff       	call   f0100068 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010243d:	6a 02                	push   $0x2
f010243f:	68 00 00 40 00       	push   $0x400000
f0102444:	57                   	push   %edi
f0102445:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010244b:	e8 5d f4 ff ff       	call   f01018ad <page_insert>
f0102450:	83 c4 10             	add    $0x10,%esp
f0102453:	85 c0                	test   %eax,%eax
f0102455:	78 19                	js     f0102470 <mem_init+0xb13>
f0102457:	68 88 78 10 f0       	push   $0xf0107888
f010245c:	68 97 7d 10 f0       	push   $0xf0107d97
f0102461:	68 cd 03 00 00       	push   $0x3cd
f0102466:	68 71 7d 10 f0       	push   $0xf0107d71
f010246b:	e8 f8 db ff ff       	call   f0100068 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102470:	6a 02                	push   $0x2
f0102472:	68 00 10 00 00       	push   $0x1000
f0102477:	56                   	push   %esi
f0102478:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010247e:	e8 2a f4 ff ff       	call   f01018ad <page_insert>
f0102483:	83 c4 10             	add    $0x10,%esp
f0102486:	85 c0                	test   %eax,%eax
f0102488:	74 19                	je     f01024a3 <mem_init+0xb46>
f010248a:	68 c0 78 10 f0       	push   $0xf01078c0
f010248f:	68 97 7d 10 f0       	push   $0xf0107d97
f0102494:	68 d0 03 00 00       	push   $0x3d0
f0102499:	68 71 7d 10 f0       	push   $0xf0107d71
f010249e:	e8 c5 db ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024a3:	83 ec 04             	sub    $0x4,%esp
f01024a6:	6a 00                	push   $0x0
f01024a8:	68 00 10 00 00       	push   $0x1000
f01024ad:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01024b3:	e8 11 f2 ff ff       	call   f01016c9 <pgdir_walk>
f01024b8:	83 c4 10             	add    $0x10,%esp
f01024bb:	f6 00 04             	testb  $0x4,(%eax)
f01024be:	74 19                	je     f01024d9 <mem_init+0xb7c>
f01024c0:	68 50 78 10 f0       	push   $0xf0107850
f01024c5:	68 97 7d 10 f0       	push   $0xf0107d97
f01024ca:	68 d1 03 00 00       	push   $0x3d1
f01024cf:	68 71 7d 10 f0       	push   $0xf0107d71
f01024d4:	e8 8f db ff ff       	call   f0100068 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01024d9:	ba 00 00 00 00       	mov    $0x0,%edx
f01024de:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01024e3:	e8 f3 ec ff ff       	call   f01011db <check_va2pa>
f01024e8:	89 f2                	mov    %esi,%edx
f01024ea:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f01024f0:	c1 fa 03             	sar    $0x3,%edx
f01024f3:	c1 e2 0c             	shl    $0xc,%edx
f01024f6:	39 d0                	cmp    %edx,%eax
f01024f8:	74 19                	je     f0102513 <mem_init+0xbb6>
f01024fa:	68 fc 78 10 f0       	push   $0xf01078fc
f01024ff:	68 97 7d 10 f0       	push   $0xf0107d97
f0102504:	68 d4 03 00 00       	push   $0x3d4
f0102509:	68 71 7d 10 f0       	push   $0xf0107d71
f010250e:	e8 55 db ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102513:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102518:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010251d:	e8 b9 ec ff ff       	call   f01011db <check_va2pa>
f0102522:	89 f2                	mov    %esi,%edx
f0102524:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f010252a:	c1 fa 03             	sar    $0x3,%edx
f010252d:	c1 e2 0c             	shl    $0xc,%edx
f0102530:	39 d0                	cmp    %edx,%eax
f0102532:	74 19                	je     f010254d <mem_init+0xbf0>
f0102534:	68 28 79 10 f0       	push   $0xf0107928
f0102539:	68 97 7d 10 f0       	push   $0xf0107d97
f010253e:	68 d5 03 00 00       	push   $0x3d5
f0102543:	68 71 7d 10 f0       	push   $0xf0107d71
f0102548:	e8 1b db ff ff       	call   f0100068 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010254d:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102552:	74 19                	je     f010256d <mem_init+0xc10>
f0102554:	68 a5 7f 10 f0       	push   $0xf0107fa5
f0102559:	68 97 7d 10 f0       	push   $0xf0107d97
f010255e:	68 d7 03 00 00       	push   $0x3d7
f0102563:	68 71 7d 10 f0       	push   $0xf0107d71
f0102568:	e8 fb da ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f010256d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102572:	74 19                	je     f010258d <mem_init+0xc30>
f0102574:	68 b6 7f 10 f0       	push   $0xf0107fb6
f0102579:	68 97 7d 10 f0       	push   $0xf0107d97
f010257e:	68 d8 03 00 00       	push   $0x3d8
f0102583:	68 71 7d 10 f0       	push   $0xf0107d71
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
f01025a2:	68 58 79 10 f0       	push   $0xf0107958
f01025a7:	68 97 7d 10 f0       	push   $0xf0107d97
f01025ac:	68 db 03 00 00       	push   $0x3db
f01025b1:	68 71 7d 10 f0       	push   $0xf0107d71
f01025b6:	e8 ad da ff ff       	call   f0100068 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01025bb:	83 ec 08             	sub    $0x8,%esp
f01025be:	6a 00                	push   $0x0
f01025c0:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01025c6:	e8 95 f2 ff ff       	call   f0101860 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025cb:	ba 00 00 00 00       	mov    $0x0,%edx
f01025d0:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01025d5:	e8 01 ec ff ff       	call   f01011db <check_va2pa>
f01025da:	83 c4 10             	add    $0x10,%esp
f01025dd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025e0:	74 19                	je     f01025fb <mem_init+0xc9e>
f01025e2:	68 7c 79 10 f0       	push   $0xf010797c
f01025e7:	68 97 7d 10 f0       	push   $0xf0107d97
f01025ec:	68 df 03 00 00       	push   $0x3df
f01025f1:	68 71 7d 10 f0       	push   $0xf0107d71
f01025f6:	e8 6d da ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025fb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102600:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102605:	e8 d1 eb ff ff       	call   f01011db <check_va2pa>
f010260a:	89 f2                	mov    %esi,%edx
f010260c:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0102612:	c1 fa 03             	sar    $0x3,%edx
f0102615:	c1 e2 0c             	shl    $0xc,%edx
f0102618:	39 d0                	cmp    %edx,%eax
f010261a:	74 19                	je     f0102635 <mem_init+0xcd8>
f010261c:	68 28 79 10 f0       	push   $0xf0107928
f0102621:	68 97 7d 10 f0       	push   $0xf0107d97
f0102626:	68 e0 03 00 00       	push   $0x3e0
f010262b:	68 71 7d 10 f0       	push   $0xf0107d71
f0102630:	e8 33 da ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 1);
f0102635:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010263a:	74 19                	je     f0102655 <mem_init+0xcf8>
f010263c:	68 5c 7f 10 f0       	push   $0xf0107f5c
f0102641:	68 97 7d 10 f0       	push   $0xf0107d97
f0102646:	68 e1 03 00 00       	push   $0x3e1
f010264b:	68 71 7d 10 f0       	push   $0xf0107d71
f0102650:	e8 13 da ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f0102655:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010265a:	74 19                	je     f0102675 <mem_init+0xd18>
f010265c:	68 b6 7f 10 f0       	push   $0xf0107fb6
f0102661:	68 97 7d 10 f0       	push   $0xf0107d97
f0102666:	68 e2 03 00 00       	push   $0x3e2
f010266b:	68 71 7d 10 f0       	push   $0xf0107d71
f0102670:	e8 f3 d9 ff ff       	call   f0100068 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102675:	83 ec 08             	sub    $0x8,%esp
f0102678:	68 00 10 00 00       	push   $0x1000
f010267d:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102683:	e8 d8 f1 ff ff       	call   f0101860 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102688:	ba 00 00 00 00       	mov    $0x0,%edx
f010268d:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102692:	e8 44 eb ff ff       	call   f01011db <check_va2pa>
f0102697:	83 c4 10             	add    $0x10,%esp
f010269a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010269d:	74 19                	je     f01026b8 <mem_init+0xd5b>
f010269f:	68 7c 79 10 f0       	push   $0xf010797c
f01026a4:	68 97 7d 10 f0       	push   $0xf0107d97
f01026a9:	68 e6 03 00 00       	push   $0x3e6
f01026ae:	68 71 7d 10 f0       	push   $0xf0107d71
f01026b3:	e8 b0 d9 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01026b8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01026bd:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01026c2:	e8 14 eb ff ff       	call   f01011db <check_va2pa>
f01026c7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026ca:	74 19                	je     f01026e5 <mem_init+0xd88>
f01026cc:	68 a0 79 10 f0       	push   $0xf01079a0
f01026d1:	68 97 7d 10 f0       	push   $0xf0107d97
f01026d6:	68 e7 03 00 00       	push   $0x3e7
f01026db:	68 71 7d 10 f0       	push   $0xf0107d71
f01026e0:	e8 83 d9 ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 0);
f01026e5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026ea:	74 19                	je     f0102705 <mem_init+0xda8>
f01026ec:	68 c7 7f 10 f0       	push   $0xf0107fc7
f01026f1:	68 97 7d 10 f0       	push   $0xf0107d97
f01026f6:	68 e8 03 00 00       	push   $0x3e8
f01026fb:	68 71 7d 10 f0       	push   $0xf0107d71
f0102700:	e8 63 d9 ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f0102705:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010270a:	74 19                	je     f0102725 <mem_init+0xdc8>
f010270c:	68 b6 7f 10 f0       	push   $0xf0107fb6
f0102711:	68 97 7d 10 f0       	push   $0xf0107d97
f0102716:	68 e9 03 00 00       	push   $0x3e9
f010271b:	68 71 7d 10 f0       	push   $0xf0107d71
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
f010273a:	68 c8 79 10 f0       	push   $0xf01079c8
f010273f:	68 97 7d 10 f0       	push   $0xf0107d97
f0102744:	68 ec 03 00 00       	push   $0x3ec
f0102749:	68 71 7d 10 f0       	push   $0xf0107d71
f010274e:	e8 15 d9 ff ff       	call   f0100068 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102753:	83 ec 0c             	sub    $0xc,%esp
f0102756:	6a 00                	push   $0x0
f0102758:	e8 a4 ee ff ff       	call   f0101601 <page_alloc>
f010275d:	83 c4 10             	add    $0x10,%esp
f0102760:	85 c0                	test   %eax,%eax
f0102762:	74 19                	je     f010277d <mem_init+0xe20>
f0102764:	68 0a 7f 10 f0       	push   $0xf0107f0a
f0102769:	68 97 7d 10 f0       	push   $0xf0107d97
f010276e:	68 ef 03 00 00       	push   $0x3ef
f0102773:	68 71 7d 10 f0       	push   $0xf0107d71
f0102778:	e8 eb d8 ff ff       	call   f0100068 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010277d:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102782:	8b 08                	mov    (%eax),%ecx
f0102784:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010278a:	89 fa                	mov    %edi,%edx
f010278c:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0102792:	c1 fa 03             	sar    $0x3,%edx
f0102795:	c1 e2 0c             	shl    $0xc,%edx
f0102798:	39 d1                	cmp    %edx,%ecx
f010279a:	74 19                	je     f01027b5 <mem_init+0xe58>
f010279c:	68 a4 76 10 f0       	push   $0xf01076a4
f01027a1:	68 97 7d 10 f0       	push   $0xf0107d97
f01027a6:	68 f2 03 00 00       	push   $0x3f2
f01027ab:	68 71 7d 10 f0       	push   $0xf0107d71
f01027b0:	e8 b3 d8 ff ff       	call   f0100068 <_panic>
	kern_pgdir[0] = 0;
f01027b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01027bb:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01027c0:	74 19                	je     f01027db <mem_init+0xe7e>
f01027c2:	68 6d 7f 10 f0       	push   $0xf0107f6d
f01027c7:	68 97 7d 10 f0       	push   $0xf0107d97
f01027cc:	68 f4 03 00 00       	push   $0x3f4
f01027d1:	68 71 7d 10 f0       	push   $0xf0107d71
f01027d6:	e8 8d d8 ff ff       	call   f0100068 <_panic>
	pp0->pp_ref = 0;

	kern_pgdir[PDX(va)] = 0;
f01027db:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01027e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01027e6:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
f01027ec:	89 f8                	mov    %edi,%eax
f01027ee:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01027f4:	c1 f8 03             	sar    $0x3,%eax
f01027f7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027fa:	89 c2                	mov    %eax,%edx
f01027fc:	c1 ea 0c             	shr    $0xc,%edx
f01027ff:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102805:	72 12                	jb     f0102819 <mem_init+0xebc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102807:	50                   	push   %eax
f0102808:	68 08 6a 10 f0       	push   $0xf0106a08
f010280d:	6a 58                	push   $0x58
f010280f:	68 7d 7d 10 f0       	push   $0xf0107d7d
f0102814:	e8 4f d8 ff ff       	call   f0100068 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102819:	83 ec 04             	sub    $0x4,%esp
f010281c:	68 00 10 00 00       	push   $0x1000
f0102821:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102826:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010282b:	50                   	push   %eax
f010282c:	e8 a8 34 00 00       	call   f0105cd9 <memset>
	page_free(pp0);
f0102831:	89 3c 24             	mov    %edi,(%esp)
f0102834:	e8 52 ee ff ff       	call   f010168b <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102839:	83 c4 0c             	add    $0xc,%esp
f010283c:	6a 01                	push   $0x1
f010283e:	6a 00                	push   $0x0
f0102840:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102846:	e8 7e ee ff ff       	call   f01016c9 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010284b:	89 fa                	mov    %edi,%edx
f010284d:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
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
f0102861:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0102867:	72 12                	jb     f010287b <mem_init+0xf1e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102869:	52                   	push   %edx
f010286a:	68 08 6a 10 f0       	push   $0xf0106a08
f010286f:	6a 58                	push   $0x58
f0102871:	68 7d 7d 10 f0       	push   $0xf0107d7d
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
f010289e:	68 d8 7f 10 f0       	push   $0xf0107fd8
f01028a3:	68 97 7d 10 f0       	push   $0xf0107d97
f01028a8:	68 00 04 00 00       	push   $0x400
f01028ad:	68 71 7d 10 f0       	push   $0xf0107d71
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
f01028be:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01028c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01028c9:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01028cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028d2:	a3 30 12 21 f0       	mov    %eax,0xf0211230

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
f010292a:	68 ec 79 10 f0       	push   $0xf01079ec
f010292f:	68 97 7d 10 f0       	push   $0xf0107d97
f0102934:	68 10 04 00 00       	push   $0x410
f0102939:	68 71 7d 10 f0       	push   $0xf0107d71
f010293e:	e8 25 d7 ff ff       	call   f0100068 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102943:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102949:	76 0e                	jbe    f0102959 <mem_init+0xffc>
f010294b:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102951:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102957:	76 19                	jbe    f0102972 <mem_init+0x1015>
f0102959:	68 14 7a 10 f0       	push   $0xf0107a14
f010295e:	68 97 7d 10 f0       	push   $0xf0107d97
f0102963:	68 11 04 00 00       	push   $0x411
f0102968:	68 71 7d 10 f0       	push   $0xf0107d71
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
f010297e:	68 3c 7a 10 f0       	push   $0xf0107a3c
f0102983:	68 97 7d 10 f0       	push   $0xf0107d97
f0102988:	68 13 04 00 00       	push   $0x413
f010298d:	68 71 7d 10 f0       	push   $0xf0107d71
f0102992:	e8 d1 d6 ff ff       	call   f0100068 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102997:	39 c6                	cmp    %eax,%esi
f0102999:	73 19                	jae    f01029b4 <mem_init+0x1057>
f010299b:	68 ef 7f 10 f0       	push   $0xf0107fef
f01029a0:	68 97 7d 10 f0       	push   $0xf0107d97
f01029a5:	68 15 04 00 00       	push   $0x415
f01029aa:	68 71 7d 10 f0       	push   $0xf0107d71
f01029af:	e8 b4 d6 ff ff       	call   f0100068 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01029b4:	89 da                	mov    %ebx,%edx
f01029b6:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01029bb:	e8 1b e8 ff ff       	call   f01011db <check_va2pa>
f01029c0:	85 c0                	test   %eax,%eax
f01029c2:	74 19                	je     f01029dd <mem_init+0x1080>
f01029c4:	68 64 7a 10 f0       	push   $0xf0107a64
f01029c9:	68 97 7d 10 f0       	push   $0xf0107d97
f01029ce:	68 17 04 00 00       	push   $0x417
f01029d3:	68 71 7d 10 f0       	push   $0xf0107d71
f01029d8:	e8 8b d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01029dd:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
f01029e3:	89 fa                	mov    %edi,%edx
f01029e5:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01029ea:	e8 ec e7 ff ff       	call   f01011db <check_va2pa>
f01029ef:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01029f4:	74 19                	je     f0102a0f <mem_init+0x10b2>
f01029f6:	68 88 7a 10 f0       	push   $0xf0107a88
f01029fb:	68 97 7d 10 f0       	push   $0xf0107d97
f0102a00:	68 18 04 00 00       	push   $0x418
f0102a05:	68 71 7d 10 f0       	push   $0xf0107d71
f0102a0a:	e8 59 d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102a0f:	89 f2                	mov    %esi,%edx
f0102a11:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102a16:	e8 c0 e7 ff ff       	call   f01011db <check_va2pa>
f0102a1b:	85 c0                	test   %eax,%eax
f0102a1d:	74 19                	je     f0102a38 <mem_init+0x10db>
f0102a1f:	68 b8 7a 10 f0       	push   $0xf0107ab8
f0102a24:	68 97 7d 10 f0       	push   $0xf0107d97
f0102a29:	68 19 04 00 00       	push   $0x419
f0102a2e:	68 71 7d 10 f0       	push   $0xf0107d71
f0102a33:	e8 30 d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a38:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102a3e:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102a43:	e8 93 e7 ff ff       	call   f01011db <check_va2pa>
f0102a48:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a4b:	74 19                	je     f0102a66 <mem_init+0x1109>
f0102a4d:	68 dc 7a 10 f0       	push   $0xf0107adc
f0102a52:	68 97 7d 10 f0       	push   $0xf0107d97
f0102a57:	68 1a 04 00 00       	push   $0x41a
f0102a5c:	68 71 7d 10 f0       	push   $0xf0107d71
f0102a61:	e8 02 d6 ff ff       	call   f0100068 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102a66:	83 ec 04             	sub    $0x4,%esp
f0102a69:	6a 00                	push   $0x0
f0102a6b:	53                   	push   %ebx
f0102a6c:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102a72:	e8 52 ec ff ff       	call   f01016c9 <pgdir_walk>
f0102a77:	83 c4 10             	add    $0x10,%esp
f0102a7a:	f6 00 1a             	testb  $0x1a,(%eax)
f0102a7d:	75 19                	jne    f0102a98 <mem_init+0x113b>
f0102a7f:	68 08 7b 10 f0       	push   $0xf0107b08
f0102a84:	68 97 7d 10 f0       	push   $0xf0107d97
f0102a89:	68 1c 04 00 00       	push   $0x41c
f0102a8e:	68 71 7d 10 f0       	push   $0xf0107d71
f0102a93:	e8 d0 d5 ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a98:	83 ec 04             	sub    $0x4,%esp
f0102a9b:	6a 00                	push   $0x0
f0102a9d:	53                   	push   %ebx
f0102a9e:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102aa4:	e8 20 ec ff ff       	call   f01016c9 <pgdir_walk>
f0102aa9:	83 c4 10             	add    $0x10,%esp
f0102aac:	f6 00 04             	testb  $0x4,(%eax)
f0102aaf:	74 19                	je     f0102aca <mem_init+0x116d>
f0102ab1:	68 4c 7b 10 f0       	push   $0xf0107b4c
f0102ab6:	68 97 7d 10 f0       	push   $0xf0107d97
f0102abb:	68 1d 04 00 00       	push   $0x41d
f0102ac0:	68 71 7d 10 f0       	push   $0xf0107d71
f0102ac5:	e8 9e d5 ff ff       	call   f0100068 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102aca:	83 ec 04             	sub    $0x4,%esp
f0102acd:	6a 00                	push   $0x0
f0102acf:	53                   	push   %ebx
f0102ad0:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102ad6:	e8 ee eb ff ff       	call   f01016c9 <pgdir_walk>
f0102adb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102ae1:	83 c4 0c             	add    $0xc,%esp
f0102ae4:	6a 00                	push   $0x0
f0102ae6:	57                   	push   %edi
f0102ae7:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102aed:	e8 d7 eb ff ff       	call   f01016c9 <pgdir_walk>
f0102af2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102af8:	83 c4 0c             	add    $0xc,%esp
f0102afb:	6a 00                	push   $0x0
f0102afd:	56                   	push   %esi
f0102afe:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102b04:	e8 c0 eb ff ff       	call   f01016c9 <pgdir_walk>
f0102b09:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102b0f:	c7 04 24 01 80 10 f0 	movl   $0xf0108001,(%esp)
f0102b16:	e8 fa 11 00 00       	call   f0103d15 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102b1b:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
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
f0102b2b:	68 e4 69 10 f0       	push   $0xf01069e4
f0102b30:	68 b9 00 00 00       	push   $0xb9
f0102b35:	68 71 7d 10 f0       	push   $0xf0107d71
f0102b3a:	e8 29 d5 ff ff       	call   f0100068 <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102b3f:	8b 15 88 1e 21 f0    	mov    0xf0211e88,%edx
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
f0102b62:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102b67:	e8 f4 eb ff ff       	call   f0101760 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    boot_map_region(kern_pgdir,
f0102b6c:	a1 3c 12 21 f0       	mov    0xf021123c,%eax
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
f0102b7c:	68 e4 69 10 f0       	push   $0xf01069e4
f0102b81:	68 c6 00 00 00       	push   $0xc6
f0102b86:	68 71 7d 10 f0       	push   $0xf0107d71
f0102b8b:	e8 d8 d4 ff ff       	call   f0100068 <_panic>
f0102b90:	83 ec 08             	sub    $0x8,%esp
f0102b93:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102b95:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b9a:	50                   	push   %eax
f0102b9b:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102ba0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102ba5:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
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
f0102bbf:	68 e4 69 10 f0       	push   $0xf01069e4
f0102bc4:	68 d7 00 00 00       	push   $0xd7
f0102bc9:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0102be7:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
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
f0102c02:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102c07:	e8 54 eb ff ff       	call   f0101760 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c0c:	83 c4 10             	add    $0x10,%esp
f0102c0f:	b8 00 30 21 f0       	mov    $0xf0213000,%eax
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
f0102c2d:	b8 00 30 21 f0       	mov    $0xf0213000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c32:	50                   	push   %eax
f0102c33:	68 e4 69 10 f0       	push   $0xf01069e4
f0102c38:	68 24 01 00 00       	push   $0x124
f0102c3d:	68 71 7d 10 f0       	push   $0xf0107d71
f0102c42:	e8 21 d4 ff ff       	call   f0100068 <_panic>
f0102c47:	83 ec 08             	sub    $0x8,%esp
f0102c4a:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f0102c4c:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102c52:	50                   	push   %eax
f0102c53:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102c58:	89 f2                	mov    %esi,%edx
f0102c5a:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
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
f0102c7b:	8b 35 8c 1e 21 f0    	mov    0xf0211e8c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102c81:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0102c86:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102c8d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102c93:	74 63                	je     f0102cf8 <mem_init+0x139b>
f0102c95:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102c9a:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102ca0:	89 f0                	mov    %esi,%eax
f0102ca2:	e8 34 e5 ff ff       	call   f01011db <check_va2pa>
f0102ca7:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cad:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102cb3:	77 15                	ja     f0102cca <mem_init+0x136d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cb5:	52                   	push   %edx
f0102cb6:	68 e4 69 10 f0       	push   $0xf01069e4
f0102cbb:	68 40 03 00 00       	push   $0x340
f0102cc0:	68 71 7d 10 f0       	push   $0xf0107d71
f0102cc5:	e8 9e d3 ff ff       	call   f0100068 <_panic>
f0102cca:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0102cd1:	39 d0                	cmp    %edx,%eax
f0102cd3:	74 19                	je     f0102cee <mem_init+0x1391>
f0102cd5:	68 80 7b 10 f0       	push   $0xf0107b80
f0102cda:	68 97 7d 10 f0       	push   $0xf0107d97
f0102cdf:	68 40 03 00 00       	push   $0x340
f0102ce4:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0102d0a:	8b 15 3c 12 21 f0    	mov    0xf021123c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d10:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d16:	77 15                	ja     f0102d2d <mem_init+0x13d0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d18:	52                   	push   %edx
f0102d19:	68 e4 69 10 f0       	push   $0xf01069e4
f0102d1e:	68 45 03 00 00       	push   $0x345
f0102d23:	68 71 7d 10 f0       	push   $0xf0107d71
f0102d28:	e8 3b d3 ff ff       	call   f0100068 <_panic>
f0102d2d:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0102d34:	39 d0                	cmp    %edx,%eax
f0102d36:	74 19                	je     f0102d51 <mem_init+0x13f4>
f0102d38:	68 b4 7b 10 f0       	push   $0xf0107bb4
f0102d3d:	68 97 7d 10 f0       	push   $0xf0107d97
f0102d42:	68 45 03 00 00       	push   $0x345
f0102d47:	68 71 7d 10 f0       	push   $0xf0107d71
f0102d4c:	e8 17 d3 ff ff       	call   f0100068 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102d51:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d57:	81 fb 00 f0 01 00    	cmp    $0x1f000,%ebx
f0102d5d:	75 9e                	jne    f0102cfd <mem_init+0x13a0>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d5f:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0102d64:	c1 e0 0c             	shl    $0xc,%eax
f0102d67:	74 41                	je     f0102daa <mem_init+0x144d>
f0102d69:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102d6e:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102d74:	89 f0                	mov    %esi,%eax
f0102d76:	e8 60 e4 ff ff       	call   f01011db <check_va2pa>
f0102d7b:	39 c3                	cmp    %eax,%ebx
f0102d7d:	74 19                	je     f0102d98 <mem_init+0x143b>
f0102d7f:	68 e8 7b 10 f0       	push   $0xf0107be8
f0102d84:	68 97 7d 10 f0       	push   $0xf0107d97
f0102d89:	68 49 03 00 00       	push   $0x349
f0102d8e:	68 71 7d 10 f0       	push   $0xf0107d71
f0102d93:	e8 d0 d2 ff ff       	call   f0100068 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d98:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d9e:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0102da3:	c1 e0 0c             	shl    $0xc,%eax
f0102da6:	39 c3                	cmp    %eax,%ebx
f0102da8:	72 c4                	jb     f0102d6e <mem_init+0x1411>
f0102daa:	c7 45 d0 00 30 21 f0 	movl   $0xf0213000,-0x30(%ebp)
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
f0102ddc:	68 e4 69 10 f0       	push   $0xf01069e4
f0102de1:	68 51 03 00 00       	push   $0x351
f0102de6:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0102e07:	68 10 7c 10 f0       	push   $0xf0107c10
f0102e0c:	68 97 7d 10 f0       	push   $0xf0107d97
f0102e11:	68 51 03 00 00       	push   $0x351
f0102e16:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0102e4b:	68 58 7c 10 f0       	push   $0xf0107c58
f0102e50:	68 97 7d 10 f0       	push   $0xf0107d97
f0102e55:	68 53 03 00 00       	push   $0x353
f0102e5a:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0102ea4:	68 1a 80 10 f0       	push   $0xf010801a
f0102ea9:	68 97 7d 10 f0       	push   $0xf0107d97
f0102eae:	68 5e 03 00 00       	push   $0x35e
f0102eb3:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0102ecc:	68 1a 80 10 f0       	push   $0xf010801a
f0102ed1:	68 97 7d 10 f0       	push   $0xf0107d97
f0102ed6:	68 62 03 00 00       	push   $0x362
f0102edb:	68 71 7d 10 f0       	push   $0xf0107d71
f0102ee0:	e8 83 d1 ff ff       	call   f0100068 <_panic>
				assert(pgdir[i] & PTE_W);
f0102ee5:	f6 c2 02             	test   $0x2,%dl
f0102ee8:	75 38                	jne    f0102f22 <mem_init+0x15c5>
f0102eea:	68 2b 80 10 f0       	push   $0xf010802b
f0102eef:	68 97 7d 10 f0       	push   $0xf0107d97
f0102ef4:	68 63 03 00 00       	push   $0x363
f0102ef9:	68 71 7d 10 f0       	push   $0xf0107d71
f0102efe:	e8 65 d1 ff ff       	call   f0100068 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102f03:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102f07:	74 19                	je     f0102f22 <mem_init+0x15c5>
f0102f09:	68 3c 80 10 f0       	push   $0xf010803c
f0102f0e:	68 97 7d 10 f0       	push   $0xf0107d97
f0102f13:	68 65 03 00 00       	push   $0x365
f0102f18:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0102f31:	68 7c 7c 10 f0       	push   $0xf0107c7c
f0102f36:	e8 da 0d 00 00       	call   f0103d15 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102f3b:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
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
f0102f4b:	68 e4 69 10 f0       	push   $0xf01069e4
f0102f50:	68 f9 00 00 00       	push   $0xf9
f0102f55:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0102f92:	68 5f 7e 10 f0       	push   $0xf0107e5f
f0102f97:	68 97 7d 10 f0       	push   $0xf0107d97
f0102f9c:	68 32 04 00 00       	push   $0x432
f0102fa1:	68 71 7d 10 f0       	push   $0xf0107d71
f0102fa6:	e8 bd d0 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0102fab:	83 ec 0c             	sub    $0xc,%esp
f0102fae:	6a 00                	push   $0x0
f0102fb0:	e8 4c e6 ff ff       	call   f0101601 <page_alloc>
f0102fb5:	89 c7                	mov    %eax,%edi
f0102fb7:	83 c4 10             	add    $0x10,%esp
f0102fba:	85 c0                	test   %eax,%eax
f0102fbc:	75 19                	jne    f0102fd7 <mem_init+0x167a>
f0102fbe:	68 75 7e 10 f0       	push   $0xf0107e75
f0102fc3:	68 97 7d 10 f0       	push   $0xf0107d97
f0102fc8:	68 33 04 00 00       	push   $0x433
f0102fcd:	68 71 7d 10 f0       	push   $0xf0107d71
f0102fd2:	e8 91 d0 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0102fd7:	83 ec 0c             	sub    $0xc,%esp
f0102fda:	6a 00                	push   $0x0
f0102fdc:	e8 20 e6 ff ff       	call   f0101601 <page_alloc>
f0102fe1:	89 c3                	mov    %eax,%ebx
f0102fe3:	83 c4 10             	add    $0x10,%esp
f0102fe6:	85 c0                	test   %eax,%eax
f0102fe8:	75 19                	jne    f0103003 <mem_init+0x16a6>
f0102fea:	68 8b 7e 10 f0       	push   $0xf0107e8b
f0102fef:	68 97 7d 10 f0       	push   $0xf0107d97
f0102ff4:	68 34 04 00 00       	push   $0x434
f0102ff9:	68 71 7d 10 f0       	push   $0xf0107d71
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
f010300e:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
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
f0103022:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0103028:	72 12                	jb     f010303c <mem_init+0x16df>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010302a:	50                   	push   %eax
f010302b:	68 08 6a 10 f0       	push   $0xf0106a08
f0103030:	6a 58                	push   $0x58
f0103032:	68 7d 7d 10 f0       	push   $0xf0107d7d
f0103037:	e8 2c d0 ff ff       	call   f0100068 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010303c:	83 ec 04             	sub    $0x4,%esp
f010303f:	68 00 10 00 00       	push   $0x1000
f0103044:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103046:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010304b:	50                   	push   %eax
f010304c:	e8 88 2c 00 00       	call   f0105cd9 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103051:	89 d8                	mov    %ebx,%eax
f0103053:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
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
f0103067:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f010306d:	72 12                	jb     f0103081 <mem_init+0x1724>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010306f:	50                   	push   %eax
f0103070:	68 08 6a 10 f0       	push   $0xf0106a08
f0103075:	6a 58                	push   $0x58
f0103077:	68 7d 7d 10 f0       	push   $0xf0107d7d
f010307c:	e8 e7 cf ff ff       	call   f0100068 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103081:	83 ec 04             	sub    $0x4,%esp
f0103084:	68 00 10 00 00       	push   $0x1000
f0103089:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f010308b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103090:	50                   	push   %eax
f0103091:	e8 43 2c 00 00       	call   f0105cd9 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103096:	6a 02                	push   $0x2
f0103098:	68 00 10 00 00       	push   $0x1000
f010309d:	57                   	push   %edi
f010309e:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01030a4:	e8 04 e8 ff ff       	call   f01018ad <page_insert>
	assert(pp1->pp_ref == 1);
f01030a9:	83 c4 20             	add    $0x20,%esp
f01030ac:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01030b1:	74 19                	je     f01030cc <mem_init+0x176f>
f01030b3:	68 5c 7f 10 f0       	push   $0xf0107f5c
f01030b8:	68 97 7d 10 f0       	push   $0xf0107d97
f01030bd:	68 39 04 00 00       	push   $0x439
f01030c2:	68 71 7d 10 f0       	push   $0xf0107d71
f01030c7:	e8 9c cf ff ff       	call   f0100068 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01030cc:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01030d3:	01 01 01 
f01030d6:	74 19                	je     f01030f1 <mem_init+0x1794>
f01030d8:	68 9c 7c 10 f0       	push   $0xf0107c9c
f01030dd:	68 97 7d 10 f0       	push   $0xf0107d97
f01030e2:	68 3a 04 00 00       	push   $0x43a
f01030e7:	68 71 7d 10 f0       	push   $0xf0107d71
f01030ec:	e8 77 cf ff ff       	call   f0100068 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01030f1:	6a 02                	push   $0x2
f01030f3:	68 00 10 00 00       	push   $0x1000
f01030f8:	53                   	push   %ebx
f01030f9:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01030ff:	e8 a9 e7 ff ff       	call   f01018ad <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103104:	83 c4 10             	add    $0x10,%esp
f0103107:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010310e:	02 02 02 
f0103111:	74 19                	je     f010312c <mem_init+0x17cf>
f0103113:	68 c0 7c 10 f0       	push   $0xf0107cc0
f0103118:	68 97 7d 10 f0       	push   $0xf0107d97
f010311d:	68 3c 04 00 00       	push   $0x43c
f0103122:	68 71 7d 10 f0       	push   $0xf0107d71
f0103127:	e8 3c cf ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f010312c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103131:	74 19                	je     f010314c <mem_init+0x17ef>
f0103133:	68 7e 7f 10 f0       	push   $0xf0107f7e
f0103138:	68 97 7d 10 f0       	push   $0xf0107d97
f010313d:	68 3d 04 00 00       	push   $0x43d
f0103142:	68 71 7d 10 f0       	push   $0xf0107d71
f0103147:	e8 1c cf ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 0);
f010314c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103151:	74 19                	je     f010316c <mem_init+0x180f>
f0103153:	68 c7 7f 10 f0       	push   $0xf0107fc7
f0103158:	68 97 7d 10 f0       	push   $0xf0107d97
f010315d:	68 3e 04 00 00       	push   $0x43e
f0103162:	68 71 7d 10 f0       	push   $0xf0107d71
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
f0103178:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f010317e:	c1 f8 03             	sar    $0x3,%eax
f0103181:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103184:	89 c2                	mov    %eax,%edx
f0103186:	c1 ea 0c             	shr    $0xc,%edx
f0103189:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f010318f:	72 12                	jb     f01031a3 <mem_init+0x1846>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103191:	50                   	push   %eax
f0103192:	68 08 6a 10 f0       	push   $0xf0106a08
f0103197:	6a 58                	push   $0x58
f0103199:	68 7d 7d 10 f0       	push   $0xf0107d7d
f010319e:	e8 c5 ce ff ff       	call   f0100068 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01031a3:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01031aa:	03 03 03 
f01031ad:	74 19                	je     f01031c8 <mem_init+0x186b>
f01031af:	68 e4 7c 10 f0       	push   $0xf0107ce4
f01031b4:	68 97 7d 10 f0       	push   $0xf0107d97
f01031b9:	68 40 04 00 00       	push   $0x440
f01031be:	68 71 7d 10 f0       	push   $0xf0107d71
f01031c3:	e8 a0 ce ff ff       	call   f0100068 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01031c8:	83 ec 08             	sub    $0x8,%esp
f01031cb:	68 00 10 00 00       	push   $0x1000
f01031d0:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01031d6:	e8 85 e6 ff ff       	call   f0101860 <page_remove>
	assert(pp2->pp_ref == 0);
f01031db:	83 c4 10             	add    $0x10,%esp
f01031de:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01031e3:	74 19                	je     f01031fe <mem_init+0x18a1>
f01031e5:	68 b6 7f 10 f0       	push   $0xf0107fb6
f01031ea:	68 97 7d 10 f0       	push   $0xf0107d97
f01031ef:	68 42 04 00 00       	push   $0x442
f01031f4:	68 71 7d 10 f0       	push   $0xf0107d71
f01031f9:	e8 6a ce ff ff       	call   f0100068 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01031fe:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0103203:	8b 08                	mov    (%eax),%ecx
f0103205:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010320b:	89 f2                	mov    %esi,%edx
f010320d:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0103213:	c1 fa 03             	sar    $0x3,%edx
f0103216:	c1 e2 0c             	shl    $0xc,%edx
f0103219:	39 d1                	cmp    %edx,%ecx
f010321b:	74 19                	je     f0103236 <mem_init+0x18d9>
f010321d:	68 a4 76 10 f0       	push   $0xf01076a4
f0103222:	68 97 7d 10 f0       	push   $0xf0107d97
f0103227:	68 45 04 00 00       	push   $0x445
f010322c:	68 71 7d 10 f0       	push   $0xf0107d71
f0103231:	e8 32 ce ff ff       	call   f0100068 <_panic>
	kern_pgdir[0] = 0;
f0103236:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010323c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103241:	74 19                	je     f010325c <mem_init+0x18ff>
f0103243:	68 6d 7f 10 f0       	push   $0xf0107f6d
f0103248:	68 97 7d 10 f0       	push   $0xf0107d97
f010324d:	68 47 04 00 00       	push   $0x447
f0103252:	68 71 7d 10 f0       	push   $0xf0107d71
f0103257:	e8 0c ce ff ff       	call   f0100068 <_panic>
	pp0->pp_ref = 0;
f010325c:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103262:	83 ec 0c             	sub    $0xc,%esp
f0103265:	56                   	push   %esi
f0103266:	e8 20 e4 ff ff       	call   f010168b <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010326b:	c7 04 24 10 7d 10 f0 	movl   $0xf0107d10,(%esp)
f0103272:	e8 9e 0a 00 00       	call   f0103d15 <cprintf>
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
f0103284:	68 00 30 21 00       	push   $0x213000
f0103289:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010328e:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103293:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0103298:	e8 c3 e4 ff ff       	call   f0101760 <boot_map_region>
f010329d:	bb 00 b0 21 f0       	mov    $0xf021b000,%ebx
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
f010330f:	89 1d 2c 12 21 f0    	mov    %ebx,0xf021122c
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
f0103339:	89 1d 2c 12 21 f0    	mov    %ebx,0xf021122c
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
f0103399:	ff 35 2c 12 21 f0    	pushl  0xf021122c
f010339f:	ff 73 48             	pushl  0x48(%ebx)
f01033a2:	68 3c 7d 10 f0       	push   $0xf0107d3c
f01033a7:	e8 69 09 00 00       	call   f0103d15 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01033ac:	89 1c 24             	mov    %ebx,(%esp)
f01033af:	e8 40 06 00 00       	call   f01039f4 <env_destroy>
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
f01033f4:	68 4c 80 10 f0       	push   $0xf010804c
f01033f9:	68 35 01 00 00       	push   $0x135
f01033fe:	68 8f 80 10 f0       	push   $0xf010808f
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
f010341c:	68 70 80 10 f0       	push   $0xf0108070
f0103421:	68 39 01 00 00       	push   $0x139
f0103426:	68 8f 80 10 f0       	push   $0xf010808f
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
f0103451:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103454:	85 c0                	test   %eax,%eax
f0103456:	75 24                	jne    f010347c <envid2env+0x3a>
		*env_store = curenv;
f0103458:	e8 ab 2e 00 00       	call   f0106308 <cpunum>
f010345d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103464:	29 c2                	sub    %eax,%edx
f0103466:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103469:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0103470:	89 06                	mov    %eax,(%esi)
		return 0;
f0103472:	b8 00 00 00 00       	mov    $0x0,%eax
f0103477:	e9 84 00 00 00       	jmp    f0103500 <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010347c:	89 c3                	mov    %eax,%ebx
f010347e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103484:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f010348b:	c1 e3 07             	shl    $0x7,%ebx
f010348e:	29 cb                	sub    %ecx,%ebx
f0103490:	03 1d 3c 12 21 f0    	add    0xf021123c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103496:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010349a:	74 05                	je     f01034a1 <envid2env+0x5f>
f010349c:	39 43 48             	cmp    %eax,0x48(%ebx)
f010349f:	74 0d                	je     f01034ae <envid2env+0x6c>
		*env_store = 0;
f01034a1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01034a7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01034ac:	eb 52                	jmp    f0103500 <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01034ae:	84 d2                	test   %dl,%dl
f01034b0:	74 47                	je     f01034f9 <envid2env+0xb7>
f01034b2:	e8 51 2e 00 00       	call   f0106308 <cpunum>
f01034b7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01034be:	29 c2                	sub    %eax,%edx
f01034c0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01034c3:	39 1c 85 28 20 21 f0 	cmp    %ebx,-0xfdedfd8(,%eax,4)
f01034ca:	74 2d                	je     f01034f9 <envid2env+0xb7>
f01034cc:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01034cf:	e8 34 2e 00 00       	call   f0106308 <cpunum>
f01034d4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01034db:	29 c2                	sub    %eax,%edx
f01034dd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01034e0:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f01034e7:	3b 78 48             	cmp    0x48(%eax),%edi
f01034ea:	74 0d                	je     f01034f9 <envid2env+0xb7>
		*env_store = 0;
f01034ec:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01034f2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01034f7:	eb 07                	jmp    f0103500 <envid2env+0xbe>
	}

	*env_store = e;
f01034f9:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01034fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103500:	83 c4 0c             	add    $0xc,%esp
f0103503:	5b                   	pop    %ebx
f0103504:	5e                   	pop    %esi
f0103505:	5f                   	pop    %edi
f0103506:	c9                   	leave  
f0103507:	c3                   	ret    

f0103508 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103508:	55                   	push   %ebp
f0103509:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010350b:	b8 88 93 12 f0       	mov    $0xf0129388,%eax
f0103510:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103513:	b8 23 00 00 00       	mov    $0x23,%eax
f0103518:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010351a:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010351c:	b0 10                	mov    $0x10,%al
f010351e:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103520:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103522:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103524:	ea 2b 35 10 f0 08 00 	ljmp   $0x8,$0xf010352b
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f010352b:	b0 00                	mov    $0x0,%al
f010352d:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103530:	c9                   	leave  
f0103531:	c3                   	ret    

f0103532 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103532:	55                   	push   %ebp
f0103533:	89 e5                	mov    %esp,%ebp
f0103535:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
f0103536:	8b 1d 3c 12 21 f0    	mov    0xf021123c,%ebx
f010353c:	89 1d 40 12 21 f0    	mov    %ebx,0xf0211240
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
f0103542:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        envs[i].env_status = ENV_FREE;
f0103549:	c7 43 54 00 00 00 00 	movl   $0x0,0x54(%ebx)
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103550:	8d 43 7c             	lea    0x7c(%ebx),%eax
f0103553:	8d 8b 00 f0 01 00    	lea    0x1f000(%ebx),%ecx
f0103559:	89 c2                	mov    %eax,%edx
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f010355b:	89 43 44             	mov    %eax,0x44(%ebx)
{
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
f010355e:	39 c8                	cmp    %ecx,%eax
f0103560:	74 1c                	je     f010357e <env_init+0x4c>
        envs[i].env_id = 0;
f0103562:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE;
f0103569:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f0103570:	83 c0 7c             	add    $0x7c,%eax
        if (i + 1 != NENV)
f0103573:	39 c8                	cmp    %ecx,%eax
f0103575:	75 0f                	jne    f0103586 <env_init+0x54>
            envs[i].env_link = envs + (i + 1);
        else 
            envs[i].env_link = NULL;
f0103577:	c7 42 44 00 00 00 00 	movl   $0x0,0x44(%edx)
    }

	// Per-CPU part of the initialization
	env_init_percpu();
f010357e:	e8 85 ff ff ff       	call   f0103508 <env_init_percpu>
}
f0103583:	5b                   	pop    %ebx
f0103584:	c9                   	leave  
f0103585:	c3                   	ret    
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0103586:	89 42 44             	mov    %eax,0x44(%edx)
f0103589:	89 c2                	mov    %eax,%edx
f010358b:	eb d5                	jmp    f0103562 <env_init+0x30>

f010358d <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010358d:	55                   	push   %ebp
f010358e:	89 e5                	mov    %esp,%ebp
f0103590:	56                   	push   %esi
f0103591:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103592:	8b 1d 40 12 21 f0    	mov    0xf0211240,%ebx
f0103598:	85 db                	test   %ebx,%ebx
f010359a:	0f 84 58 01 00 00    	je     f01036f8 <env_alloc+0x16b>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01035a0:	83 ec 0c             	sub    $0xc,%esp
f01035a3:	6a 01                	push   $0x1
f01035a5:	e8 57 e0 ff ff       	call   f0101601 <page_alloc>
f01035aa:	83 c4 10             	add    $0x10,%esp
f01035ad:	85 c0                	test   %eax,%eax
f01035af:	0f 84 4a 01 00 00    	je     f01036ff <env_alloc+0x172>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    p->pp_ref++;
f01035b5:	66 ff 40 04          	incw   0x4(%eax)
f01035b9:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01035bf:	c1 f8 03             	sar    $0x3,%eax
f01035c2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035c5:	89 c2                	mov    %eax,%edx
f01035c7:	c1 ea 0c             	shr    $0xc,%edx
f01035ca:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f01035d0:	72 12                	jb     f01035e4 <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01035d2:	50                   	push   %eax
f01035d3:	68 08 6a 10 f0       	push   $0xf0106a08
f01035d8:	6a 58                	push   $0x58
f01035da:	68 7d 7d 10 f0       	push   $0xf0107d7d
f01035df:	e8 84 ca ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f01035e4:	2d 00 00 00 10       	sub    $0x10000000,%eax
    e->env_pgdir = (pde_t *)page2kva(p);
f01035e9:	89 43 60             	mov    %eax,0x60(%ebx)
    
    memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01035ec:	83 ec 04             	sub    $0x4,%esp
f01035ef:	68 00 10 00 00       	push   $0x1000
f01035f4:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01035fa:	50                   	push   %eax
f01035fb:	e8 8d 27 00 00       	call   f0105d8d <memcpy>
    memset(e->env_pgdir, 0, PDX(UTOP) * sizeof(pde_t));
f0103600:	83 c4 0c             	add    $0xc,%esp
f0103603:	68 ec 0e 00 00       	push   $0xeec
f0103608:	6a 00                	push   $0x0
f010360a:	ff 73 60             	pushl  0x60(%ebx)
f010360d:	e8 c7 26 00 00       	call   f0105cd9 <memset>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103612:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103615:	83 c4 10             	add    $0x10,%esp
f0103618:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010361d:	77 15                	ja     f0103634 <env_alloc+0xa7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010361f:	50                   	push   %eax
f0103620:	68 e4 69 10 f0       	push   $0xf01069e4
f0103625:	68 cb 00 00 00       	push   $0xcb
f010362a:	68 8f 80 10 f0       	push   $0xf010808f
f010362f:	e8 34 ca ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103634:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010363a:	83 ca 05             	or     $0x5,%edx
f010363d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
    
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103643:	8b 43 48             	mov    0x48(%ebx),%eax
f0103646:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010364b:	89 c1                	mov    %eax,%ecx
f010364d:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0103653:	7f 05                	jg     f010365a <env_alloc+0xcd>
		generation = 1 << ENVGENSHIFT;
f0103655:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f010365a:	89 d8                	mov    %ebx,%eax
f010365c:	2b 05 3c 12 21 f0    	sub    0xf021123c,%eax
f0103662:	c1 f8 02             	sar    $0x2,%eax
f0103665:	89 c6                	mov    %eax,%esi
f0103667:	c1 e6 05             	shl    $0x5,%esi
f010366a:	89 c2                	mov    %eax,%edx
f010366c:	c1 e2 0a             	shl    $0xa,%edx
f010366f:	8d 14 16             	lea    (%esi,%edx,1),%edx
f0103672:	01 c2                	add    %eax,%edx
f0103674:	89 d6                	mov    %edx,%esi
f0103676:	c1 e6 0f             	shl    $0xf,%esi
f0103679:	01 f2                	add    %esi,%edx
f010367b:	c1 e2 05             	shl    $0x5,%edx
f010367e:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0103681:	f7 d8                	neg    %eax
f0103683:	09 c1                	or     %eax,%ecx
f0103685:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103688:	8b 45 0c             	mov    0xc(%ebp),%eax
f010368b:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010368e:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103695:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010369c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01036a3:	83 ec 04             	sub    $0x4,%esp
f01036a6:	6a 44                	push   $0x44
f01036a8:	6a 00                	push   $0x0
f01036aa:	53                   	push   %ebx
f01036ab:	e8 29 26 00 00       	call   f0105cd9 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01036b0:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01036b6:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01036bc:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01036c2:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01036c9:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f01036cf:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01036d6:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01036dd:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// set priority
	// e->env_priority = 0x0;

	// commit the allocation
	env_free_list = e->env_link;
f01036e1:	8b 43 44             	mov    0x44(%ebx),%eax
f01036e4:	a3 40 12 21 f0       	mov    %eax,0xf0211240
	*newenv_store = e;
f01036e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01036ec:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01036ee:	83 c4 10             	add    $0x10,%esp
f01036f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01036f6:	eb 0c                	jmp    f0103704 <env_alloc+0x177>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01036f8:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01036fd:	eb 05                	jmp    f0103704 <env_alloc+0x177>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01036ff:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103704:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103707:	5b                   	pop    %ebx
f0103708:	5e                   	pop    %esi
f0103709:	c9                   	leave  
f010370a:	c3                   	ret    

f010370b <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f010370b:	55                   	push   %ebp
f010370c:	89 e5                	mov    %esp,%ebp
f010370e:	57                   	push   %edi
f010370f:	56                   	push   %esi
f0103710:	53                   	push   %ebx
f0103711:	83 ec 34             	sub    $0x34,%esp
f0103714:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("env_create %u %u %u\n", binary, size, type);
	// LAB 3: Your code here.

    struct Env * e;
    int r = env_alloc(&e, 0);
f0103717:	6a 00                	push   $0x0
f0103719:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010371c:	50                   	push   %eax
f010371d:	e8 6b fe ff ff       	call   f010358d <env_alloc>
    if (r < 0) {
f0103722:	83 c4 10             	add    $0x10,%esp
f0103725:	85 c0                	test   %eax,%eax
f0103727:	79 15                	jns    f010373e <env_create+0x33>
        panic("env_create: %e\n", r);
f0103729:	50                   	push   %eax
f010372a:	68 9a 80 10 f0       	push   $0xf010809a
f010372f:	68 a4 01 00 00       	push   $0x1a4
f0103734:	68 8f 80 10 f0       	push   $0xf010808f
f0103739:	e8 2a c9 ff ff       	call   f0100068 <_panic>
    }
    load_icode(e, binary, size);
f010373e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103741:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
f0103744:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f010374a:	74 17                	je     f0103763 <env_create+0x58>
        panic("error elf magic number\n");
f010374c:	83 ec 04             	sub    $0x4,%esp
f010374f:	68 aa 80 10 f0       	push   $0xf01080aa
f0103754:	68 78 01 00 00       	push   $0x178
f0103759:	68 8f 80 10 f0       	push   $0xf010808f
f010375e:	e8 05 c9 ff ff       	call   f0100068 <_panic>
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0103763:	8b 5e 1c             	mov    0x1c(%esi),%ebx
    eph = ph + elf->e_phnum;
f0103766:	8b 7e 2c             	mov    0x2c(%esi),%edi

    lcr3(PADDR(e->env_pgdir));
f0103769:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010376c:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010376f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103774:	77 15                	ja     f010378b <env_create+0x80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103776:	50                   	push   %eax
f0103777:	68 e4 69 10 f0       	push   $0xf01069e4
f010377c:	68 7e 01 00 00       	push   $0x17e
f0103781:	68 8f 80 10 f0       	push   $0xf010808f
f0103786:	e8 dd c8 ff ff       	call   f0100068 <_panic>
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
        panic("error elf magic number\n");
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f010378b:	8d 1c 1e             	lea    (%esi,%ebx,1),%ebx
    eph = ph + elf->e_phnum;
f010378e:	0f b7 ff             	movzwl %di,%edi
f0103791:	c1 e7 05             	shl    $0x5,%edi
f0103794:	8d 3c 3b             	lea    (%ebx,%edi,1),%edi
	return (physaddr_t)kva - KERNBASE;
f0103797:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010379c:	0f 22 d8             	mov    %eax,%cr3

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f010379f:	39 fb                	cmp    %edi,%ebx
f01037a1:	73 48                	jae    f01037eb <env_create+0xe0>
        if (ph->p_type == ELF_PROG_LOAD) {
f01037a3:	83 3b 01             	cmpl   $0x1,(%ebx)
f01037a6:	75 3c                	jne    f01037e4 <env_create+0xd9>
            // cprintf("%u %u\n", ph->p_memsz, ph->p_filesz);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01037a8:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01037ab:	8b 53 08             	mov    0x8(%ebx),%edx
f01037ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01037b1:	e8 06 fc ff ff       	call   f01033bc <region_alloc>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01037b6:	83 ec 04             	sub    $0x4,%esp
f01037b9:	ff 73 10             	pushl  0x10(%ebx)
f01037bc:	89 f0                	mov    %esi,%eax
f01037be:	03 43 04             	add    0x4(%ebx),%eax
f01037c1:	50                   	push   %eax
f01037c2:	ff 73 08             	pushl  0x8(%ebx)
f01037c5:	e8 c3 25 00 00       	call   f0105d8d <memcpy>
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f01037ca:	8b 43 10             	mov    0x10(%ebx),%eax
f01037cd:	83 c4 0c             	add    $0xc,%esp
f01037d0:	8b 53 14             	mov    0x14(%ebx),%edx
f01037d3:	29 c2                	sub    %eax,%edx
f01037d5:	52                   	push   %edx
f01037d6:	6a 00                	push   $0x0
f01037d8:	03 43 08             	add    0x8(%ebx),%eax
f01037db:	50                   	push   %eax
f01037dc:	e8 f8 24 00 00       	call   f0105cd9 <memset>
f01037e1:	83 c4 10             	add    $0x10,%esp
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
    eph = ph + elf->e_phnum;

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01037e4:	83 c3 20             	add    $0x20,%ebx
f01037e7:	39 df                	cmp    %ebx,%edi
f01037e9:	77 b8                	ja     f01037a3 <env_create+0x98>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
        }
    }
    e->env_tf.tf_eip = elf->e_entry;
f01037eb:	8b 46 18             	mov    0x18(%esi),%eax
f01037ee:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01037f1:	89 42 30             	mov    %eax,0x30(%edx)

    lcr3(PADDR(kern_pgdir));
f01037f4:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037f9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037fe:	77 15                	ja     f0103815 <env_create+0x10a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103800:	50                   	push   %eax
f0103801:	68 e4 69 10 f0       	push   $0xf01069e4
f0103806:	68 8a 01 00 00       	push   $0x18a
f010380b:	68 8f 80 10 f0       	push   $0xf010808f
f0103810:	e8 53 c8 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103815:	05 00 00 00 10       	add    $0x10000000,%eax
f010381a:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010381d:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103822:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103827:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010382a:	e8 8d fb ff ff       	call   f01033bc <region_alloc>
    int r = env_alloc(&e, 0);
    if (r < 0) {
        panic("env_create: %e\n", r);
    }
    load_icode(e, binary, size);
    e->env_type = type;
f010382f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103832:	8b 55 10             	mov    0x10(%ebp),%edx
f0103835:	89 50 50             	mov    %edx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
    if (type == ENV_TYPE_FS)
f0103838:	83 fa 01             	cmp    $0x1,%edx
f010383b:	75 07                	jne    f0103844 <env_create+0x139>
        e->env_tf.tf_eflags |= FL_IOPL_3;
f010383d:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
    return;
}
f0103844:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103847:	5b                   	pop    %ebx
f0103848:	5e                   	pop    %esi
f0103849:	5f                   	pop    %edi
f010384a:	c9                   	leave  
f010384b:	c3                   	ret    

f010384c <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010384c:	55                   	push   %ebp
f010384d:	89 e5                	mov    %esp,%ebp
f010384f:	57                   	push   %edi
f0103850:	56                   	push   %esi
f0103851:	53                   	push   %ebx
f0103852:	83 ec 1c             	sub    $0x1c,%esp
f0103855:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103858:	e8 ab 2a 00 00       	call   f0106308 <cpunum>
f010385d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103860:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103867:	39 b8 28 20 21 f0    	cmp    %edi,-0xfdedfd8(%eax)
f010386d:	75 30                	jne    f010389f <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f010386f:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103874:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103879:	77 15                	ja     f0103890 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010387b:	50                   	push   %eax
f010387c:	68 e4 69 10 f0       	push   $0xf01069e4
f0103881:	68 be 01 00 00       	push   $0x1be
f0103886:	68 8f 80 10 f0       	push   $0xf010808f
f010388b:	e8 d8 c7 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103890:	05 00 00 00 10       	add    $0x10000000,%eax
f0103895:	0f 22 d8             	mov    %eax,%cr3
f0103898:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010389f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038a2:	c1 e0 02             	shl    $0x2,%eax
f01038a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01038a8:	8b 47 60             	mov    0x60(%edi),%eax
f01038ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01038ae:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01038b1:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01038b7:	0f 84 ab 00 00 00    	je     f0103968 <env_free+0x11c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01038bd:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01038c3:	89 f0                	mov    %esi,%eax
f01038c5:	c1 e8 0c             	shr    $0xc,%eax
f01038c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01038cb:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f01038d1:	72 15                	jb     f01038e8 <env_free+0x9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01038d3:	56                   	push   %esi
f01038d4:	68 08 6a 10 f0       	push   $0xf0106a08
f01038d9:	68 cd 01 00 00       	push   $0x1cd
f01038de:	68 8f 80 10 f0       	push   $0xf010808f
f01038e3:	e8 80 c7 ff ff       	call   f0100068 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01038e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01038eb:	c1 e2 16             	shl    $0x16,%edx
f01038ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01038f1:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01038f6:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01038fd:	01 
f01038fe:	74 17                	je     f0103917 <env_free+0xcb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103900:	83 ec 08             	sub    $0x8,%esp
f0103903:	89 d8                	mov    %ebx,%eax
f0103905:	c1 e0 0c             	shl    $0xc,%eax
f0103908:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010390b:	50                   	push   %eax
f010390c:	ff 77 60             	pushl  0x60(%edi)
f010390f:	e8 4c df ff ff       	call   f0101860 <page_remove>
f0103914:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103917:	43                   	inc    %ebx
f0103918:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010391e:	75 d6                	jne    f01038f6 <env_free+0xaa>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103920:	8b 47 60             	mov    0x60(%edi),%eax
f0103923:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103926:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010392d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103930:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0103936:	72 14                	jb     f010394c <env_free+0x100>
		panic("pa2page called with invalid pa");
f0103938:	83 ec 04             	sub    $0x4,%esp
f010393b:	68 70 75 10 f0       	push   $0xf0107570
f0103940:	6a 51                	push   $0x51
f0103942:	68 7d 7d 10 f0       	push   $0xf0107d7d
f0103947:	e8 1c c7 ff ff       	call   f0100068 <_panic>
		page_decref(pa2page(pa));
f010394c:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010394f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103952:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0103959:	03 05 90 1e 21 f0    	add    0xf0211e90,%eax
f010395f:	50                   	push   %eax
f0103960:	e8 46 dd ff ff       	call   f01016ab <page_decref>
f0103965:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103968:	ff 45 e0             	incl   -0x20(%ebp)
f010396b:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103972:	0f 85 27 ff ff ff    	jne    f010389f <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103978:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010397b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103980:	77 15                	ja     f0103997 <env_free+0x14b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103982:	50                   	push   %eax
f0103983:	68 e4 69 10 f0       	push   $0xf01069e4
f0103988:	68 db 01 00 00       	push   $0x1db
f010398d:	68 8f 80 10 f0       	push   $0xf010808f
f0103992:	e8 d1 c6 ff ff       	call   f0100068 <_panic>
	e->env_pgdir = 0;
f0103997:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f010399e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01039a3:	c1 e8 0c             	shr    $0xc,%eax
f01039a6:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f01039ac:	72 14                	jb     f01039c2 <env_free+0x176>
		panic("pa2page called with invalid pa");
f01039ae:	83 ec 04             	sub    $0x4,%esp
f01039b1:	68 70 75 10 f0       	push   $0xf0107570
f01039b6:	6a 51                	push   $0x51
f01039b8:	68 7d 7d 10 f0       	push   $0xf0107d7d
f01039bd:	e8 a6 c6 ff ff       	call   f0100068 <_panic>
	page_decref(pa2page(pa));
f01039c2:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01039c5:	c1 e0 03             	shl    $0x3,%eax
f01039c8:	03 05 90 1e 21 f0    	add    0xf0211e90,%eax
f01039ce:	50                   	push   %eax
f01039cf:	e8 d7 dc ff ff       	call   f01016ab <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01039d4:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01039db:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f01039e0:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01039e3:	89 3d 40 12 21 f0    	mov    %edi,0xf0211240
f01039e9:	83 c4 10             	add    $0x10,%esp
}
f01039ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01039ef:	5b                   	pop    %ebx
f01039f0:	5e                   	pop    %esi
f01039f1:	5f                   	pop    %edi
f01039f2:	c9                   	leave  
f01039f3:	c3                   	ret    

f01039f4 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01039f4:	55                   	push   %ebp
f01039f5:	89 e5                	mov    %esp,%ebp
f01039f7:	53                   	push   %ebx
f01039f8:	83 ec 04             	sub    $0x4,%esp
f01039fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01039fe:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103a02:	75 23                	jne    f0103a27 <env_destroy+0x33>
f0103a04:	e8 ff 28 00 00       	call   f0106308 <cpunum>
f0103a09:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a10:	29 c2                	sub    %eax,%edx
f0103a12:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a15:	39 1c 85 28 20 21 f0 	cmp    %ebx,-0xfdedfd8(,%eax,4)
f0103a1c:	74 09                	je     f0103a27 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103a1e:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103a25:	eb 3d                	jmp    f0103a64 <env_destroy+0x70>
	}

	env_free(e);
f0103a27:	83 ec 0c             	sub    $0xc,%esp
f0103a2a:	53                   	push   %ebx
f0103a2b:	e8 1c fe ff ff       	call   f010384c <env_free>

	if (curenv == e) {
f0103a30:	e8 d3 28 00 00       	call   f0106308 <cpunum>
f0103a35:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a3c:	29 c2                	sub    %eax,%edx
f0103a3e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a41:	83 c4 10             	add    $0x10,%esp
f0103a44:	39 1c 85 28 20 21 f0 	cmp    %ebx,-0xfdedfd8(,%eax,4)
f0103a4b:	75 17                	jne    f0103a64 <env_destroy+0x70>
		curenv = NULL;
f0103a4d:	e8 b6 28 00 00       	call   f0106308 <cpunum>
f0103a52:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a55:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f0103a5c:	00 00 00 
		sched_yield();
f0103a5f:	e8 77 0d 00 00       	call   f01047db <sched_yield>
	}
}
f0103a64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a67:	c9                   	leave  
f0103a68:	c3                   	ret    

f0103a69 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103a69:	55                   	push   %ebp
f0103a6a:	89 e5                	mov    %esp,%ebp
f0103a6c:	53                   	push   %ebx
f0103a6d:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103a70:	e8 93 28 00 00       	call   f0106308 <cpunum>
f0103a75:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a7c:	29 c2                	sub    %eax,%edx
f0103a7e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a81:	8b 1c 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%ebx
f0103a88:	e8 7b 28 00 00       	call   f0106308 <cpunum>
f0103a8d:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103a90:	8b 65 08             	mov    0x8(%ebp),%esp
f0103a93:	61                   	popa   
f0103a94:	07                   	pop    %es
f0103a95:	1f                   	pop    %ds
f0103a96:	83 c4 08             	add    $0x8,%esp
f0103a99:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103a9a:	83 ec 04             	sub    $0x4,%esp
f0103a9d:	68 c2 80 10 f0       	push   $0xf01080c2
f0103aa2:	68 11 02 00 00       	push   $0x211
f0103aa7:	68 8f 80 10 f0       	push   $0xf010808f
f0103aac:	e8 b7 c5 ff ff       	call   f0100068 <_panic>

f0103ab1 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103ab1:	55                   	push   %ebp
f0103ab2:	89 e5                	mov    %esp,%ebp
f0103ab4:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// cprintf("I am in env_run\n");
	
    if (curenv != NULL) {
f0103ab7:	e8 4c 28 00 00       	call   f0106308 <cpunum>
f0103abc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ac3:	29 c2                	sub    %eax,%edx
f0103ac5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ac8:	83 3c 85 28 20 21 f0 	cmpl   $0x0,-0xfdedfd8(,%eax,4)
f0103acf:	00 
f0103ad0:	74 3d                	je     f0103b0f <env_run+0x5e>
        // context switch
        if (curenv->env_status == ENV_RUNNING) {
f0103ad2:	e8 31 28 00 00       	call   f0106308 <cpunum>
f0103ad7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ade:	29 c2                	sub    %eax,%edx
f0103ae0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ae3:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0103aea:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103aee:	75 1f                	jne    f0103b0f <env_run+0x5e>
            curenv->env_status = ENV_RUNNABLE;
f0103af0:	e8 13 28 00 00       	call   f0106308 <cpunum>
f0103af5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103afc:	29 c2                	sub    %eax,%edx
f0103afe:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b01:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0103b08:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
        }
        // how about other env_status ? e.g. like ENV_DYING ?
    }
    curenv = e;
f0103b0f:	e8 f4 27 00 00       	call   f0106308 <cpunum>
f0103b14:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b1b:	29 c2                	sub    %eax,%edx
f0103b1d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b20:	8b 55 08             	mov    0x8(%ebp),%edx
f0103b23:	89 14 85 28 20 21 f0 	mov    %edx,-0xfdedfd8(,%eax,4)
    curenv->env_status = ENV_RUNNING;
f0103b2a:	e8 d9 27 00 00       	call   f0106308 <cpunum>
f0103b2f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b36:	29 c2                	sub    %eax,%edx
f0103b38:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b3b:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0103b42:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f0103b49:	e8 ba 27 00 00       	call   f0106308 <cpunum>
f0103b4e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b55:	29 c2                	sub    %eax,%edx
f0103b57:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b5a:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0103b61:	ff 40 58             	incl   0x58(%eax)

    lcr3(PADDR(curenv->env_pgdir));
f0103b64:	e8 9f 27 00 00       	call   f0106308 <cpunum>
f0103b69:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b70:	29 c2                	sub    %eax,%edx
f0103b72:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b75:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0103b7c:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b7f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b84:	77 15                	ja     f0103b9b <env_run+0xea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b86:	50                   	push   %eax
f0103b87:	68 e4 69 10 f0       	push   $0xf01069e4
f0103b8c:	68 3c 02 00 00       	push   $0x23c
f0103b91:	68 8f 80 10 f0       	push   $0xf010808f
f0103b96:	e8 cd c4 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b9b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ba0:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103ba3:	83 ec 0c             	sub    $0xc,%esp
f0103ba6:	68 60 94 12 f0       	push   $0xf0129460
f0103bab:	e8 ca 2a 00 00       	call   f010667a <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103bb0:	f3 90                	pause  
    unlock_kernel();
    env_pop_tf(&curenv->env_tf);    
f0103bb2:	e8 51 27 00 00       	call   f0106308 <cpunum>
f0103bb7:	83 c4 04             	add    $0x4,%esp
f0103bba:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103bc1:	29 c2                	sub    %eax,%edx
f0103bc3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103bc6:	ff 34 85 28 20 21 f0 	pushl  -0xfdedfd8(,%eax,4)
f0103bcd:	e8 97 fe ff ff       	call   f0103a69 <env_pop_tf>
	...

f0103bd4 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103bd4:	55                   	push   %ebp
f0103bd5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103bd7:	ba 70 00 00 00       	mov    $0x70,%edx
f0103bdc:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bdf:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103be0:	b2 71                	mov    $0x71,%dl
f0103be2:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103be3:	0f b6 c0             	movzbl %al,%eax
}
f0103be6:	c9                   	leave  
f0103be7:	c3                   	ret    

f0103be8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103be8:	55                   	push   %ebp
f0103be9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103beb:	ba 70 00 00 00       	mov    $0x70,%edx
f0103bf0:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bf3:	ee                   	out    %al,(%dx)
f0103bf4:	b2 71                	mov    $0x71,%dl
f0103bf6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bf9:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103bfa:	c9                   	leave  
f0103bfb:	c3                   	ret    

f0103bfc <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103bfc:	55                   	push   %ebp
f0103bfd:	89 e5                	mov    %esp,%ebp
f0103bff:	56                   	push   %esi
f0103c00:	53                   	push   %ebx
f0103c01:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c04:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103c06:	66 a3 90 93 12 f0    	mov    %ax,0xf0129390
	if (!didinit)
f0103c0c:	80 3d 44 12 21 f0 00 	cmpb   $0x0,0xf0211244
f0103c13:	74 5a                	je     f0103c6f <irq_setmask_8259A+0x73>
f0103c15:	ba 21 00 00 00       	mov    $0x21,%edx
f0103c1a:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103c1b:	89 f0                	mov    %esi,%eax
f0103c1d:	66 c1 e8 08          	shr    $0x8,%ax
f0103c21:	b2 a1                	mov    $0xa1,%dl
f0103c23:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103c24:	83 ec 0c             	sub    $0xc,%esp
f0103c27:	68 ce 80 10 f0       	push   $0xf01080ce
f0103c2c:	e8 e4 00 00 00       	call   f0103d15 <cprintf>
f0103c31:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103c34:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103c39:	0f b7 f6             	movzwl %si,%esi
f0103c3c:	f7 d6                	not    %esi
f0103c3e:	89 f0                	mov    %esi,%eax
f0103c40:	88 d9                	mov    %bl,%cl
f0103c42:	d3 f8                	sar    %cl,%eax
f0103c44:	a8 01                	test   $0x1,%al
f0103c46:	74 11                	je     f0103c59 <irq_setmask_8259A+0x5d>
			cprintf(" %d", i);
f0103c48:	83 ec 08             	sub    $0x8,%esp
f0103c4b:	53                   	push   %ebx
f0103c4c:	68 6f 85 10 f0       	push   $0xf010856f
f0103c51:	e8 bf 00 00 00       	call   f0103d15 <cprintf>
f0103c56:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103c59:	43                   	inc    %ebx
f0103c5a:	83 fb 10             	cmp    $0x10,%ebx
f0103c5d:	75 df                	jne    f0103c3e <irq_setmask_8259A+0x42>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103c5f:	83 ec 0c             	sub    $0xc,%esp
f0103c62:	68 2f 6d 10 f0       	push   $0xf0106d2f
f0103c67:	e8 a9 00 00 00       	call   f0103d15 <cprintf>
f0103c6c:	83 c4 10             	add    $0x10,%esp
}
f0103c6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103c72:	5b                   	pop    %ebx
f0103c73:	5e                   	pop    %esi
f0103c74:	c9                   	leave  
f0103c75:	c3                   	ret    

f0103c76 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103c76:	55                   	push   %ebp
f0103c77:	89 e5                	mov    %esp,%ebp
f0103c79:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f0103c7c:	c6 05 44 12 21 f0 01 	movb   $0x1,0xf0211244
f0103c83:	ba 21 00 00 00       	mov    $0x21,%edx
f0103c88:	b0 ff                	mov    $0xff,%al
f0103c8a:	ee                   	out    %al,(%dx)
f0103c8b:	b2 a1                	mov    $0xa1,%dl
f0103c8d:	ee                   	out    %al,(%dx)
f0103c8e:	b2 20                	mov    $0x20,%dl
f0103c90:	b0 11                	mov    $0x11,%al
f0103c92:	ee                   	out    %al,(%dx)
f0103c93:	b2 21                	mov    $0x21,%dl
f0103c95:	b0 20                	mov    $0x20,%al
f0103c97:	ee                   	out    %al,(%dx)
f0103c98:	b0 04                	mov    $0x4,%al
f0103c9a:	ee                   	out    %al,(%dx)
f0103c9b:	b0 03                	mov    $0x3,%al
f0103c9d:	ee                   	out    %al,(%dx)
f0103c9e:	b2 a0                	mov    $0xa0,%dl
f0103ca0:	b0 11                	mov    $0x11,%al
f0103ca2:	ee                   	out    %al,(%dx)
f0103ca3:	b2 a1                	mov    $0xa1,%dl
f0103ca5:	b0 28                	mov    $0x28,%al
f0103ca7:	ee                   	out    %al,(%dx)
f0103ca8:	b0 02                	mov    $0x2,%al
f0103caa:	ee                   	out    %al,(%dx)
f0103cab:	b0 01                	mov    $0x1,%al
f0103cad:	ee                   	out    %al,(%dx)
f0103cae:	b2 20                	mov    $0x20,%dl
f0103cb0:	b0 68                	mov    $0x68,%al
f0103cb2:	ee                   	out    %al,(%dx)
f0103cb3:	b0 0a                	mov    $0xa,%al
f0103cb5:	ee                   	out    %al,(%dx)
f0103cb6:	b2 a0                	mov    $0xa0,%dl
f0103cb8:	b0 68                	mov    $0x68,%al
f0103cba:	ee                   	out    %al,(%dx)
f0103cbb:	b0 0a                	mov    $0xa,%al
f0103cbd:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103cbe:	66 a1 90 93 12 f0    	mov    0xf0129390,%ax
f0103cc4:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103cc8:	74 0f                	je     f0103cd9 <pic_init+0x63>
		irq_setmask_8259A(irq_mask_8259A);
f0103cca:	83 ec 0c             	sub    $0xc,%esp
f0103ccd:	0f b7 c0             	movzwl %ax,%eax
f0103cd0:	50                   	push   %eax
f0103cd1:	e8 26 ff ff ff       	call   f0103bfc <irq_setmask_8259A>
f0103cd6:	83 c4 10             	add    $0x10,%esp
}
f0103cd9:	c9                   	leave  
f0103cda:	c3                   	ret    
	...

f0103cdc <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103cdc:	55                   	push   %ebp
f0103cdd:	89 e5                	mov    %esp,%ebp
f0103cdf:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103ce2:	ff 75 08             	pushl  0x8(%ebp)
f0103ce5:	e8 ea ca ff ff       	call   f01007d4 <cputchar>
f0103cea:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0103ced:	c9                   	leave  
f0103cee:	c3                   	ret    

f0103cef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103cef:	55                   	push   %ebp
f0103cf0:	89 e5                	mov    %esp,%ebp
f0103cf2:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103cf5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103cfc:	ff 75 0c             	pushl  0xc(%ebp)
f0103cff:	ff 75 08             	pushl  0x8(%ebp)
f0103d02:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103d05:	50                   	push   %eax
f0103d06:	68 dc 3c 10 f0       	push   $0xf0103cdc
f0103d0b:	e8 21 19 00 00       	call   f0105631 <vprintfmt>
	return cnt;
}
f0103d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d13:	c9                   	leave  
f0103d14:	c3                   	ret    

f0103d15 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103d15:	55                   	push   %ebp
f0103d16:	89 e5                	mov    %esp,%ebp
f0103d18:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103d1b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103d1e:	50                   	push   %eax
f0103d1f:	ff 75 08             	pushl  0x8(%ebp)
f0103d22:	e8 c8 ff ff ff       	call   f0103cef <vcprintf>
	va_end(ap);

	return cnt;
}
f0103d27:	c9                   	leave  
f0103d28:	c3                   	ret    
f0103d29:	00 00                	add    %al,(%eax)
	...

f0103d2c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103d2c:	55                   	push   %ebp
f0103d2d:	89 e5                	mov    %esp,%ebp
f0103d2f:	57                   	push   %edi
f0103d30:	56                   	push   %esi
f0103d31:	53                   	push   %ebx
f0103d32:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
    
    int cpu_id = thiscpu->cpu_id;
f0103d35:	e8 ce 25 00 00       	call   f0106308 <cpunum>
f0103d3a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d41:	29 c2                	sub    %eax,%edx
f0103d43:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d46:	0f b6 34 85 20 20 21 	movzbl -0xfdedfe0(,%eax,4),%esi
f0103d4d:	f0 
    
    // Setup a TSS so that we get the right stack
	// when we trap to the kernel.
    thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id * (KSTKSIZE + KSTKGAP);
f0103d4e:	e8 b5 25 00 00       	call   f0106308 <cpunum>
f0103d53:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d5a:	29 c2                	sub    %eax,%edx
f0103d5c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d5f:	89 f2                	mov    %esi,%edx
f0103d61:	f7 da                	neg    %edx
f0103d63:	c1 e2 10             	shl    $0x10,%edx
f0103d66:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103d6c:	89 14 85 30 20 21 f0 	mov    %edx,-0xfdedfd0(,%eax,4)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103d73:	e8 90 25 00 00       	call   f0106308 <cpunum>
f0103d78:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d7f:	29 c2                	sub    %eax,%edx
f0103d81:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d84:	66 c7 04 85 34 20 21 	movw   $0x10,-0xfdedfcc(,%eax,4)
f0103d8b:	f0 10 00 

    gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103d8e:	8d 5e 05             	lea    0x5(%esi),%ebx
f0103d91:	e8 72 25 00 00       	call   f0106308 <cpunum>
f0103d96:	89 c7                	mov    %eax,%edi
f0103d98:	e8 6b 25 00 00       	call   f0106308 <cpunum>
f0103d9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103da0:	e8 63 25 00 00       	call   f0106308 <cpunum>
f0103da5:	66 c7 04 dd 20 93 12 	movw   $0x68,-0xfed6ce0(,%ebx,8)
f0103dac:	f0 68 00 
f0103daf:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0103db6:	29 fa                	sub    %edi,%edx
f0103db8:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103dbb:	8d 14 95 2c 20 21 f0 	lea    -0xfdedfd4(,%edx,4),%edx
f0103dc2:	66 89 14 dd 22 93 12 	mov    %dx,-0xfed6cde(,%ebx,8)
f0103dc9:	f0 
f0103dca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103dcd:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0103dd4:	29 ca                	sub    %ecx,%edx
f0103dd6:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0103dd9:	8d 14 95 2c 20 21 f0 	lea    -0xfdedfd4(,%edx,4),%edx
f0103de0:	c1 ea 10             	shr    $0x10,%edx
f0103de3:	88 14 dd 24 93 12 f0 	mov    %dl,-0xfed6cdc(,%ebx,8)
f0103dea:	c6 04 dd 26 93 12 f0 	movb   $0x40,-0xfed6cda(,%ebx,8)
f0103df1:	40 
f0103df2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103df9:	29 c2                	sub    %eax,%edx
f0103dfb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103dfe:	8d 04 85 2c 20 21 f0 	lea    -0xfdedfd4(,%eax,4),%eax
f0103e05:	c1 e8 18             	shr    $0x18,%eax
f0103e08:	88 04 dd 27 93 12 f0 	mov    %al,-0xfed6cd9(,%ebx,8)
    							sizeof(struct Taskstate), 0);

    // Initialize the TSS slot of the gdt.
    gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0103e0f:	c6 04 dd 25 93 12 f0 	movb   $0x89,-0xfed6cdb(,%ebx,8)
f0103e16:	89 

    // Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
    ltr(GD_TSS0 + (cpu_id << 3));
f0103e17:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103e1e:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103e21:	b8 94 93 12 f0       	mov    $0xf0129394,%eax
f0103e26:	0f 01 18             	lidtl  (%eax)

    // Load the IDT
    lidt(&idt_pd);
}
f0103e29:	83 c4 1c             	add    $0x1c,%esp
f0103e2c:	5b                   	pop    %ebx
f0103e2d:	5e                   	pop    %esi
f0103e2e:	5f                   	pop    %edi
f0103e2f:	c9                   	leave  
f0103e30:	c3                   	ret    

f0103e31 <trap_init>:
}


void
trap_init(void)
{
f0103e31:	55                   	push   %ebp
f0103e32:	89 e5                	mov    %esp,%ebp
f0103e34:	83 ec 08             	sub    $0x8,%esp
f0103e37:	ba 01 00 00 00       	mov    $0x1,%edx
f0103e3c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e41:	eb 02                	jmp    f0103e45 <trap_init+0x14>
f0103e43:	40                   	inc    %eax
f0103e44:	42                   	inc    %edx
    extern void vec51();
    

    int i;
    for (i = 0; i != 20; i++) {
    	if (i == T_BRKPT) {
f0103e45:	83 f8 03             	cmp    $0x3,%eax
f0103e48:	75 30                	jne    f0103e7a <trap_init+0x49>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
f0103e4a:	8b 0d a8 93 12 f0    	mov    0xf01293a8,%ecx
f0103e50:	66 89 0d 78 12 21 f0 	mov    %cx,0xf0211278
f0103e57:	66 c7 05 7a 12 21 f0 	movw   $0x8,0xf021127a
f0103e5e:	08 00 
f0103e60:	c6 05 7c 12 21 f0 00 	movb   $0x0,0xf021127c
f0103e67:	c6 05 7d 12 21 f0 ee 	movb   $0xee,0xf021127d
f0103e6e:	c1 e9 10             	shr    $0x10,%ecx
f0103e71:	66 89 0d 7e 12 21 f0 	mov    %cx,0xf021127e
f0103e78:	eb c9                	jmp    f0103e43 <trap_init+0x12>
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f0103e7a:	8b 0c 85 9c 93 12 f0 	mov    -0xfed6c64(,%eax,4),%ecx
f0103e81:	66 89 0c c5 60 12 21 	mov    %cx,-0xfdeeda0(,%eax,8)
f0103e88:	f0 
f0103e89:	66 c7 04 c5 62 12 21 	movw   $0x8,-0xfdeed9e(,%eax,8)
f0103e90:	f0 08 00 
f0103e93:	c6 04 c5 64 12 21 f0 	movb   $0x0,-0xfdeed9c(,%eax,8)
f0103e9a:	00 
f0103e9b:	c6 04 c5 65 12 21 f0 	movb   $0x8e,-0xfdeed9b(,%eax,8)
f0103ea2:	8e 
f0103ea3:	c1 e9 10             	shr    $0x10,%ecx
f0103ea6:	66 89 0c c5 66 12 21 	mov    %cx,-0xfdeed9a(,%eax,8)
f0103ead:	f0 
    extern void vec46();
    extern void vec51();
    

    int i;
    for (i = 0; i != 20; i++) {
f0103eae:	83 fa 14             	cmp    $0x14,%edx
f0103eb1:	75 90                	jne    f0103e43 <trap_init+0x12>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
    	}
    }
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, vec32, 0);
f0103eb3:	b8 f2 93 12 f0       	mov    $0xf01293f2,%eax
f0103eb8:	66 a3 60 13 21 f0    	mov    %ax,0xf0211360
f0103ebe:	66 c7 05 62 13 21 f0 	movw   $0x8,0xf0211362
f0103ec5:	08 00 
f0103ec7:	c6 05 64 13 21 f0 00 	movb   $0x0,0xf0211364
f0103ece:	c6 05 65 13 21 f0 8e 	movb   $0x8e,0xf0211365
f0103ed5:	c1 e8 10             	shr    $0x10,%eax
f0103ed8:	66 a3 66 13 21 f0    	mov    %ax,0xf0211366
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, vec33, 0);
f0103ede:	b8 f8 93 12 f0       	mov    $0xf01293f8,%eax
f0103ee3:	66 a3 68 13 21 f0    	mov    %ax,0xf0211368
f0103ee9:	66 c7 05 6a 13 21 f0 	movw   $0x8,0xf021136a
f0103ef0:	08 00 
f0103ef2:	c6 05 6c 13 21 f0 00 	movb   $0x0,0xf021136c
f0103ef9:	c6 05 6d 13 21 f0 8e 	movb   $0x8e,0xf021136d
f0103f00:	c1 e8 10             	shr    $0x10,%eax
f0103f03:	66 a3 6e 13 21 f0    	mov    %ax,0xf021136e
    SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, vec36, 0);
f0103f09:	b8 fe 93 12 f0       	mov    $0xf01293fe,%eax
f0103f0e:	66 a3 80 13 21 f0    	mov    %ax,0xf0211380
f0103f14:	66 c7 05 82 13 21 f0 	movw   $0x8,0xf0211382
f0103f1b:	08 00 
f0103f1d:	c6 05 84 13 21 f0 00 	movb   $0x0,0xf0211384
f0103f24:	c6 05 85 13 21 f0 8e 	movb   $0x8e,0xf0211385
f0103f2b:	c1 e8 10             	shr    $0x10,%eax
f0103f2e:	66 a3 86 13 21 f0    	mov    %ax,0xf0211386
    SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, vec39, 0);
f0103f34:	b8 04 94 12 f0       	mov    $0xf0129404,%eax
f0103f39:	66 a3 98 13 21 f0    	mov    %ax,0xf0211398
f0103f3f:	66 c7 05 9a 13 21 f0 	movw   $0x8,0xf021139a
f0103f46:	08 00 
f0103f48:	c6 05 9c 13 21 f0 00 	movb   $0x0,0xf021139c
f0103f4f:	c6 05 9d 13 21 f0 8e 	movb   $0x8e,0xf021139d
f0103f56:	c1 e8 10             	shr    $0x10,%eax
f0103f59:	66 a3 9e 13 21 f0    	mov    %ax,0xf021139e
    SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, vec46, 0);
f0103f5f:	b8 0a 94 12 f0       	mov    $0xf012940a,%eax
f0103f64:	66 a3 d0 13 21 f0    	mov    %ax,0xf02113d0
f0103f6a:	66 c7 05 d2 13 21 f0 	movw   $0x8,0xf02113d2
f0103f71:	08 00 
f0103f73:	c6 05 d4 13 21 f0 00 	movb   $0x0,0xf02113d4
f0103f7a:	c6 05 d5 13 21 f0 8e 	movb   $0x8e,0xf02113d5
f0103f81:	c1 e8 10             	shr    $0x10,%eax
f0103f84:	66 a3 d6 13 21 f0    	mov    %ax,0xf02113d6

    SETGATE(idt[T_SYSCALL], 0, GD_KT, vec48, 3);
f0103f8a:	b8 ec 93 12 f0       	mov    $0xf01293ec,%eax
f0103f8f:	66 a3 e0 13 21 f0    	mov    %ax,0xf02113e0
f0103f95:	66 c7 05 e2 13 21 f0 	movw   $0x8,0xf02113e2
f0103f9c:	08 00 
f0103f9e:	c6 05 e4 13 21 f0 00 	movb   $0x0,0xf02113e4
f0103fa5:	c6 05 e5 13 21 f0 ee 	movb   $0xee,0xf02113e5
f0103fac:	c1 e8 10             	shr    $0x10,%eax
f0103faf:	66 a3 e6 13 21 f0    	mov    %ax,0xf02113e6
	
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, vec51, 0);
f0103fb5:	b8 10 94 12 f0       	mov    $0xf0129410,%eax
f0103fba:	66 a3 f8 13 21 f0    	mov    %ax,0xf02113f8
f0103fc0:	66 c7 05 fa 13 21 f0 	movw   $0x8,0xf02113fa
f0103fc7:	08 00 
f0103fc9:	c6 05 fc 13 21 f0 00 	movb   $0x0,0xf02113fc
f0103fd0:	c6 05 fd 13 21 f0 8e 	movb   $0x8e,0xf02113fd
f0103fd7:	c1 e8 10             	shr    $0x10,%eax
f0103fda:	66 a3 fe 13 21 f0    	mov    %ax,0xf02113fe
    
 	
	// Per-CPU setup 
	trap_init_percpu();
f0103fe0:	e8 47 fd ff ff       	call   f0103d2c <trap_init_percpu>
}
f0103fe5:	c9                   	leave  
f0103fe6:	c3                   	ret    

f0103fe7 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103fe7:	55                   	push   %ebp
f0103fe8:	89 e5                	mov    %esp,%ebp
f0103fea:	53                   	push   %ebx
f0103feb:	83 ec 0c             	sub    $0xc,%esp
f0103fee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103ff1:	ff 33                	pushl  (%ebx)
f0103ff3:	68 e2 80 10 f0       	push   $0xf01080e2
f0103ff8:	e8 18 fd ff ff       	call   f0103d15 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103ffd:	83 c4 08             	add    $0x8,%esp
f0104000:	ff 73 04             	pushl  0x4(%ebx)
f0104003:	68 f1 80 10 f0       	push   $0xf01080f1
f0104008:	e8 08 fd ff ff       	call   f0103d15 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010400d:	83 c4 08             	add    $0x8,%esp
f0104010:	ff 73 08             	pushl  0x8(%ebx)
f0104013:	68 00 81 10 f0       	push   $0xf0108100
f0104018:	e8 f8 fc ff ff       	call   f0103d15 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010401d:	83 c4 08             	add    $0x8,%esp
f0104020:	ff 73 0c             	pushl  0xc(%ebx)
f0104023:	68 0f 81 10 f0       	push   $0xf010810f
f0104028:	e8 e8 fc ff ff       	call   f0103d15 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010402d:	83 c4 08             	add    $0x8,%esp
f0104030:	ff 73 10             	pushl  0x10(%ebx)
f0104033:	68 1e 81 10 f0       	push   $0xf010811e
f0104038:	e8 d8 fc ff ff       	call   f0103d15 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010403d:	83 c4 08             	add    $0x8,%esp
f0104040:	ff 73 14             	pushl  0x14(%ebx)
f0104043:	68 2d 81 10 f0       	push   $0xf010812d
f0104048:	e8 c8 fc ff ff       	call   f0103d15 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010404d:	83 c4 08             	add    $0x8,%esp
f0104050:	ff 73 18             	pushl  0x18(%ebx)
f0104053:	68 3c 81 10 f0       	push   $0xf010813c
f0104058:	e8 b8 fc ff ff       	call   f0103d15 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010405d:	83 c4 08             	add    $0x8,%esp
f0104060:	ff 73 1c             	pushl  0x1c(%ebx)
f0104063:	68 4b 81 10 f0       	push   $0xf010814b
f0104068:	e8 a8 fc ff ff       	call   f0103d15 <cprintf>
f010406d:	83 c4 10             	add    $0x10,%esp
}
f0104070:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104073:	c9                   	leave  
f0104074:	c3                   	ret    

f0104075 <print_trapframe>:
    lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104075:	55                   	push   %ebp
f0104076:	89 e5                	mov    %esp,%ebp
f0104078:	53                   	push   %ebx
f0104079:	83 ec 04             	sub    $0x4,%esp
f010407c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010407f:	e8 84 22 00 00       	call   f0106308 <cpunum>
f0104084:	83 ec 04             	sub    $0x4,%esp
f0104087:	50                   	push   %eax
f0104088:	53                   	push   %ebx
f0104089:	68 af 81 10 f0       	push   $0xf01081af
f010408e:	e8 82 fc ff ff       	call   f0103d15 <cprintf>
	print_regs(&tf->tf_regs);
f0104093:	89 1c 24             	mov    %ebx,(%esp)
f0104096:	e8 4c ff ff ff       	call   f0103fe7 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010409b:	83 c4 08             	add    $0x8,%esp
f010409e:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01040a2:	50                   	push   %eax
f01040a3:	68 cd 81 10 f0       	push   $0xf01081cd
f01040a8:	e8 68 fc ff ff       	call   f0103d15 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01040ad:	83 c4 08             	add    $0x8,%esp
f01040b0:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01040b4:	50                   	push   %eax
f01040b5:	68 e0 81 10 f0       	push   $0xf01081e0
f01040ba:	e8 56 fc ff ff       	call   f0103d15 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01040bf:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01040c2:	83 c4 10             	add    $0x10,%esp
f01040c5:	83 f8 13             	cmp    $0x13,%eax
f01040c8:	77 09                	ja     f01040d3 <print_trapframe+0x5e>
		return excnames[trapno];
f01040ca:	8b 14 85 80 84 10 f0 	mov    -0xfef7b80(,%eax,4),%edx
f01040d1:	eb 20                	jmp    f01040f3 <print_trapframe+0x7e>
	if (trapno == T_SYSCALL)
f01040d3:	83 f8 30             	cmp    $0x30,%eax
f01040d6:	74 0f                	je     f01040e7 <print_trapframe+0x72>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01040d8:	8d 50 e0             	lea    -0x20(%eax),%edx
f01040db:	83 fa 0f             	cmp    $0xf,%edx
f01040de:	77 0e                	ja     f01040ee <print_trapframe+0x79>
		return "Hardware Interrupt";
f01040e0:	ba 66 81 10 f0       	mov    $0xf0108166,%edx
f01040e5:	eb 0c                	jmp    f01040f3 <print_trapframe+0x7e>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01040e7:	ba 5a 81 10 f0       	mov    $0xf010815a,%edx
f01040ec:	eb 05                	jmp    f01040f3 <print_trapframe+0x7e>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f01040ee:	ba 79 81 10 f0       	mov    $0xf0108179,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01040f3:	83 ec 04             	sub    $0x4,%esp
f01040f6:	52                   	push   %edx
f01040f7:	50                   	push   %eax
f01040f8:	68 f3 81 10 f0       	push   $0xf01081f3
f01040fd:	e8 13 fc ff ff       	call   f0103d15 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104102:	83 c4 10             	add    $0x10,%esp
f0104105:	3b 1d 60 1a 21 f0    	cmp    0xf0211a60,%ebx
f010410b:	75 1a                	jne    f0104127 <print_trapframe+0xb2>
f010410d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104111:	75 14                	jne    f0104127 <print_trapframe+0xb2>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104113:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104116:	83 ec 08             	sub    $0x8,%esp
f0104119:	50                   	push   %eax
f010411a:	68 05 82 10 f0       	push   $0xf0108205
f010411f:	e8 f1 fb ff ff       	call   f0103d15 <cprintf>
f0104124:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0104127:	83 ec 08             	sub    $0x8,%esp
f010412a:	ff 73 2c             	pushl  0x2c(%ebx)
f010412d:	68 14 82 10 f0       	push   $0xf0108214
f0104132:	e8 de fb ff ff       	call   f0103d15 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104137:	83 c4 10             	add    $0x10,%esp
f010413a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010413e:	75 45                	jne    f0104185 <print_trapframe+0x110>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104140:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104143:	a8 01                	test   $0x1,%al
f0104145:	74 07                	je     f010414e <print_trapframe+0xd9>
f0104147:	b9 88 81 10 f0       	mov    $0xf0108188,%ecx
f010414c:	eb 05                	jmp    f0104153 <print_trapframe+0xde>
f010414e:	b9 93 81 10 f0       	mov    $0xf0108193,%ecx
f0104153:	a8 02                	test   $0x2,%al
f0104155:	74 07                	je     f010415e <print_trapframe+0xe9>
f0104157:	ba 9f 81 10 f0       	mov    $0xf010819f,%edx
f010415c:	eb 05                	jmp    f0104163 <print_trapframe+0xee>
f010415e:	ba a5 81 10 f0       	mov    $0xf01081a5,%edx
f0104163:	a8 04                	test   $0x4,%al
f0104165:	74 07                	je     f010416e <print_trapframe+0xf9>
f0104167:	b8 aa 81 10 f0       	mov    $0xf01081aa,%eax
f010416c:	eb 05                	jmp    f0104173 <print_trapframe+0xfe>
f010416e:	b8 df 82 10 f0       	mov    $0xf01082df,%eax
f0104173:	51                   	push   %ecx
f0104174:	52                   	push   %edx
f0104175:	50                   	push   %eax
f0104176:	68 22 82 10 f0       	push   $0xf0108222
f010417b:	e8 95 fb ff ff       	call   f0103d15 <cprintf>
f0104180:	83 c4 10             	add    $0x10,%esp
f0104183:	eb 10                	jmp    f0104195 <print_trapframe+0x120>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104185:	83 ec 0c             	sub    $0xc,%esp
f0104188:	68 2f 6d 10 f0       	push   $0xf0106d2f
f010418d:	e8 83 fb ff ff       	call   f0103d15 <cprintf>
f0104192:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104195:	83 ec 08             	sub    $0x8,%esp
f0104198:	ff 73 30             	pushl  0x30(%ebx)
f010419b:	68 31 82 10 f0       	push   $0xf0108231
f01041a0:	e8 70 fb ff ff       	call   f0103d15 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01041a5:	83 c4 08             	add    $0x8,%esp
f01041a8:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01041ac:	50                   	push   %eax
f01041ad:	68 40 82 10 f0       	push   $0xf0108240
f01041b2:	e8 5e fb ff ff       	call   f0103d15 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01041b7:	83 c4 08             	add    $0x8,%esp
f01041ba:	ff 73 38             	pushl  0x38(%ebx)
f01041bd:	68 53 82 10 f0       	push   $0xf0108253
f01041c2:	e8 4e fb ff ff       	call   f0103d15 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01041c7:	83 c4 10             	add    $0x10,%esp
f01041ca:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01041ce:	74 25                	je     f01041f5 <print_trapframe+0x180>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01041d0:	83 ec 08             	sub    $0x8,%esp
f01041d3:	ff 73 3c             	pushl  0x3c(%ebx)
f01041d6:	68 62 82 10 f0       	push   $0xf0108262
f01041db:	e8 35 fb ff ff       	call   f0103d15 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01041e0:	83 c4 08             	add    $0x8,%esp
f01041e3:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01041e7:	50                   	push   %eax
f01041e8:	68 71 82 10 f0       	push   $0xf0108271
f01041ed:	e8 23 fb ff ff       	call   f0103d15 <cprintf>
f01041f2:	83 c4 10             	add    $0x10,%esp
	}
}
f01041f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01041f8:	c9                   	leave  
f01041f9:	c3                   	ret    

f01041fa <page_fault_handler>:
	}
}

void
page_fault_handler(struct Trapframe *tf)
{
f01041fa:	55                   	push   %ebp
f01041fb:	89 e5                	mov    %esp,%ebp
f01041fd:	57                   	push   %edi
f01041fe:	56                   	push   %esi
f01041ff:	53                   	push   %ebx
f0104200:	83 ec 1c             	sub    $0x1c,%esp
f0104203:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104206:	0f 20 d0             	mov    %cr2,%eax
f0104209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// cprintf("Page Fault: 0x%08x\n", fault_va);

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT)
f010420c:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0104211:	75 17                	jne    f010422a <page_fault_handler+0x30>
    	panic("page_fault_handler : page fault in kernel\n");
f0104213:	83 ec 04             	sub    $0x4,%esp
f0104216:	68 2c 84 10 f0       	push   $0xf010842c
f010421b:	68 63 01 00 00       	push   $0x163
f0104220:	68 84 82 10 f0       	push   $0xf0108284
f0104225:	e8 3e be ff ff       	call   f0100068 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

    if (curenv->env_pgfault_upcall != NULL) {
f010422a:	e8 d9 20 00 00       	call   f0106308 <cpunum>
f010422f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104236:	29 c2                	sub    %eax,%edx
f0104238:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010423b:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0104242:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104246:	0f 84 01 01 00 00    	je     f010434d <page_fault_handler+0x153>
    	// cprintf("user page fault, exist env's page fault upcall \n");
    	// exist env's page fault upcall
		// void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

    	struct UTrapframe * ut;
    	if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp <= UXSTACKTOP - 1) {
f010424c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010424f:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f0104255:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010425b:	77 25                	ja     f0104282 <page_fault_handler+0x88>
    		// already in user exception stack, should first push an empty 32-bit word
    		ut = (struct UTrapframe *)((void *)tf->tf_esp - sizeof(struct UTrapframe) - 4);
f010425d:	83 e8 38             	sub    $0x38,%eax
f0104260:	89 45 e0             	mov    %eax,-0x20(%ebp)
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe) + 4, PTE_U | PTE_W);
f0104263:	e8 a0 20 00 00       	call   f0106308 <cpunum>
f0104268:	6a 06                	push   $0x6
f010426a:	6a 38                	push   $0x38
f010426c:	ff 75 e0             	pushl  -0x20(%ebp)
f010426f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104272:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104278:	e8 f5 f0 ff ff       	call   f0103372 <user_mem_assert>
f010427d:	83 c4 10             	add    $0x10,%esp
f0104280:	eb 26                	jmp    f01042a8 <page_fault_handler+0xae>
    	} else {
    		// it's the first time in user exception stack
    		ut = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe), PTE_U | PTE_W);
f0104282:	e8 81 20 00 00       	call   f0106308 <cpunum>
f0104287:	6a 06                	push   $0x6
f0104289:	6a 34                	push   $0x34
f010428b:	68 cc ff bf ee       	push   $0xeebfffcc
f0104290:	6b c0 74             	imul   $0x74,%eax,%eax
f0104293:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104299:	e8 d4 f0 ff ff       	call   f0103372 <user_mem_assert>
f010429e:	83 c4 10             	add    $0x10,%esp
    		// already in user exception stack, should first push an empty 32-bit word
    		ut = (struct UTrapframe *)((void *)tf->tf_esp - sizeof(struct UTrapframe) - 4);
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe) + 4, PTE_U | PTE_W);
    	} else {
    		// it's the first time in user exception stack
    		ut = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f01042a1:	c7 45 e0 cc ff bf ee 	movl   $0xeebfffcc,-0x20(%ebp)
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe), PTE_U | PTE_W);
    	}
    	
    	ut->utf_esp = tf->tf_esp;
f01042a8:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01042ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01042ae:	89 42 30             	mov    %eax,0x30(%edx)
    	ut->utf_eflags = tf->tf_eflags;
f01042b1:	8b 43 38             	mov    0x38(%ebx),%eax
f01042b4:	89 42 2c             	mov    %eax,0x2c(%edx)
    	ut->utf_eip = tf->tf_eip;
f01042b7:	8b 43 30             	mov    0x30(%ebx),%eax
f01042ba:	89 42 28             	mov    %eax,0x28(%edx)
		ut->utf_regs = tf->tf_regs;
f01042bd:	89 d7                	mov    %edx,%edi
f01042bf:	83 c7 08             	add    $0x8,%edi
f01042c2:	89 de                	mov    %ebx,%esi
f01042c4:	b8 20 00 00 00       	mov    $0x20,%eax
f01042c9:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01042cf:	74 03                	je     f01042d4 <page_fault_handler+0xda>
f01042d1:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01042d2:	b0 1f                	mov    $0x1f,%al
f01042d4:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01042da:	74 05                	je     f01042e1 <page_fault_handler+0xe7>
f01042dc:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01042de:	83 e8 02             	sub    $0x2,%eax
f01042e1:	89 c1                	mov    %eax,%ecx
f01042e3:	c1 e9 02             	shr    $0x2,%ecx
f01042e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01042e8:	a8 02                	test   $0x2,%al
f01042ea:	74 02                	je     f01042ee <page_fault_handler+0xf4>
f01042ec:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01042ee:	a8 01                	test   $0x1,%al
f01042f0:	74 01                	je     f01042f3 <page_fault_handler+0xf9>
f01042f2:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		ut->utf_err = tf->tf_err;
f01042f3:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01042f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01042f9:	89 42 04             	mov    %eax,0x4(%edx)
		ut->utf_fault_va = fault_va;
f01042fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01042ff:	89 02                	mov    %eax,(%edx)

		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0104301:	e8 02 20 00 00       	call   f0106308 <cpunum>
f0104306:	6b c0 74             	imul   $0x74,%eax,%eax
f0104309:	8b 98 28 20 21 f0    	mov    -0xfdedfd8(%eax),%ebx
f010430f:	e8 f4 1f 00 00       	call   f0106308 <cpunum>
f0104314:	6b c0 74             	imul   $0x74,%eax,%eax
f0104317:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010431d:	8b 40 64             	mov    0x64(%eax),%eax
f0104320:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (uint32_t)ut;
f0104323:	e8 e0 1f 00 00       	call   f0106308 <cpunum>
f0104328:	6b c0 74             	imul   $0x74,%eax,%eax
f010432b:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104331:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104334:	89 50 3c             	mov    %edx,0x3c(%eax)
    	env_run(curenv);
f0104337:	e8 cc 1f 00 00       	call   f0106308 <cpunum>
f010433c:	83 ec 0c             	sub    $0xc,%esp
f010433f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104342:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104348:	e8 64 f7 ff ff       	call   f0103ab1 <env_run>
    } else {
    	// cprintf("user page fault, env_pgfault_upcall == NULL\n");
   	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010434d:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104350:	e8 b3 1f 00 00       	call   f0106308 <cpunum>
    } else {
    	// cprintf("user page fault, env_pgfault_upcall == NULL\n");
   	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104355:	56                   	push   %esi
f0104356:	ff 75 e4             	pushl  -0x1c(%ebp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104359:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104360:	29 c2                	sub    %eax,%edx
f0104362:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104365:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
    } else {
    	// cprintf("user page fault, env_pgfault_upcall == NULL\n");
   	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010436c:	ff 70 48             	pushl  0x48(%eax)
f010436f:	68 58 84 10 f0       	push   $0xf0108458
f0104374:	e8 9c f9 ff ff       	call   f0103d15 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104379:	89 1c 24             	mov    %ebx,(%esp)
f010437c:	e8 f4 fc ff ff       	call   f0104075 <print_trapframe>
	env_destroy(curenv);
f0104381:	e8 82 1f 00 00       	call   f0106308 <cpunum>
f0104386:	83 c4 04             	add    $0x4,%esp
f0104389:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104390:	29 c2                	sub    %eax,%edx
f0104392:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104395:	ff 34 85 28 20 21 f0 	pushl  -0xfdedfd8(,%eax,4)
f010439c:	e8 53 f6 ff ff       	call   f01039f4 <env_destroy>
f01043a1:	83 c4 10             	add    $0x10,%esp
}
f01043a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01043a7:	5b                   	pop    %ebx
f01043a8:	5e                   	pop    %esi
f01043a9:	5f                   	pop    %edi
f01043aa:	c9                   	leave  
f01043ab:	c3                   	ret    

f01043ac <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01043ac:	55                   	push   %ebp
f01043ad:	89 e5                	mov    %esp,%ebp
f01043af:	57                   	push   %edi
f01043b0:	56                   	push   %esi
f01043b1:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01043b4:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01043b5:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f01043bc:	74 01                	je     f01043bf <trap+0x13>
		asm volatile("hlt");
f01043be:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01043bf:	e8 44 1f 00 00       	call   f0106308 <cpunum>
f01043c4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01043cb:	29 c2                	sub    %eax,%edx
f01043cd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01043d0:	8d 14 85 20 20 21 f0 	lea    -0xfdedfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01043d7:	b8 01 00 00 00       	mov    $0x1,%eax
f01043dc:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01043e0:	83 f8 02             	cmp    $0x2,%eax
f01043e3:	75 10                	jne    f01043f5 <trap+0x49>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01043e5:	83 ec 0c             	sub    $0xc,%esp
f01043e8:	68 60 94 12 f0       	push   $0xf0129460
f01043ed:	e8 cd 21 00 00       	call   f01065bf <spin_lock>
f01043f2:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01043f5:	9c                   	pushf  
f01043f6:	58                   	pop    %eax
		lock_kernel();

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01043f7:	f6 c4 02             	test   $0x2,%ah
f01043fa:	74 19                	je     f0104415 <trap+0x69>
f01043fc:	68 90 82 10 f0       	push   $0xf0108290
f0104401:	68 97 7d 10 f0       	push   $0xf0107d97
f0104406:	68 29 01 00 00       	push   $0x129
f010440b:	68 84 82 10 f0       	push   $0xf0108284
f0104410:	e8 53 bc ff ff       	call   f0100068 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104415:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104419:	83 e0 03             	and    $0x3,%eax
f010441c:	83 f8 03             	cmp    $0x3,%eax
f010441f:	0f 85 dc 00 00 00    	jne    f0104501 <trap+0x155>
f0104425:	83 ec 0c             	sub    $0xc,%esp
f0104428:	68 60 94 12 f0       	push   $0xf0129460
f010442d:	e8 8d 21 00 00       	call   f01065bf <spin_lock>
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();

		assert(curenv);
f0104432:	e8 d1 1e 00 00       	call   f0106308 <cpunum>
f0104437:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010443e:	29 c2                	sub    %eax,%edx
f0104440:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104443:	83 c4 10             	add    $0x10,%esp
f0104446:	83 3c 85 28 20 21 f0 	cmpl   $0x0,-0xfdedfd8(,%eax,4)
f010444d:	00 
f010444e:	75 19                	jne    f0104469 <trap+0xbd>
f0104450:	68 a9 82 10 f0       	push   $0xf01082a9
f0104455:	68 97 7d 10 f0       	push   $0xf0107d97
f010445a:	68 32 01 00 00       	push   $0x132
f010445f:	68 84 82 10 f0       	push   $0xf0108284
f0104464:	e8 ff bb ff ff       	call   f0100068 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104469:	e8 9a 1e 00 00       	call   f0106308 <cpunum>
f010446e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104475:	29 c2                	sub    %eax,%edx
f0104477:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010447a:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0104481:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104485:	75 41                	jne    f01044c8 <trap+0x11c>
			env_free(curenv);
f0104487:	e8 7c 1e 00 00       	call   f0106308 <cpunum>
f010448c:	83 ec 0c             	sub    $0xc,%esp
f010448f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104496:	29 c2                	sub    %eax,%edx
f0104498:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010449b:	ff 34 85 28 20 21 f0 	pushl  -0xfdedfd8(,%eax,4)
f01044a2:	e8 a5 f3 ff ff       	call   f010384c <env_free>
			curenv = NULL;
f01044a7:	e8 5c 1e 00 00       	call   f0106308 <cpunum>
f01044ac:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044b3:	29 c2                	sub    %eax,%edx
f01044b5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01044b8:	c7 04 85 28 20 21 f0 	movl   $0x0,-0xfdedfd8(,%eax,4)
f01044bf:	00 00 00 00 
			sched_yield();
f01044c3:	e8 13 03 00 00       	call   f01047db <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01044c8:	e8 3b 1e 00 00       	call   f0106308 <cpunum>
f01044cd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044d4:	29 c2                	sub    %eax,%edx
f01044d6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01044d9:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f01044e0:	b9 11 00 00 00       	mov    $0x11,%ecx
f01044e5:	89 c7                	mov    %eax,%edi
f01044e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01044e9:	e8 1a 1e 00 00       	call   f0106308 <cpunum>
f01044ee:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044f5:	29 c2                	sub    %eax,%edx
f01044f7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01044fa:	8b 34 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104501:	89 35 60 1a 21 f0    	mov    %esi,0xf0211a60
	// LAB 3: Your code here.
    // cprintf("CPU %d, TRAP NUM : %u\n", cpunum(), tf->tf_trapno);
    
    int r;

	if (tf->tf_trapno == T_DEBUG) {
f0104507:	8b 46 28             	mov    0x28(%esi),%eax
f010450a:	83 f8 01             	cmp    $0x1,%eax
f010450d:	75 11                	jne    f0104520 <trap+0x174>
		monitor(tf);
f010450f:	83 ec 0c             	sub    $0xc,%esp
f0104512:	56                   	push   %esi
f0104513:	e8 4d cb ff ff       	call   f0101065 <monitor>
f0104518:	83 c4 10             	add    $0x10,%esp
f010451b:	e9 e8 00 00 00       	jmp    f0104608 <trap+0x25c>
		return;
	}
	if (tf->tf_trapno == T_PGFLT) {
f0104520:	83 f8 0e             	cmp    $0xe,%eax
f0104523:	75 11                	jne    f0104536 <trap+0x18a>
		page_fault_handler(tf);
f0104525:	83 ec 0c             	sub    $0xc,%esp
f0104528:	56                   	push   %esi
f0104529:	e8 cc fc ff ff       	call   f01041fa <page_fault_handler>
f010452e:	83 c4 10             	add    $0x10,%esp
f0104531:	e9 d2 00 00 00       	jmp    f0104608 <trap+0x25c>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f0104536:	83 f8 03             	cmp    $0x3,%eax
f0104539:	75 11                	jne    f010454c <trap+0x1a0>
		monitor(tf);
f010453b:	83 ec 0c             	sub    $0xc,%esp
f010453e:	56                   	push   %esi
f010453f:	e8 21 cb ff ff       	call   f0101065 <monitor>
f0104544:	83 c4 10             	add    $0x10,%esp
f0104547:	e9 bc 00 00 00       	jmp    f0104608 <trap+0x25c>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f010454c:	83 f8 30             	cmp    $0x30,%eax
f010454f:	75 24                	jne    f0104575 <trap+0x1c9>
		r = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104551:	83 ec 08             	sub    $0x8,%esp
f0104554:	ff 76 04             	pushl  0x4(%esi)
f0104557:	ff 36                	pushl  (%esi)
f0104559:	ff 76 10             	pushl  0x10(%esi)
f010455c:	ff 76 18             	pushl  0x18(%esi)
f010455f:	ff 76 14             	pushl  0x14(%esi)
f0104562:	ff 76 1c             	pushl  0x1c(%esi)
f0104565:	e8 8e 03 00 00       	call   f01048f8 <syscall>
                       tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = r;
f010456a:	89 46 1c             	mov    %eax,0x1c(%esi)
f010456d:	83 c4 20             	add    $0x20,%esp
f0104570:	e9 93 00 00 00       	jmp    f0104608 <trap+0x25c>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104575:	83 f8 27             	cmp    $0x27,%eax
f0104578:	75 1a                	jne    f0104594 <trap+0x1e8>
		cprintf("Spurious interrupt on irq 7\n");
f010457a:	83 ec 0c             	sub    $0xc,%esp
f010457d:	68 b0 82 10 f0       	push   $0xf01082b0
f0104582:	e8 8e f7 ff ff       	call   f0103d15 <cprintf>
		print_trapframe(tf);
f0104587:	89 34 24             	mov    %esi,(%esp)
f010458a:	e8 e6 fa ff ff       	call   f0104075 <print_trapframe>
f010458f:	83 c4 10             	add    $0x10,%esp
f0104592:	eb 74                	jmp    f0104608 <trap+0x25c>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104594:	83 f8 20             	cmp    $0x20,%eax
f0104597:	75 0a                	jne    f01045a3 <trap+0x1f7>
		lapic_eoi();
f0104599:	e8 c4 1e 00 00       	call   f0106462 <lapic_eoi>
		sched_yield();
f010459e:	e8 38 02 00 00       	call   f01047db <sched_yield>
		return;
	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
    if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f01045a3:	83 f8 21             	cmp    $0x21,%eax
f01045a6:	75 07                	jne    f01045af <trap+0x203>
        kbd_intr();
f01045a8:	e8 b1 c0 ff ff       	call   f010065e <kbd_intr>
f01045ad:	eb 59                	jmp    f0104608 <trap+0x25c>
        return;
    }

    if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f01045af:	83 f8 24             	cmp    $0x24,%eax
f01045b2:	75 07                	jne    f01045bb <trap+0x20f>
        serial_intr();
f01045b4:	e8 8a c0 ff ff       	call   f0100643 <serial_intr>
f01045b9:	eb 4d                	jmp    f0104608 <trap+0x25c>
        return;
    }

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01045bb:	83 ec 0c             	sub    $0xc,%esp
f01045be:	56                   	push   %esi
f01045bf:	e8 b1 fa ff ff       	call   f0104075 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01045c4:	83 c4 10             	add    $0x10,%esp
f01045c7:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01045cc:	75 17                	jne    f01045e5 <trap+0x239>
		panic("unhandled trap in kernel");
f01045ce:	83 ec 04             	sub    $0x4,%esp
f01045d1:	68 cd 82 10 f0       	push   $0xf01082cd
f01045d6:	68 0e 01 00 00       	push   $0x10e
f01045db:	68 84 82 10 f0       	push   $0xf0108284
f01045e0:	e8 83 ba ff ff       	call   f0100068 <_panic>
	else {
		env_destroy(curenv);
f01045e5:	e8 1e 1d 00 00       	call   f0106308 <cpunum>
f01045ea:	83 ec 0c             	sub    $0xc,%esp
f01045ed:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01045f4:	29 c2                	sub    %eax,%edx
f01045f6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01045f9:	ff 34 85 28 20 21 f0 	pushl  -0xfdedfd8(,%eax,4)
f0104600:	e8 ef f3 ff ff       	call   f01039f4 <env_destroy>
f0104605:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0104608:	e8 fb 1c 00 00       	call   f0106308 <cpunum>
f010460d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104614:	29 c2                	sub    %eax,%edx
f0104616:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104619:	83 3c 85 28 20 21 f0 	cmpl   $0x0,-0xfdedfd8(,%eax,4)
f0104620:	00 
f0104621:	74 3e                	je     f0104661 <trap+0x2b5>
f0104623:	e8 e0 1c 00 00       	call   f0106308 <cpunum>
f0104628:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010462f:	29 c2                	sub    %eax,%edx
f0104631:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104634:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f010463b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010463f:	75 20                	jne    f0104661 <trap+0x2b5>
		// cprintf("Env\n");
		env_run(curenv);
f0104641:	e8 c2 1c 00 00       	call   f0106308 <cpunum>
f0104646:	83 ec 0c             	sub    $0xc,%esp
f0104649:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104650:	29 c2                	sub    %eax,%edx
f0104652:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104655:	ff 34 85 28 20 21 f0 	pushl  -0xfdedfd8(,%eax,4)
f010465c:	e8 50 f4 ff ff       	call   f0103ab1 <env_run>
	} else {
		// cprintf("trap sched_yield\n");
		sched_yield();
f0104661:	e8 75 01 00 00       	call   f01047db <sched_yield>
	...

f0104668 <vec0>:
.data
.align 2
.globl vectors
vectors:
.text
	MYTH_NOEC(vec0, T_DIVIDE)
f0104668:	6a 00                	push   $0x0
f010466a:	6a 00                	push   $0x0
f010466c:	e9 a5 4d 02 00       	jmp    f0129416 <_alltraps>
f0104671:	90                   	nop

f0104672 <vec1>:
 	MYTH_NOEC(vec1, T_DEBUG)
f0104672:	6a 00                	push   $0x0
f0104674:	6a 01                	push   $0x1
f0104676:	e9 9b 4d 02 00       	jmp    f0129416 <_alltraps>
f010467b:	90                   	nop

f010467c <vec2>:
 	MYTH_NOEC(vec2, T_NMI)
f010467c:	6a 00                	push   $0x0
f010467e:	6a 02                	push   $0x2
f0104680:	e9 91 4d 02 00       	jmp    f0129416 <_alltraps>
f0104685:	90                   	nop

f0104686 <vec3>:
 	MYTH_NOEC(vec3, T_BRKPT)
f0104686:	6a 00                	push   $0x0
f0104688:	6a 03                	push   $0x3
f010468a:	e9 87 4d 02 00       	jmp    f0129416 <_alltraps>
f010468f:	90                   	nop

f0104690 <vec4>:
 	MYTH_NOEC(vec4, T_OFLOW)
f0104690:	6a 00                	push   $0x0
f0104692:	6a 04                	push   $0x4
f0104694:	e9 7d 4d 02 00       	jmp    f0129416 <_alltraps>
f0104699:	90                   	nop

f010469a <vec6>:
 	MYTH_NULL()
 	MYTH_NOEC(vec6, T_BOUND)
f010469a:	6a 00                	push   $0x0
f010469c:	6a 05                	push   $0x5
f010469e:	e9 73 4d 02 00       	jmp    f0129416 <_alltraps>
f01046a3:	90                   	nop

f01046a4 <vec7>:
	MYTH_NOEC(vec7, T_DEVICE)
f01046a4:	6a 00                	push   $0x0
f01046a6:	6a 07                	push   $0x7
f01046a8:	e9 69 4d 02 00       	jmp    f0129416 <_alltraps>
f01046ad:	90                   	nop

f01046ae <vec8>:
 	MYTH(vec8, T_DBLFLT)
f01046ae:	6a 08                	push   $0x8
f01046b0:	e9 61 4d 02 00       	jmp    f0129416 <_alltraps>
f01046b5:	90                   	nop

f01046b6 <vec10>:
 	MYTH_NULL()
 	MYTH(vec10, T_TSS)
f01046b6:	6a 0a                	push   $0xa
f01046b8:	e9 59 4d 02 00       	jmp    f0129416 <_alltraps>
f01046bd:	90                   	nop

f01046be <vec11>:
 	MYTH(vec11, T_SEGNP)
f01046be:	6a 0b                	push   $0xb
f01046c0:	e9 51 4d 02 00       	jmp    f0129416 <_alltraps>
f01046c5:	90                   	nop

f01046c6 <vec12>:
 	MYTH(vec12, T_STACK)
f01046c6:	6a 0c                	push   $0xc
f01046c8:	e9 49 4d 02 00       	jmp    f0129416 <_alltraps>
f01046cd:	90                   	nop

f01046ce <vec13>:
 	MYTH(vec13, T_GPFLT)
f01046ce:	6a 0d                	push   $0xd
f01046d0:	e9 41 4d 02 00       	jmp    f0129416 <_alltraps>
f01046d5:	90                   	nop

f01046d6 <vec14>:
 	MYTH(vec14, T_PGFLT) 
f01046d6:	6a 0e                	push   $0xe
f01046d8:	e9 39 4d 02 00       	jmp    f0129416 <_alltraps>
f01046dd:	90                   	nop

f01046de <vec16>:
 	MYTH_NULL()
 	MYTH_NOEC(vec16, T_FPERR)
f01046de:	6a 00                	push   $0x0
f01046e0:	6a 10                	push   $0x10
f01046e2:	e9 2f 4d 02 00       	jmp    f0129416 <_alltraps>
f01046e7:	90                   	nop

f01046e8 <vec17>:
 	MYTH(vec17, T_ALIGN)
f01046e8:	6a 11                	push   $0x11
f01046ea:	e9 27 4d 02 00       	jmp    f0129416 <_alltraps>
f01046ef:	90                   	nop

f01046f0 <vec18>:
 	MYTH_NOEC(vec18, T_MCHK)
f01046f0:	6a 00                	push   $0x0
f01046f2:	6a 12                	push   $0x12
f01046f4:	e9 1d 4d 02 00       	jmp    f0129416 <_alltraps>
f01046f9:	90                   	nop

f01046fa <vec19>:
 	MYTH_NOEC(vec19, T_SIMDERR)
f01046fa:	6a 00                	push   $0x0
f01046fc:	6a 13                	push   $0x13
f01046fe:	e9 13 4d 02 00       	jmp    f0129416 <_alltraps>
	...

f0104704 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104704:	55                   	push   %ebp
f0104705:	89 e5                	mov    %esp,%ebp
f0104707:	83 ec 08             	sub    $0x8,%esp
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010470a:	8b 15 3c 12 21 f0    	mov    0xf021123c,%edx
		     envs[i].env_status == ENV_RUNNING ||
f0104710:	8b 42 54             	mov    0x54(%edx),%eax
f0104713:	48                   	dec    %eax
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104714:	83 f8 02             	cmp    $0x2,%eax
f0104717:	76 44                	jbe    f010475d <sched_halt+0x59>
			else cprintf("ENV_RUNNING\n");
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
f0104719:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f010471e:	8b 8a d0 00 00 00    	mov    0xd0(%edx),%ecx
f0104724:	49                   	dec    %ecx
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104725:	83 f9 02             	cmp    $0x2,%ecx
f0104728:	76 0d                	jbe    f0104737 <sched_halt+0x33>
			else cprintf("ENV_RUNNING\n");
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
f010472a:	40                   	inc    %eax
f010472b:	83 c2 7c             	add    $0x7c,%edx
f010472e:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104733:	75 e9                	jne    f010471e <sched_halt+0x1a>
f0104735:	eb 07                	jmp    f010473e <sched_halt+0x3a>
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	
	if (i == NENV) {
f0104737:	3d 00 04 00 00       	cmp    $0x400,%eax
f010473c:	75 1f                	jne    f010475d <sched_halt+0x59>
		cprintf("No runnable environments in the system!\n");
f010473e:	83 ec 0c             	sub    $0xc,%esp
f0104741:	68 d0 84 10 f0       	push   $0xf01084d0
f0104746:	e8 ca f5 ff ff       	call   f0103d15 <cprintf>
f010474b:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010474e:	83 ec 0c             	sub    $0xc,%esp
f0104751:	6a 00                	push   $0x0
f0104753:	e8 0d c9 ff ff       	call   f0101065 <monitor>
f0104758:	83 c4 10             	add    $0x10,%esp
f010475b:	eb f1                	jmp    f010474e <sched_halt+0x4a>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010475d:	e8 a6 1b 00 00       	call   f0106308 <cpunum>
f0104762:	6b c0 74             	imul   $0x74,%eax,%eax
f0104765:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f010476c:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010476f:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104774:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104779:	77 12                	ja     f010478d <sched_halt+0x89>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010477b:	50                   	push   %eax
f010477c:	68 e4 69 10 f0       	push   $0xf01069e4
f0104781:	6a 58                	push   $0x58
f0104783:	68 f9 84 10 f0       	push   $0xf01084f9
f0104788:	e8 db b8 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010478d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104792:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104795:	e8 6e 1b 00 00       	call   f0106308 <cpunum>
f010479a:	6b d0 74             	imul   $0x74,%eax,%edx
f010479d:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01047a3:	b8 02 00 00 00       	mov    $0x2,%eax
f01047a8:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01047ac:	83 ec 0c             	sub    $0xc,%esp
f01047af:	68 60 94 12 f0       	push   $0xf0129460
f01047b4:	e8 c1 1e 00 00       	call   f010667a <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01047b9:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01047bb:	e8 48 1b 00 00       	call   f0106308 <cpunum>
f01047c0:	6b c0 74             	imul   $0x74,%eax,%eax
	// Release the big kernel lock as if we were "leaving" the kernel
	
	unlock_kernel();
	
	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01047c3:	8b 80 30 20 21 f0    	mov    -0xfdedfd0(%eax),%eax
f01047c9:	bd 00 00 00 00       	mov    $0x0,%ebp
f01047ce:	89 c4                	mov    %eax,%esp
f01047d0:	6a 00                	push   $0x0
f01047d2:	6a 00                	push   $0x0
f01047d4:	fb                   	sti    
f01047d5:	f4                   	hlt    
f01047d6:	83 c4 10             	add    $0x10,%esp
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01047d9:	c9                   	leave  
f01047da:	c3                   	ret    

f01047db <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01047db:	55                   	push   %ebp
f01047dc:	89 e5                	mov    %esp,%ebp
f01047de:	56                   	push   %esi
f01047df:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int now_env, i;
	if (curenv) {			// thiscpu->cpu_env
f01047e0:	e8 23 1b 00 00       	call   f0106308 <cpunum>
f01047e5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01047ec:	29 c2                	sub    %eax,%edx
f01047ee:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01047f1:	83 3c 85 28 20 21 f0 	cmpl   $0x0,-0xfdedfd8(,%eax,4)
f01047f8:	00 
f01047f9:	74 2e                	je     f0104829 <sched_yield+0x4e>
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
f01047fb:	e8 08 1b 00 00       	call   f0106308 <cpunum>
f0104800:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104807:	29 c2                	sub    %eax,%edx
f0104809:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010480c:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0104813:	8b 40 48             	mov    0x48(%eax),%eax
f0104816:	8d 40 01             	lea    0x1(%eax),%eax
f0104819:	25 ff 03 00 00       	and    $0x3ff,%eax
f010481e:	79 0e                	jns    f010482e <sched_yield+0x53>
f0104820:	48                   	dec    %eax
f0104821:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0104826:	40                   	inc    %eax
f0104827:	eb 05                	jmp    f010482e <sched_yield+0x53>
	} else {
		now_env = 0;
f0104829:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
		if (envs[now_env].env_status == ENV_RUNNABLE) {
f010482e:	8b 1d 3c 12 21 f0    	mov    0xf021123c,%ebx
f0104834:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010483b:	89 c1                	mov    %eax,%ecx
f010483d:	c1 e1 07             	shl    $0x7,%ecx
f0104840:	29 d1                	sub    %edx,%ecx
f0104842:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f0104845:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f0104849:	0f 85 8f 00 00 00    	jne    f01048de <sched_yield+0x103>
f010484f:	eb 26                	jmp    f0104877 <sched_yield+0x9c>
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f0104851:	40                   	inc    %eax
f0104852:	25 ff 03 00 80       	and    $0x800003ff,%eax
f0104857:	79 07                	jns    f0104860 <sched_yield+0x85>
f0104859:	48                   	dec    %eax
f010485a:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f010485f:	40                   	inc    %eax
		if (envs[now_env].env_status == ENV_RUNNABLE) {
f0104860:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
f0104867:	89 c1                	mov    %eax,%ecx
f0104869:	c1 e1 07             	shl    $0x7,%ecx
f010486c:	29 f1                	sub    %esi,%ecx
f010486e:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f0104871:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f0104875:	75 09                	jne    f0104880 <sched_yield+0xa5>
			env_run(&envs[now_env]);	
f0104877:	83 ec 0c             	sub    $0xc,%esp
f010487a:	51                   	push   %ecx
f010487b:	e8 31 f2 ff ff       	call   f0103ab1 <env_run>
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f0104880:	4a                   	dec    %edx
f0104881:	75 ce                	jne    f0104851 <sched_yield+0x76>
		if (envs[now_env].env_status == ENV_RUNNABLE) {
			env_run(&envs[now_env]);	
		}
	}

	if (curenv && curenv->env_status == ENV_RUNNING) {
f0104883:	e8 80 1a 00 00       	call   f0106308 <cpunum>
f0104888:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010488f:	29 c2                	sub    %eax,%edx
f0104891:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104894:	83 3c 85 28 20 21 f0 	cmpl   $0x0,-0xfdedfd8(,%eax,4)
f010489b:	00 
f010489c:	74 34                	je     f01048d2 <sched_yield+0xf7>
f010489e:	e8 65 1a 00 00       	call   f0106308 <cpunum>
f01048a3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01048aa:	29 c2                	sub    %eax,%edx
f01048ac:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01048af:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f01048b6:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01048ba:	75 16                	jne    f01048d2 <sched_yield+0xf7>
		env_run(curenv);
f01048bc:	e8 47 1a 00 00       	call   f0106308 <cpunum>
f01048c1:	83 ec 0c             	sub    $0xc,%esp
f01048c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01048c7:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01048cd:	e8 df f1 ff ff       	call   f0103ab1 <env_run>
	}

	// sched_halt never returns
	sched_halt();
f01048d2:	e8 2d fe ff ff       	call   f0104704 <sched_halt>
}
f01048d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01048da:	5b                   	pop    %ebx
f01048db:	5e                   	pop    %esi
f01048dc:	c9                   	leave  
f01048dd:	c3                   	ret    
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f01048de:	40                   	inc    %eax
f01048df:	25 ff 03 00 80       	and    $0x800003ff,%eax
f01048e4:	79 07                	jns    f01048ed <sched_yield+0x112>
f01048e6:	48                   	dec    %eax
f01048e7:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f01048ec:	40                   	inc    %eax
f01048ed:	ba ff 03 00 00       	mov    $0x3ff,%edx
f01048f2:	e9 69 ff ff ff       	jmp    f0104860 <sched_yield+0x85>
	...

f01048f8 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01048f8:	55                   	push   %ebp
f01048f9:	89 e5                	mov    %esp,%ebp
f01048fb:	57                   	push   %edi
f01048fc:	56                   	push   %esi
f01048fd:	53                   	push   %ebx
f01048fe:	83 ec 3c             	sub    $0x3c,%esp
f0104901:	8b 45 08             	mov    0x8(%ebp),%eax
f0104904:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104907:	8b 75 10             	mov    0x10(%ebp),%esi
f010490a:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Return any appropriate return value.
	// LAB 3: Your code here.
    
    // cprintf("SYSCALLNO %d\n", syscallno);
	int r = 0;
    switch (syscallno) {
f010490d:	83 f8 0f             	cmp    $0xf,%eax
f0104910:	0f 87 b4 07 00 00    	ja     f01050ca <syscall+0x7d2>
f0104916:	ff 24 85 08 85 10 f0 	jmp    *-0xfef7af8(,%eax,4)
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env * new_env;
	int r = env_alloc(&new_env, curenv->env_id);
f010491d:	e8 e6 19 00 00       	call   f0106308 <cpunum>
f0104922:	83 ec 08             	sub    $0x8,%esp
f0104925:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010492c:	29 c2                	sub    %eax,%edx
f010492e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104931:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0104938:	ff 70 48             	pushl  0x48(%eax)
f010493b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010493e:	50                   	push   %eax
f010493f:	e8 49 ec ff ff       	call   f010358d <env_alloc>
	if (r < 0) return r;
f0104944:	83 c4 10             	add    $0x10,%esp
f0104947:	85 c0                	test   %eax,%eax
f0104949:	0f 88 a3 07 00 00    	js     f01050f2 <syscall+0x7fa>
	
	new_env->env_status = ENV_NOT_RUNNABLE;
f010494f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104952:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memcpy((void *)(&new_env->env_tf), (void*)(&curenv->env_tf), sizeof(struct Trapframe));
f0104959:	e8 aa 19 00 00       	call   f0106308 <cpunum>
f010495e:	83 ec 04             	sub    $0x4,%esp
f0104961:	6a 44                	push   $0x44
f0104963:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010496a:	29 c2                	sub    %eax,%edx
f010496c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010496f:	ff 34 85 28 20 21 f0 	pushl  -0xfdedfd8(,%eax,4)
f0104976:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104979:	e8 0f 14 00 00       	call   f0105d8d <memcpy>
	
	// for children environment, return 0
	new_env->env_tf.tf_regs.reg_eax = 0;
f010497e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104981:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return new_env->env_id;
f0104988:	8b 40 48             	mov    0x48(%eax),%eax
f010498b:	83 c4 10             	add    $0x10,%esp
    // cprintf("SYSCALLNO %d\n", syscallno);
	int r = 0;
    switch (syscallno) {
    	case SYS_exofork:
    		r = sys_exofork();
    		break;
f010498e:	e9 5f 07 00 00       	jmp    f01050f2 <syscall+0x7fa>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	// LAB 4: Your code here.

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
f0104993:	83 fe 02             	cmp    $0x2,%esi
f0104996:	74 05                	je     f010499d <syscall+0xa5>
f0104998:	83 fe 04             	cmp    $0x4,%esi
f010499b:	75 2a                	jne    f01049c7 <syscall+0xcf>
		return -E_INVAL;

	struct Env * env;
	int r = envid2env(envid, &env, 1);
f010499d:	83 ec 04             	sub    $0x4,%esp
f01049a0:	6a 01                	push   $0x1
f01049a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049a5:	50                   	push   %eax
f01049a6:	53                   	push   %ebx
f01049a7:	e8 96 ea ff ff       	call   f0103442 <envid2env>
	if (r < 0) return r;
f01049ac:	83 c4 10             	add    $0x10,%esp
f01049af:	85 c0                	test   %eax,%eax
f01049b1:	0f 88 3b 07 00 00    	js     f01050f2 <syscall+0x7fa>
	env->env_status = status;
f01049b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049ba:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f01049bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01049c2:	e9 2b 07 00 00       	jmp    f01050f2 <syscall+0x7fa>
	// check whether the current environment has permission to set
	// envid's status.
	// LAB 4: Your code here.

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
		return -E_INVAL;
f01049c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
    	case SYS_exofork:
    		r = sys_exofork();
    		break;
    	case SYS_env_set_status:
    		r = sys_env_set_status((envid_t)a1, (int)a2);
    		break;
f01049cc:	e9 21 07 00 00       	jmp    f01050f2 <syscall+0x7fa>
	//   allocated!
	// LAB 4: Your code here.
	// cprintf("In kernel sys_page_alloc function\n");

	struct Env * env;
	int r = envid2env(envid, &env, 1);
f01049d1:	83 ec 04             	sub    $0x4,%esp
f01049d4:	6a 01                	push   $0x1
f01049d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049d9:	50                   	push   %eax
f01049da:	53                   	push   %ebx
f01049db:	e8 62 ea ff ff       	call   f0103442 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f01049e0:	83 c4 10             	add    $0x10,%esp
f01049e3:	85 c0                	test   %eax,%eax
f01049e5:	0f 88 88 00 00 00    	js     f0104a73 <syscall+0x17b>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f01049eb:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01049f1:	0f 87 86 00 00 00    	ja     f0104a7d <syscall+0x185>
f01049f7:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f01049fd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104a03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a08:	39 d6                	cmp    %edx,%esi
f0104a0a:	0f 85 e2 06 00 00    	jne    f01050f2 <syscall+0x7fa>
	
	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;
f0104a10:	89 fa                	mov    %edi,%edx
f0104a12:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f0104a18:	83 fa 05             	cmp    $0x5,%edx
f0104a1b:	0f 85 d1 06 00 00    	jne    f01050f2 <syscall+0x7fa>

	struct PageInfo * pg = page_alloc(ALLOC_ZERO);
f0104a21:	83 ec 0c             	sub    $0xc,%esp
f0104a24:	6a 01                	push   $0x1
f0104a26:	e8 d6 cb ff ff       	call   f0101601 <page_alloc>
f0104a2b:	89 c3                	mov    %eax,%ebx
	if (pg == NULL) return -E_NO_MEM;
f0104a2d:	83 c4 10             	add    $0x10,%esp
f0104a30:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104a35:	85 db                	test   %ebx,%ebx
f0104a37:	0f 84 b5 06 00 00    	je     f01050f2 <syscall+0x7fa>
	if (page_insert(env->env_pgdir, pg, va, perm) < 0) {
f0104a3d:	57                   	push   %edi
f0104a3e:	56                   	push   %esi
f0104a3f:	53                   	push   %ebx
f0104a40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a43:	ff 70 60             	pushl  0x60(%eax)
f0104a46:	e8 62 ce ff ff       	call   f01018ad <page_insert>
f0104a4b:	89 c2                	mov    %eax,%edx
f0104a4d:	83 c4 10             	add    $0x10,%esp
		// page_insert fails, should free the page you allocated!  
		page_free(pg);
		return -E_NO_MEM;
	}
	return 0;
f0104a50:	b8 00 00 00 00       	mov    $0x0,%eax
	
	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;

	struct PageInfo * pg = page_alloc(ALLOC_ZERO);
	if (pg == NULL) return -E_NO_MEM;
	if (page_insert(env->env_pgdir, pg, va, perm) < 0) {
f0104a55:	85 d2                	test   %edx,%edx
f0104a57:	0f 89 95 06 00 00    	jns    f01050f2 <syscall+0x7fa>
		// page_insert fails, should free the page you allocated!  
		page_free(pg);
f0104a5d:	83 ec 0c             	sub    $0xc,%esp
f0104a60:	53                   	push   %ebx
f0104a61:	e8 25 cc ff ff       	call   f010168b <page_free>
f0104a66:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104a69:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104a6e:	e9 7f 06 00 00       	jmp    f01050f2 <syscall+0x7fa>
	// LAB 4: Your code here.
	// cprintf("In kernel sys_page_alloc function\n");

	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;
f0104a73:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104a78:	e9 75 06 00 00       	jmp    f01050f2 <syscall+0x7fa>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104a7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a82:	e9 6b 06 00 00       	jmp    f01050f2 <syscall+0x7fa>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	// LAB 4: Your code here.

	struct Env * dstenv, * srcenv;
	int r = envid2env(dstenvid, &dstenv, 1);
f0104a87:	83 ec 04             	sub    $0x4,%esp
f0104a8a:	6a 01                	push   $0x1
f0104a8c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a8f:	50                   	push   %eax
f0104a90:	57                   	push   %edi
f0104a91:	e8 ac e9 ff ff       	call   f0103442 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104a96:	83 c4 10             	add    $0x10,%esp
f0104a99:	85 c0                	test   %eax,%eax
f0104a9b:	0f 88 cd 00 00 00    	js     f0104b6e <syscall+0x276>
	r = envid2env(srcenvid, &srcenv, 1);
f0104aa1:	83 ec 04             	sub    $0x4,%esp
f0104aa4:	6a 01                	push   $0x1
f0104aa6:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104aa9:	50                   	push   %eax
f0104aaa:	53                   	push   %ebx
f0104aab:	e8 92 e9 ff ff       	call   f0103442 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104ab0:	83 c4 10             	add    $0x10,%esp
f0104ab3:	85 c0                	test   %eax,%eax
f0104ab5:	0f 88 bd 00 00 00    	js     f0104b78 <syscall+0x280>

	if ((uint32_t)srcva >= UTOP || ROUNDUP(srcva, PGSIZE) != srcva) return -E_INVAL;
f0104abb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ac0:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104ac6:	0f 87 26 06 00 00    	ja     f01050f2 <syscall+0x7fa>
f0104acc:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0104ad2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104ad8:	39 d6                	cmp    %edx,%esi
f0104ada:	0f 85 12 06 00 00    	jne    f01050f2 <syscall+0x7fa>
	if ((uint32_t)dstva >= UTOP || ROUNDUP(dstva, PGSIZE) != dstva) return -E_INVAL;
f0104ae0:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104ae7:	0f 87 05 06 00 00    	ja     f01050f2 <syscall+0x7fa>
f0104aed:	8b 55 18             	mov    0x18(%ebp),%edx
f0104af0:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0104af6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104afc:	39 55 18             	cmp    %edx,0x18(%ebp)
f0104aff:	0f 85 ed 05 00 00    	jne    f01050f2 <syscall+0x7fa>


	// struct PageInfo * page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
	struct PageInfo * pg;
	pte_t * pte;
	pg = page_lookup(srcenv->env_pgdir, srcva, &pte);
f0104b05:	83 ec 04             	sub    $0x4,%esp
f0104b08:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104b0b:	50                   	push   %eax
f0104b0c:	56                   	push   %esi
f0104b0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104b10:	ff 70 60             	pushl  0x60(%eax)
f0104b13:	e8 99 cc ff ff       	call   f01017b1 <page_lookup>
f0104b18:	89 c2                	mov    %eax,%edx
	if (pg == NULL) return -E_INVAL;		
f0104b1a:	83 c4 10             	add    $0x10,%esp
f0104b1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b22:	85 d2                	test   %edx,%edx
f0104b24:	0f 84 c8 05 00 00    	je     f01050f2 <syscall+0x7fa>

	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;
f0104b2a:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104b2d:	81 e1 fd f1 ff ff    	and    $0xfffff1fd,%ecx
f0104b33:	83 f9 05             	cmp    $0x5,%ecx
f0104b36:	0f 85 b6 05 00 00    	jne    f01050f2 <syscall+0x7fa>
	
	if ((perm & PTE_W) && ((*pte) & PTE_W) == 0) return -E_INVAL;
f0104b3c:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104b40:	74 0c                	je     f0104b4e <syscall+0x256>
f0104b42:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104b45:	f6 01 02             	testb  $0x2,(%ecx)
f0104b48:	0f 84 a4 05 00 00    	je     f01050f2 <syscall+0x7fa>

	// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	if (page_insert(dstenv->env_pgdir, pg, dstva, perm) < 0) return -E_NO_MEM;
f0104b4e:	ff 75 1c             	pushl  0x1c(%ebp)
f0104b51:	ff 75 18             	pushl  0x18(%ebp)
f0104b54:	52                   	push   %edx
f0104b55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b58:	ff 70 60             	pushl  0x60(%eax)
f0104b5b:	e8 4d cd ff ff       	call   f01018ad <page_insert>
f0104b60:	83 c4 10             	add    $0x10,%esp
f0104b63:	c1 f8 1f             	sar    $0x1f,%eax
f0104b66:	83 e0 fc             	and    $0xfffffffc,%eax
f0104b69:	e9 84 05 00 00       	jmp    f01050f2 <syscall+0x7fa>
	//   check the current permissions on the page.
	// LAB 4: Your code here.

	struct Env * dstenv, * srcenv;
	int r = envid2env(dstenvid, &dstenv, 1);
	if (r < 0) return -E_BAD_ENV;
f0104b6e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104b73:	e9 7a 05 00 00       	jmp    f01050f2 <syscall+0x7fa>
	r = envid2env(srcenvid, &srcenv, 1);
	if (r < 0) return -E_BAD_ENV;
f0104b78:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104b7d:	e9 70 05 00 00       	jmp    f01050f2 <syscall+0x7fa>
{
	// Hint: This function is a wrapper around page_remove().
	// LAB 4: Your code here.

	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104b82:	83 ec 04             	sub    $0x4,%esp
f0104b85:	6a 01                	push   $0x1
f0104b87:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104b8a:	50                   	push   %eax
f0104b8b:	53                   	push   %ebx
f0104b8c:	e8 b1 e8 ff ff       	call   f0103442 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104b91:	83 c4 10             	add    $0x10,%esp
f0104b94:	85 c0                	test   %eax,%eax
f0104b96:	78 3d                	js     f0104bd5 <syscall+0x2dd>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104b98:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104b9e:	77 3f                	ja     f0104bdf <syscall+0x2e7>
f0104ba0:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0104ba6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104bac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104bb1:	39 d6                	cmp    %edx,%esi
f0104bb3:	0f 85 39 05 00 00    	jne    f01050f2 <syscall+0x7fa>
	
	// void page_remove(pde_t *pgdir, void *va)
	page_remove(env->env_pgdir, va);
f0104bb9:	83 ec 08             	sub    $0x8,%esp
f0104bbc:	56                   	push   %esi
f0104bbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104bc0:	ff 70 60             	pushl  0x60(%eax)
f0104bc3:	e8 98 cc ff ff       	call   f0101860 <page_remove>
f0104bc8:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104bcb:	b8 00 00 00 00       	mov    $0x0,%eax
f0104bd0:	e9 1d 05 00 00       	jmp    f01050f2 <syscall+0x7fa>
	// Hint: This function is a wrapper around page_remove().
	// LAB 4: Your code here.

	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;
f0104bd5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104bda:	e9 13 05 00 00       	jmp    f01050f2 <syscall+0x7fa>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104bdf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104be4:	e9 09 05 00 00       	jmp    f01050f2 <syscall+0x7fa>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// cprintf("In kernel sys_env_set_pgfault_upcall function\n");
	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104be9:	83 ec 04             	sub    $0x4,%esp
f0104bec:	6a 01                	push   $0x1
f0104bee:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104bf1:	50                   	push   %eax
f0104bf2:	53                   	push   %ebx
f0104bf3:	e8 4a e8 ff ff       	call   f0103442 <envid2env>
	if (r < 0) return r;
f0104bf8:	83 c4 10             	add    $0x10,%esp
f0104bfb:	85 c0                	test   %eax,%eax
f0104bfd:	0f 88 ef 04 00 00    	js     f01050f2 <syscall+0x7fa>

	env->env_pgfault_upcall = func;
f0104c03:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c06:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f0104c09:	b8 00 00 00 00       	mov    $0x0,%eax
    	case SYS_page_unmap:
    		r = sys_page_unmap((envid_t)a1, (void *)a2);
    		break;
    	case SYS_env_set_pgfault_upcall:
    		r = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
    		break;
f0104c0e:	e9 df 04 00 00       	jmp    f01050f2 <syscall+0x7fa>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104c13:	e8 c3 fb ff ff       	call   f01047db <sched_yield>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, (void *)s, len, PTE_U);
f0104c18:	e8 eb 16 00 00       	call   f0106308 <cpunum>
f0104c1d:	6a 04                	push   $0x4
f0104c1f:	56                   	push   %esi
f0104c20:	53                   	push   %ebx
f0104c21:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c28:	29 c2                	sub    %eax,%edx
f0104c2a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c2d:	ff 34 85 28 20 21 f0 	pushl  -0xfdedfd8(,%eax,4)
f0104c34:	e8 39 e7 ff ff       	call   f0103372 <user_mem_assert>
    
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104c39:	83 c4 0c             	add    $0xc,%esp
f0104c3c:	53                   	push   %ebx
f0104c3d:	56                   	push   %esi
f0104c3e:	68 9f 6d 10 f0       	push   $0xf0106d9f
f0104c43:	e8 cd f0 ff ff       	call   f0103d15 <cprintf>
f0104c48:	83 c4 10             	add    $0x10,%esp
    		sys_yield();
    		r = 0;
    		break;
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            r = 0;
f0104c4b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c50:	e9 9d 04 00 00       	jmp    f01050f2 <syscall+0x7fa>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104c55:	e8 16 ba ff ff       	call   f0100670 <cons_getc>
            sys_cputs((char *)a1, (size_t)a2);
            r = 0;
            break;
        case SYS_cgetc:
            r = sys_cgetc();
            break;
f0104c5a:	e9 93 04 00 00       	jmp    f01050f2 <syscall+0x7fa>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104c5f:	e8 a4 16 00 00       	call   f0106308 <cpunum>
f0104c64:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c6b:	29 c2                	sub    %eax,%edx
f0104c6d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c70:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0104c77:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_cgetc:
            r = sys_cgetc();
            break;
        case SYS_getenvid:
            r = sys_getenvid();
            break;
f0104c7a:	e9 73 04 00 00       	jmp    f01050f2 <syscall+0x7fa>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104c7f:	83 ec 04             	sub    $0x4,%esp
f0104c82:	6a 01                	push   $0x1
f0104c84:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104c87:	50                   	push   %eax
f0104c88:	53                   	push   %ebx
f0104c89:	e8 b4 e7 ff ff       	call   f0103442 <envid2env>
f0104c8e:	83 c4 10             	add    $0x10,%esp
f0104c91:	85 c0                	test   %eax,%eax
f0104c93:	0f 88 59 04 00 00    	js     f01050f2 <syscall+0x7fa>
		return r;
	env_destroy(e);
f0104c99:	83 ec 0c             	sub    $0xc,%esp
f0104c9c:	ff 75 e0             	pushl  -0x20(%ebp)
f0104c9f:	e8 50 ed ff ff       	call   f01039f4 <env_destroy>
f0104ca4:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104ca7:	b8 00 00 00 00       	mov    $0x0,%eax
        case SYS_getenvid:
            r = sys_getenvid();
            break;
        case SYS_env_destroy:
            r = sys_env_destroy(a1);
            break;
f0104cac:	e9 41 04 00 00       	jmp    f01050f2 <syscall+0x7fa>
	
	// Any environment is allowed to send IPC messages to any other environment, 
	// and the kernel does no special permission checking other than verifying that the target envid is valid.
	// So set the checkperm falg to 0
	struct Env * env;
	int r = envid2env(envid, &env, 0);	
f0104cb1:	83 ec 04             	sub    $0x4,%esp
f0104cb4:	6a 00                	push   $0x0
f0104cb6:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104cb9:	50                   	push   %eax
f0104cba:	53                   	push   %ebx
f0104cbb:	e8 82 e7 ff ff       	call   f0103442 <envid2env>
	//	-E_BAD_ENV if environment envid doesn't currently exist.
	if (r < 0) return -E_BAD_ENV;
f0104cc0:	83 c4 10             	add    $0x10,%esp
f0104cc3:	85 c0                	test   %eax,%eax
f0104cc5:	0f 88 06 01 00 00    	js     f0104dd1 <syscall+0x4d9>

	//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
	//		or another environment managed to send first.
	if (env->env_ipc_recving == false || env->env_ipc_from != 0) {
f0104ccb:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104cce:	80 7a 68 00          	cmpb   $0x0,0x68(%edx)
f0104cd2:	0f 84 03 01 00 00    	je     f0104ddb <syscall+0x4e3>
		return -E_IPC_NOT_RECV;
f0104cd8:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	//	-E_BAD_ENV if environment envid doesn't currently exist.
	if (r < 0) return -E_BAD_ENV;

	//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
	//		or another environment managed to send first.
	if (env->env_ipc_recving == false || env->env_ipc_from != 0) {
f0104cdd:	83 7a 74 00          	cmpl   $0x0,0x74(%edx)
f0104ce1:	0f 85 0b 04 00 00    	jne    f01050f2 <syscall+0x7fa>
		return -E_IPC_NOT_RECV;
	}

	//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
	if ((uint32_t)srcva < UTOP && ROUNDUP(srcva, PGSIZE) != srcva)
f0104ce7:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104ced:	0f 87 a5 00 00 00    	ja     f0104d98 <syscall+0x4a0>
f0104cf3:	8d 97 ff 0f 00 00    	lea    0xfff(%edi),%edx
f0104cf9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		return -E_INVAL;
f0104cff:	b0 fd                	mov    $0xfd,%al
	if (env->env_ipc_recving == false || env->env_ipc_from != 0) {
		return -E_IPC_NOT_RECV;
	}

	//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
	if ((uint32_t)srcva < UTOP && ROUNDUP(srcva, PGSIZE) != srcva)
f0104d01:	39 d7                	cmp    %edx,%edi
f0104d03:	0f 85 e9 03 00 00    	jne    f01050f2 <syscall+0x7fa>
		return -E_INVAL;

	//	-E_INVAL if srcva < UTOP and perm is inappropriate
	if ((uint32_t)srcva < UTOP && (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0))) 
f0104d09:	8b 55 18             	mov    0x18(%ebp),%edx
f0104d0c:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f0104d12:	83 fa 05             	cmp    $0x5,%edx
f0104d15:	0f 85 d7 03 00 00    	jne    f01050f2 <syscall+0x7fa>
		return -E_INVAL;

	//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's address space 
	if ((uint32_t)srcva < UTOP) {
		pte_t * pte;
		struct PageInfo * pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104d1b:	e8 e8 15 00 00       	call   f0106308 <cpunum>
f0104d20:	83 ec 04             	sub    $0x4,%esp
f0104d23:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104d26:	52                   	push   %edx
f0104d27:	57                   	push   %edi
f0104d28:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d2b:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104d31:	ff 70 60             	pushl  0x60(%eax)
f0104d34:	e8 78 ca ff ff       	call   f01017b1 <page_lookup>
f0104d39:	89 c1                	mov    %eax,%ecx
		if (pg == NULL) return -E_INVAL;
f0104d3b:	83 c4 10             	add    $0x10,%esp
f0104d3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d43:	85 c9                	test   %ecx,%ecx
f0104d45:	0f 84 a7 03 00 00    	je     f01050f2 <syscall+0x7fa>

		//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
		//		current environment's address space.
		if ((perm & PTE_W) && (*pte & PTE_W) == 0) 
f0104d4b:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104d4f:	74 0c                	je     f0104d5d <syscall+0x465>
f0104d51:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104d54:	f6 02 02             	testb  $0x2,(%edx)
f0104d57:	0f 84 95 03 00 00    	je     f01050f2 <syscall+0x7fa>
			return -E_INVAL;

		//	-E_NO_MEM if there's not enough memory to map srcva in envid's
		//		address space.
		if (env->env_ipc_dstva != NULL) {
f0104d5d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104d60:	8b 42 6c             	mov    0x6c(%edx),%eax
f0104d63:	85 c0                	test   %eax,%eax
f0104d65:	74 2a                	je     f0104d91 <syscall+0x499>
			r = page_insert(env->env_pgdir, pg, env->env_ipc_dstva, perm);
f0104d67:	ff 75 18             	pushl  0x18(%ebp)
f0104d6a:	50                   	push   %eax
f0104d6b:	51                   	push   %ecx
f0104d6c:	ff 72 60             	pushl  0x60(%edx)
f0104d6f:	e8 39 cb ff ff       	call   f01018ad <page_insert>
f0104d74:	89 c2                	mov    %eax,%edx
			if (r < 0) return -E_NO_MEM;
f0104d76:	83 c4 10             	add    $0x10,%esp
f0104d79:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104d7e:	85 d2                	test   %edx,%edx
f0104d80:	0f 88 6c 03 00 00    	js     f01050f2 <syscall+0x7fa>
			env->env_ipc_perm = perm;
f0104d86:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d89:	8b 55 18             	mov    0x18(%ebp),%edx
f0104d8c:	89 50 78             	mov    %edx,0x78(%eax)
f0104d8f:	eb 07                	jmp    f0104d98 <syscall+0x4a0>
		} else env->env_ipc_perm = 0;	
f0104d91:	c7 42 78 00 00 00 00 	movl   $0x0,0x78(%edx)
	}

	env->env_ipc_recving = false;
f0104d98:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104d9b:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// ... I mistake write env->env_ipc_from = envid in the first
	// ... Debug a lot of time...
	env->env_ipc_from = curenv->env_id;
f0104d9f:	e8 64 15 00 00       	call   f0106308 <cpunum>
f0104da4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104da7:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104dad:	8b 40 48             	mov    0x48(%eax),%eax
f0104db0:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_value = value;
f0104db3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104db6:	89 70 70             	mov    %esi,0x70(%eax)
	env->env_tf.tf_regs.reg_eax = 0;
f0104db9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	env->env_status = ENV_RUNNABLE;
f0104dc0:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	return 0;
f0104dc7:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dcc:	e9 21 03 00 00       	jmp    f01050f2 <syscall+0x7fa>
	// and the kernel does no special permission checking other than verifying that the target envid is valid.
	// So set the checkperm falg to 0
	struct Env * env;
	int r = envid2env(envid, &env, 0);	
	//	-E_BAD_ENV if environment envid doesn't currently exist.
	if (r < 0) return -E_BAD_ENV;
f0104dd1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104dd6:	e9 17 03 00 00       	jmp    f01050f2 <syscall+0x7fa>

	//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
	//		or another environment managed to send first.
	if (env->env_ipc_recving == false || env->env_ipc_from != 0) {
		return -E_IPC_NOT_RECV;
f0104ddb:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0104de0:	e9 0d 03 00 00       	jmp    f01050f2 <syscall+0x7fa>
static int
sys_ipc_recv(void *dstva)
{
	// cprintf("I am receiving???\n");
	// LAB 4: Your code here.
	if (((uint32_t)dstva < UTOP) && ROUNDUP(dstva, PGSIZE) != dstva) return -E_INVAL;
f0104de5:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104deb:	77 13                	ja     f0104e00 <syscall+0x508>
f0104ded:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f0104df3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104df8:	39 c3                	cmp    %eax,%ebx
f0104dfa:	0f 85 d1 02 00 00    	jne    f01050d1 <syscall+0x7d9>
	curenv->env_ipc_recving = true;			// Env is blocked receiving
f0104e00:	e8 03 15 00 00       	call   f0106308 <cpunum>
f0104e05:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e08:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104e0e:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;			// VA at which to map received page
f0104e12:	e8 f1 14 00 00       	call   f0106308 <cpunum>
f0104e17:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e1a:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104e20:	89 58 6c             	mov    %ebx,0x6c(%eax)
	curenv->env_ipc_from = 0;				// set from to 0
f0104e23:	e8 e0 14 00 00       	call   f0106308 <cpunum>
f0104e28:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e2b:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104e31:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;	// mark it not runnable
f0104e38:	e8 cb 14 00 00       	call   f0106308 <cpunum>
f0104e3d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e40:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104e46:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();							// give up the CPU
f0104e4d:	e8 89 f9 ff ff       	call   f01047db <sched_yield>

static int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
	struct Env * env;
	int r = envid2env(envid, &env, 1);	
f0104e52:	83 ec 04             	sub    $0x4,%esp
f0104e55:	6a 01                	push   $0x1
f0104e57:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e5a:	50                   	push   %eax
f0104e5b:	53                   	push   %ebx
f0104e5c:	e8 e1 e5 ff ff       	call   f0103442 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104e61:	83 c4 10             	add    $0x10,%esp
f0104e64:	c1 f8 1f             	sar    $0x1f,%eax
f0104e67:	83 e0 fe             	and    $0xfffffffe,%eax
f0104e6a:	e9 83 02 00 00       	jmp    f01050f2 <syscall+0x7fa>
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104e6f:	83 ec 04             	sub    $0x4,%esp
f0104e72:	6a 01                	push   $0x1
f0104e74:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e77:	50                   	push   %eax
f0104e78:	53                   	push   %ebx
f0104e79:	e8 c4 e5 ff ff       	call   f0103442 <envid2env>
	if (r < 0) return -E_BAD_ENV;	
f0104e7e:	83 c4 10             	add    $0x10,%esp
f0104e81:	85 c0                	test   %eax,%eax
f0104e83:	78 35                	js     f0104eba <syscall+0x5c2>

	user_mem_assert (env, tf, sizeof(struct Trapframe), PTE_U);
f0104e85:	6a 04                	push   $0x4
f0104e87:	6a 44                	push   $0x44
f0104e89:	56                   	push   %esi
f0104e8a:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e8d:	e8 e0 e4 ff ff       	call   f0103372 <user_mem_assert>

	env->env_tf = *tf;
f0104e92:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e95:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104e9a:	89 c7                	mov    %eax,%edi
f0104e9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	env->env_tf.tf_cs |= 3;
f0104e9e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ea1:	66 83 48 34 03       	orw    $0x3,0x34(%eax)
	env->env_tf.tf_eflags |= FL_IF;
f0104ea6:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
f0104ead:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104eb0:	b8 00 00 00 00       	mov    $0x0,%eax
f0104eb5:	e9 38 02 00 00       	jmp    f01050f2 <syscall+0x7fa>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;	
f0104eba:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
        case SYS_set_priority:
        	r = sys_set_priority((envid_t)a1, (uint32_t)a2);
        	break;
        case SYS_env_set_trapframe:
        	r = sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
        	break;
f0104ebf:	e9 2e 02 00 00       	jmp    f01050f2 <syscall+0x7fa>

static int
sys_exec(uint32_t eip, uint32_t esp, void * v_ph, uint32_t phnum)
{
	// set new eip and esp
	memset((void *)(&curenv->env_tf.tf_regs), 0, sizeof(struct PushRegs));
f0104ec4:	e8 3f 14 00 00       	call   f0106308 <cpunum>
f0104ec9:	83 ec 04             	sub    $0x4,%esp
f0104ecc:	6a 20                	push   $0x20
f0104ece:	6a 00                	push   $0x0
f0104ed0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ed7:	29 c2                	sub    %eax,%edx
f0104ed9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104edc:	ff 34 85 28 20 21 f0 	pushl  -0xfdedfd8(,%eax,4)
f0104ee3:	e8 f1 0d 00 00       	call   f0105cd9 <memset>
	curenv->env_tf.tf_eip = eip;
f0104ee8:	e8 1b 14 00 00       	call   f0106308 <cpunum>
f0104eed:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ef4:	29 c2                	sub    %eax,%edx
f0104ef6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ef9:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0104f00:	89 58 30             	mov    %ebx,0x30(%eax)
	curenv->env_tf.tf_esp = esp;
f0104f03:	e8 00 14 00 00       	call   f0106308 <cpunum>
f0104f08:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104f0f:	29 c2                	sub    %eax,%edx
f0104f11:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f14:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0104f1b:	89 70 3c             	mov    %esi,0x3c(%eax)
	uint32_t va, end_addr;
	struct PageInfo * pg;

	// Elf 
	struct Proghdr * ph = (struct Proghdr *) v_ph; 
	for (i = 0; i < phnum; i++, ph++) {
f0104f1e:	83 c4 10             	add    $0x10,%esp
f0104f21:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
f0104f25:	0f 84 0c 01 00 00    	je     f0105037 <syscall+0x73f>
	uint32_t now_addr = MYTEMPLATE;
	uint32_t va, end_addr;
	struct PageInfo * pg;

	// Elf 
	struct Proghdr * ph = (struct Proghdr *) v_ph; 
f0104f2b:	89 7d cc             	mov    %edi,-0x34(%ebp)
	memset((void *)(&curenv->env_tf.tf_regs), 0, sizeof(struct PushRegs));
	curenv->env_tf.tf_eip = eip;
	curenv->env_tf.tf_esp = esp;

	int perm, i;
	uint32_t now_addr = MYTEMPLATE;
f0104f2e:	bf 00 00 00 80       	mov    $0x80000000,%edi
	uint32_t va, end_addr;
	struct PageInfo * pg;

	// Elf 
	struct Proghdr * ph = (struct Proghdr *) v_ph; 
	for (i = 0; i < phnum; i++, ph++) {
f0104f33:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		if (ph->p_type != ELF_PROG_LOAD)
f0104f3a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104f3d:	83 38 01             	cmpl   $0x1,(%eax)
f0104f40:	0f 85 dd 00 00 00    	jne    f0105023 <syscall+0x72b>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
f0104f46:	89 c2                	mov    %eax,%edx
f0104f48:	8b 40 18             	mov    0x18(%eax),%eax
f0104f4b:	83 e0 02             	and    $0x2,%eax
	// Elf 
	struct Proghdr * ph = (struct Proghdr *) v_ph; 
	for (i = 0; i < phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
f0104f4e:	83 f8 01             	cmp    $0x1,%eax
f0104f51:	19 c0                	sbb    %eax,%eax
f0104f53:	83 e0 fe             	and    $0xfffffffe,%eax
f0104f56:	83 c0 07             	add    $0x7,%eax
f0104f59:	89 45 d0             	mov    %eax,-0x30(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;

		// Move to real virtual address
		end_addr = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
f0104f5c:	8b 72 08             	mov    0x8(%edx),%esi
f0104f5f:	89 f0                	mov    %esi,%eax
f0104f61:	03 42 14             	add    0x14(%edx),%eax
f0104f64:	05 ff 0f 00 00       	add    $0xfff,%eax
f0104f69:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104f6e:	89 45 c8             	mov    %eax,-0x38(%ebp)
		for (va = ROUNDDOWN(ph->p_va, PGSIZE); va != end_addr; now_addr += PGSIZE, va += PGSIZE) {
f0104f71:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0104f77:	39 f0                	cmp    %esi,%eax
f0104f79:	0f 84 a4 00 00 00    	je     f0105023 <syscall+0x72b>
f0104f7f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
			if ((pg = page_lookup(curenv->env_pgdir, (void *)now_addr, NULL)) == NULL) 
f0104f82:	e8 81 13 00 00       	call   f0106308 <cpunum>
f0104f87:	83 ec 04             	sub    $0x4,%esp
f0104f8a:	6a 00                	push   $0x0
f0104f8c:	57                   	push   %edi
f0104f8d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104f94:	29 c2                	sub    %eax,%edx
f0104f96:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f99:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0104fa0:	ff 70 60             	pushl  0x60(%eax)
f0104fa3:	e8 09 c8 ff ff       	call   f01017b1 <page_lookup>
f0104fa8:	89 c3                	mov    %eax,%ebx
f0104faa:	83 c4 10             	add    $0x10,%esp
f0104fad:	85 c0                	test   %eax,%eax
f0104faf:	0f 84 23 01 00 00    	je     f01050d8 <syscall+0x7e0>
				return -E_NO_MEM;		// no page
			if (page_insert(curenv->env_pgdir, pg, (void *)va, perm) < 0)
f0104fb5:	e8 4e 13 00 00       	call   f0106308 <cpunum>
f0104fba:	ff 75 d0             	pushl  -0x30(%ebp)
f0104fbd:	56                   	push   %esi
f0104fbe:	53                   	push   %ebx
f0104fbf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104fc6:	29 c2                	sub    %eax,%edx
f0104fc8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104fcb:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0104fd2:	ff 70 60             	pushl  0x60(%eax)
f0104fd5:	e8 d3 c8 ff ff       	call   f01018ad <page_insert>
f0104fda:	83 c4 10             	add    $0x10,%esp
f0104fdd:	85 c0                	test   %eax,%eax
f0104fdf:	0f 88 fa 00 00 00    	js     f01050df <syscall+0x7e7>
				return -E_NO_MEM;		
			page_remove(curenv->env_pgdir, (void *)now_addr);
f0104fe5:	e8 1e 13 00 00       	call   f0106308 <cpunum>
f0104fea:	83 ec 08             	sub    $0x8,%esp
f0104fed:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104ff0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ff7:	29 c2                	sub    %eax,%edx
f0104ff9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ffc:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f0105003:	ff 70 60             	pushl  0x60(%eax)
f0105006:	e8 55 c8 ff ff       	call   f0101860 <page_remove>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;

		// Move to real virtual address
		end_addr = ROUNDUP(ph->p_va + ph->p_memsz, PGSIZE);
		for (va = ROUNDDOWN(ph->p_va, PGSIZE); va != end_addr; now_addr += PGSIZE, va += PGSIZE) {
f010500b:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0105011:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0105017:	83 c4 10             	add    $0x10,%esp
f010501a:	39 75 c8             	cmp    %esi,-0x38(%ebp)
f010501d:	0f 85 5c ff ff ff    	jne    f0104f7f <syscall+0x687>
	uint32_t va, end_addr;
	struct PageInfo * pg;

	// Elf 
	struct Proghdr * ph = (struct Proghdr *) v_ph; 
	for (i = 0; i < phnum; i++, ph++) {
f0105023:	ff 45 c4             	incl   -0x3c(%ebp)
f0105026:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105029:	39 55 18             	cmp    %edx,0x18(%ebp)
f010502c:	76 0e                	jbe    f010503c <syscall+0x744>
f010502e:	83 45 cc 20          	addl   $0x20,-0x34(%ebp)
f0105032:	e9 03 ff ff ff       	jmp    f0104f3a <syscall+0x642>
	memset((void *)(&curenv->env_tf.tf_regs), 0, sizeof(struct PushRegs));
	curenv->env_tf.tf_eip = eip;
	curenv->env_tf.tf_esp = esp;

	int perm, i;
	uint32_t now_addr = MYTEMPLATE;
f0105037:	bf 00 00 00 80       	mov    $0x80000000,%edi
			page_remove(curenv->env_pgdir, (void *)now_addr);
		}
	}

	// New Stack
	if ((pg = page_lookup(curenv->env_pgdir, (void *)now_addr, NULL)) == NULL) 
f010503c:	e8 c7 12 00 00       	call   f0106308 <cpunum>
f0105041:	83 ec 04             	sub    $0x4,%esp
f0105044:	6a 00                	push   $0x0
f0105046:	57                   	push   %edi
f0105047:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010504e:	29 c2                	sub    %eax,%edx
f0105050:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105053:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f010505a:	ff 70 60             	pushl  0x60(%eax)
f010505d:	e8 4f c7 ff ff       	call   f01017b1 <page_lookup>
f0105062:	89 c3                	mov    %eax,%ebx
f0105064:	83 c4 10             	add    $0x10,%esp
f0105067:	85 c0                	test   %eax,%eax
f0105069:	74 7b                	je     f01050e6 <syscall+0x7ee>
		return -E_NO_MEM;
	if (page_insert(curenv->env_pgdir, pg, (void *)(USTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0) 
f010506b:	e8 98 12 00 00       	call   f0106308 <cpunum>
f0105070:	6a 07                	push   $0x7
f0105072:	68 00 d0 bf ee       	push   $0xeebfd000
f0105077:	53                   	push   %ebx
f0105078:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010507f:	29 c2                	sub    %eax,%edx
f0105081:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105084:	8b 04 85 28 20 21 f0 	mov    -0xfdedfd8(,%eax,4),%eax
f010508b:	ff 70 60             	pushl  0x60(%eax)
f010508e:	e8 1a c8 ff ff       	call   f01018ad <page_insert>
f0105093:	83 c4 10             	add    $0x10,%esp
f0105096:	85 c0                	test   %eax,%eax
f0105098:	78 53                	js     f01050ed <syscall+0x7f5>
		return -E_NO_MEM;
	page_remove(curenv->env_pgdir, (void *)now_addr);
f010509a:	e8 69 12 00 00       	call   f0106308 <cpunum>
f010509f:	83 ec 08             	sub    $0x8,%esp
f01050a2:	57                   	push   %edi
f01050a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01050a6:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01050ac:	ff 70 60             	pushl  0x60(%eax)
f01050af:	e8 ac c7 ff ff       	call   f0101860 <page_remove>
	
	env_run(curenv);		// never return
f01050b4:	e8 4f 12 00 00       	call   f0106308 <cpunum>
f01050b9:	83 c4 04             	add    $0x4,%esp
f01050bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01050bf:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01050c5:	e8 e7 e9 ff ff       	call   f0103ab1 <env_run>
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
    
    // cprintf("SYSCALLNO %d\n", syscallno);
	int r = 0;
f01050ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01050cf:	eb 21                	jmp    f01050f2 <syscall+0x7fa>
            break;
        case SYS_ipc_try_send:
        	r = sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
        	break;
        case SYS_ipc_recv:
        	r = sys_ipc_recv((void *)a1);
f01050d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050d6:	eb 1a                	jmp    f01050f2 <syscall+0x7fa>
        	break;
        case SYS_env_set_trapframe:
        	r = sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
        	break;
        case SYS_exec:
        	r = sys_exec((uint32_t)a1, (uint32_t)a2, (void *)a3, (uint32_t)a4);
f01050d8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01050dd:	eb 13                	jmp    f01050f2 <syscall+0x7fa>
f01050df:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01050e4:	eb 0c                	jmp    f01050f2 <syscall+0x7fa>
f01050e6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01050eb:	eb 05                	jmp    f01050f2 <syscall+0x7fa>
f01050ed:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        	break;
        dafult:
            r = -E_INVAL;
	}
	return r;
}
f01050f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050f5:	5b                   	pop    %ebx
f01050f6:	5e                   	pop    %esi
f01050f7:	5f                   	pop    %edi
f01050f8:	c9                   	leave  
f01050f9:	c3                   	ret    
	...

f01050fc <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01050fc:	55                   	push   %ebp
f01050fd:	89 e5                	mov    %esp,%ebp
f01050ff:	57                   	push   %edi
f0105100:	56                   	push   %esi
f0105101:	53                   	push   %ebx
f0105102:	83 ec 14             	sub    $0x14,%esp
f0105105:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105108:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010510b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010510e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105111:	8b 1a                	mov    (%edx),%ebx
f0105113:	8b 01                	mov    (%ecx),%eax
f0105115:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0105118:	39 c3                	cmp    %eax,%ebx
f010511a:	0f 8f 97 00 00 00    	jg     f01051b7 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0105120:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105127:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010512a:	01 d8                	add    %ebx,%eax
f010512c:	89 c7                	mov    %eax,%edi
f010512e:	c1 ef 1f             	shr    $0x1f,%edi
f0105131:	01 c7                	add    %eax,%edi
f0105133:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105135:	39 df                	cmp    %ebx,%edi
f0105137:	7c 31                	jl     f010516a <stab_binsearch+0x6e>
f0105139:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010513c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010513f:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0105144:	39 f0                	cmp    %esi,%eax
f0105146:	0f 84 b3 00 00 00    	je     f01051ff <stab_binsearch+0x103>
f010514c:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105150:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105154:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0105156:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105157:	39 d8                	cmp    %ebx,%eax
f0105159:	7c 0f                	jl     f010516a <stab_binsearch+0x6e>
f010515b:	0f b6 0a             	movzbl (%edx),%ecx
f010515e:	83 ea 0c             	sub    $0xc,%edx
f0105161:	39 f1                	cmp    %esi,%ecx
f0105163:	75 f1                	jne    f0105156 <stab_binsearch+0x5a>
f0105165:	e9 97 00 00 00       	jmp    f0105201 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010516a:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010516d:	eb 39                	jmp    f01051a8 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010516f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0105172:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0105174:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105177:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010517e:	eb 28                	jmp    f01051a8 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105180:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105183:	76 12                	jbe    f0105197 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0105185:	48                   	dec    %eax
f0105186:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105189:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010518c:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010518e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105195:	eb 11                	jmp    f01051a8 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105197:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010519a:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f010519c:	ff 45 0c             	incl   0xc(%ebp)
f010519f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01051a1:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01051a8:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f01051ab:	0f 8d 76 ff ff ff    	jge    f0105127 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01051b1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01051b5:	75 0d                	jne    f01051c4 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f01051b7:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01051ba:	8b 03                	mov    (%ebx),%eax
f01051bc:	48                   	dec    %eax
f01051bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01051c0:	89 02                	mov    %eax,(%edx)
f01051c2:	eb 55                	jmp    f0105219 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01051c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01051c7:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01051c9:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01051cc:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01051ce:	39 c1                	cmp    %eax,%ecx
f01051d0:	7d 26                	jge    f01051f8 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01051d2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01051d5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01051d8:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01051dd:	39 f2                	cmp    %esi,%edx
f01051df:	74 17                	je     f01051f8 <stab_binsearch+0xfc>
f01051e1:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01051e5:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01051e9:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01051ea:	39 c1                	cmp    %eax,%ecx
f01051ec:	7d 0a                	jge    f01051f8 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01051ee:	0f b6 1a             	movzbl (%edx),%ebx
f01051f1:	83 ea 0c             	sub    $0xc,%edx
f01051f4:	39 f3                	cmp    %esi,%ebx
f01051f6:	75 f1                	jne    f01051e9 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f01051f8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01051fb:	89 02                	mov    %eax,(%edx)
f01051fd:	eb 1a                	jmp    f0105219 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01051ff:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105201:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105204:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0105207:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010520b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010520e:	0f 82 5b ff ff ff    	jb     f010516f <stab_binsearch+0x73>
f0105214:	e9 67 ff ff ff       	jmp    f0105180 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0105219:	83 c4 14             	add    $0x14,%esp
f010521c:	5b                   	pop    %ebx
f010521d:	5e                   	pop    %esi
f010521e:	5f                   	pop    %edi
f010521f:	c9                   	leave  
f0105220:	c3                   	ret    

f0105221 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105221:	55                   	push   %ebp
f0105222:	89 e5                	mov    %esp,%ebp
f0105224:	57                   	push   %edi
f0105225:	56                   	push   %esi
f0105226:	53                   	push   %ebx
f0105227:	83 ec 2c             	sub    $0x2c,%esp
f010522a:	8b 75 08             	mov    0x8(%ebp),%esi
f010522d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105230:	c7 03 48 85 10 f0    	movl   $0xf0108548,(%ebx)
	info->eip_line = 0;
f0105236:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010523d:	c7 43 08 48 85 10 f0 	movl   $0xf0108548,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105244:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010524b:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010524e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105255:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010525b:	0f 87 ba 00 00 00    	ja     f010531b <debuginfo_eip+0xfa>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
f0105261:	e8 a2 10 00 00       	call   f0106308 <cpunum>
f0105266:	6a 04                	push   $0x4
f0105268:	6a 10                	push   $0x10
f010526a:	68 00 00 20 00       	push   $0x200000
f010526f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105276:	29 c2                	sub    %eax,%edx
f0105278:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010527b:	ff 34 85 28 20 21 f0 	pushl  -0xfdedfd8(,%eax,4)
f0105282:	e8 38 e0 ff ff       	call   f01032bf <user_mem_check>
f0105287:	83 c4 10             	add    $0x10,%esp
f010528a:	85 c0                	test   %eax,%eax
f010528c:	0f 88 11 02 00 00    	js     f01054a3 <debuginfo_eip+0x282>
			return -1;
		}

		stabs = usd->stabs;
f0105292:	a1 00 00 20 00       	mov    0x200000,%eax
f0105297:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f010529a:	8b 0d 04 00 20 00    	mov    0x200004,%ecx
f01052a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr = usd->stabstr;
f01052a3:	a1 08 00 20 00       	mov    0x200008,%eax
f01052a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f01052ab:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
f01052b1:	e8 52 10 00 00       	call   f0106308 <cpunum>
f01052b6:	89 c2                	mov    %eax,%edx
f01052b8:	6a 04                	push   $0x4
f01052ba:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01052bd:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01052c0:	50                   	push   %eax
f01052c1:	ff 75 d0             	pushl  -0x30(%ebp)
f01052c4:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01052cb:	29 d0                	sub    %edx,%eax
f01052cd:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01052d0:	ff 34 85 28 20 21 f0 	pushl  -0xfdedfd8(,%eax,4)
f01052d7:	e8 e3 df ff ff       	call   f01032bf <user_mem_check>
f01052dc:	83 c4 10             	add    $0x10,%esp
f01052df:	85 c0                	test   %eax,%eax
f01052e1:	0f 88 c3 01 00 00    	js     f01054aa <debuginfo_eip+0x289>
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f01052e7:	e8 1c 10 00 00       	call   f0106308 <cpunum>
f01052ec:	89 c2                	mov    %eax,%edx
f01052ee:	6a 04                	push   $0x4
f01052f0:	89 f8                	mov    %edi,%eax
f01052f2:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f01052f5:	50                   	push   %eax
f01052f6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01052f9:	6b c2 74             	imul   $0x74,%edx,%eax
f01052fc:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0105302:	e8 b8 df ff ff       	call   f01032bf <user_mem_check>
f0105307:	89 c2                	mov    %eax,%edx
f0105309:	83 c4 10             	add    $0x10,%esp
			return -1;
f010530c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0105311:	85 d2                	test   %edx,%edx
f0105313:	0f 88 ab 01 00 00    	js     f01054c4 <debuginfo_eip+0x2a3>
f0105319:	eb 1a                	jmp    f0105335 <debuginfo_eip+0x114>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010531b:	bf 2a e1 11 f0       	mov    $0xf011e12a,%edi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105320:	c7 45 d4 3d 4d 11 f0 	movl   $0xf0114d3d,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105327:	c7 45 cc 3c 4d 11 f0 	movl   $0xf0114d3c,-0x34(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010532e:	c7 45 d0 f0 8a 10 f0 	movl   $0xf0108af0,-0x30(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105335:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0105338:	0f 83 73 01 00 00    	jae    f01054b1 <debuginfo_eip+0x290>
f010533e:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0105342:	0f 85 70 01 00 00    	jne    f01054b8 <debuginfo_eip+0x297>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105348:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010534f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105352:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0105355:	c1 f8 02             	sar    $0x2,%eax
f0105358:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010535e:	48                   	dec    %eax
f010535f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105362:	83 ec 08             	sub    $0x8,%esp
f0105365:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105368:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010536b:	56                   	push   %esi
f010536c:	6a 64                	push   $0x64
f010536e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105371:	e8 86 fd ff ff       	call   f01050fc <stab_binsearch>
	if (lfile == 0)
f0105376:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105379:	83 c4 10             	add    $0x10,%esp
		return -1;
f010537c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0105381:	85 d2                	test   %edx,%edx
f0105383:	0f 84 3b 01 00 00    	je     f01054c4 <debuginfo_eip+0x2a3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105389:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f010538c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010538f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105392:	83 ec 08             	sub    $0x8,%esp
f0105395:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105398:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010539b:	56                   	push   %esi
f010539c:	6a 24                	push   $0x24
f010539e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01053a1:	e8 56 fd ff ff       	call   f01050fc <stab_binsearch>

	if (lfun <= rfun) {
f01053a6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01053a9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01053ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01053af:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01053b2:	83 c4 10             	add    $0x10,%esp
f01053b5:	39 c1                	cmp    %eax,%ecx
f01053b7:	7f 21                	jg     f01053da <debuginfo_eip+0x1b9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01053b9:	6b c1 0c             	imul   $0xc,%ecx,%eax
f01053bc:	03 45 d0             	add    -0x30(%ebp),%eax
f01053bf:	8b 10                	mov    (%eax),%edx
f01053c1:	89 f9                	mov    %edi,%ecx
f01053c3:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f01053c6:	39 ca                	cmp    %ecx,%edx
f01053c8:	73 06                	jae    f01053d0 <debuginfo_eip+0x1af>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01053ca:	03 55 d4             	add    -0x2c(%ebp),%edx
f01053cd:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01053d0:	8b 40 08             	mov    0x8(%eax),%eax
f01053d3:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01053d6:	29 c6                	sub    %eax,%esi
f01053d8:	eb 0f                	jmp    f01053e9 <debuginfo_eip+0x1c8>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01053da:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01053dd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01053e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		rline = rfile;
f01053e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01053e6:	89 45 c8             	mov    %eax,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01053e9:	83 ec 08             	sub    $0x8,%esp
f01053ec:	6a 3a                	push   $0x3a
f01053ee:	ff 73 08             	pushl  0x8(%ebx)
f01053f1:	e8 c1 08 00 00       	call   f0105cb7 <strfind>
f01053f6:	2b 43 08             	sub    0x8(%ebx),%eax
f01053f9:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f01053fc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01053ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    rfun = rline;
f0105402:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105405:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0105408:	83 c4 08             	add    $0x8,%esp
f010540b:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010540e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105411:	56                   	push   %esi
f0105412:	6a 44                	push   $0x44
f0105414:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105417:	e8 e0 fc ff ff       	call   f01050fc <stab_binsearch>
    if (lfun <= rfun) {
f010541c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010541f:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0105422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0105427:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f010542a:	0f 8f 94 00 00 00    	jg     f01054c4 <debuginfo_eip+0x2a3>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0105430:	6b ca 0c             	imul   $0xc,%edx,%ecx
f0105433:	03 4d d0             	add    -0x30(%ebp),%ecx
f0105436:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f010543a:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010543d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105440:	89 75 cc             	mov    %esi,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105443:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105446:	eb 04                	jmp    f010544c <debuginfo_eip+0x22b>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105448:	4a                   	dec    %edx
f0105449:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010544c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f010544f:	7c 19                	jl     f010546a <debuginfo_eip+0x249>
	       && stabs[lline].n_type != N_SOL
f0105451:	8a 48 fc             	mov    -0x4(%eax),%cl
f0105454:	80 f9 84             	cmp    $0x84,%cl
f0105457:	74 73                	je     f01054cc <debuginfo_eip+0x2ab>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105459:	80 f9 64             	cmp    $0x64,%cl
f010545c:	75 ea                	jne    f0105448 <debuginfo_eip+0x227>
f010545e:	83 38 00             	cmpl   $0x0,(%eax)
f0105461:	74 e5                	je     f0105448 <debuginfo_eip+0x227>
f0105463:	eb 67                	jmp    f01054cc <debuginfo_eip+0x2ab>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105465:	03 45 d4             	add    -0x2c(%ebp),%eax
f0105468:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010546a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010546d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105470:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105475:	39 ca                	cmp    %ecx,%edx
f0105477:	7d 4b                	jge    f01054c4 <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
f0105479:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010547c:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010547f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105482:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0105486:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105488:	eb 04                	jmp    f010548e <debuginfo_eip+0x26d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010548a:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010548d:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010548e:	39 f0                	cmp    %esi,%eax
f0105490:	7d 2d                	jge    f01054bf <debuginfo_eip+0x29e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105492:	8a 0a                	mov    (%edx),%cl
f0105494:	83 c2 0c             	add    $0xc,%edx
f0105497:	80 f9 a0             	cmp    $0xa0,%cl
f010549a:	74 ee                	je     f010548a <debuginfo_eip+0x269>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010549c:	b8 00 00 00 00       	mov    $0x0,%eax
f01054a1:	eb 21                	jmp    f01054c4 <debuginfo_eip+0x2a3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
f01054a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01054a8:	eb 1a                	jmp    f01054c4 <debuginfo_eip+0x2a3>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
f01054aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01054af:	eb 13                	jmp    f01054c4 <debuginfo_eip+0x2a3>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01054b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01054b6:	eb 0c                	jmp    f01054c4 <debuginfo_eip+0x2a3>
f01054b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01054bd:	eb 05                	jmp    f01054c4 <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01054bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01054c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01054c7:	5b                   	pop    %ebx
f01054c8:	5e                   	pop    %esi
f01054c9:	5f                   	pop    %edi
f01054ca:	c9                   	leave  
f01054cb:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01054cc:	6b d2 0c             	imul   $0xc,%edx,%edx
f01054cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01054d2:	8b 04 16             	mov    (%esi,%edx,1),%eax
f01054d5:	2b 7d d4             	sub    -0x2c(%ebp),%edi
f01054d8:	39 f8                	cmp    %edi,%eax
f01054da:	72 89                	jb     f0105465 <debuginfo_eip+0x244>
f01054dc:	eb 8c                	jmp    f010546a <debuginfo_eip+0x249>
	...

f01054e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01054e0:	55                   	push   %ebp
f01054e1:	89 e5                	mov    %esp,%ebp
f01054e3:	57                   	push   %edi
f01054e4:	56                   	push   %esi
f01054e5:	53                   	push   %ebx
f01054e6:	83 ec 2c             	sub    $0x2c,%esp
f01054e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01054ec:	89 d6                	mov    %edx,%esi
f01054ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01054f1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01054f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01054f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01054fa:	8b 45 10             	mov    0x10(%ebp),%eax
f01054fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105500:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105503:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105506:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010550d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0105510:	72 0c                	jb     f010551e <printnum+0x3e>
f0105512:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105515:	76 07                	jbe    f010551e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105517:	4b                   	dec    %ebx
f0105518:	85 db                	test   %ebx,%ebx
f010551a:	7f 31                	jg     f010554d <printnum+0x6d>
f010551c:	eb 3f                	jmp    f010555d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010551e:	83 ec 0c             	sub    $0xc,%esp
f0105521:	57                   	push   %edi
f0105522:	4b                   	dec    %ebx
f0105523:	53                   	push   %ebx
f0105524:	50                   	push   %eax
f0105525:	83 ec 08             	sub    $0x8,%esp
f0105528:	ff 75 d4             	pushl  -0x2c(%ebp)
f010552b:	ff 75 d0             	pushl  -0x30(%ebp)
f010552e:	ff 75 dc             	pushl  -0x24(%ebp)
f0105531:	ff 75 d8             	pushl  -0x28(%ebp)
f0105534:	e8 3b 12 00 00       	call   f0106774 <__udivdi3>
f0105539:	83 c4 18             	add    $0x18,%esp
f010553c:	52                   	push   %edx
f010553d:	50                   	push   %eax
f010553e:	89 f2                	mov    %esi,%edx
f0105540:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105543:	e8 98 ff ff ff       	call   f01054e0 <printnum>
f0105548:	83 c4 20             	add    $0x20,%esp
f010554b:	eb 10                	jmp    f010555d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010554d:	83 ec 08             	sub    $0x8,%esp
f0105550:	56                   	push   %esi
f0105551:	57                   	push   %edi
f0105552:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105555:	4b                   	dec    %ebx
f0105556:	83 c4 10             	add    $0x10,%esp
f0105559:	85 db                	test   %ebx,%ebx
f010555b:	7f f0                	jg     f010554d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010555d:	83 ec 08             	sub    $0x8,%esp
f0105560:	56                   	push   %esi
f0105561:	83 ec 04             	sub    $0x4,%esp
f0105564:	ff 75 d4             	pushl  -0x2c(%ebp)
f0105567:	ff 75 d0             	pushl  -0x30(%ebp)
f010556a:	ff 75 dc             	pushl  -0x24(%ebp)
f010556d:	ff 75 d8             	pushl  -0x28(%ebp)
f0105570:	e8 1b 13 00 00       	call   f0106890 <__umoddi3>
f0105575:	83 c4 14             	add    $0x14,%esp
f0105578:	0f be 80 52 85 10 f0 	movsbl -0xfef7aae(%eax),%eax
f010557f:	50                   	push   %eax
f0105580:	ff 55 e4             	call   *-0x1c(%ebp)
f0105583:	83 c4 10             	add    $0x10,%esp
}
f0105586:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105589:	5b                   	pop    %ebx
f010558a:	5e                   	pop    %esi
f010558b:	5f                   	pop    %edi
f010558c:	c9                   	leave  
f010558d:	c3                   	ret    

f010558e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010558e:	55                   	push   %ebp
f010558f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105591:	83 fa 01             	cmp    $0x1,%edx
f0105594:	7e 0e                	jle    f01055a4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105596:	8b 10                	mov    (%eax),%edx
f0105598:	8d 4a 08             	lea    0x8(%edx),%ecx
f010559b:	89 08                	mov    %ecx,(%eax)
f010559d:	8b 02                	mov    (%edx),%eax
f010559f:	8b 52 04             	mov    0x4(%edx),%edx
f01055a2:	eb 22                	jmp    f01055c6 <getuint+0x38>
	else if (lflag)
f01055a4:	85 d2                	test   %edx,%edx
f01055a6:	74 10                	je     f01055b8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01055a8:	8b 10                	mov    (%eax),%edx
f01055aa:	8d 4a 04             	lea    0x4(%edx),%ecx
f01055ad:	89 08                	mov    %ecx,(%eax)
f01055af:	8b 02                	mov    (%edx),%eax
f01055b1:	ba 00 00 00 00       	mov    $0x0,%edx
f01055b6:	eb 0e                	jmp    f01055c6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01055b8:	8b 10                	mov    (%eax),%edx
f01055ba:	8d 4a 04             	lea    0x4(%edx),%ecx
f01055bd:	89 08                	mov    %ecx,(%eax)
f01055bf:	8b 02                	mov    (%edx),%eax
f01055c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01055c6:	c9                   	leave  
f01055c7:	c3                   	ret    

f01055c8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f01055c8:	55                   	push   %ebp
f01055c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01055cb:	83 fa 01             	cmp    $0x1,%edx
f01055ce:	7e 0e                	jle    f01055de <getint+0x16>
		return va_arg(*ap, long long);
f01055d0:	8b 10                	mov    (%eax),%edx
f01055d2:	8d 4a 08             	lea    0x8(%edx),%ecx
f01055d5:	89 08                	mov    %ecx,(%eax)
f01055d7:	8b 02                	mov    (%edx),%eax
f01055d9:	8b 52 04             	mov    0x4(%edx),%edx
f01055dc:	eb 1a                	jmp    f01055f8 <getint+0x30>
	else if (lflag)
f01055de:	85 d2                	test   %edx,%edx
f01055e0:	74 0c                	je     f01055ee <getint+0x26>
		return va_arg(*ap, long);
f01055e2:	8b 10                	mov    (%eax),%edx
f01055e4:	8d 4a 04             	lea    0x4(%edx),%ecx
f01055e7:	89 08                	mov    %ecx,(%eax)
f01055e9:	8b 02                	mov    (%edx),%eax
f01055eb:	99                   	cltd   
f01055ec:	eb 0a                	jmp    f01055f8 <getint+0x30>
	else
		return va_arg(*ap, int);
f01055ee:	8b 10                	mov    (%eax),%edx
f01055f0:	8d 4a 04             	lea    0x4(%edx),%ecx
f01055f3:	89 08                	mov    %ecx,(%eax)
f01055f5:	8b 02                	mov    (%edx),%eax
f01055f7:	99                   	cltd   
}
f01055f8:	c9                   	leave  
f01055f9:	c3                   	ret    

f01055fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01055fa:	55                   	push   %ebp
f01055fb:	89 e5                	mov    %esp,%ebp
f01055fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105600:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105603:	8b 10                	mov    (%eax),%edx
f0105605:	3b 50 04             	cmp    0x4(%eax),%edx
f0105608:	73 08                	jae    f0105612 <sprintputch+0x18>
		*b->buf++ = ch;
f010560a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010560d:	88 0a                	mov    %cl,(%edx)
f010560f:	42                   	inc    %edx
f0105610:	89 10                	mov    %edx,(%eax)
}
f0105612:	c9                   	leave  
f0105613:	c3                   	ret    

f0105614 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105614:	55                   	push   %ebp
f0105615:	89 e5                	mov    %esp,%ebp
f0105617:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010561a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010561d:	50                   	push   %eax
f010561e:	ff 75 10             	pushl  0x10(%ebp)
f0105621:	ff 75 0c             	pushl  0xc(%ebp)
f0105624:	ff 75 08             	pushl  0x8(%ebp)
f0105627:	e8 05 00 00 00       	call   f0105631 <vprintfmt>
	va_end(ap);
f010562c:	83 c4 10             	add    $0x10,%esp
}
f010562f:	c9                   	leave  
f0105630:	c3                   	ret    

f0105631 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105631:	55                   	push   %ebp
f0105632:	89 e5                	mov    %esp,%ebp
f0105634:	57                   	push   %edi
f0105635:	56                   	push   %esi
f0105636:	53                   	push   %ebx
f0105637:	83 ec 2c             	sub    $0x2c,%esp
f010563a:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010563d:	8b 75 10             	mov    0x10(%ebp),%esi
f0105640:	eb 13                	jmp    f0105655 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105642:	85 c0                	test   %eax,%eax
f0105644:	0f 84 6d 03 00 00    	je     f01059b7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f010564a:	83 ec 08             	sub    $0x8,%esp
f010564d:	57                   	push   %edi
f010564e:	50                   	push   %eax
f010564f:	ff 55 08             	call   *0x8(%ebp)
f0105652:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105655:	0f b6 06             	movzbl (%esi),%eax
f0105658:	46                   	inc    %esi
f0105659:	83 f8 25             	cmp    $0x25,%eax
f010565c:	75 e4                	jne    f0105642 <vprintfmt+0x11>
f010565e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0105662:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105669:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0105670:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105677:	b9 00 00 00 00       	mov    $0x0,%ecx
f010567c:	eb 28                	jmp    f01056a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010567e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105680:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0105684:	eb 20                	jmp    f01056a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105686:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105688:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f010568c:	eb 18                	jmp    f01056a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010568e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105690:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105697:	eb 0d                	jmp    f01056a6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105699:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010569c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010569f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056a6:	8a 06                	mov    (%esi),%al
f01056a8:	0f b6 d0             	movzbl %al,%edx
f01056ab:	8d 5e 01             	lea    0x1(%esi),%ebx
f01056ae:	83 e8 23             	sub    $0x23,%eax
f01056b1:	3c 55                	cmp    $0x55,%al
f01056b3:	0f 87 e0 02 00 00    	ja     f0105999 <vprintfmt+0x368>
f01056b9:	0f b6 c0             	movzbl %al,%eax
f01056bc:	ff 24 85 a0 86 10 f0 	jmp    *-0xfef7960(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01056c3:	83 ea 30             	sub    $0x30,%edx
f01056c6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f01056c9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f01056cc:	8d 50 d0             	lea    -0x30(%eax),%edx
f01056cf:	83 fa 09             	cmp    $0x9,%edx
f01056d2:	77 44                	ja     f0105718 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056d4:	89 de                	mov    %ebx,%esi
f01056d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01056d9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f01056da:	8d 14 92             	lea    (%edx,%edx,4),%edx
f01056dd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f01056e1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01056e4:	8d 58 d0             	lea    -0x30(%eax),%ebx
f01056e7:	83 fb 09             	cmp    $0x9,%ebx
f01056ea:	76 ed                	jbe    f01056d9 <vprintfmt+0xa8>
f01056ec:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01056ef:	eb 29                	jmp    f010571a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01056f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01056f4:	8d 50 04             	lea    0x4(%eax),%edx
f01056f7:	89 55 14             	mov    %edx,0x14(%ebp)
f01056fa:	8b 00                	mov    (%eax),%eax
f01056fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056ff:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105701:	eb 17                	jmp    f010571a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0105703:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105707:	78 85                	js     f010568e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105709:	89 de                	mov    %ebx,%esi
f010570b:	eb 99                	jmp    f01056a6 <vprintfmt+0x75>
f010570d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010570f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0105716:	eb 8e                	jmp    f01056a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105718:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f010571a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010571e:	79 86                	jns    f01056a6 <vprintfmt+0x75>
f0105720:	e9 74 ff ff ff       	jmp    f0105699 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105725:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105726:	89 de                	mov    %ebx,%esi
f0105728:	e9 79 ff ff ff       	jmp    f01056a6 <vprintfmt+0x75>
f010572d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105730:	8b 45 14             	mov    0x14(%ebp),%eax
f0105733:	8d 50 04             	lea    0x4(%eax),%edx
f0105736:	89 55 14             	mov    %edx,0x14(%ebp)
f0105739:	83 ec 08             	sub    $0x8,%esp
f010573c:	57                   	push   %edi
f010573d:	ff 30                	pushl  (%eax)
f010573f:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105742:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105745:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105748:	e9 08 ff ff ff       	jmp    f0105655 <vprintfmt+0x24>
f010574d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105750:	8b 45 14             	mov    0x14(%ebp),%eax
f0105753:	8d 50 04             	lea    0x4(%eax),%edx
f0105756:	89 55 14             	mov    %edx,0x14(%ebp)
f0105759:	8b 00                	mov    (%eax),%eax
f010575b:	85 c0                	test   %eax,%eax
f010575d:	79 02                	jns    f0105761 <vprintfmt+0x130>
f010575f:	f7 d8                	neg    %eax
f0105761:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105763:	83 f8 0f             	cmp    $0xf,%eax
f0105766:	7f 0b                	jg     f0105773 <vprintfmt+0x142>
f0105768:	8b 04 85 00 88 10 f0 	mov    -0xfef7800(,%eax,4),%eax
f010576f:	85 c0                	test   %eax,%eax
f0105771:	75 1a                	jne    f010578d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0105773:	52                   	push   %edx
f0105774:	68 6a 85 10 f0       	push   $0xf010856a
f0105779:	57                   	push   %edi
f010577a:	ff 75 08             	pushl  0x8(%ebp)
f010577d:	e8 92 fe ff ff       	call   f0105614 <printfmt>
f0105782:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105785:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105788:	e9 c8 fe ff ff       	jmp    f0105655 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f010578d:	50                   	push   %eax
f010578e:	68 a9 7d 10 f0       	push   $0xf0107da9
f0105793:	57                   	push   %edi
f0105794:	ff 75 08             	pushl  0x8(%ebp)
f0105797:	e8 78 fe ff ff       	call   f0105614 <printfmt>
f010579c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010579f:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01057a2:	e9 ae fe ff ff       	jmp    f0105655 <vprintfmt+0x24>
f01057a7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f01057aa:	89 de                	mov    %ebx,%esi
f01057ac:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01057af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01057b2:	8b 45 14             	mov    0x14(%ebp),%eax
f01057b5:	8d 50 04             	lea    0x4(%eax),%edx
f01057b8:	89 55 14             	mov    %edx,0x14(%ebp)
f01057bb:	8b 00                	mov    (%eax),%eax
f01057bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01057c0:	85 c0                	test   %eax,%eax
f01057c2:	75 07                	jne    f01057cb <vprintfmt+0x19a>
				p = "(null)";
f01057c4:	c7 45 d0 63 85 10 f0 	movl   $0xf0108563,-0x30(%ebp)
			if (width > 0 && padc != '-')
f01057cb:	85 db                	test   %ebx,%ebx
f01057cd:	7e 42                	jle    f0105811 <vprintfmt+0x1e0>
f01057cf:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f01057d3:	74 3c                	je     f0105811 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f01057d5:	83 ec 08             	sub    $0x8,%esp
f01057d8:	51                   	push   %ecx
f01057d9:	ff 75 d0             	pushl  -0x30(%ebp)
f01057dc:	e8 4f 03 00 00       	call   f0105b30 <strnlen>
f01057e1:	29 c3                	sub    %eax,%ebx
f01057e3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01057e6:	83 c4 10             	add    $0x10,%esp
f01057e9:	85 db                	test   %ebx,%ebx
f01057eb:	7e 24                	jle    f0105811 <vprintfmt+0x1e0>
					putch(padc, putdat);
f01057ed:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f01057f1:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01057f4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01057f7:	83 ec 08             	sub    $0x8,%esp
f01057fa:	57                   	push   %edi
f01057fb:	53                   	push   %ebx
f01057fc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01057ff:	4e                   	dec    %esi
f0105800:	83 c4 10             	add    $0x10,%esp
f0105803:	85 f6                	test   %esi,%esi
f0105805:	7f f0                	jg     f01057f7 <vprintfmt+0x1c6>
f0105807:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010580a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105811:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105814:	0f be 02             	movsbl (%edx),%eax
f0105817:	85 c0                	test   %eax,%eax
f0105819:	75 47                	jne    f0105862 <vprintfmt+0x231>
f010581b:	eb 37                	jmp    f0105854 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f010581d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105821:	74 16                	je     f0105839 <vprintfmt+0x208>
f0105823:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105826:	83 fa 5e             	cmp    $0x5e,%edx
f0105829:	76 0e                	jbe    f0105839 <vprintfmt+0x208>
					putch('?', putdat);
f010582b:	83 ec 08             	sub    $0x8,%esp
f010582e:	57                   	push   %edi
f010582f:	6a 3f                	push   $0x3f
f0105831:	ff 55 08             	call   *0x8(%ebp)
f0105834:	83 c4 10             	add    $0x10,%esp
f0105837:	eb 0b                	jmp    f0105844 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f0105839:	83 ec 08             	sub    $0x8,%esp
f010583c:	57                   	push   %edi
f010583d:	50                   	push   %eax
f010583e:	ff 55 08             	call   *0x8(%ebp)
f0105841:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105844:	ff 4d e4             	decl   -0x1c(%ebp)
f0105847:	0f be 03             	movsbl (%ebx),%eax
f010584a:	85 c0                	test   %eax,%eax
f010584c:	74 03                	je     f0105851 <vprintfmt+0x220>
f010584e:	43                   	inc    %ebx
f010584f:	eb 1b                	jmp    f010586c <vprintfmt+0x23b>
f0105851:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105854:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105858:	7f 1e                	jg     f0105878 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010585a:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010585d:	e9 f3 fd ff ff       	jmp    f0105655 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105862:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105865:	43                   	inc    %ebx
f0105866:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0105869:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010586c:	85 f6                	test   %esi,%esi
f010586e:	78 ad                	js     f010581d <vprintfmt+0x1ec>
f0105870:	4e                   	dec    %esi
f0105871:	79 aa                	jns    f010581d <vprintfmt+0x1ec>
f0105873:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0105876:	eb dc                	jmp    f0105854 <vprintfmt+0x223>
f0105878:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010587b:	83 ec 08             	sub    $0x8,%esp
f010587e:	57                   	push   %edi
f010587f:	6a 20                	push   $0x20
f0105881:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105884:	4b                   	dec    %ebx
f0105885:	83 c4 10             	add    $0x10,%esp
f0105888:	85 db                	test   %ebx,%ebx
f010588a:	7f ef                	jg     f010587b <vprintfmt+0x24a>
f010588c:	e9 c4 fd ff ff       	jmp    f0105655 <vprintfmt+0x24>
f0105891:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105894:	89 ca                	mov    %ecx,%edx
f0105896:	8d 45 14             	lea    0x14(%ebp),%eax
f0105899:	e8 2a fd ff ff       	call   f01055c8 <getint>
f010589e:	89 c3                	mov    %eax,%ebx
f01058a0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f01058a2:	85 d2                	test   %edx,%edx
f01058a4:	78 0a                	js     f01058b0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01058a6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01058ab:	e9 b0 00 00 00       	jmp    f0105960 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f01058b0:	83 ec 08             	sub    $0x8,%esp
f01058b3:	57                   	push   %edi
f01058b4:	6a 2d                	push   $0x2d
f01058b6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01058b9:	f7 db                	neg    %ebx
f01058bb:	83 d6 00             	adc    $0x0,%esi
f01058be:	f7 de                	neg    %esi
f01058c0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01058c3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01058c8:	e9 93 00 00 00       	jmp    f0105960 <vprintfmt+0x32f>
f01058cd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01058d0:	89 ca                	mov    %ecx,%edx
f01058d2:	8d 45 14             	lea    0x14(%ebp),%eax
f01058d5:	e8 b4 fc ff ff       	call   f010558e <getuint>
f01058da:	89 c3                	mov    %eax,%ebx
f01058dc:	89 d6                	mov    %edx,%esi
			base = 10;
f01058de:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01058e3:	eb 7b                	jmp    f0105960 <vprintfmt+0x32f>
f01058e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f01058e8:	89 ca                	mov    %ecx,%edx
f01058ea:	8d 45 14             	lea    0x14(%ebp),%eax
f01058ed:	e8 d6 fc ff ff       	call   f01055c8 <getint>
f01058f2:	89 c3                	mov    %eax,%ebx
f01058f4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f01058f6:	85 d2                	test   %edx,%edx
f01058f8:	78 07                	js     f0105901 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f01058fa:	b8 08 00 00 00       	mov    $0x8,%eax
f01058ff:	eb 5f                	jmp    f0105960 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0105901:	83 ec 08             	sub    $0x8,%esp
f0105904:	57                   	push   %edi
f0105905:	6a 2d                	push   $0x2d
f0105907:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f010590a:	f7 db                	neg    %ebx
f010590c:	83 d6 00             	adc    $0x0,%esi
f010590f:	f7 de                	neg    %esi
f0105911:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f0105914:	b8 08 00 00 00       	mov    $0x8,%eax
f0105919:	eb 45                	jmp    f0105960 <vprintfmt+0x32f>
f010591b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f010591e:	83 ec 08             	sub    $0x8,%esp
f0105921:	57                   	push   %edi
f0105922:	6a 30                	push   $0x30
f0105924:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105927:	83 c4 08             	add    $0x8,%esp
f010592a:	57                   	push   %edi
f010592b:	6a 78                	push   $0x78
f010592d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105930:	8b 45 14             	mov    0x14(%ebp),%eax
f0105933:	8d 50 04             	lea    0x4(%eax),%edx
f0105936:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105939:	8b 18                	mov    (%eax),%ebx
f010593b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105940:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105943:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105948:	eb 16                	jmp    f0105960 <vprintfmt+0x32f>
f010594a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010594d:	89 ca                	mov    %ecx,%edx
f010594f:	8d 45 14             	lea    0x14(%ebp),%eax
f0105952:	e8 37 fc ff ff       	call   f010558e <getuint>
f0105957:	89 c3                	mov    %eax,%ebx
f0105959:	89 d6                	mov    %edx,%esi
			base = 16;
f010595b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105960:	83 ec 0c             	sub    $0xc,%esp
f0105963:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0105967:	52                   	push   %edx
f0105968:	ff 75 e4             	pushl  -0x1c(%ebp)
f010596b:	50                   	push   %eax
f010596c:	56                   	push   %esi
f010596d:	53                   	push   %ebx
f010596e:	89 fa                	mov    %edi,%edx
f0105970:	8b 45 08             	mov    0x8(%ebp),%eax
f0105973:	e8 68 fb ff ff       	call   f01054e0 <printnum>
			break;
f0105978:	83 c4 20             	add    $0x20,%esp
f010597b:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010597e:	e9 d2 fc ff ff       	jmp    f0105655 <vprintfmt+0x24>
f0105983:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105986:	83 ec 08             	sub    $0x8,%esp
f0105989:	57                   	push   %edi
f010598a:	52                   	push   %edx
f010598b:	ff 55 08             	call   *0x8(%ebp)
			break;
f010598e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105991:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105994:	e9 bc fc ff ff       	jmp    f0105655 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105999:	83 ec 08             	sub    $0x8,%esp
f010599c:	57                   	push   %edi
f010599d:	6a 25                	push   $0x25
f010599f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01059a2:	83 c4 10             	add    $0x10,%esp
f01059a5:	eb 02                	jmp    f01059a9 <vprintfmt+0x378>
f01059a7:	89 c6                	mov    %eax,%esi
f01059a9:	8d 46 ff             	lea    -0x1(%esi),%eax
f01059ac:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01059b0:	75 f5                	jne    f01059a7 <vprintfmt+0x376>
f01059b2:	e9 9e fc ff ff       	jmp    f0105655 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f01059b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01059ba:	5b                   	pop    %ebx
f01059bb:	5e                   	pop    %esi
f01059bc:	5f                   	pop    %edi
f01059bd:	c9                   	leave  
f01059be:	c3                   	ret    

f01059bf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01059bf:	55                   	push   %ebp
f01059c0:	89 e5                	mov    %esp,%ebp
f01059c2:	83 ec 18             	sub    $0x18,%esp
f01059c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01059c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01059cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01059ce:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01059d2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01059d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01059dc:	85 c0                	test   %eax,%eax
f01059de:	74 26                	je     f0105a06 <vsnprintf+0x47>
f01059e0:	85 d2                	test   %edx,%edx
f01059e2:	7e 29                	jle    f0105a0d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01059e4:	ff 75 14             	pushl  0x14(%ebp)
f01059e7:	ff 75 10             	pushl  0x10(%ebp)
f01059ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01059ed:	50                   	push   %eax
f01059ee:	68 fa 55 10 f0       	push   $0xf01055fa
f01059f3:	e8 39 fc ff ff       	call   f0105631 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01059f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01059fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01059fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105a01:	83 c4 10             	add    $0x10,%esp
f0105a04:	eb 0c                	jmp    f0105a12 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105a06:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105a0b:	eb 05                	jmp    f0105a12 <vsnprintf+0x53>
f0105a0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105a12:	c9                   	leave  
f0105a13:	c3                   	ret    

f0105a14 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105a14:	55                   	push   %ebp
f0105a15:	89 e5                	mov    %esp,%ebp
f0105a17:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105a1a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105a1d:	50                   	push   %eax
f0105a1e:	ff 75 10             	pushl  0x10(%ebp)
f0105a21:	ff 75 0c             	pushl  0xc(%ebp)
f0105a24:	ff 75 08             	pushl  0x8(%ebp)
f0105a27:	e8 93 ff ff ff       	call   f01059bf <vsnprintf>
	va_end(ap);

	return rc;
}
f0105a2c:	c9                   	leave  
f0105a2d:	c3                   	ret    
	...

f0105a30 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105a30:	55                   	push   %ebp
f0105a31:	89 e5                	mov    %esp,%ebp
f0105a33:	57                   	push   %edi
f0105a34:	56                   	push   %esi
f0105a35:	53                   	push   %ebx
f0105a36:	83 ec 0c             	sub    $0xc,%esp
f0105a39:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105a3c:	85 c0                	test   %eax,%eax
f0105a3e:	74 11                	je     f0105a51 <readline+0x21>
		cprintf("%s", prompt);
f0105a40:	83 ec 08             	sub    $0x8,%esp
f0105a43:	50                   	push   %eax
f0105a44:	68 a9 7d 10 f0       	push   $0xf0107da9
f0105a49:	e8 c7 e2 ff ff       	call   f0103d15 <cprintf>
f0105a4e:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105a51:	83 ec 0c             	sub    $0xc,%esp
f0105a54:	6a 00                	push   $0x0
f0105a56:	e8 9a ad ff ff       	call   f01007f5 <iscons>
f0105a5b:	89 c7                	mov    %eax,%edi
f0105a5d:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105a60:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105a65:	e8 7a ad ff ff       	call   f01007e4 <getchar>
f0105a6a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105a6c:	85 c0                	test   %eax,%eax
f0105a6e:	79 21                	jns    f0105a91 <readline+0x61>
			if (c != -E_EOF)
f0105a70:	83 f8 f8             	cmp    $0xfffffff8,%eax
f0105a73:	0f 84 89 00 00 00    	je     f0105b02 <readline+0xd2>
				cprintf("read error: %e\n", c);
f0105a79:	83 ec 08             	sub    $0x8,%esp
f0105a7c:	50                   	push   %eax
f0105a7d:	68 5f 88 10 f0       	push   $0xf010885f
f0105a82:	e8 8e e2 ff ff       	call   f0103d15 <cprintf>
f0105a87:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105a8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a8f:	eb 76                	jmp    f0105b07 <readline+0xd7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105a91:	83 f8 08             	cmp    $0x8,%eax
f0105a94:	74 05                	je     f0105a9b <readline+0x6b>
f0105a96:	83 f8 7f             	cmp    $0x7f,%eax
f0105a99:	75 18                	jne    f0105ab3 <readline+0x83>
f0105a9b:	85 f6                	test   %esi,%esi
f0105a9d:	7e 14                	jle    f0105ab3 <readline+0x83>
			if (echoing)
f0105a9f:	85 ff                	test   %edi,%edi
f0105aa1:	74 0d                	je     f0105ab0 <readline+0x80>
				cputchar('\b');
f0105aa3:	83 ec 0c             	sub    $0xc,%esp
f0105aa6:	6a 08                	push   $0x8
f0105aa8:	e8 27 ad ff ff       	call   f01007d4 <cputchar>
f0105aad:	83 c4 10             	add    $0x10,%esp
			i--;
f0105ab0:	4e                   	dec    %esi
f0105ab1:	eb b2                	jmp    f0105a65 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105ab3:	83 fb 1f             	cmp    $0x1f,%ebx
f0105ab6:	7e 21                	jle    f0105ad9 <readline+0xa9>
f0105ab8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105abe:	7f 19                	jg     f0105ad9 <readline+0xa9>
			if (echoing)
f0105ac0:	85 ff                	test   %edi,%edi
f0105ac2:	74 0c                	je     f0105ad0 <readline+0xa0>
				cputchar(c);
f0105ac4:	83 ec 0c             	sub    $0xc,%esp
f0105ac7:	53                   	push   %ebx
f0105ac8:	e8 07 ad ff ff       	call   f01007d4 <cputchar>
f0105acd:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105ad0:	88 9e 80 1a 21 f0    	mov    %bl,-0xfdee580(%esi)
f0105ad6:	46                   	inc    %esi
f0105ad7:	eb 8c                	jmp    f0105a65 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105ad9:	83 fb 0a             	cmp    $0xa,%ebx
f0105adc:	74 05                	je     f0105ae3 <readline+0xb3>
f0105ade:	83 fb 0d             	cmp    $0xd,%ebx
f0105ae1:	75 82                	jne    f0105a65 <readline+0x35>
			if (echoing)
f0105ae3:	85 ff                	test   %edi,%edi
f0105ae5:	74 0d                	je     f0105af4 <readline+0xc4>
				cputchar('\n');
f0105ae7:	83 ec 0c             	sub    $0xc,%esp
f0105aea:	6a 0a                	push   $0xa
f0105aec:	e8 e3 ac ff ff       	call   f01007d4 <cputchar>
f0105af1:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105af4:	c6 86 80 1a 21 f0 00 	movb   $0x0,-0xfdee580(%esi)
			return buf;
f0105afb:	b8 80 1a 21 f0       	mov    $0xf0211a80,%eax
f0105b00:	eb 05                	jmp    f0105b07 <readline+0xd7>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105b02:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105b07:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b0a:	5b                   	pop    %ebx
f0105b0b:	5e                   	pop    %esi
f0105b0c:	5f                   	pop    %edi
f0105b0d:	c9                   	leave  
f0105b0e:	c3                   	ret    
	...

f0105b10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105b10:	55                   	push   %ebp
f0105b11:	89 e5                	mov    %esp,%ebp
f0105b13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105b16:	80 3a 00             	cmpb   $0x0,(%edx)
f0105b19:	74 0e                	je     f0105b29 <strlen+0x19>
f0105b1b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105b20:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105b21:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105b25:	75 f9                	jne    f0105b20 <strlen+0x10>
f0105b27:	eb 05                	jmp    f0105b2e <strlen+0x1e>
f0105b29:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105b2e:	c9                   	leave  
f0105b2f:	c3                   	ret    

f0105b30 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105b30:	55                   	push   %ebp
f0105b31:	89 e5                	mov    %esp,%ebp
f0105b33:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105b36:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105b39:	85 d2                	test   %edx,%edx
f0105b3b:	74 17                	je     f0105b54 <strnlen+0x24>
f0105b3d:	80 39 00             	cmpb   $0x0,(%ecx)
f0105b40:	74 19                	je     f0105b5b <strnlen+0x2b>
f0105b42:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105b47:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105b48:	39 d0                	cmp    %edx,%eax
f0105b4a:	74 14                	je     f0105b60 <strnlen+0x30>
f0105b4c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105b50:	75 f5                	jne    f0105b47 <strnlen+0x17>
f0105b52:	eb 0c                	jmp    f0105b60 <strnlen+0x30>
f0105b54:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b59:	eb 05                	jmp    f0105b60 <strnlen+0x30>
f0105b5b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105b60:	c9                   	leave  
f0105b61:	c3                   	ret    

f0105b62 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105b62:	55                   	push   %ebp
f0105b63:	89 e5                	mov    %esp,%ebp
f0105b65:	53                   	push   %ebx
f0105b66:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b69:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105b6c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b71:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0105b74:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105b77:	42                   	inc    %edx
f0105b78:	84 c9                	test   %cl,%cl
f0105b7a:	75 f5                	jne    f0105b71 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105b7c:	5b                   	pop    %ebx
f0105b7d:	c9                   	leave  
f0105b7e:	c3                   	ret    

f0105b7f <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105b7f:	55                   	push   %ebp
f0105b80:	89 e5                	mov    %esp,%ebp
f0105b82:	53                   	push   %ebx
f0105b83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105b86:	53                   	push   %ebx
f0105b87:	e8 84 ff ff ff       	call   f0105b10 <strlen>
f0105b8c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105b8f:	ff 75 0c             	pushl  0xc(%ebp)
f0105b92:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0105b95:	50                   	push   %eax
f0105b96:	e8 c7 ff ff ff       	call   f0105b62 <strcpy>
	return dst;
}
f0105b9b:	89 d8                	mov    %ebx,%eax
f0105b9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105ba0:	c9                   	leave  
f0105ba1:	c3                   	ret    

f0105ba2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105ba2:	55                   	push   %ebp
f0105ba3:	89 e5                	mov    %esp,%ebp
f0105ba5:	56                   	push   %esi
f0105ba6:	53                   	push   %ebx
f0105ba7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105baa:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105bad:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105bb0:	85 f6                	test   %esi,%esi
f0105bb2:	74 15                	je     f0105bc9 <strncpy+0x27>
f0105bb4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0105bb9:	8a 1a                	mov    (%edx),%bl
f0105bbb:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105bbe:	80 3a 01             	cmpb   $0x1,(%edx)
f0105bc1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105bc4:	41                   	inc    %ecx
f0105bc5:	39 ce                	cmp    %ecx,%esi
f0105bc7:	77 f0                	ja     f0105bb9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105bc9:	5b                   	pop    %ebx
f0105bca:	5e                   	pop    %esi
f0105bcb:	c9                   	leave  
f0105bcc:	c3                   	ret    

f0105bcd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105bcd:	55                   	push   %ebp
f0105bce:	89 e5                	mov    %esp,%ebp
f0105bd0:	57                   	push   %edi
f0105bd1:	56                   	push   %esi
f0105bd2:	53                   	push   %ebx
f0105bd3:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105bd6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105bd9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105bdc:	85 f6                	test   %esi,%esi
f0105bde:	74 32                	je     f0105c12 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0105be0:	83 fe 01             	cmp    $0x1,%esi
f0105be3:	74 22                	je     f0105c07 <strlcpy+0x3a>
f0105be5:	8a 0b                	mov    (%ebx),%cl
f0105be7:	84 c9                	test   %cl,%cl
f0105be9:	74 20                	je     f0105c0b <strlcpy+0x3e>
f0105beb:	89 f8                	mov    %edi,%eax
f0105bed:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0105bf2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105bf5:	88 08                	mov    %cl,(%eax)
f0105bf7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105bf8:	39 f2                	cmp    %esi,%edx
f0105bfa:	74 11                	je     f0105c0d <strlcpy+0x40>
f0105bfc:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0105c00:	42                   	inc    %edx
f0105c01:	84 c9                	test   %cl,%cl
f0105c03:	75 f0                	jne    f0105bf5 <strlcpy+0x28>
f0105c05:	eb 06                	jmp    f0105c0d <strlcpy+0x40>
f0105c07:	89 f8                	mov    %edi,%eax
f0105c09:	eb 02                	jmp    f0105c0d <strlcpy+0x40>
f0105c0b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105c0d:	c6 00 00             	movb   $0x0,(%eax)
f0105c10:	eb 02                	jmp    f0105c14 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105c12:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0105c14:	29 f8                	sub    %edi,%eax
}
f0105c16:	5b                   	pop    %ebx
f0105c17:	5e                   	pop    %esi
f0105c18:	5f                   	pop    %edi
f0105c19:	c9                   	leave  
f0105c1a:	c3                   	ret    

f0105c1b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105c1b:	55                   	push   %ebp
f0105c1c:	89 e5                	mov    %esp,%ebp
f0105c1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c21:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105c24:	8a 01                	mov    (%ecx),%al
f0105c26:	84 c0                	test   %al,%al
f0105c28:	74 10                	je     f0105c3a <strcmp+0x1f>
f0105c2a:	3a 02                	cmp    (%edx),%al
f0105c2c:	75 0c                	jne    f0105c3a <strcmp+0x1f>
		p++, q++;
f0105c2e:	41                   	inc    %ecx
f0105c2f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105c30:	8a 01                	mov    (%ecx),%al
f0105c32:	84 c0                	test   %al,%al
f0105c34:	74 04                	je     f0105c3a <strcmp+0x1f>
f0105c36:	3a 02                	cmp    (%edx),%al
f0105c38:	74 f4                	je     f0105c2e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105c3a:	0f b6 c0             	movzbl %al,%eax
f0105c3d:	0f b6 12             	movzbl (%edx),%edx
f0105c40:	29 d0                	sub    %edx,%eax
}
f0105c42:	c9                   	leave  
f0105c43:	c3                   	ret    

f0105c44 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105c44:	55                   	push   %ebp
f0105c45:	89 e5                	mov    %esp,%ebp
f0105c47:	53                   	push   %ebx
f0105c48:	8b 55 08             	mov    0x8(%ebp),%edx
f0105c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105c4e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0105c51:	85 c0                	test   %eax,%eax
f0105c53:	74 1b                	je     f0105c70 <strncmp+0x2c>
f0105c55:	8a 1a                	mov    (%edx),%bl
f0105c57:	84 db                	test   %bl,%bl
f0105c59:	74 24                	je     f0105c7f <strncmp+0x3b>
f0105c5b:	3a 19                	cmp    (%ecx),%bl
f0105c5d:	75 20                	jne    f0105c7f <strncmp+0x3b>
f0105c5f:	48                   	dec    %eax
f0105c60:	74 15                	je     f0105c77 <strncmp+0x33>
		n--, p++, q++;
f0105c62:	42                   	inc    %edx
f0105c63:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105c64:	8a 1a                	mov    (%edx),%bl
f0105c66:	84 db                	test   %bl,%bl
f0105c68:	74 15                	je     f0105c7f <strncmp+0x3b>
f0105c6a:	3a 19                	cmp    (%ecx),%bl
f0105c6c:	74 f1                	je     f0105c5f <strncmp+0x1b>
f0105c6e:	eb 0f                	jmp    f0105c7f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105c70:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c75:	eb 05                	jmp    f0105c7c <strncmp+0x38>
f0105c77:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105c7c:	5b                   	pop    %ebx
f0105c7d:	c9                   	leave  
f0105c7e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105c7f:	0f b6 02             	movzbl (%edx),%eax
f0105c82:	0f b6 11             	movzbl (%ecx),%edx
f0105c85:	29 d0                	sub    %edx,%eax
f0105c87:	eb f3                	jmp    f0105c7c <strncmp+0x38>

f0105c89 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105c89:	55                   	push   %ebp
f0105c8a:	89 e5                	mov    %esp,%ebp
f0105c8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c8f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105c92:	8a 10                	mov    (%eax),%dl
f0105c94:	84 d2                	test   %dl,%dl
f0105c96:	74 18                	je     f0105cb0 <strchr+0x27>
		if (*s == c)
f0105c98:	38 ca                	cmp    %cl,%dl
f0105c9a:	75 06                	jne    f0105ca2 <strchr+0x19>
f0105c9c:	eb 17                	jmp    f0105cb5 <strchr+0x2c>
f0105c9e:	38 ca                	cmp    %cl,%dl
f0105ca0:	74 13                	je     f0105cb5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105ca2:	40                   	inc    %eax
f0105ca3:	8a 10                	mov    (%eax),%dl
f0105ca5:	84 d2                	test   %dl,%dl
f0105ca7:	75 f5                	jne    f0105c9e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0105ca9:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cae:	eb 05                	jmp    f0105cb5 <strchr+0x2c>
f0105cb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105cb5:	c9                   	leave  
f0105cb6:	c3                   	ret    

f0105cb7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105cb7:	55                   	push   %ebp
f0105cb8:	89 e5                	mov    %esp,%ebp
f0105cba:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cbd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105cc0:	8a 10                	mov    (%eax),%dl
f0105cc2:	84 d2                	test   %dl,%dl
f0105cc4:	74 11                	je     f0105cd7 <strfind+0x20>
		if (*s == c)
f0105cc6:	38 ca                	cmp    %cl,%dl
f0105cc8:	75 06                	jne    f0105cd0 <strfind+0x19>
f0105cca:	eb 0b                	jmp    f0105cd7 <strfind+0x20>
f0105ccc:	38 ca                	cmp    %cl,%dl
f0105cce:	74 07                	je     f0105cd7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105cd0:	40                   	inc    %eax
f0105cd1:	8a 10                	mov    (%eax),%dl
f0105cd3:	84 d2                	test   %dl,%dl
f0105cd5:	75 f5                	jne    f0105ccc <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f0105cd7:	c9                   	leave  
f0105cd8:	c3                   	ret    

f0105cd9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105cd9:	55                   	push   %ebp
f0105cda:	89 e5                	mov    %esp,%ebp
f0105cdc:	57                   	push   %edi
f0105cdd:	56                   	push   %esi
f0105cde:	53                   	push   %ebx
f0105cdf:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ce5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105ce8:	85 c9                	test   %ecx,%ecx
f0105cea:	74 30                	je     f0105d1c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105cec:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105cf2:	75 25                	jne    f0105d19 <memset+0x40>
f0105cf4:	f6 c1 03             	test   $0x3,%cl
f0105cf7:	75 20                	jne    f0105d19 <memset+0x40>
		c &= 0xFF;
f0105cf9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105cfc:	89 d3                	mov    %edx,%ebx
f0105cfe:	c1 e3 08             	shl    $0x8,%ebx
f0105d01:	89 d6                	mov    %edx,%esi
f0105d03:	c1 e6 18             	shl    $0x18,%esi
f0105d06:	89 d0                	mov    %edx,%eax
f0105d08:	c1 e0 10             	shl    $0x10,%eax
f0105d0b:	09 f0                	or     %esi,%eax
f0105d0d:	09 d0                	or     %edx,%eax
f0105d0f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105d11:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105d14:	fc                   	cld    
f0105d15:	f3 ab                	rep stos %eax,%es:(%edi)
f0105d17:	eb 03                	jmp    f0105d1c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105d19:	fc                   	cld    
f0105d1a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105d1c:	89 f8                	mov    %edi,%eax
f0105d1e:	5b                   	pop    %ebx
f0105d1f:	5e                   	pop    %esi
f0105d20:	5f                   	pop    %edi
f0105d21:	c9                   	leave  
f0105d22:	c3                   	ret    

f0105d23 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105d23:	55                   	push   %ebp
f0105d24:	89 e5                	mov    %esp,%ebp
f0105d26:	57                   	push   %edi
f0105d27:	56                   	push   %esi
f0105d28:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d2b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105d2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105d31:	39 c6                	cmp    %eax,%esi
f0105d33:	73 34                	jae    f0105d69 <memmove+0x46>
f0105d35:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105d38:	39 d0                	cmp    %edx,%eax
f0105d3a:	73 2d                	jae    f0105d69 <memmove+0x46>
		s += n;
		d += n;
f0105d3c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105d3f:	f6 c2 03             	test   $0x3,%dl
f0105d42:	75 1b                	jne    f0105d5f <memmove+0x3c>
f0105d44:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105d4a:	75 13                	jne    f0105d5f <memmove+0x3c>
f0105d4c:	f6 c1 03             	test   $0x3,%cl
f0105d4f:	75 0e                	jne    f0105d5f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105d51:	83 ef 04             	sub    $0x4,%edi
f0105d54:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105d57:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105d5a:	fd                   	std    
f0105d5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105d5d:	eb 07                	jmp    f0105d66 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105d5f:	4f                   	dec    %edi
f0105d60:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105d63:	fd                   	std    
f0105d64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105d66:	fc                   	cld    
f0105d67:	eb 20                	jmp    f0105d89 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105d69:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105d6f:	75 13                	jne    f0105d84 <memmove+0x61>
f0105d71:	a8 03                	test   $0x3,%al
f0105d73:	75 0f                	jne    f0105d84 <memmove+0x61>
f0105d75:	f6 c1 03             	test   $0x3,%cl
f0105d78:	75 0a                	jne    f0105d84 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105d7a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105d7d:	89 c7                	mov    %eax,%edi
f0105d7f:	fc                   	cld    
f0105d80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105d82:	eb 05                	jmp    f0105d89 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105d84:	89 c7                	mov    %eax,%edi
f0105d86:	fc                   	cld    
f0105d87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105d89:	5e                   	pop    %esi
f0105d8a:	5f                   	pop    %edi
f0105d8b:	c9                   	leave  
f0105d8c:	c3                   	ret    

f0105d8d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105d8d:	55                   	push   %ebp
f0105d8e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105d90:	ff 75 10             	pushl  0x10(%ebp)
f0105d93:	ff 75 0c             	pushl  0xc(%ebp)
f0105d96:	ff 75 08             	pushl  0x8(%ebp)
f0105d99:	e8 85 ff ff ff       	call   f0105d23 <memmove>
}
f0105d9e:	c9                   	leave  
f0105d9f:	c3                   	ret    

f0105da0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105da0:	55                   	push   %ebp
f0105da1:	89 e5                	mov    %esp,%ebp
f0105da3:	57                   	push   %edi
f0105da4:	56                   	push   %esi
f0105da5:	53                   	push   %ebx
f0105da6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105da9:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105dac:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105daf:	85 ff                	test   %edi,%edi
f0105db1:	74 32                	je     f0105de5 <memcmp+0x45>
		if (*s1 != *s2)
f0105db3:	8a 03                	mov    (%ebx),%al
f0105db5:	8a 0e                	mov    (%esi),%cl
f0105db7:	38 c8                	cmp    %cl,%al
f0105db9:	74 19                	je     f0105dd4 <memcmp+0x34>
f0105dbb:	eb 0d                	jmp    f0105dca <memcmp+0x2a>
f0105dbd:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0105dc1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0105dc5:	42                   	inc    %edx
f0105dc6:	38 c8                	cmp    %cl,%al
f0105dc8:	74 10                	je     f0105dda <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f0105dca:	0f b6 c0             	movzbl %al,%eax
f0105dcd:	0f b6 c9             	movzbl %cl,%ecx
f0105dd0:	29 c8                	sub    %ecx,%eax
f0105dd2:	eb 16                	jmp    f0105dea <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105dd4:	4f                   	dec    %edi
f0105dd5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105dda:	39 fa                	cmp    %edi,%edx
f0105ddc:	75 df                	jne    f0105dbd <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105dde:	b8 00 00 00 00       	mov    $0x0,%eax
f0105de3:	eb 05                	jmp    f0105dea <memcmp+0x4a>
f0105de5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105dea:	5b                   	pop    %ebx
f0105deb:	5e                   	pop    %esi
f0105dec:	5f                   	pop    %edi
f0105ded:	c9                   	leave  
f0105dee:	c3                   	ret    

f0105def <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105def:	55                   	push   %ebp
f0105df0:	89 e5                	mov    %esp,%ebp
f0105df2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105df5:	89 c2                	mov    %eax,%edx
f0105df7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105dfa:	39 d0                	cmp    %edx,%eax
f0105dfc:	73 12                	jae    f0105e10 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105dfe:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0105e01:	38 08                	cmp    %cl,(%eax)
f0105e03:	75 06                	jne    f0105e0b <memfind+0x1c>
f0105e05:	eb 09                	jmp    f0105e10 <memfind+0x21>
f0105e07:	38 08                	cmp    %cl,(%eax)
f0105e09:	74 05                	je     f0105e10 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105e0b:	40                   	inc    %eax
f0105e0c:	39 c2                	cmp    %eax,%edx
f0105e0e:	77 f7                	ja     f0105e07 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105e10:	c9                   	leave  
f0105e11:	c3                   	ret    

f0105e12 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105e12:	55                   	push   %ebp
f0105e13:	89 e5                	mov    %esp,%ebp
f0105e15:	57                   	push   %edi
f0105e16:	56                   	push   %esi
f0105e17:	53                   	push   %ebx
f0105e18:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e1e:	eb 01                	jmp    f0105e21 <strtol+0xf>
		s++;
f0105e20:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e21:	8a 02                	mov    (%edx),%al
f0105e23:	3c 20                	cmp    $0x20,%al
f0105e25:	74 f9                	je     f0105e20 <strtol+0xe>
f0105e27:	3c 09                	cmp    $0x9,%al
f0105e29:	74 f5                	je     f0105e20 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105e2b:	3c 2b                	cmp    $0x2b,%al
f0105e2d:	75 08                	jne    f0105e37 <strtol+0x25>
		s++;
f0105e2f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105e30:	bf 00 00 00 00       	mov    $0x0,%edi
f0105e35:	eb 13                	jmp    f0105e4a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105e37:	3c 2d                	cmp    $0x2d,%al
f0105e39:	75 0a                	jne    f0105e45 <strtol+0x33>
		s++, neg = 1;
f0105e3b:	8d 52 01             	lea    0x1(%edx),%edx
f0105e3e:	bf 01 00 00 00       	mov    $0x1,%edi
f0105e43:	eb 05                	jmp    f0105e4a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105e45:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105e4a:	85 db                	test   %ebx,%ebx
f0105e4c:	74 05                	je     f0105e53 <strtol+0x41>
f0105e4e:	83 fb 10             	cmp    $0x10,%ebx
f0105e51:	75 28                	jne    f0105e7b <strtol+0x69>
f0105e53:	8a 02                	mov    (%edx),%al
f0105e55:	3c 30                	cmp    $0x30,%al
f0105e57:	75 10                	jne    f0105e69 <strtol+0x57>
f0105e59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105e5d:	75 0a                	jne    f0105e69 <strtol+0x57>
		s += 2, base = 16;
f0105e5f:	83 c2 02             	add    $0x2,%edx
f0105e62:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105e67:	eb 12                	jmp    f0105e7b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0105e69:	85 db                	test   %ebx,%ebx
f0105e6b:	75 0e                	jne    f0105e7b <strtol+0x69>
f0105e6d:	3c 30                	cmp    $0x30,%al
f0105e6f:	75 05                	jne    f0105e76 <strtol+0x64>
		s++, base = 8;
f0105e71:	42                   	inc    %edx
f0105e72:	b3 08                	mov    $0x8,%bl
f0105e74:	eb 05                	jmp    f0105e7b <strtol+0x69>
	else if (base == 0)
		base = 10;
f0105e76:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0105e7b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e80:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105e82:	8a 0a                	mov    (%edx),%cl
f0105e84:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105e87:	80 fb 09             	cmp    $0x9,%bl
f0105e8a:	77 08                	ja     f0105e94 <strtol+0x82>
			dig = *s - '0';
f0105e8c:	0f be c9             	movsbl %cl,%ecx
f0105e8f:	83 e9 30             	sub    $0x30,%ecx
f0105e92:	eb 1e                	jmp    f0105eb2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0105e94:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0105e97:	80 fb 19             	cmp    $0x19,%bl
f0105e9a:	77 08                	ja     f0105ea4 <strtol+0x92>
			dig = *s - 'a' + 10;
f0105e9c:	0f be c9             	movsbl %cl,%ecx
f0105e9f:	83 e9 57             	sub    $0x57,%ecx
f0105ea2:	eb 0e                	jmp    f0105eb2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0105ea4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0105ea7:	80 fb 19             	cmp    $0x19,%bl
f0105eaa:	77 13                	ja     f0105ebf <strtol+0xad>
			dig = *s - 'A' + 10;
f0105eac:	0f be c9             	movsbl %cl,%ecx
f0105eaf:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105eb2:	39 f1                	cmp    %esi,%ecx
f0105eb4:	7d 0d                	jge    f0105ec3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f0105eb6:	42                   	inc    %edx
f0105eb7:	0f af c6             	imul   %esi,%eax
f0105eba:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0105ebd:	eb c3                	jmp    f0105e82 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0105ebf:	89 c1                	mov    %eax,%ecx
f0105ec1:	eb 02                	jmp    f0105ec5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105ec3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0105ec5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105ec9:	74 05                	je     f0105ed0 <strtol+0xbe>
		*endptr = (char *) s;
f0105ecb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105ece:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105ed0:	85 ff                	test   %edi,%edi
f0105ed2:	74 04                	je     f0105ed8 <strtol+0xc6>
f0105ed4:	89 c8                	mov    %ecx,%eax
f0105ed6:	f7 d8                	neg    %eax
}
f0105ed8:	5b                   	pop    %ebx
f0105ed9:	5e                   	pop    %esi
f0105eda:	5f                   	pop    %edi
f0105edb:	c9                   	leave  
f0105edc:	c3                   	ret    
f0105edd:	00 00                	add    %al,(%eax)
	...

f0105ee0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105ee0:	fa                   	cli    

	xorw    %ax, %ax
f0105ee1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105ee3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105ee5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105ee7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105ee9:	0f 01 16             	lgdtl  (%esi)
f0105eec:	74 70                	je     f0105f5e <sum+0x2>
	movl    %cr0, %eax
f0105eee:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105ef1:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105ef5:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105ef8:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105efe:	08 00                	or     %al,(%eax)

f0105f00 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105f00:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105f04:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f06:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f08:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105f0a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105f0e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105f10:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105f12:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl    %eax, %cr3
f0105f17:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105f1a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105f1d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105f22:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105f25:	8b 25 84 1e 21 f0    	mov    0xf0211e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105f2b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105f30:	b8 c2 00 10 f0       	mov    $0xf01000c2,%eax
	call    *%eax
f0105f35:	ff d0                	call   *%eax

f0105f37 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105f37:	eb fe                	jmp    f0105f37 <spin>
f0105f39:	8d 76 00             	lea    0x0(%esi),%esi

f0105f3c <gdt>:
	...
f0105f44:	ff                   	(bad)  
f0105f45:	ff 00                	incl   (%eax)
f0105f47:	00 00                	add    %al,(%eax)
f0105f49:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105f50:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105f54 <gdtdesc>:
f0105f54:	17                   	pop    %ss
f0105f55:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105f5a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105f5a:	90                   	nop
	...

f0105f5c <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105f5c:	55                   	push   %ebp
f0105f5d:	89 e5                	mov    %esp,%ebp
f0105f5f:	56                   	push   %esi
f0105f60:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105f61:	85 d2                	test   %edx,%edx
f0105f63:	7e 17                	jle    f0105f7c <sum+0x20>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105f65:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0105f6a:	b9 00 00 00 00       	mov    $0x0,%ecx
		sum += ((uint8_t *)addr)[i];
f0105f6f:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0105f73:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105f75:	41                   	inc    %ecx
f0105f76:	39 d1                	cmp    %edx,%ecx
f0105f78:	75 f5                	jne    f0105f6f <sum+0x13>
f0105f7a:	eb 05                	jmp    f0105f81 <sum+0x25>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105f7c:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0105f81:	88 d8                	mov    %bl,%al
f0105f83:	5b                   	pop    %ebx
f0105f84:	5e                   	pop    %esi
f0105f85:	c9                   	leave  
f0105f86:	c3                   	ret    

f0105f87 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105f87:	55                   	push   %ebp
f0105f88:	89 e5                	mov    %esp,%ebp
f0105f8a:	56                   	push   %esi
f0105f8b:	53                   	push   %ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f8c:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f0105f92:	89 c3                	mov    %eax,%ebx
f0105f94:	c1 eb 0c             	shr    $0xc,%ebx
f0105f97:	39 cb                	cmp    %ecx,%ebx
f0105f99:	72 12                	jb     f0105fad <mpsearch1+0x26>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f9b:	50                   	push   %eax
f0105f9c:	68 08 6a 10 f0       	push   $0xf0106a08
f0105fa1:	6a 57                	push   $0x57
f0105fa3:	68 fd 89 10 f0       	push   $0xf01089fd
f0105fa8:	e8 bb a0 ff ff       	call   f0100068 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105fad:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105fb0:	89 f2                	mov    %esi,%edx
f0105fb2:	c1 ea 0c             	shr    $0xc,%edx
f0105fb5:	39 d1                	cmp    %edx,%ecx
f0105fb7:	77 12                	ja     f0105fcb <mpsearch1+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fb9:	56                   	push   %esi
f0105fba:	68 08 6a 10 f0       	push   $0xf0106a08
f0105fbf:	6a 57                	push   $0x57
f0105fc1:	68 fd 89 10 f0       	push   $0xf01089fd
f0105fc6:	e8 9d a0 ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f0105fcb:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0105fd1:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105fd7:	39 f3                	cmp    %esi,%ebx
f0105fd9:	73 35                	jae    f0106010 <mpsearch1+0x89>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105fdb:	83 ec 04             	sub    $0x4,%esp
f0105fde:	6a 04                	push   $0x4
f0105fe0:	68 0d 8a 10 f0       	push   $0xf0108a0d
f0105fe5:	53                   	push   %ebx
f0105fe6:	e8 b5 fd ff ff       	call   f0105da0 <memcmp>
f0105feb:	83 c4 10             	add    $0x10,%esp
f0105fee:	85 c0                	test   %eax,%eax
f0105ff0:	75 10                	jne    f0106002 <mpsearch1+0x7b>
		    sum(mp, sizeof(*mp)) == 0)
f0105ff2:	ba 10 00 00 00       	mov    $0x10,%edx
f0105ff7:	89 d8                	mov    %ebx,%eax
f0105ff9:	e8 5e ff ff ff       	call   f0105f5c <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ffe:	84 c0                	test   %al,%al
f0106000:	74 13                	je     f0106015 <mpsearch1+0x8e>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106002:	83 c3 10             	add    $0x10,%ebx
f0106005:	39 de                	cmp    %ebx,%esi
f0106007:	77 d2                	ja     f0105fdb <mpsearch1+0x54>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106009:	bb 00 00 00 00       	mov    $0x0,%ebx
f010600e:	eb 05                	jmp    f0106015 <mpsearch1+0x8e>
f0106010:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106015:	89 d8                	mov    %ebx,%eax
f0106017:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010601a:	5b                   	pop    %ebx
f010601b:	5e                   	pop    %esi
f010601c:	c9                   	leave  
f010601d:	c3                   	ret    

f010601e <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010601e:	55                   	push   %ebp
f010601f:	89 e5                	mov    %esp,%ebp
f0106021:	57                   	push   %edi
f0106022:	56                   	push   %esi
f0106023:	53                   	push   %ebx
f0106024:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106027:	c7 05 c0 23 21 f0 20 	movl   $0xf0212020,0xf02123c0
f010602e:	20 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106031:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f0106038:	75 16                	jne    f0106050 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010603a:	68 00 04 00 00       	push   $0x400
f010603f:	68 08 6a 10 f0       	push   $0xf0106a08
f0106044:	6a 6f                	push   $0x6f
f0106046:	68 fd 89 10 f0       	push   $0xf01089fd
f010604b:	e8 18 a0 ff ff       	call   f0100068 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106050:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106057:	85 c0                	test   %eax,%eax
f0106059:	74 16                	je     f0106071 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
f010605b:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010605e:	ba 00 04 00 00       	mov    $0x400,%edx
f0106063:	e8 1f ff ff ff       	call   f0105f87 <mpsearch1>
f0106068:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010606b:	85 c0                	test   %eax,%eax
f010606d:	75 3c                	jne    f01060ab <mp_init+0x8d>
f010606f:	eb 20                	jmp    f0106091 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106071:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106078:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010607b:	2d 00 04 00 00       	sub    $0x400,%eax
f0106080:	ba 00 04 00 00       	mov    $0x400,%edx
f0106085:	e8 fd fe ff ff       	call   f0105f87 <mpsearch1>
f010608a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010608d:	85 c0                	test   %eax,%eax
f010608f:	75 1a                	jne    f01060ab <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106091:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106096:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010609b:	e8 e7 fe ff ff       	call   f0105f87 <mpsearch1>
f01060a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01060a3:	85 c0                	test   %eax,%eax
f01060a5:	0f 84 3b 02 00 00    	je     f01062e6 <mp_init+0x2c8>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01060ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01060ae:	8b 70 04             	mov    0x4(%eax),%esi
f01060b1:	85 f6                	test   %esi,%esi
f01060b3:	74 06                	je     f01060bb <mp_init+0x9d>
f01060b5:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01060b9:	74 15                	je     f01060d0 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f01060bb:	83 ec 0c             	sub    $0xc,%esp
f01060be:	68 70 88 10 f0       	push   $0xf0108870
f01060c3:	e8 4d dc ff ff       	call   f0103d15 <cprintf>
f01060c8:	83 c4 10             	add    $0x10,%esp
f01060cb:	e9 16 02 00 00       	jmp    f01062e6 <mp_init+0x2c8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01060d0:	89 f0                	mov    %esi,%eax
f01060d2:	c1 e8 0c             	shr    $0xc,%eax
f01060d5:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f01060db:	72 15                	jb     f01060f2 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01060dd:	56                   	push   %esi
f01060de:	68 08 6a 10 f0       	push   $0xf0106a08
f01060e3:	68 90 00 00 00       	push   $0x90
f01060e8:	68 fd 89 10 f0       	push   $0xf01089fd
f01060ed:	e8 76 9f ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f01060f2:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01060f8:	83 ec 04             	sub    $0x4,%esp
f01060fb:	6a 04                	push   $0x4
f01060fd:	68 12 8a 10 f0       	push   $0xf0108a12
f0106102:	56                   	push   %esi
f0106103:	e8 98 fc ff ff       	call   f0105da0 <memcmp>
f0106108:	83 c4 10             	add    $0x10,%esp
f010610b:	85 c0                	test   %eax,%eax
f010610d:	74 15                	je     f0106124 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010610f:	83 ec 0c             	sub    $0xc,%esp
f0106112:	68 a0 88 10 f0       	push   $0xf01088a0
f0106117:	e8 f9 db ff ff       	call   f0103d15 <cprintf>
f010611c:	83 c4 10             	add    $0x10,%esp
f010611f:	e9 c2 01 00 00       	jmp    f01062e6 <mp_init+0x2c8>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106124:	66 8b 5e 04          	mov    0x4(%esi),%bx
f0106128:	0f b7 d3             	movzwl %bx,%edx
f010612b:	89 f0                	mov    %esi,%eax
f010612d:	e8 2a fe ff ff       	call   f0105f5c <sum>
f0106132:	84 c0                	test   %al,%al
f0106134:	74 15                	je     f010614b <mp_init+0x12d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106136:	83 ec 0c             	sub    $0xc,%esp
f0106139:	68 d4 88 10 f0       	push   $0xf01088d4
f010613e:	e8 d2 db ff ff       	call   f0103d15 <cprintf>
f0106143:	83 c4 10             	add    $0x10,%esp
f0106146:	e9 9b 01 00 00       	jmp    f01062e6 <mp_init+0x2c8>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010614b:	8a 46 06             	mov    0x6(%esi),%al
f010614e:	3c 01                	cmp    $0x1,%al
f0106150:	74 1d                	je     f010616f <mp_init+0x151>
f0106152:	3c 04                	cmp    $0x4,%al
f0106154:	74 19                	je     f010616f <mp_init+0x151>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106156:	83 ec 08             	sub    $0x8,%esp
f0106159:	0f b6 c0             	movzbl %al,%eax
f010615c:	50                   	push   %eax
f010615d:	68 f8 88 10 f0       	push   $0xf01088f8
f0106162:	e8 ae db ff ff       	call   f0103d15 <cprintf>
f0106167:	83 c4 10             	add    $0x10,%esp
f010616a:	e9 77 01 00 00       	jmp    f01062e6 <mp_init+0x2c8>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f010616f:	0f b7 56 28          	movzwl 0x28(%esi),%edx
f0106173:	0f b7 c3             	movzwl %bx,%eax
f0106176:	8d 04 06             	lea    (%esi,%eax,1),%eax
f0106179:	e8 de fd ff ff       	call   f0105f5c <sum>
f010617e:	3a 46 2a             	cmp    0x2a(%esi),%al
f0106181:	74 15                	je     f0106198 <mp_init+0x17a>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106183:	83 ec 0c             	sub    $0xc,%esp
f0106186:	68 18 89 10 f0       	push   $0xf0108918
f010618b:	e8 85 db ff ff       	call   f0103d15 <cprintf>
f0106190:	83 c4 10             	add    $0x10,%esp
f0106193:	e9 4e 01 00 00       	jmp    f01062e6 <mp_init+0x2c8>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106198:	85 f6                	test   %esi,%esi
f010619a:	0f 84 46 01 00 00    	je     f01062e6 <mp_init+0x2c8>
		return;
	ismp = 1;
f01061a0:	c7 05 00 20 21 f0 01 	movl   $0x1,0xf0212000
f01061a7:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01061aa:	8b 46 24             	mov    0x24(%esi),%eax
f01061ad:	a3 00 30 25 f0       	mov    %eax,0xf0253000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01061b2:	66 83 7e 22 00       	cmpw   $0x0,0x22(%esi)
f01061b7:	0f 84 ac 00 00 00    	je     f0106269 <mp_init+0x24b>
f01061bd:	8d 5e 2c             	lea    0x2c(%esi),%ebx
f01061c0:	bf 00 00 00 00       	mov    $0x0,%edi
		switch (*p) {
f01061c5:	8a 03                	mov    (%ebx),%al
f01061c7:	84 c0                	test   %al,%al
f01061c9:	74 06                	je     f01061d1 <mp_init+0x1b3>
f01061cb:	3c 04                	cmp    $0x4,%al
f01061cd:	77 6b                	ja     f010623a <mp_init+0x21c>
f01061cf:	eb 64                	jmp    f0106235 <mp_init+0x217>
		case MPPROC:
			proc = (struct mpproc *)p;
f01061d1:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f01061d3:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f01061d7:	74 1d                	je     f01061f6 <mp_init+0x1d8>
				bootcpu = &cpus[ncpu];
f01061d9:	a1 c4 23 21 f0       	mov    0xf02123c4,%eax
f01061de:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f01061e5:	29 c1                	sub    %eax,%ecx
f01061e7:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f01061ea:	8d 04 85 20 20 21 f0 	lea    -0xfdedfe0(,%eax,4),%eax
f01061f1:	a3 c0 23 21 f0       	mov    %eax,0xf02123c0
			if (ncpu < NCPU) {
f01061f6:	a1 c4 23 21 f0       	mov    0xf02123c4,%eax
f01061fb:	83 f8 07             	cmp    $0x7,%eax
f01061fe:	7f 1b                	jg     f010621b <mp_init+0x1fd>
				cpus[ncpu].cpu_id = ncpu;
f0106200:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106207:	29 c2                	sub    %eax,%edx
f0106209:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010620c:	88 04 95 20 20 21 f0 	mov    %al,-0xfdedfe0(,%edx,4)
				ncpu++;
f0106213:	40                   	inc    %eax
f0106214:	a3 c4 23 21 f0       	mov    %eax,0xf02123c4
f0106219:	eb 15                	jmp    f0106230 <mp_init+0x212>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010621b:	83 ec 08             	sub    $0x8,%esp
f010621e:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0106222:	50                   	push   %eax
f0106223:	68 48 89 10 f0       	push   $0xf0108948
f0106228:	e8 e8 da ff ff       	call   f0103d15 <cprintf>
f010622d:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106230:	83 c3 14             	add    $0x14,%ebx
			continue;
f0106233:	eb 27                	jmp    f010625c <mp_init+0x23e>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106235:	83 c3 08             	add    $0x8,%ebx
			continue;
f0106238:	eb 22                	jmp    f010625c <mp_init+0x23e>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010623a:	83 ec 08             	sub    $0x8,%esp
f010623d:	0f b6 c0             	movzbl %al,%eax
f0106240:	50                   	push   %eax
f0106241:	68 70 89 10 f0       	push   $0xf0108970
f0106246:	e8 ca da ff ff       	call   f0103d15 <cprintf>
			ismp = 0;
f010624b:	c7 05 00 20 21 f0 00 	movl   $0x0,0xf0212000
f0106252:	00 00 00 
			i = conf->entry;
f0106255:	0f b7 7e 22          	movzwl 0x22(%esi),%edi
f0106259:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010625c:	47                   	inc    %edi
f010625d:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0106261:	39 f8                	cmp    %edi,%eax
f0106263:	0f 87 5c ff ff ff    	ja     f01061c5 <mp_init+0x1a7>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106269:	a1 c0 23 21 f0       	mov    0xf02123c0,%eax
f010626e:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106275:	83 3d 00 20 21 f0 00 	cmpl   $0x0,0xf0212000
f010627c:	75 26                	jne    f01062a4 <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010627e:	c7 05 c4 23 21 f0 01 	movl   $0x1,0xf02123c4
f0106285:	00 00 00 
		lapicaddr = 0;
f0106288:	c7 05 00 30 25 f0 00 	movl   $0x0,0xf0253000
f010628f:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106292:	83 ec 0c             	sub    $0xc,%esp
f0106295:	68 90 89 10 f0       	push   $0xf0108990
f010629a:	e8 76 da ff ff       	call   f0103d15 <cprintf>
		return;
f010629f:	83 c4 10             	add    $0x10,%esp
f01062a2:	eb 42                	jmp    f01062e6 <mp_init+0x2c8>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01062a4:	83 ec 04             	sub    $0x4,%esp
f01062a7:	ff 35 c4 23 21 f0    	pushl  0xf02123c4
f01062ad:	0f b6 00             	movzbl (%eax),%eax
f01062b0:	50                   	push   %eax
f01062b1:	68 17 8a 10 f0       	push   $0xf0108a17
f01062b6:	e8 5a da ff ff       	call   f0103d15 <cprintf>

	if (mp->imcrp) {
f01062bb:	83 c4 10             	add    $0x10,%esp
f01062be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01062c1:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01062c5:	74 1f                	je     f01062e6 <mp_init+0x2c8>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01062c7:	83 ec 0c             	sub    $0xc,%esp
f01062ca:	68 bc 89 10 f0       	push   $0xf01089bc
f01062cf:	e8 41 da ff ff       	call   f0103d15 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01062d4:	ba 22 00 00 00       	mov    $0x22,%edx
f01062d9:	b0 70                	mov    $0x70,%al
f01062db:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01062dc:	b2 23                	mov    $0x23,%dl
f01062de:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01062df:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01062e2:	ee                   	out    %al,(%dx)
f01062e3:	83 c4 10             	add    $0x10,%esp
	}
}
f01062e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01062e9:	5b                   	pop    %ebx
f01062ea:	5e                   	pop    %esi
f01062eb:	5f                   	pop    %edi
f01062ec:	c9                   	leave  
f01062ed:	c3                   	ret    
	...

f01062f0 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01062f0:	55                   	push   %ebp
f01062f1:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01062f3:	c1 e0 02             	shl    $0x2,%eax
f01062f6:	03 05 04 30 25 f0    	add    0xf0253004,%eax
f01062fc:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01062fe:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0106303:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106306:	c9                   	leave  
f0106307:	c3                   	ret    

f0106308 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106308:	55                   	push   %ebp
f0106309:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010630b:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0106310:	85 c0                	test   %eax,%eax
f0106312:	74 08                	je     f010631c <cpunum+0x14>
		return lapic[ID] >> 24;
f0106314:	8b 40 20             	mov    0x20(%eax),%eax
f0106317:	c1 e8 18             	shr    $0x18,%eax
f010631a:	eb 05                	jmp    f0106321 <cpunum+0x19>
	return 0;
f010631c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106321:	c9                   	leave  
f0106322:	c3                   	ret    

f0106323 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106323:	55                   	push   %ebp
f0106324:	89 e5                	mov    %esp,%ebp
f0106326:	83 ec 08             	sub    $0x8,%esp
	if (!lapicaddr)
f0106329:	a1 00 30 25 f0       	mov    0xf0253000,%eax
f010632e:	85 c0                	test   %eax,%eax
f0106330:	0f 84 2a 01 00 00    	je     f0106460 <lapic_init+0x13d>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106336:	83 ec 08             	sub    $0x8,%esp
f0106339:	68 00 10 00 00       	push   $0x1000
f010633e:	50                   	push   %eax
f010633f:	e8 d2 b5 ff ff       	call   f0101916 <mmio_map_region>
f0106344:	a3 04 30 25 f0       	mov    %eax,0xf0253004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106349:	ba 27 01 00 00       	mov    $0x127,%edx
f010634e:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106353:	e8 98 ff ff ff       	call   f01062f0 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106358:	ba 0b 00 00 00       	mov    $0xb,%edx
f010635d:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106362:	e8 89 ff ff ff       	call   f01062f0 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106367:	ba 20 00 02 00       	mov    $0x20020,%edx
f010636c:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106371:	e8 7a ff ff ff       	call   f01062f0 <lapicw>
	lapicw(TICR, 10000000); 
f0106376:	ba 80 96 98 00       	mov    $0x989680,%edx
f010637b:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106380:	e8 6b ff ff ff       	call   f01062f0 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106385:	e8 7e ff ff ff       	call   f0106308 <cpunum>
f010638a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106391:	29 c2                	sub    %eax,%edx
f0106393:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106396:	8d 04 85 20 20 21 f0 	lea    -0xfdedfe0(,%eax,4),%eax
f010639d:	83 c4 10             	add    $0x10,%esp
f01063a0:	39 05 c0 23 21 f0    	cmp    %eax,0xf02123c0
f01063a6:	74 0f                	je     f01063b7 <lapic_init+0x94>
		lapicw(LINT0, MASKED);
f01063a8:	ba 00 00 01 00       	mov    $0x10000,%edx
f01063ad:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01063b2:	e8 39 ff ff ff       	call   f01062f0 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01063b7:	ba 00 00 01 00       	mov    $0x10000,%edx
f01063bc:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01063c1:	e8 2a ff ff ff       	call   f01062f0 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01063c6:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f01063cb:	8b 40 30             	mov    0x30(%eax),%eax
f01063ce:	c1 e8 10             	shr    $0x10,%eax
f01063d1:	3c 03                	cmp    $0x3,%al
f01063d3:	76 0f                	jbe    f01063e4 <lapic_init+0xc1>
		lapicw(PCINT, MASKED);
f01063d5:	ba 00 00 01 00       	mov    $0x10000,%edx
f01063da:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01063df:	e8 0c ff ff ff       	call   f01062f0 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01063e4:	ba 33 00 00 00       	mov    $0x33,%edx
f01063e9:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01063ee:	e8 fd fe ff ff       	call   f01062f0 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01063f3:	ba 00 00 00 00       	mov    $0x0,%edx
f01063f8:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01063fd:	e8 ee fe ff ff       	call   f01062f0 <lapicw>
	lapicw(ESR, 0);
f0106402:	ba 00 00 00 00       	mov    $0x0,%edx
f0106407:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010640c:	e8 df fe ff ff       	call   f01062f0 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106411:	ba 00 00 00 00       	mov    $0x0,%edx
f0106416:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010641b:	e8 d0 fe ff ff       	call   f01062f0 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106420:	ba 00 00 00 00       	mov    $0x0,%edx
f0106425:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010642a:	e8 c1 fe ff ff       	call   f01062f0 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010642f:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106434:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106439:	e8 b2 fe ff ff       	call   f01062f0 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010643e:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f0106444:	81 c2 00 03 00 00    	add    $0x300,%edx
f010644a:	8b 02                	mov    (%edx),%eax
f010644c:	f6 c4 10             	test   $0x10,%ah
f010644f:	75 f9                	jne    f010644a <lapic_init+0x127>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106451:	ba 00 00 00 00       	mov    $0x0,%edx
f0106456:	b8 20 00 00 00       	mov    $0x20,%eax
f010645b:	e8 90 fe ff ff       	call   f01062f0 <lapicw>
}
f0106460:	c9                   	leave  
f0106461:	c3                   	ret    

f0106462 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106462:	55                   	push   %ebp
f0106463:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106465:	83 3d 04 30 25 f0 00 	cmpl   $0x0,0xf0253004
f010646c:	74 0f                	je     f010647d <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f010646e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106473:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106478:	e8 73 fe ff ff       	call   f01062f0 <lapicw>
}
f010647d:	c9                   	leave  
f010647e:	c3                   	ret    

f010647f <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010647f:	55                   	push   %ebp
f0106480:	89 e5                	mov    %esp,%ebp
f0106482:	56                   	push   %esi
f0106483:	53                   	push   %ebx
f0106484:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106487:	8a 5d 08             	mov    0x8(%ebp),%bl
f010648a:	ba 70 00 00 00       	mov    $0x70,%edx
f010648f:	b0 0f                	mov    $0xf,%al
f0106491:	ee                   	out    %al,(%dx)
f0106492:	b2 71                	mov    $0x71,%dl
f0106494:	b0 0a                	mov    $0xa,%al
f0106496:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106497:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f010649e:	75 19                	jne    f01064b9 <lapic_startap+0x3a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01064a0:	68 67 04 00 00       	push   $0x467
f01064a5:	68 08 6a 10 f0       	push   $0xf0106a08
f01064aa:	68 98 00 00 00       	push   $0x98
f01064af:	68 34 8a 10 f0       	push   $0xf0108a34
f01064b4:	e8 af 9b ff ff       	call   f0100068 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01064b9:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01064c0:	00 00 
	wrv[1] = addr >> 4;
f01064c2:	89 f0                	mov    %esi,%eax
f01064c4:	c1 e8 04             	shr    $0x4,%eax
f01064c7:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01064cd:	c1 e3 18             	shl    $0x18,%ebx
f01064d0:	89 da                	mov    %ebx,%edx
f01064d2:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01064d7:	e8 14 fe ff ff       	call   f01062f0 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01064dc:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01064e1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01064e6:	e8 05 fe ff ff       	call   f01062f0 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01064eb:	ba 00 85 00 00       	mov    $0x8500,%edx
f01064f0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01064f5:	e8 f6 fd ff ff       	call   f01062f0 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01064fa:	c1 ee 0c             	shr    $0xc,%esi
f01064fd:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106503:	89 da                	mov    %ebx,%edx
f0106505:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010650a:	e8 e1 fd ff ff       	call   f01062f0 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010650f:	89 f2                	mov    %esi,%edx
f0106511:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106516:	e8 d5 fd ff ff       	call   f01062f0 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010651b:	89 da                	mov    %ebx,%edx
f010651d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106522:	e8 c9 fd ff ff       	call   f01062f0 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106527:	89 f2                	mov    %esi,%edx
f0106529:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010652e:	e8 bd fd ff ff       	call   f01062f0 <lapicw>
		microdelay(200);
	}
}
f0106533:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106536:	5b                   	pop    %ebx
f0106537:	5e                   	pop    %esi
f0106538:	c9                   	leave  
f0106539:	c3                   	ret    

f010653a <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010653a:	55                   	push   %ebp
f010653b:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010653d:	8b 55 08             	mov    0x8(%ebp),%edx
f0106540:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106546:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010654b:	e8 a0 fd ff ff       	call   f01062f0 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106550:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f0106556:	81 c2 00 03 00 00    	add    $0x300,%edx
f010655c:	8b 02                	mov    (%edx),%eax
f010655e:	f6 c4 10             	test   $0x10,%ah
f0106561:	75 f9                	jne    f010655c <lapic_ipi+0x22>
		;
}
f0106563:	c9                   	leave  
f0106564:	c3                   	ret    
f0106565:	00 00                	add    %al,(%eax)
	...

f0106568 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106568:	55                   	push   %ebp
f0106569:	89 e5                	mov    %esp,%ebp
f010656b:	53                   	push   %ebx
f010656c:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f010656f:	83 38 00             	cmpl   $0x0,(%eax)
f0106572:	74 25                	je     f0106599 <holding+0x31>
f0106574:	8b 58 08             	mov    0x8(%eax),%ebx
f0106577:	e8 8c fd ff ff       	call   f0106308 <cpunum>
f010657c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106583:	29 c2                	sub    %eax,%edx
f0106585:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106588:	8d 04 85 20 20 21 f0 	lea    -0xfdedfe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f010658f:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106591:	0f 94 c0             	sete   %al
f0106594:	0f b6 c0             	movzbl %al,%eax
f0106597:	eb 05                	jmp    f010659e <holding+0x36>
f0106599:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010659e:	83 c4 04             	add    $0x4,%esp
f01065a1:	5b                   	pop    %ebx
f01065a2:	c9                   	leave  
f01065a3:	c3                   	ret    

f01065a4 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01065a4:	55                   	push   %ebp
f01065a5:	89 e5                	mov    %esp,%ebp
f01065a7:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01065aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01065b0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01065b3:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01065b6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01065bd:	c9                   	leave  
f01065be:	c3                   	ret    

f01065bf <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01065bf:	55                   	push   %ebp
f01065c0:	89 e5                	mov    %esp,%ebp
f01065c2:	53                   	push   %ebx
f01065c3:	83 ec 04             	sub    $0x4,%esp
f01065c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01065c9:	89 d8                	mov    %ebx,%eax
f01065cb:	e8 98 ff ff ff       	call   f0106568 <holding>
f01065d0:	85 c0                	test   %eax,%eax
f01065d2:	75 0d                	jne    f01065e1 <spin_lock+0x22>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01065d4:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01065d6:	b0 01                	mov    $0x1,%al
f01065d8:	f0 87 03             	lock xchg %eax,(%ebx)
f01065db:	85 c0                	test   %eax,%eax
f01065dd:	75 20                	jne    f01065ff <spin_lock+0x40>
f01065df:	eb 2e                	jmp    f010660f <spin_lock+0x50>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01065e1:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01065e4:	e8 1f fd ff ff       	call   f0106308 <cpunum>
f01065e9:	83 ec 0c             	sub    $0xc,%esp
f01065ec:	53                   	push   %ebx
f01065ed:	50                   	push   %eax
f01065ee:	68 44 8a 10 f0       	push   $0xf0108a44
f01065f3:	6a 41                	push   $0x41
f01065f5:	68 a8 8a 10 f0       	push   $0xf0108aa8
f01065fa:	e8 69 9a ff ff       	call   f0100068 <_panic>
f01065ff:	b9 01 00 00 00       	mov    $0x1,%ecx

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106604:	f3 90                	pause  
f0106606:	89 c8                	mov    %ecx,%eax
f0106608:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010660b:	85 c0                	test   %eax,%eax
f010660d:	75 f5                	jne    f0106604 <spin_lock+0x45>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010660f:	e8 f4 fc ff ff       	call   f0106308 <cpunum>
f0106614:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010661b:	29 c2                	sub    %eax,%edx
f010661d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106620:	8d 04 85 20 20 21 f0 	lea    -0xfdedfe0(,%eax,4),%eax
f0106627:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f010662a:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010662d:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010662f:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0106634:	77 30                	ja     f0106666 <spin_lock+0xa7>
f0106636:	eb 27                	jmp    f010665f <spin_lock+0xa0>
f0106638:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010663e:	76 10                	jbe    f0106650 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106640:	8b 5a 04             	mov    0x4(%edx),%ebx
f0106643:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106646:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106648:	40                   	inc    %eax
f0106649:	83 f8 0a             	cmp    $0xa,%eax
f010664c:	75 ea                	jne    f0106638 <spin_lock+0x79>
f010664e:	eb 25                	jmp    f0106675 <spin_lock+0xb6>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106650:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106657:	40                   	inc    %eax
f0106658:	83 f8 09             	cmp    $0x9,%eax
f010665b:	7e f3                	jle    f0106650 <spin_lock+0x91>
f010665d:	eb 16                	jmp    f0106675 <spin_lock+0xb6>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010665f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106664:	eb ea                	jmp    f0106650 <spin_lock+0x91>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106666:	8b 50 04             	mov    0x4(%eax),%edx
f0106669:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010666c:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010666e:	b8 01 00 00 00       	mov    $0x1,%eax
f0106673:	eb c3                	jmp    f0106638 <spin_lock+0x79>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106675:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106678:	c9                   	leave  
f0106679:	c3                   	ret    

f010667a <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010667a:	55                   	push   %ebp
f010667b:	89 e5                	mov    %esp,%ebp
f010667d:	57                   	push   %edi
f010667e:	56                   	push   %esi
f010667f:	53                   	push   %ebx
f0106680:	83 ec 4c             	sub    $0x4c,%esp
f0106683:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106686:	89 d8                	mov    %ebx,%eax
f0106688:	e8 db fe ff ff       	call   f0106568 <holding>
f010668d:	85 c0                	test   %eax,%eax
f010668f:	0f 85 c0 00 00 00    	jne    f0106755 <spin_unlock+0xdb>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106695:	83 ec 04             	sub    $0x4,%esp
f0106698:	6a 28                	push   $0x28
f010669a:	8d 43 0c             	lea    0xc(%ebx),%eax
f010669d:	50                   	push   %eax
f010669e:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01066a1:	50                   	push   %eax
f01066a2:	e8 7c f6 ff ff       	call   f0105d23 <memmove>
			
		cprintf("%u\n", lk->cpu->cpu_id);
f01066a7:	83 c4 08             	add    $0x8,%esp
f01066aa:	8b 43 08             	mov    0x8(%ebx),%eax
f01066ad:	0f b6 00             	movzbl (%eax),%eax
f01066b0:	50                   	push   %eax
f01066b1:	68 f8 6c 10 f0       	push   $0xf0106cf8
f01066b6:	e8 5a d6 ff ff       	call   f0103d15 <cprintf>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01066bb:	8b 43 08             	mov    0x8(%ebx),%eax
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
			
		cprintf("%u\n", lk->cpu->cpu_id);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01066be:	0f b6 30             	movzbl (%eax),%esi
f01066c1:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01066c4:	e8 3f fc ff ff       	call   f0106308 <cpunum>
f01066c9:	56                   	push   %esi
f01066ca:	53                   	push   %ebx
f01066cb:	50                   	push   %eax
f01066cc:	68 70 8a 10 f0       	push   $0xf0108a70
f01066d1:	e8 3f d6 ff ff       	call   f0103d15 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
f01066d6:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01066d9:	83 c4 20             	add    $0x20,%esp
f01066dc:	85 c0                	test   %eax,%eax
f01066de:	74 61                	je     f0106741 <spin_unlock+0xc7>
f01066e0:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f01066e3:	8d 7d cc             	lea    -0x34(%ebp),%edi
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01066e6:	8d 75 d0             	lea    -0x30(%ebp),%esi
f01066e9:	83 ec 08             	sub    $0x8,%esp
f01066ec:	56                   	push   %esi
f01066ed:	50                   	push   %eax
f01066ee:	e8 2e eb ff ff       	call   f0105221 <debuginfo_eip>
f01066f3:	83 c4 10             	add    $0x10,%esp
f01066f6:	85 c0                	test   %eax,%eax
f01066f8:	78 27                	js     f0106721 <spin_unlock+0xa7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01066fa:	8b 03                	mov    (%ebx),%eax
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01066fc:	83 ec 04             	sub    $0x4,%esp
f01066ff:	89 c2                	mov    %eax,%edx
f0106701:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106704:	52                   	push   %edx
f0106705:	ff 75 d8             	pushl  -0x28(%ebp)
f0106708:	ff 75 dc             	pushl  -0x24(%ebp)
f010670b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010670e:	ff 75 d0             	pushl  -0x30(%ebp)
f0106711:	50                   	push   %eax
f0106712:	68 b8 8a 10 f0       	push   $0xf0108ab8
f0106717:	e8 f9 d5 ff ff       	call   f0103d15 <cprintf>
f010671c:	83 c4 20             	add    $0x20,%esp
f010671f:	eb 12                	jmp    f0106733 <spin_unlock+0xb9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106721:	83 ec 08             	sub    $0x8,%esp
f0106724:	ff 33                	pushl  (%ebx)
f0106726:	68 cf 8a 10 f0       	push   $0xf0108acf
f010672b:	e8 e5 d5 ff ff       	call   f0103d15 <cprintf>
f0106730:	83 c4 10             	add    $0x10,%esp
			
		cprintf("%u\n", lk->cpu->cpu_id);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
f0106733:	39 fb                	cmp    %edi,%ebx
f0106735:	74 0a                	je     f0106741 <spin_unlock+0xc7>
f0106737:	8b 43 04             	mov    0x4(%ebx),%eax
f010673a:	83 c3 04             	add    $0x4,%ebx
f010673d:	85 c0                	test   %eax,%eax
f010673f:	75 a8                	jne    f01066e9 <spin_unlock+0x6f>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106741:	83 ec 04             	sub    $0x4,%esp
f0106744:	68 d7 8a 10 f0       	push   $0xf0108ad7
f0106749:	6a 6a                	push   $0x6a
f010674b:	68 a8 8a 10 f0       	push   $0xf0108aa8
f0106750:	e8 13 99 ff ff       	call   f0100068 <_panic>
	}
	lk->pcs[0] = 0;
f0106755:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f010675c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106763:	b8 00 00 00 00       	mov    $0x0,%eax
f0106768:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f010676b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010676e:	5b                   	pop    %ebx
f010676f:	5e                   	pop    %esi
f0106770:	5f                   	pop    %edi
f0106771:	c9                   	leave  
f0106772:	c3                   	ret    
	...

f0106774 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0106774:	55                   	push   %ebp
f0106775:	89 e5                	mov    %esp,%ebp
f0106777:	57                   	push   %edi
f0106778:	56                   	push   %esi
f0106779:	83 ec 10             	sub    $0x10,%esp
f010677c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010677f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0106782:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0106785:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0106788:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010678b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010678e:	85 c0                	test   %eax,%eax
f0106790:	75 2e                	jne    f01067c0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0106792:	39 f1                	cmp    %esi,%ecx
f0106794:	77 5a                	ja     f01067f0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0106796:	85 c9                	test   %ecx,%ecx
f0106798:	75 0b                	jne    f01067a5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f010679a:	b8 01 00 00 00       	mov    $0x1,%eax
f010679f:	31 d2                	xor    %edx,%edx
f01067a1:	f7 f1                	div    %ecx
f01067a3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01067a5:	31 d2                	xor    %edx,%edx
f01067a7:	89 f0                	mov    %esi,%eax
f01067a9:	f7 f1                	div    %ecx
f01067ab:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01067ad:	89 f8                	mov    %edi,%eax
f01067af:	f7 f1                	div    %ecx
f01067b1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01067b3:	89 f8                	mov    %edi,%eax
f01067b5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01067b7:	83 c4 10             	add    $0x10,%esp
f01067ba:	5e                   	pop    %esi
f01067bb:	5f                   	pop    %edi
f01067bc:	c9                   	leave  
f01067bd:	c3                   	ret    
f01067be:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01067c0:	39 f0                	cmp    %esi,%eax
f01067c2:	77 1c                	ja     f01067e0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01067c4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f01067c7:	83 f7 1f             	xor    $0x1f,%edi
f01067ca:	75 3c                	jne    f0106808 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01067cc:	39 f0                	cmp    %esi,%eax
f01067ce:	0f 82 90 00 00 00    	jb     f0106864 <__udivdi3+0xf0>
f01067d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01067d7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f01067da:	0f 86 84 00 00 00    	jbe    f0106864 <__udivdi3+0xf0>
f01067e0:	31 f6                	xor    %esi,%esi
f01067e2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01067e4:	89 f8                	mov    %edi,%eax
f01067e6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01067e8:	83 c4 10             	add    $0x10,%esp
f01067eb:	5e                   	pop    %esi
f01067ec:	5f                   	pop    %edi
f01067ed:	c9                   	leave  
f01067ee:	c3                   	ret    
f01067ef:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01067f0:	89 f2                	mov    %esi,%edx
f01067f2:	89 f8                	mov    %edi,%eax
f01067f4:	f7 f1                	div    %ecx
f01067f6:	89 c7                	mov    %eax,%edi
f01067f8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01067fa:	89 f8                	mov    %edi,%eax
f01067fc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01067fe:	83 c4 10             	add    $0x10,%esp
f0106801:	5e                   	pop    %esi
f0106802:	5f                   	pop    %edi
f0106803:	c9                   	leave  
f0106804:	c3                   	ret    
f0106805:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106808:	89 f9                	mov    %edi,%ecx
f010680a:	d3 e0                	shl    %cl,%eax
f010680c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010680f:	b8 20 00 00 00       	mov    $0x20,%eax
f0106814:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0106816:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106819:	88 c1                	mov    %al,%cl
f010681b:	d3 ea                	shr    %cl,%edx
f010681d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0106820:	09 ca                	or     %ecx,%edx
f0106822:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0106825:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106828:	89 f9                	mov    %edi,%ecx
f010682a:	d3 e2                	shl    %cl,%edx
f010682c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f010682f:	89 f2                	mov    %esi,%edx
f0106831:	88 c1                	mov    %al,%cl
f0106833:	d3 ea                	shr    %cl,%edx
f0106835:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0106838:	89 f2                	mov    %esi,%edx
f010683a:	89 f9                	mov    %edi,%ecx
f010683c:	d3 e2                	shl    %cl,%edx
f010683e:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0106841:	88 c1                	mov    %al,%cl
f0106843:	d3 ee                	shr    %cl,%esi
f0106845:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106847:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010684a:	89 f0                	mov    %esi,%eax
f010684c:	89 ca                	mov    %ecx,%edx
f010684e:	f7 75 ec             	divl   -0x14(%ebp)
f0106851:	89 d1                	mov    %edx,%ecx
f0106853:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0106855:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106858:	39 d1                	cmp    %edx,%ecx
f010685a:	72 28                	jb     f0106884 <__udivdi3+0x110>
f010685c:	74 1a                	je     f0106878 <__udivdi3+0x104>
f010685e:	89 f7                	mov    %esi,%edi
f0106860:	31 f6                	xor    %esi,%esi
f0106862:	eb 80                	jmp    f01067e4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106864:	31 f6                	xor    %esi,%esi
f0106866:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010686b:	89 f8                	mov    %edi,%eax
f010686d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010686f:	83 c4 10             	add    $0x10,%esp
f0106872:	5e                   	pop    %esi
f0106873:	5f                   	pop    %edi
f0106874:	c9                   	leave  
f0106875:	c3                   	ret    
f0106876:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0106878:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010687b:	89 f9                	mov    %edi,%ecx
f010687d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010687f:	39 c2                	cmp    %eax,%edx
f0106881:	73 db                	jae    f010685e <__udivdi3+0xea>
f0106883:	90                   	nop
		{
		  q0--;
f0106884:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106887:	31 f6                	xor    %esi,%esi
f0106889:	e9 56 ff ff ff       	jmp    f01067e4 <__udivdi3+0x70>
	...

f0106890 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0106890:	55                   	push   %ebp
f0106891:	89 e5                	mov    %esp,%ebp
f0106893:	57                   	push   %edi
f0106894:	56                   	push   %esi
f0106895:	83 ec 20             	sub    $0x20,%esp
f0106898:	8b 45 08             	mov    0x8(%ebp),%eax
f010689b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010689e:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01068a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f01068a4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01068a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f01068aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f01068ad:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01068af:	85 ff                	test   %edi,%edi
f01068b1:	75 15                	jne    f01068c8 <__umoddi3+0x38>
    {
      if (d0 > n1)
f01068b3:	39 f1                	cmp    %esi,%ecx
f01068b5:	0f 86 99 00 00 00    	jbe    f0106954 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01068bb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f01068bd:	89 d0                	mov    %edx,%eax
f01068bf:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01068c1:	83 c4 20             	add    $0x20,%esp
f01068c4:	5e                   	pop    %esi
f01068c5:	5f                   	pop    %edi
f01068c6:	c9                   	leave  
f01068c7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01068c8:	39 f7                	cmp    %esi,%edi
f01068ca:	0f 87 a4 00 00 00    	ja     f0106974 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01068d0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f01068d3:	83 f0 1f             	xor    $0x1f,%eax
f01068d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01068d9:	0f 84 a1 00 00 00    	je     f0106980 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01068df:	89 f8                	mov    %edi,%eax
f01068e1:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01068e4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01068e6:	bf 20 00 00 00       	mov    $0x20,%edi
f01068eb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f01068ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01068f1:	89 f9                	mov    %edi,%ecx
f01068f3:	d3 ea                	shr    %cl,%edx
f01068f5:	09 c2                	or     %eax,%edx
f01068f7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f01068fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01068fd:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0106900:	d3 e0                	shl    %cl,%eax
f0106902:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106905:	89 f2                	mov    %esi,%edx
f0106907:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0106909:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010690c:	d3 e0                	shl    %cl,%eax
f010690e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106911:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106914:	89 f9                	mov    %edi,%ecx
f0106916:	d3 e8                	shr    %cl,%eax
f0106918:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f010691a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f010691c:	89 f2                	mov    %esi,%edx
f010691e:	f7 75 f0             	divl   -0x10(%ebp)
f0106921:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0106923:	f7 65 f4             	mull   -0xc(%ebp)
f0106926:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0106929:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010692b:	39 d6                	cmp    %edx,%esi
f010692d:	72 71                	jb     f01069a0 <__umoddi3+0x110>
f010692f:	74 7f                	je     f01069b0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0106931:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106934:	29 c8                	sub    %ecx,%eax
f0106936:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0106938:	8a 4d ec             	mov    -0x14(%ebp),%cl
f010693b:	d3 e8                	shr    %cl,%eax
f010693d:	89 f2                	mov    %esi,%edx
f010693f:	89 f9                	mov    %edi,%ecx
f0106941:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0106943:	09 d0                	or     %edx,%eax
f0106945:	89 f2                	mov    %esi,%edx
f0106947:	8a 4d ec             	mov    -0x14(%ebp),%cl
f010694a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f010694c:	83 c4 20             	add    $0x20,%esp
f010694f:	5e                   	pop    %esi
f0106950:	5f                   	pop    %edi
f0106951:	c9                   	leave  
f0106952:	c3                   	ret    
f0106953:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0106954:	85 c9                	test   %ecx,%ecx
f0106956:	75 0b                	jne    f0106963 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106958:	b8 01 00 00 00       	mov    $0x1,%eax
f010695d:	31 d2                	xor    %edx,%edx
f010695f:	f7 f1                	div    %ecx
f0106961:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0106963:	89 f0                	mov    %esi,%eax
f0106965:	31 d2                	xor    %edx,%edx
f0106967:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106969:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010696c:	f7 f1                	div    %ecx
f010696e:	e9 4a ff ff ff       	jmp    f01068bd <__umoddi3+0x2d>
f0106973:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0106974:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106976:	83 c4 20             	add    $0x20,%esp
f0106979:	5e                   	pop    %esi
f010697a:	5f                   	pop    %edi
f010697b:	c9                   	leave  
f010697c:	c3                   	ret    
f010697d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106980:	39 f7                	cmp    %esi,%edi
f0106982:	72 05                	jb     f0106989 <__umoddi3+0xf9>
f0106984:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0106987:	77 0c                	ja     f0106995 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106989:	89 f2                	mov    %esi,%edx
f010698b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010698e:	29 c8                	sub    %ecx,%eax
f0106990:	19 fa                	sbb    %edi,%edx
f0106992:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0106995:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106998:	83 c4 20             	add    $0x20,%esp
f010699b:	5e                   	pop    %esi
f010699c:	5f                   	pop    %edi
f010699d:	c9                   	leave  
f010699e:	c3                   	ret    
f010699f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01069a0:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01069a3:	89 c1                	mov    %eax,%ecx
f01069a5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f01069a8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f01069ab:	eb 84                	jmp    f0106931 <__umoddi3+0xa1>
f01069ad:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01069b0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f01069b3:	72 eb                	jb     f01069a0 <__umoddi3+0x110>
f01069b5:	89 f2                	mov    %esi,%edx
f01069b7:	e9 75 ff ff ff       	jmp    f0106931 <__umoddi3+0xa1>
