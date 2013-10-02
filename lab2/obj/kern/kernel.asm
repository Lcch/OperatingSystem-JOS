
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
f0100058:	e8 cc 30 00 00       	call   f0103129 <memset>

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
f010006a:	68 80 35 10 f0       	push   $0xf0103580
f010006f:	e8 85 25 00 00       	call   f01025f9 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 9c 0f 00 00       	call   f0101015 <mem_init>
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
f01000b0:	68 9b 35 10 f0       	push   $0xf010359b
f01000b5:	e8 3f 25 00 00       	call   f01025f9 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 0f 25 00 00       	call   f01025d3 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 2d 46 10 f0 	movl   $0xf010462d,(%esp)
f01000cb:	e8 29 25 00 00       	call   f01025f9 <cprintf>
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
f01000f2:	68 b3 35 10 f0       	push   $0xf01035b3
f01000f7:	e8 fd 24 00 00       	call   f01025f9 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 cb 24 00 00       	call   f01025d3 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 2d 46 10 f0 	movl   $0xf010462d,(%esp)
f010010f:	e8 e5 24 00 00       	call   f01025f9 <cprintf>
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
f01002fd:	e8 71 2e 00 00       	call   f0103173 <memmove>
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
f010039c:	8a 82 00 36 10 f0    	mov    -0xfefca00(%edx),%al
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
f01003d8:	0f b6 82 00 36 10 f0 	movzbl -0xfefca00(%edx),%eax
f01003df:	0b 05 28 d5 11 f0    	or     0xf011d528,%eax
	shift ^= togglecode[data];
f01003e5:	0f b6 8a 00 37 10 f0 	movzbl -0xfefc900(%edx),%ecx
f01003ec:	31 c8                	xor    %ecx,%eax
f01003ee:	a3 28 d5 11 f0       	mov    %eax,0xf011d528

	c = charcode[shift & (CTL | SHIFT)][data];
f01003f3:	89 c1                	mov    %eax,%ecx
f01003f5:	83 e1 03             	and    $0x3,%ecx
f01003f8:	8b 0c 8d 00 38 10 f0 	mov    -0xfefc800(,%ecx,4),%ecx
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
f0100430:	68 cd 35 10 f0       	push   $0xf01035cd
f0100435:	e8 bf 21 00 00       	call   f01025f9 <cprintf>
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
f0100591:	68 d9 35 10 f0       	push   $0xf01035d9
f0100596:	e8 5e 20 00 00       	call   f01025f9 <cprintf>
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
f01005da:	68 10 38 10 f0       	push   $0xf0103810
f01005df:	e8 15 20 00 00       	call   f01025f9 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005e4:	83 c4 08             	add    $0x8,%esp
f01005e7:	68 0c 00 10 00       	push   $0x10000c
f01005ec:	68 08 39 10 f0       	push   $0xf0103908
f01005f1:	e8 03 20 00 00       	call   f01025f9 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01005f6:	83 c4 0c             	add    $0xc,%esp
f01005f9:	68 0c 00 10 00       	push   $0x10000c
f01005fe:	68 0c 00 10 f0       	push   $0xf010000c
f0100603:	68 30 39 10 f0       	push   $0xf0103930
f0100608:	e8 ec 1f 00 00       	call   f01025f9 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010060d:	83 c4 0c             	add    $0xc,%esp
f0100610:	68 78 35 10 00       	push   $0x103578
f0100615:	68 78 35 10 f0       	push   $0xf0103578
f010061a:	68 54 39 10 f0       	push   $0xf0103954
f010061f:	e8 d5 1f 00 00       	call   f01025f9 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100624:	83 c4 0c             	add    $0xc,%esp
f0100627:	68 00 d3 11 00       	push   $0x11d300
f010062c:	68 00 d3 11 f0       	push   $0xf011d300
f0100631:	68 78 39 10 f0       	push   $0xf0103978
f0100636:	e8 be 1f 00 00       	call   f01025f9 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010063b:	83 c4 0c             	add    $0xc,%esp
f010063e:	68 50 d9 11 00       	push   $0x11d950
f0100643:	68 50 d9 11 f0       	push   $0xf011d950
f0100648:	68 9c 39 10 f0       	push   $0xf010399c
f010064d:	e8 a7 1f 00 00       	call   f01025f9 <cprintf>
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
f0100674:	68 c0 39 10 f0       	push   $0xf01039c0
f0100679:	e8 7b 1f 00 00       	call   f01025f9 <cprintf>
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
f010068b:	ff 35 44 3c 10 f0    	pushl  0xf0103c44
f0100691:	ff 35 40 3c 10 f0    	pushl  0xf0103c40
f0100697:	68 29 38 10 f0       	push   $0xf0103829
f010069c:	e8 58 1f 00 00       	call   f01025f9 <cprintf>
f01006a1:	83 c4 0c             	add    $0xc,%esp
f01006a4:	ff 35 50 3c 10 f0    	pushl  0xf0103c50
f01006aa:	ff 35 4c 3c 10 f0    	pushl  0xf0103c4c
f01006b0:	68 29 38 10 f0       	push   $0xf0103829
f01006b5:	e8 3f 1f 00 00       	call   f01025f9 <cprintf>
f01006ba:	83 c4 0c             	add    $0xc,%esp
f01006bd:	ff 35 5c 3c 10 f0    	pushl  0xf0103c5c
f01006c3:	ff 35 58 3c 10 f0    	pushl  0xf0103c58
f01006c9:	68 29 38 10 f0       	push   $0xf0103829
f01006ce:	e8 26 1f 00 00       	call   f01025f9 <cprintf>
f01006d3:	83 c4 0c             	add    $0xc,%esp
f01006d6:	ff 35 68 3c 10 f0    	pushl  0xf0103c68
f01006dc:	ff 35 64 3c 10 f0    	pushl  0xf0103c64
f01006e2:	68 29 38 10 f0       	push   $0xf0103829
f01006e7:	e8 0d 1f 00 00       	call   f01025f9 <cprintf>
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
f0100704:	68 ec 39 10 f0       	push   $0xf01039ec
f0100709:	e8 eb 1e 00 00       	call   f01025f9 <cprintf>
        cprintf("num show the color attribute. \n");
f010070e:	c7 04 24 1c 3a 10 f0 	movl   $0xf0103a1c,(%esp)
f0100715:	e8 df 1e 00 00       	call   f01025f9 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f010071a:	c7 04 24 3c 3a 10 f0 	movl   $0xf0103a3c,(%esp)
f0100721:	e8 d3 1e 00 00       	call   f01025f9 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100726:	c7 04 24 70 3a 10 f0 	movl   $0xf0103a70,(%esp)
f010072d:	e8 c7 1e 00 00       	call   f01025f9 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100732:	c7 04 24 b4 3a 10 f0 	movl   $0xf0103ab4,(%esp)
f0100739:	e8 bb 1e 00 00       	call   f01025f9 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f010073e:	c7 04 24 32 38 10 f0 	movl   $0xf0103832,(%esp)
f0100745:	e8 af 1e 00 00       	call   f01025f9 <cprintf>
        cprintf("         set the background color to black\n");
f010074a:	c7 04 24 f8 3a 10 f0 	movl   $0xf0103af8,(%esp)
f0100751:	e8 a3 1e 00 00       	call   f01025f9 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100756:	c7 04 24 24 3b 10 f0 	movl   $0xf0103b24,(%esp)
f010075d:	e8 97 1e 00 00       	call   f01025f9 <cprintf>
f0100762:	83 c4 10             	add    $0x10,%esp
f0100765:	eb 52                	jmp    f01007b9 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100767:	83 ec 0c             	sub    $0xc,%esp
f010076a:	ff 73 04             	pushl  0x4(%ebx)
f010076d:	e8 ee 27 00 00       	call   f0102f60 <strlen>
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
f01007ac:	68 58 3b 10 f0       	push   $0xf0103b58
f01007b1:	e8 43 1e 00 00       	call   f01025f9 <cprintf>
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
f01007ed:	68 7c 3b 10 f0       	push   $0xf0103b7c
f01007f2:	e8 02 1e 00 00       	call   f01025f9 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f01007f7:	83 c4 18             	add    $0x18,%esp
f01007fa:	57                   	push   %edi
f01007fb:	ff 76 04             	pushl  0x4(%esi)
f01007fe:	e8 32 1f 00 00       	call   f0102735 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100803:	83 c4 0c             	add    $0xc,%esp
f0100806:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100809:	ff 75 d0             	pushl  -0x30(%ebp)
f010080c:	68 4e 38 10 f0       	push   $0xf010384e
f0100811:	e8 e3 1d 00 00       	call   f01025f9 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100816:	83 c4 0c             	add    $0xc,%esp
f0100819:	ff 75 d8             	pushl  -0x28(%ebp)
f010081c:	ff 75 dc             	pushl  -0x24(%ebp)
f010081f:	68 5e 38 10 f0       	push   $0xf010385e
f0100824:	e8 d0 1d 00 00       	call   f01025f9 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100829:	83 c4 08             	add    $0x8,%esp
f010082c:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f010082f:	53                   	push   %ebx
f0100830:	68 63 38 10 f0       	push   $0xf0103863
f0100835:	e8 bf 1d 00 00       	call   f01025f9 <cprintf>
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
f0100859:	68 b4 3b 10 f0       	push   $0xf0103bb4
f010085e:	e8 96 1d 00 00       	call   f01025f9 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100863:	c7 04 24 d8 3b 10 f0 	movl   $0xf0103bd8,(%esp)
f010086a:	e8 8a 1d 00 00       	call   f01025f9 <cprintf>
f010086f:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100872:	83 ec 0c             	sub    $0xc,%esp
f0100875:	68 68 38 10 f0       	push   $0xf0103868
f010087a:	e8 11 26 00 00       	call   f0102e90 <readline>
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
f01008a7:	68 6c 38 10 f0       	push   $0xf010386c
f01008ac:	e8 28 28 00 00       	call   f01030d9 <strchr>
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
f01008c7:	68 71 38 10 f0       	push   $0xf0103871
f01008cc:	e8 28 1d 00 00       	call   f01025f9 <cprintf>
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
f01008f1:	68 6c 38 10 f0       	push   $0xf010386c
f01008f6:	e8 de 27 00 00       	call   f01030d9 <strchr>
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
f0100914:	bb 40 3c 10 f0       	mov    $0xf0103c40,%ebx
f0100919:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010091e:	83 ec 08             	sub    $0x8,%esp
f0100921:	ff 33                	pushl  (%ebx)
f0100923:	ff 75 a8             	pushl  -0x58(%ebp)
f0100926:	e8 40 27 00 00       	call   f010306b <strcmp>
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
f0100940:	ff 97 48 3c 10 f0    	call   *-0xfefc3b8(%edi)


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
f0100961:	68 8e 38 10 f0       	push   $0xf010388e
f0100966:	e8 8e 1c 00 00       	call   f01025f9 <cprintf>
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
f01009d8:	68 70 3c 10 f0       	push   $0xf0103c70
f01009dd:	68 b4 02 00 00       	push   $0x2b4
f01009e2:	68 8c 43 10 f0       	push   $0xf010438c
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
f0100a20:	e8 73 1b 00 00       	call   f0102598 <mc146818_read>
f0100a25:	89 c6                	mov    %eax,%esi
f0100a27:	43                   	inc    %ebx
f0100a28:	89 1c 24             	mov    %ebx,(%esp)
f0100a2b:	e8 68 1b 00 00       	call   f0102598 <mc146818_read>
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
f0100a5d:	68 94 3c 10 f0       	push   $0xf0103c94
f0100a62:	68 f7 01 00 00       	push   $0x1f7
f0100a67:	68 8c 43 10 f0       	push   $0xf010438c
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
f0100aea:	68 70 3c 10 f0       	push   $0xf0103c70
f0100aef:	6a 52                	push   $0x52
f0100af1:	68 98 43 10 f0       	push   $0xf0104398
f0100af6:	e8 90 f5 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100afb:	83 ec 04             	sub    $0x4,%esp
f0100afe:	68 80 00 00 00       	push   $0x80
f0100b03:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100b08:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b0d:	50                   	push   %eax
f0100b0e:	e8 16 26 00 00       	call   f0103129 <memset>
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
f0100b84:	68 a6 43 10 f0       	push   $0xf01043a6
f0100b89:	68 b2 43 10 f0       	push   $0xf01043b2
f0100b8e:	68 11 02 00 00       	push   $0x211
f0100b93:	68 8c 43 10 f0       	push   $0xf010438c
f0100b98:	e8 ee f4 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100b9d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100ba0:	72 19                	jb     f0100bbb <check_page_free_list+0x17f>
f0100ba2:	68 c7 43 10 f0       	push   $0xf01043c7
f0100ba7:	68 b2 43 10 f0       	push   $0xf01043b2
f0100bac:	68 12 02 00 00       	push   $0x212
f0100bb1:	68 8c 43 10 f0       	push   $0xf010438c
f0100bb6:	e8 d0 f4 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bbb:	89 d0                	mov    %edx,%eax
f0100bbd:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100bc0:	a8 07                	test   $0x7,%al
f0100bc2:	74 19                	je     f0100bdd <check_page_free_list+0x1a1>
f0100bc4:	68 b8 3c 10 f0       	push   $0xf0103cb8
f0100bc9:	68 b2 43 10 f0       	push   $0xf01043b2
f0100bce:	68 13 02 00 00       	push   $0x213
f0100bd3:	68 8c 43 10 f0       	push   $0xf010438c
f0100bd8:	e8 ae f4 ff ff       	call   f010008b <_panic>
f0100bdd:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100be0:	c1 e0 0c             	shl    $0xc,%eax
f0100be3:	75 19                	jne    f0100bfe <check_page_free_list+0x1c2>
f0100be5:	68 db 43 10 f0       	push   $0xf01043db
f0100bea:	68 b2 43 10 f0       	push   $0xf01043b2
f0100bef:	68 16 02 00 00       	push   $0x216
f0100bf4:	68 8c 43 10 f0       	push   $0xf010438c
f0100bf9:	e8 8d f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bfe:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c03:	75 19                	jne    f0100c1e <check_page_free_list+0x1e2>
f0100c05:	68 ec 43 10 f0       	push   $0xf01043ec
f0100c0a:	68 b2 43 10 f0       	push   $0xf01043b2
f0100c0f:	68 17 02 00 00       	push   $0x217
f0100c14:	68 8c 43 10 f0       	push   $0xf010438c
f0100c19:	e8 6d f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c1e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c23:	75 19                	jne    f0100c3e <check_page_free_list+0x202>
f0100c25:	68 ec 3c 10 f0       	push   $0xf0103cec
f0100c2a:	68 b2 43 10 f0       	push   $0xf01043b2
f0100c2f:	68 18 02 00 00       	push   $0x218
f0100c34:	68 8c 43 10 f0       	push   $0xf010438c
f0100c39:	e8 4d f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c3e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c43:	75 19                	jne    f0100c5e <check_page_free_list+0x222>
f0100c45:	68 05 44 10 f0       	push   $0xf0104405
f0100c4a:	68 b2 43 10 f0       	push   $0xf01043b2
f0100c4f:	68 19 02 00 00       	push   $0x219
f0100c54:	68 8c 43 10 f0       	push   $0xf010438c
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
f0100c70:	68 70 3c 10 f0       	push   $0xf0103c70
f0100c75:	6a 52                	push   $0x52
f0100c77:	68 98 43 10 f0       	push   $0xf0104398
f0100c7c:	e8 0a f4 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0100c81:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0100c87:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100c8a:	76 1c                	jbe    f0100ca8 <check_page_free_list+0x26c>
f0100c8c:	68 10 3d 10 f0       	push   $0xf0103d10
f0100c91:	68 b2 43 10 f0       	push   $0xf01043b2
f0100c96:	68 1a 02 00 00       	push   $0x21a
f0100c9b:	68 8c 43 10 f0       	push   $0xf010438c
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
f0100cb7:	68 1f 44 10 f0       	push   $0xf010441f
f0100cbc:	68 b2 43 10 f0       	push   $0xf01043b2
f0100cc1:	68 22 02 00 00       	push   $0x222
f0100cc6:	68 8c 43 10 f0       	push   $0xf010438c
f0100ccb:	e8 bb f3 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100cd0:	85 f6                	test   %esi,%esi
f0100cd2:	7f 19                	jg     f0100ced <check_page_free_list+0x2b1>
f0100cd4:	68 31 44 10 f0       	push   $0xf0104431
f0100cd9:	68 b2 43 10 f0       	push   $0xf01043b2
f0100cde:	68 23 02 00 00       	push   $0x223
f0100ce3:	68 8c 43 10 f0       	push   $0xf010438c
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
f0100d16:	68 58 3d 10 f0       	push   $0xf0103d58
f0100d1b:	68 02 01 00 00       	push   $0x102
f0100d20:	68 8c 43 10 f0       	push   $0xf010438c
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
f0100ddc:	68 70 3c 10 f0       	push   $0xf0103c70
f0100de1:	6a 52                	push   $0x52
f0100de3:	68 98 43 10 f0       	push   $0xf0104398
f0100de8:	e8 9e f2 ff ff       	call   f010008b <_panic>
            memset(page2kva(alloc_page), 0, PGSIZE);
f0100ded:	83 ec 04             	sub    $0x4,%esp
f0100df0:	68 00 10 00 00       	push   $0x1000
f0100df5:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100df7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100dfc:	50                   	push   %eax
f0100dfd:	e8 27 23 00 00       	call   f0103129 <memset>
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
f0100ea8:	68 70 3c 10 f0       	push   $0xf0103c70
f0100ead:	68 63 01 00 00       	push   $0x163
f0100eb2:	68 8c 43 10 f0       	push   $0xf010438c
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

f0100ee1 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100ee1:	55                   	push   %ebp
f0100ee2:	89 e5                	mov    %esp,%ebp
f0100ee4:	53                   	push   %ebx
f0100ee5:	83 ec 10             	sub    $0x10,%esp
f0100ee8:	8b 5d 10             	mov    0x10(%ebp),%ebx
    cprintf("page_lookup\n");
f0100eeb:	68 42 44 10 f0       	push   $0xf0104442
f0100ef0:	e8 04 17 00 00       	call   f01025f9 <cprintf>
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f0100ef5:	83 c4 0c             	add    $0xc,%esp
f0100ef8:	6a 00                	push   $0x0
f0100efa:	ff 75 0c             	pushl  0xc(%ebp)
f0100efd:	ff 75 08             	pushl  0x8(%ebp)
f0100f00:	e8 45 ff ff ff       	call   f0100e4a <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0100f05:	83 c4 10             	add    $0x10,%esp
f0100f08:	85 c0                	test   %eax,%eax
f0100f0a:	74 37                	je     f0100f43 <page_lookup+0x62>
f0100f0c:	f6 00 01             	testb  $0x1,(%eax)
f0100f0f:	74 39                	je     f0100f4a <page_lookup+0x69>
    if (pte_store != 0) {
f0100f11:	85 db                	test   %ebx,%ebx
f0100f13:	74 02                	je     f0100f17 <page_lookup+0x36>
        *pte_store = pte;
f0100f15:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f0100f17:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f19:	c1 e8 0c             	shr    $0xc,%eax
f0100f1c:	3b 05 44 d9 11 f0    	cmp    0xf011d944,%eax
f0100f22:	72 14                	jb     f0100f38 <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0100f24:	83 ec 04             	sub    $0x4,%esp
f0100f27:	68 7c 3d 10 f0       	push   $0xf0103d7c
f0100f2c:	6a 4b                	push   $0x4b
f0100f2e:	68 98 43 10 f0       	push   $0xf0104398
f0100f33:	e8 53 f1 ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0100f38:	c1 e0 03             	shl    $0x3,%eax
f0100f3b:	03 05 4c d9 11 f0    	add    0xf011d94c,%eax
f0100f41:	eb 0c                	jmp    f0100f4f <page_lookup+0x6e>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0100f43:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f48:	eb 05                	jmp    f0100f4f <page_lookup+0x6e>
f0100f4a:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f0100f4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f52:	c9                   	leave  
f0100f53:	c3                   	ret    

f0100f54 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100f54:	55                   	push   %ebp
f0100f55:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100f57:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f5a:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100f5d:	c9                   	leave  
f0100f5e:	c3                   	ret    

f0100f5f <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f5f:	55                   	push   %ebp
f0100f60:	89 e5                	mov    %esp,%ebp
f0100f62:	56                   	push   %esi
f0100f63:	53                   	push   %ebx
f0100f64:	83 ec 14             	sub    $0x14,%esp
f0100f67:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f0100f6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f70:	50                   	push   %eax
f0100f71:	53                   	push   %ebx
f0100f72:	56                   	push   %esi
f0100f73:	e8 69 ff ff ff       	call   f0100ee1 <page_lookup>
    if (pg == NULL) return;
f0100f78:	83 c4 10             	add    $0x10,%esp
f0100f7b:	85 c0                	test   %eax,%eax
f0100f7d:	74 26                	je     f0100fa5 <page_remove+0x46>
    page_decref(pg);
f0100f7f:	83 ec 0c             	sub    $0xc,%esp
f0100f82:	50                   	push   %eax
f0100f83:	e8 a4 fe ff ff       	call   f0100e2c <page_decref>
    if (pte != NULL) *pte = 0;
f0100f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f8b:	83 c4 10             	add    $0x10,%esp
f0100f8e:	85 c0                	test   %eax,%eax
f0100f90:	74 06                	je     f0100f98 <page_remove+0x39>
f0100f92:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f0100f98:	83 ec 08             	sub    $0x8,%esp
f0100f9b:	53                   	push   %ebx
f0100f9c:	56                   	push   %esi
f0100f9d:	e8 b2 ff ff ff       	call   f0100f54 <tlb_invalidate>
f0100fa2:	83 c4 10             	add    $0x10,%esp
}
f0100fa5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fa8:	5b                   	pop    %ebx
f0100fa9:	5e                   	pop    %esi
f0100faa:	c9                   	leave  
f0100fab:	c3                   	ret    

f0100fac <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100fac:	55                   	push   %ebp
f0100fad:	89 e5                	mov    %esp,%ebp
f0100faf:	57                   	push   %edi
f0100fb0:	56                   	push   %esi
f0100fb1:	53                   	push   %ebx
f0100fb2:	83 ec 10             	sub    $0x10,%esp
f0100fb5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100fb8:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f0100fbb:	6a 01                	push   $0x1
f0100fbd:	57                   	push   %edi
f0100fbe:	ff 75 08             	pushl  0x8(%ebp)
f0100fc1:	e8 84 fe ff ff       	call   f0100e4a <pgdir_walk>
f0100fc6:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f0100fc8:	83 c4 10             	add    $0x10,%esp
f0100fcb:	85 c0                	test   %eax,%eax
f0100fcd:	74 39                	je     f0101008 <page_insert+0x5c>
    ++pp->pp_ref;
