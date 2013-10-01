
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
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
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
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


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
f0100046:	b8 50 b9 11 f0       	mov    $0xf011b950,%eax
f010004b:	2d 00 b3 11 f0       	sub    $0xf011b300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 b3 11 f0       	push   $0xf011b300
f0100058:	e8 40 24 00 00       	call   f010249d <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 65 04 00 00       	call   f01004c7 <cons_init>
//    cprintf("H%x Wo%s\n", 57616, &i);

//    cprintf("x=%d y=%d", 3, 4);
//    cprintf("x=%d y=%d", 3);

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 00 29 10 f0       	push   $0xf0102900
f010006f:	e8 f9 18 00 00       	call   f010196d <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 ef 0d 00 00       	call   f0100e68 <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 ca 07 00 00       	call   f0100850 <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 40 b9 11 f0 00 	cmpl   $0x0,0xf011b940
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 40 b9 11 f0    	mov    %esi,0xf011b940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000a2:	fa                   	cli    
f01000a3:	fc                   	cld    

	va_start(ap, fmt);
f01000a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	83 ec 04             	sub    $0x4,%esp
f01000aa:	ff 75 0c             	pushl  0xc(%ebp)
f01000ad:	ff 75 08             	pushl  0x8(%ebp)
f01000b0:	68 1b 29 10 f0       	push   $0xf010291b
f01000b5:	e8 b3 18 00 00       	call   f010196d <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 83 18 00 00       	call   f0101947 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 57 29 10 f0 	movl   $0xf0102957,(%esp)
f01000cb:	e8 9d 18 00 00       	call   f010196d <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 73 07 00 00       	call   f0100850 <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x48>

f01000e2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e2:	55                   	push   %ebp
f01000e3:	89 e5                	mov    %esp,%ebp
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000e9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	68 33 29 10 f0       	push   $0xf0102933
f01000f7:	e8 71 18 00 00       	call   f010196d <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 3f 18 00 00       	call   f0101947 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 57 29 10 f0 	movl   $0xf0102957,(%esp)
f010010f:	e8 59 18 00 00       	call   f010196d <cprintf>
	va_end(ap);
f0100114:	83 c4 10             	add    $0x10,%esp
}
f0100117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011a:	c9                   	leave  
f010011b:	c3                   	ret    

f010011c <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f010011c:	55                   	push   %ebp
f010011d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010011f:	ba 84 00 00 00       	mov    $0x84,%edx
f0100124:	ec                   	in     (%dx),%al
f0100125:	ec                   	in     (%dx),%al
f0100126:	ec                   	in     (%dx),%al
f0100127:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100128:	c9                   	leave  
f0100129:	c3                   	ret    

f010012a <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010012a:	55                   	push   %ebp
f010012b:	89 e5                	mov    %esp,%ebp
f010012d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100132:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100133:	a8 01                	test   $0x1,%al
f0100135:	74 08                	je     f010013f <serial_proc_data+0x15>
f0100137:	b2 f8                	mov    $0xf8,%dl
f0100139:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010013a:	0f b6 c0             	movzbl %al,%eax
f010013d:	eb 05                	jmp    f0100144 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010013f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100144:	c9                   	leave  
f0100145:	c3                   	ret    

f0100146 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100146:	55                   	push   %ebp
f0100147:	89 e5                	mov    %esp,%ebp
f0100149:	53                   	push   %ebx
f010014a:	83 ec 04             	sub    $0x4,%esp
f010014d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010014f:	eb 29                	jmp    f010017a <cons_intr+0x34>
		if (c == 0)
f0100151:	85 c0                	test   %eax,%eax
f0100153:	74 25                	je     f010017a <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100155:	8b 15 24 b5 11 f0    	mov    0xf011b524,%edx
f010015b:	88 82 20 b3 11 f0    	mov    %al,-0xfee4ce0(%edx)
f0100161:	8d 42 01             	lea    0x1(%edx),%eax
f0100164:	a3 24 b5 11 f0       	mov    %eax,0xf011b524
		if (cons.wpos == CONSBUFSIZE)
f0100169:	3d 00 02 00 00       	cmp    $0x200,%eax
f010016e:	75 0a                	jne    f010017a <cons_intr+0x34>
			cons.wpos = 0;
f0100170:	c7 05 24 b5 11 f0 00 	movl   $0x0,0xf011b524
f0100177:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010017a:	ff d3                	call   *%ebx
f010017c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010017f:	75 d0                	jne    f0100151 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100181:	83 c4 04             	add    $0x4,%esp
f0100184:	5b                   	pop    %ebx
f0100185:	c9                   	leave  
f0100186:	c3                   	ret    

f0100187 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100187:	55                   	push   %ebp
f0100188:	89 e5                	mov    %esp,%ebp
f010018a:	57                   	push   %edi
f010018b:	56                   	push   %esi
f010018c:	53                   	push   %ebx
f010018d:	83 ec 0c             	sub    $0xc,%esp
f0100190:	89 c6                	mov    %eax,%esi
f0100192:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100197:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100198:	a8 20                	test   $0x20,%al
f010019a:	75 19                	jne    f01001b5 <cons_putc+0x2e>
f010019c:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01001a1:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001a6:	e8 71 ff ff ff       	call   f010011c <delay>
f01001ab:	89 fa                	mov    %edi,%edx
f01001ad:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001ae:	a8 20                	test   $0x20,%al
f01001b0:	75 03                	jne    f01001b5 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001b2:	4b                   	dec    %ebx
f01001b3:	75 f1                	jne    f01001a6 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01001b5:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001b7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001bc:	89 f0                	mov    %esi,%eax
f01001be:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001bf:	b2 79                	mov    $0x79,%dl
f01001c1:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01001c2:	84 c0                	test   %al,%al
f01001c4:	78 1d                	js     f01001e3 <cons_putc+0x5c>
f01001c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		delay();
f01001cb:	e8 4c ff ff ff       	call   f010011c <delay>
f01001d0:	ba 79 03 00 00       	mov    $0x379,%edx
f01001d5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01001d6:	84 c0                	test   %al,%al
f01001d8:	78 09                	js     f01001e3 <cons_putc+0x5c>
f01001da:	43                   	inc    %ebx
f01001db:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01001e1:	75 e8                	jne    f01001cb <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001e3:	ba 78 03 00 00       	mov    $0x378,%edx
f01001e8:	89 f8                	mov    %edi,%eax
f01001ea:	ee                   	out    %al,(%dx)
f01001eb:	b2 7a                	mov    $0x7a,%dl
f01001ed:	b0 0d                	mov    $0xd,%al
f01001ef:	ee                   	out    %al,(%dx)
f01001f0:	b0 08                	mov    $0x8,%al
f01001f2:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
    // set user_setcolor
    c |= (user_setcolor << 8);
f01001f3:	a1 00 b3 11 f0       	mov    0xf011b300,%eax
f01001f8:	c1 e0 08             	shl    $0x8,%eax
f01001fb:	09 c6                	or     %eax,%esi

	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01001fd:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100203:	75 06                	jne    f010020b <cons_putc+0x84>
		c |= 0x0700;
f0100205:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f010020b:	89 f0                	mov    %esi,%eax
f010020d:	25 ff 00 00 00       	and    $0xff,%eax
f0100212:	83 f8 09             	cmp    $0x9,%eax
f0100215:	74 78                	je     f010028f <cons_putc+0x108>
f0100217:	83 f8 09             	cmp    $0x9,%eax
f010021a:	7f 0b                	jg     f0100227 <cons_putc+0xa0>
f010021c:	83 f8 08             	cmp    $0x8,%eax
f010021f:	0f 85 9e 00 00 00    	jne    f01002c3 <cons_putc+0x13c>
f0100225:	eb 10                	jmp    f0100237 <cons_putc+0xb0>
f0100227:	83 f8 0a             	cmp    $0xa,%eax
f010022a:	74 39                	je     f0100265 <cons_putc+0xde>
f010022c:	83 f8 0d             	cmp    $0xd,%eax
f010022f:	0f 85 8e 00 00 00    	jne    f01002c3 <cons_putc+0x13c>
f0100235:	eb 36                	jmp    f010026d <cons_putc+0xe6>
	case '\b':
		if (crt_pos > 0) {
f0100237:	66 a1 04 b3 11 f0    	mov    0xf011b304,%ax
f010023d:	66 85 c0             	test   %ax,%ax
f0100240:	0f 84 e0 00 00 00    	je     f0100326 <cons_putc+0x19f>
			crt_pos--;
f0100246:	48                   	dec    %eax
f0100247:	66 a3 04 b3 11 f0    	mov    %ax,0xf011b304
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010024d:	0f b7 c0             	movzwl %ax,%eax
f0100250:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100256:	83 ce 20             	or     $0x20,%esi
f0100259:	8b 15 08 b3 11 f0    	mov    0xf011b308,%edx
f010025f:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100263:	eb 78                	jmp    f01002dd <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100265:	66 83 05 04 b3 11 f0 	addw   $0x50,0xf011b304
f010026c:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010026d:	66 8b 0d 04 b3 11 f0 	mov    0xf011b304,%cx
f0100274:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100279:	89 c8                	mov    %ecx,%eax
f010027b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100280:	66 f7 f3             	div    %bx
f0100283:	66 29 d1             	sub    %dx,%cx
f0100286:	66 89 0d 04 b3 11 f0 	mov    %cx,0xf011b304
f010028d:	eb 4e                	jmp    f01002dd <cons_putc+0x156>
		break;
	case '\t':
		cons_putc(' ');
f010028f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100294:	e8 ee fe ff ff       	call   f0100187 <cons_putc>
		cons_putc(' ');
f0100299:	b8 20 00 00 00       	mov    $0x20,%eax
f010029e:	e8 e4 fe ff ff       	call   f0100187 <cons_putc>
		cons_putc(' ');
f01002a3:	b8 20 00 00 00       	mov    $0x20,%eax
f01002a8:	e8 da fe ff ff       	call   f0100187 <cons_putc>
		cons_putc(' ');
f01002ad:	b8 20 00 00 00       	mov    $0x20,%eax
f01002b2:	e8 d0 fe ff ff       	call   f0100187 <cons_putc>
		cons_putc(' ');
f01002b7:	b8 20 00 00 00       	mov    $0x20,%eax
f01002bc:	e8 c6 fe ff ff       	call   f0100187 <cons_putc>
f01002c1:	eb 1a                	jmp    f01002dd <cons_putc+0x156>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01002c3:	66 a1 04 b3 11 f0    	mov    0xf011b304,%ax
f01002c9:	0f b7 c8             	movzwl %ax,%ecx
f01002cc:	8b 15 08 b3 11 f0    	mov    0xf011b308,%edx
f01002d2:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01002d6:	40                   	inc    %eax
f01002d7:	66 a3 04 b3 11 f0    	mov    %ax,0xf011b304
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f01002dd:	66 81 3d 04 b3 11 f0 	cmpw   $0x7cf,0xf011b304
f01002e4:	cf 07 
f01002e6:	76 3e                	jbe    f0100326 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01002e8:	a1 08 b3 11 f0       	mov    0xf011b308,%eax
f01002ed:	83 ec 04             	sub    $0x4,%esp
f01002f0:	68 00 0f 00 00       	push   $0xf00
f01002f5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01002fb:	52                   	push   %edx
f01002fc:	50                   	push   %eax
f01002fd:	e8 e5 21 00 00       	call   f01024e7 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100302:	8b 15 08 b3 11 f0    	mov    0xf011b308,%edx
f0100308:	83 c4 10             	add    $0x10,%esp
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010030b:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100310:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100316:	40                   	inc    %eax
f0100317:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010031c:	75 f2                	jne    f0100310 <cons_putc+0x189>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010031e:	66 83 2d 04 b3 11 f0 	subw   $0x50,0xf011b304
f0100325:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100326:	8b 0d 0c b3 11 f0    	mov    0xf011b30c,%ecx
f010032c:	b0 0e                	mov    $0xe,%al
f010032e:	89 ca                	mov    %ecx,%edx
f0100330:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100331:	66 8b 35 04 b3 11 f0 	mov    0xf011b304,%si
f0100338:	8d 59 01             	lea    0x1(%ecx),%ebx
f010033b:	89 f0                	mov    %esi,%eax
f010033d:	66 c1 e8 08          	shr    $0x8,%ax
f0100341:	89 da                	mov    %ebx,%edx
f0100343:	ee                   	out    %al,(%dx)
f0100344:	b0 0f                	mov    $0xf,%al
f0100346:	89 ca                	mov    %ecx,%edx
f0100348:	ee                   	out    %al,(%dx)
f0100349:	89 f0                	mov    %esi,%eax
f010034b:	89 da                	mov    %ebx,%edx
f010034d:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010034e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100351:	5b                   	pop    %ebx
f0100352:	5e                   	pop    %esi
f0100353:	5f                   	pop    %edi
f0100354:	c9                   	leave  
f0100355:	c3                   	ret    

f0100356 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100356:	55                   	push   %ebp
f0100357:	89 e5                	mov    %esp,%ebp
f0100359:	53                   	push   %ebx
f010035a:	83 ec 04             	sub    $0x4,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010035d:	ba 64 00 00 00       	mov    $0x64,%edx
f0100362:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100363:	a8 01                	test   $0x1,%al
f0100365:	0f 84 dc 00 00 00    	je     f0100447 <kbd_proc_data+0xf1>
f010036b:	b2 60                	mov    $0x60,%dl
f010036d:	ec                   	in     (%dx),%al
f010036e:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100370:	3c e0                	cmp    $0xe0,%al
f0100372:	75 11                	jne    f0100385 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100374:	83 0d 28 b5 11 f0 40 	orl    $0x40,0xf011b528
		return 0;
f010037b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100380:	e9 c7 00 00 00       	jmp    f010044c <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f0100385:	84 c0                	test   %al,%al
f0100387:	79 33                	jns    f01003bc <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100389:	8b 0d 28 b5 11 f0    	mov    0xf011b528,%ecx
f010038f:	f6 c1 40             	test   $0x40,%cl
f0100392:	75 05                	jne    f0100399 <kbd_proc_data+0x43>
f0100394:	88 c2                	mov    %al,%dl
f0100396:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100399:	0f b6 d2             	movzbl %dl,%edx
f010039c:	8a 82 80 29 10 f0    	mov    -0xfefd680(%edx),%al
f01003a2:	83 c8 40             	or     $0x40,%eax
f01003a5:	0f b6 c0             	movzbl %al,%eax
f01003a8:	f7 d0                	not    %eax
f01003aa:	21 c1                	and    %eax,%ecx
f01003ac:	89 0d 28 b5 11 f0    	mov    %ecx,0xf011b528
		return 0;
f01003b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003b7:	e9 90 00 00 00       	jmp    f010044c <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f01003bc:	8b 0d 28 b5 11 f0    	mov    0xf011b528,%ecx
f01003c2:	f6 c1 40             	test   $0x40,%cl
f01003c5:	74 0e                	je     f01003d5 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003c7:	88 c2                	mov    %al,%dl
f01003c9:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003cc:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003cf:	89 0d 28 b5 11 f0    	mov    %ecx,0xf011b528
	}

	shift |= shiftcode[data];
f01003d5:	0f b6 d2             	movzbl %dl,%edx
f01003d8:	0f b6 82 80 29 10 f0 	movzbl -0xfefd680(%edx),%eax
f01003df:	0b 05 28 b5 11 f0    	or     0xf011b528,%eax
	shift ^= togglecode[data];
f01003e5:	0f b6 8a 80 2a 10 f0 	movzbl -0xfefd580(%edx),%ecx
f01003ec:	31 c8                	xor    %ecx,%eax
f01003ee:	a3 28 b5 11 f0       	mov    %eax,0xf011b528

	c = charcode[shift & (CTL | SHIFT)][data];
f01003f3:	89 c1                	mov    %eax,%ecx
f01003f5:	83 e1 03             	and    $0x3,%ecx
f01003f8:	8b 0c 8d 80 2b 10 f0 	mov    -0xfefd480(,%ecx,4),%ecx
f01003ff:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100403:	a8 08                	test   $0x8,%al
f0100405:	74 18                	je     f010041f <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f0100407:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010040a:	83 fa 19             	cmp    $0x19,%edx
f010040d:	77 05                	ja     f0100414 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f010040f:	83 eb 20             	sub    $0x20,%ebx
f0100412:	eb 0b                	jmp    f010041f <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100414:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100417:	83 fa 19             	cmp    $0x19,%edx
f010041a:	77 03                	ja     f010041f <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f010041c:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010041f:	f7 d0                	not    %eax
f0100421:	a8 06                	test   $0x6,%al
f0100423:	75 27                	jne    f010044c <kbd_proc_data+0xf6>
f0100425:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010042b:	75 1f                	jne    f010044c <kbd_proc_data+0xf6>
		cprintf("Rebooting!\n");
f010042d:	83 ec 0c             	sub    $0xc,%esp
f0100430:	68 4d 29 10 f0       	push   $0xf010294d
f0100435:	e8 33 15 00 00       	call   f010196d <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010043a:	ba 92 00 00 00       	mov    $0x92,%edx
f010043f:	b0 03                	mov    $0x3,%al
f0100441:	ee                   	out    %al,(%dx)
f0100442:	83 c4 10             	add    $0x10,%esp
f0100445:	eb 05                	jmp    f010044c <kbd_proc_data+0xf6>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100447:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010044c:	89 d8                	mov    %ebx,%eax
f010044e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100451:	c9                   	leave  
f0100452:	c3                   	ret    

f0100453 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100453:	55                   	push   %ebp
f0100454:	89 e5                	mov    %esp,%ebp
f0100456:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100459:	80 3d 10 b3 11 f0 00 	cmpb   $0x0,0xf011b310
f0100460:	74 0a                	je     f010046c <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100462:	b8 2a 01 10 f0       	mov    $0xf010012a,%eax
f0100467:	e8 da fc ff ff       	call   f0100146 <cons_intr>
}
f010046c:	c9                   	leave  
f010046d:	c3                   	ret    

f010046e <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010046e:	55                   	push   %ebp
f010046f:	89 e5                	mov    %esp,%ebp
f0100471:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100474:	b8 56 03 10 f0       	mov    $0xf0100356,%eax
f0100479:	e8 c8 fc ff ff       	call   f0100146 <cons_intr>
}
f010047e:	c9                   	leave  
f010047f:	c3                   	ret    

f0100480 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100480:	55                   	push   %ebp
f0100481:	89 e5                	mov    %esp,%ebp
f0100483:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100486:	e8 c8 ff ff ff       	call   f0100453 <serial_intr>
	kbd_intr();
f010048b:	e8 de ff ff ff       	call   f010046e <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100490:	8b 15 20 b5 11 f0    	mov    0xf011b520,%edx
f0100496:	3b 15 24 b5 11 f0    	cmp    0xf011b524,%edx
f010049c:	74 22                	je     f01004c0 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010049e:	0f b6 82 20 b3 11 f0 	movzbl -0xfee4ce0(%edx),%eax
f01004a5:	42                   	inc    %edx
f01004a6:	89 15 20 b5 11 f0    	mov    %edx,0xf011b520
		if (cons.rpos == CONSBUFSIZE)
f01004ac:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004b2:	75 11                	jne    f01004c5 <cons_getc+0x45>
			cons.rpos = 0;
f01004b4:	c7 05 20 b5 11 f0 00 	movl   $0x0,0xf011b520
f01004bb:	00 00 00 
f01004be:	eb 05                	jmp    f01004c5 <cons_getc+0x45>
		return c;
	}
	return 0;
f01004c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004c5:	c9                   	leave  
f01004c6:	c3                   	ret    

f01004c7 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004c7:	55                   	push   %ebp
f01004c8:	89 e5                	mov    %esp,%ebp
f01004ca:	57                   	push   %edi
f01004cb:	56                   	push   %esi
f01004cc:	53                   	push   %ebx
f01004cd:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004d0:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01004d7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01004de:	5a a5 
	if (*cp != 0xA55A) {
f01004e0:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01004e6:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01004ea:	74 11                	je     f01004fd <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01004ec:	c7 05 0c b3 11 f0 b4 	movl   $0x3b4,0xf011b30c
f01004f3:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01004f6:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01004fb:	eb 16                	jmp    f0100513 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01004fd:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100504:	c7 05 0c b3 11 f0 d4 	movl   $0x3d4,0xf011b30c
f010050b:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010050e:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100513:	8b 0d 0c b3 11 f0    	mov    0xf011b30c,%ecx
f0100519:	b0 0e                	mov    $0xe,%al
f010051b:	89 ca                	mov    %ecx,%edx
f010051d:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010051e:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100521:	89 da                	mov    %ebx,%edx
f0100523:	ec                   	in     (%dx),%al
f0100524:	0f b6 f8             	movzbl %al,%edi
f0100527:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010052a:	b0 0f                	mov    $0xf,%al
f010052c:	89 ca                	mov    %ecx,%edx
f010052e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010052f:	89 da                	mov    %ebx,%edx
f0100531:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100532:	89 35 08 b3 11 f0    	mov    %esi,0xf011b308

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100538:	0f b6 d8             	movzbl %al,%ebx
f010053b:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010053d:	66 89 3d 04 b3 11 f0 	mov    %di,0xf011b304
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100544:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100549:	b0 00                	mov    $0x0,%al
f010054b:	89 da                	mov    %ebx,%edx
f010054d:	ee                   	out    %al,(%dx)
f010054e:	b2 fb                	mov    $0xfb,%dl
f0100550:	b0 80                	mov    $0x80,%al
f0100552:	ee                   	out    %al,(%dx)
f0100553:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100558:	b0 0c                	mov    $0xc,%al
f010055a:	89 ca                	mov    %ecx,%edx
f010055c:	ee                   	out    %al,(%dx)
f010055d:	b2 f9                	mov    $0xf9,%dl
f010055f:	b0 00                	mov    $0x0,%al
f0100561:	ee                   	out    %al,(%dx)
f0100562:	b2 fb                	mov    $0xfb,%dl
f0100564:	b0 03                	mov    $0x3,%al
f0100566:	ee                   	out    %al,(%dx)
f0100567:	b2 fc                	mov    $0xfc,%dl
f0100569:	b0 00                	mov    $0x0,%al
f010056b:	ee                   	out    %al,(%dx)
f010056c:	b2 f9                	mov    $0xf9,%dl
f010056e:	b0 01                	mov    $0x1,%al
f0100570:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100571:	b2 fd                	mov    $0xfd,%dl
f0100573:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100574:	3c ff                	cmp    $0xff,%al
f0100576:	0f 95 45 e7          	setne  -0x19(%ebp)
f010057a:	8a 45 e7             	mov    -0x19(%ebp),%al
f010057d:	a2 10 b3 11 f0       	mov    %al,0xf011b310
f0100582:	89 da                	mov    %ebx,%edx
f0100584:	ec                   	in     (%dx),%al
f0100585:	89 ca                	mov    %ecx,%edx
f0100587:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100588:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f010058c:	75 10                	jne    f010059e <cons_init+0xd7>
		cprintf("Serial port does not exist!\n");
f010058e:	83 ec 0c             	sub    $0xc,%esp
f0100591:	68 59 29 10 f0       	push   $0xf0102959
f0100596:	e8 d2 13 00 00       	call   f010196d <cprintf>
f010059b:	83 c4 10             	add    $0x10,%esp
}
f010059e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005a1:	5b                   	pop    %ebx
f01005a2:	5e                   	pop    %esi
f01005a3:	5f                   	pop    %edi
f01005a4:	c9                   	leave  
f01005a5:	c3                   	ret    

