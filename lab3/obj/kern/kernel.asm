
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
f0100080:	e8 60 47 00 00       	call   f01047e5 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100085:	e8 85 04 00 00       	call   f010050f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010008a:	83 c4 08             	add    $0x8,%esp
f010008d:	68 ac 1a 00 00       	push   $0x1aac
f0100092:	68 40 4c 10 f0       	push   $0xf0104c40
f0100097:	e8 15 35 00 00       	call   f01035b1 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f010009c:	e8 84 16 00 00       	call   f0101725 <mem_init>

	// MSRs init:
	msrs_init();
f01000a1:	e8 9a ff ff ff       	call   f0100040 <msrs_init>

    // cprintf("mem_init done! \n");
	// Lab 3 user environment initialization functions
	env_init();
f01000a6:	e8 f0 2e 00 00       	call   f0102f9b <env_init>
    // cprintf("env_init done! \n");
	trap_init();
f01000ab:	e8 75 35 00 00       	call   f0103625 <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f01000b0:	83 c4 0c             	add    $0xc,%esp
f01000b3:	6a 00                	push   $0x0
f01000b5:	68 73 e8 00 00       	push   $0xe873
f01000ba:	68 c8 33 12 f0       	push   $0xf01233c8
f01000bf:	e8 e5 30 00 00       	call   f01031a9 <env_create>
#endif // TEST*
    
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000c4:	83 c4 04             	add    $0x4,%esp
f01000c7:	ff 35 7c 04 1e f0    	pushl  0xf01e047c
f01000cd:	e8 1a 34 00 00       	call   f01034ec <env_run>

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
f01000f7:	68 5b 4c 10 f0       	push   $0xf0104c5b
f01000fc:	e8 b0 34 00 00       	call   f01035b1 <cprintf>
	vcprintf(fmt, ap);
f0100101:	83 c4 08             	add    $0x8,%esp
f0100104:	53                   	push   %ebx
f0100105:	56                   	push   %esi
f0100106:	e8 80 34 00 00       	call   f010358b <vcprintf>
	cprintf("\n");
f010010b:	c7 04 24 4c 4f 10 f0 	movl   $0xf0104f4c,(%esp)
f0100112:	e8 9a 34 00 00       	call   f01035b1 <cprintf>
	va_end(ap);
f0100117:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010011a:	83 ec 0c             	sub    $0xc,%esp
f010011d:	6a 00                	push   $0x0
f010011f:	e8 c3 0d 00 00       	call   f0100ee7 <monitor>
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
f0100139:	68 73 4c 10 f0       	push   $0xf0104c73
f010013e:	e8 6e 34 00 00       	call   f01035b1 <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	53                   	push   %ebx
f0100147:	ff 75 10             	pushl  0x10(%ebp)
f010014a:	e8 3c 34 00 00       	call   f010358b <vcprintf>
	cprintf("\n");
f010014f:	c7 04 24 4c 4f 10 f0 	movl   $0xf0104f4c,(%esp)
f0100156:	e8 56 34 00 00       	call   f01035b1 <cprintf>
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
f0100345:	e8 e5 44 00 00       	call   f010482f <memmove>
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
f01003e4:	8a 82 c0 4c 10 f0    	mov    -0xfefb340(%edx),%al
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
f0100420:	0f b6 82 c0 4c 10 f0 	movzbl -0xfefb340(%edx),%eax
f0100427:	0b 05 68 04 1e f0    	or     0xf01e0468,%eax
	shift ^= togglecode[data];
f010042d:	0f b6 8a c0 4d 10 f0 	movzbl -0xfefb240(%edx),%ecx
f0100434:	31 c8                	xor    %ecx,%eax
f0100436:	a3 68 04 1e f0       	mov    %eax,0xf01e0468

	c = charcode[shift & (CTL | SHIFT)][data];
f010043b:	89 c1                	mov    %eax,%ecx
f010043d:	83 e1 03             	and    $0x3,%ecx
f0100440:	8b 0c 8d c0 4e 10 f0 	mov    -0xfefb140(,%ecx,4),%ecx
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
f0100478:	68 8d 4c 10 f0       	push   $0xf0104c8d
f010047d:	e8 2f 31 00 00       	call   f01035b1 <cprintf>
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
f01005d9:	68 99 4c 10 f0       	push   $0xf0104c99
f01005de:	e8 ce 2f 00 00       	call   f01035b1 <cprintf>
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

f010061c <mon_gdt>:
    return 0;
}

int 
mon_gdt(int argc, char **argv, struct Trapframe *tf)
{
f010061c:	55                   	push   %ebp
f010061d:	89 e5                	mov    %esp,%ebp
f010061f:	56                   	push   %esi
f0100620:	53                   	push   %ebx
    int i;
    void * g;
    cprintf("%d\n", gdt[2]);
f0100621:	83 ec 04             	sub    $0x4,%esp
f0100624:	ff 35 14 33 12 f0    	pushl  0xf0123314
f010062a:	ff 35 10 33 12 f0    	pushl  0xf0123310
f0100630:	68 d0 4e 10 f0       	push   $0xf0104ed0
f0100635:	e8 77 2f 00 00       	call   f01035b1 <cprintf>
f010063a:	bb 00 33 12 f0       	mov    $0xf0123300,%ebx
f010063f:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i != 6; i ++) {
f0100642:	be 00 00 00 00       	mov    $0x0,%esi
        g = gdt + i;
        cprintf("entry %d: 0x%08x 0x%08x\n", i, *((uint32_t*)(g)), *((uint32_t*)(g+4)));
f0100647:	ff 73 04             	pushl  0x4(%ebx)
f010064a:	ff 33                	pushl  (%ebx)
f010064c:	56                   	push   %esi
f010064d:	68 d4 4e 10 f0       	push   $0xf0104ed4
f0100652:	e8 5a 2f 00 00       	call   f01035b1 <cprintf>
mon_gdt(int argc, char **argv, struct Trapframe *tf)
{
    int i;
    void * g;
    cprintf("%d\n", gdt[2]);
    for (i = 0; i != 6; i ++) {
f0100657:	46                   	inc    %esi
f0100658:	83 c3 08             	add    $0x8,%ebx
f010065b:	83 c4 10             	add    $0x10,%esp
f010065e:	83 fe 06             	cmp    $0x6,%esi
f0100661:	75 e4                	jne    f0100647 <mon_gdt+0x2b>
        g = gdt + i;
        cprintf("entry %d: 0x%08x 0x%08x\n", i, *((uint32_t*)(g)), *((uint32_t*)(g+4)));
    }
    return 0;
}
f0100663:	b8 00 00 00 00       	mov    $0x0,%eax
f0100668:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010066b:	5b                   	pop    %ebx
f010066c:	5e                   	pop    %esi
f010066d:	c9                   	leave  
f010066e:	c3                   	ret    

f010066f <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010066f:	55                   	push   %ebp
f0100670:	89 e5                	mov    %esp,%ebp
f0100672:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100675:	68 ed 4e 10 f0       	push   $0xf0104eed
f010067a:	e8 32 2f 00 00       	call   f01035b1 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010067f:	83 c4 08             	add    $0x8,%esp
f0100682:	68 0c 00 10 00       	push   $0x10000c
f0100687:	68 24 51 10 f0       	push   $0xf0105124
f010068c:	e8 20 2f 00 00       	call   f01035b1 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100691:	83 c4 0c             	add    $0xc,%esp
f0100694:	68 0c 00 10 00       	push   $0x10000c
f0100699:	68 0c 00 10 f0       	push   $0xf010000c
f010069e:	68 4c 51 10 f0       	push   $0xf010514c
f01006a3:	e8 09 2f 00 00       	call   f01035b1 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a8:	83 c4 0c             	add    $0xc,%esp
f01006ab:	68 34 4c 10 00       	push   $0x104c34
f01006b0:	68 34 4c 10 f0       	push   $0xf0104c34
f01006b5:	68 70 51 10 f0       	push   $0xf0105170
f01006ba:	e8 f2 2e 00 00       	call   f01035b1 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006bf:	83 c4 0c             	add    $0xc,%esp
f01006c2:	68 24 02 1e 00       	push   $0x1e0224
f01006c7:	68 24 02 1e f0       	push   $0xf01e0224
f01006cc:	68 94 51 10 f0       	push   $0xf0105194
f01006d1:	e8 db 2e 00 00       	call   f01035b1 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006d6:	83 c4 0c             	add    $0xc,%esp
f01006d9:	68 50 11 1e 00       	push   $0x1e1150
f01006de:	68 50 11 1e f0       	push   $0xf01e1150
f01006e3:	68 b8 51 10 f0       	push   $0xf01051b8
f01006e8:	e8 c4 2e 00 00       	call   f01035b1 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006ed:	b8 4f 15 1e f0       	mov    $0xf01e154f,%eax
f01006f2:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006f7:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01006fa:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006ff:	89 c2                	mov    %eax,%edx
f0100701:	85 c0                	test   %eax,%eax
f0100703:	79 06                	jns    f010070b <mon_kerninfo+0x9c>
f0100705:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010070b:	c1 fa 0a             	sar    $0xa,%edx
f010070e:	52                   	push   %edx
f010070f:	68 dc 51 10 f0       	push   $0xf01051dc
f0100714:	e8 98 2e 00 00       	call   f01035b1 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100719:	b8 00 00 00 00       	mov    $0x0,%eax
f010071e:	c9                   	leave  
f010071f:	c3                   	ret    

f0100720 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100720:	55                   	push   %ebp
f0100721:	89 e5                	mov    %esp,%ebp
f0100723:	53                   	push   %ebx
f0100724:	83 ec 04             	sub    $0x4,%esp
f0100727:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010072c:	83 ec 04             	sub    $0x4,%esp
f010072f:	ff b3 84 56 10 f0    	pushl  -0xfefa97c(%ebx)
f0100735:	ff b3 80 56 10 f0    	pushl  -0xfefa980(%ebx)
f010073b:	68 06 4f 10 f0       	push   $0xf0104f06
f0100740:	e8 6c 2e 00 00       	call   f01035b1 <cprintf>
f0100745:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100748:	83 c4 10             	add    $0x10,%esp
f010074b:	83 fb 78             	cmp    $0x78,%ebx
f010074e:	75 dc                	jne    f010072c <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100750:	b8 00 00 00 00       	mov    $0x0,%eax
f0100755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100758:	c9                   	leave  
f0100759:	c3                   	ret    

f010075a <mon_si>:
    return 0;
}

int 
mon_si(int argc, char **argv, struct Trapframe *tf)
{
f010075a:	55                   	push   %ebp
f010075b:	89 e5                	mov    %esp,%ebp
f010075d:	83 ec 08             	sub    $0x8,%esp
f0100760:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f0100763:	85 c0                	test   %eax,%eax
f0100765:	75 14                	jne    f010077b <mon_si+0x21>
        cprintf("Error: you only can use si in breakpoint.\n");
f0100767:	83 ec 0c             	sub    $0xc,%esp
f010076a:	68 08 52 10 f0       	push   $0xf0105208
f010076f:	e8 3d 2e 00 00       	call   f01035b1 <cprintf>

    cprintf("tfno: %u\n", tf->tf_trapno);
    env_run(curenv);
    panic("mon_si : env_run return");
    return 0;
}
f0100774:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100779:	c9                   	leave  
f010077a:	c3                   	ret    
        cprintf("Error: you only can use si in breakpoint.\n");
        return -1;
    }

    // next step also cause debug interrupt
    tf->tf_eflags |= FL_TF;
f010077b:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)

    cprintf("tfno: %u\n", tf->tf_trapno);
f0100782:	83 ec 08             	sub    $0x8,%esp
f0100785:	ff 70 28             	pushl  0x28(%eax)
f0100788:	68 0f 4f 10 f0       	push   $0xf0104f0f
f010078d:	e8 1f 2e 00 00       	call   f01035b1 <cprintf>
    env_run(curenv);
f0100792:	83 c4 04             	add    $0x4,%esp
f0100795:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f010079b:	e8 4c 2d 00 00       	call   f01034ec <env_run>

f01007a0 <mon_continue>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

int 
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
f01007a0:	55                   	push   %ebp
f01007a1:	89 e5                	mov    %esp,%ebp
f01007a3:	83 ec 08             	sub    $0x8,%esp
f01007a6:	8b 45 10             	mov    0x10(%ebp),%eax
    if (tf == NULL) {
f01007a9:	85 c0                	test   %eax,%eax
f01007ab:	75 14                	jne    f01007c1 <mon_continue+0x21>
        cprintf("Error: you only can use continue in breakpoint.\n");
f01007ad:	83 ec 0c             	sub    $0xc,%esp
f01007b0:	68 34 52 10 f0       	push   $0xf0105234
f01007b5:	e8 f7 2d 00 00       	call   f01035b1 <cprintf>
    }
    tf->tf_eflags &= (~FL_TF);
    env_run(curenv);    // usually it won't return;
    panic("mon_continue : env_run return");
    return 0;
}
f01007ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01007bf:	c9                   	leave  
f01007c0:	c3                   	ret    
{
    if (tf == NULL) {
        cprintf("Error: you only can use continue in breakpoint.\n");
        return -1;
    }
    tf->tf_eflags &= (~FL_TF);
f01007c1:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
    env_run(curenv);    // usually it won't return;
f01007c8:	83 ec 0c             	sub    $0xc,%esp
f01007cb:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f01007d1:	e8 16 2d 00 00       	call   f01034ec <env_run>

f01007d6 <mon_showmappings>:
    return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f01007d6:	55                   	push   %ebp
f01007d7:	89 e5                	mov    %esp,%ebp
f01007d9:	57                   	push   %edi
f01007da:	56                   	push   %esi
f01007db:	53                   	push   %ebx
f01007dc:	83 ec 0c             	sub    $0xc,%esp
f01007df:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 3) {
f01007e2:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01007e6:	74 21                	je     f0100809 <mon_showmappings+0x33>
        cprintf("Command should be: showmappings [addr1] [addr2]\n");
f01007e8:	83 ec 0c             	sub    $0xc,%esp
f01007eb:	68 68 52 10 f0       	push   $0xf0105268
f01007f0:	e8 bc 2d 00 00       	call   f01035b1 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f01007f5:	c7 04 24 9c 52 10 f0 	movl   $0xf010529c,(%esp)
f01007fc:	e8 b0 2d 00 00       	call   f01035b1 <cprintf>
f0100801:	83 c4 10             	add    $0x10,%esp
f0100804:	e9 1a 01 00 00       	jmp    f0100923 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f0100809:	83 ec 04             	sub    $0x4,%esp
f010080c:	6a 00                	push   $0x0
f010080e:	6a 00                	push   $0x0
f0100810:	ff 76 04             	pushl  0x4(%esi)
f0100813:	e8 06 41 00 00       	call   f010491e <strtol>
f0100818:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f010081a:	83 c4 0c             	add    $0xc,%esp
f010081d:	6a 00                	push   $0x0
f010081f:	6a 00                	push   $0x0
f0100821:	ff 76 08             	pushl  0x8(%esi)
f0100824:	e8 f5 40 00 00       	call   f010491e <strtol>
        if (laddr > haddr) {
f0100829:	83 c4 10             	add    $0x10,%esp
f010082c:	39 c3                	cmp    %eax,%ebx
f010082e:	76 01                	jbe    f0100831 <mon_showmappings+0x5b>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100830:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, PGSIZE);
f0100831:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        haddr = ROUNDUP(haddr, PGSIZE);
f0100837:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f010083d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
f0100843:	83 ec 04             	sub    $0x4,%esp
f0100846:	57                   	push   %edi
f0100847:	53                   	push   %ebx
f0100848:	68 19 4f 10 f0       	push   $0xf0104f19
f010084d:	e8 5f 2d 00 00       	call   f01035b1 <cprintf>
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f0100852:	83 c4 10             	add    $0x10,%esp
f0100855:	39 fb                	cmp    %edi,%ebx
f0100857:	75 07                	jne    f0100860 <mon_showmappings+0x8a>
f0100859:	e9 c5 00 00 00       	jmp    f0100923 <mon_showmappings+0x14d>
f010085e:	89 f3                	mov    %esi,%ebx
            cprintf("[ 0x%08x, 0x%08x ) -> ", now, now + PGSIZE); 
f0100860:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
f0100866:	83 ec 04             	sub    $0x4,%esp
f0100869:	56                   	push   %esi
f010086a:	53                   	push   %ebx
f010086b:	68 2a 4f 10 f0       	push   $0xf0104f2a
f0100870:	e8 3c 2d 00 00       	call   f01035b1 <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f0100875:	83 c4 0c             	add    $0xc,%esp
f0100878:	6a 00                	push   $0x0
f010087a:	53                   	push   %ebx
f010087b:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0100881:	e8 90 0c 00 00       	call   f0101516 <pgdir_walk>
f0100886:	89 c3                	mov    %eax,%ebx
            if (pte == 0 || (*pte & PTE_P) == 0) {
f0100888:	83 c4 10             	add    $0x10,%esp
f010088b:	85 c0                	test   %eax,%eax
f010088d:	74 06                	je     f0100895 <mon_showmappings+0xbf>
f010088f:	8b 00                	mov    (%eax),%eax
f0100891:	a8 01                	test   $0x1,%al
f0100893:	75 12                	jne    f01008a7 <mon_showmappings+0xd1>
                cprintf(" no mapped \n");
f0100895:	83 ec 0c             	sub    $0xc,%esp
f0100898:	68 41 4f 10 f0       	push   $0xf0104f41
f010089d:	e8 0f 2d 00 00       	call   f01035b1 <cprintf>
f01008a2:	83 c4 10             	add    $0x10,%esp
f01008a5:	eb 74                	jmp    f010091b <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f01008a7:	83 ec 08             	sub    $0x8,%esp
f01008aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008af:	50                   	push   %eax
f01008b0:	68 4e 4f 10 f0       	push   $0xf0104f4e
f01008b5:	e8 f7 2c 00 00       	call   f01035b1 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f01008ba:	83 c4 10             	add    $0x10,%esp
f01008bd:	f6 03 04             	testb  $0x4,(%ebx)
f01008c0:	74 12                	je     f01008d4 <mon_showmappings+0xfe>
f01008c2:	83 ec 0c             	sub    $0xc,%esp
f01008c5:	68 56 4f 10 f0       	push   $0xf0104f56
f01008ca:	e8 e2 2c 00 00       	call   f01035b1 <cprintf>
f01008cf:	83 c4 10             	add    $0x10,%esp
f01008d2:	eb 10                	jmp    f01008e4 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f01008d4:	83 ec 0c             	sub    $0xc,%esp
f01008d7:	68 63 4f 10 f0       	push   $0xf0104f63
f01008dc:	e8 d0 2c 00 00       	call   f01035b1 <cprintf>
f01008e1:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f01008e4:	f6 03 02             	testb  $0x2,(%ebx)
f01008e7:	74 12                	je     f01008fb <mon_showmappings+0x125>
f01008e9:	83 ec 0c             	sub    $0xc,%esp
f01008ec:	68 70 4f 10 f0       	push   $0xf0104f70
f01008f1:	e8 bb 2c 00 00       	call   f01035b1 <cprintf>
f01008f6:	83 c4 10             	add    $0x10,%esp
f01008f9:	eb 10                	jmp    f010090b <mon_showmappings+0x135>
                else cprintf(" R ");
f01008fb:	83 ec 0c             	sub    $0xc,%esp
f01008fe:	68 75 4f 10 f0       	push   $0xf0104f75
f0100903:	e8 a9 2c 00 00       	call   f01035b1 <cprintf>
f0100908:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f010090b:	83 ec 0c             	sub    $0xc,%esp
f010090e:	68 4c 4f 10 f0       	push   $0xf0104f4c
f0100913:	e8 99 2c 00 00       	call   f01035b1 <cprintf>
f0100918:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDUP(haddr, PGSIZE);
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f010091b:	39 f7                	cmp    %esi,%edi
f010091d:	0f 85 3b ff ff ff    	jne    f010085e <mon_showmappings+0x88>
                cprintf("\n");
            }
        }
    }
    return 0;
}
f0100923:	b8 00 00 00 00       	mov    $0x0,%eax
f0100928:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010092b:	5b                   	pop    %ebx
f010092c:	5e                   	pop    %esi
f010092d:	5f                   	pop    %edi
f010092e:	c9                   	leave  
f010092f:	c3                   	ret    

f0100930 <mon_setpermission>:
    return 0;
}

int
mon_setpermission(int argc, char **argv, struct Trapframe *tf)
{
f0100930:	55                   	push   %ebp
f0100931:	89 e5                	mov    %esp,%ebp
f0100933:	57                   	push   %edi
f0100934:	56                   	push   %esi
f0100935:	53                   	push   %ebx
f0100936:	83 ec 0c             	sub    $0xc,%esp
f0100939:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 5) { 
f010093c:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f0100940:	74 21                	je     f0100963 <mon_setpermission+0x33>
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
f0100942:	83 ec 0c             	sub    $0xc,%esp
f0100945:	68 c4 52 10 f0       	push   $0xf01052c4
f010094a:	e8 62 2c 00 00       	call   f01035b1 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f010094f:	c7 04 24 14 53 10 f0 	movl   $0xf0105314,(%esp)
f0100956:	e8 56 2c 00 00       	call   f01035b1 <cprintf>
f010095b:	83 c4 10             	add    $0x10,%esp
f010095e:	e9 a5 01 00 00       	jmp    f0100b08 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f0100963:	83 ec 04             	sub    $0x4,%esp
f0100966:	6a 00                	push   $0x0
f0100968:	6a 00                	push   $0x0
f010096a:	ff 73 04             	pushl  0x4(%ebx)
f010096d:	e8 ac 3f 00 00       	call   f010491e <strtol>
        uint32_t perm = 0;
        if (argv[2][0] == '1') perm |= PTE_W;
f0100972:	8b 53 08             	mov    0x8(%ebx),%edx
f0100975:	83 c4 10             	add    $0x10,%esp
    if (argc != 5) { 
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
        cprintf("Example: setpermissions 0x0 1 0 1\n");
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
        uint32_t perm = 0;
f0100978:	80 3a 31             	cmpb   $0x31,(%edx)
f010097b:	0f 94 c2             	sete   %dl
f010097e:	0f b6 d2             	movzbl %dl,%edx
f0100981:	89 d6                	mov    %edx,%esi
f0100983:	d1 e6                	shl    %esi
        if (argv[2][0] == '1') perm |= PTE_W;
        if (argv[3][0] == '1') perm |= PTE_U;
f0100985:	8b 53 0c             	mov    0xc(%ebx),%edx
f0100988:	80 3a 31             	cmpb   $0x31,(%edx)
f010098b:	75 03                	jne    f0100990 <mon_setpermission+0x60>
f010098d:	83 ce 04             	or     $0x4,%esi
        if (argv[4][0] == '1') perm |= PTE_P;
f0100990:	8b 53 10             	mov    0x10(%ebx),%edx
f0100993:	80 3a 31             	cmpb   $0x31,(%edx)
f0100996:	75 03                	jne    f010099b <mon_setpermission+0x6b>
f0100998:	83 ce 01             	or     $0x1,%esi
        addr = ROUNDUP(addr, PGSIZE);
f010099b:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01009a1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
f01009a7:	83 ec 04             	sub    $0x4,%esp
f01009aa:	6a 00                	push   $0x0
f01009ac:	57                   	push   %edi
f01009ad:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f01009b3:	e8 5e 0b 00 00       	call   f0101516 <pgdir_walk>
f01009b8:	89 c3                	mov    %eax,%ebx
        if (pte != NULL) {
f01009ba:	83 c4 10             	add    $0x10,%esp
f01009bd:	85 c0                	test   %eax,%eax
f01009bf:	0f 84 33 01 00 00    	je     f0100af8 <mon_setpermission+0x1c8>
            cprintf("0x%08x -> pa: 0x%08x\n old_perm: ", addr, PTE_ADDR(*pte));
f01009c5:	83 ec 04             	sub    $0x4,%esp
f01009c8:	8b 00                	mov    (%eax),%eax
f01009ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009cf:	50                   	push   %eax
f01009d0:	57                   	push   %edi
f01009d1:	68 38 53 10 f0       	push   $0xf0105338
f01009d6:	e8 d6 2b 00 00       	call   f01035b1 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f01009db:	83 c4 10             	add    $0x10,%esp
f01009de:	f6 03 02             	testb  $0x2,(%ebx)
f01009e1:	74 12                	je     f01009f5 <mon_setpermission+0xc5>
f01009e3:	83 ec 0c             	sub    $0xc,%esp
f01009e6:	68 79 4f 10 f0       	push   $0xf0104f79
f01009eb:	e8 c1 2b 00 00       	call   f01035b1 <cprintf>
f01009f0:	83 c4 10             	add    $0x10,%esp
f01009f3:	eb 10                	jmp    f0100a05 <mon_setpermission+0xd5>
f01009f5:	83 ec 0c             	sub    $0xc,%esp
f01009f8:	68 7c 4f 10 f0       	push   $0xf0104f7c
f01009fd:	e8 af 2b 00 00       	call   f01035b1 <cprintf>
f0100a02:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100a05:	f6 03 04             	testb  $0x4,(%ebx)
f0100a08:	74 12                	je     f0100a1c <mon_setpermission+0xec>
f0100a0a:	83 ec 0c             	sub    $0xc,%esp
f0100a0d:	68 6e 60 10 f0       	push   $0xf010606e
f0100a12:	e8 9a 2b 00 00       	call   f01035b1 <cprintf>
f0100a17:	83 c4 10             	add    $0x10,%esp
f0100a1a:	eb 10                	jmp    f0100a2c <mon_setpermission+0xfc>
f0100a1c:	83 ec 0c             	sub    $0xc,%esp
f0100a1f:	68 aa 64 10 f0       	push   $0xf01064aa
f0100a24:	e8 88 2b 00 00       	call   f01035b1 <cprintf>
f0100a29:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100a2c:	f6 03 01             	testb  $0x1,(%ebx)
f0100a2f:	74 12                	je     f0100a43 <mon_setpermission+0x113>
f0100a31:	83 ec 0c             	sub    $0xc,%esp
f0100a34:	68 e2 60 10 f0       	push   $0xf01060e2
f0100a39:	e8 73 2b 00 00       	call   f01035b1 <cprintf>
f0100a3e:	83 c4 10             	add    $0x10,%esp
f0100a41:	eb 10                	jmp    f0100a53 <mon_setpermission+0x123>
f0100a43:	83 ec 0c             	sub    $0xc,%esp
f0100a46:	68 7d 4f 10 f0       	push   $0xf0104f7d
f0100a4b:	e8 61 2b 00 00       	call   f01035b1 <cprintf>
f0100a50:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f0100a53:	83 ec 0c             	sub    $0xc,%esp
f0100a56:	68 7f 4f 10 f0       	push   $0xf0104f7f
f0100a5b:	e8 51 2b 00 00       	call   f01035b1 <cprintf>
            *pte = PTE_ADDR(*pte) | perm;     
f0100a60:	8b 03                	mov    (%ebx),%eax
f0100a62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a67:	09 c6                	or     %eax,%esi
f0100a69:	89 33                	mov    %esi,(%ebx)
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100a6b:	83 c4 10             	add    $0x10,%esp
f0100a6e:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0100a74:	74 12                	je     f0100a88 <mon_setpermission+0x158>
f0100a76:	83 ec 0c             	sub    $0xc,%esp
f0100a79:	68 79 4f 10 f0       	push   $0xf0104f79
f0100a7e:	e8 2e 2b 00 00       	call   f01035b1 <cprintf>
f0100a83:	83 c4 10             	add    $0x10,%esp
f0100a86:	eb 10                	jmp    f0100a98 <mon_setpermission+0x168>
f0100a88:	83 ec 0c             	sub    $0xc,%esp
f0100a8b:	68 7c 4f 10 f0       	push   $0xf0104f7c
f0100a90:	e8 1c 2b 00 00       	call   f01035b1 <cprintf>
f0100a95:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100a98:	f6 03 04             	testb  $0x4,(%ebx)
f0100a9b:	74 12                	je     f0100aaf <mon_setpermission+0x17f>
f0100a9d:	83 ec 0c             	sub    $0xc,%esp
f0100aa0:	68 6e 60 10 f0       	push   $0xf010606e
f0100aa5:	e8 07 2b 00 00       	call   f01035b1 <cprintf>
f0100aaa:	83 c4 10             	add    $0x10,%esp
f0100aad:	eb 10                	jmp    f0100abf <mon_setpermission+0x18f>
f0100aaf:	83 ec 0c             	sub    $0xc,%esp
f0100ab2:	68 aa 64 10 f0       	push   $0xf01064aa
f0100ab7:	e8 f5 2a 00 00       	call   f01035b1 <cprintf>
f0100abc:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100abf:	f6 03 01             	testb  $0x1,(%ebx)
f0100ac2:	74 12                	je     f0100ad6 <mon_setpermission+0x1a6>
f0100ac4:	83 ec 0c             	sub    $0xc,%esp
f0100ac7:	68 e2 60 10 f0       	push   $0xf01060e2
f0100acc:	e8 e0 2a 00 00       	call   f01035b1 <cprintf>
f0100ad1:	83 c4 10             	add    $0x10,%esp
f0100ad4:	eb 10                	jmp    f0100ae6 <mon_setpermission+0x1b6>
f0100ad6:	83 ec 0c             	sub    $0xc,%esp
f0100ad9:	68 7d 4f 10 f0       	push   $0xf0104f7d
f0100ade:	e8 ce 2a 00 00       	call   f01035b1 <cprintf>
f0100ae3:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100ae6:	83 ec 0c             	sub    $0xc,%esp
f0100ae9:	68 4c 4f 10 f0       	push   $0xf0104f4c
f0100aee:	e8 be 2a 00 00       	call   f01035b1 <cprintf>
f0100af3:	83 c4 10             	add    $0x10,%esp
f0100af6:	eb 10                	jmp    f0100b08 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100af8:	83 ec 0c             	sub    $0xc,%esp
f0100afb:	68 41 4f 10 f0       	push   $0xf0104f41
f0100b00:	e8 ac 2a 00 00       	call   f01035b1 <cprintf>
f0100b05:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100b08:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b10:	5b                   	pop    %ebx
f0100b11:	5e                   	pop    %esi
f0100b12:	5f                   	pop    %edi
f0100b13:	c9                   	leave  
f0100b14:	c3                   	ret    

f0100b15 <mon_setcolor>:
    return 0;
}

int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f0100b15:	55                   	push   %ebp
f0100b16:	89 e5                	mov    %esp,%ebp
f0100b18:	56                   	push   %esi
f0100b19:	53                   	push   %ebx
f0100b1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f0100b1d:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100b21:	74 66                	je     f0100b89 <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f0100b23:	83 ec 0c             	sub    $0xc,%esp
f0100b26:	68 5c 53 10 f0       	push   $0xf010535c
f0100b2b:	e8 81 2a 00 00       	call   f01035b1 <cprintf>
        cprintf("num show the color attribute. \n");
f0100b30:	c7 04 24 8c 53 10 f0 	movl   $0xf010538c,(%esp)
f0100b37:	e8 75 2a 00 00       	call   f01035b1 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100b3c:	c7 04 24 ac 53 10 f0 	movl   $0xf01053ac,(%esp)
f0100b43:	e8 69 2a 00 00       	call   f01035b1 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100b48:	c7 04 24 e0 53 10 f0 	movl   $0xf01053e0,(%esp)
f0100b4f:	e8 5d 2a 00 00       	call   f01035b1 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100b54:	c7 04 24 24 54 10 f0 	movl   $0xf0105424,(%esp)
f0100b5b:	e8 51 2a 00 00       	call   f01035b1 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100b60:	c7 04 24 90 4f 10 f0 	movl   $0xf0104f90,(%esp)
f0100b67:	e8 45 2a 00 00       	call   f01035b1 <cprintf>
        cprintf("         set the background color to black\n");
f0100b6c:	c7 04 24 68 54 10 f0 	movl   $0xf0105468,(%esp)
f0100b73:	e8 39 2a 00 00       	call   f01035b1 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100b78:	c7 04 24 94 54 10 f0 	movl   $0xf0105494,(%esp)
f0100b7f:	e8 2d 2a 00 00       	call   f01035b1 <cprintf>
f0100b84:	83 c4 10             	add    $0x10,%esp
f0100b87:	eb 52                	jmp    f0100bdb <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100b89:	83 ec 0c             	sub    $0xc,%esp
f0100b8c:	ff 73 04             	pushl  0x4(%ebx)
f0100b8f:	e8 88 3a 00 00       	call   f010461c <strlen>
f0100b94:	83 c4 10             	add    $0x10,%esp
f0100b97:	48                   	dec    %eax
f0100b98:	78 26                	js     f0100bc0 <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f0100b9a:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100b9d:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100ba2:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f0100ba7:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f0100bab:	0f 94 c3             	sete   %bl
f0100bae:	0f b6 db             	movzbl %bl,%ebx
f0100bb1:	d3 e3                	shl    %cl,%ebx
f0100bb3:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100bb5:	48                   	dec    %eax
f0100bb6:	78 0d                	js     f0100bc5 <mon_setcolor+0xb0>
f0100bb8:	41                   	inc    %ecx
f0100bb9:	83 f9 08             	cmp    $0x8,%ecx
f0100bbc:	75 e9                	jne    f0100ba7 <mon_setcolor+0x92>
f0100bbe:	eb 05                	jmp    f0100bc5 <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100bc0:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f0100bc5:	89 15 40 02 1e f0    	mov    %edx,0xf01e0240
        cprintf(" This is color that you want ! \n");
f0100bcb:	83 ec 0c             	sub    $0xc,%esp
f0100bce:	68 c8 54 10 f0       	push   $0xf01054c8
f0100bd3:	e8 d9 29 00 00       	call   f01035b1 <cprintf>
f0100bd8:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f0100bdb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100be0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100be3:	5b                   	pop    %ebx
f0100be4:	5e                   	pop    %esi
f0100be5:	c9                   	leave  
f0100be6:	c3                   	ret    

f0100be7 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f0100be7:	55                   	push   %ebp
f0100be8:	89 e5                	mov    %esp,%ebp
f0100bea:	57                   	push   %edi
f0100beb:	56                   	push   %esi
f0100bec:	53                   	push   %ebx
f0100bed:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100bf0:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100bf2:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100bf4:	85 c0                	test   %eax,%eax
f0100bf6:	0f 84 8c 00 00 00    	je     f0100c88 <mon_backtrace+0xa1>
        cprintf("!!!!\n");
        eip = *(ebp + 1);
        cprintf("0x%08x\n", (uint32_t)ebp);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100bfc:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        cprintf("!!!!\n");
f0100bff:	83 ec 0c             	sub    $0xc,%esp
f0100c02:	68 ac 4f 10 f0       	push   $0xf0104fac
f0100c07:	e8 a5 29 00 00       	call   f01035b1 <cprintf>
        eip = *(ebp + 1);
f0100c0c:	8b 5e 04             	mov    0x4(%esi),%ebx
        cprintf("0x%08x\n", (uint32_t)ebp);
f0100c0f:	83 c4 08             	add    $0x8,%esp
f0100c12:	56                   	push   %esi
f0100c13:	68 04 63 10 f0       	push   $0xf0106304
f0100c18:	e8 94 29 00 00       	call   f01035b1 <cprintf>
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100c1d:	ff 76 18             	pushl  0x18(%esi)
f0100c20:	ff 76 14             	pushl  0x14(%esi)
f0100c23:	ff 76 10             	pushl  0x10(%esi)
f0100c26:	ff 76 0c             	pushl  0xc(%esi)
f0100c29:	ff 76 08             	pushl  0x8(%esi)
f0100c2c:	53                   	push   %ebx
f0100c2d:	56                   	push   %esi
f0100c2e:	68 ec 54 10 f0       	push   $0xf01054ec
f0100c33:	e8 79 29 00 00       	call   f01035b1 <cprintf>
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100c38:	83 c4 28             	add    $0x28,%esp
f0100c3b:	57                   	push   %edi
f0100c3c:	ff 76 04             	pushl  0x4(%esi)
f0100c3f:	e8 29 31 00 00       	call   f0103d6d <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100c44:	83 c4 0c             	add    $0xc,%esp
f0100c47:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100c4a:	ff 75 d0             	pushl  -0x30(%ebp)
f0100c4d:	68 b2 4f 10 f0       	push   $0xf0104fb2
f0100c52:	e8 5a 29 00 00       	call   f01035b1 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100c57:	83 c4 0c             	add    $0xc,%esp
f0100c5a:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c5d:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c60:	68 c2 4f 10 f0       	push   $0xf0104fc2
f0100c65:	e8 47 29 00 00       	call   f01035b1 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100c6a:	83 c4 08             	add    $0x8,%esp
f0100c6d:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100c70:	53                   	push   %ebx
f0100c71:	68 c7 4f 10 f0       	push   $0xf0104fc7
f0100c76:	e8 36 29 00 00       	call   f01035b1 <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100c7b:	8b 36                	mov    (%esi),%esi
f0100c7d:	83 c4 10             	add    $0x10,%esp
f0100c80:	85 f6                	test   %esi,%esi
f0100c82:	0f 85 77 ff ff ff    	jne    f0100bff <mon_backtrace+0x18>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100c88:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c90:	5b                   	pop    %ebx
f0100c91:	5e                   	pop    %esi
f0100c92:	5f                   	pop    %edi
f0100c93:	c9                   	leave  
f0100c94:	c3                   	ret    

f0100c95 <pa_con>:
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
f0100c95:	55                   	push   %ebp
f0100c96:	89 e5                	mov    %esp,%ebp
f0100c98:	53                   	push   %ebx
f0100c99:	83 ec 04             	sub    $0x4,%esp
f0100c9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
f0100ca2:	8b 15 4c 11 1e f0    	mov    0xf01e114c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ca8:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100cae:	77 15                	ja     f0100cc5 <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100cb0:	52                   	push   %edx
f0100cb1:	68 24 55 10 f0       	push   $0xf0105524
f0100cb6:	68 98 00 00 00       	push   $0x98
f0100cbb:	68 cc 4f 10 f0       	push   $0xf0104fcc
f0100cc0:	e8 0d f4 ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100cc5:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100ccb:	39 d0                	cmp    %edx,%eax
f0100ccd:	72 18                	jb     f0100ce7 <pa_con+0x52>
f0100ccf:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
f0100cd5:	39 d8                	cmp    %ebx,%eax
f0100cd7:	73 0e                	jae    f0100ce7 <pa_con+0x52>
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
f0100cd9:	29 d0                	sub    %edx,%eax
f0100cdb:	8b 80 00 00 00 ef    	mov    -0x11000000(%eax),%eax
f0100ce1:	89 01                	mov    %eax,(%ecx)
        return true;
f0100ce3:	b0 01                	mov    $0x1,%al
f0100ce5:	eb 56                	jmp    f0100d3d <pa_con+0xa8>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ce7:	ba 00 90 11 f0       	mov    $0xf0119000,%edx
f0100cec:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100cf2:	77 15                	ja     f0100d09 <pa_con+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100cf4:	52                   	push   %edx
f0100cf5:	68 24 55 10 f0       	push   $0xf0105524
f0100cfa:	68 9d 00 00 00       	push   $0x9d
f0100cff:	68 cc 4f 10 f0       	push   $0xf0104fcc
f0100d04:	e8 c9 f3 ff ff       	call   f01000d2 <_panic>
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
f0100d09:	3d 00 90 11 00       	cmp    $0x119000,%eax
f0100d0e:	72 18                	jb     f0100d28 <pa_con+0x93>
f0100d10:	3d 00 10 12 00       	cmp    $0x121000,%eax
f0100d15:	73 11                	jae    f0100d28 <pa_con+0x93>
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
f0100d17:	2d 00 90 11 00       	sub    $0x119000,%eax
f0100d1c:	8b 80 00 80 ff ef    	mov    -0x10008000(%eax),%eax
f0100d22:	89 01                	mov    %eax,(%ecx)
        return true;
f0100d24:	b0 01                	mov    $0x1,%al
f0100d26:	eb 15                	jmp    f0100d3d <pa_con+0xa8>
    }
    if (addr < -KERNBASE) {
f0100d28:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100d2d:	77 0c                	ja     f0100d3b <pa_con+0xa6>
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
f0100d2f:	8b 80 00 00 00 f0    	mov    -0x10000000(%eax),%eax
f0100d35:	89 01                	mov    %eax,(%ecx)
        return true;
f0100d37:	b0 01                	mov    $0x1,%al
f0100d39:	eb 02                	jmp    f0100d3d <pa_con+0xa8>
    }
    // Not in virtual memory mapped.
    return false;
f0100d3b:	b0 00                	mov    $0x0,%al
}
f0100d3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100d40:	c9                   	leave  
f0100d41:	c3                   	ret    