f0100fcf:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f0100fd3:	f6 00 01             	testb  $0x1,(%eax)
f0100fd6:	74 0f                	je     f0100fe7 <page_insert+0x3b>
        page_remove(pgdir, va);
f0100fd8:	83 ec 08             	sub    $0x8,%esp
f0100fdb:	57                   	push   %edi
f0100fdc:	ff 75 08             	pushl  0x8(%ebp)
f0100fdf:	e8 7b ff ff ff       	call   f0100f5f <page_remove>
f0100fe4:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f0100fe7:	8b 55 14             	mov    0x14(%ebp),%edx
f0100fea:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fed:	2b 35 4c d9 11 f0    	sub    0xf011d94c,%esi
f0100ff3:	c1 fe 03             	sar    $0x3,%esi
f0100ff6:	89 f0                	mov    %esi,%eax
f0100ff8:	c1 e0 0c             	shl    $0xc,%eax
f0100ffb:	89 d6                	mov    %edx,%esi
f0100ffd:	09 c6                	or     %eax,%esi
f0100fff:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101001:	b8 00 00 00 00       	mov    $0x0,%eax
f0101006:	eb 05                	jmp    f010100d <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f0101008:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f010100d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101010:	5b                   	pop    %ebx
f0101011:	5e                   	pop    %esi
f0101012:	5f                   	pop    %edi
f0101013:	c9                   	leave  
f0101014:	c3                   	ret    

f0101015 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101015:	55                   	push   %ebp
f0101016:	89 e5                	mov    %esp,%ebp
f0101018:	57                   	push   %edi
f0101019:	56                   	push   %esi
f010101a:	53                   	push   %ebx
f010101b:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010101e:	b8 15 00 00 00       	mov    $0x15,%eax
f0101023:	e8 ed f9 ff ff       	call   f0100a15 <nvram_read>
f0101028:	c1 e0 0a             	shl    $0xa,%eax
f010102b:	89 c2                	mov    %eax,%edx
f010102d:	85 c0                	test   %eax,%eax
f010102f:	79 06                	jns    f0101037 <mem_init+0x22>
f0101031:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101037:	c1 fa 0c             	sar    $0xc,%edx
f010103a:	89 15 34 d5 11 f0    	mov    %edx,0xf011d534
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101040:	b8 17 00 00 00       	mov    $0x17,%eax
f0101045:	e8 cb f9 ff ff       	call   f0100a15 <nvram_read>
f010104a:	89 c2                	mov    %eax,%edx
f010104c:	c1 e2 0a             	shl    $0xa,%edx
f010104f:	89 d0                	mov    %edx,%eax
f0101051:	85 d2                	test   %edx,%edx
f0101053:	79 06                	jns    f010105b <mem_init+0x46>
f0101055:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010105b:	c1 f8 0c             	sar    $0xc,%eax
f010105e:	74 0e                	je     f010106e <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101060:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101066:	89 15 44 d9 11 f0    	mov    %edx,0xf011d944
f010106c:	eb 0c                	jmp    f010107a <mem_init+0x65>
	else
		npages = npages_basemem;
f010106e:	8b 15 34 d5 11 f0    	mov    0xf011d534,%edx
f0101074:	89 15 44 d9 11 f0    	mov    %edx,0xf011d944

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010107a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010107d:	c1 e8 0a             	shr    $0xa,%eax
f0101080:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101081:	a1 34 d5 11 f0       	mov    0xf011d534,%eax
f0101086:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101089:	c1 e8 0a             	shr    $0xa,%eax
f010108c:	50                   	push   %eax
		npages * PGSIZE / 1024,
f010108d:	a1 44 d9 11 f0       	mov    0xf011d944,%eax
f0101092:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101095:	c1 e8 0a             	shr    $0xa,%eax
f0101098:	50                   	push   %eax
f0101099:	68 9c 3d 10 f0       	push   $0xf0103d9c
f010109e:	e8 56 15 00 00       	call   f01025f9 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01010a3:	b8 00 10 00 00       	mov    $0x1000,%eax
f01010a8:	e8 cf f8 ff ff       	call   f010097c <boot_alloc>
f01010ad:	a3 48 d9 11 f0       	mov    %eax,0xf011d948
	memset(kern_pgdir, 0, PGSIZE);
f01010b2:	83 c4 0c             	add    $0xc,%esp
f01010b5:	68 00 10 00 00       	push   $0x1000
f01010ba:	6a 00                	push   $0x0
f01010bc:	50                   	push   %eax
f01010bd:	e8 67 20 00 00       	call   f0103129 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01010c2:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01010c7:	83 c4 10             	add    $0x10,%esp
f01010ca:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010cf:	77 15                	ja     f01010e6 <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010d1:	50                   	push   %eax
f01010d2:	68 58 3d 10 f0       	push   $0xf0103d58
f01010d7:	68 8d 00 00 00       	push   $0x8d
f01010dc:	68 8c 43 10 f0       	push   $0xf010438c
f01010e1:	e8 a5 ef ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f01010e6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01010ec:	83 ca 05             	or     $0x5,%edx
f01010ef:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01010f5:	a1 44 d9 11 f0       	mov    0xf011d944,%eax
f01010fa:	c1 e0 03             	shl    $0x3,%eax
f01010fd:	e8 7a f8 ff ff       	call   f010097c <boot_alloc>
f0101102:	a3 4c d9 11 f0       	mov    %eax,0xf011d94c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101107:	e8 e9 fb ff ff       	call   f0100cf5 <page_init>

	check_page_free_list(1);
f010110c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101111:	e8 26 f9 ff ff       	call   f0100a3c <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101116:	83 3d 4c d9 11 f0 00 	cmpl   $0x0,0xf011d94c
f010111d:	75 17                	jne    f0101136 <mem_init+0x121>
		panic("'pages' is a null pointer!");
f010111f:	83 ec 04             	sub    $0x4,%esp
f0101122:	68 4f 44 10 f0       	push   $0xf010444f
f0101127:	68 34 02 00 00       	push   $0x234
f010112c:	68 8c 43 10 f0       	push   $0xf010438c
f0101131:	e8 55 ef ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101136:	a1 2c d5 11 f0       	mov    0xf011d52c,%eax
f010113b:	85 c0                	test   %eax,%eax
f010113d:	74 0e                	je     f010114d <mem_init+0x138>
f010113f:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101144:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101145:	8b 00                	mov    (%eax),%eax
f0101147:	85 c0                	test   %eax,%eax
f0101149:	75 f9                	jne    f0101144 <mem_init+0x12f>
f010114b:	eb 05                	jmp    f0101152 <mem_init+0x13d>
f010114d:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101152:	83 ec 0c             	sub    $0xc,%esp
f0101155:	6a 00                	push   $0x0
f0101157:	e8 46 fc ff ff       	call   f0100da2 <page_alloc>
f010115c:	89 c6                	mov    %eax,%esi
f010115e:	83 c4 10             	add    $0x10,%esp
f0101161:	85 c0                	test   %eax,%eax
f0101163:	75 19                	jne    f010117e <mem_init+0x169>
f0101165:	68 6a 44 10 f0       	push   $0xf010446a
f010116a:	68 b2 43 10 f0       	push   $0xf01043b2
f010116f:	68 3c 02 00 00       	push   $0x23c
f0101174:	68 8c 43 10 f0       	push   $0xf010438c
f0101179:	e8 0d ef ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010117e:	83 ec 0c             	sub    $0xc,%esp
f0101181:	6a 00                	push   $0x0
f0101183:	e8 1a fc ff ff       	call   f0100da2 <page_alloc>
f0101188:	89 c7                	mov    %eax,%edi
f010118a:	83 c4 10             	add    $0x10,%esp
f010118d:	85 c0                	test   %eax,%eax
f010118f:	75 19                	jne    f01011aa <mem_init+0x195>
f0101191:	68 80 44 10 f0       	push   $0xf0104480
f0101196:	68 b2 43 10 f0       	push   $0xf01043b2
f010119b:	68 3d 02 00 00       	push   $0x23d
f01011a0:	68 8c 43 10 f0       	push   $0xf010438c
f01011a5:	e8 e1 ee ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01011aa:	83 ec 0c             	sub    $0xc,%esp
f01011ad:	6a 00                	push   $0x0
f01011af:	e8 ee fb ff ff       	call   f0100da2 <page_alloc>
f01011b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011b7:	83 c4 10             	add    $0x10,%esp
f01011ba:	85 c0                	test   %eax,%eax
f01011bc:	75 19                	jne    f01011d7 <mem_init+0x1c2>
f01011be:	68 96 44 10 f0       	push   $0xf0104496
f01011c3:	68 b2 43 10 f0       	push   $0xf01043b2
f01011c8:	68 3e 02 00 00       	push   $0x23e
f01011cd:	68 8c 43 10 f0       	push   $0xf010438c
f01011d2:	e8 b4 ee ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01011d7:	39 fe                	cmp    %edi,%esi
f01011d9:	75 19                	jne    f01011f4 <mem_init+0x1df>
f01011db:	68 ac 44 10 f0       	push   $0xf01044ac
f01011e0:	68 b2 43 10 f0       	push   $0xf01043b2
f01011e5:	68 41 02 00 00       	push   $0x241
f01011ea:	68 8c 43 10 f0       	push   $0xf010438c
f01011ef:	e8 97 ee ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01011f4:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01011f7:	74 05                	je     f01011fe <mem_init+0x1e9>
f01011f9:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01011fc:	75 19                	jne    f0101217 <mem_init+0x202>
f01011fe:	68 d8 3d 10 f0       	push   $0xf0103dd8
f0101203:	68 b2 43 10 f0       	push   $0xf01043b2
f0101208:	68 42 02 00 00       	push   $0x242
f010120d:	68 8c 43 10 f0       	push   $0xf010438c
f0101212:	e8 74 ee ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101217:	8b 15 4c d9 11 f0    	mov    0xf011d94c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010121d:	a1 44 d9 11 f0       	mov    0xf011d944,%eax
f0101222:	c1 e0 0c             	shl    $0xc,%eax
f0101225:	89 f1                	mov    %esi,%ecx
f0101227:	29 d1                	sub    %edx,%ecx
f0101229:	c1 f9 03             	sar    $0x3,%ecx
f010122c:	c1 e1 0c             	shl    $0xc,%ecx
f010122f:	39 c1                	cmp    %eax,%ecx
f0101231:	72 19                	jb     f010124c <mem_init+0x237>
f0101233:	68 be 44 10 f0       	push   $0xf01044be
f0101238:	68 b2 43 10 f0       	push   $0xf01043b2
f010123d:	68 43 02 00 00       	push   $0x243
f0101242:	68 8c 43 10 f0       	push   $0xf010438c
f0101247:	e8 3f ee ff ff       	call   f010008b <_panic>
f010124c:	89 f9                	mov    %edi,%ecx
f010124e:	29 d1                	sub    %edx,%ecx
f0101250:	c1 f9 03             	sar    $0x3,%ecx
f0101253:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101256:	39 c8                	cmp    %ecx,%eax
f0101258:	77 19                	ja     f0101273 <mem_init+0x25e>
f010125a:	68 db 44 10 f0       	push   $0xf01044db
f010125f:	68 b2 43 10 f0       	push   $0xf01043b2
f0101264:	68 44 02 00 00       	push   $0x244
f0101269:	68 8c 43 10 f0       	push   $0xf010438c
f010126e:	e8 18 ee ff ff       	call   f010008b <_panic>
f0101273:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101276:	29 d1                	sub    %edx,%ecx
f0101278:	89 ca                	mov    %ecx,%edx
f010127a:	c1 fa 03             	sar    $0x3,%edx
f010127d:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101280:	39 d0                	cmp    %edx,%eax
f0101282:	77 19                	ja     f010129d <mem_init+0x288>
f0101284:	68 f8 44 10 f0       	push   $0xf01044f8
f0101289:	68 b2 43 10 f0       	push   $0xf01043b2
f010128e:	68 45 02 00 00       	push   $0x245
f0101293:	68 8c 43 10 f0       	push   $0xf010438c
f0101298:	e8 ee ed ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010129d:	a1 2c d5 11 f0       	mov    0xf011d52c,%eax
f01012a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01012a5:	c7 05 2c d5 11 f0 00 	movl   $0x0,0xf011d52c
f01012ac:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01012af:	83 ec 0c             	sub    $0xc,%esp
f01012b2:	6a 00                	push   $0x0
f01012b4:	e8 e9 fa ff ff       	call   f0100da2 <page_alloc>
f01012b9:	83 c4 10             	add    $0x10,%esp
f01012bc:	85 c0                	test   %eax,%eax
f01012be:	74 19                	je     f01012d9 <mem_init+0x2c4>
f01012c0:	68 15 45 10 f0       	push   $0xf0104515
f01012c5:	68 b2 43 10 f0       	push   $0xf01043b2
f01012ca:	68 4c 02 00 00       	push   $0x24c
f01012cf:	68 8c 43 10 f0       	push   $0xf010438c
f01012d4:	e8 b2 ed ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f01012d9:	83 ec 0c             	sub    $0xc,%esp
f01012dc:	56                   	push   %esi
f01012dd:	e8 2a fb ff ff       	call   f0100e0c <page_free>
	page_free(pp1);
f01012e2:	89 3c 24             	mov    %edi,(%esp)
f01012e5:	e8 22 fb ff ff       	call   f0100e0c <page_free>
	page_free(pp2);
f01012ea:	83 c4 04             	add    $0x4,%esp
f01012ed:	ff 75 d4             	pushl  -0x2c(%ebp)
f01012f0:	e8 17 fb ff ff       	call   f0100e0c <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01012f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012fc:	e8 a1 fa ff ff       	call   f0100da2 <page_alloc>
f0101301:	89 c6                	mov    %eax,%esi
f0101303:	83 c4 10             	add    $0x10,%esp
f0101306:	85 c0                	test   %eax,%eax
f0101308:	75 19                	jne    f0101323 <mem_init+0x30e>
f010130a:	68 6a 44 10 f0       	push   $0xf010446a
f010130f:	68 b2 43 10 f0       	push   $0xf01043b2
f0101314:	68 53 02 00 00       	push   $0x253
f0101319:	68 8c 43 10 f0       	push   $0xf010438c
f010131e:	e8 68 ed ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101323:	83 ec 0c             	sub    $0xc,%esp
f0101326:	6a 00                	push   $0x0
f0101328:	e8 75 fa ff ff       	call   f0100da2 <page_alloc>
f010132d:	89 c7                	mov    %eax,%edi
f010132f:	83 c4 10             	add    $0x10,%esp
f0101332:	85 c0                	test   %eax,%eax
f0101334:	75 19                	jne    f010134f <mem_init+0x33a>
f0101336:	68 80 44 10 f0       	push   $0xf0104480
f010133b:	68 b2 43 10 f0       	push   $0xf01043b2
f0101340:	68 54 02 00 00       	push   $0x254
f0101345:	68 8c 43 10 f0       	push   $0xf010438c
f010134a:	e8 3c ed ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010134f:	83 ec 0c             	sub    $0xc,%esp
f0101352:	6a 00                	push   $0x0
f0101354:	e8 49 fa ff ff       	call   f0100da2 <page_alloc>
f0101359:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010135c:	83 c4 10             	add    $0x10,%esp
f010135f:	85 c0                	test   %eax,%eax
f0101361:	75 19                	jne    f010137c <mem_init+0x367>
f0101363:	68 96 44 10 f0       	push   $0xf0104496
f0101368:	68 b2 43 10 f0       	push   $0xf01043b2
f010136d:	68 55 02 00 00       	push   $0x255
f0101372:	68 8c 43 10 f0       	push   $0xf010438c
f0101377:	e8 0f ed ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010137c:	39 fe                	cmp    %edi,%esi
f010137e:	75 19                	jne    f0101399 <mem_init+0x384>
f0101380:	68 ac 44 10 f0       	push   $0xf01044ac
f0101385:	68 b2 43 10 f0       	push   $0xf01043b2
f010138a:	68 57 02 00 00       	push   $0x257
f010138f:	68 8c 43 10 f0       	push   $0xf010438c
f0101394:	e8 f2 ec ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101399:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010139c:	74 05                	je     f01013a3 <mem_init+0x38e>
f010139e:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01013a1:	75 19                	jne    f01013bc <mem_init+0x3a7>
f01013a3:	68 d8 3d 10 f0       	push   $0xf0103dd8
f01013a8:	68 b2 43 10 f0       	push   $0xf01043b2
f01013ad:	68 58 02 00 00       	push   $0x258
f01013b2:	68 8c 43 10 f0       	push   $0xf010438c
f01013b7:	e8 cf ec ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f01013bc:	83 ec 0c             	sub    $0xc,%esp
f01013bf:	6a 00                	push   $0x0
f01013c1:	e8 dc f9 ff ff       	call   f0100da2 <page_alloc>
f01013c6:	83 c4 10             	add    $0x10,%esp
f01013c9:	85 c0                	test   %eax,%eax
f01013cb:	74 19                	je     f01013e6 <mem_init+0x3d1>
f01013cd:	68 15 45 10 f0       	push   $0xf0104515
f01013d2:	68 b2 43 10 f0       	push   $0xf01043b2
f01013d7:	68 59 02 00 00       	push   $0x259
f01013dc:	68 8c 43 10 f0       	push   $0xf010438c
f01013e1:	e8 a5 ec ff ff       	call   f010008b <_panic>
f01013e6:	89 f0                	mov    %esi,%eax
f01013e8:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
f01013ee:	c1 f8 03             	sar    $0x3,%eax
f01013f1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013f4:	89 c2                	mov    %eax,%edx
f01013f6:	c1 ea 0c             	shr    $0xc,%edx
f01013f9:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f01013ff:	72 12                	jb     f0101413 <mem_init+0x3fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101401:	50                   	push   %eax
f0101402:	68 70 3c 10 f0       	push   $0xf0103c70
f0101407:	6a 52                	push   $0x52
f0101409:	68 98 43 10 f0       	push   $0xf0104398
f010140e:	e8 78 ec ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101413:	83 ec 04             	sub    $0x4,%esp
f0101416:	68 00 10 00 00       	push   $0x1000
f010141b:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010141d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101422:	50                   	push   %eax
f0101423:	e8 01 1d 00 00       	call   f0103129 <memset>
	page_free(pp0);
f0101428:	89 34 24             	mov    %esi,(%esp)
f010142b:	e8 dc f9 ff ff       	call   f0100e0c <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101430:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101437:	e8 66 f9 ff ff       	call   f0100da2 <page_alloc>
f010143c:	83 c4 10             	add    $0x10,%esp
f010143f:	85 c0                	test   %eax,%eax
f0101441:	75 19                	jne    f010145c <mem_init+0x447>
f0101443:	68 24 45 10 f0       	push   $0xf0104524
f0101448:	68 b2 43 10 f0       	push   $0xf01043b2
f010144d:	68 5e 02 00 00       	push   $0x25e
f0101452:	68 8c 43 10 f0       	push   $0xf010438c
f0101457:	e8 2f ec ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f010145c:	39 c6                	cmp    %eax,%esi
f010145e:	74 19                	je     f0101479 <mem_init+0x464>
f0101460:	68 42 45 10 f0       	push   $0xf0104542
f0101465:	68 b2 43 10 f0       	push   $0xf01043b2
f010146a:	68 5f 02 00 00       	push   $0x25f
f010146f:	68 8c 43 10 f0       	push   $0xf010438c
f0101474:	e8 12 ec ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101479:	89 f2                	mov    %esi,%edx
f010147b:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101481:	c1 fa 03             	sar    $0x3,%edx
f0101484:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101487:	89 d0                	mov    %edx,%eax
f0101489:	c1 e8 0c             	shr    $0xc,%eax
f010148c:	3b 05 44 d9 11 f0    	cmp    0xf011d944,%eax
f0101492:	72 12                	jb     f01014a6 <mem_init+0x491>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101494:	52                   	push   %edx
f0101495:	68 70 3c 10 f0       	push   $0xf0103c70
f010149a:	6a 52                	push   $0x52
f010149c:	68 98 43 10 f0       	push   $0xf0104398
f01014a1:	e8 e5 eb ff ff       	call   f010008b <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01014a6:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f01014ad:	75 11                	jne    f01014c0 <mem_init+0x4ab>
f01014af:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01014b5:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01014bb:	80 38 00             	cmpb   $0x0,(%eax)
f01014be:	74 19                	je     f01014d9 <mem_init+0x4c4>
f01014c0:	68 52 45 10 f0       	push   $0xf0104552
f01014c5:	68 b2 43 10 f0       	push   $0xf01043b2
f01014ca:	68 62 02 00 00       	push   $0x262
f01014cf:	68 8c 43 10 f0       	push   $0xf010438c
f01014d4:	e8 b2 eb ff ff       	call   f010008b <_panic>
f01014d9:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01014da:	39 d0                	cmp    %edx,%eax
f01014dc:	75 dd                	jne    f01014bb <mem_init+0x4a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01014de:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01014e1:	89 15 2c d5 11 f0    	mov    %edx,0xf011d52c

	// free the pages we took
	page_free(pp0);
f01014e7:	83 ec 0c             	sub    $0xc,%esp
f01014ea:	56                   	push   %esi
f01014eb:	e8 1c f9 ff ff       	call   f0100e0c <page_free>
	page_free(pp1);
f01014f0:	89 3c 24             	mov    %edi,(%esp)
f01014f3:	e8 14 f9 ff ff       	call   f0100e0c <page_free>
	page_free(pp2);
f01014f8:	83 c4 04             	add    $0x4,%esp
f01014fb:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014fe:	e8 09 f9 ff ff       	call   f0100e0c <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101503:	a1 2c d5 11 f0       	mov    0xf011d52c,%eax
f0101508:	83 c4 10             	add    $0x10,%esp
f010150b:	85 c0                	test   %eax,%eax
f010150d:	74 07                	je     f0101516 <mem_init+0x501>
		--nfree;
f010150f:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101510:	8b 00                	mov    (%eax),%eax
f0101512:	85 c0                	test   %eax,%eax
f0101514:	75 f9                	jne    f010150f <mem_init+0x4fa>
		--nfree;
	assert(nfree == 0);
