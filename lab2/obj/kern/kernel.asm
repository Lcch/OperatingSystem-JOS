
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
f0100058:	e8 dc 36 00 00       	call   f0103739 <memset>

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
f010006a:	68 a0 3b 10 f0       	push   $0xf0103ba0
f010006f:	e8 95 2b 00 00       	call   f0102c09 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 24 15 00 00       	call   f010159d <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 ed 0c 00 00       	call   f0100d73 <monitor>
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
f01000b0:	68 bb 3b 10 f0       	push   $0xf0103bbb
f01000b5:	e8 4f 2b 00 00       	call   f0102c09 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 1f 2b 00 00       	call   f0102be3 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 85 3e 10 f0 	movl   $0xf0103e85,(%esp)
f01000cb:	e8 39 2b 00 00       	call   f0102c09 <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 96 0c 00 00       	call   f0100d73 <monitor>
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
f01000f2:	68 d3 3b 10 f0       	push   $0xf0103bd3
f01000f7:	e8 0d 2b 00 00       	call   f0102c09 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 db 2a 00 00       	call   f0102be3 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 85 3e 10 f0 	movl   $0xf0103e85,(%esp)
f010010f:	e8 f5 2a 00 00       	call   f0102c09 <cprintf>
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
f01002fd:	e8 81 34 00 00       	call   f0103783 <memmove>
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
f010039c:	8a 82 20 3c 10 f0    	mov    -0xfefc3e0(%edx),%al
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
f01003d8:	0f b6 82 20 3c 10 f0 	movzbl -0xfefc3e0(%edx),%eax
f01003df:	0b 05 28 e5 11 f0    	or     0xf011e528,%eax
	shift ^= togglecode[data];
f01003e5:	0f b6 8a 20 3d 10 f0 	movzbl -0xfefc2e0(%edx),%ecx
f01003ec:	31 c8                	xor    %ecx,%eax
f01003ee:	a3 28 e5 11 f0       	mov    %eax,0xf011e528

	c = charcode[shift & (CTL | SHIFT)][data];
f01003f3:	89 c1                	mov    %eax,%ecx
f01003f5:	83 e1 03             	and    $0x3,%ecx
f01003f8:	8b 0c 8d 20 3e 10 f0 	mov    -0xfefc1e0(,%ecx,4),%ecx
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
f0100430:	68 ed 3b 10 f0       	push   $0xf0103bed
f0100435:	e8 cf 27 00 00       	call   f0102c09 <cprintf>
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
f0100591:	68 f9 3b 10 f0       	push   $0xf0103bf9
f0100596:	e8 6e 26 00 00       	call   f0102c09 <cprintf>
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
f01005da:	68 30 3e 10 f0       	push   $0xf0103e30
f01005df:	e8 25 26 00 00       	call   f0102c09 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005e4:	83 c4 08             	add    $0x8,%esp
f01005e7:	68 0c 00 10 00       	push   $0x10000c
f01005ec:	68 18 40 10 f0       	push   $0xf0104018
f01005f1:	e8 13 26 00 00       	call   f0102c09 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01005f6:	83 c4 0c             	add    $0xc,%esp
f01005f9:	68 0c 00 10 00       	push   $0x10000c
f01005fe:	68 0c 00 10 f0       	push   $0xf010000c
f0100603:	68 40 40 10 f0       	push   $0xf0104040
f0100608:	e8 fc 25 00 00       	call   f0102c09 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010060d:	83 c4 0c             	add    $0xc,%esp
f0100610:	68 88 3b 10 00       	push   $0x103b88
f0100615:	68 88 3b 10 f0       	push   $0xf0103b88
f010061a:	68 64 40 10 f0       	push   $0xf0104064
f010061f:	e8 e5 25 00 00       	call   f0102c09 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100624:	83 c4 0c             	add    $0xc,%esp
f0100627:	68 00 e3 11 00       	push   $0x11e300
f010062c:	68 00 e3 11 f0       	push   $0xf011e300
f0100631:	68 88 40 10 f0       	push   $0xf0104088
f0100636:	e8 ce 25 00 00       	call   f0102c09 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010063b:	83 c4 0c             	add    $0xc,%esp
f010063e:	68 50 e9 11 00       	push   $0x11e950
f0100643:	68 50 e9 11 f0       	push   $0xf011e950
f0100648:	68 ac 40 10 f0       	push   $0xf01040ac
f010064d:	e8 b7 25 00 00       	call   f0102c09 <cprintf>
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
f0100674:	68 d0 40 10 f0       	push   $0xf01040d0
f0100679:	e8 8b 25 00 00       	call   f0102c09 <cprintf>
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
f0100694:	ff b3 24 45 10 f0    	pushl  -0xfefbadc(%ebx)
f010069a:	ff b3 20 45 10 f0    	pushl  -0xfefbae0(%ebx)
f01006a0:	68 49 3e 10 f0       	push   $0xf0103e49
f01006a5:	e8 5f 25 00 00       	call   f0102c09 <cprintf>
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
f01006d4:	68 fc 40 10 f0       	push   $0xf01040fc
f01006d9:	e8 2b 25 00 00       	call   f0102c09 <cprintf>
        cprintf("Example: showmappings 0x3000 0x5000\n");
f01006de:	c7 04 24 30 41 10 f0 	movl   $0xf0104130,(%esp)
f01006e5:	e8 1f 25 00 00       	call   f0102c09 <cprintf>
f01006ea:	83 c4 10             	add    $0x10,%esp
f01006ed:	e9 1a 01 00 00       	jmp    f010080c <mon_showmappings+0x14d>
    } else {
        uint32_t laddr = strtol(argv[1], NULL, 0);
f01006f2:	83 ec 04             	sub    $0x4,%esp
f01006f5:	6a 00                	push   $0x0
f01006f7:	6a 00                	push   $0x0
f01006f9:	ff 76 04             	pushl  0x4(%esi)
f01006fc:	e8 71 31 00 00       	call   f0103872 <strtol>
f0100701:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[2], NULL, 0);
f0100703:	83 c4 0c             	add    $0xc,%esp
f0100706:	6a 00                	push   $0x0
f0100708:	6a 00                	push   $0x0
f010070a:	ff 76 08             	pushl  0x8(%esi)
f010070d:	e8 60 31 00 00       	call   f0103872 <strtol>
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
f0100731:	68 52 3e 10 f0       	push   $0xf0103e52
f0100736:	e8 ce 24 00 00       	call   f0102c09 <cprintf>
        
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
f0100754:	68 63 3e 10 f0       	push   $0xf0103e63
f0100759:	e8 ab 24 00 00       	call   f0102c09 <cprintf>
            pte = pgdir_walk(kern_pgdir, (void *)now, 0);
f010075e:	83 c4 0c             	add    $0xc,%esp
f0100761:	6a 00                	push   $0x0
f0100763:	53                   	push   %ebx
f0100764:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f010076a:	e8 1f 0c 00 00       	call   f010138e <pgdir_walk>
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
f0100781:	68 7a 3e 10 f0       	push   $0xf0103e7a
f0100786:	e8 7e 24 00 00       	call   f0102c09 <cprintf>
f010078b:	83 c4 10             	add    $0x10,%esp
f010078e:	eb 74                	jmp    f0100804 <mon_showmappings+0x145>
            } else {
                cprintf("0x%08x ", PTE_ADDR(*pte));
f0100790:	83 ec 08             	sub    $0x8,%esp
f0100793:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100798:	50                   	push   %eax
f0100799:	68 87 3e 10 f0       	push   $0xf0103e87
f010079e:	e8 66 24 00 00       	call   f0102c09 <cprintf>
                if (*pte & PTE_U) cprintf(" user       ");
f01007a3:	83 c4 10             	add    $0x10,%esp
f01007a6:	f6 03 04             	testb  $0x4,(%ebx)
f01007a9:	74 12                	je     f01007bd <mon_showmappings+0xfe>
f01007ab:	83 ec 0c             	sub    $0xc,%esp
f01007ae:	68 8f 3e 10 f0       	push   $0xf0103e8f
f01007b3:	e8 51 24 00 00       	call   f0102c09 <cprintf>
f01007b8:	83 c4 10             	add    $0x10,%esp
f01007bb:	eb 10                	jmp    f01007cd <mon_showmappings+0x10e>
                else cprintf(" supervisor ");
f01007bd:	83 ec 0c             	sub    $0xc,%esp
f01007c0:	68 9c 3e 10 f0       	push   $0xf0103e9c
f01007c5:	e8 3f 24 00 00       	call   f0102c09 <cprintf>
f01007ca:	83 c4 10             	add    $0x10,%esp
                if (*pte & PTE_W) cprintf(" RW ");
f01007cd:	f6 03 02             	testb  $0x2,(%ebx)
f01007d0:	74 12                	je     f01007e4 <mon_showmappings+0x125>
f01007d2:	83 ec 0c             	sub    $0xc,%esp
f01007d5:	68 a9 3e 10 f0       	push   $0xf0103ea9
f01007da:	e8 2a 24 00 00       	call   f0102c09 <cprintf>
f01007df:	83 c4 10             	add    $0x10,%esp
f01007e2:	eb 10                	jmp    f01007f4 <mon_showmappings+0x135>
                else cprintf(" R ");
f01007e4:	83 ec 0c             	sub    $0xc,%esp
f01007e7:	68 ae 3e 10 f0       	push   $0xf0103eae
f01007ec:	e8 18 24 00 00       	call   f0102c09 <cprintf>
f01007f1:	83 c4 10             	add    $0x10,%esp
                cprintf("\n");
f01007f4:	83 ec 0c             	sub    $0xc,%esp
f01007f7:	68 85 3e 10 f0       	push   $0xf0103e85
f01007fc:	e8 08 24 00 00       	call   f0102c09 <cprintf>
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
f010082e:	68 58 41 10 f0       	push   $0xf0104158
f0100833:	e8 d1 23 00 00       	call   f0102c09 <cprintf>
        cprintf("Example: setpermissions 0x0 1 0 1\n");
f0100838:	c7 04 24 a8 41 10 f0 	movl   $0xf01041a8,(%esp)
f010083f:	e8 c5 23 00 00       	call   f0102c09 <cprintf>
f0100844:	83 c4 10             	add    $0x10,%esp
f0100847:	e9 a5 01 00 00       	jmp    f01009f1 <mon_setpermission+0x1d8>
    } else {
        uint32_t addr = strtol(argv[1], NULL, 0);
f010084c:	83 ec 04             	sub    $0x4,%esp
f010084f:	6a 00                	push   $0x0
f0100851:	6a 00                	push   $0x0
f0100853:	ff 73 04             	pushl  0x4(%ebx)
f0100856:	e8 17 30 00 00       	call   f0103872 <strtol>
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
f010089c:	e8 ed 0a 00 00       	call   f010138e <pgdir_walk>
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
f01008ba:	68 cc 41 10 f0       	push   $0xf01041cc
f01008bf:	e8 45 23 00 00       	call   f0102c09 <cprintf>
            if (*pte & PTE_W) cprintf("RW"); else cprintf("R-");
f01008c4:	83 c4 10             	add    $0x10,%esp
f01008c7:	f6 03 02             	testb  $0x2,(%ebx)
f01008ca:	74 12                	je     f01008de <mon_setpermission+0xc5>
f01008cc:	83 ec 0c             	sub    $0xc,%esp
f01008cf:	68 b2 3e 10 f0       	push   $0xf0103eb2
f01008d4:	e8 30 23 00 00       	call   f0102c09 <cprintf>
f01008d9:	83 c4 10             	add    $0x10,%esp
f01008dc:	eb 10                	jmp    f01008ee <mon_setpermission+0xd5>
f01008de:	83 ec 0c             	sub    $0xc,%esp
f01008e1:	68 b5 3e 10 f0       	push   $0xf0103eb5
f01008e6:	e8 1e 23 00 00       	call   f0102c09 <cprintf>
f01008eb:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f01008ee:	f6 03 04             	testb  $0x4,(%ebx)
f01008f1:	74 12                	je     f0100905 <mon_setpermission+0xec>
f01008f3:	83 ec 0c             	sub    $0xc,%esp
f01008f6:	68 81 4e 10 f0       	push   $0xf0104e81
f01008fb:	e8 09 23 00 00       	call   f0102c09 <cprintf>
f0100900:	83 c4 10             	add    $0x10,%esp
f0100903:	eb 10                	jmp    f0100915 <mon_setpermission+0xfc>
f0100905:	83 ec 0c             	sub    $0xc,%esp
f0100908:	68 b8 3e 10 f0       	push   $0xf0103eb8
f010090d:	e8 f7 22 00 00       	call   f0102c09 <cprintf>
f0100912:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f0100915:	f6 03 01             	testb  $0x1,(%ebx)
f0100918:	74 12                	je     f010092c <mon_setpermission+0x113>
f010091a:	83 ec 0c             	sub    $0xc,%esp
f010091d:	68 0d 4f 10 f0       	push   $0xf0104f0d
f0100922:	e8 e2 22 00 00       	call   f0102c09 <cprintf>
f0100927:	83 c4 10             	add    $0x10,%esp
f010092a:	eb 10                	jmp    f010093c <mon_setpermission+0x123>
f010092c:	83 ec 0c             	sub    $0xc,%esp
f010092f:	68 b6 3e 10 f0       	push   $0xf0103eb6
f0100934:	e8 d0 22 00 00       	call   f0102c09 <cprintf>
f0100939:	83 c4 10             	add    $0x10,%esp
            cprintf("  --> new_perm: ");
f010093c:	83 ec 0c             	sub    $0xc,%esp
f010093f:	68 ba 3e 10 f0       	push   $0xf0103eba
f0100944:	e8 c0 22 00 00       	call   f0102c09 <cprintf>
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
f0100962:	68 b2 3e 10 f0       	push   $0xf0103eb2
f0100967:	e8 9d 22 00 00       	call   f0102c09 <cprintf>
f010096c:	83 c4 10             	add    $0x10,%esp
f010096f:	eb 10                	jmp    f0100981 <mon_setpermission+0x168>
f0100971:	83 ec 0c             	sub    $0xc,%esp
f0100974:	68 b5 3e 10 f0       	push   $0xf0103eb5
f0100979:	e8 8b 22 00 00       	call   f0102c09 <cprintf>
f010097e:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_U) cprintf("U"); else cprintf("S");
f0100981:	f6 03 04             	testb  $0x4,(%ebx)
f0100984:	74 12                	je     f0100998 <mon_setpermission+0x17f>
f0100986:	83 ec 0c             	sub    $0xc,%esp
f0100989:	68 81 4e 10 f0       	push   $0xf0104e81
f010098e:	e8 76 22 00 00       	call   f0102c09 <cprintf>
f0100993:	83 c4 10             	add    $0x10,%esp
f0100996:	eb 10                	jmp    f01009a8 <mon_setpermission+0x18f>
f0100998:	83 ec 0c             	sub    $0xc,%esp
f010099b:	68 b8 3e 10 f0       	push   $0xf0103eb8
f01009a0:	e8 64 22 00 00       	call   f0102c09 <cprintf>
f01009a5:	83 c4 10             	add    $0x10,%esp
            if (*pte & PTE_P) cprintf("P"); else cprintf("-");
f01009a8:	f6 03 01             	testb  $0x1,(%ebx)
f01009ab:	74 12                	je     f01009bf <mon_setpermission+0x1a6>
f01009ad:	83 ec 0c             	sub    $0xc,%esp
f01009b0:	68 0d 4f 10 f0       	push   $0xf0104f0d
f01009b5:	e8 4f 22 00 00       	call   f0102c09 <cprintf>
f01009ba:	83 c4 10             	add    $0x10,%esp
f01009bd:	eb 10                	jmp    f01009cf <mon_setpermission+0x1b6>
f01009bf:	83 ec 0c             	sub    $0xc,%esp
f01009c2:	68 b6 3e 10 f0       	push   $0xf0103eb6
f01009c7:	e8 3d 22 00 00       	call   f0102c09 <cprintf>
f01009cc:	83 c4 10             	add    $0x10,%esp
            cprintf("\n");
f01009cf:	83 ec 0c             	sub    $0xc,%esp
f01009d2:	68 85 3e 10 f0       	push   $0xf0103e85
f01009d7:	e8 2d 22 00 00       	call   f0102c09 <cprintf>
f01009dc:	83 c4 10             	add    $0x10,%esp
f01009df:	eb 10                	jmp    f01009f1 <mon_setpermission+0x1d8>
        } else {
            cprintf(" no mapped \n");
f01009e1:	83 ec 0c             	sub    $0xc,%esp
f01009e4:	68 7a 3e 10 f0       	push   $0xf0103e7a
f01009e9:	e8 1b 22 00 00       	call   f0102c09 <cprintf>
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
f0100a0f:	68 f0 41 10 f0       	push   $0xf01041f0
f0100a14:	e8 f0 21 00 00       	call   f0102c09 <cprintf>
        cprintf("num show the color attribute. \n");
f0100a19:	c7 04 24 20 42 10 f0 	movl   $0xf0104220,(%esp)
f0100a20:	e8 e4 21 00 00       	call   f0102c09 <cprintf>
        cprintf("                 Text Attribute Byte (B & W)    \n");
f0100a25:	c7 04 24 40 42 10 f0 	movl   $0xf0104240,(%esp)
f0100a2c:	e8 d8 21 00 00       	call   f0102c09 <cprintf>
        cprintf("|   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |\n");
f0100a31:	c7 04 24 74 42 10 f0 	movl   $0xf0104274,(%esp)
f0100a38:	e8 cc 21 00 00       	call   f0102c09 <cprintf>
        cprintf("| Blink |    Bgd Color (RGB)    |     Foregound Color (IRGB)    |\n");
f0100a3d:	c7 04 24 b8 42 10 f0 	movl   $0xf01042b8,(%esp)
f0100a44:	e8 c0 21 00 00       	call   f0102c09 <cprintf>
        cprintf("Example: setcolor 00001111\n");
f0100a49:	c7 04 24 cb 3e 10 f0 	movl   $0xf0103ecb,(%esp)
f0100a50:	e8 b4 21 00 00       	call   f0102c09 <cprintf>
        cprintf("         set the background color to black\n");
f0100a55:	c7 04 24 fc 42 10 f0 	movl   $0xf01042fc,(%esp)
f0100a5c:	e8 a8 21 00 00       	call   f0102c09 <cprintf>
        cprintf("         set the foreground color to intense white\n");
f0100a61:	c7 04 24 28 43 10 f0 	movl   $0xf0104328,(%esp)
f0100a68:	e8 9c 21 00 00       	call   f0102c09 <cprintf>
f0100a6d:	83 c4 10             	add    $0x10,%esp
f0100a70:	eb 52                	jmp    f0100ac4 <mon_setcolor+0xc6>
    } else {
        int i, len;
        int colnum = 0;
        for (len = 0, i = strlen(argv[1]) - 1; i >= 0 && len < 8; len++, i--)
f0100a72:	83 ec 0c             	sub    $0xc,%esp
f0100a75:	ff 73 04             	pushl  0x4(%ebx)
f0100a78:	e8 f3 2a 00 00       	call   f0103570 <strlen>
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
f0100ab7:	68 5c 43 10 f0       	push   $0xf010435c
f0100abc:	e8 48 21 00 00       	call   f0102c09 <cprintf>
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
f0100af8:	68 80 43 10 f0       	push   $0xf0104380
f0100afd:	e8 07 21 00 00       	call   f0102c09 <cprintf>
        
        debuginfo_eip(*(ebp + 1), &eip_debug_info);
f0100b02:	83 c4 18             	add    $0x18,%esp
f0100b05:	57                   	push   %edi
f0100b06:	ff 76 04             	pushl  0x4(%esi)
f0100b09:	e8 37 22 00 00       	call   f0102d45 <debuginfo_eip>
        cprintf("        %s:%d: ", eip_debug_info.eip_file, eip_debug_info.eip_line);
f0100b0e:	83 c4 0c             	add    $0xc,%esp
f0100b11:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100b14:	ff 75 d0             	pushl  -0x30(%ebp)
f0100b17:	68 e7 3e 10 f0       	push   $0xf0103ee7
f0100b1c:	e8 e8 20 00 00       	call   f0102c09 <cprintf>
        cprintf("%.*s", eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name);
f0100b21:	83 c4 0c             	add    $0xc,%esp
f0100b24:	ff 75 d8             	pushl  -0x28(%ebp)
f0100b27:	ff 75 dc             	pushl  -0x24(%ebp)
f0100b2a:	68 f7 3e 10 f0       	push   $0xf0103ef7
f0100b2f:	e8 d5 20 00 00       	call   f0102c09 <cprintf>
        cprintf("+%u\n", (unsigned int)(eip - eip_debug_info.eip_fn_addr));
f0100b34:	83 c4 08             	add    $0x8,%esp
f0100b37:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f0100b3a:	53                   	push   %ebx
f0100b3b:	68 fc 3e 10 f0       	push   $0xf0103efc
f0100b40:	e8 c4 20 00 00       	call   f0102c09 <cprintf>
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
f0100b77:	68 b8 43 10 f0       	push   $0xf01043b8
f0100b7c:	68 92 00 00 00       	push   $0x92
f0100b81:	68 01 3f 10 f0       	push   $0xf0103f01
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
f0100bbb:	68 b8 43 10 f0       	push   $0xf01043b8
f0100bc0:	68 97 00 00 00       	push   $0x97
f0100bc5:	68 01 3f 10 f0       	push   $0xf0103f01
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
f0100c1d:	68 dc 43 10 f0       	push   $0xf01043dc
f0100c22:	e8 e2 1f 00 00       	call   f0102c09 <cprintf>
        cprintf("Example: dump v 0xf0000000 0xf0000010\n");
f0100c27:	c7 04 24 0c 44 10 f0 	movl   $0xf010440c,(%esp)
f0100c2e:	e8 d6 1f 00 00       	call   f0102c09 <cprintf>
        cprintf("         dump contents in virtual address [0xf0000000, 0xf0000010)\n");
f0100c33:	c7 04 24 34 44 10 f0 	movl   $0xf0104434,(%esp)
f0100c3a:	e8 ca 1f 00 00       	call   f0102c09 <cprintf>
f0100c3f:	83 c4 10             	add    $0x10,%esp
f0100c42:	e9 1f 01 00 00       	jmp    f0100d66 <mon_dump+0x15e>
    } else {
        uint32_t laddr = strtol(argv[2], NULL, 0);
f0100c47:	83 ec 04             	sub    $0x4,%esp
f0100c4a:	6a 00                	push   $0x0
f0100c4c:	6a 00                	push   $0x0
f0100c4e:	ff 76 08             	pushl  0x8(%esi)
f0100c51:	e8 1c 2c 00 00       	call   f0103872 <strtol>
f0100c56:	89 c3                	mov    %eax,%ebx
        uint32_t haddr = strtol(argv[3], NULL, 0);
f0100c58:	83 c4 0c             	add    $0xc,%esp
f0100c5b:	6a 00                	push   $0x0
f0100c5d:	6a 00                	push   $0x0
f0100c5f:	ff 76 0c             	pushl  0xc(%esi)
f0100c62:	e8 0b 2c 00 00       	call   f0103872 <strtol>
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
f0100c80:	74 0a                	je     f0100c8c <mon_dump+0x84>
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100c82:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100c85:	75 62                	jne    f0100ce9 <mon_dump+0xe1>
f0100c87:	e9 ca 00 00 00       	jmp    f0100d56 <mon_dump+0x14e>
        laddr = ROUNDDOWN(laddr, 4);
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            for (now = laddr; now != haddr; now += 4) {
f0100c8c:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0100c8f:	74 46                	je     f0100cd7 <mon_dump+0xcf>
f0100c91:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
f0100c93:	39 fb                	cmp    %edi,%ebx
f0100c95:	74 15                	je     f0100cac <mon_dump+0xa4>
f0100c97:	f6 c3 0f             	test   $0xf,%bl
f0100c9a:	75 21                	jne    f0100cbd <mon_dump+0xb5>
                    if (now != laddr) cprintf("\n");
f0100c9c:	83 ec 0c             	sub    $0xc,%esp
f0100c9f:	68 85 3e 10 f0       	push   $0xf0103e85
f0100ca4:	e8 60 1f 00 00       	call   f0102c09 <cprintf>
f0100ca9:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100cac:	83 ec 08             	sub    $0x8,%esp
f0100caf:	53                   	push   %ebx
f0100cb0:	68 10 3f 10 f0       	push   $0xf0103f10
f0100cb5:	e8 4f 1f 00 00       	call   f0102c09 <cprintf>
f0100cba:	83 c4 10             	add    $0x10,%esp
                }
                cprintf("0x%08x  ", *((uint32_t *)now));
f0100cbd:	83 ec 08             	sub    $0x8,%esp
f0100cc0:	ff 33                	pushl  (%ebx)
f0100cc2:	68 1a 3f 10 f0       	push   $0xf0103f1a
f0100cc7:	e8 3d 1f 00 00       	call   f0102c09 <cprintf>
        laddr = ROUNDDOWN(laddr, 4);
        haddr = ROUNDDOWN(haddr, 4);
        if (argv[1][0] == 'v') {
            // virtual address
            uint32_t now;
            for (now = laddr; now != haddr; now += 4) {
f0100ccc:	83 c3 04             	add    $0x4,%ebx
f0100ccf:	83 c4 10             	add    $0x10,%esp
f0100cd2:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100cd5:	75 bc                	jne    f0100c93 <mon_dump+0x8b>
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                cprintf("0x%08x  ", *((uint32_t *)now));
            }
            cprintf("\n");
f0100cd7:	83 ec 0c             	sub    $0xc,%esp
f0100cda:	68 85 3e 10 f0       	push   $0xf0103e85
f0100cdf:	e8 25 1f 00 00       	call   f0102c09 <cprintf>
f0100ce4:	83 c4 10             	add    $0x10,%esp
f0100ce7:	eb 7d                	jmp    f0100d66 <mon_dump+0x15e>
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100ce9:	89 fb                	mov    %edi,%ebx
                if (now == laddr || ((now & 0xf) == 0)) {
                    if (now != laddr) cprintf("\n");
                    cprintf("0x%08x:  ", now);
                }
                if (pa_con(now, &value)) {
f0100ceb:	8d 75 e4             	lea    -0x1c(%ebp),%esi
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
                if (now == laddr || ((now & 0xf) == 0)) {
f0100cee:	39 fb                	cmp    %edi,%ebx
f0100cf0:	74 15                	je     f0100d07 <mon_dump+0xff>
f0100cf2:	f6 c3 0f             	test   $0xf,%bl
f0100cf5:	75 21                	jne    f0100d18 <mon_dump+0x110>
                    if (now != laddr) cprintf("\n");
f0100cf7:	83 ec 0c             	sub    $0xc,%esp
f0100cfa:	68 85 3e 10 f0       	push   $0xf0103e85
f0100cff:	e8 05 1f 00 00       	call   f0102c09 <cprintf>
f0100d04:	83 c4 10             	add    $0x10,%esp
                    cprintf("0x%08x:  ", now);
f0100d07:	83 ec 08             	sub    $0x8,%esp
f0100d0a:	53                   	push   %ebx
f0100d0b:	68 10 3f 10 f0       	push   $0xf0103f10
f0100d10:	e8 f4 1e 00 00       	call   f0102c09 <cprintf>
f0100d15:	83 c4 10             	add    $0x10,%esp
                }
                if (pa_con(now, &value)) {
f0100d18:	83 ec 08             	sub    $0x8,%esp
f0100d1b:	56                   	push   %esi
f0100d1c:	53                   	push   %ebx
f0100d1d:	e8 39 fe ff ff       	call   f0100b5b <pa_con>
f0100d22:	83 c4 10             	add    $0x10,%esp
f0100d25:	84 c0                	test   %al,%al
f0100d27:	74 15                	je     f0100d3e <mon_dump+0x136>
                    cprintf("0x%08x  ", value);
f0100d29:	83 ec 08             	sub    $0x8,%esp
f0100d2c:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d2f:	68 1a 3f 10 f0       	push   $0xf0103f1a
f0100d34:	e8 d0 1e 00 00       	call   f0102c09 <cprintf>
f0100d39:	83 c4 10             	add    $0x10,%esp
f0100d3c:	eb 10                	jmp    f0100d4e <mon_dump+0x146>
                } else
                    cprintf("----------  ");
f0100d3e:	83 ec 0c             	sub    $0xc,%esp
f0100d41:	68 23 3f 10 f0       	push   $0xf0103f23
f0100d46:	e8 be 1e 00 00       	call   f0102c09 <cprintf>
f0100d4b:	83 c4 10             	add    $0x10,%esp
            }
            cprintf("\n");
        } else {
            // physical address
            uint32_t now, value;
            for (now = laddr; now != haddr; now += 4) {
f0100d4e:	83 c3 04             	add    $0x4,%ebx
f0100d51:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0100d54:	75 98                	jne    f0100cee <mon_dump+0xe6>
                if (pa_con(now, &value)) {
                    cprintf("0x%08x  ", value);
                } else
                    cprintf("----------  ");
            }
            cprintf("\n");
f0100d56:	83 ec 0c             	sub    $0xc,%esp
f0100d59:	68 85 3e 10 f0       	push   $0xf0103e85
f0100d5e:	e8 a6 1e 00 00       	call   f0102c09 <cprintf>
f0100d63:	83 c4 10             	add    $0x10,%esp
        }
    }
    return 0;
}
f0100d66:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d6e:	5b                   	pop    %ebx
f0100d6f:	5e                   	pop    %esi
f0100d70:	5f                   	pop    %edi
f0100d71:	c9                   	leave  
f0100d72:	c3                   	ret    

