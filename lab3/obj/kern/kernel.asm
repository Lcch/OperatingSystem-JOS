
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
f0100080:	e8 d0 46 00 00       	call   f0104755 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100085:	e8 85 04 00 00       	call   f010050f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010008a:	83 c4 08             	add    $0x8,%esp
f010008d:	68 ac 1a 00 00       	push   $0x1aac
f0100092:	68 c0 4b 10 f0       	push   $0xf0104bc0
f0100097:	e8 91 34 00 00       	call   f010352d <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f010009c:	e8 0c 16 00 00       	call   f01016ad <mem_init>

	// MSRs init:
	msrs_init();
f01000a1:	e8 9a ff ff ff       	call   f0100040 <msrs_init>

    // cprintf("mem_init done! \n");
	// Lab 3 user environment initialization functions
	env_init();
f01000a6:	e8 6c 2e 00 00       	call   f0102f17 <env_init>
    // cprintf("env_init done! \n");
	trap_init();
f01000ab:	e8 f1 34 00 00       	call   f01035a1 <trap_init>
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
f01000bf:	e8 61 30 00 00       	call   f0103125 <env_create>
#endif // TEST*
    
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000c4:	83 c4 04             	add    $0x4,%esp
f01000c7:	ff 35 7c 04 1e f0    	pushl  0xf01e047c
f01000cd:	e8 96 33 00 00       	call   f0103468 <env_run>

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
f01000f7:	68 db 4b 10 f0       	push   $0xf0104bdb
f01000fc:	e8 2c 34 00 00       	call   f010352d <cprintf>
	vcprintf(fmt, ap);
f0100101:	83 c4 08             	add    $0x8,%esp
f0100104:	53                   	push   %ebx
f0100105:	56                   	push   %esi
f0100106:	e8 fc 33 00 00       	call   f0103507 <vcprintf>
	cprintf("\n");
f010010b:	c7 04 24 af 4e 10 f0 	movl   $0xf0104eaf,(%esp)
f0100112:	e8 16 34 00 00       	call   f010352d <cprintf>
	va_end(ap);
f0100117:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010011a:	83 ec 0c             	sub    $0xc,%esp
f010011d:	6a 00                	push   $0x0
f010011f:	e8 4d 0d 00 00       	call   f0100e71 <monitor>
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
f0100139:	68 f3 4b 10 f0       	push   $0xf0104bf3
f010013e:	e8 ea 33 00 00       	call   f010352d <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	53                   	push   %ebx
f0100147:	ff 75 10             	pushl  0x10(%ebp)
f010014a:	e8 b8 33 00 00       	call   f0103507 <vcprintf>
	cprintf("\n");
f010014f:	c7 04 24 af 4e 10 f0 	movl   $0xf0104eaf,(%esp)
f0100156:	e8 d2 33 00 00       	call   f010352d <cprintf>
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
f0100345:	e8 55 44 00 00       	call   f010479f <memmove>
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
f01003e4:	8a 82 40 4c 10 f0    	mov    -0xfefb3c0(%edx),%al
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
f0100420:	0f b6 82 40 4c 10 f0 	movzbl -0xfefb3c0(%edx),%eax
f0100427:	0b 05 68 04 1e f0    	or     0xf01e0468,%eax
	shift ^= togglecode[data];
f010042d:	0f b6 8a 40 4d 10 f0 	movzbl -0xfefb2c0(%edx),%ecx
f0100434:	31 c8                	xor    %ecx,%eax
f0100436:	a3 68 04 1e f0       	mov    %eax,0xf01e0468

	c = charcode[shift & (CTL | SHIFT)][data];
f010043b:	89 c1                	mov    %eax,%ecx
f010043d:	83 e1 03             	and    $0x3,%ecx
f0100440:	8b 0c 8d 40 4e 10 f0 	mov    -0xfefb1c0(,%ecx,4),%ecx
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
f0100478:	68 0d 4c 10 f0       	push   $0xf0104c0d
f010047d:	e8 ab 30 00 00       	call   f010352d <cprintf>
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
f01005d9:	68 19 4c 10 f0       	push   $0xf0104c19
f01005de:	e8 4a 2f 00 00       	call   f010352d <cprintf>
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
f0100622:	68 50 4e 10 f0       	push   $0xf0104e50
f0100627:	e8 01 2f 00 00       	call   f010352d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010062c:	83 c4 08             	add    $0x8,%esp
f010062f:	68 0c 00 10 00       	push   $0x10000c
f0100634:	68 7c 50 10 f0       	push   $0xf010507c
f0100639:	e8 ef 2e 00 00       	call   f010352d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010063e:	83 c4 0c             	add    $0xc,%esp
f0100641:	68 0c 00 10 00       	push   $0x10000c
f0100646:	68 0c 00 10 f0       	push   $0xf010000c
f010064b:	68 a4 50 10 f0       	push   $0xf01050a4
f0100650:	e8 d8 2e 00 00       	call   f010352d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100655:	83 c4 0c             	add    $0xc,%esp
f0100658:	68 a4 4b 10 00       	push   $0x104ba4
f010065d:	68 a4 4b 10 f0       	push   $0xf0104ba4
f0100662:	68 c8 50 10 f0       	push   $0xf01050c8
f0100667:	e8 c1 2e 00 00       	call   f010352d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010066c:	83 c4 0c             	add    $0xc,%esp
f010066f:	68 24 02 1e 00       	push   $0x1e0224
f0100674:	68 24 02 1e f0       	push   $0xf01e0224
f0100679:	68 ec 50 10 f0       	push   $0xf01050ec
f010067e:	e8 aa 2e 00 00       	call   f010352d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100683:	83 c4 0c             	add    $0xc,%esp
f0100686:	68 50 11 1e 00       	push   $0x1e1150
f010068b:	68 50 11 1e f0       	push   $0xf01e1150
f0100690:	68 10 51 10 f0       	push   $0xf0105110
f0100695:	e8 93 2e 00 00       	call   f010352d <cprintf>
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
f01006bc:	68 34 51 10 f0       	push   $0xf0105134
f01006c1:	e8 67 2e 00 00       	call   f010352d <cprintf>
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
f01006dc:	ff b3 e4 55 10 f0    	pushl  -0xfefaa1c(%ebx)
f01006e2:	ff b3 e0 55 10 f0    	pushl  -0xfefaa20(%ebx)
f01006e8:	68 69 4e 10 f0       	push   $0xf0104e69
f01006ed:	e8 3b 2e 00 00       	call   f010352d <cprintf>
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
f0100717:	68 60 51 10 f0       	push   $0xf0105160
f010071c:	e8 0c 2e 00 00       	call   f010352d <cprintf>

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
f0100735:	68 72 4e 10 f0       	push   $0xf0104e72
f010073a:	e8 ee 2d 00 00       	call   f010352d <cprintf>
    env_run(curenv);
f010073f:	83 c4 04             	add    $0x4,%esp
f0100742:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0100748:	e8 1b 2d 00 00       	call   f0103468 <env_run>

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
f010075d:	68 8c 51 10 f0       	push   $0xf010518c
f0100762:	e8 c6 2d 00 00       	call   f010352d <cprintf>
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
f010077e:	e8 e5 2c 00 00       	call   f0103468 <env_run>

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
f0100798:	68 c0 51 10 f0       	push   $0xf01051c0
f010079d:	e8 8b 2d 00 00       	call   f010352d <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f01007a2:	c7 04 24 f4 51 10 f0 	movl   $0xf01051f4,(%esp)
f01007a9:	e8 7f 2d 00 00       	call   f010352d <cprintf>
f01007ae:	83 c4 10             	add    $0x10,%esp
f01007b1:	e9 1a 01 00 00       	jmp    f01008d0 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f01007b6:	83 ec 04             	sub    $0x4,%esp
f01007b9:	6a 00                	push   $0x0
f01007bb:	6a 00                	push   $0x0
f01007bd:	ff 76 04             	pushl  0x4(%esi)
f01007c0:	e8 c9 40 00 00       	call   f010488e <strtol>
f01007c5:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f01007c7:	83 c4 0c             	add    $0xc,%esp
f01007ca:	6a 00                	push   $0x0
f01007cc:	6a 00                	push   $0x0
f01007ce:	ff 76 08             	pushl  0x8(%esi)
f01007d1:	e8 b8 40 00 00       	call   f010488e <strtol>
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
f01007f5:	68 7c 4e 10 f0       	push   $0xf0104e7c
f01007fa:	e8 2e 2d 00 00       	call   f010352d <cprintf>
        
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
f0100818:	68 8d 4e 10 f0       	push   $0xf0104e8d
f010081d:	e8 0b 2d 00 00       	call   f010352d <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f0100822:	83 c4 0c             	add    $0xc,%esp
f0100825:	6a 00                	push   $0x0
f0100827:	53                   	push   %ebx
f0100828:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f010082e:	e8 6b 0c 00 00       	call   f010149e <pgdir_walk>
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
f0100845:	68 a4 4e 10 f0       	push   $0xf0104ea4
f010084a:	e8 de 2c 00 00       	call   f010352d <cprintf>
f010084f:	83 c4 10             	add    $0x10,%esp
f0100852:	eb 74                	jmp    f01008c8 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f0100854:	83 ec 08             	sub    $0x8,%esp
f0100857:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010085c:	50                   	push   %eax
f010085d:	68 b1 4e 10 f0       	push   $0xf0104eb1
f0100862:	e8 c6 2c 00 00       	call   f010352d <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f0100867:	83 c4 10             	add    $0x10,%esp
f010086a:	f6 03 04             	testb  $0x4,(%ebx)
f010086d:	74 12                	je     f0100881 <mon_showmappings+0xfe>
f010086f:	83 ec 0c             	sub    $0xc,%esp
f0100872:	68 b9 4e 10 f0       	push   $0xf0104eb9
f0100877:	e8 b1 2c 00 00       	call   f010352d <cprintf>
f010087c:	83 c4 10             	add    $0x10,%esp
f010087f:	eb 10                	jmp    f0100891 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f0100881:	83 ec 0c             	sub    $0xc,%esp
f0100884:	68 c6 4e 10 f0       	push   $0xf0104ec6
f0100889:	e8 9f 2c 00 00       	call   f010352d <cprintf>
f010088e:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f0100891:	f6 03 02             	testb  $0x2,(%ebx)
f0100894:	74 12                	je     f01008a8 <mon_showmappings+0x125>
f0100896:	83 ec 0c             	sub    $0xc,%esp
f0100899:	68 d3 4e 10 f0       	push   $0xf0104ed3
f010089e:	e8 8a 2c 00 00       	call   f010352d <cprintf>
f01008a3:	83 c4 10             	add    $0x10,%esp
f01008a6:	eb 10                	jmp    f01008b8 <mon_showmappings+0x135>
                else cprintf(" R ");
f01008a8:	83 ec 0c             	sub    $0xc,%esp
f01008ab:	68 d8 4e 10 f0       	push   $0xf0104ed8
f01008b0:	e8 78 2c 00 00       	call   f010352d <cprintf>
f01008b5:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f01008b8:	83 ec 0c             	sub    $0xc,%esp
f01008bb:	68 af 4e 10 f0       	push   $0xf0104eaf
f01008c0:	e8 68 2c 00 00       	call   f010352d <cprintf>
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
f01008f2:	68 1c 52 10 f0       	push   $0xf010521c
f01008f7:	e8 31 2c 00 00       	call   f010352d <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f01008fc:	c7 04 24 6c 52 10 f0 	movl   $0xf010526c,(%esp)
f0100903:	e8 25 2c 00 00       	call   f010352d <cprintf>
f0100908:	83 c4 10             	add    $0x10,%esp
f010090b:	e9 a5 01 00 00       	jmp    f0100ab5 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f0100910:	83 ec 04             	sub    $0x4,%esp
f0100913:	6a 00                	push   $0x0
f0100915:	6a 00                	push   $0x0
f0100917:	ff 73 04             	pushl  0x4(%ebx)
f010091a:	e8 6f 3f 00 00       	call   f010488e <strtol>
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
f0100960:	e8 39 0b 00 00       	call   f010149e <pgdir_walk>
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
f010097e:	68 90 52 10 f0       	push   $0xf0105290
f0100983:	e8 a5 2b 00 00       	call   f010352d <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100988:	83 c4 10             	add    $0x10,%esp
f010098b:	f6 03 02             	testb  $0x2,(%ebx)
f010098e:	74 12                	je     f01009a2 <mon_setpermission+0xc5>
f0100990:	83 ec 0c             	sub    $0xc,%esp
f0100993:	68 dc 4e 10 f0       	push   $0xf0104edc
f0100998:	e8 90 2b 00 00       	call   f010352d <cprintf>
f010099d:	83 c4 10             	add    $0x10,%esp
f01009a0:	eb 10                	jmp    f01009b2 <mon_setpermission+0xd5>
f01009a2:	83 ec 0c             	sub    $0xc,%esp
f01009a5:	68 df 4e 10 f0       	push   $0xf0104edf
f01009aa:	e8 7e 2b 00 00       	call   f010352d <cprintf>
f01009af:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f01009b2:	f6 03 04             	testb  $0x4,(%ebx)
f01009b5:	74 12                	je     f01009c9 <mon_setpermission+0xec>
f01009b7:	83 ec 0c             	sub    $0xc,%esp
f01009ba:	68 c2 5f 10 f0       	push   $0xf0105fc2
f01009bf:	e8 69 2b 00 00       	call   f010352d <cprintf>
f01009c4:	83 c4 10             	add    $0x10,%esp
f01009c7:	eb 10                	jmp    f01009d9 <mon_setpermission+0xfc>
f01009c9:	83 ec 0c             	sub    $0xc,%esp
f01009cc:	68 fe 63 10 f0       	push   $0xf01063fe
f01009d1:	e8 57 2b 00 00       	call   f010352d <cprintf>
f01009d6:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f01009d9:	f6 03 01             	testb  $0x1,(%ebx)
f01009dc:	74 12                	je     f01009f0 <mon_setpermission+0x113>
f01009de:	83 ec 0c             	sub    $0xc,%esp
f01009e1:	68 36 60 10 f0       	push   $0xf0106036
f01009e6:	e8 42 2b 00 00       	call   f010352d <cprintf>
f01009eb:	83 c4 10             	add    $0x10,%esp
f01009ee:	eb 10                	jmp    f0100a00 <mon_setpermission+0x123>
f01009f0:	83 ec 0c             	sub    $0xc,%esp
f01009f3:	68 e0 4e 10 f0       	push   $0xf0104ee0
f01009f8:	e8 30 2b 00 00       	call   f010352d <cprintf>
f01009fd:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f0100a00:	83 ec 0c             	sub    $0xc,%esp
f0100a03:	68 e2 4e 10 f0       	push   $0xf0104ee2
f0100a08:	e8 20 2b 00 00       	call   f010352d <cprintf>
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
f0100a26:	68 dc 4e 10 f0       	push   $0xf0104edc
f0100a2b:	e8 fd 2a 00 00       	call   f010352d <cprintf>
f0100a30:	83 c4 10             	add    $0x10,%esp
f0100a33:	eb 10                	jmp    f0100a45 <mon_setpermission+0x168>
f0100a35:	83 ec 0c             	sub    $0xc,%esp
f0100a38:	68 df 4e 10 f0       	push   $0xf0104edf
f0100a3d:	e8 eb 2a 00 00       	call   f010352d <cprintf>
f0100a42:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100a45:	f6 03 04             	testb  $0x4,(%ebx)
f0100a48:	74 12                	je     f0100a5c <mon_setpermission+0x17f>
f0100a4a:	83 ec 0c             	sub    $0xc,%esp
f0100a4d:	68 c2 5f 10 f0       	push   $0xf0105fc2
f0100a52:	e8 d6 2a 00 00       	call   f010352d <cprintf>
f0100a57:	83 c4 10             	add    $0x10,%esp
f0100a5a:	eb 10                	jmp    f0100a6c <mon_setpermission+0x18f>
f0100a5c:	83 ec 0c             	sub    $0xc,%esp
f0100a5f:	68 fe 63 10 f0       	push   $0xf01063fe
f0100a64:	e8 c4 2a 00 00       	call   f010352d <cprintf>
f0100a69:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100a6c:	f6 03 01             	testb  $0x1,(%ebx)
f0100a6f:	74 12                	je     f0100a83 <mon_setpermission+0x1a6>
f0100a71:	83 ec 0c             	sub    $0xc,%esp
f0100a74:	68 36 60 10 f0       	push   $0xf0106036
f0100a79:	e8 af 2a 00 00       	call   f010352d <cprintf>
f0100a7e:	83 c4 10             	add    $0x10,%esp
f0100a81:	eb 10                	jmp    f0100a93 <mon_setpermission+0x1b6>
f0100a83:	83 ec 0c             	sub    $0xc,%esp
f0100a86:	68 e0 4e 10 f0       	push   $0xf0104ee0
f0100a8b:	e8 9d 2a 00 00       	call   f010352d <cprintf>
f0100a90:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f0100a93:	83 ec 0c             	sub    $0xc,%esp
f0100a96:	68 af 4e 10 f0       	push   $0xf0104eaf
f0100a9b:	e8 8d 2a 00 00       	call   f010352d <cprintf>
f0100aa0:	83 c4 10             	add    $0x10,%esp
f0100aa3:	eb 10                	jmp    f0100ab5 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f0100aa5:	83 ec 0c             	sub    $0xc,%esp
f0100aa8:	68 a4 4e 10 f0       	push   $0xf0104ea4
f0100aad:	e8 7b 2a 00 00       	call   f010352d <cprintf>
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
f0100ad3:	68 b4 52 10 f0       	push   $0xf01052b4
f0100ad8:	e8 50 2a 00 00       	call   f010352d <cprintf>
        cprintf("num show the color attribute. \n");
f0100add:	c7 04 24 e4 52 10 f0 	movl   $0xf01052e4,(%esp)
f0100ae4:	e8 44 2a 00 00       	call   f010352d <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100ae9:	c7 04 24 04 53 10 f0 	movl   $0xf0105304,(%esp)
f0100af0:	e8 38 2a 00 00       	call   f010352d <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100af5:	c7 04 24 38 53 10 f0 	movl   $0xf0105338,(%esp)
f0100afc:	e8 2c 2a 00 00       	call   f010352d <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100b01:	c7 04 24 7c 53 10 f0 	movl   $0xf010537c,(%esp)
f0100b08:	e8 20 2a 00 00       	call   f010352d <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100b0d:	c7 04 24 f3 4e 10 f0 	movl   $0xf0104ef3,(%esp)
f0100b14:	e8 14 2a 00 00       	call   f010352d <cprintf>
        cprintf("         set the background color to black\n");
f0100b19:	c7 04 24 c0 53 10 f0 	movl   $0xf01053c0,(%esp)
f0100b20:	e8 08 2a 00 00       	call   f010352d <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100b25:	c7 04 24 ec 53 10 f0 	movl   $0xf01053ec,(%esp)
f0100b2c:	e8 fc 29 00 00       	call   f010352d <cprintf>
f0100b31:	83 c4 10             	add    $0x10,%esp
f0100b34:	eb 52                	jmp    f0100b88 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100b36:	83 ec 0c             	sub    $0xc,%esp
f0100b39:	ff 73 04             	pushl  0x4(%ebx)
f0100b3c:	e8 4b 3a 00 00       	call   f010458c <strlen>
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
f0100b7b:	68 20 54 10 f0       	push   $0xf0105420
f0100b80:	e8 a8 29 00 00       	call   f010352d <cprintf>
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
f0100ba3:	74 6d                	je     f0100c12 <mon_backtrace+0x7e>
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100ba5:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
f0100ba8:	8b 5e 04             	mov    0x4(%esi),%ebx
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100bab:	ff 76 18             	pushl  0x18(%esi)
f0100bae:	ff 76 14             	pushl  0x14(%esi)
f0100bb1:	ff 76 10             	pushl  0x10(%esi)
f0100bb4:	ff 76 0c             	pushl  0xc(%esi)
f0100bb7:	ff 76 08             	pushl  0x8(%esi)
f0100bba:	53                   	push   %ebx
f0100bbb:	56                   	push   %esi
f0100bbc:	68 44 54 10 f0       	push   $0xf0105444
f0100bc1:	e8 67 29 00 00       	call   f010352d <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100bc6:	83 c4 18             	add    $0x18,%esp
f0100bc9:	57                   	push   %edi
f0100bca:	ff 76 04             	pushl  0x4(%esi)
f0100bcd:	e8 0b 31 00 00       	call   f0103cdd <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100bd2:	83 c4 0c             	add    $0xc,%esp
f0100bd5:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100bd8:	ff 75 d0             	pushl  -0x30(%ebp)
f0100bdb:	68 0f 4f 10 f0       	push   $0xf0104f0f
f0100be0:	e8 48 29 00 00       	call   f010352d <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100be5:	83 c4 0c             	add    $0xc,%esp
f0100be8:	ff 75 d8             	pushl  -0x28(%ebp)
f0100beb:	ff 75 dc             	pushl  -0x24(%ebp)
f0100bee:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0100bf3:	e8 35 29 00 00       	call   f010352d <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100bf8:	83 c4 08             	add    $0x8,%esp
f0100bfb:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100bfe:	53                   	push   %ebx
f0100bff:	68 24 4f 10 f0       	push   $0xf0104f24
f0100c04:	e8 24 29 00 00       	call   f010352d <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100c09:	8b 36                	mov    (%esi),%esi
f0100c0b:	83 c4 10             	add    $0x10,%esp
f0100c0e:	85 f6                	test   %esi,%esi
f0100c10:	75 96                	jne    f0100ba8 <mon_backtrace+0x14>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100c12:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c1a:	5b                   	pop    %ebx
f0100c1b:	5e                   	pop    %esi
f0100c1c:	5f                   	pop    %edi
f0100c1d:	c9                   	leave  
f0100c1e:	c3                   	ret    

f0100c1f <pa_con>:
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
f0100c1f:	55                   	push   %ebp
f0100c20:	89 e5                	mov    %esp,%ebp
f0100c22:	53                   	push   %ebx
f0100c23:	83 ec 04             	sub    $0x4,%esp
f0100c26:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
f0100c2c:	8b 15 4c 11 1e f0    	mov    0xf01e114c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c32:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100c38:	77 15                	ja     f0100c4f <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c3a:	52                   	push   %edx
f0100c3b:	68 7c 54 10 f0       	push   $0xf010547c
f0100c40:	68 96 00 00 00       	push   $0x96
f0100c45:	68 29 4f 10 f0       	push   $0xf0104f29
f0100c4a:	e8 83 f4 ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100c4f:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100c55:	39 d0                	cmp    %edx,%eax
f0100c57:	72 18                	jb     f0100c71 <pa_con+0x52>
f0100c59:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
f0100c5f:	39 d8                	cmp    %ebx,%eax
f0100c61:	73 0e                	jae    f0100c71 <pa_con+0x52>
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
f0100c63:	29 d0                	sub    %edx,%eax
f0100c65:	8b 80 00 00 00 ef    	mov    -0x11000000(%eax),%eax
f0100c6b:	89 01                	mov    %eax,(%ecx)
        return true;
f0100c6d:	b0 01                	mov    $0x1,%al
f0100c6f:	eb 56                	jmp    f0100cc7 <pa_con+0xa8>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c71:	ba 00 90 11 f0       	mov    $0xf0119000,%edx
f0100c76:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100c7c:	77 15                	ja     f0100c93 <pa_con+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c7e:	52                   	push   %edx
f0100c7f:	68 7c 54 10 f0       	push   $0xf010547c
f0100c84:	68 9b 00 00 00       	push   $0x9b
f0100c89:	68 29 4f 10 f0       	push   $0xf0104f29
f0100c8e:	e8 3f f4 ff ff       	call   f01000d2 <_panic>
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
f0100c93:	3d 00 90 11 00       	cmp    $0x119000,%eax
f0100c98:	72 18                	jb     f0100cb2 <pa_con+0x93>
f0100c9a:	3d 00 10 12 00       	cmp    $0x121000,%eax
f0100c9f:	73 11                	jae    f0100cb2 <pa_con+0x93>
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
f0100ca1:	2d 00 90 11 00       	sub    $0x119000,%eax
f0100ca6:	8b 80 00 80 ff ef    	mov    -0x10008000(%eax),%eax
f0100cac:	89 01                	mov    %eax,(%ecx)
        return true;
f0100cae:	b0 01                	mov    $0x1,%al
f0100cb0:	eb 15                	jmp    f0100cc7 <pa_con+0xa8>
    }
    if (addr < -KERNBASE) {
f0100cb2:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100cb7:	77 0c                	ja     f0100cc5 <pa_con+0xa6>
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
f0100cb9:	8b 80 00 00 00 f0    	mov    -0x10000000(%eax),%eax
f0100cbf:	89 01                	mov    %eax,(%ecx)
        return true;
f0100cc1:	b0 01                	mov    $0x1,%al
f0100cc3:	eb 02                	jmp    f0100cc7 <pa_con+0xa8>
    }
    // Not in virtual memory mapped.
    return false;
f0100cc5:	b0 00                	mov    $0x0,%al
}
f0100cc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100cca:	c9                   	leave  
f0100ccb:	c3                   	ret    

f0100ccc <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
f0100ccc:	55                   	push   %ebp
f0100ccd:	89 e5                	mov    %esp,%ebp
f0100ccf:	57                   	push   %edi
f0100cd0:	56                   	push   %esi
f0100cd1:	53                   	push   %ebx
f0100cd2:	83 ec 2c             	sub    $0x2c,%esp
f0100cd5:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 4) {
f0100cd8:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100cdc:	74 2d                	je     f0100d0b <mon_dump+0x3f>
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
f0100cde:	83 ec 0c             	sub    $0xc,%esp
f0100ce1:	68 a0 54 10 f0       	push   $0xf01054a0
f0100ce6:	e8 42 28 00 00       	call   f010352d <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100ceb:	c7 04 24 d0 54 10 f0 	movl   $0xf01054d0,(%esp)
f0100cf2:	e8 36 28 00 00       	call   f010352d <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100cf7:	c7 04 24 f8 54 10 f0 	movl   $0xf01054f8,(%esp)
f0100cfe:	e8 2a 28 00 00       	call   f010352d <cprintf>
f0100d03:	83 c4 10             	add    $0x10,%esp
f0100d06:	e9 59 01 00 00       	jmp    f0100e64 <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100d0b:	83 ec 04             	sub    $0x4,%esp
f0100d0e:	6a 00                	push   $0x0
f0100d10:	6a 00                	push   $0x0
f0100d12:	ff 76 08             	pushl  0x8(%esi)
f0100d15:	e8 74 3b 00 00       	call   f010488e <strtol>
f0100d1a:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100d1c:	83 c4 0c             	add    $0xc,%esp
f0100d1f:	6a 00                	push   $0x0
f0100d21:	6a 00                	push   $0x0
f0100d23:	ff 76 0c             	pushl  0xc(%esi)
f0100d26:	e8 63 3b 00 00       	call   f010488e <strtol>
        if (laddr > haddr) {
f0100d2b:	83 c4 10             	add    $0x10,%esp
f0100d2e:	39 c3                	cmp    %eax,%ebx
f0100d30:	76 01                	jbe    f0100d33 <mon_dump+0x67>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100d32:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, 4);
f0100d33:	89 df                	mov    %ebx,%edi
f0100d35:	83 e7 fc             	and    $0xfffffffc,%edi
        haddr = ROUNDDOWN(haddr, 4);
f0100d38:	83 e0 fc             	and    $0xfffffffc,%eax
f0100d3b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if (argv[1][0] == 'v') {
f0100d3e:	8b 46 04             	mov    0x4(%esi),%eax
f0100d41:	80 38 76             	cmpb   $0x76,(%eax)
f0100d44:	74 0e                	je     f0100d54 <mon_dump+0x88>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100d46:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100d49:	0f 85 98 00 00 00    	jne    f0100de7 <mon_dump+0x11b>
f0100d4f:	e9 00 01 00 00       	jmp    f0100e54 <mon_dump+0x188>
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100d54:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100d57:	74 7c                	je     f0100dd5 <mon_dump+0x109>
f0100d59:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100d5b:	39 fb                	cmp    %edi,%ebx
f0100d5d:	74 15                	je     f0100d74 <mon_dump+0xa8>
f0100d5f:	f6 c3 0f             	test   $0xf,%bl
f0100d62:	75 21                	jne    f0100d85 <mon_dump+0xb9>
                    if (now != laddr) cprintf("\n"); 
f0100d64:	83 ec 0c             	sub    $0xc,%esp
f0100d67:	68 af 4e 10 f0       	push   $0xf0104eaf
f0100d6c:	e8 bc 27 00 00       	call   f010352d <cprintf>
f0100d71:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100d74:	83 ec 08             	sub    $0x8,%esp
f0100d77:	53                   	push   %ebx
f0100d78:	68 38 4f 10 f0       	push   $0xf0104f38
f0100d7d:	e8 ab 27 00 00       	call   f010352d <cprintf>
f0100d82:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100d85:	83 ec 04             	sub    $0x4,%esp
f0100d88:	6a 00                	push   $0x0
f0100d8a:	89 d8                	mov    %ebx,%eax
f0100d8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d91:	50                   	push   %eax
f0100d92:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0100d98:	e8 01 07 00 00       	call   f010149e <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100d9d:	83 c4 10             	add    $0x10,%esp
f0100da0:	85 c0                	test   %eax,%eax
f0100da2:	74 19                	je     f0100dbd <mon_dump+0xf1>
f0100da4:	f6 00 01             	testb  $0x1,(%eax)
f0100da7:	74 14                	je     f0100dbd <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100da9:	83 ec 08             	sub    $0x8,%esp
f0100dac:	ff 33                	pushl  (%ebx)
f0100dae:	68 42 4f 10 f0       	push   $0xf0104f42
f0100db3:	e8 75 27 00 00       	call   f010352d <cprintf>
f0100db8:	83 c4 10             	add    $0x10,%esp
f0100dbb:	eb 10                	jmp    f0100dcd <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100dbd:	83 ec 0c             	sub    $0xc,%esp
f0100dc0:	68 4d 4f 10 f0       	push   $0xf0104f4d
f0100dc5:	e8 63 27 00 00       	call   f010352d <cprintf>
f0100dca:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100dcd:	83 c3 04             	add    $0x4,%ebx
f0100dd0:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100dd3:	75 86                	jne    f0100d5b <mon_dump+0x8f>
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
f0100dd5:	83 ec 0c             	sub    $0xc,%esp
f0100dd8:	68 af 4e 10 f0       	push   $0xf0104eaf
f0100ddd:	e8 4b 27 00 00       	call   f010352d <cprintf>
f0100de2:	83 c4 10             	add    $0x10,%esp
f0100de5:	eb 7d                	jmp    f0100e64 <mon_dump+0x198>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100de7:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100de9:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100dec:	39 fb                	cmp    %edi,%ebx
f0100dee:	74 15                	je     f0100e05 <mon_dump+0x139>
f0100df0:	f6 c3 0f             	test   $0xf,%bl
f0100df3:	75 21                	jne    f0100e16 <mon_dump+0x14a>
                    if (now != laddr) cprintf("\n");
f0100df5:	83 ec 0c             	sub    $0xc,%esp
f0100df8:	68 af 4e 10 f0       	push   $0xf0104eaf
f0100dfd:	e8 2b 27 00 00       	call   f010352d <cprintf>
f0100e02:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100e05:	83 ec 08             	sub    $0x8,%esp
f0100e08:	53                   	push   %ebx
f0100e09:	68 38 4f 10 f0       	push   $0xf0104f38
f0100e0e:	e8 1a 27 00 00       	call   f010352d <cprintf>
f0100e13:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f0100e16:	83 ec 08             	sub    $0x8,%esp
f0100e19:	56                   	push   %esi
f0100e1a:	53                   	push   %ebx
f0100e1b:	e8 ff fd ff ff       	call   f0100c1f <pa_con>
f0100e20:	83 c4 10             	add    $0x10,%esp
f0100e23:	84 c0                	test   %al,%al
f0100e25:	74 15                	je     f0100e3c <mon_dump+0x170>
                    cprintf("0x%08x  ", value);
f0100e27:	83 ec 08             	sub    $0x8,%esp
f0100e2a:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100e2d:	68 42 4f 10 f0       	push   $0xf0104f42
f0100e32:	e8 f6 26 00 00       	call   f010352d <cprintf>
f0100e37:	83 c4 10             	add    $0x10,%esp
f0100e3a:	eb 10                	jmp    f0100e4c <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100e3c:	83 ec 0c             	sub    $0xc,%esp
f0100e3f:	68 4b 4f 10 f0       	push   $0xf0104f4b
f0100e44:	e8 e4 26 00 00       	call   f010352d <cprintf>
f0100e49:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100e4c:	83 c3 04             	add    $0x4,%ebx
f0100e4f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100e52:	75 98                	jne    f0100dec <mon_dump+0x120>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f0100e54:	83 ec 0c             	sub    $0xc,%esp
f0100e57:	68 af 4e 10 f0       	push   $0xf0104eaf
f0100e5c:	e8 cc 26 00 00       	call   f010352d <cprintf>
f0100e61:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100e64:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e69:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e6c:	5b                   	pop    %ebx
f0100e6d:	5e                   	pop    %esi
f0100e6e:	5f                   	pop    %edi
f0100e6f:	c9                   	leave  
f0100e70:	c3                   	ret    

f0100e71 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100e71:	55                   	push   %ebp
f0100e72:	89 e5                	mov    %esp,%ebp
f0100e74:	57                   	push   %edi
f0100e75:	56                   	push   %esi
f0100e76:	53                   	push   %ebx
f0100e77:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100e7a:	68 3c 55 10 f0       	push   $0xf010553c
f0100e7f:	e8 a9 26 00 00       	call   f010352d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100e84:	c7 04 24 60 55 10 f0 	movl   $0xf0105560,(%esp)
f0100e8b:	e8 9d 26 00 00       	call   f010352d <cprintf>

	if (tf != NULL)
f0100e90:	83 c4 10             	add    $0x10,%esp
f0100e93:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100e97:	74 0e                	je     f0100ea7 <monitor+0x36>
		print_trapframe(tf);
f0100e99:	83 ec 0c             	sub    $0xc,%esp
f0100e9c:	ff 75 08             	pushl  0x8(%ebp)
f0100e9f:	e8 3c 28 00 00       	call   f01036e0 <print_trapframe>
f0100ea4:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100ea7:	83 ec 0c             	sub    $0xc,%esp
f0100eaa:	68 58 4f 10 f0       	push   $0xf0104f58
f0100eaf:	e8 08 36 00 00       	call   f01044bc <readline>
f0100eb4:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100eb6:	83 c4 10             	add    $0x10,%esp
f0100eb9:	85 c0                	test   %eax,%eax
f0100ebb:	74 ea                	je     f0100ea7 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100ebd:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100ec4:	be 00 00 00 00       	mov    $0x0,%esi
f0100ec9:	eb 04                	jmp    f0100ecf <monitor+0x5e>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100ecb:	c6 03 00             	movb   $0x0,(%ebx)
f0100ece:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100ecf:	8a 03                	mov    (%ebx),%al
f0100ed1:	84 c0                	test   %al,%al
f0100ed3:	74 64                	je     f0100f39 <monitor+0xc8>
f0100ed5:	83 ec 08             	sub    $0x8,%esp
f0100ed8:	0f be c0             	movsbl %al,%eax
f0100edb:	50                   	push   %eax
f0100edc:	68 5c 4f 10 f0       	push   $0xf0104f5c
f0100ee1:	e8 1f 38 00 00       	call   f0104705 <strchr>
f0100ee6:	83 c4 10             	add    $0x10,%esp
f0100ee9:	85 c0                	test   %eax,%eax
f0100eeb:	75 de                	jne    f0100ecb <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100eed:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100ef0:	74 47                	je     f0100f39 <monitor+0xc8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100ef2:	83 fe 0f             	cmp    $0xf,%esi
f0100ef5:	75 14                	jne    f0100f0b <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100ef7:	83 ec 08             	sub    $0x8,%esp
f0100efa:	6a 10                	push   $0x10
f0100efc:	68 61 4f 10 f0       	push   $0xf0104f61
f0100f01:	e8 27 26 00 00       	call   f010352d <cprintf>
f0100f06:	83 c4 10             	add    $0x10,%esp
f0100f09:	eb 9c                	jmp    f0100ea7 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100f0b:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100f0f:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f10:	8a 03                	mov    (%ebx),%al
f0100f12:	84 c0                	test   %al,%al
f0100f14:	75 09                	jne    f0100f1f <monitor+0xae>
f0100f16:	eb b7                	jmp    f0100ecf <monitor+0x5e>
			buf++;
f0100f18:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f19:	8a 03                	mov    (%ebx),%al
f0100f1b:	84 c0                	test   %al,%al
f0100f1d:	74 b0                	je     f0100ecf <monitor+0x5e>
f0100f1f:	83 ec 08             	sub    $0x8,%esp
f0100f22:	0f be c0             	movsbl %al,%eax
f0100f25:	50                   	push   %eax
f0100f26:	68 5c 4f 10 f0       	push   $0xf0104f5c
f0100f2b:	e8 d5 37 00 00       	call   f0104705 <strchr>
f0100f30:	83 c4 10             	add    $0x10,%esp
f0100f33:	85 c0                	test   %eax,%eax
f0100f35:	74 e1                	je     f0100f18 <monitor+0xa7>
f0100f37:	eb 96                	jmp    f0100ecf <monitor+0x5e>
			buf++;
	}
	argv[argc] = 0;
f0100f39:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100f40:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100f41:	85 f6                	test   %esi,%esi
f0100f43:	0f 84 5e ff ff ff    	je     f0100ea7 <monitor+0x36>
f0100f49:	bb e0 55 10 f0       	mov    $0xf01055e0,%ebx
f0100f4e:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100f53:	83 ec 08             	sub    $0x8,%esp
f0100f56:	ff 33                	pushl  (%ebx)
f0100f58:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f5b:	e8 37 37 00 00       	call   f0104697 <strcmp>
f0100f60:	83 c4 10             	add    $0x10,%esp
f0100f63:	85 c0                	test   %eax,%eax
f0100f65:	75 20                	jne    f0100f87 <monitor+0x116>
			return commands[i].func(argc, argv, tf);
f0100f67:	83 ec 04             	sub    $0x4,%esp
f0100f6a:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100f6d:	ff 75 08             	pushl  0x8(%ebp)
f0100f70:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100f73:	50                   	push   %eax
f0100f74:	56                   	push   %esi
f0100f75:	ff 97 e8 55 10 f0    	call   *-0xfefaa18(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100f7b:	83 c4 10             	add    $0x10,%esp
f0100f7e:	85 c0                	test   %eax,%eax
f0100f80:	78 26                	js     f0100fa8 <monitor+0x137>
f0100f82:	e9 20 ff ff ff       	jmp    f0100ea7 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100f87:	47                   	inc    %edi
f0100f88:	83 c3 0c             	add    $0xc,%ebx
f0100f8b:	83 ff 09             	cmp    $0x9,%edi
f0100f8e:	75 c3                	jne    f0100f53 <monitor+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f90:	83 ec 08             	sub    $0x8,%esp
f0100f93:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f96:	68 7e 4f 10 f0       	push   $0xf0104f7e
f0100f9b:	e8 8d 25 00 00       	call   f010352d <cprintf>
f0100fa0:	83 c4 10             	add    $0x10,%esp
f0100fa3:	e9 ff fe ff ff       	jmp    f0100ea7 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100fa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fab:	5b                   	pop    %ebx
f0100fac:	5e                   	pop    %esi
f0100fad:	5f                   	pop    %edi
f0100fae:	c9                   	leave  
f0100faf:	c3                   	ret    

f0100fb0 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100fb0:	55                   	push   %ebp
f0100fb1:	89 e5                	mov    %esp,%ebp
f0100fb3:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100fb5:	83 3d 74 04 1e f0 00 	cmpl   $0x0,0xf01e0474
f0100fbc:	75 0f                	jne    f0100fcd <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100fbe:	b8 4f 21 1e f0       	mov    $0xf01e214f,%eax
f0100fc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fc8:	a3 74 04 1e f0       	mov    %eax,0xf01e0474
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0100fcd:	a1 74 04 1e f0       	mov    0xf01e0474,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100fd2:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100fd9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100fdf:	89 15 74 04 1e f0    	mov    %edx,0xf01e0474

	return result;
}
f0100fe5:	c9                   	leave  
f0100fe6:	c3                   	ret    

f0100fe7 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100fe7:	55                   	push   %ebp
f0100fe8:	89 e5                	mov    %esp,%ebp
f0100fea:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100fed:	89 d1                	mov    %edx,%ecx
f0100fef:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ff2:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ff5:	a8 01                	test   $0x1,%al
f0100ff7:	74 42                	je     f010103b <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ff9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ffe:	89 c1                	mov    %eax,%ecx
f0101000:	c1 e9 0c             	shr    $0xc,%ecx
f0101003:	3b 0d 44 11 1e f0    	cmp    0xf01e1144,%ecx
f0101009:	72 15                	jb     f0101020 <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010100b:	50                   	push   %eax
f010100c:	68 4c 56 10 f0       	push   $0xf010564c
f0101011:	68 1a 03 00 00       	push   $0x31a
f0101016:	68 ad 5d 10 f0       	push   $0xf0105dad
f010101b:	e8 b2 f0 ff ff       	call   f01000d2 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0101020:	c1 ea 0c             	shr    $0xc,%edx
f0101023:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101029:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101030:	a8 01                	test   $0x1,%al
f0101032:	74 0e                	je     f0101042 <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101034:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101039:	eb 0c                	jmp    f0101047 <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f010103b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101040:	eb 05                	jmp    f0101047 <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0101042:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0101047:	c9                   	leave  
f0101048:	c3                   	ret    

f0101049 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0101049:	55                   	push   %ebp
f010104a:	89 e5                	mov    %esp,%ebp
f010104c:	56                   	push   %esi
f010104d:	53                   	push   %ebx
f010104e:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101050:	83 ec 0c             	sub    $0xc,%esp
f0101053:	50                   	push   %eax
f0101054:	e8 73 24 00 00       	call   f01034cc <mc146818_read>
f0101059:	89 c6                	mov    %eax,%esi
f010105b:	43                   	inc    %ebx
f010105c:	89 1c 24             	mov    %ebx,(%esp)
f010105f:	e8 68 24 00 00       	call   f01034cc <mc146818_read>
f0101064:	c1 e0 08             	shl    $0x8,%eax
f0101067:	09 f0                	or     %esi,%eax
}
f0101069:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010106c:	5b                   	pop    %ebx
f010106d:	5e                   	pop    %esi
f010106e:	c9                   	leave  
f010106f:	c3                   	ret    

