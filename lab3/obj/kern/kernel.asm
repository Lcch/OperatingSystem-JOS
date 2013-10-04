
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
f0100058:	e8 80 3f 00 00       	call   f0103fdd <memset>

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
f010006a:	68 40 44 10 f0       	push   $0xf0104440
f010006f:	e8 99 30 00 00       	call   f010310d <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 8c 15 00 00       	call   f0101605 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 c7 2c 00 00       	call   f0102d45 <env_init>
	trap_init();
f010007e:	e8 fe 30 00 00       	call   f0103181 <trap_init>
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
f0100092:	e8 e8 2d 00 00       	call   f0102e7f <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100097:	83 c4 04             	add    $0x4,%esp
f010009a:	ff 35 b8 62 1d f0    	pushl  0xf01d62b8
f01000a0:	e8 ed 2f 00 00       	call   f0103092 <env_run>

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
f01000ca:	68 5b 44 10 f0       	push   $0xf010445b
f01000cf:	e8 39 30 00 00       	call   f010310d <cprintf>
	vcprintf(fmt, ap);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	53                   	push   %ebx
f01000d8:	56                   	push   %esi
f01000d9:	e8 09 30 00 00       	call   f01030e7 <vcprintf>
	cprintf("\n");
f01000de:	c7 04 24 25 47 10 f0 	movl   $0xf0104725,(%esp)
f01000e5:	e8 23 30 00 00       	call   f010310d <cprintf>
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
f010010c:	68 73 44 10 f0       	push   $0xf0104473
f0100111:	e8 f7 2f 00 00       	call   f010310d <cprintf>
	vcprintf(fmt, ap);
f0100116:	83 c4 08             	add    $0x8,%esp
f0100119:	53                   	push   %ebx
f010011a:	ff 75 10             	pushl  0x10(%ebp)
f010011d:	e8 c5 2f 00 00       	call   f01030e7 <vcprintf>
	cprintf("\n");
f0100122:	c7 04 24 25 47 10 f0 	movl   $0xf0104725,(%esp)
f0100129:	e8 df 2f 00 00       	call   f010310d <cprintf>
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
f0100319:	e8 09 3d 00 00       	call   f0104027 <memmove>
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
f01003b8:	8a 82 c0 44 10 f0    	mov    -0xfefbb40(%edx),%al
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
f01003f4:	0f b6 82 c0 44 10 f0 	movzbl -0xfefbb40(%edx),%eax
f01003fb:	0b 05 a8 62 1d f0    	or     0xf01d62a8,%eax
	shift ^= togglecode[data];
f0100401:	0f b6 8a c0 45 10 f0 	movzbl -0xfefba40(%edx),%ecx
f0100408:	31 c8                	xor    %ecx,%eax
f010040a:	a3 a8 62 1d f0       	mov    %eax,0xf01d62a8

	c = charcode[shift & (CTL | SHIFT)][data];
f010040f:	89 c1                	mov    %eax,%ecx
f0100411:	83 e1 03             	and    $0x3,%ecx
f0100414:	8b 0c 8d c0 46 10 f0 	mov    -0xfefb940(,%ecx,4),%ecx
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
f010044c:	68 8d 44 10 f0       	push   $0xf010448d
f0100451:	e8 b7 2c 00 00       	call   f010310d <cprintf>
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
f01005ad:	68 99 44 10 f0       	push   $0xf0104499
f01005b2:	e8 56 2b 00 00       	call   f010310d <cprintf>
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
f01005f6:	68 d0 46 10 f0       	push   $0xf01046d0
f01005fb:	e8 0d 2b 00 00       	call   f010310d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100600:	83 c4 08             	add    $0x8,%esp
f0100603:	68 0c 00 10 00       	push   $0x10000c
f0100608:	68 b4 48 10 f0       	push   $0xf01048b4
f010060d:	e8 fb 2a 00 00       	call   f010310d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100612:	83 c4 0c             	add    $0xc,%esp
f0100615:	68 0c 00 10 00       	push   $0x10000c
f010061a:	68 0c 00 10 f0       	push   $0xf010000c
f010061f:	68 dc 48 10 f0       	push   $0xf01048dc
f0100624:	e8 e4 2a 00 00       	call   f010310d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100629:	83 c4 0c             	add    $0xc,%esp
f010062c:	68 2c 44 10 00       	push   $0x10442c
f0100631:	68 2c 44 10 f0       	push   $0xf010442c
f0100636:	68 00 49 10 f0       	push   $0xf0104900
f010063b:	e8 cd 2a 00 00       	call   f010310d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100640:	83 c4 0c             	add    $0xc,%esp
f0100643:	68 64 60 1d 00       	push   $0x1d6064
f0100648:	68 64 60 1d f0       	push   $0xf01d6064
f010064d:	68 24 49 10 f0       	push   $0xf0104924
f0100652:	e8 b6 2a 00 00       	call   f010310d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100657:	83 c4 0c             	add    $0xc,%esp
f010065a:	68 90 6f 1d 00       	push   $0x1d6f90
f010065f:	68 90 6f 1d f0       	push   $0xf01d6f90
f0100664:	68 48 49 10 f0       	push   $0xf0104948
f0100669:	e8 9f 2a 00 00       	call   f010310d <cprintf>
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
f0100690:	68 6c 49 10 f0       	push   $0xf010496c
f0100695:	e8 73 2a 00 00       	call   f010310d <cprintf>
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
f01006b0:	ff b3 c4 4d 10 f0    	pushl  -0xfefb23c(%ebx)
f01006b6:	ff b3 c0 4d 10 f0    	pushl  -0xfefb240(%ebx)
f01006bc:	68 e9 46 10 f0       	push   $0xf01046e9
f01006c1:	e8 47 2a 00 00       	call   f010310d <cprintf>
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
f01006f0:	68 98 49 10 f0       	push   $0xf0104998
f01006f5:	e8 13 2a 00 00       	call   f010310d <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f01006fa:	c7 04 24 cc 49 10 f0 	movl   $0xf01049cc,(%esp)
f0100701:	e8 07 2a 00 00       	call   f010310d <cprintf>
f0100706:	83 c4 10             	add    $0x10,%esp
f0100709:	e9 1a 01 00 00       	jmp    f0100828 <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f010070e:	83 ec 04             	sub    $0x4,%esp
f0100711:	6a 00                	push   $0x0
f0100713:	6a 00                	push   $0x0
f0100715:	ff 76 04             	pushl  0x4(%esi)
f0100718:	e8 f9 39 00 00       	call   f0104116 <strtol>
f010071d:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f010071f:	83 c4 0c             	add    $0xc,%esp
f0100722:	6a 00                	push   $0x0
f0100724:	6a 00                	push   $0x0
f0100726:	ff 76 08             	pushl  0x8(%esi)
f0100729:	e8 e8 39 00 00       	call   f0104116 <strtol>
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
f010074d:	68 f2 46 10 f0       	push   $0xf01046f2
f0100752:	e8 b6 29 00 00       	call   f010310d <cprintf>
        
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
f0100770:	68 03 47 10 f0       	push   $0xf0104703
f0100775:	e8 93 29 00 00       	call   f010310d <cprintf>
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
f010079d:	68 1a 47 10 f0       	push   $0xf010471a
f01007a2:	e8 66 29 00 00       	call   f010310d <cprintf>
f01007a7:	83 c4 10             	add    $0x10,%esp
f01007aa:	eb 74                	jmp    f0100820 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f01007ac:	83 ec 08             	sub    $0x8,%esp
f01007af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01007b4:	50                   	push   %eax
f01007b5:	68 27 47 10 f0       	push   $0xf0104727
f01007ba:	e8 4e 29 00 00       	call   f010310d <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f01007bf:	83 c4 10             	add    $0x10,%esp
f01007c2:	f6 03 04             	testb  $0x4,(%ebx)
f01007c5:	74 12                	je     f01007d9 <mon_showmappings+0xfe>
f01007c7:	83 ec 0c             	sub    $0xc,%esp
f01007ca:	68 2f 47 10 f0       	push   $0xf010472f
f01007cf:	e8 39 29 00 00       	call   f010310d <cprintf>
f01007d4:	83 c4 10             	add    $0x10,%esp
f01007d7:	eb 10                	jmp    f01007e9 <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f01007d9:	83 ec 0c             	sub    $0xc,%esp
f01007dc:	68 3c 47 10 f0       	push   $0xf010473c
f01007e1:	e8 27 29 00 00       	call   f010310d <cprintf>
f01007e6:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f01007e9:	f6 03 02             	testb  $0x2,(%ebx)
f01007ec:	74 12                	je     f0100800 <mon_showmappings+0x125>
f01007ee:	83 ec 0c             	sub    $0xc,%esp
f01007f1:	68 49 47 10 f0       	push   $0xf0104749
f01007f6:	e8 12 29 00 00       	call   f010310d <cprintf>
f01007fb:	83 c4 10             	add    $0x10,%esp
f01007fe:	eb 10                	jmp    f0100810 <mon_showmappings+0x135>
                else cprintf(" R ");
f0100800:	83 ec 0c             	sub    $0xc,%esp
f0100803:	68 4e 47 10 f0       	push   $0xf010474e
f0100808:	e8 00 29 00 00       	call   f010310d <cprintf>
f010080d:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f0100810:	83 ec 0c             	sub    $0xc,%esp
f0100813:	68 25 47 10 f0       	push   $0xf0104725
f0100818:	e8 f0 28 00 00       	call   f010310d <cprintf>
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
f010084a:	68 f4 49 10 f0       	push   $0xf01049f4
f010084f:	e8 b9 28 00 00       	call   f010310d <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f0100854:	c7 04 24 44 4a 10 f0 	movl   $0xf0104a44,(%esp)
f010085b:	e8 ad 28 00 00       	call   f010310d <cprintf>
f0100860:	83 c4 10             	add    $0x10,%esp
f0100863:	e9 a5 01 00 00       	jmp    f0100a0d <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f0100868:	83 ec 04             	sub    $0x4,%esp
f010086b:	6a 00                	push   $0x0
f010086d:	6a 00                	push   $0x0
f010086f:	ff 73 04             	pushl  0x4(%ebx)
f0100872:	e8 9f 38 00 00       	call   f0104116 <strtol>
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
f01008d6:	68 68 4a 10 f0       	push   $0xf0104a68
f01008db:	e8 2d 28 00 00       	call   f010310d <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f01008e0:	83 c4 10             	add    $0x10,%esp
f01008e3:	f6 03 02             	testb  $0x2,(%ebx)
f01008e6:	74 12                	je     f01008fa <mon_setpermission+0xc5>
f01008e8:	83 ec 0c             	sub    $0xc,%esp
f01008eb:	68 52 47 10 f0       	push   $0xf0104752
f01008f0:	e8 18 28 00 00       	call   f010310d <cprintf>
f01008f5:	83 c4 10             	add    $0x10,%esp
f01008f8:	eb 10                	jmp    f010090a <mon_setpermission+0xd5>
f01008fa:	83 ec 0c             	sub    $0xc,%esp
f01008fd:	68 55 47 10 f0       	push   $0xf0104755
f0100902:	e8 06 28 00 00       	call   f010310d <cprintf>
f0100907:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f010090a:	f6 03 04             	testb  $0x4,(%ebx)
f010090d:	74 12                	je     f0100921 <mon_setpermission+0xec>
f010090f:	83 ec 0c             	sub    $0xc,%esp
f0100912:	68 8a 57 10 f0       	push   $0xf010578a
f0100917:	e8 f1 27 00 00       	call   f010310d <cprintf>
f010091c:	83 c4 10             	add    $0x10,%esp
f010091f:	eb 10                	jmp    f0100931 <mon_setpermission+0xfc>
f0100921:	83 ec 0c             	sub    $0xc,%esp
f0100924:	68 33 5b 10 f0       	push   $0xf0105b33
f0100929:	e8 df 27 00 00       	call   f010310d <cprintf>
f010092e:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100931:	f6 03 01             	testb  $0x1,(%ebx)
f0100934:	74 12                	je     f0100948 <mon_setpermission+0x113>
f0100936:	83 ec 0c             	sub    $0xc,%esp
f0100939:	68 03 58 10 f0       	push   $0xf0105803
f010093e:	e8 ca 27 00 00       	call   f010310d <cprintf>
f0100943:	83 c4 10             	add    $0x10,%esp
f0100946:	eb 10                	jmp    f0100958 <mon_setpermission+0x123>
f0100948:	83 ec 0c             	sub    $0xc,%esp
f010094b:	68 56 47 10 f0       	push   $0xf0104756
f0100950:	e8 b8 27 00 00       	call   f010310d <cprintf>
f0100955:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f0100958:	83 ec 0c             	sub    $0xc,%esp
f010095b:	68 58 47 10 f0       	push   $0xf0104758
f0100960:	e8 a8 27 00 00       	call   f010310d <cprintf>
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
f010097e:	68 52 47 10 f0       	push   $0xf0104752
f0100983:	e8 85 27 00 00       	call   f010310d <cprintf>
f0100988:	83 c4 10             	add    $0x10,%esp
f010098b:	eb 10                	jmp    f010099d <mon_setpermission+0x168>
f010098d:	83 ec 0c             	sub    $0xc,%esp
f0100990:	68 55 47 10 f0       	push   $0xf0104755
f0100995:	e8 73 27 00 00       	call   f010310d <cprintf>
f010099a:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f010099d:	f6 03 04             	testb  $0x4,(%ebx)
f01009a0:	74 12                	je     f01009b4 <mon_setpermission+0x17f>
f01009a2:	83 ec 0c             	sub    $0xc,%esp
f01009a5:	68 8a 57 10 f0       	push   $0xf010578a
f01009aa:	e8 5e 27 00 00       	call   f010310d <cprintf>
f01009af:	83 c4 10             	add    $0x10,%esp
f01009b2:	eb 10                	jmp    f01009c4 <mon_setpermission+0x18f>
f01009b4:	83 ec 0c             	sub    $0xc,%esp
f01009b7:	68 33 5b 10 f0       	push   $0xf0105b33
f01009bc:	e8 4c 27 00 00       	call   f010310d <cprintf>
f01009c1:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f01009c4:	f6 03 01             	testb  $0x1,(%ebx)
f01009c7:	74 12                	je     f01009db <mon_setpermission+0x1a6>
f01009c9:	83 ec 0c             	sub    $0xc,%esp
f01009cc:	68 03 58 10 f0       	push   $0xf0105803
f01009d1:	e8 37 27 00 00       	call   f010310d <cprintf>
f01009d6:	83 c4 10             	add    $0x10,%esp
f01009d9:	eb 10                	jmp    f01009eb <mon_setpermission+0x1b6>
f01009db:	83 ec 0c             	sub    $0xc,%esp
f01009de:	68 56 47 10 f0       	push   $0xf0104756
f01009e3:	e8 25 27 00 00       	call   f010310d <cprintf>
f01009e8:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f01009eb:	83 ec 0c             	sub    $0xc,%esp
f01009ee:	68 25 47 10 f0       	push   $0xf0104725
f01009f3:	e8 15 27 00 00       	call   f010310d <cprintf>
f01009f8:	83 c4 10             	add    $0x10,%esp
f01009fb:	eb 10                	jmp    f0100a0d <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f01009fd:	83 ec 0c             	sub    $0xc,%esp
f0100a00:	68 1a 47 10 f0       	push   $0xf010471a
f0100a05:	e8 03 27 00 00       	call   f010310d <cprintf>
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
f0100a2b:	68 8c 4a 10 f0       	push   $0xf0104a8c
f0100a30:	e8 d8 26 00 00       	call   f010310d <cprintf>
        cprintf("num show the color attribute. \n");
f0100a35:	c7 04 24 bc 4a 10 f0 	movl   $0xf0104abc,(%esp)
f0100a3c:	e8 cc 26 00 00       	call   f010310d <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100a41:	c7 04 24 dc 4a 10 f0 	movl   $0xf0104adc,(%esp)
f0100a48:	e8 c0 26 00 00       	call   f010310d <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100a4d:	c7 04 24 10 4b 10 f0 	movl   $0xf0104b10,(%esp)
f0100a54:	e8 b4 26 00 00       	call   f010310d <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100a59:	c7 04 24 54 4b 10 f0 	movl   $0xf0104b54,(%esp)
f0100a60:	e8 a8 26 00 00       	call   f010310d <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100a65:	c7 04 24 69 47 10 f0 	movl   $0xf0104769,(%esp)
f0100a6c:	e8 9c 26 00 00       	call   f010310d <cprintf>
        cprintf("         set the background color to black\n");
f0100a71:	c7 04 24 98 4b 10 f0 	movl   $0xf0104b98,(%esp)
f0100a78:	e8 90 26 00 00       	call   f010310d <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100a7d:	c7 04 24 c4 4b 10 f0 	movl   $0xf0104bc4,(%esp)
f0100a84:	e8 84 26 00 00       	call   f010310d <cprintf>
f0100a89:	83 c4 10             	add    $0x10,%esp
f0100a8c:	eb 52                	jmp    f0100ae0 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100a8e:	83 ec 0c             	sub    $0xc,%esp
f0100a91:	ff 73 04             	pushl  0x4(%ebx)
f0100a94:	e8 7b 33 00 00       	call   f0103e14 <strlen>
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
f0100ad3:	68 f8 4b 10 f0       	push   $0xf0104bf8
f0100ad8:	e8 30 26 00 00       	call   f010310d <cprintf>
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
f0100b14:	68 1c 4c 10 f0       	push   $0xf0104c1c
f0100b19:	e8 ef 25 00 00       	call   f010310d <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b1e:	83 c4 18             	add    $0x18,%esp
f0100b21:	57                   	push   %edi
f0100b22:	ff 76 04             	pushl  0x4(%esi)
f0100b25:	e8 c3 2a 00 00       	call   f01035ed <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100b2a:	83 c4 0c             	add    $0xc,%esp
f0100b2d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100b30:	ff 75 d0             	pushl  -0x30(%ebp)
f0100b33:	68 85 47 10 f0       	push   $0xf0104785
f0100b38:	e8 d0 25 00 00       	call   f010310d <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100b3d:	83 c4 0c             	add    $0xc,%esp
f0100b40:	ff 75 d8             	pushl  -0x28(%ebp)
f0100b43:	ff 75 dc             	pushl  -0x24(%ebp)
f0100b46:	68 95 47 10 f0       	push   $0xf0104795
f0100b4b:	e8 bd 25 00 00       	call   f010310d <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100b50:	83 c4 08             	add    $0x8,%esp
f0100b53:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100b56:	53                   	push   %ebx
f0100b57:	68 9a 47 10 f0       	push   $0xf010479a
f0100b5c:	e8 ac 25 00 00       	call   f010310d <cprintf>
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
f0100b93:	68 54 4c 10 f0       	push   $0xf0104c54
f0100b98:	68 93 00 00 00       	push   $0x93
f0100b9d:	68 9f 47 10 f0       	push   $0xf010479f
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
f0100bd7:	68 54 4c 10 f0       	push   $0xf0104c54
f0100bdc:	68 98 00 00 00       	push   $0x98
f0100be1:	68 9f 47 10 f0       	push   $0xf010479f
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
f0100c39:	68 78 4c 10 f0       	push   $0xf0104c78
f0100c3e:	e8 ca 24 00 00       	call   f010310d <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100c43:	c7 04 24 a8 4c 10 f0 	movl   $0xf0104ca8,(%esp)
f0100c4a:	e8 be 24 00 00       	call   f010310d <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100c4f:	c7 04 24 d0 4c 10 f0 	movl   $0xf0104cd0,(%esp)
f0100c56:	e8 b2 24 00 00       	call   f010310d <cprintf>
f0100c5b:	83 c4 10             	add    $0x10,%esp
f0100c5e:	e9 59 01 00 00       	jmp    f0100dbc <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100c63:	83 ec 04             	sub    $0x4,%esp
f0100c66:	6a 00                	push   $0x0
f0100c68:	6a 00                	push   $0x0
f0100c6a:	ff 76 08             	pushl  0x8(%esi)
f0100c6d:	e8 a4 34 00 00       	call   f0104116 <strtol>
f0100c72:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100c74:	83 c4 0c             	add    $0xc,%esp
f0100c77:	6a 00                	push   $0x0
f0100c79:	6a 00                	push   $0x0
f0100c7b:	ff 76 0c             	pushl  0xc(%esi)
f0100c7e:	e8 93 34 00 00       	call   f0104116 <strtol>
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
f0100cbf:	68 25 47 10 f0       	push   $0xf0104725
f0100cc4:	e8 44 24 00 00       	call   f010310d <cprintf>
f0100cc9:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100ccc:	83 ec 08             	sub    $0x8,%esp
f0100ccf:	53                   	push   %ebx
f0100cd0:	68 ae 47 10 f0       	push   $0xf01047ae
f0100cd5:	e8 33 24 00 00       	call   f010310d <cprintf>
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
f0100d06:	68 b8 47 10 f0       	push   $0xf01047b8
f0100d0b:	e8 fd 23 00 00       	call   f010310d <cprintf>
f0100d10:	83 c4 10             	add    $0x10,%esp
f0100d13:	eb 10                	jmp    f0100d25 <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100d15:	83 ec 0c             	sub    $0xc,%esp
f0100d18:	68 c3 47 10 f0       	push   $0xf01047c3
f0100d1d:	e8 eb 23 00 00       	call   f010310d <cprintf>
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
f0100d30:	68 25 47 10 f0       	push   $0xf0104725
f0100d35:	e8 d3 23 00 00       	call   f010310d <cprintf>
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
f0100d50:	68 25 47 10 f0       	push   $0xf0104725
f0100d55:	e8 b3 23 00 00       	call   f010310d <cprintf>
f0100d5a:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100d5d:	83 ec 08             	sub    $0x8,%esp
f0100d60:	53                   	push   %ebx
f0100d61:	68 ae 47 10 f0       	push   $0xf01047ae
f0100d66:	e8 a2 23 00 00       	call   f010310d <cprintf>
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
f0100d85:	68 b8 47 10 f0       	push   $0xf01047b8
f0100d8a:	e8 7e 23 00 00       	call   f010310d <cprintf>
f0100d8f:	83 c4 10             	add    $0x10,%esp
f0100d92:	eb 10                	jmp    f0100da4 <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100d94:	83 ec 0c             	sub    $0xc,%esp
f0100d97:	68 c1 47 10 f0       	push   $0xf01047c1
f0100d9c:	e8 6c 23 00 00       	call   f010310d <cprintf>
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
f0100daf:	68 25 47 10 f0       	push   $0xf0104725
f0100db4:	e8 54 23 00 00       	call   f010310d <cprintf>
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
f0100dd2:	68 14 4d 10 f0       	push   $0xf0104d14
f0100dd7:	e8 31 23 00 00       	call   f010310d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100ddc:	c7 04 24 38 4d 10 f0 	movl   $0xf0104d38,(%esp)
f0100de3:	e8 25 23 00 00       	call   f010310d <cprintf>

	if (tf != NULL)
f0100de8:	83 c4 10             	add    $0x10,%esp
f0100deb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100def:	74 0e                	je     f0100dff <monitor+0x36>
		print_trapframe(tf);
f0100df1:	83 ec 0c             	sub    $0xc,%esp
f0100df4:	ff 75 08             	pushl  0x8(%ebp)
f0100df7:	e8 1d 24 00 00       	call   f0103219 <print_trapframe>
f0100dfc:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100dff:	83 ec 0c             	sub    $0xc,%esp
f0100e02:	68 ce 47 10 f0       	push   $0xf01047ce
f0100e07:	e8 38 2f 00 00       	call   f0103d44 <readline>
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
f0100e34:	68 d2 47 10 f0       	push   $0xf01047d2
f0100e39:	e8 4f 31 00 00       	call   f0103f8d <strchr>
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
f0100e54:	68 d7 47 10 f0       	push   $0xf01047d7
f0100e59:	e8 af 22 00 00       	call   f010310d <cprintf>
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
f0100e7e:	68 d2 47 10 f0       	push   $0xf01047d2
f0100e83:	e8 05 31 00 00       	call   f0103f8d <strchr>
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
f0100ea1:	bb c0 4d 10 f0       	mov    $0xf0104dc0,%ebx
f0100ea6:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100eab:	83 ec 08             	sub    $0x8,%esp
f0100eae:	ff 33                	pushl  (%ebx)
f0100eb0:	ff 75 a8             	pushl  -0x58(%ebp)
f0100eb3:	e8 67 30 00 00       	call   f0103f1f <strcmp>
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
f0100ecd:	ff 97 c8 4d 10 f0    	call   *-0xfefb238(%edi)
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
f0100eee:	68 f4 47 10 f0       	push   $0xf01047f4
f0100ef3:	e8 15 22 00 00       	call   f010310d <cprintf>
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
f0100f64:	68 14 4e 10 f0       	push   $0xf0104e14
f0100f69:	68 0a 03 00 00       	push   $0x30a
f0100f6e:	68 75 55 10 f0       	push   $0xf0105575
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
f0100fac:	e8 fb 20 00 00       	call   f01030ac <mc146818_read>
f0100fb1:	89 c6                	mov    %eax,%esi
f0100fb3:	43                   	inc    %ebx
f0100fb4:	89 1c 24             	mov    %ebx,(%esp)
f0100fb7:	e8 f0 20 00 00       	call   f01030ac <mc146818_read>
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
f0100fe9:	68 38 4e 10 f0       	push   $0xf0104e38
f0100fee:	68 48 02 00 00       	push   $0x248
f0100ff3:	68 75 55 10 f0       	push   $0xf0105575
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
f0101076:	68 14 4e 10 f0       	push   $0xf0104e14
f010107b:	6a 56                	push   $0x56
f010107d:	68 81 55 10 f0       	push   $0xf0105581
f0101082:	e8 1e f0 ff ff       	call   f01000a5 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101087:	83 ec 04             	sub    $0x4,%esp
f010108a:	68 80 00 00 00       	push   $0x80
f010108f:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101094:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101099:	50                   	push   %eax
f010109a:	e8 3e 2f 00 00       	call   f0103fdd <memset>
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
f0101110:	68 8f 55 10 f0       	push   $0xf010558f
f0101115:	68 9b 55 10 f0       	push   $0xf010559b
f010111a:	68 62 02 00 00       	push   $0x262
f010111f:	68 75 55 10 f0       	push   $0xf0105575
f0101124:	e8 7c ef ff ff       	call   f01000a5 <_panic>
		assert(pp < pages + npages);
f0101129:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f010112c:	72 19                	jb     f0101147 <check_page_free_list+0x17f>
f010112e:	68 b0 55 10 f0       	push   $0xf01055b0
f0101133:	68 9b 55 10 f0       	push   $0xf010559b
f0101138:	68 63 02 00 00       	push   $0x263
f010113d:	68 75 55 10 f0       	push   $0xf0105575
f0101142:	e8 5e ef ff ff       	call   f01000a5 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101147:	89 d0                	mov    %edx,%eax
f0101149:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010114c:	a8 07                	test   $0x7,%al
f010114e:	74 19                	je     f0101169 <check_page_free_list+0x1a1>
f0101150:	68 5c 4e 10 f0       	push   $0xf0104e5c
f0101155:	68 9b 55 10 f0       	push   $0xf010559b
f010115a:	68 64 02 00 00       	push   $0x264
f010115f:	68 75 55 10 f0       	push   $0xf0105575
f0101164:	e8 3c ef ff ff       	call   f01000a5 <_panic>
f0101169:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010116c:	c1 e0 0c             	shl    $0xc,%eax
f010116f:	75 19                	jne    f010118a <check_page_free_list+0x1c2>
f0101171:	68 c4 55 10 f0       	push   $0xf01055c4
f0101176:	68 9b 55 10 f0       	push   $0xf010559b
f010117b:	68 67 02 00 00       	push   $0x267
f0101180:	68 75 55 10 f0       	push   $0xf0105575
f0101185:	e8 1b ef ff ff       	call   f01000a5 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010118a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010118f:	75 19                	jne    f01011aa <check_page_free_list+0x1e2>
f0101191:	68 d5 55 10 f0       	push   $0xf01055d5
f0101196:	68 9b 55 10 f0       	push   $0xf010559b
f010119b:	68 68 02 00 00       	push   $0x268
f01011a0:	68 75 55 10 f0       	push   $0xf0105575
f01011a5:	e8 fb ee ff ff       	call   f01000a5 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01011aa:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01011af:	75 19                	jne    f01011ca <check_page_free_list+0x202>
f01011b1:	68 90 4e 10 f0       	push   $0xf0104e90
f01011b6:	68 9b 55 10 f0       	push   $0xf010559b
f01011bb:	68 69 02 00 00       	push   $0x269
f01011c0:	68 75 55 10 f0       	push   $0xf0105575
f01011c5:	e8 db ee ff ff       	call   f01000a5 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01011ca:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01011cf:	75 19                	jne    f01011ea <check_page_free_list+0x222>
f01011d1:	68 ee 55 10 f0       	push   $0xf01055ee
f01011d6:	68 9b 55 10 f0       	push   $0xf010559b
f01011db:	68 6a 02 00 00       	push   $0x26a
f01011e0:	68 75 55 10 f0       	push   $0xf0105575
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
f01011fc:	68 14 4e 10 f0       	push   $0xf0104e14
f0101201:	6a 56                	push   $0x56
f0101203:	68 81 55 10 f0       	push   $0xf0105581
f0101208:	e8 98 ee ff ff       	call   f01000a5 <_panic>
	return (void *)(pa + KERNBASE);