f0100d42 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
f0100d42:	55                   	push   %ebp
f0100d43:	89 e5                	mov    %esp,%ebp
f0100d45:	57                   	push   %edi
f0100d46:	56                   	push   %esi
f0100d47:	53                   	push   %ebx
f0100d48:	83 ec 2c             	sub    $0x2c,%esp
f0100d4b:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 4) {
f0100d4e:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100d52:	74 2d                	je     f0100d81 <mon_dump+0x3f>
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
f0100d54:	83 ec 0c             	sub    $0xc,%esp
f0100d57:	68 48 55 10 f0       	push   $0xf0105548
f0100d5c:	e8 50 28 00 00       	call   f01035b1 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100d61:	c7 04 24 78 55 10 f0 	movl   $0xf0105578,(%esp)
f0100d68:	e8 44 28 00 00       	call   f01035b1 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100d6d:	c7 04 24 a0 55 10 f0 	movl   $0xf01055a0,(%esp)
f0100d74:	e8 38 28 00 00       	call   f01035b1 <cprintf>
f0100d79:	83 c4 10             	add    $0x10,%esp
f0100d7c:	e9 59 01 00 00       	jmp    f0100eda <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100d81:	83 ec 04             	sub    $0x4,%esp
f0100d84:	6a 00                	push   $0x0
f0100d86:	6a 00                	push   $0x0
f0100d88:	ff 76 08             	pushl  0x8(%esi)
f0100d8b:	e8 8e 3b 00 00       	call   f010491e <strtol>
f0100d90:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100d92:	83 c4 0c             	add    $0xc,%esp
f0100d95:	6a 00                	push   $0x0
f0100d97:	6a 00                	push   $0x0
f0100d99:	ff 76 0c             	pushl  0xc(%esi)
f0100d9c:	e8 7d 3b 00 00       	call   f010491e <strtol>
        if (laddr > haddr) {
f0100da1:	83 c4 10             	add    $0x10,%esp
f0100da4:	39 c3                	cmp    %eax,%ebx
f0100da6:	76 01                	jbe    f0100da9 <mon_dump+0x67>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100da8:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, 4);
f0100da9:	89 df                	mov    %ebx,%edi
f0100dab:	83 e7 fc             	and    $0xfffffffc,%edi
        haddr = ROUNDDOWN(haddr, 4);
f0100dae:	83 e0 fc             	and    $0xfffffffc,%eax
f0100db1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if (argv[1][0] == 'v') {
f0100db4:	8b 46 04             	mov    0x4(%esi),%eax
f0100db7:	80 38 76             	cmpb   $0x76,(%eax)
f0100dba:	74 0e                	je     f0100dca <mon_dump+0x88>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100dbc:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100dbf:	0f 85 98 00 00 00    	jne    f0100e5d <mon_dump+0x11b>
f0100dc5:	e9 00 01 00 00       	jmp    f0100eca <mon_dump+0x188>
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100dca:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100dcd:	74 7c                	je     f0100e4b <mon_dump+0x109>
f0100dcf:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100dd1:	39 fb                	cmp    %edi,%ebx
f0100dd3:	74 15                	je     f0100dea <mon_dump+0xa8>
f0100dd5:	f6 c3 0f             	test   $0xf,%bl
f0100dd8:	75 21                	jne    f0100dfb <mon_dump+0xb9>
                    if (now != laddr) cprintf("\n"); 
f0100dda:	83 ec 0c             	sub    $0xc,%esp
f0100ddd:	68 4c 4f 10 f0       	push   $0xf0104f4c
f0100de2:	e8 ca 27 00 00       	call   f01035b1 <cprintf>
f0100de7:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100dea:	83 ec 08             	sub    $0x8,%esp
f0100ded:	53                   	push   %ebx
f0100dee:	68 db 4f 10 f0       	push   $0xf0104fdb
f0100df3:	e8 b9 27 00 00       	call   f01035b1 <cprintf>
f0100df8:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100dfb:	83 ec 04             	sub    $0x4,%esp
f0100dfe:	6a 00                	push   $0x0
f0100e00:	89 d8                	mov    %ebx,%eax
f0100e02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e07:	50                   	push   %eax
f0100e08:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0100e0e:	e8 03 07 00 00       	call   f0101516 <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100e13:	83 c4 10             	add    $0x10,%esp
f0100e16:	85 c0                	test   %eax,%eax
f0100e18:	74 19                	je     f0100e33 <mon_dump+0xf1>
f0100e1a:	f6 00 01             	testb  $0x1,(%eax)
f0100e1d:	74 14                	je     f0100e33 <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100e1f:	83 ec 08             	sub    $0x8,%esp
f0100e22:	ff 33                	pushl  (%ebx)
f0100e24:	68 e5 4f 10 f0       	push   $0xf0104fe5
f0100e29:	e8 83 27 00 00       	call   f01035b1 <cprintf>
f0100e2e:	83 c4 10             	add    $0x10,%esp
f0100e31:	eb 10                	jmp    f0100e43 <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100e33:	83 ec 0c             	sub    $0xc,%esp
f0100e36:	68 f0 4f 10 f0       	push   $0xf0104ff0
f0100e3b:	e8 71 27 00 00       	call   f01035b1 <cprintf>
f0100e40:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100e43:	83 c3 04             	add    $0x4,%ebx
f0100e46:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100e49:	75 86                	jne    f0100dd1 <mon_dump+0x8f>
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
f0100e4b:	83 ec 0c             	sub    $0xc,%esp
f0100e4e:	68 4c 4f 10 f0       	push   $0xf0104f4c
f0100e53:	e8 59 27 00 00       	call   f01035b1 <cprintf>
f0100e58:	83 c4 10             	add    $0x10,%esp
f0100e5b:	eb 7d                	jmp    f0100eda <mon_dump+0x198>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100e5d:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100e5f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100e62:	39 fb                	cmp    %edi,%ebx
f0100e64:	74 15                	je     f0100e7b <mon_dump+0x139>
f0100e66:	f6 c3 0f             	test   $0xf,%bl
f0100e69:	75 21                	jne    f0100e8c <mon_dump+0x14a>
                    if (now != laddr) cprintf("\n");
f0100e6b:	83 ec 0c             	sub    $0xc,%esp
f0100e6e:	68 4c 4f 10 f0       	push   $0xf0104f4c
f0100e73:	e8 39 27 00 00       	call   f01035b1 <cprintf>
f0100e78:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100e7b:	83 ec 08             	sub    $0x8,%esp
f0100e7e:	53                   	push   %ebx
f0100e7f:	68 db 4f 10 f0       	push   $0xf0104fdb
f0100e84:	e8 28 27 00 00       	call   f01035b1 <cprintf>
f0100e89:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f0100e8c:	83 ec 08             	sub    $0x8,%esp
f0100e8f:	56                   	push   %esi
f0100e90:	53                   	push   %ebx
f0100e91:	e8 ff fd ff ff       	call   f0100c95 <pa_con>
f0100e96:	83 c4 10             	add    $0x10,%esp
f0100e99:	84 c0                	test   %al,%al
f0100e9b:	74 15                	je     f0100eb2 <mon_dump+0x170>
                    cprintf("0x%08x  ", value);
f0100e9d:	83 ec 08             	sub    $0x8,%esp
f0100ea0:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100ea3:	68 e5 4f 10 f0       	push   $0xf0104fe5
f0100ea8:	e8 04 27 00 00       	call   f01035b1 <cprintf>
f0100ead:	83 c4 10             	add    $0x10,%esp
f0100eb0:	eb 10                	jmp    f0100ec2 <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100eb2:	83 ec 0c             	sub    $0xc,%esp
f0100eb5:	68 ee 4f 10 f0       	push   $0xf0104fee
f0100eba:	e8 f2 26 00 00       	call   f01035b1 <cprintf>
f0100ebf:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100ec2:	83 c3 04             	add    $0x4,%ebx
f0100ec5:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100ec8:	75 98                	jne    f0100e62 <mon_dump+0x120>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f0100eca:	83 ec 0c             	sub    $0xc,%esp
f0100ecd:	68 4c 4f 10 f0       	push   $0xf0104f4c
f0100ed2:	e8 da 26 00 00       	call   f01035b1 <cprintf>
f0100ed7:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100eda:	b8 00 00 00 00       	mov    $0x0,%eax
f0100edf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ee2:	5b                   	pop    %ebx
f0100ee3:	5e                   	pop    %esi
f0100ee4:	5f                   	pop    %edi
f0100ee5:	c9                   	leave  
f0100ee6:	c3                   	ret    

f0100ee7 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100ee7:	55                   	push   %ebp
f0100ee8:	89 e5                	mov    %esp,%ebp
f0100eea:	57                   	push   %edi
f0100eeb:	56                   	push   %esi
f0100eec:	53                   	push   %ebx
f0100eed:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100ef0:	68 e4 55 10 f0       	push   $0xf01055e4
f0100ef5:	e8 b7 26 00 00       	call   f01035b1 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100efa:	c7 04 24 08 56 10 f0 	movl   $0xf0105608,(%esp)
f0100f01:	e8 ab 26 00 00       	call   f01035b1 <cprintf>

	if (tf != NULL)
f0100f06:	83 c4 10             	add    $0x10,%esp
f0100f09:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100f0d:	74 0e                	je     f0100f1d <monitor+0x36>
		print_trapframe(tf);
f0100f0f:	83 ec 0c             	sub    $0xc,%esp
f0100f12:	ff 75 08             	pushl  0x8(%ebp)
f0100f15:	e8 4a 28 00 00       	call   f0103764 <print_trapframe>
f0100f1a:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100f1d:	83 ec 0c             	sub    $0xc,%esp
f0100f20:	68 fb 4f 10 f0       	push   $0xf0104ffb
f0100f25:	e8 22 36 00 00       	call   f010454c <readline>
f0100f2a:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100f2c:	83 c4 10             	add    $0x10,%esp
f0100f2f:	85 c0                	test   %eax,%eax
f0100f31:	74 ea                	je     f0100f1d <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100f33:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100f3a:	be 00 00 00 00       	mov    $0x0,%esi
f0100f3f:	eb 04                	jmp    f0100f45 <monitor+0x5e>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100f41:	c6 03 00             	movb   $0x0,(%ebx)
f0100f44:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100f45:	8a 03                	mov    (%ebx),%al
f0100f47:	84 c0                	test   %al,%al
f0100f49:	74 64                	je     f0100faf <monitor+0xc8>
f0100f4b:	83 ec 08             	sub    $0x8,%esp
f0100f4e:	0f be c0             	movsbl %al,%eax
f0100f51:	50                   	push   %eax
f0100f52:	68 ff 4f 10 f0       	push   $0xf0104fff
f0100f57:	e8 39 38 00 00       	call   f0104795 <strchr>
f0100f5c:	83 c4 10             	add    $0x10,%esp
f0100f5f:	85 c0                	test   %eax,%eax
f0100f61:	75 de                	jne    f0100f41 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100f63:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100f66:	74 47                	je     f0100faf <monitor+0xc8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100f68:	83 fe 0f             	cmp    $0xf,%esi
f0100f6b:	75 14                	jne    f0100f81 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100f6d:	83 ec 08             	sub    $0x8,%esp
f0100f70:	6a 10                	push   $0x10
f0100f72:	68 04 50 10 f0       	push   $0xf0105004
f0100f77:	e8 35 26 00 00       	call   f01035b1 <cprintf>
f0100f7c:	83 c4 10             	add    $0x10,%esp
f0100f7f:	eb 9c                	jmp    f0100f1d <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100f81:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100f85:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f86:	8a 03                	mov    (%ebx),%al
f0100f88:	84 c0                	test   %al,%al
f0100f8a:	75 09                	jne    f0100f95 <monitor+0xae>
f0100f8c:	eb b7                	jmp    f0100f45 <monitor+0x5e>
			buf++;
f0100f8e:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f8f:	8a 03                	mov    (%ebx),%al
f0100f91:	84 c0                	test   %al,%al
f0100f93:	74 b0                	je     f0100f45 <monitor+0x5e>
f0100f95:	83 ec 08             	sub    $0x8,%esp
f0100f98:	0f be c0             	movsbl %al,%eax
f0100f9b:	50                   	push   %eax
f0100f9c:	68 ff 4f 10 f0       	push   $0xf0104fff
f0100fa1:	e8 ef 37 00 00       	call   f0104795 <strchr>
f0100fa6:	83 c4 10             	add    $0x10,%esp
f0100fa9:	85 c0                	test   %eax,%eax
f0100fab:	74 e1                	je     f0100f8e <monitor+0xa7>
f0100fad:	eb 96                	jmp    f0100f45 <monitor+0x5e>
			buf++;
	}
	argv[argc] = 0;
f0100faf:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100fb6:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100fb7:	85 f6                	test   %esi,%esi
f0100fb9:	0f 84 5e ff ff ff    	je     f0100f1d <monitor+0x36>
f0100fbf:	bb 80 56 10 f0       	mov    $0xf0105680,%ebx
f0100fc4:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100fc9:	83 ec 08             	sub    $0x8,%esp
f0100fcc:	ff 33                	pushl  (%ebx)
f0100fce:	ff 75 a8             	pushl  -0x58(%ebp)
f0100fd1:	e8 51 37 00 00       	call   f0104727 <strcmp>
f0100fd6:	83 c4 10             	add    $0x10,%esp
f0100fd9:	85 c0                	test   %eax,%eax
f0100fdb:	75 20                	jne    f0100ffd <monitor+0x116>
			return commands[i].func(argc, argv, tf);
f0100fdd:	83 ec 04             	sub    $0x4,%esp
f0100fe0:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100fe3:	ff 75 08             	pushl  0x8(%ebp)
f0100fe6:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100fe9:	50                   	push   %eax
f0100fea:	56                   	push   %esi
f0100feb:	ff 97 88 56 10 f0    	call   *-0xfefa978(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ff1:	83 c4 10             	add    $0x10,%esp
f0100ff4:	85 c0                	test   %eax,%eax
f0100ff6:	78 26                	js     f010101e <monitor+0x137>
f0100ff8:	e9 20 ff ff ff       	jmp    f0100f1d <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100ffd:	47                   	inc    %edi
f0100ffe:	83 c3 0c             	add    $0xc,%ebx
f0101001:	83 ff 0a             	cmp    $0xa,%edi
f0101004:	75 c3                	jne    f0100fc9 <monitor+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0101006:	83 ec 08             	sub    $0x8,%esp
f0101009:	ff 75 a8             	pushl  -0x58(%ebp)
f010100c:	68 21 50 10 f0       	push   $0xf0105021
f0101011:	e8 9b 25 00 00       	call   f01035b1 <cprintf>
f0101016:	83 c4 10             	add    $0x10,%esp
f0101019:	e9 ff fe ff ff       	jmp    f0100f1d <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010101e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101021:	5b                   	pop    %ebx
f0101022:	5e                   	pop    %esi
f0101023:	5f                   	pop    %edi
f0101024:	c9                   	leave  
f0101025:	c3                   	ret    
	...

f0101028 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0101028:	55                   	push   %ebp
f0101029:	89 e5                	mov    %esp,%ebp
f010102b:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010102d:	83 3d 74 04 1e f0 00 	cmpl   $0x0,0xf01e0474
f0101034:	75 0f                	jne    f0101045 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101036:	b8 4f 21 1e f0       	mov    $0xf01e214f,%eax
f010103b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101040:	a3 74 04 1e f0       	mov    %eax,0xf01e0474
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0101045:	a1 74 04 1e f0       	mov    0xf01e0474,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f010104a:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0101051:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101057:	89 15 74 04 1e f0    	mov    %edx,0xf01e0474

	return result;
}
f010105d:	c9                   	leave  
f010105e:	c3                   	ret    

f010105f <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010105f:	55                   	push   %ebp
f0101060:	89 e5                	mov    %esp,%ebp
f0101062:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0101065:	89 d1                	mov    %edx,%ecx
f0101067:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f010106a:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010106d:	a8 01                	test   $0x1,%al
f010106f:	74 42                	je     f01010b3 <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101071:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101076:	89 c1                	mov    %eax,%ecx
f0101078:	c1 e9 0c             	shr    $0xc,%ecx
f010107b:	3b 0d 44 11 1e f0    	cmp    0xf01e1144,%ecx
f0101081:	72 15                	jb     f0101098 <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101083:	50                   	push   %eax
f0101084:	68 f8 56 10 f0       	push   $0xf01056f8
f0101089:	68 1b 03 00 00       	push   $0x31b
f010108e:	68 59 5e 10 f0       	push   $0xf0105e59
f0101093:	e8 3a f0 ff ff       	call   f01000d2 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101098:	c1 ea 0c             	shr    $0xc,%edx
f010109b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01010a1:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01010a8:	a8 01                	test   $0x1,%al
f01010aa:	74 0e                	je     f01010ba <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01010ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01010b1:	eb 0c                	jmp    f01010bf <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01010b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01010b8:	eb 05                	jmp    f01010bf <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f01010ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f01010bf:	c9                   	leave  
f01010c0:	c3                   	ret    

f01010c1 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01010c1:	55                   	push   %ebp
f01010c2:	89 e5                	mov    %esp,%ebp
f01010c4:	56                   	push   %esi
f01010c5:	53                   	push   %ebx
f01010c6:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01010c8:	83 ec 0c             	sub    $0xc,%esp
f01010cb:	50                   	push   %eax
f01010cc:	e8 7f 24 00 00       	call   f0103550 <mc146818_read>
f01010d1:	89 c6                	mov    %eax,%esi
f01010d3:	43                   	inc    %ebx
f01010d4:	89 1c 24             	mov    %ebx,(%esp)
f01010d7:	e8 74 24 00 00       	call   f0103550 <mc146818_read>
f01010dc:	c1 e0 08             	shl    $0x8,%eax
f01010df:	09 f0                	or     %esi,%eax
}
f01010e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010e4:	5b                   	pop    %ebx
f01010e5:	5e                   	pop    %esi
f01010e6:	c9                   	leave  
f01010e7:	c3                   	ret    

f01010e8 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01010e8:	55                   	push   %ebp
f01010e9:	89 e5                	mov    %esp,%ebp
f01010eb:	57                   	push   %edi
f01010ec:	56                   	push   %esi
f01010ed:	53                   	push   %ebx
f01010ee:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01010f1:	3c 01                	cmp    $0x1,%al
f01010f3:	19 f6                	sbb    %esi,%esi
f01010f5:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f01010fb:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01010fc:	8b 1d 70 04 1e f0    	mov    0xf01e0470,%ebx
f0101102:	85 db                	test   %ebx,%ebx
f0101104:	75 17                	jne    f010111d <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f0101106:	83 ec 04             	sub    $0x4,%esp
f0101109:	68 1c 57 10 f0       	push   $0xf010571c
f010110e:	68 59 02 00 00       	push   $0x259
f0101113:	68 59 5e 10 f0       	push   $0xf0105e59
f0101118:	e8 b5 ef ff ff       	call   f01000d2 <_panic>

	if (only_low_memory) {
f010111d:	84 c0                	test   %al,%al
f010111f:	74 50                	je     f0101171 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101121:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101124:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101127:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010112a:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010112d:	89 d8                	mov    %ebx,%eax
f010112f:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0101135:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101138:	c1 e8 16             	shr    $0x16,%eax
f010113b:	39 c6                	cmp    %eax,%esi
f010113d:	0f 96 c0             	setbe  %al
f0101140:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101143:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0101147:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101149:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010114d:	8b 1b                	mov    (%ebx),%ebx
f010114f:	85 db                	test   %ebx,%ebx
f0101151:	75 da                	jne    f010112d <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101153:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101156:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010115c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010115f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101162:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101164:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101167:	89 1d 70 04 1e f0    	mov    %ebx,0xf01e0470
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010116d:	85 db                	test   %ebx,%ebx
f010116f:	74 57                	je     f01011c8 <check_page_free_list+0xe0>
f0101171:	89 d8                	mov    %ebx,%eax
f0101173:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0101179:	c1 f8 03             	sar    $0x3,%eax
f010117c:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010117f:	89 c2                	mov    %eax,%edx
f0101181:	c1 ea 16             	shr    $0x16,%edx
f0101184:	39 d6                	cmp    %edx,%esi
f0101186:	76 3a                	jbe    f01011c2 <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101188:	89 c2                	mov    %eax,%edx
f010118a:	c1 ea 0c             	shr    $0xc,%edx
f010118d:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0101193:	72 12                	jb     f01011a7 <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101195:	50                   	push   %eax
f0101196:	68 f8 56 10 f0       	push   $0xf01056f8
f010119b:	6a 56                	push   $0x56
f010119d:	68 65 5e 10 f0       	push   $0xf0105e65
f01011a2:	e8 2b ef ff ff       	call   f01000d2 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01011a7:	83 ec 04             	sub    $0x4,%esp
f01011aa:	68 80 00 00 00       	push   $0x80
f01011af:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01011b4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01011b9:	50                   	push   %eax
f01011ba:	e8 26 36 00 00       	call   f01047e5 <memset>
f01011bf:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01011c2:	8b 1b                	mov    (%ebx),%ebx
f01011c4:	85 db                	test   %ebx,%ebx
f01011c6:	75 a9                	jne    f0101171 <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01011c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01011cd:	e8 56 fe ff ff       	call   f0101028 <boot_alloc>
f01011d2:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011d5:	8b 15 70 04 1e f0    	mov    0xf01e0470,%edx
f01011db:	85 d2                	test   %edx,%edx
f01011dd:	0f 84 80 01 00 00    	je     f0101363 <check_page_free_list+0x27b>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01011e3:	8b 1d 4c 11 1e f0    	mov    0xf01e114c,%ebx
f01011e9:	39 da                	cmp    %ebx,%edx
f01011eb:	72 43                	jb     f0101230 <check_page_free_list+0x148>
		assert(pp < pages + npages);
f01011ed:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f01011f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01011f5:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f01011f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011fb:	39 c2                	cmp    %eax,%edx
f01011fd:	73 4f                	jae    f010124e <check_page_free_list+0x166>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01011ff:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0101202:	89 d0                	mov    %edx,%eax
f0101204:	29 d8                	sub    %ebx,%eax
f0101206:	a8 07                	test   $0x7,%al
f0101208:	75 66                	jne    f0101270 <check_page_free_list+0x188>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010120a:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010120d:	c1 e0 0c             	shl    $0xc,%eax
f0101210:	74 7f                	je     f0101291 <check_page_free_list+0x1a9>
		assert(page2pa(pp) != IOPHYSMEM);
f0101212:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101217:	0f 84 94 00 00 00    	je     f01012b1 <check_page_free_list+0x1c9>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f010121d:	be 00 00 00 00       	mov    $0x0,%esi
f0101222:	bf 00 00 00 00       	mov    $0x0,%edi
f0101227:	e9 9e 00 00 00       	jmp    f01012ca <check_page_free_list+0x1e2>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010122c:	39 da                	cmp    %ebx,%edx
f010122e:	73 19                	jae    f0101249 <check_page_free_list+0x161>
f0101230:	68 73 5e 10 f0       	push   $0xf0105e73
f0101235:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010123a:	68 73 02 00 00       	push   $0x273
f010123f:	68 59 5e 10 f0       	push   $0xf0105e59
f0101244:	e8 89 ee ff ff       	call   f01000d2 <_panic>
		assert(pp < pages + npages);
f0101249:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f010124c:	72 19                	jb     f0101267 <check_page_free_list+0x17f>
f010124e:	68 94 5e 10 f0       	push   $0xf0105e94
f0101253:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101258:	68 74 02 00 00       	push   $0x274
f010125d:	68 59 5e 10 f0       	push   $0xf0105e59
f0101262:	e8 6b ee ff ff       	call   f01000d2 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101267:	89 d0                	mov    %edx,%eax
f0101269:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010126c:	a8 07                	test   $0x7,%al
f010126e:	74 19                	je     f0101289 <check_page_free_list+0x1a1>
f0101270:	68 40 57 10 f0       	push   $0xf0105740
f0101275:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010127a:	68 75 02 00 00       	push   $0x275
f010127f:	68 59 5e 10 f0       	push   $0xf0105e59
f0101284:	e8 49 ee ff ff       	call   f01000d2 <_panic>
f0101289:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010128c:	c1 e0 0c             	shl    $0xc,%eax
f010128f:	75 19                	jne    f01012aa <check_page_free_list+0x1c2>
f0101291:	68 a8 5e 10 f0       	push   $0xf0105ea8
f0101296:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010129b:	68 78 02 00 00       	push   $0x278
f01012a0:	68 59 5e 10 f0       	push   $0xf0105e59
f01012a5:	e8 28 ee ff ff       	call   f01000d2 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01012aa:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01012af:	75 19                	jne    f01012ca <check_page_free_list+0x1e2>
f01012b1:	68 b9 5e 10 f0       	push   $0xf0105eb9
f01012b6:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01012bb:	68 79 02 00 00       	push   $0x279
f01012c0:	68 59 5e 10 f0       	push   $0xf0105e59
f01012c5:	e8 08 ee ff ff       	call   f01000d2 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01012ca:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01012cf:	75 19                	jne    f01012ea <check_page_free_list+0x202>
f01012d1:	68 74 57 10 f0       	push   $0xf0105774
f01012d6:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01012db:	68 7a 02 00 00       	push   $0x27a
f01012e0:	68 59 5e 10 f0       	push   $0xf0105e59
f01012e5:	e8 e8 ed ff ff       	call   f01000d2 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01012ea:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01012ef:	75 19                	jne    f010130a <check_page_free_list+0x222>
f01012f1:	68 d2 5e 10 f0       	push   $0xf0105ed2
f01012f6:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01012fb:	68 7b 02 00 00       	push   $0x27b
f0101300:	68 59 5e 10 f0       	push   $0xf0105e59
f0101305:	e8 c8 ed ff ff       	call   f01000d2 <_panic>
f010130a:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010130c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101311:	76 3e                	jbe    f0101351 <check_page_free_list+0x269>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101313:	c1 e8 0c             	shr    $0xc,%eax
f0101316:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101319:	77 12                	ja     f010132d <check_page_free_list+0x245>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010131b:	51                   	push   %ecx
f010131c:	68 f8 56 10 f0       	push   $0xf01056f8
f0101321:	6a 56                	push   $0x56
f0101323:	68 65 5e 10 f0       	push   $0xf0105e65
f0101328:	e8 a5 ed ff ff       	call   f01000d2 <_panic>
	return (void *)(pa + KERNBASE);
f010132d:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101333:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0101336:	76 1c                	jbe    f0101354 <check_page_free_list+0x26c>
f0101338:	68 98 57 10 f0       	push   $0xf0105798
f010133d:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101342:	68 7c 02 00 00       	push   $0x27c
f0101347:	68 59 5e 10 f0       	push   $0xf0105e59
f010134c:	e8 81 ed ff ff       	call   f01000d2 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101351:	47                   	inc    %edi
f0101352:	eb 01                	jmp    f0101355 <check_page_free_list+0x26d>
		else
			++nfree_extmem;
f0101354:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101355:	8b 12                	mov    (%edx),%edx
f0101357:	85 d2                	test   %edx,%edx
f0101359:	0f 85 cd fe ff ff    	jne    f010122c <check_page_free_list+0x144>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010135f:	85 ff                	test   %edi,%edi
f0101361:	7f 19                	jg     f010137c <check_page_free_list+0x294>
f0101363:	68 ec 5e 10 f0       	push   $0xf0105eec
f0101368:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010136d:	68 84 02 00 00       	push   $0x284
f0101372:	68 59 5e 10 f0       	push   $0xf0105e59
f0101377:	e8 56 ed ff ff       	call   f01000d2 <_panic>
	assert(nfree_extmem > 0);
f010137c:	85 f6                	test   %esi,%esi
f010137e:	7f 19                	jg     f0101399 <check_page_free_list+0x2b1>
f0101380:	68 fe 5e 10 f0       	push   $0xf0105efe
f0101385:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010138a:	68 85 02 00 00       	push   $0x285
f010138f:	68 59 5e 10 f0       	push   $0xf0105e59
f0101394:	e8 39 ed ff ff       	call   f01000d2 <_panic>
}
f0101399:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010139c:	5b                   	pop    %ebx
f010139d:	5e                   	pop    %esi
f010139e:	5f                   	pop    %edi
f010139f:	c9                   	leave  
f01013a0:	c3                   	ret    

f01013a1 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01013a1:	55                   	push   %ebp
f01013a2:	89 e5                	mov    %esp,%ebp
f01013a4:	56                   	push   %esi
f01013a5:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f01013a6:	c7 05 70 04 1e f0 00 	movl   $0x0,0xf01e0470
f01013ad:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f01013b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01013b5:	e8 6e fc ff ff       	call   f0101028 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013ba:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013bf:	77 15                	ja     f01013d6 <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013c1:	50                   	push   %eax
f01013c2:	68 24 55 10 f0       	push   $0xf0105524
f01013c7:	68 25 01 00 00       	push   $0x125
f01013cc:	68 59 5e 10 f0       	push   $0xf0105e59
f01013d1:	e8 fc ec ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01013d6:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f01013dc:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f01013df:	83 3d 44 11 1e f0 00 	cmpl   $0x0,0xf01e1144
f01013e6:	74 5f                	je     f0101447 <page_init+0xa6>
f01013e8:	8b 1d 70 04 1e f0    	mov    0xf01e0470,%ebx
f01013ee:	ba 00 00 00 00       	mov    $0x0,%edx
f01013f3:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f01013f8:	85 c0                	test   %eax,%eax
f01013fa:	74 25                	je     f0101421 <page_init+0x80>
f01013fc:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0101401:	76 04                	jbe    f0101407 <page_init+0x66>
f0101403:	39 c6                	cmp    %eax,%esi
f0101405:	77 1a                	ja     f0101421 <page_init+0x80>
		    pages[i].pp_ref = 0;
f0101407:	89 d1                	mov    %edx,%ecx
f0101409:	03 0d 4c 11 1e f0    	add    0xf01e114c,%ecx
f010140f:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f0101415:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f0101417:	89 d3                	mov    %edx,%ebx
f0101419:	03 1d 4c 11 1e f0    	add    0xf01e114c,%ebx
f010141f:	eb 14                	jmp    f0101435 <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f0101421:	89 d1                	mov    %edx,%ecx
f0101423:	03 0d 4c 11 1e f0    	add    0xf01e114c,%ecx
f0101429:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f010142f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// free pages!
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    for (i = 0; i < npages; i++) {
f0101435:	40                   	inc    %eax
f0101436:	83 c2 08             	add    $0x8,%edx
f0101439:	39 05 44 11 1e f0    	cmp    %eax,0xf01e1144
f010143f:	77 b7                	ja     f01013f8 <page_init+0x57>
f0101441:	89 1d 70 04 1e f0    	mov    %ebx,0xf01e0470
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f0101447:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010144a:	5b                   	pop    %ebx
f010144b:	5e                   	pop    %esi
f010144c:	c9                   	leave  
f010144d:	c3                   	ret    

f010144e <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f010144e:	55                   	push   %ebp
f010144f:	89 e5                	mov    %esp,%ebp
f0101451:	53                   	push   %ebx
f0101452:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f0101455:	8b 1d 70 04 1e f0    	mov    0xf01e0470,%ebx
f010145b:	85 db                	test   %ebx,%ebx
f010145d:	74 63                	je     f01014c2 <page_alloc+0x74>
f010145f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101464:	74 63                	je     f01014c9 <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f0101466:	8b 1b                	mov    (%ebx),%ebx
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f0101468:	85 db                	test   %ebx,%ebx
f010146a:	75 08                	jne    f0101474 <page_alloc+0x26>
f010146c:	89 1d 70 04 1e f0    	mov    %ebx,0xf01e0470
f0101472:	eb 4e                	jmp    f01014c2 <page_alloc+0x74>
f0101474:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101479:	75 eb                	jne    f0101466 <page_alloc+0x18>
f010147b:	eb 4c                	jmp    f01014c9 <page_alloc+0x7b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010147d:	89 d8                	mov    %ebx,%eax
f010147f:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0101485:	c1 f8 03             	sar    $0x3,%eax
f0101488:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010148b:	89 c2                	mov    %eax,%edx
f010148d:	c1 ea 0c             	shr    $0xc,%edx
f0101490:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0101496:	72 12                	jb     f01014aa <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101498:	50                   	push   %eax
f0101499:	68 f8 56 10 f0       	push   $0xf01056f8
f010149e:	6a 56                	push   $0x56
f01014a0:	68 65 5e 10 f0       	push   $0xf0105e65
f01014a5:	e8 28 ec ff ff       	call   f01000d2 <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f01014aa:	83 ec 04             	sub    $0x4,%esp
f01014ad:	68 00 10 00 00       	push   $0x1000
f01014b2:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01014b4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01014b9:	50                   	push   %eax
f01014ba:	e8 26 33 00 00       	call   f01047e5 <memset>
f01014bf:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f01014c2:	89 d8                	mov    %ebx,%eax
f01014c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014c7:	c9                   	leave  
f01014c8:	c3                   	ret    
        page_free_list = page_free_list->pp_link;
    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f01014c9:	8b 03                	mov    (%ebx),%eax
f01014cb:	a3 70 04 1e f0       	mov    %eax,0xf01e0470
        if (alloc_flags & ALLOC_ZERO) {
f01014d0:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01014d4:	74 ec                	je     f01014c2 <page_alloc+0x74>
f01014d6:	eb a5                	jmp    f010147d <page_alloc+0x2f>

f01014d8 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01014d8:	55                   	push   %ebp
f01014d9:	89 e5                	mov    %esp,%ebp
f01014db:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f01014de:	85 c0                	test   %eax,%eax
f01014e0:	74 14                	je     f01014f6 <page_free+0x1e>
f01014e2:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01014e7:	75 0d                	jne    f01014f6 <page_free+0x1e>
    pp->pp_link = page_free_list;
f01014e9:	8b 15 70 04 1e f0    	mov    0xf01e0470,%edx
f01014ef:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f01014f1:	a3 70 04 1e f0       	mov    %eax,0xf01e0470
}
f01014f6:	c9                   	leave  
f01014f7:	c3                   	ret    

f01014f8 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01014f8:	55                   	push   %ebp
f01014f9:	89 e5                	mov    %esp,%ebp
f01014fb:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01014fe:	8b 50 04             	mov    0x4(%eax),%edx
f0101501:	4a                   	dec    %edx
f0101502:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101506:	66 85 d2             	test   %dx,%dx
f0101509:	75 09                	jne    f0101514 <page_decref+0x1c>
		page_free(pp);
f010150b:	50                   	push   %eax
f010150c:	e8 c7 ff ff ff       	call   f01014d8 <page_free>
f0101511:	83 c4 04             	add    $0x4,%esp
}
f0101514:	c9                   	leave  
f0101515:	c3                   	ret    

f0101516 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101516:	55                   	push   %ebp
f0101517:	89 e5                	mov    %esp,%ebp
f0101519:	56                   	push   %esi
f010151a:	53                   	push   %ebx
f010151b:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f010151e:	89 f3                	mov    %esi,%ebx
f0101520:	c1 eb 16             	shr    $0x16,%ebx
f0101523:	c1 e3 02             	shl    $0x2,%ebx
f0101526:	03 5d 08             	add    0x8(%ebp),%ebx
f0101529:	8b 03                	mov    (%ebx),%eax
f010152b:	85 c0                	test   %eax,%eax
f010152d:	74 04                	je     f0101533 <pgdir_walk+0x1d>
f010152f:	a8 01                	test   $0x1,%al
f0101531:	75 2c                	jne    f010155f <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f0101533:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101537:	74 61                	je     f010159a <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(1);
f0101539:	83 ec 0c             	sub    $0xc,%esp
f010153c:	6a 01                	push   $0x1
f010153e:	e8 0b ff ff ff       	call   f010144e <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f0101543:	83 c4 10             	add    $0x10,%esp
f0101546:	85 c0                	test   %eax,%eax
f0101548:	74 57                	je     f01015a1 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f010154a:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010154e:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0101554:	c1 f8 03             	sar    $0x3,%eax
f0101557:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f010155a:	83 c8 07             	or     $0x7,%eax
f010155d:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f010155f:	8b 03                	mov    (%ebx),%eax
f0101561:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101566:	89 c2                	mov    %eax,%edx
f0101568:	c1 ea 0c             	shr    $0xc,%edx
f010156b:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0101571:	72 15                	jb     f0101588 <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101573:	50                   	push   %eax
f0101574:	68 f8 56 10 f0       	push   $0xf01056f8
f0101579:	68 88 01 00 00       	push   $0x188
f010157e:	68 59 5e 10 f0       	push   $0xf0105e59
f0101583:	e8 4a eb ff ff       	call   f01000d2 <_panic>
f0101588:	c1 ee 0a             	shr    $0xa,%esi
f010158b:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101591:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101598:	eb 0c                	jmp    f01015a6 <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f010159a:	b8 00 00 00 00       	mov    $0x0,%eax
f010159f:	eb 05                	jmp    f01015a6 <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f01015a1:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f01015a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01015a9:	5b                   	pop    %ebx
f01015aa:	5e                   	pop    %esi
f01015ab:	c9                   	leave  
f01015ac:	c3                   	ret    

f01015ad <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01015ad:	55                   	push   %ebp
f01015ae:	89 e5                	mov    %esp,%ebp
f01015b0:	57                   	push   %edi
f01015b1:	56                   	push   %esi
f01015b2:	53                   	push   %ebx
f01015b3:	83 ec 1c             	sub    $0x1c,%esp
f01015b6:	89 c7                	mov    %eax,%edi
f01015b8:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f01015bb:	01 d1                	add    %edx,%ecx
f01015bd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01015c0:	39 ca                	cmp    %ecx,%edx
f01015c2:	74 32                	je     f01015f6 <boot_map_region+0x49>
f01015c4:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f01015c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015c9:	83 c8 01             	or     $0x1,%eax
f01015cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f01015cf:	83 ec 04             	sub    $0x4,%esp
f01015d2:	6a 01                	push   $0x1
f01015d4:	53                   	push   %ebx
f01015d5:	57                   	push   %edi
f01015d6:	e8 3b ff ff ff       	call   f0101516 <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f01015db:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01015de:	09 f2                	or     %esi,%edx
f01015e0:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f01015e2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01015e8:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01015ee:	83 c4 10             	add    $0x10,%esp
f01015f1:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01015f4:	75 d9                	jne    f01015cf <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f01015f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015f9:	5b                   	pop    %ebx
f01015fa:	5e                   	pop    %esi
f01015fb:	5f                   	pop    %edi
f01015fc:	c9                   	leave  
f01015fd:	c3                   	ret    

