
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
f0100084:	e8 f7 5d 00 00       	call   f0105e80 <cpunum>
f0100089:	ff 75 0c             	pushl  0xc(%ebp)
f010008c:	ff 75 08             	pushl  0x8(%ebp)
f010008f:	50                   	push   %eax
f0100090:	68 40 65 10 f0       	push   $0xf0106540
f0100095:	e8 bb 3c 00 00       	call   f0103d55 <cprintf>
	vcprintf(fmt, ap);
f010009a:	83 c4 08             	add    $0x8,%esp
f010009d:	53                   	push   %ebx
f010009e:	56                   	push   %esi
f010009f:	e8 8b 3c 00 00       	call   f0103d2f <vcprintf>
	cprintf("\n");
f01000a4:	c7 04 24 af 68 10 f0 	movl   $0xf01068af,(%esp)
f01000ab:	e8 a5 3c 00 00       	call   f0103d55 <cprintf>
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
f01000d5:	68 64 65 10 f0       	push   $0xf0106564
f01000da:	68 80 00 00 00       	push   $0x80
f01000df:	68 ab 65 10 f0       	push   $0xf01065ab
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
f01000f1:	e8 8a 5d 00 00       	call   f0105e80 <cpunum>
f01000f6:	83 ec 08             	sub    $0x8,%esp
f01000f9:	50                   	push   %eax
f01000fa:	68 b7 65 10 f0       	push   $0xf01065b7
f01000ff:	e8 51 3c 00 00       	call   f0103d55 <cprintf>

	lapic_init();
f0100104:	e8 92 5d 00 00       	call   f0105e9b <lapic_init>
	env_init_percpu();
f0100109:	e8 c6 33 00 00       	call   f01034d4 <env_init_percpu>
	trap_init_percpu();
f010010e:	e8 59 3c 00 00       	call   f0103d6c <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100113:	e8 68 5d 00 00       	call   f0105e80 <cpunum>
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
f0100134:	c7 04 24 40 84 12 f0 	movl   $0xf0128440,(%esp)
f010013b:	e8 f7 5f 00 00       	call   f0106137 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100140:	e8 ca 45 00 00       	call   f010470f <sched_yield>

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
f0100151:	2d 78 4b 2e f0       	sub    $0xf02e4b78,%eax
f0100156:	50                   	push   %eax
f0100157:	6a 00                	push   $0x0
f0100159:	68 78 4b 2e f0       	push   $0xf02e4b78
f010015e:	e8 ee 56 00 00       	call   f0105851 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100163:	e8 3b 05 00 00       	call   f01006a3 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100168:	83 c4 08             	add    $0x8,%esp
f010016b:	68 ac 1a 00 00       	push   $0x1aac
f0100170:	68 cd 65 10 f0       	push   $0xf01065cd
f0100175:	e8 db 3b 00 00       	call   f0103d55 <cprintf>

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
f0100189:	e8 e3 3c 00 00       	call   f0103e71 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010018e:	e8 03 5a 00 00       	call   f0105b96 <mp_init>
	lapic_init();
f0100193:	e8 03 5d 00 00       	call   f0105e9b <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100198:	e8 19 3b 00 00       	call   f0103cb6 <pic_init>
f010019d:	c7 04 24 40 84 12 f0 	movl   $0xf0128440,(%esp)
f01001a4:	e8 8e 5f 00 00       	call   f0106137 <spin_lock>
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
f01001ba:	68 88 65 10 f0       	push   $0xf0106588
f01001bf:	6a 69                	push   $0x69
f01001c1:	68 ab 65 10 f0       	push   $0xf01065ab
f01001c6:	e8 9d fe ff ff       	call   f0100068 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001cb:	83 ec 04             	sub    $0x4,%esp
f01001ce:	b8 d2 5a 10 f0       	mov    $0xf0105ad2,%eax
f01001d3:	2d 58 5a 10 f0       	sub    $0xf0105a58,%eax
f01001d8:	50                   	push   %eax
f01001d9:	68 58 5a 10 f0       	push   $0xf0105a58
f01001de:	68 00 70 00 f0       	push   $0xf0007000
f01001e3:	e8 b3 56 00 00       	call   f010589b <memmove>

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
f0100213:	e8 68 5c 00 00       	call   f0105e80 <cpunum>
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
f0100270:	e8 82 5d 00 00       	call   f0105ff7 <lapic_startap>
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
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01002a3:	83 ec 04             	sub    $0x4,%esp
f01002a6:	6a 00                	push   $0x0
f01002a8:	68 4c fa 00 00       	push   $0xfa4c
f01002ad:	68 04 77 29 f0       	push   $0xf0297704
f01002b2:	e8 6b 34 00 00       	call   f0103722 <env_create>
	// ENV_CREATE(user_forktree, ENV_TYPE_USER);
	// ENV_CREATE(user_forktree, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01002b7:	e8 53 44 00 00       	call   f010470f <sched_yield>

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
f01002cc:	68 e8 65 10 f0       	push   $0xf01065e8
f01002d1:	e8 7f 3a 00 00       	call   f0103d55 <cprintf>
	vcprintf(fmt, ap);
f01002d6:	83 c4 08             	add    $0x8,%esp
f01002d9:	53                   	push   %ebx
f01002da:	ff 75 10             	pushl  0x10(%ebp)
f01002dd:	e8 4d 3a 00 00       	call   f0103d2f <vcprintf>
	cprintf("\n");
f01002e2:	c7 04 24 af 68 10 f0 	movl   $0xf01068af,(%esp)
f01002e9:	e8 67 3a 00 00       	call   f0103d55 <cprintf>
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
f01004d9:	e8 bd 53 00 00       	call   f010589b <memmove>
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
f0100578:	8a 82 40 66 10 f0    	mov    -0xfef99c0(%edx),%al
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
f01005b4:	0f b6 82 40 66 10 f0 	movzbl -0xfef99c0(%edx),%eax
f01005bb:	0b 05 28 52 2e f0    	or     0xf02e5228,%eax
	shift ^= togglecode[data];
f01005c1:	0f b6 8a 40 67 10 f0 	movzbl -0xfef98c0(%edx),%ecx
f01005c8:	31 c8                	xor    %ecx,%eax
f01005ca:	a3 28 52 2e f0       	mov    %eax,0xf02e5228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005cf:	89 c1                	mov    %eax,%ecx
f01005d1:	83 e1 03             	and    $0x3,%ecx
f01005d4:	8b 0c 8d 40 68 10 f0 	mov    -0xfef97c0(,%ecx,4),%ecx
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
f010060c:	68 02 66 10 f0       	push   $0xf0106602
f0100611:	e8 3f 37 00 00       	call   f0103d55 <cprintf>
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
f0100735:	e8 02 35 00 00       	call   f0103c3c <irq_setmask_8259A>
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
f010078a:	68 0e 66 10 f0       	push   $0xf010660e
f010078f:	e8 c1 35 00 00       	call   f0103d55 <cprintf>
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
f01007d2:	68 50 68 10 f0       	push   $0xf0106850
f01007d7:	e8 79 35 00 00       	call   f0103d55 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007dc:	83 c4 08             	add    $0x8,%esp
f01007df:	68 0c 00 10 00       	push   $0x10000c
f01007e4:	68 7c 6a 10 f0       	push   $0xf0106a7c
f01007e9:	e8 67 35 00 00       	call   f0103d55 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007ee:	83 c4 0c             	add    $0xc,%esp
f01007f1:	68 0c 00 10 00       	push   $0x10000c
f01007f6:	68 0c 00 10 f0       	push   $0xf010000c
f01007fb:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0100800:	e8 50 35 00 00       	call   f0103d55 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100805:	83 c4 0c             	add    $0xc,%esp
f0100808:	68 34 65 10 00       	push   $0x106534
f010080d:	68 34 65 10 f0       	push   $0xf0106534
f0100812:	68 c8 6a 10 f0       	push   $0xf0106ac8
f0100817:	e8 39 35 00 00       	call   f0103d55 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010081c:	83 c4 0c             	add    $0xc,%esp
f010081f:	68 78 4b 2e 00       	push   $0x2e4b78
f0100824:	68 78 4b 2e f0       	push   $0xf02e4b78
f0100829:	68 ec 6a 10 f0       	push   $0xf0106aec
f010082e:	e8 22 35 00 00       	call   f0103d55 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100833:	83 c4 0c             	add    $0xc,%esp
f0100836:	68 08 70 32 00       	push   $0x327008
f010083b:	68 08 70 32 f0       	push   $0xf0327008
f0100840:	68 10 6b 10 f0       	push   $0xf0106b10
f0100845:	e8 0b 35 00 00       	call   f0103d55 <cprintf>
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
f010086c:	68 34 6b 10 f0       	push   $0xf0106b34
f0100871:	e8 df 34 00 00       	call   f0103d55 <cprintf>
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
f010088c:	ff b3 c4 6f 10 f0    	pushl  -0xfef903c(%ebx)
f0100892:	ff b3 c0 6f 10 f0    	pushl  -0xfef9040(%ebx)
f0100898:	68 69 68 10 f0       	push   $0xf0106869
f010089d:	e8 b3 34 00 00       	call   f0103d55 <cprintf>
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
f01008c7:	68 60 6b 10 f0       	push   $0xf0106b60
f01008cc:	e8 84 34 00 00       	call   f0103d55 <cprintf>

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
f01008e5:	68 72 68 10 f0       	push   $0xf0106872
f01008ea:	e8 66 34 00 00       	call   f0103d55 <cprintf>
    env_run(curenv);
f01008ef:	e8 8c 55 00 00       	call   f0105e80 <cpunum>
f01008f4:	83 c4 04             	add    $0x4,%esp
f01008f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01008fa:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f0100900:	e8 ec 31 00 00       	call   f0103af1 <env_run>

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
f0100915:	68 8c 6b 10 f0       	push   $0xf0106b8c
f010091a:	e8 36 34 00 00       	call   f0103d55 <cprintf>
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
f010092d:	e8 4e 55 00 00       	call   f0105e80 <cpunum>
f0100932:	83 ec 0c             	sub    $0xc,%esp
f0100935:	6b c0 74             	imul   $0x74,%eax,%eax
f0100938:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f010093e:	e8 ae 31 00 00       	call   f0103af1 <env_run>

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
f0100958:	68 c0 6b 10 f0       	push   $0xf0106bc0
f010095d:	e8 f3 33 00 00       	call   f0103d55 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f0100962:	c7 04 24 f4 6b 10 f0 	movl   $0xf0106bf4,(%esp)
f0100969:	e8 e7 33 00 00       	call   f0103d55 <cprintf>
f010096e:	83 c4 10             	add    $0x10,%esp
f0100971:	e9 1a 01 00 00       	jmp    f0100a90 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f0100976:	83 ec 04             	sub    $0x4,%esp
f0100979:	6a 00                	push   $0x0
f010097b:	6a 00                	push   $0x0
f010097d:	ff 76 04             	pushl  0x4(%esi)
f0100980:	e8 05 50 00 00       	call   f010598a <strtol>
f0100985:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f0100987:	83 c4 0c             	add    $0xc,%esp
f010098a:	6a 00                	push   $0x0
f010098c:	6a 00                	push   $0x0
f010098e:	ff 76 08             	pushl  0x8(%esi)
f0100991:	e8 f4 4f 00 00       	call   f010598a <strtol>
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
f01009b5:	68 7c 68 10 f0       	push   $0xf010687c
f01009ba:	e8 96 33 00 00       	call   f0103d55 <cprintf>
        
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
f01009d8:	68 8d 68 10 f0       	push   $0xf010688d
f01009dd:	e8 73 33 00 00       	call   f0103d55 <cprintf>
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
f0100a05:	68 a4 68 10 f0       	push   $0xf01068a4
f0100a0a:	e8 46 33 00 00       	call   f0103d55 <cprintf>
f0100a0f:	83 c4 10             	add    $0x10,%esp
f0100a12:	eb 74                	jmp    f0100a88 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f0100a14:	83 ec 08             	sub    $0x8,%esp
f0100a17:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a1c:	50                   	push   %eax
f0100a1d:	68 b1 68 10 f0       	push   $0xf01068b1
f0100a22:	e8 2e 33 00 00       	call   f0103d55 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f0100a27:	83 c4 10             	add    $0x10,%esp
f0100a2a:	f6 03 04             	testb  $0x4,(%ebx)
f0100a2d:	74 12                	je     f0100a41 <mon_showmappings+0xfe>
f0100a2f:	83 ec 0c             	sub    $0xc,%esp
f0100a32:	68 b9 68 10 f0       	push   $0xf01068b9
f0100a37:	e8 19 33 00 00       	call   f0103d55 <cprintf>
f0100a3c:	83 c4 10             	add    $0x10,%esp
f0100a3f:	eb 10                	jmp    f0100a51 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f0100a41:	83 ec 0c             	sub    $0xc,%esp
f0100a44:	68 c6 68 10 f0       	push   $0xf01068c6
f0100a49:	e8 07 33 00 00       	call   f0103d55 <cprintf>
f0100a4e:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f0100a51:	f6 03 02             	testb  $0x2,(%ebx)
f0100a54:	74 12                	je     f0100a68 <mon_showmappings+0x125>
f0100a56:	83 ec 0c             	sub    $0xc,%esp
f0100a59:	68 d3 68 10 f0       	push   $0xf01068d3
f0100a5e:	e8 f2 32 00 00       	call   f0103d55 <cprintf>
f0100a63:	83 c4 10             	add    $0x10,%esp
f0100a66:	eb 10                	jmp    f0100a78 <mon_showmappings+0x135>
                else cprintf(" R ");
f0100a68:	83 ec 0c             	sub    $0xc,%esp
f0100a6b:	68 d8 68 10 f0       	push   $0xf01068d8
f0100a70:	e8 e0 32 00 00       	call   f0103d55 <cprintf>
f0100a75:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f0100a78:	83 ec 0c             	sub    $0xc,%esp
f0100a7b:	68 af 68 10 f0       	push   $0xf01068af
f0100a80:	e8 d0 32 00 00       	call   f0103d55 <cprintf>
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
f0100ab2:	68 1c 6c 10 f0       	push   $0xf0106c1c
f0100ab7:	e8 99 32 00 00       	call   f0103d55 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f0100abc:	c7 04 24 6c 6c 10 f0 	movl   $0xf0106c6c,(%esp)
f0100ac3:	e8 8d 32 00 00       	call   f0103d55 <cprintf>
f0100ac8:	83 c4 10             	add    $0x10,%esp
f0100acb:	e9 a5 01 00 00       	jmp    f0100c75 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f0100ad0:	83 ec 04             	sub    $0x4,%esp
f0100ad3:	6a 00                	push   $0x0
f0100ad5:	6a 00                	push   $0x0
f0100ad7:	ff 73 04             	pushl  0x4(%ebx)
f0100ada:	e8 ab 4e 00 00       	call   f010598a <strtol>
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
f0100b3e:	68 90 6c 10 f0       	push   $0xf0106c90
f0100b43:	e8 0d 32 00 00       	call   f0103d55 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100b48:	83 c4 10             	add    $0x10,%esp
f0100b4b:	f6 03 02             	testb  $0x2,(%ebx)
f0100b4e:	74 12                	je     f0100b62 <mon_setpermission+0xc5>
f0100b50:	83 ec 0c             	sub    $0xc,%esp
f0100b53:	68 dc 68 10 f0       	push   $0xf01068dc
f0100b58:	e8 f8 31 00 00       	call   f0103d55 <cprintf>
f0100b5d:	83 c4 10             	add    $0x10,%esp
f0100b60:	eb 10                	jmp    f0100b72 <mon_setpermission+0xd5>
f0100b62:	83 ec 0c             	sub    $0xc,%esp
f0100b65:	68 df 68 10 f0       	push   $0xf01068df
f0100b6a:	e8 e6 31 00 00       	call   f0103d55 <cprintf>
f0100b6f:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100b72:	f6 03 04             	testb  $0x4,(%ebx)
f0100b75:	74 12                	je     f0100b89 <mon_setpermission+0xec>
f0100b77:	83 ec 0c             	sub    $0xc,%esp
f0100b7a:	68 23 7b 10 f0       	push   $0xf0107b23
f0100b7f:	e8 d1 31 00 00       	call   f0103d55 <cprintf>
f0100b84:	83 c4 10             	add    $0x10,%esp
f0100b87:	eb 10                	jmp    f0100b99 <mon_setpermission+0xfc>
f0100b89:	83 ec 0c             	sub    $0xc,%esp
f0100b8c:	68 50 7f 10 f0       	push   $0xf0107f50
f0100b91:	e8 bf 31 00 00       	call   f0103d55 <cprintf>
f0100b96:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100b99:	f6 03 01             	testb  $0x1,(%ebx)
f0100b9c:	74 12                	je     f0100bb0 <mon_setpermission+0x113>
f0100b9e:	83 ec 0c             	sub    $0xc,%esp
f0100ba1:	68 59 85 10 f0       	push   $0xf0108559
f0100ba6:	e8 aa 31 00 00       	call   f0103d55 <cprintf>
f0100bab:	83 c4 10             	add    $0x10,%esp
f0100bae:	eb 10                	jmp    f0100bc0 <mon_setpermission+0x123>
f0100bb0:	83 ec 0c             	sub    $0xc,%esp
f0100bb3:	68 e0 68 10 f0       	push   $0xf01068e0
f0100bb8:	e8 98 31 00 00       	call   f0103d55 <cprintf>
f0100bbd:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f0100bc0:	83 ec 0c             	sub    $0xc,%esp
f0100bc3:	68 e2 68 10 f0       	push   $0xf01068e2
f0100bc8:	e8 88 31 00 00       	call   f0103d55 <cprintf>
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
f0100be6:	68 dc 68 10 f0       	push   $0xf01068dc
f0100beb:	e8 65 31 00 00       	call   f0103d55 <cprintf>
f0100bf0:	83 c4 10             	add    $0x10,%esp
f0100bf3:	eb 10                	jmp    f0100c05 <mon_setpermission+0x168>
f0100bf5:	83 ec 0c             	sub    $0xc,%esp
f0100bf8:	68 df 68 10 f0       	push   $0xf01068df
f0100bfd:	e8 53 31 00 00       	call   f0103d55 <cprintf>
f0100c02:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100c05:	f6 03 04             	testb  $0x4,(%ebx)
f0100c08:	74 12                	je     f0100c1c <mon_setpermission+0x17f>
f0100c0a:	83 ec 0c             	sub    $0xc,%esp
f0100c0d:	68 23 7b 10 f0       	push   $0xf0107b23
f0100c12:	e8 3e 31 00 00       	call   f0103d55 <cprintf>
f0100c17:	83 c4 10             	add    $0x10,%esp
f0100c1a:	eb 10                	jmp    f0100c2c <mon_setpermission+0x18f>
f0100c1c:	83 ec 0c             	sub    $0xc,%esp
f0100c1f:	68 50 7f 10 f0       	push   $0xf0107f50
f0100c24:	e8 2c 31 00 00       	call   f0103d55 <cprintf>
f0100c29:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100c2c:	f6 03 01             	testb  $0x1,(%ebx)
f0100c2f:	74 12                	je     f0100c43 <mon_setpermission+0x1a6>
f0100c31:	83 ec 0c             	sub    $0xc,%esp
f0100c34:	68 59 85 10 f0       	push   $0xf0108559
f0100c39:	e8 17 31 00 00       	call   f0103d55 <cprintf>
f0100c3e:	83 c4 10             	add    $0x10,%esp
f0100c41:	eb 10                	jmp    f0100c53 <mon_setpermission+0x1b6>
f0100c43:	83 ec 0c             	sub    $0xc,%esp
f0100c46:	68 e0 68 10 f0       	push   $0xf01068e0
f0100c4b:	e8 05 31 00 00       	call   f0103d55 <cprintf>
f0100c50:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100c53:	83 ec 0c             	sub    $0xc,%esp
f0100c56:	68 af 68 10 f0       	push   $0xf01068af
f0100c5b:	e8 f5 30 00 00       	call   f0103d55 <cprintf>
f0100c60:	83 c4 10             	add    $0x10,%esp
f0100c63:	eb 10                	jmp    f0100c75 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100c65:	83 ec 0c             	sub    $0xc,%esp
f0100c68:	68 a4 68 10 f0       	push   $0xf01068a4
f0100c6d:	e8 e3 30 00 00       	call   f0103d55 <cprintf>
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
f0100c93:	68 b4 6c 10 f0       	push   $0xf0106cb4
f0100c98:	e8 b8 30 00 00       	call   f0103d55 <cprintf>
        cprintf("num show the color attribute. \n");
f0100c9d:	c7 04 24 e4 6c 10 f0 	movl   $0xf0106ce4,(%esp)
f0100ca4:	e8 ac 30 00 00       	call   f0103d55 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100ca9:	c7 04 24 04 6d 10 f0 	movl   $0xf0106d04,(%esp)
f0100cb0:	e8 a0 30 00 00       	call   f0103d55 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100cb5:	c7 04 24 38 6d 10 f0 	movl   $0xf0106d38,(%esp)
f0100cbc:	e8 94 30 00 00       	call   f0103d55 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100cc1:	c7 04 24 7c 6d 10 f0 	movl   $0xf0106d7c,(%esp)
f0100cc8:	e8 88 30 00 00       	call   f0103d55 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100ccd:	c7 04 24 f3 68 10 f0 	movl   $0xf01068f3,(%esp)
f0100cd4:	e8 7c 30 00 00       	call   f0103d55 <cprintf>
        cprintf("         set the background color to black\n");
f0100cd9:	c7 04 24 c0 6d 10 f0 	movl   $0xf0106dc0,(%esp)
f0100ce0:	e8 70 30 00 00       	call   f0103d55 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100ce5:	c7 04 24 ec 6d 10 f0 	movl   $0xf0106dec,(%esp)
f0100cec:	e8 64 30 00 00       	call   f0103d55 <cprintf>
f0100cf1:	83 c4 10             	add    $0x10,%esp
f0100cf4:	eb 52                	jmp    f0100d48 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100cf6:	83 ec 0c             	sub    $0xc,%esp
f0100cf9:	ff 73 04             	pushl  0x4(%ebx)
f0100cfc:	e8 87 49 00 00       	call   f0105688 <strlen>
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
f0100d3b:	68 20 6e 10 f0       	push   $0xf0106e20
f0100d40:	e8 10 30 00 00       	call   f0103d55 <cprintf>
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
f0100d7c:	68 44 6e 10 f0       	push   $0xf0106e44
f0100d81:	e8 cf 2f 00 00       	call   f0103d55 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100d86:	83 c4 18             	add    $0x18,%esp
f0100d89:	57                   	push   %edi
f0100d8a:	ff 76 04             	pushl  0x4(%esi)
f0100d8d:	e8 17 40 00 00       	call   f0104da9 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100d92:	83 c4 0c             	add    $0xc,%esp
f0100d95:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100d98:	ff 75 d0             	pushl  -0x30(%ebp)
f0100d9b:	68 0f 69 10 f0       	push   $0xf010690f
f0100da0:	e8 b0 2f 00 00       	call   f0103d55 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100da5:	83 c4 0c             	add    $0xc,%esp
f0100da8:	ff 75 d8             	pushl  -0x28(%ebp)
f0100dab:	ff 75 dc             	pushl  -0x24(%ebp)
f0100dae:	68 1f 69 10 f0       	push   $0xf010691f
f0100db3:	e8 9d 2f 00 00       	call   f0103d55 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100db8:	83 c4 08             	add    $0x8,%esp
f0100dbb:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100dbe:	53                   	push   %ebx
f0100dbf:	68 24 69 10 f0       	push   $0xf0106924
f0100dc4:	e8 8c 2f 00 00       	call   f0103d55 <cprintf>
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
f0100dfb:	68 64 65 10 f0       	push   $0xf0106564
f0100e00:	68 96 00 00 00       	push   $0x96
f0100e05:	68 29 69 10 f0       	push   $0xf0106929
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
f0100e3f:	68 64 65 10 f0       	push   $0xf0106564
f0100e44:	68 9b 00 00 00       	push   $0x9b
f0100e49:	68 29 69 10 f0       	push   $0xf0106929
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
f0100ea1:	68 7c 6e 10 f0       	push   $0xf0106e7c
f0100ea6:	e8 aa 2e 00 00       	call   f0103d55 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100eab:	c7 04 24 ac 6e 10 f0 	movl   $0xf0106eac,(%esp)
f0100eb2:	e8 9e 2e 00 00       	call   f0103d55 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100eb7:	c7 04 24 d4 6e 10 f0 	movl   $0xf0106ed4,(%esp)
f0100ebe:	e8 92 2e 00 00       	call   f0103d55 <cprintf>
f0100ec3:	83 c4 10             	add    $0x10,%esp
f0100ec6:	e9 59 01 00 00       	jmp    f0101024 <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100ecb:	83 ec 04             	sub    $0x4,%esp
f0100ece:	6a 00                	push   $0x0
f0100ed0:	6a 00                	push   $0x0
f0100ed2:	ff 76 08             	pushl  0x8(%esi)
f0100ed5:	e8 b0 4a 00 00       	call   f010598a <strtol>
f0100eda:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100edc:	83 c4 0c             	add    $0xc,%esp
f0100edf:	6a 00                	push   $0x0
f0100ee1:	6a 00                	push   $0x0
f0100ee3:	ff 76 0c             	pushl  0xc(%esi)
f0100ee6:	e8 9f 4a 00 00       	call   f010598a <strtol>
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
f0100f27:	68 af 68 10 f0       	push   $0xf01068af
f0100f2c:	e8 24 2e 00 00       	call   f0103d55 <cprintf>
f0100f31:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100f34:	83 ec 08             	sub    $0x8,%esp
f0100f37:	53                   	push   %ebx
f0100f38:	68 38 69 10 f0       	push   $0xf0106938
f0100f3d:	e8 13 2e 00 00       	call   f0103d55 <cprintf>
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
f0100f6e:	68 42 69 10 f0       	push   $0xf0106942
f0100f73:	e8 dd 2d 00 00       	call   f0103d55 <cprintf>
f0100f78:	83 c4 10             	add    $0x10,%esp
f0100f7b:	eb 10                	jmp    f0100f8d <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100f7d:	83 ec 0c             	sub    $0xc,%esp
f0100f80:	68 4d 69 10 f0       	push   $0xf010694d
f0100f85:	e8 cb 2d 00 00       	call   f0103d55 <cprintf>
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
f0100f98:	68 af 68 10 f0       	push   $0xf01068af
f0100f9d:	e8 b3 2d 00 00       	call   f0103d55 <cprintf>
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
f0100fb8:	68 af 68 10 f0       	push   $0xf01068af
f0100fbd:	e8 93 2d 00 00       	call   f0103d55 <cprintf>
f0100fc2:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100fc5:	83 ec 08             	sub    $0x8,%esp
f0100fc8:	53                   	push   %ebx
f0100fc9:	68 38 69 10 f0       	push   $0xf0106938
f0100fce:	e8 82 2d 00 00       	call   f0103d55 <cprintf>
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
f0100fed:	68 42 69 10 f0       	push   $0xf0106942
f0100ff2:	e8 5e 2d 00 00       	call   f0103d55 <cprintf>
f0100ff7:	83 c4 10             	add    $0x10,%esp
f0100ffa:	eb 10                	jmp    f010100c <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100ffc:	83 ec 0c             	sub    $0xc,%esp
f0100fff:	68 4b 69 10 f0       	push   $0xf010694b
f0101004:	e8 4c 2d 00 00       	call   f0103d55 <cprintf>
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
f0101017:	68 af 68 10 f0       	push   $0xf01068af
f010101c:	e8 34 2d 00 00       	call   f0103d55 <cprintf>
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
f010103a:	68 18 6f 10 f0       	push   $0xf0106f18
f010103f:	e8 11 2d 00 00       	call   f0103d55 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101044:	c7 04 24 3c 6f 10 f0 	movl   $0xf0106f3c,(%esp)
f010104b:	e8 05 2d 00 00       	call   f0103d55 <cprintf>

	if (tf != NULL)
f0101050:	83 c4 10             	add    $0x10,%esp
f0101053:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101057:	74 0e                	je     f0101067 <monitor+0x36>
		print_trapframe(tf);
f0101059:	83 ec 0c             	sub    $0xc,%esp
f010105c:	ff 75 08             	pushl  0x8(%ebp)
f010105f:	e8 4f 2f 00 00       	call   f0103fb3 <print_trapframe>
f0101064:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0101067:	83 ec 0c             	sub    $0xc,%esp
f010106a:	68 58 69 10 f0       	push   $0xf0106958
f010106f:	e8 44 45 00 00       	call   f01055b8 <readline>
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
f010109c:	68 5c 69 10 f0       	push   $0xf010695c
f01010a1:	e8 5b 47 00 00       	call   f0105801 <strchr>
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
f01010bc:	68 61 69 10 f0       	push   $0xf0106961
f01010c1:	e8 8f 2c 00 00       	call   f0103d55 <cprintf>
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
f01010e6:	68 5c 69 10 f0       	push   $0xf010695c
f01010eb:	e8 11 47 00 00       	call   f0105801 <strchr>
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
f0101109:	bb c0 6f 10 f0       	mov    $0xf0106fc0,%ebx
f010110e:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101113:	83 ec 08             	sub    $0x8,%esp
f0101116:	ff 33                	pushl  (%ebx)
f0101118:	ff 75 a8             	pushl  -0x58(%ebp)
f010111b:	e8 73 46 00 00       	call   f0105793 <strcmp>
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
f0101135:	ff 97 c8 6f 10 f0    	call   *-0xfef9038(%edi)
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
f0101156:	68 7e 69 10 f0       	push   $0xf010697e
f010115b:	e8 f5 2b 00 00       	call   f0103d55 <cprintf>
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
f01011cc:	68 88 65 10 f0       	push   $0xf0106588
f01011d1:	68 79 03 00 00       	push   $0x379
f01011d6:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101214:	e8 fb 29 00 00       	call   f0103c14 <mc146818_read>
f0101219:	89 c6                	mov    %eax,%esi
f010121b:	43                   	inc    %ebx
f010121c:	89 1c 24             	mov    %ebx,(%esp)
f010121f:	e8 f0 29 00 00       	call   f0103c14 <mc146818_read>
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
f0101251:	68 2c 70 10 f0       	push   $0xf010702c
f0101256:	68 ae 02 00 00       	push   $0x2ae
f010125b:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01012de:	68 88 65 10 f0       	push   $0xf0106588
f01012e3:	6a 58                	push   $0x58
f01012e5:	68 fd 78 10 f0       	push   $0xf01078fd
f01012ea:	e8 79 ed ff ff       	call   f0100068 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01012ef:	83 ec 04             	sub    $0x4,%esp
f01012f2:	68 80 00 00 00       	push   $0x80
f01012f7:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01012fc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101301:	50                   	push   %eax
f0101302:	e8 4a 45 00 00       	call   f0105851 <memset>
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
f0101380:	68 0b 79 10 f0       	push   $0xf010790b
f0101385:	68 17 79 10 f0       	push   $0xf0107917
f010138a:	68 c8 02 00 00       	push   $0x2c8
f010138f:	68 f1 78 10 f0       	push   $0xf01078f1
f0101394:	e8 cf ec ff ff       	call   f0100068 <_panic>
		assert(pp < pages + npages);
f0101399:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f010139c:	72 19                	jb     f01013b7 <check_page_free_list+0x187>
f010139e:	68 2c 79 10 f0       	push   $0xf010792c
f01013a3:	68 17 79 10 f0       	push   $0xf0107917
f01013a8:	68 c9 02 00 00       	push   $0x2c9
f01013ad:	68 f1 78 10 f0       	push   $0xf01078f1
f01013b2:	e8 b1 ec ff ff       	call   f0100068 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01013b7:	89 d0                	mov    %edx,%eax
f01013b9:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01013bc:	a8 07                	test   $0x7,%al
f01013be:	74 19                	je     f01013d9 <check_page_free_list+0x1a9>
f01013c0:	68 50 70 10 f0       	push   $0xf0107050
f01013c5:	68 17 79 10 f0       	push   $0xf0107917
f01013ca:	68 ca 02 00 00       	push   $0x2ca
f01013cf:	68 f1 78 10 f0       	push   $0xf01078f1
f01013d4:	e8 8f ec ff ff       	call   f0100068 <_panic>
f01013d9:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01013dc:	c1 e0 0c             	shl    $0xc,%eax
f01013df:	75 19                	jne    f01013fa <check_page_free_list+0x1ca>
f01013e1:	68 40 79 10 f0       	push   $0xf0107940
f01013e6:	68 17 79 10 f0       	push   $0xf0107917
f01013eb:	68 cd 02 00 00       	push   $0x2cd
f01013f0:	68 f1 78 10 f0       	push   $0xf01078f1
f01013f5:	e8 6e ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01013fa:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01013ff:	75 19                	jne    f010141a <check_page_free_list+0x1ea>
f0101401:	68 51 79 10 f0       	push   $0xf0107951
f0101406:	68 17 79 10 f0       	push   $0xf0107917
f010140b:	68 ce 02 00 00       	push   $0x2ce
f0101410:	68 f1 78 10 f0       	push   $0xf01078f1
f0101415:	e8 4e ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010141a:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010141f:	75 19                	jne    f010143a <check_page_free_list+0x20a>
f0101421:	68 84 70 10 f0       	push   $0xf0107084
f0101426:	68 17 79 10 f0       	push   $0xf0107917
f010142b:	68 cf 02 00 00       	push   $0x2cf
f0101430:	68 f1 78 10 f0       	push   $0xf01078f1
f0101435:	e8 2e ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010143a:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010143f:	75 19                	jne    f010145a <check_page_free_list+0x22a>
f0101441:	68 6a 79 10 f0       	push   $0xf010796a
f0101446:	68 17 79 10 f0       	push   $0xf0107917
f010144b:	68 d0 02 00 00       	push   $0x2d0
f0101450:	68 f1 78 10 f0       	push   $0xf01078f1
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
f010146e:	68 88 65 10 f0       	push   $0xf0106588
f0101473:	6a 58                	push   $0x58
f0101475:	68 fd 78 10 f0       	push   $0xf01078fd
f010147a:	e8 e9 eb ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f010147f:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0101485:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0101488:	76 19                	jbe    f01014a3 <check_page_free_list+0x273>
f010148a:	68 a8 70 10 f0       	push   $0xf01070a8
f010148f:	68 17 79 10 f0       	push   $0xf0107917
f0101494:	68 d1 02 00 00       	push   $0x2d1
f0101499:	68 f1 78 10 f0       	push   $0xf01078f1
f010149e:	e8 c5 eb ff ff       	call   f0100068 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01014a3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01014a8:	75 19                	jne    f01014c3 <check_page_free_list+0x293>
f01014aa:	68 84 79 10 f0       	push   $0xf0107984
f01014af:	68 17 79 10 f0       	push   $0xf0107917
f01014b4:	68 d3 02 00 00       	push   $0x2d3
f01014b9:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01014dd:	68 a1 79 10 f0       	push   $0xf01079a1
f01014e2:	68 17 79 10 f0       	push   $0xf0107917
f01014e7:	68 db 02 00 00       	push   $0x2db
f01014ec:	68 f1 78 10 f0       	push   $0xf01078f1
f01014f1:	e8 72 eb ff ff       	call   f0100068 <_panic>
	assert(nfree_extmem > 0);