f010120d:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101213:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0101216:	76 1c                	jbe    f0101234 <check_page_free_list+0x26c>
f0101218:	68 b4 4e 10 f0       	push   $0xf0104eb4
f010121d:	68 9b 55 10 f0       	push   $0xf010559b
f0101222:	68 6b 02 00 00       	push   $0x26b
f0101227:	68 75 55 10 f0       	push   $0xf0105575
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
f0101243:	68 08 56 10 f0       	push   $0xf0105608
f0101248:	68 9b 55 10 f0       	push   $0xf010559b
f010124d:	68 73 02 00 00       	push   $0x273
f0101252:	68 75 55 10 f0       	push   $0xf0105575
f0101257:	e8 49 ee ff ff       	call   f01000a5 <_panic>
	assert(nfree_extmem > 0);
f010125c:	85 f6                	test   %esi,%esi
f010125e:	7f 19                	jg     f0101279 <check_page_free_list+0x2b1>
f0101260:	68 1a 56 10 f0       	push   $0xf010561a
f0101265:	68 9b 55 10 f0       	push   $0xf010559b
f010126a:	68 74 02 00 00       	push   $0x274
f010126f:	68 75 55 10 f0       	push   $0xf0105575
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
f01012a2:	68 54 4c 10 f0       	push   $0xf0104c54
f01012a7:	68 24 01 00 00       	push   $0x124
f01012ac:	68 75 55 10 f0       	push   $0xf0105575
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
f0101379:	68 14 4e 10 f0       	push   $0xf0104e14
f010137e:	6a 56                	push   $0x56
f0101380:	68 81 55 10 f0       	push   $0xf0105581
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
f010139a:	e8 3e 2c 00 00       	call   f0103fdd <memset>
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
f0101454:	68 14 4e 10 f0       	push   $0xf0104e14
f0101459:	68 87 01 00 00       	push   $0x187
f010145e:	68 75 55 10 f0       	push   $0xf0105575
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
f0101517:	68 fc 4e 10 f0       	push   $0xf0104efc
f010151c:	6a 4f                	push   $0x4f
f010151e:	68 81 55 10 f0       	push   $0xf0105581
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
f010160b:	83 ec 2c             	sub    $0x2c,%esp
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
f0101689:	68 1c 4f 10 f0       	push   $0xf0104f1c
f010168e:	e8 7a 1a 00 00       	call   f010310d <cprintf>
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
f01016ad:	e8 2b 29 00 00       	call   f0103fdd <memset>
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
f01016c2:	68 54 4c 10 f0       	push   $0xf0104c54
f01016c7:	68 8e 00 00 00       	push   $0x8e
f01016cc:	68 75 55 10 f0       	push   $0xf0105575
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
    

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f01016f7:	b8 00 80 01 00       	mov    $0x18000,%eax
f01016fc:	e8 07 f8 ff ff       	call   f0100f08 <boot_alloc>
f0101701:	a3 b8 62 1d f0       	mov    %eax,0xf01d62b8
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101706:	e8 76 fb ff ff       	call   f0101281 <page_init>

	check_page_free_list(1);
f010170b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101710:	e8 b3 f8 ff ff       	call   f0100fc8 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101715:	83 3d 8c 6f 1d f0 00 	cmpl   $0x0,0xf01d6f8c
f010171c:	75 17                	jne    f0101735 <mem_init+0x130>
		panic("'pages' is a null pointer!");
f010171e:	83 ec 04             	sub    $0x4,%esp
f0101721:	68 2b 56 10 f0       	push   $0xf010562b
f0101726:	68 85 02 00 00       	push   $0x285
f010172b:	68 75 55 10 f0       	push   $0xf0105575
f0101730:	e8 70 e9 ff ff       	call   f01000a5 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101735:	a1 ac 62 1d f0       	mov    0xf01d62ac,%eax
f010173a:	85 c0                	test   %eax,%eax
f010173c:	74 0e                	je     f010174c <mem_init+0x147>
f010173e:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101743:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101744:	8b 00                	mov    (%eax),%eax
f0101746:	85 c0                	test   %eax,%eax
f0101748:	75 f9                	jne    f0101743 <mem_init+0x13e>
f010174a:	eb 05                	jmp    f0101751 <mem_init+0x14c>
f010174c:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101751:	83 ec 0c             	sub    $0xc,%esp
f0101754:	6a 00                	push   $0x0
f0101756:	e8 d3 fb ff ff       	call   f010132e <page_alloc>
f010175b:	89 c6                	mov    %eax,%esi
f010175d:	83 c4 10             	add    $0x10,%esp
f0101760:	85 c0                	test   %eax,%eax
f0101762:	75 19                	jne    f010177d <mem_init+0x178>
f0101764:	68 46 56 10 f0       	push   $0xf0105646
f0101769:	68 9b 55 10 f0       	push   $0xf010559b
f010176e:	68 8d 02 00 00       	push   $0x28d
f0101773:	68 75 55 10 f0       	push   $0xf0105575
f0101778:	e8 28 e9 ff ff       	call   f01000a5 <_panic>
	assert((pp1 = page_alloc(0)));
f010177d:	83 ec 0c             	sub    $0xc,%esp
f0101780:	6a 00                	push   $0x0
f0101782:	e8 a7 fb ff ff       	call   f010132e <page_alloc>
f0101787:	89 c7                	mov    %eax,%edi
f0101789:	83 c4 10             	add    $0x10,%esp
f010178c:	85 c0                	test   %eax,%eax
f010178e:	75 19                	jne    f01017a9 <mem_init+0x1a4>
f0101790:	68 5c 56 10 f0       	push   $0xf010565c
f0101795:	68 9b 55 10 f0       	push   $0xf010559b
f010179a:	68 8e 02 00 00       	push   $0x28e
f010179f:	68 75 55 10 f0       	push   $0xf0105575
f01017a4:	e8 fc e8 ff ff       	call   f01000a5 <_panic>
	assert((pp2 = page_alloc(0)));
f01017a9:	83 ec 0c             	sub    $0xc,%esp
f01017ac:	6a 00                	push   $0x0
f01017ae:	e8 7b fb ff ff       	call   f010132e <page_alloc>
f01017b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017b6:	83 c4 10             	add    $0x10,%esp
f01017b9:	85 c0                	test   %eax,%eax
f01017bb:	75 19                	jne    f01017d6 <mem_init+0x1d1>
f01017bd:	68 72 56 10 f0       	push   $0xf0105672
f01017c2:	68 9b 55 10 f0       	push   $0xf010559b
f01017c7:	68 8f 02 00 00       	push   $0x28f
f01017cc:	68 75 55 10 f0       	push   $0xf0105575
f01017d1:	e8 cf e8 ff ff       	call   f01000a5 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017d6:	39 fe                	cmp    %edi,%esi
f01017d8:	75 19                	jne    f01017f3 <mem_init+0x1ee>
f01017da:	68 88 56 10 f0       	push   $0xf0105688
f01017df:	68 9b 55 10 f0       	push   $0xf010559b
f01017e4:	68 92 02 00 00       	push   $0x292
f01017e9:	68 75 55 10 f0       	push   $0xf0105575
f01017ee:	e8 b2 e8 ff ff       	call   f01000a5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017f3:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01017f6:	74 05                	je     f01017fd <mem_init+0x1f8>
f01017f8:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01017fb:	75 19                	jne    f0101816 <mem_init+0x211>
f01017fd:	68 58 4f 10 f0       	push   $0xf0104f58
f0101802:	68 9b 55 10 f0       	push   $0xf010559b
f0101807:	68 93 02 00 00       	push   $0x293
f010180c:	68 75 55 10 f0       	push   $0xf0105575
f0101811:	e8 8f e8 ff ff       	call   f01000a5 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101816:	8b 15 8c 6f 1d f0    	mov    0xf01d6f8c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010181c:	a1 84 6f 1d f0       	mov    0xf01d6f84,%eax
f0101821:	c1 e0 0c             	shl    $0xc,%eax
f0101824:	89 f1                	mov    %esi,%ecx
f0101826:	29 d1                	sub    %edx,%ecx
f0101828:	c1 f9 03             	sar    $0x3,%ecx
f010182b:	c1 e1 0c             	shl    $0xc,%ecx
f010182e:	39 c1                	cmp    %eax,%ecx
f0101830:	72 19                	jb     f010184b <mem_init+0x246>
f0101832:	68 9a 56 10 f0       	push   $0xf010569a
f0101837:	68 9b 55 10 f0       	push   $0xf010559b
f010183c:	68 94 02 00 00       	push   $0x294
f0101841:	68 75 55 10 f0       	push   $0xf0105575
f0101846:	e8 5a e8 ff ff       	call   f01000a5 <_panic>
f010184b:	89 f9                	mov    %edi,%ecx
f010184d:	29 d1                	sub    %edx,%ecx
f010184f:	c1 f9 03             	sar    $0x3,%ecx
f0101852:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101855:	39 c8                	cmp    %ecx,%eax
f0101857:	77 19                	ja     f0101872 <mem_init+0x26d>
f0101859:	68 b7 56 10 f0       	push   $0xf01056b7
f010185e:	68 9b 55 10 f0       	push   $0xf010559b
f0101863:	68 95 02 00 00       	push   $0x295
f0101868:	68 75 55 10 f0       	push   $0xf0105575
f010186d:	e8 33 e8 ff ff       	call   f01000a5 <_panic>
f0101872:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101875:	29 d1                	sub    %edx,%ecx
f0101877:	89 ca                	mov    %ecx,%edx
f0101879:	c1 fa 03             	sar    $0x3,%edx
f010187c:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010187f:	39 d0                	cmp    %edx,%eax
f0101881:	77 19                	ja     f010189c <mem_init+0x297>
f0101883:	68 d4 56 10 f0       	push   $0xf01056d4
f0101888:	68 9b 55 10 f0       	push   $0xf010559b
f010188d:	68 96 02 00 00       	push   $0x296
f0101892:	68 75 55 10 f0       	push   $0xf0105575
f0101897:	e8 09 e8 ff ff       	call   f01000a5 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010189c:	a1 ac 62 1d f0       	mov    0xf01d62ac,%eax
f01018a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018a4:	c7 05 ac 62 1d f0 00 	movl   $0x0,0xf01d62ac
f01018ab:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018ae:	83 ec 0c             	sub    $0xc,%esp
f01018b1:	6a 00                	push   $0x0
f01018b3:	e8 76 fa ff ff       	call   f010132e <page_alloc>
f01018b8:	83 c4 10             	add    $0x10,%esp
f01018bb:	85 c0                	test   %eax,%eax
f01018bd:	74 19                	je     f01018d8 <mem_init+0x2d3>
f01018bf:	68 f1 56 10 f0       	push   $0xf01056f1
f01018c4:	68 9b 55 10 f0       	push   $0xf010559b
f01018c9:	68 9d 02 00 00       	push   $0x29d
f01018ce:	68 75 55 10 f0       	push   $0xf0105575
f01018d3:	e8 cd e7 ff ff       	call   f01000a5 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01018d8:	83 ec 0c             	sub    $0xc,%esp
f01018db:	56                   	push   %esi
f01018dc:	e8 d7 fa ff ff       	call   f01013b8 <page_free>
	page_free(pp1);
f01018e1:	89 3c 24             	mov    %edi,(%esp)
f01018e4:	e8 cf fa ff ff       	call   f01013b8 <page_free>
	page_free(pp2);
f01018e9:	83 c4 04             	add    $0x4,%esp
f01018ec:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018ef:	e8 c4 fa ff ff       	call   f01013b8 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018fb:	e8 2e fa ff ff       	call   f010132e <page_alloc>
f0101900:	89 c6                	mov    %eax,%esi
f0101902:	83 c4 10             	add    $0x10,%esp
f0101905:	85 c0                	test   %eax,%eax
f0101907:	75 19                	jne    f0101922 <mem_init+0x31d>
f0101909:	68 46 56 10 f0       	push   $0xf0105646
f010190e:	68 9b 55 10 f0       	push   $0xf010559b
f0101913:	68 a4 02 00 00       	push   $0x2a4
f0101918:	68 75 55 10 f0       	push   $0xf0105575
f010191d:	e8 83 e7 ff ff       	call   f01000a5 <_panic>
	assert((pp1 = page_alloc(0)));
f0101922:	83 ec 0c             	sub    $0xc,%esp
f0101925:	6a 00                	push   $0x0
f0101927:	e8 02 fa ff ff       	call   f010132e <page_alloc>
f010192c:	89 c7                	mov    %eax,%edi
f010192e:	83 c4 10             	add    $0x10,%esp
f0101931:	85 c0                	test   %eax,%eax
f0101933:	75 19                	jne    f010194e <mem_init+0x349>
f0101935:	68 5c 56 10 f0       	push   $0xf010565c
f010193a:	68 9b 55 10 f0       	push   $0xf010559b
f010193f:	68 a5 02 00 00       	push   $0x2a5
f0101944:	68 75 55 10 f0       	push   $0xf0105575
f0101949:	e8 57 e7 ff ff       	call   f01000a5 <_panic>
	assert((pp2 = page_alloc(0)));
f010194e:	83 ec 0c             	sub    $0xc,%esp
f0101951:	6a 00                	push   $0x0
f0101953:	e8 d6 f9 ff ff       	call   f010132e <page_alloc>
f0101958:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010195b:	83 c4 10             	add    $0x10,%esp
f010195e:	85 c0                	test   %eax,%eax
f0101960:	75 19                	jne    f010197b <mem_init+0x376>
f0101962:	68 72 56 10 f0       	push   $0xf0105672
f0101967:	68 9b 55 10 f0       	push   $0xf010559b
f010196c:	68 a6 02 00 00       	push   $0x2a6
f0101971:	68 75 55 10 f0       	push   $0xf0105575
f0101976:	e8 2a e7 ff ff       	call   f01000a5 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010197b:	39 fe                	cmp    %edi,%esi
f010197d:	75 19                	jne    f0101998 <mem_init+0x393>
f010197f:	68 88 56 10 f0       	push   $0xf0105688
f0101984:	68 9b 55 10 f0       	push   $0xf010559b
f0101989:	68 a8 02 00 00       	push   $0x2a8
f010198e:	68 75 55 10 f0       	push   $0xf0105575
f0101993:	e8 0d e7 ff ff       	call   f01000a5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101998:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010199b:	74 05                	je     f01019a2 <mem_init+0x39d>
f010199d:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01019a0:	75 19                	jne    f01019bb <mem_init+0x3b6>
f01019a2:	68 58 4f 10 f0       	push   $0xf0104f58
f01019a7:	68 9b 55 10 f0       	push   $0xf010559b
f01019ac:	68 a9 02 00 00       	push   $0x2a9
f01019b1:	68 75 55 10 f0       	push   $0xf0105575
f01019b6:	e8 ea e6 ff ff       	call   f01000a5 <_panic>
	assert(!page_alloc(0));
f01019bb:	83 ec 0c             	sub    $0xc,%esp
f01019be:	6a 00                	push   $0x0
f01019c0:	e8 69 f9 ff ff       	call   f010132e <page_alloc>
f01019c5:	83 c4 10             	add    $0x10,%esp
f01019c8:	85 c0                	test   %eax,%eax
f01019ca:	74 19                	je     f01019e5 <mem_init+0x3e0>
f01019cc:	68 f1 56 10 f0       	push   $0xf01056f1
f01019d1:	68 9b 55 10 f0       	push   $0xf010559b
f01019d6:	68 aa 02 00 00       	push   $0x2aa
f01019db:	68 75 55 10 f0       	push   $0xf0105575
f01019e0:	e8 c0 e6 ff ff       	call   f01000a5 <_panic>
f01019e5:	89 f0                	mov    %esi,%eax
f01019e7:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f01019ed:	c1 f8 03             	sar    $0x3,%eax
f01019f0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019f3:	89 c2                	mov    %eax,%edx
f01019f5:	c1 ea 0c             	shr    $0xc,%edx
f01019f8:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f01019fe:	72 12                	jb     f0101a12 <mem_init+0x40d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a00:	50                   	push   %eax
f0101a01:	68 14 4e 10 f0       	push   $0xf0104e14
f0101a06:	6a 56                	push   $0x56
f0101a08:	68 81 55 10 f0       	push   $0xf0105581
f0101a0d:	e8 93 e6 ff ff       	call   f01000a5 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101a12:	83 ec 04             	sub    $0x4,%esp
f0101a15:	68 00 10 00 00       	push   $0x1000
f0101a1a:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101a1c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a21:	50                   	push   %eax
f0101a22:	e8 b6 25 00 00       	call   f0103fdd <memset>
	page_free(pp0);
f0101a27:	89 34 24             	mov    %esi,(%esp)
f0101a2a:	e8 89 f9 ff ff       	call   f01013b8 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a36:	e8 f3 f8 ff ff       	call   f010132e <page_alloc>
f0101a3b:	83 c4 10             	add    $0x10,%esp
f0101a3e:	85 c0                	test   %eax,%eax
f0101a40:	75 19                	jne    f0101a5b <mem_init+0x456>
f0101a42:	68 00 57 10 f0       	push   $0xf0105700
f0101a47:	68 9b 55 10 f0       	push   $0xf010559b
f0101a4c:	68 af 02 00 00       	push   $0x2af
f0101a51:	68 75 55 10 f0       	push   $0xf0105575
f0101a56:	e8 4a e6 ff ff       	call   f01000a5 <_panic>
	assert(pp && pp0 == pp);
f0101a5b:	39 c6                	cmp    %eax,%esi
f0101a5d:	74 19                	je     f0101a78 <mem_init+0x473>
f0101a5f:	68 1e 57 10 f0       	push   $0xf010571e
f0101a64:	68 9b 55 10 f0       	push   $0xf010559b
f0101a69:	68 b0 02 00 00       	push   $0x2b0
f0101a6e:	68 75 55 10 f0       	push   $0xf0105575
f0101a73:	e8 2d e6 ff ff       	call   f01000a5 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a78:	89 f2                	mov    %esi,%edx
f0101a7a:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0101a80:	c1 fa 03             	sar    $0x3,%edx
f0101a83:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a86:	89 d0                	mov    %edx,%eax
f0101a88:	c1 e8 0c             	shr    $0xc,%eax
f0101a8b:	3b 05 84 6f 1d f0    	cmp    0xf01d6f84,%eax
f0101a91:	72 12                	jb     f0101aa5 <mem_init+0x4a0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a93:	52                   	push   %edx
f0101a94:	68 14 4e 10 f0       	push   $0xf0104e14
f0101a99:	6a 56                	push   $0x56
f0101a9b:	68 81 55 10 f0       	push   $0xf0105581
f0101aa0:	e8 00 e6 ff ff       	call   f01000a5 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101aa5:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101aac:	75 11                	jne    f0101abf <mem_init+0x4ba>
f0101aae:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101ab4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101aba:	80 38 00             	cmpb   $0x0,(%eax)
f0101abd:	74 19                	je     f0101ad8 <mem_init+0x4d3>
f0101abf:	68 2e 57 10 f0       	push   $0xf010572e
f0101ac4:	68 9b 55 10 f0       	push   $0xf010559b
f0101ac9:	68 b3 02 00 00       	push   $0x2b3
f0101ace:	68 75 55 10 f0       	push   $0xf0105575
f0101ad3:	e8 cd e5 ff ff       	call   f01000a5 <_panic>
f0101ad8:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101ad9:	39 d0                	cmp    %edx,%eax
f0101adb:	75 dd                	jne    f0101aba <mem_init+0x4b5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101add:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101ae0:	89 0d ac 62 1d f0    	mov    %ecx,0xf01d62ac

	// free the pages we took
	page_free(pp0);
f0101ae6:	83 ec 0c             	sub    $0xc,%esp
f0101ae9:	56                   	push   %esi
f0101aea:	e8 c9 f8 ff ff       	call   f01013b8 <page_free>
	page_free(pp1);
f0101aef:	89 3c 24             	mov    %edi,(%esp)
f0101af2:	e8 c1 f8 ff ff       	call   f01013b8 <page_free>
	page_free(pp2);
f0101af7:	83 c4 04             	add    $0x4,%esp
f0101afa:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101afd:	e8 b6 f8 ff ff       	call   f01013b8 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b02:	a1 ac 62 1d f0       	mov    0xf01d62ac,%eax
f0101b07:	83 c4 10             	add    $0x10,%esp
f0101b0a:	85 c0                	test   %eax,%eax
f0101b0c:	74 07                	je     f0101b15 <mem_init+0x510>
		--nfree;
f0101b0e:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b0f:	8b 00                	mov    (%eax),%eax
f0101b11:	85 c0                	test   %eax,%eax
f0101b13:	75 f9                	jne    f0101b0e <mem_init+0x509>
		--nfree;
	assert(nfree == 0);
f0101b15:	85 db                	test   %ebx,%ebx
f0101b17:	74 19                	je     f0101b32 <mem_init+0x52d>
f0101b19:	68 38 57 10 f0       	push   $0xf0105738
f0101b1e:	68 9b 55 10 f0       	push   $0xf010559b
f0101b23:	68 c0 02 00 00       	push   $0x2c0
f0101b28:	68 75 55 10 f0       	push   $0xf0105575
f0101b2d:	e8 73 e5 ff ff       	call   f01000a5 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101b32:	83 ec 0c             	sub    $0xc,%esp
f0101b35:	68 78 4f 10 f0       	push   $0xf0104f78
f0101b3a:	e8 ce 15 00 00       	call   f010310d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b46:	e8 e3 f7 ff ff       	call   f010132e <page_alloc>
f0101b4b:	89 c7                	mov    %eax,%edi
f0101b4d:	83 c4 10             	add    $0x10,%esp
f0101b50:	85 c0                	test   %eax,%eax
f0101b52:	75 19                	jne    f0101b6d <mem_init+0x568>
f0101b54:	68 46 56 10 f0       	push   $0xf0105646
f0101b59:	68 9b 55 10 f0       	push   $0xf010559b
f0101b5e:	68 1e 03 00 00       	push   $0x31e
f0101b63:	68 75 55 10 f0       	push   $0xf0105575
f0101b68:	e8 38 e5 ff ff       	call   f01000a5 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b6d:	83 ec 0c             	sub    $0xc,%esp
f0101b70:	6a 00                	push   $0x0
f0101b72:	e8 b7 f7 ff ff       	call   f010132e <page_alloc>
f0101b77:	89 c6                	mov    %eax,%esi
f0101b79:	83 c4 10             	add    $0x10,%esp
f0101b7c:	85 c0                	test   %eax,%eax
f0101b7e:	75 19                	jne    f0101b99 <mem_init+0x594>
f0101b80:	68 5c 56 10 f0       	push   $0xf010565c
f0101b85:	68 9b 55 10 f0       	push   $0xf010559b
f0101b8a:	68 1f 03 00 00       	push   $0x31f
f0101b8f:	68 75 55 10 f0       	push   $0xf0105575
f0101b94:	e8 0c e5 ff ff       	call   f01000a5 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b99:	83 ec 0c             	sub    $0xc,%esp
f0101b9c:	6a 00                	push   $0x0
f0101b9e:	e8 8b f7 ff ff       	call   f010132e <page_alloc>
f0101ba3:	89 c3                	mov    %eax,%ebx
f0101ba5:	83 c4 10             	add    $0x10,%esp
f0101ba8:	85 c0                	test   %eax,%eax
f0101baa:	75 19                	jne    f0101bc5 <mem_init+0x5c0>
f0101bac:	68 72 56 10 f0       	push   $0xf0105672
f0101bb1:	68 9b 55 10 f0       	push   $0xf010559b
f0101bb6:	68 20 03 00 00       	push   $0x320
f0101bbb:	68 75 55 10 f0       	push   $0xf0105575
f0101bc0:	e8 e0 e4 ff ff       	call   f01000a5 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101bc5:	39 f7                	cmp    %esi,%edi
f0101bc7:	75 19                	jne    f0101be2 <mem_init+0x5dd>
f0101bc9:	68 88 56 10 f0       	push   $0xf0105688
f0101bce:	68 9b 55 10 f0       	push   $0xf010559b
f0101bd3:	68 23 03 00 00       	push   $0x323
f0101bd8:	68 75 55 10 f0       	push   $0xf0105575
f0101bdd:	e8 c3 e4 ff ff       	call   f01000a5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101be2:	39 c6                	cmp    %eax,%esi
f0101be4:	74 04                	je     f0101bea <mem_init+0x5e5>
f0101be6:	39 c7                	cmp    %eax,%edi
f0101be8:	75 19                	jne    f0101c03 <mem_init+0x5fe>
f0101bea:	68 58 4f 10 f0       	push   $0xf0104f58
f0101bef:	68 9b 55 10 f0       	push   $0xf010559b
f0101bf4:	68 24 03 00 00       	push   $0x324
f0101bf9:	68 75 55 10 f0       	push   $0xf0105575
f0101bfe:	e8 a2 e4 ff ff       	call   f01000a5 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c03:	a1 ac 62 1d f0       	mov    0xf01d62ac,%eax
f0101c08:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	page_free_list = 0;
f0101c0b:	c7 05 ac 62 1d f0 00 	movl   $0x0,0xf01d62ac
f0101c12:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c15:	83 ec 0c             	sub    $0xc,%esp
f0101c18:	6a 00                	push   $0x0
f0101c1a:	e8 0f f7 ff ff       	call   f010132e <page_alloc>
f0101c1f:	83 c4 10             	add    $0x10,%esp
f0101c22:	85 c0                	test   %eax,%eax
f0101c24:	74 19                	je     f0101c3f <mem_init+0x63a>
f0101c26:	68 f1 56 10 f0       	push   $0xf01056f1
f0101c2b:	68 9b 55 10 f0       	push   $0xf010559b
f0101c30:	68 2b 03 00 00       	push   $0x32b
f0101c35:	68 75 55 10 f0       	push   $0xf0105575
f0101c3a:	e8 66 e4 ff ff       	call   f01000a5 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c3f:	83 ec 04             	sub    $0x4,%esp
f0101c42:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c45:	50                   	push   %eax
f0101c46:	6a 00                	push   $0x0
f0101c48:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0101c4e:	e8 8b f8 ff ff       	call   f01014de <page_lookup>
f0101c53:	83 c4 10             	add    $0x10,%esp
f0101c56:	85 c0                	test   %eax,%eax
f0101c58:	74 19                	je     f0101c73 <mem_init+0x66e>
f0101c5a:	68 98 4f 10 f0       	push   $0xf0104f98
f0101c5f:	68 9b 55 10 f0       	push   $0xf010559b
f0101c64:	68 2e 03 00 00       	push   $0x32e
f0101c69:	68 75 55 10 f0       	push   $0xf0105575
f0101c6e:	e8 32 e4 ff ff       	call   f01000a5 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c73:	6a 02                	push   $0x2
f0101c75:	6a 00                	push   $0x0
f0101c77:	56                   	push   %esi
f0101c78:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0101c7e:	e8 19 f9 ff ff       	call   f010159c <page_insert>
f0101c83:	83 c4 10             	add    $0x10,%esp
f0101c86:	85 c0                	test   %eax,%eax
f0101c88:	78 19                	js     f0101ca3 <mem_init+0x69e>
f0101c8a:	68 d0 4f 10 f0       	push   $0xf0104fd0
f0101c8f:	68 9b 55 10 f0       	push   $0xf010559b
f0101c94:	68 31 03 00 00       	push   $0x331
f0101c99:	68 75 55 10 f0       	push   $0xf0105575
f0101c9e:	e8 02 e4 ff ff       	call   f01000a5 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101ca3:	83 ec 0c             	sub    $0xc,%esp
f0101ca6:	57                   	push   %edi
f0101ca7:	e8 0c f7 ff ff       	call   f01013b8 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101cac:	6a 02                	push   $0x2
f0101cae:	6a 00                	push   $0x0
f0101cb0:	56                   	push   %esi
f0101cb1:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0101cb7:	e8 e0 f8 ff ff       	call   f010159c <page_insert>
f0101cbc:	83 c4 20             	add    $0x20,%esp
f0101cbf:	85 c0                	test   %eax,%eax
f0101cc1:	74 19                	je     f0101cdc <mem_init+0x6d7>
f0101cc3:	68 00 50 10 f0       	push   $0xf0105000
f0101cc8:	68 9b 55 10 f0       	push   $0xf010559b
f0101ccd:	68 35 03 00 00       	push   $0x335
f0101cd2:	68 75 55 10 f0       	push   $0xf0105575
f0101cd7:	e8 c9 e3 ff ff       	call   f01000a5 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101cdc:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0101ce1:	8b 08                	mov    (%eax),%ecx
f0101ce3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ce9:	89 fa                	mov    %edi,%edx
f0101ceb:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0101cf1:	c1 fa 03             	sar    $0x3,%edx
f0101cf4:	c1 e2 0c             	shl    $0xc,%edx
f0101cf7:	39 d1                	cmp    %edx,%ecx
f0101cf9:	74 19                	je     f0101d14 <mem_init+0x70f>
f0101cfb:	68 30 50 10 f0       	push   $0xf0105030
f0101d00:	68 9b 55 10 f0       	push   $0xf010559b
f0101d05:	68 36 03 00 00       	push   $0x336
f0101d0a:	68 75 55 10 f0       	push   $0xf0105575
f0101d0f:	e8 91 e3 ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d14:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d19:	e8 21 f2 ff ff       	call   f0100f3f <check_va2pa>
f0101d1e:	89 f2                	mov    %esi,%edx
f0101d20:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0101d26:	c1 fa 03             	sar    $0x3,%edx
f0101d29:	c1 e2 0c             	shl    $0xc,%edx
f0101d2c:	39 d0                	cmp    %edx,%eax
f0101d2e:	74 19                	je     f0101d49 <mem_init+0x744>
f0101d30:	68 58 50 10 f0       	push   $0xf0105058
f0101d35:	68 9b 55 10 f0       	push   $0xf010559b
f0101d3a:	68 37 03 00 00       	push   $0x337
f0101d3f:	68 75 55 10 f0       	push   $0xf0105575
f0101d44:	e8 5c e3 ff ff       	call   f01000a5 <_panic>
	assert(pp1->pp_ref == 1);