f0101516:	85 db                	test   %ebx,%ebx
f0101518:	74 19                	je     f0101533 <mem_init+0x51e>
f010151a:	68 5c 45 10 f0       	push   $0xf010455c
f010151f:	68 b2 43 10 f0       	push   $0xf01043b2
f0101524:	68 6f 02 00 00       	push   $0x26f
f0101529:	68 8c 43 10 f0       	push   $0xf010438c
f010152e:	e8 58 eb ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101533:	83 ec 0c             	sub    $0xc,%esp
f0101536:	68 f8 3d 10 f0       	push   $0xf0103df8
f010153b:	e8 b9 10 00 00       	call   f01025f9 <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	cprintf("!\n");
f0101540:	c7 04 24 2c 46 10 f0 	movl   $0xf010462c,(%esp)
f0101547:	e8 ad 10 00 00       	call   f01025f9 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010154c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101553:	e8 4a f8 ff ff       	call   f0100da2 <page_alloc>
f0101558:	89 c6                	mov    %eax,%esi
f010155a:	83 c4 10             	add    $0x10,%esp
f010155d:	85 c0                	test   %eax,%eax
f010155f:	75 19                	jne    f010157a <mem_init+0x565>
f0101561:	68 6a 44 10 f0       	push   $0xf010446a
f0101566:	68 b2 43 10 f0       	push   $0xf01043b2
f010156b:	68 c8 02 00 00       	push   $0x2c8
f0101570:	68 8c 43 10 f0       	push   $0xf010438c
f0101575:	e8 11 eb ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010157a:	83 ec 0c             	sub    $0xc,%esp
f010157d:	6a 00                	push   $0x0
f010157f:	e8 1e f8 ff ff       	call   f0100da2 <page_alloc>
f0101584:	89 c7                	mov    %eax,%edi
f0101586:	83 c4 10             	add    $0x10,%esp
f0101589:	85 c0                	test   %eax,%eax
f010158b:	75 19                	jne    f01015a6 <mem_init+0x591>
f010158d:	68 80 44 10 f0       	push   $0xf0104480
f0101592:	68 b2 43 10 f0       	push   $0xf01043b2
f0101597:	68 c9 02 00 00       	push   $0x2c9
f010159c:	68 8c 43 10 f0       	push   $0xf010438c
f01015a1:	e8 e5 ea ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01015a6:	83 ec 0c             	sub    $0xc,%esp
f01015a9:	6a 00                	push   $0x0
f01015ab:	e8 f2 f7 ff ff       	call   f0100da2 <page_alloc>
f01015b0:	89 c3                	mov    %eax,%ebx
f01015b2:	83 c4 10             	add    $0x10,%esp
f01015b5:	85 c0                	test   %eax,%eax
f01015b7:	75 19                	jne    f01015d2 <mem_init+0x5bd>
f01015b9:	68 96 44 10 f0       	push   $0xf0104496
f01015be:	68 b2 43 10 f0       	push   $0xf01043b2
f01015c3:	68 ca 02 00 00       	push   $0x2ca
f01015c8:	68 8c 43 10 f0       	push   $0xf010438c
f01015cd:	e8 b9 ea ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015d2:	39 fe                	cmp    %edi,%esi
f01015d4:	75 19                	jne    f01015ef <mem_init+0x5da>
f01015d6:	68 ac 44 10 f0       	push   $0xf01044ac
f01015db:	68 b2 43 10 f0       	push   $0xf01043b2
f01015e0:	68 cd 02 00 00       	push   $0x2cd
f01015e5:	68 8c 43 10 f0       	push   $0xf010438c
f01015ea:	e8 9c ea ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015ef:	39 c7                	cmp    %eax,%edi
f01015f1:	74 04                	je     f01015f7 <mem_init+0x5e2>
f01015f3:	39 c6                	cmp    %eax,%esi
f01015f5:	75 19                	jne    f0101610 <mem_init+0x5fb>
f01015f7:	68 d8 3d 10 f0       	push   $0xf0103dd8
f01015fc:	68 b2 43 10 f0       	push   $0xf01043b2
f0101601:	68 ce 02 00 00       	push   $0x2ce
f0101606:	68 8c 43 10 f0       	push   $0xf010438c
f010160b:	e8 7b ea ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101610:	8b 0d 2c d5 11 f0    	mov    0xf011d52c,%ecx
f0101616:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101619:	c7 05 2c d5 11 f0 00 	movl   $0x0,0xf011d52c
f0101620:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101623:	83 ec 0c             	sub    $0xc,%esp
f0101626:	6a 00                	push   $0x0
f0101628:	e8 75 f7 ff ff       	call   f0100da2 <page_alloc>
f010162d:	83 c4 10             	add    $0x10,%esp
f0101630:	85 c0                	test   %eax,%eax
f0101632:	74 19                	je     f010164d <mem_init+0x638>
f0101634:	68 15 45 10 f0       	push   $0xf0104515
f0101639:	68 b2 43 10 f0       	push   $0xf01043b2
f010163e:	68 d5 02 00 00       	push   $0x2d5
f0101643:	68 8c 43 10 f0       	push   $0xf010438c
f0101648:	e8 3e ea ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010164d:	83 ec 04             	sub    $0x4,%esp
f0101650:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101653:	50                   	push   %eax
f0101654:	6a 00                	push   $0x0
f0101656:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f010165c:	e8 80 f8 ff ff       	call   f0100ee1 <page_lookup>
f0101661:	83 c4 10             	add    $0x10,%esp
f0101664:	85 c0                	test   %eax,%eax
f0101666:	74 19                	je     f0101681 <mem_init+0x66c>
f0101668:	68 18 3e 10 f0       	push   $0xf0103e18
f010166d:	68 b2 43 10 f0       	push   $0xf01043b2
f0101672:	68 d8 02 00 00       	push   $0x2d8
f0101677:	68 8c 43 10 f0       	push   $0xf010438c
f010167c:	e8 0a ea ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101681:	6a 02                	push   $0x2
f0101683:	6a 00                	push   $0x0
f0101685:	57                   	push   %edi
f0101686:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f010168c:	e8 1b f9 ff ff       	call   f0100fac <page_insert>
f0101691:	83 c4 10             	add    $0x10,%esp
f0101694:	85 c0                	test   %eax,%eax
f0101696:	78 19                	js     f01016b1 <mem_init+0x69c>
f0101698:	68 50 3e 10 f0       	push   $0xf0103e50
f010169d:	68 b2 43 10 f0       	push   $0xf01043b2
f01016a2:	68 db 02 00 00       	push   $0x2db
f01016a7:	68 8c 43 10 f0       	push   $0xf010438c
f01016ac:	e8 da e9 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01016b1:	83 ec 0c             	sub    $0xc,%esp
f01016b4:	56                   	push   %esi
f01016b5:	e8 52 f7 ff ff       	call   f0100e0c <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01016ba:	6a 02                	push   $0x2
f01016bc:	6a 00                	push   $0x0
f01016be:	57                   	push   %edi
f01016bf:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f01016c5:	e8 e2 f8 ff ff       	call   f0100fac <page_insert>
f01016ca:	83 c4 20             	add    $0x20,%esp
f01016cd:	85 c0                	test   %eax,%eax
f01016cf:	74 19                	je     f01016ea <mem_init+0x6d5>
f01016d1:	68 80 3e 10 f0       	push   $0xf0103e80
f01016d6:	68 b2 43 10 f0       	push   $0xf01043b2
f01016db:	68 df 02 00 00       	push   $0x2df
f01016e0:	68 8c 43 10 f0       	push   $0xf010438c
f01016e5:	e8 a1 e9 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01016ea:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f01016ef:	8b 08                	mov    (%eax),%ecx
f01016f1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016f7:	89 f2                	mov    %esi,%edx
f01016f9:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f01016ff:	c1 fa 03             	sar    $0x3,%edx
f0101702:	c1 e2 0c             	shl    $0xc,%edx
f0101705:	39 d1                	cmp    %edx,%ecx
f0101707:	74 19                	je     f0101722 <mem_init+0x70d>
f0101709:	68 b0 3e 10 f0       	push   $0xf0103eb0
f010170e:	68 b2 43 10 f0       	push   $0xf01043b2
f0101713:	68 e0 02 00 00       	push   $0x2e0
f0101718:	68 8c 43 10 f0       	push   $0xf010438c
f010171d:	e8 69 e9 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101722:	ba 00 00 00 00       	mov    $0x0,%edx
f0101727:	e8 87 f2 ff ff       	call   f01009b3 <check_va2pa>
f010172c:	89 fa                	mov    %edi,%edx
f010172e:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101734:	c1 fa 03             	sar    $0x3,%edx
f0101737:	c1 e2 0c             	shl    $0xc,%edx
f010173a:	39 d0                	cmp    %edx,%eax
f010173c:	74 19                	je     f0101757 <mem_init+0x742>
f010173e:	68 d8 3e 10 f0       	push   $0xf0103ed8
f0101743:	68 b2 43 10 f0       	push   $0xf01043b2
f0101748:	68 e1 02 00 00       	push   $0x2e1
f010174d:	68 8c 43 10 f0       	push   $0xf010438c
f0101752:	e8 34 e9 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101757:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010175c:	74 19                	je     f0101777 <mem_init+0x762>
f010175e:	68 67 45 10 f0       	push   $0xf0104567
f0101763:	68 b2 43 10 f0       	push   $0xf01043b2
f0101768:	68 e2 02 00 00       	push   $0x2e2
f010176d:	68 8c 43 10 f0       	push   $0xf010438c
f0101772:	e8 14 e9 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0101777:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010177c:	74 19                	je     f0101797 <mem_init+0x782>
f010177e:	68 78 45 10 f0       	push   $0xf0104578
f0101783:	68 b2 43 10 f0       	push   $0xf01043b2
f0101788:	68 e3 02 00 00       	push   $0x2e3
f010178d:	68 8c 43 10 f0       	push   $0xf010438c
f0101792:	e8 f4 e8 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101797:	6a 02                	push   $0x2
f0101799:	68 00 10 00 00       	push   $0x1000
f010179e:	53                   	push   %ebx
f010179f:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f01017a5:	e8 02 f8 ff ff       	call   f0100fac <page_insert>
f01017aa:	83 c4 10             	add    $0x10,%esp
f01017ad:	85 c0                	test   %eax,%eax
f01017af:	74 19                	je     f01017ca <mem_init+0x7b5>
f01017b1:	68 08 3f 10 f0       	push   $0xf0103f08
f01017b6:	68 b2 43 10 f0       	push   $0xf01043b2
f01017bb:	68 e6 02 00 00       	push   $0x2e6
f01017c0:	68 8c 43 10 f0       	push   $0xf010438c
f01017c5:	e8 c1 e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01017ca:	ba 00 10 00 00       	mov    $0x1000,%edx
f01017cf:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f01017d4:	e8 da f1 ff ff       	call   f01009b3 <check_va2pa>
f01017d9:	89 da                	mov    %ebx,%edx
f01017db:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f01017e1:	c1 fa 03             	sar    $0x3,%edx
f01017e4:	c1 e2 0c             	shl    $0xc,%edx
f01017e7:	39 d0                	cmp    %edx,%eax
f01017e9:	74 19                	je     f0101804 <mem_init+0x7ef>
f01017eb:	68 44 3f 10 f0       	push   $0xf0103f44
f01017f0:	68 b2 43 10 f0       	push   $0xf01043b2
f01017f5:	68 e7 02 00 00       	push   $0x2e7
f01017fa:	68 8c 43 10 f0       	push   $0xf010438c
f01017ff:	e8 87 e8 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101804:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101809:	74 19                	je     f0101824 <mem_init+0x80f>
f010180b:	68 89 45 10 f0       	push   $0xf0104589
f0101810:	68 b2 43 10 f0       	push   $0xf01043b2
f0101815:	68 e8 02 00 00       	push   $0x2e8
f010181a:	68 8c 43 10 f0       	push   $0xf010438c
f010181f:	e8 67 e8 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101824:	83 ec 0c             	sub    $0xc,%esp
f0101827:	6a 00                	push   $0x0
f0101829:	e8 74 f5 ff ff       	call   f0100da2 <page_alloc>
f010182e:	83 c4 10             	add    $0x10,%esp
f0101831:	85 c0                	test   %eax,%eax
f0101833:	74 19                	je     f010184e <mem_init+0x839>
f0101835:	68 15 45 10 f0       	push   $0xf0104515
f010183a:	68 b2 43 10 f0       	push   $0xf01043b2
f010183f:	68 eb 02 00 00       	push   $0x2eb
f0101844:	68 8c 43 10 f0       	push   $0xf010438c
f0101849:	e8 3d e8 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010184e:	6a 02                	push   $0x2
f0101850:	68 00 10 00 00       	push   $0x1000
f0101855:	53                   	push   %ebx
f0101856:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f010185c:	e8 4b f7 ff ff       	call   f0100fac <page_insert>
f0101861:	83 c4 10             	add    $0x10,%esp
f0101864:	85 c0                	test   %eax,%eax
f0101866:	74 19                	je     f0101881 <mem_init+0x86c>
f0101868:	68 08 3f 10 f0       	push   $0xf0103f08
f010186d:	68 b2 43 10 f0       	push   $0xf01043b2
f0101872:	68 ee 02 00 00       	push   $0x2ee
f0101877:	68 8c 43 10 f0       	push   $0xf010438c
f010187c:	e8 0a e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101881:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101886:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f010188b:	e8 23 f1 ff ff       	call   f01009b3 <check_va2pa>
f0101890:	89 da                	mov    %ebx,%edx
f0101892:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101898:	c1 fa 03             	sar    $0x3,%edx
f010189b:	c1 e2 0c             	shl    $0xc,%edx
f010189e:	39 d0                	cmp    %edx,%eax
f01018a0:	74 19                	je     f01018bb <mem_init+0x8a6>
f01018a2:	68 44 3f 10 f0       	push   $0xf0103f44
f01018a7:	68 b2 43 10 f0       	push   $0xf01043b2
f01018ac:	68 ef 02 00 00       	push   $0x2ef
f01018b1:	68 8c 43 10 f0       	push   $0xf010438c
f01018b6:	e8 d0 e7 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01018bb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01018c0:	74 19                	je     f01018db <mem_init+0x8c6>
f01018c2:	68 89 45 10 f0       	push   $0xf0104589
f01018c7:	68 b2 43 10 f0       	push   $0xf01043b2
f01018cc:	68 f0 02 00 00       	push   $0x2f0
f01018d1:	68 8c 43 10 f0       	push   $0xf010438c
f01018d6:	e8 b0 e7 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01018db:	83 ec 0c             	sub    $0xc,%esp
f01018de:	6a 00                	push   $0x0
f01018e0:	e8 bd f4 ff ff       	call   f0100da2 <page_alloc>
f01018e5:	83 c4 10             	add    $0x10,%esp
f01018e8:	85 c0                	test   %eax,%eax
f01018ea:	74 19                	je     f0101905 <mem_init+0x8f0>
f01018ec:	68 15 45 10 f0       	push   $0xf0104515
f01018f1:	68 b2 43 10 f0       	push   $0xf01043b2
f01018f6:	68 f4 02 00 00       	push   $0x2f4
f01018fb:	68 8c 43 10 f0       	push   $0xf010438c
f0101900:	e8 86 e7 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101905:	8b 15 48 d9 11 f0    	mov    0xf011d948,%edx
f010190b:	8b 02                	mov    (%edx),%eax
f010190d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101912:	89 c1                	mov    %eax,%ecx
f0101914:	c1 e9 0c             	shr    $0xc,%ecx
f0101917:	3b 0d 44 d9 11 f0    	cmp    0xf011d944,%ecx
f010191d:	72 15                	jb     f0101934 <mem_init+0x91f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010191f:	50                   	push   %eax
f0101920:	68 70 3c 10 f0       	push   $0xf0103c70
f0101925:	68 f7 02 00 00       	push   $0x2f7
f010192a:	68 8c 43 10 f0       	push   $0xf010438c
f010192f:	e8 57 e7 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101934:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101939:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010193c:	83 ec 04             	sub    $0x4,%esp
f010193f:	6a 00                	push   $0x0
f0101941:	68 00 10 00 00       	push   $0x1000
f0101946:	52                   	push   %edx
f0101947:	e8 fe f4 ff ff       	call   f0100e4a <pgdir_walk>
f010194c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010194f:	83 c2 04             	add    $0x4,%edx
f0101952:	83 c4 10             	add    $0x10,%esp
f0101955:	39 d0                	cmp    %edx,%eax
f0101957:	74 19                	je     f0101972 <mem_init+0x95d>
f0101959:	68 74 3f 10 f0       	push   $0xf0103f74
f010195e:	68 b2 43 10 f0       	push   $0xf01043b2
f0101963:	68 f8 02 00 00       	push   $0x2f8
f0101968:	68 8c 43 10 f0       	push   $0xf010438c
f010196d:	e8 19 e7 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101972:	6a 06                	push   $0x6
f0101974:	68 00 10 00 00       	push   $0x1000
f0101979:	53                   	push   %ebx
f010197a:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101980:	e8 27 f6 ff ff       	call   f0100fac <page_insert>
f0101985:	83 c4 10             	add    $0x10,%esp
f0101988:	85 c0                	test   %eax,%eax
f010198a:	74 19                	je     f01019a5 <mem_init+0x990>
f010198c:	68 b4 3f 10 f0       	push   $0xf0103fb4
f0101991:	68 b2 43 10 f0       	push   $0xf01043b2
f0101996:	68 fb 02 00 00       	push   $0x2fb
f010199b:	68 8c 43 10 f0       	push   $0xf010438c
f01019a0:	e8 e6 e6 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019a5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019aa:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f01019af:	e8 ff ef ff ff       	call   f01009b3 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019b4:	89 da                	mov    %ebx,%edx
f01019b6:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f01019bc:	c1 fa 03             	sar    $0x3,%edx
f01019bf:	c1 e2 0c             	shl    $0xc,%edx
f01019c2:	39 d0                	cmp    %edx,%eax
f01019c4:	74 19                	je     f01019df <mem_init+0x9ca>
f01019c6:	68 44 3f 10 f0       	push   $0xf0103f44
f01019cb:	68 b2 43 10 f0       	push   $0xf01043b2
f01019d0:	68 fc 02 00 00       	push   $0x2fc
f01019d5:	68 8c 43 10 f0       	push   $0xf010438c
f01019da:	e8 ac e6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01019df:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019e4:	74 19                	je     f01019ff <mem_init+0x9ea>
f01019e6:	68 89 45 10 f0       	push   $0xf0104589
f01019eb:	68 b2 43 10 f0       	push   $0xf01043b2
f01019f0:	68 fd 02 00 00       	push   $0x2fd
f01019f5:	68 8c 43 10 f0       	push   $0xf010438c
f01019fa:	e8 8c e6 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01019ff:	83 ec 04             	sub    $0x4,%esp
f0101a02:	6a 00                	push   $0x0
f0101a04:	68 00 10 00 00       	push   $0x1000
f0101a09:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101a0f:	e8 36 f4 ff ff       	call   f0100e4a <pgdir_walk>
f0101a14:	83 c4 10             	add    $0x10,%esp
f0101a17:	f6 00 04             	testb  $0x4,(%eax)
f0101a1a:	75 19                	jne    f0101a35 <mem_init+0xa20>
f0101a1c:	68 f4 3f 10 f0       	push   $0xf0103ff4
f0101a21:	68 b2 43 10 f0       	push   $0xf01043b2
f0101a26:	68 fe 02 00 00       	push   $0x2fe
f0101a2b:	68 8c 43 10 f0       	push   $0xf010438c
f0101a30:	e8 56 e6 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101a35:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101a3a:	f6 00 04             	testb  $0x4,(%eax)
f0101a3d:	75 19                	jne    f0101a58 <mem_init+0xa43>
f0101a3f:	68 9a 45 10 f0       	push   $0xf010459a
f0101a44:	68 b2 43 10 f0       	push   $0xf01043b2
f0101a49:	68 ff 02 00 00       	push   $0x2ff
f0101a4e:	68 8c 43 10 f0       	push   $0xf010438c
f0101a53:	e8 33 e6 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a58:	6a 02                	push   $0x2
f0101a5a:	68 00 10 00 00       	push   $0x1000
f0101a5f:	53                   	push   %ebx
f0101a60:	50                   	push   %eax
f0101a61:	e8 46 f5 ff ff       	call   f0100fac <page_insert>
f0101a66:	83 c4 10             	add    $0x10,%esp
f0101a69:	85 c0                	test   %eax,%eax
f0101a6b:	74 19                	je     f0101a86 <mem_init+0xa71>
f0101a6d:	68 08 3f 10 f0       	push   $0xf0103f08
f0101a72:	68 b2 43 10 f0       	push   $0xf01043b2
f0101a77:	68 02 03 00 00       	push   $0x302
f0101a7c:	68 8c 43 10 f0       	push   $0xf010438c
f0101a81:	e8 05 e6 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101a86:	83 ec 04             	sub    $0x4,%esp
f0101a89:	6a 00                	push   $0x0
f0101a8b:	68 00 10 00 00       	push   $0x1000
f0101a90:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101a96:	e8 af f3 ff ff       	call   f0100e4a <pgdir_walk>
f0101a9b:	83 c4 10             	add    $0x10,%esp
f0101a9e:	f6 00 02             	testb  $0x2,(%eax)
f0101aa1:	75 19                	jne    f0101abc <mem_init+0xaa7>
f0101aa3:	68 28 40 10 f0       	push   $0xf0104028
f0101aa8:	68 b2 43 10 f0       	push   $0xf01043b2
f0101aad:	68 03 03 00 00       	push   $0x303
f0101ab2:	68 8c 43 10 f0       	push   $0xf010438c
f0101ab7:	e8 cf e5 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101abc:	83 ec 04             	sub    $0x4,%esp
f0101abf:	6a 00                	push   $0x0
f0101ac1:	68 00 10 00 00       	push   $0x1000
f0101ac6:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101acc:	e8 79 f3 ff ff       	call   f0100e4a <pgdir_walk>
f0101ad1:	83 c4 10             	add    $0x10,%esp
f0101ad4:	f6 00 04             	testb  $0x4,(%eax)
f0101ad7:	74 19                	je     f0101af2 <mem_init+0xadd>
f0101ad9:	68 5c 40 10 f0       	push   $0xf010405c
f0101ade:	68 b2 43 10 f0       	push   $0xf01043b2
f0101ae3:	68 04 03 00 00       	push   $0x304
f0101ae8:	68 8c 43 10 f0       	push   $0xf010438c
f0101aed:	e8 99 e5 ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101af2:	6a 02                	push   $0x2
f0101af4:	68 00 00 40 00       	push   $0x400000
f0101af9:	56                   	push   %esi
f0101afa:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101b00:	e8 a7 f4 ff ff       	call   f0100fac <page_insert>
f0101b05:	83 c4 10             	add    $0x10,%esp
f0101b08:	85 c0                	test   %eax,%eax
f0101b0a:	78 19                	js     f0101b25 <mem_init+0xb10>
f0101b0c:	68 94 40 10 f0       	push   $0xf0104094
f0101b11:	68 b2 43 10 f0       	push   $0xf01043b2
f0101b16:	68 07 03 00 00       	push   $0x307
f0101b1b:	68 8c 43 10 f0       	push   $0xf010438c
f0101b20:	e8 66 e5 ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b25:	6a 02                	push   $0x2
f0101b27:	68 00 10 00 00       	push   $0x1000
f0101b2c:	57                   	push   %edi
f0101b2d:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101b33:	e8 74 f4 ff ff       	call   f0100fac <page_insert>
f0101b38:	83 c4 10             	add    $0x10,%esp
f0101b3b:	85 c0                	test   %eax,%eax
f0101b3d:	74 19                	je     f0101b58 <mem_init+0xb43>
f0101b3f:	68 cc 40 10 f0       	push   $0xf01040cc
f0101b44:	68 b2 43 10 f0       	push   $0xf01043b2
f0101b49:	68 0a 03 00 00       	push   $0x30a
f0101b4e:	68 8c 43 10 f0       	push   $0xf010438c
f0101b53:	e8 33 e5 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b58:	83 ec 04             	sub    $0x4,%esp
f0101b5b:	6a 00                	push   $0x0
f0101b5d:	68 00 10 00 00       	push   $0x1000
f0101b62:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101b68:	e8 dd f2 ff ff       	call   f0100e4a <pgdir_walk>
f0101b6d:	83 c4 10             	add    $0x10,%esp
f0101b70:	f6 00 04             	testb  $0x4,(%eax)
f0101b73:	74 19                	je     f0101b8e <mem_init+0xb79>
f0101b75:	68 5c 40 10 f0       	push   $0xf010405c
f0101b7a:	68 b2 43 10 f0       	push   $0xf01043b2
f0101b7f:	68 0b 03 00 00       	push   $0x30b
f0101b84:	68 8c 43 10 f0       	push   $0xf010438c
f0101b89:	e8 fd e4 ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101b8e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b93:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101b98:	e8 16 ee ff ff       	call   f01009b3 <check_va2pa>
f0101b9d:	89 fa                	mov    %edi,%edx
f0101b9f:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101ba5:	c1 fa 03             	sar    $0x3,%edx
f0101ba8:	c1 e2 0c             	shl    $0xc,%edx
f0101bab:	39 d0                	cmp    %edx,%eax
f0101bad:	74 19                	je     f0101bc8 <mem_init+0xbb3>
f0101baf:	68 08 41 10 f0       	push   $0xf0104108
f0101bb4:	68 b2 43 10 f0       	push   $0xf01043b2
f0101bb9:	68 0e 03 00 00       	push   $0x30e
f0101bbe:	68 8c 43 10 f0       	push   $0xf010438c
f0101bc3:	e8 c3 e4 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101bc8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bcd:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101bd2:	e8 dc ed ff ff       	call   f01009b3 <check_va2pa>
f0101bd7:	89 fa                	mov    %edi,%edx
f0101bd9:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101bdf:	c1 fa 03             	sar    $0x3,%edx
f0101be2:	c1 e2 0c             	shl    $0xc,%edx
f0101be5:	39 d0                	cmp    %edx,%eax
f0101be7:	74 19                	je     f0101c02 <mem_init+0xbed>
f0101be9:	68 34 41 10 f0       	push   $0xf0104134
f0101bee:	68 b2 43 10 f0       	push   $0xf01043b2
f0101bf3:	68 0f 03 00 00       	push   $0x30f
f0101bf8:	68 8c 43 10 f0       	push   $0xf010438c
f0101bfd:	e8 89 e4 ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c02:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101c07:	74 19                	je     f0101c22 <mem_init+0xc0d>
f0101c09:	68 b0 45 10 f0       	push   $0xf01045b0
f0101c0e:	68 b2 43 10 f0       	push   $0xf01043b2
f0101c13:	68 11 03 00 00       	push   $0x311
f0101c18:	68 8c 43 10 f0       	push   $0xf010438c
f0101c1d:	e8 69 e4 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101c22:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c27:	74 19                	je     f0101c42 <mem_init+0xc2d>
f0101c29:	68 c1 45 10 f0       	push   $0xf01045c1
f0101c2e:	68 b2 43 10 f0       	push   $0xf01043b2
f0101c33:	68 12 03 00 00       	push   $0x312
f0101c38:	68 8c 43 10 f0       	push   $0xf010438c
f0101c3d:	e8 49 e4 ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c42:	83 ec 0c             	sub    $0xc,%esp
f0101c45:	6a 00                	push   $0x0
f0101c47:	e8 56 f1 ff ff       	call   f0100da2 <page_alloc>
f0101c4c:	83 c4 10             	add    $0x10,%esp
f0101c4f:	85 c0                	test   %eax,%eax
f0101c51:	74 04                	je     f0101c57 <mem_init+0xc42>
f0101c53:	39 c3                	cmp    %eax,%ebx
f0101c55:	74 19                	je     f0101c70 <mem_init+0xc5b>
f0101c57:	68 64 41 10 f0       	push   $0xf0104164
f0101c5c:	68 b2 43 10 f0       	push   $0xf01043b2
f0101c61:	68 15 03 00 00       	push   $0x315
f0101c66:	68 8c 43 10 f0       	push   $0xf010438c
f0101c6b:	e8 1b e4 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c70:	83 ec 08             	sub    $0x8,%esp
f0101c73:	6a 00                	push   $0x0
f0101c75:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101c7b:	e8 df f2 ff ff       	call   f0100f5f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c80:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c85:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101c8a:	e8 24 ed ff ff       	call   f01009b3 <check_va2pa>
f0101c8f:	83 c4 10             	add    $0x10,%esp
f0101c92:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c95:	74 19                	je     f0101cb0 <mem_init+0xc9b>
f0101c97:	68 88 41 10 f0       	push   $0xf0104188
f0101c9c:	68 b2 43 10 f0       	push   $0xf01043b2
f0101ca1:	68 19 03 00 00       	push   $0x319
f0101ca6:	68 8c 43 10 f0       	push   $0xf010438c
f0101cab:	e8 db e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cb0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cb5:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101cba:	e8 f4 ec ff ff       	call   f01009b3 <check_va2pa>
f0101cbf:	89 fa                	mov    %edi,%edx
f0101cc1:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101cc7:	c1 fa 03             	sar    $0x3,%edx
f0101cca:	c1 e2 0c             	shl    $0xc,%edx
f0101ccd:	39 d0                	cmp    %edx,%eax
f0101ccf:	74 19                	je     f0101cea <mem_init+0xcd5>
f0101cd1:	68 34 41 10 f0       	push   $0xf0104134
f0101cd6:	68 b2 43 10 f0       	push   $0xf01043b2
f0101cdb:	68 1a 03 00 00       	push   $0x31a
f0101ce0:	68 8c 43 10 f0       	push   $0xf010438c
f0101ce5:	e8 a1 e3 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101cea:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101cef:	74 19                	je     f0101d0a <mem_init+0xcf5>
f0101cf1:	68 67 45 10 f0       	push   $0xf0104567
f0101cf6:	68 b2 43 10 f0       	push   $0xf01043b2
f0101cfb:	68 1b 03 00 00       	push   $0x31b
f0101d00:	68 8c 43 10 f0       	push   $0xf010438c
f0101d05:	e8 81 e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101d0a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d0f:	74 19                	je     f0101d2a <mem_init+0xd15>
f0101d11:	68 c1 45 10 f0       	push   $0xf01045c1
f0101d16:	68 b2 43 10 f0       	push   $0xf01043b2
f0101d1b:	68 1c 03 00 00       	push   $0x31c
f0101d20:	68 8c 43 10 f0       	push   $0xf010438c
f0101d25:	e8 61 e3 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d2a:	83 ec 08             	sub    $0x8,%esp
f0101d2d:	68 00 10 00 00       	push   $0x1000
f0101d32:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101d38:	e8 22 f2 ff ff       	call   f0100f5f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d3d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d42:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101d47:	e8 67 ec ff ff       	call   f01009b3 <check_va2pa>
f0101d4c:	83 c4 10             	add    $0x10,%esp
f0101d4f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d52:	74 19                	je     f0101d6d <mem_init+0xd58>
f0101d54:	68 88 41 10 f0       	push   $0xf0104188
f0101d59:	68 b2 43 10 f0       	push   $0xf01043b2
f0101d5e:	68 20 03 00 00       	push   $0x320
f0101d63:	68 8c 43 10 f0       	push   $0xf010438c
f0101d68:	e8 1e e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d6d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d72:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101d77:	e8 37 ec ff ff       	call   f01009b3 <check_va2pa>
f0101d7c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d7f:	74 19                	je     f0101d9a <mem_init+0xd85>
f0101d81:	68 ac 41 10 f0       	push   $0xf01041ac
f0101d86:	68 b2 43 10 f0       	push   $0xf01043b2
f0101d8b:	68 21 03 00 00       	push   $0x321
f0101d90:	68 8c 43 10 f0       	push   $0xf010438c
f0101d95:	e8 f1 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0101d9a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d9f:	74 19                	je     f0101dba <mem_init+0xda5>
f0101da1:	68 d2 45 10 f0       	push   $0xf01045d2
f0101da6:	68 b2 43 10 f0       	push   $0xf01043b2
f0101dab:	68 22 03 00 00       	push   $0x322
f0101db0:	68 8c 43 10 f0       	push   $0xf010438c
f0101db5:	e8 d1 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101dba:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101dbf:	74 19                	je     f0101dda <mem_init+0xdc5>
f0101dc1:	68 c1 45 10 f0       	push   $0xf01045c1
f0101dc6:	68 b2 43 10 f0       	push   $0xf01043b2
f0101dcb:	68 23 03 00 00       	push   $0x323
f0101dd0:	68 8c 43 10 f0       	push   $0xf010438c
f0101dd5:	e8 b1 e2 ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101dda:	83 ec 0c             	sub    $0xc,%esp
f0101ddd:	6a 00                	push   $0x0
f0101ddf:	e8 be ef ff ff       	call   f0100da2 <page_alloc>
f0101de4:	83 c4 10             	add    $0x10,%esp
f0101de7:	85 c0                	test   %eax,%eax
f0101de9:	74 04                	je     f0101def <mem_init+0xdda>
f0101deb:	39 c7                	cmp    %eax,%edi
f0101ded:	74 19                	je     f0101e08 <mem_init+0xdf3>
f0101def:	68 d4 41 10 f0       	push   $0xf01041d4
f0101df4:	68 b2 43 10 f0       	push   $0xf01043b2
f0101df9:	68 26 03 00 00       	push   $0x326
f0101dfe:	68 8c 43 10 f0       	push   $0xf010438c
f0101e03:	e8 83 e2 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e08:	83 ec 0c             	sub    $0xc,%esp
f0101e0b:	6a 00                	push   $0x0
f0101e0d:	e8 90 ef ff ff       	call   f0100da2 <page_alloc>
f0101e12:	83 c4 10             	add    $0x10,%esp
f0101e15:	85 c0                	test   %eax,%eax
f0101e17:	74 19                	je     f0101e32 <mem_init+0xe1d>
f0101e19:	68 15 45 10 f0       	push   $0xf0104515
f0101e1e:	68 b2 43 10 f0       	push   $0xf01043b2
f0101e23:	68 29 03 00 00       	push   $0x329
f0101e28:	68 8c 43 10 f0       	push   $0xf010438c
f0101e2d:	e8 59 e2 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e32:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101e37:	8b 08                	mov    (%eax),%ecx
f0101e39:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101e3f:	89 f2                	mov    %esi,%edx
f0101e41:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101e47:	c1 fa 03             	sar    $0x3,%edx
f0101e4a:	c1 e2 0c             	shl    $0xc,%edx
f0101e4d:	39 d1                	cmp    %edx,%ecx
f0101e4f:	74 19                	je     f0101e6a <mem_init+0xe55>
f0101e51:	68 b0 3e 10 f0       	push   $0xf0103eb0
f0101e56:	68 b2 43 10 f0       	push   $0xf01043b2
f0101e5b:	68 2c 03 00 00       	push   $0x32c
f0101e60:	68 8c 43 10 f0       	push   $0xf010438c
f0101e65:	e8 21 e2 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0101e6a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0101e70:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e75:	74 19                	je     f0101e90 <mem_init+0xe7b>
f0101e77:	68 78 45 10 f0       	push   $0xf0104578
f0101e7c:	68 b2 43 10 f0       	push   $0xf01043b2
f0101e81:	68 2e 03 00 00       	push   $0x32e
f0101e86:	68 8c 43 10 f0       	push   $0xf010438c
f0101e8b:	e8 fb e1 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0101e90:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e96:	83 ec 0c             	sub    $0xc,%esp
f0101e99:	56                   	push   %esi
f0101e9a:	e8 6d ef ff ff       	call   f0100e0c <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e9f:	83 c4 0c             	add    $0xc,%esp
f0101ea2:	6a 01                	push   $0x1
f0101ea4:	68 00 10 40 00       	push   $0x401000
f0101ea9:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101eaf:	e8 96 ef ff ff       	call   f0100e4a <pgdir_walk>
f0101eb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101eb7:	8b 0d 48 d9 11 f0    	mov    0xf011d948,%ecx
f0101ebd:	8b 51 04             	mov    0x4(%ecx),%edx
f0101ec0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ec6:	89 55 c4             	mov    %edx,-0x3c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ec9:	c1 ea 0c             	shr    $0xc,%edx
f0101ecc:	83 c4 10             	add    $0x10,%esp
f0101ecf:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f0101ed5:	72 17                	jb     f0101eee <mem_init+0xed9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ed7:	ff 75 c4             	pushl  -0x3c(%ebp)
f0101eda:	68 70 3c 10 f0       	push   $0xf0103c70
f0101edf:	68 35 03 00 00       	push   $0x335
f0101ee4:	68 8c 43 10 f0       	push   $0xf010438c
f0101ee9:	e8 9d e1 ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f0101eee:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101ef1:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101ef7:	39 d0                	cmp    %edx,%eax
f0101ef9:	74 19                	je     f0101f14 <mem_init+0xeff>
f0101efb:	68 e3 45 10 f0       	push   $0xf01045e3
f0101f00:	68 b2 43 10 f0       	push   $0xf01043b2
f0101f05:	68 36 03 00 00       	push   $0x336
f0101f0a:	68 8c 43 10 f0       	push   $0xf010438c
f0101f0f:	e8 77 e1 ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f0101f14:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101f1b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f21:	89 f0                	mov    %esi,%eax
f0101f23:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
f0101f29:	c1 f8 03             	sar    $0x3,%eax
f0101f2c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f2f:	89 c2                	mov    %eax,%edx
f0101f31:	c1 ea 0c             	shr    $0xc,%edx
f0101f34:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f0101f3a:	72 12                	jb     f0101f4e <mem_init+0xf39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f3c:	50                   	push   %eax
f0101f3d:	68 70 3c 10 f0       	push   $0xf0103c70
f0101f42:	6a 52                	push   $0x52
f0101f44:	68 98 43 10 f0       	push   $0xf0104398
f0101f49:	e8 3d e1 ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101f4e:	83 ec 04             	sub    $0x4,%esp
f0101f51:	68 00 10 00 00       	push   $0x1000
f0101f56:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101f5b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f60:	50                   	push   %eax
f0101f61:	e8 c3 11 00 00       	call   f0103129 <memset>
	page_free(pp0);