f01014f6:	85 f6                	test   %esi,%esi
f01014f8:	7f 19                	jg     f0101513 <check_page_free_list+0x2e3>
f01014fa:	68 b3 79 10 f0       	push   $0xf01079b3
f01014ff:	68 17 79 10 f0       	push   $0xf0107917
f0101504:	68 dc 02 00 00       	push   $0x2dc
f0101509:	68 f1 78 10 f0       	push   $0xf01078f1
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
f010153c:	68 64 65 10 f0       	push   $0xf0106564
f0101541:	68 50 01 00 00       	push   $0x150
f0101546:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101618:	68 88 65 10 f0       	push   $0xf0106588
f010161d:	6a 58                	push   $0x58
f010161f:	68 fd 78 10 f0       	push   $0xf01078fd
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
f0101639:	e8 13 42 00 00       	call   f0105851 <memset>
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
f01016f3:	68 88 65 10 f0       	push   $0xf0106588
f01016f8:	68 b4 01 00 00       	push   $0x1b4
f01016fd:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01017b6:	68 f0 70 10 f0       	push   $0xf01070f0
f01017bb:	6a 51                	push   $0x51
f01017bd:	68 fd 78 10 f0       	push   $0xf01078fd
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
f01017e9:	e8 92 46 00 00       	call   f0105e80 <cpunum>
f01017ee:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01017f5:	29 c2                	sub    %eax,%edx
f01017f7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01017fa:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f0101801:	00 
f0101802:	74 20                	je     f0101824 <tlb_invalidate+0x41>
f0101804:	e8 77 46 00 00       	call   f0105e80 <cpunum>
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
f01019ad:	68 10 71 10 f0       	push   $0xf0107110
f01019b2:	e8 9e 23 00 00       	call   f0103d55 <cprintf>
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
f01019d1:	e8 7b 3e 00 00       	call   f0105851 <memset>
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
f01019e6:	68 64 65 10 f0       	push   $0xf0106564
f01019eb:	68 90 00 00 00       	push   $0x90
f01019f0:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101a45:	68 c4 79 10 f0       	push   $0xf01079c4
f0101a4a:	68 ed 02 00 00       	push   $0x2ed
f0101a4f:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101a88:	68 df 79 10 f0       	push   $0xf01079df
f0101a8d:	68 17 79 10 f0       	push   $0xf0107917
f0101a92:	68 f5 02 00 00       	push   $0x2f5
f0101a97:	68 f1 78 10 f0       	push   $0xf01078f1
f0101a9c:	e8 c7 e5 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101aa1:	83 ec 0c             	sub    $0xc,%esp
f0101aa4:	6a 00                	push   $0x0
f0101aa6:	e8 22 fb ff ff       	call   f01015cd <page_alloc>
f0101aab:	89 c7                	mov    %eax,%edi
f0101aad:	83 c4 10             	add    $0x10,%esp
f0101ab0:	85 c0                	test   %eax,%eax
f0101ab2:	75 19                	jne    f0101acd <mem_init+0x1a4>
f0101ab4:	68 f5 79 10 f0       	push   $0xf01079f5
f0101ab9:	68 17 79 10 f0       	push   $0xf0107917
f0101abe:	68 f6 02 00 00       	push   $0x2f6
f0101ac3:	68 f1 78 10 f0       	push   $0xf01078f1
f0101ac8:	e8 9b e5 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101acd:	83 ec 0c             	sub    $0xc,%esp
f0101ad0:	6a 00                	push   $0x0
f0101ad2:	e8 f6 fa ff ff       	call   f01015cd <page_alloc>
f0101ad7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ada:	83 c4 10             	add    $0x10,%esp
f0101add:	85 c0                	test   %eax,%eax
f0101adf:	75 19                	jne    f0101afa <mem_init+0x1d1>
f0101ae1:	68 0b 7a 10 f0       	push   $0xf0107a0b
f0101ae6:	68 17 79 10 f0       	push   $0xf0107917
f0101aeb:	68 f7 02 00 00       	push   $0x2f7
f0101af0:	68 f1 78 10 f0       	push   $0xf01078f1
f0101af5:	e8 6e e5 ff ff       	call   f0100068 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101afa:	39 fe                	cmp    %edi,%esi
f0101afc:	75 19                	jne    f0101b17 <mem_init+0x1ee>
f0101afe:	68 21 7a 10 f0       	push   $0xf0107a21
f0101b03:	68 17 79 10 f0       	push   $0xf0107917
f0101b08:	68 fa 02 00 00       	push   $0x2fa
f0101b0d:	68 f1 78 10 f0       	push   $0xf01078f1
f0101b12:	e8 51 e5 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b17:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101b1a:	74 05                	je     f0101b21 <mem_init+0x1f8>
f0101b1c:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101b1f:	75 19                	jne    f0101b3a <mem_init+0x211>
f0101b21:	68 4c 71 10 f0       	push   $0xf010714c
f0101b26:	68 17 79 10 f0       	push   $0xf0107917
f0101b2b:	68 fb 02 00 00       	push   $0x2fb
f0101b30:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101b56:	68 33 7a 10 f0       	push   $0xf0107a33
f0101b5b:	68 17 79 10 f0       	push   $0xf0107917
f0101b60:	68 fc 02 00 00       	push   $0x2fc
f0101b65:	68 f1 78 10 f0       	push   $0xf01078f1
f0101b6a:	e8 f9 e4 ff ff       	call   f0100068 <_panic>
f0101b6f:	89 f9                	mov    %edi,%ecx
f0101b71:	29 d1                	sub    %edx,%ecx
f0101b73:	c1 f9 03             	sar    $0x3,%ecx
f0101b76:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101b79:	39 c8                	cmp    %ecx,%eax
f0101b7b:	77 19                	ja     f0101b96 <mem_init+0x26d>
f0101b7d:	68 50 7a 10 f0       	push   $0xf0107a50
f0101b82:	68 17 79 10 f0       	push   $0xf0107917
f0101b87:	68 fd 02 00 00       	push   $0x2fd
f0101b8c:	68 f1 78 10 f0       	push   $0xf01078f1
f0101b91:	e8 d2 e4 ff ff       	call   f0100068 <_panic>
f0101b96:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b99:	29 d1                	sub    %edx,%ecx
f0101b9b:	89 ca                	mov    %ecx,%edx
f0101b9d:	c1 fa 03             	sar    $0x3,%edx
f0101ba0:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101ba3:	39 d0                	cmp    %edx,%eax
f0101ba5:	77 19                	ja     f0101bc0 <mem_init+0x297>
f0101ba7:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101bac:	68 17 79 10 f0       	push   $0xf0107917
f0101bb1:	68 fe 02 00 00       	push   $0x2fe
f0101bb6:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101be3:	68 8a 7a 10 f0       	push   $0xf0107a8a
f0101be8:	68 17 79 10 f0       	push   $0xf0107917
f0101bed:	68 05 03 00 00       	push   $0x305
f0101bf2:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101c2d:	68 df 79 10 f0       	push   $0xf01079df
f0101c32:	68 17 79 10 f0       	push   $0xf0107917
f0101c37:	68 0c 03 00 00       	push   $0x30c
f0101c3c:	68 f1 78 10 f0       	push   $0xf01078f1
f0101c41:	e8 22 e4 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c46:	83 ec 0c             	sub    $0xc,%esp
f0101c49:	6a 00                	push   $0x0
f0101c4b:	e8 7d f9 ff ff       	call   f01015cd <page_alloc>
f0101c50:	89 c7                	mov    %eax,%edi
f0101c52:	83 c4 10             	add    $0x10,%esp
f0101c55:	85 c0                	test   %eax,%eax
f0101c57:	75 19                	jne    f0101c72 <mem_init+0x349>
f0101c59:	68 f5 79 10 f0       	push   $0xf01079f5
f0101c5e:	68 17 79 10 f0       	push   $0xf0107917
f0101c63:	68 0d 03 00 00       	push   $0x30d
f0101c68:	68 f1 78 10 f0       	push   $0xf01078f1
f0101c6d:	e8 f6 e3 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c72:	83 ec 0c             	sub    $0xc,%esp
f0101c75:	6a 00                	push   $0x0
f0101c77:	e8 51 f9 ff ff       	call   f01015cd <page_alloc>
f0101c7c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c7f:	83 c4 10             	add    $0x10,%esp
f0101c82:	85 c0                	test   %eax,%eax
f0101c84:	75 19                	jne    f0101c9f <mem_init+0x376>
f0101c86:	68 0b 7a 10 f0       	push   $0xf0107a0b
f0101c8b:	68 17 79 10 f0       	push   $0xf0107917
f0101c90:	68 0e 03 00 00       	push   $0x30e
f0101c95:	68 f1 78 10 f0       	push   $0xf01078f1
f0101c9a:	e8 c9 e3 ff ff       	call   f0100068 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c9f:	39 fe                	cmp    %edi,%esi
f0101ca1:	75 19                	jne    f0101cbc <mem_init+0x393>
f0101ca3:	68 21 7a 10 f0       	push   $0xf0107a21
f0101ca8:	68 17 79 10 f0       	push   $0xf0107917
f0101cad:	68 10 03 00 00       	push   $0x310
f0101cb2:	68 f1 78 10 f0       	push   $0xf01078f1
f0101cb7:	e8 ac e3 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cbc:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101cbf:	74 05                	je     f0101cc6 <mem_init+0x39d>
f0101cc1:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101cc4:	75 19                	jne    f0101cdf <mem_init+0x3b6>
f0101cc6:	68 4c 71 10 f0       	push   $0xf010714c
f0101ccb:	68 17 79 10 f0       	push   $0xf0107917
f0101cd0:	68 11 03 00 00       	push   $0x311
f0101cd5:	68 f1 78 10 f0       	push   $0xf01078f1
f0101cda:	e8 89 e3 ff ff       	call   f0100068 <_panic>
	assert(!page_alloc(0));
f0101cdf:	83 ec 0c             	sub    $0xc,%esp
f0101ce2:	6a 00                	push   $0x0
f0101ce4:	e8 e4 f8 ff ff       	call   f01015cd <page_alloc>
f0101ce9:	83 c4 10             	add    $0x10,%esp
f0101cec:	85 c0                	test   %eax,%eax
f0101cee:	74 19                	je     f0101d09 <mem_init+0x3e0>
f0101cf0:	68 8a 7a 10 f0       	push   $0xf0107a8a
f0101cf5:	68 17 79 10 f0       	push   $0xf0107917
f0101cfa:	68 12 03 00 00       	push   $0x312
f0101cff:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101d25:	68 88 65 10 f0       	push   $0xf0106588
f0101d2a:	6a 58                	push   $0x58
f0101d2c:	68 fd 78 10 f0       	push   $0xf01078fd
f0101d31:	e8 32 e3 ff ff       	call   f0100068 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101d36:	83 ec 04             	sub    $0x4,%esp
f0101d39:	68 00 10 00 00       	push   $0x1000
f0101d3e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101d40:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d45:	50                   	push   %eax
f0101d46:	e8 06 3b 00 00       	call   f0105851 <memset>
	page_free(pp0);
f0101d4b:	89 34 24             	mov    %esi,(%esp)
f0101d4e:	e8 04 f9 ff ff       	call   f0101657 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101d5a:	e8 6e f8 ff ff       	call   f01015cd <page_alloc>
f0101d5f:	83 c4 10             	add    $0x10,%esp
f0101d62:	85 c0                	test   %eax,%eax
f0101d64:	75 19                	jne    f0101d7f <mem_init+0x456>
f0101d66:	68 99 7a 10 f0       	push   $0xf0107a99
f0101d6b:	68 17 79 10 f0       	push   $0xf0107917
f0101d70:	68 17 03 00 00       	push   $0x317
f0101d75:	68 f1 78 10 f0       	push   $0xf01078f1
f0101d7a:	e8 e9 e2 ff ff       	call   f0100068 <_panic>
	assert(pp && pp0 == pp);
f0101d7f:	39 c6                	cmp    %eax,%esi
f0101d81:	74 19                	je     f0101d9c <mem_init+0x473>
f0101d83:	68 b7 7a 10 f0       	push   $0xf0107ab7
f0101d88:	68 17 79 10 f0       	push   $0xf0107917
f0101d8d:	68 18 03 00 00       	push   $0x318
f0101d92:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101db8:	68 88 65 10 f0       	push   $0xf0106588
f0101dbd:	6a 58                	push   $0x58
f0101dbf:	68 fd 78 10 f0       	push   $0xf01078fd
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
f0101de3:	68 c7 7a 10 f0       	push   $0xf0107ac7
f0101de8:	68 17 79 10 f0       	push   $0xf0107917
f0101ded:	68 1b 03 00 00       	push   $0x31b
f0101df2:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101e3d:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101e42:	68 17 79 10 f0       	push   $0xf0107917
f0101e47:	68 28 03 00 00       	push   $0x328
f0101e4c:	68 f1 78 10 f0       	push   $0xf01078f1
f0101e51:	e8 12 e2 ff ff       	call   f0100068 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101e56:	83 ec 0c             	sub    $0xc,%esp
f0101e59:	68 6c 71 10 f0       	push   $0xf010716c
f0101e5e:	e8 f2 1e 00 00       	call   f0103d55 <cprintf>
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
f0101e78:	68 df 79 10 f0       	push   $0xf01079df
f0101e7d:	68 17 79 10 f0       	push   $0xf0107917
f0101e82:	68 8e 03 00 00       	push   $0x38e
f0101e87:	68 f1 78 10 f0       	push   $0xf01078f1
f0101e8c:	e8 d7 e1 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101e91:	83 ec 0c             	sub    $0xc,%esp
f0101e94:	6a 00                	push   $0x0
f0101e96:	e8 32 f7 ff ff       	call   f01015cd <page_alloc>
f0101e9b:	89 c6                	mov    %eax,%esi
f0101e9d:	83 c4 10             	add    $0x10,%esp
f0101ea0:	85 c0                	test   %eax,%eax
f0101ea2:	75 19                	jne    f0101ebd <mem_init+0x594>
f0101ea4:	68 f5 79 10 f0       	push   $0xf01079f5
f0101ea9:	68 17 79 10 f0       	push   $0xf0107917
f0101eae:	68 8f 03 00 00       	push   $0x38f
f0101eb3:	68 f1 78 10 f0       	push   $0xf01078f1
f0101eb8:	e8 ab e1 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ebd:	83 ec 0c             	sub    $0xc,%esp
f0101ec0:	6a 00                	push   $0x0
f0101ec2:	e8 06 f7 ff ff       	call   f01015cd <page_alloc>
f0101ec7:	89 c3                	mov    %eax,%ebx
f0101ec9:	83 c4 10             	add    $0x10,%esp
f0101ecc:	85 c0                	test   %eax,%eax
f0101ece:	75 19                	jne    f0101ee9 <mem_init+0x5c0>
f0101ed0:	68 0b 7a 10 f0       	push   $0xf0107a0b
f0101ed5:	68 17 79 10 f0       	push   $0xf0107917
f0101eda:	68 90 03 00 00       	push   $0x390
f0101edf:	68 f1 78 10 f0       	push   $0xf01078f1
f0101ee4:	e8 7f e1 ff ff       	call   f0100068 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ee9:	39 f7                	cmp    %esi,%edi
f0101eeb:	75 19                	jne    f0101f06 <mem_init+0x5dd>
f0101eed:	68 21 7a 10 f0       	push   $0xf0107a21
f0101ef2:	68 17 79 10 f0       	push   $0xf0107917
f0101ef7:	68 93 03 00 00       	push   $0x393
f0101efc:	68 f1 78 10 f0       	push   $0xf01078f1
f0101f01:	e8 62 e1 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f06:	39 c6                	cmp    %eax,%esi
f0101f08:	74 04                	je     f0101f0e <mem_init+0x5e5>
f0101f0a:	39 c7                	cmp    %eax,%edi
f0101f0c:	75 19                	jne    f0101f27 <mem_init+0x5fe>
f0101f0e:	68 4c 71 10 f0       	push   $0xf010714c
f0101f13:	68 17 79 10 f0       	push   $0xf0107917
f0101f18:	68 94 03 00 00       	push   $0x394
f0101f1d:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101f4b:	68 8a 7a 10 f0       	push   $0xf0107a8a
f0101f50:	68 17 79 10 f0       	push   $0xf0107917
f0101f55:	68 9b 03 00 00       	push   $0x39b
f0101f5a:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101f7f:	68 8c 71 10 f0       	push   $0xf010718c
f0101f84:	68 17 79 10 f0       	push   $0xf0107917
f0101f89:	68 9e 03 00 00       	push   $0x39e
f0101f8e:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101faf:	68 c4 71 10 f0       	push   $0xf01071c4
f0101fb4:	68 17 79 10 f0       	push   $0xf0107917
f0101fb9:	68 a1 03 00 00       	push   $0x3a1
f0101fbe:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0101fe8:	68 f4 71 10 f0       	push   $0xf01071f4
f0101fed:	68 17 79 10 f0       	push   $0xf0107917
f0101ff2:	68 a5 03 00 00       	push   $0x3a5
f0101ff7:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102020:	68 24 72 10 f0       	push   $0xf0107224
f0102025:	68 17 79 10 f0       	push   $0xf0107917
f010202a:	68 a6 03 00 00       	push   $0x3a6
f010202f:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102055:	68 4c 72 10 f0       	push   $0xf010724c
f010205a:	68 17 79 10 f0       	push   $0xf0107917
f010205f:	68 a7 03 00 00       	push   $0x3a7
f0102064:	68 f1 78 10 f0       	push   $0xf01078f1
f0102069:	e8 fa df ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 1);
f010206e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102073:	74 19                	je     f010208e <mem_init+0x765>
f0102075:	68 dc 7a 10 f0       	push   $0xf0107adc
f010207a:	68 17 79 10 f0       	push   $0xf0107917
f010207f:	68 a8 03 00 00       	push   $0x3a8
f0102084:	68 f1 78 10 f0       	push   $0xf01078f1
f0102089:	e8 da df ff ff       	call   f0100068 <_panic>
	assert(pp0->pp_ref == 1);
f010208e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102093:	74 19                	je     f01020ae <mem_init+0x785>
f0102095:	68 ed 7a 10 f0       	push   $0xf0107aed
f010209a:	68 17 79 10 f0       	push   $0xf0107917
f010209f:	68 a9 03 00 00       	push   $0x3a9
f01020a4:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01020c8:	68 7c 72 10 f0       	push   $0xf010727c
f01020cd:	68 17 79 10 f0       	push   $0xf0107917
f01020d2:	68 ac 03 00 00       	push   $0x3ac
f01020d7:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102102:	68 b8 72 10 f0       	push   $0xf01072b8
f0102107:	68 17 79 10 f0       	push   $0xf0107917
f010210c:	68 ad 03 00 00       	push   $0x3ad
f0102111:	68 f1 78 10 f0       	push   $0xf01078f1
f0102116:	e8 4d df ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f010211b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102120:	74 19                	je     f010213b <mem_init+0x812>
f0102122:	68 fe 7a 10 f0       	push   $0xf0107afe
f0102127:	68 17 79 10 f0       	push   $0xf0107917
f010212c:	68 ae 03 00 00       	push   $0x3ae
f0102131:	68 f1 78 10 f0       	push   $0xf01078f1
f0102136:	e8 2d df ff ff       	call   f0100068 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010213b:	83 ec 0c             	sub    $0xc,%esp
f010213e:	6a 00                	push   $0x0
f0102140:	e8 88 f4 ff ff       	call   f01015cd <page_alloc>
f0102145:	83 c4 10             	add    $0x10,%esp
f0102148:	85 c0                	test   %eax,%eax
f010214a:	74 19                	je     f0102165 <mem_init+0x83c>
f010214c:	68 8a 7a 10 f0       	push   $0xf0107a8a
f0102151:	68 17 79 10 f0       	push   $0xf0107917
f0102156:	68 b1 03 00 00       	push   $0x3b1
f010215b:	68 f1 78 10 f0       	push   $0xf01078f1
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
f010217f:	68 7c 72 10 f0       	push   $0xf010727c
f0102184:	68 17 79 10 f0       	push   $0xf0107917
f0102189:	68 b4 03 00 00       	push   $0x3b4
f010218e:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01021b9:	68 b8 72 10 f0       	push   $0xf01072b8
f01021be:	68 17 79 10 f0       	push   $0xf0107917
f01021c3:	68 b5 03 00 00       	push   $0x3b5
f01021c8:	68 f1 78 10 f0       	push   $0xf01078f1
f01021cd:	e8 96 de ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f01021d2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01021d7:	74 19                	je     f01021f2 <mem_init+0x8c9>
f01021d9:	68 fe 7a 10 f0       	push   $0xf0107afe
f01021de:	68 17 79 10 f0       	push   $0xf0107917
f01021e3:	68 b6 03 00 00       	push   $0x3b6
f01021e8:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102203:	68 8a 7a 10 f0       	push   $0xf0107a8a
f0102208:	68 17 79 10 f0       	push   $0xf0107917
f010220d:	68 ba 03 00 00       	push   $0x3ba
f0102212:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102237:	68 88 65 10 f0       	push   $0xf0106588
f010223c:	68 bd 03 00 00       	push   $0x3bd
f0102241:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102270:	68 e8 72 10 f0       	push   $0xf01072e8
f0102275:	68 17 79 10 f0       	push   $0xf0107917
f010227a:	68 be 03 00 00       	push   $0x3be
f010227f:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01022a3:	68 28 73 10 f0       	push   $0xf0107328
f01022a8:	68 17 79 10 f0       	push   $0xf0107917
f01022ad:	68 c1 03 00 00       	push   $0x3c1
f01022b2:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01022dd:	68 b8 72 10 f0       	push   $0xf01072b8
f01022e2:	68 17 79 10 f0       	push   $0xf0107917
f01022e7:	68 c2 03 00 00       	push   $0x3c2
f01022ec:	68 f1 78 10 f0       	push   $0xf01078f1
f01022f1:	e8 72 dd ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f01022f6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01022fb:	74 19                	je     f0102316 <mem_init+0x9ed>
f01022fd:	68 fe 7a 10 f0       	push   $0xf0107afe
f0102302:	68 17 79 10 f0       	push   $0xf0107917
f0102307:	68 c3 03 00 00       	push   $0x3c3
f010230c:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102333:	68 68 73 10 f0       	push   $0xf0107368
f0102338:	68 17 79 10 f0       	push   $0xf0107917
f010233d:	68 c4 03 00 00       	push   $0x3c4
f0102342:	68 f1 78 10 f0       	push   $0xf01078f1
f0102347:	e8 1c dd ff ff       	call   f0100068 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010234c:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0102351:	f6 00 04             	testb  $0x4,(%eax)
f0102354:	75 19                	jne    f010236f <mem_init+0xa46>
f0102356:	68 0f 7b 10 f0       	push   $0xf0107b0f
f010235b:	68 17 79 10 f0       	push   $0xf0107917
f0102360:	68 c5 03 00 00       	push   $0x3c5
f0102365:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102384:	68 7c 72 10 f0       	push   $0xf010727c
f0102389:	68 17 79 10 f0       	push   $0xf0107917
f010238e:	68 c8 03 00 00       	push   $0x3c8
f0102393:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01023ba:	68 9c 73 10 f0       	push   $0xf010739c
f01023bf:	68 17 79 10 f0       	push   $0xf0107917
f01023c4:	68 c9 03 00 00       	push   $0x3c9
f01023c9:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01023f0:	68 d0 73 10 f0       	push   $0xf01073d0
f01023f5:	68 17 79 10 f0       	push   $0xf0107917
f01023fa:	68 ca 03 00 00       	push   $0x3ca
f01023ff:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102423:	68 08 74 10 f0       	push   $0xf0107408
f0102428:	68 17 79 10 f0       	push   $0xf0107917
f010242d:	68 cd 03 00 00       	push   $0x3cd
f0102432:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102456:	68 40 74 10 f0       	push   $0xf0107440
f010245b:	68 17 79 10 f0       	push   $0xf0107917
f0102460:	68 d0 03 00 00       	push   $0x3d0
f0102465:	68 f1 78 10 f0       	push   $0xf01078f1
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
f010248c:	68 d0 73 10 f0       	push   $0xf01073d0
f0102491:	68 17 79 10 f0       	push   $0xf0107917
f0102496:	68 d1 03 00 00       	push   $0x3d1
f010249b:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01024c6:	68 7c 74 10 f0       	push   $0xf010747c
f01024cb:	68 17 79 10 f0       	push   $0xf0107917
f01024d0:	68 d4 03 00 00       	push   $0x3d4
f01024d5:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102500:	68 a8 74 10 f0       	push   $0xf01074a8
f0102505:	68 17 79 10 f0       	push   $0xf0107917
f010250a:	68 d5 03 00 00       	push   $0x3d5
f010250f:	68 f1 78 10 f0       	push   $0xf01078f1
f0102514:	e8 4f db ff ff       	call   f0100068 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102519:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f010251e:	74 19                	je     f0102539 <mem_init+0xc10>
f0102520:	68 25 7b 10 f0       	push   $0xf0107b25
f0102525:	68 17 79 10 f0       	push   $0xf0107917
f010252a:	68 d7 03 00 00       	push   $0x3d7
f010252f:	68 f1 78 10 f0       	push   $0xf01078f1
f0102534:	e8 2f db ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f0102539:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010253e:	74 19                	je     f0102559 <mem_init+0xc30>
f0102540:	68 36 7b 10 f0       	push   $0xf0107b36
f0102545:	68 17 79 10 f0       	push   $0xf0107917
f010254a:	68 d8 03 00 00       	push   $0x3d8
f010254f:	68 f1 78 10 f0       	push   $0xf01078f1
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
f010256e:	68 d8 74 10 f0       	push   $0xf01074d8
f0102573:	68 17 79 10 f0       	push   $0xf0107917
f0102578:	68 db 03 00 00       	push   $0x3db
f010257d:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01025ae:	68 fc 74 10 f0       	push   $0xf01074fc
f01025b3:	68 17 79 10 f0       	push   $0xf0107917
f01025b8:	68 df 03 00 00       	push   $0x3df
f01025bd:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01025e8:	68 a8 74 10 f0       	push   $0xf01074a8
f01025ed:	68 17 79 10 f0       	push   $0xf0107917
f01025f2:	68 e0 03 00 00       	push   $0x3e0
f01025f7:	68 f1 78 10 f0       	push   $0xf01078f1
f01025fc:	e8 67 da ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 1);
f0102601:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102606:	74 19                	je     f0102621 <mem_init+0xcf8>
f0102608:	68 dc 7a 10 f0       	push   $0xf0107adc
f010260d:	68 17 79 10 f0       	push   $0xf0107917
f0102612:	68 e1 03 00 00       	push   $0x3e1
f0102617:	68 f1 78 10 f0       	push   $0xf01078f1
f010261c:	e8 47 da ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f0102621:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102626:	74 19                	je     f0102641 <mem_init+0xd18>
f0102628:	68 36 7b 10 f0       	push   $0xf0107b36
f010262d:	68 17 79 10 f0       	push   $0xf0107917
f0102632:	68 e2 03 00 00       	push   $0x3e2
f0102637:	68 f1 78 10 f0       	push   $0xf01078f1
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
f010266b:	68 fc 74 10 f0       	push   $0xf01074fc
f0102670:	68 17 79 10 f0       	push   $0xf0107917
f0102675:	68 e6 03 00 00       	push   $0x3e6
f010267a:	68 f1 78 10 f0       	push   $0xf01078f1
f010267f:	e8 e4 d9 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102684:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102689:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f010268e:	e8 14 eb ff ff       	call   f01011a7 <check_va2pa>
f0102693:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102696:	74 19                	je     f01026b1 <mem_init+0xd88>
f0102698:	68 20 75 10 f0       	push   $0xf0107520
f010269d:	68 17 79 10 f0       	push   $0xf0107917
f01026a2:	68 e7 03 00 00       	push   $0x3e7
f01026a7:	68 f1 78 10 f0       	push   $0xf01078f1
f01026ac:	e8 b7 d9 ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 0);
f01026b1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026b6:	74 19                	je     f01026d1 <mem_init+0xda8>
f01026b8:	68 47 7b 10 f0       	push   $0xf0107b47
f01026bd:	68 17 79 10 f0       	push   $0xf0107917
f01026c2:	68 e8 03 00 00       	push   $0x3e8
f01026c7:	68 f1 78 10 f0       	push   $0xf01078f1
f01026cc:	e8 97 d9 ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f01026d1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01026d6:	74 19                	je     f01026f1 <mem_init+0xdc8>
f01026d8:	68 36 7b 10 f0       	push   $0xf0107b36
f01026dd:	68 17 79 10 f0       	push   $0xf0107917
f01026e2:	68 e9 03 00 00       	push   $0x3e9
f01026e7:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102706:	68 48 75 10 f0       	push   $0xf0107548
f010270b:	68 17 79 10 f0       	push   $0xf0107917
f0102710:	68 ec 03 00 00       	push   $0x3ec
f0102715:	68 f1 78 10 f0       	push   $0xf01078f1
f010271a:	e8 49 d9 ff ff       	call   f0100068 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010271f:	83 ec 0c             	sub    $0xc,%esp
f0102722:	6a 00                	push   $0x0
f0102724:	e8 a4 ee ff ff       	call   f01015cd <page_alloc>
f0102729:	83 c4 10             	add    $0x10,%esp
f010272c:	85 c0                	test   %eax,%eax
f010272e:	74 19                	je     f0102749 <mem_init+0xe20>
f0102730:	68 8a 7a 10 f0       	push   $0xf0107a8a
f0102735:	68 17 79 10 f0       	push   $0xf0107917
f010273a:	68 ef 03 00 00       	push   $0x3ef
f010273f:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102768:	68 24 72 10 f0       	push   $0xf0107224
f010276d:	68 17 79 10 f0       	push   $0xf0107917
f0102772:	68 f2 03 00 00       	push   $0x3f2
f0102777:	68 f1 78 10 f0       	push   $0xf01078f1
f010277c:	e8 e7 d8 ff ff       	call   f0100068 <_panic>
	kern_pgdir[0] = 0;
f0102781:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102787:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010278c:	74 19                	je     f01027a7 <mem_init+0xe7e>
f010278e:	68 ed 7a 10 f0       	push   $0xf0107aed
f0102793:	68 17 79 10 f0       	push   $0xf0107917
f0102798:	68 f4 03 00 00       	push   $0x3f4
f010279d:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01027d4:	68 88 65 10 f0       	push   $0xf0106588
f01027d9:	6a 58                	push   $0x58
f01027db:	68 fd 78 10 f0       	push   $0xf01078fd
f01027e0:	e8 83 d8 ff ff       	call   f0100068 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01027e5:	83 ec 04             	sub    $0x4,%esp
f01027e8:	68 00 10 00 00       	push   $0x1000
f01027ed:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01027f2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01027f7:	50                   	push   %eax
f01027f8:	e8 54 30 00 00       	call   f0105851 <memset>
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
f0102836:	68 88 65 10 f0       	push   $0xf0106588
f010283b:	6a 58                	push   $0x58
f010283d:	68 fd 78 10 f0       	push   $0xf01078fd
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
f010286a:	68 58 7b 10 f0       	push   $0xf0107b58
f010286f:	68 17 79 10 f0       	push   $0xf0107917
f0102874:	68 00 04 00 00       	push   $0x400
f0102879:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01028f6:	68 6c 75 10 f0       	push   $0xf010756c
f01028fb:	68 17 79 10 f0       	push   $0xf0107917
f0102900:	68 10 04 00 00       	push   $0x410
f0102905:	68 f1 78 10 f0       	push   $0xf01078f1
f010290a:	e8 59 d7 ff ff       	call   f0100068 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010290f:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102915:	76 0e                	jbe    f0102925 <mem_init+0xffc>
f0102917:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010291d:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102923:	76 19                	jbe    f010293e <mem_init+0x1015>
f0102925:	68 94 75 10 f0       	push   $0xf0107594
f010292a:	68 17 79 10 f0       	push   $0xf0107917
f010292f:	68 11 04 00 00       	push   $0x411
f0102934:	68 f1 78 10 f0       	push   $0xf01078f1
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
f010294a:	68 bc 75 10 f0       	push   $0xf01075bc
f010294f:	68 17 79 10 f0       	push   $0xf0107917
f0102954:	68 13 04 00 00       	push   $0x413
f0102959:	68 f1 78 10 f0       	push   $0xf01078f1
f010295e:	e8 05 d7 ff ff       	call   f0100068 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102963:	39 c6                	cmp    %eax,%esi
f0102965:	73 19                	jae    f0102980 <mem_init+0x1057>
f0102967:	68 6f 7b 10 f0       	push   $0xf0107b6f
f010296c:	68 17 79 10 f0       	push   $0xf0107917
f0102971:	68 15 04 00 00       	push   $0x415
f0102976:	68 f1 78 10 f0       	push   $0xf01078f1
f010297b:	e8 e8 d6 ff ff       	call   f0100068 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102980:	89 da                	mov    %ebx,%edx
f0102982:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0102987:	e8 1b e8 ff ff       	call   f01011a7 <check_va2pa>
f010298c:	85 c0                	test   %eax,%eax
f010298e:	74 19                	je     f01029a9 <mem_init+0x1080>
f0102990:	68 e4 75 10 f0       	push   $0xf01075e4
f0102995:	68 17 79 10 f0       	push   $0xf0107917
f010299a:	68 17 04 00 00       	push   $0x417
f010299f:	68 f1 78 10 f0       	push   $0xf01078f1
f01029a4:	e8 bf d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01029a9:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
f01029af:	89 fa                	mov    %edi,%edx
f01029b1:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f01029b6:	e8 ec e7 ff ff       	call   f01011a7 <check_va2pa>
f01029bb:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01029c0:	74 19                	je     f01029db <mem_init+0x10b2>
f01029c2:	68 08 76 10 f0       	push   $0xf0107608
f01029c7:	68 17 79 10 f0       	push   $0xf0107917
f01029cc:	68 18 04 00 00       	push   $0x418
f01029d1:	68 f1 78 10 f0       	push   $0xf01078f1
f01029d6:	e8 8d d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01029db:	89 f2                	mov    %esi,%edx
f01029dd:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f01029e2:	e8 c0 e7 ff ff       	call   f01011a7 <check_va2pa>
f01029e7:	85 c0                	test   %eax,%eax
f01029e9:	74 19                	je     f0102a04 <mem_init+0x10db>
f01029eb:	68 38 76 10 f0       	push   $0xf0107638
f01029f0:	68 17 79 10 f0       	push   $0xf0107917
f01029f5:	68 19 04 00 00       	push   $0x419
f01029fa:	68 f1 78 10 f0       	push   $0xf01078f1
f01029ff:	e8 64 d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a04:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102a0a:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
f0102a0f:	e8 93 e7 ff ff       	call   f01011a7 <check_va2pa>
f0102a14:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a17:	74 19                	je     f0102a32 <mem_init+0x1109>
f0102a19:	68 5c 76 10 f0       	push   $0xf010765c
f0102a1e:	68 17 79 10 f0       	push   $0xf0107917
f0102a23:	68 1a 04 00 00       	push   $0x41a
f0102a28:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102a4b:	68 88 76 10 f0       	push   $0xf0107688
f0102a50:	68 17 79 10 f0       	push   $0xf0107917
f0102a55:	68 1c 04 00 00       	push   $0x41c
f0102a5a:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102a7d:	68 cc 76 10 f0       	push   $0xf01076cc
f0102a82:	68 17 79 10 f0       	push   $0xf0107917
f0102a87:	68 1d 04 00 00       	push   $0x41d
f0102a8c:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102adb:	c7 04 24 81 7b 10 f0 	movl   $0xf0107b81,(%esp)
f0102ae2:	e8 6e 12 00 00       	call   f0103d55 <cprintf>
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
f0102af7:	68 64 65 10 f0       	push   $0xf0106564
f0102afc:	68 b9 00 00 00       	push   $0xb9
f0102b01:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102b48:	68 64 65 10 f0       	push   $0xf0106564
f0102b4d:	68 c6 00 00 00       	push   $0xc6
f0102b52:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102b8b:	68 64 65 10 f0       	push   $0xf0106564
f0102b90:	68 d7 00 00 00       	push   $0xd7
f0102b95:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102bff:	68 64 65 10 f0       	push   $0xf0106564
f0102c04:	68 24 01 00 00       	push   $0x124
f0102c09:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102c82:	68 64 65 10 f0       	push   $0xf0106564
f0102c87:	68 40 03 00 00       	push   $0x340
f0102c8c:	68 f1 78 10 f0       	push   $0xf01078f1
f0102c91:	e8 d2 d3 ff ff       	call   f0100068 <_panic>
f0102c96:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0102c9d:	39 d0                	cmp    %edx,%eax
f0102c9f:	74 19                	je     f0102cba <mem_init+0x1391>
f0102ca1:	68 00 77 10 f0       	push   $0xf0107700
f0102ca6:	68 17 79 10 f0       	push   $0xf0107917
f0102cab:	68 40 03 00 00       	push   $0x340
f0102cb0:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102ce5:	68 64 65 10 f0       	push   $0xf0106564
f0102cea:	68 45 03 00 00       	push   $0x345
f0102cef:	68 f1 78 10 f0       	push   $0xf01078f1
f0102cf4:	e8 6f d3 ff ff       	call   f0100068 <_panic>
f0102cf9:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0102d00:	39 d0                	cmp    %edx,%eax
f0102d02:	74 19                	je     f0102d1d <mem_init+0x13f4>
f0102d04:	68 34 77 10 f0       	push   $0xf0107734
f0102d09:	68 17 79 10 f0       	push   $0xf0107917
f0102d0e:	68 45 03 00 00       	push   $0x345
f0102d13:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102d4b:	68 68 77 10 f0       	push   $0xf0107768
f0102d50:	68 17 79 10 f0       	push   $0xf0107917
f0102d55:	68 49 03 00 00       	push   $0x349
f0102d5a:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102da8:	68 64 65 10 f0       	push   $0xf0106564
f0102dad:	68 51 03 00 00       	push   $0x351
f0102db2:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102dd3:	68 90 77 10 f0       	push   $0xf0107790
f0102dd8:	68 17 79 10 f0       	push   $0xf0107917
f0102ddd:	68 51 03 00 00       	push   $0x351
f0102de2:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102e17:	68 d8 77 10 f0       	push   $0xf01077d8
f0102e1c:	68 17 79 10 f0       	push   $0xf0107917
f0102e21:	68 53 03 00 00       	push   $0x353
f0102e26:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102e70:	68 9a 7b 10 f0       	push   $0xf0107b9a
f0102e75:	68 17 79 10 f0       	push   $0xf0107917
f0102e7a:	68 5e 03 00 00       	push   $0x35e
f0102e7f:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102e98:	68 9a 7b 10 f0       	push   $0xf0107b9a
f0102e9d:	68 17 79 10 f0       	push   $0xf0107917
f0102ea2:	68 62 03 00 00       	push   $0x362
f0102ea7:	68 f1 78 10 f0       	push   $0xf01078f1
f0102eac:	e8 b7 d1 ff ff       	call   f0100068 <_panic>
				assert(pgdir[i] & PTE_W);