f01015fe <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01015fe:	55                   	push   %ebp
f01015ff:	89 e5                	mov    %esp,%ebp
f0101601:	53                   	push   %ebx
f0101602:	83 ec 08             	sub    $0x8,%esp
f0101605:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f0101608:	6a 00                	push   $0x0
f010160a:	ff 75 0c             	pushl  0xc(%ebp)
f010160d:	ff 75 08             	pushl  0x8(%ebp)
f0101610:	e8 01 ff ff ff       	call   f0101516 <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0101615:	83 c4 10             	add    $0x10,%esp
f0101618:	85 c0                	test   %eax,%eax
f010161a:	74 37                	je     f0101653 <page_lookup+0x55>
f010161c:	f6 00 01             	testb  $0x1,(%eax)
f010161f:	74 39                	je     f010165a <page_lookup+0x5c>
    if (pte_store != 0) {
f0101621:	85 db                	test   %ebx,%ebx
f0101623:	74 02                	je     f0101627 <page_lookup+0x29>
        *pte_store = pte;
f0101625:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f0101627:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101629:	c1 e8 0c             	shr    $0xc,%eax
f010162c:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f0101632:	72 14                	jb     f0101648 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101634:	83 ec 04             	sub    $0x4,%esp
f0101637:	68 e0 57 10 f0       	push   $0xf01057e0
f010163c:	6a 4f                	push   $0x4f
f010163e:	68 65 5e 10 f0       	push   $0xf0105e65
f0101643:	e8 8a ea ff ff       	call   f01000d2 <_panic>
	return &pages[PGNUM(pa)];
f0101648:	c1 e0 03             	shl    $0x3,%eax
f010164b:	03 05 4c 11 1e f0    	add    0xf01e114c,%eax
f0101651:	eb 0c                	jmp    f010165f <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0101653:	b8 00 00 00 00       	mov    $0x0,%eax
f0101658:	eb 05                	jmp    f010165f <page_lookup+0x61>
f010165a:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f010165f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101662:	c9                   	leave  
f0101663:	c3                   	ret    

f0101664 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101664:	55                   	push   %ebp
f0101665:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101667:	8b 45 0c             	mov    0xc(%ebp),%eax
f010166a:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010166d:	c9                   	leave  
f010166e:	c3                   	ret    

f010166f <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010166f:	55                   	push   %ebp
f0101670:	89 e5                	mov    %esp,%ebp
f0101672:	56                   	push   %esi
f0101673:	53                   	push   %ebx
f0101674:	83 ec 14             	sub    $0x14,%esp
f0101677:	8b 75 08             	mov    0x8(%ebp),%esi
f010167a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f010167d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101680:	50                   	push   %eax
f0101681:	53                   	push   %ebx
f0101682:	56                   	push   %esi
f0101683:	e8 76 ff ff ff       	call   f01015fe <page_lookup>
    if (pg == NULL) return;
f0101688:	83 c4 10             	add    $0x10,%esp
f010168b:	85 c0                	test   %eax,%eax
f010168d:	74 26                	je     f01016b5 <page_remove+0x46>
    page_decref(pg);
f010168f:	83 ec 0c             	sub    $0xc,%esp
f0101692:	50                   	push   %eax
f0101693:	e8 60 fe ff ff       	call   f01014f8 <page_decref>
    if (pte != NULL) *pte = 0;
f0101698:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010169b:	83 c4 10             	add    $0x10,%esp
f010169e:	85 c0                	test   %eax,%eax
f01016a0:	74 06                	je     f01016a8 <page_remove+0x39>
f01016a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f01016a8:	83 ec 08             	sub    $0x8,%esp
f01016ab:	53                   	push   %ebx
f01016ac:	56                   	push   %esi
f01016ad:	e8 b2 ff ff ff       	call   f0101664 <tlb_invalidate>
f01016b2:	83 c4 10             	add    $0x10,%esp
}
f01016b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01016b8:	5b                   	pop    %ebx
f01016b9:	5e                   	pop    %esi
f01016ba:	c9                   	leave  
f01016bb:	c3                   	ret    

f01016bc <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01016bc:	55                   	push   %ebp
f01016bd:	89 e5                	mov    %esp,%ebp
f01016bf:	57                   	push   %edi
f01016c0:	56                   	push   %esi
f01016c1:	53                   	push   %ebx
f01016c2:	83 ec 10             	sub    $0x10,%esp
f01016c5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016c8:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f01016cb:	6a 01                	push   $0x1
f01016cd:	57                   	push   %edi
f01016ce:	ff 75 08             	pushl  0x8(%ebp)
f01016d1:	e8 40 fe ff ff       	call   f0101516 <pgdir_walk>
f01016d6:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f01016d8:	83 c4 10             	add    $0x10,%esp
f01016db:	85 c0                	test   %eax,%eax
f01016dd:	74 39                	je     f0101718 <page_insert+0x5c>
    ++pp->pp_ref;
f01016df:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f01016e3:	f6 00 01             	testb  $0x1,(%eax)
f01016e6:	74 0f                	je     f01016f7 <page_insert+0x3b>
        page_remove(pgdir, va);
f01016e8:	83 ec 08             	sub    $0x8,%esp
f01016eb:	57                   	push   %edi
f01016ec:	ff 75 08             	pushl  0x8(%ebp)
f01016ef:	e8 7b ff ff ff       	call   f010166f <page_remove>
f01016f4:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f01016f7:	8b 55 14             	mov    0x14(%ebp),%edx
f01016fa:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016fd:	2b 35 4c 11 1e f0    	sub    0xf01e114c,%esi
f0101703:	c1 fe 03             	sar    $0x3,%esi
f0101706:	89 f0                	mov    %esi,%eax
f0101708:	c1 e0 0c             	shl    $0xc,%eax
f010170b:	89 d6                	mov    %edx,%esi
f010170d:	09 c6                	or     %eax,%esi
f010170f:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101711:	b8 00 00 00 00       	mov    $0x0,%eax
f0101716:	eb 05                	jmp    f010171d <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f0101718:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f010171d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101720:	5b                   	pop    %ebx
f0101721:	5e                   	pop    %esi
f0101722:	5f                   	pop    %edi
f0101723:	c9                   	leave  
f0101724:	c3                   	ret    

f0101725 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101725:	55                   	push   %ebp
f0101726:	89 e5                	mov    %esp,%ebp
f0101728:	57                   	push   %edi
f0101729:	56                   	push   %esi
f010172a:	53                   	push   %ebx
f010172b:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010172e:	b8 15 00 00 00       	mov    $0x15,%eax
f0101733:	e8 89 f9 ff ff       	call   f01010c1 <nvram_read>
f0101738:	c1 e0 0a             	shl    $0xa,%eax
f010173b:	89 c2                	mov    %eax,%edx
f010173d:	85 c0                	test   %eax,%eax
f010173f:	79 06                	jns    f0101747 <mem_init+0x22>
f0101741:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101747:	c1 fa 0c             	sar    $0xc,%edx
f010174a:	89 15 78 04 1e f0    	mov    %edx,0xf01e0478
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101750:	b8 17 00 00 00       	mov    $0x17,%eax
f0101755:	e8 67 f9 ff ff       	call   f01010c1 <nvram_read>
f010175a:	89 c2                	mov    %eax,%edx
f010175c:	c1 e2 0a             	shl    $0xa,%edx
f010175f:	89 d0                	mov    %edx,%eax
f0101761:	85 d2                	test   %edx,%edx
f0101763:	79 06                	jns    f010176b <mem_init+0x46>
f0101765:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010176b:	c1 f8 0c             	sar    $0xc,%eax
f010176e:	74 0e                	je     f010177e <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101770:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101776:	89 15 44 11 1e f0    	mov    %edx,0xf01e1144
f010177c:	eb 0c                	jmp    f010178a <mem_init+0x65>
	else
		npages = npages_basemem;
f010177e:	8b 15 78 04 1e f0    	mov    0xf01e0478,%edx
f0101784:	89 15 44 11 1e f0    	mov    %edx,0xf01e1144

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010178a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010178d:	c1 e8 0a             	shr    $0xa,%eax
f0101790:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101791:	a1 78 04 1e f0       	mov    0xf01e0478,%eax
f0101796:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101799:	c1 e8 0a             	shr    $0xa,%eax
f010179c:	50                   	push   %eax
		npages * PGSIZE / 1024,
f010179d:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f01017a2:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01017a5:	c1 e8 0a             	shr    $0xa,%eax
f01017a8:	50                   	push   %eax
f01017a9:	68 00 58 10 f0       	push   $0xf0105800
f01017ae:	e8 fe 1d 00 00       	call   f01035b1 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01017b3:	b8 00 10 00 00       	mov    $0x1000,%eax
f01017b8:	e8 6b f8 ff ff       	call   f0101028 <boot_alloc>
f01017bd:	a3 48 11 1e f0       	mov    %eax,0xf01e1148
	memset(kern_pgdir, 0, PGSIZE);
f01017c2:	83 c4 0c             	add    $0xc,%esp
f01017c5:	68 00 10 00 00       	push   $0x1000
f01017ca:	6a 00                	push   $0x0
f01017cc:	50                   	push   %eax
f01017cd:	e8 13 30 00 00       	call   f01047e5 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01017d2:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01017d7:	83 c4 10             	add    $0x10,%esp
f01017da:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01017df:	77 15                	ja     f01017f6 <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01017e1:	50                   	push   %eax
f01017e2:	68 24 55 10 f0       	push   $0xf0105524
f01017e7:	68 8e 00 00 00       	push   $0x8e
f01017ec:	68 59 5e 10 f0       	push   $0xf0105e59
f01017f1:	e8 dc e8 ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01017f6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01017fc:	83 ca 05             	or     $0x5,%edx
f01017ff:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101805:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f010180a:	c1 e0 03             	shl    $0x3,%eax
f010180d:	e8 16 f8 ff ff       	call   f0101028 <boot_alloc>
f0101812:	a3 4c 11 1e f0       	mov    %eax,0xf01e114c
    

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101817:	b8 00 80 01 00       	mov    $0x18000,%eax
f010181c:	e8 07 f8 ff ff       	call   f0101028 <boot_alloc>
f0101821:	a3 7c 04 1e f0       	mov    %eax,0xf01e047c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101826:	e8 76 fb ff ff       	call   f01013a1 <page_init>

	check_page_free_list(1);
f010182b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101830:	e8 b3 f8 ff ff       	call   f01010e8 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101835:	83 3d 4c 11 1e f0 00 	cmpl   $0x0,0xf01e114c
f010183c:	75 17                	jne    f0101855 <mem_init+0x130>
		panic("'pages' is a null pointer!");
f010183e:	83 ec 04             	sub    $0x4,%esp
f0101841:	68 0f 5f 10 f0       	push   $0xf0105f0f
f0101846:	68 96 02 00 00       	push   $0x296
f010184b:	68 59 5e 10 f0       	push   $0xf0105e59
f0101850:	e8 7d e8 ff ff       	call   f01000d2 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101855:	a1 70 04 1e f0       	mov    0xf01e0470,%eax
f010185a:	85 c0                	test   %eax,%eax
f010185c:	74 0e                	je     f010186c <mem_init+0x147>
f010185e:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101863:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101864:	8b 00                	mov    (%eax),%eax
f0101866:	85 c0                	test   %eax,%eax
f0101868:	75 f9                	jne    f0101863 <mem_init+0x13e>
f010186a:	eb 05                	jmp    f0101871 <mem_init+0x14c>
f010186c:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101871:	83 ec 0c             	sub    $0xc,%esp
f0101874:	6a 00                	push   $0x0
f0101876:	e8 d3 fb ff ff       	call   f010144e <page_alloc>
f010187b:	89 c6                	mov    %eax,%esi
f010187d:	83 c4 10             	add    $0x10,%esp
f0101880:	85 c0                	test   %eax,%eax
f0101882:	75 19                	jne    f010189d <mem_init+0x178>
f0101884:	68 2a 5f 10 f0       	push   $0xf0105f2a
f0101889:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010188e:	68 9e 02 00 00       	push   $0x29e
f0101893:	68 59 5e 10 f0       	push   $0xf0105e59
f0101898:	e8 35 e8 ff ff       	call   f01000d2 <_panic>
	assert((pp1 = page_alloc(0)));
f010189d:	83 ec 0c             	sub    $0xc,%esp
f01018a0:	6a 00                	push   $0x0
f01018a2:	e8 a7 fb ff ff       	call   f010144e <page_alloc>
f01018a7:	89 c7                	mov    %eax,%edi
f01018a9:	83 c4 10             	add    $0x10,%esp
f01018ac:	85 c0                	test   %eax,%eax
f01018ae:	75 19                	jne    f01018c9 <mem_init+0x1a4>
f01018b0:	68 40 5f 10 f0       	push   $0xf0105f40
f01018b5:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01018ba:	68 9f 02 00 00       	push   $0x29f
f01018bf:	68 59 5e 10 f0       	push   $0xf0105e59
f01018c4:	e8 09 e8 ff ff       	call   f01000d2 <_panic>
	assert((pp2 = page_alloc(0)));
f01018c9:	83 ec 0c             	sub    $0xc,%esp
f01018cc:	6a 00                	push   $0x0
f01018ce:	e8 7b fb ff ff       	call   f010144e <page_alloc>
f01018d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018d6:	83 c4 10             	add    $0x10,%esp
f01018d9:	85 c0                	test   %eax,%eax
f01018db:	75 19                	jne    f01018f6 <mem_init+0x1d1>
f01018dd:	68 56 5f 10 f0       	push   $0xf0105f56
f01018e2:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01018e7:	68 a0 02 00 00       	push   $0x2a0
f01018ec:	68 59 5e 10 f0       	push   $0xf0105e59
f01018f1:	e8 dc e7 ff ff       	call   f01000d2 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018f6:	39 fe                	cmp    %edi,%esi
f01018f8:	75 19                	jne    f0101913 <mem_init+0x1ee>
f01018fa:	68 6c 5f 10 f0       	push   $0xf0105f6c
f01018ff:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101904:	68 a3 02 00 00       	push   $0x2a3
f0101909:	68 59 5e 10 f0       	push   $0xf0105e59
f010190e:	e8 bf e7 ff ff       	call   f01000d2 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101913:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101916:	74 05                	je     f010191d <mem_init+0x1f8>
f0101918:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010191b:	75 19                	jne    f0101936 <mem_init+0x211>
f010191d:	68 3c 58 10 f0       	push   $0xf010583c
f0101922:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101927:	68 a4 02 00 00       	push   $0x2a4
f010192c:	68 59 5e 10 f0       	push   $0xf0105e59
f0101931:	e8 9c e7 ff ff       	call   f01000d2 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101936:	8b 15 4c 11 1e f0    	mov    0xf01e114c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010193c:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f0101941:	c1 e0 0c             	shl    $0xc,%eax
f0101944:	89 f1                	mov    %esi,%ecx
f0101946:	29 d1                	sub    %edx,%ecx
f0101948:	c1 f9 03             	sar    $0x3,%ecx
f010194b:	c1 e1 0c             	shl    $0xc,%ecx
f010194e:	39 c1                	cmp    %eax,%ecx
f0101950:	72 19                	jb     f010196b <mem_init+0x246>
f0101952:	68 7e 5f 10 f0       	push   $0xf0105f7e
f0101957:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010195c:	68 a5 02 00 00       	push   $0x2a5
f0101961:	68 59 5e 10 f0       	push   $0xf0105e59
f0101966:	e8 67 e7 ff ff       	call   f01000d2 <_panic>
f010196b:	89 f9                	mov    %edi,%ecx
f010196d:	29 d1                	sub    %edx,%ecx
f010196f:	c1 f9 03             	sar    $0x3,%ecx
f0101972:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101975:	39 c8                	cmp    %ecx,%eax
f0101977:	77 19                	ja     f0101992 <mem_init+0x26d>
f0101979:	68 9b 5f 10 f0       	push   $0xf0105f9b
f010197e:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101983:	68 a6 02 00 00       	push   $0x2a6
f0101988:	68 59 5e 10 f0       	push   $0xf0105e59
f010198d:	e8 40 e7 ff ff       	call   f01000d2 <_panic>
f0101992:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101995:	29 d1                	sub    %edx,%ecx
f0101997:	89 ca                	mov    %ecx,%edx
f0101999:	c1 fa 03             	sar    $0x3,%edx
f010199c:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010199f:	39 d0                	cmp    %edx,%eax
f01019a1:	77 19                	ja     f01019bc <mem_init+0x297>
f01019a3:	68 b8 5f 10 f0       	push   $0xf0105fb8
f01019a8:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01019ad:	68 a7 02 00 00       	push   $0x2a7
f01019b2:	68 59 5e 10 f0       	push   $0xf0105e59
f01019b7:	e8 16 e7 ff ff       	call   f01000d2 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019bc:	a1 70 04 1e f0       	mov    0xf01e0470,%eax
f01019c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01019c4:	c7 05 70 04 1e f0 00 	movl   $0x0,0xf01e0470
f01019cb:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019ce:	83 ec 0c             	sub    $0xc,%esp
f01019d1:	6a 00                	push   $0x0
f01019d3:	e8 76 fa ff ff       	call   f010144e <page_alloc>
f01019d8:	83 c4 10             	add    $0x10,%esp
f01019db:	85 c0                	test   %eax,%eax
f01019dd:	74 19                	je     f01019f8 <mem_init+0x2d3>
f01019df:	68 d5 5f 10 f0       	push   $0xf0105fd5
f01019e4:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01019e9:	68 ae 02 00 00       	push   $0x2ae
f01019ee:	68 59 5e 10 f0       	push   $0xf0105e59
f01019f3:	e8 da e6 ff ff       	call   f01000d2 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01019f8:	83 ec 0c             	sub    $0xc,%esp
f01019fb:	56                   	push   %esi
f01019fc:	e8 d7 fa ff ff       	call   f01014d8 <page_free>
	page_free(pp1);
f0101a01:	89 3c 24             	mov    %edi,(%esp)
f0101a04:	e8 cf fa ff ff       	call   f01014d8 <page_free>
	page_free(pp2);
f0101a09:	83 c4 04             	add    $0x4,%esp
f0101a0c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a0f:	e8 c4 fa ff ff       	call   f01014d8 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a1b:	e8 2e fa ff ff       	call   f010144e <page_alloc>
f0101a20:	89 c6                	mov    %eax,%esi
f0101a22:	83 c4 10             	add    $0x10,%esp
f0101a25:	85 c0                	test   %eax,%eax
f0101a27:	75 19                	jne    f0101a42 <mem_init+0x31d>
f0101a29:	68 2a 5f 10 f0       	push   $0xf0105f2a
f0101a2e:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101a33:	68 b5 02 00 00       	push   $0x2b5
f0101a38:	68 59 5e 10 f0       	push   $0xf0105e59
f0101a3d:	e8 90 e6 ff ff       	call   f01000d2 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a42:	83 ec 0c             	sub    $0xc,%esp
f0101a45:	6a 00                	push   $0x0
f0101a47:	e8 02 fa ff ff       	call   f010144e <page_alloc>
f0101a4c:	89 c7                	mov    %eax,%edi
f0101a4e:	83 c4 10             	add    $0x10,%esp
f0101a51:	85 c0                	test   %eax,%eax
f0101a53:	75 19                	jne    f0101a6e <mem_init+0x349>
f0101a55:	68 40 5f 10 f0       	push   $0xf0105f40
f0101a5a:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101a5f:	68 b6 02 00 00       	push   $0x2b6
f0101a64:	68 59 5e 10 f0       	push   $0xf0105e59
f0101a69:	e8 64 e6 ff ff       	call   f01000d2 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a6e:	83 ec 0c             	sub    $0xc,%esp
f0101a71:	6a 00                	push   $0x0
f0101a73:	e8 d6 f9 ff ff       	call   f010144e <page_alloc>
f0101a78:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a7b:	83 c4 10             	add    $0x10,%esp
f0101a7e:	85 c0                	test   %eax,%eax
f0101a80:	75 19                	jne    f0101a9b <mem_init+0x376>
f0101a82:	68 56 5f 10 f0       	push   $0xf0105f56
f0101a87:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101a8c:	68 b7 02 00 00       	push   $0x2b7
f0101a91:	68 59 5e 10 f0       	push   $0xf0105e59
f0101a96:	e8 37 e6 ff ff       	call   f01000d2 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a9b:	39 fe                	cmp    %edi,%esi
f0101a9d:	75 19                	jne    f0101ab8 <mem_init+0x393>
f0101a9f:	68 6c 5f 10 f0       	push   $0xf0105f6c
f0101aa4:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101aa9:	68 b9 02 00 00       	push   $0x2b9
f0101aae:	68 59 5e 10 f0       	push   $0xf0105e59
f0101ab3:	e8 1a e6 ff ff       	call   f01000d2 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ab8:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101abb:	74 05                	je     f0101ac2 <mem_init+0x39d>
f0101abd:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101ac0:	75 19                	jne    f0101adb <mem_init+0x3b6>
f0101ac2:	68 3c 58 10 f0       	push   $0xf010583c
f0101ac7:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101acc:	68 ba 02 00 00       	push   $0x2ba
f0101ad1:	68 59 5e 10 f0       	push   $0xf0105e59
f0101ad6:	e8 f7 e5 ff ff       	call   f01000d2 <_panic>
	assert(!page_alloc(0));
f0101adb:	83 ec 0c             	sub    $0xc,%esp
f0101ade:	6a 00                	push   $0x0
f0101ae0:	e8 69 f9 ff ff       	call   f010144e <page_alloc>
f0101ae5:	83 c4 10             	add    $0x10,%esp
f0101ae8:	85 c0                	test   %eax,%eax
f0101aea:	74 19                	je     f0101b05 <mem_init+0x3e0>
f0101aec:	68 d5 5f 10 f0       	push   $0xf0105fd5
f0101af1:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101af6:	68 bb 02 00 00       	push   $0x2bb
f0101afb:	68 59 5e 10 f0       	push   $0xf0105e59
f0101b00:	e8 cd e5 ff ff       	call   f01000d2 <_panic>
f0101b05:	89 f0                	mov    %esi,%eax
f0101b07:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0101b0d:	c1 f8 03             	sar    $0x3,%eax
f0101b10:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b13:	89 c2                	mov    %eax,%edx
f0101b15:	c1 ea 0c             	shr    $0xc,%edx
f0101b18:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0101b1e:	72 12                	jb     f0101b32 <mem_init+0x40d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b20:	50                   	push   %eax
f0101b21:	68 f8 56 10 f0       	push   $0xf01056f8
f0101b26:	6a 56                	push   $0x56
f0101b28:	68 65 5e 10 f0       	push   $0xf0105e65
f0101b2d:	e8 a0 e5 ff ff       	call   f01000d2 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101b32:	83 ec 04             	sub    $0x4,%esp
f0101b35:	68 00 10 00 00       	push   $0x1000
f0101b3a:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101b3c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b41:	50                   	push   %eax
f0101b42:	e8 9e 2c 00 00       	call   f01047e5 <memset>
	page_free(pp0);
f0101b47:	89 34 24             	mov    %esi,(%esp)
f0101b4a:	e8 89 f9 ff ff       	call   f01014d8 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b4f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b56:	e8 f3 f8 ff ff       	call   f010144e <page_alloc>
f0101b5b:	83 c4 10             	add    $0x10,%esp
f0101b5e:	85 c0                	test   %eax,%eax
f0101b60:	75 19                	jne    f0101b7b <mem_init+0x456>
f0101b62:	68 e4 5f 10 f0       	push   $0xf0105fe4
f0101b67:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101b6c:	68 c0 02 00 00       	push   $0x2c0
f0101b71:	68 59 5e 10 f0       	push   $0xf0105e59
f0101b76:	e8 57 e5 ff ff       	call   f01000d2 <_panic>
	assert(pp && pp0 == pp);
f0101b7b:	39 c6                	cmp    %eax,%esi
f0101b7d:	74 19                	je     f0101b98 <mem_init+0x473>
f0101b7f:	68 02 60 10 f0       	push   $0xf0106002
f0101b84:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101b89:	68 c1 02 00 00       	push   $0x2c1
f0101b8e:	68 59 5e 10 f0       	push   $0xf0105e59
f0101b93:	e8 3a e5 ff ff       	call   f01000d2 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b98:	89 f2                	mov    %esi,%edx
f0101b9a:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101ba0:	c1 fa 03             	sar    $0x3,%edx
f0101ba3:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ba6:	89 d0                	mov    %edx,%eax
f0101ba8:	c1 e8 0c             	shr    $0xc,%eax
f0101bab:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f0101bb1:	72 12                	jb     f0101bc5 <mem_init+0x4a0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101bb3:	52                   	push   %edx
f0101bb4:	68 f8 56 10 f0       	push   $0xf01056f8
f0101bb9:	6a 56                	push   $0x56
f0101bbb:	68 65 5e 10 f0       	push   $0xf0105e65
f0101bc0:	e8 0d e5 ff ff       	call   f01000d2 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101bc5:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101bcc:	75 11                	jne    f0101bdf <mem_init+0x4ba>
f0101bce:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101bd4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101bda:	80 38 00             	cmpb   $0x0,(%eax)
f0101bdd:	74 19                	je     f0101bf8 <mem_init+0x4d3>
f0101bdf:	68 12 60 10 f0       	push   $0xf0106012
f0101be4:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101be9:	68 c4 02 00 00       	push   $0x2c4
f0101bee:	68 59 5e 10 f0       	push   $0xf0105e59
f0101bf3:	e8 da e4 ff ff       	call   f01000d2 <_panic>
f0101bf8:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101bf9:	39 d0                	cmp    %edx,%eax
f0101bfb:	75 dd                	jne    f0101bda <mem_init+0x4b5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101bfd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101c00:	89 0d 70 04 1e f0    	mov    %ecx,0xf01e0470

	// free the pages we took
	page_free(pp0);
f0101c06:	83 ec 0c             	sub    $0xc,%esp
f0101c09:	56                   	push   %esi
f0101c0a:	e8 c9 f8 ff ff       	call   f01014d8 <page_free>
	page_free(pp1);
f0101c0f:	89 3c 24             	mov    %edi,(%esp)
f0101c12:	e8 c1 f8 ff ff       	call   f01014d8 <page_free>
	page_free(pp2);
f0101c17:	83 c4 04             	add    $0x4,%esp
f0101c1a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c1d:	e8 b6 f8 ff ff       	call   f01014d8 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c22:	a1 70 04 1e f0       	mov    0xf01e0470,%eax
f0101c27:	83 c4 10             	add    $0x10,%esp
f0101c2a:	85 c0                	test   %eax,%eax
f0101c2c:	74 07                	je     f0101c35 <mem_init+0x510>
		--nfree;
f0101c2e:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c2f:	8b 00                	mov    (%eax),%eax
f0101c31:	85 c0                	test   %eax,%eax
f0101c33:	75 f9                	jne    f0101c2e <mem_init+0x509>
		--nfree;
	assert(nfree == 0);
f0101c35:	85 db                	test   %ebx,%ebx
f0101c37:	74 19                	je     f0101c52 <mem_init+0x52d>
f0101c39:	68 1c 60 10 f0       	push   $0xf010601c
f0101c3e:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101c43:	68 d1 02 00 00       	push   $0x2d1
f0101c48:	68 59 5e 10 f0       	push   $0xf0105e59
f0101c4d:	e8 80 e4 ff ff       	call   f01000d2 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101c52:	83 ec 0c             	sub    $0xc,%esp
f0101c55:	68 5c 58 10 f0       	push   $0xf010585c
f0101c5a:	e8 52 19 00 00       	call   f01035b1 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c66:	e8 e3 f7 ff ff       	call   f010144e <page_alloc>
f0101c6b:	89 c7                	mov    %eax,%edi
f0101c6d:	83 c4 10             	add    $0x10,%esp
f0101c70:	85 c0                	test   %eax,%eax
f0101c72:	75 19                	jne    f0101c8d <mem_init+0x568>
f0101c74:	68 2a 5f 10 f0       	push   $0xf0105f2a
f0101c79:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101c7e:	68 2f 03 00 00       	push   $0x32f
f0101c83:	68 59 5e 10 f0       	push   $0xf0105e59
f0101c88:	e8 45 e4 ff ff       	call   f01000d2 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c8d:	83 ec 0c             	sub    $0xc,%esp
f0101c90:	6a 00                	push   $0x0
f0101c92:	e8 b7 f7 ff ff       	call   f010144e <page_alloc>
f0101c97:	89 c6                	mov    %eax,%esi
f0101c99:	83 c4 10             	add    $0x10,%esp
f0101c9c:	85 c0                	test   %eax,%eax
f0101c9e:	75 19                	jne    f0101cb9 <mem_init+0x594>
f0101ca0:	68 40 5f 10 f0       	push   $0xf0105f40
f0101ca5:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101caa:	68 30 03 00 00       	push   $0x330
f0101caf:	68 59 5e 10 f0       	push   $0xf0105e59
f0101cb4:	e8 19 e4 ff ff       	call   f01000d2 <_panic>
	assert((pp2 = page_alloc(0)));
f0101cb9:	83 ec 0c             	sub    $0xc,%esp
f0101cbc:	6a 00                	push   $0x0
f0101cbe:	e8 8b f7 ff ff       	call   f010144e <page_alloc>
f0101cc3:	89 c3                	mov    %eax,%ebx
f0101cc5:	83 c4 10             	add    $0x10,%esp
f0101cc8:	85 c0                	test   %eax,%eax
f0101cca:	75 19                	jne    f0101ce5 <mem_init+0x5c0>
f0101ccc:	68 56 5f 10 f0       	push   $0xf0105f56
f0101cd1:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101cd6:	68 31 03 00 00       	push   $0x331
f0101cdb:	68 59 5e 10 f0       	push   $0xf0105e59
f0101ce0:	e8 ed e3 ff ff       	call   f01000d2 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ce5:	39 f7                	cmp    %esi,%edi
f0101ce7:	75 19                	jne    f0101d02 <mem_init+0x5dd>
f0101ce9:	68 6c 5f 10 f0       	push   $0xf0105f6c
f0101cee:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101cf3:	68 34 03 00 00       	push   $0x334
f0101cf8:	68 59 5e 10 f0       	push   $0xf0105e59
f0101cfd:	e8 d0 e3 ff ff       	call   f01000d2 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d02:	39 c6                	cmp    %eax,%esi
f0101d04:	74 04                	je     f0101d0a <mem_init+0x5e5>
f0101d06:	39 c7                	cmp    %eax,%edi
f0101d08:	75 19                	jne    f0101d23 <mem_init+0x5fe>
f0101d0a:	68 3c 58 10 f0       	push   $0xf010583c
f0101d0f:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101d14:	68 35 03 00 00       	push   $0x335
f0101d19:	68 59 5e 10 f0       	push   $0xf0105e59
f0101d1e:	e8 af e3 ff ff       	call   f01000d2 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101d23:	a1 70 04 1e f0       	mov    0xf01e0470,%eax
f0101d28:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	page_free_list = 0;
f0101d2b:	c7 05 70 04 1e f0 00 	movl   $0x0,0xf01e0470
f0101d32:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101d35:	83 ec 0c             	sub    $0xc,%esp
f0101d38:	6a 00                	push   $0x0
f0101d3a:	e8 0f f7 ff ff       	call   f010144e <page_alloc>
f0101d3f:	83 c4 10             	add    $0x10,%esp
f0101d42:	85 c0                	test   %eax,%eax
f0101d44:	74 19                	je     f0101d5f <mem_init+0x63a>
f0101d46:	68 d5 5f 10 f0       	push   $0xf0105fd5
f0101d4b:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101d50:	68 3c 03 00 00       	push   $0x33c
f0101d55:	68 59 5e 10 f0       	push   $0xf0105e59
f0101d5a:	e8 73 e3 ff ff       	call   f01000d2 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101d5f:	83 ec 04             	sub    $0x4,%esp
f0101d62:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d65:	50                   	push   %eax
f0101d66:	6a 00                	push   $0x0
f0101d68:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101d6e:	e8 8b f8 ff ff       	call   f01015fe <page_lookup>
f0101d73:	83 c4 10             	add    $0x10,%esp
f0101d76:	85 c0                	test   %eax,%eax
f0101d78:	74 19                	je     f0101d93 <mem_init+0x66e>
f0101d7a:	68 7c 58 10 f0       	push   $0xf010587c
f0101d7f:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101d84:	68 3f 03 00 00       	push   $0x33f
f0101d89:	68 59 5e 10 f0       	push   $0xf0105e59
f0101d8e:	e8 3f e3 ff ff       	call   f01000d2 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d93:	6a 02                	push   $0x2
f0101d95:	6a 00                	push   $0x0
f0101d97:	56                   	push   %esi
f0101d98:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101d9e:	e8 19 f9 ff ff       	call   f01016bc <page_insert>
f0101da3:	83 c4 10             	add    $0x10,%esp
f0101da6:	85 c0                	test   %eax,%eax
f0101da8:	78 19                	js     f0101dc3 <mem_init+0x69e>
f0101daa:	68 b4 58 10 f0       	push   $0xf01058b4
f0101daf:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101db4:	68 42 03 00 00       	push   $0x342
f0101db9:	68 59 5e 10 f0       	push   $0xf0105e59
f0101dbe:	e8 0f e3 ff ff       	call   f01000d2 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101dc3:	83 ec 0c             	sub    $0xc,%esp
f0101dc6:	57                   	push   %edi
f0101dc7:	e8 0c f7 ff ff       	call   f01014d8 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101dcc:	6a 02                	push   $0x2
f0101dce:	6a 00                	push   $0x0
f0101dd0:	56                   	push   %esi
f0101dd1:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101dd7:	e8 e0 f8 ff ff       	call   f01016bc <page_insert>
f0101ddc:	83 c4 20             	add    $0x20,%esp
f0101ddf:	85 c0                	test   %eax,%eax
f0101de1:	74 19                	je     f0101dfc <mem_init+0x6d7>
f0101de3:	68 e4 58 10 f0       	push   $0xf01058e4
f0101de8:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101ded:	68 46 03 00 00       	push   $0x346
f0101df2:	68 59 5e 10 f0       	push   $0xf0105e59
f0101df7:	e8 d6 e2 ff ff       	call   f01000d2 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101dfc:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0101e01:	8b 08                	mov    (%eax),%ecx
f0101e03:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e09:	89 fa                	mov    %edi,%edx
f0101e0b:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101e11:	c1 fa 03             	sar    $0x3,%edx
f0101e14:	c1 e2 0c             	shl    $0xc,%edx
f0101e17:	39 d1                	cmp    %edx,%ecx
f0101e19:	74 19                	je     f0101e34 <mem_init+0x70f>
f0101e1b:	68 14 59 10 f0       	push   $0xf0105914
f0101e20:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101e25:	68 47 03 00 00       	push   $0x347
f0101e2a:	68 59 5e 10 f0       	push   $0xf0105e59
f0101e2f:	e8 9e e2 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e34:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e39:	e8 21 f2 ff ff       	call   f010105f <check_va2pa>
f0101e3e:	89 f2                	mov    %esi,%edx
f0101e40:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101e46:	c1 fa 03             	sar    $0x3,%edx
f0101e49:	c1 e2 0c             	shl    $0xc,%edx
f0101e4c:	39 d0                	cmp    %edx,%eax
f0101e4e:	74 19                	je     f0101e69 <mem_init+0x744>
f0101e50:	68 3c 59 10 f0       	push   $0xf010593c
f0101e55:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101e5a:	68 48 03 00 00       	push   $0x348
f0101e5f:	68 59 5e 10 f0       	push   $0xf0105e59
f0101e64:	e8 69 e2 ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 1);
f0101e69:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e6e:	74 19                	je     f0101e89 <mem_init+0x764>
f0101e70:	68 27 60 10 f0       	push   $0xf0106027
f0101e75:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101e7a:	68 49 03 00 00       	push   $0x349
f0101e7f:	68 59 5e 10 f0       	push   $0xf0105e59
f0101e84:	e8 49 e2 ff ff       	call   f01000d2 <_panic>
	assert(pp0->pp_ref == 1);