f0101d49:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d4e:	74 19                	je     f0101d69 <mem_init+0x764>
f0101d50:	68 43 57 10 f0       	push   $0xf0105743
f0101d55:	68 9b 55 10 f0       	push   $0xf010559b
f0101d5a:	68 38 03 00 00       	push   $0x338
f0101d5f:	68 75 55 10 f0       	push   $0xf0105575
f0101d64:	e8 3c e3 ff ff       	call   f01000a5 <_panic>
	assert(pp0->pp_ref == 1);
f0101d69:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d6e:	74 19                	je     f0101d89 <mem_init+0x784>
f0101d70:	68 54 57 10 f0       	push   $0xf0105754
f0101d75:	68 9b 55 10 f0       	push   $0xf010559b
f0101d7a:	68 39 03 00 00       	push   $0x339
f0101d7f:	68 75 55 10 f0       	push   $0xf0105575
f0101d84:	e8 1c e3 ff ff       	call   f01000a5 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d89:	6a 02                	push   $0x2
f0101d8b:	68 00 10 00 00       	push   $0x1000
f0101d90:	53                   	push   %ebx
f0101d91:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0101d97:	e8 00 f8 ff ff       	call   f010159c <page_insert>
f0101d9c:	83 c4 10             	add    $0x10,%esp
f0101d9f:	85 c0                	test   %eax,%eax
f0101da1:	74 19                	je     f0101dbc <mem_init+0x7b7>
f0101da3:	68 88 50 10 f0       	push   $0xf0105088
f0101da8:	68 9b 55 10 f0       	push   $0xf010559b
f0101dad:	68 3c 03 00 00       	push   $0x33c
f0101db2:	68 75 55 10 f0       	push   $0xf0105575
f0101db7:	e8 e9 e2 ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dbc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dc1:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0101dc6:	e8 74 f1 ff ff       	call   f0100f3f <check_va2pa>
f0101dcb:	89 da                	mov    %ebx,%edx
f0101dcd:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0101dd3:	c1 fa 03             	sar    $0x3,%edx
f0101dd6:	c1 e2 0c             	shl    $0xc,%edx
f0101dd9:	39 d0                	cmp    %edx,%eax
f0101ddb:	74 19                	je     f0101df6 <mem_init+0x7f1>
f0101ddd:	68 c4 50 10 f0       	push   $0xf01050c4
f0101de2:	68 9b 55 10 f0       	push   $0xf010559b
f0101de7:	68 3d 03 00 00       	push   $0x33d
f0101dec:	68 75 55 10 f0       	push   $0xf0105575
f0101df1:	e8 af e2 ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 1);
f0101df6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101dfb:	74 19                	je     f0101e16 <mem_init+0x811>
f0101dfd:	68 65 57 10 f0       	push   $0xf0105765
f0101e02:	68 9b 55 10 f0       	push   $0xf010559b
f0101e07:	68 3e 03 00 00       	push   $0x33e
f0101e0c:	68 75 55 10 f0       	push   $0xf0105575
f0101e11:	e8 8f e2 ff ff       	call   f01000a5 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e16:	83 ec 0c             	sub    $0xc,%esp
f0101e19:	6a 00                	push   $0x0
f0101e1b:	e8 0e f5 ff ff       	call   f010132e <page_alloc>
f0101e20:	83 c4 10             	add    $0x10,%esp
f0101e23:	85 c0                	test   %eax,%eax
f0101e25:	74 19                	je     f0101e40 <mem_init+0x83b>
f0101e27:	68 f1 56 10 f0       	push   $0xf01056f1
f0101e2c:	68 9b 55 10 f0       	push   $0xf010559b
f0101e31:	68 41 03 00 00       	push   $0x341
f0101e36:	68 75 55 10 f0       	push   $0xf0105575
f0101e3b:	e8 65 e2 ff ff       	call   f01000a5 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e40:	6a 02                	push   $0x2
f0101e42:	68 00 10 00 00       	push   $0x1000
f0101e47:	53                   	push   %ebx
f0101e48:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0101e4e:	e8 49 f7 ff ff       	call   f010159c <page_insert>
f0101e53:	83 c4 10             	add    $0x10,%esp
f0101e56:	85 c0                	test   %eax,%eax
f0101e58:	74 19                	je     f0101e73 <mem_init+0x86e>
f0101e5a:	68 88 50 10 f0       	push   $0xf0105088
f0101e5f:	68 9b 55 10 f0       	push   $0xf010559b
f0101e64:	68 44 03 00 00       	push   $0x344
f0101e69:	68 75 55 10 f0       	push   $0xf0105575
f0101e6e:	e8 32 e2 ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e73:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e78:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0101e7d:	e8 bd f0 ff ff       	call   f0100f3f <check_va2pa>
f0101e82:	89 da                	mov    %ebx,%edx
f0101e84:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0101e8a:	c1 fa 03             	sar    $0x3,%edx
f0101e8d:	c1 e2 0c             	shl    $0xc,%edx
f0101e90:	39 d0                	cmp    %edx,%eax
f0101e92:	74 19                	je     f0101ead <mem_init+0x8a8>
f0101e94:	68 c4 50 10 f0       	push   $0xf01050c4
f0101e99:	68 9b 55 10 f0       	push   $0xf010559b
f0101e9e:	68 45 03 00 00       	push   $0x345
f0101ea3:	68 75 55 10 f0       	push   $0xf0105575
f0101ea8:	e8 f8 e1 ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 1);
f0101ead:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101eb2:	74 19                	je     f0101ecd <mem_init+0x8c8>
f0101eb4:	68 65 57 10 f0       	push   $0xf0105765
f0101eb9:	68 9b 55 10 f0       	push   $0xf010559b
f0101ebe:	68 46 03 00 00       	push   $0x346
f0101ec3:	68 75 55 10 f0       	push   $0xf0105575
f0101ec8:	e8 d8 e1 ff ff       	call   f01000a5 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ecd:	83 ec 0c             	sub    $0xc,%esp
f0101ed0:	6a 00                	push   $0x0
f0101ed2:	e8 57 f4 ff ff       	call   f010132e <page_alloc>
f0101ed7:	83 c4 10             	add    $0x10,%esp
f0101eda:	85 c0                	test   %eax,%eax
f0101edc:	74 19                	je     f0101ef7 <mem_init+0x8f2>
f0101ede:	68 f1 56 10 f0       	push   $0xf01056f1
f0101ee3:	68 9b 55 10 f0       	push   $0xf010559b
f0101ee8:	68 4a 03 00 00       	push   $0x34a
f0101eed:	68 75 55 10 f0       	push   $0xf0105575
f0101ef2:	e8 ae e1 ff ff       	call   f01000a5 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ef7:	8b 15 88 6f 1d f0    	mov    0xf01d6f88,%edx
f0101efd:	8b 02                	mov    (%edx),%eax
f0101eff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f04:	89 c1                	mov    %eax,%ecx
f0101f06:	c1 e9 0c             	shr    $0xc,%ecx
f0101f09:	3b 0d 84 6f 1d f0    	cmp    0xf01d6f84,%ecx
f0101f0f:	72 15                	jb     f0101f26 <mem_init+0x921>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f11:	50                   	push   %eax
f0101f12:	68 14 4e 10 f0       	push   $0xf0104e14
f0101f17:	68 4d 03 00 00       	push   $0x34d
f0101f1c:	68 75 55 10 f0       	push   $0xf0105575
f0101f21:	e8 7f e1 ff ff       	call   f01000a5 <_panic>
	return (void *)(pa + KERNBASE);
f0101f26:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f2e:	83 ec 04             	sub    $0x4,%esp
f0101f31:	6a 00                	push   $0x0
f0101f33:	68 00 10 00 00       	push   $0x1000
f0101f38:	52                   	push   %edx
f0101f39:	e8 b8 f4 ff ff       	call   f01013f6 <pgdir_walk>
f0101f3e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101f41:	83 c2 04             	add    $0x4,%edx
f0101f44:	83 c4 10             	add    $0x10,%esp
f0101f47:	39 d0                	cmp    %edx,%eax
f0101f49:	74 19                	je     f0101f64 <mem_init+0x95f>
f0101f4b:	68 f4 50 10 f0       	push   $0xf01050f4
f0101f50:	68 9b 55 10 f0       	push   $0xf010559b
f0101f55:	68 4e 03 00 00       	push   $0x34e
f0101f5a:	68 75 55 10 f0       	push   $0xf0105575
f0101f5f:	e8 41 e1 ff ff       	call   f01000a5 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f64:	6a 06                	push   $0x6
f0101f66:	68 00 10 00 00       	push   $0x1000
f0101f6b:	53                   	push   %ebx
f0101f6c:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0101f72:	e8 25 f6 ff ff       	call   f010159c <page_insert>
f0101f77:	83 c4 10             	add    $0x10,%esp
f0101f7a:	85 c0                	test   %eax,%eax
f0101f7c:	74 19                	je     f0101f97 <mem_init+0x992>
f0101f7e:	68 34 51 10 f0       	push   $0xf0105134
f0101f83:	68 9b 55 10 f0       	push   $0xf010559b
f0101f88:	68 51 03 00 00       	push   $0x351
f0101f8d:	68 75 55 10 f0       	push   $0xf0105575
f0101f92:	e8 0e e1 ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f97:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f9c:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0101fa1:	e8 99 ef ff ff       	call   f0100f3f <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fa6:	89 da                	mov    %ebx,%edx
f0101fa8:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0101fae:	c1 fa 03             	sar    $0x3,%edx
f0101fb1:	c1 e2 0c             	shl    $0xc,%edx
f0101fb4:	39 d0                	cmp    %edx,%eax
f0101fb6:	74 19                	je     f0101fd1 <mem_init+0x9cc>
f0101fb8:	68 c4 50 10 f0       	push   $0xf01050c4
f0101fbd:	68 9b 55 10 f0       	push   $0xf010559b
f0101fc2:	68 52 03 00 00       	push   $0x352
f0101fc7:	68 75 55 10 f0       	push   $0xf0105575
f0101fcc:	e8 d4 e0 ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 1);
f0101fd1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fd6:	74 19                	je     f0101ff1 <mem_init+0x9ec>
f0101fd8:	68 65 57 10 f0       	push   $0xf0105765
f0101fdd:	68 9b 55 10 f0       	push   $0xf010559b
f0101fe2:	68 53 03 00 00       	push   $0x353
f0101fe7:	68 75 55 10 f0       	push   $0xf0105575
f0101fec:	e8 b4 e0 ff ff       	call   f01000a5 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ff1:	83 ec 04             	sub    $0x4,%esp
f0101ff4:	6a 00                	push   $0x0
f0101ff6:	68 00 10 00 00       	push   $0x1000
f0101ffb:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0102001:	e8 f0 f3 ff ff       	call   f01013f6 <pgdir_walk>
f0102006:	83 c4 10             	add    $0x10,%esp
f0102009:	f6 00 04             	testb  $0x4,(%eax)
f010200c:	75 19                	jne    f0102027 <mem_init+0xa22>
f010200e:	68 74 51 10 f0       	push   $0xf0105174
f0102013:	68 9b 55 10 f0       	push   $0xf010559b
f0102018:	68 54 03 00 00       	push   $0x354
f010201d:	68 75 55 10 f0       	push   $0xf0105575
f0102022:	e8 7e e0 ff ff       	call   f01000a5 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102027:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f010202c:	f6 00 04             	testb  $0x4,(%eax)
f010202f:	75 19                	jne    f010204a <mem_init+0xa45>
f0102031:	68 76 57 10 f0       	push   $0xf0105776
f0102036:	68 9b 55 10 f0       	push   $0xf010559b
f010203b:	68 55 03 00 00       	push   $0x355
f0102040:	68 75 55 10 f0       	push   $0xf0105575
f0102045:	e8 5b e0 ff ff       	call   f01000a5 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010204a:	6a 02                	push   $0x2
f010204c:	68 00 10 00 00       	push   $0x1000
f0102051:	53                   	push   %ebx
f0102052:	50                   	push   %eax
f0102053:	e8 44 f5 ff ff       	call   f010159c <page_insert>
f0102058:	83 c4 10             	add    $0x10,%esp
f010205b:	85 c0                	test   %eax,%eax
f010205d:	74 19                	je     f0102078 <mem_init+0xa73>
f010205f:	68 88 50 10 f0       	push   $0xf0105088
f0102064:	68 9b 55 10 f0       	push   $0xf010559b
f0102069:	68 58 03 00 00       	push   $0x358
f010206e:	68 75 55 10 f0       	push   $0xf0105575
f0102073:	e8 2d e0 ff ff       	call   f01000a5 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102078:	83 ec 04             	sub    $0x4,%esp
f010207b:	6a 00                	push   $0x0
f010207d:	68 00 10 00 00       	push   $0x1000
f0102082:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0102088:	e8 69 f3 ff ff       	call   f01013f6 <pgdir_walk>
f010208d:	83 c4 10             	add    $0x10,%esp
f0102090:	f6 00 02             	testb  $0x2,(%eax)
f0102093:	75 19                	jne    f01020ae <mem_init+0xaa9>
f0102095:	68 a8 51 10 f0       	push   $0xf01051a8
f010209a:	68 9b 55 10 f0       	push   $0xf010559b
f010209f:	68 59 03 00 00       	push   $0x359
f01020a4:	68 75 55 10 f0       	push   $0xf0105575
f01020a9:	e8 f7 df ff ff       	call   f01000a5 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020ae:	83 ec 04             	sub    $0x4,%esp
f01020b1:	6a 00                	push   $0x0
f01020b3:	68 00 10 00 00       	push   $0x1000
f01020b8:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f01020be:	e8 33 f3 ff ff       	call   f01013f6 <pgdir_walk>
f01020c3:	83 c4 10             	add    $0x10,%esp
f01020c6:	f6 00 04             	testb  $0x4,(%eax)
f01020c9:	74 19                	je     f01020e4 <mem_init+0xadf>
f01020cb:	68 dc 51 10 f0       	push   $0xf01051dc
f01020d0:	68 9b 55 10 f0       	push   $0xf010559b
f01020d5:	68 5a 03 00 00       	push   $0x35a
f01020da:	68 75 55 10 f0       	push   $0xf0105575
f01020df:	e8 c1 df ff ff       	call   f01000a5 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020e4:	6a 02                	push   $0x2
f01020e6:	68 00 00 40 00       	push   $0x400000
f01020eb:	57                   	push   %edi
f01020ec:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f01020f2:	e8 a5 f4 ff ff       	call   f010159c <page_insert>
f01020f7:	83 c4 10             	add    $0x10,%esp
f01020fa:	85 c0                	test   %eax,%eax
f01020fc:	78 19                	js     f0102117 <mem_init+0xb12>
f01020fe:	68 14 52 10 f0       	push   $0xf0105214
f0102103:	68 9b 55 10 f0       	push   $0xf010559b
f0102108:	68 5d 03 00 00       	push   $0x35d
f010210d:	68 75 55 10 f0       	push   $0xf0105575
f0102112:	e8 8e df ff ff       	call   f01000a5 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102117:	6a 02                	push   $0x2
f0102119:	68 00 10 00 00       	push   $0x1000
f010211e:	56                   	push   %esi
f010211f:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0102125:	e8 72 f4 ff ff       	call   f010159c <page_insert>
f010212a:	83 c4 10             	add    $0x10,%esp
f010212d:	85 c0                	test   %eax,%eax
f010212f:	74 19                	je     f010214a <mem_init+0xb45>
f0102131:	68 4c 52 10 f0       	push   $0xf010524c
f0102136:	68 9b 55 10 f0       	push   $0xf010559b
f010213b:	68 60 03 00 00       	push   $0x360
f0102140:	68 75 55 10 f0       	push   $0xf0105575
f0102145:	e8 5b df ff ff       	call   f01000a5 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010214a:	83 ec 04             	sub    $0x4,%esp
f010214d:	6a 00                	push   $0x0
f010214f:	68 00 10 00 00       	push   $0x1000
f0102154:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f010215a:	e8 97 f2 ff ff       	call   f01013f6 <pgdir_walk>
f010215f:	83 c4 10             	add    $0x10,%esp
f0102162:	f6 00 04             	testb  $0x4,(%eax)
f0102165:	74 19                	je     f0102180 <mem_init+0xb7b>
f0102167:	68 dc 51 10 f0       	push   $0xf01051dc
f010216c:	68 9b 55 10 f0       	push   $0xf010559b
f0102171:	68 61 03 00 00       	push   $0x361
f0102176:	68 75 55 10 f0       	push   $0xf0105575
f010217b:	e8 25 df ff ff       	call   f01000a5 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102180:	ba 00 00 00 00       	mov    $0x0,%edx
f0102185:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f010218a:	e8 b0 ed ff ff       	call   f0100f3f <check_va2pa>
f010218f:	89 f2                	mov    %esi,%edx
f0102191:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0102197:	c1 fa 03             	sar    $0x3,%edx
f010219a:	c1 e2 0c             	shl    $0xc,%edx
f010219d:	39 d0                	cmp    %edx,%eax
f010219f:	74 19                	je     f01021ba <mem_init+0xbb5>
f01021a1:	68 88 52 10 f0       	push   $0xf0105288
f01021a6:	68 9b 55 10 f0       	push   $0xf010559b
f01021ab:	68 64 03 00 00       	push   $0x364
f01021b0:	68 75 55 10 f0       	push   $0xf0105575
f01021b5:	e8 eb de ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021ba:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021bf:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f01021c4:	e8 76 ed ff ff       	call   f0100f3f <check_va2pa>
f01021c9:	89 f2                	mov    %esi,%edx
f01021cb:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f01021d1:	c1 fa 03             	sar    $0x3,%edx
f01021d4:	c1 e2 0c             	shl    $0xc,%edx
f01021d7:	39 d0                	cmp    %edx,%eax
f01021d9:	74 19                	je     f01021f4 <mem_init+0xbef>
f01021db:	68 b4 52 10 f0       	push   $0xf01052b4
f01021e0:	68 9b 55 10 f0       	push   $0xf010559b
f01021e5:	68 65 03 00 00       	push   $0x365
f01021ea:	68 75 55 10 f0       	push   $0xf0105575
f01021ef:	e8 b1 de ff ff       	call   f01000a5 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01021f4:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f01021f9:	74 19                	je     f0102214 <mem_init+0xc0f>
f01021fb:	68 8c 57 10 f0       	push   $0xf010578c
f0102200:	68 9b 55 10 f0       	push   $0xf010559b
f0102205:	68 67 03 00 00       	push   $0x367
f010220a:	68 75 55 10 f0       	push   $0xf0105575
f010220f:	e8 91 de ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 0);
f0102214:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102219:	74 19                	je     f0102234 <mem_init+0xc2f>
f010221b:	68 9d 57 10 f0       	push   $0xf010579d
f0102220:	68 9b 55 10 f0       	push   $0xf010559b
f0102225:	68 68 03 00 00       	push   $0x368
f010222a:	68 75 55 10 f0       	push   $0xf0105575
f010222f:	e8 71 de ff ff       	call   f01000a5 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102234:	83 ec 0c             	sub    $0xc,%esp
f0102237:	6a 00                	push   $0x0
f0102239:	e8 f0 f0 ff ff       	call   f010132e <page_alloc>
f010223e:	83 c4 10             	add    $0x10,%esp
f0102241:	85 c0                	test   %eax,%eax
f0102243:	74 04                	je     f0102249 <mem_init+0xc44>
f0102245:	39 c3                	cmp    %eax,%ebx
f0102247:	74 19                	je     f0102262 <mem_init+0xc5d>
f0102249:	68 e4 52 10 f0       	push   $0xf01052e4
f010224e:	68 9b 55 10 f0       	push   $0xf010559b
f0102253:	68 6b 03 00 00       	push   $0x36b
f0102258:	68 75 55 10 f0       	push   $0xf0105575
f010225d:	e8 43 de ff ff       	call   f01000a5 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102262:	83 ec 08             	sub    $0x8,%esp
f0102265:	6a 00                	push   $0x0
f0102267:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f010226d:	e8 dd f2 ff ff       	call   f010154f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102272:	ba 00 00 00 00       	mov    $0x0,%edx
f0102277:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f010227c:	e8 be ec ff ff       	call   f0100f3f <check_va2pa>
f0102281:	83 c4 10             	add    $0x10,%esp
f0102284:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102287:	74 19                	je     f01022a2 <mem_init+0xc9d>
f0102289:	68 08 53 10 f0       	push   $0xf0105308
f010228e:	68 9b 55 10 f0       	push   $0xf010559b
f0102293:	68 6f 03 00 00       	push   $0x36f
f0102298:	68 75 55 10 f0       	push   $0xf0105575
f010229d:	e8 03 de ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022a2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022a7:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f01022ac:	e8 8e ec ff ff       	call   f0100f3f <check_va2pa>
f01022b1:	89 f2                	mov    %esi,%edx
f01022b3:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f01022b9:	c1 fa 03             	sar    $0x3,%edx
f01022bc:	c1 e2 0c             	shl    $0xc,%edx
f01022bf:	39 d0                	cmp    %edx,%eax
f01022c1:	74 19                	je     f01022dc <mem_init+0xcd7>
f01022c3:	68 b4 52 10 f0       	push   $0xf01052b4
f01022c8:	68 9b 55 10 f0       	push   $0xf010559b
f01022cd:	68 70 03 00 00       	push   $0x370
f01022d2:	68 75 55 10 f0       	push   $0xf0105575
f01022d7:	e8 c9 dd ff ff       	call   f01000a5 <_panic>
	assert(pp1->pp_ref == 1);
f01022dc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022e1:	74 19                	je     f01022fc <mem_init+0xcf7>
f01022e3:	68 43 57 10 f0       	push   $0xf0105743
f01022e8:	68 9b 55 10 f0       	push   $0xf010559b
f01022ed:	68 71 03 00 00       	push   $0x371
f01022f2:	68 75 55 10 f0       	push   $0xf0105575
f01022f7:	e8 a9 dd ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 0);
f01022fc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102301:	74 19                	je     f010231c <mem_init+0xd17>
f0102303:	68 9d 57 10 f0       	push   $0xf010579d
f0102308:	68 9b 55 10 f0       	push   $0xf010559b
f010230d:	68 72 03 00 00       	push   $0x372
f0102312:	68 75 55 10 f0       	push   $0xf0105575
f0102317:	e8 89 dd ff ff       	call   f01000a5 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010231c:	83 ec 08             	sub    $0x8,%esp
f010231f:	68 00 10 00 00       	push   $0x1000
f0102324:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f010232a:	e8 20 f2 ff ff       	call   f010154f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010232f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102334:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0102339:	e8 01 ec ff ff       	call   f0100f3f <check_va2pa>
f010233e:	83 c4 10             	add    $0x10,%esp
f0102341:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102344:	74 19                	je     f010235f <mem_init+0xd5a>
f0102346:	68 08 53 10 f0       	push   $0xf0105308
f010234b:	68 9b 55 10 f0       	push   $0xf010559b
f0102350:	68 76 03 00 00       	push   $0x376
f0102355:	68 75 55 10 f0       	push   $0xf0105575
f010235a:	e8 46 dd ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010235f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102364:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0102369:	e8 d1 eb ff ff       	call   f0100f3f <check_va2pa>
f010236e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102371:	74 19                	je     f010238c <mem_init+0xd87>
f0102373:	68 2c 53 10 f0       	push   $0xf010532c
f0102378:	68 9b 55 10 f0       	push   $0xf010559b
f010237d:	68 77 03 00 00       	push   $0x377
f0102382:	68 75 55 10 f0       	push   $0xf0105575
f0102387:	e8 19 dd ff ff       	call   f01000a5 <_panic>
	assert(pp1->pp_ref == 0);
f010238c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102391:	74 19                	je     f01023ac <mem_init+0xda7>
f0102393:	68 ae 57 10 f0       	push   $0xf01057ae
f0102398:	68 9b 55 10 f0       	push   $0xf010559b
f010239d:	68 78 03 00 00       	push   $0x378
f01023a2:	68 75 55 10 f0       	push   $0xf0105575
f01023a7:	e8 f9 dc ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 0);
f01023ac:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023b1:	74 19                	je     f01023cc <mem_init+0xdc7>
f01023b3:	68 9d 57 10 f0       	push   $0xf010579d
f01023b8:	68 9b 55 10 f0       	push   $0xf010559b
f01023bd:	68 79 03 00 00       	push   $0x379
f01023c2:	68 75 55 10 f0       	push   $0xf0105575
f01023c7:	e8 d9 dc ff ff       	call   f01000a5 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01023cc:	83 ec 0c             	sub    $0xc,%esp
f01023cf:	6a 00                	push   $0x0
f01023d1:	e8 58 ef ff ff       	call   f010132e <page_alloc>
f01023d6:	83 c4 10             	add    $0x10,%esp
f01023d9:	85 c0                	test   %eax,%eax
f01023db:	74 04                	je     f01023e1 <mem_init+0xddc>
f01023dd:	39 c6                	cmp    %eax,%esi
f01023df:	74 19                	je     f01023fa <mem_init+0xdf5>
f01023e1:	68 54 53 10 f0       	push   $0xf0105354
f01023e6:	68 9b 55 10 f0       	push   $0xf010559b
f01023eb:	68 7c 03 00 00       	push   $0x37c
f01023f0:	68 75 55 10 f0       	push   $0xf0105575
f01023f5:	e8 ab dc ff ff       	call   f01000a5 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01023fa:	83 ec 0c             	sub    $0xc,%esp
f01023fd:	6a 00                	push   $0x0
f01023ff:	e8 2a ef ff ff       	call   f010132e <page_alloc>
f0102404:	83 c4 10             	add    $0x10,%esp
f0102407:	85 c0                	test   %eax,%eax
f0102409:	74 19                	je     f0102424 <mem_init+0xe1f>
f010240b:	68 f1 56 10 f0       	push   $0xf01056f1
f0102410:	68 9b 55 10 f0       	push   $0xf010559b
f0102415:	68 7f 03 00 00       	push   $0x37f
f010241a:	68 75 55 10 f0       	push   $0xf0105575
f010241f:	e8 81 dc ff ff       	call   f01000a5 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102424:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0102429:	8b 08                	mov    (%eax),%ecx
f010242b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102431:	89 fa                	mov    %edi,%edx
f0102433:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0102439:	c1 fa 03             	sar    $0x3,%edx
f010243c:	c1 e2 0c             	shl    $0xc,%edx
f010243f:	39 d1                	cmp    %edx,%ecx
f0102441:	74 19                	je     f010245c <mem_init+0xe57>
f0102443:	68 30 50 10 f0       	push   $0xf0105030
f0102448:	68 9b 55 10 f0       	push   $0xf010559b
f010244d:	68 82 03 00 00       	push   $0x382
f0102452:	68 75 55 10 f0       	push   $0xf0105575
f0102457:	e8 49 dc ff ff       	call   f01000a5 <_panic>
	kern_pgdir[0] = 0;
