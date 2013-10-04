
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
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
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
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 90 6f 1d f0       	mov    $0xf01d6f90,%eax
f010004b:	2d 64 60 1d f0       	sub    $0xf01d6064,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 64 60 1d f0       	push   $0xf01d6064
f0100058:	e8 b0 3f 00 00       	call   f010400d <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 81 04 00 00       	call   f01004e3 <cons_init>
//    cprintf("H%x Wo%s\n", 57616, &i);

//    cprintf("x=%d y=%d", 3, 4);
//    cprintf("x=%d y=%d", 3);

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 60 44 10 f0       	push   $0xf0104460
f010006f:	e8 c9 30 00 00       	call   f010313d <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 8c 15 00 00       	call   f0101605 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 f7 2c 00 00       	call   f0102d75 <env_init>
	trap_init();
f010007e:	e8 2e 31 00 00       	call   f01031b1 <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100083:	83 c4 0c             	add    $0xc,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 5b e8 00 00       	push   $0xe85b
f010008d:	68 40 13 12 f0       	push   $0xf0121340
f0100092:	e8 18 2e 00 00       	call   f0102eaf <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100097:	83 c4 04             	add    $0x4,%esp
f010009a:	ff 35 b8 62 1d f0    	pushl  0xf01d62b8
f01000a0:	e8 1d 30 00 00       	call   f01030c2 <env_run>

f01000a5 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a5:	55                   	push   %ebp
f01000a6:	89 e5                	mov    %esp,%ebp
f01000a8:	56                   	push   %esi
f01000a9:	53                   	push   %ebx
f01000aa:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ad:	83 3d 80 6f 1d f0 00 	cmpl   $0x0,0xf01d6f80
f01000b4:	75 37                	jne    f01000ed <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000b6:	89 35 80 6f 1d f0    	mov    %esi,0xf01d6f80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000bc:	fa                   	cli    
f01000bd:	fc                   	cld    

	va_start(ap, fmt);
f01000be:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000c1:	83 ec 04             	sub    $0x4,%esp
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	68 7b 44 10 f0       	push   $0xf010447b
f01000cf:	e8 69 30 00 00       	call   f010313d <cprintf>
	vcprintf(fmt, ap);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	53                   	push   %ebx
f01000d8:	56                   	push   %esi
f01000d9:	e8 39 30 00 00       	call   f0103117 <vcprintf>
	cprintf("\n");
f01000de:	c7 04 24 45 47 10 f0 	movl   $0xf0104745,(%esp)
f01000e5:	e8 53 30 00 00       	call   f010313d <cprintf>
	va_end(ap);
f01000ea:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000ed:	83 ec 0c             	sub    $0xc,%esp
f01000f0:	6a 00                	push   $0x0
f01000f2:	e8 d2 0c 00 00       	call   f0100dc9 <monitor>
f01000f7:	83 c4 10             	add    $0x10,%esp
f01000fa:	eb f1                	jmp    f01000ed <_panic+0x48>

f01000fc <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000fc:	55                   	push   %ebp
f01000fd:	89 e5                	mov    %esp,%ebp
f01000ff:	53                   	push   %ebx
f0100100:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100103:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100106:	ff 75 0c             	pushl  0xc(%ebp)
f0100109:	ff 75 08             	pushl  0x8(%ebp)
f010010c:	68 93 44 10 f0       	push   $0xf0104493
f0100111:	e8 27 30 00 00       	call   f010313d <cprintf>
	vcprintf(fmt, ap);
f0100116:	83 c4 08             	add    $0x8,%esp
f0100119:	53                   	push   %ebx
f010011a:	ff 75 10             	pushl  0x10(%ebp)
f010011d:	e8 f5 2f 00 00       	call   f0103117 <vcprintf>
	cprintf("\n");
f0100122:	c7 04 24 45 47 10 f0 	movl   $0xf0104745,(%esp)
f0100129:	e8 0f 30 00 00       	call   f010313d <cprintf>
	va_end(ap);
f010012e:	83 c4 10             	add    $0x10,%esp
}
f0100131:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100134:	c9                   	leave  
f0100135:	c3                   	ret    
	...

f0100138 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100138:	55                   	push   %ebp
f0100139:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010013b:	ba 84 00 00 00       	mov    $0x84,%edx
f0100140:	ec                   	in     (%dx),%al
f0100141:	ec                   	in     (%dx),%al
f0100142:	ec                   	in     (%dx),%al
f0100143:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100144:	c9                   	leave  
f0100145:	c3                   	ret    

f0100146 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100146:	55                   	push   %ebp
f0100147:	89 e5                	mov    %esp,%ebp
f0100149:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010014e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010014f:	a8 01                	test   $0x1,%al
f0100151:	74 08                	je     f010015b <serial_proc_data+0x15>
f0100153:	b2 f8                	mov    $0xf8,%dl
f0100155:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100156:	0f b6 c0             	movzbl %al,%eax
f0100159:	eb 05                	jmp    f0100160 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010015b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100160:	c9                   	leave  
f0100161:	c3                   	ret    

f0100162 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100162:	55                   	push   %ebp
f0100163:	89 e5                	mov    %esp,%ebp
f0100165:	53                   	push   %ebx
f0100166:	83 ec 04             	sub    $0x4,%esp
f0100169:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010016b:	eb 29                	jmp    f0100196 <cons_intr+0x34>
		if (c == 0)
f010016d:	85 c0                	test   %eax,%eax
f010016f:	74 25                	je     f0100196 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100171:	8b 15 a4 62 1d f0    	mov    0xf01d62a4,%edx
f0100177:	88 82 a0 60 1d f0    	mov    %al,-0xfe29f60(%edx)
f010017d:	8d 42 01             	lea    0x1(%edx),%eax
f0100180:	a3 a4 62 1d f0       	mov    %eax,0xf01d62a4
		if (cons.wpos == CONSBUFSIZE)
f0100185:	3d 00 02 00 00       	cmp    $0x200,%eax
f010018a:	75 0a                	jne    f0100196 <cons_intr+0x34>
			cons.wpos = 0;
f010018c:	c7 05 a4 62 1d f0 00 	movl   $0x0,0xf01d62a4
f0100193:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100196:	ff d3                	call   *%ebx
f0100198:	83 f8 ff             	cmp    $0xffffffff,%eax
f010019b:	75 d0                	jne    f010016d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010019d:	83 c4 04             	add    $0x4,%esp
f01001a0:	5b                   	pop    %ebx
f01001a1:	c9                   	leave  
f01001a2:	c3                   	ret    

f01001a3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001a3:	55                   	push   %ebp
f01001a4:	89 e5                	mov    %esp,%ebp
f01001a6:	57                   	push   %edi
f01001a7:	56                   	push   %esi
f01001a8:	53                   	push   %ebx
f01001a9:	83 ec 0c             	sub    $0xc,%esp
f01001ac:	89 c6                	mov    %eax,%esi
f01001ae:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b3:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001b4:	a8 20                	test   $0x20,%al
f01001b6:	75 19                	jne    f01001d1 <cons_putc+0x2e>
f01001b8:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01001bd:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001c2:	e8 71 ff ff ff       	call   f0100138 <delay>
f01001c7:	89 fa                	mov    %edi,%edx
f01001c9:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001ca:	a8 20                	test   $0x20,%al
f01001cc:	75 03                	jne    f01001d1 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001ce:	4b                   	dec    %ebx
f01001cf:	75 f1                	jne    f01001c2 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01001d1:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001d3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d8:	89 f0                	mov    %esi,%eax
f01001da:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001db:	b2 79                	mov    $0x79,%dl
f01001dd:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01001de:	84 c0                	test   %al,%al
f01001e0:	78 1d                	js     f01001ff <cons_putc+0x5c>
f01001e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f01001e7:	e8 4c ff ff ff       	call   f0100138 <delay>
f01001ec:	ba 79 03 00 00       	mov    $0x379,%edx
f01001f1:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01001f2:	84 c0                	test   %al,%al
f01001f4:	78 09                	js     f01001ff <cons_putc+0x5c>
f01001f6:	43                   	inc    %ebx
f01001f7:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01001fd:	75 e8                	jne    f01001e7 <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001ff:	ba 78 03 00 00       	mov    $0x378,%edx
f0100204:	89 f8                	mov    %edi,%eax
f0100206:	ee                   	out    %al,(%dx)
f0100207:	b2 7a                	mov    $0x7a,%dl
f0100209:	b0 0d                	mov    $0xd,%al
f010020b:	ee                   	out    %al,(%dx)
f010020c:	b0 08                	mov    $0x8,%al
f010020e:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
    // set user_setcolor
    c |= (user_setcolor << 8);
f010020f:	a1 80 60 1d f0       	mov    0xf01d6080,%eax
f0100214:	c1 e0 08             	shl    $0x8,%eax
f0100217:	09 c6                	or     %eax,%esi

	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100219:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f010021f:	75 06                	jne    f0100227 <cons_putc+0x84>
		c |= 0x0700;
f0100221:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f0100227:	89 f0                	mov    %esi,%eax
f0100229:	25 ff 00 00 00       	and    $0xff,%eax
f010022e:	83 f8 09             	cmp    $0x9,%eax
f0100231:	74 78                	je     f01002ab <cons_putc+0x108>
f0100233:	83 f8 09             	cmp    $0x9,%eax
f0100236:	7f 0b                	jg     f0100243 <cons_putc+0xa0>
f0100238:	83 f8 08             	cmp    $0x8,%eax
f010023b:	0f 85 9e 00 00 00    	jne    f01002df <cons_putc+0x13c>
f0100241:	eb 10                	jmp    f0100253 <cons_putc+0xb0>
f0100243:	83 f8 0a             	cmp    $0xa,%eax
f0100246:	74 39                	je     f0100281 <cons_putc+0xde>
f0100248:	83 f8 0d             	cmp    $0xd,%eax
f010024b:	0f 85 8e 00 00 00    	jne    f01002df <cons_putc+0x13c>
f0100251:	eb 36                	jmp    f0100289 <cons_putc+0xe6>
	case '\b':
		if (crt_pos > 0) {
f0100253:	66 a1 84 60 1d f0    	mov    0xf01d6084,%ax
f0100259:	66 85 c0             	test   %ax,%ax
f010025c:	0f 84 e0 00 00 00    	je     f0100342 <cons_putc+0x19f>
			crt_pos--;
f0100262:	48                   	dec    %eax
f0100263:	66 a3 84 60 1d f0    	mov    %ax,0xf01d6084
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100269:	0f b7 c0             	movzwl %ax,%eax
f010026c:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100272:	83 ce 20             	or     $0x20,%esi
f0100275:	8b 15 88 60 1d f0    	mov    0xf01d6088,%edx
f010027b:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f010027f:	eb 78                	jmp    f01002f9 <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100281:	66 83 05 84 60 1d f0 	addw   $0x50,0xf01d6084
f0100288:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100289:	66 8b 0d 84 60 1d f0 	mov    0xf01d6084,%cx
f0100290:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100295:	89 c8                	mov    %ecx,%eax
f0100297:	ba 00 00 00 00       	mov    $0x0,%edx
f010029c:	66 f7 f3             	div    %bx
f010029f:	66 29 d1             	sub    %dx,%cx
f01002a2:	66 89 0d 84 60 1d f0 	mov    %cx,0xf01d6084
f01002a9:	eb 4e                	jmp    f01002f9 <cons_putc+0x156>
		break;
	case '\t':
		cons_putc(' ');
f01002ab:	b8 20 00 00 00       	mov    $0x20,%eax
f01002b0:	e8 ee fe ff ff       	call   f01001a3 <cons_putc>
		cons_putc(' ');
f01002b5:	b8 20 00 00 00       	mov    $0x20,%eax
f01002ba:	e8 e4 fe ff ff       	call   f01001a3 <cons_putc>
		cons_putc(' ');
f01002bf:	b8 20 00 00 00       	mov    $0x20,%eax
f01002c4:	e8 da fe ff ff       	call   f01001a3 <cons_putc>
		cons_putc(' ');
f01002c9:	b8 20 00 00 00       	mov    $0x20,%eax
f01002ce:	e8 d0 fe ff ff       	call   f01001a3 <cons_putc>
		cons_putc(' ');
f01002d3:	b8 20 00 00 00       	mov    $0x20,%eax
f01002d8:	e8 c6 fe ff ff       	call   f01001a3 <cons_putc>
f01002dd:	eb 1a                	jmp    f01002f9 <cons_putc+0x156>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01002df:	66 a1 84 60 1d f0    	mov    0xf01d6084,%ax
f01002e5:	0f b7 c8             	movzwl %ax,%ecx
f01002e8:	8b 15 88 60 1d f0    	mov    0xf01d6088,%edx
f01002ee:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01002f2:	40                   	inc    %eax
f01002f3:	66 a3 84 60 1d f0    	mov    %ax,0xf01d6084
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f01002f9:	66 81 3d 84 60 1d f0 	cmpw   $0x7cf,0xf01d6084
f0100300:	cf 07 
f0100302:	76 3e                	jbe    f0100342 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100304:	a1 88 60 1d f0       	mov    0xf01d6088,%eax
f0100309:	83 ec 04             	sub    $0x4,%esp
f010030c:	68 00 0f 00 00       	push   $0xf00
f0100311:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100317:	52                   	push   %edx
f0100318:	50                   	push   %eax
f0100319:	e8 39 3d 00 00       	call   f0104057 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010031e:	8b 15 88 60 1d f0    	mov    0xf01d6088,%edx
f0100324:	83 c4 10             	add    $0x10,%esp
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100327:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010032c:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100332:	40                   	inc    %eax
f0100333:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100338:	75 f2                	jne    f010032c <cons_putc+0x189>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010033a:	66 83 2d 84 60 1d f0 	subw   $0x50,0xf01d6084
f0100341:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100342:	8b 0d 8c 60 1d f0    	mov    0xf01d608c,%ecx
f0100348:	b0 0e                	mov    $0xe,%al
f010034a:	89 ca                	mov    %ecx,%edx
f010034c:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010034d:	66 8b 35 84 60 1d f0 	mov    0xf01d6084,%si
f0100354:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100357:	89 f0                	mov    %esi,%eax
f0100359:	66 c1 e8 08          	shr    $0x8,%ax
f010035d:	89 da                	mov    %ebx,%edx
f010035f:	ee                   	out    %al,(%dx)
f0100360:	b0 0f                	mov    $0xf,%al
f0100362:	89 ca                	mov    %ecx,%edx
f0100364:	ee                   	out    %al,(%dx)
f0100365:	89 f0                	mov    %esi,%eax
f0100367:	89 da                	mov    %ebx,%edx
f0100369:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010036d:	5b                   	pop    %ebx
f010036e:	5e                   	pop    %esi
f010036f:	5f                   	pop    %edi
f0100370:	c9                   	leave  
f0100371:	c3                   	ret    

f0100372 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100372:	55                   	push   %ebp
f0100373:	89 e5                	mov    %esp,%ebp
f0100375:	53                   	push   %ebx
f0100376:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100379:	ba 64 00 00 00       	mov    $0x64,%edx
f010037e:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010037f:	a8 01                	test   $0x1,%al
f0100381:	0f 84 dc 00 00 00    	je     f0100463 <kbd_proc_data+0xf1>
f0100387:	b2 60                	mov    $0x60,%dl
f0100389:	ec                   	in     (%dx),%al
f010038a:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010038c:	3c e0                	cmp    $0xe0,%al
f010038e:	75 11                	jne    f01003a1 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100390:	83 0d a8 62 1d f0 40 	orl    $0x40,0xf01d62a8
		return 0;
f0100397:	bb 00 00 00 00       	mov    $0x0,%ebx
f010039c:	e9 c7 00 00 00       	jmp    f0100468 <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f01003a1:	84 c0                	test   %al,%al
f01003a3:	79 33                	jns    f01003d8 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003a5:	8b 0d a8 62 1d f0    	mov    0xf01d62a8,%ecx
f01003ab:	f6 c1 40             	test   $0x40,%cl
f01003ae:	75 05                	jne    f01003b5 <kbd_proc_data+0x43>
f01003b0:	88 c2                	mov    %al,%dl
f01003b2:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003b5:	0f b6 d2             	movzbl %dl,%edx
f01003b8:	8a 82 e0 44 10 f0    	mov    -0xfefbb20(%edx),%al
f01003be:	83 c8 40             	or     $0x40,%eax
f01003c1:	0f b6 c0             	movzbl %al,%eax
f01003c4:	f7 d0                	not    %eax
f01003c6:	21 c1                	and    %eax,%ecx
f01003c8:	89 0d a8 62 1d f0    	mov    %ecx,0xf01d62a8
		return 0;
f01003ce:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003d3:	e9 90 00 00 00       	jmp    f0100468 <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f01003d8:	8b 0d a8 62 1d f0    	mov    0xf01d62a8,%ecx
f01003de:	f6 c1 40             	test   $0x40,%cl
f01003e1:	74 0e                	je     f01003f1 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003e3:	88 c2                	mov    %al,%dl
f01003e5:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003e8:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003eb:	89 0d a8 62 1d f0    	mov    %ecx,0xf01d62a8
	}

	shift |= shiftcode[data];
f01003f1:	0f b6 d2             	movzbl %dl,%edx
f01003f4:	0f b6 82 e0 44 10 f0 	movzbl -0xfefbb20(%edx),%eax
f01003fb:	0b 05 a8 62 1d f0    	or     0xf01d62a8,%eax
	shift ^= togglecode[data];
f0100401:	0f b6 8a e0 45 10 f0 	movzbl -0xfefba20(%edx),%ecx
f0100408:	31 c8                	xor    %ecx,%eax
f010040a:	a3 a8 62 1d f0       	mov    %eax,0xf01d62a8

	c = charcode[shift & (CTL | SHIFT)][data];
f010040f:	89 c1                	mov    %eax,%ecx
f0100411:	83 e1 03             	and    $0x3,%ecx
f0100414:	8b 0c 8d e0 46 10 f0 	mov    -0xfefb920(,%ecx,4),%ecx
f010041b:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f010041f:	a8 08                	test   $0x8,%al
f0100421:	74 18                	je     f010043b <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f0100423:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100426:	83 fa 19             	cmp    $0x19,%edx
f0100429:	77 05                	ja     f0100430 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f010042b:	83 eb 20             	sub    $0x20,%ebx
f010042e:	eb 0b                	jmp    f010043b <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100430:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100433:	83 fa 19             	cmp    $0x19,%edx
f0100436:	77 03                	ja     f010043b <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f0100438:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010043b:	f7 d0                	not    %eax
f010043d:	a8 06                	test   $0x6,%al
f010043f:	75 27                	jne    f0100468 <kbd_proc_data+0xf6>
f0100441:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100447:	75 1f                	jne    f0100468 <kbd_proc_data+0xf6>
		cprintf("Rebooting!\n");
f0100449:	83 ec 0c             	sub    $0xc,%esp
f010044c:	68 ad 44 10 f0       	push   $0xf01044ad
f0100451:	e8 e7 2c 00 00       	call   f010313d <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100456:	ba 92 00 00 00       	mov    $0x92,%edx
f010045b:	b0 03                	mov    $0x3,%al
f010045d:	ee                   	out    %al,(%dx)
f010045e:	83 c4 10             	add    $0x10,%esp
f0100461:	eb 05                	jmp    f0100468 <kbd_proc_data+0xf6>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100463:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100468:	89 d8                	mov    %ebx,%eax
f010046a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010046d:	c9                   	leave  
f010046e:	c3                   	ret    

f010046f <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010046f:	55                   	push   %ebp
f0100470:	89 e5                	mov    %esp,%ebp
f0100472:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100475:	80 3d 90 60 1d f0 00 	cmpb   $0x0,0xf01d6090
f010047c:	74 0a                	je     f0100488 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010047e:	b8 46 01 10 f0       	mov    $0xf0100146,%eax
f0100483:	e8 da fc ff ff       	call   f0100162 <cons_intr>
}
f0100488:	c9                   	leave  
f0100489:	c3                   	ret    

f010048a <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010048a:	55                   	push   %ebp
f010048b:	89 e5                	mov    %esp,%ebp
f010048d:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100490:	b8 72 03 10 f0       	mov    $0xf0100372,%eax
f0100495:	e8 c8 fc ff ff       	call   f0100162 <cons_intr>
}
f010049a:	c9                   	leave  
f010049b:	c3                   	ret    

f010049c <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010049c:	55                   	push   %ebp
f010049d:	89 e5                	mov    %esp,%ebp
f010049f:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004a2:	e8 c8 ff ff ff       	call   f010046f <serial_intr>
	kbd_intr();
f01004a7:	e8 de ff ff ff       	call   f010048a <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004ac:	8b 15 a0 62 1d f0    	mov    0xf01d62a0,%edx
f01004b2:	3b 15 a4 62 1d f0    	cmp    0xf01d62a4,%edx
f01004b8:	74 22                	je     f01004dc <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01004ba:	0f b6 82 a0 60 1d f0 	movzbl -0xfe29f60(%edx),%eax
f01004c1:	42                   	inc    %edx
f01004c2:	89 15 a0 62 1d f0    	mov    %edx,0xf01d62a0
		if (cons.rpos == CONSBUFSIZE)
f01004c8:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004ce:	75 11                	jne    f01004e1 <cons_getc+0x45>
			cons.rpos = 0;
f01004d0:	c7 05 a0 62 1d f0 00 	movl   $0x0,0xf01d62a0
f01004d7:	00 00 00 
f01004da:	eb 05                	jmp    f01004e1 <cons_getc+0x45>
		return c;
	}
	return 0;
f01004dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004e1:	c9                   	leave  
f01004e2:	c3                   	ret    

f01004e3 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004e3:	55                   	push   %ebp
f01004e4:	89 e5                	mov    %esp,%ebp
f01004e6:	57                   	push   %edi
f01004e7:	56                   	push   %esi
f01004e8:	53                   	push   %ebx
f01004e9:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004ec:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01004f3:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01004fa:	5a a5 
	if (*cp != 0xA55A) {
f01004fc:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100502:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100506:	74 11                	je     f0100519 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100508:	c7 05 8c 60 1d f0 b4 	movl   $0x3b4,0xf01d608c
f010050f:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100512:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100517:	eb 16                	jmp    f010052f <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100519:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100520:	c7 05 8c 60 1d f0 d4 	movl   $0x3d4,0xf01d608c
f0100527:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010052a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010052f:	8b 0d 8c 60 1d f0    	mov    0xf01d608c,%ecx
f0100535:	b0 0e                	mov    $0xe,%al
f0100537:	89 ca                	mov    %ecx,%edx
f0100539:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010053a:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010053d:	89 da                	mov    %ebx,%edx
f010053f:	ec                   	in     (%dx),%al
f0100540:	0f b6 f8             	movzbl %al,%edi
f0100543:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100546:	b0 0f                	mov    $0xf,%al
f0100548:	89 ca                	mov    %ecx,%edx
f010054a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010054b:	89 da                	mov    %ebx,%edx
f010054d:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010054e:	89 35 88 60 1d f0    	mov    %esi,0xf01d6088

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100554:	0f b6 d8             	movzbl %al,%ebx
f0100557:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100559:	66 89 3d 84 60 1d f0 	mov    %di,0xf01d6084
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100560:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100565:	b0 00                	mov    $0x0,%al
f0100567:	89 da                	mov    %ebx,%edx
f0100569:	ee                   	out    %al,(%dx)
f010056a:	b2 fb                	mov    $0xfb,%dl
f010056c:	b0 80                	mov    $0x80,%al
f010056e:	ee                   	out    %al,(%dx)
f010056f:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100574:	b0 0c                	mov    $0xc,%al
f0100576:	89 ca                	mov    %ecx,%edx
f0100578:	ee                   	out    %al,(%dx)
f0100579:	b2 f9                	mov    $0xf9,%dl
f010057b:	b0 00                	mov    $0x0,%al
f010057d:	ee                   	out    %al,(%dx)
f010057e:	b2 fb                	mov    $0xfb,%dl
f0100580:	b0 03                	mov    $0x3,%al
f0100582:	ee                   	out    %al,(%dx)
f0100583:	b2 fc                	mov    $0xfc,%dl
f0100585:	b0 00                	mov    $0x0,%al
f0100587:	ee                   	out    %al,(%dx)
f0100588:	b2 f9                	mov    $0xf9,%dl
f010058a:	b0 01                	mov    $0x1,%al
f010058c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010058d:	b2 fd                	mov    $0xfd,%dl
f010058f:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100590:	3c ff                	cmp    $0xff,%al
f0100592:	0f 95 45 e7          	setne  -0x19(%ebp)
f0100596:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100599:	a2 90 60 1d f0       	mov    %al,0xf01d6090
f010059e:	89 da                	mov    %ebx,%edx
f01005a0:	ec                   	in     (%dx),%al
f01005a1:	89 ca                	mov    %ecx,%edx
f01005a3:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005a4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01005a8:	75 10                	jne    f01005ba <cons_init+0xd7>
		cprintf("Serial port does not exist!\n");
f01005aa:	83 ec 0c             	sub    $0xc,%esp
f01005ad:	68 b9 44 10 f0       	push   $0xf01044b9
f01005b2:	e8 86 2b 00 00       	call   f010313d <cprintf>
f01005b7:	83 c4 10             	add    $0x10,%esp
}
f01005ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005bd:	5b                   	pop    %ebx
f01005be:	5e                   	pop    %esi
f01005bf:	5f                   	pop    %edi
f01005c0:	c9                   	leave  
f01005c1:	c3                   	ret    

f01005c2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005c2:	55                   	push   %ebp
f01005c3:	89 e5                	mov    %esp,%ebp
f01005c5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01005cb:	e8 d3 fb ff ff       	call   f01001a3 <cons_putc>
}
f01005d0:	c9                   	leave  
f01005d1:	c3                   	ret    

f01005d2 <getchar>:

int
getchar(void)
{
f01005d2:	55                   	push   %ebp
f01005d3:	89 e5                	mov    %esp,%ebp
f01005d5:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01005d8:	e8 bf fe ff ff       	call   f010049c <cons_getc>
f01005dd:	85 c0                	test   %eax,%eax
f01005df:	74 f7                	je     f01005d8 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01005e1:	c9                   	leave  
f01005e2:	c3                   	ret    

f01005e3 <iscons>:

int
iscons(int fdnum)
{
f01005e3:	55                   	push   %ebp
f01005e4:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01005e6:	b8 01 00 00 00       	mov    $0x1,%eax
f01005eb:	c9                   	leave  
f01005ec:	c3                   	ret    
f01005ed:	00 00                	add    %al,(%eax)
	...

f01005f0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01005f0:	55                   	push   %ebp
f01005f1:	89 e5                	mov    %esp,%ebp
f01005f3:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01005f6:	68 f0 46 10 f0       	push   $0xf01046f0
f01005fb:	e8 3d 2b 00 00       	call   f010313d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100600:	83 c4 08             	add    $0x8,%esp
f0100603:	68 0c 00 10 00       	push   $0x10000c
f0100608:	68 d4 48 10 f0       	push   $0xf01048d4
f010060d:	e8 2b 2b 00 00       	call   f010313d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100612:	83 c4 0c             	add    $0xc,%esp
f0100615:	68 0c 00 10 00       	push   $0x10000c
f010061a:	68 0c 00 10 f0       	push   $0xf010000c
f010061f:	68 fc 48 10 f0       	push   $0xf01048fc
f0100624:	e8 14 2b 00 00       	call   f010313d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100629:	83 c4 0c             	add    $0xc,%esp
f010062c:	68 5c 44 10 00       	push   $0x10445c
f0100631:	68 5c 44 10 f0       	push   $0xf010445c
f0100636:	68 20 49 10 f0       	push   $0xf0104920
f010063b:	e8 fd 2a 00 00       	call   f010313d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100640:	83 c4 0c             	add    $0xc,%esp
f0100643:	68 64 60 1d 00       	push   $0x1d6064
f0100648:	68 64 60 1d f0       	push   $0xf01d6064
f010064d:	68 44 49 10 f0       	push   $0xf0104944
f0100652:	e8 e6 2a 00 00       	call   f010313d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100657:	83 c4 0c             	add    $0xc,%esp
f010065a:	68 90 6f 1d 00       	push   $0x1d6f90
f010065f:	68 90 6f 1d f0       	push   $0xf01d6f90
f0100664:	68 68 49 10 f0       	push   $0xf0104968
f0100669:	e8 cf 2a 00 00       	call   f010313d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010066e:	b8 8f 73 1d f0       	mov    $0xf01d738f,%eax
f0100673:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100678:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010067b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100680:	89 c2                	mov    %eax,%edx
f0100682:	85 c0                	test   %eax,%eax
f0100684:	79 06                	jns    f010068c <mon_kerninfo+0x9c>
f0100686:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010068c:	c1 fa 0a             	sar    $0xa,%edx
f010068f:	52                   	push   %edx
f0100690:	68 8c 49 10 f0       	push   $0xf010498c
f0100695:	e8 a3 2a 00 00       	call   f010313d <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010069a:	b8 00 00 00 00       	mov    $0x0,%eax
f010069f:	c9                   	leave  
f01006a0:	c3                   	ret    

f01006a1 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006a1:	55                   	push   %ebp
f01006a2:	89 e5                	mov    %esp,%ebp
f01006a4:	53                   	push   %ebx
f01006a5:	83 ec 04             	sub    $0x4,%esp
f01006a8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006ad:	83 ec 04             	sub    $0x4,%esp
f01006b0:	ff b3 e4 4d 10 f0    	pushl  -0xfefb21c(%ebx)
f01006b6:	ff b3 e0 4d 10 f0    	pushl  -0xfefb220(%ebx)
f01006bc:	68 09 47 10 f0       	push   $0xf0104709
f01006c1:	e8 77 2a 00 00       	call   f010313d <cprintf>
f01006c6:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01006c9:	83 c4 10             	add    $0x10,%esp
f01006cc:	83 fb 54             	cmp    $0x54,%ebx
f01006cf:	75 dc                	jne    f01006ad <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01006d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01006d9:	c9                   	leave  
f01006da:	c3                   	ret    

f01006db <mon_showmappings>:
    return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f01006db:	55                   	push   %ebp
f01006dc:	89 e5                	mov    %esp,%ebp
f01006de:	57                   	push   %edi
f01006df:	56                   	push   %esi
f01006e0:	53                   	push   %ebx
f01006e1:	83 ec 0c             	sub    $0xc,%esp
f01006e4:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 3) {
f01006e7:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01006eb:	74 21                	je     f010070e <mon_showmappings+0x33>
        cprintf("Command should be: showmappings [addr1] [addr2]\n");
f01006ed:	83 ec 0c             	sub    $0xc,%esp
f01006f0:	68 b8 49 10 f0       	push   $0xf01049b8
f01006f5:	e8 43 2a 00 00       	call   f010313d <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f01006fa:	c7 04 24 ec 49 10 f0 	movl   $0xf01049ec,(%esp)
f0100701:	e8 37 2a 00 00       	call   f010313d <cprintf>
f0100706:	83 c4 10             	add    $0x10,%esp
f0100709:	e9 1a 01 00 00       	jmp    f0100828 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f010070e:	83 ec 04             	sub    $0x4,%esp
f0100711:	6a 00                	push   $0x0
f0100713:	6a 00                	push   $0x0
f0100715:	ff 76 04             	pushl  0x4(%esi)
f0100718:	e8 29 3a 00 00       	call   f0104146 <strtol>
f010071d:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f010071f:	83 c4 0c             	add    $0xc,%esp
f0100722:	6a 00                	push   $0x0
f0100724:	6a 00                	push   $0x0
f0100726:	ff 76 08             	pushl  0x8(%esi)
f0100729:	e8 18 3a 00 00       	call   f0104146 <strtol>
        if (laddr > haddr) {
f010072e:	83 c4 10             	add    $0x10,%esp
f0100731:	39 c3                	cmp    %eax,%ebx
f0100733:	76 01                	jbe    f0100736 <mon_showmappings+0x5b>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100735:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, PGSIZE);
f0100736:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        haddr = ROUNDUP(haddr, PGSIZE);
f010073c:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f0100742:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
f0100748:	83 ec 04             	sub    $0x4,%esp
f010074b:	57                   	push   %edi
f010074c:	53                   	push   %ebx
f010074d:	68 12 47 10 f0       	push   $0xf0104712
f0100752:	e8 e6 29 00 00       	call   f010313d <cprintf>
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f0100757:	83 c4 10             	add    $0x10,%esp
f010075a:	39 fb                	cmp    %edi,%ebx
f010075c:	75 07                	jne    f0100765 <mon_showmappings+0x8a>
f010075e:	e9 c5 00 00 00       	jmp    f0100828 <mon_showmappings+0x14d>
f0100763:	89 f3                	mov    %esi,%ebx
            cprintf("[ 0x%08x, 0x%08x ) -> ", now, now + PGSIZE); 
f0100765:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
f010076b:	83 ec 04             	sub    $0x4,%esp
f010076e:	56                   	push   %esi
f010076f:	53                   	push   %ebx
f0100770:	68 23 47 10 f0       	push   $0xf0104723
f0100775:	e8 c3 29 00 00       	call   f010313d <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f010077a:	83 c4 0c             	add    $0xc,%esp
f010077d:	6a 00                	push   $0x0
f010077f:	53                   	push   %ebx
f0100780:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0100786:	e8 6b 0c 00 00       	call   f01013f6 <pgdir_walk>
f010078b:	89 c3                	mov    %eax,%ebx
            if (pte == 0 || (*pte & PTE_P) == 0) {
f010078d:	83 c4 10             	add    $0x10,%esp
f0100790:	85 c0                	test   %eax,%eax
f0100792:	74 06                	je     f010079a <mon_showmappings+0xbf>
f0100794:	8b 00                	mov    (%eax),%eax
f0100796:	a8 01                	test   $0x1,%al
f0100798:	75 12                	jne    f01007ac <mon_showmappings+0xd1>
                cprintf(" no mapped \n");
f010079a:	83 ec 0c             	sub    $0xc,%esp
f010079d:	68 3a 47 10 f0       	push   $0xf010473a
f01007a2:	e8 96 29 00 00       	call   f010313d <cprintf>
f01007a7:	83 c4 10             	add    $0x10,%esp
f01007aa:	eb 74                	jmp    f0100820 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f01007ac:	83 ec 08             	sub    $0x8,%esp
f01007af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01007b4:	50                   	push   %eax
f01007b5:	68 47 47 10 f0       	push   $0xf0104747
f01007ba:	e8 7e 29 00 00       	call   f010313d <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f01007bf:	83 c4 10             	add    $0x10,%esp
f01007c2:	f6 03 04             	testb  $0x4,(%ebx)
f01007c5:	74 12                	je     f01007d9 <mon_showmappings+0xfe>
f01007c7:	83 ec 0c             	sub    $0xc,%esp
f01007ca:	68 4f 47 10 f0       	push   $0xf010474f
f01007cf:	e8 69 29 00 00       	call   f010313d <cprintf>
f01007d4:	83 c4 10             	add    $0x10,%esp
f01007d7:	eb 10                	jmp    f01007e9 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f01007d9:	83 ec 0c             	sub    $0xc,%esp
f01007dc:	68 5c 47 10 f0       	push   $0xf010475c
f01007e1:	e8 57 29 00 00       	call   f010313d <cprintf>
f01007e6:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f01007e9:	f6 03 02             	testb  $0x2,(%ebx)
f01007ec:	74 12                	je     f0100800 <mon_showmappings+0x125>
f01007ee:	83 ec 0c             	sub    $0xc,%esp
f01007f1:	68 69 47 10 f0       	push   $0xf0104769
f01007f6:	e8 42 29 00 00       	call   f010313d <cprintf>
f01007fb:	83 c4 10             	add    $0x10,%esp
f01007fe:	eb 10                	jmp    f0100810 <mon_showmappings+0x135>
                else cprintf(" R ");
f0100800:	83 ec 0c             	sub    $0xc,%esp
f0100803:	68 6e 47 10 f0       	push   $0xf010476e
f0100808:	e8 30 29 00 00       	call   f010313d <cprintf>
f010080d:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f0100810:	83 ec 0c             	sub    $0xc,%esp
f0100813:	68 45 47 10 f0       	push   $0xf0104745
f0100818:	e8 20 29 00 00       	call   f010313d <cprintf>
f010081d:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDUP(haddr, PGSIZE);
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f0100820:	39 f7                	cmp    %esi,%edi
f0100822:	0f 85 3b ff ff ff    	jne    f0100763 <mon_showmappings+0x88>
                cprintf("\n");
            }
        }
    }
    return 0;
}
f0100828:	b8 00 00 00 00       	mov    $0x0,%eax
f010082d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100830:	5b                   	pop    %ebx
f0100831:	5e                   	pop    %esi
f0100832:	5f                   	pop    %edi
f0100833:	c9                   	leave  
f0100834:	c3                   	ret    

f0100835 <mon_setpermission>:
    return 0;
}