f0101f66:	89 34 24             	mov    %esi,(%esp)
f0101f69:	e8 9e ee ff ff       	call   f0100e0c <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101f6e:	83 c4 0c             	add    $0xc,%esp
f0101f71:	6a 01                	push   $0x1
f0101f73:	6a 00                	push   $0x0
f0101f75:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0101f7b:	e8 ca ee ff ff       	call   f0100e4a <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f80:	89 f2                	mov    %esi,%edx
f0101f82:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0101f88:	c1 fa 03             	sar    $0x3,%edx
f0101f8b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f8e:	89 d0                	mov    %edx,%eax
f0101f90:	c1 e8 0c             	shr    $0xc,%eax
f0101f93:	83 c4 10             	add    $0x10,%esp
f0101f96:	3b 05 44 d9 11 f0    	cmp    0xf011d944,%eax
f0101f9c:	72 12                	jb     f0101fb0 <mem_init+0xf9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f9e:	52                   	push   %edx
f0101f9f:	68 70 3c 10 f0       	push   $0xf0103c70
f0101fa4:	6a 52                	push   $0x52
f0101fa6:	68 98 43 10 f0       	push   $0xf0104398
f0101fab:	e8 db e0 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101fb0:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101fb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101fb9:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0101fc0:	75 11                	jne    f0101fd3 <mem_init+0xfbe>
f0101fc2:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101fc8:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101fce:	f6 00 01             	testb  $0x1,(%eax)
f0101fd1:	74 19                	je     f0101fec <mem_init+0xfd7>
f0101fd3:	68 fb 45 10 f0       	push   $0xf01045fb
f0101fd8:	68 b2 43 10 f0       	push   $0xf01043b2
f0101fdd:	68 40 03 00 00       	push   $0x340
f0101fe2:	68 8c 43 10 f0       	push   $0xf010438c
f0101fe7:	e8 9f e0 ff ff       	call   f010008b <_panic>
f0101fec:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0101fef:	39 d0                	cmp    %edx,%eax
f0101ff1:	75 db                	jne    f0101fce <mem_init+0xfb9>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0101ff3:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0101ff8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101ffe:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102004:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102007:	a3 2c d5 11 f0       	mov    %eax,0xf011d52c

	// free the pages we took
	page_free(pp0);
f010200c:	83 ec 0c             	sub    $0xc,%esp
f010200f:	56                   	push   %esi
f0102010:	e8 f7 ed ff ff       	call   f0100e0c <page_free>
	page_free(pp1);
f0102015:	89 3c 24             	mov    %edi,(%esp)
f0102018:	e8 ef ed ff ff       	call   f0100e0c <page_free>
	page_free(pp2);
f010201d:	89 1c 24             	mov    %ebx,(%esp)
f0102020:	e8 e7 ed ff ff       	call   f0100e0c <page_free>

	cprintf("check_page() succeeded!\n");
f0102025:	c7 04 24 12 46 10 f0 	movl   $0xf0104612,(%esp)
f010202c:	e8 c8 05 00 00       	call   f01025f9 <cprintf>

	check_page_free_list(1);
	check_page_alloc();
	cprintf("!\n");
    check_page();
    cprintf("!!\n");
f0102031:	c7 04 24 2b 46 10 f0 	movl   $0xf010462b,(%esp)
f0102038:	e8 bc 05 00 00       	call   f01025f9 <cprintf>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010203d:	8b 1d 48 d9 11 f0    	mov    0xf011d948,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102043:	a1 44 d9 11 f0       	mov    0xf011d944,%eax
f0102048:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f010204f:	83 c4 10             	add    $0x10,%esp
f0102052:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102058:	74 63                	je     f01020bd <mem_init+0x10a8>
f010205a:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010205f:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102065:	89 d8                	mov    %ebx,%eax
f0102067:	e8 47 e9 ff ff       	call   f01009b3 <check_va2pa>
f010206c:	8b 15 4c d9 11 f0    	mov    0xf011d94c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102072:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102078:	77 15                	ja     f010208f <mem_init+0x107a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010207a:	52                   	push   %edx
f010207b:	68 58 3d 10 f0       	push   $0xf0103d58
f0102080:	68 87 02 00 00       	push   $0x287
f0102085:	68 8c 43 10 f0       	push   $0xf010438c
f010208a:	e8 fc df ff ff       	call   f010008b <_panic>
f010208f:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102096:	39 d0                	cmp    %edx,%eax
f0102098:	74 19                	je     f01020b3 <mem_init+0x109e>
f010209a:	68 f8 41 10 f0       	push   $0xf01041f8
f010209f:	68 b2 43 10 f0       	push   $0xf01043b2
f01020a4:	68 87 02 00 00       	push   $0x287
f01020a9:	68 8c 43 10 f0       	push   $0xf010438c
f01020ae:	e8 d8 df ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01020b3:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01020b9:	39 f7                	cmp    %esi,%edi
f01020bb:	77 a2                	ja     f010205f <mem_init+0x104a>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01020bd:	a1 44 d9 11 f0       	mov    0xf011d944,%eax
f01020c2:	c1 e0 0c             	shl    $0xc,%eax
f01020c5:	74 41                	je     f0102108 <mem_init+0x10f3>
f01020c7:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01020cc:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f01020d2:	89 d8                	mov    %ebx,%eax
f01020d4:	e8 da e8 ff ff       	call   f01009b3 <check_va2pa>
f01020d9:	39 c6                	cmp    %eax,%esi
f01020db:	74 19                	je     f01020f6 <mem_init+0x10e1>
f01020dd:	68 2c 42 10 f0       	push   $0xf010422c
f01020e2:	68 b2 43 10 f0       	push   $0xf01043b2
f01020e7:	68 8c 02 00 00       	push   $0x28c
f01020ec:	68 8c 43 10 f0       	push   $0xf010438c
f01020f1:	e8 95 df ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01020f6:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01020fc:	a1 44 d9 11 f0       	mov    0xf011d944,%eax
f0102101:	c1 e0 0c             	shl    $0xc,%eax
f0102104:	39 c6                	cmp    %eax,%esi
f0102106:	72 c4                	jb     f01020cc <mem_init+0x10b7>
f0102108:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010210d:	bf 00 30 11 f0       	mov    $0xf0113000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102112:	89 f2                	mov    %esi,%edx
f0102114:	89 d8                	mov    %ebx,%eax
f0102116:	e8 98 e8 ff ff       	call   f01009b3 <check_va2pa>
f010211b:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102121:	77 19                	ja     f010213c <mem_init+0x1127>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102123:	68 00 30 11 f0       	push   $0xf0113000
f0102128:	68 58 3d 10 f0       	push   $0xf0103d58
f010212d:	68 90 02 00 00       	push   $0x290
f0102132:	68 8c 43 10 f0       	push   $0xf010438c
f0102137:	e8 4f df ff ff       	call   f010008b <_panic>
f010213c:	8d 96 00 b0 11 10    	lea    0x1011b000(%esi),%edx
f0102142:	39 d0                	cmp    %edx,%eax
f0102144:	74 19                	je     f010215f <mem_init+0x114a>
f0102146:	68 54 42 10 f0       	push   $0xf0104254
f010214b:	68 b2 43 10 f0       	push   $0xf01043b2
f0102150:	68 90 02 00 00       	push   $0x290
f0102155:	68 8c 43 10 f0       	push   $0xf010438c
f010215a:	e8 2c df ff ff       	call   f010008b <_panic>
f010215f:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102165:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010216b:	75 a5                	jne    f0102112 <mem_init+0x10fd>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010216d:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102172:	89 d8                	mov    %ebx,%eax
f0102174:	e8 3a e8 ff ff       	call   f01009b3 <check_va2pa>
f0102179:	83 f8 ff             	cmp    $0xffffffff,%eax
f010217c:	74 19                	je     f0102197 <mem_init+0x1182>
f010217e:	68 9c 42 10 f0       	push   $0xf010429c
f0102183:	68 b2 43 10 f0       	push   $0xf01043b2
f0102188:	68 91 02 00 00       	push   $0x291
f010218d:	68 8c 43 10 f0       	push   $0xf010438c
f0102192:	e8 f4 de ff ff       	call   f010008b <_panic>
f0102197:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010219c:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01021a1:	72 2d                	jb     f01021d0 <mem_init+0x11bb>
f01021a3:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01021a8:	76 07                	jbe    f01021b1 <mem_init+0x119c>
f01021aa:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01021af:	75 1f                	jne    f01021d0 <mem_init+0x11bb>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01021b1:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01021b5:	75 7e                	jne    f0102235 <mem_init+0x1220>
f01021b7:	68 2f 46 10 f0       	push   $0xf010462f
f01021bc:	68 b2 43 10 f0       	push   $0xf01043b2
f01021c1:	68 99 02 00 00       	push   $0x299
f01021c6:	68 8c 43 10 f0       	push   $0xf010438c
f01021cb:	e8 bb de ff ff       	call   f010008b <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01021d0:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01021d5:	76 3f                	jbe    f0102216 <mem_init+0x1201>
				assert(pgdir[i] & PTE_P);