f01005a6 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005a6:	55                   	push   %ebp
f01005a7:	89 e5                	mov    %esp,%ebp
f01005a9:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01005af:	e8 d3 fb ff ff       	call   f0100187 <cons_putc>
}
f01005b4:	c9                   	leave  
f01005b5:	c3                   	ret    

f01005b6 <getchar>:

int
getchar(void)
{
f01005b6:	55                   	push   %ebp
f01005b7:	89 e5                	mov    %esp,%ebp
f01005b9:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01005bc:	e8 bf fe ff ff       	call   f0100480 <cons_getc>
f01005c1:	85 c0                	test   %eax,%eax
f01005c3:	74 f7                	je     f01005bc <getchar+0x6>
		/* do nothing */;
	return c;
}
f01005c5:	c9                   	leave  
f01005c6:	c3                   	ret    

f01005c7 <iscons>:

int
iscons(int fdnum)
{
f01005c7:	55                   	push   %ebp
f01005c8:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01005ca:	b8 01 00 00 00       	mov    $0x1,%eax
f01005cf:	c9                   	leave  
f01005d0:	c3                   	ret    
f01005d1:	00 00                	add    %al,(%eax)
	...

f01005d4 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01005d4:	55                   	push   %ebp
f01005d5:	89 e5                	mov    %esp,%ebp
f01005d7:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01005da:	68 90 2b 10 f0       	push   $0xf0102b90
f01005df:	e8 89 13 00 00       	call   f010196d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005e4:	83 c4 08             	add    $0x8,%esp
f01005e7:	68 0c 00 10 00       	push   $0x10000c
f01005ec:	68 88 2c 10 f0       	push   $0xf0102c88
f01005f1:	e8 77 13 00 00       	call   f010196d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01005f6:	83 c4 0c             	add    $0xc,%esp
f01005f9:	68 0c 00 10 00       	push   $0x10000c
f01005fe:	68 0c 00 10 f0       	push   $0xf010000c
f0100603:	68 b0 2c 10 f0       	push   $0xf0102cb0
f0100608:	e8 60 13 00 00       	call   f010196d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010060d:	83 c4 0c             	add    $0xc,%esp
f0100610:	68 ec 28 10 00       	push   $0x1028ec
f0100615:	68 ec 28 10 f0       	push   $0xf01028ec
f010061a:	68 d4 2c 10 f0       	push   $0xf0102cd4
f010061f:	e8 49 13 00 00       	call   f010196d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100624:	83 c4 0c             	add    $0xc,%esp
f0100627:	68 00 b3 11 00       	push   $0x11b300
f010062c:	68 00 b3 11 f0       	push   $0xf011b300
f0100631:	68 f8 2c 10 f0       	push   $0xf0102cf8
f0100636:	e8 32 13 00 00       	call   f010196d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010063b:	83 c4 0c             	add    $0xc,%esp
f010063e:	68 50 b9 11 00       	push   $0x11b950
f0100643:	68 50 b9 11 f0       	push   $0xf011b950
f0100648:	68 1c 2d 10 f0       	push   $0xf0102d1c
f010064d:	e8 1b 13 00 00       	call   f010196d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100652:	b8 4f bd 11 f0       	mov    $0xf011bd4f,%eax
f0100657:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010065c:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010065f:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100664:	89 c2                	mov    %eax,%edx
f0100666:	85 c0                	test   %eax,%eax
f0100668:	79 06                	jns    f0100670 <mon_kerninfo+0x9c>
f010066a:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100670:	c1 fa 0a             	sar    $0xa,%edx
f0100673:	52                   	push   %edx
f0100674:	68 40 2d 10 f0       	push   $0xf0102d40
f0100679:	e8 ef 12 00 00       	call   f010196d <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010067e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100683:	c9                   	leave  
f0100684:	c3                   	ret    

f0100685 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100685:	55                   	push   %ebp
f0100686:	89 e5                	mov    %esp,%ebp
f0100688:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010068b:	ff 35 c4 2f 10 f0    	pushl  0xf0102fc4
f0100691:	ff 35 c0 2f 10 f0    	pushl  0xf0102fc0
f0100697:	68 a9 2b 10 f0       	push   $0xf0102ba9
f010069c:	e8 cc 12 00 00       	call   f010196d <cprintf>
f01006a1:	83 c4 0c             	add    $0xc,%esp
f01006a4:	ff 35 d0 2f 10 f0    	pushl  0xf0102fd0
f01006aa:	ff 35 cc 2f 10 f0    	pushl  0xf0102fcc
f01006b0:	68 a9 2b 10 f0       	push   $0xf0102ba9
f01006b5:	e8 b3 12 00 00       	call   f010196d <cprintf>
f01006ba:	83 c4 0c             	add    $0xc,%esp
f01006bd:	ff 35 dc 2f 10 f0    	pushl  0xf0102fdc
f01006c3:	ff 35 d8 2f 10 f0    	pushl  0xf0102fd8
f01006c9:	68 a9 2b 10 f0       	push   $0xf0102ba9
f01006ce:	e8 9a 12 00 00       	call   f010196d <cprintf>
f01006d3:	83 c4 0c             	add    $0xc,%esp
f01006d6:	ff 35 e8 2f 10 f0    	pushl  0xf0102fe8
f01006dc:	ff 35 e4 2f 10 f0    	pushl  0xf0102fe4
f01006e2:	68 a9 2b 10 f0       	push   $0xf0102ba9
f01006e7:	e8 81 12 00 00       	call   f010196d <cprintf>
	return 0;
}
f01006ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01006f1:	c9                   	leave  
f01006f2:	c3                   	ret    

f01006f3 <mon_setcolor>:
}


int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f01006f3:	55                   	push   %ebp
f01006f4:	89 e5                	mov    %esp,%ebp
f01006f6:	56                   	push   %esi
f01006f7:	53                   	push   %ebx
f01006f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f01006fb:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f01006ff:	74 66                	je     f0100767 <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f0100701:	83 ec 0c             	sub    $0xc,%esp
f0100704:	68 6c 2d 10 f0       	push   $0xf0102d6c
f0100709:	e8 5f 12 00 00       	call   f010196d <cprintf>
        cprintf("num show the color attribute. \n");
f010070e:	c7 04 24 9c 2d 10 f0 	movl   $0xf0102d9c,(%esp)
f0100715:	e8 53 12 00 00       	call   f010196d <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f010071a:	c7 04 24 bc 2d 10 f0 	movl   $0xf0102dbc,(%esp)
f0100721:	e8 47 12 00 00       	call   f010196d <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100726:	c7 04 24 f0 2d 10 f0 	movl   $0xf0102df0,(%esp)
f010072d:	e8 3b 12 00 00       	call   f010196d <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100732:	c7 04 24 34 2e 10 f0 	movl   $0xf0102e34,(%esp)
f0100739:	e8 2f 12 00 00       	call   f010196d <cprintf>
        cprintf("Example: setcolor 00001111\n");
f010073e:	c7 04 24 b2 2b 10 f0 	movl   $0xf0102bb2,(%esp)
f0100745:	e8 23 12 00 00       	call   f010196d <cprintf>
        cprintf("         set the background color to black\n");
f010074a:	c7 04 24 78 2e 10 f0 	movl   $0xf0102e78,(%esp)
f0100751:	e8 17 12 00 00       	call   f010196d <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100756:	c7 04 24 a4 2e 10 f0 	movl   $0xf0102ea4,(%esp)
f010075d:	e8 0b 12 00 00       	call   f010196d <cprintf>
f0100762:	83 c4 10             	add    $0x10,%esp
f0100765:	eb 52                	jmp    f01007b9 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100767:	83 ec 0c             	sub    $0xc,%esp
f010076a:	ff 73 04             	pushl  0x4(%ebx)
f010076d:	e8 62 1b 00 00       	call   f01022d4 <strlen>
f0100772:	83 c4 10             	add    $0x10,%esp
f0100775:	48                   	dec    %eax
f0100776:	78 26                	js     f010079e <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f0100778:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f010077b:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100780:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f0100785:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f0100789:	0f 94 c3             	sete   %bl
f010078c:	0f b6 db             	movzbl %bl,%ebx
f010078f:	d3 e3                	shl    %cl,%ebx
f0100791:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100793:	48                   	dec    %eax
f0100794:	78 0d                	js     f01007a3 <mon_setcolor+0xb0>
f0100796:	41                   	inc    %ecx
f0100797:	83 f9 08             	cmp    $0x8,%ecx
f010079a:	75 e9                	jne    f0100785 <mon_setcolor+0x92>
f010079c:	eb 05                	jmp    f01007a3 <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f010079e:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f01007a3:	89 15 00 b3 11 f0    	mov    %edx,0xf011b300
        cprintf(" This is color that you want ! \n");
f01007a9:	83 ec 0c             	sub    $0xc,%esp
f01007ac:	68 d8 2e 10 f0       	push   $0xf0102ed8
f01007b1:	e8 b7 11 00 00       	call   f010196d <cprintf>
f01007b6:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f01007b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01007be:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007c1:	5b                   	pop    %ebx
f01007c2:	5e                   	pop    %esi
f01007c3:	c9                   	leave  
f01007c4:	c3                   	ret    

f01007c5 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f01007c5:	55                   	push   %ebp
f01007c6:	89 e5                	mov    %esp,%ebp
f01007c8:	57                   	push   %edi
f01007c9:	56                   	push   %esi
f01007ca:	53                   	push   %ebx
f01007cb:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01007ce:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f01007d0:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f01007d2:	85 c0                	test   %eax,%eax
f01007d4:	74 6d                	je     f0100843 <mon_backtrace+0x7e>
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f01007d6:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
f01007d9:	8b 5e 04             	mov    0x4(%esi),%ebx
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f01007dc:	ff 76 18             	pushl  0x18(%esi)
f01007df:	ff 76 14             	pushl  0x14(%esi)
f01007e2:	ff 76 10             	pushl  0x10(%esi)
f01007e5:	ff 76 0c             	pushl  0xc(%esi)
f01007e8:	ff 76 08             	pushl  0x8(%esi)
f01007eb:	53                   	push   %ebx
f01007ec:	56                   	push   %esi
f01007ed:	68 fc 2e 10 f0       	push   $0xf0102efc
f01007f2:	e8 76 11 00 00       	call   f010196d <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f01007f7:	83 c4 18             	add    $0x18,%esp
f01007fa:	57                   	push   %edi
f01007fb:	ff 76 04             	pushl  0x4(%esi)
f01007fe:	e8 a6 12 00 00       	call   f0101aa9 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100803:	83 c4 0c             	add    $0xc,%esp
f0100806:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100809:	ff 75 d0             	pushl  -0x30(%ebp)
f010080c:	68 ce 2b 10 f0       	push   $0xf0102bce
f0100811:	e8 57 11 00 00       	call   f010196d <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100816:	83 c4 0c             	add    $0xc,%esp
f0100819:	ff 75 d8             	pushl  -0x28(%ebp)
f010081c:	ff 75 dc             	pushl  -0x24(%ebp)
f010081f:	68 de 2b 10 f0       	push   $0xf0102bde
f0100824:	e8 44 11 00 00       	call   f010196d <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100829:	83 c4 08             	add    $0x8,%esp
f010082c:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f010082f:	53                   	push   %ebx
f0100830:	68 e3 2b 10 f0       	push   $0xf0102be3
f0100835:	e8 33 11 00 00       	call   f010196d <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f010083a:	8b 36                	mov    (%esi),%esi
f010083c:	83 c4 10             	add    $0x10,%esp
f010083f:	85 f6                	test   %esi,%esi
f0100841:	75 96                	jne    f01007d9 <mon_backtrace+0x14>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100843:	b8 00 00 00 00       	mov    $0x0,%eax
f0100848:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010084b:	5b                   	pop    %ebx
f010084c:	5e                   	pop    %esi
f010084d:	5f                   	pop    %edi
f010084e:	c9                   	leave  
f010084f:	c3                   	ret    

f0100850 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100850:	55                   	push   %ebp
f0100851:	89 e5                	mov    %esp,%ebp
f0100853:	57                   	push   %edi
f0100854:	56                   	push   %esi
f0100855:	53                   	push   %ebx
f0100856:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100859:	68 34 2f 10 f0       	push   $0xf0102f34
f010085e:	e8 0a 11 00 00       	call   f010196d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100863:	c7 04 24 58 2f 10 f0 	movl   $0xf0102f58,(%esp)
f010086a:	e8 fe 10 00 00       	call   f010196d <cprintf>
f010086f:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100872:	83 ec 0c             	sub    $0xc,%esp
f0100875:	68 e8 2b 10 f0       	push   $0xf0102be8
f010087a:	e8 85 19 00 00       	call   f0102204 <readline>
f010087f:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100881:	83 c4 10             	add    $0x10,%esp
f0100884:	85 c0                	test   %eax,%eax
f0100886:	74 ea                	je     f0100872 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100888:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010088f:	be 00 00 00 00       	mov    $0x0,%esi
f0100894:	eb 04                	jmp    f010089a <monitor+0x4a>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100896:	c6 03 00             	movb   $0x0,(%ebx)
f0100899:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010089a:	8a 03                	mov    (%ebx),%al
f010089c:	84 c0                	test   %al,%al
f010089e:	74 64                	je     f0100904 <monitor+0xb4>
f01008a0:	83 ec 08             	sub    $0x8,%esp
f01008a3:	0f be c0             	movsbl %al,%eax
f01008a6:	50                   	push   %eax
f01008a7:	68 ec 2b 10 f0       	push   $0xf0102bec
f01008ac:	e8 9c 1b 00 00       	call   f010244d <strchr>
f01008b1:	83 c4 10             	add    $0x10,%esp
f01008b4:	85 c0                	test   %eax,%eax
f01008b6:	75 de                	jne    f0100896 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01008b8:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008bb:	74 47                	je     f0100904 <monitor+0xb4>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008bd:	83 fe 0f             	cmp    $0xf,%esi
f01008c0:	75 14                	jne    f01008d6 <monitor+0x86>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008c2:	83 ec 08             	sub    $0x8,%esp
f01008c5:	6a 10                	push   $0x10
f01008c7:	68 f1 2b 10 f0       	push   $0xf0102bf1
f01008cc:	e8 9c 10 00 00       	call   f010196d <cprintf>
f01008d1:	83 c4 10             	add    $0x10,%esp
f01008d4:	eb 9c                	jmp    f0100872 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01008d6:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008da:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008db:	8a 03                	mov    (%ebx),%al
f01008dd:	84 c0                	test   %al,%al
f01008df:	75 09                	jne    f01008ea <monitor+0x9a>
f01008e1:	eb b7                	jmp    f010089a <monitor+0x4a>
			buf++;
f01008e3:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008e4:	8a 03                	mov    (%ebx),%al
f01008e6:	84 c0                	test   %al,%al
f01008e8:	74 b0                	je     f010089a <monitor+0x4a>
f01008ea:	83 ec 08             	sub    $0x8,%esp
f01008ed:	0f be c0             	movsbl %al,%eax
f01008f0:	50                   	push   %eax
f01008f1:	68 ec 2b 10 f0       	push   $0xf0102bec
f01008f6:	e8 52 1b 00 00       	call   f010244d <strchr>
f01008fb:	83 c4 10             	add    $0x10,%esp
f01008fe:	85 c0                	test   %eax,%eax
f0100900:	74 e1                	je     f01008e3 <monitor+0x93>
f0100902:	eb 96                	jmp    f010089a <monitor+0x4a>
			buf++;
	}
	argv[argc] = 0;
f0100904:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010090b:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010090c:	85 f6                	test   %esi,%esi
f010090e:	0f 84 5e ff ff ff    	je     f0100872 <monitor+0x22>
f0100914:	bb c0 2f 10 f0       	mov    $0xf0102fc0,%ebx
f0100919:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010091e:	83 ec 08             	sub    $0x8,%esp
f0100921:	ff 33                	pushl  (%ebx)
f0100923:	ff 75 a8             	pushl  -0x58(%ebp)
f0100926:	e8 b4 1a 00 00       	call   f01023df <strcmp>
f010092b:	83 c4 10             	add    $0x10,%esp
f010092e:	85 c0                	test   %eax,%eax
f0100930:	75 20                	jne    f0100952 <monitor+0x102>
			return commands[i].func(argc, argv, tf);
f0100932:	83 ec 04             	sub    $0x4,%esp
f0100935:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100938:	ff 75 08             	pushl  0x8(%ebp)
f010093b:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010093e:	50                   	push   %eax
f010093f:	56                   	push   %esi
f0100940:	ff 97 c8 2f 10 f0    	call   *-0xfefd038(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100946:	83 c4 10             	add    $0x10,%esp
f0100949:	85 c0                	test   %eax,%eax
f010094b:	78 26                	js     f0100973 <monitor+0x123>
f010094d:	e9 20 ff ff ff       	jmp    f0100872 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100952:	47                   	inc    %edi
f0100953:	83 c3 0c             	add    $0xc,%ebx
f0100956:	83 ff 04             	cmp    $0x4,%edi
f0100959:	75 c3                	jne    f010091e <monitor+0xce>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010095b:	83 ec 08             	sub    $0x8,%esp
f010095e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100961:	68 0e 2c 10 f0       	push   $0xf0102c0e
f0100966:	e8 02 10 00 00       	call   f010196d <cprintf>
f010096b:	83 c4 10             	add    $0x10,%esp
f010096e:	e9 ff fe ff ff       	jmp    f0100872 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100973:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100976:	5b                   	pop    %ebx
f0100977:	5e                   	pop    %esi
f0100978:	5f                   	pop    %edi
f0100979:	c9                   	leave  
f010097a:	c3                   	ret    
	...

f010097c <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f010097c:	55                   	push   %ebp
f010097d:	89 e5                	mov    %esp,%ebp
f010097f:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100981:	83 3d 30 b5 11 f0 00 	cmpl   $0x0,0xf011b530
f0100988:	75 0f                	jne    f0100999 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010098a:	b8 4f c9 11 f0       	mov    $0xf011c94f,%eax
f010098f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100994:	a3 30 b5 11 f0       	mov    %eax,0xf011b530
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0100999:	a1 30 b5 11 f0       	mov    0xf011b530,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f010099e:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f01009a5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01009ab:	89 15 30 b5 11 f0    	mov    %edx,0xf011b530

	return result;
}
f01009b1:	c9                   	leave  
f01009b2:	c3                   	ret    

f01009b3 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009b3:	55                   	push   %ebp
f01009b4:	89 e5                	mov    %esp,%ebp
f01009b6:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01009b9:	89 d1                	mov    %edx,%ecx
f01009bb:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01009be:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009c1:	a8 01                	test   $0x1,%al
f01009c3:	74 42                	je     f0100a07 <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009ca:	89 c1                	mov    %eax,%ecx
f01009cc:	c1 e9 0c             	shr    $0xc,%ecx
f01009cf:	3b 0d 44 b9 11 f0    	cmp    0xf011b944,%ecx
f01009d5:	72 15                	jb     f01009ec <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009d7:	50                   	push   %eax
f01009d8:	68 f0 2f 10 f0       	push   $0xf0102ff0
f01009dd:	68 8c 02 00 00       	push   $0x28c
f01009e2:	68 f4 33 10 f0       	push   $0xf01033f4
f01009e7:	e8 9f f6 ff ff       	call   f010008b <_panic>
	if (!(p[PTX(va)] & PTE_P))
f01009ec:	c1 ea 0c             	shr    $0xc,%edx
f01009ef:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009f5:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009fc:	a8 01                	test   $0x1,%al
f01009fe:	74 0e                	je     f0100a0e <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a00:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a05:	eb 0c                	jmp    f0100a13 <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100a0c:	eb 05                	jmp    f0100a13 <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100a0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100a13:	c9                   	leave  
f0100a14:	c3                   	ret    

f0100a15 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a15:	55                   	push   %ebp
f0100a16:	89 e5                	mov    %esp,%ebp
f0100a18:	56                   	push   %esi
f0100a19:	53                   	push   %ebx
f0100a1a:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a1c:	83 ec 0c             	sub    $0xc,%esp
f0100a1f:	50                   	push   %eax
f0100a20:	e8 e7 0e 00 00       	call   f010190c <mc146818_read>
f0100a25:	89 c6                	mov    %eax,%esi
f0100a27:	43                   	inc    %ebx
f0100a28:	89 1c 24             	mov    %ebx,(%esp)
f0100a2b:	e8 dc 0e 00 00       	call   f010190c <mc146818_read>
f0100a30:	c1 e0 08             	shl    $0x8,%eax
f0100a33:	09 f0                	or     %esi,%eax
}
f0100a35:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a38:	5b                   	pop    %ebx
f0100a39:	5e                   	pop    %esi
f0100a3a:	c9                   	leave  
f0100a3b:	c3                   	ret    

