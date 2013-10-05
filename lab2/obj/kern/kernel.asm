
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
f0100015:	b8 00 c0 11 00       	mov    $0x11c000,%eax
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
f0100034:	bc 00 c0 11 f0       	mov    $0xf011c000,%esp

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
f0100046:	b8 50 e9 11 f0       	mov    $0xf011e950,%eax
f010004b:	2d 00 e3 11 f0       	sub    $0xf011e300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 e3 11 f0       	push   $0xf011e300
f0100058:	e8 28 37 00 00       	call   f0103785 <memset>

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
f010006a:	68 e0 3b 10 f0       	push   $0xf0103be0
f010006f:	e8 e1 2b 00 00       	call   f0102c55 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 5c 15 00 00       	call   f01015d5 <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 27 0d 00 00       	call   f0100dad <monitor>
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
f0100093:	83 3d 40 e9 11 f0 00 	cmpl   $0x0,0xf011e940
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 40 e9 11 f0    	mov    %esi,0xf011e940

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
f01000b0:	68 fb 3b 10 f0       	push   $0xf0103bfb
f01000b5:	e8 9b 2b 00 00       	call   f0102c55 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 6b 2b 00 00       	call   f0102c2f <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 c5 3e 10 f0 	movl   $0xf0103ec5,(%esp)
f01000cb:	e8 85 2b 00 00       	call   f0102c55 <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 d0 0c 00 00       	call   f0100dad <monitor>
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
f01000f2:	68 13 3c 10 f0       	push   $0xf0103c13
f01000f7:	e8 59 2b 00 00       	call   f0102c55 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 27 2b 00 00       	call   f0102c2f <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 c5 3e 10 f0 	movl   $0xf0103ec5,(%esp)
f010010f:	e8 41 2b 00 00       	call   f0102c55 <cprintf>
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
f0100155:	8b 15 24 e5 11 f0    	mov    0xf011e524,%edx
f010015b:	88 82 20 e3 11 f0    	mov    %al,-0xfee1ce0(%edx)
f0100161:	8d 42 01             	lea    0x1(%edx),%eax
f0100164:	a3 24 e5 11 f0       	mov    %eax,0xf011e524
		if (cons.wpos == CONSBUFSIZE)
f0100169:	3d 00 02 00 00       	cmp    $0x200,%eax
f010016e:	75 0a                	jne    f010017a <cons_intr+0x34>
			cons.wpos = 0;
f0100170:	c7 05 24 e5 11 f0 00 	movl   $0x0,0xf011e524
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
f01001f3:	a1 00 e3 11 f0       	mov    0xf011e300,%eax
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
f0100237:	66 a1 04 e3 11 f0    	mov    0xf011e304,%ax
f010023d:	66 85 c0             	test   %ax,%ax
f0100240:	0f 84 e0 00 00 00    	je     f0100326 <cons_putc+0x19f>
			crt_pos--;
f0100246:	48                   	dec    %eax
f0100247:	66 a3 04 e3 11 f0    	mov    %ax,0xf011e304
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010024d:	0f b7 c0             	movzwl %ax,%eax
f0100250:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100256:	83 ce 20             	or     $0x20,%esi
f0100259:	8b 15 08 e3 11 f0    	mov    0xf011e308,%edx
f010025f:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100263:	eb 78                	jmp    f01002dd <cons_putc+0x156>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100265:	66 83 05 04 e3 11 f0 	addw   $0x50,0xf011e304
f010026c:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010026d:	66 8b 0d 04 e3 11 f0 	mov    0xf011e304,%cx
f0100274:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100279:	89 c8                	mov    %ecx,%eax
f010027b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100280:	66 f7 f3             	div    %bx
f0100283:	66 29 d1             	sub    %dx,%cx
f0100286:	66 89 0d 04 e3 11 f0 	mov    %cx,0xf011e304
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
f01002c3:	66 a1 04 e3 11 f0    	mov    0xf011e304,%ax
f01002c9:	0f b7 c8             	movzwl %ax,%ecx
f01002cc:	8b 15 08 e3 11 f0    	mov    0xf011e308,%edx
f01002d2:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01002d6:	40                   	inc    %eax
f01002d7:	66 a3 04 e3 11 f0    	mov    %ax,0xf011e304
		break;
	}

	// What is the purpose of this?
    // out of cols, need to remove the top crt_buf
    if (crt_pos >= CRT_SIZE) {
f01002dd:	66 81 3d 04 e3 11 f0 	cmpw   $0x7cf,0xf011e304
f01002e4:	cf 07 
f01002e6:	76 3e                	jbe    f0100326 <cons_putc+0x19f>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01002e8:	a1 08 e3 11 f0       	mov    0xf011e308,%eax
f01002ed:	83 ec 04             	sub    $0x4,%esp
f01002f0:	68 00 0f 00 00       	push   $0xf00
f01002f5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01002fb:	52                   	push   %edx
f01002fc:	50                   	push   %eax
f01002fd:	e8 cd 34 00 00       	call   f01037cf <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100302:	8b 15 08 e3 11 f0    	mov    0xf011e308,%edx
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
f010031e:	66 83 2d 04 e3 11 f0 	subw   $0x50,0xf011e304
f0100325:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100326:	8b 0d 0c e3 11 f0    	mov    0xf011e30c,%ecx
f010032c:	b0 0e                	mov    $0xe,%al
f010032e:	89 ca                	mov    %ecx,%edx
f0100330:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100331:	66 8b 35 04 e3 11 f0 	mov    0xf011e304,%si
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
f0100374:	83 0d 28 e5 11 f0 40 	orl    $0x40,0xf011e528
		return 0;
f010037b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100380:	e9 c7 00 00 00       	jmp    f010044c <kbd_proc_data+0xf6>
	} else if (data & 0x80) {
f0100385:	84 c0                	test   %al,%al
f0100387:	79 33                	jns    f01003bc <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100389:	8b 0d 28 e5 11 f0    	mov    0xf011e528,%ecx
f010038f:	f6 c1 40             	test   $0x40,%cl
f0100392:	75 05                	jne    f0100399 <kbd_proc_data+0x43>
f0100394:	88 c2                	mov    %al,%dl
f0100396:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100399:	0f b6 d2             	movzbl %dl,%edx
f010039c:	8a 82 60 3c 10 f0    	mov    -0xfefc3a0(%edx),%al
f01003a2:	83 c8 40             	or     $0x40,%eax
f01003a5:	0f b6 c0             	movzbl %al,%eax
f01003a8:	f7 d0                	not    %eax
f01003aa:	21 c1                	and    %eax,%ecx
f01003ac:	89 0d 28 e5 11 f0    	mov    %ecx,0xf011e528
		return 0;
f01003b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003b7:	e9 90 00 00 00       	jmp    f010044c <kbd_proc_data+0xf6>
	} else if (shift & E0ESC) {
f01003bc:	8b 0d 28 e5 11 f0    	mov    0xf011e528,%ecx
f01003c2:	f6 c1 40             	test   $0x40,%cl
f01003c5:	74 0e                	je     f01003d5 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003c7:	88 c2                	mov    %al,%dl
f01003c9:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003cc:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003cf:	89 0d 28 e5 11 f0    	mov    %ecx,0xf011e528
	}

	shift |= shiftcode[data];
f01003d5:	0f b6 d2             	movzbl %dl,%edx
f01003d8:	0f b6 82 60 3c 10 f0 	movzbl -0xfefc3a0(%edx),%eax
f01003df:	0b 05 28 e5 11 f0    	or     0xf011e528,%eax
	shift ^= togglecode[data];
f01003e5:	0f b6 8a 60 3d 10 f0 	movzbl -0xfefc2a0(%edx),%ecx
f01003ec:	31 c8                	xor    %ecx,%eax
f01003ee:	a3 28 e5 11 f0       	mov    %eax,0xf011e528

	c = charcode[shift & (CTL | SHIFT)][data];
f01003f3:	89 c1                	mov    %eax,%ecx
f01003f5:	83 e1 03             	and    $0x3,%ecx
f01003f8:	8b 0c 8d 60 3e 10 f0 	mov    -0xfefc1a0(,%ecx,4),%ecx
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
f0100430:	68 2d 3c 10 f0       	push   $0xf0103c2d
f0100435:	e8 1b 28 00 00       	call   f0102c55 <cprintf>
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
f0100459:	80 3d 10 e3 11 f0 00 	cmpb   $0x0,0xf011e310
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
f0100490:	8b 15 20 e5 11 f0    	mov    0xf011e520,%edx
f0100496:	3b 15 24 e5 11 f0    	cmp    0xf011e524,%edx
f010049c:	74 22                	je     f01004c0 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010049e:	0f b6 82 20 e3 11 f0 	movzbl -0xfee1ce0(%edx),%eax
f01004a5:	42                   	inc    %edx
f01004a6:	89 15 20 e5 11 f0    	mov    %edx,0xf011e520
		if (cons.rpos == CONSBUFSIZE)
f01004ac:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004b2:	75 11                	jne    f01004c5 <cons_getc+0x45>
			cons.rpos = 0;
f01004b4:	c7 05 20 e5 11 f0 00 	movl   $0x0,0xf011e520
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
f01004ec:	c7 05 0c e3 11 f0 b4 	movl   $0x3b4,0xf011e30c
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
f0100504:	c7 05 0c e3 11 f0 d4 	movl   $0x3d4,0xf011e30c
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
f0100513:	8b 0d 0c e3 11 f0    	mov    0xf011e30c,%ecx
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
f0100532:	89 35 08 e3 11 f0    	mov    %esi,0xf011e308

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100538:	0f b6 d8             	movzbl %al,%ebx
f010053b:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010053d:	66 89 3d 04 e3 11 f0 	mov    %di,0xf011e304
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
f010057d:	a2 10 e3 11 f0       	mov    %al,0xf011e310
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
f0100591:	68 39 3c 10 f0       	push   $0xf0103c39
f0100596:	e8 ba 26 00 00       	call   f0102c55 <cprintf>
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
f01005da:	68 70 3e 10 f0       	push   $0xf0103e70
f01005df:	e8 71 26 00 00       	call   f0102c55 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005e4:	83 c4 08             	add    $0x8,%esp
f01005e7:	68 0c 00 10 00       	push   $0x10000c
f01005ec:	68 58 40 10 f0       	push   $0xf0104058
f01005f1:	e8 5f 26 00 00       	call   f0102c55 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01005f6:	83 c4 0c             	add    $0xc,%esp
f01005f9:	68 0c 00 10 00       	push   $0x10000c
f01005fe:	68 0c 00 10 f0       	push   $0xf010000c
f0100603:	68 80 40 10 f0       	push   $0xf0104080
f0100608:	e8 48 26 00 00       	call   f0102c55 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010060d:	83 c4 0c             	add    $0xc,%esp
f0100610:	68 d4 3b 10 00       	push   $0x103bd4
f0100615:	68 d4 3b 10 f0       	push   $0xf0103bd4
f010061a:	68 a4 40 10 f0       	push   $0xf01040a4
f010061f:	e8 31 26 00 00       	call   f0102c55 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100624:	83 c4 0c             	add    $0xc,%esp
f0100627:	68 00 e3 11 00       	push   $0x11e300
f010062c:	68 00 e3 11 f0       	push   $0xf011e300
f0100631:	68 c8 40 10 f0       	push   $0xf01040c8
f0100636:	e8 1a 26 00 00       	call   f0102c55 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010063b:	83 c4 0c             	add    $0xc,%esp
f010063e:	68 50 e9 11 00       	push   $0x11e950
f0100643:	68 50 e9 11 f0       	push   $0xf011e950
f0100648:	68 ec 40 10 f0       	push   $0xf01040ec
f010064d:	e8 03 26 00 00       	call   f0102c55 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100652:	b8 4f ed 11 f0       	mov    $0xf011ed4f,%eax
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
f0100674:	68 10 41 10 f0       	push   $0xf0104110
f0100679:	e8 d7 25 00 00       	call   f0102c55 <cprintf>
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
f0100688:	53                   	push   %ebx
f0100689:	83 ec 04             	sub    $0x4,%esp
f010068c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100691:	83 ec 04             	sub    $0x4,%esp
f0100694:	ff b3 64 45 10 f0    	pushl  -0xfefba9c(%ebx)
f010069a:	ff b3 60 45 10 f0    	pushl  -0xfefbaa0(%ebx)
f01006a0:	68 89 3e 10 f0       	push   $0xf0103e89
f01006a5:	e8 ab 25 00 00       	call   f0102c55 <cprintf>
f01006aa:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01006ad:	83 c4 10             	add    $0x10,%esp
f01006b0:	83 fb 54             	cmp    $0x54,%ebx
f01006b3:	75 dc                	jne    f0100691 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01006b5:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01006bd:	c9                   	leave  
f01006be:	c3                   	ret    

f01006bf <mon_showmappings>:
    return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f01006bf:	55                   	push   %ebp
f01006c0:	89 e5                	mov    %esp,%ebp
f01006c2:	57                   	push   %edi
f01006c3:	56                   	push   %esi
f01006c4:	53                   	push   %ebx
f01006c5:	83 ec 0c             	sub    $0xc,%esp
f01006c8:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 3) {
f01006cb:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01006cf:	74 21                	je     f01006f2 <mon_showmappings+0x33>
        cprintf("Command should be: showmappings [addr1] [addr2]\n");
f01006d1:	83 ec 0c             	sub    $0xc,%esp
f01006d4:	68 3c 41 10 f0       	push   $0xf010413c
f01006d9:	e8 77 25 00 00       	call   f0102c55 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f01006de:	c7 04 24 70 41 10 f0 	movl   $0xf0104170,(%esp)
f01006e5:	e8 6b 25 00 00       	call   f0102c55 <cprintf>
f01006ea:	83 c4 10             	add    $0x10,%esp
f01006ed:	e9 1a 01 00 00       	jmp    f010080c <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f01006f2:	83 ec 04             	sub    $0x4,%esp
f01006f5:	6a 00                	push   $0x0
f01006f7:	6a 00                	push   $0x0
f01006f9:	ff 76 04             	pushl  0x4(%esi)
f01006fc:	e8 bd 31 00 00       	call   f01038be <strtol>
f0100701:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f0100703:	83 c4 0c             	add    $0xc,%esp
f0100706:	6a 00                	push   $0x0
f0100708:	6a 00                	push   $0x0
f010070a:	ff 76 08             	pushl  0x8(%esi)
f010070d:	e8 ac 31 00 00       	call   f01038be <strtol>
        if (laddr > haddr) {
f0100712:	83 c4 10             	add    $0x10,%esp
f0100715:	39 c3                	cmp    %eax,%ebx
f0100717:	76 01                	jbe    f010071a <mon_showmappings+0x5b>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100719:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, PGSIZE);
f010071a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        haddr = ROUNDUP(haddr, PGSIZE);
f0100720:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f0100726:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
f010072c:	83 ec 04             	sub    $0x4,%esp
f010072f:	57                   	push   %edi
f0100730:	53                   	push   %ebx
f0100731:	68 92 3e 10 f0       	push   $0xf0103e92
f0100736:	e8 1a 25 00 00       	call   f0102c55 <cprintf>
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f010073b:	83 c4 10             	add    $0x10,%esp
f010073e:	39 fb                	cmp    %edi,%ebx
f0100740:	75 07                	jne    f0100749 <mon_showmappings+0x8a>
f0100742:	e9 c5 00 00 00       	jmp    f010080c <mon_showmappings+0x14d>
f0100747:	89 f3                	mov    %esi,%ebx
            cprintf("[ 0x%08x, 0x%08x ) -> ", now, now + PGSIZE); 
f0100749:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
f010074f:	83 ec 04             	sub    $0x4,%esp
f0100752:	56                   	push   %esi
f0100753:	53                   	push   %ebx
f0100754:	68 a3 3e 10 f0       	push   $0xf0103ea3
f0100759:	e8 f7 24 00 00       	call   f0102c55 <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f010075e:	83 c4 0c             	add    $0xc,%esp
f0100761:	6a 00                	push   $0x0
f0100763:	53                   	push   %ebx
f0100764:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f010076a:	e8 57 0c 00 00       	call   f01013c6 <pgdir_walk>
f010076f:	89 c3                	mov    %eax,%ebx
            if (pte == 0 || (*pte & PTE_P) == 0) {
f0100771:	83 c4 10             	add    $0x10,%esp
f0100774:	85 c0                	test   %eax,%eax
f0100776:	74 06                	je     f010077e <mon_showmappings+0xbf>
f0100778:	8b 00                	mov    (%eax),%eax
f010077a:	a8 01                	test   $0x1,%al
f010077c:	75 12                	jne    f0100790 <mon_showmappings+0xd1>
                cprintf(" no mapped \n");
f010077e:	83 ec 0c             	sub    $0xc,%esp
f0100781:	68 ba 3e 10 f0       	push   $0xf0103eba
f0100786:	e8 ca 24 00 00       	call   f0102c55 <cprintf>
f010078b:	83 c4 10             	add    $0x10,%esp
f010078e:	eb 74                	jmp    f0100804 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f0100790:	83 ec 08             	sub    $0x8,%esp
f0100793:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100798:	50                   	push   %eax
f0100799:	68 c7 3e 10 f0       	push   $0xf0103ec7
f010079e:	e8 b2 24 00 00       	call   f0102c55 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f01007a3:	83 c4 10             	add    $0x10,%esp
f01007a6:	f6 03 04             	testb  $0x4,(%ebx)
f01007a9:	74 12                	je     f01007bd <mon_showmappings+0xfe>
f01007ab:	83 ec 0c             	sub    $0xc,%esp
f01007ae:	68 cf 3e 10 f0       	push   $0xf0103ecf
f01007b3:	e8 9d 24 00 00       	call   f0102c55 <cprintf>
f01007b8:	83 c4 10             	add    $0x10,%esp
f01007bb:	eb 10                	jmp    f01007cd <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f01007bd:	83 ec 0c             	sub    $0xc,%esp
f01007c0:	68 dc 3e 10 f0       	push   $0xf0103edc
f01007c5:	e8 8b 24 00 00       	call   f0102c55 <cprintf>
f01007ca:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f01007cd:	f6 03 02             	testb  $0x2,(%ebx)
f01007d0:	74 12                	je     f01007e4 <mon_showmappings+0x125>
f01007d2:	83 ec 0c             	sub    $0xc,%esp
f01007d5:	68 e9 3e 10 f0       	push   $0xf0103ee9
f01007da:	e8 76 24 00 00       	call   f0102c55 <cprintf>
f01007df:	83 c4 10             	add    $0x10,%esp
f01007e2:	eb 10                	jmp    f01007f4 <mon_showmappings+0x135>
                else cprintf(" R ");
f01007e4:	83 ec 0c             	sub    $0xc,%esp
f01007e7:	68 ee 3e 10 f0       	push   $0xf0103eee
f01007ec:	e8 64 24 00 00       	call   f0102c55 <cprintf>
f01007f1:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f01007f4:	83 ec 0c             	sub    $0xc,%esp
f01007f7:	68 c5 3e 10 f0       	push   $0xf0103ec5
f01007fc:	e8 54 24 00 00       	call   f0102c55 <cprintf>
f0100801:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDUP(haddr, PGSIZE);
        cprintf("0x%08x - 0x%08x\n", laddr, haddr);
        
        uint32_t now;
        pte_t *pte;
        for (now = laddr; now != haddr; now += PGSIZE) {
f0100804:	39 f7                	cmp    %esi,%edi
f0100806:	0f 85 3b ff ff ff    	jne    f0100747 <mon_showmappings+0x88>
                cprintf("\n");
            }
        }
    }
    return 0;
}
f010080c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100811:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100814:	5b                   	pop    %ebx
f0100815:	5e                   	pop    %esi
f0100816:	5f                   	pop    %edi
f0100817:	c9                   	leave  
f0100818:	c3                   	ret    

f0100819 <mon_setpermission>:
    return 0;
}

int
mon_setpermission(int argc, char **argv, struct Trapframe *tf)
{
f0100819:	55                   	push   %ebp
f010081a:	89 e5                	mov    %esp,%ebp
f010081c:	57                   	push   %edi
f010081d:	56                   	push   %esi
f010081e:	53                   	push   %ebx
f010081f:	83 ec 0c             	sub    $0xc,%esp
f0100822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 5) { 
f0100825:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f0100829:	74 21                	je     f010084c <mon_setpermission+0x33>
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
f010082b:	83 ec 0c             	sub    $0xc,%esp
f010082e:	68 98 41 10 f0       	push   $0xf0104198
f0100833:	e8 1d 24 00 00       	call   f0102c55 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f0100838:	c7 04 24 e8 41 10 f0 	movl   $0xf01041e8,(%esp)
f010083f:	e8 11 24 00 00       	call   f0102c55 <cprintf>
f0100844:	83 c4 10             	add    $0x10,%esp
f0100847:	e9 a5 01 00 00       	jmp    f01009f1 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f010084c:	83 ec 04             	sub    $0x4,%esp
f010084f:	6a 00                	push   $0x0
f0100851:	6a 00                	push   $0x0
f0100853:	ff 73 04             	pushl  0x4(%ebx)
f0100856:	e8 63 30 00 00       	call   f01038be <strtol>
        uint32_t perm = 0;
        if (argv[2][0] == '1') perm |= PTE_W;
f010085b:	8b 53 08             	mov    0x8(%ebx),%edx
f010085e:	83 c4 10             	add    $0x10,%esp
    if (argc != 5) { 
        cprintf("Command should be: setpermissions [virtual addr] [W (0/1)] [U (0/1)] [P (0/1)]\n");
        cprintf("Example: setpermissions 0x0 1 0 1\n");
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
        uint32_t perm = 0;
f0100861:	80 3a 31             	cmpb   $0x31,(%edx)
f0100864:	0f 94 c2             	sete   %dl
f0100867:	0f b6 d2             	movzbl %dl,%edx
f010086a:	89 d6                	mov    %edx,%esi
f010086c:	d1 e6                	shl    %esi
        if (argv[2][0] == '1') perm |= PTE_W;
        if (argv[3][0] == '1') perm |= PTE_U;
f010086e:	8b 53 0c             	mov    0xc(%ebx),%edx
f0100871:	80 3a 31             	cmpb   $0x31,(%edx)
f0100874:	75 03                	jne    f0100879 <mon_setpermission+0x60>
f0100876:	83 ce 04             	or     $0x4,%esi
        if (argv[4][0] == '1') perm |= PTE_P;
f0100879:	8b 53 10             	mov    0x10(%ebx),%edx
f010087c:	80 3a 31             	cmpb   $0x31,(%edx)
f010087f:	75 03                	jne    f0100884 <mon_setpermission+0x6b>
f0100881:	83 ce 01             	or     $0x1,%esi
        addr = ROUNDUP(addr, PGSIZE);
f0100884:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f010088a:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
f0100890:	83 ec 04             	sub    $0x4,%esp
f0100893:	6a 00                	push   $0x0
f0100895:	57                   	push   %edi
f0100896:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f010089c:	e8 25 0b 00 00       	call   f01013c6 <pgdir_walk>
f01008a1:	89 c3                	mov    %eax,%ebx
        if (pte != NULL) {
f01008a3:	83 c4 10             	add    $0x10,%esp
f01008a6:	85 c0                	test   %eax,%eax
f01008a8:	0f 84 33 01 00 00    	je     f01009e1 <mon_setpermission+0x1c8>
            cprintf("0x%08x -> pa: 0x%08x\n old_perm: ", addr, PTE_ADDR(*pte));
f01008ae:	83 ec 04             	sub    $0x4,%esp
f01008b1:	8b 00                	mov    (%eax),%eax
f01008b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008b8:	50                   	push   %eax
f01008b9:	57                   	push   %edi
f01008ba:	68 0c 42 10 f0       	push   $0xf010420c
f01008bf:	e8 91 23 00 00       	call   f0102c55 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f01008c4:	83 c4 10             	add    $0x10,%esp
f01008c7:	f6 03 02             	testb  $0x2,(%ebx)
f01008ca:	74 12                	je     f01008de <mon_setpermission+0xc5>
f01008cc:	83 ec 0c             	sub    $0xc,%esp
f01008cf:	68 f2 3e 10 f0       	push   $0xf0103ef2
f01008d4:	e8 7c 23 00 00       	call   f0102c55 <cprintf>
f01008d9:	83 c4 10             	add    $0x10,%esp
f01008dc:	eb 10                	jmp    f01008ee <mon_setpermission+0xd5>
f01008de:	83 ec 0c             	sub    $0xc,%esp
f01008e1:	68 f5 3e 10 f0       	push   $0xf0103ef5
f01008e6:	e8 6a 23 00 00       	call   f0102c55 <cprintf>
f01008eb:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f01008ee:	f6 03 04             	testb  $0x4,(%ebx)
f01008f1:	74 12                	je     f0100905 <mon_setpermission+0xec>
f01008f3:	83 ec 0c             	sub    $0xc,%esp
f01008f6:	68 c6 4e 10 f0       	push   $0xf0104ec6
f01008fb:	e8 55 23 00 00       	call   f0102c55 <cprintf>
f0100900:	83 c4 10             	add    $0x10,%esp
f0100903:	eb 10                	jmp    f0100915 <mon_setpermission+0xfc>
f0100905:	83 ec 0c             	sub    $0xc,%esp
f0100908:	68 f8 3e 10 f0       	push   $0xf0103ef8
f010090d:	e8 43 23 00 00       	call   f0102c55 <cprintf>
f0100912:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100915:	f6 03 01             	testb  $0x1,(%ebx)
f0100918:	74 12                	je     f010092c <mon_setpermission+0x113>
f010091a:	83 ec 0c             	sub    $0xc,%esp
f010091d:	68 52 4f 10 f0       	push   $0xf0104f52
f0100922:	e8 2e 23 00 00       	call   f0102c55 <cprintf>
f0100927:	83 c4 10             	add    $0x10,%esp
f010092a:	eb 10                	jmp    f010093c <mon_setpermission+0x123>
f010092c:	83 ec 0c             	sub    $0xc,%esp
f010092f:	68 f6 3e 10 f0       	push   $0xf0103ef6
f0100934:	e8 1c 23 00 00       	call   f0102c55 <cprintf>
f0100939:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f010093c:	83 ec 0c             	sub    $0xc,%esp
f010093f:	68 fa 3e 10 f0       	push   $0xf0103efa
f0100944:	e8 0c 23 00 00       	call   f0102c55 <cprintf>
            *pte = PTE_ADDR(*pte) | perm;     
f0100949:	8b 03                	mov    (%ebx),%eax
f010094b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100950:	09 c6                	or     %eax,%esi
f0100952:	89 33                	mov    %esi,(%ebx)
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f0100954:	83 c4 10             	add    $0x10,%esp
f0100957:	f7 c6 02 00 00 00    	test   $0x2,%esi
f010095d:	74 12                	je     f0100971 <mon_setpermission+0x158>
f010095f:	83 ec 0c             	sub    $0xc,%esp
f0100962:	68 f2 3e 10 f0       	push   $0xf0103ef2
f0100967:	e8 e9 22 00 00       	call   f0102c55 <cprintf>
f010096c:	83 c4 10             	add    $0x10,%esp
f010096f:	eb 10                	jmp    f0100981 <mon_setpermission+0x168>
f0100971:	83 ec 0c             	sub    $0xc,%esp
f0100974:	68 f5 3e 10 f0       	push   $0xf0103ef5
f0100979:	e8 d7 22 00 00       	call   f0102c55 <cprintf>
f010097e:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100981:	f6 03 04             	testb  $0x4,(%ebx)
f0100984:	74 12                	je     f0100998 <mon_setpermission+0x17f>
f0100986:	83 ec 0c             	sub    $0xc,%esp
f0100989:	68 c6 4e 10 f0       	push   $0xf0104ec6
f010098e:	e8 c2 22 00 00       	call   f0102c55 <cprintf>
f0100993:	83 c4 10             	add    $0x10,%esp
f0100996:	eb 10                	jmp    f01009a8 <mon_setpermission+0x18f>
f0100998:	83 ec 0c             	sub    $0xc,%esp
f010099b:	68 f8 3e 10 f0       	push   $0xf0103ef8
f01009a0:	e8 b0 22 00 00       	call   f0102c55 <cprintf>
f01009a5:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f01009a8:	f6 03 01             	testb  $0x1,(%ebx)
f01009ab:	74 12                	je     f01009bf <mon_setpermission+0x1a6>
f01009ad:	83 ec 0c             	sub    $0xc,%esp
f01009b0:	68 52 4f 10 f0       	push   $0xf0104f52
f01009b5:	e8 9b 22 00 00       	call   f0102c55 <cprintf>
f01009ba:	83 c4 10             	add    $0x10,%esp
f01009bd:	eb 10                	jmp    f01009cf <mon_setpermission+0x1b6>
f01009bf:	83 ec 0c             	sub    $0xc,%esp
f01009c2:	68 f6 3e 10 f0       	push   $0xf0103ef6
f01009c7:	e8 89 22 00 00       	call   f0102c55 <cprintf>
f01009cc:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f01009cf:	83 ec 0c             	sub    $0xc,%esp
f01009d2:	68 c5 3e 10 f0       	push   $0xf0103ec5
f01009d7:	e8 79 22 00 00       	call   f0102c55 <cprintf>
f01009dc:	83 c4 10             	add    $0x10,%esp
f01009df:	eb 10                	jmp    f01009f1 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f01009e1:	83 ec 0c             	sub    $0xc,%esp
f01009e4:	68 ba 3e 10 f0       	push   $0xf0103eba
f01009e9:	e8 67 22 00 00       	call   f0102c55 <cprintf>
f01009ee:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f01009f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01009f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009f9:	5b                   	pop    %ebx
f01009fa:	5e                   	pop    %esi
f01009fb:	5f                   	pop    %edi
f01009fc:	c9                   	leave  
f01009fd:	c3                   	ret    

f01009fe <mon_setcolor>:
    return 0;
}

int
mon_setcolor(int argc, char **argv, struct Trapframe *tf)
{
f01009fe:	55                   	push   %ebp
f01009ff:	89 e5                	mov    %esp,%ebp
f0100a01:	56                   	push   %esi
f0100a02:	53                   	push   %ebx
f0100a03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (argc != 2) {
f0100a06:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100a0a:	74 66                	je     f0100a72 <mon_setcolor+0x74>
        cprintf("Command should be: setcolor [binary number]\n");
f0100a0c:	83 ec 0c             	sub    $0xc,%esp
f0100a0f:	68 30 42 10 f0       	push   $0xf0104230
f0100a14:	e8 3c 22 00 00       	call   f0102c55 <cprintf>
        cprintf("num show the color attribute. \n");
f0100a19:	c7 04 24 60 42 10 f0 	movl   $0xf0104260,(%esp)
f0100a20:	e8 30 22 00 00       	call   f0102c55 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100a25:	c7 04 24 80 42 10 f0 	movl   $0xf0104280,(%esp)
f0100a2c:	e8 24 22 00 00       	call   f0102c55 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100a31:	c7 04 24 b4 42 10 f0 	movl   $0xf01042b4,(%esp)
f0100a38:	e8 18 22 00 00       	call   f0102c55 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100a3d:	c7 04 24 f8 42 10 f0 	movl   $0xf01042f8,(%esp)
f0100a44:	e8 0c 22 00 00       	call   f0102c55 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100a49:	c7 04 24 0b 3f 10 f0 	movl   $0xf0103f0b,(%esp)
f0100a50:	e8 00 22 00 00       	call   f0102c55 <cprintf>
        cprintf("         set the background color to black\n");
f0100a55:	c7 04 24 3c 43 10 f0 	movl   $0xf010433c,(%esp)
f0100a5c:	e8 f4 21 00 00       	call   f0102c55 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100a61:	c7 04 24 68 43 10 f0 	movl   $0xf0104368,(%esp)
f0100a68:	e8 e8 21 00 00       	call   f0102c55 <cprintf>
f0100a6d:	83 c4 10             	add    $0x10,%esp
f0100a70:	eb 52                	jmp    f0100ac4 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100a72:	83 ec 0c             	sub    $0xc,%esp
f0100a75:	ff 73 04             	pushl  0x4(%ebx)
f0100a78:	e8 3f 2b 00 00       	call   f01035bc <strlen>
f0100a7d:	83 c4 10             	add    $0x10,%esp
f0100a80:	48                   	dec    %eax
f0100a81:	78 26                	js     f0100aa9 <mon_setcolor+0xab>
            colnum += (argv[1][i] == '1') << len;
f0100a83:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100a86:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100a8b:	b9 00 00 00 00       	mov    $0x0,%ecx
            colnum += (argv[1][i] == '1') << len;
f0100a90:	80 3c 06 31          	cmpb   $0x31,(%esi,%eax,1)
f0100a94:	0f 94 c3             	sete   %bl
f0100a97:	0f b6 db             	movzbl %bl,%ebx
f0100a9a:	d3 e3                	shl    %cl,%ebx
f0100a9c:	01 da                	add    %ebx,%edx
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100a9e:	48                   	dec    %eax
f0100a9f:	78 0d                	js     f0100aae <mon_setcolor+0xb0>
f0100aa1:	41                   	inc    %ecx
f0100aa2:	83 f9 08             	cmp    $0x8,%ecx
f0100aa5:	75 e9                	jne    f0100a90 <mon_setcolor+0x92>
f0100aa7:	eb 05                	jmp    f0100aae <mon_setcolor+0xb0>
        cprintf("Example: setcolor 00001111\n");
        cprintf("         set the background color to black\n");
        cprintf("         set the foreground color to intense white\n");
    } else {
        int i, len;
        int colnum = 0;
f0100aa9:	ba 00 00 00 00       	mov    $0x0,%edx
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
            colnum += (argv[1][i] == '1') << len;
        user_setcolor = colnum;
f0100aae:	89 15 00 e3 11 f0    	mov    %edx,0xf011e300
        cprintf(" This is color that you want ! \n");
f0100ab4:	83 ec 0c             	sub    $0xc,%esp
f0100ab7:	68 9c 43 10 f0       	push   $0xf010439c
f0100abc:	e8 94 21 00 00       	call   f0102c55 <cprintf>
f0100ac1:	83 c4 10             	add    $0x10,%esp
    }
    return 0;
}
f0100ac4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ac9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100acc:	5b                   	pop    %ebx
f0100acd:	5e                   	pop    %esi
f0100ace:	c9                   	leave  
f0100acf:	c3                   	ret    

f0100ad0 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{ 
f0100ad0:	55                   	push   %ebp
f0100ad1:	89 e5                	mov    %esp,%ebp
f0100ad3:	57                   	push   %edi
f0100ad4:	56                   	push   %esi
f0100ad5:	53                   	push   %ebx
f0100ad6:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100ad9:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100adb:	89 c6                	mov    %eax,%esi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100add:	85 c0                	test   %eax,%eax
f0100adf:	74 6d                	je     f0100b4e <mon_backtrace+0x7e>
        eip = *(ebp + 1);
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100ae1:	8d 7d d0             	lea    -0x30(%ebp),%edi
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
        eip = *(ebp + 1);
f0100ae4:	8b 5e 04             	mov    0x4(%esi),%ebx
        // arg[i] = *(ebp + 2 + i);
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6)); 
f0100ae7:	ff 76 18             	pushl  0x18(%esi)
f0100aea:	ff 76 14             	pushl  0x14(%esi)
f0100aed:	ff 76 10             	pushl  0x10(%esi)
f0100af0:	ff 76 0c             	pushl  0xc(%esi)
f0100af3:	ff 76 08             	pushl  0x8(%esi)
f0100af6:	53                   	push   %ebx
f0100af7:	56                   	push   %esi
f0100af8:	68 c0 43 10 f0       	push   $0xf01043c0
f0100afd:	e8 53 21 00 00       	call   f0102c55 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b02:	83 c4 18             	add    $0x18,%esp
f0100b05:	57                   	push   %edi
f0100b06:	ff 76 04             	pushl  0x4(%esi)
f0100b09:	e8 83 22 00 00       	call   f0102d91 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100b0e:	83 c4 0c             	add    $0xc,%esp
f0100b11:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100b14:	ff 75 d0             	pushl  -0x30(%ebp)
f0100b17:	68 27 3f 10 f0       	push   $0xf0103f27
f0100b1c:	e8 34 21 00 00       	call   f0102c55 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100b21:	83 c4 0c             	add    $0xc,%esp
f0100b24:	ff 75 d8             	pushl  -0x28(%ebp)
f0100b27:	ff 75 dc             	pushl  -0x24(%ebp)
f0100b2a:	68 37 3f 10 f0       	push   $0xf0103f37
f0100b2f:	e8 21 21 00 00       	call   f0102c55 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100b34:	83 c4 08             	add    $0x8,%esp
f0100b37:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100b3a:	53                   	push   %ebx
f0100b3b:	68 3c 3f 10 f0       	push   $0xf0103f3c
f0100b40:	e8 10 21 00 00       	call   f0102c55 <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
    uint32_t  eip;
    struct Eipdebuginfo eip_debug_info;

    // in entry.S show the top ebp = 0
    for (; ebp != 0; ebp = (uint32_t*)(*ebp)) {
f0100b45:	8b 36                	mov    (%esi),%esi
f0100b47:	83 c4 10             	add    $0x10,%esp
f0100b4a:	85 f6                	test   %esi,%esi
f0100b4c:	75 96                	jne    f0100ae4 <mon_backtrace+0x14>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
    }
    return 0;
}
f0100b4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b53:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b56:	5b                   	pop    %ebx
f0100b57:	5e                   	pop    %esi
f0100b58:	5f                   	pop    %edi
f0100b59:	c9                   	leave  
f0100b5a:	c3                   	ret    