int
mon_setpermission(int argc, char **argv, struct Trapframe *tf)
{
f0100835:	55                   	push   %ebp
f0100836:	89 e5                	mov    %esp,%ebp
f0100838:	57                   	push   %edi
f0100839:	56                   	push   %esi
f010083a:	53                   	push   %ebx
f010083b:	83 ec 0c             	sub    $0xc,%esp
f010083e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 5) { 
f0100841:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f0100845:	74 21                	je     f0100868 <mon_setpermission+0x33>
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
f0100847:	83 ec 0c             	sub    $0xc,%esp
f010084a:	68 14 4a 10 f0       	push   $0xf0104a14
f010084f:	e8 e9 28 00 00       	call   f010313d <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f0100854:	c7 04 24 64 4a 10 f0 	movl   $0xf0104a64,(%esp)
f010085b:	e8 dd 28 00 00       	call   f010313d <cprintf>
f0100860:	83 c4 10             	add    $0x10,%esp
f0100863:	e9 a5 01 00 00       	jmp    f0100a0d <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f0100868:	83 ec 04             	sub    $0x4,%esp
f010086b:	6a 00                	push   $0x0
f010086d:	6a 00                	push   $0x0
f010086f:	ff 73 04             	pushl  0x4(%ebx)
f0100872:	e8 cf 38 00 00       	call   f0104146 <strtol>
        uint32_t perm = 0;
        if (argv[2][0] == '1') perm |= PTE_W;
f0100877:	8b 53 08             	mov    0x8(%ebx),%edx
f010087a:	83 c4 10             	add    $0x10,%esp
    if (argc != 5) { 
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
        cprintf("Example: setpermissions 0x0 1 0 1\n");
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
        uint32_t perm = 0;
f010087d:	80 3a 31             	cmpb   $0x31,(%edx)
f0100880:	0f 94 c2             	sete   %dl
f0100883:	0f b6 d2             	movzbl %dl,%edx
f0100886:	89 d6                	mov    %edx,%esi
f0100888:	d1 e6                	shl    %esi
        if (argv[2][0] == '1') perm |= PTE_W;
        if (argv[3][0] == '1') perm |= PTE_U;
f010088a:	8b 53 0c             	mov    0xc(%ebx),%edx
f010088d:	80 3a 31             	cmpb   $0x31,(%edx)
f0100890:	75 03                	jne    f0100895 <mon_setpermission+0x60>
f0100892:	83 ce 04             	or     $0x4,%esi
        if (argv[4][0] == '1') perm |= PTE_P;
f0100895:	8b 53 10             	mov    0x10(%ebx),%edx
f0100898:	80 3a 31             	cmpb   $0x31,(%edx)
f010089b:	75 03                	jne    f01008a0 <mon_setpermission+0x6b>
f010089d:	83 ce 01             	or     $0x1,%esi
        addr = ROUNDUP(addr, PGSIZE);
f01008a0:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01008a6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
f01008ac:	83 ec 04             	sub    $0x4,%esp
f01008af:	6a 00                	push   $0x0
f01008b1:	57                   	push   %edi
f01008b2:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f01008b8:	e8 39 0b 00 00       	call   f01013f6 <pgdir_walk>
f01008bd:	89 c3                	mov    %eax,%ebx
        if (pte != NULL) {
f01008bf:	83 c4 10             	add    $0x10,%esp
f01008c2:	85 c0                	test   %eax,%eax
f01008c4:	0f 84 33 01 00 00    	je     f01009fd <mon_setpermission+0x1c8>
            cprintf("0x%08x -> pa: 0x%08x\n old_perm: ", addr, PTE_ADDR(*pte));
f01008ca:	83 ec 04             	sub    $0x4,%esp
f01008cd:	8b 00                	mov    (%eax),%eax
f01008cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008d4:	50                   	push   %eax
f01008d5:	57                   	push   %edi
f01008d6:	68 88 4a 10 f0       	push   $0xf0104a88
f01008db:	e8 5d 28 00 00       	call   f010313d <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f01008e0:	83 c4 10             	add    $0x10,%esp
f01008e3:	f6 03 02             	testb  $0x2,(%ebx)
f01008e6:	74 12                	je     f01008fa <mon_setpermission+0xc5>
f01008e8:	83 ec 0c             	sub    $0xc,%esp
f01008eb:	68 72 47 10 f0       	push   $0xf0104772
f01008f0:	e8 48 28 00 00       	call   f010313d <cprintf>
f01008f5:	83 c4 10             	add    $0x10,%esp
f01008f8:	eb 10                	jmp    f010090a <mon_setpermission+0xd5>
f01008fa:	83 ec 0c             	sub    $0xc,%esp
f01008fd:	68 75 47 10 f0       	push   $0xf0104775
f0100902:	e8 36 28 00 00       	call   f010313d <cprintf>
f0100907:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f010090a:	f6 03 04             	testb  $0x4,(%ebx)
f010090d:	74 12                	je     f0100921 <mon_setpermission+0xec>
f010090f:	83 ec 0c             	sub    $0xc,%esp
f0100912:	68 aa 57 10 f0       	push   $0xf01057aa
f0100917:	e8 21 28 00 00       	call   f010313d <cprintf>
f010091c:	83 c4 10             	add    $0x10,%esp
f010091f:	eb 10                	jmp    f0100931 <mon_setpermission+0xfc>
f0100921:	83 ec 0c             	sub    $0xc,%esp
f0100924:	68 6b 5b 10 f0       	push   $0xf0105b6b
f0100929:	e8 0f 28 00 00       	call   f010313d <cprintf>
f010092e:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100931:	f6 03 01             	testb  $0x1,(%ebx)
f0100934:	74 12                	je     f0100948 <mon_setpermission+0x113>
f0100936:	83 ec 0c             	sub    $0xc,%esp
f0100939:	68 3b 58 10 f0       	push   $0xf010583b
f010093e:	e8 fa 27 00 00       	call   f010313d <cprintf>
f0100943:	83 c4 10             	add    $0x10,%esp
f0100946:	eb 10                	jmp    f0100958 <mon_setpermission+0x123>
f0100948:	83 ec 0c             	sub    $0xc,%esp
f010094b:	68 76 47 10 f0       	push   $0xf0104776
f0100950:	e8 e8 27 00 00       	call   f010313d <cprintf>
f0100955:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f0100958:	83 ec 0c             	sub    $0xc,%esp
f010095b:	68 78 47 10 f0       	push   $0xf0104778
f0100960:	e8 d8 27 00 00       	call   f010313d <cprintf>
            *pte = PTE_ADDR(*pte) | perm;     
f0100965:	8b 03                	mov    (%ebx),%eax
f0100967:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010096c:	09 c6                	or     %eax,%esi
f010096e:	89 33                	mov    %esi,(%ebx)
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100970:	83 c4 10             	add    $0x10,%esp
f0100973:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0100979:	74 12                	je     f010098d <mon_setpermission+0x158>
f010097b:	83 ec 0c             	sub    $0xc,%esp
f010097e:	68 72 47 10 f0       	push   $0xf0104772
f0100983:	e8 b5 27 00 00       	call   f010313d <cprintf>
f0100988:	83 c4 10             	add    $0x10,%esp
f010098b:	eb 10                	jmp    f010099d <mon_setpermission+0x168>
f010098d:	83 ec 0c             	sub    $0xc,%esp
f0100990:	68 75 47 10 f0       	push   $0xf0104775
f0100995:	e8 a3 27 00 00       	call   f010313d <cprintf>
f010099a:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f010099d:	f6 03 04             	testb  $0x4,(%ebx)
f01009a0:	74 12                	je     f01009b4 <mon_setpermission+0x17f>
f01009a2:	83 ec 0c             	sub    $0xc,%esp
f01009a5:	68 aa 57 10 f0       	push   $0xf01057aa
f01009aa:	e8 8e 27 00 00       	call   f010313d <cprintf>
f01009af:	83 c4 10             	add    $0x10,%esp
f01009b2:	eb 10                	jmp    f01009c4 <mon_setpermission+0x18f>
f01009b4:	83 ec 0c             	sub    $0xc,%esp
f01009b7:	68 6b 5b 10 f0       	push   $0xf0105b6b
f01009bc:	e8 7c 27 00 00       	call   f010313d <cprintf>
f01009c1:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f01009c4:	f6 03 01             	testb  $0x1,(%ebx)
f01009c7:	74 12                	je     f01009db <mon_setpermission+0x1a6>
f01009c9:	83 ec 0c             	sub    $0xc,%esp
f01009cc:	68 3b 58 10 f0       	push   $0xf010583b
f01009d1:	e8 67 27 00 00       	call   f010313d <cprintf>
f01009d6:	83 c4 10             	add    $0x10,%esp
f01009d9:	eb 10                	jmp    f01009eb <mon_setpermission+0x1b6>
f01009db:	83 ec 0c             	sub    $0xc,%esp
f01009de:	68 76 47 10 f0       	push   $0xf0104776
f01009e3:	e8 55 27 00 00       	call   f010313d <cprintf>
f01009e8:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f01009eb:	83 ec 0c             	sub    $0xc,%esp
f01009ee:	68 45 47 10 f0       	push   $0xf0104745
f01009f3:	e8 45 27 00 00       	call   f010313d <cprintf>
f01009f8:	83 c4 10             	add    $0x10,%esp
f01009fb:	eb 10                	jmp    f0100a0d <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f01009fd:	83 ec 0c             	sub    $0xc,%esp
f0100a00:	68 3a 47 10 f0       	push   $0xf010473a
f0100a05:	e8 33 27 00 00       	call   f010313d <cprintf>
f0100a0a:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100a0d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a12:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a15:	5b                   	pop    %ebx
f0100a16:	5e                   	pop    %esi
f0100a17:	5f                   	pop    %edi
f0100a18:	c9                   	leave  
f0100a19:	c3                   	ret    

f0100a1a <mon_setcolor>:
    return 0;
}

int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f0100a1a:	55                   	push   %ebp
f0100a1b:	89 e5                	mov    %esp,%ebp
f0100a1d:	56                   	push   %esi
f0100a1e:	53                   	push   %ebx
f0100a1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f0100a22:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100a26:	74 66                	je     f0100a8e <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f0100a28:	83 ec 0c             	sub    $0xc,%esp
f0100a2b:	68 ac 4a 10 f0       	push   $0xf0104aac
f0100a30:	e8 08 27 00 00       	call   f010313d <cprintf>
        cprintf("num show the color attribute. \n");
f0100a35:	c7 04 24 dc 4a 10 f0 	movl   $0xf0104adc,(%esp)
f0100a3c:	e8 fc 26 00 00       	call   f010313d <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100a41:	c7 04 24 fc 4a 10 f0 	movl   $0xf0104afc,(%esp)
f0100a48:	e8 f0 26 00 00       	call   f010313d <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100a4d:	c7 04 24 30 4b 10 f0 	movl   $0xf0104b30,(%esp)
f0100a54:	e8 e4 26 00 00       	call   f010313d <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100a59:	c7 04 24 74 4b 10 f0 	movl   $0xf0104b74,(%esp)
f0100a60:	e8 d8 26 00 00       	call   f010313d <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100a65:	c7 04 24 89 47 10 f0 	movl   $0xf0104789,(%esp)
f0100a6c:	e8 cc 26 00 00       	call   f010313d <cprintf>
        cprintf("         set the background color to black\n");
f0100a71:	c7 04 24 b8 4b 10 f0 	movl   $0xf0104bb8,(%esp)
f0100a78:	e8 c0 26 00 00       	call   f010313d <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100a7d:	c7 04 24 e4 4b 10 f0 	movl   $0xf0104be4,(%esp)
f0100a84:	e8 b4 26 00 00       	call   f010313d <cprintf>
f0100a89:	83 c4 10             	add    $0x10,%esp
f0100a8c:	eb 52                	jmp    f0100ae0 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100a8e:	83 ec 0c             	sub    $0xc,%esp
f0100a91:	ff 73 04             	pushl  0x4(%ebx)
f0100a94:	e8 ab 33 00 00       	call   f0103e44 <strlen>
f0100a99:	83 c4 10             	add    $0x10,%esp
f0100a9c:	48                   	dec    %eax
f0100a9d:	78 26                	js     f0100ac5 <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f0100a9f:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100aa2:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100aa7:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f0100aac:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f0100ab0:	0f 94 c3             	sete   %bl
f0100ab3:	0f b6 db             	movzbl %bl,%ebx
f0100ab6:	d3 e3                	shl    %cl,%ebx
f0100ab8:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100aba:	48                   	dec    %eax
f0100abb:	78 0d                	js     f0100aca <mon_setcolor+0xb0>
f0100abd:	41                   	inc    %ecx
f0100abe:	83 f9 08             	cmp    $0x8,%ecx
f0100ac1:	75 e9                	jne    f0100aac <mon_setcolor+0x92>
f0100ac3:	eb 05                	jmp    f0100aca <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100ac5:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f0100aca:	89 15 80 60 1d f0    	mov    %edx,0xf01d6080
        cprintf(" This is color that you want ! \n");
f0100ad0:	83 ec 0c             	sub    $0xc,%esp
f0100ad3:	68 18 4c 10 f0       	push   $0xf0104c18
f0100ad8:	e8 60 26 00 00       	call   f010313d <cprintf>
f0100add:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f0100ae0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ae5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ae8:	5b                   	pop    %ebx
f0100ae9:	5e                   	pop    %esi
f0100aea:	c9                   	leave  
f0100aeb:	c3                   	ret    

f0100aec <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f0100aec:	55                   	push   %ebp
f0100aed:	89 e5                	mov    %esp,%ebp
f0100aef:	57                   	push   %edi
f0100af0:	56                   	push   %esi
f0100af1:	53                   	push   %ebx
f0100af2:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100af5:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100af7:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100af9:	85 c0                	test   %eax,%eax
f0100afb:	74 6d                	je     f0100b6a <mon_backtrace+0x7e>
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100afd:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
f0100b00:	8b 5e 04             	mov    0x4(%esi),%ebx
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100b03:	ff 76 18             	pushl  0x18(%esi)
f0100b06:	ff 76 14             	pushl  0x14(%esi)
f0100b09:	ff 76 10             	pushl  0x10(%esi)
f0100b0c:	ff 76 0c             	pushl  0xc(%esi)
f0100b0f:	ff 76 08             	pushl  0x8(%esi)
f0100b12:	53                   	push   %ebx
f0100b13:	56                   	push   %esi
f0100b14:	68 3c 4c 10 f0       	push   $0xf0104c3c
f0100b19:	e8 1f 26 00 00       	call   f010313d <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b1e:	83 c4 18             	add    $0x18,%esp
f0100b21:	57                   	push   %edi
f0100b22:	ff 76 04             	pushl  0x4(%esi)
f0100b25:	e8 f3 2a 00 00       	call   f010361d <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100b2a:	83 c4 0c             	add    $0xc,%esp
f0100b2d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100b30:	ff 75 d0             	pushl  -0x30(%ebp)
f0100b33:	68 a5 47 10 f0       	push   $0xf01047a5
f0100b38:	e8 00 26 00 00       	call   f010313d <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100b3d:	83 c4 0c             	add    $0xc,%esp
f0100b40:	ff 75 d8             	pushl  -0x28(%ebp)
f0100b43:	ff 75 dc             	pushl  -0x24(%ebp)
f0100b46:	68 b5 47 10 f0       	push   $0xf01047b5
f0100b4b:	e8 ed 25 00 00       	call   f010313d <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100b50:	83 c4 08             	add    $0x8,%esp
f0100b53:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100b56:	53                   	push   %ebx
f0100b57:	68 ba 47 10 f0       	push   $0xf01047ba
f0100b5c:	e8 dc 25 00 00       	call   f010313d <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100b61:	8b 36                	mov    (%esi),%esi
f0100b63:	83 c4 10             	add    $0x10,%esp
f0100b66:	85 f6                	test   %esi,%esi
f0100b68:	75 96                	jne    f0100b00 <mon_backtrace+0x14>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100b6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b72:	5b                   	pop    %ebx
f0100b73:	5e                   	pop    %esi
f0100b74:	5f                   	pop    %edi
f0100b75:	c9                   	leave  
f0100b76:	c3                   	ret    

f0100b77 <pa_con>:
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
f0100b77:	55                   	push   %ebp
f0100b78:	89 e5                	mov    %esp,%ebp
f0100b7a:	53                   	push   %ebx
f0100b7b:	83 ec 04             	sub    $0x4,%esp
f0100b7e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
f0100b84:	8b 15 8c 6f 1d f0    	mov    0xf01d6f8c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100b8a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100b90:	77 15                	ja     f0100ba7 <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b92:	52                   	push   %edx
f0100b93:	68 74 4c 10 f0       	push   $0xf0104c74
f0100b98:	68 93 00 00 00       	push   $0x93
f0100b9d:	68 bf 47 10 f0       	push   $0xf01047bf
f0100ba2:	e8 fe f4 ff ff       	call   f01000a5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100ba7:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100bad:	39 d0                	cmp    %edx,%eax
f0100baf:	72 18                	jb     f0100bc9 <pa_con+0x52>
f0100bb1:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
f0100bb7:	39 d8                	cmp    %ebx,%eax
f0100bb9:	73 0e                	jae    f0100bc9 <pa_con+0x52>
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
f0100bbb:	29 d0                	sub    %edx,%eax
f0100bbd:	8b 80 00 00 00 ef    	mov    -0x11000000(%eax),%eax
f0100bc3:	89 01                	mov    %eax,(%ecx)
        return true;
f0100bc5:	b0 01                	mov    $0x1,%al
f0100bc7:	eb 56                	jmp    f0100c1f <pa_con+0xa8>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100bc9:	ba 00 70 11 f0       	mov    $0xf0117000,%edx
f0100bce:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100bd4:	77 15                	ja     f0100beb <pa_con+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100bd6:	52                   	push   %edx
f0100bd7:	68 74 4c 10 f0       	push   $0xf0104c74
f0100bdc:	68 98 00 00 00       	push   $0x98
f0100be1:	68 bf 47 10 f0       	push   $0xf01047bf
f0100be6:	e8 ba f4 ff ff       	call   f01000a5 <_panic>
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
f0100beb:	3d 00 70 11 00       	cmp    $0x117000,%eax
f0100bf0:	72 18                	jb     f0100c0a <pa_con+0x93>
f0100bf2:	3d 00 f0 11 00       	cmp    $0x11f000,%eax
f0100bf7:	73 11                	jae    f0100c0a <pa_con+0x93>
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
f0100bf9:	2d 00 70 11 00       	sub    $0x117000,%eax
f0100bfe:	8b 80 00 80 ff ef    	mov    -0x10008000(%eax),%eax
f0100c04:	89 01                	mov    %eax,(%ecx)
        return true;
f0100c06:	b0 01                	mov    $0x1,%al
f0100c08:	eb 15                	jmp    f0100c1f <pa_con+0xa8>
    }
    if (addr < -KERNBASE) {
f0100c0a:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100c0f:	77 0c                	ja     f0100c1d <pa_con+0xa6>
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
f0100c11:	8b 80 00 00 00 f0    	mov    -0x10000000(%eax),%eax
f0100c17:	89 01                	mov    %eax,(%ecx)
        return true;
f0100c19:	b0 01                	mov    $0x1,%al
f0100c1b:	eb 02                	jmp    f0100c1f <pa_con+0xa8>
    }
    // Not in virtual memory mapped.
    return false;
f0100c1d:	b0 00                	mov    $0x0,%al
}
f0100c1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c22:	c9                   	leave  
f0100c23:	c3                   	ret    

f0100c24 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
f0100c24:	55                   	push   %ebp
f0100c25:	89 e5                	mov    %esp,%ebp
f0100c27:	57                   	push   %edi
f0100c28:	56                   	push   %esi
f0100c29:	53                   	push   %ebx
f0100c2a:	83 ec 2c             	sub    $0x2c,%esp
f0100c2d:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 4) {
f0100c30:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100c34:	74 2d                	je     f0100c63 <mon_dump+0x3f>
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
f0100c36:	83 ec 0c             	sub    $0xc,%esp
f0100c39:	68 98 4c 10 f0       	push   $0xf0104c98
f0100c3e:	e8 fa 24 00 00       	call   f010313d <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100c43:	c7 04 24 c8 4c 10 f0 	movl   $0xf0104cc8,(%esp)
f0100c4a:	e8 ee 24 00 00       	call   f010313d <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100c4f:	c7 04 24 f0 4c 10 f0 	movl   $0xf0104cf0,(%esp)
f0100c56:	e8 e2 24 00 00       	call   f010313d <cprintf>
f0100c5b:	83 c4 10             	add    $0x10,%esp
f0100c5e:	e9 59 01 00 00       	jmp    f0100dbc <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100c63:	83 ec 04             	sub    $0x4,%esp
f0100c66:	6a 00                	push   $0x0
f0100c68:	6a 00                	push   $0x0
f0100c6a:	ff 76 08             	pushl  0x8(%esi)
f0100c6d:	e8 d4 34 00 00       	call   f0104146 <strtol>
f0100c72:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100c74:	83 c4 0c             	add    $0xc,%esp
f0100c77:	6a 00                	push   $0x0
f0100c79:	6a 00                	push   $0x0
f0100c7b:	ff 76 0c             	pushl  0xc(%esi)
f0100c7e:	e8 c3 34 00 00       	call   f0104146 <strtol>
        if (laddr > haddr) {
f0100c83:	83 c4 10             	add    $0x10,%esp
f0100c86:	39 c3                	cmp    %eax,%ebx
f0100c88:	76 01                	jbe    f0100c8b <mon_dump+0x67>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100c8a:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, 4);
f0100c8b:	89 df                	mov    %ebx,%edi
f0100c8d:	83 e7 fc             	and    $0xfffffffc,%edi
        haddr = ROUNDDOWN(haddr, 4);
f0100c90:	83 e0 fc             	and    $0xfffffffc,%eax
f0100c93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if (argv[1][0] == 'v') {
f0100c96:	8b 46 04             	mov    0x4(%esi),%eax
f0100c99:	80 38 76             	cmpb   $0x76,(%eax)
f0100c9c:	74 0e                	je     f0100cac <mon_dump+0x88>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100c9e:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100ca1:	0f 85 98 00 00 00    	jne    f0100d3f <mon_dump+0x11b>
f0100ca7:	e9 00 01 00 00       	jmp    f0100dac <mon_dump+0x188>
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100cac:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100caf:	74 7c                	je     f0100d2d <mon_dump+0x109>
f0100cb1:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100cb3:	39 fb                	cmp    %edi,%ebx
f0100cb5:	74 15                	je     f0100ccc <mon_dump+0xa8>
f0100cb7:	f6 c3 0f             	test   $0xf,%bl
f0100cba:	75 21                	jne    f0100cdd <mon_dump+0xb9>
                    if (now != laddr) cprintf("\n"); 
f0100cbc:	83 ec 0c             	sub    $0xc,%esp
f0100cbf:	68 45 47 10 f0       	push   $0xf0104745
f0100cc4:	e8 74 24 00 00       	call   f010313d <cprintf>
f0100cc9:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100ccc:	83 ec 08             	sub    $0x8,%esp
f0100ccf:	53                   	push   %ebx
f0100cd0:	68 ce 47 10 f0       	push   $0xf01047ce
f0100cd5:	e8 63 24 00 00       	call   f010313d <cprintf>
f0100cda:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100cdd:	83 ec 04             	sub    $0x4,%esp
f0100ce0:	6a 00                	push   $0x0
f0100ce2:	89 d8                	mov    %ebx,%eax
f0100ce4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ce9:	50                   	push   %eax
f0100cea:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0100cf0:	e8 01 07 00 00       	call   f01013f6 <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100cf5:	83 c4 10             	add    $0x10,%esp
f0100cf8:	85 c0                	test   %eax,%eax
f0100cfa:	74 19                	je     f0100d15 <mon_dump+0xf1>
f0100cfc:	f6 00 01             	testb  $0x1,(%eax)
f0100cff:	74 14                	je     f0100d15 <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100d01:	83 ec 08             	sub    $0x8,%esp
f0100d04:	ff 33                	pushl  (%ebx)
f0100d06:	68 d8 47 10 f0       	push   $0xf01047d8
f0100d0b:	e8 2d 24 00 00       	call   f010313d <cprintf>
f0100d10:	83 c4 10             	add    $0x10,%esp
f0100d13:	eb 10                	jmp    f0100d25 <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100d15:	83 ec 0c             	sub    $0xc,%esp
f0100d18:	68 e3 47 10 f0       	push   $0xf01047e3
f0100d1d:	e8 1b 24 00 00       	call   f010313d <cprintf>
f0100d22:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100d25:	83 c3 04             	add    $0x4,%ebx
f0100d28:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100d2b:	75 86                	jne    f0100cb3 <mon_dump+0x8f>
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
f0100d2d:	83 ec 0c             	sub    $0xc,%esp
f0100d30:	68 45 47 10 f0       	push   $0xf0104745
f0100d35:	e8 03 24 00 00       	call   f010313d <cprintf>
f0100d3a:	83 c4 10             	add    $0x10,%esp
f0100d3d:	eb 7d                	jmp    f0100dbc <mon_dump+0x198>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100d3f:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100d41:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100d44:	39 fb                	cmp    %edi,%ebx
f0100d46:	74 15                	je     f0100d5d <mon_dump+0x139>
f0100d48:	f6 c3 0f             	test   $0xf,%bl
f0100d4b:	75 21                	jne    f0100d6e <mon_dump+0x14a>
                    if (now != laddr) cprintf("\n");
f0100d4d:	83 ec 0c             	sub    $0xc,%esp
f0100d50:	68 45 47 10 f0       	push   $0xf0104745
f0100d55:	e8 e3 23 00 00       	call   f010313d <cprintf>
f0100d5a:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100d5d:	83 ec 08             	sub    $0x8,%esp
f0100d60:	53                   	push   %ebx
f0100d61:	68 ce 47 10 f0       	push   $0xf01047ce
f0100d66:	e8 d2 23 00 00       	call   f010313d <cprintf>
f0100d6b:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f0100d6e:	83 ec 08             	sub    $0x8,%esp
f0100d71:	56                   	push   %esi
f0100d72:	53                   	push   %ebx
f0100d73:	e8 ff fd ff ff       	call   f0100b77 <pa_con>
f0100d78:	83 c4 10             	add    $0x10,%esp
f0100d7b:	84 c0                	test   %al,%al
f0100d7d:	74 15                	je     f0100d94 <mon_dump+0x170>
                    cprintf("0x%08x  ", value);
f0100d7f:	83 ec 08             	sub    $0x8,%esp
f0100d82:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d85:	68 d8 47 10 f0       	push   $0xf01047d8
f0100d8a:	e8 ae 23 00 00       	call   f010313d <cprintf>
f0100d8f:	83 c4 10             	add    $0x10,%esp
f0100d92:	eb 10                	jmp    f0100da4 <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100d94:	83 ec 0c             	sub    $0xc,%esp
f0100d97:	68 e1 47 10 f0       	push   $0xf01047e1
f0100d9c:	e8 9c 23 00 00       	call   f010313d <cprintf>
f0100da1:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100da4:	83 c3 04             	add    $0x4,%ebx
f0100da7:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100daa:	75 98                	jne    f0100d44 <mon_dump+0x120>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f0100dac:	83 ec 0c             	sub    $0xc,%esp
f0100daf:	68 45 47 10 f0       	push   $0xf0104745
f0100db4:	e8 84 23 00 00       	call   f010313d <cprintf>
f0100db9:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100dbc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dc4:	5b                   	pop    %ebx
f0100dc5:	5e                   	pop    %esi
f0100dc6:	5f                   	pop    %edi
f0100dc7:	c9                   	leave  
f0100dc8:	c3                   	ret    

f0100dc9 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100dc9:	55                   	push   %ebp
f0100dca:	89 e5                	mov    %esp,%ebp
f0100dcc:	57                   	push   %edi
f0100dcd:	56                   	push   %esi
f0100dce:	53                   	push   %ebx
f0100dcf:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100dd2:	68 34 4d 10 f0       	push   $0xf0104d34
f0100dd7:	e8 61 23 00 00       	call   f010313d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100ddc:	c7 04 24 58 4d 10 f0 	movl   $0xf0104d58,(%esp)
f0100de3:	e8 55 23 00 00       	call   f010313d <cprintf>

	if (tf != NULL)
f0100de8:	83 c4 10             	add    $0x10,%esp
f0100deb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100def:	74 0e                	je     f0100dff <monitor+0x36>
		print_trapframe(tf);
f0100df1:	83 ec 0c             	sub    $0xc,%esp
f0100df4:	ff 75 08             	pushl  0x8(%ebp)
f0100df7:	e8 4d 24 00 00       	call   f0103249 <print_trapframe>
f0100dfc:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100dff:	83 ec 0c             	sub    $0xc,%esp
f0100e02:	68 ee 47 10 f0       	push   $0xf01047ee
f0100e07:	e8 68 2f 00 00       	call   f0103d74 <readline>
f0100e0c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100e0e:	83 c4 10             	add    $0x10,%esp
f0100e11:	85 c0                	test   %eax,%eax
f0100e13:	74 ea                	je     f0100dff <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100e15:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100e1c:	be 00 00 00 00       	mov    $0x0,%esi
f0100e21:	eb 04                	jmp    f0100e27 <monitor+0x5e>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100e23:	c6 03 00             	movb   $0x0,(%ebx)
f0100e26:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100e27:	8a 03                	mov    (%ebx),%al
f0100e29:	84 c0                	test   %al,%al
f0100e2b:	74 64                	je     f0100e91 <monitor+0xc8>
f0100e2d:	83 ec 08             	sub    $0x8,%esp
f0100e30:	0f be c0             	movsbl %al,%eax
f0100e33:	50                   	push   %eax
f0100e34:	68 f2 47 10 f0       	push   $0xf01047f2
f0100e39:	e8 7f 31 00 00       	call   f0103fbd <strchr>
f0100e3e:	83 c4 10             	add    $0x10,%esp
f0100e41:	85 c0                	test   %eax,%eax
f0100e43:	75 de                	jne    f0100e23 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100e45:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100e48:	74 47                	je     f0100e91 <monitor+0xc8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100e4a:	83 fe 0f             	cmp    $0xf,%esi
f0100e4d:	75 14                	jne    f0100e63 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100e4f:	83 ec 08             	sub    $0x8,%esp
f0100e52:	6a 10                	push   $0x10
f0100e54:	68 f7 47 10 f0       	push   $0xf01047f7
f0100e59:	e8 df 22 00 00       	call   f010313d <cprintf>
f0100e5e:	83 c4 10             	add    $0x10,%esp
f0100e61:	eb 9c                	jmp    f0100dff <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100e63:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100e67:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e68:	8a 03                	mov    (%ebx),%al
f0100e6a:	84 c0                	test   %al,%al
f0100e6c:	75 09                	jne    f0100e77 <monitor+0xae>
f0100e6e:	eb b7                	jmp    f0100e27 <monitor+0x5e>
			buf++;
f0100e70:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e71:	8a 03                	mov    (%ebx),%al
f0100e73:	84 c0                	test   %al,%al
f0100e75:	74 b0                	je     f0100e27 <monitor+0x5e>
f0100e77:	83 ec 08             	sub    $0x8,%esp
f0100e7a:	0f be c0             	movsbl %al,%eax
f0100e7d:	50                   	push   %eax
f0100e7e:	68 f2 47 10 f0       	push   $0xf01047f2
f0100e83:	e8 35 31 00 00       	call   f0103fbd <strchr>
f0100e88:	83 c4 10             	add    $0x10,%esp
f0100e8b:	85 c0                	test   %eax,%eax
f0100e8d:	74 e1                	je     f0100e70 <monitor+0xa7>
f0100e8f:	eb 96                	jmp    f0100e27 <monitor+0x5e>
			buf++;
	}
	argv[argc] = 0;
f0100e91:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100e98:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100e99:	85 f6                	test   %esi,%esi
f0100e9b:	0f 84 5e ff ff ff    	je     f0100dff <monitor+0x36>
f0100ea1:	bb e0 4d 10 f0       	mov    $0xf0104de0,%ebx
f0100ea6:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100eab:	83 ec 08             	sub    $0x8,%esp
f0100eae:	ff 33                	pushl  (%ebx)
f0100eb0:	ff 75 a8             	pushl  -0x58(%ebp)
f0100eb3:	e8 97 30 00 00       	call   f0103f4f <strcmp>
f0100eb8:	83 c4 10             	add    $0x10,%esp
f0100ebb:	85 c0                	test   %eax,%eax
f0100ebd:	75 20                	jne    f0100edf <monitor+0x116>
			return commands[i].func(argc, argv, tf);
f0100ebf:	83 ec 04             	sub    $0x4,%esp
f0100ec2:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100ec5:	ff 75 08             	pushl  0x8(%ebp)
f0100ec8:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100ecb:	50                   	push   %eax
f0100ecc:	56                   	push   %esi
f0100ecd:	ff 97 e8 4d 10 f0    	call   *-0xfefb218(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ed3:	83 c4 10             	add    $0x10,%esp
f0100ed6:	85 c0                	test   %eax,%eax
f0100ed8:	78 26                	js     f0100f00 <monitor+0x137>
f0100eda:	e9 20 ff ff ff       	jmp    f0100dff <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100edf:	47                   	inc    %edi
f0100ee0:	83 c3 0c             	add    $0xc,%ebx
f0100ee3:	83 ff 07             	cmp    $0x7,%edi
f0100ee6:	75 c3                	jne    f0100eab <monitor+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ee8:	83 ec 08             	sub    $0x8,%esp
f0100eeb:	ff 75 a8             	pushl  -0x58(%ebp)
f0100eee:	68 14 48 10 f0       	push   $0xf0104814
f0100ef3:	e8 45 22 00 00       	call   f010313d <cprintf>
f0100ef8:	83 c4 10             	add    $0x10,%esp
f0100efb:	e9 ff fe ff ff       	jmp    f0100dff <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f03:	5b                   	pop    %ebx
f0100f04:	5e                   	pop    %esi
f0100f05:	5f                   	pop    %edi
f0100f06:	c9                   	leave  
f0100f07:	c3                   	ret    

f0100f08 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f08:	55                   	push   %ebp
f0100f09:	89 e5                	mov    %esp,%ebp
f0100f0b:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100f0d:	83 3d b0 62 1d f0 00 	cmpl   $0x0,0xf01d62b0
f0100f14:	75 0f                	jne    f0100f25 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100f16:	b8 8f 7f 1d f0       	mov    $0xf01d7f8f,%eax
f0100f1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f20:	a3 b0 62 1d f0       	mov    %eax,0xf01d62b0
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0100f25:	a1 b0 62 1d f0       	mov    0xf01d62b0,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100f2a:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100f31:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f37:	89 15 b0 62 1d f0    	mov    %edx,0xf01d62b0

	return result;
}
f0100f3d:	c9                   	leave  
f0100f3e:	c3                   	ret    

f0100f3f <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100f3f:	55                   	push   %ebp
f0100f40:	89 e5                	mov    %esp,%ebp
f0100f42:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100f45:	89 d1                	mov    %edx,%ecx
f0100f47:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100f4a:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100f4d:	a8 01                	test   $0x1,%al
f0100f4f:	74 42                	je     f0100f93 <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100f51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f56:	89 c1                	mov    %eax,%ecx
f0100f58:	c1 e9 0c             	shr    $0xc,%ecx
f0100f5b:	3b 0d 84 6f 1d f0    	cmp    0xf01d6f84,%ecx
f0100f61:	72 15                	jb     f0100f78 <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f63:	50                   	push   %eax
f0100f64:	68 34 4e 10 f0       	push   $0xf0104e34
f0100f69:	68 04 03 00 00       	push   $0x304
f0100f6e:	68 95 55 10 f0       	push   $0xf0105595
f0100f73:	e8 2d f1 ff ff       	call   f01000a5 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100f78:	c1 ea 0c             	shr    $0xc,%edx
f0100f7b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100f81:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100f88:	a8 01                	test   $0x1,%al
f0100f8a:	74 0e                	je     f0100f9a <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100f8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f91:	eb 0c                	jmp    f0100f9f <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100f93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f98:	eb 05                	jmp    f0100f9f <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100f9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100f9f:	c9                   	leave  
f0100fa0:	c3                   	ret    

f0100fa1 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100fa1:	55                   	push   %ebp
f0100fa2:	89 e5                	mov    %esp,%ebp
f0100fa4:	56                   	push   %esi
f0100fa5:	53                   	push   %ebx
f0100fa6:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100fa8:	83 ec 0c             	sub    $0xc,%esp
f0100fab:	50                   	push   %eax
f0100fac:	e8 2b 21 00 00       	call   f01030dc <mc146818_read>
f0100fb1:	89 c6                	mov    %eax,%esi
f0100fb3:	43                   	inc    %ebx
f0100fb4:	89 1c 24             	mov    %ebx,(%esp)
f0100fb7:	e8 20 21 00 00       	call   f01030dc <mc146818_read>
f0100fbc:	c1 e0 08             	shl    $0x8,%eax
f0100fbf:	09 f0                	or     %esi,%eax
}
f0100fc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fc4:	5b                   	pop    %ebx
f0100fc5:	5e                   	pop    %esi
f0100fc6:	c9                   	leave  
f0100fc7:	c3                   	ret    