f010245c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102462:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102467:	74 19                	je     f0102482 <mem_init+0xe7d>
f0102469:	68 54 57 10 f0       	push   $0xf0105754
f010246e:	68 9b 55 10 f0       	push   $0xf010559b
f0102473:	68 84 03 00 00       	push   $0x384
f0102478:	68 75 55 10 f0       	push   $0xf0105575
f010247d:	e8 23 dc ff ff       	call   f01000a5 <_panic>
	pp0->pp_ref = 0;

	kern_pgdir[PDX(va)] = 0;
f0102482:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0102487:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010248d:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
f0102493:	89 f8                	mov    %edi,%eax
f0102495:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f010249b:	c1 f8 03             	sar    $0x3,%eax
f010249e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024a1:	89 c2                	mov    %eax,%edx
f01024a3:	c1 ea 0c             	shr    $0xc,%edx
f01024a6:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f01024ac:	72 12                	jb     f01024c0 <mem_init+0xebb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024ae:	50                   	push   %eax
f01024af:	68 14 4e 10 f0       	push   $0xf0104e14
f01024b4:	6a 56                	push   $0x56
f01024b6:	68 81 55 10 f0       	push   $0xf0105581
f01024bb:	e8 e5 db ff ff       	call   f01000a5 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01024c0:	83 ec 04             	sub    $0x4,%esp
f01024c3:	68 00 10 00 00       	push   $0x1000
f01024c8:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01024cd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024d2:	50                   	push   %eax
f01024d3:	e8 05 1b 00 00       	call   f0103fdd <memset>
	page_free(pp0);
f01024d8:	89 3c 24             	mov    %edi,(%esp)
f01024db:	e8 d8 ee ff ff       	call   f01013b8 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01024e0:	83 c4 0c             	add    $0xc,%esp
f01024e3:	6a 01                	push   $0x1
f01024e5:	6a 00                	push   $0x0
f01024e7:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f01024ed:	e8 04 ef ff ff       	call   f01013f6 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024f2:	89 fa                	mov    %edi,%edx
f01024f4:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f01024fa:	c1 fa 03             	sar    $0x3,%edx
f01024fd:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102500:	89 d0                	mov    %edx,%eax
f0102502:	c1 e8 0c             	shr    $0xc,%eax
f0102505:	83 c4 10             	add    $0x10,%esp
f0102508:	3b 05 84 6f 1d f0    	cmp    0xf01d6f84,%eax
f010250e:	72 12                	jb     f0102522 <mem_init+0xf1d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102510:	52                   	push   %edx
f0102511:	68 14 4e 10 f0       	push   $0xf0104e14
f0102516:	6a 56                	push   $0x56
f0102518:	68 81 55 10 f0       	push   $0xf0105581
f010251d:	e8 83 db ff ff       	call   f01000a5 <_panic>
	return (void *)(pa + KERNBASE);
f0102522:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102528:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010252b:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102532:	75 11                	jne    f0102545 <mem_init+0xf40>
f0102534:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010253a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102540:	f6 00 01             	testb  $0x1,(%eax)
f0102543:	74 19                	je     f010255e <mem_init+0xf59>
f0102545:	68 bf 57 10 f0       	push   $0xf01057bf
f010254a:	68 9b 55 10 f0       	push   $0xf010559b
f010254f:	68 90 03 00 00       	push   $0x390
f0102554:	68 75 55 10 f0       	push   $0xf0105575
f0102559:	e8 47 db ff ff       	call   f01000a5 <_panic>
f010255e:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102561:	39 d0                	cmp    %edx,%eax
f0102563:	75 db                	jne    f0102540 <mem_init+0xf3b>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102565:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f010256a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102570:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102576:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102579:	89 0d ac 62 1d f0    	mov    %ecx,0xf01d62ac

	// free the pages we took
	page_free(pp0);
f010257f:	83 ec 0c             	sub    $0xc,%esp
f0102582:	57                   	push   %edi
f0102583:	e8 30 ee ff ff       	call   f01013b8 <page_free>
	page_free(pp1);
f0102588:	89 34 24             	mov    %esi,(%esp)
f010258b:	e8 28 ee ff ff       	call   f01013b8 <page_free>
	page_free(pp2);
f0102590:	89 1c 24             	mov    %ebx,(%esp)
f0102593:	e8 20 ee ff ff       	call   f01013b8 <page_free>

	cprintf("check_page() succeeded!\n");
f0102598:	c7 04 24 d6 57 10 f0 	movl   $0xf01057d6,(%esp)
f010259f:	e8 69 0b 00 00       	call   f010310d <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01025a4:	a1 8c 6f 1d f0       	mov    0xf01d6f8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025a9:	83 c4 10             	add    $0x10,%esp
f01025ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025b1:	77 15                	ja     f01025c8 <mem_init+0xfc3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025b3:	50                   	push   %eax
f01025b4:	68 54 4c 10 f0       	push   $0xf0104c54
f01025b9:	68 b7 00 00 00       	push   $0xb7
f01025be:	68 75 55 10 f0       	push   $0xf0105575
f01025c3:	e8 dd da ff ff       	call   f01000a5 <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f01025c8:	8b 15 84 6f 1d f0    	mov    0xf01d6f84,%edx
f01025ce:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01025d5:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f01025d8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01025de:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01025e0:	05 00 00 00 10       	add    $0x10000000,%eax
f01025e5:	50                   	push   %eax
f01025e6:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025eb:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f01025f0:	e8 98 ee ff ff       	call   f010148d <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
    boot_map_region(kern_pgdir,
f01025f5:	a1 b8 62 1d f0       	mov    0xf01d62b8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025fa:	83 c4 10             	add    $0x10,%esp
f01025fd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102602:	77 15                	ja     f0102619 <mem_init+0x1014>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102604:	50                   	push   %eax
f0102605:	68 54 4c 10 f0       	push   $0xf0104c54
f010260a:	68 c4 00 00 00       	push   $0xc4
f010260f:	68 75 55 10 f0       	push   $0xf0105575
f0102614:	e8 8c da ff ff       	call   f01000a5 <_panic>
f0102619:	83 ec 08             	sub    $0x8,%esp
f010261c:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f010261e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102623:	50                   	push   %eax
f0102624:	b9 00 20 00 00       	mov    $0x2000,%ecx
f0102629:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010262e:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0102633:	e8 55 ee ff ff       	call   f010148d <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102638:	83 c4 10             	add    $0x10,%esp
f010263b:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102640:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102645:	77 15                	ja     f010265c <mem_init+0x1057>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102647:	50                   	push   %eax
f0102648:	68 54 4c 10 f0       	push   $0xf0104c54
f010264d:	68 d5 00 00 00       	push   $0xd5
f0102652:	68 75 55 10 f0       	push   $0xf0105575
f0102657:	e8 49 da ff ff       	call   f01000a5 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f010265c:	83 ec 08             	sub    $0x8,%esp
f010265f:	6a 02                	push   $0x2
f0102661:	68 00 70 11 00       	push   $0x117000
f0102666:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010266b:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102670:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0102675:	e8 13 ee ff ff       	call   f010148d <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f010267a:	83 c4 08             	add    $0x8,%esp
f010267d:	6a 02                	push   $0x2
f010267f:	6a 00                	push   $0x0
f0102681:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102686:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010268b:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0102690:	e8 f8 ed ff ff       	call   f010148d <boot_map_region>
                    -KERNBASE,
                    0,
                    PTE_W);     
    // in 32-bit system, 2^32 - KERNBASE = - KERNBASE
   
    cprintf("!!!\n");
f0102695:	c7 04 24 ef 57 10 f0 	movl   $0xf01057ef,(%esp)
f010269c:	e8 6c 0a 00 00       	call   f010310d <cprintf>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026a1:	8b 1d 88 6f 1d f0    	mov    0xf01d6f88,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026a7:	a1 84 6f 1d f0       	mov    0xf01d6f84,%eax
f01026ac:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f01026b3:	83 c4 10             	add    $0x10,%esp
f01026b6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01026bc:	74 63                	je     f0102721 <mem_init+0x111c>
f01026be:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026c3:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01026c9:	89 d8                	mov    %ebx,%eax
f01026cb:	e8 6f e8 ff ff       	call   f0100f3f <check_va2pa>
f01026d0:	8b 15 8c 6f 1d f0    	mov    0xf01d6f8c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026d6:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01026dc:	77 15                	ja     f01026f3 <mem_init+0x10ee>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026de:	52                   	push   %edx
f01026df:	68 54 4c 10 f0       	push   $0xf0104c54
f01026e4:	68 d8 02 00 00       	push   $0x2d8
f01026e9:	68 75 55 10 f0       	push   $0xf0105575
f01026ee:	e8 b2 d9 ff ff       	call   f01000a5 <_panic>
f01026f3:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01026fa:	39 d0                	cmp    %edx,%eax
f01026fc:	74 19                	je     f0102717 <mem_init+0x1112>
f01026fe:	68 78 53 10 f0       	push   $0xf0105378
f0102703:	68 9b 55 10 f0       	push   $0xf010559b
f0102708:	68 d8 02 00 00       	push   $0x2d8
f010270d:	68 75 55 10 f0       	push   $0xf0105575
f0102712:	e8 8e d9 ff ff       	call   f01000a5 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102717:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010271d:	39 f7                	cmp    %esi,%edi
f010271f:	77 a2                	ja     f01026c3 <mem_init+0x10be>
f0102721:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102726:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f010272c:	89 d8                	mov    %ebx,%eax
f010272e:	e8 0c e8 ff ff       	call   f0100f3f <check_va2pa>
f0102733:	8b 15 b8 62 1d f0    	mov    0xf01d62b8,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102739:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010273f:	77 15                	ja     f0102756 <mem_init+0x1151>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102741:	52                   	push   %edx
f0102742:	68 54 4c 10 f0       	push   $0xf0104c54
f0102747:	68 dd 02 00 00       	push   $0x2dd
f010274c:	68 75 55 10 f0       	push   $0xf0105575
f0102751:	e8 4f d9 ff ff       	call   f01000a5 <_panic>
f0102756:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010275d:	39 d0                	cmp    %edx,%eax
f010275f:	74 19                	je     f010277a <mem_init+0x1175>
f0102761:	68 ac 53 10 f0       	push   $0xf01053ac
f0102766:	68 9b 55 10 f0       	push   $0xf010559b
f010276b:	68 dd 02 00 00       	push   $0x2dd
f0102770:	68 75 55 10 f0       	push   $0xf0105575
f0102775:	e8 2b d9 ff ff       	call   f01000a5 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010277a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102780:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f0102786:	75 9e                	jne    f0102726 <mem_init+0x1121>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102788:	a1 84 6f 1d f0       	mov    0xf01d6f84,%eax
f010278d:	c1 e0 0c             	shl    $0xc,%eax
f0102790:	74 41                	je     f01027d3 <mem_init+0x11ce>
f0102792:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102797:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f010279d:	89 d8                	mov    %ebx,%eax
f010279f:	e8 9b e7 ff ff       	call   f0100f3f <check_va2pa>
f01027a4:	39 c6                	cmp    %eax,%esi
f01027a6:	74 19                	je     f01027c1 <mem_init+0x11bc>
f01027a8:	68 e0 53 10 f0       	push   $0xf01053e0
f01027ad:	68 9b 55 10 f0       	push   $0xf010559b
f01027b2:	68 e1 02 00 00       	push   $0x2e1
f01027b7:	68 75 55 10 f0       	push   $0xf0105575
f01027bc:	e8 e4 d8 ff ff       	call   f01000a5 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027c1:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027c7:	a1 84 6f 1d f0       	mov    0xf01d6f84,%eax
f01027cc:	c1 e0 0c             	shl    $0xc,%eax
f01027cf:	39 c6                	cmp    %eax,%esi
f01027d1:	72 c4                	jb     f0102797 <mem_init+0x1192>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01027d3:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01027d8:	89 d8                	mov    %ebx,%eax
f01027da:	e8 60 e7 ff ff       	call   f0100f3f <check_va2pa>
f01027df:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01027e4:	bf 00 70 11 f0       	mov    $0xf0117000,%edi
f01027e9:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01027ef:	8d 14 37             	lea    (%edi,%esi,1),%edx
f01027f2:	39 c2                	cmp    %eax,%edx
f01027f4:	74 19                	je     f010280f <mem_init+0x120a>
f01027f6:	68 08 54 10 f0       	push   $0xf0105408
f01027fb:	68 9b 55 10 f0       	push   $0xf010559b
f0102800:	68 e5 02 00 00       	push   $0x2e5
f0102805:	68 75 55 10 f0       	push   $0xf0105575
f010280a:	e8 96 d8 ff ff       	call   f01000a5 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010280f:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102815:	0f 85 25 04 00 00    	jne    f0102c40 <mem_init+0x163b>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010281b:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102820:	89 d8                	mov    %ebx,%eax
f0102822:	e8 18 e7 ff ff       	call   f0100f3f <check_va2pa>
f0102827:	83 f8 ff             	cmp    $0xffffffff,%eax
f010282a:	74 19                	je     f0102845 <mem_init+0x1240>
f010282c:	68 50 54 10 f0       	push   $0xf0105450
f0102831:	68 9b 55 10 f0       	push   $0xf010559b
f0102836:	68 e6 02 00 00       	push   $0x2e6
f010283b:	68 75 55 10 f0       	push   $0xf0105575
f0102840:	e8 60 d8 ff ff       	call   f01000a5 <_panic>
f0102845:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010284a:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010284f:	72 2d                	jb     f010287e <mem_init+0x1279>
f0102851:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102856:	76 07                	jbe    f010285f <mem_init+0x125a>
f0102858:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010285d:	75 1f                	jne    f010287e <mem_init+0x1279>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010285f:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102863:	75 7e                	jne    f01028e3 <mem_init+0x12de>
f0102865:	68 f4 57 10 f0       	push   $0xf01057f4
f010286a:	68 9b 55 10 f0       	push   $0xf010559b
f010286f:	68 ef 02 00 00       	push   $0x2ef
f0102874:	68 75 55 10 f0       	push   $0xf0105575
f0102879:	e8 27 d8 ff ff       	call   f01000a5 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010287e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102883:	76 3f                	jbe    f01028c4 <mem_init+0x12bf>
				assert(pgdir[i] & PTE_P);
f0102885:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102888:	f6 c2 01             	test   $0x1,%dl
f010288b:	75 19                	jne    f01028a6 <mem_init+0x12a1>
f010288d:	68 f4 57 10 f0       	push   $0xf01057f4
f0102892:	68 9b 55 10 f0       	push   $0xf010559b
f0102897:	68 f3 02 00 00       	push   $0x2f3
f010289c:	68 75 55 10 f0       	push   $0xf0105575
f01028a1:	e8 ff d7 ff ff       	call   f01000a5 <_panic>
				assert(pgdir[i] & PTE_W);
f01028a6:	f6 c2 02             	test   $0x2,%dl
f01028a9:	75 38                	jne    f01028e3 <mem_init+0x12de>
f01028ab:	68 05 58 10 f0       	push   $0xf0105805
f01028b0:	68 9b 55 10 f0       	push   $0xf010559b
f01028b5:	68 f4 02 00 00       	push   $0x2f4
f01028ba:	68 75 55 10 f0       	push   $0xf0105575
f01028bf:	e8 e1 d7 ff ff       	call   f01000a5 <_panic>
			} else
				assert(pgdir[i] == 0);
f01028c4:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01028c8:	74 19                	je     f01028e3 <mem_init+0x12de>
f01028ca:	68 16 58 10 f0       	push   $0xf0105816
f01028cf:	68 9b 55 10 f0       	push   $0xf010559b
f01028d4:	68 f6 02 00 00       	push   $0x2f6
f01028d9:	68 75 55 10 f0       	push   $0xf0105575
f01028de:	e8 c2 d7 ff ff       	call   f01000a5 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01028e3:	40                   	inc    %eax
f01028e4:	3d 00 04 00 00       	cmp    $0x400,%eax
f01028e9:	0f 85 5b ff ff ff    	jne    f010284a <mem_init+0x1245>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01028ef:	83 ec 0c             	sub    $0xc,%esp
f01028f2:	68 80 54 10 f0       	push   $0xf0105480
f01028f7:	e8 11 08 00 00       	call   f010310d <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01028fc:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102901:	83 c4 10             	add    $0x10,%esp
f0102904:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102909:	77 15                	ja     f0102920 <mem_init+0x131b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010290b:	50                   	push   %eax
f010290c:	68 54 4c 10 f0       	push   $0xf0104c54
f0102911:	68 f2 00 00 00       	push   $0xf2
f0102916:	68 75 55 10 f0       	push   $0xf0105575
f010291b:	e8 85 d7 ff ff       	call   f01000a5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102920:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102925:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102928:	b8 00 00 00 00       	mov    $0x0,%eax
f010292d:	e8 96 e6 ff ff       	call   f0100fc8 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102932:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102935:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010293a:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010293d:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102940:	83 ec 0c             	sub    $0xc,%esp
f0102943:	6a 00                	push   $0x0
f0102945:	e8 e4 e9 ff ff       	call   f010132e <page_alloc>
f010294a:	89 c6                	mov    %eax,%esi
f010294c:	83 c4 10             	add    $0x10,%esp
f010294f:	85 c0                	test   %eax,%eax
f0102951:	75 19                	jne    f010296c <mem_init+0x1367>
f0102953:	68 46 56 10 f0       	push   $0xf0105646
f0102958:	68 9b 55 10 f0       	push   $0xf010559b
f010295d:	68 ab 03 00 00       	push   $0x3ab
f0102962:	68 75 55 10 f0       	push   $0xf0105575
f0102967:	e8 39 d7 ff ff       	call   f01000a5 <_panic>
	assert((pp1 = page_alloc(0)));
f010296c:	83 ec 0c             	sub    $0xc,%esp
f010296f:	6a 00                	push   $0x0
f0102971:	e8 b8 e9 ff ff       	call   f010132e <page_alloc>
f0102976:	89 c7                	mov    %eax,%edi
f0102978:	83 c4 10             	add    $0x10,%esp
f010297b:	85 c0                	test   %eax,%eax
f010297d:	75 19                	jne    f0102998 <mem_init+0x1393>
f010297f:	68 5c 56 10 f0       	push   $0xf010565c
f0102984:	68 9b 55 10 f0       	push   $0xf010559b
f0102989:	68 ac 03 00 00       	push   $0x3ac
f010298e:	68 75 55 10 f0       	push   $0xf0105575
f0102993:	e8 0d d7 ff ff       	call   f01000a5 <_panic>
	assert((pp2 = page_alloc(0)));
f0102998:	83 ec 0c             	sub    $0xc,%esp
f010299b:	6a 00                	push   $0x0
f010299d:	e8 8c e9 ff ff       	call   f010132e <page_alloc>
f01029a2:	89 c3                	mov    %eax,%ebx
f01029a4:	83 c4 10             	add    $0x10,%esp
f01029a7:	85 c0                	test   %eax,%eax
f01029a9:	75 19                	jne    f01029c4 <mem_init+0x13bf>
f01029ab:	68 72 56 10 f0       	push   $0xf0105672
f01029b0:	68 9b 55 10 f0       	push   $0xf010559b
f01029b5:	68 ad 03 00 00       	push   $0x3ad
f01029ba:	68 75 55 10 f0       	push   $0xf0105575
f01029bf:	e8 e1 d6 ff ff       	call   f01000a5 <_panic>
	page_free(pp0);
f01029c4:	83 ec 0c             	sub    $0xc,%esp
f01029c7:	56                   	push   %esi
f01029c8:	e8 eb e9 ff ff       	call   f01013b8 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029cd:	89 f8                	mov    %edi,%eax
f01029cf:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f01029d5:	c1 f8 03             	sar    $0x3,%eax
f01029d8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029db:	89 c2                	mov    %eax,%edx
f01029dd:	c1 ea 0c             	shr    $0xc,%edx
f01029e0:	83 c4 10             	add    $0x10,%esp
f01029e3:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f01029e9:	72 12                	jb     f01029fd <mem_init+0x13f8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029eb:	50                   	push   %eax
f01029ec:	68 14 4e 10 f0       	push   $0xf0104e14
f01029f1:	6a 56                	push   $0x56
f01029f3:	68 81 55 10 f0       	push   $0xf0105581
f01029f8:	e8 a8 d6 ff ff       	call   f01000a5 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01029fd:	83 ec 04             	sub    $0x4,%esp
f0102a00:	68 00 10 00 00       	push   $0x1000
f0102a05:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102a07:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a0c:	50                   	push   %eax
f0102a0d:	e8 cb 15 00 00       	call   f0103fdd <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a12:	89 d8                	mov    %ebx,%eax
f0102a14:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f0102a1a:	c1 f8 03             	sar    $0x3,%eax
f0102a1d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a20:	89 c2                	mov    %eax,%edx
f0102a22:	c1 ea 0c             	shr    $0xc,%edx
f0102a25:	83 c4 10             	add    $0x10,%esp
f0102a28:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f0102a2e:	72 12                	jb     f0102a42 <mem_init+0x143d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a30:	50                   	push   %eax
f0102a31:	68 14 4e 10 f0       	push   $0xf0104e14
f0102a36:	6a 56                	push   $0x56
f0102a38:	68 81 55 10 f0       	push   $0xf0105581
f0102a3d:	e8 63 d6 ff ff       	call   f01000a5 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102a42:	83 ec 04             	sub    $0x4,%esp
f0102a45:	68 00 10 00 00       	push   $0x1000
f0102a4a:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102a4c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a51:	50                   	push   %eax
f0102a52:	e8 86 15 00 00       	call   f0103fdd <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102a57:	6a 02                	push   $0x2
f0102a59:	68 00 10 00 00       	push   $0x1000
f0102a5e:	57                   	push   %edi
f0102a5f:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0102a65:	e8 32 eb ff ff       	call   f010159c <page_insert>
	assert(pp1->pp_ref == 1);
f0102a6a:	83 c4 20             	add    $0x20,%esp
f0102a6d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102a72:	74 19                	je     f0102a8d <mem_init+0x1488>
f0102a74:	68 43 57 10 f0       	push   $0xf0105743
f0102a79:	68 9b 55 10 f0       	push   $0xf010559b
f0102a7e:	68 b2 03 00 00       	push   $0x3b2
f0102a83:	68 75 55 10 f0       	push   $0xf0105575
f0102a88:	e8 18 d6 ff ff       	call   f01000a5 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102a8d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102a94:	01 01 01 
f0102a97:	74 19                	je     f0102ab2 <mem_init+0x14ad>
f0102a99:	68 a0 54 10 f0       	push   $0xf01054a0
f0102a9e:	68 9b 55 10 f0       	push   $0xf010559b
f0102aa3:	68 b3 03 00 00       	push   $0x3b3
f0102aa8:	68 75 55 10 f0       	push   $0xf0105575
f0102aad:	e8 f3 d5 ff ff       	call   f01000a5 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ab2:	6a 02                	push   $0x2
f0102ab4:	68 00 10 00 00       	push   $0x1000
f0102ab9:	53                   	push   %ebx
f0102aba:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0102ac0:	e8 d7 ea ff ff       	call   f010159c <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ac5:	83 c4 10             	add    $0x10,%esp
f0102ac8:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102acf:	02 02 02 
f0102ad2:	74 19                	je     f0102aed <mem_init+0x14e8>
f0102ad4:	68 c4 54 10 f0       	push   $0xf01054c4
f0102ad9:	68 9b 55 10 f0       	push   $0xf010559b
f0102ade:	68 b5 03 00 00       	push   $0x3b5
f0102ae3:	68 75 55 10 f0       	push   $0xf0105575
f0102ae8:	e8 b8 d5 ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 1);
f0102aed:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102af2:	74 19                	je     f0102b0d <mem_init+0x1508>
f0102af4:	68 65 57 10 f0       	push   $0xf0105765
f0102af9:	68 9b 55 10 f0       	push   $0xf010559b
f0102afe:	68 b6 03 00 00       	push   $0x3b6
f0102b03:	68 75 55 10 f0       	push   $0xf0105575
f0102b08:	e8 98 d5 ff ff       	call   f01000a5 <_panic>
	assert(pp1->pp_ref == 0);
f0102b0d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102b12:	74 19                	je     f0102b2d <mem_init+0x1528>
f0102b14:	68 ae 57 10 f0       	push   $0xf01057ae
f0102b19:	68 9b 55 10 f0       	push   $0xf010559b
f0102b1e:	68 b7 03 00 00       	push   $0x3b7
f0102b23:	68 75 55 10 f0       	push   $0xf0105575
f0102b28:	e8 78 d5 ff ff       	call   f01000a5 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102b2d:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102b34:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b37:	89 d8                	mov    %ebx,%eax
f0102b39:	2b 05 8c 6f 1d f0    	sub    0xf01d6f8c,%eax
f0102b3f:	c1 f8 03             	sar    $0x3,%eax
f0102b42:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b45:	89 c2                	mov    %eax,%edx
f0102b47:	c1 ea 0c             	shr    $0xc,%edx
f0102b4a:	3b 15 84 6f 1d f0    	cmp    0xf01d6f84,%edx
f0102b50:	72 12                	jb     f0102b64 <mem_init+0x155f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b52:	50                   	push   %eax
f0102b53:	68 14 4e 10 f0       	push   $0xf0104e14
f0102b58:	6a 56                	push   $0x56
f0102b5a:	68 81 55 10 f0       	push   $0xf0105581
f0102b5f:	e8 41 d5 ff ff       	call   f01000a5 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102b64:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102b6b:	03 03 03 
f0102b6e:	74 19                	je     f0102b89 <mem_init+0x1584>
f0102b70:	68 e8 54 10 f0       	push   $0xf01054e8
f0102b75:	68 9b 55 10 f0       	push   $0xf010559b
f0102b7a:	68 b9 03 00 00       	push   $0x3b9
f0102b7f:	68 75 55 10 f0       	push   $0xf0105575
f0102b84:	e8 1c d5 ff ff       	call   f01000a5 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b89:	83 ec 08             	sub    $0x8,%esp
f0102b8c:	68 00 10 00 00       	push   $0x1000
f0102b91:	ff 35 88 6f 1d f0    	pushl  0xf01d6f88
f0102b97:	e8 b3 e9 ff ff       	call   f010154f <page_remove>
	assert(pp2->pp_ref == 0);
f0102b9c:	83 c4 10             	add    $0x10,%esp
f0102b9f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102ba4:	74 19                	je     f0102bbf <mem_init+0x15ba>
f0102ba6:	68 9d 57 10 f0       	push   $0xf010579d
f0102bab:	68 9b 55 10 f0       	push   $0xf010559b
f0102bb0:	68 bb 03 00 00       	push   $0x3bb
f0102bb5:	68 75 55 10 f0       	push   $0xf0105575
f0102bba:	e8 e6 d4 ff ff       	call   f01000a5 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102bbf:	a1 88 6f 1d f0       	mov    0xf01d6f88,%eax
f0102bc4:	8b 08                	mov    (%eax),%ecx
f0102bc6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bcc:	89 f2                	mov    %esi,%edx
f0102bce:	2b 15 8c 6f 1d f0    	sub    0xf01d6f8c,%edx
f0102bd4:	c1 fa 03             	sar    $0x3,%edx
f0102bd7:	c1 e2 0c             	shl    $0xc,%edx
f0102bda:	39 d1                	cmp    %edx,%ecx
f0102bdc:	74 19                	je     f0102bf7 <mem_init+0x15f2>
f0102bde:	68 30 50 10 f0       	push   $0xf0105030
f0102be3:	68 9b 55 10 f0       	push   $0xf010559b
f0102be8:	68 be 03 00 00       	push   $0x3be
f0102bed:	68 75 55 10 f0       	push   $0xf0105575
f0102bf2:	e8 ae d4 ff ff       	call   f01000a5 <_panic>
	kern_pgdir[0] = 0;