f0100b5b <pa_con>:
    return 0;
}

bool
pa_con(uint32_t addr, uint32_t * value)
{
f0100b5b:	55                   	push   %ebp
f0100b5c:	89 e5                	mov    %esp,%ebp
f0100b5e:	53                   	push   %ebx
f0100b5f:	83 ec 04             	sub    $0x4,%esp
f0100b62:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    // get value in addr(physical address)
    // if no page mapped in addr, return false;
    if (addr >= PADDR(pages) && addr < PADDR(pages) + PTSIZE) {
f0100b68:	8b 15 4c e9 11 f0    	mov    0xf011e94c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100b6e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100b74:	77 15                	ja     f0100b8b <pa_con+0x30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b76:	52                   	push   %edx
f0100b77:	68 f8 43 10 f0       	push   $0xf01043f8
f0100b7c:	68 92 00 00 00       	push   $0x92
f0100b81:	68 41 3f 10 f0       	push   $0xf0103f41
f0100b86:	e8 00 f5 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100b8b:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100b91:	39 d0                	cmp    %edx,%eax
f0100b93:	72 18                	jb     f0100bad <pa_con+0x52>
f0100b95:	8d 9a 00 00 40 00    	lea    0x400000(%edx),%ebx
f0100b9b:	39 d8                	cmp    %ebx,%eax
f0100b9d:	73 0e                	jae    f0100bad <pa_con+0x52>
        // PageInfo
        *value = *(uint32_t *)(UPAGES + (addr - PADDR(pages)));
f0100b9f:	29 d0                	sub    %edx,%eax
f0100ba1:	8b 80 00 00 00 ef    	mov    -0x11000000(%eax),%eax
f0100ba7:	89 01                	mov    %eax,(%ecx)
        return true;
f0100ba9:	b0 01                	mov    $0x1,%al
f0100bab:	eb 56                	jmp    f0100c03 <pa_con+0xa8>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100bad:	ba 00 40 11 f0       	mov    $0xf0114000,%edx
f0100bb2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100bb8:	77 15                	ja     f0100bcf <pa_con+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100bba:	52                   	push   %edx
f0100bbb:	68 f8 43 10 f0       	push   $0xf01043f8
f0100bc0:	68 97 00 00 00       	push   $0x97
f0100bc5:	68 41 3f 10 f0       	push   $0xf0103f41
f0100bca:	e8 bc f4 ff ff       	call   f010008b <_panic>
    }
    if (addr >= PADDR(bootstack) && addr < PADDR(bootstack) + KSTKSIZE) {
f0100bcf:	3d 00 40 11 00       	cmp    $0x114000,%eax
f0100bd4:	72 18                	jb     f0100bee <pa_con+0x93>
f0100bd6:	3d 00 c0 11 00       	cmp    $0x11c000,%eax
f0100bdb:	73 11                	jae    f0100bee <pa_con+0x93>
        // kernel stack
        *value = *(uint32_t *)(KSTACKTOP - KSTKSIZE + (addr - PADDR(bootstack)));
f0100bdd:	2d 00 40 11 00       	sub    $0x114000,%eax
f0100be2:	8b 80 00 80 ff ef    	mov    -0x10008000(%eax),%eax
f0100be8:	89 01                	mov    %eax,(%ecx)
        return true;
f0100bea:	b0 01                	mov    $0x1,%al
f0100bec:	eb 15                	jmp    f0100c03 <pa_con+0xa8>
    }
    if (addr < -KERNBASE) {
f0100bee:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
f0100bf3:	77 0c                	ja     f0100c01 <pa_con+0xa6>
        // Other
        *value = *(uint32_t *)(addr + KERNBASE);
f0100bf5:	8b 80 00 00 00 f0    	mov    -0x10000000(%eax),%eax
f0100bfb:	89 01                	mov    %eax,(%ecx)
        return true;
f0100bfd:	b0 01                	mov    $0x1,%al
f0100bff:	eb 02                	jmp    f0100c03 <pa_con+0xa8>
    }
    // Not in virtual memory mapped.
    return false;
f0100c01:	b0 00                	mov    $0x0,%al
}
f0100c03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c06:	c9                   	leave  
f0100c07:	c3                   	ret    

f0100c08 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf)
{
f0100c08:	55                   	push   %ebp
f0100c09:	89 e5                	mov    %esp,%ebp
f0100c0b:	57                   	push   %edi
f0100c0c:	56                   	push   %esi
f0100c0d:	53                   	push   %ebx
f0100c0e:	83 ec 2c             	sub    $0x2c,%esp
f0100c11:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 4) {
f0100c14:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100c18:	74 2d                	je     f0100c47 <mon_dump+0x3f>
        cprintf("Command should be: dump [v/p] [addr1] [addr2]\n");
f0100c1a:	83 ec 0c             	sub    $0xc,%esp
f0100c1d:	68 1c 44 10 f0       	push   $0xf010441c
f0100c22:	e8 2e 20 00 00       	call   f0102c55 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100c27:	c7 04 24 4c 44 10 f0 	movl   $0xf010444c,(%esp)
f0100c2e:	e8 22 20 00 00       	call   f0102c55 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100c33:	c7 04 24 74 44 10 f0 	movl   $0xf0104474,(%esp)
f0100c3a:	e8 16 20 00 00       	call   f0102c55 <cprintf>
f0100c3f:	83 c4 10             	add    $0x10,%esp
f0100c42:	e9 59 01 00 00       	jmp    f0100da0 <mon_dump+0x198>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100c47:	83 ec 04             	sub    $0x4,%esp
f0100c4a:	6a 00                	push   $0x0
f0100c4c:	6a 00                	push   $0x0
f0100c4e:	ff 76 08             	pushl  0x8(%esi)
f0100c51:	e8 68 2c 00 00       	call   f01038be <strtol>
f0100c56:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100c58:	83 c4 0c             	add    $0xc,%esp
f0100c5b:	6a 00                	push   $0x0
f0100c5d:	6a 00                	push   $0x0
f0100c5f:	ff 76 0c             	pushl  0xc(%esi)
f0100c62:	e8 57 2c 00 00       	call   f01038be <strtol>
        if (laddr > haddr) {
f0100c67:	83 c4 10             	add    $0x10,%esp
f0100c6a:	39 c3                	cmp    %eax,%ebx
f0100c6c:	76 01                	jbe    f0100c6f <mon_dump+0x67>
            haddr ^= laddr;
            laddr ^= haddr;
            haddr ^= laddr;
f0100c6e:	93                   	xchg   %eax,%ebx
        }
        laddr = ROUNDDOWN(laddr, 4);
f0100c6f:	89 df                	mov    %ebx,%edi
f0100c71:	83 e7 fc             	and    $0xfffffffc,%edi
        haddr = ROUNDDOWN(haddr, 4);
f0100c74:	83 e0 fc             	and    $0xfffffffc,%eax
f0100c77:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        if (argv[1][0] == 'v') {
f0100c7a:	8b 46 04             	mov    0x4(%esi),%eax
f0100c7d:	80 38 76             	cmpb   $0x76,(%eax)
f0100c80:	74 0e                	je     f0100c90 <mon_dump+0x88>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100c82:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100c85:	0f 85 98 00 00 00    	jne    f0100d23 <mon_dump+0x11b>
f0100c8b:	e9 00 01 00 00       	jmp    f0100d90 <mon_dump+0x188>
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100c90:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100c93:	74 7c                	je     f0100d11 <mon_dump+0x109>
f0100c95:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100c97:	39 fb                	cmp    %edi,%ebx
f0100c99:	74 15                	je     f0100cb0 <mon_dump+0xa8>
f0100c9b:	f6 c3 0f             	test   $0xf,%bl
f0100c9e:	75 21                	jne    f0100cc1 <mon_dump+0xb9>
                    if (now != laddr) cprintf("\n"); 
f0100ca0:	83 ec 0c             	sub    $0xc,%esp
f0100ca3:	68 c5 3e 10 f0       	push   $0xf0103ec5
f0100ca8:	e8 a8 1f 00 00       	call   f0102c55 <cprintf>
f0100cad:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100cb0:	83 ec 08             	sub    $0x8,%esp
f0100cb3:	53                   	push   %ebx
f0100cb4:	68 50 3f 10 f0       	push   $0xf0103f50
f0100cb9:	e8 97 1f 00 00       	call   f0102c55 <cprintf>
f0100cbe:	83 c4 10             	add    $0x10,%esp
                }
                pte = pgdir_walk(kern_pgdir, (void *)ROUNDDOWN(now, PGSIZE), 0);
f0100cc1:	83 ec 04             	sub    $0x4,%esp
f0100cc4:	6a 00                	push   $0x0
f0100cc6:	89 d8                	mov    %ebx,%eax
f0100cc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ccd:	50                   	push   %eax
f0100cce:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0100cd4:	e8 ed 06 00 00       	call   f01013c6 <pgdir_walk>
                if (pte && (*pte & PTE_P)) 
f0100cd9:	83 c4 10             	add    $0x10,%esp
f0100cdc:	85 c0                	test   %eax,%eax
f0100cde:	74 19                	je     f0100cf9 <mon_dump+0xf1>
f0100ce0:	f6 00 01             	testb  $0x1,(%eax)
f0100ce3:	74 14                	je     f0100cf9 <mon_dump+0xf1>
                    cprintf("0x%08x  ", *((uint32_t *)now));
f0100ce5:	83 ec 08             	sub    $0x8,%esp
f0100ce8:	ff 33                	pushl  (%ebx)
f0100cea:	68 5a 3f 10 f0       	push   $0xf0103f5a
f0100cef:	e8 61 1f 00 00       	call   f0102c55 <cprintf>
f0100cf4:	83 c4 10             	add    $0x10,%esp
f0100cf7:	eb 10                	jmp    f0100d09 <mon_dump+0x101>
                else
                    cprintf("--------  ");
f0100cf9:	83 ec 0c             	sub    $0xc,%esp
f0100cfc:	68 65 3f 10 f0       	push   $0xf0103f65
f0100d01:	e8 4f 1f 00 00       	call   f0102c55 <cprintf>
f0100d06:	83 c4 10             	add    $0x10,%esp
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            pte_t * pte;
            for (now = laddr; now != haddr; now += 4) {
f0100d09:	83 c3 04             	add    $0x4,%ebx
f0100d0c:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100d0f:	75 86                	jne    f0100c97 <mon_dump+0x8f>
                if (pte && (*pte & PTE_P)) 
                    cprintf("0x%08x  ", *((uint32_t *)now));
                else
                    cprintf("--------  ");
            }
            cprintf("\n");
f0100d11:	83 ec 0c             	sub    $0xc,%esp
f0100d14:	68 c5 3e 10 f0       	push   $0xf0103ec5
f0100d19:	e8 37 1f 00 00       	call   f0102c55 <cprintf>
f0100d1e:	83 c4 10             	add    $0x10,%esp
f0100d21:	eb 7d                	jmp    f0100da0 <mon_dump+0x198>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100d23:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100d25:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100d28:	39 fb                	cmp    %edi,%ebx
f0100d2a:	74 15                	je     f0100d41 <mon_dump+0x139>
f0100d2c:	f6 c3 0f             	test   $0xf,%bl
f0100d2f:	75 21                	jne    f0100d52 <mon_dump+0x14a>
                    if (now != laddr) cprintf("\n");
f0100d31:	83 ec 0c             	sub    $0xc,%esp
f0100d34:	68 c5 3e 10 f0       	push   $0xf0103ec5
f0100d39:	e8 17 1f 00 00       	call   f0102c55 <cprintf>
f0100d3e:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100d41:	83 ec 08             	sub    $0x8,%esp
f0100d44:	53                   	push   %ebx
f0100d45:	68 50 3f 10 f0       	push   $0xf0103f50
f0100d4a:	e8 06 1f 00 00       	call   f0102c55 <cprintf>
f0100d4f:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f0100d52:	83 ec 08             	sub    $0x8,%esp
f0100d55:	56                   	push   %esi
f0100d56:	53                   	push   %ebx
f0100d57:	e8 ff fd ff ff       	call   f0100b5b <pa_con>
f0100d5c:	83 c4 10             	add    $0x10,%esp
f0100d5f:	84 c0                	test   %al,%al
f0100d61:	74 15                	je     f0100d78 <mon_dump+0x170>
                    cprintf("0x%08x  ", value);
f0100d63:	83 ec 08             	sub    $0x8,%esp
f0100d66:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d69:	68 5a 3f 10 f0       	push   $0xf0103f5a
f0100d6e:	e8 e2 1e 00 00       	call   f0102c55 <cprintf>
f0100d73:	83 c4 10             	add    $0x10,%esp
f0100d76:	eb 10                	jmp    f0100d88 <mon_dump+0x180>
                } else
                    cprintf("----------  ");
f0100d78:	83 ec 0c             	sub    $0xc,%esp
f0100d7b:	68 63 3f 10 f0       	push   $0xf0103f63
f0100d80:	e8 d0 1e 00 00       	call   f0102c55 <cprintf>
f0100d85:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100d88:	83 c3 04             	add    $0x4,%ebx
f0100d8b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100d8e:	75 98                	jne    f0100d28 <mon_dump+0x120>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f0100d90:	83 ec 0c             	sub    $0xc,%esp
f0100d93:	68 c5 3e 10 f0       	push   $0xf0103ec5
f0100d98:	e8 b8 1e 00 00       	call   f0102c55 <cprintf>
f0100d9d:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100da0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100da5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100da8:	5b                   	pop    %ebx
f0100da9:	5e                   	pop    %esi
f0100daa:	5f                   	pop    %edi
f0100dab:	c9                   	leave  
f0100dac:	c3                   	ret    

f0100dad <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100dad:	55                   	push   %ebp
f0100dae:	89 e5                	mov    %esp,%ebp
f0100db0:	57                   	push   %edi
f0100db1:	56                   	push   %esi
f0100db2:	53                   	push   %ebx
f0100db3:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100db6:	68 b8 44 10 f0       	push   $0xf01044b8
f0100dbb:	e8 95 1e 00 00       	call   f0102c55 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100dc0:	c7 04 24 dc 44 10 f0 	movl   $0xf01044dc,(%esp)
f0100dc7:	e8 89 1e 00 00       	call   f0102c55 <cprintf>
f0100dcc:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100dcf:	83 ec 0c             	sub    $0xc,%esp
f0100dd2:	68 70 3f 10 f0       	push   $0xf0103f70
f0100dd7:	e8 10 27 00 00       	call   f01034ec <readline>
f0100ddc:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100dde:	83 c4 10             	add    $0x10,%esp
f0100de1:	85 c0                	test   %eax,%eax
f0100de3:	74 ea                	je     f0100dcf <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100de5:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100dec:	be 00 00 00 00       	mov    $0x0,%esi
f0100df1:	eb 04                	jmp    f0100df7 <monitor+0x4a>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100df3:	c6 03 00             	movb   $0x0,(%ebx)
f0100df6:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100df7:	8a 03                	mov    (%ebx),%al
f0100df9:	84 c0                	test   %al,%al
f0100dfb:	74 64                	je     f0100e61 <monitor+0xb4>
f0100dfd:	83 ec 08             	sub    $0x8,%esp
f0100e00:	0f be c0             	movsbl %al,%eax
f0100e03:	50                   	push   %eax
f0100e04:	68 74 3f 10 f0       	push   $0xf0103f74
f0100e09:	e8 27 29 00 00       	call   f0103735 <strchr>
f0100e0e:	83 c4 10             	add    $0x10,%esp
f0100e11:	85 c0                	test   %eax,%eax
f0100e13:	75 de                	jne    f0100df3 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100e15:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100e18:	74 47                	je     f0100e61 <monitor+0xb4>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100e1a:	83 fe 0f             	cmp    $0xf,%esi
f0100e1d:	75 14                	jne    f0100e33 <monitor+0x86>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100e1f:	83 ec 08             	sub    $0x8,%esp
f0100e22:	6a 10                	push   $0x10
f0100e24:	68 79 3f 10 f0       	push   $0xf0103f79
f0100e29:	e8 27 1e 00 00       	call   f0102c55 <cprintf>
f0100e2e:	83 c4 10             	add    $0x10,%esp
f0100e31:	eb 9c                	jmp    f0100dcf <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100e33:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100e37:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e38:	8a 03                	mov    (%ebx),%al
f0100e3a:	84 c0                	test   %al,%al
f0100e3c:	75 09                	jne    f0100e47 <monitor+0x9a>
f0100e3e:	eb b7                	jmp    f0100df7 <monitor+0x4a>
			buf++;
f0100e40:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e41:	8a 03                	mov    (%ebx),%al
f0100e43:	84 c0                	test   %al,%al
f0100e45:	74 b0                	je     f0100df7 <monitor+0x4a>
f0100e47:	83 ec 08             	sub    $0x8,%esp
f0100e4a:	0f be c0             	movsbl %al,%eax
f0100e4d:	50                   	push   %eax
f0100e4e:	68 74 3f 10 f0       	push   $0xf0103f74
f0100e53:	e8 dd 28 00 00       	call   f0103735 <strchr>
f0100e58:	83 c4 10             	add    $0x10,%esp
f0100e5b:	85 c0                	test   %eax,%eax
f0100e5d:	74 e1                	je     f0100e40 <monitor+0x93>
f0100e5f:	eb 96                	jmp    f0100df7 <monitor+0x4a>
			buf++;
	}
	argv[argc] = 0;
f0100e61:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100e68:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100e69:	85 f6                	test   %esi,%esi
f0100e6b:	0f 84 5e ff ff ff    	je     f0100dcf <monitor+0x22>
f0100e71:	bb 60 45 10 f0       	mov    $0xf0104560,%ebx
f0100e76:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100e7b:	83 ec 08             	sub    $0x8,%esp
f0100e7e:	ff 33                	pushl  (%ebx)
f0100e80:	ff 75 a8             	pushl  -0x58(%ebp)
f0100e83:	e8 3f 28 00 00       	call   f01036c7 <strcmp>
f0100e88:	83 c4 10             	add    $0x10,%esp
f0100e8b:	85 c0                	test   %eax,%eax
f0100e8d:	75 20                	jne    f0100eaf <monitor+0x102>
			return commands[i].func(argc, argv, tf);
f0100e8f:	83 ec 04             	sub    $0x4,%esp
f0100e92:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100e95:	ff 75 08             	pushl  0x8(%ebp)
f0100e98:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100e9b:	50                   	push   %eax
f0100e9c:	56                   	push   %esi
f0100e9d:	ff 97 68 45 10 f0    	call   *-0xfefba98(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ea3:	83 c4 10             	add    $0x10,%esp
f0100ea6:	85 c0                	test   %eax,%eax
f0100ea8:	78 26                	js     f0100ed0 <monitor+0x123>
f0100eaa:	e9 20 ff ff ff       	jmp    f0100dcf <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100eaf:	47                   	inc    %edi
f0100eb0:	83 c3 0c             	add    $0xc,%ebx
f0100eb3:	83 ff 07             	cmp    $0x7,%edi
f0100eb6:	75 c3                	jne    f0100e7b <monitor+0xce>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100eb8:	83 ec 08             	sub    $0x8,%esp
f0100ebb:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ebe:	68 96 3f 10 f0       	push   $0xf0103f96
f0100ec3:	e8 8d 1d 00 00       	call   f0102c55 <cprintf>
f0100ec8:	83 c4 10             	add    $0x10,%esp
f0100ecb:	e9 ff fe ff ff       	jmp    f0100dcf <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ed0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ed3:	5b                   	pop    %ebx
f0100ed4:	5e                   	pop    %esi
f0100ed5:	5f                   	pop    %edi
f0100ed6:	c9                   	leave  
f0100ed7:	c3                   	ret    

f0100ed8 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ed8:	55                   	push   %ebp
f0100ed9:	89 e5                	mov    %esp,%ebp
f0100edb:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100edd:	83 3d 30 e5 11 f0 00 	cmpl   $0x0,0xf011e530
f0100ee4:	75 0f                	jne    f0100ef5 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ee6:	b8 4f f9 11 f0       	mov    $0xf011f94f,%eax
f0100eeb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ef0:	a3 30 e5 11 f0       	mov    %eax,0xf011e530
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0100ef5:	a1 30 e5 11 f0       	mov    0xf011e530,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100efa:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100f01:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f07:	89 15 30 e5 11 f0    	mov    %edx,0xf011e530

	return result;
}
f0100f0d:	c9                   	leave  
f0100f0e:	c3                   	ret    

f0100f0f <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100f0f:	55                   	push   %ebp
f0100f10:	89 e5                	mov    %esp,%ebp
f0100f12:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100f15:	89 d1                	mov    %edx,%ecx
f0100f17:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100f1a:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100f1d:	a8 01                	test   $0x1,%al
f0100f1f:	74 42                	je     f0100f63 <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100f21:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f26:	89 c1                	mov    %eax,%ecx
f0100f28:	c1 e9 0c             	shr    $0xc,%ecx
f0100f2b:	3b 0d 44 e9 11 f0    	cmp    0xf011e944,%ecx
f0100f31:	72 15                	jb     f0100f48 <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f33:	50                   	push   %eax
f0100f34:	68 b4 45 10 f0       	push   $0xf01045b4
f0100f39:	68 c4 02 00 00       	push   $0x2c4
f0100f3e:	68 ac 4c 10 f0       	push   $0xf0104cac
f0100f43:	e8 43 f1 ff ff       	call   f010008b <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100f48:	c1 ea 0c             	shr    $0xc,%edx
f0100f4b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100f51:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100f58:	a8 01                	test   $0x1,%al
f0100f5a:	74 0e                	je     f0100f6a <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100f5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f61:	eb 0c                	jmp    f0100f6f <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100f63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f68:	eb 05                	jmp    f0100f6f <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100f6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100f6f:	c9                   	leave  
f0100f70:	c3                   	ret    