f0102eb1:	f6 c2 02             	test   $0x2,%dl
f0102eb4:	75 38                	jne    f0102eee <mem_init+0x15c5>
f0102eb6:	68 ab 7b 10 f0       	push   $0xf0107bab
f0102ebb:	68 17 79 10 f0       	push   $0xf0107917
f0102ec0:	68 63 03 00 00       	push   $0x363
f0102ec5:	68 f1 78 10 f0       	push   $0xf01078f1
f0102eca:	e8 99 d1 ff ff       	call   f0100068 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102ecf:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102ed3:	74 19                	je     f0102eee <mem_init+0x15c5>
f0102ed5:	68 bc 7b 10 f0       	push   $0xf0107bbc
f0102eda:	68 17 79 10 f0       	push   $0xf0107917
f0102edf:	68 65 03 00 00       	push   $0x365
f0102ee4:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102efd:	68 fc 77 10 f0       	push   $0xf01077fc
f0102f02:	e8 4e 0e 00 00       	call   f0103d55 <cprintf>
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
f0102f17:	68 64 65 10 f0       	push   $0xf0106564
f0102f1c:	68 f9 00 00 00       	push   $0xf9
f0102f21:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102f5e:	68 df 79 10 f0       	push   $0xf01079df
f0102f63:	68 17 79 10 f0       	push   $0xf0107917
f0102f68:	68 32 04 00 00       	push   $0x432
f0102f6d:	68 f1 78 10 f0       	push   $0xf01078f1
f0102f72:	e8 f1 d0 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0102f77:	83 ec 0c             	sub    $0xc,%esp
f0102f7a:	6a 00                	push   $0x0
f0102f7c:	e8 4c e6 ff ff       	call   f01015cd <page_alloc>
f0102f81:	89 c7                	mov    %eax,%edi
f0102f83:	83 c4 10             	add    $0x10,%esp
f0102f86:	85 c0                	test   %eax,%eax
f0102f88:	75 19                	jne    f0102fa3 <mem_init+0x167a>
f0102f8a:	68 f5 79 10 f0       	push   $0xf01079f5
f0102f8f:	68 17 79 10 f0       	push   $0xf0107917
f0102f94:	68 33 04 00 00       	push   $0x433
f0102f99:	68 f1 78 10 f0       	push   $0xf01078f1
f0102f9e:	e8 c5 d0 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0102fa3:	83 ec 0c             	sub    $0xc,%esp
f0102fa6:	6a 00                	push   $0x0
f0102fa8:	e8 20 e6 ff ff       	call   f01015cd <page_alloc>
f0102fad:	89 c3                	mov    %eax,%ebx
f0102faf:	83 c4 10             	add    $0x10,%esp
f0102fb2:	85 c0                	test   %eax,%eax
f0102fb4:	75 19                	jne    f0102fcf <mem_init+0x16a6>
f0102fb6:	68 0b 7a 10 f0       	push   $0xf0107a0b
f0102fbb:	68 17 79 10 f0       	push   $0xf0107917
f0102fc0:	68 34 04 00 00       	push   $0x434
f0102fc5:	68 f1 78 10 f0       	push   $0xf01078f1
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
f0102ff7:	68 88 65 10 f0       	push   $0xf0106588
f0102ffc:	6a 58                	push   $0x58
f0102ffe:	68 fd 78 10 f0       	push   $0xf01078fd
f0103003:	e8 60 d0 ff ff       	call   f0100068 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103008:	83 ec 04             	sub    $0x4,%esp
f010300b:	68 00 10 00 00       	push   $0x1000
f0103010:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103012:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103017:	50                   	push   %eax
f0103018:	e8 34 28 00 00       	call   f0105851 <memset>
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
f010303c:	68 88 65 10 f0       	push   $0xf0106588
f0103041:	6a 58                	push   $0x58
f0103043:	68 fd 78 10 f0       	push   $0xf01078fd
f0103048:	e8 1b d0 ff ff       	call   f0100068 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010304d:	83 ec 04             	sub    $0x4,%esp
f0103050:	68 00 10 00 00       	push   $0x1000
f0103055:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0103057:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010305c:	50                   	push   %eax
f010305d:	e8 ef 27 00 00       	call   f0105851 <memset>
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
f010307f:	68 dc 7a 10 f0       	push   $0xf0107adc
f0103084:	68 17 79 10 f0       	push   $0xf0107917
f0103089:	68 39 04 00 00       	push   $0x439
f010308e:	68 f1 78 10 f0       	push   $0xf01078f1
f0103093:	e8 d0 cf ff ff       	call   f0100068 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103098:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010309f:	01 01 01 
f01030a2:	74 19                	je     f01030bd <mem_init+0x1794>
f01030a4:	68 1c 78 10 f0       	push   $0xf010781c
f01030a9:	68 17 79 10 f0       	push   $0xf0107917
f01030ae:	68 3a 04 00 00       	push   $0x43a
f01030b3:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01030df:	68 40 78 10 f0       	push   $0xf0107840
f01030e4:	68 17 79 10 f0       	push   $0xf0107917
f01030e9:	68 3c 04 00 00       	push   $0x43c
f01030ee:	68 f1 78 10 f0       	push   $0xf01078f1
f01030f3:	e8 70 cf ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f01030f8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01030fd:	74 19                	je     f0103118 <mem_init+0x17ef>
f01030ff:	68 fe 7a 10 f0       	push   $0xf0107afe
f0103104:	68 17 79 10 f0       	push   $0xf0107917
f0103109:	68 3d 04 00 00       	push   $0x43d
f010310e:	68 f1 78 10 f0       	push   $0xf01078f1
f0103113:	e8 50 cf ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 0);
f0103118:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010311d:	74 19                	je     f0103138 <mem_init+0x180f>
f010311f:	68 47 7b 10 f0       	push   $0xf0107b47
f0103124:	68 17 79 10 f0       	push   $0xf0107917
f0103129:	68 3e 04 00 00       	push   $0x43e
f010312e:	68 f1 78 10 f0       	push   $0xf01078f1
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
f010315e:	68 88 65 10 f0       	push   $0xf0106588
f0103163:	6a 58                	push   $0x58
f0103165:	68 fd 78 10 f0       	push   $0xf01078fd
f010316a:	e8 f9 ce ff ff       	call   f0100068 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010316f:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103176:	03 03 03 
f0103179:	74 19                	je     f0103194 <mem_init+0x186b>
f010317b:	68 64 78 10 f0       	push   $0xf0107864
f0103180:	68 17 79 10 f0       	push   $0xf0107917
f0103185:	68 40 04 00 00       	push   $0x440
f010318a:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01031b1:	68 36 7b 10 f0       	push   $0xf0107b36
f01031b6:	68 17 79 10 f0       	push   $0xf0107917
f01031bb:	68 42 04 00 00       	push   $0x442
f01031c0:	68 f1 78 10 f0       	push   $0xf01078f1
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
f01031e9:	68 24 72 10 f0       	push   $0xf0107224
f01031ee:	68 17 79 10 f0       	push   $0xf0107917
f01031f3:	68 45 04 00 00       	push   $0x445
f01031f8:	68 f1 78 10 f0       	push   $0xf01078f1
f01031fd:	e8 66 ce ff ff       	call   f0100068 <_panic>
	kern_pgdir[0] = 0;
f0103202:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103208:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010320d:	74 19                	je     f0103228 <mem_init+0x18ff>
f010320f:	68 ed 7a 10 f0       	push   $0xf0107aed
f0103214:	68 17 79 10 f0       	push   $0xf0107917
f0103219:	68 47 04 00 00       	push   $0x447
f010321e:	68 f1 78 10 f0       	push   $0xf01078f1
f0103223:	e8 40 ce ff ff       	call   f0100068 <_panic>
	pp0->pp_ref = 0;
f0103228:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010322e:	83 ec 0c             	sub    $0xc,%esp
f0103231:	56                   	push   %esi
f0103232:	e8 20 e4 ff ff       	call   f0101657 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103237:	c7 04 24 90 78 10 f0 	movl   $0xf0107890,(%esp)
f010323e:	e8 12 0b 00 00       	call   f0103d55 <cprintf>
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
f010336e:	68 bc 78 10 f0       	push   $0xf01078bc
f0103373:	e8 dd 09 00 00       	call   f0103d55 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103378:	89 1c 24             	mov    %ebx,(%esp)
f010337b:	e8 b4 06 00 00       	call   f0103a34 <env_destroy>
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
f01033c0:	68 cc 7b 10 f0       	push   $0xf0107bcc
f01033c5:	68 31 01 00 00       	push   $0x131
f01033ca:	68 0f 7c 10 f0       	push   $0xf0107c0f
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
f01033e8:	68 f0 7b 10 f0       	push   $0xf0107bf0
f01033ed:	68 35 01 00 00       	push   $0x135
f01033f2:	68 0f 7c 10 f0       	push   $0xf0107c0f
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
f0103424:	e8 57 2a 00 00       	call   f0105e80 <cpunum>
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
f010347e:	e8 fd 29 00 00       	call   f0105e80 <cpunum>
f0103483:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010348a:	29 c2                	sub    %eax,%edx
f010348c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010348f:	39 1c 85 28 60 2e f0 	cmp    %ebx,-0xfd19fd8(,%eax,4)
f0103496:	74 2d                	je     f01034c5 <envid2env+0xb7>
f0103498:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f010349b:	e8 e0 29 00 00       	call   f0105e80 <cpunum>
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
f0103566:	0f 84 a3 01 00 00    	je     f010370f <env_alloc+0x1b6>
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
f010357b:	0f 84 95 01 00 00    	je     f0103716 <env_alloc+0x1bd>
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
f010359f:	68 88 65 10 f0       	push   $0xf0106588
f01035a4:	6a 58                	push   $0x58
f01035a6:	68 fd 78 10 f0       	push   $0xf01078fd
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
f01035c7:	e8 39 23 00 00       	call   f0105905 <memcpy>
    memset(e->env_pgdir, 0, PDX(UTOP) * sizeof(pde_t));
f01035cc:	83 c4 0c             	add    $0xc,%esp
f01035cf:	68 ec 0e 00 00       	push   $0xeec
f01035d4:	6a 00                	push   $0x0
f01035d6:	ff 73 60             	pushl  0x60(%ebx)
f01035d9:	e8 73 22 00 00       	call   f0105851 <memset>

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
f01035ec:	68 64 65 10 f0       	push   $0xf0106564
f01035f1:	68 cb 00 00 00       	push   $0xcb
f01035f6:	68 0f 7c 10 f0       	push   $0xf0107c0f
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
f0103677:	e8 d5 21 00 00       	call   f0105851 <memset>
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

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010369b:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01036a2:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01036a6:	8b 43 44             	mov    0x44(%ebx),%eax
f01036a9:	a3 40 52 2e f0       	mov    %eax,0xf02e5240
	*newenv_store = e;
f01036ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01036b1:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01036b3:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01036b6:	e8 c5 27 00 00       	call   f0105e80 <cpunum>
f01036bb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01036c2:	29 c2                	sub    %eax,%edx
f01036c4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036c7:	83 c4 10             	add    $0x10,%esp
f01036ca:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f01036d1:	00 
f01036d2:	74 1d                	je     f01036f1 <env_alloc+0x198>
f01036d4:	e8 a7 27 00 00       	call   f0105e80 <cpunum>
f01036d9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01036e0:	29 c2                	sub    %eax,%edx
f01036e2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036e5:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f01036ec:	8b 40 48             	mov    0x48(%eax),%eax
f01036ef:	eb 05                	jmp    f01036f6 <env_alloc+0x19d>
f01036f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01036f6:	83 ec 04             	sub    $0x4,%esp
f01036f9:	53                   	push   %ebx
f01036fa:	50                   	push   %eax
f01036fb:	68 1a 7c 10 f0       	push   $0xf0107c1a
f0103700:	e8 50 06 00 00       	call   f0103d55 <cprintf>
	return 0;
f0103705:	83 c4 10             	add    $0x10,%esp
f0103708:	b8 00 00 00 00       	mov    $0x0,%eax
f010370d:	eb 0c                	jmp    f010371b <env_alloc+0x1c2>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010370f:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103714:	eb 05                	jmp    f010371b <env_alloc+0x1c2>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103716:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010371b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010371e:	5b                   	pop    %ebx
f010371f:	5e                   	pop    %esi
f0103720:	c9                   	leave  
f0103721:	c3                   	ret    

f0103722 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103722:	55                   	push   %ebp
f0103723:	89 e5                	mov    %esp,%ebp
f0103725:	57                   	push   %edi
f0103726:	56                   	push   %esi
f0103727:	53                   	push   %ebx
f0103728:	83 ec 34             	sub    $0x34,%esp
f010372b:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("env_create %u %u %u\n", binary, size, type);
	// LAB 3: Your code here.
    struct Env * e;
    int r = env_alloc(&e, 0);
f010372e:	6a 00                	push   $0x0
f0103730:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103733:	50                   	push   %eax
f0103734:	e8 20 fe ff ff       	call   f0103559 <env_alloc>
    if (r < 0) {
f0103739:	83 c4 10             	add    $0x10,%esp
f010373c:	85 c0                	test   %eax,%eax
f010373e:	79 15                	jns    f0103755 <env_create+0x33>
        panic("env_create: %e\n", r);
f0103740:	50                   	push   %eax
f0103741:	68 2f 7c 10 f0       	push   $0xf0107c2f
f0103746:	68 9f 01 00 00       	push   $0x19f
f010374b:	68 0f 7c 10 f0       	push   $0xf0107c0f
f0103750:	e8 13 c9 ff ff       	call   f0100068 <_panic>
    }
    load_icode(e, binary, size);
f0103755:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103758:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
f010375b:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103761:	74 17                	je     f010377a <env_create+0x58>
        panic("error elf magic number\n");
f0103763:	83 ec 04             	sub    $0x4,%esp
f0103766:	68 3f 7c 10 f0       	push   $0xf0107c3f
f010376b:	68 74 01 00 00       	push   $0x174
f0103770:	68 0f 7c 10 f0       	push   $0xf0107c0f
f0103775:	e8 ee c8 ff ff       	call   f0100068 <_panic>
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f010377a:	8b 5e 1c             	mov    0x1c(%esi),%ebx
    eph = ph + elf->e_phnum;
f010377d:	8b 7e 2c             	mov    0x2c(%esi),%edi

    lcr3(PADDR(e->env_pgdir));
f0103780:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103783:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103786:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010378b:	77 15                	ja     f01037a2 <env_create+0x80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010378d:	50                   	push   %eax
f010378e:	68 64 65 10 f0       	push   $0xf0106564
f0103793:	68 7a 01 00 00       	push   $0x17a
f0103798:	68 0f 7c 10 f0       	push   $0xf0107c0f
f010379d:	e8 c6 c8 ff ff       	call   f0100068 <_panic>
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
        panic("error elf magic number\n");
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01037a2:	8d 1c 1e             	lea    (%esi,%ebx,1),%ebx
    eph = ph + elf->e_phnum;
f01037a5:	0f b7 ff             	movzwl %di,%edi
f01037a8:	c1 e7 05             	shl    $0x5,%edi
f01037ab:	8d 3c 3b             	lea    (%ebx,%edi,1),%edi
	return (physaddr_t)kva - KERNBASE;
f01037ae:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01037b3:	0f 22 d8             	mov    %eax,%cr3

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01037b6:	39 fb                	cmp    %edi,%ebx
f01037b8:	73 48                	jae    f0103802 <env_create+0xe0>
        if (ph->p_type == ELF_PROG_LOAD) {
f01037ba:	83 3b 01             	cmpl   $0x1,(%ebx)
f01037bd:	75 3c                	jne    f01037fb <env_create+0xd9>
            // cprintf("%u %u\n", ph->p_memsz, ph->p_filesz);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01037bf:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01037c2:	8b 53 08             	mov    0x8(%ebx),%edx
f01037c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01037c8:	e8 bb fb ff ff       	call   f0103388 <region_alloc>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01037cd:	83 ec 04             	sub    $0x4,%esp
f01037d0:	ff 73 10             	pushl  0x10(%ebx)
f01037d3:	89 f0                	mov    %esi,%eax
f01037d5:	03 43 04             	add    0x4(%ebx),%eax
f01037d8:	50                   	push   %eax
f01037d9:	ff 73 08             	pushl  0x8(%ebx)
f01037dc:	e8 24 21 00 00       	call   f0105905 <memcpy>
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f01037e1:	8b 43 10             	mov    0x10(%ebx),%eax
f01037e4:	83 c4 0c             	add    $0xc,%esp
f01037e7:	8b 53 14             	mov    0x14(%ebx),%edx
f01037ea:	29 c2                	sub    %eax,%edx
f01037ec:	52                   	push   %edx
f01037ed:	6a 00                	push   $0x0
f01037ef:	03 43 08             	add    0x8(%ebx),%eax
f01037f2:	50                   	push   %eax
f01037f3:	e8 59 20 00 00       	call   f0105851 <memset>
f01037f8:	83 c4 10             	add    $0x10,%esp
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
    eph = ph + elf->e_phnum;

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01037fb:	83 c3 20             	add    $0x20,%ebx
f01037fe:	39 df                	cmp    %ebx,%edi
f0103800:	77 b8                	ja     f01037ba <env_create+0x98>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
        }
    }
    e->env_tf.tf_eip = elf->e_entry;
f0103802:	8b 46 18             	mov    0x18(%esi),%eax
f0103805:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103808:	89 42 30             	mov    %eax,0x30(%edx)

    lcr3(PADDR(kern_pgdir));
f010380b:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103810:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103815:	77 15                	ja     f010382c <env_create+0x10a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103817:	50                   	push   %eax
f0103818:	68 64 65 10 f0       	push   $0xf0106564
f010381d:	68 86 01 00 00       	push   $0x186
f0103822:	68 0f 7c 10 f0       	push   $0xf0107c0f
f0103827:	e8 3c c8 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010382c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103831:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103834:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103839:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010383e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103841:	e8 42 fb ff ff       	call   f0103388 <region_alloc>
    int r = env_alloc(&e, 0);
    if (r < 0) {
        panic("env_create: %e\n", r);
    }
    load_icode(e, binary, size);
    e->env_type = type;
f0103846:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103849:	8b 55 10             	mov    0x10(%ebp),%edx
f010384c:	89 50 50             	mov    %edx,0x50(%eax)
    // cprintf("env_create out\n");
    return;
}
f010384f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103852:	5b                   	pop    %ebx
f0103853:	5e                   	pop    %esi
f0103854:	5f                   	pop    %edi
f0103855:	c9                   	leave  
f0103856:	c3                   	ret    

f0103857 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103857:	55                   	push   %ebp
f0103858:	89 e5                	mov    %esp,%ebp
f010385a:	57                   	push   %edi
f010385b:	56                   	push   %esi
f010385c:	53                   	push   %ebx
f010385d:	83 ec 1c             	sub    $0x1c,%esp
f0103860:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103863:	e8 18 26 00 00       	call   f0105e80 <cpunum>
f0103868:	6b c0 74             	imul   $0x74,%eax,%eax
f010386b:	39 b8 28 60 2e f0    	cmp    %edi,-0xfd19fd8(%eax)
f0103871:	75 29                	jne    f010389c <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f0103873:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103878:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010387d:	77 15                	ja     f0103894 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010387f:	50                   	push   %eax
f0103880:	68 64 65 10 f0       	push   $0xf0106564
f0103885:	68 b5 01 00 00       	push   $0x1b5
f010388a:	68 0f 7c 10 f0       	push   $0xf0107c0f
f010388f:	e8 d4 c7 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103894:	05 00 00 00 10       	add    $0x10000000,%eax
f0103899:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010389c:	8b 5f 48             	mov    0x48(%edi),%ebx
f010389f:	e8 dc 25 00 00       	call   f0105e80 <cpunum>
f01038a4:	6b d0 74             	imul   $0x74,%eax,%edx
f01038a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01038ac:	83 ba 28 60 2e f0 00 	cmpl   $0x0,-0xfd19fd8(%edx)
f01038b3:	74 11                	je     f01038c6 <env_free+0x6f>
f01038b5:	e8 c6 25 00 00       	call   f0105e80 <cpunum>
f01038ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01038bd:	8b 80 28 60 2e f0    	mov    -0xfd19fd8(%eax),%eax
f01038c3:	8b 40 48             	mov    0x48(%eax),%eax
f01038c6:	83 ec 04             	sub    $0x4,%esp
f01038c9:	53                   	push   %ebx
f01038ca:	50                   	push   %eax
f01038cb:	68 57 7c 10 f0       	push   $0xf0107c57
f01038d0:	e8 80 04 00 00       	call   f0103d55 <cprintf>
f01038d5:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01038d8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038df:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038e2:	c1 e0 02             	shl    $0x2,%eax
f01038e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01038e8:	8b 47 60             	mov    0x60(%edi),%eax
f01038eb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01038ee:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01038f1:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01038f7:	0f 84 ab 00 00 00    	je     f01039a8 <env_free+0x151>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01038fd:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103903:	89 f0                	mov    %esi,%eax
f0103905:	c1 e8 0c             	shr    $0xc,%eax
f0103908:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010390b:	3b 05 88 5e 2e f0    	cmp    0xf02e5e88,%eax
f0103911:	72 15                	jb     f0103928 <env_free+0xd1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103913:	56                   	push   %esi
f0103914:	68 88 65 10 f0       	push   $0xf0106588
f0103919:	68 c4 01 00 00       	push   $0x1c4
f010391e:	68 0f 7c 10 f0       	push   $0xf0107c0f
f0103923:	e8 40 c7 ff ff       	call   f0100068 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103928:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010392b:	c1 e2 16             	shl    $0x16,%edx
f010392e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103931:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103936:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010393d:	01 
f010393e:	74 17                	je     f0103957 <env_free+0x100>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103940:	83 ec 08             	sub    $0x8,%esp
f0103943:	89 d8                	mov    %ebx,%eax
f0103945:	c1 e0 0c             	shl    $0xc,%eax
f0103948:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010394b:	50                   	push   %eax
f010394c:	ff 77 60             	pushl  0x60(%edi)
f010394f:	e8 d8 de ff ff       	call   f010182c <page_remove>
f0103954:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103957:	43                   	inc    %ebx
f0103958:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010395e:	75 d6                	jne    f0103936 <env_free+0xdf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103960:	8b 47 60             	mov    0x60(%edi),%eax
f0103963:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103966:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010396d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103970:	3b 05 88 5e 2e f0    	cmp    0xf02e5e88,%eax
f0103976:	72 14                	jb     f010398c <env_free+0x135>
		panic("pa2page called with invalid pa");
f0103978:	83 ec 04             	sub    $0x4,%esp
f010397b:	68 f0 70 10 f0       	push   $0xf01070f0
f0103980:	6a 51                	push   $0x51
f0103982:	68 fd 78 10 f0       	push   $0xf01078fd
f0103987:	e8 dc c6 ff ff       	call   f0100068 <_panic>
		page_decref(pa2page(pa));
f010398c:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010398f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103992:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0103999:	03 05 90 5e 2e f0    	add    0xf02e5e90,%eax
f010399f:	50                   	push   %eax
f01039a0:	e8 d2 dc ff ff       	call   f0101677 <page_decref>
f01039a5:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01039a8:	ff 45 e0             	incl   -0x20(%ebp)
f01039ab:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01039b2:	0f 85 27 ff ff ff    	jne    f01038df <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01039b8:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039c0:	77 15                	ja     f01039d7 <env_free+0x180>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039c2:	50                   	push   %eax
f01039c3:	68 64 65 10 f0       	push   $0xf0106564
f01039c8:	68 d2 01 00 00       	push   $0x1d2
f01039cd:	68 0f 7c 10 f0       	push   $0xf0107c0f
f01039d2:	e8 91 c6 ff ff       	call   f0100068 <_panic>
	e->env_pgdir = 0;
f01039d7:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01039de:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01039e3:	c1 e8 0c             	shr    $0xc,%eax
f01039e6:	3b 05 88 5e 2e f0    	cmp    0xf02e5e88,%eax
f01039ec:	72 14                	jb     f0103a02 <env_free+0x1ab>
		panic("pa2page called with invalid pa");
f01039ee:	83 ec 04             	sub    $0x4,%esp
f01039f1:	68 f0 70 10 f0       	push   $0xf01070f0
f01039f6:	6a 51                	push   $0x51
f01039f8:	68 fd 78 10 f0       	push   $0xf01078fd
f01039fd:	e8 66 c6 ff ff       	call   f0100068 <_panic>
	page_decref(pa2page(pa));
f0103a02:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103a05:	c1 e0 03             	shl    $0x3,%eax
f0103a08:	03 05 90 5e 2e f0    	add    0xf02e5e90,%eax
f0103a0e:	50                   	push   %eax
f0103a0f:	e8 63 dc ff ff       	call   f0101677 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103a14:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103a1b:	a1 40 52 2e f0       	mov    0xf02e5240,%eax
f0103a20:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103a23:	89 3d 40 52 2e f0    	mov    %edi,0xf02e5240
f0103a29:	83 c4 10             	add    $0x10,%esp
}
f0103a2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a2f:	5b                   	pop    %ebx
f0103a30:	5e                   	pop    %esi
f0103a31:	5f                   	pop    %edi
f0103a32:	c9                   	leave  
f0103a33:	c3                   	ret    

f0103a34 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103a34:	55                   	push   %ebp
f0103a35:	89 e5                	mov    %esp,%ebp
f0103a37:	53                   	push   %ebx
f0103a38:	83 ec 04             	sub    $0x4,%esp
f0103a3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103a3e:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103a42:	75 23                	jne    f0103a67 <env_destroy+0x33>
f0103a44:	e8 37 24 00 00       	call   f0105e80 <cpunum>
f0103a49:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a50:	29 c2                	sub    %eax,%edx
f0103a52:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a55:	39 1c 85 28 60 2e f0 	cmp    %ebx,-0xfd19fd8(,%eax,4)
f0103a5c:	74 09                	je     f0103a67 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103a5e:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103a65:	eb 3d                	jmp    f0103aa4 <env_destroy+0x70>
	}

	env_free(e);
f0103a67:	83 ec 0c             	sub    $0xc,%esp
f0103a6a:	53                   	push   %ebx
f0103a6b:	e8 e7 fd ff ff       	call   f0103857 <env_free>

	if (curenv == e) {
f0103a70:	e8 0b 24 00 00       	call   f0105e80 <cpunum>
f0103a75:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a7c:	29 c2                	sub    %eax,%edx
f0103a7e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a81:	83 c4 10             	add    $0x10,%esp
f0103a84:	39 1c 85 28 60 2e f0 	cmp    %ebx,-0xfd19fd8(,%eax,4)
f0103a8b:	75 17                	jne    f0103aa4 <env_destroy+0x70>
		curenv = NULL;
f0103a8d:	e8 ee 23 00 00       	call   f0105e80 <cpunum>
f0103a92:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a95:	c7 80 28 60 2e f0 00 	movl   $0x0,-0xfd19fd8(%eax)
f0103a9c:	00 00 00 
		sched_yield();
f0103a9f:	e8 6b 0c 00 00       	call   f010470f <sched_yield>
	}
}
f0103aa4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103aa7:	c9                   	leave  
f0103aa8:	c3                   	ret    

f0103aa9 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103aa9:	55                   	push   %ebp
f0103aaa:	89 e5                	mov    %esp,%ebp
f0103aac:	53                   	push   %ebx
f0103aad:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103ab0:	e8 cb 23 00 00       	call   f0105e80 <cpunum>
f0103ab5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103abc:	29 c2                	sub    %eax,%edx
f0103abe:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ac1:	8b 1c 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%ebx
f0103ac8:	e8 b3 23 00 00       	call   f0105e80 <cpunum>
f0103acd:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103ad0:	8b 65 08             	mov    0x8(%ebp),%esp
f0103ad3:	61                   	popa   
f0103ad4:	07                   	pop    %es
f0103ad5:	1f                   	pop    %ds
f0103ad6:	83 c4 08             	add    $0x8,%esp
f0103ad9:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103ada:	83 ec 04             	sub    $0x4,%esp
f0103add:	68 6d 7c 10 f0       	push   $0xf0107c6d
f0103ae2:	68 08 02 00 00       	push   $0x208
f0103ae7:	68 0f 7c 10 f0       	push   $0xf0107c0f
f0103aec:	e8 77 c5 ff ff       	call   f0100068 <_panic>

f0103af1 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103af1:	55                   	push   %ebp
f0103af2:	89 e5                	mov    %esp,%ebp
f0103af4:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// cprintf("I am in env_run\n");
	
    if (curenv != NULL) {
f0103af7:	e8 84 23 00 00       	call   f0105e80 <cpunum>
f0103afc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b03:	29 c2                	sub    %eax,%edx
f0103b05:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b08:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f0103b0f:	00 
f0103b10:	74 3d                	je     f0103b4f <env_run+0x5e>
        // context switch
        if (curenv->env_status == ENV_RUNNING) {
f0103b12:	e8 69 23 00 00       	call   f0105e80 <cpunum>
f0103b17:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b1e:	29 c2                	sub    %eax,%edx
f0103b20:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b23:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0103b2a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103b2e:	75 1f                	jne    f0103b4f <env_run+0x5e>
            curenv->env_status = ENV_RUNNABLE;
f0103b30:	e8 4b 23 00 00       	call   f0105e80 <cpunum>
f0103b35:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b3c:	29 c2                	sub    %eax,%edx
f0103b3e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b41:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0103b48:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
        }
        // how about other env_status ? e.g. like ENV_DYING ?
    }
    curenv = e;
f0103b4f:	e8 2c 23 00 00       	call   f0105e80 <cpunum>
f0103b54:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b5b:	29 c2                	sub    %eax,%edx
f0103b5d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b60:	8b 55 08             	mov    0x8(%ebp),%edx
f0103b63:	89 14 85 28 60 2e f0 	mov    %edx,-0xfd19fd8(,%eax,4)
    curenv->env_status = ENV_RUNNING;
f0103b6a:	e8 11 23 00 00       	call   f0105e80 <cpunum>
f0103b6f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b76:	29 c2                	sub    %eax,%edx
f0103b78:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b7b:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0103b82:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f0103b89:	e8 f2 22 00 00       	call   f0105e80 <cpunum>
f0103b8e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b95:	29 c2                	sub    %eax,%edx
f0103b97:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b9a:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0103ba1:	ff 40 58             	incl   0x58(%eax)
    
    lcr3(PADDR(curenv->env_pgdir));
f0103ba4:	e8 d7 22 00 00       	call   f0105e80 <cpunum>
f0103ba9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103bb0:	29 c2                	sub    %eax,%edx
f0103bb2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103bb5:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0103bbc:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bbf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bc4:	77 15                	ja     f0103bdb <env_run+0xea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bc6:	50                   	push   %eax
f0103bc7:	68 64 65 10 f0       	push   $0xf0106564
f0103bcc:	68 33 02 00 00       	push   $0x233
f0103bd1:	68 0f 7c 10 f0       	push   $0xf0107c0f
f0103bd6:	e8 8d c4 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103bdb:	05 00 00 00 10       	add    $0x10000000,%eax
f0103be0:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103be3:	83 ec 0c             	sub    $0xc,%esp
f0103be6:	68 40 84 12 f0       	push   $0xf0128440
f0103beb:	e8 02 26 00 00       	call   f01061f2 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103bf0:	f3 90                	pause  
    unlock_kernel();
    env_pop_tf(&curenv->env_tf);    
f0103bf2:	e8 89 22 00 00       	call   f0105e80 <cpunum>
f0103bf7:	83 c4 04             	add    $0x4,%esp
f0103bfa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c01:	29 c2                	sub    %eax,%edx
f0103c03:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c06:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f0103c0d:	e8 97 fe ff ff       	call   f0103aa9 <env_pop_tf>
	...

f0103c14 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103c14:	55                   	push   %ebp
f0103c15:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c17:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c1c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c1f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103c20:	b2 71                	mov    $0x71,%dl
f0103c22:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103c23:	0f b6 c0             	movzbl %al,%eax
}
f0103c26:	c9                   	leave  
f0103c27:	c3                   	ret    

f0103c28 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103c28:	55                   	push   %ebp
f0103c29:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c2b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c30:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c33:	ee                   	out    %al,(%dx)
f0103c34:	b2 71                	mov    $0x71,%dl
f0103c36:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c39:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103c3a:	c9                   	leave  
f0103c3b:	c3                   	ret    

f0103c3c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103c3c:	55                   	push   %ebp
f0103c3d:	89 e5                	mov    %esp,%ebp
f0103c3f:	56                   	push   %esi
f0103c40:	53                   	push   %ebx
f0103c41:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c44:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103c46:	66 a3 90 83 12 f0    	mov    %ax,0xf0128390
	if (!didinit)
f0103c4c:	80 3d 44 52 2e f0 00 	cmpb   $0x0,0xf02e5244
f0103c53:	74 5a                	je     f0103caf <irq_setmask_8259A+0x73>
f0103c55:	ba 21 00 00 00       	mov    $0x21,%edx
f0103c5a:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103c5b:	89 f0                	mov    %esi,%eax
f0103c5d:	66 c1 e8 08          	shr    $0x8,%ax
f0103c61:	b2 a1                	mov    $0xa1,%dl
f0103c63:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103c64:	83 ec 0c             	sub    $0xc,%esp
f0103c67:	68 79 7c 10 f0       	push   $0xf0107c79
f0103c6c:	e8 e4 00 00 00       	call   f0103d55 <cprintf>
f0103c71:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103c74:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103c79:	0f b7 f6             	movzwl %si,%esi
f0103c7c:	f7 d6                	not    %esi
f0103c7e:	89 f0                	mov    %esi,%eax
f0103c80:	88 d9                	mov    %bl,%cl
f0103c82:	d3 f8                	sar    %cl,%eax
f0103c84:	a8 01                	test   $0x1,%al
f0103c86:	74 11                	je     f0103c99 <irq_setmask_8259A+0x5d>
			cprintf(" %d", i);
f0103c88:	83 ec 08             	sub    $0x8,%esp
f0103c8b:	53                   	push   %ebx
f0103c8c:	68 6f 81 10 f0       	push   $0xf010816f
f0103c91:	e8 bf 00 00 00       	call   f0103d55 <cprintf>
f0103c96:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103c99:	43                   	inc    %ebx
f0103c9a:	83 fb 10             	cmp    $0x10,%ebx
f0103c9d:	75 df                	jne    f0103c7e <irq_setmask_8259A+0x42>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103c9f:	83 ec 0c             	sub    $0xc,%esp
f0103ca2:	68 af 68 10 f0       	push   $0xf01068af
f0103ca7:	e8 a9 00 00 00       	call   f0103d55 <cprintf>
f0103cac:	83 c4 10             	add    $0x10,%esp
}
f0103caf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103cb2:	5b                   	pop    %ebx
f0103cb3:	5e                   	pop    %esi
f0103cb4:	c9                   	leave  
f0103cb5:	c3                   	ret    

f0103cb6 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103cb6:	55                   	push   %ebp
f0103cb7:	89 e5                	mov    %esp,%ebp
f0103cb9:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f0103cbc:	c6 05 44 52 2e f0 01 	movb   $0x1,0xf02e5244
f0103cc3:	ba 21 00 00 00       	mov    $0x21,%edx
f0103cc8:	b0 ff                	mov    $0xff,%al
f0103cca:	ee                   	out    %al,(%dx)
f0103ccb:	b2 a1                	mov    $0xa1,%dl
f0103ccd:	ee                   	out    %al,(%dx)
f0103cce:	b2 20                	mov    $0x20,%dl
f0103cd0:	b0 11                	mov    $0x11,%al
f0103cd2:	ee                   	out    %al,(%dx)
f0103cd3:	b2 21                	mov    $0x21,%dl
f0103cd5:	b0 20                	mov    $0x20,%al
f0103cd7:	ee                   	out    %al,(%dx)
f0103cd8:	b0 04                	mov    $0x4,%al
f0103cda:	ee                   	out    %al,(%dx)
f0103cdb:	b0 03                	mov    $0x3,%al
f0103cdd:	ee                   	out    %al,(%dx)
f0103cde:	b2 a0                	mov    $0xa0,%dl
f0103ce0:	b0 11                	mov    $0x11,%al
f0103ce2:	ee                   	out    %al,(%dx)
f0103ce3:	b2 a1                	mov    $0xa1,%dl
f0103ce5:	b0 28                	mov    $0x28,%al
f0103ce7:	ee                   	out    %al,(%dx)
f0103ce8:	b0 02                	mov    $0x2,%al
f0103cea:	ee                   	out    %al,(%dx)
f0103ceb:	b0 01                	mov    $0x1,%al
f0103ced:	ee                   	out    %al,(%dx)
f0103cee:	b2 20                	mov    $0x20,%dl
f0103cf0:	b0 68                	mov    $0x68,%al
f0103cf2:	ee                   	out    %al,(%dx)
f0103cf3:	b0 0a                	mov    $0xa,%al
f0103cf5:	ee                   	out    %al,(%dx)
f0103cf6:	b2 a0                	mov    $0xa0,%dl
f0103cf8:	b0 68                	mov    $0x68,%al
f0103cfa:	ee                   	out    %al,(%dx)
f0103cfb:	b0 0a                	mov    $0xa,%al
f0103cfd:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103cfe:	66 a1 90 83 12 f0    	mov    0xf0128390,%ax
f0103d04:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103d08:	74 0f                	je     f0103d19 <pic_init+0x63>
		irq_setmask_8259A(irq_mask_8259A);
f0103d0a:	83 ec 0c             	sub    $0xc,%esp
f0103d0d:	0f b7 c0             	movzwl %ax,%eax
f0103d10:	50                   	push   %eax
f0103d11:	e8 26 ff ff ff       	call   f0103c3c <irq_setmask_8259A>
f0103d16:	83 c4 10             	add    $0x10,%esp
}
f0103d19:	c9                   	leave  
f0103d1a:	c3                   	ret    
	...

f0103d1c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103d1c:	55                   	push   %ebp
f0103d1d:	89 e5                	mov    %esp,%ebp
f0103d1f:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103d22:	ff 75 08             	pushl  0x8(%ebp)
f0103d25:	e8 75 ca ff ff       	call   f010079f <cputchar>
f0103d2a:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0103d2d:	c9                   	leave  
f0103d2e:	c3                   	ret    