f0101070 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101070:	55                   	push   %ebp
f0101071:	89 e5                	mov    %esp,%ebp
f0101073:	57                   	push   %edi
f0101074:	56                   	push   %esi
f0101075:	53                   	push   %ebx
f0101076:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101079:	3c 01                	cmp    $0x1,%al
f010107b:	19 f6                	sbb    %esi,%esi
f010107d:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101083:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101084:	8b 1d 70 04 1e f0    	mov    0xf01e0470,%ebx
f010108a:	85 db                	test   %ebx,%ebx
f010108c:	75 17                	jne    f01010a5 <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f010108e:	83 ec 04             	sub    $0x4,%esp
f0101091:	68 70 56 10 f0       	push   $0xf0105670
f0101096:	68 58 02 00 00       	push   $0x258
f010109b:	68 ad 5d 10 f0       	push   $0xf0105dad
f01010a0:	e8 2d f0 ff ff       	call   f01000d2 <_panic>

	if (only_low_memory) {
f01010a5:	84 c0                	test   %al,%al
f01010a7:	74 50                	je     f01010f9 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01010a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01010ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010af:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01010b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010b5:	89 d8                	mov    %ebx,%eax
f01010b7:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f01010bd:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01010c0:	c1 e8 16             	shr    $0x16,%eax
f01010c3:	39 c6                	cmp    %eax,%esi
f01010c5:	0f 96 c0             	setbe  %al
f01010c8:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f01010cb:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f01010cf:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f01010d1:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010d5:	8b 1b                	mov    (%ebx),%ebx
f01010d7:	85 db                	test   %ebx,%ebx
f01010d9:	75 da                	jne    f01010b5 <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01010db:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01010de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01010e4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01010e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010ea:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01010ec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01010ef:	89 1d 70 04 1e f0    	mov    %ebx,0xf01e0470
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010f5:	85 db                	test   %ebx,%ebx
f01010f7:	74 57                	je     f0101150 <check_page_free_list+0xe0>
f01010f9:	89 d8                	mov    %ebx,%eax
f01010fb:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0101101:	c1 f8 03             	sar    $0x3,%eax
f0101104:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101107:	89 c2                	mov    %eax,%edx
f0101109:	c1 ea 16             	shr    $0x16,%edx
f010110c:	39 d6                	cmp    %edx,%esi
f010110e:	76 3a                	jbe    f010114a <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101110:	89 c2                	mov    %eax,%edx
f0101112:	c1 ea 0c             	shr    $0xc,%edx
f0101115:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f010111b:	72 12                	jb     f010112f <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010111d:	50                   	push   %eax
f010111e:	68 4c 56 10 f0       	push   $0xf010564c
f0101123:	6a 56                	push   $0x56
f0101125:	68 b9 5d 10 f0       	push   $0xf0105db9
f010112a:	e8 a3 ef ff ff       	call   f01000d2 <_panic>
			memset(page2kva(pp), 0x97, 128);
f010112f:	83 ec 04             	sub    $0x4,%esp
f0101132:	68 80 00 00 00       	push   $0x80
f0101137:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f010113c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101141:	50                   	push   %eax
f0101142:	e8 0e 36 00 00       	call   f0104755 <memset>
f0101147:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010114a:	8b 1b                	mov    (%ebx),%ebx
f010114c:	85 db                	test   %ebx,%ebx
f010114e:	75 a9                	jne    f01010f9 <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101150:	b8 00 00 00 00       	mov    $0x0,%eax
f0101155:	e8 56 fe ff ff       	call   f0100fb0 <boot_alloc>
f010115a:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010115d:	8b 15 70 04 1e f0    	mov    0xf01e0470,%edx
f0101163:	85 d2                	test   %edx,%edx
f0101165:	0f 84 80 01 00 00    	je     f01012eb <check_page_free_list+0x27b>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010116b:	8b 1d 4c 11 1e f0    	mov    0xf01e114c,%ebx
f0101171:	39 da                	cmp    %ebx,%edx
f0101173:	72 43                	jb     f01011b8 <check_page_free_list+0x148>
		assert(pp < pages + npages);
f0101175:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f010117a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010117d:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101180:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101183:	39 c2                	cmp    %eax,%edx
f0101185:	73 4f                	jae    f01011d6 <check_page_free_list+0x166>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101187:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010118a:	89 d0                	mov    %edx,%eax
f010118c:	29 d8                	sub    %ebx,%eax
f010118e:	a8 07                	test   $0x7,%al
f0101190:	75 66                	jne    f01011f8 <check_page_free_list+0x188>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101192:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101195:	c1 e0 0c             	shl    $0xc,%eax
f0101198:	74 7f                	je     f0101219 <check_page_free_list+0x1a9>
		assert(page2pa(pp) != IOPHYSMEM);
f010119a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010119f:	0f 84 94 00 00 00    	je     f0101239 <check_page_free_list+0x1c9>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01011a5:	be 00 00 00 00       	mov    $0x0,%esi
f01011aa:	bf 00 00 00 00       	mov    $0x0,%edi
f01011af:	e9 9e 00 00 00       	jmp    f0101252 <check_page_free_list+0x1e2>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01011b4:	39 da                	cmp    %ebx,%edx
f01011b6:	73 19                	jae    f01011d1 <check_page_free_list+0x161>
f01011b8:	68 c7 5d 10 f0       	push   $0xf0105dc7
f01011bd:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01011c2:	68 72 02 00 00       	push   $0x272
f01011c7:	68 ad 5d 10 f0       	push   $0xf0105dad
f01011cc:	e8 01 ef ff ff       	call   f01000d2 <_panic>
		assert(pp < pages + npages);
f01011d1:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01011d4:	72 19                	jb     f01011ef <check_page_free_list+0x17f>
f01011d6:	68 e8 5d 10 f0       	push   $0xf0105de8
f01011db:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01011e0:	68 73 02 00 00       	push   $0x273
f01011e5:	68 ad 5d 10 f0       	push   $0xf0105dad
f01011ea:	e8 e3 ee ff ff       	call   f01000d2 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01011ef:	89 d0                	mov    %edx,%eax
f01011f1:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01011f4:	a8 07                	test   $0x7,%al
f01011f6:	74 19                	je     f0101211 <check_page_free_list+0x1a1>
f01011f8:	68 94 56 10 f0       	push   $0xf0105694
f01011fd:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101202:	68 74 02 00 00       	push   $0x274
f0101207:	68 ad 5d 10 f0       	push   $0xf0105dad
f010120c:	e8 c1 ee ff ff       	call   f01000d2 <_panic>
f0101211:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101214:	c1 e0 0c             	shl    $0xc,%eax
f0101217:	75 19                	jne    f0101232 <check_page_free_list+0x1c2>
f0101219:	68 fc 5d 10 f0       	push   $0xf0105dfc
f010121e:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101223:	68 77 02 00 00       	push   $0x277
f0101228:	68 ad 5d 10 f0       	push   $0xf0105dad
f010122d:	e8 a0 ee ff ff       	call   f01000d2 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101232:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101237:	75 19                	jne    f0101252 <check_page_free_list+0x1e2>
f0101239:	68 0d 5e 10 f0       	push   $0xf0105e0d
f010123e:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101243:	68 78 02 00 00       	push   $0x278
f0101248:	68 ad 5d 10 f0       	push   $0xf0105dad
f010124d:	e8 80 ee ff ff       	call   f01000d2 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101252:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101257:	75 19                	jne    f0101272 <check_page_free_list+0x202>
f0101259:	68 c8 56 10 f0       	push   $0xf01056c8
f010125e:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101263:	68 79 02 00 00       	push   $0x279
f0101268:	68 ad 5d 10 f0       	push   $0xf0105dad
f010126d:	e8 60 ee ff ff       	call   f01000d2 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101272:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101277:	75 19                	jne    f0101292 <check_page_free_list+0x222>
f0101279:	68 26 5e 10 f0       	push   $0xf0105e26
f010127e:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101283:	68 7a 02 00 00       	push   $0x27a
f0101288:	68 ad 5d 10 f0       	push   $0xf0105dad
f010128d:	e8 40 ee ff ff       	call   f01000d2 <_panic>
f0101292:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101294:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101299:	76 3e                	jbe    f01012d9 <check_page_free_list+0x269>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010129b:	c1 e8 0c             	shr    $0xc,%eax
f010129e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01012a1:	77 12                	ja     f01012b5 <check_page_free_list+0x245>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012a3:	51                   	push   %ecx
f01012a4:	68 4c 56 10 f0       	push   $0xf010564c
f01012a9:	6a 56                	push   $0x56
f01012ab:	68 b9 5d 10 f0       	push   $0xf0105db9
f01012b0:	e8 1d ee ff ff       	call   f01000d2 <_panic>
	return (void *)(pa + KERNBASE);
f01012b5:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f01012bb:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01012be:	76 1c                	jbe    f01012dc <check_page_free_list+0x26c>
f01012c0:	68 ec 56 10 f0       	push   $0xf01056ec
f01012c5:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01012ca:	68 7b 02 00 00       	push   $0x27b
f01012cf:	68 ad 5d 10 f0       	push   $0xf0105dad
f01012d4:	e8 f9 ed ff ff       	call   f01000d2 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f01012d9:	47                   	inc    %edi
f01012da:	eb 01                	jmp    f01012dd <check_page_free_list+0x26d>
		else
			++nfree_extmem;
f01012dc:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012dd:	8b 12                	mov    (%edx),%edx
f01012df:	85 d2                	test   %edx,%edx
f01012e1:	0f 85 cd fe ff ff    	jne    f01011b4 <check_page_free_list+0x144>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01012e7:	85 ff                	test   %edi,%edi
f01012e9:	7f 19                	jg     f0101304 <check_page_free_list+0x294>
f01012eb:	68 40 5e 10 f0       	push   $0xf0105e40
f01012f0:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01012f5:	68 83 02 00 00       	push   $0x283
f01012fa:	68 ad 5d 10 f0       	push   $0xf0105dad
f01012ff:	e8 ce ed ff ff       	call   f01000d2 <_panic>
	assert(nfree_extmem > 0);
f0101304:	85 f6                	test   %esi,%esi
f0101306:	7f 19                	jg     f0101321 <check_page_free_list+0x2b1>
f0101308:	68 52 5e 10 f0       	push   $0xf0105e52
f010130d:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101312:	68 84 02 00 00       	push   $0x284
f0101317:	68 ad 5d 10 f0       	push   $0xf0105dad
f010131c:	e8 b1 ed ff ff       	call   f01000d2 <_panic>
}
f0101321:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101324:	5b                   	pop    %ebx
f0101325:	5e                   	pop    %esi
f0101326:	5f                   	pop    %edi
f0101327:	c9                   	leave  
f0101328:	c3                   	ret    

f0101329 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101329:	55                   	push   %ebp
f010132a:	89 e5                	mov    %esp,%ebp
f010132c:	56                   	push   %esi
f010132d:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f010132e:	c7 05 70 04 1e f0 00 	movl   $0x0,0xf01e0470
f0101335:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f0101338:	b8 00 00 00 00       	mov    $0x0,%eax
f010133d:	e8 6e fc ff ff       	call   f0100fb0 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101342:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101347:	77 15                	ja     f010135e <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101349:	50                   	push   %eax
f010134a:	68 7c 54 10 f0       	push   $0xf010547c
f010134f:	68 24 01 00 00       	push   $0x124
f0101354:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101359:	e8 74 ed ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010135e:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f0101364:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f0101367:	83 3d 44 11 1e f0 00 	cmpl   $0x0,0xf01e1144
f010136e:	74 5f                	je     f01013cf <page_init+0xa6>
f0101370:	8b 1d 70 04 1e f0    	mov    0xf01e0470,%ebx
f0101376:	ba 00 00 00 00       	mov    $0x0,%edx
f010137b:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f0101380:	85 c0                	test   %eax,%eax
f0101382:	74 25                	je     f01013a9 <page_init+0x80>
f0101384:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0101389:	76 04                	jbe    f010138f <page_init+0x66>
f010138b:	39 c6                	cmp    %eax,%esi
f010138d:	77 1a                	ja     f01013a9 <page_init+0x80>
		    pages[i].pp_ref = 0;
f010138f:	89 d1                	mov    %edx,%ecx
f0101391:	03 0d 4c 11 1e f0    	add    0xf01e114c,%ecx
f0101397:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f010139d:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f010139f:	89 d3                	mov    %edx,%ebx
f01013a1:	03 1d 4c 11 1e f0    	add    0xf01e114c,%ebx
f01013a7:	eb 14                	jmp    f01013bd <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f01013a9:	89 d1                	mov    %edx,%ecx
f01013ab:	03 0d 4c 11 1e f0    	add    0xf01e114c,%ecx
f01013b1:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f01013b7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// free pages!
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    for (i = 0; i < npages; i++) {
f01013bd:	40                   	inc    %eax
f01013be:	83 c2 08             	add    $0x8,%edx
f01013c1:	39 05 44 11 1e f0    	cmp    %eax,0xf01e1144
f01013c7:	77 b7                	ja     f0101380 <page_init+0x57>
f01013c9:	89 1d 70 04 1e f0    	mov    %ebx,0xf01e0470
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f01013cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01013d2:	5b                   	pop    %ebx
f01013d3:	5e                   	pop    %esi
f01013d4:	c9                   	leave  
f01013d5:	c3                   	ret    

f01013d6 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01013d6:	55                   	push   %ebp
f01013d7:	89 e5                	mov    %esp,%ebp
f01013d9:	53                   	push   %ebx
f01013da:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f01013dd:	8b 1d 70 04 1e f0    	mov    0xf01e0470,%ebx
f01013e3:	85 db                	test   %ebx,%ebx
f01013e5:	74 63                	je     f010144a <page_alloc+0x74>
f01013e7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01013ec:	74 63                	je     f0101451 <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f01013ee:	8b 1b                	mov    (%ebx),%ebx
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f01013f0:	85 db                	test   %ebx,%ebx
f01013f2:	75 08                	jne    f01013fc <page_alloc+0x26>
f01013f4:	89 1d 70 04 1e f0    	mov    %ebx,0xf01e0470
f01013fa:	eb 4e                	jmp    f010144a <page_alloc+0x74>
f01013fc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101401:	75 eb                	jne    f01013ee <page_alloc+0x18>
f0101403:	eb 4c                	jmp    f0101451 <page_alloc+0x7b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101405:	89 d8                	mov    %ebx,%eax
f0101407:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f010140d:	c1 f8 03             	sar    $0x3,%eax
f0101410:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101413:	89 c2                	mov    %eax,%edx
f0101415:	c1 ea 0c             	shr    $0xc,%edx
f0101418:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f010141e:	72 12                	jb     f0101432 <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101420:	50                   	push   %eax
f0101421:	68 4c 56 10 f0       	push   $0xf010564c
f0101426:	6a 56                	push   $0x56
f0101428:	68 b9 5d 10 f0       	push   $0xf0105db9
f010142d:	e8 a0 ec ff ff       	call   f01000d2 <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f0101432:	83 ec 04             	sub    $0x4,%esp
f0101435:	68 00 10 00 00       	push   $0x1000
f010143a:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010143c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101441:	50                   	push   %eax
f0101442:	e8 0e 33 00 00       	call   f0104755 <memset>
f0101447:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f010144a:	89 d8                	mov    %ebx,%eax
f010144c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010144f:	c9                   	leave  
f0101450:	c3                   	ret    
        page_free_list = page_free_list->pp_link;
    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f0101451:	8b 03                	mov    (%ebx),%eax
f0101453:	a3 70 04 1e f0       	mov    %eax,0xf01e0470
        if (alloc_flags & ALLOC_ZERO) {
f0101458:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010145c:	74 ec                	je     f010144a <page_alloc+0x74>
f010145e:	eb a5                	jmp    f0101405 <page_alloc+0x2f>

f0101460 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101460:	55                   	push   %ebp
f0101461:	89 e5                	mov    %esp,%ebp
f0101463:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f0101466:	85 c0                	test   %eax,%eax
f0101468:	74 14                	je     f010147e <page_free+0x1e>
f010146a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010146f:	75 0d                	jne    f010147e <page_free+0x1e>
    pp->pp_link = page_free_list;
f0101471:	8b 15 70 04 1e f0    	mov    0xf01e0470,%edx
f0101477:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0101479:	a3 70 04 1e f0       	mov    %eax,0xf01e0470
}
f010147e:	c9                   	leave  
f010147f:	c3                   	ret    

f0101480 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101480:	55                   	push   %ebp
f0101481:	89 e5                	mov    %esp,%ebp
f0101483:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101486:	8b 50 04             	mov    0x4(%eax),%edx
f0101489:	4a                   	dec    %edx
f010148a:	66 89 50 04          	mov    %dx,0x4(%eax)
f010148e:	66 85 d2             	test   %dx,%dx
f0101491:	75 09                	jne    f010149c <page_decref+0x1c>
		page_free(pp);
f0101493:	50                   	push   %eax
f0101494:	e8 c7 ff ff ff       	call   f0101460 <page_free>
f0101499:	83 c4 04             	add    $0x4,%esp
}
f010149c:	c9                   	leave  
f010149d:	c3                   	ret    

f010149e <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010149e:	55                   	push   %ebp
f010149f:	89 e5                	mov    %esp,%ebp
f01014a1:	56                   	push   %esi
f01014a2:	53                   	push   %ebx
f01014a3:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f01014a6:	89 f3                	mov    %esi,%ebx
f01014a8:	c1 eb 16             	shr    $0x16,%ebx
f01014ab:	c1 e3 02             	shl    $0x2,%ebx
f01014ae:	03 5d 08             	add    0x8(%ebp),%ebx
f01014b1:	8b 03                	mov    (%ebx),%eax
f01014b3:	85 c0                	test   %eax,%eax
f01014b5:	74 04                	je     f01014bb <pgdir_walk+0x1d>
f01014b7:	a8 01                	test   $0x1,%al
f01014b9:	75 2c                	jne    f01014e7 <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f01014bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01014bf:	74 61                	je     f0101522 <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(1);
f01014c1:	83 ec 0c             	sub    $0xc,%esp
f01014c4:	6a 01                	push   $0x1
f01014c6:	e8 0b ff ff ff       	call   f01013d6 <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f01014cb:	83 c4 10             	add    $0x10,%esp
f01014ce:	85 c0                	test   %eax,%eax
f01014d0:	74 57                	je     f0101529 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f01014d2:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014d6:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f01014dc:	c1 f8 03             	sar    $0x3,%eax
f01014df:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f01014e2:	83 c8 07             	or     $0x7,%eax
f01014e5:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f01014e7:	8b 03                	mov    (%ebx),%eax
f01014e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014ee:	89 c2                	mov    %eax,%edx
f01014f0:	c1 ea 0c             	shr    $0xc,%edx
f01014f3:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f01014f9:	72 15                	jb     f0101510 <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014fb:	50                   	push   %eax
f01014fc:	68 4c 56 10 f0       	push   $0xf010564c
f0101501:	68 87 01 00 00       	push   $0x187
f0101506:	68 ad 5d 10 f0       	push   $0xf0105dad
f010150b:	e8 c2 eb ff ff       	call   f01000d2 <_panic>
f0101510:	c1 ee 0a             	shr    $0xa,%esi
f0101513:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101519:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101520:	eb 0c                	jmp    f010152e <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f0101522:	b8 00 00 00 00       	mov    $0x0,%eax
f0101527:	eb 05                	jmp    f010152e <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f0101529:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f010152e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101531:	5b                   	pop    %ebx
f0101532:	5e                   	pop    %esi
f0101533:	c9                   	leave  
f0101534:	c3                   	ret    

f0101535 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101535:	55                   	push   %ebp
f0101536:	89 e5                	mov    %esp,%ebp
f0101538:	57                   	push   %edi
f0101539:	56                   	push   %esi
f010153a:	53                   	push   %ebx
f010153b:	83 ec 1c             	sub    $0x1c,%esp
f010153e:	89 c7                	mov    %eax,%edi
f0101540:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101543:	01 d1                	add    %edx,%ecx
f0101545:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101548:	39 ca                	cmp    %ecx,%edx
f010154a:	74 32                	je     f010157e <boot_map_region+0x49>
f010154c:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f010154e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101551:	83 c8 01             	or     $0x1,%eax
f0101554:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f0101557:	83 ec 04             	sub    $0x4,%esp
f010155a:	6a 01                	push   $0x1
f010155c:	53                   	push   %ebx
f010155d:	57                   	push   %edi
f010155e:	e8 3b ff ff ff       	call   f010149e <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f0101563:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101566:	09 f2                	or     %esi,%edx
f0101568:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f010156a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101570:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101576:	83 c4 10             	add    $0x10,%esp
f0101579:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010157c:	75 d9                	jne    f0101557 <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f010157e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101581:	5b                   	pop    %ebx
f0101582:	5e                   	pop    %esi
f0101583:	5f                   	pop    %edi
f0101584:	c9                   	leave  
f0101585:	c3                   	ret    

f0101586 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101586:	55                   	push   %ebp
f0101587:	89 e5                	mov    %esp,%ebp
f0101589:	53                   	push   %ebx
f010158a:	83 ec 08             	sub    $0x8,%esp
f010158d:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f0101590:	6a 00                	push   $0x0
f0101592:	ff 75 0c             	pushl  0xc(%ebp)
f0101595:	ff 75 08             	pushl  0x8(%ebp)
f0101598:	e8 01 ff ff ff       	call   f010149e <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f010159d:	83 c4 10             	add    $0x10,%esp
f01015a0:	85 c0                	test   %eax,%eax
f01015a2:	74 37                	je     f01015db <page_lookup+0x55>
f01015a4:	f6 00 01             	testb  $0x1,(%eax)
f01015a7:	74 39                	je     f01015e2 <page_lookup+0x5c>
    if (pte_store != 0) {
f01015a9:	85 db                	test   %ebx,%ebx
f01015ab:	74 02                	je     f01015af <page_lookup+0x29>
        *pte_store = pte;
f01015ad:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f01015af:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015b1:	c1 e8 0c             	shr    $0xc,%eax
f01015b4:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f01015ba:	72 14                	jb     f01015d0 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01015bc:	83 ec 04             	sub    $0x4,%esp
f01015bf:	68 34 57 10 f0       	push   $0xf0105734
f01015c4:	6a 4f                	push   $0x4f
f01015c6:	68 b9 5d 10 f0       	push   $0xf0105db9
f01015cb:	e8 02 eb ff ff       	call   f01000d2 <_panic>
	return &pages[PGNUM(pa)];
f01015d0:	c1 e0 03             	shl    $0x3,%eax
f01015d3:	03 05 4c 11 1e f0    	add    0xf01e114c,%eax
f01015d9:	eb 0c                	jmp    f01015e7 <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01015db:	b8 00 00 00 00       	mov    $0x0,%eax
f01015e0:	eb 05                	jmp    f01015e7 <page_lookup+0x61>
f01015e2:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f01015e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015ea:	c9                   	leave  
f01015eb:	c3                   	ret    

f01015ec <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01015ec:	55                   	push   %ebp
f01015ed:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01015ef:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015f2:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01015f5:	c9                   	leave  
f01015f6:	c3                   	ret    

f01015f7 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01015f7:	55                   	push   %ebp
f01015f8:	89 e5                	mov    %esp,%ebp
f01015fa:	56                   	push   %esi
f01015fb:	53                   	push   %ebx
f01015fc:	83 ec 14             	sub    $0x14,%esp
f01015ff:	8b 75 08             	mov    0x8(%ebp),%esi
f0101602:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f0101605:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101608:	50                   	push   %eax
f0101609:	53                   	push   %ebx
f010160a:	56                   	push   %esi
f010160b:	e8 76 ff ff ff       	call   f0101586 <page_lookup>
    if (pg == NULL) return;
f0101610:	83 c4 10             	add    $0x10,%esp
f0101613:	85 c0                	test   %eax,%eax
f0101615:	74 26                	je     f010163d <page_remove+0x46>
    page_decref(pg);
f0101617:	83 ec 0c             	sub    $0xc,%esp
f010161a:	50                   	push   %eax
f010161b:	e8 60 fe ff ff       	call   f0101480 <page_decref>
    if (pte != NULL) *pte = 0;
f0101620:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101623:	83 c4 10             	add    $0x10,%esp
f0101626:	85 c0                	test   %eax,%eax
f0101628:	74 06                	je     f0101630 <page_remove+0x39>
f010162a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f0101630:	83 ec 08             	sub    $0x8,%esp
f0101633:	53                   	push   %ebx
f0101634:	56                   	push   %esi
f0101635:	e8 b2 ff ff ff       	call   f01015ec <tlb_invalidate>
f010163a:	83 c4 10             	add    $0x10,%esp
}
f010163d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101640:	5b                   	pop    %ebx
f0101641:	5e                   	pop    %esi
f0101642:	c9                   	leave  
f0101643:	c3                   	ret    

f0101644 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101644:	55                   	push   %ebp
f0101645:	89 e5                	mov    %esp,%ebp
f0101647:	57                   	push   %edi
f0101648:	56                   	push   %esi
f0101649:	53                   	push   %ebx
f010164a:	83 ec 10             	sub    $0x10,%esp
f010164d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101650:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f0101653:	6a 01                	push   $0x1
f0101655:	57                   	push   %edi
f0101656:	ff 75 08             	pushl  0x8(%ebp)
f0101659:	e8 40 fe ff ff       	call   f010149e <pgdir_walk>
f010165e:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f0101660:	83 c4 10             	add    $0x10,%esp
f0101663:	85 c0                	test   %eax,%eax
f0101665:	74 39                	je     f01016a0 <page_insert+0x5c>
    ++pp->pp_ref;
f0101667:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f010166b:	f6 00 01             	testb  $0x1,(%eax)
f010166e:	74 0f                	je     f010167f <page_insert+0x3b>
        page_remove(pgdir, va);
f0101670:	83 ec 08             	sub    $0x8,%esp
f0101673:	57                   	push   %edi
f0101674:	ff 75 08             	pushl  0x8(%ebp)
f0101677:	e8 7b ff ff ff       	call   f01015f7 <page_remove>
f010167c:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f010167f:	8b 55 14             	mov    0x14(%ebp),%edx
f0101682:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101685:	2b 35 4c 11 1e f0    	sub    0xf01e114c,%esi
f010168b:	c1 fe 03             	sar    $0x3,%esi
f010168e:	89 f0                	mov    %esi,%eax
f0101690:	c1 e0 0c             	shl    $0xc,%eax
f0101693:	89 d6                	mov    %edx,%esi
f0101695:	09 c6                	or     %eax,%esi
f0101697:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101699:	b8 00 00 00 00       	mov    $0x0,%eax
f010169e:	eb 05                	jmp    f01016a5 <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f01016a0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f01016a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01016a8:	5b                   	pop    %ebx
f01016a9:	5e                   	pop    %esi
f01016aa:	5f                   	pop    %edi
f01016ab:	c9                   	leave  
f01016ac:	c3                   	ret    

f01016ad <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01016ad:	55                   	push   %ebp
f01016ae:	89 e5                	mov    %esp,%ebp
f01016b0:	57                   	push   %edi
f01016b1:	56                   	push   %esi
f01016b2:	53                   	push   %ebx
f01016b3:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01016b6:	b8 15 00 00 00       	mov    $0x15,%eax
f01016bb:	e8 89 f9 ff ff       	call   f0101049 <nvram_read>
f01016c0:	c1 e0 0a             	shl    $0xa,%eax
f01016c3:	89 c2                	mov    %eax,%edx
f01016c5:	85 c0                	test   %eax,%eax
f01016c7:	79 06                	jns    f01016cf <mem_init+0x22>
f01016c9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01016cf:	c1 fa 0c             	sar    $0xc,%edx
f01016d2:	89 15 78 04 1e f0    	mov    %edx,0xf01e0478
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01016d8:	b8 17 00 00 00       	mov    $0x17,%eax
f01016dd:	e8 67 f9 ff ff       	call   f0101049 <nvram_read>
f01016e2:	89 c2                	mov    %eax,%edx
f01016e4:	c1 e2 0a             	shl    $0xa,%edx
f01016e7:	89 d0                	mov    %edx,%eax
f01016e9:	85 d2                	test   %edx,%edx
f01016eb:	79 06                	jns    f01016f3 <mem_init+0x46>
f01016ed:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01016f3:	c1 f8 0c             	sar    $0xc,%eax
f01016f6:	74 0e                	je     f0101706 <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01016f8:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01016fe:	89 15 44 11 1e f0    	mov    %edx,0xf01e1144
f0101704:	eb 0c                	jmp    f0101712 <mem_init+0x65>
	else
		npages = npages_basemem;
f0101706:	8b 15 78 04 1e f0    	mov    0xf01e0478,%edx
f010170c:	89 15 44 11 1e f0    	mov    %edx,0xf01e1144

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101712:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101715:	c1 e8 0a             	shr    $0xa,%eax
f0101718:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101719:	a1 78 04 1e f0       	mov    0xf01e0478,%eax
f010171e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101721:	c1 e8 0a             	shr    $0xa,%eax
f0101724:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0101725:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f010172a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010172d:	c1 e8 0a             	shr    $0xa,%eax
f0101730:	50                   	push   %eax
f0101731:	68 54 57 10 f0       	push   $0xf0105754
f0101736:	e8 f2 1d 00 00       	call   f010352d <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010173b:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101740:	e8 6b f8 ff ff       	call   f0100fb0 <boot_alloc>
f0101745:	a3 48 11 1e f0       	mov    %eax,0xf01e1148
	memset(kern_pgdir, 0, PGSIZE);
f010174a:	83 c4 0c             	add    $0xc,%esp
f010174d:	68 00 10 00 00       	push   $0x1000
f0101752:	6a 00                	push   $0x0
f0101754:	50                   	push   %eax
f0101755:	e8 fb 2f 00 00       	call   f0104755 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010175a:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010175f:	83 c4 10             	add    $0x10,%esp
f0101762:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101767:	77 15                	ja     f010177e <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101769:	50                   	push   %eax
f010176a:	68 7c 54 10 f0       	push   $0xf010547c
f010176f:	68 8e 00 00 00       	push   $0x8e
f0101774:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101779:	e8 54 e9 ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010177e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101784:	83 ca 05             	or     $0x5,%edx
f0101787:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f010178d:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f0101792:	c1 e0 03             	shl    $0x3,%eax
f0101795:	e8 16 f8 ff ff       	call   f0100fb0 <boot_alloc>
f010179a:	a3 4c 11 1e f0       	mov    %eax,0xf01e114c
    

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f010179f:	b8 00 80 01 00       	mov    $0x18000,%eax
f01017a4:	e8 07 f8 ff ff       	call   f0100fb0 <boot_alloc>
f01017a9:	a3 7c 04 1e f0       	mov    %eax,0xf01e047c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01017ae:	e8 76 fb ff ff       	call   f0101329 <page_init>

	check_page_free_list(1);
f01017b3:	b8 01 00 00 00       	mov    $0x1,%eax
f01017b8:	e8 b3 f8 ff ff       	call   f0101070 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01017bd:	83 3d 4c 11 1e f0 00 	cmpl   $0x0,0xf01e114c
f01017c4:	75 17                	jne    f01017dd <mem_init+0x130>
		panic("'pages' is a null pointer!");