f0100fc8 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100fc8:	55                   	push   %ebp
f0100fc9:	89 e5                	mov    %esp,%ebp
f0100fcb:	57                   	push   %edi
f0100fcc:	56                   	push   %esi
f0100fcd:	53                   	push   %ebx
f0100fce:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fd1:	3c 01                	cmp    $0x1,%al
f0100fd3:	19 f6                	sbb    %esi,%esi
f0100fd5:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100fdb:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100fdc:	8b 1d ac 62 1d f0    	mov    0xf01d62ac,%ebx
f0100fe2:	85 db                	test   %ebx,%ebx
f0100fe4:	75 17                	jne    f0100ffd <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f0100fe6:	83 ec 04             	sub    $0x4,%esp
f0100fe9:	68 58 4e 10 f0       	push   $0xf0104e58
f0100fee:	68 42 02 00 00       	push   $0x242
f0100ff3:	68 95 55 10 f0       	push   $0xf0105595
f0100ff8:	e8 a8 f0 ff ff       	call   f01000a5 <_panic>

	if (only_low_memory) {
f0100ffd:	84 c0                	test   %al,%al
f0100fff:	74 50                	je     f0101051 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101001:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101004:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101007:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010100a:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010100d:	89 d8                	mov    %ebx,%eax
f010100f:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f0101015:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101018:	c1 e8 16             	shr    $0x16,%eax
f010101b:	39 c6                	cmp    %eax,%esi
f010101d:	0f 96 c0             	setbe  %al
f0101020:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101023:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0101027:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101029:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010102d:	8b 1b                	mov    (%ebx),%ebx
f010102f:	85 db                	test   %ebx,%ebx
f0101031:	75 da                	jne    f010100d <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101033:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101036:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010103c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010103f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101042:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101044:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101047:	89 1d ac 62 1d f0    	mov    %ebx,0xf01d62ac
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010104d:	85 db                	test   %ebx,%ebx
f010104f:	74 57                	je     f01010a8 <check_page_free_list+0xe0>
f0101051:	89 d8                	mov    %ebx,%eax
f0101053:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f0101059:	c1 f8 03             	sar    $0x3,%eax
f010105c:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010105f:	89 c2                	mov    %eax,%edx
f0101061:	c1 ea 16             	shr    $0x16,%edx
f0101064:	39 d6                	cmp    %edx,%esi
f0101066:	76 3a                	jbe    f01010a2 <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101068:	89 c2                	mov    %eax,%edx
f010106a:	c1 ea 0c             	shr    $0xc,%edx
f010106d:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f0101073:	72 12                	jb     f0101087 <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101075:	50                   	push   %eax
f0101076:	68 34 4e 10 f0       	push   $0xf0104e34
f010107b:	6a 56                	push   $0x56
f010107d:	68 a1 55 10 f0       	push   $0xf01055a1
f0101082:	e8 1e f0 ff ff       	call   f01000a5 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101087:	83 ec 04             	sub    $0x4,%esp
f010108a:	68 80 00 00 00       	push   $0x80
f010108f:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101094:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101099:	50                   	push   %eax
f010109a:	e8 6e 2f 00 00       	call   f010400d <memset>
f010109f:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010a2:	8b 1b                	mov    (%ebx),%ebx
f01010a4:	85 db                	test   %ebx,%ebx
f01010a6:	75 a9                	jne    f0101051 <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01010a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01010ad:	e8 56 fe ff ff       	call   f0100f08 <boot_alloc>
f01010b2:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010b5:	8b 15 ac 62 1d f0    	mov    0xf01d62ac,%edx
f01010bb:	85 d2                	test   %edx,%edx
f01010bd:	0f 84 80 01 00 00    	je     f0101243 <check_page_free_list+0x27b>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01010c3:	8b 1d 8c 6f 1d f0    	mov    0xf01d6f8c,%ebx
f01010c9:	39 da                	cmp    %ebx,%edx
f01010cb:	72 43                	jb     f0101110 <check_page_free_list+0x148>
		assert(pp < pages + npages);
f01010cd:	a1 84 6f 1d f0       	mov    0xf01d6f84,%eax
f01010d2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01010d5:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f01010d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01010db:	39 c2                	cmp    %eax,%edx
f01010dd:	73 4f                	jae    f010112e <check_page_free_list+0x166>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010df:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f01010e2:	89 d0                	mov    %edx,%eax
f01010e4:	29 d8                	sub    %ebx,%eax
f01010e6:	a8 07                	test   $0x7,%al
f01010e8:	75 66                	jne    f0101150 <check_page_free_list+0x188>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010ea:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01010ed:	c1 e0 0c             	shl    $0xc,%eax
f01010f0:	74 7f                	je     f0101171 <check_page_free_list+0x1a9>
		assert(page2pa(pp) != IOPHYSMEM);
f01010f2:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010f7:	0f 84 94 00 00 00    	je     f0101191 <check_page_free_list+0x1c9>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01010fd:	be 00 00 00 00       	mov    $0x0,%esi
f0101102:	bf 00 00 00 00       	mov    $0x0,%edi
f0101107:	e9 9e 00 00 00       	jmp    f01011aa <check_page_free_list+0x1e2>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010110c:	39 da                	cmp    %ebx,%edx
f010110e:	73 19                	jae    f0101129 <check_page_free_list+0x161>
f0101110:	68 af 55 10 f0       	push   $0xf01055af
f0101115:	68 bb 55 10 f0       	push   $0xf01055bb
f010111a:	68 5c 02 00 00       	push   $0x25c
f010111f:	68 95 55 10 f0       	push   $0xf0105595
f0101124:	e8 7c ef ff ff       	call   f01000a5 <_panic>
		assert(pp < pages + npages);
f0101129:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f010112c:	72 19                	jb     f0101147 <check_page_free_list+0x17f>
f010112e:	68 d0 55 10 f0       	push   $0xf01055d0
f0101133:	68 bb 55 10 f0       	push   $0xf01055bb
f0101138:	68 5d 02 00 00       	push   $0x25d
f010113d:	68 95 55 10 f0       	push   $0xf0105595
f0101142:	e8 5e ef ff ff       	call   f01000a5 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101147:	89 d0                	mov    %edx,%eax
f0101149:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010114c:	a8 07                	test   $0x7,%al
f010114e:	74 19                	je     f0101169 <check_page_free_list+0x1a1>
f0101150:	68 7c 4e 10 f0       	push   $0xf0104e7c
f0101155:	68 bb 55 10 f0       	push   $0xf01055bb
f010115a:	68 5e 02 00 00       	push   $0x25e
f010115f:	68 95 55 10 f0       	push   $0xf0105595
f0101164:	e8 3c ef ff ff       	call   f01000a5 <_panic>
f0101169:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010116c:	c1 e0 0c             	shl    $0xc,%eax
f010116f:	75 19                	jne    f010118a <check_page_free_list+0x1c2>
f0101171:	68 e4 55 10 f0       	push   $0xf01055e4
f0101176:	68 bb 55 10 f0       	push   $0xf01055bb
f010117b:	68 61 02 00 00       	push   $0x261
f0101180:	68 95 55 10 f0       	push   $0xf0105595
f0101185:	e8 1b ef ff ff       	call   f01000a5 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010118a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010118f:	75 19                	jne    f01011aa <check_page_free_list+0x1e2>
f0101191:	68 f5 55 10 f0       	push   $0xf01055f5
f0101196:	68 bb 55 10 f0       	push   $0xf01055bb
f010119b:	68 62 02 00 00       	push   $0x262
f01011a0:	68 95 55 10 f0       	push   $0xf0105595
f01011a5:	e8 fb ee ff ff       	call   f01000a5 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01011aa:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01011af:	75 19                	jne    f01011ca <check_page_free_list+0x202>
f01011b1:	68 b0 4e 10 f0       	push   $0xf0104eb0
f01011b6:	68 bb 55 10 f0       	push   $0xf01055bb
f01011bb:	68 63 02 00 00       	push   $0x263
f01011c0:	68 95 55 10 f0       	push   $0xf0105595
f01011c5:	e8 db ee ff ff       	call   f01000a5 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01011ca:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01011cf:	75 19                	jne    f01011ea <check_page_free_list+0x222>
f01011d1:	68 0e 56 10 f0       	push   $0xf010560e
f01011d6:	68 bb 55 10 f0       	push   $0xf01055bb
f01011db:	68 64 02 00 00       	push   $0x264
f01011e0:	68 95 55 10 f0       	push   $0xf0105595
f01011e5:	e8 bb ee ff ff       	call   f01000a5 <_panic>
f01011ea:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011ec:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01011f1:	76 3e                	jbe    f0101231 <check_page_free_list+0x269>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011f3:	c1 e8 0c             	shr    $0xc,%eax
f01011f6:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01011f9:	77 12                	ja     f010120d <check_page_free_list+0x245>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011fb:	51                   	push   %ecx
f01011fc:	68 34 4e 10 f0       	push   $0xf0104e34
f0101201:	6a 56                	push   $0x56
f0101203:	68 a1 55 10 f0       	push   $0xf01055a1
f0101208:	e8 98 ee ff ff       	call   f01000a5 <_panic>
	return (void *)(pa + KERNBASE);
f010120d:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101213:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0101216:	76 1c                	jbe    f0101234 <check_page_free_list+0x26c>
f0101218:	68 d4 4e 10 f0       	push   $0xf0104ed4
f010121d:	68 bb 55 10 f0       	push   $0xf01055bb
f0101222:	68 65 02 00 00       	push   $0x265
f0101227:	68 95 55 10 f0       	push   $0xf0105595
f010122c:	e8 74 ee ff ff       	call   f01000a5 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101231:	47                   	inc    %edi
f0101232:	eb 01                	jmp    f0101235 <check_page_free_list+0x26d>
		else
			++nfree_extmem;
f0101234:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101235:	8b 12                	mov    (%edx),%edx
f0101237:	85 d2                	test   %edx,%edx
f0101239:	0f 85 cd fe ff ff    	jne    f010110c <check_page_free_list+0x144>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010123f:	85 ff                	test   %edi,%edi
f0101241:	7f 19                	jg     f010125c <check_page_free_list+0x294>
f0101243:	68 28 56 10 f0       	push   $0xf0105628
f0101248:	68 bb 55 10 f0       	push   $0xf01055bb
f010124d:	68 6d 02 00 00       	push   $0x26d
f0101252:	68 95 55 10 f0       	push   $0xf0105595
f0101257:	e8 49 ee ff ff       	call   f01000a5 <_panic>
	assert(nfree_extmem > 0);
f010125c:	85 f6                	test   %esi,%esi
f010125e:	7f 19                	jg     f0101279 <check_page_free_list+0x2b1>
f0101260:	68 3a 56 10 f0       	push   $0xf010563a
f0101265:	68 bb 55 10 f0       	push   $0xf01055bb
f010126a:	68 6e 02 00 00       	push   $0x26e
f010126f:	68 95 55 10 f0       	push   $0xf0105595
f0101274:	e8 2c ee ff ff       	call   f01000a5 <_panic>
}
f0101279:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010127c:	5b                   	pop    %ebx
f010127d:	5e                   	pop    %esi
f010127e:	5f                   	pop    %edi
f010127f:	c9                   	leave  
f0101280:	c3                   	ret    

f0101281 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101281:	55                   	push   %ebp
f0101282:	89 e5                	mov    %esp,%ebp
f0101284:	56                   	push   %esi
f0101285:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f0101286:	c7 05 ac 62 1d f0 00 	movl   $0x0,0xf01d62ac
f010128d:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f0101290:	b8 00 00 00 00       	mov    $0x0,%eax
f0101295:	e8 6e fc ff ff       	call   f0100f08 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010129a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010129f:	77 15                	ja     f01012b6 <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012a1:	50                   	push   %eax
f01012a2:	68 74 4c 10 f0       	push   $0xf0104c74
f01012a7:	68 1e 01 00 00       	push   $0x11e
f01012ac:	68 95 55 10 f0       	push   $0xf0105595
f01012b1:	e8 ef ed ff ff       	call   f01000a5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01012b6:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f01012bc:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f01012bf:	83 3d 84 6f 1d f0 00 	cmpl   $0x0,0xf01d6f84
f01012c6:	74 5f                	je     f0101327 <page_init+0xa6>
f01012c8:	8b 1d ac 62 1d f0    	mov    0xf01d62ac,%ebx
f01012ce:	ba 00 00 00 00       	mov    $0x0,%edx
f01012d3:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f01012d8:	85 c0                	test   %eax,%eax
f01012da:	74 25                	je     f0101301 <page_init+0x80>
f01012dc:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f01012e1:	76 04                	jbe    f01012e7 <page_init+0x66>
f01012e3:	39 c6                	cmp    %eax,%esi
f01012e5:	77 1a                	ja     f0101301 <page_init+0x80>
		    pages[i].pp_ref = 0;
f01012e7:	89 d1                	mov    %edx,%ecx
f01012e9:	03 0d 8c 6f 1d f0    	add    0xf01d6f8c,%ecx
f01012ef:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f01012f5:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f01012f7:	89 d3                	mov    %edx,%ebx
f01012f9:	03 1d 8c 6f 1d f0    	add    0xf01d6f8c,%ebx
f01012ff:	eb 14                	jmp    f0101315 <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f0101301:	89 d1                	mov    %edx,%ecx
f0101303:	03 0d 8c 6f 1d f0    	add    0xf01d6f8c,%ecx
f0101309:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f010130f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// free pages!
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    for (i = 0; i < npages; i++) {
f0101315:	40                   	inc    %eax
f0101316:	83 c2 08             	add    $0x8,%edx
f0101319:	39 05 84 6f 1d f0    	cmp    %eax,0xf01d6f84
f010131f:	77 b7                	ja     f01012d8 <page_init+0x57>
f0101321:	89 1d ac 62 1d f0    	mov    %ebx,0xf01d62ac
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f0101327:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010132a:	5b                   	pop    %ebx
f010132b:	5e                   	pop    %esi
f010132c:	c9                   	leave  
f010132d:	c3                   	ret    

f010132e <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f010132e:	55                   	push   %ebp
f010132f:	89 e5                	mov    %esp,%ebp
f0101331:	53                   	push   %ebx
f0101332:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f0101335:	8b 1d ac 62 1d f0    	mov    0xf01d62ac,%ebx
f010133b:	85 db                	test   %ebx,%ebx
f010133d:	74 63                	je     f01013a2 <page_alloc+0x74>
f010133f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101344:	74 63                	je     f01013a9 <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f0101346:	8b 1b                	mov    (%ebx),%ebx
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f0101348:	85 db                	test   %ebx,%ebx
f010134a:	75 08                	jne    f0101354 <page_alloc+0x26>
f010134c:	89 1d ac 62 1d f0    	mov    %ebx,0xf01d62ac
f0101352:	eb 4e                	jmp    f01013a2 <page_alloc+0x74>
f0101354:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101359:	75 eb                	jne    f0101346 <page_alloc+0x18>
f010135b:	eb 4c                	jmp    f01013a9 <page_alloc+0x7b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010135d:	89 d8                	mov    %ebx,%eax
f010135f:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f0101365:	c1 f8 03             	sar    $0x3,%eax
f0101368:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010136b:	89 c2                	mov    %eax,%edx
f010136d:	c1 ea 0c             	shr    $0xc,%edx
f0101370:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f0101376:	72 12                	jb     f010138a <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101378:	50                   	push   %eax
f0101379:	68 34 4e 10 f0       	push   $0xf0104e34
f010137e:	6a 56                	push   $0x56
f0101380:	68 a1 55 10 f0       	push   $0xf01055a1
f0101385:	e8 1b ed ff ff       	call   f01000a5 <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f010138a:	83 ec 04             	sub    $0x4,%esp
f010138d:	68 00 10 00 00       	push   $0x1000
f0101392:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101394:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101399:	50                   	push   %eax
f010139a:	e8 6e 2c 00 00       	call   f010400d <memset>
f010139f:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f01013a2:	89 d8                	mov    %ebx,%eax
f01013a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013a7:	c9                   	leave  
f01013a8:	c3                   	ret    
        page_free_list = page_free_list->pp_link;
    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f01013a9:	8b 03                	mov    (%ebx),%eax
f01013ab:	a3 ac 62 1d f0       	mov    %eax,0xf01d62ac
        if (alloc_flags & ALLOC_ZERO) {
f01013b0:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01013b4:	74 ec                	je     f01013a2 <page_alloc+0x74>
f01013b6:	eb a5                	jmp    f010135d <page_alloc+0x2f>

f01013b8 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01013b8:	55                   	push   %ebp
f01013b9:	89 e5                	mov    %esp,%ebp
f01013bb:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f01013be:	85 c0                	test   %eax,%eax
f01013c0:	74 14                	je     f01013d6 <page_free+0x1e>
f01013c2:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01013c7:	75 0d                	jne    f01013d6 <page_free+0x1e>
    pp->pp_link = page_free_list;
f01013c9:	8b 15 ac 62 1d f0    	mov    0xf01d62ac,%edx
f01013cf:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f01013d1:	a3 ac 62 1d f0       	mov    %eax,0xf01d62ac
}
f01013d6:	c9                   	leave  
f01013d7:	c3                   	ret    

f01013d8 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01013d8:	55                   	push   %ebp
f01013d9:	89 e5                	mov    %esp,%ebp
f01013db:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01013de:	8b 50 04             	mov    0x4(%eax),%edx
f01013e1:	4a                   	dec    %edx
f01013e2:	66 89 50 04          	mov    %dx,0x4(%eax)
f01013e6:	66 85 d2             	test   %dx,%dx
f01013e9:	75 09                	jne    f01013f4 <page_decref+0x1c>
		page_free(pp);
f01013eb:	50                   	push   %eax
f01013ec:	e8 c7 ff ff ff       	call   f01013b8 <page_free>
f01013f1:	83 c4 04             	add    $0x4,%esp
}
f01013f4:	c9                   	leave  
f01013f5:	c3                   	ret    

f01013f6 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01013f6:	55                   	push   %ebp
f01013f7:	89 e5                	mov    %esp,%ebp
f01013f9:	56                   	push   %esi
f01013fa:	53                   	push   %ebx
f01013fb:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f01013fe:	89 f3                	mov    %esi,%ebx
f0101400:	c1 eb 16             	shr    $0x16,%ebx
f0101403:	c1 e3 02             	shl    $0x2,%ebx
f0101406:	03 5d 08             	add    0x8(%ebp),%ebx
f0101409:	8b 03                	mov    (%ebx),%eax
f010140b:	85 c0                	test   %eax,%eax
f010140d:	74 04                	je     f0101413 <pgdir_walk+0x1d>
f010140f:	a8 01                	test   $0x1,%al
f0101411:	75 2c                	jne    f010143f <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f0101413:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101417:	74 61                	je     f010147a <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(1);
f0101419:	83 ec 0c             	sub    $0xc,%esp
f010141c:	6a 01                	push   $0x1
f010141e:	e8 0b ff ff ff       	call   f010132e <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f0101423:	83 c4 10             	add    $0x10,%esp
f0101426:	85 c0                	test   %eax,%eax
f0101428:	74 57                	je     f0101481 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f010142a:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010142e:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f0101434:	c1 f8 03             	sar    $0x3,%eax
f0101437:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f010143a:	83 c8 07             	or     $0x7,%eax
f010143d:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f010143f:	8b 03                	mov    (%ebx),%eax
f0101441:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101446:	89 c2                	mov    %eax,%edx
f0101448:	c1 ea 0c             	shr    $0xc,%edx
f010144b:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f0101451:	72 15                	jb     f0101468 <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101453:	50                   	push   %eax
f0101454:	68 34 4e 10 f0       	push   $0xf0104e34
f0101459:	68 81 01 00 00       	push   $0x181
f010145e:	68 95 55 10 f0       	push   $0xf0105595
f0101463:	e8 3d ec ff ff       	call   f01000a5 <_panic>
f0101468:	c1 ee 0a             	shr    $0xa,%esi
f010146b:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101471:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101478:	eb 0c                	jmp    f0101486 <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f010147a:	b8 00 00 00 00       	mov    $0x0,%eax
f010147f:	eb 05                	jmp    f0101486 <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f0101481:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f0101486:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101489:	5b                   	pop    %ebx
f010148a:	5e                   	pop    %esi
f010148b:	c9                   	leave  
f010148c:	c3                   	ret    

f010148d <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010148d:	55                   	push   %ebp
f010148e:	89 e5                	mov    %esp,%ebp
f0101490:	57                   	push   %edi
f0101491:	56                   	push   %esi
f0101492:	53                   	push   %ebx
f0101493:	83 ec 1c             	sub    $0x1c,%esp
f0101496:	89 c7                	mov    %eax,%edi
f0101498:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f010149b:	01 d1                	add    %edx,%ecx
f010149d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01014a0:	39 ca                	cmp    %ecx,%edx
f01014a2:	74 32                	je     f01014d6 <boot_map_region+0x49>
f01014a4:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f01014a6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014a9:	83 c8 01             	or     $0x1,%eax
f01014ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f01014af:	83 ec 04             	sub    $0x4,%esp
f01014b2:	6a 01                	push   $0x1
f01014b4:	53                   	push   %ebx
f01014b5:	57                   	push   %edi
f01014b6:	e8 3b ff ff ff       	call   f01013f6 <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f01014bb:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01014be:	09 f2                	or     %esi,%edx
f01014c0:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f01014c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01014c8:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01014ce:	83 c4 10             	add    $0x10,%esp
f01014d1:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01014d4:	75 d9                	jne    f01014af <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f01014d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014d9:	5b                   	pop    %ebx
f01014da:	5e                   	pop    %esi
f01014db:	5f                   	pop    %edi
f01014dc:	c9                   	leave  
f01014dd:	c3                   	ret    

f01014de <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01014de:	55                   	push   %ebp
f01014df:	89 e5                	mov    %esp,%ebp
f01014e1:	53                   	push   %ebx
f01014e2:	83 ec 08             	sub    $0x8,%esp
f01014e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f01014e8:	6a 00                	push   $0x0
f01014ea:	ff 75 0c             	pushl  0xc(%ebp)
f01014ed:	ff 75 08             	pushl  0x8(%ebp)
f01014f0:	e8 01 ff ff ff       	call   f01013f6 <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01014f5:	83 c4 10             	add    $0x10,%esp
f01014f8:	85 c0                	test   %eax,%eax
f01014fa:	74 37                	je     f0101533 <page_lookup+0x55>
f01014fc:	f6 00 01             	testb  $0x1,(%eax)
f01014ff:	74 39                	je     f010153a <page_lookup+0x5c>
    if (pte_store != 0) {
f0101501:	85 db                	test   %ebx,%ebx
f0101503:	74 02                	je     f0101507 <page_lookup+0x29>
        *pte_store = pte;
f0101505:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f0101507:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101509:	c1 e8 0c             	shr    $0xc,%eax
f010150c:	3b 05 84 6f 1d f0    	cmp    0xf01d6f84,%eax
f0101512:	72 14                	jb     f0101528 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101514:	83 ec 04             	sub    $0x4,%esp
f0101517:	68 1c 4f 10 f0       	push   $0xf0104f1c
f010151c:	6a 4f                	push   $0x4f
f010151e:	68 a1 55 10 f0       	push   $0xf01055a1
f0101523:	e8 7d eb ff ff       	call   f01000a5 <_panic>
	return &pages[PGNUM(pa)];
f0101528:	c1 e0 03             	shl    $0x3,%eax
f010152b:	03 05 8c 6f 1d f0    	add    0xf01d6f8c,%eax
f0101531:	eb 0c                	jmp    f010153f <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0101533:	b8 00 00 00 00       	mov    $0x0,%eax
f0101538:	eb 05                	jmp    f010153f <page_lookup+0x61>
f010153a:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f010153f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101542:	c9                   	leave  
f0101543:	c3                   	ret    

f0101544 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101544:	55                   	push   %ebp
f0101545:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101547:	8b 45 0c             	mov    0xc(%ebp),%eax
f010154a:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010154d:	c9                   	leave  
f010154e:	c3                   	ret    

f010154f <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010154f:	55                   	push   %ebp
f0101550:	89 e5                	mov    %esp,%ebp
f0101552:	56                   	push   %esi
f0101553:	53                   	push   %ebx
f0101554:	83 ec 14             	sub    $0x14,%esp
f0101557:	8b 75 08             	mov    0x8(%ebp),%esi
f010155a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f010155d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101560:	50                   	push   %eax
f0101561:	53                   	push   %ebx
f0101562:	56                   	push   %esi
f0101563:	e8 76 ff ff ff       	call   f01014de <page_lookup>
    if (pg == NULL) return;
f0101568:	83 c4 10             	add    $0x10,%esp
f010156b:	85 c0                	test   %eax,%eax
f010156d:	74 26                	je     f0101595 <page_remove+0x46>
    page_decref(pg);
f010156f:	83 ec 0c             	sub    $0xc,%esp
f0101572:	50                   	push   %eax
f0101573:	e8 60 fe ff ff       	call   f01013d8 <page_decref>
    if (pte != NULL) *pte = 0;
f0101578:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010157b:	83 c4 10             	add    $0x10,%esp
f010157e:	85 c0                	test   %eax,%eax
f0101580:	74 06                	je     f0101588 <page_remove+0x39>
f0101582:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f0101588:	83 ec 08             	sub    $0x8,%esp
f010158b:	53                   	push   %ebx
f010158c:	56                   	push   %esi
f010158d:	e8 b2 ff ff ff       	call   f0101544 <tlb_invalidate>
f0101592:	83 c4 10             	add    $0x10,%esp
}
f0101595:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101598:	5b                   	pop    %ebx
f0101599:	5e                   	pop    %esi
f010159a:	c9                   	leave  
f010159b:	c3                   	ret    

f010159c <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010159c:	55                   	push   %ebp
f010159d:	89 e5                	mov    %esp,%ebp
f010159f:	57                   	push   %edi
f01015a0:	56                   	push   %esi
f01015a1:	53                   	push   %ebx
f01015a2:	83 ec 10             	sub    $0x10,%esp
f01015a5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015a8:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f01015ab:	6a 01                	push   $0x1
f01015ad:	57                   	push   %edi
f01015ae:	ff 75 08             	pushl  0x8(%ebp)
f01015b1:	e8 40 fe ff ff       	call   f01013f6 <pgdir_walk>
f01015b6:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f01015b8:	83 c4 10             	add    $0x10,%esp
f01015bb:	85 c0                	test   %eax,%eax
f01015bd:	74 39                	je     f01015f8 <page_insert+0x5c>
    ++pp->pp_ref;
f01015bf:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f01015c3:	f6 00 01             	testb  $0x1,(%eax)
f01015c6:	74 0f                	je     f01015d7 <page_insert+0x3b>
        page_remove(pgdir, va);
f01015c8:	83 ec 08             	sub    $0x8,%esp
f01015cb:	57                   	push   %edi
f01015cc:	ff 75 08             	pushl  0x8(%ebp)
f01015cf:	e8 7b ff ff ff       	call   f010154f <page_remove>
f01015d4:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f01015d7:	8b 55 14             	mov    0x14(%ebp),%edx
f01015da:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015dd:	2b 35 8c 6f 1d f0    	sub    0xf01d6f8c,%esi
f01015e3:	c1 fe 03             	sar    $0x3,%esi
f01015e6:	89 f0                	mov    %esi,%eax
f01015e8:	c1 e0 0c             	shl    $0xc,%eax
f01015eb:	89 d6                	mov    %edx,%esi
f01015ed:	09 c6                	or     %eax,%esi
f01015ef:	89 33                	mov    %esi,(%ebx)
	return 0;
f01015f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01015f6:	eb 05                	jmp    f01015fd <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f01015f8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f01015fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101600:	5b                   	pop    %ebx
f0101601:	5e                   	pop    %esi
f0101602:	5f                   	pop    %edi
f0101603:	c9                   	leave  
f0101604:	c3                   	ret    

f0101605 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101605:	55                   	push   %ebp
f0101606:	89 e5                	mov    %esp,%ebp
f0101608:	57                   	push   %edi
f0101609:	56                   	push   %esi
f010160a:	53                   	push   %ebx
f010160b:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010160e:	b8 15 00 00 00       	mov    $0x15,%eax
f0101613:	e8 89 f9 ff ff       	call   f0100fa1 <nvram_read>
f0101618:	c1 e0 0a             	shl    $0xa,%eax
f010161b:	89 c2                	mov    %eax,%edx
f010161d:	85 c0                	test   %eax,%eax
f010161f:	79 06                	jns    f0101627 <mem_init+0x22>
f0101621:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101627:	c1 fa 0c             	sar    $0xc,%edx
f010162a:	89 15 b4 62 1d f0    	mov    %edx,0xf01d62b4
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101630:	b8 17 00 00 00       	mov    $0x17,%eax
f0101635:	e8 67 f9 ff ff       	call   f0100fa1 <nvram_read>
f010163a:	89 c2                	mov    %eax,%edx
f010163c:	c1 e2 0a             	shl    $0xa,%edx
f010163f:	89 d0                	mov    %edx,%eax
f0101641:	85 d2                	test   %edx,%edx
f0101643:	79 06                	jns    f010164b <mem_init+0x46>
f0101645:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010164b:	c1 f8 0c             	sar    $0xc,%eax
f010164e:	74 0e                	je     f010165e <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101650:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101656:	89 15 84 6f 1d f0    	mov    %edx,0xf01d6f84
f010165c:	eb 0c                	jmp    f010166a <mem_init+0x65>
	else
		npages = npages_basemem;
f010165e:	8b 15 b4 62 1d f0    	mov    0xf01d62b4,%edx
f0101664:	89 15 84 6f 1d f0    	mov    %edx,0xf01d6f84

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010166a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010166d:	c1 e8 0a             	shr    $0xa,%eax
f0101670:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101671:	a1 b4 62 1d f0       	mov    0xf01d62b4,%eax
f0101676:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101679:	c1 e8 0a             	shr    $0xa,%eax
f010167c:	50                   	push   %eax
		npages * PGSIZE / 1024,
f010167d:	a1 84 6f 1d f0       	mov    0xf01d6f84,%eax
f0101682:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101685:	c1 e8 0a             	shr    $0xa,%eax
f0101688:	50                   	push   %eax
f0101689:	68 3c 4f 10 f0       	push   $0xf0104f3c
f010168e:	e8 aa 1a 00 00       	call   f010313d <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101693:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101698:	e8 6b f8 ff ff       	call   f0100f08 <boot_alloc>
f010169d:	a3 88 6f 1d f0       	mov    %eax,0xf01d6f88
	memset(kern_pgdir, 0, PGSIZE);
f01016a2:	83 c4 0c             	add    $0xc,%esp
f01016a5:	68 00 10 00 00       	push   $0x1000
f01016aa:	6a 00                	push   $0x0
f01016ac:	50                   	push   %eax
f01016ad:	e8 5b 29 00 00       	call   f010400d <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01016b2:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01016b7:	83 c4 10             	add    $0x10,%esp
f01016ba:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01016bf:	77 15                	ja     f01016d6 <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01016c1:	50                   	push   %eax
f01016c2:	68 74 4c 10 f0       	push   $0xf0104c74
f01016c7:	68 8e 00 00 00       	push   $0x8e
f01016cc:	68 95 55 10 f0       	push   $0xf0105595
f01016d1:	e8 cf e9 ff ff       	call   f01000a5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01016d6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01016dc:	83 ca 05             	or     $0x5,%edx
f01016df:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01016e5:	a1 84 6f 1d f0       	mov    0xf01d6f84,%eax
f01016ea:	c1 e0 03             	shl    $0x3,%eax
f01016ed:	e8 16 f8 ff ff       	call   f0100f08 <boot_alloc>
f01016f2:	a3 8c 6f 1d f0       	mov    %eax,0xf01d6f8c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01016f7:	e8 85 fb ff ff       	call   f0101281 <page_init>

	check_page_free_list(1);
f01016fc:	b8 01 00 00 00       	mov    $0x1,%eax
f0101701:	e8 c2 f8 ff ff       	call   f0100fc8 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101706:	83 3d 8c 6f 1d f0 00 	cmpl   $0x0,0xf01d6f8c
f010170d:	75 17                	jne    f0101726 <mem_init+0x121>
		panic("'pages' is a null pointer!");
f010170f:	83 ec 04             	sub    $0x4,%esp
f0101712:	68 4b 56 10 f0       	push   $0xf010564b
f0101717:	68 7f 02 00 00       	push   $0x27f
f010171c:	68 95 55 10 f0       	push   $0xf0105595
f0101721:	e8 7f e9 ff ff       	call   f01000a5 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101726:	a1 ac 62 1d f0       	mov    0xf01d62ac,%eax
f010172b:	85 c0                	test   %eax,%eax
f010172d:	74 0e                	je     f010173d <mem_init+0x138>
f010172f:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101734:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101735:	8b 00                	mov    (%eax),%eax
f0101737:	85 c0                	test   %eax,%eax
f0101739:	75 f9                	jne    f0101734 <mem_init+0x12f>
f010173b:	eb 05                	jmp    f0101742 <mem_init+0x13d>
f010173d:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101742:	83 ec 0c             	sub    $0xc,%esp
f0101745:	6a 00                	push   $0x0
f0101747:	e8 e2 fb ff ff       	call   f010132e <page_alloc>
f010174c:	89 c6                	mov    %eax,%esi
f010174e:	83 c4 10             	add    $0x10,%esp
f0101751:	85 c0                	test   %eax,%eax
f0101753:	75 19                	jne    f010176e <mem_init+0x169>
f0101755:	68 66 56 10 f0       	push   $0xf0105666
f010175a:	68 bb 55 10 f0       	push   $0xf01055bb
f010175f:	68 87 02 00 00       	push   $0x287
f0101764:	68 95 55 10 f0       	push   $0xf0105595
f0101769:	e8 37 e9 ff ff       	call   f01000a5 <_panic>
	assert((pp1 = page_alloc(0)));
f010176e:	83 ec 0c             	sub    $0xc,%esp
f0101771:	6a 00                	push   $0x0
f0101773:	e8 b6 fb ff ff       	call   f010132e <page_alloc>
f0101778:	89 c7                	mov    %eax,%edi
f010177a:	83 c4 10             	add    $0x10,%esp
f010177d:	85 c0                	test   %eax,%eax
f010177f:	75 19                	jne    f010179a <mem_init+0x195>
f0101781:	68 7c 56 10 f0       	push   $0xf010567c
f0101786:	68 bb 55 10 f0       	push   $0xf01055bb
f010178b:	68 88 02 00 00       	push   $0x288
f0101790:	68 95 55 10 f0       	push   $0xf0105595
f0101795:	e8 0b e9 ff ff       	call   f01000a5 <_panic>
	assert((pp2 = page_alloc(0)));
f010179a:	83 ec 0c             	sub    $0xc,%esp
f010179d:	6a 00                	push   $0x0
f010179f:	e8 8a fb ff ff       	call   f010132e <page_alloc>
f01017a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017a7:	83 c4 10             	add    $0x10,%esp
f01017aa:	85 c0                	test   %eax,%eax
f01017ac:	75 19                	jne    f01017c7 <mem_init+0x1c2>
f01017ae:	68 92 56 10 f0       	push   $0xf0105692
f01017b3:	68 bb 55 10 f0       	push   $0xf01055bb
f01017b8:	68 89 02 00 00       	push   $0x289
f01017bd:	68 95 55 10 f0       	push   $0xf0105595
f01017c2:	e8 de e8 ff ff       	call   f01000a5 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017c7:	39 fe                	cmp    %edi,%esi
f01017c9:	75 19                	jne    f01017e4 <mem_init+0x1df>
f01017cb:	68 a8 56 10 f0       	push   $0xf01056a8
f01017d0:	68 bb 55 10 f0       	push   $0xf01055bb
f01017d5:	68 8c 02 00 00       	push   $0x28c
f01017da:	68 95 55 10 f0       	push   $0xf0105595
f01017df:	e8 c1 e8 ff ff       	call   f01000a5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017e4:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01017e7:	74 05                	je     f01017ee <mem_init+0x1e9>
f01017e9:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01017ec:	75 19                	jne    f0101807 <mem_init+0x202>
f01017ee:	68 78 4f 10 f0       	push   $0xf0104f78
f01017f3:	68 bb 55 10 f0       	push   $0xf01055bb
f01017f8:	68 8d 02 00 00       	push   $0x28d
f01017fd:	68 95 55 10 f0       	push   $0xf0105595
f0101802:	e8 9e e8 ff ff       	call   f01000a5 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101807:	8b 15 8c 6f 1d f0    	mov    0xf01d6f8c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010180d:	a1 84 6f 1d f0       	mov    0xf01d6f84,%eax
f0101812:	c1 e0 0c             	shl    $0xc,%eax
f0101815:	89 f1                	mov    %esi,%ecx
f0101817:	29 d1                	sub    %edx,%ecx
f0101819:	c1 f9 03             	sar    $0x3,%ecx
f010181c:	c1 e1 0c             	shl    $0xc,%ecx
f010181f:	39 c1                	cmp    %eax,%ecx
f0101821:	72 19                	jb     f010183c <mem_init+0x237>
f0101823:	68 ba 56 10 f0       	push   $0xf01056ba
f0101828:	68 bb 55 10 f0       	push   $0xf01055bb
f010182d:	68 8e 02 00 00       	push   $0x28e
f0101832:	68 95 55 10 f0       	push   $0xf0105595
f0101837:	e8 69 e8 ff ff       	call   f01000a5 <_panic>
f010183c:	89 f9                	mov    %edi,%ecx
f010183e:	29 d1                	sub    %edx,%ecx
f0101840:	c1 f9 03             	sar    $0x3,%ecx
f0101843:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101846:	39 c8                	cmp    %ecx,%eax
f0101848:	77 19                	ja     f0101863 <mem_init+0x25e>
f010184a:	68 d7 56 10 f0       	push   $0xf01056d7
f010184f:	68 bb 55 10 f0       	push   $0xf01055bb
f0101854:	68 8f 02 00 00       	push   $0x28f
f0101859:	68 95 55 10 f0       	push   $0xf0105595
f010185e:	e8 42 e8 ff ff       	call   f01000a5 <_panic>
f0101863:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101866:	29 d1                	sub    %edx,%ecx
f0101868:	89 ca                	mov    %ecx,%edx
f010186a:	c1 fa 03             	sar    $0x3,%edx
f010186d:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101870:	39 d0                	cmp    %edx,%eax
f0101872:	77 19                	ja     f010188d <mem_init+0x288>
f0101874:	68 f4 56 10 f0       	push   $0xf01056f4
f0101879:	68 bb 55 10 f0       	push   $0xf01055bb
f010187e:	68 90 02 00 00       	push   $0x290
f0101883:	68 95 55 10 f0       	push   $0xf0105595
f0101888:	e8 18 e8 ff ff       	call   f01000a5 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010188d:	a1 ac 62 1d f0       	mov    0xf01d62ac,%eax
f0101892:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101895:	c7 05 ac 62 1d f0 00 	movl   $0x0,0xf01d62ac
f010189c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010189f:	83 ec 0c             	sub    $0xc,%esp
f01018a2:	6a 00                	push   $0x0
f01018a4:	e8 85 fa ff ff       	call   f010132e <page_alloc>
f01018a9:	83 c4 10             	add    $0x10,%esp
f01018ac:	85 c0                	test   %eax,%eax
f01018ae:	74 19                	je     f01018c9 <mem_init+0x2c4>
f01018b0:	68 11 57 10 f0       	push   $0xf0105711
f01018b5:	68 bb 55 10 f0       	push   $0xf01055bb
f01018ba:	68 97 02 00 00       	push   $0x297
f01018bf:	68 95 55 10 f0       	push   $0xf0105595
f01018c4:	e8 dc e7 ff ff       	call   f01000a5 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01018c9:	83 ec 0c             	sub    $0xc,%esp
f01018cc:	56                   	push   %esi
f01018cd:	e8 e6 fa ff ff       	call   f01013b8 <page_free>
	page_free(pp1);