f0101e89:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e8e:	74 19                	je     f0101ea9 <mem_init+0x784>
f0101e90:	68 38 60 10 f0       	push   $0xf0106038
f0101e95:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101e9a:	68 4a 03 00 00       	push   $0x34a
f0101e9f:	68 59 5e 10 f0       	push   $0xf0105e59
f0101ea4:	e8 29 e2 ff ff       	call   f01000d2 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ea9:	6a 02                	push   $0x2
f0101eab:	68 00 10 00 00       	push   $0x1000
f0101eb0:	53                   	push   %ebx
f0101eb1:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101eb7:	e8 00 f8 ff ff       	call   f01016bc <page_insert>
f0101ebc:	83 c4 10             	add    $0x10,%esp
f0101ebf:	85 c0                	test   %eax,%eax
f0101ec1:	74 19                	je     f0101edc <mem_init+0x7b7>
f0101ec3:	68 6c 59 10 f0       	push   $0xf010596c
f0101ec8:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101ecd:	68 4d 03 00 00       	push   $0x34d
f0101ed2:	68 59 5e 10 f0       	push   $0xf0105e59
f0101ed7:	e8 f6 e1 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101edc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ee1:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0101ee6:	e8 74 f1 ff ff       	call   f010105f <check_va2pa>
f0101eeb:	89 da                	mov    %ebx,%edx
f0101eed:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101ef3:	c1 fa 03             	sar    $0x3,%edx
f0101ef6:	c1 e2 0c             	shl    $0xc,%edx
f0101ef9:	39 d0                	cmp    %edx,%eax
f0101efb:	74 19                	je     f0101f16 <mem_init+0x7f1>
f0101efd:	68 a8 59 10 f0       	push   $0xf01059a8
f0101f02:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101f07:	68 4e 03 00 00       	push   $0x34e
f0101f0c:	68 59 5e 10 f0       	push   $0xf0105e59
f0101f11:	e8 bc e1 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f0101f16:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f1b:	74 19                	je     f0101f36 <mem_init+0x811>
f0101f1d:	68 49 60 10 f0       	push   $0xf0106049
f0101f22:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101f27:	68 4f 03 00 00       	push   $0x34f
f0101f2c:	68 59 5e 10 f0       	push   $0xf0105e59
f0101f31:	e8 9c e1 ff ff       	call   f01000d2 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f36:	83 ec 0c             	sub    $0xc,%esp
f0101f39:	6a 00                	push   $0x0
f0101f3b:	e8 0e f5 ff ff       	call   f010144e <page_alloc>
f0101f40:	83 c4 10             	add    $0x10,%esp
f0101f43:	85 c0                	test   %eax,%eax
f0101f45:	74 19                	je     f0101f60 <mem_init+0x83b>
f0101f47:	68 d5 5f 10 f0       	push   $0xf0105fd5
f0101f4c:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101f51:	68 52 03 00 00       	push   $0x352
f0101f56:	68 59 5e 10 f0       	push   $0xf0105e59
f0101f5b:	e8 72 e1 ff ff       	call   f01000d2 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f60:	6a 02                	push   $0x2
f0101f62:	68 00 10 00 00       	push   $0x1000
f0101f67:	53                   	push   %ebx
f0101f68:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101f6e:	e8 49 f7 ff ff       	call   f01016bc <page_insert>
f0101f73:	83 c4 10             	add    $0x10,%esp
f0101f76:	85 c0                	test   %eax,%eax
f0101f78:	74 19                	je     f0101f93 <mem_init+0x86e>
f0101f7a:	68 6c 59 10 f0       	push   $0xf010596c
f0101f7f:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101f84:	68 55 03 00 00       	push   $0x355
f0101f89:	68 59 5e 10 f0       	push   $0xf0105e59
f0101f8e:	e8 3f e1 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f93:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f98:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0101f9d:	e8 bd f0 ff ff       	call   f010105f <check_va2pa>
f0101fa2:	89 da                	mov    %ebx,%edx
f0101fa4:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101faa:	c1 fa 03             	sar    $0x3,%edx
f0101fad:	c1 e2 0c             	shl    $0xc,%edx
f0101fb0:	39 d0                	cmp    %edx,%eax
f0101fb2:	74 19                	je     f0101fcd <mem_init+0x8a8>
f0101fb4:	68 a8 59 10 f0       	push   $0xf01059a8
f0101fb9:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101fbe:	68 56 03 00 00       	push   $0x356
f0101fc3:	68 59 5e 10 f0       	push   $0xf0105e59
f0101fc8:	e8 05 e1 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f0101fcd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fd2:	74 19                	je     f0101fed <mem_init+0x8c8>
f0101fd4:	68 49 60 10 f0       	push   $0xf0106049
f0101fd9:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0101fde:	68 57 03 00 00       	push   $0x357
f0101fe3:	68 59 5e 10 f0       	push   $0xf0105e59
f0101fe8:	e8 e5 e0 ff ff       	call   f01000d2 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101fed:	83 ec 0c             	sub    $0xc,%esp
f0101ff0:	6a 00                	push   $0x0
f0101ff2:	e8 57 f4 ff ff       	call   f010144e <page_alloc>
f0101ff7:	83 c4 10             	add    $0x10,%esp
f0101ffa:	85 c0                	test   %eax,%eax
f0101ffc:	74 19                	je     f0102017 <mem_init+0x8f2>
f0101ffe:	68 d5 5f 10 f0       	push   $0xf0105fd5
f0102003:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102008:	68 5b 03 00 00       	push   $0x35b
f010200d:	68 59 5e 10 f0       	push   $0xf0105e59
f0102012:	e8 bb e0 ff ff       	call   f01000d2 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102017:	8b 15 48 11 1e f0    	mov    0xf01e1148,%edx
f010201d:	8b 02                	mov    (%edx),%eax
f010201f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102024:	89 c1                	mov    %eax,%ecx
f0102026:	c1 e9 0c             	shr    $0xc,%ecx
f0102029:	3b 0d 44 11 1e f0    	cmp    0xf01e1144,%ecx
f010202f:	72 15                	jb     f0102046 <mem_init+0x921>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102031:	50                   	push   %eax
f0102032:	68 f8 56 10 f0       	push   $0xf01056f8
f0102037:	68 5e 03 00 00       	push   $0x35e
f010203c:	68 59 5e 10 f0       	push   $0xf0105e59
f0102041:	e8 8c e0 ff ff       	call   f01000d2 <_panic>
	return (void *)(pa + KERNBASE);
f0102046:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010204b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010204e:	83 ec 04             	sub    $0x4,%esp
f0102051:	6a 00                	push   $0x0
f0102053:	68 00 10 00 00       	push   $0x1000
f0102058:	52                   	push   %edx
f0102059:	e8 b8 f4 ff ff       	call   f0101516 <pgdir_walk>
f010205e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102061:	83 c2 04             	add    $0x4,%edx
f0102064:	83 c4 10             	add    $0x10,%esp
f0102067:	39 d0                	cmp    %edx,%eax
f0102069:	74 19                	je     f0102084 <mem_init+0x95f>
f010206b:	68 d8 59 10 f0       	push   $0xf01059d8
f0102070:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102075:	68 5f 03 00 00       	push   $0x35f
f010207a:	68 59 5e 10 f0       	push   $0xf0105e59
f010207f:	e8 4e e0 ff ff       	call   f01000d2 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102084:	6a 06                	push   $0x6
f0102086:	68 00 10 00 00       	push   $0x1000
f010208b:	53                   	push   %ebx
f010208c:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102092:	e8 25 f6 ff ff       	call   f01016bc <page_insert>
f0102097:	83 c4 10             	add    $0x10,%esp
f010209a:	85 c0                	test   %eax,%eax
f010209c:	74 19                	je     f01020b7 <mem_init+0x992>
f010209e:	68 18 5a 10 f0       	push   $0xf0105a18
f01020a3:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01020a8:	68 62 03 00 00       	push   $0x362
f01020ad:	68 59 5e 10 f0       	push   $0xf0105e59
f01020b2:	e8 1b e0 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020b7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020bc:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01020c1:	e8 99 ef ff ff       	call   f010105f <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020c6:	89 da                	mov    %ebx,%edx
f01020c8:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f01020ce:	c1 fa 03             	sar    $0x3,%edx
f01020d1:	c1 e2 0c             	shl    $0xc,%edx
f01020d4:	39 d0                	cmp    %edx,%eax
f01020d6:	74 19                	je     f01020f1 <mem_init+0x9cc>
f01020d8:	68 a8 59 10 f0       	push   $0xf01059a8
f01020dd:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01020e2:	68 63 03 00 00       	push   $0x363
f01020e7:	68 59 5e 10 f0       	push   $0xf0105e59
f01020ec:	e8 e1 df ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f01020f1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020f6:	74 19                	je     f0102111 <mem_init+0x9ec>
f01020f8:	68 49 60 10 f0       	push   $0xf0106049
f01020fd:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102102:	68 64 03 00 00       	push   $0x364
f0102107:	68 59 5e 10 f0       	push   $0xf0105e59
f010210c:	e8 c1 df ff ff       	call   f01000d2 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102111:	83 ec 04             	sub    $0x4,%esp
f0102114:	6a 00                	push   $0x0
f0102116:	68 00 10 00 00       	push   $0x1000
f010211b:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102121:	e8 f0 f3 ff ff       	call   f0101516 <pgdir_walk>
f0102126:	83 c4 10             	add    $0x10,%esp
f0102129:	f6 00 04             	testb  $0x4,(%eax)
f010212c:	75 19                	jne    f0102147 <mem_init+0xa22>
f010212e:	68 58 5a 10 f0       	push   $0xf0105a58
f0102133:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102138:	68 65 03 00 00       	push   $0x365
f010213d:	68 59 5e 10 f0       	push   $0xf0105e59
f0102142:	e8 8b df ff ff       	call   f01000d2 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102147:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f010214c:	f6 00 04             	testb  $0x4,(%eax)
f010214f:	75 19                	jne    f010216a <mem_init+0xa45>
f0102151:	68 5a 60 10 f0       	push   $0xf010605a
f0102156:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010215b:	68 66 03 00 00       	push   $0x366
f0102160:	68 59 5e 10 f0       	push   $0xf0105e59
f0102165:	e8 68 df ff ff       	call   f01000d2 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010216a:	6a 02                	push   $0x2
f010216c:	68 00 10 00 00       	push   $0x1000
f0102171:	53                   	push   %ebx
f0102172:	50                   	push   %eax
f0102173:	e8 44 f5 ff ff       	call   f01016bc <page_insert>
f0102178:	83 c4 10             	add    $0x10,%esp
f010217b:	85 c0                	test   %eax,%eax
f010217d:	74 19                	je     f0102198 <mem_init+0xa73>
f010217f:	68 6c 59 10 f0       	push   $0xf010596c
f0102184:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102189:	68 69 03 00 00       	push   $0x369
f010218e:	68 59 5e 10 f0       	push   $0xf0105e59
f0102193:	e8 3a df ff ff       	call   f01000d2 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102198:	83 ec 04             	sub    $0x4,%esp
f010219b:	6a 00                	push   $0x0
f010219d:	68 00 10 00 00       	push   $0x1000
f01021a2:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f01021a8:	e8 69 f3 ff ff       	call   f0101516 <pgdir_walk>
f01021ad:	83 c4 10             	add    $0x10,%esp
f01021b0:	f6 00 02             	testb  $0x2,(%eax)
f01021b3:	75 19                	jne    f01021ce <mem_init+0xaa9>
f01021b5:	68 8c 5a 10 f0       	push   $0xf0105a8c
f01021ba:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01021bf:	68 6a 03 00 00       	push   $0x36a
f01021c4:	68 59 5e 10 f0       	push   $0xf0105e59
f01021c9:	e8 04 df ff ff       	call   f01000d2 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021ce:	83 ec 04             	sub    $0x4,%esp
f01021d1:	6a 00                	push   $0x0
f01021d3:	68 00 10 00 00       	push   $0x1000
f01021d8:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f01021de:	e8 33 f3 ff ff       	call   f0101516 <pgdir_walk>
f01021e3:	83 c4 10             	add    $0x10,%esp
f01021e6:	f6 00 04             	testb  $0x4,(%eax)
f01021e9:	74 19                	je     f0102204 <mem_init+0xadf>
f01021eb:	68 c0 5a 10 f0       	push   $0xf0105ac0
f01021f0:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01021f5:	68 6b 03 00 00       	push   $0x36b
f01021fa:	68 59 5e 10 f0       	push   $0xf0105e59
f01021ff:	e8 ce de ff ff       	call   f01000d2 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102204:	6a 02                	push   $0x2
f0102206:	68 00 00 40 00       	push   $0x400000
f010220b:	57                   	push   %edi
f010220c:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102212:	e8 a5 f4 ff ff       	call   f01016bc <page_insert>
f0102217:	83 c4 10             	add    $0x10,%esp
f010221a:	85 c0                	test   %eax,%eax
f010221c:	78 19                	js     f0102237 <mem_init+0xb12>
f010221e:	68 f8 5a 10 f0       	push   $0xf0105af8
f0102223:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102228:	68 6e 03 00 00       	push   $0x36e
f010222d:	68 59 5e 10 f0       	push   $0xf0105e59
f0102232:	e8 9b de ff ff       	call   f01000d2 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102237:	6a 02                	push   $0x2
f0102239:	68 00 10 00 00       	push   $0x1000
f010223e:	56                   	push   %esi
f010223f:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102245:	e8 72 f4 ff ff       	call   f01016bc <page_insert>
f010224a:	83 c4 10             	add    $0x10,%esp
f010224d:	85 c0                	test   %eax,%eax
f010224f:	74 19                	je     f010226a <mem_init+0xb45>
f0102251:	68 30 5b 10 f0       	push   $0xf0105b30
f0102256:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010225b:	68 71 03 00 00       	push   $0x371
f0102260:	68 59 5e 10 f0       	push   $0xf0105e59
f0102265:	e8 68 de ff ff       	call   f01000d2 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010226a:	83 ec 04             	sub    $0x4,%esp
f010226d:	6a 00                	push   $0x0
f010226f:	68 00 10 00 00       	push   $0x1000
f0102274:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f010227a:	e8 97 f2 ff ff       	call   f0101516 <pgdir_walk>
f010227f:	83 c4 10             	add    $0x10,%esp
f0102282:	f6 00 04             	testb  $0x4,(%eax)
f0102285:	74 19                	je     f01022a0 <mem_init+0xb7b>
f0102287:	68 c0 5a 10 f0       	push   $0xf0105ac0
f010228c:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102291:	68 72 03 00 00       	push   $0x372
f0102296:	68 59 5e 10 f0       	push   $0xf0105e59
f010229b:	e8 32 de ff ff       	call   f01000d2 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01022a0:	ba 00 00 00 00       	mov    $0x0,%edx
f01022a5:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01022aa:	e8 b0 ed ff ff       	call   f010105f <check_va2pa>
f01022af:	89 f2                	mov    %esi,%edx
f01022b1:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f01022b7:	c1 fa 03             	sar    $0x3,%edx
f01022ba:	c1 e2 0c             	shl    $0xc,%edx
f01022bd:	39 d0                	cmp    %edx,%eax
f01022bf:	74 19                	je     f01022da <mem_init+0xbb5>
f01022c1:	68 6c 5b 10 f0       	push   $0xf0105b6c
f01022c6:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01022cb:	68 75 03 00 00       	push   $0x375
f01022d0:	68 59 5e 10 f0       	push   $0xf0105e59
f01022d5:	e8 f8 dd ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022da:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022df:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01022e4:	e8 76 ed ff ff       	call   f010105f <check_va2pa>
f01022e9:	89 f2                	mov    %esi,%edx
f01022eb:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f01022f1:	c1 fa 03             	sar    $0x3,%edx
f01022f4:	c1 e2 0c             	shl    $0xc,%edx
f01022f7:	39 d0                	cmp    %edx,%eax
f01022f9:	74 19                	je     f0102314 <mem_init+0xbef>
f01022fb:	68 98 5b 10 f0       	push   $0xf0105b98
f0102300:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102305:	68 76 03 00 00       	push   $0x376
f010230a:	68 59 5e 10 f0       	push   $0xf0105e59
f010230f:	e8 be dd ff ff       	call   f01000d2 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102314:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102319:	74 19                	je     f0102334 <mem_init+0xc0f>
f010231b:	68 70 60 10 f0       	push   $0xf0106070
f0102320:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102325:	68 78 03 00 00       	push   $0x378
f010232a:	68 59 5e 10 f0       	push   $0xf0105e59
f010232f:	e8 9e dd ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 0);
f0102334:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102339:	74 19                	je     f0102354 <mem_init+0xc2f>
f010233b:	68 81 60 10 f0       	push   $0xf0106081
f0102340:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102345:	68 79 03 00 00       	push   $0x379
f010234a:	68 59 5e 10 f0       	push   $0xf0105e59
f010234f:	e8 7e dd ff ff       	call   f01000d2 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102354:	83 ec 0c             	sub    $0xc,%esp
f0102357:	6a 00                	push   $0x0
f0102359:	e8 f0 f0 ff ff       	call   f010144e <page_alloc>
f010235e:	83 c4 10             	add    $0x10,%esp
f0102361:	85 c0                	test   %eax,%eax
f0102363:	74 04                	je     f0102369 <mem_init+0xc44>
f0102365:	39 c3                	cmp    %eax,%ebx
f0102367:	74 19                	je     f0102382 <mem_init+0xc5d>
f0102369:	68 c8 5b 10 f0       	push   $0xf0105bc8
f010236e:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102373:	68 7c 03 00 00       	push   $0x37c
f0102378:	68 59 5e 10 f0       	push   $0xf0105e59
f010237d:	e8 50 dd ff ff       	call   f01000d2 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102382:	83 ec 08             	sub    $0x8,%esp
f0102385:	6a 00                	push   $0x0
f0102387:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f010238d:	e8 dd f2 ff ff       	call   f010166f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102392:	ba 00 00 00 00       	mov    $0x0,%edx
f0102397:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f010239c:	e8 be ec ff ff       	call   f010105f <check_va2pa>
f01023a1:	83 c4 10             	add    $0x10,%esp
f01023a4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023a7:	74 19                	je     f01023c2 <mem_init+0xc9d>
f01023a9:	68 ec 5b 10 f0       	push   $0xf0105bec
f01023ae:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01023b3:	68 80 03 00 00       	push   $0x380
f01023b8:	68 59 5e 10 f0       	push   $0xf0105e59
f01023bd:	e8 10 dd ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023c2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023c7:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01023cc:	e8 8e ec ff ff       	call   f010105f <check_va2pa>
f01023d1:	89 f2                	mov    %esi,%edx
f01023d3:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f01023d9:	c1 fa 03             	sar    $0x3,%edx
f01023dc:	c1 e2 0c             	shl    $0xc,%edx
f01023df:	39 d0                	cmp    %edx,%eax
f01023e1:	74 19                	je     f01023fc <mem_init+0xcd7>
f01023e3:	68 98 5b 10 f0       	push   $0xf0105b98
f01023e8:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01023ed:	68 81 03 00 00       	push   $0x381
f01023f2:	68 59 5e 10 f0       	push   $0xf0105e59
f01023f7:	e8 d6 dc ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 1);
f01023fc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102401:	74 19                	je     f010241c <mem_init+0xcf7>
f0102403:	68 27 60 10 f0       	push   $0xf0106027
f0102408:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010240d:	68 82 03 00 00       	push   $0x382
f0102412:	68 59 5e 10 f0       	push   $0xf0105e59
f0102417:	e8 b6 dc ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 0);
f010241c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102421:	74 19                	je     f010243c <mem_init+0xd17>
f0102423:	68 81 60 10 f0       	push   $0xf0106081
f0102428:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010242d:	68 83 03 00 00       	push   $0x383
f0102432:	68 59 5e 10 f0       	push   $0xf0105e59
f0102437:	e8 96 dc ff ff       	call   f01000d2 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010243c:	83 ec 08             	sub    $0x8,%esp
f010243f:	68 00 10 00 00       	push   $0x1000
f0102444:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f010244a:	e8 20 f2 ff ff       	call   f010166f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010244f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102454:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102459:	e8 01 ec ff ff       	call   f010105f <check_va2pa>
f010245e:	83 c4 10             	add    $0x10,%esp
f0102461:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102464:	74 19                	je     f010247f <mem_init+0xd5a>
f0102466:	68 ec 5b 10 f0       	push   $0xf0105bec
f010246b:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102470:	68 87 03 00 00       	push   $0x387
f0102475:	68 59 5e 10 f0       	push   $0xf0105e59
f010247a:	e8 53 dc ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010247f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102484:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102489:	e8 d1 eb ff ff       	call   f010105f <check_va2pa>
f010248e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102491:	74 19                	je     f01024ac <mem_init+0xd87>
f0102493:	68 10 5c 10 f0       	push   $0xf0105c10
f0102498:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010249d:	68 88 03 00 00       	push   $0x388
f01024a2:	68 59 5e 10 f0       	push   $0xf0105e59
f01024a7:	e8 26 dc ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 0);
f01024ac:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01024b1:	74 19                	je     f01024cc <mem_init+0xda7>
f01024b3:	68 92 60 10 f0       	push   $0xf0106092
f01024b8:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01024bd:	68 89 03 00 00       	push   $0x389
f01024c2:	68 59 5e 10 f0       	push   $0xf0105e59
f01024c7:	e8 06 dc ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 0);
f01024cc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024d1:	74 19                	je     f01024ec <mem_init+0xdc7>
f01024d3:	68 81 60 10 f0       	push   $0xf0106081
f01024d8:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01024dd:	68 8a 03 00 00       	push   $0x38a
f01024e2:	68 59 5e 10 f0       	push   $0xf0105e59
f01024e7:	e8 e6 db ff ff       	call   f01000d2 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01024ec:	83 ec 0c             	sub    $0xc,%esp
f01024ef:	6a 00                	push   $0x0
f01024f1:	e8 58 ef ff ff       	call   f010144e <page_alloc>
f01024f6:	83 c4 10             	add    $0x10,%esp
f01024f9:	85 c0                	test   %eax,%eax
f01024fb:	74 04                	je     f0102501 <mem_init+0xddc>
f01024fd:	39 c6                	cmp    %eax,%esi
f01024ff:	74 19                	je     f010251a <mem_init+0xdf5>
f0102501:	68 38 5c 10 f0       	push   $0xf0105c38
f0102506:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010250b:	68 8d 03 00 00       	push   $0x38d
f0102510:	68 59 5e 10 f0       	push   $0xf0105e59
f0102515:	e8 b8 db ff ff       	call   f01000d2 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010251a:	83 ec 0c             	sub    $0xc,%esp
f010251d:	6a 00                	push   $0x0
f010251f:	e8 2a ef ff ff       	call   f010144e <page_alloc>
f0102524:	83 c4 10             	add    $0x10,%esp
f0102527:	85 c0                	test   %eax,%eax
f0102529:	74 19                	je     f0102544 <mem_init+0xe1f>
f010252b:	68 d5 5f 10 f0       	push   $0xf0105fd5
f0102530:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102535:	68 90 03 00 00       	push   $0x390
f010253a:	68 59 5e 10 f0       	push   $0xf0105e59
f010253f:	e8 8e db ff ff       	call   f01000d2 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102544:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102549:	8b 08                	mov    (%eax),%ecx
f010254b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102551:	89 fa                	mov    %edi,%edx
f0102553:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0102559:	c1 fa 03             	sar    $0x3,%edx
f010255c:	c1 e2 0c             	shl    $0xc,%edx
f010255f:	39 d1                	cmp    %edx,%ecx
f0102561:	74 19                	je     f010257c <mem_init+0xe57>
f0102563:	68 14 59 10 f0       	push   $0xf0105914
f0102568:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010256d:	68 93 03 00 00       	push   $0x393
f0102572:	68 59 5e 10 f0       	push   $0xf0105e59
f0102577:	e8 56 db ff ff       	call   f01000d2 <_panic>
	kern_pgdir[0] = 0;
f010257c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102582:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102587:	74 19                	je     f01025a2 <mem_init+0xe7d>
f0102589:	68 38 60 10 f0       	push   $0xf0106038
f010258e:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102593:	68 95 03 00 00       	push   $0x395
f0102598:	68 59 5e 10 f0       	push   $0xf0105e59
f010259d:	e8 30 db ff ff       	call   f01000d2 <_panic>
	pp0->pp_ref = 0;

	kern_pgdir[PDX(va)] = 0;
f01025a2:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01025a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025ad:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
f01025b3:	89 f8                	mov    %edi,%eax
f01025b5:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f01025bb:	c1 f8 03             	sar    $0x3,%eax
f01025be:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025c1:	89 c2                	mov    %eax,%edx
f01025c3:	c1 ea 0c             	shr    $0xc,%edx
f01025c6:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f01025cc:	72 12                	jb     f01025e0 <mem_init+0xebb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025ce:	50                   	push   %eax
f01025cf:	68 f8 56 10 f0       	push   $0xf01056f8
f01025d4:	6a 56                	push   $0x56
f01025d6:	68 65 5e 10 f0       	push   $0xf0105e65
f01025db:	e8 f2 da ff ff       	call   f01000d2 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01025e0:	83 ec 04             	sub    $0x4,%esp
f01025e3:	68 00 10 00 00       	push   $0x1000
f01025e8:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01025ed:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025f2:	50                   	push   %eax
f01025f3:	e8 ed 21 00 00       	call   f01047e5 <memset>
	page_free(pp0);
f01025f8:	89 3c 24             	mov    %edi,(%esp)
f01025fb:	e8 d8 ee ff ff       	call   f01014d8 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102600:	83 c4 0c             	add    $0xc,%esp
f0102603:	6a 01                	push   $0x1
f0102605:	6a 00                	push   $0x0
f0102607:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f010260d:	e8 04 ef ff ff       	call   f0101516 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102612:	89 fa                	mov    %edi,%edx
f0102614:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f010261a:	c1 fa 03             	sar    $0x3,%edx
f010261d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102620:	89 d0                	mov    %edx,%eax
f0102622:	c1 e8 0c             	shr    $0xc,%eax
f0102625:	83 c4 10             	add    $0x10,%esp
f0102628:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f010262e:	72 12                	jb     f0102642 <mem_init+0xf1d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102630:	52                   	push   %edx
f0102631:	68 f8 56 10 f0       	push   $0xf01056f8
f0102636:	6a 56                	push   $0x56
f0102638:	68 65 5e 10 f0       	push   $0xf0105e65
f010263d:	e8 90 da ff ff       	call   f01000d2 <_panic>
	return (void *)(pa + KERNBASE);
f0102642:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102648:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010264b:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102652:	75 11                	jne    f0102665 <mem_init+0xf40>
f0102654:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010265a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102660:	f6 00 01             	testb  $0x1,(%eax)
f0102663:	74 19                	je     f010267e <mem_init+0xf59>
f0102665:	68 a3 60 10 f0       	push   $0xf01060a3
f010266a:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010266f:	68 a1 03 00 00       	push   $0x3a1
f0102674:	68 59 5e 10 f0       	push   $0xf0105e59
f0102679:	e8 54 da ff ff       	call   f01000d2 <_panic>
f010267e:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102681:	39 d0                	cmp    %edx,%eax
f0102683:	75 db                	jne    f0102660 <mem_init+0xf3b>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102685:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f010268a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102690:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102696:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102699:	89 0d 70 04 1e f0    	mov    %ecx,0xf01e0470

	// free the pages we took
	page_free(pp0);
f010269f:	83 ec 0c             	sub    $0xc,%esp
f01026a2:	57                   	push   %edi
f01026a3:	e8 30 ee ff ff       	call   f01014d8 <page_free>
	page_free(pp1);
f01026a8:	89 34 24             	mov    %esi,(%esp)
f01026ab:	e8 28 ee ff ff       	call   f01014d8 <page_free>
	page_free(pp2);
f01026b0:	89 1c 24             	mov    %ebx,(%esp)
f01026b3:	e8 20 ee ff ff       	call   f01014d8 <page_free>

	cprintf("check_page() succeeded!\n");
f01026b8:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f01026bf:	e8 ed 0e 00 00       	call   f01035b1 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01026c4:	a1 4c 11 1e f0       	mov    0xf01e114c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026c9:	83 c4 10             	add    $0x10,%esp
f01026cc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026d1:	77 15                	ja     f01026e8 <mem_init+0xfc3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d3:	50                   	push   %eax
f01026d4:	68 24 55 10 f0       	push   $0xf0105524
f01026d9:	68 b7 00 00 00       	push   $0xb7
f01026de:	68 59 5e 10 f0       	push   $0xf0105e59
f01026e3:	e8 ea d9 ff ff       	call   f01000d2 <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f01026e8:	8b 15 44 11 1e f0    	mov    0xf01e1144,%edx
f01026ee:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01026f5:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f01026f8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01026fe:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102700:	05 00 00 00 10       	add    $0x10000000,%eax
f0102705:	50                   	push   %eax
f0102706:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010270b:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102710:	e8 98 ee ff ff       	call   f01015ad <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    cprintf("%d\n", sizeof(struct Env));
f0102715:	83 c4 08             	add    $0x8,%esp
f0102718:	6a 60                	push   $0x60
f010271a:	68 d0 4e 10 f0       	push   $0xf0104ed0
f010271f:	e8 8d 0e 00 00       	call   f01035b1 <cprintf>
    boot_map_region(kern_pgdir,
f0102724:	a1 7c 04 1e f0       	mov    0xf01e047c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102729:	83 c4 10             	add    $0x10,%esp
f010272c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102731:	77 15                	ja     f0102748 <mem_init+0x1023>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102733:	50                   	push   %eax
f0102734:	68 24 55 10 f0       	push   $0xf0105524
f0102739:	68 c5 00 00 00       	push   $0xc5
f010273e:	68 59 5e 10 f0       	push   $0xf0105e59
f0102743:	e8 8a d9 ff ff       	call   f01000d2 <_panic>
f0102748:	83 ec 08             	sub    $0x8,%esp
f010274b:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f010274d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102752:	50                   	push   %eax
f0102753:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102758:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010275d:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102762:	e8 46 ee ff ff       	call   f01015ad <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102767:	83 c4 10             	add    $0x10,%esp
f010276a:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f010276f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102774:	77 15                	ja     f010278b <mem_init+0x1066>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102776:	50                   	push   %eax
f0102777:	68 24 55 10 f0       	push   $0xf0105524
f010277c:	68 d6 00 00 00       	push   $0xd6
f0102781:	68 59 5e 10 f0       	push   $0xf0105e59
f0102786:	e8 47 d9 ff ff       	call   f01000d2 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f010278b:	83 ec 08             	sub    $0x8,%esp
f010278e:	6a 02                	push   $0x2
f0102790:	68 00 90 11 00       	push   $0x119000
f0102795:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010279a:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010279f:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01027a4:	e8 04 ee ff ff       	call   f01015ad <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f01027a9:	83 c4 08             	add    $0x8,%esp
f01027ac:	6a 02                	push   $0x2
f01027ae:	6a 00                	push   $0x0
f01027b0:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01027b5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01027ba:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01027bf:	e8 e9 ed ff ff       	call   f01015ad <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01027c4:	8b 1d 48 11 1e f0    	mov    0xf01e1148,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01027ca:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f01027cf:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f01027d6:	83 c4 10             	add    $0x10,%esp
f01027d9:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01027df:	74 63                	je     f0102844 <mem_init+0x111f>
f01027e1:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027e6:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01027ec:	89 d8                	mov    %ebx,%eax
f01027ee:	e8 6c e8 ff ff       	call   f010105f <check_va2pa>
f01027f3:	8b 15 4c 11 1e f0    	mov    0xf01e114c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027f9:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01027ff:	77 15                	ja     f0102816 <mem_init+0x10f1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102801:	52                   	push   %edx
f0102802:	68 24 55 10 f0       	push   $0xf0105524
f0102807:	68 e9 02 00 00       	push   $0x2e9
f010280c:	68 59 5e 10 f0       	push   $0xf0105e59
f0102811:	e8 bc d8 ff ff       	call   f01000d2 <_panic>
f0102816:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010281d:	39 d0                	cmp    %edx,%eax
f010281f:	74 19                	je     f010283a <mem_init+0x1115>
f0102821:	68 5c 5c 10 f0       	push   $0xf0105c5c
f0102826:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010282b:	68 e9 02 00 00       	push   $0x2e9
f0102830:	68 59 5e 10 f0       	push   $0xf0105e59
f0102835:	e8 98 d8 ff ff       	call   f01000d2 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010283a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102840:	39 f7                	cmp    %esi,%edi
f0102842:	77 a2                	ja     f01027e6 <mem_init+0x10c1>
f0102844:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102849:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f010284f:	89 d8                	mov    %ebx,%eax
f0102851:	e8 09 e8 ff ff       	call   f010105f <check_va2pa>
f0102856:	8b 15 7c 04 1e f0    	mov    0xf01e047c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010285c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102862:	77 15                	ja     f0102879 <mem_init+0x1154>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102864:	52                   	push   %edx
f0102865:	68 24 55 10 f0       	push   $0xf0105524
f010286a:	68 ee 02 00 00       	push   $0x2ee
f010286f:	68 59 5e 10 f0       	push   $0xf0105e59
f0102874:	e8 59 d8 ff ff       	call   f01000d2 <_panic>
f0102879:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102880:	39 d0                	cmp    %edx,%eax
f0102882:	74 19                	je     f010289d <mem_init+0x1178>
f0102884:	68 90 5c 10 f0       	push   $0xf0105c90
f0102889:	68 7f 5e 10 f0       	push   $0xf0105e7f
f010288e:	68 ee 02 00 00       	push   $0x2ee
f0102893:	68 59 5e 10 f0       	push   $0xf0105e59
f0102898:	e8 35 d8 ff ff       	call   f01000d2 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010289d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01028a3:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f01028a9:	75 9e                	jne    f0102849 <mem_init+0x1124>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028ab:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f01028b0:	c1 e0 0c             	shl    $0xc,%eax
f01028b3:	74 41                	je     f01028f6 <mem_init+0x11d1>
f01028b5:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028ba:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f01028c0:	89 d8                	mov    %ebx,%eax
f01028c2:	e8 98 e7 ff ff       	call   f010105f <check_va2pa>
f01028c7:	39 c6                	cmp    %eax,%esi
f01028c9:	74 19                	je     f01028e4 <mem_init+0x11bf>
f01028cb:	68 c4 5c 10 f0       	push   $0xf0105cc4
f01028d0:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01028d5:	68 f2 02 00 00       	push   $0x2f2
f01028da:	68 59 5e 10 f0       	push   $0xf0105e59
f01028df:	e8 ee d7 ff ff       	call   f01000d2 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028e4:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01028ea:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f01028ef:	c1 e0 0c             	shl    $0xc,%eax
f01028f2:	39 c6                	cmp    %eax,%esi
f01028f4:	72 c4                	jb     f01028ba <mem_init+0x1195>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01028f6:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01028fb:	89 d8                	mov    %ebx,%eax
f01028fd:	e8 5d e7 ff ff       	call   f010105f <check_va2pa>
f0102902:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102907:	bf 00 90 11 f0       	mov    $0xf0119000,%edi
f010290c:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102912:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102915:	39 c2                	cmp    %eax,%edx
f0102917:	74 19                	je     f0102932 <mem_init+0x120d>
f0102919:	68 ec 5c 10 f0       	push   $0xf0105cec
f010291e:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102923:	68 f6 02 00 00       	push   $0x2f6
f0102928:	68 59 5e 10 f0       	push   $0xf0105e59
f010292d:	e8 a0 d7 ff ff       	call   f01000d2 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102932:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102938:	0f 85 25 04 00 00    	jne    f0102d63 <mem_init+0x163e>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010293e:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102943:	89 d8                	mov    %ebx,%eax
f0102945:	e8 15 e7 ff ff       	call   f010105f <check_va2pa>
f010294a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010294d:	74 19                	je     f0102968 <mem_init+0x1243>
f010294f:	68 34 5d 10 f0       	push   $0xf0105d34
f0102954:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102959:	68 f7 02 00 00       	push   $0x2f7
f010295e:	68 59 5e 10 f0       	push   $0xf0105e59
f0102963:	e8 6a d7 ff ff       	call   f01000d2 <_panic>
f0102968:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010296d:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102972:	72 2d                	jb     f01029a1 <mem_init+0x127c>
f0102974:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102979:	76 07                	jbe    f0102982 <mem_init+0x125d>
f010297b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102980:	75 1f                	jne    f01029a1 <mem_init+0x127c>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102982:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102986:	75 7e                	jne    f0102a06 <mem_init+0x12e1>
f0102988:	68 d3 60 10 f0       	push   $0xf01060d3
f010298d:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102992:	68 00 03 00 00       	push   $0x300
f0102997:	68 59 5e 10 f0       	push   $0xf0105e59
f010299c:	e8 31 d7 ff ff       	call   f01000d2 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01029a1:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01029a6:	76 3f                	jbe    f01029e7 <mem_init+0x12c2>
				assert(pgdir[i] & PTE_P);
f01029a8:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01029ab:	f6 c2 01             	test   $0x1,%dl
f01029ae:	75 19                	jne    f01029c9 <mem_init+0x12a4>
f01029b0:	68 d3 60 10 f0       	push   $0xf01060d3
f01029b5:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01029ba:	68 04 03 00 00       	push   $0x304
f01029bf:	68 59 5e 10 f0       	push   $0xf0105e59
f01029c4:	e8 09 d7 ff ff       	call   f01000d2 <_panic>
				assert(pgdir[i] & PTE_W);
f01029c9:	f6 c2 02             	test   $0x2,%dl
f01029cc:	75 38                	jne    f0102a06 <mem_init+0x12e1>
f01029ce:	68 e4 60 10 f0       	push   $0xf01060e4
f01029d3:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01029d8:	68 05 03 00 00       	push   $0x305
f01029dd:	68 59 5e 10 f0       	push   $0xf0105e59
f01029e2:	e8 eb d6 ff ff       	call   f01000d2 <_panic>
			} else
				assert(pgdir[i] == 0);
f01029e7:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01029eb:	74 19                	je     f0102a06 <mem_init+0x12e1>
f01029ed:	68 f5 60 10 f0       	push   $0xf01060f5
f01029f2:	68 7f 5e 10 f0       	push   $0xf0105e7f
f01029f7:	68 07 03 00 00       	push   $0x307
f01029fc:	68 59 5e 10 f0       	push   $0xf0105e59
f0102a01:	e8 cc d6 ff ff       	call   f01000d2 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a06:	40                   	inc    %eax
f0102a07:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102a0c:	0f 85 5b ff ff ff    	jne    f010296d <mem_init+0x1248>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a12:	83 ec 0c             	sub    $0xc,%esp
f0102a15:	68 64 5d 10 f0       	push   $0xf0105d64
f0102a1a:	e8 92 0b 00 00       	call   f01035b1 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a1f:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a24:	83 c4 10             	add    $0x10,%esp
f0102a27:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a2c:	77 15                	ja     f0102a43 <mem_init+0x131e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a2e:	50                   	push   %eax
f0102a2f:	68 24 55 10 f0       	push   $0xf0105524
f0102a34:	68 f3 00 00 00       	push   $0xf3
f0102a39:	68 59 5e 10 f0       	push   $0xf0105e59
f0102a3e:	e8 8f d6 ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102a43:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102a48:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a4b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a50:	e8 93 e6 ff ff       	call   f01010e8 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102a55:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102a58:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102a5d:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102a60:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a63:	83 ec 0c             	sub    $0xc,%esp
f0102a66:	6a 00                	push   $0x0
f0102a68:	e8 e1 e9 ff ff       	call   f010144e <page_alloc>
f0102a6d:	89 c6                	mov    %eax,%esi
f0102a6f:	83 c4 10             	add    $0x10,%esp
f0102a72:	85 c0                	test   %eax,%eax
f0102a74:	75 19                	jne    f0102a8f <mem_init+0x136a>
f0102a76:	68 2a 5f 10 f0       	push   $0xf0105f2a
f0102a7b:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102a80:	68 bc 03 00 00       	push   $0x3bc
f0102a85:	68 59 5e 10 f0       	push   $0xf0105e59
f0102a8a:	e8 43 d6 ff ff       	call   f01000d2 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a8f:	83 ec 0c             	sub    $0xc,%esp
f0102a92:	6a 00                	push   $0x0
f0102a94:	e8 b5 e9 ff ff       	call   f010144e <page_alloc>
f0102a99:	89 c7                	mov    %eax,%edi
f0102a9b:	83 c4 10             	add    $0x10,%esp
f0102a9e:	85 c0                	test   %eax,%eax
f0102aa0:	75 19                	jne    f0102abb <mem_init+0x1396>
f0102aa2:	68 40 5f 10 f0       	push   $0xf0105f40
f0102aa7:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102aac:	68 bd 03 00 00       	push   $0x3bd
f0102ab1:	68 59 5e 10 f0       	push   $0xf0105e59
f0102ab6:	e8 17 d6 ff ff       	call   f01000d2 <_panic>
	assert((pp2 = page_alloc(0)));
f0102abb:	83 ec 0c             	sub    $0xc,%esp
f0102abe:	6a 00                	push   $0x0
f0102ac0:	e8 89 e9 ff ff       	call   f010144e <page_alloc>
f0102ac5:	89 c3                	mov    %eax,%ebx
f0102ac7:	83 c4 10             	add    $0x10,%esp
f0102aca:	85 c0                	test   %eax,%eax
f0102acc:	75 19                	jne    f0102ae7 <mem_init+0x13c2>
f0102ace:	68 56 5f 10 f0       	push   $0xf0105f56
f0102ad3:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102ad8:	68 be 03 00 00       	push   $0x3be
f0102add:	68 59 5e 10 f0       	push   $0xf0105e59
f0102ae2:	e8 eb d5 ff ff       	call   f01000d2 <_panic>
	page_free(pp0);