f0103d2f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103d2f:	55                   	push   %ebp
f0103d30:	89 e5                	mov    %esp,%ebp
f0103d32:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103d35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103d3c:	ff 75 0c             	pushl  0xc(%ebp)
f0103d3f:	ff 75 08             	pushl  0x8(%ebp)
f0103d42:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103d45:	50                   	push   %eax
f0103d46:	68 1c 3d 10 f0       	push   $0xf0103d1c
f0103d4b:	e8 69 14 00 00       	call   f01051b9 <vprintfmt>
	return cnt;
}
f0103d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d53:	c9                   	leave  
f0103d54:	c3                   	ret    

f0103d55 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103d55:	55                   	push   %ebp
f0103d56:	89 e5                	mov    %esp,%ebp
f0103d58:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103d5b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103d5e:	50                   	push   %eax
f0103d5f:	ff 75 08             	pushl  0x8(%ebp)
f0103d62:	e8 c8 ff ff ff       	call   f0103d2f <vcprintf>
	va_end(ap);

	return cnt;
}
f0103d67:	c9                   	leave  
f0103d68:	c3                   	ret    
f0103d69:	00 00                	add    %al,(%eax)
	...

f0103d6c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103d6c:	55                   	push   %ebp
f0103d6d:	89 e5                	mov    %esp,%ebp
f0103d6f:	57                   	push   %edi
f0103d70:	56                   	push   %esi
f0103d71:	53                   	push   %ebx
f0103d72:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
    
    int cpu_id = thiscpu->cpu_id;
f0103d75:	e8 06 21 00 00       	call   f0105e80 <cpunum>
f0103d7a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d81:	29 c2                	sub    %eax,%edx
f0103d83:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d86:	0f b6 34 85 20 60 2e 	movzbl -0xfd19fe0(,%eax,4),%esi
f0103d8d:	f0 
    
    // Setup a TSS so that we get the right stack
	// when we trap to the kernel.
    thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id * (KSTKSIZE + KSTKGAP);
f0103d8e:	e8 ed 20 00 00       	call   f0105e80 <cpunum>
f0103d93:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d9a:	29 c2                	sub    %eax,%edx
f0103d9c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d9f:	89 f2                	mov    %esi,%edx
f0103da1:	f7 da                	neg    %edx
f0103da3:	c1 e2 10             	shl    $0x10,%edx
f0103da6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103dac:	89 14 85 30 60 2e f0 	mov    %edx,-0xfd19fd0(,%eax,4)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103db3:	e8 c8 20 00 00       	call   f0105e80 <cpunum>
f0103db8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103dbf:	29 c2                	sub    %eax,%edx
f0103dc1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103dc4:	66 c7 04 85 34 60 2e 	movw   $0x10,-0xfd19fcc(,%eax,4)
f0103dcb:	f0 10 00 

    gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103dce:	8d 5e 05             	lea    0x5(%esi),%ebx
f0103dd1:	e8 aa 20 00 00       	call   f0105e80 <cpunum>
f0103dd6:	89 c7                	mov    %eax,%edi
f0103dd8:	e8 a3 20 00 00       	call   f0105e80 <cpunum>
f0103ddd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103de0:	e8 9b 20 00 00       	call   f0105e80 <cpunum>
f0103de5:	66 c7 04 dd 20 83 12 	movw   $0x68,-0xfed7ce0(,%ebx,8)
f0103dec:	f0 68 00 
f0103def:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0103df6:	29 fa                	sub    %edi,%edx
f0103df8:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103dfb:	8d 14 95 2c 60 2e f0 	lea    -0xfd19fd4(,%edx,4),%edx
f0103e02:	66 89 14 dd 22 83 12 	mov    %dx,-0xfed7cde(,%ebx,8)
f0103e09:	f0 
f0103e0a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103e0d:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0103e14:	29 ca                	sub    %ecx,%edx
f0103e16:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0103e19:	8d 14 95 2c 60 2e f0 	lea    -0xfd19fd4(,%edx,4),%edx
f0103e20:	c1 ea 10             	shr    $0x10,%edx
f0103e23:	88 14 dd 24 83 12 f0 	mov    %dl,-0xfed7cdc(,%ebx,8)
f0103e2a:	c6 04 dd 26 83 12 f0 	movb   $0x40,-0xfed7cda(,%ebx,8)
f0103e31:	40 
f0103e32:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103e39:	29 c2                	sub    %eax,%edx
f0103e3b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103e3e:	8d 04 85 2c 60 2e f0 	lea    -0xfd19fd4(,%eax,4),%eax
f0103e45:	c1 e8 18             	shr    $0x18,%eax
f0103e48:	88 04 dd 27 83 12 f0 	mov    %al,-0xfed7cd9(,%ebx,8)
    							sizeof(struct Taskstate), 0);

    // Initialize the TSS slot of the gdt.
    gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f0103e4f:	c6 04 dd 25 83 12 f0 	movb   $0x89,-0xfed7cdb(,%ebx,8)
f0103e56:	89 

    // Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
    ltr(GD_TSS0 + (cpu_id << 3));
f0103e57:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103e5e:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103e61:	b8 94 83 12 f0       	mov    $0xf0128394,%eax
f0103e66:	0f 01 18             	lidtl  (%eax)

    // Load the IDT
    lidt(&idt_pd);
}
f0103e69:	83 c4 1c             	add    $0x1c,%esp
f0103e6c:	5b                   	pop    %ebx
f0103e6d:	5e                   	pop    %esi
f0103e6e:	5f                   	pop    %edi
f0103e6f:	c9                   	leave  
f0103e70:	c3                   	ret    

f0103e71 <trap_init>:
}


void
trap_init(void)
{
f0103e71:	55                   	push   %ebp
f0103e72:	89 e5                	mov    %esp,%ebp
f0103e74:	83 ec 08             	sub    $0x8,%esp
f0103e77:	ba 01 00 00 00       	mov    $0x1,%edx
f0103e7c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e81:	eb 02                	jmp    f0103e85 <trap_init+0x14>
f0103e83:	40                   	inc    %eax
f0103e84:	42                   	inc    %edx
	// LAB 3: Your code here.  
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
    	if (i == T_BRKPT) {
f0103e85:	83 f8 03             	cmp    $0x3,%eax
f0103e88:	75 30                	jne    f0103eba <trap_init+0x49>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
f0103e8a:	8b 0d a8 83 12 f0    	mov    0xf01283a8,%ecx
f0103e90:	66 89 0d 78 52 2e f0 	mov    %cx,0xf02e5278
f0103e97:	66 c7 05 7a 52 2e f0 	movw   $0x8,0xf02e527a
f0103e9e:	08 00 
f0103ea0:	c6 05 7c 52 2e f0 00 	movb   $0x0,0xf02e527c
f0103ea7:	c6 05 7d 52 2e f0 ee 	movb   $0xee,0xf02e527d
f0103eae:	c1 e9 10             	shr    $0x10,%ecx
f0103eb1:	66 89 0d 7e 52 2e f0 	mov    %cx,0xf02e527e
f0103eb8:	eb c9                	jmp    f0103e83 <trap_init+0x12>
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f0103eba:	8b 0c 85 9c 83 12 f0 	mov    -0xfed7c64(,%eax,4),%ecx
f0103ec1:	66 89 0c c5 60 52 2e 	mov    %cx,-0xfd1ada0(,%eax,8)
f0103ec8:	f0 
f0103ec9:	66 c7 04 c5 62 52 2e 	movw   $0x8,-0xfd1ad9e(,%eax,8)
f0103ed0:	f0 08 00 
f0103ed3:	c6 04 c5 64 52 2e f0 	movb   $0x0,-0xfd1ad9c(,%eax,8)
f0103eda:	00 
f0103edb:	c6 04 c5 65 52 2e f0 	movb   $0x8e,-0xfd1ad9b(,%eax,8)
f0103ee2:	8e 
f0103ee3:	c1 e9 10             	shr    $0x10,%ecx
f0103ee6:	66 89 0c c5 66 52 2e 	mov    %cx,-0xfd1ad9a(,%eax,8)
f0103eed:	f0 

	// LAB 3: Your code here.  
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
f0103eee:	83 fa 14             	cmp    $0x14,%edx
f0103ef1:	75 90                	jne    f0103e83 <trap_init+0x12>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
    	}
    }
    SETGATE(idt[48], 0, GD_KT, vec48, 3);
f0103ef3:	b8 ec 83 12 f0       	mov    $0xf01283ec,%eax
f0103ef8:	66 a3 e0 53 2e f0    	mov    %ax,0xf02e53e0
f0103efe:	66 c7 05 e2 53 2e f0 	movw   $0x8,0xf02e53e2
f0103f05:	08 00 
f0103f07:	c6 05 e4 53 2e f0 00 	movb   $0x0,0xf02e53e4
f0103f0e:	c6 05 e5 53 2e f0 ee 	movb   $0xee,0xf02e53e5
f0103f15:	c1 e8 10             	shr    $0x10,%eax
f0103f18:	66 a3 e6 53 2e f0    	mov    %ax,0xf02e53e6

	// Per-CPU setup 
	trap_init_percpu();
f0103f1e:	e8 49 fe ff ff       	call   f0103d6c <trap_init_percpu>
}
f0103f23:	c9                   	leave  
f0103f24:	c3                   	ret    

f0103f25 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103f25:	55                   	push   %ebp
f0103f26:	89 e5                	mov    %esp,%ebp
f0103f28:	53                   	push   %ebx
f0103f29:	83 ec 0c             	sub    $0xc,%esp
f0103f2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103f2f:	ff 33                	pushl  (%ebx)
f0103f31:	68 8d 7c 10 f0       	push   $0xf0107c8d
f0103f36:	e8 1a fe ff ff       	call   f0103d55 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103f3b:	83 c4 08             	add    $0x8,%esp
f0103f3e:	ff 73 04             	pushl  0x4(%ebx)
f0103f41:	68 9c 7c 10 f0       	push   $0xf0107c9c
f0103f46:	e8 0a fe ff ff       	call   f0103d55 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103f4b:	83 c4 08             	add    $0x8,%esp
f0103f4e:	ff 73 08             	pushl  0x8(%ebx)
f0103f51:	68 ab 7c 10 f0       	push   $0xf0107cab
f0103f56:	e8 fa fd ff ff       	call   f0103d55 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103f5b:	83 c4 08             	add    $0x8,%esp
f0103f5e:	ff 73 0c             	pushl  0xc(%ebx)
f0103f61:	68 ba 7c 10 f0       	push   $0xf0107cba
f0103f66:	e8 ea fd ff ff       	call   f0103d55 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103f6b:	83 c4 08             	add    $0x8,%esp
f0103f6e:	ff 73 10             	pushl  0x10(%ebx)
f0103f71:	68 c9 7c 10 f0       	push   $0xf0107cc9
f0103f76:	e8 da fd ff ff       	call   f0103d55 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f7b:	83 c4 08             	add    $0x8,%esp
f0103f7e:	ff 73 14             	pushl  0x14(%ebx)
f0103f81:	68 d8 7c 10 f0       	push   $0xf0107cd8
f0103f86:	e8 ca fd ff ff       	call   f0103d55 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103f8b:	83 c4 08             	add    $0x8,%esp
f0103f8e:	ff 73 18             	pushl  0x18(%ebx)
f0103f91:	68 e7 7c 10 f0       	push   $0xf0107ce7
f0103f96:	e8 ba fd ff ff       	call   f0103d55 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103f9b:	83 c4 08             	add    $0x8,%esp
f0103f9e:	ff 73 1c             	pushl  0x1c(%ebx)
f0103fa1:	68 f6 7c 10 f0       	push   $0xf0107cf6
f0103fa6:	e8 aa fd ff ff       	call   f0103d55 <cprintf>
f0103fab:	83 c4 10             	add    $0x10,%esp
}
f0103fae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103fb1:	c9                   	leave  
f0103fb2:	c3                   	ret    

f0103fb3 <print_trapframe>:
    lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103fb3:	55                   	push   %ebp
f0103fb4:	89 e5                	mov    %esp,%ebp
f0103fb6:	53                   	push   %ebx
f0103fb7:	83 ec 04             	sub    $0x4,%esp
f0103fba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103fbd:	e8 be 1e 00 00       	call   f0105e80 <cpunum>
f0103fc2:	83 ec 04             	sub    $0x4,%esp
f0103fc5:	50                   	push   %eax
f0103fc6:	53                   	push   %ebx
f0103fc7:	68 5a 7d 10 f0       	push   $0xf0107d5a
f0103fcc:	e8 84 fd ff ff       	call   f0103d55 <cprintf>
	print_regs(&tf->tf_regs);
f0103fd1:	89 1c 24             	mov    %ebx,(%esp)
f0103fd4:	e8 4c ff ff ff       	call   f0103f25 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103fd9:	83 c4 08             	add    $0x8,%esp
f0103fdc:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103fe0:	50                   	push   %eax
f0103fe1:	68 78 7d 10 f0       	push   $0xf0107d78
f0103fe6:	e8 6a fd ff ff       	call   f0103d55 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103feb:	83 c4 08             	add    $0x8,%esp
f0103fee:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103ff2:	50                   	push   %eax
f0103ff3:	68 8b 7d 10 f0       	push   $0xf0107d8b
f0103ff8:	e8 58 fd ff ff       	call   f0103d55 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ffd:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104000:	83 c4 10             	add    $0x10,%esp
f0104003:	83 f8 13             	cmp    $0x13,%eax
f0104006:	77 09                	ja     f0104011 <print_trapframe+0x5e>
		return excnames[trapno];
f0104008:	8b 14 85 40 80 10 f0 	mov    -0xfef7fc0(,%eax,4),%edx
f010400f:	eb 20                	jmp    f0104031 <print_trapframe+0x7e>
	if (trapno == T_SYSCALL)
f0104011:	83 f8 30             	cmp    $0x30,%eax
f0104014:	74 0f                	je     f0104025 <print_trapframe+0x72>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104016:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104019:	83 fa 0f             	cmp    $0xf,%edx
f010401c:	77 0e                	ja     f010402c <print_trapframe+0x79>
		return "Hardware Interrupt";
f010401e:	ba 11 7d 10 f0       	mov    $0xf0107d11,%edx
f0104023:	eb 0c                	jmp    f0104031 <print_trapframe+0x7e>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0104025:	ba 05 7d 10 f0       	mov    $0xf0107d05,%edx
f010402a:	eb 05                	jmp    f0104031 <print_trapframe+0x7e>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f010402c:	ba 24 7d 10 f0       	mov    $0xf0107d24,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104031:	83 ec 04             	sub    $0x4,%esp
f0104034:	52                   	push   %edx
f0104035:	50                   	push   %eax
f0104036:	68 9e 7d 10 f0       	push   $0xf0107d9e
f010403b:	e8 15 fd ff ff       	call   f0103d55 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104040:	83 c4 10             	add    $0x10,%esp
f0104043:	3b 1d 60 5a 2e f0    	cmp    0xf02e5a60,%ebx
f0104049:	75 1a                	jne    f0104065 <print_trapframe+0xb2>
f010404b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010404f:	75 14                	jne    f0104065 <print_trapframe+0xb2>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104051:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104054:	83 ec 08             	sub    $0x8,%esp
f0104057:	50                   	push   %eax
f0104058:	68 b0 7d 10 f0       	push   $0xf0107db0
f010405d:	e8 f3 fc ff ff       	call   f0103d55 <cprintf>
f0104062:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0104065:	83 ec 08             	sub    $0x8,%esp
f0104068:	ff 73 2c             	pushl  0x2c(%ebx)
f010406b:	68 bf 7d 10 f0       	push   $0xf0107dbf
f0104070:	e8 e0 fc ff ff       	call   f0103d55 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104075:	83 c4 10             	add    $0x10,%esp
f0104078:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010407c:	75 45                	jne    f01040c3 <print_trapframe+0x110>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010407e:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104081:	a8 01                	test   $0x1,%al
f0104083:	74 07                	je     f010408c <print_trapframe+0xd9>
f0104085:	b9 33 7d 10 f0       	mov    $0xf0107d33,%ecx
f010408a:	eb 05                	jmp    f0104091 <print_trapframe+0xde>
f010408c:	b9 3e 7d 10 f0       	mov    $0xf0107d3e,%ecx
f0104091:	a8 02                	test   $0x2,%al
f0104093:	74 07                	je     f010409c <print_trapframe+0xe9>
f0104095:	ba 4a 7d 10 f0       	mov    $0xf0107d4a,%edx
f010409a:	eb 05                	jmp    f01040a1 <print_trapframe+0xee>
f010409c:	ba 50 7d 10 f0       	mov    $0xf0107d50,%edx
f01040a1:	a8 04                	test   $0x4,%al
f01040a3:	74 07                	je     f01040ac <print_trapframe+0xf9>
f01040a5:	b8 55 7d 10 f0       	mov    $0xf0107d55,%eax
f01040aa:	eb 05                	jmp    f01040b1 <print_trapframe+0xfe>
f01040ac:	b8 9f 7e 10 f0       	mov    $0xf0107e9f,%eax
f01040b1:	51                   	push   %ecx
f01040b2:	52                   	push   %edx
f01040b3:	50                   	push   %eax
f01040b4:	68 cd 7d 10 f0       	push   $0xf0107dcd
f01040b9:	e8 97 fc ff ff       	call   f0103d55 <cprintf>
f01040be:	83 c4 10             	add    $0x10,%esp
f01040c1:	eb 10                	jmp    f01040d3 <print_trapframe+0x120>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01040c3:	83 ec 0c             	sub    $0xc,%esp
f01040c6:	68 af 68 10 f0       	push   $0xf01068af
f01040cb:	e8 85 fc ff ff       	call   f0103d55 <cprintf>
f01040d0:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01040d3:	83 ec 08             	sub    $0x8,%esp
f01040d6:	ff 73 30             	pushl  0x30(%ebx)
f01040d9:	68 dc 7d 10 f0       	push   $0xf0107ddc
f01040de:	e8 72 fc ff ff       	call   f0103d55 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01040e3:	83 c4 08             	add    $0x8,%esp
f01040e6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01040ea:	50                   	push   %eax
f01040eb:	68 eb 7d 10 f0       	push   $0xf0107deb
f01040f0:	e8 60 fc ff ff       	call   f0103d55 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01040f5:	83 c4 08             	add    $0x8,%esp
f01040f8:	ff 73 38             	pushl  0x38(%ebx)
f01040fb:	68 fe 7d 10 f0       	push   $0xf0107dfe
f0104100:	e8 50 fc ff ff       	call   f0103d55 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104105:	83 c4 10             	add    $0x10,%esp
f0104108:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010410c:	74 25                	je     f0104133 <print_trapframe+0x180>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010410e:	83 ec 08             	sub    $0x8,%esp
f0104111:	ff 73 3c             	pushl  0x3c(%ebx)
f0104114:	68 0d 7e 10 f0       	push   $0xf0107e0d
f0104119:	e8 37 fc ff ff       	call   f0103d55 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010411e:	83 c4 08             	add    $0x8,%esp
f0104121:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104125:	50                   	push   %eax
f0104126:	68 1c 7e 10 f0       	push   $0xf0107e1c
f010412b:	e8 25 fc ff ff       	call   f0103d55 <cprintf>
f0104130:	83 c4 10             	add    $0x10,%esp
	}
}
f0104133:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104136:	c9                   	leave  
f0104137:	c3                   	ret    

f0104138 <page_fault_handler>:
	}
}

void
page_fault_handler(struct Trapframe *tf)
{
f0104138:	55                   	push   %ebp
f0104139:	89 e5                	mov    %esp,%ebp
f010413b:	57                   	push   %edi
f010413c:	56                   	push   %esi
f010413d:	53                   	push   %ebx
f010413e:	83 ec 1c             	sub    $0x1c,%esp
f0104141:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104144:	0f 20 d0             	mov    %cr2,%eax
f0104147:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT)
f010414a:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010414f:	75 17                	jne    f0104168 <page_fault_handler+0x30>
    	panic("page_fault_handler : page fault in kernel\n");
f0104151:	83 ec 04             	sub    $0x4,%esp
f0104154:	68 ec 7f 10 f0       	push   $0xf0107fec
f0104159:	68 3d 01 00 00       	push   $0x13d
f010415e:	68 2f 7e 10 f0       	push   $0xf0107e2f
f0104163:	e8 00 bf ff ff       	call   f0100068 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

    if (curenv->env_pgfault_upcall != NULL) {
f0104168:	e8 13 1d 00 00       	call   f0105e80 <cpunum>
f010416d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104174:	29 c2                	sub    %eax,%edx
f0104176:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104179:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0104180:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104184:	0f 84 01 01 00 00    	je     f010428b <page_fault_handler+0x153>
    	// cprintf("user page fault, exist env's page fault upcall \n");
    	// exist env's page fault upcall
		// void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

    	struct UTrapframe * ut;
    	if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp <= UXSTACKTOP - 1) {
f010418a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010418d:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f0104193:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104199:	77 25                	ja     f01041c0 <page_fault_handler+0x88>
    		// already in user exception stack, should first push an empty 32-bit word
    		ut = (struct UTrapframe *)((void *)tf->tf_esp - sizeof(struct UTrapframe) - 4);
f010419b:	83 e8 38             	sub    $0x38,%eax
f010419e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe) + 4, PTE_U | PTE_W);
f01041a1:	e8 da 1c 00 00       	call   f0105e80 <cpunum>
f01041a6:	6a 06                	push   $0x6
f01041a8:	6a 38                	push   $0x38
f01041aa:	ff 75 e0             	pushl  -0x20(%ebp)
f01041ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01041b0:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f01041b6:	e8 83 f1 ff ff       	call   f010333e <user_mem_assert>
f01041bb:	83 c4 10             	add    $0x10,%esp
f01041be:	eb 26                	jmp    f01041e6 <page_fault_handler+0xae>
    	} else {
    		// it's the first time in user exception stack
    		ut = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe), PTE_U | PTE_W);
f01041c0:	e8 bb 1c 00 00       	call   f0105e80 <cpunum>
f01041c5:	6a 06                	push   $0x6
f01041c7:	6a 34                	push   $0x34
f01041c9:	68 cc ff bf ee       	push   $0xeebfffcc
f01041ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01041d1:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f01041d7:	e8 62 f1 ff ff       	call   f010333e <user_mem_assert>
f01041dc:	83 c4 10             	add    $0x10,%esp
    		// already in user exception stack, should first push an empty 32-bit word
    		ut = (struct UTrapframe *)((void *)tf->tf_esp - sizeof(struct UTrapframe) - 4);
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe) + 4, PTE_U | PTE_W);
    	} else {
    		// it's the first time in user exception stack
    		ut = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f01041df:	c7 45 e0 cc ff bf ee 	movl   $0xeebfffcc,-0x20(%ebp)
	    	user_mem_assert(curenv, (void *)ut, sizeof(struct UTrapframe), PTE_U | PTE_W);
    	}
    	
    	ut->utf_esp = tf->tf_esp;
f01041e6:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01041e9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01041ec:	89 42 30             	mov    %eax,0x30(%edx)
    	ut->utf_eflags = tf->tf_eflags;
f01041ef:	8b 43 38             	mov    0x38(%ebx),%eax
f01041f2:	89 42 2c             	mov    %eax,0x2c(%edx)
    	ut->utf_eip = tf->tf_eip;
f01041f5:	8b 43 30             	mov    0x30(%ebx),%eax
f01041f8:	89 42 28             	mov    %eax,0x28(%edx)
		ut->utf_regs = tf->tf_regs;
f01041fb:	89 d7                	mov    %edx,%edi
f01041fd:	83 c7 08             	add    $0x8,%edi
f0104200:	89 de                	mov    %ebx,%esi
f0104202:	b8 20 00 00 00       	mov    $0x20,%eax
f0104207:	f7 c7 01 00 00 00    	test   $0x1,%edi
f010420d:	74 03                	je     f0104212 <page_fault_handler+0xda>
f010420f:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104210:	b0 1f                	mov    $0x1f,%al
f0104212:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104218:	74 05                	je     f010421f <page_fault_handler+0xe7>
f010421a:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010421c:	83 e8 02             	sub    $0x2,%eax
f010421f:	89 c1                	mov    %eax,%ecx
f0104221:	c1 e9 02             	shr    $0x2,%ecx
f0104224:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104226:	a8 02                	test   $0x2,%al
f0104228:	74 02                	je     f010422c <page_fault_handler+0xf4>
f010422a:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010422c:	a8 01                	test   $0x1,%al
f010422e:	74 01                	je     f0104231 <page_fault_handler+0xf9>
f0104230:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		ut->utf_err = tf->tf_err;
f0104231:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104234:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104237:	89 42 04             	mov    %eax,0x4(%edx)
		ut->utf_fault_va = fault_va;
f010423a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010423d:	89 02                	mov    %eax,(%edx)

		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f010423f:	e8 3c 1c 00 00       	call   f0105e80 <cpunum>
f0104244:	6b c0 74             	imul   $0x74,%eax,%eax
f0104247:	8b 98 28 60 2e f0    	mov    -0xfd19fd8(%eax),%ebx
f010424d:	e8 2e 1c 00 00       	call   f0105e80 <cpunum>
f0104252:	6b c0 74             	imul   $0x74,%eax,%eax
f0104255:	8b 80 28 60 2e f0    	mov    -0xfd19fd8(%eax),%eax
f010425b:	8b 40 64             	mov    0x64(%eax),%eax
f010425e:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (uint32_t)ut;
f0104261:	e8 1a 1c 00 00       	call   f0105e80 <cpunum>
f0104266:	6b c0 74             	imul   $0x74,%eax,%eax
f0104269:	8b 80 28 60 2e f0    	mov    -0xfd19fd8(%eax),%eax
f010426f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104272:	89 50 3c             	mov    %edx,0x3c(%eax)
    	env_run(curenv);