f0100f71 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100f71:	55                   	push   %ebp
f0100f72:	89 e5                	mov    %esp,%ebp
f0100f74:	56                   	push   %esi
f0100f75:	53                   	push   %ebx
f0100f76:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100f78:	83 ec 0c             	sub    $0xc,%esp
f0100f7b:	50                   	push   %eax
f0100f7c:	e8 73 1c 00 00       	call   f0102bf4 <mc146818_read>
f0100f81:	89 c6                	mov    %eax,%esi
f0100f83:	43                   	inc    %ebx
f0100f84:	89 1c 24             	mov    %ebx,(%esp)
f0100f87:	e8 68 1c 00 00       	call   f0102bf4 <mc146818_read>
f0100f8c:	c1 e0 08             	shl    $0x8,%eax
f0100f8f:	09 f0                	or     %esi,%eax
}
f0100f91:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f94:	5b                   	pop    %ebx
f0100f95:	5e                   	pop    %esi
f0100f96:	c9                   	leave  
f0100f97:	c3                   	ret    

f0100f98 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100f98:	55                   	push   %ebp
f0100f99:	89 e5                	mov    %esp,%ebp
f0100f9b:	57                   	push   %edi
f0100f9c:	56                   	push   %esi
f0100f9d:	53                   	push   %ebx
f0100f9e:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fa1:	3c 01                	cmp    $0x1,%al
f0100fa3:	19 f6                	sbb    %esi,%esi
f0100fa5:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100fab:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100fac:	8b 1d 2c e5 11 f0    	mov    0xf011e52c,%ebx
f0100fb2:	85 db                	test   %ebx,%ebx
f0100fb4:	75 17                	jne    f0100fcd <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f0100fb6:	83 ec 04             	sub    $0x4,%esp
f0100fb9:	68 d8 45 10 f0       	push   $0xf01045d8
f0100fbe:	68 07 02 00 00       	push   $0x207
f0100fc3:	68 ac 4c 10 f0       	push   $0xf0104cac
f0100fc8:	e8 be f0 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
f0100fcd:	84 c0                	test   %al,%al
f0100fcf:	74 50                	je     f0101021 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100fd1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100fd4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100fd7:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100fda:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fdd:	89 d8                	mov    %ebx,%eax
f0100fdf:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f0100fe5:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100fe8:	c1 e8 16             	shr    $0x16,%eax
f0100feb:	39 c6                	cmp    %eax,%esi
f0100fed:	0f 96 c0             	setbe  %al
f0100ff0:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100ff3:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0100ff7:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100ff9:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ffd:	8b 1b                	mov    (%ebx),%ebx
f0100fff:	85 db                	test   %ebx,%ebx
f0101001:	75 da                	jne    f0100fdd <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101003:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101006:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010100c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010100f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101012:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101014:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101017:	89 1d 2c e5 11 f0    	mov    %ebx,0xf011e52c
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010101d:	85 db                	test   %ebx,%ebx
f010101f:	74 57                	je     f0101078 <check_page_free_list+0xe0>
f0101021:	89 d8                	mov    %ebx,%eax
f0101023:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f0101029:	c1 f8 03             	sar    $0x3,%eax
f010102c:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010102f:	89 c2                	mov    %eax,%edx
f0101031:	c1 ea 16             	shr    $0x16,%edx
f0101034:	39 d6                	cmp    %edx,%esi
f0101036:	76 3a                	jbe    f0101072 <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101038:	89 c2                	mov    %eax,%edx
f010103a:	c1 ea 0c             	shr    $0xc,%edx
f010103d:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f0101043:	72 12                	jb     f0101057 <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101045:	50                   	push   %eax
f0101046:	68 b4 45 10 f0       	push   $0xf01045b4
f010104b:	6a 52                	push   $0x52
f010104d:	68 b8 4c 10 f0       	push   $0xf0104cb8
f0101052:	e8 34 f0 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101057:	83 ec 04             	sub    $0x4,%esp
f010105a:	68 80 00 00 00       	push   $0x80
f010105f:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101064:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101069:	50                   	push   %eax
f010106a:	e8 16 27 00 00       	call   f0103785 <memset>
f010106f:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101072:	8b 1b                	mov    (%ebx),%ebx
f0101074:	85 db                	test   %ebx,%ebx
f0101076:	75 a9                	jne    f0101021 <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101078:	b8 00 00 00 00       	mov    $0x0,%eax
f010107d:	e8 56 fe ff ff       	call   f0100ed8 <boot_alloc>
f0101082:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101085:	8b 15 2c e5 11 f0    	mov    0xf011e52c,%edx
f010108b:	85 d2                	test   %edx,%edx
f010108d:	0f 84 80 01 00 00    	je     f0101213 <check_page_free_list+0x27b>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101093:	8b 1d 4c e9 11 f0    	mov    0xf011e94c,%ebx
f0101099:	39 da                	cmp    %ebx,%edx
f010109b:	72 43                	jb     f01010e0 <check_page_free_list+0x148>
		assert(pp < pages + npages);
f010109d:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f01010a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01010a5:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f01010a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01010ab:	39 c2                	cmp    %eax,%edx
f01010ad:	73 4f                	jae    f01010fe <check_page_free_list+0x166>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010af:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f01010b2:	89 d0                	mov    %edx,%eax
f01010b4:	29 d8                	sub    %ebx,%eax
f01010b6:	a8 07                	test   $0x7,%al
f01010b8:	75 66                	jne    f0101120 <check_page_free_list+0x188>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010ba:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01010bd:	c1 e0 0c             	shl    $0xc,%eax
f01010c0:	74 7f                	je     f0101141 <check_page_free_list+0x1a9>
		assert(page2pa(pp) != IOPHYSMEM);
f01010c2:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010c7:	0f 84 94 00 00 00    	je     f0101161 <check_page_free_list+0x1c9>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01010cd:	be 00 00 00 00       	mov    $0x0,%esi
f01010d2:	bf 00 00 00 00       	mov    $0x0,%edi
f01010d7:	e9 9e 00 00 00       	jmp    f010117a <check_page_free_list+0x1e2>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01010dc:	39 da                	cmp    %ebx,%edx
f01010de:	73 19                	jae    f01010f9 <check_page_free_list+0x161>
f01010e0:	68 c6 4c 10 f0       	push   $0xf0104cc6
f01010e5:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01010ea:	68 21 02 00 00       	push   $0x221
f01010ef:	68 ac 4c 10 f0       	push   $0xf0104cac
f01010f4:	e8 92 ef ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f01010f9:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01010fc:	72 19                	jb     f0101117 <check_page_free_list+0x17f>
f01010fe:	68 e7 4c 10 f0       	push   $0xf0104ce7
f0101103:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101108:	68 22 02 00 00       	push   $0x222
f010110d:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101112:	e8 74 ef ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101117:	89 d0                	mov    %edx,%eax
f0101119:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010111c:	a8 07                	test   $0x7,%al
f010111e:	74 19                	je     f0101139 <check_page_free_list+0x1a1>
f0101120:	68 fc 45 10 f0       	push   $0xf01045fc
f0101125:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010112a:	68 23 02 00 00       	push   $0x223
f010112f:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101134:	e8 52 ef ff ff       	call   f010008b <_panic>
f0101139:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010113c:	c1 e0 0c             	shl    $0xc,%eax
f010113f:	75 19                	jne    f010115a <check_page_free_list+0x1c2>
f0101141:	68 fb 4c 10 f0       	push   $0xf0104cfb
f0101146:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010114b:	68 26 02 00 00       	push   $0x226
f0101150:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101155:	e8 31 ef ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010115a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010115f:	75 19                	jne    f010117a <check_page_free_list+0x1e2>
f0101161:	68 0c 4d 10 f0       	push   $0xf0104d0c
f0101166:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010116b:	68 27 02 00 00       	push   $0x227
f0101170:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101175:	e8 11 ef ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010117a:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010117f:	75 19                	jne    f010119a <check_page_free_list+0x202>
f0101181:	68 30 46 10 f0       	push   $0xf0104630
f0101186:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010118b:	68 28 02 00 00       	push   $0x228
f0101190:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101195:	e8 f1 ee ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010119a:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010119f:	75 19                	jne    f01011ba <check_page_free_list+0x222>
f01011a1:	68 25 4d 10 f0       	push   $0xf0104d25
f01011a6:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01011ab:	68 29 02 00 00       	push   $0x229
f01011b0:	68 ac 4c 10 f0       	push   $0xf0104cac
f01011b5:	e8 d1 ee ff ff       	call   f010008b <_panic>
f01011ba:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011bc:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01011c1:	76 3e                	jbe    f0101201 <check_page_free_list+0x269>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011c3:	c1 e8 0c             	shr    $0xc,%eax
f01011c6:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01011c9:	77 12                	ja     f01011dd <check_page_free_list+0x245>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011cb:	51                   	push   %ecx
f01011cc:	68 b4 45 10 f0       	push   $0xf01045b4
f01011d1:	6a 52                	push   $0x52
f01011d3:	68 b8 4c 10 f0       	push   $0xf0104cb8
f01011d8:	e8 ae ee ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f01011dd:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f01011e3:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01011e6:	76 1c                	jbe    f0101204 <check_page_free_list+0x26c>
f01011e8:	68 54 46 10 f0       	push   $0xf0104654
f01011ed:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01011f2:	68 2a 02 00 00       	push   $0x22a
f01011f7:	68 ac 4c 10 f0       	push   $0xf0104cac
f01011fc:	e8 8a ee ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101201:	47                   	inc    %edi
f0101202:	eb 01                	jmp    f0101205 <check_page_free_list+0x26d>
		else
			++nfree_extmem;
f0101204:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101205:	8b 12                	mov    (%edx),%edx
f0101207:	85 d2                	test   %edx,%edx
f0101209:	0f 85 cd fe ff ff    	jne    f01010dc <check_page_free_list+0x144>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010120f:	85 ff                	test   %edi,%edi
f0101211:	7f 19                	jg     f010122c <check_page_free_list+0x294>
f0101213:	68 3f 4d 10 f0       	push   $0xf0104d3f
f0101218:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010121d:	68 32 02 00 00       	push   $0x232
f0101222:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101227:	e8 5f ee ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f010122c:	85 f6                	test   %esi,%esi
f010122e:	7f 19                	jg     f0101249 <check_page_free_list+0x2b1>
f0101230:	68 51 4d 10 f0       	push   $0xf0104d51
f0101235:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010123a:	68 33 02 00 00       	push   $0x233
f010123f:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101244:	e8 42 ee ff ff       	call   f010008b <_panic>
}
f0101249:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010124c:	5b                   	pop    %ebx
f010124d:	5e                   	pop    %esi
f010124e:	5f                   	pop    %edi
f010124f:	c9                   	leave  
f0101250:	c3                   	ret    

f0101251 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101251:	55                   	push   %ebp
f0101252:	89 e5                	mov    %esp,%ebp
f0101254:	56                   	push   %esi
f0101255:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f0101256:	c7 05 2c e5 11 f0 00 	movl   $0x0,0xf011e52c
f010125d:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f0101260:	b8 00 00 00 00       	mov    $0x0,%eax
f0101265:	e8 6e fc ff ff       	call   f0100ed8 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010126a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010126f:	77 15                	ja     f0101286 <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101271:	50                   	push   %eax
f0101272:	68 f8 43 10 f0       	push   $0xf01043f8
f0101277:	68 10 01 00 00       	push   $0x110
f010127c:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101281:	e8 05 ee ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101286:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f010128c:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f010128f:	83 3d 44 e9 11 f0 00 	cmpl   $0x0,0xf011e944
f0101296:	74 5f                	je     f01012f7 <page_init+0xa6>
f0101298:	8b 1d 2c e5 11 f0    	mov    0xf011e52c,%ebx
f010129e:	ba 00 00 00 00       	mov    $0x0,%edx
f01012a3:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f01012a8:	85 c0                	test   %eax,%eax
f01012aa:	74 25                	je     f01012d1 <page_init+0x80>
f01012ac:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f01012b1:	76 04                	jbe    f01012b7 <page_init+0x66>
f01012b3:	39 c6                	cmp    %eax,%esi
f01012b5:	77 1a                	ja     f01012d1 <page_init+0x80>
		    pages[i].pp_ref = 0;
f01012b7:	89 d1                	mov    %edx,%ecx
f01012b9:	03 0d 4c e9 11 f0    	add    0xf011e94c,%ecx
f01012bf:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f01012c5:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f01012c7:	89 d3                	mov    %edx,%ebx
f01012c9:	03 1d 4c e9 11 f0    	add    0xf011e94c,%ebx
f01012cf:	eb 14                	jmp    f01012e5 <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f01012d1:	89 d1                	mov    %edx,%ecx
f01012d3:	03 0d 4c e9 11 f0    	add    0xf011e94c,%ecx
f01012d9:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f01012df:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// free pages!
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    for (i = 0; i < npages; i++) {
f01012e5:	40                   	inc    %eax
f01012e6:	83 c2 08             	add    $0x8,%edx
f01012e9:	39 05 44 e9 11 f0    	cmp    %eax,0xf011e944
f01012ef:	77 b7                	ja     f01012a8 <page_init+0x57>
f01012f1:	89 1d 2c e5 11 f0    	mov    %ebx,0xf011e52c
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f01012f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012fa:	5b                   	pop    %ebx
f01012fb:	5e                   	pop    %esi
f01012fc:	c9                   	leave  
f01012fd:	c3                   	ret    

f01012fe <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01012fe:	55                   	push   %ebp
f01012ff:	89 e5                	mov    %esp,%ebp
f0101301:	53                   	push   %ebx
f0101302:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f0101305:	8b 1d 2c e5 11 f0    	mov    0xf011e52c,%ebx
f010130b:	85 db                	test   %ebx,%ebx
f010130d:	74 63                	je     f0101372 <page_alloc+0x74>
f010130f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101314:	74 63                	je     f0101379 <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f0101316:	8b 1b                	mov    (%ebx),%ebx
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f0101318:	85 db                	test   %ebx,%ebx
f010131a:	75 08                	jne    f0101324 <page_alloc+0x26>
f010131c:	89 1d 2c e5 11 f0    	mov    %ebx,0xf011e52c
f0101322:	eb 4e                	jmp    f0101372 <page_alloc+0x74>
f0101324:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101329:	75 eb                	jne    f0101316 <page_alloc+0x18>
f010132b:	eb 4c                	jmp    f0101379 <page_alloc+0x7b>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010132d:	89 d8                	mov    %ebx,%eax
f010132f:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f0101335:	c1 f8 03             	sar    $0x3,%eax
f0101338:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010133b:	89 c2                	mov    %eax,%edx
f010133d:	c1 ea 0c             	shr    $0xc,%edx
f0101340:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f0101346:	72 12                	jb     f010135a <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101348:	50                   	push   %eax
f0101349:	68 b4 45 10 f0       	push   $0xf01045b4
f010134e:	6a 52                	push   $0x52
f0101350:	68 b8 4c 10 f0       	push   $0xf0104cb8
f0101355:	e8 31 ed ff ff       	call   f010008b <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f010135a:	83 ec 04             	sub    $0x4,%esp
f010135d:	68 00 10 00 00       	push   $0x1000
f0101362:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101364:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101369:	50                   	push   %eax
f010136a:	e8 16 24 00 00       	call   f0103785 <memset>
f010136f:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f0101372:	89 d8                	mov    %ebx,%eax
f0101374:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101377:	c9                   	leave  
f0101378:	c3                   	ret    
        page_free_list = page_free_list->pp_link;
    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f0101379:	8b 03                	mov    (%ebx),%eax
f010137b:	a3 2c e5 11 f0       	mov    %eax,0xf011e52c
        if (alloc_flags & ALLOC_ZERO) {
f0101380:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101384:	74 ec                	je     f0101372 <page_alloc+0x74>
f0101386:	eb a5                	jmp    f010132d <page_alloc+0x2f>

f0101388 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101388:	55                   	push   %ebp
f0101389:	89 e5                	mov    %esp,%ebp
f010138b:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f010138e:	85 c0                	test   %eax,%eax
f0101390:	74 14                	je     f01013a6 <page_free+0x1e>
f0101392:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101397:	75 0d                	jne    f01013a6 <page_free+0x1e>
    pp->pp_link = page_free_list;
f0101399:	8b 15 2c e5 11 f0    	mov    0xf011e52c,%edx
f010139f:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f01013a1:	a3 2c e5 11 f0       	mov    %eax,0xf011e52c
}
f01013a6:	c9                   	leave  
f01013a7:	c3                   	ret    

f01013a8 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01013a8:	55                   	push   %ebp
f01013a9:	89 e5                	mov    %esp,%ebp
f01013ab:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01013ae:	8b 50 04             	mov    0x4(%eax),%edx
f01013b1:	4a                   	dec    %edx
f01013b2:	66 89 50 04          	mov    %dx,0x4(%eax)
f01013b6:	66 85 d2             	test   %dx,%dx
f01013b9:	75 09                	jne    f01013c4 <page_decref+0x1c>
		page_free(pp);
f01013bb:	50                   	push   %eax
f01013bc:	e8 c7 ff ff ff       	call   f0101388 <page_free>
f01013c1:	83 c4 04             	add    $0x4,%esp
}
f01013c4:	c9                   	leave  
f01013c5:	c3                   	ret    

f01013c6 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01013c6:	55                   	push   %ebp
f01013c7:	89 e5                	mov    %esp,%ebp
f01013c9:	56                   	push   %esi
f01013ca:	53                   	push   %ebx
f01013cb:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f01013ce:	89 f3                	mov    %esi,%ebx
f01013d0:	c1 eb 16             	shr    $0x16,%ebx
f01013d3:	c1 e3 02             	shl    $0x2,%ebx
f01013d6:	03 5d 08             	add    0x8(%ebp),%ebx
f01013d9:	8b 03                	mov    (%ebx),%eax
f01013db:	85 c0                	test   %eax,%eax
f01013dd:	74 04                	je     f01013e3 <pgdir_walk+0x1d>
f01013df:	a8 01                	test   $0x1,%al
f01013e1:	75 2c                	jne    f010140f <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f01013e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01013e7:	74 61                	je     f010144a <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(1);
f01013e9:	83 ec 0c             	sub    $0xc,%esp
f01013ec:	6a 01                	push   $0x1
f01013ee:	e8 0b ff ff ff       	call   f01012fe <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f01013f3:	83 c4 10             	add    $0x10,%esp
f01013f6:	85 c0                	test   %eax,%eax
f01013f8:	74 57                	je     f0101451 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f01013fa:	66 ff 40 04          	incw   0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013fe:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f0101404:	c1 f8 03             	sar    $0x3,%eax
f0101407:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f010140a:	83 c8 07             	or     $0x7,%eax
f010140d:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f010140f:	8b 03                	mov    (%ebx),%eax
f0101411:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101416:	89 c2                	mov    %eax,%edx
f0101418:	c1 ea 0c             	shr    $0xc,%edx
f010141b:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f0101421:	72 15                	jb     f0101438 <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101423:	50                   	push   %eax
f0101424:	68 b4 45 10 f0       	push   $0xf01045b4
f0101429:	68 73 01 00 00       	push   $0x173
f010142e:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101433:	e8 53 ec ff ff       	call   f010008b <_panic>
f0101438:	c1 ee 0a             	shr    $0xa,%esi
f010143b:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101441:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101448:	eb 0c                	jmp    f0101456 <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f010144a:	b8 00 00 00 00       	mov    $0x0,%eax
f010144f:	eb 05                	jmp    f0101456 <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f0101451:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f0101456:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101459:	5b                   	pop    %ebx
f010145a:	5e                   	pop    %esi
f010145b:	c9                   	leave  
f010145c:	c3                   	ret    

f010145d <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010145d:	55                   	push   %ebp
f010145e:	89 e5                	mov    %esp,%ebp
f0101460:	57                   	push   %edi
f0101461:	56                   	push   %esi
f0101462:	53                   	push   %ebx
f0101463:	83 ec 1c             	sub    $0x1c,%esp
f0101466:	89 c7                	mov    %eax,%edi
f0101468:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f010146b:	01 d1                	add    %edx,%ecx
f010146d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101470:	39 ca                	cmp    %ecx,%edx
f0101472:	74 32                	je     f01014a6 <boot_map_region+0x49>
f0101474:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f0101476:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101479:	83 c8 01             	or     $0x1,%eax
f010147c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f010147f:	83 ec 04             	sub    $0x4,%esp
f0101482:	6a 01                	push   $0x1
f0101484:	53                   	push   %ebx
f0101485:	57                   	push   %edi
f0101486:	e8 3b ff ff ff       	call   f01013c6 <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f010148b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010148e:	09 f2                	or     %esi,%edx
f0101490:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101492:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101498:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010149e:	83 c4 10             	add    $0x10,%esp
f01014a1:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01014a4:	75 d9                	jne    f010147f <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f01014a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014a9:	5b                   	pop    %ebx
f01014aa:	5e                   	pop    %esi
f01014ab:	5f                   	pop    %edi
f01014ac:	c9                   	leave  
f01014ad:	c3                   	ret    

f01014ae <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01014ae:	55                   	push   %ebp
f01014af:	89 e5                	mov    %esp,%ebp
f01014b1:	53                   	push   %ebx
f01014b2:	83 ec 08             	sub    $0x8,%esp
f01014b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f01014b8:	6a 00                	push   $0x0
f01014ba:	ff 75 0c             	pushl  0xc(%ebp)
f01014bd:	ff 75 08             	pushl  0x8(%ebp)
f01014c0:	e8 01 ff ff ff       	call   f01013c6 <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01014c5:	83 c4 10             	add    $0x10,%esp
f01014c8:	85 c0                	test   %eax,%eax
f01014ca:	74 37                	je     f0101503 <page_lookup+0x55>
f01014cc:	f6 00 01             	testb  $0x1,(%eax)
f01014cf:	74 39                	je     f010150a <page_lookup+0x5c>
    if (pte_store != 0) {
f01014d1:	85 db                	test   %ebx,%ebx
f01014d3:	74 02                	je     f01014d7 <page_lookup+0x29>
        *pte_store = pte;
f01014d5:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f01014d7:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014d9:	c1 e8 0c             	shr    $0xc,%eax
f01014dc:	3b 05 44 e9 11 f0    	cmp    0xf011e944,%eax
f01014e2:	72 14                	jb     f01014f8 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01014e4:	83 ec 04             	sub    $0x4,%esp
f01014e7:	68 9c 46 10 f0       	push   $0xf010469c
f01014ec:	6a 4b                	push   $0x4b
f01014ee:	68 b8 4c 10 f0       	push   $0xf0104cb8
f01014f3:	e8 93 eb ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f01014f8:	c1 e0 03             	shl    $0x3,%eax
f01014fb:	03 05 4c e9 11 f0    	add    0xf011e94c,%eax
f0101501:	eb 0c                	jmp    f010150f <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f0101503:	b8 00 00 00 00       	mov    $0x0,%eax
f0101508:	eb 05                	jmp    f010150f <page_lookup+0x61>
f010150a:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f010150f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101512:	c9                   	leave  
f0101513:	c3                   	ret    

f0101514 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101514:	55                   	push   %ebp
f0101515:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101517:	8b 45 0c             	mov    0xc(%ebp),%eax
f010151a:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010151d:	c9                   	leave  
f010151e:	c3                   	ret    

f010151f <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010151f:	55                   	push   %ebp
f0101520:	89 e5                	mov    %esp,%ebp
f0101522:	56                   	push   %esi
f0101523:	53                   	push   %ebx
f0101524:	83 ec 14             	sub    $0x14,%esp
f0101527:	8b 75 08             	mov    0x8(%ebp),%esi
f010152a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f010152d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101530:	50                   	push   %eax
f0101531:	53                   	push   %ebx
f0101532:	56                   	push   %esi
f0101533:	e8 76 ff ff ff       	call   f01014ae <page_lookup>
    if (pg == NULL) return;
f0101538:	83 c4 10             	add    $0x10,%esp
f010153b:	85 c0                	test   %eax,%eax
f010153d:	74 26                	je     f0101565 <page_remove+0x46>
    page_decref(pg);
f010153f:	83 ec 0c             	sub    $0xc,%esp
f0101542:	50                   	push   %eax
f0101543:	e8 60 fe ff ff       	call   f01013a8 <page_decref>
    if (pte != NULL) *pte = 0;
f0101548:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010154b:	83 c4 10             	add    $0x10,%esp
f010154e:	85 c0                	test   %eax,%eax
f0101550:	74 06                	je     f0101558 <page_remove+0x39>
f0101552:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f0101558:	83 ec 08             	sub    $0x8,%esp
f010155b:	53                   	push   %ebx
f010155c:	56                   	push   %esi
f010155d:	e8 b2 ff ff ff       	call   f0101514 <tlb_invalidate>
f0101562:	83 c4 10             	add    $0x10,%esp
}
f0101565:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101568:	5b                   	pop    %ebx
f0101569:	5e                   	pop    %esi
f010156a:	c9                   	leave  
f010156b:	c3                   	ret    

f010156c <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010156c:	55                   	push   %ebp
f010156d:	89 e5                	mov    %esp,%ebp
f010156f:	57                   	push   %edi
f0101570:	56                   	push   %esi
f0101571:	53                   	push   %ebx
f0101572:	83 ec 10             	sub    $0x10,%esp
f0101575:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101578:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f010157b:	6a 01                	push   $0x1
f010157d:	57                   	push   %edi
f010157e:	ff 75 08             	pushl  0x8(%ebp)
f0101581:	e8 40 fe ff ff       	call   f01013c6 <pgdir_walk>
f0101586:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f0101588:	83 c4 10             	add    $0x10,%esp
f010158b:	85 c0                	test   %eax,%eax
f010158d:	74 39                	je     f01015c8 <page_insert+0x5c>
    ++pp->pp_ref;
f010158f:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f0101593:	f6 00 01             	testb  $0x1,(%eax)
f0101596:	74 0f                	je     f01015a7 <page_insert+0x3b>
        page_remove(pgdir, va);
f0101598:	83 ec 08             	sub    $0x8,%esp
f010159b:	57                   	push   %edi
f010159c:	ff 75 08             	pushl  0x8(%ebp)
f010159f:	e8 7b ff ff ff       	call   f010151f <page_remove>
f01015a4:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f01015a7:	8b 55 14             	mov    0x14(%ebp),%edx
f01015aa:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015ad:	2b 35 4c e9 11 f0    	sub    0xf011e94c,%esi
f01015b3:	c1 fe 03             	sar    $0x3,%esi
f01015b6:	89 f0                	mov    %esi,%eax
f01015b8:	c1 e0 0c             	shl    $0xc,%eax
f01015bb:	89 d6                	mov    %edx,%esi
f01015bd:	09 c6                	or     %eax,%esi
f01015bf:	89 33                	mov    %esi,(%ebx)
	return 0;
f01015c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01015c6:	eb 05                	jmp    f01015cd <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f01015c8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f01015cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015d0:	5b                   	pop    %ebx
f01015d1:	5e                   	pop    %esi
f01015d2:	5f                   	pop    %edi
f01015d3:	c9                   	leave  
f01015d4:	c3                   	ret    

f01015d5 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01015d5:	55                   	push   %ebp
f01015d6:	89 e5                	mov    %esp,%ebp
f01015d8:	57                   	push   %edi
f01015d9:	56                   	push   %esi
f01015da:	53                   	push   %ebx
f01015db:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01015de:	b8 15 00 00 00       	mov    $0x15,%eax
f01015e3:	e8 89 f9 ff ff       	call   f0100f71 <nvram_read>
f01015e8:	c1 e0 0a             	shl    $0xa,%eax
f01015eb:	89 c2                	mov    %eax,%edx
f01015ed:	85 c0                	test   %eax,%eax
f01015ef:	79 06                	jns    f01015f7 <mem_init+0x22>
f01015f1:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01015f7:	c1 fa 0c             	sar    $0xc,%edx
f01015fa:	89 15 34 e5 11 f0    	mov    %edx,0xf011e534
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101600:	b8 17 00 00 00       	mov    $0x17,%eax
f0101605:	e8 67 f9 ff ff       	call   f0100f71 <nvram_read>
f010160a:	89 c2                	mov    %eax,%edx
f010160c:	c1 e2 0a             	shl    $0xa,%edx
f010160f:	89 d0                	mov    %edx,%eax
f0101611:	85 d2                	test   %edx,%edx
f0101613:	79 06                	jns    f010161b <mem_init+0x46>
f0101615:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010161b:	c1 f8 0c             	sar    $0xc,%eax
f010161e:	74 0e                	je     f010162e <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101620:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101626:	89 15 44 e9 11 f0    	mov    %edx,0xf011e944
f010162c:	eb 0c                	jmp    f010163a <mem_init+0x65>
	else
		npages = npages_basemem;
f010162e:	8b 15 34 e5 11 f0    	mov    0xf011e534,%edx
f0101634:	89 15 44 e9 11 f0    	mov    %edx,0xf011e944

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010163a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010163d:	c1 e8 0a             	shr    $0xa,%eax
f0101640:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101641:	a1 34 e5 11 f0       	mov    0xf011e534,%eax
f0101646:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101649:	c1 e8 0a             	shr    $0xa,%eax
f010164c:	50                   	push   %eax
		npages * PGSIZE / 1024,
f010164d:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f0101652:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101655:	c1 e8 0a             	shr    $0xa,%eax
f0101658:	50                   	push   %eax
f0101659:	68 bc 46 10 f0       	push   $0xf01046bc
f010165e:	e8 f2 15 00 00       	call   f0102c55 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101663:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101668:	e8 6b f8 ff ff       	call   f0100ed8 <boot_alloc>
f010166d:	a3 48 e9 11 f0       	mov    %eax,0xf011e948
	memset(kern_pgdir, 0, PGSIZE);
