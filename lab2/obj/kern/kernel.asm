
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
f0100015:	b8 00 b0 11 00       	mov    $0x11b000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

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
f0100046:	b8 50 d9 11 f0       	mov    $0xf011d950,%eax
f010004b:	2d 00 d3 11 f0       	sub    $0xf011d300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 d3 11 f0       	push   $0xf011d300
f0100058:	e8 98 31 00 00       	call   f01031f5 <memset>

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
f010006a:	68 60 36 10 f0       	push   $0xf0103660
f010006f:	e8 51 26 00 00       	call   f01026c5 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 e0 0f 00 00       	call   f0101059 <mem_init>
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
f0100093:	83 3d 40 d9 11 f0 00 	cmpl   $0x0,0xf011d940
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 40 d9 11 f0    	mov    %esi,0xf011d940

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
f01000b0:	68 7b 36 10 f0       	push   $0xf010367b
f01000b5:	e8 0b 26 00 00       	call   f01026c5 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 db 25 00 00       	call   f010269f <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 fc 46 10 f0 	movl   $0xf01046fc,(%esp)
f01000cb:	e8 f5 25 00 00       	call   f01026c5 <cprintf>
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
f01000f2:	68 93 36 10 f0       	push   $0xf0103693
f01000f7:	e8 c9 25 00 00       	call   f01026c5 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 97 25 00 00       	call   f010269f <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 fc 46 10 f0 	movl   $0xf01046fc,(%esp)
f010010f:	e8 b1 25 00 00       	call   f01026c5 <cprintf>
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
f0100155:	8b 15 24 d5 11 f0    	mov    0xf011d524,%edx
f010015b:	88 82 20 d3 11 f0    	mov    %al,-0xfee2ce0(%edx)
f0100161:	8d 42 01             	lea    0x1(%edx),%eax
f0100164:	a3 24 d5 11 f0       	mov    %eax,0xf011d524
		if (cons.wpos == CONSBUFSIZE)
f0100169:	3d 00 02 00 00       	cmp    $0x200,%eax
f010016e:	75 0a                	jne    f010017a <cons_intr+0x34>
			cons.wpos = 0;
f0100170:	c7 05 24 d5 11 f0 00 	movl   $0x0,0xf011d524
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
f01001f3:	a1 00 d3 11 f0       	mov    0xf011d300,%eax
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
f0100237:	66 a1 04 d3 11 f0    	mov    0xf011d304,%ax
f010023d:	66 85 c0             	test   %ax,%ax
f0100240:	0f 84 e0 00 00 00    	je     f0100326 <cons_putc+0x19f>
			crt_pos--;
f0100246:	48                   	dec    %eax
f0100247:	66 a3 04 d3 11 f0    	mov    %ax,0xf011d304
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010024d:	0f b7 c0             	movzwl %ax,%eax
f0100250:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100256:	83 ce 20             	or     $0x20,%esi
f0100259:	8b 15 08 d3 11 f0    	mov    0xf011d308,%edx
f010025f:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100263:	eb 78                	jmp    f01002dd <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100265:	66 83 05 04 d3 11 f0 	addw   $0x50,0xf011d304
f010026c:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010026d:	66 8b 0d 04 d3 11 f0 	mov    0xf011d304,%cx
f0100274:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100279:	89 c8                	mov    %ecx,%eax
f010027b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100280:	66 f7 f3             	div    %bx
f0100283:	66 29 d1             	sub    %dx,%cx
f0100286:	66 89 0d 04 d3 11 f0 	mov    %cx,0xf011d304
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
f01002c3:	66 a1 04 d3 11 f0    	mov    0xf011d304,%ax
f01002c9:	0f b7 c8             	movzwl %ax,%ecx
f01002cc:	8b 15 08 d3 11 f0    	mov    0xf011d308,%edx
f01002d2:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01002d6:	40                   	inc    %eax
f01002d7:	66 a3 04 d3 11 f0    	mov    %ax,0xf011d304
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f01002dd:	66 81 3d 04 d3 11 f0 	cmpw   $0x7cf,0xf011d304
f01002e4:	cf 07 
f01002e6:	76 3e                	jbe    f0100326 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01002e8:	a1 08 d3 11 f0       	mov    0xf011d308,%eax
f01002ed:	83 ec 04             	sub    $0x4,%esp
f01002f0:	68 00 0f 00 00       	push   $0xf00
f01002f5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01002fb:	52                   	push   %edx
f01002fc:	50                   	push   %eax
f01002fd:	e8 3d 2f 00 00       	call   f010323f <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100302:	8b 15 08 d3 11 f0    	mov    0xf011d308,%edx
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
f010031e:	66 83 2d 04 d3 11 f0 	subw   $0x50,0xf011d304
f0100325:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100326:	8b 0d 0c d3 11 f0    	mov    0xf011d30c,%ecx
f010032c:	b0 0e                	mov    $0xe,%al
f010032e:	89 ca                	mov    %ecx,%edx
f0100330:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100331:	66 8b 35 04 d3 11 f0 	mov    0xf011d304,%si
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
f0100374:	83 0d 28 d5 11 f0 40 	orl    $0x40,0xf011d528
		return 0;
f010037b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100380:	e9 c7 00 00 00       	jmp    f010044c <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f0100385:	84 c0                	test   %al,%al
f0100387:	79 33                	jns    f01003bc <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100389:	8b 0d 28 d5 11 f0    	mov    0xf011d528,%ecx
f010038f:	f6 c1 40             	test   $0x40,%cl
f0100392:	75 05                	jne    f0100399 <kbd_proc_data+0x43>
f0100394:	88 c2                	mov    %al,%dl
f0100396:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100399:	0f b6 d2             	movzbl %dl,%edx
f010039c:	8a 82 e0 36 10 f0    	mov    -0xfefc920(%edx),%al
f01003a2:	83 c8 40             	or     $0x40,%eax
f01003a5:	0f b6 c0             	movzbl %al,%eax
f01003a8:	f7 d0                	not    %eax
f01003aa:	21 c1                	and    %eax,%ecx
f01003ac:	89 0d 28 d5 11 f0    	mov    %ecx,0xf011d528
		return 0;
f01003b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003b7:	e9 90 00 00 00       	jmp    f010044c <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f01003bc:	8b 0d 28 d5 11 f0    	mov    0xf011d528,%ecx
f01003c2:	f6 c1 40             	test   $0x40,%cl
f01003c5:	74 0e                	je     f01003d5 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003c7:	88 c2                	mov    %al,%dl
f01003c9:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003cc:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003cf:	89 0d 28 d5 11 f0    	mov    %ecx,0xf011d528
	}

	shift |= shiftcode[data];
f01003d5:	0f b6 d2             	movzbl %dl,%edx
f01003d8:	0f b6 82 e0 36 10 f0 	movzbl -0xfefc920(%edx),%eax
f01003df:	0b 05 28 d5 11 f0    	or     0xf011d528,%eax
	shift ^= togglecode[data];
f01003e5:	0f b6 8a e0 37 10 f0 	movzbl -0xfefc820(%edx),%ecx
f01003ec:	31 c8                	xor    %ecx,%eax
f01003ee:	a3 28 d5 11 f0       	mov    %eax,0xf011d528

	c = charcode[shift & (CTL | SHIFT)][data];
f01003f3:	89 c1                	mov    %eax,%ecx
f01003f5:	83 e1 03             	and    $0x3,%ecx
f01003f8:	8b 0c 8d e0 38 10 f0 	mov    -0xfefc720(,%ecx,4),%ecx
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
f0100430:	68 ad 36 10 f0       	push   $0xf01036ad
f0100435:	e8 8b 22 00 00       	call   f01026c5 <cprintf>
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
f0100459:	80 3d 10 d3 11 f0 00 	cmpb   $0x0,0xf011d310
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
f0100490:	8b 15 20 d5 11 f0    	mov    0xf011d520,%edx
f0100496:	3b 15 24 d5 11 f0    	cmp    0xf011d524,%edx
f010049c:	74 22                	je     f01004c0 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010049e:	0f b6 82 20 d3 11 f0 	movzbl -0xfee2ce0(%edx),%eax
f01004a5:	42                   	inc    %edx
f01004a6:	89 15 20 d5 11 f0    	mov    %edx,0xf011d520
		if (cons.rpos == CONSBUFSIZE)
f01004ac:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004b2:	75 11                	jne    f01004c5 <cons_getc+0x45>
			cons.rpos = 0;
f01004b4:	c7 05 20 d5 11 f0 00 	movl   $0x0,0xf011d520
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
f01004ec:	c7 05 0c d3 11 f0 b4 	movl   $0x3b4,0xf011d30c
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
f0100504:	c7 05 0c d3 11 f0 d4 	movl   $0x3d4,0xf011d30c
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
f0100513:	8b 0d 0c d3 11 f0    	mov    0xf011d30c,%ecx
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
f0100532:	89 35 08 d3 11 f0    	mov    %esi,0xf011d308

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100538:	0f b6 d8             	movzbl %al,%ebx
f010053b:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010053d:	66 89 3d 04 d3 11 f0 	mov    %di,0xf011d304
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
f010057d:	a2 10 d3 11 f0       	mov    %al,0xf011d310
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
f0100591:	68 b9 36 10 f0       	push   $0xf01036b9
f0100596:	e8 2a 21 00 00       	call   f01026c5 <cprintf>
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
f01005da:	68 f0 38 10 f0       	push   $0xf01038f0
f01005df:	e8 e1 20 00 00       	call   f01026c5 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005e4:	83 c4 08             	add    $0x8,%esp
f01005e7:	68 0c 00 10 00       	push   $0x10000c
f01005ec:	68 e8 39 10 f0       	push   $0xf01039e8
f01005f1:	e8 cf 20 00 00       	call   f01026c5 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01005f6:	83 c4 0c             	add    $0xc,%esp
f01005f9:	68 0c 00 10 00       	push   $0x10000c
f01005fe:	68 0c 00 10 f0       	push   $0xf010000c
f0100603:	68 10 3a 10 f0       	push   $0xf0103a10
f0100608:	e8 b8 20 00 00       	call   f01026c5 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010060d:	83 c4 0c             	add    $0xc,%esp
f0100610:	68 44 36 10 00       	push   $0x103644
f0100615:	68 44 36 10 f0       	push   $0xf0103644
f010061a:	68 34 3a 10 f0       	push   $0xf0103a34
f010061f:	e8 a1 20 00 00       	call   f01026c5 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100624:	83 c4 0c             	add    $0xc,%esp
f0100627:	68 00 d3 11 00       	push   $0x11d300
f010062c:	68 00 d3 11 f0       	push   $0xf011d300
f0100631:	68 58 3a 10 f0       	push   $0xf0103a58
f0100636:	e8 8a 20 00 00       	call   f01026c5 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010063b:	83 c4 0c             	add    $0xc,%esp
f010063e:	68 50 d9 11 00       	push   $0x11d950
f0100643:	68 50 d9 11 f0       	push   $0xf011d950
f0100648:	68 7c 3a 10 f0       	push   $0xf0103a7c
f010064d:	e8 73 20 00 00       	call   f01026c5 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100652:	b8 4f dd 11 f0       	mov    $0xf011dd4f,%eax
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
f0100674:	68 a0 3a 10 f0       	push   $0xf0103aa0
f0100679:	e8 47 20 00 00       	call   f01026c5 <cprintf>
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
f010068b:	ff 35 24 3d 10 f0    	pushl  0xf0103d24
f0100691:	ff 35 20 3d 10 f0    	pushl  0xf0103d20
f0100697:	68 09 39 10 f0       	push   $0xf0103909
f010069c:	e8 24 20 00 00       	call   f01026c5 <cprintf>
f01006a1:	83 c4 0c             	add    $0xc,%esp
f01006a4:	ff 35 30 3d 10 f0    	pushl  0xf0103d30
f01006aa:	ff 35 2c 3d 10 f0    	pushl  0xf0103d2c
f01006b0:	68 09 39 10 f0       	push   $0xf0103909
f01006b5:	e8 0b 20 00 00       	call   f01026c5 <cprintf>
f01006ba:	83 c4 0c             	add    $0xc,%esp
f01006bd:	ff 35 3c 3d 10 f0    	pushl  0xf0103d3c
f01006c3:	ff 35 38 3d 10 f0    	pushl  0xf0103d38
f01006c9:	68 09 39 10 f0       	push   $0xf0103909
f01006ce:	e8 f2 1f 00 00       	call   f01026c5 <cprintf>
f01006d3:	83 c4 0c             	add    $0xc,%esp
f01006d6:	ff 35 48 3d 10 f0    	pushl  0xf0103d48
f01006dc:	ff 35 44 3d 10 f0    	pushl  0xf0103d44
f01006e2:	68 09 39 10 f0       	push   $0xf0103909
f01006e7:	e8 d9 1f 00 00       	call   f01026c5 <cprintf>
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
f0100704:	68 cc 3a 10 f0       	push   $0xf0103acc
f0100709:	e8 b7 1f 00 00       	call   f01026c5 <cprintf>
        cprintf("num show the color attribute. \n");
f010070e:	c7 04 24 fc 3a 10 f0 	movl   $0xf0103afc,(%esp)
f0100715:	e8 ab 1f 00 00       	call   f01026c5 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f010071a:	c7 04 24 1c 3b 10 f0 	movl   $0xf0103b1c,(%esp)
f0100721:	e8 9f 1f 00 00       	call   f01026c5 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100726:	c7 04 24 50 3b 10 f0 	movl   $0xf0103b50,(%esp)
f010072d:	e8 93 1f 00 00       	call   f01026c5 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100732:	c7 04 24 94 3b 10 f0 	movl   $0xf0103b94,(%esp)
f0100739:	e8 87 1f 00 00       	call   f01026c5 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f010073e:	c7 04 24 12 39 10 f0 	movl   $0xf0103912,(%esp)
f0100745:	e8 7b 1f 00 00       	call   f01026c5 <cprintf>
        cprintf("         set the background color to black\n");
f010074a:	c7 04 24 d8 3b 10 f0 	movl   $0xf0103bd8,(%esp)
f0100751:	e8 6f 1f 00 00       	call   f01026c5 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100756:	c7 04 24 04 3c 10 f0 	movl   $0xf0103c04,(%esp)
f010075d:	e8 63 1f 00 00       	call   f01026c5 <cprintf>
f0100762:	83 c4 10             	add    $0x10,%esp
f0100765:	eb 52                	jmp    f01007b9 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100767:	83 ec 0c             	sub    $0xc,%esp
f010076a:	ff 73 04             	pushl  0x4(%ebx)
f010076d:	e8 ba 28 00 00       	call   f010302c <strlen>
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
f01007a3:	89 15 00 d3 11 f0    	mov    %edx,0xf011d300
        cprintf(" This is color that you want ! \n");
f01007a9:	83 ec 0c             	sub    $0xc,%esp
f01007ac:	68 38 3c 10 f0       	push   $0xf0103c38
f01007b1:	e8 0f 1f 00 00       	call   f01026c5 <cprintf>
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
f01007ed:	68 5c 3c 10 f0       	push   $0xf0103c5c
f01007f2:	e8 ce 1e 00 00       	call   f01026c5 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f01007f7:	83 c4 18             	add    $0x18,%esp
f01007fa:	57                   	push   %edi
f01007fb:	ff 76 04             	pushl  0x4(%esi)
f01007fe:	e8 fe 1f 00 00       	call   f0102801 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100803:	83 c4 0c             	add    $0xc,%esp
f0100806:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100809:	ff 75 d0             	pushl  -0x30(%ebp)
f010080c:	68 2e 39 10 f0       	push   $0xf010392e
f0100811:	e8 af 1e 00 00       	call   f01026c5 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100816:	83 c4 0c             	add    $0xc,%esp
f0100819:	ff 75 d8             	pushl  -0x28(%ebp)
f010081c:	ff 75 dc             	pushl  -0x24(%ebp)
f010081f:	68 3e 39 10 f0       	push   $0xf010393e
f0100824:	e8 9c 1e 00 00       	call   f01026c5 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100829:	83 c4 08             	add    $0x8,%esp
f010082c:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f010082f:	53                   	push   %ebx
f0100830:	68 43 39 10 f0       	push   $0xf0103943
f0100835:	e8 8b 1e 00 00       	call   f01026c5 <cprintf>
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
f0100859:	68 94 3c 10 f0       	push   $0xf0103c94
f010085e:	e8 62 1e 00 00       	call   f01026c5 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100863:	c7 04 24 b8 3c 10 f0 	movl   $0xf0103cb8,(%esp)
f010086a:	e8 56 1e 00 00       	call   f01026c5 <cprintf>
f010086f:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100872:	83 ec 0c             	sub    $0xc,%esp
f0100875:	68 48 39 10 f0       	push   $0xf0103948
f010087a:	e8 dd 26 00 00       	call   f0102f5c <readline>
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
f01008a7:	68 4c 39 10 f0       	push   $0xf010394c
f01008ac:	e8 f4 28 00 00       	call   f01031a5 <strchr>
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
f01008c7:	68 51 39 10 f0       	push   $0xf0103951
f01008cc:	e8 f4 1d 00 00       	call   f01026c5 <cprintf>
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
f01008f1:	68 4c 39 10 f0       	push   $0xf010394c
f01008f6:	e8 aa 28 00 00       	call   f01031a5 <strchr>
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
f0100914:	bb 20 3d 10 f0       	mov    $0xf0103d20,%ebx
f0100919:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010091e:	83 ec 08             	sub    $0x8,%esp
f0100921:	ff 33                	pushl  (%ebx)
f0100923:	ff 75 a8             	pushl  -0x58(%ebp)
f0100926:	e8 0c 28 00 00       	call   f0103137 <strcmp>
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
f0100940:	ff 97 28 3d 10 f0    	call   *-0xfefc2d8(%edi)


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
f0100961:	68 6e 39 10 f0       	push   $0xf010396e
f0100966:	e8 5a 1d 00 00       	call   f01026c5 <cprintf>
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
f0100981:	83 3d 30 d5 11 f0 00 	cmpl   $0x0,0xf011d530
f0100988:	75 0f                	jne    f0100999 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010098a:	b8 4f e9 11 f0       	mov    $0xf011e94f,%eax
f010098f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100994:	a3 30 d5 11 f0       	mov    %eax,0xf011d530
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0100999:	a1 30 d5 11 f0       	mov    0xf011d530,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f010099e:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f01009a5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01009ab:	89 15 30 d5 11 f0    	mov    %edx,0xf011d530

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
f01009cf:	3b 0d 44 d9 11 f0    	cmp    0xf011d944,%ecx
f01009d5:	72 15                	jb     f01009ec <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009d7:	50                   	push   %eax
f01009d8:	68 50 3d 10 f0       	push   $0xf0103d50
f01009dd:	68 c2 02 00 00       	push   $0x2c2
f01009e2:	68 6c 44 10 f0       	push   $0xf010446c
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
f0100a20:	e8 3f 1c 00 00       	call   f0102664 <mc146818_read>
f0100a25:	89 c6                	mov    %eax,%esi
f0100a27:	43                   	inc    %ebx
f0100a28:	89 1c 24             	mov    %ebx,(%esp)
f0100a2b:	e8 34 1c 00 00       	call   f0102664 <mc146818_read>
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
f0100a50:	8b 1d 2c d5 11 f0    	mov    0xf011d52c,%ebx
f0100a56:	85 db                	test   %ebx,%ebx
f0100a58:	75 17                	jne    f0100a71 <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f0100a5a:	83 ec 04             	sub    $0x4,%esp
f0100a5d:	68 74 3d 10 f0       	push   $0xf0103d74
f0100a62:	68 05 02 00 00       	push   $0x205
f0100a67:	68 6c 44 10 f0       	push   $0xf010446c
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
f0100a83:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
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
f0100abb:	89 1d 2c d5 11 f0    	mov    %ebx,0xf011d52c
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ac1:	85 db                	test   %ebx,%ebx
f0100ac3:	74 57                	je     f0100b1c <check_page_free_list+0xe0>
f0100ac5:	89 d8                	mov    %ebx,%eax
f0100ac7:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
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
f0100ae1:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f0100ae7:	72 12                	jb     f0100afb <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ae9:	50                   	push   %eax
f0100aea:	68 50 3d 10 f0       	push   $0xf0103d50
f0100aef:	6a 52                	push   $0x52
f0100af1:	68 78 44 10 f0       	push   $0xf0104478
f0100af6:	e8 90 f5 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100afb:	83 ec 04             	sub    $0x4,%esp
f0100afe:	68 80 00 00 00       	push   $0x80
f0100b03:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100b08:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b0d:	50                   	push   %eax
f0100b0e:	e8 e2 26 00 00       	call   f01031f5 <memset>
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
f0100b29:	8b 15 2c d5 11 f0    	mov    0xf011d52c,%edx
f0100b2f:	85 d2                	test   %edx,%edx
f0100b31:	0f 84 80 01 00 00    	je     f0100cb7 <check_page_free_list+0x27b>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b37:	8b 1d 4c d9 11 f0    	mov    0xf011d94c,%ebx
f0100b3d:	39 da                	cmp    %ebx,%edx
f0100b3f:	72 43                	jb     f0100b84 <check_page_free_list+0x148>
		assert(pp < pages + npages);