f0100d73 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100d73:	55                   	push   %ebp
f0100d74:	89 e5                	mov    %esp,%ebp
f0100d76:	57                   	push   %edi
f0100d77:	56                   	push   %esi
f0100d78:	53                   	push   %ebx
f0100d79:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100d7c:	68 78 44 10 f0       	push   $0xf0104478
f0100d81:	e8 83 1e 00 00       	call   f0102c09 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100d86:	c7 04 24 9c 44 10 f0 	movl   $0xf010449c,(%esp)
f0100d8d:	e8 77 1e 00 00       	call   f0102c09 <cprintf>
f0100d92:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100d95:	83 ec 0c             	sub    $0xc,%esp
f0100d98:	68 30 3f 10 f0       	push   $0xf0103f30
f0100d9d:	e8 fe 26 00 00       	call   f01034a0 <readline>
f0100da2:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100da4:	83 c4 10             	add    $0x10,%esp
f0100da7:	85 c0                	test   %eax,%eax
f0100da9:	74 ea                	je     f0100d95 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100dab:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100db2:	be 00 00 00 00       	mov    $0x0,%esi
f0100db7:	eb 04                	jmp    f0100dbd <monitor+0x4a>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100db9:	c6 03 00             	movb   $0x0,(%ebx)
f0100dbc:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100dbd:	8a 03                	mov    (%ebx),%al
f0100dbf:	84 c0                	test   %al,%al
f0100dc1:	74 64                	je     f0100e27 <monitor+0xb4>
f0100dc3:	83 ec 08             	sub    $0x8,%esp
f0100dc6:	0f be c0             	movsbl %al,%eax
f0100dc9:	50                   	push   %eax
f0100dca:	68 34 3f 10 f0       	push   $0xf0103f34
f0100dcf:	e8 15 29 00 00       	call   f01036e9 <strchr>
f0100dd4:	83 c4 10             	add    $0x10,%esp
f0100dd7:	85 c0                	test   %eax,%eax
f0100dd9:	75 de                	jne    f0100db9 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100ddb:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100dde:	74 47                	je     f0100e27 <monitor+0xb4>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100de0:	83 fe 0f             	cmp    $0xf,%esi
f0100de3:	75 14                	jne    f0100df9 <monitor+0x86>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100de5:	83 ec 08             	sub    $0x8,%esp
f0100de8:	6a 10                	push   $0x10
f0100dea:	68 39 3f 10 f0       	push   $0xf0103f39
f0100def:	e8 15 1e 00 00       	call   f0102c09 <cprintf>
f0100df4:	83 c4 10             	add    $0x10,%esp
f0100df7:	eb 9c                	jmp    f0100d95 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100df9:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100dfd:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100dfe:	8a 03                	mov    (%ebx),%al
f0100e00:	84 c0                	test   %al,%al
f0100e02:	75 09                	jne    f0100e0d <monitor+0x9a>
f0100e04:	eb b7                	jmp    f0100dbd <monitor+0x4a>
			buf++;
f0100e06:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e07:	8a 03                	mov    (%ebx),%al
f0100e09:	84 c0                	test   %al,%al
f0100e0b:	74 b0                	je     f0100dbd <monitor+0x4a>
f0100e0d:	83 ec 08             	sub    $0x8,%esp
f0100e10:	0f be c0             	movsbl %al,%eax
f0100e13:	50                   	push   %eax
f0100e14:	68 34 3f 10 f0       	push   $0xf0103f34
f0100e19:	e8 cb 28 00 00       	call   f01036e9 <strchr>
f0100e1e:	83 c4 10             	add    $0x10,%esp
f0100e21:	85 c0                	test   %eax,%eax
f0100e23:	74 e1                	je     f0100e06 <monitor+0x93>
f0100e25:	eb 96                	jmp    f0100dbd <monitor+0x4a>
			buf++;
	}
	argv[argc] = 0;
f0100e27:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100e2e:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100e2f:	85 f6                	test   %esi,%esi
f0100e31:	0f 84 5e ff ff ff    	je     f0100d95 <monitor+0x22>
f0100e37:	bb 20 45 10 f0       	mov    $0xf0104520,%ebx
f0100e3c:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100e41:	83 ec 08             	sub    $0x8,%esp
f0100e44:	ff 33                	pushl  (%ebx)
f0100e46:	ff 75 a8             	pushl  -0x58(%ebp)
f0100e49:	e8 2d 28 00 00       	call   f010367b <strcmp>
f0100e4e:	83 c4 10             	add    $0x10,%esp
f0100e51:	85 c0                	test   %eax,%eax
f0100e53:	75 20                	jne    f0100e75 <monitor+0x102>
			return commands[i].func(argc, argv, tf);
f0100e55:	83 ec 04             	sub    $0x4,%esp
f0100e58:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100e5b:	ff 75 08             	pushl  0x8(%ebp)
f0100e5e:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100e61:	50                   	push   %eax
f0100e62:	56                   	push   %esi
f0100e63:	ff 97 28 45 10 f0    	call   *-0xfefbad8(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100e69:	83 c4 10             	add    $0x10,%esp
f0100e6c:	85 c0                	test   %eax,%eax
f0100e6e:	78 26                	js     f0100e96 <monitor+0x123>
f0100e70:	e9 20 ff ff ff       	jmp    f0100d95 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100e75:	47                   	inc    %edi
f0100e76:	83 c3 0c             	add    $0xc,%ebx
f0100e79:	83 ff 07             	cmp    $0x7,%edi
f0100e7c:	75 c3                	jne    f0100e41 <monitor+0xce>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100e7e:	83 ec 08             	sub    $0x8,%esp
f0100e81:	ff 75 a8             	pushl  -0x58(%ebp)
f0100e84:	68 56 3f 10 f0       	push   $0xf0103f56
f0100e89:	e8 7b 1d 00 00       	call   f0102c09 <cprintf>
f0100e8e:	83 c4 10             	add    $0x10,%esp
f0100e91:	e9 ff fe ff ff       	jmp    f0100d95 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100e96:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e99:	5b                   	pop    %ebx
f0100e9a:	5e                   	pop    %esi
f0100e9b:	5f                   	pop    %edi
f0100e9c:	c9                   	leave  
f0100e9d:	c3                   	ret    
	...

f0100ea0 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ea0:	55                   	push   %ebp
f0100ea1:	89 e5                	mov    %esp,%ebp
f0100ea3:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ea5:	83 3d 30 e5 11 f0 00 	cmpl   $0x0,0xf011e530
f0100eac:	75 0f                	jne    f0100ebd <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100eae:	b8 4f f9 11 f0       	mov    $0xf011f94f,%eax
f0100eb3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100eb8:	a3 30 e5 11 f0       	mov    %eax,0xf011e530
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0100ebd:	a1 30 e5 11 f0       	mov    0xf011e530,%eax
    nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100ec2:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100ec9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ecf:	89 15 30 e5 11 f0    	mov    %edx,0xf011e530

	return result;
}
f0100ed5:	c9                   	leave  
f0100ed6:	c3                   	ret    

f0100ed7 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ed7:	55                   	push   %ebp
f0100ed8:	89 e5                	mov    %esp,%ebp
f0100eda:	83 ec 08             	sub    $0x8,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100edd:	89 d1                	mov    %edx,%ecx
f0100edf:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ee2:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ee5:	a8 01                	test   $0x1,%al
f0100ee7:	74 42                	je     f0100f2b <check_va2pa+0x54>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ee9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100eee:	89 c1                	mov    %eax,%ecx
f0100ef0:	c1 e9 0c             	shr    $0xc,%ecx
f0100ef3:	3b 0d 44 e9 11 f0    	cmp    0xf011e944,%ecx
f0100ef9:	72 15                	jb     f0100f10 <check_va2pa+0x39>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100efb:	50                   	push   %eax
f0100efc:	68 74 45 10 f0       	push   $0xf0104574
f0100f01:	68 c4 02 00 00       	push   $0x2c4
f0100f06:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0100f0b:	e8 7b f1 ff ff       	call   f010008b <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100f10:	c1 ea 0c             	shr    $0xc,%edx
f0100f13:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100f19:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100f20:	a8 01                	test   $0x1,%al
f0100f22:	74 0e                	je     f0100f32 <check_va2pa+0x5b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100f24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f29:	eb 0c                	jmp    f0100f37 <check_va2pa+0x60>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100f2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f30:	eb 05                	jmp    f0100f37 <check_va2pa+0x60>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100f32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100f37:	c9                   	leave  
f0100f38:	c3                   	ret    

f0100f39 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100f39:	55                   	push   %ebp
f0100f3a:	89 e5                	mov    %esp,%ebp
f0100f3c:	56                   	push   %esi
f0100f3d:	53                   	push   %ebx
f0100f3e:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100f40:	83 ec 0c             	sub    $0xc,%esp
f0100f43:	50                   	push   %eax
f0100f44:	e8 5f 1c 00 00       	call   f0102ba8 <mc146818_read>
f0100f49:	89 c6                	mov    %eax,%esi
f0100f4b:	43                   	inc    %ebx
f0100f4c:	89 1c 24             	mov    %ebx,(%esp)
f0100f4f:	e8 54 1c 00 00       	call   f0102ba8 <mc146818_read>
f0100f54:	c1 e0 08             	shl    $0x8,%eax
f0100f57:	09 f0                	or     %esi,%eax
}
f0100f59:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f5c:	5b                   	pop    %ebx
f0100f5d:	5e                   	pop    %esi
f0100f5e:	c9                   	leave  
f0100f5f:	c3                   	ret    

f0100f60 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100f60:	55                   	push   %ebp
f0100f61:	89 e5                	mov    %esp,%ebp
f0100f63:	57                   	push   %edi
f0100f64:	56                   	push   %esi
f0100f65:	53                   	push   %ebx
f0100f66:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f69:	3c 01                	cmp    $0x1,%al
f0100f6b:	19 f6                	sbb    %esi,%esi
f0100f6d:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100f73:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100f74:	8b 1d 2c e5 11 f0    	mov    0xf011e52c,%ebx
f0100f7a:	85 db                	test   %ebx,%ebx
f0100f7c:	75 17                	jne    f0100f95 <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f0100f7e:	83 ec 04             	sub    $0x4,%esp
f0100f81:	68 98 45 10 f0       	push   $0xf0104598
f0100f86:	68 07 02 00 00       	push   $0x207
f0100f8b:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0100f90:	e8 f6 f0 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
f0100f95:	84 c0                	test   %al,%al
f0100f97:	74 50                	je     f0100fe9 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100f99:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100f9c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f9f:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100fa2:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fa5:	89 d8                	mov    %ebx,%eax
f0100fa7:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f0100fad:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100fb0:	c1 e8 16             	shr    $0x16,%eax
f0100fb3:	39 c6                	cmp    %eax,%esi
f0100fb5:	0f 96 c0             	setbe  %al
f0100fb8:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100fbb:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0100fbf:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100fc1:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fc5:	8b 1b                	mov    (%ebx),%ebx
f0100fc7:	85 db                	test   %ebx,%ebx
f0100fc9:	75 da                	jne    f0100fa5 <check_page_free_list+0x45>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100fcb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100fce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100fd4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100fd7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100fda:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100fdc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fdf:	89 1d 2c e5 11 f0    	mov    %ebx,0xf011e52c
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100fe5:	85 db                	test   %ebx,%ebx
f0100fe7:	74 57                	je     f0101040 <check_page_free_list+0xe0>
f0100fe9:	89 d8                	mov    %ebx,%eax
f0100feb:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f0100ff1:	c1 f8 03             	sar    $0x3,%eax
f0100ff4:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ff7:	89 c2                	mov    %eax,%edx
f0100ff9:	c1 ea 16             	shr    $0x16,%edx
f0100ffc:	39 d6                	cmp    %edx,%esi
f0100ffe:	76 3a                	jbe    f010103a <check_page_free_list+0xda>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101000:	89 c2                	mov    %eax,%edx
f0101002:	c1 ea 0c             	shr    $0xc,%edx
f0101005:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f010100b:	72 12                	jb     f010101f <check_page_free_list+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010100d:	50                   	push   %eax
f010100e:	68 74 45 10 f0       	push   $0xf0104574
f0101013:	6a 52                	push   $0x52
f0101015:	68 78 4c 10 f0       	push   $0xf0104c78
f010101a:	e8 6c f0 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f010101f:	83 ec 04             	sub    $0x4,%esp
f0101022:	68 80 00 00 00       	push   $0x80
f0101027:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f010102c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101031:	50                   	push   %eax
f0101032:	e8 02 27 00 00       	call   f0103739 <memset>
f0101037:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010103a:	8b 1b                	mov    (%ebx),%ebx
f010103c:	85 db                	test   %ebx,%ebx
f010103e:	75 a9                	jne    f0100fe9 <check_page_free_list+0x89>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101040:	b8 00 00 00 00       	mov    $0x0,%eax
f0101045:	e8 56 fe ff ff       	call   f0100ea0 <boot_alloc>
f010104a:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010104d:	8b 15 2c e5 11 f0    	mov    0xf011e52c,%edx
f0101053:	85 d2                	test   %edx,%edx
f0101055:	0f 84 80 01 00 00    	je     f01011db <check_page_free_list+0x27b>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010105b:	8b 1d 4c e9 11 f0    	mov    0xf011e94c,%ebx
f0101061:	39 da                	cmp    %ebx,%edx
f0101063:	72 43                	jb     f01010a8 <check_page_free_list+0x148>
		assert(pp < pages + npages);
f0101065:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f010106a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010106d:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101070:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101073:	39 c2                	cmp    %eax,%edx
f0101075:	73 4f                	jae    f01010c6 <check_page_free_list+0x166>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101077:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010107a:	89 d0                	mov    %edx,%eax
f010107c:	29 d8                	sub    %ebx,%eax
f010107e:	a8 07                	test   $0x7,%al
f0101080:	75 66                	jne    f01010e8 <check_page_free_list+0x188>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101082:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101085:	c1 e0 0c             	shl    $0xc,%eax
f0101088:	74 7f                	je     f0101109 <check_page_free_list+0x1a9>
		assert(page2pa(pp) != IOPHYSMEM);
f010108a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010108f:	0f 84 94 00 00 00    	je     f0101129 <check_page_free_list+0x1c9>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101095:	be 00 00 00 00       	mov    $0x0,%esi
f010109a:	bf 00 00 00 00       	mov    $0x0,%edi
f010109f:	e9 9e 00 00 00       	jmp    f0101142 <check_page_free_list+0x1e2>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01010a4:	39 da                	cmp    %ebx,%edx
f01010a6:	73 19                	jae    f01010c1 <check_page_free_list+0x161>
f01010a8:	68 86 4c 10 f0       	push   $0xf0104c86
f01010ad:	68 92 4c 10 f0       	push   $0xf0104c92
f01010b2:	68 21 02 00 00       	push   $0x221
f01010b7:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01010bc:	e8 ca ef ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f01010c1:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01010c4:	72 19                	jb     f01010df <check_page_free_list+0x17f>
f01010c6:	68 a7 4c 10 f0       	push   $0xf0104ca7
f01010cb:	68 92 4c 10 f0       	push   $0xf0104c92
f01010d0:	68 22 02 00 00       	push   $0x222
f01010d5:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01010da:	e8 ac ef ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010df:	89 d0                	mov    %edx,%eax
f01010e1:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01010e4:	a8 07                	test   $0x7,%al
f01010e6:	74 19                	je     f0101101 <check_page_free_list+0x1a1>
f01010e8:	68 bc 45 10 f0       	push   $0xf01045bc
f01010ed:	68 92 4c 10 f0       	push   $0xf0104c92
f01010f2:	68 23 02 00 00       	push   $0x223
f01010f7:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01010fc:	e8 8a ef ff ff       	call   f010008b <_panic>
f0101101:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101104:	c1 e0 0c             	shl    $0xc,%eax
f0101107:	75 19                	jne    f0101122 <check_page_free_list+0x1c2>
f0101109:	68 bb 4c 10 f0       	push   $0xf0104cbb
f010110e:	68 92 4c 10 f0       	push   $0xf0104c92
f0101113:	68 26 02 00 00       	push   $0x226
f0101118:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010111d:	e8 69 ef ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101122:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101127:	75 19                	jne    f0101142 <check_page_free_list+0x1e2>
f0101129:	68 cc 4c 10 f0       	push   $0xf0104ccc
f010112e:	68 92 4c 10 f0       	push   $0xf0104c92
f0101133:	68 27 02 00 00       	push   $0x227
f0101138:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010113d:	e8 49 ef ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101142:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101147:	75 19                	jne    f0101162 <check_page_free_list+0x202>
f0101149:	68 f0 45 10 f0       	push   $0xf01045f0
f010114e:	68 92 4c 10 f0       	push   $0xf0104c92
f0101153:	68 28 02 00 00       	push   $0x228
f0101158:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010115d:	e8 29 ef ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101162:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101167:	75 19                	jne    f0101182 <check_page_free_list+0x222>
f0101169:	68 e5 4c 10 f0       	push   $0xf0104ce5
f010116e:	68 92 4c 10 f0       	push   $0xf0104c92
f0101173:	68 29 02 00 00       	push   $0x229
f0101178:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010117d:	e8 09 ef ff ff       	call   f010008b <_panic>
f0101182:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101184:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101189:	76 3e                	jbe    f01011c9 <check_page_free_list+0x269>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010118b:	c1 e8 0c             	shr    $0xc,%eax
f010118e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101191:	77 12                	ja     f01011a5 <check_page_free_list+0x245>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101193:	51                   	push   %ecx
f0101194:	68 74 45 10 f0       	push   $0xf0104574
f0101199:	6a 52                	push   $0x52
f010119b:	68 78 4c 10 f0       	push   $0xf0104c78
f01011a0:	e8 e6 ee ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f01011a5:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f01011ab:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01011ae:	76 1c                	jbe    f01011cc <check_page_free_list+0x26c>
f01011b0:	68 14 46 10 f0       	push   $0xf0104614
f01011b5:	68 92 4c 10 f0       	push   $0xf0104c92
f01011ba:	68 2a 02 00 00       	push   $0x22a
f01011bf:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01011c4:	e8 c2 ee ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f01011c9:	47                   	inc    %edi
f01011ca:	eb 01                	jmp    f01011cd <check_page_free_list+0x26d>
		else
			++nfree_extmem;
f01011cc:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011cd:	8b 12                	mov    (%edx),%edx
f01011cf:	85 d2                	test   %edx,%edx
f01011d1:	0f 85 cd fe ff ff    	jne    f01010a4 <check_page_free_list+0x144>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01011d7:	85 ff                	test   %edi,%edi
f01011d9:	7f 19                	jg     f01011f4 <check_page_free_list+0x294>
f01011db:	68 ff 4c 10 f0       	push   $0xf0104cff
f01011e0:	68 92 4c 10 f0       	push   $0xf0104c92
f01011e5:	68 32 02 00 00       	push   $0x232
f01011ea:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01011ef:	e8 97 ee ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f01011f4:	85 f6                	test   %esi,%esi
f01011f6:	7f 19                	jg     f0101211 <check_page_free_list+0x2b1>
f01011f8:	68 11 4d 10 f0       	push   $0xf0104d11
f01011fd:	68 92 4c 10 f0       	push   $0xf0104c92
f0101202:	68 33 02 00 00       	push   $0x233
f0101207:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010120c:	e8 7a ee ff ff       	call   f010008b <_panic>
}
f0101211:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101214:	5b                   	pop    %ebx
f0101215:	5e                   	pop    %esi
f0101216:	5f                   	pop    %edi
f0101217:	c9                   	leave  
f0101218:	c3                   	ret    

f0101219 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101219:	55                   	push   %ebp
f010121a:	89 e5                	mov    %esp,%ebp
f010121c:	56                   	push   %esi
f010121d:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    page_free_list = NULL;
f010121e:	c7 05 2c e5 11 f0 00 	movl   $0x0,0xf011e52c
f0101225:	00 00 00 
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
f0101228:	b8 00 00 00 00       	mov    $0x0,%eax
f010122d:	e8 6e fc ff ff       	call   f0100ea0 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101232:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101237:	77 15                	ja     f010124e <page_init+0x35>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101239:	50                   	push   %eax
f010123a:	68 b8 43 10 f0       	push   $0xf01043b8
f010123f:	68 10 01 00 00       	push   $0x110
f0101244:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101249:	e8 3d ee ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f010124e:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f0101254:	c1 ee 0c             	shr    $0xc,%esi
    for (i = 0; i < npages; i++) {
f0101257:	83 3d 44 e9 11 f0 00 	cmpl   $0x0,0xf011e944
f010125e:	74 5f                	je     f01012bf <page_init+0xa6>
f0101260:	8b 1d 2c e5 11 f0    	mov    0xf011e52c,%ebx
f0101266:	ba 00 00 00 00       	mov    $0x0,%edx
f010126b:	b8 00 00 00 00       	mov    $0x0,%eax
        if (i != 0 && (i < nf_lb || i >= nf_ub)) {
f0101270:	85 c0                	test   %eax,%eax
f0101272:	74 25                	je     f0101299 <page_init+0x80>
f0101274:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0101279:	76 04                	jbe    f010127f <page_init+0x66>
f010127b:	39 c6                	cmp    %eax,%esi
f010127d:	77 1a                	ja     f0101299 <page_init+0x80>
		    pages[i].pp_ref = 0;
f010127f:	89 d1                	mov    %edx,%ecx
f0101281:	03 0d 4c e9 11 f0    	add    0xf011e94c,%ecx
f0101287:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
            pages[i].pp_link = page_free_list;
f010128d:	89 19                	mov    %ebx,(%ecx)
		    page_free_list = &pages[i];
f010128f:	89 d3                	mov    %edx,%ebx
f0101291:	03 1d 4c e9 11 f0    	add    0xf011e94c,%ebx
f0101297:	eb 14                	jmp    f01012ad <page_init+0x94>
        } else {
            pages[i].pp_ref = 1;
f0101299:	89 d1                	mov    %edx,%ecx
f010129b:	03 0d 4c e9 11 f0    	add    0xf011e94c,%ecx
f01012a1:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f01012a7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	// free pages!
    page_free_list = NULL;
    size_t i;
	size_t nf_lb = IOPHYSMEM / PGSIZE;
    size_t nf_ub = PADDR(boot_alloc(0)) / PGSIZE;
    for (i = 0; i < npages; i++) {
f01012ad:	40                   	inc    %eax
f01012ae:	83 c2 08             	add    $0x8,%edx
f01012b1:	39 05 44 e9 11 f0    	cmp    %eax,0xf011e944
f01012b7:	77 b7                	ja     f0101270 <page_init+0x57>
f01012b9:	89 1d 2c e5 11 f0    	mov    %ebx,0xf011e52c
        } else {
            pages[i].pp_ref = 1;
            pages[i].pp_link = NULL;
        }
	}
}
f01012bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012c2:	5b                   	pop    %ebx
f01012c3:	5e                   	pop    %esi
f01012c4:	c9                   	leave  
f01012c5:	c3                   	ret    

f01012c6 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01012c6:	55                   	push   %ebp
f01012c7:	89 e5                	mov    %esp,%ebp
f01012c9:	53                   	push   %ebx
f01012ca:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f01012cd:	8b 1d 2c e5 11 f0    	mov    0xf011e52c,%ebx
f01012d3:	85 db                	test   %ebx,%ebx
f01012d5:	74 63                	je     f010133a <page_alloc+0x74>
f01012d7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01012dc:	74 63                	je     f0101341 <page_alloc+0x7b>
        page_free_list = page_free_list->pp_link;
f01012de:	8b 1b                	mov    (%ebx),%ebx
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in

    while (page_free_list && page_free_list->pp_ref != 0) 
f01012e0:	85 db                	test   %ebx,%ebx
f01012e2:	75 08                	jne    f01012ec <page_alloc+0x26>
f01012e4:	89 1d 2c e5 11 f0    	mov    %ebx,0xf011e52c
f01012ea:	eb 4e                	jmp    f010133a <page_alloc+0x74>
f01012ec:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01012f1:	75 eb                	jne    f01012de <page_alloc+0x18>
f01012f3:	eb 4c                	jmp    f0101341 <page_alloc+0x7b>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012f5:	89 d8                	mov    %ebx,%eax
f01012f7:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f01012fd:	c1 f8 03             	sar    $0x3,%eax
f0101300:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101303:	89 c2                	mov    %eax,%edx
f0101305:	c1 ea 0c             	shr    $0xc,%edx
f0101308:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f010130e:	72 12                	jb     f0101322 <page_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101310:	50                   	push   %eax
f0101311:	68 74 45 10 f0       	push   $0xf0104574
f0101316:	6a 52                	push   $0x52
f0101318:	68 78 4c 10 f0       	push   $0xf0104c78
f010131d:	e8 69 ed ff ff       	call   f010008b <_panic>
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
        if (alloc_flags & ALLOC_ZERO) {
            memset(page2kva(alloc_page), 0, PGSIZE);
f0101322:	83 ec 04             	sub    $0x4,%esp
f0101325:	68 00 10 00 00       	push   $0x1000
f010132a:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010132c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101331:	50                   	push   %eax
f0101332:	e8 02 24 00 00       	call   f0103739 <memset>
f0101337:	83 c4 10             	add    $0x10,%esp
        }
        return alloc_page;
    }
}
f010133a:	89 d8                	mov    %ebx,%eax
f010133c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010133f:	c9                   	leave  
f0101340:	c3                   	ret    
        page_free_list = page_free_list->pp_link;
    if (page_free_list == NULL) {
        return NULL;
    } else {
        struct PageInfo * alloc_page = page_free_list;
        page_free_list = page_free_list->pp_link;
f0101341:	8b 03                	mov    (%ebx),%eax
f0101343:	a3 2c e5 11 f0       	mov    %eax,0xf011e52c
        if (alloc_flags & ALLOC_ZERO) {
f0101348:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010134c:	74 ec                	je     f010133a <page_alloc+0x74>
f010134e:	eb a5                	jmp    f01012f5 <page_alloc+0x2f>

f0101350 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101350:	55                   	push   %ebp
f0101351:	89 e5                	mov    %esp,%ebp
f0101353:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
    if (pp == NULL || pp->pp_ref != 0) return;
f0101356:	85 c0                	test   %eax,%eax
f0101358:	74 14                	je     f010136e <page_free+0x1e>
f010135a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010135f:	75 0d                	jne    f010136e <page_free+0x1e>
    pp->pp_link = page_free_list;
f0101361:	8b 15 2c e5 11 f0    	mov    0xf011e52c,%edx
f0101367:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0101369:	a3 2c e5 11 f0       	mov    %eax,0xf011e52c
}
f010136e:	c9                   	leave  
f010136f:	c3                   	ret    

f0101370 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101370:	55                   	push   %ebp
f0101371:	89 e5                	mov    %esp,%ebp
f0101373:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101376:	8b 50 04             	mov    0x4(%eax),%edx
f0101379:	4a                   	dec    %edx
f010137a:	66 89 50 04          	mov    %dx,0x4(%eax)
f010137e:	66 85 d2             	test   %dx,%dx
f0101381:	75 09                	jne    f010138c <page_decref+0x1c>
		page_free(pp);
f0101383:	50                   	push   %eax
f0101384:	e8 c7 ff ff ff       	call   f0101350 <page_free>
f0101389:	83 c4 04             	add    $0x4,%esp
}
f010138c:	c9                   	leave  
f010138d:	c3                   	ret    