f01018d2:	89 3c 24             	mov    %edi,(%esp)
f01018d5:	e8 de fa ff ff       	call   f01013b8 <page_free>
	page_free(pp2);
f01018da:	83 c4 04             	add    $0x4,%esp
f01018dd:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018e0:	e8 d3 fa ff ff       	call   f01013b8 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018ec:	e8 3d fa ff ff       	call   f010132e <page_alloc>
f01018f1:	89 c6                	mov    %eax,%esi
f01018f3:	83 c4 10             	add    $0x10,%esp
f01018f6:	85 c0                	test   %eax,%eax
f01018f8:	75 19                	jne    f0101913 <mem_init+0x30e>
f01018fa:	68 66 56 10 f0       	push   $0xf0105666
f01018ff:	68 bb 55 10 f0       	push   $0xf01055bb
f0101904:	68 9e 02 00 00       	push   $0x29e
f0101909:	68 95 55 10 f0       	push   $0xf0105595
f010190e:	e8 92 e7 ff ff       	call   f01000a5 <_panic>
	assert((pp1 = page_alloc(0)));
f0101913:	83 ec 0c             	sub    $0xc,%esp
f0101916:	6a 00                	push   $0x0
f0101918:	e8 11 fa ff ff       	call   f010132e <page_alloc>
f010191d:	89 c7                	mov    %eax,%edi
f010191f:	83 c4 10             	add    $0x10,%esp
f0101922:	85 c0                	test   %eax,%eax
f0101924:	75 19                	jne    f010193f <mem_init+0x33a>
f0101926:	68 7c 56 10 f0       	push   $0xf010567c
f010192b:	68 bb 55 10 f0       	push   $0xf01055bb
f0101930:	68 9f 02 00 00       	push   $0x29f
f0101935:	68 95 55 10 f0       	push   $0xf0105595
f010193a:	e8 66 e7 ff ff       	call   f01000a5 <_panic>
	assert((pp2 = page_alloc(0)));
f010193f:	83 ec 0c             	sub    $0xc,%esp
f0101942:	6a 00                	push   $0x0
f0101944:	e8 e5 f9 ff ff       	call   f010132e <page_alloc>
f0101949:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010194c:	83 c4 10             	add    $0x10,%esp
f010194f:	85 c0                	test   %eax,%eax
f0101951:	75 19                	jne    f010196c <mem_init+0x367>
f0101953:	68 92 56 10 f0       	push   $0xf0105692
f0101958:	68 bb 55 10 f0       	push   $0xf01055bb
f010195d:	68 a0 02 00 00       	push   $0x2a0
f0101962:	68 95 55 10 f0       	push   $0xf0105595
f0101967:	e8 39 e7 ff ff       	call   f01000a5 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010196c:	39 fe                	cmp    %edi,%esi
f010196e:	75 19                	jne    f0101989 <mem_init+0x384>
f0101970:	68 a8 56 10 f0       	push   $0xf01056a8
f0101975:	68 bb 55 10 f0       	push   $0xf01055bb
f010197a:	68 a2 02 00 00       	push   $0x2a2
f010197f:	68 95 55 10 f0       	push   $0xf0105595
f0101984:	e8 1c e7 ff ff       	call   f01000a5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101989:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010198c:	74 05                	je     f0101993 <mem_init+0x38e>
f010198e:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101991:	75 19                	jne    f01019ac <mem_init+0x3a7>
f0101993:	68 78 4f 10 f0       	push   $0xf0104f78
f0101998:	68 bb 55 10 f0       	push   $0xf01055bb
f010199d:	68 a3 02 00 00       	push   $0x2a3
f01019a2:	68 95 55 10 f0       	push   $0xf0105595
f01019a7:	e8 f9 e6 ff ff       	call   f01000a5 <_panic>
	assert(!page_alloc(0));
f01019ac:	83 ec 0c             	sub    $0xc,%esp
f01019af:	6a 00                	push   $0x0
f01019b1:	e8 78 f9 ff ff       	call   f010132e <page_alloc>
f01019b6:	83 c4 10             	add    $0x10,%esp
f01019b9:	85 c0                	test   %eax,%eax
f01019bb:	74 19                	je     f01019d6 <mem_init+0x3d1>
f01019bd:	68 11 57 10 f0       	push   $0xf0105711
f01019c2:	68 bb 55 10 f0       	push   $0xf01055bb
f01019c7:	68 a4 02 00 00       	push   $0x2a4
f01019cc:	68 95 55 10 f0       	push   $0xf0105595
f01019d1:	e8 cf e6 ff ff       	call   f01000a5 <_panic>
f01019d6:	89 f0                	mov    %esi,%eax
f01019d8:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f01019de:	c1 f8 03             	sar    $0x3,%eax
f01019e1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019e4:	89 c2                	mov    %eax,%edx
f01019e6:	c1 ea 0c             	shr    $0xc,%edx
f01019e9:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f01019ef:	72 12                	jb     f0101a03 <mem_init+0x3fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019f1:	50                   	push   %eax
f01019f2:	68 34 4e 10 f0       	push   $0xf0104e34
f01019f7:	6a 56                	push   $0x56
f01019f9:	68 a1 55 10 f0       	push   $0xf01055a1
f01019fe:	e8 a2 e6 ff ff       	call   f01000a5 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101a03:	83 ec 04             	sub    $0x4,%esp
f0101a06:	68 00 10 00 00       	push   $0x1000
f0101a0b:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101a0d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a12:	50                   	push   %eax
f0101a13:	e8 f5 25 00 00       	call   f010400d <memset>
	page_free(pp0);
f0101a18:	89 34 24             	mov    %esi,(%esp)
f0101a1b:	e8 98 f9 ff ff       	call   f01013b8 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a20:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a27:	e8 02 f9 ff ff       	call   f010132e <page_alloc>
f0101a2c:	83 c4 10             	add    $0x10,%esp
f0101a2f:	85 c0                	test   %eax,%eax
f0101a31:	75 19                	jne    f0101a4c <mem_init+0x447>
f0101a33:	68 20 57 10 f0       	push   $0xf0105720
f0101a38:	68 bb 55 10 f0       	push   $0xf01055bb
f0101a3d:	68 a9 02 00 00       	push   $0x2a9
f0101a42:	68 95 55 10 f0       	push   $0xf0105595
f0101a47:	e8 59 e6 ff ff       	call   f01000a5 <_panic>
	assert(pp && pp0 == pp);
f0101a4c:	39 c6                	cmp    %eax,%esi
f0101a4e:	74 19                	je     f0101a69 <mem_init+0x464>
f0101a50:	68 3e 57 10 f0       	push   $0xf010573e
f0101a55:	68 bb 55 10 f0       	push   $0xf01055bb
f0101a5a:	68 aa 02 00 00       	push   $0x2aa
f0101a5f:	68 95 55 10 f0       	push   $0xf0105595
f0101a64:	e8 3c e6 ff ff       	call   f01000a5 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a69:	89 f2                	mov    %esi,%edx
f0101a6b:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0101a71:	c1 fa 03             	sar    $0x3,%edx
f0101a74:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a77:	89 d0                	mov    %edx,%eax
f0101a79:	c1 e8 0c             	shr    $0xc,%eax
f0101a7c:	3b 05 84 6f 1d f0    	cmp    0xf01d6f84,%eax
f0101a82:	72 12                	jb     f0101a96 <mem_init+0x491>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a84:	52                   	push   %edx
f0101a85:	68 34 4e 10 f0       	push   $0xf0104e34
f0101a8a:	6a 56                	push   $0x56
f0101a8c:	68 a1 55 10 f0       	push   $0xf01055a1
f0101a91:	e8 0f e6 ff ff       	call   f01000a5 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101a96:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101a9d:	75 11                	jne    f0101ab0 <mem_init+0x4ab>
f0101a9f:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101aa5:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101aab:	80 38 00             	cmpb   $0x0,(%eax)
f0101aae:	74 19                	je     f0101ac9 <mem_init+0x4c4>
f0101ab0:	68 4e 57 10 f0       	push   $0xf010574e
f0101ab5:	68 bb 55 10 f0       	push   $0xf01055bb
f0101aba:	68 ad 02 00 00       	push   $0x2ad
f0101abf:	68 95 55 10 f0       	push   $0xf0105595
f0101ac4:	e8 dc e5 ff ff       	call   f01000a5 <_panic>
f0101ac9:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101aca:	39 d0                	cmp    %edx,%eax
f0101acc:	75 dd                	jne    f0101aab <mem_init+0x4a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101ace:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101ad1:	89 15 ac 62 1d f0    	mov    %edx,0xf01d62ac

	// free the pages we took
	page_free(pp0);
f0101ad7:	83 ec 0c             	sub    $0xc,%esp
f0101ada:	56                   	push   %esi
f0101adb:	e8 d8 f8 ff ff       	call   f01013b8 <page_free>
	page_free(pp1);
f0101ae0:	89 3c 24             	mov    %edi,(%esp)
f0101ae3:	e8 d0 f8 ff ff       	call   f01013b8 <page_free>
	page_free(pp2);
f0101ae8:	83 c4 04             	add    $0x4,%esp
f0101aeb:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101aee:	e8 c5 f8 ff ff       	call   f01013b8 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101af3:	a1 ac 62 1d f0       	mov    0xf01d62ac,%eax
f0101af8:	83 c4 10             	add    $0x10,%esp
f0101afb:	85 c0                	test   %eax,%eax
f0101afd:	74 07                	je     f0101b06 <mem_init+0x501>
		--nfree;
f0101aff:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b00:	8b 00                	mov    (%eax),%eax
f0101b02:	85 c0                	test   %eax,%eax
f0101b04:	75 f9                	jne    f0101aff <mem_init+0x4fa>
		--nfree;
	assert(nfree == 0);
f0101b06:	85 db                	test   %ebx,%ebx
f0101b08:	74 19                	je     f0101b23 <mem_init+0x51e>
f0101b0a:	68 58 57 10 f0       	push   $0xf0105758
f0101b0f:	68 bb 55 10 f0       	push   $0xf01055bb
f0101b14:	68 ba 02 00 00       	push   $0x2ba
f0101b19:	68 95 55 10 f0       	push   $0xf0105595
f0101b1e:	e8 82 e5 ff ff       	call   f01000a5 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101b23:	83 ec 0c             	sub    $0xc,%esp
f0101b26:	68 98 4f 10 f0       	push   $0xf0104f98
f0101b2b:	e8 0d 16 00 00       	call   f010313d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b37:	e8 f2 f7 ff ff       	call   f010132e <page_alloc>
f0101b3c:	89 c6                	mov    %eax,%esi
f0101b3e:	83 c4 10             	add    $0x10,%esp
f0101b41:	85 c0                	test   %eax,%eax
f0101b43:	75 19                	jne    f0101b5e <mem_init+0x559>
f0101b45:	68 66 56 10 f0       	push   $0xf0105666
f0101b4a:	68 bb 55 10 f0       	push   $0xf01055bb
f0101b4f:	68 18 03 00 00       	push   $0x318
f0101b54:	68 95 55 10 f0       	push   $0xf0105595
f0101b59:	e8 47 e5 ff ff       	call   f01000a5 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b5e:	83 ec 0c             	sub    $0xc,%esp
f0101b61:	6a 00                	push   $0x0
f0101b63:	e8 c6 f7 ff ff       	call   f010132e <page_alloc>
f0101b68:	89 c7                	mov    %eax,%edi
f0101b6a:	83 c4 10             	add    $0x10,%esp
f0101b6d:	85 c0                	test   %eax,%eax
f0101b6f:	75 19                	jne    f0101b8a <mem_init+0x585>
f0101b71:	68 7c 56 10 f0       	push   $0xf010567c
f0101b76:	68 bb 55 10 f0       	push   $0xf01055bb
f0101b7b:	68 19 03 00 00       	push   $0x319
f0101b80:	68 95 55 10 f0       	push   $0xf0105595
f0101b85:	e8 1b e5 ff ff       	call   f01000a5 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b8a:	83 ec 0c             	sub    $0xc,%esp
f0101b8d:	6a 00                	push   $0x0
f0101b8f:	e8 9a f7 ff ff       	call   f010132e <page_alloc>
f0101b94:	89 c3                	mov    %eax,%ebx
f0101b96:	83 c4 10             	add    $0x10,%esp
f0101b99:	85 c0                	test   %eax,%eax
f0101b9b:	75 19                	jne    f0101bb6 <mem_init+0x5b1>
f0101b9d:	68 92 56 10 f0       	push   $0xf0105692
f0101ba2:	68 bb 55 10 f0       	push   $0xf01055bb
f0101ba7:	68 1a 03 00 00       	push   $0x31a
f0101bac:	68 95 55 10 f0       	push   $0xf0105595
f0101bb1:	e8 ef e4 ff ff       	call   f01000a5 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101bb6:	39 fe                	cmp    %edi,%esi
f0101bb8:	75 19                	jne    f0101bd3 <mem_init+0x5ce>
f0101bba:	68 a8 56 10 f0       	push   $0xf01056a8
f0101bbf:	68 bb 55 10 f0       	push   $0xf01055bb
f0101bc4:	68 1d 03 00 00       	push   $0x31d
f0101bc9:	68 95 55 10 f0       	push   $0xf0105595
f0101bce:	e8 d2 e4 ff ff       	call   f01000a5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101bd3:	39 c7                	cmp    %eax,%edi
f0101bd5:	74 04                	je     f0101bdb <mem_init+0x5d6>
f0101bd7:	39 c6                	cmp    %eax,%esi
f0101bd9:	75 19                	jne    f0101bf4 <mem_init+0x5ef>
f0101bdb:	68 78 4f 10 f0       	push   $0xf0104f78
f0101be0:	68 bb 55 10 f0       	push   $0xf01055bb
f0101be5:	68 1e 03 00 00       	push   $0x31e
f0101bea:	68 95 55 10 f0       	push   $0xf0105595
f0101bef:	e8 b1 e4 ff ff       	call   f01000a5 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101bf4:	8b 0d ac 62 1d f0    	mov    0xf01d62ac,%ecx
f0101bfa:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101bfd:	c7 05 ac 62 1d f0 00 	movl   $0x0,0xf01d62ac
f0101c04:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c07:	83 ec 0c             	sub    $0xc,%esp
f0101c0a:	6a 00                	push   $0x0
f0101c0c:	e8 1d f7 ff ff       	call   f010132e <page_alloc>
f0101c11:	83 c4 10             	add    $0x10,%esp
f0101c14:	85 c0                	test   %eax,%eax
f0101c16:	74 19                	je     f0101c31 <mem_init+0x62c>
f0101c18:	68 11 57 10 f0       	push   $0xf0105711
f0101c1d:	68 bb 55 10 f0       	push   $0xf01055bb
f0101c22:	68 25 03 00 00       	push   $0x325
f0101c27:	68 95 55 10 f0       	push   $0xf0105595
f0101c2c:	e8 74 e4 ff ff       	call   f01000a5 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c31:	83 ec 04             	sub    $0x4,%esp
f0101c34:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c37:	50                   	push   %eax
f0101c38:	6a 00                	push   $0x0
f0101c3a:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0101c40:	e8 99 f8 ff ff       	call   f01014de <page_lookup>
f0101c45:	83 c4 10             	add    $0x10,%esp
f0101c48:	85 c0                	test   %eax,%eax
f0101c4a:	74 19                	je     f0101c65 <mem_init+0x660>
f0101c4c:	68 b8 4f 10 f0       	push   $0xf0104fb8
f0101c51:	68 bb 55 10 f0       	push   $0xf01055bb
f0101c56:	68 28 03 00 00       	push   $0x328
f0101c5b:	68 95 55 10 f0       	push   $0xf0105595
f0101c60:	e8 40 e4 ff ff       	call   f01000a5 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c65:	6a 02                	push   $0x2
f0101c67:	6a 00                	push   $0x0
f0101c69:	57                   	push   %edi
f0101c6a:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0101c70:	e8 27 f9 ff ff       	call   f010159c <page_insert>
f0101c75:	83 c4 10             	add    $0x10,%esp
f0101c78:	85 c0                	test   %eax,%eax
f0101c7a:	78 19                	js     f0101c95 <mem_init+0x690>
f0101c7c:	68 f0 4f 10 f0       	push   $0xf0104ff0
f0101c81:	68 bb 55 10 f0       	push   $0xf01055bb
f0101c86:	68 2b 03 00 00       	push   $0x32b
f0101c8b:	68 95 55 10 f0       	push   $0xf0105595
f0101c90:	e8 10 e4 ff ff       	call   f01000a5 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c95:	83 ec 0c             	sub    $0xc,%esp
f0101c98:	56                   	push   %esi
f0101c99:	e8 1a f7 ff ff       	call   f01013b8 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c9e:	6a 02                	push   $0x2
f0101ca0:	6a 00                	push   $0x0
f0101ca2:	57                   	push   %edi
f0101ca3:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0101ca9:	e8 ee f8 ff ff       	call   f010159c <page_insert>
f0101cae:	83 c4 20             	add    $0x20,%esp
f0101cb1:	85 c0                	test   %eax,%eax
f0101cb3:	74 19                	je     f0101cce <mem_init+0x6c9>
f0101cb5:	68 20 50 10 f0       	push   $0xf0105020
f0101cba:	68 bb 55 10 f0       	push   $0xf01055bb
f0101cbf:	68 2f 03 00 00       	push   $0x32f
f0101cc4:	68 95 55 10 f0       	push   $0xf0105595
f0101cc9:	e8 d7 e3 ff ff       	call   f01000a5 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101cce:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0101cd3:	8b 08                	mov    (%eax),%ecx
f0101cd5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101cdb:	89 f2                	mov    %esi,%edx
f0101cdd:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0101ce3:	c1 fa 03             	sar    $0x3,%edx
f0101ce6:	c1 e2 0c             	shl    $0xc,%edx
f0101ce9:	39 d1                	cmp    %edx,%ecx
f0101ceb:	74 19                	je     f0101d06 <mem_init+0x701>
f0101ced:	68 50 50 10 f0       	push   $0xf0105050
f0101cf2:	68 bb 55 10 f0       	push   $0xf01055bb
f0101cf7:	68 30 03 00 00       	push   $0x330
f0101cfc:	68 95 55 10 f0       	push   $0xf0105595
f0101d01:	e8 9f e3 ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d06:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d0b:	e8 2f f2 ff ff       	call   f0100f3f <check_va2pa>
f0101d10:	89 fa                	mov    %edi,%edx
f0101d12:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0101d18:	c1 fa 03             	sar    $0x3,%edx
f0101d1b:	c1 e2 0c             	shl    $0xc,%edx
f0101d1e:	39 d0                	cmp    %edx,%eax
f0101d20:	74 19                	je     f0101d3b <mem_init+0x736>
f0101d22:	68 78 50 10 f0       	push   $0xf0105078
f0101d27:	68 bb 55 10 f0       	push   $0xf01055bb
f0101d2c:	68 31 03 00 00       	push   $0x331
f0101d31:	68 95 55 10 f0       	push   $0xf0105595
f0101d36:	e8 6a e3 ff ff       	call   f01000a5 <_panic>
	assert(pp1->pp_ref == 1);
f0101d3b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d40:	74 19                	je     f0101d5b <mem_init+0x756>
f0101d42:	68 63 57 10 f0       	push   $0xf0105763
f0101d47:	68 bb 55 10 f0       	push   $0xf01055bb
f0101d4c:	68 32 03 00 00       	push   $0x332
f0101d51:	68 95 55 10 f0       	push   $0xf0105595
f0101d56:	e8 4a e3 ff ff       	call   f01000a5 <_panic>
	assert(pp0->pp_ref == 1);
f0101d5b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d60:	74 19                	je     f0101d7b <mem_init+0x776>
f0101d62:	68 74 57 10 f0       	push   $0xf0105774
f0101d67:	68 bb 55 10 f0       	push   $0xf01055bb
f0101d6c:	68 33 03 00 00       	push   $0x333
f0101d71:	68 95 55 10 f0       	push   $0xf0105595
f0101d76:	e8 2a e3 ff ff       	call   f01000a5 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d7b:	6a 02                	push   $0x2
f0101d7d:	68 00 10 00 00       	push   $0x1000
f0101d82:	53                   	push   %ebx
f0101d83:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0101d89:	e8 0e f8 ff ff       	call   f010159c <page_insert>
f0101d8e:	83 c4 10             	add    $0x10,%esp
f0101d91:	85 c0                	test   %eax,%eax
f0101d93:	74 19                	je     f0101dae <mem_init+0x7a9>
f0101d95:	68 a8 50 10 f0       	push   $0xf01050a8
f0101d9a:	68 bb 55 10 f0       	push   $0xf01055bb
f0101d9f:	68 36 03 00 00       	push   $0x336
f0101da4:	68 95 55 10 f0       	push   $0xf0105595
f0101da9:	e8 f7 e2 ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dae:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101db3:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0101db8:	e8 82 f1 ff ff       	call   f0100f3f <check_va2pa>
f0101dbd:	89 da                	mov    %ebx,%edx
f0101dbf:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0101dc5:	c1 fa 03             	sar    $0x3,%edx
f0101dc8:	c1 e2 0c             	shl    $0xc,%edx
f0101dcb:	39 d0                	cmp    %edx,%eax
f0101dcd:	74 19                	je     f0101de8 <mem_init+0x7e3>
f0101dcf:	68 e4 50 10 f0       	push   $0xf01050e4
f0101dd4:	68 bb 55 10 f0       	push   $0xf01055bb
f0101dd9:	68 37 03 00 00       	push   $0x337
f0101dde:	68 95 55 10 f0       	push   $0xf0105595
f0101de3:	e8 bd e2 ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 1);
f0101de8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ded:	74 19                	je     f0101e08 <mem_init+0x803>
f0101def:	68 85 57 10 f0       	push   $0xf0105785
f0101df4:	68 bb 55 10 f0       	push   $0xf01055bb
f0101df9:	68 38 03 00 00       	push   $0x338
f0101dfe:	68 95 55 10 f0       	push   $0xf0105595
f0101e03:	e8 9d e2 ff ff       	call   f01000a5 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e08:	83 ec 0c             	sub    $0xc,%esp
f0101e0b:	6a 00                	push   $0x0
f0101e0d:	e8 1c f5 ff ff       	call   f010132e <page_alloc>
f0101e12:	83 c4 10             	add    $0x10,%esp
f0101e15:	85 c0                	test   %eax,%eax
f0101e17:	74 19                	je     f0101e32 <mem_init+0x82d>
f0101e19:	68 11 57 10 f0       	push   $0xf0105711
f0101e1e:	68 bb 55 10 f0       	push   $0xf01055bb
f0101e23:	68 3b 03 00 00       	push   $0x33b
f0101e28:	68 95 55 10 f0       	push   $0xf0105595
f0101e2d:	e8 73 e2 ff ff       	call   f01000a5 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e32:	6a 02                	push   $0x2
f0101e34:	68 00 10 00 00       	push   $0x1000
f0101e39:	53                   	push   %ebx
f0101e3a:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0101e40:	e8 57 f7 ff ff       	call   f010159c <page_insert>
f0101e45:	83 c4 10             	add    $0x10,%esp
f0101e48:	85 c0                	test   %eax,%eax
f0101e4a:	74 19                	je     f0101e65 <mem_init+0x860>
f0101e4c:	68 a8 50 10 f0       	push   $0xf01050a8
f0101e51:	68 bb 55 10 f0       	push   $0xf01055bb
f0101e56:	68 3e 03 00 00       	push   $0x33e
f0101e5b:	68 95 55 10 f0       	push   $0xf0105595
f0101e60:	e8 40 e2 ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e65:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e6a:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0101e6f:	e8 cb f0 ff ff       	call   f0100f3f <check_va2pa>
f0101e74:	89 da                	mov    %ebx,%edx
f0101e76:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0101e7c:	c1 fa 03             	sar    $0x3,%edx
f0101e7f:	c1 e2 0c             	shl    $0xc,%edx
f0101e82:	39 d0                	cmp    %edx,%eax
f0101e84:	74 19                	je     f0101e9f <mem_init+0x89a>
f0101e86:	68 e4 50 10 f0       	push   $0xf01050e4
f0101e8b:	68 bb 55 10 f0       	push   $0xf01055bb
f0101e90:	68 3f 03 00 00       	push   $0x33f
f0101e95:	68 95 55 10 f0       	push   $0xf0105595
f0101e9a:	e8 06 e2 ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 1);
f0101e9f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ea4:	74 19                	je     f0101ebf <mem_init+0x8ba>
f0101ea6:	68 85 57 10 f0       	push   $0xf0105785
f0101eab:	68 bb 55 10 f0       	push   $0xf01055bb
f0101eb0:	68 40 03 00 00       	push   $0x340
f0101eb5:	68 95 55 10 f0       	push   $0xf0105595
f0101eba:	e8 e6 e1 ff ff       	call   f01000a5 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ebf:	83 ec 0c             	sub    $0xc,%esp
f0101ec2:	6a 00                	push   $0x0
f0101ec4:	e8 65 f4 ff ff       	call   f010132e <page_alloc>
f0101ec9:	83 c4 10             	add    $0x10,%esp
f0101ecc:	85 c0                	test   %eax,%eax
f0101ece:	74 19                	je     f0101ee9 <mem_init+0x8e4>
f0101ed0:	68 11 57 10 f0       	push   $0xf0105711
f0101ed5:	68 bb 55 10 f0       	push   $0xf01055bb
f0101eda:	68 44 03 00 00       	push   $0x344
f0101edf:	68 95 55 10 f0       	push   $0xf0105595
f0101ee4:	e8 bc e1 ff ff       	call   f01000a5 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ee9:	8b 15 88 6f 1d f0    	mov    0xf01d6f88,%edx
f0101eef:	8b 02                	mov    (%edx),%eax
f0101ef1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ef6:	89 c1                	mov    %eax,%ecx
f0101ef8:	c1 e9 0c             	shr    $0xc,%ecx
f0101efb:	3b 0d 84 6f 1d f0    	cmp    0xf01d6f84,%ecx
f0101f01:	72 15                	jb     f0101f18 <mem_init+0x913>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f03:	50                   	push   %eax
f0101f04:	68 34 4e 10 f0       	push   $0xf0104e34
f0101f09:	68 47 03 00 00       	push   $0x347
f0101f0e:	68 95 55 10 f0       	push   $0xf0105595
f0101f13:	e8 8d e1 ff ff       	call   f01000a5 <_panic>
	return (void *)(pa + KERNBASE);
f0101f18:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f20:	83 ec 04             	sub    $0x4,%esp
f0101f23:	6a 00                	push   $0x0
f0101f25:	68 00 10 00 00       	push   $0x1000
f0101f2a:	52                   	push   %edx
f0101f2b:	e8 c6 f4 ff ff       	call   f01013f6 <pgdir_walk>
f0101f30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101f33:	83 c2 04             	add    $0x4,%edx
f0101f36:	83 c4 10             	add    $0x10,%esp
f0101f39:	39 d0                	cmp    %edx,%eax
f0101f3b:	74 19                	je     f0101f56 <mem_init+0x951>
f0101f3d:	68 14 51 10 f0       	push   $0xf0105114
f0101f42:	68 bb 55 10 f0       	push   $0xf01055bb
f0101f47:	68 48 03 00 00       	push   $0x348
f0101f4c:	68 95 55 10 f0       	push   $0xf0105595
f0101f51:	e8 4f e1 ff ff       	call   f01000a5 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f56:	6a 06                	push   $0x6
f0101f58:	68 00 10 00 00       	push   $0x1000
f0101f5d:	53                   	push   %ebx
f0101f5e:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0101f64:	e8 33 f6 ff ff       	call   f010159c <page_insert>
f0101f69:	83 c4 10             	add    $0x10,%esp
f0101f6c:	85 c0                	test   %eax,%eax
f0101f6e:	74 19                	je     f0101f89 <mem_init+0x984>
f0101f70:	68 54 51 10 f0       	push   $0xf0105154
f0101f75:	68 bb 55 10 f0       	push   $0xf01055bb
f0101f7a:	68 4b 03 00 00       	push   $0x34b
f0101f7f:	68 95 55 10 f0       	push   $0xf0105595
f0101f84:	e8 1c e1 ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f89:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f8e:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0101f93:	e8 a7 ef ff ff       	call   f0100f3f <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f98:	89 da                	mov    %ebx,%edx
f0101f9a:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0101fa0:	c1 fa 03             	sar    $0x3,%edx
f0101fa3:	c1 e2 0c             	shl    $0xc,%edx
f0101fa6:	39 d0                	cmp    %edx,%eax
f0101fa8:	74 19                	je     f0101fc3 <mem_init+0x9be>
f0101faa:	68 e4 50 10 f0       	push   $0xf01050e4
f0101faf:	68 bb 55 10 f0       	push   $0xf01055bb
f0101fb4:	68 4c 03 00 00       	push   $0x34c
f0101fb9:	68 95 55 10 f0       	push   $0xf0105595
f0101fbe:	e8 e2 e0 ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 1);
f0101fc3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fc8:	74 19                	je     f0101fe3 <mem_init+0x9de>
f0101fca:	68 85 57 10 f0       	push   $0xf0105785
f0101fcf:	68 bb 55 10 f0       	push   $0xf01055bb
f0101fd4:	68 4d 03 00 00       	push   $0x34d
f0101fd9:	68 95 55 10 f0       	push   $0xf0105595
f0101fde:	e8 c2 e0 ff ff       	call   f01000a5 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101fe3:	83 ec 04             	sub    $0x4,%esp
f0101fe6:	6a 00                	push   $0x0
f0101fe8:	68 00 10 00 00       	push   $0x1000
f0101fed:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0101ff3:	e8 fe f3 ff ff       	call   f01013f6 <pgdir_walk>
f0101ff8:	83 c4 10             	add    $0x10,%esp
f0101ffb:	f6 00 04             	testb  $0x4,(%eax)
f0101ffe:	75 19                	jne    f0102019 <mem_init+0xa14>
f0102000:	68 94 51 10 f0       	push   $0xf0105194
f0102005:	68 bb 55 10 f0       	push   $0xf01055bb
f010200a:	68 4e 03 00 00       	push   $0x34e
f010200f:	68 95 55 10 f0       	push   $0xf0105595
f0102014:	e8 8c e0 ff ff       	call   f01000a5 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102019:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f010201e:	f6 00 04             	testb  $0x4,(%eax)
f0102021:	75 19                	jne    f010203c <mem_init+0xa37>
f0102023:	68 96 57 10 f0       	push   $0xf0105796
f0102028:	68 bb 55 10 f0       	push   $0xf01055bb
f010202d:	68 4f 03 00 00       	push   $0x34f
f0102032:	68 95 55 10 f0       	push   $0xf0105595
f0102037:	e8 69 e0 ff ff       	call   f01000a5 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010203c:	6a 02                	push   $0x2
f010203e:	68 00 10 00 00       	push   $0x1000
f0102043:	53                   	push   %ebx
f0102044:	50                   	push   %eax
f0102045:	e8 52 f5 ff ff       	call   f010159c <page_insert>
f010204a:	83 c4 10             	add    $0x10,%esp
f010204d:	85 c0                	test   %eax,%eax
f010204f:	74 19                	je     f010206a <mem_init+0xa65>
f0102051:	68 a8 50 10 f0       	push   $0xf01050a8
f0102056:	68 bb 55 10 f0       	push   $0xf01055bb
f010205b:	68 52 03 00 00       	push   $0x352
f0102060:	68 95 55 10 f0       	push   $0xf0105595
f0102065:	e8 3b e0 ff ff       	call   f01000a5 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010206a:	83 ec 04             	sub    $0x4,%esp
f010206d:	6a 00                	push   $0x0
f010206f:	68 00 10 00 00       	push   $0x1000
f0102074:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f010207a:	e8 77 f3 ff ff       	call   f01013f6 <pgdir_walk>
f010207f:	83 c4 10             	add    $0x10,%esp
f0102082:	f6 00 02             	testb  $0x2,(%eax)
f0102085:	75 19                	jne    f01020a0 <mem_init+0xa9b>
f0102087:	68 c8 51 10 f0       	push   $0xf01051c8
f010208c:	68 bb 55 10 f0       	push   $0xf01055bb
f0102091:	68 53 03 00 00       	push   $0x353
f0102096:	68 95 55 10 f0       	push   $0xf0105595
f010209b:	e8 05 e0 ff ff       	call   f01000a5 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020a0:	83 ec 04             	sub    $0x4,%esp
f01020a3:	6a 00                	push   $0x0
f01020a5:	68 00 10 00 00       	push   $0x1000
f01020aa:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f01020b0:	e8 41 f3 ff ff       	call   f01013f6 <pgdir_walk>
f01020b5:	83 c4 10             	add    $0x10,%esp
f01020b8:	f6 00 04             	testb  $0x4,(%eax)
f01020bb:	74 19                	je     f01020d6 <mem_init+0xad1>
f01020bd:	68 fc 51 10 f0       	push   $0xf01051fc
f01020c2:	68 bb 55 10 f0       	push   $0xf01055bb
f01020c7:	68 54 03 00 00       	push   $0x354
f01020cc:	68 95 55 10 f0       	push   $0xf0105595
f01020d1:	e8 cf df ff ff       	call   f01000a5 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020d6:	6a 02                	push   $0x2
f01020d8:	68 00 00 40 00       	push   $0x400000
f01020dd:	56                   	push   %esi
f01020de:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f01020e4:	e8 b3 f4 ff ff       	call   f010159c <page_insert>
f01020e9:	83 c4 10             	add    $0x10,%esp
f01020ec:	85 c0                	test   %eax,%eax
f01020ee:	78 19                	js     f0102109 <mem_init+0xb04>
f01020f0:	68 34 52 10 f0       	push   $0xf0105234
f01020f5:	68 bb 55 10 f0       	push   $0xf01055bb
f01020fa:	68 57 03 00 00       	push   $0x357
f01020ff:	68 95 55 10 f0       	push   $0xf0105595
f0102104:	e8 9c df ff ff       	call   f01000a5 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102109:	6a 02                	push   $0x2
f010210b:	68 00 10 00 00       	push   $0x1000
f0102110:	57                   	push   %edi
f0102111:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0102117:	e8 80 f4 ff ff       	call   f010159c <page_insert>
f010211c:	83 c4 10             	add    $0x10,%esp
f010211f:	85 c0                	test   %eax,%eax
f0102121:	74 19                	je     f010213c <mem_init+0xb37>
f0102123:	68 6c 52 10 f0       	push   $0xf010526c
f0102128:	68 bb 55 10 f0       	push   $0xf01055bb
f010212d:	68 5a 03 00 00       	push   $0x35a
f0102132:	68 95 55 10 f0       	push   $0xf0105595
f0102137:	e8 69 df ff ff       	call   f01000a5 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010213c:	83 ec 04             	sub    $0x4,%esp
f010213f:	6a 00                	push   $0x0
f0102141:	68 00 10 00 00       	push   $0x1000
f0102146:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f010214c:	e8 a5 f2 ff ff       	call   f01013f6 <pgdir_walk>
f0102151:	83 c4 10             	add    $0x10,%esp
f0102154:	f6 00 04             	testb  $0x4,(%eax)
f0102157:	74 19                	je     f0102172 <mem_init+0xb6d>
f0102159:	68 fc 51 10 f0       	push   $0xf01051fc
f010215e:	68 bb 55 10 f0       	push   $0xf01055bb
f0102163:	68 5b 03 00 00       	push   $0x35b
f0102168:	68 95 55 10 f0       	push   $0xf0105595
f010216d:	e8 33 df ff ff       	call   f01000a5 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102172:	ba 00 00 00 00       	mov    $0x0,%edx
f0102177:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f010217c:	e8 be ed ff ff       	call   f0100f3f <check_va2pa>
f0102181:	89 fa                	mov    %edi,%edx
f0102183:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0102189:	c1 fa 03             	sar    $0x3,%edx
f010218c:	c1 e2 0c             	shl    $0xc,%edx
f010218f:	39 d0                	cmp    %edx,%eax
f0102191:	74 19                	je     f01021ac <mem_init+0xba7>
f0102193:	68 a8 52 10 f0       	push   $0xf01052a8
f0102198:	68 bb 55 10 f0       	push   $0xf01055bb
f010219d:	68 5e 03 00 00       	push   $0x35e
f01021a2:	68 95 55 10 f0       	push   $0xf0105595
f01021a7:	e8 f9 de ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021ac:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021b1:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f01021b6:	e8 84 ed ff ff       	call   f0100f3f <check_va2pa>
f01021bb:	89 fa                	mov    %edi,%edx
f01021bd:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f01021c3:	c1 fa 03             	sar    $0x3,%edx
f01021c6:	c1 e2 0c             	shl    $0xc,%edx
f01021c9:	39 d0                	cmp    %edx,%eax
f01021cb:	74 19                	je     f01021e6 <mem_init+0xbe1>
f01021cd:	68 d4 52 10 f0       	push   $0xf01052d4
f01021d2:	68 bb 55 10 f0       	push   $0xf01055bb
f01021d7:	68 5f 03 00 00       	push   $0x35f
f01021dc:	68 95 55 10 f0       	push   $0xf0105595
f01021e1:	e8 bf de ff ff       	call   f01000a5 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01021e6:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f01021eb:	74 19                	je     f0102206 <mem_init+0xc01>
f01021ed:	68 ac 57 10 f0       	push   $0xf01057ac
f01021f2:	68 bb 55 10 f0       	push   $0xf01055bb
f01021f7:	68 61 03 00 00       	push   $0x361
f01021fc:	68 95 55 10 f0       	push   $0xf0105595
f0102201:	e8 9f de ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 0);
f0102206:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010220b:	74 19                	je     f0102226 <mem_init+0xc21>
f010220d:	68 bd 57 10 f0       	push   $0xf01057bd
f0102212:	68 bb 55 10 f0       	push   $0xf01055bb
f0102217:	68 62 03 00 00       	push   $0x362
f010221c:	68 95 55 10 f0       	push   $0xf0105595
f0102221:	e8 7f de ff ff       	call   f01000a5 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102226:	83 ec 0c             	sub    $0xc,%esp
f0102229:	6a 00                	push   $0x0
f010222b:	e8 fe f0 ff ff       	call   f010132e <page_alloc>
f0102230:	83 c4 10             	add    $0x10,%esp
f0102233:	85 c0                	test   %eax,%eax
f0102235:	74 04                	je     f010223b <mem_init+0xc36>
f0102237:	39 c3                	cmp    %eax,%ebx
f0102239:	74 19                	je     f0102254 <mem_init+0xc4f>
f010223b:	68 04 53 10 f0       	push   $0xf0105304
f0102240:	68 bb 55 10 f0       	push   $0xf01055bb
f0102245:	68 65 03 00 00       	push   $0x365
f010224a:	68 95 55 10 f0       	push   $0xf0105595
f010224f:	e8 51 de ff ff       	call   f01000a5 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102254:	83 ec 08             	sub    $0x8,%esp
f0102257:	6a 00                	push   $0x0
f0102259:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f010225f:	e8 eb f2 ff ff       	call   f010154f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102264:	ba 00 00 00 00       	mov    $0x0,%edx
f0102269:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f010226e:	e8 cc ec ff ff       	call   f0100f3f <check_va2pa>
f0102273:	83 c4 10             	add    $0x10,%esp
f0102276:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102279:	74 19                	je     f0102294 <mem_init+0xc8f>
f010227b:	68 28 53 10 f0       	push   $0xf0105328
f0102280:	68 bb 55 10 f0       	push   $0xf01055bb
f0102285:	68 69 03 00 00       	push   $0x369
f010228a:	68 95 55 10 f0       	push   $0xf0105595
f010228f:	e8 11 de ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102294:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102299:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f010229e:	e8 9c ec ff ff       	call   f0100f3f <check_va2pa>
f01022a3:	89 fa                	mov    %edi,%edx
f01022a5:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f01022ab:	c1 fa 03             	sar    $0x3,%edx
f01022ae:	c1 e2 0c             	shl    $0xc,%edx
f01022b1:	39 d0                	cmp    %edx,%eax
f01022b3:	74 19                	je     f01022ce <mem_init+0xcc9>
f01022b5:	68 d4 52 10 f0       	push   $0xf01052d4
f01022ba:	68 bb 55 10 f0       	push   $0xf01055bb
f01022bf:	68 6a 03 00 00       	push   $0x36a
f01022c4:	68 95 55 10 f0       	push   $0xf0105595
f01022c9:	e8 d7 dd ff ff       	call   f01000a5 <_panic>
	assert(pp1->pp_ref == 1);