f0100b41:	a1 44 d9 11 f0       	mov    0xf011d944,%eax
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
f0100b84:	68 86 44 10 f0       	push   $0xf0104486
f0100b89:	68 92 44 10 f0       	push   $0xf0104492
f0100b8e:	68 1f 02 00 00       	push   $0x21f
f0100b93:	68 6c 44 10 f0       	push   $0xf010446c
f0100b98:	e8 ee f4 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100b9d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100ba0:	72 19                	jb     f0100bbb <check_page_free_list+0x17f>
f0100ba2:	68 a7 44 10 f0       	push   $0xf01044a7
f0100ba7:	68 92 44 10 f0       	push   $0xf0104492
f0100bac:	68 20 02 00 00       	push   $0x220
f0100bb1:	68 6c 44 10 f0       	push   $0xf010446c
f0100bb6:	e8 d0 f4 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bbb:	89 d0                	mov    %edx,%eax
f0100bbd:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100bc0:	a8 07                	test   $0x7,%al
f0100bc2:	74 19                	je     f0100bdd <check_page_free_list+0x1a1>
f0100bc4:	68 98 3d 10 f0       	push   $0xf0103d98
f0100bc9:	68 92 44 10 f0       	push   $0xf0104492
f0100bce:	68 21 02 00 00       	push   $0x221
f0100bd3:	68 6c 44 10 f0       	push   $0xf010446c
f0100bd8:	e8 ae f4 ff ff       	call   f010008b <_panic>
f0100bdd:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100be0:	c1 e0 0c             	shl    $0xc,%eax
f0100be3:	75 19                	jne    f0100bfe <check_page_free_list+0x1c2>
f0100be5:	68 bb 44 10 f0       	push   $0xf01044bb
f0100bea:	68 92 44 10 f0       	push   $0xf0104492
f0100bef:	68 24 02 00 00       	push   $0x224
f0100bf4:	68 6c 44 10 f0       	push   $0xf010446c
f0100bf9:	e8 8d f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bfe:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c03:	75 19                	jne    f0100c1e <check_page_free_list+0x1e2>
f0100c05:	68 cc 44 10 f0       	push   $0xf01044cc
f0100c0a:	68 92 44 10 f0       	push   $0xf0104492
f0100c0f:	68 25 02 00 00       	push   $0x225
f0100c14:	68 6c 44 10 f0       	push   $0xf010446c
f0100c19:	e8 6d f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c1e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c23:	75 19                	jne    f0100c3e <check_page_free_list+0x202>
f0100c25:	68 cc 3d 10 f0       	push   $0xf0103dcc
f0100c2a:	68 92 44 10 f0       	push   $0xf0104492
f0100c2f:	68 26 02 00 00       	push   $0x226
f0100c34:	68 6c 44 10 f0       	push   $0xf010446c
f0100c39:	e8 4d f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c3e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c43:	75 19                	jne    f0100c5e <check_page_free_list+0x222>
f0100c45:	68 e5 44 10 f0       	push   $0xf01044e5
f0100c4a:	68 92 44 10 f0       	push   $0xf0104492
f0100c4f:	68 27 02 00 00       	push   $0x227
f0100c54:	68 6c 44 10 f0       	push   $0xf010446c
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
f0100c70:	68 50 3d 10 f0       	push   $0xf0103d50
f0100c75:	6a 52                	push   $0x52
f0100c77:	68 78 44 10 f0       	push   $0xf0104478
f0100c7c:	e8 0a f4 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0100c81:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0100c87:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100c8a:	76 1c                	jbe    f0100ca8 <check_page_free_list+0x26c>
f0100c8c:	68 f0 3d 10 f0       	push   $0xf0103df0
f0100c91:	68 92 44 10 f0       	push   $0xf0104492
f0100c96:	68 28 02 00 00       	push   $0x228
f0100c9b:	68 6c 44 10 f0       	push   $0xf010446c
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
f0100cb7:	68 ff 44 10 f0       	push   $0xf01044ff
f0100cbc:	68 92 44 10 f0       	push   $0xf0104492
f0100cc1:	68 30 02 00 00       	push   $0x230
f0100cc6:	68 6c 44 10 f0       	push   $0xf010446c
f0100ccb:	e8 bb f3 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100cd0:	85 f6                	test   %esi,%esi
f0100cd2:	7f 19                	jg     f0100ced <check_page_free_list+0x2b1>
f0100cd4:	68 11 45 10 f0       	push   $0xf0104511
f0100cd9:	68 92 44 10 f0       	push   $0xf0104492
f0100cde:	68 31 02 00 00       	push   $0x231
f0100ce3:	68 6c 44 10 f0       	push   $0xf010446c
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
f0100cfa:	c7 05 2c d5 11 f0 00 	movl   $0x0,0xf011d52c
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
f0100d16:	68 38 3e 10 f0       	push   $0xf0103e38
f0100d1b:	68 10 01 00 00       	push   $0x110
f0100d20:	68 6c 44 10 f0       	push   $0xf010446c
f0100d25:	e8 61 f3 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100d2a:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f0100d30:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f0100d33:	83 3d 44 d9 11 f0 00 	cmpl   $0x0,0xf011d944
f0100d3a:	74 5f                	je     f0100d9b <page_init+0xa6>
f0100d3c:	8b 1d 2c d5 11 f0    	mov    0xf011d52c,%ebx
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
f0100d5d:	03 0d 4c d9 11 f0    	add    0xf011d94c,%ecx
f0100d63:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f0100d69:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f0100d6b:	89 d3                	mov    %edx,%ebx
f0100d6d:	03 1d 4c d9 11 f0    	add    0xf011d94c,%ebx
f0100d73:	eb 14                	jmp    f0100d89 <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f0100d75:	89 d1                	mov    %edx,%ecx
f0100d77:	03 0d 4c d9 11 f0    	add    0xf011d94c,%ecx
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
f0100d8d:	39 05 44 d9 11 f0    	cmp    %eax,0xf011d944
f0100d93:	77 b7                	ja     f0100d4c <page_init+0x57>
f0100d95:	89 1d 2c d5 11 f0    	mov    %ebx,0xf011d52c
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
f0100da9:	8b 1d 2c d5 11 f0    	mov    0xf011d52c,%ebx
f0100daf:	85 db                	test   %ebx,%ebx
f0100db1:	74 52                	je     f0100e05 <page_alloc+0x63>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f0100db3:	8b 03                	mov    (%ebx),%eax
f0100db5:	a3 2c d5 11 f0       	mov    %eax,0xf011d52c
        if (alloc_flags & ALLOC_ZERO) {
f0100dba:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100dbe:	74 45                	je     f0100e05 <page_alloc+0x63>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dc0:	89 d8                	mov    %ebx,%eax
f0100dc2:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
f0100dc8:	c1 f8 03             	sar    $0x3,%eax
f0100dcb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dce:	89 c2                	mov    %eax,%edx
f0100dd0:	c1 ea 0c             	shr    $0xc,%edx
f0100dd3:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f0100dd9:	72 12                	jb     f0100ded <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ddb:	50                   	push   %eax
f0100ddc:	68 50 3d 10 f0       	push   $0xf0103d50
f0100de1:	6a 52                	push   $0x52
f0100de3:	68 78 44 10 f0       	push   $0xf0104478
f0100de8:	e8 9e f2 ff ff       	call   f010008b <_panic>
            memset(page2kva(alloc_page), 0, PGSIZE);
f0100ded:	83 ec 04             	sub    $0x4,%esp
f0100df0:	68 00 10 00 00       	push   $0x1000
f0100df5:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100df7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100dfc:	50                   	push   %eax
f0100dfd:	e8 f3 23 00 00       	call   f01031f5 <memset>
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
f0100e1d:	8b 15 2c d5 11 f0    	mov    0xf011d52c,%edx
f0100e23:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0100e25:	a3 2c d5 11 f0       	mov    %eax,0xf011d52c
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
f0100e4d:	56                   	push   %esi
f0100e4e:	53                   	push   %ebx
f0100e4f:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f0100e52:	89 f3                	mov    %esi,%ebx
f0100e54:	c1 eb 16             	shr    $0x16,%ebx
f0100e57:	c1 e3 02             	shl    $0x2,%ebx
f0100e5a:	03 5d 08             	add    0x8(%ebp),%ebx
f0100e5d:	8b 03                	mov    (%ebx),%eax
f0100e5f:	85 c0                	test   %eax,%eax
f0100e61:	74 04                	je     f0100e67 <pgdir_walk+0x1d>
f0100e63:	a8 01                	test   $0x1,%al
f0100e65:	75 2c                	jne    f0100e93 <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f0100e67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e6b:	74 61                	je     f0100ece <pgdir_walk+0x84>

        struct PageInfo * new_page = page_alloc(1);
f0100e6d:	83 ec 0c             	sub    $0xc,%esp
f0100e70:	6a 01                	push   $0x1
f0100e72:	e8 2b ff ff ff       	call   f0100da2 <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f0100e77:	83 c4 10             	add    $0x10,%esp
f0100e7a:	85 c0                	test   %eax,%eax
f0100e7c:	74 57                	je     f0100ed5 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f0100e7e:	66 ff 40 04          	incw   0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e82:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
f0100e88:	c1 f8 03             	sar    $0x3,%eax
f0100e8b:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f0100e8e:	83 c8 07             	or     $0x7,%eax
f0100e91:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f0100e93:	8b 03                	mov    (%ebx),%eax
f0100e95:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e9a:	89 c2                	mov    %eax,%edx
f0100e9c:	c1 ea 0c             	shr    $0xc,%edx
f0100e9f:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f0100ea5:	72 15                	jb     f0100ebc <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ea7:	50                   	push   %eax
f0100ea8:	68 50 3d 10 f0       	push   $0xf0103d50
f0100ead:	68 71 01 00 00       	push   $0x171
f0100eb2:	68 6c 44 10 f0       	push   $0xf010446c
f0100eb7:	e8 cf f1 ff ff       	call   f010008b <_panic>
f0100ebc:	c1 ee 0a             	shr    $0xa,%esi
f0100ebf:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100ec5:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100ecc:	eb 0c                	jmp    f0100eda <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f0100ece:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ed3:	eb 05                	jmp    f0100eda <pgdir_walk+0x90>

        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f0100ed5:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f0100eda:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100edd:	5b                   	pop    %ebx
f0100ede:	5e                   	pop    %esi
f0100edf:	c9                   	leave  
f0100ee0:	c3                   	ret    

f0100ee1 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100ee1:	55                   	push   %ebp
f0100ee2:	89 e5                	mov    %esp,%ebp
f0100ee4:	57                   	push   %edi
f0100ee5:	56                   	push   %esi
f0100ee6:	53                   	push   %ebx
f0100ee7:	83 ec 1c             	sub    $0x1c,%esp
f0100eea:	89 c7                	mov    %eax,%edi
f0100eec:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0100eef:	01 d1                	add    %edx,%ecx
f0100ef1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100ef4:	39 ca                	cmp    %ecx,%edx
f0100ef6:	74 32                	je     f0100f2a <boot_map_region+0x49>
f0100ef8:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f0100efa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100efd:	83 c8 01             	or     $0x1,%eax
f0100f00:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f0100f03:	83 ec 04             	sub    $0x4,%esp
f0100f06:	6a 01                	push   $0x1
f0100f08:	53                   	push   %ebx
f0100f09:	57                   	push   %edi
f0100f0a:	e8 3b ff ff ff       	call   f0100e4a <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f0100f0f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100f12:	09 f2                	or     %esi,%edx
f0100f14:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0100f16:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100f1c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100f22:	83 c4 10             	add    $0x10,%esp
f0100f25:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100f28:	75 d9                	jne    f0100f03 <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f0100f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f2d:	5b                   	pop    %ebx
f0100f2e:	5e                   	pop    %esi
f0100f2f:	5f                   	pop    %edi
f0100f30:	c9                   	leave  
f0100f31:	c3                   	ret    

f0100f32 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f32:	55                   	push   %ebp
f0100f33:	89 e5                	mov    %esp,%ebp
f0100f35:	53                   	push   %ebx
f0100f36:	83 ec 08             	sub    $0x8,%esp
f0100f39:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f0100f3c:	6a 00                	push   $0x0
f0100f3e:	ff 75 0c             	pushl  0xc(%ebp)
f0100f41:	ff 75 08             	pushl  0x8(%ebp)
f0100f44:	e8 01 ff ff ff       	call   f0100e4a <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0100f49:	83 c4 10             	add    $0x10,%esp
f0100f4c:	85 c0                	test   %eax,%eax
f0100f4e:	74 37                	je     f0100f87 <page_lookup+0x55>
f0100f50:	f6 00 01             	testb  $0x1,(%eax)
f0100f53:	74 39                	je     f0100f8e <page_lookup+0x5c>
    if (pte_store != 0) {
f0100f55:	85 db                	test   %ebx,%ebx
f0100f57:	74 02                	je     f0100f5b <page_lookup+0x29>
        *pte_store = pte;
f0100f59:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f0100f5b:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f5d:	c1 e8 0c             	shr    $0xc,%eax
f0100f60:	3b 05 44 d9 11 f0    	cmp    0xf011d944,%eax
f0100f66:	72 14                	jb     f0100f7c <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0100f68:	83 ec 04             	sub    $0x4,%esp
f0100f6b:	68 5c 3e 10 f0       	push   $0xf0103e5c
f0100f70:	6a 4b                	push   $0x4b
f0100f72:	68 78 44 10 f0       	push   $0xf0104478
f0100f77:	e8 0f f1 ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0100f7c:	c1 e0 03             	shl    $0x3,%eax
f0100f7f:	03 05 4c d9 11 f0    	add    0xf011d94c,%eax
f0100f85:	eb 0c                	jmp    f0100f93 <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0100f87:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f8c:	eb 05                	jmp    f0100f93 <page_lookup+0x61>
f0100f8e:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f0100f93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f96:	c9                   	leave  
f0100f97:	c3                   	ret    

f0100f98 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100f98:	55                   	push   %ebp
f0100f99:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100f9b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f9e:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100fa1:	c9                   	leave  
f0100fa2:	c3                   	ret    

f0100fa3 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100fa3:	55                   	push   %ebp
f0100fa4:	89 e5                	mov    %esp,%ebp
f0100fa6:	56                   	push   %esi
f0100fa7:	53                   	push   %ebx
f0100fa8:	83 ec 14             	sub    $0x14,%esp
f0100fab:	8b 75 08             	mov    0x8(%ebp),%esi
f0100fae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f0100fb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100fb4:	50                   	push   %eax
f0100fb5:	53                   	push   %ebx
f0100fb6:	56                   	push   %esi
f0100fb7:	e8 76 ff ff ff       	call   f0100f32 <page_lookup>
    if (pg == NULL) return;
f0100fbc:	83 c4 10             	add    $0x10,%esp
f0100fbf:	85 c0                	test   %eax,%eax
f0100fc1:	74 26                	je     f0100fe9 <page_remove+0x46>
    page_decref(pg);
f0100fc3:	83 ec 0c             	sub    $0xc,%esp
f0100fc6:	50                   	push   %eax
f0100fc7:	e8 60 fe ff ff       	call   f0100e2c <page_decref>
    if (pte != NULL) *pte = 0;
f0100fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100fcf:	83 c4 10             	add    $0x10,%esp
f0100fd2:	85 c0                	test   %eax,%eax
f0100fd4:	74 06                	je     f0100fdc <page_remove+0x39>
f0100fd6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f0100fdc:	83 ec 08             	sub    $0x8,%esp
f0100fdf:	53                   	push   %ebx
f0100fe0:	56                   	push   %esi
f0100fe1:	e8 b2 ff ff ff       	call   f0100f98 <tlb_invalidate>
f0100fe6:	83 c4 10             	add    $0x10,%esp
}
f0100fe9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fec:	5b                   	pop    %ebx
f0100fed:	5e                   	pop    %esi
f0100fee:	c9                   	leave  
f0100fef:	c3                   	ret    

f0100ff0 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100ff0:	55                   	push   %ebp
f0100ff1:	89 e5                	mov    %esp,%ebp
f0100ff3:	57                   	push   %edi
f0100ff4:	56                   	push   %esi
f0100ff5:	53                   	push   %ebx
f0100ff6:	83 ec 10             	sub    $0x10,%esp
f0100ff9:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100ffc:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f0100fff:	6a 01                	push   $0x1
f0101001:	57                   	push   %edi
f0101002:	ff 75 08             	pushl  0x8(%ebp)
f0101005:	e8 40 fe ff ff       	call   f0100e4a <pgdir_walk>
f010100a:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f010100c:	83 c4 10             	add    $0x10,%esp
f010100f:	85 c0                	test   %eax,%eax
f0101011:	74 39                	je     f010104c <page_insert+0x5c>
    ++pp->pp_ref;
f0101013:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f0101017:	f6 00 01             	testb  $0x1,(%eax)
f010101a:	74 0f                	je     f010102b <page_insert+0x3b>
        page_remove(pgdir, va);
f010101c:	83 ec 08             	sub    $0x8,%esp
f010101f:	57                   	push   %edi
f0101020:	ff 75 08             	pushl  0x8(%ebp)
f0101023:	e8 7b ff ff ff       	call   f0100fa3 <page_remove>
f0101028:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f010102b:	8b 55 14             	mov    0x14(%ebp),%edx
f010102e:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101031:	2b 35 4c d9 11 f0    	sub    0xf011d94c,%esi
f0101037:	c1 fe 03             	sar    $0x3,%esi
f010103a:	89 f0                	mov    %esi,%eax
f010103c:	c1 e0 0c             	shl    $0xc,%eax
f010103f:	89 d6                	mov    %edx,%esi
f0101041:	09 c6                	or     %eax,%esi
f0101043:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101045:	b8 00 00 00 00       	mov    $0x0,%eax
f010104a:	eb 05                	jmp    f0101051 <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f010104c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f0101051:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101054:	5b                   	pop    %ebx
f0101055:	5e                   	pop    %esi
f0101056:	5f                   	pop    %edi
f0101057:	c9                   	leave  
f0101058:	c3                   	ret    

f0101059 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101059:	55                   	push   %ebp
f010105a:	89 e5                	mov    %esp,%ebp
f010105c:	57                   	push   %edi
f010105d:	56                   	push   %esi
f010105e:	53                   	push   %ebx
f010105f:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101062:	b8 15 00 00 00       	mov    $0x15,%eax
f0101067:	e8 a9 f9 ff ff       	call   f0100a15 <nvram_read>
f010106c:	c1 e0 0a             	shl    $0xa,%eax
f010106f:	89 c2                	mov    %eax,%edx
f0101071:	85 c0                	test   %eax,%eax
f0101073:	79 06                	jns    f010107b <mem_init+0x22>
f0101075:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010107b:	c1 fa 0c             	sar    $0xc,%edx
f010107e:	89 15 34 d5 11 f0    	mov    %edx,0xf011d534
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101084:	b8 17 00 00 00       	mov    $0x17,%eax
f0101089:	e8 87 f9 ff ff       	call   f0100a15 <nvram_read>
f010108e:	89 c2                	mov    %eax,%edx
f0101090:	c1 e2 0a             	shl    $0xa,%edx
f0101093:	89 d0                	mov    %edx,%eax
f0101095:	85 d2                	test   %edx,%edx
f0101097:	79 06                	jns    f010109f <mem_init+0x46>
f0101099:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010109f:	c1 f8 0c             	sar    $0xc,%eax
f01010a2:	74 0e                	je     f01010b2 <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01010a4:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01010aa:	89 15 44 d9 11 f0    	mov    %edx,0xf011d944
f01010b0:	eb 0c                	jmp    f01010be <mem_init+0x65>
	else
		npages = npages_basemem;
f01010b2:	8b 15 34 d5 11 f0    	mov    0xf011d534,%edx
f01010b8:	89 15 44 d9 11 f0    	mov    %edx,0xf011d944

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01010be:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01010c1:	c1 e8 0a             	shr    $0xa,%eax
f01010c4:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01010c5:	a1 34 d5 11 f0       	mov    0xf011d534,%eax
f01010ca:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01010cd:	c1 e8 0a             	shr    $0xa,%eax
f01010d0:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01010d1:	a1 44 d9 11 f0       	mov    0xf011d944,%eax
f01010d6:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01010d9:	c1 e8 0a             	shr    $0xa,%eax
f01010dc:	50                   	push   %eax
f01010dd:	68 7c 3e 10 f0       	push   $0xf0103e7c
f01010e2:	e8 de 15 00 00       	call   f01026c5 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01010e7:	b8 00 10 00 00       	mov    $0x1000,%eax
f01010ec:	e8 8b f8 ff ff       	call   f010097c <boot_alloc>
f01010f1:	a3 48 d9 11 f0       	mov    %eax,0xf011d948
	memset(kern_pgdir, 0, PGSIZE);
f01010f6:	83 c4 0c             	add    $0xc,%esp
f01010f9:	68 00 10 00 00       	push   $0x1000
f01010fe:	6a 00                	push   $0x0
f0101100:	50                   	push   %eax
f0101101:	e8 ef 20 00 00       	call   f01031f5 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101106:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010110b:	83 c4 10             	add    $0x10,%esp
f010110e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101113:	77 15                	ja     f010112a <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101115:	50                   	push   %eax
f0101116:	68 38 3e 10 f0       	push   $0xf0103e38
f010111b:	68 8d 00 00 00       	push   $0x8d
f0101120:	68 6c 44 10 f0       	push   $0xf010446c
f0101125:	e8 61 ef ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f010112a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101130:	83 ca 05             	or     $0x5,%edx
f0101133:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101139:	a1 44 d9 11 f0       	mov    0xf011d944,%eax
f010113e:	c1 e0 03             	shl    $0x3,%eax
f0101141:	e8 36 f8 ff ff       	call   f010097c <boot_alloc>
f0101146:	a3 4c d9 11 f0       	mov    %eax,0xf011d94c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010114b:	e8 a5 fb ff ff       	call   f0100cf5 <page_init>

	check_page_free_list(1);
f0101150:	b8 01 00 00 00       	mov    $0x1,%eax
f0101155:	e8 e2 f8 ff ff       	call   f0100a3c <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010115a:	83 3d 4c d9 11 f0 00 	cmpl   $0x0,0xf011d94c
f0101161:	75 17                	jne    f010117a <mem_init+0x121>
		panic("'pages' is a null pointer!");
f0101163:	83 ec 04             	sub    $0x4,%esp
f0101166:	68 22 45 10 f0       	push   $0xf0104522
f010116b:	68 42 02 00 00       	push   $0x242
f0101170:	68 6c 44 10 f0       	push   $0xf010446c
f0101175:	e8 11 ef ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010117a:	a1 2c d5 11 f0       	mov    0xf011d52c,%eax
f010117f:	85 c0                	test   %eax,%eax
f0101181:	74 0e                	je     f0101191 <mem_init+0x138>
f0101183:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101188:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101189:	8b 00                	mov    (%eax),%eax
f010118b:	85 c0                	test   %eax,%eax
f010118d:	75 f9                	jne    f0101188 <mem_init+0x12f>
f010118f:	eb 05                	jmp    f0101196 <mem_init+0x13d>
f0101191:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101196:	83 ec 0c             	sub    $0xc,%esp
f0101199:	6a 00                	push   $0x0
f010119b:	e8 02 fc ff ff       	call   f0100da2 <page_alloc>
f01011a0:	89 c6                	mov    %eax,%esi
f01011a2:	83 c4 10             	add    $0x10,%esp
f01011a5:	85 c0                	test   %eax,%eax
f01011a7:	75 19                	jne    f01011c2 <mem_init+0x169>
f01011a9:	68 3d 45 10 f0       	push   $0xf010453d
f01011ae:	68 92 44 10 f0       	push   $0xf0104492
f01011b3:	68 4a 02 00 00       	push   $0x24a
f01011b8:	68 6c 44 10 f0       	push   $0xf010446c
f01011bd:	e8 c9 ee ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01011c2:	83 ec 0c             	sub    $0xc,%esp
f01011c5:	6a 00                	push   $0x0
f01011c7:	e8 d6 fb ff ff       	call   f0100da2 <page_alloc>
f01011cc:	89 c7                	mov    %eax,%edi
f01011ce:	83 c4 10             	add    $0x10,%esp
f01011d1:	85 c0                	test   %eax,%eax
f01011d3:	75 19                	jne    f01011ee <mem_init+0x195>
f01011d5:	68 53 45 10 f0       	push   $0xf0104553
f01011da:	68 92 44 10 f0       	push   $0xf0104492
f01011df:	68 4b 02 00 00       	push   $0x24b
f01011e4:	68 6c 44 10 f0       	push   $0xf010446c
f01011e9:	e8 9d ee ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01011ee:	83 ec 0c             	sub    $0xc,%esp
f01011f1:	6a 00                	push   $0x0
f01011f3:	e8 aa fb ff ff       	call   f0100da2 <page_alloc>
f01011f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011fb:	83 c4 10             	add    $0x10,%esp
f01011fe:	85 c0                	test   %eax,%eax
f0101200:	75 19                	jne    f010121b <mem_init+0x1c2>
f0101202:	68 69 45 10 f0       	push   $0xf0104569
f0101207:	68 92 44 10 f0       	push   $0xf0104492
f010120c:	68 4c 02 00 00       	push   $0x24c
f0101211:	68 6c 44 10 f0       	push   $0xf010446c
f0101216:	e8 70 ee ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010121b:	39 fe                	cmp    %edi,%esi
f010121d:	75 19                	jne    f0101238 <mem_init+0x1df>
f010121f:	68 7f 45 10 f0       	push   $0xf010457f
f0101224:	68 92 44 10 f0       	push   $0xf0104492
f0101229:	68 4f 02 00 00       	push   $0x24f
f010122e:	68 6c 44 10 f0       	push   $0xf010446c
f0101233:	e8 53 ee ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101238:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010123b:	74 05                	je     f0101242 <mem_init+0x1e9>
f010123d:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101240:	75 19                	jne    f010125b <mem_init+0x202>
f0101242:	68 b8 3e 10 f0       	push   $0xf0103eb8
f0101247:	68 92 44 10 f0       	push   $0xf0104492
f010124c:	68 50 02 00 00       	push   $0x250
f0101251:	68 6c 44 10 f0       	push   $0xf010446c
f0101256:	e8 30 ee ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010125b:	8b 15 4c d9 11 f0    	mov    0xf011d94c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101261:	a1 44 d9 11 f0       	mov    0xf011d944,%eax
f0101266:	c1 e0 0c             	shl    $0xc,%eax
f0101269:	89 f1                	mov    %esi,%ecx
f010126b:	29 d1                	sub    %edx,%ecx
f010126d:	c1 f9 03             	sar    $0x3,%ecx
f0101270:	c1 e1 0c             	shl    $0xc,%ecx
f0101273:	39 c1                	cmp    %eax,%ecx
f0101275:	72 19                	jb     f0101290 <mem_init+0x237>
f0101277:	68 91 45 10 f0       	push   $0xf0104591
f010127c:	68 92 44 10 f0       	push   $0xf0104492
f0101281:	68 51 02 00 00       	push   $0x251
f0101286:	68 6c 44 10 f0       	push   $0xf010446c
f010128b:	e8 fb ed ff ff       	call   f010008b <_panic>
f0101290:	89 f9                	mov    %edi,%ecx
f0101292:	29 d1                	sub    %edx,%ecx
f0101294:	c1 f9 03             	sar    $0x3,%ecx
f0101297:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010129a:	39 c8                	cmp    %ecx,%eax
f010129c:	77 19                	ja     f01012b7 <mem_init+0x25e>
f010129e:	68 ae 45 10 f0       	push   $0xf01045ae
f01012a3:	68 92 44 10 f0       	push   $0xf0104492
f01012a8:	68 52 02 00 00       	push   $0x252
f01012ad:	68 6c 44 10 f0       	push   $0xf010446c
f01012b2:	e8 d4 ed ff ff       	call   f010008b <_panic>
f01012b7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01012ba:	29 d1                	sub    %edx,%ecx
f01012bc:	89 ca                	mov    %ecx,%edx
f01012be:	c1 fa 03             	sar    $0x3,%edx
f01012c1:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01012c4:	39 d0                	cmp    %edx,%eax
f01012c6:	77 19                	ja     f01012e1 <mem_init+0x288>
f01012c8:	68 cb 45 10 f0       	push   $0xf01045cb
f01012cd:	68 92 44 10 f0       	push   $0xf0104492
f01012d2:	68 53 02 00 00       	push   $0x253
f01012d7:	68 6c 44 10 f0       	push   $0xf010446c
f01012dc:	e8 aa ed ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01012e1:	a1 2c d5 11 f0       	mov    0xf011d52c,%eax
f01012e6:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01012e9:	c7 05 2c d5 11 f0 00 	movl   $0x0,0xf011d52c
f01012f0:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01012f3:	83 ec 0c             	sub    $0xc,%esp
f01012f6:	6a 00                	push   $0x0
f01012f8:	e8 a5 fa ff ff       	call   f0100da2 <page_alloc>
f01012fd:	83 c4 10             	add    $0x10,%esp
f0101300:	85 c0                	test   %eax,%eax
f0101302:	74 19                	je     f010131d <mem_init+0x2c4>
f0101304:	68 e8 45 10 f0       	push   $0xf01045e8
f0101309:	68 92 44 10 f0       	push   $0xf0104492
f010130e:	68 5a 02 00 00       	push   $0x25a
f0101313:	68 6c 44 10 f0       	push   $0xf010446c
f0101318:	e8 6e ed ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f010131d:	83 ec 0c             	sub    $0xc,%esp
f0101320:	56                   	push   %esi
f0101321:	e8 e6 fa ff ff       	call   f0100e0c <page_free>
	page_free(pp1);
f0101326:	89 3c 24             	mov    %edi,(%esp)
f0101329:	e8 de fa ff ff       	call   f0100e0c <page_free>
	page_free(pp2);
f010132e:	83 c4 04             	add    $0x4,%esp
f0101331:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101334:	e8 d3 fa ff ff       	call   f0100e0c <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101339:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101340:	e8 5d fa ff ff       	call   f0100da2 <page_alloc>
f0101345:	89 c6                	mov    %eax,%esi
f0101347:	83 c4 10             	add    $0x10,%esp
f010134a:	85 c0                	test   %eax,%eax
f010134c:	75 19                	jne    f0101367 <mem_init+0x30e>
f010134e:	68 3d 45 10 f0       	push   $0xf010453d
f0101353:	68 92 44 10 f0       	push   $0xf0104492
f0101358:	68 61 02 00 00       	push   $0x261
f010135d:	68 6c 44 10 f0       	push   $0xf010446c
f0101362:	e8 24 ed ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101367:	83 ec 0c             	sub    $0xc,%esp
f010136a:	6a 00                	push   $0x0
f010136c:	e8 31 fa ff ff       	call   f0100da2 <page_alloc>
f0101371:	89 c7                	mov    %eax,%edi
f0101373:	83 c4 10             	add    $0x10,%esp
f0101376:	85 c0                	test   %eax,%eax
f0101378:	75 19                	jne    f0101393 <mem_init+0x33a>
f010137a:	68 53 45 10 f0       	push   $0xf0104553
f010137f:	68 92 44 10 f0       	push   $0xf0104492
f0101384:	68 62 02 00 00       	push   $0x262
f0101389:	68 6c 44 10 f0       	push   $0xf010446c
f010138e:	e8 f8 ec ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101393:	83 ec 0c             	sub    $0xc,%esp
f0101396:	6a 00                	push   $0x0
f0101398:	e8 05 fa ff ff       	call   f0100da2 <page_alloc>
f010139d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013a0:	83 c4 10             	add    $0x10,%esp
f01013a3:	85 c0                	test   %eax,%eax
f01013a5:	75 19                	jne    f01013c0 <mem_init+0x367>
f01013a7:	68 69 45 10 f0       	push   $0xf0104569
f01013ac:	68 92 44 10 f0       	push   $0xf0104492
f01013b1:	68 63 02 00 00       	push   $0x263
f01013b6:	68 6c 44 10 f0       	push   $0xf010446c
f01013bb:	e8 cb ec ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013c0:	39 fe                	cmp    %edi,%esi
f01013c2:	75 19                	jne    f01013dd <mem_init+0x384>
f01013c4:	68 7f 45 10 f0       	push   $0xf010457f
f01013c9:	68 92 44 10 f0       	push   $0xf0104492
f01013ce:	68 65 02 00 00       	push   $0x265
f01013d3:	68 6c 44 10 f0       	push   $0xf010446c
f01013d8:	e8 ae ec ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013dd:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01013e0:	74 05                	je     f01013e7 <mem_init+0x38e>
f01013e2:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01013e5:	75 19                	jne    f0101400 <mem_init+0x3a7>
f01013e7:	68 b8 3e 10 f0       	push   $0xf0103eb8
f01013ec:	68 92 44 10 f0       	push   $0xf0104492
f01013f1:	68 66 02 00 00       	push   $0x266
f01013f6:	68 6c 44 10 f0       	push   $0xf010446c
f01013fb:	e8 8b ec ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101400:	83 ec 0c             	sub    $0xc,%esp
f0101403:	6a 00                	push   $0x0
f0101405:	e8 98 f9 ff ff       	call   f0100da2 <page_alloc>
f010140a:	83 c4 10             	add    $0x10,%esp
f010140d:	85 c0                	test   %eax,%eax
f010140f:	74 19                	je     f010142a <mem_init+0x3d1>
f0101411:	68 e8 45 10 f0       	push   $0xf01045e8
f0101416:	68 92 44 10 f0       	push   $0xf0104492
f010141b:	68 67 02 00 00       	push   $0x267
f0101420:	68 6c 44 10 f0       	push   $0xf010446c
f0101425:	e8 61 ec ff ff       	call   f010008b <_panic>
f010142a:	89 f0                	mov    %esi,%eax
f010142c:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
f0101432:	c1 f8 03             	sar    $0x3,%eax
f0101435:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101438:	89 c2                	mov    %eax,%edx
f010143a:	c1 ea 0c             	shr    $0xc,%edx
f010143d:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f0101443:	72 12                	jb     f0101457 <mem_init+0x3fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101445:	50                   	push   %eax
f0101446:	68 50 3d 10 f0       	push   $0xf0103d50
f010144b:	6a 52                	push   $0x52
f010144d:	68 78 44 10 f0       	push   $0xf0104478
f0101452:	e8 34 ec ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101457:	83 ec 04             	sub    $0x4,%esp
f010145a:	68 00 10 00 00       	push   $0x1000
f010145f:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101461:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101466:	50                   	push   %eax
f0101467:	e8 89 1d 00 00       	call   f01031f5 <memset>
	page_free(pp0);
f010146c:	89 34 24             	mov    %esi,(%esp)
f010146f:	e8 98 f9 ff ff       	call   f0100e0c <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101474:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010147b:	e8 22 f9 ff ff       	call   f0100da2 <page_alloc>
f0101480:	83 c4 10             	add    $0x10,%esp
f0101483:	85 c0                	test   %eax,%eax
f0101485:	75 19                	jne    f01014a0 <mem_init+0x447>
f0101487:	68 f7 45 10 f0       	push   $0xf01045f7
f010148c:	68 92 44 10 f0       	push   $0xf0104492
f0101491:	68 6c 02 00 00       	push   $0x26c
f0101496:	68 6c 44 10 f0       	push   $0xf010446c
f010149b:	e8 eb eb ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f01014a0:	39 c6                	cmp    %eax,%esi
f01014a2:	74 19                	je     f01014bd <mem_init+0x464>
f01014a4:	68 15 46 10 f0       	push   $0xf0104615
f01014a9:	68 92 44 10 f0       	push   $0xf0104492
f01014ae:	68 6d 02 00 00       	push   $0x26d
f01014b3:	68 6c 44 10 f0       	push   $0xf010446c
f01014b8:	e8 ce eb ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014bd:	89 f2                	mov    %esi,%edx
f01014bf:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f01014c5:	c1 fa 03             	sar    $0x3,%edx
f01014c8:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014cb:	89 d0                	mov    %edx,%eax
f01014cd:	c1 e8 0c             	shr    $0xc,%eax
f01014d0:	3b 05 44 d9 11 f0    	cmp    0xf011d944,%eax
f01014d6:	72 12                	jb     f01014ea <mem_init+0x491>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014d8:	52                   	push   %edx
f01014d9:	68 50 3d 10 f0       	push   $0xf0103d50
f01014de:	6a 52                	push   $0x52
f01014e0:	68 78 44 10 f0       	push   $0xf0104478
f01014e5:	e8 a1 eb ff ff       	call   f010008b <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01014ea:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f01014f1:	75 11                	jne    f0101504 <mem_init+0x4ab>
f01014f3:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01014f9:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01014ff:	80 38 00             	cmpb   $0x0,(%eax)
f0101502:	74 19                	je     f010151d <mem_init+0x4c4>
f0101504:	68 25 46 10 f0       	push   $0xf0104625
f0101509:	68 92 44 10 f0       	push   $0xf0104492
f010150e:	68 70 02 00 00       	push   $0x270
f0101513:	68 6c 44 10 f0       	push   $0xf010446c
f0101518:	e8 6e eb ff ff       	call   f010008b <_panic>
f010151d:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010151e:	39 d0                	cmp    %edx,%eax
f0101520:	75 dd                	jne    f01014ff <mem_init+0x4a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101522:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101525:	89 15 2c d5 11 f0    	mov    %edx,0xf011d52c

	// free the pages we took
	page_free(pp0);
f010152b:	83 ec 0c             	sub    $0xc,%esp
f010152e:	56                   	push   %esi
f010152f:	e8 d8 f8 ff ff       	call   f0100e0c <page_free>
	page_free(pp1);
f0101534:	89 3c 24             	mov    %edi,(%esp)
f0101537:	e8 d0 f8 ff ff       	call   f0100e0c <page_free>
	page_free(pp2);
f010153c:	83 c4 04             	add    $0x4,%esp
f010153f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101542:	e8 c5 f8 ff ff       	call   f0100e0c <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101547:	a1 2c d5 11 f0       	mov    0xf011d52c,%eax
f010154c:	83 c4 10             	add    $0x10,%esp
f010154f:	85 c0                	test   %eax,%eax
f0101551:	74 07                	je     f010155a <mem_init+0x501>
		--nfree;
f0101553:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101554:	8b 00                	mov    (%eax),%eax
f0101556:	85 c0                	test   %eax,%eax
f0101558:	75 f9                	jne    f0101553 <mem_init+0x4fa>
		--nfree;
	assert(nfree == 0);
f010155a:	85 db                	test   %ebx,%ebx
f010155c:	74 19                	je     f0101577 <mem_init+0x51e>
f010155e:	68 2f 46 10 f0       	push   $0xf010462f
f0101563:	68 92 44 10 f0       	push   $0xf0104492
f0101568:	68 7d 02 00 00       	push   $0x27d
f010156d:	68 6c 44 10 f0       	push   $0xf010446c
f0101572:	e8 14 eb ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101577:	83 ec 0c             	sub    $0xc,%esp
f010157a:	68 d8 3e 10 f0       	push   $0xf0103ed8
f010157f:	e8 41 11 00 00       	call   f01026c5 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101584:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010158b:	e8 12 f8 ff ff       	call   f0100da2 <page_alloc>
f0101590:	89 c6                	mov    %eax,%esi
f0101592:	83 c4 10             	add    $0x10,%esp
f0101595:	85 c0                	test   %eax,%eax
f0101597:	75 19                	jne    f01015b2 <mem_init+0x559>
f0101599:	68 3d 45 10 f0       	push   $0xf010453d
f010159e:	68 92 44 10 f0       	push   $0xf0104492
f01015a3:	68 d6 02 00 00       	push   $0x2d6
f01015a8:	68 6c 44 10 f0       	push   $0xf010446c
f01015ad:	e8 d9 ea ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01015b2:	83 ec 0c             	sub    $0xc,%esp
f01015b5:	6a 00                	push   $0x0
f01015b7:	e8 e6 f7 ff ff       	call   f0100da2 <page_alloc>
f01015bc:	89 c7                	mov    %eax,%edi
f01015be:	83 c4 10             	add    $0x10,%esp
f01015c1:	85 c0                	test   %eax,%eax
f01015c3:	75 19                	jne    f01015de <mem_init+0x585>
f01015c5:	68 53 45 10 f0       	push   $0xf0104553
f01015ca:	68 92 44 10 f0       	push   $0xf0104492
f01015cf:	68 d7 02 00 00       	push   $0x2d7
f01015d4:	68 6c 44 10 f0       	push   $0xf010446c
f01015d9:	e8 ad ea ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01015de:	83 ec 0c             	sub    $0xc,%esp
f01015e1:	6a 00                	push   $0x0
f01015e3:	e8 ba f7 ff ff       	call   f0100da2 <page_alloc>
f01015e8:	89 c3                	mov    %eax,%ebx
f01015ea:	83 c4 10             	add    $0x10,%esp
f01015ed:	85 c0                	test   %eax,%eax
f01015ef:	75 19                	jne    f010160a <mem_init+0x5b1>
f01015f1:	68 69 45 10 f0       	push   $0xf0104569
f01015f6:	68 92 44 10 f0       	push   $0xf0104492
f01015fb:	68 d8 02 00 00       	push   $0x2d8
f0101600:	68 6c 44 10 f0       	push   $0xf010446c
f0101605:	e8 81 ea ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010160a:	39 fe                	cmp    %edi,%esi
f010160c:	75 19                	jne    f0101627 <mem_init+0x5ce>
f010160e:	68 7f 45 10 f0       	push   $0xf010457f
f0101613:	68 92 44 10 f0       	push   $0xf0104492
f0101618:	68 db 02 00 00       	push   $0x2db
f010161d:	68 6c 44 10 f0       	push   $0xf010446c
f0101622:	e8 64 ea ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101627:	39 c7                	cmp    %eax,%edi
f0101629:	74 04                	je     f010162f <mem_init+0x5d6>
f010162b:	39 c6                	cmp    %eax,%esi
f010162d:	75 19                	jne    f0101648 <mem_init+0x5ef>
f010162f:	68 b8 3e 10 f0       	push   $0xf0103eb8
f0101634:	68 92 44 10 f0       	push   $0xf0104492
f0101639:	68 dc 02 00 00       	push   $0x2dc
f010163e:	68 6c 44 10 f0       	push   $0xf010446c
f0101643:	e8 43 ea ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101648:	8b 0d 2c d5 11 f0    	mov    0xf011d52c,%ecx
f010164e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101651:	c7 05 2c d5 11 f0 00 	movl   $0x0,0xf011d52c
f0101658:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010165b:	83 ec 0c             	sub    $0xc,%esp
f010165e:	6a 00                	push   $0x0
f0101660:	e8 3d f7 ff ff       	call   f0100da2 <page_alloc>
f0101665:	83 c4 10             	add    $0x10,%esp
f0101668:	85 c0                	test   %eax,%eax
f010166a:	74 19                	je     f0101685 <mem_init+0x62c>
f010166c:	68 e8 45 10 f0       	push   $0xf01045e8
f0101671:	68 92 44 10 f0       	push   $0xf0104492
f0101676:	68 e3 02 00 00       	push   $0x2e3
f010167b:	68 6c 44 10 f0       	push   $0xf010446c
f0101680:	e8 06 ea ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101685:	83 ec 04             	sub    $0x4,%esp
f0101688:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010168b:	50                   	push   %eax
f010168c:	6a 00                	push   $0x0
f010168e:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101694:	e8 99 f8 ff ff       	call   f0100f32 <page_lookup>
f0101699:	83 c4 10             	add    $0x10,%esp
f010169c:	85 c0                	test   %eax,%eax
f010169e:	74 19                	je     f01016b9 <mem_init+0x660>
f01016a0:	68 f8 3e 10 f0       	push   $0xf0103ef8
f01016a5:	68 92 44 10 f0       	push   $0xf0104492
f01016aa:	68 e6 02 00 00       	push   $0x2e6
f01016af:	68 6c 44 10 f0       	push   $0xf010446c
f01016b4:	e8 d2 e9 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01016b9:	6a 02                	push   $0x2
f01016bb:	6a 00                	push   $0x0
f01016bd:	57                   	push   %edi
f01016be:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f01016c4:	e8 27 f9 ff ff       	call   f0100ff0 <page_insert>
f01016c9:	83 c4 10             	add    $0x10,%esp
f01016cc:	85 c0                	test   %eax,%eax
f01016ce:	78 19                	js     f01016e9 <mem_init+0x690>
f01016d0:	68 30 3f 10 f0       	push   $0xf0103f30
f01016d5:	68 92 44 10 f0       	push   $0xf0104492
f01016da:	68 e9 02 00 00       	push   $0x2e9
f01016df:	68 6c 44 10 f0       	push   $0xf010446c
f01016e4:	e8 a2 e9 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01016e9:	83 ec 0c             	sub    $0xc,%esp
f01016ec:	56                   	push   %esi
f01016ed:	e8 1a f7 ff ff       	call   f0100e0c <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01016f2:	6a 02                	push   $0x2
f01016f4:	6a 00                	push   $0x0
f01016f6:	57                   	push   %edi
f01016f7:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f01016fd:	e8 ee f8 ff ff       	call   f0100ff0 <page_insert>
f0101702:	83 c4 20             	add    $0x20,%esp
f0101705:	85 c0                	test   %eax,%eax
f0101707:	74 19                	je     f0101722 <mem_init+0x6c9>
f0101709:	68 60 3f 10 f0       	push   $0xf0103f60
f010170e:	68 92 44 10 f0       	push   $0xf0104492
f0101713:	68 ed 02 00 00       	push   $0x2ed
f0101718:	68 6c 44 10 f0       	push   $0xf010446c
f010171d:	e8 69 e9 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101722:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101727:	8b 08                	mov    (%eax),%ecx
f0101729:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010172f:	89 f2                	mov    %esi,%edx
f0101731:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101737:	c1 fa 03             	sar    $0x3,%edx
f010173a:	c1 e2 0c             	shl    $0xc,%edx
f010173d:	39 d1                	cmp    %edx,%ecx
f010173f:	74 19                	je     f010175a <mem_init+0x701>
f0101741:	68 90 3f 10 f0       	push   $0xf0103f90
f0101746:	68 92 44 10 f0       	push   $0xf0104492
f010174b:	68 ee 02 00 00       	push   $0x2ee
f0101750:	68 6c 44 10 f0       	push   $0xf010446c
f0101755:	e8 31 e9 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010175a:	ba 00 00 00 00       	mov    $0x0,%edx
f010175f:	e8 4f f2 ff ff       	call   f01009b3 <check_va2pa>
f0101764:	89 fa                	mov    %edi,%edx
f0101766:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f010176c:	c1 fa 03             	sar    $0x3,%edx
f010176f:	c1 e2 0c             	shl    $0xc,%edx
f0101772:	39 d0                	cmp    %edx,%eax
f0101774:	74 19                	je     f010178f <mem_init+0x736>
f0101776:	68 b8 3f 10 f0       	push   $0xf0103fb8
f010177b:	68 92 44 10 f0       	push   $0xf0104492
f0101780:	68 ef 02 00 00       	push   $0x2ef
f0101785:	68 6c 44 10 f0       	push   $0xf010446c
f010178a:	e8 fc e8 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f010178f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101794:	74 19                	je     f01017af <mem_init+0x756>
f0101796:	68 3a 46 10 f0       	push   $0xf010463a
f010179b:	68 92 44 10 f0       	push   $0xf0104492
f01017a0:	68 f0 02 00 00       	push   $0x2f0
f01017a5:	68 6c 44 10 f0       	push   $0xf010446c
f01017aa:	e8 dc e8 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f01017af:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01017b4:	74 19                	je     f01017cf <mem_init+0x776>
f01017b6:	68 4b 46 10 f0       	push   $0xf010464b
f01017bb:	68 92 44 10 f0       	push   $0xf0104492
f01017c0:	68 f1 02 00 00       	push   $0x2f1
f01017c5:	68 6c 44 10 f0       	push   $0xf010446c
f01017ca:	e8 bc e8 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017cf:	6a 02                	push   $0x2
f01017d1:	68 00 10 00 00       	push   $0x1000
f01017d6:	53                   	push   %ebx
f01017d7:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f01017dd:	e8 0e f8 ff ff       	call   f0100ff0 <page_insert>
f01017e2:	83 c4 10             	add    $0x10,%esp
f01017e5:	85 c0                	test   %eax,%eax
f01017e7:	74 19                	je     f0101802 <mem_init+0x7a9>
f01017e9:	68 e8 3f 10 f0       	push   $0xf0103fe8
f01017ee:	68 92 44 10 f0       	push   $0xf0104492
f01017f3:	68 f4 02 00 00       	push   $0x2f4
f01017f8:	68 6c 44 10 f0       	push   $0xf010446c
f01017fd:	e8 89 e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101802:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101807:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f010180c:	e8 a2 f1 ff ff       	call   f01009b3 <check_va2pa>
f0101811:	89 da                	mov    %ebx,%edx
f0101813:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101819:	c1 fa 03             	sar    $0x3,%edx
f010181c:	c1 e2 0c             	shl    $0xc,%edx
f010181f:	39 d0                	cmp    %edx,%eax
f0101821:	74 19                	je     f010183c <mem_init+0x7e3>
f0101823:	68 24 40 10 f0       	push   $0xf0104024
f0101828:	68 92 44 10 f0       	push   $0xf0104492
f010182d:	68 f5 02 00 00       	push   $0x2f5
f0101832:	68 6c 44 10 f0       	push   $0xf010446c
f0101837:	e8 4f e8 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f010183c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101841:	74 19                	je     f010185c <mem_init+0x803>
f0101843:	68 5c 46 10 f0       	push   $0xf010465c
f0101848:	68 92 44 10 f0       	push   $0xf0104492
f010184d:	68 f6 02 00 00       	push   $0x2f6
f0101852:	68 6c 44 10 f0       	push   $0xf010446c
f0101857:	e8 2f e8 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010185c:	83 ec 0c             	sub    $0xc,%esp
f010185f:	6a 00                	push   $0x0
f0101861:	e8 3c f5 ff ff       	call   f0100da2 <page_alloc>
f0101866:	83 c4 10             	add    $0x10,%esp
f0101869:	85 c0                	test   %eax,%eax
f010186b:	74 19                	je     f0101886 <mem_init+0x82d>
f010186d:	68 e8 45 10 f0       	push   $0xf01045e8
f0101872:	68 92 44 10 f0       	push   $0xf0104492
f0101877:	68 f9 02 00 00       	push   $0x2f9
f010187c:	68 6c 44 10 f0       	push   $0xf010446c
f0101881:	e8 05 e8 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101886:	6a 02                	push   $0x2
f0101888:	68 00 10 00 00       	push   $0x1000
f010188d:	53                   	push   %ebx
f010188e:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101894:	e8 57 f7 ff ff       	call   f0100ff0 <page_insert>
f0101899:	83 c4 10             	add    $0x10,%esp
f010189c:	85 c0                	test   %eax,%eax
f010189e:	74 19                	je     f01018b9 <mem_init+0x860>
f01018a0:	68 e8 3f 10 f0       	push   $0xf0103fe8
f01018a5:	68 92 44 10 f0       	push   $0xf0104492
f01018aa:	68 fc 02 00 00       	push   $0x2fc
f01018af:	68 6c 44 10 f0       	push   $0xf010446c
f01018b4:	e8 d2 e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018b9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018be:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f01018c3:	e8 eb f0 ff ff       	call   f01009b3 <check_va2pa>
f01018c8:	89 da                	mov    %ebx,%edx
f01018ca:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f01018d0:	c1 fa 03             	sar    $0x3,%edx
f01018d3:	c1 e2 0c             	shl    $0xc,%edx
f01018d6:	39 d0                	cmp    %edx,%eax
f01018d8:	74 19                	je     f01018f3 <mem_init+0x89a>
f01018da:	68 24 40 10 f0       	push   $0xf0104024
f01018df:	68 92 44 10 f0       	push   $0xf0104492
f01018e4:	68 fd 02 00 00       	push   $0x2fd
f01018e9:	68 6c 44 10 f0       	push   $0xf010446c
f01018ee:	e8 98 e7 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01018f3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01018f8:	74 19                	je     f0101913 <mem_init+0x8ba>
f01018fa:	68 5c 46 10 f0       	push   $0xf010465c
f01018ff:	68 92 44 10 f0       	push   $0xf0104492
f0101904:	68 fe 02 00 00       	push   $0x2fe
f0101909:	68 6c 44 10 f0       	push   $0xf010446c
f010190e:	e8 78 e7 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101913:	83 ec 0c             	sub    $0xc,%esp
f0101916:	6a 00                	push   $0x0
f0101918:	e8 85 f4 ff ff       	call   f0100da2 <page_alloc>
f010191d:	83 c4 10             	add    $0x10,%esp
f0101920:	85 c0                	test   %eax,%eax
f0101922:	74 19                	je     f010193d <mem_init+0x8e4>
f0101924:	68 e8 45 10 f0       	push   $0xf01045e8
f0101929:	68 92 44 10 f0       	push   $0xf0104492
f010192e:	68 02 03 00 00       	push   $0x302
f0101933:	68 6c 44 10 f0       	push   $0xf010446c
f0101938:	e8 4e e7 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010193d:	8b 15 48 d9 11 f0    	mov    0xf011d948,%edx
f0101943:	8b 02                	mov    (%edx),%eax
f0101945:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010194a:	89 c1                	mov    %eax,%ecx
f010194c:	c1 e9 0c             	shr    $0xc,%ecx
f010194f:	3b 0d 44 d9 11 f0    	cmp    0xf011d944,%ecx
f0101955:	72 15                	jb     f010196c <mem_init+0x913>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101957:	50                   	push   %eax
f0101958:	68 50 3d 10 f0       	push   $0xf0103d50
f010195d:	68 05 03 00 00       	push   $0x305
f0101962:	68 6c 44 10 f0       	push   $0xf010446c
f0101967:	e8 1f e7 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f010196c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101971:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101974:	83 ec 04             	sub    $0x4,%esp
f0101977:	6a 00                	push   $0x0
f0101979:	68 00 10 00 00       	push   $0x1000
f010197e:	52                   	push   %edx
f010197f:	e8 c6 f4 ff ff       	call   f0100e4a <pgdir_walk>
f0101984:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101987:	83 c2 04             	add    $0x4,%edx
f010198a:	83 c4 10             	add    $0x10,%esp
f010198d:	39 d0                	cmp    %edx,%eax
f010198f:	74 19                	je     f01019aa <mem_init+0x951>
f0101991:	68 54 40 10 f0       	push   $0xf0104054
f0101996:	68 92 44 10 f0       	push   $0xf0104492
f010199b:	68 06 03 00 00       	push   $0x306
f01019a0:	68 6c 44 10 f0       	push   $0xf010446c
f01019a5:	e8 e1 e6 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01019aa:	6a 06                	push   $0x6
f01019ac:	68 00 10 00 00       	push   $0x1000
f01019b1:	53                   	push   %ebx
f01019b2:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f01019b8:	e8 33 f6 ff ff       	call   f0100ff0 <page_insert>
f01019bd:	83 c4 10             	add    $0x10,%esp
f01019c0:	85 c0                	test   %eax,%eax
f01019c2:	74 19                	je     f01019dd <mem_init+0x984>
f01019c4:	68 94 40 10 f0       	push   $0xf0104094
f01019c9:	68 92 44 10 f0       	push   $0xf0104492
f01019ce:	68 09 03 00 00       	push   $0x309
f01019d3:	68 6c 44 10 f0       	push   $0xf010446c
f01019d8:	e8 ae e6 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019dd:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019e2:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f01019e7:	e8 c7 ef ff ff       	call   f01009b3 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019ec:	89 da                	mov    %ebx,%edx
f01019ee:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f01019f4:	c1 fa 03             	sar    $0x3,%edx
f01019f7:	c1 e2 0c             	shl    $0xc,%edx
f01019fa:	39 d0                	cmp    %edx,%eax
f01019fc:	74 19                	je     f0101a17 <mem_init+0x9be>
f01019fe:	68 24 40 10 f0       	push   $0xf0104024
f0101a03:	68 92 44 10 f0       	push   $0xf0104492
f0101a08:	68 0a 03 00 00       	push   $0x30a
f0101a0d:	68 6c 44 10 f0       	push   $0xf010446c
f0101a12:	e8 74 e6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101a17:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a1c:	74 19                	je     f0101a37 <mem_init+0x9de>
f0101a1e:	68 5c 46 10 f0       	push   $0xf010465c
f0101a23:	68 92 44 10 f0       	push   $0xf0104492
f0101a28:	68 0b 03 00 00       	push   $0x30b
f0101a2d:	68 6c 44 10 f0       	push   $0xf010446c
f0101a32:	e8 54 e6 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101a37:	83 ec 04             	sub    $0x4,%esp
f0101a3a:	6a 00                	push   $0x0
f0101a3c:	68 00 10 00 00       	push   $0x1000
f0101a41:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101a47:	e8 fe f3 ff ff       	call   f0100e4a <pgdir_walk>
f0101a4c:	83 c4 10             	add    $0x10,%esp
f0101a4f:	f6 00 04             	testb  $0x4,(%eax)
f0101a52:	75 19                	jne    f0101a6d <mem_init+0xa14>
f0101a54:	68 d4 40 10 f0       	push   $0xf01040d4
f0101a59:	68 92 44 10 f0       	push   $0xf0104492
f0101a5e:	68 0c 03 00 00       	push   $0x30c
f0101a63:	68 6c 44 10 f0       	push   $0xf010446c
f0101a68:	e8 1e e6 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101a6d:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101a72:	f6 00 04             	testb  $0x4,(%eax)
f0101a75:	75 19                	jne    f0101a90 <mem_init+0xa37>
f0101a77:	68 6d 46 10 f0       	push   $0xf010466d
f0101a7c:	68 92 44 10 f0       	push   $0xf0104492
f0101a81:	68 0d 03 00 00       	push   $0x30d
f0101a86:	68 6c 44 10 f0       	push   $0xf010446c
f0101a8b:	e8 fb e5 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a90:	6a 02                	push   $0x2
f0101a92:	68 00 10 00 00       	push   $0x1000
f0101a97:	53                   	push   %ebx
f0101a98:	50                   	push   %eax
f0101a99:	e8 52 f5 ff ff       	call   f0100ff0 <page_insert>
f0101a9e:	83 c4 10             	add    $0x10,%esp
f0101aa1:	85 c0                	test   %eax,%eax
f0101aa3:	74 19                	je     f0101abe <mem_init+0xa65>
f0101aa5:	68 e8 3f 10 f0       	push   $0xf0103fe8
f0101aaa:	68 92 44 10 f0       	push   $0xf0104492
f0101aaf:	68 10 03 00 00       	push   $0x310
f0101ab4:	68 6c 44 10 f0       	push   $0xf010446c
f0101ab9:	e8 cd e5 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101abe:	83 ec 04             	sub    $0x4,%esp
f0101ac1:	6a 00                	push   $0x0
f0101ac3:	68 00 10 00 00       	push   $0x1000
f0101ac8:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101ace:	e8 77 f3 ff ff       	call   f0100e4a <pgdir_walk>
f0101ad3:	83 c4 10             	add    $0x10,%esp
f0101ad6:	f6 00 02             	testb  $0x2,(%eax)
f0101ad9:	75 19                	jne    f0101af4 <mem_init+0xa9b>
f0101adb:	68 08 41 10 f0       	push   $0xf0104108
f0101ae0:	68 92 44 10 f0       	push   $0xf0104492
f0101ae5:	68 11 03 00 00       	push   $0x311
f0101aea:	68 6c 44 10 f0       	push   $0xf010446c
f0101aef:	e8 97 e5 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101af4:	83 ec 04             	sub    $0x4,%esp
f0101af7:	6a 00                	push   $0x0
f0101af9:	68 00 10 00 00       	push   $0x1000
f0101afe:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101b04:	e8 41 f3 ff ff       	call   f0100e4a <pgdir_walk>
f0101b09:	83 c4 10             	add    $0x10,%esp
f0101b0c:	f6 00 04             	testb  $0x4,(%eax)
f0101b0f:	74 19                	je     f0101b2a <mem_init+0xad1>
f0101b11:	68 3c 41 10 f0       	push   $0xf010413c
f0101b16:	68 92 44 10 f0       	push   $0xf0104492
f0101b1b:	68 12 03 00 00       	push   $0x312
f0101b20:	68 6c 44 10 f0       	push   $0xf010446c
f0101b25:	e8 61 e5 ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b2a:	6a 02                	push   $0x2
f0101b2c:	68 00 00 40 00       	push   $0x400000
f0101b31:	56                   	push   %esi
f0101b32:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101b38:	e8 b3 f4 ff ff       	call   f0100ff0 <page_insert>
f0101b3d:	83 c4 10             	add    $0x10,%esp
f0101b40:	85 c0                	test   %eax,%eax
f0101b42:	78 19                	js     f0101b5d <mem_init+0xb04>
f0101b44:	68 74 41 10 f0       	push   $0xf0104174
f0101b49:	68 92 44 10 f0       	push   $0xf0104492
f0101b4e:	68 15 03 00 00       	push   $0x315
f0101b53:	68 6c 44 10 f0       	push   $0xf010446c
f0101b58:	e8 2e e5 ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b5d:	6a 02                	push   $0x2
f0101b5f:	68 00 10 00 00       	push   $0x1000
f0101b64:	57                   	push   %edi
f0101b65:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101b6b:	e8 80 f4 ff ff       	call   f0100ff0 <page_insert>
f0101b70:	83 c4 10             	add    $0x10,%esp
f0101b73:	85 c0                	test   %eax,%eax
f0101b75:	74 19                	je     f0101b90 <mem_init+0xb37>
f0101b77:	68 ac 41 10 f0       	push   $0xf01041ac
f0101b7c:	68 92 44 10 f0       	push   $0xf0104492
f0101b81:	68 18 03 00 00       	push   $0x318
f0101b86:	68 6c 44 10 f0       	push   $0xf010446c
f0101b8b:	e8 fb e4 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b90:	83 ec 04             	sub    $0x4,%esp
f0101b93:	6a 00                	push   $0x0
f0101b95:	68 00 10 00 00       	push   $0x1000
f0101b9a:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101ba0:	e8 a5 f2 ff ff       	call   f0100e4a <pgdir_walk>
f0101ba5:	83 c4 10             	add    $0x10,%esp
f0101ba8:	f6 00 04             	testb  $0x4,(%eax)
f0101bab:	74 19                	je     f0101bc6 <mem_init+0xb6d>
f0101bad:	68 3c 41 10 f0       	push   $0xf010413c
f0101bb2:	68 92 44 10 f0       	push   $0xf0104492
f0101bb7:	68 19 03 00 00       	push   $0x319
f0101bbc:	68 6c 44 10 f0       	push   $0xf010446c
f0101bc1:	e8 c5 e4 ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bc6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bcb:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101bd0:	e8 de ed ff ff       	call   f01009b3 <check_va2pa>
f0101bd5:	89 fa                	mov    %edi,%edx
f0101bd7:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101bdd:	c1 fa 03             	sar    $0x3,%edx
f0101be0:	c1 e2 0c             	shl    $0xc,%edx
f0101be3:	39 d0                	cmp    %edx,%eax
f0101be5:	74 19                	je     f0101c00 <mem_init+0xba7>
f0101be7:	68 e8 41 10 f0       	push   $0xf01041e8
f0101bec:	68 92 44 10 f0       	push   $0xf0104492
f0101bf1:	68 1c 03 00 00       	push   $0x31c
f0101bf6:	68 6c 44 10 f0       	push   $0xf010446c
f0101bfb:	e8 8b e4 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c00:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c05:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101c0a:	e8 a4 ed ff ff       	call   f01009b3 <check_va2pa>
f0101c0f:	89 fa                	mov    %edi,%edx
f0101c11:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101c17:	c1 fa 03             	sar    $0x3,%edx
f0101c1a:	c1 e2 0c             	shl    $0xc,%edx
f0101c1d:	39 d0                	cmp    %edx,%eax
f0101c1f:	74 19                	je     f0101c3a <mem_init+0xbe1>
f0101c21:	68 14 42 10 f0       	push   $0xf0104214
f0101c26:	68 92 44 10 f0       	push   $0xf0104492
f0101c2b:	68 1d 03 00 00       	push   $0x31d
f0101c30:	68 6c 44 10 f0       	push   $0xf010446c
f0101c35:	e8 51 e4 ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c3a:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101c3f:	74 19                	je     f0101c5a <mem_init+0xc01>
f0101c41:	68 83 46 10 f0       	push   $0xf0104683
f0101c46:	68 92 44 10 f0       	push   $0xf0104492
f0101c4b:	68 1f 03 00 00       	push   $0x31f
f0101c50:	68 6c 44 10 f0       	push   $0xf010446c
f0101c55:	e8 31 e4 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101c5a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c5f:	74 19                	je     f0101c7a <mem_init+0xc21>
f0101c61:	68 94 46 10 f0       	push   $0xf0104694
f0101c66:	68 92 44 10 f0       	push   $0xf0104492
f0101c6b:	68 20 03 00 00       	push   $0x320
f0101c70:	68 6c 44 10 f0       	push   $0xf010446c
f0101c75:	e8 11 e4 ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c7a:	83 ec 0c             	sub    $0xc,%esp
f0101c7d:	6a 00                	push   $0x0
f0101c7f:	e8 1e f1 ff ff       	call   f0100da2 <page_alloc>
f0101c84:	83 c4 10             	add    $0x10,%esp
f0101c87:	85 c0                	test   %eax,%eax
f0101c89:	74 04                	je     f0101c8f <mem_init+0xc36>
f0101c8b:	39 c3                	cmp    %eax,%ebx
f0101c8d:	74 19                	je     f0101ca8 <mem_init+0xc4f>
f0101c8f:	68 44 42 10 f0       	push   $0xf0104244
f0101c94:	68 92 44 10 f0       	push   $0xf0104492
f0101c99:	68 23 03 00 00       	push   $0x323
f0101c9e:	68 6c 44 10 f0       	push   $0xf010446c
f0101ca3:	e8 e3 e3 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ca8:	83 ec 08             	sub    $0x8,%esp
f0101cab:	6a 00                	push   $0x0
f0101cad:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101cb3:	e8 eb f2 ff ff       	call   f0100fa3 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cb8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cbd:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101cc2:	e8 ec ec ff ff       	call   f01009b3 <check_va2pa>
f0101cc7:	83 c4 10             	add    $0x10,%esp
f0101cca:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ccd:	74 19                	je     f0101ce8 <mem_init+0xc8f>
f0101ccf:	68 68 42 10 f0       	push   $0xf0104268
f0101cd4:	68 92 44 10 f0       	push   $0xf0104492
f0101cd9:	68 27 03 00 00       	push   $0x327
f0101cde:	68 6c 44 10 f0       	push   $0xf010446c
f0101ce3:	e8 a3 e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ce8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ced:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101cf2:	e8 bc ec ff ff       	call   f01009b3 <check_va2pa>
f0101cf7:	89 fa                	mov    %edi,%edx
f0101cf9:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101cff:	c1 fa 03             	sar    $0x3,%edx
f0101d02:	c1 e2 0c             	shl    $0xc,%edx
f0101d05:	39 d0                	cmp    %edx,%eax
f0101d07:	74 19                	je     f0101d22 <mem_init+0xcc9>
f0101d09:	68 14 42 10 f0       	push   $0xf0104214
f0101d0e:	68 92 44 10 f0       	push   $0xf0104492
f0101d13:	68 28 03 00 00       	push   $0x328
f0101d18:	68 6c 44 10 f0       	push   $0xf010446c
f0101d1d:	e8 69 e3 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101d22:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d27:	74 19                	je     f0101d42 <mem_init+0xce9>
f0101d29:	68 3a 46 10 f0       	push   $0xf010463a
f0101d2e:	68 92 44 10 f0       	push   $0xf0104492
f0101d33:	68 29 03 00 00       	push   $0x329
f0101d38:	68 6c 44 10 f0       	push   $0xf010446c
f0101d3d:	e8 49 e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101d42:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d47:	74 19                	je     f0101d62 <mem_init+0xd09>
f0101d49:	68 94 46 10 f0       	push   $0xf0104694
f0101d4e:	68 92 44 10 f0       	push   $0xf0104492
f0101d53:	68 2a 03 00 00       	push   $0x32a
f0101d58:	68 6c 44 10 f0       	push   $0xf010446c
f0101d5d:	e8 29 e3 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d62:	83 ec 08             	sub    $0x8,%esp
f0101d65:	68 00 10 00 00       	push   $0x1000
f0101d6a:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101d70:	e8 2e f2 ff ff       	call   f0100fa3 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d75:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d7a:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101d7f:	e8 2f ec ff ff       	call   f01009b3 <check_va2pa>
f0101d84:	83 c4 10             	add    $0x10,%esp
f0101d87:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d8a:	74 19                	je     f0101da5 <mem_init+0xd4c>
f0101d8c:	68 68 42 10 f0       	push   $0xf0104268
f0101d91:	68 92 44 10 f0       	push   $0xf0104492
f0101d96:	68 2e 03 00 00       	push   $0x32e
f0101d9b:	68 6c 44 10 f0       	push   $0xf010446c
f0101da0:	e8 e6 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101da5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101daa:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101daf:	e8 ff eb ff ff       	call   f01009b3 <check_va2pa>
f0101db4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101db7:	74 19                	je     f0101dd2 <mem_init+0xd79>
f0101db9:	68 8c 42 10 f0       	push   $0xf010428c
f0101dbe:	68 92 44 10 f0       	push   $0xf0104492
f0101dc3:	68 2f 03 00 00       	push   $0x32f
f0101dc8:	68 6c 44 10 f0       	push   $0xf010446c
f0101dcd:	e8 b9 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0101dd2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101dd7:	74 19                	je     f0101df2 <mem_init+0xd99>
f0101dd9:	68 a5 46 10 f0       	push   $0xf01046a5
f0101dde:	68 92 44 10 f0       	push   $0xf0104492
f0101de3:	68 30 03 00 00       	push   $0x330
f0101de8:	68 6c 44 10 f0       	push   $0xf010446c
f0101ded:	e8 99 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101df2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101df7:	74 19                	je     f0101e12 <mem_init+0xdb9>
f0101df9:	68 94 46 10 f0       	push   $0xf0104694
f0101dfe:	68 92 44 10 f0       	push   $0xf0104492
f0101e03:	68 31 03 00 00       	push   $0x331
f0101e08:	68 6c 44 10 f0       	push   $0xf010446c
f0101e0d:	e8 79 e2 ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e12:	83 ec 0c             	sub    $0xc,%esp
f0101e15:	6a 00                	push   $0x0
f0101e17:	e8 86 ef ff ff       	call   f0100da2 <page_alloc>
f0101e1c:	83 c4 10             	add    $0x10,%esp
f0101e1f:	85 c0                	test   %eax,%eax
f0101e21:	74 04                	je     f0101e27 <mem_init+0xdce>
f0101e23:	39 c7                	cmp    %eax,%edi
f0101e25:	74 19                	je     f0101e40 <mem_init+0xde7>
f0101e27:	68 b4 42 10 f0       	push   $0xf01042b4
f0101e2c:	68 92 44 10 f0       	push   $0xf0104492
f0101e31:	68 34 03 00 00       	push   $0x334
f0101e36:	68 6c 44 10 f0       	push   $0xf010446c
f0101e3b:	e8 4b e2 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e40:	83 ec 0c             	sub    $0xc,%esp
f0101e43:	6a 00                	push   $0x0
f0101e45:	e8 58 ef ff ff       	call   f0100da2 <page_alloc>
f0101e4a:	83 c4 10             	add    $0x10,%esp
f0101e4d:	85 c0                	test   %eax,%eax
f0101e4f:	74 19                	je     f0101e6a <mem_init+0xe11>
f0101e51:	68 e8 45 10 f0       	push   $0xf01045e8
f0101e56:	68 92 44 10 f0       	push   $0xf0104492
f0101e5b:	68 37 03 00 00       	push   $0x337
f0101e60:	68 6c 44 10 f0       	push   $0xf010446c
f0101e65:	e8 21 e2 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e6a:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101e6f:	8b 08                	mov    (%eax),%ecx
f0101e71:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101e77:	89 f2                	mov    %esi,%edx
f0101e79:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101e7f:	c1 fa 03             	sar    $0x3,%edx
f0101e82:	c1 e2 0c             	shl    $0xc,%edx
f0101e85:	39 d1                	cmp    %edx,%ecx
f0101e87:	74 19                	je     f0101ea2 <mem_init+0xe49>
f0101e89:	68 90 3f 10 f0       	push   $0xf0103f90
f0101e8e:	68 92 44 10 f0       	push   $0xf0104492
f0101e93:	68 3a 03 00 00       	push   $0x33a
f0101e98:	68 6c 44 10 f0       	push   $0xf010446c
f0101e9d:	e8 e9 e1 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0101ea2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0101ea8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ead:	74 19                	je     f0101ec8 <mem_init+0xe6f>
f0101eaf:	68 4b 46 10 f0       	push   $0xf010464b
f0101eb4:	68 92 44 10 f0       	push   $0xf0104492
f0101eb9:	68 3c 03 00 00       	push   $0x33c
f0101ebe:	68 6c 44 10 f0       	push   $0xf010446c
f0101ec3:	e8 c3 e1 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0101ec8:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101ece:	83 ec 0c             	sub    $0xc,%esp
f0101ed1:	56                   	push   %esi
f0101ed2:	e8 35 ef ff ff       	call   f0100e0c <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101ed7:	83 c4 0c             	add    $0xc,%esp
f0101eda:	6a 01                	push   $0x1
f0101edc:	68 00 10 40 00       	push   $0x401000
f0101ee1:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101ee7:	e8 5e ef ff ff       	call   f0100e4a <pgdir_walk>
f0101eec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101eef:	8b 0d 48 d9 11 f0    	mov    0xf011d948,%ecx
f0101ef5:	8b 51 04             	mov    0x4(%ecx),%edx
f0101ef8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101efe:	89 55 c4             	mov    %edx,-0x3c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f01:	c1 ea 0c             	shr    $0xc,%edx
f0101f04:	83 c4 10             	add    $0x10,%esp
f0101f07:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f0101f0d:	72 17                	jb     f0101f26 <mem_init+0xecd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f0f:	ff 75 c4             	pushl  -0x3c(%ebp)
f0101f12:	68 50 3d 10 f0       	push   $0xf0103d50
f0101f17:	68 43 03 00 00       	push   $0x343
f0101f1c:	68 6c 44 10 f0       	push   $0xf010446c
f0101f21:	e8 65 e1 ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f0101f26:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101f29:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101f2f:	39 d0                	cmp    %edx,%eax
f0101f31:	74 19                	je     f0101f4c <mem_init+0xef3>
f0101f33:	68 b6 46 10 f0       	push   $0xf01046b6
f0101f38:	68 92 44 10 f0       	push   $0xf0104492
f0101f3d:	68 44 03 00 00       	push   $0x344
f0101f42:	68 6c 44 10 f0       	push   $0xf010446c
f0101f47:	e8 3f e1 ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f0101f4c:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101f53:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f59:	89 f0                	mov    %esi,%eax
f0101f5b:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
f0101f61:	c1 f8 03             	sar    $0x3,%eax
f0101f64:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f67:	89 c2                	mov    %eax,%edx
f0101f69:	c1 ea 0c             	shr    $0xc,%edx
f0101f6c:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f0101f72:	72 12                	jb     f0101f86 <mem_init+0xf2d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f74:	50                   	push   %eax
f0101f75:	68 50 3d 10 f0       	push   $0xf0103d50
f0101f7a:	6a 52                	push   $0x52
f0101f7c:	68 78 44 10 f0       	push   $0xf0104478
f0101f81:	e8 05 e1 ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101f86:	83 ec 04             	sub    $0x4,%esp
f0101f89:	68 00 10 00 00       	push   $0x1000
f0101f8e:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101f93:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f98:	50                   	push   %eax
f0101f99:	e8 57 12 00 00       	call   f01031f5 <memset>
	page_free(pp0);
f0101f9e:	89 34 24             	mov    %esi,(%esp)
f0101fa1:	e8 66 ee ff ff       	call   f0100e0c <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101fa6:	83 c4 0c             	add    $0xc,%esp
f0101fa9:	6a 01                	push   $0x1
f0101fab:	6a 00                	push   $0x0
f0101fad:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101fb3:	e8 92 ee ff ff       	call   f0100e4a <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fb8:	89 f2                	mov    %esi,%edx
f0101fba:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101fc0:	c1 fa 03             	sar    $0x3,%edx
f0101fc3:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fc6:	89 d0                	mov    %edx,%eax
f0101fc8:	c1 e8 0c             	shr    $0xc,%eax
f0101fcb:	83 c4 10             	add    $0x10,%esp
f0101fce:	3b 05 44 d9 11 f0    	cmp    0xf011d944,%eax
f0101fd4:	72 12                	jb     f0101fe8 <mem_init+0xf8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fd6:	52                   	push   %edx
f0101fd7:	68 50 3d 10 f0       	push   $0xf0103d50
f0101fdc:	6a 52                	push   $0x52
f0101fde:	68 78 44 10 f0       	push   $0xf0104478
f0101fe3:	e8 a3 e0 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101fe8:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101fee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101ff1:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0101ff8:	75 11                	jne    f010200b <mem_init+0xfb2>
f0101ffa:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102000:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102006:	f6 00 01             	testb  $0x1,(%eax)
f0102009:	74 19                	je     f0102024 <mem_init+0xfcb>
f010200b:	68 ce 46 10 f0       	push   $0xf01046ce
f0102010:	68 92 44 10 f0       	push   $0xf0104492
f0102015:	68 4e 03 00 00       	push   $0x34e
f010201a:	68 6c 44 10 f0       	push   $0xf010446c
f010201f:	e8 67 e0 ff ff       	call   f010008b <_panic>
f0102024:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102027:	39 d0                	cmp    %edx,%eax
f0102029:	75 db                	jne    f0102006 <mem_init+0xfad>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010202b:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0102030:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102036:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f010203c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010203f:	a3 2c d5 11 f0       	mov    %eax,0xf011d52c

	// free the pages we took
	page_free(pp0);
f0102044:	83 ec 0c             	sub    $0xc,%esp
f0102047:	56                   	push   %esi
f0102048:	e8 bf ed ff ff       	call   f0100e0c <page_free>
	page_free(pp1);
f010204d:	89 3c 24             	mov    %edi,(%esp)
f0102050:	e8 b7 ed ff ff       	call   f0100e0c <page_free>
	page_free(pp2);
f0102055:	89 1c 24             	mov    %ebx,(%esp)
f0102058:	e8 af ed ff ff       	call   f0100e0c <page_free>

	cprintf("check_page() succeeded!\n");
f010205d:	c7 04 24 e5 46 10 f0 	movl   $0xf01046e5,(%esp)
f0102064:	e8 5c 06 00 00       	call   f01026c5 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102069:	a1 4c d9 11 f0       	mov    0xf011d94c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010206e:	83 c4 10             	add    $0x10,%esp
f0102071:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102076:	77 15                	ja     f010208d <mem_init+0x1034>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102078:	50                   	push   %eax
f0102079:	68 38 3e 10 f0       	push   $0xf0103e38
f010207e:	68 b1 00 00 00       	push   $0xb1
f0102083:	68 6c 44 10 f0       	push   $0xf010446c
f0102088:	e8 fe df ff ff       	call   f010008b <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f010208d:	8b 15 44 d9 11 f0    	mov    0xf011d944,%edx
f0102093:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f010209a:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f010209d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01020a3:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01020a5:	05 00 00 00 10       	add    $0x10000000,%eax
f01020aa:	50                   	push   %eax
f01020ab:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020b0:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f01020b5:	e8 27 ee ff ff       	call   f0100ee1 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01020ba:	83 c4 10             	add    $0x10,%esp
f01020bd:	ba 00 30 11 f0       	mov    $0xf0113000,%edx
f01020c2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01020c8:	77 15                	ja     f01020df <mem_init+0x1086>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01020ca:	52                   	push   %edx
f01020cb:	68 38 3e 10 f0       	push   $0xf0103e38
f01020d0:	68 c2 00 00 00       	push   $0xc2
f01020d5:	68 6c 44 10 f0       	push   $0xf010446c
f01020da:	e8 ac df ff ff       	call   f010008b <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f01020df:	83 ec 08             	sub    $0x8,%esp
f01020e2:	6a 02                	push   $0x2
f01020e4:	68 00 30 11 00       	push   $0x113000
f01020e9:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020ee:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020f3:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f01020f8:	e8 e4 ed ff ff       	call   f0100ee1 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f01020fd:	83 c4 08             	add    $0x8,%esp
f0102100:	6a 02                	push   $0x2
f0102102:	6a 00                	push   $0x0
f0102104:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102109:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010210e:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0102113:	e8 c9 ed ff ff       	call   f0100ee1 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102118:	8b 1d 48 d9 11 f0    	mov    0xf011d948,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010211e:	a1 44 d9 11 f0       	mov    0xf011d944,%eax
f0102123:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f010212a:	83 c4 10             	add    $0x10,%esp
f010212d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102133:	74 63                	je     f0102198 <mem_init+0x113f>
f0102135:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010213a:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102140:	89 d8                	mov    %ebx,%eax
f0102142:	e8 6c e8 ff ff       	call   f01009b3 <check_va2pa>
f0102147:	8b 15 4c d9 11 f0    	mov    0xf011d94c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010214d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102153:	77 15                	ja     f010216a <mem_init+0x1111>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102155:	52                   	push   %edx
f0102156:	68 38 3e 10 f0       	push   $0xf0103e38
f010215b:	68 95 02 00 00       	push   $0x295
f0102160:	68 6c 44 10 f0       	push   $0xf010446c
f0102165:	e8 21 df ff ff       	call   f010008b <_panic>
f010216a:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102171:	39 d0                	cmp    %edx,%eax
f0102173:	74 19                	je     f010218e <mem_init+0x1135>
f0102175:	68 d8 42 10 f0       	push   $0xf01042d8
f010217a:	68 92 44 10 f0       	push   $0xf0104492
f010217f:	68 95 02 00 00       	push   $0x295
f0102184:	68 6c 44 10 f0       	push   $0xf010446c
f0102189:	e8 fd de ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010218e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102194:	39 f7                	cmp    %esi,%edi
f0102196:	77 a2                	ja     f010213a <mem_init+0x10e1>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102198:	a1 44 d9 11 f0       	mov    0xf011d944,%eax
f010219d:	c1 e0 0c             	shl    $0xc,%eax
f01021a0:	74 41                	je     f01021e3 <mem_init+0x118a>
f01021a2:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01021a7:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f01021ad:	89 d8                	mov    %ebx,%eax
f01021af:	e8 ff e7 ff ff       	call   f01009b3 <check_va2pa>
f01021b4:	39 c6                	cmp    %eax,%esi
f01021b6:	74 19                	je     f01021d1 <mem_init+0x1178>
f01021b8:	68 0c 43 10 f0       	push   $0xf010430c
f01021bd:	68 92 44 10 f0       	push   $0xf0104492
f01021c2:	68 9a 02 00 00       	push   $0x29a
f01021c7:	68 6c 44 10 f0       	push   $0xf010446c
f01021cc:	e8 ba de ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01021d1:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01021d7:	a1 44 d9 11 f0       	mov    0xf011d944,%eax
f01021dc:	c1 e0 0c             	shl    $0xc,%eax
f01021df:	39 c6                	cmp    %eax,%esi
f01021e1:	72 c4                	jb     f01021a7 <mem_init+0x114e>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01021e3:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01021e8:	89 d8                	mov    %ebx,%eax
f01021ea:	e8 c4 e7 ff ff       	call   f01009b3 <check_va2pa>
f01021ef:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01021f4:	bf 00 30 11 f0       	mov    $0xf0113000,%edi
f01021f9:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01021ff:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102202:	39 d0                	cmp    %edx,%eax
f0102204:	74 19                	je     f010221f <mem_init+0x11c6>
f0102206:	68 34 43 10 f0       	push   $0xf0104334
f010220b:	68 92 44 10 f0       	push   $0xf0104492
f0102210:	68 9e 02 00 00       	push   $0x29e
f0102215:	68 6c 44 10 f0       	push   $0xf010446c
f010221a:	e8 6c de ff ff       	call   f010008b <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010221f:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102225:	0f 85 25 04 00 00    	jne    f0102650 <mem_init+0x15f7>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010222b:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102230:	89 d8                	mov    %ebx,%eax
f0102232:	e8 7c e7 ff ff       	call   f01009b3 <check_va2pa>
f0102237:	83 f8 ff             	cmp    $0xffffffff,%eax
f010223a:	74 19                	je     f0102255 <mem_init+0x11fc>
f010223c:	68 7c 43 10 f0       	push   $0xf010437c
f0102241:	68 92 44 10 f0       	push   $0xf0104492
f0102246:	68 9f 02 00 00       	push   $0x29f
f010224b:	68 6c 44 10 f0       	push   $0xf010446c
f0102250:	e8 36 de ff ff       	call   f010008b <_panic>
f0102255:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010225a:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f010225f:	72 2d                	jb     f010228e <mem_init+0x1235>
f0102261:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102266:	76 07                	jbe    f010226f <mem_init+0x1216>
f0102268:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010226d:	75 1f                	jne    f010228e <mem_init+0x1235>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f010226f:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102273:	75 7e                	jne    f01022f3 <mem_init+0x129a>
f0102275:	68 fe 46 10 f0       	push   $0xf01046fe
f010227a:	68 92 44 10 f0       	push   $0xf0104492
f010227f:	68 a7 02 00 00       	push   $0x2a7
f0102284:	68 6c 44 10 f0       	push   $0xf010446c
f0102289:	e8 fd dd ff ff       	call   f010008b <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010228e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102293:	76 3f                	jbe    f01022d4 <mem_init+0x127b>
				assert(pgdir[i] & PTE_P);
f0102295:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102298:	f6 c2 01             	test   $0x1,%dl
f010229b:	75 19                	jne    f01022b6 <mem_init+0x125d>
f010229d:	68 fe 46 10 f0       	push   $0xf01046fe
f01022a2:	68 92 44 10 f0       	push   $0xf0104492
f01022a7:	68 ab 02 00 00       	push   $0x2ab
f01022ac:	68 6c 44 10 f0       	push   $0xf010446c
f01022b1:	e8 d5 dd ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f01022b6:	f6 c2 02             	test   $0x2,%dl
f01022b9:	75 38                	jne    f01022f3 <mem_init+0x129a>
f01022bb:	68 0f 47 10 f0       	push   $0xf010470f
f01022c0:	68 92 44 10 f0       	push   $0xf0104492
f01022c5:	68 ac 02 00 00       	push   $0x2ac
f01022ca:	68 6c 44 10 f0       	push   $0xf010446c
f01022cf:	e8 b7 dd ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f01022d4:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01022d8:	74 19                	je     f01022f3 <mem_init+0x129a>
f01022da:	68 20 47 10 f0       	push   $0xf0104720
f01022df:	68 92 44 10 f0       	push   $0xf0104492
f01022e4:	68 ae 02 00 00       	push   $0x2ae
f01022e9:	68 6c 44 10 f0       	push   $0xf010446c
f01022ee:	e8 98 dd ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01022f3:	40                   	inc    %eax
f01022f4:	3d 00 04 00 00       	cmp    $0x400,%eax
f01022f9:	0f 85 5b ff ff ff    	jne    f010225a <mem_init+0x1201>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01022ff:	83 ec 0c             	sub    $0xc,%esp
f0102302:	68 ac 43 10 f0       	push   $0xf01043ac
f0102307:	e8 b9 03 00 00       	call   f01026c5 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010230c:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102311:	83 c4 10             	add    $0x10,%esp
f0102314:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102319:	77 15                	ja     f0102330 <mem_init+0x12d7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010231b:	50                   	push   %eax
f010231c:	68 38 3e 10 f0       	push   $0xf0103e38
f0102321:	68 de 00 00 00       	push   $0xde
f0102326:	68 6c 44 10 f0       	push   $0xf010446c
f010232b:	e8 5b dd ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102330:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102335:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102338:	b8 00 00 00 00       	mov    $0x0,%eax
f010233d:	e8 fa e6 ff ff       	call   f0100a3c <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102342:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102345:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010234a:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010234d:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102350:	83 ec 0c             	sub    $0xc,%esp
f0102353:	6a 00                	push   $0x0
f0102355:	e8 48 ea ff ff       	call   f0100da2 <page_alloc>
f010235a:	89 c6                	mov    %eax,%esi
f010235c:	83 c4 10             	add    $0x10,%esp
f010235f:	85 c0                	test   %eax,%eax
f0102361:	75 19                	jne    f010237c <mem_init+0x1323>
f0102363:	68 3d 45 10 f0       	push   $0xf010453d
f0102368:	68 92 44 10 f0       	push   $0xf0104492
f010236d:	68 69 03 00 00       	push   $0x369
f0102372:	68 6c 44 10 f0       	push   $0xf010446c
f0102377:	e8 0f dd ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010237c:	83 ec 0c             	sub    $0xc,%esp
f010237f:	6a 00                	push   $0x0
f0102381:	e8 1c ea ff ff       	call   f0100da2 <page_alloc>
f0102386:	89 c7                	mov    %eax,%edi
f0102388:	83 c4 10             	add    $0x10,%esp
f010238b:	85 c0                	test   %eax,%eax
f010238d:	75 19                	jne    f01023a8 <mem_init+0x134f>
f010238f:	68 53 45 10 f0       	push   $0xf0104553
f0102394:	68 92 44 10 f0       	push   $0xf0104492
f0102399:	68 6a 03 00 00       	push   $0x36a
f010239e:	68 6c 44 10 f0       	push   $0xf010446c
f01023a3:	e8 e3 dc ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01023a8:	83 ec 0c             	sub    $0xc,%esp
f01023ab:	6a 00                	push   $0x0
f01023ad:	e8 f0 e9 ff ff       	call   f0100da2 <page_alloc>
f01023b2:	89 c3                	mov    %eax,%ebx
f01023b4:	83 c4 10             	add    $0x10,%esp
f01023b7:	85 c0                	test   %eax,%eax
f01023b9:	75 19                	jne    f01023d4 <mem_init+0x137b>
f01023bb:	68 69 45 10 f0       	push   $0xf0104569
f01023c0:	68 92 44 10 f0       	push   $0xf0104492
f01023c5:	68 6b 03 00 00       	push   $0x36b
f01023ca:	68 6c 44 10 f0       	push   $0xf010446c
f01023cf:	e8 b7 dc ff ff       	call   f010008b <_panic>
	page_free(pp0);
f01023d4:	83 ec 0c             	sub    $0xc,%esp
f01023d7:	56                   	push   %esi
f01023d8:	e8 2f ea ff ff       	call   f0100e0c <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023dd:	89 f8                	mov    %edi,%eax
f01023df:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
f01023e5:	c1 f8 03             	sar    $0x3,%eax
f01023e8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023eb:	89 c2                	mov    %eax,%edx
f01023ed:	c1 ea 0c             	shr    $0xc,%edx
f01023f0:	83 c4 10             	add    $0x10,%esp
f01023f3:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f01023f9:	72 12                	jb     f010240d <mem_init+0x13b4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023fb:	50                   	push   %eax
f01023fc:	68 50 3d 10 f0       	push   $0xf0103d50
f0102401:	6a 52                	push   $0x52
f0102403:	68 78 44 10 f0       	push   $0xf0104478
f0102408:	e8 7e dc ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010240d:	83 ec 04             	sub    $0x4,%esp
f0102410:	68 00 10 00 00       	push   $0x1000
f0102415:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102417:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010241c:	50                   	push   %eax
f010241d:	e8 d3 0d 00 00       	call   f01031f5 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102422:	89 d8                	mov    %ebx,%eax
f0102424:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
f010242a:	c1 f8 03             	sar    $0x3,%eax
f010242d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102430:	89 c2                	mov    %eax,%edx
f0102432:	c1 ea 0c             	shr    $0xc,%edx
f0102435:	83 c4 10             	add    $0x10,%esp
f0102438:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f010243e:	72 12                	jb     f0102452 <mem_init+0x13f9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102440:	50                   	push   %eax
f0102441:	68 50 3d 10 f0       	push   $0xf0103d50
f0102446:	6a 52                	push   $0x52
f0102448:	68 78 44 10 f0       	push   $0xf0104478
f010244d:	e8 39 dc ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102452:	83 ec 04             	sub    $0x4,%esp
f0102455:	68 00 10 00 00       	push   $0x1000
f010245a:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f010245c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102461:	50                   	push   %eax
f0102462:	e8 8e 0d 00 00       	call   f01031f5 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102467:	6a 02                	push   $0x2
f0102469:	68 00 10 00 00       	push   $0x1000
f010246e:	57                   	push   %edi
f010246f:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0102475:	e8 76 eb ff ff       	call   f0100ff0 <page_insert>
	assert(pp1->pp_ref == 1);
f010247a:	83 c4 20             	add    $0x20,%esp
f010247d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102482:	74 19                	je     f010249d <mem_init+0x1444>
f0102484:	68 3a 46 10 f0       	push   $0xf010463a
f0102489:	68 92 44 10 f0       	push   $0xf0104492
f010248e:	68 70 03 00 00       	push   $0x370
f0102493:	68 6c 44 10 f0       	push   $0xf010446c
f0102498:	e8 ee db ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010249d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01024a4:	01 01 01 
f01024a7:	74 19                	je     f01024c2 <mem_init+0x1469>
f01024a9:	68 cc 43 10 f0       	push   $0xf01043cc
f01024ae:	68 92 44 10 f0       	push   $0xf0104492
f01024b3:	68 71 03 00 00       	push   $0x371
f01024b8:	68 6c 44 10 f0       	push   $0xf010446c
f01024bd:	e8 c9 db ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01024c2:	6a 02                	push   $0x2
f01024c4:	68 00 10 00 00       	push   $0x1000
f01024c9:	53                   	push   %ebx
f01024ca:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f01024d0:	e8 1b eb ff ff       	call   f0100ff0 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01024d5:	83 c4 10             	add    $0x10,%esp
f01024d8:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01024df:	02 02 02 
f01024e2:	74 19                	je     f01024fd <mem_init+0x14a4>
f01024e4:	68 f0 43 10 f0       	push   $0xf01043f0
f01024e9:	68 92 44 10 f0       	push   $0xf0104492
f01024ee:	68 73 03 00 00       	push   $0x373
f01024f3:	68 6c 44 10 f0       	push   $0xf010446c
f01024f8:	e8 8e db ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01024fd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102502:	74 19                	je     f010251d <mem_init+0x14c4>
f0102504:	68 5c 46 10 f0       	push   $0xf010465c
f0102509:	68 92 44 10 f0       	push   $0xf0104492
f010250e:	68 74 03 00 00       	push   $0x374
f0102513:	68 6c 44 10 f0       	push   $0xf010446c
f0102518:	e8 6e db ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f010251d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102522:	74 19                	je     f010253d <mem_init+0x14e4>
f0102524:	68 a5 46 10 f0       	push   $0xf01046a5
f0102529:	68 92 44 10 f0       	push   $0xf0104492
f010252e:	68 75 03 00 00       	push   $0x375
f0102533:	68 6c 44 10 f0       	push   $0xf010446c
f0102538:	e8 4e db ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010253d:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102544:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102547:	89 d8                	mov    %ebx,%eax
f0102549:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
f010254f:	c1 f8 03             	sar    $0x3,%eax
f0102552:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102555:	89 c2                	mov    %eax,%edx
f0102557:	c1 ea 0c             	shr    $0xc,%edx
f010255a:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f0102560:	72 12                	jb     f0102574 <mem_init+0x151b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102562:	50                   	push   %eax
f0102563:	68 50 3d 10 f0       	push   $0xf0103d50
f0102568:	6a 52                	push   $0x52
f010256a:	68 78 44 10 f0       	push   $0xf0104478
f010256f:	e8 17 db ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102574:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010257b:	03 03 03 
f010257e:	74 19                	je     f0102599 <mem_init+0x1540>
f0102580:	68 14 44 10 f0       	push   $0xf0104414
f0102585:	68 92 44 10 f0       	push   $0xf0104492
f010258a:	68 77 03 00 00       	push   $0x377
f010258f:	68 6c 44 10 f0       	push   $0xf010446c
f0102594:	e8 f2 da ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102599:	83 ec 08             	sub    $0x8,%esp
f010259c:	68 00 10 00 00       	push   $0x1000
f01025a1:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f01025a7:	e8 f7 e9 ff ff       	call   f0100fa3 <page_remove>
	assert(pp2->pp_ref == 0);
f01025ac:	83 c4 10             	add    $0x10,%esp
f01025af:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025b4:	74 19                	je     f01025cf <mem_init+0x1576>
f01025b6:	68 94 46 10 f0       	push   $0xf0104694
f01025bb:	68 92 44 10 f0       	push   $0xf0104492
f01025c0:	68 79 03 00 00       	push   $0x379
f01025c5:	68 6c 44 10 f0       	push   $0xf010446c
f01025ca:	e8 bc da ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025cf:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f01025d4:	8b 08                	mov    (%eax),%ecx
f01025d6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025dc:	89 f2                	mov    %esi,%edx
f01025de:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f01025e4:	c1 fa 03             	sar    $0x3,%edx
f01025e7:	c1 e2 0c             	shl    $0xc,%edx
f01025ea:	39 d1                	cmp    %edx,%ecx
f01025ec:	74 19                	je     f0102607 <mem_init+0x15ae>
f01025ee:	68 90 3f 10 f0       	push   $0xf0103f90
f01025f3:	68 92 44 10 f0       	push   $0xf0104492
f01025f8:	68 7c 03 00 00       	push   $0x37c
f01025fd:	68 6c 44 10 f0       	push   $0xf010446c
f0102602:	e8 84 da ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102607:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010260d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102612:	74 19                	je     f010262d <mem_init+0x15d4>
f0102614:	68 4b 46 10 f0       	push   $0xf010464b
f0102619:	68 92 44 10 f0       	push   $0xf0104492
f010261e:	68 7e 03 00 00       	push   $0x37e
f0102623:	68 6c 44 10 f0       	push   $0xf010446c
f0102628:	e8 5e da ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f010262d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102633:	83 ec 0c             	sub    $0xc,%esp
f0102636:	56                   	push   %esi
f0102637:	e8 d0 e7 ff ff       	call   f0100e0c <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010263c:	c7 04 24 40 44 10 f0 	movl   $0xf0104440,(%esp)
f0102643:	e8 7d 00 00 00       	call   f01026c5 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102648:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010264b:	5b                   	pop    %ebx
f010264c:	5e                   	pop    %esi
f010264d:	5f                   	pop    %edi
f010264e:	c9                   	leave  
f010264f:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102650:	89 f2                	mov    %esi,%edx
f0102652:	89 d8                	mov    %ebx,%eax
f0102654:	e8 5a e3 ff ff       	call   f01009b3 <check_va2pa>
f0102659:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010265f:	e9 9b fb ff ff       	jmp    f01021ff <mem_init+0x11a6>

f0102664 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102664:	55                   	push   %ebp
f0102665:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102667:	ba 70 00 00 00       	mov    $0x70,%edx
f010266c:	8b 45 08             	mov    0x8(%ebp),%eax
f010266f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102670:	b2 71                	mov    $0x71,%dl
f0102672:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102673:	0f b6 c0             	movzbl %al,%eax
}
f0102676:	c9                   	leave  
f0102677:	c3                   	ret    

