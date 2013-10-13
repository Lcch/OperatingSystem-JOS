
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
f0100015:	b8 00 50 12 00       	mov    $0x125000,%eax
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
f0100034:	bc 00 50 12 f0       	mov    $0xf0125000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 ee 00 00 00       	call   f010012c <i386_init>

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
f010005d:	b8 e4 73 12 f0       	mov    $0xf01273e4,%eax
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
f0100070:	83 3d 00 ef 2d f0 00 	cmpl   $0x0,0xf02def00
f0100077:	75 3a                	jne    f01000b3 <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100079:	89 35 00 ef 2d f0    	mov    %esi,0xf02def00

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010007f:	fa                   	cli    
f0100080:	fc                   	cld    

	va_start(ap, fmt);
f0100081:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f0100084:	e8 93 57 00 00       	call   f010581c <cpunum>
f0100089:	ff 75 0c             	pushl  0xc(%ebp)
f010008c:	ff 75 08             	pushl  0x8(%ebp)
f010008f:	50                   	push   %eax
f0100090:	68 c0 5e 10 f0       	push   $0xf0105ec0
f0100095:	e8 df 3b 00 00       	call   f0103c79 <cprintf>
	vcprintf(fmt, ap);
f010009a:	83 c4 08             	add    $0x8,%esp
f010009d:	53                   	push   %ebx
f010009e:	56                   	push   %esi
f010009f:	e8 af 3b 00 00       	call   f0103c53 <vcprintf>
	cprintf("\n");
f01000a4:	c7 04 24 2f 62 10 f0 	movl   $0xf010622f,(%esp)
f01000ab:	e8 c9 3b 00 00       	call   f0103c79 <cprintf>
	va_end(ap);
f01000b0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000b3:	83 ec 0c             	sub    $0xc,%esp
f01000b6:	6a 00                	push   $0x0
f01000b8:	e8 50 0f 00 00       	call   f010100d <monitor>
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
f01000c8:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000d2:	77 12                	ja     f01000e6 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000d4:	50                   	push   %eax
f01000d5:	68 e4 5e 10 f0       	push   $0xf0105ee4
f01000da:	6a 78                	push   $0x78
f01000dc:	68 2b 5f 10 f0       	push   $0xf0105f2b
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
f01000ee:	e8 29 57 00 00       	call   f010581c <cpunum>
f01000f3:	83 ec 08             	sub    $0x8,%esp
f01000f6:	50                   	push   %eax
f01000f7:	68 37 5f 10 f0       	push   $0xf0105f37
f01000fc:	e8 78 3b 00 00       	call   f0103c79 <cprintf>

	lapic_init();
f0100101:	e8 31 57 00 00       	call   f0105837 <lapic_init>
	env_init_percpu();
f0100106:	e8 d9 32 00 00       	call   f01033e4 <env_init_percpu>
	trap_init_percpu();
f010010b:	e8 80 3b 00 00       	call   f0103c90 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100110:	e8 07 57 00 00       	call   f010581c <cpunum>
f0100115:	6b d0 74             	imul   $0x74,%eax,%edx
f0100118:	81 c2 20 f0 2d f0    	add    $0xf02df020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010011e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100123:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100127:	83 c4 10             	add    $0x10,%esp
f010012a:	eb fe                	jmp    f010012a <mp_main+0x68>

f010012c <i386_init>:
	wrmsr(IA32_SYSENTER_EIP, (uint32_t)(sysenter_handler), 0);		// entry of sysenter
}

void
i386_init(void)
{
f010012c:	55                   	push   %ebp
f010012d:	89 e5                	mov    %esp,%ebp
f010012f:	53                   	push   %ebx
f0100130:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100133:	b8 08 00 32 f0       	mov    $0xf0320008,%eax
f0100138:	2d 4e d7 2d f0       	sub    $0xf02dd74e,%eax
f010013d:	50                   	push   %eax
f010013e:	6a 00                	push   $0x0
f0100140:	68 4e d7 2d f0       	push   $0xf02dd74e
f0100145:	e8 a3 50 00 00       	call   f01051ed <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010014a:	e8 30 05 00 00       	call   f010067f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010014f:	83 c4 08             	add    $0x8,%esp
f0100152:	68 ac 1a 00 00       	push   $0x1aac
f0100157:	68 4d 5f 10 f0       	push   $0xf0105f4d
f010015c:	e8 18 3b 00 00       	call   f0103c79 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100161:	e8 6d 17 00 00       	call   f01018d3 <mem_init>

	// MSRs init:
	msrs_init();
f0100166:	e8 d5 fe ff ff       	call   f0100040 <msrs_init>

    // Lab 3 user environment initialization functions
	env_init();
f010016b:	e8 9e 32 00 00       	call   f010340e <env_init>
    trap_init();
f0100170:	e8 78 3b 00 00       	call   f0103ced <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f0100175:	e8 b8 53 00 00       	call   f0105532 <mp_init>
	lapic_init();
f010017a:	e8 b8 56 00 00       	call   f0105837 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010017f:	e8 56 3a 00 00       	call   f0103bda <pic_init>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100184:	83 c4 10             	add    $0x10,%esp
f0100187:	83 3d 08 ef 2d f0 07 	cmpl   $0x7,0xf02def08
f010018e:	77 16                	ja     f01001a6 <i386_init+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100190:	68 00 70 00 00       	push   $0x7000
f0100195:	68 08 5f 10 f0       	push   $0xf0105f08
f010019a:	6a 61                	push   $0x61
f010019c:	68 2b 5f 10 f0       	push   $0xf0105f2b
f01001a1:	e8 c2 fe ff ff       	call   f0100068 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001a6:	83 ec 04             	sub    $0x4,%esp
f01001a9:	b8 6e 54 10 f0       	mov    $0xf010546e,%eax
f01001ae:	2d f4 53 10 f0       	sub    $0xf01053f4,%eax
f01001b3:	50                   	push   %eax
f01001b4:	68 f4 53 10 f0       	push   $0xf01053f4
f01001b9:	68 00 70 00 f0       	push   $0xf0007000
f01001be:	e8 74 50 00 00       	call   f0105237 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001c3:	a1 c4 f3 2d f0       	mov    0xf02df3c4,%eax
f01001c8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001cf:	29 c2                	sub    %eax,%edx
f01001d1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001d4:	8d 04 85 20 f0 2d f0 	lea    -0xfd20fe0(,%eax,4),%eax
f01001db:	83 c4 10             	add    $0x10,%esp
f01001de:	3d 20 f0 2d f0       	cmp    $0xf02df020,%eax
f01001e3:	0f 86 95 00 00 00    	jbe    f010027e <i386_init+0x152>
f01001e9:	bb 20 f0 2d f0       	mov    $0xf02df020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f01001ee:	e8 29 56 00 00       	call   f010581c <cpunum>
f01001f3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001fa:	29 c2                	sub    %eax,%edx
f01001fc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001ff:	8d 04 85 20 f0 2d f0 	lea    -0xfd20fe0(,%eax,4),%eax
f0100206:	39 c3                	cmp    %eax,%ebx
f0100208:	74 51                	je     f010025b <i386_init+0x12f>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010020a:	89 d8                	mov    %ebx,%eax
f010020c:	2d 20 f0 2d f0       	sub    $0xf02df020,%eax
f0100211:	c1 f8 02             	sar    $0x2,%eax
f0100214:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0100217:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f010021a:	89 d1                	mov    %edx,%ecx
f010021c:	c1 e1 05             	shl    $0x5,%ecx
f010021f:	29 d1                	sub    %edx,%ecx
f0100221:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100224:	89 d1                	mov    %edx,%ecx
f0100226:	c1 e1 0e             	shl    $0xe,%ecx
f0100229:	29 d1                	sub    %edx,%ecx
f010022b:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f010022e:	8d 44 90 01          	lea    0x1(%eax,%edx,4),%eax
f0100232:	c1 e0 0f             	shl    $0xf,%eax
f0100235:	05 00 00 2e f0       	add    $0xf02e0000,%eax
f010023a:	a3 04 ef 2d f0       	mov    %eax,0xf02def04
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010023f:	83 ec 08             	sub    $0x8,%esp
f0100242:	68 00 70 00 00       	push   $0x7000
f0100247:	0f b6 03             	movzbl (%ebx),%eax
f010024a:	50                   	push   %eax
f010024b:	e8 43 57 00 00       	call   f0105993 <lapic_startap>
f0100250:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100253:	8b 43 04             	mov    0x4(%ebx),%eax
f0100256:	83 f8 01             	cmp    $0x1,%eax
f0100259:	75 f8                	jne    f0100253 <i386_init+0x127>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010025b:	83 c3 74             	add    $0x74,%ebx
f010025e:	a1 c4 f3 2d f0       	mov    0xf02df3c4,%eax
f0100263:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010026a:	29 c2                	sub    %eax,%edx
f010026c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010026f:	8d 04 85 20 f0 2d f0 	lea    -0xfd20fe0(,%eax,4),%eax
f0100276:	39 c3                	cmp    %eax,%ebx
f0100278:	0f 82 70 ff ff ff    	jb     f01001ee <i386_init+0xc2>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f010027e:	83 ec 04             	sub    $0x4,%esp
f0100281:	6a 00                	push   $0x0
f0100283:	68 36 ea 00 00       	push   $0xea36
f0100288:	68 18 ed 2c f0       	push   $0xf02ced18
f010028d:	e8 c3 33 00 00       	call   f0103655 <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100292:	e8 24 42 00 00       	call   f01044bb <sched_yield>

f0100297 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100297:	55                   	push   %ebp
f0100298:	89 e5                	mov    %esp,%ebp
f010029a:	53                   	push   %ebx
f010029b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010029e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002a1:	ff 75 0c             	pushl  0xc(%ebp)
f01002a4:	ff 75 08             	pushl  0x8(%ebp)
f01002a7:	68 68 5f 10 f0       	push   $0xf0105f68
f01002ac:	e8 c8 39 00 00       	call   f0103c79 <cprintf>
	vcprintf(fmt, ap);
f01002b1:	83 c4 08             	add    $0x8,%esp
f01002b4:	53                   	push   %ebx
f01002b5:	ff 75 10             	pushl  0x10(%ebp)
f01002b8:	e8 96 39 00 00       	call   f0103c53 <vcprintf>
	cprintf("\n");
f01002bd:	c7 04 24 2f 62 10 f0 	movl   $0xf010622f,(%esp)
f01002c4:	e8 b0 39 00 00       	call   f0103c79 <cprintf>
	va_end(ap);
f01002c9:	83 c4 10             	add    $0x10,%esp
}
f01002cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002cf:	c9                   	leave  
f01002d0:	c3                   	ret    
f01002d1:	00 00                	add    %al,(%eax)
	...

f01002d4 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002d4:	55                   	push   %ebp
f01002d5:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d7:	ba 84 00 00 00       	mov    $0x84,%edx
f01002dc:	ec                   	in     (%dx),%al
f01002dd:	ec                   	in     (%dx),%al
f01002de:	ec                   	in     (%dx),%al
f01002df:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002e0:	c9                   	leave  
f01002e1:	c3                   	ret    

f01002e2 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002e2:	55                   	push   %ebp
f01002e3:	89 e5                	mov    %esp,%ebp
f01002e5:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002ea:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002eb:	a8 01                	test   $0x1,%al
f01002ed:	74 08                	je     f01002f7 <serial_proc_data+0x15>
f01002ef:	b2 f8                	mov    $0xf8,%dl
f01002f1:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002f2:	0f b6 c0             	movzbl %al,%eax
f01002f5:	eb 05                	jmp    f01002fc <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002fc:	c9                   	leave  
f01002fd:	c3                   	ret    

f01002fe <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002fe:	55                   	push   %ebp
f01002ff:	89 e5                	mov    %esp,%ebp
f0100301:	53                   	push   %ebx
f0100302:	83 ec 04             	sub    $0x4,%esp
f0100305:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100307:	eb 29                	jmp    f0100332 <cons_intr+0x34>
		if (c == 0)
f0100309:	85 c0                	test   %eax,%eax
f010030b:	74 25                	je     f0100332 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f010030d:	8b 15 24 e2 2d f0    	mov    0xf02de224,%edx
f0100313:	88 82 20 e0 2d f0    	mov    %al,-0xfd21fe0(%edx)
f0100319:	8d 42 01             	lea    0x1(%edx),%eax
f010031c:	a3 24 e2 2d f0       	mov    %eax,0xf02de224
		if (cons.wpos == CONSBUFSIZE)
f0100321:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100326:	75 0a                	jne    f0100332 <cons_intr+0x34>
			cons.wpos = 0;
f0100328:	c7 05 24 e2 2d f0 00 	movl   $0x0,0xf02de224
f010032f:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100332:	ff d3                	call   *%ebx
f0100334:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100337:	75 d0                	jne    f0100309 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100339:	83 c4 04             	add    $0x4,%esp
f010033c:	5b                   	pop    %ebx
f010033d:	c9                   	leave  
f010033e:	c3                   	ret    

f010033f <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010033f:	55                   	push   %ebp
f0100340:	89 e5                	mov    %esp,%ebp
f0100342:	57                   	push   %edi
f0100343:	56                   	push   %esi
f0100344:	53                   	push   %ebx
f0100345:	83 ec 0c             	sub    $0xc,%esp
f0100348:	89 c6                	mov    %eax,%esi
f010034a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010034f:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100350:	a8 20                	test   $0x20,%al
f0100352:	75 19                	jne    f010036d <cons_putc+0x2e>
f0100354:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100359:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010035e:	e8 71 ff ff ff       	call   f01002d4 <delay>
f0100363:	89 fa                	mov    %edi,%edx
f0100365:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100366:	a8 20                	test   $0x20,%al
f0100368:	75 03                	jne    f010036d <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010036a:	4b                   	dec    %ebx
f010036b:	75 f1                	jne    f010035e <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010036d:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100374:	89 f0                	mov    %esi,%eax
f0100376:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100377:	b2 79                	mov    $0x79,%dl
f0100379:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010037a:	84 c0                	test   %al,%al
f010037c:	78 1d                	js     f010039b <cons_putc+0x5c>
f010037e:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f0100383:	e8 4c ff ff ff       	call   f01002d4 <delay>
f0100388:	ba 79 03 00 00       	mov    $0x379,%edx
f010038d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010038e:	84 c0                	test   %al,%al
f0100390:	78 09                	js     f010039b <cons_putc+0x5c>
f0100392:	43                   	inc    %ebx
f0100393:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100399:	75 e8                	jne    f0100383 <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010039b:	ba 78 03 00 00       	mov    $0x378,%edx
f01003a0:	89 f8                	mov    %edi,%eax
f01003a2:	ee                   	out    %al,(%dx)
f01003a3:	b2 7a                	mov    $0x7a,%dl
f01003a5:	b0 0d                	mov    $0xd,%al
f01003a7:	ee                   	out    %al,(%dx)
f01003a8:	b0 08                	mov    $0x8,%al
f01003aa:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
    // set user_setcolor
    c |= (user_setcolor << 8);
f01003ab:	a1 00 e0 2d f0       	mov    0xf02de000,%eax
f01003b0:	c1 e0 08             	shl    $0x8,%eax
f01003b3:	09 c6                	or     %eax,%esi

	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003b5:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f01003bb:	75 06                	jne    f01003c3 <cons_putc+0x84>
		c |= 0x0700;
f01003bd:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f01003c3:	89 f0                	mov    %esi,%eax
f01003c5:	25 ff 00 00 00       	and    $0xff,%eax
f01003ca:	83 f8 09             	cmp    $0x9,%eax
f01003cd:	74 78                	je     f0100447 <cons_putc+0x108>
f01003cf:	83 f8 09             	cmp    $0x9,%eax
f01003d2:	7f 0b                	jg     f01003df <cons_putc+0xa0>
f01003d4:	83 f8 08             	cmp    $0x8,%eax
f01003d7:	0f 85 9e 00 00 00    	jne    f010047b <cons_putc+0x13c>
f01003dd:	eb 10                	jmp    f01003ef <cons_putc+0xb0>
f01003df:	83 f8 0a             	cmp    $0xa,%eax
f01003e2:	74 39                	je     f010041d <cons_putc+0xde>
f01003e4:	83 f8 0d             	cmp    $0xd,%eax
f01003e7:	0f 85 8e 00 00 00    	jne    f010047b <cons_putc+0x13c>
f01003ed:	eb 36                	jmp    f0100425 <cons_putc+0xe6>
	case '\b':
		if (crt_pos > 0) {
f01003ef:	66 a1 04 e0 2d f0    	mov    0xf02de004,%ax
f01003f5:	66 85 c0             	test   %ax,%ax
f01003f8:	0f 84 e0 00 00 00    	je     f01004de <cons_putc+0x19f>
			crt_pos--;
f01003fe:	48                   	dec    %eax
f01003ff:	66 a3 04 e0 2d f0    	mov    %ax,0xf02de004
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100405:	0f b7 c0             	movzwl %ax,%eax
f0100408:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f010040e:	83 ce 20             	or     $0x20,%esi
f0100411:	8b 15 08 e0 2d f0    	mov    0xf02de008,%edx
f0100417:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f010041b:	eb 78                	jmp    f0100495 <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010041d:	66 83 05 04 e0 2d f0 	addw   $0x50,0xf02de004
f0100424:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100425:	66 8b 0d 04 e0 2d f0 	mov    0xf02de004,%cx
f010042c:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100431:	89 c8                	mov    %ecx,%eax
f0100433:	ba 00 00 00 00       	mov    $0x0,%edx
f0100438:	66 f7 f3             	div    %bx
f010043b:	66 29 d1             	sub    %dx,%cx
f010043e:	66 89 0d 04 e0 2d f0 	mov    %cx,0xf02de004
f0100445:	eb 4e                	jmp    f0100495 <cons_putc+0x156>
		break;
	case '\t':
		cons_putc(' ');
f0100447:	b8 20 00 00 00       	mov    $0x20,%eax
f010044c:	e8 ee fe ff ff       	call   f010033f <cons_putc>
		cons_putc(' ');
f0100451:	b8 20 00 00 00       	mov    $0x20,%eax
f0100456:	e8 e4 fe ff ff       	call   f010033f <cons_putc>
		cons_putc(' ');
f010045b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100460:	e8 da fe ff ff       	call   f010033f <cons_putc>
		cons_putc(' ');
f0100465:	b8 20 00 00 00       	mov    $0x20,%eax
f010046a:	e8 d0 fe ff ff       	call   f010033f <cons_putc>
		cons_putc(' ');
f010046f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100474:	e8 c6 fe ff ff       	call   f010033f <cons_putc>
f0100479:	eb 1a                	jmp    f0100495 <cons_putc+0x156>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010047b:	66 a1 04 e0 2d f0    	mov    0xf02de004,%ax
f0100481:	0f b7 c8             	movzwl %ax,%ecx
f0100484:	8b 15 08 e0 2d f0    	mov    0xf02de008,%edx
f010048a:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f010048e:	40                   	inc    %eax
f010048f:	66 a3 04 e0 2d f0    	mov    %ax,0xf02de004
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f0100495:	66 81 3d 04 e0 2d f0 	cmpw   $0x7cf,0xf02de004
f010049c:	cf 07 
f010049e:	76 3e                	jbe    f01004de <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004a0:	a1 08 e0 2d f0       	mov    0xf02de008,%eax
f01004a5:	83 ec 04             	sub    $0x4,%esp
f01004a8:	68 00 0f 00 00       	push   $0xf00
f01004ad:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004b3:	52                   	push   %edx
f01004b4:	50                   	push   %eax
f01004b5:	e8 7d 4d 00 00       	call   f0105237 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004ba:	8b 15 08 e0 2d f0    	mov    0xf02de008,%edx
f01004c0:	83 c4 10             	add    $0x10,%esp
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004c3:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004c8:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004ce:	40                   	inc    %eax
f01004cf:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004d4:	75 f2                	jne    f01004c8 <cons_putc+0x189>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004d6:	66 83 2d 04 e0 2d f0 	subw   $0x50,0xf02de004
f01004dd:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004de:	8b 0d 0c e0 2d f0    	mov    0xf02de00c,%ecx
f01004e4:	b0 0e                	mov    $0xe,%al
f01004e6:	89 ca                	mov    %ecx,%edx
f01004e8:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004e9:	66 8b 35 04 e0 2d f0 	mov    0xf02de004,%si
f01004f0:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004f3:	89 f0                	mov    %esi,%eax
f01004f5:	66 c1 e8 08          	shr    $0x8,%ax
f01004f9:	89 da                	mov    %ebx,%edx
f01004fb:	ee                   	out    %al,(%dx)
f01004fc:	b0 0f                	mov    $0xf,%al
f01004fe:	89 ca                	mov    %ecx,%edx
f0100500:	ee                   	out    %al,(%dx)
f0100501:	89 f0                	mov    %esi,%eax
f0100503:	89 da                	mov    %ebx,%edx
f0100505:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100506:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100509:	5b                   	pop    %ebx
f010050a:	5e                   	pop    %esi
f010050b:	5f                   	pop    %edi
f010050c:	c9                   	leave  
f010050d:	c3                   	ret    

f010050e <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010050e:	55                   	push   %ebp
f010050f:	89 e5                	mov    %esp,%ebp
f0100511:	53                   	push   %ebx
f0100512:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100515:	ba 64 00 00 00       	mov    $0x64,%edx
f010051a:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010051b:	a8 01                	test   $0x1,%al
f010051d:	0f 84 dc 00 00 00    	je     f01005ff <kbd_proc_data+0xf1>
f0100523:	b2 60                	mov    $0x60,%dl
f0100525:	ec                   	in     (%dx),%al
f0100526:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100528:	3c e0                	cmp    $0xe0,%al
f010052a:	75 11                	jne    f010053d <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f010052c:	83 0d 28 e2 2d f0 40 	orl    $0x40,0xf02de228
		return 0;
f0100533:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100538:	e9 c7 00 00 00       	jmp    f0100604 <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f010053d:	84 c0                	test   %al,%al
f010053f:	79 33                	jns    f0100574 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100541:	8b 0d 28 e2 2d f0    	mov    0xf02de228,%ecx
f0100547:	f6 c1 40             	test   $0x40,%cl
f010054a:	75 05                	jne    f0100551 <kbd_proc_data+0x43>
f010054c:	88 c2                	mov    %al,%dl
f010054e:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100551:	0f b6 d2             	movzbl %dl,%edx
f0100554:	8a 82 c0 5f 10 f0    	mov    -0xfefa040(%edx),%al
f010055a:	83 c8 40             	or     $0x40,%eax
f010055d:	0f b6 c0             	movzbl %al,%eax
f0100560:	f7 d0                	not    %eax
f0100562:	21 c1                	and    %eax,%ecx
f0100564:	89 0d 28 e2 2d f0    	mov    %ecx,0xf02de228
		return 0;
f010056a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010056f:	e9 90 00 00 00       	jmp    f0100604 <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f0100574:	8b 0d 28 e2 2d f0    	mov    0xf02de228,%ecx
f010057a:	f6 c1 40             	test   $0x40,%cl
f010057d:	74 0e                	je     f010058d <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010057f:	88 c2                	mov    %al,%dl
f0100581:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100584:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100587:	89 0d 28 e2 2d f0    	mov    %ecx,0xf02de228
	}

	shift |= shiftcode[data];
f010058d:	0f b6 d2             	movzbl %dl,%edx
f0100590:	0f b6 82 c0 5f 10 f0 	movzbl -0xfefa040(%edx),%eax
f0100597:	0b 05 28 e2 2d f0    	or     0xf02de228,%eax
	shift ^= togglecode[data];
f010059d:	0f b6 8a c0 60 10 f0 	movzbl -0xfef9f40(%edx),%ecx
f01005a4:	31 c8                	xor    %ecx,%eax
f01005a6:	a3 28 e2 2d f0       	mov    %eax,0xf02de228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005ab:	89 c1                	mov    %eax,%ecx
f01005ad:	83 e1 03             	and    $0x3,%ecx
f01005b0:	8b 0c 8d c0 61 10 f0 	mov    -0xfef9e40(,%ecx,4),%ecx
f01005b7:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005bb:	a8 08                	test   $0x8,%al
f01005bd:	74 18                	je     f01005d7 <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f01005bf:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005c2:	83 fa 19             	cmp    $0x19,%edx
f01005c5:	77 05                	ja     f01005cc <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f01005c7:	83 eb 20             	sub    $0x20,%ebx
f01005ca:	eb 0b                	jmp    f01005d7 <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f01005cc:	8d 53 bf             	lea    -0x41(%ebx),%edx
f01005cf:	83 fa 19             	cmp    $0x19,%edx
f01005d2:	77 03                	ja     f01005d7 <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f01005d4:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005d7:	f7 d0                	not    %eax
f01005d9:	a8 06                	test   $0x6,%al
f01005db:	75 27                	jne    f0100604 <kbd_proc_data+0xf6>
f01005dd:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005e3:	75 1f                	jne    f0100604 <kbd_proc_data+0xf6>
		cprintf("Rebooting!\n");
f01005e5:	83 ec 0c             	sub    $0xc,%esp
f01005e8:	68 82 5f 10 f0       	push   $0xf0105f82
f01005ed:	e8 87 36 00 00       	call   f0103c79 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005f2:	ba 92 00 00 00       	mov    $0x92,%edx
f01005f7:	b0 03                	mov    $0x3,%al
f01005f9:	ee                   	out    %al,(%dx)
f01005fa:	83 c4 10             	add    $0x10,%esp
f01005fd:	eb 05                	jmp    f0100604 <kbd_proc_data+0xf6>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01005ff:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100604:	89 d8                	mov    %ebx,%eax
f0100606:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100609:	c9                   	leave  
f010060a:	c3                   	ret    

f010060b <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010060b:	55                   	push   %ebp
f010060c:	89 e5                	mov    %esp,%ebp
f010060e:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100611:	80 3d 10 e0 2d f0 00 	cmpb   $0x0,0xf02de010
f0100618:	74 0a                	je     f0100624 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010061a:	b8 e2 02 10 f0       	mov    $0xf01002e2,%eax
f010061f:	e8 da fc ff ff       	call   f01002fe <cons_intr>
}
f0100624:	c9                   	leave  
f0100625:	c3                   	ret    

f0100626 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100626:	55                   	push   %ebp
f0100627:	89 e5                	mov    %esp,%ebp
f0100629:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010062c:	b8 0e 05 10 f0       	mov    $0xf010050e,%eax
f0100631:	e8 c8 fc ff ff       	call   f01002fe <cons_intr>
}
f0100636:	c9                   	leave  
f0100637:	c3                   	ret    

f0100638 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100638:	55                   	push   %ebp
f0100639:	89 e5                	mov    %esp,%ebp
f010063b:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010063e:	e8 c8 ff ff ff       	call   f010060b <serial_intr>
	kbd_intr();
f0100643:	e8 de ff ff ff       	call   f0100626 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100648:	8b 15 20 e2 2d f0    	mov    0xf02de220,%edx
f010064e:	3b 15 24 e2 2d f0    	cmp    0xf02de224,%edx
f0100654:	74 22                	je     f0100678 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f0100656:	0f b6 82 20 e0 2d f0 	movzbl -0xfd21fe0(%edx),%eax
f010065d:	42                   	inc    %edx
f010065e:	89 15 20 e2 2d f0    	mov    %edx,0xf02de220
		if (cons.rpos == CONSBUFSIZE)
f0100664:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010066a:	75 11                	jne    f010067d <cons_getc+0x45>
			cons.rpos = 0;
f010066c:	c7 05 20 e2 2d f0 00 	movl   $0x0,0xf02de220
f0100673:	00 00 00 
f0100676:	eb 05                	jmp    f010067d <cons_getc+0x45>
		return c;
	}
	return 0;
f0100678:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010067d:	c9                   	leave  
f010067e:	c3                   	ret    

f010067f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010067f:	55                   	push   %ebp
f0100680:	89 e5                	mov    %esp,%ebp
f0100682:	57                   	push   %edi
f0100683:	56                   	push   %esi
f0100684:	53                   	push   %ebx
f0100685:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100688:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010068f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100696:	5a a5 
	if (*cp != 0xA55A) {
f0100698:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010069e:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006a2:	74 11                	je     f01006b5 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006a4:	c7 05 0c e0 2d f0 b4 	movl   $0x3b4,0xf02de00c
f01006ab:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006ae:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006b3:	eb 16                	jmp    f01006cb <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006b5:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006bc:	c7 05 0c e0 2d f0 d4 	movl   $0x3d4,0xf02de00c
f01006c3:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006c6:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006cb:	8b 0d 0c e0 2d f0    	mov    0xf02de00c,%ecx
f01006d1:	b0 0e                	mov    $0xe,%al
f01006d3:	89 ca                	mov    %ecx,%edx
f01006d5:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006d6:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d9:	89 da                	mov    %ebx,%edx
f01006db:	ec                   	in     (%dx),%al
f01006dc:	0f b6 f8             	movzbl %al,%edi
f01006df:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e2:	b0 0f                	mov    $0xf,%al
f01006e4:	89 ca                	mov    %ecx,%edx
f01006e6:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006e7:	89 da                	mov    %ebx,%edx
f01006e9:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006ea:	89 35 08 e0 2d f0    	mov    %esi,0xf02de008

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006f0:	0f b6 d8             	movzbl %al,%ebx
f01006f3:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006f5:	66 89 3d 04 e0 2d f0 	mov    %di,0xf02de004

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f01006fc:	e8 25 ff ff ff       	call   f0100626 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100701:	83 ec 0c             	sub    $0xc,%esp
f0100704:	0f b7 05 70 73 12 f0 	movzwl 0xf0127370,%eax
f010070b:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100710:	50                   	push   %eax
f0100711:	e8 4a 34 00 00       	call   f0103b60 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100716:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010071b:	b0 00                	mov    $0x0,%al
f010071d:	89 da                	mov    %ebx,%edx
f010071f:	ee                   	out    %al,(%dx)
f0100720:	b2 fb                	mov    $0xfb,%dl
f0100722:	b0 80                	mov    $0x80,%al
f0100724:	ee                   	out    %al,(%dx)
f0100725:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010072a:	b0 0c                	mov    $0xc,%al
f010072c:	89 ca                	mov    %ecx,%edx
f010072e:	ee                   	out    %al,(%dx)
f010072f:	b2 f9                	mov    $0xf9,%dl
f0100731:	b0 00                	mov    $0x0,%al
f0100733:	ee                   	out    %al,(%dx)
f0100734:	b2 fb                	mov    $0xfb,%dl
f0100736:	b0 03                	mov    $0x3,%al
f0100738:	ee                   	out    %al,(%dx)
f0100739:	b2 fc                	mov    $0xfc,%dl
f010073b:	b0 00                	mov    $0x0,%al
f010073d:	ee                   	out    %al,(%dx)
f010073e:	b2 f9                	mov    $0xf9,%dl
f0100740:	b0 01                	mov    $0x1,%al
f0100742:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100743:	b2 fd                	mov    $0xfd,%dl
f0100745:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100746:	83 c4 10             	add    $0x10,%esp
f0100749:	3c ff                	cmp    $0xff,%al
f010074b:	0f 95 45 e7          	setne  -0x19(%ebp)
f010074f:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100752:	a2 10 e0 2d f0       	mov    %al,0xf02de010
f0100757:	89 da                	mov    %ebx,%edx
f0100759:	ec                   	in     (%dx),%al
f010075a:	89 ca                	mov    %ecx,%edx
f010075c:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010075d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100761:	75 10                	jne    f0100773 <cons_init+0xf4>
		cprintf("Serial port does not exist!\n");
f0100763:	83 ec 0c             	sub    $0xc,%esp
f0100766:	68 8e 5f 10 f0       	push   $0xf0105f8e
f010076b:	e8 09 35 00 00       	call   f0103c79 <cprintf>
f0100770:	83 c4 10             	add    $0x10,%esp
}
f0100773:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100776:	5b                   	pop    %ebx
f0100777:	5e                   	pop    %esi
f0100778:	5f                   	pop    %edi
f0100779:	c9                   	leave  
f010077a:	c3                   	ret    

f010077b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010077b:	55                   	push   %ebp
f010077c:	89 e5                	mov    %esp,%ebp
f010077e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100781:	8b 45 08             	mov    0x8(%ebp),%eax
f0100784:	e8 b6 fb ff ff       	call   f010033f <cons_putc>
}
f0100789:	c9                   	leave  
f010078a:	c3                   	ret    

f010078b <getchar>:

int
getchar(void)
{
f010078b:	55                   	push   %ebp
f010078c:	89 e5                	mov    %esp,%ebp
f010078e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100791:	e8 a2 fe ff ff       	call   f0100638 <cons_getc>
f0100796:	85 c0                	test   %eax,%eax
f0100798:	74 f7                	je     f0100791 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010079a:	c9                   	leave  
f010079b:	c3                   	ret    

f010079c <iscons>:

int
iscons(int fdnum)
{
f010079c:	55                   	push   %ebp
f010079d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010079f:	b8 01 00 00 00       	mov    $0x1,%eax
f01007a4:	c9                   	leave  
f01007a5:	c3                   	ret    
	...

f01007a8 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007a8:	55                   	push   %ebp
f01007a9:	89 e5                	mov    %esp,%ebp
f01007ab:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007ae:	68 d0 61 10 f0       	push   $0xf01061d0
f01007b3:	e8 c1 34 00 00       	call   f0103c79 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007b8:	83 c4 08             	add    $0x8,%esp
f01007bb:	68 0c 00 10 00       	push   $0x10000c
f01007c0:	68 fc 63 10 f0       	push   $0xf01063fc
f01007c5:	e8 af 34 00 00       	call   f0103c79 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007ca:	83 c4 0c             	add    $0xc,%esp
f01007cd:	68 0c 00 10 00       	push   $0x10000c
f01007d2:	68 0c 00 10 f0       	push   $0xf010000c
f01007d7:	68 24 64 10 f0       	push   $0xf0106424
f01007dc:	e8 98 34 00 00       	call   f0103c79 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007e1:	83 c4 0c             	add    $0xc,%esp
f01007e4:	68 bc 5e 10 00       	push   $0x105ebc
f01007e9:	68 bc 5e 10 f0       	push   $0xf0105ebc
f01007ee:	68 48 64 10 f0       	push   $0xf0106448
f01007f3:	e8 81 34 00 00       	call   f0103c79 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007f8:	83 c4 0c             	add    $0xc,%esp
f01007fb:	68 4e d7 2d 00       	push   $0x2dd74e
f0100800:	68 4e d7 2d f0       	push   $0xf02dd74e
f0100805:	68 6c 64 10 f0       	push   $0xf010646c
f010080a:	e8 6a 34 00 00       	call   f0103c79 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010080f:	83 c4 0c             	add    $0xc,%esp
f0100812:	68 08 00 32 00       	push   $0x320008
f0100817:	68 08 00 32 f0       	push   $0xf0320008
f010081c:	68 90 64 10 f0       	push   $0xf0106490
f0100821:	e8 53 34 00 00       	call   f0103c79 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100826:	b8 07 04 32 f0       	mov    $0xf0320407,%eax
f010082b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100830:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100833:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100838:	89 c2                	mov    %eax,%edx
f010083a:	85 c0                	test   %eax,%eax
f010083c:	79 06                	jns    f0100844 <mon_kerninfo+0x9c>
f010083e:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100844:	c1 fa 0a             	sar    $0xa,%edx
f0100847:	52                   	push   %edx
f0100848:	68 b4 64 10 f0       	push   $0xf01064b4
f010084d:	e8 27 34 00 00       	call   f0103c79 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100852:	b8 00 00 00 00       	mov    $0x0,%eax
f0100857:	c9                   	leave  
f0100858:	c3                   	ret    

f0100859 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100859:	55                   	push   %ebp
f010085a:	89 e5                	mov    %esp,%ebp
f010085c:	53                   	push   %ebx
f010085d:	83 ec 04             	sub    $0x4,%esp
f0100860:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100865:	83 ec 04             	sub    $0x4,%esp
f0100868:	ff b3 44 69 10 f0    	pushl  -0xfef96bc(%ebx)
f010086e:	ff b3 40 69 10 f0    	pushl  -0xfef96c0(%ebx)
f0100874:	68 e9 61 10 f0       	push   $0xf01061e9
f0100879:	e8 fb 33 00 00       	call   f0103c79 <cprintf>
f010087e:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100881:	83 c4 10             	add    $0x10,%esp
f0100884:	83 fb 6c             	cmp    $0x6c,%ebx
f0100887:	75 dc                	jne    f0100865 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100889:	b8 00 00 00 00       	mov    $0x0,%eax
f010088e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100891:	c9                   	leave  
f0100892:	c3                   	ret    

f0100893 <mon_si>:
    return 0;
}

int 
mon_si(int argc, char **argv, struct Trapframe *tf)
{
f0100893:	55                   	push   %ebp
f0100894:	89 e5                	mov    %esp,%ebp
f0100896:	83 ec 08             	sub    $0x8,%esp
f0100899:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f010089c:	85 c0                	test   %eax,%eax
f010089e:	75 14                	jne    f01008b4 <mon_si+0x21>
        cprintf("Error: you only can use si in breakpoint.\n");
f01008a0:	83 ec 0c             	sub    $0xc,%esp
f01008a3:	68 e0 64 10 f0       	push   $0xf01064e0
f01008a8:	e8 cc 33 00 00       	call   f0103c79 <cprintf>

    cprintf("tfno: %u\n", tf->tf_trapno);
    env_run(curenv);
    panic("mon_si : env_run return");
    return 0;
}
f01008ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01008b2:	c9                   	leave  
f01008b3:	c3                   	ret    
        cprintf("Error: you only can use si in breakpoint.\n");
        return -1;
    }

    // next step also cause debug interrupt
    tf->tf_eflags |= FL_TF;
f01008b4:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)

    cprintf("tfno: %u\n", tf->tf_trapno);
f01008bb:	83 ec 08             	sub    $0x8,%esp
f01008be:	ff 70 28             	pushl  0x28(%eax)
f01008c1:	68 f2 61 10 f0       	push   $0xf01061f2
f01008c6:	e8 ae 33 00 00       	call   f0103c79 <cprintf>
    env_run(curenv);
f01008cb:	e8 4c 4f 00 00       	call   f010581c <cpunum>
f01008d0:	83 c4 04             	add    $0x4,%esp
f01008d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01008d6:	ff b0 28 f0 2d f0    	pushl  -0xfd20fd8(%eax)
f01008dc:	e8 43 31 00 00       	call   f0103a24 <env_run>

f01008e1 <mon_continue>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

int 
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
f01008e1:	55                   	push   %ebp
f01008e2:	89 e5                	mov    %esp,%ebp
f01008e4:	83 ec 08             	sub    $0x8,%esp
f01008e7:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f01008ea:	85 c0                	test   %eax,%eax
f01008ec:	75 14                	jne    f0100902 <mon_continue+0x21>
        cprintf("Error: you only can use continue in breakpoint.\n");
f01008ee:	83 ec 0c             	sub    $0xc,%esp
f01008f1:	68 0c 65 10 f0       	push   $0xf010650c
f01008f6:	e8 7e 33 00 00       	call   f0103c79 <cprintf>
    }
    tf->tf_eflags &= (~FL_TF);
    env_run(curenv);    // usually it won't return;
    panic("mon_continue : env_run return");
    return 0;
}
f01008fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100900:	c9                   	leave  
f0100901:	c3                   	ret    
{
    if (tf == NULL) {
        cprintf("Error: you only can use continue in breakpoint.\n");
        return -1;
    }
    tf->tf_eflags &= (~FL_TF);
f0100902:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
    env_run(curenv);    // usually it won't return;
f0100909:	e8 0e 4f 00 00       	call   f010581c <cpunum>
f010090e:	83 ec 0c             	sub    $0xc,%esp
f0100911:	6b c0 74             	imul   $0x74,%eax,%eax
f0100914:	ff b0 28 f0 2d f0    	pushl  -0xfd20fd8(%eax)
f010091a:	e8 05 31 00 00       	call   f0103a24 <env_run>

f010091f <mon_showmappings>:
    return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f010091f:	55                   	push   %ebp
f0100920:	89 e5                	mov    %esp,%ebp
f0100922:	57                   	push   %edi
f0100923:	56                   	push   %esi
f0100924:	53                   	push   %ebx
f0100925:	83 ec 0c             	sub    $0xc,%esp
f0100928:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 3) {
f010092b:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f010092f:	74 21                	je     f0100952 <mon_showmappings+0x33>
        cprintf("Command should be: showmappings [addr1] [addr2]\n");
f0100931:	83 ec 0c             	sub    $0xc,%esp
f0100934:	68 40 65 10 f0       	push   $0xf0106540
f0100939:	e8 3b 33 00 00       	call   f0103c79 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f010093e:	c7 04 24 74 65 10 f0 	movl   $0xf0106574,(%esp)
f0100945:	e8 2f 33 00 00       	call   f0103c79 <cprintf>
f010094a:	83 c4 10             	add    $0x10,%esp
f010094d:	e9 1a 01 00 00       	jmp    f0100a6c <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f0100952:	83 ec 04             	sub    $0x4,%esp
f0100955:	6a 00                	push   $0x0
f0100957:	6a 00                	push   $0x0
f0100959:	ff 76 04             	pushl  0x4(%esi)
f010095c:	e8 c5 49 00 00       	call   f0105326 <strtol>
f0100961:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f0100963:	83 c4 0c             	add    $0xc,%esp
f0100966:	6a 00                	push   $0x0
f0100968:	6a 00                	push   $0x0
f010096a:	ff 76 08             	pushl  0x8(%esi)
f010096d:	e8 b4 49 00 00       	call   f0105326 <strtol>
        if (laddr > haddr) {
f0100972:	83 c4 10             	add    $0x10,%esp
f0100975:	39 c3                	cmp    %eax,%ebx
f0100977:	76 01                	jbe    f010097a <mon_showmappings+0x5b>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100979:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, PGSIZE);
f010097a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        haddr = ROUNDUP(haddr, PGSIZE);
f0100980:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f0100986:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
f010098c:	83 ec 04             	sub    $0x4,%esp
f010098f:	57                   	push   %edi
f0100990:	53                   	push   %ebx
f0100991:	68 fc 61 10 f0       	push   $0xf01061fc
f0100996:	e8 de 32 00 00       	call   f0103c79 <cprintf>
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f010099b:	83 c4 10             	add    $0x10,%esp
f010099e:	39 fb                	cmp    %edi,%ebx
f01009a0:	75 07                	jne    f01009a9 <mon_showmappings+0x8a>
f01009a2:	e9 c5 00 00 00       	jmp    f0100a6c <mon_showmappings+0x14d>
f01009a7:	89 f3                	mov    %esi,%ebx
            cprintf("[ 0x%08x, 0x%08x ) -> ", now, now + PGSIZE); 
f01009a9:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
f01009af:	83 ec 04             	sub    $0x4,%esp
f01009b2:	56                   	push   %esi
f01009b3:	53                   	push   %ebx
f01009b4:	68 0d 62 10 f0       	push   $0xf010620d
f01009b9:	e8 bb 32 00 00       	call   f0103c79 <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f01009be:	83 c4 0c             	add    $0xc,%esp
f01009c1:	6a 00                	push   $0x0
f01009c3:	53                   	push   %ebx
f01009c4:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f01009ca:	e8 9d 0c 00 00       	call   f010166c <pgdir_walk>
f01009cf:	89 c3                	mov    %eax,%ebx
            if (pte == 0 || (*pte & PTE_P) == 0) {
f01009d1:	83 c4 10             	add    $0x10,%esp
f01009d4:	85 c0                	test   %eax,%eax
f01009d6:	74 06                	je     f01009de <mon_showmappings+0xbf>
f01009d8:	8b 00                	mov    (%eax),%eax
f01009da:	a8 01                	test   $0x1,%al
f01009dc:	75 12                	jne    f01009f0 <mon_showmappings+0xd1>
                cprintf(" no mapped \n");
f01009de:	83 ec 0c             	sub    $0xc,%esp
f01009e1:	68 24 62 10 f0       	push   $0xf0106224
f01009e6:	e8 8e 32 00 00       	call   f0103c79 <cprintf>
f01009eb:	83 c4 10             	add    $0x10,%esp
f01009ee:	eb 74                	jmp    f0100a64 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f01009f0:	83 ec 08             	sub    $0x8,%esp
f01009f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009f8:	50                   	push   %eax
f01009f9:	68 31 62 10 f0       	push   $0xf0106231
f01009fe:	e8 76 32 00 00       	call   f0103c79 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f0100a03:	83 c4 10             	add    $0x10,%esp
f0100a06:	f6 03 04             	testb  $0x4,(%ebx)
f0100a09:	74 12                	je     f0100a1d <mon_showmappings+0xfe>
f0100a0b:	83 ec 0c             	sub    $0xc,%esp
f0100a0e:	68 39 62 10 f0       	push   $0xf0106239
f0100a13:	e8 61 32 00 00       	call   f0103c79 <cprintf>
f0100a18:	83 c4 10             	add    $0x10,%esp
f0100a1b:	eb 10                	jmp    f0100a2d <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f0100a1d:	83 ec 0c             	sub    $0xc,%esp
f0100a20:	68 46 62 10 f0       	push   $0xf0106246
f0100a25:	e8 4f 32 00 00       	call   f0103c79 <cprintf>
f0100a2a:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f0100a2d:	f6 03 02             	testb  $0x2,(%ebx)
f0100a30:	74 12                	je     f0100a44 <mon_showmappings+0x125>
f0100a32:	83 ec 0c             	sub    $0xc,%esp
f0100a35:	68 53 62 10 f0       	push   $0xf0106253
f0100a3a:	e8 3a 32 00 00       	call   f0103c79 <cprintf>
f0100a3f:	83 c4 10             	add    $0x10,%esp
f0100a42:	eb 10                	jmp    f0100a54 <mon_showmappings+0x135>
                else cprintf(" R ");
f0100a44:	83 ec 0c             	sub    $0xc,%esp
f0100a47:	68 58 62 10 f0       	push   $0xf0106258
f0100a4c:	e8 28 32 00 00       	call   f0103c79 <cprintf>
f0100a51:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f0100a54:	83 ec 0c             	sub    $0xc,%esp
f0100a57:	68 2f 62 10 f0       	push   $0xf010622f
f0100a5c:	e8 18 32 00 00       	call   f0103c79 <cprintf>
f0100a61:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDUP(haddr, PGSIZE);
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f0100a64:	39 f7                	cmp    %esi,%edi
f0100a66:	0f 85 3b ff ff ff    	jne    f01009a7 <mon_showmappings+0x88>
                cprintf("\n");
            }
        }
    }
    return 0;
}
f0100a6c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a71:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a74:	5b                   	pop    %ebx
f0100a75:	5e                   	pop    %esi
f0100a76:	5f                   	pop    %edi
f0100a77:	c9                   	leave  
f0100a78:	c3                   	ret    

f0100a79 <mon_setpermission>:
    return 0;
}

int
mon_setpermission(int argc, char **argv, struct Trapframe *tf)
{
f0100a79:	55                   	push   %ebp
f0100a7a:	89 e5                	mov    %esp,%ebp
f0100a7c:	57                   	push   %edi
f0100a7d:	56                   	push   %esi
f0100a7e:	53                   	push   %ebx
f0100a7f:	83 ec 0c             	sub    $0xc,%esp
f0100a82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 5) { 
f0100a85:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f0100a89:	74 21                	je     f0100aac <mon_setpermission+0x33>
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
f0100a8b:	83 ec 0c             	sub    $0xc,%esp
f0100a8e:	68 9c 65 10 f0       	push   $0xf010659c
f0100a93:	e8 e1 31 00 00       	call   f0103c79 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f0100a98:	c7 04 24 ec 65 10 f0 	movl   $0xf01065ec,(%esp)
f0100a9f:	e8 d5 31 00 00       	call   f0103c79 <cprintf>
f0100aa4:	83 c4 10             	add    $0x10,%esp
f0100aa7:	e9 a5 01 00 00       	jmp    f0100c51 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f0100aac:	83 ec 04             	sub    $0x4,%esp
f0100aaf:	6a 00                	push   $0x0
f0100ab1:	6a 00                	push   $0x0
f0100ab3:	ff 73 04             	pushl  0x4(%ebx)
f0100ab6:	e8 6b 48 00 00       	call   f0105326 <strtol>
        uint32_t perm = 0;
        if (argv[2][0] == '1') perm |= PTE_W;
f0100abb:	8b 53 08             	mov    0x8(%ebx),%edx
f0100abe:	83 c4 10             	add    $0x10,%esp
    if (argc != 5) { 
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
        cprintf("Example: setpermissions 0x0 1 0 1\n");
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
        uint32_t perm = 0;
f0100ac1:	80 3a 31             	cmpb   $0x31,(%edx)
f0100ac4:	0f 94 c2             	sete   %dl
f0100ac7:	0f b6 d2             	movzbl %dl,%edx
f0100aca:	89 d6                	mov    %edx,%esi
f0100acc:	d1 e6                	shl    %esi
        if (argv[2][0] == '1') perm |= PTE_W;
        if (argv[3][0] == '1') perm |= PTE_U;
f0100ace:	8b 53 0c             	mov    0xc(%ebx),%edx
f0100ad1:	80 3a 31             	cmpb   $0x31,(%edx)
f0100ad4:	75 03                	jne    f0100ad9 <mon_setpermission+0x60>
f0100ad6:	83 ce 04             	or     $0x4,%esi
        if (argv[4][0] == '1') perm |= PTE_P;
f0100ad9:	8b 53 10             	mov    0x10(%ebx),%edx
f0100adc:	80 3a 31             	cmpb   $0x31,(%edx)
f0100adf:	75 03                	jne    f0100ae4 <mon_setpermission+0x6b>
f0100ae1:	83 ce 01             	or     $0x1,%esi
        addr = ROUNDUP(addr, PGSIZE);
f0100ae4:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f0100aea:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
f0100af0:	83 ec 04             	sub    $0x4,%esp
f0100af3:	6a 00                	push   $0x0
f0100af5:	57                   	push   %edi
f0100af6:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0100afc:	e8 6b 0b 00 00       	call   f010166c <pgdir_walk>
f0100b01:	89 c3                	mov    %eax,%ebx
        if (pte != NULL) {
f0100b03:	83 c4 10             	add    $0x10,%esp
f0100b06:	85 c0                	test   %eax,%eax
f0100b08:	0f 84 33 01 00 00    	je     f0100c41 <mon_setpermission+0x1c8>
            cprintf("0x%08x -> pa: 0x%08x\n old_perm: ", addr, PTE_ADDR(*pte));
f0100b0e:	83 ec 04             	sub    $0x4,%esp
f0100b11:	8b 00                	mov    (%eax),%eax
f0100b13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b18:	50                   	push   %eax
f0100b19:	57                   	push   %edi
f0100b1a:	68 10 66 10 f0       	push   $0xf0106610
f0100b1f:	e8 55 31 00 00       	call   f0103c79 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100b24:	83 c4 10             	add    $0x10,%esp
f0100b27:	f6 03 02             	testb  $0x2,(%ebx)
f0100b2a:	74 12                	je     f0100b3e <mon_setpermission+0xc5>
f0100b2c:	83 ec 0c             	sub    $0xc,%esp
f0100b2f:	68 5c 62 10 f0       	push   $0xf010625c
f0100b34:	e8 40 31 00 00       	call   f0103c79 <cprintf>
f0100b39:	83 c4 10             	add    $0x10,%esp
f0100b3c:	eb 10                	jmp    f0100b4e <mon_setpermission+0xd5>
f0100b3e:	83 ec 0c             	sub    $0xc,%esp
f0100b41:	68 5f 62 10 f0       	push   $0xf010625f
f0100b46:	e8 2e 31 00 00       	call   f0103c79 <cprintf>
f0100b4b:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100b4e:	f6 03 04             	testb  $0x4,(%ebx)
f0100b51:	74 12                	je     f0100b65 <mon_setpermission+0xec>
f0100b53:	83 ec 0c             	sub    $0xc,%esp
f0100b56:	68 c3 74 10 f0       	push   $0xf01074c3
f0100b5b:	e8 19 31 00 00       	call   f0103c79 <cprintf>
f0100b60:	83 c4 10             	add    $0x10,%esp
f0100b63:	eb 10                	jmp    f0100b75 <mon_setpermission+0xfc>
f0100b65:	83 ec 0c             	sub    $0xc,%esp
f0100b68:	68 22 79 10 f0       	push   $0xf0107922
f0100b6d:	e8 07 31 00 00       	call   f0103c79 <cprintf>
f0100b72:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100b75:	f6 03 01             	testb  $0x1,(%ebx)
f0100b78:	74 12                	je     f0100b8c <mon_setpermission+0x113>
f0100b7a:	83 ec 0c             	sub    $0xc,%esp
f0100b7d:	68 f9 7e 10 f0       	push   $0xf0107ef9
f0100b82:	e8 f2 30 00 00       	call   f0103c79 <cprintf>
f0100b87:	83 c4 10             	add    $0x10,%esp
f0100b8a:	eb 10                	jmp    f0100b9c <mon_setpermission+0x123>
f0100b8c:	83 ec 0c             	sub    $0xc,%esp
f0100b8f:	68 60 62 10 f0       	push   $0xf0106260
f0100b94:	e8 e0 30 00 00       	call   f0103c79 <cprintf>
f0100b99:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f0100b9c:	83 ec 0c             	sub    $0xc,%esp
f0100b9f:	68 62 62 10 f0       	push   $0xf0106262
f0100ba4:	e8 d0 30 00 00       	call   f0103c79 <cprintf>
            *pte = PTE_ADDR(*pte) | perm;     
f0100ba9:	8b 03                	mov    (%ebx),%eax
f0100bab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bb0:	09 c6                	or     %eax,%esi
f0100bb2:	89 33                	mov    %esi,(%ebx)
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100bb4:	83 c4 10             	add    $0x10,%esp
f0100bb7:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0100bbd:	74 12                	je     f0100bd1 <mon_setpermission+0x158>
f0100bbf:	83 ec 0c             	sub    $0xc,%esp
f0100bc2:	68 5c 62 10 f0       	push   $0xf010625c
f0100bc7:	e8 ad 30 00 00       	call   f0103c79 <cprintf>
f0100bcc:	83 c4 10             	add    $0x10,%esp
f0100bcf:	eb 10                	jmp    f0100be1 <mon_setpermission+0x168>
f0100bd1:	83 ec 0c             	sub    $0xc,%esp
f0100bd4:	68 5f 62 10 f0       	push   $0xf010625f
f0100bd9:	e8 9b 30 00 00       	call   f0103c79 <cprintf>
f0100bde:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100be1:	f6 03 04             	testb  $0x4,(%ebx)
f0100be4:	74 12                	je     f0100bf8 <mon_setpermission+0x17f>
f0100be6:	83 ec 0c             	sub    $0xc,%esp
f0100be9:	68 c3 74 10 f0       	push   $0xf01074c3
f0100bee:	e8 86 30 00 00       	call   f0103c79 <cprintf>
f0100bf3:	83 c4 10             	add    $0x10,%esp
f0100bf6:	eb 10                	jmp    f0100c08 <mon_setpermission+0x18f>
f0100bf8:	83 ec 0c             	sub    $0xc,%esp
f0100bfb:	68 22 79 10 f0       	push   $0xf0107922
f0100c00:	e8 74 30 00 00       	call   f0103c79 <cprintf>
f0100c05:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100c08:	f6 03 01             	testb  $0x1,(%ebx)
f0100c0b:	74 12                	je     f0100c1f <mon_setpermission+0x1a6>
f0100c0d:	83 ec 0c             	sub    $0xc,%esp
f0100c10:	68 f9 7e 10 f0       	push   $0xf0107ef9
f0100c15:	e8 5f 30 00 00       	call   f0103c79 <cprintf>
f0100c1a:	83 c4 10             	add    $0x10,%esp
f0100c1d:	eb 10                	jmp    f0100c2f <mon_setpermission+0x1b6>
f0100c1f:	83 ec 0c             	sub    $0xc,%esp
f0100c22:	68 60 62 10 f0       	push   $0xf0106260
f0100c27:	e8 4d 30 00 00       	call   f0103c79 <cprintf>
f0100c2c:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100c2f:	83 ec 0c             	sub    $0xc,%esp
f0100c32:	68 2f 62 10 f0       	push   $0xf010622f
f0100c37:	e8 3d 30 00 00       	call   f0103c79 <cprintf>
f0100c3c:	83 c4 10             	add    $0x10,%esp
f0100c3f:	eb 10                	jmp    f0100c51 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100c41:	83 ec 0c             	sub    $0xc,%esp
f0100c44:	68 24 62 10 f0       	push   $0xf0106224
f0100c49:	e8 2b 30 00 00       	call   f0103c79 <cprintf>
f0100c4e:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100c51:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c59:	5b                   	pop    %ebx
f0100c5a:	5e                   	pop    %esi
f0100c5b:	5f                   	pop    %edi
f0100c5c:	c9                   	leave  
f0100c5d:	c3                   	ret    

f0100c5e <mon_setcolor>:
    return 0;
}

int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f0100c5e:	55                   	push   %ebp
f0100c5f:	89 e5                	mov    %esp,%ebp
f0100c61:	56                   	push   %esi
f0100c62:	53                   	push   %ebx
f0100c63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f0100c66:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100c6a:	74 66                	je     f0100cd2 <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f0100c6c:	83 ec 0c             	sub    $0xc,%esp
f0100c6f:	68 34 66 10 f0       	push   $0xf0106634
f0100c74:	e8 00 30 00 00       	call   f0103c79 <cprintf>
        cprintf("num show the color attribute. \n");
f0100c79:	c7 04 24 64 66 10 f0 	movl   $0xf0106664,(%esp)
f0100c80:	e8 f4 2f 00 00       	call   f0103c79 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100c85:	c7 04 24 84 66 10 f0 	movl   $0xf0106684,(%esp)
f0100c8c:	e8 e8 2f 00 00       	call   f0103c79 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100c91:	c7 04 24 b8 66 10 f0 	movl   $0xf01066b8,(%esp)
f0100c98:	e8 dc 2f 00 00       	call   f0103c79 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100c9d:	c7 04 24 fc 66 10 f0 	movl   $0xf01066fc,(%esp)
f0100ca4:	e8 d0 2f 00 00       	call   f0103c79 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100ca9:	c7 04 24 73 62 10 f0 	movl   $0xf0106273,(%esp)
f0100cb0:	e8 c4 2f 00 00       	call   f0103c79 <cprintf>
        cprintf("         set the background color to black\n");
f0100cb5:	c7 04 24 40 67 10 f0 	movl   $0xf0106740,(%esp)
f0100cbc:	e8 b8 2f 00 00       	call   f0103c79 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100cc1:	c7 04 24 6c 67 10 f0 	movl   $0xf010676c,(%esp)
f0100cc8:	e8 ac 2f 00 00       	call   f0103c79 <cprintf>
f0100ccd:	83 c4 10             	add    $0x10,%esp
f0100cd0:	eb 52                	jmp    f0100d24 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100cd2:	83 ec 0c             	sub    $0xc,%esp
f0100cd5:	ff 73 04             	pushl  0x4(%ebx)
f0100cd8:	e8 47 43 00 00       	call   f0105024 <strlen>
f0100cdd:	83 c4 10             	add    $0x10,%esp
f0100ce0:	48                   	dec    %eax
f0100ce1:	78 26                	js     f0100d09 <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f0100ce3:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100ce6:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100ceb:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f0100cf0:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f0100cf4:	0f 94 c3             	sete   %bl
f0100cf7:	0f b6 db             	movzbl %bl,%ebx
f0100cfa:	d3 e3                	shl    %cl,%ebx
f0100cfc:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100cfe:	48                   	dec    %eax
f0100cff:	78 0d                	js     f0100d0e <mon_setcolor+0xb0>
f0100d01:	41                   	inc    %ecx
f0100d02:	83 f9 08             	cmp    $0x8,%ecx
f0100d05:	75 e9                	jne    f0100cf0 <mon_setcolor+0x92>
f0100d07:	eb 05                	jmp    f0100d0e <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100d09:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f0100d0e:	89 15 00 e0 2d f0    	mov    %edx,0xf02de000
        cprintf(" This is color that you want ! \n");
f0100d14:	83 ec 0c             	sub    $0xc,%esp
f0100d17:	68 a0 67 10 f0       	push   $0xf01067a0
f0100d1c:	e8 58 2f 00 00       	call   f0103c79 <cprintf>
f0100d21:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f0100d24:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d29:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100d2c:	5b                   	pop    %ebx
f0100d2d:	5e                   	pop    %esi
f0100d2e:	c9                   	leave  
f0100d2f:	c3                   	ret    

f0100d30 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f0100d30:	55                   	push   %ebp
f0100d31:	89 e5                	mov    %esp,%ebp
f0100d33:	57                   	push   %edi
f0100d34:	56                   	push   %esi
f0100d35:	53                   	push   %ebx
f0100d36:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100d39:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100d3b:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100d3d:	85 c0                	test   %eax,%eax
f0100d3f:	74 6d                	je     f0100dae <mon_backtrace+0x7e>
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100d41:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
f0100d44:	8b 5e 04             	mov    0x4(%esi),%ebx
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100d47:	ff 76 18             	pushl  0x18(%esi)
f0100d4a:	ff 76 14             	pushl  0x14(%esi)
f0100d4d:	ff 76 10             	pushl  0x10(%esi)
f0100d50:	ff 76 0c             	pushl  0xc(%esi)
f0100d53:	ff 76 08             	pushl  0x8(%esi)
f0100d56:	53                   	push   %ebx
f0100d57:	56                   	push   %esi
f0100d58:	68 c4 67 10 f0       	push   $0xf01067c4
f0100d5d:	e8 17 2f 00 00       	call   f0103c79 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100d62:	83 c4 18             	add    $0x18,%esp
f0100d65:	57                   	push   %edi
f0100d66:	ff 76 04             	pushl  0x4(%esi)
f0100d69:	e8 d7 39 00 00       	call   f0104745 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100d6e:	83 c4 0c             	add    $0xc,%esp
f0100d71:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100d74:	ff 75 d0             	pushl  -0x30(%ebp)
f0100d77:	68 8f 62 10 f0       	push   $0xf010628f
f0100d7c:	e8 f8 2e 00 00       	call   f0103c79 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100d81:	83 c4 0c             	add    $0xc,%esp
f0100d84:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d87:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d8a:	68 9f 62 10 f0       	push   $0xf010629f
f0100d8f:	e8 e5 2e 00 00       	call   f0103c79 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100d94:	83 c4 08             	add    $0x8,%esp
f0100d97:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100d9a:	53                   	push   %ebx
f0100d9b:	68 a4 62 10 f0       	push   $0xf01062a4
f0100da0:	e8 d4 2e 00 00       	call   f0103c79 <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100da5:	8b 36                	mov    (%esi),%esi
f0100da7:	83 c4 10             	add    $0x10,%esp
f0100daa:	85 f6                	test   %esi,%esi
f0100dac:	75 96                	jne    f0100d44 <mon_backtrace+0x14>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100dae:	b8 00 00 00 00       	mov    $0x0,%eax
f0100db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100db6:	5b                   	pop    %ebx
f0100db7:	5e                   	pop    %esi
f0100db8:	5f                   	pop    %edi
f0100db9:	c9                   	leave  
f0100dba:	c3                   	ret    

f0100dbb <pa_con>:
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
f0100dbb:	55                   	push   %ebp
f0100dbc:	89 e5                	mov    %esp,%ebp
f0100dbe:	53                   	push   %ebx
f0100dbf:	83 ec 04             	sub    $0x4,%esp
f0100dc2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
f0100dc8:	8b 15 10 ef 2d f0    	mov    0xf02def10,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100dce:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100dd4:	77 15                	ja     f0100deb <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100dd6:	52                   	push   %edx
f0100dd7:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0100ddc:	68 96 00 00 00       	push   $0x96
f0100de1:	68 a9 62 10 f0       	push   $0xf01062a9
f0100de6:	e8 7d f2 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100deb:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100df1:	39 d0                	cmp    %edx,%eax
f0100df3:	72 18                	jb     f0100e0d <pa_con+0x52>
f0100df5:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
f0100dfb:	39 d8                	cmp    %ebx,%eax
f0100dfd:	73 0e                	jae    f0100e0d <pa_con+0x52>
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
f0100dff:	29 d0                	sub    %edx,%eax
f0100e01:	8b 80 00 00 00 ef    	mov    -0x11000000(%eax),%eax
f0100e07:	89 01                	mov    %eax,(%ecx)
        return true;
f0100e09:	b0 01                	mov    $0x1,%al
f0100e0b:	eb 56                	jmp    f0100e63 <pa_con+0xa8>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e0d:	ba 00 d0 11 f0       	mov    $0xf011d000,%edx
f0100e12:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100e18:	77 15                	ja     f0100e2f <pa_con+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e1a:	52                   	push   %edx
f0100e1b:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0100e20:	68 9b 00 00 00       	push   $0x9b
f0100e25:	68 a9 62 10 f0       	push   $0xf01062a9
f0100e2a:	e8 39 f2 ff ff       	call   f0100068 <_panic>
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
f0100e2f:	3d 00 d0 11 00       	cmp    $0x11d000,%eax
f0100e34:	72 18                	jb     f0100e4e <pa_con+0x93>
f0100e36:	3d 00 50 12 00       	cmp    $0x125000,%eax
f0100e3b:	73 11                	jae    f0100e4e <pa_con+0x93>
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
f0100e3d:	2d 00 d0 11 00       	sub    $0x11d000,%eax
f0100e42:	8b 80 00 80 ff ef    	mov    -0x10008000(%eax),%eax
f0100e48:	89 01                	mov    %eax,(%ecx)
        return true;
f0100e4a:	b0 01                	mov    $0x1,%al
f0100e4c:	eb 15                	jmp    f0100e63 <pa_con+0xa8>
    }
    if (addr < -KERNBASE) {
f0100e4e:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100e53:	77 0c                	ja     f0100e61 <pa_con+0xa6>
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
f0100e55:	8b 80 00 00 00 f0    	mov    -0x10000000(%eax),%eax
f0100e5b:	89 01                	mov    %eax,(%ecx)
        return true;
f0100e5d:	b0 01                	mov    $0x1,%al
f0100e5f:	eb 02                	jmp    f0100e63 <pa_con+0xa8>
    }
    // Not in virtual memory mapped.
    return false;
f0100e61:	b0 00                	mov    $0x0,%al
}
f0100e63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e66:	c9                   	leave  
f0100e67:	c3                   	ret    

f0100e68 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
f0100e68:	55                   	push   %ebp
f0100e69:	89 e5                	mov    %esp,%ebp
f0100e6b:	57                   	push   %edi
f0100e6c:	56                   	push   %esi
f0100e6d:	53                   	push   %ebx
f0100e6e:	83 ec 2c             	sub    $0x2c,%esp
f0100e71:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 4) {
f0100e74:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100e78:	74 2d                	je     f0100ea7 <mon_dump+0x3f>
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
f0100e7a:	83 ec 0c             	sub    $0xc,%esp
f0100e7d:	68 fc 67 10 f0       	push   $0xf01067fc
f0100e82:	e8 f2 2d 00 00       	call   f0103c79 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100e87:	c7 04 24 2c 68 10 f0 	movl   $0xf010682c,(%esp)
f0100e8e:	e8 e6 2d 00 00       	call   f0103c79 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100e93:	c7 04 24 54 68 10 f0 	movl   $0xf0106854,(%esp)
f0100e9a:	e8 da 2d 00 00       	call   f0103c79 <cprintf>
f0100e9f:	83 c4 10             	add    $0x10,%esp
f0100ea2:	e9 59 01 00 00       	jmp    f0101000 <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100ea7:	83 ec 04             	sub    $0x4,%esp
f0100eaa:	6a 00                	push   $0x0
f0100eac:	6a 00                	push   $0x0
f0100eae:	ff 76 08             	pushl  0x8(%esi)
f0100eb1:	e8 70 44 00 00       	call   f0105326 <strtol>
f0100eb6:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100eb8:	83 c4 0c             	add    $0xc,%esp
f0100ebb:	6a 00                	push   $0x0
f0100ebd:	6a 00                	push   $0x0
f0100ebf:	ff 76 0c             	pushl  0xc(%esi)
f0100ec2:	e8 5f 44 00 00       	call   f0105326 <strtol>
        if (laddr > haddr) {
f0100ec7:	83 c4 10             	add    $0x10,%esp
f0100eca:	39 c3                	cmp    %eax,%ebx
f0100ecc:	76 01                	jbe    f0100ecf <mon_dump+0x67>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100ece:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, 4);
f0100ecf:	89 df                	mov    %ebx,%edi
f0100ed1:	83 e7 fc             	and    $0xfffffffc,%edi
        haddr = ROUNDDOWN(haddr, 4);
f0100ed4:	83 e0 fc             	and    $0xfffffffc,%eax
f0100ed7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if (argv[1][0] == 'v') {
f0100eda:	8b 46 04             	mov    0x4(%esi),%eax
f0100edd:	80 38 76             	cmpb   $0x76,(%eax)
f0100ee0:	74 0e                	je     f0100ef0 <mon_dump+0x88>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100ee2:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100ee5:	0f 85 98 00 00 00    	jne    f0100f83 <mon_dump+0x11b>
f0100eeb:	e9 00 01 00 00       	jmp    f0100ff0 <mon_dump+0x188>
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100ef0:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100ef3:	74 7c                	je     f0100f71 <mon_dump+0x109>
f0100ef5:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100ef7:	39 fb                	cmp    %edi,%ebx
f0100ef9:	74 15                	je     f0100f10 <mon_dump+0xa8>
f0100efb:	f6 c3 0f             	test   $0xf,%bl
f0100efe:	75 21                	jne    f0100f21 <mon_dump+0xb9>
                    if (now != laddr) cprintf("\n"); 
f0100f00:	83 ec 0c             	sub    $0xc,%esp
f0100f03:	68 2f 62 10 f0       	push   $0xf010622f
f0100f08:	e8 6c 2d 00 00       	call   f0103c79 <cprintf>
f0100f0d:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100f10:	83 ec 08             	sub    $0x8,%esp
f0100f13:	53                   	push   %ebx
f0100f14:	68 b8 62 10 f0       	push   $0xf01062b8
f0100f19:	e8 5b 2d 00 00       	call   f0103c79 <cprintf>
f0100f1e:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100f21:	83 ec 04             	sub    $0x4,%esp
f0100f24:	6a 00                	push   $0x0
f0100f26:	89 d8                	mov    %ebx,%eax
f0100f28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f2d:	50                   	push   %eax
f0100f2e:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0100f34:	e8 33 07 00 00       	call   f010166c <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100f39:	83 c4 10             	add    $0x10,%esp
f0100f3c:	85 c0                	test   %eax,%eax
f0100f3e:	74 19                	je     f0100f59 <mon_dump+0xf1>
f0100f40:	f6 00 01             	testb  $0x1,(%eax)
f0100f43:	74 14                	je     f0100f59 <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100f45:	83 ec 08             	sub    $0x8,%esp
f0100f48:	ff 33                	pushl  (%ebx)
f0100f4a:	68 c2 62 10 f0       	push   $0xf01062c2
f0100f4f:	e8 25 2d 00 00       	call   f0103c79 <cprintf>
f0100f54:	83 c4 10             	add    $0x10,%esp
f0100f57:	eb 10                	jmp    f0100f69 <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100f59:	83 ec 0c             	sub    $0xc,%esp
f0100f5c:	68 cd 62 10 f0       	push   $0xf01062cd
f0100f61:	e8 13 2d 00 00       	call   f0103c79 <cprintf>
f0100f66:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100f69:	83 c3 04             	add    $0x4,%ebx
f0100f6c:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100f6f:	75 86                	jne    f0100ef7 <mon_dump+0x8f>
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
f0100f71:	83 ec 0c             	sub    $0xc,%esp
f0100f74:	68 2f 62 10 f0       	push   $0xf010622f
f0100f79:	e8 fb 2c 00 00       	call   f0103c79 <cprintf>
f0100f7e:	83 c4 10             	add    $0x10,%esp
f0100f81:	eb 7d                	jmp    f0101000 <mon_dump+0x198>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100f83:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100f85:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100f88:	39 fb                	cmp    %edi,%ebx
f0100f8a:	74 15                	je     f0100fa1 <mon_dump+0x139>
f0100f8c:	f6 c3 0f             	test   $0xf,%bl
f0100f8f:	75 21                	jne    f0100fb2 <mon_dump+0x14a>
                    if (now != laddr) cprintf("\n");
f0100f91:	83 ec 0c             	sub    $0xc,%esp
f0100f94:	68 2f 62 10 f0       	push   $0xf010622f
f0100f99:	e8 db 2c 00 00       	call   f0103c79 <cprintf>
f0100f9e:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100fa1:	83 ec 08             	sub    $0x8,%esp
f0100fa4:	53                   	push   %ebx
f0100fa5:	68 b8 62 10 f0       	push   $0xf01062b8
f0100faa:	e8 ca 2c 00 00       	call   f0103c79 <cprintf>
f0100faf:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f0100fb2:	83 ec 08             	sub    $0x8,%esp
f0100fb5:	56                   	push   %esi
f0100fb6:	53                   	push   %ebx
f0100fb7:	e8 ff fd ff ff       	call   f0100dbb <pa_con>
f0100fbc:	83 c4 10             	add    $0x10,%esp
f0100fbf:	84 c0                	test   %al,%al
f0100fc1:	74 15                	je     f0100fd8 <mon_dump+0x170>
                    cprintf("0x%08x  ", value);
f0100fc3:	83 ec 08             	sub    $0x8,%esp
f0100fc6:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100fc9:	68 c2 62 10 f0       	push   $0xf01062c2
f0100fce:	e8 a6 2c 00 00       	call   f0103c79 <cprintf>
f0100fd3:	83 c4 10             	add    $0x10,%esp
f0100fd6:	eb 10                	jmp    f0100fe8 <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100fd8:	83 ec 0c             	sub    $0xc,%esp
f0100fdb:	68 cb 62 10 f0       	push   $0xf01062cb
f0100fe0:	e8 94 2c 00 00       	call   f0103c79 <cprintf>
f0100fe5:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100fe8:	83 c3 04             	add    $0x4,%ebx
f0100feb:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100fee:	75 98                	jne    f0100f88 <mon_dump+0x120>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f0100ff0:	83 ec 0c             	sub    $0xc,%esp
f0100ff3:	68 2f 62 10 f0       	push   $0xf010622f
f0100ff8:	e8 7c 2c 00 00       	call   f0103c79 <cprintf>
f0100ffd:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0101000:	b8 00 00 00 00       	mov    $0x0,%eax
f0101005:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101008:	5b                   	pop    %ebx
f0101009:	5e                   	pop    %esi
f010100a:	5f                   	pop    %edi
f010100b:	c9                   	leave  
f010100c:	c3                   	ret    

f010100d <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010100d:	55                   	push   %ebp
f010100e:	89 e5                	mov    %esp,%ebp
f0101010:	57                   	push   %edi
f0101011:	56                   	push   %esi
f0101012:	53                   	push   %ebx
f0101013:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0101016:	68 98 68 10 f0       	push   $0xf0106898
f010101b:	e8 59 2c 00 00       	call   f0103c79 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101020:	c7 04 24 bc 68 10 f0 	movl   $0xf01068bc,(%esp)
f0101027:	e8 4d 2c 00 00       	call   f0103c79 <cprintf>

	if (tf != NULL)
f010102c:	83 c4 10             	add    $0x10,%esp
f010102f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101033:	74 0e                	je     f0101043 <monitor+0x36>
		print_trapframe(tf);
f0101035:	83 ec 0c             	sub    $0xc,%esp
f0101038:	ff 75 08             	pushl  0x8(%ebp)
f010103b:	e8 ec 2d 00 00       	call   f0103e2c <print_trapframe>
f0101040:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0101043:	83 ec 0c             	sub    $0xc,%esp
f0101046:	68 d8 62 10 f0       	push   $0xf01062d8
f010104b:	e8 04 3f 00 00       	call   f0104f54 <readline>
f0101050:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0101052:	83 c4 10             	add    $0x10,%esp
f0101055:	85 c0                	test   %eax,%eax
f0101057:	74 ea                	je     f0101043 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0101059:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0101060:	be 00 00 00 00       	mov    $0x0,%esi
f0101065:	eb 04                	jmp    f010106b <monitor+0x5e>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0101067:	c6 03 00             	movb   $0x0,(%ebx)
f010106a:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010106b:	8a 03                	mov    (%ebx),%al
f010106d:	84 c0                	test   %al,%al
f010106f:	74 64                	je     f01010d5 <monitor+0xc8>
f0101071:	83 ec 08             	sub    $0x8,%esp
f0101074:	0f be c0             	movsbl %al,%eax
f0101077:	50                   	push   %eax
f0101078:	68 dc 62 10 f0       	push   $0xf01062dc
f010107d:	e8 1b 41 00 00       	call   f010519d <strchr>
f0101082:	83 c4 10             	add    $0x10,%esp
f0101085:	85 c0                	test   %eax,%eax
f0101087:	75 de                	jne    f0101067 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0101089:	80 3b 00             	cmpb   $0x0,(%ebx)
f010108c:	74 47                	je     f01010d5 <monitor+0xc8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010108e:	83 fe 0f             	cmp    $0xf,%esi
f0101091:	75 14                	jne    f01010a7 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0101093:	83 ec 08             	sub    $0x8,%esp
f0101096:	6a 10                	push   $0x10
f0101098:	68 e1 62 10 f0       	push   $0xf01062e1
f010109d:	e8 d7 2b 00 00       	call   f0103c79 <cprintf>
f01010a2:	83 c4 10             	add    $0x10,%esp
f01010a5:	eb 9c                	jmp    f0101043 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01010a7:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01010ab:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01010ac:	8a 03                	mov    (%ebx),%al
f01010ae:	84 c0                	test   %al,%al
f01010b0:	75 09                	jne    f01010bb <monitor+0xae>
f01010b2:	eb b7                	jmp    f010106b <monitor+0x5e>
			buf++;
f01010b4:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01010b5:	8a 03                	mov    (%ebx),%al
f01010b7:	84 c0                	test   %al,%al
f01010b9:	74 b0                	je     f010106b <monitor+0x5e>
f01010bb:	83 ec 08             	sub    $0x8,%esp
f01010be:	0f be c0             	movsbl %al,%eax
f01010c1:	50                   	push   %eax
f01010c2:	68 dc 62 10 f0       	push   $0xf01062dc
f01010c7:	e8 d1 40 00 00       	call   f010519d <strchr>
f01010cc:	83 c4 10             	add    $0x10,%esp
f01010cf:	85 c0                	test   %eax,%eax
f01010d1:	74 e1                	je     f01010b4 <monitor+0xa7>
f01010d3:	eb 96                	jmp    f010106b <monitor+0x5e>
			buf++;
	}
	argv[argc] = 0;
f01010d5:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01010dc:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01010dd:	85 f6                	test   %esi,%esi
f01010df:	0f 84 5e ff ff ff    	je     f0101043 <monitor+0x36>
f01010e5:	bb 40 69 10 f0       	mov    $0xf0106940,%ebx
f01010ea:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01010ef:	83 ec 08             	sub    $0x8,%esp
f01010f2:	ff 33                	pushl  (%ebx)
f01010f4:	ff 75 a8             	pushl  -0x58(%ebp)
f01010f7:	e8 33 40 00 00       	call   f010512f <strcmp>
f01010fc:	83 c4 10             	add    $0x10,%esp
f01010ff:	85 c0                	test   %eax,%eax
f0101101:	75 20                	jne    f0101123 <monitor+0x116>
			return commands[i].func(argc, argv, tf);
f0101103:	83 ec 04             	sub    $0x4,%esp
f0101106:	6b ff 0c             	imul   $0xc,%edi,%edi
f0101109:	ff 75 08             	pushl  0x8(%ebp)
f010110c:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010110f:	50                   	push   %eax
f0101110:	56                   	push   %esi
f0101111:	ff 97 48 69 10 f0    	call   *-0xfef96b8(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0101117:	83 c4 10             	add    $0x10,%esp
f010111a:	85 c0                	test   %eax,%eax
f010111c:	78 26                	js     f0101144 <monitor+0x137>
f010111e:	e9 20 ff ff ff       	jmp    f0101043 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0101123:	47                   	inc    %edi
f0101124:	83 c3 0c             	add    $0xc,%ebx
f0101127:	83 ff 09             	cmp    $0x9,%edi
f010112a:	75 c3                	jne    f01010ef <monitor+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010112c:	83 ec 08             	sub    $0x8,%esp
f010112f:	ff 75 a8             	pushl  -0x58(%ebp)
f0101132:	68 fe 62 10 f0       	push   $0xf01062fe
f0101137:	e8 3d 2b 00 00       	call   f0103c79 <cprintf>
f010113c:	83 c4 10             	add    $0x10,%esp
f010113f:	e9 ff fe ff ff       	jmp    f0101043 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0101144:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101147:	5b                   	pop    %ebx
f0101148:	5e                   	pop    %esi
f0101149:	5f                   	pop    %edi
f010114a:	c9                   	leave  
f010114b:	c3                   	ret    

f010114c <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f010114c:	55                   	push   %ebp
f010114d:	89 e5                	mov    %esp,%ebp
f010114f:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0101151:	83 3d 34 e2 2d f0 00 	cmpl   $0x0,0xf02de234
f0101158:	75 0f                	jne    f0101169 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010115a:	b8 07 10 32 f0       	mov    $0xf0321007,%eax
f010115f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101164:	a3 34 e2 2d f0       	mov    %eax,0xf02de234
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0101169:	a1 34 e2 2d f0       	mov    0xf02de234,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f010116e:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0101175:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010117b:	89 15 34 e2 2d f0    	mov    %edx,0xf02de234

	return result;
}
f0101181:	c9                   	leave  
f0101182:	c3                   	ret    

f0101183 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101183:	55                   	push   %ebp
f0101184:	89 e5                	mov    %esp,%ebp
f0101186:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0101189:	89 d1                	mov    %edx,%ecx
f010118b:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f010118e:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0101191:	a8 01                	test   $0x1,%al
f0101193:	74 42                	je     f01011d7 <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101195:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010119a:	89 c1                	mov    %eax,%ecx
f010119c:	c1 e9 0c             	shr    $0xc,%ecx
f010119f:	3b 0d 08 ef 2d f0    	cmp    0xf02def08,%ecx
f01011a5:	72 15                	jb     f01011bc <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011a7:	50                   	push   %eax
f01011a8:	68 08 5f 10 f0       	push   $0xf0105f08
f01011ad:	68 6a 03 00 00       	push   $0x36a
f01011b2:	68 91 72 10 f0       	push   $0xf0107291
f01011b7:	e8 ac ee ff ff       	call   f0100068 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f01011bc:	c1 ea 0c             	shr    $0xc,%edx
f01011bf:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01011c5:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01011cc:	a8 01                	test   $0x1,%al
f01011ce:	74 0e                	je     f01011de <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01011d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011d5:	eb 0c                	jmp    f01011e3 <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01011d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01011dc:	eb 05                	jmp    f01011e3 <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f01011de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f01011e3:	c9                   	leave  
f01011e4:	c3                   	ret    

f01011e5 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01011e5:	55                   	push   %ebp
f01011e6:	89 e5                	mov    %esp,%ebp
f01011e8:	56                   	push   %esi
f01011e9:	53                   	push   %ebx
f01011ea:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01011ec:	83 ec 0c             	sub    $0xc,%esp
f01011ef:	50                   	push   %eax
f01011f0:	e8 43 29 00 00       	call   f0103b38 <mc146818_read>
f01011f5:	89 c6                	mov    %eax,%esi
f01011f7:	43                   	inc    %ebx
f01011f8:	89 1c 24             	mov    %ebx,(%esp)
f01011fb:	e8 38 29 00 00       	call   f0103b38 <mc146818_read>
f0101200:	c1 e0 08             	shl    $0x8,%eax
f0101203:	09 f0                	or     %esi,%eax
}
f0101205:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101208:	5b                   	pop    %ebx
f0101209:	5e                   	pop    %esi
f010120a:	c9                   	leave  
f010120b:	c3                   	ret    

f010120c <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f010120c:	55                   	push   %ebp
f010120d:	89 e5                	mov    %esp,%ebp
f010120f:	57                   	push   %edi
f0101210:	56                   	push   %esi
f0101211:	53                   	push   %ebx
f0101212:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101215:	3c 01                	cmp    $0x1,%al
f0101217:	19 f6                	sbb    %esi,%esi
f0101219:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f010121f:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101220:	8b 1d 30 e2 2d f0    	mov    0xf02de230,%ebx
f0101226:	85 db                	test   %ebx,%ebx
f0101228:	75 17                	jne    f0101241 <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f010122a:	83 ec 04             	sub    $0x4,%esp
f010122d:	68 ac 69 10 f0       	push   $0xf01069ac
f0101232:	68 9f 02 00 00       	push   $0x29f
f0101237:	68 91 72 10 f0       	push   $0xf0107291
f010123c:	e8 27 ee ff ff       	call   f0100068 <_panic>

	if (only_low_memory) {
f0101241:	84 c0                	test   %al,%al
f0101243:	74 50                	je     f0101295 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101245:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101248:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010124b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010124e:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101251:	89 d8                	mov    %ebx,%eax
f0101253:	2b 05 10 ef 2d f0    	sub    0xf02def10,%eax
f0101259:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010125c:	c1 e8 16             	shr    $0x16,%eax
f010125f:	39 c6                	cmp    %eax,%esi
f0101261:	0f 96 c0             	setbe  %al
f0101264:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101267:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f010126b:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f010126d:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101271:	8b 1b                	mov    (%ebx),%ebx
f0101273:	85 db                	test   %ebx,%ebx
f0101275:	75 da                	jne    f0101251 <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101277:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010127a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101280:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101283:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101286:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101288:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010128b:	89 1d 30 e2 2d f0    	mov    %ebx,0xf02de230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101291:	85 db                	test   %ebx,%ebx
f0101293:	74 57                	je     f01012ec <check_page_free_list+0xe0>
f0101295:	89 d8                	mov    %ebx,%eax
f0101297:	2b 05 10 ef 2d f0    	sub    0xf02def10,%eax
f010129d:	c1 f8 03             	sar    $0x3,%eax
f01012a0:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01012a3:	89 c2                	mov    %eax,%edx
f01012a5:	c1 ea 16             	shr    $0x16,%edx
f01012a8:	39 d6                	cmp    %edx,%esi
f01012aa:	76 3a                	jbe    f01012e6 <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012ac:	89 c2                	mov    %eax,%edx
f01012ae:	c1 ea 0c             	shr    $0xc,%edx
f01012b1:	3b 15 08 ef 2d f0    	cmp    0xf02def08,%edx
f01012b7:	72 12                	jb     f01012cb <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012b9:	50                   	push   %eax
f01012ba:	68 08 5f 10 f0       	push   $0xf0105f08
f01012bf:	6a 58                	push   $0x58
f01012c1:	68 9d 72 10 f0       	push   $0xf010729d
f01012c6:	e8 9d ed ff ff       	call   f0100068 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01012cb:	83 ec 04             	sub    $0x4,%esp
f01012ce:	68 80 00 00 00       	push   $0x80
f01012d3:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01012d8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01012dd:	50                   	push   %eax
f01012de:	e8 0a 3f 00 00       	call   f01051ed <memset>
f01012e3:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01012e6:	8b 1b                	mov    (%ebx),%ebx
f01012e8:	85 db                	test   %ebx,%ebx
f01012ea:	75 a9                	jne    f0101295 <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01012ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01012f1:	e8 56 fe ff ff       	call   f010114c <boot_alloc>
f01012f6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012f9:	8b 15 30 e2 2d f0    	mov    0xf02de230,%edx
f01012ff:	85 d2                	test   %edx,%edx
f0101301:	0f 84 b2 01 00 00    	je     f01014b9 <check_page_free_list+0x2ad>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101307:	8b 1d 10 ef 2d f0    	mov    0xf02def10,%ebx
f010130d:	39 da                	cmp    %ebx,%edx
f010130f:	72 4b                	jb     f010135c <check_page_free_list+0x150>
		assert(pp < pages + npages);
f0101311:	a1 08 ef 2d f0       	mov    0xf02def08,%eax
f0101316:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101319:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f010131c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010131f:	39 c2                	cmp    %eax,%edx
f0101321:	73 57                	jae    f010137a <check_page_free_list+0x16e>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101323:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101326:	89 d0                	mov    %edx,%eax
f0101328:	29 d8                	sub    %ebx,%eax
f010132a:	a8 07                	test   $0x7,%al
f010132c:	75 6e                	jne    f010139c <check_page_free_list+0x190>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010132e:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101331:	c1 e0 0c             	shl    $0xc,%eax
f0101334:	0f 84 83 00 00 00    	je     f01013bd <check_page_free_list+0x1b1>
		assert(page2pa(pp) != IOPHYSMEM);
f010133a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010133f:	0f 84 98 00 00 00    	je     f01013dd <check_page_free_list+0x1d1>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101345:	be 00 00 00 00       	mov    $0x0,%esi
f010134a:	bf 00 00 00 00       	mov    $0x0,%edi
f010134f:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f0101352:	e9 9f 00 00 00       	jmp    f01013f6 <check_page_free_list+0x1ea>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101357:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f010135a:	73 19                	jae    f0101375 <check_page_free_list+0x169>
f010135c:	68 ab 72 10 f0       	push   $0xf01072ab
f0101361:	68 b7 72 10 f0       	push   $0xf01072b7
f0101366:	68 b9 02 00 00       	push   $0x2b9
f010136b:	68 91 72 10 f0       	push   $0xf0107291
f0101370:	e8 f3 ec ff ff       	call   f0100068 <_panic>
		assert(pp < pages + npages);
f0101375:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101378:	72 19                	jb     f0101393 <check_page_free_list+0x187>
f010137a:	68 cc 72 10 f0       	push   $0xf01072cc
f010137f:	68 b7 72 10 f0       	push   $0xf01072b7
f0101384:	68 ba 02 00 00       	push   $0x2ba
f0101389:	68 91 72 10 f0       	push   $0xf0107291
f010138e:	e8 d5 ec ff ff       	call   f0100068 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101393:	89 d0                	mov    %edx,%eax
f0101395:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0101398:	a8 07                	test   $0x7,%al
f010139a:	74 19                	je     f01013b5 <check_page_free_list+0x1a9>
f010139c:	68 d0 69 10 f0       	push   $0xf01069d0
f01013a1:	68 b7 72 10 f0       	push   $0xf01072b7
f01013a6:	68 bb 02 00 00       	push   $0x2bb
f01013ab:	68 91 72 10 f0       	push   $0xf0107291
f01013b0:	e8 b3 ec ff ff       	call   f0100068 <_panic>
f01013b5:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01013b8:	c1 e0 0c             	shl    $0xc,%eax
f01013bb:	75 19                	jne    f01013d6 <check_page_free_list+0x1ca>
f01013bd:	68 e0 72 10 f0       	push   $0xf01072e0
f01013c2:	68 b7 72 10 f0       	push   $0xf01072b7
f01013c7:	68 be 02 00 00       	push   $0x2be
f01013cc:	68 91 72 10 f0       	push   $0xf0107291
f01013d1:	e8 92 ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01013d6:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01013db:	75 19                	jne    f01013f6 <check_page_free_list+0x1ea>
f01013dd:	68 f1 72 10 f0       	push   $0xf01072f1
f01013e2:	68 b7 72 10 f0       	push   $0xf01072b7
f01013e7:	68 bf 02 00 00       	push   $0x2bf
f01013ec:	68 91 72 10 f0       	push   $0xf0107291
f01013f1:	e8 72 ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01013f6:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01013fb:	75 19                	jne    f0101416 <check_page_free_list+0x20a>
f01013fd:	68 04 6a 10 f0       	push   $0xf0106a04
f0101402:	68 b7 72 10 f0       	push   $0xf01072b7
f0101407:	68 c0 02 00 00       	push   $0x2c0
f010140c:	68 91 72 10 f0       	push   $0xf0107291
f0101411:	e8 52 ec ff ff       	call   f0100068 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101416:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010141b:	75 19                	jne    f0101436 <check_page_free_list+0x22a>
f010141d:	68 0a 73 10 f0       	push   $0xf010730a
f0101422:	68 b7 72 10 f0       	push   $0xf01072b7
f0101427:	68 c1 02 00 00       	push   $0x2c1
f010142c:	68 91 72 10 f0       	push   $0xf0107291
f0101431:	e8 32 ec ff ff       	call   f0100068 <_panic>
f0101436:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101438:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010143d:	76 40                	jbe    f010147f <check_page_free_list+0x273>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010143f:	89 c3                	mov    %eax,%ebx
f0101441:	c1 eb 0c             	shr    $0xc,%ebx
f0101444:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0101447:	77 12                	ja     f010145b <check_page_free_list+0x24f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101449:	50                   	push   %eax
f010144a:	68 08 5f 10 f0       	push   $0xf0105f08
f010144f:	6a 58                	push   $0x58
f0101451:	68 9d 72 10 f0       	push   $0xf010729d
f0101456:	e8 0d ec ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f010145b:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0101461:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0101464:	76 19                	jbe    f010147f <check_page_free_list+0x273>
f0101466:	68 28 6a 10 f0       	push   $0xf0106a28
f010146b:	68 b7 72 10 f0       	push   $0xf01072b7
f0101470:	68 c2 02 00 00       	push   $0x2c2
f0101475:	68 91 72 10 f0       	push   $0xf0107291
f010147a:	e8 e9 eb ff ff       	call   f0100068 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010147f:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101484:	75 19                	jne    f010149f <check_page_free_list+0x293>
f0101486:	68 24 73 10 f0       	push   $0xf0107324
f010148b:	68 b7 72 10 f0       	push   $0xf01072b7
f0101490:	68 c4 02 00 00       	push   $0x2c4
f0101495:	68 91 72 10 f0       	push   $0xf0107291
f010149a:	e8 c9 eb ff ff       	call   f0100068 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f010149f:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f01014a5:	77 03                	ja     f01014aa <check_page_free_list+0x29e>
			++nfree_basemem;
f01014a7:	47                   	inc    %edi
f01014a8:	eb 01                	jmp    f01014ab <check_page_free_list+0x29f>
		else
			++nfree_extmem;
f01014aa:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01014ab:	8b 12                	mov    (%edx),%edx
f01014ad:	85 d2                	test   %edx,%edx
f01014af:	0f 85 a2 fe ff ff    	jne    f0101357 <check_page_free_list+0x14b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01014b5:	85 ff                	test   %edi,%edi
f01014b7:	7f 19                	jg     f01014d2 <check_page_free_list+0x2c6>
f01014b9:	68 41 73 10 f0       	push   $0xf0107341
f01014be:	68 b7 72 10 f0       	push   $0xf01072b7
f01014c3:	68 cc 02 00 00       	push   $0x2cc
f01014c8:	68 91 72 10 f0       	push   $0xf0107291
f01014cd:	e8 96 eb ff ff       	call   f0100068 <_panic>
	assert(nfree_extmem > 0);
f01014d2:	85 f6                	test   %esi,%esi
f01014d4:	7f 19                	jg     f01014ef <check_page_free_list+0x2e3>
f01014d6:	68 53 73 10 f0       	push   $0xf0107353
f01014db:	68 b7 72 10 f0       	push   $0xf01072b7
f01014e0:	68 cd 02 00 00       	push   $0x2cd
f01014e5:	68 91 72 10 f0       	push   $0xf0107291
f01014ea:	e8 79 eb ff ff       	call   f0100068 <_panic>
}
f01014ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014f2:	5b                   	pop    %ebx
f01014f3:	5e                   	pop    %esi
f01014f4:	5f                   	pop    %edi
f01014f5:	c9                   	leave  
f01014f6:	c3                   	ret    

f01014f7 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01014f7:	55                   	push   %ebp
f01014f8:	89 e5                	mov    %esp,%ebp
f01014fa:	56                   	push   %esi
f01014fb:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f01014fc:	c7 05 30 e2 2d f0 00 	movl   $0x0,0xf02de230
f0101503:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f0101506:	b8 00 00 00 00       	mov    $0x0,%eax
f010150b:	e8 3c fc ff ff       	call   f010114c <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101510:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101515:	77 15                	ja     f010152c <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101517:	50                   	push   %eax
f0101518:	68 e4 5e 10 f0       	push   $0xf0105ee4
f010151d:	68 48 01 00 00       	push   $0x148
f0101522:	68 91 72 10 f0       	push   $0xf0107291
f0101527:	e8 3c eb ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010152c:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f0101532:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f0101535:	83 3d 08 ef 2d f0 00 	cmpl   $0x0,0xf02def08
f010153c:	74 5f                	je     f010159d <page_init+0xa6>
f010153e:	8b 1d 30 e2 2d f0    	mov    0xf02de230,%ebx
f0101544:	ba 00 00 00 00       	mov    $0x0,%edx
f0101549:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f010154e:	85 c0                	test   %eax,%eax
f0101550:	74 25                	je     f0101577 <page_init+0x80>
f0101552:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0101557:	76 04                	jbe    f010155d <page_init+0x66>
f0101559:	39 c6                	cmp    %eax,%esi
f010155b:	77 1a                	ja     f0101577 <page_init+0x80>
		    pages[i].pp_ref = 0;
f010155d:	89 d1                	mov    %edx,%ecx
f010155f:	03 0d 10 ef 2d f0    	add    0xf02def10,%ecx
f0101565:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f010156b:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f010156d:	89 d3                	mov    %edx,%ebx
f010156f:	03 1d 10 ef 2d f0    	add    0xf02def10,%ebx
f0101575:	eb 14                	jmp    f010158b <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f0101577:	89 d1                	mov    %edx,%ecx
f0101579:	03 0d 10 ef 2d f0    	add    0xf02def10,%ecx
f010157f:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f0101585:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// free pages!
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    for (i = 0; i < npages; i++) {
f010158b:	40                   	inc    %eax
f010158c:	83 c2 08             	add    $0x8,%edx
f010158f:	39 05 08 ef 2d f0    	cmp    %eax,0xf02def08
f0101595:	77 b7                	ja     f010154e <page_init+0x57>
f0101597:	89 1d 30 e2 2d f0    	mov    %ebx,0xf02de230
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f010159d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01015a0:	5b                   	pop    %ebx
f01015a1:	5e                   	pop    %esi
f01015a2:	c9                   	leave  
f01015a3:	c3                   	ret    

f01015a4 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01015a4:	55                   	push   %ebp
f01015a5:	89 e5                	mov    %esp,%ebp
f01015a7:	53                   	push   %ebx
f01015a8:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f01015ab:	8b 1d 30 e2 2d f0    	mov    0xf02de230,%ebx
f01015b1:	85 db                	test   %ebx,%ebx
f01015b3:	74 63                	je     f0101618 <page_alloc+0x74>
f01015b5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01015ba:	74 63                	je     f010161f <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f01015bc:	8b 1b                	mov    (%ebx),%ebx
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f01015be:	85 db                	test   %ebx,%ebx
f01015c0:	75 08                	jne    f01015ca <page_alloc+0x26>
f01015c2:	89 1d 30 e2 2d f0    	mov    %ebx,0xf02de230
f01015c8:	eb 4e                	jmp    f0101618 <page_alloc+0x74>
f01015ca:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01015cf:	75 eb                	jne    f01015bc <page_alloc+0x18>
f01015d1:	eb 4c                	jmp    f010161f <page_alloc+0x7b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015d3:	89 d8                	mov    %ebx,%eax
f01015d5:	2b 05 10 ef 2d f0    	sub    0xf02def10,%eax
f01015db:	c1 f8 03             	sar    $0x3,%eax
f01015de:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015e1:	89 c2                	mov    %eax,%edx
f01015e3:	c1 ea 0c             	shr    $0xc,%edx
f01015e6:	3b 15 08 ef 2d f0    	cmp    0xf02def08,%edx
f01015ec:	72 12                	jb     f0101600 <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015ee:	50                   	push   %eax
f01015ef:	68 08 5f 10 f0       	push   $0xf0105f08
f01015f4:	6a 58                	push   $0x58
f01015f6:	68 9d 72 10 f0       	push   $0xf010729d
f01015fb:	e8 68 ea ff ff       	call   f0100068 <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f0101600:	83 ec 04             	sub    $0x4,%esp
f0101603:	68 00 10 00 00       	push   $0x1000
f0101608:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010160a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010160f:	50                   	push   %eax
f0101610:	e8 d8 3b 00 00       	call   f01051ed <memset>
f0101615:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f0101618:	89 d8                	mov    %ebx,%eax
f010161a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010161d:	c9                   	leave  
f010161e:	c3                   	ret    
        page_free_list = page_free_list->pp_link;
    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f010161f:	8b 03                	mov    (%ebx),%eax
f0101621:	a3 30 e2 2d f0       	mov    %eax,0xf02de230
        if (alloc_flags & ALLOC_ZERO) {
f0101626:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010162a:	74 ec                	je     f0101618 <page_alloc+0x74>
f010162c:	eb a5                	jmp    f01015d3 <page_alloc+0x2f>

f010162e <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010162e:	55                   	push   %ebp
f010162f:	89 e5                	mov    %esp,%ebp
f0101631:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f0101634:	85 c0                	test   %eax,%eax
f0101636:	74 14                	je     f010164c <page_free+0x1e>
f0101638:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010163d:	75 0d                	jne    f010164c <page_free+0x1e>
    pp->pp_link = page_free_list;
f010163f:	8b 15 30 e2 2d f0    	mov    0xf02de230,%edx
f0101645:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0101647:	a3 30 e2 2d f0       	mov    %eax,0xf02de230
}
f010164c:	c9                   	leave  
f010164d:	c3                   	ret    

f010164e <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010164e:	55                   	push   %ebp
f010164f:	89 e5                	mov    %esp,%ebp
f0101651:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101654:	8b 50 04             	mov    0x4(%eax),%edx
f0101657:	4a                   	dec    %edx
f0101658:	66 89 50 04          	mov    %dx,0x4(%eax)
f010165c:	66 85 d2             	test   %dx,%dx
f010165f:	75 09                	jne    f010166a <page_decref+0x1c>
		page_free(pp);
f0101661:	50                   	push   %eax
f0101662:	e8 c7 ff ff ff       	call   f010162e <page_free>
f0101667:	83 c4 04             	add    $0x4,%esp
}
f010166a:	c9                   	leave  
f010166b:	c3                   	ret    

f010166c <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010166c:	55                   	push   %ebp
f010166d:	89 e5                	mov    %esp,%ebp
f010166f:	56                   	push   %esi
f0101670:	53                   	push   %ebx
f0101671:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f0101674:	89 f3                	mov    %esi,%ebx
f0101676:	c1 eb 16             	shr    $0x16,%ebx
f0101679:	c1 e3 02             	shl    $0x2,%ebx
f010167c:	03 5d 08             	add    0x8(%ebp),%ebx
f010167f:	8b 03                	mov    (%ebx),%eax
f0101681:	85 c0                	test   %eax,%eax
f0101683:	74 04                	je     f0101689 <pgdir_walk+0x1d>
f0101685:	a8 01                	test   $0x1,%al
f0101687:	75 2c                	jne    f01016b5 <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f0101689:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010168d:	74 61                	je     f01016f0 <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(1);
f010168f:	83 ec 0c             	sub    $0xc,%esp
f0101692:	6a 01                	push   $0x1
f0101694:	e8 0b ff ff ff       	call   f01015a4 <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f0101699:	83 c4 10             	add    $0x10,%esp
f010169c:	85 c0                	test   %eax,%eax
f010169e:	74 57                	je     f01016f7 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f01016a0:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016a4:	2b 05 10 ef 2d f0    	sub    0xf02def10,%eax
f01016aa:	c1 f8 03             	sar    $0x3,%eax
f01016ad:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f01016b0:	83 c8 07             	or     $0x7,%eax
f01016b3:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f01016b5:	8b 03                	mov    (%ebx),%eax
f01016b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016bc:	89 c2                	mov    %eax,%edx
f01016be:	c1 ea 0c             	shr    $0xc,%edx
f01016c1:	3b 15 08 ef 2d f0    	cmp    0xf02def08,%edx
f01016c7:	72 15                	jb     f01016de <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016c9:	50                   	push   %eax
f01016ca:	68 08 5f 10 f0       	push   $0xf0105f08
f01016cf:	68 ab 01 00 00       	push   $0x1ab
f01016d4:	68 91 72 10 f0       	push   $0xf0107291
f01016d9:	e8 8a e9 ff ff       	call   f0100068 <_panic>
f01016de:	c1 ee 0a             	shr    $0xa,%esi
f01016e1:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01016e7:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01016ee:	eb 0c                	jmp    f01016fc <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f01016f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01016f5:	eb 05                	jmp    f01016fc <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f01016f7:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f01016fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01016ff:	5b                   	pop    %ebx
f0101700:	5e                   	pop    %esi
f0101701:	c9                   	leave  
f0101702:	c3                   	ret    

f0101703 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101703:	55                   	push   %ebp
f0101704:	89 e5                	mov    %esp,%ebp
f0101706:	57                   	push   %edi
f0101707:	56                   	push   %esi
f0101708:	53                   	push   %ebx
f0101709:	83 ec 1c             	sub    $0x1c,%esp
f010170c:	89 c7                	mov    %eax,%edi
f010170e:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101711:	01 d1                	add    %edx,%ecx
f0101713:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101716:	39 ca                	cmp    %ecx,%edx
f0101718:	74 32                	je     f010174c <boot_map_region+0x49>
f010171a:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f010171c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010171f:	83 c8 01             	or     $0x1,%eax
f0101722:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f0101725:	83 ec 04             	sub    $0x4,%esp
f0101728:	6a 01                	push   $0x1
f010172a:	53                   	push   %ebx
f010172b:	57                   	push   %edi
f010172c:	e8 3b ff ff ff       	call   f010166c <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f0101731:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101734:	09 f2                	or     %esi,%edx
f0101736:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101738:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010173e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101744:	83 c4 10             	add    $0x10,%esp
f0101747:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010174a:	75 d9                	jne    f0101725 <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f010174c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010174f:	5b                   	pop    %ebx
f0101750:	5e                   	pop    %esi
f0101751:	5f                   	pop    %edi
f0101752:	c9                   	leave  
f0101753:	c3                   	ret    

f0101754 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101754:	55                   	push   %ebp
f0101755:	89 e5                	mov    %esp,%ebp
f0101757:	53                   	push   %ebx
f0101758:	83 ec 08             	sub    $0x8,%esp
f010175b:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f010175e:	6a 00                	push   $0x0
f0101760:	ff 75 0c             	pushl  0xc(%ebp)
f0101763:	ff 75 08             	pushl  0x8(%ebp)
f0101766:	e8 01 ff ff ff       	call   f010166c <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f010176b:	83 c4 10             	add    $0x10,%esp
f010176e:	85 c0                	test   %eax,%eax
f0101770:	74 37                	je     f01017a9 <page_lookup+0x55>
f0101772:	f6 00 01             	testb  $0x1,(%eax)
f0101775:	74 39                	je     f01017b0 <page_lookup+0x5c>
    if (pte_store != 0) {
f0101777:	85 db                	test   %ebx,%ebx
f0101779:	74 02                	je     f010177d <page_lookup+0x29>
        *pte_store = pte;
f010177b:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f010177d:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010177f:	c1 e8 0c             	shr    $0xc,%eax
f0101782:	3b 05 08 ef 2d f0    	cmp    0xf02def08,%eax
f0101788:	72 14                	jb     f010179e <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f010178a:	83 ec 04             	sub    $0x4,%esp
f010178d:	68 70 6a 10 f0       	push   $0xf0106a70
f0101792:	6a 51                	push   $0x51
f0101794:	68 9d 72 10 f0       	push   $0xf010729d
f0101799:	e8 ca e8 ff ff       	call   f0100068 <_panic>
	return &pages[PGNUM(pa)];
f010179e:	c1 e0 03             	shl    $0x3,%eax
f01017a1:	03 05 10 ef 2d f0    	add    0xf02def10,%eax
f01017a7:	eb 0c                	jmp    f01017b5 <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01017a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01017ae:	eb 05                	jmp    f01017b5 <page_lookup+0x61>
f01017b0:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f01017b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01017b8:	c9                   	leave  
f01017b9:	c3                   	ret    

f01017ba <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01017ba:	55                   	push   %ebp
f01017bb:	89 e5                	mov    %esp,%ebp
f01017bd:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01017c0:	e8 57 40 00 00       	call   f010581c <cpunum>
f01017c5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01017cc:	29 c2                	sub    %eax,%edx
f01017ce:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01017d1:	83 3c 85 28 f0 2d f0 	cmpl   $0x0,-0xfd20fd8(,%eax,4)
f01017d8:	00 
f01017d9:	74 20                	je     f01017fb <tlb_invalidate+0x41>
f01017db:	e8 3c 40 00 00       	call   f010581c <cpunum>
f01017e0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01017e7:	29 c2                	sub    %eax,%edx
f01017e9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01017ec:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f01017f3:	8b 55 08             	mov    0x8(%ebp),%edx
f01017f6:	39 50 60             	cmp    %edx,0x60(%eax)
f01017f9:	75 06                	jne    f0101801 <tlb_invalidate+0x47>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01017fb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017fe:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101801:	c9                   	leave  
f0101802:	c3                   	ret    

f0101803 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101803:	55                   	push   %ebp
f0101804:	89 e5                	mov    %esp,%ebp
f0101806:	56                   	push   %esi
f0101807:	53                   	push   %ebx
f0101808:	83 ec 14             	sub    $0x14,%esp
f010180b:	8b 75 08             	mov    0x8(%ebp),%esi
f010180e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f0101811:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101814:	50                   	push   %eax
f0101815:	53                   	push   %ebx
f0101816:	56                   	push   %esi
f0101817:	e8 38 ff ff ff       	call   f0101754 <page_lookup>
    if (pg == NULL) return;
f010181c:	83 c4 10             	add    $0x10,%esp
f010181f:	85 c0                	test   %eax,%eax
f0101821:	74 26                	je     f0101849 <page_remove+0x46>
    page_decref(pg);
f0101823:	83 ec 0c             	sub    $0xc,%esp
f0101826:	50                   	push   %eax
f0101827:	e8 22 fe ff ff       	call   f010164e <page_decref>
    if (pte != NULL) *pte = 0;
f010182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010182f:	83 c4 10             	add    $0x10,%esp
f0101832:	85 c0                	test   %eax,%eax
f0101834:	74 06                	je     f010183c <page_remove+0x39>
f0101836:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f010183c:	83 ec 08             	sub    $0x8,%esp
f010183f:	53                   	push   %ebx
f0101840:	56                   	push   %esi
f0101841:	e8 74 ff ff ff       	call   f01017ba <tlb_invalidate>
f0101846:	83 c4 10             	add    $0x10,%esp
}
f0101849:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010184c:	5b                   	pop    %ebx
f010184d:	5e                   	pop    %esi
f010184e:	c9                   	leave  
f010184f:	c3                   	ret    

f0101850 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101850:	55                   	push   %ebp
f0101851:	89 e5                	mov    %esp,%ebp
f0101853:	57                   	push   %edi
f0101854:	56                   	push   %esi
f0101855:	53                   	push   %ebx
f0101856:	83 ec 10             	sub    $0x10,%esp
f0101859:	8b 75 0c             	mov    0xc(%ebp),%esi
f010185c:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f010185f:	6a 01                	push   $0x1
f0101861:	57                   	push   %edi
f0101862:	ff 75 08             	pushl  0x8(%ebp)
f0101865:	e8 02 fe ff ff       	call   f010166c <pgdir_walk>
f010186a:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f010186c:	83 c4 10             	add    $0x10,%esp
f010186f:	85 c0                	test   %eax,%eax
f0101871:	74 39                	je     f01018ac <page_insert+0x5c>
    ++pp->pp_ref;
f0101873:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f0101877:	f6 00 01             	testb  $0x1,(%eax)
f010187a:	74 0f                	je     f010188b <page_insert+0x3b>
        page_remove(pgdir, va);
f010187c:	83 ec 08             	sub    $0x8,%esp
f010187f:	57                   	push   %edi
f0101880:	ff 75 08             	pushl  0x8(%ebp)
f0101883:	e8 7b ff ff ff       	call   f0101803 <page_remove>
f0101888:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f010188b:	8b 55 14             	mov    0x14(%ebp),%edx
f010188e:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101891:	2b 35 10 ef 2d f0    	sub    0xf02def10,%esi
f0101897:	c1 fe 03             	sar    $0x3,%esi
f010189a:	89 f0                	mov    %esi,%eax
f010189c:	c1 e0 0c             	shl    $0xc,%eax
f010189f:	89 d6                	mov    %edx,%esi
f01018a1:	09 c6                	or     %eax,%esi
f01018a3:	89 33                	mov    %esi,(%ebx)
	return 0;
f01018a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01018aa:	eb 05                	jmp    f01018b1 <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f01018ac:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f01018b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01018b4:	5b                   	pop    %ebx
f01018b5:	5e                   	pop    %esi
f01018b6:	5f                   	pop    %edi
f01018b7:	c9                   	leave  
f01018b8:	c3                   	ret    

f01018b9 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01018b9:	55                   	push   %ebp
f01018ba:	89 e5                	mov    %esp,%ebp
f01018bc:	83 ec 0c             	sub    $0xc,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	panic("mmio_map_region not implemented");
f01018bf:	68 90 6a 10 f0       	push   $0xf0106a90
f01018c4:	68 4e 02 00 00       	push   $0x24e
f01018c9:	68 91 72 10 f0       	push   $0xf0107291
f01018ce:	e8 95 e7 ff ff       	call   f0100068 <_panic>

f01018d3 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01018d3:	55                   	push   %ebp
f01018d4:	89 e5                	mov    %esp,%ebp
f01018d6:	57                   	push   %edi
f01018d7:	56                   	push   %esi
f01018d8:	53                   	push   %ebx
f01018d9:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01018dc:	b8 15 00 00 00       	mov    $0x15,%eax
f01018e1:	e8 ff f8 ff ff       	call   f01011e5 <nvram_read>
f01018e6:	c1 e0 0a             	shl    $0xa,%eax
f01018e9:	89 c2                	mov    %eax,%edx
f01018eb:	85 c0                	test   %eax,%eax
f01018ed:	79 06                	jns    f01018f5 <mem_init+0x22>
f01018ef:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01018f5:	c1 fa 0c             	sar    $0xc,%edx
f01018f8:	89 15 38 e2 2d f0    	mov    %edx,0xf02de238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01018fe:	b8 17 00 00 00       	mov    $0x17,%eax
f0101903:	e8 dd f8 ff ff       	call   f01011e5 <nvram_read>
f0101908:	89 c2                	mov    %eax,%edx
f010190a:	c1 e2 0a             	shl    $0xa,%edx
f010190d:	89 d0                	mov    %edx,%eax
f010190f:	85 d2                	test   %edx,%edx
f0101911:	79 06                	jns    f0101919 <mem_init+0x46>
f0101913:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101919:	c1 f8 0c             	sar    $0xc,%eax
f010191c:	74 0e                	je     f010192c <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010191e:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101924:	89 15 08 ef 2d f0    	mov    %edx,0xf02def08
f010192a:	eb 0c                	jmp    f0101938 <mem_init+0x65>
	else
		npages = npages_basemem;
f010192c:	8b 15 38 e2 2d f0    	mov    0xf02de238,%edx
f0101932:	89 15 08 ef 2d f0    	mov    %edx,0xf02def08

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101938:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010193b:	c1 e8 0a             	shr    $0xa,%eax
f010193e:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f010193f:	a1 38 e2 2d f0       	mov    0xf02de238,%eax
f0101944:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101947:	c1 e8 0a             	shr    $0xa,%eax
f010194a:	50                   	push   %eax
		npages * PGSIZE / 1024,
f010194b:	a1 08 ef 2d f0       	mov    0xf02def08,%eax
f0101950:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101953:	c1 e8 0a             	shr    $0xa,%eax
f0101956:	50                   	push   %eax
f0101957:	68 b0 6a 10 f0       	push   $0xf0106ab0
f010195c:	e8 18 23 00 00       	call   f0103c79 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101961:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101966:	e8 e1 f7 ff ff       	call   f010114c <boot_alloc>
f010196b:	a3 0c ef 2d f0       	mov    %eax,0xf02def0c
	memset(kern_pgdir, 0, PGSIZE);
f0101970:	83 c4 0c             	add    $0xc,%esp
f0101973:	68 00 10 00 00       	push   $0x1000
f0101978:	6a 00                	push   $0x0
f010197a:	50                   	push   %eax
f010197b:	e8 6d 38 00 00       	call   f01051ed <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101980:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101985:	83 c4 10             	add    $0x10,%esp
f0101988:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010198d:	77 15                	ja     f01019a4 <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010198f:	50                   	push   %eax
f0101990:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0101995:	68 90 00 00 00       	push   $0x90
f010199a:	68 91 72 10 f0       	push   $0xf0107291
f010199f:	e8 c4 e6 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01019a4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01019aa:	83 ca 05             	or     $0x5,%edx
f01019ad:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01019b3:	a1 08 ef 2d f0       	mov    0xf02def08,%eax
f01019b8:	c1 e0 03             	shl    $0x3,%eax
f01019bb:	e8 8c f7 ff ff       	call   f010114c <boot_alloc>
f01019c0:	a3 10 ef 2d f0       	mov    %eax,0xf02def10
    

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f01019c5:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01019ca:	e8 7d f7 ff ff       	call   f010114c <boot_alloc>
f01019cf:	a3 3c e2 2d f0       	mov    %eax,0xf02de23c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01019d4:	e8 1e fb ff ff       	call   f01014f7 <page_init>

	check_page_free_list(1);
f01019d9:	b8 01 00 00 00       	mov    $0x1,%eax
f01019de:	e8 29 f8 ff ff       	call   f010120c <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01019e3:	83 3d 10 ef 2d f0 00 	cmpl   $0x0,0xf02def10
f01019ea:	75 17                	jne    f0101a03 <mem_init+0x130>
		panic("'pages' is a null pointer!");
f01019ec:	83 ec 04             	sub    $0x4,%esp
f01019ef:	68 64 73 10 f0       	push   $0xf0107364
f01019f4:	68 de 02 00 00       	push   $0x2de
f01019f9:	68 91 72 10 f0       	push   $0xf0107291
f01019fe:	e8 65 e6 ff ff       	call   f0100068 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a03:	a1 30 e2 2d f0       	mov    0xf02de230,%eax
f0101a08:	85 c0                	test   %eax,%eax
f0101a0a:	74 0e                	je     f0101a1a <mem_init+0x147>
f0101a0c:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101a11:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a12:	8b 00                	mov    (%eax),%eax
f0101a14:	85 c0                	test   %eax,%eax
f0101a16:	75 f9                	jne    f0101a11 <mem_init+0x13e>
f0101a18:	eb 05                	jmp    f0101a1f <mem_init+0x14c>
f0101a1a:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a1f:	83 ec 0c             	sub    $0xc,%esp
f0101a22:	6a 00                	push   $0x0
f0101a24:	e8 7b fb ff ff       	call   f01015a4 <page_alloc>
f0101a29:	89 c6                	mov    %eax,%esi
f0101a2b:	83 c4 10             	add    $0x10,%esp
f0101a2e:	85 c0                	test   %eax,%eax
f0101a30:	75 19                	jne    f0101a4b <mem_init+0x178>
f0101a32:	68 7f 73 10 f0       	push   $0xf010737f
f0101a37:	68 b7 72 10 f0       	push   $0xf01072b7
f0101a3c:	68 e6 02 00 00       	push   $0x2e6
f0101a41:	68 91 72 10 f0       	push   $0xf0107291
f0101a46:	e8 1d e6 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a4b:	83 ec 0c             	sub    $0xc,%esp
f0101a4e:	6a 00                	push   $0x0
f0101a50:	e8 4f fb ff ff       	call   f01015a4 <page_alloc>
f0101a55:	89 c7                	mov    %eax,%edi
f0101a57:	83 c4 10             	add    $0x10,%esp
f0101a5a:	85 c0                	test   %eax,%eax
f0101a5c:	75 19                	jne    f0101a77 <mem_init+0x1a4>
f0101a5e:	68 95 73 10 f0       	push   $0xf0107395
f0101a63:	68 b7 72 10 f0       	push   $0xf01072b7
f0101a68:	68 e7 02 00 00       	push   $0x2e7
f0101a6d:	68 91 72 10 f0       	push   $0xf0107291
f0101a72:	e8 f1 e5 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a77:	83 ec 0c             	sub    $0xc,%esp
f0101a7a:	6a 00                	push   $0x0
f0101a7c:	e8 23 fb ff ff       	call   f01015a4 <page_alloc>
f0101a81:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a84:	83 c4 10             	add    $0x10,%esp
f0101a87:	85 c0                	test   %eax,%eax
f0101a89:	75 19                	jne    f0101aa4 <mem_init+0x1d1>
f0101a8b:	68 ab 73 10 f0       	push   $0xf01073ab
f0101a90:	68 b7 72 10 f0       	push   $0xf01072b7
f0101a95:	68 e8 02 00 00       	push   $0x2e8
f0101a9a:	68 91 72 10 f0       	push   $0xf0107291
f0101a9f:	e8 c4 e5 ff ff       	call   f0100068 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101aa4:	39 fe                	cmp    %edi,%esi
f0101aa6:	75 19                	jne    f0101ac1 <mem_init+0x1ee>
f0101aa8:	68 c1 73 10 f0       	push   $0xf01073c1
f0101aad:	68 b7 72 10 f0       	push   $0xf01072b7
f0101ab2:	68 eb 02 00 00       	push   $0x2eb
f0101ab7:	68 91 72 10 f0       	push   $0xf0107291
f0101abc:	e8 a7 e5 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ac1:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101ac4:	74 05                	je     f0101acb <mem_init+0x1f8>
f0101ac6:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101ac9:	75 19                	jne    f0101ae4 <mem_init+0x211>
f0101acb:	68 ec 6a 10 f0       	push   $0xf0106aec
f0101ad0:	68 b7 72 10 f0       	push   $0xf01072b7
f0101ad5:	68 ec 02 00 00       	push   $0x2ec
f0101ada:	68 91 72 10 f0       	push   $0xf0107291
f0101adf:	e8 84 e5 ff ff       	call   f0100068 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ae4:	8b 15 10 ef 2d f0    	mov    0xf02def10,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101aea:	a1 08 ef 2d f0       	mov    0xf02def08,%eax
f0101aef:	c1 e0 0c             	shl    $0xc,%eax
f0101af2:	89 f1                	mov    %esi,%ecx
f0101af4:	29 d1                	sub    %edx,%ecx
f0101af6:	c1 f9 03             	sar    $0x3,%ecx
f0101af9:	c1 e1 0c             	shl    $0xc,%ecx
f0101afc:	39 c1                	cmp    %eax,%ecx
f0101afe:	72 19                	jb     f0101b19 <mem_init+0x246>
f0101b00:	68 d3 73 10 f0       	push   $0xf01073d3
f0101b05:	68 b7 72 10 f0       	push   $0xf01072b7
f0101b0a:	68 ed 02 00 00       	push   $0x2ed
f0101b0f:	68 91 72 10 f0       	push   $0xf0107291
f0101b14:	e8 4f e5 ff ff       	call   f0100068 <_panic>
f0101b19:	89 f9                	mov    %edi,%ecx
f0101b1b:	29 d1                	sub    %edx,%ecx
f0101b1d:	c1 f9 03             	sar    $0x3,%ecx
f0101b20:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101b23:	39 c8                	cmp    %ecx,%eax
f0101b25:	77 19                	ja     f0101b40 <mem_init+0x26d>
f0101b27:	68 f0 73 10 f0       	push   $0xf01073f0
f0101b2c:	68 b7 72 10 f0       	push   $0xf01072b7
f0101b31:	68 ee 02 00 00       	push   $0x2ee
f0101b36:	68 91 72 10 f0       	push   $0xf0107291
f0101b3b:	e8 28 e5 ff ff       	call   f0100068 <_panic>
f0101b40:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b43:	29 d1                	sub    %edx,%ecx
f0101b45:	89 ca                	mov    %ecx,%edx
f0101b47:	c1 fa 03             	sar    $0x3,%edx
f0101b4a:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101b4d:	39 d0                	cmp    %edx,%eax
f0101b4f:	77 19                	ja     f0101b6a <mem_init+0x297>
f0101b51:	68 0d 74 10 f0       	push   $0xf010740d
f0101b56:	68 b7 72 10 f0       	push   $0xf01072b7
f0101b5b:	68 ef 02 00 00       	push   $0x2ef
f0101b60:	68 91 72 10 f0       	push   $0xf0107291
f0101b65:	e8 fe e4 ff ff       	call   f0100068 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b6a:	a1 30 e2 2d f0       	mov    0xf02de230,%eax
f0101b6f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b72:	c7 05 30 e2 2d f0 00 	movl   $0x0,0xf02de230
f0101b79:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b7c:	83 ec 0c             	sub    $0xc,%esp
f0101b7f:	6a 00                	push   $0x0
f0101b81:	e8 1e fa ff ff       	call   f01015a4 <page_alloc>
f0101b86:	83 c4 10             	add    $0x10,%esp
f0101b89:	85 c0                	test   %eax,%eax
f0101b8b:	74 19                	je     f0101ba6 <mem_init+0x2d3>
f0101b8d:	68 2a 74 10 f0       	push   $0xf010742a
f0101b92:	68 b7 72 10 f0       	push   $0xf01072b7
f0101b97:	68 f6 02 00 00       	push   $0x2f6
f0101b9c:	68 91 72 10 f0       	push   $0xf0107291
f0101ba1:	e8 c2 e4 ff ff       	call   f0100068 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101ba6:	83 ec 0c             	sub    $0xc,%esp
f0101ba9:	56                   	push   %esi
f0101baa:	e8 7f fa ff ff       	call   f010162e <page_free>
	page_free(pp1);
f0101baf:	89 3c 24             	mov    %edi,(%esp)
f0101bb2:	e8 77 fa ff ff       	call   f010162e <page_free>
	page_free(pp2);
f0101bb7:	83 c4 04             	add    $0x4,%esp
f0101bba:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bbd:	e8 6c fa ff ff       	call   f010162e <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101bc2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bc9:	e8 d6 f9 ff ff       	call   f01015a4 <page_alloc>
f0101bce:	89 c6                	mov    %eax,%esi
f0101bd0:	83 c4 10             	add    $0x10,%esp
f0101bd3:	85 c0                	test   %eax,%eax
f0101bd5:	75 19                	jne    f0101bf0 <mem_init+0x31d>
f0101bd7:	68 7f 73 10 f0       	push   $0xf010737f
f0101bdc:	68 b7 72 10 f0       	push   $0xf01072b7
f0101be1:	68 fd 02 00 00       	push   $0x2fd
f0101be6:	68 91 72 10 f0       	push   $0xf0107291
f0101beb:	e8 78 e4 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101bf0:	83 ec 0c             	sub    $0xc,%esp
f0101bf3:	6a 00                	push   $0x0
f0101bf5:	e8 aa f9 ff ff       	call   f01015a4 <page_alloc>
f0101bfa:	89 c7                	mov    %eax,%edi
f0101bfc:	83 c4 10             	add    $0x10,%esp
f0101bff:	85 c0                	test   %eax,%eax
f0101c01:	75 19                	jne    f0101c1c <mem_init+0x349>
f0101c03:	68 95 73 10 f0       	push   $0xf0107395
f0101c08:	68 b7 72 10 f0       	push   $0xf01072b7
f0101c0d:	68 fe 02 00 00       	push   $0x2fe
f0101c12:	68 91 72 10 f0       	push   $0xf0107291
f0101c17:	e8 4c e4 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c1c:	83 ec 0c             	sub    $0xc,%esp
f0101c1f:	6a 00                	push   $0x0
f0101c21:	e8 7e f9 ff ff       	call   f01015a4 <page_alloc>
f0101c26:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c29:	83 c4 10             	add    $0x10,%esp
f0101c2c:	85 c0                	test   %eax,%eax
f0101c2e:	75 19                	jne    f0101c49 <mem_init+0x376>
f0101c30:	68 ab 73 10 f0       	push   $0xf01073ab
f0101c35:	68 b7 72 10 f0       	push   $0xf01072b7
f0101c3a:	68 ff 02 00 00       	push   $0x2ff
f0101c3f:	68 91 72 10 f0       	push   $0xf0107291
f0101c44:	e8 1f e4 ff ff       	call   f0100068 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c49:	39 fe                	cmp    %edi,%esi
f0101c4b:	75 19                	jne    f0101c66 <mem_init+0x393>
f0101c4d:	68 c1 73 10 f0       	push   $0xf01073c1
f0101c52:	68 b7 72 10 f0       	push   $0xf01072b7
f0101c57:	68 01 03 00 00       	push   $0x301
f0101c5c:	68 91 72 10 f0       	push   $0xf0107291
f0101c61:	e8 02 e4 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c66:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101c69:	74 05                	je     f0101c70 <mem_init+0x39d>
f0101c6b:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101c6e:	75 19                	jne    f0101c89 <mem_init+0x3b6>
f0101c70:	68 ec 6a 10 f0       	push   $0xf0106aec
f0101c75:	68 b7 72 10 f0       	push   $0xf01072b7
f0101c7a:	68 02 03 00 00       	push   $0x302
f0101c7f:	68 91 72 10 f0       	push   $0xf0107291
f0101c84:	e8 df e3 ff ff       	call   f0100068 <_panic>
	assert(!page_alloc(0));
f0101c89:	83 ec 0c             	sub    $0xc,%esp
f0101c8c:	6a 00                	push   $0x0
f0101c8e:	e8 11 f9 ff ff       	call   f01015a4 <page_alloc>
f0101c93:	83 c4 10             	add    $0x10,%esp
f0101c96:	85 c0                	test   %eax,%eax
f0101c98:	74 19                	je     f0101cb3 <mem_init+0x3e0>
f0101c9a:	68 2a 74 10 f0       	push   $0xf010742a
f0101c9f:	68 b7 72 10 f0       	push   $0xf01072b7
f0101ca4:	68 03 03 00 00       	push   $0x303
f0101ca9:	68 91 72 10 f0       	push   $0xf0107291
f0101cae:	e8 b5 e3 ff ff       	call   f0100068 <_panic>
f0101cb3:	89 f0                	mov    %esi,%eax
f0101cb5:	2b 05 10 ef 2d f0    	sub    0xf02def10,%eax
f0101cbb:	c1 f8 03             	sar    $0x3,%eax
f0101cbe:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101cc1:	89 c2                	mov    %eax,%edx
f0101cc3:	c1 ea 0c             	shr    $0xc,%edx
f0101cc6:	3b 15 08 ef 2d f0    	cmp    0xf02def08,%edx
f0101ccc:	72 12                	jb     f0101ce0 <mem_init+0x40d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101cce:	50                   	push   %eax
f0101ccf:	68 08 5f 10 f0       	push   $0xf0105f08
f0101cd4:	6a 58                	push   $0x58
f0101cd6:	68 9d 72 10 f0       	push   $0xf010729d
f0101cdb:	e8 88 e3 ff ff       	call   f0100068 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101ce0:	83 ec 04             	sub    $0x4,%esp
f0101ce3:	68 00 10 00 00       	push   $0x1000
f0101ce8:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101cea:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cef:	50                   	push   %eax
f0101cf0:	e8 f8 34 00 00       	call   f01051ed <memset>
	page_free(pp0);
f0101cf5:	89 34 24             	mov    %esi,(%esp)
f0101cf8:	e8 31 f9 ff ff       	call   f010162e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101cfd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101d04:	e8 9b f8 ff ff       	call   f01015a4 <page_alloc>
f0101d09:	83 c4 10             	add    $0x10,%esp
f0101d0c:	85 c0                	test   %eax,%eax
f0101d0e:	75 19                	jne    f0101d29 <mem_init+0x456>
f0101d10:	68 39 74 10 f0       	push   $0xf0107439
f0101d15:	68 b7 72 10 f0       	push   $0xf01072b7
f0101d1a:	68 08 03 00 00       	push   $0x308
f0101d1f:	68 91 72 10 f0       	push   $0xf0107291
f0101d24:	e8 3f e3 ff ff       	call   f0100068 <_panic>
	assert(pp && pp0 == pp);
f0101d29:	39 c6                	cmp    %eax,%esi
f0101d2b:	74 19                	je     f0101d46 <mem_init+0x473>
f0101d2d:	68 57 74 10 f0       	push   $0xf0107457
f0101d32:	68 b7 72 10 f0       	push   $0xf01072b7
f0101d37:	68 09 03 00 00       	push   $0x309
f0101d3c:	68 91 72 10 f0       	push   $0xf0107291
f0101d41:	e8 22 e3 ff ff       	call   f0100068 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d46:	89 f2                	mov    %esi,%edx
f0101d48:	2b 15 10 ef 2d f0    	sub    0xf02def10,%edx
f0101d4e:	c1 fa 03             	sar    $0x3,%edx
f0101d51:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d54:	89 d0                	mov    %edx,%eax
f0101d56:	c1 e8 0c             	shr    $0xc,%eax
f0101d59:	3b 05 08 ef 2d f0    	cmp    0xf02def08,%eax
f0101d5f:	72 12                	jb     f0101d73 <mem_init+0x4a0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d61:	52                   	push   %edx
f0101d62:	68 08 5f 10 f0       	push   $0xf0105f08
f0101d67:	6a 58                	push   $0x58
f0101d69:	68 9d 72 10 f0       	push   $0xf010729d
f0101d6e:	e8 f5 e2 ff ff       	call   f0100068 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101d73:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101d7a:	75 11                	jne    f0101d8d <mem_init+0x4ba>
f0101d7c:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101d82:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101d88:	80 38 00             	cmpb   $0x0,(%eax)
f0101d8b:	74 19                	je     f0101da6 <mem_init+0x4d3>
f0101d8d:	68 67 74 10 f0       	push   $0xf0107467
f0101d92:	68 b7 72 10 f0       	push   $0xf01072b7
f0101d97:	68 0c 03 00 00       	push   $0x30c
f0101d9c:	68 91 72 10 f0       	push   $0xf0107291
f0101da1:	e8 c2 e2 ff ff       	call   f0100068 <_panic>
f0101da6:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101da7:	39 d0                	cmp    %edx,%eax
f0101da9:	75 dd                	jne    f0101d88 <mem_init+0x4b5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101dab:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101dae:	89 15 30 e2 2d f0    	mov    %edx,0xf02de230

	// free the pages we took
	page_free(pp0);
f0101db4:	83 ec 0c             	sub    $0xc,%esp
f0101db7:	56                   	push   %esi
f0101db8:	e8 71 f8 ff ff       	call   f010162e <page_free>
	page_free(pp1);
f0101dbd:	89 3c 24             	mov    %edi,(%esp)
f0101dc0:	e8 69 f8 ff ff       	call   f010162e <page_free>
	page_free(pp2);
f0101dc5:	83 c4 04             	add    $0x4,%esp
f0101dc8:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101dcb:	e8 5e f8 ff ff       	call   f010162e <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101dd0:	a1 30 e2 2d f0       	mov    0xf02de230,%eax
f0101dd5:	83 c4 10             	add    $0x10,%esp
f0101dd8:	85 c0                	test   %eax,%eax
f0101dda:	74 07                	je     f0101de3 <mem_init+0x510>
		--nfree;
f0101ddc:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ddd:	8b 00                	mov    (%eax),%eax
f0101ddf:	85 c0                	test   %eax,%eax
f0101de1:	75 f9                	jne    f0101ddc <mem_init+0x509>
		--nfree;
	assert(nfree == 0);
f0101de3:	85 db                	test   %ebx,%ebx
f0101de5:	74 19                	je     f0101e00 <mem_init+0x52d>
f0101de7:	68 71 74 10 f0       	push   $0xf0107471
f0101dec:	68 b7 72 10 f0       	push   $0xf01072b7
f0101df1:	68 19 03 00 00       	push   $0x319
f0101df6:	68 91 72 10 f0       	push   $0xf0107291
f0101dfb:	e8 68 e2 ff ff       	call   f0100068 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101e00:	83 ec 0c             	sub    $0xc,%esp
f0101e03:	68 0c 6b 10 f0       	push   $0xf0106b0c
f0101e08:	e8 6c 1e 00 00       	call   f0103c79 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101e0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e14:	e8 8b f7 ff ff       	call   f01015a4 <page_alloc>
f0101e19:	89 c7                	mov    %eax,%edi
f0101e1b:	83 c4 10             	add    $0x10,%esp
f0101e1e:	85 c0                	test   %eax,%eax
f0101e20:	75 19                	jne    f0101e3b <mem_init+0x568>
f0101e22:	68 7f 73 10 f0       	push   $0xf010737f
f0101e27:	68 b7 72 10 f0       	push   $0xf01072b7
f0101e2c:	68 7f 03 00 00       	push   $0x37f
f0101e31:	68 91 72 10 f0       	push   $0xf0107291
f0101e36:	e8 2d e2 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0101e3b:	83 ec 0c             	sub    $0xc,%esp
f0101e3e:	6a 00                	push   $0x0
f0101e40:	e8 5f f7 ff ff       	call   f01015a4 <page_alloc>
f0101e45:	89 c6                	mov    %eax,%esi
f0101e47:	83 c4 10             	add    $0x10,%esp
f0101e4a:	85 c0                	test   %eax,%eax
f0101e4c:	75 19                	jne    f0101e67 <mem_init+0x594>
f0101e4e:	68 95 73 10 f0       	push   $0xf0107395
f0101e53:	68 b7 72 10 f0       	push   $0xf01072b7
f0101e58:	68 80 03 00 00       	push   $0x380
f0101e5d:	68 91 72 10 f0       	push   $0xf0107291
f0101e62:	e8 01 e2 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0101e67:	83 ec 0c             	sub    $0xc,%esp
f0101e6a:	6a 00                	push   $0x0
f0101e6c:	e8 33 f7 ff ff       	call   f01015a4 <page_alloc>
f0101e71:	89 c3                	mov    %eax,%ebx
f0101e73:	83 c4 10             	add    $0x10,%esp
f0101e76:	85 c0                	test   %eax,%eax
f0101e78:	75 19                	jne    f0101e93 <mem_init+0x5c0>
f0101e7a:	68 ab 73 10 f0       	push   $0xf01073ab
f0101e7f:	68 b7 72 10 f0       	push   $0xf01072b7
f0101e84:	68 81 03 00 00       	push   $0x381
f0101e89:	68 91 72 10 f0       	push   $0xf0107291
f0101e8e:	e8 d5 e1 ff ff       	call   f0100068 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101e93:	39 f7                	cmp    %esi,%edi
f0101e95:	75 19                	jne    f0101eb0 <mem_init+0x5dd>
f0101e97:	68 c1 73 10 f0       	push   $0xf01073c1
f0101e9c:	68 b7 72 10 f0       	push   $0xf01072b7
f0101ea1:	68 84 03 00 00       	push   $0x384
f0101ea6:	68 91 72 10 f0       	push   $0xf0107291
f0101eab:	e8 b8 e1 ff ff       	call   f0100068 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101eb0:	39 c6                	cmp    %eax,%esi
f0101eb2:	74 04                	je     f0101eb8 <mem_init+0x5e5>
f0101eb4:	39 c7                	cmp    %eax,%edi
f0101eb6:	75 19                	jne    f0101ed1 <mem_init+0x5fe>
f0101eb8:	68 ec 6a 10 f0       	push   $0xf0106aec
f0101ebd:	68 b7 72 10 f0       	push   $0xf01072b7
f0101ec2:	68 85 03 00 00       	push   $0x385
f0101ec7:	68 91 72 10 f0       	push   $0xf0107291
f0101ecc:	e8 97 e1 ff ff       	call   f0100068 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ed1:	8b 0d 30 e2 2d f0    	mov    0xf02de230,%ecx
f0101ed7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101eda:	c7 05 30 e2 2d f0 00 	movl   $0x0,0xf02de230
f0101ee1:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ee4:	83 ec 0c             	sub    $0xc,%esp
f0101ee7:	6a 00                	push   $0x0
f0101ee9:	e8 b6 f6 ff ff       	call   f01015a4 <page_alloc>
f0101eee:	83 c4 10             	add    $0x10,%esp
f0101ef1:	85 c0                	test   %eax,%eax
f0101ef3:	74 19                	je     f0101f0e <mem_init+0x63b>
f0101ef5:	68 2a 74 10 f0       	push   $0xf010742a
f0101efa:	68 b7 72 10 f0       	push   $0xf01072b7
f0101eff:	68 8c 03 00 00       	push   $0x38c
f0101f04:	68 91 72 10 f0       	push   $0xf0107291
f0101f09:	e8 5a e1 ff ff       	call   f0100068 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101f0e:	83 ec 04             	sub    $0x4,%esp
f0101f11:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101f14:	50                   	push   %eax
f0101f15:	6a 00                	push   $0x0
f0101f17:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0101f1d:	e8 32 f8 ff ff       	call   f0101754 <page_lookup>
f0101f22:	83 c4 10             	add    $0x10,%esp
f0101f25:	85 c0                	test   %eax,%eax
f0101f27:	74 19                	je     f0101f42 <mem_init+0x66f>
f0101f29:	68 2c 6b 10 f0       	push   $0xf0106b2c
f0101f2e:	68 b7 72 10 f0       	push   $0xf01072b7
f0101f33:	68 8f 03 00 00       	push   $0x38f
f0101f38:	68 91 72 10 f0       	push   $0xf0107291
f0101f3d:	e8 26 e1 ff ff       	call   f0100068 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101f42:	6a 02                	push   $0x2
f0101f44:	6a 00                	push   $0x0
f0101f46:	56                   	push   %esi
f0101f47:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0101f4d:	e8 fe f8 ff ff       	call   f0101850 <page_insert>
f0101f52:	83 c4 10             	add    $0x10,%esp
f0101f55:	85 c0                	test   %eax,%eax
f0101f57:	78 19                	js     f0101f72 <mem_init+0x69f>
f0101f59:	68 64 6b 10 f0       	push   $0xf0106b64
f0101f5e:	68 b7 72 10 f0       	push   $0xf01072b7
f0101f63:	68 92 03 00 00       	push   $0x392
f0101f68:	68 91 72 10 f0       	push   $0xf0107291
f0101f6d:	e8 f6 e0 ff ff       	call   f0100068 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101f72:	83 ec 0c             	sub    $0xc,%esp
f0101f75:	57                   	push   %edi
f0101f76:	e8 b3 f6 ff ff       	call   f010162e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101f7b:	6a 02                	push   $0x2
f0101f7d:	6a 00                	push   $0x0
f0101f7f:	56                   	push   %esi
f0101f80:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0101f86:	e8 c5 f8 ff ff       	call   f0101850 <page_insert>
f0101f8b:	83 c4 20             	add    $0x20,%esp
f0101f8e:	85 c0                	test   %eax,%eax
f0101f90:	74 19                	je     f0101fab <mem_init+0x6d8>
f0101f92:	68 94 6b 10 f0       	push   $0xf0106b94
f0101f97:	68 b7 72 10 f0       	push   $0xf01072b7
f0101f9c:	68 96 03 00 00       	push   $0x396
f0101fa1:	68 91 72 10 f0       	push   $0xf0107291
f0101fa6:	e8 bd e0 ff ff       	call   f0100068 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101fab:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0101fb0:	8b 08                	mov    (%eax),%ecx
f0101fb2:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fb8:	89 fa                	mov    %edi,%edx
f0101fba:	2b 15 10 ef 2d f0    	sub    0xf02def10,%edx
f0101fc0:	c1 fa 03             	sar    $0x3,%edx
f0101fc3:	c1 e2 0c             	shl    $0xc,%edx
f0101fc6:	39 d1                	cmp    %edx,%ecx
f0101fc8:	74 19                	je     f0101fe3 <mem_init+0x710>
f0101fca:	68 c4 6b 10 f0       	push   $0xf0106bc4
f0101fcf:	68 b7 72 10 f0       	push   $0xf01072b7
f0101fd4:	68 97 03 00 00       	push   $0x397
f0101fd9:	68 91 72 10 f0       	push   $0xf0107291
f0101fde:	e8 85 e0 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101fe3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fe8:	e8 96 f1 ff ff       	call   f0101183 <check_va2pa>
f0101fed:	89 f2                	mov    %esi,%edx
f0101fef:	2b 15 10 ef 2d f0    	sub    0xf02def10,%edx
f0101ff5:	c1 fa 03             	sar    $0x3,%edx
f0101ff8:	c1 e2 0c             	shl    $0xc,%edx
f0101ffb:	39 d0                	cmp    %edx,%eax
f0101ffd:	74 19                	je     f0102018 <mem_init+0x745>
f0101fff:	68 ec 6b 10 f0       	push   $0xf0106bec
f0102004:	68 b7 72 10 f0       	push   $0xf01072b7
f0102009:	68 98 03 00 00       	push   $0x398
f010200e:	68 91 72 10 f0       	push   $0xf0107291
f0102013:	e8 50 e0 ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 1);
f0102018:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010201d:	74 19                	je     f0102038 <mem_init+0x765>
f010201f:	68 7c 74 10 f0       	push   $0xf010747c
f0102024:	68 b7 72 10 f0       	push   $0xf01072b7
f0102029:	68 99 03 00 00       	push   $0x399
f010202e:	68 91 72 10 f0       	push   $0xf0107291
f0102033:	e8 30 e0 ff ff       	call   f0100068 <_panic>
	assert(pp0->pp_ref == 1);
f0102038:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010203d:	74 19                	je     f0102058 <mem_init+0x785>
f010203f:	68 8d 74 10 f0       	push   $0xf010748d
f0102044:	68 b7 72 10 f0       	push   $0xf01072b7
f0102049:	68 9a 03 00 00       	push   $0x39a
f010204e:	68 91 72 10 f0       	push   $0xf0107291
f0102053:	e8 10 e0 ff ff       	call   f0100068 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102058:	6a 02                	push   $0x2
f010205a:	68 00 10 00 00       	push   $0x1000
f010205f:	53                   	push   %ebx
f0102060:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0102066:	e8 e5 f7 ff ff       	call   f0101850 <page_insert>
f010206b:	83 c4 10             	add    $0x10,%esp
f010206e:	85 c0                	test   %eax,%eax
f0102070:	74 19                	je     f010208b <mem_init+0x7b8>
f0102072:	68 1c 6c 10 f0       	push   $0xf0106c1c
f0102077:	68 b7 72 10 f0       	push   $0xf01072b7
f010207c:	68 9d 03 00 00       	push   $0x39d
f0102081:	68 91 72 10 f0       	push   $0xf0107291
f0102086:	e8 dd df ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010208b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102090:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102095:	e8 e9 f0 ff ff       	call   f0101183 <check_va2pa>
f010209a:	89 da                	mov    %ebx,%edx
f010209c:	2b 15 10 ef 2d f0    	sub    0xf02def10,%edx
f01020a2:	c1 fa 03             	sar    $0x3,%edx
f01020a5:	c1 e2 0c             	shl    $0xc,%edx
f01020a8:	39 d0                	cmp    %edx,%eax
f01020aa:	74 19                	je     f01020c5 <mem_init+0x7f2>
f01020ac:	68 58 6c 10 f0       	push   $0xf0106c58
f01020b1:	68 b7 72 10 f0       	push   $0xf01072b7
f01020b6:	68 9e 03 00 00       	push   $0x39e
f01020bb:	68 91 72 10 f0       	push   $0xf0107291
f01020c0:	e8 a3 df ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f01020c5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020ca:	74 19                	je     f01020e5 <mem_init+0x812>
f01020cc:	68 9e 74 10 f0       	push   $0xf010749e
f01020d1:	68 b7 72 10 f0       	push   $0xf01072b7
f01020d6:	68 9f 03 00 00       	push   $0x39f
f01020db:	68 91 72 10 f0       	push   $0xf0107291
f01020e0:	e8 83 df ff ff       	call   f0100068 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01020e5:	83 ec 0c             	sub    $0xc,%esp
f01020e8:	6a 00                	push   $0x0
f01020ea:	e8 b5 f4 ff ff       	call   f01015a4 <page_alloc>
f01020ef:	83 c4 10             	add    $0x10,%esp
f01020f2:	85 c0                	test   %eax,%eax
f01020f4:	74 19                	je     f010210f <mem_init+0x83c>
f01020f6:	68 2a 74 10 f0       	push   $0xf010742a
f01020fb:	68 b7 72 10 f0       	push   $0xf01072b7
f0102100:	68 a2 03 00 00       	push   $0x3a2
f0102105:	68 91 72 10 f0       	push   $0xf0107291
f010210a:	e8 59 df ff ff       	call   f0100068 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010210f:	6a 02                	push   $0x2
f0102111:	68 00 10 00 00       	push   $0x1000
f0102116:	53                   	push   %ebx
f0102117:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f010211d:	e8 2e f7 ff ff       	call   f0101850 <page_insert>
f0102122:	83 c4 10             	add    $0x10,%esp
f0102125:	85 c0                	test   %eax,%eax
f0102127:	74 19                	je     f0102142 <mem_init+0x86f>
f0102129:	68 1c 6c 10 f0       	push   $0xf0106c1c
f010212e:	68 b7 72 10 f0       	push   $0xf01072b7
f0102133:	68 a5 03 00 00       	push   $0x3a5
f0102138:	68 91 72 10 f0       	push   $0xf0107291
f010213d:	e8 26 df ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102142:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102147:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f010214c:	e8 32 f0 ff ff       	call   f0101183 <check_va2pa>
f0102151:	89 da                	mov    %ebx,%edx
f0102153:	2b 15 10 ef 2d f0    	sub    0xf02def10,%edx
f0102159:	c1 fa 03             	sar    $0x3,%edx
f010215c:	c1 e2 0c             	shl    $0xc,%edx
f010215f:	39 d0                	cmp    %edx,%eax
f0102161:	74 19                	je     f010217c <mem_init+0x8a9>
f0102163:	68 58 6c 10 f0       	push   $0xf0106c58
f0102168:	68 b7 72 10 f0       	push   $0xf01072b7
f010216d:	68 a6 03 00 00       	push   $0x3a6
f0102172:	68 91 72 10 f0       	push   $0xf0107291
f0102177:	e8 ec de ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f010217c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102181:	74 19                	je     f010219c <mem_init+0x8c9>
f0102183:	68 9e 74 10 f0       	push   $0xf010749e
f0102188:	68 b7 72 10 f0       	push   $0xf01072b7
f010218d:	68 a7 03 00 00       	push   $0x3a7
f0102192:	68 91 72 10 f0       	push   $0xf0107291
f0102197:	e8 cc de ff ff       	call   f0100068 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010219c:	83 ec 0c             	sub    $0xc,%esp
f010219f:	6a 00                	push   $0x0
f01021a1:	e8 fe f3 ff ff       	call   f01015a4 <page_alloc>
f01021a6:	83 c4 10             	add    $0x10,%esp
f01021a9:	85 c0                	test   %eax,%eax
f01021ab:	74 19                	je     f01021c6 <mem_init+0x8f3>
f01021ad:	68 2a 74 10 f0       	push   $0xf010742a
f01021b2:	68 b7 72 10 f0       	push   $0xf01072b7
f01021b7:	68 ab 03 00 00       	push   $0x3ab
f01021bc:	68 91 72 10 f0       	push   $0xf0107291
f01021c1:	e8 a2 de ff ff       	call   f0100068 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01021c6:	8b 15 0c ef 2d f0    	mov    0xf02def0c,%edx
f01021cc:	8b 02                	mov    (%edx),%eax
f01021ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021d3:	89 c1                	mov    %eax,%ecx
f01021d5:	c1 e9 0c             	shr    $0xc,%ecx
f01021d8:	3b 0d 08 ef 2d f0    	cmp    0xf02def08,%ecx
f01021de:	72 15                	jb     f01021f5 <mem_init+0x922>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021e0:	50                   	push   %eax
f01021e1:	68 08 5f 10 f0       	push   $0xf0105f08
f01021e6:	68 ae 03 00 00       	push   $0x3ae
f01021eb:	68 91 72 10 f0       	push   $0xf0107291
f01021f0:	e8 73 de ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f01021f5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01021fd:	83 ec 04             	sub    $0x4,%esp
f0102200:	6a 00                	push   $0x0
f0102202:	68 00 10 00 00       	push   $0x1000
f0102207:	52                   	push   %edx
f0102208:	e8 5f f4 ff ff       	call   f010166c <pgdir_walk>
f010220d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102210:	83 c2 04             	add    $0x4,%edx
f0102213:	83 c4 10             	add    $0x10,%esp
f0102216:	39 d0                	cmp    %edx,%eax
f0102218:	74 19                	je     f0102233 <mem_init+0x960>
f010221a:	68 88 6c 10 f0       	push   $0xf0106c88
f010221f:	68 b7 72 10 f0       	push   $0xf01072b7
f0102224:	68 af 03 00 00       	push   $0x3af
f0102229:	68 91 72 10 f0       	push   $0xf0107291
f010222e:	e8 35 de ff ff       	call   f0100068 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102233:	6a 06                	push   $0x6
f0102235:	68 00 10 00 00       	push   $0x1000
f010223a:	53                   	push   %ebx
f010223b:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0102241:	e8 0a f6 ff ff       	call   f0101850 <page_insert>
f0102246:	83 c4 10             	add    $0x10,%esp
f0102249:	85 c0                	test   %eax,%eax
f010224b:	74 19                	je     f0102266 <mem_init+0x993>
f010224d:	68 c8 6c 10 f0       	push   $0xf0106cc8
f0102252:	68 b7 72 10 f0       	push   $0xf01072b7
f0102257:	68 b2 03 00 00       	push   $0x3b2
f010225c:	68 91 72 10 f0       	push   $0xf0107291
f0102261:	e8 02 de ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102266:	ba 00 10 00 00       	mov    $0x1000,%edx
f010226b:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102270:	e8 0e ef ff ff       	call   f0101183 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102275:	89 da                	mov    %ebx,%edx
f0102277:	2b 15 10 ef 2d f0    	sub    0xf02def10,%edx
f010227d:	c1 fa 03             	sar    $0x3,%edx
f0102280:	c1 e2 0c             	shl    $0xc,%edx
f0102283:	39 d0                	cmp    %edx,%eax
f0102285:	74 19                	je     f01022a0 <mem_init+0x9cd>
f0102287:	68 58 6c 10 f0       	push   $0xf0106c58
f010228c:	68 b7 72 10 f0       	push   $0xf01072b7
f0102291:	68 b3 03 00 00       	push   $0x3b3
f0102296:	68 91 72 10 f0       	push   $0xf0107291
f010229b:	e8 c8 dd ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f01022a0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01022a5:	74 19                	je     f01022c0 <mem_init+0x9ed>
f01022a7:	68 9e 74 10 f0       	push   $0xf010749e
f01022ac:	68 b7 72 10 f0       	push   $0xf01072b7
f01022b1:	68 b4 03 00 00       	push   $0x3b4
f01022b6:	68 91 72 10 f0       	push   $0xf0107291
f01022bb:	e8 a8 dd ff ff       	call   f0100068 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01022c0:	83 ec 04             	sub    $0x4,%esp
f01022c3:	6a 00                	push   $0x0
f01022c5:	68 00 10 00 00       	push   $0x1000
f01022ca:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f01022d0:	e8 97 f3 ff ff       	call   f010166c <pgdir_walk>
f01022d5:	83 c4 10             	add    $0x10,%esp
f01022d8:	f6 00 04             	testb  $0x4,(%eax)
f01022db:	75 19                	jne    f01022f6 <mem_init+0xa23>
f01022dd:	68 08 6d 10 f0       	push   $0xf0106d08
f01022e2:	68 b7 72 10 f0       	push   $0xf01072b7
f01022e7:	68 b5 03 00 00       	push   $0x3b5
f01022ec:	68 91 72 10 f0       	push   $0xf0107291
f01022f1:	e8 72 dd ff ff       	call   f0100068 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01022f6:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f01022fb:	f6 00 04             	testb  $0x4,(%eax)
f01022fe:	75 19                	jne    f0102319 <mem_init+0xa46>
f0102300:	68 af 74 10 f0       	push   $0xf01074af
f0102305:	68 b7 72 10 f0       	push   $0xf01072b7
f010230a:	68 b6 03 00 00       	push   $0x3b6
f010230f:	68 91 72 10 f0       	push   $0xf0107291
f0102314:	e8 4f dd ff ff       	call   f0100068 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102319:	6a 02                	push   $0x2
f010231b:	68 00 10 00 00       	push   $0x1000
f0102320:	53                   	push   %ebx
f0102321:	50                   	push   %eax
f0102322:	e8 29 f5 ff ff       	call   f0101850 <page_insert>
f0102327:	83 c4 10             	add    $0x10,%esp
f010232a:	85 c0                	test   %eax,%eax
f010232c:	74 19                	je     f0102347 <mem_init+0xa74>
f010232e:	68 1c 6c 10 f0       	push   $0xf0106c1c
f0102333:	68 b7 72 10 f0       	push   $0xf01072b7
f0102338:	68 b9 03 00 00       	push   $0x3b9
f010233d:	68 91 72 10 f0       	push   $0xf0107291
f0102342:	e8 21 dd ff ff       	call   f0100068 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102347:	83 ec 04             	sub    $0x4,%esp
f010234a:	6a 00                	push   $0x0
f010234c:	68 00 10 00 00       	push   $0x1000
f0102351:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0102357:	e8 10 f3 ff ff       	call   f010166c <pgdir_walk>
f010235c:	83 c4 10             	add    $0x10,%esp
f010235f:	f6 00 02             	testb  $0x2,(%eax)
f0102362:	75 19                	jne    f010237d <mem_init+0xaaa>
f0102364:	68 3c 6d 10 f0       	push   $0xf0106d3c
f0102369:	68 b7 72 10 f0       	push   $0xf01072b7
f010236e:	68 ba 03 00 00       	push   $0x3ba
f0102373:	68 91 72 10 f0       	push   $0xf0107291
f0102378:	e8 eb dc ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010237d:	83 ec 04             	sub    $0x4,%esp
f0102380:	6a 00                	push   $0x0
f0102382:	68 00 10 00 00       	push   $0x1000
f0102387:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f010238d:	e8 da f2 ff ff       	call   f010166c <pgdir_walk>
f0102392:	83 c4 10             	add    $0x10,%esp
f0102395:	f6 00 04             	testb  $0x4,(%eax)
f0102398:	74 19                	je     f01023b3 <mem_init+0xae0>
f010239a:	68 70 6d 10 f0       	push   $0xf0106d70
f010239f:	68 b7 72 10 f0       	push   $0xf01072b7
f01023a4:	68 bb 03 00 00       	push   $0x3bb
f01023a9:	68 91 72 10 f0       	push   $0xf0107291
f01023ae:	e8 b5 dc ff ff       	call   f0100068 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01023b3:	6a 02                	push   $0x2
f01023b5:	68 00 00 40 00       	push   $0x400000
f01023ba:	57                   	push   %edi
f01023bb:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f01023c1:	e8 8a f4 ff ff       	call   f0101850 <page_insert>
f01023c6:	83 c4 10             	add    $0x10,%esp
f01023c9:	85 c0                	test   %eax,%eax
f01023cb:	78 19                	js     f01023e6 <mem_init+0xb13>
f01023cd:	68 a8 6d 10 f0       	push   $0xf0106da8
f01023d2:	68 b7 72 10 f0       	push   $0xf01072b7
f01023d7:	68 be 03 00 00       	push   $0x3be
f01023dc:	68 91 72 10 f0       	push   $0xf0107291
f01023e1:	e8 82 dc ff ff       	call   f0100068 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01023e6:	6a 02                	push   $0x2
f01023e8:	68 00 10 00 00       	push   $0x1000
f01023ed:	56                   	push   %esi
f01023ee:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f01023f4:	e8 57 f4 ff ff       	call   f0101850 <page_insert>
f01023f9:	83 c4 10             	add    $0x10,%esp
f01023fc:	85 c0                	test   %eax,%eax
f01023fe:	74 19                	je     f0102419 <mem_init+0xb46>
f0102400:	68 e0 6d 10 f0       	push   $0xf0106de0
f0102405:	68 b7 72 10 f0       	push   $0xf01072b7
f010240a:	68 c1 03 00 00       	push   $0x3c1
f010240f:	68 91 72 10 f0       	push   $0xf0107291
f0102414:	e8 4f dc ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102419:	83 ec 04             	sub    $0x4,%esp
f010241c:	6a 00                	push   $0x0
f010241e:	68 00 10 00 00       	push   $0x1000
f0102423:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0102429:	e8 3e f2 ff ff       	call   f010166c <pgdir_walk>
f010242e:	83 c4 10             	add    $0x10,%esp
f0102431:	f6 00 04             	testb  $0x4,(%eax)
f0102434:	74 19                	je     f010244f <mem_init+0xb7c>
f0102436:	68 70 6d 10 f0       	push   $0xf0106d70
f010243b:	68 b7 72 10 f0       	push   $0xf01072b7
f0102440:	68 c2 03 00 00       	push   $0x3c2
f0102445:	68 91 72 10 f0       	push   $0xf0107291
f010244a:	e8 19 dc ff ff       	call   f0100068 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010244f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102454:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102459:	e8 25 ed ff ff       	call   f0101183 <check_va2pa>
f010245e:	89 f2                	mov    %esi,%edx
f0102460:	2b 15 10 ef 2d f0    	sub    0xf02def10,%edx
f0102466:	c1 fa 03             	sar    $0x3,%edx
f0102469:	c1 e2 0c             	shl    $0xc,%edx
f010246c:	39 d0                	cmp    %edx,%eax
f010246e:	74 19                	je     f0102489 <mem_init+0xbb6>
f0102470:	68 1c 6e 10 f0       	push   $0xf0106e1c
f0102475:	68 b7 72 10 f0       	push   $0xf01072b7
f010247a:	68 c5 03 00 00       	push   $0x3c5
f010247f:	68 91 72 10 f0       	push   $0xf0107291
f0102484:	e8 df db ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102489:	ba 00 10 00 00       	mov    $0x1000,%edx
f010248e:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102493:	e8 eb ec ff ff       	call   f0101183 <check_va2pa>
f0102498:	89 f2                	mov    %esi,%edx
f010249a:	2b 15 10 ef 2d f0    	sub    0xf02def10,%edx
f01024a0:	c1 fa 03             	sar    $0x3,%edx
f01024a3:	c1 e2 0c             	shl    $0xc,%edx
f01024a6:	39 d0                	cmp    %edx,%eax
f01024a8:	74 19                	je     f01024c3 <mem_init+0xbf0>
f01024aa:	68 48 6e 10 f0       	push   $0xf0106e48
f01024af:	68 b7 72 10 f0       	push   $0xf01072b7
f01024b4:	68 c6 03 00 00       	push   $0x3c6
f01024b9:	68 91 72 10 f0       	push   $0xf0107291
f01024be:	e8 a5 db ff ff       	call   f0100068 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01024c3:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f01024c8:	74 19                	je     f01024e3 <mem_init+0xc10>
f01024ca:	68 c5 74 10 f0       	push   $0xf01074c5
f01024cf:	68 b7 72 10 f0       	push   $0xf01072b7
f01024d4:	68 c8 03 00 00       	push   $0x3c8
f01024d9:	68 91 72 10 f0       	push   $0xf0107291
f01024de:	e8 85 db ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f01024e3:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024e8:	74 19                	je     f0102503 <mem_init+0xc30>
f01024ea:	68 d6 74 10 f0       	push   $0xf01074d6
f01024ef:	68 b7 72 10 f0       	push   $0xf01072b7
f01024f4:	68 c9 03 00 00       	push   $0x3c9
f01024f9:	68 91 72 10 f0       	push   $0xf0107291
f01024fe:	e8 65 db ff ff       	call   f0100068 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102503:	83 ec 0c             	sub    $0xc,%esp
f0102506:	6a 00                	push   $0x0
f0102508:	e8 97 f0 ff ff       	call   f01015a4 <page_alloc>
f010250d:	83 c4 10             	add    $0x10,%esp
f0102510:	85 c0                	test   %eax,%eax
f0102512:	74 04                	je     f0102518 <mem_init+0xc45>
f0102514:	39 c3                	cmp    %eax,%ebx
f0102516:	74 19                	je     f0102531 <mem_init+0xc5e>
f0102518:	68 78 6e 10 f0       	push   $0xf0106e78
f010251d:	68 b7 72 10 f0       	push   $0xf01072b7
f0102522:	68 cc 03 00 00       	push   $0x3cc
f0102527:	68 91 72 10 f0       	push   $0xf0107291
f010252c:	e8 37 db ff ff       	call   f0100068 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102531:	83 ec 08             	sub    $0x8,%esp
f0102534:	6a 00                	push   $0x0
f0102536:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f010253c:	e8 c2 f2 ff ff       	call   f0101803 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102541:	ba 00 00 00 00       	mov    $0x0,%edx
f0102546:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f010254b:	e8 33 ec ff ff       	call   f0101183 <check_va2pa>
f0102550:	83 c4 10             	add    $0x10,%esp
f0102553:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102556:	74 19                	je     f0102571 <mem_init+0xc9e>
f0102558:	68 9c 6e 10 f0       	push   $0xf0106e9c
f010255d:	68 b7 72 10 f0       	push   $0xf01072b7
f0102562:	68 d0 03 00 00       	push   $0x3d0
f0102567:	68 91 72 10 f0       	push   $0xf0107291
f010256c:	e8 f7 da ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102571:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102576:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f010257b:	e8 03 ec ff ff       	call   f0101183 <check_va2pa>
f0102580:	89 f2                	mov    %esi,%edx
f0102582:	2b 15 10 ef 2d f0    	sub    0xf02def10,%edx
f0102588:	c1 fa 03             	sar    $0x3,%edx
f010258b:	c1 e2 0c             	shl    $0xc,%edx
f010258e:	39 d0                	cmp    %edx,%eax
f0102590:	74 19                	je     f01025ab <mem_init+0xcd8>
f0102592:	68 48 6e 10 f0       	push   $0xf0106e48
f0102597:	68 b7 72 10 f0       	push   $0xf01072b7
f010259c:	68 d1 03 00 00       	push   $0x3d1
f01025a1:	68 91 72 10 f0       	push   $0xf0107291
f01025a6:	e8 bd da ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 1);
f01025ab:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01025b0:	74 19                	je     f01025cb <mem_init+0xcf8>
f01025b2:	68 7c 74 10 f0       	push   $0xf010747c
f01025b7:	68 b7 72 10 f0       	push   $0xf01072b7
f01025bc:	68 d2 03 00 00       	push   $0x3d2
f01025c1:	68 91 72 10 f0       	push   $0xf0107291
f01025c6:	e8 9d da ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f01025cb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025d0:	74 19                	je     f01025eb <mem_init+0xd18>
f01025d2:	68 d6 74 10 f0       	push   $0xf01074d6
f01025d7:	68 b7 72 10 f0       	push   $0xf01072b7
f01025dc:	68 d3 03 00 00       	push   $0x3d3
f01025e1:	68 91 72 10 f0       	push   $0xf0107291
f01025e6:	e8 7d da ff ff       	call   f0100068 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01025eb:	83 ec 08             	sub    $0x8,%esp
f01025ee:	68 00 10 00 00       	push   $0x1000
f01025f3:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f01025f9:	e8 05 f2 ff ff       	call   f0101803 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025fe:	ba 00 00 00 00       	mov    $0x0,%edx
f0102603:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102608:	e8 76 eb ff ff       	call   f0101183 <check_va2pa>
f010260d:	83 c4 10             	add    $0x10,%esp
f0102610:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102613:	74 19                	je     f010262e <mem_init+0xd5b>
f0102615:	68 9c 6e 10 f0       	push   $0xf0106e9c
f010261a:	68 b7 72 10 f0       	push   $0xf01072b7
f010261f:	68 d7 03 00 00       	push   $0x3d7
f0102624:	68 91 72 10 f0       	push   $0xf0107291
f0102629:	e8 3a da ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010262e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102633:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102638:	e8 46 eb ff ff       	call   f0101183 <check_va2pa>
f010263d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102640:	74 19                	je     f010265b <mem_init+0xd88>
f0102642:	68 c0 6e 10 f0       	push   $0xf0106ec0
f0102647:	68 b7 72 10 f0       	push   $0xf01072b7
f010264c:	68 d8 03 00 00       	push   $0x3d8
f0102651:	68 91 72 10 f0       	push   $0xf0107291
f0102656:	e8 0d da ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 0);
f010265b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102660:	74 19                	je     f010267b <mem_init+0xda8>
f0102662:	68 e7 74 10 f0       	push   $0xf01074e7
f0102667:	68 b7 72 10 f0       	push   $0xf01072b7
f010266c:	68 d9 03 00 00       	push   $0x3d9
f0102671:	68 91 72 10 f0       	push   $0xf0107291
f0102676:	e8 ed d9 ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 0);
f010267b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102680:	74 19                	je     f010269b <mem_init+0xdc8>
f0102682:	68 d6 74 10 f0       	push   $0xf01074d6
f0102687:	68 b7 72 10 f0       	push   $0xf01072b7
f010268c:	68 da 03 00 00       	push   $0x3da
f0102691:	68 91 72 10 f0       	push   $0xf0107291
f0102696:	e8 cd d9 ff ff       	call   f0100068 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010269b:	83 ec 0c             	sub    $0xc,%esp
f010269e:	6a 00                	push   $0x0
f01026a0:	e8 ff ee ff ff       	call   f01015a4 <page_alloc>
f01026a5:	83 c4 10             	add    $0x10,%esp
f01026a8:	85 c0                	test   %eax,%eax
f01026aa:	74 04                	je     f01026b0 <mem_init+0xddd>
f01026ac:	39 c6                	cmp    %eax,%esi
f01026ae:	74 19                	je     f01026c9 <mem_init+0xdf6>
f01026b0:	68 e8 6e 10 f0       	push   $0xf0106ee8
f01026b5:	68 b7 72 10 f0       	push   $0xf01072b7
f01026ba:	68 dd 03 00 00       	push   $0x3dd
f01026bf:	68 91 72 10 f0       	push   $0xf0107291
f01026c4:	e8 9f d9 ff ff       	call   f0100068 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01026c9:	83 ec 0c             	sub    $0xc,%esp
f01026cc:	6a 00                	push   $0x0
f01026ce:	e8 d1 ee ff ff       	call   f01015a4 <page_alloc>
f01026d3:	83 c4 10             	add    $0x10,%esp
f01026d6:	85 c0                	test   %eax,%eax
f01026d8:	74 19                	je     f01026f3 <mem_init+0xe20>
f01026da:	68 2a 74 10 f0       	push   $0xf010742a
f01026df:	68 b7 72 10 f0       	push   $0xf01072b7
f01026e4:	68 e0 03 00 00       	push   $0x3e0
f01026e9:	68 91 72 10 f0       	push   $0xf0107291
f01026ee:	e8 75 d9 ff ff       	call   f0100068 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026f3:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f01026f8:	8b 08                	mov    (%eax),%ecx
f01026fa:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102700:	89 fa                	mov    %edi,%edx
f0102702:	2b 15 10 ef 2d f0    	sub    0xf02def10,%edx
f0102708:	c1 fa 03             	sar    $0x3,%edx
f010270b:	c1 e2 0c             	shl    $0xc,%edx
f010270e:	39 d1                	cmp    %edx,%ecx
f0102710:	74 19                	je     f010272b <mem_init+0xe58>
f0102712:	68 c4 6b 10 f0       	push   $0xf0106bc4
f0102717:	68 b7 72 10 f0       	push   $0xf01072b7
f010271c:	68 e3 03 00 00       	push   $0x3e3
f0102721:	68 91 72 10 f0       	push   $0xf0107291
f0102726:	e8 3d d9 ff ff       	call   f0100068 <_panic>
	kern_pgdir[0] = 0;
f010272b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102731:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102736:	74 19                	je     f0102751 <mem_init+0xe7e>
f0102738:	68 8d 74 10 f0       	push   $0xf010748d
f010273d:	68 b7 72 10 f0       	push   $0xf01072b7
f0102742:	68 e5 03 00 00       	push   $0x3e5
f0102747:	68 91 72 10 f0       	push   $0xf0107291
f010274c:	e8 17 d9 ff ff       	call   f0100068 <_panic>
	pp0->pp_ref = 0;

	kern_pgdir[PDX(va)] = 0;
f0102751:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102756:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010275c:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
f0102762:	89 f8                	mov    %edi,%eax
f0102764:	2b 05 10 ef 2d f0    	sub    0xf02def10,%eax
f010276a:	c1 f8 03             	sar    $0x3,%eax
f010276d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102770:	89 c2                	mov    %eax,%edx
f0102772:	c1 ea 0c             	shr    $0xc,%edx
f0102775:	3b 15 08 ef 2d f0    	cmp    0xf02def08,%edx
f010277b:	72 12                	jb     f010278f <mem_init+0xebc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010277d:	50                   	push   %eax
f010277e:	68 08 5f 10 f0       	push   $0xf0105f08
f0102783:	6a 58                	push   $0x58
f0102785:	68 9d 72 10 f0       	push   $0xf010729d
f010278a:	e8 d9 d8 ff ff       	call   f0100068 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010278f:	83 ec 04             	sub    $0x4,%esp
f0102792:	68 00 10 00 00       	push   $0x1000
f0102797:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f010279c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01027a1:	50                   	push   %eax
f01027a2:	e8 46 2a 00 00       	call   f01051ed <memset>
	page_free(pp0);
f01027a7:	89 3c 24             	mov    %edi,(%esp)
f01027aa:	e8 7f ee ff ff       	call   f010162e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01027af:	83 c4 0c             	add    $0xc,%esp
f01027b2:	6a 01                	push   $0x1
f01027b4:	6a 00                	push   $0x0
f01027b6:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f01027bc:	e8 ab ee ff ff       	call   f010166c <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01027c1:	89 fa                	mov    %edi,%edx
f01027c3:	2b 15 10 ef 2d f0    	sub    0xf02def10,%edx
f01027c9:	c1 fa 03             	sar    $0x3,%edx
f01027cc:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027cf:	89 d0                	mov    %edx,%eax
f01027d1:	c1 e8 0c             	shr    $0xc,%eax
f01027d4:	83 c4 10             	add    $0x10,%esp
f01027d7:	3b 05 08 ef 2d f0    	cmp    0xf02def08,%eax
f01027dd:	72 12                	jb     f01027f1 <mem_init+0xf1e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027df:	52                   	push   %edx
f01027e0:	68 08 5f 10 f0       	push   $0xf0105f08
f01027e5:	6a 58                	push   $0x58
f01027e7:	68 9d 72 10 f0       	push   $0xf010729d
f01027ec:	e8 77 d8 ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f01027f1:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01027f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01027fa:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102801:	75 11                	jne    f0102814 <mem_init+0xf41>
f0102803:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102809:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010280f:	f6 00 01             	testb  $0x1,(%eax)
f0102812:	74 19                	je     f010282d <mem_init+0xf5a>
f0102814:	68 f8 74 10 f0       	push   $0xf01074f8
f0102819:	68 b7 72 10 f0       	push   $0xf01072b7
f010281e:	68 f1 03 00 00       	push   $0x3f1
f0102823:	68 91 72 10 f0       	push   $0xf0107291
f0102828:	e8 3b d8 ff ff       	call   f0100068 <_panic>
f010282d:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102830:	39 d0                	cmp    %edx,%eax
f0102832:	75 db                	jne    f010280f <mem_init+0xf3c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102834:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102839:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010283f:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102848:	a3 30 e2 2d f0       	mov    %eax,0xf02de230

	// free the pages we took
	page_free(pp0);
f010284d:	83 ec 0c             	sub    $0xc,%esp
f0102850:	57                   	push   %edi
f0102851:	e8 d8 ed ff ff       	call   f010162e <page_free>
	page_free(pp1);
f0102856:	89 34 24             	mov    %esi,(%esp)
f0102859:	e8 d0 ed ff ff       	call   f010162e <page_free>
	page_free(pp2);
f010285e:	89 1c 24             	mov    %ebx,(%esp)
f0102861:	e8 c8 ed ff ff       	call   f010162e <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102866:	83 c4 08             	add    $0x8,%esp
f0102869:	68 01 10 00 00       	push   $0x1001
f010286e:	6a 00                	push   $0x0
f0102870:	e8 44 f0 ff ff       	call   f01018b9 <mmio_map_region>
f0102875:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102877:	83 c4 08             	add    $0x8,%esp
f010287a:	68 00 10 00 00       	push   $0x1000
f010287f:	6a 00                	push   $0x0
f0102881:	e8 33 f0 ff ff       	call   f01018b9 <mmio_map_region>
f0102886:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102888:	83 c4 10             	add    $0x10,%esp
f010288b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102891:	76 0d                	jbe    f01028a0 <mem_init+0xfcd>
f0102893:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102899:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010289e:	76 19                	jbe    f01028b9 <mem_init+0xfe6>
f01028a0:	68 0c 6f 10 f0       	push   $0xf0106f0c
f01028a5:	68 b7 72 10 f0       	push   $0xf01072b7
f01028aa:	68 01 04 00 00       	push   $0x401
f01028af:	68 91 72 10 f0       	push   $0xf0107291
f01028b4:	e8 af d7 ff ff       	call   f0100068 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01028b9:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01028bf:	76 0e                	jbe    f01028cf <mem_init+0xffc>
f01028c1:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01028c7:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01028cd:	76 19                	jbe    f01028e8 <mem_init+0x1015>
f01028cf:	68 34 6f 10 f0       	push   $0xf0106f34
f01028d4:	68 b7 72 10 f0       	push   $0xf01072b7
f01028d9:	68 02 04 00 00       	push   $0x402
f01028de:	68 91 72 10 f0       	push   $0xf0107291
f01028e3:	e8 80 d7 ff ff       	call   f0100068 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01028e8:	89 da                	mov    %ebx,%edx
f01028ea:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01028ec:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01028f2:	74 19                	je     f010290d <mem_init+0x103a>
f01028f4:	68 5c 6f 10 f0       	push   $0xf0106f5c
f01028f9:	68 b7 72 10 f0       	push   $0xf01072b7
f01028fe:	68 04 04 00 00       	push   $0x404
f0102903:	68 91 72 10 f0       	push   $0xf0107291
f0102908:	e8 5b d7 ff ff       	call   f0100068 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010290d:	39 c6                	cmp    %eax,%esi
f010290f:	73 19                	jae    f010292a <mem_init+0x1057>
f0102911:	68 0f 75 10 f0       	push   $0xf010750f
f0102916:	68 b7 72 10 f0       	push   $0xf01072b7
f010291b:	68 06 04 00 00       	push   $0x406
f0102920:	68 91 72 10 f0       	push   $0xf0107291
f0102925:	e8 3e d7 ff ff       	call   f0100068 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010292a:	89 da                	mov    %ebx,%edx
f010292c:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102931:	e8 4d e8 ff ff       	call   f0101183 <check_va2pa>
f0102936:	85 c0                	test   %eax,%eax
f0102938:	74 19                	je     f0102953 <mem_init+0x1080>
f010293a:	68 84 6f 10 f0       	push   $0xf0106f84
f010293f:	68 b7 72 10 f0       	push   $0xf01072b7
f0102944:	68 08 04 00 00       	push   $0x408
f0102949:	68 91 72 10 f0       	push   $0xf0107291
f010294e:	e8 15 d7 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102953:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
f0102959:	89 fa                	mov    %edi,%edx
f010295b:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102960:	e8 1e e8 ff ff       	call   f0101183 <check_va2pa>
f0102965:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010296a:	74 19                	je     f0102985 <mem_init+0x10b2>
f010296c:	68 a8 6f 10 f0       	push   $0xf0106fa8
f0102971:	68 b7 72 10 f0       	push   $0xf01072b7
f0102976:	68 09 04 00 00       	push   $0x409
f010297b:	68 91 72 10 f0       	push   $0xf0107291
f0102980:	e8 e3 d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102985:	89 f2                	mov    %esi,%edx
f0102987:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f010298c:	e8 f2 e7 ff ff       	call   f0101183 <check_va2pa>
f0102991:	85 c0                	test   %eax,%eax
f0102993:	74 19                	je     f01029ae <mem_init+0x10db>
f0102995:	68 d8 6f 10 f0       	push   $0xf0106fd8
f010299a:	68 b7 72 10 f0       	push   $0xf01072b7
f010299f:	68 0a 04 00 00       	push   $0x40a
f01029a4:	68 91 72 10 f0       	push   $0xf0107291
f01029a9:	e8 ba d6 ff ff       	call   f0100068 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01029ae:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01029b4:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f01029b9:	e8 c5 e7 ff ff       	call   f0101183 <check_va2pa>
f01029be:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029c1:	74 19                	je     f01029dc <mem_init+0x1109>
f01029c3:	68 fc 6f 10 f0       	push   $0xf0106ffc
f01029c8:	68 b7 72 10 f0       	push   $0xf01072b7
f01029cd:	68 0b 04 00 00       	push   $0x40b
f01029d2:	68 91 72 10 f0       	push   $0xf0107291
f01029d7:	e8 8c d6 ff ff       	call   f0100068 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01029dc:	83 ec 04             	sub    $0x4,%esp
f01029df:	6a 00                	push   $0x0
f01029e1:	53                   	push   %ebx
f01029e2:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f01029e8:	e8 7f ec ff ff       	call   f010166c <pgdir_walk>
f01029ed:	83 c4 10             	add    $0x10,%esp
f01029f0:	f6 00 1a             	testb  $0x1a,(%eax)
f01029f3:	75 19                	jne    f0102a0e <mem_init+0x113b>
f01029f5:	68 28 70 10 f0       	push   $0xf0107028
f01029fa:	68 b7 72 10 f0       	push   $0xf01072b7
f01029ff:	68 0d 04 00 00       	push   $0x40d
f0102a04:	68 91 72 10 f0       	push   $0xf0107291
f0102a09:	e8 5a d6 ff ff       	call   f0100068 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a0e:	83 ec 04             	sub    $0x4,%esp
f0102a11:	6a 00                	push   $0x0
f0102a13:	53                   	push   %ebx
f0102a14:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0102a1a:	e8 4d ec ff ff       	call   f010166c <pgdir_walk>
f0102a1f:	83 c4 10             	add    $0x10,%esp
f0102a22:	f6 00 04             	testb  $0x4,(%eax)
f0102a25:	74 19                	je     f0102a40 <mem_init+0x116d>
f0102a27:	68 6c 70 10 f0       	push   $0xf010706c
f0102a2c:	68 b7 72 10 f0       	push   $0xf01072b7
f0102a31:	68 0e 04 00 00       	push   $0x40e
f0102a36:	68 91 72 10 f0       	push   $0xf0107291
f0102a3b:	e8 28 d6 ff ff       	call   f0100068 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102a40:	83 ec 04             	sub    $0x4,%esp
f0102a43:	6a 00                	push   $0x0
f0102a45:	53                   	push   %ebx
f0102a46:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0102a4c:	e8 1b ec ff ff       	call   f010166c <pgdir_walk>
f0102a51:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102a57:	83 c4 0c             	add    $0xc,%esp
f0102a5a:	6a 00                	push   $0x0
f0102a5c:	57                   	push   %edi
f0102a5d:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0102a63:	e8 04 ec ff ff       	call   f010166c <pgdir_walk>
f0102a68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102a6e:	83 c4 0c             	add    $0xc,%esp
f0102a71:	6a 00                	push   $0x0
f0102a73:	56                   	push   %esi
f0102a74:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0102a7a:	e8 ed eb ff ff       	call   f010166c <pgdir_walk>
f0102a7f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102a85:	c7 04 24 21 75 10 f0 	movl   $0xf0107521,(%esp)
f0102a8c:	e8 e8 11 00 00       	call   f0103c79 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102a91:	a1 10 ef 2d f0       	mov    0xf02def10,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a96:	83 c4 10             	add    $0x10,%esp
f0102a99:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a9e:	77 15                	ja     f0102ab5 <mem_init+0x11e2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102aa0:	50                   	push   %eax
f0102aa1:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0102aa6:	68 b9 00 00 00       	push   $0xb9
f0102aab:	68 91 72 10 f0       	push   $0xf0107291
f0102ab0:	e8 b3 d5 ff ff       	call   f0100068 <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102ab5:	8b 15 08 ef 2d f0    	mov    0xf02def08,%edx
f0102abb:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102ac2:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102ac5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102acb:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102acd:	05 00 00 00 10       	add    $0x10000000,%eax
f0102ad2:	50                   	push   %eax
f0102ad3:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102ad8:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102add:	e8 21 ec ff ff       	call   f0101703 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    boot_map_region(kern_pgdir,
f0102ae2:	a1 3c e2 2d f0       	mov    0xf02de23c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ae7:	83 c4 10             	add    $0x10,%esp
f0102aea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102aef:	77 15                	ja     f0102b06 <mem_init+0x1233>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102af1:	50                   	push   %eax
f0102af2:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0102af7:	68 c6 00 00 00       	push   $0xc6
f0102afc:	68 91 72 10 f0       	push   $0xf0107291
f0102b01:	e8 62 d5 ff ff       	call   f0100068 <_panic>
f0102b06:	83 ec 08             	sub    $0x8,%esp
f0102b09:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102b0b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b10:	50                   	push   %eax
f0102b11:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102b16:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102b1b:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102b20:	e8 de eb ff ff       	call   f0101703 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b25:	83 c4 10             	add    $0x10,%esp
f0102b28:	b8 00 d0 11 f0       	mov    $0xf011d000,%eax
f0102b2d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b32:	77 15                	ja     f0102b49 <mem_init+0x1276>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b34:	50                   	push   %eax
f0102b35:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0102b3a:	68 d7 00 00 00       	push   $0xd7
f0102b3f:	68 91 72 10 f0       	push   $0xf0107291
f0102b44:	e8 1f d5 ff ff       	call   f0100068 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102b49:	83 ec 08             	sub    $0x8,%esp
f0102b4c:	6a 02                	push   $0x2
f0102b4e:	68 00 d0 11 00       	push   $0x11d000
f0102b53:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102b58:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102b5d:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102b62:	e8 9c eb ff ff       	call   f0101703 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102b67:	83 c4 08             	add    $0x8,%esp
f0102b6a:	6a 02                	push   $0x2
f0102b6c:	6a 00                	push   $0x0
f0102b6e:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102b73:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102b78:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f0102b7d:	e8 81 eb ff ff       	call   f0101703 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102b82:	8b 35 0c ef 2d f0    	mov    0xf02def0c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b88:	a1 08 ef 2d f0       	mov    0xf02def08,%eax
f0102b8d:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102b94:	83 c4 10             	add    $0x10,%esp
f0102b97:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102b9d:	74 63                	je     f0102c02 <mem_init+0x132f>
f0102b9f:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102ba4:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102baa:	89 f0                	mov    %esi,%eax
f0102bac:	e8 d2 e5 ff ff       	call   f0101183 <check_va2pa>
f0102bb1:	8b 15 10 ef 2d f0    	mov    0xf02def10,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bb7:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102bbd:	77 15                	ja     f0102bd4 <mem_init+0x1301>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bbf:	52                   	push   %edx
f0102bc0:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0102bc5:	68 31 03 00 00       	push   $0x331
f0102bca:	68 91 72 10 f0       	push   $0xf0107291
f0102bcf:	e8 94 d4 ff ff       	call   f0100068 <_panic>
f0102bd4:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0102bdb:	39 d0                	cmp    %edx,%eax
f0102bdd:	74 19                	je     f0102bf8 <mem_init+0x1325>
f0102bdf:	68 a0 70 10 f0       	push   $0xf01070a0
f0102be4:	68 b7 72 10 f0       	push   $0xf01072b7
f0102be9:	68 31 03 00 00       	push   $0x331
f0102bee:	68 91 72 10 f0       	push   $0xf0107291
f0102bf3:	e8 70 d4 ff ff       	call   f0100068 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102bf8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102bfe:	39 df                	cmp    %ebx,%edi
f0102c00:	77 a2                	ja     f0102ba4 <mem_init+0x12d1>
f0102c02:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102c07:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
f0102c0d:	89 f0                	mov    %esi,%eax
f0102c0f:	e8 6f e5 ff ff       	call   f0101183 <check_va2pa>
f0102c14:	8b 15 3c e2 2d f0    	mov    0xf02de23c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c1a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102c20:	77 15                	ja     f0102c37 <mem_init+0x1364>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c22:	52                   	push   %edx
f0102c23:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0102c28:	68 36 03 00 00       	push   $0x336
f0102c2d:	68 91 72 10 f0       	push   $0xf0107291
f0102c32:	e8 31 d4 ff ff       	call   f0100068 <_panic>
f0102c37:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0102c3e:	39 d0                	cmp    %edx,%eax
f0102c40:	74 19                	je     f0102c5b <mem_init+0x1388>
f0102c42:	68 d4 70 10 f0       	push   $0xf01070d4
f0102c47:	68 b7 72 10 f0       	push   $0xf01072b7
f0102c4c:	68 36 03 00 00       	push   $0x336
f0102c51:	68 91 72 10 f0       	push   $0xf0107291
f0102c56:	e8 0d d4 ff ff       	call   f0100068 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102c5b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102c61:	81 fb 00 f0 01 00    	cmp    $0x1f000,%ebx
f0102c67:	75 9e                	jne    f0102c07 <mem_init+0x1334>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c69:	a1 08 ef 2d f0       	mov    0xf02def08,%eax
f0102c6e:	c1 e0 0c             	shl    $0xc,%eax
f0102c71:	74 41                	je     f0102cb4 <mem_init+0x13e1>
f0102c73:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102c78:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102c7e:	89 f0                	mov    %esi,%eax
f0102c80:	e8 fe e4 ff ff       	call   f0101183 <check_va2pa>
f0102c85:	39 c3                	cmp    %eax,%ebx
f0102c87:	74 19                	je     f0102ca2 <mem_init+0x13cf>
f0102c89:	68 08 71 10 f0       	push   $0xf0107108
f0102c8e:	68 b7 72 10 f0       	push   $0xf01072b7
f0102c93:	68 3a 03 00 00       	push   $0x33a
f0102c98:	68 91 72 10 f0       	push   $0xf0107291
f0102c9d:	e8 c6 d3 ff ff       	call   f0100068 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ca2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ca8:	a1 08 ef 2d f0       	mov    0xf02def08,%eax
f0102cad:	c1 e0 0c             	shl    $0xc,%eax
f0102cb0:	39 c3                	cmp    %eax,%ebx
f0102cb2:	72 c4                	jb     f0102c78 <mem_init+0x13a5>
f0102cb4:	c7 45 d0 00 00 2e f0 	movl   $0xf02e0000,-0x30(%ebp)
f0102cbb:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0102cc0:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102cc3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	return (physaddr_t)kva - KERNBASE;
f0102cc6:	89 de                	mov    %ebx,%esi
f0102cc8:	81 c6 00 00 00 10    	add    $0x10000000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102cce:	8d 97 00 80 00 00    	lea    0x8000(%edi),%edx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102cd4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cd7:	e8 a7 e4 ff ff       	call   f0101183 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cdc:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102ce3:	77 15                	ja     f0102cfa <mem_init+0x1427>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ce5:	53                   	push   %ebx
f0102ce6:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0102ceb:	68 42 03 00 00       	push   $0x342
f0102cf0:	68 91 72 10 f0       	push   $0xf0107291
f0102cf5:	e8 6e d3 ff ff       	call   f0100068 <_panic>

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102cfa:	bb 00 00 00 00       	mov    $0x0,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102cff:	8d 97 00 80 00 00    	lea    0x8000(%edi),%edx
f0102d05:	89 7d c8             	mov    %edi,-0x38(%ebp)
f0102d08:	89 d7                	mov    %edx,%edi
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102d0a:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102d0d:	39 d0                	cmp    %edx,%eax
f0102d0f:	74 19                	je     f0102d2a <mem_init+0x1457>
f0102d11:	68 30 71 10 f0       	push   $0xf0107130
f0102d16:	68 b7 72 10 f0       	push   $0xf01072b7
f0102d1b:	68 42 03 00 00       	push   $0x342
f0102d20:	68 91 72 10 f0       	push   $0xf0107291
f0102d25:	e8 3e d3 ff ff       	call   f0100068 <_panic>

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102d2a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d30:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102d36:	0f 85 4d 04 00 00    	jne    f0103189 <mem_init+0x18b6>
f0102d3c:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102d3f:	66 bb 00 00          	mov    $0x0,%bx
f0102d43:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102d46:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102d49:	89 f0                	mov    %esi,%eax
f0102d4b:	e8 33 e4 ff ff       	call   f0101183 <check_va2pa>
f0102d50:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102d53:	74 19                	je     f0102d6e <mem_init+0x149b>
f0102d55:	68 78 71 10 f0       	push   $0xf0107178
f0102d5a:	68 b7 72 10 f0       	push   $0xf01072b7
f0102d5f:	68 44 03 00 00       	push   $0x344
f0102d64:	68 91 72 10 f0       	push   $0xf0107291
f0102d69:	e8 fa d2 ff ff       	call   f0100068 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102d6e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d74:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102d7a:	75 ca                	jne    f0102d46 <mem_init+0x1473>
f0102d7c:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102d83:	81 ef 00 00 01 00    	sub    $0x10000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102d89:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f0102d8f:	0f 85 2e ff ff ff    	jne    f0102cc3 <mem_init+0x13f0>
f0102d95:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102d98:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102d9d:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102da3:	83 fa 04             	cmp    $0x4,%edx
f0102da6:	77 1f                	ja     f0102dc7 <mem_init+0x14f4>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102da8:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102dac:	75 7e                	jne    f0102e2c <mem_init+0x1559>
f0102dae:	68 3a 75 10 f0       	push   $0xf010753a
f0102db3:	68 b7 72 10 f0       	push   $0xf01072b7
f0102db8:	68 4f 03 00 00       	push   $0x34f
f0102dbd:	68 91 72 10 f0       	push   $0xf0107291
f0102dc2:	e8 a1 d2 ff ff       	call   f0100068 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102dc7:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102dcc:	76 3f                	jbe    f0102e0d <mem_init+0x153a>
				assert(pgdir[i] & PTE_P);
f0102dce:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102dd1:	f6 c2 01             	test   $0x1,%dl
f0102dd4:	75 19                	jne    f0102def <mem_init+0x151c>
f0102dd6:	68 3a 75 10 f0       	push   $0xf010753a
f0102ddb:	68 b7 72 10 f0       	push   $0xf01072b7
f0102de0:	68 53 03 00 00       	push   $0x353
f0102de5:	68 91 72 10 f0       	push   $0xf0107291
f0102dea:	e8 79 d2 ff ff       	call   f0100068 <_panic>
				assert(pgdir[i] & PTE_W);
f0102def:	f6 c2 02             	test   $0x2,%dl
f0102df2:	75 38                	jne    f0102e2c <mem_init+0x1559>
f0102df4:	68 4b 75 10 f0       	push   $0xf010754b
f0102df9:	68 b7 72 10 f0       	push   $0xf01072b7
f0102dfe:	68 54 03 00 00       	push   $0x354
f0102e03:	68 91 72 10 f0       	push   $0xf0107291
f0102e08:	e8 5b d2 ff ff       	call   f0100068 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102e0d:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102e11:	74 19                	je     f0102e2c <mem_init+0x1559>
f0102e13:	68 5c 75 10 f0       	push   $0xf010755c
f0102e18:	68 b7 72 10 f0       	push   $0xf01072b7
f0102e1d:	68 56 03 00 00       	push   $0x356
f0102e22:	68 91 72 10 f0       	push   $0xf0107291
f0102e27:	e8 3c d2 ff ff       	call   f0100068 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102e2c:	40                   	inc    %eax
f0102e2d:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102e32:	0f 85 65 ff ff ff    	jne    f0102d9d <mem_init+0x14ca>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102e38:	83 ec 0c             	sub    $0xc,%esp
f0102e3b:	68 9c 71 10 f0       	push   $0xf010719c
f0102e40:	e8 34 0e 00 00       	call   f0103c79 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102e45:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e4a:	83 c4 10             	add    $0x10,%esp
f0102e4d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e52:	77 15                	ja     f0102e69 <mem_init+0x1596>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e54:	50                   	push   %eax
f0102e55:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0102e5a:	68 f9 00 00 00       	push   $0xf9
f0102e5f:	68 91 72 10 f0       	push   $0xf0107291
f0102e64:	e8 ff d1 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102e69:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102e6e:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102e71:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e76:	e8 91 e3 ff ff       	call   f010120c <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102e7b:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102e7e:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102e83:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102e86:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102e89:	83 ec 0c             	sub    $0xc,%esp
f0102e8c:	6a 00                	push   $0x0
f0102e8e:	e8 11 e7 ff ff       	call   f01015a4 <page_alloc>
f0102e93:	89 c6                	mov    %eax,%esi
f0102e95:	83 c4 10             	add    $0x10,%esp
f0102e98:	85 c0                	test   %eax,%eax
f0102e9a:	75 19                	jne    f0102eb5 <mem_init+0x15e2>
f0102e9c:	68 7f 73 10 f0       	push   $0xf010737f
f0102ea1:	68 b7 72 10 f0       	push   $0xf01072b7
f0102ea6:	68 23 04 00 00       	push   $0x423
f0102eab:	68 91 72 10 f0       	push   $0xf0107291
f0102eb0:	e8 b3 d1 ff ff       	call   f0100068 <_panic>
	assert((pp1 = page_alloc(0)));
f0102eb5:	83 ec 0c             	sub    $0xc,%esp
f0102eb8:	6a 00                	push   $0x0
f0102eba:	e8 e5 e6 ff ff       	call   f01015a4 <page_alloc>
f0102ebf:	89 c7                	mov    %eax,%edi
f0102ec1:	83 c4 10             	add    $0x10,%esp
f0102ec4:	85 c0                	test   %eax,%eax
f0102ec6:	75 19                	jne    f0102ee1 <mem_init+0x160e>
f0102ec8:	68 95 73 10 f0       	push   $0xf0107395
f0102ecd:	68 b7 72 10 f0       	push   $0xf01072b7
f0102ed2:	68 24 04 00 00       	push   $0x424
f0102ed7:	68 91 72 10 f0       	push   $0xf0107291
f0102edc:	e8 87 d1 ff ff       	call   f0100068 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ee1:	83 ec 0c             	sub    $0xc,%esp
f0102ee4:	6a 00                	push   $0x0
f0102ee6:	e8 b9 e6 ff ff       	call   f01015a4 <page_alloc>
f0102eeb:	89 c3                	mov    %eax,%ebx
f0102eed:	83 c4 10             	add    $0x10,%esp
f0102ef0:	85 c0                	test   %eax,%eax
f0102ef2:	75 19                	jne    f0102f0d <mem_init+0x163a>
f0102ef4:	68 ab 73 10 f0       	push   $0xf01073ab
f0102ef9:	68 b7 72 10 f0       	push   $0xf01072b7
f0102efe:	68 25 04 00 00       	push   $0x425
f0102f03:	68 91 72 10 f0       	push   $0xf0107291
f0102f08:	e8 5b d1 ff ff       	call   f0100068 <_panic>
	page_free(pp0);
f0102f0d:	83 ec 0c             	sub    $0xc,%esp
f0102f10:	56                   	push   %esi
f0102f11:	e8 18 e7 ff ff       	call   f010162e <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f16:	89 f8                	mov    %edi,%eax
f0102f18:	2b 05 10 ef 2d f0    	sub    0xf02def10,%eax
f0102f1e:	c1 f8 03             	sar    $0x3,%eax
f0102f21:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f24:	89 c2                	mov    %eax,%edx
f0102f26:	c1 ea 0c             	shr    $0xc,%edx
f0102f29:	83 c4 10             	add    $0x10,%esp
f0102f2c:	3b 15 08 ef 2d f0    	cmp    0xf02def08,%edx
f0102f32:	72 12                	jb     f0102f46 <mem_init+0x1673>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f34:	50                   	push   %eax
f0102f35:	68 08 5f 10 f0       	push   $0xf0105f08
f0102f3a:	6a 58                	push   $0x58
f0102f3c:	68 9d 72 10 f0       	push   $0xf010729d
f0102f41:	e8 22 d1 ff ff       	call   f0100068 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102f46:	83 ec 04             	sub    $0x4,%esp
f0102f49:	68 00 10 00 00       	push   $0x1000
f0102f4e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102f50:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f55:	50                   	push   %eax
f0102f56:	e8 92 22 00 00       	call   f01051ed <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f5b:	89 d8                	mov    %ebx,%eax
f0102f5d:	2b 05 10 ef 2d f0    	sub    0xf02def10,%eax
f0102f63:	c1 f8 03             	sar    $0x3,%eax
f0102f66:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f69:	89 c2                	mov    %eax,%edx
f0102f6b:	c1 ea 0c             	shr    $0xc,%edx
f0102f6e:	83 c4 10             	add    $0x10,%esp
f0102f71:	3b 15 08 ef 2d f0    	cmp    0xf02def08,%edx
f0102f77:	72 12                	jb     f0102f8b <mem_init+0x16b8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f79:	50                   	push   %eax
f0102f7a:	68 08 5f 10 f0       	push   $0xf0105f08
f0102f7f:	6a 58                	push   $0x58
f0102f81:	68 9d 72 10 f0       	push   $0xf010729d
f0102f86:	e8 dd d0 ff ff       	call   f0100068 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102f8b:	83 ec 04             	sub    $0x4,%esp
f0102f8e:	68 00 10 00 00       	push   $0x1000
f0102f93:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102f95:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f9a:	50                   	push   %eax
f0102f9b:	e8 4d 22 00 00       	call   f01051ed <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102fa0:	6a 02                	push   $0x2
f0102fa2:	68 00 10 00 00       	push   $0x1000
f0102fa7:	57                   	push   %edi
f0102fa8:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0102fae:	e8 9d e8 ff ff       	call   f0101850 <page_insert>
	assert(pp1->pp_ref == 1);
f0102fb3:	83 c4 20             	add    $0x20,%esp
f0102fb6:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102fbb:	74 19                	je     f0102fd6 <mem_init+0x1703>
f0102fbd:	68 7c 74 10 f0       	push   $0xf010747c
f0102fc2:	68 b7 72 10 f0       	push   $0xf01072b7
f0102fc7:	68 2a 04 00 00       	push   $0x42a
f0102fcc:	68 91 72 10 f0       	push   $0xf0107291
f0102fd1:	e8 92 d0 ff ff       	call   f0100068 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102fd6:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102fdd:	01 01 01 
f0102fe0:	74 19                	je     f0102ffb <mem_init+0x1728>
f0102fe2:	68 bc 71 10 f0       	push   $0xf01071bc
f0102fe7:	68 b7 72 10 f0       	push   $0xf01072b7
f0102fec:	68 2b 04 00 00       	push   $0x42b
f0102ff1:	68 91 72 10 f0       	push   $0xf0107291
f0102ff6:	e8 6d d0 ff ff       	call   f0100068 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ffb:	6a 02                	push   $0x2
f0102ffd:	68 00 10 00 00       	push   $0x1000
f0103002:	53                   	push   %ebx
f0103003:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f0103009:	e8 42 e8 ff ff       	call   f0101850 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010300e:	83 c4 10             	add    $0x10,%esp
f0103011:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103018:	02 02 02 
f010301b:	74 19                	je     f0103036 <mem_init+0x1763>
f010301d:	68 e0 71 10 f0       	push   $0xf01071e0
f0103022:	68 b7 72 10 f0       	push   $0xf01072b7
f0103027:	68 2d 04 00 00       	push   $0x42d
f010302c:	68 91 72 10 f0       	push   $0xf0107291
f0103031:	e8 32 d0 ff ff       	call   f0100068 <_panic>
	assert(pp2->pp_ref == 1);
f0103036:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010303b:	74 19                	je     f0103056 <mem_init+0x1783>
f010303d:	68 9e 74 10 f0       	push   $0xf010749e
f0103042:	68 b7 72 10 f0       	push   $0xf01072b7
f0103047:	68 2e 04 00 00       	push   $0x42e
f010304c:	68 91 72 10 f0       	push   $0xf0107291
f0103051:	e8 12 d0 ff ff       	call   f0100068 <_panic>
	assert(pp1->pp_ref == 0);
f0103056:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010305b:	74 19                	je     f0103076 <mem_init+0x17a3>
f010305d:	68 e7 74 10 f0       	push   $0xf01074e7
f0103062:	68 b7 72 10 f0       	push   $0xf01072b7
f0103067:	68 2f 04 00 00       	push   $0x42f
f010306c:	68 91 72 10 f0       	push   $0xf0107291
f0103071:	e8 f2 cf ff ff       	call   f0100068 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103076:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010307d:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103080:	89 d8                	mov    %ebx,%eax
f0103082:	2b 05 10 ef 2d f0    	sub    0xf02def10,%eax
f0103088:	c1 f8 03             	sar    $0x3,%eax
f010308b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010308e:	89 c2                	mov    %eax,%edx
f0103090:	c1 ea 0c             	shr    $0xc,%edx
f0103093:	3b 15 08 ef 2d f0    	cmp    0xf02def08,%edx
f0103099:	72 12                	jb     f01030ad <mem_init+0x17da>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010309b:	50                   	push   %eax
f010309c:	68 08 5f 10 f0       	push   $0xf0105f08
f01030a1:	6a 58                	push   $0x58
f01030a3:	68 9d 72 10 f0       	push   $0xf010729d
f01030a8:	e8 bb cf ff ff       	call   f0100068 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01030ad:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01030b4:	03 03 03 
f01030b7:	74 19                	je     f01030d2 <mem_init+0x17ff>
f01030b9:	68 04 72 10 f0       	push   $0xf0107204
f01030be:	68 b7 72 10 f0       	push   $0xf01072b7
f01030c3:	68 31 04 00 00       	push   $0x431
f01030c8:	68 91 72 10 f0       	push   $0xf0107291
f01030cd:	e8 96 cf ff ff       	call   f0100068 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01030d2:	83 ec 08             	sub    $0x8,%esp
f01030d5:	68 00 10 00 00       	push   $0x1000
f01030da:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f01030e0:	e8 1e e7 ff ff       	call   f0101803 <page_remove>
	assert(pp2->pp_ref == 0);
f01030e5:	83 c4 10             	add    $0x10,%esp
f01030e8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01030ed:	74 19                	je     f0103108 <mem_init+0x1835>
f01030ef:	68 d6 74 10 f0       	push   $0xf01074d6
f01030f4:	68 b7 72 10 f0       	push   $0xf01072b7
f01030f9:	68 33 04 00 00       	push   $0x433
f01030fe:	68 91 72 10 f0       	push   $0xf0107291
f0103103:	e8 60 cf ff ff       	call   f0100068 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103108:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
f010310d:	8b 08                	mov    (%eax),%ecx
f010310f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103115:	89 f2                	mov    %esi,%edx
f0103117:	2b 15 10 ef 2d f0    	sub    0xf02def10,%edx
f010311d:	c1 fa 03             	sar    $0x3,%edx
f0103120:	c1 e2 0c             	shl    $0xc,%edx
f0103123:	39 d1                	cmp    %edx,%ecx
f0103125:	74 19                	je     f0103140 <mem_init+0x186d>
f0103127:	68 c4 6b 10 f0       	push   $0xf0106bc4
f010312c:	68 b7 72 10 f0       	push   $0xf01072b7
f0103131:	68 36 04 00 00       	push   $0x436
f0103136:	68 91 72 10 f0       	push   $0xf0107291
f010313b:	e8 28 cf ff ff       	call   f0100068 <_panic>
	kern_pgdir[0] = 0;
f0103140:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103146:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010314b:	74 19                	je     f0103166 <mem_init+0x1893>
f010314d:	68 8d 74 10 f0       	push   $0xf010748d
f0103152:	68 b7 72 10 f0       	push   $0xf01072b7
f0103157:	68 38 04 00 00       	push   $0x438
f010315c:	68 91 72 10 f0       	push   $0xf0107291
f0103161:	e8 02 cf ff ff       	call   f0100068 <_panic>
	pp0->pp_ref = 0;
f0103166:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010316c:	83 ec 0c             	sub    $0xc,%esp
f010316f:	56                   	push   %esi
f0103170:	e8 b9 e4 ff ff       	call   f010162e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103175:	c7 04 24 30 72 10 f0 	movl   $0xf0107230,(%esp)
f010317c:	e8 f8 0a 00 00       	call   f0103c79 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103181:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103184:	5b                   	pop    %ebx
f0103185:	5e                   	pop    %esi
f0103186:	5f                   	pop    %edi
f0103187:	c9                   	leave  
f0103188:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103189:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f010318c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010318f:	e8 ef df ff ff       	call   f0101183 <check_va2pa>
f0103194:	e9 71 fb ff ff       	jmp    f0102d0a <mem_init+0x1437>

f0103199 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103199:	55                   	push   %ebp
f010319a:	89 e5                	mov    %esp,%ebp
f010319c:	57                   	push   %edi
f010319d:	56                   	push   %esi
f010319e:	53                   	push   %ebx
f010319f:	83 ec 1c             	sub    $0x1c,%esp
f01031a2:	8b 7d 08             	mov    0x8(%ebp),%edi
f01031a5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031a8:	8b 55 10             	mov    0x10(%ebp),%edx
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f01031ab:	85 d2                	test   %edx,%edx
f01031ad:	0f 84 85 00 00 00    	je     f0103238 <user_mem_check+0x9f>

	perm |= PTE_P;
f01031b3:	8b 75 14             	mov    0x14(%ebp),%esi
f01031b6:	83 ce 01             	or     $0x1,%esi
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
f01031b9:	89 c3                	mov    %eax,%ebx
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
f01031bb:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f01031c2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01031c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f01031cb:	89 c2                	mov    %eax,%edx
f01031cd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01031d3:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f01031d6:	74 67                	je     f010323f <user_mem_check+0xa6>
		if (va_now >= ULIM) {
f01031d8:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01031dd:	76 17                	jbe    f01031f6 <user_mem_check+0x5d>
f01031df:	eb 08                	jmp    f01031e9 <user_mem_check+0x50>
f01031e1:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01031e7:	76 0d                	jbe    f01031f6 <user_mem_check+0x5d>
			user_mem_check_addr = va_now;
f01031e9:	89 1d 2c e2 2d f0    	mov    %ebx,0xf02de22c
			return -E_FAULT;
f01031ef:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01031f4:	eb 4e                	jmp    f0103244 <user_mem_check+0xab>
		}
		pte = pgdir_walk(env->env_pgdir, (void *)va_now, false);
f01031f6:	83 ec 04             	sub    $0x4,%esp
f01031f9:	6a 00                	push   $0x0
f01031fb:	53                   	push   %ebx
f01031fc:	ff 77 60             	pushl  0x60(%edi)
f01031ff:	e8 68 e4 ff ff       	call   f010166c <pgdir_walk>
		if (pte == NULL || ((*pte & perm ) != perm)) {
f0103204:	83 c4 10             	add    $0x10,%esp
f0103207:	85 c0                	test   %eax,%eax
f0103209:	74 08                	je     f0103213 <user_mem_check+0x7a>
f010320b:	8b 00                	mov    (%eax),%eax
f010320d:	21 f0                	and    %esi,%eax
f010320f:	39 c6                	cmp    %eax,%esi
f0103211:	74 0d                	je     f0103220 <user_mem_check+0x87>
			user_mem_check_addr = va_now;
f0103213:	89 1d 2c e2 2d f0    	mov    %ebx,0xf02de22c
			return -E_FAULT;
f0103219:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010321e:	eb 24                	jmp    f0103244 <user_mem_check+0xab>

	perm |= PTE_P;
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f0103220:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103226:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010322c:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f010322f:	75 b0                	jne    f01031e1 <user_mem_check+0x48>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0103231:	b8 00 00 00 00       	mov    $0x0,%eax
f0103236:	eb 0c                	jmp    f0103244 <user_mem_check+0xab>
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f0103238:	b8 00 00 00 00       	mov    $0x0,%eax
f010323d:	eb 05                	jmp    f0103244 <user_mem_check+0xab>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f010323f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103244:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103247:	5b                   	pop    %ebx
f0103248:	5e                   	pop    %esi
f0103249:	5f                   	pop    %edi
f010324a:	c9                   	leave  
f010324b:	c3                   	ret    

f010324c <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010324c:	55                   	push   %ebp
f010324d:	89 e5                	mov    %esp,%ebp
f010324f:	53                   	push   %ebx
f0103250:	83 ec 04             	sub    $0x4,%esp
f0103253:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103256:	8b 45 14             	mov    0x14(%ebp),%eax
f0103259:	83 c8 04             	or     $0x4,%eax
f010325c:	50                   	push   %eax
f010325d:	ff 75 10             	pushl  0x10(%ebp)
f0103260:	ff 75 0c             	pushl  0xc(%ebp)
f0103263:	53                   	push   %ebx
f0103264:	e8 30 ff ff ff       	call   f0103199 <user_mem_check>
f0103269:	83 c4 10             	add    $0x10,%esp
f010326c:	85 c0                	test   %eax,%eax
f010326e:	79 21                	jns    f0103291 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103270:	83 ec 04             	sub    $0x4,%esp
f0103273:	ff 35 2c e2 2d f0    	pushl  0xf02de22c
f0103279:	ff 73 48             	pushl  0x48(%ebx)
f010327c:	68 5c 72 10 f0       	push   $0xf010725c
f0103281:	e8 f3 09 00 00       	call   f0103c79 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103286:	89 1c 24             	mov    %ebx,(%esp)
f0103289:	e8 d9 06 00 00       	call   f0103967 <env_destroy>
f010328e:	83 c4 10             	add    $0x10,%esp
	}
}
f0103291:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103294:	c9                   	leave  
f0103295:	c3                   	ret    
	...

f0103298 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103298:	55                   	push   %ebp
f0103299:	89 e5                	mov    %esp,%ebp
f010329b:	57                   	push   %edi
f010329c:	56                   	push   %esi
f010329d:	53                   	push   %ebx
f010329e:	83 ec 0c             	sub    $0xc,%esp
f01032a1:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
f01032a3:	89 d3                	mov    %edx,%ebx
f01032a5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
f01032ab:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f01032b2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f01032b8:	39 fb                	cmp    %edi,%ebx
f01032ba:	74 5a                	je     f0103316 <region_alloc+0x7e>
        pg = page_alloc(1);
f01032bc:	83 ec 0c             	sub    $0xc,%esp
f01032bf:	6a 01                	push   $0x1
f01032c1:	e8 de e2 ff ff       	call   f01015a4 <page_alloc>
        if (pg == NULL) {
f01032c6:	83 c4 10             	add    $0x10,%esp
f01032c9:	85 c0                	test   %eax,%eax
f01032cb:	75 17                	jne    f01032e4 <region_alloc+0x4c>
            panic("region_alloc : can't alloc page\n");
f01032cd:	83 ec 04             	sub    $0x4,%esp
f01032d0:	68 6c 75 10 f0       	push   $0xf010756c
f01032d5:	68 36 01 00 00       	push   $0x136
f01032da:	68 af 75 10 f0       	push   $0xf01075af
f01032df:	e8 84 cd ff ff       	call   f0100068 <_panic>
        } else {
            r = page_insert(e->env_pgdir, pg, (void *)addr, PTE_U | PTE_W);
f01032e4:	6a 06                	push   $0x6
f01032e6:	53                   	push   %ebx
f01032e7:	50                   	push   %eax
f01032e8:	ff 76 60             	pushl  0x60(%esi)
f01032eb:	e8 60 e5 ff ff       	call   f0101850 <page_insert>
            if (r != 0) {
f01032f0:	83 c4 10             	add    $0x10,%esp
f01032f3:	85 c0                	test   %eax,%eax
f01032f5:	74 15                	je     f010330c <region_alloc+0x74>
                panic("/kern/env.c/region_alloc : %e\n", r);
f01032f7:	50                   	push   %eax
f01032f8:	68 90 75 10 f0       	push   $0xf0107590
f01032fd:	68 3a 01 00 00       	push   $0x13a
f0103302:	68 af 75 10 f0       	push   $0xf01075af
f0103307:	e8 5c cd ff ff       	call   f0100068 <_panic>
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f010330c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103312:	39 df                	cmp    %ebx,%edi
f0103314:	75 a6                	jne    f01032bc <region_alloc+0x24>
                panic("/kern/env.c/region_alloc : %e\n", r);
            }
        }
    }
    return;
}
f0103316:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103319:	5b                   	pop    %ebx
f010331a:	5e                   	pop    %esi
f010331b:	5f                   	pop    %edi
f010331c:	c9                   	leave  
f010331d:	c3                   	ret    

f010331e <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010331e:	55                   	push   %ebp
f010331f:	89 e5                	mov    %esp,%ebp
f0103321:	57                   	push   %edi
f0103322:	56                   	push   %esi
f0103323:	53                   	push   %ebx
f0103324:	83 ec 0c             	sub    $0xc,%esp
f0103327:	8b 45 08             	mov    0x8(%ebp),%eax
f010332a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010332d:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103330:	85 c0                	test   %eax,%eax
f0103332:	75 24                	jne    f0103358 <envid2env+0x3a>
		*env_store = curenv;
f0103334:	e8 e3 24 00 00       	call   f010581c <cpunum>
f0103339:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103340:	29 c2                	sub    %eax,%edx
f0103342:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103345:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f010334c:	89 06                	mov    %eax,(%esi)
		return 0;
f010334e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103353:	e9 84 00 00 00       	jmp    f01033dc <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103358:	89 c3                	mov    %eax,%ebx
f010335a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103360:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0103367:	c1 e3 07             	shl    $0x7,%ebx
f010336a:	29 cb                	sub    %ecx,%ebx
f010336c:	03 1d 3c e2 2d f0    	add    0xf02de23c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103372:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103376:	74 05                	je     f010337d <envid2env+0x5f>
f0103378:	39 43 48             	cmp    %eax,0x48(%ebx)
f010337b:	74 0d                	je     f010338a <envid2env+0x6c>
		*env_store = 0;
f010337d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103383:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103388:	eb 52                	jmp    f01033dc <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010338a:	84 d2                	test   %dl,%dl
f010338c:	74 47                	je     f01033d5 <envid2env+0xb7>
f010338e:	e8 89 24 00 00       	call   f010581c <cpunum>
f0103393:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010339a:	29 c2                	sub    %eax,%edx
f010339c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010339f:	39 1c 85 28 f0 2d f0 	cmp    %ebx,-0xfd20fd8(,%eax,4)
f01033a6:	74 2d                	je     f01033d5 <envid2env+0xb7>
f01033a8:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01033ab:	e8 6c 24 00 00       	call   f010581c <cpunum>
f01033b0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01033b7:	29 c2                	sub    %eax,%edx
f01033b9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01033bc:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f01033c3:	3b 78 48             	cmp    0x48(%eax),%edi
f01033c6:	74 0d                	je     f01033d5 <envid2env+0xb7>
		*env_store = 0;
f01033c8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01033ce:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01033d3:	eb 07                	jmp    f01033dc <envid2env+0xbe>
	}

	*env_store = e;
f01033d5:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01033d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033dc:	83 c4 0c             	add    $0xc,%esp
f01033df:	5b                   	pop    %ebx
f01033e0:	5e                   	pop    %esi
f01033e1:	5f                   	pop    %edi
f01033e2:	c9                   	leave  
f01033e3:	c3                   	ret    

f01033e4 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01033e4:	55                   	push   %ebp
f01033e5:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01033e7:	b8 68 73 12 f0       	mov    $0xf0127368,%eax
f01033ec:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01033ef:	b8 23 00 00 00       	mov    $0x23,%eax
f01033f4:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01033f6:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01033f8:	b0 10                	mov    $0x10,%al
f01033fa:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01033fc:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01033fe:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103400:	ea 07 34 10 f0 08 00 	ljmp   $0x8,$0xf0103407
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103407:	b0 00                	mov    $0x0,%al
f0103409:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010340c:	c9                   	leave  
f010340d:	c3                   	ret    

f010340e <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010340e:	55                   	push   %ebp
f010340f:	89 e5                	mov    %esp,%ebp
f0103411:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
f0103412:	8b 1d 3c e2 2d f0    	mov    0xf02de23c,%ebx
f0103418:	89 1d 40 e2 2d f0    	mov    %ebx,0xf02de240
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
f010341e:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        envs[i].env_status = ENV_FREE;
f0103425:	c7 43 54 00 00 00 00 	movl   $0x0,0x54(%ebx)
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f010342c:	8d 43 7c             	lea    0x7c(%ebx),%eax
f010342f:	8d 8b 00 f0 01 00    	lea    0x1f000(%ebx),%ecx
f0103435:	89 c2                	mov    %eax,%edx
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0103437:	89 43 44             	mov    %eax,0x44(%ebx)
{
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
f010343a:	39 c8                	cmp    %ecx,%eax
f010343c:	74 1c                	je     f010345a <env_init+0x4c>
        envs[i].env_id = 0;
f010343e:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE;
f0103445:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f010344c:	83 c0 7c             	add    $0x7c,%eax
        if (i + 1 != NENV)
f010344f:	39 c8                	cmp    %ecx,%eax
f0103451:	75 0f                	jne    f0103462 <env_init+0x54>
            envs[i].env_link = envs + (i + 1);
        else 
            envs[i].env_link = NULL;
f0103453:	c7 42 44 00 00 00 00 	movl   $0x0,0x44(%edx)
    }

	// Per-CPU part of the initialization
	env_init_percpu();
f010345a:	e8 85 ff ff ff       	call   f01033e4 <env_init_percpu>
}
f010345f:	5b                   	pop    %ebx
f0103460:	c9                   	leave  
f0103461:	c3                   	ret    
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0103462:	89 42 44             	mov    %eax,0x44(%edx)
f0103465:	89 c2                	mov    %eax,%edx
f0103467:	eb d5                	jmp    f010343e <env_init+0x30>

f0103469 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103469:	55                   	push   %ebp
f010346a:	89 e5                	mov    %esp,%ebp
f010346c:	56                   	push   %esi
f010346d:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010346e:	8b 35 40 e2 2d f0    	mov    0xf02de240,%esi
f0103474:	85 f6                	test   %esi,%esi
f0103476:	0f 84 c6 01 00 00    	je     f0103642 <env_alloc+0x1d9>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010347c:	83 ec 0c             	sub    $0xc,%esp
f010347f:	6a 01                	push   $0x1
f0103481:	e8 1e e1 ff ff       	call   f01015a4 <page_alloc>
f0103486:	89 c3                	mov    %eax,%ebx
f0103488:	83 c4 10             	add    $0x10,%esp
f010348b:	85 c0                	test   %eax,%eax
f010348d:	0f 84 b6 01 00 00    	je     f0103649 <env_alloc+0x1e0>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    cprintf("env_setup_vm in\n");
f0103493:	83 ec 0c             	sub    $0xc,%esp
f0103496:	68 ba 75 10 f0       	push   $0xf01075ba
f010349b:	e8 d9 07 00 00       	call   f0103c79 <cprintf>

    p->pp_ref++;
f01034a0:	66 ff 43 04          	incw   0x4(%ebx)
f01034a4:	2b 1d 10 ef 2d f0    	sub    0xf02def10,%ebx
f01034aa:	c1 fb 03             	sar    $0x3,%ebx
f01034ad:	c1 e3 0c             	shl    $0xc,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034b0:	89 d8                	mov    %ebx,%eax
f01034b2:	c1 e8 0c             	shr    $0xc,%eax
f01034b5:	83 c4 10             	add    $0x10,%esp
f01034b8:	3b 05 08 ef 2d f0    	cmp    0xf02def08,%eax
f01034be:	72 12                	jb     f01034d2 <env_alloc+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01034c0:	53                   	push   %ebx
f01034c1:	68 08 5f 10 f0       	push   $0xf0105f08
f01034c6:	6a 58                	push   $0x58
f01034c8:	68 9d 72 10 f0       	push   $0xf010729d
f01034cd:	e8 96 cb ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f01034d2:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
    e->env_pgdir = (pde_t *)page2kva(p);
f01034d8:	89 5e 60             	mov    %ebx,0x60(%esi)
    // pay attention: have we set mapped in kern_pgdir ?
    // page_insert(kern_pgdir, p, (void *)e->env_pgdir, PTE_U | PTE_W); 

    memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01034db:	83 ec 04             	sub    $0x4,%esp
f01034de:	68 00 10 00 00       	push   $0x1000
f01034e3:	ff 35 0c ef 2d f0    	pushl  0xf02def0c
f01034e9:	53                   	push   %ebx
f01034ea:	e8 b2 1d 00 00       	call   f01052a1 <memcpy>
    memset(e->env_pgdir, 0, PDX(UTOP) * sizeof(pde_t));
f01034ef:	83 c4 0c             	add    $0xc,%esp
f01034f2:	68 ec 0e 00 00       	push   $0xeec
f01034f7:	6a 00                	push   $0x0
f01034f9:	ff 76 60             	pushl  0x60(%esi)
f01034fc:	e8 ec 1c 00 00       	call   f01051ed <memset>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103501:	8b 46 60             	mov    0x60(%esi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103504:	83 c4 10             	add    $0x10,%esp
f0103507:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010350c:	77 15                	ja     f0103523 <env_alloc+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010350e:	50                   	push   %eax
f010350f:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0103514:	68 cf 00 00 00       	push   $0xcf
f0103519:	68 af 75 10 f0       	push   $0xf01075af
f010351e:	e8 45 cb ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103523:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103529:	83 ca 05             	or     $0x5,%edx
f010352c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)

    cprintf("env_setup_vm out\n");
f0103532:	83 ec 0c             	sub    $0xc,%esp
f0103535:	68 cb 75 10 f0       	push   $0xf01075cb
f010353a:	e8 3a 07 00 00       	call   f0103c79 <cprintf>
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
    
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010353f:	8b 46 48             	mov    0x48(%esi),%eax
f0103542:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103547:	83 c4 10             	add    $0x10,%esp
f010354a:	89 c1                	mov    %eax,%ecx
f010354c:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0103552:	7f 05                	jg     f0103559 <env_alloc+0xf0>
		generation = 1 << ENVGENSHIFT;
f0103554:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0103559:	89 f0                	mov    %esi,%eax
f010355b:	2b 05 3c e2 2d f0    	sub    0xf02de23c,%eax
f0103561:	c1 f8 02             	sar    $0x2,%eax
f0103564:	89 c3                	mov    %eax,%ebx
f0103566:	c1 e3 05             	shl    $0x5,%ebx
f0103569:	89 c2                	mov    %eax,%edx
f010356b:	c1 e2 0a             	shl    $0xa,%edx
f010356e:	8d 14 13             	lea    (%ebx,%edx,1),%edx
f0103571:	01 c2                	add    %eax,%edx
f0103573:	89 d3                	mov    %edx,%ebx
f0103575:	c1 e3 0f             	shl    $0xf,%ebx
f0103578:	01 da                	add    %ebx,%edx
f010357a:	c1 e2 05             	shl    $0x5,%edx
f010357d:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0103580:	f7 d8                	neg    %eax
f0103582:	09 c1                	or     %eax,%ecx
f0103584:	89 4e 48             	mov    %ecx,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103587:	8b 45 0c             	mov    0xc(%ebp),%eax
f010358a:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f010358d:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0103594:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f010359b:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01035a2:	83 ec 04             	sub    $0x4,%esp
f01035a5:	6a 44                	push   $0x44
f01035a7:	6a 00                	push   $0x0
f01035a9:	56                   	push   %esi
f01035aa:	e8 3e 1c 00 00       	call   f01051ed <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01035af:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f01035b5:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f01035bb:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f01035c1:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f01035c8:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01035ce:	c7 46 64 00 00 00 00 	movl   $0x0,0x64(%esi)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01035d5:	c6 46 68 00          	movb   $0x0,0x68(%esi)

	// commit the allocation
	env_free_list = e->env_link;
f01035d9:	8b 46 44             	mov    0x44(%esi),%eax
f01035dc:	a3 40 e2 2d f0       	mov    %eax,0xf02de240
	*newenv_store = e;
f01035e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01035e4:	89 30                	mov    %esi,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01035e6:	8b 5e 48             	mov    0x48(%esi),%ebx
f01035e9:	e8 2e 22 00 00       	call   f010581c <cpunum>
f01035ee:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01035f5:	29 c2                	sub    %eax,%edx
f01035f7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01035fa:	83 c4 10             	add    $0x10,%esp
f01035fd:	83 3c 85 28 f0 2d f0 	cmpl   $0x0,-0xfd20fd8(,%eax,4)
f0103604:	00 
f0103605:	74 1d                	je     f0103624 <env_alloc+0x1bb>
f0103607:	e8 10 22 00 00       	call   f010581c <cpunum>
f010360c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103613:	29 c2                	sub    %eax,%edx
f0103615:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103618:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f010361f:	8b 40 48             	mov    0x48(%eax),%eax
f0103622:	eb 05                	jmp    f0103629 <env_alloc+0x1c0>
f0103624:	b8 00 00 00 00       	mov    $0x0,%eax
f0103629:	83 ec 04             	sub    $0x4,%esp
f010362c:	53                   	push   %ebx
f010362d:	50                   	push   %eax
f010362e:	68 dd 75 10 f0       	push   $0xf01075dd
f0103633:	e8 41 06 00 00       	call   f0103c79 <cprintf>
	return 0;
f0103638:	83 c4 10             	add    $0x10,%esp
f010363b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103640:	eb 0c                	jmp    f010364e <env_alloc+0x1e5>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103642:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103647:	eb 05                	jmp    f010364e <env_alloc+0x1e5>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103649:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010364e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103651:	5b                   	pop    %ebx
f0103652:	5e                   	pop    %esi
f0103653:	c9                   	leave  
f0103654:	c3                   	ret    

f0103655 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103655:	55                   	push   %ebp
f0103656:	89 e5                	mov    %esp,%ebp
f0103658:	57                   	push   %edi
f0103659:	56                   	push   %esi
f010365a:	53                   	push   %ebx
f010365b:	83 ec 34             	sub    $0x34,%esp
f010365e:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("env_create %u %u %u\n", binary, size, type);
	// LAB 3: Your code here.
    struct Env * e;
    int r = env_alloc(&e, 0);
f0103661:	6a 00                	push   $0x0
f0103663:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103666:	50                   	push   %eax
f0103667:	e8 fd fd ff ff       	call   f0103469 <env_alloc>
    if (r < 0) {
f010366c:	83 c4 10             	add    $0x10,%esp
f010366f:	85 c0                	test   %eax,%eax
f0103671:	79 15                	jns    f0103688 <env_create+0x33>
        panic("env_create: %e\n", r);
f0103673:	50                   	push   %eax
f0103674:	68 f2 75 10 f0       	push   $0xf01075f2
f0103679:	68 a4 01 00 00       	push   $0x1a4
f010367e:	68 af 75 10 f0       	push   $0xf01075af
f0103683:	e8 e0 c9 ff ff       	call   f0100068 <_panic>
    }
    load_icode(e, binary, size);
f0103688:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010368b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
f010368e:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103694:	74 17                	je     f01036ad <env_create+0x58>
        panic("error elf magic number\n");
f0103696:	83 ec 04             	sub    $0x4,%esp
f0103699:	68 02 76 10 f0       	push   $0xf0107602
f010369e:	68 79 01 00 00       	push   $0x179
f01036a3:	68 af 75 10 f0       	push   $0xf01075af
f01036a8:	e8 bb c9 ff ff       	call   f0100068 <_panic>
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01036ad:	8b 5e 1c             	mov    0x1c(%esi),%ebx
    eph = ph + elf->e_phnum;
f01036b0:	8b 7e 2c             	mov    0x2c(%esi),%edi

    lcr3(PADDR(e->env_pgdir));
f01036b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01036b6:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036b9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036be:	77 15                	ja     f01036d5 <env_create+0x80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036c0:	50                   	push   %eax
f01036c1:	68 e4 5e 10 f0       	push   $0xf0105ee4
f01036c6:	68 7f 01 00 00       	push   $0x17f
f01036cb:	68 af 75 10 f0       	push   $0xf01075af
f01036d0:	e8 93 c9 ff ff       	call   f0100068 <_panic>
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
        panic("error elf magic number\n");
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01036d5:	8d 1c 1e             	lea    (%esi,%ebx,1),%ebx
    eph = ph + elf->e_phnum;
f01036d8:	0f b7 ff             	movzwl %di,%edi
f01036db:	c1 e7 05             	shl    $0x5,%edi
f01036de:	8d 3c 3b             	lea    (%ebx,%edi,1),%edi
	return (physaddr_t)kva - KERNBASE;
f01036e1:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01036e6:	0f 22 d8             	mov    %eax,%cr3

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01036e9:	39 fb                	cmp    %edi,%ebx
f01036eb:	73 48                	jae    f0103735 <env_create+0xe0>
        if (ph->p_type == ELF_PROG_LOAD) {
f01036ed:	83 3b 01             	cmpl   $0x1,(%ebx)
f01036f0:	75 3c                	jne    f010372e <env_create+0xd9>
            // cprintf("%u %u\n", ph->p_memsz, ph->p_filesz);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01036f2:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01036f5:	8b 53 08             	mov    0x8(%ebx),%edx
f01036f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01036fb:	e8 98 fb ff ff       	call   f0103298 <region_alloc>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103700:	83 ec 04             	sub    $0x4,%esp
f0103703:	ff 73 10             	pushl  0x10(%ebx)
f0103706:	89 f0                	mov    %esi,%eax
f0103708:	03 43 04             	add    0x4(%ebx),%eax
f010370b:	50                   	push   %eax
f010370c:	ff 73 08             	pushl  0x8(%ebx)
f010370f:	e8 8d 1b 00 00       	call   f01052a1 <memcpy>
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0103714:	8b 43 10             	mov    0x10(%ebx),%eax
f0103717:	83 c4 0c             	add    $0xc,%esp
f010371a:	8b 53 14             	mov    0x14(%ebx),%edx
f010371d:	29 c2                	sub    %eax,%edx
f010371f:	52                   	push   %edx
f0103720:	6a 00                	push   $0x0
f0103722:	03 43 08             	add    0x8(%ebx),%eax
f0103725:	50                   	push   %eax
f0103726:	e8 c2 1a 00 00       	call   f01051ed <memset>
f010372b:	83 c4 10             	add    $0x10,%esp
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
    eph = ph + elf->e_phnum;

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f010372e:	83 c3 20             	add    $0x20,%ebx
f0103731:	39 df                	cmp    %ebx,%edi
f0103733:	77 b8                	ja     f01036ed <env_create+0x98>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
        }
    }
    e->env_tf.tf_eip = elf->e_entry;
f0103735:	8b 46 18             	mov    0x18(%esi),%eax
f0103738:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010373b:	89 42 30             	mov    %eax,0x30(%edx)

    lcr3(PADDR(kern_pgdir));
f010373e:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103743:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103748:	77 15                	ja     f010375f <env_create+0x10a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010374a:	50                   	push   %eax
f010374b:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0103750:	68 8b 01 00 00       	push   $0x18b
f0103755:	68 af 75 10 f0       	push   $0xf01075af
f010375a:	e8 09 c9 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010375f:	05 00 00 00 10       	add    $0x10000000,%eax
f0103764:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103767:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010376c:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103771:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103774:	e8 1f fb ff ff       	call   f0103298 <region_alloc>
    int r = env_alloc(&e, 0);
    if (r < 0) {
        panic("env_create: %e\n", r);
    }
    load_icode(e, binary, size);
    e->env_type = type;
f0103779:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010377c:	8b 55 10             	mov    0x10(%ebp),%edx
f010377f:	89 50 50             	mov    %edx,0x50(%eax)
    // cprintf("env_create out\n");
    return;
}
f0103782:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103785:	5b                   	pop    %ebx
f0103786:	5e                   	pop    %esi
f0103787:	5f                   	pop    %edi
f0103788:	c9                   	leave  
f0103789:	c3                   	ret    

f010378a <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010378a:	55                   	push   %ebp
f010378b:	89 e5                	mov    %esp,%ebp
f010378d:	57                   	push   %edi
f010378e:	56                   	push   %esi
f010378f:	53                   	push   %ebx
f0103790:	83 ec 1c             	sub    $0x1c,%esp
f0103793:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103796:	e8 81 20 00 00       	call   f010581c <cpunum>
f010379b:	6b c0 74             	imul   $0x74,%eax,%eax
f010379e:	39 b8 28 f0 2d f0    	cmp    %edi,-0xfd20fd8(%eax)
f01037a4:	75 29                	jne    f01037cf <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01037a6:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037ab:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037b0:	77 15                	ja     f01037c7 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037b2:	50                   	push   %eax
f01037b3:	68 e4 5e 10 f0       	push   $0xf0105ee4
f01037b8:	68 ba 01 00 00       	push   $0x1ba
f01037bd:	68 af 75 10 f0       	push   $0xf01075af
f01037c2:	e8 a1 c8 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01037c7:	05 00 00 00 10       	add    $0x10000000,%eax
f01037cc:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01037cf:	8b 5f 48             	mov    0x48(%edi),%ebx
f01037d2:	e8 45 20 00 00       	call   f010581c <cpunum>
f01037d7:	6b d0 74             	imul   $0x74,%eax,%edx
f01037da:	b8 00 00 00 00       	mov    $0x0,%eax
f01037df:	83 ba 28 f0 2d f0 00 	cmpl   $0x0,-0xfd20fd8(%edx)
f01037e6:	74 11                	je     f01037f9 <env_free+0x6f>
f01037e8:	e8 2f 20 00 00       	call   f010581c <cpunum>
f01037ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01037f0:	8b 80 28 f0 2d f0    	mov    -0xfd20fd8(%eax),%eax
f01037f6:	8b 40 48             	mov    0x48(%eax),%eax
f01037f9:	83 ec 04             	sub    $0x4,%esp
f01037fc:	53                   	push   %ebx
f01037fd:	50                   	push   %eax
f01037fe:	68 1a 76 10 f0       	push   $0xf010761a
f0103803:	e8 71 04 00 00       	call   f0103c79 <cprintf>
f0103808:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010380b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103812:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103815:	c1 e0 02             	shl    $0x2,%eax
f0103818:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010381b:	8b 47 60             	mov    0x60(%edi),%eax
f010381e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103821:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103824:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010382a:	0f 84 ab 00 00 00    	je     f01038db <env_free+0x151>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103830:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103836:	89 f0                	mov    %esi,%eax
f0103838:	c1 e8 0c             	shr    $0xc,%eax
f010383b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010383e:	3b 05 08 ef 2d f0    	cmp    0xf02def08,%eax
f0103844:	72 15                	jb     f010385b <env_free+0xd1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103846:	56                   	push   %esi
f0103847:	68 08 5f 10 f0       	push   $0xf0105f08
f010384c:	68 c9 01 00 00       	push   $0x1c9
f0103851:	68 af 75 10 f0       	push   $0xf01075af
f0103856:	e8 0d c8 ff ff       	call   f0100068 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010385b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010385e:	c1 e2 16             	shl    $0x16,%edx
f0103861:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103864:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103869:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103870:	01 
f0103871:	74 17                	je     f010388a <env_free+0x100>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103873:	83 ec 08             	sub    $0x8,%esp
f0103876:	89 d8                	mov    %ebx,%eax
f0103878:	c1 e0 0c             	shl    $0xc,%eax
f010387b:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010387e:	50                   	push   %eax
f010387f:	ff 77 60             	pushl  0x60(%edi)
f0103882:	e8 7c df ff ff       	call   f0101803 <page_remove>
f0103887:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010388a:	43                   	inc    %ebx
f010388b:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103891:	75 d6                	jne    f0103869 <env_free+0xdf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103893:	8b 47 60             	mov    0x60(%edi),%eax
f0103896:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103899:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01038a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01038a3:	3b 05 08 ef 2d f0    	cmp    0xf02def08,%eax
f01038a9:	72 14                	jb     f01038bf <env_free+0x135>
		panic("pa2page called with invalid pa");
f01038ab:	83 ec 04             	sub    $0x4,%esp
f01038ae:	68 70 6a 10 f0       	push   $0xf0106a70
f01038b3:	6a 51                	push   $0x51
f01038b5:	68 9d 72 10 f0       	push   $0xf010729d
f01038ba:	e8 a9 c7 ff ff       	call   f0100068 <_panic>
		page_decref(pa2page(pa));
f01038bf:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01038c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01038c5:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01038cc:	03 05 10 ef 2d f0    	add    0xf02def10,%eax
f01038d2:	50                   	push   %eax
f01038d3:	e8 76 dd ff ff       	call   f010164e <page_decref>
f01038d8:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01038db:	ff 45 e0             	incl   -0x20(%ebp)
f01038de:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01038e5:	0f 85 27 ff ff ff    	jne    f0103812 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01038eb:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038ee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038f3:	77 15                	ja     f010390a <env_free+0x180>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038f5:	50                   	push   %eax
f01038f6:	68 e4 5e 10 f0       	push   $0xf0105ee4
f01038fb:	68 d7 01 00 00       	push   $0x1d7
f0103900:	68 af 75 10 f0       	push   $0xf01075af
f0103905:	e8 5e c7 ff ff       	call   f0100068 <_panic>
	e->env_pgdir = 0;
f010390a:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103911:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103916:	c1 e8 0c             	shr    $0xc,%eax
f0103919:	3b 05 08 ef 2d f0    	cmp    0xf02def08,%eax
f010391f:	72 14                	jb     f0103935 <env_free+0x1ab>
		panic("pa2page called with invalid pa");
f0103921:	83 ec 04             	sub    $0x4,%esp
f0103924:	68 70 6a 10 f0       	push   $0xf0106a70
f0103929:	6a 51                	push   $0x51
f010392b:	68 9d 72 10 f0       	push   $0xf010729d
f0103930:	e8 33 c7 ff ff       	call   f0100068 <_panic>
	page_decref(pa2page(pa));
f0103935:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103938:	c1 e0 03             	shl    $0x3,%eax
f010393b:	03 05 10 ef 2d f0    	add    0xf02def10,%eax
f0103941:	50                   	push   %eax
f0103942:	e8 07 dd ff ff       	call   f010164e <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103947:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010394e:	a1 40 e2 2d f0       	mov    0xf02de240,%eax
f0103953:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103956:	89 3d 40 e2 2d f0    	mov    %edi,0xf02de240
f010395c:	83 c4 10             	add    $0x10,%esp
}
f010395f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103962:	5b                   	pop    %ebx
f0103963:	5e                   	pop    %esi
f0103964:	5f                   	pop    %edi
f0103965:	c9                   	leave  
f0103966:	c3                   	ret    

f0103967 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103967:	55                   	push   %ebp
f0103968:	89 e5                	mov    %esp,%ebp
f010396a:	53                   	push   %ebx
f010396b:	83 ec 04             	sub    $0x4,%esp
f010396e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103971:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103975:	75 23                	jne    f010399a <env_destroy+0x33>
f0103977:	e8 a0 1e 00 00       	call   f010581c <cpunum>
f010397c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103983:	29 c2                	sub    %eax,%edx
f0103985:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103988:	39 1c 85 28 f0 2d f0 	cmp    %ebx,-0xfd20fd8(,%eax,4)
f010398f:	74 09                	je     f010399a <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103991:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103998:	eb 3d                	jmp    f01039d7 <env_destroy+0x70>
	}

	env_free(e);
f010399a:	83 ec 0c             	sub    $0xc,%esp
f010399d:	53                   	push   %ebx
f010399e:	e8 e7 fd ff ff       	call   f010378a <env_free>

	if (curenv == e) {
f01039a3:	e8 74 1e 00 00       	call   f010581c <cpunum>
f01039a8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01039af:	29 c2                	sub    %eax,%edx
f01039b1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01039b4:	83 c4 10             	add    $0x10,%esp
f01039b7:	39 1c 85 28 f0 2d f0 	cmp    %ebx,-0xfd20fd8(,%eax,4)
f01039be:	75 17                	jne    f01039d7 <env_destroy+0x70>
		curenv = NULL;
f01039c0:	e8 57 1e 00 00       	call   f010581c <cpunum>
f01039c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01039c8:	c7 80 28 f0 2d f0 00 	movl   $0x0,-0xfd20fd8(%eax)
f01039cf:	00 00 00 
		sched_yield();
f01039d2:	e8 e4 0a 00 00       	call   f01044bb <sched_yield>
	}
}
f01039d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01039da:	c9                   	leave  
f01039db:	c3                   	ret    

f01039dc <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01039dc:	55                   	push   %ebp
f01039dd:	89 e5                	mov    %esp,%ebp
f01039df:	53                   	push   %ebx
f01039e0:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01039e3:	e8 34 1e 00 00       	call   f010581c <cpunum>
f01039e8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01039ef:	29 c2                	sub    %eax,%edx
f01039f1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01039f4:	8b 1c 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%ebx
f01039fb:	e8 1c 1e 00 00       	call   f010581c <cpunum>
f0103a00:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103a03:	8b 65 08             	mov    0x8(%ebp),%esp
f0103a06:	61                   	popa   
f0103a07:	07                   	pop    %es
f0103a08:	1f                   	pop    %ds
f0103a09:	83 c4 08             	add    $0x8,%esp
f0103a0c:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103a0d:	83 ec 04             	sub    $0x4,%esp
f0103a10:	68 30 76 10 f0       	push   $0xf0107630
f0103a15:	68 0d 02 00 00       	push   $0x20d
f0103a1a:	68 af 75 10 f0       	push   $0xf01075af
f0103a1f:	e8 44 c6 ff ff       	call   f0100068 <_panic>

f0103a24 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103a24:	55                   	push   %ebp
f0103a25:	89 e5                	mov    %esp,%ebp
f0103a27:	83 ec 08             	sub    $0x8,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

    if (curenv != NULL) {
f0103a2a:	e8 ed 1d 00 00       	call   f010581c <cpunum>
f0103a2f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a36:	29 c2                	sub    %eax,%edx
f0103a38:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a3b:	83 3c 85 28 f0 2d f0 	cmpl   $0x0,-0xfd20fd8(,%eax,4)
f0103a42:	00 
f0103a43:	74 3d                	je     f0103a82 <env_run+0x5e>
        // context switch
        if (curenv->env_status == ENV_RUNNING) {
f0103a45:	e8 d2 1d 00 00       	call   f010581c <cpunum>
f0103a4a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a51:	29 c2                	sub    %eax,%edx
f0103a53:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a56:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f0103a5d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103a61:	75 1f                	jne    f0103a82 <env_run+0x5e>
            curenv->env_status = ENV_RUNNABLE;
f0103a63:	e8 b4 1d 00 00       	call   f010581c <cpunum>
f0103a68:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a6f:	29 c2                	sub    %eax,%edx
f0103a71:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a74:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f0103a7b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
        }
        // how about other env_status ? e.g. like ENV_DYING ?
    }
    curenv = e;
f0103a82:	e8 95 1d 00 00       	call   f010581c <cpunum>
f0103a87:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a8e:	29 c2                	sub    %eax,%edx
f0103a90:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a93:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a96:	89 14 85 28 f0 2d f0 	mov    %edx,-0xfd20fd8(,%eax,4)
    curenv->env_status = ENV_RUNNING;
f0103a9d:	e8 7a 1d 00 00       	call   f010581c <cpunum>
f0103aa2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103aa9:	29 c2                	sub    %eax,%edx
f0103aab:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103aae:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f0103ab5:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f0103abc:	e8 5b 1d 00 00       	call   f010581c <cpunum>
f0103ac1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ac8:	29 c2                	sub    %eax,%edx
f0103aca:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103acd:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f0103ad4:	ff 40 58             	incl   0x58(%eax)
    
    // may have some problem, because lcr3(x), x should be physical address
    lcr3(PADDR(curenv->env_pgdir));
f0103ad7:	e8 40 1d 00 00       	call   f010581c <cpunum>
f0103adc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ae3:	29 c2                	sub    %eax,%edx
f0103ae5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ae8:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f0103aef:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103af2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103af7:	77 15                	ja     f0103b0e <env_run+0xea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103af9:	50                   	push   %eax
f0103afa:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0103aff:	68 38 02 00 00       	push   $0x238
f0103b04:	68 af 75 10 f0       	push   $0xf01075af
f0103b09:	e8 5a c5 ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b0e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103b13:	0f 22 d8             	mov    %eax,%cr3

    env_pop_tf(&curenv->env_tf);    
f0103b16:	e8 01 1d 00 00       	call   f010581c <cpunum>
f0103b1b:	83 ec 0c             	sub    $0xc,%esp
f0103b1e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b25:	29 c2                	sub    %eax,%edx
f0103b27:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b2a:	ff 34 85 28 f0 2d f0 	pushl  -0xfd20fd8(,%eax,4)
f0103b31:	e8 a6 fe ff ff       	call   f01039dc <env_pop_tf>
	...

f0103b38 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103b38:	55                   	push   %ebp
f0103b39:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103b3b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103b40:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b43:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103b44:	b2 71                	mov    $0x71,%dl
f0103b46:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103b47:	0f b6 c0             	movzbl %al,%eax
}
f0103b4a:	c9                   	leave  
f0103b4b:	c3                   	ret    

f0103b4c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103b4c:	55                   	push   %ebp
f0103b4d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103b4f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103b54:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b57:	ee                   	out    %al,(%dx)
f0103b58:	b2 71                	mov    $0x71,%dl
f0103b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b5d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103b5e:	c9                   	leave  
f0103b5f:	c3                   	ret    

f0103b60 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103b60:	55                   	push   %ebp
f0103b61:	89 e5                	mov    %esp,%ebp
f0103b63:	56                   	push   %esi
f0103b64:	53                   	push   %ebx
f0103b65:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b68:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103b6a:	66 a3 70 73 12 f0    	mov    %ax,0xf0127370
	if (!didinit)
f0103b70:	80 3d 44 e2 2d f0 00 	cmpb   $0x0,0xf02de244
f0103b77:	74 5a                	je     f0103bd3 <irq_setmask_8259A+0x73>
f0103b79:	ba 21 00 00 00       	mov    $0x21,%edx
f0103b7e:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103b7f:	89 f0                	mov    %esi,%eax
f0103b81:	66 c1 e8 08          	shr    $0x8,%ax
f0103b85:	b2 a1                	mov    $0xa1,%dl
f0103b87:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103b88:	83 ec 0c             	sub    $0xc,%esp
f0103b8b:	68 3c 76 10 f0       	push   $0xf010763c
f0103b90:	e8 e4 00 00 00       	call   f0103c79 <cprintf>
f0103b95:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103b98:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103b9d:	0f b7 f6             	movzwl %si,%esi
f0103ba0:	f7 d6                	not    %esi
f0103ba2:	89 f0                	mov    %esi,%eax
f0103ba4:	88 d9                	mov    %bl,%cl
f0103ba6:	d3 f8                	sar    %cl,%eax
f0103ba8:	a8 01                	test   $0x1,%al
f0103baa:	74 11                	je     f0103bbd <irq_setmask_8259A+0x5d>
			cprintf(" %d", i);
f0103bac:	83 ec 08             	sub    $0x8,%esp
f0103baf:	53                   	push   %ebx
f0103bb0:	68 27 7b 10 f0       	push   $0xf0107b27
f0103bb5:	e8 bf 00 00 00       	call   f0103c79 <cprintf>
f0103bba:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103bbd:	43                   	inc    %ebx
f0103bbe:	83 fb 10             	cmp    $0x10,%ebx
f0103bc1:	75 df                	jne    f0103ba2 <irq_setmask_8259A+0x42>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103bc3:	83 ec 0c             	sub    $0xc,%esp
f0103bc6:	68 2f 62 10 f0       	push   $0xf010622f
f0103bcb:	e8 a9 00 00 00       	call   f0103c79 <cprintf>
f0103bd0:	83 c4 10             	add    $0x10,%esp
}
f0103bd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103bd6:	5b                   	pop    %ebx
f0103bd7:	5e                   	pop    %esi
f0103bd8:	c9                   	leave  
f0103bd9:	c3                   	ret    

f0103bda <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103bda:	55                   	push   %ebp
f0103bdb:	89 e5                	mov    %esp,%ebp
f0103bdd:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f0103be0:	c6 05 44 e2 2d f0 01 	movb   $0x1,0xf02de244
f0103be7:	ba 21 00 00 00       	mov    $0x21,%edx
f0103bec:	b0 ff                	mov    $0xff,%al
f0103bee:	ee                   	out    %al,(%dx)
f0103bef:	b2 a1                	mov    $0xa1,%dl
f0103bf1:	ee                   	out    %al,(%dx)
f0103bf2:	b2 20                	mov    $0x20,%dl
f0103bf4:	b0 11                	mov    $0x11,%al
f0103bf6:	ee                   	out    %al,(%dx)
f0103bf7:	b2 21                	mov    $0x21,%dl
f0103bf9:	b0 20                	mov    $0x20,%al
f0103bfb:	ee                   	out    %al,(%dx)
f0103bfc:	b0 04                	mov    $0x4,%al
f0103bfe:	ee                   	out    %al,(%dx)
f0103bff:	b0 03                	mov    $0x3,%al
f0103c01:	ee                   	out    %al,(%dx)
f0103c02:	b2 a0                	mov    $0xa0,%dl
f0103c04:	b0 11                	mov    $0x11,%al
f0103c06:	ee                   	out    %al,(%dx)
f0103c07:	b2 a1                	mov    $0xa1,%dl
f0103c09:	b0 28                	mov    $0x28,%al
f0103c0b:	ee                   	out    %al,(%dx)
f0103c0c:	b0 02                	mov    $0x2,%al
f0103c0e:	ee                   	out    %al,(%dx)
f0103c0f:	b0 01                	mov    $0x1,%al
f0103c11:	ee                   	out    %al,(%dx)
f0103c12:	b2 20                	mov    $0x20,%dl
f0103c14:	b0 68                	mov    $0x68,%al
f0103c16:	ee                   	out    %al,(%dx)
f0103c17:	b0 0a                	mov    $0xa,%al
f0103c19:	ee                   	out    %al,(%dx)
f0103c1a:	b2 a0                	mov    $0xa0,%dl
f0103c1c:	b0 68                	mov    $0x68,%al
f0103c1e:	ee                   	out    %al,(%dx)
f0103c1f:	b0 0a                	mov    $0xa,%al
f0103c21:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103c22:	66 a1 70 73 12 f0    	mov    0xf0127370,%ax
f0103c28:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103c2c:	74 0f                	je     f0103c3d <pic_init+0x63>
		irq_setmask_8259A(irq_mask_8259A);
f0103c2e:	83 ec 0c             	sub    $0xc,%esp
f0103c31:	0f b7 c0             	movzwl %ax,%eax
f0103c34:	50                   	push   %eax
f0103c35:	e8 26 ff ff ff       	call   f0103b60 <irq_setmask_8259A>
f0103c3a:	83 c4 10             	add    $0x10,%esp
}
f0103c3d:	c9                   	leave  
f0103c3e:	c3                   	ret    
	...

f0103c40 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103c40:	55                   	push   %ebp
f0103c41:	89 e5                	mov    %esp,%ebp
f0103c43:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103c46:	ff 75 08             	pushl  0x8(%ebp)
f0103c49:	e8 2d cb ff ff       	call   f010077b <cputchar>
f0103c4e:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0103c51:	c9                   	leave  
f0103c52:	c3                   	ret    

f0103c53 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103c53:	55                   	push   %ebp
f0103c54:	89 e5                	mov    %esp,%ebp
f0103c56:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103c59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103c60:	ff 75 0c             	pushl  0xc(%ebp)
f0103c63:	ff 75 08             	pushl  0x8(%ebp)
f0103c66:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103c69:	50                   	push   %eax
f0103c6a:	68 40 3c 10 f0       	push   $0xf0103c40
f0103c6f:	e8 e1 0e 00 00       	call   f0104b55 <vprintfmt>
	return cnt;
}
f0103c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c77:	c9                   	leave  
f0103c78:	c3                   	ret    

f0103c79 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103c79:	55                   	push   %ebp
f0103c7a:	89 e5                	mov    %esp,%ebp
f0103c7c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103c7f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103c82:	50                   	push   %eax
f0103c83:	ff 75 08             	pushl  0x8(%ebp)
f0103c86:	e8 c8 ff ff ff       	call   f0103c53 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103c8b:	c9                   	leave  
f0103c8c:	c3                   	ret    
f0103c8d:	00 00                	add    %al,(%eax)
	...

f0103c90 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103c90:	55                   	push   %ebp
f0103c91:	89 e5                	mov    %esp,%ebp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103c93:	c7 05 84 ea 2d f0 00 	movl   $0xf0000000,0xf02dea84
f0103c9a:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103c9d:	66 c7 05 88 ea 2d f0 	movw   $0x10,0xf02dea88
f0103ca4:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103ca6:	66 c7 05 28 73 12 f0 	movw   $0x68,0xf0127328
f0103cad:	68 00 
f0103caf:	b8 80 ea 2d f0       	mov    $0xf02dea80,%eax
f0103cb4:	66 a3 2a 73 12 f0    	mov    %ax,0xf012732a
f0103cba:	89 c2                	mov    %eax,%edx
f0103cbc:	c1 ea 10             	shr    $0x10,%edx
f0103cbf:	88 15 2c 73 12 f0    	mov    %dl,0xf012732c
f0103cc5:	c6 05 2e 73 12 f0 40 	movb   $0x40,0xf012732e
f0103ccc:	c1 e8 18             	shr    $0x18,%eax
f0103ccf:	a2 2f 73 12 f0       	mov    %al,0xf012732f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103cd4:	c6 05 2d 73 12 f0 89 	movb   $0x89,0xf012732d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103cdb:	b8 28 00 00 00       	mov    $0x28,%eax
f0103ce0:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103ce3:	b8 74 73 12 f0       	mov    $0xf0127374,%eax
f0103ce8:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103ceb:	c9                   	leave  
f0103cec:	c3                   	ret    

f0103ced <trap_init>:
}


void
trap_init(void)
{
f0103ced:	55                   	push   %ebp
f0103cee:	89 e5                	mov    %esp,%ebp
f0103cf0:	ba 01 00 00 00       	mov    $0x1,%edx
f0103cf5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103cfa:	eb 02                	jmp    f0103cfe <trap_init+0x11>
f0103cfc:	40                   	inc    %eax
f0103cfd:	42                   	inc    %edx
    
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
    	if (i == T_BRKPT) {
f0103cfe:	83 f8 03             	cmp    $0x3,%eax
f0103d01:	75 30                	jne    f0103d33 <trap_init+0x46>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
f0103d03:	8b 0d 88 73 12 f0    	mov    0xf0127388,%ecx
f0103d09:	66 89 0d 78 e2 2d f0 	mov    %cx,0xf02de278
f0103d10:	66 c7 05 7a e2 2d f0 	movw   $0x8,0xf02de27a
f0103d17:	08 00 
f0103d19:	c6 05 7c e2 2d f0 00 	movb   $0x0,0xf02de27c
f0103d20:	c6 05 7d e2 2d f0 ee 	movb   $0xee,0xf02de27d
f0103d27:	c1 e9 10             	shr    $0x10,%ecx
f0103d2a:	66 89 0d 7e e2 2d f0 	mov    %cx,0xf02de27e
f0103d31:	eb c9                	jmp    f0103cfc <trap_init+0xf>
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f0103d33:	8b 0c 85 7c 73 12 f0 	mov    -0xfed8c84(,%eax,4),%ecx
f0103d3a:	66 89 0c c5 60 e2 2d 	mov    %cx,-0xfd21da0(,%eax,8)
f0103d41:	f0 
f0103d42:	66 c7 04 c5 62 e2 2d 	movw   $0x8,-0xfd21d9e(,%eax,8)
f0103d49:	f0 08 00 
f0103d4c:	c6 04 c5 64 e2 2d f0 	movb   $0x0,-0xfd21d9c(,%eax,8)
f0103d53:	00 
f0103d54:	c6 04 c5 65 e2 2d f0 	movb   $0x8e,-0xfd21d9b(,%eax,8)
f0103d5b:	8e 
f0103d5c:	c1 e9 10             	shr    $0x10,%ecx
f0103d5f:	66 89 0c c5 66 e2 2d 	mov    %cx,-0xfd21d9a(,%eax,8)
f0103d66:	f0 
    */
    
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
f0103d67:	83 fa 14             	cmp    $0x14,%edx
f0103d6a:	75 90                	jne    f0103cfc <trap_init+0xf>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
    	}
    }
    SETGATE(idt[48], 0, GD_KT, vec48, 3);
f0103d6c:	b8 cc 73 12 f0       	mov    $0xf01273cc,%eax
f0103d71:	66 a3 e0 e3 2d f0    	mov    %ax,0xf02de3e0
f0103d77:	66 c7 05 e2 e3 2d f0 	movw   $0x8,0xf02de3e2
f0103d7e:	08 00 
f0103d80:	c6 05 e4 e3 2d f0 00 	movb   $0x0,0xf02de3e4
f0103d87:	c6 05 e5 e3 2d f0 ee 	movb   $0xee,0xf02de3e5
f0103d8e:	c1 e8 10             	shr    $0x10,%eax
f0103d91:	66 a3 e6 e3 2d f0    	mov    %ax,0xf02de3e6

	// Per-CPU setup 
	trap_init_percpu();
f0103d97:	e8 f4 fe ff ff       	call   f0103c90 <trap_init_percpu>
}
f0103d9c:	c9                   	leave  
f0103d9d:	c3                   	ret    

f0103d9e <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d9e:	55                   	push   %ebp
f0103d9f:	89 e5                	mov    %esp,%ebp
f0103da1:	53                   	push   %ebx
f0103da2:	83 ec 0c             	sub    $0xc,%esp
f0103da5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103da8:	ff 33                	pushl  (%ebx)
f0103daa:	68 50 76 10 f0       	push   $0xf0107650
f0103daf:	e8 c5 fe ff ff       	call   f0103c79 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103db4:	83 c4 08             	add    $0x8,%esp
f0103db7:	ff 73 04             	pushl  0x4(%ebx)
f0103dba:	68 5f 76 10 f0       	push   $0xf010765f
f0103dbf:	e8 b5 fe ff ff       	call   f0103c79 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103dc4:	83 c4 08             	add    $0x8,%esp
f0103dc7:	ff 73 08             	pushl  0x8(%ebx)
f0103dca:	68 6e 76 10 f0       	push   $0xf010766e
f0103dcf:	e8 a5 fe ff ff       	call   f0103c79 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103dd4:	83 c4 08             	add    $0x8,%esp
f0103dd7:	ff 73 0c             	pushl  0xc(%ebx)
f0103dda:	68 7d 76 10 f0       	push   $0xf010767d
f0103ddf:	e8 95 fe ff ff       	call   f0103c79 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103de4:	83 c4 08             	add    $0x8,%esp
f0103de7:	ff 73 10             	pushl  0x10(%ebx)
f0103dea:	68 8c 76 10 f0       	push   $0xf010768c
f0103def:	e8 85 fe ff ff       	call   f0103c79 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103df4:	83 c4 08             	add    $0x8,%esp
f0103df7:	ff 73 14             	pushl  0x14(%ebx)
f0103dfa:	68 9b 76 10 f0       	push   $0xf010769b
f0103dff:	e8 75 fe ff ff       	call   f0103c79 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e04:	83 c4 08             	add    $0x8,%esp
f0103e07:	ff 73 18             	pushl  0x18(%ebx)
f0103e0a:	68 aa 76 10 f0       	push   $0xf01076aa
f0103e0f:	e8 65 fe ff ff       	call   f0103c79 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e14:	83 c4 08             	add    $0x8,%esp
f0103e17:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e1a:	68 b9 76 10 f0       	push   $0xf01076b9
f0103e1f:	e8 55 fe ff ff       	call   f0103c79 <cprintf>
f0103e24:	83 c4 10             	add    $0x10,%esp
}
f0103e27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e2a:	c9                   	leave  
f0103e2b:	c3                   	ret    

f0103e2c <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103e2c:	55                   	push   %ebp
f0103e2d:	89 e5                	mov    %esp,%ebp
f0103e2f:	53                   	push   %ebx
f0103e30:	83 ec 04             	sub    $0x4,%esp
f0103e33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e36:	e8 e1 19 00 00       	call   f010581c <cpunum>
f0103e3b:	83 ec 04             	sub    $0x4,%esp
f0103e3e:	50                   	push   %eax
f0103e3f:	53                   	push   %ebx
f0103e40:	68 1d 77 10 f0       	push   $0xf010771d
f0103e45:	e8 2f fe ff ff       	call   f0103c79 <cprintf>
	print_regs(&tf->tf_regs);
f0103e4a:	89 1c 24             	mov    %ebx,(%esp)
f0103e4d:	e8 4c ff ff ff       	call   f0103d9e <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103e52:	83 c4 08             	add    $0x8,%esp
f0103e55:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103e59:	50                   	push   %eax
f0103e5a:	68 3b 77 10 f0       	push   $0xf010773b
f0103e5f:	e8 15 fe ff ff       	call   f0103c79 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e64:	83 c4 08             	add    $0x8,%esp
f0103e67:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103e6b:	50                   	push   %eax
f0103e6c:	68 4e 77 10 f0       	push   $0xf010774e
f0103e71:	e8 03 fe ff ff       	call   f0103c79 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e76:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103e79:	83 c4 10             	add    $0x10,%esp
f0103e7c:	83 f8 13             	cmp    $0x13,%eax
f0103e7f:	77 09                	ja     f0103e8a <print_trapframe+0x5e>
		return excnames[trapno];
f0103e81:	8b 14 85 20 7a 10 f0 	mov    -0xfef85e0(,%eax,4),%edx
f0103e88:	eb 20                	jmp    f0103eaa <print_trapframe+0x7e>
	if (trapno == T_SYSCALL)
f0103e8a:	83 f8 30             	cmp    $0x30,%eax
f0103e8d:	74 0f                	je     f0103e9e <print_trapframe+0x72>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103e8f:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103e92:	83 fa 0f             	cmp    $0xf,%edx
f0103e95:	77 0e                	ja     f0103ea5 <print_trapframe+0x79>
		return "Hardware Interrupt";
f0103e97:	ba d4 76 10 f0       	mov    $0xf01076d4,%edx
f0103e9c:	eb 0c                	jmp    f0103eaa <print_trapframe+0x7e>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103e9e:	ba c8 76 10 f0       	mov    $0xf01076c8,%edx
f0103ea3:	eb 05                	jmp    f0103eaa <print_trapframe+0x7e>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103ea5:	ba e7 76 10 f0       	mov    $0xf01076e7,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103eaa:	83 ec 04             	sub    $0x4,%esp
f0103ead:	52                   	push   %edx
f0103eae:	50                   	push   %eax
f0103eaf:	68 61 77 10 f0       	push   $0xf0107761
f0103eb4:	e8 c0 fd ff ff       	call   f0103c79 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103eb9:	83 c4 10             	add    $0x10,%esp
f0103ebc:	3b 1d 60 ea 2d f0    	cmp    0xf02dea60,%ebx
f0103ec2:	75 1a                	jne    f0103ede <print_trapframe+0xb2>
f0103ec4:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ec8:	75 14                	jne    f0103ede <print_trapframe+0xb2>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103eca:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103ecd:	83 ec 08             	sub    $0x8,%esp
f0103ed0:	50                   	push   %eax
f0103ed1:	68 73 77 10 f0       	push   $0xf0107773
f0103ed6:	e8 9e fd ff ff       	call   f0103c79 <cprintf>
f0103edb:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103ede:	83 ec 08             	sub    $0x8,%esp
f0103ee1:	ff 73 2c             	pushl  0x2c(%ebx)
f0103ee4:	68 82 77 10 f0       	push   $0xf0107782
f0103ee9:	e8 8b fd ff ff       	call   f0103c79 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103eee:	83 c4 10             	add    $0x10,%esp
f0103ef1:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ef5:	75 45                	jne    f0103f3c <print_trapframe+0x110>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103ef7:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103efa:	a8 01                	test   $0x1,%al
f0103efc:	74 07                	je     f0103f05 <print_trapframe+0xd9>
f0103efe:	b9 f6 76 10 f0       	mov    $0xf01076f6,%ecx
f0103f03:	eb 05                	jmp    f0103f0a <print_trapframe+0xde>
f0103f05:	b9 01 77 10 f0       	mov    $0xf0107701,%ecx
f0103f0a:	a8 02                	test   $0x2,%al
f0103f0c:	74 07                	je     f0103f15 <print_trapframe+0xe9>
f0103f0e:	ba 0d 77 10 f0       	mov    $0xf010770d,%edx
f0103f13:	eb 05                	jmp    f0103f1a <print_trapframe+0xee>
f0103f15:	ba 13 77 10 f0       	mov    $0xf0107713,%edx
f0103f1a:	a8 04                	test   $0x4,%al
f0103f1c:	74 07                	je     f0103f25 <print_trapframe+0xf9>
f0103f1e:	b8 18 77 10 f0       	mov    $0xf0107718,%eax
f0103f23:	eb 05                	jmp    f0103f2a <print_trapframe+0xfe>
f0103f25:	b8 54 78 10 f0       	mov    $0xf0107854,%eax
f0103f2a:	51                   	push   %ecx
f0103f2b:	52                   	push   %edx
f0103f2c:	50                   	push   %eax
f0103f2d:	68 90 77 10 f0       	push   $0xf0107790
f0103f32:	e8 42 fd ff ff       	call   f0103c79 <cprintf>
f0103f37:	83 c4 10             	add    $0x10,%esp
f0103f3a:	eb 10                	jmp    f0103f4c <print_trapframe+0x120>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103f3c:	83 ec 0c             	sub    $0xc,%esp
f0103f3f:	68 2f 62 10 f0       	push   $0xf010622f
f0103f44:	e8 30 fd ff ff       	call   f0103c79 <cprintf>
f0103f49:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f4c:	83 ec 08             	sub    $0x8,%esp
f0103f4f:	ff 73 30             	pushl  0x30(%ebx)
f0103f52:	68 9f 77 10 f0       	push   $0xf010779f
f0103f57:	e8 1d fd ff ff       	call   f0103c79 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f5c:	83 c4 08             	add    $0x8,%esp
f0103f5f:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103f63:	50                   	push   %eax
f0103f64:	68 ae 77 10 f0       	push   $0xf01077ae
f0103f69:	e8 0b fd ff ff       	call   f0103c79 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f6e:	83 c4 08             	add    $0x8,%esp
f0103f71:	ff 73 38             	pushl  0x38(%ebx)
f0103f74:	68 c1 77 10 f0       	push   $0xf01077c1
f0103f79:	e8 fb fc ff ff       	call   f0103c79 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f7e:	83 c4 10             	add    $0x10,%esp
f0103f81:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f85:	74 25                	je     f0103fac <print_trapframe+0x180>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f87:	83 ec 08             	sub    $0x8,%esp
f0103f8a:	ff 73 3c             	pushl  0x3c(%ebx)
f0103f8d:	68 d0 77 10 f0       	push   $0xf01077d0
f0103f92:	e8 e2 fc ff ff       	call   f0103c79 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103f97:	83 c4 08             	add    $0x8,%esp
f0103f9a:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103f9e:	50                   	push   %eax
f0103f9f:	68 df 77 10 f0       	push   $0xf01077df
f0103fa4:	e8 d0 fc ff ff       	call   f0103c79 <cprintf>
f0103fa9:	83 c4 10             	add    $0x10,%esp
	}
}
f0103fac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103faf:	c9                   	leave  
f0103fb0:	c3                   	ret    

f0103fb1 <page_fault_handler>:
		sched_yield();
}

void
page_fault_handler(struct Trapframe *tf)
{
f0103fb1:	55                   	push   %ebp
f0103fb2:	89 e5                	mov    %esp,%ebp
f0103fb4:	57                   	push   %edi
f0103fb5:	56                   	push   %esi
f0103fb6:	53                   	push   %ebx
f0103fb7:	83 ec 0c             	sub    $0xc,%esp
f0103fba:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103fbd:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT)
f0103fc0:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0103fc5:	75 17                	jne    f0103fde <page_fault_handler+0x2d>
    	panic("page_fault_handler : page fault in kernel\n");
f0103fc7:	83 ec 04             	sub    $0x4,%esp
f0103fca:	68 bc 79 10 f0       	push   $0xf01079bc
f0103fcf:	68 65 01 00 00       	push   $0x165
f0103fd4:	68 f2 77 10 f0       	push   $0xf01077f2
f0103fd9:	e8 8a c0 ff ff       	call   f0100068 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103fde:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103fe1:	e8 36 18 00 00       	call   f010581c <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103fe6:	57                   	push   %edi
f0103fe7:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103fe8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103fef:	29 c2                	sub    %eax,%edx
f0103ff1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ff4:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ffb:	ff 70 48             	pushl  0x48(%eax)
f0103ffe:	68 e8 79 10 f0       	push   $0xf01079e8
f0104003:	e8 71 fc ff ff       	call   f0103c79 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104008:	89 1c 24             	mov    %ebx,(%esp)
f010400b:	e8 1c fe ff ff       	call   f0103e2c <print_trapframe>
	env_destroy(curenv);
f0104010:	e8 07 18 00 00       	call   f010581c <cpunum>
f0104015:	83 c4 04             	add    $0x4,%esp
f0104018:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010401f:	29 c2                	sub    %eax,%edx
f0104021:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104024:	ff 34 85 28 f0 2d f0 	pushl  -0xfd20fd8(,%eax,4)
f010402b:	e8 37 f9 ff ff       	call   f0103967 <env_destroy>
f0104030:	83 c4 10             	add    $0x10,%esp
}
f0104033:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104036:	5b                   	pop    %ebx
f0104037:	5e                   	pop    %esi
f0104038:	5f                   	pop    %edi
f0104039:	c9                   	leave  
f010403a:	c3                   	ret    

f010403b <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010403b:	55                   	push   %ebp
f010403c:	89 e5                	mov    %esp,%ebp
f010403e:	57                   	push   %edi
f010403f:	56                   	push   %esi
f0104040:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104043:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104044:	83 3d 00 ef 2d f0 00 	cmpl   $0x0,0xf02def00
f010404b:	74 01                	je     f010404e <trap+0x13>
		asm volatile("hlt");
f010404d:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010404e:	e8 c9 17 00 00       	call   f010581c <cpunum>
f0104053:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010405a:	29 c2                	sub    %eax,%edx
f010405c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010405f:	8d 14 85 20 f0 2d f0 	lea    -0xfd20fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104066:	b8 01 00 00 00       	mov    $0x1,%eax
f010406b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010406f:	83 f8 02             	cmp    $0x2,%eax
f0104072:	75 10                	jne    f0104084 <trap+0x49>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104074:	83 ec 0c             	sub    $0xc,%esp
f0104077:	68 20 74 12 f0       	push   $0xf0127420
f010407c:	e8 52 1a 00 00       	call   f0105ad3 <spin_lock>
f0104081:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104084:	9c                   	pushf  
f0104085:	58                   	pop    %eax
		lock_kernel();

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104086:	f6 c4 02             	test   $0x2,%ah
f0104089:	74 19                	je     f01040a4 <trap+0x69>
f010408b:	68 fe 77 10 f0       	push   $0xf01077fe
f0104090:	68 b7 72 10 f0       	push   $0xf01072b7
f0104095:	68 31 01 00 00       	push   $0x131
f010409a:	68 f2 77 10 f0       	push   $0xf01077f2
f010409f:	e8 c4 bf ff ff       	call   f0100068 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01040a4:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01040a8:	83 e0 03             	and    $0x3,%eax
f01040ab:	83 f8 03             	cmp    $0x3,%eax
f01040ae:	0f 85 cc 00 00 00    	jne    f0104180 <trap+0x145>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f01040b4:	e8 63 17 00 00       	call   f010581c <cpunum>
f01040b9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01040c0:	29 c2                	sub    %eax,%edx
f01040c2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01040c5:	83 3c 85 28 f0 2d f0 	cmpl   $0x0,-0xfd20fd8(,%eax,4)
f01040cc:	00 
f01040cd:	75 19                	jne    f01040e8 <trap+0xad>
f01040cf:	68 17 78 10 f0       	push   $0xf0107817
f01040d4:	68 b7 72 10 f0       	push   $0xf01072b7
f01040d9:	68 38 01 00 00       	push   $0x138
f01040de:	68 f2 77 10 f0       	push   $0xf01077f2
f01040e3:	e8 80 bf ff ff       	call   f0100068 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01040e8:	e8 2f 17 00 00       	call   f010581c <cpunum>
f01040ed:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01040f4:	29 c2                	sub    %eax,%edx
f01040f6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01040f9:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f0104100:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104104:	75 41                	jne    f0104147 <trap+0x10c>
			env_free(curenv);
f0104106:	e8 11 17 00 00       	call   f010581c <cpunum>
f010410b:	83 ec 0c             	sub    $0xc,%esp
f010410e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104115:	29 c2                	sub    %eax,%edx
f0104117:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010411a:	ff 34 85 28 f0 2d f0 	pushl  -0xfd20fd8(,%eax,4)
f0104121:	e8 64 f6 ff ff       	call   f010378a <env_free>
			curenv = NULL;
f0104126:	e8 f1 16 00 00       	call   f010581c <cpunum>
f010412b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104132:	29 c2                	sub    %eax,%edx
f0104134:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104137:	c7 04 85 28 f0 2d f0 	movl   $0x0,-0xfd20fd8(,%eax,4)
f010413e:	00 00 00 00 
			sched_yield();
f0104142:	e8 74 03 00 00       	call   f01044bb <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104147:	e8 d0 16 00 00       	call   f010581c <cpunum>
f010414c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104153:	29 c2                	sub    %eax,%edx
f0104155:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104158:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f010415f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104164:	89 c7                	mov    %eax,%edi
f0104166:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104168:	e8 af 16 00 00       	call   f010581c <cpunum>
f010416d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104174:	29 c2                	sub    %eax,%edx
f0104176:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104179:	8b 34 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104180:	89 35 60 ea 2d f0    	mov    %esi,0xf02dea60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.	
    cprintf("TRAP NUM : %u\n", tf->tf_trapno);
f0104186:	83 ec 08             	sub    $0x8,%esp
f0104189:	ff 76 28             	pushl  0x28(%esi)
f010418c:	68 1e 78 10 f0       	push   $0xf010781e
f0104191:	e8 e3 fa ff ff       	call   f0103c79 <cprintf>

    int r;
    // cprintf("TRAPNO : %d\n", tf->tf_trapno);
    switch (tf->tf_trapno) {
f0104196:	83 c4 10             	add    $0x10,%esp
f0104199:	8b 46 28             	mov    0x28(%esi),%eax
f010419c:	83 f8 03             	cmp    $0x3,%eax
f010419f:	74 3a                	je     f01041db <trap+0x1a0>
f01041a1:	83 f8 03             	cmp    $0x3,%eax
f01041a4:	77 07                	ja     f01041ad <trap+0x172>
f01041a6:	83 f8 01             	cmp    $0x1,%eax
f01041a9:	75 7b                	jne    f0104226 <trap+0x1eb>
f01041ab:	eb 0c                	jmp    f01041b9 <trap+0x17e>
f01041ad:	83 f8 0e             	cmp    $0xe,%eax
f01041b0:	74 18                	je     f01041ca <trap+0x18f>
f01041b2:	83 f8 30             	cmp    $0x30,%eax
f01041b5:	75 6f                	jne    f0104226 <trap+0x1eb>
f01041b7:	eb 33                	jmp    f01041ec <trap+0x1b1>
    	case T_DEBUG:
    		monitor(tf);
f01041b9:	83 ec 0c             	sub    $0xc,%esp
f01041bc:	56                   	push   %esi
f01041bd:	e8 4b ce ff ff       	call   f010100d <monitor>
f01041c2:	83 c4 10             	add    $0x10,%esp
f01041c5:	e9 ab 00 00 00       	jmp    f0104275 <trap+0x23a>
    		break;
        case T_PGFLT:
        	page_fault_handler(tf);
f01041ca:	83 ec 0c             	sub    $0xc,%esp
f01041cd:	56                   	push   %esi
f01041ce:	e8 de fd ff ff       	call   f0103fb1 <page_fault_handler>
f01041d3:	83 c4 10             	add    $0x10,%esp
f01041d6:	e9 9a 00 00 00       	jmp    f0104275 <trap+0x23a>
            break;
        case T_BRKPT:
            monitor(tf); 
f01041db:	83 ec 0c             	sub    $0xc,%esp
f01041de:	56                   	push   %esi
f01041df:	e8 29 ce ff ff       	call   f010100d <monitor>
f01041e4:	83 c4 10             	add    $0x10,%esp
f01041e7:	e9 89 00 00 00       	jmp    f0104275 <trap+0x23a>
            break;
        case T_SYSCALL:
            r = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f01041ec:	83 ec 08             	sub    $0x8,%esp
f01041ef:	ff 76 04             	pushl  0x4(%esi)
f01041f2:	ff 36                	pushl  (%esi)
f01041f4:	ff 76 10             	pushl  0x10(%esi)
f01041f7:	ff 76 18             	pushl  0x18(%esi)
f01041fa:	ff 76 14             	pushl  0x14(%esi)
f01041fd:	ff 76 1c             	pushl  0x1c(%esi)
f0104200:	e8 c3 02 00 00       	call   f01044c8 <syscall>
                        tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
            if (r < 0)
f0104205:	83 c4 20             	add    $0x20,%esp
f0104208:	85 c0                	test   %eax,%eax
f010420a:	79 15                	jns    f0104221 <trap+0x1e6>
                panic("trap.c/syscall : %e\n", r);
f010420c:	50                   	push   %eax
f010420d:	68 2d 78 10 f0       	push   $0xf010782d
f0104212:	68 f7 00 00 00       	push   $0xf7
f0104217:	68 f2 77 10 f0       	push   $0xf01077f2
f010421c:	e8 47 be ff ff       	call   f0100068 <_panic>
            else
                tf->tf_regs.reg_eax = r;
f0104221:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104224:	eb 4f                	jmp    f0104275 <trap+0x23a>
            break;
        default:
	        // Unexpected trap: The user process or the kernel has a bug.
	        print_trapframe(tf);
f0104226:	83 ec 0c             	sub    $0xc,%esp
f0104229:	56                   	push   %esi
f010422a:	e8 fd fb ff ff       	call   f0103e2c <print_trapframe>
	        if (tf->tf_cs == GD_KT)
f010422f:	83 c4 10             	add    $0x10,%esp
f0104232:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104237:	75 17                	jne    f0104250 <trap+0x215>
		        panic("unhandled trap in kernel");
f0104239:	83 ec 04             	sub    $0x4,%esp
f010423c:	68 42 78 10 f0       	push   $0xf0107842
f0104241:	68 ff 00 00 00       	push   $0xff
f0104246:	68 f2 77 10 f0       	push   $0xf01077f2
f010424b:	e8 18 be ff ff       	call   f0100068 <_panic>
	        else {
		        env_destroy(curenv);
f0104250:	e8 c7 15 00 00       	call   f010581c <cpunum>
f0104255:	83 ec 0c             	sub    $0xc,%esp
f0104258:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010425f:	29 c2                	sub    %eax,%edx
f0104261:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104264:	ff 34 85 28 f0 2d f0 	pushl  -0xfd20fd8(,%eax,4)
f010426b:	e8 f7 f6 ff ff       	call   f0103967 <env_destroy>
f0104270:	83 c4 10             	add    $0x10,%esp
f0104273:	eb 6d                	jmp    f01042e2 <trap+0x2a7>
    }

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104275:	83 7e 28 27          	cmpl   $0x27,0x28(%esi)
f0104279:	75 1a                	jne    f0104295 <trap+0x25a>
		cprintf("Spurious interrupt on irq 7\n");
f010427b:	83 ec 0c             	sub    $0xc,%esp
f010427e:	68 5b 78 10 f0       	push   $0xf010785b
f0104283:	e8 f1 f9 ff ff       	call   f0103c79 <cprintf>
		print_trapframe(tf);
f0104288:	89 34 24             	mov    %esi,(%esp)
f010428b:	e8 9c fb ff ff       	call   f0103e2c <print_trapframe>
f0104290:	83 c4 10             	add    $0x10,%esp
f0104293:	eb 4d                	jmp    f01042e2 <trap+0x2a7>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104295:	83 ec 0c             	sub    $0xc,%esp
f0104298:	56                   	push   %esi
f0104299:	e8 8e fb ff ff       	call   f0103e2c <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010429e:	83 c4 10             	add    $0x10,%esp
f01042a1:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01042a6:	75 17                	jne    f01042bf <trap+0x284>
		panic("unhandled trap in kernel");
f01042a8:	83 ec 04             	sub    $0x4,%esp
f01042ab:	68 42 78 10 f0       	push   $0xf0107842
f01042b0:	68 16 01 00 00       	push   $0x116
f01042b5:	68 f2 77 10 f0       	push   $0xf01077f2
f01042ba:	e8 a9 bd ff ff       	call   f0100068 <_panic>
	else {
		env_destroy(curenv);
f01042bf:	e8 58 15 00 00       	call   f010581c <cpunum>
f01042c4:	83 ec 0c             	sub    $0xc,%esp
f01042c7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01042ce:	29 c2                	sub    %eax,%edx
f01042d0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01042d3:	ff 34 85 28 f0 2d f0 	pushl  -0xfd20fd8(,%eax,4)
f01042da:	e8 88 f6 ff ff       	call   f0103967 <env_destroy>
f01042df:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01042e2:	e8 35 15 00 00       	call   f010581c <cpunum>
f01042e7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01042ee:	29 c2                	sub    %eax,%edx
f01042f0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01042f3:	83 3c 85 28 f0 2d f0 	cmpl   $0x0,-0xfd20fd8(,%eax,4)
f01042fa:	00 
f01042fb:	74 3e                	je     f010433b <trap+0x300>
f01042fd:	e8 1a 15 00 00       	call   f010581c <cpunum>
f0104302:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104309:	29 c2                	sub    %eax,%edx
f010430b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010430e:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f0104315:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104319:	75 20                	jne    f010433b <trap+0x300>
		env_run(curenv);
f010431b:	e8 fc 14 00 00       	call   f010581c <cpunum>
f0104320:	83 ec 0c             	sub    $0xc,%esp
f0104323:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010432a:	29 c2                	sub    %eax,%edx
f010432c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010432f:	ff 34 85 28 f0 2d f0 	pushl  -0xfd20fd8(,%eax,4)
f0104336:	e8 e9 f6 ff ff       	call   f0103a24 <env_run>
	else
		sched_yield();
f010433b:	e8 7b 01 00 00       	call   f01044bb <sched_yield>

f0104340 <vec0>:
.data
.align 2
.globl vectors
vectors:
.text
	MYTH_NOEC(vec0, T_DIVIDE)
f0104340:	6a 00                	push   $0x0
f0104342:	6a 00                	push   $0x0
f0104344:	e9 89 30 02 00       	jmp    f01273d2 <_alltraps>
f0104349:	90                   	nop

f010434a <vec1>:
 	MYTH_NOEC(vec1, T_DEBUG)
f010434a:	6a 00                	push   $0x0
f010434c:	6a 01                	push   $0x1
f010434e:	e9 7f 30 02 00       	jmp    f01273d2 <_alltraps>
f0104353:	90                   	nop

f0104354 <vec2>:
 	MYTH_NOEC(vec2, T_NMI)
f0104354:	6a 00                	push   $0x0
f0104356:	6a 02                	push   $0x2
f0104358:	e9 75 30 02 00       	jmp    f01273d2 <_alltraps>
f010435d:	90                   	nop

f010435e <vec3>:
 	MYTH_NOEC(vec3, T_BRKPT)
f010435e:	6a 00                	push   $0x0
f0104360:	6a 03                	push   $0x3
f0104362:	e9 6b 30 02 00       	jmp    f01273d2 <_alltraps>
f0104367:	90                   	nop

f0104368 <vec4>:
 	MYTH_NOEC(vec4, T_OFLOW)
f0104368:	6a 00                	push   $0x0
f010436a:	6a 04                	push   $0x4
f010436c:	e9 61 30 02 00       	jmp    f01273d2 <_alltraps>
f0104371:	90                   	nop

f0104372 <vec6>:
 	MYTH_NULL()
 	MYTH_NOEC(vec6, T_BOUND)
f0104372:	6a 00                	push   $0x0
f0104374:	6a 05                	push   $0x5
f0104376:	e9 57 30 02 00       	jmp    f01273d2 <_alltraps>
f010437b:	90                   	nop

f010437c <vec7>:
	MYTH_NOEC(vec7, T_DEVICE)
f010437c:	6a 00                	push   $0x0
f010437e:	6a 07                	push   $0x7
f0104380:	e9 4d 30 02 00       	jmp    f01273d2 <_alltraps>
f0104385:	90                   	nop

f0104386 <vec8>:
 	MYTH_NOEC(vec8, T_DBLFLT)
f0104386:	6a 00                	push   $0x0
f0104388:	6a 08                	push   $0x8
f010438a:	e9 43 30 02 00       	jmp    f01273d2 <_alltraps>
f010438f:	90                   	nop

f0104390 <vec10>:
 	MYTH_NULL()
 	MYTH(vec10, T_TSS)
f0104390:	6a 0a                	push   $0xa
f0104392:	e9 3b 30 02 00       	jmp    f01273d2 <_alltraps>
f0104397:	90                   	nop

f0104398 <vec11>:
 	MYTH(vec11, T_SEGNP)
f0104398:	6a 0b                	push   $0xb
f010439a:	e9 33 30 02 00       	jmp    f01273d2 <_alltraps>
f010439f:	90                   	nop

f01043a0 <vec12>:
 	MYTH(vec12, T_STACK)
f01043a0:	6a 0c                	push   $0xc
f01043a2:	e9 2b 30 02 00       	jmp    f01273d2 <_alltraps>
f01043a7:	90                   	nop

f01043a8 <vec13>:
 	MYTH(vec13, T_GPFLT)
f01043a8:	6a 0d                	push   $0xd
f01043aa:	e9 23 30 02 00       	jmp    f01273d2 <_alltraps>
f01043af:	90                   	nop

f01043b0 <vec14>:
 	MYTH(vec14, T_PGFLT) 
f01043b0:	6a 0e                	push   $0xe
f01043b2:	e9 1b 30 02 00       	jmp    f01273d2 <_alltraps>
f01043b7:	90                   	nop

f01043b8 <vec16>:
 	MYTH_NULL()
 	MYTH_NOEC(vec16, T_FPERR)
f01043b8:	6a 00                	push   $0x0
f01043ba:	6a 10                	push   $0x10
f01043bc:	e9 11 30 02 00       	jmp    f01273d2 <_alltraps>
f01043c1:	90                   	nop

f01043c2 <vec17>:
 	MYTH(vec17, T_ALIGN)
f01043c2:	6a 11                	push   $0x11
f01043c4:	e9 09 30 02 00       	jmp    f01273d2 <_alltraps>
f01043c9:	90                   	nop

f01043ca <vec18>:
 	MYTH_NOEC(vec18, T_MCHK)
f01043ca:	6a 00                	push   $0x0
f01043cc:	6a 12                	push   $0x12
f01043ce:	e9 ff 2f 02 00       	jmp    f01273d2 <_alltraps>
f01043d3:	90                   	nop

f01043d4 <vec19>:
 	MYTH_NOEC(vec19, T_SIMDERR)
f01043d4:	6a 00                	push   $0x0
f01043d6:	6a 13                	push   $0x13
f01043d8:	e9 f5 2f 02 00       	jmp    f01273d2 <_alltraps>
f01043dd:	00 00                	add    %al,(%eax)
	...

f01043e0 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01043e0:	55                   	push   %ebp
f01043e1:	89 e5                	mov    %esp,%ebp
f01043e3:	83 ec 08             	sub    $0x8,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01043e6:	8b 15 3c e2 2d f0    	mov    0xf02de23c,%edx
f01043ec:	8b 42 54             	mov    0x54(%edx),%eax
f01043ef:	83 e8 02             	sub    $0x2,%eax
f01043f2:	83 f8 01             	cmp    $0x1,%eax
f01043f5:	76 46                	jbe    f010443d <sched_halt+0x5d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01043f7:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01043fc:	8b 8a d0 00 00 00    	mov    0xd0(%edx),%ecx
f0104402:	83 e9 02             	sub    $0x2,%ecx
f0104405:	83 f9 01             	cmp    $0x1,%ecx
f0104408:	76 0d                	jbe    f0104417 <sched_halt+0x37>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010440a:	40                   	inc    %eax
f010440b:	83 c2 7c             	add    $0x7c,%edx
f010440e:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104413:	75 e7                	jne    f01043fc <sched_halt+0x1c>
f0104415:	eb 07                	jmp    f010441e <sched_halt+0x3e>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0104417:	3d 00 04 00 00       	cmp    $0x400,%eax
f010441c:	75 1f                	jne    f010443d <sched_halt+0x5d>
		cprintf("No runnable environments in the system!\n");
f010441e:	83 ec 0c             	sub    $0xc,%esp
f0104421:	68 70 7a 10 f0       	push   $0xf0107a70
f0104426:	e8 4e f8 ff ff       	call   f0103c79 <cprintf>
f010442b:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010442e:	83 ec 0c             	sub    $0xc,%esp
f0104431:	6a 00                	push   $0x0
f0104433:	e8 d5 cb ff ff       	call   f010100d <monitor>
f0104438:	83 c4 10             	add    $0x10,%esp
f010443b:	eb f1                	jmp    f010442e <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010443d:	e8 da 13 00 00       	call   f010581c <cpunum>
f0104442:	6b c0 74             	imul   $0x74,%eax,%eax
f0104445:	c7 80 28 f0 2d f0 00 	movl   $0x0,-0xfd20fd8(%eax)
f010444c:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010444f:	a1 0c ef 2d f0       	mov    0xf02def0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104454:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104459:	77 12                	ja     f010446d <sched_halt+0x8d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010445b:	50                   	push   %eax
f010445c:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0104461:	6a 3c                	push   $0x3c
f0104463:	68 99 7a 10 f0       	push   $0xf0107a99
f0104468:	e8 fb bb ff ff       	call   f0100068 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010446d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104472:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104475:	e8 a2 13 00 00       	call   f010581c <cpunum>
f010447a:	6b d0 74             	imul   $0x74,%eax,%edx
f010447d:	81 c2 20 f0 2d f0    	add    $0xf02df020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104483:	b8 02 00 00 00       	mov    $0x2,%eax
f0104488:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010448c:	83 ec 0c             	sub    $0xc,%esp
f010448f:	68 20 74 12 f0       	push   $0xf0127420
f0104494:	e8 f5 16 00 00       	call   f0105b8e <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104499:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010449b:	e8 7c 13 00 00       	call   f010581c <cpunum>
f01044a0:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01044a3:	8b 80 30 f0 2d f0    	mov    -0xfd20fd0(%eax),%eax
f01044a9:	bd 00 00 00 00       	mov    $0x0,%ebp
f01044ae:	89 c4                	mov    %eax,%esp
f01044b0:	6a 00                	push   $0x0
f01044b2:	6a 00                	push   $0x0
f01044b4:	fb                   	sti    
f01044b5:	f4                   	hlt    
f01044b6:	83 c4 10             	add    $0x10,%esp
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01044b9:	c9                   	leave  
f01044ba:	c3                   	ret    

f01044bb <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01044bb:	55                   	push   %ebp
f01044bc:	89 e5                	mov    %esp,%ebp
f01044be:	83 ec 08             	sub    $0x8,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.

	// sched_halt never returns
	sched_halt();
f01044c1:	e8 1a ff ff ff       	call   f01043e0 <sched_halt>
}
f01044c6:	c9                   	leave  
f01044c7:	c3                   	ret    

f01044c8 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01044c8:	55                   	push   %ebp
f01044c9:	89 e5                	mov    %esp,%ebp
f01044cb:	56                   	push   %esi
f01044cc:	53                   	push   %ebx
f01044cd:	83 ec 10             	sub    $0x10,%esp
f01044d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01044d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01044d6:	8b 75 10             	mov    0x10(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
    
    switch (syscallno) {
f01044d9:	83 f8 01             	cmp    $0x1,%eax
f01044dc:	74 52                	je     f0104530 <syscall+0x68>
f01044de:	83 f8 01             	cmp    $0x1,%eax
f01044e1:	72 10                	jb     f01044f3 <syscall+0x2b>
f01044e3:	83 f8 02             	cmp    $0x2,%eax
f01044e6:	74 52                	je     f010453a <syscall+0x72>
f01044e8:	83 f8 03             	cmp    $0x3,%eax
f01044eb:	0f 85 11 01 00 00    	jne    f0104602 <syscall+0x13a>
f01044f1:	eb 67                	jmp    f010455a <syscall+0x92>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, (void *)s, len, PTE_U);
f01044f3:	e8 24 13 00 00       	call   f010581c <cpunum>
f01044f8:	6a 04                	push   $0x4
f01044fa:	56                   	push   %esi
f01044fb:	53                   	push   %ebx
f01044fc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104503:	29 c2                	sub    %eax,%edx
f0104505:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104508:	ff 34 85 28 f0 2d f0 	pushl  -0xfd20fd8(,%eax,4)
f010450f:	e8 38 ed ff ff       	call   f010324c <user_mem_assert>
    
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104514:	83 c4 0c             	add    $0xc,%esp
f0104517:	53                   	push   %ebx
f0104518:	56                   	push   %esi
f0104519:	68 9f 62 10 f0       	push   $0xf010629f
f010451e:	e8 56 f7 ff ff       	call   f0103c79 <cprintf>
f0104523:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
    
    switch (syscallno) {
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
f0104526:	b8 00 00 00 00       	mov    $0x0,%eax
f010452b:	e9 e9 00 00 00       	jmp    f0104619 <syscall+0x151>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104530:	e8 03 c1 ff ff       	call   f0100638 <cons_getc>
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
            break;
        case SYS_cgetc:
            return sys_cgetc();
f0104535:	e9 df 00 00 00       	jmp    f0104619 <syscall+0x151>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010453a:	e8 dd 12 00 00       	call   f010581c <cpunum>
f010453f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104546:	29 c2                	sub    %eax,%edx
f0104548:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010454b:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f0104552:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_cgetc:
            return sys_cgetc();
            return 0;
            break;
        case SYS_getenvid:
            return sys_getenvid();
f0104555:	e9 bf 00 00 00       	jmp    f0104619 <syscall+0x151>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010455a:	83 ec 04             	sub    $0x4,%esp
f010455d:	6a 01                	push   $0x1
f010455f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104562:	50                   	push   %eax
f0104563:	53                   	push   %ebx
f0104564:	e8 b5 ed ff ff       	call   f010331e <envid2env>
f0104569:	83 c4 10             	add    $0x10,%esp
f010456c:	85 c0                	test   %eax,%eax
f010456e:	0f 88 a5 00 00 00    	js     f0104619 <syscall+0x151>
		return r;
	if (e == curenv)
f0104574:	e8 a3 12 00 00       	call   f010581c <cpunum>
f0104579:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010457c:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0104583:	29 c1                	sub    %eax,%ecx
f0104585:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0104588:	39 14 85 28 f0 2d f0 	cmp    %edx,-0xfd20fd8(,%eax,4)
f010458f:	75 2d                	jne    f01045be <syscall+0xf6>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104591:	e8 86 12 00 00       	call   f010581c <cpunum>
f0104596:	83 ec 08             	sub    $0x8,%esp
f0104599:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01045a0:	29 c2                	sub    %eax,%edx
f01045a2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01045a5:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f01045ac:	ff 70 48             	pushl  0x48(%eax)
f01045af:	68 a6 7a 10 f0       	push   $0xf0107aa6
f01045b4:	e8 c0 f6 ff ff       	call   f0103c79 <cprintf>
f01045b9:	83 c4 10             	add    $0x10,%esp
f01045bc:	eb 2f                	jmp    f01045ed <syscall+0x125>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01045be:	8b 5a 48             	mov    0x48(%edx),%ebx
f01045c1:	e8 56 12 00 00       	call   f010581c <cpunum>
f01045c6:	83 ec 04             	sub    $0x4,%esp
f01045c9:	53                   	push   %ebx
f01045ca:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01045d1:	29 c2                	sub    %eax,%edx
f01045d3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01045d6:	8b 04 85 28 f0 2d f0 	mov    -0xfd20fd8(,%eax,4),%eax
f01045dd:	ff 70 48             	pushl  0x48(%eax)
f01045e0:	68 c1 7a 10 f0       	push   $0xf0107ac1
f01045e5:	e8 8f f6 ff ff       	call   f0103c79 <cprintf>
f01045ea:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01045ed:	83 ec 0c             	sub    $0xc,%esp
f01045f0:	ff 75 f4             	pushl  -0xc(%ebp)
f01045f3:	e8 6f f3 ff ff       	call   f0103967 <env_destroy>
f01045f8:	83 c4 10             	add    $0x10,%esp
	return 0;
f01045fb:	b8 00 00 00 00       	mov    $0x0,%eax
            break;
        case SYS_getenvid:
            return sys_getenvid();
            break;
        case SYS_env_destroy:
            return sys_env_destroy(a1);
f0104600:	eb 17                	jmp    f0104619 <syscall+0x151>
            break;
        dafult:
            return -E_INVAL;
	}
    panic("syscall not implemented");
f0104602:	83 ec 04             	sub    $0x4,%esp
f0104605:	68 d9 7a 10 f0       	push   $0xf0107ad9
f010460a:	68 25 01 00 00       	push   $0x125
f010460f:	68 f1 7a 10 f0       	push   $0xf0107af1
f0104614:	e8 4f ba ff ff       	call   f0100068 <_panic>
}
f0104619:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010461c:	5b                   	pop    %ebx
f010461d:	5e                   	pop    %esi
f010461e:	c9                   	leave  
f010461f:	c3                   	ret    

f0104620 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104620:	55                   	push   %ebp
f0104621:	89 e5                	mov    %esp,%ebp
f0104623:	57                   	push   %edi
f0104624:	56                   	push   %esi
f0104625:	53                   	push   %ebx
f0104626:	83 ec 14             	sub    $0x14,%esp
f0104629:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010462c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010462f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104632:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104635:	8b 1a                	mov    (%edx),%ebx
f0104637:	8b 01                	mov    (%ecx),%eax
f0104639:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f010463c:	39 c3                	cmp    %eax,%ebx
f010463e:	0f 8f 97 00 00 00    	jg     f01046db <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0104644:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010464b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010464e:	01 d8                	add    %ebx,%eax
f0104650:	89 c7                	mov    %eax,%edi
f0104652:	c1 ef 1f             	shr    $0x1f,%edi
f0104655:	01 c7                	add    %eax,%edi
f0104657:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104659:	39 df                	cmp    %ebx,%edi
f010465b:	7c 31                	jl     f010468e <stab_binsearch+0x6e>
f010465d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104660:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104663:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0104668:	39 f0                	cmp    %esi,%eax
f010466a:	0f 84 b3 00 00 00    	je     f0104723 <stab_binsearch+0x103>
f0104670:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0104674:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104678:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010467a:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010467b:	39 d8                	cmp    %ebx,%eax
f010467d:	7c 0f                	jl     f010468e <stab_binsearch+0x6e>
f010467f:	0f b6 0a             	movzbl (%edx),%ecx
f0104682:	83 ea 0c             	sub    $0xc,%edx
f0104685:	39 f1                	cmp    %esi,%ecx
f0104687:	75 f1                	jne    f010467a <stab_binsearch+0x5a>
f0104689:	e9 97 00 00 00       	jmp    f0104725 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010468e:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104691:	eb 39                	jmp    f01046cc <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104693:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104696:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0104698:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010469b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01046a2:	eb 28                	jmp    f01046cc <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01046a4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01046a7:	76 12                	jbe    f01046bb <stab_binsearch+0x9b>
			*region_right = m - 1;
f01046a9:	48                   	dec    %eax
f01046aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01046ad:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01046b0:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01046b2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01046b9:	eb 11                	jmp    f01046cc <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01046bb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01046be:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f01046c0:	ff 45 0c             	incl   0xc(%ebp)
f01046c3:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01046c5:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01046cc:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f01046cf:	0f 8d 76 ff ff ff    	jge    f010464b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01046d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01046d9:	75 0d                	jne    f01046e8 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f01046db:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01046de:	8b 03                	mov    (%ebx),%eax
f01046e0:	48                   	dec    %eax
f01046e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01046e4:	89 02                	mov    %eax,(%edx)
f01046e6:	eb 55                	jmp    f010473d <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01046e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01046eb:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01046ed:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01046f0:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01046f2:	39 c1                	cmp    %eax,%ecx
f01046f4:	7d 26                	jge    f010471c <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01046f6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01046f9:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01046fc:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0104701:	39 f2                	cmp    %esi,%edx
f0104703:	74 17                	je     f010471c <stab_binsearch+0xfc>
f0104705:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0104709:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010470d:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010470e:	39 c1                	cmp    %eax,%ecx
f0104710:	7d 0a                	jge    f010471c <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0104712:	0f b6 1a             	movzbl (%edx),%ebx
f0104715:	83 ea 0c             	sub    $0xc,%edx
f0104718:	39 f3                	cmp    %esi,%ebx
f010471a:	75 f1                	jne    f010470d <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f010471c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010471f:	89 02                	mov    %eax,(%edx)
f0104721:	eb 1a                	jmp    f010473d <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104723:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104725:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104728:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f010472b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010472f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104732:	0f 82 5b ff ff ff    	jb     f0104693 <stab_binsearch+0x73>
f0104738:	e9 67 ff ff ff       	jmp    f01046a4 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010473d:	83 c4 14             	add    $0x14,%esp
f0104740:	5b                   	pop    %ebx
f0104741:	5e                   	pop    %esi
f0104742:	5f                   	pop    %edi
f0104743:	c9                   	leave  
f0104744:	c3                   	ret    

f0104745 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104745:	55                   	push   %ebp
f0104746:	89 e5                	mov    %esp,%ebp
f0104748:	57                   	push   %edi
f0104749:	56                   	push   %esi
f010474a:	53                   	push   %ebx
f010474b:	83 ec 2c             	sub    $0x2c,%esp
f010474e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104751:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104754:	c7 03 00 7b 10 f0    	movl   $0xf0107b00,(%ebx)
	info->eip_line = 0;
f010475a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104761:	c7 43 08 00 7b 10 f0 	movl   $0xf0107b00,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104768:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010476f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104772:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104779:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010477f:	0f 87 ba 00 00 00    	ja     f010483f <debuginfo_eip+0xfa>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
f0104785:	e8 92 10 00 00       	call   f010581c <cpunum>
f010478a:	6a 04                	push   $0x4
f010478c:	6a 10                	push   $0x10
f010478e:	68 00 00 20 00       	push   $0x200000
f0104793:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010479a:	29 c2                	sub    %eax,%edx
f010479c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010479f:	ff 34 85 28 f0 2d f0 	pushl  -0xfd20fd8(,%eax,4)
f01047a6:	e8 ee e9 ff ff       	call   f0103199 <user_mem_check>
f01047ab:	83 c4 10             	add    $0x10,%esp
f01047ae:	85 c0                	test   %eax,%eax
f01047b0:	0f 88 11 02 00 00    	js     f01049c7 <debuginfo_eip+0x282>
			return -1;
		}

		stabs = usd->stabs;
f01047b6:	a1 00 00 20 00       	mov    0x200000,%eax
f01047bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f01047be:	8b 0d 04 00 20 00    	mov    0x200004,%ecx
f01047c4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr = usd->stabstr;
f01047c7:	a1 08 00 20 00       	mov    0x200008,%eax
f01047cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f01047cf:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
f01047d5:	e8 42 10 00 00       	call   f010581c <cpunum>
f01047da:	89 c2                	mov    %eax,%edx
f01047dc:	6a 04                	push   $0x4
f01047de:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01047e1:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01047e4:	50                   	push   %eax
f01047e5:	ff 75 d0             	pushl  -0x30(%ebp)
f01047e8:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01047ef:	29 d0                	sub    %edx,%eax
f01047f1:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01047f4:	ff 34 85 28 f0 2d f0 	pushl  -0xfd20fd8(,%eax,4)
f01047fb:	e8 99 e9 ff ff       	call   f0103199 <user_mem_check>
f0104800:	83 c4 10             	add    $0x10,%esp
f0104803:	85 c0                	test   %eax,%eax
f0104805:	0f 88 c3 01 00 00    	js     f01049ce <debuginfo_eip+0x289>
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f010480b:	e8 0c 10 00 00       	call   f010581c <cpunum>
f0104810:	89 c2                	mov    %eax,%edx
f0104812:	6a 04                	push   $0x4
f0104814:	89 f8                	mov    %edi,%eax
f0104816:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0104819:	50                   	push   %eax
f010481a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010481d:	6b c2 74             	imul   $0x74,%edx,%eax
f0104820:	ff b0 28 f0 2d f0    	pushl  -0xfd20fd8(%eax)
f0104826:	e8 6e e9 ff ff       	call   f0103199 <user_mem_check>
f010482b:	89 c2                	mov    %eax,%edx
f010482d:	83 c4 10             	add    $0x10,%esp
			return -1;
f0104830:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0104835:	85 d2                	test   %edx,%edx
f0104837:	0f 88 ab 01 00 00    	js     f01049e8 <debuginfo_eip+0x2a3>
f010483d:	eb 1a                	jmp    f0104859 <debuginfo_eip+0x114>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010483f:	bf e7 c6 11 f0       	mov    $0xf011c6e7,%edi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104844:	c7 45 d4 89 34 11 f0 	movl   $0xf0113489,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010484b:	c7 45 cc 88 34 11 f0 	movl   $0xf0113488,-0x34(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104852:	c7 45 d0 d4 7f 10 f0 	movl   $0xf0107fd4,-0x30(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104859:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f010485c:	0f 83 73 01 00 00    	jae    f01049d5 <debuginfo_eip+0x290>
f0104862:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0104866:	0f 85 70 01 00 00    	jne    f01049dc <debuginfo_eip+0x297>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010486c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104873:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104876:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0104879:	c1 f8 02             	sar    $0x2,%eax
f010487c:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104882:	48                   	dec    %eax
f0104883:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104886:	83 ec 08             	sub    $0x8,%esp
f0104889:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010488c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010488f:	56                   	push   %esi
f0104890:	6a 64                	push   $0x64
f0104892:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104895:	e8 86 fd ff ff       	call   f0104620 <stab_binsearch>
	if (lfile == 0)
f010489a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010489d:	83 c4 10             	add    $0x10,%esp
		return -1;
f01048a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01048a5:	85 d2                	test   %edx,%edx
f01048a7:	0f 84 3b 01 00 00    	je     f01049e8 <debuginfo_eip+0x2a3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01048ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01048b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01048b6:	83 ec 08             	sub    $0x8,%esp
f01048b9:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01048bc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01048bf:	56                   	push   %esi
f01048c0:	6a 24                	push   $0x24
f01048c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01048c5:	e8 56 fd ff ff       	call   f0104620 <stab_binsearch>

	if (lfun <= rfun) {
f01048ca:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01048cd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01048d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01048d3:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01048d6:	83 c4 10             	add    $0x10,%esp
f01048d9:	39 c1                	cmp    %eax,%ecx
f01048db:	7f 21                	jg     f01048fe <debuginfo_eip+0x1b9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01048dd:	6b c1 0c             	imul   $0xc,%ecx,%eax
f01048e0:	03 45 d0             	add    -0x30(%ebp),%eax
f01048e3:	8b 10                	mov    (%eax),%edx
f01048e5:	89 f9                	mov    %edi,%ecx
f01048e7:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f01048ea:	39 ca                	cmp    %ecx,%edx
f01048ec:	73 06                	jae    f01048f4 <debuginfo_eip+0x1af>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01048ee:	03 55 d4             	add    -0x2c(%ebp),%edx
f01048f1:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01048f4:	8b 40 08             	mov    0x8(%eax),%eax
f01048f7:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01048fa:	29 c6                	sub    %eax,%esi
f01048fc:	eb 0f                	jmp    f010490d <debuginfo_eip+0x1c8>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01048fe:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104901:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104904:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		rline = rfile;
f0104907:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010490a:	89 45 c8             	mov    %eax,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010490d:	83 ec 08             	sub    $0x8,%esp
f0104910:	6a 3a                	push   $0x3a
f0104912:	ff 73 08             	pushl  0x8(%ebx)
f0104915:	e8 b1 08 00 00       	call   f01051cb <strfind>
f010491a:	2b 43 08             	sub    0x8(%ebx),%eax
f010491d:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0104920:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104923:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    rfun = rline;
f0104926:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104929:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f010492c:	83 c4 08             	add    $0x8,%esp
f010492f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104932:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104935:	56                   	push   %esi
f0104936:	6a 44                	push   $0x44
f0104938:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010493b:	e8 e0 fc ff ff       	call   f0104620 <stab_binsearch>
    if (lfun <= rfun) {
f0104940:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104943:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0104946:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f010494b:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f010494e:	0f 8f 94 00 00 00    	jg     f01049e8 <debuginfo_eip+0x2a3>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0104954:	6b ca 0c             	imul   $0xc,%edx,%ecx
f0104957:	03 4d d0             	add    -0x30(%ebp),%ecx
f010495a:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f010495e:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104961:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104964:	89 75 cc             	mov    %esi,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0104967:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010496a:	eb 04                	jmp    f0104970 <debuginfo_eip+0x22b>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010496c:	4a                   	dec    %edx
f010496d:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104970:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f0104973:	7c 19                	jl     f010498e <debuginfo_eip+0x249>
	       && stabs[lline].n_type != N_SOL
f0104975:	8a 48 fc             	mov    -0x4(%eax),%cl
f0104978:	80 f9 84             	cmp    $0x84,%cl
f010497b:	74 73                	je     f01049f0 <debuginfo_eip+0x2ab>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010497d:	80 f9 64             	cmp    $0x64,%cl
f0104980:	75 ea                	jne    f010496c <debuginfo_eip+0x227>
f0104982:	83 38 00             	cmpl   $0x0,(%eax)
f0104985:	74 e5                	je     f010496c <debuginfo_eip+0x227>
f0104987:	eb 67                	jmp    f01049f0 <debuginfo_eip+0x2ab>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104989:	03 45 d4             	add    -0x2c(%ebp),%eax
f010498c:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010498e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104991:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104994:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104999:	39 ca                	cmp    %ecx,%edx
f010499b:	7d 4b                	jge    f01049e8 <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
f010499d:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01049a0:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01049a3:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01049a6:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f01049aa:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01049ac:	eb 04                	jmp    f01049b2 <debuginfo_eip+0x26d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01049ae:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01049b1:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01049b2:	39 f0                	cmp    %esi,%eax
f01049b4:	7d 2d                	jge    f01049e3 <debuginfo_eip+0x29e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01049b6:	8a 0a                	mov    (%edx),%cl
f01049b8:	83 c2 0c             	add    $0xc,%edx
f01049bb:	80 f9 a0             	cmp    $0xa0,%cl
f01049be:	74 ee                	je     f01049ae <debuginfo_eip+0x269>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01049c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01049c5:	eb 21                	jmp    f01049e8 <debuginfo_eip+0x2a3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
f01049c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01049cc:	eb 1a                	jmp    f01049e8 <debuginfo_eip+0x2a3>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
f01049ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01049d3:	eb 13                	jmp    f01049e8 <debuginfo_eip+0x2a3>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01049d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01049da:	eb 0c                	jmp    f01049e8 <debuginfo_eip+0x2a3>
f01049dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01049e1:	eb 05                	jmp    f01049e8 <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01049e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01049e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049eb:	5b                   	pop    %ebx
f01049ec:	5e                   	pop    %esi
f01049ed:	5f                   	pop    %edi
f01049ee:	c9                   	leave  
f01049ef:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01049f0:	6b d2 0c             	imul   $0xc,%edx,%edx
f01049f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01049f6:	8b 04 16             	mov    (%esi,%edx,1),%eax
f01049f9:	2b 7d d4             	sub    -0x2c(%ebp),%edi
f01049fc:	39 f8                	cmp    %edi,%eax
f01049fe:	72 89                	jb     f0104989 <debuginfo_eip+0x244>
f0104a00:	eb 8c                	jmp    f010498e <debuginfo_eip+0x249>
	...

f0104a04 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104a04:	55                   	push   %ebp
f0104a05:	89 e5                	mov    %esp,%ebp
f0104a07:	57                   	push   %edi
f0104a08:	56                   	push   %esi
f0104a09:	53                   	push   %ebx
f0104a0a:	83 ec 2c             	sub    $0x2c,%esp
f0104a0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104a10:	89 d6                	mov    %edx,%esi
f0104a12:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a15:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104a18:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104a1b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104a1e:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a21:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104a24:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104a27:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104a2a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0104a31:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0104a34:	72 0c                	jb     f0104a42 <printnum+0x3e>
f0104a36:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0104a39:	76 07                	jbe    f0104a42 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104a3b:	4b                   	dec    %ebx
f0104a3c:	85 db                	test   %ebx,%ebx
f0104a3e:	7f 31                	jg     f0104a71 <printnum+0x6d>
f0104a40:	eb 3f                	jmp    f0104a81 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104a42:	83 ec 0c             	sub    $0xc,%esp
f0104a45:	57                   	push   %edi
f0104a46:	4b                   	dec    %ebx
f0104a47:	53                   	push   %ebx
f0104a48:	50                   	push   %eax
f0104a49:	83 ec 08             	sub    $0x8,%esp
f0104a4c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104a4f:	ff 75 d0             	pushl  -0x30(%ebp)
f0104a52:	ff 75 dc             	pushl  -0x24(%ebp)
f0104a55:	ff 75 d8             	pushl  -0x28(%ebp)
f0104a58:	e8 17 12 00 00       	call   f0105c74 <__udivdi3>
f0104a5d:	83 c4 18             	add    $0x18,%esp
f0104a60:	52                   	push   %edx
f0104a61:	50                   	push   %eax
f0104a62:	89 f2                	mov    %esi,%edx
f0104a64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a67:	e8 98 ff ff ff       	call   f0104a04 <printnum>
f0104a6c:	83 c4 20             	add    $0x20,%esp
f0104a6f:	eb 10                	jmp    f0104a81 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104a71:	83 ec 08             	sub    $0x8,%esp
f0104a74:	56                   	push   %esi
f0104a75:	57                   	push   %edi
f0104a76:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104a79:	4b                   	dec    %ebx
f0104a7a:	83 c4 10             	add    $0x10,%esp
f0104a7d:	85 db                	test   %ebx,%ebx
f0104a7f:	7f f0                	jg     f0104a71 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104a81:	83 ec 08             	sub    $0x8,%esp
f0104a84:	56                   	push   %esi
f0104a85:	83 ec 04             	sub    $0x4,%esp
f0104a88:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104a8b:	ff 75 d0             	pushl  -0x30(%ebp)
f0104a8e:	ff 75 dc             	pushl  -0x24(%ebp)
f0104a91:	ff 75 d8             	pushl  -0x28(%ebp)
f0104a94:	e8 f7 12 00 00       	call   f0105d90 <__umoddi3>
f0104a99:	83 c4 14             	add    $0x14,%esp
f0104a9c:	0f be 80 0a 7b 10 f0 	movsbl -0xfef84f6(%eax),%eax
f0104aa3:	50                   	push   %eax
f0104aa4:	ff 55 e4             	call   *-0x1c(%ebp)
f0104aa7:	83 c4 10             	add    $0x10,%esp
}
f0104aaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104aad:	5b                   	pop    %ebx
f0104aae:	5e                   	pop    %esi
f0104aaf:	5f                   	pop    %edi
f0104ab0:	c9                   	leave  
f0104ab1:	c3                   	ret    

f0104ab2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104ab2:	55                   	push   %ebp
f0104ab3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104ab5:	83 fa 01             	cmp    $0x1,%edx
f0104ab8:	7e 0e                	jle    f0104ac8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104aba:	8b 10                	mov    (%eax),%edx
f0104abc:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104abf:	89 08                	mov    %ecx,(%eax)
f0104ac1:	8b 02                	mov    (%edx),%eax
f0104ac3:	8b 52 04             	mov    0x4(%edx),%edx
f0104ac6:	eb 22                	jmp    f0104aea <getuint+0x38>
	else if (lflag)
f0104ac8:	85 d2                	test   %edx,%edx
f0104aca:	74 10                	je     f0104adc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104acc:	8b 10                	mov    (%eax),%edx
f0104ace:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104ad1:	89 08                	mov    %ecx,(%eax)
f0104ad3:	8b 02                	mov    (%edx),%eax
f0104ad5:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ada:	eb 0e                	jmp    f0104aea <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104adc:	8b 10                	mov    (%eax),%edx
f0104ade:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104ae1:	89 08                	mov    %ecx,(%eax)
f0104ae3:	8b 02                	mov    (%edx),%eax
f0104ae5:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104aea:	c9                   	leave  
f0104aeb:	c3                   	ret    

f0104aec <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0104aec:	55                   	push   %ebp
f0104aed:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104aef:	83 fa 01             	cmp    $0x1,%edx
f0104af2:	7e 0e                	jle    f0104b02 <getint+0x16>
		return va_arg(*ap, long long);
f0104af4:	8b 10                	mov    (%eax),%edx
f0104af6:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104af9:	89 08                	mov    %ecx,(%eax)
f0104afb:	8b 02                	mov    (%edx),%eax
f0104afd:	8b 52 04             	mov    0x4(%edx),%edx
f0104b00:	eb 1a                	jmp    f0104b1c <getint+0x30>
	else if (lflag)
f0104b02:	85 d2                	test   %edx,%edx
f0104b04:	74 0c                	je     f0104b12 <getint+0x26>
		return va_arg(*ap, long);
f0104b06:	8b 10                	mov    (%eax),%edx
f0104b08:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104b0b:	89 08                	mov    %ecx,(%eax)
f0104b0d:	8b 02                	mov    (%edx),%eax
f0104b0f:	99                   	cltd   
f0104b10:	eb 0a                	jmp    f0104b1c <getint+0x30>
	else
		return va_arg(*ap, int);
f0104b12:	8b 10                	mov    (%eax),%edx
f0104b14:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104b17:	89 08                	mov    %ecx,(%eax)
f0104b19:	8b 02                	mov    (%edx),%eax
f0104b1b:	99                   	cltd   
}
f0104b1c:	c9                   	leave  
f0104b1d:	c3                   	ret    

f0104b1e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104b1e:	55                   	push   %ebp
f0104b1f:	89 e5                	mov    %esp,%ebp
f0104b21:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104b24:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0104b27:	8b 10                	mov    (%eax),%edx
f0104b29:	3b 50 04             	cmp    0x4(%eax),%edx
f0104b2c:	73 08                	jae    f0104b36 <sprintputch+0x18>
		*b->buf++ = ch;
f0104b2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104b31:	88 0a                	mov    %cl,(%edx)
f0104b33:	42                   	inc    %edx
f0104b34:	89 10                	mov    %edx,(%eax)
}
f0104b36:	c9                   	leave  
f0104b37:	c3                   	ret    

f0104b38 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104b38:	55                   	push   %ebp
f0104b39:	89 e5                	mov    %esp,%ebp
f0104b3b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104b3e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104b41:	50                   	push   %eax
f0104b42:	ff 75 10             	pushl  0x10(%ebp)
f0104b45:	ff 75 0c             	pushl  0xc(%ebp)
f0104b48:	ff 75 08             	pushl  0x8(%ebp)
f0104b4b:	e8 05 00 00 00       	call   f0104b55 <vprintfmt>
	va_end(ap);
f0104b50:	83 c4 10             	add    $0x10,%esp
}
f0104b53:	c9                   	leave  
f0104b54:	c3                   	ret    

f0104b55 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104b55:	55                   	push   %ebp
f0104b56:	89 e5                	mov    %esp,%ebp
f0104b58:	57                   	push   %edi
f0104b59:	56                   	push   %esi
f0104b5a:	53                   	push   %ebx
f0104b5b:	83 ec 2c             	sub    $0x2c,%esp
f0104b5e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104b61:	8b 75 10             	mov    0x10(%ebp),%esi
f0104b64:	eb 13                	jmp    f0104b79 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104b66:	85 c0                	test   %eax,%eax
f0104b68:	0f 84 6d 03 00 00    	je     f0104edb <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f0104b6e:	83 ec 08             	sub    $0x8,%esp
f0104b71:	57                   	push   %edi
f0104b72:	50                   	push   %eax
f0104b73:	ff 55 08             	call   *0x8(%ebp)
f0104b76:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104b79:	0f b6 06             	movzbl (%esi),%eax
f0104b7c:	46                   	inc    %esi
f0104b7d:	83 f8 25             	cmp    $0x25,%eax
f0104b80:	75 e4                	jne    f0104b66 <vprintfmt+0x11>
f0104b82:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0104b86:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104b8d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0104b94:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0104b9b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104ba0:	eb 28                	jmp    f0104bca <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ba2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104ba4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0104ba8:	eb 20                	jmp    f0104bca <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104baa:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104bac:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0104bb0:	eb 18                	jmp    f0104bca <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104bb2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0104bb4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104bbb:	eb 0d                	jmp    f0104bca <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104bbd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104bc0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104bc3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104bca:	8a 06                	mov    (%esi),%al
f0104bcc:	0f b6 d0             	movzbl %al,%edx
f0104bcf:	8d 5e 01             	lea    0x1(%esi),%ebx
f0104bd2:	83 e8 23             	sub    $0x23,%eax
f0104bd5:	3c 55                	cmp    $0x55,%al
f0104bd7:	0f 87 e0 02 00 00    	ja     f0104ebd <vprintfmt+0x368>
f0104bdd:	0f b6 c0             	movzbl %al,%eax
f0104be0:	ff 24 85 c0 7b 10 f0 	jmp    *-0xfef8440(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104be7:	83 ea 30             	sub    $0x30,%edx
f0104bea:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0104bed:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0104bf0:	8d 50 d0             	lea    -0x30(%eax),%edx
f0104bf3:	83 fa 09             	cmp    $0x9,%edx
f0104bf6:	77 44                	ja     f0104c3c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104bf8:	89 de                	mov    %ebx,%esi
f0104bfa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104bfd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0104bfe:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0104c01:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0104c05:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0104c08:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0104c0b:	83 fb 09             	cmp    $0x9,%ebx
f0104c0e:	76 ed                	jbe    f0104bfd <vprintfmt+0xa8>
f0104c10:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104c13:	eb 29                	jmp    f0104c3e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104c15:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c18:	8d 50 04             	lea    0x4(%eax),%edx
f0104c1b:	89 55 14             	mov    %edx,0x14(%ebp)
f0104c1e:	8b 00                	mov    (%eax),%eax
f0104c20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c23:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104c25:	eb 17                	jmp    f0104c3e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0104c27:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104c2b:	78 85                	js     f0104bb2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c2d:	89 de                	mov    %ebx,%esi
f0104c2f:	eb 99                	jmp    f0104bca <vprintfmt+0x75>
f0104c31:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104c33:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0104c3a:	eb 8e                	jmp    f0104bca <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c3c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0104c3e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104c42:	79 86                	jns    f0104bca <vprintfmt+0x75>
f0104c44:	e9 74 ff ff ff       	jmp    f0104bbd <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104c49:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c4a:	89 de                	mov    %ebx,%esi
f0104c4c:	e9 79 ff ff ff       	jmp    f0104bca <vprintfmt+0x75>
f0104c51:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104c54:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c57:	8d 50 04             	lea    0x4(%eax),%edx
f0104c5a:	89 55 14             	mov    %edx,0x14(%ebp)
f0104c5d:	83 ec 08             	sub    $0x8,%esp
f0104c60:	57                   	push   %edi
f0104c61:	ff 30                	pushl  (%eax)
f0104c63:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104c66:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c69:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104c6c:	e9 08 ff ff ff       	jmp    f0104b79 <vprintfmt+0x24>
f0104c71:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104c74:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c77:	8d 50 04             	lea    0x4(%eax),%edx
f0104c7a:	89 55 14             	mov    %edx,0x14(%ebp)
f0104c7d:	8b 00                	mov    (%eax),%eax
f0104c7f:	85 c0                	test   %eax,%eax
f0104c81:	79 02                	jns    f0104c85 <vprintfmt+0x130>
f0104c83:	f7 d8                	neg    %eax
f0104c85:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104c87:	83 f8 08             	cmp    $0x8,%eax
f0104c8a:	7f 0b                	jg     f0104c97 <vprintfmt+0x142>
f0104c8c:	8b 04 85 20 7d 10 f0 	mov    -0xfef82e0(,%eax,4),%eax
f0104c93:	85 c0                	test   %eax,%eax
f0104c95:	75 1a                	jne    f0104cb1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0104c97:	52                   	push   %edx
f0104c98:	68 22 7b 10 f0       	push   $0xf0107b22
f0104c9d:	57                   	push   %edi
f0104c9e:	ff 75 08             	pushl  0x8(%ebp)
f0104ca1:	e8 92 fe ff ff       	call   f0104b38 <printfmt>
f0104ca6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ca9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104cac:	e9 c8 fe ff ff       	jmp    f0104b79 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0104cb1:	50                   	push   %eax
f0104cb2:	68 c9 72 10 f0       	push   $0xf01072c9
f0104cb7:	57                   	push   %edi
f0104cb8:	ff 75 08             	pushl  0x8(%ebp)
f0104cbb:	e8 78 fe ff ff       	call   f0104b38 <printfmt>
f0104cc0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104cc3:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0104cc6:	e9 ae fe ff ff       	jmp    f0104b79 <vprintfmt+0x24>
f0104ccb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0104cce:	89 de                	mov    %ebx,%esi
f0104cd0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104cd3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104cd6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cd9:	8d 50 04             	lea    0x4(%eax),%edx
f0104cdc:	89 55 14             	mov    %edx,0x14(%ebp)
f0104cdf:	8b 00                	mov    (%eax),%eax
f0104ce1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104ce4:	85 c0                	test   %eax,%eax
f0104ce6:	75 07                	jne    f0104cef <vprintfmt+0x19a>
				p = "(null)";
f0104ce8:	c7 45 d0 1b 7b 10 f0 	movl   $0xf0107b1b,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0104cef:	85 db                	test   %ebx,%ebx
f0104cf1:	7e 42                	jle    f0104d35 <vprintfmt+0x1e0>
f0104cf3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0104cf7:	74 3c                	je     f0104d35 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104cf9:	83 ec 08             	sub    $0x8,%esp
f0104cfc:	51                   	push   %ecx
f0104cfd:	ff 75 d0             	pushl  -0x30(%ebp)
f0104d00:	e8 3f 03 00 00       	call   f0105044 <strnlen>
f0104d05:	29 c3                	sub    %eax,%ebx
f0104d07:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104d0a:	83 c4 10             	add    $0x10,%esp
f0104d0d:	85 db                	test   %ebx,%ebx
f0104d0f:	7e 24                	jle    f0104d35 <vprintfmt+0x1e0>
					putch(padc, putdat);
f0104d11:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0104d15:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0104d18:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d1b:	83 ec 08             	sub    $0x8,%esp
f0104d1e:	57                   	push   %edi
f0104d1f:	53                   	push   %ebx
f0104d20:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104d23:	4e                   	dec    %esi
f0104d24:	83 c4 10             	add    $0x10,%esp
f0104d27:	85 f6                	test   %esi,%esi
f0104d29:	7f f0                	jg     f0104d1b <vprintfmt+0x1c6>
f0104d2b:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104d2e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104d35:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104d38:	0f be 02             	movsbl (%edx),%eax
f0104d3b:	85 c0                	test   %eax,%eax
f0104d3d:	75 47                	jne    f0104d86 <vprintfmt+0x231>
f0104d3f:	eb 37                	jmp    f0104d78 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f0104d41:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104d45:	74 16                	je     f0104d5d <vprintfmt+0x208>
f0104d47:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104d4a:	83 fa 5e             	cmp    $0x5e,%edx
f0104d4d:	76 0e                	jbe    f0104d5d <vprintfmt+0x208>
					putch('?', putdat);
f0104d4f:	83 ec 08             	sub    $0x8,%esp
f0104d52:	57                   	push   %edi
f0104d53:	6a 3f                	push   $0x3f
f0104d55:	ff 55 08             	call   *0x8(%ebp)
f0104d58:	83 c4 10             	add    $0x10,%esp
f0104d5b:	eb 0b                	jmp    f0104d68 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f0104d5d:	83 ec 08             	sub    $0x8,%esp
f0104d60:	57                   	push   %edi
f0104d61:	50                   	push   %eax
f0104d62:	ff 55 08             	call   *0x8(%ebp)
f0104d65:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104d68:	ff 4d e4             	decl   -0x1c(%ebp)
f0104d6b:	0f be 03             	movsbl (%ebx),%eax
f0104d6e:	85 c0                	test   %eax,%eax
f0104d70:	74 03                	je     f0104d75 <vprintfmt+0x220>
f0104d72:	43                   	inc    %ebx
f0104d73:	eb 1b                	jmp    f0104d90 <vprintfmt+0x23b>
f0104d75:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104d78:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104d7c:	7f 1e                	jg     f0104d9c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d7e:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0104d81:	e9 f3 fd ff ff       	jmp    f0104b79 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104d86:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104d89:	43                   	inc    %ebx
f0104d8a:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0104d8d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0104d90:	85 f6                	test   %esi,%esi
f0104d92:	78 ad                	js     f0104d41 <vprintfmt+0x1ec>
f0104d94:	4e                   	dec    %esi
f0104d95:	79 aa                	jns    f0104d41 <vprintfmt+0x1ec>
f0104d97:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104d9a:	eb dc                	jmp    f0104d78 <vprintfmt+0x223>
f0104d9c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104d9f:	83 ec 08             	sub    $0x8,%esp
f0104da2:	57                   	push   %edi
f0104da3:	6a 20                	push   $0x20
f0104da5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104da8:	4b                   	dec    %ebx
f0104da9:	83 c4 10             	add    $0x10,%esp
f0104dac:	85 db                	test   %ebx,%ebx
f0104dae:	7f ef                	jg     f0104d9f <vprintfmt+0x24a>
f0104db0:	e9 c4 fd ff ff       	jmp    f0104b79 <vprintfmt+0x24>
f0104db5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104db8:	89 ca                	mov    %ecx,%edx
f0104dba:	8d 45 14             	lea    0x14(%ebp),%eax
f0104dbd:	e8 2a fd ff ff       	call   f0104aec <getint>
f0104dc2:	89 c3                	mov    %eax,%ebx
f0104dc4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0104dc6:	85 d2                	test   %edx,%edx
f0104dc8:	78 0a                	js     f0104dd4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104dca:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104dcf:	e9 b0 00 00 00       	jmp    f0104e84 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0104dd4:	83 ec 08             	sub    $0x8,%esp
f0104dd7:	57                   	push   %edi
f0104dd8:	6a 2d                	push   $0x2d
f0104dda:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104ddd:	f7 db                	neg    %ebx
f0104ddf:	83 d6 00             	adc    $0x0,%esi
f0104de2:	f7 de                	neg    %esi
f0104de4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104de7:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104dec:	e9 93 00 00 00       	jmp    f0104e84 <vprintfmt+0x32f>
f0104df1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104df4:	89 ca                	mov    %ecx,%edx
f0104df6:	8d 45 14             	lea    0x14(%ebp),%eax
f0104df9:	e8 b4 fc ff ff       	call   f0104ab2 <getuint>
f0104dfe:	89 c3                	mov    %eax,%ebx
f0104e00:	89 d6                	mov    %edx,%esi
			base = 10;
f0104e02:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0104e07:	eb 7b                	jmp    f0104e84 <vprintfmt+0x32f>
f0104e09:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0104e0c:	89 ca                	mov    %ecx,%edx
f0104e0e:	8d 45 14             	lea    0x14(%ebp),%eax
f0104e11:	e8 d6 fc ff ff       	call   f0104aec <getint>
f0104e16:	89 c3                	mov    %eax,%ebx
f0104e18:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f0104e1a:	85 d2                	test   %edx,%edx
f0104e1c:	78 07                	js     f0104e25 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f0104e1e:	b8 08 00 00 00       	mov    $0x8,%eax
f0104e23:	eb 5f                	jmp    f0104e84 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0104e25:	83 ec 08             	sub    $0x8,%esp
f0104e28:	57                   	push   %edi
f0104e29:	6a 2d                	push   $0x2d
f0104e2b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f0104e2e:	f7 db                	neg    %ebx
f0104e30:	83 d6 00             	adc    $0x0,%esi
f0104e33:	f7 de                	neg    %esi
f0104e35:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f0104e38:	b8 08 00 00 00       	mov    $0x8,%eax
f0104e3d:	eb 45                	jmp    f0104e84 <vprintfmt+0x32f>
f0104e3f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f0104e42:	83 ec 08             	sub    $0x8,%esp
f0104e45:	57                   	push   %edi
f0104e46:	6a 30                	push   $0x30
f0104e48:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104e4b:	83 c4 08             	add    $0x8,%esp
f0104e4e:	57                   	push   %edi
f0104e4f:	6a 78                	push   $0x78
f0104e51:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104e54:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e57:	8d 50 04             	lea    0x4(%eax),%edx
f0104e5a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104e5d:	8b 18                	mov    (%eax),%ebx
f0104e5f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104e64:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104e67:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104e6c:	eb 16                	jmp    f0104e84 <vprintfmt+0x32f>
f0104e6e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104e71:	89 ca                	mov    %ecx,%edx
f0104e73:	8d 45 14             	lea    0x14(%ebp),%eax
f0104e76:	e8 37 fc ff ff       	call   f0104ab2 <getuint>
f0104e7b:	89 c3                	mov    %eax,%ebx
f0104e7d:	89 d6                	mov    %edx,%esi
			base = 16;
f0104e7f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104e84:	83 ec 0c             	sub    $0xc,%esp
f0104e87:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0104e8b:	52                   	push   %edx
f0104e8c:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e8f:	50                   	push   %eax
f0104e90:	56                   	push   %esi
f0104e91:	53                   	push   %ebx
f0104e92:	89 fa                	mov    %edi,%edx
f0104e94:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e97:	e8 68 fb ff ff       	call   f0104a04 <printnum>
			break;
f0104e9c:	83 c4 20             	add    $0x20,%esp
f0104e9f:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0104ea2:	e9 d2 fc ff ff       	jmp    f0104b79 <vprintfmt+0x24>
f0104ea7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104eaa:	83 ec 08             	sub    $0x8,%esp
f0104ead:	57                   	push   %edi
f0104eae:	52                   	push   %edx
f0104eaf:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104eb2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104eb5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104eb8:	e9 bc fc ff ff       	jmp    f0104b79 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104ebd:	83 ec 08             	sub    $0x8,%esp
f0104ec0:	57                   	push   %edi
f0104ec1:	6a 25                	push   $0x25
f0104ec3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104ec6:	83 c4 10             	add    $0x10,%esp
f0104ec9:	eb 02                	jmp    f0104ecd <vprintfmt+0x378>
f0104ecb:	89 c6                	mov    %eax,%esi
f0104ecd:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104ed0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104ed4:	75 f5                	jne    f0104ecb <vprintfmt+0x376>
f0104ed6:	e9 9e fc ff ff       	jmp    f0104b79 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0104edb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ede:	5b                   	pop    %ebx
f0104edf:	5e                   	pop    %esi
f0104ee0:	5f                   	pop    %edi
f0104ee1:	c9                   	leave  
f0104ee2:	c3                   	ret    

f0104ee3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104ee3:	55                   	push   %ebp
f0104ee4:	89 e5                	mov    %esp,%ebp
f0104ee6:	83 ec 18             	sub    $0x18,%esp
f0104ee9:	8b 45 08             	mov    0x8(%ebp),%eax
f0104eec:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104eef:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ef2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104ef6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104ef9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104f00:	85 c0                	test   %eax,%eax
f0104f02:	74 26                	je     f0104f2a <vsnprintf+0x47>
f0104f04:	85 d2                	test   %edx,%edx
f0104f06:	7e 29                	jle    f0104f31 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104f08:	ff 75 14             	pushl  0x14(%ebp)
f0104f0b:	ff 75 10             	pushl  0x10(%ebp)
f0104f0e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104f11:	50                   	push   %eax
f0104f12:	68 1e 4b 10 f0       	push   $0xf0104b1e
f0104f17:	e8 39 fc ff ff       	call   f0104b55 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104f1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104f1f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f25:	83 c4 10             	add    $0x10,%esp
f0104f28:	eb 0c                	jmp    f0104f36 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104f2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f2f:	eb 05                	jmp    f0104f36 <vsnprintf+0x53>
f0104f31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104f36:	c9                   	leave  
f0104f37:	c3                   	ret    

f0104f38 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104f38:	55                   	push   %ebp
f0104f39:	89 e5                	mov    %esp,%ebp
f0104f3b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104f3e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104f41:	50                   	push   %eax
f0104f42:	ff 75 10             	pushl  0x10(%ebp)
f0104f45:	ff 75 0c             	pushl  0xc(%ebp)
f0104f48:	ff 75 08             	pushl  0x8(%ebp)
f0104f4b:	e8 93 ff ff ff       	call   f0104ee3 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104f50:	c9                   	leave  
f0104f51:	c3                   	ret    
	...

f0104f54 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104f54:	55                   	push   %ebp
f0104f55:	89 e5                	mov    %esp,%ebp
f0104f57:	57                   	push   %edi
f0104f58:	56                   	push   %esi
f0104f59:	53                   	push   %ebx
f0104f5a:	83 ec 0c             	sub    $0xc,%esp
f0104f5d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104f60:	85 c0                	test   %eax,%eax
f0104f62:	74 11                	je     f0104f75 <readline+0x21>
		cprintf("%s", prompt);
f0104f64:	83 ec 08             	sub    $0x8,%esp
f0104f67:	50                   	push   %eax
f0104f68:	68 c9 72 10 f0       	push   $0xf01072c9
f0104f6d:	e8 07 ed ff ff       	call   f0103c79 <cprintf>
f0104f72:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104f75:	83 ec 0c             	sub    $0xc,%esp
f0104f78:	6a 00                	push   $0x0
f0104f7a:	e8 1d b8 ff ff       	call   f010079c <iscons>
f0104f7f:	89 c7                	mov    %eax,%edi
f0104f81:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104f84:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104f89:	e8 fd b7 ff ff       	call   f010078b <getchar>
f0104f8e:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104f90:	85 c0                	test   %eax,%eax
f0104f92:	79 18                	jns    f0104fac <readline+0x58>
			cprintf("read error: %e\n", c);
f0104f94:	83 ec 08             	sub    $0x8,%esp
f0104f97:	50                   	push   %eax
f0104f98:	68 44 7d 10 f0       	push   $0xf0107d44
f0104f9d:	e8 d7 ec ff ff       	call   f0103c79 <cprintf>
			return NULL;
f0104fa2:	83 c4 10             	add    $0x10,%esp
f0104fa5:	b8 00 00 00 00       	mov    $0x0,%eax
f0104faa:	eb 6f                	jmp    f010501b <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104fac:	83 f8 08             	cmp    $0x8,%eax
f0104faf:	74 05                	je     f0104fb6 <readline+0x62>
f0104fb1:	83 f8 7f             	cmp    $0x7f,%eax
f0104fb4:	75 18                	jne    f0104fce <readline+0x7a>
f0104fb6:	85 f6                	test   %esi,%esi
f0104fb8:	7e 14                	jle    f0104fce <readline+0x7a>
			if (echoing)
f0104fba:	85 ff                	test   %edi,%edi
f0104fbc:	74 0d                	je     f0104fcb <readline+0x77>
				cputchar('\b');
f0104fbe:	83 ec 0c             	sub    $0xc,%esp
f0104fc1:	6a 08                	push   $0x8
f0104fc3:	e8 b3 b7 ff ff       	call   f010077b <cputchar>
f0104fc8:	83 c4 10             	add    $0x10,%esp
			i--;
f0104fcb:	4e                   	dec    %esi
f0104fcc:	eb bb                	jmp    f0104f89 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104fce:	83 fb 1f             	cmp    $0x1f,%ebx
f0104fd1:	7e 21                	jle    f0104ff4 <readline+0xa0>
f0104fd3:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104fd9:	7f 19                	jg     f0104ff4 <readline+0xa0>
			if (echoing)
f0104fdb:	85 ff                	test   %edi,%edi
f0104fdd:	74 0c                	je     f0104feb <readline+0x97>
				cputchar(c);
f0104fdf:	83 ec 0c             	sub    $0xc,%esp
f0104fe2:	53                   	push   %ebx
f0104fe3:	e8 93 b7 ff ff       	call   f010077b <cputchar>
f0104fe8:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104feb:	88 9e 00 eb 2d f0    	mov    %bl,-0xfd21500(%esi)
f0104ff1:	46                   	inc    %esi
f0104ff2:	eb 95                	jmp    f0104f89 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104ff4:	83 fb 0a             	cmp    $0xa,%ebx
f0104ff7:	74 05                	je     f0104ffe <readline+0xaa>
f0104ff9:	83 fb 0d             	cmp    $0xd,%ebx
f0104ffc:	75 8b                	jne    f0104f89 <readline+0x35>
			if (echoing)
f0104ffe:	85 ff                	test   %edi,%edi
f0105000:	74 0d                	je     f010500f <readline+0xbb>
				cputchar('\n');
f0105002:	83 ec 0c             	sub    $0xc,%esp
f0105005:	6a 0a                	push   $0xa
f0105007:	e8 6f b7 ff ff       	call   f010077b <cputchar>
f010500c:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010500f:	c6 86 00 eb 2d f0 00 	movb   $0x0,-0xfd21500(%esi)
			return buf;
f0105016:	b8 00 eb 2d f0       	mov    $0xf02deb00,%eax
		}
	}
}
f010501b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010501e:	5b                   	pop    %ebx
f010501f:	5e                   	pop    %esi
f0105020:	5f                   	pop    %edi
f0105021:	c9                   	leave  
f0105022:	c3                   	ret    
	...

f0105024 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105024:	55                   	push   %ebp
f0105025:	89 e5                	mov    %esp,%ebp
f0105027:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010502a:	80 3a 00             	cmpb   $0x0,(%edx)
f010502d:	74 0e                	je     f010503d <strlen+0x19>
f010502f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105034:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105035:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105039:	75 f9                	jne    f0105034 <strlen+0x10>
f010503b:	eb 05                	jmp    f0105042 <strlen+0x1e>
f010503d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105042:	c9                   	leave  
f0105043:	c3                   	ret    

f0105044 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105044:	55                   	push   %ebp
f0105045:	89 e5                	mov    %esp,%ebp
f0105047:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010504a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010504d:	85 d2                	test   %edx,%edx
f010504f:	74 17                	je     f0105068 <strnlen+0x24>
f0105051:	80 39 00             	cmpb   $0x0,(%ecx)
f0105054:	74 19                	je     f010506f <strnlen+0x2b>
f0105056:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f010505b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010505c:	39 d0                	cmp    %edx,%eax
f010505e:	74 14                	je     f0105074 <strnlen+0x30>
f0105060:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105064:	75 f5                	jne    f010505b <strnlen+0x17>
f0105066:	eb 0c                	jmp    f0105074 <strnlen+0x30>
f0105068:	b8 00 00 00 00       	mov    $0x0,%eax
f010506d:	eb 05                	jmp    f0105074 <strnlen+0x30>
f010506f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105074:	c9                   	leave  
f0105075:	c3                   	ret    

f0105076 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105076:	55                   	push   %ebp
f0105077:	89 e5                	mov    %esp,%ebp
f0105079:	53                   	push   %ebx
f010507a:	8b 45 08             	mov    0x8(%ebp),%eax
f010507d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105080:	ba 00 00 00 00       	mov    $0x0,%edx
f0105085:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0105088:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f010508b:	42                   	inc    %edx
f010508c:	84 c9                	test   %cl,%cl
f010508e:	75 f5                	jne    f0105085 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105090:	5b                   	pop    %ebx
f0105091:	c9                   	leave  
f0105092:	c3                   	ret    

f0105093 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105093:	55                   	push   %ebp
f0105094:	89 e5                	mov    %esp,%ebp
f0105096:	53                   	push   %ebx
f0105097:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010509a:	53                   	push   %ebx
f010509b:	e8 84 ff ff ff       	call   f0105024 <strlen>
f01050a0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01050a3:	ff 75 0c             	pushl  0xc(%ebp)
f01050a6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01050a9:	50                   	push   %eax
f01050aa:	e8 c7 ff ff ff       	call   f0105076 <strcpy>
	return dst;
}
f01050af:	89 d8                	mov    %ebx,%eax
f01050b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01050b4:	c9                   	leave  
f01050b5:	c3                   	ret    

f01050b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01050b6:	55                   	push   %ebp
f01050b7:	89 e5                	mov    %esp,%ebp
f01050b9:	56                   	push   %esi
f01050ba:	53                   	push   %ebx
f01050bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01050be:	8b 55 0c             	mov    0xc(%ebp),%edx
f01050c1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01050c4:	85 f6                	test   %esi,%esi
f01050c6:	74 15                	je     f01050dd <strncpy+0x27>
f01050c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01050cd:	8a 1a                	mov    (%edx),%bl
f01050cf:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01050d2:	80 3a 01             	cmpb   $0x1,(%edx)
f01050d5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01050d8:	41                   	inc    %ecx
f01050d9:	39 ce                	cmp    %ecx,%esi
f01050db:	77 f0                	ja     f01050cd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01050dd:	5b                   	pop    %ebx
f01050de:	5e                   	pop    %esi
f01050df:	c9                   	leave  
f01050e0:	c3                   	ret    

f01050e1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01050e1:	55                   	push   %ebp
f01050e2:	89 e5                	mov    %esp,%ebp
f01050e4:	57                   	push   %edi
f01050e5:	56                   	push   %esi
f01050e6:	53                   	push   %ebx
f01050e7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01050ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01050ed:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01050f0:	85 f6                	test   %esi,%esi
f01050f2:	74 32                	je     f0105126 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f01050f4:	83 fe 01             	cmp    $0x1,%esi
f01050f7:	74 22                	je     f010511b <strlcpy+0x3a>
f01050f9:	8a 0b                	mov    (%ebx),%cl
f01050fb:	84 c9                	test   %cl,%cl
f01050fd:	74 20                	je     f010511f <strlcpy+0x3e>
f01050ff:	89 f8                	mov    %edi,%eax
f0105101:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0105106:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105109:	88 08                	mov    %cl,(%eax)
f010510b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010510c:	39 f2                	cmp    %esi,%edx
f010510e:	74 11                	je     f0105121 <strlcpy+0x40>
f0105110:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0105114:	42                   	inc    %edx
f0105115:	84 c9                	test   %cl,%cl
f0105117:	75 f0                	jne    f0105109 <strlcpy+0x28>
f0105119:	eb 06                	jmp    f0105121 <strlcpy+0x40>
f010511b:	89 f8                	mov    %edi,%eax
f010511d:	eb 02                	jmp    f0105121 <strlcpy+0x40>
f010511f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105121:	c6 00 00             	movb   $0x0,(%eax)
f0105124:	eb 02                	jmp    f0105128 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105126:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0105128:	29 f8                	sub    %edi,%eax
}
f010512a:	5b                   	pop    %ebx
f010512b:	5e                   	pop    %esi
f010512c:	5f                   	pop    %edi
f010512d:	c9                   	leave  
f010512e:	c3                   	ret    

f010512f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010512f:	55                   	push   %ebp
f0105130:	89 e5                	mov    %esp,%ebp
f0105132:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105135:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105138:	8a 01                	mov    (%ecx),%al
f010513a:	84 c0                	test   %al,%al
f010513c:	74 10                	je     f010514e <strcmp+0x1f>
f010513e:	3a 02                	cmp    (%edx),%al
f0105140:	75 0c                	jne    f010514e <strcmp+0x1f>
		p++, q++;
f0105142:	41                   	inc    %ecx
f0105143:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105144:	8a 01                	mov    (%ecx),%al
f0105146:	84 c0                	test   %al,%al
f0105148:	74 04                	je     f010514e <strcmp+0x1f>
f010514a:	3a 02                	cmp    (%edx),%al
f010514c:	74 f4                	je     f0105142 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010514e:	0f b6 c0             	movzbl %al,%eax
f0105151:	0f b6 12             	movzbl (%edx),%edx
f0105154:	29 d0                	sub    %edx,%eax
}
f0105156:	c9                   	leave  
f0105157:	c3                   	ret    

f0105158 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105158:	55                   	push   %ebp
f0105159:	89 e5                	mov    %esp,%ebp
f010515b:	53                   	push   %ebx
f010515c:	8b 55 08             	mov    0x8(%ebp),%edx
f010515f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105162:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0105165:	85 c0                	test   %eax,%eax
f0105167:	74 1b                	je     f0105184 <strncmp+0x2c>
f0105169:	8a 1a                	mov    (%edx),%bl
f010516b:	84 db                	test   %bl,%bl
f010516d:	74 24                	je     f0105193 <strncmp+0x3b>
f010516f:	3a 19                	cmp    (%ecx),%bl
f0105171:	75 20                	jne    f0105193 <strncmp+0x3b>
f0105173:	48                   	dec    %eax
f0105174:	74 15                	je     f010518b <strncmp+0x33>
		n--, p++, q++;
f0105176:	42                   	inc    %edx
f0105177:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105178:	8a 1a                	mov    (%edx),%bl
f010517a:	84 db                	test   %bl,%bl
f010517c:	74 15                	je     f0105193 <strncmp+0x3b>
f010517e:	3a 19                	cmp    (%ecx),%bl
f0105180:	74 f1                	je     f0105173 <strncmp+0x1b>
f0105182:	eb 0f                	jmp    f0105193 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105184:	b8 00 00 00 00       	mov    $0x0,%eax
f0105189:	eb 05                	jmp    f0105190 <strncmp+0x38>
f010518b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105190:	5b                   	pop    %ebx
f0105191:	c9                   	leave  
f0105192:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105193:	0f b6 02             	movzbl (%edx),%eax
f0105196:	0f b6 11             	movzbl (%ecx),%edx
f0105199:	29 d0                	sub    %edx,%eax
f010519b:	eb f3                	jmp    f0105190 <strncmp+0x38>

f010519d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010519d:	55                   	push   %ebp
f010519e:	89 e5                	mov    %esp,%ebp
f01051a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01051a3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01051a6:	8a 10                	mov    (%eax),%dl
f01051a8:	84 d2                	test   %dl,%dl
f01051aa:	74 18                	je     f01051c4 <strchr+0x27>
		if (*s == c)
f01051ac:	38 ca                	cmp    %cl,%dl
f01051ae:	75 06                	jne    f01051b6 <strchr+0x19>
f01051b0:	eb 17                	jmp    f01051c9 <strchr+0x2c>
f01051b2:	38 ca                	cmp    %cl,%dl
f01051b4:	74 13                	je     f01051c9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01051b6:	40                   	inc    %eax
f01051b7:	8a 10                	mov    (%eax),%dl
f01051b9:	84 d2                	test   %dl,%dl
f01051bb:	75 f5                	jne    f01051b2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f01051bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01051c2:	eb 05                	jmp    f01051c9 <strchr+0x2c>
f01051c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01051c9:	c9                   	leave  
f01051ca:	c3                   	ret    

f01051cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01051cb:	55                   	push   %ebp
f01051cc:	89 e5                	mov    %esp,%ebp
f01051ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01051d1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01051d4:	8a 10                	mov    (%eax),%dl
f01051d6:	84 d2                	test   %dl,%dl
f01051d8:	74 11                	je     f01051eb <strfind+0x20>
		if (*s == c)
f01051da:	38 ca                	cmp    %cl,%dl
f01051dc:	75 06                	jne    f01051e4 <strfind+0x19>
f01051de:	eb 0b                	jmp    f01051eb <strfind+0x20>
f01051e0:	38 ca                	cmp    %cl,%dl
f01051e2:	74 07                	je     f01051eb <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01051e4:	40                   	inc    %eax
f01051e5:	8a 10                	mov    (%eax),%dl
f01051e7:	84 d2                	test   %dl,%dl
f01051e9:	75 f5                	jne    f01051e0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f01051eb:	c9                   	leave  
f01051ec:	c3                   	ret    

f01051ed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01051ed:	55                   	push   %ebp
f01051ee:	89 e5                	mov    %esp,%ebp
f01051f0:	57                   	push   %edi
f01051f1:	56                   	push   %esi
f01051f2:	53                   	push   %ebx
f01051f3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01051f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01051fc:	85 c9                	test   %ecx,%ecx
f01051fe:	74 30                	je     f0105230 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105200:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105206:	75 25                	jne    f010522d <memset+0x40>
f0105208:	f6 c1 03             	test   $0x3,%cl
f010520b:	75 20                	jne    f010522d <memset+0x40>
		c &= 0xFF;
f010520d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105210:	89 d3                	mov    %edx,%ebx
f0105212:	c1 e3 08             	shl    $0x8,%ebx
f0105215:	89 d6                	mov    %edx,%esi
f0105217:	c1 e6 18             	shl    $0x18,%esi
f010521a:	89 d0                	mov    %edx,%eax
f010521c:	c1 e0 10             	shl    $0x10,%eax
f010521f:	09 f0                	or     %esi,%eax
f0105221:	09 d0                	or     %edx,%eax
f0105223:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105225:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105228:	fc                   	cld    
f0105229:	f3 ab                	rep stos %eax,%es:(%edi)
f010522b:	eb 03                	jmp    f0105230 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010522d:	fc                   	cld    
f010522e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105230:	89 f8                	mov    %edi,%eax
f0105232:	5b                   	pop    %ebx
f0105233:	5e                   	pop    %esi
f0105234:	5f                   	pop    %edi
f0105235:	c9                   	leave  
f0105236:	c3                   	ret    

f0105237 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105237:	55                   	push   %ebp
f0105238:	89 e5                	mov    %esp,%ebp
f010523a:	57                   	push   %edi
f010523b:	56                   	push   %esi
f010523c:	8b 45 08             	mov    0x8(%ebp),%eax
f010523f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105242:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105245:	39 c6                	cmp    %eax,%esi
f0105247:	73 34                	jae    f010527d <memmove+0x46>
f0105249:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010524c:	39 d0                	cmp    %edx,%eax
f010524e:	73 2d                	jae    f010527d <memmove+0x46>
		s += n;
		d += n;
f0105250:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105253:	f6 c2 03             	test   $0x3,%dl
f0105256:	75 1b                	jne    f0105273 <memmove+0x3c>
f0105258:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010525e:	75 13                	jne    f0105273 <memmove+0x3c>
f0105260:	f6 c1 03             	test   $0x3,%cl
f0105263:	75 0e                	jne    f0105273 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105265:	83 ef 04             	sub    $0x4,%edi
f0105268:	8d 72 fc             	lea    -0x4(%edx),%esi
f010526b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010526e:	fd                   	std    
f010526f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105271:	eb 07                	jmp    f010527a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105273:	4f                   	dec    %edi
f0105274:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105277:	fd                   	std    
f0105278:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010527a:	fc                   	cld    
f010527b:	eb 20                	jmp    f010529d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010527d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105283:	75 13                	jne    f0105298 <memmove+0x61>
f0105285:	a8 03                	test   $0x3,%al
f0105287:	75 0f                	jne    f0105298 <memmove+0x61>
f0105289:	f6 c1 03             	test   $0x3,%cl
f010528c:	75 0a                	jne    f0105298 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010528e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105291:	89 c7                	mov    %eax,%edi
f0105293:	fc                   	cld    
f0105294:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105296:	eb 05                	jmp    f010529d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105298:	89 c7                	mov    %eax,%edi
f010529a:	fc                   	cld    
f010529b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010529d:	5e                   	pop    %esi
f010529e:	5f                   	pop    %edi
f010529f:	c9                   	leave  
f01052a0:	c3                   	ret    

f01052a1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01052a1:	55                   	push   %ebp
f01052a2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01052a4:	ff 75 10             	pushl  0x10(%ebp)
f01052a7:	ff 75 0c             	pushl  0xc(%ebp)
f01052aa:	ff 75 08             	pushl  0x8(%ebp)
f01052ad:	e8 85 ff ff ff       	call   f0105237 <memmove>
}
f01052b2:	c9                   	leave  
f01052b3:	c3                   	ret    

f01052b4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01052b4:	55                   	push   %ebp
f01052b5:	89 e5                	mov    %esp,%ebp
f01052b7:	57                   	push   %edi
f01052b8:	56                   	push   %esi
f01052b9:	53                   	push   %ebx
f01052ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01052bd:	8b 75 0c             	mov    0xc(%ebp),%esi
f01052c0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01052c3:	85 ff                	test   %edi,%edi
f01052c5:	74 32                	je     f01052f9 <memcmp+0x45>
		if (*s1 != *s2)
f01052c7:	8a 03                	mov    (%ebx),%al
f01052c9:	8a 0e                	mov    (%esi),%cl
f01052cb:	38 c8                	cmp    %cl,%al
f01052cd:	74 19                	je     f01052e8 <memcmp+0x34>
f01052cf:	eb 0d                	jmp    f01052de <memcmp+0x2a>
f01052d1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f01052d5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f01052d9:	42                   	inc    %edx
f01052da:	38 c8                	cmp    %cl,%al
f01052dc:	74 10                	je     f01052ee <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f01052de:	0f b6 c0             	movzbl %al,%eax
f01052e1:	0f b6 c9             	movzbl %cl,%ecx
f01052e4:	29 c8                	sub    %ecx,%eax
f01052e6:	eb 16                	jmp    f01052fe <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01052e8:	4f                   	dec    %edi
f01052e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01052ee:	39 fa                	cmp    %edi,%edx
f01052f0:	75 df                	jne    f01052d1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01052f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01052f7:	eb 05                	jmp    f01052fe <memcmp+0x4a>
f01052f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01052fe:	5b                   	pop    %ebx
f01052ff:	5e                   	pop    %esi
f0105300:	5f                   	pop    %edi
f0105301:	c9                   	leave  
f0105302:	c3                   	ret    

f0105303 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105303:	55                   	push   %ebp
f0105304:	89 e5                	mov    %esp,%ebp
f0105306:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105309:	89 c2                	mov    %eax,%edx
f010530b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010530e:	39 d0                	cmp    %edx,%eax
f0105310:	73 12                	jae    f0105324 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105312:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0105315:	38 08                	cmp    %cl,(%eax)
f0105317:	75 06                	jne    f010531f <memfind+0x1c>
f0105319:	eb 09                	jmp    f0105324 <memfind+0x21>
f010531b:	38 08                	cmp    %cl,(%eax)
f010531d:	74 05                	je     f0105324 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010531f:	40                   	inc    %eax
f0105320:	39 c2                	cmp    %eax,%edx
f0105322:	77 f7                	ja     f010531b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105324:	c9                   	leave  
f0105325:	c3                   	ret    

f0105326 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105326:	55                   	push   %ebp
f0105327:	89 e5                	mov    %esp,%ebp
f0105329:	57                   	push   %edi
f010532a:	56                   	push   %esi
f010532b:	53                   	push   %ebx
f010532c:	8b 55 08             	mov    0x8(%ebp),%edx
f010532f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105332:	eb 01                	jmp    f0105335 <strtol+0xf>
		s++;
f0105334:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105335:	8a 02                	mov    (%edx),%al
f0105337:	3c 20                	cmp    $0x20,%al
f0105339:	74 f9                	je     f0105334 <strtol+0xe>
f010533b:	3c 09                	cmp    $0x9,%al
f010533d:	74 f5                	je     f0105334 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010533f:	3c 2b                	cmp    $0x2b,%al
f0105341:	75 08                	jne    f010534b <strtol+0x25>
		s++;
f0105343:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105344:	bf 00 00 00 00       	mov    $0x0,%edi
f0105349:	eb 13                	jmp    f010535e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010534b:	3c 2d                	cmp    $0x2d,%al
f010534d:	75 0a                	jne    f0105359 <strtol+0x33>
		s++, neg = 1;
f010534f:	8d 52 01             	lea    0x1(%edx),%edx
f0105352:	bf 01 00 00 00       	mov    $0x1,%edi
f0105357:	eb 05                	jmp    f010535e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105359:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010535e:	85 db                	test   %ebx,%ebx
f0105360:	74 05                	je     f0105367 <strtol+0x41>
f0105362:	83 fb 10             	cmp    $0x10,%ebx
f0105365:	75 28                	jne    f010538f <strtol+0x69>
f0105367:	8a 02                	mov    (%edx),%al
f0105369:	3c 30                	cmp    $0x30,%al
f010536b:	75 10                	jne    f010537d <strtol+0x57>
f010536d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105371:	75 0a                	jne    f010537d <strtol+0x57>
		s += 2, base = 16;
f0105373:	83 c2 02             	add    $0x2,%edx
f0105376:	bb 10 00 00 00       	mov    $0x10,%ebx
f010537b:	eb 12                	jmp    f010538f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f010537d:	85 db                	test   %ebx,%ebx
f010537f:	75 0e                	jne    f010538f <strtol+0x69>
f0105381:	3c 30                	cmp    $0x30,%al
f0105383:	75 05                	jne    f010538a <strtol+0x64>
		s++, base = 8;
f0105385:	42                   	inc    %edx
f0105386:	b3 08                	mov    $0x8,%bl
f0105388:	eb 05                	jmp    f010538f <strtol+0x69>
	else if (base == 0)
		base = 10;
f010538a:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010538f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105394:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105396:	8a 0a                	mov    (%edx),%cl
f0105398:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f010539b:	80 fb 09             	cmp    $0x9,%bl
f010539e:	77 08                	ja     f01053a8 <strtol+0x82>
			dig = *s - '0';
f01053a0:	0f be c9             	movsbl %cl,%ecx
f01053a3:	83 e9 30             	sub    $0x30,%ecx
f01053a6:	eb 1e                	jmp    f01053c6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01053a8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01053ab:	80 fb 19             	cmp    $0x19,%bl
f01053ae:	77 08                	ja     f01053b8 <strtol+0x92>
			dig = *s - 'a' + 10;
f01053b0:	0f be c9             	movsbl %cl,%ecx
f01053b3:	83 e9 57             	sub    $0x57,%ecx
f01053b6:	eb 0e                	jmp    f01053c6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01053b8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01053bb:	80 fb 19             	cmp    $0x19,%bl
f01053be:	77 13                	ja     f01053d3 <strtol+0xad>
			dig = *s - 'A' + 10;
f01053c0:	0f be c9             	movsbl %cl,%ecx
f01053c3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01053c6:	39 f1                	cmp    %esi,%ecx
f01053c8:	7d 0d                	jge    f01053d7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f01053ca:	42                   	inc    %edx
f01053cb:	0f af c6             	imul   %esi,%eax
f01053ce:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f01053d1:	eb c3                	jmp    f0105396 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01053d3:	89 c1                	mov    %eax,%ecx
f01053d5:	eb 02                	jmp    f01053d9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01053d7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01053d9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01053dd:	74 05                	je     f01053e4 <strtol+0xbe>
		*endptr = (char *) s;
f01053df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053e2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01053e4:	85 ff                	test   %edi,%edi
f01053e6:	74 04                	je     f01053ec <strtol+0xc6>
f01053e8:	89 c8                	mov    %ecx,%eax
f01053ea:	f7 d8                	neg    %eax
}
f01053ec:	5b                   	pop    %ebx
f01053ed:	5e                   	pop    %esi
f01053ee:	5f                   	pop    %edi
f01053ef:	c9                   	leave  
f01053f0:	c3                   	ret    
f01053f1:	00 00                	add    %al,(%eax)
	...

f01053f4 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01053f4:	fa                   	cli    

	xorw    %ax, %ax
f01053f5:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01053f7:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01053f9:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01053fb:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01053fd:	0f 01 16             	lgdtl  (%esi)
f0105400:	74 70                	je     f0105472 <sum+0x2>
	movl    %cr0, %eax
f0105402:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105405:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105409:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f010540c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105412:	08 00                	or     %al,(%eax)

f0105414 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105414:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105418:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010541a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010541c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010541e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105422:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105424:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105426:	b8 00 50 12 00       	mov    $0x125000,%eax
	movl    %eax, %cr3
f010542b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010542e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105431:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105436:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105439:	8b 25 04 ef 2d f0    	mov    0xf02def04,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010543f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105444:	b8 c2 00 10 f0       	mov    $0xf01000c2,%eax
	call    *%eax
f0105449:	ff d0                	call   *%eax

f010544b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010544b:	eb fe                	jmp    f010544b <spin>
f010544d:	8d 76 00             	lea    0x0(%esi),%esi

f0105450 <gdt>:
	...
f0105458:	ff                   	(bad)  
f0105459:	ff 00                	incl   (%eax)
f010545b:	00 00                	add    %al,(%eax)
f010545d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105464:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105468 <gdtdesc>:
f0105468:	17                   	pop    %ss
f0105469:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010546e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010546e:	90                   	nop
	...

f0105470 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105470:	55                   	push   %ebp
f0105471:	89 e5                	mov    %esp,%ebp
f0105473:	56                   	push   %esi
f0105474:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105475:	85 d2                	test   %edx,%edx
f0105477:	7e 17                	jle    f0105490 <sum+0x20>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105479:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f010547e:	b9 00 00 00 00       	mov    $0x0,%ecx
		sum += ((uint8_t *)addr)[i];
f0105483:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0105487:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105489:	41                   	inc    %ecx
f010548a:	39 d1                	cmp    %edx,%ecx
f010548c:	75 f5                	jne    f0105483 <sum+0x13>
f010548e:	eb 05                	jmp    f0105495 <sum+0x25>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105490:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0105495:	88 d8                	mov    %bl,%al
f0105497:	5b                   	pop    %ebx
f0105498:	5e                   	pop    %esi
f0105499:	c9                   	leave  
f010549a:	c3                   	ret    

f010549b <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010549b:	55                   	push   %ebp
f010549c:	89 e5                	mov    %esp,%ebp
f010549e:	56                   	push   %esi
f010549f:	53                   	push   %ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01054a0:	8b 0d 08 ef 2d f0    	mov    0xf02def08,%ecx
f01054a6:	89 c3                	mov    %eax,%ebx
f01054a8:	c1 eb 0c             	shr    $0xc,%ebx
f01054ab:	39 cb                	cmp    %ecx,%ebx
f01054ad:	72 12                	jb     f01054c1 <mpsearch1+0x26>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01054af:	50                   	push   %eax
f01054b0:	68 08 5f 10 f0       	push   $0xf0105f08
f01054b5:	6a 57                	push   $0x57
f01054b7:	68 e1 7e 10 f0       	push   $0xf0107ee1
f01054bc:	e8 a7 ab ff ff       	call   f0100068 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01054c1:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01054c4:	89 f2                	mov    %esi,%edx
f01054c6:	c1 ea 0c             	shr    $0xc,%edx
f01054c9:	39 d1                	cmp    %edx,%ecx
f01054cb:	77 12                	ja     f01054df <mpsearch1+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01054cd:	56                   	push   %esi
f01054ce:	68 08 5f 10 f0       	push   $0xf0105f08
f01054d3:	6a 57                	push   $0x57
f01054d5:	68 e1 7e 10 f0       	push   $0xf0107ee1
f01054da:	e8 89 ab ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f01054df:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01054e5:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01054eb:	39 f3                	cmp    %esi,%ebx
f01054ed:	73 35                	jae    f0105524 <mpsearch1+0x89>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01054ef:	83 ec 04             	sub    $0x4,%esp
f01054f2:	6a 04                	push   $0x4
f01054f4:	68 f1 7e 10 f0       	push   $0xf0107ef1
f01054f9:	53                   	push   %ebx
f01054fa:	e8 b5 fd ff ff       	call   f01052b4 <memcmp>
f01054ff:	83 c4 10             	add    $0x10,%esp
f0105502:	85 c0                	test   %eax,%eax
f0105504:	75 10                	jne    f0105516 <mpsearch1+0x7b>
		    sum(mp, sizeof(*mp)) == 0)
f0105506:	ba 10 00 00 00       	mov    $0x10,%edx
f010550b:	89 d8                	mov    %ebx,%eax
f010550d:	e8 5e ff ff ff       	call   f0105470 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105512:	84 c0                	test   %al,%al
f0105514:	74 13                	je     f0105529 <mpsearch1+0x8e>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105516:	83 c3 10             	add    $0x10,%ebx
f0105519:	39 de                	cmp    %ebx,%esi
f010551b:	77 d2                	ja     f01054ef <mpsearch1+0x54>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010551d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105522:	eb 05                	jmp    f0105529 <mpsearch1+0x8e>
f0105524:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105529:	89 d8                	mov    %ebx,%eax
f010552b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010552e:	5b                   	pop    %ebx
f010552f:	5e                   	pop    %esi
f0105530:	c9                   	leave  
f0105531:	c3                   	ret    

f0105532 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105532:	55                   	push   %ebp
f0105533:	89 e5                	mov    %esp,%ebp
f0105535:	57                   	push   %edi
f0105536:	56                   	push   %esi
f0105537:	53                   	push   %ebx
f0105538:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010553b:	c7 05 c0 f3 2d f0 20 	movl   $0xf02df020,0xf02df3c0
f0105542:	f0 2d f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105545:	83 3d 08 ef 2d f0 00 	cmpl   $0x0,0xf02def08
f010554c:	75 16                	jne    f0105564 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010554e:	68 00 04 00 00       	push   $0x400
f0105553:	68 08 5f 10 f0       	push   $0xf0105f08
f0105558:	6a 6f                	push   $0x6f
f010555a:	68 e1 7e 10 f0       	push   $0xf0107ee1
f010555f:	e8 04 ab ff ff       	call   f0100068 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105564:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f010556b:	85 c0                	test   %eax,%eax
f010556d:	74 16                	je     f0105585 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
f010556f:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105572:	ba 00 04 00 00       	mov    $0x400,%edx
f0105577:	e8 1f ff ff ff       	call   f010549b <mpsearch1>
f010557c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010557f:	85 c0                	test   %eax,%eax
f0105581:	75 3c                	jne    f01055bf <mp_init+0x8d>
f0105583:	eb 20                	jmp    f01055a5 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105585:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010558c:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010558f:	2d 00 04 00 00       	sub    $0x400,%eax
f0105594:	ba 00 04 00 00       	mov    $0x400,%edx
f0105599:	e8 fd fe ff ff       	call   f010549b <mpsearch1>
f010559e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01055a1:	85 c0                	test   %eax,%eax
f01055a3:	75 1a                	jne    f01055bf <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01055a5:	ba 00 00 01 00       	mov    $0x10000,%edx
f01055aa:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01055af:	e8 e7 fe ff ff       	call   f010549b <mpsearch1>
f01055b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01055b7:	85 c0                	test   %eax,%eax
f01055b9:	0f 84 3b 02 00 00    	je     f01057fa <mp_init+0x2c8>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01055bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055c2:	8b 70 04             	mov    0x4(%eax),%esi
f01055c5:	85 f6                	test   %esi,%esi
f01055c7:	74 06                	je     f01055cf <mp_init+0x9d>
f01055c9:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01055cd:	74 15                	je     f01055e4 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f01055cf:	83 ec 0c             	sub    $0xc,%esp
f01055d2:	68 54 7d 10 f0       	push   $0xf0107d54
f01055d7:	e8 9d e6 ff ff       	call   f0103c79 <cprintf>
f01055dc:	83 c4 10             	add    $0x10,%esp
f01055df:	e9 16 02 00 00       	jmp    f01057fa <mp_init+0x2c8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01055e4:	89 f0                	mov    %esi,%eax
f01055e6:	c1 e8 0c             	shr    $0xc,%eax
f01055e9:	3b 05 08 ef 2d f0    	cmp    0xf02def08,%eax
f01055ef:	72 15                	jb     f0105606 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01055f1:	56                   	push   %esi
f01055f2:	68 08 5f 10 f0       	push   $0xf0105f08
f01055f7:	68 90 00 00 00       	push   $0x90
f01055fc:	68 e1 7e 10 f0       	push   $0xf0107ee1
f0105601:	e8 62 aa ff ff       	call   f0100068 <_panic>
	return (void *)(pa + KERNBASE);
f0105606:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010560c:	83 ec 04             	sub    $0x4,%esp
f010560f:	6a 04                	push   $0x4
f0105611:	68 f6 7e 10 f0       	push   $0xf0107ef6
f0105616:	56                   	push   %esi
f0105617:	e8 98 fc ff ff       	call   f01052b4 <memcmp>
f010561c:	83 c4 10             	add    $0x10,%esp
f010561f:	85 c0                	test   %eax,%eax
f0105621:	74 15                	je     f0105638 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105623:	83 ec 0c             	sub    $0xc,%esp
f0105626:	68 84 7d 10 f0       	push   $0xf0107d84
f010562b:	e8 49 e6 ff ff       	call   f0103c79 <cprintf>
f0105630:	83 c4 10             	add    $0x10,%esp
f0105633:	e9 c2 01 00 00       	jmp    f01057fa <mp_init+0x2c8>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105638:	66 8b 5e 04          	mov    0x4(%esi),%bx
f010563c:	0f b7 d3             	movzwl %bx,%edx
f010563f:	89 f0                	mov    %esi,%eax
f0105641:	e8 2a fe ff ff       	call   f0105470 <sum>
f0105646:	84 c0                	test   %al,%al
f0105648:	74 15                	je     f010565f <mp_init+0x12d>
		cprintf("SMP: Bad MP configuration checksum\n");
f010564a:	83 ec 0c             	sub    $0xc,%esp
f010564d:	68 b8 7d 10 f0       	push   $0xf0107db8
f0105652:	e8 22 e6 ff ff       	call   f0103c79 <cprintf>
f0105657:	83 c4 10             	add    $0x10,%esp
f010565a:	e9 9b 01 00 00       	jmp    f01057fa <mp_init+0x2c8>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010565f:	8a 46 06             	mov    0x6(%esi),%al
f0105662:	3c 01                	cmp    $0x1,%al
f0105664:	74 1d                	je     f0105683 <mp_init+0x151>
f0105666:	3c 04                	cmp    $0x4,%al
f0105668:	74 19                	je     f0105683 <mp_init+0x151>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010566a:	83 ec 08             	sub    $0x8,%esp
f010566d:	0f b6 c0             	movzbl %al,%eax
f0105670:	50                   	push   %eax
f0105671:	68 dc 7d 10 f0       	push   $0xf0107ddc
f0105676:	e8 fe e5 ff ff       	call   f0103c79 <cprintf>
f010567b:	83 c4 10             	add    $0x10,%esp
f010567e:	e9 77 01 00 00       	jmp    f01057fa <mp_init+0x2c8>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0105683:	0f b7 56 28          	movzwl 0x28(%esi),%edx
f0105687:	0f b7 c3             	movzwl %bx,%eax
f010568a:	8d 04 06             	lea    (%esi,%eax,1),%eax
f010568d:	e8 de fd ff ff       	call   f0105470 <sum>
f0105692:	3a 46 2a             	cmp    0x2a(%esi),%al
f0105695:	74 15                	je     f01056ac <mp_init+0x17a>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105697:	83 ec 0c             	sub    $0xc,%esp
f010569a:	68 fc 7d 10 f0       	push   $0xf0107dfc
f010569f:	e8 d5 e5 ff ff       	call   f0103c79 <cprintf>
f01056a4:	83 c4 10             	add    $0x10,%esp
f01056a7:	e9 4e 01 00 00       	jmp    f01057fa <mp_init+0x2c8>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01056ac:	85 f6                	test   %esi,%esi
f01056ae:	0f 84 46 01 00 00    	je     f01057fa <mp_init+0x2c8>
		return;
	ismp = 1;
f01056b4:	c7 05 00 f0 2d f0 01 	movl   $0x1,0xf02df000
f01056bb:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01056be:	8b 46 24             	mov    0x24(%esi),%eax
f01056c1:	a3 00 00 32 f0       	mov    %eax,0xf0320000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01056c6:	66 83 7e 22 00       	cmpw   $0x0,0x22(%esi)
f01056cb:	0f 84 ac 00 00 00    	je     f010577d <mp_init+0x24b>
f01056d1:	8d 5e 2c             	lea    0x2c(%esi),%ebx
f01056d4:	bf 00 00 00 00       	mov    $0x0,%edi
		switch (*p) {
f01056d9:	8a 03                	mov    (%ebx),%al
f01056db:	84 c0                	test   %al,%al
f01056dd:	74 06                	je     f01056e5 <mp_init+0x1b3>
f01056df:	3c 04                	cmp    $0x4,%al
f01056e1:	77 6b                	ja     f010574e <mp_init+0x21c>
f01056e3:	eb 64                	jmp    f0105749 <mp_init+0x217>
		case MPPROC:
			proc = (struct mpproc *)p;
f01056e5:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f01056e7:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f01056eb:	74 1d                	je     f010570a <mp_init+0x1d8>
				bootcpu = &cpus[ncpu];
f01056ed:	a1 c4 f3 2d f0       	mov    0xf02df3c4,%eax
f01056f2:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f01056f9:	29 c1                	sub    %eax,%ecx
f01056fb:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f01056fe:	8d 04 85 20 f0 2d f0 	lea    -0xfd20fe0(,%eax,4),%eax
f0105705:	a3 c0 f3 2d f0       	mov    %eax,0xf02df3c0
			if (ncpu < NCPU) {
f010570a:	a1 c4 f3 2d f0       	mov    0xf02df3c4,%eax
f010570f:	83 f8 07             	cmp    $0x7,%eax
f0105712:	7f 1b                	jg     f010572f <mp_init+0x1fd>
				cpus[ncpu].cpu_id = ncpu;
f0105714:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010571b:	29 c2                	sub    %eax,%edx
f010571d:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105720:	88 04 95 20 f0 2d f0 	mov    %al,-0xfd20fe0(,%edx,4)
				ncpu++;
f0105727:	40                   	inc    %eax
f0105728:	a3 c4 f3 2d f0       	mov    %eax,0xf02df3c4
f010572d:	eb 15                	jmp    f0105744 <mp_init+0x212>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010572f:	83 ec 08             	sub    $0x8,%esp
f0105732:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0105736:	50                   	push   %eax
f0105737:	68 2c 7e 10 f0       	push   $0xf0107e2c
f010573c:	e8 38 e5 ff ff       	call   f0103c79 <cprintf>
f0105741:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105744:	83 c3 14             	add    $0x14,%ebx
			continue;
f0105747:	eb 27                	jmp    f0105770 <mp_init+0x23e>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105749:	83 c3 08             	add    $0x8,%ebx
			continue;
f010574c:	eb 22                	jmp    f0105770 <mp_init+0x23e>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010574e:	83 ec 08             	sub    $0x8,%esp
f0105751:	0f b6 c0             	movzbl %al,%eax
f0105754:	50                   	push   %eax
f0105755:	68 54 7e 10 f0       	push   $0xf0107e54
f010575a:	e8 1a e5 ff ff       	call   f0103c79 <cprintf>
			ismp = 0;
f010575f:	c7 05 00 f0 2d f0 00 	movl   $0x0,0xf02df000
f0105766:	00 00 00 
			i = conf->entry;
f0105769:	0f b7 7e 22          	movzwl 0x22(%esi),%edi
f010576d:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105770:	47                   	inc    %edi
f0105771:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105775:	39 f8                	cmp    %edi,%eax
f0105777:	0f 87 5c ff ff ff    	ja     f01056d9 <mp_init+0x1a7>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010577d:	a1 c0 f3 2d f0       	mov    0xf02df3c0,%eax
f0105782:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105789:	83 3d 00 f0 2d f0 00 	cmpl   $0x0,0xf02df000
f0105790:	75 26                	jne    f01057b8 <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105792:	c7 05 c4 f3 2d f0 01 	movl   $0x1,0xf02df3c4
f0105799:	00 00 00 
		lapicaddr = 0;
f010579c:	c7 05 00 00 32 f0 00 	movl   $0x0,0xf0320000
f01057a3:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01057a6:	83 ec 0c             	sub    $0xc,%esp
f01057a9:	68 74 7e 10 f0       	push   $0xf0107e74
f01057ae:	e8 c6 e4 ff ff       	call   f0103c79 <cprintf>
		return;
f01057b3:	83 c4 10             	add    $0x10,%esp
f01057b6:	eb 42                	jmp    f01057fa <mp_init+0x2c8>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01057b8:	83 ec 04             	sub    $0x4,%esp
f01057bb:	ff 35 c4 f3 2d f0    	pushl  0xf02df3c4
f01057c1:	0f b6 00             	movzbl (%eax),%eax
f01057c4:	50                   	push   %eax
f01057c5:	68 fb 7e 10 f0       	push   $0xf0107efb
f01057ca:	e8 aa e4 ff ff       	call   f0103c79 <cprintf>

	if (mp->imcrp) {
f01057cf:	83 c4 10             	add    $0x10,%esp
f01057d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01057d5:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01057d9:	74 1f                	je     f01057fa <mp_init+0x2c8>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01057db:	83 ec 0c             	sub    $0xc,%esp
f01057de:	68 a0 7e 10 f0       	push   $0xf0107ea0
f01057e3:	e8 91 e4 ff ff       	call   f0103c79 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01057e8:	ba 22 00 00 00       	mov    $0x22,%edx
f01057ed:	b0 70                	mov    $0x70,%al
f01057ef:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01057f0:	b2 23                	mov    $0x23,%dl
f01057f2:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01057f3:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01057f6:	ee                   	out    %al,(%dx)
f01057f7:	83 c4 10             	add    $0x10,%esp
	}
}
f01057fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01057fd:	5b                   	pop    %ebx
f01057fe:	5e                   	pop    %esi
f01057ff:	5f                   	pop    %edi
f0105800:	c9                   	leave  
f0105801:	c3                   	ret    
	...

f0105804 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105804:	55                   	push   %ebp
f0105805:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105807:	c1 e0 02             	shl    $0x2,%eax
f010580a:	03 05 04 00 32 f0    	add    0xf0320004,%eax
f0105810:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105812:	a1 04 00 32 f0       	mov    0xf0320004,%eax
f0105817:	8b 40 20             	mov    0x20(%eax),%eax
}
f010581a:	c9                   	leave  
f010581b:	c3                   	ret    

f010581c <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010581c:	55                   	push   %ebp
f010581d:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010581f:	a1 04 00 32 f0       	mov    0xf0320004,%eax
f0105824:	85 c0                	test   %eax,%eax
f0105826:	74 08                	je     f0105830 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105828:	8b 40 20             	mov    0x20(%eax),%eax
f010582b:	c1 e8 18             	shr    $0x18,%eax
f010582e:	eb 05                	jmp    f0105835 <cpunum+0x19>
	return 0;
f0105830:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105835:	c9                   	leave  
f0105836:	c3                   	ret    

f0105837 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105837:	55                   	push   %ebp
f0105838:	89 e5                	mov    %esp,%ebp
f010583a:	83 ec 08             	sub    $0x8,%esp
	if (!lapicaddr)
f010583d:	a1 00 00 32 f0       	mov    0xf0320000,%eax
f0105842:	85 c0                	test   %eax,%eax
f0105844:	0f 84 2a 01 00 00    	je     f0105974 <lapic_init+0x13d>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f010584a:	83 ec 08             	sub    $0x8,%esp
f010584d:	68 00 10 00 00       	push   $0x1000
f0105852:	50                   	push   %eax
f0105853:	e8 61 c0 ff ff       	call   f01018b9 <mmio_map_region>
f0105858:	a3 04 00 32 f0       	mov    %eax,0xf0320004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010585d:	ba 27 01 00 00       	mov    $0x127,%edx
f0105862:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105867:	e8 98 ff ff ff       	call   f0105804 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010586c:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105871:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105876:	e8 89 ff ff ff       	call   f0105804 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010587b:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105880:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105885:	e8 7a ff ff ff       	call   f0105804 <lapicw>
	lapicw(TICR, 10000000); 
f010588a:	ba 80 96 98 00       	mov    $0x989680,%edx
f010588f:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105894:	e8 6b ff ff ff       	call   f0105804 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105899:	e8 7e ff ff ff       	call   f010581c <cpunum>
f010589e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01058a5:	29 c2                	sub    %eax,%edx
f01058a7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01058aa:	8d 04 85 20 f0 2d f0 	lea    -0xfd20fe0(,%eax,4),%eax
f01058b1:	83 c4 10             	add    $0x10,%esp
f01058b4:	39 05 c0 f3 2d f0    	cmp    %eax,0xf02df3c0
f01058ba:	74 0f                	je     f01058cb <lapic_init+0x94>
		lapicw(LINT0, MASKED);
f01058bc:	ba 00 00 01 00       	mov    $0x10000,%edx
f01058c1:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01058c6:	e8 39 ff ff ff       	call   f0105804 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01058cb:	ba 00 00 01 00       	mov    $0x10000,%edx
f01058d0:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01058d5:	e8 2a ff ff ff       	call   f0105804 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01058da:	a1 04 00 32 f0       	mov    0xf0320004,%eax
f01058df:	8b 40 30             	mov    0x30(%eax),%eax
f01058e2:	c1 e8 10             	shr    $0x10,%eax
f01058e5:	3c 03                	cmp    $0x3,%al
f01058e7:	76 0f                	jbe    f01058f8 <lapic_init+0xc1>
		lapicw(PCINT, MASKED);
f01058e9:	ba 00 00 01 00       	mov    $0x10000,%edx
f01058ee:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01058f3:	e8 0c ff ff ff       	call   f0105804 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01058f8:	ba 33 00 00 00       	mov    $0x33,%edx
f01058fd:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105902:	e8 fd fe ff ff       	call   f0105804 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105907:	ba 00 00 00 00       	mov    $0x0,%edx
f010590c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105911:	e8 ee fe ff ff       	call   f0105804 <lapicw>
	lapicw(ESR, 0);
f0105916:	ba 00 00 00 00       	mov    $0x0,%edx
f010591b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105920:	e8 df fe ff ff       	call   f0105804 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105925:	ba 00 00 00 00       	mov    $0x0,%edx
f010592a:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010592f:	e8 d0 fe ff ff       	call   f0105804 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105934:	ba 00 00 00 00       	mov    $0x0,%edx
f0105939:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010593e:	e8 c1 fe ff ff       	call   f0105804 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105943:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105948:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010594d:	e8 b2 fe ff ff       	call   f0105804 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105952:	8b 15 04 00 32 f0    	mov    0xf0320004,%edx
f0105958:	81 c2 00 03 00 00    	add    $0x300,%edx
f010595e:	8b 02                	mov    (%edx),%eax
f0105960:	f6 c4 10             	test   $0x10,%ah
f0105963:	75 f9                	jne    f010595e <lapic_init+0x127>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105965:	ba 00 00 00 00       	mov    $0x0,%edx
f010596a:	b8 20 00 00 00       	mov    $0x20,%eax
f010596f:	e8 90 fe ff ff       	call   f0105804 <lapicw>
}
f0105974:	c9                   	leave  
f0105975:	c3                   	ret    

f0105976 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105976:	55                   	push   %ebp
f0105977:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105979:	83 3d 04 00 32 f0 00 	cmpl   $0x0,0xf0320004
f0105980:	74 0f                	je     f0105991 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0105982:	ba 00 00 00 00       	mov    $0x0,%edx
f0105987:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010598c:	e8 73 fe ff ff       	call   f0105804 <lapicw>
}
f0105991:	c9                   	leave  
f0105992:	c3                   	ret    

f0105993 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105993:	55                   	push   %ebp
f0105994:	89 e5                	mov    %esp,%ebp
f0105996:	56                   	push   %esi
f0105997:	53                   	push   %ebx
f0105998:	8b 75 0c             	mov    0xc(%ebp),%esi
f010599b:	8a 5d 08             	mov    0x8(%ebp),%bl
f010599e:	ba 70 00 00 00       	mov    $0x70,%edx
f01059a3:	b0 0f                	mov    $0xf,%al
f01059a5:	ee                   	out    %al,(%dx)
f01059a6:	b2 71                	mov    $0x71,%dl
f01059a8:	b0 0a                	mov    $0xa,%al
f01059aa:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059ab:	83 3d 08 ef 2d f0 00 	cmpl   $0x0,0xf02def08
f01059b2:	75 19                	jne    f01059cd <lapic_startap+0x3a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059b4:	68 67 04 00 00       	push   $0x467
f01059b9:	68 08 5f 10 f0       	push   $0xf0105f08
f01059be:	68 98 00 00 00       	push   $0x98
f01059c3:	68 18 7f 10 f0       	push   $0xf0107f18
f01059c8:	e8 9b a6 ff ff       	call   f0100068 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01059cd:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01059d4:	00 00 
	wrv[1] = addr >> 4;
f01059d6:	89 f0                	mov    %esi,%eax
f01059d8:	c1 e8 04             	shr    $0x4,%eax
f01059db:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01059e1:	c1 e3 18             	shl    $0x18,%ebx
f01059e4:	89 da                	mov    %ebx,%edx
f01059e6:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01059eb:	e8 14 fe ff ff       	call   f0105804 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01059f0:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01059f5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01059fa:	e8 05 fe ff ff       	call   f0105804 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01059ff:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105a04:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a09:	e8 f6 fd ff ff       	call   f0105804 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105a0e:	c1 ee 0c             	shr    $0xc,%esi
f0105a11:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105a17:	89 da                	mov    %ebx,%edx
f0105a19:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105a1e:	e8 e1 fd ff ff       	call   f0105804 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105a23:	89 f2                	mov    %esi,%edx
f0105a25:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a2a:	e8 d5 fd ff ff       	call   f0105804 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105a2f:	89 da                	mov    %ebx,%edx
f0105a31:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105a36:	e8 c9 fd ff ff       	call   f0105804 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105a3b:	89 f2                	mov    %esi,%edx
f0105a3d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a42:	e8 bd fd ff ff       	call   f0105804 <lapicw>
		microdelay(200);
	}
}
f0105a47:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105a4a:	5b                   	pop    %ebx
f0105a4b:	5e                   	pop    %esi
f0105a4c:	c9                   	leave  
f0105a4d:	c3                   	ret    

f0105a4e <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105a4e:	55                   	push   %ebp
f0105a4f:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105a51:	8b 55 08             	mov    0x8(%ebp),%edx
f0105a54:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105a5a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a5f:	e8 a0 fd ff ff       	call   f0105804 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105a64:	8b 15 04 00 32 f0    	mov    0xf0320004,%edx
f0105a6a:	81 c2 00 03 00 00    	add    $0x300,%edx
f0105a70:	8b 02                	mov    (%edx),%eax
f0105a72:	f6 c4 10             	test   $0x10,%ah
f0105a75:	75 f9                	jne    f0105a70 <lapic_ipi+0x22>
		;
}
f0105a77:	c9                   	leave  
f0105a78:	c3                   	ret    
f0105a79:	00 00                	add    %al,(%eax)
	...

f0105a7c <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0105a7c:	55                   	push   %ebp
f0105a7d:	89 e5                	mov    %esp,%ebp
f0105a7f:	53                   	push   %ebx
f0105a80:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0105a83:	83 38 00             	cmpl   $0x0,(%eax)
f0105a86:	74 25                	je     f0105aad <holding+0x31>
f0105a88:	8b 58 08             	mov    0x8(%eax),%ebx
f0105a8b:	e8 8c fd ff ff       	call   f010581c <cpunum>
f0105a90:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105a97:	29 c2                	sub    %eax,%edx
f0105a99:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105a9c:	8d 04 85 20 f0 2d f0 	lea    -0xfd20fe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0105aa3:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0105aa5:	0f 94 c0             	sete   %al
f0105aa8:	0f b6 c0             	movzbl %al,%eax
f0105aab:	eb 05                	jmp    f0105ab2 <holding+0x36>
f0105aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ab2:	83 c4 04             	add    $0x4,%esp
f0105ab5:	5b                   	pop    %ebx
f0105ab6:	c9                   	leave  
f0105ab7:	c3                   	ret    

f0105ab8 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105ab8:	55                   	push   %ebp
f0105ab9:	89 e5                	mov    %esp,%ebp
f0105abb:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105abe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105ac4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ac7:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105aca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105ad1:	c9                   	leave  
f0105ad2:	c3                   	ret    

f0105ad3 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105ad3:	55                   	push   %ebp
f0105ad4:	89 e5                	mov    %esp,%ebp
f0105ad6:	53                   	push   %ebx
f0105ad7:	83 ec 04             	sub    $0x4,%esp
f0105ada:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105add:	89 d8                	mov    %ebx,%eax
f0105adf:	e8 98 ff ff ff       	call   f0105a7c <holding>
f0105ae4:	85 c0                	test   %eax,%eax
f0105ae6:	75 0d                	jne    f0105af5 <spin_lock+0x22>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105ae8:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105aea:	b0 01                	mov    $0x1,%al
f0105aec:	f0 87 03             	lock xchg %eax,(%ebx)
f0105aef:	85 c0                	test   %eax,%eax
f0105af1:	75 20                	jne    f0105b13 <spin_lock+0x40>
f0105af3:	eb 2e                	jmp    f0105b23 <spin_lock+0x50>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105af5:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105af8:	e8 1f fd ff ff       	call   f010581c <cpunum>
f0105afd:	83 ec 0c             	sub    $0xc,%esp
f0105b00:	53                   	push   %ebx
f0105b01:	50                   	push   %eax
f0105b02:	68 28 7f 10 f0       	push   $0xf0107f28
f0105b07:	6a 41                	push   $0x41
f0105b09:	68 8c 7f 10 f0       	push   $0xf0107f8c
f0105b0e:	e8 55 a5 ff ff       	call   f0100068 <_panic>
f0105b13:	b9 01 00 00 00       	mov    $0x1,%ecx

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105b18:	f3 90                	pause  
f0105b1a:	89 c8                	mov    %ecx,%eax
f0105b1c:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105b1f:	85 c0                	test   %eax,%eax
f0105b21:	75 f5                	jne    f0105b18 <spin_lock+0x45>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105b23:	e8 f4 fc ff ff       	call   f010581c <cpunum>
f0105b28:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105b2f:	29 c2                	sub    %eax,%edx
f0105b31:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105b34:	8d 04 85 20 f0 2d f0 	lea    -0xfd20fe0(,%eax,4),%eax
f0105b3b:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105b3e:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0105b41:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105b43:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0105b48:	77 30                	ja     f0105b7a <spin_lock+0xa7>
f0105b4a:	eb 27                	jmp    f0105b73 <spin_lock+0xa0>
f0105b4c:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105b52:	76 10                	jbe    f0105b64 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105b54:	8b 5a 04             	mov    0x4(%edx),%ebx
f0105b57:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105b5a:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105b5c:	40                   	inc    %eax
f0105b5d:	83 f8 0a             	cmp    $0xa,%eax
f0105b60:	75 ea                	jne    f0105b4c <spin_lock+0x79>
f0105b62:	eb 25                	jmp    f0105b89 <spin_lock+0xb6>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105b64:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105b6b:	40                   	inc    %eax
f0105b6c:	83 f8 09             	cmp    $0x9,%eax
f0105b6f:	7e f3                	jle    f0105b64 <spin_lock+0x91>
f0105b71:	eb 16                	jmp    f0105b89 <spin_lock+0xb6>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105b73:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b78:	eb ea                	jmp    f0105b64 <spin_lock+0x91>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105b7a:	8b 50 04             	mov    0x4(%eax),%edx
f0105b7d:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105b80:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105b82:	b8 01 00 00 00       	mov    $0x1,%eax
f0105b87:	eb c3                	jmp    f0105b4c <spin_lock+0x79>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105b89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105b8c:	c9                   	leave  
f0105b8d:	c3                   	ret    

f0105b8e <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105b8e:	55                   	push   %ebp
f0105b8f:	89 e5                	mov    %esp,%ebp
f0105b91:	57                   	push   %edi
f0105b92:	56                   	push   %esi
f0105b93:	53                   	push   %ebx
f0105b94:	83 ec 4c             	sub    $0x4c,%esp
f0105b97:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105b9a:	89 d8                	mov    %ebx,%eax
f0105b9c:	e8 db fe ff ff       	call   f0105a7c <holding>
f0105ba1:	85 c0                	test   %eax,%eax
f0105ba3:	0f 85 ac 00 00 00    	jne    f0105c55 <spin_unlock+0xc7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105ba9:	83 ec 04             	sub    $0x4,%esp
f0105bac:	6a 28                	push   $0x28
f0105bae:	8d 43 0c             	lea    0xc(%ebx),%eax
f0105bb1:	50                   	push   %eax
f0105bb2:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0105bb5:	50                   	push   %eax
f0105bb6:	e8 7c f6 ff ff       	call   f0105237 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105bbb:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105bbe:	0f b6 30             	movzbl (%eax),%esi
f0105bc1:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105bc4:	e8 53 fc ff ff       	call   f010581c <cpunum>
f0105bc9:	56                   	push   %esi
f0105bca:	53                   	push   %ebx
f0105bcb:	50                   	push   %eax
f0105bcc:	68 54 7f 10 f0       	push   $0xf0107f54
f0105bd1:	e8 a3 e0 ff ff       	call   f0103c79 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105bd6:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0105bd9:	83 c4 20             	add    $0x20,%esp
f0105bdc:	85 c0                	test   %eax,%eax
f0105bde:	74 61                	je     f0105c41 <spin_unlock+0xb3>
f0105be0:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0105be3:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105be6:	8d 75 d0             	lea    -0x30(%ebp),%esi
f0105be9:	83 ec 08             	sub    $0x8,%esp
f0105bec:	56                   	push   %esi
f0105bed:	50                   	push   %eax
f0105bee:	e8 52 eb ff ff       	call   f0104745 <debuginfo_eip>
f0105bf3:	83 c4 10             	add    $0x10,%esp
f0105bf6:	85 c0                	test   %eax,%eax
f0105bf8:	78 27                	js     f0105c21 <spin_unlock+0x93>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105bfa:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105bfc:	83 ec 04             	sub    $0x4,%esp
f0105bff:	89 c2                	mov    %eax,%edx
f0105c01:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0105c04:	52                   	push   %edx
f0105c05:	ff 75 d8             	pushl  -0x28(%ebp)
f0105c08:	ff 75 dc             	pushl  -0x24(%ebp)
f0105c0b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0105c0e:	ff 75 d0             	pushl  -0x30(%ebp)
f0105c11:	50                   	push   %eax
f0105c12:	68 9c 7f 10 f0       	push   $0xf0107f9c
f0105c17:	e8 5d e0 ff ff       	call   f0103c79 <cprintf>
f0105c1c:	83 c4 20             	add    $0x20,%esp
f0105c1f:	eb 12                	jmp    f0105c33 <spin_unlock+0xa5>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105c21:	83 ec 08             	sub    $0x8,%esp
f0105c24:	ff 33                	pushl  (%ebx)
f0105c26:	68 b3 7f 10 f0       	push   $0xf0107fb3
f0105c2b:	e8 49 e0 ff ff       	call   f0103c79 <cprintf>
f0105c30:	83 c4 10             	add    $0x10,%esp
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105c33:	39 fb                	cmp    %edi,%ebx
f0105c35:	74 0a                	je     f0105c41 <spin_unlock+0xb3>
f0105c37:	8b 43 04             	mov    0x4(%ebx),%eax
f0105c3a:	83 c3 04             	add    $0x4,%ebx
f0105c3d:	85 c0                	test   %eax,%eax
f0105c3f:	75 a8                	jne    f0105be9 <spin_unlock+0x5b>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105c41:	83 ec 04             	sub    $0x4,%esp
f0105c44:	68 bb 7f 10 f0       	push   $0xf0107fbb
f0105c49:	6a 67                	push   $0x67
f0105c4b:	68 8c 7f 10 f0       	push   $0xf0107f8c
f0105c50:	e8 13 a4 ff ff       	call   f0100068 <_panic>
	}

	lk->pcs[0] = 0;
f0105c55:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0105c5c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105c63:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c68:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0105c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105c6e:	5b                   	pop    %ebx
f0105c6f:	5e                   	pop    %esi
f0105c70:	5f                   	pop    %edi
f0105c71:	c9                   	leave  
f0105c72:	c3                   	ret    
	...

f0105c74 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0105c74:	55                   	push   %ebp
f0105c75:	89 e5                	mov    %esp,%ebp
f0105c77:	57                   	push   %edi
f0105c78:	56                   	push   %esi
f0105c79:	83 ec 10             	sub    $0x10,%esp
f0105c7c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105c7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0105c82:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0105c85:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0105c88:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0105c8b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0105c8e:	85 c0                	test   %eax,%eax
f0105c90:	75 2e                	jne    f0105cc0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0105c92:	39 f1                	cmp    %esi,%ecx
f0105c94:	77 5a                	ja     f0105cf0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0105c96:	85 c9                	test   %ecx,%ecx
f0105c98:	75 0b                	jne    f0105ca5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0105c9a:	b8 01 00 00 00       	mov    $0x1,%eax
f0105c9f:	31 d2                	xor    %edx,%edx
f0105ca1:	f7 f1                	div    %ecx
f0105ca3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0105ca5:	31 d2                	xor    %edx,%edx
f0105ca7:	89 f0                	mov    %esi,%eax
f0105ca9:	f7 f1                	div    %ecx
f0105cab:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0105cad:	89 f8                	mov    %edi,%eax
f0105caf:	f7 f1                	div    %ecx
f0105cb1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0105cb3:	89 f8                	mov    %edi,%eax
f0105cb5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0105cb7:	83 c4 10             	add    $0x10,%esp
f0105cba:	5e                   	pop    %esi
f0105cbb:	5f                   	pop    %edi
f0105cbc:	c9                   	leave  
f0105cbd:	c3                   	ret    
f0105cbe:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0105cc0:	39 f0                	cmp    %esi,%eax
f0105cc2:	77 1c                	ja     f0105ce0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0105cc4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f0105cc7:	83 f7 1f             	xor    $0x1f,%edi
f0105cca:	75 3c                	jne    f0105d08 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0105ccc:	39 f0                	cmp    %esi,%eax
f0105cce:	0f 82 90 00 00 00    	jb     f0105d64 <__udivdi3+0xf0>
f0105cd4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0105cd7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0105cda:	0f 86 84 00 00 00    	jbe    f0105d64 <__udivdi3+0xf0>
f0105ce0:	31 f6                	xor    %esi,%esi
f0105ce2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0105ce4:	89 f8                	mov    %edi,%eax
f0105ce6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0105ce8:	83 c4 10             	add    $0x10,%esp
f0105ceb:	5e                   	pop    %esi
f0105cec:	5f                   	pop    %edi
f0105ced:	c9                   	leave  
f0105cee:	c3                   	ret    
f0105cef:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0105cf0:	89 f2                	mov    %esi,%edx
f0105cf2:	89 f8                	mov    %edi,%eax
f0105cf4:	f7 f1                	div    %ecx
f0105cf6:	89 c7                	mov    %eax,%edi
f0105cf8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0105cfa:	89 f8                	mov    %edi,%eax
f0105cfc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0105cfe:	83 c4 10             	add    $0x10,%esp
f0105d01:	5e                   	pop    %esi
f0105d02:	5f                   	pop    %edi
f0105d03:	c9                   	leave  
f0105d04:	c3                   	ret    
f0105d05:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0105d08:	89 f9                	mov    %edi,%ecx
f0105d0a:	d3 e0                	shl    %cl,%eax
f0105d0c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0105d0f:	b8 20 00 00 00       	mov    $0x20,%eax
f0105d14:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0105d16:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0105d19:	88 c1                	mov    %al,%cl
f0105d1b:	d3 ea                	shr    %cl,%edx
f0105d1d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0105d20:	09 ca                	or     %ecx,%edx
f0105d22:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0105d25:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0105d28:	89 f9                	mov    %edi,%ecx
f0105d2a:	d3 e2                	shl    %cl,%edx
f0105d2c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0105d2f:	89 f2                	mov    %esi,%edx
f0105d31:	88 c1                	mov    %al,%cl
f0105d33:	d3 ea                	shr    %cl,%edx
f0105d35:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0105d38:	89 f2                	mov    %esi,%edx
f0105d3a:	89 f9                	mov    %edi,%ecx
f0105d3c:	d3 e2                	shl    %cl,%edx
f0105d3e:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0105d41:	88 c1                	mov    %al,%cl
f0105d43:	d3 ee                	shr    %cl,%esi
f0105d45:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0105d47:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0105d4a:	89 f0                	mov    %esi,%eax
f0105d4c:	89 ca                	mov    %ecx,%edx
f0105d4e:	f7 75 ec             	divl   -0x14(%ebp)
f0105d51:	89 d1                	mov    %edx,%ecx
f0105d53:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0105d55:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0105d58:	39 d1                	cmp    %edx,%ecx
f0105d5a:	72 28                	jb     f0105d84 <__udivdi3+0x110>
f0105d5c:	74 1a                	je     f0105d78 <__udivdi3+0x104>
f0105d5e:	89 f7                	mov    %esi,%edi
f0105d60:	31 f6                	xor    %esi,%esi
f0105d62:	eb 80                	jmp    f0105ce4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0105d64:	31 f6                	xor    %esi,%esi
f0105d66:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0105d6b:	89 f8                	mov    %edi,%eax
f0105d6d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0105d6f:	83 c4 10             	add    $0x10,%esp
f0105d72:	5e                   	pop    %esi
f0105d73:	5f                   	pop    %edi
f0105d74:	c9                   	leave  
f0105d75:	c3                   	ret    
f0105d76:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0105d78:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0105d7b:	89 f9                	mov    %edi,%ecx
f0105d7d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0105d7f:	39 c2                	cmp    %eax,%edx
f0105d81:	73 db                	jae    f0105d5e <__udivdi3+0xea>
f0105d83:	90                   	nop
		{
		  q0--;
f0105d84:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0105d87:	31 f6                	xor    %esi,%esi
f0105d89:	e9 56 ff ff ff       	jmp    f0105ce4 <__udivdi3+0x70>
	...

f0105d90 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0105d90:	55                   	push   %ebp
f0105d91:	89 e5                	mov    %esp,%ebp
f0105d93:	57                   	push   %edi
f0105d94:	56                   	push   %esi
f0105d95:	83 ec 20             	sub    $0x20,%esp
f0105d98:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0105d9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0105da1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0105da4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0105da7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0105daa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0105dad:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0105daf:	85 ff                	test   %edi,%edi
f0105db1:	75 15                	jne    f0105dc8 <__umoddi3+0x38>
    {
      if (d0 > n1)
f0105db3:	39 f1                	cmp    %esi,%ecx
f0105db5:	0f 86 99 00 00 00    	jbe    f0105e54 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0105dbb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0105dbd:	89 d0                	mov    %edx,%eax
f0105dbf:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0105dc1:	83 c4 20             	add    $0x20,%esp
f0105dc4:	5e                   	pop    %esi
f0105dc5:	5f                   	pop    %edi
f0105dc6:	c9                   	leave  
f0105dc7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0105dc8:	39 f7                	cmp    %esi,%edi
f0105dca:	0f 87 a4 00 00 00    	ja     f0105e74 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0105dd0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0105dd3:	83 f0 1f             	xor    $0x1f,%eax
f0105dd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105dd9:	0f 84 a1 00 00 00    	je     f0105e80 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0105ddf:	89 f8                	mov    %edi,%eax
f0105de1:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0105de4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0105de6:	bf 20 00 00 00       	mov    $0x20,%edi
f0105deb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0105dee:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0105df1:	89 f9                	mov    %edi,%ecx
f0105df3:	d3 ea                	shr    %cl,%edx
f0105df5:	09 c2                	or     %eax,%edx
f0105df7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0105dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105dfd:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0105e00:	d3 e0                	shl    %cl,%eax
f0105e02:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0105e05:	89 f2                	mov    %esi,%edx
f0105e07:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0105e09:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105e0c:	d3 e0                	shl    %cl,%eax
f0105e0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0105e11:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105e14:	89 f9                	mov    %edi,%ecx
f0105e16:	d3 e8                	shr    %cl,%eax
f0105e18:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0105e1a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0105e1c:	89 f2                	mov    %esi,%edx
f0105e1e:	f7 75 f0             	divl   -0x10(%ebp)
f0105e21:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0105e23:	f7 65 f4             	mull   -0xc(%ebp)
f0105e26:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0105e29:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0105e2b:	39 d6                	cmp    %edx,%esi
f0105e2d:	72 71                	jb     f0105ea0 <__umoddi3+0x110>
f0105e2f:	74 7f                	je     f0105eb0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0105e31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e34:	29 c8                	sub    %ecx,%eax
f0105e36:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0105e38:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0105e3b:	d3 e8                	shr    %cl,%eax
f0105e3d:	89 f2                	mov    %esi,%edx
f0105e3f:	89 f9                	mov    %edi,%ecx
f0105e41:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0105e43:	09 d0                	or     %edx,%eax
f0105e45:	89 f2                	mov    %esi,%edx
f0105e47:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0105e4a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0105e4c:	83 c4 20             	add    $0x20,%esp
f0105e4f:	5e                   	pop    %esi
f0105e50:	5f                   	pop    %edi
f0105e51:	c9                   	leave  
f0105e52:	c3                   	ret    
f0105e53:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0105e54:	85 c9                	test   %ecx,%ecx
f0105e56:	75 0b                	jne    f0105e63 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0105e58:	b8 01 00 00 00       	mov    $0x1,%eax
f0105e5d:	31 d2                	xor    %edx,%edx
f0105e5f:	f7 f1                	div    %ecx
f0105e61:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0105e63:	89 f0                	mov    %esi,%eax
f0105e65:	31 d2                	xor    %edx,%edx
f0105e67:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0105e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105e6c:	f7 f1                	div    %ecx
f0105e6e:	e9 4a ff ff ff       	jmp    f0105dbd <__umoddi3+0x2d>
f0105e73:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0105e74:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0105e76:	83 c4 20             	add    $0x20,%esp
f0105e79:	5e                   	pop    %esi
f0105e7a:	5f                   	pop    %edi
f0105e7b:	c9                   	leave  
f0105e7c:	c3                   	ret    
f0105e7d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0105e80:	39 f7                	cmp    %esi,%edi
f0105e82:	72 05                	jb     f0105e89 <__umoddi3+0xf9>
f0105e84:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0105e87:	77 0c                	ja     f0105e95 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0105e89:	89 f2                	mov    %esi,%edx
f0105e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105e8e:	29 c8                	sub    %ecx,%eax
f0105e90:	19 fa                	sbb    %edi,%edx
f0105e92:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0105e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0105e98:	83 c4 20             	add    $0x20,%esp
f0105e9b:	5e                   	pop    %esi
f0105e9c:	5f                   	pop    %edi
f0105e9d:	c9                   	leave  
f0105e9e:	c3                   	ret    
f0105e9f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0105ea0:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105ea3:	89 c1                	mov    %eax,%ecx
f0105ea5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0105ea8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0105eab:	eb 84                	jmp    f0105e31 <__umoddi3+0xa1>
f0105ead:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0105eb0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0105eb3:	72 eb                	jb     f0105ea0 <__umoddi3+0x110>
f0105eb5:	89 f2                	mov    %esi,%edx
f0105eb7:	e9 75 ff ff ff       	jmp    f0105e31 <__umoddi3+0xa1>