f010138e <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010138e:	55                   	push   %ebp
f010138f:	89 e5                	mov    %esp,%ebp
f0101391:	56                   	push   %esi
f0101392:	53                   	push   %ebx
f0101393:	8b 75 0c             	mov    0xc(%ebp),%esi
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
f0101396:	89 f3                	mov    %esi,%ebx
f0101398:	c1 eb 16             	shr    $0x16,%ebx
f010139b:	c1 e3 02             	shl    $0x2,%ebx
f010139e:	03 5d 08             	add    0x8(%ebp),%ebx
f01013a1:	8b 03                	mov    (%ebx),%eax
f01013a3:	85 c0                	test   %eax,%eax
f01013a5:	74 04                	je     f01013ab <pgdir_walk+0x1d>
f01013a7:	a8 01                	test   $0x1,%al
f01013a9:	75 2c                	jne    f01013d7 <pgdir_walk+0x49>
        // page table is not exist
        if (create == false) return NULL;
f01013ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01013af:	74 61                	je     f0101412 <pgdir_walk+0x84>
        struct PageInfo * new_page = page_alloc(1);
f01013b1:	83 ec 0c             	sub    $0xc,%esp
f01013b4:	6a 01                	push   $0x1
f01013b6:	e8 0b ff ff ff       	call   f01012c6 <page_alloc>
        if (new_page == NULL) return NULL;      // allocation fails
f01013bb:	83 c4 10             	add    $0x10,%esp
f01013be:	85 c0                	test   %eax,%eax
f01013c0:	74 57                	je     f0101419 <pgdir_walk+0x8b>
        ++new_page->pp_ref;
f01013c2:	66 ff 40 04          	incw   0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013c6:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f01013cc:	c1 f8 03             	sar    $0x3,%eax
f01013cf:	c1 e0 0c             	shl    $0xc,%eax
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
f01013d2:	83 c8 07             	or     $0x7,%eax
f01013d5:	89 03                	mov    %eax,(%ebx)
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
f01013d7:	8b 03                	mov    (%ebx),%eax
f01013d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013de:	89 c2                	mov    %eax,%edx
f01013e0:	c1 ea 0c             	shr    $0xc,%edx
f01013e3:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f01013e9:	72 15                	jb     f0101400 <pgdir_walk+0x72>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013eb:	50                   	push   %eax
f01013ec:	68 74 45 10 f0       	push   $0xf0104574
f01013f1:	68 73 01 00 00       	push   $0x173
f01013f6:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01013fb:	e8 8b ec ff ff       	call   f010008b <_panic>
f0101400:	c1 ee 0a             	shr    $0xa,%esi
f0101403:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101409:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101410:	eb 0c                	jmp    f010141e <pgdir_walk+0x90>
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    // cprintf("pgdir_walk\n");
    if (pgdir[PDX(va)] == 0 || (pgdir[PDX(va)] & PTE_P) == 0) {
        // page table is not exist
        if (create == false) return NULL;
f0101412:	b8 00 00 00 00       	mov    $0x0,%eax
f0101417:	eb 05                	jmp    f010141e <pgdir_walk+0x90>
        struct PageInfo * new_page = page_alloc(1);
        if (new_page == NULL) return NULL;      // allocation fails
f0101419:	b8 00 00 00 00       	mov    $0x0,%eax
        ++new_page->pp_ref;
        pgdir[PDX(va)] = page2pa(new_page) | PTE_P | PTE_W | PTE_U;
    }
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
}
f010141e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101421:	5b                   	pop    %ebx
f0101422:	5e                   	pop    %esi
f0101423:	c9                   	leave  
f0101424:	c3                   	ret    

f0101425 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101425:	55                   	push   %ebp
f0101426:	89 e5                	mov    %esp,%ebp
f0101428:	57                   	push   %edi
f0101429:	56                   	push   %esi
f010142a:	53                   	push   %ebx
f010142b:	83 ec 1c             	sub    $0x1c,%esp
f010142e:	89 c7                	mov    %eax,%edi
f0101430:	8b 75 08             	mov    0x8(%ebp),%esi
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f0101433:	01 d1                	add    %edx,%ecx
f0101435:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101438:	39 ca                	cmp    %ecx,%edx
f010143a:	74 32                	je     f010146e <boot_map_region+0x49>
f010143c:	89 d3                	mov    %edx,%ebx
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f010143e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101441:	83 c8 01             	or     $0x1,%eax
f0101444:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
        pte = pgdir_walk(pgdir, (void *)va_now, true);
f0101447:	83 ec 04             	sub    $0x4,%esp
f010144a:	6a 01                	push   $0x1
f010144c:	53                   	push   %ebx
f010144d:	57                   	push   %edi
f010144e:	e8 3b ff ff ff       	call   f010138e <pgdir_walk>
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
f0101453:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101456:	09 f2                	or     %esi,%edx
f0101458:	89 10                	mov    %edx,(%eax)
{
    // cprintf("boot_map_region\n");
	// size is a multiple of PGSIZE
    uintptr_t va_now;
    pte_t * pte;
    for (va_now = va; va_now != va + size; va_now += PGSIZE, pa += PGSIZE) {
f010145a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101460:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101466:	83 c4 10             	add    $0x10,%esp
f0101469:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010146c:	75 d9                	jne    f0101447 <boot_map_region+0x22>
        pte = pgdir_walk(pgdir, (void *)va_now, true);
        // 20 PPN, 12 flag
        *pte = pa | PTE_P | perm;
    }
}
f010146e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101471:	5b                   	pop    %ebx
f0101472:	5e                   	pop    %esi
f0101473:	5f                   	pop    %edi
f0101474:	c9                   	leave  
f0101475:	c3                   	ret    

f0101476 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101476:	55                   	push   %ebp
f0101477:	89 e5                	mov    %esp,%ebp
f0101479:	53                   	push   %ebx
f010147a:	83 ec 08             	sub    $0x8,%esp
f010147d:	8b 5d 10             	mov    0x10(%ebp),%ebx
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f0101480:	6a 00                	push   $0x0
f0101482:	ff 75 0c             	pushl  0xc(%ebp)
f0101485:	ff 75 08             	pushl  0x8(%ebp)
f0101488:	e8 01 ff ff ff       	call   f010138e <pgdir_walk>
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f010148d:	83 c4 10             	add    $0x10,%esp
f0101490:	85 c0                	test   %eax,%eax
f0101492:	74 37                	je     f01014cb <page_lookup+0x55>
f0101494:	f6 00 01             	testb  $0x1,(%eax)
f0101497:	74 39                	je     f01014d2 <page_lookup+0x5c>
    if (pte_store != 0) {
f0101499:	85 db                	test   %ebx,%ebx
f010149b:	74 02                	je     f010149f <page_lookup+0x29>
        *pte_store = pte;
f010149d:	89 03                	mov    %eax,(%ebx)
    }
    return pa2page(PTE_ADDR(*pte));
f010149f:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014a1:	c1 e8 0c             	shr    $0xc,%eax
f01014a4:	3b 05 44 e9 11 f0    	cmp    0xf011e944,%eax
f01014aa:	72 14                	jb     f01014c0 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01014ac:	83 ec 04             	sub    $0x4,%esp
f01014af:	68 5c 46 10 f0       	push   $0xf010465c
f01014b4:	6a 4b                	push   $0x4b
f01014b6:	68 78 4c 10 f0       	push   $0xf0104c78
f01014bb:	e8 cb eb ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f01014c0:	c1 e0 03             	shl    $0x3,%eax
f01014c3:	03 05 4c e9 11 f0    	add    0xf011e94c,%eax
f01014c9:	eb 0c                	jmp    f01014d7 <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    // cprintf("page_lookup\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
    if (pte == NULL || (*pte & PTE_P) == 0) return NULL;   // no page mapped at va
f01014cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01014d0:	eb 05                	jmp    f01014d7 <page_lookup+0x61>
f01014d2:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pte_store != 0) {
        *pte_store = pte;
    }
    return pa2page(PTE_ADDR(*pte));
}
f01014d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014da:	c9                   	leave  
f01014db:	c3                   	ret    

f01014dc <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01014dc:	55                   	push   %ebp
f01014dd:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01014df:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014e2:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01014e5:	c9                   	leave  
f01014e6:	c3                   	ret    

f01014e7 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01014e7:	55                   	push   %ebp
f01014e8:	89 e5                	mov    %esp,%ebp
f01014ea:	56                   	push   %esi
f01014eb:	53                   	push   %ebx
f01014ec:	83 ec 14             	sub    $0x14,%esp
f01014ef:	8b 75 08             	mov    0x8(%ebp),%esi
f01014f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // cprintf("page_remove\n");
	// Fill this function in
    pte_t * pte;
    struct PageInfo * pg = page_lookup(pgdir, va, &pte);
f01014f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01014f8:	50                   	push   %eax
f01014f9:	53                   	push   %ebx
f01014fa:	56                   	push   %esi
f01014fb:	e8 76 ff ff ff       	call   f0101476 <page_lookup>
    if (pg == NULL) return;
f0101500:	83 c4 10             	add    $0x10,%esp
f0101503:	85 c0                	test   %eax,%eax
f0101505:	74 26                	je     f010152d <page_remove+0x46>
    page_decref(pg);
f0101507:	83 ec 0c             	sub    $0xc,%esp
f010150a:	50                   	push   %eax
f010150b:	e8 60 fe ff ff       	call   f0101370 <page_decref>
    if (pte != NULL) *pte = 0;
f0101510:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101513:	83 c4 10             	add    $0x10,%esp
f0101516:	85 c0                	test   %eax,%eax
f0101518:	74 06                	je     f0101520 <page_remove+0x39>
f010151a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va); 
f0101520:	83 ec 08             	sub    $0x8,%esp
f0101523:	53                   	push   %ebx
f0101524:	56                   	push   %esi
f0101525:	e8 b2 ff ff ff       	call   f01014dc <tlb_invalidate>
f010152a:	83 c4 10             	add    $0x10,%esp
}
f010152d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101530:	5b                   	pop    %ebx
f0101531:	5e                   	pop    %esi
f0101532:	c9                   	leave  
f0101533:	c3                   	ret    

f0101534 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101534:	55                   	push   %ebp
f0101535:	89 e5                	mov    %esp,%ebp
f0101537:	57                   	push   %edi
f0101538:	56                   	push   %esi
f0101539:	53                   	push   %ebx
f010153a:	83 ec 10             	sub    $0x10,%esp
f010153d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101540:	8b 7d 10             	mov    0x10(%ebp),%edi
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
f0101543:	6a 01                	push   $0x1
f0101545:	57                   	push   %edi
f0101546:	ff 75 08             	pushl  0x8(%ebp)
f0101549:	e8 40 fe ff ff       	call   f010138e <pgdir_walk>
f010154e:	89 c3                	mov    %eax,%ebx
    if (pte == NULL) return -E_NO_MEM;
f0101550:	83 c4 10             	add    $0x10,%esp
f0101553:	85 c0                	test   %eax,%eax
f0101555:	74 39                	je     f0101590 <page_insert+0x5c>
    ++pp->pp_ref;
f0101557:	66 ff 46 04          	incw   0x4(%esi)
    if (*pte & PTE_P) {
f010155b:	f6 00 01             	testb  $0x1,(%eax)
f010155e:	74 0f                	je     f010156f <page_insert+0x3b>
        page_remove(pgdir, va);
f0101560:	83 ec 08             	sub    $0x8,%esp
f0101563:	57                   	push   %edi
f0101564:	ff 75 08             	pushl  0x8(%ebp)
f0101567:	e8 7b ff ff ff       	call   f01014e7 <page_remove>
f010156c:	83 c4 10             	add    $0x10,%esp
    }
    *pte = page2pa(pp) | perm | PTE_P;        
f010156f:	8b 55 14             	mov    0x14(%ebp),%edx
f0101572:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101575:	2b 35 4c e9 11 f0    	sub    0xf011e94c,%esi
f010157b:	c1 fe 03             	sar    $0x3,%esi
f010157e:	89 f0                	mov    %esi,%eax
f0101580:	c1 e0 0c             	shl    $0xc,%eax
f0101583:	89 d6                	mov    %edx,%esi
f0101585:	09 c6                	or     %eax,%esi
f0101587:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101589:	b8 00 00 00 00       	mov    $0x0,%eax
f010158e:	eb 05                	jmp    f0101595 <page_insert+0x61>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    // cprintf("page_insert\n");
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, true);
    if (pte == NULL) return -E_NO_MEM;
f0101590:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (*pte & PTE_P) {
        page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;        
	return 0;
}
f0101595:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101598:	5b                   	pop    %ebx
f0101599:	5e                   	pop    %esi
f010159a:	5f                   	pop    %edi
f010159b:	c9                   	leave  
f010159c:	c3                   	ret    

f010159d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010159d:	55                   	push   %ebp
f010159e:	89 e5                	mov    %esp,%ebp
f01015a0:	57                   	push   %edi
f01015a1:	56                   	push   %esi
f01015a2:	53                   	push   %ebx
f01015a3:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01015a6:	b8 15 00 00 00       	mov    $0x15,%eax
f01015ab:	e8 89 f9 ff ff       	call   f0100f39 <nvram_read>
f01015b0:	c1 e0 0a             	shl    $0xa,%eax
f01015b3:	89 c2                	mov    %eax,%edx
f01015b5:	85 c0                	test   %eax,%eax
f01015b7:	79 06                	jns    f01015bf <mem_init+0x22>
f01015b9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01015bf:	c1 fa 0c             	sar    $0xc,%edx
f01015c2:	89 15 34 e5 11 f0    	mov    %edx,0xf011e534
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01015c8:	b8 17 00 00 00       	mov    $0x17,%eax
f01015cd:	e8 67 f9 ff ff       	call   f0100f39 <nvram_read>
f01015d2:	89 c2                	mov    %eax,%edx
f01015d4:	c1 e2 0a             	shl    $0xa,%edx
f01015d7:	89 d0                	mov    %edx,%eax
f01015d9:	85 d2                	test   %edx,%edx
f01015db:	79 06                	jns    f01015e3 <mem_init+0x46>
f01015dd:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01015e3:	c1 f8 0c             	sar    $0xc,%eax
f01015e6:	74 0e                	je     f01015f6 <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01015e8:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01015ee:	89 15 44 e9 11 f0    	mov    %edx,0xf011e944
f01015f4:	eb 0c                	jmp    f0101602 <mem_init+0x65>
	else
		npages = npages_basemem;
f01015f6:	8b 15 34 e5 11 f0    	mov    0xf011e534,%edx
f01015fc:	89 15 44 e9 11 f0    	mov    %edx,0xf011e944

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101602:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101605:	c1 e8 0a             	shr    $0xa,%eax
f0101608:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101609:	a1 34 e5 11 f0       	mov    0xf011e534,%eax
f010160e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101611:	c1 e8 0a             	shr    $0xa,%eax
f0101614:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0101615:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f010161a:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010161d:	c1 e8 0a             	shr    $0xa,%eax
f0101620:	50                   	push   %eax
f0101621:	68 7c 46 10 f0       	push   $0xf010467c
f0101626:	e8 de 15 00 00       	call   f0102c09 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010162b:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101630:	e8 6b f8 ff ff       	call   f0100ea0 <boot_alloc>
f0101635:	a3 48 e9 11 f0       	mov    %eax,0xf011e948
	memset(kern_pgdir, 0, PGSIZE);
f010163a:	83 c4 0c             	add    $0xc,%esp
f010163d:	68 00 10 00 00       	push   $0x1000
f0101642:	6a 00                	push   $0x0
f0101644:	50                   	push   %eax
f0101645:	e8 ef 20 00 00       	call   f0103739 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010164a:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010164f:	83 c4 10             	add    $0x10,%esp
f0101652:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101657:	77 15                	ja     f010166e <mem_init+0xd1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101659:	50                   	push   %eax
f010165a:	68 b8 43 10 f0       	push   $0xf01043b8
f010165f:	68 8d 00 00 00       	push   $0x8d
f0101664:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101669:	e8 1d ea ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f010166e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101674:	83 ca 05             	or     $0x5,%edx
f0101677:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f010167d:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f0101682:	c1 e0 03             	shl    $0x3,%eax
f0101685:	e8 16 f8 ff ff       	call   f0100ea0 <boot_alloc>
f010168a:	a3 4c e9 11 f0       	mov    %eax,0xf011e94c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010168f:	e8 85 fb ff ff       	call   f0101219 <page_init>

	check_page_free_list(1);
f0101694:	b8 01 00 00 00       	mov    $0x1,%eax
f0101699:	e8 c2 f8 ff ff       	call   f0100f60 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010169e:	83 3d 4c e9 11 f0 00 	cmpl   $0x0,0xf011e94c
f01016a5:	75 17                	jne    f01016be <mem_init+0x121>
		panic("'pages' is a null pointer!");
f01016a7:	83 ec 04             	sub    $0x4,%esp
f01016aa:	68 22 4d 10 f0       	push   $0xf0104d22
f01016af:	68 44 02 00 00       	push   $0x244
f01016b4:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01016b9:	e8 cd e9 ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016be:	a1 2c e5 11 f0       	mov    0xf011e52c,%eax
f01016c3:	85 c0                	test   %eax,%eax
f01016c5:	74 0e                	je     f01016d5 <mem_init+0x138>
f01016c7:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f01016cc:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016cd:	8b 00                	mov    (%eax),%eax
f01016cf:	85 c0                	test   %eax,%eax
f01016d1:	75 f9                	jne    f01016cc <mem_init+0x12f>
f01016d3:	eb 05                	jmp    f01016da <mem_init+0x13d>
f01016d5:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016da:	83 ec 0c             	sub    $0xc,%esp
f01016dd:	6a 00                	push   $0x0
f01016df:	e8 e2 fb ff ff       	call   f01012c6 <page_alloc>
f01016e4:	89 c6                	mov    %eax,%esi
f01016e6:	83 c4 10             	add    $0x10,%esp
f01016e9:	85 c0                	test   %eax,%eax
f01016eb:	75 19                	jne    f0101706 <mem_init+0x169>
f01016ed:	68 3d 4d 10 f0       	push   $0xf0104d3d
f01016f2:	68 92 4c 10 f0       	push   $0xf0104c92
f01016f7:	68 4c 02 00 00       	push   $0x24c
f01016fc:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101701:	e8 85 e9 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101706:	83 ec 0c             	sub    $0xc,%esp
f0101709:	6a 00                	push   $0x0
f010170b:	e8 b6 fb ff ff       	call   f01012c6 <page_alloc>
f0101710:	89 c7                	mov    %eax,%edi
f0101712:	83 c4 10             	add    $0x10,%esp
f0101715:	85 c0                	test   %eax,%eax
f0101717:	75 19                	jne    f0101732 <mem_init+0x195>
f0101719:	68 53 4d 10 f0       	push   $0xf0104d53
f010171e:	68 92 4c 10 f0       	push   $0xf0104c92
f0101723:	68 4d 02 00 00       	push   $0x24d
f0101728:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010172d:	e8 59 e9 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101732:	83 ec 0c             	sub    $0xc,%esp
f0101735:	6a 00                	push   $0x0
f0101737:	e8 8a fb ff ff       	call   f01012c6 <page_alloc>
f010173c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010173f:	83 c4 10             	add    $0x10,%esp
f0101742:	85 c0                	test   %eax,%eax
f0101744:	75 19                	jne    f010175f <mem_init+0x1c2>
f0101746:	68 69 4d 10 f0       	push   $0xf0104d69
f010174b:	68 92 4c 10 f0       	push   $0xf0104c92
f0101750:	68 4e 02 00 00       	push   $0x24e
f0101755:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010175a:	e8 2c e9 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010175f:	39 fe                	cmp    %edi,%esi
f0101761:	75 19                	jne    f010177c <mem_init+0x1df>
f0101763:	68 7f 4d 10 f0       	push   $0xf0104d7f
f0101768:	68 92 4c 10 f0       	push   $0xf0104c92
f010176d:	68 51 02 00 00       	push   $0x251
f0101772:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101777:	e8 0f e9 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010177c:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010177f:	74 05                	je     f0101786 <mem_init+0x1e9>
f0101781:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101784:	75 19                	jne    f010179f <mem_init+0x202>
f0101786:	68 b8 46 10 f0       	push   $0xf01046b8
f010178b:	68 92 4c 10 f0       	push   $0xf0104c92
f0101790:	68 52 02 00 00       	push   $0x252
f0101795:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010179a:	e8 ec e8 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010179f:	8b 15 4c e9 11 f0    	mov    0xf011e94c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01017a5:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f01017aa:	c1 e0 0c             	shl    $0xc,%eax
f01017ad:	89 f1                	mov    %esi,%ecx
f01017af:	29 d1                	sub    %edx,%ecx
f01017b1:	c1 f9 03             	sar    $0x3,%ecx
f01017b4:	c1 e1 0c             	shl    $0xc,%ecx
f01017b7:	39 c1                	cmp    %eax,%ecx
f01017b9:	72 19                	jb     f01017d4 <mem_init+0x237>
f01017bb:	68 91 4d 10 f0       	push   $0xf0104d91
f01017c0:	68 92 4c 10 f0       	push   $0xf0104c92
f01017c5:	68 53 02 00 00       	push   $0x253
f01017ca:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01017cf:	e8 b7 e8 ff ff       	call   f010008b <_panic>
f01017d4:	89 f9                	mov    %edi,%ecx
f01017d6:	29 d1                	sub    %edx,%ecx
f01017d8:	c1 f9 03             	sar    $0x3,%ecx
f01017db:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01017de:	39 c8                	cmp    %ecx,%eax
f01017e0:	77 19                	ja     f01017fb <mem_init+0x25e>
f01017e2:	68 ae 4d 10 f0       	push   $0xf0104dae
f01017e7:	68 92 4c 10 f0       	push   $0xf0104c92
f01017ec:	68 54 02 00 00       	push   $0x254
f01017f1:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01017f6:	e8 90 e8 ff ff       	call   f010008b <_panic>
f01017fb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01017fe:	29 d1                	sub    %edx,%ecx
f0101800:	89 ca                	mov    %ecx,%edx
f0101802:	c1 fa 03             	sar    $0x3,%edx
f0101805:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101808:	39 d0                	cmp    %edx,%eax
f010180a:	77 19                	ja     f0101825 <mem_init+0x288>
f010180c:	68 cb 4d 10 f0       	push   $0xf0104dcb
f0101811:	68 92 4c 10 f0       	push   $0xf0104c92
f0101816:	68 55 02 00 00       	push   $0x255
f010181b:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101820:	e8 66 e8 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101825:	a1 2c e5 11 f0       	mov    0xf011e52c,%eax
f010182a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010182d:	c7 05 2c e5 11 f0 00 	movl   $0x0,0xf011e52c
f0101834:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101837:	83 ec 0c             	sub    $0xc,%esp
f010183a:	6a 00                	push   $0x0
f010183c:	e8 85 fa ff ff       	call   f01012c6 <page_alloc>
f0101841:	83 c4 10             	add    $0x10,%esp
f0101844:	85 c0                	test   %eax,%eax
f0101846:	74 19                	je     f0101861 <mem_init+0x2c4>
f0101848:	68 e8 4d 10 f0       	push   $0xf0104de8
f010184d:	68 92 4c 10 f0       	push   $0xf0104c92
f0101852:	68 5c 02 00 00       	push   $0x25c
f0101857:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010185c:	e8 2a e8 ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101861:	83 ec 0c             	sub    $0xc,%esp
f0101864:	56                   	push   %esi
f0101865:	e8 e6 fa ff ff       	call   f0101350 <page_free>
	page_free(pp1);
f010186a:	89 3c 24             	mov    %edi,(%esp)
f010186d:	e8 de fa ff ff       	call   f0101350 <page_free>
	page_free(pp2);
f0101872:	83 c4 04             	add    $0x4,%esp
f0101875:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101878:	e8 d3 fa ff ff       	call   f0101350 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010187d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101884:	e8 3d fa ff ff       	call   f01012c6 <page_alloc>
f0101889:	89 c6                	mov    %eax,%esi
f010188b:	83 c4 10             	add    $0x10,%esp
f010188e:	85 c0                	test   %eax,%eax
f0101890:	75 19                	jne    f01018ab <mem_init+0x30e>
f0101892:	68 3d 4d 10 f0       	push   $0xf0104d3d
f0101897:	68 92 4c 10 f0       	push   $0xf0104c92
f010189c:	68 63 02 00 00       	push   $0x263
f01018a1:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01018a6:	e8 e0 e7 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01018ab:	83 ec 0c             	sub    $0xc,%esp
f01018ae:	6a 00                	push   $0x0
f01018b0:	e8 11 fa ff ff       	call   f01012c6 <page_alloc>
f01018b5:	89 c7                	mov    %eax,%edi
f01018b7:	83 c4 10             	add    $0x10,%esp
f01018ba:	85 c0                	test   %eax,%eax
f01018bc:	75 19                	jne    f01018d7 <mem_init+0x33a>
f01018be:	68 53 4d 10 f0       	push   $0xf0104d53
f01018c3:	68 92 4c 10 f0       	push   $0xf0104c92
f01018c8:	68 64 02 00 00       	push   $0x264
f01018cd:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01018d2:	e8 b4 e7 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01018d7:	83 ec 0c             	sub    $0xc,%esp
f01018da:	6a 00                	push   $0x0
f01018dc:	e8 e5 f9 ff ff       	call   f01012c6 <page_alloc>
f01018e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018e4:	83 c4 10             	add    $0x10,%esp
f01018e7:	85 c0                	test   %eax,%eax
f01018e9:	75 19                	jne    f0101904 <mem_init+0x367>
f01018eb:	68 69 4d 10 f0       	push   $0xf0104d69
f01018f0:	68 92 4c 10 f0       	push   $0xf0104c92
f01018f5:	68 65 02 00 00       	push   $0x265
f01018fa:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01018ff:	e8 87 e7 ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101904:	39 fe                	cmp    %edi,%esi
f0101906:	75 19                	jne    f0101921 <mem_init+0x384>
f0101908:	68 7f 4d 10 f0       	push   $0xf0104d7f
f010190d:	68 92 4c 10 f0       	push   $0xf0104c92
f0101912:	68 67 02 00 00       	push   $0x267
f0101917:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010191c:	e8 6a e7 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101921:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101924:	74 05                	je     f010192b <mem_init+0x38e>
f0101926:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101929:	75 19                	jne    f0101944 <mem_init+0x3a7>
f010192b:	68 b8 46 10 f0       	push   $0xf01046b8
f0101930:	68 92 4c 10 f0       	push   $0xf0104c92
f0101935:	68 68 02 00 00       	push   $0x268
f010193a:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010193f:	e8 47 e7 ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101944:	83 ec 0c             	sub    $0xc,%esp
f0101947:	6a 00                	push   $0x0
f0101949:	e8 78 f9 ff ff       	call   f01012c6 <page_alloc>
f010194e:	83 c4 10             	add    $0x10,%esp
f0101951:	85 c0                	test   %eax,%eax
f0101953:	74 19                	je     f010196e <mem_init+0x3d1>
f0101955:	68 e8 4d 10 f0       	push   $0xf0104de8
f010195a:	68 92 4c 10 f0       	push   $0xf0104c92
f010195f:	68 69 02 00 00       	push   $0x269
f0101964:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101969:	e8 1d e7 ff ff       	call   f010008b <_panic>
f010196e:	89 f0                	mov    %esi,%eax
f0101970:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f0101976:	c1 f8 03             	sar    $0x3,%eax
f0101979:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010197c:	89 c2                	mov    %eax,%edx
f010197e:	c1 ea 0c             	shr    $0xc,%edx
f0101981:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f0101987:	72 12                	jb     f010199b <mem_init+0x3fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101989:	50                   	push   %eax
f010198a:	68 74 45 10 f0       	push   $0xf0104574
f010198f:	6a 52                	push   $0x52
f0101991:	68 78 4c 10 f0       	push   $0xf0104c78
f0101996:	e8 f0 e6 ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010199b:	83 ec 04             	sub    $0x4,%esp
f010199e:	68 00 10 00 00       	push   $0x1000
f01019a3:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01019a5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01019aa:	50                   	push   %eax
f01019ab:	e8 89 1d 00 00       	call   f0103739 <memset>
	page_free(pp0);