f01017c6:	83 ec 04             	sub    $0x4,%esp
f01017c9:	68 63 5e 10 f0       	push   $0xf0105e63
f01017ce:	68 95 02 00 00       	push   $0x295
f01017d3:	68 ad 5d 10 f0       	push   $0xf0105dad
f01017d8:	e8 f5 e8 ff ff       	call   f01000d2 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01017dd:	a1 70 04 1e f0       	mov    0xf01e0470,%eax
f01017e2:	85 c0                	test   %eax,%eax
f01017e4:	74 0e                	je     f01017f4 <mem_init+0x147>
f01017e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f01017eb:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01017ec:	8b 00                	mov    (%eax),%eax
f01017ee:	85 c0                	test   %eax,%eax
f01017f0:	75 f9                	jne    f01017eb <mem_init+0x13e>
f01017f2:	eb 05                	jmp    f01017f9 <mem_init+0x14c>
f01017f4:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017f9:	83 ec 0c             	sub    $0xc,%esp
f01017fc:	6a 00                	push   $0x0
f01017fe:	e8 d3 fb ff ff       	call   f01013d6 <page_alloc>
f0101803:	89 c6                	mov    %eax,%esi
f0101805:	83 c4 10             	add    $0x10,%esp
f0101808:	85 c0                	test   %eax,%eax
f010180a:	75 19                	jne    f0101825 <mem_init+0x178>
f010180c:	68 7e 5e 10 f0       	push   $0xf0105e7e
f0101811:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101816:	68 9d 02 00 00       	push   $0x29d
f010181b:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101820:	e8 ad e8 ff ff       	call   f01000d2 <_panic>
	assert((pp1 = page_alloc(0)));
f0101825:	83 ec 0c             	sub    $0xc,%esp
f0101828:	6a 00                	push   $0x0
f010182a:	e8 a7 fb ff ff       	call   f01013d6 <page_alloc>
f010182f:	89 c7                	mov    %eax,%edi
f0101831:	83 c4 10             	add    $0x10,%esp
f0101834:	85 c0                	test   %eax,%eax
f0101836:	75 19                	jne    f0101851 <mem_init+0x1a4>
f0101838:	68 94 5e 10 f0       	push   $0xf0105e94
f010183d:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101842:	68 9e 02 00 00       	push   $0x29e
f0101847:	68 ad 5d 10 f0       	push   $0xf0105dad
f010184c:	e8 81 e8 ff ff       	call   f01000d2 <_panic>
	assert((pp2 = page_alloc(0)));
f0101851:	83 ec 0c             	sub    $0xc,%esp
f0101854:	6a 00                	push   $0x0
f0101856:	e8 7b fb ff ff       	call   f01013d6 <page_alloc>
f010185b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010185e:	83 c4 10             	add    $0x10,%esp
f0101861:	85 c0                	test   %eax,%eax
f0101863:	75 19                	jne    f010187e <mem_init+0x1d1>
f0101865:	68 aa 5e 10 f0       	push   $0xf0105eaa
f010186a:	68 d3 5d 10 f0       	push   $0xf0105dd3
f010186f:	68 9f 02 00 00       	push   $0x29f
f0101874:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101879:	e8 54 e8 ff ff       	call   f01000d2 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010187e:	39 fe                	cmp    %edi,%esi
f0101880:	75 19                	jne    f010189b <mem_init+0x1ee>
f0101882:	68 c0 5e 10 f0       	push   $0xf0105ec0
f0101887:	68 d3 5d 10 f0       	push   $0xf0105dd3
f010188c:	68 a2 02 00 00       	push   $0x2a2
f0101891:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101896:	e8 37 e8 ff ff       	call   f01000d2 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010189b:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010189e:	74 05                	je     f01018a5 <mem_init+0x1f8>
f01018a0:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01018a3:	75 19                	jne    f01018be <mem_init+0x211>
f01018a5:	68 90 57 10 f0       	push   $0xf0105790
f01018aa:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01018af:	68 a3 02 00 00       	push   $0x2a3
f01018b4:	68 ad 5d 10 f0       	push   $0xf0105dad
f01018b9:	e8 14 e8 ff ff       	call   f01000d2 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018be:	8b 15 4c 11 1e f0    	mov    0xf01e114c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01018c4:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f01018c9:	c1 e0 0c             	shl    $0xc,%eax
f01018cc:	89 f1                	mov    %esi,%ecx
f01018ce:	29 d1                	sub    %edx,%ecx
f01018d0:	c1 f9 03             	sar    $0x3,%ecx
f01018d3:	c1 e1 0c             	shl    $0xc,%ecx
f01018d6:	39 c1                	cmp    %eax,%ecx
f01018d8:	72 19                	jb     f01018f3 <mem_init+0x246>
f01018da:	68 d2 5e 10 f0       	push   $0xf0105ed2
f01018df:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01018e4:	68 a4 02 00 00       	push   $0x2a4
f01018e9:	68 ad 5d 10 f0       	push   $0xf0105dad
f01018ee:	e8 df e7 ff ff       	call   f01000d2 <_panic>
f01018f3:	89 f9                	mov    %edi,%ecx
f01018f5:	29 d1                	sub    %edx,%ecx
f01018f7:	c1 f9 03             	sar    $0x3,%ecx
f01018fa:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01018fd:	39 c8                	cmp    %ecx,%eax
f01018ff:	77 19                	ja     f010191a <mem_init+0x26d>
f0101901:	68 ef 5e 10 f0       	push   $0xf0105eef
f0101906:	68 d3 5d 10 f0       	push   $0xf0105dd3
f010190b:	68 a5 02 00 00       	push   $0x2a5
f0101910:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101915:	e8 b8 e7 ff ff       	call   f01000d2 <_panic>
f010191a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010191d:	29 d1                	sub    %edx,%ecx
f010191f:	89 ca                	mov    %ecx,%edx
f0101921:	c1 fa 03             	sar    $0x3,%edx
f0101924:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101927:	39 d0                	cmp    %edx,%eax
f0101929:	77 19                	ja     f0101944 <mem_init+0x297>
f010192b:	68 0c 5f 10 f0       	push   $0xf0105f0c
f0101930:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101935:	68 a6 02 00 00       	push   $0x2a6
f010193a:	68 ad 5d 10 f0       	push   $0xf0105dad
f010193f:	e8 8e e7 ff ff       	call   f01000d2 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101944:	a1 70 04 1e f0       	mov    0xf01e0470,%eax
f0101949:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010194c:	c7 05 70 04 1e f0 00 	movl   $0x0,0xf01e0470
f0101953:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101956:	83 ec 0c             	sub    $0xc,%esp
f0101959:	6a 00                	push   $0x0
f010195b:	e8 76 fa ff ff       	call   f01013d6 <page_alloc>
f0101960:	83 c4 10             	add    $0x10,%esp
f0101963:	85 c0                	test   %eax,%eax
f0101965:	74 19                	je     f0101980 <mem_init+0x2d3>
f0101967:	68 29 5f 10 f0       	push   $0xf0105f29
f010196c:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101971:	68 ad 02 00 00       	push   $0x2ad
f0101976:	68 ad 5d 10 f0       	push   $0xf0105dad
f010197b:	e8 52 e7 ff ff       	call   f01000d2 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101980:	83 ec 0c             	sub    $0xc,%esp
f0101983:	56                   	push   %esi
f0101984:	e8 d7 fa ff ff       	call   f0101460 <page_free>
	page_free(pp1);
f0101989:	89 3c 24             	mov    %edi,(%esp)
f010198c:	e8 cf fa ff ff       	call   f0101460 <page_free>
	page_free(pp2);
f0101991:	83 c4 04             	add    $0x4,%esp
f0101994:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101997:	e8 c4 fa ff ff       	call   f0101460 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010199c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019a3:	e8 2e fa ff ff       	call   f01013d6 <page_alloc>
f01019a8:	89 c6                	mov    %eax,%esi
f01019aa:	83 c4 10             	add    $0x10,%esp
f01019ad:	85 c0                	test   %eax,%eax
f01019af:	75 19                	jne    f01019ca <mem_init+0x31d>
f01019b1:	68 7e 5e 10 f0       	push   $0xf0105e7e
f01019b6:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01019bb:	68 b4 02 00 00       	push   $0x2b4
f01019c0:	68 ad 5d 10 f0       	push   $0xf0105dad
f01019c5:	e8 08 e7 ff ff       	call   f01000d2 <_panic>
	assert((pp1 = page_alloc(0)));
f01019ca:	83 ec 0c             	sub    $0xc,%esp
f01019cd:	6a 00                	push   $0x0
f01019cf:	e8 02 fa ff ff       	call   f01013d6 <page_alloc>
f01019d4:	89 c7                	mov    %eax,%edi
f01019d6:	83 c4 10             	add    $0x10,%esp
f01019d9:	85 c0                	test   %eax,%eax
f01019db:	75 19                	jne    f01019f6 <mem_init+0x349>
f01019dd:	68 94 5e 10 f0       	push   $0xf0105e94
f01019e2:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01019e7:	68 b5 02 00 00       	push   $0x2b5
f01019ec:	68 ad 5d 10 f0       	push   $0xf0105dad
f01019f1:	e8 dc e6 ff ff       	call   f01000d2 <_panic>
	assert((pp2 = page_alloc(0)));
f01019f6:	83 ec 0c             	sub    $0xc,%esp
f01019f9:	6a 00                	push   $0x0
f01019fb:	e8 d6 f9 ff ff       	call   f01013d6 <page_alloc>
f0101a00:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a03:	83 c4 10             	add    $0x10,%esp
f0101a06:	85 c0                	test   %eax,%eax
f0101a08:	75 19                	jne    f0101a23 <mem_init+0x376>
f0101a0a:	68 aa 5e 10 f0       	push   $0xf0105eaa
f0101a0f:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101a14:	68 b6 02 00 00       	push   $0x2b6
f0101a19:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101a1e:	e8 af e6 ff ff       	call   f01000d2 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a23:	39 fe                	cmp    %edi,%esi
f0101a25:	75 19                	jne    f0101a40 <mem_init+0x393>
f0101a27:	68 c0 5e 10 f0       	push   $0xf0105ec0
f0101a2c:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101a31:	68 b8 02 00 00       	push   $0x2b8
f0101a36:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101a3b:	e8 92 e6 ff ff       	call   f01000d2 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a40:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101a43:	74 05                	je     f0101a4a <mem_init+0x39d>
f0101a45:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101a48:	75 19                	jne    f0101a63 <mem_init+0x3b6>
f0101a4a:	68 90 57 10 f0       	push   $0xf0105790
f0101a4f:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101a54:	68 b9 02 00 00       	push   $0x2b9
f0101a59:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101a5e:	e8 6f e6 ff ff       	call   f01000d2 <_panic>
	assert(!page_alloc(0));
f0101a63:	83 ec 0c             	sub    $0xc,%esp
f0101a66:	6a 00                	push   $0x0
f0101a68:	e8 69 f9 ff ff       	call   f01013d6 <page_alloc>
f0101a6d:	83 c4 10             	add    $0x10,%esp
f0101a70:	85 c0                	test   %eax,%eax
f0101a72:	74 19                	je     f0101a8d <mem_init+0x3e0>
f0101a74:	68 29 5f 10 f0       	push   $0xf0105f29
f0101a79:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101a7e:	68 ba 02 00 00       	push   $0x2ba
f0101a83:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101a88:	e8 45 e6 ff ff       	call   f01000d2 <_panic>
f0101a8d:	89 f0                	mov    %esi,%eax
f0101a8f:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0101a95:	c1 f8 03             	sar    $0x3,%eax
f0101a98:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a9b:	89 c2                	mov    %eax,%edx
f0101a9d:	c1 ea 0c             	shr    $0xc,%edx
f0101aa0:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0101aa6:	72 12                	jb     f0101aba <mem_init+0x40d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101aa8:	50                   	push   %eax
f0101aa9:	68 4c 56 10 f0       	push   $0xf010564c
f0101aae:	6a 56                	push   $0x56
f0101ab0:	68 b9 5d 10 f0       	push   $0xf0105db9
f0101ab5:	e8 18 e6 ff ff       	call   f01000d2 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101aba:	83 ec 04             	sub    $0x4,%esp
f0101abd:	68 00 10 00 00       	push   $0x1000
f0101ac2:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101ac4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ac9:	50                   	push   %eax
f0101aca:	e8 86 2c 00 00       	call   f0104755 <memset>
	page_free(pp0);
f0101acf:	89 34 24             	mov    %esi,(%esp)
f0101ad2:	e8 89 f9 ff ff       	call   f0101460 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101ad7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101ade:	e8 f3 f8 ff ff       	call   f01013d6 <page_alloc>
f0101ae3:	83 c4 10             	add    $0x10,%esp
f0101ae6:	85 c0                	test   %eax,%eax
f0101ae8:	75 19                	jne    f0101b03 <mem_init+0x456>
f0101aea:	68 38 5f 10 f0       	push   $0xf0105f38
f0101aef:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101af4:	68 bf 02 00 00       	push   $0x2bf
f0101af9:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101afe:	e8 cf e5 ff ff       	call   f01000d2 <_panic>
	assert(pp && pp0 == pp);
f0101b03:	39 c6                	cmp    %eax,%esi
f0101b05:	74 19                	je     f0101b20 <mem_init+0x473>
f0101b07:	68 56 5f 10 f0       	push   $0xf0105f56
f0101b0c:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101b11:	68 c0 02 00 00       	push   $0x2c0
f0101b16:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101b1b:	e8 b2 e5 ff ff       	call   f01000d2 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b20:	89 f2                	mov    %esi,%edx
f0101b22:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101b28:	c1 fa 03             	sar    $0x3,%edx
f0101b2b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b2e:	89 d0                	mov    %edx,%eax
f0101b30:	c1 e8 0c             	shr    $0xc,%eax
f0101b33:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f0101b39:	72 12                	jb     f0101b4d <mem_init+0x4a0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b3b:	52                   	push   %edx
f0101b3c:	68 4c 56 10 f0       	push   $0xf010564c
f0101b41:	6a 56                	push   $0x56
f0101b43:	68 b9 5d 10 f0       	push   $0xf0105db9
f0101b48:	e8 85 e5 ff ff       	call   f01000d2 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b4d:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101b54:	75 11                	jne    f0101b67 <mem_init+0x4ba>
f0101b56:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101b5c:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101b62:	80 38 00             	cmpb   $0x0,(%eax)
f0101b65:	74 19                	je     f0101b80 <mem_init+0x4d3>
f0101b67:	68 66 5f 10 f0       	push   $0xf0105f66
f0101b6c:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101b71:	68 c3 02 00 00       	push   $0x2c3
f0101b76:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101b7b:	e8 52 e5 ff ff       	call   f01000d2 <_panic>
f0101b80:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101b81:	39 d0                	cmp    %edx,%eax
f0101b83:	75 dd                	jne    f0101b62 <mem_init+0x4b5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101b85:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101b88:	89 0d 70 04 1e f0    	mov    %ecx,0xf01e0470

	// free the pages we took
	page_free(pp0);
f0101b8e:	83 ec 0c             	sub    $0xc,%esp
f0101b91:	56                   	push   %esi
f0101b92:	e8 c9 f8 ff ff       	call   f0101460 <page_free>
	page_free(pp1);
f0101b97:	89 3c 24             	mov    %edi,(%esp)
f0101b9a:	e8 c1 f8 ff ff       	call   f0101460 <page_free>
	page_free(pp2);
f0101b9f:	83 c4 04             	add    $0x4,%esp
f0101ba2:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ba5:	e8 b6 f8 ff ff       	call   f0101460 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101baa:	a1 70 04 1e f0       	mov    0xf01e0470,%eax
f0101baf:	83 c4 10             	add    $0x10,%esp
f0101bb2:	85 c0                	test   %eax,%eax
f0101bb4:	74 07                	je     f0101bbd <mem_init+0x510>
		--nfree;
f0101bb6:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101bb7:	8b 00                	mov    (%eax),%eax
f0101bb9:	85 c0                	test   %eax,%eax
f0101bbb:	75 f9                	jne    f0101bb6 <mem_init+0x509>
		--nfree;
	assert(nfree == 0);
f0101bbd:	85 db                	test   %ebx,%ebx
f0101bbf:	74 19                	je     f0101bda <mem_init+0x52d>
f0101bc1:	68 70 5f 10 f0       	push   $0xf0105f70
f0101bc6:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101bcb:	68 d0 02 00 00       	push   $0x2d0
f0101bd0:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101bd5:	e8 f8 e4 ff ff       	call   f01000d2 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101bda:	83 ec 0c             	sub    $0xc,%esp
f0101bdd:	68 b0 57 10 f0       	push   $0xf01057b0
f0101be2:	e8 46 19 00 00       	call   f010352d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101be7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bee:	e8 e3 f7 ff ff       	call   f01013d6 <page_alloc>
f0101bf3:	89 c7                	mov    %eax,%edi
f0101bf5:	83 c4 10             	add    $0x10,%esp
f0101bf8:	85 c0                	test   %eax,%eax
f0101bfa:	75 19                	jne    f0101c15 <mem_init+0x568>
f0101bfc:	68 7e 5e 10 f0       	push   $0xf0105e7e
f0101c01:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101c06:	68 2e 03 00 00       	push   $0x32e
f0101c0b:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101c10:	e8 bd e4 ff ff       	call   f01000d2 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c15:	83 ec 0c             	sub    $0xc,%esp
f0101c18:	6a 00                	push   $0x0
f0101c1a:	e8 b7 f7 ff ff       	call   f01013d6 <page_alloc>
f0101c1f:	89 c6                	mov    %eax,%esi
f0101c21:	83 c4 10             	add    $0x10,%esp
f0101c24:	85 c0                	test   %eax,%eax
f0101c26:	75 19                	jne    f0101c41 <mem_init+0x594>
f0101c28:	68 94 5e 10 f0       	push   $0xf0105e94
f0101c2d:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101c32:	68 2f 03 00 00       	push   $0x32f
f0101c37:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101c3c:	e8 91 e4 ff ff       	call   f01000d2 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c41:	83 ec 0c             	sub    $0xc,%esp
f0101c44:	6a 00                	push   $0x0
f0101c46:	e8 8b f7 ff ff       	call   f01013d6 <page_alloc>
f0101c4b:	89 c3                	mov    %eax,%ebx
f0101c4d:	83 c4 10             	add    $0x10,%esp
f0101c50:	85 c0                	test   %eax,%eax
f0101c52:	75 19                	jne    f0101c6d <mem_init+0x5c0>
f0101c54:	68 aa 5e 10 f0       	push   $0xf0105eaa
f0101c59:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101c5e:	68 30 03 00 00       	push   $0x330
f0101c63:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101c68:	e8 65 e4 ff ff       	call   f01000d2 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c6d:	39 f7                	cmp    %esi,%edi
f0101c6f:	75 19                	jne    f0101c8a <mem_init+0x5dd>
f0101c71:	68 c0 5e 10 f0       	push   $0xf0105ec0
f0101c76:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101c7b:	68 33 03 00 00       	push   $0x333
f0101c80:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101c85:	e8 48 e4 ff ff       	call   f01000d2 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c8a:	39 c6                	cmp    %eax,%esi
f0101c8c:	74 04                	je     f0101c92 <mem_init+0x5e5>
f0101c8e:	39 c7                	cmp    %eax,%edi
f0101c90:	75 19                	jne    f0101cab <mem_init+0x5fe>
f0101c92:	68 90 57 10 f0       	push   $0xf0105790
f0101c97:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101c9c:	68 34 03 00 00       	push   $0x334
f0101ca1:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101ca6:	e8 27 e4 ff ff       	call   f01000d2 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101cab:	a1 70 04 1e f0       	mov    0xf01e0470,%eax
f0101cb0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	page_free_list = 0;
f0101cb3:	c7 05 70 04 1e f0 00 	movl   $0x0,0xf01e0470
f0101cba:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101cbd:	83 ec 0c             	sub    $0xc,%esp
f0101cc0:	6a 00                	push   $0x0
f0101cc2:	e8 0f f7 ff ff       	call   f01013d6 <page_alloc>
f0101cc7:	83 c4 10             	add    $0x10,%esp
f0101cca:	85 c0                	test   %eax,%eax
f0101ccc:	74 19                	je     f0101ce7 <mem_init+0x63a>
f0101cce:	68 29 5f 10 f0       	push   $0xf0105f29
f0101cd3:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101cd8:	68 3b 03 00 00       	push   $0x33b
f0101cdd:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101ce2:	e8 eb e3 ff ff       	call   f01000d2 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ce7:	83 ec 04             	sub    $0x4,%esp
f0101cea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ced:	50                   	push   %eax
f0101cee:	6a 00                	push   $0x0
f0101cf0:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101cf6:	e8 8b f8 ff ff       	call   f0101586 <page_lookup>
f0101cfb:	83 c4 10             	add    $0x10,%esp
f0101cfe:	85 c0                	test   %eax,%eax
f0101d00:	74 19                	je     f0101d1b <mem_init+0x66e>
f0101d02:	68 d0 57 10 f0       	push   $0xf01057d0
f0101d07:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101d0c:	68 3e 03 00 00       	push   $0x33e
f0101d11:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101d16:	e8 b7 e3 ff ff       	call   f01000d2 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d1b:	6a 02                	push   $0x2
f0101d1d:	6a 00                	push   $0x0
f0101d1f:	56                   	push   %esi
f0101d20:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101d26:	e8 19 f9 ff ff       	call   f0101644 <page_insert>
f0101d2b:	83 c4 10             	add    $0x10,%esp
f0101d2e:	85 c0                	test   %eax,%eax
f0101d30:	78 19                	js     f0101d4b <mem_init+0x69e>
f0101d32:	68 08 58 10 f0       	push   $0xf0105808
f0101d37:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101d3c:	68 41 03 00 00       	push   $0x341
f0101d41:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101d46:	e8 87 e3 ff ff       	call   f01000d2 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d4b:	83 ec 0c             	sub    $0xc,%esp
f0101d4e:	57                   	push   %edi
f0101d4f:	e8 0c f7 ff ff       	call   f0101460 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d54:	6a 02                	push   $0x2
f0101d56:	6a 00                	push   $0x0
f0101d58:	56                   	push   %esi
f0101d59:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101d5f:	e8 e0 f8 ff ff       	call   f0101644 <page_insert>
f0101d64:	83 c4 20             	add    $0x20,%esp
f0101d67:	85 c0                	test   %eax,%eax
f0101d69:	74 19                	je     f0101d84 <mem_init+0x6d7>
f0101d6b:	68 38 58 10 f0       	push   $0xf0105838
f0101d70:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101d75:	68 45 03 00 00       	push   $0x345
f0101d7a:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101d7f:	e8 4e e3 ff ff       	call   f01000d2 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d84:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0101d89:	8b 08                	mov    (%eax),%ecx
f0101d8b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d91:	89 fa                	mov    %edi,%edx
f0101d93:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101d99:	c1 fa 03             	sar    $0x3,%edx
f0101d9c:	c1 e2 0c             	shl    $0xc,%edx
f0101d9f:	39 d1                	cmp    %edx,%ecx
f0101da1:	74 19                	je     f0101dbc <mem_init+0x70f>
f0101da3:	68 68 58 10 f0       	push   $0xf0105868
f0101da8:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101dad:	68 46 03 00 00       	push   $0x346
f0101db2:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101db7:	e8 16 e3 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101dbc:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dc1:	e8 21 f2 ff ff       	call   f0100fe7 <check_va2pa>
f0101dc6:	89 f2                	mov    %esi,%edx
f0101dc8:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101dce:	c1 fa 03             	sar    $0x3,%edx
f0101dd1:	c1 e2 0c             	shl    $0xc,%edx
f0101dd4:	39 d0                	cmp    %edx,%eax
f0101dd6:	74 19                	je     f0101df1 <mem_init+0x744>
f0101dd8:	68 90 58 10 f0       	push   $0xf0105890
f0101ddd:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101de2:	68 47 03 00 00       	push   $0x347
f0101de7:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101dec:	e8 e1 e2 ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 1);
f0101df1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101df6:	74 19                	je     f0101e11 <mem_init+0x764>
f0101df8:	68 7b 5f 10 f0       	push   $0xf0105f7b
f0101dfd:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101e02:	68 48 03 00 00       	push   $0x348
f0101e07:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101e0c:	e8 c1 e2 ff ff       	call   f01000d2 <_panic>
	assert(pp0->pp_ref == 1);
f0101e11:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e16:	74 19                	je     f0101e31 <mem_init+0x784>
f0101e18:	68 8c 5f 10 f0       	push   $0xf0105f8c
f0101e1d:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101e22:	68 49 03 00 00       	push   $0x349
f0101e27:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101e2c:	e8 a1 e2 ff ff       	call   f01000d2 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e31:	6a 02                	push   $0x2
f0101e33:	68 00 10 00 00       	push   $0x1000
f0101e38:	53                   	push   %ebx
f0101e39:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101e3f:	e8 00 f8 ff ff       	call   f0101644 <page_insert>
f0101e44:	83 c4 10             	add    $0x10,%esp
f0101e47:	85 c0                	test   %eax,%eax
f0101e49:	74 19                	je     f0101e64 <mem_init+0x7b7>
f0101e4b:	68 c0 58 10 f0       	push   $0xf01058c0
f0101e50:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101e55:	68 4c 03 00 00       	push   $0x34c
f0101e5a:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101e5f:	e8 6e e2 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e64:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e69:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0101e6e:	e8 74 f1 ff ff       	call   f0100fe7 <check_va2pa>
f0101e73:	89 da                	mov    %ebx,%edx
f0101e75:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101e7b:	c1 fa 03             	sar    $0x3,%edx
f0101e7e:	c1 e2 0c             	shl    $0xc,%edx
f0101e81:	39 d0                	cmp    %edx,%eax
f0101e83:	74 19                	je     f0101e9e <mem_init+0x7f1>
f0101e85:	68 fc 58 10 f0       	push   $0xf01058fc
f0101e8a:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101e8f:	68 4d 03 00 00       	push   $0x34d
f0101e94:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101e99:	e8 34 e2 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f0101e9e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ea3:	74 19                	je     f0101ebe <mem_init+0x811>
f0101ea5:	68 9d 5f 10 f0       	push   $0xf0105f9d
f0101eaa:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101eaf:	68 4e 03 00 00       	push   $0x34e
f0101eb4:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101eb9:	e8 14 e2 ff ff       	call   f01000d2 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ebe:	83 ec 0c             	sub    $0xc,%esp
f0101ec1:	6a 00                	push   $0x0
f0101ec3:	e8 0e f5 ff ff       	call   f01013d6 <page_alloc>
f0101ec8:	83 c4 10             	add    $0x10,%esp
f0101ecb:	85 c0                	test   %eax,%eax
f0101ecd:	74 19                	je     f0101ee8 <mem_init+0x83b>
f0101ecf:	68 29 5f 10 f0       	push   $0xf0105f29
f0101ed4:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101ed9:	68 51 03 00 00       	push   $0x351
f0101ede:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101ee3:	e8 ea e1 ff ff       	call   f01000d2 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ee8:	6a 02                	push   $0x2
f0101eea:	68 00 10 00 00       	push   $0x1000
f0101eef:	53                   	push   %ebx
f0101ef0:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0101ef6:	e8 49 f7 ff ff       	call   f0101644 <page_insert>
f0101efb:	83 c4 10             	add    $0x10,%esp
f0101efe:	85 c0                	test   %eax,%eax
f0101f00:	74 19                	je     f0101f1b <mem_init+0x86e>
f0101f02:	68 c0 58 10 f0       	push   $0xf01058c0
f0101f07:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101f0c:	68 54 03 00 00       	push   $0x354
f0101f11:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101f16:	e8 b7 e1 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f1b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f20:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0101f25:	e8 bd f0 ff ff       	call   f0100fe7 <check_va2pa>
f0101f2a:	89 da                	mov    %ebx,%edx
f0101f2c:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0101f32:	c1 fa 03             	sar    $0x3,%edx
f0101f35:	c1 e2 0c             	shl    $0xc,%edx
f0101f38:	39 d0                	cmp    %edx,%eax
f0101f3a:	74 19                	je     f0101f55 <mem_init+0x8a8>
f0101f3c:	68 fc 58 10 f0       	push   $0xf01058fc
f0101f41:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101f46:	68 55 03 00 00       	push   $0x355
f0101f4b:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101f50:	e8 7d e1 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f0101f55:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f5a:	74 19                	je     f0101f75 <mem_init+0x8c8>
f0101f5c:	68 9d 5f 10 f0       	push   $0xf0105f9d
f0101f61:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101f66:	68 56 03 00 00       	push   $0x356
f0101f6b:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101f70:	e8 5d e1 ff ff       	call   f01000d2 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f75:	83 ec 0c             	sub    $0xc,%esp
f0101f78:	6a 00                	push   $0x0
f0101f7a:	e8 57 f4 ff ff       	call   f01013d6 <page_alloc>
f0101f7f:	83 c4 10             	add    $0x10,%esp
f0101f82:	85 c0                	test   %eax,%eax
f0101f84:	74 19                	je     f0101f9f <mem_init+0x8f2>
f0101f86:	68 29 5f 10 f0       	push   $0xf0105f29
f0101f8b:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101f90:	68 5a 03 00 00       	push   $0x35a
f0101f95:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101f9a:	e8 33 e1 ff ff       	call   f01000d2 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f9f:	8b 15 48 11 1e f0    	mov    0xf01e1148,%edx
f0101fa5:	8b 02                	mov    (%edx),%eax
f0101fa7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fac:	89 c1                	mov    %eax,%ecx
f0101fae:	c1 e9 0c             	shr    $0xc,%ecx
f0101fb1:	3b 0d 44 11 1e f0    	cmp    0xf01e1144,%ecx
f0101fb7:	72 15                	jb     f0101fce <mem_init+0x921>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fb9:	50                   	push   %eax
f0101fba:	68 4c 56 10 f0       	push   $0xf010564c
f0101fbf:	68 5d 03 00 00       	push   $0x35d
f0101fc4:	68 ad 5d 10 f0       	push   $0xf0105dad
f0101fc9:	e8 04 e1 ff ff       	call   f01000d2 <_panic>
	return (void *)(pa + KERNBASE);