f0102ae7:	83 ec 0c             	sub    $0xc,%esp
f0102aea:	56                   	push   %esi
f0102aeb:	e8 e8 e9 ff ff       	call   f01014d8 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102af0:	89 f8                	mov    %edi,%eax
f0102af2:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0102af8:	c1 f8 03             	sar    $0x3,%eax
f0102afb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102afe:	89 c2                	mov    %eax,%edx
f0102b00:	c1 ea 0c             	shr    $0xc,%edx
f0102b03:	83 c4 10             	add    $0x10,%esp
f0102b06:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0102b0c:	72 12                	jb     f0102b20 <mem_init+0x13fb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b0e:	50                   	push   %eax
f0102b0f:	68 f8 56 10 f0       	push   $0xf01056f8
f0102b14:	6a 56                	push   $0x56
f0102b16:	68 65 5e 10 f0       	push   $0xf0105e65
f0102b1b:	e8 b2 d5 ff ff       	call   f01000d2 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b20:	83 ec 04             	sub    $0x4,%esp
f0102b23:	68 00 10 00 00       	push   $0x1000
f0102b28:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102b2a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b2f:	50                   	push   %eax
f0102b30:	e8 b0 1c 00 00       	call   f01047e5 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b35:	89 d8                	mov    %ebx,%eax
f0102b37:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0102b3d:	c1 f8 03             	sar    $0x3,%eax
f0102b40:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b43:	89 c2                	mov    %eax,%edx
f0102b45:	c1 ea 0c             	shr    $0xc,%edx
f0102b48:	83 c4 10             	add    $0x10,%esp
f0102b4b:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0102b51:	72 12                	jb     f0102b65 <mem_init+0x1440>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b53:	50                   	push   %eax
f0102b54:	68 f8 56 10 f0       	push   $0xf01056f8
f0102b59:	6a 56                	push   $0x56
f0102b5b:	68 65 5e 10 f0       	push   $0xf0105e65
f0102b60:	e8 6d d5 ff ff       	call   f01000d2 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b65:	83 ec 04             	sub    $0x4,%esp
f0102b68:	68 00 10 00 00       	push   $0x1000
f0102b6d:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102b6f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b74:	50                   	push   %eax
f0102b75:	e8 6b 1c 00 00       	call   f01047e5 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b7a:	6a 02                	push   $0x2
f0102b7c:	68 00 10 00 00       	push   $0x1000
f0102b81:	57                   	push   %edi
f0102b82:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102b88:	e8 2f eb ff ff       	call   f01016bc <page_insert>
	assert(pp1->pp_ref == 1);
f0102b8d:	83 c4 20             	add    $0x20,%esp
f0102b90:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b95:	74 19                	je     f0102bb0 <mem_init+0x148b>
f0102b97:	68 27 60 10 f0       	push   $0xf0106027
f0102b9c:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102ba1:	68 c3 03 00 00       	push   $0x3c3
f0102ba6:	68 59 5e 10 f0       	push   $0xf0105e59
f0102bab:	e8 22 d5 ff ff       	call   f01000d2 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102bb0:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102bb7:	01 01 01 
f0102bba:	74 19                	je     f0102bd5 <mem_init+0x14b0>
f0102bbc:	68 84 5d 10 f0       	push   $0xf0105d84
f0102bc1:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102bc6:	68 c4 03 00 00       	push   $0x3c4
f0102bcb:	68 59 5e 10 f0       	push   $0xf0105e59
f0102bd0:	e8 fd d4 ff ff       	call   f01000d2 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102bd5:	6a 02                	push   $0x2
f0102bd7:	68 00 10 00 00       	push   $0x1000
f0102bdc:	53                   	push   %ebx
f0102bdd:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102be3:	e8 d4 ea ff ff       	call   f01016bc <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102be8:	83 c4 10             	add    $0x10,%esp
f0102beb:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102bf2:	02 02 02 
f0102bf5:	74 19                	je     f0102c10 <mem_init+0x14eb>
f0102bf7:	68 a8 5d 10 f0       	push   $0xf0105da8
f0102bfc:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102c01:	68 c6 03 00 00       	push   $0x3c6
f0102c06:	68 59 5e 10 f0       	push   $0xf0105e59
f0102c0b:	e8 c2 d4 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f0102c10:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c15:	74 19                	je     f0102c30 <mem_init+0x150b>
f0102c17:	68 49 60 10 f0       	push   $0xf0106049
f0102c1c:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102c21:	68 c7 03 00 00       	push   $0x3c7
f0102c26:	68 59 5e 10 f0       	push   $0xf0105e59
f0102c2b:	e8 a2 d4 ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 0);
f0102c30:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c35:	74 19                	je     f0102c50 <mem_init+0x152b>
f0102c37:	68 92 60 10 f0       	push   $0xf0106092
f0102c3c:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102c41:	68 c8 03 00 00       	push   $0x3c8
f0102c46:	68 59 5e 10 f0       	push   $0xf0105e59
f0102c4b:	e8 82 d4 ff ff       	call   f01000d2 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c50:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c57:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c5a:	89 d8                	mov    %ebx,%eax
f0102c5c:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0102c62:	c1 f8 03             	sar    $0x3,%eax
f0102c65:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c68:	89 c2                	mov    %eax,%edx
f0102c6a:	c1 ea 0c             	shr    $0xc,%edx
f0102c6d:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0102c73:	72 12                	jb     f0102c87 <mem_init+0x1562>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c75:	50                   	push   %eax
f0102c76:	68 f8 56 10 f0       	push   $0xf01056f8
f0102c7b:	6a 56                	push   $0x56
f0102c7d:	68 65 5e 10 f0       	push   $0xf0105e65
f0102c82:	e8 4b d4 ff ff       	call   f01000d2 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c87:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c8e:	03 03 03 
f0102c91:	74 19                	je     f0102cac <mem_init+0x1587>
f0102c93:	68 cc 5d 10 f0       	push   $0xf0105dcc
f0102c98:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102c9d:	68 ca 03 00 00       	push   $0x3ca
f0102ca2:	68 59 5e 10 f0       	push   $0xf0105e59
f0102ca7:	e8 26 d4 ff ff       	call   f01000d2 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cac:	83 ec 08             	sub    $0x8,%esp
f0102caf:	68 00 10 00 00       	push   $0x1000
f0102cb4:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102cba:	e8 b0 e9 ff ff       	call   f010166f <page_remove>
	assert(pp2->pp_ref == 0);
f0102cbf:	83 c4 10             	add    $0x10,%esp
f0102cc2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102cc7:	74 19                	je     f0102ce2 <mem_init+0x15bd>
f0102cc9:	68 81 60 10 f0       	push   $0xf0106081
f0102cce:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102cd3:	68 cc 03 00 00       	push   $0x3cc
f0102cd8:	68 59 5e 10 f0       	push   $0xf0105e59
f0102cdd:	e8 f0 d3 ff ff       	call   f01000d2 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ce2:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102ce7:	8b 08                	mov    (%eax),%ecx
f0102ce9:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cef:	89 f2                	mov    %esi,%edx
f0102cf1:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0102cf7:	c1 fa 03             	sar    $0x3,%edx
f0102cfa:	c1 e2 0c             	shl    $0xc,%edx
f0102cfd:	39 d1                	cmp    %edx,%ecx
f0102cff:	74 19                	je     f0102d1a <mem_init+0x15f5>
f0102d01:	68 14 59 10 f0       	push   $0xf0105914
f0102d06:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102d0b:	68 cf 03 00 00       	push   $0x3cf
f0102d10:	68 59 5e 10 f0       	push   $0xf0105e59
f0102d15:	e8 b8 d3 ff ff       	call   f01000d2 <_panic>
	kern_pgdir[0] = 0;
f0102d1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102d20:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d25:	74 19                	je     f0102d40 <mem_init+0x161b>
f0102d27:	68 38 60 10 f0       	push   $0xf0106038
f0102d2c:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0102d31:	68 d1 03 00 00       	push   $0x3d1
f0102d36:	68 59 5e 10 f0       	push   $0xf0105e59
f0102d3b:	e8 92 d3 ff ff       	call   f01000d2 <_panic>
	pp0->pp_ref = 0;
f0102d40:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102d46:	83 ec 0c             	sub    $0xc,%esp
f0102d49:	56                   	push   %esi
f0102d4a:	e8 89 e7 ff ff       	call   f01014d8 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d4f:	c7 04 24 f8 5d 10 f0 	movl   $0xf0105df8,(%esp)
f0102d56:	e8 56 08 00 00       	call   f01035b1 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d5e:	5b                   	pop    %ebx
f0102d5f:	5e                   	pop    %esi
f0102d60:	5f                   	pop    %edi
f0102d61:	c9                   	leave  
f0102d62:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102d63:	89 f2                	mov    %esi,%edx
f0102d65:	89 d8                	mov    %ebx,%eax
f0102d67:	e8 f3 e2 ff ff       	call   f010105f <check_va2pa>
f0102d6c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102d72:	e9 9b fb ff ff       	jmp    f0102912 <mem_init+0x11ed>

f0102d77 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102d77:	55                   	push   %ebp
f0102d78:	89 e5                	mov    %esp,%ebp
f0102d7a:	57                   	push   %edi
f0102d7b:	56                   	push   %esi
f0102d7c:	53                   	push   %ebx
f0102d7d:	83 ec 1c             	sub    $0x1c,%esp
f0102d80:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102d83:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d86:	8b 55 10             	mov    0x10(%ebp),%edx
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f0102d89:	85 d2                	test   %edx,%edx
f0102d8b:	0f 84 85 00 00 00    	je     f0102e16 <user_mem_check+0x9f>

	perm |= PTE_P;
f0102d91:	8b 75 14             	mov    0x14(%ebp),%esi
f0102d94:	83 ce 01             	or     $0x1,%esi
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
f0102d97:	89 c3                	mov    %eax,%ebx
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
f0102d99:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0102da0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102da6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f0102da9:	89 c2                	mov    %eax,%edx
f0102dab:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102db1:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f0102db4:	74 67                	je     f0102e1d <user_mem_check+0xa6>
		if (va_now >= ULIM) {
f0102db6:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0102dbb:	76 17                	jbe    f0102dd4 <user_mem_check+0x5d>
f0102dbd:	eb 08                	jmp    f0102dc7 <user_mem_check+0x50>
f0102dbf:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102dc5:	76 0d                	jbe    f0102dd4 <user_mem_check+0x5d>
			user_mem_check_addr = va_now;
f0102dc7:	89 1d 6c 04 1e f0    	mov    %ebx,0xf01e046c
			return -E_FAULT;
f0102dcd:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102dd2:	eb 4e                	jmp    f0102e22 <user_mem_check+0xab>
		}
		pte = pgdir_walk(env->env_pgdir, (void *)va_now, false);
f0102dd4:	83 ec 04             	sub    $0x4,%esp
f0102dd7:	6a 00                	push   $0x0
f0102dd9:	53                   	push   %ebx
f0102dda:	ff 77 5c             	pushl  0x5c(%edi)
f0102ddd:	e8 34 e7 ff ff       	call   f0101516 <pgdir_walk>
		if (pte == NULL || ((*pte & perm ) != perm)) {
f0102de2:	83 c4 10             	add    $0x10,%esp
f0102de5:	85 c0                	test   %eax,%eax
f0102de7:	74 08                	je     f0102df1 <user_mem_check+0x7a>
f0102de9:	8b 00                	mov    (%eax),%eax
f0102deb:	21 f0                	and    %esi,%eax
f0102ded:	39 c6                	cmp    %eax,%esi
f0102def:	74 0d                	je     f0102dfe <user_mem_check+0x87>
			user_mem_check_addr = va_now;
f0102df1:	89 1d 6c 04 1e f0    	mov    %ebx,0xf01e046c
			return -E_FAULT;
f0102df7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102dfc:	eb 24                	jmp    f0102e22 <user_mem_check+0xab>

	perm |= PTE_P;
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f0102dfe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e04:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102e0a:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102e0d:	75 b0                	jne    f0102dbf <user_mem_check+0x48>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0102e0f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e14:	eb 0c                	jmp    f0102e22 <user_mem_check+0xab>
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f0102e16:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e1b:	eb 05                	jmp    f0102e22 <user_mem_check+0xab>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0102e1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e25:	5b                   	pop    %ebx
f0102e26:	5e                   	pop    %esi
f0102e27:	5f                   	pop    %edi
f0102e28:	c9                   	leave  
f0102e29:	c3                   	ret    

f0102e2a <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102e2a:	55                   	push   %ebp
f0102e2b:	89 e5                	mov    %esp,%ebp
f0102e2d:	53                   	push   %ebx
f0102e2e:	83 ec 04             	sub    $0x4,%esp
f0102e31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102e34:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e37:	83 c8 04             	or     $0x4,%eax
f0102e3a:	50                   	push   %eax
f0102e3b:	ff 75 10             	pushl  0x10(%ebp)
f0102e3e:	ff 75 0c             	pushl  0xc(%ebp)
f0102e41:	53                   	push   %ebx
f0102e42:	e8 30 ff ff ff       	call   f0102d77 <user_mem_check>
f0102e47:	83 c4 10             	add    $0x10,%esp
f0102e4a:	85 c0                	test   %eax,%eax
f0102e4c:	79 21                	jns    f0102e6f <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102e4e:	83 ec 04             	sub    $0x4,%esp
f0102e51:	ff 35 6c 04 1e f0    	pushl  0xf01e046c
f0102e57:	ff 73 48             	pushl  0x48(%ebx)
f0102e5a:	68 24 5e 10 f0       	push   $0xf0105e24
f0102e5f:	e8 4d 07 00 00       	call   f01035b1 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e64:	89 1c 24             	mov    %ebx,(%esp)
f0102e67:	e8 30 06 00 00       	call   f010349c <env_destroy>
f0102e6c:	83 c4 10             	add    $0x10,%esp
	}
}
f0102e6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e72:	c9                   	leave  
f0102e73:	c3                   	ret    

f0102e74 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102e74:	55                   	push   %ebp
f0102e75:	89 e5                	mov    %esp,%ebp
f0102e77:	57                   	push   %edi
f0102e78:	56                   	push   %esi
f0102e79:	53                   	push   %ebx
f0102e7a:	83 ec 0c             	sub    $0xc,%esp
f0102e7d:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0102e7f:	89 d3                	mov    %edx,%ebx
f0102e81:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
f0102e87:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0102e8e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0102e94:	39 fb                	cmp    %edi,%ebx
f0102e96:	74 5a                	je     f0102ef2 <region_alloc+0x7e>
        pg = page_alloc(1);
f0102e98:	83 ec 0c             	sub    $0xc,%esp
f0102e9b:	6a 01                	push   $0x1
f0102e9d:	e8 ac e5 ff ff       	call   f010144e <page_alloc>
        if (pg == NULL) {
f0102ea2:	83 c4 10             	add    $0x10,%esp
f0102ea5:	85 c0                	test   %eax,%eax
f0102ea7:	75 17                	jne    f0102ec0 <region_alloc+0x4c>
            panic("region_alloc : can't alloc page\n");
f0102ea9:	83 ec 04             	sub    $0x4,%esp
f0102eac:	68 04 61 10 f0       	push   $0xf0106104
f0102eb1:	68 2a 01 00 00       	push   $0x12a
f0102eb6:	68 7e 61 10 f0       	push   $0xf010617e
f0102ebb:	e8 12 d2 ff ff       	call   f01000d2 <_panic>
        } else {
            r = page_insert(e->env_pgdir, pg, (void *)addr, PTE_U | PTE_W);
f0102ec0:	6a 06                	push   $0x6
f0102ec2:	53                   	push   %ebx
f0102ec3:	50                   	push   %eax
f0102ec4:	ff 76 5c             	pushl  0x5c(%esi)
f0102ec7:	e8 f0 e7 ff ff       	call   f01016bc <page_insert>
            if (r != 0) {
f0102ecc:	83 c4 10             	add    $0x10,%esp
f0102ecf:	85 c0                	test   %eax,%eax
f0102ed1:	74 15                	je     f0102ee8 <region_alloc+0x74>
                panic("/kern/env.c/region_alloc : %e\n", r);
f0102ed3:	50                   	push   %eax
f0102ed4:	68 28 61 10 f0       	push   $0xf0106128
f0102ed9:	68 2e 01 00 00       	push   $0x12e
f0102ede:	68 7e 61 10 f0       	push   $0xf010617e
f0102ee3:	e8 ea d1 ff ff       	call   f01000d2 <_panic>
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0102ee8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102eee:	39 df                	cmp    %ebx,%edi
f0102ef0:	75 a6                	jne    f0102e98 <region_alloc+0x24>
                panic("/kern/env.c/region_alloc : %e\n", r);
            }
        }
    }
    return;
}
f0102ef2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ef5:	5b                   	pop    %ebx
f0102ef6:	5e                   	pop    %esi
f0102ef7:	5f                   	pop    %edi
f0102ef8:	c9                   	leave  
f0102ef9:	c3                   	ret    

f0102efa <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102efa:	55                   	push   %ebp
f0102efb:	89 e5                	mov    %esp,%ebp
f0102efd:	53                   	push   %ebx
f0102efe:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f04:	8a 5d 10             	mov    0x10(%ebp),%bl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102f07:	85 c0                	test   %eax,%eax
f0102f09:	75 0e                	jne    f0102f19 <envid2env+0x1f>
		*env_store = curenv;
f0102f0b:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f0102f10:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102f12:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f17:	eb 55                	jmp    f0102f6e <envid2env+0x74>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102f19:	89 c2                	mov    %eax,%edx
f0102f1b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102f21:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102f24:	c1 e2 05             	shl    $0x5,%edx
f0102f27:	03 15 7c 04 1e f0    	add    0xf01e047c,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102f2d:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102f31:	74 05                	je     f0102f38 <envid2env+0x3e>
f0102f33:	39 42 48             	cmp    %eax,0x48(%edx)
f0102f36:	74 0d                	je     f0102f45 <envid2env+0x4b>
		*env_store = 0;
f0102f38:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102f3e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f43:	eb 29                	jmp    f0102f6e <envid2env+0x74>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f45:	84 db                	test   %bl,%bl
f0102f47:	74 1e                	je     f0102f67 <envid2env+0x6d>
f0102f49:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f0102f4e:	39 c2                	cmp    %eax,%edx
f0102f50:	74 15                	je     f0102f67 <envid2env+0x6d>
f0102f52:	8b 58 48             	mov    0x48(%eax),%ebx
f0102f55:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f0102f58:	74 0d                	je     f0102f67 <envid2env+0x6d>
		*env_store = 0;
f0102f5a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102f60:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f65:	eb 07                	jmp    f0102f6e <envid2env+0x74>
	}

	*env_store = e;
f0102f67:	89 11                	mov    %edx,(%ecx)
	return 0;
f0102f69:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f6e:	5b                   	pop    %ebx
f0102f6f:	c9                   	leave  
f0102f70:	c3                   	ret    

f0102f71 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102f71:	55                   	push   %ebp
f0102f72:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102f74:	b8 30 33 12 f0       	mov    $0xf0123330,%eax
f0102f79:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102f7c:	b8 23 00 00 00       	mov    $0x23,%eax
f0102f81:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102f83:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102f85:	b0 10                	mov    $0x10,%al
f0102f87:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102f89:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102f8b:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102f8d:	ea 94 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f94
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102f94:	b0 00                	mov    $0x0,%al
f0102f96:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f99:	c9                   	leave  
f0102f9a:	c3                   	ret    

f0102f9b <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f9b:	55                   	push   %ebp
f0102f9c:	89 e5                	mov    %esp,%ebp
f0102f9e:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
f0102f9f:	8b 1d 7c 04 1e f0    	mov    0xf01e047c,%ebx
f0102fa5:	89 1d 84 04 1e f0    	mov    %ebx,0xf01e0484
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
f0102fab:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        envs[i].env_status = ENV_FREE;
f0102fb2:	c7 43 54 00 00 00 00 	movl   $0x0,0x54(%ebx)
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0102fb9:	8d 43 60             	lea    0x60(%ebx),%eax
f0102fbc:	8d 8b 00 80 01 00    	lea    0x18000(%ebx),%ecx
f0102fc2:	89 c2                	mov    %eax,%edx
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0102fc4:	89 43 44             	mov    %eax,0x44(%ebx)
{
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
f0102fc7:	39 c8                	cmp    %ecx,%eax
f0102fc9:	74 1c                	je     f0102fe7 <env_init+0x4c>
        envs[i].env_id = 0;
f0102fcb:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE;
f0102fd2:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f0102fd9:	83 c0 60             	add    $0x60,%eax
        if (i + 1 != NENV)
f0102fdc:	39 c8                	cmp    %ecx,%eax
f0102fde:	75 0f                	jne    f0102fef <env_init+0x54>
            envs[i].env_link = envs + (i + 1);
        else 
            envs[i].env_link = NULL;
f0102fe0:	c7 42 44 00 00 00 00 	movl   $0x0,0x44(%edx)
    }

	// Per-CPU part of the initialization
	env_init_percpu();
f0102fe7:	e8 85 ff ff ff       	call   f0102f71 <env_init_percpu>
}
f0102fec:	5b                   	pop    %ebx
f0102fed:	c9                   	leave  
f0102fee:	c3                   	ret    
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0102fef:	89 42 44             	mov    %eax,0x44(%edx)
f0102ff2:	89 c2                	mov    %eax,%edx
f0102ff4:	eb d5                	jmp    f0102fcb <env_init+0x30>

f0102ff6 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102ff6:	55                   	push   %ebp
f0102ff7:	89 e5                	mov    %esp,%ebp
f0102ff9:	56                   	push   %esi
f0102ffa:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102ffb:	8b 35 84 04 1e f0    	mov    0xf01e0484,%esi
f0103001:	85 f6                	test   %esi,%esi
f0103003:	0f 84 8d 01 00 00    	je     f0103196 <env_alloc+0x1a0>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103009:	83 ec 0c             	sub    $0xc,%esp
f010300c:	6a 01                	push   $0x1
f010300e:	e8 3b e4 ff ff       	call   f010144e <page_alloc>
f0103013:	89 c3                	mov    %eax,%ebx
f0103015:	83 c4 10             	add    $0x10,%esp
f0103018:	85 c0                	test   %eax,%eax
f010301a:	0f 84 7d 01 00 00    	je     f010319d <env_alloc+0x1a7>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    cprintf("env_setup_vm in\n");
f0103020:	83 ec 0c             	sub    $0xc,%esp
f0103023:	68 89 61 10 f0       	push   $0xf0106189
f0103028:	e8 84 05 00 00       	call   f01035b1 <cprintf>

    p->pp_ref++;
f010302d:	66 ff 43 04          	incw   0x4(%ebx)
f0103031:	2b 1d 4c 11 1e f0    	sub    0xf01e114c,%ebx
f0103037:	c1 fb 03             	sar    $0x3,%ebx
f010303a:	c1 e3 0c             	shl    $0xc,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010303d:	89 d8                	mov    %ebx,%eax
f010303f:	c1 e8 0c             	shr    $0xc,%eax
f0103042:	83 c4 10             	add    $0x10,%esp
f0103045:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f010304b:	72 12                	jb     f010305f <env_alloc+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010304d:	53                   	push   %ebx
f010304e:	68 f8 56 10 f0       	push   $0xf01056f8
f0103053:	6a 56                	push   $0x56
f0103055:	68 65 5e 10 f0       	push   $0xf0105e65
f010305a:	e8 73 d0 ff ff       	call   f01000d2 <_panic>
	return (void *)(pa + KERNBASE);
f010305f:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
    e->env_pgdir = (pde_t *)page2kva(p);
f0103065:	89 5e 5c             	mov    %ebx,0x5c(%esi)
    // pay attention: have we set mapped in kern_pgdir ?
    // page_insert(kern_pgdir, p, (void *)e->env_pgdir, PTE_U | PTE_W); 

    memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103068:	83 ec 04             	sub    $0x4,%esp
f010306b:	68 00 10 00 00       	push   $0x1000
f0103070:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0103076:	53                   	push   %ebx
f0103077:	e8 1d 18 00 00       	call   f0104899 <memcpy>
    memset(e->env_pgdir, 0, PDX(UTOP) * sizeof(pde_t));
f010307c:	83 c4 0c             	add    $0xc,%esp
f010307f:	68 ec 0e 00 00       	push   $0xeec
f0103084:	6a 00                	push   $0x0
f0103086:	ff 76 5c             	pushl  0x5c(%esi)
f0103089:	e8 57 17 00 00       	call   f01047e5 <memset>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010308e:	8b 46 5c             	mov    0x5c(%esi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103091:	83 c4 10             	add    $0x10,%esp
f0103094:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103099:	77 15                	ja     f01030b0 <env_alloc+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010309b:	50                   	push   %eax
f010309c:	68 24 55 10 f0       	push   $0xf0105524
f01030a1:	68 cc 00 00 00       	push   $0xcc
f01030a6:	68 7e 61 10 f0       	push   $0xf010617e
f01030ab:	e8 22 d0 ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01030b0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01030b6:	83 ca 05             	or     $0x5,%edx
f01030b9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)

    cprintf("env_setup_vm out\n");
f01030bf:	83 ec 0c             	sub    $0xc,%esp
f01030c2:	68 9a 61 10 f0       	push   $0xf010619a
f01030c7:	e8 e5 04 00 00       	call   f01035b1 <cprintf>
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
    
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01030cc:	8b 46 48             	mov    0x48(%esi),%eax
f01030cf:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01030d4:	83 c4 10             	add    $0x10,%esp
f01030d7:	89 c1                	mov    %eax,%ecx
f01030d9:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f01030df:	7f 05                	jg     f01030e6 <env_alloc+0xf0>
		generation = 1 << ENVGENSHIFT;
f01030e1:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f01030e6:	89 f0                	mov    %esi,%eax
f01030e8:	2b 05 7c 04 1e f0    	sub    0xf01e047c,%eax
f01030ee:	c1 f8 05             	sar    $0x5,%eax
f01030f1:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01030f4:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01030f7:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01030fa:	89 d3                	mov    %edx,%ebx
f01030fc:	c1 e3 08             	shl    $0x8,%ebx
f01030ff:	01 da                	add    %ebx,%edx
f0103101:	89 d3                	mov    %edx,%ebx
f0103103:	c1 e3 10             	shl    $0x10,%ebx
f0103106:	01 da                	add    %ebx,%edx
f0103108:	8d 04 50             	lea    (%eax,%edx,2),%eax
f010310b:	09 c1                	or     %eax,%ecx
f010310d:	89 4e 48             	mov    %ecx,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103110:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103113:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f0103116:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f010311d:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0103124:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010312b:	83 ec 04             	sub    $0x4,%esp
f010312e:	6a 44                	push   $0x44
f0103130:	6a 00                	push   $0x0
f0103132:	56                   	push   %esi
f0103133:	e8 ad 16 00 00       	call   f01047e5 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103138:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f010313e:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f0103144:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f010314a:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f0103151:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0103157:	8b 46 44             	mov    0x44(%esi),%eax
f010315a:	a3 84 04 1e f0       	mov    %eax,0xf01e0484
	*newenv_store = e;
f010315f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103162:	89 30                	mov    %esi,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103164:	8b 56 48             	mov    0x48(%esi),%edx
f0103167:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f010316c:	83 c4 10             	add    $0x10,%esp
f010316f:	85 c0                	test   %eax,%eax
f0103171:	74 05                	je     f0103178 <env_alloc+0x182>
f0103173:	8b 40 48             	mov    0x48(%eax),%eax
f0103176:	eb 05                	jmp    f010317d <env_alloc+0x187>
f0103178:	b8 00 00 00 00       	mov    $0x0,%eax
f010317d:	83 ec 04             	sub    $0x4,%esp
f0103180:	52                   	push   %edx
f0103181:	50                   	push   %eax
f0103182:	68 ac 61 10 f0       	push   $0xf01061ac
f0103187:	e8 25 04 00 00       	call   f01035b1 <cprintf>
	return 0;
f010318c:	83 c4 10             	add    $0x10,%esp
f010318f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103194:	eb 0c                	jmp    f01031a2 <env_alloc+0x1ac>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103196:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010319b:	eb 05                	jmp    f01031a2 <env_alloc+0x1ac>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010319d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01031a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01031a5:	5b                   	pop    %ebx
f01031a6:	5e                   	pop    %esi
f01031a7:	c9                   	leave  
f01031a8:	c3                   	ret    

f01031a9 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f01031a9:	55                   	push   %ebp
f01031aa:	89 e5                	mov    %esp,%ebp
f01031ac:	57                   	push   %edi
f01031ad:	56                   	push   %esi
f01031ae:	53                   	push   %ebx
f01031af:	83 ec 34             	sub    $0x34,%esp
f01031b2:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("env_create %u %u %u\n", binary, size, type);
	// LAB 3: Your code here.
    struct Env * e;
    int r = env_alloc(&e, 0);
f01031b5:	6a 00                	push   $0x0
f01031b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01031ba:	50                   	push   %eax
f01031bb:	e8 36 fe ff ff       	call   f0102ff6 <env_alloc>
    if (r < 0) {
f01031c0:	83 c4 10             	add    $0x10,%esp
f01031c3:	85 c0                	test   %eax,%eax
f01031c5:	79 15                	jns    f01031dc <env_create+0x33>
        panic("env_create: %e\n", r);
f01031c7:	50                   	push   %eax
f01031c8:	68 c1 61 10 f0       	push   $0xf01061c1
f01031cd:	68 98 01 00 00       	push   $0x198
f01031d2:	68 7e 61 10 f0       	push   $0xf010617e
f01031d7:	e8 f6 ce ff ff       	call   f01000d2 <_panic>
    }
    load_icode(e, binary, size);
f01031dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
f01031e2:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f01031e8:	74 17                	je     f0103201 <env_create+0x58>
        panic("error elf magic number\n");
f01031ea:	83 ec 04             	sub    $0x4,%esp
f01031ed:	68 d1 61 10 f0       	push   $0xf01061d1
f01031f2:	68 6d 01 00 00       	push   $0x16d
f01031f7:	68 7e 61 10 f0       	push   $0xf010617e
f01031fc:	e8 d1 ce ff ff       	call   f01000d2 <_panic>
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0103201:	8b 5e 1c             	mov    0x1c(%esi),%ebx
    eph = ph + elf->e_phnum;
f0103204:	8b 7e 2c             	mov    0x2c(%esi),%edi

    lcr3(PADDR(e->env_pgdir));
f0103207:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010320a:	8b 42 5c             	mov    0x5c(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010320d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103212:	77 15                	ja     f0103229 <env_create+0x80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103214:	50                   	push   %eax
f0103215:	68 24 55 10 f0       	push   $0xf0105524
f010321a:	68 73 01 00 00       	push   $0x173
f010321f:	68 7e 61 10 f0       	push   $0xf010617e
f0103224:	e8 a9 ce ff ff       	call   f01000d2 <_panic>
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
        panic("error elf magic number\n");
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0103229:	8d 1c 1e             	lea    (%esi,%ebx,1),%ebx
    eph = ph + elf->e_phnum;
f010322c:	0f b7 ff             	movzwl %di,%edi
f010322f:	c1 e7 05             	shl    $0x5,%edi
f0103232:	8d 3c 3b             	lea    (%ebx,%edi,1),%edi
	return (physaddr_t)kva - KERNBASE;
f0103235:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010323a:	0f 22 d8             	mov    %eax,%cr3

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f010323d:	39 fb                	cmp    %edi,%ebx
f010323f:	73 48                	jae    f0103289 <env_create+0xe0>
        if (ph->p_type == ELF_PROG_LOAD) {
f0103241:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103244:	75 3c                	jne    f0103282 <env_create+0xd9>
            // cprintf("%u %u\n", ph->p_memsz, ph->p_filesz);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103246:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103249:	8b 53 08             	mov    0x8(%ebx),%edx
f010324c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010324f:	e8 20 fc ff ff       	call   f0102e74 <region_alloc>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103254:	83 ec 04             	sub    $0x4,%esp
f0103257:	ff 73 10             	pushl  0x10(%ebx)
f010325a:	89 f0                	mov    %esi,%eax
f010325c:	03 43 04             	add    0x4(%ebx),%eax
f010325f:	50                   	push   %eax
f0103260:	ff 73 08             	pushl  0x8(%ebx)
f0103263:	e8 31 16 00 00       	call   f0104899 <memcpy>
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0103268:	8b 43 10             	mov    0x10(%ebx),%eax
f010326b:	83 c4 0c             	add    $0xc,%esp
f010326e:	8b 53 14             	mov    0x14(%ebx),%edx
f0103271:	29 c2                	sub    %eax,%edx
f0103273:	52                   	push   %edx
f0103274:	6a 00                	push   $0x0
f0103276:	03 43 08             	add    0x8(%ebx),%eax
f0103279:	50                   	push   %eax
f010327a:	e8 66 15 00 00       	call   f01047e5 <memset>
f010327f:	83 c4 10             	add    $0x10,%esp
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
    eph = ph + elf->e_phnum;

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f0103282:	83 c3 20             	add    $0x20,%ebx
f0103285:	39 df                	cmp    %ebx,%edi
f0103287:	77 b8                	ja     f0103241 <env_create+0x98>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
        }
    }
    e->env_tf.tf_eip = elf->e_entry;
f0103289:	8b 46 18             	mov    0x18(%esi),%eax
f010328c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010328f:	89 42 30             	mov    %eax,0x30(%edx)

    lcr3(PADDR(kern_pgdir));
f0103292:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103297:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010329c:	77 15                	ja     f01032b3 <env_create+0x10a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010329e:	50                   	push   %eax
f010329f:	68 24 55 10 f0       	push   $0xf0105524
f01032a4:	68 7f 01 00 00       	push   $0x17f
f01032a9:	68 7e 61 10 f0       	push   $0xf010617e
f01032ae:	e8 1f ce ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01032b3:	05 00 00 00 10       	add    $0x10000000,%eax
f01032b8:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f01032bb:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01032c0:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01032c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032c8:	e8 a7 fb ff ff       	call   f0102e74 <region_alloc>
    int r = env_alloc(&e, 0);
    if (r < 0) {
        panic("env_create: %e\n", r);
    }
    load_icode(e, binary, size);
    e->env_type = type;
f01032cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032d0:	8b 55 10             	mov    0x10(%ebp),%edx
f01032d3:	89 50 50             	mov    %edx,0x50(%eax)
    // cprintf("env_create out\n");
    return;
}
f01032d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032d9:	5b                   	pop    %ebx
f01032da:	5e                   	pop    %esi
f01032db:	5f                   	pop    %edi
f01032dc:	c9                   	leave  
f01032dd:	c3                   	ret    

f01032de <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01032de:	55                   	push   %ebp
f01032df:	89 e5                	mov    %esp,%ebp
f01032e1:	57                   	push   %edi
f01032e2:	56                   	push   %esi
f01032e3:	53                   	push   %ebx
f01032e4:	83 ec 1c             	sub    $0x1c,%esp
f01032e7:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01032ea:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f01032ef:	39 c7                	cmp    %eax,%edi
f01032f1:	75 2c                	jne    f010331f <env_free+0x41>
		lcr3(PADDR(kern_pgdir));
f01032f3:	8b 15 48 11 1e f0    	mov    0xf01e1148,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032f9:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01032ff:	77 15                	ja     f0103316 <env_free+0x38>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103301:	52                   	push   %edx
f0103302:	68 24 55 10 f0       	push   $0xf0105524
f0103307:	68 ae 01 00 00       	push   $0x1ae
f010330c:	68 7e 61 10 f0       	push   $0xf010617e
f0103311:	e8 bc cd ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103316:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010331c:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010331f:	8b 4f 48             	mov    0x48(%edi),%ecx
f0103322:	ba 00 00 00 00       	mov    $0x0,%edx
f0103327:	85 c0                	test   %eax,%eax
f0103329:	74 03                	je     f010332e <env_free+0x50>
f010332b:	8b 50 48             	mov    0x48(%eax),%edx
f010332e:	83 ec 04             	sub    $0x4,%esp
f0103331:	51                   	push   %ecx
f0103332:	52                   	push   %edx
f0103333:	68 e9 61 10 f0       	push   $0xf01061e9
f0103338:	e8 74 02 00 00       	call   f01035b1 <cprintf>
f010333d:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103340:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103347:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010334a:	c1 e0 02             	shl    $0x2,%eax
f010334d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103350:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103353:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103356:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103359:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010335f:	0f 84 ab 00 00 00    	je     f0103410 <env_free+0x132>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103365:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010336b:	89 f0                	mov    %esi,%eax
f010336d:	c1 e8 0c             	shr    $0xc,%eax
f0103370:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103373:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f0103379:	72 15                	jb     f0103390 <env_free+0xb2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010337b:	56                   	push   %esi
f010337c:	68 f8 56 10 f0       	push   $0xf01056f8
f0103381:	68 bd 01 00 00       	push   $0x1bd
f0103386:	68 7e 61 10 f0       	push   $0xf010617e
f010338b:	e8 42 cd ff ff       	call   f01000d2 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103390:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103393:	c1 e2 16             	shl    $0x16,%edx
f0103396:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103399:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010339e:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01033a5:	01 
f01033a6:	74 17                	je     f01033bf <env_free+0xe1>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01033a8:	83 ec 08             	sub    $0x8,%esp
f01033ab:	89 d8                	mov    %ebx,%eax
f01033ad:	c1 e0 0c             	shl    $0xc,%eax
f01033b0:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01033b3:	50                   	push   %eax
f01033b4:	ff 77 5c             	pushl  0x5c(%edi)
f01033b7:	e8 b3 e2 ff ff       	call   f010166f <page_remove>
f01033bc:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01033bf:	43                   	inc    %ebx
f01033c0:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01033c6:	75 d6                	jne    f010339e <env_free+0xc0>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01033c8:	8b 47 5c             	mov    0x5c(%edi),%eax
f01033cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01033ce:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01033d8:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f01033de:	72 14                	jb     f01033f4 <env_free+0x116>
		panic("pa2page called with invalid pa");
f01033e0:	83 ec 04             	sub    $0x4,%esp
f01033e3:	68 e0 57 10 f0       	push   $0xf01057e0
f01033e8:	6a 4f                	push   $0x4f
f01033ea:	68 65 5e 10 f0       	push   $0xf0105e65
f01033ef:	e8 de cc ff ff       	call   f01000d2 <_panic>
		page_decref(pa2page(pa));
f01033f4:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01033f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01033fa:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0103401:	03 05 4c 11 1e f0    	add    0xf01e114c,%eax
f0103407:	50                   	push   %eax
f0103408:	e8 eb e0 ff ff       	call   f01014f8 <page_decref>
f010340d:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103410:	ff 45 e0             	incl   -0x20(%ebp)
f0103413:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f010341a:	0f 85 27 ff ff ff    	jne    f0103347 <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103420:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103423:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103428:	77 15                	ja     f010343f <env_free+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010342a:	50                   	push   %eax
f010342b:	68 24 55 10 f0       	push   $0xf0105524
f0103430:	68 cb 01 00 00       	push   $0x1cb
f0103435:	68 7e 61 10 f0       	push   $0xf010617e
f010343a:	e8 93 cc ff ff       	call   f01000d2 <_panic>
	e->env_pgdir = 0;
f010343f:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103446:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010344b:	c1 e8 0c             	shr    $0xc,%eax
f010344e:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f0103454:	72 14                	jb     f010346a <env_free+0x18c>
		panic("pa2page called with invalid pa");
f0103456:	83 ec 04             	sub    $0x4,%esp
f0103459:	68 e0 57 10 f0       	push   $0xf01057e0
f010345e:	6a 4f                	push   $0x4f
f0103460:	68 65 5e 10 f0       	push   $0xf0105e65
f0103465:	e8 68 cc ff ff       	call   f01000d2 <_panic>
	page_decref(pa2page(pa));