f01021d7:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01021da:	f6 c2 01             	test   $0x1,%dl
f01021dd:	75 19                	jne    f01021f8 <mem_init+0x11e3>
f01021df:	68 2f 46 10 f0       	push   $0xf010462f
f01021e4:	68 b2 43 10 f0       	push   $0xf01043b2
f01021e9:	68 9d 02 00 00       	push   $0x29d
f01021ee:	68 8c 43 10 f0       	push   $0xf010438c
f01021f3:	e8 93 de ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f01021f8:	f6 c2 02             	test   $0x2,%dl
f01021fb:	75 38                	jne    f0102235 <mem_init+0x1220>
f01021fd:	68 40 46 10 f0       	push   $0xf0104640
f0102202:	68 b2 43 10 f0       	push   $0xf01043b2
f0102207:	68 9e 02 00 00       	push   $0x29e
f010220c:	68 8c 43 10 f0       	push   $0xf010438c
f0102211:	e8 75 de ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f0102216:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010221a:	74 19                	je     f0102235 <mem_init+0x1220>
f010221c:	68 51 46 10 f0       	push   $0xf0104651
f0102221:	68 b2 43 10 f0       	push   $0xf01043b2
f0102226:	68 a0 02 00 00       	push   $0x2a0
f010222b:	68 8c 43 10 f0       	push   $0xf010438c
f0102230:	e8 56 de ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102235:	40                   	inc    %eax
f0102236:	3d 00 04 00 00       	cmp    $0x400,%eax
f010223b:	0f 85 5b ff ff ff    	jne    f010219c <mem_init+0x1187>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102241:	83 ec 0c             	sub    $0xc,%esp
f0102244:	68 cc 42 10 f0       	push   $0xf01042cc
f0102249:	e8 ab 03 00 00       	call   f01025f9 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010224e:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102253:	83 c4 10             	add    $0x10,%esp
f0102256:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010225b:	77 15                	ja     f0102272 <mem_init+0x125d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010225d:	50                   	push   %eax
f010225e:	68 58 3d 10 f0       	push   $0xf0103d58
f0102263:	68 d0 00 00 00       	push   $0xd0
f0102268:	68 8c 43 10 f0       	push   $0xf010438c
f010226d:	e8 19 de ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102272:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102277:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010227a:	b8 00 00 00 00       	mov    $0x0,%eax
f010227f:	e8 b8 e7 ff ff       	call   f0100a3c <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102284:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102287:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010228c:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010228f:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102292:	83 ec 0c             	sub    $0xc,%esp
f0102295:	6a 00                	push   $0x0
f0102297:	e8 06 eb ff ff       	call   f0100da2 <page_alloc>
f010229c:	89 c6                	mov    %eax,%esi
f010229e:	83 c4 10             	add    $0x10,%esp
f01022a1:	85 c0                	test   %eax,%eax
f01022a3:	75 19                	jne    f01022be <mem_init+0x12a9>
f01022a5:	68 6a 44 10 f0       	push   $0xf010446a
f01022aa:	68 b2 43 10 f0       	push   $0xf01043b2
f01022af:	68 5b 03 00 00       	push   $0x35b
f01022b4:	68 8c 43 10 f0       	push   $0xf010438c
f01022b9:	e8 cd dd ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01022be:	83 ec 0c             	sub    $0xc,%esp
f01022c1:	6a 00                	push   $0x0
f01022c3:	e8 da ea ff ff       	call   f0100da2 <page_alloc>
f01022c8:	89 c7                	mov    %eax,%edi
f01022ca:	83 c4 10             	add    $0x10,%esp
f01022cd:	85 c0                	test   %eax,%eax
f01022cf:	75 19                	jne    f01022ea <mem_init+0x12d5>
f01022d1:	68 80 44 10 f0       	push   $0xf0104480
f01022d6:	68 b2 43 10 f0       	push   $0xf01043b2
f01022db:	68 5c 03 00 00       	push   $0x35c
f01022e0:	68 8c 43 10 f0       	push   $0xf010438c
f01022e5:	e8 a1 dd ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01022ea:	83 ec 0c             	sub    $0xc,%esp
f01022ed:	6a 00                	push   $0x0
f01022ef:	e8 ae ea ff ff       	call   f0100da2 <page_alloc>
f01022f4:	89 c3                	mov    %eax,%ebx
f01022f6:	83 c4 10             	add    $0x10,%esp
f01022f9:	85 c0                	test   %eax,%eax
f01022fb:	75 19                	jne    f0102316 <mem_init+0x1301>
f01022fd:	68 96 44 10 f0       	push   $0xf0104496
f0102302:	68 b2 43 10 f0       	push   $0xf01043b2
f0102307:	68 5d 03 00 00       	push   $0x35d
f010230c:	68 8c 43 10 f0       	push   $0xf010438c
f0102311:	e8 75 dd ff ff       	call   f010008b <_panic>
	page_free(pp0);
f0102316:	83 ec 0c             	sub    $0xc,%esp
f0102319:	56                   	push   %esi
f010231a:	e8 ed ea ff ff       	call   f0100e0c <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010231f:	89 f8                	mov    %edi,%eax
f0102321:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
f0102327:	c1 f8 03             	sar    $0x3,%eax
f010232a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010232d:	89 c2                	mov    %eax,%edx
f010232f:	c1 ea 0c             	shr    $0xc,%edx
f0102332:	83 c4 10             	add    $0x10,%esp
f0102335:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f010233b:	72 12                	jb     f010234f <mem_init+0x133a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010233d:	50                   	push   %eax
f010233e:	68 70 3c 10 f0       	push   $0xf0103c70
f0102343:	6a 52                	push   $0x52
f0102345:	68 98 43 10 f0       	push   $0xf0104398
f010234a:	e8 3c dd ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010234f:	83 ec 04             	sub    $0x4,%esp
f0102352:	68 00 10 00 00       	push   $0x1000
f0102357:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102359:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010235e:	50                   	push   %eax
f010235f:	e8 c5 0d 00 00       	call   f0103129 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102364:	89 d8                	mov    %ebx,%eax
f0102366:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
f010236c:	c1 f8 03             	sar    $0x3,%eax
f010236f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102372:	89 c2                	mov    %eax,%edx
f0102374:	c1 ea 0c             	shr    $0xc,%edx
f0102377:	83 c4 10             	add    $0x10,%esp
f010237a:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f0102380:	72 12                	jb     f0102394 <mem_init+0x137f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102382:	50                   	push   %eax
f0102383:	68 70 3c 10 f0       	push   $0xf0103c70
f0102388:	6a 52                	push   $0x52
f010238a:	68 98 43 10 f0       	push   $0xf0104398
f010238f:	e8 f7 dc ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102394:	83 ec 04             	sub    $0x4,%esp
f0102397:	68 00 10 00 00       	push   $0x1000
f010239c:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f010239e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023a3:	50                   	push   %eax
f01023a4:	e8 80 0d 00 00       	call   f0103129 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01023a9:	6a 02                	push   $0x2
f01023ab:	68 00 10 00 00       	push   $0x1000
f01023b0:	57                   	push   %edi
f01023b1:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f01023b7:	e8 f0 eb ff ff       	call   f0100fac <page_insert>
	assert(pp1->pp_ref == 1);
f01023bc:	83 c4 20             	add    $0x20,%esp
f01023bf:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01023c4:	74 19                	je     f01023df <mem_init+0x13ca>
f01023c6:	68 67 45 10 f0       	push   $0xf0104567
f01023cb:	68 b2 43 10 f0       	push   $0xf01043b2
f01023d0:	68 62 03 00 00       	push   $0x362
f01023d5:	68 8c 43 10 f0       	push   $0xf010438c
f01023da:	e8 ac dc ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01023df:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01023e6:	01 01 01 
f01023e9:	74 19                	je     f0102404 <mem_init+0x13ef>
f01023eb:	68 ec 42 10 f0       	push   $0xf01042ec
f01023f0:	68 b2 43 10 f0       	push   $0xf01043b2
f01023f5:	68 63 03 00 00       	push   $0x363
f01023fa:	68 8c 43 10 f0       	push   $0xf010438c
f01023ff:	e8 87 dc ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102404:	6a 02                	push   $0x2
f0102406:	68 00 10 00 00       	push   $0x1000
f010240b:	53                   	push   %ebx
f010240c:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f0102412:	e8 95 eb ff ff       	call   f0100fac <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102417:	83 c4 10             	add    $0x10,%esp
f010241a:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102421:	02 02 02 
f0102424:	74 19                	je     f010243f <mem_init+0x142a>
f0102426:	68 10 43 10 f0       	push   $0xf0104310
f010242b:	68 b2 43 10 f0       	push   $0xf01043b2
f0102430:	68 65 03 00 00       	push   $0x365
f0102435:	68 8c 43 10 f0       	push   $0xf010438c
f010243a:	e8 4c dc ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f010243f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102444:	74 19                	je     f010245f <mem_init+0x144a>
f0102446:	68 89 45 10 f0       	push   $0xf0104589
f010244b:	68 b2 43 10 f0       	push   $0xf01043b2
f0102450:	68 66 03 00 00       	push   $0x366
f0102455:	68 8c 43 10 f0       	push   $0xf010438c
f010245a:	e8 2c dc ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f010245f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102464:	74 19                	je     f010247f <mem_init+0x146a>
f0102466:	68 d2 45 10 f0       	push   $0xf01045d2
f010246b:	68 b2 43 10 f0       	push   $0xf01043b2
f0102470:	68 67 03 00 00       	push   $0x367
f0102475:	68 8c 43 10 f0       	push   $0xf010438c
f010247a:	e8 0c dc ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010247f:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102486:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102489:	89 d8                	mov    %ebx,%eax
f010248b:	2b 05 4c d9 11 f0    	sub    0xf011d94c,%eax
f0102491:	c1 f8 03             	sar    $0x3,%eax
f0102494:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102497:	89 c2                	mov    %eax,%edx
f0102499:	c1 ea 0c             	shr    $0xc,%edx
f010249c:	3b 15 44 d9 11 f0    	cmp    0xf011d944,%edx
f01024a2:	72 12                	jb     f01024b6 <mem_init+0x14a1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024a4:	50                   	push   %eax
f01024a5:	68 70 3c 10 f0       	push   $0xf0103c70
f01024aa:	6a 52                	push   $0x52
f01024ac:	68 98 43 10 f0       	push   $0xf0104398
f01024b1:	e8 d5 db ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01024b6:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01024bd:	03 03 03 
f01024c0:	74 19                	je     f01024db <mem_init+0x14c6>
f01024c2:	68 34 43 10 f0       	push   $0xf0104334
f01024c7:	68 b2 43 10 f0       	push   $0xf01043b2
f01024cc:	68 69 03 00 00       	push   $0x369
f01024d1:	68 8c 43 10 f0       	push   $0xf010438c
f01024d6:	e8 b0 db ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01024db:	83 ec 08             	sub    $0x8,%esp
f01024de:	68 00 10 00 00       	push   $0x1000
f01024e3:	ff 35 48 d9 11 f0    	pushl  0xf011d948
f01024e9:	e8 71 ea ff ff       	call   f0100f5f <page_remove>
	assert(pp2->pp_ref == 0);
f01024ee:	83 c4 10             	add    $0x10,%esp
f01024f1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024f6:	74 19                	je     f0102511 <mem_init+0x14fc>
f01024f8:	68 c1 45 10 f0       	push   $0xf01045c1
f01024fd:	68 b2 43 10 f0       	push   $0xf01043b2
f0102502:	68 6b 03 00 00       	push   $0x36b
f0102507:	68 8c 43 10 f0       	push   $0xf010438c
f010250c:	e8 7a db ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102511:	a1 48 d9 11 f0       	mov    0xf011d948,%eax
f0102516:	8b 08                	mov    (%eax),%ecx
f0102518:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010251e:	89 f2                	mov    %esi,%edx
f0102520:	2b 15 4c d9 11 f0    	sub    0xf011d94c,%edx
f0102526:	c1 fa 03             	sar    $0x3,%edx
f0102529:	c1 e2 0c             	shl    $0xc,%edx
f010252c:	39 d1                	cmp    %edx,%ecx
f010252e:	74 19                	je     f0102549 <mem_init+0x1534>
f0102530:	68 b0 3e 10 f0       	push   $0xf0103eb0
f0102535:	68 b2 43 10 f0       	push   $0xf01043b2
f010253a:	68 6e 03 00 00       	push   $0x36e
f010253f:	68 8c 43 10 f0       	push   $0xf010438c
f0102544:	e8 42 db ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102549:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010254f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102554:	74 19                	je     f010256f <mem_init+0x155a>
f0102556:	68 78 45 10 f0       	push   $0xf0104578
f010255b:	68 b2 43 10 f0       	push   $0xf01043b2
f0102560:	68 70 03 00 00       	push   $0x370
f0102565:	68 8c 43 10 f0       	push   $0xf010438c
f010256a:	e8 1c db ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f010256f:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102575:	83 ec 0c             	sub    $0xc,%esp
f0102578:	56                   	push   %esi
f0102579:	e8 8e e8 ff ff       	call   f0100e0c <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010257e:	c7 04 24 60 43 10 f0 	movl   $0xf0104360,(%esp)
f0102585:	e8 6f 00 00 00       	call   f01025f9 <cprintf>
f010258a:	83 c4 10             	add    $0x10,%esp
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010258d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102590:	5b                   	pop    %ebx
f0102591:	5e                   	pop    %esi
f0102592:	5f                   	pop    %edi
f0102593:	c9                   	leave  
f0102594:	c3                   	ret    
f0102595:	00 00                	add    %al,(%eax)
	...

f0102598 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102598:	55                   	push   %ebp
f0102599:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010259b:	ba 70 00 00 00       	mov    $0x70,%edx
f01025a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01025a3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01025a4:	b2 71                	mov    $0x71,%dl
f01025a6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01025a7:	0f b6 c0             	movzbl %al,%eax
}
f01025aa:	c9                   	leave  
f01025ab:	c3                   	ret    

f01025ac <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01025ac:	55                   	push   %ebp
f01025ad:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01025af:	ba 70 00 00 00       	mov    $0x70,%edx
f01025b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01025b7:	ee                   	out    %al,(%dx)
f01025b8:	b2 71                	mov    $0x71,%dl
f01025ba:	8b 45 0c             	mov    0xc(%ebp),%eax
f01025bd:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01025be:	c9                   	leave  
f01025bf:	c3                   	ret    

f01025c0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01025c0:	55                   	push   %ebp
f01025c1:	89 e5                	mov    %esp,%ebp
f01025c3:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01025c6:	ff 75 08             	pushl  0x8(%ebp)
f01025c9:	e8 d8 df ff ff       	call   f01005a6 <cputchar>
f01025ce:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f01025d1:	c9                   	leave  
f01025d2:	c3                   	ret    

f01025d3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01025d3:	55                   	push   %ebp
f01025d4:	89 e5                	mov    %esp,%ebp
f01025d6:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01025d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01025e0:	ff 75 0c             	pushl  0xc(%ebp)
f01025e3:	ff 75 08             	pushl  0x8(%ebp)
f01025e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01025e9:	50                   	push   %eax
f01025ea:	68 c0 25 10 f0       	push   $0xf01025c0
f01025ef:	e8 9d 04 00 00       	call   f0102a91 <vprintfmt>
	return cnt;
}
f01025f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01025f7:	c9                   	leave  
f01025f8:	c3                   	ret    

f01025f9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01025f9:	55                   	push   %ebp
f01025fa:	89 e5                	mov    %esp,%ebp
f01025fc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01025ff:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102602:	50                   	push   %eax
f0102603:	ff 75 08             	pushl  0x8(%ebp)
f0102606:	e8 c8 ff ff ff       	call   f01025d3 <vcprintf>
	va_end(ap);

	return cnt;
}
f010260b:	c9                   	leave  
f010260c:	c3                   	ret    
f010260d:	00 00                	add    %al,(%eax)
	...

f0102610 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102610:	55                   	push   %ebp
f0102611:	89 e5                	mov    %esp,%ebp
f0102613:	57                   	push   %edi
f0102614:	56                   	push   %esi
f0102615:	53                   	push   %ebx
f0102616:	83 ec 14             	sub    $0x14,%esp
f0102619:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010261c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010261f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102622:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102625:	8b 1a                	mov    (%edx),%ebx
f0102627:	8b 01                	mov    (%ecx),%eax
f0102629:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f010262c:	39 c3                	cmp    %eax,%ebx
f010262e:	0f 8f 97 00 00 00    	jg     f01026cb <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0102634:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010263b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010263e:	01 d8                	add    %ebx,%eax
f0102640:	89 c7                	mov    %eax,%edi
f0102642:	c1 ef 1f             	shr    $0x1f,%edi
f0102645:	01 c7                	add    %eax,%edi
f0102647:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102649:	39 df                	cmp    %ebx,%edi
f010264b:	7c 31                	jl     f010267e <stab_binsearch+0x6e>
f010264d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0102650:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102653:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0102658:	39 f0                	cmp    %esi,%eax
f010265a:	0f 84 b3 00 00 00    	je     f0102713 <stab_binsearch+0x103>
f0102660:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102664:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102668:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010266a:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010266b:	39 d8                	cmp    %ebx,%eax
f010266d:	7c 0f                	jl     f010267e <stab_binsearch+0x6e>
f010266f:	0f b6 0a             	movzbl (%edx),%ecx
f0102672:	83 ea 0c             	sub    $0xc,%edx
f0102675:	39 f1                	cmp    %esi,%ecx
f0102677:	75 f1                	jne    f010266a <stab_binsearch+0x5a>
f0102679:	e9 97 00 00 00       	jmp    f0102715 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010267e:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0102681:	eb 39                	jmp    f01026bc <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102683:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102686:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0102688:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010268b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102692:	eb 28                	jmp    f01026bc <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102694:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102697:	76 12                	jbe    f01026ab <stab_binsearch+0x9b>
			*region_right = m - 1;
f0102699:	48                   	dec    %eax
f010269a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010269d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01026a0:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01026a2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01026a9:	eb 11                	jmp    f01026bc <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01026ab:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01026ae:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f01026b0:	ff 45 0c             	incl   0xc(%ebp)
f01026b3:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01026b5:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01026bc:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f01026bf:	0f 8d 76 ff ff ff    	jge    f010263b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01026c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01026c9:	75 0d                	jne    f01026d8 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f01026cb:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01026ce:	8b 03                	mov    (%ebx),%eax
f01026d0:	48                   	dec    %eax
f01026d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01026d4:	89 02                	mov    %eax,(%edx)
f01026d6:	eb 55                	jmp    f010272d <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01026d8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01026db:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01026dd:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01026e0:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01026e2:	39 c1                	cmp    %eax,%ecx
f01026e4:	7d 26                	jge    f010270c <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f01026e6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01026e9:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01026ec:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01026f1:	39 f2                	cmp    %esi,%edx
f01026f3:	74 17                	je     f010270c <stab_binsearch+0xfc>
f01026f5:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01026f9:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01026fd:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01026fe:	39 c1                	cmp    %eax,%ecx
f0102700:	7d 0a                	jge    f010270c <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102702:	0f b6 1a             	movzbl (%edx),%ebx
f0102705:	83 ea 0c             	sub    $0xc,%edx
f0102708:	39 f3                	cmp    %esi,%ebx
f010270a:	75 f1                	jne    f01026fd <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f010270c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010270f:	89 02                	mov    %eax,(%edx)
f0102711:	eb 1a                	jmp    f010272d <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102713:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102715:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102718:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f010271b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010271f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102722:	0f 82 5b ff ff ff    	jb     f0102683 <stab_binsearch+0x73>
f0102728:	e9 67 ff ff ff       	jmp    f0102694 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010272d:	83 c4 14             	add    $0x14,%esp
f0102730:	5b                   	pop    %ebx
f0102731:	5e                   	pop    %esi
f0102732:	5f                   	pop    %edi
f0102733:	c9                   	leave  
f0102734:	c3                   	ret    

f0102735 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102735:	55                   	push   %ebp
f0102736:	89 e5                	mov    %esp,%ebp
f0102738:	57                   	push   %edi
f0102739:	56                   	push   %esi
f010273a:	53                   	push   %ebx
f010273b:	83 ec 2c             	sub    $0x2c,%esp
f010273e:	8b 75 08             	mov    0x8(%ebp),%esi
f0102741:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102744:	c7 03 5f 46 10 f0    	movl   $0xf010465f,(%ebx)
	info->eip_line = 0;
f010274a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102751:	c7 43 08 5f 46 10 f0 	movl   $0xf010465f,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102758:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010275f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102762:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102769:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010276f:	76 12                	jbe    f0102783 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102771:	b8 12 2a 11 f0       	mov    $0xf0112a12,%eax
f0102776:	3d 01 b2 10 f0       	cmp    $0xf010b201,%eax
f010277b:	0f 86 90 01 00 00    	jbe    f0102911 <debuginfo_eip+0x1dc>
f0102781:	eb 14                	jmp    f0102797 <debuginfo_eip+0x62>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102783:	83 ec 04             	sub    $0x4,%esp
f0102786:	68 69 46 10 f0       	push   $0xf0104669
f010278b:	6a 7f                	push   $0x7f
f010278d:	68 76 46 10 f0       	push   $0xf0104676
f0102792:	e8 f4 d8 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102797:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010279c:	80 3d 11 2a 11 f0 00 	cmpb   $0x0,0xf0112a11
f01027a3:	0f 85 74 01 00 00    	jne    f010291d <debuginfo_eip+0x1e8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01027a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01027b0:	b8 00 b2 10 f0       	mov    $0xf010b200,%eax
f01027b5:	2d 94 48 10 f0       	sub    $0xf0104894,%eax
f01027ba:	c1 f8 02             	sar    $0x2,%eax
f01027bd:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01027c3:	48                   	dec    %eax
f01027c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01027c7:	83 ec 08             	sub    $0x8,%esp
f01027ca:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01027cd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01027d0:	56                   	push   %esi
f01027d1:	6a 64                	push   $0x64
f01027d3:	b8 94 48 10 f0       	mov    $0xf0104894,%eax
f01027d8:	e8 33 fe ff ff       	call   f0102610 <stab_binsearch>
	if (lfile == 0)
f01027dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01027e0:	83 c4 10             	add    $0x10,%esp
		return -1;