f0100a3c <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a3c:	55                   	push   %ebp
f0100a3d:	89 e5                	mov    %esp,%ebp
f0100a3f:	57                   	push   %edi
f0100a40:	56                   	push   %esi
f0100a41:	53                   	push   %ebx
f0100a42:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a45:	3c 01                	cmp    $0x1,%al
f0100a47:	19 f6                	sbb    %esi,%esi
f0100a49:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100a4f:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100a50:	8b 1d 2c b5 11 f0    	mov    0xf011b52c,%ebx
f0100a56:	85 db                	test   %ebx,%ebx
f0100a58:	75 17                	jne    f0100a71 <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f0100a5a:	83 ec 04             	sub    $0x4,%esp
f0100a5d:	68 14 30 10 f0       	push   $0xf0103014
f0100a62:	68 cf 01 00 00       	push   $0x1cf
f0100a67:	68 f4 33 10 f0       	push   $0xf01033f4
f0100a6c:	e8 1a f6 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
f0100a71:	84 c0                	test   %al,%al
f0100a73:	74 50                	je     f0100ac5 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a75:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100a78:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100a7b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100a7e:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a81:	89 d8                	mov    %ebx,%eax
f0100a83:	2b 05 4c b9 11 f0    	sub    0xf011b94c,%eax
f0100a89:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a8c:	c1 e8 16             	shr    $0x16,%eax
f0100a8f:	39 c6                	cmp    %eax,%esi
f0100a91:	0f 96 c0             	setbe  %al
f0100a94:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100a97:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0100a9b:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100a9d:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100aa1:	8b 1b                	mov    (%ebx),%ebx
f0100aa3:	85 db                	test   %ebx,%ebx
f0100aa5:	75 da                	jne    f0100a81 <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100aa7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100aaa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ab0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100ab3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ab6:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ab8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100abb:	89 1d 2c b5 11 f0    	mov    %ebx,0xf011b52c
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ac1:	85 db                	test   %ebx,%ebx
f0100ac3:	74 57                	je     f0100b1c <check_page_free_list+0xe0>
f0100ac5:	89 d8                	mov    %ebx,%eax
f0100ac7:	2b 05 4c b9 11 f0    	sub    0xf011b94c,%eax
f0100acd:	c1 f8 03             	sar    $0x3,%eax
f0100ad0:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ad3:	89 c2                	mov    %eax,%edx
f0100ad5:	c1 ea 16             	shr    $0x16,%edx
f0100ad8:	39 d6                	cmp    %edx,%esi
f0100ada:	76 3a                	jbe    f0100b16 <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100adc:	89 c2                	mov    %eax,%edx
f0100ade:	c1 ea 0c             	shr    $0xc,%edx
f0100ae1:	3b 15 44 b9 11 f0    	cmp    0xf011b944,%edx
f0100ae7:	72 12                	jb     f0100afb <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ae9:	50                   	push   %eax
f0100aea:	68 f0 2f 10 f0       	push   $0xf0102ff0
f0100aef:	6a 52                	push   $0x52
f0100af1:	68 00 34 10 f0       	push   $0xf0103400
f0100af6:	e8 90 f5 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100afb:	83 ec 04             	sub    $0x4,%esp
f0100afe:	68 80 00 00 00       	push   $0x80
f0100b03:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100b08:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b0d:	50                   	push   %eax
f0100b0e:	e8 8a 19 00 00       	call   f010249d <memset>
f0100b13:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b16:	8b 1b                	mov    (%ebx),%ebx
f0100b18:	85 db                	test   %ebx,%ebx
f0100b1a:	75 a9                	jne    f0100ac5 <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b1c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b21:	e8 56 fe ff ff       	call   f010097c <boot_alloc>
f0100b26:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b29:	8b 15 2c b5 11 f0    	mov    0xf011b52c,%edx
f0100b2f:	85 d2                	test   %edx,%edx
f0100b31:	0f 84 80 01 00 00    	je     f0100cb7 <check_page_free_list+0x27b>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b37:	8b 1d 4c b9 11 f0    	mov    0xf011b94c,%ebx
f0100b3d:	39 da                	cmp    %ebx,%edx
f0100b3f:	72 43                	jb     f0100b84 <check_page_free_list+0x148>
		assert(pp < pages + npages);
f0100b41:	a1 44 b9 11 f0       	mov    0xf011b944,%eax
f0100b46:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100b49:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0100b4c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100b4f:	39 c2                	cmp    %eax,%edx
f0100b51:	73 4f                	jae    f0100ba2 <check_page_free_list+0x166>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b53:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100b56:	89 d0                	mov    %edx,%eax
f0100b58:	29 d8                	sub    %ebx,%eax
f0100b5a:	a8 07                	test   $0x7,%al
f0100b5c:	75 66                	jne    f0100bc4 <check_page_free_list+0x188>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b5e:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b61:	c1 e0 0c             	shl    $0xc,%eax
f0100b64:	74 7f                	je     f0100be5 <check_page_free_list+0x1a9>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b66:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b6b:	0f 84 94 00 00 00    	je     f0100c05 <check_page_free_list+0x1c9>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b71:	be 00 00 00 00       	mov    $0x0,%esi
f0100b76:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b7b:	e9 9e 00 00 00       	jmp    f0100c1e <check_page_free_list+0x1e2>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b80:	39 da                	cmp    %ebx,%edx
f0100b82:	73 19                	jae    f0100b9d <check_page_free_list+0x161>
f0100b84:	68 0e 34 10 f0       	push   $0xf010340e
f0100b89:	68 1a 34 10 f0       	push   $0xf010341a
f0100b8e:	68 e9 01 00 00       	push   $0x1e9
f0100b93:	68 f4 33 10 f0       	push   $0xf01033f4
f0100b98:	e8 ee f4 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100b9d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100ba0:	72 19                	jb     f0100bbb <check_page_free_list+0x17f>
f0100ba2:	68 2f 34 10 f0       	push   $0xf010342f
f0100ba7:	68 1a 34 10 f0       	push   $0xf010341a
f0100bac:	68 ea 01 00 00       	push   $0x1ea
f0100bb1:	68 f4 33 10 f0       	push   $0xf01033f4
f0100bb6:	e8 d0 f4 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bbb:	89 d0                	mov    %edx,%eax
f0100bbd:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100bc0:	a8 07                	test   $0x7,%al
f0100bc2:	74 19                	je     f0100bdd <check_page_free_list+0x1a1>
f0100bc4:	68 38 30 10 f0       	push   $0xf0103038
f0100bc9:	68 1a 34 10 f0       	push   $0xf010341a
f0100bce:	68 eb 01 00 00       	push   $0x1eb
f0100bd3:	68 f4 33 10 f0       	push   $0xf01033f4
f0100bd8:	e8 ae f4 ff ff       	call   f010008b <_panic>
f0100bdd:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100be0:	c1 e0 0c             	shl    $0xc,%eax
f0100be3:	75 19                	jne    f0100bfe <check_page_free_list+0x1c2>
f0100be5:	68 43 34 10 f0       	push   $0xf0103443
f0100bea:	68 1a 34 10 f0       	push   $0xf010341a
f0100bef:	68 ee 01 00 00       	push   $0x1ee
f0100bf4:	68 f4 33 10 f0       	push   $0xf01033f4
f0100bf9:	e8 8d f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bfe:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c03:	75 19                	jne    f0100c1e <check_page_free_list+0x1e2>
f0100c05:	68 54 34 10 f0       	push   $0xf0103454
f0100c0a:	68 1a 34 10 f0       	push   $0xf010341a
f0100c0f:	68 ef 01 00 00       	push   $0x1ef
f0100c14:	68 f4 33 10 f0       	push   $0xf01033f4
f0100c19:	e8 6d f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c1e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c23:	75 19                	jne    f0100c3e <check_page_free_list+0x202>
f0100c25:	68 6c 30 10 f0       	push   $0xf010306c
f0100c2a:	68 1a 34 10 f0       	push   $0xf010341a
f0100c2f:	68 f0 01 00 00       	push   $0x1f0
f0100c34:	68 f4 33 10 f0       	push   $0xf01033f4
f0100c39:	e8 4d f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c3e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c43:	75 19                	jne    f0100c5e <check_page_free_list+0x222>
f0100c45:	68 6d 34 10 f0       	push   $0xf010346d
f0100c4a:	68 1a 34 10 f0       	push   $0xf010341a
f0100c4f:	68 f1 01 00 00       	push   $0x1f1
f0100c54:	68 f4 33 10 f0       	push   $0xf01033f4
f0100c59:	e8 2d f4 ff ff       	call   f010008b <_panic>
f0100c5e:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c60:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c65:	76 3e                	jbe    f0100ca5 <check_page_free_list+0x269>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c67:	c1 e8 0c             	shr    $0xc,%eax
f0100c6a:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c6d:	77 12                	ja     f0100c81 <check_page_free_list+0x245>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c6f:	51                   	push   %ecx
f0100c70:	68 f0 2f 10 f0       	push   $0xf0102ff0
f0100c75:	6a 52                	push   $0x52
f0100c77:	68 00 34 10 f0       	push   $0xf0103400
f0100c7c:	e8 0a f4 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0100c81:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0100c87:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100c8a:	76 1c                	jbe    f0100ca8 <check_page_free_list+0x26c>
f0100c8c:	68 90 30 10 f0       	push   $0xf0103090
f0100c91:	68 1a 34 10 f0       	push   $0xf010341a
f0100c96:	68 f2 01 00 00       	push   $0x1f2
f0100c9b:	68 f4 33 10 f0       	push   $0xf01033f4
f0100ca0:	e8 e6 f3 ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100ca5:	47                   	inc    %edi
f0100ca6:	eb 01                	jmp    f0100ca9 <check_page_free_list+0x26d>
		else
			++nfree_extmem;
f0100ca8:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca9:	8b 12                	mov    (%edx),%edx
f0100cab:	85 d2                	test   %edx,%edx
f0100cad:	0f 85 cd fe ff ff    	jne    f0100b80 <check_page_free_list+0x144>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100cb3:	85 ff                	test   %edi,%edi
f0100cb5:	7f 19                	jg     f0100cd0 <check_page_free_list+0x294>
f0100cb7:	68 87 34 10 f0       	push   $0xf0103487
f0100cbc:	68 1a 34 10 f0       	push   $0xf010341a
f0100cc1:	68 fa 01 00 00       	push   $0x1fa
f0100cc6:	68 f4 33 10 f0       	push   $0xf01033f4
f0100ccb:	e8 bb f3 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100cd0:	85 f6                	test   %esi,%esi
f0100cd2:	7f 19                	jg     f0100ced <check_page_free_list+0x2b1>
f0100cd4:	68 99 34 10 f0       	push   $0xf0103499
f0100cd9:	68 1a 34 10 f0       	push   $0xf010341a
f0100cde:	68 fb 01 00 00       	push   $0x1fb
f0100ce3:	68 f4 33 10 f0       	push   $0xf01033f4
f0100ce8:	e8 9e f3 ff ff       	call   f010008b <_panic>
}
f0100ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cf0:	5b                   	pop    %ebx
f0100cf1:	5e                   	pop    %esi
f0100cf2:	5f                   	pop    %edi
f0100cf3:	c9                   	leave  
f0100cf4:	c3                   	ret    

f0100cf5 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100cf5:	55                   	push   %ebp
f0100cf6:	89 e5                	mov    %esp,%ebp
f0100cf8:	56                   	push   %esi
f0100cf9:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f0100cfa:	c7 05 2c b5 11 f0 00 	movl   $0x0,0xf011b52c
f0100d01:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f0100d04:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d09:	e8 6e fc ff ff       	call   f010097c <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d0e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d13:	77 15                	ja     f0100d2a <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d15:	50                   	push   %eax
f0100d16:	68 d8 30 10 f0       	push   $0xf01030d8
f0100d1b:	68 00 01 00 00       	push   $0x100
f0100d20:	68 f4 33 10 f0       	push   $0xf01033f4
f0100d25:	e8 61 f3 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100d2a:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f0100d30:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f0100d33:	83 3d 44 b9 11 f0 00 	cmpl   $0x0,0xf011b944
f0100d3a:	74 5f                	je     f0100d9b <page_init+0xa6>
f0100d3c:	8b 1d 2c b5 11 f0    	mov    0xf011b52c,%ebx
f0100d42:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d47:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f0100d4c:	85 c0                	test   %eax,%eax
f0100d4e:	74 25                	je     f0100d75 <page_init+0x80>
f0100d50:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0100d55:	76 04                	jbe    f0100d5b <page_init+0x66>
f0100d57:	39 c6                	cmp    %eax,%esi
f0100d59:	77 1a                	ja     f0100d75 <page_init+0x80>
		    pages[i].pp_ref = 0;