f0101fce:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101fd6:	83 ec 04             	sub    $0x4,%esp
f0101fd9:	6a 00                	push   $0x0
f0101fdb:	68 00 10 00 00       	push   $0x1000
f0101fe0:	52                   	push   %edx
f0101fe1:	e8 b8 f4 ff ff       	call   f010149e <pgdir_walk>
f0101fe6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101fe9:	83 c2 04             	add    $0x4,%edx
f0101fec:	83 c4 10             	add    $0x10,%esp
f0101fef:	39 d0                	cmp    %edx,%eax
f0101ff1:	74 19                	je     f010200c <mem_init+0x95f>
f0101ff3:	68 2c 59 10 f0       	push   $0xf010592c
f0101ff8:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0101ffd:	68 5e 03 00 00       	push   $0x35e
f0102002:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102007:	e8 c6 e0 ff ff       	call   f01000d2 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010200c:	6a 06                	push   $0x6
f010200e:	68 00 10 00 00       	push   $0x1000
f0102013:	53                   	push   %ebx
f0102014:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f010201a:	e8 25 f6 ff ff       	call   f0101644 <page_insert>
f010201f:	83 c4 10             	add    $0x10,%esp
f0102022:	85 c0                	test   %eax,%eax
f0102024:	74 19                	je     f010203f <mem_init+0x992>
f0102026:	68 6c 59 10 f0       	push   $0xf010596c
f010202b:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102030:	68 61 03 00 00       	push   $0x361
f0102035:	68 ad 5d 10 f0       	push   $0xf0105dad
f010203a:	e8 93 e0 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010203f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102044:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102049:	e8 99 ef ff ff       	call   f0100fe7 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010204e:	89 da                	mov    %ebx,%edx
f0102050:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0102056:	c1 fa 03             	sar    $0x3,%edx
f0102059:	c1 e2 0c             	shl    $0xc,%edx
f010205c:	39 d0                	cmp    %edx,%eax
f010205e:	74 19                	je     f0102079 <mem_init+0x9cc>
f0102060:	68 fc 58 10 f0       	push   $0xf01058fc
f0102065:	68 d3 5d 10 f0       	push   $0xf0105dd3
f010206a:	68 62 03 00 00       	push   $0x362
f010206f:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102074:	e8 59 e0 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f0102079:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010207e:	74 19                	je     f0102099 <mem_init+0x9ec>
f0102080:	68 9d 5f 10 f0       	push   $0xf0105f9d
f0102085:	68 d3 5d 10 f0       	push   $0xf0105dd3
f010208a:	68 63 03 00 00       	push   $0x363
f010208f:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102094:	e8 39 e0 ff ff       	call   f01000d2 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102099:	83 ec 04             	sub    $0x4,%esp
f010209c:	6a 00                	push   $0x0
f010209e:	68 00 10 00 00       	push   $0x1000
f01020a3:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f01020a9:	e8 f0 f3 ff ff       	call   f010149e <pgdir_walk>
f01020ae:	83 c4 10             	add    $0x10,%esp
f01020b1:	f6 00 04             	testb  $0x4,(%eax)
f01020b4:	75 19                	jne    f01020cf <mem_init+0xa22>
f01020b6:	68 ac 59 10 f0       	push   $0xf01059ac
f01020bb:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01020c0:	68 64 03 00 00       	push   $0x364
f01020c5:	68 ad 5d 10 f0       	push   $0xf0105dad
f01020ca:	e8 03 e0 ff ff       	call   f01000d2 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01020cf:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01020d4:	f6 00 04             	testb  $0x4,(%eax)
f01020d7:	75 19                	jne    f01020f2 <mem_init+0xa45>
f01020d9:	68 ae 5f 10 f0       	push   $0xf0105fae
f01020de:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01020e3:	68 65 03 00 00       	push   $0x365
f01020e8:	68 ad 5d 10 f0       	push   $0xf0105dad
f01020ed:	e8 e0 df ff ff       	call   f01000d2 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020f2:	6a 02                	push   $0x2
f01020f4:	68 00 10 00 00       	push   $0x1000
f01020f9:	53                   	push   %ebx
f01020fa:	50                   	push   %eax
f01020fb:	e8 44 f5 ff ff       	call   f0101644 <page_insert>
f0102100:	83 c4 10             	add    $0x10,%esp
f0102103:	85 c0                	test   %eax,%eax
f0102105:	74 19                	je     f0102120 <mem_init+0xa73>
f0102107:	68 c0 58 10 f0       	push   $0xf01058c0
f010210c:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102111:	68 68 03 00 00       	push   $0x368
f0102116:	68 ad 5d 10 f0       	push   $0xf0105dad
f010211b:	e8 b2 df ff ff       	call   f01000d2 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102120:	83 ec 04             	sub    $0x4,%esp
f0102123:	6a 00                	push   $0x0
f0102125:	68 00 10 00 00       	push   $0x1000
f010212a:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102130:	e8 69 f3 ff ff       	call   f010149e <pgdir_walk>
f0102135:	83 c4 10             	add    $0x10,%esp
f0102138:	f6 00 02             	testb  $0x2,(%eax)
f010213b:	75 19                	jne    f0102156 <mem_init+0xaa9>
f010213d:	68 e0 59 10 f0       	push   $0xf01059e0
f0102142:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102147:	68 69 03 00 00       	push   $0x369
f010214c:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102151:	e8 7c df ff ff       	call   f01000d2 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102156:	83 ec 04             	sub    $0x4,%esp
f0102159:	6a 00                	push   $0x0
f010215b:	68 00 10 00 00       	push   $0x1000
f0102160:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102166:	e8 33 f3 ff ff       	call   f010149e <pgdir_walk>
f010216b:	83 c4 10             	add    $0x10,%esp
f010216e:	f6 00 04             	testb  $0x4,(%eax)
f0102171:	74 19                	je     f010218c <mem_init+0xadf>
f0102173:	68 14 5a 10 f0       	push   $0xf0105a14
f0102178:	68 d3 5d 10 f0       	push   $0xf0105dd3
f010217d:	68 6a 03 00 00       	push   $0x36a
f0102182:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102187:	e8 46 df ff ff       	call   f01000d2 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010218c:	6a 02                	push   $0x2
f010218e:	68 00 00 40 00       	push   $0x400000
f0102193:	57                   	push   %edi
f0102194:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f010219a:	e8 a5 f4 ff ff       	call   f0101644 <page_insert>
f010219f:	83 c4 10             	add    $0x10,%esp
f01021a2:	85 c0                	test   %eax,%eax
f01021a4:	78 19                	js     f01021bf <mem_init+0xb12>
f01021a6:	68 4c 5a 10 f0       	push   $0xf0105a4c
f01021ab:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01021b0:	68 6d 03 00 00       	push   $0x36d
f01021b5:	68 ad 5d 10 f0       	push   $0xf0105dad
f01021ba:	e8 13 df ff ff       	call   f01000d2 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01021bf:	6a 02                	push   $0x2
f01021c1:	68 00 10 00 00       	push   $0x1000
f01021c6:	56                   	push   %esi
f01021c7:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f01021cd:	e8 72 f4 ff ff       	call   f0101644 <page_insert>
f01021d2:	83 c4 10             	add    $0x10,%esp
f01021d5:	85 c0                	test   %eax,%eax
f01021d7:	74 19                	je     f01021f2 <mem_init+0xb45>
f01021d9:	68 84 5a 10 f0       	push   $0xf0105a84
f01021de:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01021e3:	68 70 03 00 00       	push   $0x370
f01021e8:	68 ad 5d 10 f0       	push   $0xf0105dad
f01021ed:	e8 e0 de ff ff       	call   f01000d2 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021f2:	83 ec 04             	sub    $0x4,%esp
f01021f5:	6a 00                	push   $0x0
f01021f7:	68 00 10 00 00       	push   $0x1000
f01021fc:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102202:	e8 97 f2 ff ff       	call   f010149e <pgdir_walk>
f0102207:	83 c4 10             	add    $0x10,%esp
f010220a:	f6 00 04             	testb  $0x4,(%eax)
f010220d:	74 19                	je     f0102228 <mem_init+0xb7b>
f010220f:	68 14 5a 10 f0       	push   $0xf0105a14
f0102214:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102219:	68 71 03 00 00       	push   $0x371
f010221e:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102223:	e8 aa de ff ff       	call   f01000d2 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102228:	ba 00 00 00 00       	mov    $0x0,%edx
f010222d:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102232:	e8 b0 ed ff ff       	call   f0100fe7 <check_va2pa>
f0102237:	89 f2                	mov    %esi,%edx
f0102239:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f010223f:	c1 fa 03             	sar    $0x3,%edx
f0102242:	c1 e2 0c             	shl    $0xc,%edx
f0102245:	39 d0                	cmp    %edx,%eax
f0102247:	74 19                	je     f0102262 <mem_init+0xbb5>
f0102249:	68 c0 5a 10 f0       	push   $0xf0105ac0
f010224e:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102253:	68 74 03 00 00       	push   $0x374
f0102258:	68 ad 5d 10 f0       	push   $0xf0105dad
f010225d:	e8 70 de ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102262:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102267:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f010226c:	e8 76 ed ff ff       	call   f0100fe7 <check_va2pa>
f0102271:	89 f2                	mov    %esi,%edx
f0102273:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0102279:	c1 fa 03             	sar    $0x3,%edx
f010227c:	c1 e2 0c             	shl    $0xc,%edx
f010227f:	39 d0                	cmp    %edx,%eax
f0102281:	74 19                	je     f010229c <mem_init+0xbef>
f0102283:	68 ec 5a 10 f0       	push   $0xf0105aec
f0102288:	68 d3 5d 10 f0       	push   $0xf0105dd3
f010228d:	68 75 03 00 00       	push   $0x375
f0102292:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102297:	e8 36 de ff ff       	call   f01000d2 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010229c:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f01022a1:	74 19                	je     f01022bc <mem_init+0xc0f>
f01022a3:	68 c4 5f 10 f0       	push   $0xf0105fc4
f01022a8:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01022ad:	68 77 03 00 00       	push   $0x377
f01022b2:	68 ad 5d 10 f0       	push   $0xf0105dad
f01022b7:	e8 16 de ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 0);
f01022bc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022c1:	74 19                	je     f01022dc <mem_init+0xc2f>
f01022c3:	68 d5 5f 10 f0       	push   $0xf0105fd5
f01022c8:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01022cd:	68 78 03 00 00       	push   $0x378
f01022d2:	68 ad 5d 10 f0       	push   $0xf0105dad
f01022d7:	e8 f6 dd ff ff       	call   f01000d2 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01022dc:	83 ec 0c             	sub    $0xc,%esp
f01022df:	6a 00                	push   $0x0
f01022e1:	e8 f0 f0 ff ff       	call   f01013d6 <page_alloc>
f01022e6:	83 c4 10             	add    $0x10,%esp
f01022e9:	85 c0                	test   %eax,%eax
f01022eb:	74 04                	je     f01022f1 <mem_init+0xc44>
f01022ed:	39 c3                	cmp    %eax,%ebx
f01022ef:	74 19                	je     f010230a <mem_init+0xc5d>
f01022f1:	68 1c 5b 10 f0       	push   $0xf0105b1c
f01022f6:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01022fb:	68 7b 03 00 00       	push   $0x37b
f0102300:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102305:	e8 c8 dd ff ff       	call   f01000d2 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010230a:	83 ec 08             	sub    $0x8,%esp
f010230d:	6a 00                	push   $0x0
f010230f:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102315:	e8 dd f2 ff ff       	call   f01015f7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010231a:	ba 00 00 00 00       	mov    $0x0,%edx
f010231f:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102324:	e8 be ec ff ff       	call   f0100fe7 <check_va2pa>
f0102329:	83 c4 10             	add    $0x10,%esp
f010232c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010232f:	74 19                	je     f010234a <mem_init+0xc9d>
f0102331:	68 40 5b 10 f0       	push   $0xf0105b40
f0102336:	68 d3 5d 10 f0       	push   $0xf0105dd3
f010233b:	68 7f 03 00 00       	push   $0x37f
f0102340:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102345:	e8 88 dd ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010234a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010234f:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102354:	e8 8e ec ff ff       	call   f0100fe7 <check_va2pa>
f0102359:	89 f2                	mov    %esi,%edx
f010235b:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0102361:	c1 fa 03             	sar    $0x3,%edx
f0102364:	c1 e2 0c             	shl    $0xc,%edx
f0102367:	39 d0                	cmp    %edx,%eax
f0102369:	74 19                	je     f0102384 <mem_init+0xcd7>
f010236b:	68 ec 5a 10 f0       	push   $0xf0105aec
f0102370:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102375:	68 80 03 00 00       	push   $0x380
f010237a:	68 ad 5d 10 f0       	push   $0xf0105dad
f010237f:	e8 4e dd ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 1);
f0102384:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102389:	74 19                	je     f01023a4 <mem_init+0xcf7>
f010238b:	68 7b 5f 10 f0       	push   $0xf0105f7b
f0102390:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102395:	68 81 03 00 00       	push   $0x381
f010239a:	68 ad 5d 10 f0       	push   $0xf0105dad
f010239f:	e8 2e dd ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 0);
f01023a4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023a9:	74 19                	je     f01023c4 <mem_init+0xd17>
f01023ab:	68 d5 5f 10 f0       	push   $0xf0105fd5
f01023b0:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01023b5:	68 82 03 00 00       	push   $0x382
f01023ba:	68 ad 5d 10 f0       	push   $0xf0105dad
f01023bf:	e8 0e dd ff ff       	call   f01000d2 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01023c4:	83 ec 08             	sub    $0x8,%esp
f01023c7:	68 00 10 00 00       	push   $0x1000
f01023cc:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f01023d2:	e8 20 f2 ff ff       	call   f01015f7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023d7:	ba 00 00 00 00       	mov    $0x0,%edx
f01023dc:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01023e1:	e8 01 ec ff ff       	call   f0100fe7 <check_va2pa>
f01023e6:	83 c4 10             	add    $0x10,%esp
f01023e9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023ec:	74 19                	je     f0102407 <mem_init+0xd5a>
f01023ee:	68 40 5b 10 f0       	push   $0xf0105b40
f01023f3:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01023f8:	68 86 03 00 00       	push   $0x386
f01023fd:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102402:	e8 cb dc ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102407:	ba 00 10 00 00       	mov    $0x1000,%edx
f010240c:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102411:	e8 d1 eb ff ff       	call   f0100fe7 <check_va2pa>
f0102416:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102419:	74 19                	je     f0102434 <mem_init+0xd87>
f010241b:	68 64 5b 10 f0       	push   $0xf0105b64
f0102420:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102425:	68 87 03 00 00       	push   $0x387
f010242a:	68 ad 5d 10 f0       	push   $0xf0105dad
f010242f:	e8 9e dc ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 0);
f0102434:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102439:	74 19                	je     f0102454 <mem_init+0xda7>
f010243b:	68 e6 5f 10 f0       	push   $0xf0105fe6
f0102440:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102445:	68 88 03 00 00       	push   $0x388
f010244a:	68 ad 5d 10 f0       	push   $0xf0105dad
f010244f:	e8 7e dc ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 0);
f0102454:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102459:	74 19                	je     f0102474 <mem_init+0xdc7>
f010245b:	68 d5 5f 10 f0       	push   $0xf0105fd5
f0102460:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102465:	68 89 03 00 00       	push   $0x389
f010246a:	68 ad 5d 10 f0       	push   $0xf0105dad
f010246f:	e8 5e dc ff ff       	call   f01000d2 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102474:	83 ec 0c             	sub    $0xc,%esp
f0102477:	6a 00                	push   $0x0
f0102479:	e8 58 ef ff ff       	call   f01013d6 <page_alloc>
f010247e:	83 c4 10             	add    $0x10,%esp
f0102481:	85 c0                	test   %eax,%eax
f0102483:	74 04                	je     f0102489 <mem_init+0xddc>
f0102485:	39 c6                	cmp    %eax,%esi
f0102487:	74 19                	je     f01024a2 <mem_init+0xdf5>
f0102489:	68 8c 5b 10 f0       	push   $0xf0105b8c
f010248e:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102493:	68 8c 03 00 00       	push   $0x38c
f0102498:	68 ad 5d 10 f0       	push   $0xf0105dad
f010249d:	e8 30 dc ff ff       	call   f01000d2 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01024a2:	83 ec 0c             	sub    $0xc,%esp
f01024a5:	6a 00                	push   $0x0
f01024a7:	e8 2a ef ff ff       	call   f01013d6 <page_alloc>
f01024ac:	83 c4 10             	add    $0x10,%esp
f01024af:	85 c0                	test   %eax,%eax
f01024b1:	74 19                	je     f01024cc <mem_init+0xe1f>
f01024b3:	68 29 5f 10 f0       	push   $0xf0105f29
f01024b8:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01024bd:	68 8f 03 00 00       	push   $0x38f
f01024c2:	68 ad 5d 10 f0       	push   $0xf0105dad
f01024c7:	e8 06 dc ff ff       	call   f01000d2 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01024cc:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01024d1:	8b 08                	mov    (%eax),%ecx
f01024d3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01024d9:	89 fa                	mov    %edi,%edx
f01024db:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f01024e1:	c1 fa 03             	sar    $0x3,%edx
f01024e4:	c1 e2 0c             	shl    $0xc,%edx
f01024e7:	39 d1                	cmp    %edx,%ecx
f01024e9:	74 19                	je     f0102504 <mem_init+0xe57>
f01024eb:	68 68 58 10 f0       	push   $0xf0105868
f01024f0:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01024f5:	68 92 03 00 00       	push   $0x392
f01024fa:	68 ad 5d 10 f0       	push   $0xf0105dad
f01024ff:	e8 ce db ff ff       	call   f01000d2 <_panic>
	kern_pgdir[0] = 0;
f0102504:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010250a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010250f:	74 19                	je     f010252a <mem_init+0xe7d>
f0102511:	68 8c 5f 10 f0       	push   $0xf0105f8c
f0102516:	68 d3 5d 10 f0       	push   $0xf0105dd3
f010251b:	68 94 03 00 00       	push   $0x394
f0102520:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102525:	e8 a8 db ff ff       	call   f01000d2 <_panic>
	pp0->pp_ref = 0;

	kern_pgdir[PDX(va)] = 0;
f010252a:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f010252f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102535:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
f010253b:	89 f8                	mov    %edi,%eax
f010253d:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0102543:	c1 f8 03             	sar    $0x3,%eax
f0102546:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102549:	89 c2                	mov    %eax,%edx
f010254b:	c1 ea 0c             	shr    $0xc,%edx
f010254e:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0102554:	72 12                	jb     f0102568 <mem_init+0xebb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102556:	50                   	push   %eax
f0102557:	68 4c 56 10 f0       	push   $0xf010564c
f010255c:	6a 56                	push   $0x56
f010255e:	68 b9 5d 10 f0       	push   $0xf0105db9
f0102563:	e8 6a db ff ff       	call   f01000d2 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102568:	83 ec 04             	sub    $0x4,%esp
f010256b:	68 00 10 00 00       	push   $0x1000
f0102570:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102575:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010257a:	50                   	push   %eax
f010257b:	e8 d5 21 00 00       	call   f0104755 <memset>
	page_free(pp0);
f0102580:	89 3c 24             	mov    %edi,(%esp)
f0102583:	e8 d8 ee ff ff       	call   f0101460 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102588:	83 c4 0c             	add    $0xc,%esp
f010258b:	6a 01                	push   $0x1
f010258d:	6a 00                	push   $0x0
f010258f:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102595:	e8 04 ef ff ff       	call   f010149e <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010259a:	89 fa                	mov    %edi,%edx
f010259c:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f01025a2:	c1 fa 03             	sar    $0x3,%edx
f01025a5:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025a8:	89 d0                	mov    %edx,%eax
f01025aa:	c1 e8 0c             	shr    $0xc,%eax
f01025ad:	83 c4 10             	add    $0x10,%esp
f01025b0:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f01025b6:	72 12                	jb     f01025ca <mem_init+0xf1d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025b8:	52                   	push   %edx
f01025b9:	68 4c 56 10 f0       	push   $0xf010564c
f01025be:	6a 56                	push   $0x56
f01025c0:	68 b9 5d 10 f0       	push   $0xf0105db9
f01025c5:	e8 08 db ff ff       	call   f01000d2 <_panic>
	return (void *)(pa + KERNBASE);
f01025ca:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01025d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01025d3:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f01025da:	75 11                	jne    f01025ed <mem_init+0xf40>
f01025dc:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01025e2:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01025e8:	f6 00 01             	testb  $0x1,(%eax)
f01025eb:	74 19                	je     f0102606 <mem_init+0xf59>
f01025ed:	68 f7 5f 10 f0       	push   $0xf0105ff7
f01025f2:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01025f7:	68 a0 03 00 00       	push   $0x3a0
f01025fc:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102601:	e8 cc da ff ff       	call   f01000d2 <_panic>
f0102606:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102609:	39 d0                	cmp    %edx,%eax
f010260b:	75 db                	jne    f01025e8 <mem_init+0xf3b>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010260d:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102612:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102618:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f010261e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102621:	89 0d 70 04 1e f0    	mov    %ecx,0xf01e0470

	// free the pages we took
	page_free(pp0);
f0102627:	83 ec 0c             	sub    $0xc,%esp
f010262a:	57                   	push   %edi
f010262b:	e8 30 ee ff ff       	call   f0101460 <page_free>
	page_free(pp1);
f0102630:	89 34 24             	mov    %esi,(%esp)
f0102633:	e8 28 ee ff ff       	call   f0101460 <page_free>
	page_free(pp2);
f0102638:	89 1c 24             	mov    %ebx,(%esp)
f010263b:	e8 20 ee ff ff       	call   f0101460 <page_free>

	cprintf("check_page() succeeded!\n");
f0102640:	c7 04 24 0e 60 10 f0 	movl   $0xf010600e,(%esp)
f0102647:	e8 e1 0e 00 00       	call   f010352d <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f010264c:	a1 4c 11 1e f0       	mov    0xf01e114c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102651:	83 c4 10             	add    $0x10,%esp
f0102654:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102659:	77 15                	ja     f0102670 <mem_init+0xfc3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010265b:	50                   	push   %eax
f010265c:	68 7c 54 10 f0       	push   $0xf010547c
f0102661:	68 b7 00 00 00       	push   $0xb7
f0102666:	68 ad 5d 10 f0       	push   $0xf0105dad
f010266b:	e8 62 da ff ff       	call   f01000d2 <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102670:	8b 15 44 11 1e f0    	mov    0xf01e1144,%edx
f0102676:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f010267d:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102680:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102686:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102688:	05 00 00 00 10       	add    $0x10000000,%eax
f010268d:	50                   	push   %eax
f010268e:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102693:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102698:	e8 98 ee ff ff       	call   f0101535 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    boot_map_region(kern_pgdir,
f010269d:	a1 7c 04 1e f0       	mov    0xf01e047c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026a2:	83 c4 10             	add    $0x10,%esp
f01026a5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026aa:	77 15                	ja     f01026c1 <mem_init+0x1014>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026ac:	50                   	push   %eax
f01026ad:	68 7c 54 10 f0       	push   $0xf010547c
f01026b2:	68 c4 00 00 00       	push   $0xc4
f01026b7:	68 ad 5d 10 f0       	push   $0xf0105dad
f01026bc:	e8 11 da ff ff       	call   f01000d2 <_panic>
f01026c1:	83 ec 08             	sub    $0x8,%esp
f01026c4:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01026c6:	05 00 00 00 10       	add    $0x10000000,%eax
f01026cb:	50                   	push   %eax
f01026cc:	b9 00 80 01 00       	mov    $0x18000,%ecx
f01026d1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01026d6:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f01026db:	e8 55 ee ff ff       	call   f0101535 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026e0:	83 c4 10             	add    $0x10,%esp
f01026e3:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f01026e8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026ed:	77 15                	ja     f0102704 <mem_init+0x1057>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026ef:	50                   	push   %eax
f01026f0:	68 7c 54 10 f0       	push   $0xf010547c
f01026f5:	68 d5 00 00 00       	push   $0xd5
f01026fa:	68 ad 5d 10 f0       	push   $0xf0105dad
f01026ff:	e8 ce d9 ff ff       	call   f01000d2 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102704:	83 ec 08             	sub    $0x8,%esp
f0102707:	6a 02                	push   $0x2
f0102709:	68 00 90 11 00       	push   $0x119000
f010270e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102713:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102718:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f010271d:	e8 13 ee ff ff       	call   f0101535 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102722:	83 c4 08             	add    $0x8,%esp
f0102725:	6a 02                	push   $0x2
f0102727:	6a 00                	push   $0x0
f0102729:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010272e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102733:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102738:	e8 f8 ed ff ff       	call   f0101535 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010273d:	8b 1d 48 11 1e f0    	mov    0xf01e1148,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102743:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f0102748:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f010274f:	83 c4 10             	add    $0x10,%esp
f0102752:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102758:	74 63                	je     f01027bd <mem_init+0x1110>
f010275a:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010275f:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102765:	89 d8                	mov    %ebx,%eax
f0102767:	e8 7b e8 ff ff       	call   f0100fe7 <check_va2pa>
f010276c:	8b 15 4c 11 1e f0    	mov    0xf01e114c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102772:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102778:	77 15                	ja     f010278f <mem_init+0x10e2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010277a:	52                   	push   %edx
f010277b:	68 7c 54 10 f0       	push   $0xf010547c
f0102780:	68 e8 02 00 00       	push   $0x2e8
f0102785:	68 ad 5d 10 f0       	push   $0xf0105dad
f010278a:	e8 43 d9 ff ff       	call   f01000d2 <_panic>
f010278f:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102796:	39 d0                	cmp    %edx,%eax
f0102798:	74 19                	je     f01027b3 <mem_init+0x1106>
f010279a:	68 b0 5b 10 f0       	push   $0xf0105bb0
f010279f:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01027a4:	68 e8 02 00 00       	push   $0x2e8
f01027a9:	68 ad 5d 10 f0       	push   $0xf0105dad
f01027ae:	e8 1f d9 ff ff       	call   f01000d2 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027b3:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027b9:	39 f7                	cmp    %esi,%edi
f01027bb:	77 a2                	ja     f010275f <mem_init+0x10b2>
f01027bd:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01027c2:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f01027c8:	89 d8                	mov    %ebx,%eax
f01027ca:	e8 18 e8 ff ff       	call   f0100fe7 <check_va2pa>
f01027cf:	8b 15 7c 04 1e f0    	mov    0xf01e047c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027d5:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01027db:	77 15                	ja     f01027f2 <mem_init+0x1145>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027dd:	52                   	push   %edx
f01027de:	68 7c 54 10 f0       	push   $0xf010547c
f01027e3:	68 ed 02 00 00       	push   $0x2ed
f01027e8:	68 ad 5d 10 f0       	push   $0xf0105dad
f01027ed:	e8 e0 d8 ff ff       	call   f01000d2 <_panic>
f01027f2:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01027f9:	39 d0                	cmp    %edx,%eax
f01027fb:	74 19                	je     f0102816 <mem_init+0x1169>
f01027fd:	68 e4 5b 10 f0       	push   $0xf0105be4
f0102802:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102807:	68 ed 02 00 00       	push   $0x2ed
f010280c:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102811:	e8 bc d8 ff ff       	call   f01000d2 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102816:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010281c:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f0102822:	75 9e                	jne    f01027c2 <mem_init+0x1115>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102824:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f0102829:	c1 e0 0c             	shl    $0xc,%eax
f010282c:	74 41                	je     f010286f <mem_init+0x11c2>
f010282e:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102833:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102839:	89 d8                	mov    %ebx,%eax
f010283b:	e8 a7 e7 ff ff       	call   f0100fe7 <check_va2pa>
f0102840:	39 c6                	cmp    %eax,%esi
f0102842:	74 19                	je     f010285d <mem_init+0x11b0>
f0102844:	68 18 5c 10 f0       	push   $0xf0105c18
f0102849:	68 d3 5d 10 f0       	push   $0xf0105dd3
f010284e:	68 f1 02 00 00       	push   $0x2f1
f0102853:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102858:	e8 75 d8 ff ff       	call   f01000d2 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010285d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102863:	a1 44 11 1e f0       	mov    0xf01e1144,%eax
f0102868:	c1 e0 0c             	shl    $0xc,%eax
f010286b:	39 c6                	cmp    %eax,%esi
f010286d:	72 c4                	jb     f0102833 <mem_init+0x1186>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010286f:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102874:	89 d8                	mov    %ebx,%eax
f0102876:	e8 6c e7 ff ff       	call   f0100fe7 <check_va2pa>
f010287b:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102880:	bf 00 90 11 f0       	mov    $0xf0119000,%edi
f0102885:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010288b:	8d 14 37             	lea    (%edi,%esi,1),%edx
f010288e:	39 c2                	cmp    %eax,%edx
f0102890:	74 19                	je     f01028ab <mem_init+0x11fe>
f0102892:	68 40 5c 10 f0       	push   $0xf0105c40
f0102897:	68 d3 5d 10 f0       	push   $0xf0105dd3
f010289c:	68 f5 02 00 00       	push   $0x2f5
f01028a1:	68 ad 5d 10 f0       	push   $0xf0105dad
f01028a6:	e8 27 d8 ff ff       	call   f01000d2 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01028ab:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01028b1:	0f 85 25 04 00 00    	jne    f0102cdc <mem_init+0x162f>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01028b7:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01028bc:	89 d8                	mov    %ebx,%eax
f01028be:	e8 24 e7 ff ff       	call   f0100fe7 <check_va2pa>
f01028c3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028c6:	74 19                	je     f01028e1 <mem_init+0x1234>
f01028c8:	68 88 5c 10 f0       	push   $0xf0105c88
f01028cd:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01028d2:	68 f6 02 00 00       	push   $0x2f6
f01028d7:	68 ad 5d 10 f0       	push   $0xf0105dad
f01028dc:	e8 f1 d7 ff ff       	call   f01000d2 <_panic>
f01028e1:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01028e6:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01028eb:	72 2d                	jb     f010291a <mem_init+0x126d>
f01028ed:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01028f2:	76 07                	jbe    f01028fb <mem_init+0x124e>
f01028f4:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01028f9:	75 1f                	jne    f010291a <mem_init+0x126d>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f01028fb:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01028ff:	75 7e                	jne    f010297f <mem_init+0x12d2>
f0102901:	68 27 60 10 f0       	push   $0xf0106027
f0102906:	68 d3 5d 10 f0       	push   $0xf0105dd3
f010290b:	68 ff 02 00 00       	push   $0x2ff
f0102910:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102915:	e8 b8 d7 ff ff       	call   f01000d2 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010291a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010291f:	76 3f                	jbe    f0102960 <mem_init+0x12b3>
				assert(pgdir[i] & PTE_P);
f0102921:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102924:	f6 c2 01             	test   $0x1,%dl
f0102927:	75 19                	jne    f0102942 <mem_init+0x1295>
f0102929:	68 27 60 10 f0       	push   $0xf0106027
f010292e:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102933:	68 03 03 00 00       	push   $0x303
f0102938:	68 ad 5d 10 f0       	push   $0xf0105dad
f010293d:	e8 90 d7 ff ff       	call   f01000d2 <_panic>
				assert(pgdir[i] & PTE_W);
f0102942:	f6 c2 02             	test   $0x2,%dl
f0102945:	75 38                	jne    f010297f <mem_init+0x12d2>
f0102947:	68 38 60 10 f0       	push   $0xf0106038
f010294c:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102951:	68 04 03 00 00       	push   $0x304
f0102956:	68 ad 5d 10 f0       	push   $0xf0105dad
f010295b:	e8 72 d7 ff ff       	call   f01000d2 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102960:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102964:	74 19                	je     f010297f <mem_init+0x12d2>
f0102966:	68 49 60 10 f0       	push   $0xf0106049
f010296b:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102970:	68 06 03 00 00       	push   $0x306
f0102975:	68 ad 5d 10 f0       	push   $0xf0105dad
f010297a:	e8 53 d7 ff ff       	call   f01000d2 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010297f:	40                   	inc    %eax
f0102980:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102985:	0f 85 5b ff ff ff    	jne    f01028e6 <mem_init+0x1239>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010298b:	83 ec 0c             	sub    $0xc,%esp
f010298e:	68 b8 5c 10 f0       	push   $0xf0105cb8
f0102993:	e8 95 0b 00 00       	call   f010352d <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102998:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010299d:	83 c4 10             	add    $0x10,%esp
f01029a0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029a5:	77 15                	ja     f01029bc <mem_init+0x130f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029a7:	50                   	push   %eax
f01029a8:	68 7c 54 10 f0       	push   $0xf010547c
f01029ad:	68 f2 00 00 00       	push   $0xf2
f01029b2:	68 ad 5d 10 f0       	push   $0xf0105dad
f01029b7:	e8 16 d7 ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01029bc:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01029c1:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01029c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01029c9:	e8 a2 e6 ff ff       	call   f0101070 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01029ce:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01029d1:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01029d6:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01029d9:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029dc:	83 ec 0c             	sub    $0xc,%esp
f01029df:	6a 00                	push   $0x0
f01029e1:	e8 f0 e9 ff ff       	call   f01013d6 <page_alloc>
f01029e6:	89 c6                	mov    %eax,%esi
f01029e8:	83 c4 10             	add    $0x10,%esp
f01029eb:	85 c0                	test   %eax,%eax
f01029ed:	75 19                	jne    f0102a08 <mem_init+0x135b>
f01029ef:	68 7e 5e 10 f0       	push   $0xf0105e7e
f01029f4:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01029f9:	68 bb 03 00 00       	push   $0x3bb
f01029fe:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102a03:	e8 ca d6 ff ff       	call   f01000d2 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a08:	83 ec 0c             	sub    $0xc,%esp
f0102a0b:	6a 00                	push   $0x0
f0102a0d:	e8 c4 e9 ff ff       	call   f01013d6 <page_alloc>
f0102a12:	89 c7                	mov    %eax,%edi
f0102a14:	83 c4 10             	add    $0x10,%esp
f0102a17:	85 c0                	test   %eax,%eax
f0102a19:	75 19                	jne    f0102a34 <mem_init+0x1387>
f0102a1b:	68 94 5e 10 f0       	push   $0xf0105e94
f0102a20:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102a25:	68 bc 03 00 00       	push   $0x3bc
f0102a2a:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102a2f:	e8 9e d6 ff ff       	call   f01000d2 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a34:	83 ec 0c             	sub    $0xc,%esp
f0102a37:	6a 00                	push   $0x0
f0102a39:	e8 98 e9 ff ff       	call   f01013d6 <page_alloc>
f0102a3e:	89 c3                	mov    %eax,%ebx
f0102a40:	83 c4 10             	add    $0x10,%esp
f0102a43:	85 c0                	test   %eax,%eax
f0102a45:	75 19                	jne    f0102a60 <mem_init+0x13b3>
f0102a47:	68 aa 5e 10 f0       	push   $0xf0105eaa
f0102a4c:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102a51:	68 bd 03 00 00       	push   $0x3bd
f0102a56:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102a5b:	e8 72 d6 ff ff       	call   f01000d2 <_panic>
	page_free(pp0);
f0102a60:	83 ec 0c             	sub    $0xc,%esp
f0102a63:	56                   	push   %esi
f0102a64:	e8 f7 e9 ff ff       	call   f0101460 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a69:	89 f8                	mov    %edi,%eax
f0102a6b:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0102a71:	c1 f8 03             	sar    $0x3,%eax
f0102a74:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a77:	89 c2                	mov    %eax,%edx
f0102a79:	c1 ea 0c             	shr    $0xc,%edx
f0102a7c:	83 c4 10             	add    $0x10,%esp
f0102a7f:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0102a85:	72 12                	jb     f0102a99 <mem_init+0x13ec>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a87:	50                   	push   %eax
f0102a88:	68 4c 56 10 f0       	push   $0xf010564c
f0102a8d:	6a 56                	push   $0x56
f0102a8f:	68 b9 5d 10 f0       	push   $0xf0105db9
f0102a94:	e8 39 d6 ff ff       	call   f01000d2 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a99:	83 ec 04             	sub    $0x4,%esp
f0102a9c:	68 00 10 00 00       	push   $0x1000
f0102aa1:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102aa3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102aa8:	50                   	push   %eax
f0102aa9:	e8 a7 1c 00 00       	call   f0104755 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102aae:	89 d8                	mov    %ebx,%eax
f0102ab0:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0102ab6:	c1 f8 03             	sar    $0x3,%eax
f0102ab9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102abc:	89 c2                	mov    %eax,%edx
f0102abe:	c1 ea 0c             	shr    $0xc,%edx
f0102ac1:	83 c4 10             	add    $0x10,%esp
f0102ac4:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0102aca:	72 12                	jb     f0102ade <mem_init+0x1431>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102acc:	50                   	push   %eax
f0102acd:	68 4c 56 10 f0       	push   $0xf010564c
f0102ad2:	6a 56                	push   $0x56
f0102ad4:	68 b9 5d 10 f0       	push   $0xf0105db9
f0102ad9:	e8 f4 d5 ff ff       	call   f01000d2 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102ade:	83 ec 04             	sub    $0x4,%esp
f0102ae1:	68 00 10 00 00       	push   $0x1000
f0102ae6:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102ae8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102aed:	50                   	push   %eax
f0102aee:	e8 62 1c 00 00       	call   f0104755 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102af3:	6a 02                	push   $0x2
f0102af5:	68 00 10 00 00       	push   $0x1000
f0102afa:	57                   	push   %edi
f0102afb:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102b01:	e8 3e eb ff ff       	call   f0101644 <page_insert>
	assert(pp1->pp_ref == 1);
f0102b06:	83 c4 20             	add    $0x20,%esp
f0102b09:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b0e:	74 19                	je     f0102b29 <mem_init+0x147c>
f0102b10:	68 7b 5f 10 f0       	push   $0xf0105f7b
f0102b15:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102b1a:	68 c2 03 00 00       	push   $0x3c2
f0102b1f:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102b24:	e8 a9 d5 ff ff       	call   f01000d2 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b29:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b30:	01 01 01 
f0102b33:	74 19                	je     f0102b4e <mem_init+0x14a1>
f0102b35:	68 d8 5c 10 f0       	push   $0xf0105cd8
f0102b3a:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102b3f:	68 c3 03 00 00       	push   $0x3c3
f0102b44:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102b49:	e8 84 d5 ff ff       	call   f01000d2 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b4e:	6a 02                	push   $0x2
f0102b50:	68 00 10 00 00       	push   $0x1000
f0102b55:	53                   	push   %ebx
f0102b56:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102b5c:	e8 e3 ea ff ff       	call   f0101644 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b61:	83 c4 10             	add    $0x10,%esp
f0102b64:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b6b:	02 02 02 
f0102b6e:	74 19                	je     f0102b89 <mem_init+0x14dc>
f0102b70:	68 fc 5c 10 f0       	push   $0xf0105cfc
f0102b75:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102b7a:	68 c5 03 00 00       	push   $0x3c5
f0102b7f:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102b84:	e8 49 d5 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f0102b89:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b8e:	74 19                	je     f0102ba9 <mem_init+0x14fc>
f0102b90:	68 9d 5f 10 f0       	push   $0xf0105f9d
f0102b95:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102b9a:	68 c6 03 00 00       	push   $0x3c6
f0102b9f:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102ba4:	e8 29 d5 ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 0);
f0102ba9:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102bae:	74 19                	je     f0102bc9 <mem_init+0x151c>
f0102bb0:	68 e6 5f 10 f0       	push   $0xf0105fe6
f0102bb5:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102bba:	68 c7 03 00 00       	push   $0x3c7
f0102bbf:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102bc4:	e8 09 d5 ff ff       	call   f01000d2 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102bc9:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102bd0:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bd3:	89 d8                	mov    %ebx,%eax
f0102bd5:	2b 05 4c 11 1e f0    	sub    0xf01e114c,%eax
f0102bdb:	c1 f8 03             	sar    $0x3,%eax
f0102bde:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102be1:	89 c2                	mov    %eax,%edx
f0102be3:	c1 ea 0c             	shr    $0xc,%edx
f0102be6:	3b 15 44 11 1e f0    	cmp    0xf01e1144,%edx
f0102bec:	72 12                	jb     f0102c00 <mem_init+0x1553>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bee:	50                   	push   %eax
f0102bef:	68 4c 56 10 f0       	push   $0xf010564c
f0102bf4:	6a 56                	push   $0x56
f0102bf6:	68 b9 5d 10 f0       	push   $0xf0105db9
f0102bfb:	e8 d2 d4 ff ff       	call   f01000d2 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c00:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c07:	03 03 03 
f0102c0a:	74 19                	je     f0102c25 <mem_init+0x1578>
f0102c0c:	68 20 5d 10 f0       	push   $0xf0105d20
f0102c11:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102c16:	68 c9 03 00 00       	push   $0x3c9
f0102c1b:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102c20:	e8 ad d4 ff ff       	call   f01000d2 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c25:	83 ec 08             	sub    $0x8,%esp
f0102c28:	68 00 10 00 00       	push   $0x1000
f0102c2d:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102c33:	e8 bf e9 ff ff       	call   f01015f7 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c38:	83 c4 10             	add    $0x10,%esp
f0102c3b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c40:	74 19                	je     f0102c5b <mem_init+0x15ae>
f0102c42:	68 d5 5f 10 f0       	push   $0xf0105fd5
f0102c47:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102c4c:	68 cb 03 00 00       	push   $0x3cb
f0102c51:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102c56:	e8 77 d4 ff ff       	call   f01000d2 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c5b:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
f0102c60:	8b 08                	mov    (%eax),%ecx
f0102c62:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c68:	89 f2                	mov    %esi,%edx
f0102c6a:	2b 15 4c 11 1e f0    	sub    0xf01e114c,%edx
f0102c70:	c1 fa 03             	sar    $0x3,%edx
f0102c73:	c1 e2 0c             	shl    $0xc,%edx
f0102c76:	39 d1                	cmp    %edx,%ecx
f0102c78:	74 19                	je     f0102c93 <mem_init+0x15e6>
f0102c7a:	68 68 58 10 f0       	push   $0xf0105868
f0102c7f:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102c84:	68 ce 03 00 00       	push   $0x3ce
f0102c89:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102c8e:	e8 3f d4 ff ff       	call   f01000d2 <_panic>
	kern_pgdir[0] = 0;
f0102c93:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102c99:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c9e:	74 19                	je     f0102cb9 <mem_init+0x160c>
f0102ca0:	68 8c 5f 10 f0       	push   $0xf0105f8c
f0102ca5:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0102caa:	68 d0 03 00 00       	push   $0x3d0
f0102caf:	68 ad 5d 10 f0       	push   $0xf0105dad
f0102cb4:	e8 19 d4 ff ff       	call   f01000d2 <_panic>
	pp0->pp_ref = 0;
f0102cb9:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102cbf:	83 ec 0c             	sub    $0xc,%esp
f0102cc2:	56                   	push   %esi
f0102cc3:	e8 98 e7 ff ff       	call   f0101460 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102cc8:	c7 04 24 4c 5d 10 f0 	movl   $0xf0105d4c,(%esp)
f0102ccf:	e8 59 08 00 00       	call   f010352d <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cd7:	5b                   	pop    %ebx
f0102cd8:	5e                   	pop    %esi
f0102cd9:	5f                   	pop    %edi
f0102cda:	c9                   	leave  
f0102cdb:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102cdc:	89 f2                	mov    %esi,%edx
f0102cde:	89 d8                	mov    %ebx,%eax
f0102ce0:	e8 02 e3 ff ff       	call   f0100fe7 <check_va2pa>
f0102ce5:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102ceb:	e9 9b fb ff ff       	jmp    f010288b <mem_init+0x11de>

f0102cf0 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102cf0:	55                   	push   %ebp
f0102cf1:	89 e5                	mov    %esp,%ebp
f0102cf3:	57                   	push   %edi
f0102cf4:	56                   	push   %esi
f0102cf5:	53                   	push   %ebx
f0102cf6:	83 ec 1c             	sub    $0x1c,%esp
f0102cf9:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102cfc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102cff:	8b 55 10             	mov    0x10(%ebp),%edx
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f0102d02:	85 d2                	test   %edx,%edx
f0102d04:	0f 84 85 00 00 00    	je     f0102d8f <user_mem_check+0x9f>

	perm |= PTE_P;