f0102678 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102678:	55                   	push   %ebp
f0102679:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010267b:	ba 70 00 00 00       	mov    $0x70,%edx
f0102680:	8b 45 08             	mov    0x8(%ebp),%eax
f0102683:	ee                   	out    %al,(%dx)
f0102684:	b2 71                	mov    $0x71,%dl
f0102686:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102689:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010268a:	c9                   	leave  
f010268b:	c3                   	ret    

f010268c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010268c:	55                   	push   %ebp
f010268d:	89 e5                	mov    %esp,%ebp
f010268f:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102692:	ff 75 08             	pushl  0x8(%ebp)
f0102695:	e8 0c df ff ff       	call   f01005a6 <cputchar>
f010269a:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f010269d:	c9                   	leave  
f010269e:	c3                   	ret    

f010269f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010269f:	55                   	push   %ebp
f01026a0:	89 e5                	mov    %esp,%ebp
f01026a2:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01026a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01026ac:	ff 75 0c             	pushl  0xc(%ebp)
f01026af:	ff 75 08             	pushl  0x8(%ebp)
f01026b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01026b5:	50                   	push   %eax
f01026b6:	68 8c 26 10 f0       	push   $0xf010268c
f01026bb:	e8 9d 04 00 00       	call   f0102b5d <vprintfmt>
	return cnt;
}
f01026c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01026c3:	c9                   	leave  
f01026c4:	c3                   	ret    