f0104275:	e8 06 1c 00 00       	call   f0105e80 <cpunum>
f010427a:	83 ec 0c             	sub    $0xc,%esp
f010427d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104280:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f0104286:	e8 66 f8 ff ff       	call   f0103af1 <env_run>
    } else {
    	// cprintf("user page fault, env_pgfault_upcall == NULL\n");
   	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010428b:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f010428e:	e8 ed 1b 00 00       	call   f0105e80 <cpunum>
    } else {
    	// cprintf("user page fault, env_pgfault_upcall == NULL\n");
   	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104293:	56                   	push   %esi
f0104294:	ff 75 e4             	pushl  -0x1c(%ebp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104297:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010429e:	29 c2                	sub    %eax,%edx
f01042a0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01042a3:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
    } else {
    	// cprintf("user page fault, env_pgfault_upcall == NULL\n");
   	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01042aa:	ff 70 48             	pushl  0x48(%eax)
f01042ad:	68 18 80 10 f0       	push   $0xf0108018
f01042b2:	e8 9e fa ff ff       	call   f0103d55 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01042b7:	89 1c 24             	mov    %ebx,(%esp)
f01042ba:	e8 f4 fc ff ff       	call   f0103fb3 <print_trapframe>
	env_destroy(curenv);
f01042bf:	e8 bc 1b 00 00       	call   f0105e80 <cpunum>
f01042c4:	83 c4 04             	add    $0x4,%esp
f01042c7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01042ce:	29 c2                	sub    %eax,%edx
f01042d0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01042d3:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f01042da:	e8 55 f7 ff ff       	call   f0103a34 <env_destroy>
f01042df:	83 c4 10             	add    $0x10,%esp
}
f01042e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01042e5:	5b                   	pop    %ebx
f01042e6:	5e                   	pop    %esi
f01042e7:	5f                   	pop    %edi
f01042e8:	c9                   	leave  
f01042e9:	c3                   	ret    

f01042ea <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01042ea:	55                   	push   %ebp
f01042eb:	89 e5                	mov    %esp,%ebp
f01042ed:	57                   	push   %edi
f01042ee:	56                   	push   %esi
f01042ef:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01042f2:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01042f3:	83 3d 80 5e 2e f0 00 	cmpl   $0x0,0xf02e5e80
f01042fa:	74 01                	je     f01042fd <trap+0x13>
		asm volatile("hlt");
f01042fc:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01042fd:	e8 7e 1b 00 00       	call   f0105e80 <cpunum>
f0104302:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104309:	29 c2                	sub    %eax,%edx
f010430b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010430e:	8d 14 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104315:	b8 01 00 00 00       	mov    $0x1,%eax
f010431a:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010431e:	83 f8 02             	cmp    $0x2,%eax
f0104321:	75 10                	jne    f0104333 <trap+0x49>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104323:	83 ec 0c             	sub    $0xc,%esp
f0104326:	68 40 84 12 f0       	push   $0xf0128440
f010432b:	e8 07 1e 00 00       	call   f0106137 <spin_lock>
f0104330:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104333:	9c                   	pushf  
f0104334:	58                   	pop    %eax
		lock_kernel();

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104335:	f6 c4 02             	test   $0x2,%ah
f0104338:	74 19                	je     f0104353 <trap+0x69>
f010433a:	68 3b 7e 10 f0       	push   $0xf0107e3b
f010433f:	68 17 79 10 f0       	push   $0xf0107917
f0104344:	68 04 01 00 00       	push   $0x104
f0104349:	68 2f 7e 10 f0       	push   $0xf0107e2f
f010434e:	e8 15 bd ff ff       	call   f0100068 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104353:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104357:	83 e0 03             	and    $0x3,%eax
f010435a:	83 f8 03             	cmp    $0x3,%eax
f010435d:	0f 85 dc 00 00 00    	jne    f010443f <trap+0x155>
f0104363:	83 ec 0c             	sub    $0xc,%esp
f0104366:	68 40 84 12 f0       	push   $0xf0128440
f010436b:	e8 c7 1d 00 00       	call   f0106137 <spin_lock>
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();

		assert(curenv);
f0104370:	e8 0b 1b 00 00       	call   f0105e80 <cpunum>
f0104375:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010437c:	29 c2                	sub    %eax,%edx
f010437e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104381:	83 c4 10             	add    $0x10,%esp
f0104384:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f010438b:	00 
f010438c:	75 19                	jne    f01043a7 <trap+0xbd>
f010438e:	68 54 7e 10 f0       	push   $0xf0107e54
f0104393:	68 17 79 10 f0       	push   $0xf0107917
f0104398:	68 0d 01 00 00       	push   $0x10d
f010439d:	68 2f 7e 10 f0       	push   $0xf0107e2f
f01043a2:	e8 c1 bc ff ff       	call   f0100068 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01043a7:	e8 d4 1a 00 00       	call   f0105e80 <cpunum>
f01043ac:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01043b3:	29 c2                	sub    %eax,%edx
f01043b5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01043b8:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f01043bf:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01043c3:	75 41                	jne    f0104406 <trap+0x11c>
			env_free(curenv);
f01043c5:	e8 b6 1a 00 00       	call   f0105e80 <cpunum>
f01043ca:	83 ec 0c             	sub    $0xc,%esp
f01043cd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01043d4:	29 c2                	sub    %eax,%edx
f01043d6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01043d9:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f01043e0:	e8 72 f4 ff ff       	call   f0103857 <env_free>
			curenv = NULL;
f01043e5:	e8 96 1a 00 00       	call   f0105e80 <cpunum>
f01043ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01043f1:	29 c2                	sub    %eax,%edx
f01043f3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01043f6:	c7 04 85 28 60 2e f0 	movl   $0x0,-0xfd19fd8(,%eax,4)
f01043fd:	00 00 00 00 
			sched_yield();
f0104401:	e8 09 03 00 00       	call   f010470f <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104406:	e8 75 1a 00 00       	call   f0105e80 <cpunum>
f010440b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104412:	29 c2                	sub    %eax,%edx
f0104414:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104417:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f010441e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104423:	89 c7                	mov    %eax,%edi
f0104425:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104427:	e8 54 1a 00 00       	call   f0105e80 <cpunum>
f010442c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104433:	29 c2                	sub    %eax,%edx
f0104435:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104438:	8b 34 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010443f:	89 35 60 5a 2e f0    	mov    %esi,0xf02e5a60
	// LAB 3: Your code here.
    // cprintf("CPU %d, TRAP NUM : %u\n", cpunum(), tf->tf_trapno);
    
    int r;

	if (tf->tf_trapno == T_DEBUG) {
f0104445:	8b 46 28             	mov    0x28(%esi),%eax
f0104448:	83 f8 01             	cmp    $0x1,%eax
f010444b:	75 11                	jne    f010445e <trap+0x174>
		monitor(tf);
f010444d:	83 ec 0c             	sub    $0xc,%esp
f0104450:	56                   	push   %esi
f0104451:	e8 db cb ff ff       	call   f0101031 <monitor>
f0104456:	83 c4 10             	add    $0x10,%esp
f0104459:	e9 d7 00 00 00       	jmp    f0104535 <trap+0x24b>
		return;
	}
	if (tf->tf_trapno == T_PGFLT) {
f010445e:	83 f8 0e             	cmp    $0xe,%eax
f0104461:	75 11                	jne    f0104474 <trap+0x18a>
		page_fault_handler(tf);
f0104463:	83 ec 0c             	sub    $0xc,%esp
f0104466:	56                   	push   %esi
f0104467:	e8 cc fc ff ff       	call   f0104138 <page_fault_handler>
f010446c:	83 c4 10             	add    $0x10,%esp
f010446f:	e9 c1 00 00 00       	jmp    f0104535 <trap+0x24b>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f0104474:	83 f8 03             	cmp    $0x3,%eax
f0104477:	75 11                	jne    f010448a <trap+0x1a0>
		monitor(tf);
f0104479:	83 ec 0c             	sub    $0xc,%esp
f010447c:	56                   	push   %esi
f010447d:	e8 af cb ff ff       	call   f0101031 <monitor>
f0104482:	83 c4 10             	add    $0x10,%esp
f0104485:	e9 ab 00 00 00       	jmp    f0104535 <trap+0x24b>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f010448a:	83 f8 30             	cmp    $0x30,%eax
f010448d:	75 3a                	jne    f01044c9 <trap+0x1df>
		r = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f010448f:	83 ec 08             	sub    $0x8,%esp
f0104492:	ff 76 04             	pushl  0x4(%esi)
f0104495:	ff 36                	pushl  (%esi)
f0104497:	ff 76 10             	pushl  0x10(%esi)
f010449a:	ff 76 18             	pushl  0x18(%esi)
f010449d:	ff 76 14             	pushl  0x14(%esi)
f01044a0:	ff 76 1c             	pushl  0x1c(%esi)
f01044a3:	e8 84 03 00 00       	call   f010482c <syscall>
                       tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
        if (r < 0)
f01044a8:	83 c4 20             	add    $0x20,%esp
f01044ab:	85 c0                	test   %eax,%eax
f01044ad:	79 15                	jns    f01044c4 <trap+0x1da>
            panic("trap.c/syscall : %e\n", r);
f01044af:	50                   	push   %eax
f01044b0:	68 5b 7e 10 f0       	push   $0xf0107e5b
f01044b5:	68 d2 00 00 00       	push   $0xd2
f01044ba:	68 2f 7e 10 f0       	push   $0xf0107e2f
f01044bf:	e8 a4 bb ff ff       	call   f0100068 <_panic>
        else {
            tf->tf_regs.reg_eax = r;
f01044c4:	89 46 1c             	mov    %eax,0x1c(%esi)
f01044c7:	eb 6c                	jmp    f0104535 <trap+0x24b>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01044c9:	83 f8 27             	cmp    $0x27,%eax
f01044cc:	75 1a                	jne    f01044e8 <trap+0x1fe>
		cprintf("Spurious interrupt on irq 7\n");
f01044ce:	83 ec 0c             	sub    $0xc,%esp
f01044d1:	68 70 7e 10 f0       	push   $0xf0107e70
f01044d6:	e8 7a f8 ff ff       	call   f0103d55 <cprintf>
		print_trapframe(tf);
f01044db:	89 34 24             	mov    %esi,(%esp)
f01044de:	e8 d0 fa ff ff       	call   f0103fb3 <print_trapframe>
f01044e3:	83 c4 10             	add    $0x10,%esp
f01044e6:	eb 4d                	jmp    f0104535 <trap+0x24b>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01044e8:	83 ec 0c             	sub    $0xc,%esp
f01044eb:	56                   	push   %esi
f01044ec:	e8 c2 fa ff ff       	call   f0103fb3 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01044f1:	83 c4 10             	add    $0x10,%esp
f01044f4:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01044f9:	75 17                	jne    f0104512 <trap+0x228>
		panic("unhandled trap in kernel");
f01044fb:	83 ec 04             	sub    $0x4,%esp
f01044fe:	68 8d 7e 10 f0       	push   $0xf0107e8d
f0104503:	68 e9 00 00 00       	push   $0xe9
f0104508:	68 2f 7e 10 f0       	push   $0xf0107e2f
f010450d:	e8 56 bb ff ff       	call   f0100068 <_panic>
	else {
		env_destroy(curenv);
f0104512:	e8 69 19 00 00       	call   f0105e80 <cpunum>
f0104517:	83 ec 0c             	sub    $0xc,%esp
f010451a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104521:	29 c2                	sub    %eax,%edx
f0104523:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104526:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f010452d:	e8 02 f5 ff ff       	call   f0103a34 <env_destroy>
f0104532:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0104535:	e8 46 19 00 00       	call   f0105e80 <cpunum>
f010453a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104541:	29 c2                	sub    %eax,%edx
f0104543:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104546:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f010454d:	00 
f010454e:	74 3e                	je     f010458e <trap+0x2a4>
f0104550:	e8 2b 19 00 00       	call   f0105e80 <cpunum>
f0104555:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010455c:	29 c2                	sub    %eax,%edx
f010455e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104561:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0104568:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010456c:	75 20                	jne    f010458e <trap+0x2a4>
		// cprintf("Env\n");
		env_run(curenv);
f010456e:	e8 0d 19 00 00       	call   f0105e80 <cpunum>
f0104573:	83 ec 0c             	sub    $0xc,%esp
f0104576:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010457d:	29 c2                	sub    %eax,%edx
f010457f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104582:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f0104589:	e8 63 f5 ff ff       	call   f0103af1 <env_run>
	} else {
		// cprintf("trap sched_yield\n");
		sched_yield();
f010458e:	e8 7c 01 00 00       	call   f010470f <sched_yield>
	...

f0104594 <vec0>:
.data
.align 2
.globl vectors
vectors:
.text
	MYTH_NOEC(vec0, T_DIVIDE)
f0104594:	6a 00                	push   $0x0
f0104596:	6a 00                	push   $0x0
f0104598:	e9 55 3e 02 00       	jmp    f01283f2 <_alltraps>
f010459d:	90                   	nop

f010459e <vec1>:
 	MYTH_NOEC(vec1, T_DEBUG)
f010459e:	6a 00                	push   $0x0
f01045a0:	6a 01                	push   $0x1
f01045a2:	e9 4b 3e 02 00       	jmp    f01283f2 <_alltraps>
f01045a7:	90                   	nop

f01045a8 <vec2>:
 	MYTH_NOEC(vec2, T_NMI)
f01045a8:	6a 00                	push   $0x0
f01045aa:	6a 02                	push   $0x2
f01045ac:	e9 41 3e 02 00       	jmp    f01283f2 <_alltraps>
f01045b1:	90                   	nop

f01045b2 <vec3>:
 	MYTH_NOEC(vec3, T_BRKPT)
f01045b2:	6a 00                	push   $0x0
f01045b4:	6a 03                	push   $0x3
f01045b6:	e9 37 3e 02 00       	jmp    f01283f2 <_alltraps>
f01045bb:	90                   	nop

f01045bc <vec4>:
 	MYTH_NOEC(vec4, T_OFLOW)
f01045bc:	6a 00                	push   $0x0
f01045be:	6a 04                	push   $0x4
f01045c0:	e9 2d 3e 02 00       	jmp    f01283f2 <_alltraps>
f01045c5:	90                   	nop

f01045c6 <vec6>:
 	MYTH_NULL()
 	MYTH_NOEC(vec6, T_BOUND)
f01045c6:	6a 00                	push   $0x0
f01045c8:	6a 05                	push   $0x5
f01045ca:	e9 23 3e 02 00       	jmp    f01283f2 <_alltraps>
f01045cf:	90                   	nop

f01045d0 <vec7>:
	MYTH_NOEC(vec7, T_DEVICE)
f01045d0:	6a 00                	push   $0x0
f01045d2:	6a 07                	push   $0x7
f01045d4:	e9 19 3e 02 00       	jmp    f01283f2 <_alltraps>
f01045d9:	90                   	nop

f01045da <vec8>:
 	MYTH_NOEC(vec8, T_DBLFLT)
f01045da:	6a 00                	push   $0x0
f01045dc:	6a 08                	push   $0x8
f01045de:	e9 0f 3e 02 00       	jmp    f01283f2 <_alltraps>
f01045e3:	90                   	nop

f01045e4 <vec10>:
 	MYTH_NULL()
 	MYTH(vec10, T_TSS)
f01045e4:	6a 0a                	push   $0xa
f01045e6:	e9 07 3e 02 00       	jmp    f01283f2 <_alltraps>
f01045eb:	90                   	nop

f01045ec <vec11>:
 	MYTH(vec11, T_SEGNP)
f01045ec:	6a 0b                	push   $0xb
f01045ee:	e9 ff 3d 02 00       	jmp    f01283f2 <_alltraps>
f01045f3:	90                   	nop

f01045f4 <vec12>:
 	MYTH(vec12, T_STACK)
f01045f4:	6a 0c                	push   $0xc
f01045f6:	e9 f7 3d 02 00       	jmp    f01283f2 <_alltraps>
f01045fb:	90                   	nop

f01045fc <vec13>:
 	MYTH(vec13, T_GPFLT)
f01045fc:	6a 0d                	push   $0xd
f01045fe:	e9 ef 3d 02 00       	jmp    f01283f2 <_alltraps>
f0104603:	90                   	nop

f0104604 <vec14>:
 	MYTH(vec14, T_PGFLT) 
f0104604:	6a 0e                	push   $0xe
f0104606:	e9 e7 3d 02 00       	jmp    f01283f2 <_alltraps>
f010460b:	90                   	nop

f010460c <vec16>:
 	MYTH_NULL()
 	MYTH_NOEC(vec16, T_FPERR)
f010460c:	6a 00                	push   $0x0
f010460e:	6a 10                	push   $0x10
f0104610:	e9 dd 3d 02 00       	jmp    f01283f2 <_alltraps>
f0104615:	90                   	nop

f0104616 <vec17>:
 	MYTH(vec17, T_ALIGN)
f0104616:	6a 11                	push   $0x11
f0104618:	e9 d5 3d 02 00       	jmp    f01283f2 <_alltraps>
f010461d:	90                   	nop

f010461e <vec18>:
 	MYTH_NOEC(vec18, T_MCHK)
f010461e:	6a 00                	push   $0x0
f0104620:	6a 12                	push   $0x12
f0104622:	e9 cb 3d 02 00       	jmp    f01283f2 <_alltraps>
f0104627:	90                   	nop

f0104628 <vec19>:
 	MYTH_NOEC(vec19, T_SIMDERR)
f0104628:	6a 00                	push   $0x0
f010462a:	6a 13                	push   $0x13
f010462c:	e9 c1 3d 02 00       	jmp    f01283f2 <_alltraps>
f0104631:	00 00                	add    %al,(%eax)
	...

f0104634 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104634:	55                   	push   %ebp
f0104635:	89 e5                	mov    %esp,%ebp
f0104637:	83 ec 08             	sub    $0x8,%esp
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010463a:	8b 15 3c 52 2e f0    	mov    0xf02e523c,%edx
f0104640:	8b 42 54             	mov    0x54(%edx),%eax
f0104643:	83 e8 02             	sub    $0x2,%eax
f0104646:	83 f8 01             	cmp    $0x1,%eax
f0104649:	76 46                	jbe    f0104691 <sched_halt+0x5d>
			else cprintf("ENV_RUNNING\n");
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
f010464b:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104650:	8b 8a d0 00 00 00    	mov    0xd0(%edx),%ecx
f0104656:	83 e9 02             	sub    $0x2,%ecx
f0104659:	83 f9 01             	cmp    $0x1,%ecx
f010465c:	76 0d                	jbe    f010466b <sched_halt+0x37>
			else cprintf("ENV_RUNNING\n");
		}
	}
	*/

	for (i = 0; i < NENV; i++) {
f010465e:	40                   	inc    %eax
f010465f:	83 c2 7c             	add    $0x7c,%edx
f0104662:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104667:	75 e7                	jne    f0104650 <sched_halt+0x1c>
f0104669:	eb 07                	jmp    f0104672 <sched_halt+0x3e>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	
	if (i == NENV) {
f010466b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104670:	75 1f                	jne    f0104691 <sched_halt+0x5d>
		cprintf("No runnable environments in the system!\n");
f0104672:	83 ec 0c             	sub    $0xc,%esp
f0104675:	68 90 80 10 f0       	push   $0xf0108090
f010467a:	e8 d6 f6 ff ff       	call   f0103d55 <cprintf>
f010467f:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104682:	83 ec 0c             	sub    $0xc,%esp
f0104685:	6a 00                	push   $0x0
f0104687:	e8 a5 c9 ff ff       	call   f0101031 <monitor>
f010468c:	83 c4 10             	add    $0x10,%esp
f010468f:	eb f1                	jmp    f0104682 <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104691:	e8 ea 17 00 00       	call   f0105e80 <cpunum>
f0104696:	6b c0 74             	imul   $0x74,%eax,%eax
f0104699:	c7 80 28 60 2e f0 00 	movl   $0x0,-0xfd19fd8(%eax)
f01046a0:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01046a3:	a1 8c 5e 2e f0       	mov    0xf02e5e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01046a8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01046ad:	77 12                	ja     f01046c1 <sched_halt+0x8d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01046af:	50                   	push   %eax
f01046b0:	68 64 65 10 f0       	push   $0xf0106564
f01046b5:	6a 57                	push   $0x57
f01046b7:	68 b9 80 10 f0       	push   $0xf01080b9
f01046bc:	e8 a7 b9 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01046c1:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01046c6:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01046c9:	e8 b2 17 00 00       	call   f0105e80 <cpunum>
f01046ce:	6b d0 74             	imul   $0x74,%eax,%edx
f01046d1:	81 c2 20 60 2e f0    	add    $0xf02e6020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01046d7:	b8 02 00 00 00       	mov    $0x2,%eax
f01046dc:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01046e0:	83 ec 0c             	sub    $0xc,%esp
f01046e3:	68 40 84 12 f0       	push   $0xf0128440
f01046e8:	e8 05 1b 00 00       	call   f01061f2 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01046ed:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01046ef:	e8 8c 17 00 00       	call   f0105e80 <cpunum>
f01046f4:	6b c0 74             	imul   $0x74,%eax,%eax
	// Release the big kernel lock as if we were "leaving" the kernel
	
	unlock_kernel();
	
	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01046f7:	8b 80 30 60 2e f0    	mov    -0xfd19fd0(%eax),%eax
f01046fd:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104702:	89 c4                	mov    %eax,%esp
f0104704:	6a 00                	push   $0x0
f0104706:	6a 00                	push   $0x0
f0104708:	fb                   	sti    
f0104709:	f4                   	hlt    
f010470a:	83 c4 10             	add    $0x10,%esp
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010470d:	c9                   	leave  
f010470e:	c3                   	ret    

f010470f <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010470f:	55                   	push   %ebp
f0104710:	89 e5                	mov    %esp,%ebp
f0104712:	56                   	push   %esi
f0104713:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int now_env, i;
	if (curenv) {			// thiscpu->cpu_env
f0104714:	e8 67 17 00 00       	call   f0105e80 <cpunum>
f0104719:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104720:	29 c2                	sub    %eax,%edx
f0104722:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104725:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f010472c:	00 
f010472d:	74 2e                	je     f010475d <sched_yield+0x4e>
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
f010472f:	e8 4c 17 00 00       	call   f0105e80 <cpunum>
f0104734:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010473b:	29 c2                	sub    %eax,%edx
f010473d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104740:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0104747:	8b 40 48             	mov    0x48(%eax),%eax
f010474a:	8d 40 01             	lea    0x1(%eax),%eax
f010474d:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104752:	79 0e                	jns    f0104762 <sched_yield+0x53>
f0104754:	48                   	dec    %eax
f0104755:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f010475a:	40                   	inc    %eax
f010475b:	eb 05                	jmp    f0104762 <sched_yield+0x53>
	} else {
		now_env = 0;
f010475d:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
		if (envs[now_env].env_status == ENV_RUNNABLE) {
f0104762:	8b 1d 3c 52 2e f0    	mov    0xf02e523c,%ebx
f0104768:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010476f:	89 c1                	mov    %eax,%ecx
f0104771:	c1 e1 07             	shl    $0x7,%ecx
f0104774:	29 d1                	sub    %edx,%ecx
f0104776:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f0104779:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f010477d:	0f 85 8f 00 00 00    	jne    f0104812 <sched_yield+0x103>
f0104783:	eb 26                	jmp    f01047ab <sched_yield+0x9c>
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f0104785:	40                   	inc    %eax
f0104786:	25 ff 03 00 80       	and    $0x800003ff,%eax
f010478b:	79 07                	jns    f0104794 <sched_yield+0x85>
f010478d:	48                   	dec    %eax
f010478e:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0104793:	40                   	inc    %eax
		if (envs[now_env].env_status == ENV_RUNNABLE) {
f0104794:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
f010479b:	89 c1                	mov    %eax,%ecx
f010479d:	c1 e1 07             	shl    $0x7,%ecx
f01047a0:	29 f1                	sub    %esi,%ecx
f01047a2:	8d 0c 0b             	lea    (%ebx,%ecx,1),%ecx
f01047a5:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f01047a9:	75 09                	jne    f01047b4 <sched_yield+0xa5>
			//cprintf("I am CPU %d , I am in sched yield, I find ENV %d\n", thiscpu->cpu_id, now_env);
			env_run(&envs[now_env]);
f01047ab:	83 ec 0c             	sub    $0xc,%esp
f01047ae:	51                   	push   %ecx
f01047af:	e8 3d f3 ff ff       	call   f0103af1 <env_run>
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f01047b4:	4a                   	dec    %edx
f01047b5:	75 ce                	jne    f0104785 <sched_yield+0x76>
		if (envs[now_env].env_status == ENV_RUNNABLE) {
			//cprintf("I am CPU %d , I am in sched yield, I find ENV %d\n", thiscpu->cpu_id, now_env);
			env_run(&envs[now_env]);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING) {
f01047b7:	e8 c4 16 00 00       	call   f0105e80 <cpunum>
f01047bc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01047c3:	29 c2                	sub    %eax,%edx
f01047c5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01047c8:	83 3c 85 28 60 2e f0 	cmpl   $0x0,-0xfd19fd8(,%eax,4)
f01047cf:	00 
f01047d0:	74 34                	je     f0104806 <sched_yield+0xf7>
f01047d2:	e8 a9 16 00 00       	call   f0105e80 <cpunum>
f01047d7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01047de:	29 c2                	sub    %eax,%edx
f01047e0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01047e3:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f01047ea:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01047ee:	75 16                	jne    f0104806 <sched_yield+0xf7>
		env_run(curenv);
f01047f0:	e8 8b 16 00 00       	call   f0105e80 <cpunum>
f01047f5:	83 ec 0c             	sub    $0xc,%esp
f01047f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01047fb:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f0104801:	e8 eb f2 ff ff       	call   f0103af1 <env_run>
	}

	// sched_halt never returns
	sched_halt();
f0104806:	e8 29 fe ff ff       	call   f0104634 <sched_halt>
}
f010480b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010480e:	5b                   	pop    %ebx
f010480f:	5e                   	pop    %esi
f0104810:	c9                   	leave  
f0104811:	c3                   	ret    
	if (curenv) {			// thiscpu->cpu_env
		now_env = (ENVX(curenv->env_id) + 1) % NENV;
	} else {
		now_env = 0;
	}
	for (i = 0; i < NENV; i++, now_env = (now_env + 1) % NENV) {
f0104812:	40                   	inc    %eax
f0104813:	25 ff 03 00 80       	and    $0x800003ff,%eax
f0104818:	79 07                	jns    f0104821 <sched_yield+0x112>
f010481a:	48                   	dec    %eax
f010481b:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0104820:	40                   	inc    %eax
f0104821:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0104826:	e9 69 ff ff ff       	jmp    f0104794 <sched_yield+0x85>
	...

f010482c <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010482c:	55                   	push   %ebp
f010482d:	89 e5                	mov    %esp,%ebp
f010482f:	57                   	push   %edi
f0104830:	56                   	push   %esi
f0104831:	53                   	push   %ebx
f0104832:	83 ec 1c             	sub    $0x1c,%esp
f0104835:	8b 45 08             	mov    0x8(%ebp),%eax
f0104838:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010483b:	8b 75 10             	mov    0x10(%ebp),%esi
f010483e:	8b 7d 14             	mov    0x14(%ebp),%edi
    // sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// sys_exofork(void)
	// sys_env_set_status(envid_t envid, int status)
	// cprintf("syscallno : %d\n", syscallno);
	int r = 0;
    switch (syscallno) {
f0104841:	83 f8 0a             	cmp    $0xa,%eax
f0104844:	0f 87 11 04 00 00    	ja     f0104c5b <syscall+0x42f>
f010484a:	ff 24 85 1c 81 10 f0 	jmp    *-0xfef7ee4(,%eax,4)
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env * new_env;
	int r = env_alloc(&new_env, curenv->env_id);
f0104851:	e8 2a 16 00 00       	call   f0105e80 <cpunum>
f0104856:	83 ec 08             	sub    $0x8,%esp
f0104859:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104860:	29 c2                	sub    %eax,%edx
f0104862:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104865:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f010486c:	ff 70 48             	pushl  0x48(%eax)
f010486f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104872:	50                   	push   %eax
f0104873:	e8 e1 ec ff ff       	call   f0103559 <env_alloc>
	if (r < 0) return r;
f0104878:	83 c4 10             	add    $0x10,%esp
f010487b:	85 c0                	test   %eax,%eax
f010487d:	0f 88 dd 03 00 00    	js     f0104c60 <syscall+0x434>
	
	new_env->env_status = ENV_NOT_RUNNABLE;
f0104883:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104886:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memcpy((void *)(&new_env->env_tf), (void*)(&curenv->env_tf), sizeof(struct Trapframe));
f010488d:	e8 ee 15 00 00       	call   f0105e80 <cpunum>
f0104892:	83 ec 04             	sub    $0x4,%esp
f0104895:	6a 44                	push   $0x44
f0104897:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010489e:	29 c2                	sub    %eax,%edx
f01048a0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01048a3:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f01048aa:	ff 75 e4             	pushl  -0x1c(%ebp)
f01048ad:	e8 53 10 00 00       	call   f0105905 <memcpy>
	
	// for children environment, return 0
	new_env->env_tf.tf_regs.reg_eax = 0;
f01048b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048b5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return new_env->env_id;
f01048bc:	8b 40 48             	mov    0x48(%eax),%eax
f01048bf:	83 c4 10             	add    $0x10,%esp
	// cprintf("syscallno : %d\n", syscallno);
	int r = 0;
    switch (syscallno) {
    	case SYS_exofork:
    		r = sys_exofork();
    		break;
f01048c2:	e9 99 03 00 00       	jmp    f0104c60 <syscall+0x434>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	// LAB 4: Your code here.

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
f01048c7:	83 fe 02             	cmp    $0x2,%esi
f01048ca:	74 05                	je     f01048d1 <syscall+0xa5>
f01048cc:	83 fe 04             	cmp    $0x4,%esi
f01048cf:	75 2a                	jne    f01048fb <syscall+0xcf>
		return -E_INVAL;

	struct Env * env;
	int r = envid2env(envid, &env, 1);
f01048d1:	83 ec 04             	sub    $0x4,%esp
f01048d4:	6a 01                	push   $0x1
f01048d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048d9:	50                   	push   %eax
f01048da:	53                   	push   %ebx
f01048db:	e8 2e eb ff ff       	call   f010340e <envid2env>
	if (r < 0) return r;
f01048e0:	83 c4 10             	add    $0x10,%esp
f01048e3:	85 c0                	test   %eax,%eax
f01048e5:	0f 88 75 03 00 00    	js     f0104c60 <syscall+0x434>
	env->env_status = status;
f01048eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048ee:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f01048f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01048f6:	e9 65 03 00 00       	jmp    f0104c60 <syscall+0x434>
	// check whether the current environment has permission to set
	// envid's status.
	// LAB 4: Your code here.

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
		return -E_INVAL;
f01048fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
    	case SYS_exofork:
    		r = sys_exofork();
    		break;
    	case SYS_env_set_status:
    		r = sys_env_set_status((envid_t)a1, (int)a2);
    		break;
f0104900:	e9 5b 03 00 00       	jmp    f0104c60 <syscall+0x434>
	//   allocated!
	// LAB 4: Your code here.
	// cprintf("In kernel sys_page_alloc function\n");

	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104905:	83 ec 04             	sub    $0x4,%esp
f0104908:	6a 01                	push   $0x1
f010490a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010490d:	50                   	push   %eax
f010490e:	53                   	push   %ebx
f010490f:	e8 fa ea ff ff       	call   f010340e <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104914:	83 c4 10             	add    $0x10,%esp
f0104917:	85 c0                	test   %eax,%eax
f0104919:	0f 88 88 00 00 00    	js     f01049a7 <syscall+0x17b>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f010491f:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104925:	0f 87 86 00 00 00    	ja     f01049b1 <syscall+0x185>
f010492b:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0104931:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104937:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010493c:	39 d6                	cmp    %edx,%esi
f010493e:	0f 85 1c 03 00 00    	jne    f0104c60 <syscall+0x434>
	
	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;
f0104944:	89 fa                	mov    %edi,%edx
f0104946:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f010494c:	83 fa 05             	cmp    $0x5,%edx
f010494f:	0f 85 0b 03 00 00    	jne    f0104c60 <syscall+0x434>

	struct PageInfo * pg = page_alloc(ALLOC_ZERO);
f0104955:	83 ec 0c             	sub    $0xc,%esp
f0104958:	6a 01                	push   $0x1
f010495a:	e8 6e cc ff ff       	call   f01015cd <page_alloc>
f010495f:	89 c3                	mov    %eax,%ebx
	if (pg == NULL) return -E_NO_MEM;
f0104961:	83 c4 10             	add    $0x10,%esp
f0104964:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104969:	85 db                	test   %ebx,%ebx
f010496b:	0f 84 ef 02 00 00    	je     f0104c60 <syscall+0x434>
	if (page_insert(env->env_pgdir, pg, va, perm) < 0) {
f0104971:	57                   	push   %edi
f0104972:	56                   	push   %esi
f0104973:	53                   	push   %ebx
f0104974:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104977:	ff 70 60             	pushl  0x60(%eax)
f010497a:	e8 fa ce ff ff       	call   f0101879 <page_insert>
f010497f:	89 c2                	mov    %eax,%edx
f0104981:	83 c4 10             	add    $0x10,%esp
		// page_insert fails, should free the page you allocated!  
		page_free(pg);
		return -E_NO_MEM;
	}
	return 0;
f0104984:	b8 00 00 00 00       	mov    $0x0,%eax
	
	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;

	struct PageInfo * pg = page_alloc(ALLOC_ZERO);
	if (pg == NULL) return -E_NO_MEM;
	if (page_insert(env->env_pgdir, pg, va, perm) < 0) {
f0104989:	85 d2                	test   %edx,%edx
f010498b:	0f 89 cf 02 00 00    	jns    f0104c60 <syscall+0x434>
		// page_insert fails, should free the page you allocated!  
		page_free(pg);
f0104991:	83 ec 0c             	sub    $0xc,%esp
f0104994:	53                   	push   %ebx
f0104995:	e8 bd cc ff ff       	call   f0101657 <page_free>
f010499a:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f010499d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01049a2:	e9 b9 02 00 00       	jmp    f0104c60 <syscall+0x434>
	// LAB 4: Your code here.
	// cprintf("In kernel sys_page_alloc function\n");

	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;
f01049a7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01049ac:	e9 af 02 00 00       	jmp    f0104c60 <syscall+0x434>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f01049b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01049b6:	e9 a5 02 00 00       	jmp    f0104c60 <syscall+0x434>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	// LAB 4: Your code here.

	struct Env * dstenv, * srcenv;
	int r = envid2env(dstenvid, &dstenv, 1);
f01049bb:	83 ec 04             	sub    $0x4,%esp
f01049be:	6a 01                	push   $0x1
f01049c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049c3:	50                   	push   %eax
f01049c4:	57                   	push   %edi
f01049c5:	e8 44 ea ff ff       	call   f010340e <envid2env>
	if (r < 0) return -E_BAD_ENV;
f01049ca:	83 c4 10             	add    $0x10,%esp
f01049cd:	85 c0                	test   %eax,%eax
f01049cf:	0f 88 cd 00 00 00    	js     f0104aa2 <syscall+0x276>
	r = envid2env(srcenvid, &srcenv, 1);
f01049d5:	83 ec 04             	sub    $0x4,%esp
f01049d8:	6a 01                	push   $0x1
f01049da:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01049dd:	50                   	push   %eax
f01049de:	53                   	push   %ebx
f01049df:	e8 2a ea ff ff       	call   f010340e <envid2env>
	if (r < 0) return -E_BAD_ENV;
f01049e4:	83 c4 10             	add    $0x10,%esp
f01049e7:	85 c0                	test   %eax,%eax
f01049e9:	0f 88 bd 00 00 00    	js     f0104aac <syscall+0x280>

	if ((uint32_t)srcva >= UTOP || ROUNDUP(srcva, PGSIZE) != srcva) return -E_INVAL;
f01049ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01049f4:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01049fa:	0f 87 60 02 00 00    	ja     f0104c60 <syscall+0x434>
f0104a00:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0104a06:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104a0c:	39 d6                	cmp    %edx,%esi
f0104a0e:	0f 85 4c 02 00 00    	jne    f0104c60 <syscall+0x434>
	if ((uint32_t)dstva >= UTOP || ROUNDUP(dstva, PGSIZE) != dstva) return -E_INVAL;
f0104a14:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104a1b:	0f 87 3f 02 00 00    	ja     f0104c60 <syscall+0x434>
f0104a21:	8b 55 18             	mov    0x18(%ebp),%edx
f0104a24:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0104a2a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104a30:	39 55 18             	cmp    %edx,0x18(%ebp)
f0104a33:	0f 85 27 02 00 00    	jne    f0104c60 <syscall+0x434>


	// struct PageInfo * page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
	struct PageInfo * pg;
	pte_t * pte;
	pg = page_lookup(srcenv->env_pgdir, srcva, &pte);
f0104a39:	83 ec 04             	sub    $0x4,%esp
f0104a3c:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104a3f:	50                   	push   %eax
f0104a40:	56                   	push   %esi
f0104a41:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a44:	ff 70 60             	pushl  0x60(%eax)
f0104a47:	e8 31 cd ff ff       	call   f010177d <page_lookup>
f0104a4c:	89 c2                	mov    %eax,%edx
	if (pg == NULL) return -E_INVAL;		
f0104a4e:	83 c4 10             	add    $0x10,%esp
f0104a51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a56:	85 d2                	test   %edx,%edx
f0104a58:	0f 84 02 02 00 00    	je     f0104c60 <syscall+0x434>

	if (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)) return -E_INVAL;
f0104a5e:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104a61:	81 e1 fd f1 ff ff    	and    $0xfffff1fd,%ecx
f0104a67:	83 f9 05             	cmp    $0x5,%ecx
f0104a6a:	0f 85 f0 01 00 00    	jne    f0104c60 <syscall+0x434>
	
	if ((perm & PTE_W) && ((*pte) & PTE_W) == 0) return -E_INVAL;
f0104a70:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104a74:	74 0c                	je     f0104a82 <syscall+0x256>
f0104a76:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104a79:	f6 01 02             	testb  $0x2,(%ecx)
f0104a7c:	0f 84 de 01 00 00    	je     f0104c60 <syscall+0x434>

	// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	if (page_insert(dstenv->env_pgdir, pg, dstva, perm) < 0) return -E_NO_MEM;
f0104a82:	ff 75 1c             	pushl  0x1c(%ebp)
f0104a85:	ff 75 18             	pushl  0x18(%ebp)
f0104a88:	52                   	push   %edx
f0104a89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a8c:	ff 70 60             	pushl  0x60(%eax)
f0104a8f:	e8 e5 cd ff ff       	call   f0101879 <page_insert>
f0104a94:	83 c4 10             	add    $0x10,%esp
f0104a97:	c1 f8 1f             	sar    $0x1f,%eax
f0104a9a:	83 e0 fc             	and    $0xfffffffc,%eax
f0104a9d:	e9 be 01 00 00       	jmp    f0104c60 <syscall+0x434>
	//   check the current permissions on the page.
	// LAB 4: Your code here.

	struct Env * dstenv, * srcenv;
	int r = envid2env(dstenvid, &dstenv, 1);
	if (r < 0) return -E_BAD_ENV;
f0104aa2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104aa7:	e9 b4 01 00 00       	jmp    f0104c60 <syscall+0x434>
	r = envid2env(srcenvid, &srcenv, 1);
	if (r < 0) return -E_BAD_ENV;
f0104aac:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104ab1:	e9 aa 01 00 00       	jmp    f0104c60 <syscall+0x434>
{
	// Hint: This function is a wrapper around page_remove().
	// LAB 4: Your code here.

	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104ab6:	83 ec 04             	sub    $0x4,%esp
f0104ab9:	6a 01                	push   $0x1
f0104abb:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104abe:	50                   	push   %eax
f0104abf:	53                   	push   %ebx
f0104ac0:	e8 49 e9 ff ff       	call   f010340e <envid2env>
	if (r < 0) return -E_BAD_ENV;
f0104ac5:	83 c4 10             	add    $0x10,%esp
f0104ac8:	85 c0                	test   %eax,%eax
f0104aca:	78 3d                	js     f0104b09 <syscall+0x2dd>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104acc:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104ad2:	77 3f                	ja     f0104b13 <syscall+0x2e7>
f0104ad4:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0104ada:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0104ae0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ae5:	39 d6                	cmp    %edx,%esi
f0104ae7:	0f 85 73 01 00 00    	jne    f0104c60 <syscall+0x434>
	
	// void page_remove(pde_t *pgdir, void *va)
	page_remove(env->env_pgdir, va);
f0104aed:	83 ec 08             	sub    $0x8,%esp
f0104af0:	56                   	push   %esi
f0104af1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104af4:	ff 70 60             	pushl  0x60(%eax)
f0104af7:	e8 30 cd ff ff       	call   f010182c <page_remove>
f0104afc:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104aff:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b04:	e9 57 01 00 00       	jmp    f0104c60 <syscall+0x434>
	// Hint: This function is a wrapper around page_remove().
	// LAB 4: Your code here.

	struct Env * env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) return -E_BAD_ENV;
f0104b09:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104b0e:	e9 4d 01 00 00       	jmp    f0104c60 <syscall+0x434>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104b13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b18:	e9 43 01 00 00       	jmp    f0104c60 <syscall+0x434>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// cprintf("In kernel sys_env_set_pgfault_upcall function\n");
	struct Env * env;
	int r = envid2env(envid, &env, 1);
f0104b1d:	83 ec 04             	sub    $0x4,%esp
f0104b20:	6a 01                	push   $0x1
f0104b22:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104b25:	50                   	push   %eax
f0104b26:	53                   	push   %ebx
f0104b27:	e8 e2 e8 ff ff       	call   f010340e <envid2env>
	if (r < 0) return r;
f0104b2c:	83 c4 10             	add    $0x10,%esp
f0104b2f:	85 c0                	test   %eax,%eax
f0104b31:	0f 88 29 01 00 00    	js     f0104c60 <syscall+0x434>

	env->env_pgfault_upcall = func;
f0104b37:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104b3a:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f0104b3d:	b8 00 00 00 00       	mov    $0x0,%eax
    	case SYS_page_unmap:
    		r = sys_page_unmap((envid_t)a1, (void *)a2);
    		break;
    	case SYS_env_set_pgfault_upcall:
    		r = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
    		break;
f0104b42:	e9 19 01 00 00       	jmp    f0104c60 <syscall+0x434>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104b47:	e8 c3 fb ff ff       	call   f010470f <sched_yield>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, (void *)s, len, PTE_U);
f0104b4c:	e8 2f 13 00 00       	call   f0105e80 <cpunum>
f0104b51:	6a 04                	push   $0x4
f0104b53:	56                   	push   %esi
f0104b54:	53                   	push   %ebx
f0104b55:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b5c:	29 c2                	sub    %eax,%edx
f0104b5e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b61:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f0104b68:	e8 d1 e7 ff ff       	call   f010333e <user_mem_assert>
    
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104b6d:	83 c4 0c             	add    $0xc,%esp
f0104b70:	53                   	push   %ebx
f0104b71:	56                   	push   %esi
f0104b72:	68 1f 69 10 f0       	push   $0xf010691f
f0104b77:	e8 d9 f1 ff ff       	call   f0103d55 <cprintf>
f0104b7c:	83 c4 10             	add    $0x10,%esp
    		sys_yield();
    		return 0;
    		break;
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
f0104b7f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b84:	e9 f0 00 00 00       	jmp    f0104c79 <syscall+0x44d>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104b89:	e8 ce ba ff ff       	call   f010065c <cons_getc>
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
            break;
        case SYS_cgetc:
            r = sys_cgetc();
            break;
f0104b8e:	e9 cd 00 00 00       	jmp    f0104c60 <syscall+0x434>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104b93:	e8 e8 12 00 00       	call   f0105e80 <cpunum>
f0104b98:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b9f:	29 c2                	sub    %eax,%edx
f0104ba1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ba4:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0104bab:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_cgetc:
            r = sys_cgetc();
            break;
        case SYS_getenvid:
            r = sys_getenvid();
            break;
f0104bae:	e9 ad 00 00 00       	jmp    f0104c60 <syscall+0x434>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104bb3:	83 ec 04             	sub    $0x4,%esp
f0104bb6:	6a 01                	push   $0x1
f0104bb8:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104bbb:	50                   	push   %eax
f0104bbc:	53                   	push   %ebx
f0104bbd:	e8 4c e8 ff ff       	call   f010340e <envid2env>
f0104bc2:	83 c4 10             	add    $0x10,%esp
f0104bc5:	85 c0                	test   %eax,%eax
f0104bc7:	0f 88 93 00 00 00    	js     f0104c60 <syscall+0x434>
		return r;
	if (e == curenv)
f0104bcd:	e8 ae 12 00 00       	call   f0105e80 <cpunum>
f0104bd2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104bd5:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0104bdc:	29 c1                	sub    %eax,%ecx
f0104bde:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0104be1:	39 14 85 28 60 2e f0 	cmp    %edx,-0xfd19fd8(,%eax,4)
f0104be8:	75 2d                	jne    f0104c17 <syscall+0x3eb>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104bea:	e8 91 12 00 00       	call   f0105e80 <cpunum>
f0104bef:	83 ec 08             	sub    $0x8,%esp
f0104bf2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104bf9:	29 c2                	sub    %eax,%edx
f0104bfb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104bfe:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0104c05:	ff 70 48             	pushl  0x48(%eax)
f0104c08:	68 c6 80 10 f0       	push   $0xf01080c6
f0104c0d:	e8 43 f1 ff ff       	call   f0103d55 <cprintf>
f0104c12:	83 c4 10             	add    $0x10,%esp
f0104c15:	eb 2f                	jmp    f0104c46 <syscall+0x41a>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104c17:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104c1a:	e8 61 12 00 00       	call   f0105e80 <cpunum>
f0104c1f:	83 ec 04             	sub    $0x4,%esp
f0104c22:	53                   	push   %ebx
f0104c23:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c2a:	29 c2                	sub    %eax,%edx
f0104c2c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c2f:	8b 04 85 28 60 2e f0 	mov    -0xfd19fd8(,%eax,4),%eax
f0104c36:	ff 70 48             	pushl  0x48(%eax)
f0104c39:	68 e1 80 10 f0       	push   $0xf01080e1
f0104c3e:	e8 12 f1 ff ff       	call   f0103d55 <cprintf>
f0104c43:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104c46:	83 ec 0c             	sub    $0xc,%esp
f0104c49:	ff 75 dc             	pushl  -0x24(%ebp)
f0104c4c:	e8 e3 ed ff ff       	call   f0103a34 <env_destroy>
f0104c51:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104c54:	b8 00 00 00 00       	mov    $0x0,%eax
        case SYS_getenvid:
            r = sys_getenvid();
            break;
        case SYS_env_destroy:
            r = sys_env_destroy(a1);
            break;
f0104c59:	eb 05                	jmp    f0104c60 <syscall+0x434>
    // sys_page_unmap(envid_t envid, void *va)
    // sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// sys_exofork(void)
	// sys_env_set_status(envid_t envid, int status)
	// cprintf("syscallno : %d\n", syscallno);
	int r = 0;
f0104c5b:	b8 00 00 00 00       	mov    $0x0,%eax
            r = sys_env_destroy(a1);
            break;
        dafult:
            return -E_INVAL;
	}
	if (r < 0) panic("syscall error %e\n", r);
f0104c60:	85 c0                	test   %eax,%eax
f0104c62:	79 15                	jns    f0104c79 <syscall+0x44d>
f0104c64:	50                   	push   %eax
f0104c65:	68 f9 80 10 f0       	push   $0xf01080f9
f0104c6a:	68 8a 01 00 00       	push   $0x18a
f0104c6f:	68 0b 81 10 f0       	push   $0xf010810b
f0104c74:	e8 ef b3 ff ff       	call   f0100068 <_panic>
	return r;
    panic("syscall not implemented");
}
f0104c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c7c:	5b                   	pop    %ebx
f0104c7d:	5e                   	pop    %esi
f0104c7e:	5f                   	pop    %edi
f0104c7f:	c9                   	leave  
f0104c80:	c3                   	ret    
f0104c81:	00 00                	add    %al,(%eax)
	...

f0104c84 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c84:	55                   	push   %ebp
f0104c85:	89 e5                	mov    %esp,%ebp
f0104c87:	57                   	push   %edi
f0104c88:	56                   	push   %esi
f0104c89:	53                   	push   %ebx
f0104c8a:	83 ec 14             	sub    $0x14,%esp
f0104c8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c90:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0104c93:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c96:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c99:	8b 1a                	mov    (%edx),%ebx
f0104c9b:	8b 01                	mov    (%ecx),%eax
f0104c9d:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0104ca0:	39 c3                	cmp    %eax,%ebx
f0104ca2:	0f 8f 97 00 00 00    	jg     f0104d3f <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0104ca8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104caf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104cb2:	01 d8                	add    %ebx,%eax
f0104cb4:	89 c7                	mov    %eax,%edi
f0104cb6:	c1 ef 1f             	shr    $0x1f,%edi
f0104cb9:	01 c7                	add    %eax,%edi
f0104cbb:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104cbd:	39 df                	cmp    %ebx,%edi
f0104cbf:	7c 31                	jl     f0104cf2 <stab_binsearch+0x6e>
f0104cc1:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104cc4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104cc7:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0104ccc:	39 f0                	cmp    %esi,%eax
f0104cce:	0f 84 b3 00 00 00    	je     f0104d87 <stab_binsearch+0x103>
f0104cd4:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0104cd8:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104cdc:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104cde:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104cdf:	39 d8                	cmp    %ebx,%eax
f0104ce1:	7c 0f                	jl     f0104cf2 <stab_binsearch+0x6e>
f0104ce3:	0f b6 0a             	movzbl (%edx),%ecx
f0104ce6:	83 ea 0c             	sub    $0xc,%edx
f0104ce9:	39 f1                	cmp    %esi,%ecx
f0104ceb:	75 f1                	jne    f0104cde <stab_binsearch+0x5a>
f0104ced:	e9 97 00 00 00       	jmp    f0104d89 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104cf2:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104cf5:	eb 39                	jmp    f0104d30 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104cf7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104cfa:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0104cfc:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104cff:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104d06:	eb 28                	jmp    f0104d30 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104d08:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104d0b:	76 12                	jbe    f0104d1f <stab_binsearch+0x9b>
			*region_right = m - 1;
f0104d0d:	48                   	dec    %eax
f0104d0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104d11:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104d14:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104d16:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104d1d:	eb 11                	jmp    f0104d30 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104d1f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104d22:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0104d24:	ff 45 0c             	incl   0xc(%ebp)
f0104d27:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104d29:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104d30:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0104d33:	0f 8d 76 ff ff ff    	jge    f0104caf <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104d39:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104d3d:	75 0d                	jne    f0104d4c <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0104d3f:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104d42:	8b 03                	mov    (%ebx),%eax
f0104d44:	48                   	dec    %eax
f0104d45:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104d48:	89 02                	mov    %eax,(%edx)
f0104d4a:	eb 55                	jmp    f0104da1 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d4c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104d4f:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d51:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104d54:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d56:	39 c1                	cmp    %eax,%ecx
f0104d58:	7d 26                	jge    f0104d80 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0104d5a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d5d:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0104d60:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0104d65:	39 f2                	cmp    %esi,%edx
f0104d67:	74 17                	je     f0104d80 <stab_binsearch+0xfc>
f0104d69:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0104d6d:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104d71:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d72:	39 c1                	cmp    %eax,%ecx
f0104d74:	7d 0a                	jge    f0104d80 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0104d76:	0f b6 1a             	movzbl (%edx),%ebx
f0104d79:	83 ea 0c             	sub    $0xc,%edx
f0104d7c:	39 f3                	cmp    %esi,%ebx
f0104d7e:	75 f1                	jne    f0104d71 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104d80:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104d83:	89 02                	mov    %eax,(%edx)
f0104d85:	eb 1a                	jmp    f0104da1 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104d87:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104d89:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d8c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0104d8f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104d93:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104d96:	0f 82 5b ff ff ff    	jb     f0104cf7 <stab_binsearch+0x73>
f0104d9c:	e9 67 ff ff ff       	jmp    f0104d08 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104da1:	83 c4 14             	add    $0x14,%esp
f0104da4:	5b                   	pop    %ebx
f0104da5:	5e                   	pop    %esi
f0104da6:	5f                   	pop    %edi
f0104da7:	c9                   	leave  
f0104da8:	c3                   	ret    

f0104da9 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104da9:	55                   	push   %ebp
f0104daa:	89 e5                	mov    %esp,%ebp
f0104dac:	57                   	push   %edi
f0104dad:	56                   	push   %esi
f0104dae:	53                   	push   %ebx
f0104daf:	83 ec 2c             	sub    $0x2c,%esp
f0104db2:	8b 75 08             	mov    0x8(%ebp),%esi
f0104db5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104db8:	c7 03 48 81 10 f0    	movl   $0xf0108148,(%ebx)
	info->eip_line = 0;
f0104dbe:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104dc5:	c7 43 08 48 81 10 f0 	movl   $0xf0108148,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104dcc:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104dd3:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104dd6:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104ddd:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104de3:	0f 87 ba 00 00 00    	ja     f0104ea3 <debuginfo_eip+0xfa>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
f0104de9:	e8 92 10 00 00       	call   f0105e80 <cpunum>
f0104dee:	6a 04                	push   $0x4
f0104df0:	6a 10                	push   $0x10
f0104df2:	68 00 00 20 00       	push   $0x200000
f0104df7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104dfe:	29 c2                	sub    %eax,%edx
f0104e00:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e03:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f0104e0a:	e8 7c e4 ff ff       	call   f010328b <user_mem_check>
f0104e0f:	83 c4 10             	add    $0x10,%esp
f0104e12:	85 c0                	test   %eax,%eax
f0104e14:	0f 88 11 02 00 00    	js     f010502b <debuginfo_eip+0x282>
			return -1;
		}

		stabs = usd->stabs;
f0104e1a:	a1 00 00 20 00       	mov    0x200000,%eax
f0104e1f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f0104e22:	8b 0d 04 00 20 00    	mov    0x200004,%ecx
f0104e28:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr = usd->stabstr;
f0104e2b:	a1 08 00 20 00       	mov    0x200008,%eax
f0104e30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104e33:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
f0104e39:	e8 42 10 00 00       	call   f0105e80 <cpunum>
f0104e3e:	89 c2                	mov    %eax,%edx
f0104e40:	6a 04                	push   $0x4
f0104e42:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104e45:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0104e48:	50                   	push   %eax
f0104e49:	ff 75 d0             	pushl  -0x30(%ebp)
f0104e4c:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0104e53:	29 d0                	sub    %edx,%eax
f0104e55:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0104e58:	ff 34 85 28 60 2e f0 	pushl  -0xfd19fd8(,%eax,4)
f0104e5f:	e8 27 e4 ff ff       	call   f010328b <user_mem_check>
f0104e64:	83 c4 10             	add    $0x10,%esp
f0104e67:	85 c0                	test   %eax,%eax
f0104e69:	0f 88 c3 01 00 00    	js     f0105032 <debuginfo_eip+0x289>
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0104e6f:	e8 0c 10 00 00       	call   f0105e80 <cpunum>
f0104e74:	89 c2                	mov    %eax,%edx
f0104e76:	6a 04                	push   $0x4
f0104e78:	89 f8                	mov    %edi,%eax
f0104e7a:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0104e7d:	50                   	push   %eax
f0104e7e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104e81:	6b c2 74             	imul   $0x74,%edx,%eax
f0104e84:	ff b0 28 60 2e f0    	pushl  -0xfd19fd8(%eax)
f0104e8a:	e8 fc e3 ff ff       	call   f010328b <user_mem_check>
f0104e8f:	89 c2                	mov    %eax,%edx
f0104e91:	83 c4 10             	add    $0x10,%esp
			return -1;
f0104e94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0104e99:	85 d2                	test   %edx,%edx
f0104e9b:	0f 88 ab 01 00 00    	js     f010504c <debuginfo_eip+0x2a3>
f0104ea1:	eb 1a                	jmp    f0104ebd <debuginfo_eip+0x114>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104ea3:	bf c0 d5 11 f0       	mov    $0xf011d5c0,%edi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104ea8:	c7 45 d4 d5 42 11 f0 	movl   $0xf01142d5,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104eaf:	c7 45 cc d4 42 11 f0 	movl   $0xf01142d4,-0x34(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104eb6:	c7 45 d0 34 86 10 f0 	movl   $0xf0108634,-0x30(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104ebd:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0104ec0:	0f 83 73 01 00 00    	jae    f0105039 <debuginfo_eip+0x290>
f0104ec6:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0104eca:	0f 85 70 01 00 00    	jne    f0105040 <debuginfo_eip+0x297>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104ed0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104ed7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104eda:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0104edd:	c1 f8 02             	sar    $0x2,%eax
f0104ee0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104ee6:	48                   	dec    %eax
f0104ee7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104eea:	83 ec 08             	sub    $0x8,%esp
f0104eed:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104ef0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104ef3:	56                   	push   %esi
f0104ef4:	6a 64                	push   $0x64
f0104ef6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104ef9:	e8 86 fd ff ff       	call   f0104c84 <stab_binsearch>
	if (lfile == 0)
f0104efe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104f01:	83 c4 10             	add    $0x10,%esp
		return -1;
f0104f04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0104f09:	85 d2                	test   %edx,%edx
f0104f0b:	0f 84 3b 01 00 00    	je     f010504c <debuginfo_eip+0x2a3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104f11:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0104f14:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f17:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104f1a:	83 ec 08             	sub    $0x8,%esp
f0104f1d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104f20:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104f23:	56                   	push   %esi
f0104f24:	6a 24                	push   $0x24
f0104f26:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104f29:	e8 56 fd ff ff       	call   f0104c84 <stab_binsearch>

	if (lfun <= rfun) {
f0104f2e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104f31:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104f34:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104f37:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104f3a:	83 c4 10             	add    $0x10,%esp
f0104f3d:	39 c1                	cmp    %eax,%ecx
f0104f3f:	7f 21                	jg     f0104f62 <debuginfo_eip+0x1b9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104f41:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0104f44:	03 45 d0             	add    -0x30(%ebp),%eax
f0104f47:	8b 10                	mov    (%eax),%edx
f0104f49:	89 f9                	mov    %edi,%ecx
f0104f4b:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f0104f4e:	39 ca                	cmp    %ecx,%edx
f0104f50:	73 06                	jae    f0104f58 <debuginfo_eip+0x1af>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104f52:	03 55 d4             	add    -0x2c(%ebp),%edx
f0104f55:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104f58:	8b 40 08             	mov    0x8(%eax),%eax
f0104f5b:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104f5e:	29 c6                	sub    %eax,%esi
f0104f60:	eb 0f                	jmp    f0104f71 <debuginfo_eip+0x1c8>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104f62:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104f65:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104f68:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		rline = rfile;
f0104f6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f6e:	89 45 c8             	mov    %eax,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104f71:	83 ec 08             	sub    $0x8,%esp
f0104f74:	6a 3a                	push   $0x3a
f0104f76:	ff 73 08             	pushl  0x8(%ebx)
f0104f79:	e8 b1 08 00 00       	call   f010582f <strfind>
f0104f7e:	2b 43 08             	sub    0x8(%ebx),%eax
f0104f81:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0104f84:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104f87:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    rfun = rline;
f0104f8a:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104f8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0104f90:	83 c4 08             	add    $0x8,%esp
f0104f93:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104f96:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104f99:	56                   	push   %esi
f0104f9a:	6a 44                	push   $0x44
f0104f9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104f9f:	e8 e0 fc ff ff       	call   f0104c84 <stab_binsearch>
    if (lfun <= rfun) {
f0104fa4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104fa7:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0104faa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0104faf:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0104fb2:	0f 8f 94 00 00 00    	jg     f010504c <debuginfo_eip+0x2a3>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0104fb8:	6b ca 0c             	imul   $0xc,%edx,%ecx
f0104fbb:	03 4d d0             	add    -0x30(%ebp),%ecx
f0104fbe:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f0104fc2:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104fc5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104fc8:	89 75 cc             	mov    %esi,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0104fcb:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104fce:	eb 04                	jmp    f0104fd4 <debuginfo_eip+0x22b>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104fd0:	4a                   	dec    %edx
f0104fd1:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104fd4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f0104fd7:	7c 19                	jl     f0104ff2 <debuginfo_eip+0x249>
	       && stabs[lline].n_type != N_SOL
f0104fd9:	8a 48 fc             	mov    -0x4(%eax),%cl
f0104fdc:	80 f9 84             	cmp    $0x84,%cl
f0104fdf:	74 73                	je     f0105054 <debuginfo_eip+0x2ab>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104fe1:	80 f9 64             	cmp    $0x64,%cl
f0104fe4:	75 ea                	jne    f0104fd0 <debuginfo_eip+0x227>
f0104fe6:	83 38 00             	cmpl   $0x0,(%eax)
f0104fe9:	74 e5                	je     f0104fd0 <debuginfo_eip+0x227>
f0104feb:	eb 67                	jmp    f0105054 <debuginfo_eip+0x2ab>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104fed:	03 45 d4             	add    -0x2c(%ebp),%eax
f0104ff0:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104ff2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104ff5:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ff8:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104ffd:	39 ca                	cmp    %ecx,%edx
f0104fff:	7d 4b                	jge    f010504c <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
f0105001:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105004:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105007:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010500a:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f010500e:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105010:	eb 04                	jmp    f0105016 <debuginfo_eip+0x26d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105012:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0105015:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105016:	39 f0                	cmp    %esi,%eax
f0105018:	7d 2d                	jge    f0105047 <debuginfo_eip+0x29e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010501a:	8a 0a                	mov    (%edx),%cl
f010501c:	83 c2 0c             	add    $0xc,%edx
f010501f:	80 f9 a0             	cmp    $0xa0,%cl
f0105022:	74 ee                	je     f0105012 <debuginfo_eip+0x269>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105024:	b8 00 00 00 00       	mov    $0x0,%eax
f0105029:	eb 21                	jmp    f010504c <debuginfo_eip+0x2a3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
f010502b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105030:	eb 1a                	jmp    f010504c <debuginfo_eip+0x2a3>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
f0105032:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105037:	eb 13                	jmp    f010504c <debuginfo_eip+0x2a3>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105039:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010503e:	eb 0c                	jmp    f010504c <debuginfo_eip+0x2a3>
f0105040:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105045:	eb 05                	jmp    f010504c <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105047:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010504c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010504f:	5b                   	pop    %ebx
f0105050:	5e                   	pop    %esi
f0105051:	5f                   	pop    %edi
f0105052:	c9                   	leave  
f0105053:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105054:	6b d2 0c             	imul   $0xc,%edx,%edx
f0105057:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010505a:	8b 04 16             	mov    (%esi,%edx,1),%eax
f010505d:	2b 7d d4             	sub    -0x2c(%ebp),%edi
f0105060:	39 f8                	cmp    %edi,%eax
f0105062:	72 89                	jb     f0104fed <debuginfo_eip+0x244>
f0105064:	eb 8c                	jmp    f0104ff2 <debuginfo_eip+0x249>
	...

f0105068 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105068:	55                   	push   %ebp
f0105069:	89 e5                	mov    %esp,%ebp
f010506b:	57                   	push   %edi
f010506c:	56                   	push   %esi
f010506d:	53                   	push   %ebx
f010506e:	83 ec 2c             	sub    $0x2c,%esp
f0105071:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105074:	89 d6                	mov    %edx,%esi
f0105076:	8b 45 08             	mov    0x8(%ebp),%eax
f0105079:	8b 55 0c             	mov    0xc(%ebp),%edx
f010507c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010507f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105082:	8b 45 10             	mov    0x10(%ebp),%eax
f0105085:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105088:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010508b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010508e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0105095:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0105098:	72 0c                	jb     f01050a6 <printnum+0x3e>
f010509a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f010509d:	76 07                	jbe    f01050a6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010509f:	4b                   	dec    %ebx
f01050a0:	85 db                	test   %ebx,%ebx
f01050a2:	7f 31                	jg     f01050d5 <printnum+0x6d>
f01050a4:	eb 3f                	jmp    f01050e5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01050a6:	83 ec 0c             	sub    $0xc,%esp
f01050a9:	57                   	push   %edi
f01050aa:	4b                   	dec    %ebx
f01050ab:	53                   	push   %ebx
f01050ac:	50                   	push   %eax
f01050ad:	83 ec 08             	sub    $0x8,%esp
f01050b0:	ff 75 d4             	pushl  -0x2c(%ebp)
f01050b3:	ff 75 d0             	pushl  -0x30(%ebp)
f01050b6:	ff 75 dc             	pushl  -0x24(%ebp)
f01050b9:	ff 75 d8             	pushl  -0x28(%ebp)
f01050bc:	e8 2b 12 00 00       	call   f01062ec <__udivdi3>
f01050c1:	83 c4 18             	add    $0x18,%esp
f01050c4:	52                   	push   %edx
f01050c5:	50                   	push   %eax
f01050c6:	89 f2                	mov    %esi,%edx
f01050c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050cb:	e8 98 ff ff ff       	call   f0105068 <printnum>
f01050d0:	83 c4 20             	add    $0x20,%esp
f01050d3:	eb 10                	jmp    f01050e5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01050d5:	83 ec 08             	sub    $0x8,%esp
f01050d8:	56                   	push   %esi
f01050d9:	57                   	push   %edi
f01050da:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01050dd:	4b                   	dec    %ebx
f01050de:	83 c4 10             	add    $0x10,%esp
f01050e1:	85 db                	test   %ebx,%ebx
f01050e3:	7f f0                	jg     f01050d5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01050e5:	83 ec 08             	sub    $0x8,%esp
f01050e8:	56                   	push   %esi
f01050e9:	83 ec 04             	sub    $0x4,%esp
f01050ec:	ff 75 d4             	pushl  -0x2c(%ebp)
f01050ef:	ff 75 d0             	pushl  -0x30(%ebp)
f01050f2:	ff 75 dc             	pushl  -0x24(%ebp)
f01050f5:	ff 75 d8             	pushl  -0x28(%ebp)
f01050f8:	e8 0b 13 00 00       	call   f0106408 <__umoddi3>
f01050fd:	83 c4 14             	add    $0x14,%esp
f0105100:	0f be 80 52 81 10 f0 	movsbl -0xfef7eae(%eax),%eax
f0105107:	50                   	push   %eax
f0105108:	ff 55 e4             	call   *-0x1c(%ebp)
f010510b:	83 c4 10             	add    $0x10,%esp
}
f010510e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105111:	5b                   	pop    %ebx
f0105112:	5e                   	pop    %esi
f0105113:	5f                   	pop    %edi
f0105114:	c9                   	leave  
f0105115:	c3                   	ret    

f0105116 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105116:	55                   	push   %ebp
f0105117:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105119:	83 fa 01             	cmp    $0x1,%edx
f010511c:	7e 0e                	jle    f010512c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010511e:	8b 10                	mov    (%eax),%edx
f0105120:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105123:	89 08                	mov    %ecx,(%eax)
f0105125:	8b 02                	mov    (%edx),%eax
f0105127:	8b 52 04             	mov    0x4(%edx),%edx
f010512a:	eb 22                	jmp    f010514e <getuint+0x38>
	else if (lflag)
f010512c:	85 d2                	test   %edx,%edx
f010512e:	74 10                	je     f0105140 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105130:	8b 10                	mov    (%eax),%edx
f0105132:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105135:	89 08                	mov    %ecx,(%eax)
f0105137:	8b 02                	mov    (%edx),%eax
f0105139:	ba 00 00 00 00       	mov    $0x0,%edx
f010513e:	eb 0e                	jmp    f010514e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105140:	8b 10                	mov    (%eax),%edx
f0105142:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105145:	89 08                	mov    %ecx,(%eax)
f0105147:	8b 02                	mov    (%edx),%eax
f0105149:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010514e:	c9                   	leave  
f010514f:	c3                   	ret    

f0105150 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0105150:	55                   	push   %ebp
f0105151:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105153:	83 fa 01             	cmp    $0x1,%edx
f0105156:	7e 0e                	jle    f0105166 <getint+0x16>
		return va_arg(*ap, long long);
f0105158:	8b 10                	mov    (%eax),%edx
f010515a:	8d 4a 08             	lea    0x8(%edx),%ecx
f010515d:	89 08                	mov    %ecx,(%eax)
f010515f:	8b 02                	mov    (%edx),%eax
f0105161:	8b 52 04             	mov    0x4(%edx),%edx
f0105164:	eb 1a                	jmp    f0105180 <getint+0x30>
	else if (lflag)
f0105166:	85 d2                	test   %edx,%edx
f0105168:	74 0c                	je     f0105176 <getint+0x26>
		return va_arg(*ap, long);
f010516a:	8b 10                	mov    (%eax),%edx
f010516c:	8d 4a 04             	lea    0x4(%edx),%ecx
f010516f:	89 08                	mov    %ecx,(%eax)
f0105171:	8b 02                	mov    (%edx),%eax
f0105173:	99                   	cltd   
f0105174:	eb 0a                	jmp    f0105180 <getint+0x30>
	else
		return va_arg(*ap, int);
f0105176:	8b 10                	mov    (%eax),%edx
f0105178:	8d 4a 04             	lea    0x4(%edx),%ecx
f010517b:	89 08                	mov    %ecx,(%eax)
f010517d:	8b 02                	mov    (%edx),%eax
f010517f:	99                   	cltd   
}
f0105180:	c9                   	leave  
f0105181:	c3                   	ret    

f0105182 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105182:	55                   	push   %ebp
f0105183:	89 e5                	mov    %esp,%ebp
f0105185:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105188:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f010518b:	8b 10                	mov    (%eax),%edx
f010518d:	3b 50 04             	cmp    0x4(%eax),%edx
f0105190:	73 08                	jae    f010519a <sprintputch+0x18>
		*b->buf++ = ch;
f0105192:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105195:	88 0a                	mov    %cl,(%edx)
f0105197:	42                   	inc    %edx
f0105198:	89 10                	mov    %edx,(%eax)
}
f010519a:	c9                   	leave  
f010519b:	c3                   	ret    

f010519c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010519c:	55                   	push   %ebp
f010519d:	89 e5                	mov    %esp,%ebp
f010519f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01051a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01051a5:	50                   	push   %eax
f01051a6:	ff 75 10             	pushl  0x10(%ebp)
f01051a9:	ff 75 0c             	pushl  0xc(%ebp)
f01051ac:	ff 75 08             	pushl  0x8(%ebp)
f01051af:	e8 05 00 00 00       	call   f01051b9 <vprintfmt>
	va_end(ap);
f01051b4:	83 c4 10             	add    $0x10,%esp
}
f01051b7:	c9                   	leave  
f01051b8:	c3                   	ret    

f01051b9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01051b9:	55                   	push   %ebp
f01051ba:	89 e5                	mov    %esp,%ebp
f01051bc:	57                   	push   %edi
f01051bd:	56                   	push   %esi
f01051be:	53                   	push   %ebx
f01051bf:	83 ec 2c             	sub    $0x2c,%esp
f01051c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01051c5:	8b 75 10             	mov    0x10(%ebp),%esi
f01051c8:	eb 13                	jmp    f01051dd <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01051ca:	85 c0                	test   %eax,%eax
f01051cc:	0f 84 6d 03 00 00    	je     f010553f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f01051d2:	83 ec 08             	sub    $0x8,%esp
f01051d5:	57                   	push   %edi
f01051d6:	50                   	push   %eax
f01051d7:	ff 55 08             	call   *0x8(%ebp)
f01051da:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01051dd:	0f b6 06             	movzbl (%esi),%eax
f01051e0:	46                   	inc    %esi
f01051e1:	83 f8 25             	cmp    $0x25,%eax
f01051e4:	75 e4                	jne    f01051ca <vprintfmt+0x11>
f01051e6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f01051ea:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01051f1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f01051f8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01051ff:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105204:	eb 28                	jmp    f010522e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105206:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105208:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f010520c:	eb 20                	jmp    f010522e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010520e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105210:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0105214:	eb 18                	jmp    f010522e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105216:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105218:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010521f:	eb 0d                	jmp    f010522e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105221:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105224:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105227:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010522e:	8a 06                	mov    (%esi),%al
f0105230:	0f b6 d0             	movzbl %al,%edx
f0105233:	8d 5e 01             	lea    0x1(%esi),%ebx
f0105236:	83 e8 23             	sub    $0x23,%eax
f0105239:	3c 55                	cmp    $0x55,%al
f010523b:	0f 87 e0 02 00 00    	ja     f0105521 <vprintfmt+0x368>
f0105241:	0f b6 c0             	movzbl %al,%eax
f0105244:	ff 24 85 20 82 10 f0 	jmp    *-0xfef7de0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010524b:	83 ea 30             	sub    $0x30,%edx
f010524e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0105251:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0105254:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105257:	83 fa 09             	cmp    $0x9,%edx
f010525a:	77 44                	ja     f01052a0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010525c:	89 de                	mov    %ebx,%esi
f010525e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105261:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0105262:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105265:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0105269:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010526c:	8d 58 d0             	lea    -0x30(%eax),%ebx
f010526f:	83 fb 09             	cmp    $0x9,%ebx
f0105272:	76 ed                	jbe    f0105261 <vprintfmt+0xa8>
f0105274:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105277:	eb 29                	jmp    f01052a2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105279:	8b 45 14             	mov    0x14(%ebp),%eax
f010527c:	8d 50 04             	lea    0x4(%eax),%edx
f010527f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105282:	8b 00                	mov    (%eax),%eax
f0105284:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105287:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105289:	eb 17                	jmp    f01052a2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f010528b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010528f:	78 85                	js     f0105216 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105291:	89 de                	mov    %ebx,%esi
f0105293:	eb 99                	jmp    f010522e <vprintfmt+0x75>
f0105295:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105297:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f010529e:	eb 8e                	jmp    f010522e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052a0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01052a2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01052a6:	79 86                	jns    f010522e <vprintfmt+0x75>
f01052a8:	e9 74 ff ff ff       	jmp    f0105221 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01052ad:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052ae:	89 de                	mov    %ebx,%esi
f01052b0:	e9 79 ff ff ff       	jmp    f010522e <vprintfmt+0x75>
f01052b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01052b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01052bb:	8d 50 04             	lea    0x4(%eax),%edx
f01052be:	89 55 14             	mov    %edx,0x14(%ebp)
f01052c1:	83 ec 08             	sub    $0x8,%esp
f01052c4:	57                   	push   %edi
f01052c5:	ff 30                	pushl  (%eax)
f01052c7:	ff 55 08             	call   *0x8(%ebp)
			break;
f01052ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052cd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01052d0:	e9 08 ff ff ff       	jmp    f01051dd <vprintfmt+0x24>
f01052d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01052d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01052db:	8d 50 04             	lea    0x4(%eax),%edx
f01052de:	89 55 14             	mov    %edx,0x14(%ebp)
f01052e1:	8b 00                	mov    (%eax),%eax
f01052e3:	85 c0                	test   %eax,%eax
f01052e5:	79 02                	jns    f01052e9 <vprintfmt+0x130>
f01052e7:	f7 d8                	neg    %eax
f01052e9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01052eb:	83 f8 08             	cmp    $0x8,%eax
f01052ee:	7f 0b                	jg     f01052fb <vprintfmt+0x142>
f01052f0:	8b 04 85 80 83 10 f0 	mov    -0xfef7c80(,%eax,4),%eax
f01052f7:	85 c0                	test   %eax,%eax
f01052f9:	75 1a                	jne    f0105315 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f01052fb:	52                   	push   %edx
f01052fc:	68 6a 81 10 f0       	push   $0xf010816a
f0105301:	57                   	push   %edi
f0105302:	ff 75 08             	pushl  0x8(%ebp)
f0105305:	e8 92 fe ff ff       	call   f010519c <printfmt>
f010530a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010530d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105310:	e9 c8 fe ff ff       	jmp    f01051dd <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0105315:	50                   	push   %eax
f0105316:	68 29 79 10 f0       	push   $0xf0107929
f010531b:	57                   	push   %edi
f010531c:	ff 75 08             	pushl  0x8(%ebp)
f010531f:	e8 78 fe ff ff       	call   f010519c <printfmt>
f0105324:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105327:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010532a:	e9 ae fe ff ff       	jmp    f01051dd <vprintfmt+0x24>
f010532f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0105332:	89 de                	mov    %ebx,%esi
f0105334:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0105337:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010533a:	8b 45 14             	mov    0x14(%ebp),%eax
f010533d:	8d 50 04             	lea    0x4(%eax),%edx
f0105340:	89 55 14             	mov    %edx,0x14(%ebp)
f0105343:	8b 00                	mov    (%eax),%eax
f0105345:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105348:	85 c0                	test   %eax,%eax
f010534a:	75 07                	jne    f0105353 <vprintfmt+0x19a>
				p = "(null)";
f010534c:	c7 45 d0 63 81 10 f0 	movl   $0xf0108163,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0105353:	85 db                	test   %ebx,%ebx
f0105355:	7e 42                	jle    f0105399 <vprintfmt+0x1e0>
f0105357:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f010535b:	74 3c                	je     f0105399 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f010535d:	83 ec 08             	sub    $0x8,%esp
f0105360:	51                   	push   %ecx
f0105361:	ff 75 d0             	pushl  -0x30(%ebp)
f0105364:	e8 3f 03 00 00       	call   f01056a8 <strnlen>
f0105369:	29 c3                	sub    %eax,%ebx
f010536b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010536e:	83 c4 10             	add    $0x10,%esp
f0105371:	85 db                	test   %ebx,%ebx
f0105373:	7e 24                	jle    f0105399 <vprintfmt+0x1e0>
					putch(padc, putdat);
f0105375:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0105379:	89 75 dc             	mov    %esi,-0x24(%ebp)
f010537c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010537f:	83 ec 08             	sub    $0x8,%esp
f0105382:	57                   	push   %edi
f0105383:	53                   	push   %ebx
f0105384:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105387:	4e                   	dec    %esi
f0105388:	83 c4 10             	add    $0x10,%esp
f010538b:	85 f6                	test   %esi,%esi
f010538d:	7f f0                	jg     f010537f <vprintfmt+0x1c6>
f010538f:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0105392:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105399:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010539c:	0f be 02             	movsbl (%edx),%eax
f010539f:	85 c0                	test   %eax,%eax
f01053a1:	75 47                	jne    f01053ea <vprintfmt+0x231>
f01053a3:	eb 37                	jmp    f01053dc <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f01053a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01053a9:	74 16                	je     f01053c1 <vprintfmt+0x208>
f01053ab:	8d 50 e0             	lea    -0x20(%eax),%edx
f01053ae:	83 fa 5e             	cmp    $0x5e,%edx
f01053b1:	76 0e                	jbe    f01053c1 <vprintfmt+0x208>
					putch('?', putdat);
f01053b3:	83 ec 08             	sub    $0x8,%esp
f01053b6:	57                   	push   %edi
f01053b7:	6a 3f                	push   $0x3f
f01053b9:	ff 55 08             	call   *0x8(%ebp)
f01053bc:	83 c4 10             	add    $0x10,%esp
f01053bf:	eb 0b                	jmp    f01053cc <vprintfmt+0x213>
				else
					putch(ch, putdat);
f01053c1:	83 ec 08             	sub    $0x8,%esp
f01053c4:	57                   	push   %edi
f01053c5:	50                   	push   %eax
f01053c6:	ff 55 08             	call   *0x8(%ebp)
f01053c9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01053cc:	ff 4d e4             	decl   -0x1c(%ebp)
f01053cf:	0f be 03             	movsbl (%ebx),%eax
f01053d2:	85 c0                	test   %eax,%eax
f01053d4:	74 03                	je     f01053d9 <vprintfmt+0x220>
f01053d6:	43                   	inc    %ebx
f01053d7:	eb 1b                	jmp    f01053f4 <vprintfmt+0x23b>
f01053d9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01053dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01053e0:	7f 1e                	jg     f0105400 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01053e2:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01053e5:	e9 f3 fd ff ff       	jmp    f01051dd <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01053ea:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01053ed:	43                   	inc    %ebx
f01053ee:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01053f1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01053f4:	85 f6                	test   %esi,%esi
f01053f6:	78 ad                	js     f01053a5 <vprintfmt+0x1ec>
f01053f8:	4e                   	dec    %esi
f01053f9:	79 aa                	jns    f01053a5 <vprintfmt+0x1ec>
f01053fb:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01053fe:	eb dc                	jmp    f01053dc <vprintfmt+0x223>
f0105400:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105403:	83 ec 08             	sub    $0x8,%esp
f0105406:	57                   	push   %edi
f0105407:	6a 20                	push   $0x20
f0105409:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010540c:	4b                   	dec    %ebx
f010540d:	83 c4 10             	add    $0x10,%esp
f0105410:	85 db                	test   %ebx,%ebx
f0105412:	7f ef                	jg     f0105403 <vprintfmt+0x24a>
f0105414:	e9 c4 fd ff ff       	jmp    f01051dd <vprintfmt+0x24>
f0105419:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010541c:	89 ca                	mov    %ecx,%edx
f010541e:	8d 45 14             	lea    0x14(%ebp),%eax
f0105421:	e8 2a fd ff ff       	call   f0105150 <getint>
f0105426:	89 c3                	mov    %eax,%ebx
f0105428:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f010542a:	85 d2                	test   %edx,%edx
f010542c:	78 0a                	js     f0105438 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010542e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105433:	e9 b0 00 00 00       	jmp    f01054e8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105438:	83 ec 08             	sub    $0x8,%esp
f010543b:	57                   	push   %edi
f010543c:	6a 2d                	push   $0x2d
f010543e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105441:	f7 db                	neg    %ebx
f0105443:	83 d6 00             	adc    $0x0,%esi
f0105446:	f7 de                	neg    %esi
f0105448:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010544b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105450:	e9 93 00 00 00       	jmp    f01054e8 <vprintfmt+0x32f>
f0105455:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105458:	89 ca                	mov    %ecx,%edx
f010545a:	8d 45 14             	lea    0x14(%ebp),%eax
f010545d:	e8 b4 fc ff ff       	call   f0105116 <getuint>
f0105462:	89 c3                	mov    %eax,%ebx
f0105464:	89 d6                	mov    %edx,%esi
			base = 10;
f0105466:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010546b:	eb 7b                	jmp    f01054e8 <vprintfmt+0x32f>
f010546d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0105470:	89 ca                	mov    %ecx,%edx
f0105472:	8d 45 14             	lea    0x14(%ebp),%eax
f0105475:	e8 d6 fc ff ff       	call   f0105150 <getint>
f010547a:	89 c3                	mov    %eax,%ebx
f010547c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f010547e:	85 d2                	test   %edx,%edx
f0105480:	78 07                	js     f0105489 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f0105482:	b8 08 00 00 00       	mov    $0x8,%eax
f0105487:	eb 5f                	jmp    f01054e8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0105489:	83 ec 08             	sub    $0x8,%esp
f010548c:	57                   	push   %edi
f010548d:	6a 2d                	push   $0x2d
f010548f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f0105492:	f7 db                	neg    %ebx
f0105494:	83 d6 00             	adc    $0x0,%esi
f0105497:	f7 de                	neg    %esi
f0105499:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f010549c:	b8 08 00 00 00       	mov    $0x8,%eax
f01054a1:	eb 45                	jmp    f01054e8 <vprintfmt+0x32f>
f01054a3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f01054a6:	83 ec 08             	sub    $0x8,%esp
f01054a9:	57                   	push   %edi
f01054aa:	6a 30                	push   $0x30
f01054ac:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01054af:	83 c4 08             	add    $0x8,%esp
f01054b2:	57                   	push   %edi
f01054b3:	6a 78                	push   $0x78
f01054b5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01054b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01054bb:	8d 50 04             	lea    0x4(%eax),%edx
f01054be:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01054c1:	8b 18                	mov    (%eax),%ebx
f01054c3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01054c8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01054cb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01054d0:	eb 16                	jmp    f01054e8 <vprintfmt+0x32f>
f01054d2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01054d5:	89 ca                	mov    %ecx,%edx
f01054d7:	8d 45 14             	lea    0x14(%ebp),%eax
f01054da:	e8 37 fc ff ff       	call   f0105116 <getuint>
f01054df:	89 c3                	mov    %eax,%ebx
f01054e1:	89 d6                	mov    %edx,%esi
			base = 16;
f01054e3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01054e8:	83 ec 0c             	sub    $0xc,%esp
f01054eb:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f01054ef:	52                   	push   %edx
f01054f0:	ff 75 e4             	pushl  -0x1c(%ebp)
f01054f3:	50                   	push   %eax
f01054f4:	56                   	push   %esi
f01054f5:	53                   	push   %ebx
f01054f6:	89 fa                	mov    %edi,%edx
f01054f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01054fb:	e8 68 fb ff ff       	call   f0105068 <printnum>
			break;
f0105500:	83 c4 20             	add    $0x20,%esp
f0105503:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105506:	e9 d2 fc ff ff       	jmp    f01051dd <vprintfmt+0x24>
f010550b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010550e:	83 ec 08             	sub    $0x8,%esp
f0105511:	57                   	push   %edi
f0105512:	52                   	push   %edx
f0105513:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105516:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105519:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010551c:	e9 bc fc ff ff       	jmp    f01051dd <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105521:	83 ec 08             	sub    $0x8,%esp
f0105524:	57                   	push   %edi
f0105525:	6a 25                	push   $0x25
f0105527:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010552a:	83 c4 10             	add    $0x10,%esp
f010552d:	eb 02                	jmp    f0105531 <vprintfmt+0x378>
f010552f:	89 c6                	mov    %eax,%esi
f0105531:	8d 46 ff             	lea    -0x1(%esi),%eax
f0105534:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105538:	75 f5                	jne    f010552f <vprintfmt+0x376>
f010553a:	e9 9e fc ff ff       	jmp    f01051dd <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f010553f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105542:	5b                   	pop    %ebx
f0105543:	5e                   	pop    %esi
f0105544:	5f                   	pop    %edi
f0105545:	c9                   	leave  
f0105546:	c3                   	ret    

f0105547 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105547:	55                   	push   %ebp
f0105548:	89 e5                	mov    %esp,%ebp
f010554a:	83 ec 18             	sub    $0x18,%esp
f010554d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105550:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105553:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105556:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010555a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010555d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105564:	85 c0                	test   %eax,%eax
f0105566:	74 26                	je     f010558e <vsnprintf+0x47>
f0105568:	85 d2                	test   %edx,%edx
f010556a:	7e 29                	jle    f0105595 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010556c:	ff 75 14             	pushl  0x14(%ebp)
f010556f:	ff 75 10             	pushl  0x10(%ebp)
f0105572:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105575:	50                   	push   %eax
f0105576:	68 82 51 10 f0       	push   $0xf0105182
f010557b:	e8 39 fc ff ff       	call   f01051b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105580:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105583:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105586:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105589:	83 c4 10             	add    $0x10,%esp
f010558c:	eb 0c                	jmp    f010559a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010558e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105593:	eb 05                	jmp    f010559a <vsnprintf+0x53>
f0105595:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010559a:	c9                   	leave  
f010559b:	c3                   	ret    

f010559c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010559c:	55                   	push   %ebp
f010559d:	89 e5                	mov    %esp,%ebp
f010559f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01055a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01055a5:	50                   	push   %eax
f01055a6:	ff 75 10             	pushl  0x10(%ebp)
f01055a9:	ff 75 0c             	pushl  0xc(%ebp)
f01055ac:	ff 75 08             	pushl  0x8(%ebp)
f01055af:	e8 93 ff ff ff       	call   f0105547 <vsnprintf>
	va_end(ap);

	return rc;
}
f01055b4:	c9                   	leave  
f01055b5:	c3                   	ret    
	...

f01055b8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01055b8:	55                   	push   %ebp
f01055b9:	89 e5                	mov    %esp,%ebp
f01055bb:	57                   	push   %edi
f01055bc:	56                   	push   %esi
f01055bd:	53                   	push   %ebx
f01055be:	83 ec 0c             	sub    $0xc,%esp
f01055c1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01055c4:	85 c0                	test   %eax,%eax
f01055c6:	74 11                	je     f01055d9 <readline+0x21>
		cprintf("%s", prompt);
f01055c8:	83 ec 08             	sub    $0x8,%esp
f01055cb:	50                   	push   %eax
f01055cc:	68 29 79 10 f0       	push   $0xf0107929
f01055d1:	e8 7f e7 ff ff       	call   f0103d55 <cprintf>
f01055d6:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01055d9:	83 ec 0c             	sub    $0xc,%esp
f01055dc:	6a 00                	push   $0x0
f01055de:	e8 dd b1 ff ff       	call   f01007c0 <iscons>
f01055e3:	89 c7                	mov    %eax,%edi
f01055e5:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01055e8:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01055ed:	e8 bd b1 ff ff       	call   f01007af <getchar>
f01055f2:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01055f4:	85 c0                	test   %eax,%eax
f01055f6:	79 18                	jns    f0105610 <readline+0x58>
			cprintf("read error: %e\n", c);
f01055f8:	83 ec 08             	sub    $0x8,%esp
f01055fb:	50                   	push   %eax
f01055fc:	68 a4 83 10 f0       	push   $0xf01083a4
f0105601:	e8 4f e7 ff ff       	call   f0103d55 <cprintf>
			return NULL;
f0105606:	83 c4 10             	add    $0x10,%esp
f0105609:	b8 00 00 00 00       	mov    $0x0,%eax
f010560e:	eb 6f                	jmp    f010567f <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105610:	83 f8 08             	cmp    $0x8,%eax
f0105613:	74 05                	je     f010561a <readline+0x62>
f0105615:	83 f8 7f             	cmp    $0x7f,%eax
f0105618:	75 18                	jne    f0105632 <readline+0x7a>
f010561a:	85 f6                	test   %esi,%esi
f010561c:	7e 14                	jle    f0105632 <readline+0x7a>
			if (echoing)
f010561e:	85 ff                	test   %edi,%edi
f0105620:	74 0d                	je     f010562f <readline+0x77>
				cputchar('\b');
f0105622:	83 ec 0c             	sub    $0xc,%esp
f0105625:	6a 08                	push   $0x8
f0105627:	e8 73 b1 ff ff       	call   f010079f <cputchar>
f010562c:	83 c4 10             	add    $0x10,%esp
			i--;
f010562f:	4e                   	dec    %esi
f0105630:	eb bb                	jmp    f01055ed <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105632:	83 fb 1f             	cmp    $0x1f,%ebx
f0105635:	7e 21                	jle    f0105658 <readline+0xa0>
f0105637:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010563d:	7f 19                	jg     f0105658 <readline+0xa0>
			if (echoing)
f010563f:	85 ff                	test   %edi,%edi
f0105641:	74 0c                	je     f010564f <readline+0x97>
				cputchar(c);
f0105643:	83 ec 0c             	sub    $0xc,%esp
f0105646:	53                   	push   %ebx
f0105647:	e8 53 b1 ff ff       	call   f010079f <cputchar>
f010564c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010564f:	88 9e 80 5a 2e f0    	mov    %bl,-0xfd1a580(%esi)
f0105655:	46                   	inc    %esi
f0105656:	eb 95                	jmp    f01055ed <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105658:	83 fb 0a             	cmp    $0xa,%ebx
f010565b:	74 05                	je     f0105662 <readline+0xaa>
f010565d:	83 fb 0d             	cmp    $0xd,%ebx
f0105660:	75 8b                	jne    f01055ed <readline+0x35>
			if (echoing)
f0105662:	85 ff                	test   %edi,%edi
f0105664:	74 0d                	je     f0105673 <readline+0xbb>
				cputchar('\n');
f0105666:	83 ec 0c             	sub    $0xc,%esp
f0105669:	6a 0a                	push   $0xa
f010566b:	e8 2f b1 ff ff       	call   f010079f <cputchar>
f0105670:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105673:	c6 86 80 5a 2e f0 00 	movb   $0x0,-0xfd1a580(%esi)
			return buf;
f010567a:	b8 80 5a 2e f0       	mov    $0xf02e5a80,%eax
		}
	}
}
f010567f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105682:	5b                   	pop    %ebx
f0105683:	5e                   	pop    %esi
f0105684:	5f                   	pop    %edi
f0105685:	c9                   	leave  
f0105686:	c3                   	ret    
	...

f0105688 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105688:	55                   	push   %ebp
f0105689:	89 e5                	mov    %esp,%ebp
f010568b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010568e:	80 3a 00             	cmpb   $0x0,(%edx)
f0105691:	74 0e                	je     f01056a1 <strlen+0x19>
f0105693:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105698:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105699:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010569d:	75 f9                	jne    f0105698 <strlen+0x10>
f010569f:	eb 05                	jmp    f01056a6 <strlen+0x1e>
f01056a1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01056a6:	c9                   	leave  
f01056a7:	c3                   	ret    

f01056a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01056a8:	55                   	push   %ebp
f01056a9:	89 e5                	mov    %esp,%ebp
f01056ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01056b1:	85 d2                	test   %edx,%edx
f01056b3:	74 17                	je     f01056cc <strnlen+0x24>
f01056b5:	80 39 00             	cmpb   $0x0,(%ecx)
f01056b8:	74 19                	je     f01056d3 <strnlen+0x2b>
f01056ba:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01056bf:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01056c0:	39 d0                	cmp    %edx,%eax
f01056c2:	74 14                	je     f01056d8 <strnlen+0x30>
f01056c4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01056c8:	75 f5                	jne    f01056bf <strnlen+0x17>
f01056ca:	eb 0c                	jmp    f01056d8 <strnlen+0x30>
f01056cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01056d1:	eb 05                	jmp    f01056d8 <strnlen+0x30>
f01056d3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01056d8:	c9                   	leave  
f01056d9:	c3                   	ret    

f01056da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01056da:	55                   	push   %ebp
f01056db:	89 e5                	mov    %esp,%ebp
f01056dd:	53                   	push   %ebx
f01056de:	8b 45 08             	mov    0x8(%ebp),%eax
f01056e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01056e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01056e9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01056ec:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01056ef:	42                   	inc    %edx
f01056f0:	84 c9                	test   %cl,%cl
f01056f2:	75 f5                	jne    f01056e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01056f4:	5b                   	pop    %ebx
f01056f5:	c9                   	leave  
f01056f6:	c3                   	ret    

f01056f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01056f7:	55                   	push   %ebp
f01056f8:	89 e5                	mov    %esp,%ebp
f01056fa:	53                   	push   %ebx
f01056fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01056fe:	53                   	push   %ebx
f01056ff:	e8 84 ff ff ff       	call   f0105688 <strlen>
f0105704:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105707:	ff 75 0c             	pushl  0xc(%ebp)
f010570a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f010570d:	50                   	push   %eax
f010570e:	e8 c7 ff ff ff       	call   f01056da <strcpy>
	return dst;
}
f0105713:	89 d8                	mov    %ebx,%eax
f0105715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105718:	c9                   	leave  
f0105719:	c3                   	ret    