f0102d0a:	8b 75 14             	mov    0x14(%ebp),%esi
f0102d0d:	83 ce 01             	or     $0x1,%esi
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
f0102d10:	89 c3                	mov    %eax,%ebx
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
f0102d12:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0102d19:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102d1f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f0102d22:	89 c2                	mov    %eax,%edx
f0102d24:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102d2a:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
f0102d2d:	74 67                	je     f0102d96 <user_mem_check+0xa6>
		if (va_now >= ULIM) {
f0102d2f:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0102d34:	76 17                	jbe    f0102d4d <user_mem_check+0x5d>
f0102d36:	eb 08                	jmp    f0102d40 <user_mem_check+0x50>
f0102d38:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d3e:	76 0d                	jbe    f0102d4d <user_mem_check+0x5d>
			user_mem_check_addr = va_now;
f0102d40:	89 1d 6c 04 1e f0    	mov    %ebx,0xf01e046c
			return -E_FAULT;
f0102d46:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d4b:	eb 4e                	jmp    f0102d9b <user_mem_check+0xab>
		}
		pte = pgdir_walk(env->env_pgdir, (void *)va_now, false);
f0102d4d:	83 ec 04             	sub    $0x4,%esp
f0102d50:	6a 00                	push   $0x0
f0102d52:	53                   	push   %ebx
f0102d53:	ff 77 5c             	pushl  0x5c(%edi)
f0102d56:	e8 43 e7 ff ff       	call   f010149e <pgdir_walk>
		if (pte == NULL || ((*pte & perm ) != perm)) {
f0102d5b:	83 c4 10             	add    $0x10,%esp
f0102d5e:	85 c0                	test   %eax,%eax
f0102d60:	74 08                	je     f0102d6a <user_mem_check+0x7a>
f0102d62:	8b 00                	mov    (%eax),%eax
f0102d64:	21 f0                	and    %esi,%eax
f0102d66:	39 c6                	cmp    %eax,%esi
f0102d68:	74 0d                	je     f0102d77 <user_mem_check+0x87>
			user_mem_check_addr = va_now;
f0102d6a:	89 1d 6c 04 1e f0    	mov    %ebx,0xf01e046c
			return -E_FAULT;
f0102d70:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d75:	eb 24                	jmp    f0102d9b <user_mem_check+0xab>

	perm |= PTE_P;
	pte_t * pte;
	uint32_t va_now = (uint32_t)va;
	uint32_t va_last = ROUNDUP((uint32_t)va + len, PGSIZE);
	for (; ROUNDDOWN(va_now, PGSIZE) != va_last; va_now = ROUNDDOWN(va_now + PGSIZE, PGSIZE)) {
f0102d77:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d7d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102d83:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102d86:	75 b0                	jne    f0102d38 <user_mem_check+0x48>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0102d88:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d8d:	eb 0c                	jmp    f0102d9b <user_mem_check+0xab>
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	if (len == 0) return 0;		
f0102d8f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d94:	eb 05                	jmp    f0102d9b <user_mem_check+0xab>
		if (pte == NULL || ((*pte & perm ) != perm)) {
			user_mem_check_addr = va_now;
			return -E_FAULT;
		}
	}
	return 0;
f0102d96:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d9e:	5b                   	pop    %ebx
f0102d9f:	5e                   	pop    %esi
f0102da0:	5f                   	pop    %edi
f0102da1:	c9                   	leave  
f0102da2:	c3                   	ret    

f0102da3 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102da3:	55                   	push   %ebp
f0102da4:	89 e5                	mov    %esp,%ebp
f0102da6:	53                   	push   %ebx
f0102da7:	83 ec 04             	sub    $0x4,%esp
f0102daa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102dad:	8b 45 14             	mov    0x14(%ebp),%eax
f0102db0:	83 c8 04             	or     $0x4,%eax
f0102db3:	50                   	push   %eax
f0102db4:	ff 75 10             	pushl  0x10(%ebp)
f0102db7:	ff 75 0c             	pushl  0xc(%ebp)
f0102dba:	53                   	push   %ebx
f0102dbb:	e8 30 ff ff ff       	call   f0102cf0 <user_mem_check>
f0102dc0:	83 c4 10             	add    $0x10,%esp
f0102dc3:	85 c0                	test   %eax,%eax
f0102dc5:	79 21                	jns    f0102de8 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102dc7:	83 ec 04             	sub    $0x4,%esp
f0102dca:	ff 35 6c 04 1e f0    	pushl  0xf01e046c
f0102dd0:	ff 73 48             	pushl  0x48(%ebx)
f0102dd3:	68 78 5d 10 f0       	push   $0xf0105d78
f0102dd8:	e8 50 07 00 00       	call   f010352d <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102ddd:	89 1c 24             	mov    %ebx,(%esp)
f0102de0:	e8 33 06 00 00       	call   f0103418 <env_destroy>
f0102de5:	83 c4 10             	add    $0x10,%esp
	}
}
f0102de8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102deb:	c9                   	leave  
f0102dec:	c3                   	ret    
f0102ded:	00 00                	add    %al,(%eax)
	...

f0102df0 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102df0:	55                   	push   %ebp
f0102df1:	89 e5                	mov    %esp,%ebp
f0102df3:	57                   	push   %edi
f0102df4:	56                   	push   %esi
f0102df5:	53                   	push   %ebx
f0102df6:	83 ec 0c             	sub    $0xc,%esp
f0102df9:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0102dfb:	89 d3                	mov    %edx,%ebx
f0102dfd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
f0102e03:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0102e0a:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0102e10:	39 fb                	cmp    %edi,%ebx
f0102e12:	74 5a                	je     f0102e6e <region_alloc+0x7e>
        pg = page_alloc(1);
f0102e14:	83 ec 0c             	sub    $0xc,%esp
f0102e17:	6a 01                	push   $0x1
f0102e19:	e8 b8 e5 ff ff       	call   f01013d6 <page_alloc>
        if (pg == NULL) {
f0102e1e:	83 c4 10             	add    $0x10,%esp
f0102e21:	85 c0                	test   %eax,%eax
f0102e23:	75 17                	jne    f0102e3c <region_alloc+0x4c>
            panic("region_alloc : can't alloc page\n");
f0102e25:	83 ec 04             	sub    $0x4,%esp
f0102e28:	68 58 60 10 f0       	push   $0xf0106058
f0102e2d:	68 2a 01 00 00       	push   $0x12a
f0102e32:	68 d2 60 10 f0       	push   $0xf01060d2
f0102e37:	e8 96 d2 ff ff       	call   f01000d2 <_panic>
        } else {
            r = page_insert(e->env_pgdir, pg, (void *)addr, PTE_U | PTE_W);
f0102e3c:	6a 06                	push   $0x6
f0102e3e:	53                   	push   %ebx
f0102e3f:	50                   	push   %eax
f0102e40:	ff 76 5c             	pushl  0x5c(%esi)
f0102e43:	e8 fc e7 ff ff       	call   f0101644 <page_insert>
            if (r != 0) {
f0102e48:	83 c4 10             	add    $0x10,%esp
f0102e4b:	85 c0                	test   %eax,%eax
f0102e4d:	74 15                	je     f0102e64 <region_alloc+0x74>
                panic("/kern/env.c/region_alloc : %e\n", r);
f0102e4f:	50                   	push   %eax
f0102e50:	68 7c 60 10 f0       	push   $0xf010607c
f0102e55:	68 2e 01 00 00       	push   $0x12e
f0102e5a:	68 d2 60 10 f0       	push   $0xf01060d2
f0102e5f:	e8 6e d2 ff ff       	call   f01000d2 <_panic>
    uint32_t addr = (uint32_t)ROUNDDOWN(va, PGSIZE);
    uint32_t end  = (uint32_t)ROUNDUP(va + len, PGSIZE);
    struct PageInfo *pg;
    int r;
    // cprintf("region_alloc: %u %u\n", addr, end);
    for ( ; addr != end; addr += PGSIZE) {
f0102e64:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e6a:	39 df                	cmp    %ebx,%edi
f0102e6c:	75 a6                	jne    f0102e14 <region_alloc+0x24>
                panic("/kern/env.c/region_alloc : %e\n", r);
            }
        }
    }
    return;
}
f0102e6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e71:	5b                   	pop    %ebx
f0102e72:	5e                   	pop    %esi
f0102e73:	5f                   	pop    %edi
f0102e74:	c9                   	leave  
f0102e75:	c3                   	ret    

f0102e76 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e76:	55                   	push   %ebp
f0102e77:	89 e5                	mov    %esp,%ebp
f0102e79:	53                   	push   %ebx
f0102e7a:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e80:	8a 5d 10             	mov    0x10(%ebp),%bl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e83:	85 c0                	test   %eax,%eax
f0102e85:	75 0e                	jne    f0102e95 <envid2env+0x1f>
		*env_store = curenv;
f0102e87:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f0102e8c:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102e8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e93:	eb 55                	jmp    f0102eea <envid2env+0x74>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e95:	89 c2                	mov    %eax,%edx
f0102e97:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102e9d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102ea0:	c1 e2 05             	shl    $0x5,%edx
f0102ea3:	03 15 7c 04 1e f0    	add    0xf01e047c,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102ea9:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102ead:	74 05                	je     f0102eb4 <envid2env+0x3e>
f0102eaf:	39 42 48             	cmp    %eax,0x48(%edx)
f0102eb2:	74 0d                	je     f0102ec1 <envid2env+0x4b>
		*env_store = 0;
f0102eb4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102eba:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ebf:	eb 29                	jmp    f0102eea <envid2env+0x74>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102ec1:	84 db                	test   %bl,%bl
f0102ec3:	74 1e                	je     f0102ee3 <envid2env+0x6d>
f0102ec5:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f0102eca:	39 c2                	cmp    %eax,%edx
f0102ecc:	74 15                	je     f0102ee3 <envid2env+0x6d>
f0102ece:	8b 58 48             	mov    0x48(%eax),%ebx
f0102ed1:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f0102ed4:	74 0d                	je     f0102ee3 <envid2env+0x6d>
		*env_store = 0;
f0102ed6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102edc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ee1:	eb 07                	jmp    f0102eea <envid2env+0x74>
	}

	*env_store = e;
f0102ee3:	89 11                	mov    %edx,(%ecx)
	return 0;
f0102ee5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102eea:	5b                   	pop    %ebx
f0102eeb:	c9                   	leave  
f0102eec:	c3                   	ret    

f0102eed <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102eed:	55                   	push   %ebp
f0102eee:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102ef0:	b8 30 33 12 f0       	mov    $0xf0123330,%eax
f0102ef5:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102ef8:	b8 23 00 00 00       	mov    $0x23,%eax
f0102efd:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102eff:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102f01:	b0 10                	mov    $0x10,%al
f0102f03:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102f05:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102f07:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102f09:	ea 10 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f10
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102f10:	b0 00                	mov    $0x0,%al
f0102f12:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f15:	c9                   	leave  
f0102f16:	c3                   	ret    

f0102f17 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f17:	55                   	push   %ebp
f0102f18:	89 e5                	mov    %esp,%ebp
f0102f1a:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
f0102f1b:	8b 1d 7c 04 1e f0    	mov    0xf01e047c,%ebx
f0102f21:	89 1d 84 04 1e f0    	mov    %ebx,0xf01e0484
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
f0102f27:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
        envs[i].env_status = ENV_FREE;
f0102f2e:	c7 43 54 00 00 00 00 	movl   $0x0,0x54(%ebx)
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0102f35:	8d 43 60             	lea    0x60(%ebx),%eax
f0102f38:	8d 8b 00 80 01 00    	lea    0x18000(%ebx),%ecx
f0102f3e:	89 c2                	mov    %eax,%edx
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0102f40:	89 43 44             	mov    %eax,0x44(%ebx)
{
	// Set up envs array
	// LAB 3: Your code here.
    uint32_t i;
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
f0102f43:	39 c8                	cmp    %ecx,%eax
f0102f45:	74 1c                	je     f0102f63 <env_init+0x4c>
        envs[i].env_id = 0;
f0102f47:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE;
f0102f4e:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f0102f55:	83 c0 60             	add    $0x60,%eax
        if (i + 1 != NENV)
f0102f58:	39 c8                	cmp    %ecx,%eax
f0102f5a:	75 0f                	jne    f0102f6b <env_init+0x54>
            envs[i].env_link = envs + (i + 1);
        else 
            envs[i].env_link = NULL;
f0102f5c:	c7 42 44 00 00 00 00 	movl   $0x0,0x44(%edx)
    }

	// Per-CPU part of the initialization
	env_init_percpu();
f0102f63:	e8 85 ff ff ff       	call   f0102eed <env_init_percpu>
}
f0102f68:	5b                   	pop    %ebx
f0102f69:	c9                   	leave  
f0102f6a:	c3                   	ret    
    env_free_list = envs;
    for (i = 0; i < NENV; i++) {
        envs[i].env_id = 0;
        envs[i].env_status = ENV_FREE;
        if (i + 1 != NENV)
            envs[i].env_link = envs + (i + 1);
f0102f6b:	89 42 44             	mov    %eax,0x44(%edx)
f0102f6e:	89 c2                	mov    %eax,%edx
f0102f70:	eb d5                	jmp    f0102f47 <env_init+0x30>

f0102f72 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f72:	55                   	push   %ebp
f0102f73:	89 e5                	mov    %esp,%ebp
f0102f75:	56                   	push   %esi
f0102f76:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f77:	8b 35 84 04 1e f0    	mov    0xf01e0484,%esi
f0102f7d:	85 f6                	test   %esi,%esi
f0102f7f:	0f 84 8d 01 00 00    	je     f0103112 <env_alloc+0x1a0>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102f85:	83 ec 0c             	sub    $0xc,%esp
f0102f88:	6a 01                	push   $0x1
f0102f8a:	e8 47 e4 ff ff       	call   f01013d6 <page_alloc>
f0102f8f:	89 c3                	mov    %eax,%ebx
f0102f91:	83 c4 10             	add    $0x10,%esp
f0102f94:	85 c0                	test   %eax,%eax
f0102f96:	0f 84 7d 01 00 00    	je     f0103119 <env_alloc+0x1a7>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    cprintf("env_setup_vm in\n");
f0102f9c:	83 ec 0c             	sub    $0xc,%esp
f0102f9f:	68 dd 60 10 f0       	push   $0xf01060dd
f0102fa4:	e8 84 05 00 00       	call   f010352d <cprintf>

    p->pp_ref++;
f0102fa9:	66 ff 43 04          	incw   0x4(%ebx)
f0102fad:	2b 1d 4c 11 1e f0    	sub    0xf01e114c,%ebx
f0102fb3:	c1 fb 03             	sar    $0x3,%ebx
f0102fb6:	c1 e3 0c             	shl    $0xc,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102fb9:	89 d8                	mov    %ebx,%eax
f0102fbb:	c1 e8 0c             	shr    $0xc,%eax
f0102fbe:	83 c4 10             	add    $0x10,%esp
f0102fc1:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f0102fc7:	72 12                	jb     f0102fdb <env_alloc+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102fc9:	53                   	push   %ebx
f0102fca:	68 4c 56 10 f0       	push   $0xf010564c
f0102fcf:	6a 56                	push   $0x56
f0102fd1:	68 b9 5d 10 f0       	push   $0xf0105db9
f0102fd6:	e8 f7 d0 ff ff       	call   f01000d2 <_panic>
	return (void *)(pa + KERNBASE);
f0102fdb:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
    e->env_pgdir = (pde_t *)page2kva(p);
f0102fe1:	89 5e 5c             	mov    %ebx,0x5c(%esi)
    // pay attention: have we set mapped in kern_pgdir ?
    // page_insert(kern_pgdir, p, (void *)e->env_pgdir, PTE_U | PTE_W); 

    memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102fe4:	83 ec 04             	sub    $0x4,%esp
f0102fe7:	68 00 10 00 00       	push   $0x1000
f0102fec:	ff 35 48 11 1e f0    	pushl  0xf01e1148
f0102ff2:	53                   	push   %ebx
f0102ff3:	e8 11 18 00 00       	call   f0104809 <memcpy>
    memset(e->env_pgdir, 0, PDX(UTOP) * sizeof(pde_t));
f0102ff8:	83 c4 0c             	add    $0xc,%esp
f0102ffb:	68 ec 0e 00 00       	push   $0xeec
f0103000:	6a 00                	push   $0x0
f0103002:	ff 76 5c             	pushl  0x5c(%esi)
f0103005:	e8 4b 17 00 00       	call   f0104755 <memset>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010300a:	8b 46 5c             	mov    0x5c(%esi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010300d:	83 c4 10             	add    $0x10,%esp
f0103010:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103015:	77 15                	ja     f010302c <env_alloc+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103017:	50                   	push   %eax
f0103018:	68 7c 54 10 f0       	push   $0xf010547c
f010301d:	68 cc 00 00 00       	push   $0xcc
f0103022:	68 d2 60 10 f0       	push   $0xf01060d2
f0103027:	e8 a6 d0 ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010302c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103032:	83 ca 05             	or     $0x5,%edx
f0103035:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)

    cprintf("env_setup_vm out\n");
f010303b:	83 ec 0c             	sub    $0xc,%esp
f010303e:	68 ee 60 10 f0       	push   $0xf01060ee
f0103043:	e8 e5 04 00 00       	call   f010352d <cprintf>
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
    
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103048:	8b 46 48             	mov    0x48(%esi),%eax
f010304b:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103050:	83 c4 10             	add    $0x10,%esp
f0103053:	89 c1                	mov    %eax,%ecx
f0103055:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f010305b:	7f 05                	jg     f0103062 <env_alloc+0xf0>
		generation = 1 << ENVGENSHIFT;
f010305d:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0103062:	89 f0                	mov    %esi,%eax
f0103064:	2b 05 7c 04 1e f0    	sub    0xf01e047c,%eax
f010306a:	c1 f8 05             	sar    $0x5,%eax
f010306d:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0103070:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103073:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103076:	89 d3                	mov    %edx,%ebx
f0103078:	c1 e3 08             	shl    $0x8,%ebx
f010307b:	01 da                	add    %ebx,%edx
f010307d:	89 d3                	mov    %edx,%ebx
f010307f:	c1 e3 10             	shl    $0x10,%ebx
f0103082:	01 da                	add    %ebx,%edx
f0103084:	8d 04 50             	lea    (%eax,%edx,2),%eax
f0103087:	09 c1                	or     %eax,%ecx
f0103089:	89 4e 48             	mov    %ecx,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010308c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010308f:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f0103092:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0103099:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f01030a0:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01030a7:	83 ec 04             	sub    $0x4,%esp
f01030aa:	6a 44                	push   $0x44
f01030ac:	6a 00                	push   $0x0
f01030ae:	56                   	push   %esi
f01030af:	e8 a1 16 00 00       	call   f0104755 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01030b4:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f01030ba:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f01030c0:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f01030c6:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f01030cd:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f01030d3:	8b 46 44             	mov    0x44(%esi),%eax
f01030d6:	a3 84 04 1e f0       	mov    %eax,0xf01e0484
	*newenv_store = e;
f01030db:	8b 45 08             	mov    0x8(%ebp),%eax
f01030de:	89 30                	mov    %esi,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01030e0:	8b 56 48             	mov    0x48(%esi),%edx
f01030e3:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f01030e8:	83 c4 10             	add    $0x10,%esp
f01030eb:	85 c0                	test   %eax,%eax
f01030ed:	74 05                	je     f01030f4 <env_alloc+0x182>
f01030ef:	8b 40 48             	mov    0x48(%eax),%eax
f01030f2:	eb 05                	jmp    f01030f9 <env_alloc+0x187>
f01030f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01030f9:	83 ec 04             	sub    $0x4,%esp
f01030fc:	52                   	push   %edx
f01030fd:	50                   	push   %eax
f01030fe:	68 00 61 10 f0       	push   $0xf0106100
f0103103:	e8 25 04 00 00       	call   f010352d <cprintf>
	return 0;
f0103108:	83 c4 10             	add    $0x10,%esp
f010310b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103110:	eb 0c                	jmp    f010311e <env_alloc+0x1ac>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103112:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103117:	eb 05                	jmp    f010311e <env_alloc+0x1ac>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103119:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010311e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103121:	5b                   	pop    %ebx
f0103122:	5e                   	pop    %esi
f0103123:	c9                   	leave  
f0103124:	c3                   	ret    

f0103125 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103125:	55                   	push   %ebp
f0103126:	89 e5                	mov    %esp,%ebp
f0103128:	57                   	push   %edi
f0103129:	56                   	push   %esi
f010312a:	53                   	push   %ebx
f010312b:	83 ec 34             	sub    $0x34,%esp
f010312e:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("env_create %u %u %u\n", binary, size, type);
	// LAB 3: Your code here.
    struct Env * e;
    int r = env_alloc(&e, 0);
f0103131:	6a 00                	push   $0x0
f0103133:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103136:	50                   	push   %eax
f0103137:	e8 36 fe ff ff       	call   f0102f72 <env_alloc>
    if (r < 0) {
f010313c:	83 c4 10             	add    $0x10,%esp
f010313f:	85 c0                	test   %eax,%eax
f0103141:	79 15                	jns    f0103158 <env_create+0x33>
        panic("env_create: %e\n", r);
f0103143:	50                   	push   %eax
f0103144:	68 15 61 10 f0       	push   $0xf0106115
f0103149:	68 98 01 00 00       	push   $0x198
f010314e:	68 d2 60 10 f0       	push   $0xf01060d2
f0103153:	e8 7a cf ff ff       	call   f01000d2 <_panic>
    }
    load_icode(e, binary, size);
f0103158:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010315b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
f010315e:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103164:	74 17                	je     f010317d <env_create+0x58>
        panic("error elf magic number\n");
f0103166:	83 ec 04             	sub    $0x4,%esp
f0103169:	68 25 61 10 f0       	push   $0xf0106125
f010316e:	68 6d 01 00 00       	push   $0x16d
f0103173:	68 d2 60 10 f0       	push   $0xf01060d2
f0103178:	e8 55 cf ff ff       	call   f01000d2 <_panic>
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f010317d:	8b 5e 1c             	mov    0x1c(%esi),%ebx
    eph = ph + elf->e_phnum;
f0103180:	8b 7e 2c             	mov    0x2c(%esi),%edi

    lcr3(PADDR(e->env_pgdir));
f0103183:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103186:	8b 42 5c             	mov    0x5c(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103189:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010318e:	77 15                	ja     f01031a5 <env_create+0x80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103190:	50                   	push   %eax
f0103191:	68 7c 54 10 f0       	push   $0xf010547c
f0103196:	68 73 01 00 00       	push   $0x173
f010319b:	68 d2 60 10 f0       	push   $0xf01060d2
f01031a0:	e8 2d cf ff ff       	call   f01000d2 <_panic>
    struct Elf * elf = (struct Elf *)binary;
    if (elf->e_magic != ELF_MAGIC) {
        panic("error elf magic number\n");
    }
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01031a5:	8d 1c 1e             	lea    (%esi,%ebx,1),%ebx
    eph = ph + elf->e_phnum;
f01031a8:	0f b7 ff             	movzwl %di,%edi
f01031ab:	c1 e7 05             	shl    $0x5,%edi
f01031ae:	8d 3c 3b             	lea    (%ebx,%edi,1),%edi
	return (physaddr_t)kva - KERNBASE;
f01031b1:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01031b6:	0f 22 d8             	mov    %eax,%cr3

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01031b9:	39 fb                	cmp    %edi,%ebx
f01031bb:	73 48                	jae    f0103205 <env_create+0xe0>
        if (ph->p_type == ELF_PROG_LOAD) {
f01031bd:	83 3b 01             	cmpl   $0x1,(%ebx)
f01031c0:	75 3c                	jne    f01031fe <env_create+0xd9>
            // cprintf("%u %u\n", ph->p_memsz, ph->p_filesz);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01031c2:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01031c5:	8b 53 08             	mov    0x8(%ebx),%edx
f01031c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031cb:	e8 20 fc ff ff       	call   f0102df0 <region_alloc>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01031d0:	83 ec 04             	sub    $0x4,%esp
f01031d3:	ff 73 10             	pushl  0x10(%ebx)
f01031d6:	89 f0                	mov    %esi,%eax
f01031d8:	03 43 04             	add    0x4(%ebx),%eax
f01031db:	50                   	push   %eax
f01031dc:	ff 73 08             	pushl  0x8(%ebx)
f01031df:	e8 25 16 00 00       	call   f0104809 <memcpy>
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f01031e4:	8b 43 10             	mov    0x10(%ebx),%eax
f01031e7:	83 c4 0c             	add    $0xc,%esp
f01031ea:	8b 53 14             	mov    0x14(%ebx),%edx
f01031ed:	29 c2                	sub    %eax,%edx
f01031ef:	52                   	push   %edx
f01031f0:	6a 00                	push   $0x0
f01031f2:	03 43 08             	add    0x8(%ebx),%eax
f01031f5:	50                   	push   %eax
f01031f6:	e8 5a 15 00 00       	call   f0104755 <memset>
f01031fb:	83 c4 10             	add    $0x10,%esp
    struct Proghdr *ph, *eph;
    ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
    eph = ph + elf->e_phnum;

    lcr3(PADDR(e->env_pgdir));
    for (; ph < eph; ph++) {
f01031fe:	83 c3 20             	add    $0x20,%ebx
f0103201:	39 df                	cmp    %ebx,%edi
f0103203:	77 b8                	ja     f01031bd <env_create+0x98>
            // cprintf("%u %u %u\n", *(uint32_t *)(ph->p_va), binary + ph->p_offset, ph->p_filesz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            memset((void *)(ph->p_va) + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
        }
    }
    e->env_tf.tf_eip = elf->e_entry;
f0103205:	8b 46 18             	mov    0x18(%esi),%eax
f0103208:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010320b:	89 42 30             	mov    %eax,0x30(%edx)

    lcr3(PADDR(kern_pgdir));
f010320e:	a1 48 11 1e f0       	mov    0xf01e1148,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103213:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103218:	77 15                	ja     f010322f <env_create+0x10a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010321a:	50                   	push   %eax
f010321b:	68 7c 54 10 f0       	push   $0xf010547c
f0103220:	68 7f 01 00 00       	push   $0x17f
f0103225:	68 d2 60 10 f0       	push   $0xf01060d2
f010322a:	e8 a3 ce ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010322f:	05 00 00 00 10       	add    $0x10000000,%eax
f0103234:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103237:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010323c:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103241:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103244:	e8 a7 fb ff ff       	call   f0102df0 <region_alloc>
    int r = env_alloc(&e, 0);
    if (r < 0) {
        panic("env_create: %e\n", r);
    }
    load_icode(e, binary, size);
    e->env_type = type;
f0103249:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010324c:	8b 55 10             	mov    0x10(%ebp),%edx
f010324f:	89 50 50             	mov    %edx,0x50(%eax)
    // cprintf("env_create out\n");
    return;
}
f0103252:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103255:	5b                   	pop    %ebx
f0103256:	5e                   	pop    %esi
f0103257:	5f                   	pop    %edi
f0103258:	c9                   	leave  
f0103259:	c3                   	ret    

f010325a <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010325a:	55                   	push   %ebp
f010325b:	89 e5                	mov    %esp,%ebp
f010325d:	57                   	push   %edi
f010325e:	56                   	push   %esi
f010325f:	53                   	push   %ebx
f0103260:	83 ec 1c             	sub    $0x1c,%esp
f0103263:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103266:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f010326b:	39 c7                	cmp    %eax,%edi
f010326d:	75 2c                	jne    f010329b <env_free+0x41>
		lcr3(PADDR(kern_pgdir));
f010326f:	8b 15 48 11 1e f0    	mov    0xf01e1148,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103275:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010327b:	77 15                	ja     f0103292 <env_free+0x38>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010327d:	52                   	push   %edx
f010327e:	68 7c 54 10 f0       	push   $0xf010547c
f0103283:	68 ae 01 00 00       	push   $0x1ae
f0103288:	68 d2 60 10 f0       	push   $0xf01060d2
f010328d:	e8 40 ce ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103292:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103298:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010329b:	8b 4f 48             	mov    0x48(%edi),%ecx
f010329e:	ba 00 00 00 00       	mov    $0x0,%edx
f01032a3:	85 c0                	test   %eax,%eax
f01032a5:	74 03                	je     f01032aa <env_free+0x50>
f01032a7:	8b 50 48             	mov    0x48(%eax),%edx
f01032aa:	83 ec 04             	sub    $0x4,%esp
f01032ad:	51                   	push   %ecx
f01032ae:	52                   	push   %edx
f01032af:	68 3d 61 10 f0       	push   $0xf010613d
f01032b4:	e8 74 02 00 00       	call   f010352d <cprintf>
f01032b9:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01032bc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032c6:	c1 e0 02             	shl    $0x2,%eax
f01032c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01032cc:	8b 47 5c             	mov    0x5c(%edi),%eax
f01032cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01032d2:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01032d5:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01032db:	0f 84 ab 00 00 00    	je     f010338c <env_free+0x132>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01032e1:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032e7:	89 f0                	mov    %esi,%eax
f01032e9:	c1 e8 0c             	shr    $0xc,%eax
f01032ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01032ef:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f01032f5:	72 15                	jb     f010330c <env_free+0xb2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032f7:	56                   	push   %esi
f01032f8:	68 4c 56 10 f0       	push   $0xf010564c
f01032fd:	68 bd 01 00 00       	push   $0x1bd
f0103302:	68 d2 60 10 f0       	push   $0xf01060d2
f0103307:	e8 c6 cd ff ff       	call   f01000d2 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010330c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010330f:	c1 e2 16             	shl    $0x16,%edx
f0103312:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103315:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010331a:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103321:	01 
f0103322:	74 17                	je     f010333b <env_free+0xe1>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103324:	83 ec 08             	sub    $0x8,%esp
f0103327:	89 d8                	mov    %ebx,%eax
f0103329:	c1 e0 0c             	shl    $0xc,%eax
f010332c:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010332f:	50                   	push   %eax
f0103330:	ff 77 5c             	pushl  0x5c(%edi)
f0103333:	e8 bf e2 ff ff       	call   f01015f7 <page_remove>
f0103338:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010333b:	43                   	inc    %ebx
f010333c:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103342:	75 d6                	jne    f010331a <env_free+0xc0>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103344:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103347:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010334a:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103351:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103354:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f010335a:	72 14                	jb     f0103370 <env_free+0x116>
		panic("pa2page called with invalid pa");
f010335c:	83 ec 04             	sub    $0x4,%esp
f010335f:	68 34 57 10 f0       	push   $0xf0105734
f0103364:	6a 4f                	push   $0x4f
f0103366:	68 b9 5d 10 f0       	push   $0xf0105db9
f010336b:	e8 62 cd ff ff       	call   f01000d2 <_panic>
		page_decref(pa2page(pa));
f0103370:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103373:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103376:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f010337d:	03 05 4c 11 1e f0    	add    0xf01e114c,%eax
f0103383:	50                   	push   %eax
f0103384:	e8 f7 e0 ff ff       	call   f0101480 <page_decref>
f0103389:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010338c:	ff 45 e0             	incl   -0x20(%ebp)
f010338f:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103396:	0f 85 27 ff ff ff    	jne    f01032c3 <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010339c:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010339f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033a4:	77 15                	ja     f01033bb <env_free+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033a6:	50                   	push   %eax
f01033a7:	68 7c 54 10 f0       	push   $0xf010547c
f01033ac:	68 cb 01 00 00       	push   $0x1cb
f01033b1:	68 d2 60 10 f0       	push   $0xf01060d2
f01033b6:	e8 17 cd ff ff       	call   f01000d2 <_panic>
	e->env_pgdir = 0;
f01033bb:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f01033c2:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033c7:	c1 e8 0c             	shr    $0xc,%eax
f01033ca:	3b 05 44 11 1e f0    	cmp    0xf01e1144,%eax
f01033d0:	72 14                	jb     f01033e6 <env_free+0x18c>
		panic("pa2page called with invalid pa");
f01033d2:	83 ec 04             	sub    $0x4,%esp
f01033d5:	68 34 57 10 f0       	push   $0xf0105734
f01033da:	6a 4f                	push   $0x4f
f01033dc:	68 b9 5d 10 f0       	push   $0xf0105db9
f01033e1:	e8 ec cc ff ff       	call   f01000d2 <_panic>
	page_decref(pa2page(pa));
f01033e6:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01033e9:	c1 e0 03             	shl    $0x3,%eax
f01033ec:	03 05 4c 11 1e f0    	add    0xf01e114c,%eax
f01033f2:	50                   	push   %eax
f01033f3:	e8 88 e0 ff ff       	call   f0101480 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01033f8:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01033ff:	a1 84 04 1e f0       	mov    0xf01e0484,%eax
f0103404:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103407:	89 3d 84 04 1e f0    	mov    %edi,0xf01e0484
f010340d:	83 c4 10             	add    $0x10,%esp
}
f0103410:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103413:	5b                   	pop    %ebx
f0103414:	5e                   	pop    %esi
f0103415:	5f                   	pop    %edi
f0103416:	c9                   	leave  
f0103417:	c3                   	ret    

f0103418 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103418:	55                   	push   %ebp
f0103419:	89 e5                	mov    %esp,%ebp
f010341b:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f010341e:	ff 75 08             	pushl  0x8(%ebp)
f0103421:	e8 34 fe ff ff       	call   f010325a <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103426:	c7 04 24 9c 60 10 f0 	movl   $0xf010609c,(%esp)
f010342d:	e8 fb 00 00 00       	call   f010352d <cprintf>
f0103432:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0103435:	83 ec 0c             	sub    $0xc,%esp
f0103438:	6a 00                	push   $0x0
f010343a:	e8 32 da ff ff       	call   f0100e71 <monitor>
f010343f:	83 c4 10             	add    $0x10,%esp
f0103442:	eb f1                	jmp    f0103435 <env_destroy+0x1d>

f0103444 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103444:	55                   	push   %ebp
f0103445:	89 e5                	mov    %esp,%ebp
f0103447:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f010344a:	8b 65 08             	mov    0x8(%ebp),%esp
f010344d:	61                   	popa   
f010344e:	07                   	pop    %es
f010344f:	1f                   	pop    %ds
f0103450:	83 c4 08             	add    $0x8,%esp
f0103453:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103454:	68 53 61 10 f0       	push   $0xf0106153
f0103459:	68 f3 01 00 00       	push   $0x1f3
f010345e:	68 d2 60 10 f0       	push   $0xf01060d2
f0103463:	e8 6a cc ff ff       	call   f01000d2 <_panic>

f0103468 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103468:	55                   	push   %ebp
f0103469:	89 e5                	mov    %esp,%ebp
f010346b:	83 ec 08             	sub    $0x8,%esp
f010346e:	8b 45 08             	mov    0x8(%ebp),%eax
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

    if (curenv != NULL) {
f0103471:	8b 15 80 04 1e f0    	mov    0xf01e0480,%edx
f0103477:	85 d2                	test   %edx,%edx
f0103479:	74 0d                	je     f0103488 <env_run+0x20>
        // context switch
        if (curenv->env_status == ENV_RUNNING) {
f010347b:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f010347f:	75 07                	jne    f0103488 <env_run+0x20>
            curenv->env_status = ENV_RUNNABLE;
f0103481:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
        }
        // how about other env_status ? e.g. like ENV_DYING ?
    }
    curenv = e;
f0103488:	a3 80 04 1e f0       	mov    %eax,0xf01e0480
    curenv->env_status = ENV_RUNNING;
f010348d:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs++;
f0103494:	ff 40 58             	incl   0x58(%eax)
    
    // may have some problem, because lcr3(x), x should be physical address
    lcr3(PADDR(curenv->env_pgdir));
f0103497:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010349a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01034a0:	77 15                	ja     f01034b7 <env_run+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034a2:	52                   	push   %edx
f01034a3:	68 7c 54 10 f0       	push   $0xf010547c
f01034a8:	68 1e 02 00 00       	push   $0x21e
f01034ad:	68 d2 60 10 f0       	push   $0xf01060d2
f01034b2:	e8 1b cc ff ff       	call   f01000d2 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01034b7:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01034bd:	0f 22 da             	mov    %edx,%cr3

    env_pop_tf(&curenv->env_tf);    
f01034c0:	83 ec 0c             	sub    $0xc,%esp
f01034c3:	50                   	push   %eax
f01034c4:	e8 7b ff ff ff       	call   f0103444 <env_pop_tf>
f01034c9:	00 00                	add    %al,(%eax)
	...

f01034cc <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01034cc:	55                   	push   %ebp
f01034cd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034cf:	ba 70 00 00 00       	mov    $0x70,%edx
f01034d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01034d7:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034d8:	b2 71                	mov    $0x71,%dl
f01034da:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01034db:	0f b6 c0             	movzbl %al,%eax
}
f01034de:	c9                   	leave  
f01034df:	c3                   	ret    

f01034e0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01034e0:	55                   	push   %ebp
f01034e1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034e3:	ba 70 00 00 00       	mov    $0x70,%edx
f01034e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01034eb:	ee                   	out    %al,(%dx)
f01034ec:	b2 71                	mov    $0x71,%dl
f01034ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034f1:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01034f2:	c9                   	leave  
f01034f3:	c3                   	ret    