f01019b0:	89 34 24             	mov    %esi,(%esp)
f01019b3:	e8 98 f9 ff ff       	call   f0101350 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01019b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01019bf:	e8 02 f9 ff ff       	call   f01012c6 <page_alloc>
f01019c4:	83 c4 10             	add    $0x10,%esp
f01019c7:	85 c0                	test   %eax,%eax
f01019c9:	75 19                	jne    f01019e4 <mem_init+0x447>
f01019cb:	68 f7 4d 10 f0       	push   $0xf0104df7
f01019d0:	68 92 4c 10 f0       	push   $0xf0104c92
f01019d5:	68 6e 02 00 00       	push   $0x26e
f01019da:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01019df:	e8 a7 e6 ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f01019e4:	39 c6                	cmp    %eax,%esi
f01019e6:	74 19                	je     f0101a01 <mem_init+0x464>
f01019e8:	68 15 4e 10 f0       	push   $0xf0104e15
f01019ed:	68 92 4c 10 f0       	push   $0xf0104c92
f01019f2:	68 6f 02 00 00       	push   $0x26f
f01019f7:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01019fc:	e8 8a e6 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a01:	89 f2                	mov    %esi,%edx
f0101a03:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101a09:	c1 fa 03             	sar    $0x3,%edx
f0101a0c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a0f:	89 d0                	mov    %edx,%eax
f0101a11:	c1 e8 0c             	shr    $0xc,%eax
f0101a14:	3b 05 44 e9 11 f0    	cmp    0xf011e944,%eax
f0101a1a:	72 12                	jb     f0101a2e <mem_init+0x491>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a1c:	52                   	push   %edx
f0101a1d:	68 74 45 10 f0       	push   $0xf0104574
f0101a22:	6a 52                	push   $0x52
f0101a24:	68 78 4c 10 f0       	push   $0xf0104c78
f0101a29:	e8 5d e6 ff ff       	call   f010008b <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101a2e:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101a35:	75 11                	jne    f0101a48 <mem_init+0x4ab>
f0101a37:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101a3d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101a43:	80 38 00             	cmpb   $0x0,(%eax)
f0101a46:	74 19                	je     f0101a61 <mem_init+0x4c4>
f0101a48:	68 25 4e 10 f0       	push   $0xf0104e25
f0101a4d:	68 92 4c 10 f0       	push   $0xf0104c92
f0101a52:	68 72 02 00 00       	push   $0x272
f0101a57:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101a5c:	e8 2a e6 ff ff       	call   f010008b <_panic>
f0101a61:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101a62:	39 d0                	cmp    %edx,%eax
f0101a64:	75 dd                	jne    f0101a43 <mem_init+0x4a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101a66:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101a69:	89 15 2c e5 11 f0    	mov    %edx,0xf011e52c

	// free the pages we took
	page_free(pp0);
f0101a6f:	83 ec 0c             	sub    $0xc,%esp
f0101a72:	56                   	push   %esi
f0101a73:	e8 d8 f8 ff ff       	call   f0101350 <page_free>
	page_free(pp1);
f0101a78:	89 3c 24             	mov    %edi,(%esp)
f0101a7b:	e8 d0 f8 ff ff       	call   f0101350 <page_free>
	page_free(pp2);
f0101a80:	83 c4 04             	add    $0x4,%esp
f0101a83:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a86:	e8 c5 f8 ff ff       	call   f0101350 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a8b:	a1 2c e5 11 f0       	mov    0xf011e52c,%eax
f0101a90:	83 c4 10             	add    $0x10,%esp
f0101a93:	85 c0                	test   %eax,%eax
f0101a95:	74 07                	je     f0101a9e <mem_init+0x501>
		--nfree;
f0101a97:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a98:	8b 00                	mov    (%eax),%eax
f0101a9a:	85 c0                	test   %eax,%eax
f0101a9c:	75 f9                	jne    f0101a97 <mem_init+0x4fa>
		--nfree;
	assert(nfree == 0);
f0101a9e:	85 db                	test   %ebx,%ebx
f0101aa0:	74 19                	je     f0101abb <mem_init+0x51e>
f0101aa2:	68 2f 4e 10 f0       	push   $0xf0104e2f
f0101aa7:	68 92 4c 10 f0       	push   $0xf0104c92
f0101aac:	68 7f 02 00 00       	push   $0x27f
f0101ab1:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101ab6:	e8 d0 e5 ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101abb:	83 ec 0c             	sub    $0xc,%esp
f0101abe:	68 d8 46 10 f0       	push   $0xf01046d8
f0101ac3:	e8 41 11 00 00       	call   f0102c09 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ac8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101acf:	e8 f2 f7 ff ff       	call   f01012c6 <page_alloc>
f0101ad4:	89 c6                	mov    %eax,%esi
f0101ad6:	83 c4 10             	add    $0x10,%esp
f0101ad9:	85 c0                	test   %eax,%eax
f0101adb:	75 19                	jne    f0101af6 <mem_init+0x559>
f0101add:	68 3d 4d 10 f0       	push   $0xf0104d3d
f0101ae2:	68 92 4c 10 f0       	push   $0xf0104c92
f0101ae7:	68 d8 02 00 00       	push   $0x2d8
f0101aec:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101af1:	e8 95 e5 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101af6:	83 ec 0c             	sub    $0xc,%esp
f0101af9:	6a 00                	push   $0x0
f0101afb:	e8 c6 f7 ff ff       	call   f01012c6 <page_alloc>
f0101b00:	89 c7                	mov    %eax,%edi
f0101b02:	83 c4 10             	add    $0x10,%esp
f0101b05:	85 c0                	test   %eax,%eax
f0101b07:	75 19                	jne    f0101b22 <mem_init+0x585>
f0101b09:	68 53 4d 10 f0       	push   $0xf0104d53
f0101b0e:	68 92 4c 10 f0       	push   $0xf0104c92
f0101b13:	68 d9 02 00 00       	push   $0x2d9
f0101b18:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101b1d:	e8 69 e5 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101b22:	83 ec 0c             	sub    $0xc,%esp
f0101b25:	6a 00                	push   $0x0
f0101b27:	e8 9a f7 ff ff       	call   f01012c6 <page_alloc>
f0101b2c:	89 c3                	mov    %eax,%ebx
f0101b2e:	83 c4 10             	add    $0x10,%esp
f0101b31:	85 c0                	test   %eax,%eax
f0101b33:	75 19                	jne    f0101b4e <mem_init+0x5b1>
f0101b35:	68 69 4d 10 f0       	push   $0xf0104d69
f0101b3a:	68 92 4c 10 f0       	push   $0xf0104c92
f0101b3f:	68 da 02 00 00       	push   $0x2da
f0101b44:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101b49:	e8 3d e5 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b4e:	39 fe                	cmp    %edi,%esi
f0101b50:	75 19                	jne    f0101b6b <mem_init+0x5ce>
f0101b52:	68 7f 4d 10 f0       	push   $0xf0104d7f
f0101b57:	68 92 4c 10 f0       	push   $0xf0104c92
f0101b5c:	68 dd 02 00 00       	push   $0x2dd
f0101b61:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101b66:	e8 20 e5 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b6b:	39 c7                	cmp    %eax,%edi
f0101b6d:	74 04                	je     f0101b73 <mem_init+0x5d6>
f0101b6f:	39 c6                	cmp    %eax,%esi
f0101b71:	75 19                	jne    f0101b8c <mem_init+0x5ef>
f0101b73:	68 b8 46 10 f0       	push   $0xf01046b8
f0101b78:	68 92 4c 10 f0       	push   $0xf0104c92
f0101b7d:	68 de 02 00 00       	push   $0x2de
f0101b82:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101b87:	e8 ff e4 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b8c:	8b 0d 2c e5 11 f0    	mov    0xf011e52c,%ecx
f0101b92:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	page_free_list = 0;
f0101b95:	c7 05 2c e5 11 f0 00 	movl   $0x0,0xf011e52c
f0101b9c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b9f:	83 ec 0c             	sub    $0xc,%esp
f0101ba2:	6a 00                	push   $0x0
f0101ba4:	e8 1d f7 ff ff       	call   f01012c6 <page_alloc>
f0101ba9:	83 c4 10             	add    $0x10,%esp
f0101bac:	85 c0                	test   %eax,%eax
f0101bae:	74 19                	je     f0101bc9 <mem_init+0x62c>
f0101bb0:	68 e8 4d 10 f0       	push   $0xf0104de8
f0101bb5:	68 92 4c 10 f0       	push   $0xf0104c92
f0101bba:	68 e5 02 00 00       	push   $0x2e5
f0101bbf:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101bc4:	e8 c2 e4 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101bc9:	83 ec 04             	sub    $0x4,%esp
f0101bcc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101bcf:	50                   	push   %eax
f0101bd0:	6a 00                	push   $0x0
f0101bd2:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101bd8:	e8 99 f8 ff ff       	call   f0101476 <page_lookup>
f0101bdd:	83 c4 10             	add    $0x10,%esp
f0101be0:	85 c0                	test   %eax,%eax
f0101be2:	74 19                	je     f0101bfd <mem_init+0x660>
f0101be4:	68 f8 46 10 f0       	push   $0xf01046f8
f0101be9:	68 92 4c 10 f0       	push   $0xf0104c92
f0101bee:	68 e8 02 00 00       	push   $0x2e8
f0101bf3:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101bf8:	e8 8e e4 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101bfd:	6a 02                	push   $0x2
f0101bff:	6a 00                	push   $0x0
f0101c01:	57                   	push   %edi
f0101c02:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101c08:	e8 27 f9 ff ff       	call   f0101534 <page_insert>
f0101c0d:	83 c4 10             	add    $0x10,%esp
f0101c10:	85 c0                	test   %eax,%eax
f0101c12:	78 19                	js     f0101c2d <mem_init+0x690>
f0101c14:	68 30 47 10 f0       	push   $0xf0104730
f0101c19:	68 92 4c 10 f0       	push   $0xf0104c92
f0101c1e:	68 eb 02 00 00       	push   $0x2eb
f0101c23:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101c28:	e8 5e e4 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c2d:	83 ec 0c             	sub    $0xc,%esp
f0101c30:	56                   	push   %esi
f0101c31:	e8 1a f7 ff ff       	call   f0101350 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c36:	6a 02                	push   $0x2
f0101c38:	6a 00                	push   $0x0
f0101c3a:	57                   	push   %edi
f0101c3b:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101c41:	e8 ee f8 ff ff       	call   f0101534 <page_insert>
f0101c46:	83 c4 20             	add    $0x20,%esp
f0101c49:	85 c0                	test   %eax,%eax
f0101c4b:	74 19                	je     f0101c66 <mem_init+0x6c9>
f0101c4d:	68 60 47 10 f0       	push   $0xf0104760
f0101c52:	68 92 4c 10 f0       	push   $0xf0104c92
f0101c57:	68 ef 02 00 00       	push   $0x2ef
f0101c5c:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101c61:	e8 25 e4 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c66:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101c6b:	8b 08                	mov    (%eax),%ecx
f0101c6d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c73:	89 f2                	mov    %esi,%edx
f0101c75:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101c7b:	c1 fa 03             	sar    $0x3,%edx
f0101c7e:	c1 e2 0c             	shl    $0xc,%edx
f0101c81:	39 d1                	cmp    %edx,%ecx
f0101c83:	74 19                	je     f0101c9e <mem_init+0x701>
f0101c85:	68 90 47 10 f0       	push   $0xf0104790
f0101c8a:	68 92 4c 10 f0       	push   $0xf0104c92
f0101c8f:	68 f0 02 00 00       	push   $0x2f0
f0101c94:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101c99:	e8 ed e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c9e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ca3:	e8 2f f2 ff ff       	call   f0100ed7 <check_va2pa>
f0101ca8:	89 fa                	mov    %edi,%edx
f0101caa:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101cb0:	c1 fa 03             	sar    $0x3,%edx
f0101cb3:	c1 e2 0c             	shl    $0xc,%edx
f0101cb6:	39 d0                	cmp    %edx,%eax
f0101cb8:	74 19                	je     f0101cd3 <mem_init+0x736>
f0101cba:	68 b8 47 10 f0       	push   $0xf01047b8
f0101cbf:	68 92 4c 10 f0       	push   $0xf0104c92
f0101cc4:	68 f1 02 00 00       	push   $0x2f1
f0101cc9:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101cce:	e8 b8 e3 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101cd3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101cd8:	74 19                	je     f0101cf3 <mem_init+0x756>
f0101cda:	68 3a 4e 10 f0       	push   $0xf0104e3a
f0101cdf:	68 92 4c 10 f0       	push   $0xf0104c92
f0101ce4:	68 f2 02 00 00       	push   $0x2f2
f0101ce9:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101cee:	e8 98 e3 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0101cf3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cf8:	74 19                	je     f0101d13 <mem_init+0x776>
f0101cfa:	68 4b 4e 10 f0       	push   $0xf0104e4b
f0101cff:	68 92 4c 10 f0       	push   $0xf0104c92
f0101d04:	68 f3 02 00 00       	push   $0x2f3
f0101d09:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101d0e:	e8 78 e3 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d13:	6a 02                	push   $0x2
f0101d15:	68 00 10 00 00       	push   $0x1000
f0101d1a:	53                   	push   %ebx
f0101d1b:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101d21:	e8 0e f8 ff ff       	call   f0101534 <page_insert>
f0101d26:	83 c4 10             	add    $0x10,%esp
f0101d29:	85 c0                	test   %eax,%eax
f0101d2b:	74 19                	je     f0101d46 <mem_init+0x7a9>
f0101d2d:	68 e8 47 10 f0       	push   $0xf01047e8
f0101d32:	68 92 4c 10 f0       	push   $0xf0104c92
f0101d37:	68 f6 02 00 00       	push   $0x2f6
f0101d3c:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101d41:	e8 45 e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d46:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d4b:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101d50:	e8 82 f1 ff ff       	call   f0100ed7 <check_va2pa>
f0101d55:	89 da                	mov    %ebx,%edx
f0101d57:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101d5d:	c1 fa 03             	sar    $0x3,%edx
f0101d60:	c1 e2 0c             	shl    $0xc,%edx
f0101d63:	39 d0                	cmp    %edx,%eax
f0101d65:	74 19                	je     f0101d80 <mem_init+0x7e3>
f0101d67:	68 24 48 10 f0       	push   $0xf0104824
f0101d6c:	68 92 4c 10 f0       	push   $0xf0104c92
f0101d71:	68 f7 02 00 00       	push   $0x2f7
f0101d76:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101d7b:	e8 0b e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101d80:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d85:	74 19                	je     f0101da0 <mem_init+0x803>
f0101d87:	68 5c 4e 10 f0       	push   $0xf0104e5c
f0101d8c:	68 92 4c 10 f0       	push   $0xf0104c92
f0101d91:	68 f8 02 00 00       	push   $0x2f8
f0101d96:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101d9b:	e8 eb e2 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101da0:	83 ec 0c             	sub    $0xc,%esp
f0101da3:	6a 00                	push   $0x0
f0101da5:	e8 1c f5 ff ff       	call   f01012c6 <page_alloc>
f0101daa:	83 c4 10             	add    $0x10,%esp
f0101dad:	85 c0                	test   %eax,%eax
f0101daf:	74 19                	je     f0101dca <mem_init+0x82d>
f0101db1:	68 e8 4d 10 f0       	push   $0xf0104de8
f0101db6:	68 92 4c 10 f0       	push   $0xf0104c92
f0101dbb:	68 fb 02 00 00       	push   $0x2fb
f0101dc0:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101dc5:	e8 c1 e2 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dca:	6a 02                	push   $0x2
f0101dcc:	68 00 10 00 00       	push   $0x1000
f0101dd1:	53                   	push   %ebx
f0101dd2:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101dd8:	e8 57 f7 ff ff       	call   f0101534 <page_insert>
f0101ddd:	83 c4 10             	add    $0x10,%esp
f0101de0:	85 c0                	test   %eax,%eax
f0101de2:	74 19                	je     f0101dfd <mem_init+0x860>
f0101de4:	68 e8 47 10 f0       	push   $0xf01047e8
f0101de9:	68 92 4c 10 f0       	push   $0xf0104c92
f0101dee:	68 fe 02 00 00       	push   $0x2fe
f0101df3:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101df8:	e8 8e e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dfd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e02:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101e07:	e8 cb f0 ff ff       	call   f0100ed7 <check_va2pa>
f0101e0c:	89 da                	mov    %ebx,%edx
f0101e0e:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101e14:	c1 fa 03             	sar    $0x3,%edx
f0101e17:	c1 e2 0c             	shl    $0xc,%edx
f0101e1a:	39 d0                	cmp    %edx,%eax
f0101e1c:	74 19                	je     f0101e37 <mem_init+0x89a>
f0101e1e:	68 24 48 10 f0       	push   $0xf0104824
f0101e23:	68 92 4c 10 f0       	push   $0xf0104c92
f0101e28:	68 ff 02 00 00       	push   $0x2ff
f0101e2d:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101e32:	e8 54 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101e37:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e3c:	74 19                	je     f0101e57 <mem_init+0x8ba>
f0101e3e:	68 5c 4e 10 f0       	push   $0xf0104e5c
f0101e43:	68 92 4c 10 f0       	push   $0xf0104c92
f0101e48:	68 00 03 00 00       	push   $0x300
f0101e4d:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101e52:	e8 34 e2 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e57:	83 ec 0c             	sub    $0xc,%esp
f0101e5a:	6a 00                	push   $0x0
f0101e5c:	e8 65 f4 ff ff       	call   f01012c6 <page_alloc>
f0101e61:	83 c4 10             	add    $0x10,%esp
f0101e64:	85 c0                	test   %eax,%eax
f0101e66:	74 19                	je     f0101e81 <mem_init+0x8e4>
f0101e68:	68 e8 4d 10 f0       	push   $0xf0104de8
f0101e6d:	68 92 4c 10 f0       	push   $0xf0104c92
f0101e72:	68 04 03 00 00       	push   $0x304
f0101e77:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101e7c:	e8 0a e2 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e81:	8b 15 48 e9 11 f0    	mov    0xf011e948,%edx
f0101e87:	8b 02                	mov    (%edx),%eax
f0101e89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e8e:	89 c1                	mov    %eax,%ecx
f0101e90:	c1 e9 0c             	shr    $0xc,%ecx
f0101e93:	3b 0d 44 e9 11 f0    	cmp    0xf011e944,%ecx
f0101e99:	72 15                	jb     f0101eb0 <mem_init+0x913>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e9b:	50                   	push   %eax
f0101e9c:	68 74 45 10 f0       	push   $0xf0104574
f0101ea1:	68 07 03 00 00       	push   $0x307
f0101ea6:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101eab:	e8 db e1 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101eb0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101eb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101eb8:	83 ec 04             	sub    $0x4,%esp
f0101ebb:	6a 00                	push   $0x0
f0101ebd:	68 00 10 00 00       	push   $0x1000
f0101ec2:	52                   	push   %edx
f0101ec3:	e8 c6 f4 ff ff       	call   f010138e <pgdir_walk>
f0101ec8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101ecb:	83 c2 04             	add    $0x4,%edx
f0101ece:	83 c4 10             	add    $0x10,%esp
f0101ed1:	39 d0                	cmp    %edx,%eax
f0101ed3:	74 19                	je     f0101eee <mem_init+0x951>
f0101ed5:	68 54 48 10 f0       	push   $0xf0104854
f0101eda:	68 92 4c 10 f0       	push   $0xf0104c92
f0101edf:	68 08 03 00 00       	push   $0x308
f0101ee4:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101ee9:	e8 9d e1 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101eee:	6a 06                	push   $0x6
f0101ef0:	68 00 10 00 00       	push   $0x1000
f0101ef5:	53                   	push   %ebx
f0101ef6:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101efc:	e8 33 f6 ff ff       	call   f0101534 <page_insert>
f0101f01:	83 c4 10             	add    $0x10,%esp
f0101f04:	85 c0                	test   %eax,%eax
f0101f06:	74 19                	je     f0101f21 <mem_init+0x984>
f0101f08:	68 94 48 10 f0       	push   $0xf0104894
f0101f0d:	68 92 4c 10 f0       	push   $0xf0104c92
f0101f12:	68 0b 03 00 00       	push   $0x30b
f0101f17:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101f1c:	e8 6a e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f21:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f26:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101f2b:	e8 a7 ef ff ff       	call   f0100ed7 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f30:	89 da                	mov    %ebx,%edx
f0101f32:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0101f38:	c1 fa 03             	sar    $0x3,%edx
f0101f3b:	c1 e2 0c             	shl    $0xc,%edx
f0101f3e:	39 d0                	cmp    %edx,%eax
f0101f40:	74 19                	je     f0101f5b <mem_init+0x9be>
f0101f42:	68 24 48 10 f0       	push   $0xf0104824
f0101f47:	68 92 4c 10 f0       	push   $0xf0104c92
f0101f4c:	68 0c 03 00 00       	push   $0x30c
f0101f51:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101f56:	e8 30 e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101f5b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f60:	74 19                	je     f0101f7b <mem_init+0x9de>
f0101f62:	68 5c 4e 10 f0       	push   $0xf0104e5c
f0101f67:	68 92 4c 10 f0       	push   $0xf0104c92
f0101f6c:	68 0d 03 00 00       	push   $0x30d
f0101f71:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101f76:	e8 10 e1 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101f7b:	83 ec 04             	sub    $0x4,%esp
f0101f7e:	6a 00                	push   $0x0
f0101f80:	68 00 10 00 00       	push   $0x1000
f0101f85:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0101f8b:	e8 fe f3 ff ff       	call   f010138e <pgdir_walk>
f0101f90:	83 c4 10             	add    $0x10,%esp
f0101f93:	f6 00 04             	testb  $0x4,(%eax)
f0101f96:	75 19                	jne    f0101fb1 <mem_init+0xa14>
f0101f98:	68 d4 48 10 f0       	push   $0xf01048d4
f0101f9d:	68 92 4c 10 f0       	push   $0xf0104c92
f0101fa2:	68 0e 03 00 00       	push   $0x30e
f0101fa7:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101fac:	e8 da e0 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101fb1:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0101fb6:	f6 00 04             	testb  $0x4,(%eax)
f0101fb9:	75 19                	jne    f0101fd4 <mem_init+0xa37>
f0101fbb:	68 6d 4e 10 f0       	push   $0xf0104e6d
f0101fc0:	68 92 4c 10 f0       	push   $0xf0104c92
f0101fc5:	68 0f 03 00 00       	push   $0x30f
f0101fca:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101fcf:	e8 b7 e0 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fd4:	6a 02                	push   $0x2
f0101fd6:	68 00 10 00 00       	push   $0x1000
f0101fdb:	53                   	push   %ebx
f0101fdc:	50                   	push   %eax
f0101fdd:	e8 52 f5 ff ff       	call   f0101534 <page_insert>
f0101fe2:	83 c4 10             	add    $0x10,%esp
f0101fe5:	85 c0                	test   %eax,%eax
f0101fe7:	74 19                	je     f0102002 <mem_init+0xa65>
f0101fe9:	68 e8 47 10 f0       	push   $0xf01047e8
f0101fee:	68 92 4c 10 f0       	push   $0xf0104c92
f0101ff3:	68 12 03 00 00       	push   $0x312
f0101ff8:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0101ffd:	e8 89 e0 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102002:	83 ec 04             	sub    $0x4,%esp
f0102005:	6a 00                	push   $0x0
f0102007:	68 00 10 00 00       	push   $0x1000
f010200c:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102012:	e8 77 f3 ff ff       	call   f010138e <pgdir_walk>
f0102017:	83 c4 10             	add    $0x10,%esp
f010201a:	f6 00 02             	testb  $0x2,(%eax)
f010201d:	75 19                	jne    f0102038 <mem_init+0xa9b>
f010201f:	68 08 49 10 f0       	push   $0xf0104908
f0102024:	68 92 4c 10 f0       	push   $0xf0104c92
f0102029:	68 13 03 00 00       	push   $0x313
f010202e:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102033:	e8 53 e0 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102038:	83 ec 04             	sub    $0x4,%esp
f010203b:	6a 00                	push   $0x0
f010203d:	68 00 10 00 00       	push   $0x1000
f0102042:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102048:	e8 41 f3 ff ff       	call   f010138e <pgdir_walk>
f010204d:	83 c4 10             	add    $0x10,%esp
f0102050:	f6 00 04             	testb  $0x4,(%eax)
f0102053:	74 19                	je     f010206e <mem_init+0xad1>
f0102055:	68 3c 49 10 f0       	push   $0xf010493c
f010205a:	68 92 4c 10 f0       	push   $0xf0104c92
f010205f:	68 14 03 00 00       	push   $0x314
f0102064:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102069:	e8 1d e0 ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010206e:	6a 02                	push   $0x2
f0102070:	68 00 00 40 00       	push   $0x400000
f0102075:	56                   	push   %esi
f0102076:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f010207c:	e8 b3 f4 ff ff       	call   f0101534 <page_insert>
f0102081:	83 c4 10             	add    $0x10,%esp
f0102084:	85 c0                	test   %eax,%eax
f0102086:	78 19                	js     f01020a1 <mem_init+0xb04>
f0102088:	68 74 49 10 f0       	push   $0xf0104974
f010208d:	68 92 4c 10 f0       	push   $0xf0104c92
f0102092:	68 17 03 00 00       	push   $0x317
f0102097:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010209c:	e8 ea df ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01020a1:	6a 02                	push   $0x2
f01020a3:	68 00 10 00 00       	push   $0x1000
f01020a8:	57                   	push   %edi
f01020a9:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f01020af:	e8 80 f4 ff ff       	call   f0101534 <page_insert>
f01020b4:	83 c4 10             	add    $0x10,%esp
f01020b7:	85 c0                	test   %eax,%eax
f01020b9:	74 19                	je     f01020d4 <mem_init+0xb37>
f01020bb:	68 ac 49 10 f0       	push   $0xf01049ac
f01020c0:	68 92 4c 10 f0       	push   $0xf0104c92
f01020c5:	68 1a 03 00 00       	push   $0x31a
f01020ca:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01020cf:	e8 b7 df ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020d4:	83 ec 04             	sub    $0x4,%esp
f01020d7:	6a 00                	push   $0x0
f01020d9:	68 00 10 00 00       	push   $0x1000
f01020de:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f01020e4:	e8 a5 f2 ff ff       	call   f010138e <pgdir_walk>
f01020e9:	83 c4 10             	add    $0x10,%esp
f01020ec:	f6 00 04             	testb  $0x4,(%eax)
f01020ef:	74 19                	je     f010210a <mem_init+0xb6d>
f01020f1:	68 3c 49 10 f0       	push   $0xf010493c
f01020f6:	68 92 4c 10 f0       	push   $0xf0104c92
f01020fb:	68 1b 03 00 00       	push   $0x31b
f0102100:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102105:	e8 81 df ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010210a:	ba 00 00 00 00       	mov    $0x0,%edx
f010210f:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102114:	e8 be ed ff ff       	call   f0100ed7 <check_va2pa>
f0102119:	89 fa                	mov    %edi,%edx
f010211b:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0102121:	c1 fa 03             	sar    $0x3,%edx
f0102124:	c1 e2 0c             	shl    $0xc,%edx
f0102127:	39 d0                	cmp    %edx,%eax
f0102129:	74 19                	je     f0102144 <mem_init+0xba7>
f010212b:	68 e8 49 10 f0       	push   $0xf01049e8
f0102130:	68 92 4c 10 f0       	push   $0xf0104c92
f0102135:	68 1e 03 00 00       	push   $0x31e
f010213a:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010213f:	e8 47 df ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102144:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102149:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f010214e:	e8 84 ed ff ff       	call   f0100ed7 <check_va2pa>
f0102153:	89 fa                	mov    %edi,%edx
f0102155:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f010215b:	c1 fa 03             	sar    $0x3,%edx
f010215e:	c1 e2 0c             	shl    $0xc,%edx
f0102161:	39 d0                	cmp    %edx,%eax
f0102163:	74 19                	je     f010217e <mem_init+0xbe1>
f0102165:	68 14 4a 10 f0       	push   $0xf0104a14
f010216a:	68 92 4c 10 f0       	push   $0xf0104c92
f010216f:	68 1f 03 00 00       	push   $0x31f
f0102174:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102179:	e8 0d df ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010217e:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102183:	74 19                	je     f010219e <mem_init+0xc01>
f0102185:	68 83 4e 10 f0       	push   $0xf0104e83
f010218a:	68 92 4c 10 f0       	push   $0xf0104c92
f010218f:	68 21 03 00 00       	push   $0x321
f0102194:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102199:	e8 ed de ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f010219e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021a3:	74 19                	je     f01021be <mem_init+0xc21>
f01021a5:	68 94 4e 10 f0       	push   $0xf0104e94
f01021aa:	68 92 4c 10 f0       	push   $0xf0104c92
f01021af:	68 22 03 00 00       	push   $0x322
f01021b4:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01021b9:	e8 cd de ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01021be:	83 ec 0c             	sub    $0xc,%esp
f01021c1:	6a 00                	push   $0x0
f01021c3:	e8 fe f0 ff ff       	call   f01012c6 <page_alloc>
f01021c8:	83 c4 10             	add    $0x10,%esp
f01021cb:	85 c0                	test   %eax,%eax
f01021cd:	74 04                	je     f01021d3 <mem_init+0xc36>
f01021cf:	39 c3                	cmp    %eax,%ebx
f01021d1:	74 19                	je     f01021ec <mem_init+0xc4f>
f01021d3:	68 44 4a 10 f0       	push   $0xf0104a44
f01021d8:	68 92 4c 10 f0       	push   $0xf0104c92
f01021dd:	68 25 03 00 00       	push   $0x325
f01021e2:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01021e7:	e8 9f de ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01021ec:	83 ec 08             	sub    $0x8,%esp
f01021ef:	6a 00                	push   $0x0
f01021f1:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f01021f7:	e8 eb f2 ff ff       	call   f01014e7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021fc:	ba 00 00 00 00       	mov    $0x0,%edx
f0102201:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102206:	e8 cc ec ff ff       	call   f0100ed7 <check_va2pa>
f010220b:	83 c4 10             	add    $0x10,%esp
f010220e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102211:	74 19                	je     f010222c <mem_init+0xc8f>
f0102213:	68 68 4a 10 f0       	push   $0xf0104a68
f0102218:	68 92 4c 10 f0       	push   $0xf0104c92
f010221d:	68 29 03 00 00       	push   $0x329
f0102222:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102227:	e8 5f de ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010222c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102231:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102236:	e8 9c ec ff ff       	call   f0100ed7 <check_va2pa>
f010223b:	89 fa                	mov    %edi,%edx
f010223d:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0102243:	c1 fa 03             	sar    $0x3,%edx
f0102246:	c1 e2 0c             	shl    $0xc,%edx
f0102249:	39 d0                	cmp    %edx,%eax
f010224b:	74 19                	je     f0102266 <mem_init+0xcc9>
f010224d:	68 14 4a 10 f0       	push   $0xf0104a14
f0102252:	68 92 4c 10 f0       	push   $0xf0104c92
f0102257:	68 2a 03 00 00       	push   $0x32a
f010225c:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102261:	e8 25 de ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0102266:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010226b:	74 19                	je     f0102286 <mem_init+0xce9>
f010226d:	68 3a 4e 10 f0       	push   $0xf0104e3a
f0102272:	68 92 4c 10 f0       	push   $0xf0104c92
f0102277:	68 2b 03 00 00       	push   $0x32b
f010227c:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102281:	e8 05 de ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102286:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010228b:	74 19                	je     f01022a6 <mem_init+0xd09>
f010228d:	68 94 4e 10 f0       	push   $0xf0104e94
f0102292:	68 92 4c 10 f0       	push   $0xf0104c92
f0102297:	68 2c 03 00 00       	push   $0x32c
f010229c:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01022a1:	e8 e5 dd ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01022a6:	83 ec 08             	sub    $0x8,%esp
f01022a9:	68 00 10 00 00       	push   $0x1000
f01022ae:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f01022b4:	e8 2e f2 ff ff       	call   f01014e7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022b9:	ba 00 00 00 00       	mov    $0x0,%edx
f01022be:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f01022c3:	e8 0f ec ff ff       	call   f0100ed7 <check_va2pa>
f01022c8:	83 c4 10             	add    $0x10,%esp
f01022cb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022ce:	74 19                	je     f01022e9 <mem_init+0xd4c>
f01022d0:	68 68 4a 10 f0       	push   $0xf0104a68
f01022d5:	68 92 4c 10 f0       	push   $0xf0104c92
f01022da:	68 30 03 00 00       	push   $0x330
f01022df:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01022e4:	e8 a2 dd ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01022e9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022ee:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f01022f3:	e8 df eb ff ff       	call   f0100ed7 <check_va2pa>
f01022f8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022fb:	74 19                	je     f0102316 <mem_init+0xd79>
f01022fd:	68 8c 4a 10 f0       	push   $0xf0104a8c
f0102302:	68 92 4c 10 f0       	push   $0xf0104c92
f0102307:	68 31 03 00 00       	push   $0x331
f010230c:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102311:	e8 75 dd ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102316:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010231b:	74 19                	je     f0102336 <mem_init+0xd99>
f010231d:	68 a5 4e 10 f0       	push   $0xf0104ea5
f0102322:	68 92 4c 10 f0       	push   $0xf0104c92
f0102327:	68 32 03 00 00       	push   $0x332
f010232c:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102331:	e8 55 dd ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102336:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010233b:	74 19                	je     f0102356 <mem_init+0xdb9>
f010233d:	68 94 4e 10 f0       	push   $0xf0104e94
f0102342:	68 92 4c 10 f0       	push   $0xf0104c92
f0102347:	68 33 03 00 00       	push   $0x333
f010234c:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102351:	e8 35 dd ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102356:	83 ec 0c             	sub    $0xc,%esp
f0102359:	6a 00                	push   $0x0
f010235b:	e8 66 ef ff ff       	call   f01012c6 <page_alloc>
f0102360:	83 c4 10             	add    $0x10,%esp
f0102363:	85 c0                	test   %eax,%eax
f0102365:	74 04                	je     f010236b <mem_init+0xdce>
f0102367:	39 c7                	cmp    %eax,%edi
f0102369:	74 19                	je     f0102384 <mem_init+0xde7>
f010236b:	68 b4 4a 10 f0       	push   $0xf0104ab4
f0102370:	68 92 4c 10 f0       	push   $0xf0104c92
f0102375:	68 36 03 00 00       	push   $0x336
f010237a:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010237f:	e8 07 dd ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102384:	83 ec 0c             	sub    $0xc,%esp
f0102387:	6a 00                	push   $0x0
f0102389:	e8 38 ef ff ff       	call   f01012c6 <page_alloc>
f010238e:	83 c4 10             	add    $0x10,%esp
f0102391:	85 c0                	test   %eax,%eax
f0102393:	74 19                	je     f01023ae <mem_init+0xe11>
f0102395:	68 e8 4d 10 f0       	push   $0xf0104de8
f010239a:	68 92 4c 10 f0       	push   $0xf0104c92
f010239f:	68 39 03 00 00       	push   $0x339
f01023a4:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01023a9:	e8 dd dc ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023ae:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f01023b3:	8b 08                	mov    (%eax),%ecx
f01023b5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01023bb:	89 f2                	mov    %esi,%edx
f01023bd:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f01023c3:	c1 fa 03             	sar    $0x3,%edx
f01023c6:	c1 e2 0c             	shl    $0xc,%edx
f01023c9:	39 d1                	cmp    %edx,%ecx
f01023cb:	74 19                	je     f01023e6 <mem_init+0xe49>
f01023cd:	68 90 47 10 f0       	push   $0xf0104790
f01023d2:	68 92 4c 10 f0       	push   $0xf0104c92
f01023d7:	68 3c 03 00 00       	push   $0x33c
f01023dc:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01023e1:	e8 a5 dc ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f01023e6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01023ec:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01023f1:	74 19                	je     f010240c <mem_init+0xe6f>
f01023f3:	68 4b 4e 10 f0       	push   $0xf0104e4b
f01023f8:	68 92 4c 10 f0       	push   $0xf0104c92
f01023fd:	68 3e 03 00 00       	push   $0x33e
f0102402:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102407:	e8 7f dc ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f010240c:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102412:	83 ec 0c             	sub    $0xc,%esp
f0102415:	56                   	push   %esi
f0102416:	e8 35 ef ff ff       	call   f0101350 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010241b:	83 c4 0c             	add    $0xc,%esp
f010241e:	6a 01                	push   $0x1
f0102420:	68 00 10 40 00       	push   $0x401000
f0102425:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f010242b:	e8 5e ef ff ff       	call   f010138e <pgdir_walk>
f0102430:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102433:	8b 0d 48 e9 11 f0    	mov    0xf011e948,%ecx
f0102439:	8b 51 04             	mov    0x4(%ecx),%edx
f010243c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102442:	89 55 c4             	mov    %edx,-0x3c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102445:	c1 ea 0c             	shr    $0xc,%edx
f0102448:	83 c4 10             	add    $0x10,%esp
f010244b:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f0102451:	72 17                	jb     f010246a <mem_init+0xecd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102453:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102456:	68 74 45 10 f0       	push   $0xf0104574
f010245b:	68 45 03 00 00       	push   $0x345
f0102460:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102465:	e8 21 dc ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f010246a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010246d:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102473:	39 d0                	cmp    %edx,%eax
f0102475:	74 19                	je     f0102490 <mem_init+0xef3>
f0102477:	68 b6 4e 10 f0       	push   $0xf0104eb6
f010247c:	68 92 4c 10 f0       	push   $0xf0104c92
f0102481:	68 46 03 00 00       	push   $0x346
f0102486:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010248b:	e8 fb db ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102490:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102497:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010249d:	89 f0                	mov    %esi,%eax
f010249f:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f01024a5:	c1 f8 03             	sar    $0x3,%eax
f01024a8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024ab:	89 c2                	mov    %eax,%edx
f01024ad:	c1 ea 0c             	shr    $0xc,%edx
f01024b0:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f01024b6:	72 12                	jb     f01024ca <mem_init+0xf2d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024b8:	50                   	push   %eax
f01024b9:	68 74 45 10 f0       	push   $0xf0104574
f01024be:	6a 52                	push   $0x52
f01024c0:	68 78 4c 10 f0       	push   $0xf0104c78
f01024c5:	e8 c1 db ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01024ca:	83 ec 04             	sub    $0x4,%esp
f01024cd:	68 00 10 00 00       	push   $0x1000
f01024d2:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01024d7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024dc:	50                   	push   %eax
f01024dd:	e8 57 12 00 00       	call   f0103739 <memset>
	page_free(pp0);