f01022ce:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01022d3:	74 19                	je     f01022ee <mem_init+0xce9>
f01022d5:	68 63 57 10 f0       	push   $0xf0105763
f01022da:	68 bb 55 10 f0       	push   $0xf01055bb
f01022df:	68 6b 03 00 00       	push   $0x36b
f01022e4:	68 95 55 10 f0       	push   $0xf0105595
f01022e9:	e8 b7 dd ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 0);
f01022ee:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022f3:	74 19                	je     f010230e <mem_init+0xd09>
f01022f5:	68 bd 57 10 f0       	push   $0xf01057bd
f01022fa:	68 bb 55 10 f0       	push   $0xf01055bb
f01022ff:	68 6c 03 00 00       	push   $0x36c
f0102304:	68 95 55 10 f0       	push   $0xf0105595
f0102309:	e8 97 dd ff ff       	call   f01000a5 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010230e:	83 ec 08             	sub    $0x8,%esp
f0102311:	68 00 10 00 00       	push   $0x1000
f0102316:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f010231c:	e8 2e f2 ff ff       	call   f010154f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102321:	ba 00 00 00 00       	mov    $0x0,%edx
f0102326:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f010232b:	e8 0f ec ff ff       	call   f0100f3f <check_va2pa>
f0102330:	83 c4 10             	add    $0x10,%esp
f0102333:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102336:	74 19                	je     f0102351 <mem_init+0xd4c>
f0102338:	68 28 53 10 f0       	push   $0xf0105328
f010233d:	68 bb 55 10 f0       	push   $0xf01055bb
f0102342:	68 70 03 00 00       	push   $0x370
f0102347:	68 95 55 10 f0       	push   $0xf0105595
f010234c:	e8 54 dd ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102351:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102356:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f010235b:	e8 df eb ff ff       	call   f0100f3f <check_va2pa>
f0102360:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102363:	74 19                	je     f010237e <mem_init+0xd79>
f0102365:	68 4c 53 10 f0       	push   $0xf010534c
f010236a:	68 bb 55 10 f0       	push   $0xf01055bb
f010236f:	68 71 03 00 00       	push   $0x371
f0102374:	68 95 55 10 f0       	push   $0xf0105595
f0102379:	e8 27 dd ff ff       	call   f01000a5 <_panic>
	assert(pp1->pp_ref == 0);
f010237e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102383:	74 19                	je     f010239e <mem_init+0xd99>
f0102385:	68 ce 57 10 f0       	push   $0xf01057ce
f010238a:	68 bb 55 10 f0       	push   $0xf01055bb
f010238f:	68 72 03 00 00       	push   $0x372
f0102394:	68 95 55 10 f0       	push   $0xf0105595
f0102399:	e8 07 dd ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 0);
f010239e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023a3:	74 19                	je     f01023be <mem_init+0xdb9>
f01023a5:	68 bd 57 10 f0       	push   $0xf01057bd
f01023aa:	68 bb 55 10 f0       	push   $0xf01055bb
f01023af:	68 73 03 00 00       	push   $0x373
f01023b4:	68 95 55 10 f0       	push   $0xf0105595
f01023b9:	e8 e7 dc ff ff       	call   f01000a5 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01023be:	83 ec 0c             	sub    $0xc,%esp
f01023c1:	6a 00                	push   $0x0
f01023c3:	e8 66 ef ff ff       	call   f010132e <page_alloc>
f01023c8:	83 c4 10             	add    $0x10,%esp
f01023cb:	85 c0                	test   %eax,%eax
f01023cd:	74 04                	je     f01023d3 <mem_init+0xdce>
f01023cf:	39 c7                	cmp    %eax,%edi
f01023d1:	74 19                	je     f01023ec <mem_init+0xde7>
f01023d3:	68 74 53 10 f0       	push   $0xf0105374
f01023d8:	68 bb 55 10 f0       	push   $0xf01055bb
f01023dd:	68 76 03 00 00       	push   $0x376
f01023e2:	68 95 55 10 f0       	push   $0xf0105595
f01023e7:	e8 b9 dc ff ff       	call   f01000a5 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01023ec:	83 ec 0c             	sub    $0xc,%esp
f01023ef:	6a 00                	push   $0x0
f01023f1:	e8 38 ef ff ff       	call   f010132e <page_alloc>
f01023f6:	83 c4 10             	add    $0x10,%esp
f01023f9:	85 c0                	test   %eax,%eax
f01023fb:	74 19                	je     f0102416 <mem_init+0xe11>
f01023fd:	68 11 57 10 f0       	push   $0xf0105711
f0102402:	68 bb 55 10 f0       	push   $0xf01055bb
f0102407:	68 79 03 00 00       	push   $0x379
f010240c:	68 95 55 10 f0       	push   $0xf0105595
f0102411:	e8 8f dc ff ff       	call   f01000a5 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102416:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f010241b:	8b 08                	mov    (%eax),%ecx
f010241d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102423:	89 f2                	mov    %esi,%edx
f0102425:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f010242b:	c1 fa 03             	sar    $0x3,%edx
f010242e:	c1 e2 0c             	shl    $0xc,%edx
f0102431:	39 d1                	cmp    %edx,%ecx
f0102433:	74 19                	je     f010244e <mem_init+0xe49>
f0102435:	68 50 50 10 f0       	push   $0xf0105050
f010243a:	68 bb 55 10 f0       	push   $0xf01055bb
f010243f:	68 7c 03 00 00       	push   $0x37c
f0102444:	68 95 55 10 f0       	push   $0xf0105595
f0102449:	e8 57 dc ff ff       	call   f01000a5 <_panic>
	kern_pgdir[0] = 0;
f010244e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102454:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102459:	74 19                	je     f0102474 <mem_init+0xe6f>
f010245b:	68 74 57 10 f0       	push   $0xf0105774
f0102460:	68 bb 55 10 f0       	push   $0xf01055bb
f0102465:	68 7e 03 00 00       	push   $0x37e
f010246a:	68 95 55 10 f0       	push   $0xf0105595
f010246f:	e8 31 dc ff ff       	call   f01000a5 <_panic>
	pp0->pp_ref = 0;
f0102474:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010247a:	83 ec 0c             	sub    $0xc,%esp
f010247d:	56                   	push   %esi
f010247e:	e8 35 ef ff ff       	call   f01013b8 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102483:	83 c4 0c             	add    $0xc,%esp
f0102486:	6a 01                	push   $0x1
f0102488:	68 00 10 40 00       	push   $0x401000
f010248d:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0102493:	e8 5e ef ff ff       	call   f01013f6 <pgdir_walk>
f0102498:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010249b:	8b 0d 88 6f 1d f0    	mov    0xf01d6f88,%ecx
f01024a1:	8b 51 04             	mov    0x4(%ecx),%edx
f01024a4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01024aa:	89 55 c4             	mov    %edx,-0x3c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024ad:	c1 ea 0c             	shr    $0xc,%edx
f01024b0:	83 c4 10             	add    $0x10,%esp
f01024b3:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f01024b9:	72 17                	jb     f01024d2 <mem_init+0xecd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024bb:	ff 75 c4             	pushl  -0x3c(%ebp)
f01024be:	68 34 4e 10 f0       	push   $0xf0104e34
f01024c3:	68 85 03 00 00       	push   $0x385
f01024c8:	68 95 55 10 f0       	push   $0xf0105595
f01024cd:	e8 d3 db ff ff       	call   f01000a5 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01024d2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01024d5:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01024db:	39 d0                	cmp    %edx,%eax
f01024dd:	74 19                	je     f01024f8 <mem_init+0xef3>
f01024df:	68 df 57 10 f0       	push   $0xf01057df
f01024e4:	68 bb 55 10 f0       	push   $0xf01055bb
f01024e9:	68 86 03 00 00       	push   $0x386
f01024ee:	68 95 55 10 f0       	push   $0xf0105595
f01024f3:	e8 ad db ff ff       	call   f01000a5 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01024f8:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01024ff:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102505:	89 f0                	mov    %esi,%eax
f0102507:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f010250d:	c1 f8 03             	sar    $0x3,%eax
f0102510:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102513:	89 c2                	mov    %eax,%edx
f0102515:	c1 ea 0c             	shr    $0xc,%edx
f0102518:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f010251e:	72 12                	jb     f0102532 <mem_init+0xf2d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102520:	50                   	push   %eax
f0102521:	68 34 4e 10 f0       	push   $0xf0104e34
f0102526:	6a 56                	push   $0x56
f0102528:	68 a1 55 10 f0       	push   $0xf01055a1
f010252d:	e8 73 db ff ff       	call   f01000a5 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102532:	83 ec 04             	sub    $0x4,%esp
f0102535:	68 00 10 00 00       	push   $0x1000
f010253a:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f010253f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102544:	50                   	push   %eax
f0102545:	e8 c3 1a 00 00       	call   f010400d <memset>
	page_free(pp0);
f010254a:	89 34 24             	mov    %esi,(%esp)
f010254d:	e8 66 ee ff ff       	call   f01013b8 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102552:	83 c4 0c             	add    $0xc,%esp
f0102555:	6a 01                	push   $0x1
f0102557:	6a 00                	push   $0x0
f0102559:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f010255f:	e8 92 ee ff ff       	call   f01013f6 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102564:	89 f2                	mov    %esi,%edx
f0102566:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f010256c:	c1 fa 03             	sar    $0x3,%edx
f010256f:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102572:	89 d0                	mov    %edx,%eax
f0102574:	c1 e8 0c             	shr    $0xc,%eax
f0102577:	83 c4 10             	add    $0x10,%esp
f010257a:	3b 05 84 6f 1d f0    	cmp    0xf01d6f84,%eax
f0102580:	72 12                	jb     f0102594 <mem_init+0xf8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102582:	52                   	push   %edx
f0102583:	68 34 4e 10 f0       	push   $0xf0104e34
f0102588:	6a 56                	push   $0x56
f010258a:	68 a1 55 10 f0       	push   $0xf01055a1
f010258f:	e8 11 db ff ff       	call   f01000a5 <_panic>
	return (void *)(pa + KERNBASE);
f0102594:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010259a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010259d:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f01025a4:	75 11                	jne    f01025b7 <mem_init+0xfb2>
f01025a6:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01025ac:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01025b2:	f6 00 01             	testb  $0x1,(%eax)
f01025b5:	74 19                	je     f01025d0 <mem_init+0xfcb>
f01025b7:	68 f7 57 10 f0       	push   $0xf01057f7
f01025bc:	68 bb 55 10 f0       	push   $0xf01055bb
f01025c1:	68 90 03 00 00       	push   $0x390
f01025c6:	68 95 55 10 f0       	push   $0xf0105595
f01025cb:	e8 d5 da ff ff       	call   f01000a5 <_panic>
f01025d0:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01025d3:	39 d0                	cmp    %edx,%eax
f01025d5:	75 db                	jne    f01025b2 <mem_init+0xfad>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025d7:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f01025dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025e2:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f01025e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025eb:	a3 ac 62 1d f0       	mov    %eax,0xf01d62ac

	// free the pages we took
	page_free(pp0);
f01025f0:	83 ec 0c             	sub    $0xc,%esp
f01025f3:	56                   	push   %esi
f01025f4:	e8 bf ed ff ff       	call   f01013b8 <page_free>
	page_free(pp1);
f01025f9:	89 3c 24             	mov    %edi,(%esp)
f01025fc:	e8 b7 ed ff ff       	call   f01013b8 <page_free>
	page_free(pp2);
f0102601:	89 1c 24             	mov    %ebx,(%esp)
f0102604:	e8 af ed ff ff       	call   f01013b8 <page_free>

	cprintf("check_page() succeeded!\n");
f0102609:	c7 04 24 0e 58 10 f0 	movl   $0xf010580e,(%esp)
f0102610:	e8 28 0b 00 00       	call   f010313d <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102615:	a1 8c 6f 1d f0       	mov    0xf01d6f8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010261a:	83 c4 10             	add    $0x10,%esp
f010261d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102622:	77 15                	ja     f0102639 <mem_init+0x1034>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102624:	50                   	push   %eax
f0102625:	68 74 4c 10 f0       	push   $0xf0104c74
f010262a:	68 b6 00 00 00       	push   $0xb6
f010262f:	68 95 55 10 f0       	push   $0xf0105595
f0102634:	e8 6c da ff ff       	call   f01000a5 <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102639:	8b 15 84 6f 1d f0    	mov    0xf01d6f84,%edx
f010263f:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102646:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f0102649:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f010264f:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102651:	05 00 00 00 10       	add    $0x10000000,%eax
f0102656:	50                   	push   %eax
f0102657:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010265c:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0102661:	e8 27 ee ff ff       	call   f010148d <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102666:	83 c4 10             	add    $0x10,%esp
f0102669:	ba 00 70 11 f0       	mov    $0xf0117000,%edx
f010266e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102674:	77 15                	ja     f010268b <mem_init+0x1086>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102676:	52                   	push   %edx
f0102677:	68 74 4c 10 f0       	push   $0xf0104c74
f010267c:	68 cf 00 00 00       	push   $0xcf
f0102681:	68 95 55 10 f0       	push   $0xf0105595
f0102686:	e8 1a da ff ff       	call   f01000a5 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f010268b:	83 ec 08             	sub    $0x8,%esp
f010268e:	6a 02                	push   $0x2
f0102690:	68 00 70 11 00       	push   $0x117000
f0102695:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010269a:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010269f:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f01026a4:	e8 e4 ed ff ff       	call   f010148d <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f01026a9:	83 c4 08             	add    $0x8,%esp
f01026ac:	6a 02                	push   $0x2
f01026ae:	6a 00                	push   $0x0
f01026b0:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026b5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026ba:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f01026bf:	e8 c9 ed ff ff       	call   f010148d <boot_map_region>
                    -KERNBASE,
                    0,
                    PTE_W);     
    // in 32-bit system, 2^32 - KERNBASE = - KERNBASE
   
    cprintf("!!!\n");
f01026c4:	c7 04 24 27 58 10 f0 	movl   $0xf0105827,(%esp)
f01026cb:	e8 6d 0a 00 00       	call   f010313d <cprintf>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026d0:	8b 1d 88 6f 1d f0    	mov    0xf01d6f88,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026d6:	a1 84 6f 1d f0       	mov    0xf01d6f84,%eax
f01026db:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f01026e2:	83 c4 10             	add    $0x10,%esp
f01026e5:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01026eb:	74 63                	je     f0102750 <mem_init+0x114b>
f01026ed:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026f2:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01026f8:	89 d8                	mov    %ebx,%eax
f01026fa:	e8 40 e8 ff ff       	call   f0100f3f <check_va2pa>
f01026ff:	8b 15 8c 6f 1d f0    	mov    0xf01d6f8c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102705:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010270b:	77 15                	ja     f0102722 <mem_init+0x111d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010270d:	52                   	push   %edx
f010270e:	68 74 4c 10 f0       	push   $0xf0104c74
f0102713:	68 d2 02 00 00       	push   $0x2d2
f0102718:	68 95 55 10 f0       	push   $0xf0105595
f010271d:	e8 83 d9 ff ff       	call   f01000a5 <_panic>
f0102722:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102729:	39 d0                	cmp    %edx,%eax
f010272b:	74 19                	je     f0102746 <mem_init+0x1141>
f010272d:	68 98 53 10 f0       	push   $0xf0105398
f0102732:	68 bb 55 10 f0       	push   $0xf01055bb
f0102737:	68 d2 02 00 00       	push   $0x2d2
f010273c:	68 95 55 10 f0       	push   $0xf0105595
f0102741:	e8 5f d9 ff ff       	call   f01000a5 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102746:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010274c:	39 f7                	cmp    %esi,%edi
f010274e:	77 a2                	ja     f01026f2 <mem_init+0x10ed>
f0102750:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102755:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f010275b:	89 d8                	mov    %ebx,%eax
f010275d:	e8 dd e7 ff ff       	call   f0100f3f <check_va2pa>
f0102762:	8b 15 b8 62 1d f0    	mov    0xf01d62b8,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102768:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010276e:	77 15                	ja     f0102785 <mem_init+0x1180>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102770:	52                   	push   %edx
f0102771:	68 74 4c 10 f0       	push   $0xf0104c74
f0102776:	68 d7 02 00 00       	push   $0x2d7
f010277b:	68 95 55 10 f0       	push   $0xf0105595
f0102780:	e8 20 d9 ff ff       	call   f01000a5 <_panic>
f0102785:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010278c:	39 d0                	cmp    %edx,%eax
f010278e:	74 19                	je     f01027a9 <mem_init+0x11a4>
f0102790:	68 cc 53 10 f0       	push   $0xf01053cc
f0102795:	68 bb 55 10 f0       	push   $0xf01055bb
f010279a:	68 d7 02 00 00       	push   $0x2d7
f010279f:	68 95 55 10 f0       	push   $0xf0105595
f01027a4:	e8 fc d8 ff ff       	call   f01000a5 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027a9:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027af:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f01027b5:	75 9e                	jne    f0102755 <mem_init+0x1150>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027b7:	a1 84 6f 1d f0       	mov    0xf01d6f84,%eax
f01027bc:	c1 e0 0c             	shl    $0xc,%eax
f01027bf:	74 41                	je     f0102802 <mem_init+0x11fd>
f01027c1:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01027c6:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f01027cc:	89 d8                	mov    %ebx,%eax
f01027ce:	e8 6c e7 ff ff       	call   f0100f3f <check_va2pa>
f01027d3:	39 c6                	cmp    %eax,%esi
f01027d5:	74 19                	je     f01027f0 <mem_init+0x11eb>
f01027d7:	68 00 54 10 f0       	push   $0xf0105400
f01027dc:	68 bb 55 10 f0       	push   $0xf01055bb
f01027e1:	68 db 02 00 00       	push   $0x2db
f01027e6:	68 95 55 10 f0       	push   $0xf0105595
f01027eb:	e8 b5 d8 ff ff       	call   f01000a5 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027f0:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027f6:	a1 84 6f 1d f0       	mov    0xf01d6f84,%eax
f01027fb:	c1 e0 0c             	shl    $0xc,%eax
f01027fe:	39 c6                	cmp    %eax,%esi
f0102800:	72 c4                	jb     f01027c6 <mem_init+0x11c1>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102802:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102807:	89 d8                	mov    %ebx,%eax
f0102809:	e8 31 e7 ff ff       	call   f0100f3f <check_va2pa>
f010280e:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102813:	bf 00 70 11 f0       	mov    $0xf0117000,%edi
f0102818:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010281e:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102821:	39 c2                	cmp    %eax,%edx
f0102823:	74 19                	je     f010283e <mem_init+0x1239>
f0102825:	68 28 54 10 f0       	push   $0xf0105428
f010282a:	68 bb 55 10 f0       	push   $0xf01055bb
f010282f:	68 df 02 00 00       	push   $0x2df
f0102834:	68 95 55 10 f0       	push   $0xf0105595
f0102839:	e8 67 d8 ff ff       	call   f01000a5 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010283e:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102844:	0f 85 25 04 00 00    	jne    f0102c6f <mem_init+0x166a>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010284a:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010284f:	89 d8                	mov    %ebx,%eax
f0102851:	e8 e9 e6 ff ff       	call   f0100f3f <check_va2pa>
f0102856:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102859:	74 19                	je     f0102874 <mem_init+0x126f>
f010285b:	68 70 54 10 f0       	push   $0xf0105470
f0102860:	68 bb 55 10 f0       	push   $0xf01055bb
f0102865:	68 e0 02 00 00       	push   $0x2e0
f010286a:	68 95 55 10 f0       	push   $0xf0105595
f010286f:	e8 31 d8 ff ff       	call   f01000a5 <_panic>
f0102874:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102879:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010287e:	72 2d                	jb     f01028ad <mem_init+0x12a8>
f0102880:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102885:	76 07                	jbe    f010288e <mem_init+0x1289>
f0102887:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010288c:	75 1f                	jne    f01028ad <mem_init+0x12a8>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010288e:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102892:	75 7e                	jne    f0102912 <mem_init+0x130d>
f0102894:	68 2c 58 10 f0       	push   $0xf010582c
f0102899:	68 bb 55 10 f0       	push   $0xf01055bb
f010289e:	68 e9 02 00 00       	push   $0x2e9
f01028a3:	68 95 55 10 f0       	push   $0xf0105595
f01028a8:	e8 f8 d7 ff ff       	call   f01000a5 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01028ad:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01028b2:	76 3f                	jbe    f01028f3 <mem_init+0x12ee>
				assert(pgdir[i] & PTE_P);
f01028b4:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01028b7:	f6 c2 01             	test   $0x1,%dl
f01028ba:	75 19                	jne    f01028d5 <mem_init+0x12d0>
f01028bc:	68 2c 58 10 f0       	push   $0xf010582c
f01028c1:	68 bb 55 10 f0       	push   $0xf01055bb
f01028c6:	68 ed 02 00 00       	push   $0x2ed
f01028cb:	68 95 55 10 f0       	push   $0xf0105595
f01028d0:	e8 d0 d7 ff ff       	call   f01000a5 <_panic>
				assert(pgdir[i] & PTE_W);
f01028d5:	f6 c2 02             	test   $0x2,%dl
f01028d8:	75 38                	jne    f0102912 <mem_init+0x130d>
f01028da:	68 3d 58 10 f0       	push   $0xf010583d
f01028df:	68 bb 55 10 f0       	push   $0xf01055bb
f01028e4:	68 ee 02 00 00       	push   $0x2ee
f01028e9:	68 95 55 10 f0       	push   $0xf0105595
f01028ee:	e8 b2 d7 ff ff       	call   f01000a5 <_panic>
			} else
				assert(pgdir[i] == 0);
f01028f3:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01028f7:	74 19                	je     f0102912 <mem_init+0x130d>
f01028f9:	68 4e 58 10 f0       	push   $0xf010584e
f01028fe:	68 bb 55 10 f0       	push   $0xf01055bb
f0102903:	68 f0 02 00 00       	push   $0x2f0
f0102908:	68 95 55 10 f0       	push   $0xf0105595
f010290d:	e8 93 d7 ff ff       	call   f01000a5 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102912:	40                   	inc    %eax
f0102913:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102918:	0f 85 5b ff ff ff    	jne    f0102879 <mem_init+0x1274>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010291e:	83 ec 0c             	sub    $0xc,%esp
f0102921:	68 a0 54 10 f0       	push   $0xf01054a0
f0102926:	e8 12 08 00 00       	call   f010313d <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010292b:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102930:	83 c4 10             	add    $0x10,%esp
f0102933:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102938:	77 15                	ja     f010294f <mem_init+0x134a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010293a:	50                   	push   %eax
f010293b:	68 74 4c 10 f0       	push   $0xf0104c74
f0102940:	68 ec 00 00 00       	push   $0xec
f0102945:	68 95 55 10 f0       	push   $0xf0105595
f010294a:	e8 56 d7 ff ff       	call   f01000a5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010294f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102954:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102957:	b8 00 00 00 00       	mov    $0x0,%eax
f010295c:	e8 67 e6 ff ff       	call   f0100fc8 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102961:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102964:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102969:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010296c:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010296f:	83 ec 0c             	sub    $0xc,%esp
f0102972:	6a 00                	push   $0x0
f0102974:	e8 b5 e9 ff ff       	call   f010132e <page_alloc>
f0102979:	89 c6                	mov    %eax,%esi
f010297b:	83 c4 10             	add    $0x10,%esp
f010297e:	85 c0                	test   %eax,%eax
f0102980:	75 19                	jne    f010299b <mem_init+0x1396>
f0102982:	68 66 56 10 f0       	push   $0xf0105666
f0102987:	68 bb 55 10 f0       	push   $0xf01055bb
f010298c:	68 ab 03 00 00       	push   $0x3ab
f0102991:	68 95 55 10 f0       	push   $0xf0105595
f0102996:	e8 0a d7 ff ff       	call   f01000a5 <_panic>
	assert((pp1 = page_alloc(0)));
f010299b:	83 ec 0c             	sub    $0xc,%esp
f010299e:	6a 00                	push   $0x0
f01029a0:	e8 89 e9 ff ff       	call   f010132e <page_alloc>
f01029a5:	89 c7                	mov    %eax,%edi
f01029a7:	83 c4 10             	add    $0x10,%esp
f01029aa:	85 c0                	test   %eax,%eax
f01029ac:	75 19                	jne    f01029c7 <mem_init+0x13c2>
f01029ae:	68 7c 56 10 f0       	push   $0xf010567c
f01029b3:	68 bb 55 10 f0       	push   $0xf01055bb
f01029b8:	68 ac 03 00 00       	push   $0x3ac
f01029bd:	68 95 55 10 f0       	push   $0xf0105595
f01029c2:	e8 de d6 ff ff       	call   f01000a5 <_panic>
	assert((pp2 = page_alloc(0)));
f01029c7:	83 ec 0c             	sub    $0xc,%esp
f01029ca:	6a 00                	push   $0x0
f01029cc:	e8 5d e9 ff ff       	call   f010132e <page_alloc>
f01029d1:	89 c3                	mov    %eax,%ebx
f01029d3:	83 c4 10             	add    $0x10,%esp
f01029d6:	85 c0                	test   %eax,%eax
f01029d8:	75 19                	jne    f01029f3 <mem_init+0x13ee>
f01029da:	68 92 56 10 f0       	push   $0xf0105692
f01029df:	68 bb 55 10 f0       	push   $0xf01055bb
f01029e4:	68 ad 03 00 00       	push   $0x3ad
f01029e9:	68 95 55 10 f0       	push   $0xf0105595
f01029ee:	e8 b2 d6 ff ff       	call   f01000a5 <_panic>
	page_free(pp0);
f01029f3:	83 ec 0c             	sub    $0xc,%esp
f01029f6:	56                   	push   %esi
f01029f7:	e8 bc e9 ff ff       	call   f01013b8 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029fc:	89 f8                	mov    %edi,%eax
f01029fe:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f0102a04:	c1 f8 03             	sar    $0x3,%eax
f0102a07:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a0a:	89 c2                	mov    %eax,%edx
f0102a0c:	c1 ea 0c             	shr    $0xc,%edx
f0102a0f:	83 c4 10             	add    $0x10,%esp
f0102a12:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f0102a18:	72 12                	jb     f0102a2c <mem_init+0x1427>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a1a:	50                   	push   %eax
f0102a1b:	68 34 4e 10 f0       	push   $0xf0104e34
f0102a20:	6a 56                	push   $0x56
f0102a22:	68 a1 55 10 f0       	push   $0xf01055a1
f0102a27:	e8 79 d6 ff ff       	call   f01000a5 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a2c:	83 ec 04             	sub    $0x4,%esp
f0102a2f:	68 00 10 00 00       	push   $0x1000
f0102a34:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102a36:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a3b:	50                   	push   %eax
f0102a3c:	e8 cc 15 00 00       	call   f010400d <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a41:	89 d8                	mov    %ebx,%eax
f0102a43:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f0102a49:	c1 f8 03             	sar    $0x3,%eax
f0102a4c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a4f:	89 c2                	mov    %eax,%edx
f0102a51:	c1 ea 0c             	shr    $0xc,%edx
f0102a54:	83 c4 10             	add    $0x10,%esp
f0102a57:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f0102a5d:	72 12                	jb     f0102a71 <mem_init+0x146c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a5f:	50                   	push   %eax
f0102a60:	68 34 4e 10 f0       	push   $0xf0104e34
f0102a65:	6a 56                	push   $0x56
f0102a67:	68 a1 55 10 f0       	push   $0xf01055a1
f0102a6c:	e8 34 d6 ff ff       	call   f01000a5 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102a71:	83 ec 04             	sub    $0x4,%esp
f0102a74:	68 00 10 00 00       	push   $0x1000
f0102a79:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102a7b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a80:	50                   	push   %eax
f0102a81:	e8 87 15 00 00       	call   f010400d <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102a86:	6a 02                	push   $0x2
f0102a88:	68 00 10 00 00       	push   $0x1000
f0102a8d:	57                   	push   %edi
f0102a8e:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0102a94:	e8 03 eb ff ff       	call   f010159c <page_insert>
	assert(pp1->pp_ref == 1);
f0102a99:	83 c4 20             	add    $0x20,%esp
f0102a9c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102aa1:	74 19                	je     f0102abc <mem_init+0x14b7>
f0102aa3:	68 63 57 10 f0       	push   $0xf0105763
f0102aa8:	68 bb 55 10 f0       	push   $0xf01055bb
f0102aad:	68 b2 03 00 00       	push   $0x3b2
f0102ab2:	68 95 55 10 f0       	push   $0xf0105595
f0102ab7:	e8 e9 d5 ff ff       	call   f01000a5 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102abc:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102ac3:	01 01 01 
f0102ac6:	74 19                	je     f0102ae1 <mem_init+0x14dc>
f0102ac8:	68 c0 54 10 f0       	push   $0xf01054c0
f0102acd:	68 bb 55 10 f0       	push   $0xf01055bb
f0102ad2:	68 b3 03 00 00       	push   $0x3b3
f0102ad7:	68 95 55 10 f0       	push   $0xf0105595
f0102adc:	e8 c4 d5 ff ff       	call   f01000a5 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ae1:	6a 02                	push   $0x2
f0102ae3:	68 00 10 00 00       	push   $0x1000
f0102ae8:	53                   	push   %ebx
f0102ae9:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0102aef:	e8 a8 ea ff ff       	call   f010159c <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102af4:	83 c4 10             	add    $0x10,%esp
f0102af7:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102afe:	02 02 02 
f0102b01:	74 19                	je     f0102b1c <mem_init+0x1517>
f0102b03:	68 e4 54 10 f0       	push   $0xf01054e4
f0102b08:	68 bb 55 10 f0       	push   $0xf01055bb
f0102b0d:	68 b5 03 00 00       	push   $0x3b5
f0102b12:	68 95 55 10 f0       	push   $0xf0105595
f0102b17:	e8 89 d5 ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 1);
f0102b1c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b21:	74 19                	je     f0102b3c <mem_init+0x1537>
f0102b23:	68 85 57 10 f0       	push   $0xf0105785
f0102b28:	68 bb 55 10 f0       	push   $0xf01055bb
f0102b2d:	68 b6 03 00 00       	push   $0x3b6
f0102b32:	68 95 55 10 f0       	push   $0xf0105595
f0102b37:	e8 69 d5 ff ff       	call   f01000a5 <_panic>
	assert(pp1->pp_ref == 0);
f0102b3c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102b41:	74 19                	je     f0102b5c <mem_init+0x1557>
f0102b43:	68 ce 57 10 f0       	push   $0xf01057ce
f0102b48:	68 bb 55 10 f0       	push   $0xf01055bb
f0102b4d:	68 b7 03 00 00       	push   $0x3b7
f0102b52:	68 95 55 10 f0       	push   $0xf0105595
f0102b57:	e8 49 d5 ff ff       	call   f01000a5 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102b5c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102b63:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b66:	89 d8                	mov    %ebx,%eax
f0102b68:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f0102b6e:	c1 f8 03             	sar    $0x3,%eax
f0102b71:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b74:	89 c2                	mov    %eax,%edx
f0102b76:	c1 ea 0c             	shr    $0xc,%edx
f0102b79:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f0102b7f:	72 12                	jb     f0102b93 <mem_init+0x158e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b81:	50                   	push   %eax
f0102b82:	68 34 4e 10 f0       	push   $0xf0104e34
f0102b87:	6a 56                	push   $0x56
f0102b89:	68 a1 55 10 f0       	push   $0xf01055a1
f0102b8e:	e8 12 d5 ff ff       	call   f01000a5 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102b93:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102b9a:	03 03 03 
f0102b9d:	74 19                	je     f0102bb8 <mem_init+0x15b3>
f0102b9f:	68 08 55 10 f0       	push   $0xf0105508
f0102ba4:	68 bb 55 10 f0       	push   $0xf01055bb
f0102ba9:	68 b9 03 00 00       	push   $0x3b9
f0102bae:	68 95 55 10 f0       	push   $0xf0105595
f0102bb3:	e8 ed d4 ff ff       	call   f01000a5 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102bb8:	83 ec 08             	sub    $0x8,%esp
f0102bbb:	68 00 10 00 00       	push   $0x1000
f0102bc0:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0102bc6:	e8 84 e9 ff ff       	call   f010154f <page_remove>
	assert(pp2->pp_ref == 0);