f010571a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010571a:	55                   	push   %ebp
f010571b:	89 e5                	mov    %esp,%ebp
f010571d:	56                   	push   %esi
f010571e:	53                   	push   %ebx
f010571f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105722:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105725:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105728:	85 f6                	test   %esi,%esi
f010572a:	74 15                	je     f0105741 <strncpy+0x27>
f010572c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0105731:	8a 1a                	mov    (%edx),%bl
f0105733:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105736:	80 3a 01             	cmpb   $0x1,(%edx)
f0105739:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010573c:	41                   	inc    %ecx
f010573d:	39 ce                	cmp    %ecx,%esi
f010573f:	77 f0                	ja     f0105731 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105741:	5b                   	pop    %ebx
f0105742:	5e                   	pop    %esi
f0105743:	c9                   	leave  
f0105744:	c3                   	ret    

f0105745 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105745:	55                   	push   %ebp
f0105746:	89 e5                	mov    %esp,%ebp
f0105748:	57                   	push   %edi
f0105749:	56                   	push   %esi
f010574a:	53                   	push   %ebx
f010574b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010574e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105751:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105754:	85 f6                	test   %esi,%esi
f0105756:	74 32                	je     f010578a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0105758:	83 fe 01             	cmp    $0x1,%esi
f010575b:	74 22                	je     f010577f <strlcpy+0x3a>
f010575d:	8a 0b                	mov    (%ebx),%cl
f010575f:	84 c9                	test   %cl,%cl
f0105761:	74 20                	je     f0105783 <strlcpy+0x3e>
f0105763:	89 f8                	mov    %edi,%eax
f0105765:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010576a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010576d:	88 08                	mov    %cl,(%eax)
f010576f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105770:	39 f2                	cmp    %esi,%edx
f0105772:	74 11                	je     f0105785 <strlcpy+0x40>
f0105774:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0105778:	42                   	inc    %edx
f0105779:	84 c9                	test   %cl,%cl
f010577b:	75 f0                	jne    f010576d <strlcpy+0x28>
f010577d:	eb 06                	jmp    f0105785 <strlcpy+0x40>
f010577f:	89 f8                	mov    %edi,%eax
f0105781:	eb 02                	jmp    f0105785 <strlcpy+0x40>
f0105783:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105785:	c6 00 00             	movb   $0x0,(%eax)
f0105788:	eb 02                	jmp    f010578c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010578a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f010578c:	29 f8                	sub    %edi,%eax
}
f010578e:	5b                   	pop    %ebx
f010578f:	5e                   	pop    %esi
f0105790:	5f                   	pop    %edi
f0105791:	c9                   	leave  
f0105792:	c3                   	ret    