f01027e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01027e8:	85 d2                	test   %edx,%edx
f01027ea:	0f 84 2d 01 00 00    	je     f010291d <debuginfo_eip+0x1e8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01027f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01027f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01027f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01027f9:	83 ec 08             	sub    $0x8,%esp
f01027fc:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01027ff:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102802:	56                   	push   %esi
f0102803:	6a 24                	push   $0x24
f0102805:	b8 94 48 10 f0       	mov    $0xf0104894,%eax
f010280a:	e8 01 fe ff ff       	call   f0102610 <stab_binsearch>

	if (lfun <= rfun) {
f010280f:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0102812:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102815:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102818:	83 c4 10             	add    $0x10,%esp
f010281b:	39 c7                	cmp    %eax,%edi
f010281d:	7f 32                	jg     f0102851 <debuginfo_eip+0x11c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010281f:	89 f9                	mov    %edi,%ecx
f0102821:	6b c7 0c             	imul   $0xc,%edi,%eax
f0102824:	8b 80 94 48 10 f0    	mov    -0xfefb76c(%eax),%eax
f010282a:	ba 12 2a 11 f0       	mov    $0xf0112a12,%edx
f010282f:	81 ea 01 b2 10 f0    	sub    $0xf010b201,%edx
f0102835:	39 d0                	cmp    %edx,%eax
f0102837:	73 08                	jae    f0102841 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102839:	05 01 b2 10 f0       	add    $0xf010b201,%eax
f010283e:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102841:	6b c9 0c             	imul   $0xc,%ecx,%ecx
f0102844:	8b 81 9c 48 10 f0    	mov    -0xfefb764(%ecx),%eax
f010284a:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010284d:	29 c6                	sub    %eax,%esi
f010284f:	eb 0c                	jmp    f010285d <debuginfo_eip+0x128>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102851:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102854:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
f0102857:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010285a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010285d:	83 ec 08             	sub    $0x8,%esp
f0102860:	6a 3a                	push   $0x3a
f0102862:	ff 73 08             	pushl  0x8(%ebx)
f0102865:	e8 9d 08 00 00       	call   f0103107 <strfind>
f010286a:	2b 43 08             	sub    0x8(%ebx),%eax
f010286d:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0102870:	89 7d dc             	mov    %edi,-0x24(%ebp)
    rfun = rline;
f0102873:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102876:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0102879:	83 c4 08             	add    $0x8,%esp
f010287c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010287f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102882:	56                   	push   %esi
f0102883:	6a 44                	push   $0x44
f0102885:	b8 94 48 10 f0       	mov    $0xf0104894,%eax
f010288a:	e8 81 fd ff ff       	call   f0102610 <stab_binsearch>
    if (lfun <= rfun) {
f010288f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102892:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0102895:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f010289a:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f010289d:	7f 7e                	jg     f010291d <debuginfo_eip+0x1e8>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f010289f:	6b c2 0c             	imul   $0xc,%edx,%eax
f01028a2:	05 94 48 10 f0       	add    $0xf0104894,%eax
f01028a7:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f01028ab:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01028ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01028b1:	83 c0 08             	add    $0x8,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01028b4:	eb 04                	jmp    f01028ba <debuginfo_eip+0x185>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01028b6:	4a                   	dec    %edx
f01028b7:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01028ba:	39 f2                	cmp    %esi,%edx
f01028bc:	7c 1b                	jl     f01028d9 <debuginfo_eip+0x1a4>
	       && stabs[lline].n_type != N_SOL
f01028be:	8a 48 fc             	mov    -0x4(%eax),%cl
f01028c1:	80 f9 84             	cmp    $0x84,%cl
f01028c4:	74 5f                	je     f0102925 <debuginfo_eip+0x1f0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01028c6:	80 f9 64             	cmp    $0x64,%cl
f01028c9:	75 eb                	jne    f01028b6 <debuginfo_eip+0x181>
f01028cb:	83 38 00             	cmpl   $0x0,(%eax)
f01028ce:	74 e6                	je     f01028b6 <debuginfo_eip+0x181>
f01028d0:	eb 53                	jmp    f0102925 <debuginfo_eip+0x1f0>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01028d2:	05 01 b2 10 f0       	add    $0xf010b201,%eax
f01028d7:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01028d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01028dc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01028df:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01028e4:	39 ca                	cmp    %ecx,%edx
f01028e6:	7d 35                	jge    f010291d <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
f01028e8:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01028eb:	6b d0 0c             	imul   $0xc,%eax,%edx
f01028ee:	81 c2 98 48 10 f0    	add    $0xf0104898,%edx
f01028f4:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01028f6:	eb 04                	jmp    f01028fc <debuginfo_eip+0x1c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01028f8:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01028fb:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01028fc:	39 f0                	cmp    %esi,%eax
f01028fe:	7d 18                	jge    f0102918 <debuginfo_eip+0x1e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102900:	8a 0a                	mov    (%edx),%cl
f0102902:	83 c2 0c             	add    $0xc,%edx
f0102905:	80 f9 a0             	cmp    $0xa0,%cl
f0102908:	74 ee                	je     f01028f8 <debuginfo_eip+0x1c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010290a:	b8 00 00 00 00       	mov    $0x0,%eax
f010290f:	eb 0c                	jmp    f010291d <debuginfo_eip+0x1e8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102911:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102916:	eb 05                	jmp    f010291d <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102918:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010291d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102920:	5b                   	pop    %ebx
f0102921:	5e                   	pop    %esi
f0102922:	5f                   	pop    %edi
f0102923:	c9                   	leave  
f0102924:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102925:	6b d2 0c             	imul   $0xc,%edx,%edx
f0102928:	8b 82 94 48 10 f0    	mov    -0xfefb76c(%edx),%eax
f010292e:	ba 12 2a 11 f0       	mov    $0xf0112a12,%edx
f0102933:	81 ea 01 b2 10 f0    	sub    $0xf010b201,%edx
f0102939:	39 d0                	cmp    %edx,%eax
f010293b:	72 95                	jb     f01028d2 <debuginfo_eip+0x19d>
f010293d:	eb 9a                	jmp    f01028d9 <debuginfo_eip+0x1a4>
	...

f0102940 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102940:	55                   	push   %ebp
f0102941:	89 e5                	mov    %esp,%ebp
f0102943:	57                   	push   %edi
f0102944:	56                   	push   %esi
f0102945:	53                   	push   %ebx
f0102946:	83 ec 2c             	sub    $0x2c,%esp
f0102949:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010294c:	89 d6                	mov    %edx,%esi
f010294e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102951:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102954:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102957:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010295a:	8b 45 10             	mov    0x10(%ebp),%eax
f010295d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102960:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102963:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102966:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010296d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102970:	72 0c                	jb     f010297e <printnum+0x3e>
f0102972:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0102975:	76 07                	jbe    f010297e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102977:	4b                   	dec    %ebx
f0102978:	85 db                	test   %ebx,%ebx
f010297a:	7f 31                	jg     f01029ad <printnum+0x6d>
f010297c:	eb 3f                	jmp    f01029bd <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010297e:	83 ec 0c             	sub    $0xc,%esp
f0102981:	57                   	push   %edi
f0102982:	4b                   	dec    %ebx
f0102983:	53                   	push   %ebx
f0102984:	50                   	push   %eax
f0102985:	83 ec 08             	sub    $0x8,%esp
f0102988:	ff 75 d4             	pushl  -0x2c(%ebp)
f010298b:	ff 75 d0             	pushl  -0x30(%ebp)
f010298e:	ff 75 dc             	pushl  -0x24(%ebp)
f0102991:	ff 75 d8             	pushl  -0x28(%ebp)
f0102994:	e8 97 09 00 00       	call   f0103330 <__udivdi3>
f0102999:	83 c4 18             	add    $0x18,%esp
f010299c:	52                   	push   %edx
f010299d:	50                   	push   %eax
f010299e:	89 f2                	mov    %esi,%edx
f01029a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01029a3:	e8 98 ff ff ff       	call   f0102940 <printnum>
f01029a8:	83 c4 20             	add    $0x20,%esp
f01029ab:	eb 10                	jmp    f01029bd <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01029ad:	83 ec 08             	sub    $0x8,%esp
f01029b0:	56                   	push   %esi
f01029b1:	57                   	push   %edi
f01029b2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01029b5:	4b                   	dec    %ebx
f01029b6:	83 c4 10             	add    $0x10,%esp
f01029b9:	85 db                	test   %ebx,%ebx
f01029bb:	7f f0                	jg     f01029ad <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01029bd:	83 ec 08             	sub    $0x8,%esp
f01029c0:	56                   	push   %esi
f01029c1:	83 ec 04             	sub    $0x4,%esp
f01029c4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01029c7:	ff 75 d0             	pushl  -0x30(%ebp)
f01029ca:	ff 75 dc             	pushl  -0x24(%ebp)
f01029cd:	ff 75 d8             	pushl  -0x28(%ebp)
f01029d0:	e8 77 0a 00 00       	call   f010344c <__umoddi3>
f01029d5:	83 c4 14             	add    $0x14,%esp
f01029d8:	0f be 80 84 46 10 f0 	movsbl -0xfefb97c(%eax),%eax
f01029df:	50                   	push   %eax
f01029e0:	ff 55 e4             	call   *-0x1c(%ebp)
f01029e3:	83 c4 10             	add    $0x10,%esp
}
f01029e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01029e9:	5b                   	pop    %ebx
f01029ea:	5e                   	pop    %esi
f01029eb:	5f                   	pop    %edi
f01029ec:	c9                   	leave  
f01029ed:	c3                   	ret    

f01029ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01029ee:	55                   	push   %ebp
f01029ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01029f1:	83 fa 01             	cmp    $0x1,%edx
f01029f4:	7e 0e                	jle    f0102a04 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01029f6:	8b 10                	mov    (%eax),%edx
f01029f8:	8d 4a 08             	lea    0x8(%edx),%ecx
f01029fb:	89 08                	mov    %ecx,(%eax)
f01029fd:	8b 02                	mov    (%edx),%eax
f01029ff:	8b 52 04             	mov    0x4(%edx),%edx
f0102a02:	eb 22                	jmp    f0102a26 <getuint+0x38>
	else if (lflag)
f0102a04:	85 d2                	test   %edx,%edx
f0102a06:	74 10                	je     f0102a18 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102a08:	8b 10                	mov    (%eax),%edx
f0102a0a:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102a0d:	89 08                	mov    %ecx,(%eax)
f0102a0f:	8b 02                	mov    (%edx),%eax
f0102a11:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a16:	eb 0e                	jmp    f0102a26 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102a18:	8b 10                	mov    (%eax),%edx
f0102a1a:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102a1d:	89 08                	mov    %ecx,(%eax)
f0102a1f:	8b 02                	mov    (%edx),%eax
f0102a21:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102a26:	c9                   	leave  
f0102a27:	c3                   	ret    

f0102a28 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0102a28:	55                   	push   %ebp
f0102a29:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102a2b:	83 fa 01             	cmp    $0x1,%edx
f0102a2e:	7e 0e                	jle    f0102a3e <getint+0x16>
		return va_arg(*ap, long long);
f0102a30:	8b 10                	mov    (%eax),%edx
f0102a32:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102a35:	89 08                	mov    %ecx,(%eax)
f0102a37:	8b 02                	mov    (%edx),%eax
f0102a39:	8b 52 04             	mov    0x4(%edx),%edx
f0102a3c:	eb 1a                	jmp    f0102a58 <getint+0x30>
	else if (lflag)
f0102a3e:	85 d2                	test   %edx,%edx
f0102a40:	74 0c                	je     f0102a4e <getint+0x26>
		return va_arg(*ap, long);
f0102a42:	8b 10                	mov    (%eax),%edx
f0102a44:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102a47:	89 08                	mov    %ecx,(%eax)
f0102a49:	8b 02                	mov    (%edx),%eax
f0102a4b:	99                   	cltd   
f0102a4c:	eb 0a                	jmp    f0102a58 <getint+0x30>
	else
		return va_arg(*ap, int);
f0102a4e:	8b 10                	mov    (%eax),%edx
f0102a50:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102a53:	89 08                	mov    %ecx,(%eax)
f0102a55:	8b 02                	mov    (%edx),%eax
f0102a57:	99                   	cltd   
}
f0102a58:	c9                   	leave  
f0102a59:	c3                   	ret    

f0102a5a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102a5a:	55                   	push   %ebp
f0102a5b:	89 e5                	mov    %esp,%ebp
f0102a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102a60:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0102a63:	8b 10                	mov    (%eax),%edx
f0102a65:	3b 50 04             	cmp    0x4(%eax),%edx
f0102a68:	73 08                	jae    f0102a72 <sprintputch+0x18>
		*b->buf++ = ch;
f0102a6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102a6d:	88 0a                	mov    %cl,(%edx)
f0102a6f:	42                   	inc    %edx
f0102a70:	89 10                	mov    %edx,(%eax)
}
f0102a72:	c9                   	leave  
f0102a73:	c3                   	ret    

f0102a74 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102a74:	55                   	push   %ebp
f0102a75:	89 e5                	mov    %esp,%ebp
f0102a77:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102a7a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102a7d:	50                   	push   %eax
f0102a7e:	ff 75 10             	pushl  0x10(%ebp)
f0102a81:	ff 75 0c             	pushl  0xc(%ebp)
f0102a84:	ff 75 08             	pushl  0x8(%ebp)
f0102a87:	e8 05 00 00 00       	call   f0102a91 <vprintfmt>
	va_end(ap);
f0102a8c:	83 c4 10             	add    $0x10,%esp
}
f0102a8f:	c9                   	leave  
f0102a90:	c3                   	ret    

f0102a91 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102a91:	55                   	push   %ebp
f0102a92:	89 e5                	mov    %esp,%ebp
f0102a94:	57                   	push   %edi
f0102a95:	56                   	push   %esi
f0102a96:	53                   	push   %ebx
f0102a97:	83 ec 2c             	sub    $0x2c,%esp
f0102a9a:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102a9d:	8b 75 10             	mov    0x10(%ebp),%esi
f0102aa0:	eb 13                	jmp    f0102ab5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102aa2:	85 c0                	test   %eax,%eax
f0102aa4:	0f 84 6d 03 00 00    	je     f0102e17 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f0102aaa:	83 ec 08             	sub    $0x8,%esp
f0102aad:	57                   	push   %edi
f0102aae:	50                   	push   %eax
f0102aaf:	ff 55 08             	call   *0x8(%ebp)
f0102ab2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102ab5:	0f b6 06             	movzbl (%esi),%eax
f0102ab8:	46                   	inc    %esi
f0102ab9:	83 f8 25             	cmp    $0x25,%eax
f0102abc:	75 e4                	jne    f0102aa2 <vprintfmt+0x11>
f0102abe:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0102ac2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102ac9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0102ad0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0102ad7:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102adc:	eb 28                	jmp    f0102b06 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ade:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102ae0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0102ae4:	eb 20                	jmp    f0102b06 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ae6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102ae8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0102aec:	eb 18                	jmp    f0102b06 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102aee:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0102af0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0102af7:	eb 0d                	jmp    f0102b06 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0102af9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102afc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102aff:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b06:	8a 06                	mov    (%esi),%al
f0102b08:	0f b6 d0             	movzbl %al,%edx
f0102b0b:	8d 5e 01             	lea    0x1(%esi),%ebx
f0102b0e:	83 e8 23             	sub    $0x23,%eax
f0102b11:	3c 55                	cmp    $0x55,%al
f0102b13:	0f 87 e0 02 00 00    	ja     f0102df9 <vprintfmt+0x368>
f0102b19:	0f b6 c0             	movzbl %al,%eax
f0102b1c:	ff 24 85 10 47 10 f0 	jmp    *-0xfefb8f0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102b23:	83 ea 30             	sub    $0x30,%edx
f0102b26:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0102b29:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0102b2c:	8d 50 d0             	lea    -0x30(%eax),%edx
f0102b2f:	83 fa 09             	cmp    $0x9,%edx
f0102b32:	77 44                	ja     f0102b78 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b34:	89 de                	mov    %ebx,%esi
f0102b36:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102b39:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0102b3a:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0102b3d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0102b41:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0102b44:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0102b47:	83 fb 09             	cmp    $0x9,%ebx
f0102b4a:	76 ed                	jbe    f0102b39 <vprintfmt+0xa8>
f0102b4c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102b4f:	eb 29                	jmp    f0102b7a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102b51:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b54:	8d 50 04             	lea    0x4(%eax),%edx
f0102b57:	89 55 14             	mov    %edx,0x14(%ebp)
f0102b5a:	8b 00                	mov    (%eax),%eax
f0102b5c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b5f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102b61:	eb 17                	jmp    f0102b7a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0102b63:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102b67:	78 85                	js     f0102aee <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b69:	89 de                	mov    %ebx,%esi
f0102b6b:	eb 99                	jmp    f0102b06 <vprintfmt+0x75>
f0102b6d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102b6f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0102b76:	eb 8e                	jmp    f0102b06 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b78:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0102b7a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102b7e:	79 86                	jns    f0102b06 <vprintfmt+0x75>
f0102b80:	e9 74 ff ff ff       	jmp    f0102af9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102b85:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b86:	89 de                	mov    %ebx,%esi
f0102b88:	e9 79 ff ff ff       	jmp    f0102b06 <vprintfmt+0x75>
f0102b8d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102b90:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b93:	8d 50 04             	lea    0x4(%eax),%edx
f0102b96:	89 55 14             	mov    %edx,0x14(%ebp)
f0102b99:	83 ec 08             	sub    $0x8,%esp
f0102b9c:	57                   	push   %edi
f0102b9d:	ff 30                	pushl  (%eax)
f0102b9f:	ff 55 08             	call   *0x8(%ebp)
			break;
f0102ba2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ba5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102ba8:	e9 08 ff ff ff       	jmp    f0102ab5 <vprintfmt+0x24>
f0102bad:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102bb0:	8b 45 14             	mov    0x14(%ebp),%eax
f0102bb3:	8d 50 04             	lea    0x4(%eax),%edx
f0102bb6:	89 55 14             	mov    %edx,0x14(%ebp)
f0102bb9:	8b 00                	mov    (%eax),%eax
f0102bbb:	85 c0                	test   %eax,%eax
f0102bbd:	79 02                	jns    f0102bc1 <vprintfmt+0x130>
f0102bbf:	f7 d8                	neg    %eax
f0102bc1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102bc3:	83 f8 06             	cmp    $0x6,%eax
f0102bc6:	7f 0b                	jg     f0102bd3 <vprintfmt+0x142>
f0102bc8:	8b 04 85 68 48 10 f0 	mov    -0xfefb798(,%eax,4),%eax
f0102bcf:	85 c0                	test   %eax,%eax
f0102bd1:	75 1a                	jne    f0102bed <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0102bd3:	52                   	push   %edx
f0102bd4:	68 9c 46 10 f0       	push   $0xf010469c
f0102bd9:	57                   	push   %edi
f0102bda:	ff 75 08             	pushl  0x8(%ebp)
f0102bdd:	e8 92 fe ff ff       	call   f0102a74 <printfmt>
f0102be2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102be5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102be8:	e9 c8 fe ff ff       	jmp    f0102ab5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0102bed:	50                   	push   %eax
f0102bee:	68 c4 43 10 f0       	push   $0xf01043c4
f0102bf3:	57                   	push   %edi
f0102bf4:	ff 75 08             	pushl  0x8(%ebp)
f0102bf7:	e8 78 fe ff ff       	call   f0102a74 <printfmt>
f0102bfc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102bff:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0102c02:	e9 ae fe ff ff       	jmp    f0102ab5 <vprintfmt+0x24>
f0102c07:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0102c0a:	89 de                	mov    %ebx,%esi
f0102c0c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102c0f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102c12:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c15:	8d 50 04             	lea    0x4(%eax),%edx
f0102c18:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c1b:	8b 00                	mov    (%eax),%eax
f0102c1d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102c20:	85 c0                	test   %eax,%eax
f0102c22:	75 07                	jne    f0102c2b <vprintfmt+0x19a>
				p = "(null)";
f0102c24:	c7 45 d0 95 46 10 f0 	movl   $0xf0104695,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0102c2b:	85 db                	test   %ebx,%ebx
f0102c2d:	7e 42                	jle    f0102c71 <vprintfmt+0x1e0>
f0102c2f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0102c33:	74 3c                	je     f0102c71 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102c35:	83 ec 08             	sub    $0x8,%esp
f0102c38:	51                   	push   %ecx
f0102c39:	ff 75 d0             	pushl  -0x30(%ebp)
f0102c3c:	e8 3f 03 00 00       	call   f0102f80 <strnlen>
f0102c41:	29 c3                	sub    %eax,%ebx
f0102c43:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102c46:	83 c4 10             	add    $0x10,%esp
f0102c49:	85 db                	test   %ebx,%ebx
f0102c4b:	7e 24                	jle    f0102c71 <vprintfmt+0x1e0>
					putch(padc, putdat);
f0102c4d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0102c51:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0102c54:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102c57:	83 ec 08             	sub    $0x8,%esp
f0102c5a:	57                   	push   %edi
f0102c5b:	53                   	push   %ebx
f0102c5c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102c5f:	4e                   	dec    %esi
f0102c60:	83 c4 10             	add    $0x10,%esp
f0102c63:	85 f6                	test   %esi,%esi
f0102c65:	7f f0                	jg     f0102c57 <vprintfmt+0x1c6>
f0102c67:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0102c6a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102c71:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102c74:	0f be 02             	movsbl (%edx),%eax
f0102c77:	85 c0                	test   %eax,%eax
f0102c79:	75 47                	jne    f0102cc2 <vprintfmt+0x231>
f0102c7b:	eb 37                	jmp    f0102cb4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f0102c7d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102c81:	74 16                	je     f0102c99 <vprintfmt+0x208>
f0102c83:	8d 50 e0             	lea    -0x20(%eax),%edx
f0102c86:	83 fa 5e             	cmp    $0x5e,%edx
f0102c89:	76 0e                	jbe    f0102c99 <vprintfmt+0x208>
					putch('?', putdat);