f01024e2:	89 34 24             	mov    %esi,(%esp)
f01024e5:	e8 66 ee ff ff       	call   f0101350 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01024ea:	83 c4 0c             	add    $0xc,%esp
f01024ed:	6a 01                	push   $0x1
f01024ef:	6a 00                	push   $0x0
f01024f1:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f01024f7:	e8 92 ee ff ff       	call   f010138e <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024fc:	89 f2                	mov    %esi,%edx
f01024fe:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0102504:	c1 fa 03             	sar    $0x3,%edx
f0102507:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010250a:	89 d0                	mov    %edx,%eax
f010250c:	c1 e8 0c             	shr    $0xc,%eax
f010250f:	83 c4 10             	add    $0x10,%esp
f0102512:	3b 05 44 e9 11 f0    	cmp    0xf011e944,%eax
f0102518:	72 12                	jb     f010252c <mem_init+0xf8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010251a:	52                   	push   %edx
f010251b:	68 74 45 10 f0       	push   $0xf0104574
f0102520:	6a 52                	push   $0x52
f0102522:	68 78 4c 10 f0       	push   $0xf0104c78
f0102527:	e8 5f db ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f010252c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102532:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102535:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f010253c:	75 11                	jne    f010254f <mem_init+0xfb2>
f010253e:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102544:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010254a:	f6 00 01             	testb  $0x1,(%eax)
f010254d:	74 19                	je     f0102568 <mem_init+0xfcb>
f010254f:	68 ce 4e 10 f0       	push   $0xf0104ece
f0102554:	68 92 4c 10 f0       	push   $0xf0104c92
f0102559:	68 50 03 00 00       	push   $0x350
f010255e:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102563:	e8 23 db ff ff       	call   f010008b <_panic>
f0102568:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010256b:	39 d0                	cmp    %edx,%eax
f010256d:	75 db                	jne    f010254a <mem_init+0xfad>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010256f:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102574:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010257a:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102580:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102583:	a3 2c e5 11 f0       	mov    %eax,0xf011e52c

	// free the pages we took
	page_free(pp0);
f0102588:	83 ec 0c             	sub    $0xc,%esp
f010258b:	56                   	push   %esi
f010258c:	e8 bf ed ff ff       	call   f0101350 <page_free>
	page_free(pp1);
f0102591:	89 3c 24             	mov    %edi,(%esp)
f0102594:	e8 b7 ed ff ff       	call   f0101350 <page_free>
	page_free(pp2);
f0102599:	89 1c 24             	mov    %ebx,(%esp)
f010259c:	e8 af ed ff ff       	call   f0101350 <page_free>

	cprintf("check_page() succeeded!\n");
f01025a1:	c7 04 24 e5 4e 10 f0 	movl   $0xf0104ee5,(%esp)
f01025a8:	e8 5c 06 00 00       	call   f0102c09 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01025ad:	a1 4c e9 11 f0       	mov    0xf011e94c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025b2:	83 c4 10             	add    $0x10,%esp
f01025b5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025ba:	77 15                	ja     f01025d1 <mem_init+0x1034>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025bc:	50                   	push   %eax
f01025bd:	68 b8 43 10 f0       	push   $0xf01043b8
f01025c2:	68 b1 00 00 00       	push   $0xb1
f01025c7:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01025cc:	e8 ba da ff ff       	call   f010008b <_panic>
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f01025d1:	8b 15 44 e9 11 f0    	mov    0xf011e944,%edx
f01025d7:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01025de:	83 ec 08             	sub    $0x8,%esp
                    UPAGES, 
                    ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), 
f01025e1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, 
f01025e7:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01025e9:	05 00 00 00 10       	add    $0x10000000,%eax
f01025ee:	50                   	push   %eax
f01025ef:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025f4:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f01025f9:	e8 27 ee ff ff       	call   f0101425 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025fe:	83 c4 10             	add    $0x10,%esp
f0102601:	ba 00 40 11 f0       	mov    $0xf0114000,%edx
f0102606:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010260c:	77 15                	ja     f0102623 <mem_init+0x1086>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010260e:	52                   	push   %edx
f010260f:	68 b8 43 10 f0       	push   $0xf01043b8
f0102614:	68 c2 00 00 00       	push   $0xc2
f0102619:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010261e:	e8 68 da ff ff       	call   f010008b <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102623:	83 ec 08             	sub    $0x8,%esp
f0102626:	6a 02                	push   $0x2
f0102628:	68 00 40 11 00       	push   $0x114000
f010262d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102632:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102637:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f010263c:	e8 e4 ed ff ff       	call   f0101425 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir,
f0102641:	83 c4 08             	add    $0x8,%esp
f0102644:	6a 02                	push   $0x2
f0102646:	6a 00                	push   $0x0
f0102648:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010264d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102652:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102657:	e8 c9 ed ff ff       	call   f0101425 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010265c:	8b 1d 48 e9 11 f0    	mov    0xf011e948,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102662:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f0102667:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f010266e:	83 c4 10             	add    $0x10,%esp
f0102671:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102677:	74 63                	je     f01026dc <mem_init+0x113f>
f0102679:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010267e:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102684:	89 d8                	mov    %ebx,%eax
f0102686:	e8 4c e8 ff ff       	call   f0100ed7 <check_va2pa>
f010268b:	8b 15 4c e9 11 f0    	mov    0xf011e94c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102691:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102697:	77 15                	ja     f01026ae <mem_init+0x1111>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102699:	52                   	push   %edx
f010269a:	68 b8 43 10 f0       	push   $0xf01043b8
f010269f:	68 97 02 00 00       	push   $0x297
f01026a4:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01026a9:	e8 dd d9 ff ff       	call   f010008b <_panic>
f01026ae:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01026b5:	39 d0                	cmp    %edx,%eax
f01026b7:	74 19                	je     f01026d2 <mem_init+0x1135>
f01026b9:	68 d8 4a 10 f0       	push   $0xf0104ad8
f01026be:	68 92 4c 10 f0       	push   $0xf0104c92
f01026c3:	68 97 02 00 00       	push   $0x297
f01026c8:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01026cd:	e8 b9 d9 ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01026d2:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01026d8:	39 f7                	cmp    %esi,%edi
f01026da:	77 a2                	ja     f010267e <mem_init+0x10e1>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01026dc:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f01026e1:	c1 e0 0c             	shl    $0xc,%eax
f01026e4:	74 41                	je     f0102727 <mem_init+0x118a>
f01026e6:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01026eb:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f01026f1:	89 d8                	mov    %ebx,%eax
f01026f3:	e8 df e7 ff ff       	call   f0100ed7 <check_va2pa>
f01026f8:	39 c6                	cmp    %eax,%esi
f01026fa:	74 19                	je     f0102715 <mem_init+0x1178>
f01026fc:	68 0c 4b 10 f0       	push   $0xf0104b0c
f0102701:	68 92 4c 10 f0       	push   $0xf0104c92
f0102706:	68 9c 02 00 00       	push   $0x29c
f010270b:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102710:	e8 76 d9 ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102715:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010271b:	a1 44 e9 11 f0       	mov    0xf011e944,%eax
f0102720:	c1 e0 0c             	shl    $0xc,%eax
f0102723:	39 c6                	cmp    %eax,%esi
f0102725:	72 c4                	jb     f01026eb <mem_init+0x114e>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102727:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010272c:	89 d8                	mov    %ebx,%eax
f010272e:	e8 a4 e7 ff ff       	call   f0100ed7 <check_va2pa>
f0102733:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102738:	bf 00 40 11 f0       	mov    $0xf0114000,%edi
f010273d:	81 c7 00 70 00 20    	add    $0x20007000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102743:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102746:	39 d0                	cmp    %edx,%eax
f0102748:	74 19                	je     f0102763 <mem_init+0x11c6>
f010274a:	68 34 4b 10 f0       	push   $0xf0104b34
f010274f:	68 92 4c 10 f0       	push   $0xf0104c92
f0102754:	68 a0 02 00 00       	push   $0x2a0
f0102759:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010275e:	e8 28 d9 ff ff       	call   f010008b <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102763:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102769:	0f 85 25 04 00 00    	jne    f0102b94 <mem_init+0x15f7>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010276f:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102774:	89 d8                	mov    %ebx,%eax
f0102776:	e8 5c e7 ff ff       	call   f0100ed7 <check_va2pa>
f010277b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010277e:	74 19                	je     f0102799 <mem_init+0x11fc>
f0102780:	68 7c 4b 10 f0       	push   $0xf0104b7c
f0102785:	68 92 4c 10 f0       	push   $0xf0104c92
f010278a:	68 a1 02 00 00       	push   $0x2a1
f010278f:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102794:	e8 f2 d8 ff ff       	call   f010008b <_panic>
f0102799:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010279e:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01027a3:	72 2d                	jb     f01027d2 <mem_init+0x1235>
f01027a5:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01027aa:	76 07                	jbe    f01027b3 <mem_init+0x1216>
f01027ac:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01027b1:	75 1f                	jne    f01027d2 <mem_init+0x1235>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01027b3:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01027b7:	75 7e                	jne    f0102837 <mem_init+0x129a>
f01027b9:	68 fe 4e 10 f0       	push   $0xf0104efe
f01027be:	68 92 4c 10 f0       	push   $0xf0104c92
f01027c3:	68 a9 02 00 00       	push   $0x2a9
f01027c8:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01027cd:	e8 b9 d8 ff ff       	call   f010008b <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01027d2:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01027d7:	76 3f                	jbe    f0102818 <mem_init+0x127b>
				assert(pgdir[i] & PTE_P);
f01027d9:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01027dc:	f6 c2 01             	test   $0x1,%dl
f01027df:	75 19                	jne    f01027fa <mem_init+0x125d>
f01027e1:	68 fe 4e 10 f0       	push   $0xf0104efe
f01027e6:	68 92 4c 10 f0       	push   $0xf0104c92
f01027eb:	68 ad 02 00 00       	push   $0x2ad
f01027f0:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01027f5:	e8 91 d8 ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f01027fa:	f6 c2 02             	test   $0x2,%dl
f01027fd:	75 38                	jne    f0102837 <mem_init+0x129a>
f01027ff:	68 0f 4f 10 f0       	push   $0xf0104f0f
f0102804:	68 92 4c 10 f0       	push   $0xf0104c92
f0102809:	68 ae 02 00 00       	push   $0x2ae
f010280e:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102813:	e8 73 d8 ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f0102818:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010281c:	74 19                	je     f0102837 <mem_init+0x129a>
f010281e:	68 20 4f 10 f0       	push   $0xf0104f20
f0102823:	68 92 4c 10 f0       	push   $0xf0104c92
f0102828:	68 b0 02 00 00       	push   $0x2b0
f010282d:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102832:	e8 54 d8 ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102837:	40                   	inc    %eax
f0102838:	3d 00 04 00 00       	cmp    $0x400,%eax
f010283d:	0f 85 5b ff ff ff    	jne    f010279e <mem_init+0x1201>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102843:	83 ec 0c             	sub    $0xc,%esp
f0102846:	68 ac 4b 10 f0       	push   $0xf0104bac
f010284b:	e8 b9 03 00 00       	call   f0102c09 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102850:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102855:	83 c4 10             	add    $0x10,%esp
f0102858:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010285d:	77 15                	ja     f0102874 <mem_init+0x12d7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010285f:	50                   	push   %eax
f0102860:	68 b8 43 10 f0       	push   $0xf01043b8
f0102865:	68 de 00 00 00       	push   $0xde
f010286a:	68 6c 4c 10 f0       	push   $0xf0104c6c
f010286f:	e8 17 d8 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102874:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102879:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010287c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102881:	e8 da e6 ff ff       	call   f0100f60 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102886:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102889:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010288e:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102891:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102894:	83 ec 0c             	sub    $0xc,%esp
f0102897:	6a 00                	push   $0x0
f0102899:	e8 28 ea ff ff       	call   f01012c6 <page_alloc>
f010289e:	89 c6                	mov    %eax,%esi
f01028a0:	83 c4 10             	add    $0x10,%esp
f01028a3:	85 c0                	test   %eax,%eax
f01028a5:	75 19                	jne    f01028c0 <mem_init+0x1323>
f01028a7:	68 3d 4d 10 f0       	push   $0xf0104d3d
f01028ac:	68 92 4c 10 f0       	push   $0xf0104c92
f01028b1:	68 6b 03 00 00       	push   $0x36b
f01028b6:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01028bb:	e8 cb d7 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01028c0:	83 ec 0c             	sub    $0xc,%esp
f01028c3:	6a 00                	push   $0x0
f01028c5:	e8 fc e9 ff ff       	call   f01012c6 <page_alloc>
f01028ca:	89 c7                	mov    %eax,%edi
f01028cc:	83 c4 10             	add    $0x10,%esp
f01028cf:	85 c0                	test   %eax,%eax
f01028d1:	75 19                	jne    f01028ec <mem_init+0x134f>
f01028d3:	68 53 4d 10 f0       	push   $0xf0104d53
f01028d8:	68 92 4c 10 f0       	push   $0xf0104c92
f01028dd:	68 6c 03 00 00       	push   $0x36c
f01028e2:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01028e7:	e8 9f d7 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01028ec:	83 ec 0c             	sub    $0xc,%esp
f01028ef:	6a 00                	push   $0x0
f01028f1:	e8 d0 e9 ff ff       	call   f01012c6 <page_alloc>
f01028f6:	89 c3                	mov    %eax,%ebx
f01028f8:	83 c4 10             	add    $0x10,%esp
f01028fb:	85 c0                	test   %eax,%eax
f01028fd:	75 19                	jne    f0102918 <mem_init+0x137b>
f01028ff:	68 69 4d 10 f0       	push   $0xf0104d69
f0102904:	68 92 4c 10 f0       	push   $0xf0104c92
f0102909:	68 6d 03 00 00       	push   $0x36d
f010290e:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102913:	e8 73 d7 ff ff       	call   f010008b <_panic>
	page_free(pp0);
f0102918:	83 ec 0c             	sub    $0xc,%esp
f010291b:	56                   	push   %esi
f010291c:	e8 2f ea ff ff       	call   f0101350 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102921:	89 f8                	mov    %edi,%eax
f0102923:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f0102929:	c1 f8 03             	sar    $0x3,%eax
f010292c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010292f:	89 c2                	mov    %eax,%edx
f0102931:	c1 ea 0c             	shr    $0xc,%edx
f0102934:	83 c4 10             	add    $0x10,%esp
f0102937:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f010293d:	72 12                	jb     f0102951 <mem_init+0x13b4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010293f:	50                   	push   %eax
f0102940:	68 74 45 10 f0       	push   $0xf0104574
f0102945:	6a 52                	push   $0x52
f0102947:	68 78 4c 10 f0       	push   $0xf0104c78
f010294c:	e8 3a d7 ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102951:	83 ec 04             	sub    $0x4,%esp
f0102954:	68 00 10 00 00       	push   $0x1000
f0102959:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010295b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102960:	50                   	push   %eax
f0102961:	e8 d3 0d 00 00       	call   f0103739 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102966:	89 d8                	mov    %ebx,%eax
f0102968:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f010296e:	c1 f8 03             	sar    $0x3,%eax
f0102971:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102974:	89 c2                	mov    %eax,%edx
f0102976:	c1 ea 0c             	shr    $0xc,%edx
f0102979:	83 c4 10             	add    $0x10,%esp
f010297c:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f0102982:	72 12                	jb     f0102996 <mem_init+0x13f9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102984:	50                   	push   %eax
f0102985:	68 74 45 10 f0       	push   $0xf0104574
f010298a:	6a 52                	push   $0x52
f010298c:	68 78 4c 10 f0       	push   $0xf0104c78
f0102991:	e8 f5 d6 ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102996:	83 ec 04             	sub    $0x4,%esp
f0102999:	68 00 10 00 00       	push   $0x1000
f010299e:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01029a0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01029a5:	50                   	push   %eax
f01029a6:	e8 8e 0d 00 00       	call   f0103739 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01029ab:	6a 02                	push   $0x2
f01029ad:	68 00 10 00 00       	push   $0x1000
f01029b2:	57                   	push   %edi
f01029b3:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f01029b9:	e8 76 eb ff ff       	call   f0101534 <page_insert>
	assert(pp1->pp_ref == 1);