f01026c5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01026c5:	55                   	push   %ebp
f01026c6:	89 e5                	mov    %esp,%ebp
f01026c8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01026cb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01026ce:	50                   	push   %eax
f01026cf:	ff 75 08             	pushl  0x8(%ebp)
f01026d2:	e8 c8 ff ff ff       	call   f010269f <vcprintf>
	va_end(ap);

	return cnt;
}
f01026d7:	c9                   	leave  
f01026d8:	c3                   	ret    
f01026d9:	00 00                	add    %al,(%eax)
	...

f01026dc <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01026dc:	55                   	push   %ebp
f01026dd:	89 e5                	mov    %esp,%ebp
f01026df:	57                   	push   %edi
f01026e0:	56                   	push   %esi
f01026e1:	53                   	push   %ebx
f01026e2:	83 ec 14             	sub    $0x14,%esp
f01026e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01026e8:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01026eb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01026ee:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01026f1:	8b 1a                	mov    (%edx),%ebx
f01026f3:	8b 01                	mov    (%ecx),%eax
f01026f5:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f01026f8:	39 c3                	cmp    %eax,%ebx
f01026fa:	0f 8f 97 00 00 00    	jg     f0102797 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0102700:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102707:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010270a:	01 d8                	add    %ebx,%eax
f010270c:	89 c7                	mov    %eax,%edi
f010270e:	c1 ef 1f             	shr    $0x1f,%edi
f0102711:	01 c7                	add    %eax,%edi
f0102713:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102715:	39 df                	cmp    %ebx,%edi
f0102717:	7c 31                	jl     f010274a <stab_binsearch+0x6e>
f0102719:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010271c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010271f:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0102724:	39 f0                	cmp    %esi,%eax
f0102726:	0f 84 b3 00 00 00    	je     f01027df <stab_binsearch+0x103>
f010272c:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102730:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102734:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102736:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102737:	39 d8                	cmp    %ebx,%eax
f0102739:	7c 0f                	jl     f010274a <stab_binsearch+0x6e>
f010273b:	0f b6 0a             	movzbl (%edx),%ecx
f010273e:	83 ea 0c             	sub    $0xc,%edx
f0102741:	39 f1                	cmp    %esi,%ecx
f0102743:	75 f1                	jne    f0102736 <stab_binsearch+0x5a>
f0102745:	e9 97 00 00 00       	jmp    f01027e1 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010274a:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010274d:	eb 39                	jmp    f0102788 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010274f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102752:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0102754:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102757:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010275e:	eb 28                	jmp    f0102788 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102760:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102763:	76 12                	jbe    f0102777 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0102765:	48                   	dec    %eax
f0102766:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102769:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010276c:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010276e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102775:	eb 11                	jmp    f0102788 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102777:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010277a:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f010277c:	ff 45 0c             	incl   0xc(%ebp)
f010277f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102781:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102788:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f010278b:	0f 8d 76 ff ff ff    	jge    f0102707 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102791:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102795:	75 0d                	jne    f01027a4 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0102797:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010279a:	8b 03                	mov    (%ebx),%eax
f010279c:	48                   	dec    %eax
f010279d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01027a0:	89 02                	mov    %eax,(%edx)
f01027a2:	eb 55                	jmp    f01027f9 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01027a4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01027a7:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01027a9:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01027ac:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01027ae:	39 c1                	cmp    %eax,%ecx
f01027b0:	7d 26                	jge    f01027d8 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01027b2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01027b5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01027b8:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01027bd:	39 f2                	cmp    %esi,%edx
f01027bf:	74 17                	je     f01027d8 <stab_binsearch+0xfc>
f01027c1:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01027c5:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01027c9:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01027ca:	39 c1                	cmp    %eax,%ecx
f01027cc:	7d 0a                	jge    f01027d8 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01027ce:	0f b6 1a             	movzbl (%edx),%ebx
f01027d1:	83 ea 0c             	sub    $0xc,%edx
f01027d4:	39 f3                	cmp    %esi,%ebx
f01027d6:	75 f1                	jne    f01027c9 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f01027d8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01027db:	89 02                	mov    %eax,(%edx)
f01027dd:	eb 1a                	jmp    f01027f9 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01027df:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01027e1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01027e4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01027e7:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01027eb:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01027ee:	0f 82 5b ff ff ff    	jb     f010274f <stab_binsearch+0x73>
f01027f4:	e9 67 ff ff ff       	jmp    f0102760 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01027f9:	83 c4 14             	add    $0x14,%esp
f01027fc:	5b                   	pop    %ebx
f01027fd:	5e                   	pop    %esi
f01027fe:	5f                   	pop    %edi
f01027ff:	c9                   	leave  
f0102800:	c3                   	ret    