f0102bf7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102bfd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c02:	74 19                	je     f0102c1d <mem_init+0x1618>
f0102c04:	68 54 57 10 f0       	push   $0xf0105754
f0102c09:	68 9b 55 10 f0       	push   $0xf010559b
f0102c0e:	68 c0 03 00 00       	push   $0x3c0
f0102c13:	68 75 55 10 f0       	push   $0xf0105575
f0102c18:	e8 88 d4 ff ff       	call   f01000a5 <_panic>
	pp0->pp_ref = 0;
f0102c1d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102c23:	83 ec 0c             	sub    $0xc,%esp
f0102c26:	56                   	push   %esi
f0102c27:	e8 8c e7 ff ff       	call   f01013b8 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102c2c:	c7 04 24 14 55 10 f0 	movl   $0xf0105514,(%esp)
f0102c33:	e8 d5 04 00 00       	call   f010310d <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c3b:	5b                   	pop    %ebx
f0102c3c:	5e                   	pop    %esi
f0102c3d:	5f                   	pop    %edi
f0102c3e:	c9                   	leave  
f0102c3f:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102c40:	89 f2                	mov    %esi,%edx
f0102c42:	89 d8                	mov    %ebx,%eax
f0102c44:	e8 f6 e2 ff ff       	call   f0100f3f <check_va2pa>
f0102c49:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102c4f:	e9 9b fb ff ff       	jmp    f01027ef <mem_init+0x11ea>

f0102c54 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102c54:	55                   	push   %ebp
f0102c55:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f0102c57:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c5c:	c9                   	leave  
f0102c5d:	c3                   	ret    

f0102c5e <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102c5e:	55                   	push   %ebp
f0102c5f:	89 e5                	mov    %esp,%ebp
f0102c61:	53                   	push   %ebx
f0102c62:	83 ec 04             	sub    $0x4,%esp
f0102c65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102c68:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c6b:	83 c8 04             	or     $0x4,%eax
f0102c6e:	50                   	push   %eax
f0102c6f:	ff 75 10             	pushl  0x10(%ebp)
f0102c72:	ff 75 0c             	pushl  0xc(%ebp)
f0102c75:	53                   	push   %ebx
f0102c76:	e8 d9 ff ff ff       	call   f0102c54 <user_mem_check>
f0102c7b:	83 c4 10             	add    $0x10,%esp
f0102c7e:	85 c0                	test   %eax,%eax
f0102c80:	79 1d                	jns    f0102c9f <user_mem_assert+0x41>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102c82:	83 ec 04             	sub    $0x4,%esp
f0102c85:	6a 00                	push   $0x0
f0102c87:	ff 73 48             	pushl  0x48(%ebx)
f0102c8a:	68 40 55 10 f0       	push   $0xf0105540
f0102c8f:	e8 79 04 00 00       	call   f010310d <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102c94:	89 1c 24             	mov    %ebx,(%esp)
f0102c97:	e8 a6 03 00 00       	call   f0103042 <env_destroy>
f0102c9c:	83 c4 10             	add    $0x10,%esp
	}
}
f0102c9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102ca2:	c9                   	leave  
f0102ca3:	c3                   	ret    

f0102ca4 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102ca4:	55                   	push   %ebp
f0102ca5:	89 e5                	mov    %esp,%ebp
f0102ca7:	53                   	push   %ebx
f0102ca8:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102cae:	8a 5d 10             	mov    0x10(%ebp),%bl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102cb1:	85 c0                	test   %eax,%eax
f0102cb3:	75 0e                	jne    f0102cc3 <envid2env+0x1f>
		*env_store = curenv;
f0102cb5:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax
f0102cba:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102cbc:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cc1:	eb 55                	jmp    f0102d18 <envid2env+0x74>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102cc3:	89 c2                	mov    %eax,%edx
f0102cc5:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102ccb:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102cce:	c1 e2 05             	shl    $0x5,%edx
f0102cd1:	03 15 b8 62 1d f0    	add    0xf01d62b8,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102cd7:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102cdb:	74 05                	je     f0102ce2 <envid2env+0x3e>
f0102cdd:	39 42 48             	cmp    %eax,0x48(%edx)
f0102ce0:	74 0d                	je     f0102cef <envid2env+0x4b>
		*env_store = 0;
f0102ce2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102ce8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ced:	eb 29                	jmp    f0102d18 <envid2env+0x74>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102cef:	84 db                	test   %bl,%bl
f0102cf1:	74 1e                	je     f0102d11 <envid2env+0x6d>
f0102cf3:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax
f0102cf8:	39 c2                	cmp    %eax,%edx
f0102cfa:	74 15                	je     f0102d11 <envid2env+0x6d>
f0102cfc:	8b 58 48             	mov    0x48(%eax),%ebx
f0102cff:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f0102d02:	74 0d                	je     f0102d11 <envid2env+0x6d>
		*env_store = 0;
f0102d04:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102d0a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102d0f:	eb 07                	jmp    f0102d18 <envid2env+0x74>
	}

	*env_store = e;
f0102d11:	89 11                	mov    %edx,(%ecx)
	return 0;
f0102d13:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d18:	5b                   	pop    %ebx
f0102d19:	c9                   	leave  
f0102d1a:	c3                   	ret    

f0102d1b <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102d1b:	55                   	push   %ebp
f0102d1c:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102d1e:	b8 30 13 12 f0       	mov    $0xf0121330,%eax
f0102d23:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102d26:	b8 23 00 00 00       	mov    $0x23,%eax
f0102d2b:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102d2d:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102d2f:	b0 10                	mov    $0x10,%al
f0102d31:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102d33:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102d35:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102d37:	ea 3e 2d 10 f0 08 00 	ljmp   $0x8,$0xf0102d3e
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102d3e:	b0 00                	mov    $0x0,%al
f0102d40:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102d43:	c9                   	leave  
f0102d44:	c3                   	ret    

f0102d45 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102d45:	55                   	push   %ebp
f0102d46:	89 e5                	mov    %esp,%ebp
	// Set up envs array
	// LAB 3: Your code here.

	// Per-CPU part of the initialization
	env_init_percpu();
f0102d48:	e8 ce ff ff ff       	call   f0102d1b <env_init_percpu>
}
f0102d4d:	c9                   	leave  
f0102d4e:	c3                   	ret    

f0102d4f <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102d4f:	55                   	push   %ebp
f0102d50:	89 e5                	mov    %esp,%ebp
f0102d52:	56                   	push   %esi
f0102d53:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102d54:	8b 1d c0 62 1d f0    	mov    0xf01d62c0,%ebx
f0102d5a:	85 db                	test   %ebx,%ebx
f0102d5c:	0f 84 0a 01 00 00    	je     f0102e6c <env_alloc+0x11d>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102d62:	83 ec 0c             	sub    $0xc,%esp
f0102d65:	6a 01                	push   $0x1
f0102d67:	e8 c2 e5 ff ff       	call   f010132e <page_alloc>
f0102d6c:	83 c4 10             	add    $0x10,%esp
f0102d6f:	85 c0                	test   %eax,%eax
f0102d71:	0f 84 fc 00 00 00    	je     f0102e73 <env_alloc+0x124>

	// LAB 3: Your code here.

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102d77:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d7a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d7f:	77 15                	ja     f0102d96 <env_alloc+0x47>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d81:	50                   	push   %eax
f0102d82:	68 54 4c 10 f0       	push   $0xf0104c54
f0102d87:	68 b9 00 00 00       	push   $0xb9
f0102d8c:	68 5a 58 10 f0       	push   $0xf010585a
f0102d91:	e8 0f d3 ff ff       	call   f01000a5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102d96:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102d9c:	83 ca 05             	or     $0x5,%edx
f0102d9f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102da5:	8b 43 48             	mov    0x48(%ebx),%eax
f0102da8:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102dad:	89 c1                	mov    %eax,%ecx
f0102daf:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0102db5:	7f 05                	jg     f0102dbc <env_alloc+0x6d>
		generation = 1 << ENVGENSHIFT;
f0102db7:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0102dbc:	89 d8                	mov    %ebx,%eax
f0102dbe:	2b 05 b8 62 1d f0    	sub    0xf01d62b8,%eax
f0102dc4:	c1 f8 05             	sar    $0x5,%eax
f0102dc7:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0102dca:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102dcd:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102dd0:	89 d6                	mov    %edx,%esi
f0102dd2:	c1 e6 08             	shl    $0x8,%esi
f0102dd5:	01 f2                	add    %esi,%edx
f0102dd7:	89 d6                	mov    %edx,%esi
f0102dd9:	c1 e6 10             	shl    $0x10,%esi
f0102ddc:	01 f2                	add    %esi,%edx
f0102dde:	8d 04 50             	lea    (%eax,%edx,2),%eax
f0102de1:	09 c1                	or     %eax,%ecx
f0102de3:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102de6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102de9:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102dec:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102df3:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102dfa:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102e01:	83 ec 04             	sub    $0x4,%esp
f0102e04:	6a 44                	push   $0x44
f0102e06:	6a 00                	push   $0x0
f0102e08:	53                   	push   %ebx
f0102e09:	e8 cf 11 00 00       	call   f0103fdd <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102e0e:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102e14:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102e1a:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102e20:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102e27:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102e2d:	8b 43 44             	mov    0x44(%ebx),%eax
f0102e30:	a3 c0 62 1d f0       	mov    %eax,0xf01d62c0
	*newenv_store = e;
f0102e35:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e38:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102e3a:	8b 53 48             	mov    0x48(%ebx),%edx
f0102e3d:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax
f0102e42:	83 c4 10             	add    $0x10,%esp
f0102e45:	85 c0                	test   %eax,%eax
f0102e47:	74 05                	je     f0102e4e <env_alloc+0xff>
f0102e49:	8b 40 48             	mov    0x48(%eax),%eax
f0102e4c:	eb 05                	jmp    f0102e53 <env_alloc+0x104>
f0102e4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e53:	83 ec 04             	sub    $0x4,%esp
f0102e56:	52                   	push   %edx
f0102e57:	50                   	push   %eax
f0102e58:	68 65 58 10 f0       	push   $0xf0105865
f0102e5d:	e8 ab 02 00 00       	call   f010310d <cprintf>
	return 0;
f0102e62:	83 c4 10             	add    $0x10,%esp
f0102e65:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e6a:	eb 0c                	jmp    f0102e78 <env_alloc+0x129>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102e6c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102e71:	eb 05                	jmp    f0102e78 <env_alloc+0x129>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102e73:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102e78:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102e7b:	5b                   	pop    %ebx
f0102e7c:	5e                   	pop    %esi
f0102e7d:	c9                   	leave  
f0102e7e:	c3                   	ret    

f0102e7f <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0102e7f:	55                   	push   %ebp
f0102e80:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0102e82:	c9                   	leave  
f0102e83:	c3                   	ret    

f0102e84 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102e84:	55                   	push   %ebp
f0102e85:	89 e5                	mov    %esp,%ebp
f0102e87:	57                   	push   %edi
f0102e88:	56                   	push   %esi
f0102e89:	53                   	push   %ebx
f0102e8a:	83 ec 1c             	sub    $0x1c,%esp
f0102e8d:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102e90:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax
f0102e95:	39 c7                	cmp    %eax,%edi
f0102e97:	75 2c                	jne    f0102ec5 <env_free+0x41>
		lcr3(PADDR(kern_pgdir));
f0102e99:	8b 15 88 6f 1d f0    	mov    0xf01d6f88,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e9f:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102ea5:	77 15                	ja     f0102ebc <env_free+0x38>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ea7:	52                   	push   %edx
f0102ea8:	68 54 4c 10 f0       	push   $0xf0104c54
f0102ead:	68 68 01 00 00       	push   $0x168
f0102eb2:	68 5a 58 10 f0       	push   $0xf010585a
f0102eb7:	e8 e9 d1 ff ff       	call   f01000a5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102ebc:	81 c2 00 00 00 10    	add    $0x10000000,%edx
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102ec2:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102ec5:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102ec8:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ecd:	85 c0                	test   %eax,%eax
f0102ecf:	74 03                	je     f0102ed4 <env_free+0x50>
f0102ed1:	8b 50 48             	mov    0x48(%eax),%edx
f0102ed4:	83 ec 04             	sub    $0x4,%esp
f0102ed7:	51                   	push   %ecx
f0102ed8:	52                   	push   %edx
f0102ed9:	68 7a 58 10 f0       	push   $0xf010587a
f0102ede:	e8 2a 02 00 00       	call   f010310d <cprintf>
f0102ee3:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102ee6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// gets reused.
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102eed:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ef0:	c1 e0 02             	shl    $0x2,%eax
f0102ef3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102ef6:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102ef9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102efc:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0102eff:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102f05:	0f 84 ab 00 00 00    	je     f0102fb6 <env_free+0x132>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102f0b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f11:	89 f0                	mov    %esi,%eax
f0102f13:	c1 e8 0c             	shr    $0xc,%eax
f0102f16:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f19:	3b 05 84 6f 1d f0    	cmp    0xf01d6f84,%eax
f0102f1f:	72 15                	jb     f0102f36 <env_free+0xb2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f21:	56                   	push   %esi
f0102f22:	68 14 4e 10 f0       	push   $0xf0104e14
f0102f27:	68 77 01 00 00       	push   $0x177
f0102f2c:	68 5a 58 10 f0       	push   $0xf010585a
f0102f31:	e8 6f d1 ff ff       	call   f01000a5 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102f36:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102f39:	c1 e2 16             	shl    $0x16,%edx
f0102f3c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102f3f:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102f44:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102f4b:	01 
f0102f4c:	74 17                	je     f0102f65 <env_free+0xe1>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102f4e:	83 ec 08             	sub    $0x8,%esp
f0102f51:	89 d8                	mov    %ebx,%eax
f0102f53:	c1 e0 0c             	shl    $0xc,%eax
f0102f56:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102f59:	50                   	push   %eax
f0102f5a:	ff 77 5c             	pushl  0x5c(%edi)
f0102f5d:	e8 ed e5 ff ff       	call   f010154f <page_remove>
f0102f62:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102f65:	43                   	inc    %ebx
f0102f66:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102f6c:	75 d6                	jne    f0102f44 <env_free+0xc0>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102f6e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102f71:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102f74:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f7b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102f7e:	3b 05 84 6f 1d f0    	cmp    0xf01d6f84,%eax
f0102f84:	72 14                	jb     f0102f9a <env_free+0x116>
		panic("pa2page called with invalid pa");
f0102f86:	83 ec 04             	sub    $0x4,%esp
f0102f89:	68 fc 4e 10 f0       	push   $0xf0104efc
f0102f8e:	6a 4f                	push   $0x4f
f0102f90:	68 81 55 10 f0       	push   $0xf0105581
f0102f95:	e8 0b d1 ff ff       	call   f01000a5 <_panic>
		page_decref(pa2page(pa));
f0102f9a:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0102f9d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102fa0:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0102fa7:	03 05 8c 6f 1d f0    	add    0xf01d6f8c,%eax
f0102fad:	50                   	push   %eax
f0102fae:	e8 25 e4 ff ff       	call   f01013d8 <page_decref>
f0102fb3:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102fb6:	ff 45 e0             	incl   -0x20(%ebp)
f0102fb9:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0102fc0:	0f 85 27 ff ff ff    	jne    f0102eed <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102fc6:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fc9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fce:	77 15                	ja     f0102fe5 <env_free+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fd0:	50                   	push   %eax
f0102fd1:	68 54 4c 10 f0       	push   $0xf0104c54
f0102fd6:	68 85 01 00 00       	push   $0x185
f0102fdb:	68 5a 58 10 f0       	push   $0xf010585a
f0102fe0:	e8 c0 d0 ff ff       	call   f01000a5 <_panic>
	e->env_pgdir = 0;
f0102fe5:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0102fec:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ff1:	c1 e8 0c             	shr    $0xc,%eax
f0102ff4:	3b 05 84 6f 1d f0    	cmp    0xf01d6f84,%eax
f0102ffa:	72 14                	jb     f0103010 <env_free+0x18c>
		panic("pa2page called with invalid pa");
f0102ffc:	83 ec 04             	sub    $0x4,%esp
f0102fff:	68 fc 4e 10 f0       	push   $0xf0104efc
f0103004:	6a 4f                	push   $0x4f
f0103006:	68 81 55 10 f0       	push   $0xf0105581
f010300b:	e8 95 d0 ff ff       	call   f01000a5 <_panic>
	page_decref(pa2page(pa));
f0103010:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103013:	c1 e0 03             	shl    $0x3,%eax
f0103016:	03 05 8c 6f 1d f0    	add    0xf01d6f8c,%eax
f010301c:	50                   	push   %eax
f010301d:	e8 b6 e3 ff ff       	call   f01013d8 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103022:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103029:	a1 c0 62 1d f0       	mov    0xf01d62c0,%eax
f010302e:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103031:	89 3d c0 62 1d f0    	mov    %edi,0xf01d62c0
f0103037:	83 c4 10             	add    $0x10,%esp
}
f010303a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010303d:	5b                   	pop    %ebx
f010303e:	5e                   	pop    %esi
f010303f:	5f                   	pop    %edi
f0103040:	c9                   	leave  
f0103041:	c3                   	ret    

f0103042 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103042:	55                   	push   %ebp
f0103043:	89 e5                	mov    %esp,%ebp
f0103045:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0103048:	ff 75 08             	pushl  0x8(%ebp)
f010304b:	e8 34 fe ff ff       	call   f0102e84 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103050:	c7 04 24 24 58 10 f0 	movl   $0xf0105824,(%esp)
f0103057:	e8 b1 00 00 00       	call   f010310d <cprintf>
f010305c:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f010305f:	83 ec 0c             	sub    $0xc,%esp
f0103062:	6a 00                	push   $0x0
f0103064:	e8 60 dd ff ff       	call   f0100dc9 <monitor>
f0103069:	83 c4 10             	add    $0x10,%esp
f010306c:	eb f1                	jmp    f010305f <env_destroy+0x1d>

f010306e <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010306e:	55                   	push   %ebp
f010306f:	89 e5                	mov    %esp,%ebp
f0103071:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103074:	8b 65 08             	mov    0x8(%ebp),%esp
f0103077:	61                   	popa   
f0103078:	07                   	pop    %es
f0103079:	1f                   	pop    %ds
f010307a:	83 c4 08             	add    $0x8,%esp
f010307d:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010307e:	68 90 58 10 f0       	push   $0xf0105890
f0103083:	68 ad 01 00 00       	push   $0x1ad
f0103088:	68 5a 58 10 f0       	push   $0xf010585a
f010308d:	e8 13 d0 ff ff       	call   f01000a5 <_panic>

f0103092 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103092:	55                   	push   %ebp
f0103093:	89 e5                	mov    %esp,%ebp
f0103095:	83 ec 0c             	sub    $0xc,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f0103098:	68 9c 58 10 f0       	push   $0xf010589c
f010309d:	68 cc 01 00 00       	push   $0x1cc
f01030a2:	68 5a 58 10 f0       	push   $0xf010585a
f01030a7:	e8 f9 cf ff ff       	call   f01000a5 <_panic>

f01030ac <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01030ac:	55                   	push   %ebp
f01030ad:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01030af:	ba 70 00 00 00       	mov    $0x70,%edx
f01030b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01030b7:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01030b8:	b2 71                	mov    $0x71,%dl
f01030ba:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01030bb:	0f b6 c0             	movzbl %al,%eax
}
f01030be:	c9                   	leave  
f01030bf:	c3                   	ret    

f01030c0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01030c0:	55                   	push   %ebp
f01030c1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01030c3:	ba 70 00 00 00       	mov    $0x70,%edx
f01030c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01030cb:	ee                   	out    %al,(%dx)
f01030cc:	b2 71                	mov    $0x71,%dl
f01030ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030d1:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01030d2:	c9                   	leave  
f01030d3:	c3                   	ret    

f01030d4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01030d4:	55                   	push   %ebp
f01030d5:	89 e5                	mov    %esp,%ebp
f01030d7:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01030da:	ff 75 08             	pushl  0x8(%ebp)
f01030dd:	e8 e0 d4 ff ff       	call   f01005c2 <cputchar>
f01030e2:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f01030e5:	c9                   	leave  
f01030e6:	c3                   	ret    

f01030e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01030e7:	55                   	push   %ebp
f01030e8:	89 e5                	mov    %esp,%ebp
f01030ea:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01030ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01030f4:	ff 75 0c             	pushl  0xc(%ebp)
f01030f7:	ff 75 08             	pushl  0x8(%ebp)
f01030fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01030fd:	50                   	push   %eax
f01030fe:	68 d4 30 10 f0       	push   $0xf01030d4
f0103103:	e8 3d 08 00 00       	call   f0103945 <vprintfmt>
	return cnt;
}
f0103108:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010310b:	c9                   	leave  
f010310c:	c3                   	ret    

f010310d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010310d:	55                   	push   %ebp
f010310e:	89 e5                	mov    %esp,%ebp
f0103110:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103113:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103116:	50                   	push   %eax
f0103117:	ff 75 08             	pushl  0x8(%ebp)
f010311a:	e8 c8 ff ff ff       	call   f01030e7 <vcprintf>
	va_end(ap);

	return cnt;
}
f010311f:	c9                   	leave  
f0103120:	c3                   	ret    
f0103121:	00 00                	add    %al,(%eax)
	...

f0103124 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103124:	55                   	push   %ebp
f0103125:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103127:	c7 05 04 6b 1d f0 00 	movl   $0xf0000000,0xf01d6b04
f010312e:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103131:	66 c7 05 08 6b 1d f0 	movw   $0x10,0xf01d6b08
f0103138:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010313a:	66 c7 05 28 13 12 f0 	movw   $0x68,0xf0121328
f0103141:	68 00 
f0103143:	b8 00 6b 1d f0       	mov    $0xf01d6b00,%eax
f0103148:	66 a3 2a 13 12 f0    	mov    %ax,0xf012132a
f010314e:	89 c2                	mov    %eax,%edx
f0103150:	c1 ea 10             	shr    $0x10,%edx
f0103153:	88 15 2c 13 12 f0    	mov    %dl,0xf012132c
f0103159:	c6 05 2e 13 12 f0 40 	movb   $0x40,0xf012132e
f0103160:	c1 e8 18             	shr    $0x18,%eax
f0103163:	a2 2f 13 12 f0       	mov    %al,0xf012132f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103168:	c6 05 2d 13 12 f0 89 	movb   $0x89,0xf012132d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010316f:	b8 28 00 00 00       	mov    $0x28,%eax
f0103174:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103177:	b8 38 13 12 f0       	mov    $0xf0121338,%eax
f010317c:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010317f:	c9                   	leave  
f0103180:	c3                   	ret    

f0103181 <trap_init>:
}


void
trap_init(void)
{
f0103181:	55                   	push   %ebp
f0103182:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f0103184:	e8 9b ff ff ff       	call   f0103124 <trap_init_percpu>
}
f0103189:	c9                   	leave  
f010318a:	c3                   	ret    

f010318b <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010318b:	55                   	push   %ebp
f010318c:	89 e5                	mov    %esp,%ebp
f010318e:	53                   	push   %ebx
f010318f:	83 ec 0c             	sub    $0xc,%esp
f0103192:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103195:	ff 33                	pushl  (%ebx)
f0103197:	68 b8 58 10 f0       	push   $0xf01058b8
f010319c:	e8 6c ff ff ff       	call   f010310d <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01031a1:	83 c4 08             	add    $0x8,%esp
f01031a4:	ff 73 04             	pushl  0x4(%ebx)
f01031a7:	68 c7 58 10 f0       	push   $0xf01058c7
f01031ac:	e8 5c ff ff ff       	call   f010310d <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01031b1:	83 c4 08             	add    $0x8,%esp
f01031b4:	ff 73 08             	pushl  0x8(%ebx)
f01031b7:	68 d6 58 10 f0       	push   $0xf01058d6
f01031bc:	e8 4c ff ff ff       	call   f010310d <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01031c1:	83 c4 08             	add    $0x8,%esp
f01031c4:	ff 73 0c             	pushl  0xc(%ebx)
f01031c7:	68 e5 58 10 f0       	push   $0xf01058e5
f01031cc:	e8 3c ff ff ff       	call   f010310d <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01031d1:	83 c4 08             	add    $0x8,%esp
f01031d4:	ff 73 10             	pushl  0x10(%ebx)
f01031d7:	68 f4 58 10 f0       	push   $0xf01058f4
f01031dc:	e8 2c ff ff ff       	call   f010310d <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01031e1:	83 c4 08             	add    $0x8,%esp
f01031e4:	ff 73 14             	pushl  0x14(%ebx)
f01031e7:	68 03 59 10 f0       	push   $0xf0105903
f01031ec:	e8 1c ff ff ff       	call   f010310d <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01031f1:	83 c4 08             	add    $0x8,%esp
f01031f4:	ff 73 18             	pushl  0x18(%ebx)
f01031f7:	68 12 59 10 f0       	push   $0xf0105912
f01031fc:	e8 0c ff ff ff       	call   f010310d <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103201:	83 c4 08             	add    $0x8,%esp
f0103204:	ff 73 1c             	pushl  0x1c(%ebx)
f0103207:	68 21 59 10 f0       	push   $0xf0105921
f010320c:	e8 fc fe ff ff       	call   f010310d <cprintf>
f0103211:	83 c4 10             	add    $0x10,%esp
}
f0103214:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103217:	c9                   	leave  
f0103218:	c3                   	ret    

f0103219 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103219:	55                   	push   %ebp
f010321a:	89 e5                	mov    %esp,%ebp
f010321c:	53                   	push   %ebx
f010321d:	83 ec 0c             	sub    $0xc,%esp
f0103220:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103223:	53                   	push   %ebx
f0103224:	68 57 5a 10 f0       	push   $0xf0105a57
f0103229:	e8 df fe ff ff       	call   f010310d <cprintf>
	print_regs(&tf->tf_regs);
f010322e:	89 1c 24             	mov    %ebx,(%esp)
f0103231:	e8 55 ff ff ff       	call   f010318b <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103236:	83 c4 08             	add    $0x8,%esp
f0103239:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010323d:	50                   	push   %eax
f010323e:	68 72 59 10 f0       	push   $0xf0105972
f0103243:	e8 c5 fe ff ff       	call   f010310d <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103248:	83 c4 08             	add    $0x8,%esp
f010324b:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010324f:	50                   	push   %eax
f0103250:	68 85 59 10 f0       	push   $0xf0105985
f0103255:	e8 b3 fe ff ff       	call   f010310d <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010325a:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010325d:	83 c4 10             	add    $0x10,%esp
f0103260:	83 f8 13             	cmp    $0x13,%eax
f0103263:	77 09                	ja     f010326e <print_trapframe+0x55>
		return excnames[trapno];
f0103265:	8b 14 85 20 5c 10 f0 	mov    -0xfefa3e0(,%eax,4),%edx
f010326c:	eb 11                	jmp    f010327f <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
f010326e:	83 f8 30             	cmp    $0x30,%eax
f0103271:	75 07                	jne    f010327a <print_trapframe+0x61>
		return "System call";
f0103273:	ba 30 59 10 f0       	mov    $0xf0105930,%edx
f0103278:	eb 05                	jmp    f010327f <print_trapframe+0x66>
	return "(unknown trap)";