f010346a:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010346d:	c1 e0 03             	shl    $0x3,%eax
f0103470:	03 05 4c 11 1e f0    	add    0xf01e114c,%eax
f0103476:	50                   	push   %eax
f0103477:	e8 7c e0 ff ff       	call   f01014f8 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010347c:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103483:	a1 84 04 1e f0       	mov    0xf01e0484,%eax
f0103488:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010348b:	89 3d 84 04 1e f0    	mov    %edi,0xf01e0484
f0103491:	83 c4 10             	add    $0x10,%esp
}
f0103494:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103497:	5b                   	pop    %ebx
f0103498:	5e                   	pop    %esi
f0103499:	5f                   	pop    %edi
f010349a:	c9                   	leave  
f010349b:	c3                   	ret    

f010349c <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f010349c:	55                   	push   %ebp
f010349d:	89 e5                	mov    %esp,%ebp
f010349f:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f01034a2:	ff 75 08             	pushl  0x8(%ebp)
f01034a5:	e8 34 fe ff ff       	call   f01032de <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01034aa:	c7 04 24 48 61 10 f0 	movl   $0xf0106148,(%esp)
f01034b1:	e8 fb 00 00 00       	call   f01035b1 <cprintf>
f01034b6:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f01034b9:	83 ec 0c             	sub    $0xc,%esp
f01034bc:	6a 00                	push   $0x0
f01034be:	e8 24 da ff ff       	call   f0100ee7 <monitor>
f01034c3:	83 c4 10             	add    $0x10,%esp
f01034c6:	eb f1                	jmp    f01034b9 <env_destroy+0x1d>

f01034c8 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01034c8:	55                   	push   %ebp
f01034c9:	89 e5                	mov    %esp,%ebp
f01034cb:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f01034ce:	8b 65 08             	mov    0x8(%ebp),%esp
f01034d1:	61                   	popa   
f01034d2:	07                   	pop    %es
f01034d3:	1f                   	pop    %ds
f01034d4:	83 c4 08             	add    $0x8,%esp
f01034d7:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01034d8:	68 ff 61 10 f0       	push   $0xf01061ff
f01034dd:	68 f3 01 00 00       	push   $0x1f3
f01034e2:	68 7e 61 10 f0       	push   $0xf010617e
f01034e7:	e8 e6 cb ff ff       	call   f01000d2 <_panic>

f01034ec <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01034ec:	55                   	push   %ebp
f01034ed:	89 e5                	mov    %esp,%ebp
f01034ef:	83 ec 08             	sub    $0x8,%esp
f01034f2:	8b 45 08             	mov    0x8(%ebp),%eax
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

    if (curenv != NULL) {
f01034f5:	8b 15 80 04 1e f0    	mov    0xf01e0480,%edx
f01034fb:	85 d2                	test   %edx,%edx
f01034fd:	74 0d                	je     f010350c <env_run+0x20>
        // context switch
        if (curenv->env_status == ENV_RUNNING) {
f01034ff:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103503:	75 07                	jne    f010350c <env_run+0x20>
            curenv->env_status = ENV_RUNNABLE;
f0103505:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
        }
        // how about other env_status ? e.g. like ENV_DYING ?
    }
    curenv = e;
f010350c:	a3 80 04 1e f0       	mov    %eax,0xf01e0480
    curenv->env_status = ENV_RUNNING;
f0103511:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f0103518:	ff 40 58             	incl   0x58(%eax)
    
    // may have some problem, because lcr3(x), x should be physical address
    lcr3(PADDR(curenv->env_pgdir));
f010351b:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010351e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103524:	77 15                	ja     f010353b <env_run+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103526:	52                   	push   %edx
f0103527:	68 24 55 10 f0       	push   $0xf0105524
f010352c:	68 1e 02 00 00       	push   $0x21e
f0103531:	68 7e 61 10 f0       	push   $0xf010617e
f0103536:	e8 97 cb ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010353b:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103541:	0f 22 da             	mov    %edx,%cr3

    env_pop_tf(&curenv->env_tf);    
f0103544:	83 ec 0c             	sub    $0xc,%esp
f0103547:	50                   	push   %eax
f0103548:	e8 7b ff ff ff       	call   f01034c8 <env_pop_tf>
f010354d:	00 00                	add    %al,(%eax)
	...

f0103550 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103550:	55                   	push   %ebp
f0103551:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103553:	ba 70 00 00 00       	mov    $0x70,%edx
f0103558:	8b 45 08             	mov    0x8(%ebp),%eax
f010355b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010355c:	b2 71                	mov    $0x71,%dl
f010355e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010355f:	0f b6 c0             	movzbl %al,%eax
}
f0103562:	c9                   	leave  
f0103563:	c3                   	ret    

f0103564 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103564:	55                   	push   %ebp
f0103565:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103567:	ba 70 00 00 00       	mov    $0x70,%edx
f010356c:	8b 45 08             	mov    0x8(%ebp),%eax
f010356f:	ee                   	out    %al,(%dx)
f0103570:	b2 71                	mov    $0x71,%dl
f0103572:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103575:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103576:	c9                   	leave  
f0103577:	c3                   	ret    

f0103578 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103578:	55                   	push   %ebp
f0103579:	89 e5                	mov    %esp,%ebp
f010357b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010357e:	ff 75 08             	pushl  0x8(%ebp)
f0103581:	e8 68 d0 ff ff       	call   f01005ee <cputchar>
f0103586:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0103589:	c9                   	leave  
f010358a:	c3                   	ret    

f010358b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010358b:	55                   	push   %ebp
f010358c:	89 e5                	mov    %esp,%ebp
f010358e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103591:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103598:	ff 75 0c             	pushl  0xc(%ebp)
f010359b:	ff 75 08             	pushl  0x8(%ebp)
f010359e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01035a1:	50                   	push   %eax
f01035a2:	68 78 35 10 f0       	push   $0xf0103578
f01035a7:	e8 a1 0b 00 00       	call   f010414d <vprintfmt>
	return cnt;
}
f01035ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01035af:	c9                   	leave  
f01035b0:	c3                   	ret    

f01035b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01035b1:	55                   	push   %ebp
f01035b2:	89 e5                	mov    %esp,%ebp
f01035b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01035b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01035ba:	50                   	push   %eax
f01035bb:	ff 75 08             	pushl  0x8(%ebp)
f01035be:	e8 c8 ff ff ff       	call   f010358b <vcprintf>
	va_end(ap);

	return cnt;
}
f01035c3:	c9                   	leave  
f01035c4:	c3                   	ret    
f01035c5:	00 00                	add    %al,(%eax)
	...

f01035c8 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01035c8:	55                   	push   %ebp
f01035c9:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f01035cb:	c7 05 c4 0c 1e f0 00 	movl   $0xf0000000,0xf01e0cc4
f01035d2:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f01035d5:	66 c7 05 c8 0c 1e f0 	movw   $0x10,0xf01e0cc8
f01035dc:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f01035de:	66 c7 05 28 33 12 f0 	movw   $0x68,0xf0123328
f01035e5:	68 00 
f01035e7:	b8 c0 0c 1e f0       	mov    $0xf01e0cc0,%eax
f01035ec:	66 a3 2a 33 12 f0    	mov    %ax,0xf012332a
f01035f2:	89 c2                	mov    %eax,%edx
f01035f4:	c1 ea 10             	shr    $0x10,%edx
f01035f7:	88 15 2c 33 12 f0    	mov    %dl,0xf012332c
f01035fd:	c6 05 2e 33 12 f0 40 	movb   $0x40,0xf012332e
f0103604:	c1 e8 18             	shr    $0x18,%eax
f0103607:	a2 2f 33 12 f0       	mov    %al,0xf012332f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f010360c:	c6 05 2d 33 12 f0 89 	movb   $0x89,0xf012332d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103613:	b8 28 00 00 00       	mov    $0x28,%eax
f0103618:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f010361b:	b8 38 33 12 f0       	mov    $0xf0123338,%eax
f0103620:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103623:	c9                   	leave  
f0103624:	c3                   	ret    

f0103625 <trap_init>:
}


void
trap_init(void)
{
f0103625:	55                   	push   %ebp
f0103626:	89 e5                	mov    %esp,%ebp
f0103628:	ba 01 00 00 00       	mov    $0x1,%edx
f010362d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103632:	eb 02                	jmp    f0103636 <trap_init+0x11>
f0103634:	40                   	inc    %eax
f0103635:	42                   	inc    %edx
    
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
    	if (i == T_BRKPT) {
f0103636:	83 f8 03             	cmp    $0x3,%eax
f0103639:	75 30                	jne    f010366b <trap_init+0x46>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
f010363b:	8b 0d 4c 33 12 f0    	mov    0xf012334c,%ecx
f0103641:	66 89 0d b8 04 1e f0 	mov    %cx,0xf01e04b8
f0103648:	66 c7 05 ba 04 1e f0 	movw   $0x8,0xf01e04ba
f010364f:	08 00 
f0103651:	c6 05 bc 04 1e f0 00 	movb   $0x0,0xf01e04bc
f0103658:	c6 05 bd 04 1e f0 ee 	movb   $0xee,0xf01e04bd
f010365f:	c1 e9 10             	shr    $0x10,%ecx
f0103662:	66 89 0d be 04 1e f0 	mov    %cx,0xf01e04be
f0103669:	eb c9                	jmp    f0103634 <trap_init+0xf>
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f010366b:	8b 0c 85 40 33 12 f0 	mov    -0xfedccc0(,%eax,4),%ecx
f0103672:	66 89 0c c5 a0 04 1e 	mov    %cx,-0xfe1fb60(,%eax,8)
f0103679:	f0 
f010367a:	66 c7 04 c5 a2 04 1e 	movw   $0x8,-0xfe1fb5e(,%eax,8)
f0103681:	f0 08 00 
f0103684:	c6 04 c5 a4 04 1e f0 	movb   $0x0,-0xfe1fb5c(,%eax,8)
f010368b:	00 
f010368c:	c6 04 c5 a5 04 1e f0 	movb   $0x8e,-0xfe1fb5b(,%eax,8)
f0103693:	8e 
f0103694:	c1 e9 10             	shr    $0x10,%ecx
f0103697:	66 89 0c c5 a6 04 1e 	mov    %cx,-0xfe1fb5a(,%eax,8)
f010369e:	f0 
    */
    
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
f010369f:	83 fa 14             	cmp    $0x14,%edx
f01036a2:	75 90                	jne    f0103634 <trap_init+0xf>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
    	}
    }
    SETGATE(idt[48], 0, GD_KT, vec48, 3);
f01036a4:	b8 90 33 12 f0       	mov    $0xf0123390,%eax
f01036a9:	66 a3 20 06 1e f0    	mov    %ax,0xf01e0620
f01036af:	66 c7 05 22 06 1e f0 	movw   $0x8,0xf01e0622
f01036b6:	08 00 
f01036b8:	c6 05 24 06 1e f0 00 	movb   $0x0,0xf01e0624
f01036bf:	c6 05 25 06 1e f0 ee 	movb   $0xee,0xf01e0625
f01036c6:	c1 e8 10             	shr    $0x10,%eax
f01036c9:	66 a3 26 06 1e f0    	mov    %ax,0xf01e0626

	// Per-CPU setup 
	trap_init_percpu();
f01036cf:	e8 f4 fe ff ff       	call   f01035c8 <trap_init_percpu>
}
f01036d4:	c9                   	leave  
f01036d5:	c3                   	ret    

f01036d6 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01036d6:	55                   	push   %ebp
f01036d7:	89 e5                	mov    %esp,%ebp
f01036d9:	53                   	push   %ebx
f01036da:	83 ec 0c             	sub    $0xc,%esp
f01036dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01036e0:	ff 33                	pushl  (%ebx)
f01036e2:	68 0b 62 10 f0       	push   $0xf010620b
f01036e7:	e8 c5 fe ff ff       	call   f01035b1 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01036ec:	83 c4 08             	add    $0x8,%esp
f01036ef:	ff 73 04             	pushl  0x4(%ebx)
f01036f2:	68 1a 62 10 f0       	push   $0xf010621a
f01036f7:	e8 b5 fe ff ff       	call   f01035b1 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01036fc:	83 c4 08             	add    $0x8,%esp
f01036ff:	ff 73 08             	pushl  0x8(%ebx)
f0103702:	68 29 62 10 f0       	push   $0xf0106229
f0103707:	e8 a5 fe ff ff       	call   f01035b1 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010370c:	83 c4 08             	add    $0x8,%esp
f010370f:	ff 73 0c             	pushl  0xc(%ebx)
f0103712:	68 38 62 10 f0       	push   $0xf0106238
f0103717:	e8 95 fe ff ff       	call   f01035b1 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010371c:	83 c4 08             	add    $0x8,%esp
f010371f:	ff 73 10             	pushl  0x10(%ebx)
f0103722:	68 47 62 10 f0       	push   $0xf0106247
f0103727:	e8 85 fe ff ff       	call   f01035b1 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010372c:	83 c4 08             	add    $0x8,%esp
f010372f:	ff 73 14             	pushl  0x14(%ebx)
f0103732:	68 56 62 10 f0       	push   $0xf0106256
f0103737:	e8 75 fe ff ff       	call   f01035b1 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010373c:	83 c4 08             	add    $0x8,%esp
f010373f:	ff 73 18             	pushl  0x18(%ebx)
f0103742:	68 65 62 10 f0       	push   $0xf0106265
f0103747:	e8 65 fe ff ff       	call   f01035b1 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010374c:	83 c4 08             	add    $0x8,%esp
f010374f:	ff 73 1c             	pushl  0x1c(%ebx)
f0103752:	68 74 62 10 f0       	push   $0xf0106274
f0103757:	e8 55 fe ff ff       	call   f01035b1 <cprintf>
f010375c:	83 c4 10             	add    $0x10,%esp
}
f010375f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103762:	c9                   	leave  
f0103763:	c3                   	ret    

f0103764 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103764:	55                   	push   %ebp
f0103765:	89 e5                	mov    %esp,%ebp
f0103767:	53                   	push   %ebx
f0103768:	83 ec 0c             	sub    $0xc,%esp
f010376b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f010376e:	53                   	push   %ebx
f010376f:	68 aa 63 10 f0       	push   $0xf01063aa
f0103774:	e8 38 fe ff ff       	call   f01035b1 <cprintf>
	print_regs(&tf->tf_regs);
f0103779:	89 1c 24             	mov    %ebx,(%esp)
f010377c:	e8 55 ff ff ff       	call   f01036d6 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103781:	83 c4 08             	add    $0x8,%esp
f0103784:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103788:	50                   	push   %eax
f0103789:	68 c5 62 10 f0       	push   $0xf01062c5
f010378e:	e8 1e fe ff ff       	call   f01035b1 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103793:	83 c4 08             	add    $0x8,%esp
f0103796:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010379a:	50                   	push   %eax
f010379b:	68 d8 62 10 f0       	push   $0xf01062d8
f01037a0:	e8 0c fe ff ff       	call   f01035b1 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01037a5:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01037a8:	83 c4 10             	add    $0x10,%esp
f01037ab:	83 f8 13             	cmp    $0x13,%eax
f01037ae:	77 09                	ja     f01037b9 <print_trapframe+0x55>
		return excnames[trapno];
f01037b0:	8b 14 85 c0 65 10 f0 	mov    -0xfef9a40(,%eax,4),%edx
f01037b7:	eb 11                	jmp    f01037ca <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
f01037b9:	83 f8 30             	cmp    $0x30,%eax
f01037bc:	75 07                	jne    f01037c5 <print_trapframe+0x61>
		return "System call";
f01037be:	ba 83 62 10 f0       	mov    $0xf0106283,%edx
f01037c3:	eb 05                	jmp    f01037ca <print_trapframe+0x66>
	return "(unknown trap)";
f01037c5:	ba 8f 62 10 f0       	mov    $0xf010628f,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01037ca:	83 ec 04             	sub    $0x4,%esp
f01037cd:	52                   	push   %edx
f01037ce:	50                   	push   %eax
f01037cf:	68 eb 62 10 f0       	push   $0xf01062eb
f01037d4:	e8 d8 fd ff ff       	call   f01035b1 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01037d9:	83 c4 10             	add    $0x10,%esp
f01037dc:	3b 1d a0 0c 1e f0    	cmp    0xf01e0ca0,%ebx
f01037e2:	75 1a                	jne    f01037fe <print_trapframe+0x9a>
f01037e4:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01037e8:	75 14                	jne    f01037fe <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01037ea:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01037ed:	83 ec 08             	sub    $0x8,%esp
f01037f0:	50                   	push   %eax
f01037f1:	68 fd 62 10 f0       	push   $0xf01062fd
f01037f6:	e8 b6 fd ff ff       	call   f01035b1 <cprintf>
f01037fb:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01037fe:	83 ec 08             	sub    $0x8,%esp
f0103801:	ff 73 2c             	pushl  0x2c(%ebx)
f0103804:	68 0c 63 10 f0       	push   $0xf010630c
f0103809:	e8 a3 fd ff ff       	call   f01035b1 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010380e:	83 c4 10             	add    $0x10,%esp
f0103811:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103815:	75 45                	jne    f010385c <print_trapframe+0xf8>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103817:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010381a:	a8 01                	test   $0x1,%al
f010381c:	74 07                	je     f0103825 <print_trapframe+0xc1>
f010381e:	b9 9e 62 10 f0       	mov    $0xf010629e,%ecx
f0103823:	eb 05                	jmp    f010382a <print_trapframe+0xc6>
f0103825:	b9 a9 62 10 f0       	mov    $0xf01062a9,%ecx
f010382a:	a8 02                	test   $0x2,%al
f010382c:	74 07                	je     f0103835 <print_trapframe+0xd1>
f010382e:	ba b5 62 10 f0       	mov    $0xf01062b5,%edx
f0103833:	eb 05                	jmp    f010383a <print_trapframe+0xd6>
f0103835:	ba bb 62 10 f0       	mov    $0xf01062bb,%edx
f010383a:	a8 04                	test   $0x4,%al
f010383c:	74 07                	je     f0103845 <print_trapframe+0xe1>
f010383e:	b8 c0 62 10 f0       	mov    $0xf01062c0,%eax
f0103843:	eb 05                	jmp    f010384a <print_trapframe+0xe6>
f0103845:	b8 f9 63 10 f0       	mov    $0xf01063f9,%eax
f010384a:	51                   	push   %ecx
f010384b:	52                   	push   %edx
f010384c:	50                   	push   %eax
f010384d:	68 1a 63 10 f0       	push   $0xf010631a
f0103852:	e8 5a fd ff ff       	call   f01035b1 <cprintf>
f0103857:	83 c4 10             	add    $0x10,%esp
f010385a:	eb 10                	jmp    f010386c <print_trapframe+0x108>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010385c:	83 ec 0c             	sub    $0xc,%esp
f010385f:	68 4c 4f 10 f0       	push   $0xf0104f4c
f0103864:	e8 48 fd ff ff       	call   f01035b1 <cprintf>
f0103869:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010386c:	83 ec 08             	sub    $0x8,%esp
f010386f:	ff 73 30             	pushl  0x30(%ebx)
f0103872:	68 29 63 10 f0       	push   $0xf0106329
f0103877:	e8 35 fd ff ff       	call   f01035b1 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010387c:	83 c4 08             	add    $0x8,%esp
f010387f:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103883:	50                   	push   %eax
f0103884:	68 38 63 10 f0       	push   $0xf0106338
f0103889:	e8 23 fd ff ff       	call   f01035b1 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010388e:	83 c4 08             	add    $0x8,%esp
f0103891:	ff 73 38             	pushl  0x38(%ebx)
f0103894:	68 4b 63 10 f0       	push   $0xf010634b
f0103899:	e8 13 fd ff ff       	call   f01035b1 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010389e:	83 c4 10             	add    $0x10,%esp
f01038a1:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01038a5:	74 25                	je     f01038cc <print_trapframe+0x168>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01038a7:	83 ec 08             	sub    $0x8,%esp
f01038aa:	ff 73 3c             	pushl  0x3c(%ebx)
f01038ad:	68 5a 63 10 f0       	push   $0xf010635a
f01038b2:	e8 fa fc ff ff       	call   f01035b1 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01038b7:	83 c4 08             	add    $0x8,%esp
f01038ba:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01038be:	50                   	push   %eax
f01038bf:	68 69 63 10 f0       	push   $0xf0106369
f01038c4:	e8 e8 fc ff ff       	call   f01035b1 <cprintf>
f01038c9:	83 c4 10             	add    $0x10,%esp
	}
}
f01038cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038cf:	c9                   	leave  
f01038d0:	c3                   	ret    

f01038d1 <page_fault_handler>:
	env_run(curenv);
}

void
page_fault_handler(struct Trapframe *tf)
{
f01038d1:	55                   	push   %ebp
f01038d2:	89 e5                	mov    %esp,%ebp
f01038d4:	53                   	push   %ebx
f01038d5:	83 ec 04             	sub    $0x4,%esp
f01038d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01038db:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f01038de:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01038e2:	75 17                	jne    f01038fb <page_fault_handler+0x2a>
    	panic("page_fault_handler : page fault in kernel\n");
f01038e4:	83 ec 04             	sub    $0x4,%esp
f01038e7:	68 44 65 10 f0       	push   $0xf0106544
f01038ec:	68 1c 01 00 00       	push   $0x11c
f01038f1:	68 7c 63 10 f0       	push   $0xf010637c
f01038f6:	e8 d7 c7 ff ff       	call   f01000d2 <_panic>
    
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01038fb:	ff 73 30             	pushl  0x30(%ebx)
f01038fe:	50                   	push   %eax
		curenv->env_id, fault_va, tf->tf_eip);
f01038ff:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
    
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103904:	ff 70 48             	pushl  0x48(%eax)
f0103907:	68 70 65 10 f0       	push   $0xf0106570
f010390c:	e8 a0 fc ff ff       	call   f01035b1 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103911:	89 1c 24             	mov    %ebx,(%esp)
f0103914:	e8 4b fe ff ff       	call   f0103764 <print_trapframe>
	env_destroy(curenv);
f0103919:	83 c4 04             	add    $0x4,%esp
f010391c:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103922:	e8 75 fb ff ff       	call   f010349c <env_destroy>
f0103927:	83 c4 10             	add    $0x10,%esp
}
f010392a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010392d:	c9                   	leave  
f010392e:	c3                   	ret    

f010392f <trap>:
    }
}

