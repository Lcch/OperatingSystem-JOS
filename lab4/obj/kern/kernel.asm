
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
f0100039:	e8 07 01 00 00       	call   f0100145 <i386_init>

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
f010005d:	b8 28 84 12 f0       	mov    $0xf0128428,%eax
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
f0100070:	83 3d 80 5e 2e f0 00 	cmpl   $0x0,0xf02e5e80
f0100077:	75 3a                	jne    f01000b3 <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100079:	89 35 80 5e 2e f0    	mov    %esi,0xf02e5e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010007f:	fa                   	cli    
f0100080:	fc                   	cld    

	va_start(ap, fmt);
f0100081:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f0100084:	e8 cb 60 00 00       	call   f0106154 <cpunum>
f0100089:	ff 75 0c             	pushl  0xc(%ebp)
f010008c:	ff 75 08             	pushl  0x8(%ebp)
f010008f:	50                   	push   %eax
f0100090:	68 20 68 10 f0       	push   $0xf0106820
f0100095:	e8 c3 3c 00 00       	call   f0103d5d <cprintf>
	vcprintf(fmt, ap);
f010009a:	83 c4 08             	add    $0x8,%esp
f010009d:	53                   	push   %ebx
f010009e:	56                   	push   %esi
f010009f:	e8 93 3c 00 00       	call   f0103d37 <vcprintf>
	cprintf("\n");
f01000a4:	c7 04 24 8f 6b 10 f0 	movl   $0xf0106b8f,(%esp)
f01000ab:	e8 ad 3c 00 00       	call   f0103d5d <cprintf>
	va_end(ap);
f01000b0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000b3:	83 ec 0c             	sub    $0xc,%esp
f01000b6:	6a 00                	push   $0x0
f01000b8:	e8 74 0f 00 00       	call   f0101031 <monitor>
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
f01000c8:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000d2:	77 15                	ja     f01000e9 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000d4:	50                   	push   %eax
f01000d5:	68 44 68 10 f0       	push   $0xf0106844
f01000da:	68 80 00 00 00       	push   $0x80
f01000df:	68 8b 68 10 f0       	push   $0xf010688b
f01000e4:	e8 7f ff ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000e9:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01000ee:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000f1:	e8 5e 60 00 00       	call   f0106154 <cpunum>
f01000f6:	83 ec 08             	sub    $0x8,%esp
f01000f9:	50                   	push   %eax
f01000fa:	68 97 68 10 f0       	push   $0xf0106897
f01000ff:	e8 59 3c 00 00       	call   f0103d5d <cprintf>

	lapic_init();
f0100104:	e8 66 60 00 00       	call   f010616f <lapic_init>
	env_init_percpu();
f0100109:	e8 c6 33 00 00       	call   f01034d4 <env_init_percpu>
	trap_init_percpu();
f010010e:	e8 61 3c 00 00       	call   f0103d74 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100113:	e8 3c 60 00 00       	call   f0106154 <cpunum>
f0100118:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010011f:	29 c2                	sub    %eax,%edx
f0100121:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100124:	8d 14 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010012b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100130:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100134:	c7 04 24 60 84 12 f0 	movl   $0xf0128460,(%esp)
f010013b:	e8 cb 62 00 00       	call   f010640b <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100140:	e8 c6 46 00 00       	call   f010480b <sched_yield>

f0100145 <i386_init>:
	wrmsr(IA32_SYSENTER_EIP, (uint32_t)(sysenter_handler), 0);		// entry of sysenter
}

void
i386_init(void)
{
f0100145:	55                   	push   %ebp
f0100146:	89 e5                	mov    %esp,%ebp
f0100148:	53                   	push   %ebx
f0100149:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010014c:	b8 08 70 32 f0       	mov    $0xf0327008,%eax
f0100151:	2d 98 4b 2e f0       	sub    $0xf02e4b98,%eax
f0100156:	50                   	push   %eax
f0100157:	6a 00                	push   $0x0
f0100159:	68 98 4b 2e f0       	push   $0xf02e4b98
f010015e:	e8 c2 59 00 00       	call   f0105b25 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100163:	e8 3b 05 00 00       	call   f01006a3 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100168:	83 c4 08             	add    $0x8,%esp
f010016b:	68 ac 1a 00 00       	push   $0x1aac
f0100170:	68 ad 68 10 f0       	push   $0xf01068ad
f0100175:	e8 e3 3b 00 00       	call   f0103d5d <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f010017a:	e8 aa 17 00 00       	call   f0101929 <mem_init>

	// MSRs init:
	msrs_init();
f010017f:	e8 bc fe ff ff       	call   f0100040 <msrs_init>

    // Lab 3 user environment initialization functions
	env_init();
f0100184:	e8 75 33 00 00       	call   f01034fe <env_init>
    trap_init();
f0100189:	e8 eb 3c 00 00       	call   f0103e79 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010018e:	e8 d7 5c 00 00       	call   f0105e6a <mp_init>
	lapic_init();
f0100193:	e8 d7 5f 00 00       	call   f010616f <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100198:	e8 21 3b 00 00       	call   f0103cbe <pic_init>
f010019d:	c7 04 24 60 84 12 f0 	movl   $0xf0128460,(%esp)
f01001a4:	e8 62 62 00 00       	call   f010640b <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001a9:	83 c4 10             	add    $0x10,%esp
f01001ac:	83 3d 88 5e 2e f0 07 	cmpl   $0x7,0xf02e5e88
f01001b3:	77 16                	ja     f01001cb <i386_init+0x86>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001b5:	68 00 70 00 00       	push   $0x7000
f01001ba:	68 68 68 10 f0       	push   $0xf0106868
f01001bf:	6a 69                	push   $0x69
f01001c1:	68 8b 68 10 f0       	push   $0xf010688b
f01001c6:	e8 9d fe ff ff       	call   f0100068 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001cb:	83 ec 04             	sub    $0x4,%esp
f01001ce:	b8 a6 5d 10 f0       	mov    $0xf0105da6,%eax
f01001d3:	2d 2c 5d 10 f0       	sub    $0xf0105d2c,%eax
f01001d8:	50                   	push   %eax
f01001d9:	68 2c 5d 10 f0       	push   $0xf0105d2c
f01001de:	68 00 70 00 f0       	push   $0xf0007000
f01001e3:	e8 87 59 00 00       	call   f0105b6f <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001e8:	a1 c4 63 2e f0       	mov    0xf02e63c4,%eax
f01001ed:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001f4:	29 c2                	sub    %eax,%edx
f01001f6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001f9:	8d 04 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%eax
f0100200:	83 c4 10             	add    $0x10,%esp
f0100203:	3d 20 60 2e f0       	cmp    $0xf02e6020,%eax
f0100208:	0f 86 95 00 00 00    	jbe    f01002a3 <i386_init+0x15e>
f010020e:	bb 20 60 2e f0       	mov    $0xf02e6020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100213:	e8 3c 5f 00 00       	call   f0106154 <cpunum>
f0100218:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010021f:	29 c2                	sub    %eax,%edx
f0100221:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100224:	8d 04 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%eax
f010022b:	39 c3                	cmp    %eax,%ebx
f010022d:	74 51                	je     f0100280 <i386_init+0x13b>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010022f:	89 d8                	mov    %ebx,%eax
f0100231:	2d 20 60 2e f0       	sub    $0xf02e6020,%eax
f0100236:	c1 f8 02             	sar    $0x2,%eax
f0100239:	8d 14 80             	lea    (%eax,%eax,4),%edx
f010023c:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f010023f:	89 d1                	mov    %edx,%ecx
f0100241:	c1 e1 05             	shl    $0x5,%ecx
f0100244:	29 d1                	sub    %edx,%ecx
f0100246:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100249:	89 d1                	mov    %edx,%ecx
f010024b:	c1 e1 0e             	shl    $0xe,%ecx
f010024e:	29 d1                	sub    %edx,%ecx
f0100250:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100253:	8d 44 90 01          	lea    0x1(%eax,%edx,4),%eax
f0100257:	c1 e0 0f             	shl    $0xf,%eax
f010025a:	05 00 70 2e f0       	add    $0xf02e7000,%eax
f010025f:	a3 84 5e 2e f0       	mov    %eax,0xf02e5e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100264:	83 ec 08             	sub    $0x8,%esp
f0100267:	68 00 70 00 00       	push   $0x7000
f010026c:	0f b6 03             	movzbl (%ebx),%eax
f010026f:	50                   	push   %eax
f0100270:	e8 56 60 00 00       	call   f01062cb <lapic_startap>
f0100275:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100278:	8b 43 04             	mov    0x4(%ebx),%eax
f010027b:	83 f8 01             	cmp    $0x1,%eax
f010027e:	75 f8                	jne    f0100278 <i386_init+0x133>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100280:	83 c3 74             	add    $0x74,%ebx
f0100283:	a1 c4 63 2e f0       	mov    0xf02e63c4,%eax
f0100288:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010028f:	29 c2                	sub    %eax,%edx
f0100291:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100294:	8d 04 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%eax
f010029b:	39 c3                	cmp    %eax,%ebx
f010029d:	0f 82 70 ff ff ff    	jb     f0100213 <i386_init+0xce>
	// ENV_CREATE(user_faultdie, ENV_TYPE_USER);
	// ENV_CREATE(user_faultallocbad, ENV_TYPE_USER);
	// ENV_CREATE(user_faultregs, ENV_TYPE_USER);
	// ENV_CREATE(user_forktree, ENV_TYPE_USER);
	// ENV_CREATE(user_spin, ENV_TYPE_USER);
	ENV_CREATE(user_pingpong, ENV_TYPE_USER);
f01002a3:	83 ec 04             	sub    $0x4,%esp
f01002a6:	6a 00                	push   $0x0
f01002a8:	68 b5 fa 00 00       	push   $0xfab5
f01002ad:	68 4c 5b 2b f0       	push   $0xf02b5b4c
f01002b2:	e8 72 34 00 00       	call   f0103729 <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01002b7:	e8 4f 45 00 00       	call   f010480b <sched_yield>

f01002bc <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002bc:	55                   	push   %ebp
f01002bd:	89 e5                	mov    %esp,%ebp
f01002bf:	53                   	push   %ebx
f01002c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01002c3:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002c6:	ff 75 0c             	pushl  0xc(%ebp)
f01002c9:	ff 75 08             	pushl  0x8(%ebp)
f01002cc:	68 c8 68 10 f0       	push   $0xf01068c8
f01002d1:	e8 87 3a 00 00       	call   f0103d5d <cprintf>
	vcprintf(fmt, ap);
f01002d6:	83 c4 08             	add    $0x8,%esp
f01002d9:	53                   	push   %ebx
f01002da:	ff 75 10             	pushl  0x10(%ebp)
f01002dd:	e8 55 3a 00 00       	call   f0103d37 <vcprintf>
	cprintf("\n");
f01002e2:	c7 04 24 8f 6b 10 f0 	movl   $0xf0106b8f,(%esp)
f01002e9:	e8 6f 3a 00 00       	call   f0103d5d <cprintf>
	va_end(ap);
f01002ee:	83 c4 10             	add    $0x10,%esp
}
f01002f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f4:	c9                   	leave  
f01002f5:	c3                   	ret    
	...

f01002f8 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002f8:	55                   	push   %ebp
f01002f9:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002fb:	ba 84 00 00 00       	mov    $0x84,%edx
f0100300:	ec                   	in     (%dx),%al
f0100301:	ec                   	in     (%dx),%al
f0100302:	ec                   	in     (%dx),%al
f0100303:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100304:	c9                   	leave  
f0100305:	c3                   	ret    

f0100306 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100306:	55                   	push   %ebp
f0100307:	89 e5                	mov    %esp,%ebp
f0100309:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010030e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010030f:	a8 01                	test   $0x1,%al
f0100311:	74 08                	je     f010031b <serial_proc_data+0x15>
f0100313:	b2 f8                	mov    $0xf8,%dl
f0100315:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100316:	0f b6 c0             	movzbl %al,%eax
f0100319:	eb 05                	jmp    f0100320 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010031b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100320:	c9                   	leave  
f0100321:	c3                   	ret    

f0100322 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100322:	55                   	push   %ebp
f0100323:	89 e5                	mov    %esp,%ebp
f0100325:	53                   	push   %ebx
f0100326:	83 ec 04             	sub    $0x4,%esp
f0100329:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010032b:	eb 29                	jmp    f0100356 <cons_intr+0x34>
		if (c == 0)
f010032d:	85 c0                	test   %eax,%eax
f010032f:	74 25                	je     f0100356 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100331:	8b 15 24 52 2e f0    	mov    0xf02e5224,%edx
f0100337:	88 82 20 50 2e f0    	mov    %al,-0xfd1afe0(%edx)
f010033d:	8d 42 01             	lea    0x1(%edx),%eax
f0100340:	a3 24 52 2e f0       	mov    %eax,0xf02e5224
		if (cons.wpos == CONSBUFSIZE)
f0100345:	3d 00 02 00 00       	cmp    $0x200,%eax
f010034a:	75 0a                	jne    f0100356 <cons_intr+0x34>
			cons.wpos = 0;
f010034c:	c7 05 24 52 2e f0 00 	movl   $0x0,0xf02e5224
f0100353:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100356:	ff d3                	call   *%ebx
f0100358:	83 f8 ff             	cmp    $0xffffffff,%eax
f010035b:	75 d0                	jne    f010032d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010035d:	83 c4 04             	add    $0x4,%esp
f0100360:	5b                   	pop    %ebx
f0100361:	c9                   	leave  
f0100362:	c3                   	ret    

f0100363 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100363:	55                   	push   %ebp
f0100364:	89 e5                	mov    %esp,%ebp
f0100366:	57                   	push   %edi
f0100367:	56                   	push   %esi
f0100368:	53                   	push   %ebx
f0100369:	83 ec 0c             	sub    $0xc,%esp
f010036c:	89 c6                	mov    %eax,%esi
f010036e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100373:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100374:	a8 20                	test   $0x20,%al
f0100376:	75 19                	jne    f0100391 <cons_putc+0x2e>
f0100378:	bb 00 32 00 00       	mov    $0x3200,%ebx
f010037d:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100382:	e8 71 ff ff ff       	call   f01002f8 <delay>
f0100387:	89 fa                	mov    %edi,%edx
f0100389:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010038a:	a8 20                	test   $0x20,%al
f010038c:	75 03                	jne    f0100391 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010038e:	4b                   	dec    %ebx
f010038f:	75 f1                	jne    f0100382 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100391:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100393:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100398:	89 f0                	mov    %esi,%eax
f010039a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010039b:	b2 79                	mov    $0x79,%dl
f010039d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010039e:	84 c0                	test   %al,%al
f01003a0:	78 1d                	js     f01003bf <cons_putc+0x5c>
f01003a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f01003a7:	e8 4c ff ff ff       	call   f01002f8 <delay>
f01003ac:	ba 79 03 00 00       	mov    $0x379,%edx
f01003b1:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003b2:	84 c0                	test   %al,%al
f01003b4:	78 09                	js     f01003bf <cons_putc+0x5c>
f01003b6:	43                   	inc    %ebx
f01003b7:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01003bd:	75 e8                	jne    f01003a7 <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003bf:	ba 78 03 00 00       	mov    $0x378,%edx
f01003c4:	89 f8                	mov    %edi,%eax
f01003c6:	ee                   	out    %al,(%dx)
f01003c7:	b2 7a                	mov    $0x7a,%dl
f01003c9:	b0 0d                	mov    $0xd,%al
f01003cb:	ee                   	out    %al,(%dx)
f01003cc:	b0 08                	mov    $0x8,%al
f01003ce:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
    // set user_setcolor
    c |= (user_setcolor << 8);
f01003cf:	a1 00 50 2e f0       	mov    0xf02e5000,%eax
f01003d4:	c1 e0 08             	shl    $0x8,%eax
f01003d7:	09 c6                	or     %eax,%esi

	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003d9:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f01003df:	75 06                	jne    f01003e7 <cons_putc+0x84>
		c |= 0x0700;
f01003e1:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f01003e7:	89 f0                	mov    %esi,%eax
f01003e9:	25 ff 00 00 00       	and    $0xff,%eax
f01003ee:	83 f8 09             	cmp    $0x9,%eax
f01003f1:	74 78                	je     f010046b <cons_putc+0x108>
f01003f3:	83 f8 09             	cmp    $0x9,%eax
f01003f6:	7f 0b                	jg     f0100403 <cons_putc+0xa0>
f01003f8:	83 f8 08             	cmp    $0x8,%eax
f01003fb:	0f 85 9e 00 00 00    	jne    f010049f <cons_putc+0x13c>
f0100401:	eb 10                	jmp    f0100413 <cons_putc+0xb0>
f0100403:	83 f8 0a             	cmp    $0xa,%eax
f0100406:	74 39                	je     f0100441 <cons_putc+0xde>
f0100408:	83 f8 0d             	cmp    $0xd,%eax
f010040b:	0f 85 8e 00 00 00    	jne    f010049f <cons_putc+0x13c>
f0100411:	eb 36                	jmp    f0100449 <cons_putc+0xe6>
	case '\b':
		if (crt_pos > 0) {
f0100413:	66 a1 04 50 2e f0    	mov    0xf02e5004,%ax
f0100419:	66 85 c0             	test   %ax,%ax
f010041c:	0f 84 e0 00 00 00    	je     f0100502 <cons_putc+0x19f>
			crt_pos--;
f0100422:	48                   	dec    %eax
f0100423:	66 a3 04 50 2e f0    	mov    %ax,0xf02e5004
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100429:	0f b7 c0             	movzwl %ax,%eax
f010042c:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100432:	83 ce 20             	or     $0x20,%esi
f0100435:	8b 15 08 50 2e f0    	mov    0xf02e5008,%edx
f010043b:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f010043f:	eb 78                	jmp    f01004b9 <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100441:	66 83 05 04 50 2e f0 	addw   $0x50,0xf02e5004
f0100448:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100449:	66 8b 0d 04 50 2e f0 	mov    0xf02e5004,%cx
f0100450:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100455:	89 c8                	mov    %ecx,%eax
f0100457:	ba 00 00 00 00       	mov    $0x0,%edx
f010045c:	66 f7 f3             	div    %bx
f010045f:	66 29 d1             	sub    %dx,%cx
f0100462:	66 89 0d 04 50 2e f0 	mov    %cx,0xf02e5004
f0100469:	eb 4e                	jmp    f01004b9 <cons_putc+0x156>
		break;
	case '\t':
		cons_putc(' ');
f010046b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100470:	e8 ee fe ff ff       	call   f0100363 <cons_putc>
		cons_putc(' ');
f0100475:	b8 20 00 00 00       	mov    $0x20,%eax
f010047a:	e8 e4 fe ff ff       	call   f0100363 <cons_putc>
		cons_putc(' ');
f010047f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100484:	e8 da fe ff ff       	call   f0100363 <cons_putc>
		cons_putc(' ');
f0100489:	b8 20 00 00 00       	mov    $0x20,%eax
f010048e:	e8 d0 fe ff ff       	call   f0100363 <cons_putc>
		cons_putc(' ');
f0100493:	b8 20 00 00 00       	mov    $0x20,%eax
f0100498:	e8 c6 fe ff ff       	call   f0100363 <cons_putc>
f010049d:	eb 1a                	jmp    f01004b9 <cons_putc+0x156>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010049f:	66 a1 04 50 2e f0    	mov    0xf02e5004,%ax
f01004a5:	0f b7 c8             	movzwl %ax,%ecx
f01004a8:	8b 15 08 50 2e f0    	mov    0xf02e5008,%edx
f01004ae:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01004b2:	40                   	inc    %eax
f01004b3:	66 a3 04 50 2e f0    	mov    %ax,0xf02e5004
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f01004b9:	66 81 3d 04 50 2e f0 	cmpw   $0x7cf,0xf02e5004
f01004c0:	cf 07 
f01004c2:	76 3e                	jbe    f0100502 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004c4:	a1 08 50 2e f0       	mov    0xf02e5008,%eax
f01004c9:	83 ec 04             	sub    $0x4,%esp
f01004cc:	68 00 0f 00 00       	push   $0xf00
f01004d1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004d7:	52                   	push   %edx
f01004d8:	50                   	push   %eax
f01004d9:	e8 91 56 00 00       	call   f0105b6f <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004de:	8b 15 08 50 2e f0    	mov    0xf02e5008,%edx
f01004e4:	83 c4 10             	add    $0x10,%esp
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004e7:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004ec:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004f2:	40                   	inc    %eax
f01004f3:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004f8:	75 f2                	jne    f01004ec <cons_putc+0x189>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004fa:	66 83 2d 04 50 2e f0 	subw   $0x50,0xf02e5004
f0100501:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100502:	8b 0d 0c 50 2e f0    	mov    0xf02e500c,%ecx
f0100508:	b0 0e                	mov    $0xe,%al
f010050a:	89 ca                	mov    %ecx,%edx
f010050c:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010050d:	66 8b 35 04 50 2e f0 	mov    0xf02e5004,%si
f0100514:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100517:	89 f0                	mov    %esi,%eax
f0100519:	66 c1 e8 08          	shr    $0x8,%ax
f010051d:	89 da                	mov    %ebx,%edx
f010051f:	ee                   	out    %al,(%dx)
f0100520:	b0 0f                	mov    $0xf,%al
f0100522:	89 ca                	mov    %ecx,%edx
f0100524:	ee                   	out    %al,(%dx)
f0100525:	89 f0                	mov    %esi,%eax
f0100527:	89 da                	mov    %ebx,%edx
f0100529:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010052a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010052d:	5b                   	pop    %ebx
f010052e:	5e                   	pop    %esi
f010052f:	5f                   	pop    %edi
f0100530:	c9                   	leave  
f0100531:	c3                   	ret    

f0100532 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100532:	55                   	push   %ebp
f0100533:	89 e5                	mov    %esp,%ebp
f0100535:	53                   	push   %ebx
f0100536:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100539:	ba 64 00 00 00       	mov    $0x64,%edx
f010053e:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010053f:	a8 01                	test   $0x1,%al
f0100541:	0f 84 dc 00 00 00    	je     f0100623 <kbd_proc_data+0xf1>
f0100547:	b2 60                	mov    $0x60,%dl
f0100549:	ec                   	in     (%dx),%al
f010054a:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010054c:	3c e0                	cmp    $0xe0,%al
f010054e:	75 11                	jne    f0100561 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100550:	83 0d 28 52 2e f0 40 	orl    $0x40,0xf02e5228
		return 0;
f0100557:	bb 00 00 00 00       	mov    $0x0,%ebx
f010055c:	e9 c7 00 00 00       	jmp    f0100628 <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f0100561:	84 c0                	test   %al,%al
f0100563:	79 33                	jns    f0100598 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100565:	8b 0d 28 52 2e f0    	mov    0xf02e5228,%ecx
f010056b:	f6 c1 40             	test   $0x40,%cl
f010056e:	75 05                	jne    f0100575 <kbd_proc_data+0x43>
f0100570:	88 c2                	mov    %al,%dl
f0100572:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100575:	0f b6 d2             	movzbl %dl,%edx
f0100578:	8a 82 20 69 10 f0    	mov    -0xfef96e0(%edx),%al
f010057e:	83 c8 40             	or     $0x40,%eax
f0100581:	0f b6 c0             	movzbl %al,%eax
f0100584:	f7 d0                	not    %eax
f0100586:	21 c1                	and    %eax,%ecx
f0100588:	89 0d 28 52 2e f0    	mov    %ecx,0xf02e5228
		return 0;
f010058e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100593:	e9 90 00 00 00       	jmp    f0100628 <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f0100598:	8b 0d 28 52 2e f0    	mov    0xf02e5228,%ecx
f010059e:	f6 c1 40             	test   $0x40,%cl
f01005a1:	74 0e                	je     f01005b1 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01005a3:	88 c2                	mov    %al,%dl
f01005a5:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01005a8:	83 e1 bf             	and    $0xffffffbf,%ecx
f01005ab:	89 0d 28 52 2e f0    	mov    %ecx,0xf02e5228
	}

	shift |= shiftcode[data];
f01005b1:	0f b6 d2             	movzbl %dl,%edx
f01005b4:	0f b6 82 20 69 10 f0 	movzbl -0xfef96e0(%edx),%eax
f01005bb:	0b 05 28 52 2e f0    	or     0xf02e5228,%eax
	shift ^= togglecode[data];
f01005c1:	0f b6 8a 20 6a 10 f0 	movzbl -0xfef95e0(%edx),%ecx
f01005c8:	31 c8                	xor    %ecx,%eax
f01005ca:	a3 28 52 2e f0       	mov    %eax,0xf02e5228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005cf:	89 c1                	mov    %eax,%ecx
f01005d1:	83 e1 03             	and    $0x3,%ecx
f01005d4:	8b 0c 8d 20 6b 10 f0 	mov    -0xfef94e0(,%ecx,4),%ecx
f01005db:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005df:	a8 08                	test   $0x8,%al
f01005e1:	74 18                	je     f01005fb <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f01005e3:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005e6:	83 fa 19             	cmp    $0x19,%edx
f01005e9:	77 05                	ja     f01005f0 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f01005eb:	83 eb 20             	sub    $0x20,%ebx
f01005ee:	eb 0b                	jmp    f01005fb <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f01005f0:	8d 53 bf             	lea    -0x41(%ebx),%edx
f01005f3:	83 fa 19             	cmp    $0x19,%edx
f01005f6:	77 03                	ja     f01005fb <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f01005f8:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005fb:	f7 d0                	not    %eax
f01005fd:	a8 06                	test   $0x6,%al
f01005ff:	75 27                	jne    f0100628 <kbd_proc_data+0xf6>
f0100601:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100607:	75 1f                	jne    f0100628 <kbd_proc_data+0xf6>
		cprintf("Rebooting!\n");
f0100609:	83 ec 0c             	sub    $0xc,%esp
f010060c:	68 e2 68 10 f0       	push   $0xf01068e2
f0100611:	e8 47 37 00 00       	call   f0103d5d <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100616:	ba 92 00 00 00       	mov    $0x92,%edx
f010061b:	b0 03                	mov    $0x3,%al
f010061d:	ee                   	out    %al,(%dx)
f010061e:	83 c4 10             	add    $0x10,%esp
f0100621:	eb 05                	jmp    f0100628 <kbd_proc_data+0xf6>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100623:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100628:	89 d8                	mov    %ebx,%eax
f010062a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010062d:	c9                   	leave  
f010062e:	c3                   	ret    

f010062f <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010062f:	55                   	push   %ebp
f0100630:	89 e5                	mov    %esp,%ebp
f0100632:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100635:	80 3d 10 50 2e f0 00 	cmpb   $0x0,0xf02e5010
f010063c:	74 0a                	je     f0100648 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010063e:	b8 06 03 10 f0       	mov    $0xf0100306,%eax
f0100643:	e8 da fc ff ff       	call   f0100322 <cons_intr>
}
f0100648:	c9                   	leave  
f0100649:	c3                   	ret    

f010064a <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010064a:	55                   	push   %ebp
f010064b:	89 e5                	mov    %esp,%ebp
f010064d:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100650:	b8 32 05 10 f0       	mov    $0xf0100532,%eax
f0100655:	e8 c8 fc ff ff       	call   f0100322 <cons_intr>
}
f010065a:	c9                   	leave  
f010065b:	c3                   	ret    

f010065c <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010065c:	55                   	push   %ebp
f010065d:	89 e5                	mov    %esp,%ebp
f010065f:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100662:	e8 c8 ff ff ff       	call   f010062f <serial_intr>
	kbd_intr();
f0100667:	e8 de ff ff ff       	call   f010064a <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010066c:	8b 15 20 52 2e f0    	mov    0xf02e5220,%edx
f0100672:	3b 15 24 52 2e f0    	cmp    0xf02e5224,%edx
f0100678:	74 22                	je     f010069c <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010067a:	0f b6 82 20 50 2e f0 	movzbl -0xfd1afe0(%edx),%eax
f0100681:	42                   	inc    %edx
f0100682:	89 15 20 52 2e f0    	mov    %edx,0xf02e5220
		if (cons.rpos == CONSBUFSIZE)
f0100688:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010068e:	75 11                	jne    f01006a1 <cons_getc+0x45>
			cons.rpos = 0;
f0100690:	c7 05 20 52 2e f0 00 	movl   $0x0,0xf02e5220
f0100697:	00 00 00 
f010069a:	eb 05                	jmp    f01006a1 <cons_getc+0x45>
		return c;
	}
	return 0;
f010069c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01006a1:	c9                   	leave  
f01006a2:	c3                   	ret    

f01006a3 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006a3:	55                   	push   %ebp
f01006a4:	89 e5                	mov    %esp,%ebp
f01006a6:	57                   	push   %edi
f01006a7:	56                   	push   %esi
f01006a8:	53                   	push   %ebx
f01006a9:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006ac:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01006b3:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006ba:	5a a5 
	if (*cp != 0xA55A) {
f01006bc:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01006c2:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006c6:	74 11                	je     f01006d9 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006c8:	c7 05 0c 50 2e f0 b4 	movl   $0x3b4,0xf02e500c
f01006cf:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006d2:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006d7:	eb 16                	jmp    f01006ef <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006d9:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006e0:	c7 05 0c 50 2e f0 d4 	movl   $0x3d4,0xf02e500c
f01006e7:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006ea:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006ef:	8b 0d 0c 50 2e f0    	mov    0xf02e500c,%ecx
f01006f5:	b0 0e                	mov    $0xe,%al
f01006f7:	89 ca                	mov    %ecx,%edx
f01006f9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006fa:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fd:	89 da                	mov    %ebx,%edx
f01006ff:	ec                   	in     (%dx),%al
f0100700:	0f b6 f8             	movzbl %al,%edi
f0100703:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100706:	b0 0f                	mov    $0xf,%al
f0100708:	89 ca                	mov    %ecx,%edx
f010070a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010070b:	89 da                	mov    %ebx,%edx
f010070d:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010070e:	89 35 08 50 2e f0    	mov    %esi,0xf02e5008

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100714:	0f b6 d8             	movzbl %al,%ebx
f0100717:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100719:	66 89 3d 04 50 2e f0 	mov    %di,0xf02e5004

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100720:	e8 25 ff ff ff       	call   f010064a <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100725:	83 ec 0c             	sub    $0xc,%esp
f0100728:	0f b7 05 90 83 12 f0 	movzwl 0xf0128390,%eax
f010072f:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100734:	50                   	push   %eax
f0100735:	e8 0a 35 00 00       	call   f0103c44 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010073a:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010073f:	b0 00                	mov    $0x0,%al
f0100741:	89 da                	mov    %ebx,%edx
f0100743:	ee                   	out    %al,(%dx)
f0100744:	b2 fb                	mov    $0xfb,%dl
f0100746:	b0 80                	mov    $0x80,%al
f0100748:	ee                   	out    %al,(%dx)
f0100749:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010074e:	b0 0c                	mov    $0xc,%al
f0100750:	89 ca                	mov    %ecx,%edx
f0100752:	ee                   	out    %al,(%dx)
f0100753:	b2 f9                	mov    $0xf9,%dl
f0100755:	b0 00                	mov    $0x0,%al
f0100757:	ee                   	out    %al,(%dx)
f0100758:	b2 fb                	mov    $0xfb,%dl
f010075a:	b0 03                	mov    $0x3,%al
f010075c:	ee                   	out    %al,(%dx)
f010075d:	b2 fc                	mov    $0xfc,%dl
f010075f:	b0 00                	mov    $0x0,%al
f0100761:	ee                   	out    %al,(%dx)
f0100762:	b2 f9                	mov    $0xf9,%dl
f0100764:	b0 01                	mov    $0x1,%al
f0100766:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100767:	b2 fd                	mov    $0xfd,%dl
f0100769:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010076a:	83 c4 10             	add    $0x10,%esp
f010076d:	3c ff                	cmp    $0xff,%al
f010076f:	0f 95 45 e7          	setne  -0x19(%ebp)
f0100773:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100776:	a2 10 50 2e f0       	mov    %al,0xf02e5010
f010077b:	89 da                	mov    %ebx,%edx
f010077d:	ec                   	in     (%dx),%al
f010077e:	89 ca                	mov    %ecx,%edx
f0100780:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100781:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100785:	75 10                	jne    f0100797 <cons_init+0xf4>
		cprintf("Serial port does not exist!\n");
f0100787:	83 ec 0c             	sub    $0xc,%esp
f010078a:	68 ee 68 10 f0       	push   $0xf01068ee
f010078f:	e8 c9 35 00 00       	call   f0103d5d <cprintf>
f0100794:	83 c4 10             	add    $0x10,%esp
}
f0100797:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010079a:	5b                   	pop    %ebx
f010079b:	5e                   	pop    %esi
f010079c:	5f                   	pop    %edi
f010079d:	c9                   	leave  
f010079e:	c3                   	ret    

f010079f <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010079f:	55                   	push   %ebp
f01007a0:	89 e5                	mov    %esp,%ebp
f01007a2:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01007a8:	e8 b6 fb ff ff       	call   f0100363 <cons_putc>
}
f01007ad:	c9                   	leave  
f01007ae:	c3                   	ret    

f01007af <getchar>:

int
getchar(void)
{
f01007af:	55                   	push   %ebp
f01007b0:	89 e5                	mov    %esp,%ebp
f01007b2:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007b5:	e8 a2 fe ff ff       	call   f010065c <cons_getc>
f01007ba:	85 c0                	test   %eax,%eax
f01007bc:	74 f7                	je     f01007b5 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007be:	c9                   	leave  
f01007bf:	c3                   	ret    

f01007c0 <iscons>:

int
iscons(int fdnum)
{
f01007c0:	55                   	push   %ebp
f01007c1:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007c3:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c8:	c9                   	leave  
f01007c9:	c3                   	ret    
	...

f01007cc <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007cc:	55                   	push   %ebp
f01007cd:	89 e5                	mov    %esp,%ebp
f01007cf:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d2:	68 30 6b 10 f0       	push   $0xf0106b30
f01007d7:	e8 81 35 00 00       	call   f0103d5d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007dc:	83 c4 08             	add    $0x8,%esp
f01007df:	68 0c 00 10 00       	push   $0x10000c
f01007e4:	68 5c 6d 10 f0       	push   $0xf0106d5c
f01007e9:	e8 6f 35 00 00       	call   f0103d5d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007ee:	83 c4 0c             	add    $0xc,%esp
f01007f1:	68 0c 00 10 00       	push   $0x10000c
f01007f6:	68 0c 00 10 f0       	push   $0xf010000c
f01007fb:	68 84 6d 10 f0       	push   $0xf0106d84
f0100800:	e8 58 35 00 00       	call   f0103d5d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100805:	83 c4 0c             	add    $0xc,%esp
f0100808:	68 08 68 10 00       	push   $0x106808
f010080d:	68 08 68 10 f0       	push   $0xf0106808
f0100812:	68 a8 6d 10 f0       	push   $0xf0106da8
f0100817:	e8 41 35 00 00       	call   f0103d5d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010081c:	83 c4 0c             	add    $0xc,%esp
f010081f:	68 98 4b 2e 00       	push   $0x2e4b98
f0100824:	68 98 4b 2e f0       	push   $0xf02e4b98
f0100829:	68 cc 6d 10 f0       	push   $0xf0106dcc
f010082e:	e8 2a 35 00 00       	call   f0103d5d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100833:	83 c4 0c             	add    $0xc,%esp
f0100836:	68 08 70 32 00       	push   $0x327008
f010083b:	68 08 70 32 f0       	push   $0xf0327008
f0100840:	68 f0 6d 10 f0       	push   $0xf0106df0
f0100845:	e8 13 35 00 00       	call   f0103d5d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010084a:	b8 07 74 32 f0       	mov    $0xf0327407,%eax
f010084f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100854:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100857:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085c:	89 c2                	mov    %eax,%edx
f010085e:	85 c0                	test   %eax,%eax
f0100860:	79 06                	jns    f0100868 <mon_kerninfo+0x9c>
f0100862:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100868:	c1 fa 0a             	sar    $0xa,%edx
f010086b:	52                   	push   %edx
f010086c:	68 14 6e 10 f0       	push   $0xf0106e14
f0100871:	e8 e7 34 00 00       	call   f0103d5d <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100876:	b8 00 00 00 00       	mov    $0x0,%eax
f010087b:	c9                   	leave  
f010087c:	c3                   	ret    

f010087d <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010087d:	55                   	push   %ebp
f010087e:	89 e5                	mov    %esp,%ebp
f0100880:	53                   	push   %ebx
f0100881:	83 ec 04             	sub    $0x4,%esp
f0100884:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100889:	83 ec 04             	sub    $0x4,%esp
f010088c:	ff b3 a4 72 10 f0    	pushl  -0xfef8d5c(%ebx)
f0100892:	ff b3 a0 72 10 f0    	pushl  -0xfef8d60(%ebx)
f0100898:	68 49 6b 10 f0       	push   $0xf0106b49
f010089d:	e8 bb 34 00 00       	call   f0103d5d <cprintf>
f01008a2:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008a5:	83 c4 10             	add    $0x10,%esp
f01008a8:	83 fb 6c             	cmp    $0x6c,%ebx
f01008ab:	75 dc                	jne    f0100889 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01008b5:	c9                   	leave  
f01008b6:	c3                   	ret    

f01008b7 <mon_si>:
    return 0;
}

int 
mon_si(int argc, char **argv, struct Trapframe *tf)
{
f01008b7:	55                   	push   %ebp
f01008b8:	89 e5                	mov    %esp,%ebp
f01008ba:	83 ec 08             	sub    $0x8,%esp
f01008bd:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f01008c0:	85 c0                	test   %eax,%eax
f01008c2:	75 14                	jne    f01008d8 <mon_si+0x21>
        cprintf("Error: you only can use si in breakpoint.\n");
f01008c4:	83 ec 0c             	sub    $0xc,%esp
f01008c7:	68 40 6e 10 f0       	push   $0xf0106e40
f01008cc:	e8 8c 34 00 00       	call   f0103d5d <cprintf>

    cprintf("tfno: %u\n", tf->tf_trapno);
    env_run(curenv);
    panic("mon_si : env_run return");
    return 0;
}
f01008d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01008d6:	c9                   	leave  
f01008d7:	c3                   	ret    
        cprintf("Error: you only can use si in breakpoint.\n");
        return -1;
    }

    // next step also cause debug interrupt
    tf->tf_eflags |= FL_TF;
f01008d8:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)

    cprintf("tfno: %u\n", tf->tf_trapno);
f01008df:	83 ec 08             	sub    $0x8,%esp
f01008e2:	ff 70 28             	pushl  0x28(%eax)
f01008e5:	68 52 6b 10 f0       	push   $0xf0106b52
f01008ea:	e8 6e 34 00 00       	call   f0103d5d <cprintf>
    env_run(curenv);
f01008ef:	e8 60 58 00 00       	call   f0106154 <cpunum>
f01008f4:	83 c4 04             	add    $0x4,%esp
f01008f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01008fa:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f0100900:	e8 f3 31 00 00       	call   f0103af8 <env_run>

f0100905 <mon_continue>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

int 
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
f0100905:	55                   	push   %ebp
f0100906:	89 e5                	mov    %esp,%ebp
f0100908:	83 ec 08             	sub    $0x8,%esp
f010090b:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f010090e:	85 c0                	test   %eax,%eax
f0100910:	75 14                	jne    f0100926 <mon_continue+0x21>
        cprintf("Error: you only can use continue in breakpoint.\n");
f0100912:	83 ec 0c             	sub    $0xc,%esp
f0100915:	68 6c 6e 10 f0       	push   $0xf0106e6c
f010091a:	e8 3e 34 00 00       	call   f0103d5d <cprintf>
    }
    tf->tf_eflags &= (~FL_TF);
    env_run(curenv);    // usually it won't return;
    panic("mon_continue : env_run return");
    return 0;
}
f010091f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100924:	c9                   	leave  
f0100925:	c3                   	ret    
{
    if (tf == NULL) {
        cprintf("Error: you only can use continue in breakpoint.\n");
        return -1;
    }
    tf->tf_eflags &= (~FL_TF);
f0100926:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
    env_run(curenv);    // usually it won't return;
f010092d:	e8 22 58 00 00       	call   f0106154 <cpunum>
f0100932:	83 ec 0c             	sub    $0xc,%esp
f0100935:	6b c0 74             	imul   $0x74,%eax,%eax
f0100938:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f010093e:	e8 b5 31 00 00       	call   f0103af8 <env_run>

f0100943 <mon_showmappings>:
    return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100943:	55                   	push   %ebp
f0100944:	89 e5                	mov    %esp,%ebp
f0100946:	57                   	push   %edi
f0100947:	56                   	push   %esi
f0100948:	53                   	push   %ebx
f0100949:	83 ec 0c             	sub    $0xc,%esp
f010094c:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 3) {
f010094f:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100953:	74 21                	je     f0100976 <mon_showmappings+0x33>
        cprintf("Command should be: showmappings [addr1] [addr2]\n");
f0100955:	83 ec 0c             	sub    $0xc,%esp
f0100958:	68 a0 6e 10 f0       	push   $0xf0106ea0
f010095d:	e8 fb 33 00 00       	call   f0103d5d <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f0100962:	c7 04 24 d4 6e 10 f0 	movl   $0xf0106ed4,(%esp)
f0100969:	e8 ef 33 00 00       	call   f0103d5d <cprintf>
f010096e:	83 c4 10             	add    $0x10,%esp
f0100971:	e9 1a 01 00 00       	jmp    f0100a90 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f0100976:	83 ec 04             	sub    $0x4,%esp
f0100979:	6a 00                	push   $0x0
f010097b:	6a 00                	push   $0x0
f010097d:	ff 76 04             	pushl  0x4(%esi)
f0100980:	e8 d9 52 00 00       	call   f0105c5e <strtol>
f0100985:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f0100987:	83 c4 0c             	add    $0xc,%esp
f010098a:	6a 00                	push   $0x0
f010098c:	6a 00                	push   $0x0
f010098e:	ff 76 08             	pushl  0x8(%esi)
f0100991:	e8 c8 52 00 00       	call   f0105c5e <strtol>
        if (laddr > haddr) {
f0100996:	83 c4 10             	add    $0x10,%esp
f0100999:	39 c3                	cmp    %eax,%ebx
f010099b:	76 01                	jbe    f010099e <mon_showmappings+0x5b>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f010099d:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, PGSIZE);
f010099e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        haddr = ROUNDUP(haddr, PGSIZE);
f01009a4:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01009aa:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
f01009b0:	83 ec 04             	sub    $0x4,%esp
f01009b3:	57                   	push   %edi
f01009b4:	53                   	push   %ebx
f01009b5:	68 5c 6b 10 f0       	push   $0xf0106b5c
f01009ba:	e8 9e 33 00 00       	call   f0103d5d <cprintf>
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f01009bf:	83 c4 10             	add    $0x10,%esp
f01009c2:	39 fb                	cmp    %edi,%ebx
f01009c4:	75 07                	jne    f01009cd <mon_showmappings+0x8a>
f01009c6:	e9 c5 00 00 00       	jmp    f0100a90 <mon_showmappings+0x14d>
f01009cb:	89 f3                	mov    %esi,%ebx
            cprintf("[ 0x%08x, 0x%08x ) -> ", now, now + PGSIZE); 
f01009cd:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
f01009d3:	83 ec 04             	sub    $0x4,%esp
f01009d6:	56                   	push   %esi
f01009d7:	53                   	push   %ebx
f01009d8:	68 6d 6b 10 f0       	push   $0xf0106b6d
f01009dd:	e8 7b 33 00 00       	call   f0103d5d <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f01009e2:	83 c4 0c             	add    $0xc,%esp
f01009e5:	6a 00                	push   $0x0
f01009e7:	53                   	push   %ebx
f01009e8:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f01009ee:	e8 a2 0c 00 00       	call   f0101695 <pgdir_walk>
f01009f3:	89 c3                	mov    %eax,%ebx
            if (pte == 0 || (*pte & PTE_P) == 0) {
f01009f5:	83 c4 10             	add    $0x10,%esp
f01009f8:	85 c0                	test   %eax,%eax
f01009fa:	74 06                	je     f0100a02 <mon_showmappings+0xbf>
f01009fc:	8b 00                	mov    (%eax),%eax
f01009fe:	a8 01                	test   $0x1,%al
f0100a00:	75 12                	jne    f0100a14 <mon_showmappings+0xd1>
                cprintf(" no mapped \n");
f0100a02:	83 ec 0c             	sub    $0xc,%esp
f0100a05:	68 84 6b 10 f0       	push   $0xf0106b84
f0100a0a:	e8 4e 33 00 00       	call   f0103d5d <cprintf>
f0100a0f:	83 c4 10             	add    $0x10,%esp
f0100a12:	eb 74                	jmp    f0100a88 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f0100a14:	83 ec 08             	sub    $0x8,%esp
f0100a17:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a1c:	50                   	push   %eax
f0100a1d:	68 91 6b 10 f0       	push   $0xf0106b91
f0100a22:	e8 36 33 00 00       	call   f0103d5d <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f0100a27:	83 c4 10             	add    $0x10,%esp
f0100a2a:	f6 03 04             	testb  $0x4,(%ebx)
f0100a2d:	74 12                	je     f0100a41 <mon_showmappings+0xfe>
f0100a2f:	83 ec 0c             	sub    $0xc,%esp
f0100a32:	68 99 6b 10 f0       	push   $0xf0106b99
f0100a37:	e8 21 33 00 00       	call   f0103d5d <cprintf>
f0100a3c:	83 c4 10             	add    $0x10,%esp
f0100a3f:	eb 10                	jmp    f0100a51 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f0100a41:	83 ec 0c             	sub    $0xc,%esp
f0100a44:	68 a6 6b 10 f0       	push   $0xf0106ba6
f0100a49:	e8 0f 33 00 00       	call   f0103d5d <cprintf>
f0100a4e:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f0100a51:	f6 03 02             	testb  $0x2,(%ebx)
f0100a54:	74 12                	je     f0100a68 <mon_showmappings+0x125>
f0100a56:	83 ec 0c             	sub    $0xc,%esp
f0100a59:	68 b3 6b 10 f0       	push   $0xf0106bb3
f0100a5e:	e8 fa 32 00 00       	call   f0103d5d <cprintf>
f0100a63:	83 c4 10             	add    $0x10,%esp
f0100a66:	eb 10                	jmp    f0100a78 <mon_showmappings+0x135>
                else cprintf(" R ");
f0100a68:	83 ec 0c             	sub    $0xc,%esp
f0100a6b:	68 b8 6b 10 f0       	push   $0xf0106bb8
f0100a70:	e8 e8 32 00 00       	call   f0103d5d <cprintf>
f0100a75:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f0100a78:	83 ec 0c             	sub    $0xc,%esp
f0100a7b:	68 8f 6b 10 f0       	push   $0xf0106b8f
f0100a80:	e8 d8 32 00 00       	call   f0103d5d <cprintf>
f0100a85:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDUP(haddr, PGSIZE);
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f0100a88:	39 f7                	cmp    %esi,%edi
f0100a8a:	0f 85 3b ff ff ff    	jne    f01009cb <mon_showmappings+0x88>
                cprintf("\n");
            }
        }
    }
    return 0;
}
f0100a90:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a95:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a98:	5b                   	pop    %ebx
f0100a99:	5e                   	pop    %esi
f0100a9a:	5f                   	pop    %edi
f0100a9b:	c9                   	leave  
f0100a9c:	c3                   	ret    

f0100a9d <mon_setpermission>:
    return 0;
}

int
mon_setpermission(int argc, char **argv, struct Trapframe *tf)
{
f0100a9d:	55                   	push   %ebp
f0100a9e:	89 e5                	mov    %esp,%ebp
f0100aa0:	57                   	push   %edi
f0100aa1:	56                   	push   %esi
f0100aa2:	53                   	push   %ebx
f0100aa3:	83 ec 0c             	sub    $0xc,%esp
f0100aa6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 5) { 
f0100aa9:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f0100aad:	74 21                	je     f0100ad0 <mon_setpermission+0x33>
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
f0100aaf:	83 ec 0c             	sub    $0xc,%esp
f0100ab2:	68 fc 6e 10 f0       	push   $0xf0106efc
f0100ab7:	e8 a1 32 00 00       	call   f0103d5d <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f0100abc:	c7 04 24 4c 6f 10 f0 	movl   $0xf0106f4c,(%esp)
f0100ac3:	e8 95 32 00 00       	call   f0103d5d <cprintf>
f0100ac8:	83 c4 10             	add    $0x10,%esp
f0100acb:	e9 a5 01 00 00       	jmp    f0100c75 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f0100ad0:	83 ec 04             	sub    $0x4,%esp
f0100ad3:	6a 00                	push   $0x0
f0100ad5:	6a 00                	push   $0x0
f0100ad7:	ff 73 04             	pushl  0x4(%ebx)
f0100ada:	e8 7f 51 00 00       	call   f0105c5e <strtol>
        uint32_t perm = 0;
        if (argv[2][0] == '1') perm |= PTE_W;
f0100adf:	8b 53 08             	mov    0x8(%ebx),%edx
f0100ae2:	83 c4 10             	add    $0x10,%esp
    if (argc != 5) { 
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
        cprintf("Example: setpermissions 0x0 1 0 1\n");
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
        uint32_t perm = 0;
f0100ae5:	80 3a 31             	cmpb   $0x31,(%edx)
f0100ae8:	0f 94 c2             	sete   %dl
f0100aeb:	0f b6 d2             	movzbl %dl,%edx
f0100aee:	89 d6                	mov    %edx,%esi
f0100af0:	d1 e6                	shl    %esi
        if (argv[2][0] == '1') perm |= PTE_W;
        if (argv[3][0] == '1') perm |= PTE_U;
f0100af2:	8b 53 0c             	mov    0xc(%ebx),%edx
f0100af5:	80 3a 31             	cmpb   $0x31,(%edx)
f0100af8:	75 03                	jne    f0100afd <mon_setpermission+0x60>
f0100afa:	83 ce 04             	or     $0x4,%esi
        if (argv[4][0] == '1') perm |= PTE_P;
f0100afd:	8b 53 10             	mov    0x10(%ebx),%edx
f0100b00:	80 3a 31             	cmpb   $0x31,(%edx)
f0100b03:	75 03                	jne    f0100b08 <mon_setpermission+0x6b>
f0100b05:	83 ce 01             	or     $0x1,%esi
        addr = ROUNDUP(addr, PGSIZE);
f0100b08:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f0100b0e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
f0100b14:	83 ec 04             	sub    $0x4,%esp
f0100b17:	6a 00                	push   $0x0
f0100b19:	57                   	push   %edi
f0100b1a:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0100b20:	e8 70 0b 00 00       	call   f0101695 <pgdir_walk>
f0100b25:	89 c3                	mov    %eax,%ebx
        if (pte != NULL) {
f0100b27:	83 c4 10             	add    $0x10,%esp
f0100b2a:	85 c0                	test   %eax,%eax
f0100b2c:	0f 84 33 01 00 00    	je     f0100c65 <mon_setpermission+0x1c8>
            cprintf("0x%08x -> pa: 0x%08x\n old_perm: ", addr, PTE_ADDR(*pte));
f0100b32:	83 ec 04             	sub    $0x4,%esp
f0100b35:	8b 00                	mov    (%eax),%eax
f0100b37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b3c:	50                   	push   %eax
f0100b3d:	57                   	push   %edi
f0100b3e:	68 70 6f 10 f0       	push   $0xf0106f70
f0100b43:	e8 15 32 00 00       	call   f0103d5d <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100b48:	83 c4 10             	add    $0x10,%esp
f0100b4b:	f6 03 02             	testb  $0x2,(%ebx)
f0100b4e:	74 12                	je     f0100b62 <mon_setpermission+0xc5>
f0100b50:	83 ec 0c             	sub    $0xc,%esp
f0100b53:	68 bc 6b 10 f0       	push   $0xf0106bbc
f0100b58:	e8 00 32 00 00       	call   f0103d5d <cprintf>
f0100b5d:	83 c4 10             	add    $0x10,%esp
f0100b60:	eb 10                	jmp    f0100b72 <mon_setpermission+0xd5>
f0100b62:	83 ec 0c             	sub    $0xc,%esp
f0100b65:	68 bf 6b 10 f0       	push   $0xf0106bbf
f0100b6a:	e8 ee 31 00 00       	call   f0103d5d <cprintf>
f0100b6f:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100b72:	f6 03 04             	testb  $0x4,(%ebx)
f0100b75:	74 12                	je     f0100b89 <mon_setpermission+0xec>
f0100b77:	83 ec 0c             	sub    $0xc,%esp
f0100b7a:	68 03 7e 10 f0       	push   $0xf0107e03
f0100b7f:	e8 d9 31 00 00       	call   f0103d5d <cprintf>
f0100b84:	83 c4 10             	add    $0x10,%esp
f0100b87:	eb 10                	jmp    f0100b99 <mon_setpermission+0xfc>
f0100b89:	83 ec 0c             	sub    $0xc,%esp
f0100b8c:	68 1b 82 10 f0       	push   $0xf010821b
f0100b91:	e8 c7 31 00 00       	call   f0103d5d <cprintf>
f0100b96:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100b99:	f6 03 01             	testb  $0x1,(%ebx)
f0100b9c:	74 12                	je     f0100bb0 <mon_setpermission+0x113>
f0100b9e:	83 ec 0c             	sub    $0xc,%esp
f0100ba1:	68 39 88 10 f0       	push   $0xf0108839
f0100ba6:	e8 b2 31 00 00       	call   f0103d5d <cprintf>
f0100bab:	83 c4 10             	add    $0x10,%esp
f0100bae:	eb 10                	jmp    f0100bc0 <mon_setpermission+0x123>
f0100bb0:	83 ec 0c             	sub    $0xc,%esp
f0100bb3:	68 c0 6b 10 f0       	push   $0xf0106bc0
f0100bb8:	e8 a0 31 00 00       	call   f0103d5d <cprintf>
f0100bbd:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f0100bc0:	83 ec 0c             	sub    $0xc,%esp
f0100bc3:	68 c2 6b 10 f0       	push   $0xf0106bc2
f0100bc8:	e8 90 31 00 00       	call   f0103d5d <cprintf>
            *pte = PTE_ADDR(*pte) | perm;     
f0100bcd:	8b 03                	mov    (%ebx),%eax
f0100bcf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bd4:	09 c6                	or     %eax,%esi
f0100bd6:	89 33                	mov    %esi,(%ebx)
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100bd8:	83 c4 10             	add    $0x10,%esp
f0100bdb:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0100be1:	74 12                	je     f0100bf5 <mon_setpermission+0x158>
f0100be3:	83 ec 0c             	sub    $0xc,%esp
f0100be6:	68 bc 6b 10 f0       	push   $0xf0106bbc
f0100beb:	e8 6d 31 00 00       	call   f0103d5d <cprintf>
f0100bf0:	83 c4 10             	add    $0x10,%esp
f0100bf3:	eb 10                	jmp    f0100c05 <mon_setpermission+0x168>
f0100bf5:	83 ec 0c             	sub    $0xc,%esp
f0100bf8:	68 bf 6b 10 f0       	push   $0xf0106bbf
f0100bfd:	e8 5b 31 00 00       	call   f0103d5d <cprintf>
f0100c02:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100c05:	f6 03 04             	testb  $0x4,(%ebx)
f0100c08:	74 12                	je     f0100c1c <mon_setpermission+0x17f>
f0100c0a:	83 ec 0c             	sub    $0xc,%esp
f0100c0d:	68 03 7e 10 f0       	push   $0xf0107e03
f0100c12:	e8 46 31 00 00       	call   f0103d5d <cprintf>
f0100c17:	83 c4 10             	add    $0x10,%esp
f0100c1a:	eb 10                	jmp    f0100c2c <mon_setpermission+0x18f>
f0100c1c:	83 ec 0c             	sub    $0xc,%esp
f0100c1f:	68 1b 82 10 f0       	push   $0xf010821b
f0100c24:	e8 34 31 00 00       	call   f0103d5d <cprintf>
f0100c29:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100c2c:	f6 03 01             	testb  $0x1,(%ebx)
f0100c2f:	74 12                	je     f0100c43 <mon_setpermission+0x1a6>
f0100c31:	83 ec 0c             	sub    $0xc,%esp
f0100c34:	68 39 88 10 f0       	push   $0xf0108839
f0100c39:	e8 1f 31 00 00       	call   f0103d5d <cprintf>
f0100c3e:	83 c4 10             	add    $0x10,%esp
f0100c41:	eb 10                	jmp    f0100c53 <mon_setpermission+0x1b6>
f0100c43:	83 ec 0c             	sub    $0xc,%esp
f0100c46:	68 c0 6b 10 f0       	push   $0xf0106bc0
f0100c4b:	e8 0d 31 00 00       	call   f0103d5d <cprintf>
f0100c50:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100c53:	83 ec 0c             	sub    $0xc,%esp
f0100c56:	68 8f 6b 10 f0       	push   $0xf0106b8f
f0100c5b:	e8 fd 30 00 00       	call   f0103d5d <cprintf>
f0100c60:	83 c4 10             	add    $0x10,%esp
f0100c63:	eb 10                	jmp    f0100c75 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100c65:	83 ec 0c             	sub    $0xc,%esp
f0100c68:	68 84 6b 10 f0       	push   $0xf0106b84
f0100c6d:	e8 eb 30 00 00       	call   f0103d5d <cprintf>
f0100c72:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100c75:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c7d:	5b                   	pop    %ebx
f0100c7e:	5e                   	pop    %esi
f0100c7f:	5f                   	pop    %edi
f0100c80:	c9                   	leave  
f0100c81:	c3                   	ret    

f0100c82 <mon_setcolor>:
    return 0;
}

int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f0100c82:	55                   	push   %ebp
f0100c83:	89 e5                	mov    %esp,%ebp
f0100c85:	56                   	push   %esi
f0100c86:	53                   	push   %ebx
f0100c87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f0100c8a:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100c8e:	74 66                	je     f0100cf6 <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f0100c90:	83 ec 0c             	sub    $0xc,%esp
f0100c93:	68 94 6f 10 f0       	push   $0xf0106f94
f0100c98:	e8 c0 30 00 00       	call   f0103d5d <cprintf>
        cprintf("num show the color attribute. \n");
f0100c9d:	c7 04 24 c4 6f 10 f0 	movl   $0xf0106fc4,(%esp)
f0100ca4:	e8 b4 30 00 00       	call   f0103d5d <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100ca9:	c7 04 24 e4 6f 10 f0 	movl   $0xf0106fe4,(%esp)
f0100cb0:	e8 a8 30 00 00       	call   f0103d5d <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100cb5:	c7 04 24 18 70 10 f0 	movl   $0xf0107018,(%esp)
f0100cbc:	e8 9c 30 00 00       	call   f0103d5d <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100cc1:	c7 04 24 5c 70 10 f0 	movl   $0xf010705c,(%esp)
f0100cc8:	e8 90 30 00 00       	call   f0103d5d <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100ccd:	c7 04 24 d3 6b 10 f0 	movl   $0xf0106bd3,(%esp)
f0100cd4:	e8 84 30 00 00       	call   f0103d5d <cprintf>
        cprintf("         set the background color to black\n");
f0100cd9:	c7 04 24 a0 70 10 f0 	movl   $0xf01070a0,(%esp)
f0100ce0:	e8 78 30 00 00       	call   f0103d5d <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100ce5:	c7 04 24 cc 70 10 f0 	movl   $0xf01070cc,(%esp)
f0100cec:	e8 6c 30 00 00       	call   f0103d5d <cprintf>
f0100cf1:	83 c4 10             	add    $0x10,%esp
f0100cf4:	eb 52                	jmp    f0100d48 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100cf6:	83 ec 0c             	sub    $0xc,%esp
f0100cf9:	ff 73 04             	pushl  0x4(%ebx)
f0100cfc:	e8 5b 4c 00 00       	call   f010595c <strlen>
f0100d01:	83 c4 10             	add    $0x10,%esp
f0100d04:	48                   	dec    %eax
f0100d05:	78 26                	js     f0100d2d <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f0100d07:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100d0a:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100d0f:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f0100d14:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f0100d18:	0f 94 c3             	sete   %bl
f0100d1b:	0f b6 db             	movzbl %bl,%ebx
f0100d1e:	d3 e3                	shl    %cl,%ebx
f0100d20:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100d22:	48                   	dec    %eax
f0100d23:	78 0d                	js     f0100d32 <mon_setcolor+0xb0>
f0100d25:	41                   	inc    %ecx
f0100d26:	83 f9 08             	cmp    $0x8,%ecx
f0100d29:	75 e9                	jne    f0100d14 <mon_setcolor+0x92>
f0100d2b:	eb 05                	jmp    f0100d32 <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100d2d:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f0100d32:	89 15 00 50 2e f0    	mov    %edx,0xf02e5000
        cprintf(" This is color that you want ! \n");
f0100d38:	83 ec 0c             	sub    $0xc,%esp
f0100d3b:	68 00 71 10 f0       	push   $0xf0107100
f0100d40:	e8 18 30 00 00       	call   f0103d5d <cprintf>
f0100d45:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f0100d48:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100d50:	5b                   	pop    %ebx
f0100d51:	5e                   	pop    %esi
f0100d52:	c9                   	leave  
f0100d53:	c3                   	ret    

f0100d54 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f0100d54:	55                   	push   %ebp
f0100d55:	89 e5                	mov    %esp,%ebp
f0100d57:	57                   	push   %edi
f0100d58:	56                   	push   %esi
f0100d59:	53                   	push   %ebx
f0100d5a:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100d5d:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100d5f:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100d61:	85 c0                	test   %eax,%eax
f0100d63:	74 6d                	je     f0100dd2 <mon_backtrace+0x7e>
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100d65:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
f0100d68:	8b 5e 04             	mov    0x4(%esi),%ebx
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100d6b:	ff 76 18             	pushl  0x18(%esi)
f0100d6e:	ff 76 14             	pushl  0x14(%esi)
f0100d71:	ff 76 10             	pushl  0x10(%esi)
f0100d74:	ff 76 0c             	pushl  0xc(%esi)
f0100d77:	ff 76 08             	pushl  0x8(%esi)
f0100d7a:	53                   	push   %ebx
f0100d7b:	56                   	push   %esi
f0100d7c:	68 24 71 10 f0       	push   $0xf0107124
f0100d81:	e8 d7 2f 00 00       	call   f0103d5d <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100d86:	83 c4 18             	add    $0x18,%esp
f0100d89:	57                   	push   %edi
f0100d8a:	ff 76 04             	pushl  0x4(%esi)
f0100d8d:	e8 eb 42 00 00       	call   f010507d <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100d92:	83 c4 0c             	add    $0xc,%esp
f0100d95:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100d98:	ff 75 d0             	pushl  -0x30(%ebp)
f0100d9b:	68 ef 6b 10 f0       	push   $0xf0106bef
f0100da0:	e8 b8 2f 00 00       	call   f0103d5d <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100da5:	83 c4 0c             	add    $0xc,%esp
f0100da8:	ff 75 d8             	pushl  -0x28(%ebp)
f0100dab:	ff 75 dc             	pushl  -0x24(%ebp)
f0100dae:	68 ff 6b 10 f0       	push   $0xf0106bff
f0100db3:	e8 a5 2f 00 00       	call   f0103d5d <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100db8:	83 c4 08             	add    $0x8,%esp
f0100dbb:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100dbe:	53                   	push   %ebx
f0100dbf:	68 04 6c 10 f0       	push   $0xf0106c04
f0100dc4:	e8 94 2f 00 00       	call   f0103d5d <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100dc9:	8b 36                	mov    (%esi),%esi
f0100dcb:	83 c4 10             	add    $0x10,%esp
f0100dce:	85 f6                	test   %esi,%esi
f0100dd0:	75 96                	jne    f0100d68 <mon_backtrace+0x14>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100dd2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dda:	5b                   	pop    %ebx
f0100ddb:	5e                   	pop    %esi
f0100ddc:	5f                   	pop    %edi
f0100ddd:	c9                   	leave  
f0100dde:	c3                   	ret    

f0100ddf <pa_con>:
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
f0100ddf:	55                   	push   %ebp
f0100de0:	89 e5                	mov    %esp,%ebp
f0100de2:	53                   	push   %ebx
f0100de3:	83 ec 04             	sub    $0x4,%esp
f0100de6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100de9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
f0100dec:	8b 15 90 5e 2e f0    	mov    0xf02e5e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100df2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100df8:	77 15                	ja     f0100e0f <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100dfa:	52                   	push   %edx
f0100dfb:	68 44 68 10 f0       	push   $0xf0106844
f0100e00:	68 96 00 00 00       	push   $0x96
f0100e05:	68 09 6c 10 f0       	push   $0xf0106c09
f0100e0a:	e8 59 f2 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100e0f:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100e15:	39 d0                	cmp    %edx,%eax
f0100e17:	72 18                	jb     f0100e31 <pa_con+0x52>
f0100e19:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
f0100e1f:	39 d8                	cmp    %ebx,%eax
f0100e21:	73 0e                	jae    f0100e31 <pa_con+0x52>
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
f0100e23:	29 d0                	sub    %edx,%eax
f0100e25:	8b 80 00 00 00 ef    	mov    -0x11000000(%eax),%eax
f0100e2b:	89 01                	mov    %eax,(%ecx)
        return true;
f0100e2d:	b0 01                	mov    $0x1,%al
f0100e2f:	eb 56                	jmp    f0100e87 <pa_con+0xa8>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e31:	ba 00 e0 11 f0       	mov    $0xf011e000,%edx
f0100e36:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100e3c:	77 15                	ja     f0100e53 <pa_con+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e3e:	52                   	push   %edx
f0100e3f:	68 44 68 10 f0       	push   $0xf0106844
f0100e44:	68 9b 00 00 00       	push   $0x9b
f0100e49:	68 09 6c 10 f0       	push   $0xf0106c09
f0100e4e:	e8 15 f2 ff ff       	call   f0100068 <_panic>
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
f0100e53:	3d 00 e0 11 00       	cmp    $0x11e000,%eax
f0100e58:	72 18                	jb     f0100e72 <pa_con+0x93>
f0100e5a:	3d 00 60 12 00       	cmp    $0x126000,%eax
f0100e5f:	73 11                	jae    f0100e72 <pa_con+0x93>
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
f0100e61:	2d 00 e0 11 00       	sub    $0x11e000,%eax
f0100e66:	8b 80 00 80 ff ef    	mov    -0x10008000(%eax),%eax
f0100e6c:	89 01                	mov    %eax,(%ecx)
        return true;
f0100e6e:	b0 01                	mov    $0x1,%al
f0100e70:	eb 15                	jmp    f0100e87 <pa_con+0xa8>
    }
    if (addr < -KERNBASE) {
f0100e72:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100e77:	77 0c                	ja     f0100e85 <pa_con+0xa6>
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
f0100e79:	8b 80 00 00 00 f0    	mov    -0x10000000(%eax),%eax
f0100e7f:	89 01                	mov    %eax,(%ecx)
        return true;
f0100e81:	b0 01                	mov    $0x1,%al
f0100e83:	eb 02                	jmp    f0100e87 <pa_con+0xa8>
    }
    // Not in virtual memory mapped.
    return false;
f0100e85:	b0 00                	mov    $0x0,%al
}
f0100e87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e8a:	c9                   	leave  
f0100e8b:	c3                   	ret    

f0100e8c <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
f0100e8c:	55                   	push   %ebp
f0100e8d:	89 e5                	mov    %esp,%ebp
f0100e8f:	57                   	push   %edi
f0100e90:	56                   	push   %esi
f0100e91:	53                   	push   %ebx
f0100e92:	83 ec 2c             	sub    $0x2c,%esp
f0100e95:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 4) {
f0100e98:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100e9c:	74 2d                	je     f0100ecb <mon_dump+0x3f>
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
f0100e9e:	83 ec 0c             	sub    $0xc,%esp
f0100ea1:	68 5c 71 10 f0       	push   $0xf010715c
f0100ea6:	e8 b2 2e 00 00       	call   f0103d5d <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100eab:	c7 04 24 8c 71 10 f0 	movl   $0xf010718c,(%esp)
f0100eb2:	e8 a6 2e 00 00       	call   f0103d5d <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100eb7:	c7 04 24 b4 71 10 f0 	movl   $0xf01071b4,(%esp)
f0100ebe:	e8 9a 2e 00 00       	call   f0103d5d <cprintf>
f0100ec3:	83 c4 10             	add    $0x10,%esp
f0100ec6:	e9 59 01 00 00       	jmp    f0101024 <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100ecb:	83 ec 04             	sub    $0x4,%esp
f0100ece:	6a 00                	push   $0x0
f0100ed0:	6a 00                	push   $0x0
f0100ed2:	ff 76 08             	pushl  0x8(%esi)
f0100ed5:	e8 84 4d 00 00       	call   f0105c5e <strtol>
f0100eda:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100edc:	83 c4 0c             	add    $0xc,%esp
f0100edf:	6a 00                	push   $0x0
f0100ee1:	6a 00                	push   $0x0
f0100ee3:	ff 76 0c             	pushl  0xc(%esi)
f0100ee6:	e8 73 4d 00 00       	call   f0105c5e <strtol>
        if (laddr > haddr) {
f0100eeb:	83 c4 10             	add    $0x10,%esp
f0100eee:	39 c3                	cmp    %eax,%ebx
f0100ef0:	76 01                	jbe    f0100ef3 <mon_dump+0x67>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100ef2:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, 4);
f0100ef3:	89 df                	mov    %ebx,%edi
f0100ef5:	83 e7 fc             	and    $0xfffffffc,%edi
        haddr = ROUNDDOWN(haddr, 4);
f0100ef8:	83 e0 fc             	and    $0xfffffffc,%eax
f0100efb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if (argv[1][0] == 'v') {
f0100efe:	8b 46 04             	mov    0x4(%esi),%eax
f0100f01:	80 38 76             	cmpb   $0x76,(%eax)
f0100f04:	74 0e                	je     f0100f14 <mon_dump+0x88>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100f06:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100f09:	0f 85 98 00 00 00    	jne    f0100fa7 <mon_dump+0x11b>
f0100f0f:	e9 00 01 00 00       	jmp    f0101014 <mon_dump+0x188>
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100f14:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100f17:	74 7c                	je     f0100f95 <mon_dump+0x109>
f0100f19:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100f1b:	39 fb                	cmp    %edi,%ebx
f0100f1d:	74 15                	je     f0100f34 <mon_dump+0xa8>
f0100f1f:	f6 c3 0f             	test   $0xf,%bl
f0100f22:	75 21                	jne    f0100f45 <mon_dump+0xb9>
                    if (now != laddr) cprintf("\n"); 
f0100f24:	83 ec 0c             	sub    $0xc,%esp
f0100f27:	68 8f 6b 10 f0       	push   $0xf0106b8f
f0100f2c:	e8 2c 2e 00 00       	call   f0103d5d <cprintf>
f0100f31:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100f34:	83 ec 08             	sub    $0x8,%esp
f0100f37:	53                   	push   %ebx
f0100f38:	68 18 6c 10 f0       	push   $0xf0106c18
f0100f3d:	e8 1b 2e 00 00       	call   f0103d5d <cprintf>
f0100f42:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100f45:	83 ec 04             	sub    $0x4,%esp
f0100f48:	6a 00                	push   $0x0
f0100f4a:	89 d8                	mov    %ebx,%eax
f0100f4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f51:	50                   	push   %eax
f0100f52:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0100f58:	e8 38 07 00 00       	call   f0101695 <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100f5d:	83 c4 10             	add    $0x10,%esp
f0100f60:	85 c0                	test   %eax,%eax
f0100f62:	74 19                	je     f0100f7d <mon_dump+0xf1>
f0100f64:	f6 00 01             	testb  $0x1,(%eax)
f0100f67:	74 14                	je     f0100f7d <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100f69:	83 ec 08             	sub    $0x8,%esp
f0100f6c:	ff 33                	pushl  (%ebx)
f0100f6e:	68 22 6c 10 f0       	push   $0xf0106c22
f0100f73:	e8 e5 2d 00 00       	call   f0103d5d <cprintf>
f0100f78:	83 c4 10             	add    $0x10,%esp
f0100f7b:	eb 10                	jmp    f0100f8d <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100f7d:	83 ec 0c             	sub    $0xc,%esp
f0100f80:	68 2d 6c 10 f0       	push   $0xf0106c2d
f0100f85:	e8 d3 2d 00 00       	call   f0103d5d <cprintf>
f0100f8a:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100f8d:	83 c3 04             	add    $0x4,%ebx
f0100f90:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100f93:	75 86                	jne    f0100f1b <mon_dump+0x8f>
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
f0100f95:	83 ec 0c             	sub    $0xc,%esp
f0100f98:	68 8f 6b 10 f0       	push   $0xf0106b8f
f0100f9d:	e8 bb 2d 00 00       	call   f0103d5d <cprintf>
f0100fa2:	83 c4 10             	add    $0x10,%esp
f0100fa5:	eb 7d                	jmp    f0101024 <mon_dump+0x198>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100fa7:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100fa9:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100fac:	39 fb                	cmp    %edi,%ebx
f0100fae:	74 15                	je     f0100fc5 <mon_dump+0x139>
f0100fb0:	f6 c3 0f             	test   $0xf,%bl
f0100fb3:	75 21                	jne    f0100fd6 <mon_dump+0x14a>
                    if (now != laddr) cprintf("\n");
f0100fb5:	83 ec 0c             	sub    $0xc,%esp
f0100fb8:	68 8f 6b 10 f0       	push   $0xf0106b8f
f0100fbd:	e8 9b 2d 00 00       	call   f0103d5d <cprintf>
f0100fc2:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100fc5:	83 ec 08             	sub    $0x8,%esp
f0100fc8:	53                   	push   %ebx
f0100fc9:	68 18 6c 10 f0       	push   $0xf0106c18
f0100fce:	e8 8a 2d 00 00       	call   f0103d5d <cprintf>
f0100fd3:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f0100fd6:	83 ec 08             	sub    $0x8,%esp
f0100fd9:	56                   	push   %esi
f0100fda:	53                   	push   %ebx
f0100fdb:	e8 ff fd ff ff       	call   f0100ddf <pa_con>
f0100fe0:	83 c4 10             	add    $0x10,%esp
f0100fe3:	84 c0                	test   %al,%al
f0100fe5:	74 15                	je     f0100ffc <mon_dump+0x170>
                    cprintf("0x%08x  ", value);
f0100fe7:	83 ec 08             	sub    $0x8,%esp
f0100fea:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100fed:	68 22 6c 10 f0       	push   $0xf0106c22
f0100ff2:	e8 66 2d 00 00       	call   f0103d5d <cprintf>
f0100ff7:	83 c4 10             	add    $0x10,%esp
f0100ffa:	eb 10                	jmp    f010100c <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100ffc:	83 ec 0c             	sub    $0xc,%esp
f0100fff:	68 2b 6c 10 f0       	push   $0xf0106c2b
f0101004:	e8 54 2d 00 00       	call   f0103d5d <cprintf>
f0101009:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f010100c:	83 c3 04             	add    $0x4,%ebx
f010100f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101012:	75 98                	jne    f0100fac <mon_dump+0x120>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f0101014:	83 ec 0c             	sub    $0xc,%esp
f0101017:	68 8f 6b 10 f0       	push   $0xf0106b8f
f010101c:	e8 3c 2d 00 00       	call   f0103d5d <cprintf>
f0101021:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0101024:	b8 00 00 00 00       	mov    $0x0,%eax
f0101029:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010102c:	5b                   	pop    %ebx
f010102d:	5e                   	pop    %esi
f010102e:	5f                   	pop    %edi
f010102f:	c9                   	leave  
f0101030:	c3                   	ret    

f0101031 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0101031:	55                   	push   %ebp
f0101032:	89 e5                	mov    %esp,%ebp
f0101034:	57                   	push   %edi
f0101035:	56                   	push   %esi
f0101036:	53                   	push   %ebx
f0101037:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010103a:	68 f8 71 10 f0       	push   $0xf01071f8
f010103f:	e8 19 2d 00 00       	call   f0103d5d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101044:	c7 04 24 1c 72 10 f0 	movl   $0xf010721c,(%esp)
f010104b:	e8 0d 2d 00 00       	call   f0103d5d <cprintf>

	if (tf != NULL)
f0101050:	83 c4 10             	add    $0x10,%esp
f0101053:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101057:	74 0e                	je     f0101067 <monitor+0x36>
		print_trapframe(tf);
f0101059:	83 ec 0c             	sub    $0xc,%esp
f010105c:	ff 75 08             	pushl  0x8(%ebp)
f010105f:	e8 59 30 00 00       	call   f01040bd <print_trapframe>
f0101064:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0101067:	83 ec 0c             	sub    $0xc,%esp
f010106a:	68 38 6c 10 f0       	push   $0xf0106c38
f010106f:	e8 18 48 00 00       	call   f010588c <readline>
f0101074:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0101076:	83 c4 10             	add    $0x10,%esp
f0101079:	85 c0                	test   %eax,%eax
f010107b:	74 ea                	je     f0101067 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010107d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0101084:	be 00 00 00 00       	mov    $0x0,%esi
f0101089:	eb 04                	jmp    f010108f <monitor+0x5e>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010108b:	c6 03 00             	movb   $0x0,(%ebx)
f010108e:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010108f:	8a 03                	mov    (%ebx),%al
f0101091:	84 c0                	test   %al,%al
f0101093:	74 64                	je     f01010f9 <monitor+0xc8>
f0101095:	83 ec 08             	sub    $0x8,%esp
f0101098:	0f be c0             	movsbl %al,%eax
f010109b:	50                   	push   %eax
f010109c:	68 3c 6c 10 f0       	push   $0xf0106c3c
f01010a1:	e8 2f 4a 00 00       	call   f0105ad5 <strchr>
f01010a6:	83 c4 10             	add    $0x10,%esp
f01010a9:	85 c0                	test   %eax,%eax
f01010ab:	75 de                	jne    f010108b <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01010ad:	80 3b 00             	cmpb   $0x0,(%ebx)
f01010b0:	74 47                	je     f01010f9 <monitor+0xc8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01010b2:	83 fe 0f             	cmp    $0xf,%esi
f01010b5:	75 14                	jne    f01010cb <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01010b7:	83 ec 08             	sub    $0x8,%esp
f01010ba:	6a 10                	push   $0x10
f01010bc:	68 41 6c 10 f0       	push   $0xf0106c41
f01010c1:	e8 97 2c 00 00       	call   f0103d5d <cprintf>
f01010c6:	83 c4 10             	add    $0x10,%esp
f01010c9:	eb 9c                	jmp    f0101067 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01010cb:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01010cf:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01010d0:	8a 03                	mov    (%ebx),%al
f01010d2:	84 c0                	test   %al,%al
f01010d4:	75 09                	jne    f01010df <monitor+0xae>
f01010d6:	eb b7                	jmp    f010108f <monitor+0x5e>
			buf++;
f01010d8:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01010d9:	8a 03                	mov    (%ebx),%al
f01010db:	84 c0                	test   %al,%al
f01010dd:	74 b0                	je     f010108f <monitor+0x5e>
f01010df:	83 ec 08             	sub    $0x8,%esp
f01010e2:	0f be c0             	movsbl %al,%eax
f01010e5:	50                   	push   %eax
f01010e6:	68 3c 6c 10 f0       	push   $0xf0106c3c
f01010eb:	e8 e5 49 00 00       	call   f0105ad5 <strchr>
f01010f0:	83 c4 10             	add    $0x10,%esp
f01010f3:	85 c0                	test   %eax,%eax
f01010f5:	74 e1                	je     f01010d8 <monitor+0xa7>
f01010f7:	eb 96                	jmp    f010108f <monitor+0x5e>
			buf++;
	}
	argv[argc] = 0;
f01010f9:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0101100:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0101101:	85 f6                	test   %esi,%esi
f0101103:	0f 84 5e ff ff ff    	je     f0101067 <monitor+0x36>
f0101109:	bb a0 72 10 f0       	mov    $0xf01072a0,%ebx
f010110e:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101113:	83 ec 08             	sub    $0x8,%esp
f0101116:	ff 33                	pushl  (%ebx)
f0101118:	ff 75 a8             	pushl  -0x58(%ebp)
f010111b:	e8 47 49 00 00       	call   f0105a67 <strcmp>
f0101120:	83 c4 10             	add    $0x10,%esp
f0101123:	85 c0                	test   %eax,%eax
f0101125:	75 20                	jne    f0101147 <monitor+0x116>
			return commands[i].func(argc, argv, tf);
f0101127:	83 ec 04             	sub    $0x4,%esp
f010112a:	6b ff 0c             	imul   $0xc,%edi,%edi
f010112d:	ff 75 08             	pushl  0x8(%ebp)
f0101130:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0101133:	50                   	push   %eax
f0101134:	56                   	push   %esi
f0101135:	ff 97 a8 72 10 f0    	call   *-0xfef8d58(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010113b:	83 c4 10             	add    $0x10,%esp
f010113e:	85 c0                	test   %eax,%eax
f0101140:	78 26                	js     f0101168 <monitor+0x137>
f0101142:	e9 20 ff ff ff       	jmp    f0101067 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0101147:	47                   	inc    %edi
f0101148:	83 c3 0c             	add    $0xc,%ebx
f010114b:	83 ff 09             	cmp    $0x9,%edi
f010114e:	75 c3                	jne    f0101113 <monitor+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0101150:	83 ec 08             	sub    $0x8,%esp
f0101153:	ff 75 a8             	pushl  -0x58(%ebp)
f0101156:	68 5e 6c 10 f0       	push   $0xf0106c5e
f010115b:	e8 fd 2b 00 00       	call   f0103d5d <cprintf>
f0101160:	83 c4 10             	add    $0x10,%esp
f0101163:	e9 ff fe ff ff       	jmp    f0101067 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0101168:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010116b:	5b                   	pop    %ebx
f010116c:	5e                   	pop    %esi
f010116d:	5f                   	pop    %edi
f010116e:	c9                   	leave  
f010116f:	c3                   	ret    

f0101170 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0101170:	55                   	push   %ebp
f0101171:	89 e5                	mov    %esp,%ebp
f0101173:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0101175:	83 3d 34 52 2e f0 00 	cmpl   $0x0,0xf02e5234
f010117c:	75 0f                	jne    f010118d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010117e:	b8 07 80 32 f0       	mov    $0xf0328007,%eax
f0101183:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101188:	a3 34 52 2e f0       	mov    %eax,0xf02e5234
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f010118d:	a1 34 52 2e f0       	mov    0xf02e5234,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0101192:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0101199:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010119f:	89 15 34 52 2e f0    	mov    %edx,0xf02e5234

	return result;
}
f01011a5:	c9                   	leave  
f01011a6:	c3                   	ret    

f01011a7 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01011a7:	55                   	push   %ebp
f01011a8:	89 e5                	mov    %esp,%ebp
f01011aa:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01011ad:	89 d1                	mov    %edx,%ecx
f01011af:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01011b2:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01011b5:	a8 01                	test   $0x1,%al
f01011b7:	74 42                	je     f01011fb <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01011b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011be:	89 c1                	mov    %eax,%ecx
f01011c0:	c1 e9 0c             	shr    $0xc,%ecx
f01011c3:	3b 0d 88 5e 2e f0    	cmp    0xf02e5e88,%ecx
f01011c9:	72 15                	jb     f01011e0 <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011cb:	50                   	push   %eax
f01011cc:	68 68 68 10 f0       	push   $0xf0106868
f01011d1:	68 79 03 00 00       	push   $0x379
f01011d6:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01011db:	e8 88 ee ff ff       	call   f0100068 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f01011e0:	c1 ea 0c             	shr    $0xc,%edx
f01011e3:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01011e9:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01011f0:	a8 01                	test   $0x1,%al
f01011f2:	74 0e                	je     f0101202 <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01011f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011f9:	eb 0c                	jmp    f0101207 <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01011fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101200:	eb 05                	jmp    f0101207 <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0101202:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0101207:	c9                   	leave  
f0101208:	c3                   	ret    

f0101209 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0101209:	55                   	push   %ebp
f010120a:	89 e5                	mov    %esp,%ebp
f010120c:	56                   	push   %esi
f010120d:	53                   	push   %ebx
f010120e:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101210:	83 ec 0c             	sub    $0xc,%esp
f0101213:	50                   	push   %eax
f0101214:	e8 03 2a 00 00       	call   f0103c1c <mc146818_read>
f0101219:	89 c6                	mov    %eax,%esi
f010121b:	43                   	inc    %ebx
f010121c:	89 1c 24             	mov    %ebx,(%esp)
f010121f:	e8 f8 29 00 00       	call   f0103c1c <mc146818_read>
f0101224:	c1 e0 08             	shl    $0x8,%eax
f0101227:	09 f0                	or     %esi,%eax
}
f0101229:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010122c:	5b                   	pop    %ebx
f010122d:	5e                   	pop    %esi
f010122e:	c9                   	leave  
f010122f:	c3                   	ret    

f0101230 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101230:	55                   	push   %ebp
f0101231:	89 e5                	mov    %esp,%ebp
f0101233:	57                   	push   %edi
f0101234:	56                   	push   %esi
f0101235:	53                   	push   %ebx
f0101236:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101239:	3c 01                	cmp    $0x1,%al
f010123b:	19 f6                	sbb    %esi,%esi
f010123d:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101243:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101244:	8b 1d 30 52 2e f0    	mov    0xf02e5230,%ebx
f010124a:	85 db                	test   %ebx,%ebx
f010124c:	75 17                	jne    f0101265 <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f010124e:	83 ec 04             	sub    $0x4,%esp
f0101251:	68 0c 73 10 f0       	push   $0xf010730c
f0101256:	68 ae 02 00 00       	push   $0x2ae
f010125b:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101260:	e8 03 ee ff ff       	call   f0100068 <_panic>

	if (only_low_memory) {
f0101265:	84 c0                	test   %al,%al
f0101267:	74 50                	je     f01012b9 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101269:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010126c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010126f:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101272:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101275:	89 d8                	mov    %ebx,%eax
f0101277:	2b 05 90 5e 2e f0    	sub    0xf02e5e90,%eax
f010127d:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101280:	c1 e8 16             	shr    $0x16,%eax
f0101283:	39 c6                	cmp    %eax,%esi
f0101285:	0f 96 c0             	setbe  %al
f0101288:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f010128b:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f010128f:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101291:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101295:	8b 1b                	mov    (%ebx),%ebx
f0101297:	85 db                	test   %ebx,%ebx
f0101299:	75 da                	jne    f0101275 <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f010129b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010129e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01012a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01012a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01012aa:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01012ac:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01012af:	89 1d 30 52 2e f0    	mov    %ebx,0xf02e5230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01012b5:	85 db                	test   %ebx,%ebx
f01012b7:	74 57                	je     f0101310 <check_page_free_list+0xe0>
f01012b9:	89 d8                	mov    %ebx,%eax
f01012bb:	2b 05 90 5e 2e f0    	sub    0xf02e5e90,%eax
f01012c1:	c1 f8 03             	sar    $0x3,%eax
f01012c4:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01012c7:	89 c2                	mov    %eax,%edx
f01012c9:	c1 ea 16             	shr    $0x16,%edx
f01012cc:	39 d6                	cmp    %edx,%esi
f01012ce:	76 3a                	jbe    f010130a <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012d0:	89 c2                	mov    %eax,%edx
f01012d2:	c1 ea 0c             	shr    $0xc,%edx
f01012d5:	3b 15 88 5e 2e f0    	cmp    0xf02e5e88,%edx
f01012db:	72 12                	jb     f01012ef <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012dd:	50                   	push   %eax
f01012de:	68 68 68 10 f0       	push   $0xf0106868
f01012e3:	6a 58                	push   $0x58
f01012e5:	68 dd 7b 10 f0       	push   $0xf0107bdd
f01012ea:	e8 79 ed ff ff       	call   f0100068 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01012ef:	83 ec 04             	sub    $0x4,%esp
f01012f2:	68 80 00 00 00       	push   $0x80
f01012f7:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01012fc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101301:	50                   	push   %eax
f0101302:	e8 1e 48 00 00       	call   f0105b25 <memset>
f0101307:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010130a:	8b 1b                	mov    (%ebx),%ebx
f010130c:	85 db                	test   %ebx,%ebx
f010130e:	75 a9                	jne    f01012b9 <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101310:	b8 00 00 00 00       	mov    $0x0,%eax
f0101315:	e8 56 fe ff ff       	call   f0101170 <boot_alloc>
f010131a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010131d:	8b 15 30 52 2e f0    	mov    0xf02e5230,%edx
f0101323:	85 d2                	test   %edx,%edx
f0101325:	0f 84 b2 01 00 00    	je     f01014dd <check_page_free_list+0x2ad>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010132b:	8b 1d 90 5e 2e f0    	mov    0xf02e5e90,%ebx
f0101331:	39 da                	cmp    %ebx,%edx
f0101333:	72 4b                	jb     f0101380 <check_page_free_list+0x150>
		assert(pp < pages + npages);
f0101335:	a1 88 5e 2e f0       	mov    0xf02e5e88,%eax
f010133a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010133d:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101340:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101343:	39 c2                	cmp    %eax,%edx
f0101345:	73 57                	jae    f010139e <check_page_free_list+0x16e>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101347:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f010134a:	89 d0                	mov    %edx,%eax
f010134c:	29 d8                	sub    %ebx,%eax
f010134e:	a8 07                	test   $0x7,%al
f0101350:	75 6e                	jne    f01013c0 <check_page_free_list+0x190>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101352:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101355:	c1 e0 0c             	shl    $0xc,%eax
f0101358:	0f 84 83 00 00 00    	je     f01013e1 <check_page_free_list+0x1b1>
		assert(page2pa(pp) != IOPHYSMEM);
f010135e:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101363:	0f 84 98 00 00 00    	je     f0101401 <check_page_free_list+0x1d1>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101369:	be 00 00 00 00       	mov    $0x0,%esi
f010136e:	bf 00 00 00 00       	mov    $0x0,%edi
f0101373:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f0101376:	e9 9f 00 00 00       	jmp    f010141a <check_page_free_list+0x1ea>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010137b:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f010137e:	73 19                	jae    f0101399 <check_page_free_list+0x169>
f0101380:	68 eb 7b 10 f0       	push   $0xf0107beb
f0101385:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010138a:	68 c8 02 00 00       	push   $0x2c8
f010138f:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101394:	e8 cf ec ff ff       	call   f0100068 <_panic>
		assert(pp < pages + npages);
f0101399:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f010139c:	72 19                	jb     f01013b7 <check_page_free_list+0x187>
f010139e:	68 0c 7c 10 f0       	push   $0xf0107c0c
f01013a3:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01013a8:	68 c9 02 00 00       	push   $0x2c9
f01013ad:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01013b2:	e8 b1 ec ff ff       	call   f0100068 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01013b7:	89 d0                	mov    %edx,%eax
f01013b9:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01013bc:	a8 07                	test   $0x7,%al
f01013be:	74 19                	je     f01013d9 <check_page_free_list+0x1a9>
f01013c0:	68 30 73 10 f0       	push   $0xf0107330
f01013c5:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01013ca:	68 ca 02 00 00       	push   $0x2ca
f01013cf:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01013d4:	e8 8f ec ff ff       	call   f0100068 <_panic>
f01013d9:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01013dc:	c1 e0 0c             	shl    $0xc,%eax
f01013df:	75 19                	jne    f01013fa <check_page_free_list+0x1ca>
f01013e1:	68 20 7c 10 f0       	push   $0xf0107c20
f01013e6:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01013eb:	68 cd 02 00 00       	push   $0x2cd
f01013f0:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01013f5:	e8 6e ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01013fa:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01013ff:	75 19                	jne    f010141a <check_page_free_list+0x1ea>
f0101401:	68 31 7c 10 f0       	push   $0xf0107c31
f0101406:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010140b:	68 ce 02 00 00       	push   $0x2ce
f0101410:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101415:	e8 4e ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010141a:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010141f:	75 19                	jne    f010143a <check_page_free_list+0x20a>
f0101421:	68 64 73 10 f0       	push   $0xf0107364
f0101426:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010142b:	68 cf 02 00 00       	push   $0x2cf
f0101430:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101435:	e8 2e ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010143a:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010143f:	75 19                	jne    f010145a <check_page_free_list+0x22a>
f0101441:	68 4a 7c 10 f0       	push   $0xf0107c4a
f0101446:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010144b:	68 d0 02 00 00       	push   $0x2d0
f0101450:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101455:	e8 0e ec ff ff       	call   f0100068 <_panic>
f010145a:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010145c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101461:	76 40                	jbe    f01014a3 <check_page_free_list+0x273>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101463:	89 c3                	mov    %eax,%ebx
f0101465:	c1 eb 0c             	shr    $0xc,%ebx
f0101468:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f010146b:	77 12                	ja     f010147f <check_page_free_list+0x24f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010146d:	50                   	push   %eax
f010146e:	68 68 68 10 f0       	push   $0xf0106868
f0101473:	6a 58                	push   $0x58
f0101475:	68 dd 7b 10 f0       	push   $0xf0107bdd
f010147a:	e8 e9 eb ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f010147f:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0101485:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0101488:	76 19                	jbe    f01014a3 <check_page_free_list+0x273>
f010148a:	68 88 73 10 f0       	push   $0xf0107388
f010148f:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101494:	68 d1 02 00 00       	push   $0x2d1
f0101499:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010149e:	e8 c5 eb ff ff       	call   f0100068 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01014a3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01014a8:	75 19                	jne    f01014c3 <check_page_free_list+0x293>
f01014aa:	68 64 7c 10 f0       	push   $0xf0107c64
f01014af:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01014b4:	68 d3 02 00 00       	push   $0x2d3
f01014b9:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01014be:	e8 a5 eb ff ff       	call   f0100068 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f01014c3:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f01014c9:	77 03                	ja     f01014ce <check_page_free_list+0x29e>
			++nfree_basemem;
f01014cb:	47                   	inc    %edi
f01014cc:	eb 01                	jmp    f01014cf <check_page_free_list+0x29f>
		else
			++nfree_extmem;
f01014ce:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01014cf:	8b 12                	mov    (%edx),%edx
f01014d1:	85 d2                	test   %edx,%edx
f01014d3:	0f 85 a2 fe ff ff    	jne    f010137b <check_page_free_list+0x14b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01014d9:	85 ff                	test   %edi,%edi
f01014db:	7f 19                	jg     f01014f6 <check_page_free_list+0x2c6>
f01014dd:	68 81 7c 10 f0       	push   $0xf0107c81
f01014e2:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01014e7:	68 db 02 00 00       	push   $0x2db
f01014ec:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01014f1:	e8 72 eb ff ff       	call   f0100068 <_panic>
	assert(nfree_extmem > 0);
f01014f6:	85 f6                	test   %esi,%esi
f01014f8:	7f 19                	jg     f0101513 <check_page_free_list+0x2e3>
f01014fa:	68 93 7c 10 f0       	push   $0xf0107c93
f01014ff:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101504:	68 dc 02 00 00       	push   $0x2dc
f0101509:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010150e:	e8 55 eb ff ff       	call   f0100068 <_panic>
}
f0101513:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101516:	5b                   	pop    %ebx
f0101517:	5e                   	pop    %esi
f0101518:	5f                   	pop    %edi
f0101519:	c9                   	leave  
f010151a:	c3                   	ret    

f010151b <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010151b:	55                   	push   %ebp
f010151c:	89 e5                	mov    %esp,%ebp
f010151e:	56                   	push   %esi
f010151f:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f0101520:	c7 05 30 52 2e f0 00 	movl   $0x0,0xf02e5230
f0101527:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f010152a:	b8 00 00 00 00       	mov    $0x0,%eax
f010152f:	e8 3c fc ff ff       	call   f0101170 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101534:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101539:	77 15                	ja     f0101550 <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010153b:	50                   	push   %eax
f010153c:	68 44 68 10 f0       	push   $0xf0106844
f0101541:	68 50 01 00 00       	push   $0x150
f0101546:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010154b:	e8 18 eb ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101550:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f0101556:	c1 ee 0c             	shr    $0xc,%esi
    size_t mpentry_page = MPENTRY_PADDR / PGSIZE;
    for (i = 0; i < npages; i++) {
f0101559:	83 3d 88 5e 2e f0 00 	cmpl   $0x0,0xf02e5e88
f0101560:	74 64                	je     f01015c6 <page_init+0xab>
f0101562:	8b 1d 30 52 2e f0    	mov    0xf02e5230,%ebx
f0101568:	ba 00 00 00 00       	mov    $0x0,%edx
f010156d:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub) && i != mpentry_page) {
f0101572:	85 c0                	test   %eax,%eax
f0101574:	74 2a                	je     f01015a0 <page_init+0x85>
f0101576:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f010157b:	76 04                	jbe    f0101581 <page_init+0x66>
f010157d:	39 c6                	cmp    %eax,%esi
f010157f:	77 1f                	ja     f01015a0 <page_init+0x85>
f0101581:	83 f8 07             	cmp    $0x7,%eax
f0101584:	74 1a                	je     f01015a0 <page_init+0x85>
		    pages[i].pp_ref = 0;
f0101586:	89 d1                	mov    %edx,%ecx
f0101588:	03 0d 90 5e 2e f0    	add    0xf02e5e90,%ecx
f010158e:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f0101594:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f0101596:	89 d3                	mov    %edx,%ebx
f0101598:	03 1d 90 5e 2e f0    	add    0xf02e5e90,%ebx
f010159e:	eb 14                	jmp    f01015b4 <page_init+0x99>
        } else {
            pages[i].pp_ref = 1;
f01015a0:	89 d1                	mov    %edx,%ecx
f01015a2:	03 0d 90 5e 2e f0    	add    0xf02e5e90,%ecx
f01015a8:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f01015ae:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    size_t mpentry_page = MPENTRY_PADDR / PGSIZE;
    for (i = 0; i < npages; i++) {
f01015b4:	40                   	inc    %eax
f01015b5:	83 c2 08             	add    $0x8,%edx
f01015b8:	39 05 88 5e 2e f0    	cmp    %eax,0xf02e5e88
f01015be:	77 b2                	ja     f0101572 <page_init+0x57>
f01015c0:	89 1d 30 52 2e f0    	mov    %ebx,0xf02e5230
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f01015c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01015c9:	5b                   	pop    %ebx
f01015ca:	5e                   	pop    %esi
f01015cb:	c9                   	leave  
f01015cc:	c3                   	ret    

f01015cd <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01015cd:	55                   	push   %ebp
f01015ce:	89 e5                	mov    %esp,%ebp
f01015d0:	53                   	push   %ebx
f01015d1:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
    while (page_free_list && page_free_list->pp_ref != 0) 
f01015d4:	8b 1d 30 52 2e f0    	mov    0xf02e5230,%ebx
f01015da:	85 db                	test   %ebx,%ebx
f01015dc:	74 63                	je     f0101641 <page_alloc+0x74>
f01015de:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01015e3:	74 63                	je     f0101648 <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f01015e5:	8b 1b                	mov    (%ebx),%ebx
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
    while (page_free_list && page_free_list->pp_ref != 0) 
f01015e7:	85 db                	test   %ebx,%ebx
f01015e9:	75 08                	jne    f01015f3 <page_alloc+0x26>
f01015eb:	89 1d 30 52 2e f0    	mov    %ebx,0xf02e5230
f01015f1:	eb 4e                	jmp    f0101641 <page_alloc+0x74>
f01015f3:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01015f8:	75 eb                	jne    f01015e5 <page_alloc+0x18>
f01015fa:	eb 4c                	jmp    f0101648 <page_alloc+0x7b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015fc:	89 d8                	mov    %ebx,%eax
f01015fe:	2b 05 90 5e 2e f0    	sub    0xf02e5e90,%eax
f0101604:	c1 f8 03             	sar    $0x3,%eax
f0101607:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010160a:	89 c2                	mov    %eax,%edx
f010160c:	c1 ea 0c             	shr    $0xc,%edx
f010160f:	3b 15 88 5e 2e f0    	cmp    0xf02e5e88,%edx
f0101615:	72 12                	jb     f0101629 <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101617:	50                   	push   %eax
f0101618:	68 68 68 10 f0       	push   $0xf0106868
f010161d:	6a 58                	push   $0x58
f010161f:	68 dd 7b 10 f0       	push   $0xf0107bdd
f0101624:	e8 3f ea ff ff       	call   f0100068 <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f0101629:	83 ec 04             	sub    $0x4,%esp
f010162c:	68 00 10 00 00       	push   $0x1000
f0101631:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101633:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101638:	50                   	push   %eax
f0101639:	e8 e7 44 00 00       	call   f0105b25 <memset>
f010163e:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f0101641:	89 d8                	mov    %ebx,%eax
f0101643:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101646:	c9                   	leave  
f0101647:	c3                   	ret    

    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f0101648:	8b 03                	mov    (%ebx),%eax
f010164a:	a3 30 52 2e f0       	mov    %eax,0xf02e5230
        if (alloc_flags & ALLOC_ZERO) {
f010164f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101653:	74 ec                	je     f0101641 <page_alloc+0x74>
f0101655:	eb a5                	jmp    f01015fc <page_alloc+0x2f>

f0101657 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101657:	55                   	push   %ebp
f0101658:	89 e5                	mov    %esp,%ebp
f010165a:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f010165d:	85 c0                	test   %eax,%eax
f010165f:	74 14                	je     f0101675 <page_free+0x1e>
f0101661:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101666:	75 0d                	jne    f0101675 <page_free+0x1e>
    pp->pp_link = page_free_list;
f0101668:	8b 15 30 52 2e f0    	mov    0xf02e5230,%edx
f010166e:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0101670:	a3 30 52 2e f0       	mov    %eax,0xf02e5230
}
f0101675:	c9                   	leave  
f0101676:	c3                   	ret    

f0101677 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101677:	55                   	push   %ebp
f0101678:	89 e5                	mov    %esp,%ebp
f010167a:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010167d:	8b 50 04             	mov    0x4(%eax),%edx
f0101680:	4a                   	dec    %edx
f0101681:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101685:	66 85 d2             	test   %dx,%dx
f0101688:	75 09                	jne    f0101693 <page_decref+0x1c>
		page_free(pp);
f010168a:	50                   	push   %eax
f010168b:	e8 c7 ff ff ff       	call   f0101657 <page_free>
f0101690:	83 c4 04             	add    $0x4,%esp
}
f0101693:	c9                   	leave  
f0101694:	c3                   	ret    

f0101695 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101695:	55                   	push   %ebp
f0101696:	89 e5                	mov    %esp,%ebp
f0101698:	56                   	push   %esi
f0101699:	53                   	push   %ebx
f010169a:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f010169d:	89 f3                	mov    %esi,%ebx
f010169f:	c1 eb 16             	shr    $0x16,%ebx
f01016a2:	c1 e3 02             	shl    $0x2,%ebx
f01016a5:	03 5d 08             	add    0x8(%ebp),%ebx
f01016a8:	8b 03                	mov    (%ebx),%eax
f01016aa:	85 c0                	test   %eax,%eax
f01016ac:	74 04                	je     f01016b2 <pgdir_walk+0x1d>
f01016ae:	a8 01                	test   $0x1,%al
f01016b0:	75 2c                	jne    f01016de <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f01016b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01016b6:	74 61                	je     f0101719 <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(1);
f01016b8:	83 ec 0c             	sub    $0xc,%esp
f01016bb:	6a 01                	push   $0x1
f01016bd:	e8 0b ff ff ff       	call   f01015cd <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f01016c2:	83 c4 10             	add    $0x10,%esp
f01016c5:	85 c0                	test   %eax,%eax
f01016c7:	74 57                	je     f0101720 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f01016c9:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016cd:	2b 05 90 5e 2e f0    	sub    0xf02e5e90,%eax
f01016d3:	c1 f8 03             	sar    $0x3,%eax
f01016d6:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f01016d9:	83 c8 07             	or     $0x7,%eax
f01016dc:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f01016de:	8b 03                	mov    (%ebx),%eax
f01016e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016e5:	89 c2                	mov    %eax,%edx
f01016e7:	c1 ea 0c             	shr    $0xc,%edx
f01016ea:	3b 15 88 5e 2e f0    	cmp    0xf02e5e88,%edx
f01016f0:	72 15                	jb     f0101707 <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016f2:	50                   	push   %eax
f01016f3:	68 68 68 10 f0       	push   $0xf0106868
f01016f8:	68 b4 01 00 00       	push   $0x1b4
f01016fd:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101702:	e8 61 e9 ff ff       	call   f0100068 <_panic>
f0101707:	c1 ee 0a             	shr    $0xa,%esi
f010170a:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101710:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101717:	eb 0c                	jmp    f0101725 <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f0101719:	b8 00 00 00 00       	mov    $0x0,%eax
f010171e:	eb 05                	jmp    f0101725 <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f0101720:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f0101725:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101728:	5b                   	pop    %ebx
f0101729:	5e                   	pop    %esi
f010172a:	c9                   	leave  
f010172b:	c3                   	ret    

f010172c <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010172c:	55                   	push   %ebp
f010172d:	89 e5                	mov    %esp,%ebp
f010172f:	57                   	push   %edi
f0101730:	56                   	push   %esi
f0101731:	53                   	push   %ebx
f0101732:	83 ec 1c             	sub    $0x1c,%esp
f0101735:	89 c7                	mov    %eax,%edi
f0101737:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f010173a:	01 d1                	add    %edx,%ecx
f010173c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010173f:	39 ca                	cmp    %ecx,%edx
f0101741:	74 32                	je     f0101775 <boot_map_region+0x49>
f0101743:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f0101745:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101748:	83 c8 01             	or     $0x1,%eax
f010174b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f010174e:	83 ec 04             	sub    $0x4,%esp
f0101751:	6a 01                	push   $0x1
f0101753:	53                   	push   %ebx
f0101754:	57                   	push   %edi
f0101755:	e8 3b ff ff ff       	call   f0101695 <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f010175a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010175d:	09 f2                	or     %esi,%edx
f010175f:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101761:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101767:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010176d:	83 c4 10             	add    $0x10,%esp
f0101770:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101773:	75 d9                	jne    f010174e <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f0101775:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101778:	5b                   	pop    %ebx
f0101779:	5e                   	pop    %esi
f010177a:	5f                   	pop    %edi
f010177b:	c9                   	leave  
f010177c:	c3                   	ret    

f010177d <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010177d:	55                   	push   %ebp
f010177e:	89 e5                	mov    %esp,%ebp
f0101780:	53                   	push   %ebx
f0101781:	83 ec 08             	sub    $0x8,%esp
f0101784:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f0101787:	6a 00                	push   $0x0
f0101789:	ff 75 0c             	pushl  0xc(%ebp)
f010178c:	ff 75 08             	pushl  0x8(%ebp)
f010178f:	e8 01 ff ff ff       	call   f0101695 <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0101794:	83 c4 10             	add    $0x10,%esp
f0101797:	85 c0                	test   %eax,%eax
f0101799:	74 37                	je     f01017d2 <page_lookup+0x55>
f010179b:	f6 00 01             	testb  $0x1,(%eax)
f010179e:	74 39                	je     f01017d9 <page_lookup+0x5c>
    if (pte_store != 0) {
f01017a0:	85 db                	test   %ebx,%ebx
f01017a2:	74 02                	je     f01017a6 <page_lookup+0x29>
        *pte_store = pte;
f01017a4:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f01017a6:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017a8:	c1 e8 0c             	shr    $0xc,%eax
f01017ab:	3b 05 88 5e 2e f0    	cmp    0xf02e5e88,%eax
f01017b1:	72 14                	jb     f01017c7 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01017b3:	83 ec 04             	sub    $0x4,%esp
f01017b6:	68 d0 73 10 f0       	push   $0xf01073d0
f01017bb:	6a 51                	push   $0x51
f01017bd:	68 dd 7b 10 f0       	push   $0xf0107bdd
f01017c2:	e8 a1 e8 ff ff       	call   f0100068 <_panic>
	return &pages[PGNUM(pa)];
f01017c7:	c1 e0 03             	shl    $0x3,%eax
f01017ca:	03 05 90 5e 2e f0    	add    0xf02e5e90,%eax
f01017d0:	eb 0c                	jmp    f01017de <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01017d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01017d7:	eb 05                	jmp    f01017de <page_lookup+0x61>
f01017d9:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f01017de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01017e1:	c9                   	leave  
f01017e2:	c3                   	ret    

f01017e3 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01017e3:	55                   	push   %ebp
f01017e4:	89 e5                	mov    %esp,%ebp
f01017e6:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01017e9:	e8 66 49 00 00       	call   f0106154 <cpunum>
f01017ee:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01017f5:	29 c2                	sub    %eax,%edx
f01017f7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01017fa:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f0101801:	00 
f0101802:	74 20                	je     f0101824 <tlb_invalidate+0x41>
f0101804:	e8 4b 49 00 00       	call   f0106154 <cpunum>
f0101809:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101810:	29 c2                	sub    %eax,%edx
f0101812:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0101815:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f010181c:	8b 55 08             	mov    0x8(%ebp),%edx
f010181f:	39 50 60             	cmp    %edx,0x60(%eax)
f0101822:	75 06                	jne    f010182a <tlb_invalidate+0x47>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101824:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101827:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010182a:	c9                   	leave  
f010182b:	c3                   	ret    

f010182c <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010182c:	55                   	push   %ebp
f010182d:	89 e5                	mov    %esp,%ebp
f010182f:	56                   	push   %esi
f0101830:	53                   	push   %ebx
f0101831:	83 ec 14             	sub    $0x14,%esp
f0101834:	8b 75 08             	mov    0x8(%ebp),%esi
f0101837:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f010183a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010183d:	50                   	push   %eax
f010183e:	53                   	push   %ebx
f010183f:	56                   	push   %esi
f0101840:	e8 38 ff ff ff       	call   f010177d <page_lookup>
    if (pg == NULL) return;
f0101845:	83 c4 10             	add    $0x10,%esp
f0101848:	85 c0                	test   %eax,%eax
f010184a:	74 26                	je     f0101872 <page_remove+0x46>
    page_decref(pg);
f010184c:	83 ec 0c             	sub    $0xc,%esp
f010184f:	50                   	push   %eax
f0101850:	e8 22 fe ff ff       	call   f0101677 <page_decref>
    if (pte != NULL) *pte = 0;
f0101855:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101858:	83 c4 10             	add    $0x10,%esp
f010185b:	85 c0                	test   %eax,%eax
f010185d:	74 06                	je     f0101865 <page_remove+0x39>
f010185f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f0101865:	83 ec 08             	sub    $0x8,%esp
f0101868:	53                   	push   %ebx
f0101869:	56                   	push   %esi
f010186a:	e8 74 ff ff ff       	call   f01017e3 <tlb_invalidate>
f010186f:	83 c4 10             	add    $0x10,%esp
}
f0101872:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101875:	5b                   	pop    %ebx
f0101876:	5e                   	pop    %esi
f0101877:	c9                   	leave  
f0101878:	c3                   	ret    

f0101879 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101879:	55                   	push   %ebp
f010187a:	89 e5                	mov    %esp,%ebp
f010187c:	57                   	push   %edi
f010187d:	56                   	push   %esi
f010187e:	53                   	push   %ebx
f010187f:	83 ec 10             	sub    $0x10,%esp
f0101882:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101885:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f0101888:	6a 01                	push   $0x1
f010188a:	57                   	push   %edi
f010188b:	ff 75 08             	pushl  0x8(%ebp)
f010188e:	e8 02 fe ff ff       	call   f0101695 <pgdir_walk>
f0101893:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f0101895:	83 c4 10             	add    $0x10,%esp
f0101898:	85 c0                	test   %eax,%eax
f010189a:	74 39                	je     f01018d5 <page_insert+0x5c>
    ++pp->pp_ref;
f010189c:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f01018a0:	f6 00 01             	testb  $0x1,(%eax)
f01018a3:	74 0f                	je     f01018b4 <page_insert+0x3b>
        page_remove(pgdir, va);
f01018a5:	83 ec 08             	sub    $0x8,%esp
f01018a8:	57                   	push   %edi
f01018a9:	ff 75 08             	pushl  0x8(%ebp)
f01018ac:	e8 7b ff ff ff       	call   f010182c <page_remove>
f01018b1:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f01018b4:	8b 55 14             	mov    0x14(%ebp),%edx
f01018b7:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018ba:	2b 35 90 5e 2e f0    	sub    0xf02e5e90,%esi
f01018c0:	c1 fe 03             	sar    $0x3,%esi
f01018c3:	89 f0                	mov    %esi,%eax
f01018c5:	c1 e0 0c             	shl    $0xc,%eax
f01018c8:	89 d6                	mov    %edx,%esi
f01018ca:	09 c6                	or     %eax,%esi
f01018cc:	89 33                	mov    %esi,(%ebx)
	return 0;
f01018ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01018d3:	eb 05                	jmp    f01018da <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f01018d5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f01018da:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01018dd:	5b                   	pop    %ebx
f01018de:	5e                   	pop    %esi
f01018df:	5f                   	pop    %edi
f01018e0:	c9                   	leave  
f01018e1:	c3                   	ret    

f01018e2 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01018e2:	55                   	push   %ebp
f01018e3:	89 e5                	mov    %esp,%ebp
f01018e5:	53                   	push   %ebx
f01018e6:	83 ec 0c             	sub    $0xc,%esp
f01018e9:	8b 45 08             	mov    0x8(%ebp),%eax
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	uint32_t ed = ROUNDUP(pa + size, PGSIZE);
f01018ec:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01018f2:	03 5d 0c             	add    0xc(%ebp),%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
f01018f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	uint32_t ed = ROUNDUP(pa + size, PGSIZE);
f01018fa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
	boot_map_region(kern_pgdir, base, ed - pa, pa, PTE_PCD | PTE_PWT | PTE_W);
f0101900:	29 c3                	sub    %eax,%ebx
f0101902:	6a 1a                	push   $0x1a
f0101904:	50                   	push   %eax
f0101905:	89 d9                	mov    %ebx,%ecx
f0101907:	8b 15 00 83 12 f0    	mov    0xf0128300,%edx
f010190d:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0101912:	e8 15 fe ff ff       	call   f010172c <boot_map_region>
	uintptr_t tmp_base = base;
f0101917:	a1 00 83 12 f0       	mov    0xf0128300,%eax
	base += ed - pa;
f010191c:	01 c3                	add    %eax,%ebx
f010191e:	89 1d 00 83 12 f0    	mov    %ebx,0xf0128300
	return (void *) tmp_base;
	panic("mmio_map_region not implemented");
}
f0101924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101927:	c9                   	leave  
f0101928:	c3                   	ret    

f0101929 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101929:	55                   	push   %ebp
f010192a:	89 e5                	mov    %esp,%ebp
f010192c:	57                   	push   %edi
f010192d:	56                   	push   %esi
f010192e:	53                   	push   %ebx
f010192f:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101932:	b8 15 00 00 00       	mov    $0x15,%eax
f0101937:	e8 cd f8 ff ff       	call   f0101209 <nvram_read>
f010193c:	c1 e0 0a             	shl    $0xa,%eax
f010193f:	89 c2                	mov    %eax,%edx
f0101941:	85 c0                	test   %eax,%eax
f0101943:	79 06                	jns    f010194b <mem_init+0x22>
f0101945:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010194b:	c1 fa 0c             	sar    $0xc,%edx
f010194e:	89 15 38 52 2e f0    	mov    %edx,0xf02e5238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101954:	b8 17 00 00 00       	mov    $0x17,%eax
f0101959:	e8 ab f8 ff ff       	call   f0101209 <nvram_read>
f010195e:	89 c2                	mov    %eax,%edx
f0101960:	c1 e2 0a             	shl    $0xa,%edx
f0101963:	89 d0                	mov    %edx,%eax
f0101965:	85 d2                	test   %edx,%edx
f0101967:	79 06                	jns    f010196f <mem_init+0x46>
f0101969:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010196f:	c1 f8 0c             	sar    $0xc,%eax
f0101972:	74 0e                	je     f0101982 <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101974:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010197a:	89 15 88 5e 2e f0    	mov    %edx,0xf02e5e88
f0101980:	eb 0c                	jmp    f010198e <mem_init+0x65>
	else
		npages = npages_basemem;
f0101982:	8b 15 38 52 2e f0    	mov    0xf02e5238,%edx
f0101988:	89 15 88 5e 2e f0    	mov    %edx,0xf02e5e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010198e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101991:	c1 e8 0a             	shr    $0xa,%eax
f0101994:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101995:	a1 38 52 2e f0       	mov    0xf02e5238,%eax
f010199a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010199d:	c1 e8 0a             	shr    $0xa,%eax
f01019a0:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01019a1:	a1 88 5e 2e f0       	mov    0xf02e5e88,%eax
f01019a6:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01019a9:	c1 e8 0a             	shr    $0xa,%eax
f01019ac:	50                   	push   %eax
f01019ad:	68 f0 73 10 f0       	push   $0xf01073f0
f01019b2:	e8 a6 23 00 00       	call   f0103d5d <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01019b7:	b8 00 10 00 00       	mov    $0x1000,%eax
f01019bc:	e8 af f7 ff ff       	call   f0101170 <boot_alloc>
f01019c1:	a3 8c 5e 2e f0       	mov    %eax,0xf02e5e8c
	memset(kern_pgdir, 0, PGSIZE);
f01019c6:	83 c4 0c             	add    $0xc,%esp
f01019c9:	68 00 10 00 00       	push   $0x1000
f01019ce:	6a 00                	push   $0x0
f01019d0:	50                   	push   %eax
f01019d1:	e8 4f 41 00 00       	call   f0105b25 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01019d6:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01019db:	83 c4 10             	add    $0x10,%esp
f01019de:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01019e3:	77 15                	ja     f01019fa <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01019e5:	50                   	push   %eax
f01019e6:	68 44 68 10 f0       	push   $0xf0106844
f01019eb:	68 90 00 00 00       	push   $0x90
f01019f0:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01019f5:	e8 6e e6 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01019fa:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101a00:	83 ca 05             	or     $0x5,%edx
f0101a03:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101a09:	a1 88 5e 2e f0       	mov    0xf02e5e88,%eax
f0101a0e:	c1 e0 03             	shl    $0x3,%eax
f0101a11:	e8 5a f7 ff ff       	call   f0101170 <boot_alloc>
f0101a16:	a3 90 5e 2e f0       	mov    %eax,0xf02e5e90
    

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101a1b:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101a20:	e8 4b f7 ff ff       	call   f0101170 <boot_alloc>
f0101a25:	a3 3c 52 2e f0       	mov    %eax,0xf02e523c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101a2a:	e8 ec fa ff ff       	call   f010151b <page_init>

	check_page_free_list(1);
f0101a2f:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a34:	e8 f7 f7 ff ff       	call   f0101230 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101a39:	83 3d 90 5e 2e f0 00 	cmpl   $0x0,0xf02e5e90
f0101a40:	75 17                	jne    f0101a59 <mem_init+0x130>
		panic("'pages' is a null pointer!");
f0101a42:	83 ec 04             	sub    $0x4,%esp
f0101a45:	68 a4 7c 10 f0       	push   $0xf0107ca4
f0101a4a:	68 ed 02 00 00       	push   $0x2ed
f0101a4f:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101a54:	e8 0f e6 ff ff       	call   f0100068 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a59:	a1 30 52 2e f0       	mov    0xf02e5230,%eax
f0101a5e:	85 c0                	test   %eax,%eax
f0101a60:	74 0e                	je     f0101a70 <mem_init+0x147>
f0101a62:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101a67:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a68:	8b 00                	mov    (%eax),%eax
f0101a6a:	85 c0                	test   %eax,%eax
f0101a6c:	75 f9                	jne    f0101a67 <mem_init+0x13e>
f0101a6e:	eb 05                	jmp    f0101a75 <mem_init+0x14c>
f0101a70:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a75:	83 ec 0c             	sub    $0xc,%esp
f0101a78:	6a 00                	push   $0x0
f0101a7a:	e8 4e fb ff ff       	call   f01015cd <page_alloc>
f0101a7f:	89 c6                	mov    %eax,%esi
f0101a81:	83 c4 10             	add    $0x10,%esp
f0101a84:	85 c0                	test   %eax,%eax
f0101a86:	75 19                	jne    f0101aa1 <mem_init+0x178>
f0101a88:	68 bf 7c 10 f0       	push   $0xf0107cbf
f0101a8d:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101a92:	68 f5 02 00 00       	push   $0x2f5
f0101a97:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101a9c:	e8 c7 e5 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101aa1:	83 ec 0c             	sub    $0xc,%esp
f0101aa4:	6a 00                	push   $0x0
f0101aa6:	e8 22 fb ff ff       	call   f01015cd <page_alloc>
f0101aab:	89 c7                	mov    %eax,%edi
f0101aad:	83 c4 10             	add    $0x10,%esp
f0101ab0:	85 c0                	test   %eax,%eax
f0101ab2:	75 19                	jne    f0101acd <mem_init+0x1a4>
f0101ab4:	68 d5 7c 10 f0       	push   $0xf0107cd5
f0101ab9:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101abe:	68 f6 02 00 00       	push   $0x2f6
f0101ac3:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101ac8:	e8 9b e5 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101acd:	83 ec 0c             	sub    $0xc,%esp
f0101ad0:	6a 00                	push   $0x0
f0101ad2:	e8 f6 fa ff ff       	call   f01015cd <page_alloc>
f0101ad7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ada:	83 c4 10             	add    $0x10,%esp
f0101add:	85 c0                	test   %eax,%eax
f0101adf:	75 19                	jne    f0101afa <mem_init+0x1d1>
f0101ae1:	68 eb 7c 10 f0       	push   $0xf0107ceb
f0101ae6:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101aeb:	68 f7 02 00 00       	push   $0x2f7
f0101af0:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101af5:	e8 6e e5 ff ff       	call   f0100068 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101afa:	39 fe                	cmp    %edi,%esi
f0101afc:	75 19                	jne    f0101b17 <mem_init+0x1ee>
f0101afe:	68 01 7d 10 f0       	push   $0xf0107d01
f0101b03:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101b08:	68 fa 02 00 00       	push   $0x2fa
f0101b0d:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101b12:	e8 51 e5 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b17:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101b1a:	74 05                	je     f0101b21 <mem_init+0x1f8>
f0101b1c:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101b1f:	75 19                	jne    f0101b3a <mem_init+0x211>
f0101b21:	68 2c 74 10 f0       	push   $0xf010742c
f0101b26:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101b2b:	68 fb 02 00 00       	push   $0x2fb
f0101b30:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101b35:	e8 2e e5 ff ff       	call   f0100068 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b3a:	8b 15 90 5e 2e f0    	mov    0xf02e5e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101b40:	a1 88 5e 2e f0       	mov    0xf02e5e88,%eax
f0101b45:	c1 e0 0c             	shl    $0xc,%eax
f0101b48:	89 f1                	mov    %esi,%ecx
f0101b4a:	29 d1                	sub    %edx,%ecx
f0101b4c:	c1 f9 03             	sar    $0x3,%ecx
f0101b4f:	c1 e1 0c             	shl    $0xc,%ecx
f0101b52:	39 c1                	cmp    %eax,%ecx
f0101b54:	72 19                	jb     f0101b6f <mem_init+0x246>
f0101b56:	68 13 7d 10 f0       	push   $0xf0107d13
f0101b5b:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101b60:	68 fc 02 00 00       	push   $0x2fc
f0101b65:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101b6a:	e8 f9 e4 ff ff       	call   f0100068 <_panic>
f0101b6f:	89 f9                	mov    %edi,%ecx
f0101b71:	29 d1                	sub    %edx,%ecx
f0101b73:	c1 f9 03             	sar    $0x3,%ecx
f0101b76:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101b79:	39 c8                	cmp    %ecx,%eax
f0101b7b:	77 19                	ja     f0101b96 <mem_init+0x26d>
f0101b7d:	68 30 7d 10 f0       	push   $0xf0107d30
f0101b82:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101b87:	68 fd 02 00 00       	push   $0x2fd
f0101b8c:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101b91:	e8 d2 e4 ff ff       	call   f0100068 <_panic>
f0101b96:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b99:	29 d1                	sub    %edx,%ecx
f0101b9b:	89 ca                	mov    %ecx,%edx
f0101b9d:	c1 fa 03             	sar    $0x3,%edx
f0101ba0:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101ba3:	39 d0                	cmp    %edx,%eax
f0101ba5:	77 19                	ja     f0101bc0 <mem_init+0x297>
f0101ba7:	68 4d 7d 10 f0       	push   $0xf0107d4d
f0101bac:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101bb1:	68 fe 02 00 00       	push   $0x2fe
f0101bb6:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101bbb:	e8 a8 e4 ff ff       	call   f0100068 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101bc0:	a1 30 52 2e f0       	mov    0xf02e5230,%eax
f0101bc5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101bc8:	c7 05 30 52 2e f0 00 	movl   $0x0,0xf02e5230
f0101bcf:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101bd2:	83 ec 0c             	sub    $0xc,%esp
f0101bd5:	6a 00                	push   $0x0
f0101bd7:	e8 f1 f9 ff ff       	call   f01015cd <page_alloc>
f0101bdc:	83 c4 10             	add    $0x10,%esp
f0101bdf:	85 c0                	test   %eax,%eax
f0101be1:	74 19                	je     f0101bfc <mem_init+0x2d3>
f0101be3:	68 6a 7d 10 f0       	push   $0xf0107d6a
f0101be8:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101bed:	68 05 03 00 00       	push   $0x305
f0101bf2:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101bf7:	e8 6c e4 ff ff       	call   f0100068 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101bfc:	83 ec 0c             	sub    $0xc,%esp
f0101bff:	56                   	push   %esi
f0101c00:	e8 52 fa ff ff       	call   f0101657 <page_free>
	page_free(pp1);
f0101c05:	89 3c 24             	mov    %edi,(%esp)
f0101c08:	e8 4a fa ff ff       	call   f0101657 <page_free>
	page_free(pp2);
f0101c0d:	83 c4 04             	add    $0x4,%esp
f0101c10:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c13:	e8 3f fa ff ff       	call   f0101657 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c1f:	e8 a9 f9 ff ff       	call   f01015cd <page_alloc>
f0101c24:	89 c6                	mov    %eax,%esi
f0101c26:	83 c4 10             	add    $0x10,%esp
f0101c29:	85 c0                	test   %eax,%eax
f0101c2b:	75 19                	jne    f0101c46 <mem_init+0x31d>
f0101c2d:	68 bf 7c 10 f0       	push   $0xf0107cbf
f0101c32:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101c37:	68 0c 03 00 00       	push   $0x30c
f0101c3c:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101c41:	e8 22 e4 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c46:	83 ec 0c             	sub    $0xc,%esp
f0101c49:	6a 00                	push   $0x0
f0101c4b:	e8 7d f9 ff ff       	call   f01015cd <page_alloc>
f0101c50:	89 c7                	mov    %eax,%edi
f0101c52:	83 c4 10             	add    $0x10,%esp
f0101c55:	85 c0                	test   %eax,%eax
f0101c57:	75 19                	jne    f0101c72 <mem_init+0x349>
f0101c59:	68 d5 7c 10 f0       	push   $0xf0107cd5
f0101c5e:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101c63:	68 0d 03 00 00       	push   $0x30d
f0101c68:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101c6d:	e8 f6 e3 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c72:	83 ec 0c             	sub    $0xc,%esp
f0101c75:	6a 00                	push   $0x0
f0101c77:	e8 51 f9 ff ff       	call   f01015cd <page_alloc>
f0101c7c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c7f:	83 c4 10             	add    $0x10,%esp
f0101c82:	85 c0                	test   %eax,%eax
f0101c84:	75 19                	jne    f0101c9f <mem_init+0x376>
f0101c86:	68 eb 7c 10 f0       	push   $0xf0107ceb
f0101c8b:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101c90:	68 0e 03 00 00       	push   $0x30e
f0101c95:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101c9a:	e8 c9 e3 ff ff       	call   f0100068 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c9f:	39 fe                	cmp    %edi,%esi
f0101ca1:	75 19                	jne    f0101cbc <mem_init+0x393>
f0101ca3:	68 01 7d 10 f0       	push   $0xf0107d01
f0101ca8:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101cad:	68 10 03 00 00       	push   $0x310
f0101cb2:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101cb7:	e8 ac e3 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cbc:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101cbf:	74 05                	je     f0101cc6 <mem_init+0x39d>
f0101cc1:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101cc4:	75 19                	jne    f0101cdf <mem_init+0x3b6>
f0101cc6:	68 2c 74 10 f0       	push   $0xf010742c
f0101ccb:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101cd0:	68 11 03 00 00       	push   $0x311
f0101cd5:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101cda:	e8 89 e3 ff ff       	call   f0100068 <_panic>
	assert(!page_alloc(0));
f0101cdf:	83 ec 0c             	sub    $0xc,%esp
f0101ce2:	6a 00                	push   $0x0
f0101ce4:	e8 e4 f8 ff ff       	call   f01015cd <page_alloc>
f0101ce9:	83 c4 10             	add    $0x10,%esp
f0101cec:	85 c0                	test   %eax,%eax
f0101cee:	74 19                	je     f0101d09 <mem_init+0x3e0>
f0101cf0:	68 6a 7d 10 f0       	push   $0xf0107d6a
f0101cf5:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101cfa:	68 12 03 00 00       	push   $0x312
f0101cff:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101d04:	e8 5f e3 ff ff       	call   f0100068 <_panic>
f0101d09:	89 f0                	mov    %esi,%eax
f0101d0b:	2b 05 90 5e 2e f0    	sub    0xf02e5e90,%eax
f0101d11:	c1 f8 03             	sar    $0x3,%eax
f0101d14:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d17:	89 c2                	mov    %eax,%edx
f0101d19:	c1 ea 0c             	shr    $0xc,%edx
f0101d1c:	3b 15 88 5e 2e f0    	cmp    0xf02e5e88,%edx
f0101d22:	72 12                	jb     f0101d36 <mem_init+0x40d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d24:	50                   	push   %eax
f0101d25:	68 68 68 10 f0       	push   $0xf0106868
f0101d2a:	6a 58                	push   $0x58
f0101d2c:	68 dd 7b 10 f0       	push   $0xf0107bdd
f0101d31:	e8 32 e3 ff ff       	call   f0100068 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101d36:	83 ec 04             	sub    $0x4,%esp
f0101d39:	68 00 10 00 00       	push   $0x1000
f0101d3e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101d40:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d45:	50                   	push   %eax
f0101d46:	e8 da 3d 00 00       	call   f0105b25 <memset>
	page_free(pp0);
f0101d4b:	89 34 24             	mov    %esi,(%esp)
f0101d4e:	e8 04 f9 ff ff       	call   f0101657 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101d5a:	e8 6e f8 ff ff       	call   f01015cd <page_alloc>
f0101d5f:	83 c4 10             	add    $0x10,%esp
f0101d62:	85 c0                	test   %eax,%eax
f0101d64:	75 19                	jne    f0101d7f <mem_init+0x456>
f0101d66:	68 79 7d 10 f0       	push   $0xf0107d79
f0101d6b:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101d70:	68 17 03 00 00       	push   $0x317
f0101d75:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101d7a:	e8 e9 e2 ff ff       	call   f0100068 <_panic>
	assert(pp && pp0 == pp);
f0101d7f:	39 c6                	cmp    %eax,%esi
f0101d81:	74 19                	je     f0101d9c <mem_init+0x473>
f0101d83:	68 97 7d 10 f0       	push   $0xf0107d97
f0101d88:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101d8d:	68 18 03 00 00       	push   $0x318
f0101d92:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101d97:	e8 cc e2 ff ff       	call   f0100068 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d9c:	89 f2                	mov    %esi,%edx
f0101d9e:	2b 15 90 5e 2e f0    	sub    0xf02e5e90,%edx
f0101da4:	c1 fa 03             	sar    $0x3,%edx
f0101da7:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101daa:	89 d0                	mov    %edx,%eax
f0101dac:	c1 e8 0c             	shr    $0xc,%eax
f0101daf:	3b 05 88 5e 2e f0    	cmp    0xf02e5e88,%eax
f0101db5:	72 12                	jb     f0101dc9 <mem_init+0x4a0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101db7:	52                   	push   %edx
f0101db8:	68 68 68 10 f0       	push   $0xf0106868
f0101dbd:	6a 58                	push   $0x58
f0101dbf:	68 dd 7b 10 f0       	push   $0xf0107bdd
f0101dc4:	e8 9f e2 ff ff       	call   f0100068 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101dc9:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101dd0:	75 11                	jne    f0101de3 <mem_init+0x4ba>
f0101dd2:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101dd8:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101dde:	80 38 00             	cmpb   $0x0,(%eax)
f0101de1:	74 19                	je     f0101dfc <mem_init+0x4d3>
f0101de3:	68 a7 7d 10 f0       	push   $0xf0107da7
f0101de8:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101ded:	68 1b 03 00 00       	push   $0x31b
f0101df2:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101df7:	e8 6c e2 ff ff       	call   f0100068 <_panic>
f0101dfc:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101dfd:	39 d0                	cmp    %edx,%eax
f0101dff:	75 dd                	jne    f0101dde <mem_init+0x4b5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101e01:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101e04:	89 15 30 52 2e f0    	mov    %edx,0xf02e5230

	// free the pages we took
	page_free(pp0);
f0101e0a:	83 ec 0c             	sub    $0xc,%esp
f0101e0d:	56                   	push   %esi
f0101e0e:	e8 44 f8 ff ff       	call   f0101657 <page_free>
	page_free(pp1);
f0101e13:	89 3c 24             	mov    %edi,(%esp)
f0101e16:	e8 3c f8 ff ff       	call   f0101657 <page_free>
	page_free(pp2);
f0101e1b:	83 c4 04             	add    $0x4,%esp
f0101e1e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e21:	e8 31 f8 ff ff       	call   f0101657 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e26:	a1 30 52 2e f0       	mov    0xf02e5230,%eax
f0101e2b:	83 c4 10             	add    $0x10,%esp
f0101e2e:	85 c0                	test   %eax,%eax
f0101e30:	74 07                	je     f0101e39 <mem_init+0x510>
		--nfree;
f0101e32:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e33:	8b 00                	mov    (%eax),%eax
f0101e35:	85 c0                	test   %eax,%eax
f0101e37:	75 f9                	jne    f0101e32 <mem_init+0x509>
		--nfree;
	assert(nfree == 0);
f0101e39:	85 db                	test   %ebx,%ebx
f0101e3b:	74 19                	je     f0101e56 <mem_init+0x52d>
f0101e3d:	68 b1 7d 10 f0       	push   $0xf0107db1
f0101e42:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101e47:	68 28 03 00 00       	push   $0x328
f0101e4c:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101e51:	e8 12 e2 ff ff       	call   f0100068 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101e56:	83 ec 0c             	sub    $0xc,%esp
f0101e59:	68 4c 74 10 f0       	push   $0xf010744c
f0101e5e:	e8 fa 1e 00 00       	call   f0103d5d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101e63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e6a:	e8 5e f7 ff ff       	call   f01015cd <page_alloc>
f0101e6f:	89 c7                	mov    %eax,%edi
f0101e71:	83 c4 10             	add    $0x10,%esp
f0101e74:	85 c0                	test   %eax,%eax
f0101e76:	75 19                	jne    f0101e91 <mem_init+0x568>
f0101e78:	68 bf 7c 10 f0       	push   $0xf0107cbf
f0101e7d:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101e82:	68 8e 03 00 00       	push   $0x38e
f0101e87:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101e8c:	e8 d7 e1 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101e91:	83 ec 0c             	sub    $0xc,%esp
f0101e94:	6a 00                	push   $0x0
f0101e96:	e8 32 f7 ff ff       	call   f01015cd <page_alloc>
f0101e9b:	89 c6                	mov    %eax,%esi
f0101e9d:	83 c4 10             	add    $0x10,%esp
f0101ea0:	85 c0                	test   %eax,%eax
f0101ea2:	75 19                	jne    f0101ebd <mem_init+0x594>
f0101ea4:	68 d5 7c 10 f0       	push   $0xf0107cd5
f0101ea9:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101eae:	68 8f 03 00 00       	push   $0x38f
f0101eb3:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101eb8:	e8 ab e1 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ebd:	83 ec 0c             	sub    $0xc,%esp
f0101ec0:	6a 00                	push   $0x0
f0101ec2:	e8 06 f7 ff ff       	call   f01015cd <page_alloc>
f0101ec7:	89 c3                	mov    %eax,%ebx
f0101ec9:	83 c4 10             	add    $0x10,%esp
f0101ecc:	85 c0                	test   %eax,%eax
f0101ece:	75 19                	jne    f0101ee9 <mem_init+0x5c0>
f0101ed0:	68 eb 7c 10 f0       	push   $0xf0107ceb
f0101ed5:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101eda:	68 90 03 00 00       	push   $0x390
f0101edf:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101ee4:	e8 7f e1 ff ff       	call   f0100068 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ee9:	39 f7                	cmp    %esi,%edi
f0101eeb:	75 19                	jne    f0101f06 <mem_init+0x5dd>
f0101eed:	68 01 7d 10 f0       	push   $0xf0107d01
f0101ef2:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101ef7:	68 93 03 00 00       	push   $0x393
f0101efc:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101f01:	e8 62 e1 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f06:	39 c6                	cmp    %eax,%esi
f0101f08:	74 04                	je     f0101f0e <mem_init+0x5e5>
f0101f0a:	39 c7                	cmp    %eax,%edi
f0101f0c:	75 19                	jne    f0101f27 <mem_init+0x5fe>
f0101f0e:	68 2c 74 10 f0       	push   $0xf010742c
f0101f13:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101f18:	68 94 03 00 00       	push   $0x394
f0101f1d:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101f22:	e8 41 e1 ff ff       	call   f0100068 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101f27:	8b 0d 30 52 2e f0    	mov    0xf02e5230,%ecx
f0101f2d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101f30:	c7 05 30 52 2e f0 00 	movl   $0x0,0xf02e5230
f0101f37:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101f3a:	83 ec 0c             	sub    $0xc,%esp
f0101f3d:	6a 00                	push   $0x0
f0101f3f:	e8 89 f6 ff ff       	call   f01015cd <page_alloc>
f0101f44:	83 c4 10             	add    $0x10,%esp
f0101f47:	85 c0                	test   %eax,%eax
f0101f49:	74 19                	je     f0101f64 <mem_init+0x63b>
f0101f4b:	68 6a 7d 10 f0       	push   $0xf0107d6a
f0101f50:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101f55:	68 9b 03 00 00       	push   $0x39b
f0101f5a:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101f5f:	e8 04 e1 ff ff       	call   f0100068 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101f64:	83 ec 04             	sub    $0x4,%esp
f0101f67:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101f6a:	50                   	push   %eax
f0101f6b:	6a 00                	push   $0x0
f0101f6d:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0101f73:	e8 05 f8 ff ff       	call   f010177d <page_lookup>
f0101f78:	83 c4 10             	add    $0x10,%esp
f0101f7b:	85 c0                	test   %eax,%eax
f0101f7d:	74 19                	je     f0101f98 <mem_init+0x66f>
f0101f7f:	68 6c 74 10 f0       	push   $0xf010746c
f0101f84:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101f89:	68 9e 03 00 00       	push   $0x39e
f0101f8e:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101f93:	e8 d0 e0 ff ff       	call   f0100068 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101f98:	6a 02                	push   $0x2
f0101f9a:	6a 00                	push   $0x0
f0101f9c:	56                   	push   %esi
f0101f9d:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0101fa3:	e8 d1 f8 ff ff       	call   f0101879 <page_insert>
f0101fa8:	83 c4 10             	add    $0x10,%esp
f0101fab:	85 c0                	test   %eax,%eax
f0101fad:	78 19                	js     f0101fc8 <mem_init+0x69f>
f0101faf:	68 a4 74 10 f0       	push   $0xf01074a4
f0101fb4:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101fb9:	68 a1 03 00 00       	push   $0x3a1
f0101fbe:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101fc3:	e8 a0 e0 ff ff       	call   f0100068 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101fc8:	83 ec 0c             	sub    $0xc,%esp
f0101fcb:	57                   	push   %edi
f0101fcc:	e8 86 f6 ff ff       	call   f0101657 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101fd1:	6a 02                	push   $0x2
f0101fd3:	6a 00                	push   $0x0
f0101fd5:	56                   	push   %esi
f0101fd6:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0101fdc:	e8 98 f8 ff ff       	call   f0101879 <page_insert>
f0101fe1:	83 c4 20             	add    $0x20,%esp
f0101fe4:	85 c0                	test   %eax,%eax
f0101fe6:	74 19                	je     f0102001 <mem_init+0x6d8>
f0101fe8:	68 d4 74 10 f0       	push   $0xf01074d4
f0101fed:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0101ff2:	68 a5 03 00 00       	push   $0x3a5
f0101ff7:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0101ffc:	e8 67 e0 ff ff       	call   f0100068 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102001:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0102006:	8b 08                	mov    (%eax),%ecx
f0102008:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010200e:	89 fa                	mov    %edi,%edx
f0102010:	2b 15 90 5e 2e f0    	sub    0xf02e5e90,%edx
f0102016:	c1 fa 03             	sar    $0x3,%edx
f0102019:	c1 e2 0c             	shl    $0xc,%edx
f010201c:	39 d1                	cmp    %edx,%ecx
f010201e:	74 19                	je     f0102039 <mem_init+0x710>
f0102020:	68 04 75 10 f0       	push   $0xf0107504
f0102025:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010202a:	68 a6 03 00 00       	push   $0x3a6
f010202f:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102034:	e8 2f e0 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102039:	ba 00 00 00 00       	mov    $0x0,%edx
f010203e:	e8 64 f1 ff ff       	call   f01011a7 <check_va2pa>
f0102043:	89 f2                	mov    %esi,%edx
f0102045:	2b 15 90 5e 2e f0    	sub    0xf02e5e90,%edx
f010204b:	c1 fa 03             	sar    $0x3,%edx
f010204e:	c1 e2 0c             	shl    $0xc,%edx
f0102051:	39 d0                	cmp    %edx,%eax
f0102053:	74 19                	je     f010206e <mem_init+0x745>
f0102055:	68 2c 75 10 f0       	push   $0xf010752c
f010205a:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010205f:	68 a7 03 00 00       	push   $0x3a7
f0102064:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102069:	e8 fa df ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 1);
f010206e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102073:	74 19                	je     f010208e <mem_init+0x765>
f0102075:	68 bc 7d 10 f0       	push   $0xf0107dbc
f010207a:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010207f:	68 a8 03 00 00       	push   $0x3a8
f0102084:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102089:	e8 da df ff ff       	call   f0100068 <_panic>
	assert(pp0->pp_ref == 1);
f010208e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102093:	74 19                	je     f01020ae <mem_init+0x785>
f0102095:	68 cd 7d 10 f0       	push   $0xf0107dcd
f010209a:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010209f:	68 a9 03 00 00       	push   $0x3a9
f01020a4:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01020a9:	e8 ba df ff ff       	call   f0100068 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020ae:	6a 02                	push   $0x2
f01020b0:	68 00 10 00 00       	push   $0x1000
f01020b5:	53                   	push   %ebx
f01020b6:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f01020bc:	e8 b8 f7 ff ff       	call   f0101879 <page_insert>
f01020c1:	83 c4 10             	add    $0x10,%esp
f01020c4:	85 c0                	test   %eax,%eax
f01020c6:	74 19                	je     f01020e1 <mem_init+0x7b8>
f01020c8:	68 5c 75 10 f0       	push   $0xf010755c
f01020cd:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01020d2:	68 ac 03 00 00       	push   $0x3ac
f01020d7:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01020dc:	e8 87 df ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020e1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020e6:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f01020eb:	e8 b7 f0 ff ff       	call   f01011a7 <check_va2pa>
f01020f0:	89 da                	mov    %ebx,%edx
f01020f2:	2b 15 90 5e 2e f0    	sub    0xf02e5e90,%edx
f01020f8:	c1 fa 03             	sar    $0x3,%edx
f01020fb:	c1 e2 0c             	shl    $0xc,%edx
f01020fe:	39 d0                	cmp    %edx,%eax
f0102100:	74 19                	je     f010211b <mem_init+0x7f2>
f0102102:	68 98 75 10 f0       	push   $0xf0107598
f0102107:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010210c:	68 ad 03 00 00       	push   $0x3ad
f0102111:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102116:	e8 4d df ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f010211b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102120:	74 19                	je     f010213b <mem_init+0x812>
f0102122:	68 de 7d 10 f0       	push   $0xf0107dde
f0102127:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010212c:	68 ae 03 00 00       	push   $0x3ae
f0102131:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102136:	e8 2d df ff ff       	call   f0100068 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010213b:	83 ec 0c             	sub    $0xc,%esp
f010213e:	6a 00                	push   $0x0
f0102140:	e8 88 f4 ff ff       	call   f01015cd <page_alloc>
f0102145:	83 c4 10             	add    $0x10,%esp
f0102148:	85 c0                	test   %eax,%eax
f010214a:	74 19                	je     f0102165 <mem_init+0x83c>
f010214c:	68 6a 7d 10 f0       	push   $0xf0107d6a
f0102151:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102156:	68 b1 03 00 00       	push   $0x3b1
f010215b:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102160:	e8 03 df ff ff       	call   f0100068 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102165:	6a 02                	push   $0x2
f0102167:	68 00 10 00 00       	push   $0x1000
f010216c:	53                   	push   %ebx
f010216d:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0102173:	e8 01 f7 ff ff       	call   f0101879 <page_insert>
f0102178:	83 c4 10             	add    $0x10,%esp
f010217b:	85 c0                	test   %eax,%eax
f010217d:	74 19                	je     f0102198 <mem_init+0x86f>
f010217f:	68 5c 75 10 f0       	push   $0xf010755c
f0102184:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102189:	68 b4 03 00 00       	push   $0x3b4
f010218e:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102193:	e8 d0 de ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102198:	ba 00 10 00 00       	mov    $0x1000,%edx
f010219d:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f01021a2:	e8 00 f0 ff ff       	call   f01011a7 <check_va2pa>
f01021a7:	89 da                	mov    %ebx,%edx
f01021a9:	2b 15 90 5e 2e f0    	sub    0xf02e5e90,%edx
f01021af:	c1 fa 03             	sar    $0x3,%edx
f01021b2:	c1 e2 0c             	shl    $0xc,%edx
f01021b5:	39 d0                	cmp    %edx,%eax
f01021b7:	74 19                	je     f01021d2 <mem_init+0x8a9>
f01021b9:	68 98 75 10 f0       	push   $0xf0107598
f01021be:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01021c3:	68 b5 03 00 00       	push   $0x3b5
f01021c8:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01021cd:	e8 96 de ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f01021d2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01021d7:	74 19                	je     f01021f2 <mem_init+0x8c9>
f01021d9:	68 de 7d 10 f0       	push   $0xf0107dde
f01021de:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01021e3:	68 b6 03 00 00       	push   $0x3b6
f01021e8:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01021ed:	e8 76 de ff ff       	call   f0100068 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01021f2:	83 ec 0c             	sub    $0xc,%esp
f01021f5:	6a 00                	push   $0x0
f01021f7:	e8 d1 f3 ff ff       	call   f01015cd <page_alloc>
f01021fc:	83 c4 10             	add    $0x10,%esp
f01021ff:	85 c0                	test   %eax,%eax
f0102201:	74 19                	je     f010221c <mem_init+0x8f3>
f0102203:	68 6a 7d 10 f0       	push   $0xf0107d6a
f0102208:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010220d:	68 ba 03 00 00       	push   $0x3ba
f0102212:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102217:	e8 4c de ff ff       	call   f0100068 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010221c:	8b 15 8c 5e 2e f0    	mov    0xf02e5e8c,%edx
f0102222:	8b 02                	mov    (%edx),%eax
f0102224:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102229:	89 c1                	mov    %eax,%ecx
f010222b:	c1 e9 0c             	shr    $0xc,%ecx
f010222e:	3b 0d 88 5e 2e f0    	cmp    0xf02e5e88,%ecx
f0102234:	72 15                	jb     f010224b <mem_init+0x922>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102236:	50                   	push   %eax
f0102237:	68 68 68 10 f0       	push   $0xf0106868
f010223c:	68 bd 03 00 00       	push   $0x3bd
f0102241:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102246:	e8 1d de ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f010224b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102250:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102253:	83 ec 04             	sub    $0x4,%esp
f0102256:	6a 00                	push   $0x0
f0102258:	68 00 10 00 00       	push   $0x1000
f010225d:	52                   	push   %edx
f010225e:	e8 32 f4 ff ff       	call   f0101695 <pgdir_walk>
f0102263:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102266:	83 c2 04             	add    $0x4,%edx
f0102269:	83 c4 10             	add    $0x10,%esp
f010226c:	39 d0                	cmp    %edx,%eax
f010226e:	74 19                	je     f0102289 <mem_init+0x960>
f0102270:	68 c8 75 10 f0       	push   $0xf01075c8
f0102275:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010227a:	68 be 03 00 00       	push   $0x3be
f010227f:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102284:	e8 df dd ff ff       	call   f0100068 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102289:	6a 06                	push   $0x6
f010228b:	68 00 10 00 00       	push   $0x1000
f0102290:	53                   	push   %ebx
f0102291:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0102297:	e8 dd f5 ff ff       	call   f0101879 <page_insert>
f010229c:	83 c4 10             	add    $0x10,%esp
f010229f:	85 c0                	test   %eax,%eax
f01022a1:	74 19                	je     f01022bc <mem_init+0x993>
f01022a3:	68 08 76 10 f0       	push   $0xf0107608
f01022a8:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01022ad:	68 c1 03 00 00       	push   $0x3c1
f01022b2:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01022b7:	e8 ac dd ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022bc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022c1:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f01022c6:	e8 dc ee ff ff       	call   f01011a7 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022cb:	89 da                	mov    %ebx,%edx
f01022cd:	2b 15 90 5e 2e f0    	sub    0xf02e5e90,%edx
f01022d3:	c1 fa 03             	sar    $0x3,%edx
f01022d6:	c1 e2 0c             	shl    $0xc,%edx
f01022d9:	39 d0                	cmp    %edx,%eax
f01022db:	74 19                	je     f01022f6 <mem_init+0x9cd>
f01022dd:	68 98 75 10 f0       	push   $0xf0107598
f01022e2:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01022e7:	68 c2 03 00 00       	push   $0x3c2
f01022ec:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01022f1:	e8 72 dd ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f01022f6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01022fb:	74 19                	je     f0102316 <mem_init+0x9ed>
f01022fd:	68 de 7d 10 f0       	push   $0xf0107dde
f0102302:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102307:	68 c3 03 00 00       	push   $0x3c3
f010230c:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102311:	e8 52 dd ff ff       	call   f0100068 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102316:	83 ec 04             	sub    $0x4,%esp
f0102319:	6a 00                	push   $0x0
f010231b:	68 00 10 00 00       	push   $0x1000
f0102320:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0102326:	e8 6a f3 ff ff       	call   f0101695 <pgdir_walk>
f010232b:	83 c4 10             	add    $0x10,%esp
f010232e:	f6 00 04             	testb  $0x4,(%eax)
f0102331:	75 19                	jne    f010234c <mem_init+0xa23>
f0102333:	68 48 76 10 f0       	push   $0xf0107648
f0102338:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010233d:	68 c4 03 00 00       	push   $0x3c4
f0102342:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102347:	e8 1c dd ff ff       	call   f0100068 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010234c:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0102351:	f6 00 04             	testb  $0x4,(%eax)
f0102354:	75 19                	jne    f010236f <mem_init+0xa46>
f0102356:	68 ef 7d 10 f0       	push   $0xf0107def
f010235b:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102360:	68 c5 03 00 00       	push   $0x3c5
f0102365:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010236a:	e8 f9 dc ff ff       	call   f0100068 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010236f:	6a 02                	push   $0x2
f0102371:	68 00 10 00 00       	push   $0x1000
f0102376:	53                   	push   %ebx
f0102377:	50                   	push   %eax
f0102378:	e8 fc f4 ff ff       	call   f0101879 <page_insert>
f010237d:	83 c4 10             	add    $0x10,%esp
f0102380:	85 c0                	test   %eax,%eax
f0102382:	74 19                	je     f010239d <mem_init+0xa74>
f0102384:	68 5c 75 10 f0       	push   $0xf010755c
f0102389:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010238e:	68 c8 03 00 00       	push   $0x3c8
f0102393:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102398:	e8 cb dc ff ff       	call   f0100068 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010239d:	83 ec 04             	sub    $0x4,%esp
f01023a0:	6a 00                	push   $0x0
f01023a2:	68 00 10 00 00       	push   $0x1000
f01023a7:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f01023ad:	e8 e3 f2 ff ff       	call   f0101695 <pgdir_walk>
f01023b2:	83 c4 10             	add    $0x10,%esp
f01023b5:	f6 00 02             	testb  $0x2,(%eax)
f01023b8:	75 19                	jne    f01023d3 <mem_init+0xaaa>
f01023ba:	68 7c 76 10 f0       	push   $0xf010767c
f01023bf:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01023c4:	68 c9 03 00 00       	push   $0x3c9
f01023c9:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01023ce:	e8 95 dc ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01023d3:	83 ec 04             	sub    $0x4,%esp
f01023d6:	6a 00                	push   $0x0
f01023d8:	68 00 10 00 00       	push   $0x1000
f01023dd:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f01023e3:	e8 ad f2 ff ff       	call   f0101695 <pgdir_walk>
f01023e8:	83 c4 10             	add    $0x10,%esp
f01023eb:	f6 00 04             	testb  $0x4,(%eax)
f01023ee:	74 19                	je     f0102409 <mem_init+0xae0>
f01023f0:	68 b0 76 10 f0       	push   $0xf01076b0
f01023f5:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01023fa:	68 ca 03 00 00       	push   $0x3ca
f01023ff:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102404:	e8 5f dc ff ff       	call   f0100068 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102409:	6a 02                	push   $0x2
f010240b:	68 00 00 40 00       	push   $0x400000
f0102410:	57                   	push   %edi
f0102411:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0102417:	e8 5d f4 ff ff       	call   f0101879 <page_insert>
f010241c:	83 c4 10             	add    $0x10,%esp
f010241f:	85 c0                	test   %eax,%eax
f0102421:	78 19                	js     f010243c <mem_init+0xb13>
f0102423:	68 e8 76 10 f0       	push   $0xf01076e8
f0102428:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010242d:	68 cd 03 00 00       	push   $0x3cd
f0102432:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102437:	e8 2c dc ff ff       	call   f0100068 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010243c:	6a 02                	push   $0x2
f010243e:	68 00 10 00 00       	push   $0x1000
f0102443:	56                   	push   %esi
f0102444:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f010244a:	e8 2a f4 ff ff       	call   f0101879 <page_insert>
f010244f:	83 c4 10             	add    $0x10,%esp
f0102452:	85 c0                	test   %eax,%eax
f0102454:	74 19                	je     f010246f <mem_init+0xb46>
f0102456:	68 20 77 10 f0       	push   $0xf0107720
f010245b:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102460:	68 d0 03 00 00       	push   $0x3d0
f0102465:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010246a:	e8 f9 db ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010246f:	83 ec 04             	sub    $0x4,%esp
f0102472:	6a 00                	push   $0x0
f0102474:	68 00 10 00 00       	push   $0x1000
f0102479:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f010247f:	e8 11 f2 ff ff       	call   f0101695 <pgdir_walk>
f0102484:	83 c4 10             	add    $0x10,%esp
f0102487:	f6 00 04             	testb  $0x4,(%eax)
f010248a:	74 19                	je     f01024a5 <mem_init+0xb7c>
f010248c:	68 b0 76 10 f0       	push   $0xf01076b0
f0102491:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102496:	68 d1 03 00 00       	push   $0x3d1
f010249b:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01024a0:	e8 c3 db ff ff       	call   f0100068 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01024a5:	ba 00 00 00 00       	mov    $0x0,%edx
f01024aa:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f01024af:	e8 f3 ec ff ff       	call   f01011a7 <check_va2pa>
f01024b4:	89 f2                	mov    %esi,%edx
f01024b6:	2b 15 90 5e 2e f0    	sub    0xf02e5e90,%edx
f01024bc:	c1 fa 03             	sar    $0x3,%edx
f01024bf:	c1 e2 0c             	shl    $0xc,%edx
f01024c2:	39 d0                	cmp    %edx,%eax
f01024c4:	74 19                	je     f01024df <mem_init+0xbb6>
f01024c6:	68 5c 77 10 f0       	push   $0xf010775c
f01024cb:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01024d0:	68 d4 03 00 00       	push   $0x3d4
f01024d5:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01024da:	e8 89 db ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01024df:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024e4:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f01024e9:	e8 b9 ec ff ff       	call   f01011a7 <check_va2pa>
f01024ee:	89 f2                	mov    %esi,%edx
f01024f0:	2b 15 90 5e 2e f0    	sub    0xf02e5e90,%edx
f01024f6:	c1 fa 03             	sar    $0x3,%edx
f01024f9:	c1 e2 0c             	shl    $0xc,%edx
f01024fc:	39 d0                	cmp    %edx,%eax
f01024fe:	74 19                	je     f0102519 <mem_init+0xbf0>
f0102500:	68 88 77 10 f0       	push   $0xf0107788
f0102505:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010250a:	68 d5 03 00 00       	push   $0x3d5
f010250f:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102514:	e8 4f db ff ff       	call   f0100068 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102519:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f010251e:	74 19                	je     f0102539 <mem_init+0xc10>
f0102520:	68 05 7e 10 f0       	push   $0xf0107e05
f0102525:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010252a:	68 d7 03 00 00       	push   $0x3d7
f010252f:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102534:	e8 2f db ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f0102539:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010253e:	74 19                	je     f0102559 <mem_init+0xc30>
f0102540:	68 16 7e 10 f0       	push   $0xf0107e16
f0102545:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010254a:	68 d8 03 00 00       	push   $0x3d8
f010254f:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102554:	e8 0f db ff ff       	call   f0100068 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102559:	83 ec 0c             	sub    $0xc,%esp
f010255c:	6a 00                	push   $0x0
f010255e:	e8 6a f0 ff ff       	call   f01015cd <page_alloc>
f0102563:	83 c4 10             	add    $0x10,%esp
f0102566:	85 c0                	test   %eax,%eax
f0102568:	74 04                	je     f010256e <mem_init+0xc45>
f010256a:	39 c3                	cmp    %eax,%ebx
f010256c:	74 19                	je     f0102587 <mem_init+0xc5e>
f010256e:	68 b8 77 10 f0       	push   $0xf01077b8
f0102573:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102578:	68 db 03 00 00       	push   $0x3db
f010257d:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102582:	e8 e1 da ff ff       	call   f0100068 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102587:	83 ec 08             	sub    $0x8,%esp
f010258a:	6a 00                	push   $0x0
f010258c:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0102592:	e8 95 f2 ff ff       	call   f010182c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102597:	ba 00 00 00 00       	mov    $0x0,%edx
f010259c:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f01025a1:	e8 01 ec ff ff       	call   f01011a7 <check_va2pa>
f01025a6:	83 c4 10             	add    $0x10,%esp
f01025a9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025ac:	74 19                	je     f01025c7 <mem_init+0xc9e>
f01025ae:	68 dc 77 10 f0       	push   $0xf01077dc
f01025b3:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01025b8:	68 df 03 00 00       	push   $0x3df
f01025bd:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01025c2:	e8 a1 da ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025c7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025cc:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f01025d1:	e8 d1 eb ff ff       	call   f01011a7 <check_va2pa>
f01025d6:	89 f2                	mov    %esi,%edx
f01025d8:	2b 15 90 5e 2e f0    	sub    0xf02e5e90,%edx
f01025de:	c1 fa 03             	sar    $0x3,%edx
f01025e1:	c1 e2 0c             	shl    $0xc,%edx
f01025e4:	39 d0                	cmp    %edx,%eax
f01025e6:	74 19                	je     f0102601 <mem_init+0xcd8>
f01025e8:	68 88 77 10 f0       	push   $0xf0107788
f01025ed:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01025f2:	68 e0 03 00 00       	push   $0x3e0
f01025f7:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01025fc:	e8 67 da ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 1);
f0102601:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102606:	74 19                	je     f0102621 <mem_init+0xcf8>
f0102608:	68 bc 7d 10 f0       	push   $0xf0107dbc
f010260d:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102612:	68 e1 03 00 00       	push   $0x3e1
f0102617:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010261c:	e8 47 da ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f0102621:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102626:	74 19                	je     f0102641 <mem_init+0xd18>
f0102628:	68 16 7e 10 f0       	push   $0xf0107e16
f010262d:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102632:	68 e2 03 00 00       	push   $0x3e2
f0102637:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010263c:	e8 27 da ff ff       	call   f0100068 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102641:	83 ec 08             	sub    $0x8,%esp
f0102644:	68 00 10 00 00       	push   $0x1000
f0102649:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f010264f:	e8 d8 f1 ff ff       	call   f010182c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102654:	ba 00 00 00 00       	mov    $0x0,%edx
f0102659:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f010265e:	e8 44 eb ff ff       	call   f01011a7 <check_va2pa>
f0102663:	83 c4 10             	add    $0x10,%esp
f0102666:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102669:	74 19                	je     f0102684 <mem_init+0xd5b>
f010266b:	68 dc 77 10 f0       	push   $0xf01077dc
f0102670:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102675:	68 e6 03 00 00       	push   $0x3e6
f010267a:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010267f:	e8 e4 d9 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102684:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102689:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f010268e:	e8 14 eb ff ff       	call   f01011a7 <check_va2pa>
f0102693:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102696:	74 19                	je     f01026b1 <mem_init+0xd88>
f0102698:	68 00 78 10 f0       	push   $0xf0107800
f010269d:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01026a2:	68 e7 03 00 00       	push   $0x3e7
f01026a7:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01026ac:	e8 b7 d9 ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 0);
f01026b1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026b6:	74 19                	je     f01026d1 <mem_init+0xda8>
f01026b8:	68 27 7e 10 f0       	push   $0xf0107e27
f01026bd:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01026c2:	68 e8 03 00 00       	push   $0x3e8
f01026c7:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01026cc:	e8 97 d9 ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f01026d1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01026d6:	74 19                	je     f01026f1 <mem_init+0xdc8>
f01026d8:	68 16 7e 10 f0       	push   $0xf0107e16
f01026dd:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01026e2:	68 e9 03 00 00       	push   $0x3e9
f01026e7:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01026ec:	e8 77 d9 ff ff       	call   f0100068 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01026f1:	83 ec 0c             	sub    $0xc,%esp
f01026f4:	6a 00                	push   $0x0
f01026f6:	e8 d2 ee ff ff       	call   f01015cd <page_alloc>
f01026fb:	83 c4 10             	add    $0x10,%esp
f01026fe:	85 c0                	test   %eax,%eax
f0102700:	74 04                	je     f0102706 <mem_init+0xddd>
f0102702:	39 c6                	cmp    %eax,%esi
f0102704:	74 19                	je     f010271f <mem_init+0xdf6>
f0102706:	68 28 78 10 f0       	push   $0xf0107828
f010270b:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102710:	68 ec 03 00 00       	push   $0x3ec
f0102715:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010271a:	e8 49 d9 ff ff       	call   f0100068 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010271f:	83 ec 0c             	sub    $0xc,%esp
f0102722:	6a 00                	push   $0x0
f0102724:	e8 a4 ee ff ff       	call   f01015cd <page_alloc>
f0102729:	83 c4 10             	add    $0x10,%esp
f010272c:	85 c0                	test   %eax,%eax
f010272e:	74 19                	je     f0102749 <mem_init+0xe20>
f0102730:	68 6a 7d 10 f0       	push   $0xf0107d6a
f0102735:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010273a:	68 ef 03 00 00       	push   $0x3ef
f010273f:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102744:	e8 1f d9 ff ff       	call   f0100068 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102749:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f010274e:	8b 08                	mov    (%eax),%ecx
f0102750:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102756:	89 fa                	mov    %edi,%edx
f0102758:	2b 15 90 5e 2e f0    	sub    0xf02e5e90,%edx
f010275e:	c1 fa 03             	sar    $0x3,%edx
f0102761:	c1 e2 0c             	shl    $0xc,%edx
f0102764:	39 d1                	cmp    %edx,%ecx
f0102766:	74 19                	je     f0102781 <mem_init+0xe58>
f0102768:	68 04 75 10 f0       	push   $0xf0107504
f010276d:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102772:	68 f2 03 00 00       	push   $0x3f2
f0102777:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010277c:	e8 e7 d8 ff ff       	call   f0100068 <_panic>
	kern_pgdir[0] = 0;
f0102781:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102787:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010278c:	74 19                	je     f01027a7 <mem_init+0xe7e>
f010278e:	68 cd 7d 10 f0       	push   $0xf0107dcd
f0102793:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102798:	68 f4 03 00 00       	push   $0x3f4
f010279d:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01027a2:	e8 c1 d8 ff ff       	call   f0100068 <_panic>
	pp0->pp_ref = 0;

	kern_pgdir[PDX(va)] = 0;
f01027a7:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f01027ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01027b2:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
f01027b8:	89 f8                	mov    %edi,%eax
f01027ba:	2b 05 90 5e 2e f0    	sub    0xf02e5e90,%eax
f01027c0:	c1 f8 03             	sar    $0x3,%eax
f01027c3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027c6:	89 c2                	mov    %eax,%edx
f01027c8:	c1 ea 0c             	shr    $0xc,%edx
f01027cb:	3b 15 88 5e 2e f0    	cmp    0xf02e5e88,%edx
f01027d1:	72 12                	jb     f01027e5 <mem_init+0xebc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027d3:	50                   	push   %eax
f01027d4:	68 68 68 10 f0       	push   $0xf0106868
f01027d9:	6a 58                	push   $0x58
f01027db:	68 dd 7b 10 f0       	push   $0xf0107bdd
f01027e0:	e8 83 d8 ff ff       	call   f0100068 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01027e5:	83 ec 04             	sub    $0x4,%esp
f01027e8:	68 00 10 00 00       	push   $0x1000
f01027ed:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01027f2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01027f7:	50                   	push   %eax
f01027f8:	e8 28 33 00 00       	call   f0105b25 <memset>
	page_free(pp0);
f01027fd:	89 3c 24             	mov    %edi,(%esp)
f0102800:	e8 52 ee ff ff       	call   f0101657 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102805:	83 c4 0c             	add    $0xc,%esp
f0102808:	6a 01                	push   $0x1
f010280a:	6a 00                	push   $0x0
f010280c:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0102812:	e8 7e ee ff ff       	call   f0101695 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102817:	89 fa                	mov    %edi,%edx
f0102819:	2b 15 90 5e 2e f0    	sub    0xf02e5e90,%edx
f010281f:	c1 fa 03             	sar    $0x3,%edx
f0102822:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102825:	89 d0                	mov    %edx,%eax
f0102827:	c1 e8 0c             	shr    $0xc,%eax
f010282a:	83 c4 10             	add    $0x10,%esp
f010282d:	3b 05 88 5e 2e f0    	cmp    0xf02e5e88,%eax
f0102833:	72 12                	jb     f0102847 <mem_init+0xf1e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102835:	52                   	push   %edx
f0102836:	68 68 68 10 f0       	push   $0xf0106868
f010283b:	6a 58                	push   $0x58
f010283d:	68 dd 7b 10 f0       	push   $0xf0107bdd
f0102842:	e8 21 d8 ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f0102847:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010284d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102850:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102857:	75 11                	jne    f010286a <mem_init+0xf41>
f0102859:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010285f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102865:	f6 00 01             	testb  $0x1,(%eax)
f0102868:	74 19                	je     f0102883 <mem_init+0xf5a>
f010286a:	68 38 7e 10 f0       	push   $0xf0107e38
f010286f:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102874:	68 00 04 00 00       	push   $0x400
f0102879:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010287e:	e8 e5 d7 ff ff       	call   f0100068 <_panic>
f0102883:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102886:	39 d0                	cmp    %edx,%eax
f0102888:	75 db                	jne    f0102865 <mem_init+0xf3c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010288a:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f010288f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102895:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f010289b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010289e:	a3 30 52 2e f0       	mov    %eax,0xf02e5230

	// free the pages we took
	page_free(pp0);
f01028a3:	83 ec 0c             	sub    $0xc,%esp
f01028a6:	57                   	push   %edi
f01028a7:	e8 ab ed ff ff       	call   f0101657 <page_free>
	page_free(pp1);
f01028ac:	89 34 24             	mov    %esi,(%esp)
f01028af:	e8 a3 ed ff ff       	call   f0101657 <page_free>
	page_free(pp2);
f01028b4:	89 1c 24             	mov    %ebx,(%esp)
f01028b7:	e8 9b ed ff ff       	call   f0101657 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01028bc:	83 c4 08             	add    $0x8,%esp
f01028bf:	68 01 10 00 00       	push   $0x1001
f01028c4:	6a 00                	push   $0x0
f01028c6:	e8 17 f0 ff ff       	call   f01018e2 <mmio_map_region>
f01028cb:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01028cd:	83 c4 08             	add    $0x8,%esp
f01028d0:	68 00 10 00 00       	push   $0x1000
f01028d5:	6a 00                	push   $0x0
f01028d7:	e8 06 f0 ff ff       	call   f01018e2 <mmio_map_region>
f01028dc:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01028de:	83 c4 10             	add    $0x10,%esp
f01028e1:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01028e7:	76 0d                	jbe    f01028f6 <mem_init+0xfcd>
f01028e9:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01028ef:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01028f4:	76 19                	jbe    f010290f <mem_init+0xfe6>
f01028f6:	68 4c 78 10 f0       	push   $0xf010784c
f01028fb:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102900:	68 10 04 00 00       	push   $0x410
f0102905:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010290a:	e8 59 d7 ff ff       	call   f0100068 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010290f:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102915:	76 0e                	jbe    f0102925 <mem_init+0xffc>
f0102917:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010291d:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102923:	76 19                	jbe    f010293e <mem_init+0x1015>
f0102925:	68 74 78 10 f0       	push   $0xf0107874
f010292a:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010292f:	68 11 04 00 00       	push   $0x411
f0102934:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102939:	e8 2a d7 ff ff       	call   f0100068 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010293e:	89 da                	mov    %ebx,%edx
f0102940:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102942:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102948:	74 19                	je     f0102963 <mem_init+0x103a>
f010294a:	68 9c 78 10 f0       	push   $0xf010789c
f010294f:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102954:	68 13 04 00 00       	push   $0x413
f0102959:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010295e:	e8 05 d7 ff ff       	call   f0100068 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102963:	39 c6                	cmp    %eax,%esi
f0102965:	73 19                	jae    f0102980 <mem_init+0x1057>
f0102967:	68 4f 7e 10 f0       	push   $0xf0107e4f
f010296c:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102971:	68 15 04 00 00       	push   $0x415
f0102976:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010297b:	e8 e8 d6 ff ff       	call   f0100068 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102980:	89 da                	mov    %ebx,%edx
f0102982:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0102987:	e8 1b e8 ff ff       	call   f01011a7 <check_va2pa>
f010298c:	85 c0                	test   %eax,%eax
f010298e:	74 19                	je     f01029a9 <mem_init+0x1080>
f0102990:	68 c4 78 10 f0       	push   $0xf01078c4
f0102995:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010299a:	68 17 04 00 00       	push   $0x417
f010299f:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01029a4:	e8 bf d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01029a9:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
f01029af:	89 fa                	mov    %edi,%edx
f01029b1:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f01029b6:	e8 ec e7 ff ff       	call   f01011a7 <check_va2pa>
f01029bb:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01029c0:	74 19                	je     f01029db <mem_init+0x10b2>
f01029c2:	68 e8 78 10 f0       	push   $0xf01078e8
f01029c7:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01029cc:	68 18 04 00 00       	push   $0x418
f01029d1:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01029d6:	e8 8d d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01029db:	89 f2                	mov    %esi,%edx
f01029dd:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f01029e2:	e8 c0 e7 ff ff       	call   f01011a7 <check_va2pa>
f01029e7:	85 c0                	test   %eax,%eax
f01029e9:	74 19                	je     f0102a04 <mem_init+0x10db>
f01029eb:	68 18 79 10 f0       	push   $0xf0107918
f01029f0:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01029f5:	68 19 04 00 00       	push   $0x419
f01029fa:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01029ff:	e8 64 d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a04:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102a0a:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0102a0f:	e8 93 e7 ff ff       	call   f01011a7 <check_va2pa>
f0102a14:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a17:	74 19                	je     f0102a32 <mem_init+0x1109>
f0102a19:	68 3c 79 10 f0       	push   $0xf010793c
f0102a1e:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102a23:	68 1a 04 00 00       	push   $0x41a
f0102a28:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102a2d:	e8 36 d6 ff ff       	call   f0100068 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102a32:	83 ec 04             	sub    $0x4,%esp
f0102a35:	6a 00                	push   $0x0
f0102a37:	53                   	push   %ebx
f0102a38:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0102a3e:	e8 52 ec ff ff       	call   f0101695 <pgdir_walk>
f0102a43:	83 c4 10             	add    $0x10,%esp
f0102a46:	f6 00 1a             	testb  $0x1a,(%eax)
f0102a49:	75 19                	jne    f0102a64 <mem_init+0x113b>
f0102a4b:	68 68 79 10 f0       	push   $0xf0107968
f0102a50:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102a55:	68 1c 04 00 00       	push   $0x41c
f0102a5a:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102a5f:	e8 04 d6 ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a64:	83 ec 04             	sub    $0x4,%esp
f0102a67:	6a 00                	push   $0x0
f0102a69:	53                   	push   %ebx
f0102a6a:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0102a70:	e8 20 ec ff ff       	call   f0101695 <pgdir_walk>
f0102a75:	83 c4 10             	add    $0x10,%esp
f0102a78:	f6 00 04             	testb  $0x4,(%eax)
f0102a7b:	74 19                	je     f0102a96 <mem_init+0x116d>
f0102a7d:	68 ac 79 10 f0       	push   $0xf01079ac
f0102a82:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102a87:	68 1d 04 00 00       	push   $0x41d
f0102a8c:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102a91:	e8 d2 d5 ff ff       	call   f0100068 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102a96:	83 ec 04             	sub    $0x4,%esp
f0102a99:	6a 00                	push   $0x0
f0102a9b:	53                   	push   %ebx
f0102a9c:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0102aa2:	e8 ee eb ff ff       	call   f0101695 <pgdir_walk>
f0102aa7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102aad:	83 c4 0c             	add    $0xc,%esp
f0102ab0:	6a 00                	push   $0x0
f0102ab2:	57                   	push   %edi
f0102ab3:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0102ab9:	e8 d7 eb ff ff       	call   f0101695 <pgdir_walk>
f0102abe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102ac4:	83 c4 0c             	add    $0xc,%esp
f0102ac7:	6a 00                	push   $0x0
f0102ac9:	56                   	push   %esi
f0102aca:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0102ad0:	e8 c0 eb ff ff       	call   f0101695 <pgdir_walk>
f0102ad5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102adb:	c7 04 24 61 7e 10 f0 	movl   $0xf0107e61,(%esp)
f0102ae2:	e8 76 12 00 00       	call   f0103d5d <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102ae7:	a1 90 5e 2e f0       	mov    0xf02e5e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102aec:	83 c4 10             	add    $0x10,%esp
f0102aef:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102af4:	77 15                	ja     f0102b0b <mem_init+0x11e2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102af6:	50                   	push   %eax
f0102af7:	68 44 68 10 f0       	push   $0xf0106844
f0102afc:	68 b9 00 00 00       	push   $0xb9
f0102b01:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102b06:	e8 5d d5 ff ff       	call   f0100068 <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102b0b:	8b 15 88 5e 2e f0    	mov    0xf02e5e88,%edx
f0102b11:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102b18:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102b1b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102b21:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102b23:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b28:	50                   	push   %eax
f0102b29:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102b2e:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0102b33:	e8 f4 eb ff ff       	call   f010172c <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    boot_map_region(kern_pgdir,
f0102b38:	a1 3c 52 2e f0       	mov    0xf02e523c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b3d:	83 c4 10             	add    $0x10,%esp
f0102b40:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b45:	77 15                	ja     f0102b5c <mem_init+0x1233>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b47:	50                   	push   %eax
f0102b48:	68 44 68 10 f0       	push   $0xf0106844
f0102b4d:	68 c6 00 00 00       	push   $0xc6
f0102b52:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102b57:	e8 0c d5 ff ff       	call   f0100068 <_panic>
f0102b5c:	83 ec 08             	sub    $0x8,%esp
f0102b5f:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102b61:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b66:	50                   	push   %eax
f0102b67:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102b6c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102b71:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0102b76:	e8 b1 eb ff ff       	call   f010172c <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b7b:	83 c4 10             	add    $0x10,%esp
f0102b7e:	b8 00 e0 11 f0       	mov    $0xf011e000,%eax
f0102b83:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b88:	77 15                	ja     f0102b9f <mem_init+0x1276>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b8a:	50                   	push   %eax
f0102b8b:	68 44 68 10 f0       	push   $0xf0106844
f0102b90:	68 d7 00 00 00       	push   $0xd7
f0102b95:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102b9a:	e8 c9 d4 ff ff       	call   f0100068 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102b9f:	83 ec 08             	sub    $0x8,%esp
f0102ba2:	6a 02                	push   $0x2
f0102ba4:	68 00 e0 11 00       	push   $0x11e000
f0102ba9:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102bae:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102bb3:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0102bb8:	e8 6f eb ff ff       	call   f010172c <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102bbd:	83 c4 08             	add    $0x8,%esp
f0102bc0:	6a 02                	push   $0x2
f0102bc2:	6a 00                	push   $0x0
f0102bc4:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102bc9:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102bce:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0102bd3:	e8 54 eb ff ff       	call   f010172c <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bd8:	83 c4 10             	add    $0x10,%esp
f0102bdb:	b8 00 70 2e f0       	mov    $0xf02e7000,%eax
f0102be0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102be5:	0f 87 60 06 00 00    	ja     f010324b <mem_init+0x1922>
f0102beb:	eb 0c                	jmp    f0102bf9 <mem_init+0x12d0>
f0102bed:	89 d8                	mov    %ebx,%eax
f0102bef:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102bf5:	77 1c                	ja     f0102c13 <mem_init+0x12ea>
f0102bf7:	eb 05                	jmp    f0102bfe <mem_init+0x12d5>
	//
	// LAB 4: Your code here:
    
    int cpu_id;
    for (cpu_id = 0; cpu_id < NCPU; cpu_id++) {
        boot_map_region(kern_pgdir,
f0102bf9:	b8 00 70 2e f0       	mov    $0xf02e7000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bfe:	50                   	push   %eax
f0102bff:	68 44 68 10 f0       	push   $0xf0106844
f0102c04:	68 24 01 00 00       	push   $0x124
f0102c09:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102c0e:	e8 55 d4 ff ff       	call   f0100068 <_panic>
f0102c13:	83 ec 08             	sub    $0x8,%esp
f0102c16:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f0102c18:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102c1e:	50                   	push   %eax
f0102c1f:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102c24:	89 f2                	mov    %esi,%edx
f0102c26:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0102c2b:	e8 fc ea ff ff       	call   f010172c <boot_map_region>
f0102c30:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102c36:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
    
    int cpu_id;
    for (cpu_id = 0; cpu_id < NCPU; cpu_id++) {
f0102c3c:	83 c4 10             	add    $0x10,%esp
f0102c3f:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102c45:	75 a6                	jne    f0102bed <mem_init+0x12c4>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102c47:	8b 35 8c 5e 2e f0    	mov    0xf02e5e8c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102c4d:	a1 88 5e 2e f0       	mov    0xf02e5e88,%eax
f0102c52:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102c59:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102c5f:	74 63                	je     f0102cc4 <mem_init+0x139b>
f0102c61:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102c66:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102c6c:	89 f0                	mov    %esi,%eax
f0102c6e:	e8 34 e5 ff ff       	call   f01011a7 <check_va2pa>
f0102c73:	8b 15 90 5e 2e f0    	mov    0xf02e5e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c79:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102c7f:	77 15                	ja     f0102c96 <mem_init+0x136d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c81:	52                   	push   %edx
f0102c82:	68 44 68 10 f0       	push   $0xf0106844
f0102c87:	68 40 03 00 00       	push   $0x340
f0102c8c:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102c91:	e8 d2 d3 ff ff       	call   f0100068 <_panic>
f0102c96:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0102c9d:	39 d0                	cmp    %edx,%eax
f0102c9f:	74 19                	je     f0102cba <mem_init+0x1391>
f0102ca1:	68 e0 79 10 f0       	push   $0xf01079e0
f0102ca6:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102cab:	68 40 03 00 00       	push   $0x340
f0102cb0:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102cb5:	e8 ae d3 ff ff       	call   f0100068 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102cba:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102cc0:	39 df                	cmp    %ebx,%edi
f0102cc2:	77 a2                	ja     f0102c66 <mem_init+0x133d>
f0102cc4:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102cc9:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
f0102ccf:	89 f0                	mov    %esi,%eax
f0102cd1:	e8 d1 e4 ff ff       	call   f01011a7 <check_va2pa>
f0102cd6:	8b 15 3c 52 2e f0    	mov    0xf02e523c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cdc:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102ce2:	77 15                	ja     f0102cf9 <mem_init+0x13d0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ce4:	52                   	push   %edx
f0102ce5:	68 44 68 10 f0       	push   $0xf0106844
f0102cea:	68 45 03 00 00       	push   $0x345
f0102cef:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102cf4:	e8 6f d3 ff ff       	call   f0100068 <_panic>
f0102cf9:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0102d00:	39 d0                	cmp    %edx,%eax
f0102d02:	74 19                	je     f0102d1d <mem_init+0x13f4>
f0102d04:	68 14 7a 10 f0       	push   $0xf0107a14
f0102d09:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102d0e:	68 45 03 00 00       	push   $0x345
f0102d13:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102d18:	e8 4b d3 ff ff       	call   f0100068 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102d1d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d23:	81 fb 00 f0 01 00    	cmp    $0x1f000,%ebx
f0102d29:	75 9e                	jne    f0102cc9 <mem_init+0x13a0>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d2b:	a1 88 5e 2e f0       	mov    0xf02e5e88,%eax
f0102d30:	c1 e0 0c             	shl    $0xc,%eax
f0102d33:	74 41                	je     f0102d76 <mem_init+0x144d>
f0102d35:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102d3a:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102d40:	89 f0                	mov    %esi,%eax
f0102d42:	e8 60 e4 ff ff       	call   f01011a7 <check_va2pa>
f0102d47:	39 c3                	cmp    %eax,%ebx
f0102d49:	74 19                	je     f0102d64 <mem_init+0x143b>
f0102d4b:	68 48 7a 10 f0       	push   $0xf0107a48
f0102d50:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102d55:	68 49 03 00 00       	push   $0x349
f0102d5a:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102d5f:	e8 04 d3 ff ff       	call   f0100068 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d64:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d6a:	a1 88 5e 2e f0       	mov    0xf02e5e88,%eax
f0102d6f:	c1 e0 0c             	shl    $0xc,%eax
f0102d72:	39 c3                	cmp    %eax,%ebx
f0102d74:	72 c4                	jb     f0102d3a <mem_init+0x1411>
f0102d76:	c7 45 d0 00 70 2e f0 	movl   $0xf02e7000,-0x30(%ebp)
f0102d7d:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0102d82:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102d85:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	return (physaddr_t)kva - KERNBASE;
f0102d88:	89 de                	mov    %ebx,%esi
f0102d8a:	81 c6 00 00 00 10    	add    $0x10000000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d90:	8d 97 00 80 00 00    	lea    0x8000(%edi),%edx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102d96:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d99:	e8 09 e4 ff ff       	call   f01011a7 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d9e:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102da5:	77 15                	ja     f0102dbc <mem_init+0x1493>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102da7:	53                   	push   %ebx
f0102da8:	68 44 68 10 f0       	push   $0xf0106844
f0102dad:	68 51 03 00 00       	push   $0x351
f0102db2:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102db7:	e8 ac d2 ff ff       	call   f0100068 <_panic>

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102dbc:	bb 00 00 00 00       	mov    $0x0,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102dc1:	8d 97 00 80 00 00    	lea    0x8000(%edi),%edx
f0102dc7:	89 7d c8             	mov    %edi,-0x38(%ebp)
f0102dca:	89 d7                	mov    %edx,%edi
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102dcc:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102dcf:	39 d0                	cmp    %edx,%eax
f0102dd1:	74 19                	je     f0102dec <mem_init+0x14c3>
f0102dd3:	68 70 7a 10 f0       	push   $0xf0107a70
f0102dd8:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102ddd:	68 51 03 00 00       	push   $0x351
f0102de2:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102de7:	e8 7c d2 ff ff       	call   f0100068 <_panic>

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102dec:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102df2:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102df8:	0f 85 7d 04 00 00    	jne    f010327b <mem_init+0x1952>
f0102dfe:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102e01:	66 bb 00 00          	mov    $0x0,%bx
f0102e05:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102e08:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102e0b:	89 f0                	mov    %esi,%eax
f0102e0d:	e8 95 e3 ff ff       	call   f01011a7 <check_va2pa>
f0102e12:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102e15:	74 19                	je     f0102e30 <mem_init+0x1507>
f0102e17:	68 b8 7a 10 f0       	push   $0xf0107ab8
f0102e1c:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102e21:	68 53 03 00 00       	push   $0x353
f0102e26:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102e2b:	e8 38 d2 ff ff       	call   f0100068 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102e30:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e36:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102e3c:	75 ca                	jne    f0102e08 <mem_init+0x14df>
f0102e3e:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102e45:	81 ef 00 00 01 00    	sub    $0x10000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102e4b:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f0102e51:	0f 85 2e ff ff ff    	jne    f0102d85 <mem_init+0x145c>
f0102e57:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102e5a:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102e5f:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102e65:	83 fa 04             	cmp    $0x4,%edx
f0102e68:	77 1f                	ja     f0102e89 <mem_init+0x1560>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102e6a:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102e6e:	75 7e                	jne    f0102eee <mem_init+0x15c5>
f0102e70:	68 7a 7e 10 f0       	push   $0xf0107e7a
f0102e75:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102e7a:	68 5e 03 00 00       	push   $0x35e
f0102e7f:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102e84:	e8 df d1 ff ff       	call   f0100068 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102e89:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102e8e:	76 3f                	jbe    f0102ecf <mem_init+0x15a6>
				assert(pgdir[i] & PTE_P);
f0102e90:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102e93:	f6 c2 01             	test   $0x1,%dl
f0102e96:	75 19                	jne    f0102eb1 <mem_init+0x1588>
f0102e98:	68 7a 7e 10 f0       	push   $0xf0107e7a
f0102e9d:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102ea2:	68 62 03 00 00       	push   $0x362
f0102ea7:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102eac:	e8 b7 d1 ff ff       	call   f0100068 <_panic>
				assert(pgdir[i] & PTE_W);
f0102eb1:	f6 c2 02             	test   $0x2,%dl
f0102eb4:	75 38                	jne    f0102eee <mem_init+0x15c5>
f0102eb6:	68 8b 7e 10 f0       	push   $0xf0107e8b
f0102ebb:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102ec0:	68 63 03 00 00       	push   $0x363
f0102ec5:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102eca:	e8 99 d1 ff ff       	call   f0100068 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102ecf:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102ed3:	74 19                	je     f0102eee <mem_init+0x15c5>
f0102ed5:	68 9c 7e 10 f0       	push   $0xf0107e9c
f0102eda:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102edf:	68 65 03 00 00       	push   $0x365
f0102ee4:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102ee9:	e8 7a d1 ff ff       	call   f0100068 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102eee:	40                   	inc    %eax
f0102eef:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102ef4:	0f 85 65 ff ff ff    	jne    f0102e5f <mem_init+0x1536>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102efa:	83 ec 0c             	sub    $0xc,%esp
f0102efd:	68 dc 7a 10 f0       	push   $0xf0107adc
f0102f02:	e8 56 0e 00 00       	call   f0103d5d <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102f07:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f0c:	83 c4 10             	add    $0x10,%esp
f0102f0f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f14:	77 15                	ja     f0102f2b <mem_init+0x1602>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f16:	50                   	push   %eax
f0102f17:	68 44 68 10 f0       	push   $0xf0106844
f0102f1c:	68 f9 00 00 00       	push   $0xf9
f0102f21:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102f26:	e8 3d d1 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102f2b:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102f30:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102f33:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f38:	e8 f3 e2 ff ff       	call   f0101230 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102f3d:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102f40:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102f45:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102f48:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102f4b:	83 ec 0c             	sub    $0xc,%esp
f0102f4e:	6a 00                	push   $0x0
f0102f50:	e8 78 e6 ff ff       	call   f01015cd <page_alloc>
f0102f55:	89 c6                	mov    %eax,%esi
f0102f57:	83 c4 10             	add    $0x10,%esp
f0102f5a:	85 c0                	test   %eax,%eax
f0102f5c:	75 19                	jne    f0102f77 <mem_init+0x164e>
f0102f5e:	68 bf 7c 10 f0       	push   $0xf0107cbf
f0102f63:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102f68:	68 32 04 00 00       	push   $0x432
f0102f6d:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102f72:	e8 f1 d0 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0102f77:	83 ec 0c             	sub    $0xc,%esp
f0102f7a:	6a 00                	push   $0x0
f0102f7c:	e8 4c e6 ff ff       	call   f01015cd <page_alloc>
f0102f81:	89 c7                	mov    %eax,%edi
f0102f83:	83 c4 10             	add    $0x10,%esp
f0102f86:	85 c0                	test   %eax,%eax
f0102f88:	75 19                	jne    f0102fa3 <mem_init+0x167a>
f0102f8a:	68 d5 7c 10 f0       	push   $0xf0107cd5
f0102f8f:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102f94:	68 33 04 00 00       	push   $0x433
f0102f99:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102f9e:	e8 c5 d0 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0102fa3:	83 ec 0c             	sub    $0xc,%esp
f0102fa6:	6a 00                	push   $0x0
f0102fa8:	e8 20 e6 ff ff       	call   f01015cd <page_alloc>
f0102fad:	89 c3                	mov    %eax,%ebx
f0102faf:	83 c4 10             	add    $0x10,%esp
f0102fb2:	85 c0                	test   %eax,%eax
f0102fb4:	75 19                	jne    f0102fcf <mem_init+0x16a6>
f0102fb6:	68 eb 7c 10 f0       	push   $0xf0107ceb
f0102fbb:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0102fc0:	68 34 04 00 00       	push   $0x434
f0102fc5:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0102fca:	e8 99 d0 ff ff       	call   f0100068 <_panic>
	page_free(pp0);
f0102fcf:	83 ec 0c             	sub    $0xc,%esp
f0102fd2:	56                   	push   %esi
f0102fd3:	e8 7f e6 ff ff       	call   f0101657 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102fd8:	89 f8                	mov    %edi,%eax
f0102fda:	2b 05 90 5e 2e f0    	sub    0xf02e5e90,%eax
f0102fe0:	c1 f8 03             	sar    $0x3,%eax
f0102fe3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102fe6:	89 c2                	mov    %eax,%edx
f0102fe8:	c1 ea 0c             	shr    $0xc,%edx
f0102feb:	83 c4 10             	add    $0x10,%esp
f0102fee:	3b 15 88 5e 2e f0    	cmp    0xf02e5e88,%edx
f0102ff4:	72 12                	jb     f0103008 <mem_init+0x16df>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ff6:	50                   	push   %eax
f0102ff7:	68 68 68 10 f0       	push   $0xf0106868
f0102ffc:	6a 58                	push   $0x58
f0102ffe:	68 dd 7b 10 f0       	push   $0xf0107bdd
f0103003:	e8 60 d0 ff ff       	call   f0100068 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103008:	83 ec 04             	sub    $0x4,%esp
f010300b:	68 00 10 00 00       	push   $0x1000
f0103010:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103012:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103017:	50                   	push   %eax
f0103018:	e8 08 2b 00 00       	call   f0105b25 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010301d:	89 d8                	mov    %ebx,%eax
f010301f:	2b 05 90 5e 2e f0    	sub    0xf02e5e90,%eax
f0103025:	c1 f8 03             	sar    $0x3,%eax
f0103028:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010302b:	89 c2                	mov    %eax,%edx
f010302d:	c1 ea 0c             	shr    $0xc,%edx
f0103030:	83 c4 10             	add    $0x10,%esp
f0103033:	3b 15 88 5e 2e f0    	cmp    0xf02e5e88,%edx
f0103039:	72 12                	jb     f010304d <mem_init+0x1724>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010303b:	50                   	push   %eax
f010303c:	68 68 68 10 f0       	push   $0xf0106868
f0103041:	6a 58                	push   $0x58
f0103043:	68 dd 7b 10 f0       	push   $0xf0107bdd
f0103048:	e8 1b d0 ff ff       	call   f0100068 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010304d:	83 ec 04             	sub    $0x4,%esp
f0103050:	68 00 10 00 00       	push   $0x1000
f0103055:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0103057:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010305c:	50                   	push   %eax
f010305d:	e8 c3 2a 00 00       	call   f0105b25 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103062:	6a 02                	push   $0x2
f0103064:	68 00 10 00 00       	push   $0x1000
f0103069:	57                   	push   %edi
f010306a:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f0103070:	e8 04 e8 ff ff       	call   f0101879 <page_insert>
	assert(pp1->pp_ref == 1);
f0103075:	83 c4 20             	add    $0x20,%esp
f0103078:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010307d:	74 19                	je     f0103098 <mem_init+0x176f>
f010307f:	68 bc 7d 10 f0       	push   $0xf0107dbc
f0103084:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0103089:	68 39 04 00 00       	push   $0x439
f010308e:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0103093:	e8 d0 cf ff ff       	call   f0100068 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103098:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010309f:	01 01 01 
f01030a2:	74 19                	je     f01030bd <mem_init+0x1794>
f01030a4:	68 fc 7a 10 f0       	push   $0xf0107afc
f01030a9:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01030ae:	68 3a 04 00 00       	push   $0x43a
f01030b3:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01030b8:	e8 ab cf ff ff       	call   f0100068 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01030bd:	6a 02                	push   $0x2
f01030bf:	68 00 10 00 00       	push   $0x1000
f01030c4:	53                   	push   %ebx
f01030c5:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f01030cb:	e8 a9 e7 ff ff       	call   f0101879 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01030d0:	83 c4 10             	add    $0x10,%esp
f01030d3:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01030da:	02 02 02 
f01030dd:	74 19                	je     f01030f8 <mem_init+0x17cf>
f01030df:	68 20 7b 10 f0       	push   $0xf0107b20
f01030e4:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01030e9:	68 3c 04 00 00       	push   $0x43c
f01030ee:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01030f3:	e8 70 cf ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f01030f8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01030fd:	74 19                	je     f0103118 <mem_init+0x17ef>
f01030ff:	68 de 7d 10 f0       	push   $0xf0107dde
f0103104:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0103109:	68 3d 04 00 00       	push   $0x43d
f010310e:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0103113:	e8 50 cf ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 0);
f0103118:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010311d:	74 19                	je     f0103138 <mem_init+0x180f>
f010311f:	68 27 7e 10 f0       	push   $0xf0107e27
f0103124:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0103129:	68 3e 04 00 00       	push   $0x43e
f010312e:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0103133:	e8 30 cf ff ff       	call   f0100068 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103138:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010313f:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103142:	89 d8                	mov    %ebx,%eax
f0103144:	2b 05 90 5e 2e f0    	sub    0xf02e5e90,%eax
f010314a:	c1 f8 03             	sar    $0x3,%eax
f010314d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103150:	89 c2                	mov    %eax,%edx
f0103152:	c1 ea 0c             	shr    $0xc,%edx
f0103155:	3b 15 88 5e 2e f0    	cmp    0xf02e5e88,%edx
f010315b:	72 12                	jb     f010316f <mem_init+0x1846>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010315d:	50                   	push   %eax
f010315e:	68 68 68 10 f0       	push   $0xf0106868
f0103163:	6a 58                	push   $0x58
f0103165:	68 dd 7b 10 f0       	push   $0xf0107bdd
f010316a:	e8 f9 ce ff ff       	call   f0100068 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010316f:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103176:	03 03 03 
f0103179:	74 19                	je     f0103194 <mem_init+0x186b>
f010317b:	68 44 7b 10 f0       	push   $0xf0107b44
f0103180:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0103185:	68 40 04 00 00       	push   $0x440
f010318a:	68 d1 7b 10 f0       	push   $0xf0107bd1
f010318f:	e8 d4 ce ff ff       	call   f0100068 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103194:	83 ec 08             	sub    $0x8,%esp
f0103197:	68 00 10 00 00       	push   $0x1000
f010319c:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f01031a2:	e8 85 e6 ff ff       	call   f010182c <page_remove>
	assert(pp2->pp_ref == 0);
f01031a7:	83 c4 10             	add    $0x10,%esp
f01031aa:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01031af:	74 19                	je     f01031ca <mem_init+0x18a1>
f01031b1:	68 16 7e 10 f0       	push   $0xf0107e16
f01031b6:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01031bb:	68 42 04 00 00       	push   $0x442
f01031c0:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01031c5:	e8 9e ce ff ff       	call   f0100068 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01031ca:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f01031cf:	8b 08                	mov    (%eax),%ecx
f01031d1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01031d7:	89 f2                	mov    %esi,%edx
f01031d9:	2b 15 90 5e 2e f0    	sub    0xf02e5e90,%edx
f01031df:	c1 fa 03             	sar    $0x3,%edx
f01031e2:	c1 e2 0c             	shl    $0xc,%edx
f01031e5:	39 d1                	cmp    %edx,%ecx
f01031e7:	74 19                	je     f0103202 <mem_init+0x18d9>
f01031e9:	68 04 75 10 f0       	push   $0xf0107504
f01031ee:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01031f3:	68 45 04 00 00       	push   $0x445
f01031f8:	68 d1 7b 10 f0       	push   $0xf0107bd1
f01031fd:	e8 66 ce ff ff       	call   f0100068 <_panic>
	kern_pgdir[0] = 0;
f0103202:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103208:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010320d:	74 19                	je     f0103228 <mem_init+0x18ff>
f010320f:	68 cd 7d 10 f0       	push   $0xf0107dcd
f0103214:	68 f7 7b 10 f0       	push   $0xf0107bf7
f0103219:	68 47 04 00 00       	push   $0x447
f010321e:	68 d1 7b 10 f0       	push   $0xf0107bd1
f0103223:	e8 40 ce ff ff       	call   f0100068 <_panic>
	pp0->pp_ref = 0;
f0103228:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010322e:	83 ec 0c             	sub    $0xc,%esp
f0103231:	56                   	push   %esi
f0103232:	e8 20 e4 ff ff       	call   f0101657 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103237:	c7 04 24 70 7b 10 f0 	movl   $0xf0107b70,(%esp)
f010323e:	e8 1a 0b 00 00       	call   f0103d5d <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103243:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103246:	5b                   	pop    %ebx
f0103247:	5e                   	pop    %esi
f0103248:	5f                   	pop    %edi
f0103249:	c9                   	leave  
f010324a:	c3                   	ret    
	//
	// LAB 4: Your code here:
    
    int cpu_id;
    for (cpu_id = 0; cpu_id < NCPU; cpu_id++) {
        boot_map_region(kern_pgdir,
f010324b:	83 ec 08             	sub    $0x8,%esp
f010324e:	6a 02                	push   $0x2
f0103250:	68 00 70 2e 00       	push   $0x2e7000
f0103255:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010325a:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010325f:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0103264:	e8 c3 e4 ff ff       	call   f010172c <boot_map_region>
f0103269:	bb 00 f0 2e f0       	mov    $0xf02ef000,%ebx
f010326e:	83 c4 10             	add    $0x10,%esp
f0103271:	be 00 80 fe ef       	mov    $0xeffe8000,%esi
f0103276:	e9 72 f9 ff ff       	jmp    f0102bed <mem_init+0x12c4>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010327b:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f010327e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103281:	e8 21 df ff ff       	call   f01011a7 <check_va2pa>
f0103286:	e9 41 fb ff ff       	jmp    f0102dcc <mem_init+0x14a3>

f010328b <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010328b:	55                   	push   %ebp
f010328c:	89 e5                	mov    %esp,%ebp
f010328e:	57                   	push   %edi
f010328f:	56                   	push   %esi
f0103290:	53                   	push   %ebx
f0103291:	83 ec 1c             	sub    $0x1c,%esp
f0103294:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103297:	8b 45 0c             	mov    0xc(%ebp),%eax
f010329a:	8b 55 10             	mov    0x10(%ebp),%edx
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f010329d:	85 d2                	test   %edx,%edx
f010329f:	0f 84 85 00 00 00    	je     f010332a <user_mem_check+0x9f>

	perm |= PTE_P;
f01032a5:	8b 75 14             	mov    0x14(%ebp),%esi
f01032a8:	83 ce 01             	or     $0x1,%esi
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
f01032ab:	89 c3                	mov    %eax,%ebx
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
f01032ad:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f01032b4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01032ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f01032bd:	89 c2                	mov    %eax,%edx
f01032bf:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01032c5:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f01032c8:	74 67                	je     f0103331 <user_mem_check+0xa6>
		if (va_now >= ULIM) {
f01032ca:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01032cf:	76 17                	jbe    f01032e8 <user_mem_check+0x5d>
f01032d1:	eb 08                	jmp    f01032db <user_mem_check+0x50>
f01032d3:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01032d9:	76 0d                	jbe    f01032e8 <user_mem_check+0x5d>
			user_mem_check_addr = va_now;
f01032db:	89 1d 2c 52 2e f0    	mov    %ebx,0xf02e522c
			return -E_FAULT;
f01032e1:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01032e6:	eb 4e                	jmp    f0103336 <user_mem_check+0xab>
		}
		pte = pgdir_walk(env->env_pgdir, (void *)va_now, false);
f01032e8:	83 ec 04             	sub    $0x4,%esp
f01032eb:	6a 00                	push   $0x0
f01032ed:	53                   	push   %ebx
f01032ee:	ff 77 60             	pushl  0x60(%edi)
f01032f1:	e8 9f e3 ff ff       	call   f0101695 <pgdir_walk>
		if (pte == NULL || ((*pte & perm ) != perm)) {
f01032f6:	83 c4 10             	add    $0x10,%esp
f01032f9:	85 c0                	test   %eax,%eax
f01032fb:	74 08                	je     f0103305 <user_mem_check+0x7a>
f01032fd:	8b 00                	mov    (%eax),%eax
f01032ff:	21 f0                	and    %esi,%eax
f0103301:	39 c6                	cmp    %eax,%esi
f0103303:	74 0d                	je     f0103312 <user_mem_check+0x87>
			user_mem_check_addr = va_now;
f0103305:	89 1d 2c 52 2e f0    	mov    %ebx,0xf02e522c
			return -E_FAULT;
f010330b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103310:	eb 24                	jmp    f0103336 <user_mem_check+0xab>

	perm |= PTE_P;
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f0103312:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103318:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010331e:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0103321:	75 b0                	jne    f01032d3 <user_mem_check+0x48>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0103323:	b8 00 00 00 00       	mov    $0x0,%eax
f0103328:	eb 0c                	jmp    f0103336 <user_mem_check+0xab>
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f010332a:	b8 00 00 00 00       	mov    $0x0,%eax
f010332f:	eb 05                	jmp    f0103336 <user_mem_check+0xab>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0103331:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103336:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103339:	5b                   	pop    %ebx
f010333a:	5e                   	pop    %esi
f010333b:	5f                   	pop    %edi
f010333c:	c9                   	leave  
f010333d:	c3                   	ret    

f010333e <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010333e:	55                   	push   %ebp
f010333f:	89 e5                	mov    %esp,%ebp
f0103341:	53                   	push   %ebx
f0103342:	83 ec 04             	sub    $0x4,%esp
f0103345:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103348:	8b 45 14             	mov    0x14(%ebp),%eax
f010334b:	83 c8 04             	or     $0x4,%eax
f010334e:	50                   	push   %eax
f010334f:	ff 75 10             	pushl  0x10(%ebp)
f0103352:	ff 75 0c             	pushl  0xc(%ebp)
f0103355:	53                   	push   %ebx
f0103356:	e8 30 ff ff ff       	call   f010328b <user_mem_check>
f010335b:	83 c4 10             	add    $0x10,%esp
f010335e:	85 c0                	test   %eax,%eax
f0103360:	79 21                	jns    f0103383 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103362:	83 ec 04             	sub    $0x4,%esp
f0103365:	ff 35 2c 52 2e f0    	pushl  0xf02e522c
f010336b:	ff 73 48             	pushl  0x48(%ebx)
f010336e:	68 9c 7b 10 f0       	push   $0xf0107b9c
f0103373:	e8 e5 09 00 00       	call   f0103d5d <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103378:	89 1c 24             	mov    %ebx,(%esp)
f010337b:	e8 bb 06 00 00       	call   f0103a3b <env_destroy>
f0103380:	83 c4 10             	add    $0x10,%esp
	}
}
f0103383:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103386:	c9                   	leave  
f0103387:	c3                   	ret    

f0103388 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103388:	55                   	push   %ebp
f0103389:	89 e5                	mov    %esp,%ebp
f010338b:	57                   	push   %edi
f010338c:	56                   	push   %esi
f010338d:	53                   	push   %ebx
f010338e:	83 ec 0c             	sub    $0xc,%esp
f0103391:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0103393:	89 d3                	mov    %edx,%ebx
f0103395:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
f010339b:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f01033a2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f01033a8:	39 fb                	cmp    %edi,%ebx
f01033aa:	74 5a                	je     f0103406 <region_alloc+0x7e>
        pg = page_alloc(1);
f01033ac:	83 ec 0c             	sub    $0xc,%esp
f01033af:	6a 01                	push   $0x1
f01033b1:	e8 17 e2 ff ff       	call   f01015cd <page_alloc>
        if (pg == NULL) {
f01033b6:	83 c4 10             	add    $0x10,%esp
f01033b9:	85 c0                	test   %eax,%eax
f01033bb:	75 17                	jne    f01033d4 <region_alloc+0x4c>
            panic("region_alloc : can't alloc page\n");
f01033bd:	83 ec 04             	sub    $0x4,%esp
f01033c0:	68 ac 7e 10 f0       	push   $0xf0107eac
f01033c5:	68 32 01 00 00       	push   $0x132
f01033ca:	68 ef 7e 10 f0       	push   $0xf0107eef
f01033cf:	e8 94 cc ff ff       	call   f0100068 <_panic>
        } else {
            r = page_insert(e->env_pgdir, pg, (void *)addr, PTE_U | PTE_W);
f01033d4:	6a 06                	push   $0x6
f01033d6:	53                   	push   %ebx
f01033d7:	50                   	push   %eax
f01033d8:	ff 76 60             	pushl  0x60(%esi)
f01033db:	e8 99 e4 ff ff       	call   f0101879 <page_insert>
            if (r != 0) {
f01033e0:	83 c4 10             	add    $0x10,%esp
f01033e3:	85 c0                	test   %eax,%eax
f01033e5:	74 15                	je     f01033fc <region_alloc+0x74>
                panic("/kern/env.c/region_alloc : %e\n", r);
f01033e7:	50                   	push   %eax
f01033e8:	68 d0 7e 10 f0       	push   $0xf0107ed0
f01033ed:	68 36 01 00 00       	push   $0x136
f01033f2:	68 ef 7e 10 f0       	push   $0xf0107eef
f01033f7:	e8 6c cc ff ff       	call   f0100068 <_panic>
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f01033fc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103402:	39 df                	cmp    %ebx,%edi
f0103404:	75 a6                	jne    f01033ac <region_alloc+0x24>
                panic("/kern/env.c/region_alloc : %e\n", r);
            }
        }
    }
    return;
}
f0103406:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103409:	5b                   	pop    %ebx
f010340a:	5e                   	pop    %esi
f010340b:	5f                   	pop    %edi
f010340c:	c9                   	leave  
f010340d:	c3                   	ret    

f010340e <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010340e:	55                   	push   %ebp
f010340f:	89 e5                	mov    %esp,%ebp
f0103411:	57                   	push   %edi
f0103412:	56                   	push   %esi
f0103413:	53                   	push   %ebx
f0103414:	83 ec 0c             	sub    $0xc,%esp
f0103417:	8b 45 08             	mov    0x8(%ebp),%eax
f010341a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010341d:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103420:	85 c0                	test   %eax,%eax
f0103422:	75 24                	jne    f0103448 <envid2env+0x3a>
		*env_store = curenv;
f0103424:	e8 2b 2d 00 00       	call   f0106154 <cpunum>
f0103429:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103430:	29 c2                	sub    %eax,%edx
f0103432:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103435:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f010343c:	89 06                	mov    %eax,(%esi)
		return 0;
f010343e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103443:	e9 84 00 00 00       	jmp    f01034cc <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103448:	89 c3                	mov    %eax,%ebx
f010344a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103450:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0103457:	c1 e3 07             	shl    $0x7,%ebx
f010345a:	29 cb                	sub    %ecx,%ebx
f010345c:	03 1d 3c 52 2e f0    	add    0xf02e523c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103462:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103466:	74 05                	je     f010346d <envid2env+0x5f>
f0103468:	39 43 48             	cmp    %eax,0x48(%ebx)
f010346b:	74 0d                	je     f010347a <envid2env+0x6c>
		*env_store = 0;
f010346d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103473:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103478:	eb 52                	jmp    f01034cc <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010347a:	84 d2                	test   %dl,%dl
f010347c:	74 47                	je     f01034c5 <envid2env+0xb7>
f010347e:	e8 d1 2c 00 00       	call   f0106154 <cpunum>
f0103483:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010348a:	29 c2                	sub    %eax,%edx
f010348c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010348f:	39 1c 85 28 60 2e f0 	cmp    %ebx,-0xfd19fd8(,%eax,4)
f0103496:	74 2d                	je     f01034c5 <envid2env+0xb7>
f0103498:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f010349b:	e8 b4 2c 00 00       	call   f0106154 <cpunum>
f01034a0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01034a7:	29 c2                	sub    %eax,%edx
f01034a9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01034ac:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f01034b3:	3b 78 48             	cmp    0x48(%eax),%edi
f01034b6:	74 0d                	je     f01034c5 <envid2env+0xb7>
		*env_store = 0;
f01034b8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01034be:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01034c3:	eb 07                	jmp    f01034cc <envid2env+0xbe>
	}

	*env_store = e;
f01034c5:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01034c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034cc:	83 c4 0c             	add    $0xc,%esp
f01034cf:	5b                   	pop    %ebx
f01034d0:	5e                   	pop    %esi
f01034d1:	5f                   	pop    %edi
f01034d2:	c9                   	leave  
f01034d3:	c3                   	ret    

f01034d4 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01034d4:	55                   	push   %ebp
f01034d5:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01034d7:	b8 88 83 12 f0       	mov    $0xf0128388,%eax
f01034dc:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01034df:	b8 23 00 00 00       	mov    $0x23,%eax
f01034e4:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01034e6:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01034e8:	b0 10                	mov    $0x10,%al
f01034ea:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01034ec:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01034ee:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01034f0:	ea f7 34 10 f0 08 00 	ljmp   $0x8,$0xf01034f7
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01034f7:	b0 00                	mov    $0x0,%al
f01034f9:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01034fc:	c9                   	leave  
f01034fd:	c3                   	ret    

f01034fe <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01034fe:	55                   	push   %ebp
f01034ff:	89 e5                	mov    %esp,%ebp
f0103501:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
f0103502:	8b 1d 3c 52 2e f0    	mov    0xf02e523c,%ebx
f0103508:	89 1d 40 52 2e f0    	mov    %ebx,0xf02e5240
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
f010350e:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        envs[i].env_status = ENV_FREE;
f0103515:	c7 43 54 00 00 00 00 	movl   $0x0,0x54(%ebx)
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f010351c:	8d 43 7c             	lea    0x7c(%ebx),%eax
f010351f:	8d 8b 00 f0 01 00    	lea    0x1f000(%ebx),%ecx
f0103525:	89 c2                	mov    %eax,%edx
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0103527:	89 43 44             	mov    %eax,0x44(%ebx)
{
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
f010352a:	39 c8                	cmp    %ecx,%eax
f010352c:	74 1c                	je     f010354a <env_init+0x4c>
        envs[i].env_id = 0;
f010352e:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE;
f0103535:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f010353c:	83 c0 7c             	add    $0x7c,%eax
        if (i + 1 != NENV)
f010353f:	39 c8                	cmp    %ecx,%eax
f0103541:	75 0f                	jne    f0103552 <env_init+0x54>
            envs[i].env_link = envs + (i + 1);
        else 
            envs[i].env_link = NULL;
f0103543:	c7 42 44 00 00 00 00 	movl   $0x0,0x44(%edx)
    }

	// Per-CPU part of the initialization
	env_init_percpu();
f010354a:	e8 85 ff ff ff       	call   f01034d4 <env_init_percpu>
}
f010354f:	5b                   	pop    %ebx
f0103550:	c9                   	leave  
f0103551:	c3                   	ret    
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0103552:	89 42 44             	mov    %eax,0x44(%edx)
f0103555:	89 c2                	mov    %eax,%edx
f0103557:	eb d5                	jmp    f010352e <env_init+0x30>

f0103559 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103559:	55                   	push   %ebp
f010355a:	89 e5                	mov    %esp,%ebp
f010355c:	56                   	push   %esi
f010355d:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010355e:	8b 1d 40 52 2e f0    	mov    0xf02e5240,%ebx
f0103564:	85 db                	test   %ebx,%ebx
f0103566:	0f 84 aa 01 00 00    	je     f0103716 <env_alloc+0x1bd>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010356c:	83 ec 0c             	sub    $0xc,%esp
f010356f:	6a 01                	push   $0x1
f0103571:	e8 57 e0 ff ff       	call   f01015cd <page_alloc>
f0103576:	83 c4 10             	add    $0x10,%esp
f0103579:	85 c0                	test   %eax,%eax
f010357b:	0f 84 9c 01 00 00    	je     f010371d <env_alloc+0x1c4>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    p->pp_ref++;
f0103581:	66 ff 40 04          	incw   0x4(%eax)
f0103585:	2b 05 90 5e 2e f0    	sub    0xf02e5e90,%eax
f010358b:	c1 f8 03             	sar    $0x3,%eax
f010358e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103591:	89 c2                	mov    %eax,%edx
f0103593:	c1 ea 0c             	shr    $0xc,%edx
f0103596:	3b 15 88 5e 2e f0    	cmp    0xf02e5e88,%edx
f010359c:	72 12                	jb     f01035b0 <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010359e:	50                   	push   %eax
f010359f:	68 68 68 10 f0       	push   $0xf0106868
f01035a4:	6a 58                	push   $0x58
f01035a6:	68 dd 7b 10 f0       	push   $0xf0107bdd
f01035ab:	e8 b8 ca ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f01035b0:	2d 00 00 00 10       	sub    $0x10000000,%eax
    e->env_pgdir = (pde_t *)page2kva(p);
f01035b5:	89 43 60             	mov    %eax,0x60(%ebx)
    
    memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01035b8:	83 ec 04             	sub    $0x4,%esp
f01035bb:	68 00 10 00 00       	push   $0x1000
f01035c0:	ff 35 8c 5e 2e f0    	pushl  0xf02e5e8c
f01035c6:	50                   	push   %eax
f01035c7:	e8 0d 26 00 00       	call   f0105bd9 <memcpy>
    memset(e->env_pgdir, 0, PDX(UTOP) * sizeof(pde_t));
f01035cc:	83 c4 0c             	add    $0xc,%esp
f01035cf:	68 ec 0e 00 00       	push   $0xeec
f01035d4:	6a 00                	push   $0x0
f01035d6:	ff 73 60             	pushl  0x60(%ebx)
f01035d9:	e8 47 25 00 00       	call   f0105b25 <memset>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01035de:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035e1:	83 c4 10             	add    $0x10,%esp
f01035e4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035e9:	77 15                	ja     f0103600 <env_alloc+0xa7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035eb:	50                   	push   %eax
f01035ec:	68 44 68 10 f0       	push   $0xf0106844
f01035f1:	68 cb 00 00 00       	push   $0xcb
f01035f6:	68 ef 7e 10 f0       	push   $0xf0107eef
f01035fb:	e8 68 ca ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103600:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103606:	83 ca 05             	or     $0x5,%edx
f0103609:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
    
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010360f:	8b 43 48             	mov    0x48(%ebx),%eax
f0103612:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103617:	89 c1                	mov    %eax,%ecx
f0103619:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f010361f:	7f 05                	jg     f0103626 <env_alloc+0xcd>
		generation = 1 << ENVGENSHIFT;
f0103621:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0103626:	89 d8                	mov    %ebx,%eax
f0103628:	2b 05 3c 52 2e f0    	sub    0xf02e523c,%eax
f010362e:	c1 f8 02             	sar    $0x2,%eax
f0103631:	89 c6                	mov    %eax,%esi
f0103633:	c1 e6 05             	shl    $0x5,%esi
f0103636:	89 c2                	mov    %eax,%edx
f0103638:	c1 e2 0a             	shl    $0xa,%edx
f010363b:	8d 14 16             	lea    (%esi,%edx,1),%edx
f010363e:	01 c2                	add    %eax,%edx
f0103640:	89 d6                	mov    %edx,%esi
f0103642:	c1 e6 0f             	shl    $0xf,%esi
f0103645:	01 f2                	add    %esi,%edx
f0103647:	c1 e2 05             	shl    $0x5,%edx
f010364a:	8d 04 02             	lea    (%edx,%eax,1),%eax
f010364d:	f7 d8                	neg    %eax
f010364f:	09 c1                	or     %eax,%ecx
f0103651:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103654:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103657:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010365a:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103661:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103668:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010366f:	83 ec 04             	sub    $0x4,%esp
f0103672:	6a 44                	push   $0x44
f0103674:	6a 00                	push   $0x0
f0103676:	53                   	push   %ebx
f0103677:	e8 a9 24 00 00       	call   f0105b25 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010367c:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103682:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103688:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010368e:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103695:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f010369b:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01036a2:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01036a9:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01036ad:	8b 43 44             	mov    0x44(%ebx),%eax
f01036b0:	a3 40 52 2e f0       	mov    %eax,0xf02e5240
	*newenv_store = e;
f01036b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01036b8:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01036ba:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01036bd:	e8 92 2a 00 00       	call   f0106154 <cpunum>
f01036c2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01036c9:	29 c2                	sub    %eax,%edx
f01036cb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036ce:	83 c4 10             	add    $0x10,%esp
f01036d1:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f01036d8:	00 
f01036d9:	74 1d                	je     f01036f8 <env_alloc+0x19f>
f01036db:	e8 74 2a 00 00       	call   f0106154 <cpunum>
f01036e0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01036e7:	29 c2                	sub    %eax,%edx
f01036e9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036ec:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f01036f3:	8b 40 48             	mov    0x48(%eax),%eax
f01036f6:	eb 05                	jmp    f01036fd <env_alloc+0x1a4>
f01036f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01036fd:	83 ec 04             	sub    $0x4,%esp
f0103700:	53                   	push   %ebx
f0103701:	50                   	push   %eax
f0103702:	68 fa 7e 10 f0       	push   $0xf0107efa
f0103707:	e8 51 06 00 00       	call   f0103d5d <cprintf>
	return 0;
f010370c:	83 c4 10             	add    $0x10,%esp
f010370f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103714:	eb 0c                	jmp    f0103722 <env_alloc+0x1c9>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103716:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010371b:	eb 05                	jmp    f0103722 <env_alloc+0x1c9>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010371d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103722:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103725:	5b                   	pop    %ebx
f0103726:	5e                   	pop    %esi
f0103727:	c9                   	leave  
f0103728:	c3                   	ret    

f0103729 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103729:	55                   	push   %ebp
f010372a:	89 e5                	mov    %esp,%ebp
f010372c:	57                   	push   %edi
f010372d:	56                   	push   %esi
f010372e:	53                   	push   %ebx
f010372f:	83 ec 34             	sub    $0x34,%esp
f0103732:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("env_create %u %u %u\n", binary, size, type);
	// LAB 3: Your code here.
    struct Env * e;
    int r = env_alloc(&e, 0);
f0103735:	6a 00                	push   $0x0
f0103737:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010373a:	50                   	push   %eax
f010373b:	e8 19 fe ff ff       	call   f0103559 <env_alloc>
    if (r < 0) {
f0103740:	83 c4 10             	add    $0x10,%esp
f0103743:	85 c0                	test   %eax,%eax
f0103745:	79 15                	jns    f010375c <env_create+0x33>
        panic("env_create: %e\n", r);
f0103747:	50                   	push   %eax
f0103748:	68 0f 7f 10 f0       	push   $0xf0107f0f
f010374d:	68 a0 01 00 00       	push   $0x1a0
f0103752:	68 ef 7e 10 f0       	push   $0xf0107eef
f0103757:	e8 0c c9 ff ff       	call   f0100068 <_panic>
    }
    load_icode(e, binary, size);
f010375c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010375f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
f0103762:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103768:	74 17                	je     f0103781 <env_create+0x58>
        panic("error elf magic number\n");
f010376a:	83 ec 04             	sub    $0x4,%esp
f010376d:	68 1f 7f 10 f0       	push   $0xf0107f1f
f0103772:	68 75 01 00 00       	push   $0x175
f0103777:	68 ef 7e 10 f0       	push   $0xf0107eef
f010377c:	e8 e7 c8 ff ff       	call   f0100068 <_panic>
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0103781:	8b 5e 1c             	mov    0x1c(%esi),%ebx
    eph = ph + elf->e_phnum;
f0103784:	8b 7e 2c             	mov    0x2c(%esi),%edi

    lcr3(PADDR(e->env_pgdir));
f0103787:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010378a:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010378d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103792:	77 15                	ja     f01037a9 <env_create+0x80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103794:	50                   	push   %eax
f0103795:	68 44 68 10 f0       	push   $0xf0106844
f010379a:	68 7b 01 00 00       	push   $0x17b
f010379f:	68 ef 7e 10 f0       	push   $0xf0107eef
f01037a4:	e8 bf c8 ff ff       	call   f0100068 <_panic>
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
        panic("error elf magic number\n");
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01037a9:	8d 1c 1e             	lea    (%esi,%ebx,1),%ebx
    eph = ph + elf->e_phnum;
f01037ac:	0f b7 ff             	movzwl %di,%edi
f01037af:	c1 e7 05             	shl    $0x5,%edi
f01037b2:	8d 3c 3b             	lea    (%ebx,%edi,1),%edi
	return (physaddr_t)kva - KERNBASE;
f01037b5:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01037ba:	0f 22 d8             	mov    %eax,%cr3

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01037bd:	39 fb                	cmp    %edi,%ebx
f01037bf:	73 48                	jae    f0103809 <env_create+0xe0>
        if (ph->p_type == ELF_PROG_LOAD) {
f01037c1:	83 3b 01             	cmpl   $0x1,(%ebx)
f01037c4:	75 3c                	jne    f0103802 <env_create+0xd9>
            // cprintf("%u %u\n", ph->p_memsz, ph->p_filesz);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01037c6:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01037c9:	8b 53 08             	mov    0x8(%ebx),%edx
f01037cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01037cf:	e8 b4 fb ff ff       	call   f0103388 <region_alloc>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01037d4:	83 ec 04             	sub    $0x4,%esp
f01037d7:	ff 73 10             	pushl  0x10(%ebx)
f01037da:	89 f0                	mov    %esi,%eax
f01037dc:	03 43 04             	add    0x4(%ebx),%eax
f01037df:	50                   	push   %eax
f01037e0:	ff 73 08             	pushl  0x8(%ebx)
f01037e3:	e8 f1 23 00 00       	call   f0105bd9 <memcpy>
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f01037e8:	8b 43 10             	mov    0x10(%ebx),%eax
f01037eb:	83 c4 0c             	add    $0xc,%esp
f01037ee:	8b 53 14             	mov    0x14(%ebx),%edx
f01037f1:	29 c2                	sub    %eax,%edx
f01037f3:	52                   	push   %edx
f01037f4:	6a 00                	push   $0x0
f01037f6:	03 43 08             	add    0x8(%ebx),%eax
f01037f9:	50                   	push   %eax
f01037fa:	e8 26 23 00 00       	call   f0105b25 <memset>
f01037ff:	83 c4 10             	add    $0x10,%esp
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
    eph = ph + elf->e_phnum;

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f0103802:	83 c3 20             	add    $0x20,%ebx
f0103805:	39 df                	cmp    %ebx,%edi
f0103807:	77 b8                	ja     f01037c1 <env_create+0x98>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
        }
    }
    e->env_tf.tf_eip = elf->e_entry;
f0103809:	8b 46 18             	mov    0x18(%esi),%eax
f010380c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010380f:	89 42 30             	mov    %eax,0x30(%edx)

    lcr3(PADDR(kern_pgdir));
f0103812:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103817:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010381c:	77 15                	ja     f0103833 <env_create+0x10a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010381e:	50                   	push   %eax
f010381f:	68 44 68 10 f0       	push   $0xf0106844
f0103824:	68 87 01 00 00       	push   $0x187
f0103829:	68 ef 7e 10 f0       	push   $0xf0107eef
f010382e:	e8 35 c8 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103833:	05 00 00 00 10       	add    $0x10000000,%eax
f0103838:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010383b:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103840:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103848:	e8 3b fb ff ff       	call   f0103388 <region_alloc>
    int r = env_alloc(&e, 0);
    if (r < 0) {
        panic("env_create: %e\n", r);
    }
    load_icode(e, binary, size);
    e->env_type = type;
f010384d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103850:	8b 55 10             	mov    0x10(%ebp),%edx
f0103853:	89 50 50             	mov    %edx,0x50(%eax)
    // cprintf("env_create out\n");
    return;
}
f0103856:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103859:	5b                   	pop    %ebx
f010385a:	5e                   	pop    %esi
f010385b:	5f                   	pop    %edi
f010385c:	c9                   	leave  
f010385d:	c3                   	ret    

f010385e <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010385e:	55                   	push   %ebp
f010385f:	89 e5                	mov    %esp,%ebp
f0103861:	57                   	push   %edi
f0103862:	56                   	push   %esi
f0103863:	53                   	push   %ebx
f0103864:	83 ec 1c             	sub    $0x1c,%esp
f0103867:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010386a:	e8 e5 28 00 00       	call   f0106154 <cpunum>
f010386f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103872:	39 b8 28 60 2e f0    	cmp    %edi,-0xfd19fd8(%eax)
f0103878:	75 29                	jne    f01038a3 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f010387a:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010387f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103884:	77 15                	ja     f010389b <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103886:	50                   	push   %eax
f0103887:	68 44 68 10 f0       	push   $0xf0106844
f010388c:	68 b6 01 00 00       	push   $0x1b6
f0103891:	68 ef 7e 10 f0       	push   $0xf0107eef
f0103896:	e8 cd c7 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010389b:	05 00 00 00 10       	add    $0x10000000,%eax
f01038a0:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038a3:	8b 5f 48             	mov    0x48(%edi),%ebx
f01038a6:	e8 a9 28 00 00       	call   f0106154 <cpunum>
f01038ab:	6b d0 74             	imul   $0x74,%eax,%edx
f01038ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01038b3:	83 ba 28 60 2e f0 00 	cmpl   $0x0,-0xfd19fd8(%edx)
f01038ba:	74 11                	je     f01038cd <env_free+0x6f>
f01038bc:	e8 93 28 00 00       	call   f0106154 <cpunum>
f01038c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01038c4:	8b 80 28 60 2e f0    	mov    -0xfd19fd8(%eax),%eax
f01038ca:	8b 40 48             	mov    0x48(%eax),%eax
f01038cd:	83 ec 04             	sub    $0x4,%esp
f01038d0:	53                   	push   %ebx
f01038d1:	50                   	push   %eax
f01038d2:	68 37 7f 10 f0       	push   $0xf0107f37
f01038d7:	e8 81 04 00 00       	call   f0103d5d <cprintf>
f01038dc:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01038df:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038e9:	c1 e0 02             	shl    $0x2,%eax
f01038ec:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01038ef:	8b 47 60             	mov    0x60(%edi),%eax
f01038f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01038f5:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01038f8:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01038fe:	0f 84 ab 00 00 00    	je     f01039af <env_free+0x151>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103904:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010390a:	89 f0                	mov    %esi,%eax
f010390c:	c1 e8 0c             	shr    $0xc,%eax
f010390f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103912:	3b 05 88 5e 2e f0    	cmp    0xf02e5e88,%eax
f0103918:	72 15                	jb     f010392f <env_free+0xd1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010391a:	56                   	push   %esi
f010391b:	68 68 68 10 f0       	push   $0xf0106868
f0103920:	68 c5 01 00 00       	push   $0x1c5
f0103925:	68 ef 7e 10 f0       	push   $0xf0107eef
f010392a:	e8 39 c7 ff ff       	call   f0100068 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010392f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103932:	c1 e2 16             	shl    $0x16,%edx
f0103935:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103938:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010393d:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103944:	01 
f0103945:	74 17                	je     f010395e <env_free+0x100>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103947:	83 ec 08             	sub    $0x8,%esp
f010394a:	89 d8                	mov    %ebx,%eax
f010394c:	c1 e0 0c             	shl    $0xc,%eax
f010394f:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103952:	50                   	push   %eax
f0103953:	ff 77 60             	pushl  0x60(%edi)
f0103956:	e8 d1 de ff ff       	call   f010182c <page_remove>
f010395b:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010395e:	43                   	inc    %ebx
f010395f:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103965:	75 d6                	jne    f010393d <env_free+0xdf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103967:	8b 47 60             	mov    0x60(%edi),%eax
f010396a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010396d:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103974:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103977:	3b 05 88 5e 2e f0    	cmp    0xf02e5e88,%eax
f010397d:	72 14                	jb     f0103993 <env_free+0x135>
		panic("pa2page called with invalid pa");
f010397f:	83 ec 04             	sub    $0x4,%esp
f0103982:	68 d0 73 10 f0       	push   $0xf01073d0
f0103987:	6a 51                	push   $0x51
f0103989:	68 dd 7b 10 f0       	push   $0xf0107bdd
f010398e:	e8 d5 c6 ff ff       	call   f0100068 <_panic>
		page_decref(pa2page(pa));
f0103993:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103996:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103999:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01039a0:	03 05 90 5e 2e f0    	add    0xf02e5e90,%eax
f01039a6:	50                   	push   %eax
f01039a7:	e8 cb dc ff ff       	call   f0101677 <page_decref>
f01039ac:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01039af:	ff 45 e0             	incl   -0x20(%ebp)
f01039b2:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01039b9:	0f 85 27 ff ff ff    	jne    f01038e6 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01039bf:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039c2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039c7:	77 15                	ja     f01039de <env_free+0x180>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039c9:	50                   	push   %eax
f01039ca:	68 44 68 10 f0       	push   $0xf0106844
f01039cf:	68 d3 01 00 00       	push   $0x1d3
f01039d4:	68 ef 7e 10 f0       	push   $0xf0107eef
f01039d9:	e8 8a c6 ff ff       	call   f0100068 <_panic>
	e->env_pgdir = 0;
f01039de:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01039e5:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01039ea:	c1 e8 0c             	shr    $0xc,%eax
f01039ed:	3b 05 88 5e 2e f0    	cmp    0xf02e5e88,%eax
f01039f3:	72 14                	jb     f0103a09 <env_free+0x1ab>
		panic("pa2page called with invalid pa");
f01039f5:	83 ec 04             	sub    $0x4,%esp
f01039f8:	68 d0 73 10 f0       	push   $0xf01073d0
f01039fd:	6a 51                	push   $0x51
f01039ff:	68 dd 7b 10 f0       	push   $0xf0107bdd
f0103a04:	e8 5f c6 ff ff       	call   f0100068 <_panic>
	page_decref(pa2page(pa));
f0103a09:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103a0c:	c1 e0 03             	shl    $0x3,%eax
f0103a0f:	03 05 90 5e 2e f0    	add    0xf02e5e90,%eax
f0103a15:	50                   	push   %eax
f0103a16:	e8 5c dc ff ff       	call   f0101677 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103a1b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103a22:	a1 40 52 2e f0       	mov    0xf02e5240,%eax
f0103a27:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103a2a:	89 3d 40 52 2e f0    	mov    %edi,0xf02e5240
f0103a30:	83 c4 10             	add    $0x10,%esp
}
f0103a33:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a36:	5b                   	pop    %ebx
f0103a37:	5e                   	pop    %esi
f0103a38:	5f                   	pop    %edi
f0103a39:	c9                   	leave  
f0103a3a:	c3                   	ret    

f0103a3b <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103a3b:	55                   	push   %ebp
f0103a3c:	89 e5                	mov    %esp,%ebp
f0103a3e:	53                   	push   %ebx
f0103a3f:	83 ec 04             	sub    $0x4,%esp
f0103a42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103a45:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103a49:	75 23                	jne    f0103a6e <env_destroy+0x33>
f0103a4b:	e8 04 27 00 00       	call   f0106154 <cpunum>
f0103a50:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a57:	29 c2                	sub    %eax,%edx
f0103a59:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a5c:	39 1c 85 28 60 2e f0 	cmp    %ebx,-0xfd19fd8(,%eax,4)
f0103a63:	74 09                	je     f0103a6e <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103a65:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103a6c:	eb 3d                	jmp    f0103aab <env_destroy+0x70>
	}

	env_free(e);
f0103a6e:	83 ec 0c             	sub    $0xc,%esp
f0103a71:	53                   	push   %ebx
f0103a72:	e8 e7 fd ff ff       	call   f010385e <env_free>

	if (curenv == e) {
f0103a77:	e8 d8 26 00 00       	call   f0106154 <cpunum>
f0103a7c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a83:	29 c2                	sub    %eax,%edx
f0103a85:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a88:	83 c4 10             	add    $0x10,%esp
f0103a8b:	39 1c 85 28 60 2e f0 	cmp    %ebx,-0xfd19fd8(,%eax,4)
f0103a92:	75 17                	jne    f0103aab <env_destroy+0x70>
		curenv = NULL;
f0103a94:	e8 bb 26 00 00       	call   f0106154 <cpunum>
f0103a99:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a9c:	c7 80 28 60 2e f0 00 	movl   $0x0,-0xfd19fd8(%eax)
f0103aa3:	00 00 00 
		sched_yield();
f0103aa6:	e8 60 0d 00 00       	call   f010480b <sched_yield>
	}
}
f0103aab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103aae:	c9                   	leave  
f0103aaf:	c3                   	ret    

f0103ab0 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103ab0:	55                   	push   %ebp
f0103ab1:	89 e5                	mov    %esp,%ebp
f0103ab3:	53                   	push   %ebx
f0103ab4:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103ab7:	e8 98 26 00 00       	call   f0106154 <cpunum>
f0103abc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ac3:	29 c2                	sub    %eax,%edx
f0103ac5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ac8:	8b 1c 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%ebx
f0103acf:	e8 80 26 00 00       	call   f0106154 <cpunum>
f0103ad4:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103ad7:	8b 65 08             	mov    0x8(%ebp),%esp
f0103ada:	61                   	popa   
f0103adb:	07                   	pop    %es
f0103adc:	1f                   	pop    %ds
f0103add:	83 c4 08             	add    $0x8,%esp
f0103ae0:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103ae1:	83 ec 04             	sub    $0x4,%esp
f0103ae4:	68 4d 7f 10 f0       	push   $0xf0107f4d
f0103ae9:	68 09 02 00 00       	push   $0x209
f0103aee:	68 ef 7e 10 f0       	push   $0xf0107eef
f0103af3:	e8 70 c5 ff ff       	call   f0100068 <_panic>

f0103af8 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103af8:	55                   	push   %ebp
f0103af9:	89 e5                	mov    %esp,%ebp
f0103afb:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// cprintf("I am in env_run\n");
	
    if (curenv != NULL) {
f0103afe:	e8 51 26 00 00       	call   f0106154 <cpunum>
f0103b03:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b0a:	29 c2                	sub    %eax,%edx
f0103b0c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b0f:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f0103b16:	00 
f0103b17:	74 3d                	je     f0103b56 <env_run+0x5e>
        // context switch
        if (curenv->env_status == ENV_RUNNING) {
f0103b19:	e8 36 26 00 00       	call   f0106154 <cpunum>
f0103b1e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b25:	29 c2                	sub    %eax,%edx
f0103b27:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b2a:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0103b31:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103b35:	75 1f                	jne    f0103b56 <env_run+0x5e>
            curenv->env_status = ENV_RUNNABLE;
f0103b37:	e8 18 26 00 00       	call   f0106154 <cpunum>
f0103b3c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b43:	29 c2                	sub    %eax,%edx
f0103b45:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b48:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0103b4f:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
        }
        // how about other env_status ? e.g. like ENV_DYING ?
    }
    curenv = e;
f0103b56:	e8 f9 25 00 00       	call   f0106154 <cpunum>
f0103b5b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b62:	29 c2                	sub    %eax,%edx
f0103b64:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b67:	8b 55 08             	mov    0x8(%ebp),%edx
f0103b6a:	89 14 85 28 60 2e f0 	mov    %edx,-0xfd19fd8(,%eax,4)
    curenv->env_status = ENV_RUNNING;
f0103b71:	e8 de 25 00 00       	call   f0106154 <cpunum>
f0103b76:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b7d:	29 c2                	sub    %eax,%edx
f0103b7f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b82:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0103b89:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f0103b90:	e8 bf 25 00 00       	call   f0106154 <cpunum>
f0103b95:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b9c:	29 c2                	sub    %eax,%edx
f0103b9e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ba1:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0103ba8:	ff 40 58             	incl   0x58(%eax)
    
    lcr3(PADDR(curenv->env_pgdir));
f0103bab:	e8 a4 25 00 00       	call   f0106154 <cpunum>
f0103bb0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103bb7:	29 c2                	sub    %eax,%edx
f0103bb9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103bbc:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0103bc3:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bc6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bcb:	77 15                	ja     f0103be2 <env_run+0xea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bcd:	50                   	push   %eax
f0103bce:	68 44 68 10 f0       	push   $0xf0106844
f0103bd3:	68 34 02 00 00       	push   $0x234
f0103bd8:	68 ef 7e 10 f0       	push   $0xf0107eef
f0103bdd:	e8 86 c4 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103be2:	05 00 00 00 10       	add    $0x10000000,%eax
f0103be7:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103bea:	83 ec 0c             	sub    $0xc,%esp
f0103bed:	68 60 84 12 f0       	push   $0xf0128460
f0103bf2:	e8 cf 28 00 00       	call   f01064c6 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103bf7:	f3 90                	pause  
    unlock_kernel();
    env_pop_tf(&curenv->env_tf);    
f0103bf9:	e8 56 25 00 00       	call   f0106154 <cpunum>
f0103bfe:	83 c4 04             	add    $0x4,%esp
f0103c01:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c08:	29 c2                	sub    %eax,%edx
f0103c0a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c0d:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f0103c14:	e8 97 fe ff ff       	call   f0103ab0 <env_pop_tf>
f0103c19:	00 00                	add    %al,(%eax)
	...

f0103c1c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103c1c:	55                   	push   %ebp
f0103c1d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c1f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c24:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c27:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103c28:	b2 71                	mov    $0x71,%dl
f0103c2a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103c2b:	0f b6 c0             	movzbl %al,%eax
}
f0103c2e:	c9                   	leave  
f0103c2f:	c3                   	ret    

f0103c30 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103c30:	55                   	push   %ebp
f0103c31:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c33:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c38:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c3b:	ee                   	out    %al,(%dx)
f0103c3c:	b2 71                	mov    $0x71,%dl
f0103c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c41:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103c42:	c9                   	leave  
f0103c43:	c3                   	ret    

f0103c44 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103c44:	55                   	push   %ebp
f0103c45:	89 e5                	mov    %esp,%ebp
f0103c47:	56                   	push   %esi
f0103c48:	53                   	push   %ebx
f0103c49:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c4c:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103c4e:	66 a3 90 83 12 f0    	mov    %ax,0xf0128390
	if (!didinit)
f0103c54:	80 3d 44 52 2e f0 00 	cmpb   $0x0,0xf02e5244
f0103c5b:	74 5a                	je     f0103cb7 <irq_setmask_8259A+0x73>
f0103c5d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103c62:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103c63:	89 f0                	mov    %esi,%eax
f0103c65:	66 c1 e8 08          	shr    $0x8,%ax
f0103c69:	b2 a1                	mov    $0xa1,%dl
f0103c6b:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103c6c:	83 ec 0c             	sub    $0xc,%esp
f0103c6f:	68 59 7f 10 f0       	push   $0xf0107f59
f0103c74:	e8 e4 00 00 00       	call   f0103d5d <cprintf>
f0103c79:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103c7c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103c81:	0f b7 f6             	movzwl %si,%esi
f0103c84:	f7 d6                	not    %esi
f0103c86:	89 f0                	mov    %esi,%eax
f0103c88:	88 d9                	mov    %bl,%cl
f0103c8a:	d3 f8                	sar    %cl,%eax
f0103c8c:	a8 01                	test   $0x1,%al
f0103c8e:	74 11                	je     f0103ca1 <irq_setmask_8259A+0x5d>
			cprintf(" %d", i);
f0103c90:	83 ec 08             	sub    $0x8,%esp
f0103c93:	53                   	push   %ebx
f0103c94:	68 57 84 10 f0       	push   $0xf0108457
f0103c99:	e8 bf 00 00 00       	call   f0103d5d <cprintf>
f0103c9e:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103ca1:	43                   	inc    %ebx
f0103ca2:	83 fb 10             	cmp    $0x10,%ebx
f0103ca5:	75 df                	jne    f0103c86 <irq_setmask_8259A+0x42>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103ca7:	83 ec 0c             	sub    $0xc,%esp
f0103caa:	68 8f 6b 10 f0       	push   $0xf0106b8f
f0103caf:	e8 a9 00 00 00       	call   f0103d5d <cprintf>
f0103cb4:	83 c4 10             	add    $0x10,%esp
}
f0103cb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103cba:	5b                   	pop    %ebx
f0103cbb:	5e                   	pop    %esi
f0103cbc:	c9                   	leave  
f0103cbd:	c3                   	ret    

f0103cbe <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103cbe:	55                   	push   %ebp
f0103cbf:	89 e5                	mov    %esp,%ebp
f0103cc1:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f0103cc4:	c6 05 44 52 2e f0 01 	movb   $0x1,0xf02e5244
f0103ccb:	ba 21 00 00 00       	mov    $0x21,%edx
f0103cd0:	b0 ff                	mov    $0xff,%al
f0103cd2:	ee                   	out    %al,(%dx)
f0103cd3:	b2 a1                	mov    $0xa1,%dl
f0103cd5:	ee                   	out    %al,(%dx)
f0103cd6:	b2 20                	mov    $0x20,%dl
f0103cd8:	b0 11                	mov    $0x11,%al
f0103cda:	ee                   	out    %al,(%dx)
f0103cdb:	b2 21                	mov    $0x21,%dl
f0103cdd:	b0 20                	mov    $0x20,%al
f0103cdf:	ee                   	out    %al,(%dx)
f0103ce0:	b0 04                	mov    $0x4,%al
f0103ce2:	ee                   	out    %al,(%dx)
f0103ce3:	b0 03                	mov    $0x3,%al
f0103ce5:	ee                   	out    %al,(%dx)
f0103ce6:	b2 a0                	mov    $0xa0,%dl
f0103ce8:	b0 11                	mov    $0x11,%al
f0103cea:	ee                   	out    %al,(%dx)
f0103ceb:	b2 a1                	mov    $0xa1,%dl
f0103ced:	b0 28                	mov    $0x28,%al
f0103cef:	ee                   	out    %al,(%dx)
f0103cf0:	b0 02                	mov    $0x2,%al
f0103cf2:	ee                   	out    %al,(%dx)
f0103cf3:	b0 01                	mov    $0x1,%al
f0103cf5:	ee                   	out    %al,(%dx)
f0103cf6:	b2 20                	mov    $0x20,%dl
f0103cf8:	b0 68                	mov    $0x68,%al
f0103cfa:	ee                   	out    %al,(%dx)
f0103cfb:	b0 0a                	mov    $0xa,%al
f0103cfd:	ee                   	out    %al,(%dx)
f0103cfe:	b2 a0                	mov    $0xa0,%dl
f0103d00:	b0 68                	mov    $0x68,%al
f0103d02:	ee                   	out    %al,(%dx)
f0103d03:	b0 0a                	mov    $0xa,%al
f0103d05:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103d06:	66 a1 90 83 12 f0    	mov    0xf0128390,%ax
f0103d0c:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103d10:	74 0f                	je     f0103d21 <pic_init+0x63>
		irq_setmask_8259A(irq_mask_8259A);
f0103d12:	83 ec 0c             	sub    $0xc,%esp
f0103d15:	0f b7 c0             	movzwl %ax,%eax
f0103d18:	50                   	push   %eax
f0103d19:	e8 26 ff ff ff       	call   f0103c44 <irq_setmask_8259A>
f0103d1e:	83 c4 10             	add    $0x10,%esp
}
f0103d21:	c9                   	leave  
f0103d22:	c3                   	ret    
	...

f0103d24 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103d24:	55                   	push   %ebp
f0103d25:	89 e5                	mov    %esp,%ebp
f0103d27:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103d2a:	ff 75 08             	pushl  0x8(%ebp)
f0103d2d:	e8 6d ca ff ff       	call   f010079f <cputchar>
f0103d32:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0103d35:	c9                   	leave  
f0103d36:	c3                   	ret    

f0103d37 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103d37:	55                   	push   %ebp
f0103d38:	89 e5                	mov    %esp,%ebp
f0103d3a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103d3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103d44:	ff 75 0c             	pushl  0xc(%ebp)
f0103d47:	ff 75 08             	pushl  0x8(%ebp)
f0103d4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103d4d:	50                   	push   %eax
f0103d4e:	68 24 3d 10 f0       	push   $0xf0103d24
f0103d53:	e8 35 17 00 00       	call   f010548d <vprintfmt>
	return cnt;
}
f0103d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d5b:	c9                   	leave  
f0103d5c:	c3                   	ret    

f0103d5d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103d5d:	55                   	push   %ebp
f0103d5e:	89 e5                	mov    %esp,%ebp
f0103d60:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103d63:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103d66:	50                   	push   %eax
f0103d67:	ff 75 08             	pushl  0x8(%ebp)
f0103d6a:	e8 c8 ff ff ff       	call   f0103d37 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103d6f:	c9                   	leave  
f0103d70:	c3                   	ret    
f0103d71:	00 00                	add    %al,(%eax)
	...

f0103d74 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103d74:	55                   	push   %ebp
f0103d75:	89 e5                	mov    %esp,%ebp
f0103d77:	57                   	push   %edi
f0103d78:	56                   	push   %esi
f0103d79:	53                   	push   %ebx
f0103d7a:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
    
    int cpu_id = thiscpu->cpu_id;
f0103d7d:	e8 d2 23 00 00       	call   f0106154 <cpunum>
f0103d82:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d89:	29 c2                	sub    %eax,%edx
f0103d8b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d8e:	0f b6 34 85 20 60 2e 	movzbl -0xfd19fe0(,%eax,4),%esi
f0103d95:	f0 
    
    // Setup a TSS so that we get the right stack
	// when we trap to the kernel.
    thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id * (KSTKSIZE + KSTKGAP);
f0103d96:	e8 b9 23 00 00       	call   f0106154 <cpunum>
f0103d9b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103da2:	29 c2                	sub    %eax,%edx
f0103da4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103da7:	89 f2                	mov    %esi,%edx
f0103da9:	f7 da                	neg    %edx
f0103dab:	c1 e2 10             	shl    $0x10,%edx
f0103dae:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103db4:	89 14 85 30 60 2e f0 	mov    %edx,-0xfd19fd0(,%eax,4)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103dbb:	e8 94 23 00 00       	call   f0106154 <cpunum>
f0103dc0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103dc7:	29 c2                	sub    %eax,%edx
f0103dc9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103dcc:	66 c7 04 85 34 60 2e 	movw   $0x10,-0xfd19fcc(,%eax,4)
f0103dd3:	f0 10 00 

    gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103dd6:	8d 5e 05             	lea    0x5(%esi),%ebx
f0103dd9:	e8 76 23 00 00       	call   f0106154 <cpunum>
f0103dde:	89 c7                	mov    %eax,%edi
f0103de0:	e8 6f 23 00 00       	call   f0106154 <cpunum>
f0103de5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103de8:	e8 67 23 00 00       	call   f0106154 <cpunum>
f0103ded:	66 c7 04 dd 20 83 12 	movw   $0x68,-0xfed7ce0(,%ebx,8)
f0103df4:	f0 68 00 
f0103df7:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0103dfe:	29 fa                	sub    %edi,%edx
f0103e00:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103e03:	8d 14 95 2c 60 2e f0 	lea    -0xfd19fd4(,%edx,4),%edx
f0103e0a:	66 89 14 dd 22 83 12 	mov    %dx,-0xfed7cde(,%ebx,8)
f0103e11:	f0 
f0103e12:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103e15:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0103e1c:	29 ca                	sub    %ecx,%edx
f0103e1e:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0103e21:	8d 14 95 2c 60 2e f0 	lea    -0xfd19fd4(,%edx,4),%edx
f0103e28:	c1 ea 10             	shr    $0x10,%edx
f0103e2b:	88 14 dd 24 83 12 f0 	mov    %dl,-0xfed7cdc(,%ebx,8)
f0103e32:	c6 04 dd 26 83 12 f0 	movb   $0x40,-0xfed7cda(,%ebx,8)
f0103e39:	40 
f0103e3a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103e41:	29 c2                	sub    %eax,%edx
f0103e43:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103e46:	8d 04 85 2c 60 2e f0 	lea    -0xfd19fd4(,%eax,4),%eax
f0103e4d:	c1 e8 18             	shr    $0x18,%eax
f0103e50:	88 04 dd 27 83 12 f0 	mov    %al,-0xfed7cd9(,%ebx,8)
    							sizeof(struct Taskstate), 0);

    // Initialize the TSS slot of the gdt.
    gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0103e57:	c6 04 dd 25 83 12 f0 	movb   $0x89,-0xfed7cdb(,%ebx,8)
f0103e5e:	89 

    // Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
    ltr(GD_TSS0 + (cpu_id << 3));
f0103e5f:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103e66:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103e69:	b8 94 83 12 f0       	mov    $0xf0128394,%eax
f0103e6e:	0f 01 18             	lidtl  (%eax)

    // Load the IDT
    lidt(&idt_pd);
}
f0103e71:	83 c4 1c             	add    $0x1c,%esp
f0103e74:	5b                   	pop    %ebx
f0103e75:	5e                   	pop    %esi
f0103e76:	5f                   	pop    %edi
f0103e77:	c9                   	leave  
f0103e78:	c3                   	ret    

f0103e79 <trap_init>:
}


void
trap_init(void)
{
f0103e79:	55                   	push   %ebp
f0103e7a:	89 e5                	mov    %esp,%ebp
f0103e7c:	83 ec 08             	sub    $0x8,%esp
f0103e7f:	ba 01 00 00 00       	mov    $0x1,%edx
f0103e84:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e89:	eb 02                	jmp    f0103e8d <trap_init+0x14>
f0103e8b:	40                   	inc    %eax
f0103e8c:	42                   	inc    %edx
    extern void vec51();
    

    int i;
    for (i = 0; i != 20; i++) {
    	if (i == T_BRKPT) {
f0103e8d:	83 f8 03             	cmp    $0x3,%eax
f0103e90:	75 30                	jne    f0103ec2 <trap_init+0x49>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
f0103e92:	8b 0d a8 83 12 f0    	mov    0xf01283a8,%ecx
f0103e98:	66 89 0d 78 52 2e f0 	mov    %cx,0xf02e5278
f0103e9f:	66 c7 05 7a 52 2e f0 	movw   $0x8,0xf02e527a
f0103ea6:	08 00 
f0103ea8:	c6 05 7c 52 2e f0 00 	movb   $0x0,0xf02e527c
f0103eaf:	c6 05 7d 52 2e f0 ee 	movb   $0xee,0xf02e527d
f0103eb6:	c1 e9 10             	shr    $0x10,%ecx
f0103eb9:	66 89 0d 7e 52 2e f0 	mov    %cx,0xf02e527e
f0103ec0:	eb c9                	jmp    f0103e8b <trap_init+0x12>
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f0103ec2:	8b 0c 85 9c 83 12 f0 	mov    -0xfed7c64(,%eax,4),%ecx
f0103ec9:	66 89 0c c5 60 52 2e 	mov    %cx,-0xfd1ada0(,%eax,8)
f0103ed0:	f0 
f0103ed1:	66 c7 04 c5 62 52 2e 	movw   $0x8,-0xfd1ad9e(,%eax,8)
f0103ed8:	f0 08 00 
f0103edb:	c6 04 c5 64 52 2e f0 	movb   $0x0,-0xfd1ad9c(,%eax,8)
f0103ee2:	00 
f0103ee3:	c6 04 c5 65 52 2e f0 	movb   $0x8e,-0xfd1ad9b(,%eax,8)
f0103eea:	8e 
f0103eeb:	c1 e9 10             	shr    $0x10,%ecx
f0103eee:	66 89 0c c5 66 52 2e 	mov    %cx,-0xfd1ad9a(,%eax,8)
f0103ef5:	f0 
    extern void vec46();
    extern void vec51();
    

    int i;
    for (i = 0; i != 20; i++) {
f0103ef6:	83 fa 14             	cmp    $0x14,%edx
f0103ef9:	75 90                	jne    f0103e8b <trap_init+0x12>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
    	}
    }
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, vec32, 0);
f0103efb:	b8 f2 83 12 f0       	mov    $0xf01283f2,%eax
f0103f00:	66 a3 60 53 2e f0    	mov    %ax,0xf02e5360
f0103f06:	66 c7 05 62 53 2e f0 	movw   $0x8,0xf02e5362
f0103f0d:	08 00 
f0103f0f:	c6 05 64 53 2e f0 00 	movb   $0x0,0xf02e5364
f0103f16:	c6 05 65 53 2e f0 8e 	movb   $0x8e,0xf02e5365
f0103f1d:	c1 e8 10             	shr    $0x10,%eax
f0103f20:	66 a3 66 53 2e f0    	mov    %ax,0xf02e5366
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, vec33, 0);
f0103f26:	b8 f8 83 12 f0       	mov    $0xf01283f8,%eax
f0103f2b:	66 a3 68 53 2e f0    	mov    %ax,0xf02e5368
f0103f31:	66 c7 05 6a 53 2e f0 	movw   $0x8,0xf02e536a
f0103f38:	08 00 
f0103f3a:	c6 05 6c 53 2e f0 00 	movb   $0x0,0xf02e536c
f0103f41:	c6 05 6d 53 2e f0 8e 	movb   $0x8e,0xf02e536d
f0103f48:	c1 e8 10             	shr    $0x10,%eax
f0103f4b:	66 a3 6e 53 2e f0    	mov    %ax,0xf02e536e
    SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, vec36, 0);
f0103f51:	b8 fe 83 12 f0       	mov    $0xf01283fe,%eax
f0103f56:	66 a3 80 53 2e f0    	mov    %ax,0xf02e5380
f0103f5c:	66 c7 05 82 53 2e f0 	movw   $0x8,0xf02e5382
f0103f63:	08 00 
f0103f65:	c6 05 84 53 2e f0 00 	movb   $0x0,0xf02e5384
f0103f6c:	c6 05 85 53 2e f0 8e 	movb   $0x8e,0xf02e5385
f0103f73:	c1 e8 10             	shr    $0x10,%eax
f0103f76:	66 a3 86 53 2e f0    	mov    %ax,0xf02e5386
    SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, vec39, 0);
f0103f7c:	b8 04 84 12 f0       	mov    $0xf0128404,%eax
f0103f81:	66 a3 98 53 2e f0    	mov    %ax,0xf02e5398
f0103f87:	66 c7 05 9a 53 2e f0 	movw   $0x8,0xf02e539a
f0103f8e:	08 00 
f0103f90:	c6 05 9c 53 2e f0 00 	movb   $0x0,0xf02e539c
f0103f97:	c6 05 9d 53 2e f0 8e 	movb   $0x8e,0xf02e539d
f0103f9e:	c1 e8 10             	shr    $0x10,%eax
f0103fa1:	66 a3 9e 53 2e f0    	mov    %ax,0xf02e539e
    SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, vec46, 0);
f0103fa7:	b8 0a 84 12 f0       	mov    $0xf012840a,%eax
f0103fac:	66 a3 d0 53 2e f0    	mov    %ax,0xf02e53d0
f0103fb2:	66 c7 05 d2 53 2e f0 	movw   $0x8,0xf02e53d2
f0103fb9:	08 00 
f0103fbb:	c6 05 d4 53 2e f0 00 	movb   $0x0,0xf02e53d4
f0103fc2:	c6 05 d5 53 2e f0 8e 	movb   $0x8e,0xf02e53d5
f0103fc9:	c1 e8 10             	shr    $0x10,%eax
f0103fcc:	66 a3 d6 53 2e f0    	mov    %ax,0xf02e53d6

    SETGATE(idt[T_SYSCALL], 0, GD_KT, vec48, 3);
f0103fd2:	b8 ec 83 12 f0       	mov    $0xf01283ec,%eax
f0103fd7:	66 a3 e0 53 2e f0    	mov    %ax,0xf02e53e0
f0103fdd:	66 c7 05 e2 53 2e f0 	movw   $0x8,0xf02e53e2
f0103fe4:	08 00 
f0103fe6:	c6 05 e4 53 2e f0 00 	movb   $0x0,0xf02e53e4
f0103fed:	c6 05 e5 53 2e f0 ee 	movb   $0xee,0xf02e53e5
f0103ff4:	c1 e8 10             	shr    $0x10,%eax
f0103ff7:	66 a3 e6 53 2e f0    	mov    %ax,0xf02e53e6
	
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, vec51, 0);
f0103ffd:	b8 10 84 12 f0       	mov    $0xf0128410,%eax
f0104002:	66 a3 f8 53 2e f0    	mov    %ax,0xf02e53f8
f0104008:	66 c7 05 fa 53 2e f0 	movw   $0x8,0xf02e53fa
f010400f:	08 00 
f0104011:	c6 05 fc 53 2e f0 00 	movb   $0x0,0xf02e53fc
f0104018:	c6 05 fd 53 2e f0 8e 	movb   $0x8e,0xf02e53fd
f010401f:	c1 e8 10             	shr    $0x10,%eax
f0104022:	66 a3 fe 53 2e f0    	mov    %ax,0xf02e53fe
    
 	
	// Per-CPU setup 
	trap_init_percpu();
f0104028:	e8 47 fd ff ff       	call   f0103d74 <trap_init_percpu>
}
f010402d:	c9                   	leave  
f010402e:	c3                   	ret    

f010402f <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010402f:	55                   	push   %ebp
f0104030:	89 e5                	mov    %esp,%ebp
f0104032:	53                   	push   %ebx
f0104033:	83 ec 0c             	sub    $0xc,%esp
f0104036:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104039:	ff 33                	pushl  (%ebx)
f010403b:	68 6d 7f 10 f0       	push   $0xf0107f6d
f0104040:	e8 18 fd ff ff       	call   f0103d5d <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104045:	83 c4 08             	add    $0x8,%esp
f0104048:	ff 73 04             	pushl  0x4(%ebx)
f010404b:	68 7c 7f 10 f0       	push   $0xf0107f7c
f0104050:	e8 08 fd ff ff       	call   f0103d5d <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104055:	83 c4 08             	add    $0x8,%esp
f0104058:	ff 73 08             	pushl  0x8(%ebx)
f010405b:	68 8b 7f 10 f0       	push   $0xf0107f8b
f0104060:	e8 f8 fc ff ff       	call   f0103d5d <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104065:	83 c4 08             	add    $0x8,%esp
f0104068:	ff 73 0c             	pushl  0xc(%ebx)
f010406b:	68 9a 7f 10 f0       	push   $0xf0107f9a
f0104070:	e8 e8 fc ff ff       	call   f0103d5d <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104075:	83 c4 08             	add    $0x8,%esp
f0104078:	ff 73 10             	pushl  0x10(%ebx)
f010407b:	68 a9 7f 10 f0       	push   $0xf0107fa9
f0104080:	e8 d8 fc ff ff       	call   f0103d5d <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104085:	83 c4 08             	add    $0x8,%esp
f0104088:	ff 73 14             	pushl  0x14(%ebx)
f010408b:	68 b8 7f 10 f0       	push   $0xf0107fb8
f0104090:	e8 c8 fc ff ff       	call   f0103d5d <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104095:	83 c4 08             	add    $0x8,%esp
f0104098:	ff 73 18             	pushl  0x18(%ebx)
f010409b:	68 c7 7f 10 f0       	push   $0xf0107fc7
f01040a0:	e8 b8 fc ff ff       	call   f0103d5d <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01040a5:	83 c4 08             	add    $0x8,%esp
f01040a8:	ff 73 1c             	pushl  0x1c(%ebx)
f01040ab:	68 d6 7f 10 f0       	push   $0xf0107fd6
f01040b0:	e8 a8 fc ff ff       	call   f0103d5d <cprintf>
f01040b5:	83 c4 10             	add    $0x10,%esp
}
f01040b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01040bb:	c9                   	leave  
f01040bc:	c3                   	ret    

f01040bd <print_trapframe>:
    lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01040bd:	55                   	push   %ebp
f01040be:	89 e5                	mov    %esp,%ebp
f01040c0:	53                   	push   %ebx
f01040c1:	83 ec 04             	sub    $0x4,%esp
f01040c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01040c7:	e8 88 20 00 00       	call   f0106154 <cpunum>
f01040cc:	83 ec 04             	sub    $0x4,%esp
f01040cf:	50                   	push   %eax
f01040d0:	53                   	push   %ebx
f01040d1:	68 3a 80 10 f0       	push   $0xf010803a
f01040d6:	e8 82 fc ff ff       	call   f0103d5d <cprintf>
	print_regs(&tf->tf_regs);
f01040db:	89 1c 24             	mov    %ebx,(%esp)
f01040de:	e8 4c ff ff ff       	call   f010402f <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01040e3:	83 c4 08             	add    $0x8,%esp
f01040e6:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01040ea:	50                   	push   %eax
f01040eb:	68 58 80 10 f0       	push   $0xf0108058
f01040f0:	e8 68 fc ff ff       	call   f0103d5d <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01040f5:	83 c4 08             	add    $0x8,%esp
f01040f8:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01040fc:	50                   	push   %eax
f01040fd:	68 6b 80 10 f0       	push   $0xf010806b
f0104102:	e8 56 fc ff ff       	call   f0103d5d <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104107:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010410a:	83 c4 10             	add    $0x10,%esp
f010410d:	83 f8 13             	cmp    $0x13,%eax
f0104110:	77 09                	ja     f010411b <print_trapframe+0x5e>
		return excnames[trapno];
f0104112:	8b 14 85 20 83 10 f0 	mov    -0xfef7ce0(,%eax,4),%edx
f0104119:	eb 20                	jmp    f010413b <print_trapframe+0x7e>
	if (trapno == T_SYSCALL)
f010411b:	83 f8 30             	cmp    $0x30,%eax
f010411e:	74 0f                	je     f010412f <print_trapframe+0x72>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104120:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104123:	83 fa 0f             	cmp    $0xf,%edx
f0104126:	77 0e                	ja     f0104136 <print_trapframe+0x79>
		return "Hardware Interrupt";
f0104128:	ba f1 7f 10 f0       	mov    $0xf0107ff1,%edx
f010412d:	eb 0c                	jmp    f010413b <print_trapframe+0x7e>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f010412f:	ba e5 7f 10 f0       	mov    $0xf0107fe5,%edx
f0104134:	eb 05                	jmp    f010413b <print_trapframe+0x7e>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f0104136:	ba 04 80 10 f0       	mov    $0xf0108004,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010413b:	83 ec 04             	sub    $0x4,%esp
f010413e:	52                   	push   %edx
f010413f:	50                   	push   %eax
f0104140:	68 7e 80 10 f0       	push   $0xf010807e
f0104145:	e8 13 fc ff ff       	call   f0103d5d <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010414a:	83 c4 10             	add    $0x10,%esp
f010414d:	3b 1d 60 5a 2e f0    	cmp    0xf02e5a60,%ebx
f0104153:	75 1a                	jne    f010416f <print_trapframe+0xb2>
f0104155:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104159:	75 14                	jne    f010416f <print_trapframe+0xb2>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010415b:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010415e:	83 ec 08             	sub    $0x8,%esp
f0104161:	50                   	push   %eax
f0104162:	68 90 80 10 f0       	push   $0xf0108090
f0104167:	e8 f1 fb ff ff       	call   f0103d5d <cprintf>
f010416c:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f010416f:	83 ec 08             	sub    $0x8,%esp
f0104172:	ff 73 2c             	pushl  0x2c(%ebx)
f0104175:	68 9f 80 10 f0       	push   $0xf010809f
f010417a:	e8 de fb ff ff       	call   f0103d5d <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010417f:	83 c4 10             	add    $0x10,%esp
f0104182:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104186:	75 45                	jne    f01041cd <print_trapframe+0x110>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104188:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010418b:	a8 01                	test   $0x1,%al
f010418d:	74 07                	je     f0104196 <print_trapframe+0xd9>
f010418f:	b9 13 80 10 f0       	mov    $0xf0108013,%ecx
f0104194:	eb 05                	jmp    f010419b <print_trapframe+0xde>
f0104196:	b9 1e 80 10 f0       	mov    $0xf010801e,%ecx
f010419b:	a8 02                	test   $0x2,%al
f010419d:	74 07                	je     f01041a6 <print_trapframe+0xe9>
f010419f:	ba 2a 80 10 f0       	mov    $0xf010802a,%edx
f01041a4:	eb 05                	jmp    f01041ab <print_trapframe+0xee>
f01041a6:	ba 30 80 10 f0       	mov    $0xf0108030,%edx
f01041ab:	a8 04                	test   $0x4,%al
f01041ad:	74 07                	je     f01041b6 <print_trapframe+0xf9>
f01041af:	b8 35 80 10 f0       	mov    $0xf0108035,%eax
f01041b4:	eb 05                	jmp    f01041bb <print_trapframe+0xfe>
f01041b6:	b8 6a 81 10 f0       	mov    $0xf010816a,%eax
f01041bb:	51                   	push   %ecx
f01041bc:	52                   	push   %edx
f01041bd:	50                   	push   %eax
f01041be:	68 ad 80 10 f0       	push   $0xf01080ad
f01041c3:	e8 95 fb ff ff       	call   f0103d5d <cprintf>
f01041c8:	83 c4 10             	add    $0x10,%esp
f01041cb:	eb 10                	jmp    f01041dd <print_trapframe+0x120>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01041cd:	83 ec 0c             	sub    $0xc,%esp
f01041d0:	68 8f 6b 10 f0       	push   $0xf0106b8f
f01041d5:	e8 83 fb ff ff       	call   f0103d5d <cprintf>
f01041da:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01041dd:	83 ec 08             	sub    $0x8,%esp
f01041e0:	ff 73 30             	pushl  0x30(%ebx)
f01041e3:	68 bc 80 10 f0       	push   $0xf01080bc
f01041e8:	e8 70 fb ff ff       	call   f0103d5d <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01041ed:	83 c4 08             	add    $0x8,%esp
f01041f0:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01041f4:	50                   	push   %eax
f01041f5:	68 cb 80 10 f0       	push   $0xf01080cb
f01041fa:	e8 5e fb ff ff       	call   f0103d5d <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01041ff:	83 c4 08             	add    $0x8,%esp
f0104202:	ff 73 38             	pushl  0x38(%ebx)
f0104205:	68 de 80 10 f0       	push   $0xf01080de
f010420a:	e8 4e fb ff ff       	call   f0103d5d <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010420f:	83 c4 10             	add    $0x10,%esp
f0104212:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104216:	74 25                	je     f010423d <print_trapframe+0x180>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104218:	83 ec 08             	sub    $0x8,%esp
f010421b:	ff 73 3c             	pushl  0x3c(%ebx)
f010421e:	68 ed 80 10 f0       	push   $0xf01080ed
f0104223:	e8 35 fb ff ff       	call   f0103d5d <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104228:	83 c4 08             	add    $0x8,%esp
f010422b:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010422f:	50                   	push   %eax
f0104230:	68 fc 80 10 f0       	push   $0xf01080fc
f0104235:	e8 23 fb ff ff       	call   f0103d5d <cprintf>
f010423a:	83 c4 10             	add    $0x10,%esp
	}
}
f010423d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104240:	c9                   	leave  
f0104241:	c3                   	ret    

f0104242 <page_fault_handler>:
	}
}

void
page_fault_handler(struct Trapframe *tf)
{
f0104242:	55                   	push   %ebp
f0104243:	89 e5                	mov    %esp,%ebp
f0104245:	57                   	push   %edi
f0104246:	56                   	push   %esi
f0104247:	53                   	push   %ebx
f0104248:	83 ec 1c             	sub    $0x1c,%esp
f010424b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010424e:	0f 20 d0             	mov    %cr2,%eax
f0104251:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT)
f0104254:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0104259:	75 17                	jne    f0104272 <page_fault_handler+0x30>
    	panic("page_fault_handler : page fault in kernel\n");
f010425b:	83 ec 04             	sub    $0x4,%esp
f010425e:	68 b4 82 10 f0       	push   $0xf01082b4
f0104263:	68 56 01 00 00       	push   $0x156
f0104268:	68 0f 81 10 f0       	push   $0xf010810f
f010426d:	e8 f6 bd ff ff       	call   f0100068 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

    if (curenv->env_pgfault_upcall != NULL) {
f0104272:	e8 dd 1e 00 00       	call   f0106154 <cpunum>
f0104277:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010427e:	29 c2                	sub    %eax,%edx
f0104280:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104283:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f010428a:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010428e:	0f 84 01 01 00 00    	je     f0104395 <page_fault_handler+0x153>
    	// cprintf("user page fault, exist env's page fault upcall \n");
    	// exist env's page fault upcall
		// void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

    	struct UTrapframe * ut;
    	if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp <= UXSTACKTOP - 1) {
f0104294:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104297:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f010429d:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01042a3:	77 25                	ja     f01042ca <page_fault_handler+0x88>
    		// already in user exception stack, should first push an empty 32-bit word
    		ut = (struct UTrapframe *)((void *)tf->tf_esp - sizeof(struct UTrapframe) - 4);
f01042a5:	83 e8 38             	sub    $0x38,%eax
f01042a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe) + 4, PTE_U | PTE_W);
f01042ab:	e8 a4 1e 00 00       	call   f0106154 <cpunum>
f01042b0:	6a 06                	push   $0x6
f01042b2:	6a 38                	push   $0x38
f01042b4:	ff 75 e0             	pushl  -0x20(%ebp)
f01042b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ba:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f01042c0:	e8 79 f0 ff ff       	call   f010333e <user_mem_assert>
f01042c5:	83 c4 10             	add    $0x10,%esp
f01042c8:	eb 26                	jmp    f01042f0 <page_fault_handler+0xae>
    	} else {
    		// it's the first time in user exception stack
    		ut = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe), PTE_U | PTE_W);
f01042ca:	e8 85 1e 00 00       	call   f0106154 <cpunum>
f01042cf:	6a 06                	push   $0x6
f01042d1:	6a 34                	push   $0x34
f01042d3:	68 cc ff bf ee       	push   $0xeebfffcc
f01042d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01042db:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f01042e1:	e8 58 f0 ff ff       	call   f010333e <user_mem_assert>
f01042e6:	83 c4 10             	add    $0x10,%esp
    		// already in user exception stack, should first push an empty 32-bit word
    		ut = (struct UTrapframe *)((void *)tf->tf_esp - sizeof(struct UTrapframe) - 4);
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe) + 4, PTE_U | PTE_W);
    	} else {
    		// it's the first time in user exception stack
    		ut = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f01042e9:	c7 45 e0 cc ff bf ee 	movl   $0xeebfffcc,-0x20(%ebp)
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe), PTE_U | PTE_W);
    	}
    	
    	ut->utf_esp = tf->tf_esp;
f01042f0:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01042f3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01042f6:	89 42 30             	mov    %eax,0x30(%edx)
    	ut->utf_eflags = tf->tf_eflags;
f01042f9:	8b 43 38             	mov    0x38(%ebx),%eax
f01042fc:	89 42 2c             	mov    %eax,0x2c(%edx)
    	ut->utf_eip = tf->tf_eip;
f01042ff:	8b 43 30             	mov    0x30(%ebx),%eax
f0104302:	89 42 28             	mov    %eax,0x28(%edx)
		ut->utf_regs = tf->tf_regs;
f0104305:	89 d7                	mov    %edx,%edi
f0104307:	83 c7 08             	add    $0x8,%edi
f010430a:	89 de                	mov    %ebx,%esi
f010430c:	b8 20 00 00 00       	mov    $0x20,%eax
f0104311:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104317:	74 03                	je     f010431c <page_fault_handler+0xda>
f0104319:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f010431a:	b0 1f                	mov    $0x1f,%al
f010431c:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104322:	74 05                	je     f0104329 <page_fault_handler+0xe7>
f0104324:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104326:	83 e8 02             	sub    $0x2,%eax
f0104329:	89 c1                	mov    %eax,%ecx
f010432b:	c1 e9 02             	shr    $0x2,%ecx
f010432e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104330:	a8 02                	test   $0x2,%al
f0104332:	74 02                	je     f0104336 <page_fault_handler+0xf4>
f0104334:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104336:	a8 01                	test   $0x1,%al
f0104338:	74 01                	je     f010433b <page_fault_handler+0xf9>
f010433a:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		ut->utf_err = tf->tf_err;
f010433b:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010433e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104341:	89 42 04             	mov    %eax,0x4(%edx)
		ut->utf_fault_va = fault_va;
f0104344:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104347:	89 02                	mov    %eax,(%edx)

		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0104349:	e8 06 1e 00 00       	call   f0106154 <cpunum>
f010434e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104351:	8b 98 28 60 2e f0    	mov    -0xfd19fd8(%eax),%ebx
f0104357:	e8 f8 1d 00 00       	call   f0106154 <cpunum>
f010435c:	6b c0 74             	imul   $0x74,%eax,%eax
f010435f:	8b 80 28 60 2e f0    	mov    -0xfd19fd8(%eax),%eax
f0104365:	8b 40 64             	mov    0x64(%eax),%eax
f0104368:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (uint32_t)ut;
f010436b:	e8 e4 1d 00 00       	call   f0106154 <cpunum>
f0104370:	6b c0 74             	imul   $0x74,%eax,%eax
f0104373:	8b 80 28 60 2e f0    	mov    -0xfd19fd8(%eax),%eax
f0104379:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010437c:	89 50 3c             	mov    %edx,0x3c(%eax)
    	env_run(curenv);
f010437f:	e8 d0 1d 00 00       	call   f0106154 <cpunum>
f0104384:	83 ec 0c             	sub    $0xc,%esp
f0104387:	6b c0 74             	imul   $0x74,%eax,%eax
f010438a:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f0104390:	e8 63 f7 ff ff       	call   f0103af8 <env_run>
    } else {
    	// cprintf("user page fault, env_pgfault_upcall == NULL\n");
   	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104395:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104398:	e8 b7 1d 00 00       	call   f0106154 <cpunum>
    } else {
    	// cprintf("user page fault, env_pgfault_upcall == NULL\n");
   	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010439d:	56                   	push   %esi
f010439e:	ff 75 e4             	pushl  -0x1c(%ebp)
		curenv->env_id, fault_va, tf->tf_eip);
f01043a1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01043a8:	29 c2                	sub    %eax,%edx
f01043aa:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01043ad:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
    } else {
    	// cprintf("user page fault, env_pgfault_upcall == NULL\n");
   	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01043b4:	ff 70 48             	pushl  0x48(%eax)
f01043b7:	68 e0 82 10 f0       	push   $0xf01082e0
f01043bc:	e8 9c f9 ff ff       	call   f0103d5d <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01043c1:	89 1c 24             	mov    %ebx,(%esp)
f01043c4:	e8 f4 fc ff ff       	call   f01040bd <print_trapframe>
	env_destroy(curenv);
f01043c9:	e8 86 1d 00 00       	call   f0106154 <cpunum>
f01043ce:	83 c4 04             	add    $0x4,%esp
f01043d1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01043d8:	29 c2                	sub    %eax,%edx
f01043da:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01043dd:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f01043e4:	e8 52 f6 ff ff       	call   f0103a3b <env_destroy>
f01043e9:	83 c4 10             	add    $0x10,%esp
}
f01043ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01043ef:	5b                   	pop    %ebx
f01043f0:	5e                   	pop    %esi
f01043f1:	5f                   	pop    %edi
f01043f2:	c9                   	leave  
f01043f3:	c3                   	ret    

f01043f4 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01043f4:	55                   	push   %ebp
f01043f5:	89 e5                	mov    %esp,%ebp
f01043f7:	57                   	push   %edi
f01043f8:	56                   	push   %esi
f01043f9:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01043fc:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01043fd:	83 3d 80 5e 2e f0 00 	cmpl   $0x0,0xf02e5e80
f0104404:	74 01                	je     f0104407 <trap+0x13>
		asm volatile("hlt");
f0104406:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104407:	e8 48 1d 00 00       	call   f0106154 <cpunum>
f010440c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104413:	29 c2                	sub    %eax,%edx
f0104415:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104418:	8d 14 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010441f:	b8 01 00 00 00       	mov    $0x1,%eax
f0104424:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104428:	83 f8 02             	cmp    $0x2,%eax
f010442b:	75 10                	jne    f010443d <trap+0x49>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010442d:	83 ec 0c             	sub    $0xc,%esp
f0104430:	68 60 84 12 f0       	push   $0xf0128460
f0104435:	e8 d1 1f 00 00       	call   f010640b <spin_lock>
f010443a:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010443d:	9c                   	pushf  
f010443e:	58                   	pop    %eax
		lock_kernel();

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010443f:	f6 c4 02             	test   $0x2,%ah
f0104442:	74 19                	je     f010445d <trap+0x69>
f0104444:	68 1b 81 10 f0       	push   $0xf010811b
f0104449:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010444e:	68 1d 01 00 00       	push   $0x11d
f0104453:	68 0f 81 10 f0       	push   $0xf010810f
f0104458:	e8 0b bc ff ff       	call   f0100068 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010445d:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104461:	83 e0 03             	and    $0x3,%eax
f0104464:	83 f8 03             	cmp    $0x3,%eax
f0104467:	0f 85 dc 00 00 00    	jne    f0104549 <trap+0x155>
f010446d:	83 ec 0c             	sub    $0xc,%esp
f0104470:	68 60 84 12 f0       	push   $0xf0128460
f0104475:	e8 91 1f 00 00       	call   f010640b <spin_lock>
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();

		assert(curenv);
f010447a:	e8 d5 1c 00 00       	call   f0106154 <cpunum>
f010447f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104486:	29 c2                	sub    %eax,%edx
f0104488:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010448b:	83 c4 10             	add    $0x10,%esp
f010448e:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f0104495:	00 
f0104496:	75 19                	jne    f01044b1 <trap+0xbd>
f0104498:	68 34 81 10 f0       	push   $0xf0108134
f010449d:	68 f7 7b 10 f0       	push   $0xf0107bf7
f01044a2:	68 26 01 00 00       	push   $0x126
f01044a7:	68 0f 81 10 f0       	push   $0xf010810f
f01044ac:	e8 b7 bb ff ff       	call   f0100068 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01044b1:	e8 9e 1c 00 00       	call   f0106154 <cpunum>
f01044b6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044bd:	29 c2                	sub    %eax,%edx
f01044bf:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01044c2:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f01044c9:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01044cd:	75 41                	jne    f0104510 <trap+0x11c>
			env_free(curenv);
f01044cf:	e8 80 1c 00 00       	call   f0106154 <cpunum>
f01044d4:	83 ec 0c             	sub    $0xc,%esp
f01044d7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044de:	29 c2                	sub    %eax,%edx
f01044e0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01044e3:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f01044ea:	e8 6f f3 ff ff       	call   f010385e <env_free>
			curenv = NULL;
f01044ef:	e8 60 1c 00 00       	call   f0106154 <cpunum>
f01044f4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044fb:	29 c2                	sub    %eax,%edx
f01044fd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104500:	c7 04 85 28 60 2e f0 	movl   $0x0,-0xfd19fd8(,%eax,4)
f0104507:	00 00 00 00 
			sched_yield();
f010450b:	e8 fb 02 00 00       	call   f010480b <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104510:	e8 3f 1c 00 00       	call   f0106154 <cpunum>
f0104515:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010451c:	29 c2                	sub    %eax,%edx
f010451e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104521:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0104528:	b9 11 00 00 00       	mov    $0x11,%ecx
f010452d:	89 c7                	mov    %eax,%edi
f010452f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104531:	e8 1e 1c 00 00       	call   f0106154 <cpunum>
f0104536:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010453d:	29 c2                	sub    %eax,%edx
f010453f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104542:	8b 34 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104549:	89 35 60 5a 2e f0    	mov    %esi,0xf02e5a60
	// LAB 3: Your code here.
    // cprintf("CPU %d, TRAP NUM : %u\n", cpunum(), tf->tf_trapno);
    
    int r;

	if (tf->tf_trapno == T_DEBUG) {
f010454f:	8b 46 28             	mov    0x28(%esi),%eax
f0104552:	83 f8 01             	cmp    $0x1,%eax
f0104555:	75 11                	jne    f0104568 <trap+0x174>
		monitor(tf);
f0104557:	83 ec 0c             	sub    $0xc,%esp
f010455a:	56                   	push   %esi
f010455b:	e8 d1 ca ff ff       	call   f0101031 <monitor>
f0104560:	83 c4 10             	add    $0x10,%esp
f0104563:	e9 cd 00 00 00       	jmp    f0104635 <trap+0x241>
		return;
	}
	if (tf->tf_trapno == T_PGFLT) {
f0104568:	83 f8 0e             	cmp    $0xe,%eax
f010456b:	75 11                	jne    f010457e <trap+0x18a>
		page_fault_handler(tf);
f010456d:	83 ec 0c             	sub    $0xc,%esp
f0104570:	56                   	push   %esi
f0104571:	e8 cc fc ff ff       	call   f0104242 <page_fault_handler>
f0104576:	83 c4 10             	add    $0x10,%esp
f0104579:	e9 b7 00 00 00       	jmp    f0104635 <trap+0x241>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f010457e:	83 f8 03             	cmp    $0x3,%eax
f0104581:	75 11                	jne    f0104594 <trap+0x1a0>
		monitor(tf);
f0104583:	83 ec 0c             	sub    $0xc,%esp
f0104586:	56                   	push   %esi
f0104587:	e8 a5 ca ff ff       	call   f0101031 <monitor>
f010458c:	83 c4 10             	add    $0x10,%esp
f010458f:	e9 a1 00 00 00       	jmp    f0104635 <trap+0x241>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f0104594:	83 f8 30             	cmp    $0x30,%eax
f0104597:	75 21                	jne    f01045ba <trap+0x1c6>
		r = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104599:	83 ec 08             	sub    $0x8,%esp
f010459c:	ff 76 04             	pushl  0x4(%esi)
f010459f:	ff 36                	pushl  (%esi)
f01045a1:	ff 76 10             	pushl  0x10(%esi)
f01045a4:	ff 76 18             	pushl  0x18(%esi)
f01045a7:	ff 76 14             	pushl  0x14(%esi)
f01045aa:	ff 76 1c             	pushl  0x1c(%esi)
f01045ad:	e8 76 03 00 00       	call   f0104928 <syscall>
                       tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = r;
f01045b2:	89 46 1c             	mov    %eax,0x1c(%esi)
f01045b5:	83 c4 20             	add    $0x20,%esp
f01045b8:	eb 7b                	jmp    f0104635 <trap+0x241>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01045ba:	83 f8 27             	cmp    $0x27,%eax
f01045bd:	75 1a                	jne    f01045d9 <trap+0x1e5>
		cprintf("Spurious interrupt on irq 7\n");
f01045bf:	83 ec 0c             	sub    $0xc,%esp
f01045c2:	68 3b 81 10 f0       	push   $0xf010813b
f01045c7:	e8 91 f7 ff ff       	call   f0103d5d <cprintf>
		print_trapframe(tf);
f01045cc:	89 34 24             	mov    %esi,(%esp)
f01045cf:	e8 e9 fa ff ff       	call   f01040bd <print_trapframe>
f01045d4:	83 c4 10             	add    $0x10,%esp
f01045d7:	eb 5c                	jmp    f0104635 <trap+0x241>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01045d9:	83 f8 20             	cmp    $0x20,%eax
f01045dc:	75 0a                	jne    f01045e8 <trap+0x1f4>
		lapic_eoi();
f01045de:	e8 cb 1c 00 00       	call   f01062ae <lapic_eoi>
		sched_yield();
f01045e3:	e8 23 02 00 00       	call   f010480b <sched_yield>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01045e8:	83 ec 0c             	sub    $0xc,%esp
f01045eb:	56                   	push   %esi
f01045ec:	e8 cc fa ff ff       	call   f01040bd <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01045f1:	83 c4 10             	add    $0x10,%esp
f01045f4:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01045f9:	75 17                	jne    f0104612 <trap+0x21e>
		panic("unhandled trap in kernel");
f01045fb:	83 ec 04             	sub    $0x4,%esp
f01045fe:	68 58 81 10 f0       	push   $0xf0108158
f0104603:	68 02 01 00 00       	push   $0x102
f0104608:	68 0f 81 10 f0       	push   $0xf010810f
f010460d:	e8 56 ba ff ff       	call   f0100068 <_panic>
	else {
		env_destroy(curenv);
f0104612:	e8 3d 1b 00 00       	call   f0106154 <cpunum>
f0104617:	83 ec 0c             	sub    $0xc,%esp
f010461a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104621:	29 c2                	sub    %eax,%edx
f0104623:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104626:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f010462d:	e8 09 f4 ff ff       	call   f0103a3b <env_destroy>
f0104632:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0104635:	e8 1a 1b 00 00       	call   f0106154 <cpunum>
f010463a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104641:	29 c2                	sub    %eax,%edx
f0104643:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104646:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f010464d:	00 
f010464e:	74 3e                	je     f010468e <trap+0x29a>
f0104650:	e8 ff 1a 00 00       	call   f0106154 <cpunum>
f0104655:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010465c:	29 c2                	sub    %eax,%edx
f010465e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104661:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0104668:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010466c:	75 20                	jne    f010468e <trap+0x29a>
		// cprintf("Env\n");
		env_run(curenv);
f010466e:	e8 e1 1a 00 00       	call   f0106154 <cpunum>
f0104673:	83 ec 0c             	sub    $0xc,%esp
f0104676:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010467d:	29 c2                	sub    %eax,%edx
f010467f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104682:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f0104689:	e8 6a f4 ff ff       	call   f0103af8 <env_run>
	} else {
		// cprintf("trap sched_yield\n");
		sched_yield();
f010468e:	e8 78 01 00 00       	call   f010480b <sched_yield>
	...

f0104694 <vec0>:
.data
.align 2
.globl vectors
vectors:
.text
	MYTH_NOEC(vec0, T_DIVIDE)
f0104694:	6a 00                	push   $0x0
f0104696:	6a 00                	push   $0x0
f0104698:	e9 79 3d 02 00       	jmp    f0128416 <_alltraps>
f010469d:	90                   	nop

f010469e <vec1>:
 	MYTH_NOEC(vec1, T_DEBUG)
f010469e:	6a 00                	push   $0x0
f01046a0:	6a 01                	push   $0x1
f01046a2:	e9 6f 3d 02 00       	jmp    f0128416 <_alltraps>
f01046a7:	90                   	nop

f01046a8 <vec2>:
 	MYTH_NOEC(vec2, T_NMI)
f01046a8:	6a 00                	push   $0x0
f01046aa:	6a 02                	push   $0x2
f01046ac:	e9 65 3d 02 00       	jmp    f0128416 <_alltraps>
f01046b1:	90                   	nop

f01046b2 <vec3>:
 	MYTH_NOEC(vec3, T_BRKPT)
f01046b2:	6a 00                	push   $0x0
f01046b4:	6a 03                	push   $0x3
f01046b6:	e9 5b 3d 02 00       	jmp    f0128416 <_alltraps>
f01046bb:	90                   	nop

f01046bc <vec4>:
 	MYTH_NOEC(vec4, T_OFLOW)
f01046bc:	6a 00                	push   $0x0
f01046be:	6a 04                	push   $0x4
f01046c0:	e9 51 3d 02 00       	jmp    f0128416 <_alltraps>
f01046c5:	90                   	nop

f01046c6 <vec6>:
 	MYTH_NULL()
 	MYTH_NOEC(vec6, T_BOUND)
f01046c6:	6a 00                	push   $0x0
f01046c8:	6a 05                	push   $0x5
f01046ca:	e9 47 3d 02 00       	jmp    f0128416 <_alltraps>
f01046cf:	90                   	nop

f01046d0 <vec7>:
	MYTH_NOEC(vec7, T_DEVICE)
f01046d0:	6a 00                	push   $0x0
f01046d2:	6a 07                	push   $0x7
f01046d4:	e9 3d 3d 02 00       	jmp    f0128416 <_alltraps>
f01046d9:	90                   	nop

f01046da <vec8>:
 	MYTH(vec8, T_DBLFLT)
f01046da:	6a 08                	push   $0x8
f01046dc:	e9 35 3d 02 00       	jmp    f0128416 <_alltraps>
f01046e1:	90                   	nop

f01046e2 <vec10>:
 	MYTH_NULL()
 	MYTH(vec10, T_TSS)
f01046e2:	6a 0a                	push   $0xa
f01046e4:	e9 2d 3d 02 00       	jmp    f0128416 <_alltraps>
f01046e9:	90                   	nop

f01046ea <vec11>:
 	MYTH(vec11, T_SEGNP)
f01046ea:	6a 0b                	push   $0xb
f01046ec:	e9 25 3d 02 00       	jmp    f0128416 <_alltraps>
f01046f1:	90                   	nop

f01046f2 <vec12>:
 	MYTH(vec12, T_STACK)
f01046f2:	6a 0c                	push   $0xc
f01046f4:	e9 1d 3d 02 00       	jmp    f0128416 <_alltraps>
f01046f9:	90                   	nop

f01046fa <vec13>:
 	MYTH(vec13, T_GPFLT)
f01046fa:	6a 0d                	push   $0xd
f01046fc:	e9 15 3d 02 00       	jmp    f0128416 <_alltraps>
f0104701:	90                   	nop

f0104702 <vec14>:
 	MYTH(vec14, T_PGFLT) 
f0104702:	6a 0e                	push   $0xe
f0104704:	e9 0d 3d 02 00       	jmp    f0128416 <_alltraps>
f0104709:	90                   	nop

f010470a <vec16>:
 	MYTH_NULL()
 	MYTH_NOEC(vec16, T_FPERR)
f010470a:	6a 00                	push   $0x0
f010470c:	6a 10                	push   $0x10
f010470e:	e9 03 3d 02 00       	jmp    f0128416 <_alltraps>
f0104713:	90                   	nop

f0104714 <vec17>:
 	MYTH(vec17, T_ALIGN)
f0104714:	6a 11                	push   $0x11
f0104716:	e9 fb 3c 02 00       	jmp    f0128416 <_alltraps>
f010471b:	90                   	nop

f010471c <vec18>:
 	MYTH_NOEC(vec18, T_MCHK)
f010471c:	6a 00                	push   $0x0
f010471e:	6a 12                	push   $0x12
f0104720:	e9 f1 3c 02 00       	jmp    f0128416 <_alltraps>
f0104725:	90                   	nop

f0104726 <vec19>:
 	MYTH_NOEC(vec19, T_SIMDERR)
f0104726:	6a 00                	push   $0x0
f0104728:	6a 13                	push   $0x13
f010472a:	e9 e7 3c 02 00       	jmp    f0128416 <_alltraps>
	...

f0104730 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104730:	55                   	push   %ebp
f0104731:	89 e5                	mov    %esp,%ebp
f0104733:	83 ec 08             	sub    $0x8,%esp
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104736:	8b 15 3c 52 2e f0    	mov    0xf02e523c,%edx
f010473c:	8b 42 54             	mov    0x54(%edx),%eax
f010473f:	83 e8 02             	sub    $0x2,%eax
f0104742:	83 f8 01             	cmp    $0x1,%eax
f0104745:	76 46                	jbe    f010478d <sched_halt+0x5d>
			else cprintf("ENV_RUNNING\n");
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
f0104747:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010474c:	8b 8a d0 00 00 00    	mov    0xd0(%edx),%ecx
f0104752:	83 e9 02             	sub    $0x2,%ecx
f0104755:	83 f9 01             	cmp    $0x1,%ecx
f0104758:	76 0d                	jbe    f0104767 <sched_halt+0x37>
			else cprintf("ENV_RUNNING\n");
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
f010475a:	40                   	inc    %eax
f010475b:	83 c2 7c             	add    $0x7c,%edx
f010475e:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104763:	75 e7                	jne    f010474c <sched_halt+0x1c>
f0104765:	eb 07                	jmp    f010476e <sched_halt+0x3e>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	
	if (i == NENV) {
f0104767:	3d 00 04 00 00       	cmp    $0x400,%eax
f010476c:	75 1f                	jne    f010478d <sched_halt+0x5d>
		cprintf("No runnable environments in the system!\n");
f010476e:	83 ec 0c             	sub    $0xc,%esp
f0104771:	68 70 83 10 f0       	push   $0xf0108370
f0104776:	e8 e2 f5 ff ff       	call   f0103d5d <cprintf>
f010477b:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010477e:	83 ec 0c             	sub    $0xc,%esp
f0104781:	6a 00                	push   $0x0
f0104783:	e8 a9 c8 ff ff       	call   f0101031 <monitor>
f0104788:	83 c4 10             	add    $0x10,%esp
f010478b:	eb f1                	jmp    f010477e <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010478d:	e8 c2 19 00 00       	call   f0106154 <cpunum>
f0104792:	6b c0 74             	imul   $0x74,%eax,%eax
f0104795:	c7 80 28 60 2e f0 00 	movl   $0x0,-0xfd19fd8(%eax)
f010479c:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010479f:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01047a4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01047a9:	77 12                	ja     f01047bd <sched_halt+0x8d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01047ab:	50                   	push   %eax
f01047ac:	68 44 68 10 f0       	push   $0xf0106844
f01047b1:	6a 57                	push   $0x57
f01047b3:	68 99 83 10 f0       	push   $0xf0108399
f01047b8:	e8 ab b8 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01047bd:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01047c2:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01047c5:	e8 8a 19 00 00       	call   f0106154 <cpunum>
f01047ca:	6b d0 74             	imul   $0x74,%eax,%edx
f01047cd:	81 c2 20 60 2e f0    	add    $0xf02e6020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01047d3:	b8 02 00 00 00       	mov    $0x2,%eax
f01047d8:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01047dc:	83 ec 0c             	sub    $0xc,%esp
f01047df:	68 60 84 12 f0       	push   $0xf0128460
f01047e4:	e8 dd 1c 00 00       	call   f01064c6 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01047e9:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01047eb:	e8 64 19 00 00       	call   f0106154 <cpunum>
f01047f0:	6b c0 74             	imul   $0x74,%eax,%eax
	// Release the big kernel lock as if we were "leaving" the kernel
	
	unlock_kernel();
	
	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01047f3:	8b 80 30 60 2e f0    	mov    -0xfd19fd0(%eax),%eax
f01047f9:	bd 00 00 00 00       	mov    $0x0,%ebp
f01047fe:	89 c4                	mov    %eax,%esp
f0104800:	6a 00                	push   $0x0
f0104802:	6a 00                	push   $0x0
f0104804:	fb                   	sti    
f0104805:	f4                   	hlt    
f0104806:	83 c4 10             	add    $0x10,%esp
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104809:	c9                   	leave  
f010480a:	c3                   	ret    

f010480b <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010480b:	55                   	push   %ebp
f010480c:	89 e5                	mov    %esp,%ebp
f010480e:	56                   	push   %esi
f010480f:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int now_env, i;
	if (curenv) {			// thiscpu->cpu_env
f0104810:	e8 3f 19 00 00       	call   f0106154 <cpunum>
f0104815:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010481c:	29 c2                	sub    %eax,%edx
f010481e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104821:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f0104828:	00 
f0104829:	74 2e                	je     f0104859 <sched_yield+0x4e>
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
f010482b:	e8 24 19 00 00       	call   f0106154 <cpunum>
f0104830:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104837:	29 c2                	sub    %eax,%edx
f0104839:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010483c:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0104843:	8b 40 48             	mov    0x48(%eax),%eax
f0104846:	8d 40 01             	lea    0x1(%eax),%eax
f0104849:	25 ff 03 00 00       	and    $0x3ff,%eax
f010484e:	79 0e                	jns    f010485e <sched_yield+0x53>
f0104850:	48                   	dec    %eax
f0104851:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0104856:	40                   	inc    %eax
f0104857:	eb 05                	jmp    f010485e <sched_yield+0x53>
	} else {
		now_env = 0;
f0104859:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
		if (envs[now_env].env_status == ENV_RUNNABLE) {
f010485e:	8b 1d 3c 52 2e f0    	mov    0xf02e523c,%ebx
f0104864:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010486b:	89 c1                	mov    %eax,%ecx
f010486d:	c1 e1 07             	shl    $0x7,%ecx
f0104870:	29 d1                	sub    %edx,%ecx
f0104872:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f0104875:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f0104879:	0f 85 8f 00 00 00    	jne    f010490e <sched_yield+0x103>
f010487f:	eb 26                	jmp    f01048a7 <sched_yield+0x9c>
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f0104881:	40                   	inc    %eax
f0104882:	25 ff 03 00 80       	and    $0x800003ff,%eax
f0104887:	79 07                	jns    f0104890 <sched_yield+0x85>
f0104889:	48                   	dec    %eax
f010488a:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f010488f:	40                   	inc    %eax
		if (envs[now_env].env_status == ENV_RUNNABLE) {
f0104890:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
f0104897:	89 c1                	mov    %eax,%ecx
f0104899:	c1 e1 07             	shl    $0x7,%ecx
f010489c:	29 f1                	sub    %esi,%ecx
f010489e:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f01048a1:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f01048a5:	75 09                	jne    f01048b0 <sched_yield+0xa5>
			//cprintf("I am CPU %d , I am in sched yield, I find ENV %d\n", thiscpu->cpu_id, now_env);
			env_run(&envs[now_env]);
f01048a7:	83 ec 0c             	sub    $0xc,%esp
f01048aa:	51                   	push   %ecx
f01048ab:	e8 48 f2 ff ff       	call   f0103af8 <env_run>
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f01048b0:	4a                   	dec    %edx
f01048b1:	75 ce                	jne    f0104881 <sched_yield+0x76>
		if (envs[now_env].env_status == ENV_RUNNABLE) {
			//cprintf("I am CPU %d , I am in sched yield, I find ENV %d\n", thiscpu->cpu_id, now_env);
			env_run(&envs[now_env]);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING) {
f01048b3:	e8 9c 18 00 00       	call   f0106154 <cpunum>
f01048b8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01048bf:	29 c2                	sub    %eax,%edx
f01048c1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01048c4:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f01048cb:	00 
f01048cc:	74 34                	je     f0104902 <sched_yield+0xf7>
f01048ce:	e8 81 18 00 00       	call   f0106154 <cpunum>
f01048d3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01048da:	29 c2                	sub    %eax,%edx
f01048dc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01048df:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f01048e6:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01048ea:	75 16                	jne    f0104902 <sched_yield+0xf7>
		env_run(curenv);
f01048ec:	e8 63 18 00 00       	call   f0106154 <cpunum>
f01048f1:	83 ec 0c             	sub    $0xc,%esp
f01048f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01048f7:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f01048fd:	e8 f6 f1 ff ff       	call   f0103af8 <env_run>
	}

	// sched_halt never returns
	sched_halt();
f0104902:	e8 29 fe ff ff       	call   f0104730 <sched_halt>
}
f0104907:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010490a:	5b                   	pop    %ebx
f010490b:	5e                   	pop    %esi
f010490c:	c9                   	leave  
f010490d:	c3                   	ret    
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f010490e:	40                   	inc    %eax
f010490f:	25 ff 03 00 80       	and    $0x800003ff,%eax
f0104914:	79 07                	jns    f010491d <sched_yield+0x112>
f0104916:	48                   	dec    %eax
f0104917:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f010491c:	40                   	inc    %eax
f010491d:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0104922:	e9 69 ff ff ff       	jmp    f0104890 <sched_yield+0x85>
	...

f0104928 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104928:	55                   	push   %ebp
f0104929:	89 e5                	mov    %esp,%ebp
f010492b:	57                   	push   %edi
f010492c:	56                   	push   %esi
f010492d:	53                   	push   %ebx
f010492e:	83 ec 1c             	sub    $0x1c,%esp
f0104931:	8b 45 08             	mov    0x8(%ebp),%eax
f0104934:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104937:	8b 75 10             	mov    0x10(%ebp),%esi
f010493a:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
    
	int r = 0;
    switch (syscallno) {
f010493d:	83 f8 0c             	cmp    $0xc,%eax
f0104940:	0f 87 b4 05 00 00    	ja     f0104efa <syscall+0x5d2>
f0104946:	ff 24 85 fc 83 10 f0 	jmp    *-0xfef7c04(,%eax,4)
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env * new_env;
	int r = env_alloc(&new_env, curenv->env_id);
f010494d:	e8 02 18 00 00       	call   f0106154 <cpunum>
f0104952:	83 ec 08             	sub    $0x8,%esp
f0104955:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010495c:	29 c2                	sub    %eax,%edx
f010495e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104961:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0104968:	ff 70 48             	pushl  0x48(%eax)
f010496b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010496e:	50                   	push   %eax
f010496f:	e8 e5 eb ff ff       	call   f0103559 <env_alloc>
	if (r < 0) return r;
f0104974:	83 c4 10             	add    $0x10,%esp
f0104977:	85 c0                	test   %eax,%eax
f0104979:	0f 88 80 05 00 00    	js     f0104eff <syscall+0x5d7>
	
	new_env->env_status = ENV_NOT_RUNNABLE;
f010497f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104982:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memcpy((void *)(&new_env->env_tf), (void*)(&curenv->env_tf), sizeof(struct Trapframe));
f0104989:	e8 c6 17 00 00       	call   f0106154 <cpunum>
f010498e:	83 ec 04             	sub    $0x4,%esp
f0104991:	6a 44                	push   $0x44
f0104993:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010499a:	29 c2                	sub    %eax,%edx
f010499c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010499f:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f01049a6:	ff 75 e4             	pushl  -0x1c(%ebp)
f01049a9:	e8 2b 12 00 00       	call   f0105bd9 <memcpy>
	
	// for children environment, return 0
	new_env->env_tf.tf_regs.reg_eax = 0;
f01049ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049b1:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return new_env->env_id;
f01049b8:	8b 40 48             	mov    0x48(%eax),%eax
f01049bb:	83 c4 10             	add    $0x10,%esp
    
	int r = 0;
    switch (syscallno) {
    	case SYS_exofork:
    		r = sys_exofork();
    		break;
f01049be:	e9 3c 05 00 00       	jmp    f0104eff <syscall+0x5d7>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	// LAB 4: Your code here.

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
f01049c3:	83 fe 02             	cmp    $0x2,%esi
f01049c6:	74 05                	je     f01049cd <syscall+0xa5>
f01049c8:	83 fe 04             	cmp    $0x4,%esi
f01049cb:	75 2a                	jne    f01049f7 <syscall+0xcf>
		return -E_INVAL;

	struct Env * env;
	int r = envid2env(envid, &env, 1);
f01049cd:	83 ec 04             	sub    $0x4,%esp
f01049d0:	6a 01                	push   $0x1
f01049d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049d5:	50                   	push   %eax
f01049d6:	53                   	push   %ebx
f01049d7:	e8 32 ea ff ff       	call   f010340e <envid2env>
	if (r < 0) return r;
f01049dc:	83 c4 10             	add    $0x10,%esp
f01049df:	85 c0                	test   %eax,%eax
f01049e1:	0f 88 18 05 00 00    	js     f0104eff <syscall+0x5d7>
	env->env_status = status;
f01049e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049ea:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f01049ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01049f2:	e9 08 05 00 00       	jmp    f0104eff <syscall+0x5d7>
	// check whether the current environment has permission to set
	// envid's status.
	// LAB 4: Your code here.

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
		return -E_INVAL;
f01049f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
    	case SYS_exofork:
    		r = sys_exofork();
    		break;
    	case SYS_env_set_status:
    		r = sys_env_set_status((envid_t)a1, (int)a2);
    		break;
f01049fc:	e9 fe 04 00 00       	jmp    f0104eff <syscall+0x5d7>
	//   allocated!
	// LAB 4: Your code here.
	// cprintf("In kernel sys_page_alloc function\n");

	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104a01:	83 ec 04             	sub    $0x4,%esp
f0104a04:	6a 01                	push   $0x1
f0104a06:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a09:	50                   	push   %eax
f0104a0a:	53                   	push   %ebx
f0104a0b:	e8 fe e9 ff ff       	call   f010340e <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104a10:	83 c4 10             	add    $0x10,%esp
f0104a13:	85 c0                	test   %eax,%eax
f0104a15:	0f 88 88 00 00 00    	js     f0104aa3 <syscall+0x17b>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104a1b:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104a21:	0f 87 86 00 00 00    	ja     f0104aad <syscall+0x185>
f0104a27:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0104a2d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104a33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a38:	39 d6                	cmp    %edx,%esi
f0104a3a:	0f 85 bf 04 00 00    	jne    f0104eff <syscall+0x5d7>
	
	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;
f0104a40:	89 fa                	mov    %edi,%edx
f0104a42:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f0104a48:	83 fa 05             	cmp    $0x5,%edx
f0104a4b:	0f 85 ae 04 00 00    	jne    f0104eff <syscall+0x5d7>

	struct PageInfo * pg = page_alloc(ALLOC_ZERO);
f0104a51:	83 ec 0c             	sub    $0xc,%esp
f0104a54:	6a 01                	push   $0x1
f0104a56:	e8 72 cb ff ff       	call   f01015cd <page_alloc>
f0104a5b:	89 c3                	mov    %eax,%ebx
	if (pg == NULL) return -E_NO_MEM;
f0104a5d:	83 c4 10             	add    $0x10,%esp
f0104a60:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104a65:	85 db                	test   %ebx,%ebx
f0104a67:	0f 84 92 04 00 00    	je     f0104eff <syscall+0x5d7>
	if (page_insert(env->env_pgdir, pg, va, perm) < 0) {
f0104a6d:	57                   	push   %edi
f0104a6e:	56                   	push   %esi
f0104a6f:	53                   	push   %ebx
f0104a70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a73:	ff 70 60             	pushl  0x60(%eax)
f0104a76:	e8 fe cd ff ff       	call   f0101879 <page_insert>
f0104a7b:	89 c2                	mov    %eax,%edx
f0104a7d:	83 c4 10             	add    $0x10,%esp
		// page_insert fails, should free the page you allocated!  
		page_free(pg);
		return -E_NO_MEM;
	}
	return 0;
f0104a80:	b8 00 00 00 00       	mov    $0x0,%eax
	
	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;

	struct PageInfo * pg = page_alloc(ALLOC_ZERO);
	if (pg == NULL) return -E_NO_MEM;
	if (page_insert(env->env_pgdir, pg, va, perm) < 0) {
f0104a85:	85 d2                	test   %edx,%edx
f0104a87:	0f 89 72 04 00 00    	jns    f0104eff <syscall+0x5d7>
		// page_insert fails, should free the page you allocated!  
		page_free(pg);
f0104a8d:	83 ec 0c             	sub    $0xc,%esp
f0104a90:	53                   	push   %ebx
f0104a91:	e8 c1 cb ff ff       	call   f0101657 <page_free>
f0104a96:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104a99:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104a9e:	e9 5c 04 00 00       	jmp    f0104eff <syscall+0x5d7>
	// LAB 4: Your code here.
	// cprintf("In kernel sys_page_alloc function\n");

	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;
f0104aa3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104aa8:	e9 52 04 00 00       	jmp    f0104eff <syscall+0x5d7>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104aad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ab2:	e9 48 04 00 00       	jmp    f0104eff <syscall+0x5d7>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	// LAB 4: Your code here.

	struct Env * dstenv, * srcenv;
	int r = envid2env(dstenvid, &dstenv, 1);
f0104ab7:	83 ec 04             	sub    $0x4,%esp
f0104aba:	6a 01                	push   $0x1
f0104abc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104abf:	50                   	push   %eax
f0104ac0:	57                   	push   %edi
f0104ac1:	e8 48 e9 ff ff       	call   f010340e <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104ac6:	83 c4 10             	add    $0x10,%esp
f0104ac9:	85 c0                	test   %eax,%eax
f0104acb:	0f 88 cd 00 00 00    	js     f0104b9e <syscall+0x276>
	r = envid2env(srcenvid, &srcenv, 1);
f0104ad1:	83 ec 04             	sub    $0x4,%esp
f0104ad4:	6a 01                	push   $0x1
f0104ad6:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ad9:	50                   	push   %eax
f0104ada:	53                   	push   %ebx
f0104adb:	e8 2e e9 ff ff       	call   f010340e <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104ae0:	83 c4 10             	add    $0x10,%esp
f0104ae3:	85 c0                	test   %eax,%eax
f0104ae5:	0f 88 bd 00 00 00    	js     f0104ba8 <syscall+0x280>

	if ((uint32_t)srcva >= UTOP || ROUNDUP(srcva, PGSIZE) != srcva) return -E_INVAL;
f0104aeb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104af0:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104af6:	0f 87 03 04 00 00    	ja     f0104eff <syscall+0x5d7>
f0104afc:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0104b02:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104b08:	39 d6                	cmp    %edx,%esi
f0104b0a:	0f 85 ef 03 00 00    	jne    f0104eff <syscall+0x5d7>
	if ((uint32_t)dstva >= UTOP || ROUNDUP(dstva, PGSIZE) != dstva) return -E_INVAL;
f0104b10:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104b17:	0f 87 e2 03 00 00    	ja     f0104eff <syscall+0x5d7>
f0104b1d:	8b 55 18             	mov    0x18(%ebp),%edx
f0104b20:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0104b26:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104b2c:	39 55 18             	cmp    %edx,0x18(%ebp)
f0104b2f:	0f 85 ca 03 00 00    	jne    f0104eff <syscall+0x5d7>


	// struct PageInfo * page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
	struct PageInfo * pg;
	pte_t * pte;
	pg = page_lookup(srcenv->env_pgdir, srcva, &pte);
f0104b35:	83 ec 04             	sub    $0x4,%esp
f0104b38:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104b3b:	50                   	push   %eax
f0104b3c:	56                   	push   %esi
f0104b3d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104b40:	ff 70 60             	pushl  0x60(%eax)
f0104b43:	e8 35 cc ff ff       	call   f010177d <page_lookup>
f0104b48:	89 c2                	mov    %eax,%edx
	if (pg == NULL) return -E_INVAL;		
f0104b4a:	83 c4 10             	add    $0x10,%esp
f0104b4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b52:	85 d2                	test   %edx,%edx
f0104b54:	0f 84 a5 03 00 00    	je     f0104eff <syscall+0x5d7>

	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;
f0104b5a:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104b5d:	81 e1 fd f1 ff ff    	and    $0xfffff1fd,%ecx
f0104b63:	83 f9 05             	cmp    $0x5,%ecx
f0104b66:	0f 85 93 03 00 00    	jne    f0104eff <syscall+0x5d7>
	
	if ((perm & PTE_W) && ((*pte) & PTE_W) == 0) return -E_INVAL;
f0104b6c:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104b70:	74 0c                	je     f0104b7e <syscall+0x256>
f0104b72:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104b75:	f6 01 02             	testb  $0x2,(%ecx)
f0104b78:	0f 84 81 03 00 00    	je     f0104eff <syscall+0x5d7>

	// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	if (page_insert(dstenv->env_pgdir, pg, dstva, perm) < 0) return -E_NO_MEM;
f0104b7e:	ff 75 1c             	pushl  0x1c(%ebp)
f0104b81:	ff 75 18             	pushl  0x18(%ebp)
f0104b84:	52                   	push   %edx
f0104b85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b88:	ff 70 60             	pushl  0x60(%eax)
f0104b8b:	e8 e9 cc ff ff       	call   f0101879 <page_insert>
f0104b90:	83 c4 10             	add    $0x10,%esp
f0104b93:	c1 f8 1f             	sar    $0x1f,%eax
f0104b96:	83 e0 fc             	and    $0xfffffffc,%eax
f0104b99:	e9 61 03 00 00       	jmp    f0104eff <syscall+0x5d7>
	//   check the current permissions on the page.
	// LAB 4: Your code here.

	struct Env * dstenv, * srcenv;
	int r = envid2env(dstenvid, &dstenv, 1);
	if (r < 0) return -E_BAD_ENV;
f0104b9e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104ba3:	e9 57 03 00 00       	jmp    f0104eff <syscall+0x5d7>
	r = envid2env(srcenvid, &srcenv, 1);
	if (r < 0) return -E_BAD_ENV;
f0104ba8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104bad:	e9 4d 03 00 00       	jmp    f0104eff <syscall+0x5d7>
{
	// Hint: This function is a wrapper around page_remove().
	// LAB 4: Your code here.

	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104bb2:	83 ec 04             	sub    $0x4,%esp
f0104bb5:	6a 01                	push   $0x1
f0104bb7:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104bba:	50                   	push   %eax
f0104bbb:	53                   	push   %ebx
f0104bbc:	e8 4d e8 ff ff       	call   f010340e <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104bc1:	83 c4 10             	add    $0x10,%esp
f0104bc4:	85 c0                	test   %eax,%eax
f0104bc6:	78 3d                	js     f0104c05 <syscall+0x2dd>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104bc8:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104bce:	77 3f                	ja     f0104c0f <syscall+0x2e7>
f0104bd0:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0104bd6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104bdc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104be1:	39 d6                	cmp    %edx,%esi
f0104be3:	0f 85 16 03 00 00    	jne    f0104eff <syscall+0x5d7>
	
	// void page_remove(pde_t *pgdir, void *va)
	page_remove(env->env_pgdir, va);
f0104be9:	83 ec 08             	sub    $0x8,%esp
f0104bec:	56                   	push   %esi
f0104bed:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104bf0:	ff 70 60             	pushl  0x60(%eax)
f0104bf3:	e8 34 cc ff ff       	call   f010182c <page_remove>
f0104bf8:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104bfb:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c00:	e9 fa 02 00 00       	jmp    f0104eff <syscall+0x5d7>
	// Hint: This function is a wrapper around page_remove().
	// LAB 4: Your code here.

	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;
f0104c05:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104c0a:	e9 f0 02 00 00       	jmp    f0104eff <syscall+0x5d7>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104c0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c14:	e9 e6 02 00 00       	jmp    f0104eff <syscall+0x5d7>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// cprintf("In kernel sys_env_set_pgfault_upcall function\n");
	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104c19:	83 ec 04             	sub    $0x4,%esp
f0104c1c:	6a 01                	push   $0x1
f0104c1e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104c21:	50                   	push   %eax
f0104c22:	53                   	push   %ebx
f0104c23:	e8 e6 e7 ff ff       	call   f010340e <envid2env>
	if (r < 0) return r;
f0104c28:	83 c4 10             	add    $0x10,%esp
f0104c2b:	85 c0                	test   %eax,%eax
f0104c2d:	0f 88 cc 02 00 00    	js     f0104eff <syscall+0x5d7>

	env->env_pgfault_upcall = func;
f0104c33:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c36:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f0104c39:	b8 00 00 00 00       	mov    $0x0,%eax
    	case SYS_page_unmap:
    		r = sys_page_unmap((envid_t)a1, (void *)a2);
    		break;
    	case SYS_env_set_pgfault_upcall:
    		r = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
    		break;
f0104c3e:	e9 bc 02 00 00       	jmp    f0104eff <syscall+0x5d7>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104c43:	e8 c3 fb ff ff       	call   f010480b <sched_yield>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, (void *)s, len, PTE_U);
f0104c48:	e8 07 15 00 00       	call   f0106154 <cpunum>
f0104c4d:	6a 04                	push   $0x4
f0104c4f:	56                   	push   %esi
f0104c50:	53                   	push   %ebx
f0104c51:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c58:	29 c2                	sub    %eax,%edx
f0104c5a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c5d:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f0104c64:	e8 d5 e6 ff ff       	call   f010333e <user_mem_assert>
    
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104c69:	83 c4 0c             	add    $0xc,%esp
f0104c6c:	53                   	push   %ebx
f0104c6d:	56                   	push   %esi
f0104c6e:	68 ff 6b 10 f0       	push   $0xf0106bff
f0104c73:	e8 e5 f0 ff ff       	call   f0103d5d <cprintf>
f0104c78:	83 c4 10             	add    $0x10,%esp
    		sys_yield();
    		return 0;
    		break;
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
f0104c7b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c80:	e9 98 02 00 00       	jmp    f0104f1d <syscall+0x5f5>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104c85:	e8 d2 b9 ff ff       	call   f010065c <cons_getc>
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
            break;
        case SYS_cgetc:
            r = sys_cgetc();
            break;
f0104c8a:	e9 70 02 00 00       	jmp    f0104eff <syscall+0x5d7>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104c8f:	e8 c0 14 00 00       	call   f0106154 <cpunum>
f0104c94:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c9b:	29 c2                	sub    %eax,%edx
f0104c9d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ca0:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0104ca7:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_cgetc:
            r = sys_cgetc();
            break;
        case SYS_getenvid:
            r = sys_getenvid();
            break;
f0104caa:	e9 50 02 00 00       	jmp    f0104eff <syscall+0x5d7>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104caf:	83 ec 04             	sub    $0x4,%esp
f0104cb2:	6a 01                	push   $0x1
f0104cb4:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104cb7:	50                   	push   %eax
f0104cb8:	53                   	push   %ebx
f0104cb9:	e8 50 e7 ff ff       	call   f010340e <envid2env>
f0104cbe:	83 c4 10             	add    $0x10,%esp
f0104cc1:	85 c0                	test   %eax,%eax
f0104cc3:	0f 88 36 02 00 00    	js     f0104eff <syscall+0x5d7>
		return r;
	if (e == curenv)
f0104cc9:	e8 86 14 00 00       	call   f0106154 <cpunum>
f0104cce:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104cd1:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0104cd8:	29 c1                	sub    %eax,%ecx
f0104cda:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0104cdd:	39 14 85 28 60 2e f0 	cmp    %edx,-0xfd19fd8(,%eax,4)
f0104ce4:	75 2d                	jne    f0104d13 <syscall+0x3eb>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104ce6:	e8 69 14 00 00       	call   f0106154 <cpunum>
f0104ceb:	83 ec 08             	sub    $0x8,%esp
f0104cee:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104cf5:	29 c2                	sub    %eax,%edx
f0104cf7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104cfa:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0104d01:	ff 70 48             	pushl  0x48(%eax)
f0104d04:	68 a6 83 10 f0       	push   $0xf01083a6
f0104d09:	e8 4f f0 ff ff       	call   f0103d5d <cprintf>
f0104d0e:	83 c4 10             	add    $0x10,%esp
f0104d11:	eb 2f                	jmp    f0104d42 <syscall+0x41a>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104d13:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104d16:	e8 39 14 00 00       	call   f0106154 <cpunum>
f0104d1b:	83 ec 04             	sub    $0x4,%esp
f0104d1e:	53                   	push   %ebx
f0104d1f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d26:	29 c2                	sub    %eax,%edx
f0104d28:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d2b:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0104d32:	ff 70 48             	pushl  0x48(%eax)
f0104d35:	68 c1 83 10 f0       	push   $0xf01083c1
f0104d3a:	e8 1e f0 ff ff       	call   f0103d5d <cprintf>
f0104d3f:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104d42:	83 ec 0c             	sub    $0xc,%esp
f0104d45:	ff 75 e0             	pushl  -0x20(%ebp)
f0104d48:	e8 ee ec ff ff       	call   f0103a3b <env_destroy>
f0104d4d:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104d50:	b8 00 00 00 00       	mov    $0x0,%eax
        case SYS_getenvid:
            r = sys_getenvid();
            break;
        case SYS_env_destroy:
            r = sys_env_destroy(a1);
            break;
f0104d55:	e9 a5 01 00 00       	jmp    f0104eff <syscall+0x5d7>
	
	// Any environment is allowed to send IPC messages to any other environment, 
	// and the kernel does no special permission checking other than verifying that the target envid is valid.
	// So set the checkperm falg to 0
	struct Env * env;
	int r = envid2env(envid, &env, 0);	
f0104d5a:	83 ec 04             	sub    $0x4,%esp
f0104d5d:	6a 00                	push   $0x0
f0104d5f:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104d62:	50                   	push   %eax
f0104d63:	53                   	push   %ebx
f0104d64:	e8 a5 e6 ff ff       	call   f010340e <envid2env>
	//	-E_BAD_ENV if environment envid doesn't currently exist.
	if (r < 0) return -E_BAD_ENV;
f0104d69:	83 c4 10             	add    $0x10,%esp
f0104d6c:	85 c0                	test   %eax,%eax
f0104d6e:	0f 88 09 01 00 00    	js     f0104e7d <syscall+0x555>

	//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
	//		or another environment managed to send first.
	if (env->env_ipc_recving == false || env->env_ipc_from != 0) {
f0104d74:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104d77:	80 7a 68 00          	cmpb   $0x0,0x68(%edx)
f0104d7b:	0f 84 06 01 00 00    	je     f0104e87 <syscall+0x55f>
		return -E_IPC_NOT_RECV;
f0104d81:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	//	-E_BAD_ENV if environment envid doesn't currently exist.
	if (r < 0) return -E_BAD_ENV;

	//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
	//		or another environment managed to send first.
	if (env->env_ipc_recving == false || env->env_ipc_from != 0) {
f0104d86:	83 7a 74 00          	cmpl   $0x0,0x74(%edx)
f0104d8a:	0f 85 8d 01 00 00    	jne    f0104f1d <syscall+0x5f5>
		return -E_IPC_NOT_RECV;
	}

	//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
	if ((uint32_t)srcva < UTOP && ROUNDUP(srcva, PGSIZE) != srcva)
f0104d90:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104d96:	77 2d                	ja     f0104dc5 <syscall+0x49d>
f0104d98:	8d 97 ff 0f 00 00    	lea    0xfff(%edi),%edx
f0104d9e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		return -E_INVAL;
f0104da4:	b0 fd                	mov    $0xfd,%al
	if (env->env_ipc_recving == false || env->env_ipc_from != 0) {
		return -E_IPC_NOT_RECV;
	}

	//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
	if ((uint32_t)srcva < UTOP && ROUNDUP(srcva, PGSIZE) != srcva)
f0104da6:	39 d7                	cmp    %edx,%edi
f0104da8:	0f 85 6f 01 00 00    	jne    f0104f1d <syscall+0x5f5>
		return -E_INVAL;

	//	-E_INVAL if srcva < UTOP and perm is inappropriate
	if ((uint32_t)srcva < UTOP && (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0))) 
f0104dae:	8b 55 18             	mov    0x18(%ebp),%edx
f0104db1:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f0104db7:	83 fa 05             	cmp    $0x5,%edx
f0104dba:	0f 85 5d 01 00 00    	jne    f0104f1d <syscall+0x5f5>
f0104dc0:	e9 60 01 00 00       	jmp    f0104f25 <syscall+0x5fd>
		return -E_INVAL;

	//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's address space 
	pte_t * pte;
	struct PageInfo * pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104dc5:	e8 8a 13 00 00       	call   f0106154 <cpunum>
f0104dca:	83 ec 04             	sub    $0x4,%esp
f0104dcd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104dd0:	52                   	push   %edx
f0104dd1:	57                   	push   %edi
f0104dd2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dd5:	8b 80 28 60 2e f0    	mov    -0xfd19fd8(%eax),%eax
f0104ddb:	ff 70 60             	pushl  0x60(%eax)
f0104dde:	e8 9a c9 ff ff       	call   f010177d <page_lookup>
f0104de3:	89 c2                	mov    %eax,%edx
f0104de5:	83 c4 10             	add    $0x10,%esp
	if ((uint32_t)srcva < UTOP && pg == NULL)
		return -E_INVAL;

	//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
	//		current environment's address space.
	if ((perm & PTE_W) && (*pte & PTE_W) == 0) 
f0104de8:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104dec:	74 11                	je     f0104dff <syscall+0x4d7>
		return -E_INVAL;
f0104dee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	if ((uint32_t)srcva < UTOP && pg == NULL)
		return -E_INVAL;

	//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
	//		current environment's address space.
	if ((perm & PTE_W) && (*pte & PTE_W) == 0) 
f0104df3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104df6:	f6 01 02             	testb  $0x2,(%ecx)
f0104df9:	0f 84 1e 01 00 00    	je     f0104f1d <syscall+0x5f5>
		return -E_INVAL;

	//	-E_NO_MEM if there's not enough memory to map srcva in envid's
	//		address space.
	if ((uint32_t)srcva < UTOP) {
f0104dff:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104e05:	77 33                	ja     f0104e3a <syscall+0x512>
		r = page_insert(env->env_pgdir, pg, ROUNDDOWN(srcva, PGSIZE), perm);
f0104e07:	ff 75 18             	pushl  0x18(%ebp)
f0104e0a:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0104e10:	57                   	push   %edi
f0104e11:	52                   	push   %edx
f0104e12:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e15:	ff 70 60             	pushl  0x60(%eax)
f0104e18:	e8 5c ca ff ff       	call   f0101879 <page_insert>
f0104e1d:	89 c2                	mov    %eax,%edx
		if (r < 0) return -E_NO_MEM;
f0104e1f:	83 c4 10             	add    $0x10,%esp
f0104e22:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104e27:	85 d2                	test   %edx,%edx
f0104e29:	0f 88 ee 00 00 00    	js     f0104f1d <syscall+0x5f5>
		env->env_ipc_perm = perm;
f0104e2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e32:	8b 55 18             	mov    0x18(%ebp),%edx
f0104e35:	89 50 78             	mov    %edx,0x78(%eax)
f0104e38:	eb 0a                	jmp    f0104e44 <syscall+0x51c>
	} else env->env_ipc_perm = 0;
f0104e3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e3d:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)

	env->env_ipc_recving = false;
f0104e44:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104e47:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// ... I mistake write env->env_ipc_from = envid in the first
	// ... Debug a lot of time...
	env->env_ipc_from = curenv->env_id;
f0104e4b:	e8 04 13 00 00       	call   f0106154 <cpunum>
f0104e50:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e53:	8b 80 28 60 2e f0    	mov    -0xfd19fd8(%eax),%eax
f0104e59:	8b 40 48             	mov    0x48(%eax),%eax
f0104e5c:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_value = value;
f0104e5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e62:	89 70 70             	mov    %esi,0x70(%eax)
	env->env_tf.tf_regs.reg_eax = 0;
f0104e65:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	env->env_status = ENV_RUNNABLE;
f0104e6c:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	return 0;
f0104e73:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e78:	e9 a0 00 00 00       	jmp    f0104f1d <syscall+0x5f5>
	// and the kernel does no special permission checking other than verifying that the target envid is valid.
	// So set the checkperm falg to 0
	struct Env * env;
	int r = envid2env(envid, &env, 0);	
	//	-E_BAD_ENV if environment envid doesn't currently exist.
	if (r < 0) return -E_BAD_ENV;
f0104e7d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104e82:	e9 96 00 00 00       	jmp    f0104f1d <syscall+0x5f5>

	//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
	//		or another environment managed to send first.
	if (env->env_ipc_recving == false || env->env_ipc_from != 0) {
		return -E_IPC_NOT_RECV;
f0104e87:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0104e8c:	e9 8c 00 00 00       	jmp    f0104f1d <syscall+0x5f5>
static int
sys_ipc_recv(void *dstva)
{
	// cprintf("I am receiving???\n");
	// LAB 4: Your code here.
	if (((uint32_t)dstva < UTOP) && ROUNDUP(dstva, PGSIZE) != dstva) return -E_INVAL;
f0104e91:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104e97:	77 0f                	ja     f0104ea8 <syscall+0x580>
f0104e99:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f0104e9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104ea4:	39 c3                	cmp    %eax,%ebx
f0104ea6:	75 70                	jne    f0104f18 <syscall+0x5f0>
	curenv->env_ipc_recving = true;			// Env is blocked receiving
f0104ea8:	e8 a7 12 00 00       	call   f0106154 <cpunum>
f0104ead:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eb0:	8b 80 28 60 2e f0    	mov    -0xfd19fd8(%eax),%eax
f0104eb6:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;			// VA at which to map received page
f0104eba:	e8 95 12 00 00       	call   f0106154 <cpunum>
f0104ebf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ec2:	8b 80 28 60 2e f0    	mov    -0xfd19fd8(%eax),%eax
f0104ec8:	89 58 6c             	mov    %ebx,0x6c(%eax)
	curenv->env_ipc_from = 0;				// set from to 0
f0104ecb:	e8 84 12 00 00       	call   f0106154 <cpunum>
f0104ed0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ed3:	8b 80 28 60 2e f0    	mov    -0xfd19fd8(%eax),%eax
f0104ed9:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;	// mark it not runnable
f0104ee0:	e8 6f 12 00 00       	call   f0106154 <cpunum>
f0104ee5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ee8:	8b 80 28 60 2e f0    	mov    -0xfd19fd8(%eax),%eax
f0104eee:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	// cprintf("I am receiving!!!\n");
	// cprintf("%d, %d\n", curenv->env_ipc_recving, curenv->env_ipc_from);
	sched_yield();							// give up the CPU
f0104ef5:	e8 11 f9 ff ff       	call   f010480b <sched_yield>
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
    
	int r = 0;
f0104efa:	b8 00 00 00 00       	mov    $0x0,%eax
        	return sys_ipc_recv((void *)a1);
        	break;
        dafult:
            return -E_INVAL;
	}
	if (r < 0) panic("syscall error %e\n", r);
f0104eff:	85 c0                	test   %eax,%eax
f0104f01:	79 1a                	jns    f0104f1d <syscall+0x5f5>
f0104f03:	50                   	push   %eax
f0104f04:	68 d9 83 10 f0       	push   $0xf01083d9
f0104f09:	68 c6 01 00 00       	push   $0x1c6
f0104f0e:	68 eb 83 10 f0       	push   $0xf01083eb
f0104f13:	e8 50 b1 ff ff       	call   f0100068 <_panic>
            break;
        case SYS_ipc_try_send:
        	return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
        	break;
        case SYS_ipc_recv:
        	return sys_ipc_recv((void *)a1);
f0104f18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
            return -E_INVAL;
	}
	if (r < 0) panic("syscall error %e\n", r);
	return r;
    panic("syscall not implemented");
}
f0104f1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f20:	5b                   	pop    %ebx
f0104f21:	5e                   	pop    %esi
f0104f22:	5f                   	pop    %edi
f0104f23:	c9                   	leave  
f0104f24:	c3                   	ret    
	if ((uint32_t)srcva < UTOP && (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0))) 
		return -E_INVAL;

	//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's address space 
	pte_t * pte;
	struct PageInfo * pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104f25:	e8 2a 12 00 00       	call   f0106154 <cpunum>
f0104f2a:	83 ec 04             	sub    $0x4,%esp
f0104f2d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104f30:	52                   	push   %edx
f0104f31:	57                   	push   %edi
f0104f32:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f35:	8b 80 28 60 2e f0    	mov    -0xfd19fd8(%eax),%eax
f0104f3b:	ff 70 60             	pushl  0x60(%eax)
f0104f3e:	e8 3a c8 ff ff       	call   f010177d <page_lookup>
f0104f43:	89 c2                	mov    %eax,%edx
	if ((uint32_t)srcva < UTOP && pg == NULL)
f0104f45:	83 c4 10             	add    $0x10,%esp
		return -E_INVAL;
f0104f48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;

	//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's address space 
	pte_t * pte;
	struct PageInfo * pg = page_lookup(curenv->env_pgdir, srcva, &pte);
	if ((uint32_t)srcva < UTOP && pg == NULL)
f0104f4d:	85 d2                	test   %edx,%edx
f0104f4f:	0f 85 93 fe ff ff    	jne    f0104de8 <syscall+0x4c0>
f0104f55:	eb c6                	jmp    f0104f1d <syscall+0x5f5>
	...

f0104f58 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104f58:	55                   	push   %ebp
f0104f59:	89 e5                	mov    %esp,%ebp
f0104f5b:	57                   	push   %edi
f0104f5c:	56                   	push   %esi
f0104f5d:	53                   	push   %ebx
f0104f5e:	83 ec 14             	sub    $0x14,%esp
f0104f61:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104f64:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0104f67:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f6a:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104f6d:	8b 1a                	mov    (%edx),%ebx
f0104f6f:	8b 01                	mov    (%ecx),%eax
f0104f71:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0104f74:	39 c3                	cmp    %eax,%ebx
f0104f76:	0f 8f 97 00 00 00    	jg     f0105013 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0104f7c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104f83:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104f86:	01 d8                	add    %ebx,%eax
f0104f88:	89 c7                	mov    %eax,%edi
f0104f8a:	c1 ef 1f             	shr    $0x1f,%edi
f0104f8d:	01 c7                	add    %eax,%edi
f0104f8f:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104f91:	39 df                	cmp    %ebx,%edi
f0104f93:	7c 31                	jl     f0104fc6 <stab_binsearch+0x6e>
f0104f95:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104f98:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104f9b:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0104fa0:	39 f0                	cmp    %esi,%eax
f0104fa2:	0f 84 b3 00 00 00    	je     f010505b <stab_binsearch+0x103>
f0104fa8:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0104fac:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104fb0:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104fb2:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104fb3:	39 d8                	cmp    %ebx,%eax
f0104fb5:	7c 0f                	jl     f0104fc6 <stab_binsearch+0x6e>
f0104fb7:	0f b6 0a             	movzbl (%edx),%ecx
f0104fba:	83 ea 0c             	sub    $0xc,%edx
f0104fbd:	39 f1                	cmp    %esi,%ecx
f0104fbf:	75 f1                	jne    f0104fb2 <stab_binsearch+0x5a>
f0104fc1:	e9 97 00 00 00       	jmp    f010505d <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104fc6:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104fc9:	eb 39                	jmp    f0105004 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104fcb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104fce:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0104fd0:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104fd3:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104fda:	eb 28                	jmp    f0105004 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104fdc:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104fdf:	76 12                	jbe    f0104ff3 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0104fe1:	48                   	dec    %eax
f0104fe2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104fe5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104fe8:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104fea:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104ff1:	eb 11                	jmp    f0105004 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104ff3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104ff6:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0104ff8:	ff 45 0c             	incl   0xc(%ebp)
f0104ffb:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104ffd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105004:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0105007:	0f 8d 76 ff ff ff    	jge    f0104f83 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010500d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105011:	75 0d                	jne    f0105020 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0105013:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105016:	8b 03                	mov    (%ebx),%eax
f0105018:	48                   	dec    %eax
f0105019:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010501c:	89 02                	mov    %eax,(%edx)
f010501e:	eb 55                	jmp    f0105075 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105020:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105023:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105025:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105028:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010502a:	39 c1                	cmp    %eax,%ecx
f010502c:	7d 26                	jge    f0105054 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f010502e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105031:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0105034:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0105039:	39 f2                	cmp    %esi,%edx
f010503b:	74 17                	je     f0105054 <stab_binsearch+0xfc>
f010503d:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105041:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105045:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105046:	39 c1                	cmp    %eax,%ecx
f0105048:	7d 0a                	jge    f0105054 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f010504a:	0f b6 1a             	movzbl (%edx),%ebx
f010504d:	83 ea 0c             	sub    $0xc,%edx
f0105050:	39 f3                	cmp    %esi,%ebx
f0105052:	75 f1                	jne    f0105045 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105054:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105057:	89 02                	mov    %eax,(%edx)
f0105059:	eb 1a                	jmp    f0105075 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010505b:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010505d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105060:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0105063:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105067:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010506a:	0f 82 5b ff ff ff    	jb     f0104fcb <stab_binsearch+0x73>
f0105070:	e9 67 ff ff ff       	jmp    f0104fdc <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0105075:	83 c4 14             	add    $0x14,%esp
f0105078:	5b                   	pop    %ebx
f0105079:	5e                   	pop    %esi
f010507a:	5f                   	pop    %edi
f010507b:	c9                   	leave  
f010507c:	c3                   	ret    

f010507d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010507d:	55                   	push   %ebp
f010507e:	89 e5                	mov    %esp,%ebp
f0105080:	57                   	push   %edi
f0105081:	56                   	push   %esi
f0105082:	53                   	push   %ebx
f0105083:	83 ec 2c             	sub    $0x2c,%esp
f0105086:	8b 75 08             	mov    0x8(%ebp),%esi
f0105089:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010508c:	c7 03 30 84 10 f0    	movl   $0xf0108430,(%ebx)
	info->eip_line = 0;
f0105092:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105099:	c7 43 08 30 84 10 f0 	movl   $0xf0108430,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01050a0:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01050a7:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01050aa:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01050b1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01050b7:	0f 87 ba 00 00 00    	ja     f0105177 <debuginfo_eip+0xfa>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
f01050bd:	e8 92 10 00 00       	call   f0106154 <cpunum>
f01050c2:	6a 04                	push   $0x4
f01050c4:	6a 10                	push   $0x10
f01050c6:	68 00 00 20 00       	push   $0x200000
f01050cb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01050d2:	29 c2                	sub    %eax,%edx
f01050d4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01050d7:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f01050de:	e8 a8 e1 ff ff       	call   f010328b <user_mem_check>
f01050e3:	83 c4 10             	add    $0x10,%esp
f01050e6:	85 c0                	test   %eax,%eax
f01050e8:	0f 88 11 02 00 00    	js     f01052ff <debuginfo_eip+0x282>
			return -1;
		}

		stabs = usd->stabs;
f01050ee:	a1 00 00 20 00       	mov    0x200000,%eax
f01050f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f01050f6:	8b 0d 04 00 20 00    	mov    0x200004,%ecx
f01050fc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr = usd->stabstr;
f01050ff:	a1 08 00 20 00       	mov    0x200008,%eax
f0105104:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f0105107:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
f010510d:	e8 42 10 00 00       	call   f0106154 <cpunum>
f0105112:	89 c2                	mov    %eax,%edx
f0105114:	6a 04                	push   $0x4
f0105116:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105119:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010511c:	50                   	push   %eax
f010511d:	ff 75 d0             	pushl  -0x30(%ebp)
f0105120:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0105127:	29 d0                	sub    %edx,%eax
f0105129:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010512c:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f0105133:	e8 53 e1 ff ff       	call   f010328b <user_mem_check>
f0105138:	83 c4 10             	add    $0x10,%esp
f010513b:	85 c0                	test   %eax,%eax
f010513d:	0f 88 c3 01 00 00    	js     f0105306 <debuginfo_eip+0x289>
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0105143:	e8 0c 10 00 00       	call   f0106154 <cpunum>
f0105148:	89 c2                	mov    %eax,%edx
f010514a:	6a 04                	push   $0x4
f010514c:	89 f8                	mov    %edi,%eax
f010514e:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0105151:	50                   	push   %eax
f0105152:	ff 75 d4             	pushl  -0x2c(%ebp)
f0105155:	6b c2 74             	imul   $0x74,%edx,%eax
f0105158:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f010515e:	e8 28 e1 ff ff       	call   f010328b <user_mem_check>
f0105163:	89 c2                	mov    %eax,%edx
f0105165:	83 c4 10             	add    $0x10,%esp
			return -1;
f0105168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f010516d:	85 d2                	test   %edx,%edx
f010516f:	0f 88 ab 01 00 00    	js     f0105320 <debuginfo_eip+0x2a3>
f0105175:	eb 1a                	jmp    f0105191 <debuginfo_eip+0x114>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105177:	bf cf db 11 f0       	mov    $0xf011dbcf,%edi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010517c:	c7 45 d4 d9 48 11 f0 	movl   $0xf01148d9,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105183:	c7 45 cc d8 48 11 f0 	movl   $0xf01148d8,-0x34(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010518a:	c7 45 d0 14 89 10 f0 	movl   $0xf0108914,-0x30(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105191:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0105194:	0f 83 73 01 00 00    	jae    f010530d <debuginfo_eip+0x290>
f010519a:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f010519e:	0f 85 70 01 00 00    	jne    f0105314 <debuginfo_eip+0x297>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01051a4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01051ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01051ae:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01051b1:	c1 f8 02             	sar    $0x2,%eax
f01051b4:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01051ba:	48                   	dec    %eax
f01051bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01051be:	83 ec 08             	sub    $0x8,%esp
f01051c1:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01051c4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01051c7:	56                   	push   %esi
f01051c8:	6a 64                	push   $0x64
f01051ca:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01051cd:	e8 86 fd ff ff       	call   f0104f58 <stab_binsearch>
	if (lfile == 0)
f01051d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01051d5:	83 c4 10             	add    $0x10,%esp
		return -1;
f01051d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01051dd:	85 d2                	test   %edx,%edx
f01051df:	0f 84 3b 01 00 00    	je     f0105320 <debuginfo_eip+0x2a3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01051e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01051e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01051ee:	83 ec 08             	sub    $0x8,%esp
f01051f1:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01051f4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01051f7:	56                   	push   %esi
f01051f8:	6a 24                	push   $0x24
f01051fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01051fd:	e8 56 fd ff ff       	call   f0104f58 <stab_binsearch>

	if (lfun <= rfun) {
f0105202:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105205:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105208:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010520b:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010520e:	83 c4 10             	add    $0x10,%esp
f0105211:	39 c1                	cmp    %eax,%ecx
f0105213:	7f 21                	jg     f0105236 <debuginfo_eip+0x1b9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105215:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0105218:	03 45 d0             	add    -0x30(%ebp),%eax
f010521b:	8b 10                	mov    (%eax),%edx
f010521d:	89 f9                	mov    %edi,%ecx
f010521f:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f0105222:	39 ca                	cmp    %ecx,%edx
f0105224:	73 06                	jae    f010522c <debuginfo_eip+0x1af>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105226:	03 55 d4             	add    -0x2c(%ebp),%edx
f0105229:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010522c:	8b 40 08             	mov    0x8(%eax),%eax
f010522f:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105232:	29 c6                	sub    %eax,%esi
f0105234:	eb 0f                	jmp    f0105245 <debuginfo_eip+0x1c8>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105236:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105239:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010523c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		rline = rfile;
f010523f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105242:	89 45 c8             	mov    %eax,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105245:	83 ec 08             	sub    $0x8,%esp
f0105248:	6a 3a                	push   $0x3a
f010524a:	ff 73 08             	pushl  0x8(%ebx)
f010524d:	e8 b1 08 00 00       	call   f0105b03 <strfind>
f0105252:	2b 43 08             	sub    0x8(%ebx),%eax
f0105255:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0105258:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010525b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    rfun = rline;
f010525e:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105261:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0105264:	83 c4 08             	add    $0x8,%esp
f0105267:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010526a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010526d:	56                   	push   %esi
f010526e:	6a 44                	push   $0x44
f0105270:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105273:	e8 e0 fc ff ff       	call   f0104f58 <stab_binsearch>
    if (lfun <= rfun) {
f0105278:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010527b:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f010527e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0105283:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0105286:	0f 8f 94 00 00 00    	jg     f0105320 <debuginfo_eip+0x2a3>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f010528c:	6b ca 0c             	imul   $0xc,%edx,%ecx
f010528f:	03 4d d0             	add    -0x30(%ebp),%ecx
f0105292:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f0105296:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105299:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010529c:	89 75 cc             	mov    %esi,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010529f:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01052a2:	eb 04                	jmp    f01052a8 <debuginfo_eip+0x22b>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01052a4:	4a                   	dec    %edx
f01052a5:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01052a8:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f01052ab:	7c 19                	jl     f01052c6 <debuginfo_eip+0x249>
	       && stabs[lline].n_type != N_SOL
f01052ad:	8a 48 fc             	mov    -0x4(%eax),%cl
f01052b0:	80 f9 84             	cmp    $0x84,%cl
f01052b3:	74 73                	je     f0105328 <debuginfo_eip+0x2ab>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01052b5:	80 f9 64             	cmp    $0x64,%cl
f01052b8:	75 ea                	jne    f01052a4 <debuginfo_eip+0x227>
f01052ba:	83 38 00             	cmpl   $0x0,(%eax)
f01052bd:	74 e5                	je     f01052a4 <debuginfo_eip+0x227>
f01052bf:	eb 67                	jmp    f0105328 <debuginfo_eip+0x2ab>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01052c1:	03 45 d4             	add    -0x2c(%ebp),%eax
f01052c4:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01052c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01052c9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01052cc:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01052d1:	39 ca                	cmp    %ecx,%edx
f01052d3:	7d 4b                	jge    f0105320 <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
f01052d5:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01052d8:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01052db:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01052de:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f01052e2:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01052e4:	eb 04                	jmp    f01052ea <debuginfo_eip+0x26d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01052e6:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01052e9:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01052ea:	39 f0                	cmp    %esi,%eax
f01052ec:	7d 2d                	jge    f010531b <debuginfo_eip+0x29e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01052ee:	8a 0a                	mov    (%edx),%cl
f01052f0:	83 c2 0c             	add    $0xc,%edx
f01052f3:	80 f9 a0             	cmp    $0xa0,%cl
f01052f6:	74 ee                	je     f01052e6 <debuginfo_eip+0x269>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01052f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01052fd:	eb 21                	jmp    f0105320 <debuginfo_eip+0x2a3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
f01052ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105304:	eb 1a                	jmp    f0105320 <debuginfo_eip+0x2a3>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
f0105306:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010530b:	eb 13                	jmp    f0105320 <debuginfo_eip+0x2a3>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010530d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105312:	eb 0c                	jmp    f0105320 <debuginfo_eip+0x2a3>
f0105314:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105319:	eb 05                	jmp    f0105320 <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010531b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105320:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105323:	5b                   	pop    %ebx
f0105324:	5e                   	pop    %esi
f0105325:	5f                   	pop    %edi
f0105326:	c9                   	leave  
f0105327:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105328:	6b d2 0c             	imul   $0xc,%edx,%edx
f010532b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010532e:	8b 04 16             	mov    (%esi,%edx,1),%eax
f0105331:	2b 7d d4             	sub    -0x2c(%ebp),%edi
f0105334:	39 f8                	cmp    %edi,%eax
f0105336:	72 89                	jb     f01052c1 <debuginfo_eip+0x244>
f0105338:	eb 8c                	jmp    f01052c6 <debuginfo_eip+0x249>
	...

f010533c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010533c:	55                   	push   %ebp
f010533d:	89 e5                	mov    %esp,%ebp
f010533f:	57                   	push   %edi
f0105340:	56                   	push   %esi
f0105341:	53                   	push   %ebx
f0105342:	83 ec 2c             	sub    $0x2c,%esp
f0105345:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105348:	89 d6                	mov    %edx,%esi
f010534a:	8b 45 08             	mov    0x8(%ebp),%eax
f010534d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105350:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105353:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105356:	8b 45 10             	mov    0x10(%ebp),%eax
f0105359:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010535c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010535f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105362:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0105369:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f010536c:	72 0c                	jb     f010537a <printnum+0x3e>
f010536e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105371:	76 07                	jbe    f010537a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105373:	4b                   	dec    %ebx
f0105374:	85 db                	test   %ebx,%ebx
f0105376:	7f 31                	jg     f01053a9 <printnum+0x6d>
f0105378:	eb 3f                	jmp    f01053b9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010537a:	83 ec 0c             	sub    $0xc,%esp
f010537d:	57                   	push   %edi
f010537e:	4b                   	dec    %ebx
f010537f:	53                   	push   %ebx
f0105380:	50                   	push   %eax
f0105381:	83 ec 08             	sub    $0x8,%esp
f0105384:	ff 75 d4             	pushl  -0x2c(%ebp)
f0105387:	ff 75 d0             	pushl  -0x30(%ebp)
f010538a:	ff 75 dc             	pushl  -0x24(%ebp)
f010538d:	ff 75 d8             	pushl  -0x28(%ebp)
f0105390:	e8 2b 12 00 00       	call   f01065c0 <__udivdi3>
f0105395:	83 c4 18             	add    $0x18,%esp
f0105398:	52                   	push   %edx
f0105399:	50                   	push   %eax
f010539a:	89 f2                	mov    %esi,%edx
f010539c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010539f:	e8 98 ff ff ff       	call   f010533c <printnum>
f01053a4:	83 c4 20             	add    $0x20,%esp
f01053a7:	eb 10                	jmp    f01053b9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01053a9:	83 ec 08             	sub    $0x8,%esp
f01053ac:	56                   	push   %esi
f01053ad:	57                   	push   %edi
f01053ae:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01053b1:	4b                   	dec    %ebx
f01053b2:	83 c4 10             	add    $0x10,%esp
f01053b5:	85 db                	test   %ebx,%ebx
f01053b7:	7f f0                	jg     f01053a9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01053b9:	83 ec 08             	sub    $0x8,%esp
f01053bc:	56                   	push   %esi
f01053bd:	83 ec 04             	sub    $0x4,%esp
f01053c0:	ff 75 d4             	pushl  -0x2c(%ebp)
f01053c3:	ff 75 d0             	pushl  -0x30(%ebp)
f01053c6:	ff 75 dc             	pushl  -0x24(%ebp)
f01053c9:	ff 75 d8             	pushl  -0x28(%ebp)
f01053cc:	e8 0b 13 00 00       	call   f01066dc <__umoddi3>
f01053d1:	83 c4 14             	add    $0x14,%esp
f01053d4:	0f be 80 3a 84 10 f0 	movsbl -0xfef7bc6(%eax),%eax
f01053db:	50                   	push   %eax
f01053dc:	ff 55 e4             	call   *-0x1c(%ebp)
f01053df:	83 c4 10             	add    $0x10,%esp
}
f01053e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053e5:	5b                   	pop    %ebx
f01053e6:	5e                   	pop    %esi
f01053e7:	5f                   	pop    %edi
f01053e8:	c9                   	leave  
f01053e9:	c3                   	ret    

f01053ea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01053ea:	55                   	push   %ebp
f01053eb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01053ed:	83 fa 01             	cmp    $0x1,%edx
f01053f0:	7e 0e                	jle    f0105400 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01053f2:	8b 10                	mov    (%eax),%edx
f01053f4:	8d 4a 08             	lea    0x8(%edx),%ecx
f01053f7:	89 08                	mov    %ecx,(%eax)
f01053f9:	8b 02                	mov    (%edx),%eax
f01053fb:	8b 52 04             	mov    0x4(%edx),%edx
f01053fe:	eb 22                	jmp    f0105422 <getuint+0x38>
	else if (lflag)
f0105400:	85 d2                	test   %edx,%edx
f0105402:	74 10                	je     f0105414 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105404:	8b 10                	mov    (%eax),%edx
f0105406:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105409:	89 08                	mov    %ecx,(%eax)
f010540b:	8b 02                	mov    (%edx),%eax
f010540d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105412:	eb 0e                	jmp    f0105422 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105414:	8b 10                	mov    (%eax),%edx
f0105416:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105419:	89 08                	mov    %ecx,(%eax)
f010541b:	8b 02                	mov    (%edx),%eax
f010541d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105422:	c9                   	leave  
f0105423:	c3                   	ret    

f0105424 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0105424:	55                   	push   %ebp
f0105425:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105427:	83 fa 01             	cmp    $0x1,%edx
f010542a:	7e 0e                	jle    f010543a <getint+0x16>
		return va_arg(*ap, long long);
f010542c:	8b 10                	mov    (%eax),%edx
f010542e:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105431:	89 08                	mov    %ecx,(%eax)
f0105433:	8b 02                	mov    (%edx),%eax
f0105435:	8b 52 04             	mov    0x4(%edx),%edx
f0105438:	eb 1a                	jmp    f0105454 <getint+0x30>
	else if (lflag)
f010543a:	85 d2                	test   %edx,%edx
f010543c:	74 0c                	je     f010544a <getint+0x26>
		return va_arg(*ap, long);
f010543e:	8b 10                	mov    (%eax),%edx
f0105440:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105443:	89 08                	mov    %ecx,(%eax)
f0105445:	8b 02                	mov    (%edx),%eax
f0105447:	99                   	cltd   
f0105448:	eb 0a                	jmp    f0105454 <getint+0x30>
	else
		return va_arg(*ap, int);
f010544a:	8b 10                	mov    (%eax),%edx
f010544c:	8d 4a 04             	lea    0x4(%edx),%ecx
f010544f:	89 08                	mov    %ecx,(%eax)
f0105451:	8b 02                	mov    (%edx),%eax
f0105453:	99                   	cltd   
}
f0105454:	c9                   	leave  
f0105455:	c3                   	ret    

f0105456 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105456:	55                   	push   %ebp
f0105457:	89 e5                	mov    %esp,%ebp
f0105459:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010545c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f010545f:	8b 10                	mov    (%eax),%edx
f0105461:	3b 50 04             	cmp    0x4(%eax),%edx
f0105464:	73 08                	jae    f010546e <sprintputch+0x18>
		*b->buf++ = ch;
f0105466:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105469:	88 0a                	mov    %cl,(%edx)
f010546b:	42                   	inc    %edx
f010546c:	89 10                	mov    %edx,(%eax)
}
f010546e:	c9                   	leave  
f010546f:	c3                   	ret    

f0105470 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105470:	55                   	push   %ebp
f0105471:	89 e5                	mov    %esp,%ebp
f0105473:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0105476:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105479:	50                   	push   %eax
f010547a:	ff 75 10             	pushl  0x10(%ebp)
f010547d:	ff 75 0c             	pushl  0xc(%ebp)
f0105480:	ff 75 08             	pushl  0x8(%ebp)
f0105483:	e8 05 00 00 00       	call   f010548d <vprintfmt>
	va_end(ap);
f0105488:	83 c4 10             	add    $0x10,%esp
}
f010548b:	c9                   	leave  
f010548c:	c3                   	ret    

f010548d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010548d:	55                   	push   %ebp
f010548e:	89 e5                	mov    %esp,%ebp
f0105490:	57                   	push   %edi
f0105491:	56                   	push   %esi
f0105492:	53                   	push   %ebx
f0105493:	83 ec 2c             	sub    $0x2c,%esp
f0105496:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105499:	8b 75 10             	mov    0x10(%ebp),%esi
f010549c:	eb 13                	jmp    f01054b1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010549e:	85 c0                	test   %eax,%eax
f01054a0:	0f 84 6d 03 00 00    	je     f0105813 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f01054a6:	83 ec 08             	sub    $0x8,%esp
f01054a9:	57                   	push   %edi
f01054aa:	50                   	push   %eax
f01054ab:	ff 55 08             	call   *0x8(%ebp)
f01054ae:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01054b1:	0f b6 06             	movzbl (%esi),%eax
f01054b4:	46                   	inc    %esi
f01054b5:	83 f8 25             	cmp    $0x25,%eax
f01054b8:	75 e4                	jne    f010549e <vprintfmt+0x11>
f01054ba:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f01054be:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01054c5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f01054cc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01054d3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01054d8:	eb 28                	jmp    f0105502 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054da:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01054dc:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f01054e0:	eb 20                	jmp    f0105502 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054e2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01054e4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f01054e8:	eb 18                	jmp    f0105502 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054ea:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01054ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01054f3:	eb 0d                	jmp    f0105502 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01054f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01054f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01054fb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105502:	8a 06                	mov    (%esi),%al
f0105504:	0f b6 d0             	movzbl %al,%edx
f0105507:	8d 5e 01             	lea    0x1(%esi),%ebx
f010550a:	83 e8 23             	sub    $0x23,%eax
f010550d:	3c 55                	cmp    $0x55,%al
f010550f:	0f 87 e0 02 00 00    	ja     f01057f5 <vprintfmt+0x368>
f0105515:	0f b6 c0             	movzbl %al,%eax
f0105518:	ff 24 85 00 85 10 f0 	jmp    *-0xfef7b00(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010551f:	83 ea 30             	sub    $0x30,%edx
f0105522:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0105525:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0105528:	8d 50 d0             	lea    -0x30(%eax),%edx
f010552b:	83 fa 09             	cmp    $0x9,%edx
f010552e:	77 44                	ja     f0105574 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105530:	89 de                	mov    %ebx,%esi
f0105532:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105535:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0105536:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105539:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f010553d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105540:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0105543:	83 fb 09             	cmp    $0x9,%ebx
f0105546:	76 ed                	jbe    f0105535 <vprintfmt+0xa8>
f0105548:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010554b:	eb 29                	jmp    f0105576 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010554d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105550:	8d 50 04             	lea    0x4(%eax),%edx
f0105553:	89 55 14             	mov    %edx,0x14(%ebp)
f0105556:	8b 00                	mov    (%eax),%eax
f0105558:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010555b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010555d:	eb 17                	jmp    f0105576 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f010555f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105563:	78 85                	js     f01054ea <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105565:	89 de                	mov    %ebx,%esi
f0105567:	eb 99                	jmp    f0105502 <vprintfmt+0x75>
f0105569:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010556b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0105572:	eb 8e                	jmp    f0105502 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105574:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0105576:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010557a:	79 86                	jns    f0105502 <vprintfmt+0x75>
f010557c:	e9 74 ff ff ff       	jmp    f01054f5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105581:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105582:	89 de                	mov    %ebx,%esi
f0105584:	e9 79 ff ff ff       	jmp    f0105502 <vprintfmt+0x75>
f0105589:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010558c:	8b 45 14             	mov    0x14(%ebp),%eax
f010558f:	8d 50 04             	lea    0x4(%eax),%edx
f0105592:	89 55 14             	mov    %edx,0x14(%ebp)
f0105595:	83 ec 08             	sub    $0x8,%esp
f0105598:	57                   	push   %edi
f0105599:	ff 30                	pushl  (%eax)
f010559b:	ff 55 08             	call   *0x8(%ebp)
			break;
f010559e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055a1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01055a4:	e9 08 ff ff ff       	jmp    f01054b1 <vprintfmt+0x24>
f01055a9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01055ac:	8b 45 14             	mov    0x14(%ebp),%eax
f01055af:	8d 50 04             	lea    0x4(%eax),%edx
f01055b2:	89 55 14             	mov    %edx,0x14(%ebp)
f01055b5:	8b 00                	mov    (%eax),%eax
f01055b7:	85 c0                	test   %eax,%eax
f01055b9:	79 02                	jns    f01055bd <vprintfmt+0x130>
f01055bb:	f7 d8                	neg    %eax
f01055bd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01055bf:	83 f8 08             	cmp    $0x8,%eax
f01055c2:	7f 0b                	jg     f01055cf <vprintfmt+0x142>
f01055c4:	8b 04 85 60 86 10 f0 	mov    -0xfef79a0(,%eax,4),%eax
f01055cb:	85 c0                	test   %eax,%eax
f01055cd:	75 1a                	jne    f01055e9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f01055cf:	52                   	push   %edx
f01055d0:	68 52 84 10 f0       	push   $0xf0108452
f01055d5:	57                   	push   %edi
f01055d6:	ff 75 08             	pushl  0x8(%ebp)
f01055d9:	e8 92 fe ff ff       	call   f0105470 <printfmt>
f01055de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055e1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01055e4:	e9 c8 fe ff ff       	jmp    f01054b1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f01055e9:	50                   	push   %eax
f01055ea:	68 09 7c 10 f0       	push   $0xf0107c09
f01055ef:	57                   	push   %edi
f01055f0:	ff 75 08             	pushl  0x8(%ebp)
f01055f3:	e8 78 fe ff ff       	call   f0105470 <printfmt>
f01055f8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055fb:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01055fe:	e9 ae fe ff ff       	jmp    f01054b1 <vprintfmt+0x24>
f0105603:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0105606:	89 de                	mov    %ebx,%esi
f0105608:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010560b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010560e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105611:	8d 50 04             	lea    0x4(%eax),%edx
f0105614:	89 55 14             	mov    %edx,0x14(%ebp)
f0105617:	8b 00                	mov    (%eax),%eax
f0105619:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010561c:	85 c0                	test   %eax,%eax
f010561e:	75 07                	jne    f0105627 <vprintfmt+0x19a>
				p = "(null)";
f0105620:	c7 45 d0 4b 84 10 f0 	movl   $0xf010844b,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0105627:	85 db                	test   %ebx,%ebx
f0105629:	7e 42                	jle    f010566d <vprintfmt+0x1e0>
f010562b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f010562f:	74 3c                	je     f010566d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105631:	83 ec 08             	sub    $0x8,%esp
f0105634:	51                   	push   %ecx
f0105635:	ff 75 d0             	pushl  -0x30(%ebp)
f0105638:	e8 3f 03 00 00       	call   f010597c <strnlen>
f010563d:	29 c3                	sub    %eax,%ebx
f010563f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105642:	83 c4 10             	add    $0x10,%esp
f0105645:	85 db                	test   %ebx,%ebx
f0105647:	7e 24                	jle    f010566d <vprintfmt+0x1e0>
					putch(padc, putdat);
f0105649:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f010564d:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0105650:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105653:	83 ec 08             	sub    $0x8,%esp
f0105656:	57                   	push   %edi
f0105657:	53                   	push   %ebx
f0105658:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010565b:	4e                   	dec    %esi
f010565c:	83 c4 10             	add    $0x10,%esp
f010565f:	85 f6                	test   %esi,%esi
f0105661:	7f f0                	jg     f0105653 <vprintfmt+0x1c6>
f0105663:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0105666:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010566d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105670:	0f be 02             	movsbl (%edx),%eax
f0105673:	85 c0                	test   %eax,%eax
f0105675:	75 47                	jne    f01056be <vprintfmt+0x231>
f0105677:	eb 37                	jmp    f01056b0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f0105679:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010567d:	74 16                	je     f0105695 <vprintfmt+0x208>
f010567f:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105682:	83 fa 5e             	cmp    $0x5e,%edx
f0105685:	76 0e                	jbe    f0105695 <vprintfmt+0x208>
					putch('?', putdat);
f0105687:	83 ec 08             	sub    $0x8,%esp
f010568a:	57                   	push   %edi
f010568b:	6a 3f                	push   $0x3f
f010568d:	ff 55 08             	call   *0x8(%ebp)
f0105690:	83 c4 10             	add    $0x10,%esp
f0105693:	eb 0b                	jmp    f01056a0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f0105695:	83 ec 08             	sub    $0x8,%esp
f0105698:	57                   	push   %edi
f0105699:	50                   	push   %eax
f010569a:	ff 55 08             	call   *0x8(%ebp)
f010569d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01056a0:	ff 4d e4             	decl   -0x1c(%ebp)
f01056a3:	0f be 03             	movsbl (%ebx),%eax
f01056a6:	85 c0                	test   %eax,%eax
f01056a8:	74 03                	je     f01056ad <vprintfmt+0x220>
f01056aa:	43                   	inc    %ebx
f01056ab:	eb 1b                	jmp    f01056c8 <vprintfmt+0x23b>
f01056ad:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01056b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01056b4:	7f 1e                	jg     f01056d4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056b6:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01056b9:	e9 f3 fd ff ff       	jmp    f01054b1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01056be:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01056c1:	43                   	inc    %ebx
f01056c2:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01056c5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01056c8:	85 f6                	test   %esi,%esi
f01056ca:	78 ad                	js     f0105679 <vprintfmt+0x1ec>
f01056cc:	4e                   	dec    %esi
f01056cd:	79 aa                	jns    f0105679 <vprintfmt+0x1ec>
f01056cf:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01056d2:	eb dc                	jmp    f01056b0 <vprintfmt+0x223>
f01056d4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01056d7:	83 ec 08             	sub    $0x8,%esp
f01056da:	57                   	push   %edi
f01056db:	6a 20                	push   $0x20
f01056dd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01056e0:	4b                   	dec    %ebx
f01056e1:	83 c4 10             	add    $0x10,%esp
f01056e4:	85 db                	test   %ebx,%ebx
f01056e6:	7f ef                	jg     f01056d7 <vprintfmt+0x24a>
f01056e8:	e9 c4 fd ff ff       	jmp    f01054b1 <vprintfmt+0x24>
f01056ed:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01056f0:	89 ca                	mov    %ecx,%edx
f01056f2:	8d 45 14             	lea    0x14(%ebp),%eax
f01056f5:	e8 2a fd ff ff       	call   f0105424 <getint>
f01056fa:	89 c3                	mov    %eax,%ebx
f01056fc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f01056fe:	85 d2                	test   %edx,%edx
f0105700:	78 0a                	js     f010570c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105702:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105707:	e9 b0 00 00 00       	jmp    f01057bc <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f010570c:	83 ec 08             	sub    $0x8,%esp
f010570f:	57                   	push   %edi
f0105710:	6a 2d                	push   $0x2d
f0105712:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105715:	f7 db                	neg    %ebx
f0105717:	83 d6 00             	adc    $0x0,%esi
f010571a:	f7 de                	neg    %esi
f010571c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010571f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105724:	e9 93 00 00 00       	jmp    f01057bc <vprintfmt+0x32f>
f0105729:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010572c:	89 ca                	mov    %ecx,%edx
f010572e:	8d 45 14             	lea    0x14(%ebp),%eax
f0105731:	e8 b4 fc ff ff       	call   f01053ea <getuint>
f0105736:	89 c3                	mov    %eax,%ebx
f0105738:	89 d6                	mov    %edx,%esi
			base = 10;
f010573a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010573f:	eb 7b                	jmp    f01057bc <vprintfmt+0x32f>
f0105741:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0105744:	89 ca                	mov    %ecx,%edx
f0105746:	8d 45 14             	lea    0x14(%ebp),%eax
f0105749:	e8 d6 fc ff ff       	call   f0105424 <getint>
f010574e:	89 c3                	mov    %eax,%ebx
f0105750:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f0105752:	85 d2                	test   %edx,%edx
f0105754:	78 07                	js     f010575d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f0105756:	b8 08 00 00 00       	mov    $0x8,%eax
f010575b:	eb 5f                	jmp    f01057bc <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f010575d:	83 ec 08             	sub    $0x8,%esp
f0105760:	57                   	push   %edi
f0105761:	6a 2d                	push   $0x2d
f0105763:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f0105766:	f7 db                	neg    %ebx
f0105768:	83 d6 00             	adc    $0x0,%esi
f010576b:	f7 de                	neg    %esi
f010576d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f0105770:	b8 08 00 00 00       	mov    $0x8,%eax
f0105775:	eb 45                	jmp    f01057bc <vprintfmt+0x32f>
f0105777:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f010577a:	83 ec 08             	sub    $0x8,%esp
f010577d:	57                   	push   %edi
f010577e:	6a 30                	push   $0x30
f0105780:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105783:	83 c4 08             	add    $0x8,%esp
f0105786:	57                   	push   %edi
f0105787:	6a 78                	push   $0x78
f0105789:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010578c:	8b 45 14             	mov    0x14(%ebp),%eax
f010578f:	8d 50 04             	lea    0x4(%eax),%edx
f0105792:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105795:	8b 18                	mov    (%eax),%ebx
f0105797:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010579c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010579f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01057a4:	eb 16                	jmp    f01057bc <vprintfmt+0x32f>
f01057a6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01057a9:	89 ca                	mov    %ecx,%edx
f01057ab:	8d 45 14             	lea    0x14(%ebp),%eax
f01057ae:	e8 37 fc ff ff       	call   f01053ea <getuint>
f01057b3:	89 c3                	mov    %eax,%ebx
f01057b5:	89 d6                	mov    %edx,%esi
			base = 16;
f01057b7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01057bc:	83 ec 0c             	sub    $0xc,%esp
f01057bf:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f01057c3:	52                   	push   %edx
f01057c4:	ff 75 e4             	pushl  -0x1c(%ebp)
f01057c7:	50                   	push   %eax
f01057c8:	56                   	push   %esi
f01057c9:	53                   	push   %ebx
f01057ca:	89 fa                	mov    %edi,%edx
f01057cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01057cf:	e8 68 fb ff ff       	call   f010533c <printnum>
			break;
f01057d4:	83 c4 20             	add    $0x20,%esp
f01057d7:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01057da:	e9 d2 fc ff ff       	jmp    f01054b1 <vprintfmt+0x24>
f01057df:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01057e2:	83 ec 08             	sub    $0x8,%esp
f01057e5:	57                   	push   %edi
f01057e6:	52                   	push   %edx
f01057e7:	ff 55 08             	call   *0x8(%ebp)
			break;
f01057ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057ed:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01057f0:	e9 bc fc ff ff       	jmp    f01054b1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01057f5:	83 ec 08             	sub    $0x8,%esp
f01057f8:	57                   	push   %edi
f01057f9:	6a 25                	push   $0x25
f01057fb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01057fe:	83 c4 10             	add    $0x10,%esp
f0105801:	eb 02                	jmp    f0105805 <vprintfmt+0x378>
f0105803:	89 c6                	mov    %eax,%esi
f0105805:	8d 46 ff             	lea    -0x1(%esi),%eax
f0105808:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010580c:	75 f5                	jne    f0105803 <vprintfmt+0x376>
f010580e:	e9 9e fc ff ff       	jmp    f01054b1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0105813:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105816:	5b                   	pop    %ebx
f0105817:	5e                   	pop    %esi
f0105818:	5f                   	pop    %edi
f0105819:	c9                   	leave  
f010581a:	c3                   	ret    

f010581b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010581b:	55                   	push   %ebp
f010581c:	89 e5                	mov    %esp,%ebp
f010581e:	83 ec 18             	sub    $0x18,%esp
f0105821:	8b 45 08             	mov    0x8(%ebp),%eax
f0105824:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105827:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010582a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010582e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105831:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105838:	85 c0                	test   %eax,%eax
f010583a:	74 26                	je     f0105862 <vsnprintf+0x47>
f010583c:	85 d2                	test   %edx,%edx
f010583e:	7e 29                	jle    f0105869 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105840:	ff 75 14             	pushl  0x14(%ebp)
f0105843:	ff 75 10             	pushl  0x10(%ebp)
f0105846:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105849:	50                   	push   %eax
f010584a:	68 56 54 10 f0       	push   $0xf0105456
f010584f:	e8 39 fc ff ff       	call   f010548d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105854:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105857:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010585a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010585d:	83 c4 10             	add    $0x10,%esp
f0105860:	eb 0c                	jmp    f010586e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105862:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105867:	eb 05                	jmp    f010586e <vsnprintf+0x53>
f0105869:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010586e:	c9                   	leave  
f010586f:	c3                   	ret    

f0105870 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105870:	55                   	push   %ebp
f0105871:	89 e5                	mov    %esp,%ebp
f0105873:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105876:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105879:	50                   	push   %eax
f010587a:	ff 75 10             	pushl  0x10(%ebp)
f010587d:	ff 75 0c             	pushl  0xc(%ebp)
f0105880:	ff 75 08             	pushl  0x8(%ebp)
f0105883:	e8 93 ff ff ff       	call   f010581b <vsnprintf>
	va_end(ap);

	return rc;
}
f0105888:	c9                   	leave  
f0105889:	c3                   	ret    
	...

f010588c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010588c:	55                   	push   %ebp
f010588d:	89 e5                	mov    %esp,%ebp
f010588f:	57                   	push   %edi
f0105890:	56                   	push   %esi
f0105891:	53                   	push   %ebx
f0105892:	83 ec 0c             	sub    $0xc,%esp
f0105895:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105898:	85 c0                	test   %eax,%eax
f010589a:	74 11                	je     f01058ad <readline+0x21>
		cprintf("%s", prompt);
f010589c:	83 ec 08             	sub    $0x8,%esp
f010589f:	50                   	push   %eax
f01058a0:	68 09 7c 10 f0       	push   $0xf0107c09
f01058a5:	e8 b3 e4 ff ff       	call   f0103d5d <cprintf>
f01058aa:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01058ad:	83 ec 0c             	sub    $0xc,%esp
f01058b0:	6a 00                	push   $0x0
f01058b2:	e8 09 af ff ff       	call   f01007c0 <iscons>
f01058b7:	89 c7                	mov    %eax,%edi
f01058b9:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01058bc:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01058c1:	e8 e9 ae ff ff       	call   f01007af <getchar>
f01058c6:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01058c8:	85 c0                	test   %eax,%eax
f01058ca:	79 18                	jns    f01058e4 <readline+0x58>
			cprintf("read error: %e\n", c);
f01058cc:	83 ec 08             	sub    $0x8,%esp
f01058cf:	50                   	push   %eax
f01058d0:	68 84 86 10 f0       	push   $0xf0108684
f01058d5:	e8 83 e4 ff ff       	call   f0103d5d <cprintf>
			return NULL;
f01058da:	83 c4 10             	add    $0x10,%esp
f01058dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01058e2:	eb 6f                	jmp    f0105953 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01058e4:	83 f8 08             	cmp    $0x8,%eax
f01058e7:	74 05                	je     f01058ee <readline+0x62>
f01058e9:	83 f8 7f             	cmp    $0x7f,%eax
f01058ec:	75 18                	jne    f0105906 <readline+0x7a>
f01058ee:	85 f6                	test   %esi,%esi
f01058f0:	7e 14                	jle    f0105906 <readline+0x7a>
			if (echoing)
f01058f2:	85 ff                	test   %edi,%edi
f01058f4:	74 0d                	je     f0105903 <readline+0x77>
				cputchar('\b');
f01058f6:	83 ec 0c             	sub    $0xc,%esp
f01058f9:	6a 08                	push   $0x8
f01058fb:	e8 9f ae ff ff       	call   f010079f <cputchar>
f0105900:	83 c4 10             	add    $0x10,%esp
			i--;
f0105903:	4e                   	dec    %esi
f0105904:	eb bb                	jmp    f01058c1 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105906:	83 fb 1f             	cmp    $0x1f,%ebx
f0105909:	7e 21                	jle    f010592c <readline+0xa0>
f010590b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105911:	7f 19                	jg     f010592c <readline+0xa0>
			if (echoing)
f0105913:	85 ff                	test   %edi,%edi
f0105915:	74 0c                	je     f0105923 <readline+0x97>
				cputchar(c);
f0105917:	83 ec 0c             	sub    $0xc,%esp
f010591a:	53                   	push   %ebx
f010591b:	e8 7f ae ff ff       	call   f010079f <cputchar>
f0105920:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105923:	88 9e 80 5a 2e f0    	mov    %bl,-0xfd1a580(%esi)
f0105929:	46                   	inc    %esi
f010592a:	eb 95                	jmp    f01058c1 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010592c:	83 fb 0a             	cmp    $0xa,%ebx
f010592f:	74 05                	je     f0105936 <readline+0xaa>
f0105931:	83 fb 0d             	cmp    $0xd,%ebx
f0105934:	75 8b                	jne    f01058c1 <readline+0x35>
			if (echoing)
f0105936:	85 ff                	test   %edi,%edi
f0105938:	74 0d                	je     f0105947 <readline+0xbb>
				cputchar('\n');
f010593a:	83 ec 0c             	sub    $0xc,%esp
f010593d:	6a 0a                	push   $0xa
f010593f:	e8 5b ae ff ff       	call   f010079f <cputchar>
f0105944:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105947:	c6 86 80 5a 2e f0 00 	movb   $0x0,-0xfd1a580(%esi)
			return buf;
f010594e:	b8 80 5a 2e f0       	mov    $0xf02e5a80,%eax
		}
	}
}
f0105953:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105956:	5b                   	pop    %ebx
f0105957:	5e                   	pop    %esi
f0105958:	5f                   	pop    %edi
f0105959:	c9                   	leave  
f010595a:	c3                   	ret    
	...

f010595c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010595c:	55                   	push   %ebp
f010595d:	89 e5                	mov    %esp,%ebp
f010595f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105962:	80 3a 00             	cmpb   $0x0,(%edx)
f0105965:	74 0e                	je     f0105975 <strlen+0x19>
f0105967:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f010596c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010596d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105971:	75 f9                	jne    f010596c <strlen+0x10>
f0105973:	eb 05                	jmp    f010597a <strlen+0x1e>
f0105975:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010597a:	c9                   	leave  
f010597b:	c3                   	ret    

f010597c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010597c:	55                   	push   %ebp
f010597d:	89 e5                	mov    %esp,%ebp
f010597f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105982:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105985:	85 d2                	test   %edx,%edx
f0105987:	74 17                	je     f01059a0 <strnlen+0x24>
f0105989:	80 39 00             	cmpb   $0x0,(%ecx)
f010598c:	74 19                	je     f01059a7 <strnlen+0x2b>
f010598e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105993:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105994:	39 d0                	cmp    %edx,%eax
f0105996:	74 14                	je     f01059ac <strnlen+0x30>
f0105998:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010599c:	75 f5                	jne    f0105993 <strnlen+0x17>
f010599e:	eb 0c                	jmp    f01059ac <strnlen+0x30>
f01059a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01059a5:	eb 05                	jmp    f01059ac <strnlen+0x30>
f01059a7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01059ac:	c9                   	leave  
f01059ad:	c3                   	ret    

f01059ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01059ae:	55                   	push   %ebp
f01059af:	89 e5                	mov    %esp,%ebp
f01059b1:	53                   	push   %ebx
f01059b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01059b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01059b8:	ba 00 00 00 00       	mov    $0x0,%edx
f01059bd:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01059c0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01059c3:	42                   	inc    %edx
f01059c4:	84 c9                	test   %cl,%cl
f01059c6:	75 f5                	jne    f01059bd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01059c8:	5b                   	pop    %ebx
f01059c9:	c9                   	leave  
f01059ca:	c3                   	ret    

f01059cb <strcat>:

char *
strcat(char *dst, const char *src)
{
f01059cb:	55                   	push   %ebp
f01059cc:	89 e5                	mov    %esp,%ebp
f01059ce:	53                   	push   %ebx
f01059cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01059d2:	53                   	push   %ebx
f01059d3:	e8 84 ff ff ff       	call   f010595c <strlen>
f01059d8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01059db:	ff 75 0c             	pushl  0xc(%ebp)
f01059de:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01059e1:	50                   	push   %eax
f01059e2:	e8 c7 ff ff ff       	call   f01059ae <strcpy>
	return dst;
}
f01059e7:	89 d8                	mov    %ebx,%eax
f01059e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01059ec:	c9                   	leave  
f01059ed:	c3                   	ret    

f01059ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01059ee:	55                   	push   %ebp
f01059ef:	89 e5                	mov    %esp,%ebp
f01059f1:	56                   	push   %esi
f01059f2:	53                   	push   %ebx
f01059f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01059f6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01059f9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01059fc:	85 f6                	test   %esi,%esi
f01059fe:	74 15                	je     f0105a15 <strncpy+0x27>
f0105a00:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0105a05:	8a 1a                	mov    (%edx),%bl
f0105a07:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105a0a:	80 3a 01             	cmpb   $0x1,(%edx)
f0105a0d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105a10:	41                   	inc    %ecx
f0105a11:	39 ce                	cmp    %ecx,%esi
f0105a13:	77 f0                	ja     f0105a05 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105a15:	5b                   	pop    %ebx
f0105a16:	5e                   	pop    %esi
f0105a17:	c9                   	leave  
f0105a18:	c3                   	ret    

f0105a19 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105a19:	55                   	push   %ebp
f0105a1a:	89 e5                	mov    %esp,%ebp
f0105a1c:	57                   	push   %edi
f0105a1d:	56                   	push   %esi
f0105a1e:	53                   	push   %ebx
f0105a1f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105a22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105a25:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105a28:	85 f6                	test   %esi,%esi
f0105a2a:	74 32                	je     f0105a5e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0105a2c:	83 fe 01             	cmp    $0x1,%esi
f0105a2f:	74 22                	je     f0105a53 <strlcpy+0x3a>
f0105a31:	8a 0b                	mov    (%ebx),%cl
f0105a33:	84 c9                	test   %cl,%cl
f0105a35:	74 20                	je     f0105a57 <strlcpy+0x3e>
f0105a37:	89 f8                	mov    %edi,%eax
f0105a39:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0105a3e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105a41:	88 08                	mov    %cl,(%eax)
f0105a43:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105a44:	39 f2                	cmp    %esi,%edx
f0105a46:	74 11                	je     f0105a59 <strlcpy+0x40>
f0105a48:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0105a4c:	42                   	inc    %edx
f0105a4d:	84 c9                	test   %cl,%cl
f0105a4f:	75 f0                	jne    f0105a41 <strlcpy+0x28>
f0105a51:	eb 06                	jmp    f0105a59 <strlcpy+0x40>
f0105a53:	89 f8                	mov    %edi,%eax
f0105a55:	eb 02                	jmp    f0105a59 <strlcpy+0x40>
f0105a57:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105a59:	c6 00 00             	movb   $0x0,(%eax)
f0105a5c:	eb 02                	jmp    f0105a60 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105a5e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0105a60:	29 f8                	sub    %edi,%eax
}
f0105a62:	5b                   	pop    %ebx
f0105a63:	5e                   	pop    %esi
f0105a64:	5f                   	pop    %edi
f0105a65:	c9                   	leave  
f0105a66:	c3                   	ret    

f0105a67 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105a67:	55                   	push   %ebp
f0105a68:	89 e5                	mov    %esp,%ebp
f0105a6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a6d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105a70:	8a 01                	mov    (%ecx),%al
f0105a72:	84 c0                	test   %al,%al
f0105a74:	74 10                	je     f0105a86 <strcmp+0x1f>
f0105a76:	3a 02                	cmp    (%edx),%al
f0105a78:	75 0c                	jne    f0105a86 <strcmp+0x1f>
		p++, q++;
f0105a7a:	41                   	inc    %ecx
f0105a7b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105a7c:	8a 01                	mov    (%ecx),%al
f0105a7e:	84 c0                	test   %al,%al
f0105a80:	74 04                	je     f0105a86 <strcmp+0x1f>
f0105a82:	3a 02                	cmp    (%edx),%al
f0105a84:	74 f4                	je     f0105a7a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105a86:	0f b6 c0             	movzbl %al,%eax
f0105a89:	0f b6 12             	movzbl (%edx),%edx
f0105a8c:	29 d0                	sub    %edx,%eax
}
f0105a8e:	c9                   	leave  
f0105a8f:	c3                   	ret    

f0105a90 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105a90:	55                   	push   %ebp
f0105a91:	89 e5                	mov    %esp,%ebp
f0105a93:	53                   	push   %ebx
f0105a94:	8b 55 08             	mov    0x8(%ebp),%edx
f0105a97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105a9a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0105a9d:	85 c0                	test   %eax,%eax
f0105a9f:	74 1b                	je     f0105abc <strncmp+0x2c>
f0105aa1:	8a 1a                	mov    (%edx),%bl
f0105aa3:	84 db                	test   %bl,%bl
f0105aa5:	74 24                	je     f0105acb <strncmp+0x3b>
f0105aa7:	3a 19                	cmp    (%ecx),%bl
f0105aa9:	75 20                	jne    f0105acb <strncmp+0x3b>
f0105aab:	48                   	dec    %eax
f0105aac:	74 15                	je     f0105ac3 <strncmp+0x33>
		n--, p++, q++;
f0105aae:	42                   	inc    %edx
f0105aaf:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105ab0:	8a 1a                	mov    (%edx),%bl
f0105ab2:	84 db                	test   %bl,%bl
f0105ab4:	74 15                	je     f0105acb <strncmp+0x3b>
f0105ab6:	3a 19                	cmp    (%ecx),%bl
f0105ab8:	74 f1                	je     f0105aab <strncmp+0x1b>
f0105aba:	eb 0f                	jmp    f0105acb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105abc:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ac1:	eb 05                	jmp    f0105ac8 <strncmp+0x38>
f0105ac3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105ac8:	5b                   	pop    %ebx
f0105ac9:	c9                   	leave  
f0105aca:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105acb:	0f b6 02             	movzbl (%edx),%eax
f0105ace:	0f b6 11             	movzbl (%ecx),%edx
f0105ad1:	29 d0                	sub    %edx,%eax
f0105ad3:	eb f3                	jmp    f0105ac8 <strncmp+0x38>

f0105ad5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105ad5:	55                   	push   %ebp
f0105ad6:	89 e5                	mov    %esp,%ebp
f0105ad8:	8b 45 08             	mov    0x8(%ebp),%eax
f0105adb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105ade:	8a 10                	mov    (%eax),%dl
f0105ae0:	84 d2                	test   %dl,%dl
f0105ae2:	74 18                	je     f0105afc <strchr+0x27>
		if (*s == c)
f0105ae4:	38 ca                	cmp    %cl,%dl
f0105ae6:	75 06                	jne    f0105aee <strchr+0x19>
f0105ae8:	eb 17                	jmp    f0105b01 <strchr+0x2c>
f0105aea:	38 ca                	cmp    %cl,%dl
f0105aec:	74 13                	je     f0105b01 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105aee:	40                   	inc    %eax
f0105aef:	8a 10                	mov    (%eax),%dl
f0105af1:	84 d2                	test   %dl,%dl
f0105af3:	75 f5                	jne    f0105aea <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0105af5:	b8 00 00 00 00       	mov    $0x0,%eax
f0105afa:	eb 05                	jmp    f0105b01 <strchr+0x2c>
f0105afc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b01:	c9                   	leave  
f0105b02:	c3                   	ret    

f0105b03 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105b03:	55                   	push   %ebp
f0105b04:	89 e5                	mov    %esp,%ebp
f0105b06:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b09:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105b0c:	8a 10                	mov    (%eax),%dl
f0105b0e:	84 d2                	test   %dl,%dl
f0105b10:	74 11                	je     f0105b23 <strfind+0x20>
		if (*s == c)
f0105b12:	38 ca                	cmp    %cl,%dl
f0105b14:	75 06                	jne    f0105b1c <strfind+0x19>
f0105b16:	eb 0b                	jmp    f0105b23 <strfind+0x20>
f0105b18:	38 ca                	cmp    %cl,%dl
f0105b1a:	74 07                	je     f0105b23 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105b1c:	40                   	inc    %eax
f0105b1d:	8a 10                	mov    (%eax),%dl
f0105b1f:	84 d2                	test   %dl,%dl
f0105b21:	75 f5                	jne    f0105b18 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f0105b23:	c9                   	leave  
f0105b24:	c3                   	ret    

f0105b25 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105b25:	55                   	push   %ebp
f0105b26:	89 e5                	mov    %esp,%ebp
f0105b28:	57                   	push   %edi
f0105b29:	56                   	push   %esi
f0105b2a:	53                   	push   %ebx
f0105b2b:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105b34:	85 c9                	test   %ecx,%ecx
f0105b36:	74 30                	je     f0105b68 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105b38:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105b3e:	75 25                	jne    f0105b65 <memset+0x40>
f0105b40:	f6 c1 03             	test   $0x3,%cl
f0105b43:	75 20                	jne    f0105b65 <memset+0x40>
		c &= 0xFF;
f0105b45:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105b48:	89 d3                	mov    %edx,%ebx
f0105b4a:	c1 e3 08             	shl    $0x8,%ebx
f0105b4d:	89 d6                	mov    %edx,%esi
f0105b4f:	c1 e6 18             	shl    $0x18,%esi
f0105b52:	89 d0                	mov    %edx,%eax
f0105b54:	c1 e0 10             	shl    $0x10,%eax
f0105b57:	09 f0                	or     %esi,%eax
f0105b59:	09 d0                	or     %edx,%eax
f0105b5b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105b5d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105b60:	fc                   	cld    
f0105b61:	f3 ab                	rep stos %eax,%es:(%edi)
f0105b63:	eb 03                	jmp    f0105b68 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105b65:	fc                   	cld    
f0105b66:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105b68:	89 f8                	mov    %edi,%eax
f0105b6a:	5b                   	pop    %ebx
f0105b6b:	5e                   	pop    %esi
f0105b6c:	5f                   	pop    %edi
f0105b6d:	c9                   	leave  
f0105b6e:	c3                   	ret    

f0105b6f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105b6f:	55                   	push   %ebp
f0105b70:	89 e5                	mov    %esp,%ebp
f0105b72:	57                   	push   %edi
f0105b73:	56                   	push   %esi
f0105b74:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b77:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105b7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105b7d:	39 c6                	cmp    %eax,%esi
f0105b7f:	73 34                	jae    f0105bb5 <memmove+0x46>
f0105b81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105b84:	39 d0                	cmp    %edx,%eax
f0105b86:	73 2d                	jae    f0105bb5 <memmove+0x46>
		s += n;
		d += n;
f0105b88:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105b8b:	f6 c2 03             	test   $0x3,%dl
f0105b8e:	75 1b                	jne    f0105bab <memmove+0x3c>
f0105b90:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105b96:	75 13                	jne    f0105bab <memmove+0x3c>
f0105b98:	f6 c1 03             	test   $0x3,%cl
f0105b9b:	75 0e                	jne    f0105bab <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105b9d:	83 ef 04             	sub    $0x4,%edi
f0105ba0:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105ba3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105ba6:	fd                   	std    
f0105ba7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105ba9:	eb 07                	jmp    f0105bb2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105bab:	4f                   	dec    %edi
f0105bac:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105baf:	fd                   	std    
f0105bb0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105bb2:	fc                   	cld    
f0105bb3:	eb 20                	jmp    f0105bd5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105bb5:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105bbb:	75 13                	jne    f0105bd0 <memmove+0x61>
f0105bbd:	a8 03                	test   $0x3,%al
f0105bbf:	75 0f                	jne    f0105bd0 <memmove+0x61>
f0105bc1:	f6 c1 03             	test   $0x3,%cl
f0105bc4:	75 0a                	jne    f0105bd0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105bc6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105bc9:	89 c7                	mov    %eax,%edi
f0105bcb:	fc                   	cld    
f0105bcc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105bce:	eb 05                	jmp    f0105bd5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105bd0:	89 c7                	mov    %eax,%edi
f0105bd2:	fc                   	cld    
f0105bd3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105bd5:	5e                   	pop    %esi
f0105bd6:	5f                   	pop    %edi
f0105bd7:	c9                   	leave  
f0105bd8:	c3                   	ret    

f0105bd9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105bd9:	55                   	push   %ebp
f0105bda:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105bdc:	ff 75 10             	pushl  0x10(%ebp)
f0105bdf:	ff 75 0c             	pushl  0xc(%ebp)
f0105be2:	ff 75 08             	pushl  0x8(%ebp)
f0105be5:	e8 85 ff ff ff       	call   f0105b6f <memmove>
}
f0105bea:	c9                   	leave  
f0105beb:	c3                   	ret    

f0105bec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105bec:	55                   	push   %ebp
f0105bed:	89 e5                	mov    %esp,%ebp
f0105bef:	57                   	push   %edi
f0105bf0:	56                   	push   %esi
f0105bf1:	53                   	push   %ebx
f0105bf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105bf5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105bf8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105bfb:	85 ff                	test   %edi,%edi
f0105bfd:	74 32                	je     f0105c31 <memcmp+0x45>
		if (*s1 != *s2)
f0105bff:	8a 03                	mov    (%ebx),%al
f0105c01:	8a 0e                	mov    (%esi),%cl
f0105c03:	38 c8                	cmp    %cl,%al
f0105c05:	74 19                	je     f0105c20 <memcmp+0x34>
f0105c07:	eb 0d                	jmp    f0105c16 <memcmp+0x2a>
f0105c09:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0105c0d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0105c11:	42                   	inc    %edx
f0105c12:	38 c8                	cmp    %cl,%al
f0105c14:	74 10                	je     f0105c26 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f0105c16:	0f b6 c0             	movzbl %al,%eax
f0105c19:	0f b6 c9             	movzbl %cl,%ecx
f0105c1c:	29 c8                	sub    %ecx,%eax
f0105c1e:	eb 16                	jmp    f0105c36 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105c20:	4f                   	dec    %edi
f0105c21:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c26:	39 fa                	cmp    %edi,%edx
f0105c28:	75 df                	jne    f0105c09 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105c2a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c2f:	eb 05                	jmp    f0105c36 <memcmp+0x4a>
f0105c31:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c36:	5b                   	pop    %ebx
f0105c37:	5e                   	pop    %esi
f0105c38:	5f                   	pop    %edi
f0105c39:	c9                   	leave  
f0105c3a:	c3                   	ret    

f0105c3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105c3b:	55                   	push   %ebp
f0105c3c:	89 e5                	mov    %esp,%ebp
f0105c3e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105c41:	89 c2                	mov    %eax,%edx
f0105c43:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105c46:	39 d0                	cmp    %edx,%eax
f0105c48:	73 12                	jae    f0105c5c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105c4a:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0105c4d:	38 08                	cmp    %cl,(%eax)
f0105c4f:	75 06                	jne    f0105c57 <memfind+0x1c>
f0105c51:	eb 09                	jmp    f0105c5c <memfind+0x21>
f0105c53:	38 08                	cmp    %cl,(%eax)
f0105c55:	74 05                	je     f0105c5c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105c57:	40                   	inc    %eax
f0105c58:	39 c2                	cmp    %eax,%edx
f0105c5a:	77 f7                	ja     f0105c53 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105c5c:	c9                   	leave  
f0105c5d:	c3                   	ret    

f0105c5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105c5e:	55                   	push   %ebp
f0105c5f:	89 e5                	mov    %esp,%ebp
f0105c61:	57                   	push   %edi
f0105c62:	56                   	push   %esi
f0105c63:	53                   	push   %ebx
f0105c64:	8b 55 08             	mov    0x8(%ebp),%edx
f0105c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105c6a:	eb 01                	jmp    f0105c6d <strtol+0xf>
		s++;
f0105c6c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105c6d:	8a 02                	mov    (%edx),%al
f0105c6f:	3c 20                	cmp    $0x20,%al
f0105c71:	74 f9                	je     f0105c6c <strtol+0xe>
f0105c73:	3c 09                	cmp    $0x9,%al
f0105c75:	74 f5                	je     f0105c6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105c77:	3c 2b                	cmp    $0x2b,%al
f0105c79:	75 08                	jne    f0105c83 <strtol+0x25>
		s++;
f0105c7b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105c7c:	bf 00 00 00 00       	mov    $0x0,%edi
f0105c81:	eb 13                	jmp    f0105c96 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105c83:	3c 2d                	cmp    $0x2d,%al
f0105c85:	75 0a                	jne    f0105c91 <strtol+0x33>
		s++, neg = 1;
f0105c87:	8d 52 01             	lea    0x1(%edx),%edx
f0105c8a:	bf 01 00 00 00       	mov    $0x1,%edi
f0105c8f:	eb 05                	jmp    f0105c96 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105c91:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105c96:	85 db                	test   %ebx,%ebx
f0105c98:	74 05                	je     f0105c9f <strtol+0x41>
f0105c9a:	83 fb 10             	cmp    $0x10,%ebx
f0105c9d:	75 28                	jne    f0105cc7 <strtol+0x69>
f0105c9f:	8a 02                	mov    (%edx),%al
f0105ca1:	3c 30                	cmp    $0x30,%al
f0105ca3:	75 10                	jne    f0105cb5 <strtol+0x57>
f0105ca5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105ca9:	75 0a                	jne    f0105cb5 <strtol+0x57>
		s += 2, base = 16;
f0105cab:	83 c2 02             	add    $0x2,%edx
f0105cae:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105cb3:	eb 12                	jmp    f0105cc7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0105cb5:	85 db                	test   %ebx,%ebx
f0105cb7:	75 0e                	jne    f0105cc7 <strtol+0x69>
f0105cb9:	3c 30                	cmp    $0x30,%al
f0105cbb:	75 05                	jne    f0105cc2 <strtol+0x64>
		s++, base = 8;
f0105cbd:	42                   	inc    %edx
f0105cbe:	b3 08                	mov    $0x8,%bl
f0105cc0:	eb 05                	jmp    f0105cc7 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0105cc2:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0105cc7:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ccc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105cce:	8a 0a                	mov    (%edx),%cl
f0105cd0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105cd3:	80 fb 09             	cmp    $0x9,%bl
f0105cd6:	77 08                	ja     f0105ce0 <strtol+0x82>
			dig = *s - '0';
f0105cd8:	0f be c9             	movsbl %cl,%ecx
f0105cdb:	83 e9 30             	sub    $0x30,%ecx
f0105cde:	eb 1e                	jmp    f0105cfe <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0105ce0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0105ce3:	80 fb 19             	cmp    $0x19,%bl
f0105ce6:	77 08                	ja     f0105cf0 <strtol+0x92>
			dig = *s - 'a' + 10;
f0105ce8:	0f be c9             	movsbl %cl,%ecx
f0105ceb:	83 e9 57             	sub    $0x57,%ecx
f0105cee:	eb 0e                	jmp    f0105cfe <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0105cf0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0105cf3:	80 fb 19             	cmp    $0x19,%bl
f0105cf6:	77 13                	ja     f0105d0b <strtol+0xad>
			dig = *s - 'A' + 10;
f0105cf8:	0f be c9             	movsbl %cl,%ecx
f0105cfb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105cfe:	39 f1                	cmp    %esi,%ecx
f0105d00:	7d 0d                	jge    f0105d0f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f0105d02:	42                   	inc    %edx
f0105d03:	0f af c6             	imul   %esi,%eax
f0105d06:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0105d09:	eb c3                	jmp    f0105cce <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0105d0b:	89 c1                	mov    %eax,%ecx
f0105d0d:	eb 02                	jmp    f0105d11 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105d0f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0105d11:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105d15:	74 05                	je     f0105d1c <strtol+0xbe>
		*endptr = (char *) s;
f0105d17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105d1a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105d1c:	85 ff                	test   %edi,%edi
f0105d1e:	74 04                	je     f0105d24 <strtol+0xc6>
f0105d20:	89 c8                	mov    %ecx,%eax
f0105d22:	f7 d8                	neg    %eax
}
f0105d24:	5b                   	pop    %ebx
f0105d25:	5e                   	pop    %esi
f0105d26:	5f                   	pop    %edi
f0105d27:	c9                   	leave  
f0105d28:	c3                   	ret    
f0105d29:	00 00                	add    %al,(%eax)
	...

f0105d2c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105d2c:	fa                   	cli    

	xorw    %ax, %ax
f0105d2d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105d2f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105d31:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105d33:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105d35:	0f 01 16             	lgdtl  (%esi)
f0105d38:	74 70                	je     f0105daa <sum+0x2>
	movl    %cr0, %eax
f0105d3a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105d3d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105d41:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105d44:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105d4a:	08 00                	or     %al,(%eax)

f0105d4c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105d4c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105d50:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105d52:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105d54:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105d56:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105d5a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105d5c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105d5e:	b8 00 60 12 00       	mov    $0x126000,%eax
	movl    %eax, %cr3
f0105d63:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105d66:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105d69:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105d6e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105d71:	8b 25 84 5e 2e f0    	mov    0xf02e5e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105d77:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105d7c:	b8 c2 00 10 f0       	mov    $0xf01000c2,%eax
	call    *%eax
f0105d81:	ff d0                	call   *%eax

f0105d83 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105d83:	eb fe                	jmp    f0105d83 <spin>
f0105d85:	8d 76 00             	lea    0x0(%esi),%esi

f0105d88 <gdt>:
	...
f0105d90:	ff                   	(bad)  
f0105d91:	ff 00                	incl   (%eax)
f0105d93:	00 00                	add    %al,(%eax)
f0105d95:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105d9c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105da0 <gdtdesc>:
f0105da0:	17                   	pop    %ss
f0105da1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105da6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105da6:	90                   	nop
	...

f0105da8 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105da8:	55                   	push   %ebp
f0105da9:	89 e5                	mov    %esp,%ebp
f0105dab:	56                   	push   %esi
f0105dac:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105dad:	85 d2                	test   %edx,%edx
f0105daf:	7e 17                	jle    f0105dc8 <sum+0x20>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105db1:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0105db6:	b9 00 00 00 00       	mov    $0x0,%ecx
		sum += ((uint8_t *)addr)[i];
f0105dbb:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0105dbf:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105dc1:	41                   	inc    %ecx
f0105dc2:	39 d1                	cmp    %edx,%ecx
f0105dc4:	75 f5                	jne    f0105dbb <sum+0x13>
f0105dc6:	eb 05                	jmp    f0105dcd <sum+0x25>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0105dcd:	88 d8                	mov    %bl,%al
f0105dcf:	5b                   	pop    %ebx
f0105dd0:	5e                   	pop    %esi
f0105dd1:	c9                   	leave  
f0105dd2:	c3                   	ret    

f0105dd3 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105dd3:	55                   	push   %ebp
f0105dd4:	89 e5                	mov    %esp,%ebp
f0105dd6:	56                   	push   %esi
f0105dd7:	53                   	push   %ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105dd8:	8b 0d 88 5e 2e f0    	mov    0xf02e5e88,%ecx
f0105dde:	89 c3                	mov    %eax,%ebx
f0105de0:	c1 eb 0c             	shr    $0xc,%ebx
f0105de3:	39 cb                	cmp    %ecx,%ebx
f0105de5:	72 12                	jb     f0105df9 <mpsearch1+0x26>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105de7:	50                   	push   %eax
f0105de8:	68 68 68 10 f0       	push   $0xf0106868
f0105ded:	6a 57                	push   $0x57
f0105def:	68 21 88 10 f0       	push   $0xf0108821
f0105df4:	e8 6f a2 ff ff       	call   f0100068 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105df9:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105dfc:	89 f2                	mov    %esi,%edx
f0105dfe:	c1 ea 0c             	shr    $0xc,%edx
f0105e01:	39 d1                	cmp    %edx,%ecx
f0105e03:	77 12                	ja     f0105e17 <mpsearch1+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e05:	56                   	push   %esi
f0105e06:	68 68 68 10 f0       	push   $0xf0106868
f0105e0b:	6a 57                	push   $0x57
f0105e0d:	68 21 88 10 f0       	push   $0xf0108821
f0105e12:	e8 51 a2 ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f0105e17:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0105e1d:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105e23:	39 f3                	cmp    %esi,%ebx
f0105e25:	73 35                	jae    f0105e5c <mpsearch1+0x89>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105e27:	83 ec 04             	sub    $0x4,%esp
f0105e2a:	6a 04                	push   $0x4
f0105e2c:	68 31 88 10 f0       	push   $0xf0108831
f0105e31:	53                   	push   %ebx
f0105e32:	e8 b5 fd ff ff       	call   f0105bec <memcmp>
f0105e37:	83 c4 10             	add    $0x10,%esp
f0105e3a:	85 c0                	test   %eax,%eax
f0105e3c:	75 10                	jne    f0105e4e <mpsearch1+0x7b>
		    sum(mp, sizeof(*mp)) == 0)
f0105e3e:	ba 10 00 00 00       	mov    $0x10,%edx
f0105e43:	89 d8                	mov    %ebx,%eax
f0105e45:	e8 5e ff ff ff       	call   f0105da8 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105e4a:	84 c0                	test   %al,%al
f0105e4c:	74 13                	je     f0105e61 <mpsearch1+0x8e>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105e4e:	83 c3 10             	add    $0x10,%ebx
f0105e51:	39 de                	cmp    %ebx,%esi
f0105e53:	77 d2                	ja     f0105e27 <mpsearch1+0x54>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105e55:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105e5a:	eb 05                	jmp    f0105e61 <mpsearch1+0x8e>
f0105e5c:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105e61:	89 d8                	mov    %ebx,%eax
f0105e63:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e66:	5b                   	pop    %ebx
f0105e67:	5e                   	pop    %esi
f0105e68:	c9                   	leave  
f0105e69:	c3                   	ret    

f0105e6a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105e6a:	55                   	push   %ebp
f0105e6b:	89 e5                	mov    %esp,%ebp
f0105e6d:	57                   	push   %edi
f0105e6e:	56                   	push   %esi
f0105e6f:	53                   	push   %ebx
f0105e70:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105e73:	c7 05 c0 63 2e f0 20 	movl   $0xf02e6020,0xf02e63c0
f0105e7a:	60 2e f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105e7d:	83 3d 88 5e 2e f0 00 	cmpl   $0x0,0xf02e5e88
f0105e84:	75 16                	jne    f0105e9c <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e86:	68 00 04 00 00       	push   $0x400
f0105e8b:	68 68 68 10 f0       	push   $0xf0106868
f0105e90:	6a 6f                	push   $0x6f
f0105e92:	68 21 88 10 f0       	push   $0xf0108821
f0105e97:	e8 cc a1 ff ff       	call   f0100068 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105e9c:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105ea3:	85 c0                	test   %eax,%eax
f0105ea5:	74 16                	je     f0105ebd <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
f0105ea7:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105eaa:	ba 00 04 00 00       	mov    $0x400,%edx
f0105eaf:	e8 1f ff ff ff       	call   f0105dd3 <mpsearch1>
f0105eb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105eb7:	85 c0                	test   %eax,%eax
f0105eb9:	75 3c                	jne    f0105ef7 <mp_init+0x8d>
f0105ebb:	eb 20                	jmp    f0105edd <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105ebd:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105ec4:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105ec7:	2d 00 04 00 00       	sub    $0x400,%eax
f0105ecc:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ed1:	e8 fd fe ff ff       	call   f0105dd3 <mpsearch1>
f0105ed6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ed9:	85 c0                	test   %eax,%eax
f0105edb:	75 1a                	jne    f0105ef7 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105edd:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ee2:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105ee7:	e8 e7 fe ff ff       	call   f0105dd3 <mpsearch1>
f0105eec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105eef:	85 c0                	test   %eax,%eax
f0105ef1:	0f 84 3b 02 00 00    	je     f0106132 <mp_init+0x2c8>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105ef7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105efa:	8b 70 04             	mov    0x4(%eax),%esi
f0105efd:	85 f6                	test   %esi,%esi
f0105eff:	74 06                	je     f0105f07 <mp_init+0x9d>
f0105f01:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105f05:	74 15                	je     f0105f1c <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105f07:	83 ec 0c             	sub    $0xc,%esp
f0105f0a:	68 94 86 10 f0       	push   $0xf0108694
f0105f0f:	e8 49 de ff ff       	call   f0103d5d <cprintf>
f0105f14:	83 c4 10             	add    $0x10,%esp
f0105f17:	e9 16 02 00 00       	jmp    f0106132 <mp_init+0x2c8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f1c:	89 f0                	mov    %esi,%eax
f0105f1e:	c1 e8 0c             	shr    $0xc,%eax
f0105f21:	3b 05 88 5e 2e f0    	cmp    0xf02e5e88,%eax
f0105f27:	72 15                	jb     f0105f3e <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f29:	56                   	push   %esi
f0105f2a:	68 68 68 10 f0       	push   $0xf0106868
f0105f2f:	68 90 00 00 00       	push   $0x90
f0105f34:	68 21 88 10 f0       	push   $0xf0108821
f0105f39:	e8 2a a1 ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f0105f3e:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105f44:	83 ec 04             	sub    $0x4,%esp
f0105f47:	6a 04                	push   $0x4
f0105f49:	68 36 88 10 f0       	push   $0xf0108836
f0105f4e:	56                   	push   %esi
f0105f4f:	e8 98 fc ff ff       	call   f0105bec <memcmp>
f0105f54:	83 c4 10             	add    $0x10,%esp
f0105f57:	85 c0                	test   %eax,%eax
f0105f59:	74 15                	je     f0105f70 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105f5b:	83 ec 0c             	sub    $0xc,%esp
f0105f5e:	68 c4 86 10 f0       	push   $0xf01086c4
f0105f63:	e8 f5 dd ff ff       	call   f0103d5d <cprintf>
f0105f68:	83 c4 10             	add    $0x10,%esp
f0105f6b:	e9 c2 01 00 00       	jmp    f0106132 <mp_init+0x2c8>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105f70:	66 8b 5e 04          	mov    0x4(%esi),%bx
f0105f74:	0f b7 d3             	movzwl %bx,%edx
f0105f77:	89 f0                	mov    %esi,%eax
f0105f79:	e8 2a fe ff ff       	call   f0105da8 <sum>
f0105f7e:	84 c0                	test   %al,%al
f0105f80:	74 15                	je     f0105f97 <mp_init+0x12d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105f82:	83 ec 0c             	sub    $0xc,%esp
f0105f85:	68 f8 86 10 f0       	push   $0xf01086f8
f0105f8a:	e8 ce dd ff ff       	call   f0103d5d <cprintf>
f0105f8f:	83 c4 10             	add    $0x10,%esp
f0105f92:	e9 9b 01 00 00       	jmp    f0106132 <mp_init+0x2c8>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105f97:	8a 46 06             	mov    0x6(%esi),%al
f0105f9a:	3c 01                	cmp    $0x1,%al
f0105f9c:	74 1d                	je     f0105fbb <mp_init+0x151>
f0105f9e:	3c 04                	cmp    $0x4,%al
f0105fa0:	74 19                	je     f0105fbb <mp_init+0x151>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105fa2:	83 ec 08             	sub    $0x8,%esp
f0105fa5:	0f b6 c0             	movzbl %al,%eax
f0105fa8:	50                   	push   %eax
f0105fa9:	68 1c 87 10 f0       	push   $0xf010871c
f0105fae:	e8 aa dd ff ff       	call   f0103d5d <cprintf>
f0105fb3:	83 c4 10             	add    $0x10,%esp
f0105fb6:	e9 77 01 00 00       	jmp    f0106132 <mp_init+0x2c8>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0105fbb:	0f b7 56 28          	movzwl 0x28(%esi),%edx
f0105fbf:	0f b7 c3             	movzwl %bx,%eax
f0105fc2:	8d 04 06             	lea    (%esi,%eax,1),%eax
f0105fc5:	e8 de fd ff ff       	call   f0105da8 <sum>
f0105fca:	3a 46 2a             	cmp    0x2a(%esi),%al
f0105fcd:	74 15                	je     f0105fe4 <mp_init+0x17a>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105fcf:	83 ec 0c             	sub    $0xc,%esp
f0105fd2:	68 3c 87 10 f0       	push   $0xf010873c
f0105fd7:	e8 81 dd ff ff       	call   f0103d5d <cprintf>
f0105fdc:	83 c4 10             	add    $0x10,%esp
f0105fdf:	e9 4e 01 00 00       	jmp    f0106132 <mp_init+0x2c8>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105fe4:	85 f6                	test   %esi,%esi
f0105fe6:	0f 84 46 01 00 00    	je     f0106132 <mp_init+0x2c8>
		return;
	ismp = 1;
f0105fec:	c7 05 00 60 2e f0 01 	movl   $0x1,0xf02e6000
f0105ff3:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105ff6:	8b 46 24             	mov    0x24(%esi),%eax
f0105ff9:	a3 00 70 32 f0       	mov    %eax,0xf0327000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105ffe:	66 83 7e 22 00       	cmpw   $0x0,0x22(%esi)
f0106003:	0f 84 ac 00 00 00    	je     f01060b5 <mp_init+0x24b>
f0106009:	8d 5e 2c             	lea    0x2c(%esi),%ebx
f010600c:	bf 00 00 00 00       	mov    $0x0,%edi
		switch (*p) {
f0106011:	8a 03                	mov    (%ebx),%al
f0106013:	84 c0                	test   %al,%al
f0106015:	74 06                	je     f010601d <mp_init+0x1b3>
f0106017:	3c 04                	cmp    $0x4,%al
f0106019:	77 6b                	ja     f0106086 <mp_init+0x21c>
f010601b:	eb 64                	jmp    f0106081 <mp_init+0x217>
		case MPPROC:
			proc = (struct mpproc *)p;
f010601d:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f010601f:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f0106023:	74 1d                	je     f0106042 <mp_init+0x1d8>
				bootcpu = &cpus[ncpu];
f0106025:	a1 c4 63 2e f0       	mov    0xf02e63c4,%eax
f010602a:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0106031:	29 c1                	sub    %eax,%ecx
f0106033:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0106036:	8d 04 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%eax
f010603d:	a3 c0 63 2e f0       	mov    %eax,0xf02e63c0
			if (ncpu < NCPU) {
f0106042:	a1 c4 63 2e f0       	mov    0xf02e63c4,%eax
f0106047:	83 f8 07             	cmp    $0x7,%eax
f010604a:	7f 1b                	jg     f0106067 <mp_init+0x1fd>
				cpus[ncpu].cpu_id = ncpu;
f010604c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106053:	29 c2                	sub    %eax,%edx
f0106055:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0106058:	88 04 95 20 60 2e f0 	mov    %al,-0xfd19fe0(,%edx,4)
				ncpu++;
f010605f:	40                   	inc    %eax
f0106060:	a3 c4 63 2e f0       	mov    %eax,0xf02e63c4
f0106065:	eb 15                	jmp    f010607c <mp_init+0x212>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106067:	83 ec 08             	sub    $0x8,%esp
f010606a:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f010606e:	50                   	push   %eax
f010606f:	68 6c 87 10 f0       	push   $0xf010876c
f0106074:	e8 e4 dc ff ff       	call   f0103d5d <cprintf>
f0106079:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010607c:	83 c3 14             	add    $0x14,%ebx
			continue;
f010607f:	eb 27                	jmp    f01060a8 <mp_init+0x23e>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106081:	83 c3 08             	add    $0x8,%ebx
			continue;
f0106084:	eb 22                	jmp    f01060a8 <mp_init+0x23e>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106086:	83 ec 08             	sub    $0x8,%esp
f0106089:	0f b6 c0             	movzbl %al,%eax
f010608c:	50                   	push   %eax
f010608d:	68 94 87 10 f0       	push   $0xf0108794
f0106092:	e8 c6 dc ff ff       	call   f0103d5d <cprintf>
			ismp = 0;
f0106097:	c7 05 00 60 2e f0 00 	movl   $0x0,0xf02e6000
f010609e:	00 00 00 
			i = conf->entry;
f01060a1:	0f b7 7e 22          	movzwl 0x22(%esi),%edi
f01060a5:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01060a8:	47                   	inc    %edi
f01060a9:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f01060ad:	39 f8                	cmp    %edi,%eax
f01060af:	0f 87 5c ff ff ff    	ja     f0106011 <mp_init+0x1a7>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01060b5:	a1 c0 63 2e f0       	mov    0xf02e63c0,%eax
f01060ba:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01060c1:	83 3d 00 60 2e f0 00 	cmpl   $0x0,0xf02e6000
f01060c8:	75 26                	jne    f01060f0 <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01060ca:	c7 05 c4 63 2e f0 01 	movl   $0x1,0xf02e63c4
f01060d1:	00 00 00 
		lapicaddr = 0;
f01060d4:	c7 05 00 70 32 f0 00 	movl   $0x0,0xf0327000
f01060db:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01060de:	83 ec 0c             	sub    $0xc,%esp
f01060e1:	68 b4 87 10 f0       	push   $0xf01087b4
f01060e6:	e8 72 dc ff ff       	call   f0103d5d <cprintf>
		return;
f01060eb:	83 c4 10             	add    $0x10,%esp
f01060ee:	eb 42                	jmp    f0106132 <mp_init+0x2c8>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01060f0:	83 ec 04             	sub    $0x4,%esp
f01060f3:	ff 35 c4 63 2e f0    	pushl  0xf02e63c4
f01060f9:	0f b6 00             	movzbl (%eax),%eax
f01060fc:	50                   	push   %eax
f01060fd:	68 3b 88 10 f0       	push   $0xf010883b
f0106102:	e8 56 dc ff ff       	call   f0103d5d <cprintf>

	if (mp->imcrp) {
f0106107:	83 c4 10             	add    $0x10,%esp
f010610a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010610d:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106111:	74 1f                	je     f0106132 <mp_init+0x2c8>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106113:	83 ec 0c             	sub    $0xc,%esp
f0106116:	68 e0 87 10 f0       	push   $0xf01087e0
f010611b:	e8 3d dc ff ff       	call   f0103d5d <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106120:	ba 22 00 00 00       	mov    $0x22,%edx
f0106125:	b0 70                	mov    $0x70,%al
f0106127:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106128:	b2 23                	mov    $0x23,%dl
f010612a:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010612b:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010612e:	ee                   	out    %al,(%dx)
f010612f:	83 c4 10             	add    $0x10,%esp
	}
}
f0106132:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106135:	5b                   	pop    %ebx
f0106136:	5e                   	pop    %esi
f0106137:	5f                   	pop    %edi
f0106138:	c9                   	leave  
f0106139:	c3                   	ret    
	...

f010613c <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010613c:	55                   	push   %ebp
f010613d:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010613f:	c1 e0 02             	shl    $0x2,%eax
f0106142:	03 05 04 70 32 f0    	add    0xf0327004,%eax
f0106148:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010614a:	a1 04 70 32 f0       	mov    0xf0327004,%eax
f010614f:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106152:	c9                   	leave  
f0106153:	c3                   	ret    

f0106154 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106154:	55                   	push   %ebp
f0106155:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106157:	a1 04 70 32 f0       	mov    0xf0327004,%eax
f010615c:	85 c0                	test   %eax,%eax
f010615e:	74 08                	je     f0106168 <cpunum+0x14>
		return lapic[ID] >> 24;
f0106160:	8b 40 20             	mov    0x20(%eax),%eax
f0106163:	c1 e8 18             	shr    $0x18,%eax
f0106166:	eb 05                	jmp    f010616d <cpunum+0x19>
	return 0;
f0106168:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010616d:	c9                   	leave  
f010616e:	c3                   	ret    

f010616f <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010616f:	55                   	push   %ebp
f0106170:	89 e5                	mov    %esp,%ebp
f0106172:	83 ec 08             	sub    $0x8,%esp
	if (!lapicaddr)
f0106175:	a1 00 70 32 f0       	mov    0xf0327000,%eax
f010617a:	85 c0                	test   %eax,%eax
f010617c:	0f 84 2a 01 00 00    	je     f01062ac <lapic_init+0x13d>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106182:	83 ec 08             	sub    $0x8,%esp
f0106185:	68 00 10 00 00       	push   $0x1000
f010618a:	50                   	push   %eax
f010618b:	e8 52 b7 ff ff       	call   f01018e2 <mmio_map_region>
f0106190:	a3 04 70 32 f0       	mov    %eax,0xf0327004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106195:	ba 27 01 00 00       	mov    $0x127,%edx
f010619a:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010619f:	e8 98 ff ff ff       	call   f010613c <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01061a4:	ba 0b 00 00 00       	mov    $0xb,%edx
f01061a9:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01061ae:	e8 89 ff ff ff       	call   f010613c <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01061b3:	ba 20 00 02 00       	mov    $0x20020,%edx
f01061b8:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01061bd:	e8 7a ff ff ff       	call   f010613c <lapicw>
	lapicw(TICR, 10000000); 
f01061c2:	ba 80 96 98 00       	mov    $0x989680,%edx
f01061c7:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01061cc:	e8 6b ff ff ff       	call   f010613c <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01061d1:	e8 7e ff ff ff       	call   f0106154 <cpunum>
f01061d6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01061dd:	29 c2                	sub    %eax,%edx
f01061df:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01061e2:	8d 04 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%eax
f01061e9:	83 c4 10             	add    $0x10,%esp
f01061ec:	39 05 c0 63 2e f0    	cmp    %eax,0xf02e63c0
f01061f2:	74 0f                	je     f0106203 <lapic_init+0x94>
		lapicw(LINT0, MASKED);
f01061f4:	ba 00 00 01 00       	mov    $0x10000,%edx
f01061f9:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01061fe:	e8 39 ff ff ff       	call   f010613c <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106203:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106208:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010620d:	e8 2a ff ff ff       	call   f010613c <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106212:	a1 04 70 32 f0       	mov    0xf0327004,%eax
f0106217:	8b 40 30             	mov    0x30(%eax),%eax
f010621a:	c1 e8 10             	shr    $0x10,%eax
f010621d:	3c 03                	cmp    $0x3,%al
f010621f:	76 0f                	jbe    f0106230 <lapic_init+0xc1>
		lapicw(PCINT, MASKED);
f0106221:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106226:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010622b:	e8 0c ff ff ff       	call   f010613c <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106230:	ba 33 00 00 00       	mov    $0x33,%edx
f0106235:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010623a:	e8 fd fe ff ff       	call   f010613c <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010623f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106244:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106249:	e8 ee fe ff ff       	call   f010613c <lapicw>
	lapicw(ESR, 0);
f010624e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106253:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106258:	e8 df fe ff ff       	call   f010613c <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010625d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106262:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106267:	e8 d0 fe ff ff       	call   f010613c <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010626c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106271:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106276:	e8 c1 fe ff ff       	call   f010613c <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010627b:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106280:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106285:	e8 b2 fe ff ff       	call   f010613c <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010628a:	8b 15 04 70 32 f0    	mov    0xf0327004,%edx
f0106290:	81 c2 00 03 00 00    	add    $0x300,%edx
f0106296:	8b 02                	mov    (%edx),%eax
f0106298:	f6 c4 10             	test   $0x10,%ah
f010629b:	75 f9                	jne    f0106296 <lapic_init+0x127>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010629d:	ba 00 00 00 00       	mov    $0x0,%edx
f01062a2:	b8 20 00 00 00       	mov    $0x20,%eax
f01062a7:	e8 90 fe ff ff       	call   f010613c <lapicw>
}
f01062ac:	c9                   	leave  
f01062ad:	c3                   	ret    

f01062ae <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01062ae:	55                   	push   %ebp
f01062af:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01062b1:	83 3d 04 70 32 f0 00 	cmpl   $0x0,0xf0327004
f01062b8:	74 0f                	je     f01062c9 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f01062ba:	ba 00 00 00 00       	mov    $0x0,%edx
f01062bf:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01062c4:	e8 73 fe ff ff       	call   f010613c <lapicw>
}
f01062c9:	c9                   	leave  
f01062ca:	c3                   	ret    

f01062cb <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01062cb:	55                   	push   %ebp
f01062cc:	89 e5                	mov    %esp,%ebp
f01062ce:	56                   	push   %esi
f01062cf:	53                   	push   %ebx
f01062d0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01062d3:	8a 5d 08             	mov    0x8(%ebp),%bl
f01062d6:	ba 70 00 00 00       	mov    $0x70,%edx
f01062db:	b0 0f                	mov    $0xf,%al
f01062dd:	ee                   	out    %al,(%dx)
f01062de:	b2 71                	mov    $0x71,%dl
f01062e0:	b0 0a                	mov    $0xa,%al
f01062e2:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01062e3:	83 3d 88 5e 2e f0 00 	cmpl   $0x0,0xf02e5e88
f01062ea:	75 19                	jne    f0106305 <lapic_startap+0x3a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062ec:	68 67 04 00 00       	push   $0x467
f01062f1:	68 68 68 10 f0       	push   $0xf0106868
f01062f6:	68 98 00 00 00       	push   $0x98
f01062fb:	68 58 88 10 f0       	push   $0xf0108858
f0106300:	e8 63 9d ff ff       	call   f0100068 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106305:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010630c:	00 00 
	wrv[1] = addr >> 4;
f010630e:	89 f0                	mov    %esi,%eax
f0106310:	c1 e8 04             	shr    $0x4,%eax
f0106313:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106319:	c1 e3 18             	shl    $0x18,%ebx
f010631c:	89 da                	mov    %ebx,%edx
f010631e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106323:	e8 14 fe ff ff       	call   f010613c <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106328:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010632d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106332:	e8 05 fe ff ff       	call   f010613c <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106337:	ba 00 85 00 00       	mov    $0x8500,%edx
f010633c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106341:	e8 f6 fd ff ff       	call   f010613c <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106346:	c1 ee 0c             	shr    $0xc,%esi
f0106349:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010634f:	89 da                	mov    %ebx,%edx
f0106351:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106356:	e8 e1 fd ff ff       	call   f010613c <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010635b:	89 f2                	mov    %esi,%edx
f010635d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106362:	e8 d5 fd ff ff       	call   f010613c <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106367:	89 da                	mov    %ebx,%edx
f0106369:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010636e:	e8 c9 fd ff ff       	call   f010613c <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106373:	89 f2                	mov    %esi,%edx
f0106375:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010637a:	e8 bd fd ff ff       	call   f010613c <lapicw>
		microdelay(200);
	}
}
f010637f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106382:	5b                   	pop    %ebx
f0106383:	5e                   	pop    %esi
f0106384:	c9                   	leave  
f0106385:	c3                   	ret    

f0106386 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106386:	55                   	push   %ebp
f0106387:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106389:	8b 55 08             	mov    0x8(%ebp),%edx
f010638c:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106392:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106397:	e8 a0 fd ff ff       	call   f010613c <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010639c:	8b 15 04 70 32 f0    	mov    0xf0327004,%edx
f01063a2:	81 c2 00 03 00 00    	add    $0x300,%edx
f01063a8:	8b 02                	mov    (%edx),%eax
f01063aa:	f6 c4 10             	test   $0x10,%ah
f01063ad:	75 f9                	jne    f01063a8 <lapic_ipi+0x22>
		;
}
f01063af:	c9                   	leave  
f01063b0:	c3                   	ret    
f01063b1:	00 00                	add    %al,(%eax)
	...

f01063b4 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01063b4:	55                   	push   %ebp
f01063b5:	89 e5                	mov    %esp,%ebp
f01063b7:	53                   	push   %ebx
f01063b8:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01063bb:	83 38 00             	cmpl   $0x0,(%eax)
f01063be:	74 25                	je     f01063e5 <holding+0x31>
f01063c0:	8b 58 08             	mov    0x8(%eax),%ebx
f01063c3:	e8 8c fd ff ff       	call   f0106154 <cpunum>
f01063c8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01063cf:	29 c2                	sub    %eax,%edx
f01063d1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01063d4:	8d 04 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f01063db:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f01063dd:	0f 94 c0             	sete   %al
f01063e0:	0f b6 c0             	movzbl %al,%eax
f01063e3:	eb 05                	jmp    f01063ea <holding+0x36>
f01063e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01063ea:	83 c4 04             	add    $0x4,%esp
f01063ed:	5b                   	pop    %ebx
f01063ee:	c9                   	leave  
f01063ef:	c3                   	ret    

f01063f0 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01063f0:	55                   	push   %ebp
f01063f1:	89 e5                	mov    %esp,%ebp
f01063f3:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01063f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01063fc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01063ff:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106402:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106409:	c9                   	leave  
f010640a:	c3                   	ret    

f010640b <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010640b:	55                   	push   %ebp
f010640c:	89 e5                	mov    %esp,%ebp
f010640e:	53                   	push   %ebx
f010640f:	83 ec 04             	sub    $0x4,%esp
f0106412:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106415:	89 d8                	mov    %ebx,%eax
f0106417:	e8 98 ff ff ff       	call   f01063b4 <holding>
f010641c:	85 c0                	test   %eax,%eax
f010641e:	75 0d                	jne    f010642d <spin_lock+0x22>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106420:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106422:	b0 01                	mov    $0x1,%al
f0106424:	f0 87 03             	lock xchg %eax,(%ebx)
f0106427:	85 c0                	test   %eax,%eax
f0106429:	75 20                	jne    f010644b <spin_lock+0x40>
f010642b:	eb 2e                	jmp    f010645b <spin_lock+0x50>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010642d:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106430:	e8 1f fd ff ff       	call   f0106154 <cpunum>
f0106435:	83 ec 0c             	sub    $0xc,%esp
f0106438:	53                   	push   %ebx
f0106439:	50                   	push   %eax
f010643a:	68 68 88 10 f0       	push   $0xf0108868
f010643f:	6a 41                	push   $0x41
f0106441:	68 cc 88 10 f0       	push   $0xf01088cc
f0106446:	e8 1d 9c ff ff       	call   f0100068 <_panic>
f010644b:	b9 01 00 00 00       	mov    $0x1,%ecx

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106450:	f3 90                	pause  
f0106452:	89 c8                	mov    %ecx,%eax
f0106454:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106457:	85 c0                	test   %eax,%eax
f0106459:	75 f5                	jne    f0106450 <spin_lock+0x45>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010645b:	e8 f4 fc ff ff       	call   f0106154 <cpunum>
f0106460:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106467:	29 c2                	sub    %eax,%edx
f0106469:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010646c:	8d 04 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%eax
f0106473:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106476:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0106479:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010647b:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0106480:	77 30                	ja     f01064b2 <spin_lock+0xa7>
f0106482:	eb 27                	jmp    f01064ab <spin_lock+0xa0>
f0106484:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010648a:	76 10                	jbe    f010649c <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
f010648c:	8b 5a 04             	mov    0x4(%edx),%ebx
f010648f:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106492:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106494:	40                   	inc    %eax
f0106495:	83 f8 0a             	cmp    $0xa,%eax
f0106498:	75 ea                	jne    f0106484 <spin_lock+0x79>
f010649a:	eb 25                	jmp    f01064c1 <spin_lock+0xb6>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010649c:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01064a3:	40                   	inc    %eax
f01064a4:	83 f8 09             	cmp    $0x9,%eax
f01064a7:	7e f3                	jle    f010649c <spin_lock+0x91>
f01064a9:	eb 16                	jmp    f01064c1 <spin_lock+0xb6>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01064ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01064b0:	eb ea                	jmp    f010649c <spin_lock+0x91>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01064b2:	8b 50 04             	mov    0x4(%eax),%edx
f01064b5:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01064b8:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01064ba:	b8 01 00 00 00       	mov    $0x1,%eax
f01064bf:	eb c3                	jmp    f0106484 <spin_lock+0x79>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01064c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01064c4:	c9                   	leave  
f01064c5:	c3                   	ret    

f01064c6 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01064c6:	55                   	push   %ebp
f01064c7:	89 e5                	mov    %esp,%ebp
f01064c9:	57                   	push   %edi
f01064ca:	56                   	push   %esi
f01064cb:	53                   	push   %ebx
f01064cc:	83 ec 4c             	sub    $0x4c,%esp
f01064cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01064d2:	89 d8                	mov    %ebx,%eax
f01064d4:	e8 db fe ff ff       	call   f01063b4 <holding>
f01064d9:	85 c0                	test   %eax,%eax
f01064db:	0f 85 c0 00 00 00    	jne    f01065a1 <spin_unlock+0xdb>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01064e1:	83 ec 04             	sub    $0x4,%esp
f01064e4:	6a 28                	push   $0x28
f01064e6:	8d 43 0c             	lea    0xc(%ebx),%eax
f01064e9:	50                   	push   %eax
f01064ea:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01064ed:	50                   	push   %eax
f01064ee:	e8 7c f6 ff ff       	call   f0105b6f <memmove>
			
		cprintf("%u\n", lk->cpu->cpu_id);
f01064f3:	83 c4 08             	add    $0x8,%esp
f01064f6:	8b 43 08             	mov    0x8(%ebx),%eax
f01064f9:	0f b6 00             	movzbl (%eax),%eax
f01064fc:	50                   	push   %eax
f01064fd:	68 58 6b 10 f0       	push   $0xf0106b58
f0106502:	e8 56 d8 ff ff       	call   f0103d5d <cprintf>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106507:	8b 43 08             	mov    0x8(%ebx),%eax
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
			
		cprintf("%u\n", lk->cpu->cpu_id);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010650a:	0f b6 30             	movzbl (%eax),%esi
f010650d:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106510:	e8 3f fc ff ff       	call   f0106154 <cpunum>
f0106515:	56                   	push   %esi
f0106516:	53                   	push   %ebx
f0106517:	50                   	push   %eax
f0106518:	68 94 88 10 f0       	push   $0xf0108894
f010651d:	e8 3b d8 ff ff       	call   f0103d5d <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
f0106522:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0106525:	83 c4 20             	add    $0x20,%esp
f0106528:	85 c0                	test   %eax,%eax
f010652a:	74 61                	je     f010658d <spin_unlock+0xc7>
f010652c:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f010652f:	8d 7d cc             	lea    -0x34(%ebp),%edi
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106532:	8d 75 d0             	lea    -0x30(%ebp),%esi
f0106535:	83 ec 08             	sub    $0x8,%esp
f0106538:	56                   	push   %esi
f0106539:	50                   	push   %eax
f010653a:	e8 3e eb ff ff       	call   f010507d <debuginfo_eip>
f010653f:	83 c4 10             	add    $0x10,%esp
f0106542:	85 c0                	test   %eax,%eax
f0106544:	78 27                	js     f010656d <spin_unlock+0xa7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106546:	8b 03                	mov    (%ebx),%eax
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106548:	83 ec 04             	sub    $0x4,%esp
f010654b:	89 c2                	mov    %eax,%edx
f010654d:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106550:	52                   	push   %edx
f0106551:	ff 75 d8             	pushl  -0x28(%ebp)
f0106554:	ff 75 dc             	pushl  -0x24(%ebp)
f0106557:	ff 75 d4             	pushl  -0x2c(%ebp)
f010655a:	ff 75 d0             	pushl  -0x30(%ebp)
f010655d:	50                   	push   %eax
f010655e:	68 dc 88 10 f0       	push   $0xf01088dc
f0106563:	e8 f5 d7 ff ff       	call   f0103d5d <cprintf>
f0106568:	83 c4 20             	add    $0x20,%esp
f010656b:	eb 12                	jmp    f010657f <spin_unlock+0xb9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010656d:	83 ec 08             	sub    $0x8,%esp
f0106570:	ff 33                	pushl  (%ebx)
f0106572:	68 f3 88 10 f0       	push   $0xf01088f3
f0106577:	e8 e1 d7 ff ff       	call   f0103d5d <cprintf>
f010657c:	83 c4 10             	add    $0x10,%esp
			
		cprintf("%u\n", lk->cpu->cpu_id);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
f010657f:	39 fb                	cmp    %edi,%ebx
f0106581:	74 0a                	je     f010658d <spin_unlock+0xc7>
f0106583:	8b 43 04             	mov    0x4(%ebx),%eax
f0106586:	83 c3 04             	add    $0x4,%ebx
f0106589:	85 c0                	test   %eax,%eax
f010658b:	75 a8                	jne    f0106535 <spin_unlock+0x6f>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010658d:	83 ec 04             	sub    $0x4,%esp
f0106590:	68 fb 88 10 f0       	push   $0xf01088fb
f0106595:	6a 6a                	push   $0x6a
f0106597:	68 cc 88 10 f0       	push   $0xf01088cc
f010659c:	e8 c7 9a ff ff       	call   f0100068 <_panic>
	}
	lk->pcs[0] = 0;
f01065a1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f01065a8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01065af:	b8 00 00 00 00       	mov    $0x0,%eax
f01065b4:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f01065b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01065ba:	5b                   	pop    %ebx
f01065bb:	5e                   	pop    %esi
f01065bc:	5f                   	pop    %edi
f01065bd:	c9                   	leave  
f01065be:	c3                   	ret    
	...

f01065c0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01065c0:	55                   	push   %ebp
f01065c1:	89 e5                	mov    %esp,%ebp
f01065c3:	57                   	push   %edi
f01065c4:	56                   	push   %esi
f01065c5:	83 ec 10             	sub    $0x10,%esp
f01065c8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01065cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01065ce:	89 7d f0             	mov    %edi,-0x10(%ebp)
f01065d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f01065d4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01065d7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01065da:	85 c0                	test   %eax,%eax
f01065dc:	75 2e                	jne    f010660c <__udivdi3+0x4c>
    {
      if (d0 > n1)
f01065de:	39 f1                	cmp    %esi,%ecx
f01065e0:	77 5a                	ja     f010663c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01065e2:	85 c9                	test   %ecx,%ecx
f01065e4:	75 0b                	jne    f01065f1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01065e6:	b8 01 00 00 00       	mov    $0x1,%eax
f01065eb:	31 d2                	xor    %edx,%edx
f01065ed:	f7 f1                	div    %ecx
f01065ef:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01065f1:	31 d2                	xor    %edx,%edx
f01065f3:	89 f0                	mov    %esi,%eax
f01065f5:	f7 f1                	div    %ecx
f01065f7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01065f9:	89 f8                	mov    %edi,%eax
f01065fb:	f7 f1                	div    %ecx
f01065fd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01065ff:	89 f8                	mov    %edi,%eax
f0106601:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106603:	83 c4 10             	add    $0x10,%esp
f0106606:	5e                   	pop    %esi
f0106607:	5f                   	pop    %edi
f0106608:	c9                   	leave  
f0106609:	c3                   	ret    
f010660a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010660c:	39 f0                	cmp    %esi,%eax
f010660e:	77 1c                	ja     f010662c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106610:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f0106613:	83 f7 1f             	xor    $0x1f,%edi
f0106616:	75 3c                	jne    f0106654 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106618:	39 f0                	cmp    %esi,%eax
f010661a:	0f 82 90 00 00 00    	jb     f01066b0 <__udivdi3+0xf0>
f0106620:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106623:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0106626:	0f 86 84 00 00 00    	jbe    f01066b0 <__udivdi3+0xf0>
f010662c:	31 f6                	xor    %esi,%esi
f010662e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106630:	89 f8                	mov    %edi,%eax
f0106632:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106634:	83 c4 10             	add    $0x10,%esp
f0106637:	5e                   	pop    %esi
f0106638:	5f                   	pop    %edi
f0106639:	c9                   	leave  
f010663a:	c3                   	ret    
f010663b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010663c:	89 f2                	mov    %esi,%edx
f010663e:	89 f8                	mov    %edi,%eax
f0106640:	f7 f1                	div    %ecx
f0106642:	89 c7                	mov    %eax,%edi
f0106644:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106646:	89 f8                	mov    %edi,%eax
f0106648:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010664a:	83 c4 10             	add    $0x10,%esp
f010664d:	5e                   	pop    %esi
f010664e:	5f                   	pop    %edi
f010664f:	c9                   	leave  
f0106650:	c3                   	ret    
f0106651:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106654:	89 f9                	mov    %edi,%ecx
f0106656:	d3 e0                	shl    %cl,%eax
f0106658:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010665b:	b8 20 00 00 00       	mov    $0x20,%eax
f0106660:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0106662:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106665:	88 c1                	mov    %al,%cl
f0106667:	d3 ea                	shr    %cl,%edx
f0106669:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010666c:	09 ca                	or     %ecx,%edx
f010666e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0106671:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106674:	89 f9                	mov    %edi,%ecx
f0106676:	d3 e2                	shl    %cl,%edx
f0106678:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f010667b:	89 f2                	mov    %esi,%edx
f010667d:	88 c1                	mov    %al,%cl
f010667f:	d3 ea                	shr    %cl,%edx
f0106681:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0106684:	89 f2                	mov    %esi,%edx
f0106686:	89 f9                	mov    %edi,%ecx
f0106688:	d3 e2                	shl    %cl,%edx
f010668a:	8b 75 f0             	mov    -0x10(%ebp),%esi
f010668d:	88 c1                	mov    %al,%cl
f010668f:	d3 ee                	shr    %cl,%esi
f0106691:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106693:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0106696:	89 f0                	mov    %esi,%eax
f0106698:	89 ca                	mov    %ecx,%edx
f010669a:	f7 75 ec             	divl   -0x14(%ebp)
f010669d:	89 d1                	mov    %edx,%ecx
f010669f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01066a1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01066a4:	39 d1                	cmp    %edx,%ecx
f01066a6:	72 28                	jb     f01066d0 <__udivdi3+0x110>
f01066a8:	74 1a                	je     f01066c4 <__udivdi3+0x104>
f01066aa:	89 f7                	mov    %esi,%edi
f01066ac:	31 f6                	xor    %esi,%esi
f01066ae:	eb 80                	jmp    f0106630 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01066b0:	31 f6                	xor    %esi,%esi
f01066b2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01066b7:	89 f8                	mov    %edi,%eax
f01066b9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01066bb:	83 c4 10             	add    $0x10,%esp
f01066be:	5e                   	pop    %esi
f01066bf:	5f                   	pop    %edi
f01066c0:	c9                   	leave  
f01066c1:	c3                   	ret    
f01066c2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01066c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01066c7:	89 f9                	mov    %edi,%ecx
f01066c9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01066cb:	39 c2                	cmp    %eax,%edx
f01066cd:	73 db                	jae    f01066aa <__udivdi3+0xea>
f01066cf:	90                   	nop
		{
		  q0--;
f01066d0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01066d3:	31 f6                	xor    %esi,%esi
f01066d5:	e9 56 ff ff ff       	jmp    f0106630 <__udivdi3+0x70>
	...

f01066dc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f01066dc:	55                   	push   %ebp
f01066dd:	89 e5                	mov    %esp,%ebp
f01066df:	57                   	push   %edi
f01066e0:	56                   	push   %esi
f01066e1:	83 ec 20             	sub    $0x20,%esp
f01066e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01066e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01066ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01066ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f01066f0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01066f3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f01066f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f01066f9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01066fb:	85 ff                	test   %edi,%edi
f01066fd:	75 15                	jne    f0106714 <__umoddi3+0x38>
    {
      if (d0 > n1)
f01066ff:	39 f1                	cmp    %esi,%ecx
f0106701:	0f 86 99 00 00 00    	jbe    f01067a0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106707:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0106709:	89 d0                	mov    %edx,%eax
f010670b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f010670d:	83 c4 20             	add    $0x20,%esp
f0106710:	5e                   	pop    %esi
f0106711:	5f                   	pop    %edi
f0106712:	c9                   	leave  
f0106713:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106714:	39 f7                	cmp    %esi,%edi
f0106716:	0f 87 a4 00 00 00    	ja     f01067c0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f010671c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f010671f:	83 f0 1f             	xor    $0x1f,%eax
f0106722:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106725:	0f 84 a1 00 00 00    	je     f01067cc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f010672b:	89 f8                	mov    %edi,%eax
f010672d:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0106730:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0106732:	bf 20 00 00 00       	mov    $0x20,%edi
f0106737:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f010673a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010673d:	89 f9                	mov    %edi,%ecx
f010673f:	d3 ea                	shr    %cl,%edx
f0106741:	09 c2                	or     %eax,%edx
f0106743:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0106746:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106749:	8a 4d ec             	mov    -0x14(%ebp),%cl
f010674c:	d3 e0                	shl    %cl,%eax
f010674e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106751:	89 f2                	mov    %esi,%edx
f0106753:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0106755:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106758:	d3 e0                	shl    %cl,%eax
f010675a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f010675d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106760:	89 f9                	mov    %edi,%ecx
f0106762:	d3 e8                	shr    %cl,%eax
f0106764:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0106766:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106768:	89 f2                	mov    %esi,%edx
f010676a:	f7 75 f0             	divl   -0x10(%ebp)
f010676d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f010676f:	f7 65 f4             	mull   -0xc(%ebp)
f0106772:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0106775:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106777:	39 d6                	cmp    %edx,%esi
f0106779:	72 71                	jb     f01067ec <__umoddi3+0x110>
f010677b:	74 7f                	je     f01067fc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f010677d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106780:	29 c8                	sub    %ecx,%eax
f0106782:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0106784:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0106787:	d3 e8                	shr    %cl,%eax
f0106789:	89 f2                	mov    %esi,%edx
f010678b:	89 f9                	mov    %edi,%ecx
f010678d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f010678f:	09 d0                	or     %edx,%eax
f0106791:	89 f2                	mov    %esi,%edx
f0106793:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0106796:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106798:	83 c4 20             	add    $0x20,%esp
f010679b:	5e                   	pop    %esi
f010679c:	5f                   	pop    %edi
f010679d:	c9                   	leave  
f010679e:	c3                   	ret    
f010679f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01067a0:	85 c9                	test   %ecx,%ecx
f01067a2:	75 0b                	jne    f01067af <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01067a4:	b8 01 00 00 00       	mov    $0x1,%eax
f01067a9:	31 d2                	xor    %edx,%edx
f01067ab:	f7 f1                	div    %ecx
f01067ad:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01067af:	89 f0                	mov    %esi,%eax
f01067b1:	31 d2                	xor    %edx,%edx
f01067b3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01067b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01067b8:	f7 f1                	div    %ecx
f01067ba:	e9 4a ff ff ff       	jmp    f0106709 <__umoddi3+0x2d>
f01067bf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f01067c0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01067c2:	83 c4 20             	add    $0x20,%esp
f01067c5:	5e                   	pop    %esi
f01067c6:	5f                   	pop    %edi
f01067c7:	c9                   	leave  
f01067c8:	c3                   	ret    
f01067c9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01067cc:	39 f7                	cmp    %esi,%edi
f01067ce:	72 05                	jb     f01067d5 <__umoddi3+0xf9>
f01067d0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f01067d3:	77 0c                	ja     f01067e1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01067d5:	89 f2                	mov    %esi,%edx
f01067d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01067da:	29 c8                	sub    %ecx,%eax
f01067dc:	19 fa                	sbb    %edi,%edx
f01067de:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f01067e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01067e4:	83 c4 20             	add    $0x20,%esp
f01067e7:	5e                   	pop    %esi
f01067e8:	5f                   	pop    %edi
f01067e9:	c9                   	leave  
f01067ea:	c3                   	ret    
f01067eb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01067ec:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01067ef:	89 c1                	mov    %eax,%ecx
f01067f1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f01067f4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f01067f7:	eb 84                	jmp    f010677d <__umoddi3+0xa1>
f01067f9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01067fc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f01067ff:	72 eb                	jb     f01067ec <__umoddi3+0x110>
f0106801:	89 f2                	mov    %esi,%edx
f0106803:	e9 75 ff ff ff       	jmp    f010677d <__umoddi3+0xa1>