f0102bcb:	83 c4 10             	add    $0x10,%esp
f0102bce:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102bd3:	74 19                	je     f0102bee <mem_init+0x15e9>
f0102bd5:	68 bd 57 10 f0       	push   $0xf01057bd
f0102bda:	68 bb 55 10 f0       	push   $0xf01055bb
f0102bdf:	68 bb 03 00 00       	push   $0x3bb
f0102be4:	68 95 55 10 f0       	push   $0xf0105595
f0102be9:	e8 b7 d4 ff ff       	call   f01000a5 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102bee:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0102bf3:	8b 08                	mov    (%eax),%ecx
f0102bf5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bfb:	89 f2                	mov    %esi,%edx
f0102bfd:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0102c03:	c1 fa 03             	sar    $0x3,%edx
f0102c06:	c1 e2 0c             	shl    $0xc,%edx
f0102c09:	39 d1                	cmp    %edx,%ecx
f0102c0b:	74 19                	je     f0102c26 <mem_init+0x1621>
f0102c0d:	68 50 50 10 f0       	push   $0xf0105050
f0102c12:	68 bb 55 10 f0       	push   $0xf01055bb
f0102c17:	68 be 03 00 00       	push   $0x3be
f0102c1c:	68 95 55 10 f0       	push   $0xf0105595
f0102c21:	e8 7f d4 ff ff       	call   f01000a5 <_panic>
	kern_pgdir[0] = 0;
f0102c26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102c2c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c31:	74 19                	je     f0102c4c <mem_init+0x1647>
f0102c33:	68 74 57 10 f0       	push   $0xf0105774
f0102c38:	68 bb 55 10 f0       	push   $0xf01055bb
f0102c3d:	68 c0 03 00 00       	push   $0x3c0
f0102c42:	68 95 55 10 f0       	push   $0xf0105595
f0102c47:	e8 59 d4 ff ff       	call   f01000a5 <_panic>
	pp0->pp_ref = 0;
f0102c4c:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102c52:	83 ec 0c             	sub    $0xc,%esp
f0102c55:	56                   	push   %esi
f0102c56:	e8 5d e7 ff ff       	call   f01013b8 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102c5b:	c7 04 24 34 55 10 f0 	movl   $0xf0105534,(%esp)
f0102c62:	e8 d6 04 00 00       	call   f010313d <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c6a:	5b                   	pop    %ebx
f0102c6b:	5e                   	pop    %esi
f0102c6c:	5f                   	pop    %edi
f0102c6d:	c9                   	leave  
f0102c6e:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102c6f:	89 f2                	mov    %esi,%edx
f0102c71:	89 d8                	mov    %ebx,%eax
f0102c73:	e8 c7 e2 ff ff       	call   f0100f3f <check_va2pa>
f0102c78:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102c7e:	e9 9b fb ff ff       	jmp    f010281e <mem_init+0x1219>

f0102c83 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102c83:	55                   	push   %ebp
f0102c84:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f0102c86:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c8b:	c9                   	leave  
f0102c8c:	c3                   	ret    

f0102c8d <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102c8d:	55                   	push   %ebp
f0102c8e:	89 e5                	mov    %esp,%ebp
f0102c90:	53                   	push   %ebx
f0102c91:	83 ec 04             	sub    $0x4,%esp
f0102c94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102c97:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c9a:	83 c8 04             	or     $0x4,%eax
f0102c9d:	50                   	push   %eax
f0102c9e:	ff 75 10             	pushl  0x10(%ebp)
f0102ca1:	ff 75 0c             	pushl  0xc(%ebp)
f0102ca4:	53                   	push   %ebx
f0102ca5:	e8 d9 ff ff ff       	call   f0102c83 <user_mem_check>
f0102caa:	83 c4 10             	add    $0x10,%esp
f0102cad:	85 c0                	test   %eax,%eax
f0102caf:	79 1d                	jns    f0102cce <user_mem_assert+0x41>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102cb1:	83 ec 04             	sub    $0x4,%esp
f0102cb4:	6a 00                	push   $0x0
f0102cb6:	ff 73 48             	pushl  0x48(%ebx)
f0102cb9:	68 60 55 10 f0       	push   $0xf0105560
f0102cbe:	e8 7a 04 00 00       	call   f010313d <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102cc3:	89 1c 24             	mov    %ebx,(%esp)
f0102cc6:	e8 a7 03 00 00       	call   f0103072 <env_destroy>
f0102ccb:	83 c4 10             	add    $0x10,%esp
	}
}
f0102cce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102cd1:	c9                   	leave  
f0102cd2:	c3                   	ret    
	...

f0102cd4 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102cd4:	55                   	push   %ebp
f0102cd5:	89 e5                	mov    %esp,%ebp
f0102cd7:	53                   	push   %ebx
f0102cd8:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102cde:	8a 5d 10             	mov    0x10(%ebp),%bl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102ce1:	85 c0                	test   %eax,%eax
f0102ce3:	75 0e                	jne    f0102cf3 <envid2env+0x1f>
		*env_store = curenv;
f0102ce5:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax
f0102cea:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102cec:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cf1:	eb 55                	jmp    f0102d48 <envid2env+0x74>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102cf3:	89 c2                	mov    %eax,%edx
f0102cf5:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102cfb:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102cfe:	c1 e2 05             	shl    $0x5,%edx
f0102d01:	03 15 b8 62 1d f0    	add    0xf01d62b8,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102d07:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102d0b:	74 05                	je     f0102d12 <envid2env+0x3e>
f0102d0d:	39 42 48             	cmp    %eax,0x48(%edx)
f0102d10:	74 0d                	je     f0102d1f <envid2env+0x4b>
		*env_store = 0;
f0102d12:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102d18:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102d1d:	eb 29                	jmp    f0102d48 <envid2env+0x74>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102d1f:	84 db                	test   %bl,%bl
f0102d21:	74 1e                	je     f0102d41 <envid2env+0x6d>
f0102d23:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax
f0102d28:	39 c2                	cmp    %eax,%edx
f0102d2a:	74 15                	je     f0102d41 <envid2env+0x6d>
f0102d2c:	8b 58 48             	mov    0x48(%eax),%ebx
f0102d2f:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f0102d32:	74 0d                	je     f0102d41 <envid2env+0x6d>
		*env_store = 0;
f0102d34:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102d3a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102d3f:	eb 07                	jmp    f0102d48 <envid2env+0x74>
	}

	*env_store = e;
f0102d41:	89 11                	mov    %edx,(%ecx)
	return 0;
f0102d43:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d48:	5b                   	pop    %ebx
f0102d49:	c9                   	leave  
f0102d4a:	c3                   	ret    

f0102d4b <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102d4b:	55                   	push   %ebp
f0102d4c:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102d4e:	b8 30 13 12 f0       	mov    $0xf0121330,%eax
f0102d53:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102d56:	b8 23 00 00 00       	mov    $0x23,%eax
f0102d5b:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102d5d:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102d5f:	b0 10                	mov    $0x10,%al
f0102d61:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102d63:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102d65:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102d67:	ea 6e 2d 10 f0 08 00 	ljmp   $0x8,$0xf0102d6e
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102d6e:	b0 00                	mov    $0x0,%al
f0102d70:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102d73:	c9                   	leave  
f0102d74:	c3                   	ret    

f0102d75 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102d75:	55                   	push   %ebp
f0102d76:	89 e5                	mov    %esp,%ebp
	// Set up envs array
	// LAB 3: Your code here.

	// Per-CPU part of the initialization
	env_init_percpu();
f0102d78:	e8 ce ff ff ff       	call   f0102d4b <env_init_percpu>
}
f0102d7d:	c9                   	leave  
f0102d7e:	c3                   	ret    

f0102d7f <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102d7f:	55                   	push   %ebp
f0102d80:	89 e5                	mov    %esp,%ebp
f0102d82:	56                   	push   %esi
f0102d83:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102d84:	8b 1d c0 62 1d f0    	mov    0xf01d62c0,%ebx
f0102d8a:	85 db                	test   %ebx,%ebx
f0102d8c:	0f 84 0a 01 00 00    	je     f0102e9c <env_alloc+0x11d>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102d92:	83 ec 0c             	sub    $0xc,%esp
f0102d95:	6a 01                	push   $0x1
f0102d97:	e8 92 e5 ff ff       	call   f010132e <page_alloc>
f0102d9c:	83 c4 10             	add    $0x10,%esp
f0102d9f:	85 c0                	test   %eax,%eax
f0102da1:	0f 84 fc 00 00 00    	je     f0102ea3 <env_alloc+0x124>

	// LAB 3: Your code here.

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102da7:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102daa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102daf:	77 15                	ja     f0102dc6 <env_alloc+0x47>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102db1:	50                   	push   %eax
f0102db2:	68 74 4c 10 f0       	push   $0xf0104c74
f0102db7:	68 b9 00 00 00       	push   $0xb9
f0102dbc:	68 92 58 10 f0       	push   $0xf0105892
f0102dc1:	e8 df d2 ff ff       	call   f01000a5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102dc6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102dcc:	83 ca 05             	or     $0x5,%edx
f0102dcf:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102dd5:	8b 43 48             	mov    0x48(%ebx),%eax
f0102dd8:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102ddd:	89 c1                	mov    %eax,%ecx
f0102ddf:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0102de5:	7f 05                	jg     f0102dec <env_alloc+0x6d>
		generation = 1 << ENVGENSHIFT;
f0102de7:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0102dec:	89 d8                	mov    %ebx,%eax
f0102dee:	2b 05 b8 62 1d f0    	sub    0xf01d62b8,%eax
f0102df4:	c1 f8 05             	sar    $0x5,%eax
f0102df7:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0102dfa:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102dfd:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102e00:	89 d6                	mov    %edx,%esi
f0102e02:	c1 e6 08             	shl    $0x8,%esi
f0102e05:	01 f2                	add    %esi,%edx
f0102e07:	89 d6                	mov    %edx,%esi
f0102e09:	c1 e6 10             	shl    $0x10,%esi
f0102e0c:	01 f2                	add    %esi,%edx
f0102e0e:	8d 04 50             	lea    (%eax,%edx,2),%eax
f0102e11:	09 c1                	or     %eax,%ecx
f0102e13:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102e16:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e19:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102e1c:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102e23:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102e2a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102e31:	83 ec 04             	sub    $0x4,%esp
f0102e34:	6a 44                	push   $0x44
f0102e36:	6a 00                	push   $0x0
f0102e38:	53                   	push   %ebx
f0102e39:	e8 cf 11 00 00       	call   f010400d <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102e3e:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102e44:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102e4a:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102e50:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102e57:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102e5d:	8b 43 44             	mov    0x44(%ebx),%eax
f0102e60:	a3 c0 62 1d f0       	mov    %eax,0xf01d62c0
	*newenv_store = e;
f0102e65:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e68:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102e6a:	8b 53 48             	mov    0x48(%ebx),%edx
f0102e6d:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax
f0102e72:	83 c4 10             	add    $0x10,%esp
f0102e75:	85 c0                	test   %eax,%eax
f0102e77:	74 05                	je     f0102e7e <env_alloc+0xff>
f0102e79:	8b 40 48             	mov    0x48(%eax),%eax
f0102e7c:	eb 05                	jmp    f0102e83 <env_alloc+0x104>
f0102e7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e83:	83 ec 04             	sub    $0x4,%esp
f0102e86:	52                   	push   %edx
f0102e87:	50                   	push   %eax
f0102e88:	68 9d 58 10 f0       	push   $0xf010589d
f0102e8d:	e8 ab 02 00 00       	call   f010313d <cprintf>
	return 0;
f0102e92:	83 c4 10             	add    $0x10,%esp
f0102e95:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e9a:	eb 0c                	jmp    f0102ea8 <env_alloc+0x129>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102e9c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102ea1:	eb 05                	jmp    f0102ea8 <env_alloc+0x129>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102ea3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102ea8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102eab:	5b                   	pop    %ebx
f0102eac:	5e                   	pop    %esi
f0102ead:	c9                   	leave  
f0102eae:	c3                   	ret    

f0102eaf <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0102eaf:	55                   	push   %ebp
f0102eb0:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0102eb2:	c9                   	leave  
f0102eb3:	c3                   	ret    

f0102eb4 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102eb4:	55                   	push   %ebp
f0102eb5:	89 e5                	mov    %esp,%ebp
f0102eb7:	57                   	push   %edi
f0102eb8:	56                   	push   %esi
f0102eb9:	53                   	push   %ebx
f0102eba:	83 ec 1c             	sub    $0x1c,%esp
f0102ebd:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102ec0:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax
f0102ec5:	39 c7                	cmp    %eax,%edi
f0102ec7:	75 2c                	jne    f0102ef5 <env_free+0x41>
		lcr3(PADDR(kern_pgdir));
f0102ec9:	8b 15 88 6f 1d f0    	mov    0xf01d6f88,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ecf:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102ed5:	77 15                	ja     f0102eec <env_free+0x38>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ed7:	52                   	push   %edx
f0102ed8:	68 74 4c 10 f0       	push   $0xf0104c74
f0102edd:	68 68 01 00 00       	push   $0x168
f0102ee2:	68 92 58 10 f0       	push   $0xf0105892
f0102ee7:	e8 b9 d1 ff ff       	call   f01000a5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102eec:	81 c2 00 00 00 10    	add    $0x10000000,%edx
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102ef2:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102ef5:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102ef8:	ba 00 00 00 00       	mov    $0x0,%edx
f0102efd:	85 c0                	test   %eax,%eax
f0102eff:	74 03                	je     f0102f04 <env_free+0x50>
f0102f01:	8b 50 48             	mov    0x48(%eax),%edx
f0102f04:	83 ec 04             	sub    $0x4,%esp
f0102f07:	51                   	push   %ecx
f0102f08:	52                   	push   %edx
f0102f09:	68 b2 58 10 f0       	push   $0xf01058b2
f0102f0e:	e8 2a 02 00 00       	call   f010313d <cprintf>
f0102f13:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102f16:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102f1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f20:	c1 e0 02             	shl    $0x2,%eax
f0102f23:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102f26:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102f29:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102f2c:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0102f2f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102f35:	0f 84 ab 00 00 00    	je     f0102fe6 <env_free+0x132>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102f3b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f41:	89 f0                	mov    %esi,%eax
f0102f43:	c1 e8 0c             	shr    $0xc,%eax
f0102f46:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f49:	3b 05 84 6f 1d f0    	cmp    0xf01d6f84,%eax
f0102f4f:	72 15                	jb     f0102f66 <env_free+0xb2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f51:	56                   	push   %esi
f0102f52:	68 34 4e 10 f0       	push   $0xf0104e34
f0102f57:	68 77 01 00 00       	push   $0x177
f0102f5c:	68 92 58 10 f0       	push   $0xf0105892
f0102f61:	e8 3f d1 ff ff       	call   f01000a5 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102f66:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102f69:	c1 e2 16             	shl    $0x16,%edx
f0102f6c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102f6f:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102f74:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102f7b:	01 
f0102f7c:	74 17                	je     f0102f95 <env_free+0xe1>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102f7e:	83 ec 08             	sub    $0x8,%esp
f0102f81:	89 d8                	mov    %ebx,%eax
f0102f83:	c1 e0 0c             	shl    $0xc,%eax
f0102f86:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102f89:	50                   	push   %eax
f0102f8a:	ff 77 5c             	pushl  0x5c(%edi)
f0102f8d:	e8 bd e5 ff ff       	call   f010154f <page_remove>
f0102f92:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102f95:	43                   	inc    %ebx
f0102f96:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102f9c:	75 d6                	jne    f0102f74 <env_free+0xc0>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102f9e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102fa1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102fa4:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102fab:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102fae:	3b 05 84 6f 1d f0    	cmp    0xf01d6f84,%eax
f0102fb4:	72 14                	jb     f0102fca <env_free+0x116>
		panic("pa2page called with invalid pa");
f0102fb6:	83 ec 04             	sub    $0x4,%esp
f0102fb9:	68 1c 4f 10 f0       	push   $0xf0104f1c
f0102fbe:	6a 4f                	push   $0x4f
f0102fc0:	68 a1 55 10 f0       	push   $0xf01055a1
f0102fc5:	e8 db d0 ff ff       	call   f01000a5 <_panic>
		page_decref(pa2page(pa));
f0102fca:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0102fcd:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102fd0:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0102fd7:	03 05 8c 6f 1d f0    	add    0xf01d6f8c,%eax
f0102fdd:	50                   	push   %eax
f0102fde:	e8 f5 e3 ff ff       	call   f01013d8 <page_decref>
f0102fe3:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102fe6:	ff 45 e0             	incl   -0x20(%ebp)
f0102fe9:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0102ff0:	0f 85 27 ff ff ff    	jne    f0102f1d <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102ff6:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ff9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ffe:	77 15                	ja     f0103015 <env_free+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103000:	50                   	push   %eax
f0103001:	68 74 4c 10 f0       	push   $0xf0104c74
f0103006:	68 85 01 00 00       	push   $0x185
f010300b:	68 92 58 10 f0       	push   $0xf0105892
f0103010:	e8 90 d0 ff ff       	call   f01000a5 <_panic>
	e->env_pgdir = 0;
f0103015:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f010301c:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103021:	c1 e8 0c             	shr    $0xc,%eax
f0103024:	3b 05 84 6f 1d f0    	cmp    0xf01d6f84,%eax
f010302a:	72 14                	jb     f0103040 <env_free+0x18c>
		panic("pa2page called with invalid pa");
f010302c:	83 ec 04             	sub    $0x4,%esp
f010302f:	68 1c 4f 10 f0       	push   $0xf0104f1c
f0103034:	6a 4f                	push   $0x4f
f0103036:	68 a1 55 10 f0       	push   $0xf01055a1
f010303b:	e8 65 d0 ff ff       	call   f01000a5 <_panic>
	page_decref(pa2page(pa));
f0103040:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103043:	c1 e0 03             	shl    $0x3,%eax
f0103046:	03 05 8c 6f 1d f0    	add    0xf01d6f8c,%eax
f010304c:	50                   	push   %eax
f010304d:	e8 86 e3 ff ff       	call   f01013d8 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103052:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103059:	a1 c0 62 1d f0       	mov    0xf01d62c0,%eax
f010305e:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103061:	89 3d c0 62 1d f0    	mov    %edi,0xf01d62c0
f0103067:	83 c4 10             	add    $0x10,%esp
}
f010306a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010306d:	5b                   	pop    %ebx
f010306e:	5e                   	pop    %esi
f010306f:	5f                   	pop    %edi
f0103070:	c9                   	leave  
f0103071:	c3                   	ret    

f0103072 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103072:	55                   	push   %ebp
f0103073:	89 e5                	mov    %esp,%ebp
f0103075:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0103078:	ff 75 08             	pushl  0x8(%ebp)
f010307b:	e8 34 fe ff ff       	call   f0102eb4 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103080:	c7 04 24 5c 58 10 f0 	movl   $0xf010585c,(%esp)
f0103087:	e8 b1 00 00 00       	call   f010313d <cprintf>
f010308c:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f010308f:	83 ec 0c             	sub    $0xc,%esp
f0103092:	6a 00                	push   $0x0
f0103094:	e8 30 dd ff ff       	call   f0100dc9 <monitor>
f0103099:	83 c4 10             	add    $0x10,%esp
f010309c:	eb f1                	jmp    f010308f <env_destroy+0x1d>

f010309e <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010309e:	55                   	push   %ebp
f010309f:	89 e5                	mov    %esp,%ebp
f01030a1:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f01030a4:	8b 65 08             	mov    0x8(%ebp),%esp
f01030a7:	61                   	popa   
f01030a8:	07                   	pop    %es
f01030a9:	1f                   	pop    %ds
f01030aa:	83 c4 08             	add    $0x8,%esp
f01030ad:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01030ae:	68 c8 58 10 f0       	push   $0xf01058c8
f01030b3:	68 ad 01 00 00       	push   $0x1ad
f01030b8:	68 92 58 10 f0       	push   $0xf0105892
f01030bd:	e8 e3 cf ff ff       	call   f01000a5 <_panic>

f01030c2 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01030c2:	55                   	push   %ebp
f01030c3:	89 e5                	mov    %esp,%ebp
f01030c5:	83 ec 0c             	sub    $0xc,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f01030c8:	68 d4 58 10 f0       	push   $0xf01058d4
f01030cd:	68 cc 01 00 00       	push   $0x1cc
f01030d2:	68 92 58 10 f0       	push   $0xf0105892
f01030d7:	e8 c9 cf ff ff       	call   f01000a5 <_panic>

f01030dc <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01030dc:	55                   	push   %ebp
f01030dd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01030df:	ba 70 00 00 00       	mov    $0x70,%edx
f01030e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01030e7:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01030e8:	b2 71                	mov    $0x71,%dl
f01030ea:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01030eb:	0f b6 c0             	movzbl %al,%eax
}
f01030ee:	c9                   	leave  
f01030ef:	c3                   	ret    

f01030f0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01030f0:	55                   	push   %ebp
f01030f1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01030f3:	ba 70 00 00 00       	mov    $0x70,%edx
f01030f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01030fb:	ee                   	out    %al,(%dx)
f01030fc:	b2 71                	mov    $0x71,%dl
f01030fe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103101:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103102:	c9                   	leave  
f0103103:	c3                   	ret    

f0103104 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103104:	55                   	push   %ebp
f0103105:	89 e5                	mov    %esp,%ebp
f0103107:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010310a:	ff 75 08             	pushl  0x8(%ebp)
f010310d:	e8 b0 d4 ff ff       	call   f01005c2 <cputchar>
f0103112:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0103115:	c9                   	leave  
f0103116:	c3                   	ret    

f0103117 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103117:	55                   	push   %ebp
f0103118:	89 e5                	mov    %esp,%ebp
f010311a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010311d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103124:	ff 75 0c             	pushl  0xc(%ebp)
f0103127:	ff 75 08             	pushl  0x8(%ebp)
f010312a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010312d:	50                   	push   %eax
f010312e:	68 04 31 10 f0       	push   $0xf0103104
f0103133:	e8 3d 08 00 00       	call   f0103975 <vprintfmt>
	return cnt;
}
f0103138:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010313b:	c9                   	leave  
f010313c:	c3                   	ret    

f010313d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010313d:	55                   	push   %ebp
f010313e:	89 e5                	mov    %esp,%ebp
f0103140:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103143:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103146:	50                   	push   %eax
f0103147:	ff 75 08             	pushl  0x8(%ebp)
f010314a:	e8 c8 ff ff ff       	call   f0103117 <vcprintf>
	va_end(ap);

	return cnt;
}
f010314f:	c9                   	leave  
f0103150:	c3                   	ret    
f0103151:	00 00                	add    %al,(%eax)
	...

f0103154 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103154:	55                   	push   %ebp
f0103155:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103157:	c7 05 04 6b 1d f0 00 	movl   $0xf0000000,0xf01d6b04
f010315e:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103161:	66 c7 05 08 6b 1d f0 	movw   $0x10,0xf01d6b08
f0103168:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010316a:	66 c7 05 28 13 12 f0 	movw   $0x68,0xf0121328
f0103171:	68 00 
f0103173:	b8 00 6b 1d f0       	mov    $0xf01d6b00,%eax
f0103178:	66 a3 2a 13 12 f0    	mov    %ax,0xf012132a
f010317e:	89 c2                	mov    %eax,%edx
f0103180:	c1 ea 10             	shr    $0x10,%edx
f0103183:	88 15 2c 13 12 f0    	mov    %dl,0xf012132c
f0103189:	c6 05 2e 13 12 f0 40 	movb   $0x40,0xf012132e
f0103190:	c1 e8 18             	shr    $0x18,%eax
f0103193:	a2 2f 13 12 f0       	mov    %al,0xf012132f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103198:	c6 05 2d 13 12 f0 89 	movb   $0x89,0xf012132d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010319f:	b8 28 00 00 00       	mov    $0x28,%eax
f01031a4:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01031a7:	b8 38 13 12 f0       	mov    $0xf0121338,%eax
f01031ac:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01031af:	c9                   	leave  
f01031b0:	c3                   	ret    

f01031b1 <trap_init>:
}


void
trap_init(void)
{
f01031b1:	55                   	push   %ebp
f01031b2:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f01031b4:	e8 9b ff ff ff       	call   f0103154 <trap_init_percpu>
}
f01031b9:	c9                   	leave  
f01031ba:	c3                   	ret    

f01031bb <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01031bb:	55                   	push   %ebp
f01031bc:	89 e5                	mov    %esp,%ebp
f01031be:	53                   	push   %ebx
f01031bf:	83 ec 0c             	sub    $0xc,%esp
f01031c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01031c5:	ff 33                	pushl  (%ebx)
f01031c7:	68 f0 58 10 f0       	push   $0xf01058f0
f01031cc:	e8 6c ff ff ff       	call   f010313d <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01031d1:	83 c4 08             	add    $0x8,%esp
f01031d4:	ff 73 04             	pushl  0x4(%ebx)
f01031d7:	68 ff 58 10 f0       	push   $0xf01058ff
f01031dc:	e8 5c ff ff ff       	call   f010313d <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01031e1:	83 c4 08             	add    $0x8,%esp
f01031e4:	ff 73 08             	pushl  0x8(%ebx)
f01031e7:	68 0e 59 10 f0       	push   $0xf010590e
f01031ec:	e8 4c ff ff ff       	call   f010313d <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01031f1:	83 c4 08             	add    $0x8,%esp
f01031f4:	ff 73 0c             	pushl  0xc(%ebx)
f01031f7:	68 1d 59 10 f0       	push   $0xf010591d
f01031fc:	e8 3c ff ff ff       	call   f010313d <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103201:	83 c4 08             	add    $0x8,%esp
f0103204:	ff 73 10             	pushl  0x10(%ebx)
f0103207:	68 2c 59 10 f0       	push   $0xf010592c
f010320c:	e8 2c ff ff ff       	call   f010313d <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103211:	83 c4 08             	add    $0x8,%esp
f0103214:	ff 73 14             	pushl  0x14(%ebx)
f0103217:	68 3b 59 10 f0       	push   $0xf010593b
f010321c:	e8 1c ff ff ff       	call   f010313d <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103221:	83 c4 08             	add    $0x8,%esp
f0103224:	ff 73 18             	pushl  0x18(%ebx)
f0103227:	68 4a 59 10 f0       	push   $0xf010594a
f010322c:	e8 0c ff ff ff       	call   f010313d <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103231:	83 c4 08             	add    $0x8,%esp
f0103234:	ff 73 1c             	pushl  0x1c(%ebx)
f0103237:	68 59 59 10 f0       	push   $0xf0105959
f010323c:	e8 fc fe ff ff       	call   f010313d <cprintf>
f0103241:	83 c4 10             	add    $0x10,%esp
}
f0103244:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103247:	c9                   	leave  
f0103248:	c3                   	ret    

f0103249 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103249:	55                   	push   %ebp
f010324a:	89 e5                	mov    %esp,%ebp
f010324c:	53                   	push   %ebx
f010324d:	83 ec 0c             	sub    $0xc,%esp
f0103250:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103253:	53                   	push   %ebx
f0103254:	68 8f 5a 10 f0       	push   $0xf0105a8f
f0103259:	e8 df fe ff ff       	call   f010313d <cprintf>
	print_regs(&tf->tf_regs);
f010325e:	89 1c 24             	mov    %ebx,(%esp)
f0103261:	e8 55 ff ff ff       	call   f01031bb <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103266:	83 c4 08             	add    $0x8,%esp
f0103269:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010326d:	50                   	push   %eax
f010326e:	68 aa 59 10 f0       	push   $0xf01059aa
f0103273:	e8 c5 fe ff ff       	call   f010313d <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103278:	83 c4 08             	add    $0x8,%esp
f010327b:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010327f:	50                   	push   %eax
f0103280:	68 bd 59 10 f0       	push   $0xf01059bd
f0103285:	e8 b3 fe ff ff       	call   f010313d <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010328a:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010328d:	83 c4 10             	add    $0x10,%esp
f0103290:	83 f8 13             	cmp    $0x13,%eax
f0103293:	77 09                	ja     f010329e <print_trapframe+0x55>
		return excnames[trapno];
f0103295:	8b 14 85 60 5c 10 f0 	mov    -0xfefa3a0(,%eax,4),%edx
f010329c:	eb 11                	jmp    f01032af <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
f010329e:	83 f8 30             	cmp    $0x30,%eax
f01032a1:	75 07                	jne    f01032aa <print_trapframe+0x61>
		return "System call";
f01032a3:	ba 68 59 10 f0       	mov    $0xf0105968,%edx
f01032a8:	eb 05                	jmp    f01032af <print_trapframe+0x66>
	return "(unknown trap)";
f01032aa:	ba 74 59 10 f0       	mov    $0xf0105974,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01032af:	83 ec 04             	sub    $0x4,%esp
f01032b2:	52                   	push   %edx
f01032b3:	50                   	push   %eax
f01032b4:	68 d0 59 10 f0       	push   $0xf01059d0
f01032b9:	e8 7f fe ff ff       	call   f010313d <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01032be:	83 c4 10             	add    $0x10,%esp
f01032c1:	3b 1d e0 6a 1d f0    	cmp    0xf01d6ae0,%ebx
f01032c7:	75 1a                	jne    f01032e3 <print_trapframe+0x9a>
f01032c9:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01032cd:	75 14                	jne    f01032e3 <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01032cf:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01032d2:	83 ec 08             	sub    $0x8,%esp
f01032d5:	50                   	push   %eax
f01032d6:	68 e2 59 10 f0       	push   $0xf01059e2
f01032db:	e8 5d fe ff ff       	call   f010313d <cprintf>
f01032e0:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01032e3:	83 ec 08             	sub    $0x8,%esp
f01032e6:	ff 73 2c             	pushl  0x2c(%ebx)
f01032e9:	68 f1 59 10 f0       	push   $0xf01059f1
f01032ee:	e8 4a fe ff ff       	call   f010313d <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01032f3:	83 c4 10             	add    $0x10,%esp
f01032f6:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01032fa:	75 45                	jne    f0103341 <print_trapframe+0xf8>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01032fc:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01032ff:	a8 01                	test   $0x1,%al
f0103301:	74 07                	je     f010330a <print_trapframe+0xc1>
f0103303:	b9 83 59 10 f0       	mov    $0xf0105983,%ecx
f0103308:	eb 05                	jmp    f010330f <print_trapframe+0xc6>
f010330a:	b9 8e 59 10 f0       	mov    $0xf010598e,%ecx
f010330f:	a8 02                	test   $0x2,%al
f0103311:	74 07                	je     f010331a <print_trapframe+0xd1>
f0103313:	ba 9a 59 10 f0       	mov    $0xf010599a,%edx
f0103318:	eb 05                	jmp    f010331f <print_trapframe+0xd6>
f010331a:	ba a0 59 10 f0       	mov    $0xf01059a0,%edx
f010331f:	a8 04                	test   $0x4,%al
f0103321:	74 07                	je     f010332a <print_trapframe+0xe1>
f0103323:	b8 a5 59 10 f0       	mov    $0xf01059a5,%eax
f0103328:	eb 05                	jmp    f010332f <print_trapframe+0xe6>
f010332a:	b8 ba 5a 10 f0       	mov    $0xf0105aba,%eax
f010332f:	51                   	push   %ecx
f0103330:	52                   	push   %edx
f0103331:	50                   	push   %eax
f0103332:	68 ff 59 10 f0       	push   $0xf01059ff
f0103337:	e8 01 fe ff ff       	call   f010313d <cprintf>
f010333c:	83 c4 10             	add    $0x10,%esp
f010333f:	eb 10                	jmp    f0103351 <print_trapframe+0x108>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103341:	83 ec 0c             	sub    $0xc,%esp
f0103344:	68 45 47 10 f0       	push   $0xf0104745
f0103349:	e8 ef fd ff ff       	call   f010313d <cprintf>
f010334e:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103351:	83 ec 08             	sub    $0x8,%esp
f0103354:	ff 73 30             	pushl  0x30(%ebx)
f0103357:	68 0e 5a 10 f0       	push   $0xf0105a0e
f010335c:	e8 dc fd ff ff       	call   f010313d <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103361:	83 c4 08             	add    $0x8,%esp
f0103364:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103368:	50                   	push   %eax
f0103369:	68 1d 5a 10 f0       	push   $0xf0105a1d
f010336e:	e8 ca fd ff ff       	call   f010313d <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103373:	83 c4 08             	add    $0x8,%esp
f0103376:	ff 73 38             	pushl  0x38(%ebx)
f0103379:	68 30 5a 10 f0       	push   $0xf0105a30
f010337e:	e8 ba fd ff ff       	call   f010313d <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103383:	83 c4 10             	add    $0x10,%esp
f0103386:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010338a:	74 25                	je     f01033b1 <print_trapframe+0x168>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010338c:	83 ec 08             	sub    $0x8,%esp
f010338f:	ff 73 3c             	pushl  0x3c(%ebx)
f0103392:	68 3f 5a 10 f0       	push   $0xf0105a3f
f0103397:	e8 a1 fd ff ff       	call   f010313d <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010339c:	83 c4 08             	add    $0x8,%esp
f010339f:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01033a3:	50                   	push   %eax
f01033a4:	68 4e 5a 10 f0       	push   $0xf0105a4e
f01033a9:	e8 8f fd ff ff       	call   f010313d <cprintf>
f01033ae:	83 c4 10             	add    $0x10,%esp
	}
}
f01033b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033b4:	c9                   	leave  
f01033b5:	c3                   	ret    

f01033b6 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01033b6:	55                   	push   %ebp
f01033b7:	89 e5                	mov    %esp,%ebp
f01033b9:	57                   	push   %edi
f01033ba:	56                   	push   %esi
f01033bb:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01033be:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01033bf:	9c                   	pushf  
f01033c0:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01033c1:	f6 c4 02             	test   $0x2,%ah
f01033c4:	74 19                	je     f01033df <trap+0x29>
f01033c6:	68 61 5a 10 f0       	push   $0xf0105a61
f01033cb:	68 bb 55 10 f0       	push   $0xf01055bb
f01033d0:	68 a7 00 00 00       	push   $0xa7
f01033d5:	68 7a 5a 10 f0       	push   $0xf0105a7a
f01033da:	e8 c6 cc ff ff       	call   f01000a5 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01033df:	83 ec 08             	sub    $0x8,%esp
f01033e2:	56                   	push   %esi
f01033e3:	68 86 5a 10 f0       	push   $0xf0105a86
f01033e8:	e8 50 fd ff ff       	call   f010313d <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01033ed:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01033f1:	83 e0 03             	and    $0x3,%eax
f01033f4:	83 c4 10             	add    $0x10,%esp
f01033f7:	83 f8 03             	cmp    $0x3,%eax
f01033fa:	75 31                	jne    f010342d <trap+0x77>
		// Trapped from user mode.
		assert(curenv);
f01033fc:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax
f0103401:	85 c0                	test   %eax,%eax
f0103403:	75 19                	jne    f010341e <trap+0x68>
f0103405:	68 a1 5a 10 f0       	push   $0xf0105aa1
f010340a:	68 bb 55 10 f0       	push   $0xf01055bb
f010340f:	68 ad 00 00 00       	push   $0xad
f0103414:	68 7a 5a 10 f0       	push   $0xf0105a7a
f0103419:	e8 87 cc ff ff       	call   f01000a5 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010341e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103423:	89 c7                	mov    %eax,%edi
f0103425:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103427:	8b 35 bc 62 1d f0    	mov    0xf01d62bc,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010342d:	89 35 e0 6a 1d f0    	mov    %esi,0xf01d6ae0
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103433:	83 ec 0c             	sub    $0xc,%esp
f0103436:	56                   	push   %esi
f0103437:	e8 0d fe ff ff       	call   f0103249 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010343c:	83 c4 10             	add    $0x10,%esp
f010343f:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103444:	75 17                	jne    f010345d <trap+0xa7>
		panic("unhandled trap in kernel");
f0103446:	83 ec 04             	sub    $0x4,%esp
f0103449:	68 a8 5a 10 f0       	push   $0xf0105aa8
f010344e:	68 96 00 00 00       	push   $0x96
f0103453:	68 7a 5a 10 f0       	push   $0xf0105a7a
f0103458:	e8 48 cc ff ff       	call   f01000a5 <_panic>
	else {
		env_destroy(curenv);
f010345d:	83 ec 0c             	sub    $0xc,%esp
f0103460:	ff 35 bc 62 1d f0    	pushl  0xf01d62bc
f0103466:	e8 07 fc ff ff       	call   f0103072 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010346b:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax
f0103470:	83 c4 10             	add    $0x10,%esp
f0103473:	85 c0                	test   %eax,%eax
f0103475:	74 06                	je     f010347d <trap+0xc7>
f0103477:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010347b:	74 19                	je     f0103496 <trap+0xe0>
f010347d:	68 04 5c 10 f0       	push   $0xf0105c04
f0103482:	68 bb 55 10 f0       	push   $0xf01055bb
f0103487:	68 bf 00 00 00       	push   $0xbf
f010348c:	68 7a 5a 10 f0       	push   $0xf0105a7a
f0103491:	e8 0f cc ff ff       	call   f01000a5 <_panic>
	env_run(curenv);
f0103496:	83 ec 0c             	sub    $0xc,%esp
f0103499:	50                   	push   %eax
f010349a:	e8 23 fc ff ff       	call   f01030c2 <env_run>

f010349f <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010349f:	55                   	push   %ebp
f01034a0:	89 e5                	mov    %esp,%ebp
f01034a2:	53                   	push   %ebx
f01034a3:	83 ec 04             	sub    $0x4,%esp
f01034a6:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01034a9:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01034ac:	ff 73 30             	pushl  0x30(%ebx)
f01034af:	50                   	push   %eax
		curenv->env_id, fault_va, tf->tf_eip);
f01034b0:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01034b5:	ff 70 48             	pushl  0x48(%eax)
f01034b8:	68 30 5c 10 f0       	push   $0xf0105c30
f01034bd:	e8 7b fc ff ff       	call   f010313d <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01034c2:	89 1c 24             	mov    %ebx,(%esp)
f01034c5:	e8 7f fd ff ff       	call   f0103249 <print_trapframe>
	env_destroy(curenv);