f01034f4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01034f4:	55                   	push   %ebp
f01034f5:	89 e5                	mov    %esp,%ebp
f01034f7:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01034fa:	ff 75 08             	pushl  0x8(%ebp)
f01034fd:	e8 ec d0 ff ff       	call   f01005ee <cputchar>
f0103502:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0103505:	c9                   	leave  
f0103506:	c3                   	ret    

f0103507 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103507:	55                   	push   %ebp
f0103508:	89 e5                	mov    %esp,%ebp
f010350a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010350d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103514:	ff 75 0c             	pushl  0xc(%ebp)
f0103517:	ff 75 08             	pushl  0x8(%ebp)
f010351a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010351d:	50                   	push   %eax
f010351e:	68 f4 34 10 f0       	push   $0xf01034f4
f0103523:	e8 95 0b 00 00       	call   f01040bd <vprintfmt>
	return cnt;
}
f0103528:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010352b:	c9                   	leave  
f010352c:	c3                   	ret    

f010352d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010352d:	55                   	push   %ebp
f010352e:	89 e5                	mov    %esp,%ebp
f0103530:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103533:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103536:	50                   	push   %eax
f0103537:	ff 75 08             	pushl  0x8(%ebp)
f010353a:	e8 c8 ff ff ff       	call   f0103507 <vcprintf>
	va_end(ap);

	return cnt;
}
f010353f:	c9                   	leave  
f0103540:	c3                   	ret    
f0103541:	00 00                	add    %al,(%eax)
	...

f0103544 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103544:	55                   	push   %ebp
f0103545:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103547:	c7 05 c4 0c 1e f0 00 	movl   $0xf0000000,0xf01e0cc4
f010354e:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103551:	66 c7 05 c8 0c 1e f0 	movw   $0x10,0xf01e0cc8
f0103558:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010355a:	66 c7 05 28 33 12 f0 	movw   $0x68,0xf0123328
f0103561:	68 00 
f0103563:	b8 c0 0c 1e f0       	mov    $0xf01e0cc0,%eax
f0103568:	66 a3 2a 33 12 f0    	mov    %ax,0xf012332a
f010356e:	89 c2                	mov    %eax,%edx
f0103570:	c1 ea 10             	shr    $0x10,%edx
f0103573:	88 15 2c 33 12 f0    	mov    %dl,0xf012332c
f0103579:	c6 05 2e 33 12 f0 40 	movb   $0x40,0xf012332e
f0103580:	c1 e8 18             	shr    $0x18,%eax
f0103583:	a2 2f 33 12 f0       	mov    %al,0xf012332f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103588:	c6 05 2d 33 12 f0 89 	movb   $0x89,0xf012332d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010358f:	b8 28 00 00 00       	mov    $0x28,%eax
f0103594:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103597:	b8 38 33 12 f0       	mov    $0xf0123338,%eax
f010359c:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010359f:	c9                   	leave  
f01035a0:	c3                   	ret    

f01035a1 <trap_init>:
}


void
trap_init(void)
{
f01035a1:	55                   	push   %ebp
f01035a2:	89 e5                	mov    %esp,%ebp
f01035a4:	ba 01 00 00 00       	mov    $0x1,%edx
f01035a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01035ae:	eb 02                	jmp    f01035b2 <trap_init+0x11>
f01035b0:	40                   	inc    %eax
f01035b1:	42                   	inc    %edx
    
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
    	if (i == T_BRKPT) {
f01035b2:	83 f8 03             	cmp    $0x3,%eax
f01035b5:	75 30                	jne    f01035e7 <trap_init+0x46>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
f01035b7:	8b 0d 4c 33 12 f0    	mov    0xf012334c,%ecx
f01035bd:	66 89 0d b8 04 1e f0 	mov    %cx,0xf01e04b8
f01035c4:	66 c7 05 ba 04 1e f0 	movw   $0x8,0xf01e04ba
f01035cb:	08 00 
f01035cd:	c6 05 bc 04 1e f0 00 	movb   $0x0,0xf01e04bc
f01035d4:	c6 05 bd 04 1e f0 ee 	movb   $0xee,0xf01e04bd
f01035db:	c1 e9 10             	shr    $0x10,%ecx
f01035de:	66 89 0d be 04 1e f0 	mov    %cx,0xf01e04be
f01035e5:	eb c9                	jmp    f01035b0 <trap_init+0xf>
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f01035e7:	8b 0c 85 40 33 12 f0 	mov    -0xfedccc0(,%eax,4),%ecx
f01035ee:	66 89 0c c5 a0 04 1e 	mov    %cx,-0xfe1fb60(,%eax,8)
f01035f5:	f0 
f01035f6:	66 c7 04 c5 a2 04 1e 	movw   $0x8,-0xfe1fb5e(,%eax,8)
f01035fd:	f0 08 00 
f0103600:	c6 04 c5 a4 04 1e f0 	movb   $0x0,-0xfe1fb5c(,%eax,8)
f0103607:	00 
f0103608:	c6 04 c5 a5 04 1e f0 	movb   $0x8e,-0xfe1fb5b(,%eax,8)
f010360f:	8e 
f0103610:	c1 e9 10             	shr    $0x10,%ecx
f0103613:	66 89 0c c5 a6 04 1e 	mov    %cx,-0xfe1fb5a(,%eax,8)
f010361a:	f0 
    */
    
    extern uint32_t vectors[];
    extern void vec48();
    int i;
    for (i = 0; i != 20; i++) {
f010361b:	83 fa 14             	cmp    $0x14,%edx
f010361e:	75 90                	jne    f01035b0 <trap_init+0xf>
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 3);
    	} else {
    		SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
    	}
    }
    SETGATE(idt[48], 0, GD_KT, vec48, 3);
f0103620:	b8 90 33 12 f0       	mov    $0xf0123390,%eax
f0103625:	66 a3 20 06 1e f0    	mov    %ax,0xf01e0620
f010362b:	66 c7 05 22 06 1e f0 	movw   $0x8,0xf01e0622
f0103632:	08 00 
f0103634:	c6 05 24 06 1e f0 00 	movb   $0x0,0xf01e0624
f010363b:	c6 05 25 06 1e f0 ee 	movb   $0xee,0xf01e0625
f0103642:	c1 e8 10             	shr    $0x10,%eax
f0103645:	66 a3 26 06 1e f0    	mov    %ax,0xf01e0626

	// Per-CPU setup 
	trap_init_percpu();
f010364b:	e8 f4 fe ff ff       	call   f0103544 <trap_init_percpu>
}
f0103650:	c9                   	leave  
f0103651:	c3                   	ret    

f0103652 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103652:	55                   	push   %ebp
f0103653:	89 e5                	mov    %esp,%ebp
f0103655:	53                   	push   %ebx
f0103656:	83 ec 0c             	sub    $0xc,%esp
f0103659:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010365c:	ff 33                	pushl  (%ebx)
f010365e:	68 5f 61 10 f0       	push   $0xf010615f
f0103663:	e8 c5 fe ff ff       	call   f010352d <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103668:	83 c4 08             	add    $0x8,%esp
f010366b:	ff 73 04             	pushl  0x4(%ebx)
f010366e:	68 6e 61 10 f0       	push   $0xf010616e
f0103673:	e8 b5 fe ff ff       	call   f010352d <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103678:	83 c4 08             	add    $0x8,%esp
f010367b:	ff 73 08             	pushl  0x8(%ebx)
f010367e:	68 7d 61 10 f0       	push   $0xf010617d
f0103683:	e8 a5 fe ff ff       	call   f010352d <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103688:	83 c4 08             	add    $0x8,%esp
f010368b:	ff 73 0c             	pushl  0xc(%ebx)
f010368e:	68 8c 61 10 f0       	push   $0xf010618c
f0103693:	e8 95 fe ff ff       	call   f010352d <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103698:	83 c4 08             	add    $0x8,%esp
f010369b:	ff 73 10             	pushl  0x10(%ebx)
f010369e:	68 9b 61 10 f0       	push   $0xf010619b
f01036a3:	e8 85 fe ff ff       	call   f010352d <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01036a8:	83 c4 08             	add    $0x8,%esp
f01036ab:	ff 73 14             	pushl  0x14(%ebx)
f01036ae:	68 aa 61 10 f0       	push   $0xf01061aa
f01036b3:	e8 75 fe ff ff       	call   f010352d <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01036b8:	83 c4 08             	add    $0x8,%esp
f01036bb:	ff 73 18             	pushl  0x18(%ebx)
f01036be:	68 b9 61 10 f0       	push   $0xf01061b9
f01036c3:	e8 65 fe ff ff       	call   f010352d <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01036c8:	83 c4 08             	add    $0x8,%esp
f01036cb:	ff 73 1c             	pushl  0x1c(%ebx)
f01036ce:	68 c8 61 10 f0       	push   $0xf01061c8
f01036d3:	e8 55 fe ff ff       	call   f010352d <cprintf>
f01036d8:	83 c4 10             	add    $0x10,%esp
}
f01036db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01036de:	c9                   	leave  
f01036df:	c3                   	ret    

f01036e0 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01036e0:	55                   	push   %ebp
f01036e1:	89 e5                	mov    %esp,%ebp
f01036e3:	53                   	push   %ebx
f01036e4:	83 ec 0c             	sub    $0xc,%esp
f01036e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f01036ea:	53                   	push   %ebx
f01036eb:	68 fe 62 10 f0       	push   $0xf01062fe
f01036f0:	e8 38 fe ff ff       	call   f010352d <cprintf>
	print_regs(&tf->tf_regs);
f01036f5:	89 1c 24             	mov    %ebx,(%esp)
f01036f8:	e8 55 ff ff ff       	call   f0103652 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01036fd:	83 c4 08             	add    $0x8,%esp
f0103700:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103704:	50                   	push   %eax
f0103705:	68 19 62 10 f0       	push   $0xf0106219
f010370a:	e8 1e fe ff ff       	call   f010352d <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010370f:	83 c4 08             	add    $0x8,%esp
f0103712:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103716:	50                   	push   %eax
f0103717:	68 2c 62 10 f0       	push   $0xf010622c
f010371c:	e8 0c fe ff ff       	call   f010352d <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103721:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103724:	83 c4 10             	add    $0x10,%esp
f0103727:	83 f8 13             	cmp    $0x13,%eax
f010372a:	77 09                	ja     f0103735 <print_trapframe+0x55>
		return excnames[trapno];
f010372c:	8b 14 85 20 65 10 f0 	mov    -0xfef9ae0(,%eax,4),%edx
f0103733:	eb 11                	jmp    f0103746 <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
f0103735:	83 f8 30             	cmp    $0x30,%eax
f0103738:	75 07                	jne    f0103741 <print_trapframe+0x61>
		return "System call";
f010373a:	ba d7 61 10 f0       	mov    $0xf01061d7,%edx
f010373f:	eb 05                	jmp    f0103746 <print_trapframe+0x66>
	return "(unknown trap)";
f0103741:	ba e3 61 10 f0       	mov    $0xf01061e3,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103746:	83 ec 04             	sub    $0x4,%esp
f0103749:	52                   	push   %edx
f010374a:	50                   	push   %eax
f010374b:	68 3f 62 10 f0       	push   $0xf010623f
f0103750:	e8 d8 fd ff ff       	call   f010352d <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103755:	83 c4 10             	add    $0x10,%esp
f0103758:	3b 1d a0 0c 1e f0    	cmp    0xf01e0ca0,%ebx
f010375e:	75 1a                	jne    f010377a <print_trapframe+0x9a>
f0103760:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103764:	75 14                	jne    f010377a <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103766:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103769:	83 ec 08             	sub    $0x8,%esp
f010376c:	50                   	push   %eax
f010376d:	68 51 62 10 f0       	push   $0xf0106251
f0103772:	e8 b6 fd ff ff       	call   f010352d <cprintf>
f0103777:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f010377a:	83 ec 08             	sub    $0x8,%esp
f010377d:	ff 73 2c             	pushl  0x2c(%ebx)
f0103780:	68 60 62 10 f0       	push   $0xf0106260
f0103785:	e8 a3 fd ff ff       	call   f010352d <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010378a:	83 c4 10             	add    $0x10,%esp
f010378d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103791:	75 45                	jne    f01037d8 <print_trapframe+0xf8>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103793:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103796:	a8 01                	test   $0x1,%al
f0103798:	74 07                	je     f01037a1 <print_trapframe+0xc1>
f010379a:	b9 f2 61 10 f0       	mov    $0xf01061f2,%ecx
f010379f:	eb 05                	jmp    f01037a6 <print_trapframe+0xc6>
f01037a1:	b9 fd 61 10 f0       	mov    $0xf01061fd,%ecx
f01037a6:	a8 02                	test   $0x2,%al
f01037a8:	74 07                	je     f01037b1 <print_trapframe+0xd1>
f01037aa:	ba 09 62 10 f0       	mov    $0xf0106209,%edx
f01037af:	eb 05                	jmp    f01037b6 <print_trapframe+0xd6>
f01037b1:	ba 0f 62 10 f0       	mov    $0xf010620f,%edx
f01037b6:	a8 04                	test   $0x4,%al
f01037b8:	74 07                	je     f01037c1 <print_trapframe+0xe1>
f01037ba:	b8 14 62 10 f0       	mov    $0xf0106214,%eax
f01037bf:	eb 05                	jmp    f01037c6 <print_trapframe+0xe6>
f01037c1:	b8 4d 63 10 f0       	mov    $0xf010634d,%eax
f01037c6:	51                   	push   %ecx
f01037c7:	52                   	push   %edx
f01037c8:	50                   	push   %eax
f01037c9:	68 6e 62 10 f0       	push   $0xf010626e
f01037ce:	e8 5a fd ff ff       	call   f010352d <cprintf>
f01037d3:	83 c4 10             	add    $0x10,%esp
f01037d6:	eb 10                	jmp    f01037e8 <print_trapframe+0x108>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01037d8:	83 ec 0c             	sub    $0xc,%esp
f01037db:	68 af 4e 10 f0       	push   $0xf0104eaf
f01037e0:	e8 48 fd ff ff       	call   f010352d <cprintf>
f01037e5:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01037e8:	83 ec 08             	sub    $0x8,%esp
f01037eb:	ff 73 30             	pushl  0x30(%ebx)
f01037ee:	68 7d 62 10 f0       	push   $0xf010627d
f01037f3:	e8 35 fd ff ff       	call   f010352d <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01037f8:	83 c4 08             	add    $0x8,%esp
f01037fb:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01037ff:	50                   	push   %eax
f0103800:	68 8c 62 10 f0       	push   $0xf010628c
f0103805:	e8 23 fd ff ff       	call   f010352d <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010380a:	83 c4 08             	add    $0x8,%esp
f010380d:	ff 73 38             	pushl  0x38(%ebx)
f0103810:	68 9f 62 10 f0       	push   $0xf010629f
f0103815:	e8 13 fd ff ff       	call   f010352d <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010381a:	83 c4 10             	add    $0x10,%esp
f010381d:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103821:	74 25                	je     f0103848 <print_trapframe+0x168>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103823:	83 ec 08             	sub    $0x8,%esp
f0103826:	ff 73 3c             	pushl  0x3c(%ebx)
f0103829:	68 ae 62 10 f0       	push   $0xf01062ae
f010382e:	e8 fa fc ff ff       	call   f010352d <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103833:	83 c4 08             	add    $0x8,%esp
f0103836:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010383a:	50                   	push   %eax
f010383b:	68 bd 62 10 f0       	push   $0xf01062bd
f0103840:	e8 e8 fc ff ff       	call   f010352d <cprintf>
f0103845:	83 c4 10             	add    $0x10,%esp
	}
}
f0103848:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010384b:	c9                   	leave  
f010384c:	c3                   	ret    

f010384d <page_fault_handler>:
	env_run(curenv);
}

void
page_fault_handler(struct Trapframe *tf)
{
f010384d:	55                   	push   %ebp
f010384e:	89 e5                	mov    %esp,%ebp
f0103850:	53                   	push   %ebx
f0103851:	83 ec 04             	sub    $0x4,%esp
f0103854:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103857:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT)
f010385a:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010385f:	75 17                	jne    f0103878 <page_fault_handler+0x2b>
    	panic("page_fault_handler : page fault in kernel\n");
f0103861:	83 ec 04             	sub    $0x4,%esp
f0103864:	68 98 64 10 f0       	push   $0xf0106498
f0103869:	68 1c 01 00 00       	push   $0x11c
f010386e:	68 d0 62 10 f0       	push   $0xf01062d0
f0103873:	e8 5a c8 ff ff       	call   f01000d2 <_panic>
    
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103878:	ff 73 30             	pushl  0x30(%ebx)
f010387b:	50                   	push   %eax
		curenv->env_id, fault_va, tf->tf_eip);
f010387c:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
    
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103881:	ff 70 48             	pushl  0x48(%eax)
f0103884:	68 c4 64 10 f0       	push   $0xf01064c4
f0103889:	e8 9f fc ff ff       	call   f010352d <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010388e:	89 1c 24             	mov    %ebx,(%esp)
f0103891:	e8 4a fe ff ff       	call   f01036e0 <print_trapframe>
	env_destroy(curenv);
f0103896:	83 c4 04             	add    $0x4,%esp
f0103899:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f010389f:	e8 74 fb ff ff       	call   f0103418 <env_destroy>
f01038a4:	83 c4 10             	add    $0x10,%esp
}
f01038a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038aa:	c9                   	leave  
f01038ab:	c3                   	ret    

f01038ac <trap>:
    }
}