f01029be:	83 c4 20             	add    $0x20,%esp
f01029c1:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01029c6:	74 19                	je     f01029e1 <mem_init+0x1444>
f01029c8:	68 3a 4e 10 f0       	push   $0xf0104e3a
f01029cd:	68 92 4c 10 f0       	push   $0xf0104c92
f01029d2:	68 72 03 00 00       	push   $0x372
f01029d7:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01029dc:	e8 aa d6 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01029e1:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01029e8:	01 01 01 
f01029eb:	74 19                	je     f0102a06 <mem_init+0x1469>
f01029ed:	68 cc 4b 10 f0       	push   $0xf0104bcc
f01029f2:	68 92 4c 10 f0       	push   $0xf0104c92
f01029f7:	68 73 03 00 00       	push   $0x373
f01029fc:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102a01:	e8 85 d6 ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102a06:	6a 02                	push   $0x2
f0102a08:	68 00 10 00 00       	push   $0x1000
f0102a0d:	53                   	push   %ebx
f0102a0e:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102a14:	e8 1b eb ff ff       	call   f0101534 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102a19:	83 c4 10             	add    $0x10,%esp
f0102a1c:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102a23:	02 02 02 
f0102a26:	74 19                	je     f0102a41 <mem_init+0x14a4>
f0102a28:	68 f0 4b 10 f0       	push   $0xf0104bf0
f0102a2d:	68 92 4c 10 f0       	push   $0xf0104c92
f0102a32:	68 75 03 00 00       	push   $0x375
f0102a37:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102a3c:	e8 4a d6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102a41:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102a46:	74 19                	je     f0102a61 <mem_init+0x14c4>
f0102a48:	68 5c 4e 10 f0       	push   $0xf0104e5c
f0102a4d:	68 92 4c 10 f0       	push   $0xf0104c92
f0102a52:	68 76 03 00 00       	push   $0x376
f0102a57:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102a5c:	e8 2a d6 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102a61:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102a66:	74 19                	je     f0102a81 <mem_init+0x14e4>
f0102a68:	68 a5 4e 10 f0       	push   $0xf0104ea5
f0102a6d:	68 92 4c 10 f0       	push   $0xf0104c92
f0102a72:	68 77 03 00 00       	push   $0x377
f0102a77:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102a7c:	e8 0a d6 ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102a81:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102a88:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a8b:	89 d8                	mov    %ebx,%eax
f0102a8d:	2b 05 4c e9 11 f0    	sub    0xf011e94c,%eax
f0102a93:	c1 f8 03             	sar    $0x3,%eax
f0102a96:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a99:	89 c2                	mov    %eax,%edx
f0102a9b:	c1 ea 0c             	shr    $0xc,%edx
f0102a9e:	3b 15 44 e9 11 f0    	cmp    0xf011e944,%edx
f0102aa4:	72 12                	jb     f0102ab8 <mem_init+0x151b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102aa6:	50                   	push   %eax
f0102aa7:	68 74 45 10 f0       	push   $0xf0104574
f0102aac:	6a 52                	push   $0x52
f0102aae:	68 78 4c 10 f0       	push   $0xf0104c78
f0102ab3:	e8 d3 d5 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ab8:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102abf:	03 03 03 
f0102ac2:	74 19                	je     f0102add <mem_init+0x1540>
f0102ac4:	68 14 4c 10 f0       	push   $0xf0104c14
f0102ac9:	68 92 4c 10 f0       	push   $0xf0104c92
f0102ace:	68 79 03 00 00       	push   $0x379
f0102ad3:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102ad8:	e8 ae d5 ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102add:	83 ec 08             	sub    $0x8,%esp
f0102ae0:	68 00 10 00 00       	push   $0x1000
f0102ae5:	ff 35 48 e9 11 f0    	pushl  0xf011e948
f0102aeb:	e8 f7 e9 ff ff       	call   f01014e7 <page_remove>
	assert(pp2->pp_ref == 0);
f0102af0:	83 c4 10             	add    $0x10,%esp
f0102af3:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102af8:	74 19                	je     f0102b13 <mem_init+0x1576>
f0102afa:	68 94 4e 10 f0       	push   $0xf0104e94
f0102aff:	68 92 4c 10 f0       	push   $0xf0104c92
f0102b04:	68 7b 03 00 00       	push   $0x37b
f0102b09:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102b0e:	e8 78 d5 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b13:	a1 48 e9 11 f0       	mov    0xf011e948,%eax
f0102b18:	8b 08                	mov    (%eax),%ecx
f0102b1a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b20:	89 f2                	mov    %esi,%edx
f0102b22:	2b 15 4c e9 11 f0    	sub    0xf011e94c,%edx
f0102b28:	c1 fa 03             	sar    $0x3,%edx
f0102b2b:	c1 e2 0c             	shl    $0xc,%edx
f0102b2e:	39 d1                	cmp    %edx,%ecx
f0102b30:	74 19                	je     f0102b4b <mem_init+0x15ae>
f0102b32:	68 90 47 10 f0       	push   $0xf0104790
f0102b37:	68 92 4c 10 f0       	push   $0xf0104c92
f0102b3c:	68 7e 03 00 00       	push   $0x37e
f0102b41:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102b46:	e8 40 d5 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102b4b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b51:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102b56:	74 19                	je     f0102b71 <mem_init+0x15d4>
f0102b58:	68 4b 4e 10 f0       	push   $0xf0104e4b
f0102b5d:	68 92 4c 10 f0       	push   $0xf0104c92
f0102b62:	68 80 03 00 00       	push   $0x380
f0102b67:	68 6c 4c 10 f0       	push   $0xf0104c6c
f0102b6c:	e8 1a d5 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102b71:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102b77:	83 ec 0c             	sub    $0xc,%esp
f0102b7a:	56                   	push   %esi
f0102b7b:	e8 d0 e7 ff ff       	call   f0101350 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102b80:	c7 04 24 40 4c 10 f0 	movl   $0xf0104c40,(%esp)
f0102b87:	e8 7d 00 00 00       	call   f0102c09 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102b8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b8f:	5b                   	pop    %ebx
f0102b90:	5e                   	pop    %esi
f0102b91:	5f                   	pop    %edi
f0102b92:	c9                   	leave  
f0102b93:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102b94:	89 f2                	mov    %esi,%edx
f0102b96:	89 d8                	mov    %ebx,%eax
f0102b98:	e8 3a e3 ff ff       	call   f0100ed7 <check_va2pa>
f0102b9d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102ba3:	e9 9b fb ff ff       	jmp    f0102743 <mem_init+0x11a6>

f0102ba8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102ba8:	55                   	push   %ebp
f0102ba9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102bab:	ba 70 00 00 00       	mov    $0x70,%edx
f0102bb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bb3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102bb4:	b2 71                	mov    $0x71,%dl
f0102bb6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102bb7:	0f b6 c0             	movzbl %al,%eax
}
f0102bba:	c9                   	leave  
f0102bbb:	c3                   	ret    

f0102bbc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102bbc:	55                   	push   %ebp
f0102bbd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102bbf:	ba 70 00 00 00       	mov    $0x70,%edx
f0102bc4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bc7:	ee                   	out    %al,(%dx)
f0102bc8:	b2 71                	mov    $0x71,%dl
f0102bca:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bcd:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102bce:	c9                   	leave  
f0102bcf:	c3                   	ret    

f0102bd0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102bd0:	55                   	push   %ebp
f0102bd1:	89 e5                	mov    %esp,%ebp
f0102bd3:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102bd6:	ff 75 08             	pushl  0x8(%ebp)
f0102bd9:	e8 c8 d9 ff ff       	call   f01005a6 <cputchar>
f0102bde:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0102be1:	c9                   	leave  
f0102be2:	c3                   	ret    

f0102be3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102be3:	55                   	push   %ebp
f0102be4:	89 e5                	mov    %esp,%ebp
f0102be6:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102be9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102bf0:	ff 75 0c             	pushl  0xc(%ebp)
f0102bf3:	ff 75 08             	pushl  0x8(%ebp)
f0102bf6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102bf9:	50                   	push   %eax
f0102bfa:	68 d0 2b 10 f0       	push   $0xf0102bd0
f0102bff:	e8 9d 04 00 00       	call   f01030a1 <vprintfmt>
	return cnt;
}
f0102c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102c07:	c9                   	leave  
f0102c08:	c3                   	ret    

f0102c09 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102c09:	55                   	push   %ebp
f0102c0a:	89 e5                	mov    %esp,%ebp
f0102c0c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102c0f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102c12:	50                   	push   %eax
f0102c13:	ff 75 08             	pushl  0x8(%ebp)
f0102c16:	e8 c8 ff ff ff       	call   f0102be3 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102c1b:	c9                   	leave  
f0102c1c:	c3                   	ret    
f0102c1d:	00 00                	add    %al,(%eax)
	...

f0102c20 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102c20:	55                   	push   %ebp
f0102c21:	89 e5                	mov    %esp,%ebp
f0102c23:	57                   	push   %edi
f0102c24:	56                   	push   %esi
f0102c25:	53                   	push   %ebx
f0102c26:	83 ec 14             	sub    $0x14,%esp
f0102c29:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102c2c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102c2f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102c32:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102c35:	8b 1a                	mov    (%edx),%ebx
f0102c37:	8b 01                	mov    (%ecx),%eax
f0102c39:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0102c3c:	39 c3                	cmp    %eax,%ebx
f0102c3e:	0f 8f 97 00 00 00    	jg     f0102cdb <stab_binsearch+0xbb>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0102c44:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102c4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c4e:	01 d8                	add    %ebx,%eax
f0102c50:	89 c7                	mov    %eax,%edi
f0102c52:	c1 ef 1f             	shr    $0x1f,%edi
f0102c55:	01 c7                	add    %eax,%edi
f0102c57:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102c59:	39 df                	cmp    %ebx,%edi
f0102c5b:	7c 31                	jl     f0102c8e <stab_binsearch+0x6e>
f0102c5d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0102c60:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102c63:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0102c68:	39 f0                	cmp    %esi,%eax
f0102c6a:	0f 84 b3 00 00 00    	je     f0102d23 <stab_binsearch+0x103>
f0102c70:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102c74:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102c78:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102c7a:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102c7b:	39 d8                	cmp    %ebx,%eax
f0102c7d:	7c 0f                	jl     f0102c8e <stab_binsearch+0x6e>
f0102c7f:	0f b6 0a             	movzbl (%edx),%ecx
f0102c82:	83 ea 0c             	sub    $0xc,%edx
f0102c85:	39 f1                	cmp    %esi,%ecx
f0102c87:	75 f1                	jne    f0102c7a <stab_binsearch+0x5a>
f0102c89:	e9 97 00 00 00       	jmp    f0102d25 <stab_binsearch+0x105>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102c8e:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0102c91:	eb 39                	jmp    f0102ccc <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102c93:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102c96:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0102c98:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102c9b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102ca2:	eb 28                	jmp    f0102ccc <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102ca4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102ca7:	76 12                	jbe    f0102cbb <stab_binsearch+0x9b>
			*region_right = m - 1;
f0102ca9:	48                   	dec    %eax
f0102caa:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102cad:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102cb0:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102cb2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0102cb9:	eb 11                	jmp    f0102ccc <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102cbb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102cbe:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0102cc0:	ff 45 0c             	incl   0xc(%ebp)
f0102cc3:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102cc5:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102ccc:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0102ccf:	0f 8d 76 ff ff ff    	jge    f0102c4b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102cd5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102cd9:	75 0d                	jne    f0102ce8 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0102cdb:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102cde:	8b 03                	mov    (%ebx),%eax
f0102ce0:	48                   	dec    %eax
f0102ce1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102ce4:	89 02                	mov    %eax,(%edx)
f0102ce6:	eb 55                	jmp    f0102d3d <stab_binsearch+0x11d>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102ce8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102ceb:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102ced:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102cf0:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102cf2:	39 c1                	cmp    %eax,%ecx
f0102cf4:	7d 26                	jge    f0102d1c <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102cf6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102cf9:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0102cfc:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0102d01:	39 f2                	cmp    %esi,%edx
f0102d03:	74 17                	je     f0102d1c <stab_binsearch+0xfc>
f0102d05:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102d09:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102d0d:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102d0e:	39 c1                	cmp    %eax,%ecx
f0102d10:	7d 0a                	jge    f0102d1c <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102d12:	0f b6 1a             	movzbl (%edx),%ebx
f0102d15:	83 ea 0c             	sub    $0xc,%edx
f0102d18:	39 f3                	cmp    %esi,%ebx
f0102d1a:	75 f1                	jne    f0102d0d <stab_binsearch+0xed>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102d1c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102d1f:	89 02                	mov    %eax,(%edx)
f0102d21:	eb 1a                	jmp    f0102d3d <stab_binsearch+0x11d>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102d23:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102d25:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102d28:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0102d2b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102d2f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102d32:	0f 82 5b ff ff ff    	jb     f0102c93 <stab_binsearch+0x73>
f0102d38:	e9 67 ff ff ff       	jmp    f0102ca4 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0102d3d:	83 c4 14             	add    $0x14,%esp
f0102d40:	5b                   	pop    %ebx
f0102d41:	5e                   	pop    %esi
f0102d42:	5f                   	pop    %edi
f0102d43:	c9                   	leave  
f0102d44:	c3                   	ret    

f0102d45 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102d45:	55                   	push   %ebp
f0102d46:	89 e5                	mov    %esp,%ebp
f0102d48:	57                   	push   %edi
f0102d49:	56                   	push   %esi
f0102d4a:	53                   	push   %ebx
f0102d4b:	83 ec 2c             	sub    $0x2c,%esp
f0102d4e:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102d54:	c7 03 2e 4f 10 f0    	movl   $0xf0104f2e,(%ebx)
	info->eip_line = 0;
f0102d5a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102d61:	c7 43 08 2e 4f 10 f0 	movl   $0xf0104f2e,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102d68:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102d6f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102d72:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102d79:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102d7f:	76 12                	jbe    f0102d93 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102d81:	b8 ad 3d 11 f0       	mov    $0xf0113dad,%eax
f0102d86:	3d 91 c4 10 f0       	cmp    $0xf010c491,%eax
f0102d8b:	0f 86 90 01 00 00    	jbe    f0102f21 <debuginfo_eip+0x1dc>
f0102d91:	eb 14                	jmp    f0102da7 <debuginfo_eip+0x62>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102d93:	83 ec 04             	sub    $0x4,%esp
f0102d96:	68 38 4f 10 f0       	push   $0xf0104f38
f0102d9b:	6a 7f                	push   $0x7f
f0102d9d:	68 45 4f 10 f0       	push   $0xf0104f45
f0102da2:	e8 e4 d2 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102da7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102dac:	80 3d ac 3d 11 f0 00 	cmpb   $0x0,0xf0113dac
f0102db3:	0f 85 74 01 00 00    	jne    f0102f2d <debuginfo_eip+0x1e8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102db9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102dc0:	b8 90 c4 10 f0       	mov    $0xf010c490,%eax
f0102dc5:	2d 64 51 10 f0       	sub    $0xf0105164,%eax
f0102dca:	c1 f8 02             	sar    $0x2,%eax
f0102dcd:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102dd3:	48                   	dec    %eax
f0102dd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102dd7:	83 ec 08             	sub    $0x8,%esp
f0102dda:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102ddd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102de0:	56                   	push   %esi
f0102de1:	6a 64                	push   $0x64
f0102de3:	b8 64 51 10 f0       	mov    $0xf0105164,%eax
f0102de8:	e8 33 fe ff ff       	call   f0102c20 <stab_binsearch>
	if (lfile == 0)
f0102ded:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102df0:	83 c4 10             	add    $0x10,%esp
		return -1;
f0102df3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0102df8:	85 d2                	test   %edx,%edx
f0102dfa:	0f 84 2d 01 00 00    	je     f0102f2d <debuginfo_eip+0x1e8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102e00:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0102e03:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e06:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102e09:	83 ec 08             	sub    $0x8,%esp
f0102e0c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102e0f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102e12:	56                   	push   %esi
f0102e13:	6a 24                	push   $0x24
f0102e15:	b8 64 51 10 f0       	mov    $0xf0105164,%eax
f0102e1a:	e8 01 fe ff ff       	call   f0102c20 <stab_binsearch>

	if (lfun <= rfun) {
f0102e1f:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0102e22:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e25:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e28:	83 c4 10             	add    $0x10,%esp
f0102e2b:	39 c7                	cmp    %eax,%edi
f0102e2d:	7f 32                	jg     f0102e61 <debuginfo_eip+0x11c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102e2f:	89 f9                	mov    %edi,%ecx
f0102e31:	6b c7 0c             	imul   $0xc,%edi,%eax
f0102e34:	8b 80 64 51 10 f0    	mov    -0xfefae9c(%eax),%eax
f0102e3a:	ba ad 3d 11 f0       	mov    $0xf0113dad,%edx
f0102e3f:	81 ea 91 c4 10 f0    	sub    $0xf010c491,%edx
f0102e45:	39 d0                	cmp    %edx,%eax
f0102e47:	73 08                	jae    f0102e51 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102e49:	05 91 c4 10 f0       	add    $0xf010c491,%eax
f0102e4e:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102e51:	6b c9 0c             	imul   $0xc,%ecx,%ecx
f0102e54:	8b 81 6c 51 10 f0    	mov    -0xfefae94(%ecx),%eax
f0102e5a:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102e5d:	29 c6                	sub    %eax,%esi
f0102e5f:	eb 0c                	jmp    f0102e6d <debuginfo_eip+0x128>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102e61:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102e64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
f0102e67:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102e6a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102e6d:	83 ec 08             	sub    $0x8,%esp
f0102e70:	6a 3a                	push   $0x3a
f0102e72:	ff 73 08             	pushl  0x8(%ebx)
f0102e75:	e8 9d 08 00 00       	call   f0103717 <strfind>
f0102e7a:	2b 43 08             	sub    0x8(%ebx),%eax
f0102e7d:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    lfun = lline;
f0102e80:	89 7d dc             	mov    %edi,-0x24(%ebp)
    rfun = rline;
f0102e83:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e86:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
f0102e89:	83 c4 08             	add    $0x8,%esp
f0102e8c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102e8f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102e92:	56                   	push   %esi
f0102e93:	6a 44                	push   $0x44
f0102e95:	b8 64 51 10 f0       	mov    $0xf0105164,%eax
f0102e9a:	e8 81 fd ff ff       	call   f0102c20 <stab_binsearch>
    if (lfun <= rfun) {
f0102e9f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102ea2:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[lfun].n_desc;
        lline = lfun;
        rline = rfun;
    } else {
        // not found
        return -1;
f0102ea5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	which one.
	// Your code here.
    lfun = lline;
    rfun = rline;
    stab_binsearch(stabs, &lfun, &rfun, N_SLINE, addr);
    if (lfun <= rfun) {
f0102eaa:	3b 55 d8             	cmp    -0x28(%ebp),%edx
f0102ead:	7f 7e                	jg     f0102f2d <debuginfo_eip+0x1e8>
        // stab[lfun] points to right SLINE entry
        info->eip_line = stabs[lfun].n_desc;
f0102eaf:	6b c2 0c             	imul   $0xc,%edx,%eax
f0102eb2:	05 64 51 10 f0       	add    $0xf0105164,%eax
f0102eb7:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0102ebb:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102ebe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0102ec1:	83 c0 08             	add    $0x8,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102ec4:	eb 04                	jmp    f0102eca <debuginfo_eip+0x185>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0102ec6:	4a                   	dec    %edx
f0102ec7:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102eca:	39 f2                	cmp    %esi,%edx
f0102ecc:	7c 1b                	jl     f0102ee9 <debuginfo_eip+0x1a4>
	       && stabs[lline].n_type != N_SOL
f0102ece:	8a 48 fc             	mov    -0x4(%eax),%cl
f0102ed1:	80 f9 84             	cmp    $0x84,%cl
f0102ed4:	74 5f                	je     f0102f35 <debuginfo_eip+0x1f0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102ed6:	80 f9 64             	cmp    $0x64,%cl
f0102ed9:	75 eb                	jne    f0102ec6 <debuginfo_eip+0x181>
f0102edb:	83 38 00             	cmpl   $0x0,(%eax)
f0102ede:	74 e6                	je     f0102ec6 <debuginfo_eip+0x181>
f0102ee0:	eb 53                	jmp    f0102f35 <debuginfo_eip+0x1f0>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102ee2:	05 91 c4 10 f0       	add    $0xf010c491,%eax
f0102ee7:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102ee9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102eec:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102eef:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102ef4:	39 ca                	cmp    %ecx,%edx
f0102ef6:	7d 35                	jge    f0102f2d <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
f0102ef8:	8d 42 01             	lea    0x1(%edx),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0102efb:	6b d0 0c             	imul   $0xc,%eax,%edx
f0102efe:	81 c2 68 51 10 f0    	add    $0xf0105168,%edx
f0102f04:	89 ce                	mov    %ecx,%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102f06:	eb 04                	jmp    f0102f0c <debuginfo_eip+0x1c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102f08:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0102f0b:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102f0c:	39 f0                	cmp    %esi,%eax
f0102f0e:	7d 18                	jge    f0102f28 <debuginfo_eip+0x1e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102f10:	8a 0a                	mov    (%edx),%cl
f0102f12:	83 c2 0c             	add    $0xc,%edx
f0102f15:	80 f9 a0             	cmp    $0xa0,%cl
f0102f18:	74 ee                	je     f0102f08 <debuginfo_eip+0x1c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102f1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f1f:	eb 0c                	jmp    f0102f2d <debuginfo_eip+0x1e8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102f21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102f26:	eb 05                	jmp    f0102f2d <debuginfo_eip+0x1e8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102f28:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f30:	5b                   	pop    %ebx
f0102f31:	5e                   	pop    %esi
f0102f32:	5f                   	pop    %edi
f0102f33:	c9                   	leave  
f0102f34:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102f35:	6b d2 0c             	imul   $0xc,%edx,%edx
f0102f38:	8b 82 64 51 10 f0    	mov    -0xfefae9c(%edx),%eax
f0102f3e:	ba ad 3d 11 f0       	mov    $0xf0113dad,%edx
f0102f43:	81 ea 91 c4 10 f0    	sub    $0xf010c491,%edx
f0102f49:	39 d0                	cmp    %edx,%eax
f0102f4b:	72 95                	jb     f0102ee2 <debuginfo_eip+0x19d>
f0102f4d:	eb 9a                	jmp    f0102ee9 <debuginfo_eip+0x1a4>
	...

f0102f50 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102f50:	55                   	push   %ebp
f0102f51:	89 e5                	mov    %esp,%ebp
f0102f53:	57                   	push   %edi
f0102f54:	56                   	push   %esi
f0102f55:	53                   	push   %ebx
f0102f56:	83 ec 2c             	sub    $0x2c,%esp
f0102f59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102f5c:	89 d6                	mov    %edx,%esi
f0102f5e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f61:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102f64:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f67:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102f6a:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f6d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102f70:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102f73:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102f76:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102f7d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102f80:	72 0c                	jb     f0102f8e <printnum+0x3e>
f0102f82:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0102f85:	76 07                	jbe    f0102f8e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102f87:	4b                   	dec    %ebx
f0102f88:	85 db                	test   %ebx,%ebx
f0102f8a:	7f 31                	jg     f0102fbd <printnum+0x6d>
f0102f8c:	eb 3f                	jmp    f0102fcd <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102f8e:	83 ec 0c             	sub    $0xc,%esp
f0102f91:	57                   	push   %edi
f0102f92:	4b                   	dec    %ebx
f0102f93:	53                   	push   %ebx
f0102f94:	50                   	push   %eax
f0102f95:	83 ec 08             	sub    $0x8,%esp
f0102f98:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102f9b:	ff 75 d0             	pushl  -0x30(%ebp)
f0102f9e:	ff 75 dc             	pushl  -0x24(%ebp)
f0102fa1:	ff 75 d8             	pushl  -0x28(%ebp)
f0102fa4:	e8 97 09 00 00       	call   f0103940 <__udivdi3>
f0102fa9:	83 c4 18             	add    $0x18,%esp
f0102fac:	52                   	push   %edx
f0102fad:	50                   	push   %eax
f0102fae:	89 f2                	mov    %esi,%edx
f0102fb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102fb3:	e8 98 ff ff ff       	call   f0102f50 <printnum>
f0102fb8:	83 c4 20             	add    $0x20,%esp
f0102fbb:	eb 10                	jmp    f0102fcd <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102fbd:	83 ec 08             	sub    $0x8,%esp
f0102fc0:	56                   	push   %esi
f0102fc1:	57                   	push   %edi
f0102fc2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102fc5:	4b                   	dec    %ebx
f0102fc6:	83 c4 10             	add    $0x10,%esp
f0102fc9:	85 db                	test   %ebx,%ebx
f0102fcb:	7f f0                	jg     f0102fbd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102fcd:	83 ec 08             	sub    $0x8,%esp
f0102fd0:	56                   	push   %esi
f0102fd1:	83 ec 04             	sub    $0x4,%esp
f0102fd4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102fd7:	ff 75 d0             	pushl  -0x30(%ebp)
f0102fda:	ff 75 dc             	pushl  -0x24(%ebp)
f0102fdd:	ff 75 d8             	pushl  -0x28(%ebp)
f0102fe0:	e8 77 0a 00 00       	call   f0103a5c <__umoddi3>
f0102fe5:	83 c4 14             	add    $0x14,%esp
f0102fe8:	0f be 80 53 4f 10 f0 	movsbl -0xfefb0ad(%eax),%eax
f0102fef:	50                   	push   %eax
f0102ff0:	ff 55 e4             	call   *-0x1c(%ebp)
f0102ff3:	83 c4 10             	add    $0x10,%esp
}
f0102ff6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ff9:	5b                   	pop    %ebx
f0102ffa:	5e                   	pop    %esi
f0102ffb:	5f                   	pop    %edi
f0102ffc:	c9                   	leave  
f0102ffd:	c3                   	ret    

f0102ffe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102ffe:	55                   	push   %ebp
f0102fff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103001:	83 fa 01             	cmp    $0x1,%edx
f0103004:	7e 0e                	jle    f0103014 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103006:	8b 10                	mov    (%eax),%edx
f0103008:	8d 4a 08             	lea    0x8(%edx),%ecx
f010300b:	89 08                	mov    %ecx,(%eax)
f010300d:	8b 02                	mov    (%edx),%eax
f010300f:	8b 52 04             	mov    0x4(%edx),%edx
f0103012:	eb 22                	jmp    f0103036 <getuint+0x38>
	else if (lflag)
f0103014:	85 d2                	test   %edx,%edx
f0103016:	74 10                	je     f0103028 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103018:	8b 10                	mov    (%eax),%edx
f010301a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010301d:	89 08                	mov    %ecx,(%eax)
f010301f:	8b 02                	mov    (%edx),%eax
f0103021:	ba 00 00 00 00       	mov    $0x0,%edx
f0103026:	eb 0e                	jmp    f0103036 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103028:	8b 10                	mov    (%eax),%edx
f010302a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010302d:	89 08                	mov    %ecx,(%eax)
f010302f:	8b 02                	mov    (%edx),%eax
f0103031:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103036:	c9                   	leave  
f0103037:	c3                   	ret    

f0103038 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103038:	55                   	push   %ebp
f0103039:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010303b:	83 fa 01             	cmp    $0x1,%edx
f010303e:	7e 0e                	jle    f010304e <getint+0x16>
		return va_arg(*ap, long long);
f0103040:	8b 10                	mov    (%eax),%edx
f0103042:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103045:	89 08                	mov    %ecx,(%eax)
f0103047:	8b 02                	mov    (%edx),%eax
f0103049:	8b 52 04             	mov    0x4(%edx),%edx
f010304c:	eb 1a                	jmp    f0103068 <getint+0x30>
	else if (lflag)
f010304e:	85 d2                	test   %edx,%edx
f0103050:	74 0c                	je     f010305e <getint+0x26>
		return va_arg(*ap, long);
f0103052:	8b 10                	mov    (%eax),%edx
f0103054:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103057:	89 08                	mov    %ecx,(%eax)
f0103059:	8b 02                	mov    (%edx),%eax
f010305b:	99                   	cltd   
f010305c:	eb 0a                	jmp    f0103068 <getint+0x30>
	else
		return va_arg(*ap, int);
f010305e:	8b 10                	mov    (%eax),%edx
f0103060:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103063:	89 08                	mov    %ecx,(%eax)
f0103065:	8b 02                	mov    (%edx),%eax
f0103067:	99                   	cltd   
}
f0103068:	c9                   	leave  
f0103069:	c3                   	ret    

f010306a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010306a:	55                   	push   %ebp
f010306b:	89 e5                	mov    %esp,%ebp
f010306d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103070:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103073:	8b 10                	mov    (%eax),%edx
f0103075:	3b 50 04             	cmp    0x4(%eax),%edx
f0103078:	73 08                	jae    f0103082 <sprintputch+0x18>
		*b->buf++ = ch;
f010307a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010307d:	88 0a                	mov    %cl,(%edx)
f010307f:	42                   	inc    %edx
f0103080:	89 10                	mov    %edx,(%eax)
}
f0103082:	c9                   	leave  
f0103083:	c3                   	ret    