f01034ca:	83 c4 04             	add    $0x4,%esp
f01034cd:	ff 35 bc 62 1d f0    	pushl  0xf01d62bc
f01034d3:	e8 9a fb ff ff       	call   f0103072 <env_destroy>
f01034d8:	83 c4 10             	add    $0x10,%esp
}
f01034db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034de:	c9                   	leave  
f01034df:	c3                   	ret    

f01034e0 <syscall>:
f01034e0:	55                   	push   %ebp
f01034e1:	89 e5                	mov    %esp,%ebp
f01034e3:	83 ec 0c             	sub    $0xc,%esp
f01034e6:	68 b0 5c 10 f0       	push   $0xf0105cb0
f01034eb:	6a 49                	push   $0x49
f01034ed:	68 c8 5c 10 f0       	push   $0xf0105cc8
f01034f2:	e8 ae cb ff ff       	call   f01000a5 <_panic>
	...

f01034f8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01034f8:	55                   	push   %ebp
f01034f9:	89 e5                	mov    %esp,%ebp
f01034fb:	57                   	push   %edi
f01034fc:	56                   	push   %esi
f01034fd:	53                   	push   %ebx
f01034fe:	83 ec 14             	sub    $0x14,%esp
f0103501:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103504:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103507:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010350a:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f010350d:	8b 1a                	mov    (%edx),%ebx
f010350f:	8b 01                	mov    (%ecx),%eax
f0103511:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0103514:	39 c3                	cmp    %eax,%ebx
f0103516:	0f 8f 97 00 00 00    	jg     f01035b3 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f010351c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103523:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103526:	01 d8                	add    %ebx,%eax
f0103528:	89 c7                	mov    %eax,%edi
f010352a:	c1 ef 1f             	shr    $0x1f,%edi
f010352d:	01 c7                	add    %eax,%edi
f010352f:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103531:	39 df                	cmp    %ebx,%edi
f0103533:	7c 31                	jl     f0103566 <stab_binsearch+0x6e>
f0103535:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103538:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010353b:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103540:	39 f0                	cmp    %esi,%eax
f0103542:	0f 84 b3 00 00 00    	je     f01035fb <stab_binsearch+0x103>
f0103548:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010354c:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103550:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103552:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103553:	39 d8                	cmp    %ebx,%eax
f0103555:	7c 0f                	jl     f0103566 <stab_binsearch+0x6e>
f0103557:	0f b6 0a             	movzbl (%edx),%ecx
f010355a:	83 ea 0c             	sub    $0xc,%edx
f010355d:	39 f1                	cmp    %esi,%ecx
f010355f:	75 f1                	jne    f0103552 <stab_binsearch+0x5a>
f0103561:	e9 97 00 00 00       	jmp    f01035fd <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103566:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103569:	eb 39                	jmp    f01035a4 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010356b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010356e:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0103570:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103573:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010357a:	eb 28                	jmp    f01035a4 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010357c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010357f:	76 12                	jbe    f0103593 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0103581:	48                   	dec    %eax
f0103582:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103585:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103588:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010358a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103591:	eb 11                	jmp    f01035a4 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103593:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103596:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103598:	ff 45 0c             	incl   0xc(%ebp)
f010359b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010359d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01035a4:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f01035a7:	0f 8d 76 ff ff ff    	jge    f0103523 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01035ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01035b1:	75 0d                	jne    f01035c0 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f01035b3:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01035b6:	8b 03                	mov    (%ebx),%eax
f01035b8:	48                   	dec    %eax
f01035b9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035bc:	89 02                	mov    %eax,(%edx)
f01035be:	eb 55                	jmp    f0103615 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01035c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01035c3:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01035c5:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01035c8:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01035ca:	39 c1                	cmp    %eax,%ecx
f01035cc:	7d 26                	jge    f01035f4 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01035ce:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01035d1:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01035d4:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01035d9:	39 f2                	cmp    %esi,%edx
f01035db:	74 17                	je     f01035f4 <stab_binsearch+0xfc>
f01035dd:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01035e1:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01035e5:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01035e6:	39 c1                	cmp    %eax,%ecx
f01035e8:	7d 0a                	jge    f01035f4 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01035ea:	0f b6 1a             	movzbl (%edx),%ebx
f01035ed:	83 ea 0c             	sub    $0xc,%edx
f01035f0:	39 f3                	cmp    %esi,%ebx
f01035f2:	75 f1                	jne    f01035e5 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f01035f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01035f7:	89 02                	mov    %eax,(%edx)
f01035f9:	eb 1a                	jmp    f0103615 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01035fb:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01035fd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103600:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103603:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103607:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010360a:	0f 82 5b ff ff ff    	jb     f010356b <stab_binsearch+0x73>
f0103610:	e9 67 ff ff ff       	jmp    f010357c <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103615:	83 c4 14             	add    $0x14,%esp
f0103618:	5b                   	pop    %ebx
f0103619:	5e                   	pop    %esi
f010361a:	5f                   	pop    %edi
f010361b:	c9                   	leave  
f010361c:	c3                   	ret    

f010361d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010361d:	55                   	push   %ebp
f010361e:	89 e5                	mov    %esp,%ebp
f0103620:	57                   	push   %edi
f0103621:	56                   	push   %esi
f0103622:	53                   	push   %ebx
f0103623:	83 ec 2c             	sub    $0x2c,%esp
f0103626:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103629:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010362c:	c7 03 d7 5c 10 f0    	movl   $0xf0105cd7,(%ebx)
	info->eip_line = 0;
f0103632:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103639:	c7 43 08 d7 5c 10 f0 	movl   $0xf0105cd7,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103640:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103647:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010364a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103651:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0103657:	77 1e                	ja     f0103677 <debuginfo_eip+0x5a>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103659:	a1 00 00 20 00       	mov    0x200000,%eax
f010365e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f0103661:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103666:	8b 15 08 00 20 00    	mov    0x200008,%edx
f010366c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f010366f:	8b 35 0c 00 20 00    	mov    0x20000c,%esi
f0103675:	eb 18                	jmp    f010368f <debuginfo_eip+0x72>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103677:	be 62 6d 11 f0       	mov    $0xf0116d62,%esi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010367c:	c7 45 d4 61 e8 10 f0 	movl   $0xf010e861,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103683:	b8 60 e8 10 f0       	mov    $0xf010e860,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103688:	c7 45 d0 f0 5e 10 f0 	movl   $0xf0105ef0,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010368f:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0103692:	0f 83 5c 01 00 00    	jae    f01037f4 <debuginfo_eip+0x1d7>
f0103698:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f010369c:	0f 85 59 01 00 00    	jne    f01037fb <debuginfo_eip+0x1de>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01036a2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01036a9:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01036ac:	c1 f8 02             	sar    $0x2,%eax
f01036af:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01036b5:	48                   	dec    %eax
f01036b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01036b9:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01036bc:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01036bf:	57                   	push   %edi
f01036c0:	6a 64                	push   $0x64
f01036c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01036c5:	e8 2e fe ff ff       	call   f01034f8 <stab_binsearch>
	if (lfile == 0)
f01036ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01036cd:	83 c4 08             	add    $0x8,%esp
		return -1;
f01036d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01036d5:	85 d2                	test   %edx,%edx
f01036d7:	0f 84 2a 01 00 00    	je     f0103807 <debuginfo_eip+0x1ea>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01036dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01036e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01036e6:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01036e9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01036ec:	57                   	push   %edi
f01036ed:	6a 24                	push   $0x24
f01036ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01036f2:	e8 01 fe ff ff       	call   f01034f8 <stab_binsearch>

	if (lfun <= rfun) {
f01036f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01036fa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01036fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103700:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103703:	83 c4 08             	add    $0x8,%esp
f0103706:	39 c1                	cmp    %eax,%ecx
f0103708:	7f 21                	jg     f010372b <debuginfo_eip+0x10e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010370a:	6b c1 0c             	imul   $0xc,%ecx,%eax
f010370d:	03 45 d0             	add    -0x30(%ebp),%eax
f0103710:	8b 10                	mov    (%eax),%edx
f0103712:	89 f1                	mov    %esi,%ecx
f0103714:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f0103717:	39 ca                	cmp    %ecx,%edx
f0103719:	73 06                	jae    f0103721 <debuginfo_eip+0x104>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010371b:	03 55 d4             	add    -0x2c(%ebp),%edx
f010371e:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103721:	8b 40 08             	mov    0x8(%eax),%eax
f0103724:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103727:	29 c7                	sub    %eax,%edi
f0103729:	eb 0f                	jmp    f010373a <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010372b:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f010372e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103731:	89 55 cc             	mov    %edx,-0x34(%ebp)
		rline = rfile;
f0103734:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103737:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010373a:	83 ec 08             	sub    $0x8,%esp
f010373d:	6a 3a                	push   $0x3a
f010373f:	ff 73 08             	pushl  0x8(%ebx)
f0103742:	e8 a4 08 00 00       	call   f0103feb <strfind>
f0103747:	2b 43 08             	sub    0x8(%ebx),%eax
f010374a:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f010374d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103750:	89 45 dc             	mov    %eax,-0x24(%ebp)
    rfun = rline;
f0103753:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0103756:	89 55 d8             	mov    %edx,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0103759:	83 c4 08             	add    $0x8,%esp
f010375c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010375f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103762:	57                   	push   %edi
f0103763:	6a 44                	push   $0x44
f0103765:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103768:	e8 8b fd ff ff       	call   f01034f8 <stab_binsearch>
    if (lfun <= rfun) {
f010376d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103770:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0103773:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0103778:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f010377b:	0f 8f 86 00 00 00    	jg     f0103807 <debuginfo_eip+0x1ea>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0103781:	6b ca 0c             	imul   $0xc,%edx,%ecx
f0103784:	03 4d d0             	add    -0x30(%ebp),%ecx
f0103787:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f010378b:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010378e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103791:	89 45 cc             	mov    %eax,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103794:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103797:	eb 04                	jmp    f010379d <debuginfo_eip+0x180>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103799:	4a                   	dec    %edx
f010379a:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010379d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f01037a0:	7c 19                	jl     f01037bb <debuginfo_eip+0x19e>
	       && stabs[lline].n_type != N_SOL
f01037a2:	8a 48 fc             	mov    -0x4(%eax),%cl
f01037a5:	80 f9 84             	cmp    $0x84,%cl
f01037a8:	74 65                	je     f010380f <debuginfo_eip+0x1f2>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01037aa:	80 f9 64             	cmp    $0x64,%cl
f01037ad:	75 ea                	jne    f0103799 <debuginfo_eip+0x17c>
f01037af:	83 38 00             	cmpl   $0x0,(%eax)
f01037b2:	74 e5                	je     f0103799 <debuginfo_eip+0x17c>
f01037b4:	eb 59                	jmp    f010380f <debuginfo_eip+0x1f2>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01037b6:	03 45 d4             	add    -0x2c(%ebp),%eax
f01037b9:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01037bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01037be:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01037c1:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01037c6:	39 ca                	cmp    %ecx,%edx
f01037c8:	7d 3d                	jge    f0103807 <debuginfo_eip+0x1ea>
		for (lline = lfun + 1;
f01037ca:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01037cd:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01037d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01037d3:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f01037d7:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01037d9:	eb 04                	jmp    f01037df <debuginfo_eip+0x1c2>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01037db:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01037de:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01037df:	39 f0                	cmp    %esi,%eax
f01037e1:	7d 1f                	jge    f0103802 <debuginfo_eip+0x1e5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01037e3:	8a 0a                	mov    (%edx),%cl
f01037e5:	83 c2 0c             	add    $0xc,%edx
f01037e8:	80 f9 a0             	cmp    $0xa0,%cl
f01037eb:	74 ee                	je     f01037db <debuginfo_eip+0x1be>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01037ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01037f2:	eb 13                	jmp    f0103807 <debuginfo_eip+0x1ea>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01037f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037f9:	eb 0c                	jmp    f0103807 <debuginfo_eip+0x1ea>
f01037fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103800:	eb 05                	jmp    f0103807 <debuginfo_eip+0x1ea>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103802:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103807:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010380a:	5b                   	pop    %ebx
f010380b:	5e                   	pop    %esi
f010380c:	5f                   	pop    %edi
f010380d:	c9                   	leave  
f010380e:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010380f:	6b d2 0c             	imul   $0xc,%edx,%edx
f0103812:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103815:	8b 04 11             	mov    (%ecx,%edx,1),%eax
f0103818:	2b 75 d4             	sub    -0x2c(%ebp),%esi
f010381b:	39 f0                	cmp    %esi,%eax
f010381d:	72 97                	jb     f01037b6 <debuginfo_eip+0x199>
f010381f:	eb 9a                	jmp    f01037bb <debuginfo_eip+0x19e>
f0103821:	00 00                	add    %al,(%eax)
	...

f0103824 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103824:	55                   	push   %ebp
f0103825:	89 e5                	mov    %esp,%ebp
f0103827:	57                   	push   %edi
f0103828:	56                   	push   %esi
f0103829:	53                   	push   %ebx
f010382a:	83 ec 2c             	sub    $0x2c,%esp
f010382d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103830:	89 d6                	mov    %edx,%esi
f0103832:	8b 45 08             	mov    0x8(%ebp),%eax
f0103835:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103838:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010383b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010383e:	8b 45 10             	mov    0x10(%ebp),%eax
f0103841:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103844:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103847:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010384a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0103851:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0103854:	72 0c                	jb     f0103862 <printnum+0x3e>
f0103856:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103859:	76 07                	jbe    f0103862 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010385b:	4b                   	dec    %ebx
f010385c:	85 db                	test   %ebx,%ebx
f010385e:	7f 31                	jg     f0103891 <printnum+0x6d>
f0103860:	eb 3f                	jmp    f01038a1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103862:	83 ec 0c             	sub    $0xc,%esp
f0103865:	57                   	push   %edi
f0103866:	4b                   	dec    %ebx
f0103867:	53                   	push   %ebx
f0103868:	50                   	push   %eax
f0103869:	83 ec 08             	sub    $0x8,%esp
f010386c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010386f:	ff 75 d0             	pushl  -0x30(%ebp)
f0103872:	ff 75 dc             	pushl  -0x24(%ebp)
f0103875:	ff 75 d8             	pushl  -0x28(%ebp)
f0103878:	e8 97 09 00 00       	call   f0104214 <__udivdi3>
f010387d:	83 c4 18             	add    $0x18,%esp
f0103880:	52                   	push   %edx
f0103881:	50                   	push   %eax
f0103882:	89 f2                	mov    %esi,%edx
f0103884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103887:	e8 98 ff ff ff       	call   f0103824 <printnum>
f010388c:	83 c4 20             	add    $0x20,%esp
f010388f:	eb 10                	jmp    f01038a1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103891:	83 ec 08             	sub    $0x8,%esp
f0103894:	56                   	push   %esi
f0103895:	57                   	push   %edi
f0103896:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103899:	4b                   	dec    %ebx
f010389a:	83 c4 10             	add    $0x10,%esp
f010389d:	85 db                	test   %ebx,%ebx
f010389f:	7f f0                	jg     f0103891 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01038a1:	83 ec 08             	sub    $0x8,%esp
f01038a4:	56                   	push   %esi
f01038a5:	83 ec 04             	sub    $0x4,%esp
f01038a8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01038ab:	ff 75 d0             	pushl  -0x30(%ebp)
f01038ae:	ff 75 dc             	pushl  -0x24(%ebp)
f01038b1:	ff 75 d8             	pushl  -0x28(%ebp)
f01038b4:	e8 77 0a 00 00       	call   f0104330 <__umoddi3>
f01038b9:	83 c4 14             	add    $0x14,%esp
f01038bc:	0f be 80 e1 5c 10 f0 	movsbl -0xfefa31f(%eax),%eax
f01038c3:	50                   	push   %eax
f01038c4:	ff 55 e4             	call   *-0x1c(%ebp)
f01038c7:	83 c4 10             	add    $0x10,%esp
}
f01038ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01038cd:	5b                   	pop    %ebx
f01038ce:	5e                   	pop    %esi
f01038cf:	5f                   	pop    %edi
f01038d0:	c9                   	leave  
f01038d1:	c3                   	ret    

f01038d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01038d2:	55                   	push   %ebp
f01038d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01038d5:	83 fa 01             	cmp    $0x1,%edx
f01038d8:	7e 0e                	jle    f01038e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01038da:	8b 10                	mov    (%eax),%edx
f01038dc:	8d 4a 08             	lea    0x8(%edx),%ecx
f01038df:	89 08                	mov    %ecx,(%eax)
f01038e1:	8b 02                	mov    (%edx),%eax
f01038e3:	8b 52 04             	mov    0x4(%edx),%edx
f01038e6:	eb 22                	jmp    f010390a <getuint+0x38>
	else if (lflag)
f01038e8:	85 d2                	test   %edx,%edx
f01038ea:	74 10                	je     f01038fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01038ec:	8b 10                	mov    (%eax),%edx
f01038ee:	8d 4a 04             	lea    0x4(%edx),%ecx
f01038f1:	89 08                	mov    %ecx,(%eax)
f01038f3:	8b 02                	mov    (%edx),%eax
f01038f5:	ba 00 00 00 00       	mov    $0x0,%edx
f01038fa:	eb 0e                	jmp    f010390a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01038fc:	8b 10                	mov    (%eax),%edx
f01038fe:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103901:	89 08                	mov    %ecx,(%eax)
f0103903:	8b 02                	mov    (%edx),%eax
f0103905:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010390a:	c9                   	leave  
f010390b:	c3                   	ret    

f010390c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f010390c:	55                   	push   %ebp
f010390d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010390f:	83 fa 01             	cmp    $0x1,%edx
f0103912:	7e 0e                	jle    f0103922 <getint+0x16>
		return va_arg(*ap, long long);
f0103914:	8b 10                	mov    (%eax),%edx
f0103916:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103919:	89 08                	mov    %ecx,(%eax)
f010391b:	8b 02                	mov    (%edx),%eax
f010391d:	8b 52 04             	mov    0x4(%edx),%edx
f0103920:	eb 1a                	jmp    f010393c <getint+0x30>
	else if (lflag)
f0103922:	85 d2                	test   %edx,%edx
f0103924:	74 0c                	je     f0103932 <getint+0x26>
		return va_arg(*ap, long);
f0103926:	8b 10                	mov    (%eax),%edx
f0103928:	8d 4a 04             	lea    0x4(%edx),%ecx
f010392b:	89 08                	mov    %ecx,(%eax)
f010392d:	8b 02                	mov    (%edx),%eax
f010392f:	99                   	cltd   
f0103930:	eb 0a                	jmp    f010393c <getint+0x30>
	else
		return va_arg(*ap, int);
f0103932:	8b 10                	mov    (%eax),%edx
f0103934:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103937:	89 08                	mov    %ecx,(%eax)
f0103939:	8b 02                	mov    (%edx),%eax
f010393b:	99                   	cltd   
}
f010393c:	c9                   	leave  
f010393d:	c3                   	ret    

f010393e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010393e:	55                   	push   %ebp
f010393f:	89 e5                	mov    %esp,%ebp
f0103941:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103944:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103947:	8b 10                	mov    (%eax),%edx
f0103949:	3b 50 04             	cmp    0x4(%eax),%edx
f010394c:	73 08                	jae    f0103956 <sprintputch+0x18>
		*b->buf++ = ch;
f010394e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103951:	88 0a                	mov    %cl,(%edx)
f0103953:	42                   	inc    %edx
f0103954:	89 10                	mov    %edx,(%eax)
}
f0103956:	c9                   	leave  
f0103957:	c3                   	ret    

f0103958 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103958:	55                   	push   %ebp
f0103959:	89 e5                	mov    %esp,%ebp
f010395b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010395e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103961:	50                   	push   %eax
f0103962:	ff 75 10             	pushl  0x10(%ebp)
f0103965:	ff 75 0c             	pushl  0xc(%ebp)
f0103968:	ff 75 08             	pushl  0x8(%ebp)
f010396b:	e8 05 00 00 00       	call   f0103975 <vprintfmt>
	va_end(ap);
f0103970:	83 c4 10             	add    $0x10,%esp
}
f0103973:	c9                   	leave  
f0103974:	c3                   	ret    

f0103975 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103975:	55                   	push   %ebp
f0103976:	89 e5                	mov    %esp,%ebp
f0103978:	57                   	push   %edi
f0103979:	56                   	push   %esi
f010397a:	53                   	push   %ebx
f010397b:	83 ec 2c             	sub    $0x2c,%esp
f010397e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103981:	8b 75 10             	mov    0x10(%ebp),%esi
f0103984:	eb 13                	jmp    f0103999 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103986:	85 c0                	test   %eax,%eax
f0103988:	0f 84 6d 03 00 00    	je     f0103cfb <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f010398e:	83 ec 08             	sub    $0x8,%esp
f0103991:	57                   	push   %edi
f0103992:	50                   	push   %eax
f0103993:	ff 55 08             	call   *0x8(%ebp)
f0103996:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103999:	0f b6 06             	movzbl (%esi),%eax
f010399c:	46                   	inc    %esi
f010399d:	83 f8 25             	cmp    $0x25,%eax
f01039a0:	75 e4                	jne    f0103986 <vprintfmt+0x11>
f01039a2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f01039a6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01039ad:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f01039b4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01039bb:	b9 00 00 00 00       	mov    $0x0,%ecx
f01039c0:	eb 28                	jmp    f01039ea <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039c2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01039c4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f01039c8:	eb 20                	jmp    f01039ea <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039ca:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01039cc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f01039d0:	eb 18                	jmp    f01039ea <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039d2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01039d4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01039db:	eb 0d                	jmp    f01039ea <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01039dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01039e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01039e3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039ea:	8a 06                	mov    (%esi),%al
f01039ec:	0f b6 d0             	movzbl %al,%edx
f01039ef:	8d 5e 01             	lea    0x1(%esi),%ebx
f01039f2:	83 e8 23             	sub    $0x23,%eax
f01039f5:	3c 55                	cmp    $0x55,%al
f01039f7:	0f 87 e0 02 00 00    	ja     f0103cdd <vprintfmt+0x368>
f01039fd:	0f b6 c0             	movzbl %al,%eax
f0103a00:	ff 24 85 6c 5d 10 f0 	jmp    *-0xfefa294(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103a07:	83 ea 30             	sub    $0x30,%edx
f0103a0a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0103a0d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0103a10:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103a13:	83 fa 09             	cmp    $0x9,%edx
f0103a16:	77 44                	ja     f0103a5c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a18:	89 de                	mov    %ebx,%esi
f0103a1a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103a1d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0103a1e:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103a21:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103a25:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103a28:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0103a2b:	83 fb 09             	cmp    $0x9,%ebx
f0103a2e:	76 ed                	jbe    f0103a1d <vprintfmt+0xa8>
f0103a30:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103a33:	eb 29                	jmp    f0103a5e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103a35:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a38:	8d 50 04             	lea    0x4(%eax),%edx
f0103a3b:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a3e:	8b 00                	mov    (%eax),%eax
f0103a40:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a43:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103a45:	eb 17                	jmp    f0103a5e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0103a47:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103a4b:	78 85                	js     f01039d2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a4d:	89 de                	mov    %ebx,%esi
f0103a4f:	eb 99                	jmp    f01039ea <vprintfmt+0x75>
f0103a51:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103a53:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0103a5a:	eb 8e                	jmp    f01039ea <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a5c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0103a5e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103a62:	79 86                	jns    f01039ea <vprintfmt+0x75>
f0103a64:	e9 74 ff ff ff       	jmp    f01039dd <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103a69:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a6a:	89 de                	mov    %ebx,%esi
f0103a6c:	e9 79 ff ff ff       	jmp    f01039ea <vprintfmt+0x75>
f0103a71:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103a74:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a77:	8d 50 04             	lea    0x4(%eax),%edx
f0103a7a:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a7d:	83 ec 08             	sub    $0x8,%esp
f0103a80:	57                   	push   %edi
f0103a81:	ff 30                	pushl  (%eax)
f0103a83:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103a86:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a89:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103a8c:	e9 08 ff ff ff       	jmp    f0103999 <vprintfmt+0x24>
f0103a91:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103a94:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a97:	8d 50 04             	lea    0x4(%eax),%edx
f0103a9a:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a9d:	8b 00                	mov    (%eax),%eax
f0103a9f:	85 c0                	test   %eax,%eax
f0103aa1:	79 02                	jns    f0103aa5 <vprintfmt+0x130>
f0103aa3:	f7 d8                	neg    %eax
f0103aa5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103aa7:	83 f8 06             	cmp    $0x6,%eax
f0103aaa:	7f 0b                	jg     f0103ab7 <vprintfmt+0x142>
f0103aac:	8b 04 85 c4 5e 10 f0 	mov    -0xfefa13c(,%eax,4),%eax
f0103ab3:	85 c0                	test   %eax,%eax
f0103ab5:	75 1a                	jne    f0103ad1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0103ab7:	52                   	push   %edx
f0103ab8:	68 f9 5c 10 f0       	push   $0xf0105cf9
f0103abd:	57                   	push   %edi
f0103abe:	ff 75 08             	pushl  0x8(%ebp)
f0103ac1:	e8 92 fe ff ff       	call   f0103958 <printfmt>
f0103ac6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ac9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103acc:	e9 c8 fe ff ff       	jmp    f0103999 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0103ad1:	50                   	push   %eax
f0103ad2:	68 cd 55 10 f0       	push   $0xf01055cd
f0103ad7:	57                   	push   %edi
f0103ad8:	ff 75 08             	pushl  0x8(%ebp)
f0103adb:	e8 78 fe ff ff       	call   f0103958 <printfmt>
f0103ae0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ae3:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103ae6:	e9 ae fe ff ff       	jmp    f0103999 <vprintfmt+0x24>
f0103aeb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0103aee:	89 de                	mov    %ebx,%esi
f0103af0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103af3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103af6:	8b 45 14             	mov    0x14(%ebp),%eax
f0103af9:	8d 50 04             	lea    0x4(%eax),%edx
f0103afc:	89 55 14             	mov    %edx,0x14(%ebp)
f0103aff:	8b 00                	mov    (%eax),%eax
f0103b01:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103b04:	85 c0                	test   %eax,%eax
f0103b06:	75 07                	jne    f0103b0f <vprintfmt+0x19a>
				p = "(null)";
f0103b08:	c7 45 d0 f2 5c 10 f0 	movl   $0xf0105cf2,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0103b0f:	85 db                	test   %ebx,%ebx
f0103b11:	7e 42                	jle    f0103b55 <vprintfmt+0x1e0>
f0103b13:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0103b17:	74 3c                	je     f0103b55 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103b19:	83 ec 08             	sub    $0x8,%esp
f0103b1c:	51                   	push   %ecx
f0103b1d:	ff 75 d0             	pushl  -0x30(%ebp)
f0103b20:	e8 3f 03 00 00       	call   f0103e64 <strnlen>
f0103b25:	29 c3                	sub    %eax,%ebx
f0103b27:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103b2a:	83 c4 10             	add    $0x10,%esp
f0103b2d:	85 db                	test   %ebx,%ebx
f0103b2f:	7e 24                	jle    f0103b55 <vprintfmt+0x1e0>
					putch(padc, putdat);
f0103b31:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0103b35:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103b38:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103b3b:	83 ec 08             	sub    $0x8,%esp
f0103b3e:	57                   	push   %edi
f0103b3f:	53                   	push   %ebx
f0103b40:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103b43:	4e                   	dec    %esi
f0103b44:	83 c4 10             	add    $0x10,%esp
f0103b47:	85 f6                	test   %esi,%esi
f0103b49:	7f f0                	jg     f0103b3b <vprintfmt+0x1c6>
f0103b4b:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103b4e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103b55:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103b58:	0f be 02             	movsbl (%edx),%eax
f0103b5b:	85 c0                	test   %eax,%eax
f0103b5d:	75 47                	jne    f0103ba6 <vprintfmt+0x231>
f0103b5f:	eb 37                	jmp    f0103b98 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f0103b61:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103b65:	74 16                	je     f0103b7d <vprintfmt+0x208>
f0103b67:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103b6a:	83 fa 5e             	cmp    $0x5e,%edx
f0103b6d:	76 0e                	jbe    f0103b7d <vprintfmt+0x208>
					putch('?', putdat);
f0103b6f:	83 ec 08             	sub    $0x8,%esp
f0103b72:	57                   	push   %edi
f0103b73:	6a 3f                	push   $0x3f
f0103b75:	ff 55 08             	call   *0x8(%ebp)
f0103b78:	83 c4 10             	add    $0x10,%esp
f0103b7b:	eb 0b                	jmp    f0103b88 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f0103b7d:	83 ec 08             	sub    $0x8,%esp
f0103b80:	57                   	push   %edi
f0103b81:	50                   	push   %eax
f0103b82:	ff 55 08             	call   *0x8(%ebp)
f0103b85:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103b88:	ff 4d e4             	decl   -0x1c(%ebp)
f0103b8b:	0f be 03             	movsbl (%ebx),%eax
f0103b8e:	85 c0                	test   %eax,%eax
f0103b90:	74 03                	je     f0103b95 <vprintfmt+0x220>
f0103b92:	43                   	inc    %ebx
f0103b93:	eb 1b                	jmp    f0103bb0 <vprintfmt+0x23b>
f0103b95:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103b98:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103b9c:	7f 1e                	jg     f0103bbc <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103b9e:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103ba1:	e9 f3 fd ff ff       	jmp    f0103999 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103ba6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103ba9:	43                   	inc    %ebx
f0103baa:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103bad:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103bb0:	85 f6                	test   %esi,%esi
f0103bb2:	78 ad                	js     f0103b61 <vprintfmt+0x1ec>
f0103bb4:	4e                   	dec    %esi
f0103bb5:	79 aa                	jns    f0103b61 <vprintfmt+0x1ec>
f0103bb7:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103bba:	eb dc                	jmp    f0103b98 <vprintfmt+0x223>
f0103bbc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103bbf:	83 ec 08             	sub    $0x8,%esp
f0103bc2:	57                   	push   %edi
f0103bc3:	6a 20                	push   $0x20
f0103bc5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103bc8:	4b                   	dec    %ebx
f0103bc9:	83 c4 10             	add    $0x10,%esp
f0103bcc:	85 db                	test   %ebx,%ebx
f0103bce:	7f ef                	jg     f0103bbf <vprintfmt+0x24a>
f0103bd0:	e9 c4 fd ff ff       	jmp    f0103999 <vprintfmt+0x24>
f0103bd5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103bd8:	89 ca                	mov    %ecx,%edx
f0103bda:	8d 45 14             	lea    0x14(%ebp),%eax
f0103bdd:	e8 2a fd ff ff       	call   f010390c <getint>
f0103be2:	89 c3                	mov    %eax,%ebx
f0103be4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0103be6:	85 d2                	test   %edx,%edx
f0103be8:	78 0a                	js     f0103bf4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103bea:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103bef:	e9 b0 00 00 00       	jmp    f0103ca4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0103bf4:	83 ec 08             	sub    $0x8,%esp
f0103bf7:	57                   	push   %edi
f0103bf8:	6a 2d                	push   $0x2d
f0103bfa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103bfd:	f7 db                	neg    %ebx
f0103bff:	83 d6 00             	adc    $0x0,%esi
f0103c02:	f7 de                	neg    %esi
f0103c04:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103c07:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103c0c:	e9 93 00 00 00       	jmp    f0103ca4 <vprintfmt+0x32f>
f0103c11:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103c14:	89 ca                	mov    %ecx,%edx
f0103c16:	8d 45 14             	lea    0x14(%ebp),%eax
f0103c19:	e8 b4 fc ff ff       	call   f01038d2 <getuint>
f0103c1e:	89 c3                	mov    %eax,%ebx
f0103c20:	89 d6                	mov    %edx,%esi
			base = 10;
f0103c22:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0103c27:	eb 7b                	jmp    f0103ca4 <vprintfmt+0x32f>
f0103c29:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0103c2c:	89 ca                	mov    %ecx,%edx
f0103c2e:	8d 45 14             	lea    0x14(%ebp),%eax
f0103c31:	e8 d6 fc ff ff       	call   f010390c <getint>
f0103c36:	89 c3                	mov    %eax,%ebx
f0103c38:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f0103c3a:	85 d2                	test   %edx,%edx
f0103c3c:	78 07                	js     f0103c45 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f0103c3e:	b8 08 00 00 00       	mov    $0x8,%eax
f0103c43:	eb 5f                	jmp    f0103ca4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0103c45:	83 ec 08             	sub    $0x8,%esp
f0103c48:	57                   	push   %edi
f0103c49:	6a 2d                	push   $0x2d
f0103c4b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f0103c4e:	f7 db                	neg    %ebx
f0103c50:	83 d6 00             	adc    $0x0,%esi
f0103c53:	f7 de                	neg    %esi
f0103c55:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f0103c58:	b8 08 00 00 00       	mov    $0x8,%eax
f0103c5d:	eb 45                	jmp    f0103ca4 <vprintfmt+0x32f>
f0103c5f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f0103c62:	83 ec 08             	sub    $0x8,%esp
f0103c65:	57                   	push   %edi
f0103c66:	6a 30                	push   $0x30
f0103c68:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103c6b:	83 c4 08             	add    $0x8,%esp
f0103c6e:	57                   	push   %edi
f0103c6f:	6a 78                	push   $0x78
f0103c71:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103c74:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c77:	8d 50 04             	lea    0x4(%eax),%edx
f0103c7a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103c7d:	8b 18                	mov    (%eax),%ebx
f0103c7f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103c84:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103c87:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103c8c:	eb 16                	jmp    f0103ca4 <vprintfmt+0x32f>
f0103c8e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103c91:	89 ca                	mov    %ecx,%edx
f0103c93:	8d 45 14             	lea    0x14(%ebp),%eax
f0103c96:	e8 37 fc ff ff       	call   f01038d2 <getuint>
f0103c9b:	89 c3                	mov    %eax,%ebx
f0103c9d:	89 d6                	mov    %edx,%esi
			base = 16;
f0103c9f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103ca4:	83 ec 0c             	sub    $0xc,%esp
f0103ca7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0103cab:	52                   	push   %edx
f0103cac:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103caf:	50                   	push   %eax
f0103cb0:	56                   	push   %esi
f0103cb1:	53                   	push   %ebx
f0103cb2:	89 fa                	mov    %edi,%edx
f0103cb4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cb7:	e8 68 fb ff ff       	call   f0103824 <printnum>
			break;
f0103cbc:	83 c4 20             	add    $0x20,%esp
f0103cbf:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103cc2:	e9 d2 fc ff ff       	jmp    f0103999 <vprintfmt+0x24>
f0103cc7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103cca:	83 ec 08             	sub    $0x8,%esp
f0103ccd:	57                   	push   %edi
f0103cce:	52                   	push   %edx
f0103ccf:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103cd2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cd5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103cd8:	e9 bc fc ff ff       	jmp    f0103999 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103cdd:	83 ec 08             	sub    $0x8,%esp
f0103ce0:	57                   	push   %edi
f0103ce1:	6a 25                	push   $0x25
f0103ce3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103ce6:	83 c4 10             	add    $0x10,%esp
f0103ce9:	eb 02                	jmp    f0103ced <vprintfmt+0x378>
f0103ceb:	89 c6                	mov    %eax,%esi
f0103ced:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103cf0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103cf4:	75 f5                	jne    f0103ceb <vprintfmt+0x376>
f0103cf6:	e9 9e fc ff ff       	jmp    f0103999 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0103cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103cfe:	5b                   	pop    %ebx
f0103cff:	5e                   	pop    %esi
f0103d00:	5f                   	pop    %edi
f0103d01:	c9                   	leave  
f0103d02:	c3                   	ret    

f0103d03 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103d03:	55                   	push   %ebp
f0103d04:	89 e5                	mov    %esp,%ebp
f0103d06:	83 ec 18             	sub    $0x18,%esp
f0103d09:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103d0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103d12:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103d16:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103d19:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103d20:	85 c0                	test   %eax,%eax
f0103d22:	74 26                	je     f0103d4a <vsnprintf+0x47>
f0103d24:	85 d2                	test   %edx,%edx
f0103d26:	7e 29                	jle    f0103d51 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103d28:	ff 75 14             	pushl  0x14(%ebp)
f0103d2b:	ff 75 10             	pushl  0x10(%ebp)
f0103d2e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103d31:	50                   	push   %eax
f0103d32:	68 3e 39 10 f0       	push   $0xf010393e
f0103d37:	e8 39 fc ff ff       	call   f0103975 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103d3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103d3f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d45:	83 c4 10             	add    $0x10,%esp
f0103d48:	eb 0c                	jmp    f0103d56 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103d4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103d4f:	eb 05                	jmp    f0103d56 <vsnprintf+0x53>
f0103d51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103d56:	c9                   	leave  
f0103d57:	c3                   	ret    

f0103d58 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103d58:	55                   	push   %ebp
f0103d59:	89 e5                	mov    %esp,%ebp
f0103d5b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103d5e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103d61:	50                   	push   %eax
f0103d62:	ff 75 10             	pushl  0x10(%ebp)
f0103d65:	ff 75 0c             	pushl  0xc(%ebp)
f0103d68:	ff 75 08             	pushl  0x8(%ebp)
f0103d6b:	e8 93 ff ff ff       	call   f0103d03 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103d70:	c9                   	leave  
f0103d71:	c3                   	ret    
	...

f0103d74 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103d74:	55                   	push   %ebp
f0103d75:	89 e5                	mov    %esp,%ebp
f0103d77:	57                   	push   %edi
f0103d78:	56                   	push   %esi
f0103d79:	53                   	push   %ebx
f0103d7a:	83 ec 0c             	sub    $0xc,%esp
f0103d7d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103d80:	85 c0                	test   %eax,%eax
f0103d82:	74 11                	je     f0103d95 <readline+0x21>
		cprintf("%s", prompt);
f0103d84:	83 ec 08             	sub    $0x8,%esp
f0103d87:	50                   	push   %eax
f0103d88:	68 cd 55 10 f0       	push   $0xf01055cd
f0103d8d:	e8 ab f3 ff ff       	call   f010313d <cprintf>
f0103d92:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103d95:	83 ec 0c             	sub    $0xc,%esp
f0103d98:	6a 00                	push   $0x0
f0103d9a:	e8 44 c8 ff ff       	call   f01005e3 <iscons>
f0103d9f:	89 c7                	mov    %eax,%edi
f0103da1:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103da4:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103da9:	e8 24 c8 ff ff       	call   f01005d2 <getchar>
f0103dae:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103db0:	85 c0                	test   %eax,%eax
f0103db2:	79 18                	jns    f0103dcc <readline+0x58>
			cprintf("read error: %e\n", c);
f0103db4:	83 ec 08             	sub    $0x8,%esp
f0103db7:	50                   	push   %eax
f0103db8:	68 e0 5e 10 f0       	push   $0xf0105ee0
f0103dbd:	e8 7b f3 ff ff       	call   f010313d <cprintf>
			return NULL;
f0103dc2:	83 c4 10             	add    $0x10,%esp
f0103dc5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103dca:	eb 6f                	jmp    f0103e3b <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103dcc:	83 f8 08             	cmp    $0x8,%eax
f0103dcf:	74 05                	je     f0103dd6 <readline+0x62>
f0103dd1:	83 f8 7f             	cmp    $0x7f,%eax
f0103dd4:	75 18                	jne    f0103dee <readline+0x7a>
f0103dd6:	85 f6                	test   %esi,%esi
f0103dd8:	7e 14                	jle    f0103dee <readline+0x7a>
			if (echoing)
f0103dda:	85 ff                	test   %edi,%edi
f0103ddc:	74 0d                	je     f0103deb <readline+0x77>
				cputchar('\b');
f0103dde:	83 ec 0c             	sub    $0xc,%esp
f0103de1:	6a 08                	push   $0x8
f0103de3:	e8 da c7 ff ff       	call   f01005c2 <cputchar>
f0103de8:	83 c4 10             	add    $0x10,%esp
			i--;
f0103deb:	4e                   	dec    %esi
f0103dec:	eb bb                	jmp    f0103da9 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103dee:	83 fb 1f             	cmp    $0x1f,%ebx
f0103df1:	7e 21                	jle    f0103e14 <readline+0xa0>
f0103df3:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103df9:	7f 19                	jg     f0103e14 <readline+0xa0>
			if (echoing)
f0103dfb:	85 ff                	test   %edi,%edi
f0103dfd:	74 0c                	je     f0103e0b <readline+0x97>
				cputchar(c);
f0103dff:	83 ec 0c             	sub    $0xc,%esp
f0103e02:	53                   	push   %ebx
f0103e03:	e8 ba c7 ff ff       	call   f01005c2 <cputchar>
f0103e08:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103e0b:	88 9e 80 6b 1d f0    	mov    %bl,-0xfe29480(%esi)
f0103e11:	46                   	inc    %esi
f0103e12:	eb 95                	jmp    f0103da9 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103e14:	83 fb 0a             	cmp    $0xa,%ebx
f0103e17:	74 05                	je     f0103e1e <readline+0xaa>
f0103e19:	83 fb 0d             	cmp    $0xd,%ebx
f0103e1c:	75 8b                	jne    f0103da9 <readline+0x35>
			if (echoing)
f0103e1e:	85 ff                	test   %edi,%edi
f0103e20:	74 0d                	je     f0103e2f <readline+0xbb>
				cputchar('\n');
f0103e22:	83 ec 0c             	sub    $0xc,%esp
f0103e25:	6a 0a                	push   $0xa
f0103e27:	e8 96 c7 ff ff       	call   f01005c2 <cputchar>
f0103e2c:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103e2f:	c6 86 80 6b 1d f0 00 	movb   $0x0,-0xfe29480(%esi)
			return buf;
f0103e36:	b8 80 6b 1d f0       	mov    $0xf01d6b80,%eax
		}
	}
}
f0103e3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e3e:	5b                   	pop    %ebx
f0103e3f:	5e                   	pop    %esi
f0103e40:	5f                   	pop    %edi
f0103e41:	c9                   	leave  
f0103e42:	c3                   	ret    
	...