f010327a:	ba 3c 59 10 f0       	mov    $0xf010593c,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010327f:	83 ec 04             	sub    $0x4,%esp
f0103282:	52                   	push   %edx
f0103283:	50                   	push   %eax
f0103284:	68 98 59 10 f0       	push   $0xf0105998
f0103289:	e8 7f fe ff ff       	call   f010310d <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010328e:	83 c4 10             	add    $0x10,%esp
f0103291:	3b 1d e0 6a 1d f0    	cmp    0xf01d6ae0,%ebx
f0103297:	75 1a                	jne    f01032b3 <print_trapframe+0x9a>
f0103299:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010329d:	75 14                	jne    f01032b3 <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010329f:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01032a2:	83 ec 08             	sub    $0x8,%esp
f01032a5:	50                   	push   %eax
f01032a6:	68 aa 59 10 f0       	push   $0xf01059aa
f01032ab:	e8 5d fe ff ff       	call   f010310d <cprintf>
f01032b0:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01032b3:	83 ec 08             	sub    $0x8,%esp
f01032b6:	ff 73 2c             	pushl  0x2c(%ebx)
f01032b9:	68 b9 59 10 f0       	push   $0xf01059b9
f01032be:	e8 4a fe ff ff       	call   f010310d <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01032c3:	83 c4 10             	add    $0x10,%esp
f01032c6:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01032ca:	75 45                	jne    f0103311 <print_trapframe+0xf8>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01032cc:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01032cf:	a8 01                	test   $0x1,%al
f01032d1:	74 07                	je     f01032da <print_trapframe+0xc1>
f01032d3:	b9 4b 59 10 f0       	mov    $0xf010594b,%ecx
f01032d8:	eb 05                	jmp    f01032df <print_trapframe+0xc6>
f01032da:	b9 56 59 10 f0       	mov    $0xf0105956,%ecx
f01032df:	a8 02                	test   $0x2,%al
f01032e1:	74 07                	je     f01032ea <print_trapframe+0xd1>
f01032e3:	ba 62 59 10 f0       	mov    $0xf0105962,%edx
f01032e8:	eb 05                	jmp    f01032ef <print_trapframe+0xd6>
f01032ea:	ba 68 59 10 f0       	mov    $0xf0105968,%edx
f01032ef:	a8 04                	test   $0x4,%al
f01032f1:	74 07                	je     f01032fa <print_trapframe+0xe1>
f01032f3:	b8 6d 59 10 f0       	mov    $0xf010596d,%eax
f01032f8:	eb 05                	jmp    f01032ff <print_trapframe+0xe6>
f01032fa:	b8 82 5a 10 f0       	mov    $0xf0105a82,%eax
f01032ff:	51                   	push   %ecx
f0103300:	52                   	push   %edx
f0103301:	50                   	push   %eax
f0103302:	68 c7 59 10 f0       	push   $0xf01059c7
f0103307:	e8 01 fe ff ff       	call   f010310d <cprintf>
f010330c:	83 c4 10             	add    $0x10,%esp
f010330f:	eb 10                	jmp    f0103321 <print_trapframe+0x108>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103311:	83 ec 0c             	sub    $0xc,%esp
f0103314:	68 25 47 10 f0       	push   $0xf0104725
f0103319:	e8 ef fd ff ff       	call   f010310d <cprintf>
f010331e:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103321:	83 ec 08             	sub    $0x8,%esp
f0103324:	ff 73 30             	pushl  0x30(%ebx)
f0103327:	68 d6 59 10 f0       	push   $0xf01059d6
f010332c:	e8 dc fd ff ff       	call   f010310d <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103331:	83 c4 08             	add    $0x8,%esp
f0103334:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103338:	50                   	push   %eax
f0103339:	68 e5 59 10 f0       	push   $0xf01059e5
f010333e:	e8 ca fd ff ff       	call   f010310d <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103343:	83 c4 08             	add    $0x8,%esp
f0103346:	ff 73 38             	pushl  0x38(%ebx)
f0103349:	68 f8 59 10 f0       	push   $0xf01059f8
f010334e:	e8 ba fd ff ff       	call   f010310d <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103353:	83 c4 10             	add    $0x10,%esp
f0103356:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010335a:	74 25                	je     f0103381 <print_trapframe+0x168>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010335c:	83 ec 08             	sub    $0x8,%esp
f010335f:	ff 73 3c             	pushl  0x3c(%ebx)
f0103362:	68 07 5a 10 f0       	push   $0xf0105a07
f0103367:	e8 a1 fd ff ff       	call   f010310d <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010336c:	83 c4 08             	add    $0x8,%esp
f010336f:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103373:	50                   	push   %eax
f0103374:	68 16 5a 10 f0       	push   $0xf0105a16
f0103379:	e8 8f fd ff ff       	call   f010310d <cprintf>
f010337e:	83 c4 10             	add    $0x10,%esp
	}
}
f0103381:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103384:	c9                   	leave  
f0103385:	c3                   	ret    

f0103386 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103386:	55                   	push   %ebp
f0103387:	89 e5                	mov    %esp,%ebp
f0103389:	57                   	push   %edi
f010338a:	56                   	push   %esi
f010338b:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010338e:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010338f:	9c                   	pushf  
f0103390:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103391:	f6 c4 02             	test   $0x2,%ah
f0103394:	74 19                	je     f01033af <trap+0x29>
f0103396:	68 29 5a 10 f0       	push   $0xf0105a29
f010339b:	68 9b 55 10 f0       	push   $0xf010559b
f01033a0:	68 a7 00 00 00       	push   $0xa7
f01033a5:	68 42 5a 10 f0       	push   $0xf0105a42
f01033aa:	e8 f6 cc ff ff       	call   f01000a5 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01033af:	83 ec 08             	sub    $0x8,%esp
f01033b2:	56                   	push   %esi
f01033b3:	68 4e 5a 10 f0       	push   $0xf0105a4e
f01033b8:	e8 50 fd ff ff       	call   f010310d <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01033bd:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01033c1:	83 e0 03             	and    $0x3,%eax
f01033c4:	83 c4 10             	add    $0x10,%esp
f01033c7:	83 f8 03             	cmp    $0x3,%eax
f01033ca:	75 31                	jne    f01033fd <trap+0x77>
		// Trapped from user mode.
		assert(curenv);
f01033cc:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax
f01033d1:	85 c0                	test   %eax,%eax
f01033d3:	75 19                	jne    f01033ee <trap+0x68>
f01033d5:	68 69 5a 10 f0       	push   $0xf0105a69
f01033da:	68 9b 55 10 f0       	push   $0xf010559b
f01033df:	68 ad 00 00 00       	push   $0xad
f01033e4:	68 42 5a 10 f0       	push   $0xf0105a42
f01033e9:	e8 b7 cc ff ff       	call   f01000a5 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01033ee:	b9 11 00 00 00       	mov    $0x11,%ecx
f01033f3:	89 c7                	mov    %eax,%edi
f01033f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01033f7:	8b 35 bc 62 1d f0    	mov    0xf01d62bc,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01033fd:	89 35 e0 6a 1d f0    	mov    %esi,0xf01d6ae0
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103403:	83 ec 0c             	sub    $0xc,%esp
f0103406:	56                   	push   %esi
f0103407:	e8 0d fe ff ff       	call   f0103219 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010340c:	83 c4 10             	add    $0x10,%esp
f010340f:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103414:	75 17                	jne    f010342d <trap+0xa7>
		panic("unhandled trap in kernel");
f0103416:	83 ec 04             	sub    $0x4,%esp
f0103419:	68 70 5a 10 f0       	push   $0xf0105a70
f010341e:	68 96 00 00 00       	push   $0x96
f0103423:	68 42 5a 10 f0       	push   $0xf0105a42
f0103428:	e8 78 cc ff ff       	call   f01000a5 <_panic>
	else {
		env_destroy(curenv);
f010342d:	83 ec 0c             	sub    $0xc,%esp
f0103430:	ff 35 bc 62 1d f0    	pushl  0xf01d62bc
f0103436:	e8 07 fc ff ff       	call   f0103042 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010343b:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax
f0103440:	83 c4 10             	add    $0x10,%esp
f0103443:	85 c0                	test   %eax,%eax
f0103445:	74 06                	je     f010344d <trap+0xc7>
f0103447:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010344b:	74 19                	je     f0103466 <trap+0xe0>
f010344d:	68 cc 5b 10 f0       	push   $0xf0105bcc
f0103452:	68 9b 55 10 f0       	push   $0xf010559b
f0103457:	68 bf 00 00 00       	push   $0xbf
f010345c:	68 42 5a 10 f0       	push   $0xf0105a42
f0103461:	e8 3f cc ff ff       	call   f01000a5 <_panic>
	env_run(curenv);
f0103466:	83 ec 0c             	sub    $0xc,%esp
f0103469:	50                   	push   %eax
f010346a:	e8 23 fc ff ff       	call   f0103092 <env_run>

f010346f <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010346f:	55                   	push   %ebp
f0103470:	89 e5                	mov    %esp,%ebp
f0103472:	53                   	push   %ebx
f0103473:	83 ec 04             	sub    $0x4,%esp
f0103476:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103479:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010347c:	ff 73 30             	pushl  0x30(%ebx)
f010347f:	50                   	push   %eax
		curenv->env_id, fault_va, tf->tf_eip);
f0103480:	a1 bc 62 1d f0       	mov    0xf01d62bc,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103485:	ff 70 48             	pushl  0x48(%eax)
f0103488:	68 f8 5b 10 f0       	push   $0xf0105bf8
f010348d:	e8 7b fc ff ff       	call   f010310d <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103492:	89 1c 24             	mov    %ebx,(%esp)
f0103495:	e8 7f fd ff ff       	call   f0103219 <print_trapframe>
	env_destroy(curenv);
f010349a:	83 c4 04             	add    $0x4,%esp
f010349d:	ff 35 bc 62 1d f0    	pushl  0xf01d62bc
f01034a3:	e8 9a fb ff ff       	call   f0103042 <env_destroy>
f01034a8:	83 c4 10             	add    $0x10,%esp
}
f01034ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034ae:	c9                   	leave  
f01034af:	c3                   	ret    

f01034b0 <syscall>:
f01034b0:	55                   	push   %ebp
f01034b1:	89 e5                	mov    %esp,%ebp
f01034b3:	83 ec 0c             	sub    $0xc,%esp
f01034b6:	68 70 5c 10 f0       	push   $0xf0105c70
f01034bb:	6a 49                	push   $0x49
f01034bd:	68 88 5c 10 f0       	push   $0xf0105c88
f01034c2:	e8 de cb ff ff       	call   f01000a5 <_panic>
	...

f01034c8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01034c8:	55                   	push   %ebp
f01034c9:	89 e5                	mov    %esp,%ebp
f01034cb:	57                   	push   %edi
f01034cc:	56                   	push   %esi
f01034cd:	53                   	push   %ebx
f01034ce:	83 ec 14             	sub    $0x14,%esp
f01034d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01034d4:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01034d7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01034da:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01034dd:	8b 1a                	mov    (%edx),%ebx
f01034df:	8b 01                	mov    (%ecx),%eax
f01034e1:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f01034e4:	39 c3                	cmp    %eax,%ebx
f01034e6:	0f 8f 97 00 00 00    	jg     f0103583 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f01034ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01034f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01034f6:	01 d8                	add    %ebx,%eax
f01034f8:	89 c7                	mov    %eax,%edi
f01034fa:	c1 ef 1f             	shr    $0x1f,%edi
f01034fd:	01 c7                	add    %eax,%edi
f01034ff:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103501:	39 df                	cmp    %ebx,%edi
f0103503:	7c 31                	jl     f0103536 <stab_binsearch+0x6e>
f0103505:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103508:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010350b:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103510:	39 f0                	cmp    %esi,%eax
f0103512:	0f 84 b3 00 00 00    	je     f01035cb <stab_binsearch+0x103>
f0103518:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010351c:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103520:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103522:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103523:	39 d8                	cmp    %ebx,%eax
f0103525:	7c 0f                	jl     f0103536 <stab_binsearch+0x6e>
f0103527:	0f b6 0a             	movzbl (%edx),%ecx
f010352a:	83 ea 0c             	sub    $0xc,%edx
f010352d:	39 f1                	cmp    %esi,%ecx
f010352f:	75 f1                	jne    f0103522 <stab_binsearch+0x5a>
f0103531:	e9 97 00 00 00       	jmp    f01035cd <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103536:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103539:	eb 39                	jmp    f0103574 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010353b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010353e:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0103540:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103543:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010354a:	eb 28                	jmp    f0103574 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010354c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010354f:	76 12                	jbe    f0103563 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0103551:	48                   	dec    %eax
f0103552:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103555:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103558:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010355a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103561:	eb 11                	jmp    f0103574 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103563:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103566:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103568:	ff 45 0c             	incl   0xc(%ebp)
f010356b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010356d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103574:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103577:	0f 8d 76 ff ff ff    	jge    f01034f3 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010357d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103581:	75 0d                	jne    f0103590 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0103583:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103586:	8b 03                	mov    (%ebx),%eax
f0103588:	48                   	dec    %eax
f0103589:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010358c:	89 02                	mov    %eax,(%edx)
f010358e:	eb 55                	jmp    f01035e5 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103590:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103593:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103595:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103598:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010359a:	39 c1                	cmp    %eax,%ecx
f010359c:	7d 26                	jge    f01035c4 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f010359e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01035a1:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01035a4:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01035a9:	39 f2                	cmp    %esi,%edx
f01035ab:	74 17                	je     f01035c4 <stab_binsearch+0xfc>
f01035ad:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01035b1:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01035b5:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01035b6:	39 c1                	cmp    %eax,%ecx
f01035b8:	7d 0a                	jge    f01035c4 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01035ba:	0f b6 1a             	movzbl (%edx),%ebx
f01035bd:	83 ea 0c             	sub    $0xc,%edx
f01035c0:	39 f3                	cmp    %esi,%ebx
f01035c2:	75 f1                	jne    f01035b5 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f01035c4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01035c7:	89 02                	mov    %eax,(%edx)
f01035c9:	eb 1a                	jmp    f01035e5 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01035cb:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01035cd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01035d0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01035d3:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01035d7:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01035da:	0f 82 5b ff ff ff    	jb     f010353b <stab_binsearch+0x73>
f01035e0:	e9 67 ff ff ff       	jmp    f010354c <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01035e5:	83 c4 14             	add    $0x14,%esp
f01035e8:	5b                   	pop    %ebx
f01035e9:	5e                   	pop    %esi
f01035ea:	5f                   	pop    %edi
f01035eb:	c9                   	leave  
f01035ec:	c3                   	ret    

f01035ed <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01035ed:	55                   	push   %ebp
f01035ee:	89 e5                	mov    %esp,%ebp
f01035f0:	57                   	push   %edi
f01035f1:	56                   	push   %esi
f01035f2:	53                   	push   %ebx
f01035f3:	83 ec 2c             	sub    $0x2c,%esp
f01035f6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01035f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01035fc:	c7 03 97 5c 10 f0    	movl   $0xf0105c97,(%ebx)
	info->eip_line = 0;
f0103602:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103609:	c7 43 08 97 5c 10 f0 	movl   $0xf0105c97,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103610:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103617:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010361a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103621:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0103627:	77 1e                	ja     f0103647 <debuginfo_eip+0x5a>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103629:	a1 00 00 20 00       	mov    0x200000,%eax
f010362e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stab_end = usd->stab_end;
f0103631:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103636:	8b 15 08 00 20 00    	mov    0x200008,%edx
f010363c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f010363f:	8b 35 0c 00 20 00    	mov    0x20000c,%esi
f0103645:	eb 18                	jmp    f010365f <debuginfo_eip+0x72>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103647:	be 3a 6d 11 f0       	mov    $0xf0116d3a,%esi

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010364c:	c7 45 d4 39 e8 10 f0 	movl   $0xf010e839,-0x2c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103653:	b8 38 e8 10 f0       	mov    $0xf010e838,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103658:	c7 45 d0 b0 5e 10 f0 	movl   $0xf0105eb0,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010365f:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0103662:	0f 83 5c 01 00 00    	jae    f01037c4 <debuginfo_eip+0x1d7>
f0103668:	80 7e ff 00          	cmpb   $0x0,-0x1(%esi)
f010366c:	0f 85 59 01 00 00    	jne    f01037cb <debuginfo_eip+0x1de>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103672:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103679:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010367c:	c1 f8 02             	sar    $0x2,%eax
f010367f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103685:	48                   	dec    %eax
f0103686:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103689:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010368c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010368f:	57                   	push   %edi
f0103690:	6a 64                	push   $0x64
f0103692:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103695:	e8 2e fe ff ff       	call   f01034c8 <stab_binsearch>
	if (lfile == 0)
f010369a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010369d:	83 c4 08             	add    $0x8,%esp
		return -1;
f01036a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01036a5:	85 d2                	test   %edx,%edx
f01036a7:	0f 84 2a 01 00 00    	je     f01037d7 <debuginfo_eip+0x1ea>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01036ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01036b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01036b6:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01036b9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01036bc:	57                   	push   %edi
f01036bd:	6a 24                	push   $0x24
f01036bf:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01036c2:	e8 01 fe ff ff       	call   f01034c8 <stab_binsearch>

	if (lfun <= rfun) {
f01036c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01036ca:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01036cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01036d0:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01036d3:	83 c4 08             	add    $0x8,%esp
f01036d6:	39 c1                	cmp    %eax,%ecx
f01036d8:	7f 21                	jg     f01036fb <debuginfo_eip+0x10e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01036da:	6b c1 0c             	imul   $0xc,%ecx,%eax
f01036dd:	03 45 d0             	add    -0x30(%ebp),%eax
f01036e0:	8b 10                	mov    (%eax),%edx
f01036e2:	89 f1                	mov    %esi,%ecx
f01036e4:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f01036e7:	39 ca                	cmp    %ecx,%edx
f01036e9:	73 06                	jae    f01036f1 <debuginfo_eip+0x104>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01036eb:	03 55 d4             	add    -0x2c(%ebp),%edx
f01036ee:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01036f1:	8b 40 08             	mov    0x8(%eax),%eax
f01036f4:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01036f7:	29 c7                	sub    %eax,%edi
f01036f9:	eb 0f                	jmp    f010370a <debuginfo_eip+0x11d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01036fb:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f01036fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103701:	89 55 cc             	mov    %edx,-0x34(%ebp)
		rline = rfile;
f0103704:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103707:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010370a:	83 ec 08             	sub    $0x8,%esp
f010370d:	6a 3a                	push   $0x3a
f010370f:	ff 73 08             	pushl  0x8(%ebx)
f0103712:	e8 a4 08 00 00       	call   f0103fbb <strfind>
f0103717:	2b 43 08             	sub    0x8(%ebx),%eax
f010371a:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f010371d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103720:	89 45 dc             	mov    %eax,-0x24(%ebp)
    rfun = rline;
f0103723:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0103726:	89 55 d8             	mov    %edx,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0103729:	83 c4 08             	add    $0x8,%esp
f010372c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010372f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103732:	57                   	push   %edi
f0103733:	6a 44                	push   $0x44
f0103735:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103738:	e8 8b fd ff ff       	call   f01034c8 <stab_binsearch>
    if (lfun <= rfun) {
f010373d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103740:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0103743:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0103748:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f010374b:	0f 8f 86 00 00 00    	jg     f01037d7 <debuginfo_eip+0x1ea>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0103751:	6b ca 0c             	imul   $0xc,%edx,%ecx
f0103754:	03 4d d0             	add    -0x30(%ebp),%ecx
f0103757:	0f b7 41 06          	movzwl 0x6(%ecx),%eax
f010375b:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010375e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103761:	89 45 cc             	mov    %eax,-0x34(%ebp)
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103764:	8d 41 08             	lea    0x8(%ecx),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103767:	eb 04                	jmp    f010376d <debuginfo_eip+0x180>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103769:	4a                   	dec    %edx
f010376a:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010376d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f0103770:	7c 19                	jl     f010378b <debuginfo_eip+0x19e>
	       && stabs[lline].n_type != N_SOL
f0103772:	8a 48 fc             	mov    -0x4(%eax),%cl
f0103775:	80 f9 84             	cmp    $0x84,%cl
f0103778:	74 65                	je     f01037df <debuginfo_eip+0x1f2>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010377a:	80 f9 64             	cmp    $0x64,%cl
f010377d:	75 ea                	jne    f0103769 <debuginfo_eip+0x17c>
f010377f:	83 38 00             	cmpl   $0x0,(%eax)
f0103782:	74 e5                	je     f0103769 <debuginfo_eip+0x17c>
f0103784:	eb 59                	jmp    f01037df <debuginfo_eip+0x1f2>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103786:	03 45 d4             	add    -0x2c(%ebp),%eax
f0103789:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010378b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010378e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103791:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103796:	39 ca                	cmp    %ecx,%edx
f0103798:	7d 3d                	jge    f01037d7 <debuginfo_eip+0x1ea>
		for (lline = lfun + 1;
f010379a:	8d 42 01             	lea    0x1(%edx),%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010379d:	6b d0 0c             	imul   $0xc,%eax,%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01037a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01037a3:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f01037a7:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01037a9:	eb 04                	jmp    f01037af <debuginfo_eip+0x1c2>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01037ab:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01037ae:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01037af:	39 f0                	cmp    %esi,%eax
f01037b1:	7d 1f                	jge    f01037d2 <debuginfo_eip+0x1e5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01037b3:	8a 0a                	mov    (%edx),%cl
f01037b5:	83 c2 0c             	add    $0xc,%edx
f01037b8:	80 f9 a0             	cmp    $0xa0,%cl
f01037bb:	74 ee                	je     f01037ab <debuginfo_eip+0x1be>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01037bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01037c2:	eb 13                	jmp    f01037d7 <debuginfo_eip+0x1ea>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01037c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037c9:	eb 0c                	jmp    f01037d7 <debuginfo_eip+0x1ea>
f01037cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037d0:	eb 05                	jmp    f01037d7 <debuginfo_eip+0x1ea>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01037d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01037d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037da:	5b                   	pop    %ebx
f01037db:	5e                   	pop    %esi
f01037dc:	5f                   	pop    %edi
f01037dd:	c9                   	leave  
f01037de:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01037df:	6b d2 0c             	imul   $0xc,%edx,%edx
f01037e2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01037e5:	8b 04 11             	mov    (%ecx,%edx,1),%eax
f01037e8:	2b 75 d4             	sub    -0x2c(%ebp),%esi
f01037eb:	39 f0                	cmp    %esi,%eax
f01037ed:	72 97                	jb     f0103786 <debuginfo_eip+0x199>
f01037ef:	eb 9a                	jmp    f010378b <debuginfo_eip+0x19e>
f01037f1:	00 00                	add    %al,(%eax)
	...

f01037f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01037f4:	55                   	push   %ebp
f01037f5:	89 e5                	mov    %esp,%ebp
f01037f7:	57                   	push   %edi
f01037f8:	56                   	push   %esi
f01037f9:	53                   	push   %ebx
f01037fa:	83 ec 2c             	sub    $0x2c,%esp
f01037fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103800:	89 d6                	mov    %edx,%esi
f0103802:	8b 45 08             	mov    0x8(%ebp),%eax
f0103805:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103808:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010380b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010380e:	8b 45 10             	mov    0x10(%ebp),%eax
f0103811:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103814:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103817:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010381a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0103821:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0103824:	72 0c                	jb     f0103832 <printnum+0x3e>
f0103826:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103829:	76 07                	jbe    f0103832 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010382b:	4b                   	dec    %ebx
f010382c:	85 db                	test   %ebx,%ebx
f010382e:	7f 31                	jg     f0103861 <printnum+0x6d>
f0103830:	eb 3f                	jmp    f0103871 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103832:	83 ec 0c             	sub    $0xc,%esp
f0103835:	57                   	push   %edi
f0103836:	4b                   	dec    %ebx
f0103837:	53                   	push   %ebx
f0103838:	50                   	push   %eax
f0103839:	83 ec 08             	sub    $0x8,%esp
f010383c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010383f:	ff 75 d0             	pushl  -0x30(%ebp)
f0103842:	ff 75 dc             	pushl  -0x24(%ebp)
f0103845:	ff 75 d8             	pushl  -0x28(%ebp)
f0103848:	e8 97 09 00 00       	call   f01041e4 <__udivdi3>
f010384d:	83 c4 18             	add    $0x18,%esp
f0103850:	52                   	push   %edx
f0103851:	50                   	push   %eax
f0103852:	89 f2                	mov    %esi,%edx
f0103854:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103857:	e8 98 ff ff ff       	call   f01037f4 <printnum>
f010385c:	83 c4 20             	add    $0x20,%esp
f010385f:	eb 10                	jmp    f0103871 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103861:	83 ec 08             	sub    $0x8,%esp
f0103864:	56                   	push   %esi
f0103865:	57                   	push   %edi
f0103866:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103869:	4b                   	dec    %ebx
f010386a:	83 c4 10             	add    $0x10,%esp
f010386d:	85 db                	test   %ebx,%ebx
f010386f:	7f f0                	jg     f0103861 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103871:	83 ec 08             	sub    $0x8,%esp
f0103874:	56                   	push   %esi
f0103875:	83 ec 04             	sub    $0x4,%esp
f0103878:	ff 75 d4             	pushl  -0x2c(%ebp)
f010387b:	ff 75 d0             	pushl  -0x30(%ebp)
f010387e:	ff 75 dc             	pushl  -0x24(%ebp)
f0103881:	ff 75 d8             	pushl  -0x28(%ebp)
f0103884:	e8 77 0a 00 00       	call   f0104300 <__umoddi3>
f0103889:	83 c4 14             	add    $0x14,%esp
f010388c:	0f be 80 a1 5c 10 f0 	movsbl -0xfefa35f(%eax),%eax
f0103893:	50                   	push   %eax
f0103894:	ff 55 e4             	call   *-0x1c(%ebp)
f0103897:	83 c4 10             	add    $0x10,%esp
}
f010389a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010389d:	5b                   	pop    %ebx
f010389e:	5e                   	pop    %esi
f010389f:	5f                   	pop    %edi
f01038a0:	c9                   	leave  
f01038a1:	c3                   	ret    

f01038a2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01038a2:	55                   	push   %ebp
f01038a3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01038a5:	83 fa 01             	cmp    $0x1,%edx
f01038a8:	7e 0e                	jle    f01038b8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01038aa:	8b 10                	mov    (%eax),%edx
f01038ac:	8d 4a 08             	lea    0x8(%edx),%ecx
f01038af:	89 08                	mov    %ecx,(%eax)
f01038b1:	8b 02                	mov    (%edx),%eax
f01038b3:	8b 52 04             	mov    0x4(%edx),%edx
f01038b6:	eb 22                	jmp    f01038da <getuint+0x38>
	else if (lflag)
f01038b8:	85 d2                	test   %edx,%edx
f01038ba:	74 10                	je     f01038cc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01038bc:	8b 10                	mov    (%eax),%edx
f01038be:	8d 4a 04             	lea    0x4(%edx),%ecx
f01038c1:	89 08                	mov    %ecx,(%eax)
f01038c3:	8b 02                	mov    (%edx),%eax
f01038c5:	ba 00 00 00 00       	mov    $0x0,%edx
f01038ca:	eb 0e                	jmp    f01038da <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01038cc:	8b 10                	mov    (%eax),%edx
f01038ce:	8d 4a 04             	lea    0x4(%edx),%ecx
f01038d1:	89 08                	mov    %ecx,(%eax)
f01038d3:	8b 02                	mov    (%edx),%eax
f01038d5:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01038da:	c9                   	leave  
f01038db:	c3                   	ret    

f01038dc <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f01038dc:	55                   	push   %ebp
f01038dd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01038df:	83 fa 01             	cmp    $0x1,%edx
f01038e2:	7e 0e                	jle    f01038f2 <getint+0x16>
		return va_arg(*ap, long long);
f01038e4:	8b 10                	mov    (%eax),%edx
f01038e6:	8d 4a 08             	lea    0x8(%edx),%ecx
f01038e9:	89 08                	mov    %ecx,(%eax)
f01038eb:	8b 02                	mov    (%edx),%eax
f01038ed:	8b 52 04             	mov    0x4(%edx),%edx
f01038f0:	eb 1a                	jmp    f010390c <getint+0x30>
	else if (lflag)
f01038f2:	85 d2                	test   %edx,%edx
f01038f4:	74 0c                	je     f0103902 <getint+0x26>
		return va_arg(*ap, long);
f01038f6:	8b 10                	mov    (%eax),%edx
f01038f8:	8d 4a 04             	lea    0x4(%edx),%ecx
f01038fb:	89 08                	mov    %ecx,(%eax)
f01038fd:	8b 02                	mov    (%edx),%eax
f01038ff:	99                   	cltd   
f0103900:	eb 0a                	jmp    f010390c <getint+0x30>
	else
		return va_arg(*ap, int);
f0103902:	8b 10                	mov    (%eax),%edx
f0103904:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103907:	89 08                	mov    %ecx,(%eax)
f0103909:	8b 02                	mov    (%edx),%eax
f010390b:	99                   	cltd   
}
f010390c:	c9                   	leave  
f010390d:	c3                   	ret    

f010390e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010390e:	55                   	push   %ebp
f010390f:	89 e5                	mov    %esp,%ebp
f0103911:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103914:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103917:	8b 10                	mov    (%eax),%edx
f0103919:	3b 50 04             	cmp    0x4(%eax),%edx
f010391c:	73 08                	jae    f0103926 <sprintputch+0x18>
		*b->buf++ = ch;
f010391e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103921:	88 0a                	mov    %cl,(%edx)
f0103923:	42                   	inc    %edx
f0103924:	89 10                	mov    %edx,(%eax)
}
f0103926:	c9                   	leave  
f0103927:	c3                   	ret    