f0103084 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103084:	55                   	push   %ebp
f0103085:	89 e5                	mov    %esp,%ebp
f0103087:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010308a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010308d:	50                   	push   %eax
f010308e:	ff 75 10             	pushl  0x10(%ebp)
f0103091:	ff 75 0c             	pushl  0xc(%ebp)
f0103094:	ff 75 08             	pushl  0x8(%ebp)
f0103097:	e8 05 00 00 00       	call   f01030a1 <vprintfmt>
	va_end(ap);
f010309c:	83 c4 10             	add    $0x10,%esp
}
f010309f:	c9                   	leave  
f01030a0:	c3                   	ret    

f01030a1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01030a1:	55                   	push   %ebp
f01030a2:	89 e5                	mov    %esp,%ebp
f01030a4:	57                   	push   %edi
f01030a5:	56                   	push   %esi
f01030a6:	53                   	push   %ebx
f01030a7:	83 ec 2c             	sub    $0x2c,%esp
f01030aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01030ad:	8b 75 10             	mov    0x10(%ebp),%esi
f01030b0:	eb 13                	jmp    f01030c5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01030b2:	85 c0                	test   %eax,%eax
f01030b4:	0f 84 6d 03 00 00    	je     f0103427 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
f01030ba:	83 ec 08             	sub    $0x8,%esp
f01030bd:	57                   	push   %edi
f01030be:	50                   	push   %eax
f01030bf:	ff 55 08             	call   *0x8(%ebp)
f01030c2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01030c5:	0f b6 06             	movzbl (%esi),%eax
f01030c8:	46                   	inc    %esi
f01030c9:	83 f8 25             	cmp    $0x25,%eax
f01030cc:	75 e4                	jne    f01030b2 <vprintfmt+0x11>
f01030ce:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f01030d2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01030d9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f01030e0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01030e7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01030ec:	eb 28                	jmp    f0103116 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01030ee:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01030f0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f01030f4:	eb 20                	jmp    f0103116 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01030f6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01030f8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f01030fc:	eb 18                	jmp    f0103116 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01030fe:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103100:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103107:	eb 0d                	jmp    f0103116 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103109:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010310c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010310f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103116:	8a 06                	mov    (%esi),%al
f0103118:	0f b6 d0             	movzbl %al,%edx
f010311b:	8d 5e 01             	lea    0x1(%esi),%ebx
f010311e:	83 e8 23             	sub    $0x23,%eax
f0103121:	3c 55                	cmp    $0x55,%al
f0103123:	0f 87 e0 02 00 00    	ja     f0103409 <vprintfmt+0x368>
f0103129:	0f b6 c0             	movzbl %al,%eax
f010312c:	ff 24 85 e0 4f 10 f0 	jmp    *-0xfefb020(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103133:	83 ea 30             	sub    $0x30,%edx
f0103136:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0103139:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f010313c:	8d 50 d0             	lea    -0x30(%eax),%edx
f010313f:	83 fa 09             	cmp    $0x9,%edx
f0103142:	77 44                	ja     f0103188 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103144:	89 de                	mov    %ebx,%esi
f0103146:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103149:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f010314a:	8d 14 92             	lea    (%edx,%edx,4),%edx
f010314d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103151:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103154:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0103157:	83 fb 09             	cmp    $0x9,%ebx
f010315a:	76 ed                	jbe    f0103149 <vprintfmt+0xa8>
f010315c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010315f:	eb 29                	jmp    f010318a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103161:	8b 45 14             	mov    0x14(%ebp),%eax
f0103164:	8d 50 04             	lea    0x4(%eax),%edx
f0103167:	89 55 14             	mov    %edx,0x14(%ebp)
f010316a:	8b 00                	mov    (%eax),%eax
f010316c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010316f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103171:	eb 17                	jmp    f010318a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
f0103173:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103177:	78 85                	js     f01030fe <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103179:	89 de                	mov    %ebx,%esi
f010317b:	eb 99                	jmp    f0103116 <vprintfmt+0x75>
f010317d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010317f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0103186:	eb 8e                	jmp    f0103116 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103188:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f010318a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010318e:	79 86                	jns    f0103116 <vprintfmt+0x75>
f0103190:	e9 74 ff ff ff       	jmp    f0103109 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103195:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103196:	89 de                	mov    %ebx,%esi
f0103198:	e9 79 ff ff ff       	jmp    f0103116 <vprintfmt+0x75>
f010319d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01031a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01031a3:	8d 50 04             	lea    0x4(%eax),%edx
f01031a6:	89 55 14             	mov    %edx,0x14(%ebp)
f01031a9:	83 ec 08             	sub    $0x8,%esp
f01031ac:	57                   	push   %edi
f01031ad:	ff 30                	pushl  (%eax)
f01031af:	ff 55 08             	call   *0x8(%ebp)
			break;
f01031b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031b5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01031b8:	e9 08 ff ff ff       	jmp    f01030c5 <vprintfmt+0x24>
f01031bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01031c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01031c3:	8d 50 04             	lea    0x4(%eax),%edx
f01031c6:	89 55 14             	mov    %edx,0x14(%ebp)
f01031c9:	8b 00                	mov    (%eax),%eax
f01031cb:	85 c0                	test   %eax,%eax
f01031cd:	79 02                	jns    f01031d1 <vprintfmt+0x130>
f01031cf:	f7 d8                	neg    %eax
f01031d1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01031d3:	83 f8 06             	cmp    $0x6,%eax
f01031d6:	7f 0b                	jg     f01031e3 <vprintfmt+0x142>
f01031d8:	8b 04 85 38 51 10 f0 	mov    -0xfefaec8(,%eax,4),%eax
f01031df:	85 c0                	test   %eax,%eax
f01031e1:	75 1a                	jne    f01031fd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f01031e3:	52                   	push   %edx
f01031e4:	68 6b 4f 10 f0       	push   $0xf0104f6b
f01031e9:	57                   	push   %edi
f01031ea:	ff 75 08             	pushl  0x8(%ebp)
f01031ed:	e8 92 fe ff ff       	call   f0103084 <printfmt>
f01031f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031f5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01031f8:	e9 c8 fe ff ff       	jmp    f01030c5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
f01031fd:	50                   	push   %eax
f01031fe:	68 a4 4c 10 f0       	push   $0xf0104ca4
f0103203:	57                   	push   %edi
f0103204:	ff 75 08             	pushl  0x8(%ebp)
f0103207:	e8 78 fe ff ff       	call   f0103084 <printfmt>
f010320c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010320f:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103212:	e9 ae fe ff ff       	jmp    f01030c5 <vprintfmt+0x24>
f0103217:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f010321a:	89 de                	mov    %ebx,%esi
f010321c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010321f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103222:	8b 45 14             	mov    0x14(%ebp),%eax
f0103225:	8d 50 04             	lea    0x4(%eax),%edx
f0103228:	89 55 14             	mov    %edx,0x14(%ebp)
f010322b:	8b 00                	mov    (%eax),%eax
f010322d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103230:	85 c0                	test   %eax,%eax
f0103232:	75 07                	jne    f010323b <vprintfmt+0x19a>
				p = "(null)";
f0103234:	c7 45 d0 64 4f 10 f0 	movl   $0xf0104f64,-0x30(%ebp)
			if (width > 0 && padc != '-')
f010323b:	85 db                	test   %ebx,%ebx
f010323d:	7e 42                	jle    f0103281 <vprintfmt+0x1e0>
f010323f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0103243:	74 3c                	je     f0103281 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103245:	83 ec 08             	sub    $0x8,%esp
f0103248:	51                   	push   %ecx
f0103249:	ff 75 d0             	pushl  -0x30(%ebp)
f010324c:	e8 3f 03 00 00       	call   f0103590 <strnlen>
f0103251:	29 c3                	sub    %eax,%ebx
f0103253:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103256:	83 c4 10             	add    $0x10,%esp
f0103259:	85 db                	test   %ebx,%ebx
f010325b:	7e 24                	jle    f0103281 <vprintfmt+0x1e0>
					putch(padc, putdat);
f010325d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
f0103261:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0103264:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103267:	83 ec 08             	sub    $0x8,%esp
f010326a:	57                   	push   %edi
f010326b:	53                   	push   %ebx
f010326c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010326f:	4e                   	dec    %esi
f0103270:	83 c4 10             	add    $0x10,%esp
f0103273:	85 f6                	test   %esi,%esi
f0103275:	7f f0                	jg     f0103267 <vprintfmt+0x1c6>
f0103277:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010327a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103281:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103284:	0f be 02             	movsbl (%edx),%eax
f0103287:	85 c0                	test   %eax,%eax
f0103289:	75 47                	jne    f01032d2 <vprintfmt+0x231>
f010328b:	eb 37                	jmp    f01032c4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
f010328d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103291:	74 16                	je     f01032a9 <vprintfmt+0x208>
f0103293:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103296:	83 fa 5e             	cmp    $0x5e,%edx
f0103299:	76 0e                	jbe    f01032a9 <vprintfmt+0x208>
					putch('?', putdat);
f010329b:	83 ec 08             	sub    $0x8,%esp
f010329e:	57                   	push   %edi
f010329f:	6a 3f                	push   $0x3f
f01032a1:	ff 55 08             	call   *0x8(%ebp)
f01032a4:	83 c4 10             	add    $0x10,%esp
f01032a7:	eb 0b                	jmp    f01032b4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
f01032a9:	83 ec 08             	sub    $0x8,%esp
f01032ac:	57                   	push   %edi
f01032ad:	50                   	push   %eax
f01032ae:	ff 55 08             	call   *0x8(%ebp)
f01032b1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01032b4:	ff 4d e4             	decl   -0x1c(%ebp)
f01032b7:	0f be 03             	movsbl (%ebx),%eax
f01032ba:	85 c0                	test   %eax,%eax
f01032bc:	74 03                	je     f01032c1 <vprintfmt+0x220>
f01032be:	43                   	inc    %ebx
f01032bf:	eb 1b                	jmp    f01032dc <vprintfmt+0x23b>
f01032c1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01032c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01032c8:	7f 1e                	jg     f01032e8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032ca:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01032cd:	e9 f3 fd ff ff       	jmp    f01030c5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01032d2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01032d5:	43                   	inc    %ebx
f01032d6:	89 75 dc             	mov    %esi,-0x24(%ebp)
f01032d9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01032dc:	85 f6                	test   %esi,%esi
f01032de:	78 ad                	js     f010328d <vprintfmt+0x1ec>
f01032e0:	4e                   	dec    %esi
f01032e1:	79 aa                	jns    f010328d <vprintfmt+0x1ec>
f01032e3:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01032e6:	eb dc                	jmp    f01032c4 <vprintfmt+0x223>
f01032e8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01032eb:	83 ec 08             	sub    $0x8,%esp
f01032ee:	57                   	push   %edi
f01032ef:	6a 20                	push   $0x20
f01032f1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01032f4:	4b                   	dec    %ebx
f01032f5:	83 c4 10             	add    $0x10,%esp
f01032f8:	85 db                	test   %ebx,%ebx
f01032fa:	7f ef                	jg     f01032eb <vprintfmt+0x24a>
f01032fc:	e9 c4 fd ff ff       	jmp    f01030c5 <vprintfmt+0x24>
f0103301:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103304:	89 ca                	mov    %ecx,%edx
f0103306:	8d 45 14             	lea    0x14(%ebp),%eax
f0103309:	e8 2a fd ff ff       	call   f0103038 <getint>
f010330e:	89 c3                	mov    %eax,%ebx
f0103310:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
f0103312:	85 d2                	test   %edx,%edx
f0103314:	78 0a                	js     f0103320 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103316:	b8 0a 00 00 00       	mov    $0xa,%eax
f010331b:	e9 b0 00 00 00       	jmp    f01033d0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0103320:	83 ec 08             	sub    $0x8,%esp
f0103323:	57                   	push   %edi
f0103324:	6a 2d                	push   $0x2d
f0103326:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103329:	f7 db                	neg    %ebx
f010332b:	83 d6 00             	adc    $0x0,%esi
f010332e:	f7 de                	neg    %esi
f0103330:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103333:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103338:	e9 93 00 00 00       	jmp    f01033d0 <vprintfmt+0x32f>
f010333d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103340:	89 ca                	mov    %ecx,%edx
f0103342:	8d 45 14             	lea    0x14(%ebp),%eax
f0103345:	e8 b4 fc ff ff       	call   f0102ffe <getuint>
f010334a:	89 c3                	mov    %eax,%ebx
f010334c:	89 d6                	mov    %edx,%esi
			base = 10;
f010334e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0103353:	eb 7b                	jmp    f01033d0 <vprintfmt+0x32f>
f0103355:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
f0103358:	89 ca                	mov    %ecx,%edx
f010335a:	8d 45 14             	lea    0x14(%ebp),%eax
f010335d:	e8 d6 fc ff ff       	call   f0103038 <getint>
f0103362:	89 c3                	mov    %eax,%ebx
f0103364:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
f0103366:	85 d2                	test   %edx,%edx
f0103368:	78 07                	js     f0103371 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
f010336a:	b8 08 00 00 00       	mov    $0x8,%eax
f010336f:	eb 5f                	jmp    f01033d0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
f0103371:	83 ec 08             	sub    $0x8,%esp
f0103374:	57                   	push   %edi
f0103375:	6a 2d                	push   $0x2d
f0103377:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
f010337a:	f7 db                	neg    %ebx
f010337c:	83 d6 00             	adc    $0x0,%esi
f010337f:	f7 de                	neg    %esi
f0103381:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
f0103384:	b8 08 00 00 00       	mov    $0x8,%eax
f0103389:	eb 45                	jmp    f01033d0 <vprintfmt+0x32f>
f010338b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
f010338e:	83 ec 08             	sub    $0x8,%esp
f0103391:	57                   	push   %edi
f0103392:	6a 30                	push   $0x30
f0103394:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103397:	83 c4 08             	add    $0x8,%esp
f010339a:	57                   	push   %edi
f010339b:	6a 78                	push   $0x78
f010339d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01033a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01033a3:	8d 50 04             	lea    0x4(%eax),%edx
f01033a6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01033a9:	8b 18                	mov    (%eax),%ebx
f01033ab:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01033b0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01033b3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01033b8:	eb 16                	jmp    f01033d0 <vprintfmt+0x32f>
f01033ba:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01033bd:	89 ca                	mov    %ecx,%edx
f01033bf:	8d 45 14             	lea    0x14(%ebp),%eax
f01033c2:	e8 37 fc ff ff       	call   f0102ffe <getuint>
f01033c7:	89 c3                	mov    %eax,%ebx
f01033c9:	89 d6                	mov    %edx,%esi
			base = 16;
f01033cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01033d0:	83 ec 0c             	sub    $0xc,%esp
f01033d3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f01033d7:	52                   	push   %edx
f01033d8:	ff 75 e4             	pushl  -0x1c(%ebp)
f01033db:	50                   	push   %eax
f01033dc:	56                   	push   %esi
f01033dd:	53                   	push   %ebx
f01033de:	89 fa                	mov    %edi,%edx
f01033e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01033e3:	e8 68 fb ff ff       	call   f0102f50 <printnum>
			break;
f01033e8:	83 c4 20             	add    $0x20,%esp
f01033eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01033ee:	e9 d2 fc ff ff       	jmp    f01030c5 <vprintfmt+0x24>
f01033f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01033f6:	83 ec 08             	sub    $0x8,%esp
f01033f9:	57                   	push   %edi
f01033fa:	52                   	push   %edx
f01033fb:	ff 55 08             	call   *0x8(%ebp)
			break;
f01033fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103401:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103404:	e9 bc fc ff ff       	jmp    f01030c5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103409:	83 ec 08             	sub    $0x8,%esp
f010340c:	57                   	push   %edi
f010340d:	6a 25                	push   $0x25
f010340f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103412:	83 c4 10             	add    $0x10,%esp
f0103415:	eb 02                	jmp    f0103419 <vprintfmt+0x378>
f0103417:	89 c6                	mov    %eax,%esi
f0103419:	8d 46 ff             	lea    -0x1(%esi),%eax
f010341c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103420:	75 f5                	jne    f0103417 <vprintfmt+0x376>
f0103422:	e9 9e fc ff ff       	jmp    f01030c5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
f0103427:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010342a:	5b                   	pop    %ebx
f010342b:	5e                   	pop    %esi
f010342c:	5f                   	pop    %edi
f010342d:	c9                   	leave  
f010342e:	c3                   	ret    

f010342f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010342f:	55                   	push   %ebp
f0103430:	89 e5                	mov    %esp,%ebp
f0103432:	83 ec 18             	sub    $0x18,%esp
f0103435:	8b 45 08             	mov    0x8(%ebp),%eax
f0103438:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010343b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010343e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103442:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103445:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010344c:	85 c0                	test   %eax,%eax
f010344e:	74 26                	je     f0103476 <vsnprintf+0x47>
f0103450:	85 d2                	test   %edx,%edx
f0103452:	7e 29                	jle    f010347d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103454:	ff 75 14             	pushl  0x14(%ebp)
f0103457:	ff 75 10             	pushl  0x10(%ebp)
f010345a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010345d:	50                   	push   %eax
f010345e:	68 6a 30 10 f0       	push   $0xf010306a
f0103463:	e8 39 fc ff ff       	call   f01030a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103468:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010346b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010346e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103471:	83 c4 10             	add    $0x10,%esp
f0103474:	eb 0c                	jmp    f0103482 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103476:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010347b:	eb 05                	jmp    f0103482 <vsnprintf+0x53>
f010347d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103482:	c9                   	leave  
f0103483:	c3                   	ret    

f0103484 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103484:	55                   	push   %ebp
f0103485:	89 e5                	mov    %esp,%ebp
f0103487:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010348a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010348d:	50                   	push   %eax
f010348e:	ff 75 10             	pushl  0x10(%ebp)
f0103491:	ff 75 0c             	pushl  0xc(%ebp)
f0103494:	ff 75 08             	pushl  0x8(%ebp)
f0103497:	e8 93 ff ff ff       	call   f010342f <vsnprintf>
	va_end(ap);

	return rc;
}
f010349c:	c9                   	leave  
f010349d:	c3                   	ret    
	...

f01034a0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01034a0:	55                   	push   %ebp
f01034a1:	89 e5                	mov    %esp,%ebp
f01034a3:	57                   	push   %edi
f01034a4:	56                   	push   %esi
f01034a5:	53                   	push   %ebx
f01034a6:	83 ec 0c             	sub    $0xc,%esp
f01034a9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01034ac:	85 c0                	test   %eax,%eax
f01034ae:	74 11                	je     f01034c1 <readline+0x21>
		cprintf("%s", prompt);
f01034b0:	83 ec 08             	sub    $0x8,%esp
f01034b3:	50                   	push   %eax
f01034b4:	68 a4 4c 10 f0       	push   $0xf0104ca4
f01034b9:	e8 4b f7 ff ff       	call   f0102c09 <cprintf>
f01034be:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01034c1:	83 ec 0c             	sub    $0xc,%esp
f01034c4:	6a 00                	push   $0x0
f01034c6:	e8 fc d0 ff ff       	call   f01005c7 <iscons>
f01034cb:	89 c7                	mov    %eax,%edi
f01034cd:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01034d0:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01034d5:	e8 dc d0 ff ff       	call   f01005b6 <getchar>
f01034da:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01034dc:	85 c0                	test   %eax,%eax
f01034de:	79 18                	jns    f01034f8 <readline+0x58>
			cprintf("read error: %e\n", c);
f01034e0:	83 ec 08             	sub    $0x8,%esp
f01034e3:	50                   	push   %eax
f01034e4:	68 54 51 10 f0       	push   $0xf0105154
f01034e9:	e8 1b f7 ff ff       	call   f0102c09 <cprintf>
			return NULL;
f01034ee:	83 c4 10             	add    $0x10,%esp
f01034f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01034f6:	eb 6f                	jmp    f0103567 <readline+0xc7>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01034f8:	83 f8 08             	cmp    $0x8,%eax
f01034fb:	74 05                	je     f0103502 <readline+0x62>
f01034fd:	83 f8 7f             	cmp    $0x7f,%eax
f0103500:	75 18                	jne    f010351a <readline+0x7a>
f0103502:	85 f6                	test   %esi,%esi
f0103504:	7e 14                	jle    f010351a <readline+0x7a>
			if (echoing)
f0103506:	85 ff                	test   %edi,%edi
f0103508:	74 0d                	je     f0103517 <readline+0x77>
				cputchar('\b');
f010350a:	83 ec 0c             	sub    $0xc,%esp
f010350d:	6a 08                	push   $0x8
f010350f:	e8 92 d0 ff ff       	call   f01005a6 <cputchar>
f0103514:	83 c4 10             	add    $0x10,%esp
			i--;
f0103517:	4e                   	dec    %esi
f0103518:	eb bb                	jmp    f01034d5 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010351a:	83 fb 1f             	cmp    $0x1f,%ebx
f010351d:	7e 21                	jle    f0103540 <readline+0xa0>
f010351f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103525:	7f 19                	jg     f0103540 <readline+0xa0>
			if (echoing)
f0103527:	85 ff                	test   %edi,%edi
f0103529:	74 0c                	je     f0103537 <readline+0x97>
				cputchar(c);
f010352b:	83 ec 0c             	sub    $0xc,%esp
f010352e:	53                   	push   %ebx
f010352f:	e8 72 d0 ff ff       	call   f01005a6 <cputchar>
f0103534:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103537:	88 9e 40 e5 11 f0    	mov    %bl,-0xfee1ac0(%esi)
f010353d:	46                   	inc    %esi
f010353e:	eb 95                	jmp    f01034d5 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103540:	83 fb 0a             	cmp    $0xa,%ebx
f0103543:	74 05                	je     f010354a <readline+0xaa>
f0103545:	83 fb 0d             	cmp    $0xd,%ebx
f0103548:	75 8b                	jne    f01034d5 <readline+0x35>
			if (echoing)
f010354a:	85 ff                	test   %edi,%edi
f010354c:	74 0d                	je     f010355b <readline+0xbb>
				cputchar('\n');
f010354e:	83 ec 0c             	sub    $0xc,%esp
f0103551:	6a 0a                	push   $0xa
f0103553:	e8 4e d0 ff ff       	call   f01005a6 <cputchar>
f0103558:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010355b:	c6 86 40 e5 11 f0 00 	movb   $0x0,-0xfee1ac0(%esi)
			return buf;
f0103562:	b8 40 e5 11 f0       	mov    $0xf011e540,%eax
		}
	}
}
f0103567:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010356a:	5b                   	pop    %ebx
f010356b:	5e                   	pop    %esi
f010356c:	5f                   	pop    %edi
f010356d:	c9                   	leave  
f010356e:	c3                   	ret    
	...

f0103570 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103570:	55                   	push   %ebp
f0103571:	89 e5                	mov    %esp,%ebp
f0103573:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103576:	80 3a 00             	cmpb   $0x0,(%edx)
f0103579:	74 0e                	je     f0103589 <strlen+0x19>
f010357b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0103580:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103581:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103585:	75 f9                	jne    f0103580 <strlen+0x10>
f0103587:	eb 05                	jmp    f010358e <strlen+0x1e>
f0103589:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010358e:	c9                   	leave  
f010358f:	c3                   	ret    

f0103590 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103590:	55                   	push   %ebp
f0103591:	89 e5                	mov    %esp,%ebp
f0103593:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103596:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103599:	85 d2                	test   %edx,%edx
f010359b:	74 17                	je     f01035b4 <strnlen+0x24>
f010359d:	80 39 00             	cmpb   $0x0,(%ecx)
f01035a0:	74 19                	je     f01035bb <strnlen+0x2b>
f01035a2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01035a7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01035a8:	39 d0                	cmp    %edx,%eax
f01035aa:	74 14                	je     f01035c0 <strnlen+0x30>
f01035ac:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01035b0:	75 f5                	jne    f01035a7 <strnlen+0x17>
f01035b2:	eb 0c                	jmp    f01035c0 <strnlen+0x30>
f01035b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01035b9:	eb 05                	jmp    f01035c0 <strnlen+0x30>
f01035bb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01035c0:	c9                   	leave  
f01035c1:	c3                   	ret    

f01035c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01035c2:	55                   	push   %ebp
f01035c3:	89 e5                	mov    %esp,%ebp
f01035c5:	53                   	push   %ebx
f01035c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01035c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01035cc:	ba 00 00 00 00       	mov    $0x0,%edx
f01035d1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01035d4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01035d7:	42                   	inc    %edx
f01035d8:	84 c9                	test   %cl,%cl
f01035da:	75 f5                	jne    f01035d1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01035dc:	5b                   	pop    %ebx
f01035dd:	c9                   	leave  
f01035de:	c3                   	ret    

f01035df <strcat>:

char *
strcat(char *dst, const char *src)
{
f01035df:	55                   	push   %ebp
f01035e0:	89 e5                	mov    %esp,%ebp
f01035e2:	53                   	push   %ebx
f01035e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01035e6:	53                   	push   %ebx
f01035e7:	e8 84 ff ff ff       	call   f0103570 <strlen>
f01035ec:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01035ef:	ff 75 0c             	pushl  0xc(%ebp)
f01035f2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01035f5:	50                   	push   %eax
f01035f6:	e8 c7 ff ff ff       	call   f01035c2 <strcpy>
	return dst;
}
f01035fb:	89 d8                	mov    %ebx,%eax
f01035fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103600:	c9                   	leave  
f0103601:	c3                   	ret    

f0103602 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103602:	55                   	push   %ebp
f0103603:	89 e5                	mov    %esp,%ebp
f0103605:	56                   	push   %esi
f0103606:	53                   	push   %ebx
f0103607:	8b 45 08             	mov    0x8(%ebp),%eax
f010360a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010360d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103610:	85 f6                	test   %esi,%esi
f0103612:	74 15                	je     f0103629 <strncpy+0x27>
f0103614:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103619:	8a 1a                	mov    (%edx),%bl
f010361b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010361e:	80 3a 01             	cmpb   $0x1,(%edx)
f0103621:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103624:	41                   	inc    %ecx
f0103625:	39 ce                	cmp    %ecx,%esi
f0103627:	77 f0                	ja     f0103619 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103629:	5b                   	pop    %ebx
f010362a:	5e                   	pop    %esi
f010362b:	c9                   	leave  
f010362c:	c3                   	ret    

f010362d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010362d:	55                   	push   %ebp
f010362e:	89 e5                	mov    %esp,%ebp
f0103630:	57                   	push   %edi
f0103631:	56                   	push   %esi
f0103632:	53                   	push   %ebx
f0103633:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103636:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103639:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010363c:	85 f6                	test   %esi,%esi
f010363e:	74 32                	je     f0103672 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0103640:	83 fe 01             	cmp    $0x1,%esi
f0103643:	74 22                	je     f0103667 <strlcpy+0x3a>
f0103645:	8a 0b                	mov    (%ebx),%cl
f0103647:	84 c9                	test   %cl,%cl
f0103649:	74 20                	je     f010366b <strlcpy+0x3e>
f010364b:	89 f8                	mov    %edi,%eax
f010364d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0103652:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103655:	88 08                	mov    %cl,(%eax)
f0103657:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103658:	39 f2                	cmp    %esi,%edx
f010365a:	74 11                	je     f010366d <strlcpy+0x40>
f010365c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
f0103660:	42                   	inc    %edx
f0103661:	84 c9                	test   %cl,%cl
f0103663:	75 f0                	jne    f0103655 <strlcpy+0x28>
f0103665:	eb 06                	jmp    f010366d <strlcpy+0x40>
f0103667:	89 f8                	mov    %edi,%eax
f0103669:	eb 02                	jmp    f010366d <strlcpy+0x40>
f010366b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010366d:	c6 00 00             	movb   $0x0,(%eax)
f0103670:	eb 02                	jmp    f0103674 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103672:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0103674:	29 f8                	sub    %edi,%eax
}
f0103676:	5b                   	pop    %ebx
f0103677:	5e                   	pop    %esi
f0103678:	5f                   	pop    %edi
f0103679:	c9                   	leave  
f010367a:	c3                   	ret    