f0101672:	83 c4 0c             	add    $0xc,%esp
f0101675:	68 00 10 00 00       	push   $0x1000
f010167a:	6a 00                	push   $0x0
f010167c:	50                   	push   %eax
f010167d:	e8 03 21 00 00       	call   f0103785 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101682:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101687:	83 c4 10             	add    $0x10,%esp
f010168a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010168f:	77 15                	ja     f01016a6 <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101691:	50                   	push   %eax
f0101692:	68 f8 43 10 f0       	push   $0xf01043f8
f0101697:	68 8d 00 00 00       	push   $0x8d
f010169c:	68 ac 4c 10 f0       	push   $0xf0104cac
f01016a1:	e8 e5 e9 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f01016a6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01016ac:	83 ca 05             	or     $0x5,%edx
f01016af:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01016b5:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f01016ba:	c1 e0 03             	shl    $0x3,%eax
f01016bd:	e8 16 f8 ff ff       	call   f0100ed8 <boot_alloc>
f01016c2:	a3 4c e9 11 f0       	mov    %eax,0xf011e94c
    cprintf("%u \n", sizeof(struct PageInfo)); 
f01016c7:	83 ec 08             	sub    $0x8,%esp
f01016ca:	6a 08                	push   $0x8
f01016cc:	68 62 4d 10 f0       	push   $0xf0104d62
f01016d1:	e8 7f 15 00 00       	call   f0102c55 <cprintf>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01016d6:	e8 76 fb ff ff       	call   f0101251 <page_init>

	check_page_free_list(1);
f01016db:	b8 01 00 00 00       	mov    $0x1,%eax
f01016e0:	e8 b3 f8 ff ff       	call   f0100f98 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01016e5:	83 c4 10             	add    $0x10,%esp
f01016e8:	83 3d 4c e9 11 f0 00 	cmpl   $0x0,0xf011e94c
f01016ef:	75 17                	jne    f0101708 <mem_init+0x133>
		panic("'pages' is a null pointer!");
f01016f1:	83 ec 04             	sub    $0x4,%esp
f01016f4:	68 67 4d 10 f0       	push   $0xf0104d67
f01016f9:	68 44 02 00 00       	push   $0x244
f01016fe:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101703:	e8 83 e9 ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101708:	a1 2c e5 11 f0       	mov    0xf011e52c,%eax
f010170d:	85 c0                	test   %eax,%eax
f010170f:	74 0e                	je     f010171f <mem_init+0x14a>
f0101711:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101716:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101717:	8b 00                	mov    (%eax),%eax
f0101719:	85 c0                	test   %eax,%eax
f010171b:	75 f9                	jne    f0101716 <mem_init+0x141>
f010171d:	eb 05                	jmp    f0101724 <mem_init+0x14f>
f010171f:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101724:	83 ec 0c             	sub    $0xc,%esp
f0101727:	6a 00                	push   $0x0
f0101729:	e8 d0 fb ff ff       	call   f01012fe <page_alloc>
f010172e:	89 c6                	mov    %eax,%esi
f0101730:	83 c4 10             	add    $0x10,%esp
f0101733:	85 c0                	test   %eax,%eax
f0101735:	75 19                	jne    f0101750 <mem_init+0x17b>
f0101737:	68 82 4d 10 f0       	push   $0xf0104d82
f010173c:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101741:	68 4c 02 00 00       	push   $0x24c
f0101746:	68 ac 4c 10 f0       	push   $0xf0104cac
f010174b:	e8 3b e9 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101750:	83 ec 0c             	sub    $0xc,%esp
f0101753:	6a 00                	push   $0x0
f0101755:	e8 a4 fb ff ff       	call   f01012fe <page_alloc>
f010175a:	89 c7                	mov    %eax,%edi
f010175c:	83 c4 10             	add    $0x10,%esp
f010175f:	85 c0                	test   %eax,%eax
f0101761:	75 19                	jne    f010177c <mem_init+0x1a7>
f0101763:	68 98 4d 10 f0       	push   $0xf0104d98
f0101768:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010176d:	68 4d 02 00 00       	push   $0x24d
f0101772:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101777:	e8 0f e9 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010177c:	83 ec 0c             	sub    $0xc,%esp
f010177f:	6a 00                	push   $0x0
f0101781:	e8 78 fb ff ff       	call   f01012fe <page_alloc>
f0101786:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101789:	83 c4 10             	add    $0x10,%esp
f010178c:	85 c0                	test   %eax,%eax
f010178e:	75 19                	jne    f01017a9 <mem_init+0x1d4>
f0101790:	68 ae 4d 10 f0       	push   $0xf0104dae
f0101795:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010179a:	68 4e 02 00 00       	push   $0x24e
f010179f:	68 ac 4c 10 f0       	push   $0xf0104cac
f01017a4:	e8 e2 e8 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017a9:	39 fe                	cmp    %edi,%esi
f01017ab:	75 19                	jne    f01017c6 <mem_init+0x1f1>
f01017ad:	68 c4 4d 10 f0       	push   $0xf0104dc4
f01017b2:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01017b7:	68 51 02 00 00       	push   $0x251
f01017bc:	68 ac 4c 10 f0       	push   $0xf0104cac
f01017c1:	e8 c5 e8 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017c6:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01017c9:	74 05                	je     f01017d0 <mem_init+0x1fb>
f01017cb:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01017ce:	75 19                	jne    f01017e9 <mem_init+0x214>
f01017d0:	68 f8 46 10 f0       	push   $0xf01046f8
f01017d5:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01017da:	68 52 02 00 00       	push   $0x252
f01017df:	68 ac 4c 10 f0       	push   $0xf0104cac
f01017e4:	e8 a2 e8 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017e9:	8b 15 4c e9 11 f0    	mov    0xf011e94c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01017ef:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f01017f4:	c1 e0 0c             	shl    $0xc,%eax
f01017f7:	89 f1                	mov    %esi,%ecx
f01017f9:	29 d1                	sub    %edx,%ecx
f01017fb:	c1 f9 03             	sar    $0x3,%ecx
f01017fe:	c1 e1 0c             	shl    $0xc,%ecx
f0101801:	39 c1                	cmp    %eax,%ecx
f0101803:	72 19                	jb     f010181e <mem_init+0x249>
f0101805:	68 d6 4d 10 f0       	push   $0xf0104dd6
f010180a:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010180f:	68 53 02 00 00       	push   $0x253
f0101814:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101819:	e8 6d e8 ff ff       	call   f010008b <_panic>
f010181e:	89 f9                	mov    %edi,%ecx
f0101820:	29 d1                	sub    %edx,%ecx
f0101822:	c1 f9 03             	sar    $0x3,%ecx
f0101825:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101828:	39 c8                	cmp    %ecx,%eax
f010182a:	77 19                	ja     f0101845 <mem_init+0x270>
f010182c:	68 f3 4d 10 f0       	push   $0xf0104df3
f0101831:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101836:	68 54 02 00 00       	push   $0x254
f010183b:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101840:	e8 46 e8 ff ff       	call   f010008b <_panic>
f0101845:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101848:	29 d1                	sub    %edx,%ecx
f010184a:	89 ca                	mov    %ecx,%edx
f010184c:	c1 fa 03             	sar    $0x3,%edx
f010184f:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101852:	39 d0                	cmp    %edx,%eax
f0101854:	77 19                	ja     f010186f <mem_init+0x29a>
f0101856:	68 10 4e 10 f0       	push   $0xf0104e10
f010185b:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101860:	68 55 02 00 00       	push   $0x255
f0101865:	68 ac 4c 10 f0       	push   $0xf0104cac
f010186a:	e8 1c e8 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010186f:	a1 2c e5 11 f0       	mov    0xf011e52c,%eax
f0101874:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101877:	c7 05 2c e5 11 f0 00 	movl   $0x0,0xf011e52c
f010187e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101881:	83 ec 0c             	sub    $0xc,%esp
f0101884:	6a 00                	push   $0x0
f0101886:	e8 73 fa ff ff       	call   f01012fe <page_alloc>
f010188b:	83 c4 10             	add    $0x10,%esp
f010188e:	85 c0                	test   %eax,%eax
f0101890:	74 19                	je     f01018ab <mem_init+0x2d6>
f0101892:	68 2d 4e 10 f0       	push   $0xf0104e2d
f0101897:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010189c:	68 5c 02 00 00       	push   $0x25c
f01018a1:	68 ac 4c 10 f0       	push   $0xf0104cac
f01018a6:	e8 e0 e7 ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f01018ab:	83 ec 0c             	sub    $0xc,%esp
f01018ae:	56                   	push   %esi
f01018af:	e8 d4 fa ff ff       	call   f0101388 <page_free>
	page_free(pp1);
f01018b4:	89 3c 24             	mov    %edi,(%esp)
f01018b7:	e8 cc fa ff ff       	call   f0101388 <page_free>
	page_free(pp2);
f01018bc:	83 c4 04             	add    $0x4,%esp
f01018bf:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018c2:	e8 c1 fa ff ff       	call   f0101388 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018ce:	e8 2b fa ff ff       	call   f01012fe <page_alloc>
f01018d3:	89 c6                	mov    %eax,%esi
f01018d5:	83 c4 10             	add    $0x10,%esp
f01018d8:	85 c0                	test   %eax,%eax
f01018da:	75 19                	jne    f01018f5 <mem_init+0x320>
f01018dc:	68 82 4d 10 f0       	push   $0xf0104d82
f01018e1:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01018e6:	68 63 02 00 00       	push   $0x263
f01018eb:	68 ac 4c 10 f0       	push   $0xf0104cac
f01018f0:	e8 96 e7 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01018f5:	83 ec 0c             	sub    $0xc,%esp
f01018f8:	6a 00                	push   $0x0
f01018fa:	e8 ff f9 ff ff       	call   f01012fe <page_alloc>
f01018ff:	89 c7                	mov    %eax,%edi
f0101901:	83 c4 10             	add    $0x10,%esp
f0101904:	85 c0                	test   %eax,%eax
f0101906:	75 19                	jne    f0101921 <mem_init+0x34c>
f0101908:	68 98 4d 10 f0       	push   $0xf0104d98
f010190d:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101912:	68 64 02 00 00       	push   $0x264
f0101917:	68 ac 4c 10 f0       	push   $0xf0104cac
f010191c:	e8 6a e7 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101921:	83 ec 0c             	sub    $0xc,%esp
f0101924:	6a 00                	push   $0x0
f0101926:	e8 d3 f9 ff ff       	call   f01012fe <page_alloc>
f010192b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010192e:	83 c4 10             	add    $0x10,%esp
f0101931:	85 c0                	test   %eax,%eax
f0101933:	75 19                	jne    f010194e <mem_init+0x379>
f0101935:	68 ae 4d 10 f0       	push   $0xf0104dae
f010193a:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010193f:	68 65 02 00 00       	push   $0x265
f0101944:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101949:	e8 3d e7 ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010194e:	39 fe                	cmp    %edi,%esi
f0101950:	75 19                	jne    f010196b <mem_init+0x396>
f0101952:	68 c4 4d 10 f0       	push   $0xf0104dc4
f0101957:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010195c:	68 67 02 00 00       	push   $0x267
f0101961:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101966:	e8 20 e7 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010196b:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010196e:	74 05                	je     f0101975 <mem_init+0x3a0>
f0101970:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101973:	75 19                	jne    f010198e <mem_init+0x3b9>
f0101975:	68 f8 46 10 f0       	push   $0xf01046f8
f010197a:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010197f:	68 68 02 00 00       	push   $0x268
f0101984:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101989:	e8 fd e6 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f010198e:	83 ec 0c             	sub    $0xc,%esp
f0101991:	6a 00                	push   $0x0
f0101993:	e8 66 f9 ff ff       	call   f01012fe <page_alloc>
f0101998:	83 c4 10             	add    $0x10,%esp
f010199b:	85 c0                	test   %eax,%eax
f010199d:	74 19                	je     f01019b8 <mem_init+0x3e3>
f010199f:	68 2d 4e 10 f0       	push   $0xf0104e2d
f01019a4:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01019a9:	68 69 02 00 00       	push   $0x269
f01019ae:	68 ac 4c 10 f0       	push   $0xf0104cac
f01019b3:	e8 d3 e6 ff ff       	call   f010008b <_panic>
f01019b8:	89 f0                	mov    %esi,%eax
f01019ba:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f01019c0:	c1 f8 03             	sar    $0x3,%eax
f01019c3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019c6:	89 c2                	mov    %eax,%edx
f01019c8:	c1 ea 0c             	shr    $0xc,%edx
f01019cb:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f01019d1:	72 12                	jb     f01019e5 <mem_init+0x410>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019d3:	50                   	push   %eax
f01019d4:	68 b4 45 10 f0       	push   $0xf01045b4
f01019d9:	6a 52                	push   $0x52
f01019db:	68 b8 4c 10 f0       	push   $0xf0104cb8
f01019e0:	e8 a6 e6 ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01019e5:	83 ec 04             	sub    $0x4,%esp
f01019e8:	68 00 10 00 00       	push   $0x1000
f01019ed:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01019ef:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01019f4:	50                   	push   %eax
f01019f5:	e8 8b 1d 00 00       	call   f0103785 <memset>
	page_free(pp0);
f01019fa:	89 34 24             	mov    %esi,(%esp)
f01019fd:	e8 86 f9 ff ff       	call   f0101388 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a02:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a09:	e8 f0 f8 ff ff       	call   f01012fe <page_alloc>
f0101a0e:	83 c4 10             	add    $0x10,%esp
f0101a11:	85 c0                	test   %eax,%eax
f0101a13:	75 19                	jne    f0101a2e <mem_init+0x459>
f0101a15:	68 3c 4e 10 f0       	push   $0xf0104e3c
f0101a1a:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101a1f:	68 6e 02 00 00       	push   $0x26e
f0101a24:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101a29:	e8 5d e6 ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f0101a2e:	39 c6                	cmp    %eax,%esi
f0101a30:	74 19                	je     f0101a4b <mem_init+0x476>
f0101a32:	68 5a 4e 10 f0       	push   $0xf0104e5a
f0101a37:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101a3c:	68 6f 02 00 00       	push   $0x26f
f0101a41:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101a46:	e8 40 e6 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a4b:	89 f2                	mov    %esi,%edx
f0101a4d:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101a53:	c1 fa 03             	sar    $0x3,%edx
f0101a56:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a59:	89 d0                	mov    %edx,%eax
f0101a5b:	c1 e8 0c             	shr    $0xc,%eax
f0101a5e:	3b 05 44 e9 11 f0    	cmp    0xf011e944,%eax
f0101a64:	72 12                	jb     f0101a78 <mem_init+0x4a3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a66:	52                   	push   %edx
f0101a67:	68 b4 45 10 f0       	push   $0xf01045b4
f0101a6c:	6a 52                	push   $0x52
f0101a6e:	68 b8 4c 10 f0       	push   $0xf0104cb8
f0101a73:	e8 13 e6 ff ff       	call   f010008b <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101a78:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101a7f:	75 11                	jne    f0101a92 <mem_init+0x4bd>
f0101a81:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101a87:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101a8d:	80 38 00             	cmpb   $0x0,(%eax)
f0101a90:	74 19                	je     f0101aab <mem_init+0x4d6>
f0101a92:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101a97:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101a9c:	68 72 02 00 00       	push   $0x272
f0101aa1:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101aa6:	e8 e0 e5 ff ff       	call   f010008b <_panic>
f0101aab:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101aac:	39 d0                	cmp    %edx,%eax
f0101aae:	75 dd                	jne    f0101a8d <mem_init+0x4b8>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101ab0:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101ab3:	89 15 2c e5 11 f0    	mov    %edx,0xf011e52c

	// free the pages we took
	page_free(pp0);
f0101ab9:	83 ec 0c             	sub    $0xc,%esp
f0101abc:	56                   	push   %esi
f0101abd:	e8 c6 f8 ff ff       	call   f0101388 <page_free>
	page_free(pp1);
f0101ac2:	89 3c 24             	mov    %edi,(%esp)
f0101ac5:	e8 be f8 ff ff       	call   f0101388 <page_free>
	page_free(pp2);
f0101aca:	83 c4 04             	add    $0x4,%esp
f0101acd:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ad0:	e8 b3 f8 ff ff       	call   f0101388 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ad5:	a1 2c e5 11 f0       	mov    0xf011e52c,%eax
f0101ada:	83 c4 10             	add    $0x10,%esp
f0101add:	85 c0                	test   %eax,%eax
f0101adf:	74 07                	je     f0101ae8 <mem_init+0x513>
		--nfree;
f0101ae1:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ae2:	8b 00                	mov    (%eax),%eax
f0101ae4:	85 c0                	test   %eax,%eax
f0101ae6:	75 f9                	jne    f0101ae1 <mem_init+0x50c>
		--nfree;
	assert(nfree == 0);