f0100d5b:	89 d1                	mov    %edx,%ecx
f0100d5d:	03 0d 4c b9 11 f0    	add    0xf011b94c,%ecx
f0100d63:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f0100d69:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f0100d6b:	89 d3                	mov    %edx,%ebx
f0100d6d:	03 1d 4c b9 11 f0    	add    0xf011b94c,%ebx
f0100d73:	eb 14                	jmp    f0100d89 <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f0100d75:	89 d1                	mov    %edx,%ecx
f0100d77:	03 0d 4c b9 11 f0    	add    0xf011b94c,%ecx
f0100d7d:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f0100d83:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// free pages!
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    for (i = 0; i < npages; i++) {
f0100d89:	40                   	inc    %eax
f0100d8a:	83 c2 08             	add    $0x8,%edx
f0100d8d:	39 05 44 b9 11 f0    	cmp    %eax,0xf011b944
f0100d93:	77 b7                	ja     f0100d4c <page_init+0x57>
f0100d95:	89 1d 2c b5 11 f0    	mov    %ebx,0xf011b52c
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f0100d9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100d9e:	5b                   	pop    %ebx
f0100d9f:	5e                   	pop    %esi
f0100da0:	c9                   	leave  
f0100da1:	c3                   	ret    

f0100da2 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100da2:	55                   	push   %ebp
f0100da3:	89 e5                	mov    %esp,%ebp
f0100da5:	53                   	push   %ebx
f0100da6:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if (page_free_list == NULL) {
f0100da9:	8b 1d 2c b5 11 f0    	mov    0xf011b52c,%ebx
f0100daf:	85 db                	test   %ebx,%ebx
f0100db1:	74 52                	je     f0100e05 <page_alloc+0x63>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f0100db3:	8b 03                	mov    (%ebx),%eax
f0100db5:	a3 2c b5 11 f0       	mov    %eax,0xf011b52c
        if (alloc_flags & ALLOC_ZERO) {
f0100dba:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100dbe:	74 45                	je     f0100e05 <page_alloc+0x63>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dc0:	89 d8                	mov    %ebx,%eax
f0100dc2:	2b 05 4c b9 11 f0    	sub    0xf011b94c,%eax
f0100dc8:	c1 f8 03             	sar    $0x3,%eax
f0100dcb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dce:	89 c2                	mov    %eax,%edx
f0100dd0:	c1 ea 0c             	shr    $0xc,%edx
f0100dd3:	3b 15 44 b9 11 f0    	cmp    0xf011b944,%edx
f0100dd9:	72 12                	jb     f0100ded <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ddb:	50                   	push   %eax
f0100ddc:	68 f0 2f 10 f0       	push   $0xf0102ff0
f0100de1:	6a 52                	push   $0x52
f0100de3:	68 00 34 10 f0       	push   $0xf0103400
f0100de8:	e8 9e f2 ff ff       	call   f010008b <_panic>
            memset(page2kva(alloc_page), 0, PGSIZE);
f0100ded:	83 ec 04             	sub    $0x4,%esp
f0100df0:	68 00 10 00 00       	push   $0x1000
f0100df5:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100df7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100dfc:	50                   	push   %eax
f0100dfd:	e8 9b 16 00 00       	call   f010249d <memset>
f0100e02:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f0100e05:	89 d8                	mov    %ebx,%eax
f0100e07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e0a:	c9                   	leave  
f0100e0b:	c3                   	ret    

f0100e0c <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100e0c:	55                   	push   %ebp
f0100e0d:	89 e5                	mov    %esp,%ebp
f0100e0f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f0100e12:	85 c0                	test   %eax,%eax
f0100e14:	74 14                	je     f0100e2a <page_free+0x1e>
f0100e16:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e1b:	75 0d                	jne    f0100e2a <page_free+0x1e>
    pp->pp_link = page_free_list;
f0100e1d:	8b 15 2c b5 11 f0    	mov    0xf011b52c,%edx
f0100e23:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0100e25:	a3 2c b5 11 f0       	mov    %eax,0xf011b52c
}
f0100e2a:	c9                   	leave  
f0100e2b:	c3                   	ret    

f0100e2c <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100e2c:	55                   	push   %ebp
f0100e2d:	89 e5                	mov    %esp,%ebp
f0100e2f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100e32:	8b 50 04             	mov    0x4(%eax),%edx
f0100e35:	4a                   	dec    %edx
f0100e36:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100e3a:	66 85 d2             	test   %dx,%dx
f0100e3d:	75 09                	jne    f0100e48 <page_decref+0x1c>
		page_free(pp);
f0100e3f:	50                   	push   %eax
f0100e40:	e8 c7 ff ff ff       	call   f0100e0c <page_free>
f0100e45:	83 c4 04             	add    $0x4,%esp
}
f0100e48:	c9                   	leave  
f0100e49:	c3                   	ret    

f0100e4a <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e4a:	55                   	push   %ebp
f0100e4b:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100e4d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e52:	c9                   	leave  
f0100e53:	c3                   	ret    

f0100e54 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100e54:	55                   	push   %ebp
f0100e55:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100e57:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e5c:	c9                   	leave  
f0100e5d:	c3                   	ret    

f0100e5e <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100e5e:	55                   	push   %ebp
f0100e5f:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100e61:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e66:	c9                   	leave  
f0100e67:	c3                   	ret    

f0100e68 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100e68:	55                   	push   %ebp
f0100e69:	89 e5                	mov    %esp,%ebp
f0100e6b:	57                   	push   %edi
f0100e6c:	56                   	push   %esi
f0100e6d:	53                   	push   %ebx
f0100e6e:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100e71:	b8 15 00 00 00       	mov    $0x15,%eax
f0100e76:	e8 9a fb ff ff       	call   f0100a15 <nvram_read>
f0100e7b:	c1 e0 0a             	shl    $0xa,%eax
f0100e7e:	89 c2                	mov    %eax,%edx
f0100e80:	85 c0                	test   %eax,%eax
f0100e82:	79 06                	jns    f0100e8a <mem_init+0x22>
f0100e84:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100e8a:	c1 fa 0c             	sar    $0xc,%edx
f0100e8d:	89 15 34 b5 11 f0    	mov    %edx,0xf011b534
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100e93:	b8 17 00 00 00       	mov    $0x17,%eax
f0100e98:	e8 78 fb ff ff       	call   f0100a15 <nvram_read>
f0100e9d:	89 c2                	mov    %eax,%edx
f0100e9f:	c1 e2 0a             	shl    $0xa,%edx
f0100ea2:	89 d0                	mov    %edx,%eax
f0100ea4:	85 d2                	test   %edx,%edx
f0100ea6:	79 06                	jns    f0100eae <mem_init+0x46>
f0100ea8:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100eae:	c1 f8 0c             	sar    $0xc,%eax
f0100eb1:	74 0e                	je     f0100ec1 <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100eb3:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0100eb9:	89 15 44 b9 11 f0    	mov    %edx,0xf011b944
f0100ebf:	eb 0c                	jmp    f0100ecd <mem_init+0x65>
	else
		npages = npages_basemem;
f0100ec1:	8b 15 34 b5 11 f0    	mov    0xf011b534,%edx
f0100ec7:	89 15 44 b9 11 f0    	mov    %edx,0xf011b944

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0100ecd:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100ed0:	c1 e8 0a             	shr    $0xa,%eax
f0100ed3:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100ed4:	a1 34 b5 11 f0       	mov    0xf011b534,%eax
f0100ed9:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100edc:	c1 e8 0a             	shr    $0xa,%eax
f0100edf:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0100ee0:	a1 44 b9 11 f0       	mov    0xf011b944,%eax
f0100ee5:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100ee8:	c1 e8 0a             	shr    $0xa,%eax
f0100eeb:	50                   	push   %eax
f0100eec:	68 fc 30 10 f0       	push   $0xf01030fc
f0100ef1:	e8 77 0a 00 00       	call   f010196d <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100ef6:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100efb:	e8 7c fa ff ff       	call   f010097c <boot_alloc>
f0100f00:	a3 48 b9 11 f0       	mov    %eax,0xf011b948
	memset(kern_pgdir, 0, PGSIZE);
f0100f05:	83 c4 0c             	add    $0xc,%esp
f0100f08:	68 00 10 00 00       	push   $0x1000
f0100f0d:	6a 00                	push   $0x0
f0100f0f:	50                   	push   %eax
f0100f10:	e8 88 15 00 00       	call   f010249d <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100f15:	a1 48 b9 11 f0       	mov    0xf011b948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f1a:	83 c4 10             	add    $0x10,%esp
f0100f1d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f22:	77 15                	ja     f0100f39 <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f24:	50                   	push   %eax
f0100f25:	68 d8 30 10 f0       	push   $0xf01030d8
f0100f2a:	68 8d 00 00 00       	push   $0x8d
f0100f2f:	68 f4 33 10 f0       	push   $0xf01033f4
f0100f34:	e8 52 f1 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100f39:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100f3f:	83 ca 05             	or     $0x5,%edx
f0100f42:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0100f48:	a1 44 b9 11 f0       	mov    0xf011b944,%eax
f0100f4d:	c1 e0 03             	shl    $0x3,%eax
f0100f50:	e8 27 fa ff ff       	call   f010097c <boot_alloc>
f0100f55:	a3 4c b9 11 f0       	mov    %eax,0xf011b94c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0100f5a:	e8 96 fd ff ff       	call   f0100cf5 <page_init>

	check_page_free_list(1);
f0100f5f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100f64:	e8 d3 fa ff ff       	call   f0100a3c <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0100f69:	83 3d 4c b9 11 f0 00 	cmpl   $0x0,0xf011b94c
f0100f70:	75 17                	jne    f0100f89 <mem_init+0x121>
		panic("'pages' is a null pointer!");
f0100f72:	83 ec 04             	sub    $0x4,%esp
f0100f75:	68 aa 34 10 f0       	push   $0xf01034aa
f0100f7a:	68 0c 02 00 00       	push   $0x20c
f0100f7f:	68 f4 33 10 f0       	push   $0xf01033f4
f0100f84:	e8 02 f1 ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100f89:	a1 2c b5 11 f0       	mov    0xf011b52c,%eax
f0100f8e:	85 c0                	test   %eax,%eax
f0100f90:	74 0e                	je     f0100fa0 <mem_init+0x138>
f0100f92:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0100f97:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100f98:	8b 00                	mov    (%eax),%eax
f0100f9a:	85 c0                	test   %eax,%eax
f0100f9c:	75 f9                	jne    f0100f97 <mem_init+0x12f>
f0100f9e:	eb 05                	jmp    f0100fa5 <mem_init+0x13d>
f0100fa0:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0100fa5:	83 ec 0c             	sub    $0xc,%esp
f0100fa8:	6a 00                	push   $0x0
f0100faa:	e8 f3 fd ff ff       	call   f0100da2 <page_alloc>
f0100faf:	89 c6                	mov    %eax,%esi
f0100fb1:	83 c4 10             	add    $0x10,%esp
f0100fb4:	85 c0                	test   %eax,%eax
f0100fb6:	75 19                	jne    f0100fd1 <mem_init+0x169>
f0100fb8:	68 c5 34 10 f0       	push   $0xf01034c5
f0100fbd:	68 1a 34 10 f0       	push   $0xf010341a
f0100fc2:	68 14 02 00 00       	push   $0x214
f0100fc7:	68 f4 33 10 f0       	push   $0xf01033f4
f0100fcc:	e8 ba f0 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0100fd1:	83 ec 0c             	sub    $0xc,%esp
f0100fd4:	6a 00                	push   $0x0
f0100fd6:	e8 c7 fd ff ff       	call   f0100da2 <page_alloc>
f0100fdb:	89 c7                	mov    %eax,%edi
f0100fdd:	83 c4 10             	add    $0x10,%esp
f0100fe0:	85 c0                	test   %eax,%eax
f0100fe2:	75 19                	jne    f0100ffd <mem_init+0x195>
f0100fe4:	68 db 34 10 f0       	push   $0xf01034db
f0100fe9:	68 1a 34 10 f0       	push   $0xf010341a
f0100fee:	68 15 02 00 00       	push   $0x215
f0100ff3:	68 f4 33 10 f0       	push   $0xf01033f4
f0100ff8:	e8 8e f0 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0100ffd:	83 ec 0c             	sub    $0xc,%esp
f0101000:	6a 00                	push   $0x0
f0101002:	e8 9b fd ff ff       	call   f0100da2 <page_alloc>
f0101007:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010100a:	83 c4 10             	add    $0x10,%esp
f010100d:	85 c0                	test   %eax,%eax
f010100f:	75 19                	jne    f010102a <mem_init+0x1c2>
f0101011:	68 f1 34 10 f0       	push   $0xf01034f1
f0101016:	68 1a 34 10 f0       	push   $0xf010341a
f010101b:	68 16 02 00 00       	push   $0x216
f0101020:	68 f4 33 10 f0       	push   $0xf01033f4
f0101025:	e8 61 f0 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010102a:	39 fe                	cmp    %edi,%esi
f010102c:	75 19                	jne    f0101047 <mem_init+0x1df>
f010102e:	68 07 35 10 f0       	push   $0xf0103507
f0101033:	68 1a 34 10 f0       	push   $0xf010341a
f0101038:	68 19 02 00 00       	push   $0x219
f010103d:	68 f4 33 10 f0       	push   $0xf01033f4
f0101042:	e8 44 f0 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101047:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010104a:	74 05                	je     f0101051 <mem_init+0x1e9>
f010104c:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010104f:	75 19                	jne    f010106a <mem_init+0x202>
f0101051:	68 38 31 10 f0       	push   $0xf0103138
f0101056:	68 1a 34 10 f0       	push   $0xf010341a
f010105b:	68 1a 02 00 00       	push   $0x21a
f0101060:	68 f4 33 10 f0       	push   $0xf01033f4
f0101065:	e8 21 f0 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010106a:	8b 15 4c b9 11 f0    	mov    0xf011b94c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101070:	a1 44 b9 11 f0       	mov    0xf011b944,%eax
f0101075:	c1 e0 0c             	shl    $0xc,%eax
f0101078:	89 f1                	mov    %esi,%ecx
f010107a:	29 d1                	sub    %edx,%ecx
f010107c:	c1 f9 03             	sar    $0x3,%ecx
f010107f:	c1 e1 0c             	shl    $0xc,%ecx
f0101082:	39 c1                	cmp    %eax,%ecx
f0101084:	72 19                	jb     f010109f <mem_init+0x237>
f0101086:	68 19 35 10 f0       	push   $0xf0103519
f010108b:	68 1a 34 10 f0       	push   $0xf010341a
f0101090:	68 1b 02 00 00       	push   $0x21b
f0101095:	68 f4 33 10 f0       	push   $0xf01033f4
f010109a:	e8 ec ef ff ff       	call   f010008b <_panic>
f010109f:	89 f9                	mov    %edi,%ecx
f01010a1:	29 d1                	sub    %edx,%ecx
f01010a3:	c1 f9 03             	sar    $0x3,%ecx
f01010a6:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01010a9:	39 c8                	cmp    %ecx,%eax
f01010ab:	77 19                	ja     f01010c6 <mem_init+0x25e>
f01010ad:	68 36 35 10 f0       	push   $0xf0103536
f01010b2:	68 1a 34 10 f0       	push   $0xf010341a
f01010b7:	68 1c 02 00 00       	push   $0x21c
f01010bc:	68 f4 33 10 f0       	push   $0xf01033f4
f01010c1:	e8 c5 ef ff ff       	call   f010008b <_panic>
f01010c6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01010c9:	29 d1                	sub    %edx,%ecx
f01010cb:	89 ca                	mov    %ecx,%edx
f01010cd:	c1 fa 03             	sar    $0x3,%edx
f01010d0:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01010d3:	39 d0                	cmp    %edx,%eax
f01010d5:	77 19                	ja     f01010f0 <mem_init+0x288>
f01010d7:	68 53 35 10 f0       	push   $0xf0103553
f01010dc:	68 1a 34 10 f0       	push   $0xf010341a
f01010e1:	68 1d 02 00 00       	push   $0x21d
f01010e6:	68 f4 33 10 f0       	push   $0xf01033f4
f01010eb:	e8 9b ef ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01010f0:	a1 2c b5 11 f0       	mov    0xf011b52c,%eax
f01010f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01010f8:	c7 05 2c b5 11 f0 00 	movl   $0x0,0xf011b52c
f01010ff:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101102:	83 ec 0c             	sub    $0xc,%esp
f0101105:	6a 00                	push   $0x0
f0101107:	e8 96 fc ff ff       	call   f0100da2 <page_alloc>
f010110c:	83 c4 10             	add    $0x10,%esp
f010110f:	85 c0                	test   %eax,%eax
f0101111:	74 19                	je     f010112c <mem_init+0x2c4>
f0101113:	68 70 35 10 f0       	push   $0xf0103570
f0101118:	68 1a 34 10 f0       	push   $0xf010341a
f010111d:	68 24 02 00 00       	push   $0x224
f0101122:	68 f4 33 10 f0       	push   $0xf01033f4
f0101127:	e8 5f ef ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f010112c:	83 ec 0c             	sub    $0xc,%esp
f010112f:	56                   	push   %esi
f0101130:	e8 d7 fc ff ff       	call   f0100e0c <page_free>
	page_free(pp1);
f0101135:	89 3c 24             	mov    %edi,(%esp)
f0101138:	e8 cf fc ff ff       	call   f0100e0c <page_free>
	page_free(pp2);
f010113d:	83 c4 04             	add    $0x4,%esp
f0101140:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101143:	e8 c4 fc ff ff       	call   f0100e0c <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101148:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010114f:	e8 4e fc ff ff       	call   f0100da2 <page_alloc>
f0101154:	89 c6                	mov    %eax,%esi
f0101156:	83 c4 10             	add    $0x10,%esp
f0101159:	85 c0                	test   %eax,%eax
f010115b:	75 19                	jne    f0101176 <mem_init+0x30e>
f010115d:	68 c5 34 10 f0       	push   $0xf01034c5
f0101162:	68 1a 34 10 f0       	push   $0xf010341a
f0101167:	68 2b 02 00 00       	push   $0x22b
f010116c:	68 f4 33 10 f0       	push   $0xf01033f4
f0101171:	e8 15 ef ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101176:	83 ec 0c             	sub    $0xc,%esp
f0101179:	6a 00                	push   $0x0
f010117b:	e8 22 fc ff ff       	call   f0100da2 <page_alloc>
f0101180:	89 c7                	mov    %eax,%edi
f0101182:	83 c4 10             	add    $0x10,%esp
f0101185:	85 c0                	test   %eax,%eax
f0101187:	75 19                	jne    f01011a2 <mem_init+0x33a>
f0101189:	68 db 34 10 f0       	push   $0xf01034db
f010118e:	68 1a 34 10 f0       	push   $0xf010341a
f0101193:	68 2c 02 00 00       	push   $0x22c
f0101198:	68 f4 33 10 f0       	push   $0xf01033f4
f010119d:	e8 e9 ee ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01011a2:	83 ec 0c             	sub    $0xc,%esp
f01011a5:	6a 00                	push   $0x0
f01011a7:	e8 f6 fb ff ff       	call   f0100da2 <page_alloc>
f01011ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011af:	83 c4 10             	add    $0x10,%esp
f01011b2:	85 c0                	test   %eax,%eax
f01011b4:	75 19                	jne    f01011cf <mem_init+0x367>
f01011b6:	68 f1 34 10 f0       	push   $0xf01034f1
f01011bb:	68 1a 34 10 f0       	push   $0xf010341a
f01011c0:	68 2d 02 00 00       	push   $0x22d
f01011c5:	68 f4 33 10 f0       	push   $0xf01033f4
f01011ca:	e8 bc ee ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01011cf:	39 fe                	cmp    %edi,%esi
f01011d1:	75 19                	jne    f01011ec <mem_init+0x384>
f01011d3:	68 07 35 10 f0       	push   $0xf0103507
f01011d8:	68 1a 34 10 f0       	push   $0xf010341a
f01011dd:	68 2f 02 00 00       	push   $0x22f
f01011e2:	68 f4 33 10 f0       	push   $0xf01033f4
f01011e7:	e8 9f ee ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01011ec:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01011ef:	74 05                	je     f01011f6 <mem_init+0x38e>
f01011f1:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01011f4:	75 19                	jne    f010120f <mem_init+0x3a7>
f01011f6:	68 38 31 10 f0       	push   $0xf0103138
f01011fb:	68 1a 34 10 f0       	push   $0xf010341a
f0101200:	68 30 02 00 00       	push   $0x230
f0101205:	68 f4 33 10 f0       	push   $0xf01033f4
f010120a:	e8 7c ee ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f010120f:	83 ec 0c             	sub    $0xc,%esp
f0101212:	6a 00                	push   $0x0
f0101214:	e8 89 fb ff ff       	call   f0100da2 <page_alloc>
f0101219:	83 c4 10             	add    $0x10,%esp
f010121c:	85 c0                	test   %eax,%eax
f010121e:	74 19                	je     f0101239 <mem_init+0x3d1>
f0101220:	68 70 35 10 f0       	push   $0xf0103570
f0101225:	68 1a 34 10 f0       	push   $0xf010341a
f010122a:	68 31 02 00 00       	push   $0x231
f010122f:	68 f4 33 10 f0       	push   $0xf01033f4
f0101234:	e8 52 ee ff ff       	call   f010008b <_panic>
f0101239:	89 f0                	mov    %esi,%eax
f010123b:	2b 05 4c b9 11 f0    	sub    0xf011b94c,%eax
f0101241:	c1 f8 03             	sar    $0x3,%eax
f0101244:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101247:	89 c2                	mov    %eax,%edx
f0101249:	c1 ea 0c             	shr    $0xc,%edx
f010124c:	3b 15 44 b9 11 f0    	cmp    0xf011b944,%edx
f0101252:	72 12                	jb     f0101266 <mem_init+0x3fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101254:	50                   	push   %eax
f0101255:	68 f0 2f 10 f0       	push   $0xf0102ff0
f010125a:	6a 52                	push   $0x52
f010125c:	68 00 34 10 f0       	push   $0xf0103400
f0101261:	e8 25 ee ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101266:	83 ec 04             	sub    $0x4,%esp
f0101269:	68 00 10 00 00       	push   $0x1000
f010126e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101270:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101275:	50                   	push   %eax
f0101276:	e8 22 12 00 00       	call   f010249d <memset>
	page_free(pp0);
f010127b:	89 34 24             	mov    %esi,(%esp)
f010127e:	e8 89 fb ff ff       	call   f0100e0c <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101283:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010128a:	e8 13 fb ff ff       	call   f0100da2 <page_alloc>
f010128f:	83 c4 10             	add    $0x10,%esp
f0101292:	85 c0                	test   %eax,%eax
f0101294:	75 19                	jne    f01012af <mem_init+0x447>
f0101296:	68 7f 35 10 f0       	push   $0xf010357f
f010129b:	68 1a 34 10 f0       	push   $0xf010341a
f01012a0:	68 36 02 00 00       	push   $0x236
f01012a5:	68 f4 33 10 f0       	push   $0xf01033f4
f01012aa:	e8 dc ed ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f01012af:	39 c6                	cmp    %eax,%esi
f01012b1:	74 19                	je     f01012cc <mem_init+0x464>
f01012b3:	68 9d 35 10 f0       	push   $0xf010359d
f01012b8:	68 1a 34 10 f0       	push   $0xf010341a
f01012bd:	68 37 02 00 00       	push   $0x237
f01012c2:	68 f4 33 10 f0       	push   $0xf01033f4
f01012c7:	e8 bf ed ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012cc:	89 f2                	mov    %esi,%edx
f01012ce:	2b 15 4c b9 11 f0    	sub    0xf011b94c,%edx
f01012d4:	c1 fa 03             	sar    $0x3,%edx
f01012d7:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012da:	89 d0                	mov    %edx,%eax
f01012dc:	c1 e8 0c             	shr    $0xc,%eax
f01012df:	3b 05 44 b9 11 f0    	cmp    0xf011b944,%eax
f01012e5:	72 12                	jb     f01012f9 <mem_init+0x491>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012e7:	52                   	push   %edx
f01012e8:	68 f0 2f 10 f0       	push   $0xf0102ff0
f01012ed:	6a 52                	push   $0x52
f01012ef:	68 00 34 10 f0       	push   $0xf0103400
f01012f4:	e8 92 ed ff ff       	call   f010008b <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01012f9:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101300:	75 11                	jne    f0101313 <mem_init+0x4ab>
f0101302:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101308:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010130e:	80 38 00             	cmpb   $0x0,(%eax)
f0101311:	74 19                	je     f010132c <mem_init+0x4c4>
f0101313:	68 ad 35 10 f0       	push   $0xf01035ad
f0101318:	68 1a 34 10 f0       	push   $0xf010341a
f010131d:	68 3a 02 00 00       	push   $0x23a
f0101322:	68 f4 33 10 f0       	push   $0xf01033f4
f0101327:	e8 5f ed ff ff       	call   f010008b <_panic>
f010132c:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010132d:	39 d0                	cmp    %edx,%eax
f010132f:	75 dd                	jne    f010130e <mem_init+0x4a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101331:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101334:	89 0d 2c b5 11 f0    	mov    %ecx,0xf011b52c

	// free the pages we took
	page_free(pp0);
f010133a:	83 ec 0c             	sub    $0xc,%esp
f010133d:	56                   	push   %esi
f010133e:	e8 c9 fa ff ff       	call   f0100e0c <page_free>
	page_free(pp1);
f0101343:	89 3c 24             	mov    %edi,(%esp)
f0101346:	e8 c1 fa ff ff       	call   f0100e0c <page_free>
	page_free(pp2);
f010134b:	83 c4 04             	add    $0x4,%esp
f010134e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101351:	e8 b6 fa ff ff       	call   f0100e0c <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101356:	a1 2c b5 11 f0       	mov    0xf011b52c,%eax
f010135b:	83 c4 10             	add    $0x10,%esp
f010135e:	85 c0                	test   %eax,%eax
f0101360:	74 07                	je     f0101369 <mem_init+0x501>
		--nfree;
f0101362:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101363:	8b 00                	mov    (%eax),%eax
f0101365:	85 c0                	test   %eax,%eax
f0101367:	75 f9                	jne    f0101362 <mem_init+0x4fa>
		--nfree;
	assert(nfree == 0);
f0101369:	85 db                	test   %ebx,%ebx
f010136b:	74 19                	je     f0101386 <mem_init+0x51e>
f010136d:	68 b7 35 10 f0       	push   $0xf01035b7
f0101372:	68 1a 34 10 f0       	push   $0xf010341a
f0101377:	68 47 02 00 00       	push   $0x247
f010137c:	68 f4 33 10 f0       	push   $0xf01033f4
f0101381:	e8 05 ed ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101386:	83 ec 0c             	sub    $0xc,%esp
f0101389:	68 58 31 10 f0       	push   $0xf0103158
f010138e:	e8 da 05 00 00       	call   f010196d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101393:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010139a:	e8 03 fa ff ff       	call   f0100da2 <page_alloc>
f010139f:	89 c7                	mov    %eax,%edi
f01013a1:	83 c4 10             	add    $0x10,%esp
f01013a4:	85 c0                	test   %eax,%eax
f01013a6:	75 19                	jne    f01013c1 <mem_init+0x559>
f01013a8:	68 c5 34 10 f0       	push   $0xf01034c5
f01013ad:	68 1a 34 10 f0       	push   $0xf010341a
f01013b2:	68 a0 02 00 00       	push   $0x2a0
f01013b7:	68 f4 33 10 f0       	push   $0xf01033f4
f01013bc:	e8 ca ec ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01013c1:	83 ec 0c             	sub    $0xc,%esp
f01013c4:	6a 00                	push   $0x0
f01013c6:	e8 d7 f9 ff ff       	call   f0100da2 <page_alloc>
f01013cb:	89 c6                	mov    %eax,%esi
f01013cd:	83 c4 10             	add    $0x10,%esp
f01013d0:	85 c0                	test   %eax,%eax
f01013d2:	75 19                	jne    f01013ed <mem_init+0x585>
f01013d4:	68 db 34 10 f0       	push   $0xf01034db
f01013d9:	68 1a 34 10 f0       	push   $0xf010341a
f01013de:	68 a1 02 00 00       	push   $0x2a1
f01013e3:	68 f4 33 10 f0       	push   $0xf01033f4
f01013e8:	e8 9e ec ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01013ed:	83 ec 0c             	sub    $0xc,%esp
f01013f0:	6a 00                	push   $0x0
f01013f2:	e8 ab f9 ff ff       	call   f0100da2 <page_alloc>
f01013f7:	89 c3                	mov    %eax,%ebx
f01013f9:	83 c4 10             	add    $0x10,%esp
f01013fc:	85 c0                	test   %eax,%eax
f01013fe:	75 19                	jne    f0101419 <mem_init+0x5b1>
f0101400:	68 f1 34 10 f0       	push   $0xf01034f1
f0101405:	68 1a 34 10 f0       	push   $0xf010341a
f010140a:	68 a2 02 00 00       	push   $0x2a2
f010140f:	68 f4 33 10 f0       	push   $0xf01033f4
f0101414:	e8 72 ec ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101419:	39 f7                	cmp    %esi,%edi
f010141b:	75 19                	jne    f0101436 <mem_init+0x5ce>
f010141d:	68 07 35 10 f0       	push   $0xf0103507
f0101422:	68 1a 34 10 f0       	push   $0xf010341a
f0101427:	68 a5 02 00 00       	push   $0x2a5
f010142c:	68 f4 33 10 f0       	push   $0xf01033f4
f0101431:	e8 55 ec ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101436:	39 c6                	cmp    %eax,%esi
f0101438:	74 04                	je     f010143e <mem_init+0x5d6>
f010143a:	39 c7                	cmp    %eax,%edi
f010143c:	75 19                	jne    f0101457 <mem_init+0x5ef>
f010143e:	68 38 31 10 f0       	push   $0xf0103138
f0101443:	68 1a 34 10 f0       	push   $0xf010341a
f0101448:	68 a6 02 00 00       	push   $0x2a6
f010144d:	68 f4 33 10 f0       	push   $0xf01033f4
f0101452:	e8 34 ec ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;
f0101457:	c7 05 2c b5 11 f0 00 	movl   $0x0,0xf011b52c
f010145e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101461:	83 ec 0c             	sub    $0xc,%esp
f0101464:	6a 00                	push   $0x0
f0101466:	e8 37 f9 ff ff       	call   f0100da2 <page_alloc>
f010146b:	83 c4 10             	add    $0x10,%esp
f010146e:	85 c0                	test   %eax,%eax
f0101470:	74 19                	je     f010148b <mem_init+0x623>
f0101472:	68 70 35 10 f0       	push   $0xf0103570
f0101477:	68 1a 34 10 f0       	push   $0xf010341a
f010147c:	68 ad 02 00 00       	push   $0x2ad
f0101481:	68 f4 33 10 f0       	push   $0xf01033f4
f0101486:	e8 00 ec ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010148b:	a1 48 b9 11 f0       	mov    0xf011b948,%eax
f0101490:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101493:	83 ec 04             	sub    $0x4,%esp
f0101496:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101499:	50                   	push   %eax
f010149a:	6a 00                	push   $0x0
f010149c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010149f:	e8 ba f9 ff ff       	call   f0100e5e <page_lookup>
f01014a4:	83 c4 10             	add    $0x10,%esp
f01014a7:	85 c0                	test   %eax,%eax
f01014a9:	74 19                	je     f01014c4 <mem_init+0x65c>
f01014ab:	68 78 31 10 f0       	push   $0xf0103178
f01014b0:	68 1a 34 10 f0       	push   $0xf010341a
f01014b5:	68 b0 02 00 00       	push   $0x2b0
f01014ba:	68 f4 33 10 f0       	push   $0xf01033f4
f01014bf:	e8 c7 eb ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01014c4:	6a 02                	push   $0x2
f01014c6:	6a 00                	push   $0x0
f01014c8:	56                   	push   %esi
f01014c9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014cc:	e8 83 f9 ff ff       	call   f0100e54 <page_insert>
f01014d1:	83 c4 10             	add    $0x10,%esp
f01014d4:	85 c0                	test   %eax,%eax
f01014d6:	78 19                	js     f01014f1 <mem_init+0x689>
f01014d8:	68 b0 31 10 f0       	push   $0xf01031b0
f01014dd:	68 1a 34 10 f0       	push   $0xf010341a
f01014e2:	68 b3 02 00 00       	push   $0x2b3
f01014e7:	68 f4 33 10 f0       	push   $0xf01033f4
f01014ec:	e8 9a eb ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01014f1:	83 ec 0c             	sub    $0xc,%esp
f01014f4:	57                   	push   %edi
f01014f5:	e8 12 f9 ff ff       	call   f0100e0c <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01014fa:	8b 0d 48 b9 11 f0    	mov    0xf011b948,%ecx
f0101500:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101503:	6a 02                	push   $0x2
f0101505:	6a 00                	push   $0x0
f0101507:	56                   	push   %esi
f0101508:	51                   	push   %ecx
f0101509:	e8 46 f9 ff ff       	call   f0100e54 <page_insert>
f010150e:	83 c4 20             	add    $0x20,%esp
f0101511:	85 c0                	test   %eax,%eax
f0101513:	74 19                	je     f010152e <mem_init+0x6c6>
f0101515:	68 e0 31 10 f0       	push   $0xf01031e0
f010151a:	68 1a 34 10 f0       	push   $0xf010341a
f010151f:	68 b7 02 00 00       	push   $0x2b7
f0101524:	68 f4 33 10 f0       	push   $0xf01033f4
f0101529:	e8 5d eb ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010152e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101531:	8b 10                	mov    (%eax),%edx
f0101533:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101539:	89 f8                	mov    %edi,%eax
f010153b:	2b 05 4c b9 11 f0    	sub    0xf011b94c,%eax
f0101541:	c1 f8 03             	sar    $0x3,%eax
f0101544:	c1 e0 0c             	shl    $0xc,%eax
f0101547:	39 c2                	cmp    %eax,%edx
f0101549:	74 19                	je     f0101564 <mem_init+0x6fc>
f010154b:	68 10 32 10 f0       	push   $0xf0103210
f0101550:	68 1a 34 10 f0       	push   $0xf010341a
f0101555:	68 b8 02 00 00       	push   $0x2b8
f010155a:	68 f4 33 10 f0       	push   $0xf01033f4
f010155f:	e8 27 eb ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101564:	ba 00 00 00 00       	mov    $0x0,%edx
f0101569:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010156c:	e8 42 f4 ff ff       	call   f01009b3 <check_va2pa>
f0101571:	89 f2                	mov    %esi,%edx
f0101573:	2b 15 4c b9 11 f0    	sub    0xf011b94c,%edx
f0101579:	c1 fa 03             	sar    $0x3,%edx
f010157c:	c1 e2 0c             	shl    $0xc,%edx
f010157f:	39 d0                	cmp    %edx,%eax
f0101581:	74 19                	je     f010159c <mem_init+0x734>
f0101583:	68 38 32 10 f0       	push   $0xf0103238
f0101588:	68 1a 34 10 f0       	push   $0xf010341a
f010158d:	68 b9 02 00 00       	push   $0x2b9
f0101592:	68 f4 33 10 f0       	push   $0xf01033f4
f0101597:	e8 ef ea ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f010159c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01015a1:	74 19                	je     f01015bc <mem_init+0x754>
f01015a3:	68 c2 35 10 f0       	push   $0xf01035c2
f01015a8:	68 1a 34 10 f0       	push   $0xf010341a
f01015ad:	68 ba 02 00 00       	push   $0x2ba
f01015b2:	68 f4 33 10 f0       	push   $0xf01033f4
f01015b7:	e8 cf ea ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f01015bc:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01015c1:	74 19                	je     f01015dc <mem_init+0x774>
f01015c3:	68 d3 35 10 f0       	push   $0xf01035d3
f01015c8:	68 1a 34 10 f0       	push   $0xf010341a
f01015cd:	68 bb 02 00 00       	push   $0x2bb
f01015d2:	68 f4 33 10 f0       	push   $0xf01033f4
f01015d7:	e8 af ea ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01015dc:	8b 35 48 b9 11 f0    	mov    0xf011b948,%esi
f01015e2:	6a 02                	push   $0x2
f01015e4:	68 00 10 00 00       	push   $0x1000
f01015e9:	53                   	push   %ebx
f01015ea:	56                   	push   %esi
f01015eb:	e8 64 f8 ff ff       	call   f0100e54 <page_insert>
f01015f0:	83 c4 10             	add    $0x10,%esp
f01015f3:	85 c0                	test   %eax,%eax
f01015f5:	74 19                	je     f0101610 <mem_init+0x7a8>
f01015f7:	68 68 32 10 f0       	push   $0xf0103268
f01015fc:	68 1a 34 10 f0       	push   $0xf010341a
f0101601:	68 be 02 00 00       	push   $0x2be
f0101606:	68 f4 33 10 f0       	push   $0xf01033f4
f010160b:	e8 7b ea ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101610:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101615:	89 f0                	mov    %esi,%eax
f0101617:	e8 97 f3 ff ff       	call   f01009b3 <check_va2pa>
f010161c:	89 da                	mov    %ebx,%edx
f010161e:	2b 15 4c b9 11 f0    	sub    0xf011b94c,%edx
f0101624:	c1 fa 03             	sar    $0x3,%edx
f0101627:	c1 e2 0c             	shl    $0xc,%edx
f010162a:	39 d0                	cmp    %edx,%eax
f010162c:	74 19                	je     f0101647 <mem_init+0x7df>
f010162e:	68 a4 32 10 f0       	push   $0xf01032a4
f0101633:	68 1a 34 10 f0       	push   $0xf010341a
f0101638:	68 bf 02 00 00       	push   $0x2bf
f010163d:	68 f4 33 10 f0       	push   $0xf01033f4
f0101642:	e8 44 ea ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101647:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010164c:	74 19                	je     f0101667 <mem_init+0x7ff>
f010164e:	68 e4 35 10 f0       	push   $0xf01035e4
f0101653:	68 1a 34 10 f0       	push   $0xf010341a
f0101658:	68 c0 02 00 00       	push   $0x2c0
f010165d:	68 f4 33 10 f0       	push   $0xf01033f4
f0101662:	e8 24 ea ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101667:	83 ec 0c             	sub    $0xc,%esp
f010166a:	6a 00                	push   $0x0
f010166c:	e8 31 f7 ff ff       	call   f0100da2 <page_alloc>
f0101671:	83 c4 10             	add    $0x10,%esp
f0101674:	85 c0                	test   %eax,%eax
f0101676:	74 19                	je     f0101691 <mem_init+0x829>
f0101678:	68 70 35 10 f0       	push   $0xf0103570
f010167d:	68 1a 34 10 f0       	push   $0xf010341a
f0101682:	68 c3 02 00 00       	push   $0x2c3
f0101687:	68 f4 33 10 f0       	push   $0xf01033f4
f010168c:	e8 fa e9 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101691:	8b 35 48 b9 11 f0    	mov    0xf011b948,%esi
f0101697:	6a 02                	push   $0x2
f0101699:	68 00 10 00 00       	push   $0x1000
f010169e:	53                   	push   %ebx
f010169f:	56                   	push   %esi
f01016a0:	e8 af f7 ff ff       	call   f0100e54 <page_insert>
f01016a5:	83 c4 10             	add    $0x10,%esp
f01016a8:	85 c0                	test   %eax,%eax
f01016aa:	74 19                	je     f01016c5 <mem_init+0x85d>
f01016ac:	68 68 32 10 f0       	push   $0xf0103268
f01016b1:	68 1a 34 10 f0       	push   $0xf010341a
f01016b6:	68 c6 02 00 00       	push   $0x2c6
f01016bb:	68 f4 33 10 f0       	push   $0xf01033f4
f01016c0:	e8 c6 e9 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01016c5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01016ca:	89 f0                	mov    %esi,%eax
f01016cc:	e8 e2 f2 ff ff       	call   f01009b3 <check_va2pa>
f01016d1:	89 da                	mov    %ebx,%edx
f01016d3:	2b 15 4c b9 11 f0    	sub    0xf011b94c,%edx
f01016d9:	c1 fa 03             	sar    $0x3,%edx
f01016dc:	c1 e2 0c             	shl    $0xc,%edx
f01016df:	39 d0                	cmp    %edx,%eax
f01016e1:	74 19                	je     f01016fc <mem_init+0x894>
f01016e3:	68 a4 32 10 f0       	push   $0xf01032a4
f01016e8:	68 1a 34 10 f0       	push   $0xf010341a
f01016ed:	68 c7 02 00 00       	push   $0x2c7
f01016f2:	68 f4 33 10 f0       	push   $0xf01033f4
f01016f7:	e8 8f e9 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01016fc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101701:	74 19                	je     f010171c <mem_init+0x8b4>
f0101703:	68 e4 35 10 f0       	push   $0xf01035e4
f0101708:	68 1a 34 10 f0       	push   $0xf010341a
f010170d:	68 c8 02 00 00       	push   $0x2c8
f0101712:	68 f4 33 10 f0       	push   $0xf01033f4
f0101717:	e8 6f e9 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010171c:	83 ec 0c             	sub    $0xc,%esp
f010171f:	6a 00                	push   $0x0
f0101721:	e8 7c f6 ff ff       	call   f0100da2 <page_alloc>
f0101726:	83 c4 10             	add    $0x10,%esp
f0101729:	85 c0                	test   %eax,%eax
f010172b:	74 19                	je     f0101746 <mem_init+0x8de>
f010172d:	68 70 35 10 f0       	push   $0xf0103570
f0101732:	68 1a 34 10 f0       	push   $0xf010341a
f0101737:	68 cc 02 00 00       	push   $0x2cc
f010173c:	68 f4 33 10 f0       	push   $0xf01033f4
f0101741:	e8 45 e9 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101746:	8b 35 48 b9 11 f0    	mov    0xf011b948,%esi
f010174c:	8b 3e                	mov    (%esi),%edi
f010174e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101754:	89 f8                	mov    %edi,%eax
f0101756:	c1 e8 0c             	shr    $0xc,%eax
f0101759:	3b 05 44 b9 11 f0    	cmp    0xf011b944,%eax
f010175f:	72 15                	jb     f0101776 <mem_init+0x90e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101761:	57                   	push   %edi
f0101762:	68 f0 2f 10 f0       	push   $0xf0102ff0
f0101767:	68 cf 02 00 00       	push   $0x2cf
f010176c:	68 f4 33 10 f0       	push   $0xf01033f4
f0101771:	e8 15 e9 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101776:	8d 87 00 00 00 f0    	lea    -0x10000000(%edi),%eax
f010177c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010177f:	83 ec 04             	sub    $0x4,%esp
f0101782:	6a 00                	push   $0x0
f0101784:	68 00 10 00 00       	push   $0x1000
f0101789:	56                   	push   %esi
f010178a:	e8 bb f6 ff ff       	call   f0100e4a <pgdir_walk>
f010178f:	83 c4 10             	add    $0x10,%esp
f0101792:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101798:	39 f8                	cmp    %edi,%eax
f010179a:	74 19                	je     f01017b5 <mem_init+0x94d>
f010179c:	68 d4 32 10 f0       	push   $0xf01032d4
f01017a1:	68 1a 34 10 f0       	push   $0xf010341a
f01017a6:	68 d0 02 00 00       	push   $0x2d0
f01017ab:	68 f4 33 10 f0       	push   $0xf01033f4
f01017b0:	e8 d6 e8 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01017b5:	6a 06                	push   $0x6
f01017b7:	68 00 10 00 00       	push   $0x1000
f01017bc:	53                   	push   %ebx
f01017bd:	56                   	push   %esi
f01017be:	e8 91 f6 ff ff       	call   f0100e54 <page_insert>
f01017c3:	83 c4 10             	add    $0x10,%esp
f01017c6:	85 c0                	test   %eax,%eax
f01017c8:	74 19                	je     f01017e3 <mem_init+0x97b>
f01017ca:	68 14 33 10 f0       	push   $0xf0103314
f01017cf:	68 1a 34 10 f0       	push   $0xf010341a
f01017d4:	68 d3 02 00 00       	push   $0x2d3
f01017d9:	68 f4 33 10 f0       	push   $0xf01033f4
f01017de:	e8 a8 e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01017e3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01017e8:	89 f0                	mov    %esi,%eax
f01017ea:	e8 c4 f1 ff ff       	call   f01009b3 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017ef:	89 da                	mov    %ebx,%edx
f01017f1:	2b 15 4c b9 11 f0    	sub    0xf011b94c,%edx
f01017f7:	c1 fa 03             	sar    $0x3,%edx
f01017fa:	c1 e2 0c             	shl    $0xc,%edx
f01017fd:	39 d0                	cmp    %edx,%eax
f01017ff:	74 19                	je     f010181a <mem_init+0x9b2>
f0101801:	68 a4 32 10 f0       	push   $0xf01032a4
f0101806:	68 1a 34 10 f0       	push   $0xf010341a
f010180b:	68 d4 02 00 00       	push   $0x2d4
f0101810:	68 f4 33 10 f0       	push   $0xf01033f4
f0101815:	e8 71 e8 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f010181a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010181f:	74 19                	je     f010183a <mem_init+0x9d2>
f0101821:	68 e4 35 10 f0       	push   $0xf01035e4
f0101826:	68 1a 34 10 f0       	push   $0xf010341a
f010182b:	68 d5 02 00 00       	push   $0x2d5
f0101830:	68 f4 33 10 f0       	push   $0xf01033f4
f0101835:	e8 51 e8 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010183a:	8b 35 48 b9 11 f0    	mov    0xf011b948,%esi
f0101840:	83 ec 04             	sub    $0x4,%esp
f0101843:	6a 00                	push   $0x0
f0101845:	68 00 10 00 00       	push   $0x1000
f010184a:	56                   	push   %esi
f010184b:	e8 fa f5 ff ff       	call   f0100e4a <pgdir_walk>
f0101850:	83 c4 10             	add    $0x10,%esp
f0101853:	8b 38                	mov    (%eax),%edi
f0101855:	f7 c7 04 00 00 00    	test   $0x4,%edi
f010185b:	75 19                	jne    f0101876 <mem_init+0xa0e>
f010185d:	68 54 33 10 f0       	push   $0xf0103354
f0101862:	68 1a 34 10 f0       	push   $0xf010341a
f0101867:	68 d6 02 00 00       	push   $0x2d6
f010186c:	68 f4 33 10 f0       	push   $0xf01033f4
f0101871:	e8 15 e8 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101876:	f6 06 04             	testb  $0x4,(%esi)
f0101879:	75 19                	jne    f0101894 <mem_init+0xa2c>
f010187b:	68 f5 35 10 f0       	push   $0xf01035f5
f0101880:	68 1a 34 10 f0       	push   $0xf010341a
f0101885:	68 d7 02 00 00       	push   $0x2d7
f010188a:	68 f4 33 10 f0       	push   $0xf01033f4
f010188f:	e8 f7 e7 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101894:	6a 02                	push   $0x2
f0101896:	68 00 10 00 00       	push   $0x1000
f010189b:	53                   	push   %ebx
f010189c:	56                   	push   %esi
f010189d:	e8 b2 f5 ff ff       	call   f0100e54 <page_insert>
f01018a2:	83 c4 10             	add    $0x10,%esp
f01018a5:	85 c0                	test   %eax,%eax
f01018a7:	74 19                	je     f01018c2 <mem_init+0xa5a>
f01018a9:	68 68 32 10 f0       	push   $0xf0103268
f01018ae:	68 1a 34 10 f0       	push   $0xf010341a
f01018b3:	68 da 02 00 00       	push   $0x2da
f01018b8:	68 f4 33 10 f0       	push   $0xf01033f4
f01018bd:	e8 c9 e7 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01018c2:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01018c8:	75 19                	jne    f01018e3 <mem_init+0xa7b>
f01018ca:	68 88 33 10 f0       	push   $0xf0103388
f01018cf:	68 1a 34 10 f0       	push   $0xf010341a
f01018d4:	68 db 02 00 00       	push   $0x2db
f01018d9:	68 f4 33 10 f0       	push   $0xf01033f4
f01018de:	e8 a8 e7 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01018e3:	68 bc 33 10 f0       	push   $0xf01033bc
f01018e8:	68 1a 34 10 f0       	push   $0xf010341a
f01018ed:	68 dc 02 00 00       	push   $0x2dc
f01018f2:	68 f4 33 10 f0       	push   $0xf01033f4
f01018f7:	e8 8f e7 ff ff       	call   f010008b <_panic>

f01018fc <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01018fc:	55                   	push   %ebp
f01018fd:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f01018ff:	c9                   	leave  
f0101900:	c3                   	ret    

f0101901 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101901:	55                   	push   %ebp
f0101902:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101904:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101907:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010190a:	c9                   	leave  
f010190b:	c3                   	ret    

f010190c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010190c:	55                   	push   %ebp
f010190d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010190f:	ba 70 00 00 00       	mov    $0x70,%edx
f0101914:	8b 45 08             	mov    0x8(%ebp),%eax
f0101917:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0101918:	b2 71                	mov    $0x71,%dl
f010191a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010191b:	0f b6 c0             	movzbl %al,%eax
}
f010191e:	c9                   	leave  
f010191f:	c3                   	ret    