f010367b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010367b:	55                   	push   %ebp
f010367c:	89 e5                	mov    %esp,%ebp
f010367e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103681:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103684:	8a 01                	mov    (%ecx),%al
f0103686:	84 c0                	test   %al,%al
f0103688:	74 10                	je     f010369a <strcmp+0x1f>
f010368a:	3a 02                	cmp    (%edx),%al
f010368c:	75 0c                	jne    f010369a <strcmp+0x1f>
		p++, q++;
f010368e:	41                   	inc    %ecx
f010368f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103690:	8a 01                	mov    (%ecx),%al
f0103692:	84 c0                	test   %al,%al
f0103694:	74 04                	je     f010369a <strcmp+0x1f>
f0103696:	3a 02                	cmp    (%edx),%al
f0103698:	74 f4                	je     f010368e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010369a:	0f b6 c0             	movzbl %al,%eax
f010369d:	0f b6 12             	movzbl (%edx),%edx
f01036a0:	29 d0                	sub    %edx,%eax
}
f01036a2:	c9                   	leave  
f01036a3:	c3                   	ret    

f01036a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01036a4:	55                   	push   %ebp
f01036a5:	89 e5                	mov    %esp,%ebp
f01036a7:	53                   	push   %ebx
f01036a8:	8b 55 08             	mov    0x8(%ebp),%edx
f01036ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01036ae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01036b1:	85 c0                	test   %eax,%eax
f01036b3:	74 1b                	je     f01036d0 <strncmp+0x2c>
f01036b5:	8a 1a                	mov    (%edx),%bl
f01036b7:	84 db                	test   %bl,%bl
f01036b9:	74 24                	je     f01036df <strncmp+0x3b>
f01036bb:	3a 19                	cmp    (%ecx),%bl
f01036bd:	75 20                	jne    f01036df <strncmp+0x3b>
f01036bf:	48                   	dec    %eax
f01036c0:	74 15                	je     f01036d7 <strncmp+0x33>
		n--, p++, q++;
f01036c2:	42                   	inc    %edx
f01036c3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01036c4:	8a 1a                	mov    (%edx),%bl
f01036c6:	84 db                	test   %bl,%bl
f01036c8:	74 15                	je     f01036df <strncmp+0x3b>
f01036ca:	3a 19                	cmp    (%ecx),%bl
f01036cc:	74 f1                	je     f01036bf <strncmp+0x1b>
f01036ce:	eb 0f                	jmp    f01036df <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01036d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01036d5:	eb 05                	jmp    f01036dc <strncmp+0x38>
f01036d7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01036dc:	5b                   	pop    %ebx
f01036dd:	c9                   	leave  
f01036de:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01036df:	0f b6 02             	movzbl (%edx),%eax
f01036e2:	0f b6 11             	movzbl (%ecx),%edx
f01036e5:	29 d0                	sub    %edx,%eax
f01036e7:	eb f3                	jmp    f01036dc <strncmp+0x38>

f01036e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01036e9:	55                   	push   %ebp
f01036ea:	89 e5                	mov    %esp,%ebp
f01036ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01036ef:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01036f2:	8a 10                	mov    (%eax),%dl
f01036f4:	84 d2                	test   %dl,%dl
f01036f6:	74 18                	je     f0103710 <strchr+0x27>
		if (*s == c)
f01036f8:	38 ca                	cmp    %cl,%dl
f01036fa:	75 06                	jne    f0103702 <strchr+0x19>
f01036fc:	eb 17                	jmp    f0103715 <strchr+0x2c>
f01036fe:	38 ca                	cmp    %cl,%dl
f0103700:	74 13                	je     f0103715 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103702:	40                   	inc    %eax
f0103703:	8a 10                	mov    (%eax),%dl
f0103705:	84 d2                	test   %dl,%dl
f0103707:	75 f5                	jne    f01036fe <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f0103709:	b8 00 00 00 00       	mov    $0x0,%eax
f010370e:	eb 05                	jmp    f0103715 <strchr+0x2c>
f0103710:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103715:	c9                   	leave  
f0103716:	c3                   	ret    

f0103717 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103717:	55                   	push   %ebp
f0103718:	89 e5                	mov    %esp,%ebp
f010371a:	8b 45 08             	mov    0x8(%ebp),%eax
f010371d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103720:	8a 10                	mov    (%eax),%dl
f0103722:	84 d2                	test   %dl,%dl
f0103724:	74 11                	je     f0103737 <strfind+0x20>
		if (*s == c)
f0103726:	38 ca                	cmp    %cl,%dl
f0103728:	75 06                	jne    f0103730 <strfind+0x19>
f010372a:	eb 0b                	jmp    f0103737 <strfind+0x20>
f010372c:	38 ca                	cmp    %cl,%dl
f010372e:	74 07                	je     f0103737 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103730:	40                   	inc    %eax
f0103731:	8a 10                	mov    (%eax),%dl
f0103733:	84 d2                	test   %dl,%dl
f0103735:	75 f5                	jne    f010372c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f0103737:	c9                   	leave  
f0103738:	c3                   	ret    

f0103739 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103739:	55                   	push   %ebp
f010373a:	89 e5                	mov    %esp,%ebp
f010373c:	57                   	push   %edi
f010373d:	56                   	push   %esi
f010373e:	53                   	push   %ebx
f010373f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103742:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103745:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103748:	85 c9                	test   %ecx,%ecx
f010374a:	74 30                	je     f010377c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010374c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103752:	75 25                	jne    f0103779 <memset+0x40>
f0103754:	f6 c1 03             	test   $0x3,%cl
f0103757:	75 20                	jne    f0103779 <memset+0x40>
		c &= 0xFF;
f0103759:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010375c:	89 d3                	mov    %edx,%ebx
f010375e:	c1 e3 08             	shl    $0x8,%ebx
f0103761:	89 d6                	mov    %edx,%esi
f0103763:	c1 e6 18             	shl    $0x18,%esi
f0103766:	89 d0                	mov    %edx,%eax
f0103768:	c1 e0 10             	shl    $0x10,%eax
f010376b:	09 f0                	or     %esi,%eax
f010376d:	09 d0                	or     %edx,%eax
f010376f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103771:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103774:	fc                   	cld    
f0103775:	f3 ab                	rep stos %eax,%es:(%edi)
f0103777:	eb 03                	jmp    f010377c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103779:	fc                   	cld    
f010377a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010377c:	89 f8                	mov    %edi,%eax
f010377e:	5b                   	pop    %ebx
f010377f:	5e                   	pop    %esi
f0103780:	5f                   	pop    %edi
f0103781:	c9                   	leave  
f0103782:	c3                   	ret    

f0103783 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103783:	55                   	push   %ebp
f0103784:	89 e5                	mov    %esp,%ebp
f0103786:	57                   	push   %edi
f0103787:	56                   	push   %esi
f0103788:	8b 45 08             	mov    0x8(%ebp),%eax
f010378b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010378e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103791:	39 c6                	cmp    %eax,%esi
f0103793:	73 34                	jae    f01037c9 <memmove+0x46>
f0103795:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103798:	39 d0                	cmp    %edx,%eax
f010379a:	73 2d                	jae    f01037c9 <memmove+0x46>
		s += n;
		d += n;
f010379c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010379f:	f6 c2 03             	test   $0x3,%dl
f01037a2:	75 1b                	jne    f01037bf <memmove+0x3c>
f01037a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01037aa:	75 13                	jne    f01037bf <memmove+0x3c>
f01037ac:	f6 c1 03             	test   $0x3,%cl
f01037af:	75 0e                	jne    f01037bf <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01037b1:	83 ef 04             	sub    $0x4,%edi
f01037b4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01037b7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01037ba:	fd                   	std    
f01037bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01037bd:	eb 07                	jmp    f01037c6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01037bf:	4f                   	dec    %edi
f01037c0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01037c3:	fd                   	std    
f01037c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01037c6:	fc                   	cld    
f01037c7:	eb 20                	jmp    f01037e9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01037c9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01037cf:	75 13                	jne    f01037e4 <memmove+0x61>
f01037d1:	a8 03                	test   $0x3,%al
f01037d3:	75 0f                	jne    f01037e4 <memmove+0x61>
f01037d5:	f6 c1 03             	test   $0x3,%cl
f01037d8:	75 0a                	jne    f01037e4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01037da:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01037dd:	89 c7                	mov    %eax,%edi
f01037df:	fc                   	cld    
f01037e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01037e2:	eb 05                	jmp    f01037e9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01037e4:	89 c7                	mov    %eax,%edi
f01037e6:	fc                   	cld    
f01037e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01037e9:	5e                   	pop    %esi
f01037ea:	5f                   	pop    %edi
f01037eb:	c9                   	leave  
f01037ec:	c3                   	ret    

f01037ed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01037ed:	55                   	push   %ebp
f01037ee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01037f0:	ff 75 10             	pushl  0x10(%ebp)
f01037f3:	ff 75 0c             	pushl  0xc(%ebp)
f01037f6:	ff 75 08             	pushl  0x8(%ebp)
f01037f9:	e8 85 ff ff ff       	call   f0103783 <memmove>
}
f01037fe:	c9                   	leave  
f01037ff:	c3                   	ret    

f0103800 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103800:	55                   	push   %ebp
f0103801:	89 e5                	mov    %esp,%ebp
f0103803:	57                   	push   %edi
f0103804:	56                   	push   %esi
f0103805:	53                   	push   %ebx
f0103806:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103809:	8b 75 0c             	mov    0xc(%ebp),%esi
f010380c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010380f:	85 ff                	test   %edi,%edi
f0103811:	74 32                	je     f0103845 <memcmp+0x45>
		if (*s1 != *s2)
f0103813:	8a 03                	mov    (%ebx),%al
f0103815:	8a 0e                	mov    (%esi),%cl
f0103817:	38 c8                	cmp    %cl,%al
f0103819:	74 19                	je     f0103834 <memcmp+0x34>
f010381b:	eb 0d                	jmp    f010382a <memcmp+0x2a>
f010381d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f0103821:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
f0103825:	42                   	inc    %edx
f0103826:	38 c8                	cmp    %cl,%al
f0103828:	74 10                	je     f010383a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
f010382a:	0f b6 c0             	movzbl %al,%eax
f010382d:	0f b6 c9             	movzbl %cl,%ecx
f0103830:	29 c8                	sub    %ecx,%eax
f0103832:	eb 16                	jmp    f010384a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103834:	4f                   	dec    %edi
f0103835:	ba 00 00 00 00       	mov    $0x0,%edx
f010383a:	39 fa                	cmp    %edi,%edx
f010383c:	75 df                	jne    f010381d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010383e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103843:	eb 05                	jmp    f010384a <memcmp+0x4a>
f0103845:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010384a:	5b                   	pop    %ebx
f010384b:	5e                   	pop    %esi
f010384c:	5f                   	pop    %edi
f010384d:	c9                   	leave  
f010384e:	c3                   	ret    

f010384f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010384f:	55                   	push   %ebp
f0103850:	89 e5                	mov    %esp,%ebp
f0103852:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103855:	89 c2                	mov    %eax,%edx
f0103857:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010385a:	39 d0                	cmp    %edx,%eax
f010385c:	73 12                	jae    f0103870 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f010385e:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0103861:	38 08                	cmp    %cl,(%eax)
f0103863:	75 06                	jne    f010386b <memfind+0x1c>
f0103865:	eb 09                	jmp    f0103870 <memfind+0x21>
f0103867:	38 08                	cmp    %cl,(%eax)
f0103869:	74 05                	je     f0103870 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010386b:	40                   	inc    %eax
f010386c:	39 c2                	cmp    %eax,%edx
f010386e:	77 f7                	ja     f0103867 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103870:	c9                   	leave  
f0103871:	c3                   	ret    

f0103872 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103872:	55                   	push   %ebp
f0103873:	89 e5                	mov    %esp,%ebp
f0103875:	57                   	push   %edi
f0103876:	56                   	push   %esi
f0103877:	53                   	push   %ebx
f0103878:	8b 55 08             	mov    0x8(%ebp),%edx
f010387b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010387e:	eb 01                	jmp    f0103881 <strtol+0xf>
		s++;
f0103880:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103881:	8a 02                	mov    (%edx),%al
f0103883:	3c 20                	cmp    $0x20,%al
f0103885:	74 f9                	je     f0103880 <strtol+0xe>
f0103887:	3c 09                	cmp    $0x9,%al
f0103889:	74 f5                	je     f0103880 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010388b:	3c 2b                	cmp    $0x2b,%al
f010388d:	75 08                	jne    f0103897 <strtol+0x25>
		s++;
f010388f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103890:	bf 00 00 00 00       	mov    $0x0,%edi
f0103895:	eb 13                	jmp    f01038aa <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103897:	3c 2d                	cmp    $0x2d,%al
f0103899:	75 0a                	jne    f01038a5 <strtol+0x33>
		s++, neg = 1;
f010389b:	8d 52 01             	lea    0x1(%edx),%edx
f010389e:	bf 01 00 00 00       	mov    $0x1,%edi
f01038a3:	eb 05                	jmp    f01038aa <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01038a5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01038aa:	85 db                	test   %ebx,%ebx
f01038ac:	74 05                	je     f01038b3 <strtol+0x41>
f01038ae:	83 fb 10             	cmp    $0x10,%ebx
f01038b1:	75 28                	jne    f01038db <strtol+0x69>
f01038b3:	8a 02                	mov    (%edx),%al
f01038b5:	3c 30                	cmp    $0x30,%al
f01038b7:	75 10                	jne    f01038c9 <strtol+0x57>
f01038b9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01038bd:	75 0a                	jne    f01038c9 <strtol+0x57>
		s += 2, base = 16;
f01038bf:	83 c2 02             	add    $0x2,%edx
f01038c2:	bb 10 00 00 00       	mov    $0x10,%ebx
f01038c7:	eb 12                	jmp    f01038db <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01038c9:	85 db                	test   %ebx,%ebx
f01038cb:	75 0e                	jne    f01038db <strtol+0x69>
f01038cd:	3c 30                	cmp    $0x30,%al
f01038cf:	75 05                	jne    f01038d6 <strtol+0x64>
		s++, base = 8;
f01038d1:	42                   	inc    %edx
f01038d2:	b3 08                	mov    $0x8,%bl
f01038d4:	eb 05                	jmp    f01038db <strtol+0x69>
	else if (base == 0)
		base = 10;
f01038d6:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01038db:	b8 00 00 00 00       	mov    $0x0,%eax
f01038e0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01038e2:	8a 0a                	mov    (%edx),%cl
f01038e4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01038e7:	80 fb 09             	cmp    $0x9,%bl
f01038ea:	77 08                	ja     f01038f4 <strtol+0x82>
			dig = *s - '0';
f01038ec:	0f be c9             	movsbl %cl,%ecx
f01038ef:	83 e9 30             	sub    $0x30,%ecx
f01038f2:	eb 1e                	jmp    f0103912 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01038f4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01038f7:	80 fb 19             	cmp    $0x19,%bl
f01038fa:	77 08                	ja     f0103904 <strtol+0x92>
			dig = *s - 'a' + 10;
f01038fc:	0f be c9             	movsbl %cl,%ecx
f01038ff:	83 e9 57             	sub    $0x57,%ecx
f0103902:	eb 0e                	jmp    f0103912 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0103904:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0103907:	80 fb 19             	cmp    $0x19,%bl
f010390a:	77 13                	ja     f010391f <strtol+0xad>
			dig = *s - 'A' + 10;
f010390c:	0f be c9             	movsbl %cl,%ecx
f010390f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103912:	39 f1                	cmp    %esi,%ecx
f0103914:	7d 0d                	jge    f0103923 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
f0103916:	42                   	inc    %edx
f0103917:	0f af c6             	imul   %esi,%eax
f010391a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f010391d:	eb c3                	jmp    f01038e2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010391f:	89 c1                	mov    %eax,%ecx
f0103921:	eb 02                	jmp    f0103925 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103923:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0103925:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103929:	74 05                	je     f0103930 <strtol+0xbe>
		*endptr = (char *) s;
f010392b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010392e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0103930:	85 ff                	test   %edi,%edi
f0103932:	74 04                	je     f0103938 <strtol+0xc6>
f0103934:	89 c8                	mov    %ecx,%eax
f0103936:	f7 d8                	neg    %eax
}
f0103938:	5b                   	pop    %ebx
f0103939:	5e                   	pop    %esi
f010393a:	5f                   	pop    %edi
f010393b:	c9                   	leave  
f010393c:	c3                   	ret    
f010393d:	00 00                	add    %al,(%eax)
	...

f0103940 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0103940:	55                   	push   %ebp
f0103941:	89 e5                	mov    %esp,%ebp
f0103943:	57                   	push   %edi
f0103944:	56                   	push   %esi
f0103945:	83 ec 10             	sub    $0x10,%esp
f0103948:	8b 7d 08             	mov    0x8(%ebp),%edi
f010394b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f010394e:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0103951:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0103954:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103957:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f010395a:	85 c0                	test   %eax,%eax
f010395c:	75 2e                	jne    f010398c <__udivdi3+0x4c>
    {
      if (d0 > n1)
f010395e:	39 f1                	cmp    %esi,%ecx
f0103960:	77 5a                	ja     f01039bc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103962:	85 c9                	test   %ecx,%ecx
f0103964:	75 0b                	jne    f0103971 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103966:	b8 01 00 00 00       	mov    $0x1,%eax
f010396b:	31 d2                	xor    %edx,%edx
f010396d:	f7 f1                	div    %ecx
f010396f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0103971:	31 d2                	xor    %edx,%edx
f0103973:	89 f0                	mov    %esi,%eax
f0103975:	f7 f1                	div    %ecx
f0103977:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103979:	89 f8                	mov    %edi,%eax
f010397b:	f7 f1                	div    %ecx
f010397d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010397f:	89 f8                	mov    %edi,%eax
f0103981:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103983:	83 c4 10             	add    $0x10,%esp
f0103986:	5e                   	pop    %esi
f0103987:	5f                   	pop    %edi
f0103988:	c9                   	leave  
f0103989:	c3                   	ret    
f010398a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f010398c:	39 f0                	cmp    %esi,%eax
f010398e:	77 1c                	ja     f01039ac <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103990:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
f0103993:	83 f7 1f             	xor    $0x1f,%edi
f0103996:	75 3c                	jne    f01039d4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103998:	39 f0                	cmp    %esi,%eax
f010399a:	0f 82 90 00 00 00    	jb     f0103a30 <__udivdi3+0xf0>
f01039a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01039a3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f01039a6:	0f 86 84 00 00 00    	jbe    f0103a30 <__udivdi3+0xf0>
f01039ac:	31 f6                	xor    %esi,%esi
f01039ae:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01039b0:	89 f8                	mov    %edi,%eax
f01039b2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01039b4:	83 c4 10             	add    $0x10,%esp
f01039b7:	5e                   	pop    %esi
f01039b8:	5f                   	pop    %edi
f01039b9:	c9                   	leave  
f01039ba:	c3                   	ret    
f01039bb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01039bc:	89 f2                	mov    %esi,%edx
f01039be:	89 f8                	mov    %edi,%eax
f01039c0:	f7 f1                	div    %ecx
f01039c2:	89 c7                	mov    %eax,%edi
f01039c4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01039c6:	89 f8                	mov    %edi,%eax
f01039c8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01039ca:	83 c4 10             	add    $0x10,%esp
f01039cd:	5e                   	pop    %esi
f01039ce:	5f                   	pop    %edi
f01039cf:	c9                   	leave  
f01039d0:	c3                   	ret    
f01039d1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f01039d4:	89 f9                	mov    %edi,%ecx
f01039d6:	d3 e0                	shl    %cl,%eax
f01039d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f01039db:	b8 20 00 00 00       	mov    $0x20,%eax
f01039e0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f01039e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01039e5:	88 c1                	mov    %al,%cl
f01039e7:	d3 ea                	shr    %cl,%edx
f01039e9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01039ec:	09 ca                	or     %ecx,%edx
f01039ee:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
f01039f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01039f4:	89 f9                	mov    %edi,%ecx
f01039f6:	d3 e2                	shl    %cl,%edx
f01039f8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
f01039fb:	89 f2                	mov    %esi,%edx
f01039fd:	88 c1                	mov    %al,%cl
f01039ff:	d3 ea                	shr    %cl,%edx
f0103a01:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
f0103a04:	89 f2                	mov    %esi,%edx
f0103a06:	89 f9                	mov    %edi,%ecx
f0103a08:	d3 e2                	shl    %cl,%edx
f0103a0a:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0103a0d:	88 c1                	mov    %al,%cl
f0103a0f:	d3 ee                	shr    %cl,%esi
f0103a11:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103a13:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103a16:	89 f0                	mov    %esi,%eax
f0103a18:	89 ca                	mov    %ecx,%edx
f0103a1a:	f7 75 ec             	divl   -0x14(%ebp)
f0103a1d:	89 d1                	mov    %edx,%ecx
f0103a1f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103a21:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103a24:	39 d1                	cmp    %edx,%ecx
f0103a26:	72 28                	jb     f0103a50 <__udivdi3+0x110>
f0103a28:	74 1a                	je     f0103a44 <__udivdi3+0x104>
f0103a2a:	89 f7                	mov    %esi,%edi
f0103a2c:	31 f6                	xor    %esi,%esi
f0103a2e:	eb 80                	jmp    f01039b0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103a30:	31 f6                	xor    %esi,%esi
f0103a32:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103a37:	89 f8                	mov    %edi,%eax
f0103a39:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103a3b:	83 c4 10             	add    $0x10,%esp
f0103a3e:	5e                   	pop    %esi
f0103a3f:	5f                   	pop    %edi
f0103a40:	c9                   	leave  
f0103a41:	c3                   	ret    
f0103a42:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0103a44:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103a47:	89 f9                	mov    %edi,%ecx
f0103a49:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103a4b:	39 c2                	cmp    %eax,%edx
f0103a4d:	73 db                	jae    f0103a2a <__udivdi3+0xea>
f0103a4f:	90                   	nop
		{
		  q0--;
f0103a50:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103a53:	31 f6                	xor    %esi,%esi
f0103a55:	e9 56 ff ff ff       	jmp    f01039b0 <__udivdi3+0x70>
	...

f0103a5c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0103a5c:	55                   	push   %ebp
f0103a5d:	89 e5                	mov    %esp,%ebp
f0103a5f:	57                   	push   %edi
f0103a60:	56                   	push   %esi
f0103a61:	83 ec 20             	sub    $0x20,%esp
f0103a64:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a67:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0103a6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0103a6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
f0103a70:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0103a73:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0103a76:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
f0103a79:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103a7b:	85 ff                	test   %edi,%edi
f0103a7d:	75 15                	jne    f0103a94 <__umoddi3+0x38>
    {
      if (d0 > n1)
f0103a7f:	39 f1                	cmp    %esi,%ecx
f0103a81:	0f 86 99 00 00 00    	jbe    f0103b20 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103a87:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0103a89:	89 d0                	mov    %edx,%eax
f0103a8b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103a8d:	83 c4 20             	add    $0x20,%esp
f0103a90:	5e                   	pop    %esi
f0103a91:	5f                   	pop    %edi
f0103a92:	c9                   	leave  
f0103a93:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103a94:	39 f7                	cmp    %esi,%edi
f0103a96:	0f 87 a4 00 00 00    	ja     f0103b40 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103a9c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0103a9f:	83 f0 1f             	xor    $0x1f,%eax
f0103aa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103aa5:	0f 84 a1 00 00 00    	je     f0103b4c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103aab:	89 f8                	mov    %edi,%eax
f0103aad:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103ab0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103ab2:	bf 20 00 00 00       	mov    $0x20,%edi
f0103ab7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0103aba:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103abd:	89 f9                	mov    %edi,%ecx
f0103abf:	d3 ea                	shr    %cl,%edx
f0103ac1:	09 c2                	or     %eax,%edx
f0103ac3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
f0103ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ac9:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103acc:	d3 e0                	shl    %cl,%eax
f0103ace:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103ad1:	89 f2                	mov    %esi,%edx
f0103ad3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0103ad5:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103ad8:	d3 e0                	shl    %cl,%eax
f0103ada:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103add:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103ae0:	89 f9                	mov    %edi,%ecx
f0103ae2:	d3 e8                	shr    %cl,%eax
f0103ae4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0103ae6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103ae8:	89 f2                	mov    %esi,%edx
f0103aea:	f7 75 f0             	divl   -0x10(%ebp)
f0103aed:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103aef:	f7 65 f4             	mull   -0xc(%ebp)
f0103af2:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103af5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103af7:	39 d6                	cmp    %edx,%esi
f0103af9:	72 71                	jb     f0103b6c <__umoddi3+0x110>
f0103afb:	74 7f                	je     f0103b7c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0103afd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b00:	29 c8                	sub    %ecx,%eax
f0103b02:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0103b04:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103b07:	d3 e8                	shr    %cl,%eax
f0103b09:	89 f2                	mov    %esi,%edx
f0103b0b:	89 f9                	mov    %edi,%ecx
f0103b0d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0103b0f:	09 d0                	or     %edx,%eax
f0103b11:	89 f2                	mov    %esi,%edx
f0103b13:	8a 4d ec             	mov    -0x14(%ebp),%cl
f0103b16:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103b18:	83 c4 20             	add    $0x20,%esp
f0103b1b:	5e                   	pop    %esi
f0103b1c:	5f                   	pop    %edi
f0103b1d:	c9                   	leave  
f0103b1e:	c3                   	ret    
f0103b1f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103b20:	85 c9                	test   %ecx,%ecx
f0103b22:	75 0b                	jne    f0103b2f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103b24:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b29:	31 d2                	xor    %edx,%edx
f0103b2b:	f7 f1                	div    %ecx
f0103b2d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0103b2f:	89 f0                	mov    %esi,%eax
f0103b31:	31 d2                	xor    %edx,%edx
f0103b33:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b38:	f7 f1                	div    %ecx
f0103b3a:	e9 4a ff ff ff       	jmp    f0103a89 <__umoddi3+0x2d>
f0103b3f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0103b40:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103b42:	83 c4 20             	add    $0x20,%esp
f0103b45:	5e                   	pop    %esi
f0103b46:	5f                   	pop    %edi
f0103b47:	c9                   	leave  
f0103b48:	c3                   	ret    
f0103b49:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103b4c:	39 f7                	cmp    %esi,%edi
f0103b4e:	72 05                	jb     f0103b55 <__umoddi3+0xf9>
f0103b50:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0103b53:	77 0c                	ja     f0103b61 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103b55:	89 f2                	mov    %esi,%edx
f0103b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b5a:	29 c8                	sub    %ecx,%eax
f0103b5c:	19 fa                	sbb    %edi,%edx
f0103b5e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0103b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103b6c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103b6f:	89 c1                	mov    %eax,%ecx
f0103b71:	2b 4d f4             	sub    -0xc(%ebp),%ecx
f0103b74:	1b 55 f0             	sbb    -0x10(%ebp),%edx
f0103b77:	eb 84                	jmp    f0103afd <__umoddi3+0xa1>
f0103b79:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103b7c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103b7f:	72 eb                	jb     f0103b6c <__umoddi3+0x110>
f0103b81:	89 f2                	mov    %esi,%edx
f0103b83:	e9 75 ff ff ff       	jmp    f0103afd <__umoddi3+0xa1>