f0101ae8:	85 db                	test   %ebx,%ebx
f0101aea:	74 19                	je     f0101b05 <mem_init+0x530>
f0101aec:	68 74 4e 10 f0       	push   $0xf0104e74
f0101af1:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101af6:	68 7f 02 00 00       	push   $0x27f
f0101afb:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101b00:	e8 86 e5 ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101b05:	83 ec 0c             	sub    $0xc,%esp
f0101b08:	68 18 47 10 f0       	push   $0xf0104718
f0101b0d:	e8 43 11 00 00       	call   f0102c55 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b19:	e8 e0 f7 ff ff       	call   f01012fe <page_alloc>
f0101b1e:	89 c6                	mov    %eax,%esi
f0101b20:	83 c4 10             	add    $0x10,%esp
f0101b23:	85 c0                	test   %eax,%eax
f0101b25:	75 19                	jne    f0101b40 <mem_init+0x56b>
f0101b27:	68 82 4d 10 f0       	push   $0xf0104d82
f0101b2c:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101b31:	68 d8 02 00 00       	push   $0x2d8
f0101b36:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101b3b:	e8 4b e5 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101b40:	83 ec 0c             	sub    $0xc,%esp
f0101b43:	6a 00                	push   $0x0
f0101b45:	e8 b4 f7 ff ff       	call   f01012fe <page_alloc>
f0101b4a:	89 c7                	mov    %eax,%edi
f0101b4c:	83 c4 10             	add    $0x10,%esp
f0101b4f:	85 c0                	test   %eax,%eax
f0101b51:	75 19                	jne    f0101b6c <mem_init+0x597>
f0101b53:	68 98 4d 10 f0       	push   $0xf0104d98
f0101b58:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101b5d:	68 d9 02 00 00       	push   $0x2d9
f0101b62:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101b67:	e8 1f e5 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101b6c:	83 ec 0c             	sub    $0xc,%esp
f0101b6f:	6a 00                	push   $0x0
f0101b71:	e8 88 f7 ff ff       	call   f01012fe <page_alloc>
f0101b76:	89 c3                	mov    %eax,%ebx
f0101b78:	83 c4 10             	add    $0x10,%esp
f0101b7b:	85 c0                	test   %eax,%eax
f0101b7d:	75 19                	jne    f0101b98 <mem_init+0x5c3>
f0101b7f:	68 ae 4d 10 f0       	push   $0xf0104dae
f0101b84:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101b89:	68 da 02 00 00       	push   $0x2da
f0101b8e:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101b93:	e8 f3 e4 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b98:	39 fe                	cmp    %edi,%esi
f0101b9a:	75 19                	jne    f0101bb5 <mem_init+0x5e0>
f0101b9c:	68 c4 4d 10 f0       	push   $0xf0104dc4
f0101ba1:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101ba6:	68 dd 02 00 00       	push   $0x2dd
f0101bab:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101bb0:	e8 d6 e4 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101bb5:	39 c7                	cmp    %eax,%edi
f0101bb7:	74 04                	je     f0101bbd <mem_init+0x5e8>
f0101bb9:	39 c6                	cmp    %eax,%esi
f0101bbb:	75 19                	jne    f0101bd6 <mem_init+0x601>
f0101bbd:	68 f8 46 10 f0       	push   $0xf01046f8
f0101bc2:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101bc7:	68 de 02 00 00       	push   $0x2de
f0101bcc:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101bd1:	e8 b5 e4 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101bd6:	8b 0d 2c e5 11 f0    	mov    0xf011e52c,%ecx
f0101bdc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101bdf:	c7 05 2c e5 11 f0 00 	movl   $0x0,0xf011e52c
f0101be6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101be9:	83 ec 0c             	sub    $0xc,%esp
f0101bec:	6a 00                	push   $0x0
f0101bee:	e8 0b f7 ff ff       	call   f01012fe <page_alloc>
f0101bf3:	83 c4 10             	add    $0x10,%esp
f0101bf6:	85 c0                	test   %eax,%eax
f0101bf8:	74 19                	je     f0101c13 <mem_init+0x63e>
f0101bfa:	68 2d 4e 10 f0       	push   $0xf0104e2d
f0101bff:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101c04:	68 e5 02 00 00       	push   $0x2e5
f0101c09:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101c0e:	e8 78 e4 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c13:	83 ec 04             	sub    $0x4,%esp
f0101c16:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c19:	50                   	push   %eax
f0101c1a:	6a 00                	push   $0x0
f0101c1c:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101c22:	e8 87 f8 ff ff       	call   f01014ae <page_lookup>
f0101c27:	83 c4 10             	add    $0x10,%esp
f0101c2a:	85 c0                	test   %eax,%eax
f0101c2c:	74 19                	je     f0101c47 <mem_init+0x672>
f0101c2e:	68 38 47 10 f0       	push   $0xf0104738
f0101c33:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101c38:	68 e8 02 00 00       	push   $0x2e8
f0101c3d:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101c42:	e8 44 e4 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c47:	6a 02                	push   $0x2
f0101c49:	6a 00                	push   $0x0
f0101c4b:	57                   	push   %edi
f0101c4c:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101c52:	e8 15 f9 ff ff       	call   f010156c <page_insert>
f0101c57:	83 c4 10             	add    $0x10,%esp
f0101c5a:	85 c0                	test   %eax,%eax
f0101c5c:	78 19                	js     f0101c77 <mem_init+0x6a2>
f0101c5e:	68 70 47 10 f0       	push   $0xf0104770
f0101c63:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101c68:	68 eb 02 00 00       	push   $0x2eb
f0101c6d:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101c72:	e8 14 e4 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c77:	83 ec 0c             	sub    $0xc,%esp
f0101c7a:	56                   	push   %esi
f0101c7b:	e8 08 f7 ff ff       	call   f0101388 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c80:	6a 02                	push   $0x2
f0101c82:	6a 00                	push   $0x0
f0101c84:	57                   	push   %edi
f0101c85:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101c8b:	e8 dc f8 ff ff       	call   f010156c <page_insert>
f0101c90:	83 c4 20             	add    $0x20,%esp
f0101c93:	85 c0                	test   %eax,%eax
f0101c95:	74 19                	je     f0101cb0 <mem_init+0x6db>
f0101c97:	68 a0 47 10 f0       	push   $0xf01047a0
f0101c9c:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101ca1:	68 ef 02 00 00       	push   $0x2ef
f0101ca6:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101cab:	e8 db e3 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101cb0:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101cb5:	8b 08                	mov    (%eax),%ecx
f0101cb7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101cbd:	89 f2                	mov    %esi,%edx
f0101cbf:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101cc5:	c1 fa 03             	sar    $0x3,%edx
f0101cc8:	c1 e2 0c             	shl    $0xc,%edx
f0101ccb:	39 d1                	cmp    %edx,%ecx
f0101ccd:	74 19                	je     f0101ce8 <mem_init+0x713>
f0101ccf:	68 d0 47 10 f0       	push   $0xf01047d0
f0101cd4:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101cd9:	68 f0 02 00 00       	push   $0x2f0
f0101cde:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101ce3:	e8 a3 e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101ce8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ced:	e8 1d f2 ff ff       	call   f0100f0f <check_va2pa>
f0101cf2:	89 fa                	mov    %edi,%edx
f0101cf4:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101cfa:	c1 fa 03             	sar    $0x3,%edx
f0101cfd:	c1 e2 0c             	shl    $0xc,%edx
f0101d00:	39 d0                	cmp    %edx,%eax
f0101d02:	74 19                	je     f0101d1d <mem_init+0x748>
f0101d04:	68 f8 47 10 f0       	push   $0xf01047f8
f0101d09:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101d0e:	68 f1 02 00 00       	push   $0x2f1
f0101d13:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101d18:	e8 6e e3 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101d1d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d22:	74 19                	je     f0101d3d <mem_init+0x768>
f0101d24:	68 7f 4e 10 f0       	push   $0xf0104e7f
f0101d29:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101d2e:	68 f2 02 00 00       	push   $0x2f2
f0101d33:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101d38:	e8 4e e3 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0101d3d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d42:	74 19                	je     f0101d5d <mem_init+0x788>
f0101d44:	68 90 4e 10 f0       	push   $0xf0104e90
f0101d49:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101d4e:	68 f3 02 00 00       	push   $0x2f3
f0101d53:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101d58:	e8 2e e3 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d5d:	6a 02                	push   $0x2
f0101d5f:	68 00 10 00 00       	push   $0x1000
f0101d64:	53                   	push   %ebx
f0101d65:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101d6b:	e8 fc f7 ff ff       	call   f010156c <page_insert>
f0101d70:	83 c4 10             	add    $0x10,%esp
f0101d73:	85 c0                	test   %eax,%eax
f0101d75:	74 19                	je     f0101d90 <mem_init+0x7bb>
f0101d77:	68 28 48 10 f0       	push   $0xf0104828
f0101d7c:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101d81:	68 f6 02 00 00       	push   $0x2f6
f0101d86:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101d8b:	e8 fb e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d90:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d95:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101d9a:	e8 70 f1 ff ff       	call   f0100f0f <check_va2pa>
f0101d9f:	89 da                	mov    %ebx,%edx
f0101da1:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101da7:	c1 fa 03             	sar    $0x3,%edx
f0101daa:	c1 e2 0c             	shl    $0xc,%edx
f0101dad:	39 d0                	cmp    %edx,%eax
f0101daf:	74 19                	je     f0101dca <mem_init+0x7f5>
f0101db1:	68 64 48 10 f0       	push   $0xf0104864
f0101db6:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101dbb:	68 f7 02 00 00       	push   $0x2f7
f0101dc0:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101dc5:	e8 c1 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101dca:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101dcf:	74 19                	je     f0101dea <mem_init+0x815>
f0101dd1:	68 a1 4e 10 f0       	push   $0xf0104ea1
f0101dd6:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101ddb:	68 f8 02 00 00       	push   $0x2f8
f0101de0:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101de5:	e8 a1 e2 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101dea:	83 ec 0c             	sub    $0xc,%esp
f0101ded:	6a 00                	push   $0x0
f0101def:	e8 0a f5 ff ff       	call   f01012fe <page_alloc>
f0101df4:	83 c4 10             	add    $0x10,%esp
f0101df7:	85 c0                	test   %eax,%eax
f0101df9:	74 19                	je     f0101e14 <mem_init+0x83f>
f0101dfb:	68 2d 4e 10 f0       	push   $0xf0104e2d
f0101e00:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101e05:	68 fb 02 00 00       	push   $0x2fb
f0101e0a:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101e0f:	e8 77 e2 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e14:	6a 02                	push   $0x2
f0101e16:	68 00 10 00 00       	push   $0x1000
f0101e1b:	53                   	push   %ebx
f0101e1c:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101e22:	e8 45 f7 ff ff       	call   f010156c <page_insert>
f0101e27:	83 c4 10             	add    $0x10,%esp
f0101e2a:	85 c0                	test   %eax,%eax
f0101e2c:	74 19                	je     f0101e47 <mem_init+0x872>
f0101e2e:	68 28 48 10 f0       	push   $0xf0104828
f0101e33:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101e38:	68 fe 02 00 00       	push   $0x2fe
f0101e3d:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101e42:	e8 44 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e47:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e4c:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101e51:	e8 b9 f0 ff ff       	call   f0100f0f <check_va2pa>
f0101e56:	89 da                	mov    %ebx,%edx
f0101e58:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101e5e:	c1 fa 03             	sar    $0x3,%edx
f0101e61:	c1 e2 0c             	shl    $0xc,%edx
f0101e64:	39 d0                	cmp    %edx,%eax
f0101e66:	74 19                	je     f0101e81 <mem_init+0x8ac>
f0101e68:	68 64 48 10 f0       	push   $0xf0104864
f0101e6d:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101e72:	68 ff 02 00 00       	push   $0x2ff
f0101e77:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101e7c:	e8 0a e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101e81:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e86:	74 19                	je     f0101ea1 <mem_init+0x8cc>
f0101e88:	68 a1 4e 10 f0       	push   $0xf0104ea1
f0101e8d:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101e92:	68 00 03 00 00       	push   $0x300
f0101e97:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101e9c:	e8 ea e1 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ea1:	83 ec 0c             	sub    $0xc,%esp
f0101ea4:	6a 00                	push   $0x0
f0101ea6:	e8 53 f4 ff ff       	call   f01012fe <page_alloc>
f0101eab:	83 c4 10             	add    $0x10,%esp
f0101eae:	85 c0                	test   %eax,%eax
f0101eb0:	74 19                	je     f0101ecb <mem_init+0x8f6>
f0101eb2:	68 2d 4e 10 f0       	push   $0xf0104e2d
f0101eb7:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101ebc:	68 04 03 00 00       	push   $0x304
f0101ec1:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101ec6:	e8 c0 e1 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ecb:	8b 15 48 e9 11 f0    	mov    0xf011e948,%edx
f0101ed1:	8b 02                	mov    (%edx),%eax
f0101ed3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ed8:	89 c1                	mov    %eax,%ecx
f0101eda:	c1 e9 0c             	shr    $0xc,%ecx
f0101edd:	3b 0d 44 e9 11 f0    	cmp    0xf011e944,%ecx
f0101ee3:	72 15                	jb     f0101efa <mem_init+0x925>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ee5:	50                   	push   %eax
f0101ee6:	68 b4 45 10 f0       	push   $0xf01045b4
f0101eeb:	68 07 03 00 00       	push   $0x307
f0101ef0:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101ef5:	e8 91 e1 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101efa:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101eff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f02:	83 ec 04             	sub    $0x4,%esp
f0101f05:	6a 00                	push   $0x0
f0101f07:	68 00 10 00 00       	push   $0x1000
f0101f0c:	52                   	push   %edx
f0101f0d:	e8 b4 f4 ff ff       	call   f01013c6 <pgdir_walk>
f0101f12:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101f15:	83 c2 04             	add    $0x4,%edx
f0101f18:	83 c4 10             	add    $0x10,%esp
f0101f1b:	39 d0                	cmp    %edx,%eax
f0101f1d:	74 19                	je     f0101f38 <mem_init+0x963>
f0101f1f:	68 94 48 10 f0       	push   $0xf0104894
f0101f24:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101f29:	68 08 03 00 00       	push   $0x308
f0101f2e:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101f33:	e8 53 e1 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f38:	6a 06                	push   $0x6
f0101f3a:	68 00 10 00 00       	push   $0x1000
f0101f3f:	53                   	push   %ebx
f0101f40:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101f46:	e8 21 f6 ff ff       	call   f010156c <page_insert>
f0101f4b:	83 c4 10             	add    $0x10,%esp
f0101f4e:	85 c0                	test   %eax,%eax
f0101f50:	74 19                	je     f0101f6b <mem_init+0x996>
f0101f52:	68 d4 48 10 f0       	push   $0xf01048d4
f0101f57:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101f5c:	68 0b 03 00 00       	push   $0x30b
f0101f61:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101f66:	e8 20 e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f6b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f70:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101f75:	e8 95 ef ff ff       	call   f0100f0f <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f7a:	89 da                	mov    %ebx,%edx
f0101f7c:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101f82:	c1 fa 03             	sar    $0x3,%edx
f0101f85:	c1 e2 0c             	shl    $0xc,%edx
f0101f88:	39 d0                	cmp    %edx,%eax
f0101f8a:	74 19                	je     f0101fa5 <mem_init+0x9d0>
f0101f8c:	68 64 48 10 f0       	push   $0xf0104864
f0101f91:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101f96:	68 0c 03 00 00       	push   $0x30c
f0101f9b:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101fa0:	e8 e6 e0 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101fa5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101faa:	74 19                	je     f0101fc5 <mem_init+0x9f0>
f0101fac:	68 a1 4e 10 f0       	push   $0xf0104ea1
f0101fb1:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101fb6:	68 0d 03 00 00       	push   $0x30d
f0101fbb:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101fc0:	e8 c6 e0 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101fc5:	83 ec 04             	sub    $0x4,%esp
f0101fc8:	6a 00                	push   $0x0
f0101fca:	68 00 10 00 00       	push   $0x1000
f0101fcf:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101fd5:	e8 ec f3 ff ff       	call   f01013c6 <pgdir_walk>
f0101fda:	83 c4 10             	add    $0x10,%esp
f0101fdd:	f6 00 04             	testb  $0x4,(%eax)
f0101fe0:	75 19                	jne    f0101ffb <mem_init+0xa26>
f0101fe2:	68 14 49 10 f0       	push   $0xf0104914
f0101fe7:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0101fec:	68 0e 03 00 00       	push   $0x30e
f0101ff1:	68 ac 4c 10 f0       	push   $0xf0104cac
f0101ff6:	e8 90 e0 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101ffb:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102000:	f6 00 04             	testb  $0x4,(%eax)
f0102003:	75 19                	jne    f010201e <mem_init+0xa49>
f0102005:	68 b2 4e 10 f0       	push   $0xf0104eb2
f010200a:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010200f:	68 0f 03 00 00       	push   $0x30f
f0102014:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102019:	e8 6d e0 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010201e:	6a 02                	push   $0x2
f0102020:	68 00 10 00 00       	push   $0x1000
f0102025:	53                   	push   %ebx
f0102026:	50                   	push   %eax
f0102027:	e8 40 f5 ff ff       	call   f010156c <page_insert>
f010202c:	83 c4 10             	add    $0x10,%esp
f010202f:	85 c0                	test   %eax,%eax
f0102031:	74 19                	je     f010204c <mem_init+0xa77>
f0102033:	68 28 48 10 f0       	push   $0xf0104828
f0102038:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010203d:	68 12 03 00 00       	push   $0x312
f0102042:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102047:	e8 3f e0 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010204c:	83 ec 04             	sub    $0x4,%esp
f010204f:	6a 00                	push   $0x0
f0102051:	68 00 10 00 00       	push   $0x1000
f0102056:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f010205c:	e8 65 f3 ff ff       	call   f01013c6 <pgdir_walk>
f0102061:	83 c4 10             	add    $0x10,%esp
f0102064:	f6 00 02             	testb  $0x2,(%eax)
f0102067:	75 19                	jne    f0102082 <mem_init+0xaad>
f0102069:	68 48 49 10 f0       	push   $0xf0104948
f010206e:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102073:	68 13 03 00 00       	push   $0x313
f0102078:	68 ac 4c 10 f0       	push   $0xf0104cac
f010207d:	e8 09 e0 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102082:	83 ec 04             	sub    $0x4,%esp
f0102085:	6a 00                	push   $0x0
f0102087:	68 00 10 00 00       	push   $0x1000
f010208c:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102092:	e8 2f f3 ff ff       	call   f01013c6 <pgdir_walk>
f0102097:	83 c4 10             	add    $0x10,%esp
f010209a:	f6 00 04             	testb  $0x4,(%eax)
f010209d:	74 19                	je     f01020b8 <mem_init+0xae3>
f010209f:	68 7c 49 10 f0       	push   $0xf010497c
f01020a4:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01020a9:	68 14 03 00 00       	push   $0x314
f01020ae:	68 ac 4c 10 f0       	push   $0xf0104cac
f01020b3:	e8 d3 df ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020b8:	6a 02                	push   $0x2
f01020ba:	68 00 00 40 00       	push   $0x400000
f01020bf:	56                   	push   %esi
f01020c0:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f01020c6:	e8 a1 f4 ff ff       	call   f010156c <page_insert>
f01020cb:	83 c4 10             	add    $0x10,%esp
f01020ce:	85 c0                	test   %eax,%eax
f01020d0:	78 19                	js     f01020eb <mem_init+0xb16>
f01020d2:	68 b4 49 10 f0       	push   $0xf01049b4
f01020d7:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01020dc:	68 17 03 00 00       	push   $0x317
f01020e1:	68 ac 4c 10 f0       	push   $0xf0104cac
f01020e6:	e8 a0 df ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01020eb:	6a 02                	push   $0x2
f01020ed:	68 00 10 00 00       	push   $0x1000
f01020f2:	57                   	push   %edi
f01020f3:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f01020f9:	e8 6e f4 ff ff       	call   f010156c <page_insert>
f01020fe:	83 c4 10             	add    $0x10,%esp
f0102101:	85 c0                	test   %eax,%eax
f0102103:	74 19                	je     f010211e <mem_init+0xb49>
f0102105:	68 ec 49 10 f0       	push   $0xf01049ec
f010210a:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010210f:	68 1a 03 00 00       	push   $0x31a
f0102114:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102119:	e8 6d df ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010211e:	83 ec 04             	sub    $0x4,%esp
f0102121:	6a 00                	push   $0x0
f0102123:	68 00 10 00 00       	push   $0x1000
f0102128:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f010212e:	e8 93 f2 ff ff       	call   f01013c6 <pgdir_walk>
f0102133:	83 c4 10             	add    $0x10,%esp
f0102136:	f6 00 04             	testb  $0x4,(%eax)
f0102139:	74 19                	je     f0102154 <mem_init+0xb7f>
f010213b:	68 7c 49 10 f0       	push   $0xf010497c
f0102140:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102145:	68 1b 03 00 00       	push   $0x31b
f010214a:	68 ac 4c 10 f0       	push   $0xf0104cac
f010214f:	e8 37 df ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102154:	ba 00 00 00 00       	mov    $0x0,%edx
f0102159:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f010215e:	e8 ac ed ff ff       	call   f0100f0f <check_va2pa>
f0102163:	89 fa                	mov    %edi,%edx
f0102165:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f010216b:	c1 fa 03             	sar    $0x3,%edx
f010216e:	c1 e2 0c             	shl    $0xc,%edx
f0102171:	39 d0                	cmp    %edx,%eax
f0102173:	74 19                	je     f010218e <mem_init+0xbb9>
f0102175:	68 28 4a 10 f0       	push   $0xf0104a28
f010217a:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010217f:	68 1e 03 00 00       	push   $0x31e
f0102184:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102189:	e8 fd de ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010218e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102193:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102198:	e8 72 ed ff ff       	call   f0100f0f <check_va2pa>
f010219d:	89 fa                	mov    %edi,%edx
f010219f:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f01021a5:	c1 fa 03             	sar    $0x3,%edx
f01021a8:	c1 e2 0c             	shl    $0xc,%edx
f01021ab:	39 d0                	cmp    %edx,%eax
f01021ad:	74 19                	je     f01021c8 <mem_init+0xbf3>
f01021af:	68 54 4a 10 f0       	push   $0xf0104a54
f01021b4:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01021b9:	68 1f 03 00 00       	push   $0x31f
f01021be:	68 ac 4c 10 f0       	push   $0xf0104cac
f01021c3:	e8 c3 de ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01021c8:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f01021cd:	74 19                	je     f01021e8 <mem_init+0xc13>
f01021cf:	68 c8 4e 10 f0       	push   $0xf0104ec8
f01021d4:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01021d9:	68 21 03 00 00       	push   $0x321
f01021de:	68 ac 4c 10 f0       	push   $0xf0104cac
f01021e3:	e8 a3 de ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f01021e8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021ed:	74 19                	je     f0102208 <mem_init+0xc33>
f01021ef:	68 d9 4e 10 f0       	push   $0xf0104ed9
f01021f4:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01021f9:	68 22 03 00 00       	push   $0x322
f01021fe:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102203:	e8 83 de ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102208:	83 ec 0c             	sub    $0xc,%esp
f010220b:	6a 00                	push   $0x0
f010220d:	e8 ec f0 ff ff       	call   f01012fe <page_alloc>
f0102212:	83 c4 10             	add    $0x10,%esp
f0102215:	85 c0                	test   %eax,%eax
f0102217:	74 04                	je     f010221d <mem_init+0xc48>
f0102219:	39 c3                	cmp    %eax,%ebx
f010221b:	74 19                	je     f0102236 <mem_init+0xc61>
f010221d:	68 84 4a 10 f0       	push   $0xf0104a84
f0102222:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102227:	68 25 03 00 00       	push   $0x325
f010222c:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102231:	e8 55 de ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102236:	83 ec 08             	sub    $0x8,%esp
f0102239:	6a 00                	push   $0x0
f010223b:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102241:	e8 d9 f2 ff ff       	call   f010151f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102246:	ba 00 00 00 00       	mov    $0x0,%edx
f010224b:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102250:	e8 ba ec ff ff       	call   f0100f0f <check_va2pa>
f0102255:	83 c4 10             	add    $0x10,%esp
f0102258:	83 f8 ff             	cmp    $0xffffffff,%eax
f010225b:	74 19                	je     f0102276 <mem_init+0xca1>
f010225d:	68 a8 4a 10 f0       	push   $0xf0104aa8
f0102262:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102267:	68 29 03 00 00       	push   $0x329
f010226c:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102271:	e8 15 de ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102276:	ba 00 10 00 00       	mov    $0x1000,%edx
f010227b:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102280:	e8 8a ec ff ff       	call   f0100f0f <check_va2pa>
f0102285:	89 fa                	mov    %edi,%edx
f0102287:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f010228d:	c1 fa 03             	sar    $0x3,%edx
f0102290:	c1 e2 0c             	shl    $0xc,%edx
f0102293:	39 d0                	cmp    %edx,%eax
f0102295:	74 19                	je     f01022b0 <mem_init+0xcdb>
f0102297:	68 54 4a 10 f0       	push   $0xf0104a54
f010229c:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01022a1:	68 2a 03 00 00       	push   $0x32a
f01022a6:	68 ac 4c 10 f0       	push   $0xf0104cac
f01022ab:	e8 db dd ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f01022b0:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01022b5:	74 19                	je     f01022d0 <mem_init+0xcfb>
f01022b7:	68 7f 4e 10 f0       	push   $0xf0104e7f
f01022bc:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01022c1:	68 2b 03 00 00       	push   $0x32b
f01022c6:	68 ac 4c 10 f0       	push   $0xf0104cac
f01022cb:	e8 bb dd ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f01022d0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022d5:	74 19                	je     f01022f0 <mem_init+0xd1b>
f01022d7:	68 d9 4e 10 f0       	push   $0xf0104ed9
f01022dc:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01022e1:	68 2c 03 00 00       	push   $0x32c
f01022e6:	68 ac 4c 10 f0       	push   $0xf0104cac
f01022eb:	e8 9b dd ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01022f0:	83 ec 08             	sub    $0x8,%esp
f01022f3:	68 00 10 00 00       	push   $0x1000
f01022f8:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f01022fe:	e8 1c f2 ff ff       	call   f010151f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102303:	ba 00 00 00 00       	mov    $0x0,%edx
f0102308:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f010230d:	e8 fd eb ff ff       	call   f0100f0f <check_va2pa>
f0102312:	83 c4 10             	add    $0x10,%esp
f0102315:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102318:	74 19                	je     f0102333 <mem_init+0xd5e>
f010231a:	68 a8 4a 10 f0       	push   $0xf0104aa8
f010231f:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102324:	68 30 03 00 00       	push   $0x330
f0102329:	68 ac 4c 10 f0       	push   $0xf0104cac
f010232e:	e8 58 dd ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102333:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102338:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f010233d:	e8 cd eb ff ff       	call   f0100f0f <check_va2pa>
f0102342:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102345:	74 19                	je     f0102360 <mem_init+0xd8b>
f0102347:	68 cc 4a 10 f0       	push   $0xf0104acc
f010234c:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102351:	68 31 03 00 00       	push   $0x331
f0102356:	68 ac 4c 10 f0       	push   $0xf0104cac
f010235b:	e8 2b dd ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102360:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102365:	74 19                	je     f0102380 <mem_init+0xdab>
f0102367:	68 ea 4e 10 f0       	push   $0xf0104eea
f010236c:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102371:	68 32 03 00 00       	push   $0x332
f0102376:	68 ac 4c 10 f0       	push   $0xf0104cac
f010237b:	e8 0b dd ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102380:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102385:	74 19                	je     f01023a0 <mem_init+0xdcb>
f0102387:	68 d9 4e 10 f0       	push   $0xf0104ed9
f010238c:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102391:	68 33 03 00 00       	push   $0x333
f0102396:	68 ac 4c 10 f0       	push   $0xf0104cac
f010239b:	e8 eb dc ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01023a0:	83 ec 0c             	sub    $0xc,%esp
f01023a3:	6a 00                	push   $0x0
f01023a5:	e8 54 ef ff ff       	call   f01012fe <page_alloc>
f01023aa:	83 c4 10             	add    $0x10,%esp
f01023ad:	85 c0                	test   %eax,%eax
f01023af:	74 04                	je     f01023b5 <mem_init+0xde0>
f01023b1:	39 c7                	cmp    %eax,%edi
f01023b3:	74 19                	je     f01023ce <mem_init+0xdf9>
f01023b5:	68 f4 4a 10 f0       	push   $0xf0104af4
f01023ba:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01023bf:	68 36 03 00 00       	push   $0x336
f01023c4:	68 ac 4c 10 f0       	push   $0xf0104cac
f01023c9:	e8 bd dc ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01023ce:	83 ec 0c             	sub    $0xc,%esp
f01023d1:	6a 00                	push   $0x0
f01023d3:	e8 26 ef ff ff       	call   f01012fe <page_alloc>
f01023d8:	83 c4 10             	add    $0x10,%esp
f01023db:	85 c0                	test   %eax,%eax
f01023dd:	74 19                	je     f01023f8 <mem_init+0xe23>
f01023df:	68 2d 4e 10 f0       	push   $0xf0104e2d
f01023e4:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01023e9:	68 39 03 00 00       	push   $0x339
f01023ee:	68 ac 4c 10 f0       	push   $0xf0104cac
f01023f3:	e8 93 dc ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023f8:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f01023fd:	8b 08                	mov    (%eax),%ecx
f01023ff:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102405:	89 f2                	mov    %esi,%edx
f0102407:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f010240d:	c1 fa 03             	sar    $0x3,%edx
f0102410:	c1 e2 0c             	shl    $0xc,%edx
f0102413:	39 d1                	cmp    %edx,%ecx
f0102415:	74 19                	je     f0102430 <mem_init+0xe5b>
f0102417:	68 d0 47 10 f0       	push   $0xf01047d0
f010241c:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102421:	68 3c 03 00 00       	push   $0x33c
f0102426:	68 ac 4c 10 f0       	push   $0xf0104cac
f010242b:	e8 5b dc ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102430:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102436:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010243b:	74 19                	je     f0102456 <mem_init+0xe81>
f010243d:	68 90 4e 10 f0       	push   $0xf0104e90
f0102442:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102447:	68 3e 03 00 00       	push   $0x33e
f010244c:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102451:	e8 35 dc ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102456:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010245c:	83 ec 0c             	sub    $0xc,%esp
f010245f:	56                   	push   %esi
f0102460:	e8 23 ef ff ff       	call   f0101388 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102465:	83 c4 0c             	add    $0xc,%esp
f0102468:	6a 01                	push   $0x1
f010246a:	68 00 10 40 00       	push   $0x401000
f010246f:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102475:	e8 4c ef ff ff       	call   f01013c6 <pgdir_walk>
f010247a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010247d:	8b 0d 48 e9 11 f0    	mov    0xf011e948,%ecx
f0102483:	8b 51 04             	mov    0x4(%ecx),%edx
f0102486:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010248c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010248f:	c1 ea 0c             	shr    $0xc,%edx
f0102492:	83 c4 10             	add    $0x10,%esp
f0102495:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f010249b:	72 17                	jb     f01024b4 <mem_init+0xedf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010249d:	ff 75 c4             	pushl  -0x3c(%ebp)
f01024a0:	68 b4 45 10 f0       	push   $0xf01045b4
f01024a5:	68 45 03 00 00       	push   $0x345
f01024aa:	68 ac 4c 10 f0       	push   $0xf0104cac
f01024af:	e8 d7 db ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f01024b4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01024b7:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01024bd:	39 d0                	cmp    %edx,%eax
f01024bf:	74 19                	je     f01024da <mem_init+0xf05>
f01024c1:	68 fb 4e 10 f0       	push   $0xf0104efb
f01024c6:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01024cb:	68 46 03 00 00       	push   $0x346
f01024d0:	68 ac 4c 10 f0       	push   $0xf0104cac
f01024d5:	e8 b1 db ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f01024da:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01024e1:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024e7:	89 f0                	mov    %esi,%eax
f01024e9:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f01024ef:	c1 f8 03             	sar    $0x3,%eax
f01024f2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024f5:	89 c2                	mov    %eax,%edx
f01024f7:	c1 ea 0c             	shr    $0xc,%edx
f01024fa:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f0102500:	72 12                	jb     f0102514 <mem_init+0xf3f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102502:	50                   	push   %eax
f0102503:	68 b4 45 10 f0       	push   $0xf01045b4
f0102508:	6a 52                	push   $0x52
f010250a:	68 b8 4c 10 f0       	push   $0xf0104cb8
f010250f:	e8 77 db ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102514:	83 ec 04             	sub    $0x4,%esp
f0102517:	68 00 10 00 00       	push   $0x1000
f010251c:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102521:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102526:	50                   	push   %eax
f0102527:	e8 59 12 00 00       	call   f0103785 <memset>
	page_free(pp0);
f010252c:	89 34 24             	mov    %esi,(%esp)
f010252f:	e8 54 ee ff ff       	call   f0101388 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102534:	83 c4 0c             	add    $0xc,%esp
f0102537:	6a 01                	push   $0x1
f0102539:	6a 00                	push   $0x0
f010253b:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102541:	e8 80 ee ff ff       	call   f01013c6 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102546:	89 f2                	mov    %esi,%edx
f0102548:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f010254e:	c1 fa 03             	sar    $0x3,%edx
f0102551:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102554:	89 d0                	mov    %edx,%eax
f0102556:	c1 e8 0c             	shr    $0xc,%eax
f0102559:	83 c4 10             	add    $0x10,%esp
f010255c:	3b 05 44 e9 11 f0    	cmp    0xf011e944,%eax
f0102562:	72 12                	jb     f0102576 <mem_init+0xfa1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102564:	52                   	push   %edx
f0102565:	68 b4 45 10 f0       	push   $0xf01045b4
f010256a:	6a 52                	push   $0x52
f010256c:	68 b8 4c 10 f0       	push   $0xf0104cb8
f0102571:	e8 15 db ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0102576:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010257c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010257f:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102586:	75 11                	jne    f0102599 <mem_init+0xfc4>
f0102588:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010258e:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102594:	f6 00 01             	testb  $0x1,(%eax)
f0102597:	74 19                	je     f01025b2 <mem_init+0xfdd>
f0102599:	68 13 4f 10 f0       	push   $0xf0104f13
f010259e:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01025a3:	68 50 03 00 00       	push   $0x350
f01025a8:	68 ac 4c 10 f0       	push   $0xf0104cac
f01025ad:	e8 d9 da ff ff       	call   f010008b <_panic>
f01025b2:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01025b5:	39 d0                	cmp    %edx,%eax
f01025b7:	75 db                	jne    f0102594 <mem_init+0xfbf>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025b9:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f01025be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025c4:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f01025ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025cd:	a3 2c e5 11 f0       	mov    %eax,0xf011e52c

	// free the pages we took
	page_free(pp0);
f01025d2:	83 ec 0c             	sub    $0xc,%esp
f01025d5:	56                   	push   %esi
f01025d6:	e8 ad ed ff ff       	call   f0101388 <page_free>
	page_free(pp1);
f01025db:	89 3c 24             	mov    %edi,(%esp)
f01025de:	e8 a5 ed ff ff       	call   f0101388 <page_free>
	page_free(pp2);
f01025e3:	89 1c 24             	mov    %ebx,(%esp)
f01025e6:	e8 9d ed ff ff       	call   f0101388 <page_free>

	cprintf("check_page() succeeded!\n");
f01025eb:	c7 04 24 2a 4f 10 f0 	movl   $0xf0104f2a,(%esp)
f01025f2:	e8 5e 06 00 00       	call   f0102c55 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01025f7:	a1 4c e9 11 f0       	mov    0xf011e94c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025fc:	83 c4 10             	add    $0x10,%esp
f01025ff:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102604:	77 15                	ja     f010261b <mem_init+0x1046>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102606:	50                   	push   %eax
f0102607:	68 f8 43 10 f0       	push   $0xf01043f8
f010260c:	68 b1 00 00 00       	push   $0xb1
f0102611:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102616:	e8 70 da ff ff       	call   f010008b <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f010261b:	8b 15 44 e9 11 f0    	mov    0xf011e944,%edx
f0102621:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102628:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f010262b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f0102631:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102633:	05 00 00 00 10       	add    $0x10000000,%eax
f0102638:	50                   	push   %eax
f0102639:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010263e:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102643:	e8 15 ee ff ff       	call   f010145d <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102648:	83 c4 10             	add    $0x10,%esp
f010264b:	ba 00 40 11 f0       	mov    $0xf0114000,%edx
f0102650:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102656:	77 15                	ja     f010266d <mem_init+0x1098>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102658:	52                   	push   %edx
f0102659:	68 f8 43 10 f0       	push   $0xf01043f8
f010265e:	68 c2 00 00 00       	push   $0xc2
f0102663:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102668:	e8 1e da ff ff       	call   f010008b <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f010266d:	83 ec 08             	sub    $0x8,%esp
f0102670:	6a 02                	push   $0x2
f0102672:	68 00 40 11 00       	push   $0x114000
f0102677:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010267c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102681:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102686:	e8 d2 ed ff ff       	call   f010145d <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f010268b:	83 c4 08             	add    $0x8,%esp
f010268e:	6a 02                	push   $0x2
f0102690:	6a 00                	push   $0x0
f0102692:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102697:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010269c:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f01026a1:	e8 b7 ed ff ff       	call   f010145d <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026a6:	8b 1d 48 e9 11 f0    	mov    0xf011e948,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026ac:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f01026b1:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f01026b8:	83 c4 10             	add    $0x10,%esp
f01026bb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01026c1:	74 63                	je     f0102726 <mem_init+0x1151>
f01026c3:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026c8:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01026ce:	89 d8                	mov    %ebx,%eax
f01026d0:	e8 3a e8 ff ff       	call   f0100f0f <check_va2pa>
f01026d5:	8b 15 4c e9 11 f0    	mov    0xf011e94c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026db:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01026e1:	77 15                	ja     f01026f8 <mem_init+0x1123>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026e3:	52                   	push   %edx
f01026e4:	68 f8 43 10 f0       	push   $0xf01043f8
f01026e9:	68 97 02 00 00       	push   $0x297
f01026ee:	68 ac 4c 10 f0       	push   $0xf0104cac
f01026f3:	e8 93 d9 ff ff       	call   f010008b <_panic>
f01026f8:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01026ff:	39 d0                	cmp    %edx,%eax
f0102701:	74 19                	je     f010271c <mem_init+0x1147>
f0102703:	68 18 4b 10 f0       	push   $0xf0104b18
f0102708:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010270d:	68 97 02 00 00       	push   $0x297
f0102712:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102717:	e8 6f d9 ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010271c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102722:	39 f7                	cmp    %esi,%edi
f0102724:	77 a2                	ja     f01026c8 <mem_init+0x10f3>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102726:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f010272b:	c1 e0 0c             	shl    $0xc,%eax
f010272e:	74 41                	je     f0102771 <mem_init+0x119c>
f0102730:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102735:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f010273b:	89 d8                	mov    %ebx,%eax
f010273d:	e8 cd e7 ff ff       	call   f0100f0f <check_va2pa>
f0102742:	39 c6                	cmp    %eax,%esi
f0102744:	74 19                	je     f010275f <mem_init+0x118a>
f0102746:	68 4c 4b 10 f0       	push   $0xf0104b4c
f010274b:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102750:	68 9c 02 00 00       	push   $0x29c
f0102755:	68 ac 4c 10 f0       	push   $0xf0104cac
f010275a:	e8 2c d9 ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010275f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102765:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f010276a:	c1 e0 0c             	shl    $0xc,%eax
f010276d:	39 c6                	cmp    %eax,%esi
f010276f:	72 c4                	jb     f0102735 <mem_init+0x1160>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102771:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102776:	89 d8                	mov    %ebx,%eax
f0102778:	e8 92 e7 ff ff       	call   f0100f0f <check_va2pa>
f010277d:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102782:	bf 00 40 11 f0       	mov    $0xf0114000,%edi
f0102787:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010278d:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102790:	39 d0                	cmp    %edx,%eax
f0102792:	74 19                	je     f01027ad <mem_init+0x11d8>
f0102794:	68 74 4b 10 f0       	push   $0xf0104b74
f0102799:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010279e:	68 a0 02 00 00       	push   $0x2a0
f01027a3:	68 ac 4c 10 f0       	push   $0xf0104cac
f01027a8:	e8 de d8 ff ff       	call   f010008b <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01027ad:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01027b3:	0f 85 25 04 00 00    	jne    f0102bde <mem_init+0x1609>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01027b9:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01027be:	89 d8                	mov    %ebx,%eax
f01027c0:	e8 4a e7 ff ff       	call   f0100f0f <check_va2pa>
f01027c5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01027c8:	74 19                	je     f01027e3 <mem_init+0x120e>
f01027ca:	68 bc 4b 10 f0       	push   $0xf0104bbc
f01027cf:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01027d4:	68 a1 02 00 00       	push   $0x2a1
f01027d9:	68 ac 4c 10 f0       	push   $0xf0104cac
f01027de:	e8 a8 d8 ff ff       	call   f010008b <_panic>
f01027e3:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01027e8:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01027ed:	72 2d                	jb     f010281c <mem_init+0x1247>
f01027ef:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01027f4:	76 07                	jbe    f01027fd <mem_init+0x1228>
f01027f6:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01027fb:	75 1f                	jne    f010281c <mem_init+0x1247>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01027fd:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102801:	75 7e                	jne    f0102881 <mem_init+0x12ac>
f0102803:	68 43 4f 10 f0       	push   $0xf0104f43
f0102808:	68 d2 4c 10 f0       	push   $0xf0104cd2
f010280d:	68 a9 02 00 00       	push   $0x2a9
f0102812:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102817:	e8 6f d8 ff ff       	call   f010008b <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010281c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102821:	76 3f                	jbe    f0102862 <mem_init+0x128d>
				assert(pgdir[i] & PTE_P);