f0101920 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0101920:	55                   	push   %ebp
f0101921:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101923:	ba 70 00 00 00       	mov    $0x70,%edx
f0101928:	8b 45 08             	mov    0x8(%ebp),%eax
f010192b:	ee                   	out    %al,(%dx)
f010192c:	b2 71                	mov    $0x71,%dl
f010192e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101931:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0101932:	c9                   	leave  
f0101933:	c3                   	ret    

f0101934 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0101934:	55                   	push   %ebp
f0101935:	89 e5                	mov    %esp,%ebp
f0101937:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010193a:	ff 75 08             	pushl  0x8(%ebp)
f010193d:	e8 64 ec ff ff       	call   f01005a6 <cputchar>
f0101942:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0101945:	c9                   	leave  
f0101946:	c3                   	ret    

f0101947 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0101947:	55                   	push   %ebp
f0101948:	89 e5                	mov    %esp,%ebp
f010194a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010194d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0101954:	ff 75 0c             	pushl  0xc(%ebp)
f0101957:	ff 75 08             	pushl  0x8(%ebp)
f010195a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010195d:	50                   	push   %eax
f010195e:	68 34 19 10 f0       	push   $0xf0101934
f0101963:	e8 9d 04 00 00       	call   f0101e05 <vprintfmt>
	return cnt;
}
f0101968:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010196b:	c9                   	leave  
f010196c:	c3                   	ret    

f010196d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010196d:	55                   	push   %ebp
f010196e:	89 e5                	mov    %esp,%ebp
f0101970:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0101973:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0101976:	50                   	push   %eax
f0101977:	ff 75 08             	pushl  0x8(%ebp)
f010197a:	e8 c8 ff ff ff       	call   f0101947 <vcprintf>
	va_end(ap);

	return cnt;
}
f010197f:	c9                   	leave  
f0101980:	c3                   	ret    
f0101981:	00 00                	add    %al,(%eax)
	...

f0101984 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0101984:	55                   	push   %ebp
f0101985:	89 e5                	mov    %esp,%ebp
f0101987:	57                   	push   %edi
f0101988:	56                   	push   %esi
f0101989:	53                   	push   %ebx
f010198a:	83 ec 14             	sub    $0x14,%esp
f010198d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101990:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0101993:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101996:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0101999:	8b 1a                	mov    (%edx),%ebx
f010199b:	8b 01                	mov    (%ecx),%eax
f010199d:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f01019a0:	39 c3                	cmp    %eax,%ebx
f01019a2:	0f 8f 97 00 00 00    	jg     f0101a3f <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f01019a8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01019af:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01019b2:	01 d8                	add    %ebx,%eax
f01019b4:	89 c7                	mov    %eax,%edi
f01019b6:	c1 ef 1f             	shr    $0x1f,%edi
f01019b9:	01 c7                	add    %eax,%edi
f01019bb:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01019bd:	39 df                	cmp    %ebx,%edi
f01019bf:	7c 31                	jl     f01019f2 <stab_binsearch+0x6e>
f01019c1:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01019c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01019c7:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01019cc:	39 f0                	cmp    %esi,%eax
f01019ce:	0f 84 b3 00 00 00    	je     f0101a87 <stab_binsearch+0x103>
f01019d4:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01019d8:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01019dc:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01019de:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01019df:	39 d8                	cmp    %ebx,%eax
f01019e1:	7c 0f                	jl     f01019f2 <stab_binsearch+0x6e>
f01019e3:	0f b6 0a             	movzbl (%edx),%ecx
f01019e6:	83 ea 0c             	sub    $0xc,%edx
f01019e9:	39 f1                	cmp    %esi,%ecx
f01019eb:	75 f1                	jne    f01019de <stab_binsearch+0x5a>
f01019ed:	e9 97 00 00 00       	jmp    f0101a89 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01019f2:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01019f5:	eb 39                	jmp    f0101a30 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01019f7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01019fa:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f01019fc:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01019ff:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0101a06:	eb 28                	jmp    f0101a30 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0101a08:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0101a0b:	76 12                	jbe    f0101a1f <stab_binsearch+0x9b>
			*region_right = m - 1;
f0101a0d:	48                   	dec    %eax
f0101a0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101a11:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101a14:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101a16:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0101a1d:	eb 11                	jmp    f0101a30 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0101a1f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101a22:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0101a24:	ff 45 0c             	incl   0xc(%ebp)
f0101a27:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101a29:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0101a30:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0101a33:	0f 8d 76 ff ff ff    	jge    f01019af <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0101a39:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101a3d:	75 0d                	jne    f0101a4c <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0101a3f:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0101a42:	8b 03                	mov    (%ebx),%eax
f0101a44:	48                   	dec    %eax
f0101a45:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101a48:	89 02                	mov    %eax,(%edx)
f0101a4a:	eb 55                	jmp    f0101aa1 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101a4c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101a4f:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0101a51:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0101a54:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101a56:	39 c1                	cmp    %eax,%ecx
f0101a58:	7d 26                	jge    f0101a80 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0101a5a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0101a5d:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0101a60:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0101a65:	39 f2                	cmp    %esi,%edx
f0101a67:	74 17                	je     f0101a80 <stab_binsearch+0xfc>
f0101a69:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0101a6d:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0101a71:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101a72:	39 c1                	cmp    %eax,%ecx
f0101a74:	7d 0a                	jge    f0101a80 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0101a76:	0f b6 1a             	movzbl (%edx),%ebx
f0101a79:	83 ea 0c             	sub    $0xc,%edx
f0101a7c:	39 f3                	cmp    %esi,%ebx
f0101a7e:	75 f1                	jne    f0101a71 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0101a80:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101a83:	89 02                	mov    %eax,(%edx)
f0101a85:	eb 1a                	jmp    f0101aa1 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0101a87:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0101a89:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0101a8c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0101a8f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0101a93:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0101a96:	0f 82 5b ff ff ff    	jb     f01019f7 <stab_binsearch+0x73>
f0101a9c:	e9 67 ff ff ff       	jmp    f0101a08 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0101aa1:	83 c4 14             	add    $0x14,%esp
f0101aa4:	5b                   	pop    %ebx
f0101aa5:	5e                   	pop    %esi
f0101aa6:	5f                   	pop    %edi
f0101aa7:	c9                   	leave  
f0101aa8:	c3                   	ret    

f0101aa9 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0101aa9:	55                   	push   %ebp
f0101aaa:	89 e5                	mov    %esp,%ebp
f0101aac:	57                   	push   %edi
f0101aad:	56                   	push   %esi
f0101aae:	53                   	push   %ebx
f0101aaf:	83 ec 2c             	sub    $0x2c,%esp
f0101ab2:	8b 75 08             	mov    0x8(%ebp),%esi
f0101ab5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0101ab8:	c7 03 0b 36 10 f0    	movl   $0xf010360b,(%ebx)
	info->eip_line = 0;
f0101abe:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0101ac5:	c7 43 08 0b 36 10 f0 	movl   $0xf010360b,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0101acc:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0101ad3:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0101ad6:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0101add:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101ae3:	76 12                	jbe    f0101af7 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101ae5:	b8 bd 0c 11 f0       	mov    $0xf0110cbd,%eax
f0101aea:	3d 1d 95 10 f0       	cmp    $0xf010951d,%eax
f0101aef:	0f 86 90 01 00 00    	jbe    f0101c85 <debuginfo_eip+0x1dc>
f0101af5:	eb 14                	jmp    f0101b0b <debuginfo_eip+0x62>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0101af7:	83 ec 04             	sub    $0x4,%esp
f0101afa:	68 15 36 10 f0       	push   $0xf0103615
f0101aff:	6a 7f                	push   $0x7f
f0101b01:	68 22 36 10 f0       	push   $0xf0103622
f0101b06:	e8 80 e5 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0101b0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101b10:	80 3d bc 0c 11 f0 00 	cmpb   $0x0,0xf0110cbc
f0101b17:	0f 85 74 01 00 00    	jne    f0101c91 <debuginfo_eip+0x1e8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0101b1d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0101b24:	b8 1c 95 10 f0       	mov    $0xf010951c,%eax
f0101b29:	2d 40 38 10 f0       	sub    $0xf0103840,%eax
f0101b2e:	c1 f8 02             	sar    $0x2,%eax
f0101b31:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101b37:	48                   	dec    %eax
f0101b38:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0101b3b:	83 ec 08             	sub    $0x8,%esp
f0101b3e:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0101b41:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0101b44:	56                   	push   %esi
f0101b45:	6a 64                	push   $0x64
f0101b47:	b8 40 38 10 f0       	mov    $0xf0103840,%eax
f0101b4c:	e8 33 fe ff ff       	call   f0101984 <stab_binsearch>
	if (lfile == 0)
f0101b51:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101b54:	83 c4 10             	add    $0x10,%esp
		return -1;