f0102801 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102801:	55                   	push   %ebp
f0102802:	89 e5                	mov    %esp,%ebp
f0102804:	57                   	push   %edi
f0102805:	56                   	push   %esi
f0102806:	53                   	push   %ebx
f0102807:	83 ec 2c             	sub    $0x2c,%esp
f010280a:	8b 75 08             	mov    0x8(%ebp),%esi
f010280d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102810:	c7 03 2e 47 10 f0    	movl   $0xf010472e,(%ebx)
	info->eip_line = 0;
f0102816:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010281d:	c7 43 08 2e 47 10 f0 	movl   $0xf010472e,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102824:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010282b:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010282e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102835:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010283b:	76 12                	jbe    f010284f <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010283d:	b8 1a 2d 11 f0       	mov    $0xf0112d1a,%eax
f0102842:	3d b1 b4 10 f0       	cmp    $0xf010b4b1,%eax
f0102847:	0f 86 90 01 00 00    	jbe    f01029dd <debuginfo_eip+0x1dc>
f010284d:	eb 14                	jmp    f0102863 <debuginfo_eip+0x62>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f010284f:	83 ec 04             	sub    $0x4,%esp
f0102852:	68 38 47 10 f0       	push   $0xf0104738
f0102857:	6a 7f                	push   $0x7f
f0102859:	68 45 47 10 f0       	push   $0xf0104745
f010285e:	e8 28 d8 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102863:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102868:	80 3d 19 2d 11 f0 00 	cmpb   $0x0,0xf0112d19
f010286f:	0f 85 74 01 00 00    	jne    f01029e9 <debuginfo_eip+0x1e8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102875:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010287c:	b8 b0 b4 10 f0       	mov    $0xf010b4b0,%eax
f0102881:	2d 64 49 10 f0       	sub    $0xf0104964,%eax
f0102886:	c1 f8 02             	sar    $0x2,%eax
f0102889:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010288f:	48                   	dec    %eax
f0102890:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102893:	83 ec 08             	sub    $0x8,%esp
f0102896:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102899:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010289c:	56                   	push   %esi
f010289d:	6a 64                	push   $0x64
f010289f:	b8 64 49 10 f0       	mov    $0xf0104964,%eax
f01028a4:	e8 33 fe ff ff       	call   f01026dc <stab_binsearch>
	if (lfile == 0)