f0105793 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105793:	55                   	push   %ebp
f0105794:	89 e5                	mov    %esp,%ebp
f0105796:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105799:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010579c:	8a 01                	mov    (%ecx),%al
f010579e:	84 c0                	test   %al,%al
f01057a0:	74 10                	je     f01057b2 <strcmp+0x1f>
f01057a2:	3a 02                	cmp    (%edx),%al
f01057a4:	75 0c                	jne    f01057b2 <strcmp+0x1f>
		p++, q++;
f01057a6:	41                   	inc    %ecx
f01057a7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01057a8:	8a 01                	mov    (%ecx),%al
f01057aa:	84 c0                	test   %al,%al
f01057ac:	74 04                	je     f01057b2 <strcmp+0x1f>
f01057ae:	3a 02                	cmp    (%edx),%al
f01057b0:	74 f4                	je     f01057a6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01057b2:	0f b6 c0             	movzbl %al,%eax
f01057b5:	0f b6 12             	movzbl (%edx),%edx
f01057b8:	29 d0                	sub    %edx,%eax
}
f01057ba:	c9                   	leave  
f01057bb:	c3                   	ret    

f01057bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01057bc:	55                   	push   %ebp
f01057bd:	89 e5                	mov    %esp,%ebp
f01057bf:	53                   	push   %ebx
f01057c0:	8b 55 08             	mov    0x8(%ebp),%edx
f01057c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01057c6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01057c9:	85 c0                	test   %eax,%eax
f01057cb:	74 1b                	je     f01057e8 <strncmp+0x2c>
f01057cd:	8a 1a                	mov    (%edx),%bl
f01057cf:	84 db                	test   %bl,%bl
f01057d1:	74 24                	je     f01057f7 <strncmp+0x3b>
f01057d3:	3a 19                	cmp    (%ecx),%bl
f01057d5:	75 20                	jne    f01057f7 <strncmp+0x3b>
f01057d7:	48                   	dec    %eax
f01057d8:	74 15                	je     f01057ef <strncmp+0x33>
		n--, p++, q++;
f01057da:	42                   	inc    %edx
f01057db:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01057dc:	8a 1a                	mov    (%edx),%bl
f01057de:	84 db                	test   %bl,%bl
f01057e0:	74 15                	je     f01057f7 <strncmp+0x3b>
f01057e2:	3a 19                	cmp    (%ecx),%bl
f01057e4:	74 f1                	je     f01057d7 <strncmp+0x1b>
f01057e6:	eb 0f                	jmp    f01057f7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01057e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01057ed:	eb 05                	jmp    f01057f4 <strncmp+0x38>
f01057ef:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01057f4:	5b                   	pop    %ebx
f01057f5:	c9                   	leave  
f01057f6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01057f7:	0f b6 02             	movzbl (%edx),%eax
f01057fa:	0f b6 11             	movzbl (%ecx),%edx
f01057fd:	29 d0                	sub    %edx,%eax
f01057ff:	eb f3                	jmp    f01057f4 <strncmp+0x38>

f0105801 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105801:	55                   	push   %ebp
f0105802:	89 e5                	mov    %esp,%ebp
f0105804:	8b 45 08             	mov    0x8(%ebp),%eax
f0105807:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010580a:	8a 10                	mov    (%eax),%dl
f010580c:	84 d2                	test   %dl,%dl
f010580e:	74 18                	je     f0105828 <strchr+0x27>
		if (*s == c)
f0105810:	38 ca                	cmp    %cl,%dl
f0105812:	75 06                	jne    f010581a <strchr+0x19>
f0105814:	eb 17                	jmp    f010582d <strchr+0x2c>
f0105816:	38 ca                	cmp    %cl,%dl
f0105818:	74 13                	je     f010582d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010581a:	40                   	inc    %eax
f010581b:	8a 10                	mov    (%eax),%dl
f010581d:	84 d2                	test   %dl,%dl
f010581f:	75 f5                	jne    f0105816 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0105821:	b8 00 00 00 00       	mov    $0x0,%eax
f0105826:	eb 05                	jmp    f010582d <strchr+0x2c>
f0105828:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010582d:	c9                   	leave  
f010582e:	c3                   	ret    

f010582f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010582f:	55                   	push   %ebp
f0105830:	89 e5                	mov    %esp,%ebp
f0105832:	8b 45 08             	mov    0x8(%ebp),%eax
f0105835:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105838:	8a 10                	mov    (%eax),%dl
f010583a:	84 d2                	test   %dl,%dl
f010583c:	74 11                	je     f010584f <strfind+0x20>
		if (*s == c)
f010583e:	38 ca                	cmp    %cl,%dl
f0105840:	75 06                	jne    f0105848 <strfind+0x19>
f0105842:	eb 0b                	jmp    f010584f <strfind+0x20>
f0105844:	38 ca                	cmp    %cl,%dl
f0105846:	74 07                	je     f010584f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105848:	40                   	inc    %eax
f0105849:	8a 10                	mov    (%eax),%dl
f010584b:	84 d2                	test   %dl,%dl
f010584d:	75 f5                	jne    f0105844 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f010584f:	c9                   	leave  
f0105850:	c3                   	ret    

f0105851 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105851:	55                   	push   %ebp
f0105852:	89 e5                	mov    %esp,%ebp
f0105854:	57                   	push   %edi
f0105855:	56                   	push   %esi
f0105856:	53                   	push   %ebx
f0105857:	8b 7d 08             	mov    0x8(%ebp),%edi
f010585a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010585d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105860:	85 c9                	test   %ecx,%ecx
f0105862:	74 30                	je     f0105894 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105864:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010586a:	75 25                	jne    f0105891 <memset+0x40>
f010586c:	f6 c1 03             	test   $0x3,%cl
f010586f:	75 20                	jne    f0105891 <memset+0x40>
		c &= 0xFF;
f0105871:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105874:	89 d3                	mov    %edx,%ebx
f0105876:	c1 e3 08             	shl    $0x8,%ebx
f0105879:	89 d6                	mov    %edx,%esi
f010587b:	c1 e6 18             	shl    $0x18,%esi
f010587e:	89 d0                	mov    %edx,%eax
f0105880:	c1 e0 10             	shl    $0x10,%eax
f0105883:	09 f0                	or     %esi,%eax
f0105885:	09 d0                	or     %edx,%eax
f0105887:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105889:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f010588c:	fc                   	cld    
f010588d:	f3 ab                	rep stos %eax,%es:(%edi)
f010588f:	eb 03                	jmp    f0105894 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105891:	fc                   	cld    
f0105892:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105894:	89 f8                	mov    %edi,%eax
f0105896:	5b                   	pop    %ebx
f0105897:	5e                   	pop    %esi
f0105898:	5f                   	pop    %edi
f0105899:	c9                   	leave  
f010589a:	c3                   	ret    

f010589b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010589b:	55                   	push   %ebp
f010589c:	89 e5                	mov    %esp,%ebp
f010589e:	57                   	push   %edi
f010589f:	56                   	push   %esi
f01058a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01058a3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01058a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01058a9:	39 c6                	cmp    %eax,%esi
f01058ab:	73 34                	jae    f01058e1 <memmove+0x46>
f01058ad:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01058b0:	39 d0                	cmp    %edx,%eax
f01058b2:	73 2d                	jae    f01058e1 <memmove+0x46>
		s += n;
		d += n;
f01058b4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01058b7:	f6 c2 03             	test   $0x3,%dl
f01058ba:	75 1b                	jne    f01058d7 <memmove+0x3c>
f01058bc:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01058c2:	75 13                	jne    f01058d7 <memmove+0x3c>
f01058c4:	f6 c1 03             	test   $0x3,%cl
f01058c7:	75 0e                	jne    f01058d7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01058c9:	83 ef 04             	sub    $0x4,%edi
f01058cc:	8d 72 fc             	lea    -0x4(%edx),%esi
f01058cf:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01058d2:	fd                   	std    
f01058d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01058d5:	eb 07                	jmp    f01058de <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01058d7:	4f                   	dec    %edi
f01058d8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01058db:	fd                   	std    
f01058dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01058de:	fc                   	cld    
f01058df:	eb 20                	jmp    f0105901 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01058e1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01058e7:	75 13                	jne    f01058fc <memmove+0x61>
f01058e9:	a8 03                	test   $0x3,%al
f01058eb:	75 0f                	jne    f01058fc <memmove+0x61>
f01058ed:	f6 c1 03             	test   $0x3,%cl
f01058f0:	75 0a                	jne    f01058fc <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01058f2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01058f5:	89 c7                	mov    %eax,%edi
f01058f7:	fc                   	cld    
f01058f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01058fa:	eb 05                	jmp    f0105901 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01058fc:	89 c7                	mov    %eax,%edi
f01058fe:	fc                   	cld    
f01058ff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105901:	5e                   	pop    %esi
f0105902:	5f                   	pop    %edi
f0105903:	c9                   	leave  
f0105904:	c3                   	ret    

f0105905 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105905:	55                   	push   %ebp
f0105906:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105908:	ff 75 10             	pushl  0x10(%ebp)
f010590b:	ff 75 0c             	pushl  0xc(%ebp)
f010590e:	ff 75 08             	pushl  0x8(%ebp)
f0105911:	e8 85 ff ff ff       	call   f010589b <memmove>
}
f0105916:	c9                   	leave  
f0105917:	c3                   	ret    

f0105918 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105918:	55                   	push   %ebp
f0105919:	89 e5                	mov    %esp,%ebp
f010591b:	57                   	push   %edi
f010591c:	56                   	push   %esi
f010591d:	53                   	push   %ebx
f010591e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105921:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105924:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105927:	85 ff                	test   %edi,%edi
f0105929:	74 32                	je     f010595d <memcmp+0x45>
		if (*s1 != *s2)
f010592b:	8a 03                	mov    (%ebx),%al
f010592d:	8a 0e                	mov    (%esi),%cl
f010592f:	38 c8                	cmp    %cl,%al
f0105931:	74 19                	je     f010594c <memcmp+0x34>
f0105933:	eb 0d                	jmp    f0105942 <memcmp+0x2a>
f0105935:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0105939:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f010593d:	42                   	inc    %edx
f010593e:	38 c8                	cmp    %cl,%al
f0105940:	74 10                	je     f0105952 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f0105942:	0f b6 c0             	movzbl %al,%eax
f0105945:	0f b6 c9             	movzbl %cl,%ecx
f0105948:	29 c8                	sub    %ecx,%eax
f010594a:	eb 16                	jmp    f0105962 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010594c:	4f                   	dec    %edi
f010594d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105952:	39 fa                	cmp    %edi,%edx
f0105954:	75 df                	jne    f0105935 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105956:	b8 00 00 00 00       	mov    $0x0,%eax
f010595b:	eb 05                	jmp    f0105962 <memcmp+0x4a>
f010595d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105962:	5b                   	pop    %ebx
f0105963:	5e                   	pop    %esi
f0105964:	5f                   	pop    %edi
f0105965:	c9                   	leave  
f0105966:	c3                   	ret    

f0105967 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105967:	55                   	push   %ebp
f0105968:	89 e5                	mov    %esp,%ebp
f010596a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010596d:	89 c2                	mov    %eax,%edx
f010596f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105972:	39 d0                	cmp    %edx,%eax
f0105974:	73 12                	jae    f0105988 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105976:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0105979:	38 08                	cmp    %cl,(%eax)
f010597b:	75 06                	jne    f0105983 <memfind+0x1c>
f010597d:	eb 09                	jmp    f0105988 <memfind+0x21>
f010597f:	38 08                	cmp    %cl,(%eax)
f0105981:	74 05                	je     f0105988 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105983:	40                   	inc    %eax
f0105984:	39 c2                	cmp    %eax,%edx
f0105986:	77 f7                	ja     f010597f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105988:	c9                   	leave  
f0105989:	c3                   	ret    

f010598a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010598a:	55                   	push   %ebp
f010598b:	89 e5                	mov    %esp,%ebp
f010598d:	57                   	push   %edi
f010598e:	56                   	push   %esi
f010598f:	53                   	push   %ebx
f0105990:	8b 55 08             	mov    0x8(%ebp),%edx
f0105993:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105996:	eb 01                	jmp    f0105999 <strtol+0xf>
		s++;
f0105998:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105999:	8a 02                	mov    (%edx),%al
f010599b:	3c 20                	cmp    $0x20,%al
f010599d:	74 f9                	je     f0105998 <strtol+0xe>
f010599f:	3c 09                	cmp    $0x9,%al
f01059a1:	74 f5                	je     f0105998 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01059a3:	3c 2b                	cmp    $0x2b,%al
f01059a5:	75 08                	jne    f01059af <strtol+0x25>
		s++;
f01059a7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01059a8:	bf 00 00 00 00       	mov    $0x0,%edi
f01059ad:	eb 13                	jmp    f01059c2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01059af:	3c 2d                	cmp    $0x2d,%al
f01059b1:	75 0a                	jne    f01059bd <strtol+0x33>
		s++, neg = 1;
f01059b3:	8d 52 01             	lea    0x1(%edx),%edx
f01059b6:	bf 01 00 00 00       	mov    $0x1,%edi
f01059bb:	eb 05                	jmp    f01059c2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01059bd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01059c2:	85 db                	test   %ebx,%ebx
f01059c4:	74 05                	je     f01059cb <strtol+0x41>
f01059c6:	83 fb 10             	cmp    $0x10,%ebx
f01059c9:	75 28                	jne    f01059f3 <strtol+0x69>
f01059cb:	8a 02                	mov    (%edx),%al
f01059cd:	3c 30                	cmp    $0x30,%al
f01059cf:	75 10                	jne    f01059e1 <strtol+0x57>
f01059d1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01059d5:	75 0a                	jne    f01059e1 <strtol+0x57>
		s += 2, base = 16;
f01059d7:	83 c2 02             	add    $0x2,%edx
f01059da:	bb 10 00 00 00       	mov    $0x10,%ebx
f01059df:	eb 12                	jmp    f01059f3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01059e1:	85 db                	test   %ebx,%ebx
f01059e3:	75 0e                	jne    f01059f3 <strtol+0x69>
f01059e5:	3c 30                	cmp    $0x30,%al
f01059e7:	75 05                	jne    f01059ee <strtol+0x64>
		s++, base = 8;
f01059e9:	42                   	inc    %edx
f01059ea:	b3 08                	mov    $0x8,%bl
f01059ec:	eb 05                	jmp    f01059f3 <strtol+0x69>
	else if (base == 0)
		base = 10;
f01059ee:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01059f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01059f8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01059fa:	8a 0a                	mov    (%edx),%cl
f01059fc:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01059ff:	80 fb 09             	cmp    $0x9,%bl
f0105a02:	77 08                	ja     f0105a0c <strtol+0x82>
			dig = *s - '0';
f0105a04:	0f be c9             	movsbl %cl,%ecx
f0105a07:	83 e9 30             	sub    $0x30,%ecx
f0105a0a:	eb 1e                	jmp    f0105a2a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0105a0c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0105a0f:	80 fb 19             	cmp    $0x19,%bl
f0105a12:	77 08                	ja     f0105a1c <strtol+0x92>
			dig = *s - 'a' + 10;
f0105a14:	0f be c9             	movsbl %cl,%ecx
f0105a17:	83 e9 57             	sub    $0x57,%ecx
f0105a1a:	eb 0e                	jmp    f0105a2a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0105a1c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0105a1f:	80 fb 19             	cmp    $0x19,%bl
f0105a22:	77 13                	ja     f0105a37 <strtol+0xad>
			dig = *s - 'A' + 10;
f0105a24:	0f be c9             	movsbl %cl,%ecx
f0105a27:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105a2a:	39 f1                	cmp    %esi,%ecx
f0105a2c:	7d 0d                	jge    f0105a3b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f0105a2e:	42                   	inc    %edx
f0105a2f:	0f af c6             	imul   %esi,%eax
f0105a32:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0105a35:	eb c3                	jmp    f01059fa <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0105a37:	89 c1                	mov    %eax,%ecx
f0105a39:	eb 02                	jmp    f0105a3d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105a3b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0105a3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105a41:	74 05                	je     f0105a48 <strtol+0xbe>
		*endptr = (char *) s;
f0105a43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105a46:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105a48:	85 ff                	test   %edi,%edi
f0105a4a:	74 04                	je     f0105a50 <strtol+0xc6>
f0105a4c:	89 c8                	mov    %ecx,%eax
f0105a4e:	f7 d8                	neg    %eax
}
f0105a50:	5b                   	pop    %ebx
f0105a51:	5e                   	pop    %esi
f0105a52:	5f                   	pop    %edi
f0105a53:	c9                   	leave  
f0105a54:	c3                   	ret    
f0105a55:	00 00                	add    %al,(%eax)
	...

f0105a58 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105a58:	fa                   	cli    

	xorw    %ax, %ax
f0105a59:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105a5b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a5d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a5f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105a61:	0f 01 16             	lgdtl  (%esi)
f0105a64:	74 70                	je     f0105ad6 <sum+0x2>
	movl    %cr0, %eax
f0105a66:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105a69:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105a6d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105a70:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105a76:	08 00                	or     %al,(%eax)

f0105a78 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105a78:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105a7c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a7e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a80:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105a82:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105a86:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105a88:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105a8a:	b8 00 60 12 00       	mov    $0x126000,%eax
	movl    %eax, %cr3
f0105a8f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105a92:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105a95:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105a9a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105a9d:	8b 25 84 5e 2e f0    	mov    0xf02e5e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105aa3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105aa8:	b8 c2 00 10 f0       	mov    $0xf01000c2,%eax
	call    *%eax
f0105aad:	ff d0                	call   *%eax

f0105aaf <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105aaf:	eb fe                	jmp    f0105aaf <spin>
f0105ab1:	8d 76 00             	lea    0x0(%esi),%esi

f0105ab4 <gdt>:
	...
f0105abc:	ff                   	(bad)  
f0105abd:	ff 00                	incl   (%eax)
f0105abf:	00 00                	add    %al,(%eax)
f0105ac1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105ac8:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105acc <gdtdesc>:
f0105acc:	17                   	pop    %ss
f0105acd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105ad2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105ad2:	90                   	nop
	...

f0105ad4 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105ad4:	55                   	push   %ebp
f0105ad5:	89 e5                	mov    %esp,%ebp
f0105ad7:	56                   	push   %esi
f0105ad8:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105ad9:	85 d2                	test   %edx,%edx
f0105adb:	7e 17                	jle    f0105af4 <sum+0x20>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105add:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0105ae2:	b9 00 00 00 00       	mov    $0x0,%ecx
		sum += ((uint8_t *)addr)[i];
f0105ae7:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0105aeb:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105aed:	41                   	inc    %ecx
f0105aee:	39 d1                	cmp    %edx,%ecx
f0105af0:	75 f5                	jne    f0105ae7 <sum+0x13>
f0105af2:	eb 05                	jmp    f0105af9 <sum+0x25>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105af4:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0105af9:	88 d8                	mov    %bl,%al
f0105afb:	5b                   	pop    %ebx
f0105afc:	5e                   	pop    %esi
f0105afd:	c9                   	leave  
f0105afe:	c3                   	ret    

f0105aff <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105aff:	55                   	push   %ebp
f0105b00:	89 e5                	mov    %esp,%ebp
f0105b02:	56                   	push   %esi
f0105b03:	53                   	push   %ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b04:	8b 0d 88 5e 2e f0    	mov    0xf02e5e88,%ecx
f0105b0a:	89 c3                	mov    %eax,%ebx
f0105b0c:	c1 eb 0c             	shr    $0xc,%ebx
f0105b0f:	39 cb                	cmp    %ecx,%ebx
f0105b11:	72 12                	jb     f0105b25 <mpsearch1+0x26>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b13:	50                   	push   %eax
f0105b14:	68 88 65 10 f0       	push   $0xf0106588
f0105b19:	6a 57                	push   $0x57
f0105b1b:	68 41 85 10 f0       	push   $0xf0108541
f0105b20:	e8 43 a5 ff ff       	call   f0100068 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105b25:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b28:	89 f2                	mov    %esi,%edx
f0105b2a:	c1 ea 0c             	shr    $0xc,%edx
f0105b2d:	39 d1                	cmp    %edx,%ecx
f0105b2f:	77 12                	ja     f0105b43 <mpsearch1+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b31:	56                   	push   %esi
f0105b32:	68 88 65 10 f0       	push   $0xf0106588
f0105b37:	6a 57                	push   $0x57
f0105b39:	68 41 85 10 f0       	push   $0xf0108541
f0105b3e:	e8 25 a5 ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f0105b43:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0105b49:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105b4f:	39 f3                	cmp    %esi,%ebx
f0105b51:	73 35                	jae    f0105b88 <mpsearch1+0x89>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105b53:	83 ec 04             	sub    $0x4,%esp
f0105b56:	6a 04                	push   $0x4
f0105b58:	68 51 85 10 f0       	push   $0xf0108551
f0105b5d:	53                   	push   %ebx
f0105b5e:	e8 b5 fd ff ff       	call   f0105918 <memcmp>
f0105b63:	83 c4 10             	add    $0x10,%esp
f0105b66:	85 c0                	test   %eax,%eax
f0105b68:	75 10                	jne    f0105b7a <mpsearch1+0x7b>
		    sum(mp, sizeof(*mp)) == 0)
f0105b6a:	ba 10 00 00 00       	mov    $0x10,%edx
f0105b6f:	89 d8                	mov    %ebx,%eax
f0105b71:	e8 5e ff ff ff       	call   f0105ad4 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105b76:	84 c0                	test   %al,%al
f0105b78:	74 13                	je     f0105b8d <mpsearch1+0x8e>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105b7a:	83 c3 10             	add    $0x10,%ebx
f0105b7d:	39 de                	cmp    %ebx,%esi
f0105b7f:	77 d2                	ja     f0105b53 <mpsearch1+0x54>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105b81:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105b86:	eb 05                	jmp    f0105b8d <mpsearch1+0x8e>
f0105b88:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105b8d:	89 d8                	mov    %ebx,%eax
f0105b8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105b92:	5b                   	pop    %ebx
f0105b93:	5e                   	pop    %esi
f0105b94:	c9                   	leave  
f0105b95:	c3                   	ret    

f0105b96 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105b96:	55                   	push   %ebp
f0105b97:	89 e5                	mov    %esp,%ebp
f0105b99:	57                   	push   %edi
f0105b9a:	56                   	push   %esi
f0105b9b:	53                   	push   %ebx
f0105b9c:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105b9f:	c7 05 c0 63 2e f0 20 	movl   $0xf02e6020,0xf02e63c0
f0105ba6:	60 2e f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ba9:	83 3d 88 5e 2e f0 00 	cmpl   $0x0,0xf02e5e88
f0105bb0:	75 16                	jne    f0105bc8 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105bb2:	68 00 04 00 00       	push   $0x400
f0105bb7:	68 88 65 10 f0       	push   $0xf0106588
f0105bbc:	6a 6f                	push   $0x6f
f0105bbe:	68 41 85 10 f0       	push   $0xf0108541
f0105bc3:	e8 a0 a4 ff ff       	call   f0100068 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105bc8:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105bcf:	85 c0                	test   %eax,%eax
f0105bd1:	74 16                	je     f0105be9 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
f0105bd3:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105bd6:	ba 00 04 00 00       	mov    $0x400,%edx
f0105bdb:	e8 1f ff ff ff       	call   f0105aff <mpsearch1>
f0105be0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105be3:	85 c0                	test   %eax,%eax
f0105be5:	75 3c                	jne    f0105c23 <mp_init+0x8d>
f0105be7:	eb 20                	jmp    f0105c09 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105be9:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105bf0:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105bf3:	2d 00 04 00 00       	sub    $0x400,%eax
f0105bf8:	ba 00 04 00 00       	mov    $0x400,%edx
f0105bfd:	e8 fd fe ff ff       	call   f0105aff <mpsearch1>
f0105c02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105c05:	85 c0                	test   %eax,%eax
f0105c07:	75 1a                	jne    f0105c23 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105c09:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c0e:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105c13:	e8 e7 fe ff ff       	call   f0105aff <mpsearch1>
f0105c18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105c1b:	85 c0                	test   %eax,%eax
f0105c1d:	0f 84 3b 02 00 00    	je     f0105e5e <mp_init+0x2c8>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105c23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c26:	8b 70 04             	mov    0x4(%eax),%esi
f0105c29:	85 f6                	test   %esi,%esi
f0105c2b:	74 06                	je     f0105c33 <mp_init+0x9d>
f0105c2d:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105c31:	74 15                	je     f0105c48 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105c33:	83 ec 0c             	sub    $0xc,%esp
f0105c36:	68 b4 83 10 f0       	push   $0xf01083b4
f0105c3b:	e8 15 e1 ff ff       	call   f0103d55 <cprintf>
f0105c40:	83 c4 10             	add    $0x10,%esp
f0105c43:	e9 16 02 00 00       	jmp    f0105e5e <mp_init+0x2c8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105c48:	89 f0                	mov    %esi,%eax
f0105c4a:	c1 e8 0c             	shr    $0xc,%eax
f0105c4d:	3b 05 88 5e 2e f0    	cmp    0xf02e5e88,%eax
f0105c53:	72 15                	jb     f0105c6a <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105c55:	56                   	push   %esi
f0105c56:	68 88 65 10 f0       	push   $0xf0106588
f0105c5b:	68 90 00 00 00       	push   $0x90
f0105c60:	68 41 85 10 f0       	push   $0xf0108541
f0105c65:	e8 fe a3 ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f0105c6a:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105c70:	83 ec 04             	sub    $0x4,%esp
f0105c73:	6a 04                	push   $0x4
f0105c75:	68 56 85 10 f0       	push   $0xf0108556
f0105c7a:	56                   	push   %esi
f0105c7b:	e8 98 fc ff ff       	call   f0105918 <memcmp>
f0105c80:	83 c4 10             	add    $0x10,%esp
f0105c83:	85 c0                	test   %eax,%eax
f0105c85:	74 15                	je     f0105c9c <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105c87:	83 ec 0c             	sub    $0xc,%esp
f0105c8a:	68 e4 83 10 f0       	push   $0xf01083e4
f0105c8f:	e8 c1 e0 ff ff       	call   f0103d55 <cprintf>
f0105c94:	83 c4 10             	add    $0x10,%esp
f0105c97:	e9 c2 01 00 00       	jmp    f0105e5e <mp_init+0x2c8>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105c9c:	66 8b 5e 04          	mov    0x4(%esi),%bx
f0105ca0:	0f b7 d3             	movzwl %bx,%edx
f0105ca3:	89 f0                	mov    %esi,%eax
f0105ca5:	e8 2a fe ff ff       	call   f0105ad4 <sum>
f0105caa:	84 c0                	test   %al,%al
f0105cac:	74 15                	je     f0105cc3 <mp_init+0x12d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105cae:	83 ec 0c             	sub    $0xc,%esp
f0105cb1:	68 18 84 10 f0       	push   $0xf0108418
f0105cb6:	e8 9a e0 ff ff       	call   f0103d55 <cprintf>
f0105cbb:	83 c4 10             	add    $0x10,%esp
f0105cbe:	e9 9b 01 00 00       	jmp    f0105e5e <mp_init+0x2c8>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105cc3:	8a 46 06             	mov    0x6(%esi),%al
f0105cc6:	3c 01                	cmp    $0x1,%al
f0105cc8:	74 1d                	je     f0105ce7 <mp_init+0x151>
f0105cca:	3c 04                	cmp    $0x4,%al
f0105ccc:	74 19                	je     f0105ce7 <mp_init+0x151>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105cce:	83 ec 08             	sub    $0x8,%esp
f0105cd1:	0f b6 c0             	movzbl %al,%eax
f0105cd4:	50                   	push   %eax
f0105cd5:	68 3c 84 10 f0       	push   $0xf010843c
f0105cda:	e8 76 e0 ff ff       	call   f0103d55 <cprintf>
f0105cdf:	83 c4 10             	add    $0x10,%esp
f0105ce2:	e9 77 01 00 00       	jmp    f0105e5e <mp_init+0x2c8>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0105ce7:	0f b7 56 28          	movzwl 0x28(%esi),%edx
f0105ceb:	0f b7 c3             	movzwl %bx,%eax
f0105cee:	8d 04 06             	lea    (%esi,%eax,1),%eax
f0105cf1:	e8 de fd ff ff       	call   f0105ad4 <sum>
f0105cf6:	3a 46 2a             	cmp    0x2a(%esi),%al
f0105cf9:	74 15                	je     f0105d10 <mp_init+0x17a>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105cfb:	83 ec 0c             	sub    $0xc,%esp
f0105cfe:	68 5c 84 10 f0       	push   $0xf010845c
f0105d03:	e8 4d e0 ff ff       	call   f0103d55 <cprintf>
f0105d08:	83 c4 10             	add    $0x10,%esp
f0105d0b:	e9 4e 01 00 00       	jmp    f0105e5e <mp_init+0x2c8>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105d10:	85 f6                	test   %esi,%esi
f0105d12:	0f 84 46 01 00 00    	je     f0105e5e <mp_init+0x2c8>
		return;
	ismp = 1;