f0101b57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0101b5c:	85 d2                	test   %edx,%edx
f0101b5e:	0f 84 2d 01 00 00    	je     f0101c91 <debuginfo_eip+0x1e8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0101b64:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0101b67:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101b6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0101b6d:	83 ec 08             	sub    $0x8,%esp
f0101b70:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0101b73:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101b76:	56                   	push   %esi
f0101b77:	6a 24                	push   $0x24
f0101b79:	b8 40 38 10 f0       	mov    $0xf0103840,%eax
f0101b7e:	e8 01 fe ff ff       	call   f0101984 <stab_binsearch>

	if (lfun <= rfun) {
f0101b83:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0101b86:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101b89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b8c:	83 c4 10             	add    $0x10,%esp
f0101b8f:	39 c7                	cmp    %eax,%edi
f0101b91:	7f 32                	jg     f0101bc5 <debuginfo_eip+0x11c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0101b93:	89 f9                	mov    %edi,%ecx
f0101b95:	6b c7 0c             	imul   $0xc,%edi,%eax
f0101b98:	8b 80 40 38 10 f0    	mov    -0xfefc7c0(%eax),%eax
f0101b9e:	ba bd 0c 11 f0       	mov    $0xf0110cbd,%edx
f0101ba3:	81 ea 1d 95 10 f0    	sub    $0xf010951d,%edx
f0101ba9:	39 d0                	cmp    %edx,%eax
f0101bab:	73 08                	jae    f0101bb5 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0101bad:	05 1d 95 10 f0       	add    $0xf010951d,%eax
f0101bb2:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0101bb5:	6b c9 0c             	imul   $0xc,%ecx,%ecx
f0101bb8:	8b 81 48 38 10 f0    	mov    -0xfefc7b8(%ecx),%eax
f0101bbe:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0101bc1:	29 c6                	sub    %eax,%esi
f0101bc3:	eb 0c                	jmp    f0101bd1 <debuginfo_eip+0x128>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0101bc5:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0101bc8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
f0101bcb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101bce:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0101bd1:	83 ec 08             	sub    $0x8,%esp
f0101bd4:	6a 3a                	push   $0x3a
f0101bd6:	ff 73 08             	pushl  0x8(%ebx)
f0101bd9:	e8 9d 08 00 00       	call   f010247b <strfind>
f0101bde:	2b 43 08             	sub    0x8(%ebx),%eax
f0101be1:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0101be4:	89 7d dc             	mov    %edi,-0x24(%ebp)
    rfun = rline;
f0101be7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bea:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0101bed:	83 c4 08             	add    $0x8,%esp
f0101bf0:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0101bf3:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101bf6:	56                   	push   %esi
f0101bf7:	6a 44                	push   $0x44
f0101bf9:	b8 40 38 10 f0       	mov    $0xf0103840,%eax
f0101bfe:	e8 81 fd ff ff       	call   f0101984 <stab_binsearch>
    if (lfun <= rfun) {
f0101c03:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101c06:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0101c09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0101c0e:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0101c11:	7f 7e                	jg     f0101c91 <debuginfo_eip+0x1e8>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0101c13:	6b c2 0c             	imul   $0xc,%edx,%eax
f0101c16:	05 40 38 10 f0       	add    $0xf0103840,%eax
f0101c1b:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0101c1f:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101c22:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0101c25:	83 c0 08             	add    $0x8,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101c28:	eb 04                	jmp    f0101c2e <debuginfo_eip+0x185>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0101c2a:	4a                   	dec    %edx
f0101c2b:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101c2e:	39 f2                	cmp    %esi,%edx
f0101c30:	7c 1b                	jl     f0101c4d <debuginfo_eip+0x1a4>
	       && stabs[lline].n_type != N_SOL
f0101c32:	8a 48 fc             	mov    -0x4(%eax),%cl
f0101c35:	80 f9 84             	cmp    $0x84,%cl
f0101c38:	74 5f                	je     f0101c99 <debuginfo_eip+0x1f0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0101c3a:	80 f9 64             	cmp    $0x64,%cl
f0101c3d:	75 eb                	jne    f0101c2a <debuginfo_eip+0x181>
f0101c3f:	83 38 00             	cmpl   $0x0,(%eax)
f0101c42:	74 e6                	je     f0101c2a <debuginfo_eip+0x181>
f0101c44:	eb 53                	jmp    f0101c99 <debuginfo_eip+0x1f0>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0101c46:	05 1d 95 10 f0       	add    $0xf010951d,%eax
f0101c4b:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101c4d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101c50:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101c53:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101c58:	39 ca                	cmp    %ecx,%edx
f0101c5a:	7d 35                	jge    f0101c91 <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
f0101c5c:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0101c5f:	6b d0 0c             	imul   $0xc,%eax,%edx
f0101c62:	81 c2 44 38 10 f0    	add    $0xf0103844,%edx
f0101c68:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0101c6a:	eb 04                	jmp    f0101c70 <debuginfo_eip+0x1c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0101c6c:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0101c6f:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0101c70:	39 f0                	cmp    %esi,%eax
f0101c72:	7d 18                	jge    f0101c8c <debuginfo_eip+0x1e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0101c74:	8a 0a                	mov    (%edx),%cl
f0101c76:	83 c2 0c             	add    $0xc,%edx
f0101c79:	80 f9 a0             	cmp    $0xa0,%cl
f0101c7c:	74 ee                	je     f0101c6c <debuginfo_eip+0x1c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101c7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c83:	eb 0c                	jmp    f0101c91 <debuginfo_eip+0x1e8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0101c85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101c8a:	eb 05                	jmp    f0101c91 <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101c8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101c94:	5b                   	pop    %ebx
f0101c95:	5e                   	pop    %esi
f0101c96:	5f                   	pop    %edi
f0101c97:	c9                   	leave  
f0101c98:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0101c99:	6b d2 0c             	imul   $0xc,%edx,%edx
f0101c9c:	8b 82 40 38 10 f0    	mov    -0xfefc7c0(%edx),%eax
f0101ca2:	ba bd 0c 11 f0       	mov    $0xf0110cbd,%edx
f0101ca7:	81 ea 1d 95 10 f0    	sub    $0xf010951d,%edx
f0101cad:	39 d0                	cmp    %edx,%eax
f0101caf:	72 95                	jb     f0101c46 <debuginfo_eip+0x19d>
f0101cb1:	eb 9a                	jmp    f0101c4d <debuginfo_eip+0x1a4>
	...

f0101cb4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101cb4:	55                   	push   %ebp
f0101cb5:	89 e5                	mov    %esp,%ebp
f0101cb7:	57                   	push   %edi
f0101cb8:	56                   	push   %esi
f0101cb9:	53                   	push   %ebx
f0101cba:	83 ec 2c             	sub    $0x2c,%esp
f0101cbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101cc0:	89 d6                	mov    %edx,%esi
f0101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
f0101cc5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101cc8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101ccb:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101cce:	8b 45 10             	mov    0x10(%ebp),%eax
f0101cd1:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0101cd4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101cd7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101cda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101ce1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0101ce4:	72 0c                	jb     f0101cf2 <printnum+0x3e>
f0101ce6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0101ce9:	76 07                	jbe    f0101cf2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101ceb:	4b                   	dec    %ebx
f0101cec:	85 db                	test   %ebx,%ebx
f0101cee:	7f 31                	jg     f0101d21 <printnum+0x6d>
f0101cf0:	eb 3f                	jmp    f0101d31 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101cf2:	83 ec 0c             	sub    $0xc,%esp
f0101cf5:	57                   	push   %edi
f0101cf6:	4b                   	dec    %ebx
f0101cf7:	53                   	push   %ebx
f0101cf8:	50                   	push   %eax
f0101cf9:	83 ec 08             	sub    $0x8,%esp
f0101cfc:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101cff:	ff 75 d0             	pushl  -0x30(%ebp)
f0101d02:	ff 75 dc             	pushl  -0x24(%ebp)
f0101d05:	ff 75 d8             	pushl  -0x28(%ebp)
f0101d08:	e8 97 09 00 00       	call   f01026a4 <__udivdi3>
f0101d0d:	83 c4 18             	add    $0x18,%esp
f0101d10:	52                   	push   %edx
f0101d11:	50                   	push   %eax
f0101d12:	89 f2                	mov    %esi,%edx
f0101d14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101d17:	e8 98 ff ff ff       	call   f0101cb4 <printnum>
f0101d1c:	83 c4 20             	add    $0x20,%esp
f0101d1f:	eb 10                	jmp    f0101d31 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0101d21:	83 ec 08             	sub    $0x8,%esp
f0101d24:	56                   	push   %esi
f0101d25:	57                   	push   %edi
f0101d26:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101d29:	4b                   	dec    %ebx
f0101d2a:	83 c4 10             	add    $0x10,%esp
f0101d2d:	85 db                	test   %ebx,%ebx
f0101d2f:	7f f0                	jg     f0101d21 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101d31:	83 ec 08             	sub    $0x8,%esp
f0101d34:	56                   	push   %esi
f0101d35:	83 ec 04             	sub    $0x4,%esp
f0101d38:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d3b:	ff 75 d0             	pushl  -0x30(%ebp)
f0101d3e:	ff 75 dc             	pushl  -0x24(%ebp)
f0101d41:	ff 75 d8             	pushl  -0x28(%ebp)
f0101d44:	e8 77 0a 00 00       	call   f01027c0 <__umoddi3>
f0101d49:	83 c4 14             	add    $0x14,%esp
f0101d4c:	0f be 80 30 36 10 f0 	movsbl -0xfefc9d0(%eax),%eax
f0101d53:	50                   	push   %eax
f0101d54:	ff 55 e4             	call   *-0x1c(%ebp)
f0101d57:	83 c4 10             	add    $0x10,%esp
}
f0101d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101d5d:	5b                   	pop    %ebx
f0101d5e:	5e                   	pop    %esi
f0101d5f:	5f                   	pop    %edi
f0101d60:	c9                   	leave  
f0101d61:	c3                   	ret    

f0101d62 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0101d62:	55                   	push   %ebp
f0101d63:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101d65:	83 fa 01             	cmp    $0x1,%edx
f0101d68:	7e 0e                	jle    f0101d78 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0101d6a:	8b 10                	mov    (%eax),%edx
f0101d6c:	8d 4a 08             	lea    0x8(%edx),%ecx
f0101d6f:	89 08                	mov    %ecx,(%eax)
f0101d71:	8b 02                	mov    (%edx),%eax
f0101d73:	8b 52 04             	mov    0x4(%edx),%edx
f0101d76:	eb 22                	jmp    f0101d9a <getuint+0x38>
	else if (lflag)
f0101d78:	85 d2                	test   %edx,%edx
f0101d7a:	74 10                	je     f0101d8c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0101d7c:	8b 10                	mov    (%eax),%edx
f0101d7e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101d81:	89 08                	mov    %ecx,(%eax)
f0101d83:	8b 02                	mov    (%edx),%eax
f0101d85:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d8a:	eb 0e                	jmp    f0101d9a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0101d8c:	8b 10                	mov    (%eax),%edx
f0101d8e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101d91:	89 08                	mov    %ecx,(%eax)
f0101d93:	8b 02                	mov    (%edx),%eax
f0101d95:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101d9a:	c9                   	leave  
f0101d9b:	c3                   	ret    

f0101d9c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0101d9c:	55                   	push   %ebp
f0101d9d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101d9f:	83 fa 01             	cmp    $0x1,%edx
f0101da2:	7e 0e                	jle    f0101db2 <getint+0x16>
		return va_arg(*ap, long long);
f0101da4:	8b 10                	mov    (%eax),%edx
f0101da6:	8d 4a 08             	lea    0x8(%edx),%ecx
f0101da9:	89 08                	mov    %ecx,(%eax)
f0101dab:	8b 02                	mov    (%edx),%eax
f0101dad:	8b 52 04             	mov    0x4(%edx),%edx
f0101db0:	eb 1a                	jmp    f0101dcc <getint+0x30>
	else if (lflag)
f0101db2:	85 d2                	test   %edx,%edx
f0101db4:	74 0c                	je     f0101dc2 <getint+0x26>
		return va_arg(*ap, long);
f0101db6:	8b 10                	mov    (%eax),%edx
f0101db8:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101dbb:	89 08                	mov    %ecx,(%eax)
f0101dbd:	8b 02                	mov    (%edx),%eax
f0101dbf:	99                   	cltd   
f0101dc0:	eb 0a                	jmp    f0101dcc <getint+0x30>
	else
		return va_arg(*ap, int);
f0101dc2:	8b 10                	mov    (%eax),%edx
f0101dc4:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101dc7:	89 08                	mov    %ecx,(%eax)
f0101dc9:	8b 02                	mov    (%edx),%eax
f0101dcb:	99                   	cltd   
}
f0101dcc:	c9                   	leave  
f0101dcd:	c3                   	ret    

f0101dce <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101dce:	55                   	push   %ebp
f0101dcf:	89 e5                	mov    %esp,%ebp
f0101dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101dd4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0101dd7:	8b 10                	mov    (%eax),%edx
f0101dd9:	3b 50 04             	cmp    0x4(%eax),%edx
f0101ddc:	73 08                	jae    f0101de6 <sprintputch+0x18>
		*b->buf++ = ch;
f0101dde:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101de1:	88 0a                	mov    %cl,(%edx)
f0101de3:	42                   	inc    %edx
f0101de4:	89 10                	mov    %edx,(%eax)
}
f0101de6:	c9                   	leave  
f0101de7:	c3                   	ret    

f0101de8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101de8:	55                   	push   %ebp
f0101de9:	89 e5                	mov    %esp,%ebp
f0101deb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0101dee:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101df1:	50                   	push   %eax
f0101df2:	ff 75 10             	pushl  0x10(%ebp)
f0101df5:	ff 75 0c             	pushl  0xc(%ebp)
f0101df8:	ff 75 08             	pushl  0x8(%ebp)
f0101dfb:	e8 05 00 00 00       	call   f0101e05 <vprintfmt>
	va_end(ap);
f0101e00:	83 c4 10             	add    $0x10,%esp
}
f0101e03:	c9                   	leave  
f0101e04:	c3                   	ret    

f0101e05 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101e05:	55                   	push   %ebp
f0101e06:	89 e5                	mov    %esp,%ebp
f0101e08:	57                   	push   %edi
f0101e09:	56                   	push   %esi
f0101e0a:	53                   	push   %ebx
f0101e0b:	83 ec 2c             	sub    $0x2c,%esp
f0101e0e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101e11:	8b 75 10             	mov    0x10(%ebp),%esi
f0101e14:	eb 13                	jmp    f0101e29 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0101e16:	85 c0                	test   %eax,%eax
f0101e18:	0f 84 6d 03 00 00    	je     f010218b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f0101e1e:	83 ec 08             	sub    $0x8,%esp
f0101e21:	57                   	push   %edi
f0101e22:	50                   	push   %eax
f0101e23:	ff 55 08             	call   *0x8(%ebp)
f0101e26:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101e29:	0f b6 06             	movzbl (%esi),%eax
f0101e2c:	46                   	inc    %esi
f0101e2d:	83 f8 25             	cmp    $0x25,%eax
f0101e30:	75 e4                	jne    f0101e16 <vprintfmt+0x11>
f0101e32:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0101e36:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0101e3d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0101e44:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0101e4b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101e50:	eb 28                	jmp    f0101e7a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101e52:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0101e54:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0101e58:	eb 20                	jmp    f0101e7a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101e5a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101e5c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0101e60:	eb 18                	jmp    f0101e7a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101e62:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0101e64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101e6b:	eb 0d                	jmp    f0101e7a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0101e6d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101e73:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101e7a:	8a 06                	mov    (%esi),%al
f0101e7c:	0f b6 d0             	movzbl %al,%edx
f0101e7f:	8d 5e 01             	lea    0x1(%esi),%ebx
f0101e82:	83 e8 23             	sub    $0x23,%eax
f0101e85:	3c 55                	cmp    $0x55,%al
f0101e87:	0f 87 e0 02 00 00    	ja     f010216d <vprintfmt+0x368>
f0101e8d:	0f b6 c0             	movzbl %al,%eax
f0101e90:	ff 24 85 bc 36 10 f0 	jmp    *-0xfefc944(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101e97:	83 ea 30             	sub    $0x30,%edx
f0101e9a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0101e9d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0101ea0:	8d 50 d0             	lea    -0x30(%eax),%edx
f0101ea3:	83 fa 09             	cmp    $0x9,%edx
f0101ea6:	77 44                	ja     f0101eec <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101ea8:	89 de                	mov    %ebx,%esi
f0101eaa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0101ead:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0101eae:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0101eb1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0101eb5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0101eb8:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0101ebb:	83 fb 09             	cmp    $0x9,%ebx
f0101ebe:	76 ed                	jbe    f0101ead <vprintfmt+0xa8>
f0101ec0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0101ec3:	eb 29                	jmp    f0101eee <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101ec5:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ec8:	8d 50 04             	lea    0x4(%eax),%edx
f0101ecb:	89 55 14             	mov    %edx,0x14(%ebp)
f0101ece:	8b 00                	mov    (%eax),%eax
f0101ed0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101ed3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101ed5:	eb 17                	jmp    f0101eee <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0101ed7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101edb:	78 85                	js     f0101e62 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101edd:	89 de                	mov    %ebx,%esi
f0101edf:	eb 99                	jmp    f0101e7a <vprintfmt+0x75>
f0101ee1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101ee3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0101eea:	eb 8e                	jmp    f0101e7a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101eec:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0101eee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101ef2:	79 86                	jns    f0101e7a <vprintfmt+0x75>
f0101ef4:	e9 74 ff ff ff       	jmp    f0101e6d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101ef9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101efa:	89 de                	mov    %ebx,%esi
f0101efc:	e9 79 ff ff ff       	jmp    f0101e7a <vprintfmt+0x75>
f0101f01:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101f04:	8b 45 14             	mov    0x14(%ebp),%eax
f0101f07:	8d 50 04             	lea    0x4(%eax),%edx
f0101f0a:	89 55 14             	mov    %edx,0x14(%ebp)
f0101f0d:	83 ec 08             	sub    $0x8,%esp
f0101f10:	57                   	push   %edi
f0101f11:	ff 30                	pushl  (%eax)
f0101f13:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101f16:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101f19:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0101f1c:	e9 08 ff ff ff       	jmp    f0101e29 <vprintfmt+0x24>
f0101f21:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101f24:	8b 45 14             	mov    0x14(%ebp),%eax
f0101f27:	8d 50 04             	lea    0x4(%eax),%edx
f0101f2a:	89 55 14             	mov    %edx,0x14(%ebp)
f0101f2d:	8b 00                	mov    (%eax),%eax
f0101f2f:	85 c0                	test   %eax,%eax
f0101f31:	79 02                	jns    f0101f35 <vprintfmt+0x130>
f0101f33:	f7 d8                	neg    %eax
f0101f35:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101f37:	83 f8 06             	cmp    $0x6,%eax
f0101f3a:	7f 0b                	jg     f0101f47 <vprintfmt+0x142>
f0101f3c:	8b 04 85 14 38 10 f0 	mov    -0xfefc7ec(,%eax,4),%eax
f0101f43:	85 c0                	test   %eax,%eax
f0101f45:	75 1a                	jne    f0101f61 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0101f47:	52                   	push   %edx
f0101f48:	68 48 36 10 f0       	push   $0xf0103648
f0101f4d:	57                   	push   %edi
f0101f4e:	ff 75 08             	pushl  0x8(%ebp)
f0101f51:	e8 92 fe ff ff       	call   f0101de8 <printfmt>
f0101f56:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101f59:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101f5c:	e9 c8 fe ff ff       	jmp    f0101e29 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0101f61:	50                   	push   %eax
f0101f62:	68 2c 34 10 f0       	push   $0xf010342c
f0101f67:	57                   	push   %edi
f0101f68:	ff 75 08             	pushl  0x8(%ebp)
f0101f6b:	e8 78 fe ff ff       	call   f0101de8 <printfmt>
f0101f70:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101f73:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101f76:	e9 ae fe ff ff       	jmp    f0101e29 <vprintfmt+0x24>
f0101f7b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0101f7e:	89 de                	mov    %ebx,%esi
f0101f80:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101f83:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101f86:	8b 45 14             	mov    0x14(%ebp),%eax
f0101f89:	8d 50 04             	lea    0x4(%eax),%edx
f0101f8c:	89 55 14             	mov    %edx,0x14(%ebp)
f0101f8f:	8b 00                	mov    (%eax),%eax
f0101f91:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101f94:	85 c0                	test   %eax,%eax
f0101f96:	75 07                	jne    f0101f9f <vprintfmt+0x19a>
				p = "(null)";
f0101f98:	c7 45 d0 41 36 10 f0 	movl   $0xf0103641,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0101f9f:	85 db                	test   %ebx,%ebx
f0101fa1:	7e 42                	jle    f0101fe5 <vprintfmt+0x1e0>
f0101fa3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0101fa7:	74 3c                	je     f0101fe5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101fa9:	83 ec 08             	sub    $0x8,%esp
f0101fac:	51                   	push   %ecx
f0101fad:	ff 75 d0             	pushl  -0x30(%ebp)
f0101fb0:	e8 3f 03 00 00       	call   f01022f4 <strnlen>
f0101fb5:	29 c3                	sub    %eax,%ebx
f0101fb7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101fba:	83 c4 10             	add    $0x10,%esp
f0101fbd:	85 db                	test   %ebx,%ebx
f0101fbf:	7e 24                	jle    f0101fe5 <vprintfmt+0x1e0>
					putch(padc, putdat);
f0101fc1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0101fc5:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0101fc8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101fcb:	83 ec 08             	sub    $0x8,%esp
f0101fce:	57                   	push   %edi
f0101fcf:	53                   	push   %ebx
f0101fd0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101fd3:	4e                   	dec    %esi
f0101fd4:	83 c4 10             	add    $0x10,%esp
f0101fd7:	85 f6                	test   %esi,%esi
f0101fd9:	7f f0                	jg     f0101fcb <vprintfmt+0x1c6>
f0101fdb:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101fde:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101fe5:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101fe8:	0f be 02             	movsbl (%edx),%eax
f0101feb:	85 c0                	test   %eax,%eax
f0101fed:	75 47                	jne    f0102036 <vprintfmt+0x231>
f0101fef:	eb 37                	jmp    f0102028 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f0101ff1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101ff5:	74 16                	je     f010200d <vprintfmt+0x208>
f0101ff7:	8d 50 e0             	lea    -0x20(%eax),%edx
f0101ffa:	83 fa 5e             	cmp    $0x5e,%edx
f0101ffd:	76 0e                	jbe    f010200d <vprintfmt+0x208>
					putch('?', putdat);
f0101fff:	83 ec 08             	sub    $0x8,%esp
f0102002:	57                   	push   %edi
f0102003:	6a 3f                	push   $0x3f
f0102005:	ff 55 08             	call   *0x8(%ebp)
f0102008:	83 c4 10             	add    $0x10,%esp
f010200b:	eb 0b                	jmp    f0102018 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f010200d:	83 ec 08             	sub    $0x8,%esp
f0102010:	57                   	push   %edi
f0102011:	50                   	push   %eax
f0102012:	ff 55 08             	call   *0x8(%ebp)
f0102015:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102018:	ff 4d e4             	decl   -0x1c(%ebp)
f010201b:	0f be 03             	movsbl (%ebx),%eax
f010201e:	85 c0                	test   %eax,%eax
f0102020:	74 03                	je     f0102025 <vprintfmt+0x220>
f0102022:	43                   	inc    %ebx
f0102023:	eb 1b                	jmp    f0102040 <vprintfmt+0x23b>
f0102025:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102028:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010202c:	7f 1e                	jg     f010204c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010202e:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0102031:	e9 f3 fd ff ff       	jmp    f0101e29 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102036:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102039:	43                   	inc    %ebx
f010203a:	89 75 dc             	mov    %esi,-0x24(%ebp)
f010203d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102040:	85 f6                	test   %esi,%esi
f0102042:	78 ad                	js     f0101ff1 <vprintfmt+0x1ec>
f0102044:	4e                   	dec    %esi
f0102045:	79 aa                	jns    f0101ff1 <vprintfmt+0x1ec>
f0102047:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010204a:	eb dc                	jmp    f0102028 <vprintfmt+0x223>
f010204c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010204f:	83 ec 08             	sub    $0x8,%esp
f0102052:	57                   	push   %edi
f0102053:	6a 20                	push   $0x20
f0102055:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102058:	4b                   	dec    %ebx
f0102059:	83 c4 10             	add    $0x10,%esp
f010205c:	85 db                	test   %ebx,%ebx
f010205e:	7f ef                	jg     f010204f <vprintfmt+0x24a>
f0102060:	e9 c4 fd ff ff       	jmp    f0101e29 <vprintfmt+0x24>
f0102065:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102068:	89 ca                	mov    %ecx,%edx
f010206a:	8d 45 14             	lea    0x14(%ebp),%eax
f010206d:	e8 2a fd ff ff       	call   f0101d9c <getint>
f0102072:	89 c3                	mov    %eax,%ebx
f0102074:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0102076:	85 d2                	test   %edx,%edx
f0102078:	78 0a                	js     f0102084 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010207a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010207f:	e9 b0 00 00 00       	jmp    f0102134 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0102084:	83 ec 08             	sub    $0x8,%esp
f0102087:	57                   	push   %edi
f0102088:	6a 2d                	push   $0x2d
f010208a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010208d:	f7 db                	neg    %ebx
f010208f:	83 d6 00             	adc    $0x0,%esi
f0102092:	f7 de                	neg    %esi
f0102094:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102097:	b8 0a 00 00 00       	mov    $0xa,%eax
f010209c:	e9 93 00 00 00       	jmp    f0102134 <vprintfmt+0x32f>
f01020a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01020a4:	89 ca                	mov    %ecx,%edx
f01020a6:	8d 45 14             	lea    0x14(%ebp),%eax
f01020a9:	e8 b4 fc ff ff       	call   f0101d62 <getuint>
f01020ae:	89 c3                	mov    %eax,%ebx
f01020b0:	89 d6                	mov    %edx,%esi
			base = 10;
f01020b2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01020b7:	eb 7b                	jmp    f0102134 <vprintfmt+0x32f>
f01020b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f01020bc:	89 ca                	mov    %ecx,%edx
f01020be:	8d 45 14             	lea    0x14(%ebp),%eax
f01020c1:	e8 d6 fc ff ff       	call   f0101d9c <getint>
f01020c6:	89 c3                	mov    %eax,%ebx
f01020c8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f01020ca:	85 d2                	test   %edx,%edx
f01020cc:	78 07                	js     f01020d5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f01020ce:	b8 08 00 00 00       	mov    $0x8,%eax
f01020d3:	eb 5f                	jmp    f0102134 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f01020d5:	83 ec 08             	sub    $0x8,%esp
f01020d8:	57                   	push   %edi
f01020d9:	6a 2d                	push   $0x2d
f01020db:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f01020de:	f7 db                	neg    %ebx
f01020e0:	83 d6 00             	adc    $0x0,%esi
f01020e3:	f7 de                	neg    %esi
f01020e5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f01020e8:	b8 08 00 00 00       	mov    $0x8,%eax
f01020ed:	eb 45                	jmp    f0102134 <vprintfmt+0x32f>
f01020ef:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f01020f2:	83 ec 08             	sub    $0x8,%esp
f01020f5:	57                   	push   %edi
f01020f6:	6a 30                	push   $0x30
f01020f8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01020fb:	83 c4 08             	add    $0x8,%esp
f01020fe:	57                   	push   %edi
f01020ff:	6a 78                	push   $0x78
f0102101:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102104:	8b 45 14             	mov    0x14(%ebp),%eax
f0102107:	8d 50 04             	lea    0x4(%eax),%edx
f010210a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010210d:	8b 18                	mov    (%eax),%ebx
f010210f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102114:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102117:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010211c:	eb 16                	jmp    f0102134 <vprintfmt+0x32f>
f010211e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102121:	89 ca                	mov    %ecx,%edx
f0102123:	8d 45 14             	lea    0x14(%ebp),%eax
f0102126:	e8 37 fc ff ff       	call   f0101d62 <getuint>
f010212b:	89 c3                	mov    %eax,%ebx
f010212d:	89 d6                	mov    %edx,%esi
			base = 16;
f010212f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102134:	83 ec 0c             	sub    $0xc,%esp
f0102137:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f010213b:	52                   	push   %edx
f010213c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010213f:	50                   	push   %eax
f0102140:	56                   	push   %esi
f0102141:	53                   	push   %ebx
f0102142:	89 fa                	mov    %edi,%edx
f0102144:	8b 45 08             	mov    0x8(%ebp),%eax
f0102147:	e8 68 fb ff ff       	call   f0101cb4 <printnum>
			break;
f010214c:	83 c4 20             	add    $0x20,%esp
f010214f:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0102152:	e9 d2 fc ff ff       	jmp    f0101e29 <vprintfmt+0x24>
f0102157:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010215a:	83 ec 08             	sub    $0x8,%esp
f010215d:	57                   	push   %edi
f010215e:	52                   	push   %edx
f010215f:	ff 55 08             	call   *0x8(%ebp)
			break;
f0102162:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102165:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102168:	e9 bc fc ff ff       	jmp    f0101e29 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010216d:	83 ec 08             	sub    $0x8,%esp
f0102170:	57                   	push   %edi
f0102171:	6a 25                	push   $0x25
f0102173:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102176:	83 c4 10             	add    $0x10,%esp
f0102179:	eb 02                	jmp    f010217d <vprintfmt+0x378>
f010217b:	89 c6                	mov    %eax,%esi
f010217d:	8d 46 ff             	lea    -0x1(%esi),%eax
f0102180:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0102184:	75 f5                	jne    f010217b <vprintfmt+0x376>
f0102186:	e9 9e fc ff ff       	jmp    f0101e29 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f010218b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010218e:	5b                   	pop    %ebx
f010218f:	5e                   	pop    %esi
f0102190:	5f                   	pop    %edi
f0102191:	c9                   	leave  
f0102192:	c3                   	ret    

f0102193 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102193:	55                   	push   %ebp
f0102194:	89 e5                	mov    %esp,%ebp
f0102196:	83 ec 18             	sub    $0x18,%esp
f0102199:	8b 45 08             	mov    0x8(%ebp),%eax
f010219c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010219f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01021a2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01021a6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01021a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01021b0:	85 c0                	test   %eax,%eax
f01021b2:	74 26                	je     f01021da <vsnprintf+0x47>
f01021b4:	85 d2                	test   %edx,%edx
f01021b6:	7e 29                	jle    f01021e1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01021b8:	ff 75 14             	pushl  0x14(%ebp)
f01021bb:	ff 75 10             	pushl  0x10(%ebp)
f01021be:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01021c1:	50                   	push   %eax
f01021c2:	68 ce 1d 10 f0       	push   $0xf0101dce
f01021c7:	e8 39 fc ff ff       	call   f0101e05 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01021cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01021cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01021d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01021d5:	83 c4 10             	add    $0x10,%esp
f01021d8:	eb 0c                	jmp    f01021e6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01021da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01021df:	eb 05                	jmp    f01021e6 <vsnprintf+0x53>
f01021e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01021e6:	c9                   	leave  
f01021e7:	c3                   	ret    

f01021e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01021e8:	55                   	push   %ebp
f01021e9:	89 e5                	mov    %esp,%ebp
f01021eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01021ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01021f1:	50                   	push   %eax
f01021f2:	ff 75 10             	pushl  0x10(%ebp)
f01021f5:	ff 75 0c             	pushl  0xc(%ebp)
f01021f8:	ff 75 08             	pushl  0x8(%ebp)
f01021fb:	e8 93 ff ff ff       	call   f0102193 <vsnprintf>
	va_end(ap);

	return rc;
}
f0102200:	c9                   	leave  
f0102201:	c3                   	ret    
	...