f0102c8b:	83 ec 08             	sub    $0x8,%esp
f0102c8e:	57                   	push   %edi
f0102c8f:	6a 3f                	push   $0x3f
f0102c91:	ff 55 08             	call   *0x8(%ebp)
f0102c94:	83 c4 10             	add    $0x10,%esp
f0102c97:	eb 0b                	jmp    f0102ca4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f0102c99:	83 ec 08             	sub    $0x8,%esp
f0102c9c:	57                   	push   %edi
f0102c9d:	50                   	push   %eax
f0102c9e:	ff 55 08             	call   *0x8(%ebp)
f0102ca1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102ca4:	ff 4d e4             	decl   -0x1c(%ebp)
f0102ca7:	0f be 03             	movsbl (%ebx),%eax
f0102caa:	85 c0                	test   %eax,%eax
f0102cac:	74 03                	je     f0102cb1 <vprintfmt+0x220>
f0102cae:	43                   	inc    %ebx
f0102caf:	eb 1b                	jmp    f0102ccc <vprintfmt+0x23b>
f0102cb1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102cb4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102cb8:	7f 1e                	jg     f0102cd8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cba:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0102cbd:	e9 f3 fd ff ff       	jmp    f0102ab5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102cc2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102cc5:	43                   	inc    %ebx
f0102cc6:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0102cc9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102ccc:	85 f6                	test   %esi,%esi
f0102cce:	78 ad                	js     f0102c7d <vprintfmt+0x1ec>
f0102cd0:	4e                   	dec    %esi
f0102cd1:	79 aa                	jns    f0102c7d <vprintfmt+0x1ec>
f0102cd3:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0102cd6:	eb dc                	jmp    f0102cb4 <vprintfmt+0x223>
f0102cd8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102cdb:	83 ec 08             	sub    $0x8,%esp
f0102cde:	57                   	push   %edi
f0102cdf:	6a 20                	push   $0x20
f0102ce1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102ce4:	4b                   	dec    %ebx
f0102ce5:	83 c4 10             	add    $0x10,%esp
f0102ce8:	85 db                	test   %ebx,%ebx
f0102cea:	7f ef                	jg     f0102cdb <vprintfmt+0x24a>
f0102cec:	e9 c4 fd ff ff       	jmp    f0102ab5 <vprintfmt+0x24>
f0102cf1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102cf4:	89 ca                	mov    %ecx,%edx
f0102cf6:	8d 45 14             	lea    0x14(%ebp),%eax
f0102cf9:	e8 2a fd ff ff       	call   f0102a28 <getint>
f0102cfe:	89 c3                	mov    %eax,%ebx
f0102d00:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0102d02:	85 d2                	test   %edx,%edx
f0102d04:	78 0a                	js     f0102d10 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102d06:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102d0b:	e9 b0 00 00 00       	jmp    f0102dc0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0102d10:	83 ec 08             	sub    $0x8,%esp
f0102d13:	57                   	push   %edi
f0102d14:	6a 2d                	push   $0x2d
f0102d16:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0102d19:	f7 db                	neg    %ebx
f0102d1b:	83 d6 00             	adc    $0x0,%esi
f0102d1e:	f7 de                	neg    %esi
f0102d20:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102d23:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102d28:	e9 93 00 00 00       	jmp    f0102dc0 <vprintfmt+0x32f>
f0102d2d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102d30:	89 ca                	mov    %ecx,%edx
f0102d32:	8d 45 14             	lea    0x14(%ebp),%eax
f0102d35:	e8 b4 fc ff ff       	call   f01029ee <getuint>
f0102d3a:	89 c3                	mov    %eax,%ebx
f0102d3c:	89 d6                	mov    %edx,%esi
			base = 10;
f0102d3e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0102d43:	eb 7b                	jmp    f0102dc0 <vprintfmt+0x32f>
f0102d45:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0102d48:	89 ca                	mov    %ecx,%edx
f0102d4a:	8d 45 14             	lea    0x14(%ebp),%eax
f0102d4d:	e8 d6 fc ff ff       	call   f0102a28 <getint>
f0102d52:	89 c3                	mov    %eax,%ebx
f0102d54:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f0102d56:	85 d2                	test   %edx,%edx
f0102d58:	78 07                	js     f0102d61 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f0102d5a:	b8 08 00 00 00       	mov    $0x8,%eax
f0102d5f:	eb 5f                	jmp    f0102dc0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0102d61:	83 ec 08             	sub    $0x8,%esp
f0102d64:	57                   	push   %edi
f0102d65:	6a 2d                	push   $0x2d
f0102d67:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f0102d6a:	f7 db                	neg    %ebx
f0102d6c:	83 d6 00             	adc    $0x0,%esi
f0102d6f:	f7 de                	neg    %esi
f0102d71:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f0102d74:	b8 08 00 00 00       	mov    $0x8,%eax
f0102d79:	eb 45                	jmp    f0102dc0 <vprintfmt+0x32f>
f0102d7b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f0102d7e:	83 ec 08             	sub    $0x8,%esp
f0102d81:	57                   	push   %edi
f0102d82:	6a 30                	push   $0x30
f0102d84:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0102d87:	83 c4 08             	add    $0x8,%esp
f0102d8a:	57                   	push   %edi
f0102d8b:	6a 78                	push   $0x78
f0102d8d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102d90:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d93:	8d 50 04             	lea    0x4(%eax),%edx
f0102d96:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102d99:	8b 18                	mov    (%eax),%ebx
f0102d9b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102da0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102da3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0102da8:	eb 16                	jmp    f0102dc0 <vprintfmt+0x32f>
f0102daa:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102dad:	89 ca                	mov    %ecx,%edx
f0102daf:	8d 45 14             	lea    0x14(%ebp),%eax
f0102db2:	e8 37 fc ff ff       	call   f01029ee <getuint>
f0102db7:	89 c3                	mov    %eax,%ebx
f0102db9:	89 d6                	mov    %edx,%esi
			base = 16;
f0102dbb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102dc0:	83 ec 0c             	sub    $0xc,%esp
f0102dc3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0102dc7:	52                   	push   %edx
f0102dc8:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102dcb:	50                   	push   %eax
f0102dcc:	56                   	push   %esi
f0102dcd:	53                   	push   %ebx
f0102dce:	89 fa                	mov    %edi,%edx
f0102dd0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102dd3:	e8 68 fb ff ff       	call   f0102940 <printnum>
			break;
f0102dd8:	83 c4 20             	add    $0x20,%esp
f0102ddb:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0102dde:	e9 d2 fc ff ff       	jmp    f0102ab5 <vprintfmt+0x24>
f0102de3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102de6:	83 ec 08             	sub    $0x8,%esp
f0102de9:	57                   	push   %edi
f0102dea:	52                   	push   %edx
f0102deb:	ff 55 08             	call   *0x8(%ebp)
			break;
f0102dee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102df1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102df4:	e9 bc fc ff ff       	jmp    f0102ab5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0102df9:	83 ec 08             	sub    $0x8,%esp
f0102dfc:	57                   	push   %edi
f0102dfd:	6a 25                	push   $0x25
f0102dff:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102e02:	83 c4 10             	add    $0x10,%esp
f0102e05:	eb 02                	jmp    f0102e09 <vprintfmt+0x378>
f0102e07:	89 c6                	mov    %eax,%esi
f0102e09:	8d 46 ff             	lea    -0x1(%esi),%eax
f0102e0c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0102e10:	75 f5                	jne    f0102e07 <vprintfmt+0x376>
f0102e12:	e9 9e fc ff ff       	jmp    f0102ab5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0102e17:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e1a:	5b                   	pop    %ebx
f0102e1b:	5e                   	pop    %esi
f0102e1c:	5f                   	pop    %edi
f0102e1d:	c9                   	leave  
f0102e1e:	c3                   	ret    

f0102e1f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102e1f:	55                   	push   %ebp
f0102e20:	89 e5                	mov    %esp,%ebp
f0102e22:	83 ec 18             	sub    $0x18,%esp
f0102e25:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e28:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102e2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102e2e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102e32:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102e35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102e3c:	85 c0                	test   %eax,%eax
f0102e3e:	74 26                	je     f0102e66 <vsnprintf+0x47>
f0102e40:	85 d2                	test   %edx,%edx
f0102e42:	7e 29                	jle    f0102e6d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102e44:	ff 75 14             	pushl  0x14(%ebp)
f0102e47:	ff 75 10             	pushl  0x10(%ebp)
f0102e4a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102e4d:	50                   	push   %eax
f0102e4e:	68 5a 2a 10 f0       	push   $0xf0102a5a
f0102e53:	e8 39 fc ff ff       	call   f0102a91 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102e58:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102e5b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102e61:	83 c4 10             	add    $0x10,%esp
f0102e64:	eb 0c                	jmp    f0102e72 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0102e66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0102e6b:	eb 05                	jmp    f0102e72 <vsnprintf+0x53>
f0102e6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102e72:	c9                   	leave  
f0102e73:	c3                   	ret    

f0102e74 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102e74:	55                   	push   %ebp
f0102e75:	89 e5                	mov    %esp,%ebp
f0102e77:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102e7a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102e7d:	50                   	push   %eax
f0102e7e:	ff 75 10             	pushl  0x10(%ebp)
f0102e81:	ff 75 0c             	pushl  0xc(%ebp)
f0102e84:	ff 75 08             	pushl  0x8(%ebp)
f0102e87:	e8 93 ff ff ff       	call   f0102e1f <vsnprintf>
	va_end(ap);

	return rc;
}
f0102e8c:	c9                   	leave  
f0102e8d:	c3                   	ret    
	...

f0102e90 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102e90:	55                   	push   %ebp
f0102e91:	89 e5                	mov    %esp,%ebp
f0102e93:	57                   	push   %edi
f0102e94:	56                   	push   %esi
f0102e95:	53                   	push   %ebx
f0102e96:	83 ec 0c             	sub    $0xc,%esp
f0102e99:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102e9c:	85 c0                	test   %eax,%eax
f0102e9e:	74 11                	je     f0102eb1 <readline+0x21>
		cprintf("%s", prompt);
f0102ea0:	83 ec 08             	sub    $0x8,%esp
f0102ea3:	50                   	push   %eax
f0102ea4:	68 c4 43 10 f0       	push   $0xf01043c4
f0102ea9:	e8 4b f7 ff ff       	call   f01025f9 <cprintf>
f0102eae:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0102eb1:	83 ec 0c             	sub    $0xc,%esp
f0102eb4:	6a 00                	push   $0x0
f0102eb6:	e8 0c d7 ff ff       	call   f01005c7 <iscons>
f0102ebb:	89 c7                	mov    %eax,%edi
f0102ebd:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0102ec0:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0102ec5:	e8 ec d6 ff ff       	call   f01005b6 <getchar>
f0102eca:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102ecc:	85 c0                	test   %eax,%eax
f0102ece:	79 18                	jns    f0102ee8 <readline+0x58>
			cprintf("read error: %e\n", c);
f0102ed0:	83 ec 08             	sub    $0x8,%esp
f0102ed3:	50                   	push   %eax
f0102ed4:	68 84 48 10 f0       	push   $0xf0104884
f0102ed9:	e8 1b f7 ff ff       	call   f01025f9 <cprintf>
			return NULL;
f0102ede:	83 c4 10             	add    $0x10,%esp
f0102ee1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ee6:	eb 6f                	jmp    f0102f57 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102ee8:	83 f8 08             	cmp    $0x8,%eax
f0102eeb:	74 05                	je     f0102ef2 <readline+0x62>
f0102eed:	83 f8 7f             	cmp    $0x7f,%eax
f0102ef0:	75 18                	jne    f0102f0a <readline+0x7a>
f0102ef2:	85 f6                	test   %esi,%esi
f0102ef4:	7e 14                	jle    f0102f0a <readline+0x7a>
			if (echoing)
f0102ef6:	85 ff                	test   %edi,%edi
f0102ef8:	74 0d                	je     f0102f07 <readline+0x77>
				cputchar('\b');
f0102efa:	83 ec 0c             	sub    $0xc,%esp
f0102efd:	6a 08                	push   $0x8
f0102eff:	e8 a2 d6 ff ff       	call   f01005a6 <cputchar>
f0102f04:	83 c4 10             	add    $0x10,%esp
			i--;
f0102f07:	4e                   	dec    %esi
f0102f08:	eb bb                	jmp    f0102ec5 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0102f0a:	83 fb 1f             	cmp    $0x1f,%ebx
f0102f0d:	7e 21                	jle    f0102f30 <readline+0xa0>
f0102f0f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102f15:	7f 19                	jg     f0102f30 <readline+0xa0>
			if (echoing)
f0102f17:	85 ff                	test   %edi,%edi
f0102f19:	74 0c                	je     f0102f27 <readline+0x97>
				cputchar(c);
f0102f1b:	83 ec 0c             	sub    $0xc,%esp
f0102f1e:	53                   	push   %ebx
f0102f1f:	e8 82 d6 ff ff       	call   f01005a6 <cputchar>
f0102f24:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0102f27:	88 9e 40 d5 11 f0    	mov    %bl,-0xfee2ac0(%esi)
f0102f2d:	46                   	inc    %esi
f0102f2e:	eb 95                	jmp    f0102ec5 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0102f30:	83 fb 0a             	cmp    $0xa,%ebx
f0102f33:	74 05                	je     f0102f3a <readline+0xaa>
f0102f35:	83 fb 0d             	cmp    $0xd,%ebx
f0102f38:	75 8b                	jne    f0102ec5 <readline+0x35>
			if (echoing)
f0102f3a:	85 ff                	test   %edi,%edi
f0102f3c:	74 0d                	je     f0102f4b <readline+0xbb>
				cputchar('\n');
f0102f3e:	83 ec 0c             	sub    $0xc,%esp
f0102f41:	6a 0a                	push   $0xa
f0102f43:	e8 5e d6 ff ff       	call   f01005a6 <cputchar>
f0102f48:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0102f4b:	c6 86 40 d5 11 f0 00 	movb   $0x0,-0xfee2ac0(%esi)
			return buf;
f0102f52:	b8 40 d5 11 f0       	mov    $0xf011d540,%eax
		}
	}
}
f0102f57:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f5a:	5b                   	pop    %ebx
f0102f5b:	5e                   	pop    %esi
f0102f5c:	5f                   	pop    %edi
f0102f5d:	c9                   	leave  
f0102f5e:	c3                   	ret    
	...

f0102f60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0102f60:	55                   	push   %ebp
f0102f61:	89 e5                	mov    %esp,%ebp
f0102f63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0102f66:	80 3a 00             	cmpb   $0x0,(%edx)
f0102f69:	74 0e                	je     f0102f79 <strlen+0x19>
f0102f6b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0102f70:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0102f71:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0102f75:	75 f9                	jne    f0102f70 <strlen+0x10>
f0102f77:	eb 05                	jmp    f0102f7e <strlen+0x1e>
f0102f79:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0102f7e:	c9                   	leave  
f0102f7f:	c3                   	ret    

f0102f80 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0102f80:	55                   	push   %ebp
f0102f81:	89 e5                	mov    %esp,%ebp
f0102f83:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102f86:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0102f89:	85 d2                	test   %edx,%edx
f0102f8b:	74 17                	je     f0102fa4 <strnlen+0x24>
f0102f8d:	80 39 00             	cmpb   $0x0,(%ecx)
f0102f90:	74 19                	je     f0102fab <strnlen+0x2b>
f0102f92:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0102f97:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0102f98:	39 d0                	cmp    %edx,%eax
f0102f9a:	74 14                	je     f0102fb0 <strnlen+0x30>
f0102f9c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0102fa0:	75 f5                	jne    f0102f97 <strnlen+0x17>
f0102fa2:	eb 0c                	jmp    f0102fb0 <strnlen+0x30>
f0102fa4:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fa9:	eb 05                	jmp    f0102fb0 <strnlen+0x30>
f0102fab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0102fb0:	c9                   	leave  
f0102fb1:	c3                   	ret    

f0102fb2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0102fb2:	55                   	push   %ebp
f0102fb3:	89 e5                	mov    %esp,%ebp
f0102fb5:	53                   	push   %ebx
f0102fb6:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fb9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0102fbc:	ba 00 00 00 00       	mov    $0x0,%edx
f0102fc1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0102fc4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0102fc7:	42                   	inc    %edx
f0102fc8:	84 c9                	test   %cl,%cl
f0102fca:	75 f5                	jne    f0102fc1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0102fcc:	5b                   	pop    %ebx
f0102fcd:	c9                   	leave  
f0102fce:	c3                   	ret    

f0102fcf <strcat>:

char *
strcat(char *dst, const char *src)
{
f0102fcf:	55                   	push   %ebp
f0102fd0:	89 e5                	mov    %esp,%ebp
f0102fd2:	53                   	push   %ebx
f0102fd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0102fd6:	53                   	push   %ebx
f0102fd7:	e8 84 ff ff ff       	call   f0102f60 <strlen>
f0102fdc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0102fdf:	ff 75 0c             	pushl  0xc(%ebp)
f0102fe2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0102fe5:	50                   	push   %eax
f0102fe6:	e8 c7 ff ff ff       	call   f0102fb2 <strcpy>
	return dst;
}
f0102feb:	89 d8                	mov    %ebx,%eax
f0102fed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102ff0:	c9                   	leave  
f0102ff1:	c3                   	ret    

f0102ff2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0102ff2:	55                   	push   %ebp
f0102ff3:	89 e5                	mov    %esp,%ebp
f0102ff5:	56                   	push   %esi
f0102ff6:	53                   	push   %ebx
f0102ff7:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ffa:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102ffd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103000:	85 f6                	test   %esi,%esi
f0103002:	74 15                	je     f0103019 <strncpy+0x27>
f0103004:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103009:	8a 1a                	mov    (%edx),%bl
f010300b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010300e:	80 3a 01             	cmpb   $0x1,(%edx)
f0103011:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103014:	41                   	inc    %ecx
f0103015:	39 ce                	cmp    %ecx,%esi
f0103017:	77 f0                	ja     f0103009 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103019:	5b                   	pop    %ebx
f010301a:	5e                   	pop    %esi
f010301b:	c9                   	leave  
f010301c:	c3                   	ret    

f010301d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010301d:	55                   	push   %ebp
f010301e:	89 e5                	mov    %esp,%ebp
f0103020:	57                   	push   %edi
f0103021:	56                   	push   %esi
f0103022:	53                   	push   %ebx
f0103023:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103026:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103029:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010302c:	85 f6                	test   %esi,%esi
f010302e:	74 32                	je     f0103062 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0103030:	83 fe 01             	cmp    $0x1,%esi
f0103033:	74 22                	je     f0103057 <strlcpy+0x3a>
f0103035:	8a 0b                	mov    (%ebx),%cl
f0103037:	84 c9                	test   %cl,%cl
f0103039:	74 20                	je     f010305b <strlcpy+0x3e>
f010303b:	89 f8                	mov    %edi,%eax
f010303d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0103042:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103045:	88 08                	mov    %cl,(%eax)
f0103047:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103048:	39 f2                	cmp    %esi,%edx
f010304a:	74 11                	je     f010305d <strlcpy+0x40>
f010304c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0103050:	42                   	inc    %edx
f0103051:	84 c9                	test   %cl,%cl
f0103053:	75 f0                	jne    f0103045 <strlcpy+0x28>
f0103055:	eb 06                	jmp    f010305d <strlcpy+0x40>
f0103057:	89 f8                	mov    %edi,%eax
f0103059:	eb 02                	jmp    f010305d <strlcpy+0x40>
f010305b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010305d:	c6 00 00             	movb   $0x0,(%eax)
f0103060:	eb 02                	jmp    f0103064 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103062:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0103064:	29 f8                	sub    %edi,%eax
}
f0103066:	5b                   	pop    %ebx
f0103067:	5e                   	pop    %esi
f0103068:	5f                   	pop    %edi
f0103069:	c9                   	leave  
f010306a:	c3                   	ret    

f010306b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010306b:	55                   	push   %ebp
f010306c:	89 e5                	mov    %esp,%ebp
f010306e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103071:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103074:	8a 01                	mov    (%ecx),%al
f0103076:	84 c0                	test   %al,%al
f0103078:	74 10                	je     f010308a <strcmp+0x1f>
f010307a:	3a 02                	cmp    (%edx),%al
f010307c:	75 0c                	jne    f010308a <strcmp+0x1f>
		p++, q++;
f010307e:	41                   	inc    %ecx
f010307f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103080:	8a 01                	mov    (%ecx),%al
f0103082:	84 c0                	test   %al,%al
f0103084:	74 04                	je     f010308a <strcmp+0x1f>
f0103086:	3a 02                	cmp    (%edx),%al
f0103088:	74 f4                	je     f010307e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010308a:	0f b6 c0             	movzbl %al,%eax
f010308d:	0f b6 12             	movzbl (%edx),%edx
f0103090:	29 d0                	sub    %edx,%eax
}
f0103092:	c9                   	leave  
f0103093:	c3                   	ret    

f0103094 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103094:	55                   	push   %ebp
f0103095:	89 e5                	mov    %esp,%ebp
f0103097:	53                   	push   %ebx
f0103098:	8b 55 08             	mov    0x8(%ebp),%edx
f010309b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010309e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01030a1:	85 c0                	test   %eax,%eax
f01030a3:	74 1b                	je     f01030c0 <strncmp+0x2c>
f01030a5:	8a 1a                	mov    (%edx),%bl
f01030a7:	84 db                	test   %bl,%bl
f01030a9:	74 24                	je     f01030cf <strncmp+0x3b>
f01030ab:	3a 19                	cmp    (%ecx),%bl
f01030ad:	75 20                	jne    f01030cf <strncmp+0x3b>
f01030af:	48                   	dec    %eax
f01030b0:	74 15                	je     f01030c7 <strncmp+0x33>
		n--, p++, q++;
f01030b2:	42                   	inc    %edx
f01030b3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01030b4:	8a 1a                	mov    (%edx),%bl
f01030b6:	84 db                	test   %bl,%bl
f01030b8:	74 15                	je     f01030cf <strncmp+0x3b>
f01030ba:	3a 19                	cmp    (%ecx),%bl
f01030bc:	74 f1                	je     f01030af <strncmp+0x1b>
f01030be:	eb 0f                	jmp    f01030cf <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01030c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01030c5:	eb 05                	jmp    f01030cc <strncmp+0x38>
f01030c7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01030cc:	5b                   	pop    %ebx
f01030cd:	c9                   	leave  
f01030ce:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01030cf:	0f b6 02             	movzbl (%edx),%eax
f01030d2:	0f b6 11             	movzbl (%ecx),%edx
f01030d5:	29 d0                	sub    %edx,%eax
f01030d7:	eb f3                	jmp    f01030cc <strncmp+0x38>

f01030d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01030d9:	55                   	push   %ebp
f01030da:	89 e5                	mov    %esp,%ebp
f01030dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01030df:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01030e2:	8a 10                	mov    (%eax),%dl
f01030e4:	84 d2                	test   %dl,%dl
f01030e6:	74 18                	je     f0103100 <strchr+0x27>
		if (*s == c)
f01030e8:	38 ca                	cmp    %cl,%dl
f01030ea:	75 06                	jne    f01030f2 <strchr+0x19>
f01030ec:	eb 17                	jmp    f0103105 <strchr+0x2c>
f01030ee:	38 ca                	cmp    %cl,%dl
f01030f0:	74 13                	je     f0103105 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01030f2:	40                   	inc    %eax
f01030f3:	8a 10                	mov    (%eax),%dl
f01030f5:	84 d2                	test   %dl,%dl
f01030f7:	75 f5                	jne    f01030ee <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f01030f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01030fe:	eb 05                	jmp    f0103105 <strchr+0x2c>
f0103100:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103105:	c9                   	leave  
f0103106:	c3                   	ret    