f01028a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01028ac:	83 c4 10             	add    $0x10,%esp
		return -1;
f01028af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01028b4:	85 d2                	test   %edx,%edx
f01028b6:	0f 84 2d 01 00 00    	je     f01029e9 <debuginfo_eip+0x1e8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01028bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01028bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01028c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01028c5:	83 ec 08             	sub    $0x8,%esp
f01028c8:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01028cb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01028ce:	56                   	push   %esi
f01028cf:	6a 24                	push   $0x24
f01028d1:	b8 64 49 10 f0       	mov    $0xf0104964,%eax
f01028d6:	e8 01 fe ff ff       	call   f01026dc <stab_binsearch>

	if (lfun <= rfun) {
f01028db:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01028de:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01028e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01028e4:	83 c4 10             	add    $0x10,%esp
f01028e7:	39 c7                	cmp    %eax,%edi
f01028e9:	7f 32                	jg     f010291d <debuginfo_eip+0x11c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01028eb:	89 f9                	mov    %edi,%ecx
f01028ed:	6b c7 0c             	imul   $0xc,%edi,%eax
f01028f0:	8b 80 64 49 10 f0    	mov    -0xfefb69c(%eax),%eax
f01028f6:	ba 1a 2d 11 f0       	mov    $0xf0112d1a,%edx
f01028fb:	81 ea b1 b4 10 f0    	sub    $0xf010b4b1,%edx
f0102901:	39 d0                	cmp    %edx,%eax
f0102903:	73 08                	jae    f010290d <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102905:	05 b1 b4 10 f0       	add    $0xf010b4b1,%eax
f010290a:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010290d:	6b c9 0c             	imul   $0xc,%ecx,%ecx
f0102910:	8b 81 6c 49 10 f0    	mov    -0xfefb694(%ecx),%eax
f0102916:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102919:	29 c6                	sub    %eax,%esi
f010291b:	eb 0c                	jmp    f0102929 <debuginfo_eip+0x128>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010291d:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102920:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
f0102923:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102926:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102929:	83 ec 08             	sub    $0x8,%esp
f010292c:	6a 3a                	push   $0x3a
f010292e:	ff 73 08             	pushl  0x8(%ebx)
f0102931:	e8 9d 08 00 00       	call   f01031d3 <strfind>
f0102936:	2b 43 08             	sub    0x8(%ebx),%eax
f0102939:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f010293c:	89 7d dc             	mov    %edi,-0x24(%ebp)
    rfun = rline;
f010293f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102942:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0102945:	83 c4 08             	add    $0x8,%esp
f0102948:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010294b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010294e:	56                   	push   %esi
f010294f:	6a 44                	push   $0x44
f0102951:	b8 64 49 10 f0       	mov    $0xf0104964,%eax
f0102956:	e8 81 fd ff ff       	call   f01026dc <stab_binsearch>
    if (lfun <= rfun) {
f010295b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010295e:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0102961:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0102966:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0102969:	7f 7e                	jg     f01029e9 <debuginfo_eip+0x1e8>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f010296b:	6b c2 0c             	imul   $0xc,%edx,%eax
f010296e:	05 64 49 10 f0       	add    $0xf0104964,%eax
f0102973:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0102977:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010297a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010297d:	83 c0 08             	add    $0x8,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102980:	eb 04                	jmp    f0102986 <debuginfo_eip+0x185>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0102982:	4a                   	dec    %edx
f0102983:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102986:	39 f2                	cmp    %esi,%edx
f0102988:	7c 1b                	jl     f01029a5 <debuginfo_eip+0x1a4>
	       && stabs[lline].n_type != N_SOL
f010298a:	8a 48 fc             	mov    -0x4(%eax),%cl
f010298d:	80 f9 84             	cmp    $0x84,%cl
f0102990:	74 5f                	je     f01029f1 <debuginfo_eip+0x1f0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102992:	80 f9 64             	cmp    $0x64,%cl
f0102995:	75 eb                	jne    f0102982 <debuginfo_eip+0x181>
f0102997:	83 38 00             	cmpl   $0x0,(%eax)
f010299a:	74 e6                	je     f0102982 <debuginfo_eip+0x181>
f010299c:	eb 53                	jmp    f01029f1 <debuginfo_eip+0x1f0>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f010299e:	05 b1 b4 10 f0       	add    $0xf010b4b1,%eax
f01029a3:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01029a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01029a8:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01029ab:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01029b0:	39 ca                	cmp    %ecx,%edx
f01029b2:	7d 35                	jge    f01029e9 <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
f01029b4:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01029b7:	6b d0 0c             	imul   $0xc,%eax,%edx
f01029ba:	81 c2 68 49 10 f0    	add    $0xf0104968,%edx
f01029c0:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01029c2:	eb 04                	jmp    f01029c8 <debuginfo_eip+0x1c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01029c4:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01029c7:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01029c8:	39 f0                	cmp    %esi,%eax
f01029ca:	7d 18                	jge    f01029e4 <debuginfo_eip+0x1e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01029cc:	8a 0a                	mov    (%edx),%cl
f01029ce:	83 c2 0c             	add    $0xc,%edx
f01029d1:	80 f9 a0             	cmp    $0xa0,%cl
f01029d4:	74 ee                	je     f01029c4 <debuginfo_eip+0x1c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01029d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01029db:	eb 0c                	jmp    f01029e9 <debuginfo_eip+0x1e8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01029dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029e2:	eb 05                	jmp    f01029e9 <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01029e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01029e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01029ec:	5b                   	pop    %ebx
f01029ed:	5e                   	pop    %esi
f01029ee:	5f                   	pop    %edi
f01029ef:	c9                   	leave  
f01029f0:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01029f1:	6b d2 0c             	imul   $0xc,%edx,%edx
f01029f4:	8b 82 64 49 10 f0    	mov    -0xfefb69c(%edx),%eax
f01029fa:	ba 1a 2d 11 f0       	mov    $0xf0112d1a,%edx
f01029ff:	81 ea b1 b4 10 f0    	sub    $0xf010b4b1,%edx
f0102a05:	39 d0                	cmp    %edx,%eax
f0102a07:	72 95                	jb     f010299e <debuginfo_eip+0x19d>
f0102a09:	eb 9a                	jmp    f01029a5 <debuginfo_eip+0x1a4>
	...

f0102a0c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102a0c:	55                   	push   %ebp
f0102a0d:	89 e5                	mov    %esp,%ebp
f0102a0f:	57                   	push   %edi
f0102a10:	56                   	push   %esi
f0102a11:	53                   	push   %ebx
f0102a12:	83 ec 2c             	sub    $0x2c,%esp
f0102a15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102a18:	89 d6                	mov    %edx,%esi
f0102a1a:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102a20:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102a23:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102a26:	8b 45 10             	mov    0x10(%ebp),%eax
f0102a29:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102a2c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102a2f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102a32:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102a39:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102a3c:	72 0c                	jb     f0102a4a <printnum+0x3e>
f0102a3e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0102a41:	76 07                	jbe    f0102a4a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102a43:	4b                   	dec    %ebx
f0102a44:	85 db                	test   %ebx,%ebx
f0102a46:	7f 31                	jg     f0102a79 <printnum+0x6d>
f0102a48:	eb 3f                	jmp    f0102a89 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102a4a:	83 ec 0c             	sub    $0xc,%esp
f0102a4d:	57                   	push   %edi
f0102a4e:	4b                   	dec    %ebx
f0102a4f:	53                   	push   %ebx
f0102a50:	50                   	push   %eax
f0102a51:	83 ec 08             	sub    $0x8,%esp
f0102a54:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102a57:	ff 75 d0             	pushl  -0x30(%ebp)
f0102a5a:	ff 75 dc             	pushl  -0x24(%ebp)
f0102a5d:	ff 75 d8             	pushl  -0x28(%ebp)
f0102a60:	e8 97 09 00 00       	call   f01033fc <__udivdi3>
f0102a65:	83 c4 18             	add    $0x18,%esp
f0102a68:	52                   	push   %edx
f0102a69:	50                   	push   %eax
f0102a6a:	89 f2                	mov    %esi,%edx
f0102a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102a6f:	e8 98 ff ff ff       	call   f0102a0c <printnum>
f0102a74:	83 c4 20             	add    $0x20,%esp
f0102a77:	eb 10                	jmp    f0102a89 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102a79:	83 ec 08             	sub    $0x8,%esp
f0102a7c:	56                   	push   %esi
f0102a7d:	57                   	push   %edi
f0102a7e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102a81:	4b                   	dec    %ebx
f0102a82:	83 c4 10             	add    $0x10,%esp
f0102a85:	85 db                	test   %ebx,%ebx
f0102a87:	7f f0                	jg     f0102a79 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102a89:	83 ec 08             	sub    $0x8,%esp
f0102a8c:	56                   	push   %esi
f0102a8d:	83 ec 04             	sub    $0x4,%esp
f0102a90:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102a93:	ff 75 d0             	pushl  -0x30(%ebp)
f0102a96:	ff 75 dc             	pushl  -0x24(%ebp)
f0102a99:	ff 75 d8             	pushl  -0x28(%ebp)
f0102a9c:	e8 77 0a 00 00       	call   f0103518 <__umoddi3>
f0102aa1:	83 c4 14             	add    $0x14,%esp
f0102aa4:	0f be 80 53 47 10 f0 	movsbl -0xfefb8ad(%eax),%eax
f0102aab:	50                   	push   %eax
f0102aac:	ff 55 e4             	call   *-0x1c(%ebp)
f0102aaf:	83 c4 10             	add    $0x10,%esp
}
f0102ab2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ab5:	5b                   	pop    %ebx
f0102ab6:	5e                   	pop    %esi
f0102ab7:	5f                   	pop    %edi
f0102ab8:	c9                   	leave  
f0102ab9:	c3                   	ret    

f0102aba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102aba:	55                   	push   %ebp
f0102abb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102abd:	83 fa 01             	cmp    $0x1,%edx
f0102ac0:	7e 0e                	jle    f0102ad0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102ac2:	8b 10                	mov    (%eax),%edx
f0102ac4:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102ac7:	89 08                	mov    %ecx,(%eax)
f0102ac9:	8b 02                	mov    (%edx),%eax
f0102acb:	8b 52 04             	mov    0x4(%edx),%edx
f0102ace:	eb 22                	jmp    f0102af2 <getuint+0x38>
	else if (lflag)
f0102ad0:	85 d2                	test   %edx,%edx
f0102ad2:	74 10                	je     f0102ae4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102ad4:	8b 10                	mov    (%eax),%edx
f0102ad6:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102ad9:	89 08                	mov    %ecx,(%eax)
f0102adb:	8b 02                	mov    (%edx),%eax
f0102add:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ae2:	eb 0e                	jmp    f0102af2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102ae4:	8b 10                	mov    (%eax),%edx
f0102ae6:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102ae9:	89 08                	mov    %ecx,(%eax)
f0102aeb:	8b 02                	mov    (%edx),%eax
f0102aed:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102af2:	c9                   	leave  
f0102af3:	c3                   	ret    

f0102af4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0102af4:	55                   	push   %ebp
f0102af5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102af7:	83 fa 01             	cmp    $0x1,%edx
f0102afa:	7e 0e                	jle    f0102b0a <getint+0x16>
		return va_arg(*ap, long long);
f0102afc:	8b 10                	mov    (%eax),%edx
f0102afe:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102b01:	89 08                	mov    %ecx,(%eax)
f0102b03:	8b 02                	mov    (%edx),%eax
f0102b05:	8b 52 04             	mov    0x4(%edx),%edx
f0102b08:	eb 1a                	jmp    f0102b24 <getint+0x30>
	else if (lflag)
f0102b0a:	85 d2                	test   %edx,%edx
f0102b0c:	74 0c                	je     f0102b1a <getint+0x26>
		return va_arg(*ap, long);
f0102b0e:	8b 10                	mov    (%eax),%edx
f0102b10:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102b13:	89 08                	mov    %ecx,(%eax)
f0102b15:	8b 02                	mov    (%edx),%eax
f0102b17:	99                   	cltd   
f0102b18:	eb 0a                	jmp    f0102b24 <getint+0x30>
	else
		return va_arg(*ap, int);
f0102b1a:	8b 10                	mov    (%eax),%edx
f0102b1c:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102b1f:	89 08                	mov    %ecx,(%eax)
f0102b21:	8b 02                	mov    (%edx),%eax
f0102b23:	99                   	cltd   
}
f0102b24:	c9                   	leave  
f0102b25:	c3                   	ret    

f0102b26 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102b26:	55                   	push   %ebp
f0102b27:	89 e5                	mov    %esp,%ebp
f0102b29:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102b2c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0102b2f:	8b 10                	mov    (%eax),%edx
f0102b31:	3b 50 04             	cmp    0x4(%eax),%edx
f0102b34:	73 08                	jae    f0102b3e <sprintputch+0x18>
		*b->buf++ = ch;
f0102b36:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102b39:	88 0a                	mov    %cl,(%edx)
f0102b3b:	42                   	inc    %edx
f0102b3c:	89 10                	mov    %edx,(%eax)
}
f0102b3e:	c9                   	leave  
f0102b3f:	c3                   	ret    

f0102b40 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102b40:	55                   	push   %ebp
f0102b41:	89 e5                	mov    %esp,%ebp
f0102b43:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102b46:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102b49:	50                   	push   %eax
f0102b4a:	ff 75 10             	pushl  0x10(%ebp)
f0102b4d:	ff 75 0c             	pushl  0xc(%ebp)
f0102b50:	ff 75 08             	pushl  0x8(%ebp)
f0102b53:	e8 05 00 00 00       	call   f0102b5d <vprintfmt>
	va_end(ap);
f0102b58:	83 c4 10             	add    $0x10,%esp
}
f0102b5b:	c9                   	leave  
f0102b5c:	c3                   	ret    