f0102204 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102204:	55                   	push   %ebp
f0102205:	89 e5                	mov    %esp,%ebp
f0102207:	57                   	push   %edi
f0102208:	56                   	push   %esi
f0102209:	53                   	push   %ebx
f010220a:	83 ec 0c             	sub    $0xc,%esp
f010220d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102210:	85 c0                	test   %eax,%eax
f0102212:	74 11                	je     f0102225 <readline+0x21>
		cprintf("%s", prompt);
f0102214:	83 ec 08             	sub    $0x8,%esp
f0102217:	50                   	push   %eax
f0102218:	68 2c 34 10 f0       	push   $0xf010342c
f010221d:	e8 4b f7 ff ff       	call   f010196d <cprintf>
f0102222:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0102225:	83 ec 0c             	sub    $0xc,%esp
f0102228:	6a 00                	push   $0x0
f010222a:	e8 98 e3 ff ff       	call   f01005c7 <iscons>
f010222f:	89 c7                	mov    %eax,%edi
f0102231:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0102234:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0102239:	e8 78 e3 ff ff       	call   f01005b6 <getchar>
f010223e:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102240:	85 c0                	test   %eax,%eax
f0102242:	79 18                	jns    f010225c <readline+0x58>
			cprintf("read error: %e\n", c);
f0102244:	83 ec 08             	sub    $0x8,%esp
f0102247:	50                   	push   %eax
f0102248:	68 30 38 10 f0       	push   $0xf0103830
f010224d:	e8 1b f7 ff ff       	call   f010196d <cprintf>
			return NULL;
f0102252:	83 c4 10             	add    $0x10,%esp
f0102255:	b8 00 00 00 00       	mov    $0x0,%eax
f010225a:	eb 6f                	jmp    f01022cb <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010225c:	83 f8 08             	cmp    $0x8,%eax
f010225f:	74 05                	je     f0102266 <readline+0x62>
f0102261:	83 f8 7f             	cmp    $0x7f,%eax
f0102264:	75 18                	jne    f010227e <readline+0x7a>
f0102266:	85 f6                	test   %esi,%esi
f0102268:	7e 14                	jle    f010227e <readline+0x7a>
			if (echoing)
f010226a:	85 ff                	test   %edi,%edi
f010226c:	74 0d                	je     f010227b <readline+0x77>
				cputchar('\b');
f010226e:	83 ec 0c             	sub    $0xc,%esp
f0102271:	6a 08                	push   $0x8
f0102273:	e8 2e e3 ff ff       	call   f01005a6 <cputchar>
f0102278:	83 c4 10             	add    $0x10,%esp
			i--;
f010227b:	4e                   	dec    %esi
f010227c:	eb bb                	jmp    f0102239 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010227e:	83 fb 1f             	cmp    $0x1f,%ebx
f0102281:	7e 21                	jle    f01022a4 <readline+0xa0>
f0102283:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102289:	7f 19                	jg     f01022a4 <readline+0xa0>
			if (echoing)
f010228b:	85 ff                	test   %edi,%edi
f010228d:	74 0c                	je     f010229b <readline+0x97>
				cputchar(c);
f010228f:	83 ec 0c             	sub    $0xc,%esp
f0102292:	53                   	push   %ebx
f0102293:	e8 0e e3 ff ff       	call   f01005a6 <cputchar>
f0102298:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010229b:	88 9e 40 b5 11 f0    	mov    %bl,-0xfee4ac0(%esi)
f01022a1:	46                   	inc    %esi
f01022a2:	eb 95                	jmp    f0102239 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01022a4:	83 fb 0a             	cmp    $0xa,%ebx
f01022a7:	74 05                	je     f01022ae <readline+0xaa>
f01022a9:	83 fb 0d             	cmp    $0xd,%ebx
f01022ac:	75 8b                	jne    f0102239 <readline+0x35>
			if (echoing)
f01022ae:	85 ff                	test   %edi,%edi
f01022b0:	74 0d                	je     f01022bf <readline+0xbb>
				cputchar('\n');
f01022b2:	83 ec 0c             	sub    $0xc,%esp
f01022b5:	6a 0a                	push   $0xa
f01022b7:	e8 ea e2 ff ff       	call   f01005a6 <cputchar>
f01022bc:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01022bf:	c6 86 40 b5 11 f0 00 	movb   $0x0,-0xfee4ac0(%esi)
			return buf;
f01022c6:	b8 40 b5 11 f0       	mov    $0xf011b540,%eax
		}
	}
}
f01022cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01022ce:	5b                   	pop    %ebx
f01022cf:	5e                   	pop    %esi
f01022d0:	5f                   	pop    %edi
f01022d1:	c9                   	leave  
f01022d2:	c3                   	ret    
	...

f01022d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01022d4:	55                   	push   %ebp
f01022d5:	89 e5                	mov    %esp,%ebp
f01022d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01022da:	80 3a 00             	cmpb   $0x0,(%edx)
f01022dd:	74 0e                	je     f01022ed <strlen+0x19>
f01022df:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01022e4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01022e5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01022e9:	75 f9                	jne    f01022e4 <strlen+0x10>
f01022eb:	eb 05                	jmp    f01022f2 <strlen+0x1e>
f01022ed:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01022f2:	c9                   	leave  
f01022f3:	c3                   	ret    

f01022f4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01022f4:	55                   	push   %ebp
f01022f5:	89 e5                	mov    %esp,%ebp
f01022f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01022fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01022fd:	85 d2                	test   %edx,%edx
f01022ff:	74 17                	je     f0102318 <strnlen+0x24>
f0102301:	80 39 00             	cmpb   $0x0,(%ecx)
f0102304:	74 19                	je     f010231f <strnlen+0x2b>
f0102306:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f010230b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010230c:	39 d0                	cmp    %edx,%eax
f010230e:	74 14                	je     f0102324 <strnlen+0x30>
f0102310:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0102314:	75 f5                	jne    f010230b <strnlen+0x17>
f0102316:	eb 0c                	jmp    f0102324 <strnlen+0x30>
f0102318:	b8 00 00 00 00       	mov    $0x0,%eax
f010231d:	eb 05                	jmp    f0102324 <strnlen+0x30>
f010231f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0102324:	c9                   	leave  
f0102325:	c3                   	ret    

f0102326 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0102326:	55                   	push   %ebp
f0102327:	89 e5                	mov    %esp,%ebp
f0102329:	53                   	push   %ebx
f010232a:	8b 45 08             	mov    0x8(%ebp),%eax
f010232d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0102330:	ba 00 00 00 00       	mov    $0x0,%edx
f0102335:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0102338:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f010233b:	42                   	inc    %edx
f010233c:	84 c9                	test   %cl,%cl
f010233e:	75 f5                	jne    f0102335 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0102340:	5b                   	pop    %ebx
f0102341:	c9                   	leave  
f0102342:	c3                   	ret    

f0102343 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0102343:	55                   	push   %ebp
f0102344:	89 e5                	mov    %esp,%ebp
f0102346:	53                   	push   %ebx
f0102347:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010234a:	53                   	push   %ebx
f010234b:	e8 84 ff ff ff       	call   f01022d4 <strlen>
f0102350:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0102353:	ff 75 0c             	pushl  0xc(%ebp)
f0102356:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0102359:	50                   	push   %eax
f010235a:	e8 c7 ff ff ff       	call   f0102326 <strcpy>
	return dst;
}
f010235f:	89 d8                	mov    %ebx,%eax
f0102361:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102364:	c9                   	leave  
f0102365:	c3                   	ret    

f0102366 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0102366:	55                   	push   %ebp
f0102367:	89 e5                	mov    %esp,%ebp
f0102369:	56                   	push   %esi
f010236a:	53                   	push   %ebx
f010236b:	8b 45 08             	mov    0x8(%ebp),%eax
f010236e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102371:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102374:	85 f6                	test   %esi,%esi
f0102376:	74 15                	je     f010238d <strncpy+0x27>
f0102378:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010237d:	8a 1a                	mov    (%edx),%bl
f010237f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0102382:	80 3a 01             	cmpb   $0x1,(%edx)
f0102385:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102388:	41                   	inc    %ecx
f0102389:	39 ce                	cmp    %ecx,%esi
f010238b:	77 f0                	ja     f010237d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010238d:	5b                   	pop    %ebx
f010238e:	5e                   	pop    %esi
f010238f:	c9                   	leave  
f0102390:	c3                   	ret    

f0102391 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0102391:	55                   	push   %ebp
f0102392:	89 e5                	mov    %esp,%ebp
f0102394:	57                   	push   %edi
f0102395:	56                   	push   %esi
f0102396:	53                   	push   %ebx
f0102397:	8b 7d 08             	mov    0x8(%ebp),%edi
f010239a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010239d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01023a0:	85 f6                	test   %esi,%esi
f01023a2:	74 32                	je     f01023d6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f01023a4:	83 fe 01             	cmp    $0x1,%esi
f01023a7:	74 22                	je     f01023cb <strlcpy+0x3a>
f01023a9:	8a 0b                	mov    (%ebx),%cl
f01023ab:	84 c9                	test   %cl,%cl
f01023ad:	74 20                	je     f01023cf <strlcpy+0x3e>
f01023af:	89 f8                	mov    %edi,%eax
f01023b1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01023b6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01023b9:	88 08                	mov    %cl,(%eax)
f01023bb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01023bc:	39 f2                	cmp    %esi,%edx
f01023be:	74 11                	je     f01023d1 <strlcpy+0x40>
f01023c0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f01023c4:	42                   	inc    %edx
f01023c5:	84 c9                	test   %cl,%cl
f01023c7:	75 f0                	jne    f01023b9 <strlcpy+0x28>
f01023c9:	eb 06                	jmp    f01023d1 <strlcpy+0x40>
f01023cb:	89 f8                	mov    %edi,%eax
f01023cd:	eb 02                	jmp    f01023d1 <strlcpy+0x40>
f01023cf:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01023d1:	c6 00 00             	movb   $0x0,(%eax)
f01023d4:	eb 02                	jmp    f01023d8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01023d6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f01023d8:	29 f8                	sub    %edi,%eax
}
f01023da:	5b                   	pop    %ebx
f01023db:	5e                   	pop    %esi
f01023dc:	5f                   	pop    %edi
f01023dd:	c9                   	leave  
f01023de:	c3                   	ret    

f01023df <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01023df:	55                   	push   %ebp
f01023e0:	89 e5                	mov    %esp,%ebp
f01023e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01023e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01023e8:	8a 01                	mov    (%ecx),%al
f01023ea:	84 c0                	test   %al,%al
f01023ec:	74 10                	je     f01023fe <strcmp+0x1f>
f01023ee:	3a 02                	cmp    (%edx),%al
f01023f0:	75 0c                	jne    f01023fe <strcmp+0x1f>
		p++, q++;
f01023f2:	41                   	inc    %ecx
f01023f3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01023f4:	8a 01                	mov    (%ecx),%al
f01023f6:	84 c0                	test   %al,%al
f01023f8:	74 04                	je     f01023fe <strcmp+0x1f>
f01023fa:	3a 02                	cmp    (%edx),%al
f01023fc:	74 f4                	je     f01023f2 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01023fe:	0f b6 c0             	movzbl %al,%eax
f0102401:	0f b6 12             	movzbl (%edx),%edx
f0102404:	29 d0                	sub    %edx,%eax
}
f0102406:	c9                   	leave  
f0102407:	c3                   	ret    

f0102408 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0102408:	55                   	push   %ebp
f0102409:	89 e5                	mov    %esp,%ebp
f010240b:	53                   	push   %ebx
f010240c:	8b 55 08             	mov    0x8(%ebp),%edx
f010240f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102412:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0102415:	85 c0                	test   %eax,%eax
f0102417:	74 1b                	je     f0102434 <strncmp+0x2c>
f0102419:	8a 1a                	mov    (%edx),%bl
f010241b:	84 db                	test   %bl,%bl
f010241d:	74 24                	je     f0102443 <strncmp+0x3b>
f010241f:	3a 19                	cmp    (%ecx),%bl
f0102421:	75 20                	jne    f0102443 <strncmp+0x3b>
f0102423:	48                   	dec    %eax
f0102424:	74 15                	je     f010243b <strncmp+0x33>
		n--, p++, q++;
f0102426:	42                   	inc    %edx
f0102427:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0102428:	8a 1a                	mov    (%edx),%bl
f010242a:	84 db                	test   %bl,%bl
f010242c:	74 15                	je     f0102443 <strncmp+0x3b>
f010242e:	3a 19                	cmp    (%ecx),%bl
f0102430:	74 f1                	je     f0102423 <strncmp+0x1b>
f0102432:	eb 0f                	jmp    f0102443 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0102434:	b8 00 00 00 00       	mov    $0x0,%eax
f0102439:	eb 05                	jmp    f0102440 <strncmp+0x38>
f010243b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0102440:	5b                   	pop    %ebx
f0102441:	c9                   	leave  
f0102442:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0102443:	0f b6 02             	movzbl (%edx),%eax
f0102446:	0f b6 11             	movzbl (%ecx),%edx
f0102449:	29 d0                	sub    %edx,%eax
f010244b:	eb f3                	jmp    f0102440 <strncmp+0x38>

f010244d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010244d:	55                   	push   %ebp
f010244e:	89 e5                	mov    %esp,%ebp
f0102450:	8b 45 08             	mov    0x8(%ebp),%eax
f0102453:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0102456:	8a 10                	mov    (%eax),%dl
f0102458:	84 d2                	test   %dl,%dl
f010245a:	74 18                	je     f0102474 <strchr+0x27>
		if (*s == c)
f010245c:	38 ca                	cmp    %cl,%dl
f010245e:	75 06                	jne    f0102466 <strchr+0x19>
f0102460:	eb 17                	jmp    f0102479 <strchr+0x2c>
f0102462:	38 ca                	cmp    %cl,%dl
f0102464:	74 13                	je     f0102479 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0102466:	40                   	inc    %eax
f0102467:	8a 10                	mov    (%eax),%dl
f0102469:	84 d2                	test   %dl,%dl
f010246b:	75 f5                	jne    f0102462 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f010246d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102472:	eb 05                	jmp    f0102479 <strchr+0x2c>
f0102474:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102479:	c9                   	leave  
f010247a:	c3                   	ret    

f010247b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010247b:	55                   	push   %ebp
f010247c:	89 e5                	mov    %esp,%ebp
f010247e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102481:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0102484:	8a 10                	mov    (%eax),%dl
f0102486:	84 d2                	test   %dl,%dl
f0102488:	74 11                	je     f010249b <strfind+0x20>
		if (*s == c)