void
trap(struct Trapframe *tf)
{
f010392f:	55                   	push   %ebp
f0103930:	89 e5                	mov    %esp,%ebp
f0103932:	57                   	push   %edi
f0103933:	56                   	push   %esi
f0103934:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103937:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103938:	9c                   	pushf  
f0103939:	58                   	pop    %eax
	
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010393a:	f6 c4 02             	test   $0x2,%ah
f010393d:	74 19                	je     f0103958 <trap+0x29>
f010393f:	68 88 63 10 f0       	push   $0xf0106388
f0103944:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0103949:	68 f4 00 00 00       	push   $0xf4
f010394e:	68 7c 63 10 f0       	push   $0xf010637c
f0103953:	e8 7a c7 ff ff       	call   f01000d2 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103958:	83 ec 08             	sub    $0x8,%esp
f010395b:	56                   	push   %esi
f010395c:	68 a1 63 10 f0       	push   $0xf01063a1
f0103961:	e8 4b fc ff ff       	call   f01035b1 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103966:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010396a:	83 e0 03             	and    $0x3,%eax
f010396d:	83 c4 10             	add    $0x10,%esp
f0103970:	83 f8 03             	cmp    $0x3,%eax
f0103973:	75 31                	jne    f01039a6 <trap+0x77>
		// Trapped from user mode.
		assert(curenv);
f0103975:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f010397a:	85 c0                	test   %eax,%eax
f010397c:	75 19                	jne    f0103997 <trap+0x68>
f010397e:	68 bc 63 10 f0       	push   $0xf01063bc
f0103983:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0103988:	68 fa 00 00 00       	push   $0xfa
f010398d:	68 7c 63 10 f0       	push   $0xf010637c
f0103992:	e8 3b c7 ff ff       	call   f01000d2 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103997:	b9 11 00 00 00       	mov    $0x11,%ecx
f010399c:	89 c7                	mov    %eax,%edi
f010399e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01039a0:	8b 35 80 04 1e f0    	mov    0xf01e0480,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01039a6:	89 35 a0 0c 1e f0    	mov    %esi,0xf01e0ca0
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
    
    cprintf("TRAP NUM : %u\n", tf->tf_trapno);
f01039ac:	83 ec 08             	sub    $0x8,%esp
f01039af:	ff 76 28             	pushl  0x28(%esi)
f01039b2:	68 c3 63 10 f0       	push   $0xf01063c3
f01039b7:	e8 f5 fb ff ff       	call   f01035b1 <cprintf>

    int r;
    // cprintf("TRAPNO : %d\n", tf->tf_trapno);
    switch (tf->tf_trapno) {
f01039bc:	83 c4 10             	add    $0x10,%esp
f01039bf:	8b 46 28             	mov    0x28(%esi),%eax
f01039c2:	83 f8 03             	cmp    $0x3,%eax
f01039c5:	74 3a                	je     f0103a01 <trap+0xd2>
f01039c7:	83 f8 03             	cmp    $0x3,%eax
f01039ca:	77 07                	ja     f01039d3 <trap+0xa4>
f01039cc:	83 f8 01             	cmp    $0x1,%eax
f01039cf:	75 78                	jne    f0103a49 <trap+0x11a>
f01039d1:	eb 0c                	jmp    f01039df <trap+0xb0>
f01039d3:	83 f8 0e             	cmp    $0xe,%eax
f01039d6:	74 18                	je     f01039f0 <trap+0xc1>
f01039d8:	83 f8 30             	cmp    $0x30,%eax
f01039db:	75 6c                	jne    f0103a49 <trap+0x11a>
f01039dd:	eb 30                	jmp    f0103a0f <trap+0xe0>
    	case T_DEBUG:
    		monitor(tf);
f01039df:	83 ec 0c             	sub    $0xc,%esp
f01039e2:	56                   	push   %esi
f01039e3:	e8 ff d4 ff ff       	call   f0100ee7 <monitor>
f01039e8:	83 c4 10             	add    $0x10,%esp
f01039eb:	e9 94 00 00 00       	jmp    f0103a84 <trap+0x155>
    		break;
        case T_PGFLT:
        	page_fault_handler(tf);
f01039f0:	83 ec 0c             	sub    $0xc,%esp
f01039f3:	56                   	push   %esi
f01039f4:	e8 d8 fe ff ff       	call   f01038d1 <page_fault_handler>
f01039f9:	83 c4 10             	add    $0x10,%esp
f01039fc:	e9 83 00 00 00       	jmp    f0103a84 <trap+0x155>
            break;
        case T_BRKPT:
            monitor(tf); 
f0103a01:	83 ec 0c             	sub    $0xc,%esp
f0103a04:	56                   	push   %esi
f0103a05:	e8 dd d4 ff ff       	call   f0100ee7 <monitor>
f0103a0a:	83 c4 10             	add    $0x10,%esp
f0103a0d:	eb 75                	jmp    f0103a84 <trap+0x155>
            break;
        case T_SYSCALL:
            r = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0103a0f:	83 ec 08             	sub    $0x8,%esp
f0103a12:	ff 76 04             	pushl  0x4(%esi)
f0103a15:	ff 36                	pushl  (%esi)
f0103a17:	ff 76 10             	pushl  0x10(%esi)
f0103a1a:	ff 76 18             	pushl  0x18(%esi)
f0103a1d:	ff 76 14             	pushl  0x14(%esi)
f0103a20:	ff 76 1c             	pushl  0x1c(%esi)
f0103a23:	e8 38 01 00 00       	call   f0103b60 <syscall>
                        tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
            if (r < 0)
f0103a28:	83 c4 20             	add    $0x20,%esp
f0103a2b:	85 c0                	test   %eax,%eax
f0103a2d:	79 15                	jns    f0103a44 <trap+0x115>
                panic("trap.c/syscall : %e\n", r);
f0103a2f:	50                   	push   %eax
f0103a30:	68 d2 63 10 f0       	push   $0xf01063d2
f0103a35:	68 da 00 00 00       	push   $0xda
f0103a3a:	68 7c 63 10 f0       	push   $0xf010637c
f0103a3f:	e8 8e c6 ff ff       	call   f01000d2 <_panic>
            else
                tf->tf_regs.reg_eax = r;
f0103a44:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103a47:	eb 3b                	jmp    f0103a84 <trap+0x155>
            break;
        default:
	        // Unexpected trap: The user process or the kernel has a bug.
	        print_trapframe(tf);
f0103a49:	83 ec 0c             	sub    $0xc,%esp
f0103a4c:	56                   	push   %esi
f0103a4d:	e8 12 fd ff ff       	call   f0103764 <print_trapframe>
	        if (tf->tf_cs == GD_KT)
f0103a52:	83 c4 10             	add    $0x10,%esp
f0103a55:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103a5a:	75 17                	jne    f0103a73 <trap+0x144>
		        panic("unhandled trap in kernel");
f0103a5c:	83 ec 04             	sub    $0x4,%esp
f0103a5f:	68 e7 63 10 f0       	push   $0xf01063e7
f0103a64:	68 e2 00 00 00       	push   $0xe2
f0103a69:	68 7c 63 10 f0       	push   $0xf010637c
f0103a6e:	e8 5f c6 ff ff       	call   f01000d2 <_panic>
	        else {
		        env_destroy(curenv);
f0103a73:	83 ec 0c             	sub    $0xc,%esp
f0103a76:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103a7c:	e8 1b fa ff ff       	call   f010349c <env_destroy>
f0103a81:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103a84:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f0103a89:	85 c0                	test   %eax,%eax
f0103a8b:	74 06                	je     f0103a93 <trap+0x164>
f0103a8d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103a91:	74 19                	je     f0103aac <trap+0x17d>
f0103a93:	68 94 65 10 f0       	push   $0xf0106594
f0103a98:	68 7f 5e 10 f0       	push   $0xf0105e7f
f0103a9d:	68 0c 01 00 00       	push   $0x10c
f0103aa2:	68 7c 63 10 f0       	push   $0xf010637c
f0103aa7:	e8 26 c6 ff ff       	call   f01000d2 <_panic>
	env_run(curenv);
f0103aac:	83 ec 0c             	sub    $0xc,%esp
f0103aaf:	50                   	push   %eax
f0103ab0:	e8 37 fa ff ff       	call   f01034ec <env_run>
f0103ab5:	00 00                	add    %al,(%eax)
	...

f0103ab8 <vec0>:
.data
.align 2
.globl vectors
vectors:
.text
	MYTH_NOEC(vec0, T_DIVIDE)
f0103ab8:	6a 00                	push   $0x0
f0103aba:	6a 00                	push   $0x0
f0103abc:	e9 d5 f8 01 00       	jmp    f0123396 <_alltraps>
f0103ac1:	90                   	nop

f0103ac2 <vec1>:
 	MYTH_NOEC(vec1, T_DEBUG)
f0103ac2:	6a 00                	push   $0x0
f0103ac4:	6a 01                	push   $0x1
f0103ac6:	e9 cb f8 01 00       	jmp    f0123396 <_alltraps>
f0103acb:	90                   	nop

f0103acc <vec2>:
 	MYTH_NOEC(vec2, T_NMI)
f0103acc:	6a 00                	push   $0x0
f0103ace:	6a 02                	push   $0x2
f0103ad0:	e9 c1 f8 01 00       	jmp    f0123396 <_alltraps>
f0103ad5:	90                   	nop

f0103ad6 <vec3>:
 	MYTH_NOEC(vec3, T_BRKPT)
f0103ad6:	6a 00                	push   $0x0
f0103ad8:	6a 03                	push   $0x3
f0103ada:	e9 b7 f8 01 00       	jmp    f0123396 <_alltraps>
f0103adf:	90                   	nop

f0103ae0 <vec4>:
 	MYTH_NOEC(vec4, T_OFLOW)
f0103ae0:	6a 00                	push   $0x0
f0103ae2:	6a 04                	push   $0x4
f0103ae4:	e9 ad f8 01 00       	jmp    f0123396 <_alltraps>
f0103ae9:	90                   	nop

f0103aea <vec5>:
 	MYTH_NOEC(vec5, T_BOUND)
f0103aea:	6a 00                	push   $0x0
f0103aec:	6a 05                	push   $0x5
f0103aee:	e9 a3 f8 01 00       	jmp    f0123396 <_alltraps>
f0103af3:	90                   	nop

f0103af4 <vec6>:
 	MYTH_NOEC(vec6, T_ILLOP)
f0103af4:	6a 00                	push   $0x0
f0103af6:	6a 06                	push   $0x6
f0103af8:	e9 99 f8 01 00       	jmp    f0123396 <_alltraps>
f0103afd:	90                   	nop

f0103afe <vec7>:
	MYTH_NOEC(vec7, T_DEVICE)
f0103afe:	6a 00                	push   $0x0
f0103b00:	6a 07                	push   $0x7
f0103b02:	e9 8f f8 01 00       	jmp    f0123396 <_alltraps>
f0103b07:	90                   	nop

f0103b08 <vec8>:
 	MYTH(vec8, T_DBLFLT)
f0103b08:	6a 08                	push   $0x8
f0103b0a:	e9 87 f8 01 00       	jmp    f0123396 <_alltraps>
f0103b0f:	90                   	nop

f0103b10 <vec10>:
 	MYTH_NULL()
 	MYTH(vec10, T_TSS)
f0103b10:	6a 0a                	push   $0xa
f0103b12:	e9 7f f8 01 00       	jmp    f0123396 <_alltraps>
f0103b17:	90                   	nop

f0103b18 <vec11>:
 	MYTH(vec11, T_SEGNP)
f0103b18:	6a 0b                	push   $0xb
f0103b1a:	e9 77 f8 01 00       	jmp    f0123396 <_alltraps>
f0103b1f:	90                   	nop

f0103b20 <vec12>:
 	MYTH(vec12, T_STACK)
f0103b20:	6a 0c                	push   $0xc
f0103b22:	e9 6f f8 01 00       	jmp    f0123396 <_alltraps>
f0103b27:	90                   	nop

f0103b28 <vec13>:
 	MYTH(vec13, T_GPFLT)
f0103b28:	6a 0d                	push   $0xd
f0103b2a:	e9 67 f8 01 00       	jmp    f0123396 <_alltraps>
f0103b2f:	90                   	nop

f0103b30 <vec14>:
 	MYTH(vec14, T_PGFLT) 
f0103b30:	6a 0e                	push   $0xe
f0103b32:	e9 5f f8 01 00       	jmp    f0123396 <_alltraps>
f0103b37:	90                   	nop

f0103b38 <vec16>:
 	MYTH_NULL()
 	MYTH_NOEC(vec16, T_FPERR)
f0103b38:	6a 00                	push   $0x0
f0103b3a:	6a 10                	push   $0x10
f0103b3c:	e9 55 f8 01 00       	jmp    f0123396 <_alltraps>
f0103b41:	90                   	nop

f0103b42 <vec17>:
 	MYTH(vec17, T_ALIGN)
f0103b42:	6a 11                	push   $0x11
f0103b44:	e9 4d f8 01 00       	jmp    f0123396 <_alltraps>
f0103b49:	90                   	nop

f0103b4a <vec18>:
 	MYTH_NOEC(vec18, T_MCHK)
f0103b4a:	6a 00                	push   $0x0
f0103b4c:	6a 12                	push   $0x12
f0103b4e:	e9 43 f8 01 00       	jmp    f0123396 <_alltraps>
f0103b53:	90                   	nop

f0103b54 <vec19>:
 	MYTH_NOEC(vec19, T_SIMDERR)
f0103b54:	6a 00                	push   $0x0
f0103b56:	6a 13                	push   $0x13
f0103b58:	e9 39 f8 01 00       	jmp    f0123396 <_alltraps>
f0103b5d:	00 00                	add    %al,(%eax)
	...

f0103b60 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103b60:	55                   	push   %ebp
f0103b61:	89 e5                	mov    %esp,%ebp
f0103b63:	56                   	push   %esi
f0103b64:	53                   	push   %ebx
f0103b65:	83 ec 10             	sub    $0x10,%esp
f0103b68:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b6b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103b6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
    
    switch (syscallno) {
f0103b71:	83 f8 01             	cmp    $0x1,%eax
f0103b74:	74 40                	je     f0103bb6 <syscall+0x56>
f0103b76:	83 f8 01             	cmp    $0x1,%eax
f0103b79:	72 10                	jb     f0103b8b <syscall+0x2b>
f0103b7b:	83 f8 02             	cmp    $0x2,%eax
f0103b7e:	74 40                	je     f0103bc0 <syscall+0x60>
f0103b80:	83 f8 03             	cmp    $0x3,%eax
f0103b83:	0f 85 a4 00 00 00    	jne    f0103c2d <syscall+0xcd>
f0103b89:	eb 3f                	jmp    f0103bca <syscall+0x6a>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, (void *)s, len, PTE_U);
f0103b8b:	6a 04                	push   $0x4
f0103b8d:	53                   	push   %ebx
f0103b8e:	56                   	push   %esi
f0103b8f:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103b95:	e8 90 f2 ff ff       	call   f0102e2a <user_mem_assert>
    
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103b9a:	83 c4 0c             	add    $0xc,%esp
f0103b9d:	56                   	push   %esi
f0103b9e:	53                   	push   %ebx
f0103b9f:	68 c2 4f 10 f0       	push   $0xf0104fc2
f0103ba4:	e8 08 fa ff ff       	call   f01035b1 <cprintf>
f0103ba9:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
    
    switch (syscallno) {
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
f0103bac:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bb1:	e9 8b 00 00 00       	jmp    f0103c41 <syscall+0xe1>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103bb6:	e8 0d c9 ff ff       	call   f01004c8 <cons_getc>
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
            break;
        case SYS_cgetc:
            return sys_cgetc();
f0103bbb:	e9 81 00 00 00       	jmp    f0103c41 <syscall+0xe1>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103bc0:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f0103bc5:	8b 40 48             	mov    0x48(%eax),%eax
            break;
        case SYS_cgetc:
            return sys_cgetc();
            break;
        case SYS_getenvid:
            return sys_getenvid();
f0103bc8:	eb 77                	jmp    f0103c41 <syscall+0xe1>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103bca:	83 ec 04             	sub    $0x4,%esp
f0103bcd:	6a 01                	push   $0x1
f0103bcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103bd2:	50                   	push   %eax
f0103bd3:	56                   	push   %esi
f0103bd4:	e8 21 f3 ff ff       	call   f0102efa <envid2env>
f0103bd9:	83 c4 10             	add    $0x10,%esp
f0103bdc:	85 c0                	test   %eax,%eax
f0103bde:	78 61                	js     f0103c41 <syscall+0xe1>
		return r;
	if (e == curenv)
f0103be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103be3:	8b 15 80 04 1e f0    	mov    0xf01e0480,%edx
f0103be9:	39 d0                	cmp    %edx,%eax
f0103beb:	75 15                	jne    f0103c02 <syscall+0xa2>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103bed:	83 ec 08             	sub    $0x8,%esp
f0103bf0:	ff 70 48             	pushl  0x48(%eax)
f0103bf3:	68 10 66 10 f0       	push   $0xf0106610
f0103bf8:	e8 b4 f9 ff ff       	call   f01035b1 <cprintf>
f0103bfd:	83 c4 10             	add    $0x10,%esp
f0103c00:	eb 16                	jmp    f0103c18 <syscall+0xb8>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103c02:	83 ec 04             	sub    $0x4,%esp
f0103c05:	ff 70 48             	pushl  0x48(%eax)
f0103c08:	ff 72 48             	pushl  0x48(%edx)
f0103c0b:	68 2b 66 10 f0       	push   $0xf010662b
f0103c10:	e8 9c f9 ff ff       	call   f01035b1 <cprintf>
f0103c15:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103c18:	83 ec 0c             	sub    $0xc,%esp
f0103c1b:	ff 75 f4             	pushl  -0xc(%ebp)
f0103c1e:	e8 79 f8 ff ff       	call   f010349c <env_destroy>
f0103c23:	83 c4 10             	add    $0x10,%esp
	return 0;
f0103c26:	b8 00 00 00 00       	mov    $0x0,%eax
            break;
        case SYS_getenvid:
            return sys_getenvid();
            break;
        case SYS_env_destroy:
            return sys_env_destroy(a1);
f0103c2b:	eb 14                	jmp    f0103c41 <syscall+0xe1>
            break;
        dafult:
            return -E_INVAL;
	}
    panic("syscall not implemented");
f0103c2d:	83 ec 04             	sub    $0x4,%esp
f0103c30:	68 43 66 10 f0       	push   $0xf0106643
f0103c35:	6a 5b                	push   $0x5b
f0103c37:	68 5b 66 10 f0       	push   $0xf010665b
f0103c3c:	e8 91 c4 ff ff       	call   f01000d2 <_panic>
}
f0103c41:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103c44:	5b                   	pop    %ebx
f0103c45:	5e                   	pop    %esi
f0103c46:	c9                   	leave  
f0103c47:	c3                   	ret    

f0103c48 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103c48:	55                   	push   %ebp
f0103c49:	89 e5                	mov    %esp,%ebp
f0103c4b:	57                   	push   %edi
f0103c4c:	56                   	push   %esi
f0103c4d:	53                   	push   %ebx
f0103c4e:	83 ec 14             	sub    $0x14,%esp
f0103c51:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103c54:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103c57:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103c5a:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103c5d:	8b 1a                	mov    (%edx),%ebx
f0103c5f:	8b 01                	mov    (%ecx),%eax
f0103c61:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0103c64:	39 c3                	cmp    %eax,%ebx
f0103c66:	0f 8f 97 00 00 00    	jg     f0103d03 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0103c6c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103c73:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103c76:	01 d8                	add    %ebx,%eax
f0103c78:	89 c7                	mov    %eax,%edi
f0103c7a:	c1 ef 1f             	shr    $0x1f,%edi
f0103c7d:	01 c7                	add    %eax,%edi
f0103c7f:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103c81:	39 df                	cmp    %ebx,%edi
f0103c83:	7c 31                	jl     f0103cb6 <stab_binsearch+0x6e>
f0103c85:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103c88:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103c8b:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103c90:	39 f0                	cmp    %esi,%eax
f0103c92:	0f 84 b3 00 00 00    	je     f0103d4b <stab_binsearch+0x103>
f0103c98:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103c9c:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103ca0:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103ca2:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103ca3:	39 d8                	cmp    %ebx,%eax
f0103ca5:	7c 0f                	jl     f0103cb6 <stab_binsearch+0x6e>
f0103ca7:	0f b6 0a             	movzbl (%edx),%ecx
f0103caa:	83 ea 0c             	sub    $0xc,%edx
f0103cad:	39 f1                	cmp    %esi,%ecx
f0103caf:	75 f1                	jne    f0103ca2 <stab_binsearch+0x5a>
f0103cb1:	e9 97 00 00 00       	jmp    f0103d4d <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103cb6:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103cb9:	eb 39                	jmp    f0103cf4 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103cbb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103cbe:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0103cc0:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103cc3:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103cca:	eb 28                	jmp    f0103cf4 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103ccc:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103ccf:	76 12                	jbe    f0103ce3 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0103cd1:	48                   	dec    %eax
f0103cd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103cd5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103cd8:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103cda:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103ce1:	eb 11                	jmp    f0103cf4 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103ce3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103ce6:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103ce8:	ff 45 0c             	incl   0xc(%ebp)
f0103ceb:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103ced:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103cf4:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103cf7:	0f 8d 76 ff ff ff    	jge    f0103c73 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103cfd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103d01:	75 0d                	jne    f0103d10 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0103d03:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103d06:	8b 03                	mov    (%ebx),%eax
f0103d08:	48                   	dec    %eax
f0103d09:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103d0c:	89 02                	mov    %eax,(%edx)
f0103d0e:	eb 55                	jmp    f0103d65 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103d10:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103d13:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103d15:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103d18:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103d1a:	39 c1                	cmp    %eax,%ecx
f0103d1c:	7d 26                	jge    f0103d44 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0103d1e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103d21:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103d24:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103d29:	39 f2                	cmp    %esi,%edx
f0103d2b:	74 17                	je     f0103d44 <stab_binsearch+0xfc>
f0103d2d:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103d31:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103d35:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103d36:	39 c1                	cmp    %eax,%ecx
f0103d38:	7d 0a                	jge    f0103d44 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0103d3a:	0f b6 1a             	movzbl (%edx),%ebx
f0103d3d:	83 ea 0c             	sub    $0xc,%edx
f0103d40:	39 f3                	cmp    %esi,%ebx
f0103d42:	75 f1                	jne    f0103d35 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103d44:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103d47:	89 02                	mov    %eax,(%edx)
f0103d49:	eb 1a                	jmp    f0103d65 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103d4b:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103d4d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103d50:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103d53:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103d57:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103d5a:	0f 82 5b ff ff ff    	jb     f0103cbb <stab_binsearch+0x73>
f0103d60:	e9 67 ff ff ff       	jmp    f0103ccc <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103d65:	83 c4 14             	add    $0x14,%esp
f0103d68:	5b                   	pop    %ebx
f0103d69:	5e                   	pop    %esi
f0103d6a:	5f                   	pop    %edi
f0103d6b:	c9                   	leave  
f0103d6c:	c3                   	ret    

f0103d6d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103d6d:	55                   	push   %ebp
f0103d6e:	89 e5                	mov    %esp,%ebp
f0103d70:	57                   	push   %edi
f0103d71:	56                   	push   %esi
f0103d72:	53                   	push   %ebx
f0103d73:	83 ec 2c             	sub    $0x2c,%esp
f0103d76:	8b 75 08             	mov    0x8(%ebp),%esi
f0103d79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103d7c:	c7 03 6a 66 10 f0    	movl   $0xf010666a,(%ebx)
	info->eip_line = 0;
f0103d82:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103d89:	c7 43 08 6a 66 10 f0 	movl   $0xf010666a,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103d90:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103d97:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103d9a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103da1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103da7:	0f 87 89 00 00 00    	ja     f0103e36 <debuginfo_eip+0xc9>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
f0103dad:	6a 04                	push   $0x4
f0103daf:	6a 10                	push   $0x10
f0103db1:	68 00 00 20 00       	push   $0x200000
f0103db6:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103dbc:	e8 b6 ef ff ff       	call   f0102d77 <user_mem_check>
f0103dc1:	83 c4 10             	add    $0x10,%esp
f0103dc4:	85 c0                	test   %eax,%eax
f0103dc6:	0f 88 f2 01 00 00    	js     f0103fbe <debuginfo_eip+0x251>
			return -1;
		}
        
		stabs = usd->stabs;
f0103dcc:	a1 00 00 20 00       	mov    0x200000,%eax
f0103dd1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f0103dd4:	8b 0d 04 00 20 00    	mov    0x200004,%ecx
f0103dda:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr = usd->stabstr;
f0103ddd:	a1 08 00 20 00       	mov    0x200008,%eax
f0103de2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103de5:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
f0103deb:	6a 04                	push   $0x4
f0103ded:	89 c8                	mov    %ecx,%eax
f0103def:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0103df2:	50                   	push   %eax
f0103df3:	ff 75 d0             	pushl  -0x30(%ebp)
f0103df6:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103dfc:	e8 76 ef ff ff       	call   f0102d77 <user_mem_check>
f0103e01:	83 c4 10             	add    $0x10,%esp
f0103e04:	85 c0                	test   %eax,%eax
f0103e06:	0f 88 b9 01 00 00    	js     f0103fc5 <debuginfo_eip+0x258>
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0103e0c:	6a 04                	push   $0x4
f0103e0e:	89 f8                	mov    %edi,%eax
f0103e10:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0103e13:	50                   	push   %eax
f0103e14:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103e17:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103e1d:	e8 55 ef ff ff       	call   f0102d77 <user_mem_check>
f0103e22:	89 c2                	mov    %eax,%edx
f0103e24:	83 c4 10             	add    $0x10,%esp
			return -1;
f0103e27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0103e2c:	85 d2                	test   %edx,%edx
f0103e2e:	0f 88 ab 01 00 00    	js     f0103fdf <debuginfo_eip+0x272>
f0103e34:	eb 1a                	jmp    f0103e50 <debuginfo_eip+0xe3>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103e36:	bf fb 85 11 f0       	mov    $0xf01185fb,%edi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103e3b:	c7 45 d4 8d ff 10 f0 	movl   $0xf010ff8d,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103e42:	c7 45 cc 8c ff 10 f0 	movl   $0xf010ff8c,-0x34(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103e49:	c7 45 d0 84 68 10 f0 	movl   $0xf0106884,-0x30(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103e50:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0103e53:	0f 83 73 01 00 00    	jae    f0103fcc <debuginfo_eip+0x25f>
f0103e59:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0103e5d:	0f 85 70 01 00 00    	jne    f0103fd3 <debuginfo_eip+0x266>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103e63:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103e6a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103e6d:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0103e70:	c1 f8 02             	sar    $0x2,%eax
f0103e73:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103e79:	48                   	dec    %eax
f0103e7a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103e7d:	83 ec 08             	sub    $0x8,%esp
f0103e80:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103e83:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103e86:	56                   	push   %esi
f0103e87:	6a 64                	push   $0x64
f0103e89:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103e8c:	e8 b7 fd ff ff       	call   f0103c48 <stab_binsearch>
	if (lfile == 0)
f0103e91:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103e94:	83 c4 10             	add    $0x10,%esp
		return -1;
f0103e97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0103e9c:	85 d2                	test   %edx,%edx
f0103e9e:	0f 84 3b 01 00 00    	je     f0103fdf <debuginfo_eip+0x272>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103ea4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0103ea7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103eaa:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103ead:	83 ec 08             	sub    $0x8,%esp
f0103eb0:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103eb3:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103eb6:	56                   	push   %esi
f0103eb7:	6a 24                	push   $0x24
f0103eb9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103ebc:	e8 87 fd ff ff       	call   f0103c48 <stab_binsearch>

	if (lfun <= rfun) {
f0103ec1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103ec4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0103ec7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103eca:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103ecd:	83 c4 10             	add    $0x10,%esp
f0103ed0:	39 c1                	cmp    %eax,%ecx
f0103ed2:	7f 21                	jg     f0103ef5 <debuginfo_eip+0x188>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103ed4:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0103ed7:	03 45 d0             	add    -0x30(%ebp),%eax
f0103eda:	8b 10                	mov    (%eax),%edx
f0103edc:	89 f9                	mov    %edi,%ecx
f0103ede:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f0103ee1:	39 ca                	cmp    %ecx,%edx
f0103ee3:	73 06                	jae    f0103eeb <debuginfo_eip+0x17e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103ee5:	03 55 d4             	add    -0x2c(%ebp),%edx
f0103ee8:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103eeb:	8b 40 08             	mov    0x8(%eax),%eax
f0103eee:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103ef1:	29 c6                	sub    %eax,%esi
f0103ef3:	eb 0f                	jmp    f0103f04 <debuginfo_eip+0x197>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103ef5:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103ef8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103efb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		rline = rfile;
f0103efe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f01:	89 45 c8             	mov    %eax,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103f04:	83 ec 08             	sub    $0x8,%esp
f0103f07:	6a 3a                	push   $0x3a
f0103f09:	ff 73 08             	pushl  0x8(%ebx)
f0103f0c:	e8 b2 08 00 00       	call   f01047c3 <strfind>
f0103f11:	2b 43 08             	sub    0x8(%ebx),%eax
f0103f14:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0103f17:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103f1a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    rfun = rline;
f0103f1d:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103f20:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0103f23:	83 c4 08             	add    $0x8,%esp
f0103f26:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103f29:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103f2c:	56                   	push   %esi
f0103f2d:	6a 44                	push   $0x44
f0103f2f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103f32:	e8 11 fd ff ff       	call   f0103c48 <stab_binsearch>
    if (lfun <= rfun) {
f0103f37:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103f3a:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0103f3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0103f42:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0103f45:	0f 8f 94 00 00 00    	jg     f0103fdf <debuginfo_eip+0x272>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0103f4b:	6b ca 0c             	imul   $0xc,%edx,%ecx
f0103f4e:	03 4d d0             	add    -0x30(%ebp),%ecx
f0103f51:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f0103f55:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103f58:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103f5b:	89 75 cc             	mov    %esi,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103f5e:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103f61:	eb 04                	jmp    f0103f67 <debuginfo_eip+0x1fa>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103f63:	4a                   	dec    %edx
f0103f64:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103f67:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f0103f6a:	7c 19                	jl     f0103f85 <debuginfo_eip+0x218>
	       && stabs[lline].n_type != N_SOL
f0103f6c:	8a 48 fc             	mov    -0x4(%eax),%cl
f0103f6f:	80 f9 84             	cmp    $0x84,%cl
f0103f72:	74 73                	je     f0103fe7 <debuginfo_eip+0x27a>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103f74:	80 f9 64             	cmp    $0x64,%cl
f0103f77:	75 ea                	jne    f0103f63 <debuginfo_eip+0x1f6>
f0103f79:	83 38 00             	cmpl   $0x0,(%eax)
f0103f7c:	74 e5                	je     f0103f63 <debuginfo_eip+0x1f6>
f0103f7e:	eb 67                	jmp    f0103fe7 <debuginfo_eip+0x27a>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103f80:	03 45 d4             	add    -0x2c(%ebp),%eax
f0103f83:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103f85:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103f88:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f8b:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103f90:	39 ca                	cmp    %ecx,%edx
f0103f92:	7d 4b                	jge    f0103fdf <debuginfo_eip+0x272>
		for (lline = lfun + 1;
f0103f94:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103f97:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103f9a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103f9d:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0103fa1:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103fa3:	eb 04                	jmp    f0103fa9 <debuginfo_eip+0x23c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103fa5:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103fa8:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103fa9:	39 f0                	cmp    %esi,%eax
f0103fab:	7d 2d                	jge    f0103fda <debuginfo_eip+0x26d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103fad:	8a 0a                	mov    (%edx),%cl
f0103faf:	83 c2 0c             	add    $0xc,%edx
f0103fb2:	80 f9 a0             	cmp    $0xa0,%cl
f0103fb5:	74 ee                	je     f0103fa5 <debuginfo_eip+0x238>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103fb7:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fbc:	eb 21                	jmp    f0103fdf <debuginfo_eip+0x272>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
f0103fbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103fc3:	eb 1a                	jmp    f0103fdf <debuginfo_eip+0x272>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
f0103fc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103fca:	eb 13                	jmp    f0103fdf <debuginfo_eip+0x272>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103fcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103fd1:	eb 0c                	jmp    f0103fdf <debuginfo_eip+0x272>
f0103fd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103fd8:	eb 05                	jmp    f0103fdf <debuginfo_eip+0x272>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103fda:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103fdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103fe2:	5b                   	pop    %ebx
f0103fe3:	5e                   	pop    %esi
f0103fe4:	5f                   	pop    %edi
f0103fe5:	c9                   	leave  
f0103fe6:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103fe7:	6b d2 0c             	imul   $0xc,%edx,%edx
f0103fea:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103fed:	8b 04 16             	mov    (%esi,%edx,1),%eax
f0103ff0:	2b 7d d4             	sub    -0x2c(%ebp),%edi
f0103ff3:	39 f8                	cmp    %edi,%eax
f0103ff5:	72 89                	jb     f0103f80 <debuginfo_eip+0x213>
f0103ff7:	eb 8c                	jmp    f0103f85 <debuginfo_eip+0x218>
f0103ff9:	00 00                	add    %al,(%eax)
	...

f0103ffc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103ffc:	55                   	push   %ebp
f0103ffd:	89 e5                	mov    %esp,%ebp
f0103fff:	57                   	push   %edi
f0104000:	56                   	push   %esi
f0104001:	53                   	push   %ebx
f0104002:	83 ec 2c             	sub    $0x2c,%esp
f0104005:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104008:	89 d6                	mov    %edx,%esi
f010400a:	8b 45 08             	mov    0x8(%ebp),%eax
f010400d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104010:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104013:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104016:	8b 45 10             	mov    0x10(%ebp),%eax
f0104019:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010401c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010401f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104022:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0104029:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f010402c:	72 0c                	jb     f010403a <printnum+0x3e>
f010402e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0104031:	76 07                	jbe    f010403a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104033:	4b                   	dec    %ebx
f0104034:	85 db                	test   %ebx,%ebx
f0104036:	7f 31                	jg     f0104069 <printnum+0x6d>
f0104038:	eb 3f                	jmp    f0104079 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010403a:	83 ec 0c             	sub    $0xc,%esp
f010403d:	57                   	push   %edi
f010403e:	4b                   	dec    %ebx
f010403f:	53                   	push   %ebx
f0104040:	50                   	push   %eax
f0104041:	83 ec 08             	sub    $0x8,%esp
f0104044:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104047:	ff 75 d0             	pushl  -0x30(%ebp)
f010404a:	ff 75 dc             	pushl  -0x24(%ebp)
f010404d:	ff 75 d8             	pushl  -0x28(%ebp)
f0104050:	e8 97 09 00 00       	call   f01049ec <__udivdi3>
f0104055:	83 c4 18             	add    $0x18,%esp
f0104058:	52                   	push   %edx
f0104059:	50                   	push   %eax
f010405a:	89 f2                	mov    %esi,%edx
f010405c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010405f:	e8 98 ff ff ff       	call   f0103ffc <printnum>
f0104064:	83 c4 20             	add    $0x20,%esp
f0104067:	eb 10                	jmp    f0104079 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104069:	83 ec 08             	sub    $0x8,%esp
f010406c:	56                   	push   %esi
f010406d:	57                   	push   %edi
f010406e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104071:	4b                   	dec    %ebx
f0104072:	83 c4 10             	add    $0x10,%esp
f0104075:	85 db                	test   %ebx,%ebx
f0104077:	7f f0                	jg     f0104069 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104079:	83 ec 08             	sub    $0x8,%esp
f010407c:	56                   	push   %esi
f010407d:	83 ec 04             	sub    $0x4,%esp
f0104080:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104083:	ff 75 d0             	pushl  -0x30(%ebp)
f0104086:	ff 75 dc             	pushl  -0x24(%ebp)
f0104089:	ff 75 d8             	pushl  -0x28(%ebp)
f010408c:	e8 77 0a 00 00       	call   f0104b08 <__umoddi3>
f0104091:	83 c4 14             	add    $0x14,%esp
f0104094:	0f be 80 74 66 10 f0 	movsbl -0xfef998c(%eax),%eax
f010409b:	50                   	push   %eax
f010409c:	ff 55 e4             	call   *-0x1c(%ebp)
f010409f:	83 c4 10             	add    $0x10,%esp
}
f01040a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040a5:	5b                   	pop    %ebx
f01040a6:	5e                   	pop    %esi
f01040a7:	5f                   	pop    %edi
f01040a8:	c9                   	leave  
f01040a9:	c3                   	ret    

f01040aa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01040aa:	55                   	push   %ebp
f01040ab:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01040ad:	83 fa 01             	cmp    $0x1,%edx
f01040b0:	7e 0e                	jle    f01040c0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01040b2:	8b 10                	mov    (%eax),%edx
f01040b4:	8d 4a 08             	lea    0x8(%edx),%ecx
f01040b7:	89 08                	mov    %ecx,(%eax)
f01040b9:	8b 02                	mov    (%edx),%eax
f01040bb:	8b 52 04             	mov    0x4(%edx),%edx
f01040be:	eb 22                	jmp    f01040e2 <getuint+0x38>
	else if (lflag)
f01040c0:	85 d2                	test   %edx,%edx
f01040c2:	74 10                	je     f01040d4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01040c4:	8b 10                	mov    (%eax),%edx
f01040c6:	8d 4a 04             	lea    0x4(%edx),%ecx
f01040c9:	89 08                	mov    %ecx,(%eax)
f01040cb:	8b 02                	mov    (%edx),%eax
f01040cd:	ba 00 00 00 00       	mov    $0x0,%edx
f01040d2:	eb 0e                	jmp    f01040e2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01040d4:	8b 10                	mov    (%eax),%edx
f01040d6:	8d 4a 04             	lea    0x4(%edx),%ecx
f01040d9:	89 08                	mov    %ecx,(%eax)
f01040db:	8b 02                	mov    (%edx),%eax
f01040dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01040e2:	c9                   	leave  
f01040e3:	c3                   	ret    

f01040e4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f01040e4:	55                   	push   %ebp
f01040e5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01040e7:	83 fa 01             	cmp    $0x1,%edx
f01040ea:	7e 0e                	jle    f01040fa <getint+0x16>
		return va_arg(*ap, long long);
f01040ec:	8b 10                	mov    (%eax),%edx
f01040ee:	8d 4a 08             	lea    0x8(%edx),%ecx
f01040f1:	89 08                	mov    %ecx,(%eax)
f01040f3:	8b 02                	mov    (%edx),%eax
f01040f5:	8b 52 04             	mov    0x4(%edx),%edx
f01040f8:	eb 1a                	jmp    f0104114 <getint+0x30>
	else if (lflag)
f01040fa:	85 d2                	test   %edx,%edx
f01040fc:	74 0c                	je     f010410a <getint+0x26>
		return va_arg(*ap, long);
f01040fe:	8b 10                	mov    (%eax),%edx
f0104100:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104103:	89 08                	mov    %ecx,(%eax)
f0104105:	8b 02                	mov    (%edx),%eax
f0104107:	99                   	cltd   
f0104108:	eb 0a                	jmp    f0104114 <getint+0x30>
	else
		return va_arg(*ap, int);
f010410a:	8b 10                	mov    (%eax),%edx
f010410c:	8d 4a 04             	lea    0x4(%edx),%ecx
f010410f:	89 08                	mov    %ecx,(%eax)
f0104111:	8b 02                	mov    (%edx),%eax
f0104113:	99                   	cltd   
}
f0104114:	c9                   	leave  
f0104115:	c3                   	ret    

f0104116 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104116:	55                   	push   %ebp
f0104117:	89 e5                	mov    %esp,%ebp
f0104119:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010411c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f010411f:	8b 10                	mov    (%eax),%edx
f0104121:	3b 50 04             	cmp    0x4(%eax),%edx
f0104124:	73 08                	jae    f010412e <sprintputch+0x18>
		*b->buf++ = ch;
f0104126:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104129:	88 0a                	mov    %cl,(%edx)
f010412b:	42                   	inc    %edx
f010412c:	89 10                	mov    %edx,(%eax)
}
f010412e:	c9                   	leave  
f010412f:	c3                   	ret    

f0104130 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104130:	55                   	push   %ebp
f0104131:	89 e5                	mov    %esp,%ebp
f0104133:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104136:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104139:	50                   	push   %eax
f010413a:	ff 75 10             	pushl  0x10(%ebp)
f010413d:	ff 75 0c             	pushl  0xc(%ebp)
f0104140:	ff 75 08             	pushl  0x8(%ebp)
f0104143:	e8 05 00 00 00       	call   f010414d <vprintfmt>
	va_end(ap);
f0104148:	83 c4 10             	add    $0x10,%esp
}
f010414b:	c9                   	leave  
f010414c:	c3                   	ret    

f010414d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010414d:	55                   	push   %ebp
f010414e:	89 e5                	mov    %esp,%ebp
f0104150:	57                   	push   %edi
f0104151:	56                   	push   %esi
f0104152:	53                   	push   %ebx
f0104153:	83 ec 2c             	sub    $0x2c,%esp
f0104156:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104159:	8b 75 10             	mov    0x10(%ebp),%esi
f010415c:	eb 13                	jmp    f0104171 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010415e:	85 c0                	test   %eax,%eax
f0104160:	0f 84 6d 03 00 00    	je     f01044d3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f0104166:	83 ec 08             	sub    $0x8,%esp
f0104169:	57                   	push   %edi
f010416a:	50                   	push   %eax
f010416b:	ff 55 08             	call   *0x8(%ebp)
f010416e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104171:	0f b6 06             	movzbl (%esi),%eax
f0104174:	46                   	inc    %esi
f0104175:	83 f8 25             	cmp    $0x25,%eax
f0104178:	75 e4                	jne    f010415e <vprintfmt+0x11>
f010417a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f010417e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104185:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f010418c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0104193:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104198:	eb 28                	jmp    f01041c2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010419a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010419c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f01041a0:	eb 20                	jmp    f01041c2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041a2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01041a4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f01041a8:	eb 18                	jmp    f01041c2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041aa:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01041ac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01041b3:	eb 0d                	jmp    f01041c2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01041b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01041b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01041bb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041c2:	8a 06                	mov    (%esi),%al
f01041c4:	0f b6 d0             	movzbl %al,%edx
f01041c7:	8d 5e 01             	lea    0x1(%esi),%ebx
f01041ca:	83 e8 23             	sub    $0x23,%eax
f01041cd:	3c 55                	cmp    $0x55,%al
f01041cf:	0f 87 e0 02 00 00    	ja     f01044b5 <vprintfmt+0x368>
f01041d5:	0f b6 c0             	movzbl %al,%eax
f01041d8:	ff 24 85 00 67 10 f0 	jmp    *-0xfef9900(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01041df:	83 ea 30             	sub    $0x30,%edx
f01041e2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f01041e5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f01041e8:	8d 50 d0             	lea    -0x30(%eax),%edx
f01041eb:	83 fa 09             	cmp    $0x9,%edx
f01041ee:	77 44                	ja     f0104234 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041f0:	89 de                	mov    %ebx,%esi
f01041f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01041f5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f01041f6:	8d 14 92             	lea    (%edx,%edx,4),%edx
f01041f9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f01041fd:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0104200:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0104203:	83 fb 09             	cmp    $0x9,%ebx
f0104206:	76 ed                	jbe    f01041f5 <vprintfmt+0xa8>
f0104208:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010420b:	eb 29                	jmp    f0104236 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010420d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104210:	8d 50 04             	lea    0x4(%eax),%edx
f0104213:	89 55 14             	mov    %edx,0x14(%ebp)
f0104216:	8b 00                	mov    (%eax),%eax
f0104218:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010421b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010421d:	eb 17                	jmp    f0104236 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f010421f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104223:	78 85                	js     f01041aa <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104225:	89 de                	mov    %ebx,%esi
f0104227:	eb 99                	jmp    f01041c2 <vprintfmt+0x75>
f0104229:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010422b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0104232:	eb 8e                	jmp    f01041c2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104234:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0104236:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010423a:	79 86                	jns    f01041c2 <vprintfmt+0x75>
f010423c:	e9 74 ff ff ff       	jmp    f01041b5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104241:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104242:	89 de                	mov    %ebx,%esi
f0104244:	e9 79 ff ff ff       	jmp    f01041c2 <vprintfmt+0x75>
f0104249:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010424c:	8b 45 14             	mov    0x14(%ebp),%eax
f010424f:	8d 50 04             	lea    0x4(%eax),%edx
f0104252:	89 55 14             	mov    %edx,0x14(%ebp)
f0104255:	83 ec 08             	sub    $0x8,%esp
f0104258:	57                   	push   %edi
f0104259:	ff 30                	pushl  (%eax)
f010425b:	ff 55 08             	call   *0x8(%ebp)
			break;
f010425e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104261:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104264:	e9 08 ff ff ff       	jmp    f0104171 <vprintfmt+0x24>
f0104269:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f010426c:	8b 45 14             	mov    0x14(%ebp),%eax
f010426f:	8d 50 04             	lea    0x4(%eax),%edx
f0104272:	89 55 14             	mov    %edx,0x14(%ebp)
f0104275:	8b 00                	mov    (%eax),%eax
f0104277:	85 c0                	test   %eax,%eax
f0104279:	79 02                	jns    f010427d <vprintfmt+0x130>
f010427b:	f7 d8                	neg    %eax
f010427d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010427f:	83 f8 06             	cmp    $0x6,%eax
f0104282:	7f 0b                	jg     f010428f <vprintfmt+0x142>
f0104284:	8b 04 85 58 68 10 f0 	mov    -0xfef97a8(,%eax,4),%eax
f010428b:	85 c0                	test   %eax,%eax
f010428d:	75 1a                	jne    f01042a9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f010428f:	52                   	push   %edx
f0104290:	68 8c 66 10 f0       	push   $0xf010668c
f0104295:	57                   	push   %edi
f0104296:	ff 75 08             	pushl  0x8(%ebp)
f0104299:	e8 92 fe ff ff       	call   f0104130 <printfmt>
f010429e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01042a1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01042a4:	e9 c8 fe ff ff       	jmp    f0104171 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f01042a9:	50                   	push   %eax
f01042aa:	68 91 5e 10 f0       	push   $0xf0105e91
f01042af:	57                   	push   %edi
f01042b0:	ff 75 08             	pushl  0x8(%ebp)
f01042b3:	e8 78 fe ff ff       	call   f0104130 <printfmt>
f01042b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01042bb:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01042be:	e9 ae fe ff ff       	jmp    f0104171 <vprintfmt+0x24>
f01042c3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f01042c6:	89 de                	mov    %ebx,%esi
f01042c8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01042cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01042ce:	8b 45 14             	mov    0x14(%ebp),%eax
f01042d1:	8d 50 04             	lea    0x4(%eax),%edx
f01042d4:	89 55 14             	mov    %edx,0x14(%ebp)
f01042d7:	8b 00                	mov    (%eax),%eax
f01042d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01042dc:	85 c0                	test   %eax,%eax
f01042de:	75 07                	jne    f01042e7 <vprintfmt+0x19a>
				p = "(null)";
f01042e0:	c7 45 d0 85 66 10 f0 	movl   $0xf0106685,-0x30(%ebp)
			if (width > 0 && padc != '-')
f01042e7:	85 db                	test   %ebx,%ebx
f01042e9:	7e 42                	jle    f010432d <vprintfmt+0x1e0>
f01042eb:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f01042ef:	74 3c                	je     f010432d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f01042f1:	83 ec 08             	sub    $0x8,%esp
f01042f4:	51                   	push   %ecx
f01042f5:	ff 75 d0             	pushl  -0x30(%ebp)
f01042f8:	e8 3f 03 00 00       	call   f010463c <strnlen>
f01042fd:	29 c3                	sub    %eax,%ebx
f01042ff:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104302:	83 c4 10             	add    $0x10,%esp
f0104305:	85 db                	test   %ebx,%ebx
f0104307:	7e 24                	jle    f010432d <vprintfmt+0x1e0>
					putch(padc, putdat);
f0104309:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f010430d:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0104310:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104313:	83 ec 08             	sub    $0x8,%esp
f0104316:	57                   	push   %edi
f0104317:	53                   	push   %ebx
f0104318:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010431b:	4e                   	dec    %esi
f010431c:	83 c4 10             	add    $0x10,%esp
f010431f:	85 f6                	test   %esi,%esi
f0104321:	7f f0                	jg     f0104313 <vprintfmt+0x1c6>
f0104323:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104326:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010432d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104330:	0f be 02             	movsbl (%edx),%eax
f0104333:	85 c0                	test   %eax,%eax
f0104335:	75 47                	jne    f010437e <vprintfmt+0x231>
f0104337:	eb 37                	jmp    f0104370 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f0104339:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010433d:	74 16                	je     f0104355 <vprintfmt+0x208>
f010433f:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104342:	83 fa 5e             	cmp    $0x5e,%edx
f0104345:	76 0e                	jbe    f0104355 <vprintfmt+0x208>
					putch('?', putdat);
f0104347:	83 ec 08             	sub    $0x8,%esp
f010434a:	57                   	push   %edi
f010434b:	6a 3f                	push   $0x3f
f010434d:	ff 55 08             	call   *0x8(%ebp)
f0104350:	83 c4 10             	add    $0x10,%esp
f0104353:	eb 0b                	jmp    f0104360 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f0104355:	83 ec 08             	sub    $0x8,%esp
f0104358:	57                   	push   %edi
f0104359:	50                   	push   %eax
f010435a:	ff 55 08             	call   *0x8(%ebp)
f010435d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104360:	ff 4d e4             	decl   -0x1c(%ebp)
f0104363:	0f be 03             	movsbl (%ebx),%eax
f0104366:	85 c0                	test   %eax,%eax
f0104368:	74 03                	je     f010436d <vprintfmt+0x220>
f010436a:	43                   	inc    %ebx
f010436b:	eb 1b                	jmp    f0104388 <vprintfmt+0x23b>
f010436d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104370:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104374:	7f 1e                	jg     f0104394 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104376:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0104379:	e9 f3 fd ff ff       	jmp    f0104171 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010437e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104381:	43                   	inc    %ebx
f0104382:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0104385:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0104388:	85 f6                	test   %esi,%esi
f010438a:	78 ad                	js     f0104339 <vprintfmt+0x1ec>
f010438c:	4e                   	dec    %esi
f010438d:	79 aa                	jns    f0104339 <vprintfmt+0x1ec>
f010438f:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104392:	eb dc                	jmp    f0104370 <vprintfmt+0x223>
f0104394:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104397:	83 ec 08             	sub    $0x8,%esp
f010439a:	57                   	push   %edi
f010439b:	6a 20                	push   $0x20
f010439d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01043a0:	4b                   	dec    %ebx
f01043a1:	83 c4 10             	add    $0x10,%esp
f01043a4:	85 db                	test   %ebx,%ebx
f01043a6:	7f ef                	jg     f0104397 <vprintfmt+0x24a>
f01043a8:	e9 c4 fd ff ff       	jmp    f0104171 <vprintfmt+0x24>
f01043ad:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01043b0:	89 ca                	mov    %ecx,%edx
f01043b2:	8d 45 14             	lea    0x14(%ebp),%eax
f01043b5:	e8 2a fd ff ff       	call   f01040e4 <getint>
f01043ba:	89 c3                	mov    %eax,%ebx
f01043bc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f01043be:	85 d2                	test   %edx,%edx
f01043c0:	78 0a                	js     f01043cc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01043c2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01043c7:	e9 b0 00 00 00       	jmp    f010447c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f01043cc:	83 ec 08             	sub    $0x8,%esp
f01043cf:	57                   	push   %edi
f01043d0:	6a 2d                	push   $0x2d
f01043d2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01043d5:	f7 db                	neg    %ebx
f01043d7:	83 d6 00             	adc    $0x0,%esi
f01043da:	f7 de                	neg    %esi
f01043dc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01043df:	b8 0a 00 00 00       	mov    $0xa,%eax
f01043e4:	e9 93 00 00 00       	jmp    f010447c <vprintfmt+0x32f>
f01043e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01043ec:	89 ca                	mov    %ecx,%edx
f01043ee:	8d 45 14             	lea    0x14(%ebp),%eax
f01043f1:	e8 b4 fc ff ff       	call   f01040aa <getuint>
f01043f6:	89 c3                	mov    %eax,%ebx
f01043f8:	89 d6                	mov    %edx,%esi
			base = 10;
f01043fa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01043ff:	eb 7b                	jmp    f010447c <vprintfmt+0x32f>
f0104401:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0104404:	89 ca                	mov    %ecx,%edx
f0104406:	8d 45 14             	lea    0x14(%ebp),%eax
f0104409:	e8 d6 fc ff ff       	call   f01040e4 <getint>
f010440e:	89 c3                	mov    %eax,%ebx
f0104410:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f0104412:	85 d2                	test   %edx,%edx
f0104414:	78 07                	js     f010441d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f0104416:	b8 08 00 00 00       	mov    $0x8,%eax
f010441b:	eb 5f                	jmp    f010447c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f010441d:	83 ec 08             	sub    $0x8,%esp
f0104420:	57                   	push   %edi
f0104421:	6a 2d                	push   $0x2d
f0104423:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f0104426:	f7 db                	neg    %ebx
f0104428:	83 d6 00             	adc    $0x0,%esi
f010442b:	f7 de                	neg    %esi
f010442d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f0104430:	b8 08 00 00 00       	mov    $0x8,%eax
f0104435:	eb 45                	jmp    f010447c <vprintfmt+0x32f>
f0104437:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f010443a:	83 ec 08             	sub    $0x8,%esp
f010443d:	57                   	push   %edi
f010443e:	6a 30                	push   $0x30
f0104440:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104443:	83 c4 08             	add    $0x8,%esp
f0104446:	57                   	push   %edi
f0104447:	6a 78                	push   $0x78
f0104449:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010444c:	8b 45 14             	mov    0x14(%ebp),%eax
f010444f:	8d 50 04             	lea    0x4(%eax),%edx
f0104452:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104455:	8b 18                	mov    (%eax),%ebx
f0104457:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010445c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010445f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104464:	eb 16                	jmp    f010447c <vprintfmt+0x32f>
f0104466:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104469:	89 ca                	mov    %ecx,%edx
f010446b:	8d 45 14             	lea    0x14(%ebp),%eax
f010446e:	e8 37 fc ff ff       	call   f01040aa <getuint>
f0104473:	89 c3                	mov    %eax,%ebx
f0104475:	89 d6                	mov    %edx,%esi
			base = 16;
f0104477:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f010447c:	83 ec 0c             	sub    $0xc,%esp
f010447f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0104483:	52                   	push   %edx
f0104484:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104487:	50                   	push   %eax
f0104488:	56                   	push   %esi
f0104489:	53                   	push   %ebx
f010448a:	89 fa                	mov    %edi,%edx
f010448c:	8b 45 08             	mov    0x8(%ebp),%eax
f010448f:	e8 68 fb ff ff       	call   f0103ffc <printnum>
			break;
f0104494:	83 c4 20             	add    $0x20,%esp
f0104497:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010449a:	e9 d2 fc ff ff       	jmp    f0104171 <vprintfmt+0x24>
f010449f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01044a2:	83 ec 08             	sub    $0x8,%esp
f01044a5:	57                   	push   %edi
f01044a6:	52                   	push   %edx
f01044a7:	ff 55 08             	call   *0x8(%ebp)
			break;
f01044aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044ad:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01044b0:	e9 bc fc ff ff       	jmp    f0104171 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01044b5:	83 ec 08             	sub    $0x8,%esp
f01044b8:	57                   	push   %edi
f01044b9:	6a 25                	push   $0x25
f01044bb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01044be:	83 c4 10             	add    $0x10,%esp
f01044c1:	eb 02                	jmp    f01044c5 <vprintfmt+0x378>
f01044c3:	89 c6                	mov    %eax,%esi
f01044c5:	8d 46 ff             	lea    -0x1(%esi),%eax
f01044c8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01044cc:	75 f5                	jne    f01044c3 <vprintfmt+0x376>
f01044ce:	e9 9e fc ff ff       	jmp    f0104171 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f01044d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01044d6:	5b                   	pop    %ebx
f01044d7:	5e                   	pop    %esi
f01044d8:	5f                   	pop    %edi
f01044d9:	c9                   	leave  
f01044da:	c3                   	ret    

f01044db <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01044db:	55                   	push   %ebp
f01044dc:	89 e5                	mov    %esp,%ebp
f01044de:	83 ec 18             	sub    $0x18,%esp
f01044e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01044e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01044e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01044ea:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01044ee:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01044f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01044f8:	85 c0                	test   %eax,%eax
f01044fa:	74 26                	je     f0104522 <vsnprintf+0x47>
f01044fc:	85 d2                	test   %edx,%edx
f01044fe:	7e 29                	jle    f0104529 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104500:	ff 75 14             	pushl  0x14(%ebp)
f0104503:	ff 75 10             	pushl  0x10(%ebp)
f0104506:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104509:	50                   	push   %eax
f010450a:	68 16 41 10 f0       	push   $0xf0104116
f010450f:	e8 39 fc ff ff       	call   f010414d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104514:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104517:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010451a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010451d:	83 c4 10             	add    $0x10,%esp
f0104520:	eb 0c                	jmp    f010452e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104522:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104527:	eb 05                	jmp    f010452e <vsnprintf+0x53>
f0104529:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010452e:	c9                   	leave  
f010452f:	c3                   	ret    

f0104530 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104530:	55                   	push   %ebp
f0104531:	89 e5                	mov    %esp,%ebp
f0104533:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104536:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104539:	50                   	push   %eax
f010453a:	ff 75 10             	pushl  0x10(%ebp)
f010453d:	ff 75 0c             	pushl  0xc(%ebp)
f0104540:	ff 75 08             	pushl  0x8(%ebp)
f0104543:	e8 93 ff ff ff       	call   f01044db <vsnprintf>
	va_end(ap);

	return rc;
}
f0104548:	c9                   	leave  
f0104549:	c3                   	ret    
	...

f010454c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010454c:	55                   	push   %ebp
f010454d:	89 e5                	mov    %esp,%ebp
f010454f:	57                   	push   %edi
f0104550:	56                   	push   %esi
f0104551:	53                   	push   %ebx
f0104552:	83 ec 0c             	sub    $0xc,%esp
f0104555:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104558:	85 c0                	test   %eax,%eax
f010455a:	74 11                	je     f010456d <readline+0x21>
		cprintf("%s", prompt);
f010455c:	83 ec 08             	sub    $0x8,%esp
f010455f:	50                   	push   %eax
f0104560:	68 91 5e 10 f0       	push   $0xf0105e91
f0104565:	e8 47 f0 ff ff       	call   f01035b1 <cprintf>
f010456a:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010456d:	83 ec 0c             	sub    $0xc,%esp
f0104570:	6a 00                	push   $0x0
f0104572:	e8 98 c0 ff ff       	call   f010060f <iscons>
f0104577:	89 c7                	mov    %eax,%edi
f0104579:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010457c:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104581:	e8 78 c0 ff ff       	call   f01005fe <getchar>
f0104586:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104588:	85 c0                	test   %eax,%eax
f010458a:	79 18                	jns    f01045a4 <readline+0x58>
			cprintf("read error: %e\n", c);
f010458c:	83 ec 08             	sub    $0x8,%esp
f010458f:	50                   	push   %eax
f0104590:	68 74 68 10 f0       	push   $0xf0106874
f0104595:	e8 17 f0 ff ff       	call   f01035b1 <cprintf>
			return NULL;
f010459a:	83 c4 10             	add    $0x10,%esp
f010459d:	b8 00 00 00 00       	mov    $0x0,%eax
f01045a2:	eb 6f                	jmp    f0104613 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01045a4:	83 f8 08             	cmp    $0x8,%eax
f01045a7:	74 05                	je     f01045ae <readline+0x62>
f01045a9:	83 f8 7f             	cmp    $0x7f,%eax
f01045ac:	75 18                	jne    f01045c6 <readline+0x7a>
f01045ae:	85 f6                	test   %esi,%esi
f01045b0:	7e 14                	jle    f01045c6 <readline+0x7a>
			if (echoing)
f01045b2:	85 ff                	test   %edi,%edi
f01045b4:	74 0d                	je     f01045c3 <readline+0x77>
				cputchar('\b');
f01045b6:	83 ec 0c             	sub    $0xc,%esp
f01045b9:	6a 08                	push   $0x8
f01045bb:	e8 2e c0 ff ff       	call   f01005ee <cputchar>
f01045c0:	83 c4 10             	add    $0x10,%esp
			i--;
f01045c3:	4e                   	dec    %esi
f01045c4:	eb bb                	jmp    f0104581 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01045c6:	83 fb 1f             	cmp    $0x1f,%ebx
f01045c9:	7e 21                	jle    f01045ec <readline+0xa0>
f01045cb:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01045d1:	7f 19                	jg     f01045ec <readline+0xa0>
			if (echoing)
f01045d3:	85 ff                	test   %edi,%edi
f01045d5:	74 0c                	je     f01045e3 <readline+0x97>
				cputchar(c);
f01045d7:	83 ec 0c             	sub    $0xc,%esp
f01045da:	53                   	push   %ebx
f01045db:	e8 0e c0 ff ff       	call   f01005ee <cputchar>
f01045e0:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01045e3:	88 9e 40 0d 1e f0    	mov    %bl,-0xfe1f2c0(%esi)
f01045e9:	46                   	inc    %esi
f01045ea:	eb 95                	jmp    f0104581 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01045ec:	83 fb 0a             	cmp    $0xa,%ebx
f01045ef:	74 05                	je     f01045f6 <readline+0xaa>
f01045f1:	83 fb 0d             	cmp    $0xd,%ebx
f01045f4:	75 8b                	jne    f0104581 <readline+0x35>
			if (echoing)
f01045f6:	85 ff                	test   %edi,%edi
f01045f8:	74 0d                	je     f0104607 <readline+0xbb>
				cputchar('\n');
f01045fa:	83 ec 0c             	sub    $0xc,%esp
f01045fd:	6a 0a                	push   $0xa
f01045ff:	e8 ea bf ff ff       	call   f01005ee <cputchar>
f0104604:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104607:	c6 86 40 0d 1e f0 00 	movb   $0x0,-0xfe1f2c0(%esi)
			return buf;
f010460e:	b8 40 0d 1e f0       	mov    $0xf01e0d40,%eax
		}
	}
}
f0104613:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104616:	5b                   	pop    %ebx
f0104617:	5e                   	pop    %esi
f0104618:	5f                   	pop    %edi
f0104619:	c9                   	leave  
f010461a:	c3                   	ret    
	...