f0103e44 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103e44:	55                   	push   %ebp
f0103e45:	89 e5                	mov    %esp,%ebp
f0103e47:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103e4a:	80 3a 00             	cmpb   $0x0,(%edx)
f0103e4d:	74 0e                	je     f0103e5d <strlen+0x19>
f0103e4f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0103e54:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103e55:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103e59:	75 f9                	jne    f0103e54 <strlen+0x10>
f0103e5b:	eb 05                	jmp    f0103e62 <strlen+0x1e>
f0103e5d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0103e62:	c9                   	leave  
f0103e63:	c3                   	ret    

f0103e64 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103e64:	55                   	push   %ebp
f0103e65:	89 e5                	mov    %esp,%ebp
f0103e67:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103e6d:	85 d2                	test   %edx,%edx
f0103e6f:	74 17                	je     f0103e88 <strnlen+0x24>
f0103e71:	80 39 00             	cmpb   $0x0,(%ecx)
f0103e74:	74 19                	je     f0103e8f <strnlen+0x2b>
f0103e76:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0103e7b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103e7c:	39 d0                	cmp    %edx,%eax
f0103e7e:	74 14                	je     f0103e94 <strnlen+0x30>
f0103e80:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103e84:	75 f5                	jne    f0103e7b <strnlen+0x17>
f0103e86:	eb 0c                	jmp    f0103e94 <strnlen+0x30>
f0103e88:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e8d:	eb 05                	jmp    f0103e94 <strnlen+0x30>
f0103e8f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0103e94:	c9                   	leave  
f0103e95:	c3                   	ret    

f0103e96 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103e96:	55                   	push   %ebp
f0103e97:	89 e5                	mov    %esp,%ebp
f0103e99:	53                   	push   %ebx
f0103e9a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103ea0:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ea5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0103ea8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103eab:	42                   	inc    %edx
f0103eac:	84 c9                	test   %cl,%cl
f0103eae:	75 f5                	jne    f0103ea5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103eb0:	5b                   	pop    %ebx
f0103eb1:	c9                   	leave  
f0103eb2:	c3                   	ret    

f0103eb3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103eb3:	55                   	push   %ebp
f0103eb4:	89 e5                	mov    %esp,%ebp
f0103eb6:	53                   	push   %ebx
f0103eb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103eba:	53                   	push   %ebx
f0103ebb:	e8 84 ff ff ff       	call   f0103e44 <strlen>
f0103ec0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103ec3:	ff 75 0c             	pushl  0xc(%ebp)
f0103ec6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0103ec9:	50                   	push   %eax
f0103eca:	e8 c7 ff ff ff       	call   f0103e96 <strcpy>
	return dst;
}
f0103ecf:	89 d8                	mov    %ebx,%eax
f0103ed1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ed4:	c9                   	leave  
f0103ed5:	c3                   	ret    

f0103ed6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103ed6:	55                   	push   %ebp
f0103ed7:	89 e5                	mov    %esp,%ebp
f0103ed9:	56                   	push   %esi
f0103eda:	53                   	push   %ebx
f0103edb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ede:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103ee1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103ee4:	85 f6                	test   %esi,%esi
f0103ee6:	74 15                	je     f0103efd <strncpy+0x27>
f0103ee8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103eed:	8a 1a                	mov    (%edx),%bl
f0103eef:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103ef2:	80 3a 01             	cmpb   $0x1,(%edx)
f0103ef5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103ef8:	41                   	inc    %ecx
f0103ef9:	39 ce                	cmp    %ecx,%esi
f0103efb:	77 f0                	ja     f0103eed <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103efd:	5b                   	pop    %ebx
f0103efe:	5e                   	pop    %esi
f0103eff:	c9                   	leave  
f0103f00:	c3                   	ret    

f0103f01 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103f01:	55                   	push   %ebp
f0103f02:	89 e5                	mov    %esp,%ebp
f0103f04:	57                   	push   %edi
f0103f05:	56                   	push   %esi
f0103f06:	53                   	push   %ebx
f0103f07:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103f0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103f0d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103f10:	85 f6                	test   %esi,%esi
f0103f12:	74 32                	je     f0103f46 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0103f14:	83 fe 01             	cmp    $0x1,%esi
f0103f17:	74 22                	je     f0103f3b <strlcpy+0x3a>
f0103f19:	8a 0b                	mov    (%ebx),%cl
f0103f1b:	84 c9                	test   %cl,%cl
f0103f1d:	74 20                	je     f0103f3f <strlcpy+0x3e>
f0103f1f:	89 f8                	mov    %edi,%eax
f0103f21:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0103f26:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103f29:	88 08                	mov    %cl,(%eax)
f0103f2b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103f2c:	39 f2                	cmp    %esi,%edx
f0103f2e:	74 11                	je     f0103f41 <strlcpy+0x40>
f0103f30:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0103f34:	42                   	inc    %edx
f0103f35:	84 c9                	test   %cl,%cl
f0103f37:	75 f0                	jne    f0103f29 <strlcpy+0x28>
f0103f39:	eb 06                	jmp    f0103f41 <strlcpy+0x40>
f0103f3b:	89 f8                	mov    %edi,%eax
f0103f3d:	eb 02                	jmp    f0103f41 <strlcpy+0x40>
f0103f3f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103f41:	c6 00 00             	movb   $0x0,(%eax)
f0103f44:	eb 02                	jmp    f0103f48 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103f46:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0103f48:	29 f8                	sub    %edi,%eax
}
f0103f4a:	5b                   	pop    %ebx
f0103f4b:	5e                   	pop    %esi
f0103f4c:	5f                   	pop    %edi
f0103f4d:	c9                   	leave  
f0103f4e:	c3                   	ret    

f0103f4f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103f4f:	55                   	push   %ebp
f0103f50:	89 e5                	mov    %esp,%ebp
f0103f52:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103f55:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103f58:	8a 01                	mov    (%ecx),%al
f0103f5a:	84 c0                	test   %al,%al
f0103f5c:	74 10                	je     f0103f6e <strcmp+0x1f>
f0103f5e:	3a 02                	cmp    (%edx),%al
f0103f60:	75 0c                	jne    f0103f6e <strcmp+0x1f>
		p++, q++;
f0103f62:	41                   	inc    %ecx
f0103f63:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103f64:	8a 01                	mov    (%ecx),%al
f0103f66:	84 c0                	test   %al,%al
f0103f68:	74 04                	je     f0103f6e <strcmp+0x1f>
f0103f6a:	3a 02                	cmp    (%edx),%al
f0103f6c:	74 f4                	je     f0103f62 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103f6e:	0f b6 c0             	movzbl %al,%eax
f0103f71:	0f b6 12             	movzbl (%edx),%edx
f0103f74:	29 d0                	sub    %edx,%eax
}
f0103f76:	c9                   	leave  
f0103f77:	c3                   	ret    

f0103f78 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103f78:	55                   	push   %ebp
f0103f79:	89 e5                	mov    %esp,%ebp
f0103f7b:	53                   	push   %ebx
f0103f7c:	8b 55 08             	mov    0x8(%ebp),%edx
f0103f7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103f82:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0103f85:	85 c0                	test   %eax,%eax
f0103f87:	74 1b                	je     f0103fa4 <strncmp+0x2c>
f0103f89:	8a 1a                	mov    (%edx),%bl
f0103f8b:	84 db                	test   %bl,%bl
f0103f8d:	74 24                	je     f0103fb3 <strncmp+0x3b>
f0103f8f:	3a 19                	cmp    (%ecx),%bl
f0103f91:	75 20                	jne    f0103fb3 <strncmp+0x3b>
f0103f93:	48                   	dec    %eax
f0103f94:	74 15                	je     f0103fab <strncmp+0x33>
		n--, p++, q++;
f0103f96:	42                   	inc    %edx
f0103f97:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103f98:	8a 1a                	mov    (%edx),%bl
f0103f9a:	84 db                	test   %bl,%bl
f0103f9c:	74 15                	je     f0103fb3 <strncmp+0x3b>
f0103f9e:	3a 19                	cmp    (%ecx),%bl
f0103fa0:	74 f1                	je     f0103f93 <strncmp+0x1b>
f0103fa2:	eb 0f                	jmp    f0103fb3 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103fa4:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fa9:	eb 05                	jmp    f0103fb0 <strncmp+0x38>
f0103fab:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103fb0:	5b                   	pop    %ebx
f0103fb1:	c9                   	leave  
f0103fb2:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103fb3:	0f b6 02             	movzbl (%edx),%eax
f0103fb6:	0f b6 11             	movzbl (%ecx),%edx
f0103fb9:	29 d0                	sub    %edx,%eax
f0103fbb:	eb f3                	jmp    f0103fb0 <strncmp+0x38>

f0103fbd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103fbd:	55                   	push   %ebp
f0103fbe:	89 e5                	mov    %esp,%ebp
f0103fc0:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fc3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103fc6:	8a 10                	mov    (%eax),%dl
f0103fc8:	84 d2                	test   %dl,%dl
f0103fca:	74 18                	je     f0103fe4 <strchr+0x27>
		if (*s == c)
f0103fcc:	38 ca                	cmp    %cl,%dl
f0103fce:	75 06                	jne    f0103fd6 <strchr+0x19>
f0103fd0:	eb 17                	jmp    f0103fe9 <strchr+0x2c>
f0103fd2:	38 ca                	cmp    %cl,%dl
f0103fd4:	74 13                	je     f0103fe9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103fd6:	40                   	inc    %eax
f0103fd7:	8a 10                	mov    (%eax),%dl
f0103fd9:	84 d2                	test   %dl,%dl
f0103fdb:	75 f5                	jne    f0103fd2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0103fdd:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fe2:	eb 05                	jmp    f0103fe9 <strchr+0x2c>
f0103fe4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103fe9:	c9                   	leave  
f0103fea:	c3                   	ret    

f0103feb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103feb:	55                   	push   %ebp
f0103fec:	89 e5                	mov    %esp,%ebp
f0103fee:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ff1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103ff4:	8a 10                	mov    (%eax),%dl
f0103ff6:	84 d2                	test   %dl,%dl
f0103ff8:	74 11                	je     f010400b <strfind+0x20>
		if (*s == c)
f0103ffa:	38 ca                	cmp    %cl,%dl
f0103ffc:	75 06                	jne    f0104004 <strfind+0x19>
f0103ffe:	eb 0b                	jmp    f010400b <strfind+0x20>
f0104000:	38 ca                	cmp    %cl,%dl
f0104002:	74 07                	je     f010400b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104004:	40                   	inc    %eax
f0104005:	8a 10                	mov    (%eax),%dl
f0104007:	84 d2                	test   %dl,%dl
f0104009:	75 f5                	jne    f0104000 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f010400b:	c9                   	leave  
f010400c:	c3                   	ret    

f010400d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010400d:	55                   	push   %ebp
f010400e:	89 e5                	mov    %esp,%ebp
f0104010:	57                   	push   %edi
f0104011:	56                   	push   %esi
f0104012:	53                   	push   %ebx
f0104013:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104016:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104019:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010401c:	85 c9                	test   %ecx,%ecx
f010401e:	74 30                	je     f0104050 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104020:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104026:	75 25                	jne    f010404d <memset+0x40>
f0104028:	f6 c1 03             	test   $0x3,%cl
f010402b:	75 20                	jne    f010404d <memset+0x40>
		c &= 0xFF;
f010402d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104030:	89 d3                	mov    %edx,%ebx
f0104032:	c1 e3 08             	shl    $0x8,%ebx
f0104035:	89 d6                	mov    %edx,%esi
f0104037:	c1 e6 18             	shl    $0x18,%esi
f010403a:	89 d0                	mov    %edx,%eax
f010403c:	c1 e0 10             	shl    $0x10,%eax
f010403f:	09 f0                	or     %esi,%eax
f0104041:	09 d0                	or     %edx,%eax
f0104043:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104045:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104048:	fc                   	cld    
f0104049:	f3 ab                	rep stos %eax,%es:(%edi)
f010404b:	eb 03                	jmp    f0104050 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010404d:	fc                   	cld    
f010404e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104050:	89 f8                	mov    %edi,%eax
f0104052:	5b                   	pop    %ebx
f0104053:	5e                   	pop    %esi
f0104054:	5f                   	pop    %edi
f0104055:	c9                   	leave  
f0104056:	c3                   	ret    

f0104057 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104057:	55                   	push   %ebp
f0104058:	89 e5                	mov    %esp,%ebp
f010405a:	57                   	push   %edi
f010405b:	56                   	push   %esi
f010405c:	8b 45 08             	mov    0x8(%ebp),%eax
f010405f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104062:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104065:	39 c6                	cmp    %eax,%esi
f0104067:	73 34                	jae    f010409d <memmove+0x46>
f0104069:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010406c:	39 d0                	cmp    %edx,%eax
f010406e:	73 2d                	jae    f010409d <memmove+0x46>
		s += n;
		d += n;
f0104070:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104073:	f6 c2 03             	test   $0x3,%dl
f0104076:	75 1b                	jne    f0104093 <memmove+0x3c>
f0104078:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010407e:	75 13                	jne    f0104093 <memmove+0x3c>
f0104080:	f6 c1 03             	test   $0x3,%cl
f0104083:	75 0e                	jne    f0104093 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104085:	83 ef 04             	sub    $0x4,%edi
f0104088:	8d 72 fc             	lea    -0x4(%edx),%esi
f010408b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010408e:	fd                   	std    
f010408f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104091:	eb 07                	jmp    f010409a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104093:	4f                   	dec    %edi
f0104094:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104097:	fd                   	std    
f0104098:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010409a:	fc                   	cld    
f010409b:	eb 20                	jmp    f01040bd <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010409d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01040a3:	75 13                	jne    f01040b8 <memmove+0x61>
f01040a5:	a8 03                	test   $0x3,%al
f01040a7:	75 0f                	jne    f01040b8 <memmove+0x61>
f01040a9:	f6 c1 03             	test   $0x3,%cl
f01040ac:	75 0a                	jne    f01040b8 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01040ae:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01040b1:	89 c7                	mov    %eax,%edi
f01040b3:	fc                   	cld    
f01040b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01040b6:	eb 05                	jmp    f01040bd <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01040b8:	89 c7                	mov    %eax,%edi
f01040ba:	fc                   	cld    
f01040bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01040bd:	5e                   	pop    %esi
f01040be:	5f                   	pop    %edi
f01040bf:	c9                   	leave  
f01040c0:	c3                   	ret    

f01040c1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01040c1:	55                   	push   %ebp
f01040c2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01040c4:	ff 75 10             	pushl  0x10(%ebp)
f01040c7:	ff 75 0c             	pushl  0xc(%ebp)
f01040ca:	ff 75 08             	pushl  0x8(%ebp)
f01040cd:	e8 85 ff ff ff       	call   f0104057 <memmove>
}
f01040d2:	c9                   	leave  
f01040d3:	c3                   	ret    

f01040d4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01040d4:	55                   	push   %ebp
f01040d5:	89 e5                	mov    %esp,%ebp
f01040d7:	57                   	push   %edi
f01040d8:	56                   	push   %esi
f01040d9:	53                   	push   %ebx
f01040da:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01040dd:	8b 75 0c             	mov    0xc(%ebp),%esi
f01040e0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01040e3:	85 ff                	test   %edi,%edi
f01040e5:	74 32                	je     f0104119 <memcmp+0x45>
		if (*s1 != *s2)
f01040e7:	8a 03                	mov    (%ebx),%al
f01040e9:	8a 0e                	mov    (%esi),%cl
f01040eb:	38 c8                	cmp    %cl,%al
f01040ed:	74 19                	je     f0104108 <memcmp+0x34>
f01040ef:	eb 0d                	jmp    f01040fe <memcmp+0x2a>
f01040f1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f01040f5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f01040f9:	42                   	inc    %edx
f01040fa:	38 c8                	cmp    %cl,%al
f01040fc:	74 10                	je     f010410e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f01040fe:	0f b6 c0             	movzbl %al,%eax
f0104101:	0f b6 c9             	movzbl %cl,%ecx
f0104104:	29 c8                	sub    %ecx,%eax
f0104106:	eb 16                	jmp    f010411e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104108:	4f                   	dec    %edi
f0104109:	ba 00 00 00 00       	mov    $0x0,%edx
f010410e:	39 fa                	cmp    %edi,%edx
f0104110:	75 df                	jne    f01040f1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104112:	b8 00 00 00 00       	mov    $0x0,%eax
f0104117:	eb 05                	jmp    f010411e <memcmp+0x4a>
f0104119:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010411e:	5b                   	pop    %ebx
f010411f:	5e                   	pop    %esi
f0104120:	5f                   	pop    %edi
f0104121:	c9                   	leave  
f0104122:	c3                   	ret    

f0104123 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104123:	55                   	push   %ebp
f0104124:	89 e5                	mov    %esp,%ebp
f0104126:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104129:	89 c2                	mov    %eax,%edx
f010412b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010412e:	39 d0                	cmp    %edx,%eax
f0104130:	73 12                	jae    f0104144 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104132:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0104135:	38 08                	cmp    %cl,(%eax)
f0104137:	75 06                	jne    f010413f <memfind+0x1c>
f0104139:	eb 09                	jmp    f0104144 <memfind+0x21>
f010413b:	38 08                	cmp    %cl,(%eax)
f010413d:	74 05                	je     f0104144 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010413f:	40                   	inc    %eax
f0104140:	39 c2                	cmp    %eax,%edx
f0104142:	77 f7                	ja     f010413b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104144:	c9                   	leave  
f0104145:	c3                   	ret    

f0104146 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104146:	55                   	push   %ebp
f0104147:	89 e5                	mov    %esp,%ebp
f0104149:	57                   	push   %edi
f010414a:	56                   	push   %esi
f010414b:	53                   	push   %ebx
f010414c:	8b 55 08             	mov    0x8(%ebp),%edx
f010414f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104152:	eb 01                	jmp    f0104155 <strtol+0xf>
		s++;
f0104154:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104155:	8a 02                	mov    (%edx),%al
f0104157:	3c 20                	cmp    $0x20,%al
f0104159:	74 f9                	je     f0104154 <strtol+0xe>
f010415b:	3c 09                	cmp    $0x9,%al
f010415d:	74 f5                	je     f0104154 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010415f:	3c 2b                	cmp    $0x2b,%al
f0104161:	75 08                	jne    f010416b <strtol+0x25>
		s++;
f0104163:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104164:	bf 00 00 00 00       	mov    $0x0,%edi
f0104169:	eb 13                	jmp    f010417e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010416b:	3c 2d                	cmp    $0x2d,%al
f010416d:	75 0a                	jne    f0104179 <strtol+0x33>
		s++, neg = 1;
f010416f:	8d 52 01             	lea    0x1(%edx),%edx
f0104172:	bf 01 00 00 00       	mov    $0x1,%edi
f0104177:	eb 05                	jmp    f010417e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104179:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010417e:	85 db                	test   %ebx,%ebx
f0104180:	74 05                	je     f0104187 <strtol+0x41>
f0104182:	83 fb 10             	cmp    $0x10,%ebx
f0104185:	75 28                	jne    f01041af <strtol+0x69>
f0104187:	8a 02                	mov    (%edx),%al
f0104189:	3c 30                	cmp    $0x30,%al
f010418b:	75 10                	jne    f010419d <strtol+0x57>
f010418d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104191:	75 0a                	jne    f010419d <strtol+0x57>
		s += 2, base = 16;
f0104193:	83 c2 02             	add    $0x2,%edx
f0104196:	bb 10 00 00 00       	mov    $0x10,%ebx
f010419b:	eb 12                	jmp    f01041af <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f010419d:	85 db                	test   %ebx,%ebx
f010419f:	75 0e                	jne    f01041af <strtol+0x69>
f01041a1:	3c 30                	cmp    $0x30,%al
f01041a3:	75 05                	jne    f01041aa <strtol+0x64>
		s++, base = 8;
f01041a5:	42                   	inc    %edx
f01041a6:	b3 08                	mov    $0x8,%bl
f01041a8:	eb 05                	jmp    f01041af <strtol+0x69>
	else if (base == 0)
		base = 10;
f01041aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01041af:	b8 00 00 00 00       	mov    $0x0,%eax
f01041b4:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01041b6:	8a 0a                	mov    (%edx),%cl
f01041b8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01041bb:	80 fb 09             	cmp    $0x9,%bl
f01041be:	77 08                	ja     f01041c8 <strtol+0x82>
			dig = *s - '0';
f01041c0:	0f be c9             	movsbl %cl,%ecx
f01041c3:	83 e9 30             	sub    $0x30,%ecx
f01041c6:	eb 1e                	jmp    f01041e6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01041c8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01041cb:	80 fb 19             	cmp    $0x19,%bl
f01041ce:	77 08                	ja     f01041d8 <strtol+0x92>
			dig = *s - 'a' + 10;
f01041d0:	0f be c9             	movsbl %cl,%ecx
f01041d3:	83 e9 57             	sub    $0x57,%ecx
f01041d6:	eb 0e                	jmp    f01041e6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01041d8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01041db:	80 fb 19             	cmp    $0x19,%bl
f01041de:	77 13                	ja     f01041f3 <strtol+0xad>
			dig = *s - 'A' + 10;
f01041e0:	0f be c9             	movsbl %cl,%ecx
f01041e3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01041e6:	39 f1                	cmp    %esi,%ecx
f01041e8:	7d 0d                	jge    f01041f7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f01041ea:	42                   	inc    %edx
f01041eb:	0f af c6             	imul   %esi,%eax
f01041ee:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f01041f1:	eb c3                	jmp    f01041b6 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01041f3:	89 c1                	mov    %eax,%ecx
f01041f5:	eb 02                	jmp    f01041f9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01041f7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01041f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01041fd:	74 05                	je     f0104204 <strtol+0xbe>
		*endptr = (char *) s;
f01041ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104202:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104204:	85 ff                	test   %edi,%edi
f0104206:	74 04                	je     f010420c <strtol+0xc6>
f0104208:	89 c8                	mov    %ecx,%eax
f010420a:	f7 d8                	neg    %eax
}
f010420c:	5b                   	pop    %ebx
f010420d:	5e                   	pop    %esi
f010420e:	5f                   	pop    %edi
f010420f:	c9                   	leave  
f0104210:	c3                   	ret    
f0104211:	00 00                	add    %al,(%eax)
	...

f0104214 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0104214:	55                   	push   %ebp
f0104215:	89 e5                	mov    %esp,%ebp
f0104217:	57                   	push   %edi
f0104218:	56                   	push   %esi
f0104219:	83 ec 10             	sub    $0x10,%esp
f010421c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010421f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0104222:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0104225:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0104228:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010422b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010422e:	85 c0                	test   %eax,%eax
f0104230:	75 2e                	jne    f0104260 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0104232:	39 f1                	cmp    %esi,%ecx
f0104234:	77 5a                	ja     f0104290 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0104236:	85 c9                	test   %ecx,%ecx
f0104238:	75 0b                	jne    f0104245 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f010423a:	b8 01 00 00 00       	mov    $0x1,%eax
f010423f:	31 d2                	xor    %edx,%edx
f0104241:	f7 f1                	div    %ecx
f0104243:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0104245:	31 d2                	xor    %edx,%edx
f0104247:	89 f0                	mov    %esi,%eax
f0104249:	f7 f1                	div    %ecx
f010424b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010424d:	89 f8                	mov    %edi,%eax
f010424f:	f7 f1                	div    %ecx
f0104251:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104253:	89 f8                	mov    %edi,%eax
f0104255:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104257:	83 c4 10             	add    $0x10,%esp
f010425a:	5e                   	pop    %esi
f010425b:	5f                   	pop    %edi
f010425c:	c9                   	leave  
f010425d:	c3                   	ret    
f010425e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0104260:	39 f0                	cmp    %esi,%eax
f0104262:	77 1c                	ja     f0104280 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0104264:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f0104267:	83 f7 1f             	xor    $0x1f,%edi
f010426a:	75 3c                	jne    f01042a8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010426c:	39 f0                	cmp    %esi,%eax
f010426e:	0f 82 90 00 00 00    	jb     f0104304 <__udivdi3+0xf0>
f0104274:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104277:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f010427a:	0f 86 84 00 00 00    	jbe    f0104304 <__udivdi3+0xf0>
f0104280:	31 f6                	xor    %esi,%esi
f0104282:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104284:	89 f8                	mov    %edi,%eax
f0104286:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104288:	83 c4 10             	add    $0x10,%esp
f010428b:	5e                   	pop    %esi
f010428c:	5f                   	pop    %edi
f010428d:	c9                   	leave  
f010428e:	c3                   	ret    
f010428f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104290:	89 f2                	mov    %esi,%edx
f0104292:	89 f8                	mov    %edi,%eax
f0104294:	f7 f1                	div    %ecx
f0104296:	89 c7                	mov    %eax,%edi
f0104298:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010429a:	89 f8                	mov    %edi,%eax
f010429c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010429e:	83 c4 10             	add    $0x10,%esp
f01042a1:	5e                   	pop    %esi
f01042a2:	5f                   	pop    %edi
f01042a3:	c9                   	leave  
f01042a4:	c3                   	ret    
f01042a5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01042a8:	89 f9                	mov    %edi,%ecx
f01042aa:	d3 e0                	shl    %cl,%eax
f01042ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01042af:	b8 20 00 00 00       	mov    $0x20,%eax
f01042b4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f01042b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01042b9:	88 c1                	mov    %al,%cl
f01042bb:	d3 ea                	shr    %cl,%edx
f01042bd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01042c0:	09 ca                	or     %ecx,%edx
f01042c2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f01042c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01042c8:	89 f9                	mov    %edi,%ecx
f01042ca:	d3 e2                	shl    %cl,%edx
f01042cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f01042cf:	89 f2                	mov    %esi,%edx
f01042d1:	88 c1                	mov    %al,%cl
f01042d3:	d3 ea                	shr    %cl,%edx
f01042d5:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f01042d8:	89 f2                	mov    %esi,%edx
f01042da:	89 f9                	mov    %edi,%ecx
f01042dc:	d3 e2                	shl    %cl,%edx
f01042de:	8b 75 f0             	mov    -0x10(%ebp),%esi
f01042e1:	88 c1                	mov    %al,%cl
f01042e3:	d3 ee                	shr    %cl,%esi
f01042e5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01042e7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01042ea:	89 f0                	mov    %esi,%eax
f01042ec:	89 ca                	mov    %ecx,%edx
f01042ee:	f7 75 ec             	divl   -0x14(%ebp)
f01042f1:	89 d1                	mov    %edx,%ecx
f01042f3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01042f5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01042f8:	39 d1                	cmp    %edx,%ecx
f01042fa:	72 28                	jb     f0104324 <__udivdi3+0x110>
f01042fc:	74 1a                	je     f0104318 <__udivdi3+0x104>
f01042fe:	89 f7                	mov    %esi,%edi
f0104300:	31 f6                	xor    %esi,%esi
f0104302:	eb 80                	jmp    f0104284 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0104304:	31 f6                	xor    %esi,%esi
f0104306:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010430b:	89 f8                	mov    %edi,%eax
f010430d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010430f:	83 c4 10             	add    $0x10,%esp
f0104312:	5e                   	pop    %esi
f0104313:	5f                   	pop    %edi
f0104314:	c9                   	leave  
f0104315:	c3                   	ret    
f0104316:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0104318:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010431b:	89 f9                	mov    %edi,%ecx
f010431d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010431f:	39 c2                	cmp    %eax,%edx
f0104321:	73 db                	jae    f01042fe <__udivdi3+0xea>
f0104323:	90                   	nop
		{
		  q0--;
f0104324:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104327:	31 f6                	xor    %esi,%esi
f0104329:	e9 56 ff ff ff       	jmp    f0104284 <__udivdi3+0x70>
	...

f0104330 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0104330:	55                   	push   %ebp
f0104331:	89 e5                	mov    %esp,%ebp
f0104333:	57                   	push   %edi
f0104334:	56                   	push   %esi
f0104335:	83 ec 20             	sub    $0x20,%esp
f0104338:	8b 45 08             	mov    0x8(%ebp),%eax
f010433b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010433e:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0104341:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0104344:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0104347:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f010434a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f010434d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010434f:	85 ff                	test   %edi,%edi
f0104351:	75 15                	jne    f0104368 <__umoddi3+0x38>
    {
      if (d0 > n1)
f0104353:	39 f1                	cmp    %esi,%ecx
f0104355:	0f 86 99 00 00 00    	jbe    f01043f4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010435b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f010435d:	89 d0                	mov    %edx,%eax
f010435f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104361:	83 c4 20             	add    $0x20,%esp
f0104364:	5e                   	pop    %esi
f0104365:	5f                   	pop    %edi
f0104366:	c9                   	leave  
f0104367:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0104368:	39 f7                	cmp    %esi,%edi
f010436a:	0f 87 a4 00 00 00    	ja     f0104414 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0104370:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0104373:	83 f0 1f             	xor    $0x1f,%eax
f0104376:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104379:	0f 84 a1 00 00 00    	je     f0104420 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f010437f:	89 f8                	mov    %edi,%eax
f0104381:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104384:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0104386:	bf 20 00 00 00       	mov    $0x20,%edi
f010438b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f010438e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104391:	89 f9                	mov    %edi,%ecx
f0104393:	d3 ea                	shr    %cl,%edx
f0104395:	09 c2                	or     %eax,%edx
f0104397:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f010439a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010439d:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01043a0:	d3 e0                	shl    %cl,%eax
f01043a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f01043a5:	89 f2                	mov    %esi,%edx
f01043a7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f01043a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01043ac:	d3 e0                	shl    %cl,%eax
f01043ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f01043b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01043b4:	89 f9                	mov    %edi,%ecx
f01043b6:	d3 e8                	shr    %cl,%eax
f01043b8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f01043ba:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01043bc:	89 f2                	mov    %esi,%edx
f01043be:	f7 75 f0             	divl   -0x10(%ebp)
f01043c1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01043c3:	f7 65 f4             	mull   -0xc(%ebp)
f01043c6:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01043c9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01043cb:	39 d6                	cmp    %edx,%esi
f01043cd:	72 71                	jb     f0104440 <__umoddi3+0x110>
f01043cf:	74 7f                	je     f0104450 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01043d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01043d4:	29 c8                	sub    %ecx,%eax
f01043d6:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01043d8:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01043db:	d3 e8                	shr    %cl,%eax
f01043dd:	89 f2                	mov    %esi,%edx
f01043df:	89 f9                	mov    %edi,%ecx
f01043e1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01043e3:	09 d0                	or     %edx,%eax
f01043e5:	89 f2                	mov    %esi,%edx
f01043e7:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01043ea:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01043ec:	83 c4 20             	add    $0x20,%esp
f01043ef:	5e                   	pop    %esi
f01043f0:	5f                   	pop    %edi
f01043f1:	c9                   	leave  
f01043f2:	c3                   	ret    
f01043f3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01043f4:	85 c9                	test   %ecx,%ecx
f01043f6:	75 0b                	jne    f0104403 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01043f8:	b8 01 00 00 00       	mov    $0x1,%eax
f01043fd:	31 d2                	xor    %edx,%edx
f01043ff:	f7 f1                	div    %ecx
f0104401:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0104403:	89 f0                	mov    %esi,%eax
f0104405:	31 d2                	xor    %edx,%edx
f0104407:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104409:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010440c:	f7 f1                	div    %ecx
f010440e:	e9 4a ff ff ff       	jmp    f010435d <__umoddi3+0x2d>
f0104413:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0104414:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104416:	83 c4 20             	add    $0x20,%esp
f0104419:	5e                   	pop    %esi
f010441a:	5f                   	pop    %edi
f010441b:	c9                   	leave  
f010441c:	c3                   	ret    
f010441d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0104420:	39 f7                	cmp    %esi,%edi
f0104422:	72 05                	jb     f0104429 <__umoddi3+0xf9>
f0104424:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0104427:	77 0c                	ja     f0104435 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0104429:	89 f2                	mov    %esi,%edx
f010442b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010442e:	29 c8                	sub    %ecx,%eax
f0104430:	19 fa                	sbb    %edi,%edx
f0104432:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0104435:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104438:	83 c4 20             	add    $0x20,%esp
f010443b:	5e                   	pop    %esi
f010443c:	5f                   	pop    %edi
f010443d:	c9                   	leave  
f010443e:	c3                   	ret    
f010443f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104440:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104443:	89 c1                	mov    %eax,%ecx
f0104445:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0104448:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f010444b:	eb 84                	jmp    f01043d1 <__umoddi3+0xa1>
f010444d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104450:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0104453:	72 eb                	jb     f0104440 <__umoddi3+0x110>
f0104455:	89 f2                	mov    %esi,%edx
f0104457:	e9 75 ff ff ff       	jmp    f01043d1 <__umoddi3+0xa1>