void
trap(struct Trapframe *tf)
{
f01038ac:	55                   	push   %ebp
f01038ad:	89 e5                	mov    %esp,%ebp
f01038af:	57                   	push   %edi
f01038b0:	56                   	push   %esi
f01038b1:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01038b4:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01038b5:	9c                   	pushf  
f01038b6:	58                   	pop    %eax
	
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01038b7:	f6 c4 02             	test   $0x2,%ah
f01038ba:	74 19                	je     f01038d5 <trap+0x29>
f01038bc:	68 dc 62 10 f0       	push   $0xf01062dc
f01038c1:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01038c6:	68 f4 00 00 00       	push   $0xf4
f01038cb:	68 d0 62 10 f0       	push   $0xf01062d0
f01038d0:	e8 fd c7 ff ff       	call   f01000d2 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01038d5:	83 ec 08             	sub    $0x8,%esp
f01038d8:	56                   	push   %esi
f01038d9:	68 f5 62 10 f0       	push   $0xf01062f5
f01038de:	e8 4a fc ff ff       	call   f010352d <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01038e3:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01038e7:	83 e0 03             	and    $0x3,%eax
f01038ea:	83 c4 10             	add    $0x10,%esp
f01038ed:	83 f8 03             	cmp    $0x3,%eax
f01038f0:	75 31                	jne    f0103923 <trap+0x77>
		// Trapped from user mode.
		assert(curenv);
f01038f2:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f01038f7:	85 c0                	test   %eax,%eax
f01038f9:	75 19                	jne    f0103914 <trap+0x68>
f01038fb:	68 10 63 10 f0       	push   $0xf0106310
f0103900:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0103905:	68 fa 00 00 00       	push   $0xfa
f010390a:	68 d0 62 10 f0       	push   $0xf01062d0
f010390f:	e8 be c7 ff ff       	call   f01000d2 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103914:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103919:	89 c7                	mov    %eax,%edi
f010391b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010391d:	8b 35 80 04 1e f0    	mov    0xf01e0480,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103923:	89 35 a0 0c 1e f0    	mov    %esi,0xf01e0ca0
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
    
    cprintf("TRAP NUM : %u\n", tf->tf_trapno);
f0103929:	83 ec 08             	sub    $0x8,%esp
f010392c:	ff 76 28             	pushl  0x28(%esi)
f010392f:	68 17 63 10 f0       	push   $0xf0106317
f0103934:	e8 f4 fb ff ff       	call   f010352d <cprintf>

    int r;
    // cprintf("TRAPNO : %d\n", tf->tf_trapno);
    switch (tf->tf_trapno) {
f0103939:	83 c4 10             	add    $0x10,%esp
f010393c:	8b 46 28             	mov    0x28(%esi),%eax
f010393f:	83 f8 03             	cmp    $0x3,%eax
f0103942:	74 3a                	je     f010397e <trap+0xd2>
f0103944:	83 f8 03             	cmp    $0x3,%eax
f0103947:	77 07                	ja     f0103950 <trap+0xa4>
f0103949:	83 f8 01             	cmp    $0x1,%eax
f010394c:	75 78                	jne    f01039c6 <trap+0x11a>
f010394e:	eb 0c                	jmp    f010395c <trap+0xb0>
f0103950:	83 f8 0e             	cmp    $0xe,%eax
f0103953:	74 18                	je     f010396d <trap+0xc1>
f0103955:	83 f8 30             	cmp    $0x30,%eax
f0103958:	75 6c                	jne    f01039c6 <trap+0x11a>
f010395a:	eb 30                	jmp    f010398c <trap+0xe0>
    	case T_DEBUG:
    		monitor(tf);
f010395c:	83 ec 0c             	sub    $0xc,%esp
f010395f:	56                   	push   %esi
f0103960:	e8 0c d5 ff ff       	call   f0100e71 <monitor>
f0103965:	83 c4 10             	add    $0x10,%esp
f0103968:	e9 94 00 00 00       	jmp    f0103a01 <trap+0x155>
    		break;
        case T_PGFLT:
        	page_fault_handler(tf);
f010396d:	83 ec 0c             	sub    $0xc,%esp
f0103970:	56                   	push   %esi
f0103971:	e8 d7 fe ff ff       	call   f010384d <page_fault_handler>
f0103976:	83 c4 10             	add    $0x10,%esp
f0103979:	e9 83 00 00 00       	jmp    f0103a01 <trap+0x155>
            break;
        case T_BRKPT:
            monitor(tf); 
f010397e:	83 ec 0c             	sub    $0xc,%esp
f0103981:	56                   	push   %esi
f0103982:	e8 ea d4 ff ff       	call   f0100e71 <monitor>
f0103987:	83 c4 10             	add    $0x10,%esp
f010398a:	eb 75                	jmp    f0103a01 <trap+0x155>
            break;
        case T_SYSCALL:
            r = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f010398c:	83 ec 08             	sub    $0x8,%esp
f010398f:	ff 76 04             	pushl  0x4(%esi)
f0103992:	ff 36                	pushl  (%esi)
f0103994:	ff 76 10             	pushl  0x10(%esi)
f0103997:	ff 76 18             	pushl  0x18(%esi)
f010399a:	ff 76 14             	pushl  0x14(%esi)
f010399d:	ff 76 1c             	pushl  0x1c(%esi)
f01039a0:	e8 2b 01 00 00       	call   f0103ad0 <syscall>
                        tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
            if (r < 0)
f01039a5:	83 c4 20             	add    $0x20,%esp
f01039a8:	85 c0                	test   %eax,%eax
f01039aa:	79 15                	jns    f01039c1 <trap+0x115>
                panic("trap.c/syscall : %e\n", r);
f01039ac:	50                   	push   %eax
f01039ad:	68 26 63 10 f0       	push   $0xf0106326
f01039b2:	68 da 00 00 00       	push   $0xda
f01039b7:	68 d0 62 10 f0       	push   $0xf01062d0
f01039bc:	e8 11 c7 ff ff       	call   f01000d2 <_panic>
            else
                tf->tf_regs.reg_eax = r;
f01039c1:	89 46 1c             	mov    %eax,0x1c(%esi)
f01039c4:	eb 3b                	jmp    f0103a01 <trap+0x155>
            break;
        default:
	        // Unexpected trap: The user process or the kernel has a bug.
	        print_trapframe(tf);
f01039c6:	83 ec 0c             	sub    $0xc,%esp
f01039c9:	56                   	push   %esi
f01039ca:	e8 11 fd ff ff       	call   f01036e0 <print_trapframe>
	        if (tf->tf_cs == GD_KT)
f01039cf:	83 c4 10             	add    $0x10,%esp
f01039d2:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01039d7:	75 17                	jne    f01039f0 <trap+0x144>
		        panic("unhandled trap in kernel");
f01039d9:	83 ec 04             	sub    $0x4,%esp
f01039dc:	68 3b 63 10 f0       	push   $0xf010633b
f01039e1:	68 e2 00 00 00       	push   $0xe2
f01039e6:	68 d0 62 10 f0       	push   $0xf01062d0
f01039eb:	e8 e2 c6 ff ff       	call   f01000d2 <_panic>
	        else {
		        env_destroy(curenv);
f01039f0:	83 ec 0c             	sub    $0xc,%esp
f01039f3:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f01039f9:	e8 1a fa ff ff       	call   f0103418 <env_destroy>
f01039fe:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103a01:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f0103a06:	85 c0                	test   %eax,%eax
f0103a08:	74 06                	je     f0103a10 <trap+0x164>
f0103a0a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103a0e:	74 19                	je     f0103a29 <trap+0x17d>
f0103a10:	68 e8 64 10 f0       	push   $0xf01064e8
f0103a15:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0103a1a:	68 0c 01 00 00       	push   $0x10c
f0103a1f:	68 d0 62 10 f0       	push   $0xf01062d0
f0103a24:	e8 a9 c6 ff ff       	call   f01000d2 <_panic>
	env_run(curenv);
f0103a29:	83 ec 0c             	sub    $0xc,%esp
f0103a2c:	50                   	push   %eax
f0103a2d:	e8 36 fa ff ff       	call   f0103468 <env_run>
	...

f0103a34 <vec0>:
.data
.align 2
.globl vectors
vectors:
.text
	MYTH_NOEC(vec0, T_DIVIDE)
f0103a34:	6a 00                	push   $0x0
f0103a36:	6a 00                	push   $0x0
f0103a38:	e9 59 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a3d:	90                   	nop

f0103a3e <vec1>:
 	MYTH_NOEC(vec1, T_DEBUG)
f0103a3e:	6a 00                	push   $0x0
f0103a40:	6a 01                	push   $0x1
f0103a42:	e9 4f f9 01 00       	jmp    f0123396 <_alltraps>
f0103a47:	90                   	nop

f0103a48 <vec2>:
 	MYTH_NOEC(vec2, T_NMI)
f0103a48:	6a 00                	push   $0x0
f0103a4a:	6a 02                	push   $0x2
f0103a4c:	e9 45 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a51:	90                   	nop

f0103a52 <vec3>:
 	MYTH_NOEC(vec3, T_BRKPT)
f0103a52:	6a 00                	push   $0x0
f0103a54:	6a 03                	push   $0x3
f0103a56:	e9 3b f9 01 00       	jmp    f0123396 <_alltraps>
f0103a5b:	90                   	nop

f0103a5c <vec4>:
 	MYTH_NOEC(vec4, T_OFLOW)
f0103a5c:	6a 00                	push   $0x0
f0103a5e:	6a 04                	push   $0x4
f0103a60:	e9 31 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a65:	90                   	nop

f0103a66 <vec6>:
 	MYTH_NULL()
 	MYTH_NOEC(vec6, T_BOUND)
f0103a66:	6a 00                	push   $0x0
f0103a68:	6a 05                	push   $0x5
f0103a6a:	e9 27 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a6f:	90                   	nop

f0103a70 <vec7>:
	MYTH_NOEC(vec7, T_DEVICE)
f0103a70:	6a 00                	push   $0x0
f0103a72:	6a 07                	push   $0x7
f0103a74:	e9 1d f9 01 00       	jmp    f0123396 <_alltraps>
f0103a79:	90                   	nop

f0103a7a <vec8>:
 	MYTH(vec8, T_DBLFLT)
f0103a7a:	6a 08                	push   $0x8
f0103a7c:	e9 15 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a81:	90                   	nop

f0103a82 <vec10>:
 	MYTH_NULL()
 	MYTH(vec10, T_TSS)
f0103a82:	6a 0a                	push   $0xa
f0103a84:	e9 0d f9 01 00       	jmp    f0123396 <_alltraps>
f0103a89:	90                   	nop

f0103a8a <vec11>:
 	MYTH(vec11, T_SEGNP)
f0103a8a:	6a 0b                	push   $0xb
f0103a8c:	e9 05 f9 01 00       	jmp    f0123396 <_alltraps>
f0103a91:	90                   	nop

f0103a92 <vec12>:
 	MYTH(vec12, T_STACK)
f0103a92:	6a 0c                	push   $0xc
f0103a94:	e9 fd f8 01 00       	jmp    f0123396 <_alltraps>
f0103a99:	90                   	nop

f0103a9a <vec13>:
 	MYTH(vec13, T_GPFLT)
f0103a9a:	6a 0d                	push   $0xd
f0103a9c:	e9 f5 f8 01 00       	jmp    f0123396 <_alltraps>
f0103aa1:	90                   	nop

f0103aa2 <vec14>:
 	MYTH(vec14, T_PGFLT) 
f0103aa2:	6a 0e                	push   $0xe
f0103aa4:	e9 ed f8 01 00       	jmp    f0123396 <_alltraps>
f0103aa9:	90                   	nop

f0103aaa <vec16>:
 	MYTH_NULL()
 	MYTH_NOEC(vec16, T_FPERR)
f0103aaa:	6a 00                	push   $0x0
f0103aac:	6a 10                	push   $0x10
f0103aae:	e9 e3 f8 01 00       	jmp    f0123396 <_alltraps>
f0103ab3:	90                   	nop

f0103ab4 <vec17>:
 	MYTH(vec17, T_ALIGN)
f0103ab4:	6a 11                	push   $0x11
f0103ab6:	e9 db f8 01 00       	jmp    f0123396 <_alltraps>
f0103abb:	90                   	nop

f0103abc <vec18>:
 	MYTH_NOEC(vec18, T_MCHK)
f0103abc:	6a 00                	push   $0x0
f0103abe:	6a 12                	push   $0x12
f0103ac0:	e9 d1 f8 01 00       	jmp    f0123396 <_alltraps>
f0103ac5:	90                   	nop

f0103ac6 <vec19>:
 	MYTH_NOEC(vec19, T_SIMDERR)
f0103ac6:	6a 00                	push   $0x0
f0103ac8:	6a 13                	push   $0x13
f0103aca:	e9 c7 f8 01 00       	jmp    f0123396 <_alltraps>
	...

f0103ad0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103ad0:	55                   	push   %ebp
f0103ad1:	89 e5                	mov    %esp,%ebp
f0103ad3:	56                   	push   %esi
f0103ad4:	53                   	push   %ebx
f0103ad5:	83 ec 10             	sub    $0x10,%esp
f0103ad8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103adb:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103ade:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
    
    switch (syscallno) {
f0103ae1:	83 f8 01             	cmp    $0x1,%eax
f0103ae4:	74 40                	je     f0103b26 <syscall+0x56>
f0103ae6:	83 f8 01             	cmp    $0x1,%eax
f0103ae9:	72 10                	jb     f0103afb <syscall+0x2b>
f0103aeb:	83 f8 02             	cmp    $0x2,%eax
f0103aee:	74 40                	je     f0103b30 <syscall+0x60>
f0103af0:	83 f8 03             	cmp    $0x3,%eax
f0103af3:	0f 85 a4 00 00 00    	jne    f0103b9d <syscall+0xcd>
f0103af9:	eb 3f                	jmp    f0103b3a <syscall+0x6a>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, (void *)s, len, PTE_U);
f0103afb:	6a 04                	push   $0x4
f0103afd:	53                   	push   %ebx
f0103afe:	56                   	push   %esi
f0103aff:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103b05:	e8 99 f2 ff ff       	call   f0102da3 <user_mem_assert>
    
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103b0a:	83 c4 0c             	add    $0xc,%esp
f0103b0d:	56                   	push   %esi
f0103b0e:	53                   	push   %ebx
f0103b0f:	68 1f 4f 10 f0       	push   $0xf0104f1f
f0103b14:	e8 14 fa ff ff       	call   f010352d <cprintf>
f0103b19:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
    
    switch (syscallno) {
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
f0103b1c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b21:	e9 8b 00 00 00       	jmp    f0103bb1 <syscall+0xe1>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103b26:	e8 9d c9 ff ff       	call   f01004c8 <cons_getc>
        case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
            break;
        case SYS_cgetc:
            return sys_cgetc();
f0103b2b:	e9 81 00 00 00       	jmp    f0103bb1 <syscall+0xe1>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103b30:	a1 80 04 1e f0       	mov    0xf01e0480,%eax
f0103b35:	8b 40 48             	mov    0x48(%eax),%eax
        case SYS_cgetc:
            return sys_cgetc();
            return 0;
            break;
        case SYS_getenvid:
            return sys_getenvid();
f0103b38:	eb 77                	jmp    f0103bb1 <syscall+0xe1>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103b3a:	83 ec 04             	sub    $0x4,%esp
f0103b3d:	6a 01                	push   $0x1
f0103b3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b42:	50                   	push   %eax
f0103b43:	56                   	push   %esi
f0103b44:	e8 2d f3 ff ff       	call   f0102e76 <envid2env>
f0103b49:	83 c4 10             	add    $0x10,%esp
f0103b4c:	85 c0                	test   %eax,%eax
f0103b4e:	78 61                	js     f0103bb1 <syscall+0xe1>
		return r;
	if (e == curenv)
f0103b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b53:	8b 15 80 04 1e f0    	mov    0xf01e0480,%edx
f0103b59:	39 d0                	cmp    %edx,%eax
f0103b5b:	75 15                	jne    f0103b72 <syscall+0xa2>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103b5d:	83 ec 08             	sub    $0x8,%esp
f0103b60:	ff 70 48             	pushl  0x48(%eax)
f0103b63:	68 70 65 10 f0       	push   $0xf0106570
f0103b68:	e8 c0 f9 ff ff       	call   f010352d <cprintf>
f0103b6d:	83 c4 10             	add    $0x10,%esp
f0103b70:	eb 16                	jmp    f0103b88 <syscall+0xb8>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103b72:	83 ec 04             	sub    $0x4,%esp
f0103b75:	ff 70 48             	pushl  0x48(%eax)
f0103b78:	ff 72 48             	pushl  0x48(%edx)
f0103b7b:	68 8b 65 10 f0       	push   $0xf010658b
f0103b80:	e8 a8 f9 ff ff       	call   f010352d <cprintf>
f0103b85:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103b88:	83 ec 0c             	sub    $0xc,%esp
f0103b8b:	ff 75 f4             	pushl  -0xc(%ebp)
f0103b8e:	e8 85 f8 ff ff       	call   f0103418 <env_destroy>
f0103b93:	83 c4 10             	add    $0x10,%esp
	return 0;
f0103b96:	b8 00 00 00 00       	mov    $0x0,%eax
            break;
        case SYS_getenvid:
            return sys_getenvid();
            break;
        case SYS_env_destroy:
            return sys_env_destroy(a1);
f0103b9b:	eb 14                	jmp    f0103bb1 <syscall+0xe1>
            break;
        dafult:
            return -E_INVAL;
	}
    panic("syscall not implemented");
f0103b9d:	83 ec 04             	sub    $0x4,%esp
f0103ba0:	68 a3 65 10 f0       	push   $0xf01065a3
f0103ba5:	6a 5c                	push   $0x5c
f0103ba7:	68 bb 65 10 f0       	push   $0xf01065bb
f0103bac:	e8 21 c5 ff ff       	call   f01000d2 <_panic>
}
f0103bb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103bb4:	5b                   	pop    %ebx
f0103bb5:	5e                   	pop    %esi
f0103bb6:	c9                   	leave  
f0103bb7:	c3                   	ret    

f0103bb8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103bb8:	55                   	push   %ebp
f0103bb9:	89 e5                	mov    %esp,%ebp
f0103bbb:	57                   	push   %edi
f0103bbc:	56                   	push   %esi
f0103bbd:	53                   	push   %ebx
f0103bbe:	83 ec 14             	sub    $0x14,%esp
f0103bc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103bc4:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103bc7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103bca:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103bcd:	8b 1a                	mov    (%edx),%ebx
f0103bcf:	8b 01                	mov    (%ecx),%eax
f0103bd1:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0103bd4:	39 c3                	cmp    %eax,%ebx
f0103bd6:	0f 8f 97 00 00 00    	jg     f0103c73 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0103bdc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103be3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103be6:	01 d8                	add    %ebx,%eax
f0103be8:	89 c7                	mov    %eax,%edi
f0103bea:	c1 ef 1f             	shr    $0x1f,%edi
f0103bed:	01 c7                	add    %eax,%edi
f0103bef:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103bf1:	39 df                	cmp    %ebx,%edi
f0103bf3:	7c 31                	jl     f0103c26 <stab_binsearch+0x6e>
f0103bf5:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103bf8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103bfb:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103c00:	39 f0                	cmp    %esi,%eax
f0103c02:	0f 84 b3 00 00 00    	je     f0103cbb <stab_binsearch+0x103>
f0103c08:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103c0c:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103c10:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103c12:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103c13:	39 d8                	cmp    %ebx,%eax
f0103c15:	7c 0f                	jl     f0103c26 <stab_binsearch+0x6e>
f0103c17:	0f b6 0a             	movzbl (%edx),%ecx
f0103c1a:	83 ea 0c             	sub    $0xc,%edx
f0103c1d:	39 f1                	cmp    %esi,%ecx
f0103c1f:	75 f1                	jne    f0103c12 <stab_binsearch+0x5a>
f0103c21:	e9 97 00 00 00       	jmp    f0103cbd <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103c26:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103c29:	eb 39                	jmp    f0103c64 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103c2b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103c2e:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0103c30:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c33:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103c3a:	eb 28                	jmp    f0103c64 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103c3c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103c3f:	76 12                	jbe    f0103c53 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0103c41:	48                   	dec    %eax
f0103c42:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103c45:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103c48:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c4a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103c51:	eb 11                	jmp    f0103c64 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103c53:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103c56:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103c58:	ff 45 0c             	incl   0xc(%ebp)
f0103c5b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103c5d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103c64:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103c67:	0f 8d 76 ff ff ff    	jge    f0103be3 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103c6d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103c71:	75 0d                	jne    f0103c80 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0103c73:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103c76:	8b 03                	mov    (%ebx),%eax
f0103c78:	48                   	dec    %eax
f0103c79:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103c7c:	89 02                	mov    %eax,(%edx)
f0103c7e:	eb 55                	jmp    f0103cd5 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103c80:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103c83:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103c85:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103c88:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103c8a:	39 c1                	cmp    %eax,%ecx
f0103c8c:	7d 26                	jge    f0103cb4 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0103c8e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103c91:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103c94:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103c99:	39 f2                	cmp    %esi,%edx
f0103c9b:	74 17                	je     f0103cb4 <stab_binsearch+0xfc>
f0103c9d:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103ca1:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103ca5:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103ca6:	39 c1                	cmp    %eax,%ecx
f0103ca8:	7d 0a                	jge    f0103cb4 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0103caa:	0f b6 1a             	movzbl (%edx),%ebx
f0103cad:	83 ea 0c             	sub    $0xc,%edx
f0103cb0:	39 f3                	cmp    %esi,%ebx
f0103cb2:	75 f1                	jne    f0103ca5 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103cb4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103cb7:	89 02                	mov    %eax,(%edx)
f0103cb9:	eb 1a                	jmp    f0103cd5 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103cbb:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103cbd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103cc0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103cc3:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103cc7:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103cca:	0f 82 5b ff ff ff    	jb     f0103c2b <stab_binsearch+0x73>
f0103cd0:	e9 67 ff ff ff       	jmp    f0103c3c <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103cd5:	83 c4 14             	add    $0x14,%esp
f0103cd8:	5b                   	pop    %ebx
f0103cd9:	5e                   	pop    %esi
f0103cda:	5f                   	pop    %edi
f0103cdb:	c9                   	leave  
f0103cdc:	c3                   	ret    

f0103cdd <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103cdd:	55                   	push   %ebp
f0103cde:	89 e5                	mov    %esp,%ebp
f0103ce0:	57                   	push   %edi
f0103ce1:	56                   	push   %esi
f0103ce2:	53                   	push   %ebx
f0103ce3:	83 ec 2c             	sub    $0x2c,%esp
f0103ce6:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ce9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103cec:	c7 03 ca 65 10 f0    	movl   $0xf01065ca,(%ebx)
	info->eip_line = 0;
f0103cf2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103cf9:	c7 43 08 ca 65 10 f0 	movl   $0xf01065ca,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103d00:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103d07:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103d0a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103d11:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103d17:	0f 87 89 00 00 00    	ja     f0103da6 <debuginfo_eip+0xc9>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
f0103d1d:	6a 04                	push   $0x4
f0103d1f:	6a 10                	push   $0x10
f0103d21:	68 00 00 20 00       	push   $0x200000
f0103d26:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103d2c:	e8 bf ef ff ff       	call   f0102cf0 <user_mem_check>
f0103d31:	83 c4 10             	add    $0x10,%esp
f0103d34:	85 c0                	test   %eax,%eax
f0103d36:	0f 88 f2 01 00 00    	js     f0103f2e <debuginfo_eip+0x251>
			return -1;
		}

		stabs = usd->stabs;
f0103d3c:	a1 00 00 20 00       	mov    0x200000,%eax
f0103d41:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f0103d44:	8b 0d 04 00 20 00    	mov    0x200004,%ecx
f0103d4a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr = usd->stabstr;
f0103d4d:	a1 08 00 20 00       	mov    0x200008,%eax
f0103d52:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103d55:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
f0103d5b:	6a 04                	push   $0x4
f0103d5d:	89 c8                	mov    %ecx,%eax
f0103d5f:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0103d62:	50                   	push   %eax
f0103d63:	ff 75 d0             	pushl  -0x30(%ebp)
f0103d66:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103d6c:	e8 7f ef ff ff       	call   f0102cf0 <user_mem_check>
f0103d71:	83 c4 10             	add    $0x10,%esp
f0103d74:	85 c0                	test   %eax,%eax
f0103d76:	0f 88 b9 01 00 00    	js     f0103f35 <debuginfo_eip+0x258>
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0103d7c:	6a 04                	push   $0x4
f0103d7e:	89 f8                	mov    %edi,%eax
f0103d80:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0103d83:	50                   	push   %eax
f0103d84:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103d87:	ff 35 80 04 1e f0    	pushl  0xf01e0480
f0103d8d:	e8 5e ef ff ff       	call   f0102cf0 <user_mem_check>
f0103d92:	89 c2                	mov    %eax,%edx
f0103d94:	83 c4 10             	add    $0x10,%esp
			return -1;
f0103d97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, (uint32_t)stabstr_end - (uint32_t)stabstr, PTE_U) < 0) {
f0103d9c:	85 d2                	test   %edx,%edx
f0103d9e:	0f 88 ab 01 00 00    	js     f0103f4f <debuginfo_eip+0x272>
f0103da4:	eb 1a                	jmp    f0103dc0 <debuginfo_eip+0xe3>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103da6:	bf 80 84 11 f0       	mov    $0xf0118480,%edi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103dab:	c7 45 d4 21 fe 10 f0 	movl   $0xf010fe21,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103db2:	c7 45 cc 20 fe 10 f0 	movl   $0xf010fe20,-0x34(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103db9:	c7 45 d0 e4 67 10 f0 	movl   $0xf01067e4,-0x30(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103dc0:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0103dc3:	0f 83 73 01 00 00    	jae    f0103f3c <debuginfo_eip+0x25f>
f0103dc9:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0103dcd:	0f 85 70 01 00 00    	jne    f0103f43 <debuginfo_eip+0x266>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103dd3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103dda:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103ddd:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0103de0:	c1 f8 02             	sar    $0x2,%eax
f0103de3:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103de9:	48                   	dec    %eax
f0103dea:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103ded:	83 ec 08             	sub    $0x8,%esp
f0103df0:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103df3:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103df6:	56                   	push   %esi
f0103df7:	6a 64                	push   $0x64
f0103df9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103dfc:	e8 b7 fd ff ff       	call   f0103bb8 <stab_binsearch>
	if (lfile == 0)
f0103e01:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103e04:	83 c4 10             	add    $0x10,%esp
		return -1;
f0103e07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0103e0c:	85 d2                	test   %edx,%edx
f0103e0e:	0f 84 3b 01 00 00    	je     f0103f4f <debuginfo_eip+0x272>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103e14:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0103e17:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e1a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103e1d:	83 ec 08             	sub    $0x8,%esp
f0103e20:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103e23:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103e26:	56                   	push   %esi
f0103e27:	6a 24                	push   $0x24
f0103e29:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103e2c:	e8 87 fd ff ff       	call   f0103bb8 <stab_binsearch>

	if (lfun <= rfun) {
f0103e31:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103e34:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0103e37:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103e3a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103e3d:	83 c4 10             	add    $0x10,%esp
f0103e40:	39 c1                	cmp    %eax,%ecx
f0103e42:	7f 21                	jg     f0103e65 <debuginfo_eip+0x188>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103e44:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0103e47:	03 45 d0             	add    -0x30(%ebp),%eax
f0103e4a:	8b 10                	mov    (%eax),%edx
f0103e4c:	89 f9                	mov    %edi,%ecx
f0103e4e:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f0103e51:	39 ca                	cmp    %ecx,%edx
f0103e53:	73 06                	jae    f0103e5b <debuginfo_eip+0x17e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103e55:	03 55 d4             	add    -0x2c(%ebp),%edx
f0103e58:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103e5b:	8b 40 08             	mov    0x8(%eax),%eax
f0103e5e:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103e61:	29 c6                	sub    %eax,%esi
f0103e63:	eb 0f                	jmp    f0103e74 <debuginfo_eip+0x197>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103e65:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103e68:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103e6b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		rline = rfile;
f0103e6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e71:	89 45 c8             	mov    %eax,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103e74:	83 ec 08             	sub    $0x8,%esp
f0103e77:	6a 3a                	push   $0x3a
f0103e79:	ff 73 08             	pushl  0x8(%ebx)
f0103e7c:	e8 b2 08 00 00       	call   f0104733 <strfind>
f0103e81:	2b 43 08             	sub    0x8(%ebx),%eax
f0103e84:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0103e87:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103e8a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    rfun = rline;
f0103e8d:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103e90:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0103e93:	83 c4 08             	add    $0x8,%esp
f0103e96:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103e99:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103e9c:	56                   	push   %esi
f0103e9d:	6a 44                	push   $0x44
f0103e9f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103ea2:	e8 11 fd ff ff       	call   f0103bb8 <stab_binsearch>
    if (lfun <= rfun) {
f0103ea7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103eaa:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0103ead:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0103eb2:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0103eb5:	0f 8f 94 00 00 00    	jg     f0103f4f <debuginfo_eip+0x272>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0103ebb:	6b ca 0c             	imul   $0xc,%edx,%ecx
f0103ebe:	03 4d d0             	add    -0x30(%ebp),%ecx
f0103ec1:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f0103ec5:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103ec8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103ecb:	89 75 cc             	mov    %esi,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103ece:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103ed1:	eb 04                	jmp    f0103ed7 <debuginfo_eip+0x1fa>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103ed3:	4a                   	dec    %edx
f0103ed4:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103ed7:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f0103eda:	7c 19                	jl     f0103ef5 <debuginfo_eip+0x218>
	       && stabs[lline].n_type != N_SOL
f0103edc:	8a 48 fc             	mov    -0x4(%eax),%cl
f0103edf:	80 f9 84             	cmp    $0x84,%cl
f0103ee2:	74 73                	je     f0103f57 <debuginfo_eip+0x27a>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103ee4:	80 f9 64             	cmp    $0x64,%cl
f0103ee7:	75 ea                	jne    f0103ed3 <debuginfo_eip+0x1f6>
f0103ee9:	83 38 00             	cmpl   $0x0,(%eax)
f0103eec:	74 e5                	je     f0103ed3 <debuginfo_eip+0x1f6>
f0103eee:	eb 67                	jmp    f0103f57 <debuginfo_eip+0x27a>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103ef0:	03 45 d4             	add    -0x2c(%ebp),%eax
f0103ef3:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103ef5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103ef8:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103efb:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103f00:	39 ca                	cmp    %ecx,%edx
f0103f02:	7d 4b                	jge    f0103f4f <debuginfo_eip+0x272>
		for (lline = lfun + 1;
f0103f04:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103f07:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103f0a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103f0d:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0103f11:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103f13:	eb 04                	jmp    f0103f19 <debuginfo_eip+0x23c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103f15:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103f18:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103f19:	39 f0                	cmp    %esi,%eax
f0103f1b:	7d 2d                	jge    f0103f4a <debuginfo_eip+0x26d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103f1d:	8a 0a                	mov    (%edx),%cl
f0103f1f:	83 c2 0c             	add    $0xc,%edx
f0103f22:	80 f9 a0             	cmp    $0xa0,%cl
f0103f25:	74 ee                	je     f0103f15 <debuginfo_eip+0x238>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f27:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f2c:	eb 21                	jmp    f0103f4f <debuginfo_eip+0x272>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
f0103f2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f33:	eb 1a                	jmp    f0103f4f <debuginfo_eip+0x272>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uint32_t)stab_end - (uint32_t)stabs, PTE_U) < 0) {
			return -1;
f0103f35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f3a:	eb 13                	jmp    f0103f4f <debuginfo_eip+0x272>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103f3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f41:	eb 0c                	jmp    f0103f4f <debuginfo_eip+0x272>
f0103f43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103f48:	eb 05                	jmp    f0103f4f <debuginfo_eip+0x272>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103f4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103f4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f52:	5b                   	pop    %ebx
f0103f53:	5e                   	pop    %esi
f0103f54:	5f                   	pop    %edi
f0103f55:	c9                   	leave  
f0103f56:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103f57:	6b d2 0c             	imul   $0xc,%edx,%edx
f0103f5a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103f5d:	8b 04 16             	mov    (%esi,%edx,1),%eax
f0103f60:	2b 7d d4             	sub    -0x2c(%ebp),%edi
f0103f63:	39 f8                	cmp    %edi,%eax
f0103f65:	72 89                	jb     f0103ef0 <debuginfo_eip+0x213>
f0103f67:	eb 8c                	jmp    f0103ef5 <debuginfo_eip+0x218>
f0103f69:	00 00                	add    %al,(%eax)
	...

f0103f6c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103f6c:	55                   	push   %ebp
f0103f6d:	89 e5                	mov    %esp,%ebp
f0103f6f:	57                   	push   %edi
f0103f70:	56                   	push   %esi
f0103f71:	53                   	push   %ebx
f0103f72:	83 ec 2c             	sub    $0x2c,%esp
f0103f75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103f78:	89 d6                	mov    %edx,%esi
f0103f7a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f7d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103f80:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103f83:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103f86:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f89:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103f8c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103f8f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103f92:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0103f99:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0103f9c:	72 0c                	jb     f0103faa <printnum+0x3e>
f0103f9e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103fa1:	76 07                	jbe    f0103faa <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103fa3:	4b                   	dec    %ebx
f0103fa4:	85 db                	test   %ebx,%ebx
f0103fa6:	7f 31                	jg     f0103fd9 <printnum+0x6d>
f0103fa8:	eb 3f                	jmp    f0103fe9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103faa:	83 ec 0c             	sub    $0xc,%esp
f0103fad:	57                   	push   %edi
f0103fae:	4b                   	dec    %ebx
f0103faf:	53                   	push   %ebx
f0103fb0:	50                   	push   %eax
f0103fb1:	83 ec 08             	sub    $0x8,%esp
f0103fb4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103fb7:	ff 75 d0             	pushl  -0x30(%ebp)
f0103fba:	ff 75 dc             	pushl  -0x24(%ebp)
f0103fbd:	ff 75 d8             	pushl  -0x28(%ebp)
f0103fc0:	e8 97 09 00 00       	call   f010495c <__udivdi3>
f0103fc5:	83 c4 18             	add    $0x18,%esp
f0103fc8:	52                   	push   %edx
f0103fc9:	50                   	push   %eax
f0103fca:	89 f2                	mov    %esi,%edx
f0103fcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103fcf:	e8 98 ff ff ff       	call   f0103f6c <printnum>
f0103fd4:	83 c4 20             	add    $0x20,%esp
f0103fd7:	eb 10                	jmp    f0103fe9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103fd9:	83 ec 08             	sub    $0x8,%esp
f0103fdc:	56                   	push   %esi
f0103fdd:	57                   	push   %edi
f0103fde:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103fe1:	4b                   	dec    %ebx
f0103fe2:	83 c4 10             	add    $0x10,%esp
f0103fe5:	85 db                	test   %ebx,%ebx
f0103fe7:	7f f0                	jg     f0103fd9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103fe9:	83 ec 08             	sub    $0x8,%esp
f0103fec:	56                   	push   %esi
f0103fed:	83 ec 04             	sub    $0x4,%esp
f0103ff0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103ff3:	ff 75 d0             	pushl  -0x30(%ebp)
f0103ff6:	ff 75 dc             	pushl  -0x24(%ebp)
f0103ff9:	ff 75 d8             	pushl  -0x28(%ebp)
f0103ffc:	e8 77 0a 00 00       	call   f0104a78 <__umoddi3>
f0104001:	83 c4 14             	add    $0x14,%esp
f0104004:	0f be 80 d4 65 10 f0 	movsbl -0xfef9a2c(%eax),%eax
f010400b:	50                   	push   %eax
f010400c:	ff 55 e4             	call   *-0x1c(%ebp)
f010400f:	83 c4 10             	add    $0x10,%esp
}
f0104012:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104015:	5b                   	pop    %ebx
f0104016:	5e                   	pop    %esi
f0104017:	5f                   	pop    %edi
f0104018:	c9                   	leave  
f0104019:	c3                   	ret    

f010401a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010401a:	55                   	push   %ebp
f010401b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010401d:	83 fa 01             	cmp    $0x1,%edx
f0104020:	7e 0e                	jle    f0104030 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104022:	8b 10                	mov    (%eax),%edx
f0104024:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104027:	89 08                	mov    %ecx,(%eax)
f0104029:	8b 02                	mov    (%edx),%eax
f010402b:	8b 52 04             	mov    0x4(%edx),%edx
f010402e:	eb 22                	jmp    f0104052 <getuint+0x38>
	else if (lflag)
f0104030:	85 d2                	test   %edx,%edx
f0104032:	74 10                	je     f0104044 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104034:	8b 10                	mov    (%eax),%edx
f0104036:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104039:	89 08                	mov    %ecx,(%eax)
f010403b:	8b 02                	mov    (%edx),%eax
f010403d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104042:	eb 0e                	jmp    f0104052 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104044:	8b 10                	mov    (%eax),%edx
f0104046:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104049:	89 08                	mov    %ecx,(%eax)
f010404b:	8b 02                	mov    (%edx),%eax
f010404d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104052:	c9                   	leave  
f0104053:	c3                   	ret    

f0104054 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0104054:	55                   	push   %ebp
f0104055:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104057:	83 fa 01             	cmp    $0x1,%edx
f010405a:	7e 0e                	jle    f010406a <getint+0x16>
		return va_arg(*ap, long long);
f010405c:	8b 10                	mov    (%eax),%edx
f010405e:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104061:	89 08                	mov    %ecx,(%eax)
f0104063:	8b 02                	mov    (%edx),%eax
f0104065:	8b 52 04             	mov    0x4(%edx),%edx
f0104068:	eb 1a                	jmp    f0104084 <getint+0x30>
	else if (lflag)
f010406a:	85 d2                	test   %edx,%edx
f010406c:	74 0c                	je     f010407a <getint+0x26>
		return va_arg(*ap, long);
f010406e:	8b 10                	mov    (%eax),%edx
f0104070:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104073:	89 08                	mov    %ecx,(%eax)
f0104075:	8b 02                	mov    (%edx),%eax
f0104077:	99                   	cltd   
f0104078:	eb 0a                	jmp    f0104084 <getint+0x30>
	else
		return va_arg(*ap, int);
f010407a:	8b 10                	mov    (%eax),%edx
f010407c:	8d 4a 04             	lea    0x4(%edx),%ecx
f010407f:	89 08                	mov    %ecx,(%eax)
f0104081:	8b 02                	mov    (%edx),%eax
f0104083:	99                   	cltd   
}
f0104084:	c9                   	leave  
f0104085:	c3                   	ret    

f0104086 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104086:	55                   	push   %ebp
f0104087:	89 e5                	mov    %esp,%ebp
f0104089:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010408c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f010408f:	8b 10                	mov    (%eax),%edx
f0104091:	3b 50 04             	cmp    0x4(%eax),%edx
f0104094:	73 08                	jae    f010409e <sprintputch+0x18>
		*b->buf++ = ch;
f0104096:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104099:	88 0a                	mov    %cl,(%edx)
f010409b:	42                   	inc    %edx
f010409c:	89 10                	mov    %edx,(%eax)
}
f010409e:	c9                   	leave  
f010409f:	c3                   	ret    

f01040a0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01040a0:	55                   	push   %ebp
f01040a1:	89 e5                	mov    %esp,%ebp
f01040a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01040a6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01040a9:	50                   	push   %eax
f01040aa:	ff 75 10             	pushl  0x10(%ebp)
f01040ad:	ff 75 0c             	pushl  0xc(%ebp)
f01040b0:	ff 75 08             	pushl  0x8(%ebp)
f01040b3:	e8 05 00 00 00       	call   f01040bd <vprintfmt>
	va_end(ap);
f01040b8:	83 c4 10             	add    $0x10,%esp
}
f01040bb:	c9                   	leave  
f01040bc:	c3                   	ret    

f01040bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01040bd:	55                   	push   %ebp
f01040be:	89 e5                	mov    %esp,%ebp
f01040c0:	57                   	push   %edi
f01040c1:	56                   	push   %esi
f01040c2:	53                   	push   %ebx
f01040c3:	83 ec 2c             	sub    $0x2c,%esp
f01040c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01040c9:	8b 75 10             	mov    0x10(%ebp),%esi
f01040cc:	eb 13                	jmp    f01040e1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01040ce:	85 c0                	test   %eax,%eax
f01040d0:	0f 84 6d 03 00 00    	je     f0104443 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f01040d6:	83 ec 08             	sub    $0x8,%esp
f01040d9:	57                   	push   %edi
f01040da:	50                   	push   %eax
f01040db:	ff 55 08             	call   *0x8(%ebp)
f01040de:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01040e1:	0f b6 06             	movzbl (%esi),%eax
f01040e4:	46                   	inc    %esi
f01040e5:	83 f8 25             	cmp    $0x25,%eax
f01040e8:	75 e4                	jne    f01040ce <vprintfmt+0x11>
f01040ea:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f01040ee:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01040f5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f01040fc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0104103:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104108:	eb 28                	jmp    f0104132 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010410a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010410c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0104110:	eb 20                	jmp    f0104132 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104112:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104114:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0104118:	eb 18                	jmp    f0104132 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010411a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f010411c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104123:	eb 0d                	jmp    f0104132 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104125:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104128:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010412b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104132:	8a 06                	mov    (%esi),%al
f0104134:	0f b6 d0             	movzbl %al,%edx
f0104137:	8d 5e 01             	lea    0x1(%esi),%ebx
f010413a:	83 e8 23             	sub    $0x23,%eax
f010413d:	3c 55                	cmp    $0x55,%al
f010413f:	0f 87 e0 02 00 00    	ja     f0104425 <vprintfmt+0x368>
f0104145:	0f b6 c0             	movzbl %al,%eax
f0104148:	ff 24 85 60 66 10 f0 	jmp    *-0xfef99a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010414f:	83 ea 30             	sub    $0x30,%edx
f0104152:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0104155:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0104158:	8d 50 d0             	lea    -0x30(%eax),%edx
f010415b:	83 fa 09             	cmp    $0x9,%edx
f010415e:	77 44                	ja     f01041a4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104160:	89 de                	mov    %ebx,%esi
f0104162:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104165:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0104166:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0104169:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f010416d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0104170:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0104173:	83 fb 09             	cmp    $0x9,%ebx
f0104176:	76 ed                	jbe    f0104165 <vprintfmt+0xa8>
f0104178:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010417b:	eb 29                	jmp    f01041a6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010417d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104180:	8d 50 04             	lea    0x4(%eax),%edx
f0104183:	89 55 14             	mov    %edx,0x14(%ebp)
f0104186:	8b 00                	mov    (%eax),%eax
f0104188:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010418b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010418d:	eb 17                	jmp    f01041a6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f010418f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104193:	78 85                	js     f010411a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104195:	89 de                	mov    %ebx,%esi
f0104197:	eb 99                	jmp    f0104132 <vprintfmt+0x75>
f0104199:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010419b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f01041a2:	eb 8e                	jmp    f0104132 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041a4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01041a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01041aa:	79 86                	jns    f0104132 <vprintfmt+0x75>
f01041ac:	e9 74 ff ff ff       	jmp    f0104125 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01041b1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041b2:	89 de                	mov    %ebx,%esi
f01041b4:	e9 79 ff ff ff       	jmp    f0104132 <vprintfmt+0x75>
f01041b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01041bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01041bf:	8d 50 04             	lea    0x4(%eax),%edx
f01041c2:	89 55 14             	mov    %edx,0x14(%ebp)
f01041c5:	83 ec 08             	sub    $0x8,%esp
f01041c8:	57                   	push   %edi
f01041c9:	ff 30                	pushl  (%eax)
f01041cb:	ff 55 08             	call   *0x8(%ebp)
			break;
f01041ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041d1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01041d4:	e9 08 ff ff ff       	jmp    f01040e1 <vprintfmt+0x24>
f01041d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01041dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01041df:	8d 50 04             	lea    0x4(%eax),%edx
f01041e2:	89 55 14             	mov    %edx,0x14(%ebp)
f01041e5:	8b 00                	mov    (%eax),%eax
f01041e7:	85 c0                	test   %eax,%eax
f01041e9:	79 02                	jns    f01041ed <vprintfmt+0x130>
f01041eb:	f7 d8                	neg    %eax
f01041ed:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01041ef:	83 f8 06             	cmp    $0x6,%eax
f01041f2:	7f 0b                	jg     f01041ff <vprintfmt+0x142>
f01041f4:	8b 04 85 b8 67 10 f0 	mov    -0xfef9848(,%eax,4),%eax
f01041fb:	85 c0                	test   %eax,%eax
f01041fd:	75 1a                	jne    f0104219 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f01041ff:	52                   	push   %edx
f0104200:	68 ec 65 10 f0       	push   $0xf01065ec
f0104205:	57                   	push   %edi
f0104206:	ff 75 08             	pushl  0x8(%ebp)
f0104209:	e8 92 fe ff ff       	call   f01040a0 <printfmt>
f010420e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104211:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104214:	e9 c8 fe ff ff       	jmp    f01040e1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0104219:	50                   	push   %eax
f010421a:	68 e5 5d 10 f0       	push   $0xf0105de5
f010421f:	57                   	push   %edi
f0104220:	ff 75 08             	pushl  0x8(%ebp)
f0104223:	e8 78 fe ff ff       	call   f01040a0 <printfmt>
f0104228:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010422b:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010422e:	e9 ae fe ff ff       	jmp    f01040e1 <vprintfmt+0x24>
f0104233:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0104236:	89 de                	mov    %ebx,%esi
f0104238:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010423b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010423e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104241:	8d 50 04             	lea    0x4(%eax),%edx
f0104244:	89 55 14             	mov    %edx,0x14(%ebp)
f0104247:	8b 00                	mov    (%eax),%eax
f0104249:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010424c:	85 c0                	test   %eax,%eax
f010424e:	75 07                	jne    f0104257 <vprintfmt+0x19a>
				p = "(null)";
f0104250:	c7 45 d0 e5 65 10 f0 	movl   $0xf01065e5,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0104257:	85 db                	test   %ebx,%ebx
f0104259:	7e 42                	jle    f010429d <vprintfmt+0x1e0>
f010425b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f010425f:	74 3c                	je     f010429d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104261:	83 ec 08             	sub    $0x8,%esp
f0104264:	51                   	push   %ecx
f0104265:	ff 75 d0             	pushl  -0x30(%ebp)
f0104268:	e8 3f 03 00 00       	call   f01045ac <strnlen>
f010426d:	29 c3                	sub    %eax,%ebx
f010426f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104272:	83 c4 10             	add    $0x10,%esp
f0104275:	85 db                	test   %ebx,%ebx
f0104277:	7e 24                	jle    f010429d <vprintfmt+0x1e0>
					putch(padc, putdat);
f0104279:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f010427d:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0104280:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104283:	83 ec 08             	sub    $0x8,%esp
f0104286:	57                   	push   %edi
f0104287:	53                   	push   %ebx
f0104288:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010428b:	4e                   	dec    %esi
f010428c:	83 c4 10             	add    $0x10,%esp
f010428f:	85 f6                	test   %esi,%esi
f0104291:	7f f0                	jg     f0104283 <vprintfmt+0x1c6>
f0104293:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104296:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010429d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01042a0:	0f be 02             	movsbl (%edx),%eax
f01042a3:	85 c0                	test   %eax,%eax
f01042a5:	75 47                	jne    f01042ee <vprintfmt+0x231>
f01042a7:	eb 37                	jmp    f01042e0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f01042a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01042ad:	74 16                	je     f01042c5 <vprintfmt+0x208>
f01042af:	8d 50 e0             	lea    -0x20(%eax),%edx
f01042b2:	83 fa 5e             	cmp    $0x5e,%edx
f01042b5:	76 0e                	jbe    f01042c5 <vprintfmt+0x208>
					putch('?', putdat);
f01042b7:	83 ec 08             	sub    $0x8,%esp
f01042ba:	57                   	push   %edi
f01042bb:	6a 3f                	push   $0x3f
f01042bd:	ff 55 08             	call   *0x8(%ebp)
f01042c0:	83 c4 10             	add    $0x10,%esp
f01042c3:	eb 0b                	jmp    f01042d0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f01042c5:	83 ec 08             	sub    $0x8,%esp
f01042c8:	57                   	push   %edi
f01042c9:	50                   	push   %eax
f01042ca:	ff 55 08             	call   *0x8(%ebp)
f01042cd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01042d0:	ff 4d e4             	decl   -0x1c(%ebp)
f01042d3:	0f be 03             	movsbl (%ebx),%eax
f01042d6:	85 c0                	test   %eax,%eax
f01042d8:	74 03                	je     f01042dd <vprintfmt+0x220>
f01042da:	43                   	inc    %ebx
f01042db:	eb 1b                	jmp    f01042f8 <vprintfmt+0x23b>
f01042dd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01042e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01042e4:	7f 1e                	jg     f0104304 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01042e6:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01042e9:	e9 f3 fd ff ff       	jmp    f01040e1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01042ee:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01042f1:	43                   	inc    %ebx
f01042f2:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01042f5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01042f8:	85 f6                	test   %esi,%esi
f01042fa:	78 ad                	js     f01042a9 <vprintfmt+0x1ec>
f01042fc:	4e                   	dec    %esi
f01042fd:	79 aa                	jns    f01042a9 <vprintfmt+0x1ec>
f01042ff:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104302:	eb dc                	jmp    f01042e0 <vprintfmt+0x223>
f0104304:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104307:	83 ec 08             	sub    $0x8,%esp
f010430a:	57                   	push   %edi
f010430b:	6a 20                	push   $0x20
f010430d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104310:	4b                   	dec    %ebx
f0104311:	83 c4 10             	add    $0x10,%esp
f0104314:	85 db                	test   %ebx,%ebx
f0104316:	7f ef                	jg     f0104307 <vprintfmt+0x24a>
f0104318:	e9 c4 fd ff ff       	jmp    f01040e1 <vprintfmt+0x24>
f010431d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104320:	89 ca                	mov    %ecx,%edx
f0104322:	8d 45 14             	lea    0x14(%ebp),%eax
f0104325:	e8 2a fd ff ff       	call   f0104054 <getint>
f010432a:	89 c3                	mov    %eax,%ebx
f010432c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f010432e:	85 d2                	test   %edx,%edx
f0104330:	78 0a                	js     f010433c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104332:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104337:	e9 b0 00 00 00       	jmp    f01043ec <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f010433c:	83 ec 08             	sub    $0x8,%esp
f010433f:	57                   	push   %edi
f0104340:	6a 2d                	push   $0x2d
f0104342:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104345:	f7 db                	neg    %ebx
f0104347:	83 d6 00             	adc    $0x0,%esi
f010434a:	f7 de                	neg    %esi
f010434c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010434f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104354:	e9 93 00 00 00       	jmp    f01043ec <vprintfmt+0x32f>
f0104359:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010435c:	89 ca                	mov    %ecx,%edx
f010435e:	8d 45 14             	lea    0x14(%ebp),%eax
f0104361:	e8 b4 fc ff ff       	call   f010401a <getuint>
f0104366:	89 c3                	mov    %eax,%ebx
f0104368:	89 d6                	mov    %edx,%esi
			base = 10;
f010436a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010436f:	eb 7b                	jmp    f01043ec <vprintfmt+0x32f>
f0104371:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0104374:	89 ca                	mov    %ecx,%edx
f0104376:	8d 45 14             	lea    0x14(%ebp),%eax
f0104379:	e8 d6 fc ff ff       	call   f0104054 <getint>
f010437e:	89 c3                	mov    %eax,%ebx
f0104380:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f0104382:	85 d2                	test   %edx,%edx
f0104384:	78 07                	js     f010438d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f0104386:	b8 08 00 00 00       	mov    $0x8,%eax
f010438b:	eb 5f                	jmp    f01043ec <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f010438d:	83 ec 08             	sub    $0x8,%esp
f0104390:	57                   	push   %edi
f0104391:	6a 2d                	push   $0x2d
f0104393:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f0104396:	f7 db                	neg    %ebx
f0104398:	83 d6 00             	adc    $0x0,%esi
f010439b:	f7 de                	neg    %esi
f010439d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f01043a0:	b8 08 00 00 00       	mov    $0x8,%eax
f01043a5:	eb 45                	jmp    f01043ec <vprintfmt+0x32f>
f01043a7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f01043aa:	83 ec 08             	sub    $0x8,%esp
f01043ad:	57                   	push   %edi
f01043ae:	6a 30                	push   $0x30
f01043b0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01043b3:	83 c4 08             	add    $0x8,%esp
f01043b6:	57                   	push   %edi
f01043b7:	6a 78                	push   $0x78
f01043b9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01043bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01043bf:	8d 50 04             	lea    0x4(%eax),%edx
f01043c2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01043c5:	8b 18                	mov    (%eax),%ebx
f01043c7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01043cc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01043cf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01043d4:	eb 16                	jmp    f01043ec <vprintfmt+0x32f>
f01043d6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01043d9:	89 ca                	mov    %ecx,%edx
f01043db:	8d 45 14             	lea    0x14(%ebp),%eax
f01043de:	e8 37 fc ff ff       	call   f010401a <getuint>
f01043e3:	89 c3                	mov    %eax,%ebx
f01043e5:	89 d6                	mov    %edx,%esi
			base = 16;
f01043e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01043ec:	83 ec 0c             	sub    $0xc,%esp
f01043ef:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f01043f3:	52                   	push   %edx
f01043f4:	ff 75 e4             	pushl  -0x1c(%ebp)
f01043f7:	50                   	push   %eax
f01043f8:	56                   	push   %esi
f01043f9:	53                   	push   %ebx
f01043fa:	89 fa                	mov    %edi,%edx
f01043fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01043ff:	e8 68 fb ff ff       	call   f0103f6c <printnum>
			break;
f0104404:	83 c4 20             	add    $0x20,%esp
f0104407:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010440a:	e9 d2 fc ff ff       	jmp    f01040e1 <vprintfmt+0x24>
f010440f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104412:	83 ec 08             	sub    $0x8,%esp
f0104415:	57                   	push   %edi
f0104416:	52                   	push   %edx
f0104417:	ff 55 08             	call   *0x8(%ebp)
			break;
f010441a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010441d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104420:	e9 bc fc ff ff       	jmp    f01040e1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104425:	83 ec 08             	sub    $0x8,%esp
f0104428:	57                   	push   %edi
f0104429:	6a 25                	push   $0x25
f010442b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010442e:	83 c4 10             	add    $0x10,%esp
f0104431:	eb 02                	jmp    f0104435 <vprintfmt+0x378>
f0104433:	89 c6                	mov    %eax,%esi
f0104435:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104438:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010443c:	75 f5                	jne    f0104433 <vprintfmt+0x376>
f010443e:	e9 9e fc ff ff       	jmp    f01040e1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0104443:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104446:	5b                   	pop    %ebx
f0104447:	5e                   	pop    %esi
f0104448:	5f                   	pop    %edi
f0104449:	c9                   	leave  
f010444a:	c3                   	ret    

f010444b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010444b:	55                   	push   %ebp
f010444c:	89 e5                	mov    %esp,%ebp
f010444e:	83 ec 18             	sub    $0x18,%esp
f0104451:	8b 45 08             	mov    0x8(%ebp),%eax
f0104454:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104457:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010445a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010445e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104461:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104468:	85 c0                	test   %eax,%eax
f010446a:	74 26                	je     f0104492 <vsnprintf+0x47>
f010446c:	85 d2                	test   %edx,%edx
f010446e:	7e 29                	jle    f0104499 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104470:	ff 75 14             	pushl  0x14(%ebp)
f0104473:	ff 75 10             	pushl  0x10(%ebp)
f0104476:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104479:	50                   	push   %eax
f010447a:	68 86 40 10 f0       	push   $0xf0104086
f010447f:	e8 39 fc ff ff       	call   f01040bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104484:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104487:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010448a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010448d:	83 c4 10             	add    $0x10,%esp
f0104490:	eb 0c                	jmp    f010449e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104497:	eb 05                	jmp    f010449e <vsnprintf+0x53>
f0104499:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010449e:	c9                   	leave  
f010449f:	c3                   	ret    

f01044a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01044a0:	55                   	push   %ebp
f01044a1:	89 e5                	mov    %esp,%ebp
f01044a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01044a6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01044a9:	50                   	push   %eax
f01044aa:	ff 75 10             	pushl  0x10(%ebp)
f01044ad:	ff 75 0c             	pushl  0xc(%ebp)
f01044b0:	ff 75 08             	pushl  0x8(%ebp)
f01044b3:	e8 93 ff ff ff       	call   f010444b <vsnprintf>
	va_end(ap);

	return rc;
}
f01044b8:	c9                   	leave  
f01044b9:	c3                   	ret    
	...

