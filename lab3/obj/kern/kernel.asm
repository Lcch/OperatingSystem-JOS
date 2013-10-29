
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
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
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
f0100034:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 2a 00 00 00       	call   f0100068 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <msrs_init>:
#include <kern/kclock.h>
#include <kern/env.h>
#include <kern/trap.h>

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
f010005d:	b8 a8 33 12 f0       	mov    $0xf01233a8,%eax
f0100062:	b1 76                	mov    $0x76,%cl
f0100064:	0f 30                	wrmsr  
}
f0100066:	c9                   	leave  
f0100067:	c3                   	ret    

f0100068 <i386_init>:

void
i386_init(void)
{
f0100068:	55                   	push   %ebp
f0100069:	89 e5                	mov    %esp,%ebp
f010006b:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010006e:	b8 50 11 1e f0       	mov    $0xf01e1150,%eax
f0100073:	2d 24 02 1e f0       	sub    $0xf01e0224,%eax
f0100078:	50                   	push   %eax
f0100079:	6a 00                	push   $0x0
f010007b:	68 24 02 1e f0       	push   $0xf01e0224
f0100080:	e8 f4 46 00 00       	call   f0104779 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100085:	e8 85 04 00 00       	call   f010050f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010008a:	83 c4 08             	add    $0x8,%esp
f010008d:	68 ac 1a 00 00       	push   $0x1aac
f0100092:	68 e0 4b 10 f0       	push   $0xf0104be0
f0100097:	e8 b5 34 00 00       	call   f0103551 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f010009c:	e8 30 16 00 00       	call   f01016d1 <mem_init>

	// MSRs init:
	msrs_init();
f01000a1:	e8 9a ff ff ff       	call   f0100040 <msrs_init>

    // cprintf("mem_init done! \n");
	// Lab 3 user environment initialization functions
	env_init();
f01000a6:	e8 90 2e 00 00       	call   f0102f3b <env_init>
    // cprintf("env_init done! \n");
	trap_init();
f01000ab:	e8 15 35 00 00       	call   f01035c5 <trap_init>
    // cprintf("trap_init done! \n");

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01000b0:	83 c4 0c             	add    $0xc,%esp
f01000b3:	6a 00                	push   $0x0
f01000b5:	68 73 e8 00 00       	push   $0xe873
f01000ba:	68 c8 33 12 f0       	push   $0xf01233c8
f01000bf:	e8 85 30 00 00       	call   f0103149 <env_create>
	// Touch all you want.
	ENV_CREATE(user_breakpoint, ENV_TYPE_USER);
#endif // TEST*
    
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000c4:	83 c4 04             	add    $0x4,%esp
f01000c7:	ff 35 7c 04 1e f0    	pushl  0xf01e047c
f01000cd:	e8 ba 33 00 00       	call   f010348c <env_run>

f01000d2 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000d2:	55                   	push   %ebp
f01000d3:	89 e5                	mov    %esp,%ebp
f01000d5:	56                   	push   %esi
f01000d6:	53                   	push   %ebx
f01000d7:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000da:	83 3d 40 11 1e f0 00 	cmpl   $0x0,0xf01e1140
f01000e1:	75 37                	jne    f010011a <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000e3:	89 35 40 11 1e f0    	mov    %esi,0xf01e1140

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000e9:	fa                   	cli    
f01000ea:	fc                   	cld    

	va_start(ap, fmt);
f01000eb:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000ee:	83 ec 04             	sub    $0x4,%esp
f01000f1:	ff 75 0c             	pushl  0xc(%ebp)
f01000f4:	ff 75 08             	pushl  0x8(%ebp)
f01000f7:	68 fb 4b 10 f0       	push   $0xf0104bfb
f01000fc:	e8 50 34 00 00       	call   f0103551 <cprintf>
	vcprintf(fmt, ap);
f0100101:	83 c4 08             	add    $0x8,%esp
f0100104:	53                   	push   %ebx
f0100105:	56                   	push   %esi
f0100106:	e8 20 34 00 00       	call   f010352b <vcprintf>
	cprintf("\n");
f010010b:	c7 04 24 cf 4e 10 f0 	movl   $0xf0104ecf,(%esp)
f0100112:	e8 3a 34 00 00       	call   f0103551 <cprintf>
	va_end(ap);
f0100117:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010011a:	83 ec 0c             	sub    $0xc,%esp
f010011d:	6a 00                	push   $0x0
f010011f:	e8 70 0d 00 00       	call   f0100e94 <monitor>
f0100124:	83 c4 10             	add    $0x10,%esp
f0100127:	eb f1                	jmp    f010011a <_panic+0x48>

f0100129 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100129:	55                   	push   %ebp
f010012a:	89 e5                	mov    %esp,%ebp
f010012c:	53                   	push   %ebx
f010012d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100130:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100133:	ff 75 0c             	pushl  0xc(%ebp)
f0100136:	ff 75 08             	pushl  0x8(%ebp)
f0100139:	68 13 4c 10 f0       	push   $0xf0104c13
f010013e:	e8 0e 34 00 00       	call   f0103551 <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	53                   	push   %ebx
f0100147:	ff 75 10             	pushl  0x10(%ebp)
f010014a:	e8 dc 33 00 00       	call   f010352b <vcprintf>
	cprintf("\n");
f010014f:	c7 04 24 cf 4e 10 f0 	movl   $0xf0104ecf,(%esp)
f0100156:	e8 f6 33 00 00       	call   f0103551 <cprintf>
	va_end(ap);
f010015b:	83 c4 10             	add    $0x10,%esp
}
f010015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100161:	c9                   	leave  
f0100162:	c3                   	ret    
	...

f0100164 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100164:	55                   	push   %ebp
f0100165:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100167:	ba 84 00 00 00       	mov    $0x84,%edx
f010016c:	ec                   	in     (%dx),%al
f010016d:	ec                   	in     (%dx),%al
f010016e:	ec                   	in     (%dx),%al
f010016f:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100170:	c9                   	leave  
f0100171:	c3                   	ret    

f0100172 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100172:	55                   	push   %ebp
f0100173:	89 e5                	mov    %esp,%ebp
f0100175:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017a:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010017b:	a8 01                	test   $0x1,%al
f010017d:	74 08                	je     f0100187 <serial_proc_data+0x15>
f010017f:	b2 f8                	mov    $0xf8,%dl
f0100181:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100182:	0f b6 c0             	movzbl %al,%eax
f0100185:	eb 05                	jmp    f010018c <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100187:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010018c:	c9                   	leave  
f010018d:	c3                   	ret    

f010018e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010018e:	55                   	push   %ebp
f010018f:	89 e5                	mov    %esp,%ebp
f0100191:	53                   	push   %ebx
f0100192:	83 ec 04             	sub    $0x4,%esp
f0100195:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100197:	eb 29                	jmp    f01001c2 <cons_intr+0x34>
		if (c == 0)
f0100199:	85 c0                	test   %eax,%eax
f010019b:	74 25                	je     f01001c2 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f010019d:	8b 15 64 04 1e f0    	mov    0xf01e0464,%edx
f01001a3:	88 82 60 02 1e f0    	mov    %al,-0xfe1fda0(%edx)
f01001a9:	8d 42 01             	lea    0x1(%edx),%eax
f01001ac:	a3 64 04 1e f0       	mov    %eax,0xf01e0464
		if (cons.wpos == CONSBUFSIZE)
f01001b1:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001b6:	75 0a                	jne    f01001c2 <cons_intr+0x34>
			cons.wpos = 0;
f01001b8:	c7 05 64 04 1e f0 00 	movl   $0x0,0xf01e0464
f01001bf:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001c2:	ff d3                	call   *%ebx
f01001c4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001c7:	75 d0                	jne    f0100199 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001c9:	83 c4 04             	add    $0x4,%esp
f01001cc:	5b                   	pop    %ebx
f01001cd:	c9                   	leave  
f01001ce:	c3                   	ret    

f01001cf <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001cf:	55                   	push   %ebp
f01001d0:	89 e5                	mov    %esp,%ebp
f01001d2:	57                   	push   %edi
f01001d3:	56                   	push   %esi
f01001d4:	53                   	push   %ebx
f01001d5:	83 ec 0c             	sub    $0xc,%esp
f01001d8:	89 c6                	mov    %eax,%esi
f01001da:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001df:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001e0:	a8 20                	test   $0x20,%al
f01001e2:	75 19                	jne    f01001fd <cons_putc+0x2e>
f01001e4:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01001e9:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001ee:	e8 71 ff ff ff       	call   f0100164 <delay>
f01001f3:	89 fa                	mov    %edi,%edx
f01001f5:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001f6:	a8 20                	test   $0x20,%al
f01001f8:	75 03                	jne    f01001fd <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001fa:	4b                   	dec    %ebx
f01001fb:	75 f1                	jne    f01001ee <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01001fd:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001ff:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100204:	89 f0                	mov    %esi,%eax
f0100206:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100207:	b2 79                	mov    $0x79,%dl
f0100209:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010020a:	84 c0                	test   %al,%al
f010020c:	78 1d                	js     f010022b <cons_putc+0x5c>
f010020e:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f0100213:	e8 4c ff ff ff       	call   f0100164 <delay>
f0100218:	ba 79 03 00 00       	mov    $0x379,%edx
f010021d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010021e:	84 c0                	test   %al,%al
f0100220:	78 09                	js     f010022b <cons_putc+0x5c>
f0100222:	43                   	inc    %ebx
f0100223:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100229:	75 e8                	jne    f0100213 <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010022b:	ba 78 03 00 00       	mov    $0x378,%edx
f0100230:	89 f8                	mov    %edi,%eax
f0100232:	ee                   	out    %al,(%dx)
f0100233:	b2 7a                	mov    $0x7a,%dl
f0100235:	b0 0d                	mov    $0xd,%al
f0100237:	ee                   	out    %al,(%dx)
f0100238:	b0 08                	mov    $0x8,%al
f010023a:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
    // set user_setcolor
    c |= (user_setcolor << 8);
f010023b:	a1 40 02 1e f0       	mov    0xf01e0240,%eax
f0100240:	c1 e0 08             	shl    $0x8,%eax
f0100243:	09 c6                	or     %eax,%esi

	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100245:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f010024b:	75 06                	jne    f0100253 <cons_putc+0x84>
		c |= 0x0700;
f010024d:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f0100253:	89 f0                	mov    %esi,%eax
f0100255:	25 ff 00 00 00       	and    $0xff,%eax
f010025a:	83 f8 09             	cmp    $0x9,%eax
f010025d:	74 78                	je     f01002d7 <cons_putc+0x108>
f010025f:	83 f8 09             	cmp    $0x9,%eax
f0100262:	7f 0b                	jg     f010026f <cons_putc+0xa0>
f0100264:	83 f8 08             	cmp    $0x8,%eax
f0100267:	0f 85 9e 00 00 00    	jne    f010030b <cons_putc+0x13c>
f010026d:	eb 10                	jmp    f010027f <cons_putc+0xb0>
f010026f:	83 f8 0a             	cmp    $0xa,%eax
f0100272:	74 39                	je     f01002ad <cons_putc+0xde>
f0100274:	83 f8 0d             	cmp    $0xd,%eax
f0100277:	0f 85 8e 00 00 00    	jne    f010030b <cons_putc+0x13c>
f010027d:	eb 36                	jmp    f01002b5 <cons_putc+0xe6>
	case '\b':
		if (crt_pos > 0) {
f010027f:	66 a1 44 02 1e f0    	mov    0xf01e0244,%ax
f0100285:	66 85 c0             	test   %ax,%ax
f0100288:	0f 84 e0 00 00 00    	je     f010036e <cons_putc+0x19f>
			crt_pos--;
f010028e:	48                   	dec    %eax
f010028f:	66 a3 44 02 1e f0    	mov    %ax,0xf01e0244
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100295:	0f b7 c0             	movzwl %ax,%eax
f0100298:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f010029e:	83 ce 20             	or     $0x20,%esi
f01002a1:	8b 15 48 02 1e f0    	mov    0xf01e0248,%edx
f01002a7:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01002ab:	eb 78                	jmp    f0100325 <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002ad:	66 83 05 44 02 1e f0 	addw   $0x50,0xf01e0244
f01002b4:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002b5:	66 8b 0d 44 02 1e f0 	mov    0xf01e0244,%cx
f01002bc:	bb 50 00 00 00       	mov    $0x50,%ebx
f01002c1:	89 c8                	mov    %ecx,%eax
f01002c3:	ba 00 00 00 00       	mov    $0x0,%edx
f01002c8:	66 f7 f3             	div    %bx
f01002cb:	66 29 d1             	sub    %dx,%cx
f01002ce:	66 89 0d 44 02 1e f0 	mov    %cx,0xf01e0244
f01002d5:	eb 4e                	jmp    f0100325 <cons_putc+0x156>
		break;
	case '\t':
		cons_putc(' ');
f01002d7:	b8 20 00 00 00       	mov    $0x20,%eax
f01002dc:	e8 ee fe ff ff       	call   f01001cf <cons_putc>
		cons_putc(' ');
f01002e1:	b8 20 00 00 00       	mov    $0x20,%eax
f01002e6:	e8 e4 fe ff ff       	call   f01001cf <cons_putc>
		cons_putc(' ');
f01002eb:	b8 20 00 00 00       	mov    $0x20,%eax
f01002f0:	e8 da fe ff ff       	call   f01001cf <cons_putc>
		cons_putc(' ');
f01002f5:	b8 20 00 00 00       	mov    $0x20,%eax
f01002fa:	e8 d0 fe ff ff       	call   f01001cf <cons_putc>
		cons_putc(' ');
f01002ff:	b8 20 00 00 00       	mov    $0x20,%eax
f0100304:	e8 c6 fe ff ff       	call   f01001cf <cons_putc>
f0100309:	eb 1a                	jmp    f0100325 <cons_putc+0x156>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010030b:	66 a1 44 02 1e f0    	mov    0xf01e0244,%ax
f0100311:	0f b7 c8             	movzwl %ax,%ecx
f0100314:	8b 15 48 02 1e f0    	mov    0xf01e0248,%edx
f010031a:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f010031e:	40                   	inc    %eax
f010031f:	66 a3 44 02 1e f0    	mov    %ax,0xf01e0244
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f0100325:	66 81 3d 44 02 1e f0 	cmpw   $0x7cf,0xf01e0244
f010032c:	cf 07 
f010032e:	76 3e                	jbe    f010036e <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100330:	a1 48 02 1e f0       	mov    0xf01e0248,%eax
f0100335:	83 ec 04             	sub    $0x4,%esp
f0100338:	68 00 0f 00 00       	push   $0xf00
f010033d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100343:	52                   	push   %edx
f0100344:	50                   	push   %eax
f0100345:	e8 79 44 00 00       	call   f01047c3 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010034a:	8b 15 48 02 1e f0    	mov    0xf01e0248,%edx
f0100350:	83 c4 10             	add    $0x10,%esp
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100353:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100358:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010035e:	40                   	inc    %eax
f010035f:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100364:	75 f2                	jne    f0100358 <cons_putc+0x189>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100366:	66 83 2d 44 02 1e f0 	subw   $0x50,0xf01e0244
f010036d:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010036e:	8b 0d 4c 02 1e f0    	mov    0xf01e024c,%ecx
f0100374:	b0 0e                	mov    $0xe,%al
f0100376:	89 ca                	mov    %ecx,%edx
f0100378:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100379:	66 8b 35 44 02 1e f0 	mov    0xf01e0244,%si
f0100380:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100383:	89 f0                	mov    %esi,%eax
f0100385:	66 c1 e8 08          	shr    $0x8,%ax
f0100389:	89 da                	mov    %ebx,%edx
f010038b:	ee                   	out    %al,(%dx)
f010038c:	b0 0f                	mov    $0xf,%al
f010038e:	89 ca                	mov    %ecx,%edx
f0100390:	ee                   	out    %al,(%dx)
f0100391:	89 f0                	mov    %esi,%eax
f0100393:	89 da                	mov    %ebx,%edx
f0100395:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100396:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100399:	5b                   	pop    %ebx
f010039a:	5e                   	pop    %esi
f010039b:	5f                   	pop    %edi
f010039c:	c9                   	leave  
f010039d:	c3                   	ret    

f010039e <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010039e:	55                   	push   %ebp
f010039f:	89 e5                	mov    %esp,%ebp
f01003a1:	53                   	push   %ebx
f01003a2:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a5:	ba 64 00 00 00       	mov    $0x64,%edx
f01003aa:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003ab:	a8 01                	test   $0x1,%al
f01003ad:	0f 84 dc 00 00 00    	je     f010048f <kbd_proc_data+0xf1>
f01003b3:	b2 60                	mov    $0x60,%dl
f01003b5:	ec                   	in     (%dx),%al
f01003b6:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003b8:	3c e0                	cmp    $0xe0,%al
f01003ba:	75 11                	jne    f01003cd <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01003bc:	83 0d 68 04 1e f0 40 	orl    $0x40,0xf01e0468
		return 0;
f01003c3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003c8:	e9 c7 00 00 00       	jmp    f0100494 <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f01003cd:	84 c0                	test   %al,%al
f01003cf:	79 33                	jns    f0100404 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003d1:	8b 0d 68 04 1e f0    	mov    0xf01e0468,%ecx
f01003d7:	f6 c1 40             	test   $0x40,%cl
f01003da:	75 05                	jne    f01003e1 <kbd_proc_data+0x43>
f01003dc:	88 c2                	mov    %al,%dl
f01003de:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003e1:	0f b6 d2             	movzbl %dl,%edx
f01003e4:	8a 82 60 4c 10 f0    	mov    -0xfefb3a0(%edx),%al
f01003ea:	83 c8 40             	or     $0x40,%eax
f01003ed:	0f b6 c0             	movzbl %al,%eax
f01003f0:	f7 d0                	not    %eax
f01003f2:	21 c1                	and    %eax,%ecx
f01003f4:	89 0d 68 04 1e f0    	mov    %ecx,0xf01e0468
		return 0;
f01003fa:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003ff:	e9 90 00 00 00       	jmp    f0100494 <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f0100404:	8b 0d 68 04 1e f0    	mov    0xf01e0468,%ecx
f010040a:	f6 c1 40             	test   $0x40,%cl
f010040d:	74 0e                	je     f010041d <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010040f:	88 c2                	mov    %al,%dl
f0100411:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100414:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100417:	89 0d 68 04 1e f0    	mov    %ecx,0xf01e0468
	}

	shift |= shiftcode[data];
f010041d:	0f b6 d2             	movzbl %dl,%edx
f0100420:	0f b6 82 60 4c 10 f0 	movzbl -0xfefb3a0(%edx),%eax
f0100427:	0b 05 68 04 1e f0    	or     0xf01e0468,%eax
	shift ^= togglecode[data];
f010042d:	0f b6 8a 60 4d 10 f0 	movzbl -0xfefb2a0(%edx),%ecx
f0100434:	31 c8                	xor    %ecx,%eax
f0100436:	a3 68 04 1e f0       	mov    %eax,0xf01e0468

	c = charcode[shift & (CTL | SHIFT)][data];
f010043b:	89 c1                	mov    %eax,%ecx
f010043d:	83 e1 03             	and    $0x3,%ecx
f0100440:	8b 0c 8d 60 4e 10 f0 	mov    -0xfefb1a0(,%ecx,4),%ecx
f0100447:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f010044b:	a8 08                	test   $0x8,%al
f010044d:	74 18                	je     f0100467 <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f010044f:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100452:	83 fa 19             	cmp    $0x19,%edx
f0100455:	77 05                	ja     f010045c <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f0100457:	83 eb 20             	sub    $0x20,%ebx
f010045a:	eb 0b                	jmp    f0100467 <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f010045c:	8d 53 bf             	lea    -0x41(%ebx),%edx
f010045f:	83 fa 19             	cmp    $0x19,%edx
f0100462:	77 03                	ja     f0100467 <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f0100464:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100467:	f7 d0                	not    %eax
f0100469:	a8 06                	test   $0x6,%al
f010046b:	75 27                	jne    f0100494 <kbd_proc_data+0xf6>
f010046d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100473:	75 1f                	jne    f0100494 <kbd_proc_data+0xf6>
		cprintf("Rebooting!\n");
f0100475:	83 ec 0c             	sub    $0xc,%esp
f0100478:	68 2d 4c 10 f0       	push   $0xf0104c2d
f010047d:	e8 cf 30 00 00       	call   f0103551 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100482:	ba 92 00 00 00       	mov    $0x92,%edx
f0100487:	b0 03                	mov    $0x3,%al
f0100489:	ee                   	out    %al,(%dx)
f010048a:	83 c4 10             	add    $0x10,%esp
f010048d:	eb 05                	jmp    f0100494 <kbd_proc_data+0xf6>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010048f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100494:	89 d8                	mov    %ebx,%eax
f0100496:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100499:	c9                   	leave  
f010049a:	c3                   	ret    

f010049b <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010049b:	55                   	push   %ebp
f010049c:	89 e5                	mov    %esp,%ebp
f010049e:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004a1:	80 3d 50 02 1e f0 00 	cmpb   $0x0,0xf01e0250
f01004a8:	74 0a                	je     f01004b4 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004aa:	b8 72 01 10 f0       	mov    $0xf0100172,%eax
f01004af:	e8 da fc ff ff       	call   f010018e <cons_intr>
}
f01004b4:	c9                   	leave  
f01004b5:	c3                   	ret    

f01004b6 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004b6:	55                   	push   %ebp
f01004b7:	89 e5                	mov    %esp,%ebp
f01004b9:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004bc:	b8 9e 03 10 f0       	mov    $0xf010039e,%eax
f01004c1:	e8 c8 fc ff ff       	call   f010018e <cons_intr>
}
f01004c6:	c9                   	leave  
f01004c7:	c3                   	ret    

f01004c8 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004c8:	55                   	push   %ebp
f01004c9:	89 e5                	mov    %esp,%ebp
f01004cb:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004ce:	e8 c8 ff ff ff       	call   f010049b <serial_intr>
	kbd_intr();
f01004d3:	e8 de ff ff ff       	call   f01004b6 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004d8:	8b 15 60 04 1e f0    	mov    0xf01e0460,%edx
f01004de:	3b 15 64 04 1e f0    	cmp    0xf01e0464,%edx
f01004e4:	74 22                	je     f0100508 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01004e6:	0f b6 82 60 02 1e f0 	movzbl -0xfe1fda0(%edx),%eax
f01004ed:	42                   	inc    %edx
f01004ee:	89 15 60 04 1e f0    	mov    %edx,0xf01e0460
		if (cons.rpos == CONSBUFSIZE)
f01004f4:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004fa:	75 11                	jne    f010050d <cons_getc+0x45>
			cons.rpos = 0;
f01004fc:	c7 05 60 04 1e f0 00 	movl   $0x0,0xf01e0460
f0100503:	00 00 00 
f0100506:	eb 05                	jmp    f010050d <cons_getc+0x45>
		return c;
	}
	return 0;
f0100508:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010050d:	c9                   	leave  
f010050e:	c3                   	ret    

f010050f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010050f:	55                   	push   %ebp
f0100510:	89 e5                	mov    %esp,%ebp
f0100512:	57                   	push   %edi
f0100513:	56                   	push   %esi
f0100514:	53                   	push   %ebx
f0100515:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100518:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010051f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100526:	5a a5 
	if (*cp != 0xA55A) {
f0100528:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010052e:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100532:	74 11                	je     f0100545 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100534:	c7 05 4c 02 1e f0 b4 	movl   $0x3b4,0xf01e024c
f010053b:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010053e:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100543:	eb 16                	jmp    f010055b <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100545:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010054c:	c7 05 4c 02 1e f0 d4 	movl   $0x3d4,0xf01e024c
f0100553:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100556:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010055b:	8b 0d 4c 02 1e f0    	mov    0xf01e024c,%ecx
f0100561:	b0 0e                	mov    $0xe,%al
f0100563:	89 ca                	mov    %ecx,%edx
f0100565:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100566:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100569:	89 da                	mov    %ebx,%edx
f010056b:	ec                   	in     (%dx),%al
f010056c:	0f b6 f8             	movzbl %al,%edi
f010056f:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100572:	b0 0f                	mov    $0xf,%al
f0100574:	89 ca                	mov    %ecx,%edx
f0100576:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100577:	89 da                	mov    %ebx,%edx
f0100579:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010057a:	89 35 48 02 1e f0    	mov    %esi,0xf01e0248

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100580:	0f b6 d8             	movzbl %al,%ebx
f0100583:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100585:	66 89 3d 44 02 1e f0 	mov    %di,0xf01e0244
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010058c:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100591:	b0 00                	mov    $0x0,%al
f0100593:	89 da                	mov    %ebx,%edx
f0100595:	ee                   	out    %al,(%dx)
f0100596:	b2 fb                	mov    $0xfb,%dl
f0100598:	b0 80                	mov    $0x80,%al
f010059a:	ee                   	out    %al,(%dx)
f010059b:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01005a0:	b0 0c                	mov    $0xc,%al
f01005a2:	89 ca                	mov    %ecx,%edx
f01005a4:	ee                   	out    %al,(%dx)
f01005a5:	b2 f9                	mov    $0xf9,%dl
f01005a7:	b0 00                	mov    $0x0,%al
f01005a9:	ee                   	out    %al,(%dx)
f01005aa:	b2 fb                	mov    $0xfb,%dl
f01005ac:	b0 03                	mov    $0x3,%al
f01005ae:	ee                   	out    %al,(%dx)
f01005af:	b2 fc                	mov    $0xfc,%dl
f01005b1:	b0 00                	mov    $0x0,%al
f01005b3:	ee                   	out    %al,(%dx)
f01005b4:	b2 f9                	mov    $0xf9,%dl
f01005b6:	b0 01                	mov    $0x1,%al
f01005b8:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b9:	b2 fd                	mov    $0xfd,%dl
f01005bb:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005bc:	3c ff                	cmp    $0xff,%al
f01005be:	0f 95 45 e7          	setne  -0x19(%ebp)
f01005c2:	8a 45 e7             	mov    -0x19(%ebp),%al
f01005c5:	a2 50 02 1e f0       	mov    %al,0xf01e0250
f01005ca:	89 da                	mov    %ebx,%edx
f01005cc:	ec                   	in     (%dx),%al
f01005cd:	89 ca                	mov    %ecx,%edx
f01005cf:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005d0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01005d4:	75 10                	jne    f01005e6 <cons_init+0xd7>
		cprintf("Serial port does not exist!\n");
f01005d6:	83 ec 0c             	sub    $0xc,%esp
f01005d9:	68 39 4c 10 f0       	push   $0xf0104c39
f01005de:	e8 6e 2f 00 00       	call   f0103551 <cprintf>
f01005e3:	83 c4 10             	add    $0x10,%esp
}
f01005e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005e9:	5b                   	pop    %ebx
f01005ea:	5e                   	pop    %esi
f01005eb:	5f                   	pop    %edi
f01005ec:	c9                   	leave  
f01005ed:	c3                   	ret    

f01005ee <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005ee:	55                   	push   %ebp
f01005ef:	89 e5                	mov    %esp,%ebp
f01005f1:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01005f7:	e8 d3 fb ff ff       	call   f01001cf <cons_putc>
}
f01005fc:	c9                   	leave  
f01005fd:	c3                   	ret    

f01005fe <getchar>:

int
getchar(void)
{
f01005fe:	55                   	push   %ebp
f01005ff:	89 e5                	mov    %esp,%ebp
f0100601:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100604:	e8 bf fe ff ff       	call   f01004c8 <cons_getc>
f0100609:	85 c0                	test   %eax,%eax
f010060b:	74 f7                	je     f0100604 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010060d:	c9                   	leave  
f010060e:	c3                   	ret    

f010060f <iscons>:

int
iscons(int fdnum)
{
f010060f:	55                   	push   %ebp
f0100610:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100612:	b8 01 00 00 00       	mov    $0x1,%eax
f0100617:	c9                   	leave  
f0100618:	c3                   	ret    
f0100619:	00 00                	add    %al,(%eax)
	...

f010061c <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010061c:	55                   	push   %ebp
f010061d:	89 e5                	mov    %esp,%ebp
f010061f:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100622:	68 70 4e 10 f0       	push   $0xf0104e70
f0100627:	e8 25 2f 00 00       	call   f0103551 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010062c:	83 c4 08             	add    $0x8,%esp
f010062f:	68 0c 00 10 00       	push   $0x10000c
f0100634:	68 a0 50 10 f0       	push   $0xf01050a0
f0100639:	e8 13 2f 00 00       	call   f0103551 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010063e:	83 c4 0c             	add    $0xc,%esp
f0100641:	68 0c 00 10 00       	push   $0x10000c
f0100646:	68 0c 00 10 f0       	push   $0xf010000c
f010064b:	68 c8 50 10 f0       	push   $0xf01050c8
f0100650:	e8 fc 2e 00 00       	call   f0103551 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100655:	83 c4 0c             	add    $0xc,%esp
f0100658:	68 c8 4b 10 00       	push   $0x104bc8
f010065d:	68 c8 4b 10 f0       	push   $0xf0104bc8
f0100662:	68 ec 50 10 f0       	push   $0xf01050ec
f0100667:	e8 e5 2e 00 00       	call   f0103551 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010066c:	83 c4 0c             	add    $0xc,%esp
f010066f:	68 24 02 1e 00       	push   $0x1e0224
f0100674:	68 24 02 1e f0       	push   $0xf01e0224
f0100679:	68 10 51 10 f0       	push   $0xf0105110
f010067e:	e8 ce 2e 00 00       	call   f0103551 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100683:	83 c4 0c             	add    $0xc,%esp
f0100686:	68 50 11 1e 00       	push   $0x1e1150
f010068b:	68 50 11 1e f0       	push   $0xf01e1150
f0100690:	68 34 51 10 f0       	push   $0xf0105134
f0100695:	e8 b7 2e 00 00       	call   f0103551 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010069a:	b8 4f 15 1e f0       	mov    $0xf01e154f,%eax
f010069f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006a4:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01006a7:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006ac:	89 c2                	mov    %eax,%edx
f01006ae:	85 c0                	test   %eax,%eax
f01006b0:	79 06                	jns    f01006b8 <mon_kerninfo+0x9c>
f01006b2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006b8:	c1 fa 0a             	sar    $0xa,%edx
f01006bb:	52                   	push   %edx
f01006bc:	68 58 51 10 f0       	push   $0xf0105158
f01006c1:	e8 8b 2e 00 00       	call   f0103551 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01006cb:	c9                   	leave  
f01006cc:	c3                   	ret    

f01006cd <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006cd:	55                   	push   %ebp
f01006ce:	89 e5                	mov    %esp,%ebp
f01006d0:	53                   	push   %ebx
f01006d1:	83 ec 04             	sub    $0x4,%esp
f01006d4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006d9:	83 ec 04             	sub    $0x4,%esp
f01006dc:	ff b3 04 56 10 f0    	pushl  -0xfefa9fc(%ebx)
f01006e2:	ff b3 00 56 10 f0    	pushl  -0xfefaa00(%ebx)
f01006e8:	68 89 4e 10 f0       	push   $0xf0104e89
f01006ed:	e8 5f 2e 00 00       	call   f0103551 <cprintf>
f01006f2:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01006f5:	83 c4 10             	add    $0x10,%esp
f01006f8:	83 fb 6c             	cmp    $0x6c,%ebx
f01006fb:	75 dc                	jne    f01006d9 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01006fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100702:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100705:	c9                   	leave  
f0100706:	c3                   	ret    

f0100707 <mon_si>:
    return 0;
}

int 
mon_si(int argc, char **argv, struct Trapframe *tf)
{
f0100707:	55                   	push   %ebp
f0100708:	89 e5                	mov    %esp,%ebp
f010070a:	83 ec 08             	sub    $0x8,%esp
f010070d:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f0100710:	85 c0                	test   %eax,%eax
f0100712:	75 14                	jne    f0100728 <mon_si+0x21>
        cprintf("Error: you only can use si in breakpoint.\n");
f0100714:	83 ec 0c             	sub    $0xc,%esp
f0100717:	68 84 51 10 f0       	push   $0xf0105184
f010071c:	e8 30 2e 00 00       	call   f0103551 <cprintf>

    cprintf("tfno: %u\n", tf->tf_trapno);
    env_run(curenv);
    panic("mon_si : env_run return");
    return 0;
}
f0100721:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100726:	c9                   	leave  
f0100727:	c3                   	ret    
        cprintf("Error: you only can use si in breakpoint.\n");
        return -1;
    }

    // next step also cause debug interrupt
    tf->tf_eflags |= FL_TF;
f0100728:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)

    cprintf("tfno: %u\n", tf->tf_trapno);
f010072f:	83 ec 08             	sub    $0x8,%esp
f0100732:	ff 70 28             	pushl  0x28(%eax)
f0100735:	68 92 4e 10 f0       	push   $0xf0104e92
f010073a:	e8 12 2e 00 00       	call   f0103551 <cprintf>
    env_run(curenv);
f010073f:	83 c4 04             	add    $0x4,%esp
f0100742:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0100748:	e8 3f 2d 00 00       	call   f010348c <env_run>

f010074d <mon_continue>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

int 
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
f010074d:	55                   	push   %ebp
f010074e:	89 e5                	mov    %esp,%ebp
f0100750:	83 ec 08             	sub    $0x8,%esp
f0100753:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f0100756:	85 c0                	test   %eax,%eax
f0100758:	75 14                	jne    f010076e <mon_continue+0x21>
        cprintf("Error: you only can use continue in breakpoint.\n");
f010075a:	83 ec 0c             	sub    $0xc,%esp
f010075d:	68 b0 51 10 f0       	push   $0xf01051b0
f0100762:	e8 ea 2d 00 00       	call   f0103551 <cprintf>
    }
    tf->tf_eflags &= (~FL_TF);
    env_run(curenv);    // usually it won't return;
    panic("mon_continue : env_run return");
    return 0;
}
f0100767:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010076c:	c9                   	leave  
f010076d:	c3                   	ret    
{
    if (tf == NULL) {
        cprintf("Error: you only can use continue in breakpoint.\n");
        return -1;
    }
    tf->tf_eflags &= (~FL_TF);
f010076e:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
    env_run(curenv);    // usually it won't return;
f0100775:	83 ec 0c             	sub    $0xc,%esp
f0100778:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f010077e:	e8 09 2d 00 00       	call   f010348c <env_run>

f0100783 <mon_showmappings>:
    return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100783:	55                   	push   %ebp
f0100784:	89 e5                	mov    %esp,%ebp
f0100786:	57                   	push   %edi
f0100787:	56                   	push   %esi
f0100788:	53                   	push   %ebx
f0100789:	83 ec 0c             	sub    $0xc,%esp
f010078c:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 3) {
f010078f:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100793:	74 21                	je     f01007b6 <mon_showmappings+0x33>
        cprintf("Command should be: showmappings [addr1] [addr2]\n");
f0100795:	83 ec 0c             	sub    $0xc,%esp
f0100798:	68 e4 51 10 f0       	push   $0xf01051e4
f010079d:	e8 af 2d 00 00       	call   f0103551 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f01007a2:	c7 04 24 18 52 10 f0 	movl   $0xf0105218,(%esp)
f01007a9:	e8 a3 2d 00 00       	call   f0103551 <cprintf>
f01007ae:	83 c4 10             	add    $0x10,%esp
f01007b1:	e9 1a 01 00 00       	jmp    f01008d0 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f01007b6:	83 ec 04             	sub    $0x4,%esp
f01007b9:	6a 00                	push   $0x0
f01007bb:	6a 00                	push   $0x0
f01007bd:	ff 76 04             	pushl  0x4(%esi)
f01007c0:	e8 ed 40 00 00       	call   f01048b2 <strtol>
f01007c5:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f01007c7:	83 c4 0c             	add    $0xc,%esp
f01007ca:	6a 00                	push   $0x0
f01007cc:	6a 00                	push   $0x0
f01007ce:	ff 76 08             	pushl  0x8(%esi)
f01007d1:	e8 dc 40 00 00       	call   f01048b2 <strtol>
        if (laddr > haddr) {
f01007d6:	83 c4 10             	add    $0x10,%esp
f01007d9:	39 c3                	cmp    %eax,%ebx
f01007db:	76 01                	jbe    f01007de <mon_showmappings+0x5b>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f01007dd:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, PGSIZE);
f01007de:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        haddr = ROUNDUP(haddr, PGSIZE);
f01007e4:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01007ea:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
f01007f0:	83 ec 04             	sub    $0x4,%esp
f01007f3:	57                   	push   %edi
f01007f4:	53                   	push   %ebx
f01007f5:	68 9c 4e 10 f0       	push   $0xf0104e9c
f01007fa:	e8 52 2d 00 00       	call   f0103551 <cprintf>
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f01007ff:	83 c4 10             	add    $0x10,%esp
f0100802:	39 fb                	cmp    %edi,%ebx
f0100804:	75 07                	jne    f010080d <mon_showmappings+0x8a>
f0100806:	e9 c5 00 00 00       	jmp    f01008d0 <mon_showmappings+0x14d>
f010080b:	89 f3                	mov    %esi,%ebx
            cprintf("[ 0x%08x, 0x%08x ) -> ", now, now + PGSIZE); 
f010080d:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
f0100813:	83 ec 04             	sub    $0x4,%esp
f0100816:	56                   	push   %esi
f0100817:	53                   	push   %ebx
f0100818:	68 ad 4e 10 f0       	push   $0xf0104ead
f010081d:	e8 2f 2d 00 00       	call   f0103551 <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f0100822:	83 c4 0c             	add    $0xc,%esp
f0100825:	6a 00                	push   $0x0
f0100827:	53                   	push   %ebx
f0100828:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f010082e:	e8 8f 0c 00 00       	call   f01014c2 <pgdir_walk>
f0100833:	89 c3                	mov    %eax,%ebx
            if (pte == 0 || (*pte & PTE_P) == 0) {
f0100835:	83 c4 10             	add    $0x10,%esp
f0100838:	85 c0                	test   %eax,%eax
f010083a:	74 06                	je     f0100842 <mon_showmappings+0xbf>
f010083c:	8b 00                	mov    (%eax),%eax
f010083e:	a8 01                	test   $0x1,%al
f0100840:	75 12                	jne    f0100854 <mon_showmappings+0xd1>
                cprintf(" no mapped \n");
f0100842:	83 ec 0c             	sub    $0xc,%esp
f0100845:	68 c4 4e 10 f0       	push   $0xf0104ec4
f010084a:	e8 02 2d 00 00       	call   f0103551 <cprintf>
f010084f:	83 c4 10             	add    $0x10,%esp
f0100852:	eb 74                	jmp    f01008c8 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f0100854:	83 ec 08             	sub    $0x8,%esp
f0100857:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010085c:	50                   	push   %eax
f010085d:	68 d1 4e 10 f0       	push   $0xf0104ed1
f0100862:	e8 ea 2c 00 00       	call   f0103551 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f0100867:	83 c4 10             	add    $0x10,%esp
f010086a:	f6 03 04             	testb  $0x4,(%ebx)
f010086d:	74 12                	je     f0100881 <mon_showmappings+0xfe>
f010086f:	83 ec 0c             	sub    $0xc,%esp
f0100872:	68 d9 4e 10 f0       	push   $0xf0104ed9
f0100877:	e8 d5 2c 00 00       	call   f0103551 <cprintf>
f010087c:	83 c4 10             	add    $0x10,%esp
f010087f:	eb 10                	jmp    f0100891 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f0100881:	83 ec 0c             	sub    $0xc,%esp
f0100884:	68 e6 4e 10 f0       	push   $0xf0104ee6
f0100889:	e8 c3 2c 00 00       	call   f0103551 <cprintf>
f010088e:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f0100891:	f6 03 02             	testb  $0x2,(%ebx)
f0100894:	74 12                	je     f01008a8 <mon_showmappings+0x125>
f0100896:	83 ec 0c             	sub    $0xc,%esp
f0100899:	68 f3 4e 10 f0       	push   $0xf0104ef3
f010089e:	e8 ae 2c 00 00       	call   f0103551 <cprintf>
f01008a3:	83 c4 10             	add    $0x10,%esp
f01008a6:	eb 10                	jmp    f01008b8 <mon_showmappings+0x135>
                else cprintf(" R ");
f01008a8:	83 ec 0c             	sub    $0xc,%esp
f01008ab:	68 f8 4e 10 f0       	push   $0xf0104ef8
f01008b0:	e8 9c 2c 00 00       	call   f0103551 <cprintf>
f01008b5:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f01008b8:	83 ec 0c             	sub    $0xc,%esp
f01008bb:	68 cf 4e 10 f0       	push   $0xf0104ecf
f01008c0:	e8 8c 2c 00 00       	call   f0103551 <cprintf>
f01008c5:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDUP(haddr, PGSIZE);
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f01008c8:	39 f7                	cmp    %esi,%edi
f01008ca:	0f 85 3b ff ff ff    	jne    f010080b <mon_showmappings+0x88>
                cprintf("\n");
            }
        }
    }
    return 0;
}
f01008d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008d8:	5b                   	pop    %ebx
f01008d9:	5e                   	pop    %esi
f01008da:	5f                   	pop    %edi
f01008db:	c9                   	leave  
f01008dc:	c3                   	ret    

f01008dd <mon_setpermission>:
    return 0;
}

int
mon_setpermission(int argc, char **argv, struct Trapframe *tf)
{
f01008dd:	55                   	push   %ebp
f01008de:	89 e5                	mov    %esp,%ebp
f01008e0:	57                   	push   %edi
f01008e1:	56                   	push   %esi
f01008e2:	53                   	push   %ebx
f01008e3:	83 ec 0c             	sub    $0xc,%esp
f01008e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 5) { 
f01008e9:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f01008ed:	74 21                	je     f0100910 <mon_setpermission+0x33>
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
f01008ef:	83 ec 0c             	sub    $0xc,%esp
f01008f2:	68 40 52 10 f0       	push   $0xf0105240
f01008f7:	e8 55 2c 00 00       	call   f0103551 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f01008fc:	c7 04 24 90 52 10 f0 	movl   $0xf0105290,(%esp)
f0100903:	e8 49 2c 00 00       	call   f0103551 <cprintf>
f0100908:	83 c4 10             	add    $0x10,%esp
f010090b:	e9 a5 01 00 00       	jmp    f0100ab5 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f0100910:	83 ec 04             	sub    $0x4,%esp
f0100913:	6a 00                	push   $0x0
f0100915:	6a 00                	push   $0x0
f0100917:	ff 73 04             	pushl  0x4(%ebx)
f010091a:	e8 93 3f 00 00       	call   f01048b2 <strtol>
        uint32_t perm = 0;
        if (argv[2][0] == '1') perm |= PTE_W;
f010091f:	8b 53 08             	mov    0x8(%ebx),%edx
f0100922:	83 c4 10             	add    $0x10,%esp
    if (argc != 5) { 
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
        cprintf("Example: setpermissions 0x0 1 0 1\n");
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
        uint32_t perm = 0;
f0100925:	80 3a 31             	cmpb   $0x31,(%edx)
f0100928:	0f 94 c2             	sete   %dl
f010092b:	0f b6 d2             	movzbl %dl,%edx
f010092e:	89 d6                	mov    %edx,%esi
f0100930:	d1 e6                	shl    %esi
        if (argv[2][0] == '1') perm |= PTE_W;
        if (argv[3][0] == '1') perm |= PTE_U;
f0100932:	8b 53 0c             	mov    0xc(%ebx),%edx
f0100935:	80 3a 31             	cmpb   $0x31,(%edx)
f0100938:	75 03                	jne    f010093d <mon_setpermission+0x60>
f010093a:	83 ce 04             	or     $0x4,%esi
        if (argv[4][0] == '1') perm |= PTE_P;
f010093d:	8b 53 10             	mov    0x10(%ebx),%edx
f0100940:	80 3a 31             	cmpb   $0x31,(%edx)
f0100943:	75 03                	jne    f0100948 <mon_setpermission+0x6b>
f0100945:	83 ce 01             	or     $0x1,%esi
        addr = ROUNDUP(addr, PGSIZE);
f0100948:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f010094e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
f0100954:	83 ec 04             	sub    $0x4,%esp
f0100957:	6a 00                	push   $0x0
f0100959:	57                   	push   %edi
f010095a:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0100960:	e8 5d 0b 00 00       	call   f01014c2 <pgdir_walk>
f0100965:	89 c3                	mov    %eax,%ebx
        if (pte != NULL) {
f0100967:	83 c4 10             	add    $0x10,%esp
f010096a:	85 c0                	test   %eax,%eax
f010096c:	0f 84 33 01 00 00    	je     f0100aa5 <mon_setpermission+0x1c8>
            cprintf("0x%08x -> pa: 0x%08x\n old_perm: ", addr, PTE_ADDR(*pte));
f0100972:	83 ec 04             	sub    $0x4,%esp
f0100975:	8b 00                	mov    (%eax),%eax
f0100977:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010097c:	50                   	push   %eax
f010097d:	57                   	push   %edi
f010097e:	68 b4 52 10 f0       	push   $0xf01052b4
f0100983:	e8 c9 2b 00 00       	call   f0103551 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100988:	83 c4 10             	add    $0x10,%esp
f010098b:	f6 03 02             	testb  $0x2,(%ebx)
f010098e:	74 12                	je     f01009a2 <mon_setpermission+0xc5>
f0100990:	83 ec 0c             	sub    $0xc,%esp
f0100993:	68 fc 4e 10 f0       	push   $0xf0104efc
f0100998:	e8 b4 2b 00 00       	call   f0103551 <cprintf>
f010099d:	83 c4 10             	add    $0x10,%esp
f01009a0:	eb 10                	jmp    f01009b2 <mon_setpermission+0xd5>
f01009a2:	83 ec 0c             	sub    $0xc,%esp
f01009a5:	68 ff 4e 10 f0       	push   $0xf0104eff
f01009aa:	e8 a2 2b 00 00       	call   f0103551 <cprintf>
f01009af:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f01009b2:	f6 03 04             	testb  $0x4,(%ebx)
f01009b5:	74 12                	je     f01009c9 <mon_setpermission+0xec>
f01009b7:	83 ec 0c             	sub    $0xc,%esp
f01009ba:	68 e2 5f 10 f0       	push   $0xf0105fe2
f01009bf:	e8 8d 2b 00 00       	call   f0103551 <cprintf>
f01009c4:	83 c4 10             	add    $0x10,%esp
f01009c7:	eb 10                	jmp    f01009d9 <mon_setpermission+0xfc>
f01009c9:	83 ec 0c             	sub    $0xc,%esp
f01009cc:	68 1e 64 10 f0       	push   $0xf010641e
f01009d1:	e8 7b 2b 00 00       	call   f0103551 <cprintf>
f01009d6:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f01009d9:	f6 03 01             	testb  $0x1,(%ebx)
f01009dc:	74 12                	je     f01009f0 <mon_setpermission+0x113>
f01009de:	83 ec 0c             	sub    $0xc,%esp
f01009e1:	68 56 60 10 f0       	push   $0xf0106056
f01009e6:	e8 66 2b 00 00       	call   f0103551 <cprintf>
f01009eb:	83 c4 10             	add    $0x10,%esp
f01009ee:	eb 10                	jmp    f0100a00 <mon_setpermission+0x123>
f01009f0:	83 ec 0c             	sub    $0xc,%esp
f01009f3:	68 00 4f 10 f0       	push   $0xf0104f00
f01009f8:	e8 54 2b 00 00       	call   f0103551 <cprintf>
f01009fd:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f0100a00:	83 ec 0c             	sub    $0xc,%esp
f0100a03:	68 02 4f 10 f0       	push   $0xf0104f02
f0100a08:	e8 44 2b 00 00       	call   f0103551 <cprintf>
            *pte = PTE_ADDR(*pte) | perm;     
f0100a0d:	8b 03                	mov    (%ebx),%eax
f0100a0f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a14:	09 c6                	or     %eax,%esi
f0100a16:	89 33                	mov    %esi,(%ebx)
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100a18:	83 c4 10             	add    $0x10,%esp
f0100a1b:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0100a21:	74 12                	je     f0100a35 <mon_setpermission+0x158>
f0100a23:	83 ec 0c             	sub    $0xc,%esp
f0100a26:	68 fc 4e 10 f0       	push   $0xf0104efc
f0100a2b:	e8 21 2b 00 00       	call   f0103551 <cprintf>
f0100a30:	83 c4 10             	add    $0x10,%esp
f0100a33:	eb 10                	jmp    f0100a45 <mon_setpermission+0x168>
f0100a35:	83 ec 0c             	sub    $0xc,%esp
f0100a38:	68 ff 4e 10 f0       	push   $0xf0104eff
f0100a3d:	e8 0f 2b 00 00       	call   f0103551 <cprintf>
f0100a42:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100a45:	f6 03 04             	testb  $0x4,(%ebx)
f0100a48:	74 12                	je     f0100a5c <mon_setpermission+0x17f>
f0100a4a:	83 ec 0c             	sub    $0xc,%esp
f0100a4d:	68 e2 5f 10 f0       	push   $0xf0105fe2
f0100a52:	e8 fa 2a 00 00       	call   f0103551 <cprintf>
f0100a57:	83 c4 10             	add    $0x10,%esp
f0100a5a:	eb 10                	jmp    f0100a6c <mon_setpermission+0x18f>
f0100a5c:	83 ec 0c             	sub    $0xc,%esp
f0100a5f:	68 1e 64 10 f0       	push   $0xf010641e
f0100a64:	e8 e8 2a 00 00       	call   f0103551 <cprintf>
f0100a69:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100a6c:	f6 03 01             	testb  $0x1,(%ebx)
f0100a6f:	74 12                	je     f0100a83 <mon_setpermission+0x1a6>
f0100a71:	83 ec 0c             	sub    $0xc,%esp
f0100a74:	68 56 60 10 f0       	push   $0xf0106056
f0100a79:	e8 d3 2a 00 00       	call   f0103551 <cprintf>
f0100a7e:	83 c4 10             	add    $0x10,%esp
f0100a81:	eb 10                	jmp    f0100a93 <mon_setpermission+0x1b6>
f0100a83:	83 ec 0c             	sub    $0xc,%esp
f0100a86:	68 00 4f 10 f0       	push   $0xf0104f00
f0100a8b:	e8 c1 2a 00 00       	call   f0103551 <cprintf>
f0100a90:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100a93:	83 ec 0c             	sub    $0xc,%esp
f0100a96:	68 cf 4e 10 f0       	push   $0xf0104ecf
f0100a9b:	e8 b1 2a 00 00       	call   f0103551 <cprintf>
f0100aa0:	83 c4 10             	add    $0x10,%esp
f0100aa3:	eb 10                	jmp    f0100ab5 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100aa5:	83 ec 0c             	sub    $0xc,%esp
f0100aa8:	68 c4 4e 10 f0       	push   $0xf0104ec4
f0100aad:	e8 9f 2a 00 00       	call   f0103551 <cprintf>
f0100ab2:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100ab5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100abd:	5b                   	pop    %ebx
f0100abe:	5e                   	pop    %esi
f0100abf:	5f                   	pop    %edi
f0100ac0:	c9                   	leave  
f0100ac1:	c3                   	ret    

f0100ac2 <mon_setcolor>:
    return 0;
}

int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f0100ac2:	55                   	push   %ebp
f0100ac3:	89 e5                	mov    %esp,%ebp
f0100ac5:	56                   	push   %esi
f0100ac6:	53                   	push   %ebx
f0100ac7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f0100aca:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100ace:	74 66                	je     f0100b36 <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f0100ad0:	83 ec 0c             	sub    $0xc,%esp
f0100ad3:	68 d8 52 10 f0       	push   $0xf01052d8
f0100ad8:	e8 74 2a 00 00       	call   f0103551 <cprintf>
        cprintf("num show the color attribute. \n");
f0100add:	c7 04 24 08 53 10 f0 	movl   $0xf0105308,(%esp)
f0100ae4:	e8 68 2a 00 00       	call   f0103551 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100ae9:	c7 04 24 28 53 10 f0 	movl   $0xf0105328,(%esp)
f0100af0:	e8 5c 2a 00 00       	call   f0103551 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100af5:	c7 04 24 5c 53 10 f0 	movl   $0xf010535c,(%esp)
f0100afc:	e8 50 2a 00 00       	call   f0103551 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100b01:	c7 04 24 a0 53 10 f0 	movl   $0xf01053a0,(%esp)
f0100b08:	e8 44 2a 00 00       	call   f0103551 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100b0d:	c7 04 24 13 4f 10 f0 	movl   $0xf0104f13,(%esp)
f0100b14:	e8 38 2a 00 00       	call   f0103551 <cprintf>
        cprintf("         set the background color to black\n");
f0100b19:	c7 04 24 e4 53 10 f0 	movl   $0xf01053e4,(%esp)
f0100b20:	e8 2c 2a 00 00       	call   f0103551 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100b25:	c7 04 24 10 54 10 f0 	movl   $0xf0105410,(%esp)
f0100b2c:	e8 20 2a 00 00       	call   f0103551 <cprintf>
f0100b31:	83 c4 10             	add    $0x10,%esp
f0100b34:	eb 52                	jmp    f0100b88 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100b36:	83 ec 0c             	sub    $0xc,%esp
f0100b39:	ff 73 04             	pushl  0x4(%ebx)
f0100b3c:	e8 6f 3a 00 00       	call   f01045b0 <strlen>
f0100b41:	83 c4 10             	add    $0x10,%esp
f0100b44:	48                   	dec    %eax
f0100b45:	78 26                	js     f0100b6d <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f0100b47:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100b4a:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100b4f:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f0100b54:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f0100b58:	0f 94 c3             	sete   %bl
f0100b5b:	0f b6 db             	movzbl %bl,%ebx
f0100b5e:	d3 e3                	shl    %cl,%ebx
f0100b60:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100b62:	48                   	dec    %eax
f0100b63:	78 0d                	js     f0100b72 <mon_setcolor+0xb0>
f0100b65:	41                   	inc    %ecx
f0100b66:	83 f9 08             	cmp    $0x8,%ecx
f0100b69:	75 e9                	jne    f0100b54 <mon_setcolor+0x92>
f0100b6b:	eb 05                	jmp    f0100b72 <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100b6d:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f0100b72:	89 15 40 02 1e f0    	mov    %edx,0xf01e0240
        cprintf(" This is color that you want ! \n");
f0100b78:	83 ec 0c             	sub    $0xc,%esp
f0100b7b:	68 44 54 10 f0       	push   $0xf0105444
f0100b80:	e8 cc 29 00 00       	call   f0103551 <cprintf>
f0100b85:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f0100b88:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b90:	5b                   	pop    %ebx
f0100b91:	5e                   	pop    %esi
f0100b92:	c9                   	leave  
f0100b93:	c3                   	ret    

f0100b94 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f0100b94:	55                   	push   %ebp
f0100b95:	89 e5                	mov    %esp,%ebp
f0100b97:	57                   	push   %edi
f0100b98:	56                   	push   %esi
f0100b99:	53                   	push   %ebx
f0100b9a:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100b9d:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100b9f:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100ba1:	85 c0                	test   %eax,%eax
f0100ba3:	0f 84 8c 00 00 00    	je     f0100c35 <mon_backtrace+0xa1>
        cprintf("!!!!\n");
        eip = *(ebp + 1);
        cprintf("0x%08x\n", (uint32_t)ebp);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100ba9:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        cprintf("!!!!\n");
f0100bac:	83 ec 0c             	sub    $0xc,%esp
f0100baf:	68 2f 4f 10 f0       	push   $0xf0104f2f
f0100bb4:	e8 98 29 00 00       	call   f0103551 <cprintf>
        eip = *(ebp + 1);
f0100bb9:	8b 5e 04             	mov    0x4(%esi),%ebx
        cprintf("0x%08x\n", (uint32_t)ebp);
f0100bbc:	83 c4 08             	add    $0x8,%esp
f0100bbf:	56                   	push   %esi
f0100bc0:	68 78 62 10 f0       	push   $0xf0106278
f0100bc5:	e8 87 29 00 00       	call   f0103551 <cprintf>
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100bca:	ff 76 18             	pushl  0x18(%esi)
f0100bcd:	ff 76 14             	pushl  0x14(%esi)
f0100bd0:	ff 76 10             	pushl  0x10(%esi)
f0100bd3:	ff 76 0c             	pushl  0xc(%esi)
f0100bd6:	ff 76 08             	pushl  0x8(%esi)
f0100bd9:	53                   	push   %ebx
f0100bda:	56                   	push   %esi
f0100bdb:	68 68 54 10 f0       	push   $0xf0105468
f0100be0:	e8 6c 29 00 00       	call   f0103551 <cprintf>
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100be5:	83 c4 28             	add    $0x28,%esp
f0100be8:	57                   	push   %edi
f0100be9:	ff 76 04             	pushl  0x4(%esi)
f0100bec:	e8 10 31 00 00       	call   f0103d01 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100bf1:	83 c4 0c             	add    $0xc,%esp
f0100bf4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100bf7:	ff 75 d0             	pushl  -0x30(%ebp)
f0100bfa:	68 35 4f 10 f0       	push   $0xf0104f35
f0100bff:	e8 4d 29 00 00       	call   f0103551 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100c04:	83 c4 0c             	add    $0xc,%esp
f0100c07:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c0a:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c0d:	68 45 4f 10 f0       	push   $0xf0104f45
f0100c12:	e8 3a 29 00 00       	call   f0103551 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100c17:	83 c4 08             	add    $0x8,%esp
f0100c1a:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100c1d:	53                   	push   %ebx
f0100c1e:	68 4a 4f 10 f0       	push   $0xf0104f4a
f0100c23:	e8 29 29 00 00       	call   f0103551 <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100c28:	8b 36                	mov    (%esi),%esi
f0100c2a:	83 c4 10             	add    $0x10,%esp
f0100c2d:	85 f6                	test   %esi,%esi
f0100c2f:	0f 85 77 ff ff ff    	jne    f0100bac <mon_backtrace+0x18>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100c35:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c3d:	5b                   	pop    %ebx
f0100c3e:	5e                   	pop    %esi
f0100c3f:	5f                   	pop    %edi
f0100c40:	c9                   	leave  
f0100c41:	c3                   	ret    

f0100c42 <pa_con>:
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
f0100c42:	55                   	push   %ebp
f0100c43:	89 e5                	mov    %esp,%ebp
f0100c45:	53                   	push   %ebx
f0100c46:	83 ec 04             	sub    $0x4,%esp
f0100c49:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
f0100c4f:	8b 15 4c 11 1e f0    	mov    0xf01e114c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c55:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100c5b:	77 15                	ja     f0100c72 <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c5d:	52                   	push   %edx
f0100c5e:	68 a0 54 10 f0       	push   $0xf01054a0
f0100c63:	68 97 00 00 00       	push   $0x97
f0100c68:	68 4f 4f 10 f0       	push   $0xf0104f4f
f0100c6d:	e8 60 f4 ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100c72:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100c78:	39 d0                	cmp    %edx,%eax
f0100c7a:	72 18                	jb     f0100c94 <pa_con+0x52>
f0100c7c:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
f0100c82:	39 d8                	cmp    %ebx,%eax
f0100c84:	73 0e                	jae    f0100c94 <pa_con+0x52>
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
f0100c86:	29 d0                	sub    %edx,%eax
f0100c88:	8b 80 00 00 00 ef    	mov    -0x11000000(%eax),%eax
f0100c8e:	89 01                	mov    %eax,(%ecx)
        return true;
f0100c90:	b0 01                	mov    $0x1,%al
f0100c92:	eb 56                	jmp    f0100cea <pa_con+0xa8>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c94:	ba 00 90 11 f0       	mov    $0xf0119000,%edx
f0100c99:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100c9f:	77 15                	ja     f0100cb6 <pa_con+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ca1:	52                   	push   %edx
f0100ca2:	68 a0 54 10 f0       	push   $0xf01054a0
f0100ca7:	68 9c 00 00 00       	push   $0x9c
f0100cac:	68 4f 4f 10 f0       	push   $0xf0104f4f
f0100cb1:	e8 1c f4 ff ff       	call   f01000d2 <_panic>
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
f0100cb6:	3d 00 90 11 00       	cmp    $0x119000,%eax
f0100cbb:	72 18                	jb     f0100cd5 <pa_con+0x93>
f0100cbd:	3d 00 10 12 00       	cmp    $0x121000,%eax
f0100cc2:	73 11                	jae    f0100cd5 <pa_con+0x93>
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
f0100cc4:	2d 00 90 11 00       	sub    $0x119000,%eax
f0100cc9:	8b 80 00 80 ff ef    	mov    -0x10008000(%eax),%eax
f0100ccf:	89 01                	mov    %eax,(%ecx)
        return true;
f0100cd1:	b0 01                	mov    $0x1,%al
f0100cd3:	eb 15                	jmp    f0100cea <pa_con+0xa8>
    }
    if (addr < -KERNBASE) {
f0100cd5:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100cda:	77 0c                	ja     f0100ce8 <pa_con+0xa6>
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
f0100cdc:	8b 80 00 00 00 f0    	mov    -0x10000000(%eax),%eax
f0100ce2:	89 01                	mov    %eax,(%ecx)
        return true;
f0100ce4:	b0 01                	mov    $0x1,%al
f0100ce6:	eb 02                	jmp    f0100cea <pa_con+0xa8>
    }
    // Not in virtual memory mapped.
    return false;
f0100ce8:	b0 00                	mov    $0x0,%al
}
f0100cea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ced:	c9                   	leave  
f0100cee:	c3                   	ret    

f0100cef <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
f0100cef:	55                   	push   %ebp
f0100cf0:	89 e5                	mov    %esp,%ebp
f0100cf2:	57                   	push   %edi
f0100cf3:	56                   	push   %esi
f0100cf4:	53                   	push   %ebx
f0100cf5:	83 ec 2c             	sub    $0x2c,%esp
f0100cf8:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 4) {
f0100cfb:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100cff:	74 2d                	je     f0100d2e <mon_dump+0x3f>
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
f0100d01:	83 ec 0c             	sub    $0xc,%esp
f0100d04:	68 c4 54 10 f0       	push   $0xf01054c4
f0100d09:	e8 43 28 00 00       	call   f0103551 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100d0e:	c7 04 24 f4 54 10 f0 	movl   $0xf01054f4,(%esp)
f0100d15:	e8 37 28 00 00       	call   f0103551 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100d1a:	c7 04 24 1c 55 10 f0 	movl   $0xf010551c,(%esp)
f0100d21:	e8 2b 28 00 00       	call   f0103551 <cprintf>
f0100d26:	83 c4 10             	add    $0x10,%esp
f0100d29:	e9 59 01 00 00       	jmp    f0100e87 <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100d2e:	83 ec 04             	sub    $0x4,%esp
f0100d31:	6a 00                	push   $0x0
f0100d33:	6a 00                	push   $0x0
f0100d35:	ff 76 08             	pushl  0x8(%esi)
f0100d38:	e8 75 3b 00 00       	call   f01048b2 <strtol>
f0100d3d:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100d3f:	83 c4 0c             	add    $0xc,%esp
f0100d42:	6a 00                	push   $0x0
f0100d44:	6a 00                	push   $0x0
f0100d46:	ff 76 0c             	pushl  0xc(%esi)
f0100d49:	e8 64 3b 00 00       	call   f01048b2 <strtol>
        if (laddr > haddr) {
f0100d4e:	83 c4 10             	add    $0x10,%esp
f0100d51:	39 c3                	cmp    %eax,%ebx
f0100d53:	76 01                	jbe    f0100d56 <mon_dump+0x67>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100d55:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, 4);
f0100d56:	89 df                	mov    %ebx,%edi
f0100d58:	83 e7 fc             	and    $0xfffffffc,%edi
        haddr = ROUNDDOWN(haddr, 4);
f0100d5b:	83 e0 fc             	and    $0xfffffffc,%eax
f0100d5e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if (argv[1][0] == 'v') {
f0100d61:	8b 46 04             	mov    0x4(%esi),%eax
f0100d64:	80 38 76             	cmpb   $0x76,(%eax)
f0100d67:	74 0e                	je     f0100d77 <mon_dump+0x88>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100d69:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100d6c:	0f 85 98 00 00 00    	jne    f0100e0a <mon_dump+0x11b>
f0100d72:	e9 00 01 00 00       	jmp    f0100e77 <mon_dump+0x188>
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100d77:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100d7a:	74 7c                	je     f0100df8 <mon_dump+0x109>
f0100d7c:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100d7e:	39 fb                	cmp    %edi,%ebx
f0100d80:	74 15                	je     f0100d97 <mon_dump+0xa8>
f0100d82:	f6 c3 0f             	test   $0xf,%bl
f0100d85:	75 21                	jne    f0100da8 <mon_dump+0xb9>
                    if (now != laddr) cprintf("\n"); 
f0100d87:	83 ec 0c             	sub    $0xc,%esp
f0100d8a:	68 cf 4e 10 f0       	push   $0xf0104ecf
f0100d8f:	e8 bd 27 00 00       	call   f0103551 <cprintf>
f0100d94:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100d97:	83 ec 08             	sub    $0x8,%esp
f0100d9a:	53                   	push   %ebx
f0100d9b:	68 5e 4f 10 f0       	push   $0xf0104f5e
f0100da0:	e8 ac 27 00 00       	call   f0103551 <cprintf>
f0100da5:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100da8:	83 ec 04             	sub    $0x4,%esp
f0100dab:	6a 00                	push   $0x0
f0100dad:	89 d8                	mov    %ebx,%eax
f0100daf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100db4:	50                   	push   %eax
f0100db5:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0100dbb:	e8 02 07 00 00       	call   f01014c2 <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100dc0:	83 c4 10             	add    $0x10,%esp
f0100dc3:	85 c0                	test   %eax,%eax
f0100dc5:	74 19                	je     f0100de0 <mon_dump+0xf1>
f0100dc7:	f6 00 01             	testb  $0x1,(%eax)
f0100dca:	74 14                	je     f0100de0 <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100dcc:	83 ec 08             	sub    $0x8,%esp
f0100dcf:	ff 33                	pushl  (%ebx)
f0100dd1:	68 68 4f 10 f0       	push   $0xf0104f68
f0100dd6:	e8 76 27 00 00       	call   f0103551 <cprintf>
f0100ddb:	83 c4 10             	add    $0x10,%esp
f0100dde:	eb 10                	jmp    f0100df0 <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100de0:	83 ec 0c             	sub    $0xc,%esp
f0100de3:	68 73 4f 10 f0       	push   $0xf0104f73
f0100de8:	e8 64 27 00 00       	call   f0103551 <cprintf>
f0100ded:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100df0:	83 c3 04             	add    $0x4,%ebx
f0100df3:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100df6:	75 86                	jne    f0100d7e <mon_dump+0x8f>
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
f0100df8:	83 ec 0c             	sub    $0xc,%esp
f0100dfb:	68 cf 4e 10 f0       	push   $0xf0104ecf
f0100e00:	e8 4c 27 00 00       	call   f0103551 <cprintf>
f0100e05:	83 c4 10             	add    $0x10,%esp
f0100e08:	eb 7d                	jmp    f0100e87 <mon_dump+0x198>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100e0a:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100e0c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100e0f:	39 fb                	cmp    %edi,%ebx
f0100e11:	74 15                	je     f0100e28 <mon_dump+0x139>
f0100e13:	f6 c3 0f             	test   $0xf,%bl
f0100e16:	75 21                	jne    f0100e39 <mon_dump+0x14a>
                    if (now != laddr) cprintf("\n");
f0100e18:	83 ec 0c             	sub    $0xc,%esp
f0100e1b:	68 cf 4e 10 f0       	push   $0xf0104ecf
f0100e20:	e8 2c 27 00 00       	call   f0103551 <cprintf>
f0100e25:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100e28:	83 ec 08             	sub    $0x8,%esp
f0100e2b:	53                   	push   %ebx
f0100e2c:	68 5e 4f 10 f0       	push   $0xf0104f5e
f0100e31:	e8 1b 27 00 00       	call   f0103551 <cprintf>
f0100e36:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f0100e39:	83 ec 08             	sub    $0x8,%esp
f0100e3c:	56                   	push   %esi
f0100e3d:	53                   	push   %ebx
f0100e3e:	e8 ff fd ff ff       	call   f0100c42 <pa_con>
f0100e43:	83 c4 10             	add    $0x10,%esp
f0100e46:	84 c0                	test   %al,%al
f0100e48:	74 15                	je     f0100e5f <mon_dump+0x170>
                    cprintf("0x%08x  ", value);
f0100e4a:	83 ec 08             	sub    $0x8,%esp
f0100e4d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100e50:	68 68 4f 10 f0       	push   $0xf0104f68
f0100e55:	e8 f7 26 00 00       	call   f0103551 <cprintf>
f0100e5a:	83 c4 10             	add    $0x10,%esp
f0100e5d:	eb 10                	jmp    f0100e6f <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100e5f:	83 ec 0c             	sub    $0xc,%esp
f0100e62:	68 71 4f 10 f0       	push   $0xf0104f71
f0100e67:	e8 e5 26 00 00       	call   f0103551 <cprintf>
f0100e6c:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100e6f:	83 c3 04             	add    $0x4,%ebx
f0100e72:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100e75:	75 98                	jne    f0100e0f <mon_dump+0x120>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f0100e77:	83 ec 0c             	sub    $0xc,%esp
f0100e7a:	68 cf 4e 10 f0       	push   $0xf0104ecf
f0100e7f:	e8 cd 26 00 00       	call   f0103551 <cprintf>
f0100e84:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100e87:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e8f:	5b                   	pop    %ebx
f0100e90:	5e                   	pop    %esi
f0100e91:	5f                   	pop    %edi
f0100e92:	c9                   	leave  
f0100e93:	c3                   	ret    

f0100e94 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100e94:	55                   	push   %ebp
f0100e95:	89 e5                	mov    %esp,%ebp
f0100e97:	57                   	push   %edi
f0100e98:	56                   	push   %esi
f0100e99:	53                   	push   %ebx
f0100e9a:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100e9d:	68 60 55 10 f0       	push   $0xf0105560
f0100ea2:	e8 aa 26 00 00       	call   f0103551 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100ea7:	c7 04 24 84 55 10 f0 	movl   $0xf0105584,(%esp)
f0100eae:	e8 9e 26 00 00       	call   f0103551 <cprintf>

	if (tf != NULL)
f0100eb3:	83 c4 10             	add    $0x10,%esp
f0100eb6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100eba:	74 0e                	je     f0100eca <monitor+0x36>
		print_trapframe(tf);
f0100ebc:	83 ec 0c             	sub    $0xc,%esp
f0100ebf:	ff 75 08             	pushl  0x8(%ebp)
f0100ec2:	e8 3d 28 00 00       	call   f0103704 <print_trapframe>
f0100ec7:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100eca:	83 ec 0c             	sub    $0xc,%esp
f0100ecd:	68 7e 4f 10 f0       	push   $0xf0104f7e
f0100ed2:	e8 09 36 00 00       	call   f01044e0 <readline>
f0100ed7:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100ed9:	83 c4 10             	add    $0x10,%esp
f0100edc:	85 c0                	test   %eax,%eax
f0100ede:	74 ea                	je     f0100eca <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100ee0:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100ee7:	be 00 00 00 00       	mov    $0x0,%esi
f0100eec:	eb 04                	jmp    f0100ef2 <monitor+0x5e>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100eee:	c6 03 00             	movb   $0x0,(%ebx)
f0100ef1:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100ef2:	8a 03                	mov    (%ebx),%al
f0100ef4:	84 c0                	test   %al,%al
f0100ef6:	74 64                	je     f0100f5c <monitor+0xc8>
f0100ef8:	83 ec 08             	sub    $0x8,%esp
f0100efb:	0f be c0             	movsbl %al,%eax
f0100efe:	50                   	push   %eax
f0100eff:	68 82 4f 10 f0       	push   $0xf0104f82
f0100f04:	e8 20 38 00 00       	call   f0104729 <strchr>
f0100f09:	83 c4 10             	add    $0x10,%esp
f0100f0c:	85 c0                	test   %eax,%eax
f0100f0e:	75 de                	jne    f0100eee <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100f10:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100f13:	74 47                	je     f0100f5c <monitor+0xc8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100f15:	83 fe 0f             	cmp    $0xf,%esi
f0100f18:	75 14                	jne    f0100f2e <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100f1a:	83 ec 08             	sub    $0x8,%esp
f0100f1d:	6a 10                	push   $0x10
f0100f1f:	68 87 4f 10 f0       	push   $0xf0104f87
f0100f24:	e8 28 26 00 00       	call   f0103551 <cprintf>
f0100f29:	83 c4 10             	add    $0x10,%esp
f0100f2c:	eb 9c                	jmp    f0100eca <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100f2e:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100f32:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f33:	8a 03                	mov    (%ebx),%al
f0100f35:	84 c0                	test   %al,%al
f0100f37:	75 09                	jne    f0100f42 <monitor+0xae>
f0100f39:	eb b7                	jmp    f0100ef2 <monitor+0x5e>
			buf++;
f0100f3b:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f3c:	8a 03                	mov    (%ebx),%al
f0100f3e:	84 c0                	test   %al,%al
f0100f40:	74 b0                	je     f0100ef2 <monitor+0x5e>
f0100f42:	83 ec 08             	sub    $0x8,%esp
f0100f45:	0f be c0             	movsbl %al,%eax
f0100f48:	50                   	push   %eax
f0100f49:	68 82 4f 10 f0       	push   $0xf0104f82
f0100f4e:	e8 d6 37 00 00       	call   f0104729 <strchr>
f0100f53:	83 c4 10             	add    $0x10,%esp
f0100f56:	85 c0                	test   %eax,%eax
f0100f58:	74 e1                	je     f0100f3b <monitor+0xa7>
f0100f5a:	eb 96                	jmp    f0100ef2 <monitor+0x5e>
			buf++;
	}
	argv[argc] = 0;
f0100f5c:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100f63:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100f64:	85 f6                	test   %esi,%esi
f0100f66:	0f 84 5e ff ff ff    	je     f0100eca <monitor+0x36>
f0100f6c:	bb 00 56 10 f0       	mov    $0xf0105600,%ebx
f0100f71:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100f76:	83 ec 08             	sub    $0x8,%esp
f0100f79:	ff 33                	pushl  (%ebx)
f0100f7b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f7e:	e8 38 37 00 00       	call   f01046bb <strcmp>
f0100f83:	83 c4 10             	add    $0x10,%esp
f0100f86:	85 c0                	test   %eax,%eax
f0100f88:	75 20                	jne    f0100faa <monitor+0x116>
			return commands[i].func(argc, argv, tf);
f0100f8a:	83 ec 04             	sub    $0x4,%esp
f0100f8d:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100f90:	ff 75 08             	pushl  0x8(%ebp)
f0100f93:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100f96:	50                   	push   %eax
f0100f97:	56                   	push   %esi
f0100f98:	ff 97 08 56 10 f0    	call   *-0xfefa9f8(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100f9e:	83 c4 10             	add    $0x10,%esp
f0100fa1:	85 c0                	test   %eax,%eax
f0100fa3:	78 26                	js     f0100fcb <monitor+0x137>
f0100fa5:	e9 20 ff ff ff       	jmp    f0100eca <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100faa:	47                   	inc    %edi
f0100fab:	83 c3 0c             	add    $0xc,%ebx
f0100fae:	83 ff 09             	cmp    $0x9,%edi
f0100fb1:	75 c3                	jne    f0100f76 <monitor+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100fb3:	83 ec 08             	sub    $0x8,%esp
f0100fb6:	ff 75 a8             	pushl  -0x58(%ebp)
f0100fb9:	68 a4 4f 10 f0       	push   $0xf0104fa4
f0100fbe:	e8 8e 25 00 00       	call   f0103551 <cprintf>
f0100fc3:	83 c4 10             	add    $0x10,%esp
f0100fc6:	e9 ff fe ff ff       	jmp    f0100eca <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100fcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fce:	5b                   	pop    %ebx
f0100fcf:	5e                   	pop    %esi
f0100fd0:	5f                   	pop    %edi
f0100fd1:	c9                   	leave  
f0100fd2:	c3                   	ret    
	...

f0100fd4 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100fd4:	55                   	push   %ebp
f0100fd5:	89 e5                	mov    %esp,%ebp
f0100fd7:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100fd9:	83 3d 74 04 1e f0 00 	cmpl   $0x0,0xf01e0474
f0100fe0:	75 0f                	jne    f0100ff1 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100fe2:	b8 4f 21 1e f0       	mov    $0xf01e214f,%eax
f0100fe7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fec:	a3 74 04 1e f0       	mov    %eax,0xf01e0474
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0100ff1:	a1 74 04 1e f0       	mov    0xf01e0474,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100ff6:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100ffd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101003:	89 15 74 04 1e f0    	mov    %edx,0xf01e0474

	return result;
}
f0101009:	c9                   	leave  
f010100a:	c3                   	ret    

f010100b <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010100b:	55                   	push   %ebp
f010100c:	89 e5                	mov    %esp,%ebp
f010100e:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0101011:	89 d1                	mov    %edx,%ecx
f0101013:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0101016:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0101019:	a8 01                	test   $0x1,%al
f010101b:	74 42                	je     f010105f <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010101d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101022:	89 c1                	mov    %eax,%ecx
f0101024:	c1 e9 0c             	shr    $0xc,%ecx
f0101027:	3b 0d 44 11 1e f0    	cmp    0xf01e1144,%ecx
f010102d:	72 15                	jb     f0101044 <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010102f:	50                   	push   %eax
f0101030:	68 6c 56 10 f0       	push   $0xf010566c
f0101035:	68 1a 03 00 00       	push   $0x31a
f010103a:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010103f:	e8 8e f0 ff ff       	call   f01000d2 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101044:	c1 ea 0c             	shr    $0xc,%edx
f0101047:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010104d:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101054:	a8 01                	test   $0x1,%al
f0101056:	74 0e                	je     f0101066 <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101058:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010105d:	eb 0c                	jmp    f010106b <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f010105f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101064:	eb 05                	jmp    f010106b <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0101066:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f010106b:	c9                   	leave  
f010106c:	c3                   	ret    

f010106d <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f010106d:	55                   	push   %ebp
f010106e:	89 e5                	mov    %esp,%ebp
f0101070:	56                   	push   %esi
f0101071:	53                   	push   %ebx
f0101072:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101074:	83 ec 0c             	sub    $0xc,%esp
f0101077:	50                   	push   %eax
f0101078:	e8 73 24 00 00       	call   f01034f0 <mc146818_read>
f010107d:	89 c6                	mov    %eax,%esi
f010107f:	43                   	inc    %ebx
f0101080:	89 1c 24             	mov    %ebx,(%esp)
f0101083:	e8 68 24 00 00       	call   f01034f0 <mc146818_read>
f0101088:	c1 e0 08             	shl    $0x8,%eax
f010108b:	09 f0                	or     %esi,%eax
}
f010108d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101090:	5b                   	pop    %ebx
f0101091:	5e                   	pop    %esi
f0101092:	c9                   	leave  
f0101093:	c3                   	ret    

f0101094 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101094:	55                   	push   %ebp
f0101095:	89 e5                	mov    %esp,%ebp
f0101097:	57                   	push   %edi
f0101098:	56                   	push   %esi
f0101099:	53                   	push   %ebx
f010109a:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010109d:	3c 01                	cmp    $0x1,%al
f010109f:	19 f6                	sbb    %esi,%esi
f01010a1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f01010a7:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01010a8:	8b 1d 70 04 1e f0    	mov    0xf01e0470,%ebx
f01010ae:	85 db                	test   %ebx,%ebx
f01010b0:	75 17                	jne    f01010c9 <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f01010b2:	83 ec 04             	sub    $0x4,%esp
f01010b5:	68 90 56 10 f0       	push   $0xf0105690
f01010ba:	68 58 02 00 00       	push   $0x258
f01010bf:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01010c4:	e8 09 f0 ff ff       	call   f01000d2 <_panic>

	if (only_low_memory) {
f01010c9:	84 c0                	test   %al,%al
f01010cb:	74 50                	je     f010111d <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01010cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01010d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01010d6:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010d9:	89 d8                	mov    %ebx,%eax
f01010db:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f01010e1:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01010e4:	c1 e8 16             	shr    $0x16,%eax
f01010e7:	39 c6                	cmp    %eax,%esi
f01010e9:	0f 96 c0             	setbe  %al
f01010ec:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f01010ef:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f01010f3:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f01010f5:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010f9:	8b 1b                	mov    (%ebx),%ebx
f01010fb:	85 db                	test   %ebx,%ebx
f01010fd:	75 da                	jne    f01010d9 <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01010ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101102:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101108:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010110b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010110e:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101110:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101113:	89 1d 70 04 1e f0    	mov    %ebx,0xf01e0470
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101119:	85 db                	test   %ebx,%ebx
f010111b:	74 57                	je     f0101174 <check_page_free_list+0xe0>
f010111d:	89 d8                	mov    %ebx,%eax
f010111f:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0101125:	c1 f8 03             	sar    $0x3,%eax
f0101128:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010112b:	89 c2                	mov    %eax,%edx
f010112d:	c1 ea 16             	shr    $0x16,%edx
f0101130:	39 d6                	cmp    %edx,%esi
f0101132:	76 3a                	jbe    f010116e <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101134:	89 c2                	mov    %eax,%edx
f0101136:	c1 ea 0c             	shr    $0xc,%edx
f0101139:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f010113f:	72 12                	jb     f0101153 <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101141:	50                   	push   %eax
f0101142:	68 6c 56 10 f0       	push   $0xf010566c
f0101147:	6a 56                	push   $0x56
f0101149:	68 d9 5d 10 f0       	push   $0xf0105dd9
f010114e:	e8 7f ef ff ff       	call   f01000d2 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101153:	83 ec 04             	sub    $0x4,%esp
f0101156:	68 80 00 00 00       	push   $0x80
f010115b:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101160:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101165:	50                   	push   %eax
f0101166:	e8 0e 36 00 00       	call   f0104779 <memset>
f010116b:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010116e:	8b 1b                	mov    (%ebx),%ebx
f0101170:	85 db                	test   %ebx,%ebx
f0101172:	75 a9                	jne    f010111d <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101174:	b8 00 00 00 00       	mov    $0x0,%eax
f0101179:	e8 56 fe ff ff       	call   f0100fd4 <boot_alloc>
f010117e:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101181:	8b 15 70 04 1e f0    	mov    0xf01e0470,%edx
f0101187:	85 d2                	test   %edx,%edx
f0101189:	0f 84 80 01 00 00    	je     f010130f <check_page_free_list+0x27b>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010118f:	8b 1d 4c 11 1e f0    	mov    0xf01e114c,%ebx
f0101195:	39 da                	cmp    %ebx,%edx
f0101197:	72 43                	jb     f01011dc <check_page_free_list+0x148>
		assert(pp < pages + npages);
f0101199:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f010119e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01011a1:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f01011a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011a7:	39 c2                	cmp    %eax,%edx
f01011a9:	73 4f                	jae    f01011fa <check_page_free_list+0x166>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01011ab:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f01011ae:	89 d0                	mov    %edx,%eax
f01011b0:	29 d8                	sub    %ebx,%eax
f01011b2:	a8 07                	test   $0x7,%al
f01011b4:	75 66                	jne    f010121c <check_page_free_list+0x188>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011b6:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01011b9:	c1 e0 0c             	shl    $0xc,%eax
f01011bc:	74 7f                	je     f010123d <check_page_free_list+0x1a9>
		assert(page2pa(pp) != IOPHYSMEM);
f01011be:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01011c3:	0f 84 94 00 00 00    	je     f010125d <check_page_free_list+0x1c9>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01011c9:	be 00 00 00 00       	mov    $0x0,%esi
f01011ce:	bf 00 00 00 00       	mov    $0x0,%edi
f01011d3:	e9 9e 00 00 00       	jmp    f0101276 <check_page_free_list+0x1e2>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01011d8:	39 da                	cmp    %ebx,%edx
f01011da:	73 19                	jae    f01011f5 <check_page_free_list+0x161>
f01011dc:	68 e7 5d 10 f0       	push   $0xf0105de7
f01011e1:	68 f3 5d 10 f0       	push   $0xf0105df3
f01011e6:	68 72 02 00 00       	push   $0x272
f01011eb:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01011f0:	e8 dd ee ff ff       	call   f01000d2 <_panic>
		assert(pp < pages + npages);
f01011f5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01011f8:	72 19                	jb     f0101213 <check_page_free_list+0x17f>
f01011fa:	68 08 5e 10 f0       	push   $0xf0105e08
f01011ff:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101204:	68 73 02 00 00       	push   $0x273
f0101209:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010120e:	e8 bf ee ff ff       	call   f01000d2 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101213:	89 d0                	mov    %edx,%eax
f0101215:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101218:	a8 07                	test   $0x7,%al
f010121a:	74 19                	je     f0101235 <check_page_free_list+0x1a1>
f010121c:	68 b4 56 10 f0       	push   $0xf01056b4
f0101221:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101226:	68 74 02 00 00       	push   $0x274
f010122b:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101230:	e8 9d ee ff ff       	call   f01000d2 <_panic>
f0101235:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101238:	c1 e0 0c             	shl    $0xc,%eax
f010123b:	75 19                	jne    f0101256 <check_page_free_list+0x1c2>
f010123d:	68 1c 5e 10 f0       	push   $0xf0105e1c
f0101242:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101247:	68 77 02 00 00       	push   $0x277
f010124c:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101251:	e8 7c ee ff ff       	call   f01000d2 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101256:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010125b:	75 19                	jne    f0101276 <check_page_free_list+0x1e2>
f010125d:	68 2d 5e 10 f0       	push   $0xf0105e2d
f0101262:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101267:	68 78 02 00 00       	push   $0x278
f010126c:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101271:	e8 5c ee ff ff       	call   f01000d2 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101276:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010127b:	75 19                	jne    f0101296 <check_page_free_list+0x202>
f010127d:	68 e8 56 10 f0       	push   $0xf01056e8
f0101282:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101287:	68 79 02 00 00       	push   $0x279
f010128c:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101291:	e8 3c ee ff ff       	call   f01000d2 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101296:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010129b:	75 19                	jne    f01012b6 <check_page_free_list+0x222>
f010129d:	68 46 5e 10 f0       	push   $0xf0105e46
f01012a2:	68 f3 5d 10 f0       	push   $0xf0105df3
f01012a7:	68 7a 02 00 00       	push   $0x27a
f01012ac:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01012b1:	e8 1c ee ff ff       	call   f01000d2 <_panic>
f01012b6:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01012b8:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01012bd:	76 3e                	jbe    f01012fd <check_page_free_list+0x269>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012bf:	c1 e8 0c             	shr    $0xc,%eax
f01012c2:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01012c5:	77 12                	ja     f01012d9 <check_page_free_list+0x245>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012c7:	51                   	push   %ecx
f01012c8:	68 6c 56 10 f0       	push   $0xf010566c
f01012cd:	6a 56                	push   $0x56
f01012cf:	68 d9 5d 10 f0       	push   $0xf0105dd9
f01012d4:	e8 f9 ed ff ff       	call   f01000d2 <_panic>
	return (void *)(pa + KERNBASE);
f01012d9:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f01012df:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01012e2:	76 1c                	jbe    f0101300 <check_page_free_list+0x26c>
f01012e4:	68 0c 57 10 f0       	push   $0xf010570c
f01012e9:	68 f3 5d 10 f0       	push   $0xf0105df3
f01012ee:	68 7b 02 00 00       	push   $0x27b
f01012f3:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01012f8:	e8 d5 ed ff ff       	call   f01000d2 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f01012fd:	47                   	inc    %edi
f01012fe:	eb 01                	jmp    f0101301 <check_page_free_list+0x26d>
		else
			++nfree_extmem;
f0101300:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101301:	8b 12                	mov    (%edx),%edx
f0101303:	85 d2                	test   %edx,%edx
f0101305:	0f 85 cd fe ff ff    	jne    f01011d8 <check_page_free_list+0x144>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010130b:	85 ff                	test   %edi,%edi
f010130d:	7f 19                	jg     f0101328 <check_page_free_list+0x294>
f010130f:	68 60 5e 10 f0       	push   $0xf0105e60
f0101314:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101319:	68 83 02 00 00       	push   $0x283
f010131e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101323:	e8 aa ed ff ff       	call   f01000d2 <_panic>
	assert(nfree_extmem > 0);
f0101328:	85 f6                	test   %esi,%esi
f010132a:	7f 19                	jg     f0101345 <check_page_free_list+0x2b1>
f010132c:	68 72 5e 10 f0       	push   $0xf0105e72
f0101331:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101336:	68 84 02 00 00       	push   $0x284
f010133b:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101340:	e8 8d ed ff ff       	call   f01000d2 <_panic>
}
f0101345:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101348:	5b                   	pop    %ebx
f0101349:	5e                   	pop    %esi
f010134a:	5f                   	pop    %edi
f010134b:	c9                   	leave  
f010134c:	c3                   	ret    

f010134d <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010134d:	55                   	push   %ebp
f010134e:	89 e5                	mov    %esp,%ebp
f0101350:	56                   	push   %esi
f0101351:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f0101352:	c7 05 70 04 1e f0 00 	movl   $0x0,0xf01e0470
f0101359:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f010135c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101361:	e8 6e fc ff ff       	call   f0100fd4 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101366:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010136b:	77 15                	ja     f0101382 <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010136d:	50                   	push   %eax
f010136e:	68 a0 54 10 f0       	push   $0xf01054a0
f0101373:	68 24 01 00 00       	push   $0x124
f0101378:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010137d:	e8 50 ed ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101382:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f0101388:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f010138b:	83 3d 44 11 1e f0 00 	cmpl   $0x0,0xf01e1144
f0101392:	74 5f                	je     f01013f3 <page_init+0xa6>
f0101394:	8b 1d 70 04 1e f0    	mov    0xf01e0470,%ebx
f010139a:	ba 00 00 00 00       	mov    $0x0,%edx
f010139f:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f01013a4:	85 c0                	test   %eax,%eax
f01013a6:	74 25                	je     f01013cd <page_init+0x80>
f01013a8:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f01013ad:	76 04                	jbe    f01013b3 <page_init+0x66>
f01013af:	39 c6                	cmp    %eax,%esi
f01013b1:	77 1a                	ja     f01013cd <page_init+0x80>
		    pages[i].pp_ref = 0;
f01013b3:	89 d1                	mov    %edx,%ecx
f01013b5:	03 0d 4c 11 1e f0    	add    0xf01e114c,%ecx
f01013bb:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f01013c1:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f01013c3:	89 d3                	mov    %edx,%ebx
f01013c5:	03 1d 4c 11 1e f0    	add    0xf01e114c,%ebx
f01013cb:	eb 14                	jmp    f01013e1 <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f01013cd:	89 d1                	mov    %edx,%ecx
f01013cf:	03 0d 4c 11 1e f0    	add    0xf01e114c,%ecx
f01013d5:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f01013db:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// free pages!
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    for (i = 0; i < npages; i++) {
f01013e1:	40                   	inc    %eax
f01013e2:	83 c2 08             	add    $0x8,%edx
f01013e5:	39 05 44 11 1e f0    	cmp    %eax,0xf01e1144
f01013eb:	77 b7                	ja     f01013a4 <page_init+0x57>
f01013ed:	89 1d 70 04 1e f0    	mov    %ebx,0xf01e0470
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f01013f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01013f6:	5b                   	pop    %ebx
f01013f7:	5e                   	pop    %esi
f01013f8:	c9                   	leave  
f01013f9:	c3                   	ret    

f01013fa <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01013fa:	55                   	push   %ebp
f01013fb:	89 e5                	mov    %esp,%ebp
f01013fd:	53                   	push   %ebx
f01013fe:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f0101401:	8b 1d 70 04 1e f0    	mov    0xf01e0470,%ebx
f0101407:	85 db                	test   %ebx,%ebx
f0101409:	74 63                	je     f010146e <page_alloc+0x74>
f010140b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101410:	74 63                	je     f0101475 <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f0101412:	8b 1b                	mov    (%ebx),%ebx
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f0101414:	85 db                	test   %ebx,%ebx
f0101416:	75 08                	jne    f0101420 <page_alloc+0x26>
f0101418:	89 1d 70 04 1e f0    	mov    %ebx,0xf01e0470
f010141e:	eb 4e                	jmp    f010146e <page_alloc+0x74>
f0101420:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101425:	75 eb                	jne    f0101412 <page_alloc+0x18>
f0101427:	eb 4c                	jmp    f0101475 <page_alloc+0x7b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101429:	89 d8                	mov    %ebx,%eax
f010142b:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0101431:	c1 f8 03             	sar    $0x3,%eax
f0101434:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101437:	89 c2                	mov    %eax,%edx
f0101439:	c1 ea 0c             	shr    $0xc,%edx
f010143c:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0101442:	72 12                	jb     f0101456 <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101444:	50                   	push   %eax
f0101445:	68 6c 56 10 f0       	push   $0xf010566c
f010144a:	6a 56                	push   $0x56
f010144c:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0101451:	e8 7c ec ff ff       	call   f01000d2 <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f0101456:	83 ec 04             	sub    $0x4,%esp
f0101459:	68 00 10 00 00       	push   $0x1000
f010145e:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101460:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101465:	50                   	push   %eax
f0101466:	e8 0e 33 00 00       	call   f0104779 <memset>
f010146b:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f010146e:	89 d8                	mov    %ebx,%eax
f0101470:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101473:	c9                   	leave  
f0101474:	c3                   	ret    
        page_free_list = page_free_list->pp_link;
    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f0101475:	8b 03                	mov    (%ebx),%eax
f0101477:	a3 70 04 1e f0       	mov    %eax,0xf01e0470
        if (alloc_flags & ALLOC_ZERO) {
f010147c:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101480:	74 ec                	je     f010146e <page_alloc+0x74>
f0101482:	eb a5                	jmp    f0101429 <page_alloc+0x2f>

f0101484 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101484:	55                   	push   %ebp
f0101485:	89 e5                	mov    %esp,%ebp
f0101487:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f010148a:	85 c0                	test   %eax,%eax
f010148c:	74 14                	je     f01014a2 <page_free+0x1e>
f010148e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101493:	75 0d                	jne    f01014a2 <page_free+0x1e>
    pp->pp_link = page_free_list;
f0101495:	8b 15 70 04 1e f0    	mov    0xf01e0470,%edx
f010149b:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f010149d:	a3 70 04 1e f0       	mov    %eax,0xf01e0470
}
f01014a2:	c9                   	leave  
f01014a3:	c3                   	ret    

f01014a4 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01014a4:	55                   	push   %ebp
f01014a5:	89 e5                	mov    %esp,%ebp
f01014a7:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01014aa:	8b 50 04             	mov    0x4(%eax),%edx
f01014ad:	4a                   	dec    %edx
f01014ae:	66 89 50 04          	mov    %dx,0x4(%eax)
f01014b2:	66 85 d2             	test   %dx,%dx
f01014b5:	75 09                	jne    f01014c0 <page_decref+0x1c>
		page_free(pp);
f01014b7:	50                   	push   %eax
f01014b8:	e8 c7 ff ff ff       	call   f0101484 <page_free>
f01014bd:	83 c4 04             	add    $0x4,%esp
}
f01014c0:	c9                   	leave  
f01014c1:	c3                   	ret    

f01014c2 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01014c2:	55                   	push   %ebp
f01014c3:	89 e5                	mov    %esp,%ebp
f01014c5:	56                   	push   %esi
f01014c6:	53                   	push   %ebx
f01014c7:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f01014ca:	89 f3                	mov    %esi,%ebx
f01014cc:	c1 eb 16             	shr    $0x16,%ebx
f01014cf:	c1 e3 02             	shl    $0x2,%ebx
f01014d2:	03 5d 08             	add    0x8(%ebp),%ebx
f01014d5:	8b 03                	mov    (%ebx),%eax
f01014d7:	85 c0                	test   %eax,%eax
f01014d9:	74 04                	je     f01014df <pgdir_walk+0x1d>
f01014db:	a8 01                	test   $0x1,%al
f01014dd:	75 2c                	jne    f010150b <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f01014df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01014e3:	74 61                	je     f0101546 <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(1);
f01014e5:	83 ec 0c             	sub    $0xc,%esp
f01014e8:	6a 01                	push   $0x1
f01014ea:	e8 0b ff ff ff       	call   f01013fa <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f01014ef:	83 c4 10             	add    $0x10,%esp
f01014f2:	85 c0                	test   %eax,%eax
f01014f4:	74 57                	je     f010154d <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f01014f6:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014fa:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0101500:	c1 f8 03             	sar    $0x3,%eax
f0101503:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f0101506:	83 c8 07             	or     $0x7,%eax
f0101509:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f010150b:	8b 03                	mov    (%ebx),%eax
f010150d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101512:	89 c2                	mov    %eax,%edx
f0101514:	c1 ea 0c             	shr    $0xc,%edx
f0101517:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f010151d:	72 15                	jb     f0101534 <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010151f:	50                   	push   %eax
f0101520:	68 6c 56 10 f0       	push   $0xf010566c
f0101525:	68 87 01 00 00       	push   $0x187
f010152a:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010152f:	e8 9e eb ff ff       	call   f01000d2 <_panic>
f0101534:	c1 ee 0a             	shr    $0xa,%esi
f0101537:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010153d:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101544:	eb 0c                	jmp    f0101552 <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f0101546:	b8 00 00 00 00       	mov    $0x0,%eax
f010154b:	eb 05                	jmp    f0101552 <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f010154d:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f0101552:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101555:	5b                   	pop    %ebx
f0101556:	5e                   	pop    %esi
f0101557:	c9                   	leave  
f0101558:	c3                   	ret    

f0101559 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101559:	55                   	push   %ebp
f010155a:	89 e5                	mov    %esp,%ebp
f010155c:	57                   	push   %edi
f010155d:	56                   	push   %esi
f010155e:	53                   	push   %ebx
f010155f:	83 ec 1c             	sub    $0x1c,%esp
f0101562:	89 c7                	mov    %eax,%edi
f0101564:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101567:	01 d1                	add    %edx,%ecx
f0101569:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010156c:	39 ca                	cmp    %ecx,%edx
f010156e:	74 32                	je     f01015a2 <boot_map_region+0x49>
f0101570:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f0101572:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101575:	83 c8 01             	or     $0x1,%eax
f0101578:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f010157b:	83 ec 04             	sub    $0x4,%esp
f010157e:	6a 01                	push   $0x1
f0101580:	53                   	push   %ebx
f0101581:	57                   	push   %edi
f0101582:	e8 3b ff ff ff       	call   f01014c2 <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f0101587:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010158a:	09 f2                	or     %esi,%edx
f010158c:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f010158e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101594:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010159a:	83 c4 10             	add    $0x10,%esp
f010159d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01015a0:	75 d9                	jne    f010157b <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f01015a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015a5:	5b                   	pop    %ebx
f01015a6:	5e                   	pop    %esi
f01015a7:	5f                   	pop    %edi
f01015a8:	c9                   	leave  
f01015a9:	c3                   	ret    

f01015aa <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01015aa:	55                   	push   %ebp
f01015ab:	89 e5                	mov    %esp,%ebp
f01015ad:	53                   	push   %ebx
f01015ae:	83 ec 08             	sub    $0x8,%esp
f01015b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f01015b4:	6a 00                	push   $0x0
f01015b6:	ff 75 0c             	pushl  0xc(%ebp)
f01015b9:	ff 75 08             	pushl  0x8(%ebp)
f01015bc:	e8 01 ff ff ff       	call   f01014c2 <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01015c1:	83 c4 10             	add    $0x10,%esp
f01015c4:	85 c0                	test   %eax,%eax
f01015c6:	74 37                	je     f01015ff <page_lookup+0x55>
f01015c8:	f6 00 01             	testb  $0x1,(%eax)
f01015cb:	74 39                	je     f0101606 <page_lookup+0x5c>
    if (pte_store != 0) {
f01015cd:	85 db                	test   %ebx,%ebx
f01015cf:	74 02                	je     f01015d3 <page_lookup+0x29>
        *pte_store = pte;
f01015d1:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f01015d3:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015d5:	c1 e8 0c             	shr    $0xc,%eax
f01015d8:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f01015de:	72 14                	jb     f01015f4 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01015e0:	83 ec 04             	sub    $0x4,%esp
f01015e3:	68 54 57 10 f0       	push   $0xf0105754
f01015e8:	6a 4f                	push   $0x4f
f01015ea:	68 d9 5d 10 f0       	push   $0xf0105dd9
f01015ef:	e8 de ea ff ff       	call   f01000d2 <_panic>
	return &pages[PGNUM(pa)];
f01015f4:	c1 e0 03             	shl    $0x3,%eax
f01015f7:	03 05 4c 11 1e f0    	add    0xf01e114c,%eax
f01015fd:	eb 0c                	jmp    f010160b <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01015ff:	b8 00 00 00 00       	mov    $0x0,%eax
f0101604:	eb 05                	jmp    f010160b <page_lookup+0x61>
f0101606:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f010160b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010160e:	c9                   	leave  
f010160f:	c3                   	ret    

f0101610 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101610:	55                   	push   %ebp
f0101611:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101613:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101616:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101619:	c9                   	leave  
f010161a:	c3                   	ret    

f010161b <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010161b:	55                   	push   %ebp
f010161c:	89 e5                	mov    %esp,%ebp
f010161e:	56                   	push   %esi
f010161f:	53                   	push   %ebx
f0101620:	83 ec 14             	sub    $0x14,%esp
f0101623:	8b 75 08             	mov    0x8(%ebp),%esi
f0101626:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f0101629:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010162c:	50                   	push   %eax
f010162d:	53                   	push   %ebx
f010162e:	56                   	push   %esi
f010162f:	e8 76 ff ff ff       	call   f01015aa <page_lookup>
    if (pg == NULL) return;
f0101634:	83 c4 10             	add    $0x10,%esp
f0101637:	85 c0                	test   %eax,%eax
f0101639:	74 26                	je     f0101661 <page_remove+0x46>
    page_decref(pg);
f010163b:	83 ec 0c             	sub    $0xc,%esp
f010163e:	50                   	push   %eax
f010163f:	e8 60 fe ff ff       	call   f01014a4 <page_decref>
    if (pte != NULL) *pte = 0;
f0101644:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101647:	83 c4 10             	add    $0x10,%esp
f010164a:	85 c0                	test   %eax,%eax
f010164c:	74 06                	je     f0101654 <page_remove+0x39>
f010164e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f0101654:	83 ec 08             	sub    $0x8,%esp
f0101657:	53                   	push   %ebx
f0101658:	56                   	push   %esi
f0101659:	e8 b2 ff ff ff       	call   f0101610 <tlb_invalidate>
f010165e:	83 c4 10             	add    $0x10,%esp
}
f0101661:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101664:	5b                   	pop    %ebx
f0101665:	5e                   	pop    %esi
f0101666:	c9                   	leave  
f0101667:	c3                   	ret    

f0101668 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101668:	55                   	push   %ebp
f0101669:	89 e5                	mov    %esp,%ebp
f010166b:	57                   	push   %edi
f010166c:	56                   	push   %esi
f010166d:	53                   	push   %ebx
f010166e:	83 ec 10             	sub    $0x10,%esp
f0101671:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101674:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f0101677:	6a 01                	push   $0x1
f0101679:	57                   	push   %edi
f010167a:	ff 75 08             	pushl  0x8(%ebp)
f010167d:	e8 40 fe ff ff       	call   f01014c2 <pgdir_walk>
f0101682:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f0101684:	83 c4 10             	add    $0x10,%esp
f0101687:	85 c0                	test   %eax,%eax
f0101689:	74 39                	je     f01016c4 <page_insert+0x5c>
    ++pp->pp_ref;
f010168b:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f010168f:	f6 00 01             	testb  $0x1,(%eax)
f0101692:	74 0f                	je     f01016a3 <page_insert+0x3b>
        page_remove(pgdir, va);
f0101694:	83 ec 08             	sub    $0x8,%esp
f0101697:	57                   	push   %edi
f0101698:	ff 75 08             	pushl  0x8(%ebp)
f010169b:	e8 7b ff ff ff       	call   f010161b <page_remove>
f01016a0:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f01016a3:	8b 55 14             	mov    0x14(%ebp),%edx
f01016a6:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016a9:	2b 35 4c 11 1e f0    	sub    0xf01e114c,%esi
f01016af:	c1 fe 03             	sar    $0x3,%esi
f01016b2:	89 f0                	mov    %esi,%eax
f01016b4:	c1 e0 0c             	shl    $0xc,%eax
f01016b7:	89 d6                	mov    %edx,%esi
f01016b9:	09 c6                	or     %eax,%esi
f01016bb:	89 33                	mov    %esi,(%ebx)
	return 0;
f01016bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01016c2:	eb 05                	jmp    f01016c9 <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f01016c4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f01016c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01016cc:	5b                   	pop    %ebx
f01016cd:	5e                   	pop    %esi
f01016ce:	5f                   	pop    %edi
f01016cf:	c9                   	leave  
f01016d0:	c3                   	ret    

f01016d1 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01016d1:	55                   	push   %ebp
f01016d2:	89 e5                	mov    %esp,%ebp
f01016d4:	57                   	push   %edi
f01016d5:	56                   	push   %esi
f01016d6:	53                   	push   %ebx
f01016d7:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01016da:	b8 15 00 00 00       	mov    $0x15,%eax
f01016df:	e8 89 f9 ff ff       	call   f010106d <nvram_read>
f01016e4:	c1 e0 0a             	shl    $0xa,%eax
f01016e7:	89 c2                	mov    %eax,%edx
f01016e9:	85 c0                	test   %eax,%eax
f01016eb:	79 06                	jns    f01016f3 <mem_init+0x22>
f01016ed:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01016f3:	c1 fa 0c             	sar    $0xc,%edx
f01016f6:	89 15 78 04 1e f0    	mov    %edx,0xf01e0478
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01016fc:	b8 17 00 00 00       	mov    $0x17,%eax
f0101701:	e8 67 f9 ff ff       	call   f010106d <nvram_read>
f0101706:	89 c2                	mov    %eax,%edx
f0101708:	c1 e2 0a             	shl    $0xa,%edx
f010170b:	89 d0                	mov    %edx,%eax
f010170d:	85 d2                	test   %edx,%edx
f010170f:	79 06                	jns    f0101717 <mem_init+0x46>
f0101711:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101717:	c1 f8 0c             	sar    $0xc,%eax
f010171a:	74 0e                	je     f010172a <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010171c:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101722:	89 15 44 11 1e f0    	mov    %edx,0xf01e1144
f0101728:	eb 0c                	jmp    f0101736 <mem_init+0x65>
	else
		npages = npages_basemem;
f010172a:	8b 15 78 04 1e f0    	mov    0xf01e0478,%edx
f0101730:	89 15 44 11 1e f0    	mov    %edx,0xf01e1144

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101736:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101739:	c1 e8 0a             	shr    $0xa,%eax
f010173c:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f010173d:	a1 78 04 1e f0       	mov    0xf01e0478,%eax
f0101742:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101745:	c1 e8 0a             	shr    $0xa,%eax
f0101748:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0101749:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f010174e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101751:	c1 e8 0a             	shr    $0xa,%eax
f0101754:	50                   	push   %eax
f0101755:	68 74 57 10 f0       	push   $0xf0105774
f010175a:	e8 f2 1d 00 00       	call   f0103551 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010175f:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101764:	e8 6b f8 ff ff       	call   f0100fd4 <boot_alloc>
f0101769:	a3 48 11 1e f0       	mov    %eax,0xf01e1148
	memset(kern_pgdir, 0, PGSIZE);
f010176e:	83 c4 0c             	add    $0xc,%esp
f0101771:	68 00 10 00 00       	push   $0x1000
f0101776:	6a 00                	push   $0x0
f0101778:	50                   	push   %eax
f0101779:	e8 fb 2f 00 00       	call   f0104779 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010177e:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101783:	83 c4 10             	add    $0x10,%esp
f0101786:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010178b:	77 15                	ja     f01017a2 <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010178d:	50                   	push   %eax
f010178e:	68 a0 54 10 f0       	push   $0xf01054a0
f0101793:	68 8e 00 00 00       	push   $0x8e
f0101798:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010179d:	e8 30 e9 ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01017a2:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01017a8:	83 ca 05             	or     $0x5,%edx
f01017ab:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01017b1:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f01017b6:	c1 e0 03             	shl    $0x3,%eax
f01017b9:	e8 16 f8 ff ff       	call   f0100fd4 <boot_alloc>
f01017be:	a3 4c 11 1e f0       	mov    %eax,0xf01e114c
    

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f01017c3:	b8 00 80 01 00       	mov    $0x18000,%eax
f01017c8:	e8 07 f8 ff ff       	call   f0100fd4 <boot_alloc>
f01017cd:	a3 7c 04 1e f0       	mov    %eax,0xf01e047c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01017d2:	e8 76 fb ff ff       	call   f010134d <page_init>

	check_page_free_list(1);
f01017d7:	b8 01 00 00 00       	mov    $0x1,%eax
f01017dc:	e8 b3 f8 ff ff       	call   f0101094 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01017e1:	83 3d 4c 11 1e f0 00 	cmpl   $0x0,0xf01e114c
f01017e8:	75 17                	jne    f0101801 <mem_init+0x130>
		panic("'pages' is a null pointer!");
f01017ea:	83 ec 04             	sub    $0x4,%esp
f01017ed:	68 83 5e 10 f0       	push   $0xf0105e83
f01017f2:	68 95 02 00 00       	push   $0x295
f01017f7:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01017fc:	e8 d1 e8 ff ff       	call   f01000d2 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101801:	a1 70 04 1e f0       	mov    0xf01e0470,%eax
f0101806:	85 c0                	test   %eax,%eax
f0101808:	74 0e                	je     f0101818 <mem_init+0x147>
f010180a:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f010180f:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101810:	8b 00                	mov    (%eax),%eax
f0101812:	85 c0                	test   %eax,%eax
f0101814:	75 f9                	jne    f010180f <mem_init+0x13e>
f0101816:	eb 05                	jmp    f010181d <mem_init+0x14c>
f0101818:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010181d:	83 ec 0c             	sub    $0xc,%esp
f0101820:	6a 00                	push   $0x0
f0101822:	e8 d3 fb ff ff       	call   f01013fa <page_alloc>
f0101827:	89 c6                	mov    %eax,%esi
f0101829:	83 c4 10             	add    $0x10,%esp
f010182c:	85 c0                	test   %eax,%eax
f010182e:	75 19                	jne    f0101849 <mem_init+0x178>
f0101830:	68 9e 5e 10 f0       	push   $0xf0105e9e
f0101835:	68 f3 5d 10 f0       	push   $0xf0105df3
f010183a:	68 9d 02 00 00       	push   $0x29d
f010183f:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101844:	e8 89 e8 ff ff       	call   f01000d2 <_panic>
	assert((pp1 = page_alloc(0)));
f0101849:	83 ec 0c             	sub    $0xc,%esp
f010184c:	6a 00                	push   $0x0
f010184e:	e8 a7 fb ff ff       	call   f01013fa <page_alloc>
f0101853:	89 c7                	mov    %eax,%edi
f0101855:	83 c4 10             	add    $0x10,%esp
f0101858:	85 c0                	test   %eax,%eax
f010185a:	75 19                	jne    f0101875 <mem_init+0x1a4>
f010185c:	68 b4 5e 10 f0       	push   $0xf0105eb4
f0101861:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101866:	68 9e 02 00 00       	push   $0x29e
f010186b:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101870:	e8 5d e8 ff ff       	call   f01000d2 <_panic>
	assert((pp2 = page_alloc(0)));
f0101875:	83 ec 0c             	sub    $0xc,%esp
f0101878:	6a 00                	push   $0x0
f010187a:	e8 7b fb ff ff       	call   f01013fa <page_alloc>
f010187f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101882:	83 c4 10             	add    $0x10,%esp
f0101885:	85 c0                	test   %eax,%eax
f0101887:	75 19                	jne    f01018a2 <mem_init+0x1d1>
f0101889:	68 ca 5e 10 f0       	push   $0xf0105eca
f010188e:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101893:	68 9f 02 00 00       	push   $0x29f
f0101898:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010189d:	e8 30 e8 ff ff       	call   f01000d2 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018a2:	39 fe                	cmp    %edi,%esi
f01018a4:	75 19                	jne    f01018bf <mem_init+0x1ee>
f01018a6:	68 e0 5e 10 f0       	push   $0xf0105ee0
f01018ab:	68 f3 5d 10 f0       	push   $0xf0105df3
f01018b0:	68 a2 02 00 00       	push   $0x2a2
f01018b5:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01018ba:	e8 13 e8 ff ff       	call   f01000d2 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018bf:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01018c2:	74 05                	je     f01018c9 <mem_init+0x1f8>
f01018c4:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01018c7:	75 19                	jne    f01018e2 <mem_init+0x211>
f01018c9:	68 b0 57 10 f0       	push   $0xf01057b0
f01018ce:	68 f3 5d 10 f0       	push   $0xf0105df3
f01018d3:	68 a3 02 00 00       	push   $0x2a3
f01018d8:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01018dd:	e8 f0 e7 ff ff       	call   f01000d2 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018e2:	8b 15 4c 11 1e f0    	mov    0xf01e114c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01018e8:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f01018ed:	c1 e0 0c             	shl    $0xc,%eax
f01018f0:	89 f1                	mov    %esi,%ecx
f01018f2:	29 d1                	sub    %edx,%ecx
f01018f4:	c1 f9 03             	sar    $0x3,%ecx
f01018f7:	c1 e1 0c             	shl    $0xc,%ecx
f01018fa:	39 c1                	cmp    %eax,%ecx
f01018fc:	72 19                	jb     f0101917 <mem_init+0x246>
f01018fe:	68 f2 5e 10 f0       	push   $0xf0105ef2
f0101903:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101908:	68 a4 02 00 00       	push   $0x2a4
f010190d:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101912:	e8 bb e7 ff ff       	call   f01000d2 <_panic>
f0101917:	89 f9                	mov    %edi,%ecx
f0101919:	29 d1                	sub    %edx,%ecx
f010191b:	c1 f9 03             	sar    $0x3,%ecx
f010191e:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101921:	39 c8                	cmp    %ecx,%eax
f0101923:	77 19                	ja     f010193e <mem_init+0x26d>
f0101925:	68 0f 5f 10 f0       	push   $0xf0105f0f
f010192a:	68 f3 5d 10 f0       	push   $0xf0105df3
f010192f:	68 a5 02 00 00       	push   $0x2a5
f0101934:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101939:	e8 94 e7 ff ff       	call   f01000d2 <_panic>
f010193e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101941:	29 d1                	sub    %edx,%ecx
f0101943:	89 ca                	mov    %ecx,%edx
f0101945:	c1 fa 03             	sar    $0x3,%edx
f0101948:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010194b:	39 d0                	cmp    %edx,%eax
f010194d:	77 19                	ja     f0101968 <mem_init+0x297>
f010194f:	68 2c 5f 10 f0       	push   $0xf0105f2c
f0101954:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101959:	68 a6 02 00 00       	push   $0x2a6
f010195e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101963:	e8 6a e7 ff ff       	call   f01000d2 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101968:	a1 70 04 1e f0       	mov    0xf01e0470,%eax
f010196d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101970:	c7 05 70 04 1e f0 00 	movl   $0x0,0xf01e0470
f0101977:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010197a:	83 ec 0c             	sub    $0xc,%esp
f010197d:	6a 00                	push   $0x0
f010197f:	e8 76 fa ff ff       	call   f01013fa <page_alloc>
f0101984:	83 c4 10             	add    $0x10,%esp
f0101987:	85 c0                	test   %eax,%eax
f0101989:	74 19                	je     f01019a4 <mem_init+0x2d3>
f010198b:	68 49 5f 10 f0       	push   $0xf0105f49
f0101990:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101995:	68 ad 02 00 00       	push   $0x2ad
f010199a:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010199f:	e8 2e e7 ff ff       	call   f01000d2 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01019a4:	83 ec 0c             	sub    $0xc,%esp
f01019a7:	56                   	push   %esi
f01019a8:	e8 d7 fa ff ff       	call   f0101484 <page_free>
	page_free(pp1);
f01019ad:	89 3c 24             	mov    %edi,(%esp)
f01019b0:	e8 cf fa ff ff       	call   f0101484 <page_free>
	page_free(pp2);
f01019b5:	83 c4 04             	add    $0x4,%esp
f01019b8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019bb:	e8 c4 fa ff ff       	call   f0101484 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019c7:	e8 2e fa ff ff       	call   f01013fa <page_alloc>
f01019cc:	89 c6                	mov    %eax,%esi
f01019ce:	83 c4 10             	add    $0x10,%esp
f01019d1:	85 c0                	test   %eax,%eax
f01019d3:	75 19                	jne    f01019ee <mem_init+0x31d>
f01019d5:	68 9e 5e 10 f0       	push   $0xf0105e9e
f01019da:	68 f3 5d 10 f0       	push   $0xf0105df3
f01019df:	68 b4 02 00 00       	push   $0x2b4
f01019e4:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01019e9:	e8 e4 e6 ff ff       	call   f01000d2 <_panic>
	assert((pp1 = page_alloc(0)));
f01019ee:	83 ec 0c             	sub    $0xc,%esp
f01019f1:	6a 00                	push   $0x0
f01019f3:	e8 02 fa ff ff       	call   f01013fa <page_alloc>
f01019f8:	89 c7                	mov    %eax,%edi
f01019fa:	83 c4 10             	add    $0x10,%esp
f01019fd:	85 c0                	test   %eax,%eax
f01019ff:	75 19                	jne    f0101a1a <mem_init+0x349>
f0101a01:	68 b4 5e 10 f0       	push   $0xf0105eb4
f0101a06:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101a0b:	68 b5 02 00 00       	push   $0x2b5
f0101a10:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101a15:	e8 b8 e6 ff ff       	call   f01000d2 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a1a:	83 ec 0c             	sub    $0xc,%esp
f0101a1d:	6a 00                	push   $0x0
f0101a1f:	e8 d6 f9 ff ff       	call   f01013fa <page_alloc>
f0101a24:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a27:	83 c4 10             	add    $0x10,%esp
f0101a2a:	85 c0                	test   %eax,%eax
f0101a2c:	75 19                	jne    f0101a47 <mem_init+0x376>
f0101a2e:	68 ca 5e 10 f0       	push   $0xf0105eca
f0101a33:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101a38:	68 b6 02 00 00       	push   $0x2b6
f0101a3d:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101a42:	e8 8b e6 ff ff       	call   f01000d2 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a47:	39 fe                	cmp    %edi,%esi
f0101a49:	75 19                	jne    f0101a64 <mem_init+0x393>
f0101a4b:	68 e0 5e 10 f0       	push   $0xf0105ee0
f0101a50:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101a55:	68 b8 02 00 00       	push   $0x2b8
f0101a5a:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101a5f:	e8 6e e6 ff ff       	call   f01000d2 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a64:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101a67:	74 05                	je     f0101a6e <mem_init+0x39d>
f0101a69:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101a6c:	75 19                	jne    f0101a87 <mem_init+0x3b6>
f0101a6e:	68 b0 57 10 f0       	push   $0xf01057b0
f0101a73:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101a78:	68 b9 02 00 00       	push   $0x2b9
f0101a7d:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101a82:	e8 4b e6 ff ff       	call   f01000d2 <_panic>
	assert(!page_alloc(0));
f0101a87:	83 ec 0c             	sub    $0xc,%esp
f0101a8a:	6a 00                	push   $0x0
f0101a8c:	e8 69 f9 ff ff       	call   f01013fa <page_alloc>
f0101a91:	83 c4 10             	add    $0x10,%esp
f0101a94:	85 c0                	test   %eax,%eax
f0101a96:	74 19                	je     f0101ab1 <mem_init+0x3e0>
f0101a98:	68 49 5f 10 f0       	push   $0xf0105f49
f0101a9d:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101aa2:	68 ba 02 00 00       	push   $0x2ba
f0101aa7:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101aac:	e8 21 e6 ff ff       	call   f01000d2 <_panic>
f0101ab1:	89 f0                	mov    %esi,%eax
f0101ab3:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0101ab9:	c1 f8 03             	sar    $0x3,%eax
f0101abc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101abf:	89 c2                	mov    %eax,%edx
f0101ac1:	c1 ea 0c             	shr    $0xc,%edx
f0101ac4:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0101aca:	72 12                	jb     f0101ade <mem_init+0x40d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101acc:	50                   	push   %eax
f0101acd:	68 6c 56 10 f0       	push   $0xf010566c
f0101ad2:	6a 56                	push   $0x56
f0101ad4:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0101ad9:	e8 f4 e5 ff ff       	call   f01000d2 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101ade:	83 ec 04             	sub    $0x4,%esp
f0101ae1:	68 00 10 00 00       	push   $0x1000
f0101ae6:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101ae8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101aed:	50                   	push   %eax
f0101aee:	e8 86 2c 00 00       	call   f0104779 <memset>
	page_free(pp0);
f0101af3:	89 34 24             	mov    %esi,(%esp)
f0101af6:	e8 89 f9 ff ff       	call   f0101484 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101afb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b02:	e8 f3 f8 ff ff       	call   f01013fa <page_alloc>
f0101b07:	83 c4 10             	add    $0x10,%esp
f0101b0a:	85 c0                	test   %eax,%eax
f0101b0c:	75 19                	jne    f0101b27 <mem_init+0x456>
f0101b0e:	68 58 5f 10 f0       	push   $0xf0105f58
f0101b13:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101b18:	68 bf 02 00 00       	push   $0x2bf
f0101b1d:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101b22:	e8 ab e5 ff ff       	call   f01000d2 <_panic>
	assert(pp && pp0 == pp);
f0101b27:	39 c6                	cmp    %eax,%esi
f0101b29:	74 19                	je     f0101b44 <mem_init+0x473>
f0101b2b:	68 76 5f 10 f0       	push   $0xf0105f76
f0101b30:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101b35:	68 c0 02 00 00       	push   $0x2c0
f0101b3a:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101b3f:	e8 8e e5 ff ff       	call   f01000d2 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b44:	89 f2                	mov    %esi,%edx
f0101b46:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101b4c:	c1 fa 03             	sar    $0x3,%edx
f0101b4f:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b52:	89 d0                	mov    %edx,%eax
f0101b54:	c1 e8 0c             	shr    $0xc,%eax
f0101b57:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f0101b5d:	72 12                	jb     f0101b71 <mem_init+0x4a0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b5f:	52                   	push   %edx
f0101b60:	68 6c 56 10 f0       	push   $0xf010566c
f0101b65:	6a 56                	push   $0x56
f0101b67:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0101b6c:	e8 61 e5 ff ff       	call   f01000d2 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b71:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101b78:	75 11                	jne    f0101b8b <mem_init+0x4ba>
f0101b7a:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101b80:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b86:	80 38 00             	cmpb   $0x0,(%eax)
f0101b89:	74 19                	je     f0101ba4 <mem_init+0x4d3>
f0101b8b:	68 86 5f 10 f0       	push   $0xf0105f86
f0101b90:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101b95:	68 c3 02 00 00       	push   $0x2c3
f0101b9a:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101b9f:	e8 2e e5 ff ff       	call   f01000d2 <_panic>
f0101ba4:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101ba5:	39 d0                	cmp    %edx,%eax
f0101ba7:	75 dd                	jne    f0101b86 <mem_init+0x4b5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101ba9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101bac:	89 0d 70 04 1e f0    	mov    %ecx,0xf01e0470

	// free the pages we took
	page_free(pp0);
f0101bb2:	83 ec 0c             	sub    $0xc,%esp
f0101bb5:	56                   	push   %esi
f0101bb6:	e8 c9 f8 ff ff       	call   f0101484 <page_free>
	page_free(pp1);
f0101bbb:	89 3c 24             	mov    %edi,(%esp)
f0101bbe:	e8 c1 f8 ff ff       	call   f0101484 <page_free>
	page_free(pp2);
f0101bc3:	83 c4 04             	add    $0x4,%esp
f0101bc6:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bc9:	e8 b6 f8 ff ff       	call   f0101484 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101bce:	a1 70 04 1e f0       	mov    0xf01e0470,%eax
f0101bd3:	83 c4 10             	add    $0x10,%esp
f0101bd6:	85 c0                	test   %eax,%eax
f0101bd8:	74 07                	je     f0101be1 <mem_init+0x510>
		--nfree;
f0101bda:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101bdb:	8b 00                	mov    (%eax),%eax
f0101bdd:	85 c0                	test   %eax,%eax
f0101bdf:	75 f9                	jne    f0101bda <mem_init+0x509>
		--nfree;
	assert(nfree == 0);
f0101be1:	85 db                	test   %ebx,%ebx
f0101be3:	74 19                	je     f0101bfe <mem_init+0x52d>
f0101be5:	68 90 5f 10 f0       	push   $0xf0105f90
f0101bea:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101bef:	68 d0 02 00 00       	push   $0x2d0
f0101bf4:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101bf9:	e8 d4 e4 ff ff       	call   f01000d2 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101bfe:	83 ec 0c             	sub    $0xc,%esp
f0101c01:	68 d0 57 10 f0       	push   $0xf01057d0
f0101c06:	e8 46 19 00 00       	call   f0103551 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c12:	e8 e3 f7 ff ff       	call   f01013fa <page_alloc>
f0101c17:	89 c7                	mov    %eax,%edi
f0101c19:	83 c4 10             	add    $0x10,%esp
f0101c1c:	85 c0                	test   %eax,%eax
f0101c1e:	75 19                	jne    f0101c39 <mem_init+0x568>
f0101c20:	68 9e 5e 10 f0       	push   $0xf0105e9e
f0101c25:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101c2a:	68 2e 03 00 00       	push   $0x32e
f0101c2f:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101c34:	e8 99 e4 ff ff       	call   f01000d2 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c39:	83 ec 0c             	sub    $0xc,%esp
f0101c3c:	6a 00                	push   $0x0
f0101c3e:	e8 b7 f7 ff ff       	call   f01013fa <page_alloc>
f0101c43:	89 c6                	mov    %eax,%esi
f0101c45:	83 c4 10             	add    $0x10,%esp
f0101c48:	85 c0                	test   %eax,%eax
f0101c4a:	75 19                	jne    f0101c65 <mem_init+0x594>
f0101c4c:	68 b4 5e 10 f0       	push   $0xf0105eb4
f0101c51:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101c56:	68 2f 03 00 00       	push   $0x32f
f0101c5b:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101c60:	e8 6d e4 ff ff       	call   f01000d2 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c65:	83 ec 0c             	sub    $0xc,%esp
f0101c68:	6a 00                	push   $0x0
f0101c6a:	e8 8b f7 ff ff       	call   f01013fa <page_alloc>
f0101c6f:	89 c3                	mov    %eax,%ebx
f0101c71:	83 c4 10             	add    $0x10,%esp
f0101c74:	85 c0                	test   %eax,%eax
f0101c76:	75 19                	jne    f0101c91 <mem_init+0x5c0>
f0101c78:	68 ca 5e 10 f0       	push   $0xf0105eca
f0101c7d:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101c82:	68 30 03 00 00       	push   $0x330
f0101c87:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101c8c:	e8 41 e4 ff ff       	call   f01000d2 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c91:	39 f7                	cmp    %esi,%edi
f0101c93:	75 19                	jne    f0101cae <mem_init+0x5dd>
f0101c95:	68 e0 5e 10 f0       	push   $0xf0105ee0
f0101c9a:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101c9f:	68 33 03 00 00       	push   $0x333
f0101ca4:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101ca9:	e8 24 e4 ff ff       	call   f01000d2 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cae:	39 c6                	cmp    %eax,%esi
f0101cb0:	74 04                	je     f0101cb6 <mem_init+0x5e5>
f0101cb2:	39 c7                	cmp    %eax,%edi
f0101cb4:	75 19                	jne    f0101ccf <mem_init+0x5fe>
f0101cb6:	68 b0 57 10 f0       	push   $0xf01057b0
f0101cbb:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101cc0:	68 34 03 00 00       	push   $0x334
f0101cc5:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101cca:	e8 03 e4 ff ff       	call   f01000d2 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ccf:	a1 70 04 1e f0       	mov    0xf01e0470,%eax
f0101cd4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	page_free_list = 0;
f0101cd7:	c7 05 70 04 1e f0 00 	movl   $0x0,0xf01e0470
f0101cde:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ce1:	83 ec 0c             	sub    $0xc,%esp
f0101ce4:	6a 00                	push   $0x0
f0101ce6:	e8 0f f7 ff ff       	call   f01013fa <page_alloc>
f0101ceb:	83 c4 10             	add    $0x10,%esp
f0101cee:	85 c0                	test   %eax,%eax
f0101cf0:	74 19                	je     f0101d0b <mem_init+0x63a>
f0101cf2:	68 49 5f 10 f0       	push   $0xf0105f49
f0101cf7:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101cfc:	68 3b 03 00 00       	push   $0x33b
f0101d01:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101d06:	e8 c7 e3 ff ff       	call   f01000d2 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101d0b:	83 ec 04             	sub    $0x4,%esp
f0101d0e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d11:	50                   	push   %eax
f0101d12:	6a 00                	push   $0x0
f0101d14:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101d1a:	e8 8b f8 ff ff       	call   f01015aa <page_lookup>
f0101d1f:	83 c4 10             	add    $0x10,%esp
f0101d22:	85 c0                	test   %eax,%eax
f0101d24:	74 19                	je     f0101d3f <mem_init+0x66e>
f0101d26:	68 f0 57 10 f0       	push   $0xf01057f0
f0101d2b:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101d30:	68 3e 03 00 00       	push   $0x33e
f0101d35:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101d3a:	e8 93 e3 ff ff       	call   f01000d2 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d3f:	6a 02                	push   $0x2
f0101d41:	6a 00                	push   $0x0
f0101d43:	56                   	push   %esi
f0101d44:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101d4a:	e8 19 f9 ff ff       	call   f0101668 <page_insert>
f0101d4f:	83 c4 10             	add    $0x10,%esp
f0101d52:	85 c0                	test   %eax,%eax
f0101d54:	78 19                	js     f0101d6f <mem_init+0x69e>
f0101d56:	68 28 58 10 f0       	push   $0xf0105828
f0101d5b:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101d60:	68 41 03 00 00       	push   $0x341
f0101d65:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101d6a:	e8 63 e3 ff ff       	call   f01000d2 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d6f:	83 ec 0c             	sub    $0xc,%esp
f0101d72:	57                   	push   %edi
f0101d73:	e8 0c f7 ff ff       	call   f0101484 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d78:	6a 02                	push   $0x2
f0101d7a:	6a 00                	push   $0x0
f0101d7c:	56                   	push   %esi
f0101d7d:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101d83:	e8 e0 f8 ff ff       	call   f0101668 <page_insert>
f0101d88:	83 c4 20             	add    $0x20,%esp
f0101d8b:	85 c0                	test   %eax,%eax
f0101d8d:	74 19                	je     f0101da8 <mem_init+0x6d7>
f0101d8f:	68 58 58 10 f0       	push   $0xf0105858
f0101d94:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101d99:	68 45 03 00 00       	push   $0x345
f0101d9e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101da3:	e8 2a e3 ff ff       	call   f01000d2 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101da8:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0101dad:	8b 08                	mov    (%eax),%ecx
f0101daf:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101db5:	89 fa                	mov    %edi,%edx
f0101db7:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101dbd:	c1 fa 03             	sar    $0x3,%edx
f0101dc0:	c1 e2 0c             	shl    $0xc,%edx
f0101dc3:	39 d1                	cmp    %edx,%ecx
f0101dc5:	74 19                	je     f0101de0 <mem_init+0x70f>
f0101dc7:	68 88 58 10 f0       	push   $0xf0105888
f0101dcc:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101dd1:	68 46 03 00 00       	push   $0x346
f0101dd6:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101ddb:	e8 f2 e2 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101de0:	ba 00 00 00 00       	mov    $0x0,%edx
f0101de5:	e8 21 f2 ff ff       	call   f010100b <check_va2pa>
f0101dea:	89 f2                	mov    %esi,%edx
f0101dec:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101df2:	c1 fa 03             	sar    $0x3,%edx
f0101df5:	c1 e2 0c             	shl    $0xc,%edx
f0101df8:	39 d0                	cmp    %edx,%eax
f0101dfa:	74 19                	je     f0101e15 <mem_init+0x744>
f0101dfc:	68 b0 58 10 f0       	push   $0xf01058b0
f0101e01:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101e06:	68 47 03 00 00       	push   $0x347
f0101e0b:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101e10:	e8 bd e2 ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 1);
f0101e15:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e1a:	74 19                	je     f0101e35 <mem_init+0x764>
f0101e1c:	68 9b 5f 10 f0       	push   $0xf0105f9b
f0101e21:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101e26:	68 48 03 00 00       	push   $0x348
f0101e2b:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101e30:	e8 9d e2 ff ff       	call   f01000d2 <_panic>
	assert(pp0->pp_ref == 1);
f0101e35:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e3a:	74 19                	je     f0101e55 <mem_init+0x784>
f0101e3c:	68 ac 5f 10 f0       	push   $0xf0105fac
f0101e41:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101e46:	68 49 03 00 00       	push   $0x349
f0101e4b:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101e50:	e8 7d e2 ff ff       	call   f01000d2 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e55:	6a 02                	push   $0x2
f0101e57:	68 00 10 00 00       	push   $0x1000
f0101e5c:	53                   	push   %ebx
f0101e5d:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101e63:	e8 00 f8 ff ff       	call   f0101668 <page_insert>
f0101e68:	83 c4 10             	add    $0x10,%esp
f0101e6b:	85 c0                	test   %eax,%eax
f0101e6d:	74 19                	je     f0101e88 <mem_init+0x7b7>
f0101e6f:	68 e0 58 10 f0       	push   $0xf01058e0
f0101e74:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101e79:	68 4c 03 00 00       	push   $0x34c
f0101e7e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101e83:	e8 4a e2 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e88:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e8d:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0101e92:	e8 74 f1 ff ff       	call   f010100b <check_va2pa>
f0101e97:	89 da                	mov    %ebx,%edx
f0101e99:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101e9f:	c1 fa 03             	sar    $0x3,%edx
f0101ea2:	c1 e2 0c             	shl    $0xc,%edx
f0101ea5:	39 d0                	cmp    %edx,%eax
f0101ea7:	74 19                	je     f0101ec2 <mem_init+0x7f1>
f0101ea9:	68 1c 59 10 f0       	push   $0xf010591c
f0101eae:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101eb3:	68 4d 03 00 00       	push   $0x34d
f0101eb8:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101ebd:	e8 10 e2 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f0101ec2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ec7:	74 19                	je     f0101ee2 <mem_init+0x811>
f0101ec9:	68 bd 5f 10 f0       	push   $0xf0105fbd
f0101ece:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101ed3:	68 4e 03 00 00       	push   $0x34e
f0101ed8:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101edd:	e8 f0 e1 ff ff       	call   f01000d2 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ee2:	83 ec 0c             	sub    $0xc,%esp
f0101ee5:	6a 00                	push   $0x0
f0101ee7:	e8 0e f5 ff ff       	call   f01013fa <page_alloc>
f0101eec:	83 c4 10             	add    $0x10,%esp
f0101eef:	85 c0                	test   %eax,%eax
f0101ef1:	74 19                	je     f0101f0c <mem_init+0x83b>
f0101ef3:	68 49 5f 10 f0       	push   $0xf0105f49
f0101ef8:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101efd:	68 51 03 00 00       	push   $0x351
f0101f02:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101f07:	e8 c6 e1 ff ff       	call   f01000d2 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f0c:	6a 02                	push   $0x2
f0101f0e:	68 00 10 00 00       	push   $0x1000
f0101f13:	53                   	push   %ebx
f0101f14:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101f1a:	e8 49 f7 ff ff       	call   f0101668 <page_insert>
f0101f1f:	83 c4 10             	add    $0x10,%esp
f0101f22:	85 c0                	test   %eax,%eax
f0101f24:	74 19                	je     f0101f3f <mem_init+0x86e>
f0101f26:	68 e0 58 10 f0       	push   $0xf01058e0
f0101f2b:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101f30:	68 54 03 00 00       	push   $0x354
f0101f35:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101f3a:	e8 93 e1 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f3f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f44:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0101f49:	e8 bd f0 ff ff       	call   f010100b <check_va2pa>
f0101f4e:	89 da                	mov    %ebx,%edx
f0101f50:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101f56:	c1 fa 03             	sar    $0x3,%edx
f0101f59:	c1 e2 0c             	shl    $0xc,%edx
f0101f5c:	39 d0                	cmp    %edx,%eax
f0101f5e:	74 19                	je     f0101f79 <mem_init+0x8a8>
f0101f60:	68 1c 59 10 f0       	push   $0xf010591c
f0101f65:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101f6a:	68 55 03 00 00       	push   $0x355
f0101f6f:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101f74:	e8 59 e1 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f0101f79:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f7e:	74 19                	je     f0101f99 <mem_init+0x8c8>
f0101f80:	68 bd 5f 10 f0       	push   $0xf0105fbd
f0101f85:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101f8a:	68 56 03 00 00       	push   $0x356
f0101f8f:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101f94:	e8 39 e1 ff ff       	call   f01000d2 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f99:	83 ec 0c             	sub    $0xc,%esp
f0101f9c:	6a 00                	push   $0x0
f0101f9e:	e8 57 f4 ff ff       	call   f01013fa <page_alloc>
f0101fa3:	83 c4 10             	add    $0x10,%esp
f0101fa6:	85 c0                	test   %eax,%eax
f0101fa8:	74 19                	je     f0101fc3 <mem_init+0x8f2>
f0101faa:	68 49 5f 10 f0       	push   $0xf0105f49
f0101faf:	68 f3 5d 10 f0       	push   $0xf0105df3
f0101fb4:	68 5a 03 00 00       	push   $0x35a
f0101fb9:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101fbe:	e8 0f e1 ff ff       	call   f01000d2 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101fc3:	8b 15 48 11 1e f0    	mov    0xf01e1148,%edx
f0101fc9:	8b 02                	mov    (%edx),%eax
f0101fcb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fd0:	89 c1                	mov    %eax,%ecx
f0101fd2:	c1 e9 0c             	shr    $0xc,%ecx
f0101fd5:	3b 0d 44 11 1e f0    	cmp    0xf01e1144,%ecx
f0101fdb:	72 15                	jb     f0101ff2 <mem_init+0x921>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fdd:	50                   	push   %eax
f0101fde:	68 6c 56 10 f0       	push   $0xf010566c
f0101fe3:	68 5d 03 00 00       	push   $0x35d
f0101fe8:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0101fed:	e8 e0 e0 ff ff       	call   f01000d2 <_panic>
	return (void *)(pa + KERNBASE);
f0101ff2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ff7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ffa:	83 ec 04             	sub    $0x4,%esp
f0101ffd:	6a 00                	push   $0x0
f0101fff:	68 00 10 00 00       	push   $0x1000
f0102004:	52                   	push   %edx
f0102005:	e8 b8 f4 ff ff       	call   f01014c2 <pgdir_walk>
f010200a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010200d:	83 c2 04             	add    $0x4,%edx
f0102010:	83 c4 10             	add    $0x10,%esp
f0102013:	39 d0                	cmp    %edx,%eax
f0102015:	74 19                	je     f0102030 <mem_init+0x95f>
f0102017:	68 4c 59 10 f0       	push   $0xf010594c
f010201c:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102021:	68 5e 03 00 00       	push   $0x35e
f0102026:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010202b:	e8 a2 e0 ff ff       	call   f01000d2 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102030:	6a 06                	push   $0x6
f0102032:	68 00 10 00 00       	push   $0x1000
f0102037:	53                   	push   %ebx
f0102038:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f010203e:	e8 25 f6 ff ff       	call   f0101668 <page_insert>
f0102043:	83 c4 10             	add    $0x10,%esp
f0102046:	85 c0                	test   %eax,%eax
f0102048:	74 19                	je     f0102063 <mem_init+0x992>
f010204a:	68 8c 59 10 f0       	push   $0xf010598c
f010204f:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102054:	68 61 03 00 00       	push   $0x361
f0102059:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010205e:	e8 6f e0 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102063:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102068:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f010206d:	e8 99 ef ff ff       	call   f010100b <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102072:	89 da                	mov    %ebx,%edx
f0102074:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f010207a:	c1 fa 03             	sar    $0x3,%edx
f010207d:	c1 e2 0c             	shl    $0xc,%edx
f0102080:	39 d0                	cmp    %edx,%eax
f0102082:	74 19                	je     f010209d <mem_init+0x9cc>
f0102084:	68 1c 59 10 f0       	push   $0xf010591c
f0102089:	68 f3 5d 10 f0       	push   $0xf0105df3
f010208e:	68 62 03 00 00       	push   $0x362
f0102093:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102098:	e8 35 e0 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f010209d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020a2:	74 19                	je     f01020bd <mem_init+0x9ec>
f01020a4:	68 bd 5f 10 f0       	push   $0xf0105fbd
f01020a9:	68 f3 5d 10 f0       	push   $0xf0105df3
f01020ae:	68 63 03 00 00       	push   $0x363
f01020b3:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01020b8:	e8 15 e0 ff ff       	call   f01000d2 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01020bd:	83 ec 04             	sub    $0x4,%esp
f01020c0:	6a 00                	push   $0x0
f01020c2:	68 00 10 00 00       	push   $0x1000
f01020c7:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f01020cd:	e8 f0 f3 ff ff       	call   f01014c2 <pgdir_walk>
f01020d2:	83 c4 10             	add    $0x10,%esp
f01020d5:	f6 00 04             	testb  $0x4,(%eax)
f01020d8:	75 19                	jne    f01020f3 <mem_init+0xa22>
f01020da:	68 cc 59 10 f0       	push   $0xf01059cc
f01020df:	68 f3 5d 10 f0       	push   $0xf0105df3
f01020e4:	68 64 03 00 00       	push   $0x364
f01020e9:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01020ee:	e8 df df ff ff       	call   f01000d2 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01020f3:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01020f8:	f6 00 04             	testb  $0x4,(%eax)
f01020fb:	75 19                	jne    f0102116 <mem_init+0xa45>
f01020fd:	68 ce 5f 10 f0       	push   $0xf0105fce
f0102102:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102107:	68 65 03 00 00       	push   $0x365
f010210c:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102111:	e8 bc df ff ff       	call   f01000d2 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102116:	6a 02                	push   $0x2
f0102118:	68 00 10 00 00       	push   $0x1000
f010211d:	53                   	push   %ebx
f010211e:	50                   	push   %eax
f010211f:	e8 44 f5 ff ff       	call   f0101668 <page_insert>
f0102124:	83 c4 10             	add    $0x10,%esp
f0102127:	85 c0                	test   %eax,%eax
f0102129:	74 19                	je     f0102144 <mem_init+0xa73>
f010212b:	68 e0 58 10 f0       	push   $0xf01058e0
f0102130:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102135:	68 68 03 00 00       	push   $0x368
f010213a:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010213f:	e8 8e df ff ff       	call   f01000d2 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102144:	83 ec 04             	sub    $0x4,%esp
f0102147:	6a 00                	push   $0x0
f0102149:	68 00 10 00 00       	push   $0x1000
f010214e:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102154:	e8 69 f3 ff ff       	call   f01014c2 <pgdir_walk>
f0102159:	83 c4 10             	add    $0x10,%esp
f010215c:	f6 00 02             	testb  $0x2,(%eax)
f010215f:	75 19                	jne    f010217a <mem_init+0xaa9>
f0102161:	68 00 5a 10 f0       	push   $0xf0105a00
f0102166:	68 f3 5d 10 f0       	push   $0xf0105df3
f010216b:	68 69 03 00 00       	push   $0x369
f0102170:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102175:	e8 58 df ff ff       	call   f01000d2 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010217a:	83 ec 04             	sub    $0x4,%esp
f010217d:	6a 00                	push   $0x0
f010217f:	68 00 10 00 00       	push   $0x1000
f0102184:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f010218a:	e8 33 f3 ff ff       	call   f01014c2 <pgdir_walk>
f010218f:	83 c4 10             	add    $0x10,%esp
f0102192:	f6 00 04             	testb  $0x4,(%eax)
f0102195:	74 19                	je     f01021b0 <mem_init+0xadf>
f0102197:	68 34 5a 10 f0       	push   $0xf0105a34
f010219c:	68 f3 5d 10 f0       	push   $0xf0105df3
f01021a1:	68 6a 03 00 00       	push   $0x36a
f01021a6:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01021ab:	e8 22 df ff ff       	call   f01000d2 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01021b0:	6a 02                	push   $0x2
f01021b2:	68 00 00 40 00       	push   $0x400000
f01021b7:	57                   	push   %edi
f01021b8:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f01021be:	e8 a5 f4 ff ff       	call   f0101668 <page_insert>
f01021c3:	83 c4 10             	add    $0x10,%esp
f01021c6:	85 c0                	test   %eax,%eax
f01021c8:	78 19                	js     f01021e3 <mem_init+0xb12>
f01021ca:	68 6c 5a 10 f0       	push   $0xf0105a6c
f01021cf:	68 f3 5d 10 f0       	push   $0xf0105df3
f01021d4:	68 6d 03 00 00       	push   $0x36d
f01021d9:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01021de:	e8 ef de ff ff       	call   f01000d2 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01021e3:	6a 02                	push   $0x2
f01021e5:	68 00 10 00 00       	push   $0x1000
f01021ea:	56                   	push   %esi
f01021eb:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f01021f1:	e8 72 f4 ff ff       	call   f0101668 <page_insert>
f01021f6:	83 c4 10             	add    $0x10,%esp
f01021f9:	85 c0                	test   %eax,%eax
f01021fb:	74 19                	je     f0102216 <mem_init+0xb45>
f01021fd:	68 a4 5a 10 f0       	push   $0xf0105aa4
f0102202:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102207:	68 70 03 00 00       	push   $0x370
f010220c:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102211:	e8 bc de ff ff       	call   f01000d2 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102216:	83 ec 04             	sub    $0x4,%esp
f0102219:	6a 00                	push   $0x0
f010221b:	68 00 10 00 00       	push   $0x1000
f0102220:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102226:	e8 97 f2 ff ff       	call   f01014c2 <pgdir_walk>
f010222b:	83 c4 10             	add    $0x10,%esp
f010222e:	f6 00 04             	testb  $0x4,(%eax)
f0102231:	74 19                	je     f010224c <mem_init+0xb7b>
f0102233:	68 34 5a 10 f0       	push   $0xf0105a34
f0102238:	68 f3 5d 10 f0       	push   $0xf0105df3
f010223d:	68 71 03 00 00       	push   $0x371
f0102242:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102247:	e8 86 de ff ff       	call   f01000d2 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010224c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102251:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102256:	e8 b0 ed ff ff       	call   f010100b <check_va2pa>
f010225b:	89 f2                	mov    %esi,%edx
f010225d:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0102263:	c1 fa 03             	sar    $0x3,%edx
f0102266:	c1 e2 0c             	shl    $0xc,%edx
f0102269:	39 d0                	cmp    %edx,%eax
f010226b:	74 19                	je     f0102286 <mem_init+0xbb5>
f010226d:	68 e0 5a 10 f0       	push   $0xf0105ae0
f0102272:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102277:	68 74 03 00 00       	push   $0x374
f010227c:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102281:	e8 4c de ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102286:	ba 00 10 00 00       	mov    $0x1000,%edx
f010228b:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102290:	e8 76 ed ff ff       	call   f010100b <check_va2pa>
f0102295:	89 f2                	mov    %esi,%edx
f0102297:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f010229d:	c1 fa 03             	sar    $0x3,%edx
f01022a0:	c1 e2 0c             	shl    $0xc,%edx
f01022a3:	39 d0                	cmp    %edx,%eax
f01022a5:	74 19                	je     f01022c0 <mem_init+0xbef>
f01022a7:	68 0c 5b 10 f0       	push   $0xf0105b0c
f01022ac:	68 f3 5d 10 f0       	push   $0xf0105df3
f01022b1:	68 75 03 00 00       	push   $0x375
f01022b6:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01022bb:	e8 12 de ff ff       	call   f01000d2 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01022c0:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f01022c5:	74 19                	je     f01022e0 <mem_init+0xc0f>
f01022c7:	68 e4 5f 10 f0       	push   $0xf0105fe4
f01022cc:	68 f3 5d 10 f0       	push   $0xf0105df3
f01022d1:	68 77 03 00 00       	push   $0x377
f01022d6:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01022db:	e8 f2 dd ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 0);
f01022e0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022e5:	74 19                	je     f0102300 <mem_init+0xc2f>
f01022e7:	68 f5 5f 10 f0       	push   $0xf0105ff5
f01022ec:	68 f3 5d 10 f0       	push   $0xf0105df3
f01022f1:	68 78 03 00 00       	push   $0x378
f01022f6:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01022fb:	e8 d2 dd ff ff       	call   f01000d2 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102300:	83 ec 0c             	sub    $0xc,%esp
f0102303:	6a 00                	push   $0x0
f0102305:	e8 f0 f0 ff ff       	call   f01013fa <page_alloc>
f010230a:	83 c4 10             	add    $0x10,%esp
f010230d:	85 c0                	test   %eax,%eax
f010230f:	74 04                	je     f0102315 <mem_init+0xc44>
f0102311:	39 c3                	cmp    %eax,%ebx
f0102313:	74 19                	je     f010232e <mem_init+0xc5d>
f0102315:	68 3c 5b 10 f0       	push   $0xf0105b3c
f010231a:	68 f3 5d 10 f0       	push   $0xf0105df3
f010231f:	68 7b 03 00 00       	push   $0x37b
f0102324:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102329:	e8 a4 dd ff ff       	call   f01000d2 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010232e:	83 ec 08             	sub    $0x8,%esp
f0102331:	6a 00                	push   $0x0
f0102333:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102339:	e8 dd f2 ff ff       	call   f010161b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010233e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102343:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102348:	e8 be ec ff ff       	call   f010100b <check_va2pa>
f010234d:	83 c4 10             	add    $0x10,%esp
f0102350:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102353:	74 19                	je     f010236e <mem_init+0xc9d>
f0102355:	68 60 5b 10 f0       	push   $0xf0105b60
f010235a:	68 f3 5d 10 f0       	push   $0xf0105df3
f010235f:	68 7f 03 00 00       	push   $0x37f
f0102364:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102369:	e8 64 dd ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010236e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102373:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102378:	e8 8e ec ff ff       	call   f010100b <check_va2pa>
f010237d:	89 f2                	mov    %esi,%edx
f010237f:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0102385:	c1 fa 03             	sar    $0x3,%edx
f0102388:	c1 e2 0c             	shl    $0xc,%edx
f010238b:	39 d0                	cmp    %edx,%eax
f010238d:	74 19                	je     f01023a8 <mem_init+0xcd7>
f010238f:	68 0c 5b 10 f0       	push   $0xf0105b0c
f0102394:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102399:	68 80 03 00 00       	push   $0x380
f010239e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01023a3:	e8 2a dd ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 1);
f01023a8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01023ad:	74 19                	je     f01023c8 <mem_init+0xcf7>
f01023af:	68 9b 5f 10 f0       	push   $0xf0105f9b
f01023b4:	68 f3 5d 10 f0       	push   $0xf0105df3
f01023b9:	68 81 03 00 00       	push   $0x381
f01023be:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01023c3:	e8 0a dd ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 0);
f01023c8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023cd:	74 19                	je     f01023e8 <mem_init+0xd17>
f01023cf:	68 f5 5f 10 f0       	push   $0xf0105ff5
f01023d4:	68 f3 5d 10 f0       	push   $0xf0105df3
f01023d9:	68 82 03 00 00       	push   $0x382
f01023de:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01023e3:	e8 ea dc ff ff       	call   f01000d2 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01023e8:	83 ec 08             	sub    $0x8,%esp
f01023eb:	68 00 10 00 00       	push   $0x1000
f01023f0:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f01023f6:	e8 20 f2 ff ff       	call   f010161b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023fb:	ba 00 00 00 00       	mov    $0x0,%edx
f0102400:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102405:	e8 01 ec ff ff       	call   f010100b <check_va2pa>
f010240a:	83 c4 10             	add    $0x10,%esp
f010240d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102410:	74 19                	je     f010242b <mem_init+0xd5a>
f0102412:	68 60 5b 10 f0       	push   $0xf0105b60
f0102417:	68 f3 5d 10 f0       	push   $0xf0105df3
f010241c:	68 86 03 00 00       	push   $0x386
f0102421:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102426:	e8 a7 dc ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010242b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102430:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102435:	e8 d1 eb ff ff       	call   f010100b <check_va2pa>
f010243a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010243d:	74 19                	je     f0102458 <mem_init+0xd87>
f010243f:	68 84 5b 10 f0       	push   $0xf0105b84
f0102444:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102449:	68 87 03 00 00       	push   $0x387
f010244e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102453:	e8 7a dc ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 0);
f0102458:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010245d:	74 19                	je     f0102478 <mem_init+0xda7>
f010245f:	68 06 60 10 f0       	push   $0xf0106006
f0102464:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102469:	68 88 03 00 00       	push   $0x388
f010246e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102473:	e8 5a dc ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 0);
f0102478:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010247d:	74 19                	je     f0102498 <mem_init+0xdc7>
f010247f:	68 f5 5f 10 f0       	push   $0xf0105ff5
f0102484:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102489:	68 89 03 00 00       	push   $0x389
f010248e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102493:	e8 3a dc ff ff       	call   f01000d2 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102498:	83 ec 0c             	sub    $0xc,%esp
f010249b:	6a 00                	push   $0x0
f010249d:	e8 58 ef ff ff       	call   f01013fa <page_alloc>
f01024a2:	83 c4 10             	add    $0x10,%esp
f01024a5:	85 c0                	test   %eax,%eax
f01024a7:	74 04                	je     f01024ad <mem_init+0xddc>
f01024a9:	39 c6                	cmp    %eax,%esi
f01024ab:	74 19                	je     f01024c6 <mem_init+0xdf5>
f01024ad:	68 ac 5b 10 f0       	push   $0xf0105bac
f01024b2:	68 f3 5d 10 f0       	push   $0xf0105df3
f01024b7:	68 8c 03 00 00       	push   $0x38c
f01024bc:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01024c1:	e8 0c dc ff ff       	call   f01000d2 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01024c6:	83 ec 0c             	sub    $0xc,%esp
f01024c9:	6a 00                	push   $0x0
f01024cb:	e8 2a ef ff ff       	call   f01013fa <page_alloc>
f01024d0:	83 c4 10             	add    $0x10,%esp
f01024d3:	85 c0                	test   %eax,%eax
f01024d5:	74 19                	je     f01024f0 <mem_init+0xe1f>
f01024d7:	68 49 5f 10 f0       	push   $0xf0105f49
f01024dc:	68 f3 5d 10 f0       	push   $0xf0105df3
f01024e1:	68 8f 03 00 00       	push   $0x38f
f01024e6:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01024eb:	e8 e2 db ff ff       	call   f01000d2 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01024f0:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01024f5:	8b 08                	mov    (%eax),%ecx
f01024f7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01024fd:	89 fa                	mov    %edi,%edx
f01024ff:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0102505:	c1 fa 03             	sar    $0x3,%edx
f0102508:	c1 e2 0c             	shl    $0xc,%edx
f010250b:	39 d1                	cmp    %edx,%ecx
f010250d:	74 19                	je     f0102528 <mem_init+0xe57>
f010250f:	68 88 58 10 f0       	push   $0xf0105888
f0102514:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102519:	68 92 03 00 00       	push   $0x392
f010251e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102523:	e8 aa db ff ff       	call   f01000d2 <_panic>
	kern_pgdir[0] = 0;
f0102528:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010252e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102533:	74 19                	je     f010254e <mem_init+0xe7d>
f0102535:	68 ac 5f 10 f0       	push   $0xf0105fac
f010253a:	68 f3 5d 10 f0       	push   $0xf0105df3
f010253f:	68 94 03 00 00       	push   $0x394
f0102544:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102549:	e8 84 db ff ff       	call   f01000d2 <_panic>
	pp0->pp_ref = 0;

	kern_pgdir[PDX(va)] = 0;
f010254e:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102553:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102559:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
f010255f:	89 f8                	mov    %edi,%eax
f0102561:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0102567:	c1 f8 03             	sar    $0x3,%eax
f010256a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010256d:	89 c2                	mov    %eax,%edx
f010256f:	c1 ea 0c             	shr    $0xc,%edx
f0102572:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0102578:	72 12                	jb     f010258c <mem_init+0xebb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010257a:	50                   	push   %eax
f010257b:	68 6c 56 10 f0       	push   $0xf010566c
f0102580:	6a 56                	push   $0x56
f0102582:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0102587:	e8 46 db ff ff       	call   f01000d2 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010258c:	83 ec 04             	sub    $0x4,%esp
f010258f:	68 00 10 00 00       	push   $0x1000
f0102594:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102599:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010259e:	50                   	push   %eax
f010259f:	e8 d5 21 00 00       	call   f0104779 <memset>
	page_free(pp0);
f01025a4:	89 3c 24             	mov    %edi,(%esp)
f01025a7:	e8 d8 ee ff ff       	call   f0101484 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01025ac:	83 c4 0c             	add    $0xc,%esp
f01025af:	6a 01                	push   $0x1
f01025b1:	6a 00                	push   $0x0
f01025b3:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f01025b9:	e8 04 ef ff ff       	call   f01014c2 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025be:	89 fa                	mov    %edi,%edx
f01025c0:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f01025c6:	c1 fa 03             	sar    $0x3,%edx
f01025c9:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025cc:	89 d0                	mov    %edx,%eax
f01025ce:	c1 e8 0c             	shr    $0xc,%eax
f01025d1:	83 c4 10             	add    $0x10,%esp
f01025d4:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f01025da:	72 12                	jb     f01025ee <mem_init+0xf1d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025dc:	52                   	push   %edx
f01025dd:	68 6c 56 10 f0       	push   $0xf010566c
f01025e2:	6a 56                	push   $0x56
f01025e4:	68 d9 5d 10 f0       	push   $0xf0105dd9
f01025e9:	e8 e4 da ff ff       	call   f01000d2 <_panic>
	return (void *)(pa + KERNBASE);
f01025ee:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01025f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01025f7:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f01025fe:	75 11                	jne    f0102611 <mem_init+0xf40>
f0102600:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102606:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010260c:	f6 00 01             	testb  $0x1,(%eax)
f010260f:	74 19                	je     f010262a <mem_init+0xf59>
f0102611:	68 17 60 10 f0       	push   $0xf0106017
f0102616:	68 f3 5d 10 f0       	push   $0xf0105df3
f010261b:	68 a0 03 00 00       	push   $0x3a0
f0102620:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102625:	e8 a8 da ff ff       	call   f01000d2 <_panic>
f010262a:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010262d:	39 d0                	cmp    %edx,%eax
f010262f:	75 db                	jne    f010260c <mem_init+0xf3b>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102631:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102636:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010263c:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102642:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102645:	89 0d 70 04 1e f0    	mov    %ecx,0xf01e0470

	// free the pages we took
	page_free(pp0);
f010264b:	83 ec 0c             	sub    $0xc,%esp
f010264e:	57                   	push   %edi
f010264f:	e8 30 ee ff ff       	call   f0101484 <page_free>
	page_free(pp1);
f0102654:	89 34 24             	mov    %esi,(%esp)
f0102657:	e8 28 ee ff ff       	call   f0101484 <page_free>
	page_free(pp2);
f010265c:	89 1c 24             	mov    %ebx,(%esp)
f010265f:	e8 20 ee ff ff       	call   f0101484 <page_free>

	cprintf("check_page() succeeded!\n");
f0102664:	c7 04 24 2e 60 10 f0 	movl   $0xf010602e,(%esp)
f010266b:	e8 e1 0e 00 00       	call   f0103551 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102670:	a1 4c 11 1e f0       	mov    0xf01e114c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102675:	83 c4 10             	add    $0x10,%esp
f0102678:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010267d:	77 15                	ja     f0102694 <mem_init+0xfc3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010267f:	50                   	push   %eax
f0102680:	68 a0 54 10 f0       	push   $0xf01054a0
f0102685:	68 b7 00 00 00       	push   $0xb7
f010268a:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010268f:	e8 3e da ff ff       	call   f01000d2 <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102694:	8b 15 44 11 1e f0    	mov    0xf01e1144,%edx
f010269a:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01026a1:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f01026a4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01026aa:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01026ac:	05 00 00 00 10       	add    $0x10000000,%eax
f01026b1:	50                   	push   %eax
f01026b2:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01026b7:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01026bc:	e8 98 ee ff ff       	call   f0101559 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    boot_map_region(kern_pgdir,
f01026c1:	a1 7c 04 1e f0       	mov    0xf01e047c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026c6:	83 c4 10             	add    $0x10,%esp
f01026c9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026ce:	77 15                	ja     f01026e5 <mem_init+0x1014>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d0:	50                   	push   %eax
f01026d1:	68 a0 54 10 f0       	push   $0xf01054a0
f01026d6:	68 c4 00 00 00       	push   $0xc4
f01026db:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01026e0:	e8 ed d9 ff ff       	call   f01000d2 <_panic>
f01026e5:	83 ec 08             	sub    $0x8,%esp
f01026e8:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01026ea:	05 00 00 00 10       	add    $0x10000000,%eax
f01026ef:	50                   	push   %eax
f01026f0:	b9 00 80 01 00       	mov    $0x18000,%ecx
f01026f5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01026fa:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01026ff:	e8 55 ee ff ff       	call   f0101559 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102704:	83 c4 10             	add    $0x10,%esp
f0102707:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f010270c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102711:	77 15                	ja     f0102728 <mem_init+0x1057>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102713:	50                   	push   %eax
f0102714:	68 a0 54 10 f0       	push   $0xf01054a0
f0102719:	68 d5 00 00 00       	push   $0xd5
f010271e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102723:	e8 aa d9 ff ff       	call   f01000d2 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102728:	83 ec 08             	sub    $0x8,%esp
f010272b:	6a 02                	push   $0x2
f010272d:	68 00 90 11 00       	push   $0x119000
f0102732:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102737:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010273c:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102741:	e8 13 ee ff ff       	call   f0101559 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102746:	83 c4 08             	add    $0x8,%esp
f0102749:	6a 02                	push   $0x2
f010274b:	6a 00                	push   $0x0
f010274d:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102752:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102757:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f010275c:	e8 f8 ed ff ff       	call   f0101559 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102761:	8b 1d 48 11 1e f0    	mov    0xf01e1148,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102767:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f010276c:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102773:	83 c4 10             	add    $0x10,%esp
f0102776:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f010277c:	74 63                	je     f01027e1 <mem_init+0x1110>
f010277e:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102783:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102789:	89 d8                	mov    %ebx,%eax
f010278b:	e8 7b e8 ff ff       	call   f010100b <check_va2pa>
f0102790:	8b 15 4c 11 1e f0    	mov    0xf01e114c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102796:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010279c:	77 15                	ja     f01027b3 <mem_init+0x10e2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010279e:	52                   	push   %edx
f010279f:	68 a0 54 10 f0       	push   $0xf01054a0
f01027a4:	68 e8 02 00 00       	push   $0x2e8
f01027a9:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01027ae:	e8 1f d9 ff ff       	call   f01000d2 <_panic>
f01027b3:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01027ba:	39 d0                	cmp    %edx,%eax
f01027bc:	74 19                	je     f01027d7 <mem_init+0x1106>
f01027be:	68 d0 5b 10 f0       	push   $0xf0105bd0
f01027c3:	68 f3 5d 10 f0       	push   $0xf0105df3
f01027c8:	68 e8 02 00 00       	push   $0x2e8
f01027cd:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01027d2:	e8 fb d8 ff ff       	call   f01000d2 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027d7:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027dd:	39 f7                	cmp    %esi,%edi
f01027df:	77 a2                	ja     f0102783 <mem_init+0x10b2>
f01027e1:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01027e6:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f01027ec:	89 d8                	mov    %ebx,%eax
f01027ee:	e8 18 e8 ff ff       	call   f010100b <check_va2pa>
f01027f3:	8b 15 7c 04 1e f0    	mov    0xf01e047c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027f9:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01027ff:	77 15                	ja     f0102816 <mem_init+0x1145>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102801:	52                   	push   %edx
f0102802:	68 a0 54 10 f0       	push   $0xf01054a0
f0102807:	68 ed 02 00 00       	push   $0x2ed
f010280c:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102811:	e8 bc d8 ff ff       	call   f01000d2 <_panic>
f0102816:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010281d:	39 d0                	cmp    %edx,%eax
f010281f:	74 19                	je     f010283a <mem_init+0x1169>
f0102821:	68 04 5c 10 f0       	push   $0xf0105c04
f0102826:	68 f3 5d 10 f0       	push   $0xf0105df3
f010282b:	68 ed 02 00 00       	push   $0x2ed
f0102830:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102835:	e8 98 d8 ff ff       	call   f01000d2 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010283a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102840:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f0102846:	75 9e                	jne    f01027e6 <mem_init+0x1115>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102848:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f010284d:	c1 e0 0c             	shl    $0xc,%eax
f0102850:	74 41                	je     f0102893 <mem_init+0x11c2>
f0102852:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102857:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f010285d:	89 d8                	mov    %ebx,%eax
f010285f:	e8 a7 e7 ff ff       	call   f010100b <check_va2pa>
f0102864:	39 c6                	cmp    %eax,%esi
f0102866:	74 19                	je     f0102881 <mem_init+0x11b0>
f0102868:	68 38 5c 10 f0       	push   $0xf0105c38
f010286d:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102872:	68 f1 02 00 00       	push   $0x2f1
f0102877:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010287c:	e8 51 d8 ff ff       	call   f01000d2 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102881:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102887:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f010288c:	c1 e0 0c             	shl    $0xc,%eax
f010288f:	39 c6                	cmp    %eax,%esi
f0102891:	72 c4                	jb     f0102857 <mem_init+0x1186>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102893:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102898:	89 d8                	mov    %ebx,%eax
f010289a:	e8 6c e7 ff ff       	call   f010100b <check_va2pa>
f010289f:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01028a4:	bf 00 90 11 f0       	mov    $0xf0119000,%edi
f01028a9:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01028af:	8d 14 37             	lea    (%edi,%esi,1),%edx
f01028b2:	39 c2                	cmp    %eax,%edx
f01028b4:	74 19                	je     f01028cf <mem_init+0x11fe>
f01028b6:	68 60 5c 10 f0       	push   $0xf0105c60
f01028bb:	68 f3 5d 10 f0       	push   $0xf0105df3
f01028c0:	68 f5 02 00 00       	push   $0x2f5
f01028c5:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01028ca:	e8 03 d8 ff ff       	call   f01000d2 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01028cf:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01028d5:	0f 85 25 04 00 00    	jne    f0102d00 <mem_init+0x162f>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01028db:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01028e0:	89 d8                	mov    %ebx,%eax
f01028e2:	e8 24 e7 ff ff       	call   f010100b <check_va2pa>
f01028e7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028ea:	74 19                	je     f0102905 <mem_init+0x1234>
f01028ec:	68 a8 5c 10 f0       	push   $0xf0105ca8
f01028f1:	68 f3 5d 10 f0       	push   $0xf0105df3
f01028f6:	68 f6 02 00 00       	push   $0x2f6
f01028fb:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102900:	e8 cd d7 ff ff       	call   f01000d2 <_panic>
f0102905:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010290a:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010290f:	72 2d                	jb     f010293e <mem_init+0x126d>
f0102911:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102916:	76 07                	jbe    f010291f <mem_init+0x124e>
f0102918:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010291d:	75 1f                	jne    f010293e <mem_init+0x126d>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010291f:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102923:	75 7e                	jne    f01029a3 <mem_init+0x12d2>
f0102925:	68 47 60 10 f0       	push   $0xf0106047
f010292a:	68 f3 5d 10 f0       	push   $0xf0105df3
f010292f:	68 ff 02 00 00       	push   $0x2ff
f0102934:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102939:	e8 94 d7 ff ff       	call   f01000d2 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010293e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102943:	76 3f                	jbe    f0102984 <mem_init+0x12b3>
				assert(pgdir[i] & PTE_P);
f0102945:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102948:	f6 c2 01             	test   $0x1,%dl
f010294b:	75 19                	jne    f0102966 <mem_init+0x1295>
f010294d:	68 47 60 10 f0       	push   $0xf0106047
f0102952:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102957:	68 03 03 00 00       	push   $0x303
f010295c:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102961:	e8 6c d7 ff ff       	call   f01000d2 <_panic>
				assert(pgdir[i] & PTE_W);
f0102966:	f6 c2 02             	test   $0x2,%dl
f0102969:	75 38                	jne    f01029a3 <mem_init+0x12d2>
f010296b:	68 58 60 10 f0       	push   $0xf0106058
f0102970:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102975:	68 04 03 00 00       	push   $0x304
f010297a:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010297f:	e8 4e d7 ff ff       	call   f01000d2 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102984:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102988:	74 19                	je     f01029a3 <mem_init+0x12d2>
f010298a:	68 69 60 10 f0       	push   $0xf0106069
f010298f:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102994:	68 06 03 00 00       	push   $0x306
f0102999:	68 cd 5d 10 f0       	push   $0xf0105dcd
f010299e:	e8 2f d7 ff ff       	call   f01000d2 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01029a3:	40                   	inc    %eax
f01029a4:	3d 00 04 00 00       	cmp    $0x400,%eax
f01029a9:	0f 85 5b ff ff ff    	jne    f010290a <mem_init+0x1239>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01029af:	83 ec 0c             	sub    $0xc,%esp
f01029b2:	68 d8 5c 10 f0       	push   $0xf0105cd8
f01029b7:	e8 95 0b 00 00       	call   f0103551 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01029bc:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029c1:	83 c4 10             	add    $0x10,%esp
f01029c4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029c9:	77 15                	ja     f01029e0 <mem_init+0x130f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029cb:	50                   	push   %eax
f01029cc:	68 a0 54 10 f0       	push   $0xf01054a0
f01029d1:	68 f2 00 00 00       	push   $0xf2
f01029d6:	68 cd 5d 10 f0       	push   $0xf0105dcd
f01029db:	e8 f2 d6 ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01029e0:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01029e5:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01029e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01029ed:	e8 a2 e6 ff ff       	call   f0101094 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01029f2:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01029f5:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01029fa:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01029fd:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a00:	83 ec 0c             	sub    $0xc,%esp
f0102a03:	6a 00                	push   $0x0
f0102a05:	e8 f0 e9 ff ff       	call   f01013fa <page_alloc>
f0102a0a:	89 c6                	mov    %eax,%esi
f0102a0c:	83 c4 10             	add    $0x10,%esp
f0102a0f:	85 c0                	test   %eax,%eax
f0102a11:	75 19                	jne    f0102a2c <mem_init+0x135b>
f0102a13:	68 9e 5e 10 f0       	push   $0xf0105e9e
f0102a18:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102a1d:	68 bb 03 00 00       	push   $0x3bb
f0102a22:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102a27:	e8 a6 d6 ff ff       	call   f01000d2 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a2c:	83 ec 0c             	sub    $0xc,%esp
f0102a2f:	6a 00                	push   $0x0
f0102a31:	e8 c4 e9 ff ff       	call   f01013fa <page_alloc>
f0102a36:	89 c7                	mov    %eax,%edi
f0102a38:	83 c4 10             	add    $0x10,%esp
f0102a3b:	85 c0                	test   %eax,%eax
f0102a3d:	75 19                	jne    f0102a58 <mem_init+0x1387>
f0102a3f:	68 b4 5e 10 f0       	push   $0xf0105eb4
f0102a44:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102a49:	68 bc 03 00 00       	push   $0x3bc
f0102a4e:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102a53:	e8 7a d6 ff ff       	call   f01000d2 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a58:	83 ec 0c             	sub    $0xc,%esp
f0102a5b:	6a 00                	push   $0x0
f0102a5d:	e8 98 e9 ff ff       	call   f01013fa <page_alloc>
f0102a62:	89 c3                	mov    %eax,%ebx
f0102a64:	83 c4 10             	add    $0x10,%esp
f0102a67:	85 c0                	test   %eax,%eax
f0102a69:	75 19                	jne    f0102a84 <mem_init+0x13b3>
f0102a6b:	68 ca 5e 10 f0       	push   $0xf0105eca
f0102a70:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102a75:	68 bd 03 00 00       	push   $0x3bd
f0102a7a:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102a7f:	e8 4e d6 ff ff       	call   f01000d2 <_panic>
	page_free(pp0);
f0102a84:	83 ec 0c             	sub    $0xc,%esp
f0102a87:	56                   	push   %esi
f0102a88:	e8 f7 e9 ff ff       	call   f0101484 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a8d:	89 f8                	mov    %edi,%eax
f0102a8f:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0102a95:	c1 f8 03             	sar    $0x3,%eax
f0102a98:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a9b:	89 c2                	mov    %eax,%edx
f0102a9d:	c1 ea 0c             	shr    $0xc,%edx
f0102aa0:	83 c4 10             	add    $0x10,%esp
f0102aa3:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0102aa9:	72 12                	jb     f0102abd <mem_init+0x13ec>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102aab:	50                   	push   %eax
f0102aac:	68 6c 56 10 f0       	push   $0xf010566c
f0102ab1:	6a 56                	push   $0x56
f0102ab3:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0102ab8:	e8 15 d6 ff ff       	call   f01000d2 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102abd:	83 ec 04             	sub    $0x4,%esp
f0102ac0:	68 00 10 00 00       	push   $0x1000
f0102ac5:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102ac7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102acc:	50                   	push   %eax
f0102acd:	e8 a7 1c 00 00       	call   f0104779 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ad2:	89 d8                	mov    %ebx,%eax
f0102ad4:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0102ada:	c1 f8 03             	sar    $0x3,%eax
f0102add:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ae0:	89 c2                	mov    %eax,%edx
f0102ae2:	c1 ea 0c             	shr    $0xc,%edx
f0102ae5:	83 c4 10             	add    $0x10,%esp
f0102ae8:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0102aee:	72 12                	jb     f0102b02 <mem_init+0x1431>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102af0:	50                   	push   %eax
f0102af1:	68 6c 56 10 f0       	push   $0xf010566c
f0102af6:	6a 56                	push   $0x56
f0102af8:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0102afd:	e8 d0 d5 ff ff       	call   f01000d2 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b02:	83 ec 04             	sub    $0x4,%esp
f0102b05:	68 00 10 00 00       	push   $0x1000
f0102b0a:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102b0c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b11:	50                   	push   %eax
f0102b12:	e8 62 1c 00 00       	call   f0104779 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b17:	6a 02                	push   $0x2
f0102b19:	68 00 10 00 00       	push   $0x1000
f0102b1e:	57                   	push   %edi
f0102b1f:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102b25:	e8 3e eb ff ff       	call   f0101668 <page_insert>
	assert(pp1->pp_ref == 1);
f0102b2a:	83 c4 20             	add    $0x20,%esp
f0102b2d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b32:	74 19                	je     f0102b4d <mem_init+0x147c>
f0102b34:	68 9b 5f 10 f0       	push   $0xf0105f9b
f0102b39:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102b3e:	68 c2 03 00 00       	push   $0x3c2
f0102b43:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102b48:	e8 85 d5 ff ff       	call   f01000d2 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b4d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b54:	01 01 01 
f0102b57:	74 19                	je     f0102b72 <mem_init+0x14a1>
f0102b59:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0102b5e:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102b63:	68 c3 03 00 00       	push   $0x3c3
f0102b68:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102b6d:	e8 60 d5 ff ff       	call   f01000d2 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b72:	6a 02                	push   $0x2
f0102b74:	68 00 10 00 00       	push   $0x1000
f0102b79:	53                   	push   %ebx
f0102b7a:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102b80:	e8 e3 ea ff ff       	call   f0101668 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b85:	83 c4 10             	add    $0x10,%esp
f0102b88:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b8f:	02 02 02 
f0102b92:	74 19                	je     f0102bad <mem_init+0x14dc>
f0102b94:	68 1c 5d 10 f0       	push   $0xf0105d1c
f0102b99:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102b9e:	68 c5 03 00 00       	push   $0x3c5
f0102ba3:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102ba8:	e8 25 d5 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f0102bad:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102bb2:	74 19                	je     f0102bcd <mem_init+0x14fc>
f0102bb4:	68 bd 5f 10 f0       	push   $0xf0105fbd
f0102bb9:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102bbe:	68 c6 03 00 00       	push   $0x3c6
f0102bc3:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102bc8:	e8 05 d5 ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 0);
f0102bcd:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102bd2:	74 19                	je     f0102bed <mem_init+0x151c>
f0102bd4:	68 06 60 10 f0       	push   $0xf0106006
f0102bd9:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102bde:	68 c7 03 00 00       	push   $0x3c7
f0102be3:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102be8:	e8 e5 d4 ff ff       	call   f01000d2 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102bed:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102bf4:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bf7:	89 d8                	mov    %ebx,%eax
f0102bf9:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0102bff:	c1 f8 03             	sar    $0x3,%eax
f0102c02:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c05:	89 c2                	mov    %eax,%edx
f0102c07:	c1 ea 0c             	shr    $0xc,%edx
f0102c0a:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0102c10:	72 12                	jb     f0102c24 <mem_init+0x1553>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c12:	50                   	push   %eax
f0102c13:	68 6c 56 10 f0       	push   $0xf010566c
f0102c18:	6a 56                	push   $0x56
f0102c1a:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0102c1f:	e8 ae d4 ff ff       	call   f01000d2 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c24:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c2b:	03 03 03 
f0102c2e:	74 19                	je     f0102c49 <mem_init+0x1578>
f0102c30:	68 40 5d 10 f0       	push   $0xf0105d40
f0102c35:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102c3a:	68 c9 03 00 00       	push   $0x3c9
f0102c3f:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102c44:	e8 89 d4 ff ff       	call   f01000d2 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c49:	83 ec 08             	sub    $0x8,%esp
f0102c4c:	68 00 10 00 00       	push   $0x1000
f0102c51:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102c57:	e8 bf e9 ff ff       	call   f010161b <page_remove>
	assert(pp2->pp_ref == 0);
f0102c5c:	83 c4 10             	add    $0x10,%esp
f0102c5f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c64:	74 19                	je     f0102c7f <mem_init+0x15ae>
f0102c66:	68 f5 5f 10 f0       	push   $0xf0105ff5
f0102c6b:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102c70:	68 cb 03 00 00       	push   $0x3cb
f0102c75:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102c7a:	e8 53 d4 ff ff       	call   f01000d2 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c7f:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102c84:	8b 08                	mov    (%eax),%ecx
f0102c86:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c8c:	89 f2                	mov    %esi,%edx
f0102c8e:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0102c94:	c1 fa 03             	sar    $0x3,%edx
f0102c97:	c1 e2 0c             	shl    $0xc,%edx
f0102c9a:	39 d1                	cmp    %edx,%ecx
f0102c9c:	74 19                	je     f0102cb7 <mem_init+0x15e6>
f0102c9e:	68 88 58 10 f0       	push   $0xf0105888
f0102ca3:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102ca8:	68 ce 03 00 00       	push   $0x3ce
f0102cad:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102cb2:	e8 1b d4 ff ff       	call   f01000d2 <_panic>
	kern_pgdir[0] = 0;
f0102cb7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102cbd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cc2:	74 19                	je     f0102cdd <mem_init+0x160c>
f0102cc4:	68 ac 5f 10 f0       	push   $0xf0105fac
f0102cc9:	68 f3 5d 10 f0       	push   $0xf0105df3
f0102cce:	68 d0 03 00 00       	push   $0x3d0
f0102cd3:	68 cd 5d 10 f0       	push   $0xf0105dcd
f0102cd8:	e8 f5 d3 ff ff       	call   f01000d2 <_panic>
	pp0->pp_ref = 0;
f0102cdd:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102ce3:	83 ec 0c             	sub    $0xc,%esp
f0102ce6:	56                   	push   %esi
f0102ce7:	e8 98 e7 ff ff       	call   f0101484 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102cec:	c7 04 24 6c 5d 10 f0 	movl   $0xf0105d6c,(%esp)
f0102cf3:	e8 59 08 00 00       	call   f0103551 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cfb:	5b                   	pop    %ebx
f0102cfc:	5e                   	pop    %esi
f0102cfd:	5f                   	pop    %edi
f0102cfe:	c9                   	leave  
f0102cff:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102d00:	89 f2                	mov    %esi,%edx
f0102d02:	89 d8                	mov    %ebx,%eax
f0102d04:	e8 02 e3 ff ff       	call   f010100b <check_va2pa>
f0102d09:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102d0f:	e9 9b fb ff ff       	jmp    f01028af <mem_init+0x11de>

f0102d14 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102d14:	55                   	push   %ebp
f0102d15:	89 e5                	mov    %esp,%ebp
f0102d17:	57                   	push   %edi
f0102d18:	56                   	push   %esi
f0102d19:	53                   	push   %ebx
f0102d1a:	83 ec 1c             	sub    $0x1c,%esp
f0102d1d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102d20:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d23:	8b 55 10             	mov    0x10(%ebp),%edx
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f0102d26:	85 d2                	test   %edx,%edx
f0102d28:	0f 84 85 00 00 00    	je     f0102db3 <user_mem_check+0x9f>

	perm |= PTE_P;
f0102d2e:	8b 75 14             	mov    0x14(%ebp),%esi
f0102d31:	83 ce 01             	or     $0x1,%esi
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
f0102d34:	89 c3                	mov    %eax,%ebx
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
f0102d36:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0102d3d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102d43:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f0102d46:	89 c2                	mov    %eax,%edx
f0102d48:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102d4e:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f0102d51:	74 67                	je     f0102dba <user_mem_check+0xa6>
		if (va_now >= ULIM) {
f0102d53:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0102d58:	76 17                	jbe    f0102d71 <user_mem_check+0x5d>
f0102d5a:	eb 08                	jmp    f0102d64 <user_mem_check+0x50>
f0102d5c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d62:	76 0d                	jbe    f0102d71 <user_mem_check+0x5d>
			user_mem_check_addr = va_now;
f0102d64:	89 1d 6c 04 1e f0    	mov    %ebx,0xf01e046c
			return -E_FAULT;
f0102d6a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d6f:	eb 4e                	jmp    f0102dbf <user_mem_check+0xab>
		}
		pte = pgdir_walk(env->env_pgdir, (void *)va_now, false);
f0102d71:	83 ec 04             	sub    $0x4,%esp
f0102d74:	6a 00                	push   $0x0
f0102d76:	53                   	push   %ebx
f0102d77:	ff 77 5c             	pushl  0x5c(%edi)
f0102d7a:	e8 43 e7 ff ff       	call   f01014c2 <pgdir_walk>
		if (pte == NULL || ((*pte & perm ) != perm)) {
f0102d7f:	83 c4 10             	add    $0x10,%esp
f0102d82:	85 c0                	test   %eax,%eax
f0102d84:	74 08                	je     f0102d8e <user_mem_check+0x7a>
f0102d86:	8b 00                	mov    (%eax),%eax
f0102d88:	21 f0                	and    %esi,%eax
f0102d8a:	39 c6                	cmp    %eax,%esi
f0102d8c:	74 0d                	je     f0102d9b <user_mem_check+0x87>
			user_mem_check_addr = va_now;
f0102d8e:	89 1d 6c 04 1e f0    	mov    %ebx,0xf01e046c
			return -E_FAULT;
f0102d94:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d99:	eb 24                	jmp    f0102dbf <user_mem_check+0xab>

	perm |= PTE_P;
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f0102d9b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102da1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102da7:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102daa:	75 b0                	jne    f0102d5c <user_mem_check+0x48>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0102dac:	b8 00 00 00 00       	mov    $0x0,%eax
f0102db1:	eb 0c                	jmp    f0102dbf <user_mem_check+0xab>
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f0102db3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102db8:	eb 05                	jmp    f0102dbf <user_mem_check+0xab>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0102dba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dc2:	5b                   	pop    %ebx
f0102dc3:	5e                   	pop    %esi
f0102dc4:	5f                   	pop    %edi
f0102dc5:	c9                   	leave  
f0102dc6:	c3                   	ret    

f0102dc7 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102dc7:	55                   	push   %ebp
f0102dc8:	89 e5                	mov    %esp,%ebp
f0102dca:	53                   	push   %ebx
f0102dcb:	83 ec 04             	sub    $0x4,%esp
f0102dce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102dd1:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dd4:	83 c8 04             	or     $0x4,%eax
f0102dd7:	50                   	push   %eax
f0102dd8:	ff 75 10             	pushl  0x10(%ebp)
f0102ddb:	ff 75 0c             	pushl  0xc(%ebp)
f0102dde:	53                   	push   %ebx
f0102ddf:	e8 30 ff ff ff       	call   f0102d14 <user_mem_check>
f0102de4:	83 c4 10             	add    $0x10,%esp
f0102de7:	85 c0                	test   %eax,%eax
f0102de9:	79 21                	jns    f0102e0c <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102deb:	83 ec 04             	sub    $0x4,%esp
f0102dee:	ff 35 6c 04 1e f0    	pushl  0xf01e046c
f0102df4:	ff 73 48             	pushl  0x48(%ebx)
f0102df7:	68 98 5d 10 f0       	push   $0xf0105d98
f0102dfc:	e8 50 07 00 00       	call   f0103551 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e01:	89 1c 24             	mov    %ebx,(%esp)
f0102e04:	e8 33 06 00 00       	call   f010343c <env_destroy>
f0102e09:	83 c4 10             	add    $0x10,%esp
	}
}
f0102e0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e0f:	c9                   	leave  
f0102e10:	c3                   	ret    
f0102e11:	00 00                	add    %al,(%eax)
	...

f0102e14 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102e14:	55                   	push   %ebp
f0102e15:	89 e5                	mov    %esp,%ebp
f0102e17:	57                   	push   %edi
f0102e18:	56                   	push   %esi
f0102e19:	53                   	push   %ebx
f0102e1a:	83 ec 0c             	sub    $0xc,%esp
f0102e1d:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0102e1f:	89 d3                	mov    %edx,%ebx
f0102e21:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
f0102e27:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0102e2e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0102e34:	39 fb                	cmp    %edi,%ebx
f0102e36:	74 5a                	je     f0102e92 <region_alloc+0x7e>
        pg = page_alloc(1);
f0102e38:	83 ec 0c             	sub    $0xc,%esp
f0102e3b:	6a 01                	push   $0x1
f0102e3d:	e8 b8 e5 ff ff       	call   f01013fa <page_alloc>
        if (pg == NULL) {
f0102e42:	83 c4 10             	add    $0x10,%esp
f0102e45:	85 c0                	test   %eax,%eax
f0102e47:	75 17                	jne    f0102e60 <region_alloc+0x4c>
            panic("region_alloc : can't alloc page\n");
f0102e49:	83 ec 04             	sub    $0x4,%esp
f0102e4c:	68 78 60 10 f0       	push   $0xf0106078
f0102e51:	68 2a 01 00 00       	push   $0x12a
f0102e56:	68 f2 60 10 f0       	push   $0xf01060f2
f0102e5b:	e8 72 d2 ff ff       	call   f01000d2 <_panic>
        } else {
            r = page_insert(e->env_pgdir, pg, (void *)addr, PTE_U | PTE_W);
f0102e60:	6a 06                	push   $0x6
f0102e62:	53                   	push   %ebx
f0102e63:	50                   	push   %eax
f0102e64:	ff 76 5c             	pushl  0x5c(%esi)
f0102e67:	e8 fc e7 ff ff       	call   f0101668 <page_insert>
            if (r != 0) {
f0102e6c:	83 c4 10             	add    $0x10,%esp
f0102e6f:	85 c0                	test   %eax,%eax
f0102e71:	74 15                	je     f0102e88 <region_alloc+0x74>
                panic("/kern/env.c/region_alloc : %e\n", r);
f0102e73:	50                   	push   %eax
f0102e74:	68 9c 60 10 f0       	push   $0xf010609c
f0102e79:	68 2e 01 00 00       	push   $0x12e
f0102e7e:	68 f2 60 10 f0       	push   $0xf01060f2
f0102e83:	e8 4a d2 ff ff       	call   f01000d2 <_panic>
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0102e88:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e8e:	39 df                	cmp    %ebx,%edi
f0102e90:	75 a6                	jne    f0102e38 <region_alloc+0x24>
                panic("/kern/env.c/region_alloc : %e\n", r);
            }
        }
    }
    return;
}
f0102e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e95:	5b                   	pop    %ebx
f0102e96:	5e                   	pop    %esi
f0102e97:	5f                   	pop    %edi
f0102e98:	c9                   	leave  
f0102e99:	c3                   	ret    

f0102e9a <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e9a:	55                   	push   %ebp
f0102e9b:	89 e5                	mov    %esp,%ebp
f0102e9d:	53                   	push   %ebx
f0102e9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102ea4:	8a 5d 10             	mov    0x10(%ebp),%bl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102ea7:	85 c0                	test   %eax,%eax
f0102ea9:	75 0e                	jne    f0102eb9 <envid2env+0x1f>
		*env_store = curenv;
f0102eab:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f0102eb0:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102eb2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eb7:	eb 55                	jmp    f0102f0e <envid2env+0x74>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102eb9:	89 c2                	mov    %eax,%edx
f0102ebb:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102ec1:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102ec4:	c1 e2 05             	shl    $0x5,%edx
f0102ec7:	03 15 7c 04 1e f0    	add    0xf01e047c,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102ecd:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102ed1:	74 05                	je     f0102ed8 <envid2env+0x3e>
f0102ed3:	39 42 48             	cmp    %eax,0x48(%edx)
f0102ed6:	74 0d                	je     f0102ee5 <envid2env+0x4b>
		*env_store = 0;
f0102ed8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102ede:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ee3:	eb 29                	jmp    f0102f0e <envid2env+0x74>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102ee5:	84 db                	test   %bl,%bl
f0102ee7:	74 1e                	je     f0102f07 <envid2env+0x6d>
f0102ee9:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f0102eee:	39 c2                	cmp    %eax,%edx
f0102ef0:	74 15                	je     f0102f07 <envid2env+0x6d>
f0102ef2:	8b 58 48             	mov    0x48(%eax),%ebx
f0102ef5:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f0102ef8:	74 0d                	je     f0102f07 <envid2env+0x6d>
		*env_store = 0;
f0102efa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102f00:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f05:	eb 07                	jmp    f0102f0e <envid2env+0x74>
	}

	*env_store = e;
f0102f07:	89 11                	mov    %edx,(%ecx)
	return 0;
f0102f09:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f0e:	5b                   	pop    %ebx
f0102f0f:	c9                   	leave  
f0102f10:	c3                   	ret    

f0102f11 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102f11:	55                   	push   %ebp
f0102f12:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102f14:	b8 30 33 12 f0       	mov    $0xf0123330,%eax
f0102f19:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102f1c:	b8 23 00 00 00       	mov    $0x23,%eax
f0102f21:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102f23:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102f25:	b0 10                	mov    $0x10,%al
f0102f27:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102f29:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102f2b:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102f2d:	ea 34 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f34
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102f34:	b0 00                	mov    $0x0,%al
f0102f36:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f39:	c9                   	leave  
f0102f3a:	c3                   	ret    

f0102f3b <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f3b:	55                   	push   %ebp
f0102f3c:	89 e5                	mov    %esp,%ebp
f0102f3e:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
f0102f3f:	8b 1d 7c 04 1e f0    	mov    0xf01e047c,%ebx
f0102f45:	89 1d 84 04 1e f0    	mov    %ebx,0xf01e0484
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
f0102f4b:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        envs[i].env_status = ENV_FREE;
f0102f52:	c7 43 54 00 00 00 00 	movl   $0x0,0x54(%ebx)
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0102f59:	8d 43 60             	lea    0x60(%ebx),%eax
f0102f5c:	8d 8b 00 80 01 00    	lea    0x18000(%ebx),%ecx
f0102f62:	89 c2                	mov    %eax,%edx
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0102f64:	89 43 44             	mov    %eax,0x44(%ebx)
{
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
f0102f67:	39 c8                	cmp    %ecx,%eax
f0102f69:	74 1c                	je     f0102f87 <env_init+0x4c>
        envs[i].env_id = 0;
f0102f6b:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE;
f0102f72:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f0102f79:	83 c0 60             	add    $0x60,%eax
        if (i + 1 != NENV)
f0102f7c:	39 c8                	cmp    %ecx,%eax
f0102f7e:	75 0f                	jne    f0102f8f <env_init+0x54>
            envs[i].env_link = envs + (i + 1);
        else 
            envs[i].env_link = NULL;
f0102f80:	c7 42 44 00 00 00 00 	movl   $0x0,0x44(%edx)
    }

	// Per-CPU part of the initialization
	env_init_percpu();
f0102f87:	e8 85 ff ff ff       	call   f0102f11 <env_init_percpu>
}
f0102f8c:	5b                   	pop    %ebx
f0102f8d:	c9                   	leave  
f0102f8e:	c3                   	ret    
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0102f8f:	89 42 44             	mov    %eax,0x44(%edx)
f0102f92:	89 c2                	mov    %eax,%edx
f0102f94:	eb d5                	jmp    f0102f6b <env_init+0x30>

f0102f96 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f96:	55                   	push   %ebp
f0102f97:	89 e5                	mov    %esp,%ebp
f0102f99:	56                   	push   %esi
f0102f9a:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f9b:	8b 35 84 04 1e f0    	mov    0xf01e0484,%esi
f0102fa1:	85 f6                	test   %esi,%esi
f0102fa3:	0f 84 8d 01 00 00    	je     f0103136 <env_alloc+0x1a0>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102fa9:	83 ec 0c             	sub    $0xc,%esp
f0102fac:	6a 01                	push   $0x1
f0102fae:	e8 47 e4 ff ff       	call   f01013fa <page_alloc>
f0102fb3:	89 c3                	mov    %eax,%ebx
f0102fb5:	83 c4 10             	add    $0x10,%esp
f0102fb8:	85 c0                	test   %eax,%eax
f0102fba:	0f 84 7d 01 00 00    	je     f010313d <env_alloc+0x1a7>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    cprintf("env_setup_vm in\n");
f0102fc0:	83 ec 0c             	sub    $0xc,%esp
f0102fc3:	68 fd 60 10 f0       	push   $0xf01060fd
f0102fc8:	e8 84 05 00 00       	call   f0103551 <cprintf>

    p->pp_ref++;
f0102fcd:	66 ff 43 04          	incw   0x4(%ebx)
f0102fd1:	2b 1d 4c 11 1e f0    	sub    0xf01e114c,%ebx
f0102fd7:	c1 fb 03             	sar    $0x3,%ebx
f0102fda:	c1 e3 0c             	shl    $0xc,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102fdd:	89 d8                	mov    %ebx,%eax
f0102fdf:	c1 e8 0c             	shr    $0xc,%eax
f0102fe2:	83 c4 10             	add    $0x10,%esp
f0102fe5:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f0102feb:	72 12                	jb     f0102fff <env_alloc+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102fed:	53                   	push   %ebx
f0102fee:	68 6c 56 10 f0       	push   $0xf010566c
f0102ff3:	6a 56                	push   $0x56
f0102ff5:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0102ffa:	e8 d3 d0 ff ff       	call   f01000d2 <_panic>
	return (void *)(pa + KERNBASE);
f0102fff:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
    e->env_pgdir = (pde_t *)page2kva(p);
f0103005:	89 5e 5c             	mov    %ebx,0x5c(%esi)
    // pay attention: have we set mapped in kern_pgdir ?
    // page_insert(kern_pgdir, p, (void *)e->env_pgdir, PTE_U | PTE_W); 

    memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103008:	83 ec 04             	sub    $0x4,%esp
f010300b:	68 00 10 00 00       	push   $0x1000
f0103010:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0103016:	53                   	push   %ebx
f0103017:	e8 11 18 00 00       	call   f010482d <memcpy>
    memset(e->env_pgdir, 0, PDX(UTOP) * sizeof(pde_t));
f010301c:	83 c4 0c             	add    $0xc,%esp
f010301f:	68 ec 0e 00 00       	push   $0xeec
f0103024:	6a 00                	push   $0x0
f0103026:	ff 76 5c             	pushl  0x5c(%esi)
f0103029:	e8 4b 17 00 00       	call   f0104779 <memset>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010302e:	8b 46 5c             	mov    0x5c(%esi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103031:	83 c4 10             	add    $0x10,%esp
f0103034:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103039:	77 15                	ja     f0103050 <env_alloc+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010303b:	50                   	push   %eax
f010303c:	68 a0 54 10 f0       	push   $0xf01054a0
f0103041:	68 cc 00 00 00       	push   $0xcc
f0103046:	68 f2 60 10 f0       	push   $0xf01060f2
f010304b:	e8 82 d0 ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103050:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103056:	83 ca 05             	or     $0x5,%edx
f0103059:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)

    cprintf("env_setup_vm out\n");
f010305f:	83 ec 0c             	sub    $0xc,%esp
f0103062:	68 0e 61 10 f0       	push   $0xf010610e
f0103067:	e8 e5 04 00 00       	call   f0103551 <cprintf>
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
    
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010306c:	8b 46 48             	mov    0x48(%esi),%eax
f010306f:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103074:	83 c4 10             	add    $0x10,%esp
f0103077:	89 c1                	mov    %eax,%ecx
f0103079:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f010307f:	7f 05                	jg     f0103086 <env_alloc+0xf0>
		generation = 1 << ENVGENSHIFT;
f0103081:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0103086:	89 f0                	mov    %esi,%eax
f0103088:	2b 05 7c 04 1e f0    	sub    0xf01e047c,%eax
f010308e:	c1 f8 05             	sar    $0x5,%eax
f0103091:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0103094:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103097:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010309a:	89 d3                	mov    %edx,%ebx
f010309c:	c1 e3 08             	shl    $0x8,%ebx
f010309f:	01 da                	add    %ebx,%edx
f01030a1:	89 d3                	mov    %edx,%ebx
f01030a3:	c1 e3 10             	shl    $0x10,%ebx
f01030a6:	01 da                	add    %ebx,%edx
f01030a8:	8d 04 50             	lea    (%eax,%edx,2),%eax
f01030ab:	09 c1                	or     %eax,%ecx
f01030ad:	89 4e 48             	mov    %ecx,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01030b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030b3:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f01030b6:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f01030bd:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f01030c4:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01030cb:	83 ec 04             	sub    $0x4,%esp
f01030ce:	6a 44                	push   $0x44
f01030d0:	6a 00                	push   $0x0
f01030d2:	56                   	push   %esi
f01030d3:	e8 a1 16 00 00       	call   f0104779 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01030d8:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f01030de:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f01030e4:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f01030ea:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f01030f1:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f01030f7:	8b 46 44             	mov    0x44(%esi),%eax
f01030fa:	a3 84 04 1e f0       	mov    %eax,0xf01e0484
	*newenv_store = e;
f01030ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0103102:	89 30                	mov    %esi,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103104:	8b 56 48             	mov    0x48(%esi),%edx
f0103107:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f010310c:	83 c4 10             	add    $0x10,%esp
f010310f:	85 c0                	test   %eax,%eax
f0103111:	74 05                	je     f0103118 <env_alloc+0x182>
f0103113:	8b 40 48             	mov    0x48(%eax),%eax
f0103116:	eb 05                	jmp    f010311d <env_alloc+0x187>
f0103118:	b8 00 00 00 00       	mov    $0x0,%eax
f010311d:	83 ec 04             	sub    $0x4,%esp
f0103120:	52                   	push   %edx
f0103121:	50                   	push   %eax
f0103122:	68 20 61 10 f0       	push   $0xf0106120
f0103127:	e8 25 04 00 00       	call   f0103551 <cprintf>
	return 0;
f010312c:	83 c4 10             	add    $0x10,%esp
f010312f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103134:	eb 0c                	jmp    f0103142 <env_alloc+0x1ac>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103136:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010313b:	eb 05                	jmp    f0103142 <env_alloc+0x1ac>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010313d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103142:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103145:	5b                   	pop    %ebx
f0103146:	5e                   	pop    %esi
f0103147:	c9                   	leave  
f0103148:	c3                   	ret    

f0103149 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103149:	55                   	push   %ebp
f010314a:	89 e5                	mov    %esp,%ebp
f010314c:	57                   	push   %edi
f010314d:	56                   	push   %esi
f010314e:	53                   	push   %ebx
f010314f:	83 ec 34             	sub    $0x34,%esp
f0103152:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("env_create %u %u %u\n", binary, size, type);
	// LAB 3: Your code here.
    struct Env * e;
    int r = env_alloc(&e, 0);
f0103155:	6a 00                	push   $0x0
f0103157:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010315a:	50                   	push   %eax
f010315b:	e8 36 fe ff ff       	call   f0102f96 <env_alloc>
    if (r < 0) {
f0103160:	83 c4 10             	add    $0x10,%esp
f0103163:	85 c0                	test   %eax,%eax
f0103165:	79 15                	jns    f010317c <env_create+0x33>
        panic("env_create: %e\n", r);
f0103167:	50                   	push   %eax
f0103168:	68 35 61 10 f0       	push   $0xf0106135
f010316d:	68 98 01 00 00       	push   $0x198
f0103172:	68 f2 60 10 f0       	push   $0xf01060f2
f0103177:	e8 56 cf ff ff       	call   f01000d2 <_panic>
    }
    load_icode(e, binary, size);
f010317c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010317f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
f0103182:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103188:	74 17                	je     f01031a1 <env_create+0x58>
        panic("error elf magic number\n");
f010318a:	83 ec 04             	sub    $0x4,%esp
f010318d:	68 45 61 10 f0       	push   $0xf0106145
f0103192:	68 6d 01 00 00       	push   $0x16d
f0103197:	68 f2 60 10 f0       	push   $0xf01060f2
f010319c:	e8 31 cf ff ff       	call   f01000d2 <_panic>
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01031a1:	8b 5e 1c             	mov    0x1c(%esi),%ebx
    eph = ph + elf->e_phnum;
f01031a4:	8b 7e 2c             	mov    0x2c(%esi),%edi

    lcr3(PADDR(e->env_pgdir));
f01031a7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01031aa:	8b 42 5c             	mov    0x5c(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031ad:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031b2:	77 15                	ja     f01031c9 <env_create+0x80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031b4:	50                   	push   %eax
f01031b5:	68 a0 54 10 f0       	push   $0xf01054a0
f01031ba:	68 73 01 00 00       	push   $0x173
f01031bf:	68 f2 60 10 f0       	push   $0xf01060f2
f01031c4:	e8 09 cf ff ff       	call   f01000d2 <_panic>
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
        panic("error elf magic number\n");
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01031c9:	8d 1c 1e             	lea    (%esi,%ebx,1),%ebx
    eph = ph + elf->e_phnum;
f01031cc:	0f b7 ff             	movzwl %di,%edi
f01031cf:	c1 e7 05             	shl    $0x5,%edi
f01031d2:	8d 3c 3b             	lea    (%ebx,%edi,1),%edi
	return (physaddr_t)kva - KERNBASE;
f01031d5:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01031da:	0f 22 d8             	mov    %eax,%cr3

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01031dd:	39 fb                	cmp    %edi,%ebx
f01031df:	73 48                	jae    f0103229 <env_create+0xe0>
        if (ph->p_type == ELF_PROG_LOAD) {
f01031e1:	83 3b 01             	cmpl   $0x1,(%ebx)
f01031e4:	75 3c                	jne    f0103222 <env_create+0xd9>
            // cprintf("%u %u\n", ph->p_memsz, ph->p_filesz);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01031e6:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01031e9:	8b 53 08             	mov    0x8(%ebx),%edx
f01031ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031ef:	e8 20 fc ff ff       	call   f0102e14 <region_alloc>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01031f4:	83 ec 04             	sub    $0x4,%esp
f01031f7:	ff 73 10             	pushl  0x10(%ebx)
f01031fa:	89 f0                	mov    %esi,%eax
f01031fc:	03 43 04             	add    0x4(%ebx),%eax
f01031ff:	50                   	push   %eax
f0103200:	ff 73 08             	pushl  0x8(%ebx)
f0103203:	e8 25 16 00 00       	call   f010482d <memcpy>
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0103208:	8b 43 10             	mov    0x10(%ebx),%eax
f010320b:	83 c4 0c             	add    $0xc,%esp
f010320e:	8b 53 14             	mov    0x14(%ebx),%edx
f0103211:	29 c2                	sub    %eax,%edx
f0103213:	52                   	push   %edx
f0103214:	6a 00                	push   $0x0
f0103216:	03 43 08             	add    0x8(%ebx),%eax
f0103219:	50                   	push   %eax
f010321a:	e8 5a 15 00 00       	call   f0104779 <memset>
f010321f:	83 c4 10             	add    $0x10,%esp
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
    eph = ph + elf->e_phnum;

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f0103222:	83 c3 20             	add    $0x20,%ebx
f0103225:	39 df                	cmp    %ebx,%edi
f0103227:	77 b8                	ja     f01031e1 <env_create+0x98>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
        }
    }
    e->env_tf.tf_eip = elf->e_entry;
f0103229:	8b 46 18             	mov    0x18(%esi),%eax
f010322c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010322f:	89 42 30             	mov    %eax,0x30(%edx)

    lcr3(PADDR(kern_pgdir));
f0103232:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103237:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010323c:	77 15                	ja     f0103253 <env_create+0x10a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010323e:	50                   	push   %eax
f010323f:	68 a0 54 10 f0       	push   $0xf01054a0
f0103244:	68 7f 01 00 00       	push   $0x17f
f0103249:	68 f2 60 10 f0       	push   $0xf01060f2
f010324e:	e8 7f ce ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103253:	05 00 00 00 10       	add    $0x10000000,%eax
f0103258:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010325b:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103260:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103265:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103268:	e8 a7 fb ff ff       	call   f0102e14 <region_alloc>
    int r = env_alloc(&e, 0);
    if (r < 0) {
        panic("env_create: %e\n", r);
    }
    load_icode(e, binary, size);
    e->env_type = type;
f010326d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103270:	8b 55 10             	mov    0x10(%ebp),%edx
f0103273:	89 50 50             	mov    %edx,0x50(%eax)
    // cprintf("env_create out\n");
    return;
}
f0103276:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103279:	5b                   	pop    %ebx
f010327a:	5e                   	pop    %esi
f010327b:	5f                   	pop    %edi
f010327c:	c9                   	leave  
f010327d:	c3                   	ret    

f010327e <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010327e:	55                   	push   %ebp
f010327f:	89 e5                	mov    %esp,%ebp
f0103281:	57                   	push   %edi
f0103282:	56                   	push   %esi
f0103283:	53                   	push   %ebx
f0103284:	83 ec 1c             	sub    $0x1c,%esp
f0103287:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010328a:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f010328f:	39 c7                	cmp    %eax,%edi
f0103291:	75 2c                	jne    f01032bf <env_free+0x41>
		lcr3(PADDR(kern_pgdir));
f0103293:	8b 15 48 11 1e f0    	mov    0xf01e1148,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103299:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010329f:	77 15                	ja     f01032b6 <env_free+0x38>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032a1:	52                   	push   %edx
f01032a2:	68 a0 54 10 f0       	push   $0xf01054a0
f01032a7:	68 ae 01 00 00       	push   $0x1ae
f01032ac:	68 f2 60 10 f0       	push   $0xf01060f2
f01032b1:	e8 1c ce ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01032b6:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01032bc:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032bf:	8b 4f 48             	mov    0x48(%edi),%ecx
f01032c2:	ba 00 00 00 00       	mov    $0x0,%edx
f01032c7:	85 c0                	test   %eax,%eax
f01032c9:	74 03                	je     f01032ce <env_free+0x50>
f01032cb:	8b 50 48             	mov    0x48(%eax),%edx
f01032ce:	83 ec 04             	sub    $0x4,%esp
f01032d1:	51                   	push   %ecx
f01032d2:	52                   	push   %edx
f01032d3:	68 5d 61 10 f0       	push   $0xf010615d
f01032d8:	e8 74 02 00 00       	call   f0103551 <cprintf>
f01032dd:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01032e0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032ea:	c1 e0 02             	shl    $0x2,%eax
f01032ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01032f0:	8b 47 5c             	mov    0x5c(%edi),%eax
f01032f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01032f6:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01032f9:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01032ff:	0f 84 ab 00 00 00    	je     f01033b0 <env_free+0x132>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103305:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010330b:	89 f0                	mov    %esi,%eax
f010330d:	c1 e8 0c             	shr    $0xc,%eax
f0103310:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103313:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f0103319:	72 15                	jb     f0103330 <env_free+0xb2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010331b:	56                   	push   %esi
f010331c:	68 6c 56 10 f0       	push   $0xf010566c
f0103321:	68 bd 01 00 00       	push   $0x1bd
f0103326:	68 f2 60 10 f0       	push   $0xf01060f2
f010332b:	e8 a2 cd ff ff       	call   f01000d2 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103330:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103333:	c1 e2 16             	shl    $0x16,%edx
f0103336:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103339:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010333e:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103345:	01 
f0103346:	74 17                	je     f010335f <env_free+0xe1>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103348:	83 ec 08             	sub    $0x8,%esp
f010334b:	89 d8                	mov    %ebx,%eax
f010334d:	c1 e0 0c             	shl    $0xc,%eax
f0103350:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103353:	50                   	push   %eax
f0103354:	ff 77 5c             	pushl  0x5c(%edi)
f0103357:	e8 bf e2 ff ff       	call   f010161b <page_remove>
f010335c:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010335f:	43                   	inc    %ebx
f0103360:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103366:	75 d6                	jne    f010333e <env_free+0xc0>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103368:	8b 47 5c             	mov    0x5c(%edi),%eax
f010336b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010336e:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103375:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103378:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f010337e:	72 14                	jb     f0103394 <env_free+0x116>
		panic("pa2page called with invalid pa");
f0103380:	83 ec 04             	sub    $0x4,%esp
f0103383:	68 54 57 10 f0       	push   $0xf0105754
f0103388:	6a 4f                	push   $0x4f
f010338a:	68 d9 5d 10 f0       	push   $0xf0105dd9
f010338f:	e8 3e cd ff ff       	call   f01000d2 <_panic>
		page_decref(pa2page(pa));
f0103394:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103397:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010339a:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01033a1:	03 05 4c 11 1e f0    	add    0xf01e114c,%eax
f01033a7:	50                   	push   %eax
f01033a8:	e8 f7 e0 ff ff       	call   f01014a4 <page_decref>
f01033ad:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01033b0:	ff 45 e0             	incl   -0x20(%ebp)
f01033b3:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01033ba:	0f 85 27 ff ff ff    	jne    f01032e7 <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01033c0:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033c3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033c8:	77 15                	ja     f01033df <env_free+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033ca:	50                   	push   %eax
f01033cb:	68 a0 54 10 f0       	push   $0xf01054a0
f01033d0:	68 cb 01 00 00       	push   $0x1cb
f01033d5:	68 f2 60 10 f0       	push   $0xf01060f2
f01033da:	e8 f3 cc ff ff       	call   f01000d2 <_panic>
	e->env_pgdir = 0;
f01033df:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f01033e6:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033eb:	c1 e8 0c             	shr    $0xc,%eax
f01033ee:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f01033f4:	72 14                	jb     f010340a <env_free+0x18c>
		panic("pa2page called with invalid pa");
f01033f6:	83 ec 04             	sub    $0x4,%esp
f01033f9:	68 54 57 10 f0       	push   $0xf0105754
f01033fe:	6a 4f                	push   $0x4f
f0103400:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0103405:	e8 c8 cc ff ff       	call   f01000d2 <_panic>
	page_decref(pa2page(pa));
f010340a:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010340d:	c1 e0 03             	shl    $0x3,%eax
f0103410:	03 05 4c 11 1e f0    	add    0xf01e114c,%eax
f0103416:	50                   	push   %eax
f0103417:	e8 88 e0 ff ff       	call   f01014a4 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010341c:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103423:	a1 84 04 1e f0       	mov    0xf01e0484,%eax
f0103428:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010342b:	89 3d 84 04 1e f0    	mov    %edi,0xf01e0484
f0103431:	83 c4 10             	add    $0x10,%esp
}
f0103434:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103437:	5b                   	pop    %ebx
f0103438:	5e                   	pop    %esi
f0103439:	5f                   	pop    %edi
f010343a:	c9                   	leave  
f010343b:	c3                   	ret    

f010343c <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f010343c:	55                   	push   %ebp
f010343d:	89 e5                	mov    %esp,%ebp
f010343f:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0103442:	ff 75 08             	pushl  0x8(%ebp)
f0103445:	e8 34 fe ff ff       	call   f010327e <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f010344a:	c7 04 24 bc 60 10 f0 	movl   $0xf01060bc,(%esp)
f0103451:	e8 fb 00 00 00       	call   f0103551 <cprintf>
f0103456:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0103459:	83 ec 0c             	sub    $0xc,%esp
f010345c:	6a 00                	push   $0x0
f010345e:	e8 31 da ff ff       	call   f0100e94 <monitor>
f0103463:	83 c4 10             	add    $0x10,%esp
f0103466:	eb f1                	jmp    f0103459 <env_destroy+0x1d>

f0103468 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103468:	55                   	push   %ebp
f0103469:	89 e5                	mov    %esp,%ebp
f010346b:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f010346e:	8b 65 08             	mov    0x8(%ebp),%esp
f0103471:	61                   	popa   
f0103472:	07                   	pop    %es
f0103473:	1f                   	pop    %ds
f0103474:	83 c4 08             	add    $0x8,%esp
f0103477:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103478:	68 73 61 10 f0       	push   $0xf0106173
f010347d:	68 f3 01 00 00       	push   $0x1f3
f0103482:	68 f2 60 10 f0       	push   $0xf01060f2
f0103487:	e8 46 cc ff ff       	call   f01000d2 <_panic>

f010348c <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010348c:	55                   	push   %ebp
f010348d:	89 e5                	mov    %esp,%ebp
f010348f:	83 ec 08             	sub    $0x8,%esp
f0103492:	8b 45 08             	mov    0x8(%ebp),%eax
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

    if (curenv != NULL) {
f0103495:	8b 15 80 04 1e f0    	mov    0xf01e0480,%edx
f010349b:	85 d2                	test   %edx,%edx
f010349d:	74 0d                	je     f01034ac <env_run+0x20>
        // context switch
        if (curenv->env_status == ENV_RUNNING) {
f010349f:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f01034a3:	75 07                	jne    f01034ac <env_run+0x20>
            curenv->env_status = ENV_RUNNABLE;
f01034a5:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
        }
        // how about other env_status ? e.g. like ENV_DYING ?
    }
    curenv = e;
f01034ac:	a3 80 04 1e f0       	mov    %eax,0xf01e0480
    curenv->env_status = ENV_RUNNING;
f01034b1:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f01034b8:	ff 40 58             	incl   0x58(%eax)
    
    // may have some problem, because lcr3(x), x should be physical address
    lcr3(PADDR(curenv->env_pgdir));
f01034bb:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034be:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01034c4:	77 15                	ja     f01034db <env_run+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034c6:	52                   	push   %edx
f01034c7:	68 a0 54 10 f0       	push   $0xf01054a0
f01034cc:	68 1e 02 00 00       	push   $0x21e
f01034d1:	68 f2 60 10 f0       	push   $0xf01060f2
f01034d6:	e8 f7 cb ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01034db:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01034e1:	0f 22 da             	mov    %edx,%cr3

    env_pop_tf(&curenv->env_tf);    
f01034e4:	83 ec 0c             	sub    $0xc,%esp
f01034e7:	50                   	push   %eax
f01034e8:	e8 7b ff ff ff       	call   f0103468 <env_pop_tf>
f01034ed:	00 00                	add    %al,(%eax)
	...

f01034f0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01034f0:	55                   	push   %ebp
f01034f1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034f3:	ba 70 00 00 00       	mov    $0x70,%edx
f01034f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01034fb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034fc:	b2 71                	mov    $0x71,%dl
f01034fe:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01034ff:	0f b6 c0             	movzbl %al,%eax
}
f0103502:	c9                   	leave  
f0103503:	c3                   	ret    

f0103504 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103504:	55                   	push   %ebp
f0103505:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103507:	ba 70 00 00 00       	mov    $0x70,%edx
f010350c:	8b 45 08             	mov    0x8(%ebp),%eax
f010350f:	ee                   	out    %al,(%dx)
f0103510:	b2 71                	mov    $0x71,%dl
f0103512:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103515:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103516:	c9                   	leave  
f0103517:	c3                   	ret    

f0103518 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103518:	55                   	push   %ebp
f0103519:	89 e5                	mov    %esp,%ebp
f010351b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010351e:	ff 75 08             	pushl  0x8(%ebp)
f0103521:	e8 c8 d0 ff ff       	call   f01005ee <cputchar>
f0103526:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0103529:	c9                   	leave  
f010352a:	c3                   	ret    

f010352b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010352b:	55                   	push   %ebp
f010352c:	89 e5                	mov    %esp,%ebp
f010352e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103531:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103538:	ff 75 0c             	pushl  0xc(%ebp)
f010353b:	ff 75 08             	pushl  0x8(%ebp)
f010353e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103541:	50                   	push   %eax
f0103542:	68 18 35 10 f0       	push   $0xf0103518
f0103547:	e8 95 0b 00 00       	call   f01040e1 <vprintfmt>
	return cnt;
}
f010354c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010354f:	c9                   	leave  
f0103550:	c3                   	ret    

f0103551 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103551:	55                   	push   %ebp
f0103552:	89 e5                	mov    %esp,%ebp
f0103554:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103557:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010355a:	50                   	push   %eax
f010355b:	ff 75 08             	pushl  0x8(%ebp)
f010355e:	e8 c8 ff ff ff       	call   f010352b <vcprintf>
	va_end(ap);

	return cnt;
}
f0103563:	c9                   	leave  
f0103564:	c3                   	ret    
f0103565:	00 00                	add    %al,(%eax)
	...

f0103568 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103568:	55                   	push   %ebp
f0103569:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f010356b:	c7 05 c4 0c 1e f0 00 	movl   $0xf0000000,0xf01e0cc4
f0103572:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103575:	66 c7 05 c8 0c 1e f0 	movw   $0x10,0xf01e0cc8
f010357c:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010357e:	66 c7 05 28 33 12 f0 	movw   $0x68,0xf0123328
f0103585:	68 00 
f0103587:	b8 c0 0c 1e f0       	mov    $0xf01e0cc0,%eax
f010358c:	66 a3 2a 33 12 f0    	mov    %ax,0xf012332a
f0103592:	89 c2                	mov    %eax,%edx
f0103594:	c1 ea 10             	shr    $0x10,%edx
f0103597:	88 15 2c 33 12 f0    	mov    %dl,0xf012332c
f010359d:	c6 05 2e 33 12 f0 40 	movb   $0x40,0xf012332e
f01035a4:	c1 e8 18             	shr    $0x18,%eax
f01035a7:	a2 2f 33 12 f0       	mov    %al,0xf012332f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01035ac:	c6 05 2d 33 12 f0 89 	movb   $0x89,0xf012332d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01035b3:	b8 28 00 00 00       	mov    $0x28,%eax
f01035b8:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01035bb:	b8 38 33 12 f0       	mov    $0xf0123338,%eax
f01035c0:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01035c3:	c9                   	leave  
f01035c4:	c3                   	ret    

f01035c5 <trap_init>:
}


void
trap_init(void)
{
f01035c5:	55                   	push   %ebp
f01035c6:	89 e5                	mov    %esp,%ebp
f01035c8:	ba 01 00 00 00       	mov    $0x1,%edx
f01035cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01035d2:	eb 02                	jmp    f01035d6 <trap_init+0x11>
f01035d4:	40                   	inc    %eax
f01035d5:	42                   	inc    %edx
    
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
    	if (i == T_BRKPT) {
f01035d6:	83 f8 03             	cmp    $0x3,%eax
f01035d9:	75 30                	jne    f010360b <trap_init+0x46>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
f01035db:	8b 0d 4c 33 12 f0    	mov    0xf012334c,%ecx
f01035e1:	66 89 0d b8 04 1e f0 	mov    %cx,0xf01e04b8
f01035e8:	66 c7 05 ba 04 1e f0 	movw   $0x8,0xf01e04ba
f01035ef:	08 00 
f01035f1:	c6 05 bc 04 1e f0 00 	movb   $0x0,0xf01e04bc
f01035f8:	c6 05 bd 04 1e f0 ee 	movb   $0xee,0xf01e04bd
f01035ff:	c1 e9 10             	shr    $0x10,%ecx
f0103602:	66 89 0d be 04 1e f0 	mov    %cx,0xf01e04be
f0103609:	eb c9                	jmp    f01035d4 <trap_init+0xf>
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f010360b:	8b 0c 85 40 33 12 f0 	mov    -0xfedccc0(,%eax,4),%ecx
f0103612:	66 89 0c c5 a0 04 1e 	mov    %cx,-0xfe1fb60(,%eax,8)
f0103619:	f0 
f010361a:	66 c7 04 c5 a2 04 1e 	movw   $0x8,-0xfe1fb5e(,%eax,8)
f0103621:	f0 08 00 
f0103624:	c6 04 c5 a4 04 1e f0 	movb   $0x0,-0xfe1fb5c(,%eax,8)
f010362b:	00 
f010362c:	c6 04 c5 a5 04 1e f0 	movb   $0x8e,-0xfe1fb5b(,%eax,8)
f0103633:	8e 
f0103634:	c1 e9 10             	shr    $0x10,%ecx
f0103637:	66 89 0c c5 a6 04 1e 	mov    %cx,-0xfe1fb5a(,%eax,8)
f010363e:	f0 
    */
    
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
f010363f:	83 fa 14             	cmp    $0x14,%edx
f0103642:	75 90                	jne    f01035d4 <trap_init+0xf>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
    	}
    }
    SETGATE(idt[48], 0, GD_KT, vec48, 3);
f0103644:	b8 90 33 12 f0       	mov    $0xf0123390,%eax
f0103649:	66 a3 20 06 1e f0    	mov    %ax,0xf01e0620
f010364f:	66 c7 05 22 06 1e f0 	movw   $0x8,0xf01e0622
f0103656:	08 00 
f0103658:	c6 05 24 06 1e f0 00 	movb   $0x0,0xf01e0624
f010365f:	c6 05 25 06 1e f0 ee 	movb   $0xee,0xf01e0625
f0103666:	c1 e8 10             	shr    $0x10,%eax
f0103669:	66 a3 26 06 1e f0    	mov    %ax,0xf01e0626

	// Per-CPU setup 
	trap_init_percpu();
f010366f:	e8 f4 fe ff ff       	call   f0103568 <trap_init_percpu>
}
f0103674:	c9                   	leave  
f0103675:	c3                   	ret    

f0103676 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103676:	55                   	push   %ebp
f0103677:	89 e5                	mov    %esp,%ebp
f0103679:	53                   	push   %ebx
f010367a:	83 ec 0c             	sub    $0xc,%esp
f010367d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103680:	ff 33                	pushl  (%ebx)
f0103682:	68 7f 61 10 f0       	push   $0xf010617f
f0103687:	e8 c5 fe ff ff       	call   f0103551 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010368c:	83 c4 08             	add    $0x8,%esp
f010368f:	ff 73 04             	pushl  0x4(%ebx)
f0103692:	68 8e 61 10 f0       	push   $0xf010618e
f0103697:	e8 b5 fe ff ff       	call   f0103551 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010369c:	83 c4 08             	add    $0x8,%esp
f010369f:	ff 73 08             	pushl  0x8(%ebx)
f01036a2:	68 9d 61 10 f0       	push   $0xf010619d
f01036a7:	e8 a5 fe ff ff       	call   f0103551 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01036ac:	83 c4 08             	add    $0x8,%esp
f01036af:	ff 73 0c             	pushl  0xc(%ebx)
f01036b2:	68 ac 61 10 f0       	push   $0xf01061ac
f01036b7:	e8 95 fe ff ff       	call   f0103551 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01036bc:	83 c4 08             	add    $0x8,%esp
f01036bf:	ff 73 10             	pushl  0x10(%ebx)
f01036c2:	68 bb 61 10 f0       	push   $0xf01061bb
f01036c7:	e8 85 fe ff ff       	call   f0103551 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01036cc:	83 c4 08             	add    $0x8,%esp
f01036cf:	ff 73 14             	pushl  0x14(%ebx)
f01036d2:	68 ca 61 10 f0       	push   $0xf01061ca
f01036d7:	e8 75 fe ff ff       	call   f0103551 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01036dc:	83 c4 08             	add    $0x8,%esp
f01036df:	ff 73 18             	pushl  0x18(%ebx)
f01036e2:	68 d9 61 10 f0       	push   $0xf01061d9
f01036e7:	e8 65 fe ff ff       	call   f0103551 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01036ec:	83 c4 08             	add    $0x8,%esp
f01036ef:	ff 73 1c             	pushl  0x1c(%ebx)
f01036f2:	68 e8 61 10 f0       	push   $0xf01061e8
f01036f7:	e8 55 fe ff ff       	call   f0103551 <cprintf>
f01036fc:	83 c4 10             	add    $0x10,%esp
}
f01036ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103702:	c9                   	leave  
f0103703:	c3                   	ret    

f0103704 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103704:	55                   	push   %ebp
f0103705:	89 e5                	mov    %esp,%ebp
f0103707:	53                   	push   %ebx
f0103708:	83 ec 0c             	sub    $0xc,%esp
f010370b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f010370e:	53                   	push   %ebx
f010370f:	68 1e 63 10 f0       	push   $0xf010631e
f0103714:	e8 38 fe ff ff       	call   f0103551 <cprintf>
	print_regs(&tf->tf_regs);
f0103719:	89 1c 24             	mov    %ebx,(%esp)
f010371c:	e8 55 ff ff ff       	call   f0103676 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103721:	83 c4 08             	add    $0x8,%esp
f0103724:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103728:	50                   	push   %eax
f0103729:	68 39 62 10 f0       	push   $0xf0106239
f010372e:	e8 1e fe ff ff       	call   f0103551 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103733:	83 c4 08             	add    $0x8,%esp
f0103736:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010373a:	50                   	push   %eax
f010373b:	68 4c 62 10 f0       	push   $0xf010624c
f0103740:	e8 0c fe ff ff       	call   f0103551 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103745:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103748:	83 c4 10             	add    $0x10,%esp
f010374b:	83 f8 13             	cmp    $0x13,%eax
f010374e:	77 09                	ja     f0103759 <print_trapframe+0x55>
		return excnames[trapno];
f0103750:	8b 14 85 40 65 10 f0 	mov    -0xfef9ac0(,%eax,4),%edx
f0103757:	eb 11                	jmp    f010376a <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
f0103759:	83 f8 30             	cmp    $0x30,%eax
f010375c:	75 07                	jne    f0103765 <print_trapframe+0x61>
		return "System call";
f010375e:	ba f7 61 10 f0       	mov    $0xf01061f7,%edx
f0103763:	eb 05                	jmp    f010376a <print_trapframe+0x66>
	return "(unknown trap)";
f0103765:	ba 03 62 10 f0       	mov    $0xf0106203,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010376a:	83 ec 04             	sub    $0x4,%esp
f010376d:	52                   	push   %edx
f010376e:	50                   	push   %eax
f010376f:	68 5f 62 10 f0       	push   $0xf010625f
f0103774:	e8 d8 fd ff ff       	call   f0103551 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103779:	83 c4 10             	add    $0x10,%esp
f010377c:	3b 1d a0 0c 1e f0    	cmp    0xf01e0ca0,%ebx
f0103782:	75 1a                	jne    f010379e <print_trapframe+0x9a>
f0103784:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103788:	75 14                	jne    f010379e <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010378a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010378d:	83 ec 08             	sub    $0x8,%esp
f0103790:	50                   	push   %eax
f0103791:	68 71 62 10 f0       	push   $0xf0106271
f0103796:	e8 b6 fd ff ff       	call   f0103551 <cprintf>
f010379b:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f010379e:	83 ec 08             	sub    $0x8,%esp
f01037a1:	ff 73 2c             	pushl  0x2c(%ebx)
f01037a4:	68 80 62 10 f0       	push   $0xf0106280
f01037a9:	e8 a3 fd ff ff       	call   f0103551 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01037ae:	83 c4 10             	add    $0x10,%esp
f01037b1:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01037b5:	75 45                	jne    f01037fc <print_trapframe+0xf8>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01037b7:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01037ba:	a8 01                	test   $0x1,%al
f01037bc:	74 07                	je     f01037c5 <print_trapframe+0xc1>
f01037be:	b9 12 62 10 f0       	mov    $0xf0106212,%ecx
f01037c3:	eb 05                	jmp    f01037ca <print_trapframe+0xc6>
f01037c5:	b9 1d 62 10 f0       	mov    $0xf010621d,%ecx
f01037ca:	a8 02                	test   $0x2,%al
f01037cc:	74 07                	je     f01037d5 <print_trapframe+0xd1>
f01037ce:	ba 29 62 10 f0       	mov    $0xf0106229,%edx
f01037d3:	eb 05                	jmp    f01037da <print_trapframe+0xd6>
f01037d5:	ba 2f 62 10 f0       	mov    $0xf010622f,%edx
f01037da:	a8 04                	test   $0x4,%al
f01037dc:	74 07                	je     f01037e5 <print_trapframe+0xe1>
f01037de:	b8 34 62 10 f0       	mov    $0xf0106234,%eax
f01037e3:	eb 05                	jmp    f01037ea <print_trapframe+0xe6>
f01037e5:	b8 6d 63 10 f0       	mov    $0xf010636d,%eax
f01037ea:	51                   	push   %ecx
f01037eb:	52                   	push   %edx
f01037ec:	50                   	push   %eax
f01037ed:	68 8e 62 10 f0       	push   $0xf010628e
f01037f2:	e8 5a fd ff ff       	call   f0103551 <cprintf>
f01037f7:	83 c4 10             	add    $0x10,%esp
f01037fa:	eb 10                	jmp    f010380c <print_trapframe+0x108>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01037fc:	83 ec 0c             	sub    $0xc,%esp
f01037ff:	68 cf 4e 10 f0       	push   $0xf0104ecf
f0103804:	e8 48 fd ff ff       	call   f0103551 <cprintf>
f0103809:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010380c:	83 ec 08             	sub    $0x8,%esp
f010380f:	ff 73 30             	pushl  0x30(%ebx)
f0103812:	68 9d 62 10 f0       	push   $0xf010629d
f0103817:	e8 35 fd ff ff       	call   f0103551 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010381c:	83 c4 08             	add    $0x8,%esp
f010381f:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103823:	50                   	push   %eax
f0103824:	68 ac 62 10 f0       	push   $0xf01062ac
f0103829:	e8 23 fd ff ff       	call   f0103551 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010382e:	83 c4 08             	add    $0x8,%esp
f0103831:	ff 73 38             	pushl  0x38(%ebx)
f0103834:	68 bf 62 10 f0       	push   $0xf01062bf
f0103839:	e8 13 fd ff ff       	call   f0103551 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010383e:	83 c4 10             	add    $0x10,%esp
f0103841:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103845:	74 25                	je     f010386c <print_trapframe+0x168>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103847:	83 ec 08             	sub    $0x8,%esp
f010384a:	ff 73 3c             	pushl  0x3c(%ebx)
f010384d:	68 ce 62 10 f0       	push   $0xf01062ce
f0103852:	e8 fa fc ff ff       	call   f0103551 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103857:	83 c4 08             	add    $0x8,%esp
f010385a:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010385e:	50                   	push   %eax
f010385f:	68 dd 62 10 f0       	push   $0xf01062dd
f0103864:	e8 e8 fc ff ff       	call   f0103551 <cprintf>
f0103869:	83 c4 10             	add    $0x10,%esp
	}
}
f010386c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010386f:	c9                   	leave  
f0103870:	c3                   	ret    

f0103871 <page_fault_handler>:
	env_run(curenv);
}

void
page_fault_handler(struct Trapframe *tf)
{
f0103871:	55                   	push   %ebp
f0103872:	89 e5                	mov    %esp,%ebp
f0103874:	53                   	push   %ebx
f0103875:	83 ec 04             	sub    $0x4,%esp
f0103878:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010387b:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f010387e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103882:	75 17                	jne    f010389b <page_fault_handler+0x2a>
    	panic("page_fault_handler : page fault in kernel\n");
f0103884:	83 ec 04             	sub    $0x4,%esp
f0103887:	68 b8 64 10 f0       	push   $0xf01064b8
f010388c:	68 1c 01 00 00       	push   $0x11c
f0103891:	68 f0 62 10 f0       	push   $0xf01062f0
f0103896:	e8 37 c8 ff ff       	call   f01000d2 <_panic>
    
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010389b:	ff 73 30             	pushl  0x30(%ebx)
f010389e:	50                   	push   %eax
		curenv->env_id, fault_va, tf->tf_eip);
f010389f:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
    
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01038a4:	ff 70 48             	pushl  0x48(%eax)
f01038a7:	68 e4 64 10 f0       	push   $0xf01064e4
f01038ac:	e8 a0 fc ff ff       	call   f0103551 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01038b1:	89 1c 24             	mov    %ebx,(%esp)
f01038b4:	e8 4b fe ff ff       	call   f0103704 <print_trapframe>
	env_destroy(curenv);
f01038b9:	83 c4 04             	add    $0x4,%esp
f01038bc:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f01038c2:	e8 75 fb ff ff       	call   f010343c <env_destroy>
f01038c7:	83 c4 10             	add    $0x10,%esp
}
f01038ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038cd:	c9                   	leave  
f01038ce:	c3                   	ret    

f01038cf <trap>:
    }
}

void
trap(struct Trapframe *tf)
{
f01038cf:	55                   	push   %ebp
f01038d0:	89 e5                	mov    %esp,%ebp
f01038d2:	57                   	push   %edi
f01038d3:	56                   	push   %esi
f01038d4:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01038d7:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01038d8:	9c                   	pushf  
f01038d9:	58                   	pop    %eax
	
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01038da:	f6 c4 02             	test   $0x2,%ah
f01038dd:	74 19                	je     f01038f8 <trap+0x29>
f01038df:	68 fc 62 10 f0       	push   $0xf01062fc
f01038e4:	68 f3 5d 10 f0       	push   $0xf0105df3
f01038e9:	68 f4 00 00 00       	push   $0xf4
f01038ee:	68 f0 62 10 f0       	push   $0xf01062f0
f01038f3:	e8 da c7 ff ff       	call   f01000d2 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01038f8:	83 ec 08             	sub    $0x8,%esp
f01038fb:	56                   	push   %esi
f01038fc:	68 15 63 10 f0       	push   $0xf0106315
f0103901:	e8 4b fc ff ff       	call   f0103551 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103906:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010390a:	83 e0 03             	and    $0x3,%eax
f010390d:	83 c4 10             	add    $0x10,%esp
f0103910:	83 f8 03             	cmp    $0x3,%eax
f0103913:	75 31                	jne    f0103946 <trap+0x77>
		// Trapped from user mode.
		assert(curenv);
f0103915:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f010391a:	85 c0                	test   %eax,%eax
f010391c:	75 19                	jne    f0103937 <trap+0x68>
f010391e:	68 30 63 10 f0       	push   $0xf0106330
f0103923:	68 f3 5d 10 f0       	push   $0xf0105df3
f0103928:	68 fa 00 00 00       	push   $0xfa
f010392d:	68 f0 62 10 f0       	push   $0xf01062f0
f0103932:	e8 9b c7 ff ff       	call   f01000d2 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103937:	b9 11 00 00 00       	mov    $0x11,%ecx
f010393c:	89 c7                	mov    %eax,%edi
f010393e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103940:	8b 35 80 04 1e f0    	mov    0xf01e0480,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103946:	89 35 a0 0c 1e f0    	mov    %esi,0xf01e0ca0
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
    
    cprintf("TRAP NUM : %u\n", tf->tf_trapno);
f010394c:	83 ec 08             	sub    $0x8,%esp
f010394f:	ff 76 28             	pushl  0x28(%esi)
f0103952:	68 37 63 10 f0       	push   $0xf0106337
f0103957:	e8 f5 fb ff ff       	call   f0103551 <cprintf>

    int r;
    // cprintf("TRAPNO : %d\n", tf->tf_trapno);
    switch (tf->tf_trapno) {
f010395c:	83 c4 10             	add    $0x10,%esp
f010395f:	8b 46 28             	mov    0x28(%esi),%eax
f0103962:	83 f8 03             	cmp    $0x3,%eax
f0103965:	74 3a                	je     f01039a1 <trap+0xd2>
f0103967:	83 f8 03             	cmp    $0x3,%eax
f010396a:	77 07                	ja     f0103973 <trap+0xa4>
f010396c:	83 f8 01             	cmp    $0x1,%eax
f010396f:	75 78                	jne    f01039e9 <trap+0x11a>
f0103971:	eb 0c                	jmp    f010397f <trap+0xb0>
f0103973:	83 f8 0e             	cmp    $0xe,%eax
f0103976:	74 18                	je     f0103990 <trap+0xc1>
f0103978:	83 f8 30             	cmp    $0x30,%eax
f010397b:	75 6c                	jne    f01039e9 <trap+0x11a>
f010397d:	eb 30                	jmp    f01039af <trap+0xe0>
    	case T_DEBUG:
    		monitor(tf);
f010397f:	83 ec 0c             	sub    $0xc,%esp
f0103982:	56                   	push   %esi
f0103983:	e8 0c d5 ff ff       	call   f0100e94 <monitor>
f0103988:	83 c4 10             	add    $0x10,%esp
f010398b:	e9 94 00 00 00       	jmp    f0103a24 <trap+0x155>
    		break;
        case T_PGFLT:
        	page_fault_handler(tf);
f0103990:	83 ec 0c             	sub    $0xc,%esp
f0103993:	56                   	push   %esi
f0103994:	e8 d8 fe ff ff       	call   f0103871 <page_fault_handler>
f0103999:	83 c4 10             	add    $0x10,%esp
f010399c:	e9 83 00 00 00       	jmp    f0103a24 <trap+0x155>
            break;
        case T_BRKPT:
            monitor(tf); 
f01039a1:	83 ec 0c             	sub    $0xc,%esp
f01039a4:	56                   	push   %esi
f01039a5:	e8 ea d4 ff ff       	call   f0100e94 <monitor>
f01039aa:	83 c4 10             	add    $0x10,%esp
f01039ad:	eb 75                	jmp    f0103a24 <trap+0x155>
            break;
        case T_SYSCALL:
            r = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f01039af:	83 ec 08             	sub    $0x8,%esp
f01039b2:	ff 76 04             	pushl  0x4(%esi)
f01039b5:	ff 36                	pushl  (%esi)
f01039b7:	ff 76 10             	pushl  0x10(%esi)
f01039ba:	ff 76 18             	pushl  0x18(%esi)
f01039bd:	ff 76 14             	pushl  0x14(%esi)
f01039c0:	ff 76 1c             	pushl  0x1c(%esi)
f01039c3:	e8 2c 01 00 00       	call   f0103af4 <syscall>
                        tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
            if (r < 0)
f01039c8:	83 c4 20             	add    $0x20,%esp
f01039cb:	85 c0                	test   %eax,%eax
f01039cd:	79 15                	jns    f01039e4 <trap+0x115>
                panic("trap.c/syscall : %e\n", r);
f01039cf:	50                   	push   %eax
f01039d0:	68 46 63 10 f0       	push   $0xf0106346
f01039d5:	68 da 00 00 00       	push   $0xda
f01039da:	68 f0 62 10 f0       	push   $0xf01062f0
f01039df:	e8 ee c6 ff ff       	call   f01000d2 <_panic>
            else
                tf->tf_regs.reg_eax = r;
f01039e4:	89 46 1c             	mov    %eax,0x1c(%esi)
f01039e7:	eb 3b                	jmp    f0103a24 <trap+0x155>
            break;
        default:
	        // Unexpected trap: The user process or the kernel has a bug.
	        print_trapframe(tf);
f01039e9:	83 ec 0c             	sub    $0xc,%esp
f01039ec:	56                   	push   %esi
f01039ed:	e8 12 fd ff ff       	call   f0103704 <print_trapframe>
	        if (tf->tf_cs == GD_KT)
f01039f2:	83 c4 10             	add    $0x10,%esp
f01039f5:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01039fa:	75 17                	jne    f0103a13 <trap+0x144>
		        panic("unhandled trap in kernel");
f01039fc:	83 ec 04             	sub    $0x4,%esp
f01039ff:	68 5b 63 10 f0       	push   $0xf010635b
f0103a04:	68 e2 00 00 00       	push   $0xe2
f0103a09:	68 f0 62 10 f0       	push   $0xf01062f0
f0103a0e:	e8 bf c6 ff ff       	call   f01000d2 <_panic>
	        else {
		        env_destroy(curenv);
f0103a13:	83 ec 0c             	sub    $0xc,%esp
f0103a16:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103a1c:	e8 1b fa ff ff       	call   f010343c <env_destroy>
f0103a21:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103a24:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f0103a29:	85 c0                	test   %eax,%eax
f0103a2b:	74 06                	je     f0103a33 <trap+0x164>
f0103a2d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103a31:	74 19                	je     f0103a4c <trap+0x17d>
f0103a33:	68 08 65 10 f0       	push   $0xf0106508
f0103a38:	68 f3 5d 10 f0       	push   $0xf0105df3
f0103a3d:	68 0c 01 00 00       	push   $0x10c
f0103a42:	68 f0 62 10 f0       	push   $0xf01062f0
f0103a47:	e8 86 c6 ff ff       	call   f01000d2 <_panic>
	env_run(curenv);
f0103a4c:	83 ec 0c             	sub    $0xc,%esp
f0103a4f:	50                   	push   %eax
f0103a50:	e8 37 fa ff ff       	call   f010348c <env_run>
f0103a55:	00 00                	add    %al,(%eax)
	...

f0103a58 <vec0>:
.data
.align 2
.globl vectors
vectors:
.text
	MYTH_NOEC(vec0, T_DIVIDE)
f0103a58:	6a 00                	push   $0x0
f0103a5a:	6a 00                	push   $0x0
f0103a5c:	e9 35 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a61:	90                   	nop

f0103a62 <vec1>:
 	MYTH_NOEC(vec1, T_DEBUG)
f0103a62:	6a 00                	push   $0x0
f0103a64:	6a 01                	push   $0x1
f0103a66:	e9 2b f9 01 00       	jmp    f0123396 <_alltraps>
f0103a6b:	90                   	nop

f0103a6c <vec2>:
 	MYTH_NOEC(vec2, T_NMI)
f0103a6c:	6a 00                	push   $0x0
f0103a6e:	6a 02                	push   $0x2
f0103a70:	e9 21 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a75:	90                   	nop

f0103a76 <vec3>:
 	MYTH_NOEC(vec3, T_BRKPT)
f0103a76:	6a 00                	push   $0x0
f0103a78:	6a 03                	push   $0x3
f0103a7a:	e9 17 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a7f:	90                   	nop

f0103a80 <vec4>:
 	MYTH_NOEC(vec4, T_OFLOW)
f0103a80:	6a 00                	push   $0x0
f0103a82:	6a 04                	push   $0x4
f0103a84:	e9 0d f9 01 00       	jmp    f0123396 <_alltraps>
f0103a89:	90                   	nop

f0103a8a <vec6>:
 	MYTH_NULL()
 	MYTH_NOEC(vec6, T_BOUND)
f0103a8a:	6a 00                	push   $0x0
f0103a8c:	6a 05                	push   $0x5
f0103a8e:	e9 03 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a93:	90                   	nop

f0103a94 <vec7>:
	MYTH_NOEC(vec7, T_DEVICE)
f0103a94:	6a 00                	push   $0x0
f0103a96:	6a 07                	push   $0x7
f0103a98:	e9 f9 f8 01 00       	jmp    f0123396 <_alltraps>
f0103a9d:	90                   	nop

f0103a9e <vec8>:
 	MYTH(vec8, T_DBLFLT)
f0103a9e:	6a 08                	push   $0x8
f0103aa0:	e9 f1 f8 01 00       	jmp    f0123396 <_alltraps>
f0103aa5:	90                   	nop

f0103aa6 <vec10>:
 	MYTH_NULL()
 	MYTH(vec10, T_TSS)
f0103aa6:	6a 0a                	push   $0xa
f0103aa8:	e9 e9 f8 01 00       	jmp    f0123396 <_alltraps>
f0103aad:	90                   	nop

f0103aae <vec11>:
 	MYTH(vec11, T_SEGNP)
f0103aae:	6a 0b                	push   $0xb
f0103ab0:	e9 e1 f8 01 00       	jmp    f0123396 <_alltraps>
f0103ab5:	90                   	nop

f0103ab6 <vec12>:
 	MYTH(vec12, T_STACK)
f0103ab6:	6a 0c                	push   $0xc
f0103ab8:	e9 d9 f8 01 00       	jmp    f0123396 <_alltraps>
f0103abd:	90                   	nop

f0103abe <vec13>:
 	MYTH(vec13, T_GPFLT)
f0103abe:	6a 0d                	push   $0xd
f0103ac0:	e9 d1 f8 01 00       	jmp    f0123396 <_alltraps>
f0103ac5:	90                   	nop

f0103ac6 <vec14>:
 	MYTH(vec14, T_PGFLT) 
f0103ac6:	6a 0e                	push   $0xe
f0103ac8:	e9 c9 f8 01 00       	jmp    f0123396 <_alltraps>
f0103acd:	90                   	nop

f0103ace <vec16>:
 	MYTH_NULL()
 	MYTH_NOEC(vec16, T_FPERR)
f0103ace:	6a 00                	push   $0x0
f0103ad0:	6a 10                	push   $0x10
f0103ad2:	e9 bf f8 01 00       	jmp    f0123396 <_alltraps>
f0103ad7:	90                   	nop

f0103ad8 <vec17>:
 	MYTH(vec17, T_ALIGN)
f0103ad8:	6a 11                	push   $0x11
f0103ada:	e9 b7 f8 01 00       	jmp    f0123396 <_alltraps>
f0103adf:	90                   	nop

f0103ae0 <vec18>:
 	MYTH_NOEC(vec18, T_MCHK)
f0103ae0:	6a 00                	push   $0x0
f0103ae2:	6a 12                	push   $0x12
f0103ae4:	e9 ad f8 01 00       	jmp    f0123396 <_alltraps>
f0103ae9:	90                   	nop

f0103aea <vec19>:
 	MYTH_NOEC(vec19, T_SIMDERR)
f0103aea:	6a 00                	push   $0x0
f0103aec:	6a 13                	push   $0x13
f0103aee:	e9 a3 f8 01 00       	jmp    f0123396 <_alltraps>
	...

f0103af4 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103af4:	55                   	push   %ebp
f0103af5:	89 e5                	mov    %esp,%ebp
f0103af7:	56                   	push   %esi
f0103af8:	53                   	push   %ebx
f0103af9:	83 ec 10             	sub    $0x10,%esp
f0103afc:	8b 45 08             	mov    0x8(%ebp),%eax
f0103aff:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103b02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
    
    switch (syscallno) {
f0103b05:	83 f8 01             	cmp    $0x1,%eax
f0103b08:	74 40                	je     f0103b4a <syscall+0x56>
f0103b0a:	83 f8 01             	cmp    $0x1,%eax
f0103b0d:	72 10                	jb     f0103b1f <syscall+0x2b>
f0103b0f:	83 f8 02             	cmp    $0x2,%eax
f0103b12:	74 40                	je     f0103b54 <syscall+0x60>
f0103b14:	83 f8 03             	cmp    $0x3,%eax
f0103b17:	0f 85 a4 00 00 00    	jne    f0103bc1 <syscall+0xcd>
f0103b1d:	eb 3f                	jmp    f0103b5e <syscall+0x6a>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, (void *)s, len, PTE_U);
f0103b1f:	6a 04                	push   $0x4
f0103b21:	53                   	push   %ebx
f0103b22:	56                   	push   %esi
f0103b23:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103b29:	e8 99 f2 ff ff       	call   f0102dc7 <user_mem_assert>
    
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103b2e:	83 c4 0c             	add    $0xc,%esp
f0103b31:	56                   	push   %esi
f0103b32:	53                   	push   %ebx
f0103b33:	68 45 4f 10 f0       	push   $0xf0104f45
f0103b38:	e8 14 fa ff ff       	call   f0103551 <cprintf>
f0103b3d:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
    
    switch (syscallno) {
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
f0103b40:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b45:	e9 8b 00 00 00       	jmp    f0103bd5 <syscall+0xe1>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103b4a:	e8 79 c9 ff ff       	call   f01004c8 <cons_getc>
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
            break;
        case SYS_cgetc:
            return sys_cgetc();
f0103b4f:	e9 81 00 00 00       	jmp    f0103bd5 <syscall+0xe1>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103b54:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f0103b59:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_cgetc:
            return sys_cgetc();
            return 0;
            break;
        case SYS_getenvid:
            return sys_getenvid();
f0103b5c:	eb 77                	jmp    f0103bd5 <syscall+0xe1>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103b5e:	83 ec 04             	sub    $0x4,%esp
f0103b61:	6a 01                	push   $0x1
f0103b63:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b66:	50                   	push   %eax
f0103b67:	56                   	push   %esi
f0103b68:	e8 2d f3 ff ff       	call   f0102e9a <envid2env>
f0103b6d:	83 c4 10             	add    $0x10,%esp
f0103b70:	85 c0                	test   %eax,%eax
f0103b72:	78 61                	js     f0103bd5 <syscall+0xe1>
		return r;
	if (e == curenv)
f0103b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b77:	8b 15 80 04 1e f0    	mov    0xf01e0480,%edx
f0103b7d:	39 d0                	cmp    %edx,%eax
f0103b7f:	75 15                	jne    f0103b96 <syscall+0xa2>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103b81:	83 ec 08             	sub    $0x8,%esp
f0103b84:	ff 70 48             	pushl  0x48(%eax)
f0103b87:	68 90 65 10 f0       	push   $0xf0106590
f0103b8c:	e8 c0 f9 ff ff       	call   f0103551 <cprintf>
f0103b91:	83 c4 10             	add    $0x10,%esp
f0103b94:	eb 16                	jmp    f0103bac <syscall+0xb8>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103b96:	83 ec 04             	sub    $0x4,%esp
f0103b99:	ff 70 48             	pushl  0x48(%eax)
f0103b9c:	ff 72 48             	pushl  0x48(%edx)
f0103b9f:	68 ab 65 10 f0       	push   $0xf01065ab
f0103ba4:	e8 a8 f9 ff ff       	call   f0103551 <cprintf>
f0103ba9:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103bac:	83 ec 0c             	sub    $0xc,%esp
f0103baf:	ff 75 f4             	pushl  -0xc(%ebp)
f0103bb2:	e8 85 f8 ff ff       	call   f010343c <env_destroy>
f0103bb7:	83 c4 10             	add    $0x10,%esp
	return 0;
f0103bba:	b8 00 00 00 00       	mov    $0x0,%eax
            break;
        case SYS_getenvid:
            return sys_getenvid();
            break;
        case SYS_env_destroy:
            return sys_env_destroy(a1);
f0103bbf:	eb 14                	jmp    f0103bd5 <syscall+0xe1>
            break;
        dafult:
            return -E_INVAL;
	}
    panic("syscall not implemented");
f0103bc1:	83 ec 04             	sub    $0x4,%esp
f0103bc4:	68 c3 65 10 f0       	push   $0xf01065c3
f0103bc9:	6a 5c                	push   $0x5c
f0103bcb:	68 db 65 10 f0       	push   $0xf01065db
f0103bd0:	e8 fd c4 ff ff       	call   f01000d2 <_panic>
}
f0103bd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103bd8:	5b                   	pop    %ebx
f0103bd9:	5e                   	pop    %esi
f0103bda:	c9                   	leave  
f0103bdb:	c3                   	ret    

f0103bdc <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103bdc:	55                   	push   %ebp
f0103bdd:	89 e5                	mov    %esp,%ebp
f0103bdf:	57                   	push   %edi
f0103be0:	56                   	push   %esi
f0103be1:	53                   	push   %ebx
f0103be2:	83 ec 14             	sub    $0x14,%esp
f0103be5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103be8:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103beb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103bee:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103bf1:	8b 1a                	mov    (%edx),%ebx
f0103bf3:	8b 01                	mov    (%ecx),%eax
f0103bf5:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0103bf8:	39 c3                	cmp    %eax,%ebx
f0103bfa:	0f 8f 97 00 00 00    	jg     f0103c97 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0103c00:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103c07:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103c0a:	01 d8                	add    %ebx,%eax
f0103c0c:	89 c7                	mov    %eax,%edi
f0103c0e:	c1 ef 1f             	shr    $0x1f,%edi
f0103c11:	01 c7                	add    %eax,%edi
f0103c13:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103c15:	39 df                	cmp    %ebx,%edi
f0103c17:	7c 31                	jl     f0103c4a <stab_binsearch+0x6e>
f0103c19:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103c1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103c1f:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103c24:	39 f0                	cmp    %esi,%eax
f0103c26:	0f 84 b3 00 00 00    	je     f0103cdf <stab_binsearch+0x103>
f0103c2c:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103c30:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103c34:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103c36:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103c37:	39 d8                	cmp    %ebx,%eax
f0103c39:	7c 0f                	jl     f0103c4a <stab_binsearch+0x6e>
f0103c3b:	0f b6 0a             	movzbl (%edx),%ecx
f0103c3e:	83 ea 0c             	sub    $0xc,%edx
f0103c41:	39 f1                	cmp    %esi,%ecx
f0103c43:	75 f1                	jne    f0103c36 <stab_binsearch+0x5a>
f0103c45:	e9 97 00 00 00       	jmp    f0103ce1 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103c4a:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103c4d:	eb 39                	jmp    f0103c88 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103c4f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103c52:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0103c54:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c57:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103c5e:	eb 28                	jmp    f0103c88 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103c60:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103c63:	76 12                	jbe    f0103c77 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0103c65:	48                   	dec    %eax
f0103c66:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103c69:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103c6c:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c6e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103c75:	eb 11                	jmp    f0103c88 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103c77:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103c7a:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103c7c:	ff 45 0c             	incl   0xc(%ebp)
f0103c7f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c81:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103c88:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103c8b:	0f 8d 76 ff ff ff    	jge    f0103c07 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103c91:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103c95:	75 0d                	jne    f0103ca4 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0103c97:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103c9a:	8b 03                	mov    (%ebx),%eax
f0103c9c:	48                   	dec    %eax
f0103c9d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103ca0:	89 02                	mov    %eax,(%edx)
f0103ca2:	eb 55                	jmp    f0103cf9 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103ca4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103ca7:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103ca9:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103cac:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103cae:	39 c1                	cmp    %eax,%ecx
f0103cb0:	7d 26                	jge    f0103cd8 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0103cb2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103cb5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103cb8:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103cbd:	39 f2                	cmp    %esi,%edx
f0103cbf:	74 17                	je     f0103cd8 <stab_binsearch+0xfc>
f0103cc1:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103cc5:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103cc9:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103cca:	39 c1                	cmp    %eax,%ecx
f0103ccc:	7d 0a                	jge    f0103cd8 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0103cce:	0f b6 1a             	movzbl (%edx),%ebx
f0103cd1:	83 ea 0c             	sub    $0xc,%edx
f0103cd4:	39 f3                	cmp    %esi,%ebx
f0103cd6:	75 f1                	jne    f0103cc9 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103cd8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103cdb:	89 02                	mov    %eax,(%edx)
f0103cdd:	eb 1a                	jmp    f0103cf9 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103cdf:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103ce1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103ce4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103ce7:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103ceb:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103cee:	0f 82 5b ff ff ff    	jb     f0103c4f <stab_binsearch+0x73>
f0103cf4:	e9 67 ff ff ff       	jmp    f0103c60 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103cf9:	83 c4 14             	add    $0x14,%esp
f0103cfc:	5b                   	pop    %ebx
f0103cfd:	5e                   	pop    %esi
f0103cfe:	5f                   	pop    %edi
f0103cff:	c9                   	leave  
f0103d00:	c3                   	ret    

f0103d01 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103d01:	55                   	push   %ebp
f0103d02:	89 e5                	mov    %esp,%ebp
f0103d04:	57                   	push   %edi
f0103d05:	56                   	push   %esi
f0103d06:	53                   	push   %ebx
f0103d07:	83 ec 2c             	sub    $0x2c,%esp
f0103d0a:	8b 75 08             	mov    0x8(%ebp),%esi
f0103d0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103d10:	c7 03 ea 65 10 f0    	movl   $0xf01065ea,(%ebx)
	info->eip_line = 0;
f0103d16:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103d1d:	c7 43 08 ea 65 10 f0 	movl   $0xf01065ea,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103d24:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103d2b:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103d2e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103d35:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103d3b:	0f 87 89 00 00 00    	ja     f0103dca <debuginfo_eip+0xc9>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
f0103d41:	6a 04                	push   $0x4
f0103d43:	6a 10                	push   $0x10
f0103d45:	68 00 00 20 00       	push   $0x200000
f0103d4a:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103d50:	e8 bf ef ff ff       	call   f0102d14 <user_mem_check>
f0103d55:	83 c4 10             	add    $0x10,%esp
f0103d58:	85 c0                	test   %eax,%eax
f0103d5a:	0f 88 f2 01 00 00    	js     f0103f52 <debuginfo_eip+0x251>
			return -1;
		}
        
		stabs = usd->stabs;
f0103d60:	a1 00 00 20 00       	mov    0x200000,%eax
f0103d65:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f0103d68:	8b 0d 04 00 20 00    	mov    0x200004,%ecx
f0103d6e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr = usd->stabstr;
f0103d71:	a1 08 00 20 00       	mov    0x200008,%eax
f0103d76:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103d79:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
f0103d7f:	6a 04                	push   $0x4
f0103d81:	89 c8                	mov    %ecx,%eax
f0103d83:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0103d86:	50                   	push   %eax
f0103d87:	ff 75 d0             	pushl  -0x30(%ebp)
f0103d8a:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103d90:	e8 7f ef ff ff       	call   f0102d14 <user_mem_check>
f0103d95:	83 c4 10             	add    $0x10,%esp
f0103d98:	85 c0                	test   %eax,%eax
f0103d9a:	0f 88 b9 01 00 00    	js     f0103f59 <debuginfo_eip+0x258>
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0103da0:	6a 04                	push   $0x4
f0103da2:	89 f8                	mov    %edi,%eax
f0103da4:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0103da7:	50                   	push   %eax
f0103da8:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103dab:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103db1:	e8 5e ef ff ff       	call   f0102d14 <user_mem_check>
f0103db6:	89 c2                	mov    %eax,%edx
f0103db8:	83 c4 10             	add    $0x10,%esp
			return -1;
f0103dbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0103dc0:	85 d2                	test   %edx,%edx
f0103dc2:	0f 88 ab 01 00 00    	js     f0103f73 <debuginfo_eip+0x272>
f0103dc8:	eb 1a                	jmp    f0103de4 <debuginfo_eip+0xe3>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103dca:	bf b8 84 11 f0       	mov    $0xf01184b8,%edi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103dcf:	c7 45 d4 59 fe 10 f0 	movl   $0xf010fe59,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103dd6:	c7 45 cc 58 fe 10 f0 	movl   $0xf010fe58,-0x34(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103ddd:	c7 45 d0 04 68 10 f0 	movl   $0xf0106804,-0x30(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103de4:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0103de7:	0f 83 73 01 00 00    	jae    f0103f60 <debuginfo_eip+0x25f>
f0103ded:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0103df1:	0f 85 70 01 00 00    	jne    f0103f67 <debuginfo_eip+0x266>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103df7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103dfe:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103e01:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0103e04:	c1 f8 02             	sar    $0x2,%eax
f0103e07:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103e0d:	48                   	dec    %eax
f0103e0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103e11:	83 ec 08             	sub    $0x8,%esp
f0103e14:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103e17:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103e1a:	56                   	push   %esi
f0103e1b:	6a 64                	push   $0x64
f0103e1d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103e20:	e8 b7 fd ff ff       	call   f0103bdc <stab_binsearch>
	if (lfile == 0)
f0103e25:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103e28:	83 c4 10             	add    $0x10,%esp
		return -1;
f0103e2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0103e30:	85 d2                	test   %edx,%edx
f0103e32:	0f 84 3b 01 00 00    	je     f0103f73 <debuginfo_eip+0x272>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103e38:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0103e3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e3e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103e41:	83 ec 08             	sub    $0x8,%esp
f0103e44:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103e47:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103e4a:	56                   	push   %esi
f0103e4b:	6a 24                	push   $0x24
f0103e4d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103e50:	e8 87 fd ff ff       	call   f0103bdc <stab_binsearch>

	if (lfun <= rfun) {
f0103e55:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103e58:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0103e5b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103e5e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103e61:	83 c4 10             	add    $0x10,%esp
f0103e64:	39 c1                	cmp    %eax,%ecx
f0103e66:	7f 21                	jg     f0103e89 <debuginfo_eip+0x188>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103e68:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0103e6b:	03 45 d0             	add    -0x30(%ebp),%eax
f0103e6e:	8b 10                	mov    (%eax),%edx
f0103e70:	89 f9                	mov    %edi,%ecx
f0103e72:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f0103e75:	39 ca                	cmp    %ecx,%edx
f0103e77:	73 06                	jae    f0103e7f <debuginfo_eip+0x17e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103e79:	03 55 d4             	add    -0x2c(%ebp),%edx
f0103e7c:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103e7f:	8b 40 08             	mov    0x8(%eax),%eax
f0103e82:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103e85:	29 c6                	sub    %eax,%esi
f0103e87:	eb 0f                	jmp    f0103e98 <debuginfo_eip+0x197>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103e89:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103e8c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103e8f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		rline = rfile;
f0103e92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e95:	89 45 c8             	mov    %eax,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103e98:	83 ec 08             	sub    $0x8,%esp
f0103e9b:	6a 3a                	push   $0x3a
f0103e9d:	ff 73 08             	pushl  0x8(%ebx)
f0103ea0:	e8 b2 08 00 00       	call   f0104757 <strfind>
f0103ea5:	2b 43 08             	sub    0x8(%ebx),%eax
f0103ea8:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0103eab:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103eae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    rfun = rline;
f0103eb1:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103eb4:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0103eb7:	83 c4 08             	add    $0x8,%esp
f0103eba:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103ebd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103ec0:	56                   	push   %esi
f0103ec1:	6a 44                	push   $0x44
f0103ec3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103ec6:	e8 11 fd ff ff       	call   f0103bdc <stab_binsearch>
    if (lfun <= rfun) {
f0103ecb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103ece:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0103ed1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0103ed6:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0103ed9:	0f 8f 94 00 00 00    	jg     f0103f73 <debuginfo_eip+0x272>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0103edf:	6b ca 0c             	imul   $0xc,%edx,%ecx
f0103ee2:	03 4d d0             	add    -0x30(%ebp),%ecx
f0103ee5:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f0103ee9:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103eec:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103eef:	89 75 cc             	mov    %esi,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103ef2:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103ef5:	eb 04                	jmp    f0103efb <debuginfo_eip+0x1fa>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103ef7:	4a                   	dec    %edx
f0103ef8:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103efb:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f0103efe:	7c 19                	jl     f0103f19 <debuginfo_eip+0x218>
	       && stabs[lline].n_type != N_SOL
f0103f00:	8a 48 fc             	mov    -0x4(%eax),%cl
f0103f03:	80 f9 84             	cmp    $0x84,%cl
f0103f06:	74 73                	je     f0103f7b <debuginfo_eip+0x27a>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103f08:	80 f9 64             	cmp    $0x64,%cl
f0103f0b:	75 ea                	jne    f0103ef7 <debuginfo_eip+0x1f6>
f0103f0d:	83 38 00             	cmpl   $0x0,(%eax)
f0103f10:	74 e5                	je     f0103ef7 <debuginfo_eip+0x1f6>
f0103f12:	eb 67                	jmp    f0103f7b <debuginfo_eip+0x27a>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103f14:	03 45 d4             	add    -0x2c(%ebp),%eax
f0103f17:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103f19:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103f1c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f1f:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103f24:	39 ca                	cmp    %ecx,%edx
f0103f26:	7d 4b                	jge    f0103f73 <debuginfo_eip+0x272>
		for (lline = lfun + 1;
f0103f28:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103f2b:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103f2e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103f31:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0103f35:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103f37:	eb 04                	jmp    f0103f3d <debuginfo_eip+0x23c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103f39:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103f3c:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103f3d:	39 f0                	cmp    %esi,%eax
f0103f3f:	7d 2d                	jge    f0103f6e <debuginfo_eip+0x26d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103f41:	8a 0a                	mov    (%edx),%cl
f0103f43:	83 c2 0c             	add    $0xc,%edx
f0103f46:	80 f9 a0             	cmp    $0xa0,%cl
f0103f49:	74 ee                	je     f0103f39 <debuginfo_eip+0x238>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f4b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f50:	eb 21                	jmp    f0103f73 <debuginfo_eip+0x272>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
f0103f52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f57:	eb 1a                	jmp    f0103f73 <debuginfo_eip+0x272>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
f0103f59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f5e:	eb 13                	jmp    f0103f73 <debuginfo_eip+0x272>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103f60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f65:	eb 0c                	jmp    f0103f73 <debuginfo_eip+0x272>
f0103f67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f6c:	eb 05                	jmp    f0103f73 <debuginfo_eip+0x272>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f76:	5b                   	pop    %ebx
f0103f77:	5e                   	pop    %esi
f0103f78:	5f                   	pop    %edi
f0103f79:	c9                   	leave  
f0103f7a:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103f7b:	6b d2 0c             	imul   $0xc,%edx,%edx
f0103f7e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103f81:	8b 04 16             	mov    (%esi,%edx,1),%eax
f0103f84:	2b 7d d4             	sub    -0x2c(%ebp),%edi
f0103f87:	39 f8                	cmp    %edi,%eax
f0103f89:	72 89                	jb     f0103f14 <debuginfo_eip+0x213>
f0103f8b:	eb 8c                	jmp    f0103f19 <debuginfo_eip+0x218>
f0103f8d:	00 00                	add    %al,(%eax)
	...

f0103f90 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103f90:	55                   	push   %ebp
f0103f91:	89 e5                	mov    %esp,%ebp
f0103f93:	57                   	push   %edi
f0103f94:	56                   	push   %esi
f0103f95:	53                   	push   %ebx
f0103f96:	83 ec 2c             	sub    $0x2c,%esp
f0103f99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103f9c:	89 d6                	mov    %edx,%esi
f0103f9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fa1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103fa4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103fa7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103faa:	8b 45 10             	mov    0x10(%ebp),%eax
f0103fad:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103fb0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103fb3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103fb6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0103fbd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0103fc0:	72 0c                	jb     f0103fce <printnum+0x3e>
f0103fc2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103fc5:	76 07                	jbe    f0103fce <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103fc7:	4b                   	dec    %ebx
f0103fc8:	85 db                	test   %ebx,%ebx
f0103fca:	7f 31                	jg     f0103ffd <printnum+0x6d>
f0103fcc:	eb 3f                	jmp    f010400d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103fce:	83 ec 0c             	sub    $0xc,%esp
f0103fd1:	57                   	push   %edi
f0103fd2:	4b                   	dec    %ebx
f0103fd3:	53                   	push   %ebx
f0103fd4:	50                   	push   %eax
f0103fd5:	83 ec 08             	sub    $0x8,%esp
f0103fd8:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103fdb:	ff 75 d0             	pushl  -0x30(%ebp)
f0103fde:	ff 75 dc             	pushl  -0x24(%ebp)
f0103fe1:	ff 75 d8             	pushl  -0x28(%ebp)
f0103fe4:	e8 97 09 00 00       	call   f0104980 <__udivdi3>
f0103fe9:	83 c4 18             	add    $0x18,%esp
f0103fec:	52                   	push   %edx
f0103fed:	50                   	push   %eax
f0103fee:	89 f2                	mov    %esi,%edx
f0103ff0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ff3:	e8 98 ff ff ff       	call   f0103f90 <printnum>
f0103ff8:	83 c4 20             	add    $0x20,%esp
f0103ffb:	eb 10                	jmp    f010400d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103ffd:	83 ec 08             	sub    $0x8,%esp
f0104000:	56                   	push   %esi
f0104001:	57                   	push   %edi
f0104002:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104005:	4b                   	dec    %ebx
f0104006:	83 c4 10             	add    $0x10,%esp
f0104009:	85 db                	test   %ebx,%ebx
f010400b:	7f f0                	jg     f0103ffd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010400d:	83 ec 08             	sub    $0x8,%esp
f0104010:	56                   	push   %esi
f0104011:	83 ec 04             	sub    $0x4,%esp
f0104014:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104017:	ff 75 d0             	pushl  -0x30(%ebp)
f010401a:	ff 75 dc             	pushl  -0x24(%ebp)
f010401d:	ff 75 d8             	pushl  -0x28(%ebp)
f0104020:	e8 77 0a 00 00       	call   f0104a9c <__umoddi3>
f0104025:	83 c4 14             	add    $0x14,%esp
f0104028:	0f be 80 f4 65 10 f0 	movsbl -0xfef9a0c(%eax),%eax
f010402f:	50                   	push   %eax
f0104030:	ff 55 e4             	call   *-0x1c(%ebp)
f0104033:	83 c4 10             	add    $0x10,%esp
}
f0104036:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104039:	5b                   	pop    %ebx
f010403a:	5e                   	pop    %esi
f010403b:	5f                   	pop    %edi
f010403c:	c9                   	leave  
f010403d:	c3                   	ret    

f010403e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010403e:	55                   	push   %ebp
f010403f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104041:	83 fa 01             	cmp    $0x1,%edx
f0104044:	7e 0e                	jle    f0104054 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104046:	8b 10                	mov    (%eax),%edx
f0104048:	8d 4a 08             	lea    0x8(%edx),%ecx
f010404b:	89 08                	mov    %ecx,(%eax)
f010404d:	8b 02                	mov    (%edx),%eax
f010404f:	8b 52 04             	mov    0x4(%edx),%edx
f0104052:	eb 22                	jmp    f0104076 <getuint+0x38>
	else if (lflag)
f0104054:	85 d2                	test   %edx,%edx
f0104056:	74 10                	je     f0104068 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104058:	8b 10                	mov    (%eax),%edx
f010405a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010405d:	89 08                	mov    %ecx,(%eax)
f010405f:	8b 02                	mov    (%edx),%eax
f0104061:	ba 00 00 00 00       	mov    $0x0,%edx
f0104066:	eb 0e                	jmp    f0104076 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104068:	8b 10                	mov    (%eax),%edx
f010406a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010406d:	89 08                	mov    %ecx,(%eax)
f010406f:	8b 02                	mov    (%edx),%eax
f0104071:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104076:	c9                   	leave  
f0104077:	c3                   	ret    

f0104078 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0104078:	55                   	push   %ebp
f0104079:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010407b:	83 fa 01             	cmp    $0x1,%edx
f010407e:	7e 0e                	jle    f010408e <getint+0x16>
		return va_arg(*ap, long long);
f0104080:	8b 10                	mov    (%eax),%edx
f0104082:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104085:	89 08                	mov    %ecx,(%eax)
f0104087:	8b 02                	mov    (%edx),%eax
f0104089:	8b 52 04             	mov    0x4(%edx),%edx
f010408c:	eb 1a                	jmp    f01040a8 <getint+0x30>
	else if (lflag)
f010408e:	85 d2                	test   %edx,%edx
f0104090:	74 0c                	je     f010409e <getint+0x26>
		return va_arg(*ap, long);
f0104092:	8b 10                	mov    (%eax),%edx
f0104094:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104097:	89 08                	mov    %ecx,(%eax)
f0104099:	8b 02                	mov    (%edx),%eax
f010409b:	99                   	cltd   
f010409c:	eb 0a                	jmp    f01040a8 <getint+0x30>
	else
		return va_arg(*ap, int);
f010409e:	8b 10                	mov    (%eax),%edx
f01040a0:	8d 4a 04             	lea    0x4(%edx),%ecx
f01040a3:	89 08                	mov    %ecx,(%eax)
f01040a5:	8b 02                	mov    (%edx),%eax
f01040a7:	99                   	cltd   
}
f01040a8:	c9                   	leave  
f01040a9:	c3                   	ret    

f01040aa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01040aa:	55                   	push   %ebp
f01040ab:	89 e5                	mov    %esp,%ebp
f01040ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01040b0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01040b3:	8b 10                	mov    (%eax),%edx
f01040b5:	3b 50 04             	cmp    0x4(%eax),%edx
f01040b8:	73 08                	jae    f01040c2 <sprintputch+0x18>
		*b->buf++ = ch;
f01040ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01040bd:	88 0a                	mov    %cl,(%edx)
f01040bf:	42                   	inc    %edx
f01040c0:	89 10                	mov    %edx,(%eax)
}
f01040c2:	c9                   	leave  
f01040c3:	c3                   	ret    

f01040c4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01040c4:	55                   	push   %ebp
f01040c5:	89 e5                	mov    %esp,%ebp
f01040c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01040ca:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01040cd:	50                   	push   %eax
f01040ce:	ff 75 10             	pushl  0x10(%ebp)
f01040d1:	ff 75 0c             	pushl  0xc(%ebp)
f01040d4:	ff 75 08             	pushl  0x8(%ebp)
f01040d7:	e8 05 00 00 00       	call   f01040e1 <vprintfmt>
	va_end(ap);
f01040dc:	83 c4 10             	add    $0x10,%esp
}
f01040df:	c9                   	leave  
f01040e0:	c3                   	ret    

f01040e1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01040e1:	55                   	push   %ebp
f01040e2:	89 e5                	mov    %esp,%ebp
f01040e4:	57                   	push   %edi
f01040e5:	56                   	push   %esi
f01040e6:	53                   	push   %ebx
f01040e7:	83 ec 2c             	sub    $0x2c,%esp
f01040ea:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01040ed:	8b 75 10             	mov    0x10(%ebp),%esi
f01040f0:	eb 13                	jmp    f0104105 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01040f2:	85 c0                	test   %eax,%eax
f01040f4:	0f 84 6d 03 00 00    	je     f0104467 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f01040fa:	83 ec 08             	sub    $0x8,%esp
f01040fd:	57                   	push   %edi
f01040fe:	50                   	push   %eax
f01040ff:	ff 55 08             	call   *0x8(%ebp)
f0104102:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104105:	0f b6 06             	movzbl (%esi),%eax
f0104108:	46                   	inc    %esi
f0104109:	83 f8 25             	cmp    $0x25,%eax
f010410c:	75 e4                	jne    f01040f2 <vprintfmt+0x11>
f010410e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0104112:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104119:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0104120:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0104127:	b9 00 00 00 00       	mov    $0x0,%ecx
f010412c:	eb 28                	jmp    f0104156 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010412e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104130:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0104134:	eb 20                	jmp    f0104156 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104136:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104138:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f010413c:	eb 18                	jmp    f0104156 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010413e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0104140:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104147:	eb 0d                	jmp    f0104156 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104149:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010414c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010414f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104156:	8a 06                	mov    (%esi),%al
f0104158:	0f b6 d0             	movzbl %al,%edx
f010415b:	8d 5e 01             	lea    0x1(%esi),%ebx
f010415e:	83 e8 23             	sub    $0x23,%eax
f0104161:	3c 55                	cmp    $0x55,%al
f0104163:	0f 87 e0 02 00 00    	ja     f0104449 <vprintfmt+0x368>
f0104169:	0f b6 c0             	movzbl %al,%eax
f010416c:	ff 24 85 80 66 10 f0 	jmp    *-0xfef9980(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104173:	83 ea 30             	sub    $0x30,%edx
f0104176:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0104179:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f010417c:	8d 50 d0             	lea    -0x30(%eax),%edx
f010417f:	83 fa 09             	cmp    $0x9,%edx
f0104182:	77 44                	ja     f01041c8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104184:	89 de                	mov    %ebx,%esi
f0104186:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104189:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f010418a:	8d 14 92             	lea    (%edx,%edx,4),%edx
f010418d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0104191:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0104194:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0104197:	83 fb 09             	cmp    $0x9,%ebx
f010419a:	76 ed                	jbe    f0104189 <vprintfmt+0xa8>
f010419c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010419f:	eb 29                	jmp    f01041ca <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01041a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01041a4:	8d 50 04             	lea    0x4(%eax),%edx
f01041a7:	89 55 14             	mov    %edx,0x14(%ebp)
f01041aa:	8b 00                	mov    (%eax),%eax
f01041ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041af:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01041b1:	eb 17                	jmp    f01041ca <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f01041b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01041b7:	78 85                	js     f010413e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041b9:	89 de                	mov    %ebx,%esi
f01041bb:	eb 99                	jmp    f0104156 <vprintfmt+0x75>
f01041bd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01041bf:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f01041c6:	eb 8e                	jmp    f0104156 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041c8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01041ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01041ce:	79 86                	jns    f0104156 <vprintfmt+0x75>
f01041d0:	e9 74 ff ff ff       	jmp    f0104149 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01041d5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041d6:	89 de                	mov    %ebx,%esi
f01041d8:	e9 79 ff ff ff       	jmp    f0104156 <vprintfmt+0x75>
f01041dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01041e0:	8b 45 14             	mov    0x14(%ebp),%eax
f01041e3:	8d 50 04             	lea    0x4(%eax),%edx
f01041e6:	89 55 14             	mov    %edx,0x14(%ebp)
f01041e9:	83 ec 08             	sub    $0x8,%esp
f01041ec:	57                   	push   %edi
f01041ed:	ff 30                	pushl  (%eax)
f01041ef:	ff 55 08             	call   *0x8(%ebp)
			break;
f01041f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041f5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01041f8:	e9 08 ff ff ff       	jmp    f0104105 <vprintfmt+0x24>
f01041fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104200:	8b 45 14             	mov    0x14(%ebp),%eax
f0104203:	8d 50 04             	lea    0x4(%eax),%edx
f0104206:	89 55 14             	mov    %edx,0x14(%ebp)
f0104209:	8b 00                	mov    (%eax),%eax
f010420b:	85 c0                	test   %eax,%eax
f010420d:	79 02                	jns    f0104211 <vprintfmt+0x130>
f010420f:	f7 d8                	neg    %eax
f0104211:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104213:	83 f8 06             	cmp    $0x6,%eax
f0104216:	7f 0b                	jg     f0104223 <vprintfmt+0x142>
f0104218:	8b 04 85 d8 67 10 f0 	mov    -0xfef9828(,%eax,4),%eax
f010421f:	85 c0                	test   %eax,%eax
f0104221:	75 1a                	jne    f010423d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0104223:	52                   	push   %edx
f0104224:	68 0c 66 10 f0       	push   $0xf010660c
f0104229:	57                   	push   %edi
f010422a:	ff 75 08             	pushl  0x8(%ebp)
f010422d:	e8 92 fe ff ff       	call   f01040c4 <printfmt>
f0104232:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104235:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104238:	e9 c8 fe ff ff       	jmp    f0104105 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f010423d:	50                   	push   %eax
f010423e:	68 05 5e 10 f0       	push   $0xf0105e05
f0104243:	57                   	push   %edi
f0104244:	ff 75 08             	pushl  0x8(%ebp)
f0104247:	e8 78 fe ff ff       	call   f01040c4 <printfmt>
f010424c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010424f:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0104252:	e9 ae fe ff ff       	jmp    f0104105 <vprintfmt+0x24>
f0104257:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f010425a:	89 de                	mov    %ebx,%esi
f010425c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010425f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104262:	8b 45 14             	mov    0x14(%ebp),%eax
f0104265:	8d 50 04             	lea    0x4(%eax),%edx
f0104268:	89 55 14             	mov    %edx,0x14(%ebp)
f010426b:	8b 00                	mov    (%eax),%eax
f010426d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104270:	85 c0                	test   %eax,%eax
f0104272:	75 07                	jne    f010427b <vprintfmt+0x19a>
				p = "(null)";
f0104274:	c7 45 d0 05 66 10 f0 	movl   $0xf0106605,-0x30(%ebp)
			if (width > 0 && padc != '-')
f010427b:	85 db                	test   %ebx,%ebx
f010427d:	7e 42                	jle    f01042c1 <vprintfmt+0x1e0>
f010427f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0104283:	74 3c                	je     f01042c1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104285:	83 ec 08             	sub    $0x8,%esp
f0104288:	51                   	push   %ecx
f0104289:	ff 75 d0             	pushl  -0x30(%ebp)
f010428c:	e8 3f 03 00 00       	call   f01045d0 <strnlen>
f0104291:	29 c3                	sub    %eax,%ebx
f0104293:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104296:	83 c4 10             	add    $0x10,%esp
f0104299:	85 db                	test   %ebx,%ebx
f010429b:	7e 24                	jle    f01042c1 <vprintfmt+0x1e0>
					putch(padc, putdat);
f010429d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f01042a1:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01042a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01042a7:	83 ec 08             	sub    $0x8,%esp
f01042aa:	57                   	push   %edi
f01042ab:	53                   	push   %ebx
f01042ac:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01042af:	4e                   	dec    %esi
f01042b0:	83 c4 10             	add    $0x10,%esp
f01042b3:	85 f6                	test   %esi,%esi
f01042b5:	7f f0                	jg     f01042a7 <vprintfmt+0x1c6>
f01042b7:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01042ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01042c1:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01042c4:	0f be 02             	movsbl (%edx),%eax
f01042c7:	85 c0                	test   %eax,%eax
f01042c9:	75 47                	jne    f0104312 <vprintfmt+0x231>
f01042cb:	eb 37                	jmp    f0104304 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f01042cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01042d1:	74 16                	je     f01042e9 <vprintfmt+0x208>
f01042d3:	8d 50 e0             	lea    -0x20(%eax),%edx
f01042d6:	83 fa 5e             	cmp    $0x5e,%edx
f01042d9:	76 0e                	jbe    f01042e9 <vprintfmt+0x208>
					putch('?', putdat);
f01042db:	83 ec 08             	sub    $0x8,%esp
f01042de:	57                   	push   %edi
f01042df:	6a 3f                	push   $0x3f
f01042e1:	ff 55 08             	call   *0x8(%ebp)
f01042e4:	83 c4 10             	add    $0x10,%esp
f01042e7:	eb 0b                	jmp    f01042f4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f01042e9:	83 ec 08             	sub    $0x8,%esp
f01042ec:	57                   	push   %edi
f01042ed:	50                   	push   %eax
f01042ee:	ff 55 08             	call   *0x8(%ebp)
f01042f1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01042f4:	ff 4d e4             	decl   -0x1c(%ebp)
f01042f7:	0f be 03             	movsbl (%ebx),%eax
f01042fa:	85 c0                	test   %eax,%eax
f01042fc:	74 03                	je     f0104301 <vprintfmt+0x220>
f01042fe:	43                   	inc    %ebx
f01042ff:	eb 1b                	jmp    f010431c <vprintfmt+0x23b>
f0104301:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104304:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104308:	7f 1e                	jg     f0104328 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010430a:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010430d:	e9 f3 fd ff ff       	jmp    f0104105 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104312:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104315:	43                   	inc    %ebx
f0104316:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0104319:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010431c:	85 f6                	test   %esi,%esi
f010431e:	78 ad                	js     f01042cd <vprintfmt+0x1ec>
f0104320:	4e                   	dec    %esi
f0104321:	79 aa                	jns    f01042cd <vprintfmt+0x1ec>
f0104323:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104326:	eb dc                	jmp    f0104304 <vprintfmt+0x223>
f0104328:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010432b:	83 ec 08             	sub    $0x8,%esp
f010432e:	57                   	push   %edi
f010432f:	6a 20                	push   $0x20
f0104331:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104334:	4b                   	dec    %ebx
f0104335:	83 c4 10             	add    $0x10,%esp
f0104338:	85 db                	test   %ebx,%ebx
f010433a:	7f ef                	jg     f010432b <vprintfmt+0x24a>
f010433c:	e9 c4 fd ff ff       	jmp    f0104105 <vprintfmt+0x24>
f0104341:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104344:	89 ca                	mov    %ecx,%edx
f0104346:	8d 45 14             	lea    0x14(%ebp),%eax
f0104349:	e8 2a fd ff ff       	call   f0104078 <getint>
f010434e:	89 c3                	mov    %eax,%ebx
f0104350:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0104352:	85 d2                	test   %edx,%edx
f0104354:	78 0a                	js     f0104360 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104356:	b8 0a 00 00 00       	mov    $0xa,%eax
f010435b:	e9 b0 00 00 00       	jmp    f0104410 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0104360:	83 ec 08             	sub    $0x8,%esp
f0104363:	57                   	push   %edi
f0104364:	6a 2d                	push   $0x2d
f0104366:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104369:	f7 db                	neg    %ebx
f010436b:	83 d6 00             	adc    $0x0,%esi
f010436e:	f7 de                	neg    %esi
f0104370:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104373:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104378:	e9 93 00 00 00       	jmp    f0104410 <vprintfmt+0x32f>
f010437d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104380:	89 ca                	mov    %ecx,%edx
f0104382:	8d 45 14             	lea    0x14(%ebp),%eax
f0104385:	e8 b4 fc ff ff       	call   f010403e <getuint>
f010438a:	89 c3                	mov    %eax,%ebx
f010438c:	89 d6                	mov    %edx,%esi
			base = 10;
f010438e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0104393:	eb 7b                	jmp    f0104410 <vprintfmt+0x32f>
f0104395:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0104398:	89 ca                	mov    %ecx,%edx
f010439a:	8d 45 14             	lea    0x14(%ebp),%eax
f010439d:	e8 d6 fc ff ff       	call   f0104078 <getint>
f01043a2:	89 c3                	mov    %eax,%ebx
f01043a4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f01043a6:	85 d2                	test   %edx,%edx
f01043a8:	78 07                	js     f01043b1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f01043aa:	b8 08 00 00 00       	mov    $0x8,%eax
f01043af:	eb 5f                	jmp    f0104410 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f01043b1:	83 ec 08             	sub    $0x8,%esp
f01043b4:	57                   	push   %edi
f01043b5:	6a 2d                	push   $0x2d
f01043b7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f01043ba:	f7 db                	neg    %ebx
f01043bc:	83 d6 00             	adc    $0x0,%esi
f01043bf:	f7 de                	neg    %esi
f01043c1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f01043c4:	b8 08 00 00 00       	mov    $0x8,%eax
f01043c9:	eb 45                	jmp    f0104410 <vprintfmt+0x32f>
f01043cb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f01043ce:	83 ec 08             	sub    $0x8,%esp
f01043d1:	57                   	push   %edi
f01043d2:	6a 30                	push   $0x30
f01043d4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01043d7:	83 c4 08             	add    $0x8,%esp
f01043da:	57                   	push   %edi
f01043db:	6a 78                	push   $0x78
f01043dd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01043e0:	8b 45 14             	mov    0x14(%ebp),%eax
f01043e3:	8d 50 04             	lea    0x4(%eax),%edx
f01043e6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01043e9:	8b 18                	mov    (%eax),%ebx
f01043eb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01043f0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01043f3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01043f8:	eb 16                	jmp    f0104410 <vprintfmt+0x32f>
f01043fa:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01043fd:	89 ca                	mov    %ecx,%edx
f01043ff:	8d 45 14             	lea    0x14(%ebp),%eax
f0104402:	e8 37 fc ff ff       	call   f010403e <getuint>
f0104407:	89 c3                	mov    %eax,%ebx
f0104409:	89 d6                	mov    %edx,%esi
			base = 16;
f010440b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104410:	83 ec 0c             	sub    $0xc,%esp
f0104413:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0104417:	52                   	push   %edx
f0104418:	ff 75 e4             	pushl  -0x1c(%ebp)
f010441b:	50                   	push   %eax
f010441c:	56                   	push   %esi
f010441d:	53                   	push   %ebx
f010441e:	89 fa                	mov    %edi,%edx
f0104420:	8b 45 08             	mov    0x8(%ebp),%eax
f0104423:	e8 68 fb ff ff       	call   f0103f90 <printnum>
			break;
f0104428:	83 c4 20             	add    $0x20,%esp
f010442b:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010442e:	e9 d2 fc ff ff       	jmp    f0104105 <vprintfmt+0x24>
f0104433:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104436:	83 ec 08             	sub    $0x8,%esp
f0104439:	57                   	push   %edi
f010443a:	52                   	push   %edx
f010443b:	ff 55 08             	call   *0x8(%ebp)
			break;
f010443e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104441:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104444:	e9 bc fc ff ff       	jmp    f0104105 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104449:	83 ec 08             	sub    $0x8,%esp
f010444c:	57                   	push   %edi
f010444d:	6a 25                	push   $0x25
f010444f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104452:	83 c4 10             	add    $0x10,%esp
f0104455:	eb 02                	jmp    f0104459 <vprintfmt+0x378>
f0104457:	89 c6                	mov    %eax,%esi
f0104459:	8d 46 ff             	lea    -0x1(%esi),%eax
f010445c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104460:	75 f5                	jne    f0104457 <vprintfmt+0x376>
f0104462:	e9 9e fc ff ff       	jmp    f0104105 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0104467:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010446a:	5b                   	pop    %ebx
f010446b:	5e                   	pop    %esi
f010446c:	5f                   	pop    %edi
f010446d:	c9                   	leave  
f010446e:	c3                   	ret    

f010446f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010446f:	55                   	push   %ebp
f0104470:	89 e5                	mov    %esp,%ebp
f0104472:	83 ec 18             	sub    $0x18,%esp
f0104475:	8b 45 08             	mov    0x8(%ebp),%eax
f0104478:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010447b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010447e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104482:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104485:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010448c:	85 c0                	test   %eax,%eax
f010448e:	74 26                	je     f01044b6 <vsnprintf+0x47>
f0104490:	85 d2                	test   %edx,%edx
f0104492:	7e 29                	jle    f01044bd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104494:	ff 75 14             	pushl  0x14(%ebp)
f0104497:	ff 75 10             	pushl  0x10(%ebp)
f010449a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010449d:	50                   	push   %eax
f010449e:	68 aa 40 10 f0       	push   $0xf01040aa
f01044a3:	e8 39 fc ff ff       	call   f01040e1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01044a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01044ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01044ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01044b1:	83 c4 10             	add    $0x10,%esp
f01044b4:	eb 0c                	jmp    f01044c2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01044b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01044bb:	eb 05                	jmp    f01044c2 <vsnprintf+0x53>
f01044bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01044c2:	c9                   	leave  
f01044c3:	c3                   	ret    

f01044c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01044c4:	55                   	push   %ebp
f01044c5:	89 e5                	mov    %esp,%ebp
f01044c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01044ca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01044cd:	50                   	push   %eax
f01044ce:	ff 75 10             	pushl  0x10(%ebp)
f01044d1:	ff 75 0c             	pushl  0xc(%ebp)
f01044d4:	ff 75 08             	pushl  0x8(%ebp)
f01044d7:	e8 93 ff ff ff       	call   f010446f <vsnprintf>
	va_end(ap);

	return rc;
}
f01044dc:	c9                   	leave  
f01044dd:	c3                   	ret    
	...

f01044e0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01044e0:	55                   	push   %ebp
f01044e1:	89 e5                	mov    %esp,%ebp
f01044e3:	57                   	push   %edi
f01044e4:	56                   	push   %esi
f01044e5:	53                   	push   %ebx
f01044e6:	83 ec 0c             	sub    $0xc,%esp
f01044e9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01044ec:	85 c0                	test   %eax,%eax
f01044ee:	74 11                	je     f0104501 <readline+0x21>
		cprintf("%s", prompt);
f01044f0:	83 ec 08             	sub    $0x8,%esp
f01044f3:	50                   	push   %eax
f01044f4:	68 05 5e 10 f0       	push   $0xf0105e05
f01044f9:	e8 53 f0 ff ff       	call   f0103551 <cprintf>
f01044fe:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104501:	83 ec 0c             	sub    $0xc,%esp
f0104504:	6a 00                	push   $0x0
f0104506:	e8 04 c1 ff ff       	call   f010060f <iscons>
f010450b:	89 c7                	mov    %eax,%edi
f010450d:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104510:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104515:	e8 e4 c0 ff ff       	call   f01005fe <getchar>
f010451a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010451c:	85 c0                	test   %eax,%eax
f010451e:	79 18                	jns    f0104538 <readline+0x58>
			cprintf("read error: %e\n", c);
f0104520:	83 ec 08             	sub    $0x8,%esp
f0104523:	50                   	push   %eax
f0104524:	68 f4 67 10 f0       	push   $0xf01067f4
f0104529:	e8 23 f0 ff ff       	call   f0103551 <cprintf>
			return NULL;
f010452e:	83 c4 10             	add    $0x10,%esp
f0104531:	b8 00 00 00 00       	mov    $0x0,%eax
f0104536:	eb 6f                	jmp    f01045a7 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104538:	83 f8 08             	cmp    $0x8,%eax
f010453b:	74 05                	je     f0104542 <readline+0x62>
f010453d:	83 f8 7f             	cmp    $0x7f,%eax
f0104540:	75 18                	jne    f010455a <readline+0x7a>
f0104542:	85 f6                	test   %esi,%esi
f0104544:	7e 14                	jle    f010455a <readline+0x7a>
			if (echoing)
f0104546:	85 ff                	test   %edi,%edi
f0104548:	74 0d                	je     f0104557 <readline+0x77>
				cputchar('\b');
f010454a:	83 ec 0c             	sub    $0xc,%esp
f010454d:	6a 08                	push   $0x8
f010454f:	e8 9a c0 ff ff       	call   f01005ee <cputchar>
f0104554:	83 c4 10             	add    $0x10,%esp
			i--;
f0104557:	4e                   	dec    %esi
f0104558:	eb bb                	jmp    f0104515 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010455a:	83 fb 1f             	cmp    $0x1f,%ebx
f010455d:	7e 21                	jle    f0104580 <readline+0xa0>
f010455f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104565:	7f 19                	jg     f0104580 <readline+0xa0>
			if (echoing)
f0104567:	85 ff                	test   %edi,%edi
f0104569:	74 0c                	je     f0104577 <readline+0x97>
				cputchar(c);
f010456b:	83 ec 0c             	sub    $0xc,%esp
f010456e:	53                   	push   %ebx
f010456f:	e8 7a c0 ff ff       	call   f01005ee <cputchar>
f0104574:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104577:	88 9e 40 0d 1e f0    	mov    %bl,-0xfe1f2c0(%esi)
f010457d:	46                   	inc    %esi
f010457e:	eb 95                	jmp    f0104515 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104580:	83 fb 0a             	cmp    $0xa,%ebx
f0104583:	74 05                	je     f010458a <readline+0xaa>
f0104585:	83 fb 0d             	cmp    $0xd,%ebx
f0104588:	75 8b                	jne    f0104515 <readline+0x35>
			if (echoing)
f010458a:	85 ff                	test   %edi,%edi
f010458c:	74 0d                	je     f010459b <readline+0xbb>
				cputchar('\n');
f010458e:	83 ec 0c             	sub    $0xc,%esp
f0104591:	6a 0a                	push   $0xa
f0104593:	e8 56 c0 ff ff       	call   f01005ee <cputchar>
f0104598:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010459b:	c6 86 40 0d 1e f0 00 	movb   $0x0,-0xfe1f2c0(%esi)
			return buf;
f01045a2:	b8 40 0d 1e f0       	mov    $0xf01e0d40,%eax
		}
	}
}
f01045a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01045aa:	5b                   	pop    %ebx
f01045ab:	5e                   	pop    %esi
f01045ac:	5f                   	pop    %edi
f01045ad:	c9                   	leave  
f01045ae:	c3                   	ret    
	...

f01045b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01045b0:	55                   	push   %ebp
f01045b1:	89 e5                	mov    %esp,%ebp
f01045b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01045b6:	80 3a 00             	cmpb   $0x0,(%edx)
f01045b9:	74 0e                	je     f01045c9 <strlen+0x19>
f01045bb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01045c0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01045c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01045c5:	75 f9                	jne    f01045c0 <strlen+0x10>
f01045c7:	eb 05                	jmp    f01045ce <strlen+0x1e>
f01045c9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01045ce:	c9                   	leave  
f01045cf:	c3                   	ret    

f01045d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01045d0:	55                   	push   %ebp
f01045d1:	89 e5                	mov    %esp,%ebp
f01045d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01045d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01045d9:	85 d2                	test   %edx,%edx
f01045db:	74 17                	je     f01045f4 <strnlen+0x24>
f01045dd:	80 39 00             	cmpb   $0x0,(%ecx)
f01045e0:	74 19                	je     f01045fb <strnlen+0x2b>
f01045e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01045e7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01045e8:	39 d0                	cmp    %edx,%eax
f01045ea:	74 14                	je     f0104600 <strnlen+0x30>
f01045ec:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01045f0:	75 f5                	jne    f01045e7 <strnlen+0x17>
f01045f2:	eb 0c                	jmp    f0104600 <strnlen+0x30>
f01045f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01045f9:	eb 05                	jmp    f0104600 <strnlen+0x30>
f01045fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104600:	c9                   	leave  
f0104601:	c3                   	ret    

f0104602 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104602:	55                   	push   %ebp
f0104603:	89 e5                	mov    %esp,%ebp
f0104605:	53                   	push   %ebx
f0104606:	8b 45 08             	mov    0x8(%ebp),%eax
f0104609:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010460c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104611:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0104614:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104617:	42                   	inc    %edx
f0104618:	84 c9                	test   %cl,%cl
f010461a:	75 f5                	jne    f0104611 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010461c:	5b                   	pop    %ebx
f010461d:	c9                   	leave  
f010461e:	c3                   	ret    

f010461f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010461f:	55                   	push   %ebp
f0104620:	89 e5                	mov    %esp,%ebp
f0104622:	53                   	push   %ebx
f0104623:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104626:	53                   	push   %ebx
f0104627:	e8 84 ff ff ff       	call   f01045b0 <strlen>
f010462c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010462f:	ff 75 0c             	pushl  0xc(%ebp)
f0104632:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0104635:	50                   	push   %eax
f0104636:	e8 c7 ff ff ff       	call   f0104602 <strcpy>
	return dst;
}
f010463b:	89 d8                	mov    %ebx,%eax
f010463d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104640:	c9                   	leave  
f0104641:	c3                   	ret    

f0104642 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104642:	55                   	push   %ebp
f0104643:	89 e5                	mov    %esp,%ebp
f0104645:	56                   	push   %esi
f0104646:	53                   	push   %ebx
f0104647:	8b 45 08             	mov    0x8(%ebp),%eax
f010464a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010464d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104650:	85 f6                	test   %esi,%esi
f0104652:	74 15                	je     f0104669 <strncpy+0x27>
f0104654:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0104659:	8a 1a                	mov    (%edx),%bl
f010465b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010465e:	80 3a 01             	cmpb   $0x1,(%edx)
f0104661:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104664:	41                   	inc    %ecx
f0104665:	39 ce                	cmp    %ecx,%esi
f0104667:	77 f0                	ja     f0104659 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104669:	5b                   	pop    %ebx
f010466a:	5e                   	pop    %esi
f010466b:	c9                   	leave  
f010466c:	c3                   	ret    

f010466d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010466d:	55                   	push   %ebp
f010466e:	89 e5                	mov    %esp,%ebp
f0104670:	57                   	push   %edi
f0104671:	56                   	push   %esi
f0104672:	53                   	push   %ebx
f0104673:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104676:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104679:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010467c:	85 f6                	test   %esi,%esi
f010467e:	74 32                	je     f01046b2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0104680:	83 fe 01             	cmp    $0x1,%esi
f0104683:	74 22                	je     f01046a7 <strlcpy+0x3a>
f0104685:	8a 0b                	mov    (%ebx),%cl
f0104687:	84 c9                	test   %cl,%cl
f0104689:	74 20                	je     f01046ab <strlcpy+0x3e>
f010468b:	89 f8                	mov    %edi,%eax
f010468d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0104692:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104695:	88 08                	mov    %cl,(%eax)
f0104697:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104698:	39 f2                	cmp    %esi,%edx
f010469a:	74 11                	je     f01046ad <strlcpy+0x40>
f010469c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f01046a0:	42                   	inc    %edx
f01046a1:	84 c9                	test   %cl,%cl
f01046a3:	75 f0                	jne    f0104695 <strlcpy+0x28>
f01046a5:	eb 06                	jmp    f01046ad <strlcpy+0x40>
f01046a7:	89 f8                	mov    %edi,%eax
f01046a9:	eb 02                	jmp    f01046ad <strlcpy+0x40>
f01046ab:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01046ad:	c6 00 00             	movb   $0x0,(%eax)
f01046b0:	eb 02                	jmp    f01046b4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01046b2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f01046b4:	29 f8                	sub    %edi,%eax
}
f01046b6:	5b                   	pop    %ebx
f01046b7:	5e                   	pop    %esi
f01046b8:	5f                   	pop    %edi
f01046b9:	c9                   	leave  
f01046ba:	c3                   	ret    

f01046bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01046bb:	55                   	push   %ebp
f01046bc:	89 e5                	mov    %esp,%ebp
f01046be:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01046c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01046c4:	8a 01                	mov    (%ecx),%al
f01046c6:	84 c0                	test   %al,%al
f01046c8:	74 10                	je     f01046da <strcmp+0x1f>
f01046ca:	3a 02                	cmp    (%edx),%al
f01046cc:	75 0c                	jne    f01046da <strcmp+0x1f>
		p++, q++;
f01046ce:	41                   	inc    %ecx
f01046cf:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01046d0:	8a 01                	mov    (%ecx),%al
f01046d2:	84 c0                	test   %al,%al
f01046d4:	74 04                	je     f01046da <strcmp+0x1f>
f01046d6:	3a 02                	cmp    (%edx),%al
f01046d8:	74 f4                	je     f01046ce <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01046da:	0f b6 c0             	movzbl %al,%eax
f01046dd:	0f b6 12             	movzbl (%edx),%edx
f01046e0:	29 d0                	sub    %edx,%eax
}
f01046e2:	c9                   	leave  
f01046e3:	c3                   	ret    

f01046e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01046e4:	55                   	push   %ebp
f01046e5:	89 e5                	mov    %esp,%ebp
f01046e7:	53                   	push   %ebx
f01046e8:	8b 55 08             	mov    0x8(%ebp),%edx
f01046eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01046ee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01046f1:	85 c0                	test   %eax,%eax
f01046f3:	74 1b                	je     f0104710 <strncmp+0x2c>
f01046f5:	8a 1a                	mov    (%edx),%bl
f01046f7:	84 db                	test   %bl,%bl
f01046f9:	74 24                	je     f010471f <strncmp+0x3b>
f01046fb:	3a 19                	cmp    (%ecx),%bl
f01046fd:	75 20                	jne    f010471f <strncmp+0x3b>
f01046ff:	48                   	dec    %eax
f0104700:	74 15                	je     f0104717 <strncmp+0x33>
		n--, p++, q++;
f0104702:	42                   	inc    %edx
f0104703:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104704:	8a 1a                	mov    (%edx),%bl
f0104706:	84 db                	test   %bl,%bl
f0104708:	74 15                	je     f010471f <strncmp+0x3b>
f010470a:	3a 19                	cmp    (%ecx),%bl
f010470c:	74 f1                	je     f01046ff <strncmp+0x1b>
f010470e:	eb 0f                	jmp    f010471f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104710:	b8 00 00 00 00       	mov    $0x0,%eax
f0104715:	eb 05                	jmp    f010471c <strncmp+0x38>
f0104717:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010471c:	5b                   	pop    %ebx
f010471d:	c9                   	leave  
f010471e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010471f:	0f b6 02             	movzbl (%edx),%eax
f0104722:	0f b6 11             	movzbl (%ecx),%edx
f0104725:	29 d0                	sub    %edx,%eax
f0104727:	eb f3                	jmp    f010471c <strncmp+0x38>

f0104729 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104729:	55                   	push   %ebp
f010472a:	89 e5                	mov    %esp,%ebp
f010472c:	8b 45 08             	mov    0x8(%ebp),%eax
f010472f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104732:	8a 10                	mov    (%eax),%dl
f0104734:	84 d2                	test   %dl,%dl
f0104736:	74 18                	je     f0104750 <strchr+0x27>
		if (*s == c)
f0104738:	38 ca                	cmp    %cl,%dl
f010473a:	75 06                	jne    f0104742 <strchr+0x19>
f010473c:	eb 17                	jmp    f0104755 <strchr+0x2c>
f010473e:	38 ca                	cmp    %cl,%dl
f0104740:	74 13                	je     f0104755 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104742:	40                   	inc    %eax
f0104743:	8a 10                	mov    (%eax),%dl
f0104745:	84 d2                	test   %dl,%dl
f0104747:	75 f5                	jne    f010473e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0104749:	b8 00 00 00 00       	mov    $0x0,%eax
f010474e:	eb 05                	jmp    f0104755 <strchr+0x2c>
f0104750:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104755:	c9                   	leave  
f0104756:	c3                   	ret    

f0104757 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104757:	55                   	push   %ebp
f0104758:	89 e5                	mov    %esp,%ebp
f010475a:	8b 45 08             	mov    0x8(%ebp),%eax
f010475d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104760:	8a 10                	mov    (%eax),%dl
f0104762:	84 d2                	test   %dl,%dl
f0104764:	74 11                	je     f0104777 <strfind+0x20>
		if (*s == c)
f0104766:	38 ca                	cmp    %cl,%dl
f0104768:	75 06                	jne    f0104770 <strfind+0x19>
f010476a:	eb 0b                	jmp    f0104777 <strfind+0x20>
f010476c:	38 ca                	cmp    %cl,%dl
f010476e:	74 07                	je     f0104777 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104770:	40                   	inc    %eax
f0104771:	8a 10                	mov    (%eax),%dl
f0104773:	84 d2                	test   %dl,%dl
f0104775:	75 f5                	jne    f010476c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f0104777:	c9                   	leave  
f0104778:	c3                   	ret    

f0104779 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104779:	55                   	push   %ebp
f010477a:	89 e5                	mov    %esp,%ebp
f010477c:	57                   	push   %edi
f010477d:	56                   	push   %esi
f010477e:	53                   	push   %ebx
f010477f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104782:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104785:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104788:	85 c9                	test   %ecx,%ecx
f010478a:	74 30                	je     f01047bc <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010478c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104792:	75 25                	jne    f01047b9 <memset+0x40>
f0104794:	f6 c1 03             	test   $0x3,%cl
f0104797:	75 20                	jne    f01047b9 <memset+0x40>
		c &= 0xFF;
f0104799:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010479c:	89 d3                	mov    %edx,%ebx
f010479e:	c1 e3 08             	shl    $0x8,%ebx
f01047a1:	89 d6                	mov    %edx,%esi
f01047a3:	c1 e6 18             	shl    $0x18,%esi
f01047a6:	89 d0                	mov    %edx,%eax
f01047a8:	c1 e0 10             	shl    $0x10,%eax
f01047ab:	09 f0                	or     %esi,%eax
f01047ad:	09 d0                	or     %edx,%eax
f01047af:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01047b1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01047b4:	fc                   	cld    
f01047b5:	f3 ab                	rep stos %eax,%es:(%edi)
f01047b7:	eb 03                	jmp    f01047bc <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01047b9:	fc                   	cld    
f01047ba:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01047bc:	89 f8                	mov    %edi,%eax
f01047be:	5b                   	pop    %ebx
f01047bf:	5e                   	pop    %esi
f01047c0:	5f                   	pop    %edi
f01047c1:	c9                   	leave  
f01047c2:	c3                   	ret    

f01047c3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01047c3:	55                   	push   %ebp
f01047c4:	89 e5                	mov    %esp,%ebp
f01047c6:	57                   	push   %edi
f01047c7:	56                   	push   %esi
f01047c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01047cb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01047ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01047d1:	39 c6                	cmp    %eax,%esi
f01047d3:	73 34                	jae    f0104809 <memmove+0x46>
f01047d5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01047d8:	39 d0                	cmp    %edx,%eax
f01047da:	73 2d                	jae    f0104809 <memmove+0x46>
		s += n;
		d += n;
f01047dc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01047df:	f6 c2 03             	test   $0x3,%dl
f01047e2:	75 1b                	jne    f01047ff <memmove+0x3c>
f01047e4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01047ea:	75 13                	jne    f01047ff <memmove+0x3c>
f01047ec:	f6 c1 03             	test   $0x3,%cl
f01047ef:	75 0e                	jne    f01047ff <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01047f1:	83 ef 04             	sub    $0x4,%edi
f01047f4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01047f7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01047fa:	fd                   	std    
f01047fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01047fd:	eb 07                	jmp    f0104806 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01047ff:	4f                   	dec    %edi
f0104800:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104803:	fd                   	std    
f0104804:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104806:	fc                   	cld    
f0104807:	eb 20                	jmp    f0104829 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104809:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010480f:	75 13                	jne    f0104824 <memmove+0x61>
f0104811:	a8 03                	test   $0x3,%al
f0104813:	75 0f                	jne    f0104824 <memmove+0x61>
f0104815:	f6 c1 03             	test   $0x3,%cl
f0104818:	75 0a                	jne    f0104824 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010481a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010481d:	89 c7                	mov    %eax,%edi
f010481f:	fc                   	cld    
f0104820:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104822:	eb 05                	jmp    f0104829 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104824:	89 c7                	mov    %eax,%edi
f0104826:	fc                   	cld    
f0104827:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104829:	5e                   	pop    %esi
f010482a:	5f                   	pop    %edi
f010482b:	c9                   	leave  
f010482c:	c3                   	ret    

f010482d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010482d:	55                   	push   %ebp
f010482e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104830:	ff 75 10             	pushl  0x10(%ebp)
f0104833:	ff 75 0c             	pushl  0xc(%ebp)
f0104836:	ff 75 08             	pushl  0x8(%ebp)
f0104839:	e8 85 ff ff ff       	call   f01047c3 <memmove>
}
f010483e:	c9                   	leave  
f010483f:	c3                   	ret    

f0104840 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104840:	55                   	push   %ebp
f0104841:	89 e5                	mov    %esp,%ebp
f0104843:	57                   	push   %edi
f0104844:	56                   	push   %esi
f0104845:	53                   	push   %ebx
f0104846:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104849:	8b 75 0c             	mov    0xc(%ebp),%esi
f010484c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010484f:	85 ff                	test   %edi,%edi
f0104851:	74 32                	je     f0104885 <memcmp+0x45>
		if (*s1 != *s2)
f0104853:	8a 03                	mov    (%ebx),%al
f0104855:	8a 0e                	mov    (%esi),%cl
f0104857:	38 c8                	cmp    %cl,%al
f0104859:	74 19                	je     f0104874 <memcmp+0x34>
f010485b:	eb 0d                	jmp    f010486a <memcmp+0x2a>
f010485d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0104861:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0104865:	42                   	inc    %edx
f0104866:	38 c8                	cmp    %cl,%al
f0104868:	74 10                	je     f010487a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f010486a:	0f b6 c0             	movzbl %al,%eax
f010486d:	0f b6 c9             	movzbl %cl,%ecx
f0104870:	29 c8                	sub    %ecx,%eax
f0104872:	eb 16                	jmp    f010488a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104874:	4f                   	dec    %edi
f0104875:	ba 00 00 00 00       	mov    $0x0,%edx
f010487a:	39 fa                	cmp    %edi,%edx
f010487c:	75 df                	jne    f010485d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010487e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104883:	eb 05                	jmp    f010488a <memcmp+0x4a>
f0104885:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010488a:	5b                   	pop    %ebx
f010488b:	5e                   	pop    %esi
f010488c:	5f                   	pop    %edi
f010488d:	c9                   	leave  
f010488e:	c3                   	ret    

f010488f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010488f:	55                   	push   %ebp
f0104890:	89 e5                	mov    %esp,%ebp
f0104892:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104895:	89 c2                	mov    %eax,%edx
f0104897:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010489a:	39 d0                	cmp    %edx,%eax
f010489c:	73 12                	jae    f01048b0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f010489e:	8a 4d 0c             	mov    0xc(%ebp),%cl
f01048a1:	38 08                	cmp    %cl,(%eax)
f01048a3:	75 06                	jne    f01048ab <memfind+0x1c>
f01048a5:	eb 09                	jmp    f01048b0 <memfind+0x21>
f01048a7:	38 08                	cmp    %cl,(%eax)
f01048a9:	74 05                	je     f01048b0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01048ab:	40                   	inc    %eax
f01048ac:	39 c2                	cmp    %eax,%edx
f01048ae:	77 f7                	ja     f01048a7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01048b0:	c9                   	leave  
f01048b1:	c3                   	ret    

f01048b2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01048b2:	55                   	push   %ebp
f01048b3:	89 e5                	mov    %esp,%ebp
f01048b5:	57                   	push   %edi
f01048b6:	56                   	push   %esi
f01048b7:	53                   	push   %ebx
f01048b8:	8b 55 08             	mov    0x8(%ebp),%edx
f01048bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01048be:	eb 01                	jmp    f01048c1 <strtol+0xf>
		s++;
f01048c0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01048c1:	8a 02                	mov    (%edx),%al
f01048c3:	3c 20                	cmp    $0x20,%al
f01048c5:	74 f9                	je     f01048c0 <strtol+0xe>
f01048c7:	3c 09                	cmp    $0x9,%al
f01048c9:	74 f5                	je     f01048c0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01048cb:	3c 2b                	cmp    $0x2b,%al
f01048cd:	75 08                	jne    f01048d7 <strtol+0x25>
		s++;
f01048cf:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01048d0:	bf 00 00 00 00       	mov    $0x0,%edi
f01048d5:	eb 13                	jmp    f01048ea <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01048d7:	3c 2d                	cmp    $0x2d,%al
f01048d9:	75 0a                	jne    f01048e5 <strtol+0x33>
		s++, neg = 1;
f01048db:	8d 52 01             	lea    0x1(%edx),%edx
f01048de:	bf 01 00 00 00       	mov    $0x1,%edi
f01048e3:	eb 05                	jmp    f01048ea <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01048e5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01048ea:	85 db                	test   %ebx,%ebx
f01048ec:	74 05                	je     f01048f3 <strtol+0x41>
f01048ee:	83 fb 10             	cmp    $0x10,%ebx
f01048f1:	75 28                	jne    f010491b <strtol+0x69>
f01048f3:	8a 02                	mov    (%edx),%al
f01048f5:	3c 30                	cmp    $0x30,%al
f01048f7:	75 10                	jne    f0104909 <strtol+0x57>
f01048f9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01048fd:	75 0a                	jne    f0104909 <strtol+0x57>
		s += 2, base = 16;
f01048ff:	83 c2 02             	add    $0x2,%edx
f0104902:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104907:	eb 12                	jmp    f010491b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0104909:	85 db                	test   %ebx,%ebx
f010490b:	75 0e                	jne    f010491b <strtol+0x69>
f010490d:	3c 30                	cmp    $0x30,%al
f010490f:	75 05                	jne    f0104916 <strtol+0x64>
		s++, base = 8;
f0104911:	42                   	inc    %edx
f0104912:	b3 08                	mov    $0x8,%bl
f0104914:	eb 05                	jmp    f010491b <strtol+0x69>
	else if (base == 0)
		base = 10;
f0104916:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010491b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104920:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104922:	8a 0a                	mov    (%edx),%cl
f0104924:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104927:	80 fb 09             	cmp    $0x9,%bl
f010492a:	77 08                	ja     f0104934 <strtol+0x82>
			dig = *s - '0';
f010492c:	0f be c9             	movsbl %cl,%ecx
f010492f:	83 e9 30             	sub    $0x30,%ecx
f0104932:	eb 1e                	jmp    f0104952 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0104934:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0104937:	80 fb 19             	cmp    $0x19,%bl
f010493a:	77 08                	ja     f0104944 <strtol+0x92>
			dig = *s - 'a' + 10;
f010493c:	0f be c9             	movsbl %cl,%ecx
f010493f:	83 e9 57             	sub    $0x57,%ecx
f0104942:	eb 0e                	jmp    f0104952 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0104944:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0104947:	80 fb 19             	cmp    $0x19,%bl
f010494a:	77 13                	ja     f010495f <strtol+0xad>
			dig = *s - 'A' + 10;
f010494c:	0f be c9             	movsbl %cl,%ecx
f010494f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104952:	39 f1                	cmp    %esi,%ecx
f0104954:	7d 0d                	jge    f0104963 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f0104956:	42                   	inc    %edx
f0104957:	0f af c6             	imul   %esi,%eax
f010495a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f010495d:	eb c3                	jmp    f0104922 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010495f:	89 c1                	mov    %eax,%ecx
f0104961:	eb 02                	jmp    f0104965 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104963:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104965:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104969:	74 05                	je     f0104970 <strtol+0xbe>
		*endptr = (char *) s;
f010496b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010496e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104970:	85 ff                	test   %edi,%edi
f0104972:	74 04                	je     f0104978 <strtol+0xc6>
f0104974:	89 c8                	mov    %ecx,%eax
f0104976:	f7 d8                	neg    %eax
}
f0104978:	5b                   	pop    %ebx
f0104979:	5e                   	pop    %esi
f010497a:	5f                   	pop    %edi
f010497b:	c9                   	leave  
f010497c:	c3                   	ret    
f010497d:	00 00                	add    %al,(%eax)
	...

f0104980 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0104980:	55                   	push   %ebp
f0104981:	89 e5                	mov    %esp,%ebp
f0104983:	57                   	push   %edi
f0104984:	56                   	push   %esi
f0104985:	83 ec 10             	sub    $0x10,%esp
f0104988:	8b 7d 08             	mov    0x8(%ebp),%edi
f010498b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010498e:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0104991:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0104994:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0104997:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010499a:	85 c0                	test   %eax,%eax
f010499c:	75 2e                	jne    f01049cc <__udivdi3+0x4c>
    {
      if (d0 > n1)
f010499e:	39 f1                	cmp    %esi,%ecx
f01049a0:	77 5a                	ja     f01049fc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01049a2:	85 c9                	test   %ecx,%ecx
f01049a4:	75 0b                	jne    f01049b1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01049a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01049ab:	31 d2                	xor    %edx,%edx
f01049ad:	f7 f1                	div    %ecx
f01049af:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01049b1:	31 d2                	xor    %edx,%edx
f01049b3:	89 f0                	mov    %esi,%eax
f01049b5:	f7 f1                	div    %ecx
f01049b7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01049b9:	89 f8                	mov    %edi,%eax
f01049bb:	f7 f1                	div    %ecx
f01049bd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01049bf:	89 f8                	mov    %edi,%eax
f01049c1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01049c3:	83 c4 10             	add    $0x10,%esp
f01049c6:	5e                   	pop    %esi
f01049c7:	5f                   	pop    %edi
f01049c8:	c9                   	leave  
f01049c9:	c3                   	ret    
f01049ca:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01049cc:	39 f0                	cmp    %esi,%eax
f01049ce:	77 1c                	ja     f01049ec <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01049d0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f01049d3:	83 f7 1f             	xor    $0x1f,%edi
f01049d6:	75 3c                	jne    f0104a14 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01049d8:	39 f0                	cmp    %esi,%eax
f01049da:	0f 82 90 00 00 00    	jb     f0104a70 <__udivdi3+0xf0>
f01049e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01049e3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f01049e6:	0f 86 84 00 00 00    	jbe    f0104a70 <__udivdi3+0xf0>
f01049ec:	31 f6                	xor    %esi,%esi
f01049ee:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01049f0:	89 f8                	mov    %edi,%eax
f01049f2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01049f4:	83 c4 10             	add    $0x10,%esp
f01049f7:	5e                   	pop    %esi
f01049f8:	5f                   	pop    %edi
f01049f9:	c9                   	leave  
f01049fa:	c3                   	ret    
f01049fb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01049fc:	89 f2                	mov    %esi,%edx
f01049fe:	89 f8                	mov    %edi,%eax
f0104a00:	f7 f1                	div    %ecx
f0104a02:	89 c7                	mov    %eax,%edi
f0104a04:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104a06:	89 f8                	mov    %edi,%eax
f0104a08:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104a0a:	83 c4 10             	add    $0x10,%esp
f0104a0d:	5e                   	pop    %esi
f0104a0e:	5f                   	pop    %edi
f0104a0f:	c9                   	leave  
f0104a10:	c3                   	ret    
f0104a11:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0104a14:	89 f9                	mov    %edi,%ecx
f0104a16:	d3 e0                	shl    %cl,%eax
f0104a18:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0104a1b:	b8 20 00 00 00       	mov    $0x20,%eax
f0104a20:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0104a22:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a25:	88 c1                	mov    %al,%cl
f0104a27:	d3 ea                	shr    %cl,%edx
f0104a29:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104a2c:	09 ca                	or     %ecx,%edx
f0104a2e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0104a31:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a34:	89 f9                	mov    %edi,%ecx
f0104a36:	d3 e2                	shl    %cl,%edx
f0104a38:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0104a3b:	89 f2                	mov    %esi,%edx
f0104a3d:	88 c1                	mov    %al,%cl
f0104a3f:	d3 ea                	shr    %cl,%edx
f0104a41:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0104a44:	89 f2                	mov    %esi,%edx
f0104a46:	89 f9                	mov    %edi,%ecx
f0104a48:	d3 e2                	shl    %cl,%edx
f0104a4a:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0104a4d:	88 c1                	mov    %al,%cl
f0104a4f:	d3 ee                	shr    %cl,%esi
f0104a51:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0104a53:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104a56:	89 f0                	mov    %esi,%eax
f0104a58:	89 ca                	mov    %ecx,%edx
f0104a5a:	f7 75 ec             	divl   -0x14(%ebp)
f0104a5d:	89 d1                	mov    %edx,%ecx
f0104a5f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0104a61:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104a64:	39 d1                	cmp    %edx,%ecx
f0104a66:	72 28                	jb     f0104a90 <__udivdi3+0x110>
f0104a68:	74 1a                	je     f0104a84 <__udivdi3+0x104>
f0104a6a:	89 f7                	mov    %esi,%edi
f0104a6c:	31 f6                	xor    %esi,%esi
f0104a6e:	eb 80                	jmp    f01049f0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0104a70:	31 f6                	xor    %esi,%esi
f0104a72:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104a77:	89 f8                	mov    %edi,%eax
f0104a79:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104a7b:	83 c4 10             	add    $0x10,%esp
f0104a7e:	5e                   	pop    %esi
f0104a7f:	5f                   	pop    %edi
f0104a80:	c9                   	leave  
f0104a81:	c3                   	ret    
f0104a82:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0104a84:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104a87:	89 f9                	mov    %edi,%ecx
f0104a89:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104a8b:	39 c2                	cmp    %eax,%edx
f0104a8d:	73 db                	jae    f0104a6a <__udivdi3+0xea>
f0104a8f:	90                   	nop
		{
		  q0--;
f0104a90:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104a93:	31 f6                	xor    %esi,%esi
f0104a95:	e9 56 ff ff ff       	jmp    f01049f0 <__udivdi3+0x70>
	...

f0104a9c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0104a9c:	55                   	push   %ebp
f0104a9d:	89 e5                	mov    %esp,%ebp
f0104a9f:	57                   	push   %edi
f0104aa0:	56                   	push   %esi
f0104aa1:	83 ec 20             	sub    $0x20,%esp
f0104aa4:	8b 45 08             	mov    0x8(%ebp),%eax
f0104aa7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0104aaa:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0104aad:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0104ab0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0104ab3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0104ab6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0104ab9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0104abb:	85 ff                	test   %edi,%edi
f0104abd:	75 15                	jne    f0104ad4 <__umoddi3+0x38>
    {
      if (d0 > n1)
f0104abf:	39 f1                	cmp    %esi,%ecx
f0104ac1:	0f 86 99 00 00 00    	jbe    f0104b60 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104ac7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0104ac9:	89 d0                	mov    %edx,%eax
f0104acb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104acd:	83 c4 20             	add    $0x20,%esp
f0104ad0:	5e                   	pop    %esi
f0104ad1:	5f                   	pop    %edi
f0104ad2:	c9                   	leave  
f0104ad3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0104ad4:	39 f7                	cmp    %esi,%edi
f0104ad6:	0f 87 a4 00 00 00    	ja     f0104b80 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0104adc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0104adf:	83 f0 1f             	xor    $0x1f,%eax
f0104ae2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ae5:	0f 84 a1 00 00 00    	je     f0104b8c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0104aeb:	89 f8                	mov    %edi,%eax
f0104aed:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104af0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0104af2:	bf 20 00 00 00       	mov    $0x20,%edi
f0104af7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0104afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104afd:	89 f9                	mov    %edi,%ecx
f0104aff:	d3 ea                	shr    %cl,%edx
f0104b01:	09 c2                	or     %eax,%edx
f0104b03:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0104b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104b09:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104b0c:	d3 e0                	shl    %cl,%eax
f0104b0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0104b11:	89 f2                	mov    %esi,%edx
f0104b13:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0104b15:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104b18:	d3 e0                	shl    %cl,%eax
f0104b1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0104b1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104b20:	89 f9                	mov    %edi,%ecx
f0104b22:	d3 e8                	shr    %cl,%eax
f0104b24:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0104b26:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0104b28:	89 f2                	mov    %esi,%edx
f0104b2a:	f7 75 f0             	divl   -0x10(%ebp)
f0104b2d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0104b2f:	f7 65 f4             	mull   -0xc(%ebp)
f0104b32:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0104b35:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104b37:	39 d6                	cmp    %edx,%esi
f0104b39:	72 71                	jb     f0104bac <__umoddi3+0x110>
f0104b3b:	74 7f                	je     f0104bbc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0104b3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b40:	29 c8                	sub    %ecx,%eax
f0104b42:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0104b44:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104b47:	d3 e8                	shr    %cl,%eax
f0104b49:	89 f2                	mov    %esi,%edx
f0104b4b:	89 f9                	mov    %edi,%ecx
f0104b4d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0104b4f:	09 d0                	or     %edx,%eax
f0104b51:	89 f2                	mov    %esi,%edx
f0104b53:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104b56:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104b58:	83 c4 20             	add    $0x20,%esp
f0104b5b:	5e                   	pop    %esi
f0104b5c:	5f                   	pop    %edi
f0104b5d:	c9                   	leave  
f0104b5e:	c3                   	ret    
f0104b5f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0104b60:	85 c9                	test   %ecx,%ecx
f0104b62:	75 0b                	jne    f0104b6f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0104b64:	b8 01 00 00 00       	mov    $0x1,%eax
f0104b69:	31 d2                	xor    %edx,%edx
f0104b6b:	f7 f1                	div    %ecx
f0104b6d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0104b6f:	89 f0                	mov    %esi,%eax
f0104b71:	31 d2                	xor    %edx,%edx
f0104b73:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104b78:	f7 f1                	div    %ecx
f0104b7a:	e9 4a ff ff ff       	jmp    f0104ac9 <__umoddi3+0x2d>
f0104b7f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0104b80:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104b82:	83 c4 20             	add    $0x20,%esp
f0104b85:	5e                   	pop    %esi
f0104b86:	5f                   	pop    %edi
f0104b87:	c9                   	leave  
f0104b88:	c3                   	ret    
f0104b89:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0104b8c:	39 f7                	cmp    %esi,%edi
f0104b8e:	72 05                	jb     f0104b95 <__umoddi3+0xf9>
f0104b90:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0104b93:	77 0c                	ja     f0104ba1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0104b95:	89 f2                	mov    %esi,%edx
f0104b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104b9a:	29 c8                	sub    %ecx,%eax
f0104b9c:	19 fa                	sbb    %edi,%edx
f0104b9e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0104ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104ba4:	83 c4 20             	add    $0x20,%esp
f0104ba7:	5e                   	pop    %esi
f0104ba8:	5f                   	pop    %edi
f0104ba9:	c9                   	leave  
f0104baa:	c3                   	ret    
f0104bab:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104bac:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104baf:	89 c1                	mov    %eax,%ecx
f0104bb1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0104bb4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0104bb7:	eb 84                	jmp    f0104b3d <__umoddi3+0xa1>
f0104bb9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104bbc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0104bbf:	72 eb                	jb     f0104bac <__umoddi3+0x110>
f0104bc1:	89 f2                	mov    %esi,%edx
f0104bc3:	e9 75 ff ff ff       	jmp    f0104b3d <__umoddi3+0xa1>