f010461c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010461c:	55                   	push   %ebp
f010461d:	89 e5                	mov    %esp,%ebp
f010461f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104622:	80 3a 00             	cmpb   $0x0,(%edx)
f0104625:	74 0e                	je     f0104635 <strlen+0x19>
f0104627:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f010462c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010462d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104631:	75 f9                	jne    f010462c <strlen+0x10>
f0104633:	eb 05                	jmp    f010463a <strlen+0x1e>
f0104635:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010463a:	c9                   	leave  
f010463b:	c3                   	ret    

f010463c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010463c:	55                   	push   %ebp
f010463d:	89 e5                	mov    %esp,%ebp
f010463f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104642:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104645:	85 d2                	test   %edx,%edx
f0104647:	74 17                	je     f0104660 <strnlen+0x24>
f0104649:	80 39 00             	cmpb   $0x0,(%ecx)
f010464c:	74 19                	je     f0104667 <strnlen+0x2b>
f010464e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0104653:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104654:	39 d0                	cmp    %edx,%eax
f0104656:	74 14                	je     f010466c <strnlen+0x30>
f0104658:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010465c:	75 f5                	jne    f0104653 <strnlen+0x17>
f010465e:	eb 0c                	jmp    f010466c <strnlen+0x30>
f0104660:	b8 00 00 00 00       	mov    $0x0,%eax
f0104665:	eb 05                	jmp    f010466c <strnlen+0x30>
f0104667:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010466c:	c9                   	leave  
f010466d:	c3                   	ret    

f010466e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010466e:	55                   	push   %ebp
f010466f:	89 e5                	mov    %esp,%ebp
f0104671:	53                   	push   %ebx
f0104672:	8b 45 08             	mov    0x8(%ebp),%eax
f0104675:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104678:	ba 00 00 00 00       	mov    $0x0,%edx
f010467d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0104680:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104683:	42                   	inc    %edx
f0104684:	84 c9                	test   %cl,%cl
f0104686:	75 f5                	jne    f010467d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104688:	5b                   	pop    %ebx
f0104689:	c9                   	leave  
f010468a:	c3                   	ret    

f010468b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010468b:	55                   	push   %ebp
f010468c:	89 e5                	mov    %esp,%ebp
f010468e:	53                   	push   %ebx
f010468f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104692:	53                   	push   %ebx
f0104693:	e8 84 ff ff ff       	call   f010461c <strlen>
f0104698:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010469b:	ff 75 0c             	pushl  0xc(%ebp)
f010469e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01046a1:	50                   	push   %eax
f01046a2:	e8 c7 ff ff ff       	call   f010466e <strcpy>
	return dst;
}
f01046a7:	89 d8                	mov    %ebx,%eax
f01046a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01046ac:	c9                   	leave  
f01046ad:	c3                   	ret    

f01046ae <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01046ae:	55                   	push   %ebp
f01046af:	89 e5                	mov    %esp,%ebp
f01046b1:	56                   	push   %esi
f01046b2:	53                   	push   %ebx
f01046b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01046b6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01046b9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01046bc:	85 f6                	test   %esi,%esi
f01046be:	74 15                	je     f01046d5 <strncpy+0x27>
f01046c0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01046c5:	8a 1a                	mov    (%edx),%bl
f01046c7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01046ca:	80 3a 01             	cmpb   $0x1,(%edx)
f01046cd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01046d0:	41                   	inc    %ecx
f01046d1:	39 ce                	cmp    %ecx,%esi
f01046d3:	77 f0                	ja     f01046c5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01046d5:	5b                   	pop    %ebx
f01046d6:	5e                   	pop    %esi
f01046d7:	c9                   	leave  
f01046d8:	c3                   	ret    

f01046d9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01046d9:	55                   	push   %ebp
f01046da:	89 e5                	mov    %esp,%ebp
f01046dc:	57                   	push   %edi
f01046dd:	56                   	push   %esi
f01046de:	53                   	push   %ebx
f01046df:	8b 7d 08             	mov    0x8(%ebp),%edi
f01046e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01046e5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01046e8:	85 f6                	test   %esi,%esi
f01046ea:	74 32                	je     f010471e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f01046ec:	83 fe 01             	cmp    $0x1,%esi
f01046ef:	74 22                	je     f0104713 <strlcpy+0x3a>
f01046f1:	8a 0b                	mov    (%ebx),%cl
f01046f3:	84 c9                	test   %cl,%cl
f01046f5:	74 20                	je     f0104717 <strlcpy+0x3e>
f01046f7:	89 f8                	mov    %edi,%eax
f01046f9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01046fe:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104701:	88 08                	mov    %cl,(%eax)
f0104703:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104704:	39 f2                	cmp    %esi,%edx
f0104706:	74 11                	je     f0104719 <strlcpy+0x40>
f0104708:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f010470c:	42                   	inc    %edx
f010470d:	84 c9                	test   %cl,%cl
f010470f:	75 f0                	jne    f0104701 <strlcpy+0x28>
f0104711:	eb 06                	jmp    f0104719 <strlcpy+0x40>
f0104713:	89 f8                	mov    %edi,%eax
f0104715:	eb 02                	jmp    f0104719 <strlcpy+0x40>
f0104717:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104719:	c6 00 00             	movb   $0x0,(%eax)
f010471c:	eb 02                	jmp    f0104720 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010471e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0104720:	29 f8                	sub    %edi,%eax
}
f0104722:	5b                   	pop    %ebx
f0104723:	5e                   	pop    %esi
f0104724:	5f                   	pop    %edi
f0104725:	c9                   	leave  
f0104726:	c3                   	ret    

f0104727 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104727:	55                   	push   %ebp
f0104728:	89 e5                	mov    %esp,%ebp
f010472a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010472d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104730:	8a 01                	mov    (%ecx),%al
f0104732:	84 c0                	test   %al,%al
f0104734:	74 10                	je     f0104746 <strcmp+0x1f>
f0104736:	3a 02                	cmp    (%edx),%al
f0104738:	75 0c                	jne    f0104746 <strcmp+0x1f>
		p++, q++;
f010473a:	41                   	inc    %ecx
f010473b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010473c:	8a 01                	mov    (%ecx),%al
f010473e:	84 c0                	test   %al,%al
f0104740:	74 04                	je     f0104746 <strcmp+0x1f>
f0104742:	3a 02                	cmp    (%edx),%al
f0104744:	74 f4                	je     f010473a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104746:	0f b6 c0             	movzbl %al,%eax
f0104749:	0f b6 12             	movzbl (%edx),%edx
f010474c:	29 d0                	sub    %edx,%eax
}
f010474e:	c9                   	leave  
f010474f:	c3                   	ret    

f0104750 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104750:	55                   	push   %ebp
f0104751:	89 e5                	mov    %esp,%ebp
f0104753:	53                   	push   %ebx
f0104754:	8b 55 08             	mov    0x8(%ebp),%edx
f0104757:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010475a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f010475d:	85 c0                	test   %eax,%eax
f010475f:	74 1b                	je     f010477c <strncmp+0x2c>
f0104761:	8a 1a                	mov    (%edx),%bl
f0104763:	84 db                	test   %bl,%bl
f0104765:	74 24                	je     f010478b <strncmp+0x3b>
f0104767:	3a 19                	cmp    (%ecx),%bl
f0104769:	75 20                	jne    f010478b <strncmp+0x3b>
f010476b:	48                   	dec    %eax
f010476c:	74 15                	je     f0104783 <strncmp+0x33>
		n--, p++, q++;
f010476e:	42                   	inc    %edx
f010476f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104770:	8a 1a                	mov    (%edx),%bl
f0104772:	84 db                	test   %bl,%bl
f0104774:	74 15                	je     f010478b <strncmp+0x3b>
f0104776:	3a 19                	cmp    (%ecx),%bl
f0104778:	74 f1                	je     f010476b <strncmp+0x1b>
f010477a:	eb 0f                	jmp    f010478b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f010477c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104781:	eb 05                	jmp    f0104788 <strncmp+0x38>
f0104783:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104788:	5b                   	pop    %ebx
f0104789:	c9                   	leave  
f010478a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010478b:	0f b6 02             	movzbl (%edx),%eax
f010478e:	0f b6 11             	movzbl (%ecx),%edx
f0104791:	29 d0                	sub    %edx,%eax
f0104793:	eb f3                	jmp    f0104788 <strncmp+0x38>

f0104795 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104795:	55                   	push   %ebp
f0104796:	89 e5                	mov    %esp,%ebp
f0104798:	8b 45 08             	mov    0x8(%ebp),%eax
f010479b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010479e:	8a 10                	mov    (%eax),%dl
f01047a0:	84 d2                	test   %dl,%dl
f01047a2:	74 18                	je     f01047bc <strchr+0x27>
		if (*s == c)
f01047a4:	38 ca                	cmp    %cl,%dl
f01047a6:	75 06                	jne    f01047ae <strchr+0x19>
f01047a8:	eb 17                	jmp    f01047c1 <strchr+0x2c>
f01047aa:	38 ca                	cmp    %cl,%dl
f01047ac:	74 13                	je     f01047c1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01047ae:	40                   	inc    %eax
f01047af:	8a 10                	mov    (%eax),%dl
f01047b1:	84 d2                	test   %dl,%dl
f01047b3:	75 f5                	jne    f01047aa <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f01047b5:	b8 00 00 00 00       	mov    $0x0,%eax
f01047ba:	eb 05                	jmp    f01047c1 <strchr+0x2c>
f01047bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01047c1:	c9                   	leave  
f01047c2:	c3                   	ret    

f01047c3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01047c3:	55                   	push   %ebp
f01047c4:	89 e5                	mov    %esp,%ebp
f01047c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01047c9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01047cc:	8a 10                	mov    (%eax),%dl
f01047ce:	84 d2                	test   %dl,%dl
f01047d0:	74 11                	je     f01047e3 <strfind+0x20>
		if (*s == c)
f01047d2:	38 ca                	cmp    %cl,%dl
f01047d4:	75 06                	jne    f01047dc <strfind+0x19>
f01047d6:	eb 0b                	jmp    f01047e3 <strfind+0x20>
f01047d8:	38 ca                	cmp    %cl,%dl
f01047da:	74 07                	je     f01047e3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01047dc:	40                   	inc    %eax
f01047dd:	8a 10                	mov    (%eax),%dl
f01047df:	84 d2                	test   %dl,%dl
f01047e1:	75 f5                	jne    f01047d8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f01047e3:	c9                   	leave  
f01047e4:	c3                   	ret    

f01047e5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01047e5:	55                   	push   %ebp
f01047e6:	89 e5                	mov    %esp,%ebp
f01047e8:	57                   	push   %edi
f01047e9:	56                   	push   %esi
f01047ea:	53                   	push   %ebx
f01047eb:	8b 7d 08             	mov    0x8(%ebp),%edi
f01047ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01047f4:	85 c9                	test   %ecx,%ecx
f01047f6:	74 30                	je     f0104828 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01047f8:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01047fe:	75 25                	jne    f0104825 <memset+0x40>
f0104800:	f6 c1 03             	test   $0x3,%cl
f0104803:	75 20                	jne    f0104825 <memset+0x40>
		c &= 0xFF;
f0104805:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104808:	89 d3                	mov    %edx,%ebx
f010480a:	c1 e3 08             	shl    $0x8,%ebx
f010480d:	89 d6                	mov    %edx,%esi
f010480f:	c1 e6 18             	shl    $0x18,%esi
f0104812:	89 d0                	mov    %edx,%eax
f0104814:	c1 e0 10             	shl    $0x10,%eax
f0104817:	09 f0                	or     %esi,%eax
f0104819:	09 d0                	or     %edx,%eax
f010481b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010481d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104820:	fc                   	cld    
f0104821:	f3 ab                	rep stos %eax,%es:(%edi)
f0104823:	eb 03                	jmp    f0104828 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104825:	fc                   	cld    
f0104826:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104828:	89 f8                	mov    %edi,%eax
f010482a:	5b                   	pop    %ebx
f010482b:	5e                   	pop    %esi
f010482c:	5f                   	pop    %edi
f010482d:	c9                   	leave  
f010482e:	c3                   	ret    

f010482f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010482f:	55                   	push   %ebp
f0104830:	89 e5                	mov    %esp,%ebp
f0104832:	57                   	push   %edi
f0104833:	56                   	push   %esi
f0104834:	8b 45 08             	mov    0x8(%ebp),%eax
f0104837:	8b 75 0c             	mov    0xc(%ebp),%esi
f010483a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010483d:	39 c6                	cmp    %eax,%esi
f010483f:	73 34                	jae    f0104875 <memmove+0x46>
f0104841:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104844:	39 d0                	cmp    %edx,%eax
f0104846:	73 2d                	jae    f0104875 <memmove+0x46>
		s += n;
		d += n;
f0104848:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010484b:	f6 c2 03             	test   $0x3,%dl
f010484e:	75 1b                	jne    f010486b <memmove+0x3c>
f0104850:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104856:	75 13                	jne    f010486b <memmove+0x3c>
f0104858:	f6 c1 03             	test   $0x3,%cl
f010485b:	75 0e                	jne    f010486b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010485d:	83 ef 04             	sub    $0x4,%edi
f0104860:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104863:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104866:	fd                   	std    
f0104867:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104869:	eb 07                	jmp    f0104872 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010486b:	4f                   	dec    %edi
f010486c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010486f:	fd                   	std    
f0104870:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104872:	fc                   	cld    
f0104873:	eb 20                	jmp    f0104895 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104875:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010487b:	75 13                	jne    f0104890 <memmove+0x61>
f010487d:	a8 03                	test   $0x3,%al
f010487f:	75 0f                	jne    f0104890 <memmove+0x61>
f0104881:	f6 c1 03             	test   $0x3,%cl
f0104884:	75 0a                	jne    f0104890 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104886:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104889:	89 c7                	mov    %eax,%edi
f010488b:	fc                   	cld    
f010488c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010488e:	eb 05                	jmp    f0104895 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104890:	89 c7                	mov    %eax,%edi
f0104892:	fc                   	cld    
f0104893:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104895:	5e                   	pop    %esi
f0104896:	5f                   	pop    %edi
f0104897:	c9                   	leave  
f0104898:	c3                   	ret    

f0104899 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104899:	55                   	push   %ebp
f010489a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010489c:	ff 75 10             	pushl  0x10(%ebp)
f010489f:	ff 75 0c             	pushl  0xc(%ebp)
f01048a2:	ff 75 08             	pushl  0x8(%ebp)
f01048a5:	e8 85 ff ff ff       	call   f010482f <memmove>
}
f01048aa:	c9                   	leave  
f01048ab:	c3                   	ret    

f01048ac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01048ac:	55                   	push   %ebp
f01048ad:	89 e5                	mov    %esp,%ebp
f01048af:	57                   	push   %edi
f01048b0:	56                   	push   %esi
f01048b1:	53                   	push   %ebx
f01048b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01048b5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01048b8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01048bb:	85 ff                	test   %edi,%edi
f01048bd:	74 32                	je     f01048f1 <memcmp+0x45>
		if (*s1 != *s2)
f01048bf:	8a 03                	mov    (%ebx),%al
f01048c1:	8a 0e                	mov    (%esi),%cl
f01048c3:	38 c8                	cmp    %cl,%al
f01048c5:	74 19                	je     f01048e0 <memcmp+0x34>
f01048c7:	eb 0d                	jmp    f01048d6 <memcmp+0x2a>
f01048c9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f01048cd:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f01048d1:	42                   	inc    %edx
f01048d2:	38 c8                	cmp    %cl,%al
f01048d4:	74 10                	je     f01048e6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f01048d6:	0f b6 c0             	movzbl %al,%eax
f01048d9:	0f b6 c9             	movzbl %cl,%ecx
f01048dc:	29 c8                	sub    %ecx,%eax
f01048de:	eb 16                	jmp    f01048f6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01048e0:	4f                   	dec    %edi
f01048e1:	ba 00 00 00 00       	mov    $0x0,%edx
f01048e6:	39 fa                	cmp    %edi,%edx
f01048e8:	75 df                	jne    f01048c9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01048ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01048ef:	eb 05                	jmp    f01048f6 <memcmp+0x4a>
f01048f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01048f6:	5b                   	pop    %ebx
f01048f7:	5e                   	pop    %esi
f01048f8:	5f                   	pop    %edi
f01048f9:	c9                   	leave  
f01048fa:	c3                   	ret    

f01048fb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01048fb:	55                   	push   %ebp
f01048fc:	89 e5                	mov    %esp,%ebp
f01048fe:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104901:	89 c2                	mov    %eax,%edx
f0104903:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104906:	39 d0                	cmp    %edx,%eax
f0104908:	73 12                	jae    f010491c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f010490a:	8a 4d 0c             	mov    0xc(%ebp),%cl
f010490d:	38 08                	cmp    %cl,(%eax)
f010490f:	75 06                	jne    f0104917 <memfind+0x1c>
f0104911:	eb 09                	jmp    f010491c <memfind+0x21>
f0104913:	38 08                	cmp    %cl,(%eax)
f0104915:	74 05                	je     f010491c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104917:	40                   	inc    %eax
f0104918:	39 c2                	cmp    %eax,%edx
f010491a:	77 f7                	ja     f0104913 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010491c:	c9                   	leave  
f010491d:	c3                   	ret    

f010491e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010491e:	55                   	push   %ebp
f010491f:	89 e5                	mov    %esp,%ebp
f0104921:	57                   	push   %edi
f0104922:	56                   	push   %esi
f0104923:	53                   	push   %ebx
f0104924:	8b 55 08             	mov    0x8(%ebp),%edx
f0104927:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010492a:	eb 01                	jmp    f010492d <strtol+0xf>
		s++;
f010492c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010492d:	8a 02                	mov    (%edx),%al
f010492f:	3c 20                	cmp    $0x20,%al
f0104931:	74 f9                	je     f010492c <strtol+0xe>
f0104933:	3c 09                	cmp    $0x9,%al
f0104935:	74 f5                	je     f010492c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104937:	3c 2b                	cmp    $0x2b,%al
f0104939:	75 08                	jne    f0104943 <strtol+0x25>
		s++;
f010493b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010493c:	bf 00 00 00 00       	mov    $0x0,%edi
f0104941:	eb 13                	jmp    f0104956 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104943:	3c 2d                	cmp    $0x2d,%al
f0104945:	75 0a                	jne    f0104951 <strtol+0x33>
		s++, neg = 1;
f0104947:	8d 52 01             	lea    0x1(%edx),%edx
f010494a:	bf 01 00 00 00       	mov    $0x1,%edi
f010494f:	eb 05                	jmp    f0104956 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104951:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104956:	85 db                	test   %ebx,%ebx
f0104958:	74 05                	je     f010495f <strtol+0x41>
f010495a:	83 fb 10             	cmp    $0x10,%ebx
f010495d:	75 28                	jne    f0104987 <strtol+0x69>
f010495f:	8a 02                	mov    (%edx),%al
f0104961:	3c 30                	cmp    $0x30,%al
f0104963:	75 10                	jne    f0104975 <strtol+0x57>
f0104965:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104969:	75 0a                	jne    f0104975 <strtol+0x57>
		s += 2, base = 16;
f010496b:	83 c2 02             	add    $0x2,%edx
f010496e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104973:	eb 12                	jmp    f0104987 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0104975:	85 db                	test   %ebx,%ebx
f0104977:	75 0e                	jne    f0104987 <strtol+0x69>
f0104979:	3c 30                	cmp    $0x30,%al
f010497b:	75 05                	jne    f0104982 <strtol+0x64>
		s++, base = 8;
f010497d:	42                   	inc    %edx
f010497e:	b3 08                	mov    $0x8,%bl
f0104980:	eb 05                	jmp    f0104987 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0104982:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0104987:	b8 00 00 00 00       	mov    $0x0,%eax
f010498c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010498e:	8a 0a                	mov    (%edx),%cl
f0104990:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104993:	80 fb 09             	cmp    $0x9,%bl
f0104996:	77 08                	ja     f01049a0 <strtol+0x82>
			dig = *s - '0';
f0104998:	0f be c9             	movsbl %cl,%ecx
f010499b:	83 e9 30             	sub    $0x30,%ecx
f010499e:	eb 1e                	jmp    f01049be <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01049a0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01049a3:	80 fb 19             	cmp    $0x19,%bl
f01049a6:	77 08                	ja     f01049b0 <strtol+0x92>
			dig = *s - 'a' + 10;
f01049a8:	0f be c9             	movsbl %cl,%ecx
f01049ab:	83 e9 57             	sub    $0x57,%ecx
f01049ae:	eb 0e                	jmp    f01049be <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01049b0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01049b3:	80 fb 19             	cmp    $0x19,%bl
f01049b6:	77 13                	ja     f01049cb <strtol+0xad>
			dig = *s - 'A' + 10;
f01049b8:	0f be c9             	movsbl %cl,%ecx
f01049bb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01049be:	39 f1                	cmp    %esi,%ecx
f01049c0:	7d 0d                	jge    f01049cf <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f01049c2:	42                   	inc    %edx
f01049c3:	0f af c6             	imul   %esi,%eax
f01049c6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f01049c9:	eb c3                	jmp    f010498e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01049cb:	89 c1                	mov    %eax,%ecx
f01049cd:	eb 02                	jmp    f01049d1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01049cf:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01049d1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01049d5:	74 05                	je     f01049dc <strtol+0xbe>
		*endptr = (char *) s;
f01049d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01049da:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01049dc:	85 ff                	test   %edi,%edi
f01049de:	74 04                	je     f01049e4 <strtol+0xc6>
f01049e0:	89 c8                	mov    %ecx,%eax
f01049e2:	f7 d8                	neg    %eax
}
f01049e4:	5b                   	pop    %ebx
f01049e5:	5e                   	pop    %esi
f01049e6:	5f                   	pop    %edi
f01049e7:	c9                   	leave  
f01049e8:	c3                   	ret    
f01049e9:	00 00                	add    %al,(%eax)
	...

f01049ec <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01049ec:	55                   	push   %ebp
f01049ed:	89 e5                	mov    %esp,%ebp
f01049ef:	57                   	push   %edi
f01049f0:	56                   	push   %esi
f01049f1:	83 ec 10             	sub    $0x10,%esp
f01049f4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01049f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01049fa:	89 7d f0             	mov    %edi,-0x10(%ebp)
f01049fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0104a00:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0104a03:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0104a06:	85 c0                	test   %eax,%eax
f0104a08:	75 2e                	jne    f0104a38 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0104a0a:	39 f1                	cmp    %esi,%ecx
f0104a0c:	77 5a                	ja     f0104a68 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0104a0e:	85 c9                	test   %ecx,%ecx
f0104a10:	75 0b                	jne    f0104a1d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0104a12:	b8 01 00 00 00       	mov    $0x1,%eax
f0104a17:	31 d2                	xor    %edx,%edx
f0104a19:	f7 f1                	div    %ecx
f0104a1b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0104a1d:	31 d2                	xor    %edx,%edx
f0104a1f:	89 f0                	mov    %esi,%eax
f0104a21:	f7 f1                	div    %ecx
f0104a23:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104a25:	89 f8                	mov    %edi,%eax
f0104a27:	f7 f1                	div    %ecx
f0104a29:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104a2b:	89 f8                	mov    %edi,%eax
f0104a2d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104a2f:	83 c4 10             	add    $0x10,%esp
f0104a32:	5e                   	pop    %esi
f0104a33:	5f                   	pop    %edi
f0104a34:	c9                   	leave  
f0104a35:	c3                   	ret    
f0104a36:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0104a38:	39 f0                	cmp    %esi,%eax
f0104a3a:	77 1c                	ja     f0104a58 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0104a3c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f0104a3f:	83 f7 1f             	xor    $0x1f,%edi
f0104a42:	75 3c                	jne    f0104a80 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0104a44:	39 f0                	cmp    %esi,%eax
f0104a46:	0f 82 90 00 00 00    	jb     f0104adc <__udivdi3+0xf0>
f0104a4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104a4f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0104a52:	0f 86 84 00 00 00    	jbe    f0104adc <__udivdi3+0xf0>
f0104a58:	31 f6                	xor    %esi,%esi
f0104a5a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104a5c:	89 f8                	mov    %edi,%eax
f0104a5e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104a60:	83 c4 10             	add    $0x10,%esp
f0104a63:	5e                   	pop    %esi
f0104a64:	5f                   	pop    %edi
f0104a65:	c9                   	leave  
f0104a66:	c3                   	ret    
f0104a67:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104a68:	89 f2                	mov    %esi,%edx
f0104a6a:	89 f8                	mov    %edi,%eax
f0104a6c:	f7 f1                	div    %ecx
f0104a6e:	89 c7                	mov    %eax,%edi
f0104a70:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104a72:	89 f8                	mov    %edi,%eax
f0104a74:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104a76:	83 c4 10             	add    $0x10,%esp
f0104a79:	5e                   	pop    %esi
f0104a7a:	5f                   	pop    %edi
f0104a7b:	c9                   	leave  
f0104a7c:	c3                   	ret    
f0104a7d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0104a80:	89 f9                	mov    %edi,%ecx
f0104a82:	d3 e0                	shl    %cl,%eax
f0104a84:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0104a87:	b8 20 00 00 00       	mov    $0x20,%eax
f0104a8c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0104a8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a91:	88 c1                	mov    %al,%cl
f0104a93:	d3 ea                	shr    %cl,%edx
f0104a95:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104a98:	09 ca                	or     %ecx,%edx
f0104a9a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0104a9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104aa0:	89 f9                	mov    %edi,%ecx
f0104aa2:	d3 e2                	shl    %cl,%edx
f0104aa4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0104aa7:	89 f2                	mov    %esi,%edx
f0104aa9:	88 c1                	mov    %al,%cl
f0104aab:	d3 ea                	shr    %cl,%edx
f0104aad:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0104ab0:	89 f2                	mov    %esi,%edx
f0104ab2:	89 f9                	mov    %edi,%ecx
f0104ab4:	d3 e2                	shl    %cl,%edx
f0104ab6:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0104ab9:	88 c1                	mov    %al,%cl
f0104abb:	d3 ee                	shr    %cl,%esi
f0104abd:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0104abf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104ac2:	89 f0                	mov    %esi,%eax
f0104ac4:	89 ca                	mov    %ecx,%edx
f0104ac6:	f7 75 ec             	divl   -0x14(%ebp)
f0104ac9:	89 d1                	mov    %edx,%ecx
f0104acb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0104acd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104ad0:	39 d1                	cmp    %edx,%ecx
f0104ad2:	72 28                	jb     f0104afc <__udivdi3+0x110>
f0104ad4:	74 1a                	je     f0104af0 <__udivdi3+0x104>
f0104ad6:	89 f7                	mov    %esi,%edi
f0104ad8:	31 f6                	xor    %esi,%esi
f0104ada:	eb 80                	jmp    f0104a5c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0104adc:	31 f6                	xor    %esi,%esi
f0104ade:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104ae3:	89 f8                	mov    %edi,%eax
f0104ae5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104ae7:	83 c4 10             	add    $0x10,%esp
f0104aea:	5e                   	pop    %esi
f0104aeb:	5f                   	pop    %edi
f0104aec:	c9                   	leave  
f0104aed:	c3                   	ret    
f0104aee:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0104af0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104af3:	89 f9                	mov    %edi,%ecx
f0104af5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104af7:	39 c2                	cmp    %eax,%edx
f0104af9:	73 db                	jae    f0104ad6 <__udivdi3+0xea>
f0104afb:	90                   	nop
		{
		  q0--;
f0104afc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104aff:	31 f6                	xor    %esi,%esi
f0104b01:	e9 56 ff ff ff       	jmp    f0104a5c <__udivdi3+0x70>
	...

f0104b08 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0104b08:	55                   	push   %ebp
f0104b09:	89 e5                	mov    %esp,%ebp
f0104b0b:	57                   	push   %edi
f0104b0c:	56                   	push   %esi
f0104b0d:	83 ec 20             	sub    $0x20,%esp
f0104b10:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b13:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0104b16:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0104b19:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0104b1c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0104b1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0104b22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0104b25:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0104b27:	85 ff                	test   %edi,%edi
f0104b29:	75 15                	jne    f0104b40 <__umoddi3+0x38>
    {
      if (d0 > n1)
f0104b2b:	39 f1                	cmp    %esi,%ecx
f0104b2d:	0f 86 99 00 00 00    	jbe    f0104bcc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104b33:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0104b35:	89 d0                	mov    %edx,%eax
f0104b37:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104b39:	83 c4 20             	add    $0x20,%esp
f0104b3c:	5e                   	pop    %esi
f0104b3d:	5f                   	pop    %edi
f0104b3e:	c9                   	leave  
f0104b3f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0104b40:	39 f7                	cmp    %esi,%edi
f0104b42:	0f 87 a4 00 00 00    	ja     f0104bec <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0104b48:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0104b4b:	83 f0 1f             	xor    $0x1f,%eax
f0104b4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104b51:	0f 84 a1 00 00 00    	je     f0104bf8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0104b57:	89 f8                	mov    %edi,%eax
f0104b59:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104b5c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0104b5e:	bf 20 00 00 00       	mov    $0x20,%edi
f0104b63:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0104b66:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104b69:	89 f9                	mov    %edi,%ecx
f0104b6b:	d3 ea                	shr    %cl,%edx
f0104b6d:	09 c2                	or     %eax,%edx
f0104b6f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0104b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104b75:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104b78:	d3 e0                	shl    %cl,%eax
f0104b7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0104b7d:	89 f2                	mov    %esi,%edx
f0104b7f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0104b81:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104b84:	d3 e0                	shl    %cl,%eax
f0104b86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0104b89:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104b8c:	89 f9                	mov    %edi,%ecx
f0104b8e:	d3 e8                	shr    %cl,%eax
f0104b90:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0104b92:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0104b94:	89 f2                	mov    %esi,%edx
f0104b96:	f7 75 f0             	divl   -0x10(%ebp)
f0104b99:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0104b9b:	f7 65 f4             	mull   -0xc(%ebp)
f0104b9e:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0104ba1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104ba3:	39 d6                	cmp    %edx,%esi
f0104ba5:	72 71                	jb     f0104c18 <__umoddi3+0x110>
f0104ba7:	74 7f                	je     f0104c28 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0104ba9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bac:	29 c8                	sub    %ecx,%eax
f0104bae:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0104bb0:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104bb3:	d3 e8                	shr    %cl,%eax
f0104bb5:	89 f2                	mov    %esi,%edx
f0104bb7:	89 f9                	mov    %edi,%ecx
f0104bb9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0104bbb:	09 d0                	or     %edx,%eax
f0104bbd:	89 f2                	mov    %esi,%edx
f0104bbf:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104bc2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104bc4:	83 c4 20             	add    $0x20,%esp
f0104bc7:	5e                   	pop    %esi
f0104bc8:	5f                   	pop    %edi
f0104bc9:	c9                   	leave  
f0104bca:	c3                   	ret    
f0104bcb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0104bcc:	85 c9                	test   %ecx,%ecx
f0104bce:	75 0b                	jne    f0104bdb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0104bd0:	b8 01 00 00 00       	mov    $0x1,%eax
f0104bd5:	31 d2                	xor    %edx,%edx
f0104bd7:	f7 f1                	div    %ecx
f0104bd9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0104bdb:	89 f0                	mov    %esi,%eax
f0104bdd:	31 d2                	xor    %edx,%edx
f0104bdf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104be4:	f7 f1                	div    %ecx
f0104be6:	e9 4a ff ff ff       	jmp    f0104b35 <__umoddi3+0x2d>
f0104beb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0104bec:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104bee:	83 c4 20             	add    $0x20,%esp
f0104bf1:	5e                   	pop    %esi
f0104bf2:	5f                   	pop    %edi
f0104bf3:	c9                   	leave  
f0104bf4:	c3                   	ret    
f0104bf5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0104bf8:	39 f7                	cmp    %esi,%edi
f0104bfa:	72 05                	jb     f0104c01 <__umoddi3+0xf9>
f0104bfc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0104bff:	77 0c                	ja     f0104c0d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0104c01:	89 f2                	mov    %esi,%edx
f0104c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c06:	29 c8                	sub    %ecx,%eax
f0104c08:	19 fa                	sbb    %edi,%edx
f0104c0a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0104c0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104c10:	83 c4 20             	add    $0x20,%esp
f0104c13:	5e                   	pop    %esi
f0104c14:	5f                   	pop    %edi
f0104c15:	c9                   	leave  
f0104c16:	c3                   	ret    
f0104c17:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104c18:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104c1b:	89 c1                	mov    %eax,%ecx
f0104c1d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0104c20:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0104c23:	eb 84                	jmp    f0104ba9 <__umoddi3+0xa1>
f0104c25:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104c28:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0104c2b:	72 eb                	jb     f0104c18 <__umoddi3+0x110>
f0104c2d:	89 f2                	mov    %esi,%edx
f0104c2f:	e9 75 ff ff ff       	jmp    f0104ba9 <__umoddi3+0xa1>