f0105d18:	c7 05 00 60 2e f0 01 	movl   $0x1,0xf02e6000
f0105d1f:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105d22:	8b 46 24             	mov    0x24(%esi),%eax
f0105d25:	a3 00 70 32 f0       	mov    %eax,0xf0327000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d2a:	66 83 7e 22 00       	cmpw   $0x0,0x22(%esi)
f0105d2f:	0f 84 ac 00 00 00    	je     f0105de1 <mp_init+0x24b>
f0105d35:	8d 5e 2c             	lea    0x2c(%esi),%ebx
f0105d38:	bf 00 00 00 00       	mov    $0x0,%edi
		switch (*p) {
f0105d3d:	8a 03                	mov    (%ebx),%al
f0105d3f:	84 c0                	test   %al,%al
f0105d41:	74 06                	je     f0105d49 <mp_init+0x1b3>
f0105d43:	3c 04                	cmp    $0x4,%al
f0105d45:	77 6b                	ja     f0105db2 <mp_init+0x21c>
f0105d47:	eb 64                	jmp    f0105dad <mp_init+0x217>
		case MPPROC:
			proc = (struct mpproc *)p;
f0105d49:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f0105d4b:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f0105d4f:	74 1d                	je     f0105d6e <mp_init+0x1d8>
				bootcpu = &cpus[ncpu];
f0105d51:	a1 c4 63 2e f0       	mov    0xf02e63c4,%eax
f0105d56:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0105d5d:	29 c1                	sub    %eax,%ecx
f0105d5f:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0105d62:	8d 04 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%eax
f0105d69:	a3 c0 63 2e f0       	mov    %eax,0xf02e63c0
			if (ncpu < NCPU) {
f0105d6e:	a1 c4 63 2e f0       	mov    0xf02e63c4,%eax
f0105d73:	83 f8 07             	cmp    $0x7,%eax
f0105d76:	7f 1b                	jg     f0105d93 <mp_init+0x1fd>
				cpus[ncpu].cpu_id = ncpu;
f0105d78:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105d7f:	29 c2                	sub    %eax,%edx
f0105d81:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105d84:	88 04 95 20 60 2e f0 	mov    %al,-0xfd19fe0(,%edx,4)
				ncpu++;
f0105d8b:	40                   	inc    %eax
f0105d8c:	a3 c4 63 2e f0       	mov    %eax,0xf02e63c4
f0105d91:	eb 15                	jmp    f0105da8 <mp_init+0x212>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105d93:	83 ec 08             	sub    $0x8,%esp
f0105d96:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0105d9a:	50                   	push   %eax
f0105d9b:	68 8c 84 10 f0       	push   $0xf010848c
f0105da0:	e8 b0 df ff ff       	call   f0103d55 <cprintf>
f0105da5:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105da8:	83 c3 14             	add    $0x14,%ebx
			continue;
f0105dab:	eb 27                	jmp    f0105dd4 <mp_init+0x23e>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105dad:	83 c3 08             	add    $0x8,%ebx
			continue;
f0105db0:	eb 22                	jmp    f0105dd4 <mp_init+0x23e>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105db2:	83 ec 08             	sub    $0x8,%esp
f0105db5:	0f b6 c0             	movzbl %al,%eax
f0105db8:	50                   	push   %eax
f0105db9:	68 b4 84 10 f0       	push   $0xf01084b4
f0105dbe:	e8 92 df ff ff       	call   f0103d55 <cprintf>
			ismp = 0;
f0105dc3:	c7 05 00 60 2e f0 00 	movl   $0x0,0xf02e6000
f0105dca:	00 00 00 
			i = conf->entry;
f0105dcd:	0f b7 7e 22          	movzwl 0x22(%esi),%edi
f0105dd1:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105dd4:	47                   	inc    %edi
f0105dd5:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105dd9:	39 f8                	cmp    %edi,%eax
f0105ddb:	0f 87 5c ff ff ff    	ja     f0105d3d <mp_init+0x1a7>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105de1:	a1 c0 63 2e f0       	mov    0xf02e63c0,%eax
f0105de6:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105ded:	83 3d 00 60 2e f0 00 	cmpl   $0x0,0xf02e6000
f0105df4:	75 26                	jne    f0105e1c <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105df6:	c7 05 c4 63 2e f0 01 	movl   $0x1,0xf02e63c4
f0105dfd:	00 00 00 
		lapicaddr = 0;
f0105e00:	c7 05 00 70 32 f0 00 	movl   $0x0,0xf0327000
f0105e07:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105e0a:	83 ec 0c             	sub    $0xc,%esp
f0105e0d:	68 d4 84 10 f0       	push   $0xf01084d4
f0105e12:	e8 3e df ff ff       	call   f0103d55 <cprintf>
		return;
f0105e17:	83 c4 10             	add    $0x10,%esp
f0105e1a:	eb 42                	jmp    f0105e5e <mp_init+0x2c8>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105e1c:	83 ec 04             	sub    $0x4,%esp
f0105e1f:	ff 35 c4 63 2e f0    	pushl  0xf02e63c4
f0105e25:	0f b6 00             	movzbl (%eax),%eax
f0105e28:	50                   	push   %eax
f0105e29:	68 5b 85 10 f0       	push   $0xf010855b
f0105e2e:	e8 22 df ff ff       	call   f0103d55 <cprintf>

	if (mp->imcrp) {
f0105e33:	83 c4 10             	add    $0x10,%esp
f0105e36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e39:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105e3d:	74 1f                	je     f0105e5e <mp_init+0x2c8>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105e3f:	83 ec 0c             	sub    $0xc,%esp
f0105e42:	68 00 85 10 f0       	push   $0xf0108500
f0105e47:	e8 09 df ff ff       	call   f0103d55 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105e4c:	ba 22 00 00 00       	mov    $0x22,%edx
f0105e51:	b0 70                	mov    $0x70,%al
f0105e53:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105e54:	b2 23                	mov    $0x23,%dl
f0105e56:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105e57:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105e5a:	ee                   	out    %al,(%dx)
f0105e5b:	83 c4 10             	add    $0x10,%esp
	}
}
f0105e5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105e61:	5b                   	pop    %ebx
f0105e62:	5e                   	pop    %esi
f0105e63:	5f                   	pop    %edi
f0105e64:	c9                   	leave  
f0105e65:	c3                   	ret    
	...

f0105e68 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105e68:	55                   	push   %ebp
f0105e69:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105e6b:	c1 e0 02             	shl    $0x2,%eax
f0105e6e:	03 05 04 70 32 f0    	add    0xf0327004,%eax
f0105e74:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105e76:	a1 04 70 32 f0       	mov    0xf0327004,%eax
f0105e7b:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105e7e:	c9                   	leave  
f0105e7f:	c3                   	ret    

f0105e80 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105e80:	55                   	push   %ebp
f0105e81:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105e83:	a1 04 70 32 f0       	mov    0xf0327004,%eax
f0105e88:	85 c0                	test   %eax,%eax
f0105e8a:	74 08                	je     f0105e94 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105e8c:	8b 40 20             	mov    0x20(%eax),%eax
f0105e8f:	c1 e8 18             	shr    $0x18,%eax
f0105e92:	eb 05                	jmp    f0105e99 <cpunum+0x19>
	return 0;
f0105e94:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e99:	c9                   	leave  
f0105e9a:	c3                   	ret    

f0105e9b <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105e9b:	55                   	push   %ebp
f0105e9c:	89 e5                	mov    %esp,%ebp
f0105e9e:	83 ec 08             	sub    $0x8,%esp
	if (!lapicaddr)
f0105ea1:	a1 00 70 32 f0       	mov    0xf0327000,%eax
f0105ea6:	85 c0                	test   %eax,%eax
f0105ea8:	0f 84 2a 01 00 00    	je     f0105fd8 <lapic_init+0x13d>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105eae:	83 ec 08             	sub    $0x8,%esp
f0105eb1:	68 00 10 00 00       	push   $0x1000
f0105eb6:	50                   	push   %eax
f0105eb7:	e8 26 ba ff ff       	call   f01018e2 <mmio_map_region>
f0105ebc:	a3 04 70 32 f0       	mov    %eax,0xf0327004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105ec1:	ba 27 01 00 00       	mov    $0x127,%edx
f0105ec6:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105ecb:	e8 98 ff ff ff       	call   f0105e68 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105ed0:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105ed5:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105eda:	e8 89 ff ff ff       	call   f0105e68 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105edf:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105ee4:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105ee9:	e8 7a ff ff ff       	call   f0105e68 <lapicw>
	lapicw(TICR, 10000000); 
f0105eee:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105ef3:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105ef8:	e8 6b ff ff ff       	call   f0105e68 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105efd:	e8 7e ff ff ff       	call   f0105e80 <cpunum>
f0105f02:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105f09:	29 c2                	sub    %eax,%edx
f0105f0b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105f0e:	8d 04 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%eax
f0105f15:	83 c4 10             	add    $0x10,%esp
f0105f18:	39 05 c0 63 2e f0    	cmp    %eax,0xf02e63c0
f0105f1e:	74 0f                	je     f0105f2f <lapic_init+0x94>
		lapicw(LINT0, MASKED);
f0105f20:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f25:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105f2a:	e8 39 ff ff ff       	call   f0105e68 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105f2f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f34:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105f39:	e8 2a ff ff ff       	call   f0105e68 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105f3e:	a1 04 70 32 f0       	mov    0xf0327004,%eax
f0105f43:	8b 40 30             	mov    0x30(%eax),%eax
f0105f46:	c1 e8 10             	shr    $0x10,%eax
f0105f49:	3c 03                	cmp    $0x3,%al
f0105f4b:	76 0f                	jbe    f0105f5c <lapic_init+0xc1>
		lapicw(PCINT, MASKED);
f0105f4d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f52:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105f57:	e8 0c ff ff ff       	call   f0105e68 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105f5c:	ba 33 00 00 00       	mov    $0x33,%edx
f0105f61:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105f66:	e8 fd fe ff ff       	call   f0105e68 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105f6b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f70:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105f75:	e8 ee fe ff ff       	call   f0105e68 <lapicw>
	lapicw(ESR, 0);
f0105f7a:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f7f:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105f84:	e8 df fe ff ff       	call   f0105e68 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105f89:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f8e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105f93:	e8 d0 fe ff ff       	call   f0105e68 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105f98:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f9d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fa2:	e8 c1 fe ff ff       	call   f0105e68 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105fa7:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105fac:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fb1:	e8 b2 fe ff ff       	call   f0105e68 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105fb6:	8b 15 04 70 32 f0    	mov    0xf0327004,%edx
f0105fbc:	81 c2 00 03 00 00    	add    $0x300,%edx
f0105fc2:	8b 02                	mov    (%edx),%eax
f0105fc4:	f6 c4 10             	test   $0x10,%ah
f0105fc7:	75 f9                	jne    f0105fc2 <lapic_init+0x127>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105fc9:	ba 00 00 00 00       	mov    $0x0,%edx
f0105fce:	b8 20 00 00 00       	mov    $0x20,%eax
f0105fd3:	e8 90 fe ff ff       	call   f0105e68 <lapicw>
}
f0105fd8:	c9                   	leave  
f0105fd9:	c3                   	ret    

f0105fda <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105fda:	55                   	push   %ebp
f0105fdb:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105fdd:	83 3d 04 70 32 f0 00 	cmpl   $0x0,0xf0327004
f0105fe4:	74 0f                	je     f0105ff5 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0105fe6:	ba 00 00 00 00       	mov    $0x0,%edx
f0105feb:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105ff0:	e8 73 fe ff ff       	call   f0105e68 <lapicw>
}
f0105ff5:	c9                   	leave  
f0105ff6:	c3                   	ret    

f0105ff7 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105ff7:	55                   	push   %ebp
f0105ff8:	89 e5                	mov    %esp,%ebp
f0105ffa:	56                   	push   %esi
f0105ffb:	53                   	push   %ebx
f0105ffc:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105fff:	8a 5d 08             	mov    0x8(%ebp),%bl
f0106002:	ba 70 00 00 00       	mov    $0x70,%edx
f0106007:	b0 0f                	mov    $0xf,%al
f0106009:	ee                   	out    %al,(%dx)
f010600a:	b2 71                	mov    $0x71,%dl
f010600c:	b0 0a                	mov    $0xa,%al
f010600e:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010600f:	83 3d 88 5e 2e f0 00 	cmpl   $0x0,0xf02e5e88
f0106016:	75 19                	jne    f0106031 <lapic_startap+0x3a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106018:	68 67 04 00 00       	push   $0x467
f010601d:	68 88 65 10 f0       	push   $0xf0106588
f0106022:	68 98 00 00 00       	push   $0x98
f0106027:	68 78 85 10 f0       	push   $0xf0108578
f010602c:	e8 37 a0 ff ff       	call   f0100068 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106031:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106038:	00 00 
	wrv[1] = addr >> 4;
f010603a:	89 f0                	mov    %esi,%eax
f010603c:	c1 e8 04             	shr    $0x4,%eax
f010603f:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106045:	c1 e3 18             	shl    $0x18,%ebx
f0106048:	89 da                	mov    %ebx,%edx
f010604a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010604f:	e8 14 fe ff ff       	call   f0105e68 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106054:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106059:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010605e:	e8 05 fe ff ff       	call   f0105e68 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106063:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106068:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010606d:	e8 f6 fd ff ff       	call   f0105e68 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106072:	c1 ee 0c             	shr    $0xc,%esi
f0106075:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010607b:	89 da                	mov    %ebx,%edx
f010607d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106082:	e8 e1 fd ff ff       	call   f0105e68 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106087:	89 f2                	mov    %esi,%edx
f0106089:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010608e:	e8 d5 fd ff ff       	call   f0105e68 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106093:	89 da                	mov    %ebx,%edx
f0106095:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010609a:	e8 c9 fd ff ff       	call   f0105e68 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010609f:	89 f2                	mov    %esi,%edx
f01060a1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060a6:	e8 bd fd ff ff       	call   f0105e68 <lapicw>
		microdelay(200);
	}
}
f01060ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01060ae:	5b                   	pop    %ebx
f01060af:	5e                   	pop    %esi
f01060b0:	c9                   	leave  
f01060b1:	c3                   	ret    

f01060b2 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01060b2:	55                   	push   %ebp
f01060b3:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01060b5:	8b 55 08             	mov    0x8(%ebp),%edx
f01060b8:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01060be:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060c3:	e8 a0 fd ff ff       	call   f0105e68 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01060c8:	8b 15 04 70 32 f0    	mov    0xf0327004,%edx
f01060ce:	81 c2 00 03 00 00    	add    $0x300,%edx
f01060d4:	8b 02                	mov    (%edx),%eax
f01060d6:	f6 c4 10             	test   $0x10,%ah
f01060d9:	75 f9                	jne    f01060d4 <lapic_ipi+0x22>
		;
}
f01060db:	c9                   	leave  
f01060dc:	c3                   	ret    
f01060dd:	00 00                	add    %al,(%eax)
	...

f01060e0 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01060e0:	55                   	push   %ebp
f01060e1:	89 e5                	mov    %esp,%ebp
f01060e3:	53                   	push   %ebx
f01060e4:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01060e7:	83 38 00             	cmpl   $0x0,(%eax)
f01060ea:	74 25                	je     f0106111 <holding+0x31>
f01060ec:	8b 58 08             	mov    0x8(%eax),%ebx
f01060ef:	e8 8c fd ff ff       	call   f0105e80 <cpunum>
f01060f4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01060fb:	29 c2                	sub    %eax,%edx
f01060fd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106100:	8d 04 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106107:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106109:	0f 94 c0             	sete   %al
f010610c:	0f b6 c0             	movzbl %al,%eax
f010610f:	eb 05                	jmp    f0106116 <holding+0x36>
f0106111:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106116:	83 c4 04             	add    $0x4,%esp
f0106119:	5b                   	pop    %ebx
f010611a:	c9                   	leave  
f010611b:	c3                   	ret    

f010611c <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010611c:	55                   	push   %ebp
f010611d:	89 e5                	mov    %esp,%ebp
f010611f:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106122:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106128:	8b 55 0c             	mov    0xc(%ebp),%edx
f010612b:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010612e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106135:	c9                   	leave  
f0106136:	c3                   	ret    

f0106137 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106137:	55                   	push   %ebp
f0106138:	89 e5                	mov    %esp,%ebp
f010613a:	53                   	push   %ebx
f010613b:	83 ec 04             	sub    $0x4,%esp
f010613e:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106141:	89 d8                	mov    %ebx,%eax
f0106143:	e8 98 ff ff ff       	call   f01060e0 <holding>
f0106148:	85 c0                	test   %eax,%eax
f010614a:	75 0d                	jne    f0106159 <spin_lock+0x22>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010614c:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010614e:	b0 01                	mov    $0x1,%al
f0106150:	f0 87 03             	lock xchg %eax,(%ebx)
f0106153:	85 c0                	test   %eax,%eax
f0106155:	75 20                	jne    f0106177 <spin_lock+0x40>
f0106157:	eb 2e                	jmp    f0106187 <spin_lock+0x50>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106159:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010615c:	e8 1f fd ff ff       	call   f0105e80 <cpunum>
f0106161:	83 ec 0c             	sub    $0xc,%esp
f0106164:	53                   	push   %ebx
f0106165:	50                   	push   %eax
f0106166:	68 88 85 10 f0       	push   $0xf0108588
f010616b:	6a 41                	push   $0x41
f010616d:	68 ec 85 10 f0       	push   $0xf01085ec
f0106172:	e8 f1 9e ff ff       	call   f0100068 <_panic>
f0106177:	b9 01 00 00 00       	mov    $0x1,%ecx

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010617c:	f3 90                	pause  
f010617e:	89 c8                	mov    %ecx,%eax
f0106180:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106183:	85 c0                	test   %eax,%eax
f0106185:	75 f5                	jne    f010617c <spin_lock+0x45>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106187:	e8 f4 fc ff ff       	call   f0105e80 <cpunum>
f010618c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106193:	29 c2                	sub    %eax,%edx
f0106195:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106198:	8d 04 85 20 60 2e f0 	lea    -0xfd19fe0(,%eax,4),%eax
f010619f:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01061a2:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01061a5:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01061a7:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01061ac:	77 30                	ja     f01061de <spin_lock+0xa7>
f01061ae:	eb 27                	jmp    f01061d7 <spin_lock+0xa0>
f01061b0:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01061b6:	76 10                	jbe    f01061c8 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01061b8:	8b 5a 04             	mov    0x4(%edx),%ebx
f01061bb:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01061be:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01061c0:	40                   	inc    %eax
f01061c1:	83 f8 0a             	cmp    $0xa,%eax
f01061c4:	75 ea                	jne    f01061b0 <spin_lock+0x79>
f01061c6:	eb 25                	jmp    f01061ed <spin_lock+0xb6>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01061c8:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01061cf:	40                   	inc    %eax
f01061d0:	83 f8 09             	cmp    $0x9,%eax
f01061d3:	7e f3                	jle    f01061c8 <spin_lock+0x91>
f01061d5:	eb 16                	jmp    f01061ed <spin_lock+0xb6>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01061d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01061dc:	eb ea                	jmp    f01061c8 <spin_lock+0x91>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01061de:	8b 50 04             	mov    0x4(%eax),%edx
f01061e1:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01061e4:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01061e6:	b8 01 00 00 00       	mov    $0x1,%eax
f01061eb:	eb c3                	jmp    f01061b0 <spin_lock+0x79>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01061ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01061f0:	c9                   	leave  
f01061f1:	c3                   	ret    

f01061f2 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01061f2:	55                   	push   %ebp
f01061f3:	89 e5                	mov    %esp,%ebp
f01061f5:	57                   	push   %edi
f01061f6:	56                   	push   %esi
f01061f7:	53                   	push   %ebx
f01061f8:	83 ec 4c             	sub    $0x4c,%esp
f01061fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01061fe:	89 d8                	mov    %ebx,%eax
f0106200:	e8 db fe ff ff       	call   f01060e0 <holding>
f0106205:	85 c0                	test   %eax,%eax
f0106207:	0f 85 c0 00 00 00    	jne    f01062cd <spin_unlock+0xdb>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010620d:	83 ec 04             	sub    $0x4,%esp
f0106210:	6a 28                	push   $0x28
f0106212:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106215:	50                   	push   %eax
f0106216:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0106219:	50                   	push   %eax
f010621a:	e8 7c f6 ff ff       	call   f010589b <memmove>
			
		cprintf("%u\n", lk->cpu->cpu_id);
f010621f:	83 c4 08             	add    $0x8,%esp
f0106222:	8b 43 08             	mov    0x8(%ebx),%eax
f0106225:	0f b6 00             	movzbl (%eax),%eax
f0106228:	50                   	push   %eax
f0106229:	68 78 68 10 f0       	push   $0xf0106878
f010622e:	e8 22 db ff ff       	call   f0103d55 <cprintf>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106233:	8b 43 08             	mov    0x8(%ebx),%eax
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
			
		cprintf("%u\n", lk->cpu->cpu_id);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106236:	0f b6 30             	movzbl (%eax),%esi
f0106239:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010623c:	e8 3f fc ff ff       	call   f0105e80 <cpunum>
f0106241:	56                   	push   %esi
f0106242:	53                   	push   %ebx
f0106243:	50                   	push   %eax
f0106244:	68 b4 85 10 f0       	push   $0xf01085b4
f0106249:	e8 07 db ff ff       	call   f0103d55 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
f010624e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0106251:	83 c4 20             	add    $0x20,%esp
f0106254:	85 c0                	test   %eax,%eax
f0106256:	74 61                	je     f01062b9 <spin_unlock+0xc7>
f0106258:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f010625b:	8d 7d cc             	lea    -0x34(%ebp),%edi
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010625e:	8d 75 d0             	lea    -0x30(%ebp),%esi
f0106261:	83 ec 08             	sub    $0x8,%esp
f0106264:	56                   	push   %esi
f0106265:	50                   	push   %eax
f0106266:	e8 3e eb ff ff       	call   f0104da9 <debuginfo_eip>
f010626b:	83 c4 10             	add    $0x10,%esp
f010626e:	85 c0                	test   %eax,%eax
f0106270:	78 27                	js     f0106299 <spin_unlock+0xa7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106272:	8b 03                	mov    (%ebx),%eax
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106274:	83 ec 04             	sub    $0x4,%esp
f0106277:	89 c2                	mov    %eax,%edx
f0106279:	2b 55 e0             	sub    -0x20(%ebp),%edx
f010627c:	52                   	push   %edx
f010627d:	ff 75 d8             	pushl  -0x28(%ebp)
f0106280:	ff 75 dc             	pushl  -0x24(%ebp)
f0106283:	ff 75 d4             	pushl  -0x2c(%ebp)
f0106286:	ff 75 d0             	pushl  -0x30(%ebp)
f0106289:	50                   	push   %eax
f010628a:	68 fc 85 10 f0       	push   $0xf01085fc
f010628f:	e8 c1 da ff ff       	call   f0103d55 <cprintf>
f0106294:	83 c4 20             	add    $0x20,%esp
f0106297:	eb 12                	jmp    f01062ab <spin_unlock+0xb9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106299:	83 ec 08             	sub    $0x8,%esp
f010629c:	ff 33                	pushl  (%ebx)
f010629e:	68 13 86 10 f0       	push   $0xf0108613
f01062a3:	e8 ad da ff ff       	call   f0103d55 <cprintf>
f01062a8:	83 c4 10             	add    $0x10,%esp
			
		cprintf("%u\n", lk->cpu->cpu_id);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);

		for (i = 0; i < 10 && pcs[i]; i++) {
f01062ab:	39 fb                	cmp    %edi,%ebx
f01062ad:	74 0a                	je     f01062b9 <spin_unlock+0xc7>
f01062af:	8b 43 04             	mov    0x4(%ebx),%eax
f01062b2:	83 c3 04             	add    $0x4,%ebx
f01062b5:	85 c0                	test   %eax,%eax
f01062b7:	75 a8                	jne    f0106261 <spin_unlock+0x6f>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01062b9:	83 ec 04             	sub    $0x4,%esp
f01062bc:	68 1b 86 10 f0       	push   $0xf010861b
f01062c1:	6a 6a                	push   $0x6a
f01062c3:	68 ec 85 10 f0       	push   $0xf01085ec
f01062c8:	e8 9b 9d ff ff       	call   f0100068 <_panic>
	}
	lk->pcs[0] = 0;
f01062cd:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f01062d4:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01062db:	b8 00 00 00 00       	mov    $0x0,%eax
f01062e0:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f01062e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01062e6:	5b                   	pop    %ebx
f01062e7:	5e                   	pop    %esi
f01062e8:	5f                   	pop    %edi
f01062e9:	c9                   	leave  
f01062ea:	c3                   	ret    
	...

f01062ec <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01062ec:	55                   	push   %ebp
f01062ed:	89 e5                	mov    %esp,%ebp
f01062ef:	57                   	push   %edi
f01062f0:	56                   	push   %esi
f01062f1:	83 ec 10             	sub    $0x10,%esp
f01062f4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01062f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01062fa:	89 7d f0             	mov    %edi,-0x10(%ebp)
f01062fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0106300:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0106303:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106306:	85 c0                	test   %eax,%eax
f0106308:	75 2e                	jne    f0106338 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f010630a:	39 f1                	cmp    %esi,%ecx
f010630c:	77 5a                	ja     f0106368 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f010630e:	85 c9                	test   %ecx,%ecx
f0106310:	75 0b                	jne    f010631d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106312:	b8 01 00 00 00       	mov    $0x1,%eax
f0106317:	31 d2                	xor    %edx,%edx
f0106319:	f7 f1                	div    %ecx
f010631b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010631d:	31 d2                	xor    %edx,%edx
f010631f:	89 f0                	mov    %esi,%eax
f0106321:	f7 f1                	div    %ecx
f0106323:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106325:	89 f8                	mov    %edi,%eax
f0106327:	f7 f1                	div    %ecx
f0106329:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010632b:	89 f8                	mov    %edi,%eax
f010632d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010632f:	83 c4 10             	add    $0x10,%esp
f0106332:	5e                   	pop    %esi
f0106333:	5f                   	pop    %edi
f0106334:	c9                   	leave  
f0106335:	c3                   	ret    
f0106336:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106338:	39 f0                	cmp    %esi,%eax
f010633a:	77 1c                	ja     f0106358 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f010633c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f010633f:	83 f7 1f             	xor    $0x1f,%edi
f0106342:	75 3c                	jne    f0106380 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106344:	39 f0                	cmp    %esi,%eax
f0106346:	0f 82 90 00 00 00    	jb     f01063dc <__udivdi3+0xf0>
f010634c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010634f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0106352:	0f 86 84 00 00 00    	jbe    f01063dc <__udivdi3+0xf0>
f0106358:	31 f6                	xor    %esi,%esi
f010635a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010635c:	89 f8                	mov    %edi,%eax
f010635e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106360:	83 c4 10             	add    $0x10,%esp
f0106363:	5e                   	pop    %esi
f0106364:	5f                   	pop    %edi
f0106365:	c9                   	leave  
f0106366:	c3                   	ret    
f0106367:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106368:	89 f2                	mov    %esi,%edx
f010636a:	89 f8                	mov    %edi,%eax
f010636c:	f7 f1                	div    %ecx
f010636e:	89 c7                	mov    %eax,%edi
f0106370:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106372:	89 f8                	mov    %edi,%eax
f0106374:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106376:	83 c4 10             	add    $0x10,%esp
f0106379:	5e                   	pop    %esi
f010637a:	5f                   	pop    %edi
f010637b:	c9                   	leave  
f010637c:	c3                   	ret    
f010637d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106380:	89 f9                	mov    %edi,%ecx
f0106382:	d3 e0                	shl    %cl,%eax
f0106384:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0106387:	b8 20 00 00 00       	mov    $0x20,%eax
f010638c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f010638e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106391:	88 c1                	mov    %al,%cl
f0106393:	d3 ea                	shr    %cl,%edx
f0106395:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0106398:	09 ca                	or     %ecx,%edx
f010639a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f010639d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01063a0:	89 f9                	mov    %edi,%ecx
f01063a2:	d3 e2                	shl    %cl,%edx
f01063a4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f01063a7:	89 f2                	mov    %esi,%edx
f01063a9:	88 c1                	mov    %al,%cl
f01063ab:	d3 ea                	shr    %cl,%edx
f01063ad:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f01063b0:	89 f2                	mov    %esi,%edx
f01063b2:	89 f9                	mov    %edi,%ecx
f01063b4:	d3 e2                	shl    %cl,%edx
f01063b6:	8b 75 f0             	mov    -0x10(%ebp),%esi
f01063b9:	88 c1                	mov    %al,%cl
f01063bb:	d3 ee                	shr    %cl,%esi
f01063bd:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01063bf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01063c2:	89 f0                	mov    %esi,%eax
f01063c4:	89 ca                	mov    %ecx,%edx
f01063c6:	f7 75 ec             	divl   -0x14(%ebp)
f01063c9:	89 d1                	mov    %edx,%ecx
f01063cb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01063cd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01063d0:	39 d1                	cmp    %edx,%ecx
f01063d2:	72 28                	jb     f01063fc <__udivdi3+0x110>
f01063d4:	74 1a                	je     f01063f0 <__udivdi3+0x104>
f01063d6:	89 f7                	mov    %esi,%edi
f01063d8:	31 f6                	xor    %esi,%esi
f01063da:	eb 80                	jmp    f010635c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01063dc:	31 f6                	xor    %esi,%esi
f01063de:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01063e3:	89 f8                	mov    %edi,%eax
f01063e5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01063e7:	83 c4 10             	add    $0x10,%esp
f01063ea:	5e                   	pop    %esi
f01063eb:	5f                   	pop    %edi
f01063ec:	c9                   	leave  
f01063ed:	c3                   	ret    
f01063ee:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01063f0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01063f3:	89 f9                	mov    %edi,%ecx
f01063f5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01063f7:	39 c2                	cmp    %eax,%edx
f01063f9:	73 db                	jae    f01063d6 <__udivdi3+0xea>
f01063fb:	90                   	nop
		{
		  q0--;
f01063fc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01063ff:	31 f6                	xor    %esi,%esi
f0106401:	e9 56 ff ff ff       	jmp    f010635c <__udivdi3+0x70>
	...

f0106408 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0106408:	55                   	push   %ebp
f0106409:	89 e5                	mov    %esp,%ebp
f010640b:	57                   	push   %edi
f010640c:	56                   	push   %esi
f010640d:	83 ec 20             	sub    $0x20,%esp
f0106410:	8b 45 08             	mov    0x8(%ebp),%eax
f0106413:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0106416:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106419:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f010641c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010641f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0106422:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0106425:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106427:	85 ff                	test   %edi,%edi
f0106429:	75 15                	jne    f0106440 <__umoddi3+0x38>
    {
      if (d0 > n1)
f010642b:	39 f1                	cmp    %esi,%ecx
f010642d:	0f 86 99 00 00 00    	jbe    f01064cc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106433:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0106435:	89 d0                	mov    %edx,%eax
f0106437:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106439:	83 c4 20             	add    $0x20,%esp
f010643c:	5e                   	pop    %esi
f010643d:	5f                   	pop    %edi
f010643e:	c9                   	leave  
f010643f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106440:	39 f7                	cmp    %esi,%edi
f0106442:	0f 87 a4 00 00 00    	ja     f01064ec <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106448:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f010644b:	83 f0 1f             	xor    $0x1f,%eax
f010644e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106451:	0f 84 a1 00 00 00    	je     f01064f8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106457:	89 f8                	mov    %edi,%eax
f0106459:	8a 4d ec             	mov    -0x14(%ebp),%cl
f010645c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010645e:	bf 20 00 00 00       	mov    $0x20,%edi
f0106463:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0106466:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106469:	89 f9                	mov    %edi,%ecx
f010646b:	d3 ea                	shr    %cl,%edx
f010646d:	09 c2                	or     %eax,%edx
f010646f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0106472:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106475:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0106478:	d3 e0                	shl    %cl,%eax
f010647a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f010647d:	89 f2                	mov    %esi,%edx
f010647f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0106481:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106484:	d3 e0                	shl    %cl,%eax
f0106486:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106489:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010648c:	89 f9                	mov    %edi,%ecx
f010648e:	d3 e8                	shr    %cl,%eax
f0106490:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0106492:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106494:	89 f2                	mov    %esi,%edx
f0106496:	f7 75 f0             	divl   -0x10(%ebp)
f0106499:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f010649b:	f7 65 f4             	mull   -0xc(%ebp)
f010649e:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01064a1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01064a3:	39 d6                	cmp    %edx,%esi
f01064a5:	72 71                	jb     f0106518 <__umoddi3+0x110>
f01064a7:	74 7f                	je     f0106528 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01064a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01064ac:	29 c8                	sub    %ecx,%eax
f01064ae:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01064b0:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01064b3:	d3 e8                	shr    %cl,%eax
f01064b5:	89 f2                	mov    %esi,%edx
f01064b7:	89 f9                	mov    %edi,%ecx
f01064b9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01064bb:	09 d0                	or     %edx,%eax
f01064bd:	89 f2                	mov    %esi,%edx
f01064bf:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01064c2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01064c4:	83 c4 20             	add    $0x20,%esp
f01064c7:	5e                   	pop    %esi
f01064c8:	5f                   	pop    %edi
f01064c9:	c9                   	leave  
f01064ca:	c3                   	ret    
f01064cb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01064cc:	85 c9                	test   %ecx,%ecx
f01064ce:	75 0b                	jne    f01064db <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01064d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01064d5:	31 d2                	xor    %edx,%edx
f01064d7:	f7 f1                	div    %ecx
f01064d9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01064db:	89 f0                	mov    %esi,%eax
f01064dd:	31 d2                	xor    %edx,%edx
f01064df:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01064e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01064e4:	f7 f1                	div    %ecx
f01064e6:	e9 4a ff ff ff       	jmp    f0106435 <__umoddi3+0x2d>
f01064eb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f01064ec:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01064ee:	83 c4 20             	add    $0x20,%esp
f01064f1:	5e                   	pop    %esi
f01064f2:	5f                   	pop    %edi
f01064f3:	c9                   	leave  
f01064f4:	c3                   	ret    
f01064f5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01064f8:	39 f7                	cmp    %esi,%edi
f01064fa:	72 05                	jb     f0106501 <__umoddi3+0xf9>
f01064fc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f01064ff:	77 0c                	ja     f010650d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106501:	89 f2                	mov    %esi,%edx
f0106503:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106506:	29 c8                	sub    %ecx,%eax
f0106508:	19 fa                	sbb    %edi,%edx
f010650a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f010650d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106510:	83 c4 20             	add    $0x20,%esp
f0106513:	5e                   	pop    %esi
f0106514:	5f                   	pop    %edi
f0106515:	c9                   	leave  
f0106516:	c3                   	ret    
f0106517:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106518:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010651b:	89 c1                	mov    %eax,%ecx
f010651d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0106520:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0106523:	eb 84                	jmp    f01064a9 <__umoddi3+0xa1>
f0106525:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106528:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f010652b:	72 eb                	jb     f0106518 <__umoddi3+0x110>
f010652d:	89 f2                	mov    %esi,%edx
f010652f:	e9 75 ff ff ff       	jmp    f01064a9 <__umoddi3+0xa1>