f01044bc <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01044bc:	55                   	push   %ebp
f01044bd:	89 e5                	mov    %esp,%ebp
f01044bf:	57                   	push   %edi
f01044c0:	56                   	push   %esi
f01044c1:	53                   	push   %ebx
f01044c2:	83 ec 0c             	sub    $0xc,%esp
f01044c5:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01044c8:	85 c0                	test   %eax,%eax
f01044ca:	74 11                	je     f01044dd <readline+0x21>
		cprintf("%s", prompt);
f01044cc:	83 ec 08             	sub    $0x8,%esp
f01044cf:	50                   	push   %eax
f01044d0:	68 e5 5d 10 f0       	push   $0xf0105de5
f01044d5:	e8 53 f0 ff ff       	call   f010352d <cprintf>
f01044da:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01044dd:	83 ec 0c             	sub    $0xc,%esp
f01044e0:	6a 00                	push   $0x0
f01044e2:	e8 28 c1 ff ff       	call   f010060f <iscons>
f01044e7:	89 c7                	mov    %eax,%edi
f01044e9:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01044ec:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01044f1:	e8 08 c1 ff ff       	call   f01005fe <getchar>
f01044f6:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01044f8:	85 c0                	test   %eax,%eax
f01044fa:	79 18                	jns    f0104514 <readline+0x58>
			cprintf("read error: %e\n", c);
f01044fc:	83 ec 08             	sub    $0x8,%esp
f01044ff:	50                   	push   %eax
f0104500:	68 d4 67 10 f0       	push   $0xf01067d4
f0104505:	e8 23 f0 ff ff       	call   f010352d <cprintf>
			return NULL;
f010450a:	83 c4 10             	add    $0x10,%esp
f010450d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104512:	eb 6f                	jmp    f0104583 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104514:	83 f8 08             	cmp    $0x8,%eax
f0104517:	74 05                	je     f010451e <readline+0x62>
f0104519:	83 f8 7f             	cmp    $0x7f,%eax
f010451c:	75 18                	jne    f0104536 <readline+0x7a>
f010451e:	85 f6                	test   %esi,%esi
f0104520:	7e 14                	jle    f0104536 <readline+0x7a>
			if (echoing)
f0104522:	85 ff                	test   %edi,%edi
f0104524:	74 0d                	je     f0104533 <readline+0x77>
				cputchar('\b');
f0104526:	83 ec 0c             	sub    $0xc,%esp
f0104529:	6a 08                	push   $0x8
f010452b:	e8 be c0 ff ff       	call   f01005ee <cputchar>
f0104530:	83 c4 10             	add    $0x10,%esp
			i--;
f0104533:	4e                   	dec    %esi
f0104534:	eb bb                	jmp    f01044f1 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104536:	83 fb 1f             	cmp    $0x1f,%ebx
f0104539:	7e 21                	jle    f010455c <readline+0xa0>
f010453b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104541:	7f 19                	jg     f010455c <readline+0xa0>
			if (echoing)
f0104543:	85 ff                	test   %edi,%edi
f0104545:	74 0c                	je     f0104553 <readline+0x97>
				cputchar(c);
f0104547:	83 ec 0c             	sub    $0xc,%esp
f010454a:	53                   	push   %ebx
f010454b:	e8 9e c0 ff ff       	call   f01005ee <cputchar>
f0104550:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104553:	88 9e 40 0d 1e f0    	mov    %bl,-0xfe1f2c0(%esi)
f0104559:	46                   	inc    %esi
f010455a:	eb 95                	jmp    f01044f1 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010455c:	83 fb 0a             	cmp    $0xa,%ebx
f010455f:	74 05                	je     f0104566 <readline+0xaa>
f0104561:	83 fb 0d             	cmp    $0xd,%ebx
f0104564:	75 8b                	jne    f01044f1 <readline+0x35>
			if (echoing)
f0104566:	85 ff                	test   %edi,%edi
f0104568:	74 0d                	je     f0104577 <readline+0xbb>
				cputchar('\n');
f010456a:	83 ec 0c             	sub    $0xc,%esp
f010456d:	6a 0a                	push   $0xa
f010456f:	e8 7a c0 ff ff       	call   f01005ee <cputchar>
f0104574:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104577:	c6 86 40 0d 1e f0 00 	movb   $0x0,-0xfe1f2c0(%esi)
			return buf;
f010457e:	b8 40 0d 1e f0       	mov    $0xf01e0d40,%eax
		}
	}
}
f0104583:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104586:	5b                   	pop    %ebx
f0104587:	5e                   	pop    %esi
f0104588:	5f                   	pop    %edi
f0104589:	c9                   	leave  
f010458a:	c3                   	ret    
	...

f010458c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010458c:	55                   	push   %ebp
f010458d:	89 e5                	mov    %esp,%ebp
f010458f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104592:	80 3a 00             	cmpb   $0x0,(%edx)
f0104595:	74 0e                	je     f01045a5 <strlen+0x19>
f0104597:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f010459c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010459d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01045a1:	75 f9                	jne    f010459c <strlen+0x10>
f01045a3:	eb 05                	jmp    f01045aa <strlen+0x1e>
f01045a5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01045aa:	c9                   	leave  
f01045ab:	c3                   	ret    

f01045ac <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01045ac:	55                   	push   %ebp
f01045ad:	89 e5                	mov    %esp,%ebp
f01045af:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01045b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01045b5:	85 d2                	test   %edx,%edx
f01045b7:	74 17                	je     f01045d0 <strnlen+0x24>
f01045b9:	80 39 00             	cmpb   $0x0,(%ecx)
f01045bc:	74 19                	je     f01045d7 <strnlen+0x2b>
f01045be:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01045c3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01045c4:	39 d0                	cmp    %edx,%eax
f01045c6:	74 14                	je     f01045dc <strnlen+0x30>
f01045c8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01045cc:	75 f5                	jne    f01045c3 <strnlen+0x17>
f01045ce:	eb 0c                	jmp    f01045dc <strnlen+0x30>
f01045d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01045d5:	eb 05                	jmp    f01045dc <strnlen+0x30>
f01045d7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01045dc:	c9                   	leave  
f01045dd:	c3                   	ret    

f01045de <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01045de:	55                   	push   %ebp
f01045df:	89 e5                	mov    %esp,%ebp
f01045e1:	53                   	push   %ebx
f01045e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01045e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01045e8:	ba 00 00 00 00       	mov    $0x0,%edx
f01045ed:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01045f0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01045f3:	42                   	inc    %edx
f01045f4:	84 c9                	test   %cl,%cl
f01045f6:	75 f5                	jne    f01045ed <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01045f8:	5b                   	pop    %ebx
f01045f9:	c9                   	leave  
f01045fa:	c3                   	ret    

f01045fb <strcat>:

char *
strcat(char *dst, const char *src)
{
f01045fb:	55                   	push   %ebp
f01045fc:	89 e5                	mov    %esp,%ebp
f01045fe:	53                   	push   %ebx
f01045ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104602:	53                   	push   %ebx
f0104603:	e8 84 ff ff ff       	call   f010458c <strlen>
f0104608:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010460b:	ff 75 0c             	pushl  0xc(%ebp)
f010460e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0104611:	50                   	push   %eax
f0104612:	e8 c7 ff ff ff       	call   f01045de <strcpy>
	return dst;
}
f0104617:	89 d8                	mov    %ebx,%eax
f0104619:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010461c:	c9                   	leave  
f010461d:	c3                   	ret    

f010461e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010461e:	55                   	push   %ebp
f010461f:	89 e5                	mov    %esp,%ebp
f0104621:	56                   	push   %esi
f0104622:	53                   	push   %ebx
f0104623:	8b 45 08             	mov    0x8(%ebp),%eax
f0104626:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104629:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010462c:	85 f6                	test   %esi,%esi
f010462e:	74 15                	je     f0104645 <strncpy+0x27>
f0104630:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0104635:	8a 1a                	mov    (%edx),%bl
f0104637:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010463a:	80 3a 01             	cmpb   $0x1,(%edx)
f010463d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104640:	41                   	inc    %ecx
f0104641:	39 ce                	cmp    %ecx,%esi
f0104643:	77 f0                	ja     f0104635 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104645:	5b                   	pop    %ebx
f0104646:	5e                   	pop    %esi
f0104647:	c9                   	leave  
f0104648:	c3                   	ret    

f0104649 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104649:	55                   	push   %ebp
f010464a:	89 e5                	mov    %esp,%ebp
f010464c:	57                   	push   %edi
f010464d:	56                   	push   %esi
f010464e:	53                   	push   %ebx
f010464f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104652:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104655:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104658:	85 f6                	test   %esi,%esi
f010465a:	74 32                	je     f010468e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f010465c:	83 fe 01             	cmp    $0x1,%esi
f010465f:	74 22                	je     f0104683 <strlcpy+0x3a>
f0104661:	8a 0b                	mov    (%ebx),%cl
f0104663:	84 c9                	test   %cl,%cl
f0104665:	74 20                	je     f0104687 <strlcpy+0x3e>
f0104667:	89 f8                	mov    %edi,%eax
f0104669:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010466e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104671:	88 08                	mov    %cl,(%eax)
f0104673:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104674:	39 f2                	cmp    %esi,%edx
f0104676:	74 11                	je     f0104689 <strlcpy+0x40>
f0104678:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f010467c:	42                   	inc    %edx
f010467d:	84 c9                	test   %cl,%cl
f010467f:	75 f0                	jne    f0104671 <strlcpy+0x28>
f0104681:	eb 06                	jmp    f0104689 <strlcpy+0x40>
f0104683:	89 f8                	mov    %edi,%eax
f0104685:	eb 02                	jmp    f0104689 <strlcpy+0x40>
f0104687:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104689:	c6 00 00             	movb   $0x0,(%eax)
f010468c:	eb 02                	jmp    f0104690 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010468e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0104690:	29 f8                	sub    %edi,%eax
}
f0104692:	5b                   	pop    %ebx
f0104693:	5e                   	pop    %esi
f0104694:	5f                   	pop    %edi
f0104695:	c9                   	leave  
f0104696:	c3                   	ret    

f0104697 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104697:	55                   	push   %ebp
f0104698:	89 e5                	mov    %esp,%ebp
f010469a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010469d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01046a0:	8a 01                	mov    (%ecx),%al
f01046a2:	84 c0                	test   %al,%al
f01046a4:	74 10                	je     f01046b6 <strcmp+0x1f>
f01046a6:	3a 02                	cmp    (%edx),%al
f01046a8:	75 0c                	jne    f01046b6 <strcmp+0x1f>
		p++, q++;
f01046aa:	41                   	inc    %ecx
f01046ab:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01046ac:	8a 01                	mov    (%ecx),%al
f01046ae:	84 c0                	test   %al,%al
f01046b0:	74 04                	je     f01046b6 <strcmp+0x1f>
f01046b2:	3a 02                	cmp    (%edx),%al
f01046b4:	74 f4                	je     f01046aa <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01046b6:	0f b6 c0             	movzbl %al,%eax
f01046b9:	0f b6 12             	movzbl (%edx),%edx
f01046bc:	29 d0                	sub    %edx,%eax
}
f01046be:	c9                   	leave  
f01046bf:	c3                   	ret    

f01046c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01046c0:	55                   	push   %ebp
f01046c1:	89 e5                	mov    %esp,%ebp
f01046c3:	53                   	push   %ebx
f01046c4:	8b 55 08             	mov    0x8(%ebp),%edx
f01046c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01046ca:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01046cd:	85 c0                	test   %eax,%eax
f01046cf:	74 1b                	je     f01046ec <strncmp+0x2c>
f01046d1:	8a 1a                	mov    (%edx),%bl
f01046d3:	84 db                	test   %bl,%bl
f01046d5:	74 24                	je     f01046fb <strncmp+0x3b>
f01046d7:	3a 19                	cmp    (%ecx),%bl
f01046d9:	75 20                	jne    f01046fb <strncmp+0x3b>
f01046db:	48                   	dec    %eax
f01046dc:	74 15                	je     f01046f3 <strncmp+0x33>
		n--, p++, q++;
f01046de:	42                   	inc    %edx
f01046df:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01046e0:	8a 1a                	mov    (%edx),%bl
f01046e2:	84 db                	test   %bl,%bl
f01046e4:	74 15                	je     f01046fb <strncmp+0x3b>
f01046e6:	3a 19                	cmp    (%ecx),%bl
f01046e8:	74 f1                	je     f01046db <strncmp+0x1b>
f01046ea:	eb 0f                	jmp    f01046fb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01046ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01046f1:	eb 05                	jmp    f01046f8 <strncmp+0x38>
f01046f3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01046f8:	5b                   	pop    %ebx
f01046f9:	c9                   	leave  
f01046fa:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01046fb:	0f b6 02             	movzbl (%edx),%eax
f01046fe:	0f b6 11             	movzbl (%ecx),%edx
f0104701:	29 d0                	sub    %edx,%eax
f0104703:	eb f3                	jmp    f01046f8 <strncmp+0x38>

f0104705 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104705:	55                   	push   %ebp
f0104706:	89 e5                	mov    %esp,%ebp
f0104708:	8b 45 08             	mov    0x8(%ebp),%eax
f010470b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010470e:	8a 10                	mov    (%eax),%dl
f0104710:	84 d2                	test   %dl,%dl
f0104712:	74 18                	je     f010472c <strchr+0x27>
		if (*s == c)
f0104714:	38 ca                	cmp    %cl,%dl
f0104716:	75 06                	jne    f010471e <strchr+0x19>
f0104718:	eb 17                	jmp    f0104731 <strchr+0x2c>
f010471a:	38 ca                	cmp    %cl,%dl
f010471c:	74 13                	je     f0104731 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010471e:	40                   	inc    %eax
f010471f:	8a 10                	mov    (%eax),%dl
f0104721:	84 d2                	test   %dl,%dl
f0104723:	75 f5                	jne    f010471a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0104725:	b8 00 00 00 00       	mov    $0x0,%eax
f010472a:	eb 05                	jmp    f0104731 <strchr+0x2c>
f010472c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104731:	c9                   	leave  
f0104732:	c3                   	ret    

f0104733 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104733:	55                   	push   %ebp
f0104734:	89 e5                	mov    %esp,%ebp
f0104736:	8b 45 08             	mov    0x8(%ebp),%eax
f0104739:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010473c:	8a 10                	mov    (%eax),%dl
f010473e:	84 d2                	test   %dl,%dl
f0104740:	74 11                	je     f0104753 <strfind+0x20>
		if (*s == c)
f0104742:	38 ca                	cmp    %cl,%dl
f0104744:	75 06                	jne    f010474c <strfind+0x19>
f0104746:	eb 0b                	jmp    f0104753 <strfind+0x20>
f0104748:	38 ca                	cmp    %cl,%dl
f010474a:	74 07                	je     f0104753 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010474c:	40                   	inc    %eax
f010474d:	8a 10                	mov    (%eax),%dl
f010474f:	84 d2                	test   %dl,%dl
f0104751:	75 f5                	jne    f0104748 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f0104753:	c9                   	leave  
f0104754:	c3                   	ret    

f0104755 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104755:	55                   	push   %ebp
f0104756:	89 e5                	mov    %esp,%ebp
f0104758:	57                   	push   %edi
f0104759:	56                   	push   %esi
f010475a:	53                   	push   %ebx
f010475b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010475e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104761:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104764:	85 c9                	test   %ecx,%ecx
f0104766:	74 30                	je     f0104798 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104768:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010476e:	75 25                	jne    f0104795 <memset+0x40>
f0104770:	f6 c1 03             	test   $0x3,%cl
f0104773:	75 20                	jne    f0104795 <memset+0x40>
		c &= 0xFF;
f0104775:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104778:	89 d3                	mov    %edx,%ebx
f010477a:	c1 e3 08             	shl    $0x8,%ebx
f010477d:	89 d6                	mov    %edx,%esi
f010477f:	c1 e6 18             	shl    $0x18,%esi
f0104782:	89 d0                	mov    %edx,%eax
f0104784:	c1 e0 10             	shl    $0x10,%eax
f0104787:	09 f0                	or     %esi,%eax
f0104789:	09 d0                	or     %edx,%eax
f010478b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010478d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104790:	fc                   	cld    
f0104791:	f3 ab                	rep stos %eax,%es:(%edi)
f0104793:	eb 03                	jmp    f0104798 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104795:	fc                   	cld    
f0104796:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104798:	89 f8                	mov    %edi,%eax
f010479a:	5b                   	pop    %ebx
f010479b:	5e                   	pop    %esi
f010479c:	5f                   	pop    %edi
f010479d:	c9                   	leave  
f010479e:	c3                   	ret    

f010479f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010479f:	55                   	push   %ebp
f01047a0:	89 e5                	mov    %esp,%ebp
f01047a2:	57                   	push   %edi
f01047a3:	56                   	push   %esi
f01047a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01047a7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01047aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01047ad:	39 c6                	cmp    %eax,%esi
f01047af:	73 34                	jae    f01047e5 <memmove+0x46>
f01047b1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01047b4:	39 d0                	cmp    %edx,%eax
f01047b6:	73 2d                	jae    f01047e5 <memmove+0x46>
		s += n;
		d += n;
f01047b8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01047bb:	f6 c2 03             	test   $0x3,%dl
f01047be:	75 1b                	jne    f01047db <memmove+0x3c>
f01047c0:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01047c6:	75 13                	jne    f01047db <memmove+0x3c>
f01047c8:	f6 c1 03             	test   $0x3,%cl
f01047cb:	75 0e                	jne    f01047db <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01047cd:	83 ef 04             	sub    $0x4,%edi
f01047d0:	8d 72 fc             	lea    -0x4(%edx),%esi
f01047d3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01047d6:	fd                   	std    
f01047d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01047d9:	eb 07                	jmp    f01047e2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01047db:	4f                   	dec    %edi
f01047dc:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01047df:	fd                   	std    
f01047e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01047e2:	fc                   	cld    
f01047e3:	eb 20                	jmp    f0104805 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01047e5:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01047eb:	75 13                	jne    f0104800 <memmove+0x61>
f01047ed:	a8 03                	test   $0x3,%al
f01047ef:	75 0f                	jne    f0104800 <memmove+0x61>
f01047f1:	f6 c1 03             	test   $0x3,%cl
f01047f4:	75 0a                	jne    f0104800 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01047f6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01047f9:	89 c7                	mov    %eax,%edi
f01047fb:	fc                   	cld    
f01047fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01047fe:	eb 05                	jmp    f0104805 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104800:	89 c7                	mov    %eax,%edi
f0104802:	fc                   	cld    
f0104803:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104805:	5e                   	pop    %esi
f0104806:	5f                   	pop    %edi
f0104807:	c9                   	leave  
f0104808:	c3                   	ret    

f0104809 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104809:	55                   	push   %ebp
f010480a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010480c:	ff 75 10             	pushl  0x10(%ebp)
f010480f:	ff 75 0c             	pushl  0xc(%ebp)
f0104812:	ff 75 08             	pushl  0x8(%ebp)
f0104815:	e8 85 ff ff ff       	call   f010479f <memmove>
}
f010481a:	c9                   	leave  
f010481b:	c3                   	ret    

f010481c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010481c:	55                   	push   %ebp
f010481d:	89 e5                	mov    %esp,%ebp
f010481f:	57                   	push   %edi
f0104820:	56                   	push   %esi
f0104821:	53                   	push   %ebx
f0104822:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104825:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104828:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010482b:	85 ff                	test   %edi,%edi
f010482d:	74 32                	je     f0104861 <memcmp+0x45>
		if (*s1 != *s2)
f010482f:	8a 03                	mov    (%ebx),%al
f0104831:	8a 0e                	mov    (%esi),%cl
f0104833:	38 c8                	cmp    %cl,%al
f0104835:	74 19                	je     f0104850 <memcmp+0x34>
f0104837:	eb 0d                	jmp    f0104846 <memcmp+0x2a>
f0104839:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f010483d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0104841:	42                   	inc    %edx
f0104842:	38 c8                	cmp    %cl,%al
f0104844:	74 10                	je     f0104856 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f0104846:	0f b6 c0             	movzbl %al,%eax
f0104849:	0f b6 c9             	movzbl %cl,%ecx
f010484c:	29 c8                	sub    %ecx,%eax
f010484e:	eb 16                	jmp    f0104866 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104850:	4f                   	dec    %edi
f0104851:	ba 00 00 00 00       	mov    $0x0,%edx
f0104856:	39 fa                	cmp    %edi,%edx
f0104858:	75 df                	jne    f0104839 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010485a:	b8 00 00 00 00       	mov    $0x0,%eax
f010485f:	eb 05                	jmp    f0104866 <memcmp+0x4a>
f0104861:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104866:	5b                   	pop    %ebx
f0104867:	5e                   	pop    %esi
f0104868:	5f                   	pop    %edi
f0104869:	c9                   	leave  
f010486a:	c3                   	ret    

f010486b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010486b:	55                   	push   %ebp
f010486c:	89 e5                	mov    %esp,%ebp
f010486e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104871:	89 c2                	mov    %eax,%edx
f0104873:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104876:	39 d0                	cmp    %edx,%eax
f0104878:	73 12                	jae    f010488c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f010487a:	8a 4d 0c             	mov    0xc(%ebp),%cl
f010487d:	38 08                	cmp    %cl,(%eax)
f010487f:	75 06                	jne    f0104887 <memfind+0x1c>
f0104881:	eb 09                	jmp    f010488c <memfind+0x21>
f0104883:	38 08                	cmp    %cl,(%eax)
f0104885:	74 05                	je     f010488c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104887:	40                   	inc    %eax
f0104888:	39 c2                	cmp    %eax,%edx
f010488a:	77 f7                	ja     f0104883 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010488c:	c9                   	leave  
f010488d:	c3                   	ret    

f010488e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010488e:	55                   	push   %ebp
f010488f:	89 e5                	mov    %esp,%ebp
f0104891:	57                   	push   %edi
f0104892:	56                   	push   %esi
f0104893:	53                   	push   %ebx
f0104894:	8b 55 08             	mov    0x8(%ebp),%edx
f0104897:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010489a:	eb 01                	jmp    f010489d <strtol+0xf>
		s++;
f010489c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010489d:	8a 02                	mov    (%edx),%al
f010489f:	3c 20                	cmp    $0x20,%al
f01048a1:	74 f9                	je     f010489c <strtol+0xe>
f01048a3:	3c 09                	cmp    $0x9,%al
f01048a5:	74 f5                	je     f010489c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01048a7:	3c 2b                	cmp    $0x2b,%al
f01048a9:	75 08                	jne    f01048b3 <strtol+0x25>
		s++;
f01048ab:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01048ac:	bf 00 00 00 00       	mov    $0x0,%edi
f01048b1:	eb 13                	jmp    f01048c6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01048b3:	3c 2d                	cmp    $0x2d,%al
f01048b5:	75 0a                	jne    f01048c1 <strtol+0x33>
		s++, neg = 1;
f01048b7:	8d 52 01             	lea    0x1(%edx),%edx
f01048ba:	bf 01 00 00 00       	mov    $0x1,%edi
f01048bf:	eb 05                	jmp    f01048c6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01048c1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01048c6:	85 db                	test   %ebx,%ebx
f01048c8:	74 05                	je     f01048cf <strtol+0x41>
f01048ca:	83 fb 10             	cmp    $0x10,%ebx
f01048cd:	75 28                	jne    f01048f7 <strtol+0x69>
f01048cf:	8a 02                	mov    (%edx),%al
f01048d1:	3c 30                	cmp    $0x30,%al
f01048d3:	75 10                	jne    f01048e5 <strtol+0x57>
f01048d5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01048d9:	75 0a                	jne    f01048e5 <strtol+0x57>
		s += 2, base = 16;
f01048db:	83 c2 02             	add    $0x2,%edx
f01048de:	bb 10 00 00 00       	mov    $0x10,%ebx
f01048e3:	eb 12                	jmp    f01048f7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01048e5:	85 db                	test   %ebx,%ebx
f01048e7:	75 0e                	jne    f01048f7 <strtol+0x69>
f01048e9:	3c 30                	cmp    $0x30,%al
f01048eb:	75 05                	jne    f01048f2 <strtol+0x64>
		s++, base = 8;
f01048ed:	42                   	inc    %edx
f01048ee:	b3 08                	mov    $0x8,%bl
f01048f0:	eb 05                	jmp    f01048f7 <strtol+0x69>
	else if (base == 0)
		base = 10;
f01048f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01048f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01048fc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01048fe:	8a 0a                	mov    (%edx),%cl
f0104900:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104903:	80 fb 09             	cmp    $0x9,%bl
f0104906:	77 08                	ja     f0104910 <strtol+0x82>
			dig = *s - '0';
f0104908:	0f be c9             	movsbl %cl,%ecx
f010490b:	83 e9 30             	sub    $0x30,%ecx
f010490e:	eb 1e                	jmp    f010492e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0104910:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0104913:	80 fb 19             	cmp    $0x19,%bl
f0104916:	77 08                	ja     f0104920 <strtol+0x92>
			dig = *s - 'a' + 10;
f0104918:	0f be c9             	movsbl %cl,%ecx
f010491b:	83 e9 57             	sub    $0x57,%ecx
f010491e:	eb 0e                	jmp    f010492e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0104920:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0104923:	80 fb 19             	cmp    $0x19,%bl
f0104926:	77 13                	ja     f010493b <strtol+0xad>
			dig = *s - 'A' + 10;
f0104928:	0f be c9             	movsbl %cl,%ecx
f010492b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010492e:	39 f1                	cmp    %esi,%ecx
f0104930:	7d 0d                	jge    f010493f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f0104932:	42                   	inc    %edx
f0104933:	0f af c6             	imul   %esi,%eax
f0104936:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0104939:	eb c3                	jmp    f01048fe <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010493b:	89 c1                	mov    %eax,%ecx
f010493d:	eb 02                	jmp    f0104941 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010493f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104941:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104945:	74 05                	je     f010494c <strtol+0xbe>
		*endptr = (char *) s;
f0104947:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010494a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f010494c:	85 ff                	test   %edi,%edi
f010494e:	74 04                	je     f0104954 <strtol+0xc6>
f0104950:	89 c8                	mov    %ecx,%eax
f0104952:	f7 d8                	neg    %eax
}
f0104954:	5b                   	pop    %ebx
f0104955:	5e                   	pop    %esi
f0104956:	5f                   	pop    %edi
f0104957:	c9                   	leave  
f0104958:	c3                   	ret    
f0104959:	00 00                	add    %al,(%eax)
	...

f010495c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f010495c:	55                   	push   %ebp
f010495d:	89 e5                	mov    %esp,%ebp
f010495f:	57                   	push   %edi
f0104960:	56                   	push   %esi
f0104961:	83 ec 10             	sub    $0x10,%esp
f0104964:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104967:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010496a:	89 7d f0             	mov    %edi,-0x10(%ebp)
f010496d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0104970:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0104973:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0104976:	85 c0                	test   %eax,%eax
f0104978:	75 2e                	jne    f01049a8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f010497a:	39 f1                	cmp    %esi,%ecx
f010497c:	77 5a                	ja     f01049d8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f010497e:	85 c9                	test   %ecx,%ecx
f0104980:	75 0b                	jne    f010498d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0104982:	b8 01 00 00 00       	mov    $0x1,%eax
f0104987:	31 d2                	xor    %edx,%edx
f0104989:	f7 f1                	div    %ecx
f010498b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010498d:	31 d2                	xor    %edx,%edx
f010498f:	89 f0                	mov    %esi,%eax
f0104991:	f7 f1                	div    %ecx
f0104993:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104995:	89 f8                	mov    %edi,%eax
f0104997:	f7 f1                	div    %ecx
f0104999:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010499b:	89 f8                	mov    %edi,%eax
f010499d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010499f:	83 c4 10             	add    $0x10,%esp
f01049a2:	5e                   	pop    %esi
f01049a3:	5f                   	pop    %edi
f01049a4:	c9                   	leave  
f01049a5:	c3                   	ret    
f01049a6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01049a8:	39 f0                	cmp    %esi,%eax
f01049aa:	77 1c                	ja     f01049c8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01049ac:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f01049af:	83 f7 1f             	xor    $0x1f,%edi
f01049b2:	75 3c                	jne    f01049f0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01049b4:	39 f0                	cmp    %esi,%eax
f01049b6:	0f 82 90 00 00 00    	jb     f0104a4c <__udivdi3+0xf0>
f01049bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01049bf:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f01049c2:	0f 86 84 00 00 00    	jbe    f0104a4c <__udivdi3+0xf0>
f01049c8:	31 f6                	xor    %esi,%esi
f01049ca:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01049cc:	89 f8                	mov    %edi,%eax
f01049ce:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01049d0:	83 c4 10             	add    $0x10,%esp
f01049d3:	5e                   	pop    %esi
f01049d4:	5f                   	pop    %edi
f01049d5:	c9                   	leave  
f01049d6:	c3                   	ret    
f01049d7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01049d8:	89 f2                	mov    %esi,%edx
f01049da:	89 f8                	mov    %edi,%eax
f01049dc:	f7 f1                	div    %ecx
f01049de:	89 c7                	mov    %eax,%edi
f01049e0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01049e2:	89 f8                	mov    %edi,%eax
f01049e4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01049e6:	83 c4 10             	add    $0x10,%esp
f01049e9:	5e                   	pop    %esi
f01049ea:	5f                   	pop    %edi
f01049eb:	c9                   	leave  
f01049ec:	c3                   	ret    
f01049ed:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01049f0:	89 f9                	mov    %edi,%ecx
f01049f2:	d3 e0                	shl    %cl,%eax
f01049f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01049f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01049fc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f01049fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a01:	88 c1                	mov    %al,%cl
f0104a03:	d3 ea                	shr    %cl,%edx
f0104a05:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104a08:	09 ca                	or     %ecx,%edx
f0104a0a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0104a0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a10:	89 f9                	mov    %edi,%ecx
f0104a12:	d3 e2                	shl    %cl,%edx
f0104a14:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0104a17:	89 f2                	mov    %esi,%edx
f0104a19:	88 c1                	mov    %al,%cl
f0104a1b:	d3 ea                	shr    %cl,%edx
f0104a1d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0104a20:	89 f2                	mov    %esi,%edx
f0104a22:	89 f9                	mov    %edi,%ecx
f0104a24:	d3 e2                	shl    %cl,%edx
f0104a26:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0104a29:	88 c1                	mov    %al,%cl
f0104a2b:	d3 ee                	shr    %cl,%esi
f0104a2d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0104a2f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104a32:	89 f0                	mov    %esi,%eax
f0104a34:	89 ca                	mov    %ecx,%edx
f0104a36:	f7 75 ec             	divl   -0x14(%ebp)
f0104a39:	89 d1                	mov    %edx,%ecx
f0104a3b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0104a3d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104a40:	39 d1                	cmp    %edx,%ecx
f0104a42:	72 28                	jb     f0104a6c <__udivdi3+0x110>
f0104a44:	74 1a                	je     f0104a60 <__udivdi3+0x104>
f0104a46:	89 f7                	mov    %esi,%edi
f0104a48:	31 f6                	xor    %esi,%esi
f0104a4a:	eb 80                	jmp    f01049cc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0104a4c:	31 f6                	xor    %esi,%esi
f0104a4e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104a53:	89 f8                	mov    %edi,%eax
f0104a55:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104a57:	83 c4 10             	add    $0x10,%esp
f0104a5a:	5e                   	pop    %esi
f0104a5b:	5f                   	pop    %edi
f0104a5c:	c9                   	leave  
f0104a5d:	c3                   	ret    
f0104a5e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0104a60:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104a63:	89 f9                	mov    %edi,%ecx
f0104a65:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104a67:	39 c2                	cmp    %eax,%edx
f0104a69:	73 db                	jae    f0104a46 <__udivdi3+0xea>
f0104a6b:	90                   	nop
		{
		  q0--;
f0104a6c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104a6f:	31 f6                	xor    %esi,%esi
f0104a71:	e9 56 ff ff ff       	jmp    f01049cc <__udivdi3+0x70>
	...

f0104a78 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0104a78:	55                   	push   %ebp
f0104a79:	89 e5                	mov    %esp,%ebp
f0104a7b:	57                   	push   %edi
f0104a7c:	56                   	push   %esi
f0104a7d:	83 ec 20             	sub    $0x20,%esp
f0104a80:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a83:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0104a86:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0104a89:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0104a8c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0104a8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0104a92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0104a95:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0104a97:	85 ff                	test   %edi,%edi
f0104a99:	75 15                	jne    f0104ab0 <__umoddi3+0x38>
    {
      if (d0 > n1)
f0104a9b:	39 f1                	cmp    %esi,%ecx
f0104a9d:	0f 86 99 00 00 00    	jbe    f0104b3c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104aa3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0104aa5:	89 d0                	mov    %edx,%eax
f0104aa7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104aa9:	83 c4 20             	add    $0x20,%esp
f0104aac:	5e                   	pop    %esi
f0104aad:	5f                   	pop    %edi
f0104aae:	c9                   	leave  
f0104aaf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0104ab0:	39 f7                	cmp    %esi,%edi
f0104ab2:	0f 87 a4 00 00 00    	ja     f0104b5c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0104ab8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0104abb:	83 f0 1f             	xor    $0x1f,%eax
f0104abe:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ac1:	0f 84 a1 00 00 00    	je     f0104b68 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0104ac7:	89 f8                	mov    %edi,%eax
f0104ac9:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104acc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0104ace:	bf 20 00 00 00       	mov    $0x20,%edi
f0104ad3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0104ad6:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104ad9:	89 f9                	mov    %edi,%ecx
f0104adb:	d3 ea                	shr    %cl,%edx
f0104add:	09 c2                	or     %eax,%edx
f0104adf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0104ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ae5:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104ae8:	d3 e0                	shl    %cl,%eax
f0104aea:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0104aed:	89 f2                	mov    %esi,%edx
f0104aef:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0104af1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104af4:	d3 e0                	shl    %cl,%eax
f0104af6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0104af9:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104afc:	89 f9                	mov    %edi,%ecx
f0104afe:	d3 e8                	shr    %cl,%eax
f0104b00:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0104b02:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0104b04:	89 f2                	mov    %esi,%edx
f0104b06:	f7 75 f0             	divl   -0x10(%ebp)
f0104b09:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0104b0b:	f7 65 f4             	mull   -0xc(%ebp)
f0104b0e:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0104b11:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104b13:	39 d6                	cmp    %edx,%esi
f0104b15:	72 71                	jb     f0104b88 <__umoddi3+0x110>
f0104b17:	74 7f                	je     f0104b98 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0104b19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b1c:	29 c8                	sub    %ecx,%eax
f0104b1e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0104b20:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104b23:	d3 e8                	shr    %cl,%eax
f0104b25:	89 f2                	mov    %esi,%edx
f0104b27:	89 f9                	mov    %edi,%ecx
f0104b29:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0104b2b:	09 d0                	or     %edx,%eax
f0104b2d:	89 f2                	mov    %esi,%edx
f0104b2f:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104b32:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104b34:	83 c4 20             	add    $0x20,%esp
f0104b37:	5e                   	pop    %esi
f0104b38:	5f                   	pop    %edi
f0104b39:	c9                   	leave  
f0104b3a:	c3                   	ret    
f0104b3b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0104b3c:	85 c9                	test   %ecx,%ecx
f0104b3e:	75 0b                	jne    f0104b4b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0104b40:	b8 01 00 00 00       	mov    $0x1,%eax
f0104b45:	31 d2                	xor    %edx,%edx
f0104b47:	f7 f1                	div    %ecx
f0104b49:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0104b4b:	89 f0                	mov    %esi,%eax
f0104b4d:	31 d2                	xor    %edx,%edx
f0104b4f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104b54:	f7 f1                	div    %ecx
f0104b56:	e9 4a ff ff ff       	jmp    f0104aa5 <__umoddi3+0x2d>
f0104b5b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0104b5c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104b5e:	83 c4 20             	add    $0x20,%esp
f0104b61:	5e                   	pop    %esi
f0104b62:	5f                   	pop    %edi
f0104b63:	c9                   	leave  
f0104b64:	c3                   	ret    
f0104b65:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0104b68:	39 f7                	cmp    %esi,%edi
f0104b6a:	72 05                	jb     f0104b71 <__umoddi3+0xf9>
f0104b6c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0104b6f:	77 0c                	ja     f0104b7d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0104b71:	89 f2                	mov    %esi,%edx
f0104b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104b76:	29 c8                	sub    %ecx,%eax
f0104b78:	19 fa                	sbb    %edi,%edx
f0104b7a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0104b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104b80:	83 c4 20             	add    $0x20,%esp
f0104b83:	5e                   	pop    %esi
f0104b84:	5f                   	pop    %edi
f0104b85:	c9                   	leave  
f0104b86:	c3                   	ret    
f0104b87:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104b88:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104b8b:	89 c1                	mov    %eax,%ecx
f0104b8d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0104b90:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0104b93:	eb 84                	jmp    f0104b19 <__umoddi3+0xa1>
f0104b95:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104b98:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0104b9b:	72 eb                	jb     f0104b88 <__umoddi3+0x110>
f0104b9d:	89 f2                	mov    %esi,%edx
f0104b9f:	e9 75 ff ff ff       	jmp    f0104b19 <__umoddi3+0xa1>