f0102823:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102826:	f6 c2 01             	test   $0x1,%dl
f0102829:	75 19                	jne    f0102844 <mem_init+0x126f>
f010282b:	68 43 4f 10 f0       	push   $0xf0104f43
f0102830:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102835:	68 ad 02 00 00       	push   $0x2ad
f010283a:	68 ac 4c 10 f0       	push   $0xf0104cac
f010283f:	e8 47 d8 ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f0102844:	f6 c2 02             	test   $0x2,%dl
f0102847:	75 38                	jne    f0102881 <mem_init+0x12ac>
f0102849:	68 54 4f 10 f0       	push   $0xf0104f54
f010284e:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102853:	68 ae 02 00 00       	push   $0x2ae
f0102858:	68 ac 4c 10 f0       	push   $0xf0104cac
f010285d:	e8 29 d8 ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f0102862:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102866:	74 19                	je     f0102881 <mem_init+0x12ac>
f0102868:	68 65 4f 10 f0       	push   $0xf0104f65
f010286d:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102872:	68 b0 02 00 00       	push   $0x2b0
f0102877:	68 ac 4c 10 f0       	push   $0xf0104cac
f010287c:	e8 0a d8 ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102881:	40                   	inc    %eax
f0102882:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102887:	0f 85 5b ff ff ff    	jne    f01027e8 <mem_init+0x1213>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010288d:	83 ec 0c             	sub    $0xc,%esp
f0102890:	68 ec 4b 10 f0       	push   $0xf0104bec
f0102895:	e8 bb 03 00 00       	call   f0102c55 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010289a:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010289f:	83 c4 10             	add    $0x10,%esp
f01028a2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028a7:	77 15                	ja     f01028be <mem_init+0x12e9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028a9:	50                   	push   %eax
f01028aa:	68 f8 43 10 f0       	push   $0xf01043f8
f01028af:	68 de 00 00 00       	push   $0xde
f01028b4:	68 ac 4c 10 f0       	push   $0xf0104cac
f01028b9:	e8 cd d7 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f01028be:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01028c3:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01028c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01028cb:	e8 c8 e6 ff ff       	call   f0100f98 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01028d0:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01028d3:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01028d8:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01028db:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01028de:	83 ec 0c             	sub    $0xc,%esp
f01028e1:	6a 00                	push   $0x0
f01028e3:	e8 16 ea ff ff       	call   f01012fe <page_alloc>
f01028e8:	89 c6                	mov    %eax,%esi
f01028ea:	83 c4 10             	add    $0x10,%esp
f01028ed:	85 c0                	test   %eax,%eax
f01028ef:	75 19                	jne    f010290a <mem_init+0x1335>
f01028f1:	68 82 4d 10 f0       	push   $0xf0104d82
f01028f6:	68 d2 4c 10 f0       	push   $0xf0104cd2
f01028fb:	68 6b 03 00 00       	push   $0x36b
f0102900:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102905:	e8 81 d7 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010290a:	83 ec 0c             	sub    $0xc,%esp
f010290d:	6a 00                	push   $0x0
f010290f:	e8 ea e9 ff ff       	call   f01012fe <page_alloc>
f0102914:	89 c7                	mov    %eax,%edi
f0102916:	83 c4 10             	add    $0x10,%esp
f0102919:	85 c0                	test   %eax,%eax
f010291b:	75 19                	jne    f0102936 <mem_init+0x1361>
f010291d:	68 98 4d 10 f0       	push   $0xf0104d98
f0102922:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102927:	68 6c 03 00 00       	push   $0x36c
f010292c:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102931:	e8 55 d7 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0102936:	83 ec 0c             	sub    $0xc,%esp
f0102939:	6a 00                	push   $0x0
f010293b:	e8 be e9 ff ff       	call   f01012fe <page_alloc>
f0102940:	89 c3                	mov    %eax,%ebx
f0102942:	83 c4 10             	add    $0x10,%esp
f0102945:	85 c0                	test   %eax,%eax
f0102947:	75 19                	jne    f0102962 <mem_init+0x138d>
f0102949:	68 ae 4d 10 f0       	push   $0xf0104dae
f010294e:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102953:	68 6d 03 00 00       	push   $0x36d
f0102958:	68 ac 4c 10 f0       	push   $0xf0104cac
f010295d:	e8 29 d7 ff ff       	call   f010008b <_panic>
	page_free(pp0);
f0102962:	83 ec 0c             	sub    $0xc,%esp
f0102965:	56                   	push   %esi
f0102966:	e8 1d ea ff ff       	call   f0101388 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010296b:	89 f8                	mov    %edi,%eax
f010296d:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f0102973:	c1 f8 03             	sar    $0x3,%eax
f0102976:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102979:	89 c2                	mov    %eax,%edx
f010297b:	c1 ea 0c             	shr    $0xc,%edx
f010297e:	83 c4 10             	add    $0x10,%esp
f0102981:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f0102987:	72 12                	jb     f010299b <mem_init+0x13c6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102989:	50                   	push   %eax
f010298a:	68 b4 45 10 f0       	push   $0xf01045b4
f010298f:	6a 52                	push   $0x52
f0102991:	68 b8 4c 10 f0       	push   $0xf0104cb8
f0102996:	e8 f0 d6 ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010299b:	83 ec 04             	sub    $0x4,%esp
f010299e:	68 00 10 00 00       	push   $0x1000
f01029a3:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01029a5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01029aa:	50                   	push   %eax
f01029ab:	e8 d5 0d 00 00       	call   f0103785 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029b0:	89 d8                	mov    %ebx,%eax
f01029b2:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f01029b8:	c1 f8 03             	sar    $0x3,%eax
f01029bb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029be:	89 c2                	mov    %eax,%edx
f01029c0:	c1 ea 0c             	shr    $0xc,%edx
f01029c3:	83 c4 10             	add    $0x10,%esp
f01029c6:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f01029cc:	72 12                	jb     f01029e0 <mem_init+0x140b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029ce:	50                   	push   %eax
f01029cf:	68 b4 45 10 f0       	push   $0xf01045b4
f01029d4:	6a 52                	push   $0x52
f01029d6:	68 b8 4c 10 f0       	push   $0xf0104cb8
f01029db:	e8 ab d6 ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01029e0:	83 ec 04             	sub    $0x4,%esp
f01029e3:	68 00 10 00 00       	push   $0x1000
f01029e8:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01029ea:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01029ef:	50                   	push   %eax
f01029f0:	e8 90 0d 00 00       	call   f0103785 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01029f5:	6a 02                	push   $0x2
f01029f7:	68 00 10 00 00       	push   $0x1000
f01029fc:	57                   	push   %edi
f01029fd:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102a03:	e8 64 eb ff ff       	call   f010156c <page_insert>
	assert(pp1->pp_ref == 1);
f0102a08:	83 c4 20             	add    $0x20,%esp
f0102a0b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102a10:	74 19                	je     f0102a2b <mem_init+0x1456>
f0102a12:	68 7f 4e 10 f0       	push   $0xf0104e7f
f0102a17:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102a1c:	68 72 03 00 00       	push   $0x372
f0102a21:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102a26:	e8 60 d6 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102a2b:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102a32:	01 01 01 
f0102a35:	74 19                	je     f0102a50 <mem_init+0x147b>
f0102a37:	68 0c 4c 10 f0       	push   $0xf0104c0c
f0102a3c:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102a41:	68 73 03 00 00       	push   $0x373
f0102a46:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102a4b:	e8 3b d6 ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102a50:	6a 02                	push   $0x2
f0102a52:	68 00 10 00 00       	push   $0x1000
f0102a57:	53                   	push   %ebx
f0102a58:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102a5e:	e8 09 eb ff ff       	call   f010156c <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102a63:	83 c4 10             	add    $0x10,%esp
f0102a66:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102a6d:	02 02 02 
f0102a70:	74 19                	je     f0102a8b <mem_init+0x14b6>
f0102a72:	68 30 4c 10 f0       	push   $0xf0104c30
f0102a77:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102a7c:	68 75 03 00 00       	push   $0x375
f0102a81:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102a86:	e8 00 d6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102a8b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102a90:	74 19                	je     f0102aab <mem_init+0x14d6>
f0102a92:	68 a1 4e 10 f0       	push   $0xf0104ea1
f0102a97:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102a9c:	68 76 03 00 00       	push   $0x376
f0102aa1:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102aa6:	e8 e0 d5 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102aab:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102ab0:	74 19                	je     f0102acb <mem_init+0x14f6>
f0102ab2:	68 ea 4e 10 f0       	push   $0xf0104eea
f0102ab7:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102abc:	68 77 03 00 00       	push   $0x377
f0102ac1:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102ac6:	e8 c0 d5 ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102acb:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102ad2:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ad5:	89 d8                	mov    %ebx,%eax
f0102ad7:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f0102add:	c1 f8 03             	sar    $0x3,%eax
f0102ae0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ae3:	89 c2                	mov    %eax,%edx
f0102ae5:	c1 ea 0c             	shr    $0xc,%edx
f0102ae8:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f0102aee:	72 12                	jb     f0102b02 <mem_init+0x152d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102af0:	50                   	push   %eax
f0102af1:	68 b4 45 10 f0       	push   $0xf01045b4
f0102af6:	6a 52                	push   $0x52
f0102af8:	68 b8 4c 10 f0       	push   $0xf0104cb8
f0102afd:	e8 89 d5 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102b02:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102b09:	03 03 03 
f0102b0c:	74 19                	je     f0102b27 <mem_init+0x1552>
f0102b0e:	68 54 4c 10 f0       	push   $0xf0104c54
f0102b13:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102b18:	68 79 03 00 00       	push   $0x379
f0102b1d:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102b22:	e8 64 d5 ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b27:	83 ec 08             	sub    $0x8,%esp
f0102b2a:	68 00 10 00 00       	push   $0x1000
f0102b2f:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102b35:	e8 e5 e9 ff ff       	call   f010151f <page_remove>
	assert(pp2->pp_ref == 0);
f0102b3a:	83 c4 10             	add    $0x10,%esp
f0102b3d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102b42:	74 19                	je     f0102b5d <mem_init+0x1588>
f0102b44:	68 d9 4e 10 f0       	push   $0xf0104ed9
f0102b49:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102b4e:	68 7b 03 00 00       	push   $0x37b
f0102b53:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102b58:	e8 2e d5 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b5d:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102b62:	8b 08                	mov    (%eax),%ecx
f0102b64:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b6a:	89 f2                	mov    %esi,%edx
f0102b6c:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0102b72:	c1 fa 03             	sar    $0x3,%edx
f0102b75:	c1 e2 0c             	shl    $0xc,%edx
f0102b78:	39 d1                	cmp    %edx,%ecx
f0102b7a:	74 19                	je     f0102b95 <mem_init+0x15c0>
f0102b7c:	68 d0 47 10 f0       	push   $0xf01047d0
f0102b81:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102b86:	68 7e 03 00 00       	push   $0x37e
f0102b8b:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102b90:	e8 f6 d4 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102b95:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b9b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ba0:	74 19                	je     f0102bbb <mem_init+0x15e6>
f0102ba2:	68 90 4e 10 f0       	push   $0xf0104e90
f0102ba7:	68 d2 4c 10 f0       	push   $0xf0104cd2
f0102bac:	68 80 03 00 00       	push   $0x380
f0102bb1:	68 ac 4c 10 f0       	push   $0xf0104cac
f0102bb6:	e8 d0 d4 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102bbb:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102bc1:	83 ec 0c             	sub    $0xc,%esp
f0102bc4:	56                   	push   %esi
f0102bc5:	e8 be e7 ff ff       	call   f0101388 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102bca:	c7 04 24 80 4c 10 f0 	movl   $0xf0104c80,(%esp)
f0102bd1:	e8 7f 00 00 00       	call   f0102c55 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102bd9:	5b                   	pop    %ebx
f0102bda:	5e                   	pop    %esi
f0102bdb:	5f                   	pop    %edi
f0102bdc:	c9                   	leave  
f0102bdd:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102bde:	89 f2                	mov    %esi,%edx
f0102be0:	89 d8                	mov    %ebx,%eax
f0102be2:	e8 28 e3 ff ff       	call   f0100f0f <check_va2pa>
f0102be7:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102bed:	e9 9b fb ff ff       	jmp    f010278d <mem_init+0x11b8>
	...

f0102bf4 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102bf4:	55                   	push   %ebp
f0102bf5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102bf7:	ba 70 00 00 00       	mov    $0x70,%edx
f0102bfc:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bff:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102c00:	b2 71                	mov    $0x71,%dl
f0102c02:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102c03:	0f b6 c0             	movzbl %al,%eax
}
f0102c06:	c9                   	leave  
f0102c07:	c3                   	ret    

f0102c08 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102c08:	55                   	push   %ebp
f0102c09:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102c0b:	ba 70 00 00 00       	mov    $0x70,%edx
f0102c10:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c13:	ee                   	out    %al,(%dx)
f0102c14:	b2 71                	mov    $0x71,%dl
f0102c16:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c19:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102c1a:	c9                   	leave  
f0102c1b:	c3                   	ret    

f0102c1c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102c1c:	55                   	push   %ebp
f0102c1d:	89 e5                	mov    %esp,%ebp
f0102c1f:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102c22:	ff 75 08             	pushl  0x8(%ebp)
f0102c25:	e8 7c d9 ff ff       	call   f01005a6 <cputchar>
f0102c2a:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0102c2d:	c9                   	leave  
f0102c2e:	c3                   	ret    

f0102c2f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102c2f:	55                   	push   %ebp
f0102c30:	89 e5                	mov    %esp,%ebp
f0102c32:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102c35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102c3c:	ff 75 0c             	pushl  0xc(%ebp)
f0102c3f:	ff 75 08             	pushl  0x8(%ebp)
f0102c42:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102c45:	50                   	push   %eax
f0102c46:	68 1c 2c 10 f0       	push   $0xf0102c1c
f0102c4b:	e8 9d 04 00 00       	call   f01030ed <vprintfmt>
	return cnt;
}
f0102c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102c53:	c9                   	leave  
f0102c54:	c3                   	ret    

f0102c55 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102c55:	55                   	push   %ebp
f0102c56:	89 e5                	mov    %esp,%ebp
f0102c58:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102c5b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102c5e:	50                   	push   %eax
f0102c5f:	ff 75 08             	pushl  0x8(%ebp)
f0102c62:	e8 c8 ff ff ff       	call   f0102c2f <vcprintf>
	va_end(ap);

	return cnt;
}
f0102c67:	c9                   	leave  
f0102c68:	c3                   	ret    
f0102c69:	00 00                	add    %al,(%eax)
	...

f0102c6c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102c6c:	55                   	push   %ebp
f0102c6d:	89 e5                	mov    %esp,%ebp
f0102c6f:	57                   	push   %edi
f0102c70:	56                   	push   %esi
f0102c71:	53                   	push   %ebx
f0102c72:	83 ec 14             	sub    $0x14,%esp
f0102c75:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102c78:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102c7b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102c7e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102c81:	8b 1a                	mov    (%edx),%ebx
f0102c83:	8b 01                	mov    (%ecx),%eax
f0102c85:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0102c88:	39 c3                	cmp    %eax,%ebx
f0102c8a:	0f 8f 97 00 00 00    	jg     f0102d27 <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0102c90:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102c97:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c9a:	01 d8                	add    %ebx,%eax
f0102c9c:	89 c7                	mov    %eax,%edi
f0102c9e:	c1 ef 1f             	shr    $0x1f,%edi
f0102ca1:	01 c7                	add    %eax,%edi
f0102ca3:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102ca5:	39 df                	cmp    %ebx,%edi
f0102ca7:	7c 31                	jl     f0102cda <stab_binsearch+0x6e>
f0102ca9:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0102cac:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102caf:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0102cb4:	39 f0                	cmp    %esi,%eax
f0102cb6:	0f 84 b3 00 00 00    	je     f0102d6f <stab_binsearch+0x103>
f0102cbc:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102cc0:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102cc4:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102cc6:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102cc7:	39 d8                	cmp    %ebx,%eax
f0102cc9:	7c 0f                	jl     f0102cda <stab_binsearch+0x6e>
f0102ccb:	0f b6 0a             	movzbl (%edx),%ecx
f0102cce:	83 ea 0c             	sub    $0xc,%edx
f0102cd1:	39 f1                	cmp    %esi,%ecx
f0102cd3:	75 f1                	jne    f0102cc6 <stab_binsearch+0x5a>
f0102cd5:	e9 97 00 00 00       	jmp    f0102d71 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102cda:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0102cdd:	eb 39                	jmp    f0102d18 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102cdf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102ce2:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0102ce4:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102ce7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102cee:	eb 28                	jmp    f0102d18 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102cf0:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102cf3:	76 12                	jbe    f0102d07 <stab_binsearch+0x9b>
			*region_right = m - 1;
f0102cf5:	48                   	dec    %eax
f0102cf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102cf9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102cfc:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102cfe:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102d05:	eb 11                	jmp    f0102d18 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102d07:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102d0a:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0102d0c:	ff 45 0c             	incl   0xc(%ebp)
f0102d0f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102d11:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102d18:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0102d1b:	0f 8d 76 ff ff ff    	jge    f0102c97 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102d21:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102d25:	75 0d                	jne    f0102d34 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0102d27:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102d2a:	8b 03                	mov    (%ebx),%eax
f0102d2c:	48                   	dec    %eax
f0102d2d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d30:	89 02                	mov    %eax,(%edx)
f0102d32:	eb 55                	jmp    f0102d89 <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102d34:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102d37:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102d39:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102d3c:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102d3e:	39 c1                	cmp    %eax,%ecx
f0102d40:	7d 26                	jge    f0102d68 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102d42:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102d45:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0102d48:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0102d4d:	39 f2                	cmp    %esi,%edx
f0102d4f:	74 17                	je     f0102d68 <stab_binsearch+0xfc>
f0102d51:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102d55:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102d59:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102d5a:	39 c1                	cmp    %eax,%ecx
f0102d5c:	7d 0a                	jge    f0102d68 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102d5e:	0f b6 1a             	movzbl (%edx),%ebx
f0102d61:	83 ea 0c             	sub    $0xc,%edx
f0102d64:	39 f3                	cmp    %esi,%ebx
f0102d66:	75 f1                	jne    f0102d59 <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102d68:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102d6b:	89 02                	mov    %eax,(%edx)
f0102d6d:	eb 1a                	jmp    f0102d89 <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102d6f:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102d71:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102d74:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0102d77:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102d7b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102d7e:	0f 82 5b ff ff ff    	jb     f0102cdf <stab_binsearch+0x73>
f0102d84:	e9 67 ff ff ff       	jmp    f0102cf0 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0102d89:	83 c4 14             	add    $0x14,%esp
f0102d8c:	5b                   	pop    %ebx
f0102d8d:	5e                   	pop    %esi
f0102d8e:	5f                   	pop    %edi
f0102d8f:	c9                   	leave  
f0102d90:	c3                   	ret    

f0102d91 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102d91:	55                   	push   %ebp
f0102d92:	89 e5                	mov    %esp,%ebp
f0102d94:	57                   	push   %edi
f0102d95:	56                   	push   %esi
f0102d96:	53                   	push   %ebx
f0102d97:	83 ec 2c             	sub    $0x2c,%esp
f0102d9a:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102da0:	c7 03 73 4f 10 f0    	movl   $0xf0104f73,(%ebx)
	info->eip_line = 0;
f0102da6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102dad:	c7 43 08 73 4f 10 f0 	movl   $0xf0104f73,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102db4:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102dbb:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102dbe:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102dc5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102dcb:	76 12                	jbe    f0102ddf <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102dcd:	b8 39 3e 11 f0       	mov    $0xf0113e39,%eax
f0102dd2:	3d 1d c5 10 f0       	cmp    $0xf010c51d,%eax
f0102dd7:	0f 86 90 01 00 00    	jbe    f0102f6d <debuginfo_eip+0x1dc>
f0102ddd:	eb 14                	jmp    f0102df3 <debuginfo_eip+0x62>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102ddf:	83 ec 04             	sub    $0x4,%esp
f0102de2:	68 7d 4f 10 f0       	push   $0xf0104f7d
f0102de7:	6a 7f                	push   $0x7f
f0102de9:	68 8a 4f 10 f0       	push   $0xf0104f8a
f0102dee:	e8 98 d2 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102df3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102df8:	80 3d 38 3e 11 f0 00 	cmpb   $0x0,0xf0113e38
f0102dff:	0f 85 74 01 00 00    	jne    f0102f79 <debuginfo_eip+0x1e8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102e05:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102e0c:	b8 1c c5 10 f0       	mov    $0xf010c51c,%eax
f0102e11:	2d a8 51 10 f0       	sub    $0xf01051a8,%eax
f0102e16:	c1 f8 02             	sar    $0x2,%eax
f0102e19:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102e1f:	48                   	dec    %eax
f0102e20:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102e23:	83 ec 08             	sub    $0x8,%esp
f0102e26:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102e29:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102e2c:	56                   	push   %esi
f0102e2d:	6a 64                	push   $0x64
f0102e2f:	b8 a8 51 10 f0       	mov    $0xf01051a8,%eax
f0102e34:	e8 33 fe ff ff       	call   f0102c6c <stab_binsearch>
	if (lfile == 0)
f0102e39:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102e3c:	83 c4 10             	add    $0x10,%esp
		return -1;
f0102e3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0102e44:	85 d2                	test   %edx,%edx
f0102e46:	0f 84 2d 01 00 00    	je     f0102f79 <debuginfo_eip+0x1e8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102e4c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0102e4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e52:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102e55:	83 ec 08             	sub    $0x8,%esp
f0102e58:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102e5b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102e5e:	56                   	push   %esi
f0102e5f:	6a 24                	push   $0x24
f0102e61:	b8 a8 51 10 f0       	mov    $0xf01051a8,%eax
f0102e66:	e8 01 fe ff ff       	call   f0102c6c <stab_binsearch>

	if (lfun <= rfun) {
f0102e6b:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0102e6e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e71:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e74:	83 c4 10             	add    $0x10,%esp
f0102e77:	39 c7                	cmp    %eax,%edi
f0102e79:	7f 32                	jg     f0102ead <debuginfo_eip+0x11c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102e7b:	89 f9                	mov    %edi,%ecx
f0102e7d:	6b c7 0c             	imul   $0xc,%edi,%eax
f0102e80:	8b 80 a8 51 10 f0    	mov    -0xfefae58(%eax),%eax
f0102e86:	ba 39 3e 11 f0       	mov    $0xf0113e39,%edx
f0102e8b:	81 ea 1d c5 10 f0    	sub    $0xf010c51d,%edx
f0102e91:	39 d0                	cmp    %edx,%eax
f0102e93:	73 08                	jae    f0102e9d <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102e95:	05 1d c5 10 f0       	add    $0xf010c51d,%eax
f0102e9a:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102e9d:	6b c9 0c             	imul   $0xc,%ecx,%ecx
f0102ea0:	8b 81 b0 51 10 f0    	mov    -0xfefae50(%ecx),%eax
f0102ea6:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102ea9:	29 c6                	sub    %eax,%esi
f0102eab:	eb 0c                	jmp    f0102eb9 <debuginfo_eip+0x128>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102ead:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102eb0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
f0102eb3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102eb6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102eb9:	83 ec 08             	sub    $0x8,%esp
f0102ebc:	6a 3a                	push   $0x3a
f0102ebe:	ff 73 08             	pushl  0x8(%ebx)
f0102ec1:	e8 9d 08 00 00       	call   f0103763 <strfind>
f0102ec6:	2b 43 08             	sub    0x8(%ebx),%eax
f0102ec9:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0102ecc:	89 7d dc             	mov    %edi,-0x24(%ebp)
    rfun = rline;
f0102ecf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ed2:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0102ed5:	83 c4 08             	add    $0x8,%esp
f0102ed8:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102edb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102ede:	56                   	push   %esi
f0102edf:	6a 44                	push   $0x44
f0102ee1:	b8 a8 51 10 f0       	mov    $0xf01051a8,%eax
f0102ee6:	e8 81 fd ff ff       	call   f0102c6c <stab_binsearch>
    if (lfun <= rfun) {
f0102eeb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102eee:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0102ef1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0102ef6:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0102ef9:	7f 7e                	jg     f0102f79 <debuginfo_eip+0x1e8>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0102efb:	6b c2 0c             	imul   $0xc,%edx,%eax
f0102efe:	05 a8 51 10 f0       	add    $0xf01051a8,%eax
f0102f03:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0102f07:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102f0a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0102f0d:	83 c0 08             	add    $0x8,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102f10:	eb 04                	jmp    f0102f16 <debuginfo_eip+0x185>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0102f12:	4a                   	dec    %edx
f0102f13:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102f16:	39 f2                	cmp    %esi,%edx
f0102f18:	7c 1b                	jl     f0102f35 <debuginfo_eip+0x1a4>
	       && stabs[lline].n_type != N_SOL
f0102f1a:	8a 48 fc             	mov    -0x4(%eax),%cl
f0102f1d:	80 f9 84             	cmp    $0x84,%cl
f0102f20:	74 5f                	je     f0102f81 <debuginfo_eip+0x1f0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102f22:	80 f9 64             	cmp    $0x64,%cl
f0102f25:	75 eb                	jne    f0102f12 <debuginfo_eip+0x181>
f0102f27:	83 38 00             	cmpl   $0x0,(%eax)
f0102f2a:	74 e6                	je     f0102f12 <debuginfo_eip+0x181>
f0102f2c:	eb 53                	jmp    f0102f81 <debuginfo_eip+0x1f0>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102f2e:	05 1d c5 10 f0       	add    $0xf010c51d,%eax
f0102f33:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102f35:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102f38:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102f3b:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102f40:	39 ca                	cmp    %ecx,%edx
f0102f42:	7d 35                	jge    f0102f79 <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
f0102f44:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0102f47:	6b d0 0c             	imul   $0xc,%eax,%edx
f0102f4a:	81 c2 ac 51 10 f0    	add    $0xf01051ac,%edx
f0102f50:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102f52:	eb 04                	jmp    f0102f58 <debuginfo_eip+0x1c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102f54:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0102f57:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102f58:	39 f0                	cmp    %esi,%eax
f0102f5a:	7d 18                	jge    f0102f74 <debuginfo_eip+0x1e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102f5c:	8a 0a                	mov    (%edx),%cl
f0102f5e:	83 c2 0c             	add    $0xc,%edx
f0102f61:	80 f9 a0             	cmp    $0xa0,%cl
f0102f64:	74 ee                	je     f0102f54 <debuginfo_eip+0x1c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102f66:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f6b:	eb 0c                	jmp    f0102f79 <debuginfo_eip+0x1e8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102f6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102f72:	eb 05                	jmp    f0102f79 <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102f74:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f79:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f7c:	5b                   	pop    %ebx
f0102f7d:	5e                   	pop    %esi
f0102f7e:	5f                   	pop    %edi
f0102f7f:	c9                   	leave  
f0102f80:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102f81:	6b d2 0c             	imul   $0xc,%edx,%edx
f0102f84:	8b 82 a8 51 10 f0    	mov    -0xfefae58(%edx),%eax
f0102f8a:	ba 39 3e 11 f0       	mov    $0xf0113e39,%edx
f0102f8f:	81 ea 1d c5 10 f0    	sub    $0xf010c51d,%edx
f0102f95:	39 d0                	cmp    %edx,%eax
f0102f97:	72 95                	jb     f0102f2e <debuginfo_eip+0x19d>
f0102f99:	eb 9a                	jmp    f0102f35 <debuginfo_eip+0x1a4>
	...

f0102f9c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102f9c:	55                   	push   %ebp
f0102f9d:	89 e5                	mov    %esp,%ebp
f0102f9f:	57                   	push   %edi
f0102fa0:	56                   	push   %esi
f0102fa1:	53                   	push   %ebx
f0102fa2:	83 ec 2c             	sub    $0x2c,%esp
f0102fa5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102fa8:	89 d6                	mov    %edx,%esi
f0102faa:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fad:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102fb0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102fb3:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102fb6:	8b 45 10             	mov    0x10(%ebp),%eax
f0102fb9:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102fbc:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102fbf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102fc2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102fc9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102fcc:	72 0c                	jb     f0102fda <printnum+0x3e>
f0102fce:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0102fd1:	76 07                	jbe    f0102fda <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102fd3:	4b                   	dec    %ebx
f0102fd4:	85 db                	test   %ebx,%ebx
f0102fd6:	7f 31                	jg     f0103009 <printnum+0x6d>
f0102fd8:	eb 3f                	jmp    f0103019 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102fda:	83 ec 0c             	sub    $0xc,%esp
f0102fdd:	57                   	push   %edi
f0102fde:	4b                   	dec    %ebx
f0102fdf:	53                   	push   %ebx
f0102fe0:	50                   	push   %eax
f0102fe1:	83 ec 08             	sub    $0x8,%esp
f0102fe4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102fe7:	ff 75 d0             	pushl  -0x30(%ebp)
f0102fea:	ff 75 dc             	pushl  -0x24(%ebp)
f0102fed:	ff 75 d8             	pushl  -0x28(%ebp)
f0102ff0:	e8 97 09 00 00       	call   f010398c <__udivdi3>
f0102ff5:	83 c4 18             	add    $0x18,%esp
f0102ff8:	52                   	push   %edx
f0102ff9:	50                   	push   %eax
f0102ffa:	89 f2                	mov    %esi,%edx
f0102ffc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102fff:	e8 98 ff ff ff       	call   f0102f9c <printnum>
f0103004:	83 c4 20             	add    $0x20,%esp
f0103007:	eb 10                	jmp    f0103019 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103009:	83 ec 08             	sub    $0x8,%esp
f010300c:	56                   	push   %esi
f010300d:	57                   	push   %edi
f010300e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103011:	4b                   	dec    %ebx
f0103012:	83 c4 10             	add    $0x10,%esp
f0103015:	85 db                	test   %ebx,%ebx
f0103017:	7f f0                	jg     f0103009 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103019:	83 ec 08             	sub    $0x8,%esp
f010301c:	56                   	push   %esi
f010301d:	83 ec 04             	sub    $0x4,%esp
f0103020:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103023:	ff 75 d0             	pushl  -0x30(%ebp)
f0103026:	ff 75 dc             	pushl  -0x24(%ebp)
f0103029:	ff 75 d8             	pushl  -0x28(%ebp)
f010302c:	e8 77 0a 00 00       	call   f0103aa8 <__umoddi3>
f0103031:	83 c4 14             	add    $0x14,%esp
f0103034:	0f be 80 98 4f 10 f0 	movsbl -0xfefb068(%eax),%eax
f010303b:	50                   	push   %eax
f010303c:	ff 55 e4             	call   *-0x1c(%ebp)
f010303f:	83 c4 10             	add    $0x10,%esp
}
f0103042:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103045:	5b                   	pop    %ebx
f0103046:	5e                   	pop    %esi
f0103047:	5f                   	pop    %edi
f0103048:	c9                   	leave  
f0103049:	c3                   	ret    

f010304a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010304a:	55                   	push   %ebp
f010304b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010304d:	83 fa 01             	cmp    $0x1,%edx
f0103050:	7e 0e                	jle    f0103060 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103052:	8b 10                	mov    (%eax),%edx
f0103054:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103057:	89 08                	mov    %ecx,(%eax)
f0103059:	8b 02                	mov    (%edx),%eax
f010305b:	8b 52 04             	mov    0x4(%edx),%edx
f010305e:	eb 22                	jmp    f0103082 <getuint+0x38>
	else if (lflag)
f0103060:	85 d2                	test   %edx,%edx
f0103062:	74 10                	je     f0103074 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103064:	8b 10                	mov    (%eax),%edx
f0103066:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103069:	89 08                	mov    %ecx,(%eax)
f010306b:	8b 02                	mov    (%edx),%eax
f010306d:	ba 00 00 00 00       	mov    $0x0,%edx
f0103072:	eb 0e                	jmp    f0103082 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103074:	8b 10                	mov    (%eax),%edx
f0103076:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103079:	89 08                	mov    %ecx,(%eax)
f010307b:	8b 02                	mov    (%edx),%eax
f010307d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103082:	c9                   	leave  
f0103083:	c3                   	ret    

f0103084 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103084:	55                   	push   %ebp
f0103085:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103087:	83 fa 01             	cmp    $0x1,%edx
f010308a:	7e 0e                	jle    f010309a <getint+0x16>
		return va_arg(*ap, long long);
f010308c:	8b 10                	mov    (%eax),%edx
f010308e:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103091:	89 08                	mov    %ecx,(%eax)
f0103093:	8b 02                	mov    (%edx),%eax
f0103095:	8b 52 04             	mov    0x4(%edx),%edx
f0103098:	eb 1a                	jmp    f01030b4 <getint+0x30>
	else if (lflag)
f010309a:	85 d2                	test   %edx,%edx
f010309c:	74 0c                	je     f01030aa <getint+0x26>
		return va_arg(*ap, long);
f010309e:	8b 10                	mov    (%eax),%edx
f01030a0:	8d 4a 04             	lea    0x4(%edx),%ecx
f01030a3:	89 08                	mov    %ecx,(%eax)
f01030a5:	8b 02                	mov    (%edx),%eax
f01030a7:	99                   	cltd   
f01030a8:	eb 0a                	jmp    f01030b4 <getint+0x30>
	else
		return va_arg(*ap, int);
f01030aa:	8b 10                	mov    (%eax),%edx
f01030ac:	8d 4a 04             	lea    0x4(%edx),%ecx
f01030af:	89 08                	mov    %ecx,(%eax)
f01030b1:	8b 02                	mov    (%edx),%eax
f01030b3:	99                   	cltd   
}
f01030b4:	c9                   	leave  
f01030b5:	c3                   	ret    