f0102b5d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102b5d:	55                   	push   %ebp
f0102b5e:	89 e5                	mov    %esp,%ebp
f0102b60:	57                   	push   %edi
f0102b61:	56                   	push   %esi
f0102b62:	53                   	push   %ebx
f0102b63:	83 ec 2c             	sub    $0x2c,%esp
f0102b66:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102b69:	8b 75 10             	mov    0x10(%ebp),%esi
f0102b6c:	eb 13                	jmp    f0102b81 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102b6e:	85 c0                	test   %eax,%eax
f0102b70:	0f 84 6d 03 00 00    	je     f0102ee3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f0102b76:	83 ec 08             	sub    $0x8,%esp
f0102b79:	57                   	push   %edi
f0102b7a:	50                   	push   %eax
f0102b7b:	ff 55 08             	call   *0x8(%ebp)
f0102b7e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102b81:	0f b6 06             	movzbl (%esi),%eax
f0102b84:	46                   	inc    %esi
f0102b85:	83 f8 25             	cmp    $0x25,%eax
f0102b88:	75 e4                	jne    f0102b6e <vprintfmt+0x11>
f0102b8a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0102b8e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102b95:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0102b9c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0102ba3:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102ba8:	eb 28                	jmp    f0102bd2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102baa:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102bac:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0102bb0:	eb 20                	jmp    f0102bd2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102bb2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102bb4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0102bb8:	eb 18                	jmp    f0102bd2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102bba:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0102bbc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0102bc3:	eb 0d                	jmp    f0102bd2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0102bc5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bc8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102bcb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102bd2:	8a 06                	mov    (%esi),%al
f0102bd4:	0f b6 d0             	movzbl %al,%edx
f0102bd7:	8d 5e 01             	lea    0x1(%esi),%ebx
f0102bda:	83 e8 23             	sub    $0x23,%eax
f0102bdd:	3c 55                	cmp    $0x55,%al
f0102bdf:	0f 87 e0 02 00 00    	ja     f0102ec5 <vprintfmt+0x368>
f0102be5:	0f b6 c0             	movzbl %al,%eax
f0102be8:	ff 24 85 e0 47 10 f0 	jmp    *-0xfefb820(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102bef:	83 ea 30             	sub    $0x30,%edx
f0102bf2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0102bf5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0102bf8:	8d 50 d0             	lea    -0x30(%eax),%edx
f0102bfb:	83 fa 09             	cmp    $0x9,%edx
f0102bfe:	77 44                	ja     f0102c44 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c00:	89 de                	mov    %ebx,%esi
f0102c02:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102c05:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0102c06:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0102c09:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0102c0d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0102c10:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0102c13:	83 fb 09             	cmp    $0x9,%ebx
f0102c16:	76 ed                	jbe    f0102c05 <vprintfmt+0xa8>
f0102c18:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102c1b:	eb 29                	jmp    f0102c46 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102c1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c20:	8d 50 04             	lea    0x4(%eax),%edx
f0102c23:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c26:	8b 00                	mov    (%eax),%eax
f0102c28:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c2b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102c2d:	eb 17                	jmp    f0102c46 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0102c2f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102c33:	78 85                	js     f0102bba <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c35:	89 de                	mov    %ebx,%esi
f0102c37:	eb 99                	jmp    f0102bd2 <vprintfmt+0x75>
f0102c39:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102c3b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0102c42:	eb 8e                	jmp    f0102bd2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c44:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0102c46:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102c4a:	79 86                	jns    f0102bd2 <vprintfmt+0x75>
f0102c4c:	e9 74 ff ff ff       	jmp    f0102bc5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102c51:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c52:	89 de                	mov    %ebx,%esi
f0102c54:	e9 79 ff ff ff       	jmp    f0102bd2 <vprintfmt+0x75>
f0102c59:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102c5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c5f:	8d 50 04             	lea    0x4(%eax),%edx
f0102c62:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c65:	83 ec 08             	sub    $0x8,%esp
f0102c68:	57                   	push   %edi
f0102c69:	ff 30                	pushl  (%eax)
f0102c6b:	ff 55 08             	call   *0x8(%ebp)
			break;
f0102c6e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c71:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102c74:	e9 08 ff ff ff       	jmp    f0102b81 <vprintfmt+0x24>
f0102c79:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102c7c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c7f:	8d 50 04             	lea    0x4(%eax),%edx
f0102c82:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c85:	8b 00                	mov    (%eax),%eax
f0102c87:	85 c0                	test   %eax,%eax
f0102c89:	79 02                	jns    f0102c8d <vprintfmt+0x130>
f0102c8b:	f7 d8                	neg    %eax
f0102c8d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102c8f:	83 f8 06             	cmp    $0x6,%eax
f0102c92:	7f 0b                	jg     f0102c9f <vprintfmt+0x142>
f0102c94:	8b 04 85 38 49 10 f0 	mov    -0xfefb6c8(,%eax,4),%eax
f0102c9b:	85 c0                	test   %eax,%eax
f0102c9d:	75 1a                	jne    f0102cb9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0102c9f:	52                   	push   %edx
f0102ca0:	68 6b 47 10 f0       	push   $0xf010476b
f0102ca5:	57                   	push   %edi
f0102ca6:	ff 75 08             	pushl  0x8(%ebp)
f0102ca9:	e8 92 fe ff ff       	call   f0102b40 <printfmt>
f0102cae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cb1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102cb4:	e9 c8 fe ff ff       	jmp    f0102b81 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0102cb9:	50                   	push   %eax
f0102cba:	68 a4 44 10 f0       	push   $0xf01044a4
f0102cbf:	57                   	push   %edi
f0102cc0:	ff 75 08             	pushl  0x8(%ebp)
f0102cc3:	e8 78 fe ff ff       	call   f0102b40 <printfmt>
f0102cc8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ccb:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0102cce:	e9 ae fe ff ff       	jmp    f0102b81 <vprintfmt+0x24>
f0102cd3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0102cd6:	89 de                	mov    %ebx,%esi
f0102cd8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102cdb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102cde:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ce1:	8d 50 04             	lea    0x4(%eax),%edx
f0102ce4:	89 55 14             	mov    %edx,0x14(%ebp)
f0102ce7:	8b 00                	mov    (%eax),%eax
f0102ce9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102cec:	85 c0                	test   %eax,%eax
f0102cee:	75 07                	jne    f0102cf7 <vprintfmt+0x19a>
				p = "(null)";
f0102cf0:	c7 45 d0 64 47 10 f0 	movl   $0xf0104764,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0102cf7:	85 db                	test   %ebx,%ebx
f0102cf9:	7e 42                	jle    f0102d3d <vprintfmt+0x1e0>
f0102cfb:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0102cff:	74 3c                	je     f0102d3d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d01:	83 ec 08             	sub    $0x8,%esp
f0102d04:	51                   	push   %ecx
f0102d05:	ff 75 d0             	pushl  -0x30(%ebp)
f0102d08:	e8 3f 03 00 00       	call   f010304c <strnlen>
f0102d0d:	29 c3                	sub    %eax,%ebx
f0102d0f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102d12:	83 c4 10             	add    $0x10,%esp
f0102d15:	85 db                	test   %ebx,%ebx
f0102d17:	7e 24                	jle    f0102d3d <vprintfmt+0x1e0>
					putch(padc, putdat);
f0102d19:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0102d1d:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0102d20:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102d23:	83 ec 08             	sub    $0x8,%esp
f0102d26:	57                   	push   %edi
f0102d27:	53                   	push   %ebx
f0102d28:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d2b:	4e                   	dec    %esi
f0102d2c:	83 c4 10             	add    $0x10,%esp
f0102d2f:	85 f6                	test   %esi,%esi
f0102d31:	7f f0                	jg     f0102d23 <vprintfmt+0x1c6>
f0102d33:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0102d36:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102d3d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102d40:	0f be 02             	movsbl (%edx),%eax
f0102d43:	85 c0                	test   %eax,%eax
f0102d45:	75 47                	jne    f0102d8e <vprintfmt+0x231>
f0102d47:	eb 37                	jmp    f0102d80 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f0102d49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102d4d:	74 16                	je     f0102d65 <vprintfmt+0x208>
f0102d4f:	8d 50 e0             	lea    -0x20(%eax),%edx
f0102d52:	83 fa 5e             	cmp    $0x5e,%edx
f0102d55:	76 0e                	jbe    f0102d65 <vprintfmt+0x208>
					putch('?', putdat);
f0102d57:	83 ec 08             	sub    $0x8,%esp
f0102d5a:	57                   	push   %edi
f0102d5b:	6a 3f                	push   $0x3f
f0102d5d:	ff 55 08             	call   *0x8(%ebp)
f0102d60:	83 c4 10             	add    $0x10,%esp
f0102d63:	eb 0b                	jmp    f0102d70 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f0102d65:	83 ec 08             	sub    $0x8,%esp
f0102d68:	57                   	push   %edi
f0102d69:	50                   	push   %eax
f0102d6a:	ff 55 08             	call   *0x8(%ebp)
f0102d6d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102d70:	ff 4d e4             	decl   -0x1c(%ebp)
f0102d73:	0f be 03             	movsbl (%ebx),%eax
f0102d76:	85 c0                	test   %eax,%eax
f0102d78:	74 03                	je     f0102d7d <vprintfmt+0x220>
f0102d7a:	43                   	inc    %ebx
f0102d7b:	eb 1b                	jmp    f0102d98 <vprintfmt+0x23b>
f0102d7d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102d80:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102d84:	7f 1e                	jg     f0102da4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d86:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0102d89:	e9 f3 fd ff ff       	jmp    f0102b81 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102d8e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102d91:	43                   	inc    %ebx
f0102d92:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0102d95:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102d98:	85 f6                	test   %esi,%esi
f0102d9a:	78 ad                	js     f0102d49 <vprintfmt+0x1ec>
f0102d9c:	4e                   	dec    %esi
f0102d9d:	79 aa                	jns    f0102d49 <vprintfmt+0x1ec>
f0102d9f:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0102da2:	eb dc                	jmp    f0102d80 <vprintfmt+0x223>
f0102da4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102da7:	83 ec 08             	sub    $0x8,%esp
f0102daa:	57                   	push   %edi
f0102dab:	6a 20                	push   $0x20
f0102dad:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102db0:	4b                   	dec    %ebx
f0102db1:	83 c4 10             	add    $0x10,%esp
f0102db4:	85 db                	test   %ebx,%ebx
f0102db6:	7f ef                	jg     f0102da7 <vprintfmt+0x24a>
f0102db8:	e9 c4 fd ff ff       	jmp    f0102b81 <vprintfmt+0x24>
f0102dbd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102dc0:	89 ca                	mov    %ecx,%edx
f0102dc2:	8d 45 14             	lea    0x14(%ebp),%eax
f0102dc5:	e8 2a fd ff ff       	call   f0102af4 <getint>
f0102dca:	89 c3                	mov    %eax,%ebx
f0102dcc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0102dce:	85 d2                	test   %edx,%edx
f0102dd0:	78 0a                	js     f0102ddc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102dd2:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102dd7:	e9 b0 00 00 00       	jmp    f0102e8c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0102ddc:	83 ec 08             	sub    $0x8,%esp
f0102ddf:	57                   	push   %edi
f0102de0:	6a 2d                	push   $0x2d
f0102de2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0102de5:	f7 db                	neg    %ebx
f0102de7:	83 d6 00             	adc    $0x0,%esi
f0102dea:	f7 de                	neg    %esi
f0102dec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102def:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102df4:	e9 93 00 00 00       	jmp    f0102e8c <vprintfmt+0x32f>
f0102df9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102dfc:	89 ca                	mov    %ecx,%edx
f0102dfe:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e01:	e8 b4 fc ff ff       	call   f0102aba <getuint>
f0102e06:	89 c3                	mov    %eax,%ebx
f0102e08:	89 d6                	mov    %edx,%esi
			base = 10;
f0102e0a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0102e0f:	eb 7b                	jmp    f0102e8c <vprintfmt+0x32f>
f0102e11:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0102e14:	89 ca                	mov    %ecx,%edx
f0102e16:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e19:	e8 d6 fc ff ff       	call   f0102af4 <getint>
f0102e1e:	89 c3                	mov    %eax,%ebx
f0102e20:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f0102e22:	85 d2                	test   %edx,%edx
f0102e24:	78 07                	js     f0102e2d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f0102e26:	b8 08 00 00 00       	mov    $0x8,%eax
f0102e2b:	eb 5f                	jmp    f0102e8c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0102e2d:	83 ec 08             	sub    $0x8,%esp
f0102e30:	57                   	push   %edi
f0102e31:	6a 2d                	push   $0x2d
f0102e33:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f0102e36:	f7 db                	neg    %ebx
f0102e38:	83 d6 00             	adc    $0x0,%esi
f0102e3b:	f7 de                	neg    %esi
f0102e3d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f0102e40:	b8 08 00 00 00       	mov    $0x8,%eax
f0102e45:	eb 45                	jmp    f0102e8c <vprintfmt+0x32f>
f0102e47:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f0102e4a:	83 ec 08             	sub    $0x8,%esp
f0102e4d:	57                   	push   %edi
f0102e4e:	6a 30                	push   $0x30
f0102e50:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0102e53:	83 c4 08             	add    $0x8,%esp
f0102e56:	57                   	push   %edi
f0102e57:	6a 78                	push   $0x78
f0102e59:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102e5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e5f:	8d 50 04             	lea    0x4(%eax),%edx
f0102e62:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102e65:	8b 18                	mov    (%eax),%ebx
f0102e67:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102e6c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102e6f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0102e74:	eb 16                	jmp    f0102e8c <vprintfmt+0x32f>
f0102e76:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102e79:	89 ca                	mov    %ecx,%edx
f0102e7b:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e7e:	e8 37 fc ff ff       	call   f0102aba <getuint>
f0102e83:	89 c3                	mov    %eax,%ebx
f0102e85:	89 d6                	mov    %edx,%esi
			base = 16;
f0102e87:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102e8c:	83 ec 0c             	sub    $0xc,%esp
f0102e8f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0102e93:	52                   	push   %edx
f0102e94:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102e97:	50                   	push   %eax
f0102e98:	56                   	push   %esi
f0102e99:	53                   	push   %ebx
f0102e9a:	89 fa                	mov    %edi,%edx
f0102e9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e9f:	e8 68 fb ff ff       	call   f0102a0c <printnum>
			break;
f0102ea4:	83 c4 20             	add    $0x20,%esp
f0102ea7:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0102eaa:	e9 d2 fc ff ff       	jmp    f0102b81 <vprintfmt+0x24>
f0102eaf:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102eb2:	83 ec 08             	sub    $0x8,%esp
f0102eb5:	57                   	push   %edi
f0102eb6:	52                   	push   %edx
f0102eb7:	ff 55 08             	call   *0x8(%ebp)
			break;
f0102eba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ebd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102ec0:	e9 bc fc ff ff       	jmp    f0102b81 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0102ec5:	83 ec 08             	sub    $0x8,%esp
f0102ec8:	57                   	push   %edi
f0102ec9:	6a 25                	push   $0x25
f0102ecb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102ece:	83 c4 10             	add    $0x10,%esp
f0102ed1:	eb 02                	jmp    f0102ed5 <vprintfmt+0x378>
f0102ed3:	89 c6                	mov    %eax,%esi
f0102ed5:	8d 46 ff             	lea    -0x1(%esi),%eax
f0102ed8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0102edc:	75 f5                	jne    f0102ed3 <vprintfmt+0x376>
f0102ede:	e9 9e fc ff ff       	jmp    f0102b81 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0102ee3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ee6:	5b                   	pop    %ebx
f0102ee7:	5e                   	pop    %esi
f0102ee8:	5f                   	pop    %edi
f0102ee9:	c9                   	leave  
f0102eea:	c3                   	ret    

f0102eeb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102eeb:	55                   	push   %ebp
f0102eec:	89 e5                	mov    %esp,%ebp
f0102eee:	83 ec 18             	sub    $0x18,%esp
f0102ef1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ef4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102ef7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102efa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102efe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102f01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102f08:	85 c0                	test   %eax,%eax
f0102f0a:	74 26                	je     f0102f32 <vsnprintf+0x47>
f0102f0c:	85 d2                	test   %edx,%edx
f0102f0e:	7e 29                	jle    f0102f39 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102f10:	ff 75 14             	pushl  0x14(%ebp)
f0102f13:	ff 75 10             	pushl  0x10(%ebp)
f0102f16:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102f19:	50                   	push   %eax
f0102f1a:	68 26 2b 10 f0       	push   $0xf0102b26
f0102f1f:	e8 39 fc ff ff       	call   f0102b5d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102f24:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102f27:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f2d:	83 c4 10             	add    $0x10,%esp
f0102f30:	eb 0c                	jmp    f0102f3e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0102f32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0102f37:	eb 05                	jmp    f0102f3e <vsnprintf+0x53>
f0102f39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102f3e:	c9                   	leave  
f0102f3f:	c3                   	ret    

f0102f40 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102f40:	55                   	push   %ebp
f0102f41:	89 e5                	mov    %esp,%ebp
f0102f43:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102f46:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102f49:	50                   	push   %eax
f0102f4a:	ff 75 10             	pushl  0x10(%ebp)
f0102f4d:	ff 75 0c             	pushl  0xc(%ebp)
f0102f50:	ff 75 08             	pushl  0x8(%ebp)
f0102f53:	e8 93 ff ff ff       	call   f0102eeb <vsnprintf>
	va_end(ap);

	return rc;
}
f0102f58:	c9                   	leave  
f0102f59:	c3                   	ret    
	...

f0102f5c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102f5c:	55                   	push   %ebp
f0102f5d:	89 e5                	mov    %esp,%ebp
f0102f5f:	57                   	push   %edi
f0102f60:	56                   	push   %esi
f0102f61:	53                   	push   %ebx
f0102f62:	83 ec 0c             	sub    $0xc,%esp
f0102f65:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102f68:	85 c0                	test   %eax,%eax
f0102f6a:	74 11                	je     f0102f7d <readline+0x21>
		cprintf("%s", prompt);
f0102f6c:	83 ec 08             	sub    $0x8,%esp
f0102f6f:	50                   	push   %eax
f0102f70:	68 a4 44 10 f0       	push   $0xf01044a4
f0102f75:	e8 4b f7 ff ff       	call   f01026c5 <cprintf>
f0102f7a:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0102f7d:	83 ec 0c             	sub    $0xc,%esp
f0102f80:	6a 00                	push   $0x0
f0102f82:	e8 40 d6 ff ff       	call   f01005c7 <iscons>
f0102f87:	89 c7                	mov    %eax,%edi
f0102f89:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0102f8c:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0102f91:	e8 20 d6 ff ff       	call   f01005b6 <getchar>
f0102f96:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102f98:	85 c0                	test   %eax,%eax
f0102f9a:	79 18                	jns    f0102fb4 <readline+0x58>
			cprintf("read error: %e\n", c);
f0102f9c:	83 ec 08             	sub    $0x8,%esp
f0102f9f:	50                   	push   %eax
f0102fa0:	68 54 49 10 f0       	push   $0xf0104954
f0102fa5:	e8 1b f7 ff ff       	call   f01026c5 <cprintf>
			return NULL;
f0102faa:	83 c4 10             	add    $0x10,%esp
f0102fad:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fb2:	eb 6f                	jmp    f0103023 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102fb4:	83 f8 08             	cmp    $0x8,%eax
f0102fb7:	74 05                	je     f0102fbe <readline+0x62>
f0102fb9:	83 f8 7f             	cmp    $0x7f,%eax
f0102fbc:	75 18                	jne    f0102fd6 <readline+0x7a>
f0102fbe:	85 f6                	test   %esi,%esi
f0102fc0:	7e 14                	jle    f0102fd6 <readline+0x7a>
			if (echoing)
f0102fc2:	85 ff                	test   %edi,%edi
f0102fc4:	74 0d                	je     f0102fd3 <readline+0x77>
				cputchar('\b');
f0102fc6:	83 ec 0c             	sub    $0xc,%esp
f0102fc9:	6a 08                	push   $0x8
f0102fcb:	e8 d6 d5 ff ff       	call   f01005a6 <cputchar>
f0102fd0:	83 c4 10             	add    $0x10,%esp
			i--;
f0102fd3:	4e                   	dec    %esi
f0102fd4:	eb bb                	jmp    f0102f91 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0102fd6:	83 fb 1f             	cmp    $0x1f,%ebx
f0102fd9:	7e 21                	jle    f0102ffc <readline+0xa0>
f0102fdb:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102fe1:	7f 19                	jg     f0102ffc <readline+0xa0>
			if (echoing)
f0102fe3:	85 ff                	test   %edi,%edi
f0102fe5:	74 0c                	je     f0102ff3 <readline+0x97>
				cputchar(c);
f0102fe7:	83 ec 0c             	sub    $0xc,%esp
f0102fea:	53                   	push   %ebx
f0102feb:	e8 b6 d5 ff ff       	call   f01005a6 <cputchar>
f0102ff0:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0102ff3:	88 9e 40 d5 11 f0    	mov    %bl,-0xfee2ac0(%esi)
f0102ff9:	46                   	inc    %esi
f0102ffa:	eb 95                	jmp    f0102f91 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0102ffc:	83 fb 0a             	cmp    $0xa,%ebx
f0102fff:	74 05                	je     f0103006 <readline+0xaa>
f0103001:	83 fb 0d             	cmp    $0xd,%ebx
f0103004:	75 8b                	jne    f0102f91 <readline+0x35>
			if (echoing)
f0103006:	85 ff                	test   %edi,%edi
f0103008:	74 0d                	je     f0103017 <readline+0xbb>
				cputchar('\n');
f010300a:	83 ec 0c             	sub    $0xc,%esp
f010300d:	6a 0a                	push   $0xa
f010300f:	e8 92 d5 ff ff       	call   f01005a6 <cputchar>
f0103014:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103017:	c6 86 40 d5 11 f0 00 	movb   $0x0,-0xfee2ac0(%esi)
			return buf;
f010301e:	b8 40 d5 11 f0       	mov    $0xf011d540,%eax
		}
	}
}
f0103023:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103026:	5b                   	pop    %ebx
f0103027:	5e                   	pop    %esi
f0103028:	5f                   	pop    %edi
f0103029:	c9                   	leave  
f010302a:	c3                   	ret    
	...

f010302c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010302c:	55                   	push   %ebp
f010302d:	89 e5                	mov    %esp,%ebp
f010302f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103032:	80 3a 00             	cmpb   $0x0,(%edx)
f0103035:	74 0e                	je     f0103045 <strlen+0x19>
f0103037:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f010303c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010303d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103041:	75 f9                	jne    f010303c <strlen+0x10>
f0103043:	eb 05                	jmp    f010304a <strlen+0x1e>
f0103045:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010304a:	c9                   	leave  
f010304b:	c3                   	ret    

f010304c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010304c:	55                   	push   %ebp
f010304d:	89 e5                	mov    %esp,%ebp
f010304f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103052:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103055:	85 d2                	test   %edx,%edx
f0103057:	74 17                	je     f0103070 <strnlen+0x24>
f0103059:	80 39 00             	cmpb   $0x0,(%ecx)
f010305c:	74 19                	je     f0103077 <strnlen+0x2b>
f010305e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0103063:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103064:	39 d0                	cmp    %edx,%eax
f0103066:	74 14                	je     f010307c <strnlen+0x30>
f0103068:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010306c:	75 f5                	jne    f0103063 <strnlen+0x17>
f010306e:	eb 0c                	jmp    f010307c <strnlen+0x30>
f0103070:	b8 00 00 00 00       	mov    $0x0,%eax
f0103075:	eb 05                	jmp    f010307c <strnlen+0x30>
f0103077:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010307c:	c9                   	leave  
f010307d:	c3                   	ret    

f010307e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010307e:	55                   	push   %ebp
f010307f:	89 e5                	mov    %esp,%ebp
f0103081:	53                   	push   %ebx
f0103082:	8b 45 08             	mov    0x8(%ebp),%eax
f0103085:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103088:	ba 00 00 00 00       	mov    $0x0,%edx
f010308d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0103090:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103093:	42                   	inc    %edx
f0103094:	84 c9                	test   %cl,%cl
f0103096:	75 f5                	jne    f010308d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103098:	5b                   	pop    %ebx
f0103099:	c9                   	leave  
f010309a:	c3                   	ret    

f010309b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010309b:	55                   	push   %ebp
f010309c:	89 e5                	mov    %esp,%ebp
f010309e:	53                   	push   %ebx
f010309f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01030a2:	53                   	push   %ebx
f01030a3:	e8 84 ff ff ff       	call   f010302c <strlen>
f01030a8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01030ab:	ff 75 0c             	pushl  0xc(%ebp)
f01030ae:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01030b1:	50                   	push   %eax
f01030b2:	e8 c7 ff ff ff       	call   f010307e <strcpy>
	return dst;
}
f01030b7:	89 d8                	mov    %ebx,%eax
f01030b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01030bc:	c9                   	leave  
f01030bd:	c3                   	ret    

f01030be <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01030be:	55                   	push   %ebp
f01030bf:	89 e5                	mov    %esp,%ebp
f01030c1:	56                   	push   %esi
f01030c2:	53                   	push   %ebx
f01030c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01030c6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01030c9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01030cc:	85 f6                	test   %esi,%esi
f01030ce:	74 15                	je     f01030e5 <strncpy+0x27>
f01030d0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01030d5:	8a 1a                	mov    (%edx),%bl
f01030d7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01030da:	80 3a 01             	cmpb   $0x1,(%edx)
f01030dd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01030e0:	41                   	inc    %ecx
f01030e1:	39 ce                	cmp    %ecx,%esi
f01030e3:	77 f0                	ja     f01030d5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01030e5:	5b                   	pop    %ebx
f01030e6:	5e                   	pop    %esi
f01030e7:	c9                   	leave  
f01030e8:	c3                   	ret    

f01030e9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01030e9:	55                   	push   %ebp
f01030ea:	89 e5                	mov    %esp,%ebp
f01030ec:	57                   	push   %edi
f01030ed:	56                   	push   %esi
f01030ee:	53                   	push   %ebx
f01030ef:	8b 7d 08             	mov    0x8(%ebp),%edi
f01030f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01030f5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01030f8:	85 f6                	test   %esi,%esi
f01030fa:	74 32                	je     f010312e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f01030fc:	83 fe 01             	cmp    $0x1,%esi
f01030ff:	74 22                	je     f0103123 <strlcpy+0x3a>
f0103101:	8a 0b                	mov    (%ebx),%cl
f0103103:	84 c9                	test   %cl,%cl
f0103105:	74 20                	je     f0103127 <strlcpy+0x3e>
f0103107:	89 f8                	mov    %edi,%eax
f0103109:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010310e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103111:	88 08                	mov    %cl,(%eax)
f0103113:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103114:	39 f2                	cmp    %esi,%edx
f0103116:	74 11                	je     f0103129 <strlcpy+0x40>
f0103118:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f010311c:	42                   	inc    %edx
f010311d:	84 c9                	test   %cl,%cl
f010311f:	75 f0                	jne    f0103111 <strlcpy+0x28>
f0103121:	eb 06                	jmp    f0103129 <strlcpy+0x40>
f0103123:	89 f8                	mov    %edi,%eax
f0103125:	eb 02                	jmp    f0103129 <strlcpy+0x40>
f0103127:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103129:	c6 00 00             	movb   $0x0,(%eax)
f010312c:	eb 02                	jmp    f0103130 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010312e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0103130:	29 f8                	sub    %edi,%eax
}
f0103132:	5b                   	pop    %ebx
f0103133:	5e                   	pop    %esi
f0103134:	5f                   	pop    %edi
f0103135:	c9                   	leave  
f0103136:	c3                   	ret    

f0103137 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103137:	55                   	push   %ebp
f0103138:	89 e5                	mov    %esp,%ebp
f010313a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010313d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103140:	8a 01                	mov    (%ecx),%al
f0103142:	84 c0                	test   %al,%al
f0103144:	74 10                	je     f0103156 <strcmp+0x1f>
f0103146:	3a 02                	cmp    (%edx),%al
f0103148:	75 0c                	jne    f0103156 <strcmp+0x1f>
		p++, q++;
f010314a:	41                   	inc    %ecx
f010314b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010314c:	8a 01                	mov    (%ecx),%al
f010314e:	84 c0                	test   %al,%al
f0103150:	74 04                	je     f0103156 <strcmp+0x1f>
f0103152:	3a 02                	cmp    (%edx),%al
f0103154:	74 f4                	je     f010314a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103156:	0f b6 c0             	movzbl %al,%eax
f0103159:	0f b6 12             	movzbl (%edx),%edx
f010315c:	29 d0                	sub    %edx,%eax
}
f010315e:	c9                   	leave  
f010315f:	c3                   	ret    

f0103160 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103160:	55                   	push   %ebp
f0103161:	89 e5                	mov    %esp,%ebp
f0103163:	53                   	push   %ebx
f0103164:	8b 55 08             	mov    0x8(%ebp),%edx
f0103167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010316a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f010316d:	85 c0                	test   %eax,%eax
f010316f:	74 1b                	je     f010318c <strncmp+0x2c>
f0103171:	8a 1a                	mov    (%edx),%bl
f0103173:	84 db                	test   %bl,%bl
f0103175:	74 24                	je     f010319b <strncmp+0x3b>
f0103177:	3a 19                	cmp    (%ecx),%bl
f0103179:	75 20                	jne    f010319b <strncmp+0x3b>
f010317b:	48                   	dec    %eax
f010317c:	74 15                	je     f0103193 <strncmp+0x33>
		n--, p++, q++;