f0103928 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103928:	55                   	push   %ebp
f0103929:	89 e5                	mov    %esp,%ebp
f010392b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010392e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103931:	50                   	push   %eax
f0103932:	ff 75 10             	pushl  0x10(%ebp)
f0103935:	ff 75 0c             	pushl  0xc(%ebp)
f0103938:	ff 75 08             	pushl  0x8(%ebp)
f010393b:	e8 05 00 00 00       	call   f0103945 <vprintfmt>
	va_end(ap);
f0103940:	83 c4 10             	add    $0x10,%esp
}
f0103943:	c9                   	leave  
f0103944:	c3                   	ret    

f0103945 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103945:	55                   	push   %ebp
f0103946:	89 e5                	mov    %esp,%ebp
f0103948:	57                   	push   %edi
f0103949:	56                   	push   %esi
f010394a:	53                   	push   %ebx
f010394b:	83 ec 2c             	sub    $0x2c,%esp
f010394e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103951:	8b 75 10             	mov    0x10(%ebp),%esi
f0103954:	eb 13                	jmp    f0103969 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103956:	85 c0                	test   %eax,%eax
f0103958:	0f 84 6d 03 00 00    	je     f0103ccb <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f010395e:	83 ec 08             	sub    $0x8,%esp
f0103961:	57                   	push   %edi
f0103962:	50                   	push   %eax
f0103963:	ff 55 08             	call   *0x8(%ebp)
f0103966:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103969:	0f b6 06             	movzbl (%esi),%eax
f010396c:	46                   	inc    %esi
f010396d:	83 f8 25             	cmp    $0x25,%eax
f0103970:	75 e4                	jne    f0103956 <vprintfmt+0x11>
f0103972:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0103976:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010397d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0103984:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f010398b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103990:	eb 28                	jmp    f01039ba <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103992:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103994:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0103998:	eb 20                	jmp    f01039ba <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010399a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010399c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f01039a0:	eb 18                	jmp    f01039ba <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039a2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01039a4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01039ab:	eb 0d                	jmp    f01039ba <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01039ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01039b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01039b3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039ba:	8a 06                	mov    (%esi),%al
f01039bc:	0f b6 d0             	movzbl %al,%edx
f01039bf:	8d 5e 01             	lea    0x1(%esi),%ebx
f01039c2:	83 e8 23             	sub    $0x23,%eax
f01039c5:	3c 55                	cmp    $0x55,%al
f01039c7:	0f 87 e0 02 00 00    	ja     f0103cad <vprintfmt+0x368>
f01039cd:	0f b6 c0             	movzbl %al,%eax
f01039d0:	ff 24 85 2c 5d 10 f0 	jmp    *-0xfefa2d4(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01039d7:	83 ea 30             	sub    $0x30,%edx
f01039da:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f01039dd:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f01039e0:	8d 50 d0             	lea    -0x30(%eax),%edx
f01039e3:	83 fa 09             	cmp    $0x9,%edx
f01039e6:	77 44                	ja     f0103a2c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039e8:	89 de                	mov    %ebx,%esi
f01039ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01039ed:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f01039ee:	8d 14 92             	lea    (%edx,%edx,4),%edx
f01039f1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f01039f5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01039f8:	8d 58 d0             	lea    -0x30(%eax),%ebx
f01039fb:	83 fb 09             	cmp    $0x9,%ebx
f01039fe:	76 ed                	jbe    f01039ed <vprintfmt+0xa8>
f0103a00:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103a03:	eb 29                	jmp    f0103a2e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103a05:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a08:	8d 50 04             	lea    0x4(%eax),%edx
f0103a0b:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a0e:	8b 00                	mov    (%eax),%eax
f0103a10:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a13:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103a15:	eb 17                	jmp    f0103a2e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0103a17:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103a1b:	78 85                	js     f01039a2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a1d:	89 de                	mov    %ebx,%esi
f0103a1f:	eb 99                	jmp    f01039ba <vprintfmt+0x75>
f0103a21:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103a23:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0103a2a:	eb 8e                	jmp    f01039ba <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a2c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0103a2e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103a32:	79 86                	jns    f01039ba <vprintfmt+0x75>
f0103a34:	e9 74 ff ff ff       	jmp    f01039ad <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103a39:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a3a:	89 de                	mov    %ebx,%esi
f0103a3c:	e9 79 ff ff ff       	jmp    f01039ba <vprintfmt+0x75>
f0103a41:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103a44:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a47:	8d 50 04             	lea    0x4(%eax),%edx
f0103a4a:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a4d:	83 ec 08             	sub    $0x8,%esp
f0103a50:	57                   	push   %edi
f0103a51:	ff 30                	pushl  (%eax)
f0103a53:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103a56:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a59:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103a5c:	e9 08 ff ff ff       	jmp    f0103969 <vprintfmt+0x24>
f0103a61:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103a64:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a67:	8d 50 04             	lea    0x4(%eax),%edx
f0103a6a:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a6d:	8b 00                	mov    (%eax),%eax
f0103a6f:	85 c0                	test   %eax,%eax
f0103a71:	79 02                	jns    f0103a75 <vprintfmt+0x130>
f0103a73:	f7 d8                	neg    %eax
f0103a75:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103a77:	83 f8 06             	cmp    $0x6,%eax
f0103a7a:	7f 0b                	jg     f0103a87 <vprintfmt+0x142>
f0103a7c:	8b 04 85 84 5e 10 f0 	mov    -0xfefa17c(,%eax,4),%eax
f0103a83:	85 c0                	test   %eax,%eax
f0103a85:	75 1a                	jne    f0103aa1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0103a87:	52                   	push   %edx
f0103a88:	68 b9 5c 10 f0       	push   $0xf0105cb9
f0103a8d:	57                   	push   %edi
f0103a8e:	ff 75 08             	pushl  0x8(%ebp)
f0103a91:	e8 92 fe ff ff       	call   f0103928 <printfmt>
f0103a96:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a99:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103a9c:	e9 c8 fe ff ff       	jmp    f0103969 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0103aa1:	50                   	push   %eax
f0103aa2:	68 ad 55 10 f0       	push   $0xf01055ad
f0103aa7:	57                   	push   %edi
f0103aa8:	ff 75 08             	pushl  0x8(%ebp)
f0103aab:	e8 78 fe ff ff       	call   f0103928 <printfmt>
f0103ab0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ab3:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103ab6:	e9 ae fe ff ff       	jmp    f0103969 <vprintfmt+0x24>
f0103abb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0103abe:	89 de                	mov    %ebx,%esi
f0103ac0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103ac3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103ac6:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ac9:	8d 50 04             	lea    0x4(%eax),%edx
f0103acc:	89 55 14             	mov    %edx,0x14(%ebp)
f0103acf:	8b 00                	mov    (%eax),%eax
f0103ad1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103ad4:	85 c0                	test   %eax,%eax
f0103ad6:	75 07                	jne    f0103adf <vprintfmt+0x19a>
				p = "(null)";
f0103ad8:	c7 45 d0 b2 5c 10 f0 	movl   $0xf0105cb2,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0103adf:	85 db                	test   %ebx,%ebx
f0103ae1:	7e 42                	jle    f0103b25 <vprintfmt+0x1e0>
f0103ae3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0103ae7:	74 3c                	je     f0103b25 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103ae9:	83 ec 08             	sub    $0x8,%esp
f0103aec:	51                   	push   %ecx
f0103aed:	ff 75 d0             	pushl  -0x30(%ebp)
f0103af0:	e8 3f 03 00 00       	call   f0103e34 <strnlen>
f0103af5:	29 c3                	sub    %eax,%ebx
f0103af7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103afa:	83 c4 10             	add    $0x10,%esp
f0103afd:	85 db                	test   %ebx,%ebx
f0103aff:	7e 24                	jle    f0103b25 <vprintfmt+0x1e0>
					putch(padc, putdat);
f0103b01:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0103b05:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103b08:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103b0b:	83 ec 08             	sub    $0x8,%esp
f0103b0e:	57                   	push   %edi
f0103b0f:	53                   	push   %ebx
f0103b10:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103b13:	4e                   	dec    %esi
f0103b14:	83 c4 10             	add    $0x10,%esp
f0103b17:	85 f6                	test   %esi,%esi
f0103b19:	7f f0                	jg     f0103b0b <vprintfmt+0x1c6>
f0103b1b:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103b1e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103b25:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103b28:	0f be 02             	movsbl (%edx),%eax
f0103b2b:	85 c0                	test   %eax,%eax
f0103b2d:	75 47                	jne    f0103b76 <vprintfmt+0x231>
f0103b2f:	eb 37                	jmp    f0103b68 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f0103b31:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103b35:	74 16                	je     f0103b4d <vprintfmt+0x208>
f0103b37:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103b3a:	83 fa 5e             	cmp    $0x5e,%edx
f0103b3d:	76 0e                	jbe    f0103b4d <vprintfmt+0x208>
					putch('?', putdat);
f0103b3f:	83 ec 08             	sub    $0x8,%esp
f0103b42:	57                   	push   %edi
f0103b43:	6a 3f                	push   $0x3f
f0103b45:	ff 55 08             	call   *0x8(%ebp)
f0103b48:	83 c4 10             	add    $0x10,%esp
f0103b4b:	eb 0b                	jmp    f0103b58 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f0103b4d:	83 ec 08             	sub    $0x8,%esp
f0103b50:	57                   	push   %edi
f0103b51:	50                   	push   %eax
f0103b52:	ff 55 08             	call   *0x8(%ebp)
f0103b55:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103b58:	ff 4d e4             	decl   -0x1c(%ebp)
f0103b5b:	0f be 03             	movsbl (%ebx),%eax
f0103b5e:	85 c0                	test   %eax,%eax
f0103b60:	74 03                	je     f0103b65 <vprintfmt+0x220>
f0103b62:	43                   	inc    %ebx
f0103b63:	eb 1b                	jmp    f0103b80 <vprintfmt+0x23b>
f0103b65:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103b68:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103b6c:	7f 1e                	jg     f0103b8c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103b6e:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103b71:	e9 f3 fd ff ff       	jmp    f0103969 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103b76:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103b79:	43                   	inc    %ebx
f0103b7a:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103b7d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103b80:	85 f6                	test   %esi,%esi
f0103b82:	78 ad                	js     f0103b31 <vprintfmt+0x1ec>
f0103b84:	4e                   	dec    %esi
f0103b85:	79 aa                	jns    f0103b31 <vprintfmt+0x1ec>
f0103b87:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103b8a:	eb dc                	jmp    f0103b68 <vprintfmt+0x223>
f0103b8c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103b8f:	83 ec 08             	sub    $0x8,%esp
f0103b92:	57                   	push   %edi
f0103b93:	6a 20                	push   $0x20
f0103b95:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103b98:	4b                   	dec    %ebx
f0103b99:	83 c4 10             	add    $0x10,%esp
f0103b9c:	85 db                	test   %ebx,%ebx
f0103b9e:	7f ef                	jg     f0103b8f <vprintfmt+0x24a>
f0103ba0:	e9 c4 fd ff ff       	jmp    f0103969 <vprintfmt+0x24>
f0103ba5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103ba8:	89 ca                	mov    %ecx,%edx
f0103baa:	8d 45 14             	lea    0x14(%ebp),%eax
f0103bad:	e8 2a fd ff ff       	call   f01038dc <getint>
f0103bb2:	89 c3                	mov    %eax,%ebx
f0103bb4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0103bb6:	85 d2                	test   %edx,%edx
f0103bb8:	78 0a                	js     f0103bc4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103bba:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103bbf:	e9 b0 00 00 00       	jmp    f0103c74 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0103bc4:	83 ec 08             	sub    $0x8,%esp
f0103bc7:	57                   	push   %edi
f0103bc8:	6a 2d                	push   $0x2d
f0103bca:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103bcd:	f7 db                	neg    %ebx
f0103bcf:	83 d6 00             	adc    $0x0,%esi
f0103bd2:	f7 de                	neg    %esi
f0103bd4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103bd7:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103bdc:	e9 93 00 00 00       	jmp    f0103c74 <vprintfmt+0x32f>
f0103be1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103be4:	89 ca                	mov    %ecx,%edx
f0103be6:	8d 45 14             	lea    0x14(%ebp),%eax
f0103be9:	e8 b4 fc ff ff       	call   f01038a2 <getuint>
f0103bee:	89 c3                	mov    %eax,%ebx
f0103bf0:	89 d6                	mov    %edx,%esi
			base = 10;
f0103bf2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0103bf7:	eb 7b                	jmp    f0103c74 <vprintfmt+0x32f>
f0103bf9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0103bfc:	89 ca                	mov    %ecx,%edx
f0103bfe:	8d 45 14             	lea    0x14(%ebp),%eax
f0103c01:	e8 d6 fc ff ff       	call   f01038dc <getint>
f0103c06:	89 c3                	mov    %eax,%ebx
f0103c08:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f0103c0a:	85 d2                	test   %edx,%edx
f0103c0c:	78 07                	js     f0103c15 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f0103c0e:	b8 08 00 00 00       	mov    $0x8,%eax
f0103c13:	eb 5f                	jmp    f0103c74 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0103c15:	83 ec 08             	sub    $0x8,%esp
f0103c18:	57                   	push   %edi
f0103c19:	6a 2d                	push   $0x2d
f0103c1b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f0103c1e:	f7 db                	neg    %ebx
f0103c20:	83 d6 00             	adc    $0x0,%esi
f0103c23:	f7 de                	neg    %esi
f0103c25:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f0103c28:	b8 08 00 00 00       	mov    $0x8,%eax
f0103c2d:	eb 45                	jmp    f0103c74 <vprintfmt+0x32f>
f0103c2f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f0103c32:	83 ec 08             	sub    $0x8,%esp
f0103c35:	57                   	push   %edi
f0103c36:	6a 30                	push   $0x30
f0103c38:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103c3b:	83 c4 08             	add    $0x8,%esp
f0103c3e:	57                   	push   %edi
f0103c3f:	6a 78                	push   $0x78
f0103c41:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103c44:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c47:	8d 50 04             	lea    0x4(%eax),%edx
f0103c4a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103c4d:	8b 18                	mov    (%eax),%ebx
f0103c4f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103c54:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103c57:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103c5c:	eb 16                	jmp    f0103c74 <vprintfmt+0x32f>
f0103c5e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103c61:	89 ca                	mov    %ecx,%edx
f0103c63:	8d 45 14             	lea    0x14(%ebp),%eax
f0103c66:	e8 37 fc ff ff       	call   f01038a2 <getuint>
f0103c6b:	89 c3                	mov    %eax,%ebx
f0103c6d:	89 d6                	mov    %edx,%esi
			base = 16;
f0103c6f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103c74:	83 ec 0c             	sub    $0xc,%esp
f0103c77:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0103c7b:	52                   	push   %edx
f0103c7c:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103c7f:	50                   	push   %eax
f0103c80:	56                   	push   %esi
f0103c81:	53                   	push   %ebx
f0103c82:	89 fa                	mov    %edi,%edx
f0103c84:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c87:	e8 68 fb ff ff       	call   f01037f4 <printnum>
			break;
f0103c8c:	83 c4 20             	add    $0x20,%esp
f0103c8f:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103c92:	e9 d2 fc ff ff       	jmp    f0103969 <vprintfmt+0x24>
f0103c97:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103c9a:	83 ec 08             	sub    $0x8,%esp
f0103c9d:	57                   	push   %edi
f0103c9e:	52                   	push   %edx
f0103c9f:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103ca2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ca5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103ca8:	e9 bc fc ff ff       	jmp    f0103969 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103cad:	83 ec 08             	sub    $0x8,%esp
f0103cb0:	57                   	push   %edi
f0103cb1:	6a 25                	push   $0x25
f0103cb3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103cb6:	83 c4 10             	add    $0x10,%esp
f0103cb9:	eb 02                	jmp    f0103cbd <vprintfmt+0x378>
f0103cbb:	89 c6                	mov    %eax,%esi
f0103cbd:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103cc0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103cc4:	75 f5                	jne    f0103cbb <vprintfmt+0x376>
f0103cc6:	e9 9e fc ff ff       	jmp    f0103969 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0103ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103cce:	5b                   	pop    %ebx
f0103ccf:	5e                   	pop    %esi
f0103cd0:	5f                   	pop    %edi
f0103cd1:	c9                   	leave  
f0103cd2:	c3                   	ret    

f0103cd3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103cd3:	55                   	push   %ebp
f0103cd4:	89 e5                	mov    %esp,%ebp
f0103cd6:	83 ec 18             	sub    $0x18,%esp
f0103cd9:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cdc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103cdf:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ce2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103ce6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103ce9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103cf0:	85 c0                	test   %eax,%eax
f0103cf2:	74 26                	je     f0103d1a <vsnprintf+0x47>
f0103cf4:	85 d2                	test   %edx,%edx
f0103cf6:	7e 29                	jle    f0103d21 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103cf8:	ff 75 14             	pushl  0x14(%ebp)
f0103cfb:	ff 75 10             	pushl  0x10(%ebp)
f0103cfe:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103d01:	50                   	push   %eax
f0103d02:	68 0e 39 10 f0       	push   $0xf010390e
f0103d07:	e8 39 fc ff ff       	call   f0103945 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103d0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103d0f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d15:	83 c4 10             	add    $0x10,%esp
f0103d18:	eb 0c                	jmp    f0103d26 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103d1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103d1f:	eb 05                	jmp    f0103d26 <vsnprintf+0x53>
f0103d21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103d26:	c9                   	leave  
f0103d27:	c3                   	ret    

f0103d28 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103d28:	55                   	push   %ebp
f0103d29:	89 e5                	mov    %esp,%ebp
f0103d2b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103d2e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103d31:	50                   	push   %eax
f0103d32:	ff 75 10             	pushl  0x10(%ebp)
f0103d35:	ff 75 0c             	pushl  0xc(%ebp)
f0103d38:	ff 75 08             	pushl  0x8(%ebp)
f0103d3b:	e8 93 ff ff ff       	call   f0103cd3 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103d40:	c9                   	leave  
f0103d41:	c3                   	ret    
	...

f0103d44 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103d44:	55                   	push   %ebp
f0103d45:	89 e5                	mov    %esp,%ebp
f0103d47:	57                   	push   %edi
f0103d48:	56                   	push   %esi
f0103d49:	53                   	push   %ebx
f0103d4a:	83 ec 0c             	sub    $0xc,%esp
f0103d4d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103d50:	85 c0                	test   %eax,%eax
f0103d52:	74 11                	je     f0103d65 <readline+0x21>
		cprintf("%s", prompt);
f0103d54:	83 ec 08             	sub    $0x8,%esp
f0103d57:	50                   	push   %eax
f0103d58:	68 ad 55 10 f0       	push   $0xf01055ad
f0103d5d:	e8 ab f3 ff ff       	call   f010310d <cprintf>
f0103d62:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103d65:	83 ec 0c             	sub    $0xc,%esp
f0103d68:	6a 00                	push   $0x0
f0103d6a:	e8 74 c8 ff ff       	call   f01005e3 <iscons>
f0103d6f:	89 c7                	mov    %eax,%edi
f0103d71:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103d74:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103d79:	e8 54 c8 ff ff       	call   f01005d2 <getchar>
f0103d7e:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103d80:	85 c0                	test   %eax,%eax
f0103d82:	79 18                	jns    f0103d9c <readline+0x58>
			cprintf("read error: %e\n", c);
f0103d84:	83 ec 08             	sub    $0x8,%esp
f0103d87:	50                   	push   %eax
f0103d88:	68 a0 5e 10 f0       	push   $0xf0105ea0
f0103d8d:	e8 7b f3 ff ff       	call   f010310d <cprintf>
			return NULL;
f0103d92:	83 c4 10             	add    $0x10,%esp
f0103d95:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d9a:	eb 6f                	jmp    f0103e0b <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103d9c:	83 f8 08             	cmp    $0x8,%eax
f0103d9f:	74 05                	je     f0103da6 <readline+0x62>
f0103da1:	83 f8 7f             	cmp    $0x7f,%eax
f0103da4:	75 18                	jne    f0103dbe <readline+0x7a>
f0103da6:	85 f6                	test   %esi,%esi
f0103da8:	7e 14                	jle    f0103dbe <readline+0x7a>
			if (echoing)
f0103daa:	85 ff                	test   %edi,%edi
f0103dac:	74 0d                	je     f0103dbb <readline+0x77>
				cputchar('\b');
f0103dae:	83 ec 0c             	sub    $0xc,%esp
f0103db1:	6a 08                	push   $0x8
f0103db3:	e8 0a c8 ff ff       	call   f01005c2 <cputchar>
f0103db8:	83 c4 10             	add    $0x10,%esp
			i--;
f0103dbb:	4e                   	dec    %esi
f0103dbc:	eb bb                	jmp    f0103d79 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103dbe:	83 fb 1f             	cmp    $0x1f,%ebx
f0103dc1:	7e 21                	jle    f0103de4 <readline+0xa0>
f0103dc3:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103dc9:	7f 19                	jg     f0103de4 <readline+0xa0>
			if (echoing)
f0103dcb:	85 ff                	test   %edi,%edi
f0103dcd:	74 0c                	je     f0103ddb <readline+0x97>
				cputchar(c);
f0103dcf:	83 ec 0c             	sub    $0xc,%esp
f0103dd2:	53                   	push   %ebx
f0103dd3:	e8 ea c7 ff ff       	call   f01005c2 <cputchar>
f0103dd8:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103ddb:	88 9e 80 6b 1d f0    	mov    %bl,-0xfe29480(%esi)
f0103de1:	46                   	inc    %esi
f0103de2:	eb 95                	jmp    f0103d79 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103de4:	83 fb 0a             	cmp    $0xa,%ebx
f0103de7:	74 05                	je     f0103dee <readline+0xaa>
f0103de9:	83 fb 0d             	cmp    $0xd,%ebx
f0103dec:	75 8b                	jne    f0103d79 <readline+0x35>
			if (echoing)
f0103dee:	85 ff                	test   %edi,%edi
f0103df0:	74 0d                	je     f0103dff <readline+0xbb>
				cputchar('\n');
f0103df2:	83 ec 0c             	sub    $0xc,%esp
f0103df5:	6a 0a                	push   $0xa
f0103df7:	e8 c6 c7 ff ff       	call   f01005c2 <cputchar>
f0103dfc:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103dff:	c6 86 80 6b 1d f0 00 	movb   $0x0,-0xfe29480(%esi)
			return buf;
f0103e06:	b8 80 6b 1d f0       	mov    $0xf01d6b80,%eax
		}
	}
}
f0103e0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e0e:	5b                   	pop    %ebx
f0103e0f:	5e                   	pop    %esi
f0103e10:	5f                   	pop    %edi
f0103e11:	c9                   	leave  
f0103e12:	c3                   	ret    
	...

f0103e14 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103e14:	55                   	push   %ebp
f0103e15:	89 e5                	mov    %esp,%ebp
f0103e17:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103e1a:	80 3a 00             	cmpb   $0x0,(%edx)
f0103e1d:	74 0e                	je     f0103e2d <strlen+0x19>
f0103e1f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0103e24:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103e25:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103e29:	75 f9                	jne    f0103e24 <strlen+0x10>
f0103e2b:	eb 05                	jmp    f0103e32 <strlen+0x1e>
f0103e2d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0103e32:	c9                   	leave  
f0103e33:	c3                   	ret    

f0103e34 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103e34:	55                   	push   %ebp
f0103e35:	89 e5                	mov    %esp,%ebp
f0103e37:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103e3a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103e3d:	85 d2                	test   %edx,%edx
f0103e3f:	74 17                	je     f0103e58 <strnlen+0x24>
f0103e41:	80 39 00             	cmpb   $0x0,(%ecx)
f0103e44:	74 19                	je     f0103e5f <strnlen+0x2b>
f0103e46:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0103e4b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103e4c:	39 d0                	cmp    %edx,%eax
f0103e4e:	74 14                	je     f0103e64 <strnlen+0x30>
f0103e50:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103e54:	75 f5                	jne    f0103e4b <strnlen+0x17>
f0103e56:	eb 0c                	jmp    f0103e64 <strnlen+0x30>
f0103e58:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e5d:	eb 05                	jmp    f0103e64 <strnlen+0x30>
f0103e5f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0103e64:	c9                   	leave  
f0103e65:	c3                   	ret    

f0103e66 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103e66:	55                   	push   %ebp
f0103e67:	89 e5                	mov    %esp,%ebp
f0103e69:	53                   	push   %ebx
f0103e6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103e70:	ba 00 00 00 00       	mov    $0x0,%edx
f0103e75:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0103e78:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103e7b:	42                   	inc    %edx
f0103e7c:	84 c9                	test   %cl,%cl
f0103e7e:	75 f5                	jne    f0103e75 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103e80:	5b                   	pop    %ebx
f0103e81:	c9                   	leave  
f0103e82:	c3                   	ret    

f0103e83 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103e83:	55                   	push   %ebp
f0103e84:	89 e5                	mov    %esp,%ebp
f0103e86:	53                   	push   %ebx
f0103e87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103e8a:	53                   	push   %ebx
f0103e8b:	e8 84 ff ff ff       	call   f0103e14 <strlen>
f0103e90:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103e93:	ff 75 0c             	pushl  0xc(%ebp)
f0103e96:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0103e99:	50                   	push   %eax
f0103e9a:	e8 c7 ff ff ff       	call   f0103e66 <strcpy>
	return dst;
}
f0103e9f:	89 d8                	mov    %ebx,%eax
f0103ea1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ea4:	c9                   	leave  
f0103ea5:	c3                   	ret    

f0103ea6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103ea6:	55                   	push   %ebp
f0103ea7:	89 e5                	mov    %esp,%ebp
f0103ea9:	56                   	push   %esi
f0103eaa:	53                   	push   %ebx
f0103eab:	8b 45 08             	mov    0x8(%ebp),%eax
f0103eae:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103eb1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103eb4:	85 f6                	test   %esi,%esi
f0103eb6:	74 15                	je     f0103ecd <strncpy+0x27>
f0103eb8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103ebd:	8a 1a                	mov    (%edx),%bl
f0103ebf:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103ec2:	80 3a 01             	cmpb   $0x1,(%edx)
f0103ec5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103ec8:	41                   	inc    %ecx
f0103ec9:	39 ce                	cmp    %ecx,%esi
f0103ecb:	77 f0                	ja     f0103ebd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103ecd:	5b                   	pop    %ebx
f0103ece:	5e                   	pop    %esi
f0103ecf:	c9                   	leave  
f0103ed0:	c3                   	ret    