f010248a:	38 ca                	cmp    %cl,%dl
f010248c:	75 06                	jne    f0102494 <strfind+0x19>
f010248e:	eb 0b                	jmp    f010249b <strfind+0x20>
f0102490:	38 ca                	cmp    %cl,%dl
f0102492:	74 07                	je     f010249b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0102494:	40                   	inc    %eax
f0102495:	8a 10                	mov    (%eax),%dl
f0102497:	84 d2                	test   %dl,%dl
f0102499:	75 f5                	jne    f0102490 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f010249b:	c9                   	leave  
f010249c:	c3                   	ret    

f010249d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010249d:	55                   	push   %ebp
f010249e:	89 e5                	mov    %esp,%ebp
f01024a0:	57                   	push   %edi
f01024a1:	56                   	push   %esi
f01024a2:	53                   	push   %ebx
f01024a3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01024a6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01024a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01024ac:	85 c9                	test   %ecx,%ecx
f01024ae:	74 30                	je     f01024e0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01024b0:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01024b6:	75 25                	jne    f01024dd <memset+0x40>
f01024b8:	f6 c1 03             	test   $0x3,%cl
f01024bb:	75 20                	jne    f01024dd <memset+0x40>
		c &= 0xFF;
f01024bd:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01024c0:	89 d3                	mov    %edx,%ebx
f01024c2:	c1 e3 08             	shl    $0x8,%ebx
f01024c5:	89 d6                	mov    %edx,%esi
f01024c7:	c1 e6 18             	shl    $0x18,%esi
f01024ca:	89 d0                	mov    %edx,%eax
f01024cc:	c1 e0 10             	shl    $0x10,%eax
f01024cf:	09 f0                	or     %esi,%eax
f01024d1:	09 d0                	or     %edx,%eax
f01024d3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01024d5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01024d8:	fc                   	cld    
f01024d9:	f3 ab                	rep stos %eax,%es:(%edi)
f01024db:	eb 03                	jmp    f01024e0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01024dd:	fc                   	cld    
f01024de:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01024e0:	89 f8                	mov    %edi,%eax
f01024e2:	5b                   	pop    %ebx
f01024e3:	5e                   	pop    %esi
f01024e4:	5f                   	pop    %edi
f01024e5:	c9                   	leave  
f01024e6:	c3                   	ret    

f01024e7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01024e7:	55                   	push   %ebp
f01024e8:	89 e5                	mov    %esp,%ebp
f01024ea:	57                   	push   %edi
f01024eb:	56                   	push   %esi
f01024ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01024ef:	8b 75 0c             	mov    0xc(%ebp),%esi
f01024f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01024f5:	39 c6                	cmp    %eax,%esi
f01024f7:	73 34                	jae    f010252d <memmove+0x46>
f01024f9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01024fc:	39 d0                	cmp    %edx,%eax
f01024fe:	73 2d                	jae    f010252d <memmove+0x46>
		s += n;
		d += n;
f0102500:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0102503:	f6 c2 03             	test   $0x3,%dl
f0102506:	75 1b                	jne    f0102523 <memmove+0x3c>
f0102508:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010250e:	75 13                	jne    f0102523 <memmove+0x3c>
f0102510:	f6 c1 03             	test   $0x3,%cl
f0102513:	75 0e                	jne    f0102523 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0102515:	83 ef 04             	sub    $0x4,%edi
f0102518:	8d 72 fc             	lea    -0x4(%edx),%esi
f010251b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010251e:	fd                   	std    
f010251f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102521:	eb 07                	jmp    f010252a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0102523:	4f                   	dec    %edi
f0102524:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0102527:	fd                   	std    
f0102528:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010252a:	fc                   	cld    
f010252b:	eb 20                	jmp    f010254d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010252d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0102533:	75 13                	jne    f0102548 <memmove+0x61>
f0102535:	a8 03                	test   $0x3,%al
f0102537:	75 0f                	jne    f0102548 <memmove+0x61>
f0102539:	f6 c1 03             	test   $0x3,%cl
f010253c:	75 0a                	jne    f0102548 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010253e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0102541:	89 c7                	mov    %eax,%edi
f0102543:	fc                   	cld    
f0102544:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102546:	eb 05                	jmp    f010254d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0102548:	89 c7                	mov    %eax,%edi
f010254a:	fc                   	cld    
f010254b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010254d:	5e                   	pop    %esi
f010254e:	5f                   	pop    %edi
f010254f:	c9                   	leave  
f0102550:	c3                   	ret    

f0102551 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0102551:	55                   	push   %ebp
f0102552:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0102554:	ff 75 10             	pushl  0x10(%ebp)
f0102557:	ff 75 0c             	pushl  0xc(%ebp)
f010255a:	ff 75 08             	pushl  0x8(%ebp)
f010255d:	e8 85 ff ff ff       	call   f01024e7 <memmove>
}
f0102562:	c9                   	leave  
f0102563:	c3                   	ret    

f0102564 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0102564:	55                   	push   %ebp
f0102565:	89 e5                	mov    %esp,%ebp
f0102567:	57                   	push   %edi
f0102568:	56                   	push   %esi
f0102569:	53                   	push   %ebx
f010256a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010256d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102570:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102573:	85 ff                	test   %edi,%edi
f0102575:	74 32                	je     f01025a9 <memcmp+0x45>
		if (*s1 != *s2)
f0102577:	8a 03                	mov    (%ebx),%al
f0102579:	8a 0e                	mov    (%esi),%cl
f010257b:	38 c8                	cmp    %cl,%al
f010257d:	74 19                	je     f0102598 <memcmp+0x34>
f010257f:	eb 0d                	jmp    f010258e <memcmp+0x2a>
f0102581:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0102585:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0102589:	42                   	inc    %edx
f010258a:	38 c8                	cmp    %cl,%al
f010258c:	74 10                	je     f010259e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f010258e:	0f b6 c0             	movzbl %al,%eax
f0102591:	0f b6 c9             	movzbl %cl,%ecx
f0102594:	29 c8                	sub    %ecx,%eax
f0102596:	eb 16                	jmp    f01025ae <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102598:	4f                   	dec    %edi
f0102599:	ba 00 00 00 00       	mov    $0x0,%edx
f010259e:	39 fa                	cmp    %edi,%edx
f01025a0:	75 df                	jne    f0102581 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01025a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01025a7:	eb 05                	jmp    f01025ae <memcmp+0x4a>
f01025a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01025ae:	5b                   	pop    %ebx
f01025af:	5e                   	pop    %esi
f01025b0:	5f                   	pop    %edi
f01025b1:	c9                   	leave  
f01025b2:	c3                   	ret    

f01025b3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01025b3:	55                   	push   %ebp
f01025b4:	89 e5                	mov    %esp,%ebp
f01025b6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01025b9:	89 c2                	mov    %eax,%edx
f01025bb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01025be:	39 d0                	cmp    %edx,%eax
f01025c0:	73 12                	jae    f01025d4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f01025c2:	8a 4d 0c             	mov    0xc(%ebp),%cl
f01025c5:	38 08                	cmp    %cl,(%eax)
f01025c7:	75 06                	jne    f01025cf <memfind+0x1c>
f01025c9:	eb 09                	jmp    f01025d4 <memfind+0x21>
f01025cb:	38 08                	cmp    %cl,(%eax)
f01025cd:	74 05                	je     f01025d4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01025cf:	40                   	inc    %eax
f01025d0:	39 c2                	cmp    %eax,%edx
f01025d2:	77 f7                	ja     f01025cb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01025d4:	c9                   	leave  
f01025d5:	c3                   	ret    

f01025d6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01025d6:	55                   	push   %ebp
f01025d7:	89 e5                	mov    %esp,%ebp
f01025d9:	57                   	push   %edi
f01025da:	56                   	push   %esi
f01025db:	53                   	push   %ebx
f01025dc:	8b 55 08             	mov    0x8(%ebp),%edx
f01025df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01025e2:	eb 01                	jmp    f01025e5 <strtol+0xf>
		s++;
f01025e4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01025e5:	8a 02                	mov    (%edx),%al
f01025e7:	3c 20                	cmp    $0x20,%al
f01025e9:	74 f9                	je     f01025e4 <strtol+0xe>
f01025eb:	3c 09                	cmp    $0x9,%al
f01025ed:	74 f5                	je     f01025e4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01025ef:	3c 2b                	cmp    $0x2b,%al
f01025f1:	75 08                	jne    f01025fb <strtol+0x25>
		s++;
f01025f3:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01025f4:	bf 00 00 00 00       	mov    $0x0,%edi
f01025f9:	eb 13                	jmp    f010260e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01025fb:	3c 2d                	cmp    $0x2d,%al
f01025fd:	75 0a                	jne    f0102609 <strtol+0x33>
		s++, neg = 1;
f01025ff:	8d 52 01             	lea    0x1(%edx),%edx
f0102602:	bf 01 00 00 00       	mov    $0x1,%edi
f0102607:	eb 05                	jmp    f010260e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0102609:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010260e:	85 db                	test   %ebx,%ebx
f0102610:	74 05                	je     f0102617 <strtol+0x41>
f0102612:	83 fb 10             	cmp    $0x10,%ebx
f0102615:	75 28                	jne    f010263f <strtol+0x69>
f0102617:	8a 02                	mov    (%edx),%al
f0102619:	3c 30                	cmp    $0x30,%al
f010261b:	75 10                	jne    f010262d <strtol+0x57>
f010261d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0102621:	75 0a                	jne    f010262d <strtol+0x57>
		s += 2, base = 16;
f0102623:	83 c2 02             	add    $0x2,%edx
f0102626:	bb 10 00 00 00       	mov    $0x10,%ebx
f010262b:	eb 12                	jmp    f010263f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f010262d:	85 db                	test   %ebx,%ebx
f010262f:	75 0e                	jne    f010263f <strtol+0x69>
f0102631:	3c 30                	cmp    $0x30,%al
f0102633:	75 05                	jne    f010263a <strtol+0x64>
		s++, base = 8;
f0102635:	42                   	inc    %edx
f0102636:	b3 08                	mov    $0x8,%bl
f0102638:	eb 05                	jmp    f010263f <strtol+0x69>
	else if (base == 0)
		base = 10;
f010263a:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010263f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102644:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0102646:	8a 0a                	mov    (%edx),%cl
f0102648:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f010264b:	80 fb 09             	cmp    $0x9,%bl
f010264e:	77 08                	ja     f0102658 <strtol+0x82>
			dig = *s - '0';
f0102650:	0f be c9             	movsbl %cl,%ecx
f0102653:	83 e9 30             	sub    $0x30,%ecx
f0102656:	eb 1e                	jmp    f0102676 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0102658:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010265b:	80 fb 19             	cmp    $0x19,%bl
f010265e:	77 08                	ja     f0102668 <strtol+0x92>
			dig = *s - 'a' + 10;
f0102660:	0f be c9             	movsbl %cl,%ecx
f0102663:	83 e9 57             	sub    $0x57,%ecx
f0102666:	eb 0e                	jmp    f0102676 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0102668:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f010266b:	80 fb 19             	cmp    $0x19,%bl
f010266e:	77 13                	ja     f0102683 <strtol+0xad>
			dig = *s - 'A' + 10;
f0102670:	0f be c9             	movsbl %cl,%ecx
f0102673:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0102676:	39 f1                	cmp    %esi,%ecx
f0102678:	7d 0d                	jge    f0102687 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f010267a:	42                   	inc    %edx
f010267b:	0f af c6             	imul   %esi,%eax
f010267e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0102681:	eb c3                	jmp    f0102646 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0102683:	89 c1                	mov    %eax,%ecx
f0102685:	eb 02                	jmp    f0102689 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0102687:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0102689:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010268d:	74 05                	je     f0102694 <strtol+0xbe>
		*endptr = (char *) s;
f010268f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102692:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0102694:	85 ff                	test   %edi,%edi
f0102696:	74 04                	je     f010269c <strtol+0xc6>
f0102698:	89 c8                	mov    %ecx,%eax
f010269a:	f7 d8                	neg    %eax
}
f010269c:	5b                   	pop    %ebx
f010269d:	5e                   	pop    %esi
f010269e:	5f                   	pop    %edi
f010269f:	c9                   	leave  
f01026a0:	c3                   	ret    
f01026a1:	00 00                	add    %al,(%eax)
	...

f01026a4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01026a4:	55                   	push   %ebp
f01026a5:	89 e5                	mov    %esp,%ebp
f01026a7:	57                   	push   %edi
f01026a8:	56                   	push   %esi
f01026a9:	83 ec 10             	sub    $0x10,%esp
f01026ac:	8b 7d 08             	mov    0x8(%ebp),%edi
f01026af:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01026b2:	89 7d f0             	mov    %edi,-0x10(%ebp)
f01026b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f01026b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01026bb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01026be:	85 c0                	test   %eax,%eax
f01026c0:	75 2e                	jne    f01026f0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f01026c2:	39 f1                	cmp    %esi,%ecx
f01026c4:	77 5a                	ja     f0102720 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01026c6:	85 c9                	test   %ecx,%ecx
f01026c8:	75 0b                	jne    f01026d5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01026ca:	b8 01 00 00 00       	mov    $0x1,%eax
f01026cf:	31 d2                	xor    %edx,%edx
f01026d1:	f7 f1                	div    %ecx
f01026d3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01026d5:	31 d2                	xor    %edx,%edx
f01026d7:	89 f0                	mov    %esi,%eax
f01026d9:	f7 f1                	div    %ecx
f01026db:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01026dd:	89 f8                	mov    %edi,%eax
f01026df:	f7 f1                	div    %ecx
f01026e1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01026e3:	89 f8                	mov    %edi,%eax
f01026e5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01026e7:	83 c4 10             	add    $0x10,%esp
f01026ea:	5e                   	pop    %esi
f01026eb:	5f                   	pop    %edi
f01026ec:	c9                   	leave  
f01026ed:	c3                   	ret    
f01026ee:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01026f0:	39 f0                	cmp    %esi,%eax
f01026f2:	77 1c                	ja     f0102710 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01026f4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f01026f7:	83 f7 1f             	xor    $0x1f,%edi
f01026fa:	75 3c                	jne    f0102738 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01026fc:	39 f0                	cmp    %esi,%eax
f01026fe:	0f 82 90 00 00 00    	jb     f0102794 <__udivdi3+0xf0>
f0102704:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102707:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f010270a:	0f 86 84 00 00 00    	jbe    f0102794 <__udivdi3+0xf0>
f0102710:	31 f6                	xor    %esi,%esi
f0102712:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0102714:	89 f8                	mov    %edi,%eax
f0102716:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0102718:	83 c4 10             	add    $0x10,%esp
f010271b:	5e                   	pop    %esi
f010271c:	5f                   	pop    %edi
f010271d:	c9                   	leave  
f010271e:	c3                   	ret    
f010271f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0102720:	89 f2                	mov    %esi,%edx
f0102722:	89 f8                	mov    %edi,%eax
f0102724:	f7 f1                	div    %ecx
f0102726:	89 c7                	mov    %eax,%edi
f0102728:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010272a:	89 f8                	mov    %edi,%eax
f010272c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010272e:	83 c4 10             	add    $0x10,%esp
f0102731:	5e                   	pop    %esi
f0102732:	5f                   	pop    %edi
f0102733:	c9                   	leave  
f0102734:	c3                   	ret    
f0102735:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0102738:	89 f9                	mov    %edi,%ecx
f010273a:	d3 e0                	shl    %cl,%eax
f010273c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010273f:	b8 20 00 00 00       	mov    $0x20,%eax
f0102744:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0102746:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102749:	88 c1                	mov    %al,%cl
f010274b:	d3 ea                	shr    %cl,%edx
f010274d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102750:	09 ca                	or     %ecx,%edx
f0102752:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0102755:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102758:	89 f9                	mov    %edi,%ecx
f010275a:	d3 e2                	shl    %cl,%edx
f010275c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f010275f:	89 f2                	mov    %esi,%edx
f0102761:	88 c1                	mov    %al,%cl
f0102763:	d3 ea                	shr    %cl,%edx
f0102765:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0102768:	89 f2                	mov    %esi,%edx
f010276a:	89 f9                	mov    %edi,%ecx
f010276c:	d3 e2                	shl    %cl,%edx
f010276e:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0102771:	88 c1                	mov    %al,%cl
f0102773:	d3 ee                	shr    %cl,%esi
f0102775:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0102777:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010277a:	89 f0                	mov    %esi,%eax
f010277c:	89 ca                	mov    %ecx,%edx
f010277e:	f7 75 ec             	divl   -0x14(%ebp)
f0102781:	89 d1                	mov    %edx,%ecx
f0102783:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0102785:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0102788:	39 d1                	cmp    %edx,%ecx
f010278a:	72 28                	jb     f01027b4 <__udivdi3+0x110>
f010278c:	74 1a                	je     f01027a8 <__udivdi3+0x104>
f010278e:	89 f7                	mov    %esi,%edi
f0102790:	31 f6                	xor    %esi,%esi
f0102792:	eb 80                	jmp    f0102714 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0102794:	31 f6                	xor    %esi,%esi
f0102796:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010279b:	89 f8                	mov    %edi,%eax
f010279d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010279f:	83 c4 10             	add    $0x10,%esp
f01027a2:	5e                   	pop    %esi
f01027a3:	5f                   	pop    %edi
f01027a4:	c9                   	leave  
f01027a5:	c3                   	ret    
f01027a6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01027a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01027ab:	89 f9                	mov    %edi,%ecx
f01027ad:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01027af:	39 c2                	cmp    %eax,%edx
f01027b1:	73 db                	jae    f010278e <__udivdi3+0xea>
f01027b3:	90                   	nop
		{
		  q0--;
f01027b4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01027b7:	31 f6                	xor    %esi,%esi
f01027b9:	e9 56 ff ff ff       	jmp    f0102714 <__udivdi3+0x70>
	...

f01027c0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f01027c0:	55                   	push   %ebp
f01027c1:	89 e5                	mov    %esp,%ebp
f01027c3:	57                   	push   %edi
f01027c4:	56                   	push   %esi
f01027c5:	83 ec 20             	sub    $0x20,%esp
f01027c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01027cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01027ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01027d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f01027d4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01027d7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f01027da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f01027dd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01027df:	85 ff                	test   %edi,%edi
f01027e1:	75 15                	jne    f01027f8 <__umoddi3+0x38>
    {
      if (d0 > n1)
f01027e3:	39 f1                	cmp    %esi,%ecx
f01027e5:	0f 86 99 00 00 00    	jbe    f0102884 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01027eb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f01027ed:	89 d0                	mov    %edx,%eax
f01027ef:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01027f1:	83 c4 20             	add    $0x20,%esp
f01027f4:	5e                   	pop    %esi
f01027f5:	5f                   	pop    %edi
f01027f6:	c9                   	leave  
f01027f7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01027f8:	39 f7                	cmp    %esi,%edi
f01027fa:	0f 87 a4 00 00 00    	ja     f01028a4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0102800:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0102803:	83 f0 1f             	xor    $0x1f,%eax
f0102806:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102809:	0f 84 a1 00 00 00    	je     f01028b0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f010280f:	89 f8                	mov    %edi,%eax
f0102811:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0102814:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0102816:	bf 20 00 00 00       	mov    $0x20,%edi
f010281b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f010281e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102821:	89 f9                	mov    %edi,%ecx
f0102823:	d3 ea                	shr    %cl,%edx
f0102825:	09 c2                	or     %eax,%edx
f0102827:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f010282a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010282d:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0102830:	d3 e0                	shl    %cl,%eax
f0102832:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0102835:	89 f2                	mov    %esi,%edx
f0102837:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0102839:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010283c:	d3 e0                	shl    %cl,%eax
f010283e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0102841:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102844:	89 f9                	mov    %edi,%ecx
f0102846:	d3 e8                	shr    %cl,%eax
f0102848:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f010284a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f010284c:	89 f2                	mov    %esi,%edx
f010284e:	f7 75 f0             	divl   -0x10(%ebp)
f0102851:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0102853:	f7 65 f4             	mull   -0xc(%ebp)
f0102856:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102859:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010285b:	39 d6                	cmp    %edx,%esi
f010285d:	72 71                	jb     f01028d0 <__umoddi3+0x110>
f010285f:	74 7f                	je     f01028e0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0102861:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102864:	29 c8                	sub    %ecx,%eax
f0102866:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0102868:	8a 4d ec             	mov    -0x14(%ebp),%cl
f010286b:	d3 e8                	shr    %cl,%eax
f010286d:	89 f2                	mov    %esi,%edx
f010286f:	89 f9                	mov    %edi,%ecx
f0102871:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0102873:	09 d0                	or     %edx,%eax
f0102875:	89 f2                	mov    %esi,%edx
f0102877:	8a 4d ec             	mov    -0x14(%ebp),%cl
f010287a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f010287c:	83 c4 20             	add    $0x20,%esp
f010287f:	5e                   	pop    %esi
f0102880:	5f                   	pop    %edi
f0102881:	c9                   	leave  
f0102882:	c3                   	ret    
f0102883:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0102884:	85 c9                	test   %ecx,%ecx
f0102886:	75 0b                	jne    f0102893 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0102888:	b8 01 00 00 00       	mov    $0x1,%eax
f010288d:	31 d2                	xor    %edx,%edx
f010288f:	f7 f1                	div    %ecx
f0102891:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0102893:	89 f0                	mov    %esi,%eax
f0102895:	31 d2                	xor    %edx,%edx
f0102897:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0102899:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010289c:	f7 f1                	div    %ecx
f010289e:	e9 4a ff ff ff       	jmp    f01027ed <__umoddi3+0x2d>
f01028a3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f01028a4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01028a6:	83 c4 20             	add    $0x20,%esp
f01028a9:	5e                   	pop    %esi
f01028aa:	5f                   	pop    %edi
f01028ab:	c9                   	leave  
f01028ac:	c3                   	ret    
f01028ad:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01028b0:	39 f7                	cmp    %esi,%edi
f01028b2:	72 05                	jb     f01028b9 <__umoddi3+0xf9>
f01028b4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f01028b7:	77 0c                	ja     f01028c5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01028b9:	89 f2                	mov    %esi,%edx
f01028bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01028be:	29 c8                	sub    %ecx,%eax
f01028c0:	19 fa                	sbb    %edi,%edx
f01028c2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f01028c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01028c8:	83 c4 20             	add    $0x20,%esp
f01028cb:	5e                   	pop    %esi
f01028cc:	5f                   	pop    %edi
f01028cd:	c9                   	leave  
f01028ce:	c3                   	ret    
f01028cf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01028d0:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01028d3:	89 c1                	mov    %eax,%ecx
f01028d5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f01028d8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f01028db:	eb 84                	jmp    f0102861 <__umoddi3+0xa1>
f01028dd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01028e0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f01028e3:	72 eb                	jb     f01028d0 <__umoddi3+0x110>
f01028e5:	89 f2                	mov    %esi,%edx
f01028e7:	e9 75 ff ff ff       	jmp    f0102861 <__umoddi3+0xa1>