f01030b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01030b6:	55                   	push   %ebp
f01030b7:	89 e5                	mov    %esp,%ebp
f01030b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01030bc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01030bf:	8b 10                	mov    (%eax),%edx
f01030c1:	3b 50 04             	cmp    0x4(%eax),%edx
f01030c4:	73 08                	jae    f01030ce <sprintputch+0x18>
		*b->buf++ = ch;
f01030c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01030c9:	88 0a                	mov    %cl,(%edx)
f01030cb:	42                   	inc    %edx
f01030cc:	89 10                	mov    %edx,(%eax)
}
f01030ce:	c9                   	leave  
f01030cf:	c3                   	ret    

f01030d0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01030d0:	55                   	push   %ebp
f01030d1:	89 e5                	mov    %esp,%ebp
f01030d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01030d6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01030d9:	50                   	push   %eax
f01030da:	ff 75 10             	pushl  0x10(%ebp)
f01030dd:	ff 75 0c             	pushl  0xc(%ebp)
f01030e0:	ff 75 08             	pushl  0x8(%ebp)
f01030e3:	e8 05 00 00 00       	call   f01030ed <vprintfmt>
	va_end(ap);
f01030e8:	83 c4 10             	add    $0x10,%esp
}
f01030eb:	c9                   	leave  
f01030ec:	c3                   	ret    

f01030ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01030ed:	55                   	push   %ebp
f01030ee:	89 e5                	mov    %esp,%ebp
f01030f0:	57                   	push   %edi
f01030f1:	56                   	push   %esi
f01030f2:	53                   	push   %ebx
f01030f3:	83 ec 2c             	sub    $0x2c,%esp
f01030f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01030f9:	8b 75 10             	mov    0x10(%ebp),%esi
f01030fc:	eb 13                	jmp    f0103111 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01030fe:	85 c0                	test   %eax,%eax
f0103100:	0f 84 6d 03 00 00    	je     f0103473 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f0103106:	83 ec 08             	sub    $0x8,%esp
f0103109:	57                   	push   %edi
f010310a:	50                   	push   %eax
f010310b:	ff 55 08             	call   *0x8(%ebp)
f010310e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103111:	0f b6 06             	movzbl (%esi),%eax
f0103114:	46                   	inc    %esi
f0103115:	83 f8 25             	cmp    $0x25,%eax
f0103118:	75 e4                	jne    f01030fe <vprintfmt+0x11>
f010311a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f010311e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103125:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f010312c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103133:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103138:	eb 28                	jmp    f0103162 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010313a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010313c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0103140:	eb 20                	jmp    f0103162 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103142:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103144:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0103148:	eb 18                	jmp    f0103162 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010314a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f010314c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103153:	eb 0d                	jmp    f0103162 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103155:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103158:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010315b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103162:	8a 06                	mov    (%esi),%al
f0103164:	0f b6 d0             	movzbl %al,%edx
f0103167:	8d 5e 01             	lea    0x1(%esi),%ebx
f010316a:	83 e8 23             	sub    $0x23,%eax
f010316d:	3c 55                	cmp    $0x55,%al
f010316f:	0f 87 e0 02 00 00    	ja     f0103455 <vprintfmt+0x368>
f0103175:	0f b6 c0             	movzbl %al,%eax
f0103178:	ff 24 85 24 50 10 f0 	jmp    *-0xfefafdc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010317f:	83 ea 30             	sub    $0x30,%edx
f0103182:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0103185:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0103188:	8d 50 d0             	lea    -0x30(%eax),%edx
f010318b:	83 fa 09             	cmp    $0x9,%edx
f010318e:	77 44                	ja     f01031d4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103190:	89 de                	mov    %ebx,%esi
f0103192:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103195:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0103196:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103199:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f010319d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01031a0:	8d 58 d0             	lea    -0x30(%eax),%ebx
f01031a3:	83 fb 09             	cmp    $0x9,%ebx
f01031a6:	76 ed                	jbe    f0103195 <vprintfmt+0xa8>
f01031a8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01031ab:	eb 29                	jmp    f01031d6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01031ad:	8b 45 14             	mov    0x14(%ebp),%eax
f01031b0:	8d 50 04             	lea    0x4(%eax),%edx
f01031b3:	89 55 14             	mov    %edx,0x14(%ebp)
f01031b6:	8b 00                	mov    (%eax),%eax
f01031b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031bb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01031bd:	eb 17                	jmp    f01031d6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f01031bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01031c3:	78 85                	js     f010314a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031c5:	89 de                	mov    %ebx,%esi
f01031c7:	eb 99                	jmp    f0103162 <vprintfmt+0x75>
f01031c9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01031cb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f01031d2:	eb 8e                	jmp    f0103162 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031d4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01031d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01031da:	79 86                	jns    f0103162 <vprintfmt+0x75>
f01031dc:	e9 74 ff ff ff       	jmp    f0103155 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01031e1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031e2:	89 de                	mov    %ebx,%esi
f01031e4:	e9 79 ff ff ff       	jmp    f0103162 <vprintfmt+0x75>
f01031e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01031ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01031ef:	8d 50 04             	lea    0x4(%eax),%edx
f01031f2:	89 55 14             	mov    %edx,0x14(%ebp)
f01031f5:	83 ec 08             	sub    $0x8,%esp
f01031f8:	57                   	push   %edi
f01031f9:	ff 30                	pushl  (%eax)
f01031fb:	ff 55 08             	call   *0x8(%ebp)
			break;
f01031fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103201:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103204:	e9 08 ff ff ff       	jmp    f0103111 <vprintfmt+0x24>
f0103209:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f010320c:	8b 45 14             	mov    0x14(%ebp),%eax
f010320f:	8d 50 04             	lea    0x4(%eax),%edx
f0103212:	89 55 14             	mov    %edx,0x14(%ebp)
f0103215:	8b 00                	mov    (%eax),%eax
f0103217:	85 c0                	test   %eax,%eax
f0103219:	79 02                	jns    f010321d <vprintfmt+0x130>
f010321b:	f7 d8                	neg    %eax
f010321d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010321f:	83 f8 06             	cmp    $0x6,%eax
f0103222:	7f 0b                	jg     f010322f <vprintfmt+0x142>
f0103224:	8b 04 85 7c 51 10 f0 	mov    -0xfefae84(,%eax,4),%eax
f010322b:	85 c0                	test   %eax,%eax
f010322d:	75 1a                	jne    f0103249 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f010322f:	52                   	push   %edx
f0103230:	68 b0 4f 10 f0       	push   $0xf0104fb0
f0103235:	57                   	push   %edi
f0103236:	ff 75 08             	pushl  0x8(%ebp)
f0103239:	e8 92 fe ff ff       	call   f01030d0 <printfmt>
f010323e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103241:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103244:	e9 c8 fe ff ff       	jmp    f0103111 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f0103249:	50                   	push   %eax
f010324a:	68 e4 4c 10 f0       	push   $0xf0104ce4
f010324f:	57                   	push   %edi
f0103250:	ff 75 08             	pushl  0x8(%ebp)
f0103253:	e8 78 fe ff ff       	call   f01030d0 <printfmt>
f0103258:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010325b:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010325e:	e9 ae fe ff ff       	jmp    f0103111 <vprintfmt+0x24>
f0103263:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0103266:	89 de                	mov    %ebx,%esi
f0103268:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010326b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010326e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103271:	8d 50 04             	lea    0x4(%eax),%edx
f0103274:	89 55 14             	mov    %edx,0x14(%ebp)
f0103277:	8b 00                	mov    (%eax),%eax
f0103279:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010327c:	85 c0                	test   %eax,%eax
f010327e:	75 07                	jne    f0103287 <vprintfmt+0x19a>
				p = "(null)";
f0103280:	c7 45 d0 a9 4f 10 f0 	movl   $0xf0104fa9,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0103287:	85 db                	test   %ebx,%ebx
f0103289:	7e 42                	jle    f01032cd <vprintfmt+0x1e0>
f010328b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f010328f:	74 3c                	je     f01032cd <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103291:	83 ec 08             	sub    $0x8,%esp
f0103294:	51                   	push   %ecx
f0103295:	ff 75 d0             	pushl  -0x30(%ebp)
f0103298:	e8 3f 03 00 00       	call   f01035dc <strnlen>
f010329d:	29 c3                	sub    %eax,%ebx
f010329f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01032a2:	83 c4 10             	add    $0x10,%esp
f01032a5:	85 db                	test   %ebx,%ebx
f01032a7:	7e 24                	jle    f01032cd <vprintfmt+0x1e0>
					putch(padc, putdat);
f01032a9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f01032ad:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01032b0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01032b3:	83 ec 08             	sub    $0x8,%esp
f01032b6:	57                   	push   %edi
f01032b7:	53                   	push   %ebx
f01032b8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01032bb:	4e                   	dec    %esi
f01032bc:	83 c4 10             	add    $0x10,%esp
f01032bf:	85 f6                	test   %esi,%esi
f01032c1:	7f f0                	jg     f01032b3 <vprintfmt+0x1c6>
f01032c3:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01032c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01032cd:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01032d0:	0f be 02             	movsbl (%edx),%eax
f01032d3:	85 c0                	test   %eax,%eax
f01032d5:	75 47                	jne    f010331e <vprintfmt+0x231>
f01032d7:	eb 37                	jmp    f0103310 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f01032d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01032dd:	74 16                	je     f01032f5 <vprintfmt+0x208>
f01032df:	8d 50 e0             	lea    -0x20(%eax),%edx
f01032e2:	83 fa 5e             	cmp    $0x5e,%edx
f01032e5:	76 0e                	jbe    f01032f5 <vprintfmt+0x208>
					putch('?', putdat);
f01032e7:	83 ec 08             	sub    $0x8,%esp
f01032ea:	57                   	push   %edi
f01032eb:	6a 3f                	push   $0x3f
f01032ed:	ff 55 08             	call   *0x8(%ebp)
f01032f0:	83 c4 10             	add    $0x10,%esp
f01032f3:	eb 0b                	jmp    f0103300 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f01032f5:	83 ec 08             	sub    $0x8,%esp
f01032f8:	57                   	push   %edi
f01032f9:	50                   	push   %eax
f01032fa:	ff 55 08             	call   *0x8(%ebp)
f01032fd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103300:	ff 4d e4             	decl   -0x1c(%ebp)
f0103303:	0f be 03             	movsbl (%ebx),%eax
f0103306:	85 c0                	test   %eax,%eax
f0103308:	74 03                	je     f010330d <vprintfmt+0x220>
f010330a:	43                   	inc    %ebx
f010330b:	eb 1b                	jmp    f0103328 <vprintfmt+0x23b>
f010330d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103310:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103314:	7f 1e                	jg     f0103334 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103316:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103319:	e9 f3 fd ff ff       	jmp    f0103111 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010331e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103321:	43                   	inc    %ebx
f0103322:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103325:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103328:	85 f6                	test   %esi,%esi
f010332a:	78 ad                	js     f01032d9 <vprintfmt+0x1ec>
f010332c:	4e                   	dec    %esi
f010332d:	79 aa                	jns    f01032d9 <vprintfmt+0x1ec>
f010332f:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103332:	eb dc                	jmp    f0103310 <vprintfmt+0x223>
f0103334:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103337:	83 ec 08             	sub    $0x8,%esp
f010333a:	57                   	push   %edi
f010333b:	6a 20                	push   $0x20
f010333d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103340:	4b                   	dec    %ebx
f0103341:	83 c4 10             	add    $0x10,%esp
f0103344:	85 db                	test   %ebx,%ebx
f0103346:	7f ef                	jg     f0103337 <vprintfmt+0x24a>
f0103348:	e9 c4 fd ff ff       	jmp    f0103111 <vprintfmt+0x24>
f010334d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103350:	89 ca                	mov    %ecx,%edx
f0103352:	8d 45 14             	lea    0x14(%ebp),%eax
f0103355:	e8 2a fd ff ff       	call   f0103084 <getint>
f010335a:	89 c3                	mov    %eax,%ebx
f010335c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f010335e:	85 d2                	test   %edx,%edx
f0103360:	78 0a                	js     f010336c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103362:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103367:	e9 b0 00 00 00       	jmp    f010341c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f010336c:	83 ec 08             	sub    $0x8,%esp
f010336f:	57                   	push   %edi
f0103370:	6a 2d                	push   $0x2d
f0103372:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103375:	f7 db                	neg    %ebx
f0103377:	83 d6 00             	adc    $0x0,%esi
f010337a:	f7 de                	neg    %esi
f010337c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010337f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103384:	e9 93 00 00 00       	jmp    f010341c <vprintfmt+0x32f>
f0103389:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010338c:	89 ca                	mov    %ecx,%edx
f010338e:	8d 45 14             	lea    0x14(%ebp),%eax
f0103391:	e8 b4 fc ff ff       	call   f010304a <getuint>
f0103396:	89 c3                	mov    %eax,%ebx
f0103398:	89 d6                	mov    %edx,%esi
			base = 10;
f010339a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010339f:	eb 7b                	jmp    f010341c <vprintfmt+0x32f>
f01033a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f01033a4:	89 ca                	mov    %ecx,%edx
f01033a6:	8d 45 14             	lea    0x14(%ebp),%eax
f01033a9:	e8 d6 fc ff ff       	call   f0103084 <getint>
f01033ae:	89 c3                	mov    %eax,%ebx
f01033b0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f01033b2:	85 d2                	test   %edx,%edx
f01033b4:	78 07                	js     f01033bd <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f01033b6:	b8 08 00 00 00       	mov    $0x8,%eax
f01033bb:	eb 5f                	jmp    f010341c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f01033bd:	83 ec 08             	sub    $0x8,%esp
f01033c0:	57                   	push   %edi
f01033c1:	6a 2d                	push   $0x2d
f01033c3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f01033c6:	f7 db                	neg    %ebx
f01033c8:	83 d6 00             	adc    $0x0,%esi
f01033cb:	f7 de                	neg    %esi
f01033cd:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f01033d0:	b8 08 00 00 00       	mov    $0x8,%eax
f01033d5:	eb 45                	jmp    f010341c <vprintfmt+0x32f>
f01033d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f01033da:	83 ec 08             	sub    $0x8,%esp
f01033dd:	57                   	push   %edi
f01033de:	6a 30                	push   $0x30
f01033e0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01033e3:	83 c4 08             	add    $0x8,%esp
f01033e6:	57                   	push   %edi
f01033e7:	6a 78                	push   $0x78
f01033e9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01033ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01033ef:	8d 50 04             	lea    0x4(%eax),%edx
f01033f2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01033f5:	8b 18                	mov    (%eax),%ebx
f01033f7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01033fc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01033ff:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103404:	eb 16                	jmp    f010341c <vprintfmt+0x32f>
f0103406:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103409:	89 ca                	mov    %ecx,%edx
f010340b:	8d 45 14             	lea    0x14(%ebp),%eax
f010340e:	e8 37 fc ff ff       	call   f010304a <getuint>
f0103413:	89 c3                	mov    %eax,%ebx
f0103415:	89 d6                	mov    %edx,%esi
			base = 16;
f0103417:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f010341c:	83 ec 0c             	sub    $0xc,%esp
f010341f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0103423:	52                   	push   %edx
f0103424:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103427:	50                   	push   %eax
f0103428:	56                   	push   %esi
f0103429:	53                   	push   %ebx
f010342a:	89 fa                	mov    %edi,%edx
f010342c:	8b 45 08             	mov    0x8(%ebp),%eax
f010342f:	e8 68 fb ff ff       	call   f0102f9c <printnum>
			break;
f0103434:	83 c4 20             	add    $0x20,%esp
f0103437:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010343a:	e9 d2 fc ff ff       	jmp    f0103111 <vprintfmt+0x24>
f010343f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103442:	83 ec 08             	sub    $0x8,%esp
f0103445:	57                   	push   %edi
f0103446:	52                   	push   %edx
f0103447:	ff 55 08             	call   *0x8(%ebp)
			break;
f010344a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010344d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103450:	e9 bc fc ff ff       	jmp    f0103111 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103455:	83 ec 08             	sub    $0x8,%esp
f0103458:	57                   	push   %edi
f0103459:	6a 25                	push   $0x25
f010345b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010345e:	83 c4 10             	add    $0x10,%esp
f0103461:	eb 02                	jmp    f0103465 <vprintfmt+0x378>
f0103463:	89 c6                	mov    %eax,%esi
f0103465:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103468:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010346c:	75 f5                	jne    f0103463 <vprintfmt+0x376>
f010346e:	e9 9e fc ff ff       	jmp    f0103111 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0103473:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103476:	5b                   	pop    %ebx
f0103477:	5e                   	pop    %esi
f0103478:	5f                   	pop    %edi
f0103479:	c9                   	leave  
f010347a:	c3                   	ret    

f010347b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010347b:	55                   	push   %ebp
f010347c:	89 e5                	mov    %esp,%ebp
f010347e:	83 ec 18             	sub    $0x18,%esp
f0103481:	8b 45 08             	mov    0x8(%ebp),%eax
f0103484:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103487:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010348a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010348e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103491:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103498:	85 c0                	test   %eax,%eax
f010349a:	74 26                	je     f01034c2 <vsnprintf+0x47>
f010349c:	85 d2                	test   %edx,%edx
f010349e:	7e 29                	jle    f01034c9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01034a0:	ff 75 14             	pushl  0x14(%ebp)
f01034a3:	ff 75 10             	pushl  0x10(%ebp)
f01034a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01034a9:	50                   	push   %eax
f01034aa:	68 b6 30 10 f0       	push   $0xf01030b6
f01034af:	e8 39 fc ff ff       	call   f01030ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01034b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01034b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01034ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01034bd:	83 c4 10             	add    $0x10,%esp
f01034c0:	eb 0c                	jmp    f01034ce <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01034c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01034c7:	eb 05                	jmp    f01034ce <vsnprintf+0x53>
f01034c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01034ce:	c9                   	leave  
f01034cf:	c3                   	ret    

f01034d0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01034d0:	55                   	push   %ebp
f01034d1:	89 e5                	mov    %esp,%ebp
f01034d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01034d6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01034d9:	50                   	push   %eax
f01034da:	ff 75 10             	pushl  0x10(%ebp)
f01034dd:	ff 75 0c             	pushl  0xc(%ebp)
f01034e0:	ff 75 08             	pushl  0x8(%ebp)
f01034e3:	e8 93 ff ff ff       	call   f010347b <vsnprintf>
	va_end(ap);

	return rc;
}
f01034e8:	c9                   	leave  
f01034e9:	c3                   	ret    
	...

f01034ec <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01034ec:	55                   	push   %ebp
f01034ed:	89 e5                	mov    %esp,%ebp
f01034ef:	57                   	push   %edi
f01034f0:	56                   	push   %esi
f01034f1:	53                   	push   %ebx
f01034f2:	83 ec 0c             	sub    $0xc,%esp
f01034f5:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01034f8:	85 c0                	test   %eax,%eax
f01034fa:	74 11                	je     f010350d <readline+0x21>
		cprintf("%s", prompt);
f01034fc:	83 ec 08             	sub    $0x8,%esp
f01034ff:	50                   	push   %eax
f0103500:	68 e4 4c 10 f0       	push   $0xf0104ce4
f0103505:	e8 4b f7 ff ff       	call   f0102c55 <cprintf>
f010350a:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010350d:	83 ec 0c             	sub    $0xc,%esp
f0103510:	6a 00                	push   $0x0
f0103512:	e8 b0 d0 ff ff       	call   f01005c7 <iscons>
f0103517:	89 c7                	mov    %eax,%edi
f0103519:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010351c:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103521:	e8 90 d0 ff ff       	call   f01005b6 <getchar>
f0103526:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103528:	85 c0                	test   %eax,%eax
f010352a:	79 18                	jns    f0103544 <readline+0x58>
			cprintf("read error: %e\n", c);
f010352c:	83 ec 08             	sub    $0x8,%esp
f010352f:	50                   	push   %eax
f0103530:	68 98 51 10 f0       	push   $0xf0105198
f0103535:	e8 1b f7 ff ff       	call   f0102c55 <cprintf>
			return NULL;
f010353a:	83 c4 10             	add    $0x10,%esp
f010353d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103542:	eb 6f                	jmp    f01035b3 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103544:	83 f8 08             	cmp    $0x8,%eax
f0103547:	74 05                	je     f010354e <readline+0x62>
f0103549:	83 f8 7f             	cmp    $0x7f,%eax
f010354c:	75 18                	jne    f0103566 <readline+0x7a>
f010354e:	85 f6                	test   %esi,%esi
f0103550:	7e 14                	jle    f0103566 <readline+0x7a>
			if (echoing)
f0103552:	85 ff                	test   %edi,%edi
f0103554:	74 0d                	je     f0103563 <readline+0x77>
				cputchar('\b');
f0103556:	83 ec 0c             	sub    $0xc,%esp
f0103559:	6a 08                	push   $0x8
f010355b:	e8 46 d0 ff ff       	call   f01005a6 <cputchar>
f0103560:	83 c4 10             	add    $0x10,%esp
			i--;
f0103563:	4e                   	dec    %esi
f0103564:	eb bb                	jmp    f0103521 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103566:	83 fb 1f             	cmp    $0x1f,%ebx
f0103569:	7e 21                	jle    f010358c <readline+0xa0>
f010356b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103571:	7f 19                	jg     f010358c <readline+0xa0>
			if (echoing)
f0103573:	85 ff                	test   %edi,%edi
f0103575:	74 0c                	je     f0103583 <readline+0x97>
				cputchar(c);
f0103577:	83 ec 0c             	sub    $0xc,%esp
f010357a:	53                   	push   %ebx
f010357b:	e8 26 d0 ff ff       	call   f01005a6 <cputchar>
f0103580:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103583:	88 9e 40 e5 11 f0    	mov    %bl,-0xfee1ac0(%esi)
f0103589:	46                   	inc    %esi
f010358a:	eb 95                	jmp    f0103521 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010358c:	83 fb 0a             	cmp    $0xa,%ebx
f010358f:	74 05                	je     f0103596 <readline+0xaa>
f0103591:	83 fb 0d             	cmp    $0xd,%ebx
f0103594:	75 8b                	jne    f0103521 <readline+0x35>
			if (echoing)
f0103596:	85 ff                	test   %edi,%edi
f0103598:	74 0d                	je     f01035a7 <readline+0xbb>
				cputchar('\n');
f010359a:	83 ec 0c             	sub    $0xc,%esp
f010359d:	6a 0a                	push   $0xa
f010359f:	e8 02 d0 ff ff       	call   f01005a6 <cputchar>
f01035a4:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01035a7:	c6 86 40 e5 11 f0 00 	movb   $0x0,-0xfee1ac0(%esi)
			return buf;
f01035ae:	b8 40 e5 11 f0       	mov    $0xf011e540,%eax
		}
	}
}
f01035b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035b6:	5b                   	pop    %ebx
f01035b7:	5e                   	pop    %esi
f01035b8:	5f                   	pop    %edi
f01035b9:	c9                   	leave  
f01035ba:	c3                   	ret    
	...

f01035bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01035bc:	55                   	push   %ebp
f01035bd:	89 e5                	mov    %esp,%ebp
f01035bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01035c2:	80 3a 00             	cmpb   $0x0,(%edx)
f01035c5:	74 0e                	je     f01035d5 <strlen+0x19>
f01035c7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01035cc:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01035cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01035d1:	75 f9                	jne    f01035cc <strlen+0x10>
f01035d3:	eb 05                	jmp    f01035da <strlen+0x1e>
f01035d5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01035da:	c9                   	leave  
f01035db:	c3                   	ret    

f01035dc <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01035dc:	55                   	push   %ebp
f01035dd:	89 e5                	mov    %esp,%ebp
f01035df:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01035e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01035e5:	85 d2                	test   %edx,%edx
f01035e7:	74 17                	je     f0103600 <strnlen+0x24>
f01035e9:	80 39 00             	cmpb   $0x0,(%ecx)
f01035ec:	74 19                	je     f0103607 <strnlen+0x2b>
f01035ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01035f3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01035f4:	39 d0                	cmp    %edx,%eax
f01035f6:	74 14                	je     f010360c <strnlen+0x30>
f01035f8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01035fc:	75 f5                	jne    f01035f3 <strnlen+0x17>
f01035fe:	eb 0c                	jmp    f010360c <strnlen+0x30>
f0103600:	b8 00 00 00 00       	mov    $0x0,%eax
f0103605:	eb 05                	jmp    f010360c <strnlen+0x30>
f0103607:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010360c:	c9                   	leave  
f010360d:	c3                   	ret    

f010360e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010360e:	55                   	push   %ebp
f010360f:	89 e5                	mov    %esp,%ebp
f0103611:	53                   	push   %ebx
f0103612:	8b 45 08             	mov    0x8(%ebp),%eax
f0103615:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103618:	ba 00 00 00 00       	mov    $0x0,%edx
f010361d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0103620:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103623:	42                   	inc    %edx
f0103624:	84 c9                	test   %cl,%cl
f0103626:	75 f5                	jne    f010361d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103628:	5b                   	pop    %ebx
f0103629:	c9                   	leave  
f010362a:	c3                   	ret    

f010362b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010362b:	55                   	push   %ebp
f010362c:	89 e5                	mov    %esp,%ebp
f010362e:	53                   	push   %ebx
f010362f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103632:	53                   	push   %ebx
f0103633:	e8 84 ff ff ff       	call   f01035bc <strlen>
f0103638:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010363b:	ff 75 0c             	pushl  0xc(%ebp)
f010363e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0103641:	50                   	push   %eax
f0103642:	e8 c7 ff ff ff       	call   f010360e <strcpy>
	return dst;
}
f0103647:	89 d8                	mov    %ebx,%eax
f0103649:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010364c:	c9                   	leave  
f010364d:	c3                   	ret    