f0103107 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103107:	55                   	push   %ebp
f0103108:	89 e5                	mov    %esp,%ebp
f010310a:	8b 45 08             	mov    0x8(%ebp),%eax
f010310d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103110:	8a 10                	mov    (%eax),%dl
f0103112:	84 d2                	test   %dl,%dl
f0103114:	74 11                	je     f0103127 <strfind+0x20>
		if (*s == c)
f0103116:	38 ca                	cmp    %cl,%dl
f0103118:	75 06                	jne    f0103120 <strfind+0x19>
f010311a:	eb 0b                	jmp    f0103127 <strfind+0x20>
f010311c:	38 ca                	cmp    %cl,%dl
f010311e:	74 07                	je     f0103127 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103120:	40                   	inc    %eax
f0103121:	8a 10                	mov    (%eax),%dl
f0103123:	84 d2                	test   %dl,%dl
f0103125:	75 f5                	jne    f010311c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f0103127:	c9                   	leave  
f0103128:	c3                   	ret    

f0103129 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103129:	55                   	push   %ebp
f010312a:	89 e5                	mov    %esp,%ebp
f010312c:	57                   	push   %edi
f010312d:	56                   	push   %esi
f010312e:	53                   	push   %ebx
f010312f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103132:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103135:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103138:	85 c9                	test   %ecx,%ecx
f010313a:	74 30                	je     f010316c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010313c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103142:	75 25                	jne    f0103169 <memset+0x40>
f0103144:	f6 c1 03             	test   $0x3,%cl
f0103147:	75 20                	jne    f0103169 <memset+0x40>
		c &= 0xFF;
f0103149:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010314c:	89 d3                	mov    %edx,%ebx
f010314e:	c1 e3 08             	shl    $0x8,%ebx
f0103151:	89 d6                	mov    %edx,%esi
f0103153:	c1 e6 18             	shl    $0x18,%esi
f0103156:	89 d0                	mov    %edx,%eax
f0103158:	c1 e0 10             	shl    $0x10,%eax
f010315b:	09 f0                	or     %esi,%eax
f010315d:	09 d0                	or     %edx,%eax
f010315f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103161:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103164:	fc                   	cld    
f0103165:	f3 ab                	rep stos %eax,%es:(%edi)
f0103167:	eb 03                	jmp    f010316c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103169:	fc                   	cld    
f010316a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010316c:	89 f8                	mov    %edi,%eax
f010316e:	5b                   	pop    %ebx
f010316f:	5e                   	pop    %esi
f0103170:	5f                   	pop    %edi
f0103171:	c9                   	leave  
f0103172:	c3                   	ret    

f0103173 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103173:	55                   	push   %ebp
f0103174:	89 e5                	mov    %esp,%ebp
f0103176:	57                   	push   %edi
f0103177:	56                   	push   %esi
f0103178:	8b 45 08             	mov    0x8(%ebp),%eax
f010317b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010317e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103181:	39 c6                	cmp    %eax,%esi
f0103183:	73 34                	jae    f01031b9 <memmove+0x46>
f0103185:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103188:	39 d0                	cmp    %edx,%eax
f010318a:	73 2d                	jae    f01031b9 <memmove+0x46>
		s += n;
		d += n;
f010318c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010318f:	f6 c2 03             	test   $0x3,%dl
f0103192:	75 1b                	jne    f01031af <memmove+0x3c>
f0103194:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010319a:	75 13                	jne    f01031af <memmove+0x3c>
f010319c:	f6 c1 03             	test   $0x3,%cl
f010319f:	75 0e                	jne    f01031af <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01031a1:	83 ef 04             	sub    $0x4,%edi
f01031a4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01031a7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01031aa:	fd                   	std    
f01031ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01031ad:	eb 07                	jmp    f01031b6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01031af:	4f                   	dec    %edi
f01031b0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01031b3:	fd                   	std    
f01031b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01031b6:	fc                   	cld    
f01031b7:	eb 20                	jmp    f01031d9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01031b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01031bf:	75 13                	jne    f01031d4 <memmove+0x61>
f01031c1:	a8 03                	test   $0x3,%al
f01031c3:	75 0f                	jne    f01031d4 <memmove+0x61>
f01031c5:	f6 c1 03             	test   $0x3,%cl
f01031c8:	75 0a                	jne    f01031d4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01031ca:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01031cd:	89 c7                	mov    %eax,%edi
f01031cf:	fc                   	cld    
f01031d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01031d2:	eb 05                	jmp    f01031d9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01031d4:	89 c7                	mov    %eax,%edi
f01031d6:	fc                   	cld    
f01031d7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01031d9:	5e                   	pop    %esi
f01031da:	5f                   	pop    %edi
f01031db:	c9                   	leave  
f01031dc:	c3                   	ret    

f01031dd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01031dd:	55                   	push   %ebp
f01031de:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01031e0:	ff 75 10             	pushl  0x10(%ebp)
f01031e3:	ff 75 0c             	pushl  0xc(%ebp)
f01031e6:	ff 75 08             	pushl  0x8(%ebp)
f01031e9:	e8 85 ff ff ff       	call   f0103173 <memmove>
}
f01031ee:	c9                   	leave  
f01031ef:	c3                   	ret    

f01031f0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01031f0:	55                   	push   %ebp
f01031f1:	89 e5                	mov    %esp,%ebp
f01031f3:	57                   	push   %edi
f01031f4:	56                   	push   %esi
f01031f5:	53                   	push   %ebx
f01031f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01031f9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01031fc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01031ff:	85 ff                	test   %edi,%edi
f0103201:	74 32                	je     f0103235 <memcmp+0x45>
		if (*s1 != *s2)
f0103203:	8a 03                	mov    (%ebx),%al
f0103205:	8a 0e                	mov    (%esi),%cl
f0103207:	38 c8                	cmp    %cl,%al
f0103209:	74 19                	je     f0103224 <memcmp+0x34>
f010320b:	eb 0d                	jmp    f010321a <memcmp+0x2a>
f010320d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0103211:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0103215:	42                   	inc    %edx
f0103216:	38 c8                	cmp    %cl,%al
f0103218:	74 10                	je     f010322a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f010321a:	0f b6 c0             	movzbl %al,%eax
f010321d:	0f b6 c9             	movzbl %cl,%ecx
f0103220:	29 c8                	sub    %ecx,%eax
f0103222:	eb 16                	jmp    f010323a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103224:	4f                   	dec    %edi
f0103225:	ba 00 00 00 00       	mov    $0x0,%edx
f010322a:	39 fa                	cmp    %edi,%edx
f010322c:	75 df                	jne    f010320d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010322e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103233:	eb 05                	jmp    f010323a <memcmp+0x4a>
f0103235:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010323a:	5b                   	pop    %ebx
f010323b:	5e                   	pop    %esi
f010323c:	5f                   	pop    %edi
f010323d:	c9                   	leave  
f010323e:	c3                   	ret    

f010323f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010323f:	55                   	push   %ebp
f0103240:	89 e5                	mov    %esp,%ebp
f0103242:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103245:	89 c2                	mov    %eax,%edx
f0103247:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010324a:	39 d0                	cmp    %edx,%eax
f010324c:	73 12                	jae    f0103260 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f010324e:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0103251:	38 08                	cmp    %cl,(%eax)
f0103253:	75 06                	jne    f010325b <memfind+0x1c>
f0103255:	eb 09                	jmp    f0103260 <memfind+0x21>
f0103257:	38 08                	cmp    %cl,(%eax)
f0103259:	74 05                	je     f0103260 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010325b:	40                   	inc    %eax
f010325c:	39 c2                	cmp    %eax,%edx
f010325e:	77 f7                	ja     f0103257 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103260:	c9                   	leave  
f0103261:	c3                   	ret    

f0103262 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103262:	55                   	push   %ebp
f0103263:	89 e5                	mov    %esp,%ebp
f0103265:	57                   	push   %edi
f0103266:	56                   	push   %esi
f0103267:	53                   	push   %ebx
f0103268:	8b 55 08             	mov    0x8(%ebp),%edx
f010326b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010326e:	eb 01                	jmp    f0103271 <strtol+0xf>
		s++;
f0103270:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103271:	8a 02                	mov    (%edx),%al
f0103273:	3c 20                	cmp    $0x20,%al
f0103275:	74 f9                	je     f0103270 <strtol+0xe>
f0103277:	3c 09                	cmp    $0x9,%al
f0103279:	74 f5                	je     f0103270 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010327b:	3c 2b                	cmp    $0x2b,%al
f010327d:	75 08                	jne    f0103287 <strtol+0x25>
		s++;
f010327f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103280:	bf 00 00 00 00       	mov    $0x0,%edi
f0103285:	eb 13                	jmp    f010329a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103287:	3c 2d                	cmp    $0x2d,%al
f0103289:	75 0a                	jne    f0103295 <strtol+0x33>
		s++, neg = 1;
f010328b:	8d 52 01             	lea    0x1(%edx),%edx
f010328e:	bf 01 00 00 00       	mov    $0x1,%edi
f0103293:	eb 05                	jmp    f010329a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103295:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010329a:	85 db                	test   %ebx,%ebx
f010329c:	74 05                	je     f01032a3 <strtol+0x41>
f010329e:	83 fb 10             	cmp    $0x10,%ebx
f01032a1:	75 28                	jne    f01032cb <strtol+0x69>
f01032a3:	8a 02                	mov    (%edx),%al
f01032a5:	3c 30                	cmp    $0x30,%al
f01032a7:	75 10                	jne    f01032b9 <strtol+0x57>
f01032a9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01032ad:	75 0a                	jne    f01032b9 <strtol+0x57>
		s += 2, base = 16;
f01032af:	83 c2 02             	add    $0x2,%edx
f01032b2:	bb 10 00 00 00       	mov    $0x10,%ebx
f01032b7:	eb 12                	jmp    f01032cb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01032b9:	85 db                	test   %ebx,%ebx
f01032bb:	75 0e                	jne    f01032cb <strtol+0x69>
f01032bd:	3c 30                	cmp    $0x30,%al
f01032bf:	75 05                	jne    f01032c6 <strtol+0x64>
		s++, base = 8;
f01032c1:	42                   	inc    %edx
f01032c2:	b3 08                	mov    $0x8,%bl
f01032c4:	eb 05                	jmp    f01032cb <strtol+0x69>
	else if (base == 0)
		base = 10;
f01032c6:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01032cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01032d0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01032d2:	8a 0a                	mov    (%edx),%cl
f01032d4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01032d7:	80 fb 09             	cmp    $0x9,%bl
f01032da:	77 08                	ja     f01032e4 <strtol+0x82>
			dig = *s - '0';
f01032dc:	0f be c9             	movsbl %cl,%ecx
f01032df:	83 e9 30             	sub    $0x30,%ecx
f01032e2:	eb 1e                	jmp    f0103302 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01032e4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01032e7:	80 fb 19             	cmp    $0x19,%bl
f01032ea:	77 08                	ja     f01032f4 <strtol+0x92>
			dig = *s - 'a' + 10;
f01032ec:	0f be c9             	movsbl %cl,%ecx
f01032ef:	83 e9 57             	sub    $0x57,%ecx
f01032f2:	eb 0e                	jmp    f0103302 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01032f4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01032f7:	80 fb 19             	cmp    $0x19,%bl
f01032fa:	77 13                	ja     f010330f <strtol+0xad>
			dig = *s - 'A' + 10;
f01032fc:	0f be c9             	movsbl %cl,%ecx
f01032ff:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103302:	39 f1                	cmp    %esi,%ecx
f0103304:	7d 0d                	jge    f0103313 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f0103306:	42                   	inc    %edx
f0103307:	0f af c6             	imul   %esi,%eax
f010330a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f010330d:	eb c3                	jmp    f01032d2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010330f:	89 c1                	mov    %eax,%ecx
f0103311:	eb 02                	jmp    f0103315 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103313:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0103315:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103319:	74 05                	je     f0103320 <strtol+0xbe>
		*endptr = (char *) s;
f010331b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010331e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0103320:	85 ff                	test   %edi,%edi
f0103322:	74 04                	je     f0103328 <strtol+0xc6>
f0103324:	89 c8                	mov    %ecx,%eax
f0103326:	f7 d8                	neg    %eax
}
f0103328:	5b                   	pop    %ebx
f0103329:	5e                   	pop    %esi
f010332a:	5f                   	pop    %edi
f010332b:	c9                   	leave  
f010332c:	c3                   	ret    
f010332d:	00 00                	add    %al,(%eax)
	...

f0103330 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0103330:	55                   	push   %ebp
f0103331:	89 e5                	mov    %esp,%ebp
f0103333:	57                   	push   %edi
f0103334:	56                   	push   %esi
f0103335:	83 ec 10             	sub    $0x10,%esp
f0103338:	8b 7d 08             	mov    0x8(%ebp),%edi
f010333b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010333e:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0103341:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0103344:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103347:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010334a:	85 c0                	test   %eax,%eax
f010334c:	75 2e                	jne    f010337c <__udivdi3+0x4c>
    {
      if (d0 > n1)
f010334e:	39 f1                	cmp    %esi,%ecx
f0103350:	77 5a                	ja     f01033ac <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103352:	85 c9                	test   %ecx,%ecx
f0103354:	75 0b                	jne    f0103361 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103356:	b8 01 00 00 00       	mov    $0x1,%eax
f010335b:	31 d2                	xor    %edx,%edx
f010335d:	f7 f1                	div    %ecx
f010335f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0103361:	31 d2                	xor    %edx,%edx
f0103363:	89 f0                	mov    %esi,%eax
f0103365:	f7 f1                	div    %ecx
f0103367:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103369:	89 f8                	mov    %edi,%eax
f010336b:	f7 f1                	div    %ecx
f010336d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010336f:	89 f8                	mov    %edi,%eax
f0103371:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103373:	83 c4 10             	add    $0x10,%esp
f0103376:	5e                   	pop    %esi
f0103377:	5f                   	pop    %edi
f0103378:	c9                   	leave  
f0103379:	c3                   	ret    
f010337a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010337c:	39 f0                	cmp    %esi,%eax
f010337e:	77 1c                	ja     f010339c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103380:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f0103383:	83 f7 1f             	xor    $0x1f,%edi
f0103386:	75 3c                	jne    f01033c4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103388:	39 f0                	cmp    %esi,%eax
f010338a:	0f 82 90 00 00 00    	jb     f0103420 <__udivdi3+0xf0>
f0103390:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103393:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f0103396:	0f 86 84 00 00 00    	jbe    f0103420 <__udivdi3+0xf0>
f010339c:	31 f6                	xor    %esi,%esi
f010339e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01033a0:	89 f8                	mov    %edi,%eax
f01033a2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01033a4:	83 c4 10             	add    $0x10,%esp
f01033a7:	5e                   	pop    %esi
f01033a8:	5f                   	pop    %edi
f01033a9:	c9                   	leave  
f01033aa:	c3                   	ret    
f01033ab:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01033ac:	89 f2                	mov    %esi,%edx
f01033ae:	89 f8                	mov    %edi,%eax
f01033b0:	f7 f1                	div    %ecx
f01033b2:	89 c7                	mov    %eax,%edi
f01033b4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01033b6:	89 f8                	mov    %edi,%eax
f01033b8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01033ba:	83 c4 10             	add    $0x10,%esp
f01033bd:	5e                   	pop    %esi
f01033be:	5f                   	pop    %edi
f01033bf:	c9                   	leave  
f01033c0:	c3                   	ret    
f01033c1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01033c4:	89 f9                	mov    %edi,%ecx
f01033c6:	d3 e0                	shl    %cl,%eax
f01033c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01033cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01033d0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f01033d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01033d5:	88 c1                	mov    %al,%cl
f01033d7:	d3 ea                	shr    %cl,%edx
f01033d9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01033dc:	09 ca                	or     %ecx,%edx
f01033de:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f01033e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01033e4:	89 f9                	mov    %edi,%ecx
f01033e6:	d3 e2                	shl    %cl,%edx
f01033e8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f01033eb:	89 f2                	mov    %esi,%edx
f01033ed:	88 c1                	mov    %al,%cl
f01033ef:	d3 ea                	shr    %cl,%edx
f01033f1:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f01033f4:	89 f2                	mov    %esi,%edx
f01033f6:	89 f9                	mov    %edi,%ecx
f01033f8:	d3 e2                	shl    %cl,%edx
f01033fa:	8b 75 f0             	mov    -0x10(%ebp),%esi
f01033fd:	88 c1                	mov    %al,%cl
f01033ff:	d3 ee                	shr    %cl,%esi
f0103401:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103403:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103406:	89 f0                	mov    %esi,%eax
f0103408:	89 ca                	mov    %ecx,%edx
f010340a:	f7 75 ec             	divl   -0x14(%ebp)
f010340d:	89 d1                	mov    %edx,%ecx
f010340f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103411:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103414:	39 d1                	cmp    %edx,%ecx
f0103416:	72 28                	jb     f0103440 <__udivdi3+0x110>
f0103418:	74 1a                	je     f0103434 <__udivdi3+0x104>
f010341a:	89 f7                	mov    %esi,%edi
f010341c:	31 f6                	xor    %esi,%esi
f010341e:	eb 80                	jmp    f01033a0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103420:	31 f6                	xor    %esi,%esi
f0103422:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103427:	89 f8                	mov    %edi,%eax
f0103429:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010342b:	83 c4 10             	add    $0x10,%esp
f010342e:	5e                   	pop    %esi
f010342f:	5f                   	pop    %edi
f0103430:	c9                   	leave  
f0103431:	c3                   	ret    
f0103432:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0103434:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103437:	89 f9                	mov    %edi,%ecx
f0103439:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010343b:	39 c2                	cmp    %eax,%edx
f010343d:	73 db                	jae    f010341a <__udivdi3+0xea>
f010343f:	90                   	nop
		{
		  q0--;
f0103440:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103443:	31 f6                	xor    %esi,%esi
f0103445:	e9 56 ff ff ff       	jmp    f01033a0 <__udivdi3+0x70>
	...

f010344c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f010344c:	55                   	push   %ebp
f010344d:	89 e5                	mov    %esp,%ebp
f010344f:	57                   	push   %edi
f0103450:	56                   	push   %esi
f0103451:	83 ec 20             	sub    $0x20,%esp
f0103454:	8b 45 08             	mov    0x8(%ebp),%eax
f0103457:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010345a:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010345d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0103460:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103463:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0103466:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0103469:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010346b:	85 ff                	test   %edi,%edi
f010346d:	75 15                	jne    f0103484 <__umoddi3+0x38>
    {
      if (d0 > n1)
f010346f:	39 f1                	cmp    %esi,%ecx
f0103471:	0f 86 99 00 00 00    	jbe    f0103510 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103477:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0103479:	89 d0                	mov    %edx,%eax
f010347b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f010347d:	83 c4 20             	add    $0x20,%esp
f0103480:	5e                   	pop    %esi
f0103481:	5f                   	pop    %edi
f0103482:	c9                   	leave  
f0103483:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103484:	39 f7                	cmp    %esi,%edi
f0103486:	0f 87 a4 00 00 00    	ja     f0103530 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f010348c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f010348f:	83 f0 1f             	xor    $0x1f,%eax
f0103492:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103495:	0f 84 a1 00 00 00    	je     f010353c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f010349b:	89 f8                	mov    %edi,%eax
f010349d:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01034a0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01034a2:	bf 20 00 00 00       	mov    $0x20,%edi
f01034a7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f01034aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01034ad:	89 f9                	mov    %edi,%ecx
f01034af:	d3 ea                	shr    %cl,%edx
f01034b1:	09 c2                	or     %eax,%edx
f01034b3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f01034b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01034b9:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01034bc:	d3 e0                	shl    %cl,%eax
f01034be:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f01034c1:	89 f2                	mov    %esi,%edx
f01034c3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f01034c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01034c8:	d3 e0                	shl    %cl,%eax
f01034ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f01034cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01034d0:	89 f9                	mov    %edi,%ecx
f01034d2:	d3 e8                	shr    %cl,%eax
f01034d4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f01034d6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01034d8:	89 f2                	mov    %esi,%edx
f01034da:	f7 75 f0             	divl   -0x10(%ebp)
f01034dd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01034df:	f7 65 f4             	mull   -0xc(%ebp)
f01034e2:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01034e5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01034e7:	39 d6                	cmp    %edx,%esi
f01034e9:	72 71                	jb     f010355c <__umoddi3+0x110>
f01034eb:	74 7f                	je     f010356c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01034ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034f0:	29 c8                	sub    %ecx,%eax
f01034f2:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01034f4:	8a 4d ec             	mov    -0x14(%ebp),%cl
f01034f7:	d3 e8                	shr    %cl,%eax
f01034f9:	89 f2                	mov    %esi,%edx
f01034fb:	89 f9                	mov    %edi,%ecx
f01034fd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01034ff:	09 d0                	or     %edx,%eax
f0103501:	89 f2                	mov    %esi,%edx
f0103503:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103506:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103508:	83 c4 20             	add    $0x20,%esp
f010350b:	5e                   	pop    %esi
f010350c:	5f                   	pop    %edi
f010350d:	c9                   	leave  
f010350e:	c3                   	ret    
f010350f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103510:	85 c9                	test   %ecx,%ecx
f0103512:	75 0b                	jne    f010351f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103514:	b8 01 00 00 00       	mov    $0x1,%eax
f0103519:	31 d2                	xor    %edx,%edx
f010351b:	f7 f1                	div    %ecx
f010351d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010351f:	89 f0                	mov    %esi,%eax
f0103521:	31 d2                	xor    %edx,%edx
f0103523:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103525:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103528:	f7 f1                	div    %ecx
f010352a:	e9 4a ff ff ff       	jmp    f0103479 <__umoddi3+0x2d>
f010352f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0103530:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103532:	83 c4 20             	add    $0x20,%esp
f0103535:	5e                   	pop    %esi
f0103536:	5f                   	pop    %edi
f0103537:	c9                   	leave  
f0103538:	c3                   	ret    
f0103539:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010353c:	39 f7                	cmp    %esi,%edi
f010353e:	72 05                	jb     f0103545 <__umoddi3+0xf9>
f0103540:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0103543:	77 0c                	ja     f0103551 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103545:	89 f2                	mov    %esi,%edx
f0103547:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010354a:	29 c8                	sub    %ecx,%eax
f010354c:	19 fa                	sbb    %edi,%edx
f010354e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0103551:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103554:	83 c4 20             	add    $0x20,%esp
f0103557:	5e                   	pop    %esi
f0103558:	5f                   	pop    %edi
f0103559:	c9                   	leave  
f010355a:	c3                   	ret    
f010355b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f010355c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010355f:	89 c1                	mov    %eax,%ecx
f0103561:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0103564:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0103567:	eb 84                	jmp    f01034ed <__umoddi3+0xa1>
f0103569:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010356c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f010356f:	72 eb                	jb     f010355c <__umoddi3+0x110>
f0103571:	89 f2                	mov    %esi,%edx
f0103573:	e9 75 ff ff ff       	jmp    f01034ed <__umoddi3+0xa1>