f010317e:	42                   	inc    %edx
f010317f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103180:	8a 1a                	mov    (%edx),%bl
f0103182:	84 db                	test   %bl,%bl
f0103184:	74 15                	je     f010319b <strncmp+0x3b>
f0103186:	3a 19                	cmp    (%ecx),%bl
f0103188:	74 f1                	je     f010317b <strncmp+0x1b>
f010318a:	eb 0f                	jmp    f010319b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f010318c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103191:	eb 05                	jmp    f0103198 <strncmp+0x38>
f0103193:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103198:	5b                   	pop    %ebx
f0103199:	c9                   	leave  
f010319a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010319b:	0f b6 02             	movzbl (%edx),%eax
f010319e:	0f b6 11             	movzbl (%ecx),%edx
f01031a1:	29 d0                	sub    %edx,%eax
f01031a3:	eb f3                	jmp    f0103198 <strncmp+0x38>

f01031a5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01031a5:	55                   	push   %ebp
f01031a6:	89 e5                	mov    %esp,%ebp
f01031a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01031ab:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01031ae:	8a 10                	mov    (%eax),%dl
f01031b0:	84 d2                	test   %dl,%dl
f01031b2:	74 18                	je     f01031cc <strchr+0x27>
		if (*s == c)
f01031b4:	38 ca                	cmp    %cl,%dl
f01031b6:	75 06                	jne    f01031be <strchr+0x19>
f01031b8:	eb 17                	jmp    f01031d1 <strchr+0x2c>
f01031ba:	38 ca                	cmp    %cl,%dl
f01031bc:	74 13                	je     f01031d1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01031be:	40                   	inc    %eax
f01031bf:	8a 10                	mov    (%eax),%dl
f01031c1:	84 d2                	test   %dl,%dl
f01031c3:	75 f5                	jne    f01031ba <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f01031c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01031ca:	eb 05                	jmp    f01031d1 <strchr+0x2c>
f01031cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031d1:	c9                   	leave  
f01031d2:	c3                   	ret    

f01031d3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01031d3:	55                   	push   %ebp
f01031d4:	89 e5                	mov    %esp,%ebp
f01031d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01031d9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01031dc:	8a 10                	mov    (%eax),%dl
f01031de:	84 d2                	test   %dl,%dl
f01031e0:	74 11                	je     f01031f3 <strfind+0x20>
		if (*s == c)
f01031e2:	38 ca                	cmp    %cl,%dl
f01031e4:	75 06                	jne    f01031ec <strfind+0x19>
f01031e6:	eb 0b                	jmp    f01031f3 <strfind+0x20>
f01031e8:	38 ca                	cmp    %cl,%dl
f01031ea:	74 07                	je     f01031f3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01031ec:	40                   	inc    %eax
f01031ed:	8a 10                	mov    (%eax),%dl
f01031ef:	84 d2                	test   %dl,%dl
f01031f1:	75 f5                	jne    f01031e8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f01031f3:	c9                   	leave  
f01031f4:	c3                   	ret    

f01031f5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01031f5:	55                   	push   %ebp
f01031f6:	89 e5                	mov    %esp,%ebp
f01031f8:	57                   	push   %edi
f01031f9:	56                   	push   %esi
f01031fa:	53                   	push   %ebx
f01031fb:	8b 7d 08             	mov    0x8(%ebp),%edi
f01031fe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103201:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103204:	85 c9                	test   %ecx,%ecx
f0103206:	74 30                	je     f0103238 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103208:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010320e:	75 25                	jne    f0103235 <memset+0x40>
f0103210:	f6 c1 03             	test   $0x3,%cl
f0103213:	75 20                	jne    f0103235 <memset+0x40>
		c &= 0xFF;
f0103215:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103218:	89 d3                	mov    %edx,%ebx
f010321a:	c1 e3 08             	shl    $0x8,%ebx
f010321d:	89 d6                	mov    %edx,%esi
f010321f:	c1 e6 18             	shl    $0x18,%esi
f0103222:	89 d0                	mov    %edx,%eax
f0103224:	c1 e0 10             	shl    $0x10,%eax
f0103227:	09 f0                	or     %esi,%eax
f0103229:	09 d0                	or     %edx,%eax
f010322b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010322d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103230:	fc                   	cld    
f0103231:	f3 ab                	rep stos %eax,%es:(%edi)
f0103233:	eb 03                	jmp    f0103238 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103235:	fc                   	cld    
f0103236:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103238:	89 f8                	mov    %edi,%eax
f010323a:	5b                   	pop    %ebx
f010323b:	5e                   	pop    %esi
f010323c:	5f                   	pop    %edi
f010323d:	c9                   	leave  
f010323e:	c3                   	ret    

f010323f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010323f:	55                   	push   %ebp
f0103240:	89 e5                	mov    %esp,%ebp
f0103242:	57                   	push   %edi
f0103243:	56                   	push   %esi
f0103244:	8b 45 08             	mov    0x8(%ebp),%eax
f0103247:	8b 75 0c             	mov    0xc(%ebp),%esi
f010324a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010324d:	39 c6                	cmp    %eax,%esi
f010324f:	73 34                	jae    f0103285 <memmove+0x46>
f0103251:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103254:	39 d0                	cmp    %edx,%eax
f0103256:	73 2d                	jae    f0103285 <memmove+0x46>
		s += n;
		d += n;
f0103258:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010325b:	f6 c2 03             	test   $0x3,%dl
f010325e:	75 1b                	jne    f010327b <memmove+0x3c>
f0103260:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103266:	75 13                	jne    f010327b <memmove+0x3c>
f0103268:	f6 c1 03             	test   $0x3,%cl
f010326b:	75 0e                	jne    f010327b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010326d:	83 ef 04             	sub    $0x4,%edi
f0103270:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103273:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0103276:	fd                   	std    
f0103277:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103279:	eb 07                	jmp    f0103282 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010327b:	4f                   	dec    %edi
f010327c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010327f:	fd                   	std    
f0103280:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103282:	fc                   	cld    
f0103283:	eb 20                	jmp    f01032a5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103285:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010328b:	75 13                	jne    f01032a0 <memmove+0x61>
f010328d:	a8 03                	test   $0x3,%al
f010328f:	75 0f                	jne    f01032a0 <memmove+0x61>
f0103291:	f6 c1 03             	test   $0x3,%cl
f0103294:	75 0a                	jne    f01032a0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103296:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0103299:	89 c7                	mov    %eax,%edi
f010329b:	fc                   	cld    
f010329c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010329e:	eb 05                	jmp    f01032a5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01032a0:	89 c7                	mov    %eax,%edi
f01032a2:	fc                   	cld    
f01032a3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01032a5:	5e                   	pop    %esi
f01032a6:	5f                   	pop    %edi
f01032a7:	c9                   	leave  
f01032a8:	c3                   	ret    

f01032a9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01032a9:	55                   	push   %ebp
f01032aa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01032ac:	ff 75 10             	pushl  0x10(%ebp)
f01032af:	ff 75 0c             	pushl  0xc(%ebp)
f01032b2:	ff 75 08             	pushl  0x8(%ebp)
f01032b5:	e8 85 ff ff ff       	call   f010323f <memmove>
}
f01032ba:	c9                   	leave  
f01032bb:	c3                   	ret    

f01032bc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01032bc:	55                   	push   %ebp
f01032bd:	89 e5                	mov    %esp,%ebp
f01032bf:	57                   	push   %edi
f01032c0:	56                   	push   %esi
f01032c1:	53                   	push   %ebx
f01032c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01032c5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01032c8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01032cb:	85 ff                	test   %edi,%edi
f01032cd:	74 32                	je     f0103301 <memcmp+0x45>
		if (*s1 != *s2)
f01032cf:	8a 03                	mov    (%ebx),%al
f01032d1:	8a 0e                	mov    (%esi),%cl
f01032d3:	38 c8                	cmp    %cl,%al
f01032d5:	74 19                	je     f01032f0 <memcmp+0x34>
f01032d7:	eb 0d                	jmp    f01032e6 <memcmp+0x2a>
f01032d9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f01032dd:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f01032e1:	42                   	inc    %edx
f01032e2:	38 c8                	cmp    %cl,%al
f01032e4:	74 10                	je     f01032f6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f01032e6:	0f b6 c0             	movzbl %al,%eax
f01032e9:	0f b6 c9             	movzbl %cl,%ecx
f01032ec:	29 c8                	sub    %ecx,%eax
f01032ee:	eb 16                	jmp    f0103306 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01032f0:	4f                   	dec    %edi
f01032f1:	ba 00 00 00 00       	mov    $0x0,%edx
f01032f6:	39 fa                	cmp    %edi,%edx
f01032f8:	75 df                	jne    f01032d9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01032fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01032ff:	eb 05                	jmp    f0103306 <memcmp+0x4a>
f0103301:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103306:	5b                   	pop    %ebx
f0103307:	5e                   	pop    %esi
f0103308:	5f                   	pop    %edi
f0103309:	c9                   	leave  
f010330a:	c3                   	ret    

f010330b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010330b:	55                   	push   %ebp
f010330c:	89 e5                	mov    %esp,%ebp
f010330e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103311:	89 c2                	mov    %eax,%edx
f0103313:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103316:	39 d0                	cmp    %edx,%eax
f0103318:	73 12                	jae    f010332c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f010331a:	8a 4d 0c             	mov    0xc(%ebp),%cl
f010331d:	38 08                	cmp    %cl,(%eax)
f010331f:	75 06                	jne    f0103327 <memfind+0x1c>
f0103321:	eb 09                	jmp    f010332c <memfind+0x21>
f0103323:	38 08                	cmp    %cl,(%eax)
f0103325:	74 05                	je     f010332c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103327:	40                   	inc    %eax
f0103328:	39 c2                	cmp    %eax,%edx
f010332a:	77 f7                	ja     f0103323 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010332c:	c9                   	leave  
f010332d:	c3                   	ret    

f010332e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010332e:	55                   	push   %ebp
f010332f:	89 e5                	mov    %esp,%ebp
f0103331:	57                   	push   %edi
f0103332:	56                   	push   %esi
f0103333:	53                   	push   %ebx
f0103334:	8b 55 08             	mov    0x8(%ebp),%edx
f0103337:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010333a:	eb 01                	jmp    f010333d <strtol+0xf>
		s++;
f010333c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010333d:	8a 02                	mov    (%edx),%al
f010333f:	3c 20                	cmp    $0x20,%al
f0103341:	74 f9                	je     f010333c <strtol+0xe>
f0103343:	3c 09                	cmp    $0x9,%al
f0103345:	74 f5                	je     f010333c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103347:	3c 2b                	cmp    $0x2b,%al
f0103349:	75 08                	jne    f0103353 <strtol+0x25>
		s++;
f010334b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010334c:	bf 00 00 00 00       	mov    $0x0,%edi
f0103351:	eb 13                	jmp    f0103366 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103353:	3c 2d                	cmp    $0x2d,%al
f0103355:	75 0a                	jne    f0103361 <strtol+0x33>
		s++, neg = 1;
f0103357:	8d 52 01             	lea    0x1(%edx),%edx
f010335a:	bf 01 00 00 00       	mov    $0x1,%edi
f010335f:	eb 05                	jmp    f0103366 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103361:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103366:	85 db                	test   %ebx,%ebx
f0103368:	74 05                	je     f010336f <strtol+0x41>
f010336a:	83 fb 10             	cmp    $0x10,%ebx
f010336d:	75 28                	jne    f0103397 <strtol+0x69>
f010336f:	8a 02                	mov    (%edx),%al
f0103371:	3c 30                	cmp    $0x30,%al
f0103373:	75 10                	jne    f0103385 <strtol+0x57>
f0103375:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103379:	75 0a                	jne    f0103385 <strtol+0x57>
		s += 2, base = 16;
f010337b:	83 c2 02             	add    $0x2,%edx
f010337e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103383:	eb 12                	jmp    f0103397 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0103385:	85 db                	test   %ebx,%ebx
f0103387:	75 0e                	jne    f0103397 <strtol+0x69>
f0103389:	3c 30                	cmp    $0x30,%al
f010338b:	75 05                	jne    f0103392 <strtol+0x64>
		s++, base = 8;
f010338d:	42                   	inc    %edx
f010338e:	b3 08                	mov    $0x8,%bl
f0103390:	eb 05                	jmp    f0103397 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0103392:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0103397:	b8 00 00 00 00       	mov    $0x0,%eax
f010339c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010339e:	8a 0a                	mov    (%edx),%cl
f01033a0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01033a3:	80 fb 09             	cmp    $0x9,%bl
f01033a6:	77 08                	ja     f01033b0 <strtol+0x82>
			dig = *s - '0';
f01033a8:	0f be c9             	movsbl %cl,%ecx
f01033ab:	83 e9 30             	sub    $0x30,%ecx
f01033ae:	eb 1e                	jmp    f01033ce <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01033b0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01033b3:	80 fb 19             	cmp    $0x19,%bl
f01033b6:	77 08                	ja     f01033c0 <strtol+0x92>
			dig = *s - 'a' + 10;
f01033b8:	0f be c9             	movsbl %cl,%ecx
f01033bb:	83 e9 57             	sub    $0x57,%ecx
f01033be:	eb 0e                	jmp    f01033ce <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01033c0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01033c3:	80 fb 19             	cmp    $0x19,%bl
f01033c6:	77 13                	ja     f01033db <strtol+0xad>
			dig = *s - 'A' + 10;
f01033c8:	0f be c9             	movsbl %cl,%ecx
f01033cb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01033ce:	39 f1                	cmp    %esi,%ecx
f01033d0:	7d 0d                	jge    f01033df <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f01033d2:	42                   	inc    %edx
f01033d3:	0f af c6             	imul   %esi,%eax
f01033d6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f01033d9:	eb c3                	jmp    f010339e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01033db:	89 c1                	mov    %eax,%ecx
f01033dd:	eb 02                	jmp    f01033e1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01033df:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01033e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01033e5:	74 05                	je     f01033ec <strtol+0xbe>
		*endptr = (char *) s;
f01033e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01033ea:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01033ec:	85 ff                	test   %edi,%edi
f01033ee:	74 04                	je     f01033f4 <strtol+0xc6>
f01033f0:	89 c8                	mov    %ecx,%eax
f01033f2:	f7 d8                	neg    %eax
}
f01033f4:	5b                   	pop    %ebx
f01033f5:	5e                   	pop    %esi
f01033f6:	5f                   	pop    %edi
f01033f7:	c9                   	leave  
f01033f8:	c3                   	ret    
f01033f9:	00 00                	add    %al,(%eax)
	...

f01033fc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01033fc:	55                   	push   %ebp
f01033fd:	89 e5                	mov    %esp,%ebp
f01033ff:	57                   	push   %edi
f0103400:	56                   	push   %esi
f0103401:	83 ec 10             	sub    $0x10,%esp
f0103404:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103407:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010340a:	89 7d f0             	mov    %edi,-0x10(%ebp)
f010340d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0103410:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103413:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103416:	85 c0                	test   %eax,%eax
f0103418:	75 2e                	jne    f0103448 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f010341a:	39 f1                	cmp    %esi,%ecx
f010341c:	77 5a                	ja     f0103478 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f010341e:	85 c9                	test   %ecx,%ecx
f0103420:	75 0b                	jne    f010342d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103422:	b8 01 00 00 00       	mov    $0x1,%eax
f0103427:	31 d2                	xor    %edx,%edx
f0103429:	f7 f1                	div    %ecx
f010342b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010342d:	31 d2                	xor    %edx,%edx
f010342f:	89 f0                	mov    %esi,%eax
f0103431:	f7 f1                	div    %ecx
f0103433:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103435:	89 f8                	mov    %edi,%eax
f0103437:	f7 f1                	div    %ecx
f0103439:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010343b:	89 f8                	mov    %edi,%eax
f010343d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010343f:	83 c4 10             	add    $0x10,%esp
f0103442:	5e                   	pop    %esi
f0103443:	5f                   	pop    %edi
f0103444:	c9                   	leave  
f0103445:	c3                   	ret    
f0103446:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103448:	39 f0                	cmp    %esi,%eax
f010344a:	77 1c                	ja     f0103468 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f010344c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f010344f:	83 f7 1f             	xor    $0x1f,%edi
f0103452:	75 3c                	jne    f0103490 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103454:	39 f0                	cmp    %esi,%eax
f0103456:	0f 82 90 00 00 00    	jb     f01034ec <__udivdi3+0xf0>
f010345c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010345f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0103462:	0f 86 84 00 00 00    	jbe    f01034ec <__udivdi3+0xf0>
f0103468:	31 f6                	xor    %esi,%esi
f010346a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010346c:	89 f8                	mov    %edi,%eax
f010346e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103470:	83 c4 10             	add    $0x10,%esp
f0103473:	5e                   	pop    %esi
f0103474:	5f                   	pop    %edi
f0103475:	c9                   	leave  
f0103476:	c3                   	ret    
f0103477:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103478:	89 f2                	mov    %esi,%edx
f010347a:	89 f8                	mov    %edi,%eax
f010347c:	f7 f1                	div    %ecx
f010347e:	89 c7                	mov    %eax,%edi
f0103480:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103482:	89 f8                	mov    %edi,%eax
f0103484:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103486:	83 c4 10             	add    $0x10,%esp
f0103489:	5e                   	pop    %esi
f010348a:	5f                   	pop    %edi
f010348b:	c9                   	leave  
f010348c:	c3                   	ret    
f010348d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103490:	89 f9                	mov    %edi,%ecx
f0103492:	d3 e0                	shl    %cl,%eax
f0103494:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103497:	b8 20 00 00 00       	mov    $0x20,%eax
f010349c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f010349e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01034a1:	88 c1                	mov    %al,%cl
f01034a3:	d3 ea                	shr    %cl,%edx
f01034a5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01034a8:	09 ca                	or     %ecx,%edx
f01034aa:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f01034ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01034b0:	89 f9                	mov    %edi,%ecx
f01034b2:	d3 e2                	shl    %cl,%edx
f01034b4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f01034b7:	89 f2                	mov    %esi,%edx
f01034b9:	88 c1                	mov    %al,%cl
f01034bb:	d3 ea                	shr    %cl,%edx
f01034bd:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f01034c0:	89 f2                	mov    %esi,%edx
f01034c2:	89 f9                	mov    %edi,%ecx
f01034c4:	d3 e2                	shl    %cl,%edx
f01034c6:	8b 75 f0             	mov    -0x10(%ebp),%esi
f01034c9:	88 c1                	mov    %al,%cl
f01034cb:	d3 ee                	shr    %cl,%esi
f01034cd:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01034cf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01034d2:	89 f0                	mov    %esi,%eax
f01034d4:	89 ca                	mov    %ecx,%edx
f01034d6:	f7 75 ec             	divl   -0x14(%ebp)
f01034d9:	89 d1                	mov    %edx,%ecx
f01034db:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01034dd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01034e0:	39 d1                	cmp    %edx,%ecx
f01034e2:	72 28                	jb     f010350c <__udivdi3+0x110>
f01034e4:	74 1a                	je     f0103500 <__udivdi3+0x104>
f01034e6:	89 f7                	mov    %esi,%edi
f01034e8:	31 f6                	xor    %esi,%esi
f01034ea:	eb 80                	jmp    f010346c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01034ec:	31 f6                	xor    %esi,%esi
f01034ee:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01034f3:	89 f8                	mov    %edi,%eax
f01034f5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01034f7:	83 c4 10             	add    $0x10,%esp
f01034fa:	5e                   	pop    %esi
f01034fb:	5f                   	pop    %edi
f01034fc:	c9                   	leave  
f01034fd:	c3                   	ret    
f01034fe:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0103500:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103503:	89 f9                	mov    %edi,%ecx
f0103505:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103507:	39 c2                	cmp    %eax,%edx
f0103509:	73 db                	jae    f01034e6 <__udivdi3+0xea>
f010350b:	90                   	nop
		{
		  q0--;
f010350c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f010350f:	31 f6                	xor    %esi,%esi
f0103511:	e9 56 ff ff ff       	jmp    f010346c <__udivdi3+0x70>
	...

f0103518 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0103518:	55                   	push   %ebp
f0103519:	89 e5                	mov    %esp,%ebp
f010351b:	57                   	push   %edi
f010351c:	56                   	push   %esi
f010351d:	83 ec 20             	sub    $0x20,%esp
f0103520:	8b 45 08             	mov    0x8(%ebp),%eax
f0103523:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0103526:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0103529:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f010352c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010352f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0103532:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0103535:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103537:	85 ff                	test   %edi,%edi
f0103539:	75 15                	jne    f0103550 <__umoddi3+0x38>
    {
      if (d0 > n1)
f010353b:	39 f1                	cmp    %esi,%ecx
f010353d:	0f 86 99 00 00 00    	jbe    f01035dc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103543:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0103545:	89 d0                	mov    %edx,%eax
f0103547:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103549:	83 c4 20             	add    $0x20,%esp
f010354c:	5e                   	pop    %esi
f010354d:	5f                   	pop    %edi
f010354e:	c9                   	leave  
f010354f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103550:	39 f7                	cmp    %esi,%edi
f0103552:	0f 87 a4 00 00 00    	ja     f01035fc <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103558:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f010355b:	83 f0 1f             	xor    $0x1f,%eax
f010355e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103561:	0f 84 a1 00 00 00    	je     f0103608 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103567:	89 f8                	mov    %edi,%eax
f0103569:	8a 4d ec             	mov    -0x14(%ebp),%cl
f010356c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010356e:	bf 20 00 00 00       	mov    $0x20,%edi
f0103573:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0103576:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103579:	89 f9                	mov    %edi,%ecx
f010357b:	d3 ea                	shr    %cl,%edx
f010357d:	09 c2                	or     %eax,%edx
f010357f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0103582:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103585:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103588:	d3 e0                	shl    %cl,%eax
f010358a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f010358d:	89 f2                	mov    %esi,%edx
f010358f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0103591:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103594:	d3 e0                	shl    %cl,%eax
f0103596:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103599:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010359c:	89 f9                	mov    %edi,%ecx
f010359e:	d3 e8                	shr    %cl,%eax
f01035a0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f01035a2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01035a4:	89 f2                	mov    %esi,%edx
f01035a6:	f7 75 f0             	divl   -0x10(%ebp)
f01035a9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01035ab:	f7 65 f4             	mull   -0xc(%ebp)
f01035ae:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01035b1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01035b3:	39 d6                	cmp    %edx,%esi
f01035b5:	72 71                	jb     f0103628 <__umoddi3+0x110>
f01035b7:	74 7f                	je     f0103638 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01035b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035bc:	29 c8                	sub    %ecx,%eax
f01035be:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01035c0:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01035c3:	d3 e8                	shr    %cl,%eax
f01035c5:	89 f2                	mov    %esi,%edx
f01035c7:	89 f9                	mov    %edi,%ecx
f01035c9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01035cb:	09 d0                	or     %edx,%eax
f01035cd:	89 f2                	mov    %esi,%edx
f01035cf:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01035d2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01035d4:	83 c4 20             	add    $0x20,%esp
f01035d7:	5e                   	pop    %esi
f01035d8:	5f                   	pop    %edi
f01035d9:	c9                   	leave  
f01035da:	c3                   	ret    
f01035db:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01035dc:	85 c9                	test   %ecx,%ecx
f01035de:	75 0b                	jne    f01035eb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01035e0:	b8 01 00 00 00       	mov    $0x1,%eax
f01035e5:	31 d2                	xor    %edx,%edx
f01035e7:	f7 f1                	div    %ecx
f01035e9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01035eb:	89 f0                	mov    %esi,%eax
f01035ed:	31 d2                	xor    %edx,%edx
f01035ef:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01035f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01035f4:	f7 f1                	div    %ecx
f01035f6:	e9 4a ff ff ff       	jmp    f0103545 <__umoddi3+0x2d>
f01035fb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f01035fc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01035fe:	83 c4 20             	add    $0x20,%esp
f0103601:	5e                   	pop    %esi
f0103602:	5f                   	pop    %edi
f0103603:	c9                   	leave  
f0103604:	c3                   	ret    
f0103605:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103608:	39 f7                	cmp    %esi,%edi
f010360a:	72 05                	jb     f0103611 <__umoddi3+0xf9>
f010360c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f010360f:	77 0c                	ja     f010361d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103611:	89 f2                	mov    %esi,%edx
f0103613:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103616:	29 c8                	sub    %ecx,%eax
f0103618:	19 fa                	sbb    %edi,%edx
f010361a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f010361d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103620:	83 c4 20             	add    $0x20,%esp
f0103623:	5e                   	pop    %esi
f0103624:	5f                   	pop    %edi
f0103625:	c9                   	leave  
f0103626:	c3                   	ret    
f0103627:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103628:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010362b:	89 c1                	mov    %eax,%ecx
f010362d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0103630:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0103633:	eb 84                	jmp    f01035b9 <__umoddi3+0xa1>
f0103635:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103638:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f010363b:	72 eb                	jb     f0103628 <__umoddi3+0x110>
f010363d:	89 f2                	mov    %esi,%edx
f010363f:	e9 75 ff ff ff       	jmp    f01035b9 <__umoddi3+0xa1>