f010364e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010364e:	55                   	push   %ebp
f010364f:	89 e5                	mov    %esp,%ebp
f0103651:	56                   	push   %esi
f0103652:	53                   	push   %ebx
f0103653:	8b 45 08             	mov    0x8(%ebp),%eax
f0103656:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103659:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010365c:	85 f6                	test   %esi,%esi
f010365e:	74 15                	je     f0103675 <strncpy+0x27>
f0103660:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103665:	8a 1a                	mov    (%edx),%bl
f0103667:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010366a:	80 3a 01             	cmpb   $0x1,(%edx)
f010366d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103670:	41                   	inc    %ecx
f0103671:	39 ce                	cmp    %ecx,%esi
f0103673:	77 f0                	ja     f0103665 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103675:	5b                   	pop    %ebx
f0103676:	5e                   	pop    %esi
f0103677:	c9                   	leave  
f0103678:	c3                   	ret    

f0103679 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103679:	55                   	push   %ebp
f010367a:	89 e5                	mov    %esp,%ebp
f010367c:	57                   	push   %edi
f010367d:	56                   	push   %esi
f010367e:	53                   	push   %ebx
f010367f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103682:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103685:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103688:	85 f6                	test   %esi,%esi
f010368a:	74 32                	je     f01036be <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f010368c:	83 fe 01             	cmp    $0x1,%esi
f010368f:	74 22                	je     f01036b3 <strlcpy+0x3a>
f0103691:	8a 0b                	mov    (%ebx),%cl
f0103693:	84 c9                	test   %cl,%cl
f0103695:	74 20                	je     f01036b7 <strlcpy+0x3e>
f0103697:	89 f8                	mov    %edi,%eax
f0103699:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010369e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01036a1:	88 08                	mov    %cl,(%eax)
f01036a3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01036a4:	39 f2                	cmp    %esi,%edx
f01036a6:	74 11                	je     f01036b9 <strlcpy+0x40>
f01036a8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f01036ac:	42                   	inc    %edx
f01036ad:	84 c9                	test   %cl,%cl
f01036af:	75 f0                	jne    f01036a1 <strlcpy+0x28>
f01036b1:	eb 06                	jmp    f01036b9 <strlcpy+0x40>
f01036b3:	89 f8                	mov    %edi,%eax
f01036b5:	eb 02                	jmp    f01036b9 <strlcpy+0x40>
f01036b7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01036b9:	c6 00 00             	movb   $0x0,(%eax)
f01036bc:	eb 02                	jmp    f01036c0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01036be:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f01036c0:	29 f8                	sub    %edi,%eax
}
f01036c2:	5b                   	pop    %ebx
f01036c3:	5e                   	pop    %esi
f01036c4:	5f                   	pop    %edi
f01036c5:	c9                   	leave  
f01036c6:	c3                   	ret    

f01036c7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01036c7:	55                   	push   %ebp
f01036c8:	89 e5                	mov    %esp,%ebp
f01036ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01036cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01036d0:	8a 01                	mov    (%ecx),%al
f01036d2:	84 c0                	test   %al,%al
f01036d4:	74 10                	je     f01036e6 <strcmp+0x1f>
f01036d6:	3a 02                	cmp    (%edx),%al
f01036d8:	75 0c                	jne    f01036e6 <strcmp+0x1f>
		p++, q++;
f01036da:	41                   	inc    %ecx
f01036db:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01036dc:	8a 01                	mov    (%ecx),%al
f01036de:	84 c0                	test   %al,%al
f01036e0:	74 04                	je     f01036e6 <strcmp+0x1f>
f01036e2:	3a 02                	cmp    (%edx),%al
f01036e4:	74 f4                	je     f01036da <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01036e6:	0f b6 c0             	movzbl %al,%eax
f01036e9:	0f b6 12             	movzbl (%edx),%edx
f01036ec:	29 d0                	sub    %edx,%eax
}
f01036ee:	c9                   	leave  
f01036ef:	c3                   	ret    

f01036f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01036f0:	55                   	push   %ebp
f01036f1:	89 e5                	mov    %esp,%ebp
f01036f3:	53                   	push   %ebx
f01036f4:	8b 55 08             	mov    0x8(%ebp),%edx
f01036f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01036fa:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01036fd:	85 c0                	test   %eax,%eax
f01036ff:	74 1b                	je     f010371c <strncmp+0x2c>
f0103701:	8a 1a                	mov    (%edx),%bl
f0103703:	84 db                	test   %bl,%bl
f0103705:	74 24                	je     f010372b <strncmp+0x3b>
f0103707:	3a 19                	cmp    (%ecx),%bl
f0103709:	75 20                	jne    f010372b <strncmp+0x3b>
f010370b:	48                   	dec    %eax
f010370c:	74 15                	je     f0103723 <strncmp+0x33>
		n--, p++, q++;
f010370e:	42                   	inc    %edx
f010370f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103710:	8a 1a                	mov    (%edx),%bl
f0103712:	84 db                	test   %bl,%bl
f0103714:	74 15                	je     f010372b <strncmp+0x3b>
f0103716:	3a 19                	cmp    (%ecx),%bl
f0103718:	74 f1                	je     f010370b <strncmp+0x1b>
f010371a:	eb 0f                	jmp    f010372b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f010371c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103721:	eb 05                	jmp    f0103728 <strncmp+0x38>
f0103723:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103728:	5b                   	pop    %ebx
f0103729:	c9                   	leave  
f010372a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010372b:	0f b6 02             	movzbl (%edx),%eax
f010372e:	0f b6 11             	movzbl (%ecx),%edx
f0103731:	29 d0                	sub    %edx,%eax
f0103733:	eb f3                	jmp    f0103728 <strncmp+0x38>

f0103735 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103735:	55                   	push   %ebp
f0103736:	89 e5                	mov    %esp,%ebp
f0103738:	8b 45 08             	mov    0x8(%ebp),%eax
f010373b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010373e:	8a 10                	mov    (%eax),%dl
f0103740:	84 d2                	test   %dl,%dl
f0103742:	74 18                	je     f010375c <strchr+0x27>
		if (*s == c)
f0103744:	38 ca                	cmp    %cl,%dl
f0103746:	75 06                	jne    f010374e <strchr+0x19>
f0103748:	eb 17                	jmp    f0103761 <strchr+0x2c>
f010374a:	38 ca                	cmp    %cl,%dl
f010374c:	74 13                	je     f0103761 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010374e:	40                   	inc    %eax
f010374f:	8a 10                	mov    (%eax),%dl
f0103751:	84 d2                	test   %dl,%dl
f0103753:	75 f5                	jne    f010374a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0103755:	b8 00 00 00 00       	mov    $0x0,%eax
f010375a:	eb 05                	jmp    f0103761 <strchr+0x2c>
f010375c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103761:	c9                   	leave  
f0103762:	c3                   	ret    

f0103763 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103763:	55                   	push   %ebp
f0103764:	89 e5                	mov    %esp,%ebp
f0103766:	8b 45 08             	mov    0x8(%ebp),%eax
f0103769:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010376c:	8a 10                	mov    (%eax),%dl
f010376e:	84 d2                	test   %dl,%dl
f0103770:	74 11                	je     f0103783 <strfind+0x20>
		if (*s == c)
f0103772:	38 ca                	cmp    %cl,%dl
f0103774:	75 06                	jne    f010377c <strfind+0x19>
f0103776:	eb 0b                	jmp    f0103783 <strfind+0x20>
f0103778:	38 ca                	cmp    %cl,%dl
f010377a:	74 07                	je     f0103783 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010377c:	40                   	inc    %eax
f010377d:	8a 10                	mov    (%eax),%dl
f010377f:	84 d2                	test   %dl,%dl
f0103781:	75 f5                	jne    f0103778 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f0103783:	c9                   	leave  
f0103784:	c3                   	ret    

f0103785 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103785:	55                   	push   %ebp
f0103786:	89 e5                	mov    %esp,%ebp
f0103788:	57                   	push   %edi
f0103789:	56                   	push   %esi
f010378a:	53                   	push   %ebx
f010378b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010378e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103791:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103794:	85 c9                	test   %ecx,%ecx
f0103796:	74 30                	je     f01037c8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103798:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010379e:	75 25                	jne    f01037c5 <memset+0x40>
f01037a0:	f6 c1 03             	test   $0x3,%cl
f01037a3:	75 20                	jne    f01037c5 <memset+0x40>
		c &= 0xFF;
f01037a5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01037a8:	89 d3                	mov    %edx,%ebx
f01037aa:	c1 e3 08             	shl    $0x8,%ebx
f01037ad:	89 d6                	mov    %edx,%esi
f01037af:	c1 e6 18             	shl    $0x18,%esi
f01037b2:	89 d0                	mov    %edx,%eax
f01037b4:	c1 e0 10             	shl    $0x10,%eax
f01037b7:	09 f0                	or     %esi,%eax
f01037b9:	09 d0                	or     %edx,%eax
f01037bb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01037bd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01037c0:	fc                   	cld    
f01037c1:	f3 ab                	rep stos %eax,%es:(%edi)
f01037c3:	eb 03                	jmp    f01037c8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01037c5:	fc                   	cld    
f01037c6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01037c8:	89 f8                	mov    %edi,%eax
f01037ca:	5b                   	pop    %ebx
f01037cb:	5e                   	pop    %esi
f01037cc:	5f                   	pop    %edi
f01037cd:	c9                   	leave  
f01037ce:	c3                   	ret    

f01037cf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01037cf:	55                   	push   %ebp
f01037d0:	89 e5                	mov    %esp,%ebp
f01037d2:	57                   	push   %edi
f01037d3:	56                   	push   %esi
f01037d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01037d7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01037da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01037dd:	39 c6                	cmp    %eax,%esi
f01037df:	73 34                	jae    f0103815 <memmove+0x46>
f01037e1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01037e4:	39 d0                	cmp    %edx,%eax
f01037e6:	73 2d                	jae    f0103815 <memmove+0x46>
		s += n;
		d += n;
f01037e8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01037eb:	f6 c2 03             	test   $0x3,%dl
f01037ee:	75 1b                	jne    f010380b <memmove+0x3c>
f01037f0:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01037f6:	75 13                	jne    f010380b <memmove+0x3c>
f01037f8:	f6 c1 03             	test   $0x3,%cl
f01037fb:	75 0e                	jne    f010380b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01037fd:	83 ef 04             	sub    $0x4,%edi
f0103800:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103803:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0103806:	fd                   	std    
f0103807:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103809:	eb 07                	jmp    f0103812 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010380b:	4f                   	dec    %edi
f010380c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010380f:	fd                   	std    
f0103810:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103812:	fc                   	cld    
f0103813:	eb 20                	jmp    f0103835 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103815:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010381b:	75 13                	jne    f0103830 <memmove+0x61>
f010381d:	a8 03                	test   $0x3,%al
f010381f:	75 0f                	jne    f0103830 <memmove+0x61>
f0103821:	f6 c1 03             	test   $0x3,%cl
f0103824:	75 0a                	jne    f0103830 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103826:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0103829:	89 c7                	mov    %eax,%edi
f010382b:	fc                   	cld    
f010382c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010382e:	eb 05                	jmp    f0103835 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103830:	89 c7                	mov    %eax,%edi
f0103832:	fc                   	cld    
f0103833:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103835:	5e                   	pop    %esi
f0103836:	5f                   	pop    %edi
f0103837:	c9                   	leave  
f0103838:	c3                   	ret    

f0103839 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103839:	55                   	push   %ebp
f010383a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010383c:	ff 75 10             	pushl  0x10(%ebp)
f010383f:	ff 75 0c             	pushl  0xc(%ebp)
f0103842:	ff 75 08             	pushl  0x8(%ebp)
f0103845:	e8 85 ff ff ff       	call   f01037cf <memmove>
}
f010384a:	c9                   	leave  
f010384b:	c3                   	ret    

f010384c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010384c:	55                   	push   %ebp
f010384d:	89 e5                	mov    %esp,%ebp
f010384f:	57                   	push   %edi
f0103850:	56                   	push   %esi
f0103851:	53                   	push   %ebx
f0103852:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103855:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103858:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010385b:	85 ff                	test   %edi,%edi
f010385d:	74 32                	je     f0103891 <memcmp+0x45>
		if (*s1 != *s2)
f010385f:	8a 03                	mov    (%ebx),%al
f0103861:	8a 0e                	mov    (%esi),%cl
f0103863:	38 c8                	cmp    %cl,%al
f0103865:	74 19                	je     f0103880 <memcmp+0x34>
f0103867:	eb 0d                	jmp    f0103876 <memcmp+0x2a>
f0103869:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f010386d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0103871:	42                   	inc    %edx
f0103872:	38 c8                	cmp    %cl,%al
f0103874:	74 10                	je     f0103886 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f0103876:	0f b6 c0             	movzbl %al,%eax
f0103879:	0f b6 c9             	movzbl %cl,%ecx
f010387c:	29 c8                	sub    %ecx,%eax
f010387e:	eb 16                	jmp    f0103896 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103880:	4f                   	dec    %edi
f0103881:	ba 00 00 00 00       	mov    $0x0,%edx
f0103886:	39 fa                	cmp    %edi,%edx
f0103888:	75 df                	jne    f0103869 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010388a:	b8 00 00 00 00       	mov    $0x0,%eax
f010388f:	eb 05                	jmp    f0103896 <memcmp+0x4a>
f0103891:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103896:	5b                   	pop    %ebx
f0103897:	5e                   	pop    %esi
f0103898:	5f                   	pop    %edi
f0103899:	c9                   	leave  
f010389a:	c3                   	ret    

f010389b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010389b:	55                   	push   %ebp
f010389c:	89 e5                	mov    %esp,%ebp
f010389e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01038a1:	89 c2                	mov    %eax,%edx
f01038a3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01038a6:	39 d0                	cmp    %edx,%eax
f01038a8:	73 12                	jae    f01038bc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f01038aa:	8a 4d 0c             	mov    0xc(%ebp),%cl
f01038ad:	38 08                	cmp    %cl,(%eax)
f01038af:	75 06                	jne    f01038b7 <memfind+0x1c>
f01038b1:	eb 09                	jmp    f01038bc <memfind+0x21>
f01038b3:	38 08                	cmp    %cl,(%eax)
f01038b5:	74 05                	je     f01038bc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01038b7:	40                   	inc    %eax
f01038b8:	39 c2                	cmp    %eax,%edx
f01038ba:	77 f7                	ja     f01038b3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01038bc:	c9                   	leave  
f01038bd:	c3                   	ret    

f01038be <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01038be:	55                   	push   %ebp
f01038bf:	89 e5                	mov    %esp,%ebp
f01038c1:	57                   	push   %edi
f01038c2:	56                   	push   %esi
f01038c3:	53                   	push   %ebx
f01038c4:	8b 55 08             	mov    0x8(%ebp),%edx
f01038c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01038ca:	eb 01                	jmp    f01038cd <strtol+0xf>
		s++;
f01038cc:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01038cd:	8a 02                	mov    (%edx),%al
f01038cf:	3c 20                	cmp    $0x20,%al
f01038d1:	74 f9                	je     f01038cc <strtol+0xe>
f01038d3:	3c 09                	cmp    $0x9,%al
f01038d5:	74 f5                	je     f01038cc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01038d7:	3c 2b                	cmp    $0x2b,%al
f01038d9:	75 08                	jne    f01038e3 <strtol+0x25>
		s++;
f01038db:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01038dc:	bf 00 00 00 00       	mov    $0x0,%edi
f01038e1:	eb 13                	jmp    f01038f6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01038e3:	3c 2d                	cmp    $0x2d,%al
f01038e5:	75 0a                	jne    f01038f1 <strtol+0x33>
		s++, neg = 1;
f01038e7:	8d 52 01             	lea    0x1(%edx),%edx
f01038ea:	bf 01 00 00 00       	mov    $0x1,%edi
f01038ef:	eb 05                	jmp    f01038f6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01038f1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01038f6:	85 db                	test   %ebx,%ebx
f01038f8:	74 05                	je     f01038ff <strtol+0x41>
f01038fa:	83 fb 10             	cmp    $0x10,%ebx
f01038fd:	75 28                	jne    f0103927 <strtol+0x69>
f01038ff:	8a 02                	mov    (%edx),%al
f0103901:	3c 30                	cmp    $0x30,%al
f0103903:	75 10                	jne    f0103915 <strtol+0x57>
f0103905:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103909:	75 0a                	jne    f0103915 <strtol+0x57>
		s += 2, base = 16;
f010390b:	83 c2 02             	add    $0x2,%edx
f010390e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103913:	eb 12                	jmp    f0103927 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0103915:	85 db                	test   %ebx,%ebx
f0103917:	75 0e                	jne    f0103927 <strtol+0x69>
f0103919:	3c 30                	cmp    $0x30,%al
f010391b:	75 05                	jne    f0103922 <strtol+0x64>
		s++, base = 8;
f010391d:	42                   	inc    %edx
f010391e:	b3 08                	mov    $0x8,%bl
f0103920:	eb 05                	jmp    f0103927 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0103922:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0103927:	b8 00 00 00 00       	mov    $0x0,%eax
f010392c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010392e:	8a 0a                	mov    (%edx),%cl
f0103930:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0103933:	80 fb 09             	cmp    $0x9,%bl
f0103936:	77 08                	ja     f0103940 <strtol+0x82>
			dig = *s - '0';
f0103938:	0f be c9             	movsbl %cl,%ecx
f010393b:	83 e9 30             	sub    $0x30,%ecx
f010393e:	eb 1e                	jmp    f010395e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0103940:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0103943:	80 fb 19             	cmp    $0x19,%bl
f0103946:	77 08                	ja     f0103950 <strtol+0x92>
			dig = *s - 'a' + 10;
f0103948:	0f be c9             	movsbl %cl,%ecx
f010394b:	83 e9 57             	sub    $0x57,%ecx
f010394e:	eb 0e                	jmp    f010395e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0103950:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0103953:	80 fb 19             	cmp    $0x19,%bl
f0103956:	77 13                	ja     f010396b <strtol+0xad>
			dig = *s - 'A' + 10;
f0103958:	0f be c9             	movsbl %cl,%ecx
f010395b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010395e:	39 f1                	cmp    %esi,%ecx
f0103960:	7d 0d                	jge    f010396f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f0103962:	42                   	inc    %edx
f0103963:	0f af c6             	imul   %esi,%eax
f0103966:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0103969:	eb c3                	jmp    f010392e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010396b:	89 c1                	mov    %eax,%ecx
f010396d:	eb 02                	jmp    f0103971 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010396f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0103971:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103975:	74 05                	je     f010397c <strtol+0xbe>
		*endptr = (char *) s;
f0103977:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010397a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f010397c:	85 ff                	test   %edi,%edi
f010397e:	74 04                	je     f0103984 <strtol+0xc6>
f0103980:	89 c8                	mov    %ecx,%eax
f0103982:	f7 d8                	neg    %eax
}
f0103984:	5b                   	pop    %ebx
f0103985:	5e                   	pop    %esi
f0103986:	5f                   	pop    %edi
f0103987:	c9                   	leave  
f0103988:	c3                   	ret    
f0103989:	00 00                	add    %al,(%eax)
	...

f010398c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f010398c:	55                   	push   %ebp
f010398d:	89 e5                	mov    %esp,%ebp
f010398f:	57                   	push   %edi
f0103990:	56                   	push   %esi
f0103991:	83 ec 10             	sub    $0x10,%esp
f0103994:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103997:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010399a:	89 7d f0             	mov    %edi,-0x10(%ebp)
f010399d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f01039a0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01039a3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01039a6:	85 c0                	test   %eax,%eax
f01039a8:	75 2e                	jne    f01039d8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f01039aa:	39 f1                	cmp    %esi,%ecx
f01039ac:	77 5a                	ja     f0103a08 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01039ae:	85 c9                	test   %ecx,%ecx
f01039b0:	75 0b                	jne    f01039bd <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01039b2:	b8 01 00 00 00       	mov    $0x1,%eax
f01039b7:	31 d2                	xor    %edx,%edx
f01039b9:	f7 f1                	div    %ecx
f01039bb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01039bd:	31 d2                	xor    %edx,%edx
f01039bf:	89 f0                	mov    %esi,%eax
f01039c1:	f7 f1                	div    %ecx
f01039c3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01039c5:	89 f8                	mov    %edi,%eax
f01039c7:	f7 f1                	div    %ecx
f01039c9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01039cb:	89 f8                	mov    %edi,%eax
f01039cd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01039cf:	83 c4 10             	add    $0x10,%esp
f01039d2:	5e                   	pop    %esi
f01039d3:	5f                   	pop    %edi
f01039d4:	c9                   	leave  
f01039d5:	c3                   	ret    
f01039d6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01039d8:	39 f0                	cmp    %esi,%eax
f01039da:	77 1c                	ja     f01039f8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f01039dc:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f01039df:	83 f7 1f             	xor    $0x1f,%edi
f01039e2:	75 3c                	jne    f0103a20 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01039e4:	39 f0                	cmp    %esi,%eax
f01039e6:	0f 82 90 00 00 00    	jb     f0103a7c <__udivdi3+0xf0>
f01039ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01039ef:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f01039f2:	0f 86 84 00 00 00    	jbe    f0103a7c <__udivdi3+0xf0>
f01039f8:	31 f6                	xor    %esi,%esi
f01039fa:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01039fc:	89 f8                	mov    %edi,%eax
f01039fe:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103a00:	83 c4 10             	add    $0x10,%esp
f0103a03:	5e                   	pop    %esi
f0103a04:	5f                   	pop    %edi
f0103a05:	c9                   	leave  
f0103a06:	c3                   	ret    
f0103a07:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103a08:	89 f2                	mov    %esi,%edx
f0103a0a:	89 f8                	mov    %edi,%eax
f0103a0c:	f7 f1                	div    %ecx
f0103a0e:	89 c7                	mov    %eax,%edi
f0103a10:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103a12:	89 f8                	mov    %edi,%eax
f0103a14:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103a16:	83 c4 10             	add    $0x10,%esp
f0103a19:	5e                   	pop    %esi
f0103a1a:	5f                   	pop    %edi
f0103a1b:	c9                   	leave  
f0103a1c:	c3                   	ret    
f0103a1d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103a20:	89 f9                	mov    %edi,%ecx
f0103a22:	d3 e0                	shl    %cl,%eax
f0103a24:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103a27:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a2c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0103a2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103a31:	88 c1                	mov    %al,%cl
f0103a33:	d3 ea                	shr    %cl,%edx
f0103a35:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103a38:	09 ca                	or     %ecx,%edx
f0103a3a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f0103a3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103a40:	89 f9                	mov    %edi,%ecx
f0103a42:	d3 e2                	shl    %cl,%edx
f0103a44:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f0103a47:	89 f2                	mov    %esi,%edx
f0103a49:	88 c1                	mov    %al,%cl
f0103a4b:	d3 ea                	shr    %cl,%edx
f0103a4d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0103a50:	89 f2                	mov    %esi,%edx
f0103a52:	89 f9                	mov    %edi,%ecx
f0103a54:	d3 e2                	shl    %cl,%edx
f0103a56:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0103a59:	88 c1                	mov    %al,%cl
f0103a5b:	d3 ee                	shr    %cl,%esi
f0103a5d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103a5f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103a62:	89 f0                	mov    %esi,%eax
f0103a64:	89 ca                	mov    %ecx,%edx
f0103a66:	f7 75 ec             	divl   -0x14(%ebp)
f0103a69:	89 d1                	mov    %edx,%ecx
f0103a6b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103a6d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103a70:	39 d1                	cmp    %edx,%ecx
f0103a72:	72 28                	jb     f0103a9c <__udivdi3+0x110>
f0103a74:	74 1a                	je     f0103a90 <__udivdi3+0x104>
f0103a76:	89 f7                	mov    %esi,%edi
f0103a78:	31 f6                	xor    %esi,%esi
f0103a7a:	eb 80                	jmp    f01039fc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103a7c:	31 f6                	xor    %esi,%esi
f0103a7e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103a83:	89 f8                	mov    %edi,%eax
f0103a85:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103a87:	83 c4 10             	add    $0x10,%esp
f0103a8a:	5e                   	pop    %esi
f0103a8b:	5f                   	pop    %edi
f0103a8c:	c9                   	leave  
f0103a8d:	c3                   	ret    
f0103a8e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0103a90:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103a93:	89 f9                	mov    %edi,%ecx
f0103a95:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103a97:	39 c2                	cmp    %eax,%edx
f0103a99:	73 db                	jae    f0103a76 <__udivdi3+0xea>
f0103a9b:	90                   	nop
		{
		  q0--;
f0103a9c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103a9f:	31 f6                	xor    %esi,%esi
f0103aa1:	e9 56 ff ff ff       	jmp    f01039fc <__udivdi3+0x70>
	...

f0103aa8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0103aa8:	55                   	push   %ebp
f0103aa9:	89 e5                	mov    %esp,%ebp
f0103aab:	57                   	push   %edi
f0103aac:	56                   	push   %esi
f0103aad:	83 ec 20             	sub    $0x20,%esp
f0103ab0:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ab3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0103ab6:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0103ab9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0103abc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103abf:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0103ac2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0103ac5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103ac7:	85 ff                	test   %edi,%edi
f0103ac9:	75 15                	jne    f0103ae0 <__umoddi3+0x38>
    {
      if (d0 > n1)
f0103acb:	39 f1                	cmp    %esi,%ecx
f0103acd:	0f 86 99 00 00 00    	jbe    f0103b6c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103ad3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0103ad5:	89 d0                	mov    %edx,%eax
f0103ad7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103ad9:	83 c4 20             	add    $0x20,%esp
f0103adc:	5e                   	pop    %esi
f0103add:	5f                   	pop    %edi
f0103ade:	c9                   	leave  
f0103adf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103ae0:	39 f7                	cmp    %esi,%edi
f0103ae2:	0f 87 a4 00 00 00    	ja     f0103b8c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103ae8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0103aeb:	83 f0 1f             	xor    $0x1f,%eax
f0103aee:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103af1:	0f 84 a1 00 00 00    	je     f0103b98 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103af7:	89 f8                	mov    %edi,%eax
f0103af9:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103afc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103afe:	bf 20 00 00 00       	mov    $0x20,%edi
f0103b03:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0103b06:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103b09:	89 f9                	mov    %edi,%ecx
f0103b0b:	d3 ea                	shr    %cl,%edx
f0103b0d:	09 c2                	or     %eax,%edx
f0103b0f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0103b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b15:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103b18:	d3 e0                	shl    %cl,%eax
f0103b1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103b1d:	89 f2                	mov    %esi,%edx
f0103b1f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0103b21:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b24:	d3 e0                	shl    %cl,%eax
f0103b26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103b29:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b2c:	89 f9                	mov    %edi,%ecx
f0103b2e:	d3 e8                	shr    %cl,%eax
f0103b30:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0103b32:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103b34:	89 f2                	mov    %esi,%edx
f0103b36:	f7 75 f0             	divl   -0x10(%ebp)
f0103b39:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103b3b:	f7 65 f4             	mull   -0xc(%ebp)
f0103b3e:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103b41:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103b43:	39 d6                	cmp    %edx,%esi
f0103b45:	72 71                	jb     f0103bb8 <__umoddi3+0x110>
f0103b47:	74 7f                	je     f0103bc8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0103b49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b4c:	29 c8                	sub    %ecx,%eax
f0103b4e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0103b50:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103b53:	d3 e8                	shr    %cl,%eax
f0103b55:	89 f2                	mov    %esi,%edx
f0103b57:	89 f9                	mov    %edi,%ecx
f0103b59:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0103b5b:	09 d0                	or     %edx,%eax
f0103b5d:	89 f2                	mov    %esi,%edx
f0103b5f:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103b62:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103b64:	83 c4 20             	add    $0x20,%esp
f0103b67:	5e                   	pop    %esi
f0103b68:	5f                   	pop    %edi
f0103b69:	c9                   	leave  
f0103b6a:	c3                   	ret    
f0103b6b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103b6c:	85 c9                	test   %ecx,%ecx
f0103b6e:	75 0b                	jne    f0103b7b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103b70:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b75:	31 d2                	xor    %edx,%edx
f0103b77:	f7 f1                	div    %ecx
f0103b79:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0103b7b:	89 f0                	mov    %esi,%eax
f0103b7d:	31 d2                	xor    %edx,%edx
f0103b7f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b84:	f7 f1                	div    %ecx
f0103b86:	e9 4a ff ff ff       	jmp    f0103ad5 <__umoddi3+0x2d>
f0103b8b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0103b8c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103b8e:	83 c4 20             	add    $0x20,%esp
f0103b91:	5e                   	pop    %esi
f0103b92:	5f                   	pop    %edi
f0103b93:	c9                   	leave  
f0103b94:	c3                   	ret    
f0103b95:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103b98:	39 f7                	cmp    %esi,%edi
f0103b9a:	72 05                	jb     f0103ba1 <__umoddi3+0xf9>
f0103b9c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0103b9f:	77 0c                	ja     f0103bad <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103ba1:	89 f2                	mov    %esi,%edx
f0103ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103ba6:	29 c8                	sub    %ecx,%eax
f0103ba8:	19 fa                	sbb    %edi,%edx
f0103baa:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0103bad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103bb0:	83 c4 20             	add    $0x20,%esp
f0103bb3:	5e                   	pop    %esi
f0103bb4:	5f                   	pop    %edi
f0103bb5:	c9                   	leave  
f0103bb6:	c3                   	ret    
f0103bb7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103bb8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103bbb:	89 c1                	mov    %eax,%ecx
f0103bbd:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0103bc0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0103bc3:	eb 84                	jmp    f0103b49 <__umoddi3+0xa1>
f0103bc5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103bc8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103bcb:	72 eb                	jb     f0103bb8 <__umoddi3+0x110>
f0103bcd:	89 f2                	mov    %esi,%edx
f0103bcf:	e9 75 ff ff ff       	jmp    f0103b49 <__umoddi3+0xa1>