f0103ed1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103ed1:	55                   	push   %ebp
f0103ed2:	89 e5                	mov    %esp,%ebp
f0103ed4:	57                   	push   %edi
f0103ed5:	56                   	push   %esi
f0103ed6:	53                   	push   %ebx
f0103ed7:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103eda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103edd:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103ee0:	85 f6                	test   %esi,%esi
f0103ee2:	74 32                	je     f0103f16 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0103ee4:	83 fe 01             	cmp    $0x1,%esi
f0103ee7:	74 22                	je     f0103f0b <strlcpy+0x3a>
f0103ee9:	8a 0b                	mov    (%ebx),%cl
f0103eeb:	84 c9                	test   %cl,%cl
f0103eed:	74 20                	je     f0103f0f <strlcpy+0x3e>
f0103eef:	89 f8                	mov    %edi,%eax
f0103ef1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0103ef6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103ef9:	88 08                	mov    %cl,(%eax)
f0103efb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103efc:	39 f2                	cmp    %esi,%edx
f0103efe:	74 11                	je     f0103f11 <strlcpy+0x40>
f0103f00:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0103f04:	42                   	inc    %edx
f0103f05:	84 c9                	test   %cl,%cl
f0103f07:	75 f0                	jne    f0103ef9 <strlcpy+0x28>
f0103f09:	eb 06                	jmp    f0103f11 <strlcpy+0x40>
f0103f0b:	89 f8                	mov    %edi,%eax
f0103f0d:	eb 02                	jmp    f0103f11 <strlcpy+0x40>
f0103f0f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103f11:	c6 00 00             	movb   $0x0,(%eax)
f0103f14:	eb 02                	jmp    f0103f18 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103f16:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0103f18:	29 f8                	sub    %edi,%eax
}
f0103f1a:	5b                   	pop    %ebx
f0103f1b:	5e                   	pop    %esi
f0103f1c:	5f                   	pop    %edi
f0103f1d:	c9                   	leave  
f0103f1e:	c3                   	ret    

f0103f1f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103f1f:	55                   	push   %ebp
f0103f20:	89 e5                	mov    %esp,%ebp
f0103f22:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103f25:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103f28:	8a 01                	mov    (%ecx),%al
f0103f2a:	84 c0                	test   %al,%al
f0103f2c:	74 10                	je     f0103f3e <strcmp+0x1f>
f0103f2e:	3a 02                	cmp    (%edx),%al
f0103f30:	75 0c                	jne    f0103f3e <strcmp+0x1f>
		p++, q++;
f0103f32:	41                   	inc    %ecx
f0103f33:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103f34:	8a 01                	mov    (%ecx),%al
f0103f36:	84 c0                	test   %al,%al
f0103f38:	74 04                	je     f0103f3e <strcmp+0x1f>
f0103f3a:	3a 02                	cmp    (%edx),%al
f0103f3c:	74 f4                	je     f0103f32 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103f3e:	0f b6 c0             	movzbl %al,%eax
f0103f41:	0f b6 12             	movzbl (%edx),%edx
f0103f44:	29 d0                	sub    %edx,%eax
}
f0103f46:	c9                   	leave  
f0103f47:	c3                   	ret    

f0103f48 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103f48:	55                   	push   %ebp
f0103f49:	89 e5                	mov    %esp,%ebp
f0103f4b:	53                   	push   %ebx
f0103f4c:	8b 55 08             	mov    0x8(%ebp),%edx
f0103f4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103f52:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0103f55:	85 c0                	test   %eax,%eax
f0103f57:	74 1b                	je     f0103f74 <strncmp+0x2c>
f0103f59:	8a 1a                	mov    (%edx),%bl
f0103f5b:	84 db                	test   %bl,%bl
f0103f5d:	74 24                	je     f0103f83 <strncmp+0x3b>
f0103f5f:	3a 19                	cmp    (%ecx),%bl
f0103f61:	75 20                	jne    f0103f83 <strncmp+0x3b>
f0103f63:	48                   	dec    %eax
f0103f64:	74 15                	je     f0103f7b <strncmp+0x33>
		n--, p++, q++;
f0103f66:	42                   	inc    %edx
f0103f67:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103f68:	8a 1a                	mov    (%edx),%bl
f0103f6a:	84 db                	test   %bl,%bl
f0103f6c:	74 15                	je     f0103f83 <strncmp+0x3b>
f0103f6e:	3a 19                	cmp    (%ecx),%bl
f0103f70:	74 f1                	je     f0103f63 <strncmp+0x1b>
f0103f72:	eb 0f                	jmp    f0103f83 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103f74:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f79:	eb 05                	jmp    f0103f80 <strncmp+0x38>
f0103f7b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103f80:	5b                   	pop    %ebx
f0103f81:	c9                   	leave  
f0103f82:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103f83:	0f b6 02             	movzbl (%edx),%eax
f0103f86:	0f b6 11             	movzbl (%ecx),%edx
f0103f89:	29 d0                	sub    %edx,%eax
f0103f8b:	eb f3                	jmp    f0103f80 <strncmp+0x38>

f0103f8d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103f8d:	55                   	push   %ebp
f0103f8e:	89 e5                	mov    %esp,%ebp
f0103f90:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f93:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103f96:	8a 10                	mov    (%eax),%dl
f0103f98:	84 d2                	test   %dl,%dl
f0103f9a:	74 18                	je     f0103fb4 <strchr+0x27>
		if (*s == c)
f0103f9c:	38 ca                	cmp    %cl,%dl
f0103f9e:	75 06                	jne    f0103fa6 <strchr+0x19>
f0103fa0:	eb 17                	jmp    f0103fb9 <strchr+0x2c>
f0103fa2:	38 ca                	cmp    %cl,%dl
f0103fa4:	74 13                	je     f0103fb9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103fa6:	40                   	inc    %eax
f0103fa7:	8a 10                	mov    (%eax),%dl
f0103fa9:	84 d2                	test   %dl,%dl
f0103fab:	75 f5                	jne    f0103fa2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0103fad:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fb2:	eb 05                	jmp    f0103fb9 <strchr+0x2c>
f0103fb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103fb9:	c9                   	leave  
f0103fba:	c3                   	ret    

f0103fbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103fbb:	55                   	push   %ebp
f0103fbc:	89 e5                	mov    %esp,%ebp
f0103fbe:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fc1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103fc4:	8a 10                	mov    (%eax),%dl
f0103fc6:	84 d2                	test   %dl,%dl
f0103fc8:	74 11                	je     f0103fdb <strfind+0x20>
		if (*s == c)
f0103fca:	38 ca                	cmp    %cl,%dl
f0103fcc:	75 06                	jne    f0103fd4 <strfind+0x19>
f0103fce:	eb 0b                	jmp    f0103fdb <strfind+0x20>
f0103fd0:	38 ca                	cmp    %cl,%dl
f0103fd2:	74 07                	je     f0103fdb <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103fd4:	40                   	inc    %eax
f0103fd5:	8a 10                	mov    (%eax),%dl
f0103fd7:	84 d2                	test   %dl,%dl
f0103fd9:	75 f5                	jne    f0103fd0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f0103fdb:	c9                   	leave  
f0103fdc:	c3                   	ret    

f0103fdd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103fdd:	55                   	push   %ebp
f0103fde:	89 e5                	mov    %esp,%ebp
f0103fe0:	57                   	push   %edi
f0103fe1:	56                   	push   %esi
f0103fe2:	53                   	push   %ebx
f0103fe3:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103fe9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103fec:	85 c9                	test   %ecx,%ecx
f0103fee:	74 30                	je     f0104020 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103ff0:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103ff6:	75 25                	jne    f010401d <memset+0x40>
f0103ff8:	f6 c1 03             	test   $0x3,%cl
f0103ffb:	75 20                	jne    f010401d <memset+0x40>
		c &= 0xFF;
f0103ffd:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104000:	89 d3                	mov    %edx,%ebx
f0104002:	c1 e3 08             	shl    $0x8,%ebx
f0104005:	89 d6                	mov    %edx,%esi
f0104007:	c1 e6 18             	shl    $0x18,%esi
f010400a:	89 d0                	mov    %edx,%eax
f010400c:	c1 e0 10             	shl    $0x10,%eax
f010400f:	09 f0                	or     %esi,%eax
f0104011:	09 d0                	or     %edx,%eax
f0104013:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104015:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104018:	fc                   	cld    
f0104019:	f3 ab                	rep stos %eax,%es:(%edi)
f010401b:	eb 03                	jmp    f0104020 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010401d:	fc                   	cld    
f010401e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104020:	89 f8                	mov    %edi,%eax
f0104022:	5b                   	pop    %ebx
f0104023:	5e                   	pop    %esi
f0104024:	5f                   	pop    %edi
f0104025:	c9                   	leave  
f0104026:	c3                   	ret    

f0104027 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104027:	55                   	push   %ebp
f0104028:	89 e5                	mov    %esp,%ebp
f010402a:	57                   	push   %edi
f010402b:	56                   	push   %esi
f010402c:	8b 45 08             	mov    0x8(%ebp),%eax
f010402f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104032:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104035:	39 c6                	cmp    %eax,%esi
f0104037:	73 34                	jae    f010406d <memmove+0x46>
f0104039:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010403c:	39 d0                	cmp    %edx,%eax
f010403e:	73 2d                	jae    f010406d <memmove+0x46>
		s += n;
		d += n;
f0104040:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104043:	f6 c2 03             	test   $0x3,%dl
f0104046:	75 1b                	jne    f0104063 <memmove+0x3c>
f0104048:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010404e:	75 13                	jne    f0104063 <memmove+0x3c>
f0104050:	f6 c1 03             	test   $0x3,%cl
f0104053:	75 0e                	jne    f0104063 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104055:	83 ef 04             	sub    $0x4,%edi
f0104058:	8d 72 fc             	lea    -0x4(%edx),%esi
f010405b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010405e:	fd                   	std    
f010405f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104061:	eb 07                	jmp    f010406a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104063:	4f                   	dec    %edi
f0104064:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104067:	fd                   	std    
f0104068:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010406a:	fc                   	cld    
f010406b:	eb 20                	jmp    f010408d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010406d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104073:	75 13                	jne    f0104088 <memmove+0x61>
f0104075:	a8 03                	test   $0x3,%al
f0104077:	75 0f                	jne    f0104088 <memmove+0x61>
f0104079:	f6 c1 03             	test   $0x3,%cl
f010407c:	75 0a                	jne    f0104088 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010407e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104081:	89 c7                	mov    %eax,%edi
f0104083:	fc                   	cld    
f0104084:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104086:	eb 05                	jmp    f010408d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104088:	89 c7                	mov    %eax,%edi
f010408a:	fc                   	cld    
f010408b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010408d:	5e                   	pop    %esi
f010408e:	5f                   	pop    %edi
f010408f:	c9                   	leave  
f0104090:	c3                   	ret    

f0104091 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104091:	55                   	push   %ebp
f0104092:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104094:	ff 75 10             	pushl  0x10(%ebp)
f0104097:	ff 75 0c             	pushl  0xc(%ebp)
f010409a:	ff 75 08             	pushl  0x8(%ebp)
f010409d:	e8 85 ff ff ff       	call   f0104027 <memmove>
}
f01040a2:	c9                   	leave  
f01040a3:	c3                   	ret    

f01040a4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01040a4:	55                   	push   %ebp
f01040a5:	89 e5                	mov    %esp,%ebp
f01040a7:	57                   	push   %edi
f01040a8:	56                   	push   %esi
f01040a9:	53                   	push   %ebx
f01040aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01040ad:	8b 75 0c             	mov    0xc(%ebp),%esi
f01040b0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01040b3:	85 ff                	test   %edi,%edi
f01040b5:	74 32                	je     f01040e9 <memcmp+0x45>
		if (*s1 != *s2)
f01040b7:	8a 03                	mov    (%ebx),%al
f01040b9:	8a 0e                	mov    (%esi),%cl
f01040bb:	38 c8                	cmp    %cl,%al
f01040bd:	74 19                	je     f01040d8 <memcmp+0x34>
f01040bf:	eb 0d                	jmp    f01040ce <memcmp+0x2a>
f01040c1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f01040c5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f01040c9:	42                   	inc    %edx
f01040ca:	38 c8                	cmp    %cl,%al
f01040cc:	74 10                	je     f01040de <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f01040ce:	0f b6 c0             	movzbl %al,%eax
f01040d1:	0f b6 c9             	movzbl %cl,%ecx
f01040d4:	29 c8                	sub    %ecx,%eax
f01040d6:	eb 16                	jmp    f01040ee <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01040d8:	4f                   	dec    %edi
f01040d9:	ba 00 00 00 00       	mov    $0x0,%edx
f01040de:	39 fa                	cmp    %edi,%edx
f01040e0:	75 df                	jne    f01040c1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01040e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01040e7:	eb 05                	jmp    f01040ee <memcmp+0x4a>
f01040e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01040ee:	5b                   	pop    %ebx
f01040ef:	5e                   	pop    %esi
f01040f0:	5f                   	pop    %edi
f01040f1:	c9                   	leave  
f01040f2:	c3                   	ret    

f01040f3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01040f3:	55                   	push   %ebp
f01040f4:	89 e5                	mov    %esp,%ebp
f01040f6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01040f9:	89 c2                	mov    %eax,%edx
f01040fb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01040fe:	39 d0                	cmp    %edx,%eax
f0104100:	73 12                	jae    f0104114 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104102:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0104105:	38 08                	cmp    %cl,(%eax)
f0104107:	75 06                	jne    f010410f <memfind+0x1c>
f0104109:	eb 09                	jmp    f0104114 <memfind+0x21>
f010410b:	38 08                	cmp    %cl,(%eax)
f010410d:	74 05                	je     f0104114 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010410f:	40                   	inc    %eax
f0104110:	39 c2                	cmp    %eax,%edx
f0104112:	77 f7                	ja     f010410b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104114:	c9                   	leave  
f0104115:	c3                   	ret    

f0104116 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104116:	55                   	push   %ebp
f0104117:	89 e5                	mov    %esp,%ebp
f0104119:	57                   	push   %edi
f010411a:	56                   	push   %esi
f010411b:	53                   	push   %ebx
f010411c:	8b 55 08             	mov    0x8(%ebp),%edx
f010411f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104122:	eb 01                	jmp    f0104125 <strtol+0xf>
		s++;
f0104124:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104125:	8a 02                	mov    (%edx),%al
f0104127:	3c 20                	cmp    $0x20,%al
f0104129:	74 f9                	je     f0104124 <strtol+0xe>
f010412b:	3c 09                	cmp    $0x9,%al
f010412d:	74 f5                	je     f0104124 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010412f:	3c 2b                	cmp    $0x2b,%al
f0104131:	75 08                	jne    f010413b <strtol+0x25>
		s++;
f0104133:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104134:	bf 00 00 00 00       	mov    $0x0,%edi
f0104139:	eb 13                	jmp    f010414e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010413b:	3c 2d                	cmp    $0x2d,%al
f010413d:	75 0a                	jne    f0104149 <strtol+0x33>
		s++, neg = 1;
f010413f:	8d 52 01             	lea    0x1(%edx),%edx
f0104142:	bf 01 00 00 00       	mov    $0x1,%edi
f0104147:	eb 05                	jmp    f010414e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104149:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010414e:	85 db                	test   %ebx,%ebx
f0104150:	74 05                	je     f0104157 <strtol+0x41>
f0104152:	83 fb 10             	cmp    $0x10,%ebx
f0104155:	75 28                	jne    f010417f <strtol+0x69>
f0104157:	8a 02                	mov    (%edx),%al
f0104159:	3c 30                	cmp    $0x30,%al
f010415b:	75 10                	jne    f010416d <strtol+0x57>
f010415d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104161:	75 0a                	jne    f010416d <strtol+0x57>
		s += 2, base = 16;
f0104163:	83 c2 02             	add    $0x2,%edx
f0104166:	bb 10 00 00 00       	mov    $0x10,%ebx
f010416b:	eb 12                	jmp    f010417f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f010416d:	85 db                	test   %ebx,%ebx
f010416f:	75 0e                	jne    f010417f <strtol+0x69>
f0104171:	3c 30                	cmp    $0x30,%al
f0104173:	75 05                	jne    f010417a <strtol+0x64>
		s++, base = 8;
f0104175:	42                   	inc    %edx
f0104176:	b3 08                	mov    $0x8,%bl
f0104178:	eb 05                	jmp    f010417f <strtol+0x69>
	else if (base == 0)
		base = 10;
f010417a:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010417f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104184:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104186:	8a 0a                	mov    (%edx),%cl
f0104188:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f010418b:	80 fb 09             	cmp    $0x9,%bl
f010418e:	77 08                	ja     f0104198 <strtol+0x82>
			dig = *s - '0';
f0104190:	0f be c9             	movsbl %cl,%ecx
f0104193:	83 e9 30             	sub    $0x30,%ecx
f0104196:	eb 1e                	jmp    f01041b6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0104198:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010419b:	80 fb 19             	cmp    $0x19,%bl
f010419e:	77 08                	ja     f01041a8 <strtol+0x92>
			dig = *s - 'a' + 10;
f01041a0:	0f be c9             	movsbl %cl,%ecx
f01041a3:	83 e9 57             	sub    $0x57,%ecx
f01041a6:	eb 0e                	jmp    f01041b6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01041a8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01041ab:	80 fb 19             	cmp    $0x19,%bl
f01041ae:	77 13                	ja     f01041c3 <strtol+0xad>
			dig = *s - 'A' + 10;
f01041b0:	0f be c9             	movsbl %cl,%ecx
f01041b3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01041b6:	39 f1                	cmp    %esi,%ecx
f01041b8:	7d 0d                	jge    f01041c7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f01041ba:	42                   	inc    %edx
f01041bb:	0f af c6             	imul   %esi,%eax
f01041be:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f01041c1:	eb c3                	jmp    f0104186 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01041c3:	89 c1                	mov    %eax,%ecx
f01041c5:	eb 02                	jmp    f01041c9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01041c7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01041c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01041cd:	74 05                	je     f01041d4 <strtol+0xbe>
		*endptr = (char *) s;
f01041cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01041d2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01041d4:	85 ff                	test   %edi,%edi
f01041d6:	74 04                	je     f01041dc <strtol+0xc6>
f01041d8:	89 c8                	mov    %ecx,%eax
f01041da:	f7 d8                	neg    %eax
}
f01041dc:	5b                   	pop    %ebx
f01041dd:	5e                   	pop    %esi
f01041de:	5f                   	pop    %edi
f01041df:	c9                   	leave  
f01041e0:	c3                   	ret    
f01041e1:	00 00                	add    %al,(%eax)
	...

f01041e4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01041e4:	55                   	push   %ebp
f01041e5:	89 e5                	mov    %esp,%ebp
f01041e7:	57                   	push   %edi
f01041e8:	56                   	push   %esi
f01041e9:	83 ec 10             	sub    $0x10,%esp
f01041ec:	8b 7d 08             	mov    0x8(%ebp),%edi
f01041ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01041f2:	89 7d f0             	mov    %edi,-0x10(%ebp)
f01041f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f01041f8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01041fb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01041fe:	85 c0                	test   %eax,%eax
f0104200:	75 2e                	jne    f0104230 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0104202:	39 f1                	cmp    %esi,%ecx
f0104204:	77 5a                	ja     f0104260 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0104206:	85 c9                	test   %ecx,%ecx
f0104208:	75 0b                	jne    f0104215 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f010420a:	b8 01 00 00 00       	mov    $0x1,%eax
f010420f:	31 d2                	xor    %edx,%edx
f0104211:	f7 f1                	div    %ecx
f0104213:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0104215:	31 d2                	xor    %edx,%edx
f0104217:	89 f0                	mov    %esi,%eax
f0104219:	f7 f1                	div    %ecx
f010421b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010421d:	89 f8                	mov    %edi,%eax
f010421f:	f7 f1                	div    %ecx
f0104221:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104223:	89 f8                	mov    %edi,%eax
f0104225:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104227:	83 c4 10             	add    $0x10,%esp
f010422a:	5e                   	pop    %esi
f010422b:	5f                   	pop    %edi
f010422c:	c9                   	leave  
f010422d:	c3                   	ret    
f010422e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0104230:	39 f0                	cmp    %esi,%eax
f0104232:	77 1c                	ja     f0104250 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0104234:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f0104237:	83 f7 1f             	xor    $0x1f,%edi
f010423a:	75 3c                	jne    f0104278 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010423c:	39 f0                	cmp    %esi,%eax
f010423e:	0f 82 90 00 00 00    	jb     f01042d4 <__udivdi3+0xf0>
f0104244:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104247:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f010424a:	0f 86 84 00 00 00    	jbe    f01042d4 <__udivdi3+0xf0>
f0104250:	31 f6                	xor    %esi,%esi
f0104252:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104254:	89 f8                	mov    %edi,%eax
f0104256:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104258:	83 c4 10             	add    $0x10,%esp
f010425b:	5e                   	pop    %esi
f010425c:	5f                   	pop    %edi
f010425d:	c9                   	leave  
f010425e:	c3                   	ret    
f010425f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104260:	89 f2                	mov    %esi,%edx
f0104262:	89 f8                	mov    %edi,%eax
f0104264:	f7 f1                	div    %ecx
f0104266:	89 c7                	mov    %eax,%edi
f0104268:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010426a:	89 f8                	mov    %edi,%eax
f010426c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010426e:	83 c4 10             	add    $0x10,%esp
f0104271:	5e                   	pop    %esi
f0104272:	5f                   	pop    %edi
f0104273:	c9                   	leave  
f0104274:	c3                   	ret    
f0104275:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0104278:	89 f9                	mov    %edi,%ecx
f010427a:	d3 e0                	shl    %cl,%eax
f010427c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010427f:	b8 20 00 00 00       	mov    $0x20,%eax
f0104284:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0104286:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104289:	88 c1                	mov    %al,%cl
f010428b:	d3 ea                	shr    %cl,%edx
f010428d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104290:	09 ca                	or     %ecx,%edx
f0104292:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0104295:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104298:	89 f9                	mov    %edi,%ecx
f010429a:	d3 e2                	shl    %cl,%edx
f010429c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f010429f:	89 f2                	mov    %esi,%edx
f01042a1:	88 c1                	mov    %al,%cl
f01042a3:	d3 ea                	shr    %cl,%edx
f01042a5:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f01042a8:	89 f2                	mov    %esi,%edx
f01042aa:	89 f9                	mov    %edi,%ecx
f01042ac:	d3 e2                	shl    %cl,%edx
f01042ae:	8b 75 f0             	mov    -0x10(%ebp),%esi
f01042b1:	88 c1                	mov    %al,%cl
f01042b3:	d3 ee                	shr    %cl,%esi
f01042b5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01042b7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01042ba:	89 f0                	mov    %esi,%eax
f01042bc:	89 ca                	mov    %ecx,%edx
f01042be:	f7 75 ec             	divl   -0x14(%ebp)
f01042c1:	89 d1                	mov    %edx,%ecx
f01042c3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01042c5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01042c8:	39 d1                	cmp    %edx,%ecx
f01042ca:	72 28                	jb     f01042f4 <__udivdi3+0x110>
f01042cc:	74 1a                	je     f01042e8 <__udivdi3+0x104>
f01042ce:	89 f7                	mov    %esi,%edi
f01042d0:	31 f6                	xor    %esi,%esi
f01042d2:	eb 80                	jmp    f0104254 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01042d4:	31 f6                	xor    %esi,%esi
f01042d6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01042db:	89 f8                	mov    %edi,%eax
f01042dd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01042df:	83 c4 10             	add    $0x10,%esp
f01042e2:	5e                   	pop    %esi
f01042e3:	5f                   	pop    %edi
f01042e4:	c9                   	leave  
f01042e5:	c3                   	ret    
f01042e6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01042e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01042eb:	89 f9                	mov    %edi,%ecx
f01042ed:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01042ef:	39 c2                	cmp    %eax,%edx
f01042f1:	73 db                	jae    f01042ce <__udivdi3+0xea>
f01042f3:	90                   	nop
		{
		  q0--;
f01042f4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01042f7:	31 f6                	xor    %esi,%esi
f01042f9:	e9 56 ff ff ff       	jmp    f0104254 <__udivdi3+0x70>
	...

f0104300 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0104300:	55                   	push   %ebp
f0104301:	89 e5                	mov    %esp,%ebp
f0104303:	57                   	push   %edi
f0104304:	56                   	push   %esi
f0104305:	83 ec 20             	sub    $0x20,%esp
f0104308:	8b 45 08             	mov    0x8(%ebp),%eax
f010430b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010430e:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0104311:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0104314:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0104317:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f010431a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f010431d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010431f:	85 ff                	test   %edi,%edi
f0104321:	75 15                	jne    f0104338 <__umoddi3+0x38>
    {
      if (d0 > n1)
f0104323:	39 f1                	cmp    %esi,%ecx
f0104325:	0f 86 99 00 00 00    	jbe    f01043c4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f010432b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f010432d:	89 d0                	mov    %edx,%eax
f010432f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104331:	83 c4 20             	add    $0x20,%esp
f0104334:	5e                   	pop    %esi
f0104335:	5f                   	pop    %edi
f0104336:	c9                   	leave  
f0104337:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0104338:	39 f7                	cmp    %esi,%edi
f010433a:	0f 87 a4 00 00 00    	ja     f01043e4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0104340:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0104343:	83 f0 1f             	xor    $0x1f,%eax
f0104346:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104349:	0f 84 a1 00 00 00    	je     f01043f0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f010434f:	89 f8                	mov    %edi,%eax
f0104351:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104354:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0104356:	bf 20 00 00 00       	mov    $0x20,%edi
f010435b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f010435e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104361:	89 f9                	mov    %edi,%ecx
f0104363:	d3 ea                	shr    %cl,%edx
f0104365:	09 c2                	or     %eax,%edx
f0104367:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f010436a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010436d:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0104370:	d3 e0                	shl    %cl,%eax
f0104372:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0104375:	89 f2                	mov    %esi,%edx
f0104377:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0104379:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010437c:	d3 e0                	shl    %cl,%eax
f010437e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0104381:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104384:	89 f9                	mov    %edi,%ecx
f0104386:	d3 e8                	shr    %cl,%eax
f0104388:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f010438a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f010438c:	89 f2                	mov    %esi,%edx
f010438e:	f7 75 f0             	divl   -0x10(%ebp)
f0104391:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0104393:	f7 65 f4             	mull   -0xc(%ebp)
f0104396:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0104399:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010439b:	39 d6                	cmp    %edx,%esi
f010439d:	72 71                	jb     f0104410 <__umoddi3+0x110>
f010439f:	74 7f                	je     f0104420 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01043a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01043a4:	29 c8                	sub    %ecx,%eax
f01043a6:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01043a8:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01043ab:	d3 e8                	shr    %cl,%eax
f01043ad:	89 f2                	mov    %esi,%edx
f01043af:	89 f9                	mov    %edi,%ecx
f01043b1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01043b3:	09 d0                	or     %edx,%eax
f01043b5:	89 f2                	mov    %esi,%edx
f01043b7:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01043ba:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01043bc:	83 c4 20             	add    $0x20,%esp
f01043bf:	5e                   	pop    %esi
f01043c0:	5f                   	pop    %edi
f01043c1:	c9                   	leave  
f01043c2:	c3                   	ret    
f01043c3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01043c4:	85 c9                	test   %ecx,%ecx
f01043c6:	75 0b                	jne    f01043d3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01043c8:	b8 01 00 00 00       	mov    $0x1,%eax
f01043cd:	31 d2                	xor    %edx,%edx
f01043cf:	f7 f1                	div    %ecx
f01043d1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01043d3:	89 f0                	mov    %esi,%eax
f01043d5:	31 d2                	xor    %edx,%edx
f01043d7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01043d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01043dc:	f7 f1                	div    %ecx
f01043de:	e9 4a ff ff ff       	jmp    f010432d <__umoddi3+0x2d>
f01043e3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f01043e4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01043e6:	83 c4 20             	add    $0x20,%esp
f01043e9:	5e                   	pop    %esi
f01043ea:	5f                   	pop    %edi
f01043eb:	c9                   	leave  
f01043ec:	c3                   	ret    
f01043ed:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01043f0:	39 f7                	cmp    %esi,%edi
f01043f2:	72 05                	jb     f01043f9 <__umoddi3+0xf9>
f01043f4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f01043f7:	77 0c                	ja     f0104405 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01043f9:	89 f2                	mov    %esi,%edx
f01043fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01043fe:	29 c8                	sub    %ecx,%eax
f0104400:	19 fa                	sbb    %edi,%edx
f0104402:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0104405:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0104408:	83 c4 20             	add    $0x20,%esp
f010440b:	5e                   	pop    %esi
f010440c:	5f                   	pop    %edi
f010440d:	c9                   	leave  
f010440e:	c3                   	ret    
f010440f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0104410:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104413:	89 c1                	mov    %eax,%ecx
f0104415:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0104418:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f010441b:	eb 84                	jmp    f01043a1 <__umoddi3+0xa1>
f010441d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0104420:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0104423:	72 eb                	jb     f0104410 <__umoddi3+0x110>
f0104425:	89 f2                	mov    %esi,%edx
f0104427:	e9 75 ff ff ff       	jmp    f01043a1 <__umoddi3+0xa1>
